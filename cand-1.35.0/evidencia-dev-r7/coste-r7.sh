#!/usr/bin/env bash
# coste-r7.sh — informativo, NO un criterio: mínimo de 5 corridas por caso, cd6afa6 frente a la candidata.
set -u
. "$(dirname "$0")/lib-r7.sh"
nuevo_proyecto
big="$(head -c 131000 /dev/zero | tr '\0' 'a')"
declare -A J=(
  [write-src]="$(j Write "$P" - "file_path=$P/src/a.ts" content=x)"
  [bash-ls]="$(j Bash "$P" - 'command=ls -la')"
  [bash-131k]="$(j Bash "$P" - "command=echo $big > docs/n.md")"
  [fp-largo-cr]="$(j Write "$P" - "file_path=$P/docs/${big:0:4000}$CR" content=x)"
)
for c in write-src bash-ls bash-131k fp-largo-cr; do
  for k in cd6afa6 cand; do
    min=999999999
    for r in 1 2 3 4 5; do
      t0=${EPOCHREALTIME/./}; printf '%s' "${J[$c]}" | CLAUDE_PROJECT_DIR="$P" bash "${ARB[$k]}/guard.sh" >/dev/null 2>&1; t1=${EPOCHREALTIME/./}
      d=$((t1 - t0)); [ "$d" -lt "$min" ] && min=$d
    done
    printf '%-12s %-8s min=%6d us\n' "$c" "$k" "$min"
  done
done
