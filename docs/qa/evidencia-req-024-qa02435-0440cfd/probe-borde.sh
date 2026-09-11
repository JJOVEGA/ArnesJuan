#!/usr/bin/env bash
set -u
H="$1"; BASE="$(mktemp -d)"; trap 'rm -rf "$BASE"' EXIT
mk() { local P="$BASE/$1"; rm -rf "$P"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  cat > "$P/.arnes/config.json" <<JSON
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md", "campos": { "ausencia_exige": $2 } }
JSON
  echo "$P"; }
req() { local f="$1" rig="$2"; shift 2
  { printf '# R\nEstado: en-revisión\nSensible a seguridad: no\nRigor: %s\nHallazgos abiertos: (ninguno)\n' "$rig"
    for l in "$@"; do printf '%s\n' "$l"; done; } > "$f"; }
j() { jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:$os,new_string:$ns}}'; }
go() { local out dec=allow; out="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" bash "$H/guard-completado.sh" 2>/dev/null)"
  printf '%s' "$out" | grep -Eq '"permissionDecision":"deny"' && dec=deny
  printf '  dec=%s\n  aviso=%s\n  motivo=%s\n' "$dec" \
    "$(printf '%s' "$out" | jq -r '(.systemMessage//"")' 2>/dev/null | tr '\n' ' ' | cut -c1-2000)" \
    "$(printf '%s' "$out" | jq -r '(.hookSpecificOutput.permissionDecisionReason//"")' 2>/dev/null | tr '\n' ' ' | cut -c1-260)"; }

echo "### (a) llave ENCENDIDA: ¿el DENY del cierre NOMBRA 'QA:' en los tres rigores?"
P="$(mk on true)"
for rig in ligero estandar critico; do
  req "$P/requirements/R.md" "$rig" 'qa: aprobado' 'Seguridad: aprobado'
  echo "-- rigor=$rig"; go "$P" "$(j "$P/requirements/R.md" 'Estado: en-revisión' 'Estado: completado')"
done
echo; echo "### (b) llave con TIPO INVALIDO (string \"true\"): ¿aviso y decision siguen de acuerdo?"
P2="$(mk bad '"true"')"
req "$P2/requirements/S.md" critico 'QA: pendiente' 'Seguridad: aprobado'
echo "-- aviso:"; go "$P2" "$(j "$P2/requirements/S.md" 'QA: pendiente' 'qa: aprobado')"
req "$P2/requirements/T.md" critico 'qa: aprobado' 'Seguridad: aprobado'
echo "-- cierre:"; go "$P2" "$(j "$P2/requirements/T.md" 'Estado: en-revisión' 'Estado: completado')"
echo; echo "### (c) llave ENCENDIDA + rigor ligero: ¿el aviso dice ENCENDIDA y el cierre deniega?"
req "$P/requirements/U.md" ligero 'QA: pendiente' 'Seguridad: aprobado'
go "$P" "$(j "$P/requirements/U.md" 'QA: pendiente' 'qa: aprobado')"
