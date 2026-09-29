# QA-023-02 (lado del HOOK; el de la herramienta no se ejecuta aqui): old_string no literal -> via de fragmentos.
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
BS=$(printf '\\'); S0='Estado: en-revisión'; C='Estado: completado'
doc "$S0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: SEC-1 (contrato)' 'Rigor: critico'
caso "Q0 control: old literal 'en-revisión' -> 'completado'" E 'en-revisión' 'completado'
caso "Q1 old 'en-revisi\\u00f3n' (literal \\u) -> 'completado'" E "en-revisi${BS}u00f3n" 'completado'
caso "Q2 idem por MultiEdit" M "en-revisi${BS}u00f3n" 'completado'
caso "Q3 old con la linea entera escapada -> 'Estado: completado'" E "Estado: en-revisi${BS}u00f3n" "$C"
doc "$S0" $'Sensible a seguridad\xc2\xa0: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: (ninguno)' 'Rigor: ligero'
caso "Q4 fila critica SEC-047 (NBSP), old literal" E "$S0" "$C"
caso "Q5 fila critica SEC-047, old escapado + linea entera (B6)" E "Estado: en-revisi${BS}u00f3n" "$C"
echo "## cola con una entrada pendiente"
printf '## Pendientes\n\n### [x] (coordinadora) — algo\n\n## Resueltas\n' > $P/PENDING_APPROVAL.md
doc "$S0" 'Sensible a seguridad: sí' 'QA: aprobado' 'Seguridad: aprobado' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico'
caso "Q6 control con cola: old literal" E 'en-revisión' 'completado'
caso "Q7 con cola: old escapado" E "en-revisi${BS}u00f3n" 'completado'
rm -f $P/PENDING_APPROVAL.md
