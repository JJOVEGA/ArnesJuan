#!/usr/bin/env bash
# SEC-128: el nombre de la herramienta con CR, salto o en minúsculas, con file_path 5 y el enlace <raíz>/5 -> src/a.ts.
source /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127/qa/sonda-qa.sh; prep_proy; ln -sfn src/a.ts "$PQ/5"
for tn in 'Edit\r' 'Edit\n' 'edit' 'Write\r' 'MultiEdit\r' 'NotebookEdit'; do for ag in - desarrollador qa-tester; do
  j="$(jq -cn --arg c "$PQ" --arg a "$ag" "{hook_event_name:\"PreToolUse\",tool_name:\"$tn\",cwd:\$c,tool_input:{file_path:5,old_string:\"a\",new_string:\"b\",content:\"x\",edits:[]}} + (if \$a == \"-\" then {} else {agent_id:\"a1\",agent_type:\$a} end)")"
  printf '%-12s %-14s' "$tn" "$ag"; for a in cand a599 v135; do printf ' | %s gc=%s' $a "$(pr $a guard-codigo.sh "$j" | cut -c1-45)"; done; printf ' | cand guard.sh=%s\n' "$(pr cand guard.sh "$j" | cut -c1-45)"
done; done
