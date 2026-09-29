. "$(dirname "$0")/qa-lib.sh"
declare -A T C B
for d in "$@"; do
  fam="${d##*/}"; fam="${fam%%__*}"; cp "$d" "$F"
  j="$(jedit 'Estado: en-revisión' 'Estado: completado')"
  juzga "$CAND" "$j"; c=$DEC; cp "$d" "$F"; juzga "$BASE" "$j"; b=$DEC
  T[$fam]=$(( ${T[$fam]:-0} + 1 )); [ "$c" = deny ] && C[$fam]=$(( ${C[$fam]:-0} + 1 )); [ "$b" = allow ] && B[$fam]=$(( ${B[$fam]:-0} + 1 ))
  [ "$c" = deny ] || echo "CANDIDATA NO DENIEGA: ${d##*/} ($c)"
done
for f in "${!T[@]}"; do echo "$f: entradas=${T[$f]} candidata_deny=${C[$f]:-0} base_allow=${B[$f]:-0}"; done | sort
