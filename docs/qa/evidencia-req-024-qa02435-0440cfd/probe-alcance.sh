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
go() { local out dec=allow; out="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" bash "$H/guard-completado.sh" 2>/dev/null)"
  printf '%s' "$out" | grep -Eq '"permissionDecision":"deny"' && dec=deny
  printf '%s | motivo: %s' "$dec" "$(printf '%s' "$out" | jq -r '(.hookSpecificOutput.permissionDecisionReason//"—")' 2>/dev/null | tr '\n' ' ' | cut -c1-100)"; }
caso() { local n="$1"; shift; local f="$P/requirements/$n.md"
  { printf '# R\nEstado: en-revisión\n'; for l in "$@"; do printf '%s\n' "$l"; done; } > "$f"
  printf '%-52s %s\n' "$n" "$(go "$P" "$(j "$f" 'Estado: en-revisión' 'Estado: completado')")"; }
echo "LLAVE APAGADA. El aviso dice: «el REQ SI podra cerrarse SIN VEREDICTO DE QA»."
echo "¿Cierra el REQ por otras causas, y el calificativo «sin veredicto de QA» aguanta?"
caso QAausente-critico-SEGpendiente 'Sensible a seguridad: si' 'Rigor: critico' 'Hallazgos abiertos: (ninguno)' 'qa: aprobado' 'Seguridad: pendiente'
caso QAausente-critico-SEGaprobado  'Sensible a seguridad: si' 'Rigor: critico' 'Hallazgos abiertos: (ninguno)' 'qa: aprobado' 'Seguridad: aprobado'
caso QAausente-hallazgo-bloqueante  'Sensible a seguridad: no' 'Rigor: estandar' 'Hallazgos abiertos: X-1 (usuario/dinero)' 'qa: aprobado' 'Seguridad: aprobado'
caso QAausente-hallazgo-instrumento 'Sensible a seguridad: no' 'Rigor: estandar' 'Hallazgos abiertos: X-1 (instrumento)' 'qa: aprobado' 'Seguridad: aprobado'
caso QAausente-hallazgos-ausente    'Sensible a seguridad: no' 'Rigor: estandar' 'qa: aprobado' 'Seguridad: aprobado'
caso QAausente-SIN-linea-alguna     'Sensible a seguridad: no' 'Rigor: estandar' 'Hallazgos abiertos: (ninguno)' 'Seguridad: aprobado'
caso QAausente-rigor-ausente        'Sensible a seguridad: no' 'Hallazgos abiertos: (ninguno)' 'qa: aprobado' 'Seguridad: aprobado'
echo
echo "Y con la COLA de aprobaciones NO vacia (otra causa ajena a QA):"
printf '## Pendientes\n\n### [2026-09-11] (qa) — D1\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
caso QAausente-con-cola-pendiente   'Sensible a seguridad: no' 'Rigor: estandar' 'Hallazgos abiertos: (ninguno)' 'qa: aprobado' 'Seguridad: aprobado'
