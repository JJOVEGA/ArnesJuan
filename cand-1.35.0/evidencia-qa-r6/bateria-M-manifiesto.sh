#!/usr/bin/env bash
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r6/qa-lib-r6.sh
PRJ=$Q/proj-manif; rm -rf "$PRJ"; mkproj "$PRJ"
printf 'esto no es json {' > "$PRJ/.arnes/config.json"   # manifiesto roto
M="$PRJ/.arnes/config.json"
echo "== CA-60: manifiesto roto, la reparacion y sus bordes con salto, $(date -Iseconds) =="
quad "M-ctl Write al manifiesto SIN salto (la reparacion)"        guard.sh "$(j Write "$PRJ" - "file_path=$M" content={})"
quad "M-dev Write al manifiesto SIN salto por el desarrollador"   guard.sh "$(j Write "$PRJ" desarrollador "file_path=$M" content={})"
quad "M1 Write al manifiesto CON salto final (file_path LF)"      guard.sh "$(j Write "$PRJ" - "file_path=$M$NL" content={})"
quad "M2 Write a manif LF manif (dos en el file_path)"            guard.sh "$(j Write "$PRJ" - "file_path=$M$NL$M" content={})"
quad "M4 M1 por guard-completado a solas"                         guard-completado.sh "$(j Write "$PRJ" - "file_path=$M$NL" content={})"
quad "M5 tool_name Write LF al manifiesto"                        guard.sh "$(j "Write$NL" "$PRJ" - "file_path=$M" content={})"
REP="pri""ntf '{}' > .arnes/config.json"
quad "M-bash reparacion por Bash SIN salto"                       guard.sh "$(j Bash "$PRJ" - "command=$REP")"
quad "M-bash2 reparacion por Bash + otra escritura"              guard.sh "$(j Bash "$PRJ" - "command=$REP ; ec""ho x > src/a.ts")"
