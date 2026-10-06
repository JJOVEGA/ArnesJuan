#!/usr/bin/env bash
# Fuera del paso 5 (observación): variables de estado de lib.sh heredadas del entorno del hook.
source /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127/qa/sonda-qa.sh; prep_proy
JSRC="$(jq -cn --arg c "$PQ" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:"src/a.ts",content:"x"}}')"
c() { local a=$1 s=$2 red=$3; shift 3; local out; out="$(cd "$PQ"; unset LC_ALL ARNES_INPUT; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$PQ"; for v in "$@"; do export "$v"; done; eval "bash \"\${H[$a]}/$s\" $red" 2>/dev/null)"; printf '%s rc=%s' "$(dec "$out")" $?; }
printf '%s' "$JSRC" > "$S/jsrc.json"
for vars in "" "ARNES_INPUT_LISTO=1" "ARNES_INPUT_LISTO=1 ARNES_TOOL=Read" "ARNES_MANIFEST_LISTO=1" "ARNES_GLOBS_CARGADOS=1"; do
  for a in cand v135; do for s in guard.sh guard-codigo.sh; do
    printf '%-40s %-5s %-16s Write src/ coordinadora legible: %s | entrada cerrada: %s\n' "[$vars]" $a $s "$(c $a $s "< '$S/jsrc.json'" $vars)" "$(c $a $s '<&-' $vars)"
  done; done
done
