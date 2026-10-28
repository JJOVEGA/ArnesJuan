#!/usr/bin/env bash
# ca02f.sh <hooks-dir> <work-dir> <out> — CA-02 (f): el cierre legítimo, gate `sleep 1000`, N real (420 s), a nivel de hook.
set -u
H="$1"; P="$2"; OUT="$3"
rm -rf "$P"; mkdir -p "$P/requirements" "$P/.arnes" "$P/src"
jq -n '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:["sleep 1000"]}' > "$P/.arnes/config.json"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
( cd "$P" && git init -q && git add -A && git -c user.email=x@x -c user.name=x commit -qm base )
jq -n --arg fp "$P/requirements/REQ-001.md" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$P/in"
echo "hooks=$H presupuesto=$(grep -n '^ARNES_GATES_PRESUPUESTO_S=' "$H/lib.sh") inicio=$(date -Is)" > "$OUT"
t0=${EPOCHREALTIME/./}
o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" timeout 700 bash "$H/guard.sh" < "$P/in" 2>"$OUT.err")"; rc=$?
ms=$(( (${EPOCHREALTIME/./} - t0) / 1000 ))
echo "rc=$rc ms=$ms fin=$(date -Is)" >> "$OUT"
printf '%s\n' "$o" | jq -r '.hookSpecificOutput | "decision=\(.permissionDecision)\nmotivo=\(.permissionDecisionReason)"' >> "$OUT" 2>&1 || printf 'salida cruda: %s\n' "$o" >> "$OUT"
vivos=''; for p in $(pgrep -x sleep); do [ "$(readlink /proc/$p/cwd 2>/dev/null)" = "$P" ] && vivos+="$p "; done
echo "sleep vivos con cwd en el proyecto tras la decisión: <$vivos>" >> "$OUT"
