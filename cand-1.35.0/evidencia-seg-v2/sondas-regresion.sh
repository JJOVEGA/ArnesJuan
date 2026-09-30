# No regresion: lo que acredito R-045 (REQ-023 CA-01..CA-12) y REQ-031, candidata frente a 31d2a21 (r045) y 713ac68.
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
crlf() { DOC="${DOC//$'\n'/$'\r\n'}"; }
for v in jedit jwrite; do
  if [ $v = jwrite ]; then W() { jwrite "${DOC/"$S0"/"$C"}"; }; else W() { jedit "$S0" "$C"; }; fi
  doc "$S0" "$T" "$Q" "$G" "$H" "$R0";                                   caso "[$v] A1 F0 cierra" W
  doc "$S0" "$T" 'qa: pendiente' "$G" "$H" "$R0";                         caso "[$v] R10 qa: pendiente" W
  doc "$S0" $'\xef\xbb\xbfSensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' "$H" 'Rigor: ligero'; caso "[$v] R8 BOM Sensible + ligero" W
  doc "$S0" "$T" "$Q" "$G" $'Hallazgos\xc2\xa0abiertos: SEC-1 (contrato)' "$R0"; caso "[$v] R5 NBSP en Hallazgos" W
  doc "$S0" "$T" "$Q" "$Q" "$G" "$H" "$R0";                               caso "[$v] R16 QA repetida mismo valor" W
  doc "$S0" "$T" "$Q" "$G" "$H" "$R0" 'Estado: completado';               caso "[$v] R17 Estado repetida terminal" W
  doc "$S0" "$T" "$Q" "$G" "$H" "$R0" '<!-- qa: pendiente -->';           caso "[$v] A5 variante en comentario" W
  doc "$S0" "$T" "$Q" "$G" 'Hallazgos abiertos: SEC-1 (contrato)' 'Hallazgos abiertos: (ninguno)' "$R0"; caso "[$v] U1 CA-A12 unica ambiguedad" W
  doc "$S0" "$T" "$Q" "$G" 'Hallazgos abiertos: SEC-1 (contrato)' "$R0";  caso "[$v] U2 contrato canonico" W
  doc "$S0" "$T" "$Q" "$G" 'Hallazgos abiertos: SEC-A (instrumento) · SEC-B (contrato)' "$R0"; caso "[$v] REQ-031 separador ·" W
  doc "$S0" "$T" "$Q" "$G" 'Hallazgos abiertos: QA-6 (instrumento) — REQ-7' "$R0"; caso "[$v] REQ-031 nota tras parentesis" W
  doc "$S0" $'\xef\xbb\xbfSensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' "$H" 'Rigor: ligero'; crlf; caso "[$v] U3 R8 en CRLF" W
  doc "$S0" "$T" "$Q" "$G" "$H" "$R0" $'Nota\rx: y';                      caso "[$v] CR interior" W
done
Z=$(printf '\xe2\x80\x8b%.0s' $(seq 85)); doc "$S0" "$T" "$Q" "$G" "${Z}Hallazgos abiertos: SEC-1 (contrato)" "$R0"; caso "F3 clave de 273 B (fuera (e), limitacion)" jedit "$S0" "$C"
doc 'Estado: completado' "$T" 'QA: pendiente' "$G" "$H" "$R0" 'ESTADO: completado'; caso "A4 gobernante terminal + variante (reabrir no se bloquea)" jedit 'Estado: completado' 'Estado: en-progreso'
