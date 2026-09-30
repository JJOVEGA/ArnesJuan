. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
BIG=$(for i in $(seq 7000); do printf 'X-%d (instrumento, evidencia larga de relleno), ' $i; done); BIG="SEC-9 (contrato), ${BIG%, }"
doc "$S0" "$T" "$Q" "$G" "Hallazgos abiertos: $BIG" "$R0"; caso "T1 techo 348 910 B, Edit" jedit "$S0" "$C"
caso "T2 techo 348 910 B, Write" jwrite "${DOC/"$S0"/"$C"}"
LL='Hallazgos abiertos: SEC-2 (instrumento, relleno de sesenta caracteres)'; L=(); for ((i=0;i<1800;i++)); do L+=("$LL"); done
doc "$S0" "$T" "$Q" "$G" 'Hallazgos abiertos: SEC-1 (contrato)' "${L[@]}" "$R0"; caso "S1 SEC-118: CA-A12 con 1 801 lineas ASCII (sigue abierto)" jedit "$S0" "$C"
X140=$(head -c 140000 /dev/zero | tr '\0' 'x'); doc "$S0" "$T" "QA: pendiente—$X140" "$G" 'Hallazgos abiertos: (ninguno)' "$R0"; caso "S2 SEC-118: QA de 140 KB sin parentesis (sigue abierto)" jedit "$S0" "$C"
