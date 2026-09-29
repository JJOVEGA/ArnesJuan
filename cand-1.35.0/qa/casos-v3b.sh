. "$(dirname "$0")/qa-lib.sh"
V134=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/qa/v134/hooks
BS=$(printf '\\'); H='Hallazgos abiertos: (ninguno)'
t() { local id="$1" j="$2" r='' h; for h in "$CAND" "$BASE" "$NHK" "$V134"; do printf '%s' "$DOC" > "$F"; juzga "$h" "$j"; r+=" $DEC"; done; echo "$id | cand base713 N-1.33.2 v1.34.0 =$r"; }
doc 'Estado: en-revisión' 'Sensible a seguridad: sí' 'qa: pendiente' 'Seguridad: aprobado' "$H" 'Rigor: critico'
t "B1 literal (control)" "$(jedit 'Estado: en-revisión' 'Estado: completado')"
t "B2 escape + linea Estado entera" "$(jedit "Estado: en-revisi${BS}u00f3n" 'Estado: completado')"
doc 'Estado: en-revisión' 'Sensible a seguridad'$'\xc2\xa0'': sí' 'QA: pendiente' 'Seguridad: pendiente' "$H" 'Rigor: ligero'
t "B5 fila critica SEC-047, literal (control)" "$(jedit 'Estado: en-revisión' 'Estado: completado')"
t "B6 fila critica SEC-047, escape + linea Estado entera" "$(jedit "Estado: en-revisi${BS}u00f3n" 'Estado: completado')"
