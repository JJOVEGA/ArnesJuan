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
TPL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../templates" && pwd)"
PASS=0; FAIL=0
# Filtro opcional: `run.sh bash` corre solo los casos cuyo nombre lo contenga.
# Existe porque una vuelta completa cuesta ~8 min en Windows, y un ciclo de
# verificacion caro es lo que empuja a saltarse la suite.
FILTRO="${1:-}"

command -v jq >/dev/null 2>&1 || { echo "SKIP: jq no instalado"; exit 0; }

# --- proyecto de prueba efímero ---
PROJ="$(mktemp -d)"
# Un archivo fijo, reutilizado: capturar stderr no debe costar un fork por llamada.
ERRLOG="$(mktemp)"
trap 'rm -rf "$PROJ"; rm -f "$ERRLOG"' EXIT
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

# mkreq <archivo> <sensible> <qa> <seguridad> [hallazgos] — crea un REQ en disco.
mkreq() {
  printf '# %s\nEstado: en-revisión\nSensible a seguridad: %s\nQA: %s\nSeguridad: %s\n' \
    "$(basename "$1" .md)" "$2" "$3" "$4" > "$1"
  if [ -n "${5:-}" ]; then printf 'Hallazgos abiertos: %s\n' "$5" >> "$1"; fi
  return 0
}

# mkreq_r <nombre> <sensible> <qa> <seguridad> <rigor> — REQ con nivel de rigor.
mkreq_r() {
  { printf '# %s
Estado: en-revisión
' "$1"
    [ -n "$2" ] && printf 'Sensible a seguridad: %s
' "$2"
    [ -n "$3" ] && printf 'QA: %s
' "$3"
    [ -n "$4" ] && printf 'Seguridad: %s
' "$4"
    [ -n "$5" ] && printf 'Rigor: %s
' "$5"
  } > "$PROJ/requirements/$1.md"
  return 0
}

# setcfg <filtro jq> — muta el manifiesto del proyecto de prueba.
setcfg()   { jq "$1" "$PROJ/.arnes/config.json" > "$PROJ/.arnes/c.tmp" && mv "$PROJ/.arnes/c.tmp" "$PROJ/.arnes/config.json"; }
setgates() { setcfg "$1"; }

# stderr NO se descarta: se aparta para poder enseñarlo cuando algo falla.
corre() { : > "$ERRLOG"; printf '%s' "$2" | "$HOOKS_DIR/$1" 2>"$ERRLOG"; }
# diagnostico: lo que el hook escribio en stderr, si escribio algo.
diag() { [ -s "$ERRLOG" ] && sed 's/^/          stderr| /' "$ERRLOG"; return 0; }

# check <nombre> <esperado:deny|allow> <script> <json>
check() {
  local nombre="$1" esperado="$2" script="$3" json="$4" out got
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  out="$(corre "$script" "$json")"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then got=deny; else got=allow; fi
  if [ "$got" = "$esperado" ]; then
    echo "  PASS  $nombre  ($got)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  esperado=$esperado got=$got"; diag; FAIL=$((FAIL+1))
  fi
}

# check_motivo <nombre> <regex> <script> <json> — exige deny Y que el motivo lo explique.
# Un deny mudo, o que no nombre a quien lo intentó, es un bug de diagnóstico.
check_motivo() {
  local nombre="$1" patron="$2" script="$3" json="$4" out motivo
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  out="$(corre "$script" "$json")"
  motivo="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // empty' 2>/dev/null)"
  if [ -n "$motivo" ] && printf '%s' "$motivo" | grep -Eq "$patron"; then
    echo "  PASS  $nombre"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  motivo=<${motivo:-vacío}> no casa /$patron/"; diag; FAIL=$((FAIL+1))
  fi
}

# --- CANARIO: si el hook no corre, todo caso `allow` sería un verde falso -------
canario="$(corre guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "" "" 'hola')")"
if ! printf '%s' "$canario" | grep -Eq '"permissionDecision": *"deny"'; then
  echo "ABORT: el canario no denegó; el hook no se está ejecutando."
  echo "       Con el hook muerto, todos los casos 'allow' pasarían en falso."
  # Un aborto sin evidencia obliga a adivinar, y adivinar fue lo que nos costó un día:
  # se relanza UNA vez enseñando todo lo que el primer intento se calló.
  echo "       --- evidencia del intento ---"
  diag
  echo "       salida: <$canario>"
  printf '%s' "$(emite_edit "$PROJ/src/app.ts" "" "" 'hola')" | "$HOOKS_DIR/guard-codigo.sh" > /dev/null
  echo "       rc del hook en un 2º intento: $?"
  echo "       hook: $HOOKS_DIR/guard-codigo.sh"
  ls -l "$HOOKS_DIR/guard-codigo.sh" 2>&1 | sed 's/^/       /'
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

# --- Clase del hallazgo: la unica puerta que existe para DEJAR PASAR ------------
# Un defecto del propio arnes no puede impedir cerrar una funcion de negocio.
echo "Clase del hallazgo:"
mkreq "$PROJ/requirements/REQ-020.md" "no" "aprobado" "n/a" "SEC-1 (instrumento)"
check "hallazgo de instrumento -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-020.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-021.md" "no" "aprobado" "n/a" "SEC-2 (usuario/dinero)"
check "hallazgo de usuario/dinero -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-021.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-022.md" "no" "aprobado" "n/a" "SEC-3 (contrato)"
check "hallazgo de contrato -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-022.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-023.md" "no" "aprobado" "n/a" "SEC-4"
check "hallazgo SIN clase -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-023.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-024.md" "no" "aprobado" "n/a" "SEC-5 (instrumento), SEC-6 (usuario/dinero)"
check "mezcla: basta uno bloqueante -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-024.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-025.md" "no" "aprobado" "n/a" "(ninguno)"
check "sin hallazgos abiertos -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-025.md" "" "" 'Estado: completado')"
# Compatibilidad: un REQ anterior a este campo no puede quedar bloqueado por el.
mkreq "$PROJ/requirements/REQ-026.md" "no" "aprobado" "n/a"
check "REQ antiguo sin el campo -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-026.md" "" "" 'Estado: completado')"

# --- Cierre de un REQ por Bash: se DERIVA a Edit/Write -------------------------
# Era la limitacion conocida de la version anterior: `guard-completado` no miraba
# Bash, asi que un `sed -i` cerraba un REQ sin que ninguna puerta lo evaluara.
echo "Cierre de REQ por Bash (guard-completado):"
check "sed -i que cierra un REQ -> deny" deny guard-completado.sh \
  "$(emite_bash "sed -i 's/en-revision/completado/' requirements/REQ-001.md" "" "")"
check "heredoc que cierra un REQ -> deny" deny guard-completado.sh \
  "$(emite_bash "cat > requirements/REQ-001.md <<'FIN'
Estado: completado
FIN" "" "")"
# Frontera: mencionar el estado NO basta, hace falta escribir en el REQ.
check "leer un REQ que menciona completado -> allow" allow guard-completado.sh \
  "$(emite_bash "grep -n 'completado' requirements/REQ-001.md" "" "")"
check "anotar en un REQ sin cerrarlo -> allow" allow guard-completado.sh \
  "$(emite_bash "echo 'nota de trabajo' >> requirements/REQ-001.md" "" "")"
check "escribir fuera de requirements/ -> allow" allow guard-completado.sh \
  "$(emite_bash "echo completado > notas.txt" "" "")"

# --- Arranque limpio: la plantilla de PENDING no puede bloquear ----------------
# El ejemplo de formato vivia COMENTADO bajo `## Pendientes`; el conteo lo leia
# como 1 pendiente y un proyecto recien inicializado no cerraba ningun REQ.
echo "Arranque limpio — plantilla de PENDING_APPROVAL:"
cp "$TPL_DIR/PENDING_APPROVAL.md.tpl" "$PROJ/PENDING_APPROVAL.md"
check "PENDING recien copiado de la plantilla -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: completado')"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"

# --- El punto de entrada REAL: guard.sh ----------------------------------------
# Los bloques de arriba prueban cada guardian por separado, que es como se
# desarrollan. Pero `hooks.json` invoca `guard.sh`, que los corre a los DOS en un
# solo proceso. Sin estos casos, el banco validaria algo distinto de lo que
# realmente se ejecuta — y en este arnes un hueco asi no se nota: falla abierto.
#
# El riesgo concreto que cubren: dentro de `guard.sh` los guardianes son
# funciones, y si alguna dijera "permito" con `exit 0` en vez de `return 0`,
# mataria el proceso y el segundo NUNCA correria. Por eso hay casos que exigen
# denegacion del SEGUNDO guardian pasando por el primero.
# --- Nivel de rigor: cuanta ceremonia paga cada REQ ----------------------------
# La compatibilidad es lo que mas importa aqui: un REQ que NO declara `Rigor:`
# debe juzgarse EXACTAMENTE como antes de que los niveles existieran. Si eso se
# rompiera, un proyecto sin migrar cambiaria de comportamiento sin avisar.
echo "Nivel de rigor:"
mkreq_r "REQ-040" "no" "pendiente" "n/a" ""
check "sin Rigor + QA pendiente -> deny (como siempre)" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-040.md" "" "" 'Estado: completado')"
mkreq_r "REQ-041" "sí" "aprobado" "pendiente" ""
check "sin Rigor + sensible sin seguridad -> deny (como siempre)" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-041.md" "" "" 'Estado: completado')"
mkreq_r "REQ-042" "no" "pendiente" "n/a" "ligero"
check "LIGERO no exige veredictos -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-042.md" "" "" 'Estado: completado')"
mkreq_r "REQ-043" "no" "pendiente" "n/a" "estandar"
check "estandar exige QA -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-043.md" "" "" 'Estado: completado')"
mkreq_r "REQ-044" "no" "aprobado" "pendiente" "critico"
check "critico exige seguridad -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-044.md" "" "" 'Estado: completado')"
mkreq_r "REQ-045" "no" "aprobado" "aprobado" "critico"
check "critico con QA y seguridad -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-045.md" "" "" 'Estado: completado')"
# EL SUELO: declarar un nivel menor sobre un REQ sensible NO lo baja.
mkreq_r "REQ-046" "sí" "pendiente" "n/a" "ligero"
check "ligero sobre SENSIBLE no baja el suelo -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-046.md" "" "" 'Estado: completado')"
mkreq_r "REQ-047" "sí" "aprobado" "pendiente" "estandar"
check "estandar sobre SENSIBLE no baja el suelo -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-047.md" "" "" 'Estado: completado')"
# Un valor inventado nunca debe abrir la puerta.
mkreq_r "REQ-048" "no" "pendiente" "n/a" "inventado"
check "Rigor invalido se ignora, no abre -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-048.md" "" "" 'Estado: completado')"

# --- Orden del ciclo: seguridad no firma lo que QA no ha validado --------------
# La regla ya estaba en AGENTS.md 6; lo que faltaba era que se cumpliera. Corre en
# CUALQUIER edicion del REQ, no solo al cerrarlo: el dano se hace al escribir el
# veredicto, no al cierre.
echo "Orden del ciclo (seguridad tras QA):"
mkreq_r "REQ-050" "no" "pendiente" "pendiente" ""
check "firmar Seguridad con QA pendiente -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-050.md" "" "" 'Seguridad: aprobado')"
check "...y tampoco al cerrar de paso -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-050.md" "" "" 'Estado: completado
Seguridad: aprobado')"
# La excepcion se declara AL EMITIRLA, no al invocarla.
check "auditoria PREVENTIVA declarada -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-050.md" "" "" 'Seguridad: aprobado (preventiva)')"
mkreq_r "REQ-051" "no" "aprobado" "pendiente" ""
check "orden correcto: QA ya aprobado -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-051.md" "" "" 'Seguridad: aprobado')"
mkreq_r "REQ-052" "no" "pendiente" "pendiente" ""
check "edicion que NO toca Seguridad -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-052.md" "" "" 'Notas: trabajo en curso')"
# Un REQ anterior al campo QA no puede quedar bloqueado por esto.
mkreq_r "REQ-053" "no" "" "pendiente" ""
check "REQ antiguo sin campo QA -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-053.md" "" "" 'Seguridad: aprobado')"
# La firma preventiva desbloquea el ORDEN, no el CIERRE: se emitio antes de que
# existiera el codigo, luego no acredita el codigo. Un REQ critico sigue exigiendo
# la auditoria de verdad.
mkreq_r "REQ-054" "sí" "aprobado" "aprobado (preventiva)" ""
check "critico: solo firma preventiva no cierra -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-054.md" "" "" 'Estado: completado')"
mkreq_r "REQ-055" "sí" "aprobado" "aprobado" ""
check "critico: auditoria real si cierra -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-055.md" "" "" 'Estado: completado')"
# Sin esto la regla del orden seria un abrazo mortal: QA firma primero, siempre.
mkreq_r "REQ-056" "sí" "pendiente" "pendiente" ""
check "sensible: QA firma sin esperar a seguridad -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-056.md" "" "" 'QA: aprobado')"

# --- Formas DECORADAS: el banco escribia siempre limpio -----------------------
# LECCION (2026-09-04): un proyecto real declaraba `Sensible a seguridad: **si**`
# en siete REQ y NINGUNO casaba -- la puerta de seguridad no llegaba a existir para
# ellos. El banco no lo vio porque escribe sus propios REQ y los escribe limpios:
# veinticuatro fixtures y solo dos valores, "si" y "no".
#
# Es EL MISMO diagnostico que quedo escrito en 1.16.0 sobre otro campo --"el banco
# no lo veia porque escribia su propio archivo limpio, nunca la plantilla"-- y
# reaparecio porque entonces se arreglo el CASO y no el BANCO. Por eso ahora cada
# campo que se compara contra una forma cerrada tiene su fixture decorado, con sus
# controles negativos: probar que no se estorba a quien escribe `no` es lo que da
# valor a los `deny`.
echo "Formas decoradas (marcado de Markdown en el valor):"
mkreq "$PROJ/requirements/REQ-060.md" "**sí**" "aprobado" "pendiente"
check "sensible en **negrita** exige auditoria -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-060.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-061.md" "**sí** — toca autenticación" "aprobado" "pendiente"
check "negrita + comentario tras el valor -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-061.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-062.md" "sí — gobierna la puerta" "aprobado" "pendiente"
check "comentario tras el valor, sin negrita -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-062.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-063.md" "_sí_" "aprobado" "pendiente"
check "sensible en _cursiva_ -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-063.md" "" "" 'Estado: completado')"
# El tercer estado: un valor que no se entiende cae del lado seguro. Sin esto, la
# lista de formas reconocidas seria una lista enumerada, y esas se pudren.
mkreq "$PROJ/requirements/REQ-064.md" "por evaluar" "aprobado" "pendiente"
check "valor que NO se entiende -> deny (lado seguro)" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-064.md" "" "" 'Estado: completado')"
check_motivo "...y la denegacion dice por que" "no se reconoce" guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-064.md" "" "" 'Estado: completado')"
# Controles negativos: el arnes NO puede estorbar a quien declara que no es sensible.
mkreq "$PROJ/requirements/REQ-065.md" "**no**" "aprobado" "pendiente"
check "no sensible en **negrita** -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-065.md" "" "" 'Estado: completado')"
# El conjunto que ABRE la puerta es minimo: solo una negacion explicita. `n/a` y
# `ninguna` son lo que se escribe cuando NO se ha clasificado, no cuando se ha
# decidido que no es sensible -- le abrian un hueco al fallo cerrado justo en el
# caso para el que se construyo. Lo delataba una asimetria: `n/a` abria y
# `no aplica`, la misma frase, cerraba. Ahora coinciden, y ninguna abre.
mkreq "$PROJ/requirements/REQ-066.md" "n/a" "aprobado" "pendiente"
check "'n/a' no abre la puerta -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-066.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-072.md" "no aplica" "aprobado" "pendiente"
check "...y 'no aplica' dice lo mismo -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-072.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-073.md" "ninguna" "aprobado" "pendiente"
check "'ninguna' tampoco abre -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-073.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-067.md" "no — es solo texto" "aprobado" "pendiente"
check "no + comentario tras el valor -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-067.md" "" "" 'Estado: completado')"
# Los otros campos tambien se comparan contra forma cerrada, y tambien se decoran.
mkreq "$PROJ/requirements/REQ-068.md" "no" "**aprobado**" "n/a"
check "QA en **negrita** cuenta como aprobado -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-068.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-069.md" "sí" "aprobado" "**aprobado**"
check "Seguridad en **negrita** cierra un critico -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-069.md" "" "" 'Estado: completado')"
# Y la firma PREVENTIVA sigue sin cerrar aunque venga decorada: quitar el marcado
# no puede convertirla en una firma completa. Es el fallo que el arreglo obvio
# --cortar el valor en el primer parentesis-- habria introducido.
mkreq "$PROJ/requirements/REQ-070.md" "sí" "aprobado" "**aprobado (preventiva)**"
check "preventiva decorada TAMPOCO cierra -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-070.md" "" "" 'Estado: completado')"
mkreq_r "REQ-071" "no" "pendiente" "n/a" "**ligero**"
check "Rigor **ligero** decorado se reconoce -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-071.md" "" "" 'Estado: completado')"

echo "guard.sh — punto de entrada unico (los dos guardianes, un proceso):"
check "A1 por guard.sh: coordinadora edita src/ -> deny" deny guard.sh \
  "$(emite_edit "$PROJ/src/app.ts" "" "" 'hola')"
check "A1 por guard.sh: desarrollador edita src/ -> allow" allow guard.sh \
  "$(emite_edit "$PROJ/src/app.ts" "a1" "arnes-juan:desarrollador" 'hola')"
check "A1 por guard.sh: edicion neutra -> allow" allow guard.sh \
  "$(emite_edit "$PROJ/docs/nota.md" "" "" 'hola')"
# CRITICO: el primer guardian permite y el SEGUNDO debe seguir juzgando.
mkreq "$PROJ/requirements/REQ-030.md" "no" "pendiente" "n/a"
check "guard.sh: el 2o guardian sigue corriendo tras el 1o -> deny" deny guard.sh \
  "$(emite_edit "$PROJ/requirements/REQ-030.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-031.md" "no" "aprobado" "n/a"
check "guard.sh: cierre limpio -> allow" allow guard.sh \
  "$(emite_edit "$PROJ/requirements/REQ-031.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-032.md" "sí" "aprobado" "pendiente"
check "guard.sh: sensible sin seguridad -> deny" deny guard.sh \
  "$(emite_edit "$PROJ/requirements/REQ-032.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-033.md" "no" "aprobado" "n/a" "SEC-9 (instrumento)"
check "guard.sh: hallazgo de instrumento -> allow" allow guard.sh \
  "$(emite_edit "$PROJ/requirements/REQ-033.md" "" "" 'Estado: completado')"
check "guard.sh: Bash escribe en src/ -> deny" deny guard.sh \
  "$(emite_bash "echo x > src/app.ts" "" "")"
check "guard.sh: Bash cierra un REQ -> deny" deny guard.sh \
  "$(emite_bash "sed -i 's/en-revision/completado/' requirements/REQ-031.md" "" "")"
check "guard.sh: Bash de lectura -> allow" allow guard.sh \
  "$(emite_bash "grep -rn foo src/" "" "")"

# --- El asterisco de NOTA AL PIE no es enfasis --------------------------------
# El arreglo de 1.21.0 retiraba todo `*`, y eso convertia `Seguridad: aprobado*`
# en `aprobado`: un asterisco tras una firma es una llamada a nota al pie, y una
# nota al pie apunta a una SALVEDAD -- lo contrario de una firma incondicional.
#
# Fue el mismo error girado: el argumento se hizo sobre `Sensible a seguridad:`
# --donde `**si**` si es el mismo valor-- y el cambio se aplico a los cinco
# campos. El sujeto del arreglo era mas estrecho que su poblacion.
#
# El enfasis de Markdown es PAREADO por definicion: solo se retira cuando envuelve
# el valor entero. Un asterisco suelto nunca envuelve nada.
echo "Asterisco de nota al pie (una salvedad no es una firma):"
mkreq "$PROJ/requirements/REQ-074.md" "sí" "aprobado" "aprobado*"
check "'aprobado*' NO cierra un critico -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-074.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-075.md" "sí" "aprobado" "*aprobado"
check "'*aprobado' tampoco -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-075.md" "" "" 'Estado: completado')"
# Control positivo: el enfasis PAREADO si se retira, o el arreglo habria roto lo
# que 1.21.0 vino a arreglar.
mkreq "$PROJ/requirements/REQ-076.md" "sí" "aprobado" "*aprobado*"
check "'*aprobado*' pareado si cierra -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-076.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-077.md" "**sí**" "aprobado" "pendiente"
check "y '**sí**' sigue exigiendo auditoria -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-077.md" "" "" 'Estado: completado')"

# --- Continuidad automatica: el bloque DERIVADO de ESTADO.md -------------------
# Este hook no decide nada (no hay deny/allow que mirar): escribe un archivo. Asi
# que se comprueba por CONTENIDO, que es la misma regla que el arnes aplica a todo
# lo demas -- se acredita por lo que quedo escrito, no porque el comando dijera
# que si.
#
# Lo que hay que fijar, por orden de dano si se rompe:
#   1. que NO estorbe donde no le llaman (sin manifiesto, repo ajeno)
#   2. que NUNCA falle (un hook Stop que falla deja la sesion colgada)
#   3. que no pise lo que escribio una persona
#   4. que correrlo dos veces de lo mismo
echo "Continuidad automatica (hook Stop -> bloque derivado):"

EST_PROJ="$(mktemp -d)"
mkdir -p "$EST_PROJ/.arnes" "$EST_PROJ/requirements" "$EST_PROJ/docs"
cp "$PROJ/.arnes/config.json" "$EST_PROJ/.arnes/config.json"
printf '## Pendientes\n- decidir el proveedor\n- aprobar el borrado\n\n## Resueltas\n- otra\n' > "$EST_PROJ/PENDING_APPROVAL.md"
printf '# REQ-001\nEstado: completado\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n' > "$EST_PROJ/requirements/REQ-001.md"
printf '# REQ-002\nEstado: en-revisión\nSensible a seguridad: **sí**\nQA: con-hallazgos\nSeguridad: pendiente\n' > "$EST_PROJ/requirements/REQ-002.md"
printf '# Los REQ\nEste README no es un REQ y no debe contarse.\n' > "$EST_PROJ/requirements/README.md"
printf '# ESTADO\n\n## Fase actual\nESTO LO ESCRIBIO UNA PERSONA.\n' > "$EST_PROJ/docs/ESTADO.md"

# corre_estado <dir-proyecto> -> ejecuta el hook Stop contra ese proyecto
corre_estado() {
  local d="$1" json
  json="$(CLAUDE_PROJECT_DIR="$d" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')"
  : > "$ERRLOG"
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$d" "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>"$ERRLOG"
}
# check_estado <nombre> <patron-grep> <si|no: debe aparecer> <archivo>
check_estado() {
  local nombre="$1" patron="$2" debe="$3" archivo="$4" hay=no
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  [ -f "$archivo" ] && grep -q -- "$patron" "$archivo" && hay=si
  if [ "$hay" = "$debe" ]; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  esperaba aparece=$debe, fue=$hay"; diag; FAIL=$((FAIL+1)); fi
}

corre_estado "$EST_PROJ"; EST_RC=$?
if [ "$EST_RC" -eq 0 ]; then echo "  PASS  el hook sale 0 (no bloquea la parada)"; PASS=$((PASS+1))
else echo "  FAIL  el hook salio $EST_RC: una parada bloqueada es peor que no tener el bloque"; diag; FAIL=$((FAIL+1)); fi

check_estado "escribe el bloque derivado"          "ARNES:DERIVADO inicio"  si "$EST_PROJ/docs/ESTADO.md"
check_estado "no pisa lo que escribio una persona" "ESTO LO ESCRIBIO UNA"   si "$EST_PROJ/docs/ESTADO.md"
check_estado "cuenta los REQ, no el README"        "REQ:\*\* 2"             si "$EST_PROJ/docs/ESTADO.md"
check_estado "lee la cola de aprobaciones"         "pendientes:\*\* 2"      si "$EST_PROJ/docs/ESTADO.md"
# El REQ-002 dice `**si**`: desde 1.21.0 su rigor efectivo es critico, y el bloque
# derivado lo ENSEÑA. Es la utilidad de mostrar los valores como los lee la maquina.
check_estado "el bloque delata el rigor efectivo"  "critico"                si "$EST_PROJ/docs/ESTADO.md"
# Sin repositorio el estado del arbol es DESCONOCIDO. Decir "limpio" o "con cambios"
# seria afirmar un hecho que no se tiene.
check_estado "arbol sin repo -> desconocido, no inventado" "desconocido"    si "$EST_PROJ/docs/ESTADO.md"

corre_estado "$EST_PROJ"
EST_N="$(grep -c 'ARNES:DERIVADO inicio' "$EST_PROJ/docs/ESTADO.md")"
if [ "$EST_N" = "1" ]; then echo "  PASS  idempotente: dos pasadas, un solo bloque"; PASS=$((PASS+1))
else echo "  FAIL  idempotente: hay $EST_N bloques tras dos pasadas"; FAIL=$((FAIL+1)); fi

# Apagable: quien no lo quiera, lo apaga.
EST_OFF="$(mktemp -d)"; mkdir -p "$EST_OFF/.arnes" "$EST_OFF/requirements" "$EST_OFF/docs"
jq '.estado_derivado.activo = false' "$PROJ/.arnes/config.json" > "$EST_OFF/.arnes/config.json"
corre_estado "$EST_OFF"
check_estado "con activo:false no escribe" "ARNES:DERIVADO" no "$EST_OFF/docs/ESTADO.md"

# INERTE en un repo ajeno: sin manifiesto no se toca nada. Es la invariante que
# permite instalar el plugin sin que estorbe fuera de un proyecto del arnes.
EST_AJENO="$(mktemp -d)"; mkdir -p "$EST_AJENO/docs"
printf '# El ESTADO de OTRO proyecto\n' > "$EST_AJENO/docs/ESTADO.md"
corre_estado "$EST_AJENO"; EST_RC=$?
check_estado "sin manifiesto no escribe (repo ajeno)" "ARNES:DERIVADO" no "$EST_AJENO/docs/ESTADO.md"
if [ "$EST_RC" -eq 0 ]; then echo "  PASS  sin manifiesto tambien sale 0"; PASS=$((PASS+1))
else echo "  FAIL  sin manifiesto salio $EST_RC"; FAIL=$((FAIL+1)); fi

# Sin la carpeta destino no se inventa: crear `docs/` en un proyecto que no la tiene
# seria decidir su estructura, y eso no le toca al arnes.
EST_SIN="$(mktemp -d)"; mkdir -p "$EST_SIN/.arnes" "$EST_SIN/requirements"
cp "$PROJ/.arnes/config.json" "$EST_SIN/.arnes/config.json"
corre_estado "$EST_SIN"
if [ ! -e "$EST_SIN/docs" ]; then echo "  PASS  sin la carpeta destino no la inventa"; PASS=$((PASS+1))
else echo "  FAIL  creo docs/ en un proyecto que no la tenia"; FAIL=$((FAIL+1)); fi

rm -rf "$EST_PROJ" "$EST_OFF" "$EST_AJENO" "$EST_SIN"

# --- Rotacion de artefactos: una bitacora no crece sin tope --------------------
# Medido en un proyecto real: el CHANGELOG.md llego a 1,17 MB, del orden de 300.000
# tokens que entran en la ventana cada vez que alguien lo lee.
#
# Estos casos existen porque los DOS fallos de este hook los encontro una prueba
# desechable de scratchpad, no una lectura del codigo: la comprobacion con `case`
# --que fallaba siempre porque `## [1.20.0]` lleva corchetes, y en un patron de
# `case` los corchetes son una clase de caracteres-- y el conteo invertido, que
# conservaba `total - conservar` y vaciaba el archivo a trozos en cada pasada.
# Una prueba que encuentra un fallo y luego se tira no protege de nada manana.
echo "Rotacion de artefactos (mover, nunca resumir):"

# rot_proj <conservar> <umbral> <activo> <orden> -> deja la ruta en ROT_P
rot_proj() {
  ROT_P="$(mktemp -d)"; mkdir -p "$ROT_P/.arnes"
  jq -n --argjson c "$1" --argjson u "$2" --argjson a "$3" --arg o "$4" \
    '{agentes:{agente_codigo:"desarrollador"},
      rotacion:{activo:$a, umbral_bytes:$u, conservar_secciones:$c, orden:$o,
                artefactos:["CHANGELOG.md"]}}' > "$ROT_P/.arnes/config.json"
  { printf '# CHANGELOG\n\n> PREAMBULO DE UNA PERSONA.\n\n'
    for v in 10 9 8 7 6 5 4 3 2 1; do
      printf '## [1.%s.0]\n' "$v"
      for i in 1 2 3 4 5 6; do printf 'relleno %s de 1.%s.0 para que el archivo pese lo suyo\n' "$i" "$v"; done
      printf '\n'
    done
  } > "$ROT_P/CHANGELOG.md"
}
rot_corre() {
  local d="$1" json
  json="$(CLAUDE_PROJECT_DIR="$d" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
  : > "$ERRLOG"
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$d" "$HOOKS_DIR/rotar-artefactos.sh" >/dev/null 2>"$ERRLOG"
}
rot_sec() { grep -c '^## ' "$1" 2>/dev/null || echo 0; }
# rot_check <nombre> <esperado> <obtenido>
rot_check() {
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=$2 obtenido=$3"; diag; FAIL=$((FAIL+1)); fi
}

# Apagada: instalar el plugin no puede reestructurar el documento de nadie.
rot_proj 3 2000 false nuevo-primero
rot_corre "$ROT_P"
rot_check "apagada por defecto no toca nada" "10-no" "$(rot_sec "$ROT_P/CHANGELOG.md")-$([ -e "$ROT_P/CHANGELOG-archivo.md" ] && echo si || echo no)"
rm -rf "$ROT_P"

# Bajo el umbral tampoco: no se rota por rotar.
rot_proj 3 999999 true nuevo-primero
rot_corre "$ROT_P"
rot_check "bajo el umbral no toca nada" "10" "$(rot_sec "$ROT_P/CHANGELOG.md")"
rm -rf "$ROT_P"

# Conserva EXACTAMENTE lo declarado. Es el conteo que estaba invertido.
rot_proj 3 2000 true nuevo-primero
rot_corre "$ROT_P"; ROT_RC=$?
rot_check "conserva exactamente conservar_secciones" "3" "$(rot_sec "$ROT_P/CHANGELOG.md")"
rot_check "nada se pierde: origen + archivo = total" "10" \
  "$(( $(rot_sec "$ROT_P/CHANGELOG.md") + $(rot_sec "$ROT_P/CHANGELOG-archivo.md") ))"
rot_check "conserva LAS NUEVAS, no las viejas" "1" "$(grep -c '^## \[1\.10\.0\]' "$ROT_P/CHANGELOG.md")"
rot_check "no pisa el preambulo de una persona" "1" "$(grep -c 'PREAMBULO DE UNA PERSONA' "$ROT_P/CHANGELOG.md")"
rot_check "deja el puntero al archivo" "1" "$(grep -c 'CHANGELOG-archivo.md' "$ROT_P/CHANGELOG.md")"
rot_check "el hook sale 0 (no bloquea la parada)" "0" "$ROT_RC"
# Idempotencia: la primera version volvia a rotar en cada pasada.
rot_corre "$ROT_P"; rot_corre "$ROT_P"
rot_check "idempotente: tres pasadas, mismo reparto" "3-7" \
  "$(rot_sec "$ROT_P/CHANGELOG.md")-$(rot_sec "$ROT_P/CHANGELOG-archivo.md")"
rm -rf "$ROT_P"

# El orden se DECLARA. Con `nuevo-al-final` se conserva la otra mitad.
rot_proj 3 2000 true nuevo-al-final
rot_corre "$ROT_P"
rot_check "orden nuevo-al-final conserva el final" "1" "$(grep -c '^## \[1\.1\.0\]' "$ROT_P/CHANGELOG.md")"
rot_check "...y archiva el principio" "1" "$(grep -c '^## \[1\.10\.0\]' "$ROT_P/CHANGELOG-archivo.md")"
rm -rf "$ROT_P"

# Sin encabezados no hay limite seguro: no se corta a media entrada.
rot_proj 3 2000 true nuevo-primero
{ printf '# CHANGELOG sin secciones\n'; for i in $(seq 1 200); do printf 'linea larga de relleno numero %s en un archivo sin ningun encabezado de nivel dos\n' "$i"; done; } > "$ROT_P/CHANGELOG.md"
ROT_ANTES="$(wc -c < "$ROT_P/CHANGELOG.md")"
rot_corre "$ROT_P"
rot_check "sin encabezados no corta nada" "$ROT_ANTES" "$(wc -c < "$ROT_P/CHANGELOG.md")"
rm -rf "$ROT_P"

# Inerte en repo ajeno, como el resto de hooks.
ROT_AJENO="$(mktemp -d)"; printf '# CHANGELOG de OTRO\n## [9.9.9]\nx\n' > "$ROT_AJENO/CHANGELOG.md"
rot_corre "$ROT_AJENO"; ROT_RC=$?
rot_check "sin manifiesto no toca nada y sale 0" "1-0" "$(rot_sec "$ROT_AJENO/CHANGELOG.md")-$ROT_RC"
rm -rf "$ROT_AJENO"

echo "INERTE — sin manifiesto, el hook no estorba:"
PROJ2="$(mktemp -d)"; mkdir -p "$PROJ2/src"; export CLAUDE_PROJECT_DIR="$PROJ2"
check "sin .arnes/config.json, guard.sh no estorba -> allow" allow guard.sh "$(jq -n --arg fp "$PROJ2/src/x.ts" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:"x",new_string:"y"}}')"
check "sin .arnes/config.json edita src/ -> allow" allow guard-codigo.sh "$(jq -n --arg fp "$PROJ2/src/x.ts" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:"x",new_string:"y"}}')"
check "sin .arnes/config.json escribe por Bash -> allow" allow guard-codigo.sh "$(emite_bash 'echo x > src/x.ts' "" "")"
rm -rf "$PROJ2"

echo "-------------------------------------------"
echo "Resultado: $PASS PASS, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
