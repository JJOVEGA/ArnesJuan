#!/usr/bin/env bash
# dobles.sh <hooks> <n> <gates-json> <outdir> — cuenta salidas que NO son exactamente un documento JSON (lo que el cliente no aplica)
set -u
H="$1"; N="$2"; G="$3"; O="$4"; mkdir -p "$O"
P=$(mktemp -d $O/p.XXXXXX); mkdir -p "$P/requirements" "$P/.arnes"
jq -n --argjson g "$G" '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:$g}' > "$P/.arnes/config.json"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
jq -n --arg fp "$P/requirements/REQ-001.md" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$P/in"
declare -A K; t_ini=$SECONDS
for ((i=0;i<N;i++)); do
  t0=${EPOCHREALTIME/./}
  out=$(cd "$P" && CLAUDE_PROJECT_DIR="$P" timeout 30 bash "$H/guard.sh" < "$P/in" 2>/dev/null); rc=$?
  ms=$(( (${EPOCHREALTIME/./}-t0)/1000 ))
  n=$(printf '%s' "$out" | jq -s 'length' 2>/dev/null || echo X)
  if [ -z "$out" ]; then k="allow(0 docs)"; else k="$n docs: $(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason[0:60]' 2>/dev/null | tr '\n' '|')"; fi
  [ "$rc" = 124 ] && k="TIMEOUT30 $k"
  K["$k"]=$(( ${K["$k"]:-0} + 1 ))
  case "$k" in "1 docs: ARNES: no se puede marcar"*) ;; *) printf '%s\n' "$out" > "$O/out.$i"; echo "  it=$i rc=$rc ms=$ms $k";; esac
done
echo "== $(basename $(dirname $H)) n=$N gates=$G s=$((SECONDS-t_ini))"; for k in "${!K[@]}"; do printf '  %5d  %s\n' "${K[$k]}" "$k"; done
for p in $(pgrep -u "$(id -u)" .); do [ "$(readlink /proc/$p/cwd 2>/dev/null)" = "$P" ] && kill -KILL "$p" 2>/dev/null; done
