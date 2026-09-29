. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
for loc in C C.UTF-8; do export LC_ALL=$loc
L=(); for i in $(seq 30); do L+=("$(printf '\xf0\x9f\x98\x80%.0s' $(seq 20))Sensible a seguridad: sí"); done
doc "$S0" "$T" "$Q" "$G" "$H" "$R0" "${L[@]}"; printf '%s' "$DOC" > "$F"; juzga "$CAND" "$(jedit "$S0" "$C")"
echo "X9[$loc] cand dec=$DEC motivo=${#MOT} caracteres; $(printf '%s' "$MOT" | wc -c) bytes; ¿byte >=0x80 crudo en el motivo?: $(printf '%s' "$MOT" | LC_ALL=C grep -c $'[\x80-\xff]')"
printf '%s\n' "$MOT" | head -c 600; echo; echo '...'; printf '%s\n' "$MOT" | tail -c 400
done
