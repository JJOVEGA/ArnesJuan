. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'; R0='Rigor: critico'; S0='Estado: en-revisión'
C='Estado: completado'
echo "## Controles del instrumento"
doc "$S0" "$T" "$Q" "$G" "$H" "$R0"; caso "K1 F0 cierra (verde)" E "$S0" "$C"
doc "$S0" "$T" 'QA: pendiente' "$G" "$H" "$R0"; caso "K2 QA pendiente canonica" E "$S0" "$C"
echo "## Marcadores y blancos dentro de la frontera (no en la tabla de CA-08)"
for v in E W; do
doc "$S0" "$T" $'-\tQA: pendiente' "$G" "$H" "$R0";      caso "M1 '-<TAB>QA: pendiente'" $v "$S0" "$C"
doc "$S0" "$T" '+ QA: pendiente' "$G" "$H" "$R0";        caso "M2 '+ QA: pendiente'" $v "$S0" "$C"
doc "$S0" "$T" '123) QA: pendiente' "$G" "$H" "$R0";     caso "M3 '123) QA: pendiente'" $v "$S0" "$C"
doc "$S0" "$T" '-   QA: pendiente' "$G" "$H" "$R0";      caso "M4 '-   QA' (marcador + blancos)" $v "$S0" "$C"
doc "$S0" "$T" $'Q\x7fA: pendiente' "$G" "$H" "$R0";     caso "M5 DEL dentro de QA" $v "$S0" "$C"
doc "$S0" "$T" $'\xe2\x80\x8b- QA: pendiente' "$G" "$H" "$R0"; caso "M6 ZWSP y luego '- QA'" $v "$S0" "$C"
doc "$S0" "$T" $'Q\xc2\xadA: pendiente' "$G" "$H" "$R0"; caso "M7 SHY (U+00AD) dentro de QA" $v "$S0" "$C"
doc "$S0" "$T" $'\xef\xbb\xbfQA: pendiente' "$G" "$H" "$R0"; caso "M8 BOM + QA: pendiente" $v "$S0" "$C"
doc "$S0" "$T" "$Q" "$G" "$H" $'R\xe2\x80\x8dIGOR: critico' ; caso "M9 ZWJ en RIGOR (critico, sin Sens)" $v "$S0" "$C"
doc "$S0" "$T" 'Qa: pendiente' "$G" "$H" "$R0";          caso "M10 'Qa:' " $v "$S0" "$C"
doc "$S0" "$T" $'QA\xc2\xa0: pendiente' "$G" "$H" "$R0";  caso "M11 NBSP tras QA antes de ':'" $v "$S0" "$C"
doc "$S0" "$T" $'\tQA: pendiente' "$G" "$H" "$R0";        caso "M12 TAB inicial (sangrado canonico)" $v "$S0" "$C"
doc "$S0" "$T" '**qa**: pendiente' "$G" "$H" "$R0";      caso "M13 '**qa**:' decorada y variante" $v "$S0" "$C"
doc "$S0" "$T" '`QA`: pendiente' "$Q" "$G" "$H" "$R0";   caso "M14 '\`QA\`: pendiente' + QA aprobado (repetida)" $v "$S0" "$C"
done
