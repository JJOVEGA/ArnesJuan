#!/usr/bin/env bash
# Hook Stop / SubagentStop: deja en `docs/ESTADO.md` un bloque DERIVADO del disco.
#
# POR QUE EXISTE
# El coste mas caro de una sesion larga no es el tiempo: es tener que reconstruir
# donde quedo todo cuando el contexto se pierde. Y pedirle a un agente que resuma
# lo que hizo no lo resuelve, porque un resumen redactado por el modelo miente
# justo cuando mas falta hace -- cuando le queda poco contexto, que es cuando peor
# recuerda.
#
# Por eso este bloque NO SE REDACTA, SE DERIVA. Cada linea sale de leer un archivo:
# el estado de cada REQ, sus veredictos, la cola de aprobaciones, la rama y si el
# arbol esta limpio. Nada aqui es una opinion sobre el trabajo; todo es una lectura
# del trabajo. Si el bloque se equivoca, es que el disco dice eso.
#
# INVARIANTES
# - NUNCA bloquea. Un hook Stop que falla deja la sesion colgada, y una herramienta
#   de continuidad que impide terminar es peor que no tenerla. Sale 0 pase lo que pase.
# - IDEMPOTENTE. Reescribe entre marcadores; correrlo dos veces da lo mismo.
# - NO TOCA LO QUE ESCRIBIO UNA PERSONA. Fuera de los marcadores no se modifica nada,
#   y el bloque se anade al final si no existia.
# - INERTE sin `.arnes/config.json`, como los demas hooks.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

arnes_estado_derivado() {
  local destino cuerpo tmp v_plugin v_proyecto aviso_version
  local total=0 hechos=0 revision=0 progreso=0 bloqueados=0 otros=0 notas=0
  local f base linea filas='' pend_abiertas='?' rama='?' sha='?' limpio='?'

  arnes_parse_manifest_estado || return 0
  [ "$ARNES_ESTADO_ACTIVO" != "false" ] || return 0

  arnes_ruta_interna "$ARNES_ESTADO_ARCHIVO" || return 0   # fuera del proyecto: no se escribe
  destino="$ARNES_PROJ/$ARNES_ESTADO_ARCHIVO"
  [ -d "${destino%/*}" ] || return 0     # sin la carpeta, no se inventa (y sin fork: sin dirname)
  arnes_dir_interno "${destino%/*}" || return 0   # contencion FISICA: un symlink no saca la escritura del proyecto

  # --- Los REQ, en UNA pasada de awk (no linea a linea en bash) ------------------
  # Antes: dos bucles `while read` en bash POR ARCHIVO (uno para Estado:, otro dentro de
  # arnes_campos_req). Con REQ de 5 lineas, como los del banco, microsegundos. Medido en
  # un proyecto real --47 REQ, 3,73 MB, uno de 244 KB--: 92 s por parada, dos veces por
  # turno. Reproducido aqui con un fixture del mismo tamano: 126 818 ms. El banco no lo
  # vio porque sus artefactos no tienen tamano.
  #
  # awk procesa los 4 MB en un solo proceso y devuelve una linea por archivo con los seis
  # campos crudos; bash normaliza 47 lineas cortas por el MISMO camino que la puerta.
  # La semantica se conserva byte a byte (Estado: primera aparicion; el resto, ultima):
  # ver hooks/campos-req.awk.
  local -a REQS=()
  for f in "$ARNES_PROJ/$ARNES_REQ_DIR"/*.md; do
    [ -f "$f" ] || continue
    case "${f##*/}" in README.md|readme.md) continue ;; esac
    # Un .md VACIO no tiene lineas, asi que awk (FNR==1) nunca lo ve y no emitiria nada:
    # desapareceria del conteo. Antes del awk contaba como "archivo sin Estado", y eso
    # se conserva contandolo aqui. Lo encontro una revision externa comparando 1.29.2
    # con 1.29.3 archivo por archivo.
    if [ ! -s "$f" ]; then notas=$((notas+1)); continue; fi
    REQS+=("$f")
  done
  local extraidos=''
  if [ "${#REQS[@]}" -gt 0 ]; then
    extraidos="$(awk -f "$DIR/campos-req.awk" "${REQS[@]}" 2>/dev/null)" || extraidos=''
  fi
  local ruta c_est c_qa c_seg c_sens c_hall c_rig est
  while IFS=$'\001' read -r ruta c_est c_qa c_seg c_sens c_hall c_rig; do
    [ -n "$ruta" ] || continue
    base="${ruta##*/}"
    arnes_norm_campo "$c_est"; arnes_veredicto "$ARNES_CAMPO"; est="$ARNES_VEREDICTO"
    # Sin `Estado:` no es un REQ, es una nota que vive en la misma carpeta. Medido:
    # el bloque decia 58 REQ y habia 57. Se cuentan aparte y se DICE.
    if [ -z "$est" ]; then notas=$((notas+1)); continue; fi
    arnes_campos_normaliza "$c_qa" "$c_seg" "$c_sens" "$c_hall" "$c_rig"
    total=$((total+1))
    case "$est" in
      "$ARNES_ESTADO_DONE") hechos=$((hechos+1)) ;;
      en-revision|en-revisión) revision=$((revision+1)) ;;
      en-progreso)            progreso=$((progreso+1)) ;;
      bloqueado)              bloqueados=$((bloqueados+1)) ;;
      *)                      otros=$((otros+1)) ;;
    esac
    # Solo lo ABIERTO va a la tabla: el bloque responde "donde quedamos".
    if [ "$est" != "$ARNES_ESTADO_DONE" ]; then
      filas+="| ${base%.md} | ${est:-—} | ${ARNES_QA:-—} | ${ARNES_SEG:-—} | ${ARNES_RIGOR:-—} | ${ARNES_HALL:-—} |"$'\n'
    fi
  done <<< "$extraidos"

  # --- La cola de aprobaciones ---
  local pfile="$ARNES_PROJ/$ARNES_PENDING_REL"
  if [ -f "$pfile" ]; then
    local ptexto='' dentro=0 n=0
    IFS= read -r -d '' ptexto < "$pfile"
    while IFS= read -r linea; do
      case "$linea" in
        '## Pendientes'*) dentro=1; continue ;;
        '## '*)           dentro=0; continue ;;
      esac
      [ "$dentro" -eq 1 ] || continue
      case "$linea" in
        '- '*|'* '*|'1. '*) n=$((n+1)) ;;
      esac
    done <<< "$ptexto"
    pend_abiertas="$n"
  fi

  # --- Git: unos pocos forks, y solo en una parada de agente (no en cada Edit) ---
  #
  # Si git no puede responder --no hay repo, no esta instalado-- el estado del arbol
  # es DESCONOCIDO, y eso es lo que se escribe. No "limpio" ni "con cambios": las dos
  # serian afirmar un hecho que no se tiene. Es la misma regla que el resto del arnes
  # aplica a los valores que no entiende, y aqui costaria igual de barato equivocarse.
  rama='(sin repositorio)'; sha='—'; limpio='desconocido'
  if command -v git >/dev/null 2>&1 && git -C "$ARNES_PROJ" rev-parse --git-dir >/dev/null 2>&1; then
    rama="$(git -C "$ARNES_PROJ" rev-parse --abbrev-ref HEAD 2>/dev/null)" || rama='?'
    sha="$(git -C "$ARNES_PROJ" rev-parse --short HEAD 2>/dev/null)" || sha='?'
    if git -C "$ARNES_PROJ" diff --quiet 2>/dev/null && git -C "$ARNES_PROJ" diff --cached --quiet 2>/dev/null; then
      limpio='limpio'
    else
      limpio='CON CAMBIOS SIN COMITEAR'
    fi
  fi

  # --- Version instalada, visible en cada parada -------------------------------
  # Un proyecto real corrio 1.13.0 durante un MES con 1.24.0 publicada, sin ninguna
  # senal: el plugin no se actualiza solo. No se consulta la red --un hook que hace
  # DNS puede colgar una parada-- pero SI se ensena lo que es gratis: la version
  # instalada y la que el proyecto declara haber migrado. Verlo en cada sesion es lo
  # que faltaba; comparar contra el remoto es trabajo de /arnes-upgrade.
  if arnes_jq_file "$DIR/../.claude-plugin/plugin.json" -r '.version // "?"' 2>/dev/null
    then v_plugin="$ARNES_JQ"; else v_plugin='?'; fi
  if arnes_jq_file "$ARNES_MANIFEST" -r '.arnes_version // ""' 2>/dev/null
    then v_proyecto="$ARNES_JQ"; else v_proyecto=''; fi
  aviso_version="**Arnés:** plugin instalado \`$v_plugin\`"
  if [ -n "$v_proyecto" ] && [ "$v_proyecto" != "$v_plugin" ]; then
    aviso_version+=" · el proyecto declara \`$v_proyecto\` — **migración pendiente** (\`/arnes-upgrade\`)"
  fi

  # --- El bloque ---
  cuerpo="<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — $(date '+%Y-%m-%d %H:%M')

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** \`$rama\` @ \`$sha\` — $limpio
$aviso_version
**Aprobaciones pendientes:** $pend_abiertas
**REQ:** $total — completado $hechos · en-revisión $revision · en-progreso $progreso · bloqueado $bloqueados · otros $otros
**Otros archivos en \`$ARNES_REQ_DIR/\` sin \`Estado:\` (notas, no REQ):** $notas
"
  if [ -n "$filas" ]; then
    cuerpo+="
_Sólo los REQ abiertos; los $hechos completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
$filas"
  fi
  cuerpo+="
<!-- ARNES:DERIVADO fin -->"

  # --- Escritura idempotente: se reemplaza entre marcadores, o se anade al final ---
  tmp="$destino.arnes.tmp"
  if [ -f "$destino" ]; then
    local texto='' fuera='' saltando=0
    IFS= read -r -d '' texto < "$destino"
    while IFS= read -r linea; do
      case "$linea" in
        '<!-- ARNES:DERIVADO inicio'*) saltando=1; continue ;;
        '<!-- ARNES:DERIVADO fin'*)    saltando=0; continue ;;
      esac
      [ "$saltando" -eq 1 ] || fuera+="$linea"$'\n'
    done <<< "$texto"
    # Se recorta la cola de lineas vacias que deja el bloque retirado.
    while [ "${fuera%$'\n\n'}" != "$fuera" ]; do fuera="${fuera%$'\n'}"; done
    printf '%s\n%s\n' "$fuera" "$cuerpo" > "$tmp" && mv -f "$tmp" "$destino"
  else
    printf '%s\n' "$cuerpo" > "$tmp" && mv -f "$tmp" "$destino"
  fi
  return 0
}

# Campos del manifiesto que este hook necesita. Uno solo de jq.
arnes_parse_manifest_estado() {
  arnes_jq_file "$ARNES_MANIFEST" -r '
    [ (.estado_derivado.archivo   // "docs/ESTADO.md"),
      # OJO con `//` en jq: trata `false` IGUAL QUE ausente, asi que
      # `.activo // true` devuelve true cuando alguien escribio false y el
      # interruptor quedaba soldado en encendido. Solo un `false` EXPLICITO apaga;
      # ausente, null o cualquier otra cosa deja el hook activo, que es el lado
      # inocuo (solo escribe un bloque derivado).
      (if .estado_derivado.activo == false then "false" else "true" end),
      (.requirements_dir          // "requirements"),
      (.estados.completado        // "completado"),
      (.pending_approval          // "PENDING_APPROVAL.md") ] | join("\n")' || return 1
  local i=0 l
  while IFS= read -r l; do
    case "$i" in
      0) ARNES_ESTADO_ARCHIVO="$l" ;;
      1) ARNES_ESTADO_ACTIVO="$l" ;;
      2) ARNES_REQ_DIR="$l" ;;
      3) arnes_norm_campo "$l"; ARNES_ESTADO_DONE="$ARNES_CAMPO" ;;
      4) ARNES_PENDING_REL="$l" ;;
    esac
    i=$((i+1))
  done <<< "$ARNES_JQ"
  return 0
}

# Ejecutado directamente (no `source`).
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  # `|| exit 0` en TODO: una parada nunca se bloquea por este hook.
  arnes_preludio || exit 0
  arnes_estado_derivado || true
  exit 0
fi
