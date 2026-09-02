#!/usr/bin/env bash
# Escenario de regresión de los hooks de enforcement del arnés (A1, A2, A3).
# Alimenta JSON de PreToolUse a los scripts reales y verifica deny/allow.
# No necesita Claude Code: prueba los scripts en aislamiento. Requiere jq.
#
# LECCIÓN GRABADA (2026-09-01): un caso verde que espera `allow` NO prueba nada por sí
# solo — también pasa cuando el hook ni siquiera llega a ejecutarse. Por eso este banco
# (a) arranca con un canario que exige un `deny` real antes de correr nada más, y
# (b) por cada arreglo añade su caso `deny`, no sólo el `allow` que lo acompaña.
set -uo pipefail

# ARNES_HOOKS_DIR permite apuntar a OTRA copia de los hooks: así se comprueba que un
# caso nuevo falla contra el código anterior (si pasa antes del arreglo, no prueba nada).
HOOKS_DIR="${ARNES_HOOKS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../hooks" && pwd)}"
PASS=0; FAIL=0

command -v jq >/dev/null 2>&1 || { echo "SKIP: jq no instalado"; exit 0; }

# --- proyecto de prueba efímero ---
PROJ="$(mktemp -d)"
trap 'rm -rf "$PROJ"' EXIT
mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src" "$PROJ/tests"
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

# emite_bash <comando> <agent_id> <agent_type>
emite_bash() {
  jq -n --arg cmd "$1" --arg aid "$2" --arg at "$3" \
    '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{command:$cmd}}
     + (if $aid!="" then {agent_id:$aid} else {} end)
     + (if $at!=""  then {agent_type:$at} else {} end)'
}

# mkreq <archivo> <sensible> <qa> <seguridad> — crea un REQ en disco con sus veredictos.
mkreq() {
  printf '# %s\nEstado: en-revisión\nSensible a seguridad: %s\nQA: %s\nSeguridad: %s\n' \
    "$(basename "$1" .md)" "$2" "$3" "$4" > "$1"
}

# setcfg <filtro jq> — muta el manifiesto del proyecto de prueba.
setcfg()   { jq "$1" "$PROJ/.arnes/config.json" > "$PROJ/.arnes/c.tmp" && mv "$PROJ/.arnes/c.tmp" "$PROJ/.arnes/config.json"; }
setgates() { setcfg "$1"; }

corre() { printf '%s' "$2" | "$HOOKS_DIR/$1" 2>/dev/null; }

# check <nombre> <esperado:deny|allow> <script> <json>
check() {
  local nombre="$1" esperado="$2" script="$3" json="$4" out got
  out="$(corre "$script" "$json")"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then got=deny; else got=allow; fi
  if [ "$got" = "$esperado" ]; then
    echo "  PASS  $nombre  ($got)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  esperado=$esperado got=$got"; FAIL=$((FAIL+1))
  fi
}

# check_motivo <nombre> <regex> <script> <json> — exige deny Y que el motivo lo explique.
# Un deny mudo, o que no nombre a quien lo intentó, es un bug de diagnóstico.
check_motivo() {
  local nombre="$1" patron="$2" script="$3" json="$4" out motivo
  out="$(corre "$script" "$json")"
  motivo="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // empty' 2>/dev/null)"
  if [ -n "$motivo" ] && printf '%s' "$motivo" | grep -Eq "$patron"; then
    echo "  PASS  $nombre"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  motivo=<${motivo:-vacío}> no casa /$patron/"; FAIL=$((FAIL+1))
  fi
}

# --- CANARIO: si el hook no corre, todo caso `allow` sería un verde falso -------
canario="$(corre guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "" "" 'hola')")"
if ! printf '%s' "$canario" | grep -Eq '"permissionDecision": *"deny"'; then
  echo "ABORT: el canario no denegó; el hook no se está ejecutando (¿CRLF? ¿jq? ¿permisos?)."
  echo "       Con el hook muerto, todos los casos 'allow' pasarían en falso."
  exit 1
fi

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
setgates '.quality_gates = ["false"]'
check "REQ -> completado con quality gate roja -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: completado')"

# --- Regresión Windows y formas del manifiesto (bugs hallados en SENDA, 2026-09-01) ---
echo "Regresión Windows / formas del manifiesto:"

# El manifiesto real de un proyecto declara objetos {nombre, comando}; la plantilla
# (templates/arnes-config.json.tpl) no fija la forma. El hook debe aceptar AMBAS.
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

# --- Regresión: identidad del agente (bug hallado en SENDA, 2026-09-02) --------
# Claude Code entrega `agent_type` con el prefijo del plugin (`arnes-juan:desarrollador`)
# y el manifiesto declara el nombre corto: la comparación cruda no casaba NUNCA, así que
# el guard denegaba justo al único agente autorizado a escribir código.
echo "Identidad del agente (prefijo del plugin):"
check "desarrollador CON prefijo de plugin -> allow" allow guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a3" "arnes-juan:desarrollador" 'hola')"
check "qa-tester CON prefijo de plugin -> deny"      deny  guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a4" "arnes-juan:qa-tester" 'hola')"
check_motivo "el deny sigue nombrando al agente de forma legible" "subagente 'qa-tester' \(arnes-juan:qa-tester\)" \
  guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a4" "arnes-juan:qa-tester" 'hola')"
check "agent_type con mayúsculas y espacios -> allow" allow guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a5" "  Arnes-Juan:Desarrollador " 'hola')"
# Sin `agent_id` es la coordinadora, diga lo que diga `agent_type`.
check "coordinadora que se declara desarrollador -> deny" deny guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "" "arnes-juan:desarrollador" 'hola')"
# Manifiesto con el nombre corto: no exige proveedor, porque el manifiesto no lo dijo.
check "otro-plugin:desarrollador con manifiesto sin prefijo -> allow" allow guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a6" "otro-plugin:desarrollador" 'hola')"

# Manifiesto que SÍ califica el proveedor: comparación estricta, opt-in del proyecto.
setcfg '.agentes.agente_codigo = "arnes-juan:desarrollador"'
check "manifiesto con prefijo + agent_type sin prefijo -> allow" allow guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a7" "desarrollador" 'hola')"
check "manifiesto con prefijo + mismo proveedor -> allow"        allow guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a8" "arnes-juan:desarrollador" 'hola')"
check "manifiesto con prefijo + otro proveedor -> deny"          deny  guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a9" "otro-plugin:desarrollador" 'hola')"
check "manifiesto con prefijo + coordinadora -> deny"            deny  guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" ""   "" 'hola')"
setcfg '.agentes.agente_codigo = "desarrollador"'

# --- Regresión: cobertura PARCIAL de Bash (hueco hallado en SENDA, 2026-09-02) -
# Un agente rechazado en `Edit` escribió el archivo con `cat > ...` y el guard ni se
# enteró: `Bash` no estaba en el matcher. La cobertura nueva es parcial a propósito;
# lo que NO se negocia es que no dispare sobre comandos de lectura.
echo "Bash — escrituras evidentes (cobertura parcial):"
check "coordinadora: redirección a código -> deny"      deny guard-codigo.sh "$(emite_bash 'cat > src/app.ts <<< "export const x = 1;"' "" "")"
check "coordinadora: >> pegado al archivo -> deny"      deny guard-codigo.sh "$(emite_bash 'echo x >>src/app.ts' "" "")"
check "coordinadora: ruta absoluta del proyecto -> deny" deny guard-codigo.sh "$(emite_bash "echo x > $PROJ/src/app.ts" "" "")"
check "coordinadora: tee sobre código -> deny"          deny guard-codigo.sh "$(emite_bash 'echo x | tee src/app.ts' "" "")"
check "coordinadora: sed -i sobre código -> deny"       deny guard-codigo.sh "$(emite_bash "sed -i 's/a/b/' src/app.ts" "" "")"
check "coordinadora: cp a directorio de código -> deny" deny guard-codigo.sh "$(emite_bash 'cp /tmp/x.ts src/' "" "")"
check "coordinadora: mv a directorio de código -> deny" deny guard-codigo.sh "$(emite_bash 'mv /tmp/x.ts src' "" "")"
check "coordinadora: escritura en la segunda orden encadenada -> deny" deny guard-codigo.sh "$(emite_bash 'npm run build && echo listo > app/gen.ts' "" "")"
check_motivo "el deny por Bash admite que la cobertura es parcial" "parcial" \
  guard-codigo.sh "$(emite_bash 'echo x > src/app.ts' "" "")"
check "desarrollador (con prefijo) escribe por Bash -> allow" allow guard-codigo.sh "$(emite_bash 'echo x > src/app.ts' "a10" "arnes-juan:desarrollador")"

echo "Bash — lo que NO debe denegar (falsos positivos):"
check "coordinadora: cat de lectura -> allow"        allow guard-codigo.sh "$(emite_bash 'cat src/app.ts' "" "")"
check "coordinadora: grep recursivo -> allow"        allow guard-codigo.sh "$(emite_bash 'grep -rn foo src/ | head -20' "" "")"
check "coordinadora: sed sin -i -> allow"            allow guard-codigo.sh "$(emite_bash "sed -n '1,20p' src/app.ts" "" "")"
check "coordinadora: la ruta sólo se menciona en un mensaje -> allow" allow guard-codigo.sh "$(emite_bash 'git commit -m "arregla src/app.ts > listo"' "" "")"
check "coordinadora: lee código y escribe fuera -> allow" allow guard-codigo.sh "$(emite_bash 'cp src/app.ts /tmp/copia.ts' "" "")"
check "coordinadora: redirige un log fuera de los globs -> allow" allow guard-codigo.sh "$(emite_bash 'npm run build > /tmp/build.log 2>&1' "" "")"
check "qa-tester escribe en tests/ (no es código de app) -> allow" allow guard-codigo.sh "$(emite_bash 'echo x > tests/a.test.ts' "a11" "arnes-juan:qa-tester")"

echo "INERTE — sin manifiesto, el hook no estorba:"
PROJ2="$(mktemp -d)"; mkdir -p "$PROJ2/src"; export CLAUDE_PROJECT_DIR="$PROJ2"
check "sin .arnes/config.json edita src/ -> allow" allow guard-codigo.sh "$(jq -n --arg fp "$PROJ2/src/x.ts" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:"x",new_string:"y"}}')"
check "sin .arnes/config.json escribe por Bash -> allow" allow guard-codigo.sh "$(emite_bash 'echo x > src/x.ts' "" "")"
rm -rf "$PROJ2"

echo "-------------------------------------------"
echo "Resultado: $PASS PASS, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
