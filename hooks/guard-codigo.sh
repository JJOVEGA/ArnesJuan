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
set -uo pipefail
# Directorio del propio script por expansión de parámetro. La forma habitual
# —`$(cd "$(dirname ...)" && pwd)"`— son DOS forks anidados, y en esta
# plataforma un fork cuesta más que ejecutar el binario que va dentro.
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

# Lee stdin con el builtin `read`: `cat` costaba un fork y su sustitución, otro.
IFS= read -r -d '' input || true
arnes_require_jq || exit 0

arnes_project_dir "$input"; proj="$ARNES_PROJ"
[ -n "$proj" ] || exit 0
manifest="$proj/.arnes/config.json"
[ -f "$manifest" ] || exit 0   # no es un proyecto del arnés -> inerte

# UNA lectura del input para todo lo que se necesita de él. Este hook corre en
# CADA Edit/Write/MultiEdit y en CADA Bash; en Windows un arranque de proceso
# cuesta ~0,5 s, así que leer los campos por separado eran cinco `jq` más cinco
# `tr` por invocación. `command` va al final porque puede ser multilínea: se lee
# como el resto del flujo.
{ IFS= read -r tool; IFS= read -r agent_id; IFS= read -r agent_type; IFS= read -r fp
  comando="$(cat)"; } < <(
  printf '%s' "$input" | arnes_jq -r '[.tool_name // "",
                                       .agent_id // "",
                                       .agent_type // "",
                                       .tool_input.file_path // "",
                                       .tool_input.command // ""] | .[]')

# --- ¿Qué ruta(s) de código de la app toca esta llamada? ---
# Comparación en forma canónica: en Windows `proj` y `fp` llegan en formas distintas.
objetivo=""      # primera ruta de código de app detectada
via_bash=0
if [ "$tool" = "Bash" ]; then
  [ -n "$comando" ] || exit 0
  via_bash=1
  while IFS= read -r cand; do
    [ -n "$cand" ] || continue
    arnes_ruta_relativa "$cand" "$proj"; rel="$ARNES_REL"
    if arnes_es_codigo_app "$rel" "$manifest"; then objetivo="$rel"; break; fi
  done < <(arnes_bash_escrituras "$comando")
else
  [ -n "$fp" ] || exit 0
  arnes_ruta_relativa "$fp" "$proj"; rel="$ARNES_REL"
  arnes_es_codigo_app "$rel" "$manifest" && objetivo="$rel"
fi

[ -n "$objetivo" ] || exit 0   # no es código de app -> permitir

# Sólo aquí hace falta el manifiesto: la inmensa mayoría de las llamadas ya
# salieron arriba sin llegar a leerlo.
agente_codigo="$(arnes_jq -r '.agentes.agente_codigo // "desarrollador"' "$manifest")"

# Es código de app. Permitido SÓLO si es un subagente real (agent_id presente) Y
# además es el agente de código designado. La comparación tolera el prefijo del
# plugin (`arnes-juan:desarrollador` casa con `desarrollador`); ver lib.sh.
if [ -n "$agent_id" ] && arnes_agente_coincide "$agent_type" "$agente_codigo"; then
  exit 0
fi

# Editor no autorizado -> fail-closed, no silencioso.
if [ -n "$agent_id" ]; then
  quien="el subagente $(arnes_agente_legible "${agent_type:-desconocido}")"
else
  quien="la sesión coordinadora"
fi
if [ "$via_bash" -eq 1 ]; then
  arnes_deny "ARNES: el comando escribe en '$objetivo', que es código de la app; sólo el agente '$agente_codigo' puede hacerlo (intento de $quien). Escribirlo por Bash no salta la regla: delega el cambio en '$agente_codigo' (ver AGENTS.md §5). Nota: la detección en Bash es parcial (redirecciones, tee, cp/mv/install, sed -i, dd) — si esto es un falso positivo, repórtalo."
fi
arnes_deny "ARNES: '$objetivo' es código de la app; sólo el agente '$agente_codigo' puede editarlo (intento de $quien). Delega el cambio en '$agente_codigo' — ni siquiera al depurar se parchea a mano (ver AGENTS.md §5)."
