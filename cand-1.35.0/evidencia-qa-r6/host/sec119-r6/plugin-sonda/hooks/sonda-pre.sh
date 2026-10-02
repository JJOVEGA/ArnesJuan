#!/usr/bin/env bash
# Registra la entrada EXACTA que recibe el hook, se la pasa SIN CAMBIOS al guard.sh real del candidato
# y devuelve al host su salida estandar y su codigo de salida tal cual. No decide nada por su cuenta.
G=/home/juan/dev/ArnesJuan-v1.35/hooks/guard.sh
LOG="${CLAUDE_PROJECT_DIR:?}/../logs"; mkdir -p "$LOG"; n=$(date +%s%N)
in="$(cat)"; printf '%s' "$in" > "$LOG/pre-$n-in.json"
out="$(printf '%s' "$in" | bash "$G" 2>"$LOG/pre-$n-err.txt")"; rc=$?
printf '%s' "$out" > "$LOG/pre-$n-out.json"; printf '%s\n' "$rc" > "$LOG/pre-$n-rc.txt"
printf '%s' "$out"; exit "$rc"
