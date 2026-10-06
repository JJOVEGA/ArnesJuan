#!/usr/bin/env bash
# R-055, sonda B a nivel de hook: ¿se alcanza desde el hook el fallo de la redireccion del grupo de
# `arnes_estado_ausente`? Barrido del limite de descriptores (ulimit -n, heredado del proceso padre) con
# el cierre por Bash de la coordinadora: `sed -i 's/en-revisión/completado/' requirements/REQ-900.md`.
# Por guard.sh y por guard-completado.sh; v1.35.0, 413c6bd y 78a2f33. Con CLAUDE_PROJECT_DIR, cwd en el
# proyecto, LANG=C.UTF-8, sin LC_ALL. Se anota la decision y la primera linea de stderr.
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r055
declare -A H=([v135]=/home/juan/dev/ArnesJuan-v1.35.0-base/hooks [413c]=$S/413c6bd/hooks [78a2]=$S/78a2f33/hooks)
P=$S/proy
J="$(jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"sed -i '"'"'s/en-revisión/completado/'"'"' requirements/REQ-900.md"}}')"
dec() { case "$1" in *'"permissionDecision":"deny"'*) printf 'deny<%s>' "$(jq -r '.hookSpecificOutput.permissionDecisionReason' <<<"$1" 2>/dev/null | cut -c1-60)";;
        '') printf nada;; *) printf 'otra<%s>' "${1:0:60}";; esac; }
for n in sin 3 4 5 6 7 8 9 10 11 12 13 14 16 20 32; do
  for a in v135 413c 78a2; do
    for s in guard.sh guard-completado.sh; do
      out="$(cd "$P"; unset LC_ALL POSIXLY_CORRECT ARNES_INPUT; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P"
             printf '%s' "$J" | bash -c '[ "$1" = sin ] || ulimit -n "$1"; exec bash "$2"' _ "$n" "${H[$a]}/$s" 2>"$S/err-b.txt")"; rc=$?
      printf 'n=%-4s %-5s %-20s %s rc=%s err1=<%s>\n' "$n" "$a" "$s" "$(dec "$out")" "$rc" "$(head -1 "$S/err-b.txt" | sed "s#$S#<S>#g" | cut -c1-110)"
    done
  done
done
