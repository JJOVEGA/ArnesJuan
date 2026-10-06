#!/usr/bin/env bash
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
P=$S/proj
NEW=/home/juan/dev/ArnesJuan-v1.36; OLD=$S/old; V=/home/juan/dev/ArnesJuan-v1.35.0-base
res(){ local o="$1" rc="$2"
  case "$o" in *'"deny"'*) echo "deny rc=$rc";; '') echo "SIN-DECISION rc=$rc";; *) echo "OTRO rc=$rc :: ${o:0:120}" | tr '\n' ' '; echo;; esac; }
for t in "$V" "$OLD" "$NEW"; do for h in guard.sh guard-git.sh guard-codigo.sh guard-completado.sh stop.sh; do
  printf '%-24s %-20s ' "$(basename "$t")" "$h"
  o="$(CLAUDE_PROJECT_DIR=$P bash "$t/hooks/$h" <&- 2>&1)"; rc=$?; printf 'cerrada: '; res "$o" "$rc" | tr -d '\n'
  o="$(CLAUDE_PROJECT_DIR=$P bash "$t/hooks/$h" < "$P/src" 2>&1)"; rc=$?; printf ' | dir: '; res "$o" "$rc" | tr -d '\n'
  o="$(CLAUDE_PROJECT_DIR=$P bash "$t/hooks/$h" < /dev/null 2>&1)"; rc=$?; printf ' | null: '; res "$o" "$rc"
done; done
