. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
crlf() { DOC="${DOC//$'\n'/$'\r\n'}"; }
for loc in C C.UTF-8; do export LC_ALL=$loc; echo "## LC_ALL=$loc"
doc "$S0" "$T" "$Q" "$G" "$H" "$R0"; crlf;                     caso "X1 F0 en CRLF (control)" E "$S0" "$C"
doc "$S0" "$T" 'qa: pendiente' "$G" "$H" "$R0"; crlf;          caso "X2 variante en CRLF" E "$S0" "$C"
doc "$S0" "$T" $'\xef\xbb\xbfSensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' "$H" 'Rigor: ligero'; crlf; caso "X3 R8 en CRLF" W "$S0" "$C"
doc "$S0" "$T" "$Q" "$G" "$H" "$R0" '<!-- x --> qa: pendiente'; caso "X4 variante tras comentario cerrado" E "$S0" "$C"
doc "$S0" "$T" "$Q" "$G" "$H" "$R0" '<!-- qa: pendiente -->';    caso "X5 variante dentro de comentario (A5)" E "$S0" "$C"
doc "$S0" "$T" "$Q" "$G" "$H" "$R0" '<!--qa: pendiente-->';      caso "X6 comentario sin espacio (CA-11)" E "$S0" "$C"
doc "$S0" "$T" "$Q" "$G" "$H" "$R0" '<!-- abre y no cierra' 'qa: pendiente'; caso "X7 rango sin cerrar + variante" E "$S0" "$C"
doc "$S0" "$T" $'Q\rA: pendiente' "$G" "$H" "$R0";                caso "X8 CR interior en la clave" E "$S0" "$C"
L=(); for i in $(seq 30); do L+=("$(printf '\xf0\x9f\x98\x80%.0s' $(seq 20))Sensible a seguridad: sí"); done
doc "$S0" "$T" "$Q" "$G" "$H" "$R0" "${L[@]}"; caso "X9 30 variantes con 80 B escapados c/u" E "$S0" "$C"; echo "   bytes del motivo: ${#MOT}"
done
