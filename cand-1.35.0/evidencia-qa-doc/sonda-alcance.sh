# QA (intervención documental): bordes de «las ediciones cuyo documento resultante la puerta reconstruye».
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-doc/lib-sonda-qa.sh
jm2() { jq -cn --arg f "$F" --arg o1 "$1" --arg n1 "$2" --arg o2 "$3" --arg n2 "$4" --arg p "$P" '{tool_name:"MultiEdit",cwd:$p,agent_type:"qa-tester",tool_input:{file_path:$f,edits:[{old_string:$o1,new_string:$n1},{old_string:$o2,new_string:$n2}]}}'; }
S0='Estado: en-revisión'
# M1: MultiEdit cuyo 2.º old_string sólo existe tras la 1.ª edición (no está en el archivo, sí en el intermedio)
doc "$S0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico'
printf '%s' "$DOC" > "$F"; juzga "$CAND" "$(jm2 'Estado: en-revisión' 'Estado: intermedio' 'intermedio' 'completado')"
printf '%-58s cand=%s | %s\n' "M1 MultiEdit, 2.º old_string sólo en el intermedio" "$DEC" "${MOT:0:100}"
# N1: Edit con old_string vacío sobre un REQ que no existe (creación), línea decorada, QA pendiente
rm -f "$F"; DOCN=$'# REQ-900\n**Estado:** completado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: SEC-1 (contrato)\nRigor: critico\n\n## Criterios\n'
juzga "$CAND" "$(jedit '' "$DOCN")"; printf '%-58s cand=%s | %s\n' "N1 Edit old_string vacío, archivo nuevo, **Estado:**" "$DEC" "${MOT:0:100}"
juzga "$CAND" "$(jwrite "$DOCN")"; printf '%-58s cand=%s | %s\n' "N1w control: el mismo documento por Write" "$DEC" "${MOT:0:100}"
