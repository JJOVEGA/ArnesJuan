# Instrumento del auditor (R-045): proyecto temporal + JSON PreToolUse contra el entrypoint real guard.sh.
E=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg
CAND=/home/juan/dev/ArnesJuan-v1.35/hooks
BASE=$E/base713/hooks
P=$E/proy; F=$P/requirements/REQ-900.md
mkdir -p $P/.arnes $P/requirements
cat > $P/.arnes/config.json <<'J'
{"agentes":{"agente_codigo":"desarrollador","conocidos":["desarrollador","qa-tester","auditor-seguridad","analista-requerimientos"]},
 "codigo_app":{"globs":["src/*"]},"quality_gates":[],"estados":{"completado":"completado","todos":["borrador","pendiente","en-progreso","en-revisión","completado","bloqueado"]},
 "estado_derivado":{"activo":false},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md","git":{"activo":false}}
J
rm -f $P/PENDING_APPROVAL.md
# doc <lineas de cabecera...> -> DOC (con cuerpo)
doc() { local l; DOC='# REQ-900 — sonda'$'\n'; for l in "$@"; do DOC+="$l"$'\n'; done; DOC+=$'\n## Criterios\n\n- CA-01 x\n'; }
jedit()  { jq -cn --arg f "$F" --arg o "$1" --arg n "$2" --arg p "$P" '{tool_name:"Edit",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,old_string:$o,new_string:$n}}'; }
jmulti() { jq -cn --arg f "$F" --arg o "$1" --arg n "$2" --arg p "$P" '{tool_name:"MultiEdit",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,edits:[{old_string:$o,new_string:$n}]}}'; }
jwrite() { jq -cn --arg f "$F" --arg c "$1" --arg p "$P" '{tool_name:"Write",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,content:$c}}'; }
# juzga <dir hooks> <json en archivo o cadena> -> DEC MOT RC T ERR
juzga() { local h="$1" j="$2" out t0 t1
  t0=$(date +%s.%N)
  out=$(CLAUDE_PROJECT_DIR=$P bash "$h/guard.sh" <<< "$j" 2>$E/.err); RC=$?
  t1=$(date +%s.%N); TT=$(awk -v a=$t0 -v b=$t1 'BEGIN{printf "%.2f", b-a}')
  ERR=$(head -c 200 $E/.err | tr '\n' ' ')
  if [ -z "$out" ]; then DEC=allow; MOT=''; else
    DEC=$(jq -r '.hookSpecificOutput.permissionDecision // "otro"' <<< "$out" 2>/dev/null); MOT=$(jq -r '.hookSpecificOutput.permissionDecisionReason // .systemMessage // ""' <<< "$out" 2>/dev/null)
    [ "$DEC" = otro ] && DEC=allow+aviso; fi; }
# caso <id> <via E|M|W> <old> <new> : usa DOC en disco; imprime cand y base
caso() { local id="$1" via="$2" o="$3" n="$4" j dc db mc
  printf '%s' "$DOC" > "$F"
  case "$via" in E) j="$(jedit "$o" "$n")";; M) j="$(jmulti "$o" "$n")";; W) j="$(jwrite "${DOC/"$o"/"$n"}")";; esac
  juzga "$CAND" "$j"; dc=$DEC; mc="${MOT:0:110}"
  printf '%s' "$DOC" > "$F"; juzga "$BASE" "$j"; db=$DEC
  printf '%-52s %s cand=%-6s base=%-6s | %s\n' "$id" "$via" "$dc" "$db" "$mc"; }
