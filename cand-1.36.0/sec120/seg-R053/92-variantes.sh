#!/usr/bin/env bash
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
P=$S/proj
NEW=/home/juan/dev/ArnesJuan-v1.36; OLD=$S/old; V=/home/juan/dev/ArnesJuan-v1.35.0-base
ln -sfn src/a.ts "$P/5"
res(){ local o="$1" rc="$2"
  case "$o" in *'"deny"'*) echo "deny rc=$rc";; '') echo "SIN-DECISION rc=$rc";; *) echo "OTRO rc=$rc";; esac; }
D='"agent_id":"x","agent_type":"desarrollador","cwd":"'$P'"'
inputs=(
 "W5   {\"tool_name\":\"Write\",$D,\"tool_input\":{\"file_path\":5,\"content\":\"x\"}}"
 "M5   {\"tool_name\":\"MultiEdit\",$D,\"tool_input\":{\"file_path\":5,\"edits\":[{\"old_string\":\"a\",\"new_string\":\"b\"}]}}"
 "E5c  {\"tool_name\":\"Edit\",\"cwd\":\"$P\",\"tool_input\":{\"file_path\":5,\"old_string\":\"a\",\"new_string\":\"b\"}}"
 "Es   {\"tool_name\":\"Edit\",$D,\"tool_input\":{\"file_path\":\"5\",\"old_string\":\"a\",\"new_string\":\"b\"}}"
 "TN5  {\"tool_name\":5,\"cwd\":\"$P\",\"tool_input\":{\"command\":\"echo x > src/a.ts\"}}"
 "TNf  {\"tool_name\":false,\"cwd\":\"$P\",\"tool_input\":{\"command\":\"git reset --hard\"}}"
)
for e in "${inputs[@]}"; do id="${e%% *}"; inp="${e#* }"; inp="${inp# *}"; inp="${inp# *}"
  for t in "$V" "$OLD" "$NEW"; do printf '%-5s %-24s' "$id" "$(basename "$t")"
    for h in guard-codigo.sh guard-completado.sh guard.sh; do
      o="$(printf '%s' "$inp" | CLAUDE_PROJECT_DIR=$P bash "$t/hooks/$h" 2>/dev/null)"; rc=$?; printf ' %s=%s' "${h%.sh}" "$(res "$o" "$rc")"
    done; echo
  done
done
