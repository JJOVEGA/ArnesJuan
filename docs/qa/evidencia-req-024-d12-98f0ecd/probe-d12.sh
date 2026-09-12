#!/usr/bin/env bash
# QA D12 — mide con el hook REAL las celdas que la fila :351 y el parrafo afirman.
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
llave() { sed -i "s/\"ausencia_exige\": [a-z]*/\"ausencia_exige\": $1/" "$P/.arnes/config.json"; }
j() { jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" --arg ag "${4:-}" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,agent_name:$ag,tool_input:{file_path:$fp,old_string:$os,new_string:$ns}}'; }
go() { local out dec=ALLOW; out="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" bash "$H/guard-completado.sh" 2>/dev/null)"
  printf '%s' "$out" | grep -Eq '"permissionDecision":"deny"' && dec=DENY; printf '%s' "$dec"; }
# construye un REQ: $1=archivo $2=rigor $3=linea QA (vacio=ausente) $4=linea SEG
req() { local f="$1"; { printf '# R\nEstado: en-revisión\nSensible a seguridad: no\nRigor: %s\nHallazgos abiertos: (ninguno)\n' "$2"
  [ -n "$3" ] && printf '%s\n' "$3"; [ -n "$4" ] && printf '%s\n' "$4"; } > "$f"; }
cierre() { go "$P" "$(j "$1" 'Estado: en-revisión' 'Estado: completado')"; }

echo "=== EJE 1 · POR VALOR (campo declarado, valor fuera de vocabulario) ==="
printf '%-7s %-9s %-7s %-7s\n' llave rigor QAfuera SEGfuera
for k in false true; do llave $k; for r in ligero estandar critico; do
  req "$P/requirements/A.md" "$r" 'QA: aprobadisimo' 'Seguridad: aprobado'; a=$(cierre "$P/requirements/A.md")
  req "$P/requirements/B.md" "$r" 'QA: aprobado' 'Seguridad: aprobadisimo'; b=$(cierre "$P/requirements/B.md")
  printf '%-7s %-9s %-7s %-7s\n' "$k" "$r" "$a" "$b"
done; done

echo; echo "=== EJE 2 · POR AUSENCIA (el campo no llega a declararse) ==="
printf '%-7s %-9s %-10s %-10s %-12s\n' llave rigor QAausente SEGausente 'QAminuscula'
for k in false true; do llave $k; for r in ligero estandar critico; do
  req "$P/requirements/C.md" "$r" '' 'Seguridad: aprobado'; a=$(cierre "$P/requirements/C.md")
  req "$P/requirements/D.md" "$r" 'QA: aprobado' ''; b=$(cierre "$P/requirements/D.md")
  req "$P/requirements/E.md" "$r" 'qa: aprobado' 'Seguridad: aprobado'; c=$(cierre "$P/requirements/E.md")
  printf '%-7s %-9s %-10s %-10s %-12s\n' "$k" "$r" "$a" "$b" "$c"
done; done

echo; echo "=== EJE 3 · FIRMAR Seguridad: aprobado con QA sin declararse (fila :353) ==="
printf '%-7s %-9s %-12s %-12s %-12s\n' llave rigor 'QAausente' 'QAminuscula' 'QApendiente'
for k in false true; do llave $k; for r in ligero estandar critico; do
  req "$P/requirements/F.md" "$r" '' 'Seguridad: pendiente'
  a=$(go "$P" "$(j "$P/requirements/F.md" 'Seguridad: pendiente' 'Seguridad: aprobado')")
  req "$P/requirements/G.md" "$r" 'qa: aprobado' 'Seguridad: pendiente'
  b=$(go "$P" "$(j "$P/requirements/G.md" 'Seguridad: pendiente' 'Seguridad: aprobado')")
  req "$P/requirements/I.md" "$r" 'QA: pendiente' 'Seguridad: pendiente'
  c=$(go "$P" "$(j "$P/requirements/I.md" 'Seguridad: pendiente' 'Seguridad: aprobado')")
  printf '%-7s %-9s %-12s %-12s %-12s\n' "$k" "$r" "$a" "$b" "$c"
done; done
