. "$(dirname "$0")/qa-lib.sh"
V134=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/qa/v134/hooks
doc 'Estado: en-revisión' 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: SEC-1 (contrato)' 'Rigor: critico'; D0="$DOC"
BS=$(printf '\\'); ESC="en-revisi${BS}u00f3n"
for h in "$V134" "$CAND"; do
  printf '%s' "$D0" > "$F"; juzga "$h" "$(jedit 'en-revisión' 'completado')"; a=$DEC
  printf '%s' "$D0" > "$F"; juzga "$h" "$(jedit "$ESC" 'completado')"; b=$DEC
  printf '%s' "$D0" > "$F"; juzga "$h" "$(jmulti "$ESC" 'completado')"; c=$DEC
  echo "${h#/tmp/claude-1000/*/scratchpad/qa/}: control literal=$a · escape Edit=$b · escape MultiEdit=$c"
done
printf '## Pendientes\n\n### [2026-09-29] (qa) prueba\n- Espera: propietario.\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
doc 'Estado: en-revisión' 'Sensible a seguridad: sí' 'QA: aprobado' 'Seguridad: aprobado' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico'; D0="$DOC"
for h in "$V134" "$CAND"; do printf '%s' "$D0" > "$F"; juzga "$h" "$(jedit 'en-revisión' 'completado')"; a=$DEC; printf '%s' "$D0" > "$F"; juzga "$h" "$(jedit "$ESC" 'completado')"; echo "${h#/tmp/claude-1000/*/scratchpad/qa/} con cola pendiente: literal=$a · escape=$DEC"; done
