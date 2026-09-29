# QA (intervención documental): ¿«1 601 líneas repetidas de 60 caracteres o más deniegan» vale con caracteres no ASCII?
# El motivo de CA-A12 cita '${l:0:60}' en el locale ambiente: en UTF-8 son 60 CARACTERES, no bytes.
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-doc/lib-sonda-qa.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
run() { local id="$1" LL="$2" n="$3" loc="$4" L=() i j out d
  for ((i=0;i<n-1;i++)); do L+=("$LL"); done
  doc "$S0" "$T" "$Q" "$G" 'Hallazgos abiertos: SEC-1 (contrato)' "${L[@]}" "$R0"; j="$(jedit "$S0" "$C")"
  for h in "$CAND" "$BASE"; do printf '%s' "$DOC" > "$F"
    out=$(env LC_ALL=$loc CLAUDE_PROJECT_DIR=$P timeout 150 bash "$h/guard.sh" <<< "$j" 2>$E/.err); d=allow; [ -n "$out" ] && d=$(jq -r .hookSpecificOutput.permissionDecision <<< "$out")
    printf '%-34s n=%-5s LC_ALL=%-8s %-4s dec=%-5s salida=%sB err=%s\n' "$id" "$n" "$loc" "$([ "$h" = "$CAND" ] && echo cand || echo base)" $d ${#out} "$(grep -o 'Argument list too long' $E/.err | head -1)"
  done; }
ASC='Hallazgos abiertos: SEC-2 (instrumento, relleno de sesenta caracteres)'
NA2='Hallazgos abiertos: SEC-2 (instrumento, ñññññññññññññññññññññññññññññññññññññññññ)'
NA3='Hallazgos abiertos: SEC-2 (instrumento, «»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»)'
printf 'bytes de los primeros 60 caracteres: ASC=%s NA2=%s NA3=%s\n' "$(LC_ALL=C.UTF-8 bash -c 'l="$1"; printf %s "${l:0:60}"' _ "$ASC" | wc -c)" "$(LC_ALL=C.UTF-8 bash -c 'l="$1"; printf %s "${l:0:60}"' _ "$NA2" | wc -c)" "$(LC_ALL=C.UTF-8 bash -c 'l="$1"; printf %s "${l:0:60}"' _ "$NA3" | wc -c)"
run "control ASCII (=R-045)" "$ASC" 1601 C.UTF-8
run "ñ (2 bytes) en los 60 primeros" "$NA2" 1601 C.UTF-8
run "ñ (2 bytes) en los 60 primeros" "$NA2" 1601 C
run "«» (2 bytes) en los 60 primeros" "$NA3" 1601 C.UTF-8
run "ñ (2 bytes) en los 60 primeros" "$NA2" 1201 C.UTF-8
# Segunda tanda: 4 bytes por carácter (U+1F600) en 40 de los 60 primeros caracteres
NA4='Hallazgos abiertos: SEC-2 (instrumento, 😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀😀)'
printf 'bytes de los primeros 60 caracteres: NA4=%s\n' "$(LC_ALL=C.UTF-8 bash -c 'l="$1"; printf %s "${l:0:60}"' _ "$NA4" | wc -c)"
run "😀 (4 bytes) en los 60 primeros" "$NA4" 801 C.UTF-8
run "control ASCII con el mismo n" "$ASC" 801 C.UTF-8
run "😀 (4 bytes) en los 60 primeros" "$NA4" 601 C.UTF-8
