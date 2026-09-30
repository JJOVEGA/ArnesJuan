. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2/lib-sonda.sh
S0='Estado: en-revisión'
doc "$S0" 'Sensible a seguridad: no' 'QA: pendiente' 'Seguridad: n/a'
caso "CA-01 valor solo, QA pendiente" jedit 'en-revisión' 'completado'
caso "CA-05 MultiEdit valor + historial" jmulti2 'en-revisión' 'completado' '- CA-01 x' '- CA-01 x (fila)'
jra() { jq -cn --arg f "$F" --arg p "$P" '{tool_name:"Edit",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,old_string:"en-revisión",new_string:"completado",replace_all:true}}'; }
caso "CA-06 replace_all true" jra
DOC="${DOC//$'\n'/$'\r\n'}"; caso "CA-07 CRLF, valor solo" jedit 'en-revisión' 'completado'
doc "$S0" 'Sensible a seguridad: no' 'QA: aprobado' 'Seguridad: n/a'; caso "CA-13 control positivo (verde)" jedit 'en-revisión' 'completado'
N=$P/requirements/NO-EXISTE.md; rm -f $N
for h in "$CAND" "$BASE"; do j=$(jq -cn --arg f "$N" --arg p "$P" '{tool_name:"Edit",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,old_string:"x",new_string:"y"}}'); juzga "$h" "$j"; echo "CA-12 ruta inexistente, old 'x': $(basename $(dirname $h)) dec=$DEC rc=$RC stderr=[$(cat $E2/.err)]"; done
for h in "$CAND" "$BASE"; do j=$(jq -cn --arg f "$N" --arg p "$P" '{tool_name:"Edit",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,old_string:"",new_string:"# R\nEstado: en-progreso\n"}}'); juzga "$h" "$j"; echo "CA-12 ruta inexistente, creacion: $(basename $(dirname $h)) dec=$DEC rc=$RC stderr=[$(cat $E2/.err)]"; done
bj() { jq -cn --arg p "$P" --arg c "$1" --arg a "$2" '{tool_name:"Bash",cwd:$p,agent_type:$a,tool_input:{command:$c}}'; }
for h in "$CAND" "$BASE"; do juzga "$h" "$(bj $'cat <<EOF\n$(echo x > src/generated.ts)\nEOF' '')"; a=$DEC; juzga "$h" "$(bj $'cat <<EOF\n$(sed -i \'s/en-revisión/completado/\' requirements/REQ-900.md)\nEOF' '')"; b=$DEC; juzga "$h" "$(bj $'cat <<EOF\n$(echo x > src/generated.ts)\nEOF' 'desarrollador')"; c=$DEC; echo "CA-16/CA-23/CA-24 $(basename $(dirname $h)): $a / $b / $c"; done
