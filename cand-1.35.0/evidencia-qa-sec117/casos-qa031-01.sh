#!/usr/bin/env bash
set -uo pipefail
H="$1"; R="$(mktemp -d)"; trap 'rm -rf "$R"' EXIT
P="$R/proj"; mkdir -p "$P/.arnes" "$P/requirements"
printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["desarrollador"]},"codigo_app":{"globs":["src/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; export CLAUDE_PROJECT_DIR="$P"
F="$P/requirements/REQ-5.md"
for v in 'HALLAZGOS ABIERTOS:' 'hallazgos abiertos:' 'Hallazgos  abiertos:' '- Hallazgos abiertos:'; do
printf '# REQ-5\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: QA-2 (instrumento)\n%s SEC-1 (contrato)\n' "$v" > "$F"
j="$(jq -n --arg fp "$F" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}')"
out="$(printf '%s' "$j" | "$H/guard.sh" 2>/dev/null)"
d=allow; grep -q '"deny"' <<< "$out" && d=deny
printf '%-26s Edit literal cierre -> %-5s %s\n' "'$v'" "$d" "$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" | cut -c1-90)"
done
