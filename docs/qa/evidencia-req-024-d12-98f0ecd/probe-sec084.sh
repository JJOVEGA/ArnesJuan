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
run() { printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" bash "$H/guard-completado.sh" 2>/dev/null; }
dec() { local o; o="$(run "$1" "$2")"; if printf '%s' "$o" | grep -Eq '"permissionDecision":"deny"'; then echo DENY
        elif printf '%s' "$o" | grep -q 'systemMessage'; then echo "ALLOW+aviso"; else echo "ALLOW(mudo)"; fi; }
for llave in false true; do
sed -i "s/\"ausencia_exige\": [a-z]*/\"ausencia_exige\": $llave/" "$P/.arnes/config.json"
echo "=== llave ausencia_exige=$llave · REQ critico con QA: pendiente ==="
printf '%-34s %-14s %-14s\n' 'forma escrita de la clave' 'FIRMAR' 'CIERRE despues'
while IFS='|' read -r etiq linea; do
  f="$P/requirements/T.md"
  printf '# R\nEstado: en-revisión\nSensible a seguridad: sí\nRigor: critico\nHallazgos abiertos: (ninguno)\nQA: pendiente\n%s: pendiente\n' "$etiq" > "$f"
  a=$(dec "$P" "$(j "$f" "$etiq: pendiente" "$etiq: aprobado")")
  printf '# R\nEstado: en-revisión\nSensible a seguridad: sí\nRigor: critico\nHallazgos abiertos: (ninguno)\nQA: pendiente\n%s: aprobado\n' "$etiq" > "$f"
  b=$(dec "$P" "$(j "$f" 'Estado: en-revisión' 'Estado: completado')")
  printf '%-34s %-14s %-14s\n' "$etiq" "$a" "$b"
done <<'FORMAS'
Seguridad|
_Seguridad_|
**Seguridad**|
__Seguridad__|
*Seguridad*|
`Seguridad`|
FORMAS
echo
done
