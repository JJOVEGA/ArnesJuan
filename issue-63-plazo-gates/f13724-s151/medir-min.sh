. "$1"; shift
for d in "$@"; do m=''; for i in 1 2 3 4 5 6 7; do t=${EPOCHREALTIME/./}; arnes_hash_arbol "$d" || echo ERR; t=$(( ${EPOCHREALTIME/./} - t )); [ -n "$m" ] && [ "$m" -le "$t" ] || m=$t; done; printf '%s %s ms %s\n' "${d##*/}" $((m/1000)) "$ARNES_HASH"; done
