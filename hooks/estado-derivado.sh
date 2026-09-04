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
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

arnes_estado_derivado() {
  local destino cuerpo tmp
  local total=0 hechos=0 revision=0 progreso=0 bloqueados=0 otros=0 notas=0
  local f base linea filas='' pend_abiertas='?' rama='?' sha='?' limpio='?'

  arnes_parse_manifest_estado || return 0
  [ "$ARNES_ESTADO_ACTIVO" != "false" ] || return 0

  destino="$ARNES_PROJ/$ARNES_ESTADO_ARCHIVO"
  [ -d "$(dirname "$destino")" ] || return 0     # sin la carpeta, no se inventa

  # --- Los REQ, leidos del disco uno a uno (read, no cat: sin forks) ---
  for f in "$ARNES_PROJ/$ARNES_REQ_DIR"/*.md; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    case "$base" in README.md|readme.md) continue ;; esac
    local texto='' est=''
    IFS= read -r -d '' texto < "$f"
    while IFS= read -r linea; do
      case "$linea" in 'Estado:'*) est="${linea#Estado:}"; break ;; esac
    done <<< "$texto"
    arnes_norm_campo "$est"; est="$ARNES_CAMPO"
    # Sin `Estado:` no es un REQ, es una nota que vive en la misma carpeta. Medido:
    # el bloque decia 58 REQ y habia 57, porque contaba
    # `consecuencias-de-las-decisiones-abiertas.md`. Un bloque que presume de
    # derivar del disco no puede decir 58 donde el disco dice 57. Se cuentan aparte
    # y se DICE, en vez de esconderlos: que un archivo quede fuera por silencio es
    # justo lo que este bloque existe para evitar.
    if [ -z "$est" ]; then notas=$((notas+1)); continue; fi
    arnes_campos_req "$texto" ''
    total=$((total+1))
    case "$est" in
      "$ARNES_ESTADO_DONE") hechos=$((hechos+1)) ;;
      en-revision|en-revisión) revision=$((revision+1)) ;;
      en-progreso)            progreso=$((progreso+1)) ;;
      bloqueado)              bloqueados=$((bloqueados+1)) ;;
      *)                      otros=$((otros+1)) ;;
    esac
    # Solo lo ABIERTO va a la tabla. El bloque responde "donde quedamos", y un REQ
    # completado ya no es parte de esa respuesta: es historia, y la linea de conteo
    # ya lo resume. Medido: con 58 REQ el bloque pesaba 10,4 KB -- un 25 % sobre un
    # ESTADO.md de 40 KB que se lee al empezar CADA sesion. Es justo el presupuesto
    # que la rotacion existe para cuidar, y aqui se lo estaba comiendo el arnes.
    if [ "$est" != "$ARNES_ESTADO_DONE" ]; then
      filas+="| ${base%.md} | ${est:-—} | ${ARNES_QA:-—} | ${ARNES_SEG:-—} | ${ARNES_RIGOR:-—} | ${ARNES_HALL:-—} |"$'\n'
    fi
  done

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
