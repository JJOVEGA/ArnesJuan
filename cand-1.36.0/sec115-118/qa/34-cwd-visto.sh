#!/usr/bin/env bash
# 34-cwd-visto.sh <scratch> <hooks>... — ARNES_CWD_VISTO heredada del entorno con el valor del `cwd` de la entrada.
set -u; S="$1"; shift; QD="$(cd "$(dirname "$0")" && pwd)"; . "$QD/h.sh"; P="$S/pcv"; mkp "$P"
jq -cn --arg c "$P/no-existe" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"echo x > src/a.ts"}}' > "$S/cv1"
jq -cn --arg c "$P/no-existe" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"echo Estado: completado > requirements/REQ-900.md"}}' > "$S/cv2"
jq -cn --arg c "$P/no-existe" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"echo x > ../src/a.ts"}}' > "$S/cv3"
echo "# $(date -Is)"
for H in "$@"; do for v in cv1 cv2 cv3; do for e in X=1 "ARNES_CWD_VISTO=$P/no-existe"; do
  printf '%s %s %-14s %s\n' "$H" "$v" "${e%%=*}" "$(corre "$H" guard.sh "$S/$v" "$e")"; done; done; done
