#!/usr/bin/env bash
# bucle.sh <etiqueta> <hooks> <n> <gates-json> -> cuenta de decisiones y motivos de N cierres legítimos seguidos (un proyecto)
set -u
TAG="$1"; H="$2"; N="$3"; G="$4"
P=$(mktemp -d /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/b.XXXXXX)
mkdir -p "$P/requirements" "$P/.arnes"
jq -n --argjson g "$G" '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:$g}' > "$P/.arnes/config.json"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
jq -n --arg fp "$P/requirements/REQ-001.md" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$P/in"
declare -A C; max=0
for ((i=0;i<N;i++)); do
  t0=${EPOCHREALTIME/./}
  out=$(cd "$P" && CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$H/guard.sh" < "$P/in" 2>>"$P/err"); rc=$?
  ms=$(( (${EPOCHREALTIME/./}-t0)/1000 )); [ $ms -gt $max ] && max=$ms
  mot=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null)
  [ "$rc" = 124 ] && mot="TIMEOUT"
  k="${mot:0:150}"; [ -n "$k" ] || k=ALLOW; [ "$k" = ALLOW ] && [ $ms -lt 5000 ] || echo "  it=$i rc=$rc ms=$ms $k" >&2
  C["$k"]=$(( ${C["$k"]:-0} + 1 ))
done
echo "== $TAG n=$N gates=$G max_ms=$max"
for k in "${!C[@]}"; do printf '  %5d  %s\n' "${C[$k]}" "$k"; done
[ -s "$P/err" ] && { echo "  stderr (primeras líneas):"; head -5 "$P/err" | sed 's/^/    /'; }
for p in $(pgrep -u "$(id -u)" .); do [ "$(readlink /proc/$p/cwd 2>/dev/null)" = "$P" ] && kill -KILL "$p" 2>/dev/null; done
rm -rf "$P"
