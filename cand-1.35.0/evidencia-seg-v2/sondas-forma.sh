. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2/lib-sonda.sh
S0='Estado: en-revisión'; C='Estado: completado'
doc "$S0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico'
raw() { jq -cn --arg f "$F" --arg p "$P" --argjson ti "$1" '{tool_name:$ENV.T,cwd:$p,agent_type:"auditor-seguridad",tool_input:($ti + {file_path:$f})}'; }
T=Edit      caso "F1 Edit old_string numerico (5)"                raw '{"old_string":5,"new_string":"completado"}'
T=Edit      caso "F2 Edit sin old_string ni new_string"            raw '{}'
T=Edit      caso "F3 Edit con alias old_str/new_str (CLI los acepta)" raw '{"old_str":"en-revisión","new_str":"completado"}'
T=Edit      caso "F4 Edit replace_all como cadena \"true\""          raw '{"old_string":"en-revisión","new_string":"completado","replace_all":"true"}'
T=MultiEdit caso "F5 MultiEdit edits no es lista (cadena)"         raw '{"edits":"x"}'
T=MultiEdit caso "F6 MultiEdit edits con numero"                   raw '{"edits":[5]}'
T=MultiEdit caso "F7 MultiEdit edits vacio"                        raw '{"edits":[]}'
T=MultiEdit caso "F8 MultiEdit old_string numerico"                raw '{"edits":[{"old_string":5,"new_string":"completado"}]}'
