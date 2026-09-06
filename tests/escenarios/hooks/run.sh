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
# MEDIDO (2026-09-04, Windows + MSYS + almacenamiento sincronizado):
#   secuencial          23m10   user 1m10   sys 17m36
#   paralelo (20 a la vez) 16m58   user 1m28   sys 16m33
# Solo un 27% mejor, y `sys` ~= `real` en los dos casos: el sistema hace UNA cosa a
# la vez. La creacion de procesos en esta maquina es de un solo carril (fork
# emulado + filtro del antivirus), y ninguna paralelizacion del despacho puede
# saltarse eso. El coste vive en el kernel, no en el codigo del banco.
#
# Existe porque una vuelta completa cuesta ~17 min en Windows, y un ciclo de
# verificacion caro es lo que empuja a saltarse la suite.
FILTRO="${1:-}"

command -v jq >/dev/null 2>&1 || { echo "SKIP: jq no instalado"; exit 0; }

# --- proyecto de prueba efímero, UNO POR SECCION -------------------------------
# Antes había un solo proyecto compartido por todo el banco, y eso creaba
# acoplamiento invisible: `setgates ["false"]` dejaba las gates en rojo al final de
# una sección y las restauraba OTRA sección más abajo. Hoy ningún caso mide mal por
# eso, pero la corrección de una sección dependía de que otra limpiara detrás — y
# bajo ejecución concurrente eso deja de ser frágil y pasa a ser falso.
#
# Cada sección arranca ahora de un proyecto recién hecho, con el manifiesto base.
# Lo que una sección necesite distinto, lo declara ella.
RAIZ="$(mktemp -d)"
# Cuantas secciones a la vez. `ARNES_JOBS=1` reproduce el orden secuencial exacto,
# que es lo que se usa para diagnosticar cuando algo falla solo en paralelo.
JOBS="${ARNES_JOBS:-6}"
# Un archivo fijo, reutilizado: capturar stderr no debe costar un fork por llamada.
ERRLOG="$(mktemp)"   # el despachador da uno propio a cada seccion
trap 'rm -rf "$RAIZ"; rm -f "$ERRLOG"' EXIT
SEC=0

MANIFIESTO_BASE='{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}'

# seccion_nueva [titulo] — proyecto limpio y, si hay titulo, lo anuncia.
seccion_nueva() {
  PROJ="$RAIZ/proj-$BASHPID"
  mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src" "$PROJ/tests" "$PROJ/docs"
  printf '%s\n' "$MANIFIESTO_BASE" > "$PROJ/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
  export CLAUDE_PROJECT_DIR="$PROJ"
  [ -z "${1:-}" ] || echo "$1"
}
seccion_nueva          # el canario necesita proyecto antes de la primera sección

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

# emite_edit_real <file_path> <old_string> <new_string> [replace_all] — un Edit de la
# coordinadora cuyo `old_string` SI esta en el archivo: el hook reconstruye el documento
# resultante. El 4o argumento, cuando no va vacio, marca `replace_all: true`.
emite_edit_real() {
  jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" --arg ra "${4:-}" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:({file_path:$fp,old_string:$os,new_string:$ns}
                  + (if $ra!="" then {replace_all:true} else {} end))}'
}

# emite_write <file_path> <contenido> — un Write de la coordinadora con el documento entero.
emite_write() {
  jq -n --arg fp "$1" --arg c "$2" \
    '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,content:$c}}'
}

# emite_multiedit <file_path> <old1> <new1> [<old2> <new2> ...] — un MultiEdit real.
emite_multiedit() {
  local fp="$1"; shift
  local edits='[]'
  while [ "$#" -ge 2 ]; do
    edits="$(jq -c --arg os "$1" --arg ns "$2" '. + [{old_string:$os,new_string:$ns}]' <<< "$edits")"
    shift 2
  done
  jq -n --arg fp "$fp" --argjson ed "$edits" \
    '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,edits:$ed}}'
}

# emite_bash <comando> <agent_id> <agent_type>
# QA REQ-001: el comando va por STDIN (`jq -Rs`), NO como argumento `--arg`.
# MEDIDO: con el cuerpo de 10.000 lineas del caso de rendimiento, `--arg` supera el
# limite de UN argumento del proceso (MAX_ARG_STRLEN, 128 KB en Linux; ARG_MAX no es
# el que muerde). jq moria con `Argument list too long`, el JSON salia VACIO, el hook
# recibia nada y respondia allow: el caso pasaba POR LA RAZON EQUIVOCADA y no medio ni
# el tiempo ni la decision. Los otros emisores (`emite_write`, `emite_edit_real`,
# `emite_multiedit`) tienen el mismo techo latente; hoy ningun caso les pasa 128 KB,
# y si alguno lo hace, la guarda de `check` lo delata en vez de dejarlo en verde.
emite_bash() {
  printf '%s' "$1" | jq -Rs --arg aid "$2" --arg at "$3" \
    '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{command:.}}
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

# QA REQ-001: LA MISMA LECCION DEL CANARIO, UN NIVEL MAS ABAJO. Un caso que espera
# `allow` tambien pasa cuando el hook no recibe NADA, y el emisor puede quedarse mudo
# sin avisar (jq reventando por el tamano del argumento fue exactamente eso). Un JSON
# vacio no es un caso: es un caso que no se ejecuto, y tiene que salir en rojo.
json_no_vacio() {   # <nombre> <json> -> 0 si hay caso, 1 si esta vacio (y ya reporto)
  [ -n "$2" ] && return 0
  echo "  FAIL  $1  el JSON del caso salio VACIO: el hook no habria recibido entrada y"
  echo "        habria respondido allow. El caso no midio nada (revisa el emisor)."
  return 1
}

# check <nombre> <esperado:deny|allow> <script> <json>
check() {
  local nombre="$1" esperado="$2" script="$3" json="$4" out got
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  json_no_vacio "$nombre" "$json" || { FAIL=$((FAIL+1)); return 0; }
  out="$(corre "$script" "$json")"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then got=deny; else got=allow; fi
  if [ "$got" = "$esperado" ]; then
    echo "  PASS  $nombre  ($got)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  esperado=$esperado got=$got"; diag; FAIL=$((FAIL+1))
  fi
}

# QA REQ-001: el reloj se lee en MILISEGUNDOS y la decision se comprueba aparte del
# tiempo. Con `date +%s` un caso de 0 s y uno de 0,9 s son indistinguibles, y con la
# condicion unida por `&&` un `deny` inesperado se reportaba como "lento" en vez de
# como lo que es. Ademas se exige que el JSON exista: ver `json_no_vacio`.
# DEV REQ-001 v3: vive AQUI, con `check` y `check_motivo`, y no dentro de una seccion.
# Cada seccion corre en su propio subshell, asi que una funcion definida dentro de una
# no existe para las demas: al usarla en otra seccion los casos no fallaban, es que
# NO SE EJECUTABAN — y solo el cuadre de CASOS_ESPERADOS lo delato.
# DEV 1.31.0 v3 (QA-111): EL VEREDICTO DECIDE; EL RELOJ NO.
#
# Hasta v3 un caso fallaba si `ms >= techo`, con el techo puesto JUSTO encima de lo
# medido. QA midio el mismo caso ("heredoc CITADO de ~300 KB", techo 1000) en 1038 ms
# (FAIL) y en 616 ms (PASS) sobre LA MISMA linea base, sin cambiar nada: dos corridas
# completas de v1.30.3 dieron 457 y 458 PASS. El banco es la puerta REQUERIDA de `main`,
# y un rojo que la gente aprende a re-lanzar es un rojo que deja de significar algo.
#
# El reparto, que es el arreglo de raiz y no un numero mas alto:
#   1) EL VEREDICTO (`deny`/`allow`) decide, y NO se reintenta: es discreto, estable y
#      es lo que el caso quiere acreditar. Un `allow` donde se espera `deny` no mejora
#      repitiendolo.
#   2) QUE EL HOOK RESPONDA es la otra mitad discreta, y la que de verdad importa: un
#      hook que se atasca muere, `guard.sh` recibe salida vacia y PERMITE (QA-007). Eso
#      lo detecta `timeout` por su codigo de salida (124), no una comparacion de reloj —
#      y se comprueba SIEMPRE, tambien cuando se esperaba `allow`, que es justo donde un
#      hook muerto pasaba por bueno.
#   3) EL TIEMPO se conserva, porque el coste es la propiedad que estos casos vigilan
#      (lineal vs cuadratico son ordenes de magnitud), pero contra un techo HOLGADO
#      —CRONO_HOLGURA veces el presupuesto declarado— y con REINTENTO: solo falla si la
#      MEJOR de CRONO_INTENTOS medidas se pasa. Un pico de carga ajena no es una
#      regresion; un algoritmo cuadratico se pasa por multiplos, no por un 4 %.
#      Reintentar no cuesta nada en el camino feliz: solo se repite si la primera medida
#      se paso del techo holgado.
# El numero medido se imprime siempre: el banco sigue sirviendo de medicion.
CRONO_HOLGURA="${ARNES_CRONO_HOLGURA:-4}"
CRONO_INTENTOS="${ARNES_CRONO_INTENTOS:-3}"

# mide_hook <script> <json> <timeout_s> -> deja SALIDA_HOOK, CRONO_MS y CRONO_RC.
# La entrada va por ARCHIVO y no por tuberia para poder leer el codigo de salida de
# `timeout` (en `printf | timeout` el `$?` es el del ULTIMO de la tuberia dentro de la
# sustitucion, y con `set -o pipefail` distinguirlo exige mas ceremonia que un archivo).
SALIDA_HOOK=''; CRONO_MS=0; CRONO_RC=0
mide_hook() {
  local script="$1" json="$2" secs="$3" t0 t1 entrada="$ERRLOG.in"
  : > "$ERRLOG"
  printf '%s' "$json" > "$entrada"
  t0="$(date +%s%N)"
  SALIDA_HOOK="$(timeout "$secs" bash "$HOOKS_DIR/$script" < "$entrada" 2>"$ERRLOG")"; CRONO_RC=$?
  t1="$(date +%s%N)"
  CRONO_MS=$(( (t1 - t0) / 1000000 ))
  rm -f "$entrada"
}

cronometra_bash() {   # <nombre> <esperado:deny|allow> <presupuesto_ms> <json>
  local nombre="$1" esperado="$2" presu="$3" json="$4" got holgado secs intento=1 mejor=-1
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  if ! json_no_vacio "$nombre" "$json"; then FAIL=$((FAIL+1)); return 0; fi
  holgado=$(( presu * CRONO_HOLGURA )); secs=$(( (holgado / 1000) + 5 ))
  while : ; do
    mide_hook guard-codigo.sh "$json" "$secs"
    if [ "$CRONO_RC" -eq 124 ]; then
      echo "  FAIL  $nombre  NO RESPONDIO en ${secs}s: timeout lo corto (un hook muerto PERMITE)"; diag; FAIL=$((FAIL+1)); return 0
    fi
    if printf '%s' "$SALIDA_HOOK" | grep -Eq '"permissionDecision": *"deny"'; then got=deny; else got=allow; fi
    if [ "$got" != "$esperado" ]; then
      echo "  FAIL  $nombre  esperado=$esperado got=$got  (${CRONO_MS}ms)"; diag; FAIL=$((FAIL+1)); return 0
    fi
    if [ "$mejor" -lt 0 ] || [ "$CRONO_MS" -lt "$mejor" ]; then mejor="$CRONO_MS"; fi
    if [ "$CRONO_MS" -lt "$holgado" ]; then
      echo "  PASS  $nombre  ($got en ${CRONO_MS}ms; presupuesto ${presu}ms, techo holgado ${holgado}ms)"; PASS=$((PASS+1)); return 0
    fi
    [ "$intento" -lt "$CRONO_INTENTOS" ] || break
    intento=$(( intento + 1 ))
  done
  echo "  FAIL  $nombre  DESBOCADO: veredicto $got correcto, pero ${mejor}ms en la mejor de $CRONO_INTENTOS medidas (presupuesto ${presu}ms, techo holgado ${holgado}ms)"; diag; FAIL=$((FAIL+1))
}

# check_motivo <nombre> <regex> <script> <json> — exige deny Y que el motivo lo explique.
# Un deny mudo, o que no nombre a quien lo intentó, es un bug de diagnóstico.
check_motivo() {
  local nombre="$1" patron="$2" script="$3" json="$4" out motivo
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  json_no_vacio "$nombre" "$json" || { FAIL=$((FAIL+1)); return 0; }
  out="$(corre "$script" "$json")"
  motivo="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // empty' 2>/dev/null)"
  if [ -n "$motivo" ] && printf '%s' "$motivo" | grep -Eq "$patron"; then
    echo "  PASS  $nombre"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  motivo=<${motivo:-vacío}> no casa /$patron/"; diag; FAIL=$((FAIL+1))
  fi
}

# check_aviso <nombre> <si|no: debe haber systemMessage> [<regex del aviso>] <script> <json>
# Un aviso NO es una decision: la llamada tiene que seguir permitida. Por eso se exige
# ademas que la salida no traiga `deny` — si el aviso llegara denegando, el arnes habria
# convertido una errata en un bloqueo, que es justo lo que no se quiere.
# Pasa por `json_no_vacio` como el resto: un JSON vacio es un caso que no se ejecuto.
check_aviso() {
  local nombre="$1" debe="$2" patron="$3" script="$4" json="$5" out msg hay=no
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  json_no_vacio "$nombre" "$json" || { FAIL=$((FAIL+1)); return 0; }
  out="$(corre "$script" "$json")"
  msg="$(printf '%s' "$out" | jq -r 'select(.systemMessage != null) | .systemMessage' 2>/dev/null | head -c 4000)"
  [ -n "$msg" ] && hay=si
  if [ "$hay" != "$debe" ]; then
    echo "  FAIL  $nombre  systemMessage esperado=$debe, fue=$hay  <${msg:0:120}>"; diag; FAIL=$((FAIL+1)); return 0
  fi
  if [ "$debe" = "si" ] && [ -n "$patron" ] && ! printf '%s' "$msg" | grep -Eq "$patron"; then
    echo "  FAIL  $nombre  el aviso no casa /$patron/  <${msg:0:160}>"; FAIL=$((FAIL+1)); return 0
  fi
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then
    echo "  FAIL  $nombre  el aviso DENEGO la llamada; avisar no es decidir"; FAIL=$((FAIL+1)); return 0
  fi
  echo "  PASS  $nombre"; PASS=$((PASS+1))
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

seccion_01() {
  seccion_nueva "A1 — guard-codigo.sh (quién edita código de la app):"
check "coordinadora edita src/ -> deny"          deny  guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" ""    ""               'hola')"
check "desarrollador edita src/ -> allow"        allow guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a1"  "desarrollador"  'hola')"
check "qa-tester edita src/ -> deny"             deny  guard-codigo.sh "$(emite_edit "$PROJ/src/app.ts" "a2"  "qa-tester"      'hola')"
check "coordinadora edita doc fuera de app -> allow" allow guard-codigo.sh "$(emite_edit "$PROJ/docs/README.md" "" "" 'hola')"

}
seccion_02() {
  seccion_nueva "A3/A2 — guard-completado.sh (transición a completado):"
check "REQ -> en-progreso (no completado) -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: en-progreso')"
check "REQ -> completado, sin pendientes, gate ok -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: completado')"

}
seccion_03() {
  seccion_nueva "Veredictos QA/Seguridad (anti-deriva):"
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
}
seccion_04() {
  seccion_nueva "Regresión Windows / formas del manifiesto:"

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
else
  # Sin cygpath no hay forma Windows que probar. Pero un caso que NO corre tiene que
  # VERSE y CONTARSE: el primer run del banco en Linux abortó con "168 de 169" porque
  # este caso desaparecía en silencio, y un caso ausente se lee igual que uno que
  # pasó. SKIP es el tercer estado, y el cuadre lo suma.
  echo "  SKIP  ruta estilo Windows con backslashes -> deny  (sin cygpath: caso solo de Windows)"
fi

# --- Regresión: identidad del agente (bug hallado en SENDA, 2026-09-02) --------
# Claude Code entrega `agent_type` con el prefijo del plugin (`arnes-juan:desarrollador`)
# y el manifiesto declara el nombre corto: la comparación cruda no casaba NUNCA, así que
# el guard denegaba justo al único agente autorizado a escribir código.
}
seccion_05() {
  seccion_nueva "Identidad del agente (prefijo del plugin):"
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
}
seccion_06() {
  seccion_nueva "Bash — escrituras evidentes (cobertura parcial):"
check "coordinadora: redirección a código -> deny"      deny guard-codigo.sh "$(emite_bash 'cat > src/app.ts <<< "export const x = 1;"' "" "")"
check "coordinadora: >> pegado al archivo -> deny"      deny guard-codigo.sh "$(emite_bash 'echo x >>src/app.ts' "" "")"
check "coordinadora: ruta absoluta del proyecto -> deny" deny guard-codigo.sh "$(emite_bash "echo x > $PROJ/src/app.ts" "" "")"
check "coordinadora: tee sobre código -> deny"          deny guard-codigo.sh "$(emite_bash 'echo x | tee src/app.ts' "" "")"
check "coordinadora: sed -i sobre código -> deny"       deny guard-codigo.sh "$(emite_bash "sed -i 's/a/b/' src/app.ts" "" "")"
check "coordinadora: cp a directorio de código -> deny" deny guard-codigo.sh "$(emite_bash 'cp /tmp/x.ts src/' "" "")"
check "coordinadora: mv a directorio de código -> deny" deny guard-codigo.sh "$(emite_bash 'mv /tmp/x.ts src' "" "")"
check "coordinadora: escritura en la segunda orden encadenada -> deny" deny guard-codigo.sh "$(emite_bash 'npm run build && echo listo > app/gen.ts' "" "")"
# Controles positivos del descuento de heredocs (1.30.2): lo que NO es cuerpo sigue viendose.
check "heredoc: el cuerpo se descuenta, pero el cp DESPUES del cierre -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<\'EOF\'\ntexto que no escribe nada\nEOF\ncp /tmp/x.ts src/' "" "")"
check "heredoc: la redireccion en la PROPIA linea del heredoc -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF > src/gen.ts\nexport const x = 1;\nEOF' "" "")"
check "here-string (<<<) no es heredoc: el cp de detras sigue viendose -> deny" deny guard-codigo.sh \
  "$(emite_bash 'cat <<< "hola" ; cp /tmp/x.ts src/' "" "")"
check "aritmetica \$((1<<n)) no es heredoc: el cp de la linea siguiente sigue viendose -> deny" deny guard-codigo.sh \
  "$(emite_bash $'echo $((1<<n))\ncp /tmp/x.ts src/' "" "")"
# --- Heredoc SIN CITAR: el cuerpo no es solo texto (medido en 1.30.2) ---------------
# Una revision externa escribio codigo protegido con `cat <<EOF` / `$(echo x > src/...)`:
# el shell EJECUTA la sustitucion y crea el archivo, pero el detector descontaba TODO el
# cuerpo del heredoc como texto y devolvia ALLOW. Con el delimitador sin citar se
# conservan y se analizan las lineas con una sustitucion; el resto sigue siendo texto.
check "heredoc sin citar: una sustitucion escribe en codigo protegido -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/generated.ts)\nEOF' "" "")"
check_motivo "heredoc sin citar: ...y el motivo nombra el archivo que se crearia" "src/generated\.ts" \
  guard-codigo.sh "$(emite_bash $'cat <<EOF\n$(echo x > src/generated.ts)\nEOF' "" "")"
check "heredoc sin citar: acentos graves que escriben en codigo -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n`echo x > src/a.ts`\nEOF' "" "")"
check "heredoc sin citar con <<- y sangria: cp al codigo dentro de la sustitucion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<-EOF\n\t$(cp README.md src/a.ts)\n\tEOF' "" "")"
# Sin delimitador de cierre el bucle tiene que TERMINAR igual y seguir viendo la sustitucion.
check "heredoc sin citar y sin cierre: la sustitucion se sigue viendo -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/a.ts)' "" "")"
check_motivo "el deny por Bash admite que la cobertura es parcial" "parcial" \
  guard-codigo.sh "$(emite_bash 'echo x > src/app.ts' "" "")"
check "desarrollador (con prefijo) escribe por Bash -> allow" allow guard-codigo.sh "$(emite_bash 'echo x > src/app.ts' "a10" "arnes-juan:desarrollador")"

}
seccion_07() {
  seccion_nueva "Bash — lo que NO debe denegar (falsos positivos):"
check "coordinadora: cat de lectura -> allow"        allow guard-codigo.sh "$(emite_bash 'cat src/app.ts' "" "")"
check "coordinadora: grep recursivo -> allow"        allow guard-codigo.sh "$(emite_bash 'grep -rn foo src/ | head -20' "" "")"
check "coordinadora: sed sin -i -> allow"            allow guard-codigo.sh "$(emite_bash "sed -n '1,20p' src/app.ts" "" "")"
check "coordinadora: la ruta sólo se menciona en un mensaje -> allow" allow guard-codigo.sh "$(emite_bash 'git commit -m "arregla src/app.ts > listo"' "" "")"
check "coordinadora: lee código y escribe fuera -> allow" allow guard-codigo.sh "$(emite_bash 'cp src/app.ts /tmp/copia.ts' "" "")"
# El cuerpo de un heredoc es TEXTO que se entrega a un comando, no el comando (1.30.2).
# Medido en un proyecto real: un resumen en heredoc con `cp README.md src/...` como texto
# era denegado. Reproducido con cp, con `>` y con tee.
check "heredoc: 'cp README.md src/...' como TEXTO del cuerpo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<\'EOF\'\nresumen: cp README.md src/canario.txt ; listo\nEOF' "" "")"
check "heredoc: 'echo x > src/otro.ts' en el cuerpo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nejemplo: echo hola > src/otro.ts\nEOF' "" "")"
check "heredoc con <<- y sangria: 'tee src/otro.ts' en el cuerpo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<-EOF\n\tejemplo: tee src/otro.ts\n\tEOF' "" "")"
# --- Heredoc CITADO: el cuerpo si es literal, tambien en el shell real ---------------
# El control que da valor a los deny de arriba: con el delimitador citado o escapado bash
# NO expande nada, no se crea ningun archivo, y el hook no puede estorbar.
check "heredoc CITADO <<'EOF': el cuerpo es literal -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<\'EOF\'\n$(echo x > src/generated.ts)\nEOF' "" "")"
check 'heredoc CITADO con comillas dobles: el cuerpo es literal -> allow' allow guard-codigo.sh \
  "$(emite_bash $'cat <<"EOF"\n$(echo x > src/generated.ts)\nEOF' "" "")"
check 'heredoc ESCAPADO con barra invertida: el cuerpo es literal -> allow' allow guard-codigo.sh \
  "$(emite_bash $'cat <<\\EOF\n$(echo x > src/generated.ts)\nEOF' "" "")"
# Sin citar, pero la expansion no escribe nada: tampoco puede denegarse.
check "heredoc sin citar: una expansion inocente de fecha -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nfecha: $(date)\nEOF' "" "")"
# El falso positivo de 1.29.1, ahora tambien con el delimitador SIN citar: texto es texto.
check "heredoc sin citar: 'cp README.md src/...' como TEXTO del cuerpo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nresumen: cp README.md src/x.ts ; listo\nEOF' "" "")"
# La restriccion es de QUIEN edita, no de la forma del comando.
check "heredoc sin citar: el desarrollador si puede escribir codigo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/generated.ts)\nEOF' "a12" "arnes-juan:desarrollador")"
# Ni la here-string ni la aritmetica son heredocs, y solas no escriben nada.
check "heredoc: una here-string sola no lo es -> allow" allow guard-codigo.sh \
  "$(emite_bash 'cat <<< "hola"' "" "")"
check "heredoc: la aritmetica \$((1<<n)) sola no lo es -> allow" allow guard-codigo.sh \
  "$(emite_bash 'echo $((1<<n))' "" "")"
# RENDIMIENTO (CA-28): un cuerpo de 10.000 lineas se analiza con expansion de parametros,
# sin un proceso por linea. Umbral 5 s: un hook PreToolUse muere a los 60 s y un hook
# muerto no deniega, asi que el margen tiene que ser amplio, no justo.
# CA-28: cuerpo de 10.000 lineas SIN expansiones. Es el camino BARATO —el cuerpo entero
# se descuenta—, asi que este caso NO acredita el coste del camino caro: ver el de abajo.
cronometra_bash "heredoc sin citar: 10.000 lineas de cuerpo SIN expansiones -> allow" allow 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF' "$(yes 'linea de texto sin expansiones' | head -10000)")" "" "")"
# QA REQ-001 — HALLAZGO QA-003 (coste cuadratico del cuerpo CONSERVADO).
# Las lineas con `$(` ya no se descuentan: entran en el texto que analiza el detector, y
# el descuento de comillas es un bucle que RECONSTRUYE la cadena entera por cada par. Con
# 1.500 lineas de cuerpo (28 KB de comando) el hook no responde en 65 s. MEDIDO en Linux,
# WSL2, 2026-09-05: 1.30.2 respondia `deny` en 210 ms; la candidata no responde.
# Un hook PreToolUse muere a los 60 s, y UN HOOK MUERTO NO DENIEGA: el comando de este
# caso escribe de verdad en `src/robado.ts`. Es fallo en abierto por agotamiento.
#   500 lineas -> 5,5 s (1.30.2: 0,11 s) · 1.000 -> 40 s · 1.500 -> >65 s
cronometra_bash "heredoc sin citar: 1.500 lineas con expansion y comillas + escritura real -> deny" deny 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/robado.ts' "$(yes "\$(date) 'x' \"y\"" | head -1500)")" "" "")"
# DEV REQ-001 v2: el mismo camino caro, con el TRIPLE de cuerpo. Un umbral que solo se
# cumple en el tamano exacto que denuncio el defecto no acredita que el coste dejo de ser
# cuadratico: acredita que se movio el punto de ruptura. Con el descuento por fragmento
# el coste es lineal — medido en Linux/WSL2 2026-09-05: 500 lineas 110 ms, 1.000 211 ms,
# 1.500 211 ms, 5.000 511 ms (antes: 5,5 s / 40 s / >65 s).
# DEV REQ-001 v3 (nota, no toco el caso): con el presupuesto de 64 KiB estas 5.000 lineas
# (80 KB de material analizable) se deniegan POR TAMANO, no por ver la redireccion. Sigue
# siendo `deny` y sigue siendo correcto, pero el caso ya no acredita el analisis real: eso
# lo acredita el de 4.000 lineas de la seccion DEV v3, que cabe justo bajo el techo y
# EXIGE que el motivo nombre la ruta.
cronometra_bash "heredoc sin citar: 5.000 lineas con expansion y comillas + escritura real -> deny" deny 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/robado.ts' "$(yes "\$(date) 'x' \"y\"" | head -5000)")" "" "")"

# QA REQ-001 — HALLAZGO QA-001 (falso NEGATIVO nuevo, medido 2026-09-05).
# Conservar las lineas del cuerpo con `$(` mete SUS COMILLAS en el texto que analiza el
# detector, y el descuento de entrecomillado empareja por pares SOBRE TODO EL COMANDO. Una
# comilla impar en el cuerpo se empareja con la primera comilla del comando REAL que va
# despues del cierre y borra lo que queda en medio: la redireccion se evapora.
# Reproduccion: el shell CREA `src/robado.ts` (verificado ejecutandolo en un sandbox).
# 1.30.2: deny. Candidata: allow. Es la misma familia que este REQ vino a cerrar.
check "QA: comilla impar en el cuerpo NO puede desarmar la redireccion posterior -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(date) don\'t\nEOF\necho x > src/robado.ts && echo \'listo\'' "" "")"
check "QA: control, el mismo comando sin el heredoc delante -> deny" deny guard-codigo.sh \
  "$(emite_bash $'echo x > src/robado.ts && echo \'listo\'' "" "")"
check "QA: la misma comilla impar con acento grave en el cuerpo -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n`date` don\'t\nEOF\ncp README.md src/a.ts && echo \'ok\'' "" "")"
check "QA: control, cuerpo con expansion y comillas PARES -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(date) \'hoy\'\nEOF\necho x > src/robado.ts && echo \'listo\'' "" "")"
# QA REQ-001 — HALLAZGO QA-004 (falso POSITIVO nuevo). La linea entera se analiza como
# comando por llevar UNA expansion, asi que el TEXTO que la acompana vuelve a leerse como
# orden: es el falso positivo de 1.29.1 otra vez, ahora con `$(` en la linea. En el shell
# real solo se expande `$(date)`; no se copia nada. 1.30.2: allow. Candidata: deny.
check "QA: cuerpo con \$(date) y una mencion TEXTUAL de cp no es una escritura -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nver $(date) y luego cp README.md src/x.ts\nEOF' "" "")"
check "QA: control, cuerpo con \$(date) y sin rutas -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nver $(date) y nada mas\nEOF' "" "")"

# DEV REQ-001 v2: la frontera que cierra QA-001/QA-002/QA-003 no es "el cuerpo", es CADA
# FRAGMENTO EJECUTABLE. Del cuerpo sin citar se conserva solo el interior de `$( )` y de
# los acentos graves, cada uno desentrecomillado por separado y unido con `;`. Estos casos
# fijan las tres consecuencias, para que un arreglo futuro no las deshaga en silencio.
#
# 1) Una comilla impar de UN fragmento tampoco puede desarmar a OTRO fragmento del mismo
#    cuerpo: la frontera es por fragmento, no solo entre cuerpo y comando real.
check "DEV: comilla impar en un fragmento NO desarma otro fragmento del cuerpo -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo don\'t)\n$(echo x > src/f2.ts)\nEOF' "" "")"
# 2) ...y el operando de un fragmento no se lee como destino del comando del anterior: sin
#    el separador, el `cp` seguiria buscando destino dentro del fragmento siguiente.
check "DEV: el destino de un cp no cruza al fragmento siguiente -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(cp README.md)\n$(echo src/x.ts)\nEOF' "" "")"
# 3) El falso positivo de QA-003 tampoco depende del ORDEN: la mencion textual delante de
#    la expansion sigue siendo texto.
check "DEV: mencion textual ANTES de la expansion sigue siendo texto -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\ncp README.md src/x.ts es lo que hace $(date)\nEOF' "" "")"
# 4) DENTRO de la expansion las comillas SI son sintaxis, como en el shell real: `echo` con
#    la redireccion entrecomillada imprime texto, no redirige. El par deny/allow es lo que
#    acredita que el descuento por fragmento no se volvio ciego.
check "DEV: comillas DENTRO de la expansion siguen siendo sintaxis -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \'x > src/a.ts\')\nEOF' "" "")"
check "DEV: control, la misma expansion SIN comillas -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/a.ts)\nEOF' "" "")"
# 5) La limitacion declarada tiene un borde util: una sustitucion que abre en una linea y
#    no cierra en ella aporta el resto de SU linea, asi que el comando que la abre se ve.
check "DEV: sustitucion que abre en una linea y cierra en otra -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/multi.ts\n)\nEOF' "" "")"

# QA REQ-001 v2 — RE-VALIDACION (vuelta 1 del bucle dev<->QA, 2026-09-05).
# Los tres hallazgos de la vuelta 1 se verificaron con sondas propias, no solo con el
# banco. Estos casos fijan la conducta ARREGLADA por sus BORDES, que es donde un arreglo
# futuro la deshace en silencio. Todos verdes hoy; si alguno se pone rojo, la frontera
# "cada fragmento ejecutable se desentrecomilla aislado" volvio a romperse.
#
# 1) Comillas CRUZADAS entre dos fragmentos del MISMO cuerpo: una comilla impar en el
#    primer fragmento no puede emparejarse con una del segundo y borrar la escritura.
check "QA v2: comilla simple impar cruzada entre dos fragmentos -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo a\')\n$(echo x > src/v1.ts)\nEOF' "" "")"
check "QA v2: comilla doble impar cruzada entre dos fragmentos -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo "a)\n$(echo x > src/v2.ts)\nEOF' "" "")"
# 2) Acento grave IMPAR en el cuerpo: no puede tragarse el comando real posterior.
check "QA v2: acento grave impar en el cuerpo NO desarma la escritura posterior -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nhola `date\nEOF\necho x > src/v3.ts' "" "")"
# 3) La comilla impar en el comando REAL, ANTES del heredoc: el descuento del comando
#    real sigue siendo de una pieza, y una comilla suya sin pareja no borra la escritura.
check "QA v2: comilla impar en el comando real ANTES del heredoc -> deny" deny guard-codigo.sh \
  "$(emite_bash $'echo \'abre\ncat <<EOF\n$(date)\nEOF\necho x > src/v4.ts' "" "")"
# 4) Un fragmento que TERMINA en `;` no deja al detector buscando operando en el siguiente.
check "QA v2: fragmento que termina en ';' no cruza al siguiente -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo hola;)\n$(echo x > src/v5.ts)\nEOF' "" "")"
check "QA v2: control, cp sin destino + ruta en el fragmento siguiente -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(cp README.md;)\n$(echo src/v6.ts)\nEOF' "" "")"
# 5) El detector COMPLETO tiene que seguir vivo DENTRO de la expansion, no solo `>` y `cp`.
#    Sin estos, un arreglo podria recortar el fragmento y dejar mudas las otras formas.
check "QA v2: install dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(install -m 644 README.md src/v7.ts)\nEOF' "" "")"
check "QA v2: perl -pi dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(perl -pi -e s/a/b/ src/v8.ts)\nEOF' "" "")"
check "QA v2: dd of= dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(dd if=/dev/zero of=src/v9.ts)\nEOF' "" "")"
check "QA v2: mv dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(mv README.md src/v10.ts)\nEOF' "" "")"
# 6) Operadores dentro de la expansion: el fragmento se tokeniza como comando de verdad.
check "QA v2: '&&' dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(true && echo x > src/v11.ts)\nEOF' "" "")"
check "QA v2: tuberia a tee dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(cat README.md | tee src/v12.ts)\nEOF' "" "")"
# 7) La LINEA QUE ABRE el heredoc no es cuerpo: su redireccion se sigue viendo.
check "QA v2: redireccion en la linea que abre el heredoc -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF > src/v13.ts\ntexto\nEOF' "" "")"
check "QA v2: 'cat > ruta <<EOF' -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat > src/v14.ts <<EOF\ntexto\nEOF' "" "")"

# QA REQ-001 v2 — HALLAZGO QA-007 (`contrato`, BLOQUEA): el coste dejo de ser cuadratico
# en el NUMERO DE LINEAS del cuerpo, pero sigue siendolo en el TAMANO DE UNA LINEA. El
# punto de ruptura se movio de eje, no desaparecio. MEDIDO en Linux/WSL2 2026-09-05 con
# una sola linea de cuerpo y N expansiones `$(date)`, mas la escritura real FUERA del
# heredoc (`echo x > src/...`):
#   N=500 -> 210 ms · 1.000 -> 411 ms · 2.000 -> 1,3 s · 4.000 -> 5,1 s ·
#   8.000 -> 18,0 s · 12.000 -> 41,1 s · 16.000 -> NO RESPONDE en 60 s
# Contra v1.30.2 la misma entrada responde `deny` en 213 ms con N=20.000 (plana): es una
# REGRESION del arreglo, no una limitacion heredada. A los 60 s el hook muere, la salida
# sale VACIA y `guard.sh` permite: verificado en un sandbox, el shell CREA `src/qa7.ts`.
# Umbral el del REQ (CA-40/CA-48): menos de 5 s. Se usa N=8.000 —no 4.000, que cae
# JUSTO sobre el umbral (5,0 s medidos) y daria un caso flaky— para que el resultado sea
# el mismo en cada corrida: el `timeout` duro lo corta a los 10 s y el caso reporta
# `got=allow`, que es LA VERDAD del defecto (hook cortado = hook que no deniega).
# Cuando el coste sea lineal, 8.000 expansiones deben resolverse muy por debajo de 1 s.
cronometra_bash "QA v2: UNA linea de cuerpo con 8.000 expansiones + escritura real -> deny" deny 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(yes '$(date)' | head -8000 | tr -d '\n')")" "" "")"
# Control del caso de arriba: la MISMA escritura sin el cuerpo delante se resuelve al
# instante. Sin el, un `deny` lento no distingue "el cuerpo cuesta" de "la sonda es lenta".
cronometra_bash "QA v2: control, la misma escritura sin el cuerpo delante -> deny" deny 5000 \
  "$(emite_bash 'echo x > src/qa7.ts' "" "")"

check "coordinadora: redirige un log fuera de los globs -> allow" allow guard-codigo.sh "$(emite_bash 'npm run build > /tmp/build.log 2>&1' "" "")"
check "qa-tester escribe en tests/ (no es código de app) -> allow" allow guard-codigo.sh "$(emite_bash 'echo x > tests/a.test.ts' "a11" "arnes-juan:qa-tester")"

# --- Clase del hallazgo: la unica puerta que existe para DEJAR PASAR ------------
# Un defecto del propio arnes no puede impedir cerrar una funcion de negocio.
}
seccion_08() {
  seccion_nueva "Clase del hallazgo:"
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
}
seccion_09() {
  seccion_nueva "Cierre de REQ por Bash (guard-completado):"
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

# El mismo heredoc sin citar, por la via del cierre de un REQ: la sustitucion ejecuta el
# `sed -i` de verdad, asi que la transicion tiene que derivarse a Edit/Write igual.
check "heredoc sin citar que cierra un REQ con sed -i -> deny" deny guard-completado.sh \
  "$(emite_bash $'cat <<EOF\n$(sed -i \'s/en-revisión/completado/\' requirements/REQ-001.md)\nEOF' "" "")"
# QA REQ-001 — HALLAZGO QA-001, por la puerta del CIERRE. Una comilla IMPAR en una linea
# del cuerpo que se conserva (`$(`) se empareja, en el descuento global de texto
# entrecomillado, con la primera comilla del comando REAL que va DESPUES del cierre, y se
# lleva por delante lo que hay en medio: el `sed -i` desaparece del texto analizado.
# 1.30.2 denegaba (descontaba el cuerpo entero); la candidata deja pasar.
check "QA: comilla impar en el cuerpo NO puede desarmar el sed -i que cierra el REQ -> deny" deny guard-completado.sh \
  "$(emite_bash $'cat <<EOF\n$(date) don\'t\nEOF\nsed -i \'s/en-revisión/completado/\' requirements/REQ-001.md' "" "")"
check "QA: control, el mismo sed -i sin el heredoc delante -> deny" deny guard-completado.sh \
  "$(emite_bash $'sed -i \'s/en-revisión/completado/\' requirements/REQ-001.md' "" "")"
# --- Arranque limpio: la plantilla de PENDING no puede bloquear ----------------
# El ejemplo de formato vivia COMENTADO bajo `## Pendientes`; el conteo lo leia
# como 1 pendiente y un proyecto recien inicializado no cerraba ningun REQ.
}
seccion_10() {
  seccion_nueva "Arranque limpio — plantilla de PENDING_APPROVAL:"
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
}
seccion_11() {
  seccion_nueva "Nivel de rigor:"
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
}
seccion_12() {
  # --- `ligero` salta los VEREDICTOS, no las PUERTAS -------------------------------
seccion_nueva "Rigor ligero: salta veredictos, no puertas:"
# La plantilla promete "analista + desarrollador + quality gates" para ligero. Hasta
# 1.28.0 el codigo hacia `return 0` antes de la clase del hallazgo, de las aprobaciones
# pendientes y de las quality gates: un REQ ligero cerraba con el build en rojo. Lo
# encontro una revision externa leyendo el codigo; estos casos lo fijan.
mkreq_r "REQ-090" "no" "pendiente" "n/a" "ligero"
setgates '.quality_gates = ["false"]'
check "ligero con quality gate ROJA -> deny (la plantilla promete gates)" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-090.md" "" "" 'Estado: completado')"
setgates '.quality_gates = ["true"]'
printf '## Pendientes\n### [2026-09-05] (qa) — decision humana\n- Contexto: x\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "ligero con aprobacion humana PENDIENTE -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-090.md" "" "" 'Estado: completado')"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
mkreq "$PROJ/requirements/REQ-091.md" "no" "pendiente" "n/a" "SEC-7 (usuario/dinero)"
printf 'Rigor: ligero\n' >> "$PROJ/requirements/REQ-091.md"
check "ligero con hallazgo usuario/dinero ABIERTO -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-091.md" "" "" 'Estado: completado')"
# Control positivo de lo que SI salta: sin veredicto de QA, con todo lo demas verde.
check "ligero SIN veredicto de QA y todo verde -> allow (eso si lo salta)" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-090.md" "" "" 'Estado: completado')"

}
seccion_13() {
seccion_nueva "Orden del ciclo (seguridad tras QA):"
mkreq_r "REQ-050" "no" "pendiente" "pendiente" ""
check "firmar Seguridad con QA pendiente -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-050.md" "" "" 'Seguridad: aprobado')"
check "...y tampoco al cerrar de paso -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-050.md" "" "" 'Estado: completado
Seguridad: aprobado')"
# La excepcion se declara AL EMITIRLA, no al invocarla.
check "auditoria PREVENTIVA declarada -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-050.md" "" "" 'Seguridad: preventiva')"
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
mkreq_r "REQ-054" "sí" "aprobado" "preventiva" ""
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
}
seccion_14() {
  # --- Los campos valen SOLO en la cabecera: la puerta -------------------------------
# Medido: `Seguridad: aprobado (A-009, 2026-09-02)` a columna cero dentro de
# `## Historial de cambios` cerraba un REQ critico cuya cabecera decia `pendiente`. La
# forma con parentesis final es la que normaliza a `aprobado` limpio; la forma con texto
# detras denegaba POR ACCIDENTE. Es la familia de `**si**`: la maquina lee algo distinto
# de lo que la cabecera declara. La regla es estructural --antes del primer `## `--, no
# el nombre de una seccion, que seria mapeo del proyecto.
seccion_nueva "Campos solo en la cabecera (la historia no es un veredicto):"
printf '# REQ-110\nEstado: en-revisión\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: pendiente\n\n## Historial de cambios\n- 2026-09-01: se abrio la auditoria\nSeguridad: aprobado (A-009, 2026-09-02)\n' > "$PROJ/requirements/REQ-110.md"
check "historia con 'Seguridad: aprobado (...)' a col. 0 NO cierra -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-110.md" "" "" 'Estado: completado')"
printf '# REQ-111\nEstado: en-revisión\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: aprobado\n\n## Historial de cambios\nSeguridad: pendiente\n' > "$PROJ/requirements/REQ-111.md"
check "control: la CABECERA si se lee (aprobado arriba, pendiente en historia) -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-111.md" "" "" 'Estado: completado')"
printf '# REQ-112\nEstado: en-revisión\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: pendiente\n\n## Historial\n- Seguridad: aprobado (A-009)\n' > "$PROJ/requirements/REQ-112.md"
check "vineta '- Seguridad:' en historia tampoco cuenta -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-112.md" "" "" 'Estado: completado')"
# Un fragmento de Edit no tiene `##`: se lee entero, como siempre.
printf '# REQ-113\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-113.md"
check "un fragmento sin '##' se lee entero: QA aprobado en el Edit -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-113.md" "" "" 'QA: aprobado
Estado: completado')"
# --- El bypass por MultiEdit (medido en 1.30.1) -------------------------------------
# Un MultiEdit que cerraba el REQ y aprobaba SOLO la linea del historial pasaba: se
# concatenaban los `new_string` y el `## ` se quedaba en el disco. El hook reconstruye
# ahora el documento resultante y lee la cabecera de ahi.
printf '# REQ-114\nEstado: en-revisión\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: pendiente\n\n## Historial\n\nSeguridad: pendiente (registro anterior)\n' > "$PROJ/requirements/REQ-114.md"
check "MultiEdit: cierra y aprueba SOLO la linea del historial -> deny" deny guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-114.md" 'Estado: en-revisión' 'Estado: completado' 'Seguridad: pendiente (registro anterior)' 'Seguridad: aprobado (A-009)')"
check "control: MultiEdit que aprueba la CABECERA y cierra -> allow" allow guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-114.md" 'Estado: en-revisión' 'Estado: completado' $'Seguridad: pendiente\n' $'Seguridad: aprobado (A-009)\n')"
# El mismo bypass sobre un archivo CRLF (Windows): la reconstruccion tiene que casar igual.
printf '# REQ-115\r\nEstado: en-revisión\r\nSensible a seguridad: sí\r\nQA: aprobado\r\nSeguridad: pendiente\r\n\r\n## Historial\r\n\r\nSeguridad: pendiente (registro anterior)\r\n' > "$PROJ/requirements/REQ-115.md"
check "MultiEdit sobre un REQ CRLF: el bypass tambien -> deny" deny guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-115.md" 'Estado: en-revisión' 'Estado: completado' 'Seguridad: pendiente (registro anterior)' 'Seguridad: aprobado (A-009)')"
# Y al reves: `Estado: completado` escrito SOLO en la historia no es una transicion.
check "Edit: 'Estado: completado' solo en la historia NO es una transicion -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-114.md" 'Seguridad: pendiente (registro anterior)' $'Seguridad: pendiente (registro anterior)\n- 2026-08-01: Estado: completado (intento anterior, revertido)')"
# --- El bypass por SUSTITUCION DEL VALOR (medido en 1.30.2) -------------------------
# Una revision externa cerro un REQ con `old_string: en-revisión` / `new_string: completado`.
# El fragmento no escribe la palabra «Estado» en ninguna parte, y el hook exigia esa palabra
# EN EL FRAGMENTO antes de correr las puertas: salia por arriba y devolvia ALLOW con
# `QA: pendiente`. Sustituir el VALOR es la forma mas natural de cerrar un REQ a mano.
# Ahora, con el documento reconstruido, la transicion se lee del DOCUMENTO: la cabecera en
# disco no lo decia y la resultante si.
mkreq "$PROJ/requirements/REQ-120.md" "no" "pendiente" "n/a"
check "transicion por documento: Edit que sustituye SOLO el valor -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-120.md" 'en-revisión' 'completado')"
check_motivo "transicion por documento: ...y el motivo nombra el veredicto que falta" "QA es 'pendiente'" \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-120.md" 'en-revisión' 'completado')"
# Control positivo: el mismo Edit sobre un REQ que SI puede cerrarse no puede estorbar.
mkreq "$PROJ/requirements/REQ-121.md" "no" "aprobado" "n/a"
check "transicion por documento: control, SOLO el valor con todo en verde -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-121.md" 'en-revisión' 'completado')"
# El suelo del REQ sensible tambien se aplica por esta via.
mkreq "$PROJ/requirements/REQ-122.md" "sí" "aprobado" "pendiente"
check "transicion por documento: SOLO el valor sobre un REQ sensible sin auditoria -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-122.md" 'en-revisión' 'completado')"
# MultiEdit: una edicion sustituye el valor y la otra anota el historial.
printf '# REQ-124\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n\n## Historial\n| 2026-09-01 | nace |\n' > "$PROJ/requirements/REQ-124.md"
check "transicion por documento: MultiEdit con SOLO el valor + fila de historial -> deny" deny guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-124.md" 'en-revisión' 'completado' '| 2026-09-01 | nace |' $'| 2026-09-01 | nace |\n| 2026-09-02 | cierra |')"
# `replace_all`: el valor aparece ANTES de la cabecera, asi que solo sustituyendo TODAS las
# ocurrencias queda `Estado: completado`. Es lo que separa "se reconstruyo" de "se adivino".
printf '# REQ-125 (nacio en-revisión)\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-125.md"
check "transicion por documento: replace_all sustituye TODAS las ocurrencias -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-125.md" 'en-revisión' 'completado' 1)"
check "transicion por documento: control, sin replace_all solo la primera y la cabecera no cambia -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-125.md" 'en-revisión' 'completado')"
# El mismo bypass sobre un archivo CRLF: el CR no puede devolver un ALLOW por la puerta de atras.
printf '# REQ-123\r\nEstado: en-revisión\r\nSensible a seguridad: no\r\nQA: pendiente\r\nSeguridad: n/a\r\n' > "$PROJ/requirements/REQ-123.md"
check "transicion por documento: SOLO el valor sobre un REQ CRLF -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-123.md" 'en-revisión' 'completado')"
# --- El fallback sigue vivo: sin documento reconstruido se juzga el fragmento ---------
mkreq "$PROJ/requirements/REQ-126.md" "no" "pendiente" "n/a"
check "transicion por documento: Write con la cabecera completa -> deny" deny guard-completado.sh \
  "$(emite_write "$PROJ/requirements/REQ-126.md" $'# REQ-126\nEstado: completado\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n')"
# Y al reves: un `Write` cuya CABECERA sigue en revision pero cuyo cuerpo cita el estado
# terminal dentro de un criterio. Medido con 1.30.2 mientras se redactaba un REQ: el `grep`
# miraba todo el contenido y lo denegaba. Manda la cabecera, aqui tambien.
check "transicion por documento: control, Write que solo CITA el estado en el cuerpo -> allow" allow guard-completado.sh \
  "$(emite_write "$PROJ/requirements/REQ-126.md" $'# REQ-126\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n\n## Criterios\n- Cuando el REQ queda `Estado: completado (ejemplo citado)`, entonces...\n')"
# QA REQ-001 v2 — CA-45. El REQ declara UN solo cambio de conducta `deny -> allow`
# respecto a v1.30.2 (CA-36) y hasta ahora NO tenia caso: la evidencia de CA-50 no se
# podia correr. Es el `Write` que reescribe entero un REQ que EN DISCO ya estaba en el
# estado terminal; no hay transicion, asi que no corre ninguna de las tres puertas —ni
# con la cola de aprobaciones abierta, ni con `Seguridad: pendiente`, ni con un hallazgo
# `usuario/dinero`—. MEDIDO: v1.30.2 responde `deny`; la candidata, `allow`.
printf '# REQ-131\nEstado: completado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\n' > "$PROJ/requirements/REQ-131.md"
printf '## Pendientes\n\n### Fusionar el PR de la candidata\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "transicion por documento: Write sobre un REQ que EN DISCO ya estaba terminal -> allow" allow guard-completado.sh \
  "$(emite_write "$PROJ/requirements/REQ-131.md" $'# REQ-131\nEstado: completado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: X-1 (usuario/dinero)\n\n## Historia\nreescrito entero\n')"
# Control obligatorio: el MISMO documento sobre un REQ que en disco NO estaba terminal
# sigue en `deny`. Sin el, el ALLOW de arriba no prueba que la regla sea "no hay
# transicion": probaria que la puerta dejo de mirar.
printf '# REQ-132\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\n' > "$PROJ/requirements/REQ-132.md"
check "transicion por documento: control, el mismo Write sobre un REQ NO terminal -> deny" deny guard-completado.sh \
  "$(emite_write "$PROJ/requirements/REQ-132.md" $'# REQ-132\nEstado: completado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: X-1 (usuario/dinero)\n\n## Historia\nreescrito entero\n')"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
mkreq "$PROJ/requirements/REQ-127.md" "no" "pendiente" "n/a"
check "transicion por documento: old_string ausente + 'Estado: completado' en el fragmento -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-127.md" "" "" 'Estado: completado')"
check "transicion por documento: old_string ausente y fragmento 'completado' a secas -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-127.md" "" "" 'completado')"
# Un REQ que NO existe en disco: `disk` vacio no puede tumbar el hook con `set -u` ni dejar traza.
if [ -z "$FILTRO" ] || printf '%s' "transicion por documento: REQ inexistente en disco" | grep -qi -- "$FILTRO"; then
salida="$(corre guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-999.md" 'en-revisión' 'completado')")"
if ! printf '%s' "$salida" | grep -Eq '"permissionDecision": *"deny"' && [ ! -s "$ERRLOG" ]; then
  echo "  PASS  transicion por documento: REQ inexistente en disco -> allow y sin traza de bash"; PASS=$((PASS+1))
else
  echo "  FAIL  transicion por documento: REQ inexistente en disco: salida=<$salida>"; diag; FAIL=$((FAIL+1))
fi
fi
# --- No hay transicion: la cabecera en disco YA decia el estado terminal --------------
printf '# REQ-128\nEstado: completado\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n\n## Historia\ntexto original\n' > "$PROJ/requirements/REQ-128.md"
check "transicion por documento: la cabecera en disco YA decia completado -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-128.md" 'texto original' 'texto corregido')"
check "transicion por documento: reabrir un REQ cerrado a en-progreso -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-128.md" 'completado' 'en-progreso')"
# --- Las puertas A2 y A3 corren sobre el documento reconstruido, no sobre el fragmento --
mkreq "$PROJ/requirements/REQ-129.md" "no" "aprobado" "n/a"
printf '## Pendientes\n\n### Fusionar el PR de la candidata\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check_motivo "transicion por documento: SOLO el valor con la cola de aprobaciones abierta -> deny" "PENDING_APPROVAL" \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-129.md" 'en-revisión' 'completado')"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
setgates '.quality_gates = ["false"]'
check_motivo "transicion por documento: SOLO el valor con una quality gate roja -> deny" "quality gate" \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-129.md" 'en-revisión' 'completado')"
setgates '.quality_gates = ["true"]'
# --- El estado terminal es el DEL MANIFIESTO, no la palabra «completado» ---------------
mkreq "$PROJ/requirements/REQ-130.md" "no" "pendiente" "n/a"
setcfg '.estados.completado = "hecho"'
check "transicion por documento: estado terminal 'hecho' del manifiesto -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-130.md" 'en-revisión' 'hecho')"
check "transicion por documento: control, 'completado' ya no es terminal en ese manifiesto -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-130.md" 'en-revisión' 'completado')"
setcfg '.estados.completado = "completado"'
# QA REQ-001 — variantes de escritura del MISMO cierre, independientes de las del
# desarrollador. Todas dejan la cabecera resultante en el estado terminal, asi que todas
# tienen que denegar; si alguna se colara, la regla nueva estaria leyendo la forma del
# fragmento y no el documento. Todas verificadas en rojo contra 1.30.2 salvo la primera.
mkreq "$PROJ/requirements/REQ-140.md" "no" "pendiente" "n/a"
check "QA: Edit con la LINEA ENTERA 'Estado: completado' -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-140.md" 'Estado: en-revisión' 'Estado: completado')"
check "QA: el valor en MAYUSCULAS -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-140.md" 'en-revisión' 'COMPLETADO')"
check "QA: el valor con su parentesis de evidencia -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-140.md" 'en-revisión' 'completado (por fin)')"
check "QA: el valor en **negrita** -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-140.md" 'en-revisión' '**completado**')"
check "QA: el valor con espacios de mas tras los dos puntos -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-140.md" 'Estado: en-revisión' 'Estado:   completado')"
# MultiEdit ENCADENADO: la 1a edicion escribe el texto que busca la 2a. Solo aplicando las
# ediciones EN ORDEN sobre el documento —como hara la herramienta— queda la cabecera
# cerrada; leyendo los fragmentos sueltos, ninguno dice el estado terminal.
mkreq "$PROJ/requirements/REQ-141.md" "no" "pendiente" "n/a"
check "QA: MultiEdit encadenado (edit1 crea lo que busca edit2) -> deny" deny guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-141.md" 'en-revisión' 'PROVISIONAL' 'PROVISIONAL' 'completado')"
check "QA: control, edit2 busca lo que edit1 destruyo: la herramienta fallaria -> allow" allow guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-141.md" 'en-revisión' 'PROVISIONAL' 'en-revisión' 'completado')"

}
seccion_15() {
seccion_nueva "Formas decoradas (marcado de Markdown en el valor):"
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
mkreq "$PROJ/requirements/REQ-070.md" "sí" "aprobado" "**preventiva**"
check "preventiva decorada TAMPOCO cierra -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-070.md" "" "" 'Estado: completado')"
mkreq_r "REQ-071" "no" "pendiente" "n/a" "**ligero**"
check "Rigor **ligero** decorado se reconoce -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-071.md" "" "" 'Estado: completado')"

}
seccion_16() {
  seccion_nueva "guard.sh — punto de entrada unico (los dos guardianes, un proceso):"
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
}
seccion_17() {
  seccion_nueva "Asterisco de nota al pie (una salvedad no es una firma):"
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

# --- El parentesis es EVIDENCIA, y la evidencia no cambia el veredicto ---------
# Medido en un proyecto real: 26 REQ paralizados porque su convencion es
# `QA: aprobado (medido el 3/9, 42 pruebas)` -- el veredicto con lo que lo sostiene
# al lado-- y la comparacion exigia la palabra exacta. La alternativa era quitar los
# parentesis de 35 lineas, o sea BORRAR LA EVIDENCIA del encabezado del REQ, que es
# media razon de ser de este arnes.
#
# La primera version metia el matiz DENTRO del parentesis (`aprobado (preventiva)`),
# y el mismo signo significaba "evidencia" en un caso y "matiz que invierte el
# veredicto" en el otro. Esa ambiguedad era un error de diseño y se QUITO en vez de
# arbitrarse: un matiz que cambia el veredicto ES OTRO VEREDICTO.
}
seccion_18() {
  seccion_nueva "Parentesis = evidencia (el veredicto no cambia):"
mkreq "$PROJ/requirements/REQ-080.md" "no" "aprobado (medido el 3/9, 42 pruebas)" "n/a"
check "QA con su evidencia entre parentesis cierra -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-080.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-081.md" "sí" "aprobado" "aprobado (auditado el 3/9)"
check "Seguridad con evidencia cierra un critico -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-081.md" "" "" 'Estado: completado')"
# Balanceado y final, la misma leccion que el enfasis pareado: si no cierra, no es
# un parentesis, es texto -- y el texto sobra en un veredicto.
mkreq "$PROJ/requirements/REQ-083.md" "sí" "aprobado" "aprobado (sin cerrar"
check "parentesis sin cerrar no es evidencia -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-083.md" "" "" 'Estado: completado')"
# `preventiva` es SU PROPIO veredicto, no un matiz de aprobado. Sigue sin cerrar.
mkreq "$PROJ/requirements/REQ-082.md" "sí" "aprobado" "preventiva"
check "preventiva NO cierra un critico -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-082.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-084.md" "no" "pendiente" "pendiente"
check "preventiva desbloquea el ORDEN del ciclo -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-084.md" "" "" 'Seguridad: preventiva')"
# Medido por DOS proyectos: `aprobado (medido)` contaba y `**aprobado** (medido)` no,
# porque al normalizar el enfasis no envolvia el valor entero -- el parentesis estaba
# detras. Mismo valor, dos escrituras, veredictos opuestos: la asimetria de `n/a`.
mkreq "$PROJ/requirements/REQ-086.md" "no" "**aprobado** (medido el 3/9)" "n/a"
check "enfasis + evidencia: misma escritura, mismo veredicto -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-086.md" "" "" 'Estado: completado')"

# --- La cola de aprobaciones acaba donde acaba su seccion ----------------------
# Antes solo la cerraba una cabecera literal `## Resueltas`, asi que cualquier otra
# --`## Notas`, `## Historico`-- la dejaba abierta y sus `###` contaban como
# aprobaciones pendientes. Los proyectos lo esquivaban ordenando el archivo: carga,
# no estilo.
}
seccion_19() {
  seccion_nueva "Cola de aprobaciones: la seccion acaba en la siguiente cabecera:"
mkreq "$PROJ/requirements/REQ-085.md" "no" "aprobado" "n/a"
printf '## Pendientes\n\n## Notas\n### [2026-01-01] esto NO es una aprobacion\n- contexto\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "un ### bajo OTRA cabecera no es cola -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-085.md" "" "" 'Estado: completado')"
printf '## Pendientes\n### [2026-01-01] una aprobacion de verdad\n- contexto\n\n## Notas\n### otra cosa\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "...pero uno bajo Pendientes si -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-085.md" "" "" 'Estado: completado')"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"

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
}
seccion_20() {
  seccion_nueva "Continuidad automatica (hook Stop -> bloque derivado):"

EST_PROJ="$(mktemp -d)"
mkdir -p "$EST_PROJ/.arnes" "$EST_PROJ/requirements" "$EST_PROJ/docs"
cp "$PROJ/.arnes/config.json" "$EST_PROJ/.arnes/config.json"
# REQ-009: la cola se cuenta con LA REGLA DE LA PUERTA —encabezados `###`—, no con
# vinetas. Esta sonda escribia dos vinetas y esperaba 2; la puerta habria dicho 0 sobre
# ese mismo archivo, asi que el caso acreditaba un numero que no bloqueaba nada. Ahora la
# sonda escribe DOS ENTRADAS del formato documentado, con su cuerpo de vinetas debajo: el
# 2 que se comprueba es el mismo 2 que deniega el cierre.
printf '## Pendientes\n### [2026-09-05] (coordinadora) — decidir el proveedor\n- **Contexto** x\n- **Espera** aprobación\n\n### [2026-09-05] (coordinadora) — aprobar el borrado\n- **Contexto** y\n\n## Resueltas\n### [2026-09-01] (coordinadora) — otra\n' > "$EST_PROJ/PENDING_APPROVAL.md"
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

# Medido: el bloque decia 58 REQ y habia 57, porque contaba una nota sin `Estado:`.
# Y pesaba 10,4 KB con 58 filas, un 25 % de un ESTADO.md que se lee en CADA sesion.
printf '# Nota\nEsto NO tiene Estado y no es un REQ.\n' > "$EST_PROJ/requirements/consecuencias.md"
corre_estado "$EST_PROJ"
check_estado "una nota sin Estado: no cuenta como REQ"  "REQ:\*\* 2 "              si "$EST_PROJ/docs/ESTADO.md"
check_estado "...y se dice cuantas hay, no se esconden" "notas, no REQ):\*\* 1"    si "$EST_PROJ/docs/ESTADO.md"
check_estado "un REQ completado NO ocupa fila"          "^| REQ-001 "              no "$EST_PROJ/docs/ESTADO.md"
check_estado "un REQ abierto SI ocupa fila"             "^| REQ-002 "              si "$EST_PROJ/docs/ESTADO.md"

# `Estado:` lleva la MISMA regla que los veredictos: el parentesis es evidencia.
# Medido: sin esto el bloque decia 2 completados donde habia 9 y metia 44 REQ en
# "otros". La PUERTA no estaba afectada --caza el estado en el texto crudo-- asi que
# era un tablero que mentia; serio igual, porque el proyecto apago la continuidad.
printf '# REQ-020\nEstado: completado (2026-09-01)\nQA: aprobado\nSeguridad: n/a\n' > "$EST_PROJ/requirements/REQ-020.md"
corre_estado "$EST_PROJ"
check_estado "Estado con evidencia cuenta como completado" "REQ:\*\* 3 .* completado 2" si "$EST_PROJ/docs/ESTADO.md"
check_estado "...y no ocupa fila entre los abiertos"        "^| REQ-020 "                    no "$EST_PROJ/docs/ESTADO.md"
# La version instalada, visible en cada parada. Un proyecto real corrio 1.13.0 un MES
# con 1.24.0 publicada, sin ninguna senal. No se consulta la red: se ensena lo gratis.
check_estado "la version del plugin se ve en el bloque"     "plugin instalado"               si "$EST_PROJ/docs/ESTADO.md"

# --- Una ruta del manifiesto no puede salir del proyecto --------------------------
# `estado_derivado.archivo` y las `ruta` de rotacion se concatenaban tal cual: con
# `"archivo": "../fuera.md"` el hook de parada escribia FUERA del repositorio en cada
# parada. El manifiesto tambien lo puede escribir un agente y no lo protege guard-codigo.
EST_RAIZ="$(mktemp -d)"; EST_FUERA="$EST_RAIZ/proyecto"; mkdir -p "$EST_FUERA/.arnes" "$EST_FUERA/requirements" "$EST_FUERA/docs"
jq '.estado_derivado = {activo:true, archivo:"../fuera.md"}' "$PROJ/.arnes/config.json" > "$EST_FUERA/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$EST_FUERA/PENDING_APPROVAL.md"
corre_estado "$EST_FUERA"; EST_RC=$?
if [ ! -e "$EST_RAIZ/fuera.md" ]; then echo "  PASS  estado_derivado.archivo '../fuera.md' NO escribe fuera del proyecto"; PASS=$((PASS+1))
else echo "  FAIL  el bloque derivado se escribio FUERA del proyecto"; FAIL=$((FAIL+1)); fi
if [ "$EST_RC" -eq 0 ]; then echo "  PASS  ...y sigue saliendo 0"; PASS=$((PASS+1))
else echo "  FAIL  salio $EST_RC"; FAIL=$((FAIL+1)); fi
rm -rf "$EST_RAIZ"

# --- Contencion FISICA: un enlace simbolico no saca la escritura del proyecto ------
# La contencion lexica de 1.29.0 bloqueaba `..`, absolutas y `~`. Una revision externa
# reprodujo en 1.29.1 que `docs -> /externo` con `archivo: docs/ESTADO.md` escribia
# fuera. En Windows sin modo desarrollador `ln -s` no crea un enlace real, asi que aqui
# el caso sale SKIP y lo ejecuta el CI en Linux: es exactamente para lo que esta.
SYM_RAIZ="$(mktemp -d)"; SYM_P="$SYM_RAIZ/proyecto"; SYM_EXT="$SYM_RAIZ/externo"
mkdir -p "$SYM_P/.arnes" "$SYM_P/requirements" "$SYM_EXT"
ln -s "$SYM_EXT" "$SYM_P/docs" 2>/dev/null
if [ -L "$SYM_P/docs" ]; then
  jq '.estado_derivado = {activo:true, archivo:"docs/ESTADO.md"}' "$PROJ/.arnes/config.json" > "$SYM_P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$SYM_P/PENDING_APPROVAL.md"
  corre_estado "$SYM_P"; SYM_RC=$?
  if [ ! -e "$SYM_EXT/ESTADO.md" ]; then echo "  PASS  docs -> externo (symlink): el bloque derivado NO se escribe fuera"; PASS=$((PASS+1))
  else echo "  FAIL  el bloque derivado atraveso el symlink y se escribio FUERA"; FAIL=$((FAIL+1)); fi
  if [ "$SYM_RC" -eq 0 ]; then echo "  PASS  ...y sigue saliendo 0"; PASS=$((PASS+1))
  else echo "  FAIL  salio $SYM_RC"; FAIL=$((FAIL+1)); fi
else
  echo "  SKIP  docs -> externo (symlink): el bloque derivado NO se escribe fuera  (sin symlinks reales en esta plataforma)"
  echo "  SKIP  ...y sigue saliendo 0  (sin symlinks reales en esta plataforma)"
fi
rm -rf "$SYM_RAIZ"

# --- El banco no tenia TAMANO, y por eso no vio 92 segundos ----------------------
# Medido en un proyecto real: 47 REQ, 3,73 MB, uno de 244 KB, y el bloque derivado
# tardaba 92 s por parada leyendo linea a linea en bash. Con REQ de cinco lineas eso son
# microsegundos; el banco certificaba la correccion y no veia el coste. Estos casos no
# miden tiempo --un temporizador es fragil entre maquinas-- pero SI exigen que el bloque
# sea correcto sobre un fixture del tamano real, y que los campos se encuentren aunque
# esten a doscientas lineas de la cabecera.
EST_G="$(mktemp -d)"; mkdir -p "$EST_G/.arnes" "$EST_G/requirements" "$EST_G/docs"
cp "$PROJ/.arnes/config.json" "$EST_G/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$EST_G/PENDING_APPROVAL.md"
EST_RELLENO="$(printf 'Esta linea documenta la historia del requerimiento con detalle suficiente para pesar lo que pesa uno real.\n%.0s' $(seq 1 700))"
for i in $(seq -w 1 47); do
  EST_ST=en-revisión; [ "$((10#$i % 3))" -eq 0 ] && EST_ST=completado
  { printf '# REQ-%s\nEstado: %s\nSensible a seguridad: no\nQA: aprobado (medido)\nSeguridad: n/a\n\n## Historia\n' "$i" "$EST_ST"; printf '%s' "$EST_RELLENO"; } > "$EST_G/requirements/REQ-$i.md"
done
# Un REQ con los veredictos DESPUES de doscientas lineas de historia: se encuentran igual.
{ printf '# REQ-099\nEstado: en-revisión\n\n## Historia\n'; printf '%s' "$EST_RELLENO"; printf '\nQA: con-hallazgos\nRigor: critico\nHallazgos abiertos: SEC-1 (usuario/dinero)\n'; } > "$EST_G/requirements/REQ-099.md"
corre_estado "$EST_G"
check_estado "47 REQ grandes (3,7 MB): el bloque los cuenta todos"    "REQ:\*\* 48 "                       si "$EST_G/docs/ESTADO.md"
check_estado "...y los 15 completados salen como completados"          "completado 15 "                      si "$EST_G/docs/ESTADO.md"
# Los campos valen SOLO en la cabecera. Ayer este mismo banco fijaba lo contrario --"campos
# a 200 lineas de la cabecera se encuentran igual"-- porque eso hacia el codigo. Medido hoy:
# una linea `Seguridad: aprobado (A-009, 2026-09-02)` dentro de `## Historial` se leia como
# EL veredicto y cerraba un REQ critico con la cabecera en pendiente. El caso se da la
# vuelta: lo que hay dentro de una seccion NO es un campo.
# REQ-010: la celda muestra el valor NORMALIZADO (`en-revision`), que es el que aplica la
# puerta. CA-16 lo exige: puerta, informe y bloque derivado tienen que coincidir caracter a
# caracter, y desde 1.31.0 el acento ya no es parte del valor.
check_estado "campos DENTRO de una seccion NO se leen: QA queda vacio"  "^| REQ-099 | en-revision | — | — | estandar | — |" si "$EST_G/docs/ESTADO.md"
check_estado "...y Rigor cae al defecto, no al 'critico' de la historia" "^| REQ-099 | en-revisión | — | — | critico"      no "$EST_G/docs/ESTADO.md"
rm -rf "$EST_G"

# Un .md VACIO es un archivo sin Estado y se cuenta como nota, como antes de 1.29.3:
# awk no emite linea para un archivo sin lineas, y desaparecia del conteo en silencio.
: > "$EST_PROJ/requirements/vacio.md"
corre_estado "$EST_PROJ"
check_estado "un .md VACIO cuenta como nota, no desaparece" "notas, no REQ):\*\* 2" si "$EST_PROJ/docs/ESTADO.md"
rm -f "$EST_PROJ/requirements/vacio.md"

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
}
seccion_21() {
  seccion_nueva "Rotacion de artefactos (mover, nunca resumir):"

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

# --- El orden es del ARTEFACTO, no del proyecto -------------------------------
# Medido en un proyecto real: el CHANGELOG crece por arriba y el registro de
# seguridad por abajo. Con un `orden` global la rotacion era inservible para uno de
# los dos, y equivocarse archiva lo MAS RECIENTE. `artefactos` acepta cadena u
# objeto, la misma convencion que las quality_gates: la cadena hereda lo global.
ROT_M="$(mktemp -d)"; mkdir -p "$ROT_M/.arnes" "$ROT_M/seg"
cat > "$ROT_M/.arnes/config.json" <<JSON
{ "agentes": { "agente_codigo": "desarrollador" },
  "rotacion": { "activo": true, "umbral_bytes": 400, "conservar_secciones": 2,
                "artefactos": [ "CHANGELOG.md",
                                { "ruta": "seg/registro.md", "orden": "nuevo-al-final", "conservar_secciones": 1 } ] } }
JSON
for n in CHANGELOG.md seg/registro.md; do
  { printf '# %s\n\n' "$n"; for v in 5 4 3 2 1; do printf '## [1.%s.0]\n' "$v"; for i in 1 2 3; do printf 'relleno %s de 1.%s.0 con texto suficiente\n' "$i" "$v"; done; printf '\n'; done; } > "$ROT_M/$n"
done
rot_corre "$ROT_M"
rot_check "artefacto como CADENA sigue funcionando (compatibilidad)" "## [1.5.0] ## [1.4.0]" \
  "$(grep -o '^## \[1\.[0-9]*\.0\]' "$ROT_M/CHANGELOG.md" | tr '\n' ' ' | sed 's/ $//')"
rot_check "...y el OBJETO usa SU orden, opuesto, en la misma pasada" "## [1.1.0]" \
  "$(grep -o '^## \[1\.[0-9]*\.0\]' "$ROT_M/seg/registro.md" | tr '\n' ' ' | sed 's/ $//')"
rot_check "...y SU conservar_secciones, distinto del global" "1" \
  "$(grep -c '^## ' "$ROT_M/seg/registro.md")"
rm -rf "$ROT_M"

# --- Un artefacto CRLF rota igual que uno LF -----------------------------------
# En Windows la mayoria de los archivos son CRLF, y este banco los escribia todos
# con LF: por eso no lo vio. Medido en un proyecto real: el registro de seguridad
# (12 857 CRLF) creaba su archivo y NO recortaba el origen, en silencio y con exit 0.
# Peor que inoperante: el contenido quedaba en los dos sitios y cada parada lo volvia
# a anadir -- 3, 6, 9 secciones en tres pasadas. Una fuga sin tope, justo en la
# funcion cuyo proposito es frenar el crecimiento sin tope.
ROT_CR="$(mktemp -d)"; mkdir -p "$ROT_CR/.arnes"
cat > "$ROT_CR/.arnes/config.json" <<JSON
{ "agentes": { "agente_codigo": "desarrollador" },
  "rotacion": { "activo": true, "umbral_bytes": 400, "conservar_secciones": 2,
                "artefactos": ["LF.md","CRLF.md"] } }
JSON
rot_gen() { printf '# %s\n\n' "$1"; for v in 5 4 3 2 1; do printf '## [1.%s.0]\n' "$v"; for i in 1 2 3; do printf 'relleno %s de 1.%s.0 con texto suficiente\n' "$i" "$v"; done; printf '\n'; done; }
rot_gen LF > "$ROT_CR/LF.md"
rot_gen CRLF | sed 's/$/\r/' > "$ROT_CR/CRLF.md"
# Tres pasadas: la fuga solo se ve repitiendo.
rot_corre "$ROT_CR"; rot_corre "$ROT_CR"; rot_corre "$ROT_CR"
rot_check "un artefacto CRLF rota igual que uno LF" "2-3" \
  "$(rot_sec "$ROT_CR/CRLF.md")-$(rot_sec "$ROT_CR/CRLF-archivo.md")"
rot_check "...y no duplica: tres pasadas, mismo reparto" "2-3" \
  "$(rot_sec "$ROT_CR/LF.md")-$(rot_sec "$ROT_CR/LF-archivo.md")"
rot_check "nada se pierde con CRLF: origen + archivo = total" "5" \
  "$(( $(rot_sec "$ROT_CR/CRLF.md") + $(rot_sec "$ROT_CR/CRLF-archivo.md") ))"
# Se MUEVE tal cual: el final de linea del contenido no se toca.
rot_check "el contenido movido conserva su CRLF" "si" \
  "$([ "$(tr -cd '\r' < "$ROT_CR/CRLF-archivo.md" | wc -c)" -gt 0 ] && echo si || echo no)"
# Si la verificacion falla, no puede quedar medio hecho ni dejar basura.
rot_check "sin temporales huerfanos" "0" \
  "$(ls "$ROT_CR"/*.arnes.tmp 2>/dev/null | wc -l)"
rm -rf "$ROT_CR"

# La misma regla para la rotacion: una `ruta` fuera del proyecto no se toca.
ROT_RAIZ="$(mktemp -d)"; ROT_FUERA="$ROT_RAIZ/proyecto"; mkdir -p "$ROT_FUERA/.arnes"
printf '# fuera\n\n## [1.5.0]\nx\n\n## [1.4.0]\nx\n\n## [1.3.0]\nx\n' > "$ROT_RAIZ/fuera.md"; ROT_ANTES="$(wc -c < "$ROT_RAIZ/fuera.md")"
printf '{ "agentes": { "agente_codigo": "desarrollador" }, "rotacion": { "activo": true, "umbral_bytes": 10, "conservar_secciones": 1, "artefactos": ["../fuera.md"] } }' > "$ROT_FUERA/.arnes/config.json"
rot_corre "$ROT_FUERA"
rot_check "rotacion con ruta '../fuera.md' NO toca nada fuera del proyecto" "$ROT_ANTES-no" \
  "$(wc -c < "$ROT_RAIZ/fuera.md")-$([ -e "$ROT_RAIZ/fuera-archivo.md" ] && echo si || echo no)"
rm -rf "$ROT_RAIZ"

# La misma contencion fisica para la rotacion: un artefacto bajo un directorio enlazado
# hacia fuera no se toca. SKIP donde no hay symlinks reales; lo ejecuta el CI en Linux.
SYR_RAIZ="$(mktemp -d)"; SYR_P="$SYR_RAIZ/proyecto"; SYR_EXT="$SYR_RAIZ/externo"
mkdir -p "$SYR_P/.arnes" "$SYR_EXT"
ln -s "$SYR_EXT" "$SYR_P/bitacoras" 2>/dev/null
if [ -L "$SYR_P/bitacoras" ]; then
  printf '# fuera\n\n## [1.5.0]\nx\n\n## [1.4.0]\nx\n\n## [1.3.0]\nx\n' > "$SYR_EXT/LOG.md"; SYR_ANTES="$(wc -c < "$SYR_EXT/LOG.md")"
  printf '{ "agentes": { "agente_codigo": "desarrollador" }, "rotacion": { "activo": true, "umbral_bytes": 10, "conservar_secciones": 1, "artefactos": ["bitacoras/LOG.md"] } }' > "$SYR_P/.arnes/config.json"
  rot_corre "$SYR_P"
  rot_check "rotacion bajo un directorio symlink hacia fuera NO toca el externo" "$SYR_ANTES-no" \
    "$(wc -c < "$SYR_EXT/LOG.md")-$([ -e "$SYR_EXT/LOG-archivo.md" ] && echo si || echo no)"
else
  echo "  SKIP  rotacion bajo un directorio symlink hacia fuera NO toca el externo  (sin symlinks reales en esta plataforma)"
fi
rm -rf "$SYR_RAIZ"

# `umbral_bytes` mide BYTES. Un archivo UTF-8 de ~4 000 bytes y ~2 000 caracteres con umbral
# 3 000 rotaba en 1.29.2 y dejo de rotar en 1.29.3, cuando ${#texto} sustituyo a wc -c.
ROT_U="$(mktemp -d)"; mkdir -p "$ROT_U/.arnes"
printf '{ "agentes": { "agente_codigo": "desarrollador" }, "rotacion": { "activo": true, "umbral_bytes": 3000, "conservar_secciones": 1, "artefactos": ["UTF8.md"] } }' > "$ROT_U/.arnes/config.json"
{ printf '# UTF8\n\n'; for v in 3 2 1; do printf '## [1.%s.0]\n' "$v"; for i in $(seq 1 12); do printf 'áéíóú áéíóú áéíóú áéíóú áéíóú áéíóú áéíóú áéíóú áéíóú áéíóú\n'; done; printf '\n'; done; } > "$ROT_U/UTF8.md"
ROT_UB="$(LC_ALL=C; t="$(cat "$ROT_U/UTF8.md")"; printf '%s' "${#t}")"
rot_corre "$ROT_U"
rot_check "umbral_bytes mide BYTES: UTF-8 de ${ROT_UB} bytes (< chars×2) con umbral 3000 ROTA" "1" "$(rot_sec "$ROT_U/UTF8.md")"
rm -rf "$ROT_U"

# Inerte en repo ajeno, como el resto de hooks.
ROT_AJENO="$(mktemp -d)"; printf '# CHANGELOG de OTRO\n## [9.9.9]\nx\n' > "$ROT_AJENO/CHANGELOG.md"
rot_corre "$ROT_AJENO"; ROT_RC=$?
rot_check "sin manifiesto no toca nada y sale 0" "1-0" "$(rot_sec "$ROT_AJENO/CHANGELOG.md")-$ROT_RC"
rm -rf "$ROT_AJENO"

}
seccion_22() {
# --- hooks.json: la forma que hace que Bash de lectura NO arranque el guard -------
# Los hooks del plugin se declaran en hooks.json y Claude Code evalua el `if` de cada
# handler ANTES de crear el proceso (verificado en 2.1.260 con control positivo). El
# banco no puede probar ese motor --es de Claude Code--, pero SI puede fijar la forma
# del archivo: si alguien anade un handler Bash sin `if`, todos los `ls` vuelven a
# pagar el interprete y nadie lo nota, porque nada falla: solo se vuelve lento.
seccion_nueva "hooks.json (la forma que NO deja Bash sin guardian):"
HJ="$HOOKS_DIR/hooks.json"
hj_check() {   # <nombre> <esperado> <obtenido>
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=$2 obtenido=$3"; FAIL=$((FAIL+1)); fi
}
hj_check "es JSON valido" "ok" "$(jq -e . "$HJ" >/dev/null 2>&1 && echo ok || echo roto)"
# NINGUN handler lleva `if`. 1.25.0 puso uno por disparador para que un `ls` no arrancara
# el guardian, y `if` funciona --medido con control positivo-- pero SOLO para prefijos de
# comando: una redireccion NUNCA casa, porque Claude Code la separa del comando antes de
# evaluar el patron. Medido en un proyecto real: `echo 'Estado: completado' > requirements/x`
# paso y creo el archivo. Como la redireccion puede ir en cualquier comando, la unica puerta
# posible para Bash es la que ve TODOS. Este caso existe para que nadie vuelva a "optimizar"
# esto sin pasar por aqui: la version anterior de este mismo banco EXIGIA el `if`, y eso
# certificaba la forma que dejaba la puerta en abierto.
hj_check "NINGUN handler lleva if: la redireccion no se puede seleccionar con if" "0" \
  "$(jq -r '[.hooks.PreToolUse[] | .hooks[] | select(has("if"))] | length' "$HJ")"
hj_check "un solo grupo cubre Edit|Write|MultiEdit|Bash" "1" \
  "$(jq -r '[.hooks.PreToolUse[] | select(.matcher=="Edit|Write|MultiEdit|Bash")] | length' "$HJ")"
hj_check "Bash esta en el matcher (la puerta de consola existe)" "true" "$(jq -r '[.hooks.PreToolUse[].matcher | select(split("|") | index("Bash") != null)] | length > 0' "$HJ")"
hj_check "todos los handlers PreToolUse apuntan a guard.sh" "0" \
  "$(jq -r '[.hooks.PreToolUse[] | .hooks[] | select(.command | endswith("/hooks/guard.sh") | not)] | length' "$HJ")"
hj_check "Stop y SubagentStop: UN solo proceso, stop.sh" "stop.sh-stop.sh" \
  "$(jq -r '.hooks.Stop[0].hooks | map(.command | split("/") | last) | join(",")' "$HJ")-$(jq -r '.hooks.SubagentStop[0].hooks | map(.command | split("/") | last) | join(",")' "$HJ")"

# --- stop.sh: el segundo paso sigue corriendo tras el primero ---------------------
# Mismo caso que "guard.sh: el 2o guardian sigue corriendo tras el 1o": si la
# continuidad terminara el proceso, la rotacion nunca correria y nadie lo veria.
# (misma seccion: comparte proyecto con la de arriba)
echo "stop.sh (continuidad y rotacion en un proceso):"
ST="$(mktemp -d)"; mkdir -p "$ST/.arnes" "$ST/requirements" "$ST/docs"
jq '.rotacion = {activo:true, umbral_bytes:500, conservar_secciones:2, artefactos:["CHANGELOG.md"]}' "$PROJ/.arnes/config.json" > "$ST/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$ST/PENDING_APPROVAL.md"
printf '# REQ-001\nEstado: en-revisión\nQA: pendiente\nSeguridad: n/a\n' > "$ST/requirements/REQ-001.md"
{ printf '# CHANGELOG\n\n'; for v in 5 4 3 2 1; do printf '## [1.%s.0]\n' "$v"; for i in 1 2 3 4; do printf 'relleno %s de 1.%s.0 para que pese\n' "$i" "$v"; done; printf '\n'; done; } > "$ST/CHANGELOG.md"
: > "$ERRLOG"
CLAUDE_PROJECT_DIR="$ST" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}' | CLAUDE_PROJECT_DIR="$ST" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"; ST_RC=$?
hj_check "stop.sh sale 0 (no bloquea la parada)" "0" "$ST_RC"
hj_check "la continuidad escribio su bloque" "1" "$(grep -c 'ARNES:DERIVADO inicio' "$ST/docs/ESTADO.md" 2>/dev/null || echo 0)"
hj_check "...y la rotacion corrio EN LA MISMA parada" "2" "$(grep -c '^## ' "$ST/CHANGELOG.md")"
rm -rf "$ST"

}
seccion_23() {
seccion_nueva "INERTE — sin manifiesto, el hook no estorba:"
PROJ2="$(mktemp -d)"; mkdir -p "$PROJ2/src"; export CLAUDE_PROJECT_DIR="$PROJ2"
check "sin .arnes/config.json, guard.sh no estorba -> allow" allow guard.sh "$(jq -n --arg fp "$PROJ2/src/x.ts" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:"x",new_string:"y"}}')"
check "sin .arnes/config.json edita src/ -> allow" allow guard-codigo.sh "$(jq -n --arg fp "$PROJ2/src/x.ts" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:"x",new_string:"y"}}')"
check "sin .arnes/config.json escribe por Bash -> allow" allow guard-codigo.sh "$(emite_bash 'echo x > src/x.ts' "" "")"
rm -rf "$PROJ2"

}

seccion_24() {
seccion_nueva "tools/arnes-lectura.sh (el informe tiene que poder decir que algo esta mal):"
# FALLO EN ABIERTO medido (1.30.1): el contador de anomalias se incrementaba dentro de un
# subshell y el informe decia «Ningún valor anómalo» y salia 0 con cuatro REQ fuera del
# vocabulario en un proyecto real. Un informe que siempre dice que todo esta bien es peor
# que no tenerlo: estos casos exigen que sepa decir que NO.
if [ -z "$FILTRO" ] || printf '%s' "arnes-lectura" | grep -qi -- "$FILTRO"; then
LECTURA="$HOOKS_DIR/../tools/arnes-lectura.sh"
mkreq "$PROJ/requirements/REQ-240.md" "no" "aprobado con residual declarado" "n/a"
mkreq "$PROJ/requirements/REQ-241.md" "no" "aprobado" "n/a"
salida="$(bash "$LECTURA" "$PROJ" 2>"$ERRLOG")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$salida" | grep -q 'aprobadoconresidualdeclarado'; then
  echo "  PASS  arnes-lectura: un veredicto fuera del vocabulario sale 1 y lo nombra"; PASS=$((PASS+1))
else
  echo "  FAIL  arnes-lectura: un veredicto fuera del vocabulario: rc=$rc (esperado 1)"; diag
  printf '%s\n' "$salida" | head -12 | sed 's/^/          salida| /'; FAIL=$((FAIL+1))
fi
if printf '%s' "$salida" | grep -q 'NO LEE COMO ESTÁN ESCRITOS (1)'; then
  echo "  PASS  arnes-lectura: ...y cuenta 1 anomalia, no 0"; PASS=$((PASS+1))
else
  echo "  FAIL  arnes-lectura: ...el contador no dice 1"; FAIL=$((FAIL+1))
fi
mkreq "$PROJ/requirements/REQ-240.md" "no" "aprobado" "n/a"
salida="$(bash "$LECTURA" "$PROJ" 2>"$ERRLOG")"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$salida" | grep -q 'Ningún valor anómalo'; then
  echo "  PASS  arnes-lectura: control, con todo en vocabulario sale 0 y lo dice"; PASS=$((PASS+1))
else
  echo "  FAIL  arnes-lectura: control: rc=$rc (esperado 0)"; diag; FAIL=$((FAIL+1))
fi
fi

}

seccion_25() {
  seccion_nueva "DEV REQ-001 v3: presupuesto de analisis y coste lineal (QA-007):"
# ============================================================================
# DEV REQ-001 v3 — el eje que quedaba de QA-007 y el presupuesto que lo tapa.
#
# QA-007 midio que el coste seguia siendo CUADRATICO en el tamano de UNA linea del
# cuerpo: 4.000 expansiones 5,1 s (rompe CA-40/CA-48), 8.000 18,0 s, 16.000 NO RESPONDE
# en 60 s -> el hook muere, `guard.sh` recibe salida vacia y PERMITE. La causa medida:
# avanzar con `${r#*...}` COPIA el resto de la cadena en cada paso.
#
# Arreglo: el texto se PARTE UNA VEZ (troceado por IFS, dentro de bash, sin procesos) y
# los trozos se unen UNA vez. Nada se copia por paso. MEDIDO en Linux/WSL2 2026-09-05,
# de punta a punta con `guard-codigo.sh`, una linea de N expansiones + escritura real:
#   N     antes (vuelta 1)        ahora
#   500   210 ms                  212 ms
#   2.000 1.313 ms                212 ms
#   4.000 5.118 ms                410 ms
#   8.000 18.037 ms               814 ms
#  16.000 >60 s -> ALLOW          212 ms (deny por presupuesto)
#
# Y ADEMAS EL PRESUPUESTO. Un algoritmo lineal tambien tiene acantilado: basta una
# entrada 100 veces mayor. Por eso, por encima de `ARNES_BASH_MAX_ANALISIS` (64 KiB de
# MATERIAL ANALIZADO, ver lib.sh) el hook no analiza y DENIEGA diciendo como salir.
# Falla cerrado y a tiempo, en vez de abierto y por agotamiento.
# ============================================================================

# --- 1) El eje de QA-007, en el tamano que antes mataba al hook ---------------
# 16.000 expansiones en UNA linea. Antes: sin respuesta en 60 s -> salida vacia -> allow
# -> el shell creaba `src/qa7.ts` (verificado en sandbox por QA). Ahora: deny inmediato.
cronometra_bash "DEV v3: UNA linea con 16.000 expansiones + escritura real -> deny" deny 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(yes '$(date)' | head -16000 | tr -d '\n')")" "" "")"
# Control obligatorio: sin el, un deny rapido no distingue "el arreglo funciona" de
# "la sonda no llego a construir el caso".
cronometra_bash "DEV v3: control, la misma escritura sin el cuerpo -> deny" deny 5000 \
  "$(emite_bash 'echo x > src/qa7.ts' "" "")"

# --- 2) La frontera del presupuesto, medida al byte ---------------------------
# El presupuesto cuenta (a) los bytes de las lineas del cuerpo SIN CITAR que llevan
# expansion y (b) los bytes del comando fuera de los cuerpos. Aqui (b) son 29 bytes
# (`cat <<EOF` + `echo x > src/qa7.ts`; la linea del delimitador de cierre no cuenta),
# asi que la frontera exacta esta en una linea de cuerpo de 65.507 bytes. MEDIDO: 65.507
# se analiza, 65.508 se deniega por tamano. Los dos casos DENIEGAN — lo que se comprueba
# es POR QUE, que es justo lo que un `deny` a secas no distingue.
cuerpo_de() {   # <bytes> -> una linea de cuerpo de exactamente ese tamano, densa en `$(date)`
  local n="$1" u='$(date)' s r
  s="$(yes "$u" | head -$(( n / ${#u} )) | tr -d '\n')"
  r=$(( n - ${#s} ))
  printf '%s%s' "$s" "$(printf '%*s' "$r" '' | tr ' ' 'a')"
}
check_motivo "DEV v3: 1 byte POR DEBAJO del presupuesto -> analiza y nombra la ruta" \
  "escribe en 'src/qa7\.ts'" guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 65507)")" "" "")"
check_motivo "DEV v3: 1 byte POR ENCIMA del presupuesto -> deny por tamano, con salida" \
  "demasiado grande para analizarlo con garantia.*heredoc CITADO" guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 65508)")" "" "")"

# --- 3) El presupuesto NO toca el camino legitimo -----------------------------
# Escribir un archivo grande con un heredoc CITADO es la forma normal de hacerlo y la
# usan todos los agentes: el cuerpo se descuenta entero sin analizarse. 300 KB tienen
# que seguir siendo `allow` y seguir siendo baratos. Si el presupuesto se hubiera puesto
# sobre el TAMANO DEL COMANDO, este caso se habria vuelto rojo — y con el, el trabajo
# normal de todo el mundo.
GRANDE_CITADO="$(yes 'texto de relleno de cien bytes para llegar a trescientos kilobytes sin ninguna expansion aqu' | head -3000)"
cronometra_bash "DEV v3: heredoc CITADO de ~300 KB -> allow y barato" allow 1000 \
  "$(emite_bash "$(printf "cat > docs/x.md <<'EOF'\n%s\nEOF" "$GRANDE_CITADO")" "" "")"
# CA-28 en grande: sin citar pero SIN expansiones, el cuerpo tambien se descuenta entero.
cronometra_bash "DEV v3: heredoc SIN citar de ~300 KB SIN expansiones -> allow" allow 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF' "$GRANDE_CITADO")" "" "")"
# CONTROL POSITIVO de los dos de arriba: un `allow` sobre una entrada de 300 KB tambien
# lo produce un hook que murio. Con la MISMA entrada mas una escritura real fuera del
# heredoc, el hook tiene que seguir denegando.
check "DEV v3: control, los mismos 300 KB citados + escritura real -> deny" deny guard-codigo.sh \
  "$(emite_bash "$(printf "cat > docs/x.md <<'EOF'\n%s\nEOF\necho x > src/grande.ts" "$GRANDE_CITADO")" "" "")"

# DEV 1.31.0 v3 (QA-111): LO QUE EL CASO DE ARRIBA QUERIA ACREDITAR, SIN RELOJ.
# «El heredoc citado se descuenta ENTERO y no entra en el presupuesto de analisis» es una
# propiedad DISCRETA, y hasta v3 se comprobaba de la peor forma posible: cronometrando.
# Se comprueba directamente, y por el MOTIVO, que es donde el hook dice por que decidio:
#   - si los 300 KB citados hubieran entrado en el presupuesto (64 KiB), la respuesta
#     seria el deny POR TAMANO, no el deny por la ruta;
#   - que el motivo NOMBRE la ruta prueba ademas que el analisis SI corrio y SI vio la
#     escritura de fuera del heredoc — un hook muerto no nombra ninguna ruta.
# Los dos hechos juntos son exactamente la propiedad, y ninguno depende de la carga de
# la maquina. El caso cronometrado de arriba se queda como MEDICION del coste.
check_motivo "DEV 1.31.0 v3: QA-111 los 300 KB CITADOS se descuentan enteros: deny POR LA RUTA" \
  "escribe en 'src/grande\.ts'" guard-codigo.sh \
  "$(emite_bash "$(printf "cat > docs/x.md <<'EOF'\n%s\nEOF\necho x > src/grande.ts" "$GRANDE_CITADO")" "" "")"
# La otra mitad, explicita: el motivo NO puede ser el del presupuesto. Sin este control,
# un dia en que el descuento se rompa el caso de arriba seguiria en rojo pero nadie
# sabria si es por tamano o por otra cosa; y si ademas cambiara el orden de las puertas,
# un deny por tamano podria colarse como acierto.
MOT_CIT="$(corre guard-codigo.sh "$(emite_bash "$(printf "cat > docs/x.md <<'EOF'\n%s\nEOF\necho x > src/grande.ts" "$GRANDE_CITADO")" "" "")" | jq -r '.hookSpecificOutput.permissionDecisionReason // empty' 2>/dev/null)"
if printf '%s' "$MOT_CIT" | grep -q 'demasiado grande para analizarlo'; then
  echo "  FAIL  DEV 1.31.0 v3: QA-111 ...y NO por el presupuesto de analisis  motivo=<${MOT_CIT:0:120}>"; diag; FAIL=$((FAIL+1))
else
  echo "  PASS  DEV 1.31.0 v3: QA-111 ...y NO por el presupuesto de analisis"; PASS=$((PASS+1))
fi

# --- 4) Lineal tambien en LINEAS, con analisis de verdad ----------------------
# 4.000 lineas de cuerpo con expansion y comillas son 64.000 bytes: caben JUSTO bajo el
# presupuesto, asi que este caso mide el analisis real y no el atajo del techo. Que el
# motivo nombre la ruta es lo que lo acredita.
check_motivo "DEV v3: 4.000 lineas de cuerpo bajo el presupuesto -> analiza y nombra la ruta" \
  "escribe en 'src/robado\.ts'" guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/robado.ts' "$(yes "\$(date) 'x' \"y\"" | head -4000)")" "" "")"

# --- 5) El presupuesto tambien cierra la puerta del CIERRE DE REQ -------------
# `guard-completado` comparte el detector. Si no mira el codigo de salida, una entrada
# sobre el techo le llega como "no escribe nada" -> allow, que es el fallo en abierto de
# siempre por otra puerta. Aqui la denegacion alcanza a TODOS los agentes, porque la
# regla que aplica este guardian tambien alcanza a todos.
check_motivo "DEV v3: sobre el presupuesto, guard-completado deniega por tamano" \
  "demasiado grande para analizarlo con garantia" guard-completado.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\nsed -i s/x/y/ requirements/REQ-001.md' "$(cuerpo_de 70000)")" "" "")"
# ...y NO alcanza al agente de codigo por la puerta de `guard-codigo`: a el ya se le
# permitia escribir, asi que el techo no le quita nada.
check "DEV v3: sobre el presupuesto, guard-codigo NO estorba al desarrollador -> allow" allow guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 70000)")" "a1" "arnes-juan:desarrollador")"
check "DEV v3: ...y al qa-tester si -> deny" deny guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 70000)")" "a2" "arnes-juan:qa-tester")"

# --- 6) La clave opcional del manifiesto --------------------------------------
# `limites.bash_max_analisis` es OPCIONAL: el defecto vive en el codigo y ningun
# proyecto tiene que declararla. Se prueba en las dos direcciones, porque una clave que
# solo se lee cuando conviene no se esta leyendo.
setcfg '.limites = {bash_max_analisis: 4194304}'
check_motivo "DEV v3: con el techo subido en el manifiesto, la misma entrada SI se analiza" \
  "escribe en 'src/qa7\.ts'" guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 70000)")" "" "")"
# ...y la clave solo puede SUBIR el techo, nunca bajarlo por debajo del que trae el
# codigo: el manifiesto se lee con `jq` y el camino comun no puede pagar un proceso por
# comando, asi que el defecto se aplica sin preguntar. Un techo de 64 bytes escrito a
# mano NO convierte en "no analizable" un comando que la puerta sabe analizar.
setcfg '.limites = {bash_max_analisis: 64}'
check_motivo "DEV v3: el manifiesto NO puede bajar el techo por debajo del defecto" \
  "escribe en 'src/qa7\.ts'" guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(date) una linea corta pero de mas de sesenta y cuatro bytes de largo\nEOF\necho x > src/qa7.ts' "" "")"
# Una errata en el manifiesto NO puede desactivar la puerta: valor no numerico -> manda
# el defecto del codigo, y una entrada normal se sigue analizando.
setcfg '.limites = {bash_max_analisis: "mucho"}'
check_motivo "DEV v3: techo con errata -> manda el defecto del codigo, no se desactiva nada" \
  "escribe en 'src/qa7\.ts'" guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/qa7.ts)\nEOF' "" "")"
# QA 1.31.0: HALLAZGO QA-103 — el motivo del techo imprime el NOMBRE de la variable en
# vez de su valor (`\$ARNES_BASH_MAX_MANIFIESTO` va escapado en guard-codigo.sh:88 y en
# guard-completado.sh:54). Quien lee la denegacion no sabe hasta donde puede subir el
# techo. Un deny que no se puede accionar es un deny a medias.
check_motivo "QA-103 el motivo del techo imprime el maximo en BYTES, no el nombre de la variable" \
  "hasta un maximo de 131072 bytes" guard-codigo.sh \
  "$(emite_bash "$(printf 'echo "%s" > src/qa103.ts' "$(printf 'a%.0s' $(seq 1 70000))")" "" "")"
setcfg 'del(.limites)'

# --- 7) QA-013: `\$(` escapado no es una sustitucion --------------------------
# bash imprime el texto literal y no ejecuta nada, asi que denegarlo era un falso
# positivo en un detector cuyo sesgo declarado es el contrario. Se cuenta la barra
# invertida por PARIDAD: `\$(` no ejecuta, `\\$(` SI (la primera barra escapa a la
# segunda). Los tres casos juntos son la prueba; uno solo no lo seria.
check "DEV v3: QA-013, \$( escapado en el cuerpo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n\\$(cp README.md src/f3.ts)\nEOF' "" "")"
check "DEV v3: QA-013, barra ESCAPADA antes de \$( (bash si ejecuta) -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n\\\\$(cp README.md src/f3.ts)\nEOF' "" "")"
check "DEV v3: QA-013, control, sin barra ninguna -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(cp README.md src/f3.ts)\nEOF' "" "")"

# --- 8) QA REQ-001 v3: HALLAZGO QA-015 ---------------------------------------
# El recorte por fragmento toma el prefijo hasta el PRIMER `)` (`${p[i]%%')'*}`), sin
# mirar comillas ni anidamiento. Todo lo que venga DESPUES de ese `)` dentro de la misma
# sustitucion se pierde — incluida la redireccion. Los tres casos siguientes crean el
# archivo en un shell REAL (verificado en sandbox por QA) y hoy salen `allow`.
#
# NO es limitacion heredada: el arbol `6cb348a`, ANTERIOR al primer arreglo de este
# mismo REQ, DENIEGA los tres (alli se conservaba la LINEA entera). El comentario de
# `_arnes_expansiones` afirma del anidamiento "Es mas cobertura, nunca menos": medido,
# es menos. Ver docs/qa/REQ-001.md §8.
check "QA v3: expansion ANIDADA, la escritura va tras el ) interior -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(cat "$(ls README.md)" > src/n12.ts)\nEOF' "" "")"
check "QA v3: un ) dentro de comillas trunca el fragmento -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo "a)b" > src/n3.ts)\nEOF' "" "")"
check "QA v3: parentesis literal entrecomillado en la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo "(hola)" > src/n10.ts)\nEOF' "" "")"
# Controles obligatorios: sin ellos un deny futuro no distingue "se arreglo el recorte"
# de "se volvio a analizar la linea entera", que es el falso positivo de 1.29.1.
check "QA v3: control, la misma expansion SIN ) interior -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/n9.ts)\nEOF' "" "")"
check "QA v3: control, la misma forma SIN heredoc ya se detecta -> deny" deny guard-codigo.sh \
  "$(emite_bash $'echo $(echo "a)b" > src/n3.ts)' "" "")"
check "QA v3: control, el acento grave NO trunca en el ) -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n`echo "a)b" > src/bt.ts`\nEOF' "" "")"
# Control de FALSO POSITIVO (CA-49): el texto que sigue al cierre REAL de la expansion
# sigue siendo texto y no puede volver a leerse como comando.
check "QA v3: control CA-49, texto tras el cierre real de la expansion -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nver $(basename "$(pwd)") y luego cp README.md src/x.ts\nEOF' "" "")"

# --- 9) DEV REQ-001 v4: el cierre se decide por PROFUNDIDAD, no por el primer ) -----
# El arreglo de QA-015 no consiste en "mirar tambien las comillas": consiste en que el
# fragmento termina donde la profundidad de parentesis vuelve a cero, contando solo los
# parentesis que NO estan entrecomillados. Estos cuatro casos fijan las cuatro esquinas
# de esa regla; sin ellos, un arreglo futuro podria volver a cortar en el primer `)` y
# solo se enterarian los tres casos de QA-015.
#
# (a) El `)` INTERIOR de una sustitucion anidada no cierra la exterior, y la escritura
#     puede estar en el interior: el fragmento de fuera se la lleva igual.
check "DEV v4: anidada con la escritura DENTRO del interior -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(x $(echo y > src/w1.ts) z)\nEOF' "" "")"
# (b) Las comillas SIMPLES tapan el `)` igual que las dobles. Se prueban las dos formas
#     porque el descuento las trata por separado y una sola no acredita a la otra.
check "DEV v4: un ) entre comillas SIMPLES no cierra el fragmento -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \'a)b\' > src/w2.ts)\nEOF' "" "")"
# (c) Desbalanceado: si la profundidad NUNCA vuelve a cero, el fragmento es el resto de
#     la linea. Es fail-closed a proposito, y aqui SOBREDETECTA: verificado en un sandbox
#     real, bash NO ejecuta esta linea (la sustitucion no cierra y es un error de
#     sintaxis), asi que no crea el archivo. Se deniega igual porque el hook trabaja
#     LINEA A LINEA y una sustitucion abierta puede cerrar en la siguiente, que es la
#     limitacion declarada en `_arnes_expansiones`, y entonces su interior SI se ejecuta
#     (caso `DEV: sustitucion que abre en una linea y cierra en otra`, mas arriba). El
#     sesgo del detector es al falso negativo, y este es el sitio exacto donde no se
#     acepta pagarlo.
check "DEV v4: parentesis que nunca cierra + escritura despues -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(foo ( bar) cp README.md src/w3.ts\nEOF' "" "")"
# (d) ...y el reverso, que es el que impide "arreglarlo" analizando la linea entera: el
#     cierre REAL es el primer `)` cuando no hay nada abierto, y lo que sigue —parentesis
#     literales incluidos— es TEXTO. Sin este caso, (c) invita al falso positivo de 1.29.1.
check "DEV v4: (texto) tras el cierre real sigue siendo texto -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(date) (texto) cp README.md src/x.ts\nEOF' "" "")"
# (e) La paridad de la barra invertida vale para TODOS los caracteres con significado, no
#     solo para `$(`: un `\)` es un parentesis LITERAL y no cierra nada. Verificado en un
#     sandbox real: bash CREA `src/w4.ts`. Sin este caso, el arreglo de QA-015 dejaba
#     abierta la misma puerta por el lado del escapado. El control es obligatorio: sin la
#     barra, ese `)` SI cierra y lo de detras vuelve a ser texto.
check "DEV v4: un ) ESCAPADO no cierra el fragmento -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \\) > src/w4.ts)\nEOF' "" "")"
check "DEV v4: control, el mismo ) SIN escapar si cierra -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo ) > src/w4.ts)\nEOF' "" "")"

# --- 10) DEV REQ-001 v4: QA-016, el deny por tamano dice CUANTO ---------------------
# CA-53 pide que el motivo diga cual es el presupuesto. Decir "es demasiado grande" sin
# el numero deja a quien lo recibe partiendo el comando a ciegas. El numero sale del
# techo EFECTIVO (`arnes_techo_bash`), no de una constante escrita en el mensaje: si el
# manifiesto lo sube, el mensaje sube con el. Se comprueba en las dos puertas.
check_motivo "DEV v4: el deny por tamano dice el presupuesto en bytes (guard-codigo)" \
  "presupuesto de analisis vigente es de 65536 bytes" guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 65508)")" "" "")"
check_motivo "DEV v4: ...y tambien lo dice guard-completado" \
  "presupuesto de analisis vigente es de 65536 bytes" guard-completado.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\nsed -i s/x/y/ requirements/REQ-001.md' "$(cuerpo_de 70000)")" "" "")"
# --- 11) QA REQ-001 v4: la familia de QA-015, contrastada con el shell REAL ---------
# Re-validacion, vuelta 3 (docs/qa/REQ-001.md §9). Cada uno de estos casos se comparo
# en un sandbox con lo que bash hace DE VERDAD (crea o no crea el archivo), y el
# veredicto exigido es el que coincide con esa medida — salvo donde la sobredeteccion
# se declara a proposito. Sin ese contraste, un `deny` solo prueba que la sonda dispara.
#
# (a) Un `)` Y un `$(` dentro de comillas SIMPLES. Bash no ejecuta lo entrecomillado
#     pero SI la redireccion de fuera: medido, CREA `src/v1.ts`. Es la union de las dos
#     esquinas que el arreglo trata por separado (comillas y profundidad).
check "QA v4: \$( y ) entre comillas simples, la escritura fuera -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \'$(cp README.md src/z1.ts)\' > src/v1.ts)\nEOF' "" "")"
# (b) Aritmetica DENTRO de la sustitucion: `$((` aporta DOS aperturas y `))` dos cierres.
#     Si la cuenta de profundidad se descuadrara aqui, el fragmento cerraria antes de la
#     redireccion. Medido: bash CREA `src/v3.ts`.
check "QA v4: aritmetica \$(( )) dentro de la sustitucion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo $((1+2)) > src/v3.ts)\nEOF' "" "")"
# (c) Dos sustituciones en la MISMA linea: la primera cierra limpia y la segunda escribe.
#     Comprueba que cerrar un fragmento no deja de mirar lo que viene detras.
check "QA v4: dos sustituciones, la primera cierra y la segunda escribe -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(date) y $(cp README.md src/v4.ts)\nEOF' "" "")"
# (d) El `)` entre comillas simples en su forma minima, `\')\'`. Medido: CREA `src/v5.ts`.
check "QA v4: un ) solo entre comillas simples no cierra -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \')\' > src/v5.ts)\nEOF' "" "")"
# (e) EL OTRO LADO DE LA PARIDAD del caso `DEV v4: un ) ESCAPADO no cierra`: con DOS
#     barras la primera escapa a la segunda, el `)` es REAL y cierra. Medido: bash no
#     crea nada, y `> src/v6.ts` queda fuera de la sustitucion, como texto del cuerpo.
#     Un arreglo que "denegara por si acaso" ante cualquier barra pondria esto en rojo.
check "QA v4: con \\\\) la barra se escapa a si misma y el ) SI cierra -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \\\\) > src/v6.ts)\nEOF' "" "")"
# (f) Comilla IMPAR dentro de la sustitucion: no se puede descontar sin inventarse un
#     cierre, asi que el fragmento se lleva el resto de la linea y la redireccion cae
#     dentro. SOBREDETECTA a proposito (bash da error de sintaxis y no crea nada): es la
#     direccion obligatoria, la misma de `DEV v4: parentesis que nunca cierra`.
check "QA v4: comilla impar dentro de la expansion -> deny (fail-closed)" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo "a > src/v2.ts)\nEOF' "" "")"
# (g) LIMITACION DECLARADA, no defecto de esta version: una sustitucion ANIDADA dentro de
#     COMILLAS DOBLES se descuenta con las comillas y no se ve. Bash SI ejecuta el `cp`
#     (medido: crea `src/g2.ts`), y ni siquiera hace falta un heredoc. Es la familia de
#     QA-006 —lo entrecomillado se descuenta antes de analizar—, medida `allow` en la
#     candidata Y en v1.30.2: preexistente, no regresion, y su trabajo vive en REQ-007.
#     El caso esta aqui para que el hueco sea VISIBLE y para que el dia que REQ-007 lo
#     cierre alguien tenga que venir a cambiarlo a `deny` a mano, en vez de descubrirlo.
check "QA v4: LIMITACION QA-006/REQ-007, sustitucion dentro de comillas dobles -> allow" allow guard-codigo.sh \
  "$(emite_bash $'echo "$(cp README.md src/g2.ts)"' "" "")"
}

# --- REQ-002: un veredicto lleva fecha y caduca con el codigo ------------------------
# Medido en un proyecto real: cuatro REQ se habrian cerrado con un `QA: aprobado` emitido
# contra codigo que cambio DESPUES de la firma. Las dos claves nacen APAGADAS: los casos
# de control comprueban primero que sin opt-in no cambia nada.
seccion_26() {
  seccion_nueva "Veredicto fechado y no caduco (veredictos.*, opt-in):"

# ver_proj <exigir_fecha> <caducan> [fecha del commit del codigo] [globs-json]
ver_proj() {
  VP="$(mktemp -d)"; mkdir -p "$VP/.arnes" "$VP/requirements" "$VP/src"
  jq -n --argjson f "$1" --argjson c "$2" --argjson g "${4:-[\"src/*\"]}" \
    '{agentes:{agente_codigo:"desarrollador"}, codigo_app:{globs:$g},
      quality_gates:["true"], estados:{completado:"completado"},
      requirements_dir:"requirements", pending_approval:"PENDING_APPROVAL.md",
      veredictos:{exigir_fecha:$f, caducan_con_codigo:$c}}' > "$VP/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$VP/PENDING_APPROVAL.md"
  if [ -n "${3:-}" ]; then
    printf 'codigo\n' > "$VP/src/app.ts"
    git -C "$VP" init -q >/dev/null 2>&1
    git -C "$VP" config user.email banco@arnes.local >/dev/null 2>&1
    git -C "$VP" config user.name banco >/dev/null 2>&1
    git -C "$VP" add -A >/dev/null 2>&1
    GIT_AUTHOR_DATE="$3T10:00:00 +0000" GIT_COMMITTER_DATE="$3T10:00:00 +0000" \
      git -C "$VP" commit -qm codigo >/dev/null 2>&1
  fi
}
# ver_req <archivo> <qa> <seguridad> <rigor>
ver_req() {
  printf '# %s\nEstado: en-revisión\nSensible a seguridad: no\nQA: %s\nSeguridad: %s\nRigor: %s\n' \
    "$(basename "$1" .md)" "$2" "$3" "$4" > "$1"
}
ver_cierra() { emite_edit "$1" "" "" 'Estado: completado'; }
ver_corre() { : > "$ERRLOG"; printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" "$HOOKS_DIR/guard-completado.sh" 2>"$ERRLOG"; }
# ver_check <nombre> <deny|allow> <dir> <json> [regex del motivo]
ver_check() {
  local nombre="$1" esperado="$2" d="$3" json="$4" patron="${5:-}" out got motivo
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  json_no_vacio "$nombre" "$json" || { FAIL=$((FAIL+1)); return 0; }
  out="$(ver_corre "$d" "$json")"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then got=deny; else got=allow; fi
  motivo="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // empty' 2>/dev/null)"
  if [ "$got" != "$esperado" ]; then
    echo "  FAIL  $nombre  esperado=$esperado got=$got  <${motivo:0:140}>"; diag; FAIL=$((FAIL+1)); return 0
  fi
  if [ -n "$patron" ] && ! printf '%s' "$motivo" | grep -Eq "$patron"; then
    echo "  FAIL  $nombre  el motivo no casa /$patron/  <${motivo:0:180}>"; FAIL=$((FAIL+1)); return 0
  fi
  echo "  PASS  $nombre  ($got)"; PASS=$((PASS+1))
}

# --- Bloque A: el interruptor y la forma de la fecha ---
# CA-01: sin opt-in, byte a byte lo de 1.30.3. Es el control que protege a todo proyecto
# que no pida nada: una novedad que cambia el juicio sin que nadie la encienda es una
# regresion, por muy correcta que sea.
ver_proj false false; VP1="$VP"
ver_req "$VP1/requirements/REQ-100.md" "aprobado" "aprobado" "critico"
ver_check "CA-01 sin opt-in: veredictos SIN fecha -> allow" allow "$VP1" "$(ver_cierra "$VP1/requirements/REQ-100.md")"
rm -rf "$VP1"

ver_proj true false; VP2="$VP"
ver_req "$VP2/requirements/REQ-101.md" "aprobado" "n/a" "estandar"
ver_check "CA-02 exigir_fecha: 'aprobado' sin parentesis -> deny" deny "$VP2" \
  "$(ver_cierra "$VP2/requirements/REQ-101.md")" 'QA:.*AAAA-MM-DD|AAAA-MM-DD.*QA:'
ver_req "$VP2/requirements/REQ-102.md" "aprobado (R-045)" "n/a" "estandar"
ver_check "CA-03 parentesis SIN fecha -> deny" deny "$VP2" "$(ver_cierra "$VP2/requirements/REQ-102.md")" 'AAAA-MM-DD'
ver_req "$VP2/requirements/REQ-103.md" "aprobado (R-045, 2026-09-01)" "n/a" "estandar"
ver_check "CA-04 fecha en cualquier posicion del parentesis -> allow" allow "$VP2" "$(ver_cierra "$VP2/requirements/REQ-103.md")"
# CA-05: solo AAAA-MM-DD con mes 01-12 y dia 01-31. Lo que no case NO es "fecha rara":
# es "sin fecha", y sin fecha no se cierra. Aceptar `2026-13-05` la volveria
# incomparable contra la del codigo, que es justo para lo que se lee.
for f in '01/09/2026' '2026-9-1' '20260901' '2026-13-05'; do
  ver_req "$VP2/requirements/REQ-104.md" "aprobado ($f)" "n/a" "estandar"
  ver_check "CA-05 '$f' no es una fecha -> deny" deny "$VP2" "$(ver_cierra "$VP2/requirements/REQ-104.md")" 'AAAA-MM-DD'
done
ver_req "$VP2/requirements/REQ-105.md" "aprobado (2026-09-01)" "aprobado" "critico"
ver_check "CA-07 critico: la fecha se exige tambien a Seguridad -> deny" deny "$VP2" \
  "$(ver_cierra "$VP2/requirements/REQ-105.md")" 'Seguridad:'
ver_req "$VP2/requirements/REQ-106.md" "aprobado" "n/a" "ligero"
ver_check "CA-08 ligero no pide veredictos ni sus fechas -> allow" allow "$VP2" "$(ver_cierra "$VP2/requirements/REQ-106.md")"
ver_req "$VP2/requirements/REQ-107.md" "pendiente" "n/a" "estandar"
ver_check "CA-09 QA pendiente: deniega el VEREDICTO, no la fecha" deny "$VP2" \
  "$(ver_cierra "$VP2/requirements/REQ-107.md")" 'veredicto de QA'
rm -rf "$VP2"

# --- Bloque B: caducidad frente al codigo ---
ver_proj false true 2026-08-30; VP3="$VP"
ver_req "$VP3/requirements/REQ-110.md" "aprobado (2026-09-01)" "n/a" "estandar"
ver_check "CA-10 veredicto POSTERIOR al commit, arbol limpio -> allow" allow "$VP3" "$(ver_cierra "$VP3/requirements/REQ-110.md")"
ver_req "$VP3/requirements/REQ-111.md" "aprobado (2026-08-29)" "n/a" "estandar"
ver_check "CA-11 veredicto ANTERIOR al commit -> deny con las dos fechas y el sha" deny "$VP3" \
  "$(ver_cierra "$VP3/requirements/REQ-111.md")" '2026-08-29.*2026-08-30'
# CA-12: `%cs` tiene resolucion de DIA, asi que el empate NO caduca. Es una asimetria
# declarada, no un descuido: la alternativa seria caducar por el reloj de la maquina.
ver_req "$VP3/requirements/REQ-112.md" "aprobado (2026-08-30)" "n/a" "estandar"
ver_check "CA-12 mismo dia que el commit -> allow (el empate no caduca)" allow "$VP3" "$(ver_cierra "$VP3/requirements/REQ-112.md")"
# CA-19: sin fecha no hay nada que comparar, aunque `exigir_fecha` este apagado.
ver_req "$VP3/requirements/REQ-113.md" "aprobado" "n/a" "estandar"
ver_check "CA-19 caducan sin exigir_fecha: 'aprobado' sin fecha -> deny" deny "$VP3" \
  "$(ver_cierra "$VP3/requirements/REQ-113.md")" 'no lleva fecha'
ver_req "$VP3/requirements/REQ-114.md" "aprobado (2026-09-01)" "aprobado (2026-08-29)" "critico"
ver_check "CA-21 la caducidad alcanza a Seguridad, no solo a QA -> deny" deny "$VP3" \
  "$(ver_cierra "$VP3/requirements/REQ-114.md")" 'Seguridad:'
# CA-14: solo cuenta el codigo DECLARADO. Un README sucio no caduca ningun veredicto.
printf 'ruido\n' > "$VP3/README.md"
ver_check "CA-14 sucio FUERA de los globs -> allow" allow "$VP3" "$(ver_cierra "$VP3/requirements/REQ-110.md")"
# CA-13: sucio DENTRO de los globs -> deny, y el motivo nombra el archivo.
printf 'cambio sin comitear\n' >> "$VP3/src/app.ts"
ver_check "CA-13 cambio sin comitear en el codigo -> deny nombrando el archivo" deny "$VP3" \
  "$(ver_cierra "$VP3/requirements/REQ-110.md")" 'src/app.ts'
rm -rf "$VP3"

# CA-15: una puerta que no puede medir no deja pasar.
ver_proj false true; VP4="$VP"
ver_req "$VP4/requirements/REQ-120.md" "aprobado (2026-09-01)" "n/a" "estandar"
ver_check "CA-15 sin repositorio git -> deny (no puedo medir)" deny "$VP4" \
  "$(ver_cierra "$VP4/requirements/REQ-120.md")" 'no puede medir|no pudo responder'
rm -rf "$VP4"

# CA-16: un git anterior a `%cs` devuelve el literal. Tomarlo por fecha seria dejar pasar
# por no entender la salida, que es la peor forma de permitir.
ver_proj false true 2026-08-30; VP5="$VP"
ver_req "$VP5/requirements/REQ-121.md" "aprobado (2026-09-01)" "n/a" "estandar"
FAKEBIN="$(mktemp -d)"
printf '#!/bin/sh\necho "%%cs abcdef1"\n' > "$FAKEBIN/git"; chmod +x "$FAKEBIN/git"
VER_JSON="$(ver_cierra "$VP5/requirements/REQ-121.md")"
if [ -n "$FILTRO" ] && ! printf '%s' "CA-16" | grep -qi -- "$FILTRO"; then :; else
  json_no_vacio "CA-16 git que no entiende %cs" "$VER_JSON" || FAIL=$((FAIL+1))
  VER_OUT="$(: > "$ERRLOG"; printf '%s' "$VER_JSON" | PATH="$FAKEBIN:$PATH" CLAUDE_PROJECT_DIR="$VP5" "$HOOKS_DIR/guard-completado.sh" 2>"$ERRLOG")"
  if printf '%s' "$VER_OUT" | grep -Eq '"permissionDecision": *"deny"'; then
    echo "  PASS  CA-16 git que no entiende %cs -> deny (no puedo medir)"; PASS=$((PASS+1))
  else
    echo "  FAIL  CA-16 git que no entiende %cs: permitio por no entender la salida"; diag; FAIL=$((FAIL+1))
  fi
fi
rm -rf "$FAKEBIN" "$VP5"

# CA-17: sin globs la consulta mediria el repositorio entero, que es OTRA pregunta.
ver_proj false true 2026-08-30 '[]'; VP6="$VP"
ver_req "$VP6/requirements/REQ-122.md" "aprobado (2026-09-01)" "n/a" "estandar"
ver_check "CA-17 caducan con codigo_app.globs vacio -> deny" deny "$VP6" \
  "$(ver_cierra "$VP6/requirements/REQ-122.md")" 'globs'
rm -rf "$VP6"

# CA-18: repositorio con commits pero NINGUNO que toque los globs, y el arbol limpio ahi.
# No hay codigo posterior al veredicto porque no hay codigo comiteado, y se pudo medir.
ver_proj false true; VP7="$VP"
rmdir "$VP7/src" 2>/dev/null
git -C "$VP7" init -q >/dev/null 2>&1
git -C "$VP7" config user.email banco@arnes.local >/dev/null 2>&1
git -C "$VP7" config user.name banco >/dev/null 2>&1
printf 'documento\n' > "$VP7/LEEME.md"
git -C "$VP7" add LEEME.md >/dev/null 2>&1
git -C "$VP7" commit -qm doc >/dev/null 2>&1
ver_req "$VP7/requirements/REQ-123.md" "aprobado (2026-09-01)" "n/a" "estandar"
ver_check "CA-18 ningun commit toca los globs y el arbol esta limpio -> allow" allow "$VP7" \
  "$(ver_cierra "$VP7/requirements/REQ-123.md")"
rm -rf "$VP7"

# CA-20: con las dos claves ausentes no se mide NADA, ni con el codigo cambiado despues
# ni con el arbol sucio. El control que dice que esto es opt-in de verdad.
ver_proj false false 2026-09-30; VP8="$VP"
printf 'sucio\n' >> "$VP8/src/app.ts"
ver_req "$VP8/requirements/REQ-124.md" "aprobado (2026-08-01)" "n/a" "estandar"
ver_check "CA-20 sin las claves: codigo posterior y arbol sucio -> allow" allow "$VP8" \
  "$(ver_cierra "$VP8/requirements/REQ-124.md")"
rm -rf "$VP8"
}

# --- REQ-003: un vocabulario, un lector, y un aviso al escribir ----------------------
seccion_27() {
  seccion_nueva "Vocabulario de veredictos, aviso y lectura (REQ-003):"

# --- Bloque A: `con-hallazgos` es un valor VALIDO de Seguridad, y no cierra ---
mkreq_r "REQ-200" "no" "aprobado" "con-hallazgos" "critico"
check "CA-02 critico con Seguridad: con-hallazgos -> deny (valido, pero no firma)" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-200.md" "" "" 'Estado: completado')"
check "CA-03 escribir con-hallazgos sin cerrar -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-200.md" "" "" 'Seguridad: con-hallazgos')"
# CA-08: la puerta de ORDEN del ciclo solo se dispara con `aprobado`. `con-hallazgos` no
# es una firma, asi que puede escribirse con QA todavia pendiente.
mkreq_r "REQ-201" "no" "pendiente" "con-hallazgos" "critico"
check "CA-08 con-hallazgos con QA pendiente -> allow (no es una firma)" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-201.md" "" "" 'Seguridad: con-hallazgos')"
# CA-06: no regresion. Ninguno de los otros valores cierra un REQ critico.
for v in vetado preventiva pendiente n/a; do
  mkreq_r "REQ-202" "no" "aprobado" "$v" "critico"
  check "CA-06 critico con Seguridad: $v -> deny (como en 1.30.3)" deny guard-completado.sh \
    "$(emite_edit "$PROJ/requirements/REQ-202.md" "" "" 'Estado: completado')"
done
mkreq_r "REQ-203" "no" "pendiente" "con-hallazgos" "ligero"
check "CA-07 ligero con con-hallazgos -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-203.md" "" "" 'Estado: completado')"

# --- Bloque B: el aviso al ESCRIBIR un valor que la maquina no reconoce ---
# No deniega: es una errata, no un ataque, y la puerta ya la atrapa al cerrar. Denegar
# aqui añadiria friccion constante a algo inocuo, y esa friccion acaba con alguien
# apagando el guard.
mkreq_r "REQ-210" "no" "pendiente" "n/a" "estandar"
check_aviso "CA-09 escribir 'QA: aprobadisimo' -> avisa sin denegar" si 'QA:.*pendiente\|aprobado\|con-hallazgos' \
  guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-210.md" "" "" 'QA: aprobadísimo')"
check_aviso "CA-10 escribir un valor del vocabulario -> sin aviso" no "" \
  guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-210.md" "" "" 'QA: aprobado')"
# CA-11: el aviso es por la ESCRITURA del campo, no por el estado del archivo. Si no,
# cada edicion del REQ repetiria el mismo aviso hasta que alguien lo silencie.
printf '# REQ-211\nEstado: en-revisión\nQA: aprobadísimo\nSeguridad: n/a\n\n## Historial de cambios\n| f | a | c |\n' > "$PROJ/requirements/REQ-211.md"
check_aviso "CA-11 el REQ ya lo tenia en disco y la edicion no lo toca -> sin aviso" no "" \
  guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-211.md" "" "" '| 2026-09-05 | otra fila | causa |')"
check_aviso "CA-12 'Seguridad: aprobado' dentro del historial -> sin aviso" no "" \
  guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-211.md" "" "" '| 2026-09-05 | Seguridad: aprobado | causa |')"
check_aviso "CA-15 el mismo texto FUERA de requirements/ -> sin aviso" no "" \
  guard-completado.sh "$(emite_edit "$PROJ/docs/notas.md" "" "" 'QA: loquesea')"
# CA-13: el aviso no compite con la denegacion ni la sustituye.
mkreq_r "REQ-212" "no" "aprobadísimo" "n/a" "estandar"
check "CA-13 valor fuera del vocabulario Y cierre -> deny (manda la puerta)" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-212.md" "" "" 'Estado: completado')"

# --- Bloque C: el informe lee EXACTAMENTE lo que lee la puerta ---
LEC="$HOOKS_DIR/../tools/arnes-lectura.sh"
lec_proj() {
  LP="$(mktemp -d)"; mkdir -p "$LP/.arnes" "$LP/requirements"
  printf '%s\n' "$MANIFIESTO_BASE" > "$LP/.arnes/config.json"
}
# lec_check <nombre> <rc esperado> <patron> <si|no aparece>
lec_check() {
  local nombre="$1" rc_esp="$2" patron="$3" debe="$4" out rc hay=no
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  out="$(: > "$ERRLOG"; bash "$LEC" "$LP" 2>"$ERRLOG")"; rc=$?
  if [ -z "$out" ]; then
    echo "  FAIL  $nombre  el informe no imprimio NADA: no midio nada"; diag; FAIL=$((FAIL+1)); return 0
  fi
  printf '%s' "$out" | grep -Eq -- "$patron" && hay=si
  if [ "$rc" = "$rc_esp" ] && [ "$hay" = "$debe" ]; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  rc=$rc (esperado $rc_esp), patron aparece=$hay (esperado $debe)"; diag; FAIL=$((FAIL+1)); fi
}
lec_proj
printf '# REQ-300\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: con-hallazgos\nRigor: critico\n' > "$LP/requirements/REQ-300.md"
lec_check "CA-01 'Seguridad: con-hallazgos' no es una anomalia (sale 0)" 0 'REQ-300' no
# CA-16/CA-17: la regla del parentesis se aplica a `Estado:` igual que en la puerta.
printf '# REQ-301\nEstado: en-revisión (2026-08-25, tras la ronda 3)\nQA: aprobado\nSeguridad: n/a\n' > "$LP/requirements/REQ-301.md"
printf '# REQ-302\nEstado: **completado** (revertido en la ronda 2)\nQA: aprobado\nSeguridad: n/a\n' > "$LP/requirements/REQ-302.md"
lec_check "CA-16/CA-17 Estado con parentesis o enfasis no es anomalia (sale 0)" 0 'REQ-30[12]' no
# CA-18: la comparacion es EXACTA contra el vocabulario delimitado, no por prefijo.
printf '# REQ-303\nEstado: en-revisión-parcial\nQA: aprobado\nSeguridad: n/a\n' > "$LP/requirements/REQ-303.md"
lec_check "CA-18/CA-20 un estado que NO existe sigue siendo anomalia (sale 1)" 1 'REQ-303' si
lec_check "CA-20 ...y se imprime el bloque que lo explica" 1 'NO LEE COMO EST' si
rm -rf "$LP"
# CA-04: el informe no puede tener su propia copia del vocabulario.
if grep -Eq "^(QA_OK|SEG_OK|RIG_OK)='\\|" "$LEC"; then
  echo "  FAIL  CA-04 tools/arnes-lectura.sh conserva su propia lista de valores"; FAIL=$((FAIL+1))
else
  echo "  PASS  CA-04 el vocabulario viene de lib.sh, no de una copia en el informe"; PASS=$((PASS+1))
fi
}

# --- REQ-004: rotar UNA seccion; el contrato no se toca -------------------------------
seccion_28() {
  seccion_nueva "Rotacion de UNA seccion (la historia se archiva, el contrato no):"

# rsec_proj <activo> <conservar-json> <umbral> <orden> [archivo_dir] [seccion]
rsec_proj() {
  RP2="$(mktemp -d)"; mkdir -p "$RP2/.arnes" "$RP2/requirements"
  jq -n --argjson a "$1" --argjson c "$2" --argjson u "$3" --arg o "$4" \
        --arg ad "${5:-}" --arg se "${6:-## Historial de cambios}" \
    '{agentes:{agente_codigo:"desarrollador"}, requirements_dir:"requirements",
      rotacion:{activo:$a, artefactos:[
        ({glob:"requirements/REQ-*.md", seccion:$se, umbral_bytes:$u, orden:$o}
         + (if $c == null then {} else {conservar_entradas:$c} end)
         + (if $ad == "" then {} else {archivo_dir:$ad} end))]}}' > "$RP2/.arnes/config.json"
}
# rsec_req <archivo> <n entradas> [crlf]
rsec_req() {
  local f="$1" n="$2" crlf="${3:-}" i
  { printf '# %s\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: (ninguno)\nRigor: critico\n\n' "$(basename "$f" .md)"
    printf '## Criterios de aceptación\n- CA-01 — el contrato, que no se rota jamas\n\n'
    printf '## Historial de cambios\nPreambulo de la seccion.\n\n'
    for i in $(seq -w 1 "$n"); do
      printf -- '- 2026-01-%s: entrada %s con texto suficiente para pasar del umbral declarado\n' "$i" "$i"
      printf '  continuacion indentada de %s\n| tabla | fila |\n' "$i"
    done
    printf '\n## Notas / alcance\nfinal intacto\n'
  } > "$f"
  [ -n "$crlf" ] && { sed 's/$/\r/' "$f" > "$f.crlf" && mv "$f.crlf" "$f"; }
  return 0
}
rsec_corre() {
  local json
  json="$(CLAUDE_PROJECT_DIR="$1" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
  : > "$ERRLOG"
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$1" "$HOOKS_DIR/rotar-artefactos.sh" >/dev/null 2>"$ERRLOG"
}
rsec_check() {
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=$2 obtenido=$3"; diag; FAIL=$((FAIL+1)); fi
}
rsec_cnt() {   # <patron> <archivo> -> cuenta, y 0 si el archivo no existe
  local n
  n="$(grep -c -- "$1" "$2" 2>/dev/null)" || n=0
  [ -n "$n" ] || n=0
  printf '%s' "$n"
}
rsec_ent() { rsec_cnt '^- 2026' "$1"; }

# CA-01: apagada, no toca nada. Reestructurar el documento de una persona no puede ser
# el comportamiento por defecto.
rsec_proj false 20 1000 nuevo-al-final
rsec_req "$RP2/requirements/REQ-400.md" 60
cp "$RP2/requirements/REQ-400.md" "$RP2/antes.md"
rsec_corre "$RP2"; rsec_corre "$RP2"
rsec_check "CA-01 apagada: dos paradas y ni un byte cambia" "iguales-no" \
  "$(cmp -s "$RP2/antes.md" "$RP2/requirements/REQ-400.md" && echo iguales || echo distintos)-$([ -d "$RP2/requirements/historial" ] && echo si || echo no)"
rm -rf "$RP2"

# CA-02/03/04/07/19: el reparto, y sobre todo lo que NO se toca.
rsec_proj true 20 1000 nuevo-al-final
rsec_req "$RP2/requirements/REQ-401.md" 60
cp "$RP2/requirements/REQ-401.md" "$RP2/antes.md"
rsec_corre "$RP2"; RSEC_RC=$?
rsec_check "CA-02 quedan 20 entradas y 40 se archivan" "20-40" \
  "$(rsec_ent "$RP2/requirements/REQ-401.md")-$(rsec_ent "$RP2/requirements/historial/REQ-401.md")"
rsec_check "CA-02 un solo puntero al archivo" "1" "$(rsec_cnt 'historial/REQ-401.md' "$RP2/requirements/REQ-401.md")"
rsec_check "CA-03 la cabecera y las demas secciones, byte a byte" "iguales" \
  "$(cmp -s <(sed '/^## Historial de cambios$/,/^## Notas/{/^## Notas/!d}' "$RP2/antes.md") \
            <(sed '/^## Historial de cambios$/,/^## Notas/{/^## Notas/!d}' "$RP2/requirements/REQ-401.md") && echo iguales || echo distintos)"
# CA-04 es una invariante de SEGURIDAD, no una comodidad: el hook escribe en
# requirements/ desde una parada, fuera de la via que vigila guard-completado. Una
# rotacion que pudiera tocar la cabecera seria un camino para cerrar o firmar un REQ
# sin puerta alguna.
rsec_check "CA-04 los campos de la cabecera, intactos" "$(sed -n '2,7p' "$RP2/antes.md" | md5sum)" \
  "$(sed -n '2,7p' "$RP2/requirements/REQ-401.md" | md5sum)"
rsec_check "CA-07 ninguna continuacion queda huerfana" "60-60" \
  "$(( $(rsec_cnt 'continuacion indentada' "$RP2/requirements/REQ-401.md") + $(rsec_cnt 'continuacion indentada' "$RP2/requirements/historial/REQ-401.md") ))-$(( $(rsec_ent "$RP2/requirements/REQ-401.md") + $(rsec_ent "$RP2/requirements/historial/REQ-401.md") ))"
rsec_check "CA-18 la entrada mas reciente se queda en el documento" "1" \
  "$(rsec_cnt '2026-01-60' "$RP2/requirements/REQ-401.md")"
rsec_check "CA-19 el puntero dice cuantas quedan" "1" \
  "$(rsec_cnt 'quedan las 20 más recientes' "$RP2/requirements/REQ-401.md")"
rsec_check "el hook sale 0 (una parada no se bloquea)" "0" "$RSEC_RC"
# CA-05: idempotencia. Sin ella, cada parada se lleva otro trozo del documento.
rsec_corre "$RP2"; rsec_corre "$RP2"
rsec_check "CA-05 idempotente: tres paradas, mismo reparto y un solo puntero" "20-40-1" \
  "$(rsec_ent "$RP2/requirements/REQ-401.md")-$(rsec_ent "$RP2/requirements/historial/REQ-401.md")-$(rsec_cnt 'historial/REQ-401.md' "$RP2/requirements/REQ-401.md")"
rm -rf "$RP2"

# CA-06: el umbral manda sobre el numero de entradas.
rsec_proj true 20 9999999 nuevo-al-final
rsec_req "$RP2/requirements/REQ-402.md" 200
rsec_corre "$RP2"
rsec_check "CA-06 bajo el umbral no se toca nada, haya las entradas que haya" "200-no" \
  "$(rsec_ent "$RP2/requirements/REQ-402.md")-$([ -d "$RP2/requirements/historial" ] && echo si || echo no)"
rm -rf "$RP2"

# CA-09/CA-10: un archivo que casa el glob pero no tiene la seccion no se toca; y cada
# REQ rota a SU propio archivo.
rsec_proj true 20 1000 nuevo-al-final
rsec_req "$RP2/requirements/REQ-403.md" 60
rsec_req "$RP2/requirements/REQ-404.md" 60
printf '# REQ-405\nEstado: en-revisión\n\n## Criterios\n- sin seccion de historia\n' > "$RP2/requirements/REQ-405.md"
cp "$RP2/requirements/REQ-405.md" "$RP2/antes405.md"
rsec_corre "$RP2"
rsec_check "CA-09 sin la seccion declarada, el archivo no se toca" "iguales-no" \
  "$(cmp -s "$RP2/antes405.md" "$RP2/requirements/REQ-405.md" && echo iguales || echo distintos)-$([ -e "$RP2/requirements/historial/REQ-405.md" ] && echo si || echo no)"
rsec_check "CA-10 cada REQ a su propio archivo de historia" "40-40-0" \
  "$(rsec_ent "$RP2/requirements/historial/REQ-403.md")-$(rsec_ent "$RP2/requirements/historial/REQ-404.md")-$(( $(rsec_cnt 'entrada 01 con texto' "$RP2/requirements/historial/REQ-403.md") - 1 ))"
rm -rf "$RP2"

# CA-11: CRLF. La fuga medida en 1.27.0 —3 -> 6 -> 9 en tres pasadas— no puede volver.
rsec_proj true 20 1000 nuevo-al-final
rsec_req "$RP2/requirements/REQ-406.md" 60 crlf
rsec_corre "$RP2"; rsec_corre "$RP2"; rsec_corre "$RP2"
rsec_check "CA-11 CRLF: tres paradas, mismo reparto y sin duplicar" "20-40" \
  "$(rsec_ent "$RP2/requirements/REQ-406.md")-$(rsec_ent "$RP2/requirements/historial/REQ-406.md")"
rm -rf "$RP2"

# CA-13: contencion LEXICA. `../fuera` no se escribe, y el origen no se toca.
rsec_proj true 20 1000 nuevo-al-final ../fuera
rsec_req "$RP2/requirements/REQ-407.md" 60
cp "$RP2/requirements/REQ-407.md" "$RP2/antes.md"
rsec_corre "$RP2"
rsec_check "CA-13 archivo_dir con .. no escribe nada y no toca el origen" "iguales-no" \
  "$(cmp -s "$RP2/antes.md" "$RP2/requirements/REQ-407.md" && echo iguales || echo distintos)-$([ -e "$RP2/../fuera" ] && echo si || echo no)"
rm -rf "$RP2"

# CA-14: contencion FISICA. Ruta relativa limpia que, RESUELTA, sale del proyecto por un
# enlace simbolico. La misma regla que `estado_derivado.archivo` desde 1.29.1.
if ln -s /tmp /tmp/arnes-enlace-test-$$ 2>/dev/null; then
  rm -f /tmp/arnes-enlace-test-$$
  rsec_proj true 20 1000 nuevo-al-final salida
  FUERA="$(mktemp -d)"
  ln -s "$FUERA" "$RP2/salida"
  rsec_req "$RP2/requirements/REQ-408.md" 60
  cp "$RP2/requirements/REQ-408.md" "$RP2/antes.md"
  rsec_corre "$RP2"
  rsec_check "CA-14 archivo_dir que sale por un enlace simbolico -> nada fuera" "iguales-0" \
    "$(cmp -s "$RP2/antes.md" "$RP2/requirements/REQ-408.md" && echo iguales || echo distintos)-$(ls -1 "$FUERA" | wc -l | tr -d ' ')"
  rm -rf "$RP2" "$FUERA"
else
  echo "  SKIP  CA-14 contencion fisica: esta plataforma no crea enlaces simbolicos"; SKIP=$((SKIP+1))
fi

# CA-15: archivo_dir dentro del proyecto -> ahi, y no junto al documento.
rsec_proj true 20 1000 nuevo-al-final historial-global
rsec_req "$RP2/requirements/REQ-409.md" 60
rsec_corre "$RP2"
rsec_check "CA-15 archivo_dir interno: escribe ahi y no junto al documento" "40-no" \
  "$(rsec_ent "$RP2/historial-global/REQ-409.md")-$([ -e "$RP2/requirements/historial/REQ-409.md" ] && echo si || echo no)"
rm -rf "$RP2"

# CA-16: manifiesto malformado -> se ignora esa entrada, nada se toca, la parada sale 0.
rsec_proj true '"veinte"' 1000 nuevo-al-final
rsec_req "$RP2/requirements/REQ-410.md" 60
cp "$RP2/requirements/REQ-410.md" "$RP2/antes.md"
rsec_corre "$RP2"; RSEC_RC=$?
rsec_check "CA-16 conservar_entradas no numerico: se ignora y sale 0" "iguales-0" \
  "$(cmp -s "$RP2/antes.md" "$RP2/requirements/REQ-410.md" && echo iguales || echo distintos)-$RSEC_RC"
rm -rf "$RP2"

# CA-20: el nombre de la seccion se compara EXACTO, nunca por prefijo. Declarar
# `## Historial` no puede llevarse por delante `## Historial de cambios`: la rotacion
# escribiria en una seccion que el proyecto no nombro.
rsec_proj true 20 1000 nuevo-al-final "" "## Historial"
rsec_req "$RP2/requirements/REQ-411.md" 60
cp "$RP2/requirements/REQ-411.md" "$RP2/antes.md"
rsec_corre "$RP2"
rsec_check "CA-20 '## Historial' no casa '## Historial de cambios' (exacto, no prefijo)" "iguales" \
  "$(cmp -s "$RP2/antes.md" "$RP2/requirements/REQ-411.md" && echo iguales || echo distintos)"
# QA 1.31.0: HALLAZGO QA-102 — REQ-004 CA-09 pide dos cosas y solo se cumple una: no
# rotar (arriba) Y DECIRLO. Un artefacto declarado cuya seccion no existe es un error de
# mapeo que hay que ver; hoy `arnes_rotar_seccion` sale con `return 0` en silencio.
rsec_check "QA-102 CA-09: la seccion declarada no encontrada emite arnes_warn" "hay-aviso" \
  "$( [ -s "$ERRLOG" ] && echo hay-aviso || echo silencio)"
# DEV 1.31.0 v2: un aviso que no dice CUAL archivo ni QUE seccion no obliga a nadie a
# mirar nada. CA-09 pide los dos datos, porque el error que describe es de MAPEO: alguien
# escribio un nombre de seccion y el documento tiene otro.
rsec_check "DEV 1.31.0 v2: QA-102 el aviso nombra el archivo y la seccion declarada" "si-si" \
  "$(grep -q 'REQ-411.md' "$ERRLOG" && echo si || echo no)-$(grep -q '## Historial' "$ERRLOG" && echo si || echo no)"
rm -rf "$RP2"

# DEV 1.31.0 v2: la SEGUNDA MITAD de CA-09 —el bloque derivado lo refleja—. Se prueba por
# `stop.sh`, que es como corre en produccion: la rotacion deja el dato y el bloque lo
# ensena sin volver a mirar el disco (por eso stop.sh rota ANTES de derivar).
rsec_proj true 20 1000 nuevo-al-final "" "## Historial"
mkdir -p "$RP2/docs"
printf '# ESTADO\n\n## Fase\nlo que escribio una persona\n' > "$RP2/docs/ESTADO.md"
rsec_req "$RP2/requirements/REQ-412.md" 60
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$RP2" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$RP2" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
rsec_check "DEV 1.31.0 v2: QA-102 CA-09 el bloque derivado refleja la seccion no encontrada" "si-si" \
  "$(grep -q 'no contienen la sección declarada' "$RP2/docs/ESTADO.md" && echo si || echo no)-$(grep -q 'REQ-412.md' "$RP2/docs/ESTADO.md" && echo si || echo no)"
rsec_check "DEV 1.31.0 v2: QA-102 lo que escribio una persona sigue fuera de los marcadores" "1" \
  "$(grep -c 'lo que escribio una persona' "$RP2/docs/ESTADO.md")"
# CONTROL: cuando la seccion SI existe no se dice nada. Un bloque que informa de lo que no
# pasa deja de servir para saber donde quedamos.
rm -rf "$RP2"
rsec_proj true 20 1000 nuevo-al-final
mkdir -p "$RP2/docs"; printf '# ESTADO\n' > "$RP2/docs/ESTADO.md"
rsec_req "$RP2/requirements/REQ-413.md" 60
printf '%s' "$(CLAUDE_PROJECT_DIR="$RP2" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$RP2" "$HOOKS_DIR/stop.sh" >/dev/null 2>/dev/null
rsec_check "DEV 1.31.0 v2: QA-102 control: con la seccion encontrada el bloque no dice nada" "no-20" \
  "$(grep -q 'no contienen la sección declarada' "$RP2/docs/ESTADO.md" && echo si || echo no)-$(rsec_ent "$RP2/requirements/REQ-413.md")"
rm -rf "$RP2"

# QA 1.31.0 v2: HALLAZGO QA-109 — la seccion SI existe, pero no tiene ni una entrada
# reconocible (`- `, `* `, `### `, `N. `): esta hecha SOLO de filas de tabla, que CA-07
# cuenta como continuaciones. No se rota nada y NO SE DICE NADA — el mismo silencio que
# CA-09 declara inaceptable para la seccion que no existe, en la rama hermana. No es
# hipotetico: el `## Historial de cambios` de los REQ de ESTE repositorio es una tabla.
# El caso fija la conducta MEDIDA hoy (silencio); si se decide avisar, este caso cambia
# con el criterio que lo ordene.
rsec_proj true 20 1000 nuevo-al-final
mkdir -p "$RP2/docs"; printf '# ESTADO\n' > "$RP2/docs/ESTADO.md"
{ printf '# REQ-414\nEstado: en-revisión\n\n## Historial de cambios\n\n'
  i=1; while [ "$i" -le 60 ]; do
    printf '| 2026-01-01 | fila de tabla numero %s con relleno de sobra para pasar del umbral de mil bytes | causa | — |\n' "$i"
    i=$((i+1))
  done
} > "$RP2/requirements/REQ-414.md"
cp "$RP2/requirements/REQ-414.md" "$RP2/antes414.md"
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$RP2" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$RP2" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
# DEV 1.31.0 v3 (QA-109): la conducta que este caso fijaba —silencio— era la medida, no
# la querida. El criterio cambia: NO ROTAR sigue igual (sin entradas no hay limite seguro
# donde cortar), pero se AVISA, como en la rama que ya avisaba.
rsec_check "DEV 1.31.0 v3: QA-109 seccion sin entradas reconocibles: NO rota, pero AVISA" "iguales-aviso" \
  "$(cmp -s "$RP2/antes414.md" "$RP2/requirements/REQ-414.md" && echo iguales || echo distintos)-$(grep -q 'REQ-414.md' "$ERRLOG" && echo aviso || echo silencio)"
# Los dos casos son ERRORES DE MAPEO DISTINTOS y piden acciones distintas: alli se
# corrige el nombre de la seccion en el manifiesto, aqui el formato de la seccion o la
# expectativa de rotarla. Un aviso que no los distinga manda a mirar el archivo
# equivocado, asi que se exige que el texto diga que la seccion SI esta y que lo que
# falta son ENTRADAS, y que NO reutilice el texto de la otra rama.
rsec_check "DEV 1.31.0 v3: QA-109 el aviso DISTINGUE 'existe sin entradas' de 'no existe'" "si-si-no" \
  "$(grep -q 'ENTRADA reconocible' "$ERRLOG" && echo si || echo no)-$(grep -q "SI contiene la seccion '## Historial de cambios'" "$ERRLOG" && echo si || echo no)-$(grep -q 'NO contiene la seccion' "$ERRLOG" && echo si || echo no)"
# Y la segunda mitad de CA-09, igual que en la rama hermana: el bloque derivado lo
# refleja, con el archivo de ejemplo, sin volver a mirar el disco.
rsec_check "DEV 1.31.0 v3: QA-109 el bloque derivado refleja la seccion sin entradas" "si-si" \
  "$(grep -q 'sin ninguna entrada reconocible' "$RP2/docs/ESTADO.md" && echo si || echo no)-$(grep -q 'REQ-414.md' "$RP2/docs/ESTADO.md" && echo si || echo no)"
rm -rf "$RP2"

# CONTROL de los tres de arriba: con la MISMA seccion y el MISMO umbral, pero con
# entradas de verdad, no se avisa nada y se rota. Sin este control, un aviso emitido
# siempre —o una rotacion rota— pasaria por acierto.
rsec_proj true 20 1000 nuevo-al-final
mkdir -p "$RP2/docs"; printf '# ESTADO\n' > "$RP2/docs/ESTADO.md"
rsec_req "$RP2/requirements/REQ-415.md" 60
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$RP2" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$RP2" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
rsec_check "DEV 1.31.0 v3: QA-109 control: con entradas de verdad ni aviso ni mencion en el bloque" "silencio-no-20" \
  "$(grep -q 'ENTRADA reconocible' "$ERRLOG" && echo aviso || echo silencio)-$(grep -q 'sin ninguna entrada reconocible' "$RP2/docs/ESTADO.md" && echo si || echo no)-$(rsec_ent "$RP2/requirements/REQ-415.md")"
rm -rf "$RP2"

# CA-17: no regresion. La forma ANTERIOR —artefacto por ruta, secciones `## `— sigue
# rotando igual que en 1.30.3.
RP3="$(mktemp -d)"; mkdir -p "$RP3/.arnes"
jq -n '{agentes:{agente_codigo:"desarrollador"},
        rotacion:{activo:true, umbral_bytes:2000, conservar_secciones:3, orden:"nuevo-primero",
                  artefactos:["CHANGELOG.md"]}}' > "$RP3/.arnes/config.json"
{ printf '# CHANGELOG\n\n'
  for v in 10 9 8 7 6 5 4 3 2 1; do
    printf '## [1.%s.0]\n' "$v"
    for i in 1 2 3 4 5 6; do printf 'relleno %s de 1.%s.0 para que el archivo pese lo suyo\n' "$i" "$v"; done
    printf '\n'
  done
} > "$RP3/CHANGELOG.md"
RSEC_JSON="$(CLAUDE_PROJECT_DIR="$RP3" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
: > "$ERRLOG"
printf '%s' "$RSEC_JSON" | CLAUDE_PROJECT_DIR="$RP3" "$HOOKS_DIR/rotar-artefactos.sh" >/dev/null 2>"$ERRLOG"
rsec_check "CA-17 la forma anterior (por ruta, secciones ##) no cambia" "3-7" \
  "$(rsec_cnt '^## ' "$RP3/CHANGELOG.md")-$(rsec_cnt '^## ' "$RP3/CHANGELOG-archivo.md")"
rm -rf "$RP3"
}

# --- REQ-005: git destructivo prohibido a TODOS los agentes ---------------------------
seccion_29() {
  seccion_nueva "guard-git: ningun agente ejecuta git destructivo:"

# CA-17: sin bloque `git` en el manifiesto la puerta ya esta encendida. Es la UNICA
# novedad de 1.31.0 activa por defecto, y lo esta porque su daño es irreversible.
check "CA-01/CA-17 coordinadora: 'git clean -fd' -> deny (por defecto)" deny guard-git.sh "$(emite_bash 'git clean -fd' "" "")"
check_motivo "CA-01 el motivo dice que se pierde y como seguir" 'comitea|humano' guard-git.sh "$(emite_bash 'git clean -fd' "" "")"
# CA-02: es una regla del COMANDO, no de la identidad. Ahi esta la diferencia con
# guard-codigo, y por eso alcanza al desarrollador y a la coordinadora por igual.
check "CA-02 el MISMO comando desde el desarrollador -> deny igual" deny guard-git.sh "$(emite_bash 'git clean -fd' "d1" "desarrollador")"
check "CA-03 'git reset --hard' -> deny"            deny guard-git.sh "$(emite_bash 'git reset --hard' "" "")"
check "CA-03 'git reset --hard HEAD~1' -> deny"     deny guard-git.sh "$(emite_bash 'git reset --hard HEAD~1' "" "")"
check "CA-04 'git checkout .' -> deny"              deny guard-git.sh "$(emite_bash 'git checkout .' "" "")"
check "CA-04 'git restore .' -> deny"               deny guard-git.sh "$(emite_bash 'git restore .' "" "")"
check "CA-05 'git stash' desnudo -> deny"           deny guard-git.sh "$(emite_bash 'git stash' "" "")"
check "CA-05 'git stash push -u' -> deny"           deny guard-git.sh "$(emite_bash 'git stash push -u' "" "")"
# CA-06: el subcomando se reconoce este donde este dentro del comando.
check "CA-06 'cd sub && git clean -fd' -> deny"     deny guard-git.sh "$(emite_bash 'cd sub && git clean -fd' "" "")"
check "CA-06 'git -C proj reset --hard' -> deny"    deny guard-git.sh "$(emite_bash 'git -C proj reset --hard' "" "")"
check "CA-06 '(git reset --hard)' -> deny"          deny guard-git.sh "$(emite_bash '(git reset --hard)' "" "")"
check "CA-06 'x=\$(git stash)' -> deny"             deny guard-git.sh "$(emite_bash 'x=$(git stash)' "" "")"
check "CA-06 'git clean -fd | tee log' -> deny"     deny guard-git.sh "$(emite_bash 'git clean -fd | tee log' "" "")"
# CA-07: con el delimitador SIN CITAR bash ejecuta de verdad la sustitucion. Mismo
# descuento que el detector de escrituras, no una segunda copia de esa regla.
check "CA-07 heredoc SIN citar con \$(git clean -fd) -> deny" deny guard-git.sh \
  "$(emite_bash $'cat <<EOF\n$(git clean -fd)\nEOF' "" "")"
# La lista por defecto casa por FLAG: `clean -f` alcanza -f, -fd y -fdx, y no -n.
check "flags cortos: 'git clean -fdx' -> deny"      deny guard-git.sh "$(emite_bash 'git clean -fdx' "" "")"
check "los argumentos entrecomillados no desarman el reconocimiento" deny guard-git.sh "$(emite_bash 'git clean -fd "src"' "" "")"

# --- Controles positivos: lo que NO deniega ---
check "CA-08 'git stash list' -> allow"             allow guard-git.sh "$(emite_bash 'git stash list' "" "")"
check "CA-08 'git stash show' -> allow"             allow guard-git.sh "$(emite_bash 'git stash show' "" "")"
check "CA-09 'git restore --staged archivo.ts' -> allow" allow guard-git.sh "$(emite_bash 'git restore --staged archivo.ts' "" "")"
check "CA-10 'git clean -n' -> allow"               allow guard-git.sh "$(emite_bash 'git clean -n' "" "")"
check "CA-10 'git clean --dry-run' -> allow"        allow guard-git.sh "$(emite_bash 'git clean --dry-run' "" "")"
check "CA-11 'git reset --soft HEAD~1' -> allow"    allow guard-git.sh "$(emite_bash 'git reset --soft HEAD~1' "" "")"
check "CA-11 'git reset archivo.ts' -> allow"       allow guard-git.sh "$(emite_bash 'git reset archivo.ts' "" "")"
check "CA-12 'git checkout rama' -> allow"          allow guard-git.sh "$(emite_bash 'git checkout rama' "" "")"
check "CA-12 'git checkout -b rama' -> allow"       allow guard-git.sh "$(emite_bash 'git checkout -b rama' "" "")"
check "CA-12 'git restore --source=HEAD~1 x.ts' -> allow" allow guard-git.sh "$(emite_bash 'git restore --source=HEAD~1 x.ts' "" "")"
# CA-13: lo entrecomillado y el cuerpo literal de un heredoc no son el comando.
check "CA-13 'git commit -m \"no uses git clean\"' -> allow" allow guard-git.sh "$(emite_bash 'git commit -m "no uses git clean"' "" "")"
check "CA-13 heredoc CITADO cuyo cuerpo dice git clean -fd -> allow" allow guard-git.sh \
  "$(emite_bash $'cat <<\'EOF\'\ngit clean -fd\nEOF' "" "")"
# CA-14: `git` es un TOKEN de comando, no una subcadena.
# QA 1.31.0: HALLAZGO QA-101 — la regla casa el flag CORTO por letras, pero la forma
# LARGA equivalente y el alias del subcomando escapan. `git clean --force` borra lo mismo
# que `git clean -f`, y `git stash save` es el alias historico de `git stash push`. Los
# tres son la conducta que REQ-005 existe para impedir. Controles positivos justo debajo.
check "QA-101 'git clean --force' -> deny"          deny  guard-git.sh "$(emite_bash 'git clean --force' "" "")"
check "QA-101 'git clean --force -d' -> deny"       deny  guard-git.sh "$(emite_bash 'git clean --force -d' "" "")"
check "QA-101 'git stash save \"wip\"' -> deny"      deny  guard-git.sh "$(emite_bash 'git stash save "wip"' "" "")"
check "QA-101 control: 'git clean --dry-run' sigue allow" allow guard-git.sh "$(emite_bash 'git clean --dry-run' "" "")"
check "QA-101 control: 'git stash list' sigue allow" allow guard-git.sh "$(emite_bash 'git stash list' "" "")"
# DEV 1.31.0 v2: la equivalencia es SIMETRICA y vive en el motor, no en la lista. La forma
# larga se traduce a su letra corta antes de comparar, en los DOS lados; asi una regla
# escrita con una ortografia alcanza tambien la otra, y ninguna lista tiene que enumerar
# variantes. Con el `=` pegado (`--force=x`) la opcion sigue siendo la misma.
check "DEV 1.31.0 v2: QA-101 'git clean -d --force' (larga al final) -> deny" deny guard-git.sh \
  "$(emite_bash 'git clean -d --force' "" "")"
check "DEV 1.31.0 v2: QA-101 'git stash save' sin mensaje -> deny" deny guard-git.sh \
  "$(emite_bash 'git stash save' "" "")"
check "DEV 1.31.0 v2: QA-101 'git clean --force=si' -> deny" deny guard-git.sh \
  "$(emite_bash 'git clean --force=si' "" "")"
# FIN DE OPCIONES: detras de `--` lo que hay son pathspecs. `--force` ahi es el NOMBRE DE
# UN ARCHIVO, no el flag, y denegarlo seria el falso positivo que estorba a todo el mundo.
check "DEV 1.31.0 v2: QA-101 control fin de opciones: 'git clean -- --force' -> allow" allow guard-git.sh \
  "$(emite_bash 'git clean -- --force' "" "")"
# Y la otra mitad del control: `--staged` en su forma corta tampoco toca el arbol.
check "DEV 1.31.0 v2: QA-101 control: 'git restore -S .' (forma corta de --staged) -> allow" allow guard-git.sh \
  "$(emite_bash 'git restore -S .' "" "")"

# QA 1.31.0 v2: el FIN DE OPCIONES (`--`) que 1.31.0 introduce mueve TRES veredictos de
# DENY a ALLOW respecto de `40312c6`, y esa direccion se declara, no se descubre. Los tres
# son correctos —medido en un repositorio desechable: `git reset -- --hard` no toca ni el
# arbol ni el indice, y `git clean -- -f` solo alcanza a un archivo llamado `-f`, y solo
# si el proyecto puso `clean.requireForce=false`—, pero ningun criterio los describia.
# Se fijan aqui para que un cambio futuro en el detector no los mueva sin que nadie lo vea.
check "QA 1.31.0 v2: fin de opciones 'git clean -- -f' -> allow (era deny en 40312c6)" allow guard-git.sh \
  "$(emite_bash 'git clean -- -f' "" "")"
check "QA 1.31.0 v2: fin de opciones 'git reset -- --hard' -> allow (era deny en 40312c6)" allow guard-git.sh \
  "$(emite_bash 'git reset -- --hard' "" "")"
# CONTROL, y es el que sostiene la regla: detras de `--` deja de buscarse una OPCION, pero
# un token LITERAL se sigue buscando en todo el segmento, porque ahi si puede ser un
# pathspec — y `git checkout -- .` arrasa el arbol igual.
check "QA 1.31.0 v2: control fin de opciones: 'git checkout -- .' sigue deny" deny guard-git.sh \
  "$(emite_bash 'git checkout -- .' "" "")"
check "DEV 1.31.0 v2: QA-101 'git restore -W .' (forma corta de --worktree) -> deny" deny guard-git.sh \
  "$(emite_bash 'git restore -W .' "" "")"

# QA 1.31.0 v3: HALLAZGO QA-113 — un token ENTRECOMILLADO desaparece del analisis, y con
# el la regla. `git clean "-f"` es, para bash, exactamente `git clean -f`: borra lo mismo.
# La puerta no lo ve porque el descuento de comillas —COMPARTIDO con el detector de
# escrituras (CA-07, CA-13)— borra lo entrecomillado antes de mirar el comando. No es una
# regresion: en v1.30.3 publicada el mismo descuento deja pasar `echo x > "src/a.ts"`, y
# su arreglo esta declarado y asignado a REQ-007 Bloque C (CA-14…CA-18), ventana 1.32.0.
# Estos casos fijan la conducta MEDIDA HOY para que el cambio se vea cuando aterrice: al
# arreglar el Bloque C estos dos `allow` pasaran a `deny` y el banco lo dira en voz alta.
check "QA 1.31.0 v3: QA-113 'git clean \"-f\"' -> allow (hoy; cambia con REQ-007 Bloque C)" allow guard-git.sh \
  "$(emite_bash 'git clean "-f"' "" "")"
check "QA 1.31.0 v3: QA-113 'git checkout \".\"' -> allow (hoy; cambia con REQ-007 Bloque C)" allow guard-git.sh \
  "$(emite_bash 'git checkout "."' "" "")"
# CONTROL, y es el que hace legible al hallazgo: el MISMO comando sin comillas si se deniega.
check "QA 1.31.0 v3: QA-113 control: 'git clean -f' desnudo sigue deny" deny guard-git.sh \
  "$(emite_bash 'git clean -f' "" "")"

# QA 1.31.0 v3: los bordes del FIN DE OPCIONES que CA-21.4 no enumera, medidos uno a uno.
# Detras de `--` no hay opciones: tampoco con el valor pegado, tampoco si el `--` se
# repite. Y la mitad que sostiene la regla: la opcion escrita ANTES del `--` sigue casando.
check "QA 1.31.0 v3: valor pegado tras '--': 'git clean -- --force=x' -> allow" allow guard-git.sh \
  "$(emite_bash 'git clean -- --force=x' "" "")"
check "QA 1.31.0 v3: '--' repetido: 'git clean -- -- -f' -> allow" allow guard-git.sh \
  "$(emite_bash 'git clean -- -- -f' "" "")"
check "QA 1.31.0 v3: la opcion ANTES del '--' casa igual: 'git clean -f -- -f' -> deny" deny guard-git.sh \
  "$(emite_bash 'git clean -f -- -f' "" "")"
# `--` como UNICO argumento: no hay opcion que casar (regla con token) y tampoco hay
# posicional que quite la forma desnuda (regla sin tokens). Los dos lados, medidos.
check "QA 1.31.0 v3: '--' unico argumento: 'git clean --' -> allow" allow guard-git.sh \
  "$(emite_bash 'git clean --' "" "")"
check "QA 1.31.0 v3: '--' unico argumento: 'git stash --' -> deny (sigue siendo la forma desnuda)" deny guard-git.sh \
  "$(emite_bash 'git stash --' "" "")"
# La excepcion de `restore` y el fin de opciones, en sus dos direcciones: con `--staged`
# como OPCION el arbol no se toca (allow); detras del `--` es una RUTA, y entonces el
# comando restaura el arbol de verdad (deny).
check "QA 1.31.0 v3: 'git restore --staged -- .' -> allow (solo rehace el indice)" allow guard-git.sh \
  "$(emite_bash 'git restore --staged -- .' "" "")"
check "QA 1.31.0 v3: 'git restore -- --staged .' -> deny (tras '--' es una ruta, no la opcion)" deny guard-git.sh \
  "$(emite_bash 'git restore -- --staged .' "" "")"
check "CA-14 'github clone x' -> allow"             allow guard-git.sh "$(emite_bash 'github clone x' "" "")"
check "CA-14 'mygit clean -f' -> allow"             allow guard-git.sh "$(emite_bash 'mygit clean -f' "" "")"
check "CA-15 'echo \"git clean -f\"' -> allow"      allow guard-git.sh "$(emite_bash 'echo "git clean -f"' "" "")"
# CA-16: no regresion. El git de todos los dias sigue pasando —y las dos consultas de
# REQ-002 (`git log`, `git status`) son lecturas y conviven con esta puerta.
check "CA-16 'git status' -> allow"                 allow guard-git.sh "$(emite_bash 'git status --porcelain' "" "")"
check "CA-16 'git log' -> allow"                    allow guard-git.sh "$(emite_bash 'git log -1 --format=%cs -- src/' "" "")"
check "CA-16 'git add .' y 'git commit' -> allow"   allow guard-git.sh "$(emite_bash 'git add . && git commit -m listo' "" "")"

# --- El manifiesto: mecanismo aqui, mapeo alli ---
setcfg '.git = {"activo": false}'
check "CA-18 git.activo:false -> allow (acto explicito del proyecto)" allow guard-git.sh "$(emite_bash 'git clean -fd' "" "")"
setcfg '.git = {"prohibidos": []}'
check "CA-20 lista vacia: una decision declarada, no un error -> allow" allow guard-git.sh "$(emite_bash 'git reset --hard' "" "")"
setcfg '.git = {"prohibidos": ["push --force"]}'
check "CA-19 lista propia: 'git clean -fd' ya no esta en ella -> allow" allow guard-git.sh "$(emite_bash 'git clean -fd' "" "")"
check "CA-19 lista propia: 'git push --force origin main' -> deny" deny guard-git.sh "$(emite_bash 'git push --force origin main' "" "")"
# DEV 1.31.0 v2: QA-101 al reves. El proyecto declaro la forma LARGA; la corta es el mismo
# flag y tiene que casar igual. Por esto la equivalencia esta en el MOTOR: si viviera en la
# lista por defecto, una lista propia como esta la perderia sin enterarse.
check "DEV 1.31.0 v2: QA-101 lista propia con la larga: 'git push -f origin main' -> deny" deny guard-git.sh \
  "$(emite_bash 'git push -f origin main' "" "")"
check "DEV 1.31.0 v2: QA-101 control: '--force-with-lease' no es '--force' -> allow" allow guard-git.sh \
  "$(emite_bash 'git push --force-with-lease origin main' "" "")"
# DEV 1.31.0 v2: UN CASO POR ENTRADA DE LA TABLA DE EQUIVALENCIAS (CA-21.2). Una tabla del
# mecanismo cuyas filas nadie mide es una afirmacion, no un mecanismo; y el control de al
# lado es el que impide que la equivalencia se vuelva ancha: cada token casa con SUS
# ortografias, no con las del vecino.
setcfg '.git = {"prohibidos": ["clean -d"]}'
check "DEV 1.31.0 v2: QA-101 '--directory' es la larga de 'clean -d' -> deny" deny guard-git.sh \
  "$(emite_bash 'git clean --directory' "" "")"
check "DEV 1.31.0 v2: QA-101 control: '--dry-run' es la de '-n', no la de '-d' -> allow" allow guard-git.sh \
  "$(emite_bash 'git clean --dry-run' "" "")"
setcfg '.git = {"prohibidos": ["stash -u"]}'
check "DEV 1.31.0 v2: QA-101 '--include-untracked' es la larga de 'stash -u' -> deny" deny guard-git.sh \
  "$(emite_bash 'git stash --include-untracked' "" "")"
setcfg '.git = {"prohibidos": ["stash -a"]}'
check "DEV 1.31.0 v2: QA-101 '--all' es la larga de 'stash -a' -> deny" deny guard-git.sh \
  "$(emite_bash 'git stash --all' "" "")"
setcfg '.git = {"prohibidos": ["reset --hard"]}'
check "CA-21 el token en otra posicion del segmento -> deny igual" deny guard-git.sh "$(emite_bash 'git reset HEAD~1 --hard' "" "")"
setcfg 'del(.git)'

# --- Integracion y orden: guard.sh ---
# CA-24: cuando un comando es a la vez git destructivo y escritura sobre codigo
# protegido, el motivo es el de GIT: la denegacion es final y los demas no corren.
check_motivo "CA-23/CA-24 en guard.sh manda el motivo de git" 'git.prohibidos' guard.sh \
  "$(emite_bash 'git clean -fd && echo x > src/generado.ts' "" "")"
# CA-25: interponer el guardian nuevo no apaga a los que ya estaban.
check_motivo "CA-25 lo que guard-git permite lo sigue juzgando guard-codigo" 'código de la app|codigo de la app|protegid' guard.sh \
  "$(emite_bash 'echo x > src/generado.ts' "" "")"
check "CA-26 un comando sin el token git sigue pasando por guard.sh -> allow" allow guard.sh "$(emite_bash 'ls -la' "" "")"
# CA-28: ejecutado por su cuenta decide igual que dentro de guard.sh.
check "CA-28 guard-git.sh por su cuenta decide igual" deny guard-git.sh "$(emite_bash 'git checkout .' "" "")"
# CA-29: el bit de ejecucion es parte del contrato del punto de entrada.
if [ -x "$HOOKS_DIR/guard-git.sh" ]; then
  echo "  PASS  CA-29 guard-git.sh es ejecutable"; PASS=$((PASS+1))
else
  echo "  FAIL  CA-29 guard-git.sh no tiene bit de ejecucion"; FAIL=$((FAIL+1))
fi
}

# --- REQ-006: las celdas del bloque derivado, recortadas ------------------------------
seccion_30() {
  seccion_nueva "Celdas del bloque derivado recortadas (presentacion, no lectura):"

DER="$(mktemp -d)"
mkdir -p "$DER/.arnes" "$DER/requirements" "$DER/docs"
printf '%s\n' "$MANIFIESTO_BASE" > "$DER/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$DER/PENDING_APPROVAL.md"
printf '# ESTADO\n\n## Fase\nlo que escribio una persona\n' > "$DER/docs/ESTADO.md"
LARGO="$(printf 'a%.0s' $(seq 1 1296))"
C40="$(printf 'b%.0s' $(seq 1 40))"
C41="$(printf 'c%.0s' $(seq 1 41))"
printf '# REQ-600\nEstado: en-revisión\nQA: %s\nSeguridad: pendiente\n' "$LARGO" > "$DER/requirements/REQ-600.md"
printf '# REQ-601\nEstado: en-revisión\nQA: aprobado\nSeguridad: con-hallazgos\nHallazgos abiertos: SEC-121 (instrumento)\n' > "$DER/requirements/REQ-601.md"
printf '# REQ-602\nEstado: en-revisión\nQA: %s\nSeguridad: %s\n' "$C40" "$C41" > "$DER/requirements/REQ-602.md"
printf '# REQ-603\nEstado: en-revisión\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: SEC-1|SEC-2 (contrato)\n' > "$DER/requirements/REQ-603.md"
der_corre() {
  local json
  json="$(CLAUDE_PROJECT_DIR="$DER" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')"
  : > "$ERRLOG"
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$DER" "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>"$ERRLOG"
}
der_check() {
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=$2 obtenido=$3"; diag; FAIL=$((FAIL+1)); fi
}
der_corre; DER_RC=$?
DER_FILA="$(grep '^| REQ-600 ' "$DER/docs/ESTADO.md" || true)"
DER_QA="$(printf '%s' "$DER_FILA" | awk -F' \\| ' '{print $3}')"
der_check "CA-01 la celda mide 41 como mucho y termina en elipsis" "41-si" \
  "${#DER_QA}-$(case "$DER_QA" in *…) echo si ;; *) echo no ;; esac)"
der_check "CA-02 el valor completo no entra en el archivo" "no" \
  "$(grep -qF -- "$LARGO" "$DER/docs/ESTADO.md" && echo si || echo no)"
# CA-05: una fila que no cabe deja de renderizarse como fila. La tabla es lo que el
# bloque existe para dar.
der_check "CA-05 toda fila de la tabla tiene 7 separadores" "0" \
  "$(grep '^| REQ-' "$DER/docs/ESTADO.md" | awk -F'|' 'NF!=8 {n++} END {print n+0}')"
# CA-06: una barra en el VALOR abriria una columna nueva. Se neutraliza al componer.
der_check "CA-06 una barra dentro del valor no crea una columna" "1" \
  "$(grep -c '^| REQ-603 .*sec-1¦sec-2' "$DER/docs/ESTADO.md")"
der_check "CA-03 los valores cortos salen intactos y sin elipsis" "1" \
  "$(grep -c '^| REQ-601 | en-revision | aprobado | con-hallazgos | estandar | sec-121(instrumento) |' "$DER/docs/ESTADO.md")"
DER_F602="$(grep '^| REQ-602 ' "$DER/docs/ESTADO.md" || true)"
der_check "CA-04 borde exacto: 40 intacto, 41 recortado" "40-41" \
  "$(printf '%s' "$DER_F602" | awk -F' \\| ' '{print length($3)"-"length($4)}')"
der_check "CA-10 un 'Hallazgos abiertos:' vacio sigue mostrando el guion" "1" \
  "$(grep -c '^| REQ-600 .* — |$' "$DER/docs/ESTADO.md")"
der_check "CA-17 el hook sale 0 (la parada no se bloquea nunca)" "0" "$DER_RC"
# CA-09: idempotencia. Una celda no puede ganar una segunda elipsis en cada parada.
cp "$DER/docs/ESTADO.md" "$DER/antes.md"
der_corre
der_check "CA-09 idempotente: el bloque no cambia ni la celda gana otra elipsis" "iguales" \
  "$(cmp -s "$DER/antes.md" "$DER/docs/ESTADO.md" && echo iguales || echo distintos)"
# CA-11/CA-12: EL RECORTE ES DE PRESENTACION. La puerta lee el campo ENTERO: si el
# recorte llegara a la lectura, un `Hallazgos abiertos:` largo podria perder su clase
# bloqueante por el camino y cerrar un REQ que no debia cerrarse.
cp "$DER/requirements/REQ-603.md" "$PROJ/requirements/REQ-603.md"
printf '# REQ-604\nEstado: en-revisión\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: SEC-9999999999999999999999999999999999999 (contrato)\n' > "$PROJ/requirements/REQ-604.md"
check "CA-11 hallazgo largo de clase contrato: la puerta lee el campo entero -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-604.md" "" "" 'Estado: completado')"
printf '# REQ-605\nEstado: en-revisión\nQA: aprobado con la condicion de que se repita la ronda cuando el modulo cambie\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-605.md"
check "CA-12 un QA largo que empieza por aprobado se lee como siempre -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-605.md" "" "" 'Estado: completado')"
rm -rf "$DER"
}

# --- REQ-009: la cola de aprobaciones se cuenta UNA vez, con la regla de la puerta ----
seccion_31() {
  seccion_nueva "Cola de aprobaciones: una sola regla, la de la puerta (REQ-009):"

# Un REQ listo para cerrar: lo unico que puede bloquearlo es la cola.
printf '# REQ-900\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-900.md"
CIERRE="$(emite_edit_real "$PROJ/requirements/REQ-900.md" 'en-revisión' 'completado')"

# La ENTRADA REAL del formato que documenta el propio PENDING_APPROVAL.md: un `###` y sus
# cuatro vinetas. Contra v1.30.3 la puerta decia 1 y el bloque derivado decia 4.
ENTRADA='## Pendientes

### [2026-09-05] (desarrollador) — Una decision que espera
- **Contexto** por que se detuvo aqui
- **Opciones** A / B
- **Recomendación del agente** A
- **Espera** aprobación del humano

## Resueltas
'
printf '%s' "$ENTRADA" > "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-01 la puerta cuenta 1 sobre la entrada del formato documentado" \
  'hay 1 aprobación' guard-completado.sh "$CIERRE"

# El MISMO archivo, leido por el bloque derivado: tiene que decir 1, no 4.
DER9="$(mktemp -d)"
mkdir -p "$DER9/.arnes" "$DER9/requirements" "$DER9/docs"
printf '%s\n' "$MANIFIESTO_BASE" > "$DER9/.arnes/config.json"
printf '# ESTADO\n' > "$DER9/docs/ESTADO.md"
der9_cola() {   # -> imprime lo que el bloque derivado escribe como cola
  local json
  json="$(CLAUDE_PROJECT_DIR="$DER9" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')"
  : > "$ERRLOG"
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$DER9" "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>"$ERRLOG"
  sed -n 's/^\*\*Aprobaciones pendientes:\*\* //p' "$DER9/docs/ESTADO.md" | tail -1
}
der9_check() {
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=<$2> obtenido=<$3>"; diag; FAIL=$((FAIL+1)); fi
}
printf '%s' "$ENTRADA" > "$DER9/PENDING_APPROVAL.md"
der9_check "REQ-009 CA-01 el bloque derivado dice 1 sobre la misma entrada (decia 4)" "1" "$(der9_cola)"

# CA-12: CRLF. El retorno de carro no puede cambiar la cuenta en ninguno de los dos.
printf '%s' "$ENTRADA" | sed 's/$/\r/' > "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-12 CRLF: la puerta sigue contando 1" 'hay 1 aprobación' guard-completado.sh "$CIERRE"
printf '%s' "$ENTRADA" | sed 's/$/\r/' > "$DER9/PENDING_APPROVAL.md"
der9_check "REQ-009 CA-12 CRLF: el bloque derivado tambien dice 1" "1" "$(der9_cola)"

# CA-07: un ejemplo COMENTADO dentro de la seccion no es una entrada.
COMENTADO='## Pendientes

<!--
### [AAAA-MM-DD] (agente) — Título de la decisión
- **Contexto** …
-->

## Resueltas
'
printf '%s' "$COMENTADO" > "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-07 un ejemplo comentado bajo Pendientes no bloquea el cierre" allow guard-completado.sh "$CIERRE"
printf '%s' "$COMENTADO" > "$DER9/PENDING_APPROVAL.md"
der9_check "REQ-009 CA-07 el bloque derivado tambien dice 0 con el ejemplo comentado" "0" "$(der9_cola)"

# CA-06: el archivo de arranque del arnes, con el ejemplo FUERA de la cola.
cp "$TPL_DIR/PENDING_APPROVAL.md.tpl" "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-06 la plantilla de PENDING no bloquea (ejemplo fuera de la cola)" allow guard-completado.sh "$CIERRE"

# CA-09 / CA-10: lo resuelto no bloquea, y CUALQUIER seccion cierra la cola.
printf '## Pendientes\n\n## Resueltas\n### a\n### b\n### c\n### d\n### e\n' > "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-09 cinco entradas bajo Resueltas no bloquean" allow guard-completado.sh "$CIERRE"
printf '## Pendientes\n\n## Notas\n### a\n### b\n' > "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-10 cualquier seccion cierra la cola, no solo Resueltas" allow guard-completado.sh "$CIERRE"

# CA-11: solo el nivel `###` es una entrada.
printf '## Pendientes\n### [2026-09-05] (dev) — una\n#### un subapartado suyo\n' > "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-11 un '####' no es una entrada: sigue siendo 1" 'hay 1 aprobación' guard-completado.sh "$CIERRE"

# CA-13: la forma del encabezado. Abre por prefijo; sin espacio no abre nada.
printf '## Pendientes (2 abiertas)\n### [2026-09-05] (dev) — una\n' > "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-13 '## Pendientes (2 abiertas)' abre la seccion por prefijo" 'hay 1 aprobación' guard-completado.sh "$CIERRE"
printf '##Pendientes\n### [2026-09-05] (dev) — una\n' > "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-13 '##Pendientes' sin espacio no abre la seccion (como en v1.30.3)" allow guard-completado.sh "$CIERRE"

# CA-05: control de no regresion, 0 / 1 / 3 entradas.
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-05 con 0 entradas el cierre pasa" allow guard-completado.sh "$CIERRE"
printf '## Pendientes\n### a\n### b\n### c\n' > "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-05 con 3 entradas deniega y dice cuantas" 'hay 3 aprobación' guard-completado.sh "$CIERRE"

# CA-14: sin archivo de cola, no hay cola. Ni error ni bloqueo.
rm -f "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-14 sin PENDING_APPROVAL.md el cierre no se bloquea" allow guard-completado.sh "$CIERRE"
rm -f "$DER9/PENDING_APPROVAL.md"
der9_check "REQ-009 CA-14 sin archivo el bloque derivado dice 0, no error" "0" "$(der9_cola)"

# --- Bloque C: la cola es una puerta. Si no se puede contar, no deja pasar ---
# CA-15: un NUL antes de la seccion truncaria la lectura y la cuenta saldria 0 sobre un
# archivo que nadie leyo entero. Eso ABRE el cierre de cualquier REQ con aprobaciones
# humanas abiertas: es exactamente lo que no puede pasar.
printf 'basura' > "$PROJ/PENDING_APPROVAL.md"
printf '\000' >> "$PROJ/PENDING_APPROVAL.md"
printf '\n## Pendientes\n### [2026-09-05] (dev) — una decision de verdad\n' >> "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-15 un NUL en la cola: DENY con motivo propio, nunca allow por 0" \
  'no se pudo leer entera' guard-completado.sh "$CIERRE"
# CA-16: el bloque derivado informa, no decide: no bloquea la parada, pero tampoco puede
# afirmar un numero que no midio.
cp "$PROJ/PENDING_APPROVAL.md" "$DER9/PENDING_APPROVAL.md"
DER9_COLA="$(der9_cola)"; DER9_RC=$?
der9_check "REQ-009 CA-16 con NUL el bloque dice 'sin datos', no 0" "sin datos" "$DER9_COLA"
der9_check "REQ-009 CA-16 con NUL la parada NO se bloquea (rc 0)" "0" "$DER9_RC"

# CA-17: archivo ilegible. Con root todo es legible y el caso no mide nada: se salta
# diciendolo, que es distinto de pasar.
printf '## Pendientes\n### [2026-09-05] (dev) — una\n' > "$PROJ/PENDING_APPROVAL.md"
chmod 000 "$PROJ/PENDING_APPROVAL.md" 2>/dev/null
if [ -r "$PROJ/PENDING_APPROVAL.md" ]; then
  echo "  SKIP  REQ-009 CA-17 cola ilegible (condicion: corriendo como root, chmod 000 sigue siendo legible)"
else
  check_motivo "REQ-009 CA-17 una cola ilegible deniega el cierre con el mismo motivo" \
    'no se pudo leer entera' guard-completado.sh "$CIERRE"
fi
chmod 644 "$PROJ/PENDING_APPROVAL.md" 2>/dev/null

# --- Bloque A: la regla es UNA. Se prueba por mutacion, no por lectura ---
# CA-02: ningun consumidor conserva transcripcion propia de la regla.
PROPIOS=$(grep -c -e '\^###' -e "'- '\*|'\* '\*|'1\. '\*" \
  "$HOOKS_DIR/guard-completado.sh" "$HOOKS_DIR/estado-derivado.sh" 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')
der9_check "REQ-009 CA-02 ningun consumidor conserva su propio patron de conteo" "0" "$PROPIOS"

# CA-03: se muta SOLO la funcion de lib.sh —que `###` case tambien con `####`— y se mira
# si los TRES lectores cambian. No mide que la regla sea correcta: mide que sea UNA.
MUT="$(mktemp -d)"
cp -r "$HOOKS_DIR" "$MUT/hooks"
cp -r "$HOOKS_DIR/../tools" "$MUT/tools" 2>/dev/null || true
cp -r "$HOOKS_DIR/../.claude-plugin" "$MUT/.claude-plugin" 2>/dev/null || true
mkdir -p "$MUT/proy/.arnes" "$MUT/proy/requirements" "$MUT/proy/docs"
printf '%s\n' "$MANIFIESTO_BASE" > "$MUT/proy/.arnes/config.json"
printf '# ESTADO\n' > "$MUT/proy/docs/ESTADO.md"
printf '# REQ-901\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n' > "$MUT/proy/requirements/REQ-901.md"
printf '## Pendientes\n### [2026-09-05] (dev) — una\n#### y un subapartado\n' > "$MUT/proy/PENDING_APPROVAL.md"
tres_cuentas() {   # -> "puerta|bloque|informe"
  local j p b i
  j="$(CLAUDE_PROJECT_DIR="$MUT/proy" jq -n '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
        tool_input:{file_path:(env.CLAUDE_PROJECT_DIR+"/requirements/REQ-901.md"),old_string:"en-revisión",new_string:"completado"}}')"
  p="$(printf '%s' "$j" | CLAUDE_PROJECT_DIR="$MUT/proy" "$MUT/hooks/guard-completado.sh" 2>/dev/null \
       | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' | sed -n 's/.*hay \([0-9]*\) aprobación.*/\1/p')"
  printf '%s' "$(CLAUDE_PROJECT_DIR="$MUT/proy" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')" \
    | CLAUDE_PROJECT_DIR="$MUT/proy" "$MUT/hooks/estado-derivado.sh" >/dev/null 2>&1
  b="$(sed -n 's/^\*\*Aprobaciones pendientes:\*\* //p' "$MUT/proy/docs/ESTADO.md" | tail -1)"
  i="$("$MUT/tools/arnes-lectura.sh" "$MUT/proy" 2>/dev/null | sed -n 's/.*cola de aprobaciones ([^)]*): \([0-9]*\) pendiente.*/\1/p')"
  printf '%s|%s|%s' "$p" "$b" "$i"
}
der9_check "REQ-009 CA-03 sin mutar, los tres lectores dicen 1" "1|1|1" "$(tres_cuentas)"
sed -i "s/'###'\[\[:space:\]\]\*)/'###'*)/" "$MUT/hooks/lib.sh"
der9_check "REQ-009 CA-03 mutada SOLO lib.sh, los tres cambian a 2 (la regla es una)" "2|2|2" "$(tres_cuentas)"
sed -i "s/'###'\*)/'###'[[:space:]]*)/" "$MUT/hooks/lib.sh"
der9_check "REQ-009 CA-03 retirada la mutacion, los tres vuelven a 1" "1|1|1" "$(tres_cuentas)"

# CA-20: la unificacion se paga en NEGATIVO. La puerta pagaba un `awk` por cierre y ahora
# no arranca ninguno; la parada no gana ninguno. Se mide con un awk instrumentado en PATH.
BIN9="$(mktemp -d)"
printf '#!/bin/sh\necho awk >> "%s/awk.log"\nexec /usr/bin/awk "$@"\n' "$BIN9" > "$BIN9/awk"
chmod +x "$BIN9/awk"
printf '## Pendientes\n### [2026-09-05] (dev) — una\n' > "$PROJ/PENDING_APPROVAL.md"
: > "$BIN9/awk.log"
printf '%s' "$CIERRE" | PATH="$BIN9:$PATH" "$HOOKS_DIR/guard-completado.sh" >/dev/null 2>&1
der9_check "REQ-009 CA-20 el cierre no arranca ningun awk para contar la cola" "0" "$(wc -l < "$BIN9/awk.log" | tr -d ' ')"
rm -rf "$MUT" "$DER9" "$BIN9"
}

# --- REQ-007: los huecos de la auditoria R-001 (SEC-001, SEC-002, SEC-003, SEC-006) ----
seccion_32() {
  seccion_nueva "Huecos de la auditoria de seguridad R-001 (REQ-007, bloque H):"

printf '# REQ-700\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-700.md"
printf '# REQ-701\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-701.md"

# --- SEC-003 (CA-47/CA-48): una barra de mas desactivaba LAS DOS puertas ---
# Un caracter, sin ninguna forma exotica: `arnes_ruta_relativa` recortaba el prefijo del
# proyecto TEXTUALMENTE, la ruta no empezaba por `<raiz>/`, ningun glob casaba y ninguna
# ruta caia dentro de requirements/.
check "REQ-007 CA-47 SEC-003 Write a <raiz>//src//a.ts -> deny igual que con una barra" deny \
  guard-codigo.sh "$(emite_write "$PROJ//src//a.ts" 'hola')"
check "REQ-007 CA-47 SEC-003 Edit que cierra un REQ en <raiz>//requirements//REQ-700.md -> deny" deny \
  guard-completado.sh "$(emite_edit_real "$PROJ//requirements//REQ-700.md" 'en-revisión' 'completado')"
# CA-48: los controles positivos que YA se resolvian bien no pueden romperse.
check "REQ-007 CA-48 control <raiz>/./src/../src/a.ts sigue deny" deny \
  guard-codigo.sh "$(emite_write "$PROJ/./src/../src/a.ts" 'hola')"
check "REQ-007 CA-48 control <raiz>/src/./a.ts sigue deny" deny \
  guard-codigo.sh "$(emite_write "$PROJ/src/./a.ts" 'hola')"
check "REQ-007 CA-48 control ruta relativa src/a.ts sigue deny" deny \
  guard-codigo.sh "$(emite_write "src/a.ts" 'hola')"
check "REQ-007 CA-48 control ./src/a.ts sigue deny" deny \
  guard-codigo.sh "$(emite_write "./src/a.ts" 'hola')"
# CA-48 (a): lo que decide es el glob, no la barra.
check "REQ-007 CA-48 <raiz>//docs//notas.md (fuera de los globs) -> allow" allow \
  guard-codigo.sh "$(emite_write "$PROJ//docs//notas.md" 'hola')"
# CA-48 (b): la doble barra INICIAL de una UNC de Windows no se colapsa.
check "REQ-007 CA-48 una ruta UNC //servidor/recurso/x.ts conserva su forma -> allow" allow \
  guard-codigo.sh "$(emite_write "//servidor/recurso/src/a.ts" 'hola')"
# CA-48 (c): la restriccion sigue siendo de QUIEN edita.
check "REQ-007 CA-48 el desarrollador si puede escribir en <raiz>//src//a.ts" allow \
  guard-codigo.sh "$(jq -n --arg fp "$PROJ//src//a.ts" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,agent_id:"a1",agent_type:"desarrollador",tool_input:{file_path:$fp,content:"hola"}}')"

# --- SEC-001 (CA-43/CA-44): un byte de control desincronizaba la simulacion ---
# El separador de las piezas viaja DENTRO del dato que controla quien llama. Con campos
# de mas, el bucle leia como tripletas cosas que no lo eran y el documento que el hook
# simulaba dejaba de ser el que la herramienta iba a escribir: las cuatro puertas del
# cierre se saltaban a la vez, con un byte.
SOH=$'\001'
check "REQ-007 CA-43 SEC-001 MultiEdit con un byte de control en el new_string -> deny" deny \
  guard-completado.sh "$(jq -n --arg fp "$PROJ/requirements/REQ-700.md" --arg ns "completado${SOH}x${SOH}y${SOH}1" \
    '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,edits:[{old_string:"en-revisión",new_string:$ns},{old_string:"# REQ-700",new_string:"# REQ-700"}]}}')"
check "REQ-007 CA-43 SEC-001 Write con 'nota'+byte de control delante del documento cerrado -> deny" deny \
  guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-700.md" "nota${SOH}# REQ-700
Estado: completado
QA: pendiente
")"
check "REQ-007 CA-44 control: el MultiEdit HONESTO que cierra con QA pendiente ya denegaba" deny \
  guard-completado.sh "$(emite_multiedit "$PROJ/requirements/REQ-700.md" 'en-revisión' 'completado' '# REQ-700' '# REQ-700 x')"
check "REQ-007 CA-44 control: el mismo MultiEdit sobre un REQ en verde -> allow" allow \
  guard-completado.sh "$(emite_multiedit "$PROJ/requirements/REQ-701.md" 'en-revisión' 'completado' '# REQ-701' '# REQ-701 x')"
check "REQ-007 CA-44 control: tabuladores y saltos de linea legitimos no son un falso positivo" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-701.md" '# REQ-701' "# REQ-701
| a	| b |
")"

# --- SEC-002 (CA-45/CA-46): un NUL en el REQ truncaba la lectura del disco ---
# `read -d ''` se detiene en el primer NUL: los veredictos se leian de un texto incompleto
# —y un campo vacio no exige nada— y ademas el `old_string` no se encontraba, asi que la
# puerta caia a la via mas laxa. Bastaba una escritura previa en requirements/.
printf '# REQ-702 ' > "$PROJ/requirements/REQ-702.md"
printf '\000' >> "$PROJ/requirements/REQ-702.md"
printf ' nota\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n' >> "$PROJ/requirements/REQ-702.md"
check_motivo "REQ-007 CA-45 SEC-002 un NUL en el REQ: el cierre deniega con motivo propio" \
  'no se puede leer entero' guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-702.md" 'en-revisión' 'completado')"
check "REQ-007 CA-46 control: sobre el REQ con NUL, una edicion que no toca el estado -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-702.md" 'nota' 'otra anotacion')"
check "REQ-007 CA-46 control: el mismo REQ SIN NUL y con QA pendiente -> deny (como siempre)" deny \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-700.md" 'en-revisión' 'completado')"
check "REQ-007 CA-46 control: el mismo REQ SIN NUL y con los veredictos completos -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-701.md" 'en-revisión' 'completado')"

# --- SEC-006 parte (b) (CA-54/CA-55): el techo del manifiesto no tenia tope ---
# El coste del analisis crece con el tamano y un hook PreToolUse MUERE a los 60 s
# permitiendo: sin maximo, subir el techo desde el manifiesto reabria POR CONFIGURACION
# el fallo en abierto que el presupuesto cerro.
GRANDE="$(printf 'a%.0s' $(seq 1 140000))"
MEDIANO="$(printf 'a%.0s' $(seq 1 70000))"
setcfg '.limites.bash_max_analisis = 4294967296'
check_motivo "REQ-007 CA-54 SEC-006 un techo de 4294967296 se recorta al maximo y el deny lo dice" \
  'presupuesto de analisis vigente es de 131072 bytes' guard-codigo.sh "$(emite_bash "$GRANDE" "" "")"
setcfg '.limites.bash_max_analisis = 99999999999999999999'
check_motivo "REQ-007 CA-54 SEC-006 un valor que desborda 64 bits tampoco sube el techo" \
  'presupuesto de analisis vigente es de 131072 bytes' guard-codigo.sh "$(emite_bash "$GRANDE" "" "")"
setcfg '.limites.bash_max_analisis = "999999"'
check_motivo "REQ-007 CA-54 SEC-006 '999999' entrecomillado no es un numero: cae al defecto" \
  'presupuesto de analisis vigente es de 65536 bytes' guard-codigo.sh "$(emite_bash "$MEDIANO" "" "")"
# CA-55: los cuatro controles ya medidos. Su veredicto es identico al de v1.30.3.
setcfg '.limites.bash_max_analisis = 100'
check_motivo "REQ-007 CA-55 control: un valor mas bajo que el defecto no baja el techo" \
  'presupuesto de analisis vigente es de 65536 bytes' guard-codigo.sh "$(emite_bash "$MEDIANO" "" "")"
setcfg '.limites.bash_max_analisis = -5'
check_motivo "REQ-007 CA-55 control: -5 cae al defecto" \
  'presupuesto de analisis vigente es de 65536 bytes' guard-codigo.sh "$(emite_bash "$MEDIANO" "" "")"
setcfg '.limites.bash_max_analisis = 0'
check_motivo "REQ-007 CA-55 control: 0 cae al defecto" \
  'presupuesto de analisis vigente es de 65536 bytes' guard-codigo.sh "$(emite_bash "$MEDIANO" "" "")"
setcfg 'del(.limites)'
check_motivo "REQ-007 CA-55 control: la clave ausente cae al defecto" \
  'presupuesto de analisis vigente es de 65536 bytes' guard-codigo.sh "$(emite_bash "$MEDIANO" "" "")"
# CA-55: el motivo del deny por presupuesto NO nombra ninguna ruta (QA-016 de REQ-001).
S7_MOT="$(printf '%s' "$(emite_bash "$MEDIANO" "" "")" | "$HOOKS_DIR/guard-codigo.sh" 2>/dev/null | jq -r '.hookSpecificOutput.permissionDecisionReason // ""')"
if [ -n "$FILTRO" ] && ! printf '%s' "REQ-007 CA-55 el deny por presupuesto no nombra ninguna ruta" | grep -qi -- "$FILTRO"; then :
elif printf '%s' "$S7_MOT" | grep -q 'src/'; then
  echo "  FAIL  REQ-007 CA-55 el deny por presupuesto no nombra ninguna ruta"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-007 CA-55 el deny por presupuesto no nombra ninguna ruta"; PASS=$((PASS+1))
fi
# CA-53, control obligatorio: la ampliacion de globs es MAPEO de ArnesJuan y no se propaga
# a las plantillas. Si un dia aparece ahi, este caso se pone rojo.
if [ -n "$FILTRO" ] && ! printf '%s' "REQ-007 CA-53 ninguna plantilla hereda los globs del autoalojamiento" | grep -qi -- "$FILTRO"; then :
elif sed -n '/"codigo_app"/,/^  }/p' "$TPL_DIR/arnes-config.json.tpl" | grep -qE '\.arnes|\.claude-plugin'; then
  echo "  FAIL  REQ-007 CA-53 ninguna plantilla hereda los globs del autoalojamiento"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-007 CA-53 ninguna plantilla hereda los globs del autoalojamiento"; PASS=$((PASS+1))
fi

# --- QA-014 (CA-40/CA-41): la clase del hallazgo solo se leia en forma CERRADA ---
# `AGENTS.md` 6 pide anotar dueno y forzador en la deuda de `instrumento`, y la puerta
# denegaba el cierre justo por esa anotacion: partia la lista por comas sin mirar el
# parentesis y leia «un hallazgo sin clase». Castigaba lo que la metodologia pide.
mkreq "$PROJ/requirements/REQ-710.md" no aprobado n/a 'QA-006 (instrumento, dueño REQ-007)'
check "REQ-007 CA-40 QA-014 '(instrumento, dueño REQ-007)': la clase es el primer elemento -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-710.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-711.md" no aprobado n/a 'SEC-9 (usuario/dinero, dueño desarrollador, vence 2026-10-01)'
check_motivo "REQ-007 CA-40 QA-014 la evidencia acompana, nunca cambia el veredicto -> deny por la clase" \
  "clase 'usuario/dinero'" guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-711.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-712.md" no aprobado n/a 'QA-006 (nota, instrumento)'
check_motivo "REQ-007 CA-41 control: la clase NO es el primer elemento -> deny" \
  'no cuenta como hallazgo' guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-712.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-713.md" no aprobado n/a 'QA-006 [instrumento]'
check_motivo "REQ-007 CA-41 control: otro delimitador no es un parentesis -> deny" \
  'no cuenta como hallazgo' guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-713.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-714.md" no aprobado n/a 'QA-006 (dueño REQ-007)'
# El motivo admite las dos redacciones —la de v1.30.3 y la de esta version—: lo que este
# control acredita es que un hallazgo sin clase reconocible NO cierra, en las dos.
check_motivo "REQ-007 CA-41 control: sin ninguna clase -> deny" \
  'no cuenta como hallazgo|no es una clase valida|que no existe' guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-714.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-715.md" no aprobado n/a 'QA-006 (Instrumento)'
check "REQ-007 CA-41 control: '(Instrumento)' se sigue leyendo como hoy -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-715.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-716.md" no aprobado n/a 'QA-006 ( instrumento )'
check "REQ-007 CA-41 control: '( instrumento )' se sigue leyendo como hoy -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-716.md" 'en-revisión' 'completado')"
mkreq "$PROJ/requirements/REQ-717.md" no aprobado n/a 'QA-006 (instrumento) — REQ-007'
check "REQ-007 CA-41 control: '(instrumento) — REQ-007' se sigue leyendo como hoy -> allow" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-717.md" 'en-revisión' 'completado')"

# --- SEC-007 (CA-56/CA-57): la reconstruccion no tenia techo ---
# El presupuesto fail-closed del analisis de Bash vivia SOLO en el detector de escrituras;
# la via Edit/MultiEdit aplicaba cada edicion sobre una copia completa del texto. Medido:
# 1.501 ediciones sobre 300 KB -> 25,7 s, y 3,1 MB x 401 ediciones -> sin respuesta a los
# 30 s. A los 60 s el hook muere sin emitir nada y el resultado efectivo es PERMITIR.
S7BIG="$PROJ/requirements/REQ-720.md"
{ printf '# REQ-720\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n'
  for i in $(seq 0 49); do printf 'marca%s\n' "$i"; done
  printf 'x%.0s' $(seq 1 700000); printf '\n'; } > "$S7BIG"
# emite_multi_n <file> <n> — n ediciones iguales en UNA sola llamada a jq.
emite_multi_n() {
  jq -n --arg fp "$1" --argjson n "$2" \
    '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,edits:[range($n)|{old_string:"en-revisión",new_string:"completado"}]}}'
}
check_motivo "REQ-007 CA-56 SEC-007 100 ediciones sobre 700 KB superan el presupuesto -> deny" \
  'presupuesto de 67108864 bytes-edicion' guard-completado.sh "$(emite_multi_n "$S7BIG" 100)"
# CA-56: el motivo dice el presupuesto y NO nombra ninguna ruta.
S7_M="$(printf '%s' "$(emite_multi_n "$S7BIG" 100)" | "$HOOKS_DIR/guard-completado.sh" 2>/dev/null | jq -r '.hookSpecificOutput.permissionDecisionReason // ""')"
if [ -n "$FILTRO" ] && ! printf '%s' "REQ-007 CA-56 el deny por presupuesto de reconstruccion no nombra ninguna ruta" | grep -qi -- "$FILTRO"; then :
elif printf '%s' "$S7_M" | grep -qE 'REQ-720|requirements/'; then
  echo "  FAIL  REQ-007 CA-56 el deny por presupuesto de reconstruccion no nombra ninguna ruta"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-007 CA-56 el deny por presupuesto de reconstruccion no nombra ninguna ruta"; PASS=$((PASS+1))
fi
# CA-57 (b): por DEBAJO del presupuesto se reconstruye y se juzga con el veredicto de siempre.
# 50 ediciones REALES —cada una casa con su marca en el documento— mas el cierre: el
# documento se reconstruye de verdad y se juzga por su cabecera resultante.
check "REQ-007 CA-57 control: 50 ediciones (bajo el presupuesto) se juzgan como siempre -> deny" deny \
  guard-completado.sh "$(jq -n --arg fp "$S7BIG" '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,edits:([range(50)|{old_string:("marca"+tostring),new_string:("MARCA"+tostring)}]
                                       + [{old_string:"en-revisión",new_string:"completado"}])}}')"
# CA-57 (c): por encima del presupuesto NUNCA hay allow, ni siquiera para el agente de codigo.
check "REQ-007 CA-57 control: el deny por presupuesto alcanza tambien al desarrollador" deny \
  guard-completado.sh "$(emite_multi_n "$S7BIG" 100 | jq '. + {agent_id:"a1",agent_type:"desarrollador"}')"
# CA-57 (a): el caso ordinario no cambia de veredicto ni de coste.
check "REQ-007 CA-57 control: una edicion sola sobre el mismo REQ se juzga como siempre -> deny" deny \
  guard-completado.sh "$(emite_edit_real "$S7BIG" 'en-revisión' 'completado')"
}

TOTAL_SECCIONES=33

# --- REQ-010 (el acento no es parte del valor) + REQ-007 bloque A (la clave tambien se
# --- decora) + SEC-004 (enlace simbolico) + SEC-006 parte a (el manifiesto, en este repo)
# Las dos primeras son LAS DOS MITADES DE LA MISMA LINEA: el valor lo normaliza
# `arnes_norm_campo` y la clave `arnes_norm_clave`, y las dos comparten la misma regla.
# Por eso van en la misma seccion: si una se arregla sin la otra, el defecto reaparece en
# la mitad de al lado.
seccion_33() {
  seccion_nueva "El acento y la clave decorada (REQ-010 + REQ-007 bloque A, SEC-004):"

# Fixtures NFD escritos con ESCAPES DE BYTES EXPLICITOS, nunca copiando y pegando: un
# editor puede re-normalizar al guardar y el fixture dejaria de medir lo que dice medir.
NFD_O=$'o\xcc\x81'      # o + U+0301 COMBINING ACUTE  == "ó" en NFD
NFD_A=$'a\xcc\x81'      # a + U+0301                  == "á" en NFD
NFD_N=$'n\xcc\x83'      # n + U+0303 COMBINING TILDE  == "ñ" en NFD

# ---------- REQ-010 · informe (arnes-lectura): el mismo lector que la puerta ----------
L33="$(mktemp -d)"; mkdir -p "$L33/.arnes" "$L33/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$L33/.arnes/config.json"
LEC33="$HOOKS_DIR/../tools/arnes-lectura.sh"
# lec33 <nombre> <rc esperado> <patron> <si|no aparece>
lec33() {
  local nombre="$1" rc_esp="$2" patron="$3" debe="$4" out rc hay=no
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  out="$(: > "$ERRLOG"; bash "$LEC33" "$L33" 2>"$ERRLOG")"; rc=$?
  if [ -z "$out" ]; then
    echo "  FAIL  $nombre  el informe no imprimio NADA: no midio nada"; diag; FAIL=$((FAIL+1)); return 0
  fi
  printf '%s' "$out" | grep -Eq -- "$patron" && hay=si
  if [ "$rc" = "$rc_esp" ] && [ "$hay" = "$debe" ]; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  rc=$rc (esperado $rc_esp), patron aparece=$hay (esperado $debe)"; diag; FAIL=$((FAIL+1)); fi
}

# CA-01: EL CASO MEDIDO. `estados.todos` por defecto trae `en-revisión`; el REQ lo escribe
# sin tilde. Contra v1.30.3 esto sale como «ninguna puerta lo reconoce» y el informe sale 1.
printf '# REQ-800\nEstado: en-revision\nQA: aprobado\nSeguridad: n/a\n' > "$L33/requirements/REQ-800.md"
lec33 "REQ-010 CA-01 'Estado: en-revision' SIN tilde no es anomalia (sale 0)" 0 'REQ-800' no
# CA-03: la misma cabecera en NFD (bytes explicitos) tampoco lo es.
printf '# REQ-801\nEstado: en-revisi%sn\nQA: aprobado\nSeguridad: n/a\n' "$NFD_O" > "$L33/requirements/REQ-801.md"
lec33 "REQ-010 CA-03 'en-revisión' en NFD (o+U+0301) no es anomalia (sale 0)" 0 'REQ-801' no
# CA-04: `estándar` no se reconocia porque `á` no estaba en la unica pareja que se plegaba.
printf '# REQ-802\nEstado: en-revision\nQA: aprobado\nSeguridad: n/a\nRigor: est%sndar\n' 'á' > "$L33/requirements/REQ-802.md"
lec33 "REQ-010 CA-04 'Rigor: estándar' se reconoce (sale 0)" 0 'REQ-802' no
printf '# REQ-803\nEstado: en-revision\nQA: aprobado\nSeguridad: n/a\nRigor: cr%stico\n' 'í' > "$L33/requirements/REQ-803.md"
lec33 "REQ-010 CA-04 no-regresion: 'Rigor: crítico' se sigue reconociendo" 0 'REQ-803' no
# CA-11/CA-12: lo que YA se normalizaba no se pierde.
printf '# REQ-804\nEstado: En-Revisi%sn\nQA: **pendiente**\nSeguridad: n/a\n' 'ó' > "$L33/requirements/REQ-804.md"
printf '# REQ-805\nEstado: en-revisi%sn (2026-08-25, tras la ronda 3)\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$L33/requirements/REQ-805.md"
lec33 "REQ-010 CA-11 mayusculas, enfasis y parentesis de evidencia siguen sin marcarse" 0 'REQ-80[45]' no
rm -f "$L33/requirements/REQ-80"[0-5]".md"
# CA-12: un asterisco SUELTO no es enfasis y sigue sin leerse como veredicto.
printf '# REQ-806\nEstado: en-revision\nQA: aprobado*\nSeguridad: n/a\n' > "$L33/requirements/REQ-806.md"
lec33 "REQ-010 CA-12 'QA: aprobado*' (nota al pie) sigue siendo anomalia (sale 1)" 1 'REQ-806' si
rm -f "$L33/requirements/REQ-806.md"
# CA-08: LO QUE NO SE ENSANCHA. Esto pliega ortografia, no separadores ni palabras.
printf '# REQ-807\nEstado: en revision\nQA: aprobado\nSeguridad: n/a\n' > "$L33/requirements/REQ-807.md"
printf '# REQ-808\nEstado: enrevision\nQA: aprobado\nSeguridad: n/a\n' > "$L33/requirements/REQ-808.md"
printf '# REQ-809\nEstado: revisi%sn\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$L33/requirements/REQ-809.md"
lec33 "REQ-010 CA-08 'en revision', 'enrevision' y 'revisión' siguen siendo anomalia" 1 'REQ-80[789]' si
rm -f "$L33/requirements/REQ-80"[789]".md"
# CA-09: la pertenencia al vocabulario sigue siendo EXACTA, no por prefijo (REQ-003 CA-18).
printf '# REQ-810\nEstado: en-revision-parcial\nQA: aprobado\nSeguridad: n/a\n' > "$L33/requirements/REQ-810.md"
lec33 "REQ-010 CA-09 'en-revision-parcial' sigue siendo anomalia (sale 1)" 1 'REQ-810' si
# CA-13: el aviso ensena el valor CRUDO ademas del normalizado. Quien lee el aviso tiene
# que poder ENCONTRAR el texto en su editor; si solo viera el plegado, buscaria en vano.
printf '# REQ-811\nEstado: revisi%sn\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$L33/requirements/REQ-811.md"
lec33 "REQ-010 CA-13 el aviso ensena el valor CRUDO con su tilde" 1 'escrito:  «revisión»' si
lec33 "REQ-010 CA-13 ...y al lado el normalizado que lee la maquina" 1 'se lee:   <revision>' si
rm -f "$L33/requirements/REQ-810.md" "$L33/requirements/REQ-811.md"
# CA-02: LA DIRECCION INVERSA. El manifiesto declara el estado SIN tilde y el REQ lo
# escribe CON tilde: la normalizacion se aplica a los DOS lados de la comparacion.
python3 - "$L33/.arnes/config.json" <<'PY' 2>/dev/null || jq '.estados.todos = ["borrador","en-revision","completado"]' "$L33/.arnes/config.json" > "$L33/.arnes/c2" && mv "$L33/.arnes/c2" "$L33/.arnes/config.json"
import json,sys
p=sys.argv[1]; d=json.load(open(p)); d["estados"]["todos"]=["borrador","en-revision","completado"]
json.dump(d,open(p,"w"))
PY
printf '# REQ-812\nEstado: en-revisi%sn\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$L33/requirements/REQ-812.md"
lec33 "REQ-010 CA-02 manifiesto SIN tilde + REQ CON tilde: tampoco es anomalia" 0 'REQ-812' no
# CA-10: LA FRONTERA. La `ñ` NO es una `n` con adorno: plegarla haria iguales dos palabras
# distintas. Con un vocabulario que declara `año`, el valor `ano` NO casa.
jq '.estados.todos = ["borrador","año","completado"]' "$L33/.arnes/config.json" > "$L33/.arnes/c3" && mv "$L33/.arnes/c3" "$L33/.arnes/config.json"
rm -f "$L33/requirements/REQ-812.md"
printf '# REQ-813\nEstado: ano\nQA: aprobado\nSeguridad: n/a\n' > "$L33/requirements/REQ-813.md"
lec33 "REQ-010 CA-10 la ñ no se pliega: 'ano' no casa con 'año' (sigue anomalia)" 1 'REQ-813' si
printf '# REQ-814\nEstado: a%so\nQA: aprobado\nSeguridad: n/a\n' 'ñ' > "$L33/requirements/REQ-814.md"
rm -f "$L33/requirements/REQ-813.md"
lec33 "REQ-010 CA-10 control: 'año' con ñ SI casa con 'año'" 0 'REQ-814' no
# CA-10 en NFD: `n`+U+0303 tampoco se pliega, porque el diacritico solo se retira tras VOCAL.
printf '# REQ-815\nEstado: a%so\nQA: aprobado\nSeguridad: n/a\n' "$NFD_N" > "$L33/requirements/REQ-815.md"
rm -f "$L33/requirements/REQ-814.md"
lec33 "REQ-010 CA-10 la ñ tampoco se pliega en NFD (n+U+0303 no es 'n')" 1 'REQ-815' si
rm -rf "$L33"

# ---------- REQ-010 · LA PUERTA: el fallo EN ABIERTO que esto cierra ----------
# Un proyecto cuyo `estados.completado` lleva acento —el manifiesto lo declara cada
# proyecto: es mapeo, no mecanismo— y un REQ critico con la auditoria pendiente. Escribir
# el estado SIN tilde hacia que la puerta NO VIERA la transicion: allow, y un REQ critico
# cerrado sin veredicto de seguridad. Falla en abierto y en silencio.
P810="$RAIZ/p810-$BASHPID"; mkdir -p "$P810/.arnes" "$P810/requirements" "$P810/src"
jq '.estados = {"completado":"aprobación","todos":["en-revisión","aprobación"]}' <<< "$MANIFIESTO_BASE" > "$P810/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P810/PENDING_APPROVAL.md"
printf '# REQ-820\nEstado: en-revisi%sn\nSensible a seguridad: s%s\nQA: aprobado\nSeguridad: pendiente\n' 'ó' 'í' > "$P810/requirements/REQ-820.md"
CLAUDE_PROJECT_DIR="$P810" check "REQ-010 CA-05 estado terminal acentuado escrito SIN tilde -> deny (era ALLOW)" deny \
  guard-completado.sh "$(CLAUDE_PROJECT_DIR="$P810" jq -n --arg fp "$P810/requirements/REQ-820.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$fp|sub("/requirements/.*";""),
      tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"aprobacion"}}')"
CLAUDE_PROJECT_DIR="$P810" check "REQ-010 CA-05 control: el mismo cierre CON tilde ya denegaba" deny \
  guard-completado.sh "$(CLAUDE_PROJECT_DIR="$P810" jq -n --arg fp "$P810/requirements/REQ-820.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$fp|sub("/requirements/.*";""),
      tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"aprobación"}}')"
# CA-06: la direccion contraria. El REQ YA estaba en el estado terminal acentuado y la
# edicion solo cambia la ORTOGRAFIA: no hay transicion nueva que inventar.
printf '# REQ-821\nEstado: aprobaci%sn\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$P810/requirements/REQ-821.md"
CLAUDE_PROJECT_DIR="$P810" check "REQ-010 CA-06 reescribir 'aprobación' como 'aprobacion' no cambia el veredicto" allow \
  guard-completado.sh "$(CLAUDE_PROJECT_DIR="$P810" jq -n --arg fp "$P810/requirements/REQ-821.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$fp|sub("/requirements/.*";""),
      tool_input:{file_path:$fp,old_string:"aprobación",new_string:"aprobacion"}}')"
# CA-22: EL VEREDICTO NO PUEDE DEPENDER DEL LOCALE del entorno en que arranca el hook,
# porque ese entorno no lo elige el arnes. Se mide el MISMO caso bajo tres locales.
J820="$(CLAUDE_PROJECT_DIR="$P810" jq -n --arg fp "$P810/requirements/REQ-820.md" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$fp|sub("/requirements/.*";""),
    tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"aprobacion"}}')"
for LOC in C C.UTF-8 es_ES.UTF-8; do
  got="$(printf '%s' "$J820" | LC_ALL="$LOC" CLAUDE_PROJECT_DIR="$P810" bash "$HOOKS_DIR/guard-completado.sh" 2>/dev/null | grep -Eo '"permissionDecision": *"deny"' | head -1)"
  if [ -n "$got" ]; then echo "  PASS  REQ-010 CA-22 mismo veredicto (deny) bajo LC_ALL=$LOC"; PASS=$((PASS+1))
  else echo "  FAIL  REQ-010 CA-22 bajo LC_ALL=$LOC el veredicto cambio (no denego)"; FAIL=$((FAIL+1)); fi
done
# CA-07: el bloque derivado cuenta las TRES escrituras en la MISMA casilla.
mkdir -p "$P810/docs"; printf '# ESTADO\n\n## Fase\nx\n' > "$P810/docs/ESTADO.md"
rm -f "$P810/requirements/REQ-82"[01]".md"
printf '# REQ-830\nEstado: en-revisi%sn\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$P810/requirements/REQ-830.md"
printf '# REQ-831\nEstado: en-revision\nQA: aprobado\nSeguridad: n/a\n' > "$P810/requirements/REQ-831.md"
printf '# REQ-832\nEstado: en-revisi%sn\nQA: aprobado\nSeguridad: n/a\n' "$NFD_O" > "$P810/requirements/REQ-832.md"
printf '%s' "$(CLAUDE_PROJECT_DIR="$P810" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')" \
  | CLAUDE_PROJECT_DIR="$P810" bash "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>"$ERRLOG"
n_rev="$(grep -c '^| REQ-83[012] | en-revision |' "$P810/docs/ESTADO.md" 2>/dev/null || true)"
if [ "${n_rev:-0}" = "3" ]; then echo "  PASS  REQ-010 CA-07 las tres escrituras caen en la MISMA casilla del bloque derivado"; PASS=$((PASS+1))
else echo "  FAIL  REQ-010 CA-07 solo $n_rev de 3 cayeron en la casilla de 'en revision'"; diag; FAIL=$((FAIL+1)); fi

# ---------- REQ-010 · CA-14/CA-18: UNA sola normalizacion, y ninguna pareja a mano ----
LIBSH="$HOOKS_DIR/lib.sh"
otros=0
for f in "$HOOKS_DIR/guard-completado.sh" "$HOOKS_DIR/guard-codigo.sh" "$HOOKS_DIR/estado-derivado.sh" \
         "$HOOKS_DIR/campos-req.awk" "$HOOKS_DIR/../tools/arnes-lectura.sh"; do
  [ -f "$f" ] || continue
  grep -Eq '(//|/)[áéíóúüÁÉÍÓÚÜ]/' "$f" && otros=$((otros+1))
done
if [ "$otros" -eq 0 ]; then echo "  PASS  REQ-010 CA-14 el plegado vive SOLO en lib.sh; nadie tiene el suyo"; PASS=$((PASS+1))
else echo "  FAIL  REQ-010 CA-14 $otros archivo(s) fuera de lib.sh pliegan acentos por su cuenta"; FAIL=$((FAIL+1)); fi
# CA-18: el defecto NOMBRADO. Lo que habia era la pareja `Í`/`í` escrita a mano para el
# caso de `sí`, y ninguna mas: el sujeto del control era mas estrecho que su poblacion.
if grep -Eq '^\s*v="\$\{v//Í/i\}"; v="\$\{v//í/i\}"' "$LIBSH"; then
  echo "  FAIL  REQ-010 CA-18 sigue la pareja Í/í escrita a mano para un caso concreto"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-010 CA-18 no queda ninguna pareja de letras escrita a mano"; PASS=$((PASS+1))
fi
# CA-20: SOLO expansion de parametros. Ni un `sed`, `tr`, `iconv` o `awk` nuevo en el plegado.
if awk '/^arnes_pliega_ortografia\(\)/,/^}/' "$LIBSH" | grep -Eq '\b(sed|tr|iconv|perl|awk|python3?)\b'; then
  echo "  FAIL  REQ-010 CA-20 el plegado invoca un binario externo"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-010 CA-20 el plegado es solo expansion de parametros (ningun binario)"; PASS=$((PASS+1))
fi

# CA-19: EL CAMINO COMUN NO GANA NI UN PROCESO. Se instrumentan `sed`, `tr` e `iconv` en
# el PATH: sus registros tienen que quedar VACIOS tras un `ls -la` cualquiera.
BIN33="$RAIZ/bin33-$BASHPID"; mkdir -p "$BIN33"
for b in sed tr iconv; do
  real="$(command -v "$b" 2>/dev/null || true)"
  printf '#!/bin/sh\necho "%s $*" >> "%s/registro-%s"\nexec %s "$@"\n' "$b" "$BIN33" "$b" "${real:-/bin/true}" > "$BIN33/$b"
  chmod +x "$BIN33/$b"
done
printf '%s' "$(jq -n '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{command:"ls -la"}}')" \
  | PATH="$BIN33:$PATH" bash "$HOOKS_DIR/guard.sh" >/dev/null 2>"$ERRLOG"
huellas=0
for b in sed tr iconv; do [ -s "$BIN33/registro-$b" ] && huellas=$((huellas+1)); done
if [ "$huellas" -eq 0 ]; then echo "  PASS  REQ-010 CA-19 'ls -la' por guard.sh: registros de sed, tr e iconv VACIOS"; PASS=$((PASS+1))
else echo "  FAIL  REQ-010 CA-19 $huellas binario(s) instrumentado(s) se invocaron en el camino comun"; FAIL=$((FAIL+1)); fi

# ---------- REQ-007 bloque A: LA CLAVE DEL CAMPO TAMBIEN SE DECORA ----------
# Todos sobre un REQ con `QA: pendiente`: si la clave se lee, la puerta DENIEGA por el
# veredicto que falta; si no se lee, el campo queda vacio y la puerta deja pasar.
mk_req() { printf '%s\n' "$1" > "$PROJ/requirements/REQ-840.md"; }
cierra() { emite_write "$PROJ/requirements/REQ-840.md" "$1"; }
TAB=$'\t'
mk_req "# REQ-840"
check "REQ-007 CA-01 'Estado:<TAB>completado' con QA pendiente -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado:${TAB}completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-02 '**Estado:** completado' (clave decorada) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
**Estado:** completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-03 ' Estado: completado' (un espacio de sangrado) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
 Estado: completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-03 '  Estado: completado' (dos espacios) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
  Estado: completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-03 '<TAB>Estado: completado' -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
${TAB}Estado: completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-04 'Estado : completado' (espacio antes de los dos puntos) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado : completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-04 '__Estado:__ completado' -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
__Estado:__ completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-04 '*Estado:* completado' -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
*Estado:* completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-04 '\`Estado:\` completado' -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
\`Estado:\` completado
QA: pendiente
Seguridad: n/a
")"
# CA-04 (la regla, no la lista): una forma que NADIE ha escrito todavia.
check "REQ-007 CA-04 '**Estado** : completado' (forma no enumerada) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
**Estado** : completado
QA: pendiente
Seguridad: n/a
")"
# CA-05/CA-06: LA TOLERANCIA ES SOBRE COMO SE ESCRIBE LA CLAVE, NUNCA SOBRE DONDE VALE.
printf '# REQ-841\nEstado: en-revisión\nQA: aprobado\nSeguridad: n/a\n\n## Historial de cambios\nEstado: completado\n**Estado:** completado\n' > "$PROJ/requirements/REQ-841.md"
check "REQ-007 CA-05 control: 'Estado: completado' DENTRO de una seccion no cierra nada" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-841.md" '# REQ-841' '# REQ-841 (nota)')"
printf '# REQ-842\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\n\n## Historial de cambios\n**Seguridad:** aprobado\n' > "$PROJ/requirements/REQ-842.md"
check "REQ-007 CA-06 control: un '**Seguridad:** aprobado' en una seccion sigue sin ser veredicto" deny \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-842.md" 'en-revisión' 'completado')"
# CA-07: EL FALLO EN ABIERTO de este bloque. La clave decorada dejaba el campo VACIO, y un
# campo vacio significa «ningun hallazgo»: el REQ cerraba con un hallazgo bloqueante escrito.
check_motivo "REQ-007 CA-07 '**Hallazgos abiertos:** SEC-9 (usuario/dinero)' -> deny por la clase" \
  'usuario/dinero|hallazgo' guard-completado.sh "$(cierra "# REQ-840
Estado: completado
QA: aprobado
Seguridad: n/a
**Hallazgos abiertos:** SEC-9 (usuario/dinero)
")"
# CA-08: la regla vale para LOS SEIS campos, no solo para `Estado:`.
check "REQ-007 CA-08 '**Sensible a seguridad:** sí' con Seguridad pendiente -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado: completado
**Sensible a seguridad:** sí
QA: aprobado
Seguridad: pendiente
")"
check "REQ-007 CA-08 '**QA:** pendiente' -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado: completado
Sensible a seguridad: no
**QA:** pendiente
Seguridad: n/a
")"
check "REQ-007 CA-08 '**Rigor:** ligero' sobre un REQ sensible (el suelo manda) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado: completado
Sensible a seguridad: sí
**Rigor:** ligero
QA: aprobado
Seguridad: pendiente
")"
# CA-09: LEER DE MAS CAE DEL LADO QUE CIERRA LA PUERTA. La tolerancia nunca BAJA una
# exigencia: `**Rigor:** critico` sobre un REQ no sensible se lee `critico` y exige auditoria.
check "REQ-007 CA-09 '**Rigor:** critico' en un REQ no sensible se LEE critico -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado: completado
Sensible a seguridad: no
**Rigor:** critico
QA: aprobado
Seguridad: pendiente
")"
# Control: el mismo REQ con todo en verde SI cierra. Sin esto, los deny de arriba podrian
# estar denegando por cualquier otra razon.
check "REQ-007 bloque A control: clave decorada + todo en verde -> allow" allow \
  guard-completado.sh "$(cierra "# REQ-840
**Estado:** completado
**Sensible a seguridad:** no
**QA:** aprobado
**Seguridad:** n/a
**Hallazgos abiertos:** (ninguno)
")"
# CA-22: EL INFORME LEE EXACTAMENTE LO QUE LEE LA PUERTA, tambien la clave decorada.
# Un informe que dijera «nota sin Estado» sobre un REQ que la puerta ya juzga cerrado miente.
K33="$(mktemp -d)"; mkdir -p "$K33/.arnes" "$K33/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$K33/.arnes/config.json"
printf '# REQ-850\n**Estado:** en-revisión\n**QA:** aprobado\n**Seguridad:** n/a\n' > "$K33/requirements/REQ-850.md"
out33="$(bash "$LEC33" "$K33" 2>/dev/null)"; rc33=$?
if [ "$rc33" = "0" ] && printf '%s' "$out33" | grep -q '1 REQ leídos'; then
  echo "  PASS  REQ-007 CA-22 el informe lee la clave decorada igual que la puerta (1 REQ, 0 notas)"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-007 CA-22 el informe no leyo el REQ de clave decorada (rc=$rc33)"; FAIL=$((FAIL+1))
fi
rm -rf "$K33"
# El bloque derivado, con el MISMO documento: la tercera boca dice lo mismo que las otras dos.
printf '# REQ-851\n**Estado:** en-revisión\n**QA:** aprobado\n**Seguridad:** n/a\n' > "$P810/requirements/REQ-851.md"
rm -f "$P810/requirements/REQ-83"[012]".md"
printf '%s' "$(CLAUDE_PROJECT_DIR="$P810" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')" \
  | CLAUDE_PROJECT_DIR="$P810" bash "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>"$ERRLOG"
if grep -q '^| REQ-851 | en-revision | aprobado | n/a |' "$P810/docs/ESTADO.md" 2>/dev/null; then
  echo "  PASS  REQ-007 CA-22 el bloque derivado tambien lee la clave decorada"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-007 CA-22 el bloque derivado no leyo la clave decorada"; diag; FAIL=$((FAIL+1))
fi

# ---------- SEC-004 (CA-49/CA-50): el arnes juzga LA RUTA ESCRITA, no su destino ----------
printf '# REQ-860\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-860.md"
ln -sf "$PROJ/requirements/REQ-860.md" "$PROJ/docs/enlace.md"
check_motivo "SEC-004 CA-49 Edit sobre un enlace a un REQ -> deny (salida fail-closed)" \
  'ENLACE SIMBOLICO|ruta escrita, no su destino' guard-completado.sh \
  "$(emite_write "$PROJ/docs/enlace.md" "# REQ-860
Estado: completado
QA: pendiente
")"
ln -sf "$PROJ/src/a.ts" "$PROJ/docs/enlace-src.md"
check "SEC-004 CA-49 Write sobre un enlace a codigo protegido -> deny tambien en guard-codigo" deny \
  guard-codigo.sh "$(emite_write "$PROJ/docs/enlace-src.md" 'hola')"
# CA-50 (a): un archivo REGULAR fuera de los globs sigue permitido. La puerta no puede
# convertir en protegido lo que no lo es.
printf 'notas\n' > "$PROJ/docs/notas.md"
check "SEC-004 CA-50a un archivo REGULAR en docs/ sigue -> allow" allow \
  guard-codigo.sh "$(emite_write "$PROJ/docs/notas.md" 'hola')"
check "SEC-004 CA-50a ...y tambien para la puerta de cierre" allow \
  guard-completado.sh "$(emite_write "$PROJ/docs/notas.md" 'hola')"
# CA-50 (b): un enlace ROTO no puede matar al guardian — y un guardian muerto no deniega.
ln -sf "$PROJ/no-existe-jamas.md" "$PROJ/docs/enlace-roto.md"
# DEV 1.31.0 v3 (QA-111): este caso tambien decidia por reloj de pared (umbral 1000 ms)
# y era el decimo del banco que lo hacia. Lo que acredita —«ni cuelga ni revienta»— es
# discreto: que RESPONDA (no lo corte `timeout`) y que responda `deny`. El reloj se
# informa; no decide. Un enlace roto que colgara el guardian lo caza el `timeout`, que es
# el fallo real: un hook muerto no deniega.
mide_hook guard.sh "$(emite_write "$PROJ/docs/enlace-roto.md" 'hola')" 15
if [ "$CRONO_RC" -ne 124 ] && printf '%s' "$SALIDA_HOOK" | grep -q '"deny"'; then
  echo "  PASS  SEC-004 CA-50b enlace ROTO: responde deny (${CRONO_MS}ms), ni cuelga ni revienta"; PASS=$((PASS+1))
else
  echo "  FAIL  SEC-004 CA-50b enlace roto: rc=$CRONO_RC ${CRONO_MS}ms, salida=<${SALIDA_HOOK:0:80}>"; diag; FAIL=$((FAIL+1))
fi
# CA-50 (c) — DESVIACION DECLARADA. El criterio pide `allow` para un enlace que apunta
# FUERA del proyecto, porque esta escrito suponiendo la salida (a), la que RESUELVE el
# destino. La salida elegida es fail-closed SIN resolver, y sin resolver no se puede saber
# adonde apunta: el enlace esta DENTRO del proyecto y se deniega por lo que es, no por
# adonde va. Lo que si se conserva del criterio es que el arnes NO SE SALE DE LA RAIZ.
ln -sf /etc/hostname "$PROJ/docs/enlace-fuera.md"
check "SEC-004 CA-50c enlace que apunta FUERA -> deny, no allow" deny \
  guard-codigo.sh "$(emite_write "$PROJ/docs/enlace-fuera.md" 'hola')"
# ...y el control que sostiene la desviacion: un enlace que esta FUERA del proyecto no es
# asunto del arnes y no se juzga.
FUERA33="$(mktemp -d)"; printf 'x\n' > "$FUERA33/real.md"; ln -sf "$FUERA33/real.md" "$FUERA33/enlace.md"
check "SEC-004 CA-50c control: un enlace FUERA del proyecto no se juzga -> allow" allow \
  guard-codigo.sh "$(emite_write "$FUERA33/enlace.md" 'hola')"
rm -rf "$FUERA33"
# CA-50 (d): el camino comun de Bash no paga NADA por esto.
check "SEC-004 CA-50d el camino comun de Bash ('ls -la') sigue -> allow" allow \
  guard-codigo.sh "$(jq -n '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{command:"ls -la"}}')"
# ...y el agente de codigo TAMPOCO escribe a traves de un enlace: la puerta es sobre la
# FORMA de la escritura, no sobre quien la hace.
check "SEC-004 el desarrollador tampoco escribe a traves de un enlace -> deny" deny \
  guard-codigo.sh "$(jq -n --arg fp "$PROJ/docs/enlace-src.md" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,agent_id:"a1",agent_type:"desarrollador",tool_input:{file_path:$fp,content:"hola"}}')"

# ---------- SEC-006 parte (a) (CA-53): control obligatorio de la decision ----------
# La ampliacion de `codigo_app.globs` es MAPEO DE ESTE REPOSITORIO, no mecanismo: ninguna
# plantilla puede ganarla, o todos los proyectos que instalen el arnes la heredarian.
TPL33="$HOOKS_DIR/../templates/arnes-config.json.tpl"
if [ -f "$TPL33" ] && grep -Eq '\.arnes/config\.json|\.claude-plugin' "$TPL33"; then
  echo "  FAIL  REQ-007 CA-53 la plantilla arnes-config.json.tpl gano los globs de este repo"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-007 CA-53 la ampliacion NO se propaga a templates/arnes-config.json.tpl"; PASS=$((PASS+1))
fi
# Y el mecanismo que la hace valer: con esos globs declarados, la coordinadora no escribe
# el manifiesto y el agente de codigo si. Se mide sobre un proyecto efimero, no sobre este
# repositorio: el banco no puede depender del mapeo de quien lo corre.
M33="$RAIZ/m33-$BASHPID"; mkdir -p "$M33/.arnes" "$M33/.claude-plugin" "$M33/requirements"
jq '.codigo_app.globs = ["hooks/*",".arnes/config.json",".claude-plugin/*"]' <<< "$MANIFIESTO_BASE" > "$M33/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$M33/PENDING_APPROVAL.md"
CLAUDE_PROJECT_DIR="$M33" check "REQ-007 CA-53 la coordinadora NO escribe .arnes/config.json -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$M33" emite_write "$M33/.arnes/config.json" '{}')"
CLAUDE_PROJECT_DIR="$M33" check "REQ-007 CA-53 ...ni .claude-plugin/plugin.json -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$M33" emite_write "$M33/.claude-plugin/plugin.json" '{}')"
CLAUDE_PROJECT_DIR="$M33" check "REQ-007 CA-53 el desarrollador SI lo escribe -> allow" allow \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$M33" jq -n --arg fp "$M33/.arnes/config.json" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,agent_id:"a1",agent_type:"desarrollador",tool_input:{file_path:$fp,content:"{}"}}')"
# ---------- SEC-005 (CA-51/CA-52): un manifiesto ROTO no es un manifiesto AUSENTE ------
# Medido en la auditoria R-001: `arnes_parse_manifest` no miraba el codigo de salida de
# `arnes_jq_file`, y `arnes_jq_file` deja `ARNES_JQ` CON SU VALOR ANTERIOR cuando jq falla.
# El valor anterior era el analisis del INPUT: las variables del manifiesto se rellenaban
# con campos que controla quien llama (`ARNES_AGENTE_CODIGO` = `Bash`, el `tool_name`) y
# los globs quedaban vacios. Todo permitido, en silencio, con las invariantes declaradas.
R33="$RAIZ/r33-$BASHPID"; mkdir -p "$R33/.arnes" "$R33/requirements" "$R33/src" "$R33/docs"
printf '## Pendientes\n\n## Resueltas\n' > "$R33/PENDING_APPROVAL.md"
roto33() { printf '%s' "$1" > "$R33/.arnes/config.json"; }
# Las cuatro formas del criterio: invalido, vacio, `null` y un array. Las tres ultimas son
# JSON VALIDO, que es lo que las hacia peligrosas: jq las atravesaba sin fallar.
roto33 '{ "codigo_app": '
CLAUDE_PROJECT_DIR="$R33" check_motivo "REQ-007 CA-51 SEC-005 manifiesto INVALIDO: Write -> deny con motivo" \
  'no se puede leer|NO se puede leer' guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
roto33 ''
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-51 SEC-005 manifiesto VACIO -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
roto33 'null'
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-51 SEC-005 manifiesto 'null' (JSON valido) -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
roto33 '[1,2]'
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-51 SEC-005 manifiesto ARRAY (JSON valido) -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-51 SEC-005 ...y la puerta de cierre tampoco deja pasar" deny \
  guard-completado.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/requirements/REQ-870.md" 'Estado: completado')"
# El aviso de un manifiesto ilegible va por `arnes_warn`, o sea por STDERR, y NO por
# `systemMessage`. Se emite SIEMPRE QUE EL MANIFIESTO SE CONSULTA —tambien cuando la
# llamada se permite: aqui el comando escribe fuera de toda ruta protegida y aun asi hubo
# que leer el manifiesto para saberlo—. Se comprueba donde vive.
# DEV 1.31.0 v2 (QA-104): la sonda era `ls -la`, que NO escribe nada y por tanto ya no
# consulta el manifiesto; el aviso se sigue exigiendo, en la llamada que si lo consulta.
: > "$ERRLOG"
sal33="$(CLAUDE_PROJECT_DIR="$R33" jq -n '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{command:"cat notas.md"}}' \
  | CLAUDE_PROJECT_DIR="$R33" bash "$HOOKS_DIR/guard-codigo.sh" 2>"$ERRLOG")"
if [ ! -s "$ERRLOG" ] && ! printf '%s' "$sal33" | grep -q '"deny"'; then
  echo "  PASS  DEV 1.31.0 v2: QA-104 un comando que no escribe no consulta el manifiesto (ni avisa ni deniega)"; PASS=$((PASS+1))
else
  echo "  FAIL  DEV 1.31.0 v2: QA-104 un comando sin escrituras leyo el manifiesto o quedo denegado"; diag; FAIL=$((FAIL+1))
fi
: > "$ERRLOG"
# La llamada PERMITIDA con el manifiesto roto es la que lo repara (QA-105): se consulta el
# manifiesto, se avisa por stderr, y aun asi se deja pasar. Es la unica combinacion donde
# «avisa aunque permita» se puede observar, porque cualquier otra escritura se deniega.
sal33="$(CLAUDE_PROJECT_DIR="$R33" emite_bash 'printf "{}" > .arnes/config.json' "" "" \
  | CLAUDE_PROJECT_DIR="$R33" bash "$HOOKS_DIR/guard-codigo.sh" 2>"$ERRLOG")"
if grep -q 'no se puede leer' "$ERRLOG" && ! printf '%s' "$sal33" | grep -q '"deny"'; then
  echo "  PASS  REQ-007 CA-51 SEC-005 el aviso se emite siempre que el manifiesto se consulta (stderr), tambien cuando permite"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-007 CA-51 SEC-005 sin aviso en stderr, o la reparacion del manifiesto quedo denegada"; diag; FAIL=$((FAIL+1))
fi
# DEV 1.31.0 v2 (QA-105): CON EL MANIFIESTO ROTO, LA UNICA ESCRITURA QUE SE PERMITE ES LA
# DEL PROPIO MANIFIESTO. El motivo del deny recomienda «corrige el JSON», y desde que
# `.arnes/config.json` esta en `codigo_app.globs` esa salida estaba denegada para TODOS:
# el remedio que el mensaje ofrece tiene que existir por la via que el mensaje nombra.
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 manifiesto roto: Write al PROPIO manifiesto -> allow" allow \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/.arnes/config.json" '{}')"
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 ...tambien por Bash (la via que el motivo nombra)" allow \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_bash 'printf "{}" > .arnes/config.json' "" "")"
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 ...y la puerta de cierre tampoco lo estorba" allow \
  guard-completado.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/.arnes/config.json" '{}')"
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 control: cualquier OTRA ruta sigue denegada" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 control: reparar Y escribir otra cosa no es reparar -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_bash 'printf "{}" > .arnes/config.json; echo x > docs/x.md' "" "")"
# La excepcion es de UN ARCHIVO, no del modo degradado: no se extiende por vecindad.
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-105 control: otro archivo bajo .arnes/ NO repara nada -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/.arnes/migracion.md" 'hola')"
# El fail-closed de SEC-005 no se debilita por leer el manifiesto mas tarde: un comando de
# Bash que SI escribe lo consulta, no puede leerlo, y deniega igual que antes.
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-104 control: manifiesto roto + Bash que escribe -> deny (el fail-closed sigue)" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_bash 'echo x > src/a.ts' "" "")"
# Y el motivo nombra una salida ALCANZABLE: un remedio que el propio arnes deniega no es un
# remedio. Es la mitad de diagnostico del hallazgo QA-105.
CLAUDE_PROJECT_DIR="$R33" check_motivo "DEV 1.31.0 v2: QA-105 el motivo dice que la reparacion del manifiesto SI se puede" \
  "UNICA escritura permitida es la del propio" guard-codigo.sh \
  "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
# NINGUNA VARIABLE DEL MANIFIESTO SE RELLENA CON CAMPOS DEL INPUT. Es la mitad grave del
# hallazgo: no es solo que permitiera, es que el llamante escribia quien es el agente
# autorizado. Se mide leyendo las variables, no la decision.
fuga33="$(CLAUDE_PROJECT_DIR="$R33" bash -c '. "'"$HOOKS_DIR"'/lib.sh"
  ARNES_INPUT="$(jq -n "{tool_name:\"Bash\",agent_type:\"qa-tester\",tool_input:{file_path:\"/x\",command:\"c\"}}")"
  arnes_project_dir "$ARNES_INPUT"; ARNES_MANIFEST="'"$R33"'/.arnes/config.json"
  arnes_parse_input; arnes_parse_manifest 2>/dev/null
  printf "%s|%s|%s" "$ARNES_AGENTE_CODIGO" "$ARNES_REQ_DIR" "${#ARNES_GLOBS[@]}"')"
if [ "$fuga33" = "||0" ]; then
  echo "  PASS  REQ-007 CA-51 SEC-005 ninguna variable del manifiesto se rellena con el input"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-007 CA-51 SEC-005 fuga del input al manifiesto: <$fuga33> (esperado '||0')"; FAIL=$((FAIL+1))
fi
# CA-52: LOS CONTROLES QUE YA PASABAN NO CAMBIAN. Un fail-closed nuevo que rompa el modo
# inerte convertiria el arreglo en un estorbo para todo proyecto que no usa el arnes.
rm -f "$R33/.arnes/config.json"
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-52 control: manifiesto AUSENTE sigue INERTE -> allow" allow \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/src/a.ts" 'hola')"
printf '%s\n' "$MANIFIESTO_BASE" > "$R33/.arnes/config.json"
CLAUDE_PROJECT_DIR="$R33" check "REQ-007 CA-52 control: manifiesto VALIDO decide igual que siempre -> deny" deny \
  guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/src/a.ts" 'hola')"
CLAUDE_PROJECT_DIR="$R33" check_aviso "REQ-007 CA-52 control: un manifiesto VALIDO no emite NINGUN aviso" \
  no '' guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
# La clave OPCIONAL ausente sigue cayendo al defecto del codigo, sin denegar ni avisar:
# "no declarado" no puede confundirse con "ilegible".
CLAUDE_PROJECT_DIR="$R33" check_aviso "REQ-007 CA-52 control: 'limites' ausente cae al defecto sin avisar ni denegar" \
  no '' guard-codigo.sh "$(CLAUDE_PROJECT_DIR="$R33" jq -n '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{command:"cat src/a.ts"}}')"

# DEV 1.31.0 v2 (QA-106/QA-107): UNA SOLA REGLA PARA TODOS LOS TIPOS. Lo que no tiene el
# tipo que la clave espera cae al valor por defecto Y SE DICE, nombrando clave y valor. La
# asimetria era el hallazgo: `exigir_fecha: "true"` apagaba la puerta en silencio mientras
# el techo de Bash si avisaba ante el mismo error.
tipo33() {   # <nombre> <filtro jq sobre el manifiesto> <patron esperado en stderr|-> 
  local nombre="$1" filtro="$2" patron="$3" hay
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  jq "$filtro" "$R33/.arnes/config.json" > "$R33/.arnes/c.tmp" && mv "$R33/.arnes/c.tmp" "$R33/.arnes/config.json"
  : > "$ERRLOG"
  CLAUDE_PROJECT_DIR="$R33" bash "$HOOKS_DIR/guard-codigo.sh" >/dev/null 2>"$ERRLOG" \
    <<< "$(CLAUDE_PROJECT_DIR="$R33" emite_write "$R33/docs/x.md" 'hola')"
  if [ "$patron" = "-" ]; then
    if [ -s "$ERRLOG" ]; then echo "  FAIL  $nombre  aviso inesperado"; diag; FAIL=$((FAIL+1)); else echo "  PASS  $nombre"; PASS=$((PASS+1)); fi
    return 0
  fi
  if grep -qE "$patron" "$ERRLOG"; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  el aviso no casa /$patron/"; diag; FAIL=$((FAIL+1)); fi
}
tipo33 "DEV 1.31.0 v2: QA-106 'exigir_fecha' con la cadena \"true\" avisa y cae al defecto" \
  '.veredictos.exigir_fecha = "true"' "veredictos.exigir_fecha.*\"true\""
tipo33 "DEV 1.31.0 v2: QA-106 'exigir_fecha' con el numero 1 avisa igual" \
  '.veredictos.exigir_fecha = 1' 'veredictos.exigir_fecha.*1'
tipo33 "DEV 1.31.0 v2: QA-106 control: el booleano de verdad no avisa" \
  '.veredictos.exigir_fecha = true' '-'
tipo33 "DEV 1.31.0 v2: QA-107 'bash_max_analisis: 1e9' avisa en vez de caer callado" \
  '.limites.bash_max_analisis = 1e9' 'bash_max_analisis.*no es un entero positivo'
tipo33 "DEV 1.31.0 v2: QA-107 'bash_max_analisis: 1.5' avisa igual" \
  '.limites.bash_max_analisis = 1.5' 'bash_max_analisis.*no es un entero positivo'
tipo33 "DEV 1.31.0 v2: QA-107 control: un entero valido no avisa" \
  '.limites.bash_max_analisis = 131072' '-'
tipo33 "DEV 1.31.0 v2: QA-106 'git.activo' con cadena avisa y manda el defecto (encendida)" \
  '.git.activo = "false"' 'git.activo.*"false"'
tipo33 "DEV 1.31.0 v2: QA-106 'codigo_app.globs' que no es un array avisa" \
  '.codigo_app.globs = "src/**"' 'codigo_app.globs.*src'
# La puerta sigue decidiendo con el defecto, que es lo que hace segura la caida: `git.activo`
# con un tipo raro NO apaga guard-git.
tipo33 "DEV 1.31.0 v2: QA-106 control: el manifiesto ya reparado no avisa" \
  '.codigo_app.globs = ["src/**"] | .git = {} | del(.limites) | del(.veredictos)' '-'
CLAUDE_PROJECT_DIR="$R33" check "DEV 1.31.0 v2: QA-106 'git.activo' con cadena no apaga la puerta de git -> deny" deny \
  guard-git.sh "$(CLAUDE_PROJECT_DIR="$R33" emite_bash 'git clean -fd' "" "")"

# --- DEV 1.31.0 v2 (QA-104): EL COSTE DEL CAMINO COMUN, MEDIDO EN PROCESOS ---------
# El reloj no sirve para esto: en Linux un fork son milisegundos y en Windows entre 1,2 y
# 6 s, asi que el umbral de tiempo que aqui pasaria alli no diria nada. Lo que se fija es
# el NUMERO DE PROCESOS `jq`, que es la magnitud que cambia de plataforma. Se cuenta con un
# `jq` instrumentado primero en el PATH que registra su llamada y delega en el real.
JQ33="$(mktemp -d)"; CNT33="$JQ33/llamadas"
JQREAL="$(command -v jq)"
{ printf '#!/usr/bin/env bash\n'; printf 'echo x >> "%s"\n' "$CNT33"; printf 'exec "%s" "$@"\n' "$JQREAL"; } > "$JQ33/jq"
chmod +x "$JQ33/jq"
cuenta_jq33() {   # <comando de Bash> -> numero de procesos jq de UNA invocacion de guard.sh
  local entrada; entrada="$(CLAUDE_PROJECT_DIR="$R33" emite_bash "$1" "" "")"
  : > "$CNT33"
  printf '%s' "$entrada" | PATH="$JQ33:$PATH" CLAUDE_PROJECT_DIR="$R33" bash "$HOOKS_DIR/guard.sh" >/dev/null 2>/dev/null
  grep -c x "$CNT33" 2>/dev/null || echo 0
}
for par in "ls -la" "npm run build"; do
  n33="$(cuenta_jq33 "$par")"
  if [ "$n33" = "1" ]; then
    echo "  PASS  DEV 1.31.0 v2: QA-104 '$par' cuesta 1 proceso jq (como v1.30.3)"; PASS=$((PASS+1))
  else
    echo "  FAIL  DEV 1.31.0 v2: QA-104 '$par' cuesta $n33 procesos jq y v1.30.3 costaba 1"; FAIL=$((FAIL+1))
  fi
done
rm -rf "$JQ33"
}

# --- Despacho en paralelo -----------------------------------------------------
# El canario ya corrio en el padre, solo y antes que nada: si el hook esta muerto no
# se lanza ni una seccion.
activos=0
for i in $(seq 1 "$TOTAL_SECCIONES"); do
  (
    ERRLOG="$RAIZ/err-$i"        # propio: en paralelo, un stderr compartido miente
    "seccion_$(printf '%02d' "$i")"
  ) > "$RAIZ/out-$i" 2>&1 &
  # Contador propio, NO `jobs -pr` dentro de `$( )`: el job control no cruza el
  # subshell de la sustitucion y devolvia 1 con tres trabajos vivos, asi que el
  # limitador no limitaba nada y las 20 secciones salian a la vez.
  activos=$((activos+1))
  if [ "$activos" -ge "$JOBS" ]; then wait -n 2>/dev/null; activos=$((activos-1)); fi
done
wait

# La salida se concatena EN ORDEN: una suite cuyo informe cambia de forma segun el
# reparto de CPU es una suite que nadie compara con la vuelta anterior.
llegaron=0
for i in $(seq 1 "$TOTAL_SECCIONES"); do
  if [ -f "$RAIZ/out-$i" ]; then cat "$RAIZ/out-$i"; llegaron=$((llegaron+1)); fi
done

# --- Cuadre 1: ninguna seccion puede desaparecer en silencio ------------------
# Una seccion muerta produce CERO lineas, que es exactamente lo que produce una
# seccion que paso limpia. Sin este control, matarla y acertarla se ven igual.
if [ "$llegaron" -ne "$TOTAL_SECCIONES" ]; then
  echo "ABORT: llegaron $llegaron de $TOTAL_SECCIONES secciones. Alguna murio sin dejar salida."
  exit 1
fi

# --- El recuento sale DEL TEXTO, no de variables ------------------------------
# Los contadores del padre se quedaron a cero: cada seccion incremento los suyos en
# su propio proceso y se los llevo al morir.
PASS="$(grep -c '^  PASS ' "$RAIZ"/out-* 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')"
FAIL="$(grep -c '^  FAIL ' "$RAIZ"/out-* 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')"
SKIP="$(grep -c '^  SKIP ' "$RAIZ"/out-* 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')"

# --- Cuadre 2: el numero de casos es una invariante del banco -----------------
# Si alguien anade o quita un caso, actualiza CASOS_ESPERADOS. Cuesta una linea y
# convierte "faltan tres casos" en un fallo ruidoso en vez de un verde mas pequeno.
CASOS_ESPERADOS=625
# Con FILTRO la vuelta es parcial por definicion: el cuadre solo vale en la completa.
# (Sin esta guarda toda vuelta filtrada abortaba aqui, y el EXIT quedaba oculto tras un
# `| tail` en el que se lanzaba: otro control que certificaba lo que no medía.)
# PASS + FAIL + SKIP: un caso saltado por plataforma cuenta como caso, no como hueco.
if [ -z "$FILTRO" ] && [ $((PASS+FAIL+SKIP)) -ne "$CASOS_ESPERADOS" ]; then
  echo "ABORT: corrieron $((PASS+FAIL+SKIP)) casos (PASS $PASS · FAIL $FAIL · SKIP $SKIP) y se esperaban $CASOS_ESPERADOS."
  echo "       O falta un caso por el camino, o alguien anadio uno y no actualizo"
  echo "       CASOS_ESPERADOS. Las dos cosas hay que mirarlas."
  exit 1
fi

echo "-------------------------------------------"
if [ "${SKIP:-0}" -gt 0 ]; then echo "Resultado: $PASS PASS, $FAIL FAIL, $SKIP SKIP (casos de otra plataforma)"; else echo "Resultado: $PASS PASS, $FAIL FAIL"; fi
[ "$FAIL" -eq 0 ]
