#!/usr/bin/env bash
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
P=$S/proj
NEW=/home/juan/dev/ArnesJuan-v1.36; OLD=$S/old; V=/home/juan/dev/ArnesJuan-v1.35.0-base
ln -sfn src/a.ts "$P/5"
run(){ # tree hook input
  local o rc
  o="$(printf '%s' "$3" | CLAUDE_PROJECT_DIR=$P bash "$1/hooks/$2" 2>&1)"; rc=$?
  case "$o" in
    *'"deny"'*) echo "deny rc=$rc :: $(printf '%s' "$o" | jq -r .hookSpecificOutput.permissionDecisionReason 2>/dev/null | head -c 110)";;
    '') echo "SIN-DECISION rc=$rc";;
    *) echo "OTRO rc=$rc :: ${o:0:150}";;
  esac
}
big=$(head -c 300000 /dev/zero | tr '\0' 'a')
inputs=(
 '{"tool_name":"Edit","agent_id":"x","agent_type":"desarrollador","cwd":"'$P'","tool_input":{"file_path":5,"old_string":"a","new_string":"b"}}'
 '{"tool_name":"Bash","agent_id":"x","agent_type":"desarrollador","cwd":"'$P'","tool_input":{"command":["cat <<x > src/a.ts"]}}'
 '{"tool_name":"Bash","agent_id":"x","agent_type":"desarrollador","cwd":"'$P'","tool_input":{"command":["'$big' > src/a.ts <<x"]}}'
)
for inp in "${inputs[@]}"; do
  echo "== ${inp:0:140}"
  for t in "$V" "$OLD" "$NEW"; do for h in guard-codigo.sh guard-git.sh guard-completado.sh guard.sh; do
    printf '%-26s %-20s ' "$(basename "$t")" "$h"; run "$t" "$h" "$inp"
  done; done
done
