set -u
S="$1"; REPO=/home/juan/dev/ArnesJuan-1.34-reparaciones
PV="$S/fix/proj-vacio"; mkdir -p "$PV/.arnes" "$PV/requirements" "$PV/docs"
cat > "$PV/.arnes/config.json" <<'JSON'
{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}
JSON
printf '# ESTADO\n' > "$PV/docs/ESTADO.md"
printf '## Pendientes\n\n## Resueltas\n' > "$PV/PENDING_APPROVAL.md"
P="$S/fix/proj"; mkdir -p "$P/.arnes" "$P/requirements" "$P/docs"
cp "$PV/.arnes/config.json" "$P/.arnes/config.json"
printf '# ESTADO\n' > "$P/docs/ESTADO.md"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
cp "$REPO"/requirements/REQ-*.md "$P/requirements/" 2>/dev/null || :
CLAUDE_PROJECT_DIR="$P" jq -n --arg fp "$P/requirements/REQ-951.md" --arg c '# REQ-951
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Hallazgos abiertos: (ninguno)
Rigor: critico' '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,
                  tool_input:{file_path:$fp,content:$c}}' > "$S/fix/ent.json"
echo listo
