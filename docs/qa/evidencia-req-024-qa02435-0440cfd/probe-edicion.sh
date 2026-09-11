#!/usr/bin/env bash
set -u
H="$1"; BASE="$(mktemp -d)"; trap 'rm -rf "$BASE"' EXIT
P="$BASE/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
cat > "$P/.arnes/config.json" <<JSON
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md", "campos": { "ausencia_exige": false } }
JSON
req() { local f="$1" rig="$2"; shift 2
  { printf '# R\nEstado: en-revisión\nSensible a seguridad: no\nRigor: %s\nHallazgos abiertos: (ninguno)\n' "$rig"
    for l in "$@"; do printf '%s\n' "$l"; done; } > "$f"; }
j_edit() { jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:$os,new_string:$ns}}'; }
full() { local out rc dec=allow; out="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" bash "$H/guard-completado.sh" 2>/dev/null)"; rc=$?
  printf '%s' "$out" | grep -Eq '"permissionDecision":"deny"' && dec=deny
  local msg; msg="$(printf '%s' "$out" | jq -r '(.systemMessage // "")' 2>/dev/null | tr '\n' ' ')"
  local rea; rea="$(printf '%s' "$out" | jq -r '(.hookSpecificOutput.permissionDecisionReason // "")' 2>/dev/null | tr '\n' ' ' | cut -c1-200)"
  printf 'dec=%s rc=%s\n  AVISO: %s\n  MOTIVO: %s\n' "$dec" "$rc" "${msg:0:400}" "$rea"; }
for rig in ligero estandar critico; do
  echo "=========== rigor=$rig ==========="
  req "$P/requirements/A.md" "$rig" 'QA: pendiente' 'Seguridad: pendiente'
  echo "[1] edicion que PRODUCE el aviso de QA-desfase (Seguridad: pendiente):"; full "$P" "$(j_edit "$P/requirements/A.md" 'QA: pendiente' 'qa: aprobado')"
  req "$P/requirements/B.md" "$rig" 'QA: pendiente' 'Seguridad: aprobado'
  echo "[2] idem, pero el REQ YA lleva 'Seguridad: aprobado' (guarda de ORDEN en juego):"; full "$P" "$(j_edit "$P/requirements/B.md" 'QA: pendiente' 'qa: aprobado')"
  req "$P/requirements/C.md" "$rig" 'qa: aprobado' 'Seguridad: pendiente'
  echo "[3] FIRMAR Seguridad con QA ya en desfase:"; full "$P" "$(j_edit "$P/requirements/C.md" 'Seguridad: pendiente' 'Seguridad: aprobado')"
  req "$P/requirements/D.md" "$rig" 'QA: pendiente' 'Seguridad: pendiente'
  echo "[4] edicion que produce el aviso de QA fuera de vocabulario:"; full "$P" "$(j_edit "$P/requirements/D.md" 'QA: pendiente' 'QA: aprobadisimo')"
done
