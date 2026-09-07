#!/usr/bin/env bash
# Escenario de regresión de los hooks de enforcement del arnés (A1, A2, A3).
# Alimenta JSON de PreToolUse a los scripts reales y verifica deny/allow.
# No necesita Claude Code: prueba los scripts en aislamiento. Requiere jq.
#
# LECCIÓN GRABADA (2026-09-01): un caso verde que espera `allow` NO prueba nada por sí
# solo — también pasa cuando el hook ni siquiera llega a ejecutarse. Por eso este banco
# (a) arranca con un canario que exige un `deny` real antes de correr nada más, y
# (b) por cada arreglo añade su caso `deny`, no sólo el `allow` que lo acompaña.
#
# ESTRUCTURA (1.32.0): este archivo es el CORREDOR, no el banco. Los casos viven en
# `secciones/NN-<slug>.sh`, uno por sección, y el corredor los DESCUBRE con un glob:
# añadir o quitar una sección no toca ni una línea de aquí. Antes eran 4.096 líneas en
# un solo archivo, y eso obligaba a leerlo entero para tocar cuarenta y impedía que dos
# comisiones trabajaran a la vez. Aquí quedan: los ayudantes compartidos, el canario
# global, el despacho y los dos cuadres (por archivo y total). Ver README.md del banco.
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
# --- Argumentos: o un FILTRO de nombre de caso, o archivos de sección ----------
# `run.sh bash`                 -> filtro por nombre de caso (semántica de v1.31.0).
# `run.sh secciones/07-*.sh`    -> corrida parcial: sólo esas secciones, más el canario.
# Se distinguen por la FORMA: un argumento con `/` o terminado en `.sh` es un selector
# de archivos; cualquier otro es el filtro de siempre. Un selector que no casa con
# ningún archivo ABORTA en vez de degradar a filtro: una vuelta que corre cero casos y
# sale verde es exactamente el fallo en abierto que este banco existe para no tener.
FILTRO=""
SELECTORES=()
for arg in "$@"; do
  case "$arg" in
    */*|*.sh) SELECTORES+=("$arg") ;;
    *)        [ -n "$FILTRO" ] || FILTRO="$arg" ;;
  esac
done

# Dónde viven las secciones. `ARNES_SECCIONES_DIR` apunta a OTRO directorio: es como la
# autoprueba del corredor (`autoprueba-corredor.sh`) le da de comer secciones sintéticas
# —una que no declara su número, otra que muere a mitad— sin tocar el banco de verdad.
SEC_DIR="${ARNES_SECCIONES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/secciones" 2>/dev/null && pwd)}"

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
# QA 1.32.0 (H-10): CON SALTO DE LINEA FINAL GARANTIZADO, y no es cosmetica. `sed` copia
# el ultimo renglon tal cual: si `$ERRLOG` no termina en `\n`, la linea `  PASS ` del caso
# siguiente se pega detras, deja de empezar por `^  PASS ` y el `awk` del recuento no la
# ve — el cuadre por archivo aborta acusando a `CASOS_ESPERADOS_SECCION` y el culpable es
# un diagnostico sin `\n`. `awk` lee el ultimo renglon incompleto como un registro y su
# `print` siempre añade el separador, asi que el arreglo es el mismo fork de antes. Se
# arreglo en las secciones 34 y 35 (`head -c 300` -> `${salida:0:300}`) y faltaba aqui,
# que es donde vale para las 37 secciones a la vez.
diag() { [ -s "$ERRLOG" ] && awk '{ print "          stderr| " $0 }' "$ERRLOG"; return 0; }

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

# ver_check / lec_check — DEV 1.32.0 (REQ-014): SUBEN AQUI. Los dos juzgan la respuesta
# de un hook, así que son ayudantes de la invariante 1 igual que `check`, y desde que
# cada sección es un ARCHIVO su sitio no puede ser dentro de uno de ellos: un ayudante
# que juzga hooks tiene que estar disponible para cualquier sección que lo necesite.
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

LEC="$HOOKS_DIR/../tools/arnes-lectura.sh"
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


# --- Descubrimiento: un glob de bash, ni un solo proceso ----------------------
# Corre en CADA invocación del banco, y en Windows cada fork cuesta entre 1,2 y 6 s:
# `find`/`ls`/`sort` aquí serían tres procesos por vuelta a cambio de nada. El orden es
# el lexicográfico del glob, fijado con LC_ALL=C SÓLO durante la expansión: un banco
# cuyo orden depende del idioma del entorno convierte cualquier acoplamiento entre
# secciones en un fallo intermitente que sólo aparece en la máquina de otro.
if [ -z "$SEC_DIR" ] || [ ! -d "$SEC_DIR" ]; then
  echo "ABORT: no encuentro el directorio de secciones (ARNES_SECCIONES_DIR o ./secciones)."
  exit 1
fi
LC_ALL_PREVIO="${LC_ALL-__sin_definir__}"
LC_ALL=C
shopt -s nullglob
TODAS=( "$SEC_DIR"/[0-9][0-9]-*.sh )
shopt -u nullglob
if [ "$LC_ALL_PREVIO" = "__sin_definir__" ]; then unset LC_ALL; else LC_ALL="$LC_ALL_PREVIO"; fi

if [ "${#TODAS[@]}" -eq 0 ]; then
  echo "ABORT: no hay ningún archivo de sección en $SEC_DIR (patrón NN-<slug>.sh)."
  echo "       Un banco sin secciones sale verde sin haber medido nada."
  exit 1
fi

# --- Nada en `secciones/` se queda fuera EN SILENCIO ---------------------------
# QA 1.32.0 (H-04 y H-05), las dos mitades del mismo agujero de descubrimiento:
#   * un archivo que NO casa el patrón (`40-sin-extension`, `zz-huerfana.sh`) no lo
#     ejecuta nadie, y la vuelta salía verde sin mencionarlo. El respaldo es el cuadre
#     total, y en vuelta parcial el cuadre total está suspendido por diseño: ahí no
#     había red ninguna.
#   * una entrada que SÍ casa pero no es un archivo legible (un directorio llamado
#     `43-dir.sh`) mataba el corredor bajo `set -u` a mitad del cuadre, sin `ABORT:` y
#     sin línea `Resultado:` — fail-closed, pero indiagnosticable, que es justo lo que
#     esta estructura existe para ganar.
# Se comprueba ANTES de correr nada y con globs, sin un solo proceso. Los ocultos
# (`.algo`) quedan fuera a propósito: son temporales de editor, no secciones.
ARNES_HUERFANOS=''
shopt -s nullglob
for ARNES_ENTRADA in "$SEC_DIR"/*; do
  ARNES_NOMBRE="${ARNES_ENTRADA##*/}"
  case "$ARNES_NOMBRE" in
    [0-9][0-9]-*.sh)
      if [ ! -f "$ARNES_ENTRADA" ] || [ ! -r "$ARNES_ENTRADA" ]; then
        ARNES_HUERFANOS="$ARNES_HUERFANOS       $ARNES_NOMBRE: casa el patrón pero no es un archivo regular legible
"
      fi ;;
    *)
      ARNES_HUERFANOS="$ARNES_HUERFANOS       $ARNES_NOMBRE: no casa NN-<slug>.sh, así que el banco no lo ejecuta
" ;;
  esac
done
shopt -u nullglob
if [ -n "$ARNES_HUERFANOS" ]; then
  echo "ABORT: hay entradas en $SEC_DIR que esta vuelta NO iba a ejecutar:"
  printf '%s' "$ARNES_HUERFANOS"
  echo "       O se renombra a NN-<slug>.sh (y se declara su CASOS_ESPERADOS_SECCION),"
  echo "       o se saca de secciones/. Un archivo invisible para el descubrimiento es"
  echo "       un banco que sale verde sin haber corrido lo que alguien creyó escribir."
  exit 1
fi

# Sonda de descubrimiento: imprime lo descubierto y se va. Es la única forma de medir el
# ORDEN (dos veces, mismo resultado) y el COSTE (cero forks) sin el ruido de 683 casos.
if [ -n "${ARNES_SOLO_DESCUBRIR:-}" ]; then
  for f in "${TODAS[@]}"; do printf '%s\n' "${f##*/}"; done
  exit 0
fi

# --- Selección: qué secciones de las descubiertas entran en esta vuelta -------
SECCIONES=()
if [ "${#SELECTORES[@]}" -gt 0 ]; then
  # El orden lo manda el descubrimiento, no el orden en que se escribieron los argumentos.
  for f in "${TODAS[@]}"; do
    base="${f##*/}"
    for pat in "${SELECTORES[@]}"; do
      pat_base="${pat##*/}"
      if [ "$f" = "$pat" ] || [ "$base" = "$pat_base" ] || [[ $base == $pat_base ]] || [[ $f == $pat ]]; then
        SECCIONES+=("$f"); break
      fi
    done
  done
  for pat in "${SELECTORES[@]}"; do
    pat_base="${pat##*/}"; casado=no
    for f in "${SECCIONES[@]}"; do
      base="${f##*/}"
      if [ "$f" = "$pat" ] || [ "$base" = "$pat_base" ] || [[ $base == $pat_base ]] || [[ $f == $pat ]]; then casado=si; break; fi
    done
    if [ "$casado" = no ]; then
      echo "ABORT: ningún archivo de sección casa con '$pat'."
      exit 1
    fi
  done
else
  SECCIONES=( "${TODAS[@]}" )
fi
N_SEC="${#SECCIONES[@]}"
PARCIAL=no
[ "$N_SEC" -eq "${#TODAS[@]}" ] || PARCIAL=si
[ -z "${ARNES_SECCIONES_DIR:-}" ] || PARCIAL=si

# --- Invariante 1, comprobada sobre el texto: quien juzga un hook, se guarda ---
# Un ayudante propio de una sección que ejecute un hook y dicte PASS/FAIL sin guarda
# contra la salida vacía reintroduce el verde falso de 2026-09-01 dentro de un archivo
# que nadie más mira. Se comprueba antes de correr nada: una puerta que sólo avisa
# después de 683 casos llega tarde.
#
# QA 1.32.0 (H-03): SE MIRA LA CADENA DE LLAMADAS, NO EL CUERPO SUELTO. La versión
# anterior exigía que ejecutar el hook y dictar el veredicto ocurrieran en la MISMA
# función, y eso se evade partiendo el ayudante en dos —una que ejecuta, otra que
# juzga—, sin ocultar nada: QA lo midió y salió `1 PASS, 0 FAIL`, rc 0, con un caso de
# entrada vacía en verde. Un control que se rodea escribiendo dos funciones en vez de
# una no es un control. Ahora la propiedad «ejecuta un hook» y la propiedad «tiene
# guarda» se PROPAGAN por las llamadas dentro del archivo hasta punto fijo, así que da
# igual en cuántos trozos se parta: quien dicta PASS/FAIL sobre una cadena que ejecuta
# un hook, lleva la guarda en algún eslabón de esa cadena.
GUARDA_ESTRUCTURA="$(awk '
  function cierra() {
    if (fn == "") return
    cuerpoDe[fn] = cuerpo; orden[++nfn] = fn
    fn = ""; cuerpo = ""
  }
  # Al terminar cada archivo se resuelve ese archivo y se olvida: los ayudantes de una
  # sección no cruzan a otra (cada una corre en su propio subshell), así que mezclarlos
  # aquí inventaría llamadas que en la vuelta real no existen.
  function resuelve(   i, j, f, g, txt, cambio) {
    cierra()
    for (i = 1; i <= nfn; i++) {
      f = orden[i]; txt = cuerpoDe[f]
      eje[f] = ((txt ~ /\$HOOKS_DIR\//) || (txt ~ /"\$LEC"/))
      ver[f] = (txt ~ /  (PASS|FAIL)  /)
      # QA 1.32.0 (H-11): «GUARDA EQUIVALENTE» ES UNA PROPIEDAD, NO TRES LITERALES. Esto
      # era `json_no_vacio || -z "$out" || -z "$SALIDA`: una guarda idéntica escrita con
      # la variable llamada `o` en vez de `out` producía ABORT sobre código CORRECTO, que
      # es un falso positivo — y un control que grita sobre lo bueno es un control que
      # alguien acaba quitando. La propiedad: `json_no_vacio`, o una comprobación de
      # vacío (`-z`/`-n`) sobre una variable LOCAL, que en este banco son las que empiezan
      # en minúscula. La distinción de mayúsculas no es estilo: `[ -n "$FILTRO" ]` abre 31
      # ayudantes de sección y NO es una guarda —es el filtro de nombre de caso—, así que
      # admitir cualquier variable dejaría el control abierto de par en par mientras
      # aparenta seguir cerrado. Documentado en el README del banco.
      gua[f] = (txt ~ /json_no_vacio/ || txt ~ /-[zn] +"?\$[{]?[a-z_]/)
    }
    do {
      cambio = 0
      for (i = 1; i <= nfn; i++) {
        f = orden[i]
        for (j = 1; j <= nfn; j++) {
          g = orden[j]
          if (f == g) continue
          if (cuerpoDe[f] !~ ("(^|[^A-Za-z_0-9])" g "([^A-Za-z_0-9]|$)")) continue
          if (eje[g] && !eje[f]) { eje[f] = 1; cambio = 1 }
          if (gua[g] && !gua[f]) { gua[f] = 1; cambio = 1 }
        }
      }
    } while (cambio)
    for (i = 1; i <= nfn; i++) {
      f = orden[i]
      if (eje[f] && ver[f] && !gua[f])
        printf "%s: la funcion %s() ejecuta un hook y dicta veredicto sin guarda de salida vacia\n", archivo, f
    }
    nfn = 0; split("", orden); split("", cuerpoDe); split("", eje); split("", ver); split("", gua)
  }
  FNR == 1 && NR > 1 { resuelve() }
  FNR == 1 { archivo = FILENAME }
  /^[A-Za-z_][A-Za-z_0-9]*\(\)[ \t]*\{/ { cierra(); fn = $0; sub(/\(\).*/, "", fn); cuerpo = $0; if ($0 ~ /\}[ \t]*$/) cierra(); next }
  fn != "" { cuerpo = cuerpo "\n" $0; if ($0 ~ /^\}/) cierra(); next }
  END { resuelve() }
' "${SECCIONES[@]}")"
if [ -n "$GUARDA_ESTRUCTURA" ]; then
  echo "ABORT: invariante 1 rota en un archivo de sección (ver README del banco):"
  printf '%s\n' "$GUARDA_ESTRUCTURA" | sed 's/^/       /'
  exit 1
fi

# --- Despacho en paralelo -----------------------------------------------------
# El canario ya corrió en el padre, solo y antes que nada: si el hook está muerto no se
# lanza ni una sección, y tampoco se descubre ninguna.
#
# Cada sección va en SU PROPIO SUBSHELL, con `set --` para que no herede los argumentos
# del corredor (dentro de la sección `$1` no existía cuando era una función, y no puede
# empezar a existir ahora valiendo el filtro). Al terminar el archivo entero se escribe
# `fin-N`: ese archivo es la prueba de que la sección llegó al final. Una sección cuyo
# subshell muere a mitad no lo deja, y eso es lo que la distingue de una sección que
# pasó limpia — las dos producen, si no, exactamente las mismas cero líneas.
#
# MEDIDO al partir el banco (2026-09-06): el índice del bucle NO puede llamarse `i`. Seis
# secciones usan `i` como contador de un `for` suyo, y cuando la sección era una función
# eso daba igual —el despachador ya no volvía a mirar `$i`—, pero ahora el subshell tiene
# que escribir su marca DESPUÉS de la sección: con `$i` clobbereado, seis secciones
# escribían la marca de otra y el corredor las declaraba muertas. Los nombres del corredor
# que sobreviven al `source` llevan prefijo `ARNES_`.
activos=0
for ((sec_i = 0; sec_i < N_SEC; sec_i++)); do
  {
    (
      set --
      ERRLOG="$RAIZ/err-$sec_i"    # propio: en paralelo, un stderr compartido miente
      ARNES_MARCA_FIN="$RAIZ/fin-$sec_i"
      source "${SECCIONES[sec_i]}"
      ARNES_RC_SEC=$?
      # CA-06 de REQ-017: NADA DE UNA SECCION SOBREVIVE A SU SECCION. Medido en 1.32.1:
      # una sonda de QA —un envoltorio de `grep` que, construido con `command -v` sobre un
      # binario sombreado por una funcion de shell, se llamaba a si mismo— vivio 3 h 41 min
      # comiendose un nucleo, y falseo la linea base de OTRA medicion, que concluyo «dentro
      # del ruido» con toda logica interna. El instrumento mentia, y nadie relaciono las dos
      # cosas. Se anota QUE quedo vivo (para que el cuadre pueda acusar a esta seccion por
      # su nombre) y se mata: un banco que deja procesos detras envenena la vuelta siguiente.
      # `jobs -pr` es builtin y se redirige a un archivo: dentro de `$( )` el job control no
      # cruza el subshell de la sustitucion y devuelve vacio con trabajos vivos.
      jobs -pr > "$RAIZ/vivos-$sec_i" 2>/dev/null || :
      while IFS= read -r ARNES_PID_VIVO; do
        [ -n "$ARNES_PID_VIVO" ] || continue
        kill -9 "$ARNES_PID_VIVO" 2>/dev/null || :
      done < "$RAIZ/vivos-$sec_i"
      printf '%s\n' "$ARNES_RC_SEC" > "$ARNES_MARCA_FIN"
      exit "$ARNES_RC_SEC"
    ) > "$RAIZ/out-$sec_i" 2>&1
    printf '%s\n' "$?" > "$RAIZ/rc-$sec_i"
  } &
  # Contador propio, NO `jobs -pr` dentro de `$( )`: el job control no cruza el
  # subshell de la sustitución y devolvía 1 con tres trabajos vivos, así que el
  # limitador no limitaba nada y las secciones salían todas a la vez.
  activos=$((activos + 1))
  if [ "$activos" -ge "$JOBS" ]; then wait -n 2>/dev/null; activos=$((activos - 1)); fi
done
wait

# La salida se concatena EN ORDEN: una suite cuyo informe cambia de forma según el
# reparto de CPU es una suite que nadie compara con la vuelta anterior.
for ((i = 0; i < N_SEC; i++)); do
  [ -f "$RAIZ/out-$i" ] && cat "$RAIZ/out-$i"
done

# --- El recuento sale DEL TEXTO, no de variables, y AHORA POR ARCHIVO ---------
# Los contadores del padre se quedaron a cero: cada sección incrementó los suyos en su
# propio proceso y se los llevó al morir. Una sola pasada de awk reparte el recuento por
# archivo, que es lo que convierte «faltan tres casos» en «faltan tres casos EN ESTE».
NPASS=(); NFAIL=(); NSKIP=()
for ((i = 0; i < N_SEC; i++)); do NPASS[i]=0; NFAIL[i]=0; NSKIP[i]=0; done
SALIDAS=()
for ((i = 0; i < N_SEC; i++)); do [ -f "$RAIZ/out-$i" ] && SALIDAS+=("$RAIZ/out-$i"); done
if [ "${#SALIDAS[@]}" -gt 0 ]; then
  while read -r idx np nf ns; do
    NPASS[idx]="$np"; NFAIL[idx]="$nf"; NSKIP[idx]="$ns"
  done < <(awk '
      { n = FILENAME; sub(/^.*\/out-/, "", n); visto[n] = 1 }
      /^  PASS / { p[n]++ }
      /^  FAIL / { f[n]++ }
      /^  SKIP / { s[n]++ }
      END { for (k in visto) printf "%s %d %d %d\n", k, p[k], f[k], s[k] }
    ' "${SALIDAS[@]}")
fi

# CASOS_ESPERADOS_SECCION se lee del TEXTO del archivo, no de la corrida: una sección
# que muere antes de declararlo no puede además decidir contra qué se la compara.
CASOS_DECLARADOS=''
lee_casos_declarados() {   # <archivo> -> deja CASOS_DECLARADOS, 1 si no lo declara
  local linea=""   # inicializada: con `set -u`, un `read` que falla dejaba `linea` sin definir y mataba el bucle del cuadre entero (QA 1.32.0 H-05)
  CASOS_DECLARADOS=''
  while IFS= read -r linea || [ -n "$linea" ]; do
    case "$linea" in
      CASOS_ESPERADOS_SECCION=[0-9]*)
        linea="${linea#CASOS_ESPERADOS_SECCION=}"
        CASOS_DECLARADOS="${linea%%[!0-9]*}"
        return 0 ;;
    esac
  done < "$1"
  return 1
}

# --- Cuadre 1: ninguna sección puede morir ni desaparecer en silencio ---------
PASS=0; FAIL=0; SKIP=0; PROBLEMAS=0
for ((i = 0; i < N_SEC; i++)); do
  archivo="${SECCIONES[i]}"; base="${archivo##*/}"
  if [ ! -f "$RAIZ/out-$i" ]; then
    echo "ABORT: la sección $base no dejó ni una línea de salida: murió sin decir nada."
    PROBLEMAS=$((PROBLEMAS + 1)); continue
  fi
  if [ ! -f "$RAIZ/fin-$i" ]; then
    rc_sec='?'
    [ -f "$RAIZ/rc-$i" ] && read -r rc_sec < "$RAIZ/rc-$i"
    echo "ABORT: la sección $base murió a mitad (código de salida $rc_sec) y no llegó al final del archivo."
    echo "       No se cuenta como sección de cero casos: una sección muerta y una limpia"
    echo "       producen las mismas cero líneas, y sólo esto las distingue."
    PROBLEMAS=$((PROBLEMAS + 1)); continue
  fi
  # CA-06 de REQ-017, la mitad del corredor: una sección que deja un proceso vivo no es
  # una sección que pasó, es una sección que va a falsear el reloj de la siguiente. Se
  # dice CON EL NOMBRE del archivo — un núcleo comido por un huérfano anónimo es lo que
  # costó 3 h 41 min de diagnóstico en 1.32.1.
  if [ -s "$RAIZ/vivos-$i" ]; then
    pids_vivos=''
    while IFS= read -r pid_vivo; do
      [ -n "$pid_vivo" ] || continue
      pids_vivos="$pids_vivos $pid_vivo"
    done < "$RAIZ/vivos-$i"
    echo "ABORT: la sección $base terminó dejando procesos vivos (PID$pids_vivos); el banco los mató."
    echo "       Una sonda que sobrevive a su sección se come un núcleo y envenena el reloj"
    echo "       de la siguiente, que concluirá 'dentro del ruido' con toda lógica interna."
    PROBLEMAS=$((PROBLEMAS + 1))
  fi
  PASS=$((PASS + NPASS[i])); FAIL=$((FAIL + NFAIL[i])); SKIP=$((SKIP + NSKIP[i]))
  if ! lee_casos_declarados "$archivo"; then
    echo "ABORT: la sección $base no declara CASOS_ESPERADOS_SECCION."
    echo "       Sin su número, el cuadre por archivo no puede decir si perdió casos."
    PROBLEMAS=$((PROBLEMAS + 1)); continue
  fi
  # Con FILTRO la vuelta es parcial DENTRO de cada sección: el cuadre por archivo sólo
  # vale cuando la sección corre entera.
  if [ -z "$FILTRO" ]; then
    ejecutados=$((NPASS[i] + NFAIL[i] + NSKIP[i]))
    if [ "$ejecutados" -ne "$CASOS_DECLARADOS" ]; then
      echo "ABORT: la sección $base declara $CASOS_DECLARADOS casos y ejecutó $ejecutados" \
           "(PASS ${NPASS[i]} · FAIL ${NFAIL[i]} · SKIP ${NSKIP[i]})."
      echo "       O falta un caso por el camino, o alguien añadió uno y no actualizó"
      echo "       CASOS_ESPERADOS_SECCION en ese archivo. Las dos cosas hay que mirarlas."
      PROBLEMAS=$((PROBLEMAS + 1))
    fi
  fi
done

# --- Cuadre 2: el número total de casos sigue siendo una invariante del banco -
# Si alguien añade o quita un caso, actualiza el número de SU archivo y este total.
CASOS_ESPERADOS=847
# Con FILTRO o con una corrida parcial el total no puede cuadrar por definición: se
# suspende DICIÉNDOLO. Un cuadre que aborta en falso se acaba comentando, y un cuadre
# que se salta en silencio es el que dejó pasar una sección entera sin ejecutar.
if [ -n "$FILTRO" ] || [ "$PARCIAL" = si ]; then
  echo "aviso: vuelta parcial ($N_SEC de ${#TODAS[@]} secciones${FILTRO:+, filtro '$FILTRO'}):" \
       "el cuadre TOTAL queda suspendido; el de cada sección sigue exigiéndose."
elif [ $((PASS + FAIL + SKIP)) -ne "$CASOS_ESPERADOS" ]; then
  echo "ABORT: corrieron $((PASS + FAIL + SKIP)) casos (PASS $PASS · FAIL $FAIL · SKIP $SKIP) y se esperaban $CASOS_ESPERADOS."
  echo "       El cuadre por archivo de arriba dice en cuál; si no dijo nada, el que no"
  echo "       cuadra es el total y alguien cambió un CASOS_ESPERADOS_SECCION sin cambiar éste."
  PROBLEMAS=$((PROBLEMAS + 1))
fi

echo "-------------------------------------------"
if [ "${SKIP:-0}" -gt 0 ]; then echo "Resultado: $PASS PASS, $FAIL FAIL, $SKIP SKIP (casos de otra plataforma)"; else echo "Resultado: $PASS PASS, $FAIL FAIL"; fi
[ "$FAIL" -eq 0 ] && [ "$PROBLEMAS" -eq 0 ]
