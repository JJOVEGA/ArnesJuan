#!/usr/bin/env bash
# rq.sh <etiqueta> <hooks-dir> <gates-json> [timeout_s] [wrap] -> una línea: árbol, rc, ms, decisión, motivo corto, gates.
# Proyecto desechable en el scratchpad; al terminar, mata (KILL) SOLO los procesos cuyo cwd es ese proyecto.
set -u
TAG="$1"; H="$2"; G="$3"; TO="${4:-60}"; WRAP="${5:-}"
P=$(mktemp -d /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/p.XXXXXX)
mkdir -p "$P/requirements" "$P/.arnes"
jq -n --argjson g "$G" '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:$g}' > "$P/.arnes/config.json"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
jq -n --arg fp "$P/requirements/REQ-001.md" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$P/in"
t0=${EPOCHREALTIME/./}
if [ "$WRAP" = pty ]; then
  out=$(cd "$P" && CLAUDE_PROJECT_DIR="$P" timeout "$TO" script -qec "bash '$H/guard.sh' < '$P/in' > '$P/out' 2>/dev/null" /dev/null >/dev/null 2>&1; echo "rc=$?"); rc=${out#rc=}; out=$(cat "$P/out" 2>/dev/null)
else
  out=$(cd "$P" && CLAUDE_PROJECT_DIR="$P" timeout "$TO" bash "$H/guard.sh" < "$P/in" 2>/dev/null); rc=$?
fi
ms=$(( (${EPOCHREALTIME/./}-t0)/1000 ))
dec=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // "sin-decision"' 2>/dev/null)
mot=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null)
case "$mot" in *"dentro de su presupuesto"*) m=PRESUP;; *"plazo propio"*) m=PLAZO;; *"falló la quality gate"*) m="GATE";; *"bash ("*) m=BASH;; *"reloj que vigila"*) m=RELOJ;; *"termino sin concluir"*) m=TRAMPA;; '') m=-;; *) m="OTRO:${mot:0:70}";; esac
[ "$rc" = 124 ] && dec=sin-decision-timeout
printf '%-6s rc=%-3s %7sms %-20s %-8s %s\n' "$TAG" "$rc" "$ms" "${dec:-sin-decision}" "$m" "$G"
# limpieza acotada por cwd
for p in $(pgrep -u "$(id -u)" .); do [ "$(readlink /proc/$p/cwd 2>/dev/null)" = "$P" ] && kill -KILL "$p" 2>/dev/null; done
rm -rf "$P"
