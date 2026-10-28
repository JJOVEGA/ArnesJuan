#!/usr/bin/env bash
# mide-mv.sh <proyecto> <n> <hooks>... — mínimo y mediana de guard.sh con `mv src/a.txt docs/PLAN.md` (qa-tester),
# intercalado por árbol: la rama de la sonda de REQ-033 «mv con origen protegido».
set -u
P="$1"; N="$2"; shift 2
J="$P/in-mv"; jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,agent_id:"a1",agent_type:"qa-tester",tool_input:{command:"mv src/a.txt docs/PLAN.md"}}' > "$J"
declare -A T
for ((i = 0; i < N; i++)); do for h in "$@"; do
  t0=${EPOCHREALTIME/./}; (cd "$P" && CLAUDE_PROJECT_DIR="$P" bash "$h/guard.sh" < "$J" >/dev/null 2>&1); T[$h]+="$(( ${EPOCHREALTIME/./} - t0 )) "
done; done
for h in "$@"; do s=$(tr ' ' '\n' <<< "${T[$h]}" | grep . | sort -n); n=$(wc -l <<< "$s")
  printf '%-70s min=%6d us  med=%6d us\n' "$h" "$(head -1 <<< "$s")" "$(sed -n "$(( (n + 1) / 2 ))p" <<< "$s")"; done
echo "decision candidata: $(cd "$P" && CLAUDE_PROJECT_DIR="$P" bash "$1/guard.sh" < "$J" | jq -r '.hookSpecificOutput.permissionDecision // "allow"')"
