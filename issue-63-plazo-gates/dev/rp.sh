# rp.sh <plug> <gates-json-array> [env...] -> tree, gates, ms, decision, motive head
PLUG="$1"; G="$2"; shift 2; P=$(mktemp -d)
mkdir -p "$P/requirements" "$P/.arnes"
jq -n --argjson g "$G" '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:$g}' > "$P/.arnes/config.json"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
payload=$(jq -n --arg fp "$P/requirements/REQ-001.md" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}')
t0=${EPOCHREALTIME/./}
out=$(printf '%s' "$payload" | env "$@" CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$PLUG/hooks/guard.sh" 2>/dev/null); rc=$?
ms=$(( (${EPOCHREALTIME/./}-t0)/1000 ))
dec=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // "sin-decision"' 2>/dev/null)
mot=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null)
case "$mot" in *presupuesto*) m=PRESUP;; *"plazo propio"*) m=PLAZO;; *"falló la quality gate"*) m="GATE:${mot#*quality gate \`}"; m="${m%%\`*}";; *"bash ("*) m=BASH;; *"reloj"*) m=RELOJ;; '') m=-;; *) m="OTRO:${mot:0:60}";; esac
printf '%-4s rc=%-3s %6sms %-12s %-14s %s\n' "$(basename "$PLUG")" "$rc" "$ms" "${dec:-sin-decision}" "$m" "$G"
rm -rf "$P"
