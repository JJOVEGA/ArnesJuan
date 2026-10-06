#!/usr/bin/env bash
# Ayudantes de las sondas de QA del paso 5. Se hace `source`.
W=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/qa5
declare -A H=([cand]=$W/hooks [a599]=$S/a59917d/hooks [413c]=$S/413c6bd/hooks [82ce]=$S/82ceb63/hooks [v135]=$B/hooks)
PQ=$S/proy; LOCQ=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa/eq/loc
prep_proy() { rm -rf "$PQ"; cp -a /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120/proyecto "$PQ"; : > "$PQ/src/a.ts"; mkdir -p "$PQ/dirent"; }
# dec <salida> -> "deny <motivo corto>" | "nada" | "otra:<...>"
dec() { case "$1" in *'"permissionDecision":"deny"'*) printf 'deny<%s>' "$(jq -r '.hookSpecificOutput.permissionDecisionReason' <<<"$1" 2>/dev/null | cut -c1-70)";;
        '') printf nada;; *) printf 'otra<%s>' "${1:0:80}";; esac; }
# pr <arbol> <script> <json> : CLAUDE_PROJECT_DIR=$PQ, cwd $PQ, LANG=C.UTF-8
pr() { local out rc; out="$(cd "$PQ"; unset LC_ALL POSIXLY_CORRECT ARNES_INPUT; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$PQ"; printf '%s' "$3" | bash "${H[$1]}/$2" 2>/dev/null)"; rc=$?; printf '%s rc=%s' "$(dec "$out")" "$rc"; }
