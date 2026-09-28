#!/usr/bin/env bash
# uso: smoke.sh <hooks_dir> ; lee valores de stdin (uno por linea)
H="$1"; P="$(mktemp -d)"; mkdir -p "$P/.arnes" "$P/requirements"
printf '%s' '{"agentes":{"agente_codigo":"desarrollador"},"codigo_app":{"globs":["src/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
while IFS= read -r v; do
  f="$P/requirements/REQ-A.md"
  printf '# REQ-A\nEstado: en-revisión\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: aprobado\nHallazgos abiertos: %s\n' "$v" > "$f"
  j="$(jq -n --arg fp "$f" --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"completado"}}')"
  out="$(printf '%s' "$j" | CLAUDE_PROJECT_DIR="$P" "$H/guard-completado.sh" 2>&1)"
  if printf '%s' "$out" | grep -q '"deny"'; then echo "[$v] => deny | $(printf '%s' "$out" | jq -r .hookSpecificOutput.permissionDecisionReason | cut -c1-330)"; else echo "[$v] => allow $out"; fi
done
rm -rf "$P"
