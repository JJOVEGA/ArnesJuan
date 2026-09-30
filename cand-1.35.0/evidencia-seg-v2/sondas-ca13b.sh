. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2/lib-sonda.sh
S0='Estado: en-revisión (tras “R-4”)'
doc "$S0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: SEC-1 (contrato)' 'Rigor: critico' 'Prioridad: alta'
printf '%s' "$DOC" > $F; j=$(jq -cn --arg p "$P" --arg c "sed -i 's/en-revisión/completado/' requirements/REQ-900.md" '{tool_name:"Bash",cwd:$p,agent_type:"auditor-seguridad",tool_input:{command:$c}}')
for h in "$CAND" "$BASE"; do juzga "$h" "$j"; echo "D3b Bash sed -i relativo con el estado terminal: $(basename $(dirname $h)) dec=$DEC | ${MOT:0:90}"; done
printf 'ñ%.0s' $(seq 100000) > $E2/.big
for h in "$CAND"; do printf '%s' "$DOC" > $F
  jq -cn --rawfile o $E2/.big --arg f "$F" --arg p "$P" '{tool_name:"Edit",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,old_string:$o,new_string:"completado"}}' > $E2/.jbig
  echo "json del instrumento: $(wc -c < $E2/.jbig) bytes (no vacio)"
  out=$(CLAUDE_PROJECT_DIR=$P bash "$h/guard.sh" < $E2/.jbig 2>$E2/.err); m=$(jq -r .hookSpecificOutput.permissionDecisionReason <<< "$out")
  echo "E1b old_string no literal de 200 000 bytes (ñ): dec=$(jq -r .hookSpecificOutput.permissionDecision <<< "$out") motivo=$(printf '%s' "$m" | wc -c) bytes, crudo>=0x80 fuera del texto fijo: $(printf '%s' "$m" | sed "s/'requirements[^']*'//" | LC_ALL=C grep -c $'[\x80-\xff]') err=$(head -c 80 $E2/.err)"
  echo "   $(grep -o 'El old_string de .\{0,200\}' <<< "$m")"
done
