#!/usr/bin/env bash
# Hook Stop / SubagentStop: mueve las secciones viejas de un artefacto que crecio
# demasiado a un archivo aparte, dejando un puntero. Y, desde 1.31.0, mueve las
# entradas viejas de UNA SECCION de un documento (p. ej. `## Historial` de un REQ).
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
# - CORTA SOLO EN LIMITES DE SECCION (`## `) o de ENTRADA. Si no encuentra limites
#   seguros, no hace nada. Un corte a media seccion parte una entrada en dos.
# - NUNCA BLOQUEA la parada, como el resto de hooks Stop.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

arnes_rotar_artefactos() {
  local tipo ruta orden umbral conservar seccion adir f
  arnes_parse_manifest_rotacion || return 0
  [ "$ARNES_ROT_ACTIVO" = "true" ] || return 0
  [ -n "$ARNES_ROT_LISTA" ] || return 0
  while IFS=$'\t' read -r tipo ruta orden umbral conservar seccion adir; do
    [ -n "$ruta" ] || continue
    arnes_ruta_interna "$ruta" || continue   # fuera del proyecto: no se toca
    case "$tipo" in
      seccion)
        # El glob se expande AQUI (globbing encendido, como en todo el hook de parada) y
        # cada archivo pasa por la misma contencion fisica que un artefacto por ruta.
        for f in "$ARNES_PROJ"/$ruta; do
          [ -f "$f" ] || continue
          arnes_rotar_seccion "$f" "$seccion" "$orden" "$umbral" "$conservar" "$adir" || true
        done ;;
      *)
        arnes_rotar_uno "$ARNES_PROJ/$ruta" "$orden" "$umbral" "$conservar" || true ;;
    esac
  done <<< "$ARNES_ROT_LISTA"
  return 0
}

# arnes_rotar_uno <ruta> <orden> <umbral> <conservar> — rota UN artefacto si le toca.
# Los ajustes llegan por parametro, no por global: cada artefacto tiene los suyos.
arnes_rotar_uno() {
  local f="$1" orden="$2" umbral="$3" conservar="$4" destino tam texto linea
  local preambulo='' seccion='' secciones=0 i=0 corte
  [ -f "$f" ] || return 0
  arnes_dir_interno "${f%/*}" || return 0   # contencion FISICA: el directorio del artefacto, resuelto, dentro del proyecto

  # Sin `wc -c`: era un fork por artefacto en CADA parada, aunque no hubiera nada que
  # rotar (medido: 12,6 s en un proyecto real con dos artefactos y nada que mover).
  # El archivo se lee de todos modos justo despues; se compara la longitud leida.
  # `umbral_bytes` mide BYTES, y ${#texto} cuenta CARACTERES salvo en locale C: un
  # archivo UTF-8 de 4 032 bytes y 2 032 caracteres con umbral 3 000 rotaba en 1.29.2 y
  # dejo de rotar en 1.29.3. Lo midio una revision externa. LC_ALL=C solo para la
  # cuenta, y se restaura: el resto de la funcion no depende del locale, pero no hay
  # razon para cambiarselo a `date` ni a `grep`.
  IFS= read -r -d '' texto < "$f"
  local _lc_prev="${LC_ALL-__sin__}" tam_bytes
  LC_ALL=C; tam_bytes="${#texto}"
  if [ "$_lc_prev" = "__sin__" ]; then unset LC_ALL; else LC_ALL="$_lc_prev"; fi
  [ "$tam_bytes" -gt "$umbral" ] 2>/dev/null || return 0

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

  # --- 1) Construir el destino COMPLETO aparte, verificarlo, y solo entonces mover --
  #
  # Antes se anadia al destino y DESPUES se verificaba. Cuando la verificacion
  # fallaba, el contenido ya estaba en el destino y el origen no se recortaba: quedaba
  # DUPLICADO, y la siguiente parada lo volvia a anadir. Medido con un archivo CRLF:
  # 3 -> 6 -> 9 secciones en tres pasadas. Una fuga sin tope, justo en la funcion cuyo
  # proposito es frenar el crecimiento sin tope.
  #
  # Ahora el destino se arma en un temporal y solo se publica si la verificacion pasa.
  # Todo o nada: ni se pierde contenido ni se duplica.
  local marca tmp_dest
  marca="<!-- ARNES:ROTADO $(date '+%Y-%m-%d %H:%M') -->"
  tmp_dest="$destino.arnes.tmp"
  if [ -f "$destino" ]; then
    cat "$destino" > "$tmp_dest" || return 0
  else
    printf '# Archivo de %s\n\n> Secciones retiradas de `%s` para que no crezca sin tope.\n> Se MOVIERON tal cual: aqui no hay resumen ni reescritura.\n\n' \
      "$(basename "$f")" "$(basename "$f")" > "$tmp_dest" || return 0
  fi
  printf '%s\n%s\n' "$marca" "$viejo" >> "$tmp_dest" || { rm -f "$tmp_dest"; return 0; }

  # La prueba no es que el append no fallara: es que el texto ESTE en el disco.
  #
  # Se comprueba con `grep -F`, no con `case`: un encabezado de CHANGELOG lleva
  # corchetes --`## [1.20.0]`-- y en un patron de `case` los corchetes son una CLASE
  # DE CARACTERES, no texto.
  #
  # Y a la sonda se le RETIRA EL CR FINAL. En un archivo CRLF, cortar por el salto de
  # linea deja el CR pegado al final de la sonda, mientras que grep en Windows lee el
  # archivo en modo texto y ya lo ha quitado de sus lineas: 92 bytes contra 91, y no
  # casaba NUNCA. Es la misma familia que el CR de jq que dejaba `guard-codigo` en
  # abierto -- solo que aqui viene del propio archivo, y en Windows eso es la mayoria
  # de los archivos. Quitarlo es seguro en los dos casos: `-F` busca subcadena, asi
  # que la sonda sin CR casa igual con una linea que lo conserve.
  local sonda NL=$'\n' CR=$'\r'
  sonda="${viejo%%"$NL"*}"
  sonda="${sonda%"$CR"}"
  grep -qF -- "$sonda" "$tmp_dest" || { rm -f "$tmp_dest"; return 0; }
  mv -f "$tmp_dest" "$destino" || { rm -f "$tmp_dest"; return 0; }

  # --- 2) Solo ahora se recorta el origen ---
  local puntero="> Las secciones anteriores se movieron a [\`$(basename "$destino")\`]($(basename "$destino")) — el arnés las rota para que este archivo no crezca sin tope."
  printf '%s%s\n\n%s' "$preambulo" "$puntero" "$nuevo" > "$f.arnes.tmp" && mv -f "$f.arnes.tmp" "$f"
  return 0
}

# arnes_rotar_seccion <archivo> <seccion> <orden> <umbral> <conservar> <archivo_dir>
# Rota UNA SECCION de un documento —p. ej. `## Historial` de un REQ— moviendo sus
# entradas viejas a un archivo aparte. El resto del documento NO SE TOCA: los
# criterios de aceptacion son el contrato, y el contrato no se rota nunca.
#
# POR QUE. Medido en un proyecto real: `requirements/` pesaba 3,73 MB en 47 archivos,
# 81 KB de media, con un REQ de 244 KB. Y el coste no lo paga solo la parada: lo paga
# cada agente que abre el REQ para leer dos criterios y se traga 244 KB de historia.
# Que es "historia rotable" lo decide cada proyecto (mapeo: glob + seccion); el arnes
# trae el mecanismo (cuantas entradas conservar, adonde mover, en que orden).
#
# ENTRADA = lo que empieza a columna cero por `- `, `* `, `### ` o `N. `. Las lineas
# que no empiezan asi pertenecen a la entrada anterior (continuaciones) o, antes de
# la primera, al preambulo de la seccion, que se conserva. Una seccion sin entradas
# reconocibles no se toca: no hay limite seguro donde cortar.
arnes_rotar_seccion() {
  local f="$1" sec="$2" orden="$3" umbral="$4" conservar="$5" adir="$6"
  local texto linea antes='' cab='' cuerpo='' despues='' fase=0
  [ -f "$f" ] || return 0
  arnes_dir_interno "${f%/*}" || return 0
  texto=''; IFS= read -r -d '' texto < "$f"

  # 1) La seccion va de su cabecera (el prefijo declarado, p. ej. `## Historial`) a la
  #    siguiente cabecera `## ` o al final del documento. Lo de antes y lo de despues
  #    se conserva byte a byte.
  while IFS= read -r linea || [ -n "$linea" ]; do
    case "$fase" in
      0) case "$linea" in "$sec"*) cab="$linea"$'\n'; fase=1 ;; *) antes+="$linea"$'\n' ;; esac ;;
      1) case "$linea" in '## '*) despues+="$linea"$'\n'; fase=2 ;; *) cuerpo+="$linea"$'\n' ;; esac ;;
      *) despues+="$linea"$'\n' ;;
    esac
  done <<< "$texto"
  [ "$fase" -ge 1 ] || return 0

  # 2) Solo si la SECCION (no el archivo) pesa mas del umbral, en bytes.
  local _lc_prev="${LC_ALL-__sin__}" tam_bytes
  LC_ALL=C; tam_bytes="${#cuerpo}"
  if [ "$_lc_prev" = "__sin__" ]; then unset LC_ALL; else LC_ALL="$_lc_prev"; fi
  [ "$tam_bytes" -gt "$umbral" ] 2>/dev/null || return 0

  # 3) Preambulo de la seccion + entradas.
  local -a ent=()
  local pre='' cur='' hay=0
  while IFS= read -r linea || [ -n "$linea" ]; do
    case "$linea" in
      '- '*|'* '*|'### '*|[0-9]'. '*|[0-9][0-9]'. '*|[0-9][0-9][0-9]'. '*)
        [ "$hay" -eq 1 ] && ent+=("$cur")
        cur="$linea"$'\n'; hay=1 ;;
      *)
        if [ "$hay" -eq 1 ]; then cur+="$linea"$'\n'; else pre+="$linea"$'\n'; fi ;;
    esac
  done <<< "$cuerpo"
  [ "$hay" -eq 1 ] && ent+=("$cur")
  local total="${#ent[@]}"
  [ "$total" -gt "$conservar" ] 2>/dev/null || return 0

  # 4) Lo viejo se DECLARA con `orden`, como en el artefacto entero. Un historial
  #    suele anadir al final (`nuevo-al-final`); un CHANGELOG pone lo nuevo arriba.
  local viejo='' nuevo='' i corte="$conservar"
  if [ "$orden" = "nuevo-al-final" ]; then
    for (( i=0; i<total-corte; i++ )); do viejo+="${ent[$i]}"; done
    for (( i=total-corte; i<total; i++ )); do nuevo+="${ent[$i]}"; done
  else
    for (( i=corte; i<total; i++ )); do viejo+="${ent[$i]}"; done
    for (( i=0; i<corte; i++ )); do nuevo+="${ent[$i]}"; done
  fi
  [ -n "$viejo" ] || return 0

  # 5) Destino: `<archivo_dir>/<nombre>`; por defecto `<carpeta del documento>/historial/`.
  #    Contenido fisicamente en el proyecto. Se arma aparte, se verifica, y solo entonces
  #    se recorta el origen: todo o nada, exactamente como en arnes_rotar_uno.
  local nombre="${f##*/}" dir_dest destino rel_dest NL=$'\n' CR=$'\r' cab1
  cab1="${cab%%"$NL"*}"; cab1="${cab1%"$CR"}"
  if [ -n "$adir" ]; then
    arnes_ruta_interna "$adir" || return 0
    dir_dest="$ARNES_PROJ/$adir"; rel_dest="$adir/$nombre"
  else
    dir_dest="${f%/*}/historial"; rel_dest="historial/$nombre"
  fi
  mkdir -p "$dir_dest" 2>/dev/null || return 0
  arnes_dir_interno "$dir_dest" || return 0
  destino="$dir_dest/$nombre"
  local marca tmp_dest sonda
  marca="<!-- ARNES:ROTADO $(date '+%Y-%m-%d %H:%M') -->"
  tmp_dest="$destino.arnes.tmp"
  if [ -f "$destino" ]; then
    cat "$destino" > "$tmp_dest" || return 0
  else
    printf '# %s — archivo de «%s»\n\n> Entradas retiradas de la sección `%s` de `%s` para que no crezca sin tope.\n> Se MOVIERON tal cual: aquí no hay resumen ni reescritura. El resto del documento no se tocó.\n\n' \
      "${nombre%.md}" "${cab1#\#\# }" "$cab1" "$nombre" > "$tmp_dest" || return 0
  fi
  printf '%s\n%s\n' "$marca" "$viejo" >> "$tmp_dest" || { rm -f "$tmp_dest"; return 0; }
  sonda="${viejo%%"$NL"*}"; sonda="${sonda%"$CR"}"
  grep -qF -- "$sonda" "$tmp_dest" || { rm -f "$tmp_dest"; return 0; }
  mv -f "$tmp_dest" "$destino" || { rm -f "$tmp_dest"; return 0; }

  # 6) Recortar el origen: lo de antes + cabecera + preambulo + puntero (una sola vez;
  #    la idempotencia de las entradas sale del conteo) + lo conservado + lo de despues.
  local puntero="> Entradas anteriores de esta sección en [\`$rel_dest\`]($rel_dest) — el arnés las mueve para que este archivo no crezca sin tope; el resto del documento no se toca."
  case "$pre" in *"$rel_dest"*) ;; *) pre+="$puntero"$'\n\n' ;; esac
  printf '%s%s%s%s%s' "$antes" "$cab" "$pre" "$nuevo" "$despues" > "$f.arnes.tmp" && mv -f "$f.arnes.tmp" "$f"
  return 0
}

arnes_parse_manifest_rotacion() {
  # `artefactos` acepta CADENA u OBJETO, la misma convencion que ya usan las
  # quality_gates. Una cadena hereda los ajustes globales; un objeto declara los
  # suyos. Asi un manifiesto que hoy dice ["CHANGELOG.md"] sigue funcionando igual.
  #
  # Un objeto con `glob` y `seccion` es una rotacion DE SECCION: rota esa seccion en
  # cada archivo que case, conservando `conservar_entradas` (20 por defecto) y moviendo
  # el resto a `archivo_dir` (por defecto `historial/` junto al documento).
  #
  # POR QUE por artefacto y no global: medido en un proyecto real, el CHANGELOG crece
  # por arriba y el registro de seguridad por abajo. Un solo `orden` no puede servir a
  # los dos, y equivocarse archiva lo MAS RECIENTE. Con el orden global la funcion era
  # inservible para uno de los dos archivos; el error fue mio y es el mismo de siempre:
  # el orden es una propiedad DEL ARTEFACTO, no del proyecto.
  #
  # Cada fila: tipo \t ruta-o-glob \t orden \t umbral \t conservar \t seccion \t archivo_dir
  arnes_jq_file "$ARNES_MANIFEST" -r '
    . as $m
    | ($m.rotacion.umbral_bytes // 262144) as $u
    | ($m.rotacion.conservar_secciones // 12) as $c
    | (if $m.rotacion.orden == "nuevo-al-final" then "nuevo-al-final" else "nuevo-primero" end) as $o
    | [ (if $m.rotacion.activo == true then "true" else "false" end) ]
      + [ ($m.rotacion.artefactos // [])[]
          | if type == "object" then
              (if (.glob // "") != "" and (.seccion // "") != "" then
                 [ "seccion", .glob,
                   (if (.orden // $o) == "nuevo-al-final" then "nuevo-al-final" else "nuevo-primero" end),
                   ((.umbral_bytes // $u) | tostring),
                   ((.conservar_entradas // 20) | tostring),
                   .seccion, (.archivo_dir // "") ]
               else
                 [ "archivo", (.ruta // .archivo // ""),
                   (if (.orden // $o) == "nuevo-al-final" then "nuevo-al-final" else "nuevo-primero" end),
                   ((.umbral_bytes // $u) | tostring),
                   ((.conservar_secciones // $c) | tostring), "", "" ]
               end)
            else [ "archivo", ., $o, ($u | tostring), ($c | tostring), "", "" ]
            end
          | join("\t") ]
    | join("\n")' || return 1
  local primera=1 l
  ARNES_ROT_LISTA=''
  while IFS= read -r l; do
    if [ "$primera" = 1 ]; then ARNES_ROT_ACTIVO="$l"; primera=0; continue; fi
    ARNES_ROT_LISTA+="$l"$'\n'
  done <<< "$ARNES_JQ"
  return 0
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  arnes_preludio || exit 0
  arnes_rotar_artefactos || true
  exit 0
fi
