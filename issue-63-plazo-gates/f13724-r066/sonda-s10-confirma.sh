#!/usr/bin/env bash
# CONFIRMACION de SEC-151 a nivel de hook (carga larga: la lanza la coordinadora, ~15 min; NO la corrio el auditor).
# Veredicto verde y despues un cambio de codigo (caducado) + un archivo disperso no ignorado de 200 GiB (0 bytes en disco).
# Si el hook tarda mas de 600 000 ms, el cliente lo cancela y aplica el Edit sin decision (medido por QA, CA-12).
set -u
R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r066
. <(sed -n '/^C=/,/^W=/p' $R/sondas.sh)
cierra_largo() { jq -n --arg fp "$2/requirements/REQ-001.md" --arg cwd "$2" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' | (cd "$2" && CLAUDE_PROJECT_DIR="$2" timeout 1500 bash "$1/hooks/guard.sh" 2>/dev/null | head -c 200); echo " rc=${PIPESTATUS[1]}"; }
P=$W/c10-conf; mk $P '["grep -q bien src/a.txt"]'; herr $P; echo mal > $P/src/a.txt; truncate -s 200G $P/datos.bin
t0=${EPOCHREALTIME/./}; cierra_largo $C $P; t1=${EPOCHREALTIME/./}; echo "cand: $(( (t1-t0)/1000 )) ms (umbral del cliente: 600000 ms)"
t0=${EPOCHREALTIME/./}; cierra_largo $B $P; t1=${EPOCHREALTIME/./}; echo "base: $(( (t1-t0)/1000 )) ms"
rm -rf $P
