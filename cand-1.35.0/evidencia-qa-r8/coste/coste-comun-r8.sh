#!/usr/bin/env bash
# P3 del registro previo (informativo): camino comun, minimo de 5 corridas por caso y arbol.
. "$(dirname "$0")/lib8.sh"
proyecto8 "$EV8/proj-comun"
declare -A J=(
  [bash-ls]="$(j8 Bash "$P" - 'command=ls -la')"
  [bash-devnull]="$(j8 Bash "$P" - 'command=echo x > /dev/null')"
  [bash-stderr]="$(j8 Bash "$P" - 'command=echo x > /dev/stderr')"
  [write-src]="$(j8 Write "$P" - "file_path=$P/src/a.ts" content=x)"
)
echo "== P3 camino comun $(date -Iseconds); loadavg $(cut -d' ' -f1-3 /proc/loadavg) =="
for c in bash-ls bash-devnull bash-stderr write-src; do
  for k in cand 3bc7d3c; do
    min=999999999
    for r in 1 2 3 4 5; do
      t0=${EPOCHREALTIME/./}; printf '%s' "${J[$c]}" | CLAUDE_PROJECT_DIR="$P" bash "${ARB[$k]}/guard.sh" >/dev/null 2>&1; t1=${EPOCHREALTIME/./}
      d=$((t1 - t0)); [ "$d" -lt "$min" ] && min=$d
    done
    printf '%-14s %-8s min=%6d us\n' "$c" "$k" "$min"
  done
done
rm -rf "$EV8/proj-comun"
