. "$(dirname "$0")/qa-lib.sh"
printf '## Pendientes\n\n### [2026-09-29] (qa) decision pendiente de prueba\n- Espera: propietario.\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
doc 'Estado: en-revisión' 'Sensible a seguridad: sí' 'QA: aprobado' 'Seguridad: aprobado' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico'; D0="$DOC"
BS=$(printf '\\'); ESC="en-revisi${BS}u00f3n"
for h in "$CAND" "$BASE" "$NHK"; do printf '%s' "$D0" > "$F"; juzga "$h" "$(jedit 'en-revisión' 'completado')"; a=$DEC; m=${MOT:0:90}; printf '%s' "$D0" > "$F"; juzga "$h" "$(jedit "$ESC" 'completado')"; echo "${h#$S/qa/}: literal(control)=$a [$m] | escape=$DEC"; done
