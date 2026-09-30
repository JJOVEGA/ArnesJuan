# Instrumento del auditor (R-045-A). Variables de tiempo con nombre propio (TT) para no pisar fixtures.
E2=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2
CAND=/home/juan/dev/ArnesJuan-v1.35/hooks; BASE=$E2/base713/hooks; R045=$E2/r045/hooks
P=$E2/proy; F=$P/requirements/REQ-900.md
mkdir -p $P/.arnes $P/requirements $P/src $P/docs
cat > $P/.arnes/config.json <<'J'
{"agentes":{"agente_codigo":"desarrollador","conocidos":["desarrollador","qa-tester","auditor-seguridad","analista-requerimientos"]},
 "codigo_app":{"globs":["src/*"]},"quality_gates":[],"estados":{"completado":"completado","todos":["borrador","pendiente","en-progreso","en-revisión","completado","bloqueado"]},
 "estado_derivado":{"activo":false},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md","git":{"activo":false}}
J
rm -f $P/PENDING_APPROVAL.md
doc() { local l; DOC='# REQ-900 — sonda'$'\n'; for l in "$@"; do DOC+="$l"$'\n'; done; DOC+=$'\n## Criterios\n\n- CA-01 x\n'; }
jedit()  { jq -cn --arg f "${FP:-$F}" --arg o "$1" --arg n "$2" --arg p "$P" --arg a "${AG:-auditor-seguridad}" '{tool_name:"Edit",cwd:$p,agent_type:$a,tool_input:{file_path:$f,old_string:$o,new_string:$n,replace_all:false}}'; }
jmulti() { jq -cn --arg f "${FP:-$F}" --arg o "$1" --arg n "$2" --arg p "$P" --arg a "${AG:-auditor-seguridad}" '{tool_name:"MultiEdit",cwd:$p,agent_type:$a,tool_input:{file_path:$f,edits:[{old_string:$o,new_string:$n}]}}'; }
jmulti2() { jq -cn --arg f "${FP:-$F}" --arg o1 "$1" --arg n1 "$2" --arg o2 "$3" --arg n2 "$4" --arg p "$P" --arg a "${AG:-auditor-seguridad}" '{tool_name:"MultiEdit",cwd:$p,agent_type:$a,tool_input:{file_path:$f,edits:[{old_string:$o1,new_string:$n1},{old_string:$o2,new_string:$n2}]}}'; }
jwrite() { printf '%s' "$1" > $E2/.content; jq -cn --rawfile c $E2/.content --arg f "${FP:-$F}" --arg p "$P" --arg a "${AG:-auditor-seguridad}" '{tool_name:"Write",cwd:$p,agent_type:$a,tool_input:{file_path:$f,content:$c}}'; }
juzga() { local h="$1" j="$2" out t0 t1
  t0=$(date +%s.%N); out=$(CLAUDE_PROJECT_DIR=$P bash "$h/guard.sh" <<< "$j" 2>$E2/.err); RC=$?; t1=$(date +%s.%N)
  TT=$(awk -v a=$t0 -v b=$t1 'BEGIN{printf "%.2f", b-a}')
  if [ -z "$out" ]; then DEC=allow; MOT=''; else DEC=$(jq -r '.hookSpecificOutput.permissionDecision // "aviso"' <<< "$out"); MOT=$(jq -r '.hookSpecificOutput.permissionDecisionReason // .systemMessage // ""' <<< "$out"); fi; }
# caso <id> <json-builder...> : escribe DOC en F antes de cada puerta; imprime cand / r045 / base
caso() { local id="$1"; shift; local j dc mc dr db
  j="$("$@")"
  printf '%s' "$DOC" > "$F"; juzga "$CAND" "$j"; dc=$DEC; mc="${MOT:0:120}"
  printf '%s' "$DOC" > "$F"; juzga "$R045" "$j"; dr=$DEC
  printf '%s' "$DOC" > "$F"; juzga "$BASE" "$j"; db=$DEC
  printf '%-58s cand=%-5s r045=%-5s base=%-5s | %s\n' "$id" "$dc" "$dr" "$db" "$mc"; }
