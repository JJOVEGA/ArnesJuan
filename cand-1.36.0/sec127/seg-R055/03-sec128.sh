#!/usr/bin/env bash
# R-055, sonda C: SEC-128 a nivel de hook, independiente de la de QA (qa/50- y qa/59-).
# Agente de codigo (`desarrollador` y `arnes-juan:desarrollador`), coordinadora y otro subagente;
# `file_path` no textual en varias formas, con y sin un enlace en la raiz cuyo nombre es su texto;
# Edit, Write y MultiEdit; guard-codigo.sh solo y guard.sh; v1.35.0, 413c6bd y 78a2f33.
# Controles: el agente de codigo con `file_path` texto en src/ (allow) y con `command` no textual en Bash
# (guard-codigo lo deja pasar como en 413c6bd).
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r055
declare -A H=([v135]=/home/juan/dev/ArnesJuan-v1.35.0-base/hooks [413c]=$S/413c6bd/hooks [78a2]=$S/78a2f33/hooks)
P=$S/proy
ln -sfn src/a.ts "$P/5"; ln -sfn src/a.ts "$P/true"
dec() { case "$1" in *'"permissionDecision":"deny"'*) printf 'deny<%s>' "$(jq -r '.hookSpecificOutput.permissionDecisionReason' <<<"$1" 2>/dev/null | cut -c1-48)";;
        '') printf nada;; *) printf 'otra<%s>' "${1:0:48}";; esac; }
pr() { local out; out="$(cd "$P"; unset LC_ALL POSIXLY_CORRECT ARNES_INPUT; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P"; printf '%s' "$3" | bash "${H[$1]}/$2" 2>/dev/null)"; printf '%s rc=%s' "$(dec "$out")" "$?"; }
mk() { # <tool> <fp json> <agente: dev|devp|coord|qa>
  local ti
  case "$1" in
    Edit) ti="{\"file_path\":$2,\"old_string\":\"a\",\"new_string\":\"b\"}" ;;
    Write) ti="{\"file_path\":$2,\"content\":\"x\"}" ;;
    MultiEdit) ti="{\"file_path\":$2,\"edits\":[{\"old_string\":\"a\",\"new_string\":\"b\"}]}" ;;
    Bash) ti="{\"command\":$2}" ;;
  esac
  case "$3" in
    dev) jq -cn --arg c "$P" --argjson ti "$ti" --arg t "$1" '{hook_event_name:"PreToolUse",tool_name:$t,cwd:$c,agent_id:"a1",agent_type:"desarrollador",tool_input:$ti}' ;;
    devp) jq -cn --arg c "$P" --argjson ti "$ti" --arg t "$1" '{hook_event_name:"PreToolUse",tool_name:$t,cwd:$c,agent_id:"a1",agent_type:"arnes-juan:desarrollador",tool_input:$ti}' ;;
    qa) jq -cn --arg c "$P" --argjson ti "$ti" --arg t "$1" '{hook_event_name:"PreToolUse",tool_name:$t,cwd:$c,agent_id:"a2",agent_type:"qa-tester",tool_input:$ti}' ;;
    coord) jq -cn --arg c "$P" --argjson ti "$ti" --arg t "$1" '{hook_event_name:"PreToolUse",tool_name:$t,cwd:$c,tool_input:$ti}' ;;
  esac
}
for fp in 5 true '{"a":1}' '["src/a.ts"]' 5.0 -1 '"src/a.ts"'; do
  for ag in dev devp coord qa; do
    for t in Edit Write MultiEdit; do
      j="$(mk $t "$fp" $ag)"
      for a in v135 413c 78a2; do
        printf 'fp=%-12s %-5s %-9s %-4s guard-codigo=%-60s guard=%s\n' "$fp" $ag $t $a "$(pr $a guard-codigo.sh "$j")" "$(pr $a guard.sh "$j")"
      done
    done
  done
done
echo "== control: Bash del agente de codigo con command no textual"
for c in 5 '["ls"]'; do for a in v135 413c 78a2; do j="$(mk Bash "$c" dev)"
  printf 'cmd=%-8s dev  Bash %-4s guard-codigo=%-60s guard=%s\n' "$c" $a "$(pr $a guard-codigo.sh "$j")" "$(pr $a guard.sh "$j")"; done; done
