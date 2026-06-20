#!/usr/bin/env bash
# Escenario de regresión de los hooks de enforcement del arnés (A1, A2, A3).
# Alimenta JSON de PreToolUse a los scripts reales y verifica deny/allow.
# No necesita Claude Code: prueba los scripts en aislamiento. Requiere jq.
set -uo pipefail

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../hooks" && pwd)"
PASS=0; FAIL=0

command -v jq >/dev/null 2>&1 || { echo "SKIP: jq no instalado"; exit 0; }

# --- proyecto de prueba efímero ---
PROJ="$(mktemp -d)"
trap 'rm -rf "$PROJ"' EXIT
mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
cat > "$PROJ/.arnes/config.json" <<'JSON'
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
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$PROJ"

# emite_edit <file_path> <agent_id> <agent_type> <new_string>
# Los campos agent_id/agent_type se OMITEN cuando van vacíos: así llega el input
# real de la sesión coordinadora (sin agent_id).
emite_edit() {
  jq -n --arg fp "$1" --arg aid "$2" --arg at "$3" --arg ns "$4" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,old_string:"x",new_string:$ns}}
     + (if $aid!="" then {agent_id:$aid} else {} end)
     + (if $at!=""  then {agent_type:$at} else {} end)'
}

# check <nombre> <esperado:deny|allow> <script> <json>
check() {
  local nombre="$1" esperado="$2" script="$3" json="$4" out got
  out="$(printf '%s' "$json" | "$HOOKS_DIR/$script" 2>/dev/null)"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then got=deny; else got=allow; fi
  if [ "$got" = "$esperado" ]; then
    echo "  PASS  $nombre  ($got)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  esperado=$esperado got=$got"; FAIL=$((FAIL+1))
  fi
}

echo "A1 — guard-codigo.sh (quién edita código de la app):"
check "coordinadora edita src/ -> deny"          deny  guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" ""    ""               'hola')"
check "desarrollador edita src/ -> allow"        allow guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a1"  "desarrollador"  'hola')"
check "qa-tester edita src/ -> deny"             deny  guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a2"  "qa-tester"      'hola')"
check "coordinadora edita doc fuera de app -> allow" allow guard-codigo.sh "$(emite_edit "$PROJ/docs/README.md" "" "" 'hola')"

echo "A3/A2 — guard-completado.sh (transición a completado):"
check "REQ -> en-progreso (no completado) -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: en-progreso')"
check "REQ -> completado, sin pendientes, gate ok -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: completado')"

# Con una aprobación pendiente -> debe denegar el completado (A2)
printf '## Pendientes\n### [2026-06-20] (qa) — algo\n- Contexto: x\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "REQ -> completado con aprobación pendiente -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: completado')"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"

# Con una quality gate que falla -> debe denegar (A3)
jq '.quality_gates = ["false"]' "$PROJ/.arnes/config.json" > "$PROJ/.arnes/config.json.tmp" && mv "$PROJ/.arnes/config.json.tmp" "$PROJ/.arnes/config.json"
check "REQ -> completado con quality gate roja -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: completado')"

echo "INERTE — sin manifiesto, el hook no estorba:"
PROJ2="$(mktemp -d)"; mkdir -p "$PROJ2/src"; export CLAUDE_PROJECT_DIR="$PROJ2"
check "sin .arnes/config.json edita src/ -> allow" allow guard-codigo.sh "$(jq -n --arg fp "$PROJ2/src/x.ts" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:"x",new_string:"y"}}')"
rm -rf "$PROJ2"

echo "-------------------------------------------"
echo "Resultado: $PASS PASS, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
