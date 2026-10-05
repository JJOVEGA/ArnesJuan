#!/usr/bin/env bash
# Ejecuta cada entrada de entradas/ por guard.sh de tres árboles y por cada guardián del candidato.
# Columnas: entrada | v1.35.0 | 82ceb63 | candidato (guard.sh) | git | codigo | completado (candidato) | motivo del candidato (60 car.)
# Decisión: deny | nada (sin salida: el host permite) | otro:<...> ; rc distinto de 0 se anota.
set -u
Q=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120/qa; P=$Q/proyecto; D=$Q/entradas
declare -A H=([v135]=/home/juan/dev/ArnesJuan-v1.35.0-base/hooks [h82]=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/t82/hooks [cand]=/home/juan/dev/ArnesJuan-v1.36/hooks)
dec() { # <script> <entrada> [env...]
  local out rc; out="$(env "${@:3}" bash "$1" < "$2" 2>/dev/null)"; rc=$?
  local d; if [ -z "$out" ]; then d=nada; elif printf '%s' "$out" | jq -e '.hookSpecificOutput.permissionDecision=="deny"' >/dev/null 2>&1; then d=deny; else d="otro"; fi
  [ $rc = 0 ] || d="$d(rc$rc)"; MOT="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // .systemMessage // empty' 2>/dev/null | cut -c1-70)"; DEC="$d"; }
for f in $(ls $D/*.json | sort); do n=${f##*/}; n=${n%.json}
  dec ${H[v135]}/guard.sh $f CLAUDE_PROJECT_DIR=$P; a=$DEC; dec ${H[h82]}/guard.sh $f CLAUDE_PROJECT_DIR=$P; b=$DEC
  dec ${H[cand]}/guard.sh $f CLAUDE_PROJECT_DIR=$P; c=$DEC; m="$MOT"
  dec ${H[cand]}/guard-git.sh $f CLAUDE_PROJECT_DIR=$P; g=$DEC; dec ${H[cand]}/guard-codigo.sh $f CLAUDE_PROJECT_DIR=$P; k=$DEC; dec ${H[cand]}/guard-completado.sh $f CLAUDE_PROJECT_DIR=$P; x=$DEC
  printf '%-48s %-6s %-6s %-6s | %-6s %-6s %-6s | %s\n' "$n" "$a" "$b" "$c" "$g" "$k" "$x" "$m"
done
