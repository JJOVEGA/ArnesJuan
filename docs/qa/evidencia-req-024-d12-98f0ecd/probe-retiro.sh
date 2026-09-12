#!/usr/bin/env bash
set -u
H="$1"; BASE="$(mktemp -d)"; trap 'rm -rf "$BASE"' EXIT
P="$BASE/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
cat > "$P/.arnes/config.json" <<'JSON'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md", "campos": { "ausencia_exige": false } }
JSON
j() { jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:$os,new_string:$ns}}'; }
dec() { local o; o="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" bash "$H/guard-completado.sh" 2>/dev/null)"
  if printf '%s' "$o" | grep -Eq '"permissionDecision":"deny"'; then echo DENY
  elif printf '%s' "$o" | grep -q 'systemMessage'; then echo "ALLOW+aviso"; else echo "ALLOW(mudo)"; fi; }
for k in false true; do
 sed -i "s/\"ausencia_exige\": [a-z]*/\"ausencia_exige\": $k/" "$P/.arnes/config.json"
 for r in ligero estandar critico; do
  f="$P/requirements/R.md"
  printf '# R\nEstado: en-revisión\nSensible a seguridad: no\nRigor: %s\nHallazgos abiertos: (ninguno)\nQA: aprobado\nSeguridad: aprobado\n' "$r" > "$f"
  a=$(dec "$P" "$(j "$f" 'QA: aprobado
' '')")
  printf '# R\nEstado: en-revisión\nSensible a seguridad: no\nRigor: %s\nHallazgos abiertos: (ninguno)\nSeguridad: aprobado\n' "$r" > "$f"
  b=$(dec "$P" "$(j "$f" 'Estado: en-revisión' 'Estado: completado')")
  printf '  llave=%-5s rigor=%-9s retirar QA: -> %-12s  y luego CERRAR -> %s\n' "$k" "$r" "$a" "$b"
 done
done
