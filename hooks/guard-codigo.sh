#!/usr/bin/env bash
# guard-codigo.sh — Invariante A1: "la coordinadora no edita código de la app".
#
# Solo el agente de código (por defecto `desarrollador`) puede editar las rutas de
# código de la app. Cualquier edición desde la sesión coordinadora (sin `agent_id`)
# o desde otro subagente se DENIEGA. El editor se distingue por el campo `agent_id`
# del input del hook: presente sólo cuando la llamada viene de un subagente.
#
# Cubre `Edit`/`Write`/`MultiEdit` (por `file_path`) y, de forma DELIBERADAMENTE
# PARCIAL, `Bash` (redirecciones, `tee`, `cp`/`mv`/`install`, `sed -i`, `dd of=`).
# Ver `arnes_bash_escrituras` en lib.sh: es una barandilla contra el descuido, no
# una jaula contra un agente decidido a rodearla.
#
# La lógica vive en una FUNCIÓN para que `guard.sh` pueda ejecutar los dos
# guardianes en un solo arranque de intérprete, reutilizando el mismo análisis del
# input y del manifiesto. Este archivo sigue siendo ejecutable por su cuenta —el
# banco de pruebas lo invoca así— y en ambos casos corre exactamente el mismo
# código, que es lo que hace que las pruebas sigan valiendo.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

# ⚠️ REGLA CRÍTICA DE ESTA FUNCIÓN: "permitir" se dice con `return 0`, NUNCA con
# `exit 0`. Un `exit` aquí mataría el proceso entero y el segundo guardián no
# llegaría a correr — fallo abierto y en silencio, que es justo la familia de
# defecto que este arnés existe para impedir. `arnes_deny` sí termina el proceso,
# y eso es correcto: una denegación es final y no hay nada más que juzgar.
arnes_guard_codigo() {
  local objetivo="" via_bash=0 rel cand quien

  arnes_parse_input

  if [ "$ARNES_TOOL" = "Bash" ]; then
    [ -n "$ARNES_CMD" ] || return 0
    via_bash=1
    while IFS= read -r cand; do
      [ -n "$cand" ] || continue
      arnes_ruta_relativa "$cand" "$ARNES_PROJ"; rel="$ARNES_REL"
      if arnes_es_codigo_app "$rel" "$ARNES_MANIFEST"; then objetivo="$rel"; break; fi
    done <<< "$(arnes_bash_escrituras "$ARNES_CMD")"
  else
    [ -n "$ARNES_FP" ] || return 0
    arnes_ruta_relativa "$ARNES_FP" "$ARNES_PROJ"; rel="$ARNES_REL"
    arnes_es_codigo_app "$rel" "$ARNES_MANIFEST" && objetivo="$rel"
  fi

  [ -n "$objetivo" ] || return 0   # no es código de app -> permitir

  arnes_parse_manifest

  # Es código de app. Permitido SÓLO si es un subagente real (agent_id presente) Y
  # además es el agente de código designado. La comparación tolera el prefijo del
  # plugin (`arnes-juan:desarrollador` casa con `desarrollador`); ver lib.sh.
  if [ -n "$ARNES_AGENT_ID" ] && arnes_agente_coincide "$ARNES_AGENT_TYPE" "$ARNES_AGENTE_CODIGO"; then
    return 0
  fi

  # Editor no autorizado -> fail-closed, no silencioso.
  if [ -n "$ARNES_AGENT_ID" ]; then
    quien="el subagente $(arnes_agente_legible "${ARNES_AGENT_TYPE:-desconocido}")"
  else
    quien="la sesión coordinadora"
  fi
  if [ "$via_bash" -eq 1 ]; then
    arnes_deny "ARNES: el comando escribe en '$objetivo', que es código de la app; sólo el agente '$ARNES_AGENTE_CODIGO' puede hacerlo (intento de $quien). Escribirlo por Bash no salta la regla: delega el cambio en '$ARNES_AGENTE_CODIGO' (ver AGENTS.md §5). Nota: la detección en Bash es parcial (redirecciones, tee, cp/mv/install, sed -i, dd) — si esto es un falso positivo, repórtalo."
  fi
  arnes_deny "ARNES: '$objetivo' es código de la app; sólo el agente '$ARNES_AGENTE_CODIGO' puede editarlo (intento de $quien). Delega el cambio en '$ARNES_AGENTE_CODIGO' — ni siquiera al depurar se parchea a mano (ver AGENTS.md §5)."
}

# Ejecutado directamente (no `source`): hace su propio preludio y corre.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  arnes_preludio || exit 0
  arnes_guard_codigo
  exit 0
fi
