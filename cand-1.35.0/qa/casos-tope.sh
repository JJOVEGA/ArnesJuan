. "$(dirname "$0")/qa-lib.sh"
E0='Estado: en-revisión'; EC='Estado: completado'
mk() { local n="$1" l="$2" i; local -a L=("$E0" 'Sensible a seguridad: sí' 'QA: aprobado' 'Seguridad: aprobado' 'Rigor: critico'); for ((i=0;i<n;i++)); do L+=("$l"); done; doc "${L[@]}"; }
t() { local id="$1" h="$2" j t0 t1; printf '%s' "$DOC" > "$F"; j="$(jwrite "${DOC/"$E0"/"$EC"}")"; t0=$EPOCHREALTIME; juzga "$h" "$j"; t1=$EPOCHREALTIME
  echo "$id $(basename $(dirname $h))/$(basename $h) dec=$DEC rc=$RC bytes_motivo=${#MOT} t=$(awk -v a=$t0 -v b=$t1 'BEGIN{printf "%.2f", b-a}')s err=$(head -c 120 $S/stderr.last | tr '\n' ' ') | ${MOT: -160}"; }
mk 3000 'Hallazgos abiertos: (ninguno)'; t CAA12-3000-canonicas "$CAND"; t CAA12-3000-canonicas "$BASE"
mk 3000 'QA: aprobado'; t QA-3000-canonicas "$CAND"; t QA-3000-canonicas "$BASE"
mk 400 'qa: aprobado'; t qa-400-variantes "$CAND"; t qa-400-variantes "$BASE"
mk 21 'qa: aprobado'; t qa-21-variantes "$CAND"
mk 19 'qa: aprobado'; t qa-19-variantes "$CAND"
mk 3000 'Hallazgos abiertos: (ninguno)'; DOC="${DOC/Rigor: critico/Rigor: critico$'\n'hallazgos abiertos: x}"; t CAA12-3000+variante "$CAND"
