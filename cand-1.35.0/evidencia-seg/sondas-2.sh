. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'; R0='Rigor: critico'; S0='Estado: en-revisión'
C='Estado: completado'; QP='QA: pendiente'
echo "## Intento de cierre por lineas Estado que no gobiernan (QA pendiente en todas)"
for v in E M W; do
doc "$S0" "$T" "$QP" "$G" "$H" "$R0"; caso "I1 anade 'ESTADO: completado (2026-09-29)'" $v "$R0" "$R0"$'\nESTADO: completado (2026-09-29)'
doc "$S0" "$T" "$QP" "$G" "$H" "$R0"; caso "I2 anade '- Estado: **COMPLETADO**'" $v "$R0" "$R0"$'\n- Estado: **COMPLETADO**'
doc "$T" "$QP" "$G" "$H" "$R0";       caso "I3 sin Estado exacto; anade 'estado: completado'" $v "$R0" "$R0"$'\nestado: completado'
doc "$S0" "$T" "$QP" "$G" "$H" "$R0"; caso "I4 cambia gobernante a variante 'ESTADO: completado'" $v "$S0" 'ESTADO: completado'
doc "$S0" "$T" "$QP" "$G" "$H" "$R0"; caso "I5 anade 'Estado:completado' exacta 2a (sin blanco)" $v "$R0" "$R0"$'\nEstado:completado'
doc "$S0" "$T" "$QP" "$G" "$H" "$R0"; caso "I6 anade Estado exacta 2a con TAB 'Estado:\tcompletado'" $v "$R0" "$R0"$'\nEstado:\tcompletado'
doc "$S0" "$T" "$QP" "$G" "$H" "$R0"; caso "I7 gobernante vacio 'Estado:' + 2a completado" $v "$S0" $'Estado:\nEstado: completado'
done
echo "## Locale: clave de 257 bytes (85 x U+200B + qa) y de 255 bytes (84 x U+200B + qa + 1)"
Z85=$(printf '\xe2\x80\x8b%.0s' $(seq 85)); Z84=$(printf '\xe2\x80\x8b%.0s' $(seq 84))
for loc in C C.UTF-8; do
 export LC_ALL=$loc
 doc "$S0" "$T" "${Z85}qa: pendiente" "$G" "$H" "$R0"; caso "L1[$loc] 85xZWSP+qa (257 B, fuera (e))" E "$S0" "$C"
 doc "$S0" "$T" "${Z84}qa: pendiente" "$G" "$H" "$R0"; caso "L2[$loc] 84xZWSP+qa (254 B, dentro)" E "$S0" "$C"
 doc "$S0" "$T" "${Z84}Q A: pendiente" "$G" "$H" "$R0"; caso "L3[$loc] 84xZWSP+'Q A' (255 B)" E "$S0" "$C"
 doc "$S0" "$T" "${Z84}Q  A: pendiente" "$G" "$H" "$R0"; caso "L4[$loc] 84xZWSP+'Q  A' (256 B)" E "$S0" "$C"
 doc "$S0" "$T" "${Z84}Q   A: pendiente" "$G" "$H" "$R0"; caso "L5[$loc] 84xZWSP+'Q   A' (257 B)" E "$S0" "$C"
done
unset LC_ALL
echo "## Excepcion de REQ-031 CA-A12 (solo Hallazgos canonica repetida)"
doc "$S0" "$T" "$Q" "$G" 'Hallazgos abiertos: SEC-1 (contrato)' '**Hallazgos abiertos:** (ninguno)' "$R0"; caso "U4 canonica + decorada (CA-A12)" E "$S0" "$C"
doc "$S0" "$T" "$Q" "$G" 'Hallazgos abiertos: SEC-1 (contrato)' 'Hallazgos abiertos: (ninguno)' "$R0" "$Q"; caso "U5 CA-A12 + QA repetida" E "$S0" "$C"
doc "$S0" "$T" "$Q" "$G" 'Hallazgos abiertos: (ninguno)' 'Hallazgos abiertos: (ninguno)' "$R0"; caso "U6 Hallazgos (ninguno) x2 identicos" E "$S0" "$C"
