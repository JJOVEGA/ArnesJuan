#!/usr/bin/env bash
# 50-reqs-reales.sh <hooksdir>... — CA-68, compatibilidad declarada: Write de REQ-021.md y REQ-023.md ENTEROS (copias de la
# cabeza en un proyecto con el manifiesto base), como coordinadora, por guard.sh: deben seguir sin decisión. Una corrida por punto.
set -u; QA=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa
W="${TMPDIR:-/tmp}/qa2-reqs-$$"; mkdir -p "$W"; . "$QA/h.sh"; P="$W/p"; mkp "$P"
for r in REQ-021.md REQ-023.md; do cp /home/juan/dev/ArnesJuan-v1.36/requirements/$r "$P/requirements/$r"
  jq -cn --arg fp "$P/requirements/$r" --arg c "$P" --rawfile ct "$P/requirements/$r" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$fp,content:$ct}}' > "$W/w-$r"
  for hd in "$@"; do echo "$r ($(wc -c < "$P/requirements/$r") B) hooks=$hd: $(corre "$hd" guard.sh "$W/w-$r")"; done; done
rm -rf "$W"
