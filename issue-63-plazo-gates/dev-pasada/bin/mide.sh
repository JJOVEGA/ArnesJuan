#!/usr/bin/env bash
# mide.sh <proj> <json> <n> <hooks-dir>... — mínimo y mediana (ms) de n corridas intercaladas de guard-completado.sh por árbol
set -u
P="$1"; J="$2"; N="$3"; shift 3
declare -A T
for ((i=0;i<N;i++)); do
  for h in "$@"; do
    t0=${EPOCHREALTIME/./}
    CLAUDE_PROJECT_DIR="$P" bash "$h/guard-completado.sh" < "$J" >/dev/null 2>&1
    T[$h]+="$(( ${EPOCHREALTIME/./} - t0 )) "
  done
done
for h in "$@"; do
  s=$(tr ' ' '\n' <<< "${T[$h]}" | grep . | sort -n)
  n=$(wc -l <<< "$s"); min=$(head -1 <<< "$s"); med=$(sed -n "$(( (n+1)/2 ))p" <<< "$s")
  printf '%-60s min=%6.1f ms  med=%6.1f ms\n' "$h" "$(bc -l <<< "$min/1000")" "$(bc -l <<< "$med/1000")"
done
