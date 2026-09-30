. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2/lib-sonda.sh
S0='Estado: en-revisión (tras “R-4”)'
doc "$S0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: SEC-1 (contrato)' 'Rigor: critico'
for h in "$CAND" "$BASE"; do
 j=$(jq -cn --arg p "$P" --arg c $'cat <<EOF\n$(echo x > src/generated.ts)\nEOF' '{tool_name:"Bash",cwd:$p,agent_id:"a1",agent_type:"arnes-juan:desarrollador",tool_input:{command:$c}}'); juzga "$h" "$j"; a=$DEC
 printf '%s' "$DOC" > $F; j=$(jq -cn --arg f "$F" --arg p "$P" '{tool_name:"Edit",cwd:$p,agent_id:"a1",agent_type:"arnes-juan:desarrollador",tool_input:{file_path:$f,old_string:"en-revisión (tras \"R-4\")",new_string:"completado"}}'); juzga "$h" "$j"; b=$DEC; m="${MOT:0:80}"
 echo "$(basename $(dirname $h)): CA-24 desarrollador heredoc=$a | D2b desarrollador Edit no literal=$b ($m)"
done
