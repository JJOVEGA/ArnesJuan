#!/usr/bin/env bash
# Hook Stop / SubagentStop: mueve las secciones viejas de un artefacto que crecio
# demasiado a un archivo aparte, dejando un puntero.
#
# POR QUE EXISTE
# Un artefacto de bitacora --CHANGELOG, registro de seguridad, hallazgos-- crece sin
# tope, y todo lo que crece sin tope acaba entrando entero en la ventana de contexto.
# Medido en un proyecto real: el CHANGELOG.md llego a 1,17 MB. A ~4 caracteres por
# token son del orden de 300.000 tokens en UN archivo, y se pagan otra vez en cada
# sesion que lo lea. No es un problema de disco: es presupuesto.
#
# QUE NO HACE, Y ES LA PARTE IMPORTANTE
# No resume, no reescribe, no borra. MUEVE texto de un archivo a otro y deja un
# puntero. Un resumen aqui seria peor que el problema: convertiria la bitacora en
# la version que el modelo recuerda de la bitacora.
#
# INVARIANTES
# - APAGADO salvo que el proyecto lo encienda. Reestructurar un documento que
#   escribio una persona no puede ser el comportamiento por defecto.
# - NUNCA BORRA. Primero se anade al archivo destino, se RELEE para comprobar que
#   esta, y solo entonces se recorta el origen. Si la comprobacion falla, no se toca
#   el origen: se prefiere un archivo grande a un archivo perdido.
# - CORTA SOLO EN LIMITES DE SECCION (`## `). Si no encuentra limites seguros, no
#   hace nada. Un corte a media seccion parte una entrada en dos.
# - NUNCA BLOQUEA la parada, como el resto de hooks Stop.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

arnes_rotar_artefactos() {
  local ruta orden umbral conservar
  arnes_parse_manifest_rotacion || return 0
  [ "$ARNES_ROT_ACTIVO" = "true" ] || return 0
  [ -n "$ARNES_ROT_LISTA" ] || return 0
  while IFS=$'	' read -r ruta orden umbral conservar; do
    [ -n "$ruta" ] || continue
    arnes_rotar_uno "$ARNES_PROJ/$ruta" "$orden" "$umbral" "$conservar" || true
  done <<< "$ARNES_ROT_LISTA"
  return 0
}

# arnes_rotar_uno <ruta> <orden> <umbral> <conservar> — rota UN artefacto si le toca.
# Los ajustes llegan por parametro, no por global: cada artefacto tiene los suyos.
arnes_rotar_uno() {
  local f="$1" orden="$2" umbral="$3" conservar="$4" destino tam texto linea
  local preambulo='' seccion='' secciones=0 i=0 corte
  [ -f "$f" ] || return 0

  tam="$(wc -c < "$f" 2>/dev/null)" || return 0
  tam="${tam// /}"
  [ "$tam" -gt "$umbral" ] 2>/dev/null || return 0

  IFS= read -r -d '' texto < "$f"

  # --- Se parte en secciones de nivel 2. Sin limites, no se toca nada. ---
  local -a cuerpos=()
  while IFS= read -r linea; do
    case "$linea" in
      '## '*)
        if [ "$secciones" -eq 0 ]; then preambulo="$seccion"; else cuerpos+=("$seccion"); fi
        seccion="$linea"$'\n'; secciones=$((secciones+1)) ;;
      *)
        seccion+="$linea"$'\n' ;;
    esac
  done <<< "$texto"
  if [ "$secciones" -eq 0 ]; then return 0; fi
  cuerpos+=("$seccion")

  # Sin excedente por encima de lo que hay que conservar, no hay nada que mover.
  # Y como al terminar quedan EXACTAMENTE `conservar` secciones, la siguiente pasada
  # no encuentra excedente: la idempotencia sale de aqui, no de una comprobacion
  # aparte. (La primera version restaba al reves --conservaba `total - conservar`--
  # y cada pasada volvia a rotar, vaciando el archivo a trozos.)
  local total="${#cuerpos[@]}"
  [ "$total" -gt "$conservar" ] || return 0
  corte="$conservar"

  # --- Que mitad es "lo viejo" NO se adivina: se declara ---
  # Un CHANGELOG pone lo nuevo arriba; un registro cronologico lo anade al final.
  # Adivinar mal significa archivar lo mas RECIENTE, que es justo lo que hay que
  # tener a mano. Por defecto se asume la convencion del CHANGELOG, que es la que
  # usan las plantillas del arnes; lo contrario se declara con
  # `rotacion.orden: "nuevo-al-final"`.
  local viejo='' nuevo=''
  if [ "$orden" = "nuevo-al-final" ]; then
    for (( i=0; i<total-corte; i++ )); do viejo+="${cuerpos[$i]}"; done
    for (( i=total-corte; i<total; i++ )); do nuevo+="${cuerpos[$i]}"; done
  else
    for (( i=corte; i<total; i++ )); do viejo+="${cuerpos[$i]}"; done
    for (( i=0; i<corte; i++ )); do nuevo+="${cuerpos[$i]}"; done
  fi
  [ -n "$viejo" ] || return 0

  destino="${f%.md}-archivo.md"

  # --- 1) Anadir al destino, y RELEER para comprobar que llego ---
  local marca="<!-- ARNES:ROTADO $(date '+%Y-%m-%d %H:%M') -->"
  if [ ! -f "$destino" ]; then
    printf '# Archivo de %s\n\n> Secciones retiradas de `%s` para que no crezca sin tope.\n> Se MOVIERON tal cual: aqui no hay resumen ni reescritura.\n\n' \
      "$(basename "$f")" "$(basename "$f")" > "$destino" || return 0
  fi
  printf '%s\n%s\n' "$marca" "$viejo" >> "$destino" || return 0

  # La prueba no es que el append no fallara: es que el texto ESTE en el disco.
  #
  # Se comprueba con `grep -F`, no con `case`: un encabezado de CHANGELOG lleva
  # corchetes --`## [1.20.0]`-- y en un patron de `case` los corchetes son una CLASE
  # DE CARACTERES, no texto. La comprobacion habria fallado siempre y el recorte no
  # habria ocurrido nunca. Un fork, y solo cuando toca rotar.
  local sonda NL=$'\n'
  sonda="${viejo%%"$NL"*}"
  grep -qF -- "$sonda" "$destino" || return 0    # no llego: el origen NO se toca

  # --- 2) Solo ahora se recorta el origen ---
  local puntero="> Las secciones anteriores se movieron a [\`$(basename "$destino")\`]($(basename "$destino")) — el arnés las rota para que este archivo no crezca sin tope."
  printf '%s%s\n\n%s' "$preambulo" "$puntero" "$nuevo" > "$f.arnes.tmp" && mv -f "$f.arnes.tmp" "$f"
  return 0
}

arnes_parse_manifest_rotacion() {
  # `artefactos` acepta CADENA u OBJETO, la misma convencion que ya usan las
  # quality_gates. Una cadena hereda los ajustes globales; un objeto declara los
  # suyos. Asi un manifiesto que hoy dice ["CHANGELOG.md"] sigue funcionando igual.
  #
  # POR QUE por artefacto y no global: medido en un proyecto real, el CHANGELOG crece
  # por arriba y el registro de seguridad por abajo. Un solo `orden` no puede servir a
  # los dos, y equivocarse archiva lo MAS RECIENTE. Con el orden global la funcion era
  # inservible para uno de los dos archivos; el error fue mio y es el mismo de siempre:
  # el orden es una propiedad DEL ARTEFACTO, no del proyecto.
  arnes_jq_file "$ARNES_MANIFEST" -r '
    . as $m
    | ($m.rotacion.umbral_bytes // 262144) as $u
    | ($m.rotacion.conservar_secciones // 12) as $c
    | (if $m.rotacion.orden == "nuevo-al-final" then "nuevo-al-final" else "nuevo-primero" end) as $o
    | [ (if $m.rotacion.activo == true then "true" else "false" end) ]
      + [ ($m.rotacion.artefactos // [])[]
          | if type == "object"
            then [ (.ruta // .archivo // ""),
                   (if (.orden // $o) == "nuevo-al-final" then "nuevo-al-final" else "nuevo-primero" end),
                   ((.umbral_bytes // $u) | tostring),
                   ((.conservar_secciones // $c) | tostring) ]
            else [ ., $o, ($u | tostring), ($c | tostring) ]
            end
          | join("	") ]
    | join("
")' || return 1
  local primera=1 l
  ARNES_ROT_LISTA=''
  while IFS= read -r l; do
    if [ "$primera" = 1 ]; then ARNES_ROT_ACTIVO="$l"; primera=0; continue; fi
    ARNES_ROT_LISTA+="$l"$'
'
  done <<< "$ARNES_JQ"
  return 0
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  arnes_preludio || exit 0
  arnes_rotar_artefactos || true
  exit 0
fi
