set -u
H=/home/juan/dev/ArnesJuan-1.34-reparaciones/hooks; BASE="$(mktemp -d)"; trap 'rm -rf "$BASE"' EXIT
P="$BASE/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
cat > "$P/.arnes/config.json" <<'JSON'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md", "campos": { "ausencia_exige": false } }
JSON
echo "ESCENARIO EXACTO DE REQ-003 CA-13: UN Edit que escribe A LA VEZ el valor fuera del"
echo "vocabulario y el estado terminal. El criterio promete DENY, sin condicion."
for r in ligero estandar critico; do
  f="$P/requirements/Z.md"
  printf '# R\nEstado: en-revisión\nSensible a seguridad: no\nRigor: %s\nHallazgos abiertos: (ninguno)\nQA: pendiente\nSeguridad: aprobado\n' "$r" > "$f"
  json="$(jq -n --arg fp "$f" --arg os 'Estado: en-revisión
Sensible a seguridad: no
Rigor: '"$r"'
Hallazgos abiertos: (ninguno)
QA: pendiente' --arg ns 'Estado: completado
Sensible a seguridad: no
Rigor: '"$r"'
Hallazgos abiertos: (ninguno)
QA: aprobadisimo' '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:$os,new_string:$ns}}')"
  out="$(printf '%s' "$json" | CLAUDE_PROJECT_DIR="$P" bash "$H/guard-completado.sh" 2>/dev/null)"
  dec=ALLOW; printf '%s' "$out" | grep -Eq '"permissionDecision":"deny"' && dec=DENY
  printf '  rigor=%-9s -> %s   %s\n' "$r" "$dec" "$([ "$dec" = ALLOW ] && echo '<-- REQ-003 CA-13 promete DENY: FALSO aqui' || echo 'coincide con el criterio')"
done
