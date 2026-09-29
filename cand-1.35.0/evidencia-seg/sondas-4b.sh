# Repeticion de C1 por Write con el contenido por --rawfile (la version con --arg fallo en el INSTRUMENTO: JSON vacio).
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
BIG=$(for i in $(seq 7000); do printf 'X-%d (instrumento, evidencia larga de relleno), ' $i; done); BIG="SEC-9 (contrato), ${BIG%, }"
doc "$S0" "$T" "$Q" "$G" "Hallazgos abiertos: $BIG" "$R0"
printf '%s' "${DOC/"$S0"/"$C"}" > $E/.content
jq -cn --rawfile c $E/.content --arg f "$F" --arg p "$P" '{tool_name:"Write",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,content:$c}}' > $E/.j
echo "json: $(wc -c < $E/.j) bytes (no vacio)"
for h in "$CAND" "$BASE"; do printf '%s' "$DOC" > "$F"
  t0=$(date +%s.%N); out=$(CLAUDE_PROJECT_DIR=$P timeout 150 bash "$h/guard.sh" < $E/.j 2>/dev/null); t1=$(date +%s.%N)
  d=allow; [ -n "$out" ] && d=$(jq -r .hookSpecificOutput.permissionDecision <<< "$out")
  echo "C1 techo por Write (rawfile) $h dec=$d t=$(awk -v a=$t0 -v b=$t1 'BEGIN{printf "%.2f",b-a}')s | $(jq -r '.hookSpecificOutput.permissionDecisionReason // ""' <<< "$out" | cut -c60-130)"
done
