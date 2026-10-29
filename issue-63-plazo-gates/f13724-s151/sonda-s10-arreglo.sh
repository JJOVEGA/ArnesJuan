#!/usr/bin/env bash
# Misma sonda que r066/sonda-s10-confirma.sh (veredicto verde, src/a.txt cambiado, 200 GiB dispersos), sobre el árbol del arreglo.
set -u
R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r066
. <(sed -n '/^mk()/,/^}/p' $R/sondas.sh)
C=/home/juan/dev/ArnesJuan-1.36.3; T=$C/tools/arnes-gates.sh
herr() { ( cd "$1" && bash "$T" --quien auditor-seguridad >/dev/null 2>&1 ); echo "herramienta rc=$?"; }
cierra_largo() { jq -n --arg fp "$2/requirements/REQ-001.md" --arg cwd "$2" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' | (cd "$2" && CLAUDE_PROJECT_DIR="$2" timeout 1500 bash "$1/hooks/guard.sh" 2>/dev/null) > "$2.out"; echo "rc=${PIPESTATUS[1]}"; jq -r .hookSpecificOutput.permissionDecisionReason "$2.out" | cut -c1-330; }
P=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/s151/w/c10-arreglo; mkdir -p /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/s151/w; mk $P '["grep -q bien src/a.txt"]'; herr $P; echo mal > $P/src/a.txt; truncate -s 200G $P/datos.bin
t0=${EPOCHREALTIME/./}; cierra_largo $C $P; t1=${EPOCHREALTIME/./}; echo "arreglo: $(( (t1-t0)/1000 )) ms (presupuesto 30 000 ms; umbral del cliente 600 000 ms)"
sleep 0.5; pgrep -af "$P" | grep -v sonda || echo "sin procesos vivos del proyecto"
echo "fin $(date -Iseconds)"
