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

# mkreq <archivo> <sensible> <qa> <seguridad> — crea un REQ en disco con sus veredictos.
mkreq() {
  printf '# %s\nEstado: en-revisión\nSensible a seguridad: %s\nQA: %s\nSeguridad: %s\n' \
    "$(basename "$1" .md)" "$2" "$3" "$4" > "$1"
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

echo "Veredictos QA/Seguridad (anti-deriva):"
mkreq "$PROJ/requirements/REQ-010.md" "no" "pendiente" "n/a"
check "completado con QA: pendiente -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-010.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-011.md" "no" "aprobado" "n/a"
check "completado con QA: aprobado (no sensible) -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-011.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-012.md" "sí" "aprobado" "pendiente"
check "sensible + Seguridad: pendiente -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-012.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-013.md" "sí" "aprobado" "aprobado"
check "sensible + QA y Seguridad aprobados -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-013.md" "" "" 'Estado: completado')"

# Con una aprobación pendiente -> debe denegar el completado (A2)
printf '## Pendientes\n### [2026-06-20] (qa) — algo\n- Contexto: x\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "REQ -> completado con aprobación pendiente -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: completado')"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"

# Con una quality gate que falla -> debe denegar (A3)
jq '.quality_gates = ["false"]' "$PROJ/.arnes/config.json" > "$PROJ/.arnes/config.json.tmp" && mv "$PROJ/.arnes/config.json.tmp" "$PROJ/.arnes/config.json"
check "REQ -> completado con quality gate roja -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: completado')"

# --- Regresión Windows y formas del manifiesto (bugs hallados en SENDA, 2026-09-01) ---
echo "Regresión Windows / formas del manifiesto:"

# El manifiesto real de un proyecto declara objetos {nombre, comando}; la plantilla
# (templates/arnes-config.json.tpl) no fija la forma. El hook debe aceptar AMBAS.
setgates() { jq "$1" "$PROJ/.arnes/config.json" > "$PROJ/.arnes/c.tmp" && mv "$PROJ/.arnes/c.tmp" "$PROJ/.arnes/config.json"; }
setgates '.quality_gates = [{"nombre":"Verde","comando":"true"}]'
check "quality_gates como objetos, en verde -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: completado')"
setgates '.quality_gates = [{"nombre":"Roja","comando":"false"}]'
check "quality_gates como objetos, en rojo -> deny"   deny  guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: completado')"
setgates '.quality_gates = ["true"]'

# En Windows el file_path llega como `C:\proj\src\a.ts` mientras que la raíz del
# proyecto puede llegar en forma MSYS `/tmp/...`. Sin normalizar, la resta del
# prefijo deja la ruta absoluta, ningún glob casa y el hook PERMITE TODO.
if command -v cygpath >/dev/null 2>&1; then
  WPROJ="$(cygpath -w -- "$PROJ")"
  check "ruta estilo Windows con backslashes -> deny" deny guard-codigo.sh "$(emite_edit "${WPROJ}\src\app.ts" "" "" 'hola')"
fi

echo "INERTE — sin manifiesto, el hook no estorba:"
PROJ2="$(mktemp -d)"; mkdir -p "$PROJ2/src"; export CLAUDE_PROJECT_DIR="$PROJ2"
check "sin .arnes/config.json edita src/ -> allow" allow guard-codigo.sh "$(jq -n --arg fp "$PROJ2/src/x.ts" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:"x",new_string:"y"}}')"
rm -rf "$PROJ2"

echo "-------------------------------------------"
echo "Resultado: $PASS PASS, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
