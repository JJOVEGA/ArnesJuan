#!/usr/bin/env bash
# formas.sh <hooks> <proyecto> — CA-05: cada forma de escribir el registro, por el agente de código, a nivel de hook.
set -u
H="$1"; P="$2"; R=.arnes/gates-veredicto.json
j() { jq -cn --arg c "$P" --arg cmd "$1" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,agent_id:"a1",agent_type:"desarrollador",tool_input:{command:$cmd}}'; }
e() { jq -cn --arg c "$P" --arg t "$1" --arg fp "$P/$R" '{hook_event_name:"PreToolUse",tool_name:$t,cwd:$c,agent_id:"a1",agent_type:"desarrollador",tool_input:({file_path:$fp} + (if $t=="Write" then {content:"{}"} elif $t=="Edit" then {old_string:"a",new_string:"b"} else {edits:[{old_string:"a",new_string:"b"}]} end))}'; }
uno() { local o; o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" bash "$H/guard.sh" <<< "$2" 2>/dev/null)"
  case "$o" in *'"deny"'*) printf 'deny   %s\n' "$1" ;; '') printf 'allow  %s\n' "$1" ;; *) printf 'otra   %s\n' "$1" ;; esac; }
for t in Edit Write MultiEdit; do uno "$t" "$(e "$t")"; done
for c in "echo '{}' > $R" "printf x >> $R" "echo x | tee $R" "cp src/a.txt $R" "mv src/a.txt $R" "sed -i s/a/b/ $R" "truncate -s0 $R" "install src/a.txt $R" "dd if=src/a.txt of=$R" \
         "cat $R" "rm $R" "rm -f $R" "mv $R /tmp/x"; do
  uno "Bash: $c" "$(j "$c")"
done
