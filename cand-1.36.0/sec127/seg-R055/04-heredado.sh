#!/usr/bin/env bash
# R-055, sonda D: el paso 5 no empeora QA-007-07 ni SEC-129 (estado heredado del entorno).
# Coordinadora: Write a src/a.ts y Bash `printf x > src/a.ts`; entrada legible y entrada cerrada;
# 413c6bd frente a 78a2f33 (y v1.35.0 como referencia). Solo compara: no repara ni decide destino.
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r055
declare -A H=([v135]=/home/juan/dev/ArnesJuan-v1.35.0-base/hooks [413c]=$S/413c6bd/hooks [78a2]=$S/78a2f33/hooks)
P=$S/proy
JW="$(jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:"src/a.ts",content:"x"}}')"
JB="$(jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"printf x > src/a.ts"}}')"
dec() { case "$1" in *'"permissionDecision":"deny"'*) printf 'deny';; '') printf nada;; *) printf 'otra';; esac; }
corre() { # <arbol> <json|-> <var...>
  local a=$1 j=$2 out; shift 2
  if [ "$j" = - ]; then
    out="$(cd "$P"; unset LC_ALL POSIXLY_CORRECT ARNES_INPUT; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P"; for v in "$@"; do export "$v"; done; bash "${H[$a]}/guard.sh" <&- 2>/dev/null)"
  else
    out="$(cd "$P"; unset LC_ALL POSIXLY_CORRECT ARNES_INPUT; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P"; for v in "$@"; do export "$v"; done; printf '%s' "$j" | bash "${H[$a]}/guard.sh" 2>/dev/null)"
  fi
  dec "$out"
}
for env in "" ARNES_INPUT_LISTO=1 ARNES_MANIFEST_LISTO=1 "ARNES_INPUT=$JW" POSIXLY_CORRECT=1 SHELLOPTS=posix; do
  et="${env:0:28}"; [ -n "$env" ] || et='(ninguna)'
  for a in v135 413c 78a2; do
    printf '%-28s %-5s Write-legible=%-5s Bash-legible=%-5s cerrada=%-5s\n' "$et" $a \
      "$(corre $a "$JW" ${env:+"$env"})" "$(corre $a "$JB" ${env:+"$env"})" "$(corre $a - ${env:+"$env"})"
  done
done
