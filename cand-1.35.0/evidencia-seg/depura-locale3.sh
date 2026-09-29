. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
E1=$(printf '\xf0\x9f\x98\x80%.0s' $(seq 20))
L=(); for i in $(seq ${N:-30}); do L+=("${E1}Sensible a seguridad: sí"); done
doc "$S0" "$T" "$Q" "$G" "$H" "$R0" "${L[@]}"; printf '%s' "$DOC" > "$F"; sha=$(sha256sum < "$F" | cut -c1-12)
juzga "$CAND" "$(jedit "$S0" "$C")"
echo "LC_ALL=${LC_ALL-<unset>} N=${N:-30} doc=$sha dec=$DEC items=$(grep -o 'linea [0-9]*' <<< "$MOT" | head -3 | tr '\n' ,) veces=$(grep -o 'declara[da]* [0-9]* veces' <<< "$MOT" | head -2 | tr '\n' ,) resto=$(grep -o 'y [0-9]* linea(s) ambigua(s) mas' <<< "$MOT")"
