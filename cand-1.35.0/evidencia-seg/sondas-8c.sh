. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
for loc in C C.UTF-8; do export LC_ALL=$loc
L=(); for i in $(seq 30); do L+=("$(printf '\xf0\x9f\x98\x80%.0s' $(seq 20))Sensible a seguridad: sí"); done
doc "$S0" "$T" "$Q" "$G" "$H" "$R0" "${L[@]}"; printf '%s' "$DOC" > "$F"
echo "[$loc] doc sha=$(sha256sum < $F | cut -c1-12) bytes=$(wc -c < $F) linea3=$(sed -n 3p $F | od -c | head -1 | cut -c1-60)"
juzga "$CAND" "$(jedit "$S0" "$C")"; echo "[$loc] items=$(grep -o 'linea [0-9]*' <<< "$MOT" | head -2 | tr '\n' ,) $(grep -o 'declara[da]* [0-9]* veces' <<< "$MOT" | head -1)"
done
