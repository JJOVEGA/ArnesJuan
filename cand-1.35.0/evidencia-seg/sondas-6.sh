# Umbral de CA-A12 con lineas que el motivo cita enteras (60 caracteres): cuantas repeticiones bastan para dejar la puerta sin salida.
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
LL='Hallazgos abiertos: SEC-2 (instrumento, relleno de sesenta caracteres)'
for n in 1600 1800; do
  L=(); for ((i=0;i<n;i++)); do L+=("$LL"); done
  doc "$S0" "$T" "$Q" "$G" 'Hallazgos abiertos: SEC-1 (contrato)' "${L[@]}" "$R0"; j="$(jedit "$S0" "$C")"
  for h in "$CAND" "$BASE"; do printf '%s' "$DOC" > "$F"
    out=$(CLAUDE_PROJECT_DIR=$P timeout 150 bash "$h/guard.sh" <<< "$j" 2>$E/.err); d=allow; [ -n "$out" ] && d=$(jq -r .hookSpecificOutput.permissionDecision <<< "$out")
    printf 'CA-A12 %s repeticiones de 60+ car. %-4s dec=%-5s motivo=%sB err=%s\n' $((n+1)) "$([ "$h" = "$CAND" ] && echo cand || echo base)" $d ${#out} "$(grep -o 'Argument list too long' $E/.err | head -1)"
  done
done
