. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
H='Hallazgos abiertos: (ninguno)'; S0='Estado: en-revisión'; C='Estado: completado'
crlf() { DOC="${DOC//$'\n'/$'\r\n'}"; }
for loc in C C.UTF-8; do export LC_ALL=$loc
for v in E W; do
doc "$S0" $'\xef\xbb\xbfSensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' "$H" 'Rigor: ligero'; crlf; caso "X3b[$loc] R8 (fila critica SEC-047) en CRLF" $v "$S0" "$C"
doc "$S0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' "$H" 'Rigor: ligero'; crlf; caso "X3c[$loc] gemelo sin BOM en CRLF (control)" $v "$S0" "$C"
done; done
