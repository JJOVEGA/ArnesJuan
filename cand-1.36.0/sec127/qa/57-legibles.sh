#!/usr/bin/env bash
# Entradas legibles normales que no deben pasar a deny: escritor lento por trozos (tubería bloqueante), entrada grande,
# salto final, CRLF final, y la sesión normal de cada herramienta. Candidato frente a v1.35.0.
source /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127/qa/sonda-qa.sh; prep_proy
JD="$(jq -cn --arg c "$PQ" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:"docs/x.md",content:"hola"}}')"
{ printf 'echo '; head -c 100000 /dev/zero | tr '\0' a; printf ' > docs/x.md'; } > "$S/kgrande.txt"
JB="$(jq -cn --arg c "$PQ" --rawfile k "$S/kgrande.txt" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}}')"; echo "entrada grande: ${#JB} bytes"
JE="$(jq -cn --arg c "$PQ" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:"requirements/REQ-900.md",old_string:"a",new_string:"b"}}')"
JG="$(jq -cn --arg c "$PQ" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"git status"}}')"
lento() { local s=$1; printf '%s' "${s:0:20}"; sleep 0.2; printf '%s' "${s:20:20}"; sleep 0.2; printf '%s' "${s:40}"; }
for a in cand v135; do for sc in guard.sh guard-codigo.sh guard-completado.sh guard-git.sh; do
  o1="$(cd $PQ; export CLAUDE_PROJECT_DIR=$PQ LANG=C.UTF-8; lento "$JD" | bash ${H[$a]}/$sc 2>&1)"
  o2="$(cd $PQ; export CLAUDE_PROJECT_DIR=$PQ LANG=C.UTF-8; printf '%s\n' "$JD" | bash ${H[$a]}/$sc 2>&1)"
  o3="$(cd $PQ; export CLAUDE_PROJECT_DIR=$PQ LANG=C.UTF-8; printf '%s\r\n' "$JD" | bash ${H[$a]}/$sc 2>&1)"
  o4="$(cd $PQ; export CLAUDE_PROJECT_DIR=$PQ LANG=C.UTF-8; printf '%s' "$JB" | bash ${H[$a]}/$sc 2>&1 | head -c 300)"
  o5="$(cd $PQ; export CLAUDE_PROJECT_DIR=$PQ LANG=C.UTF-8; printf '%s' "$JE" | bash ${H[$a]}/$sc 2>&1)"
  o6="$(cd $PQ; export CLAUDE_PROJECT_DIR=$PQ LANG=C.UTF-8; printf '%s' "$JG" | bash ${H[$a]}/$sc 2>&1)"
  printf '%-5s %-20s lento=%s | salto=%s | crlf=%s | grande=%s | edit-req=%s | git-status=%s\n' $a $sc "$(dec "$o1")" "$(dec "$o2")" "$(dec "$o3")" "$(dec "$o4"|cut -c1-50)" "$(dec "$o5")" "$(dec "$o6")"
done; done
