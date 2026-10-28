#!/usr/bin/env bash
# traza.sh <hooks> <n> <gates-json> <outdir> [x] — como bucle.sh, guarda el stderr (y la traza con x) de cada cierre que no es allow
set -u
H="$1"; N="$2"; G="$3"; O="$4"; X="${5:-}"; mkdir -p "$O"
P=$(mktemp -d $O/p.XXXXXX); mkdir -p "$P/requirements" "$P/.arnes"
jq -n --argjson g "$G" '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:$g}' > "$P/.arnes/config.json"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
jq -n --arg fp "$P/requirements/REQ-001.md" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$P/in"
ok=0; malo=0
for ((i=0;i<N;i++)); do
  t0=${EPOCHREALTIME/./}
  if [ "$X" = x ]; then out=$(cd "$P" && CLAUDE_PROJECT_DIR="$P" timeout 60 bash -x "$H/guard.sh" < "$P/in" 2>"$O/err.$i"); rc=$?
  else out=$(cd "$P" && CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$H/guard.sh" < "$P/in" 2>"$O/err.$i"); rc=$?; fi
  ms=$(( (${EPOCHREALTIME/./}-t0)/1000 ))
  if [ -z "$out" ] && [ $rc = 0 ]; then ok=$((ok+1)); rm -f "$O/err.$i"
  else malo=$((malo+1)); printf '%s\n' "$out" > "$O/out.$i"; echo "it=$i rc=$rc ms=$ms $(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null | cut -c1-90)"; fi
done
echo "allow=$ok otros=$malo"
for p in $(pgrep -u "$(id -u)" .); do [ "$(readlink /proc/$p/cwd 2>/dev/null)" = "$P" ] && kill -KILL "$p" 2>/dev/null; done
