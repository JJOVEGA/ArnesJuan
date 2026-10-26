#!/usr/bin/env bash
# Issue #63: un cierre con todo en orden y una quality gate lenta.
# Uso: repro.sh <raíz-del-plugin> <gate> <directorio-nuevo>
set -u
PLUG="$1"; GATE="$2"; P="$3"
mkdir -p "$P/requirements" "$P/.arnes" "$P/src"
jq -n --arg g "$GATE" '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},
  codigo_app:{globs:["src/*"]}, quality_gates:[$g]}' > "$P/.arnes/config.json"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
( cd "$P" && git init -q && git add -A && git -c user.email=x@x -c user.name=x commit -qm base )
payload=$(jq -n --arg fp "$P/requirements/REQ-001.md" --arg cwd "$P" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",
    tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}')
t0=$(date +%s.%N)
out=$(printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$P" CLAUDE_PLUGIN_ROOT="$PLUG" bash "$PLUG/hooks/guard.sh"); rc=$?
t1=$(date +%s.%N)
dec=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // "sin-decision"' 2>/dev/null)
mot=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null | cut -c1-110)
printf '%s\t%s\trc=%s\t%.1fs\t%s\t%s\n' "$(basename "$PLUG")" "$GATE" "$rc" "$(echo "$t1 - $t0" | bc)" "${dec:-sin-decision}" "$mot"
