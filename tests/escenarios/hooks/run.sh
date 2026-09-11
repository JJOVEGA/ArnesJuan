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

# --- LOS INSTRUMENTOS COMPARTIDOS DE `tests/util/` (REQ-021) -------------------
# LA SONDA MIDE, EL CORREDOR JUZGA. Las sondas son PROGRAMAS que se invocan (no ayudantes
# sourceados, así que la invariante 3 del README sigue intacta) y publican un registro de
# una línea `clave=valor`. Aquí abajo vive TODO lo que juzga: el ÚNICO parser del registro,
# la expectativa de la calibración —factor esperado y banda— y el veredicto de CA-10.
#
# POR QUÉ LA EXPECTATIVA VIVE AQUÍ Y NO EN LA SONDA (SEC-036, REQ-021 CA-03 punto 2). El
# sustituto de no proteger `tests/util/` bajo `codigo_app.globs` es «una sonda alterada no
# da verde», y eso sólo es cierto si la expectativa NO se puede alterar en el mismo
# movimiento que la sonda. Con la banda dentro del archivo cuestionado —y siendo operativa,
# o sea legítimamente editable— ensancharla es UNA LÍNEA EN LA MISMA EDICIÓN: la
# calibración se autocertifica. Aquí, alterar el instrumento y alterar su examen son dos
# ediciones en dos archivos, y la segunda cae en `run.sh`.
case "${BASH_SOURCE[0]}" in */*) UTIL_DIR="${BASH_SOURCE[0]%/*}/../../util" ;; *) UTIL_DIR="../../util" ;; esac
UTIL_DIR="${ARNES_UTIL_DIR:-$UTIL_DIR}"

# El identificador de CORRIDA ata la calibración con las mediciones que habilita (CA-03
# punto 5). Sin él, «una vez por corrida» sería la puerta por la que se reutiliza la
# calibración de ayer, que es acreditación de fail-before otra vez.
export ARNES_CORRIDA="corrida-$$-${EPOCHSECONDS:-0}"
# El árbol medido, leído SIN gastar un proceso: en Windows cada fork cuesta 1,2–6 s.
ARNES_ARBOL=desconocido
ARNES_REPO_GIT="${BASH_SOURCE[0]%/*}/../../.."
if [ -r "$ARNES_REPO_GIT/.git/HEAD" ]; then
  ARNES_REF_HEAD=''
  read -r ARNES_REF_HEAD < "$ARNES_REPO_GIT/.git/HEAD" 2>/dev/null || :
  case "$ARNES_REF_HEAD" in
    "ref: "*) ARNES_REF_HEAD="${ARNES_REF_HEAD#ref: }"
              [ -r "$ARNES_REPO_GIT/.git/$ARNES_REF_HEAD" ] &&
                { read -r ARNES_ARBOL < "$ARNES_REPO_GIT/.git/$ARNES_REF_HEAD" 2>/dev/null || ARNES_ARBOL=desconocido; } ;;
    ?*)       ARNES_ARBOL="$ARNES_REF_HEAD" ;;
  esac
fi
[ -n "$ARNES_ARBOL" ] || ARNES_ARBOL=desconocido
export ARNES_ARBOL

# sonda_lee <registro> — EL ÚNICO PARSER (CA-01 punto 4). `tests/util/README.md` apunta
# aquí y NO lo transcribe: dos transcripciones de la misma regla se desfasan.
# CADA CAMPO NUMÉRICO SE VALIDA POR SEPARADO y un campo obligatorio AUSENTE es un error con
# motivo, NUNCA un cero (CA-01 punto 5). Concatenar campos antes de la guarda —`"$rc$ut"`—
# hace desaparecer un valor vacío dentro de los dígitos del vecino, y escribir la clase como
# `*[!0-9|]*` dentro de un `case` no dispara nunca, porque ahí `|` es el separador de
# alternativas (comprobado en bash 5.3).
declare -A SONDA=()
SONDA_MOTIVO=''
sonda_num() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# sonda_es_util <instrumento> — QUIÉN es un instrumento de `tests/util/`, y ésta es su sede
# única. Decide qué campos son obligatorios: el materializador de línea base vive INLINE en
# las secciones 37 (REQ-021 CA-05, tras la reducción de alcance del 2026-09-08) y HEREDA el
# formato y este parser, pero NO hereda CA-04, así que no puede observar `vivos` y no lo
# declara. Exigirle un campo que no puede observar no es rigor: es un FAIL garantizado, que
# es la forma de criterio insatisfacible que este REQ ya ha pagado dos veces. Por eso el
# campo se enuncia sobre EL EMISOR y no sobre el formato (CA-10 punto 2).
sonda_es_util() { case "${1:-}" in reloj|procesos) return 0 ;; *) return 1 ;; esac; }
# …y QUIÉNES son los emisores que este juez sabe juzgar. Los de `tests/util/` más el
# materializador INLINE de CA-05. Un emisor que no esté aquí es un registro que nadie ha
# declarado, y eso es FAIL: fail-closed, porque no hay forma de saber qué gates le aplican.
sonda_emisor_conocido() { case "${1:-}" in reloj|procesos|linea-base) return 0 ;; *) return 1 ;; esac; }

sonda_lee() {
  local reg="${1:-}" resto par clave valor vistas=' '
  SONDA=(); SONDA_MOTIVO=''
  if [ -z "$reg" ]; then SONDA_MOTIVO='el registro salió VACÍO: la sonda no se ejecutó'; return 1; fi
  case "$reg" in *'='*) ;; *) SONDA_MOTIVO="el registro no tiene ningún campo clave=valor (<${reg:0:80}>)"; return 1 ;; esac
  # SIN `for par in $reg`, Y NO ES ESTILO (QA-021-04): esa forma parte por espacios —así que
  # un valor con un espacio deja de ser un valor y sus palabras con `=` se vuelven CAMPOS— y
  # además hace EXPANSIÓN DE NOMBRES DE ARCHIVO sobre lo que resulta, de modo que el
  # significado de un registro dependía del contenido del directorio de trabajo (comprobado
  # con un archivo llamado `estado=ok` en el `cwd`: el juez leía `estado=<ok>` y dejaba pasar
  # como medición una sonda que no había podido medir). Se recorre con expansión de
  # parámetros: no hay split, no hay glob y no cuesta un proceso.
  resto="$reg"
  while [ -n "$resto" ]; do
    par="${resto%% *}"
    if [ "$par" = "$resto" ]; then resto=''; else resto="${resto#* }"; fi
    [ -n "$par" ] || continue
    case "$par" in *'='*) ;; *) continue ;; esac
    clave="${par%%=*}"; valor="${par#*=}"
    [ -n "$clave" ] || continue
    # CLAVE REPETIDA = registro AMBIGUO = ILEGIBLE (QA-021-04). Dejar ganar a la ÚLTIMA
    # aparición es lo que convertía un `estado=sin-linea-base` en `estado=ok` en cuanto un
    # valor traía un espacio. Ni CA-01 punto 5 («ausente es un error, nunca un cero») ni
    # CA-10 («vacío o ilegible es FAIL») cubrían el registro AMBIGUO — y un registro
    # ambiguo no es un registro: son dos, y elegir uno es adivinar.
    case "$vistas" in *" $clave "*) SONDA_MOTIVO="el registro trae la clave '$clave' REPETIDA: es ambiguo, y un registro ambiguo no es legible"; return 1 ;; esac
    vistas="$vistas$clave "
    SONDA[$clave]="$valor"
  done
  # Los campos que TODO registro trae. Ausente no es cero: es un error con motivo.
  for clave in sonda modo estado corrida invocacion us procesos; do
    if [ -z "${SONDA[$clave]:-}" ]; then SONDA_MOTIVO="al registro le falta el campo obligatorio '$clave'"; return 1; fi
  done
  # …y los que además tienen que ser números, UNO A UNO.
  if ! sonda_num "${SONDA[us]}"; then SONDA_MOTIVO="el campo 'us' no es un número (<${SONDA[us]}>)"; return 1; fi
  # `procesos` es un número O EXACTAMENTE `no-aplica`, que NO es un cero (QA-021-07): el
  # reloj no puede contar procesos sin instrumentar, y una muestra mixta no es publicable
  # (CA-02 punto 5). Un cero publicado ahí era la mitad en procesos de CA-08 (iii)
  # calculándose como 0/0 y saliendo `0,000×` — PASA en vacío.
  case "${SONDA[procesos]}" in
    no-aplica) ;;
    *) if ! sonda_num "${SONDA[procesos]}"; then SONDA_MOTIVO="el campo 'procesos' no es un número ni 'no-aplica' (<${SONDA[procesos]}>)"; return 1; fi ;;
  esac
  # `vivos` es obligatorio SÓLO en el registro de un instrumento de `tests/util/`
  # (CA-10 punto 2): ausente ahí es ilegible → FAIL, nunca un cero.
  if sonda_es_util "${SONDA[sonda]}"; then
    if [ -z "${SONDA[vivos]:-}" ]; then SONDA_MOTIVO="al registro de '${SONDA[sonda]}' le falta 'vivos', y es un instrumento de tests/util/: un cero publicado y un campo ausente no son lo mismo"; return 1; fi
    if ! sonda_num "${SONDA[vivos]}"; then SONDA_MOTIVO="el campo 'vivos' no es un número (<${SONDA[vivos]}>)"; return 1; fi
  fi
  return 0
}

# sonda_banda <instrumento> — LA EXPECTATIVA DE LA CALIBRACIÓN, y ésta es su sede única
# (CA-03 punto 2). Cuatro milésimas: mínimo y máximo del factor SENSIBLE (esperado 2,000) y
# del INSENSIBLE (esperado 1,000). OPERATIVA: se ESTRECHA con la medición; ensancharla para
# acomodar un sujeto cuyo factor DERIVA no es conforme — lo que se cambia es el sujeto.
# Medido el 2026-09-07 (bash 5.3.9, linux, máquina CON carga ajena, 8 corridas): reloj
# 1,663–2,080 y 0,779–1,054 —el sujeto es un bucle aritmético puro, REALMENTE lineal, y lo
# que se ve es ruido de planificación, no deriva del sujeto—; `procesos` y `linea-base`,
# EXACTOS (2,000 y 1,000) en todas. La banda del reloj se declara sobre eso y se ESTRECHA
# cuando haya medición en máquina en reposo, que es donde el corredor la toma de verdad
# (antes del despacho en paralelo).
sonda_banda() {
  case "${1:-}" in
    reloj)      printf '%s' '1600 2400 800 1200' ;;
    procesos)   printf '%s' '1900 2100 900 1100' ;;
    *)          return 1 ;;
  esac
}

# --- LA MITAD DISCORDANTE DE CA-03 (a.2), Y SU TESTIGO -------------------------
# LA PROCEDENCIA DEL FACTOR NO SE LEE EN EL REGISTRO: la sonda honesta y la tautológica
# publican EL MISMO NÚMERO. Medido (QA-021-01): el factor de `sonda-linea-base.sh` se
# calculaba sobre el propio parámetro, así que `2N/N = 2000` salía POR ARITMÉTICA, y una
# copia que no materializaba, no verificaba y no comprobaba el bit de ejecución publicó
# `cal_a=2000 cal_b=1000` y EL JUEZ REAL DIJO PASS. La identidad de camino no protege de
# esto: la mutación borra el camino entero y el factor no se mueve.
# Por eso la calibración ejerce además una entrada cuya MAGNITUD OBSERVADA es distinta del
# parámetro, y el juez contrasta esa magnitud contra UN TESTIGO QUE ÉL MISMO OBTIENE.
#
# Y ESO NO BASTABA, MEDIDO (QA-021-10). Hasta el 2026-09-08 este juez «obtenía» el testigo de
# `procesos` CONTANDO las líneas de un archivo de rastro que él creaba vacío y que la SONDA
# rellenaba, y el de `reloj` cronometrando un sujeto cuyo tamaño LEÍA del registro de la
# sonda. Los dos salían, por dos cuentas distintas, del MISMO parámetro: `3 = 3` se cumple
# por construcción, así que una copia que no invocaba `grep` ni una vez y calculaba las cinco
# magnitudes por aritmética obtuvo PASS de este juez sin tocarlo. *Crear el recipiente no es
# obtener el testigo: el testigo es el VALOR.* Y dos canales de salida de la misma sonda no
# son dos caminos.
# Lo que lo cierra son las CINCO CONDICIONES de CA-03 (a.3), cada una con su ABORTO nombrado
# —y la (3) es la que convierte «independiente» en algo que se COMPRUEBA en vez de razonarse:
#   1. NO VACUIDAD    · el testigo no coincide con el parámetro.
#   2. VALOR DEL JUEZ  · lo produce él, no un artefacto que la sonda pueda escribir.
#   3. ANTERIORIDAD    · lo tiene ANTES de invocar la sonda. Se mide con dos marcas de reloj
#                        del propio juez, cuesta CERO procesos y es sólo un cambio de orden.
#   4. TAMAÑO DEL JUEZ · el sujeto discordante lo fija él y la sonda NO lo declara: un
#                        `disc_veces=`/`disc_vueltas=` en el registro ABORTA el caso.
#   5. LA VARA NO ES DEL JUZGADO · el umbral no se lee del registro del instrumento juzgado.
# El aborto se materializa como FAIL nombrado y no como el `ABORT:` del corredor: un guardián
# que tumba la vuelta entera por una condición de vacuidad es la lección de CA-07 punto 4, y
# un FAIL ya es «no PASA» y se ve.
# La banda del reloj es GENEROSA a propósito: lo que discrimina es el orden de magnitud
# entre lo observado y el parámetro, no la precisión del cronómetro del juez. OPERATIVA: se
# estrecha con la medición.
#
# EL SUELO, AQUÍ, POR LA CONDICIÓN 5. Antes se leía `suelo=` del registro del reloj, así que
# una sonda que publicara un suelo generoso se compraba su propia abstención. Su sede
# DOCUMENTAL sigue siendo `requirements/README.md` § «Cómo se escribe un criterio que no se
# desmiente» (50 ms) y leerla desde el juez no es una segunda sede: es un lector más de la
# misma, igual que la constante de la sonda.
SONDA_SUELO_US=50000

# Un TESTIGO es una TERNA: «<valor> <µs en que el juez lo obtuvo> <µs en que invocó la sonda>».
# Las dos marcas son lo que hace COMPROBABLE la anterioridad; sin ellas el caso aborta, que es
# lo correcto: un juez que no sabe cuándo obtuvo su testigo no puede afirmar que lo tenía antes.
SONDA_T_VALOR=''; SONDA_T_ANTES=''; SONDA_T_INVOCA=''
sonda_terna_parte() {   # <terna> -> SONDA_T_VALOR / SONDA_T_ANTES / SONDA_T_INVOCA
  local t="${1-}"
  SONDA_T_VALOR=''; SONDA_T_ANTES=''; SONDA_T_INVOCA=''
  case "$t" in
    *' '*' '*) ;;
    *) return 0 ;;   # sin las dos marcas no hay terna, y una terna a medias no se completa
  esac
  SONDA_T_VALOR="${t%% *}";  t="${t#* }"
  SONDA_T_ANTES="${t%% *}";  t="${t#* }"
  SONDA_T_INVOCA="${t%% *}"
}

SONDA_DISC_VEREDICTO=''
SONDA_DISC_MOTIVO=''
sonda_discordante() {   # <instrumento> <registro de calibración> <terna del testigo>
  local inst="${1:-}" reg="${2:-}" terna="${3-}" p o r testigo clave declarado=''
  SONDA_DISC_VEREDICTO=fail; SONDA_DISC_MOTIVO=''
  if ! sonda_lee "$reg"; then
    SONDA_DISC_MOTIVO="el registro de calibración de '$inst' no se puede leer: $SONDA_MOTIVO"; return 0
  fi
  p="${SONDA[disc_param]:-}"; o="${SONDA[disc_obs]:-}"
  if ! sonda_num "$p" || ! sonda_num "$o"; then
    SONDA_DISC_MOTIVO="'$inst' no publicó la mitad discordante (disc_param=<${p:-vacío}> disc_obs=<${o:-vacío}>): sin ella la procedencia del factor queda sin acreditar, y una sonda tautológica publica el mismo factor que una honesta"
    return 0
  fi
  # CONDICIÓN 4 · el tamaño del sujeto discordante lo fija el JUEZ y la sonda no lo declara.
  # Se comprueba sobre el registro porque ahí es donde se veía: `disc_veces = cal_n − 1` y
  # `disc_vueltas = cal_n / 50` los decidía y publicaba la sonda, y de ahí salía también el
  # testigo. Si el campo reaparece, el contraste ha vuelto a tener un solo lado.
  for clave in disc_veces disc_vueltas disc_tamano disc_sujeto; do
    [ -n "${SONDA[$clave]:-}" ] && declarado="$declarado $clave=${SONDA[$clave]}"
  done
  if [ -n "$declarado" ]; then
    SONDA_DISC_VEREDICTO=abort
    SONDA_DISC_MOTIVO="condición 4 de CA-03 (a.3): '$inst' DECLARA en su registro el tamaño del sujeto discordante ($declarado), y ese tamaño es del juez; si lo pone la sonda, el parámetro y el testigo vuelven a salir de la misma fuente y el contraste no puede fallar (QA-021-10)"
    return 0
  fi
  # CONDICIÓN 3 · ANTERIORIDAD, que es la forma EJECUTABLE de las condiciones 1 y 2.
  sonda_terna_parte "$terna"
  if ! sonda_num "${SONDA_T_VALOR:-}" || ! sonda_num "${SONDA_T_ANTES:-}" || ! sonda_num "${SONDA_T_INVOCA:-}"; then
    SONDA_DISC_VEREDICTO=abort
    SONDA_DISC_MOTIVO="condición 3 de CA-03 (a.3): el juez no acredita CUÁNDO obtuvo el testigo de '$inst' (terna=<${terna:-vacía}>, se esperaba «valor antes invoca»), y un testigo sin esa marca es uno que la sonda PUDO alimentar"
    return 0
  fi
  testigo="$SONDA_T_VALOR"
  if [ "$SONDA_T_ANTES" -ge "$SONDA_T_INVOCA" ]; then
    SONDA_DISC_VEREDICTO=abort
    SONDA_DISC_MOTIVO="condición 3 de CA-03 (a.3) (ANTERIORIDAD): el juez obtuvo el testigo de '$inst' en ${SONDA_T_ANTES}µs y la sonda se invocó en ${SONDA_T_INVOCA}µs, así que el testigo NO existía antes de la invocación y la sonda pudo alimentarlo (testigo=$testigo)"
    return 0
  fi
  if [ "$testigo" -le 0 ]; then
    SONDA_DISC_VEREDICTO=abort
    SONDA_DISC_MOTIVO="condición 2 de CA-03 (a.3): el juez no obtuvo TESTIGO para '$inst' (<$testigo>), así que no hay con qué contrastar la magnitud publicada; un testigo que produce la propia sonda no es un testigo"
    return 0
  fi
  if [ "$testigo" -eq "$p" ]; then
    SONDA_DISC_VEREDICTO=abort
    SONDA_DISC_MOTIVO="condición 1 de CA-03 (a.3) (NO VACUIDAD): el testigo de '$inst' COINCIDE con el parámetro ($testigo): el caso no distingue nada y su verde sería cierto POR VACÍO — una colisión es un defecto del dimensionado, no un veredicto"
    return 0
  fi
  case "$inst" in
    procesos)
      # Contraste EXACTO: el testigo es el número de invocaciones del binario instrumentado
      # que EL JUEZ metió en el snippet, y la magnitud publicada sale de contar el registro
      # de los envoltorios. Una sonda que no ejerza el sujeto no puede llegar a ese número
      # por aritmética sobre el parámetro, que es lo único que la mutación medida hacía.
      if [ "$o" -ne "$testigo" ]; then
        SONDA_DISC_MOTIVO="'$inst' publica disc_obs=$o donde el testigo del juez dice $testigo (parámetro con que se la invocó: $p): la magnitud no sale de observar el sujeto"
        return 0
      fi ;;
    reloj)
      # CONDICIÓN 5 · el umbral es el del JUEZ (`SONDA_SUELO_US`) y no el `suelo=` que
      # publica el instrumento juzgado: quien es juzgado no aporta la vara.
      if [ "$testigo" -ge "$SONDA_SUELO_US" ]; then
        SONDA_DISC_VEREDICTO=abort
        SONDA_DISC_MOTIVO="condición 1 de CA-03 (a.3): el juez cronometró su sujeto discordante de '$inst' en ${testigo}µs, que NO queda bajo el suelo de ${SONDA_SUELO_US}µs que el JUEZ declara: el caso no distingue nada"
        return 0
      fi
      if [ "${SONDA[disc_estado]:-}" != suelo ]; then
        SONDA_DISC_MOTIVO="'$inst' publica disc_estado=${SONDA[disc_estado]:-vacío} sobre un sujeto que el juez cronometró en ${testigo}µs, por debajo del suelo de ${SONDA_SUELO_US}µs: quien no mide no puede saber que está bajo el suelo (parámetro $p, disc_obs=$o)"
        return 0
      fi
      r=$(( o * 1000 / testigo ))
      if [ "$r" -lt 40 ] || [ "$r" -gt 25000 ]; then
        SONDA_DISC_MOTIVO="'$inst' publica disc_obs=${o}µs contra el testigo de ${testigo}µs que obtuvo el juez (razón ${r}‰, banda [40,25000]‰; parámetro $p): la magnitud publicada no es la que se observa"
        return 0
      fi ;;
    *)
      SONDA_DISC_VEREDICTO=abort
      SONDA_DISC_MOTIVO="no hay testigo declarado para '$inst' en el juez, que es su sede única"
      return 0 ;;
  esac
  SONDA_DISC_VEREDICTO=ok
  return 0
}

# EL SUJETO DISCORDANTE Y SU TESTIGO SON DEL JUEZ, Y ÉSTA ES SU SEDE ÚNICA (CA-03 (a.2) y
# (a.3) condiciones 2 y 4). Viven aquí y no en las secciones por dos motivos: uno de contrato
# —el conjunto lo fija el ayudante de veredicto— y uno medido: cronometrar dentro de una
# sección la convertiría en una SEGUNDA SEDE del reloj y el guardián de CA-07 punto 4 la
# acusaría, con razón.
#
# LO QUE ESTA VUELTA CAMBIA, Y ES TODO EL ARREGLO: el juez CONSTRUYE los dos sujetos y OBTIENE
# los dos testigos ANTES de invocar cualquier sonda. Antes los obtenía después —el de
# `procesos` contando líneas que la sonda escribía, el de `reloj` sobre un tamaño que leía del
# registro de la sonda—, y un testigo que sólo existe DESPUÉS es uno que la sonda pudo
# alimentar: `3 = 3` por construcción (QA-021-10). No cuesta un proceso: es orden.
#
# LO QUE ESTO NO CIERRA, dicho aquí y no en la cabeza de nadie (CA-03 (a.3)): los sujetos
# llegan a la sonda como snippets, así que una sonda que LEA el snippet y publique su cuenta
# sin ejercerlo sigue pasando. Eso ya no es aritmética disfrazada de medición —el descuido que
# (a.1) persigue— sino falsificación deliberada, y su respuesta no es un criterio más: es la
# custodia de `tests/util/*` en `codigo_app.globs` (1.34.0, P-01) y la mutación de un tercero.
SONDA_DISC_PROC_VECES=2        # OPERATIVO: cualquier valor < 4 cumple la condición 1
SONDA_DISC_RELOJ_SONDEO=2000   # vueltas del sondeo con que el juez deriva su tamaño
SONDA_DISC_RELOJ_PARTE=50      # el discordante del reloj cuesta 1/50 del suelo
SONDA_DISC_PROC_SUJ=''; SONDA_DISC_PROC_TESTIGO=0
SONDA_DISC_RELOJ_SUJ=''; SONDA_DISC_RELOJ_TESTIGO=0
SONDA_DISC_T_ANTES=0
# sonda_disc_prepara — deja los dos sujetos, los dos testigos y la marca de anterioridad.
sonda_disc_prepara() {
  local arnes_u arnes_v arnes_s arnes_t0 arnes_t1 arnes_m=''
  # (procesos) EL SUJETO: `SONDA_DISC_PROC_VECES` invocaciones del binario instrumentado, y
  # el TESTIGO **es ese número**, que el juez conoce porque lo puso él. Se elige MENOR QUE 4
  # a propósito (condición 1): el parámetro de esa sonda es `resolución × margen` con margen
  # ≥ 4 por contrato, así que no puede coincidir POR CONSTRUCCIÓN — y cuesta menos que el
  # `cal_n − 1` de antes, así que el término de CA-08 (iii) sólo se abarata.
  SONDA_DISC_PROC_SUJ=''
  for ((ARNES_DISC_I = 0; ARNES_DISC_I < SONDA_DISC_PROC_VECES; ARNES_DISC_I++)); do
    SONDA_DISC_PROC_SUJ="${SONDA_DISC_PROC_SUJ}grep -q x /dev/null || :"$'\n'
  done
  SONDA_DISC_PROC_TESTIGO="$SONDA_DISC_PROC_VECES"
  # (reloj) EL TAMAÑO SE DERIVA DEL SUELO CON EL RELOJ DEL JUEZ, en esta corrida y en esta
  # máquina (CA-03 (c)): un absoluto escrito a mano lo falsean la máquina, el runner y la
  # carga, y aquí decidiría además si el sujeto queda o no bajo el suelo — o sea, si el caso
  # aborta. Se apunta a 1/50 del suelo, que deja 50× de holgura para el ruido.
  arnes_t0=${EPOCHREALTIME/./}
  for ((ARNES_DISC_I = 0; ARNES_DISC_I < SONDA_DISC_RELOJ_SONDEO; ARNES_DISC_I++)); do :; done
  arnes_t1=${EPOCHREALTIME/./}
  arnes_u=$(( arnes_t1 - arnes_t0 )); [ "$arnes_u" -ge 1 ] || arnes_u=1
  arnes_v=$(( SONDA_SUELO_US * SONDA_DISC_RELOJ_SONDEO / (arnes_u * SONDA_DISC_RELOJ_PARTE) ))
  [ "$arnes_v" -ge 1 ] || arnes_v=1
  printf -v SONDA_DISC_RELOJ_SUJ 'for ((ARNES_DISC_J = 0; ARNES_DISC_J < %s; ARNES_DISC_J++)); do :; done' "$arnes_v"
  # …Y EL TESTIGO: el mínimo de 3 pasadas con el cronómetro de ESTE proceso, sobre el mismo
  # snippet que se le va a entregar. La sonda honesta lo mide muy por debajo del suelo y lo
  # DICE (`disc_estado=suelo`, sin factor, CA-02 punto 4); una que calcula sin medir publica
  # un número por encima del suelo y aquí se la caza.
  for arnes_s in 1 2 3; do
    arnes_t0=${EPOCHREALTIME/./}
    eval "$SONDA_DISC_RELOJ_SUJ"
    arnes_t1=${EPOCHREALTIME/./}
    arnes_u=$(( arnes_t1 - arnes_t0 )); [ "$arnes_u" -ge 1 ] || arnes_u=1
    if [ -z "$arnes_m" ] || [ "$arnes_u" -lt "$arnes_m" ]; then arnes_m="$arnes_u"; fi
  done
  SONDA_DISC_RELOJ_TESTIGO="$arnes_m"
  # LA MARCA DE ANTERIORIDAD: el instante en que el juez YA TIENE los dos testigos. Lo que
  # la hace comprobable es que se compara con la marca de la invocación, tomada abajo.
  SONDA_DISC_T_ANTES=${EPOCHREALTIME/./}
}

# sonda_calibracion_falla <instrumento> — deja SONDA_CAL_MOTIVO y devuelve 0 si la
# calibración de ESTA corrida para ese instrumento NO sirve. Es lo que convierte «una vez
# por corrida» en algo verificable: la calibración y las mediciones comparten el
# identificador de corrida (CA-03 punto 5).
SONDA_CAL_MOTIVO=''
sonda_calibracion_falla() {   # <instrumento> [<registro> <terna del testigo>]
  local inst="${1:-}" reg="${2-}" terna="${3-}" archivo banda amin amax bmin bmax a b
  SONDA_CAL_MOTIVO=''
  # Sin registro explícito se leen los de ESTA corrida. Con registro explícito se puede
  # juzgar una COPIA —lo que el residual de `tests/util/` exige: mutar la sonda en una copia
  # y comprobar que el juez REAL no la deja pasar (`ARNES_UTIL_DIR`, sin tocar el árbol)—.
  if [ "$#" -lt 2 ]; then
    archivo="$RAIZ/cal-$inst"
    if [ ! -r "$archivo" ]; then SONDA_CAL_MOTIVO="esta corrida no calibró '$inst'"; return 0; fi
    reg=''; IFS= read -r reg < "$archivo" 2>/dev/null || reg=''
    # La TERNA se lee del archivo que el juez escribió ANTES de invocar a la sonda: valor,
    # marca de obtención y marca de invocación. Leerla no cronometra nada.
    terna=''
    [ -r "$RAIZ/testigo-$inst" ] && { IFS= read -r terna < "$RAIZ/testigo-$inst" 2>/dev/null || terna=''; }
  fi
  if ! sonda_lee "$reg"; then SONDA_CAL_MOTIVO="la calibración de '$inst' no se puede leer: $SONDA_MOTIVO"; return 0; fi
  if [ "${SONDA[corrida]}" != "$ARNES_CORRIDA" ]; then
    SONDA_CAL_MOTIVO="la calibración de '$inst' es de OTRA corrida (${SONDA[corrida]}); no se reutiliza la de ayer"; return 0
  fi
  if [ "${SONDA[estado]}" != ok ]; then
    SONDA_CAL_MOTIVO="la calibración de '$inst' no pudo medir: estado=${SONDA[estado]} motivo=${SONDA[motivo]:-sin motivo}"; return 0
  fi
  # CA-10 punto 2: `vivos > 0` en un registro de CALIBRACIÓN es FAIL. Una calibración tomada
  # con descendencia viva no acredita que el instrumento responda al sujeto, y por CA-03
  # punto 5 arrastra a todas las mediciones de su corrida.
  if sonda_es_util "$inst" && sonda_num "${SONDA[vivos]:-}" && [ "${SONDA[vivos]}" -gt 0 ]; then
    SONDA_CAL_MOTIVO="la calibración de '$inst' se tomó con ${SONDA[vivos]} descendientes VIVOS (los mató y lo declaró, pero la muestra ya estaba contaminada): no acredita que el instrumento responda al sujeto (CA-10 punto 2)"
    return 0
  fi
  a="${SONDA[cal_a]:-}"; b="${SONDA[cal_b]:-}"
  if ! sonda_num "$a" || ! sonda_num "$b"; then
    SONDA_CAL_MOTIVO="la calibración de '$inst' no publicó los dos factores (a=<${a:-vacío}> b=<${b:-vacío}>)"; return 0
  fi
  banda="$(sonda_banda "$inst")" || { SONDA_CAL_MOTIVO="no hay banda declarada para '$inst' en el juez"; return 0; }
  read -r amin amax bmin bmax <<< "$banda"
  if [ "$a" -lt "$amin" ] || [ "$a" -gt "$amax" ] || [ "$b" -lt "$bmin" ] || [ "$b" -gt "$bmax" ] || [ "$a" -le "$b" ]; then
    SONDA_CAL_MOTIVO="la calibración de '$inst' NO distingue el sujeto sensible del insensible: a=$a b=$b (banda a [$amin,$amax] · b [$bmin,$bmax], en milésimas)"
    return 0
  fi
  # …y la MITAD DISCORDANTE (a.2): el par en banda dice «los factores salen»; la discordante
  # dice «y salen de OBSERVAR el sujeto». Sin ella, la calibración de una sonda tautológica
  # pasa entera, que es exactamente lo que se midió.
  sonda_discordante "$inst" "$reg" "$terna"
  if [ "$SONDA_DISC_VEREDICTO" != ok ]; then
    SONDA_CAL_MOTIVO="$SONDA_DISC_MOTIVO"; sonda_lee "$reg"; return 0
  fi
  sonda_lee "$reg"
  return 1
}

# sonda_usable <nombre> <registro> — LA PUERTA DE CA-10, en un solo sitio.
#   * registro vacío o ilegible                       -> FAIL (no es una sonda que no pudo
#                                                        medir: es una que no se ejecutó)
#   * `estado` distinto de `ok`                       -> SKIP citando motivo y número
#   * corrida sin calibración de SU instrumento, o
#     calibración que no distingue                    -> FAIL (CA-03 punto 5)
#   * si no, devuelve 0 SIN emitir nada y el llamador dicta su propio veredicto.
sonda_usable() {
  local nombre="$1" reg="${2:-}" inst
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 1; fi
  if [ -z "$reg" ]; then
    echo "  FAIL  $nombre  el registro de la sonda salió VACÍO: no es una sonda que no pudo medir, es una que no se ejecutó"; FAIL=$((FAIL+1)); return 1
  fi
  if ! sonda_lee "$reg"; then
    echo "  FAIL  $nombre  $SONDA_MOTIVO"; FAIL=$((FAIL+1)); return 1
  fi
  inst="${SONDA[sonda]}"
  if ! sonda_emisor_conocido "$inst"; then
    echo "  FAIL  $nombre  el registro dice venir de '$inst', y este juez no declara ese emisor: no puede saber qué gates le aplican"; FAIL=$((FAIL+1)); return 1
  fi
  if [ "${SONDA[estado]}" != ok ]; then
    echo "  SKIP  $nombre  la sonda '$inst' no pudo medir: estado=${SONDA[estado]} motivo=${SONDA[motivo]:-sin motivo} (min=${SONDA[min]:-n/a} archivos=${SONDA[archivos]:-n/a} cuenta=${SONDA[cuenta]:-n/a} us=${SONDA[us]})"
    return 1
  fi
  if [ "${SONDA[corrida]}" != "$ARNES_CORRIDA" ]; then
    echo "  FAIL  $nombre  el registro es de otra corrida (${SONDA[corrida]} en vez de $ARNES_CORRIDA): una medición sin la calibración de SU corrida no es publicable"; FAIL=$((FAIL+1)); return 1
  fi
  # LA CALIBRACIÓN SE EXIGE AL EMISOR QUE LA TIENE, y esa frontera es la misma que la de
  # `vivos`: CA-03 rige sobre los instrumentos de `tests/util/` («Cuando una corrida usa un
  # instrumento de tests/util/»), y CA-05 punto 4 dice de forma expresa que el materializador
  # inline HEREDA el formato y el parser y NO hereda la calibración de CA-03. Pedírsela sería
  # un FAIL garantizado sobre `mat37`/`mat47`, que es la forma de criterio insatisfacible que
  # este REQ ya ha pagado dos veces. Sobre él siguen exigiéndose CA-08 (0), CA-06 y CA-10.
  if sonda_es_util "$inst" && sonda_calibracion_falla "$inst"; then
    echo "  FAIL  $nombre  $SONDA_CAL_MOTIVO — «no hay calibración» y «la calibración no distingue» dicen lo mismo: no sé si estoy midiendo el sujeto"; FAIL=$((FAIL+1))
    sonda_lee "$reg"; return 1
  fi
  sonda_lee "$reg"
  # CA-10 punto 2: `vivos > 0` en un registro de MEDICIÓN es SKIP citando el número que sí
  # obtuvo y el `vivos=<n>`, nunca PASS. La sonda hizo lo correcto —encontró descendencia y
  # la mató— pero LA MUESTRA SE TOMÓ CON ELLA VIVA, que es el incidente de las 3 h 41 min en
  # miniatura: el que concluyó «dentro del ruido» con toda su lógica interna. Va DESPUÉS de
  # la calibración para que un FAIL siga ganando a un SKIP.
  # NECESARIO Y NO SUFICIENTE: leerlo cierra el fail-open de NO leerlo; que `vivos` cuente
  # bien es de la sonda, y hasta la vuelta 1 subestimaba (QA-021-05, cerrado con la marca).
  if sonda_es_util "$inst" && [ "${SONDA[vivos]:-0}" -gt 0 ]; then
    echo "  SKIP  $nombre  la sonda '$inst' encontró y mató ${SONDA[vivos]} descendientes: la muestra se tomó con ellos VIVOS y el reloj estaba contaminado (min=${SONDA[min]:-n/a} cuenta=${SONDA[cuenta]:-n/a} us=${SONDA[us]} vivos=${SONDA[vivos]})"
    return 1
  fi
  return 0
}

# sonda_juzga_calibracion <nombre> <instrumento> — el caso EXPLÍCITO de la calibración
# (CA-03 punto 3): si (a) y (b) no se distinguen dentro de la banda, FAIL —nunca SKIP y
# nunca PASS— nombrando el instrumento y los dos factores obtenidos.
sonda_juzga_calibracion() {
  local nombre="$1" inst="${2:-}" arch reg=''
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  arch="$RAIZ/cal-$inst"
  [ -r "$arch" ] && { IFS= read -r reg < "$arch" 2>/dev/null || reg=''; }
  if [ -z "$reg" ]; then
    echo "  FAIL  $nombre  la calibración de '$inst' no dejó registro: un instrumento que no se ejecuta produce el mismo silencio que uno que miente"; FAIL=$((FAIL+1)); return 0
  fi
  if sonda_calibracion_falla "$inst"; then
    echo "  FAIL  $nombre  $SONDA_CAL_MOTIVO"; FAIL=$((FAIL+1)); return 0
  fi
  sonda_lee "$reg"
  echo "  PASS  $nombre  sensible $(awk -v c="${SONDA[cal_a]}" 'BEGIN{printf "%.3f", c/1000}')× · insensible $(awk -v c="${SONDA[cal_b]}" 'BEGIN{printf "%.3f", c/1000}')× (esperados 2,000 y 1,000, los dos en banda y distinguidos; tamaño derivado del suelo en esta corrida: cal_n=${SONDA[cal_n]:-?} a ${SONDA[cal_margen]:-?}× el suelo, r=${SONDA[r]:-?})"; PASS=$((PASS+1))
}

# sonda_juzga_discordante <nombre> <instrumento> <registro> <terna> <esperado: pasa|falla|aborta>
# El caso EXPLÍCITO de la mitad discordante (CA-03 (a.2)), y también su FAIL-BEFORE: se le
# da un registro y la terna de su testigo y se comprueba que el veredicto del juez REAL es el
# que se espera. Con `falla` acredita que la comprobación DISTINGUE —sin esa mitad, un FAIL
# sólo probaría que falla, no que distingue (a.3)—; con `aborta`, que una de las cinco
# condiciones del testigo incumplida NO se convierte en PASS (CA-10 punto 1).
sonda_juzga_discordante() {
  local nombre="$1" inst="${2:-}" reg="${3-}" terna="${4-}" esperado="${5:-pasa}" obtenido
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  # Invariante 1 del banco: la guarda ANTES de juzgar. Un registro vacío y un registro que
  # miente producen el mismo silencio, y sin esta línea el caso lo llamaría «falla» y daría
  # verde en el fail-before sin que la sonda se hubiera ejecutado.
  if [ -z "$reg" ]; then
    echo "  FAIL  $nombre  no hay registro de calibración de '$inst' que juzgar: no se ejecutó nada, así que ni el fail-before ni el pass-after significan nada"; FAIL=$((FAIL+1)); return 0
  fi
  sonda_discordante "$inst" "$reg" "$terna"
  obtenido="$SONDA_DISC_VEREDICTO"
  case "$esperado:$obtenido" in
    pasa:ok)
      sonda_lee "$reg"
      echo "  PASS  $nombre  (disc_param=${SONDA[disc_param]:-?} · disc_obs=${SONDA[disc_obs]:-?} · testigo del juez=${terna%% *}, obtenido antes de invocar: terna <$terna>)"; PASS=$((PASS+1)) ;;
    falla:fail)
      echo "  PASS  $nombre  (el juez la caza: $SONDA_DISC_MOTIVO)"; PASS=$((PASS+1)) ;;
    aborta:abort)
      echo "  PASS  $nombre  (el juez ABORTA y no pasa: $SONDA_DISC_MOTIVO)"; PASS=$((PASS+1)) ;;
    *)
      echo "  FAIL  $nombre  se esperaba que la mitad discordante de '$inst' diera <$esperado> y el juez dijo <$obtenido>${SONDA_DISC_MOTIVO:+ ($SONDA_DISC_MOTIVO)}"; FAIL=$((FAIL+1)) ;;
  esac
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

# --- CA-07 punto 4 (REQ-021): NO QUEDA UNA SEGUNDA SEDE DE LO QUE SÍ SE MUDA ---
# Se comprueba POR PROPIEDAD y sobre el TEXTO, como la invariante 1: una función de sección
# que CRONOMETRE REPETICIONES de un sujeto o que CUENTE PROCESOS con envoltorios en el
# `PATH` reconstruye lo que una sonda de `tests/util/` ya hace, y dos sedes de la misma
# regla se desfasan. La misma pasada dice si esta vuelta usa algún instrumento: así la
# calibración de CA-03 no se le cobra a las vueltas anidadas —la sección 32 que 37/2
# cronometra, los directorios sintéticos de la autoprueba— que no tocan `tests/util/`, y no
# cuesta un `grep` por sección (en Windows cada fork cuesta 1,2–6 s).
#
# Y LA MATERIALIZACIÓN DE UN ÁRBOL DESDE UNA REFERENCIA DE `git` SALE DE ESTA COMPROBACIÓN,
# con su motivo y no en silencio: desde el 2026-09-08 la sede de esa propiedad ES la función
# inline de `37/1` y `37/2` (REQ-021 CA-05, tras la reducción de alcance), así que acusarla
# convertiría este guardián en un `ABORT` PERMANENTE sobre `mat37`/`mat47` — y un guardián
# que acusa la única sede que hay enumera un artefacto en vez de enunciar la propiedad «no
# hay dos sedes de lo mismo». Medido: la regla `cuerpo ~ /ls-tree/` acusaba a `mat37()`.
# Lo que esto NO tapa —que `mat37` y `mat47` siguen siendo dos copias literales y que nada
# comprueba que las dos conserven CA-05— está declarado en AN-021-01, con dueño y ventana.
SONDA_HACE_FALTA=no
SEGUNDA_SEDE="$(awk '
  function cierra(   reloj, bucle) {
    if (fn == "") return
    reloj = (gsub(/EPOCHREALTIME/, "EPOCHREALTIME", cuerpo) >= 2) || (cuerpo ~ /date \+%s%N/)
    bucle = (cuerpo ~ /for \(\(/) || (cuerpo ~ /(^|\n)[ \t]*while /)
    if (reloj && bucle)
      printf "%s: la funcion %s() cronometra repeticiones de un sujeto; eso es sonda-reloj.sh\n", archivo, fn
    if (cuerpo ~ /chmod \+x/ && cuerpo ~ /PATH=/)
      printf "%s: la funcion %s() cuenta procesos con envoltorios en el PATH; eso es sonda-procesos.sh\n", archivo, fn
    fn = ""; cuerpo = ""
  }
  FNR == 1 { cierra(); archivo = FILENAME }
  index($0, "sonda-reloj.sh") || index($0, "sonda-procesos.sh") { usa = 1 }
  /^[A-Za-z_][A-Za-z_0-9]*\(\)[ \t]*\{/ { cierra(); fn = $0; sub(/\(\).*/, "", fn); cuerpo = $0; if ($0 ~ /\}[ \t]*$/) cierra(); next }
  fn != "" { cuerpo = cuerpo "\n" $0; if ($0 ~ /^\}/) cierra(); next }
  END { cierra(); if (usa) printf "USA-INSTRUMENTOS\n" }
' "${SECCIONES[@]}")"
case "$SEGUNDA_SEDE" in
  *USA-INSTRUMENTOS*) SONDA_HACE_FALTA=si; SEGUNDA_SEDE="${SEGUNDA_SEDE%USA-INSTRUMENTOS}" ;;
esac
SEGUNDA_SEDE="${SEGUNDA_SEDE%"${SEGUNDA_SEDE##*[!$'\n']}"}"
if [ -n "$SEGUNDA_SEDE" ]; then
  echo "ABORT: hay una SEGUNDA SEDE de lo que una sonda de tests/util/ ya hace (REQ-021 CA-07.4):"
  printf '%s\n' "$SEGUNDA_SEDE" | sed 's/^/       /'
  echo "       Se invoca el instrumento; no se reescribe dentro de una sección."
  exit 1
fi

# --- La calibración: UNA VEZ POR INSTRUMENTO Y POR CORRIDA (CA-03) ------------
# Lo que acredita es una propiedad del INSTRUMENTO, no de la invocación: las tres sondas
# mudas de la ventana 1.32.1 —`jq --arg` de 128 KB, `git show` sin bit de ejecución,
# `$BASHPID` dentro de `$( )`— dejaron de responder al sujeto en TODAS sus invocaciones, y
# el archivo no cambia entre dos invocaciones de la misma corrida. Y una calibración cara es
# una calibración que alguien apaga, que es el final de camino que CA-08 (iii) existe para
# evitar.
#
# NO SE LE PASA EL TAMAÑO, Y ESO ES EL ARREGLO (CA-03 (c), QA-021-06). Antes iba
# `--n 200000` fijo: en esta máquina eso dejaba el ejercicio INSENSIBLE a ~72 ms, o sea a
# 1,4× del suelo de 50 ms, donde el ruido del planificador domina — 5 de 30 calibraciones
# fuera de banda, 2 con la máquina EN REPOSO, y cada una enrojeciendo `hooks-en-linux`. Y en
# una máquina bastante más rápida el mismo absoluto habría dicho `suelo` hasta que alguien
# subiera un env: una puerta requerida cuyo verde depende de la velocidad de la máquina es
# la que alguien acaba apagando. Ahora la sonda DERIVA el tamaño del suelo medido en esta
# corrida (`cal_n`, publicado en el registro) y `ARNES_SONDA_CAL_N` sólo puede SUBIRLO.
#
# `r` NO MUEVE CA-08 (iii) —numerador y denominador llevan los MISMOS mandos, porque el
# denominador se toma con el `r` que la calibración publica—, así que sólo cuesta reloj y eso
# lo mide (ii). Y AQUÍ ESTÁ EN 3 POR UNA MEDICIÓN, NO POR COSTUMBRE, en las dos direcciones:
#   * la vuelta 2 lo subió a 5 CREYENDO que era la palanca de CA-03 (d), y la medición lo
#     desmintió: (d) sale **0 de 30 en cuatro regímenes con r=3** igual que con r=5. Lo que
#     arregló (d) fue el TAMAÑO derivado del suelo —el insensible pasa de 1,4× a 4× el
#     suelo— y el INTERCALADO del par; `r` no aportó nada que se pueda medir;
#   * y r=5 dejaba CA-08 (ii) en **1,2825×** contra un techo de 1,25×, con la calibración
#     costando 5,6–6,0 s de los 25,6 s de la corrida. Bajarlo a 3 es la salida que (ii)
#     tenía PRE-DECIDIDA —«bajar `r` sólo mientras (d) siga en 0 de 30»— y (d) sigue en 0.
# Los rangos, las corridas y las cuatro regímenes están en el Historial de REQ-021.
# OPERATIVO: se sube con la medición; subirlo sólo cuesta reloj, y lo paga (ii).
SONDA_CAL_R="${ARNES_SONDA_CAL_R:-3}"
if [ "$SONDA_HACE_FALTA" = si ] && [ -d "$UTIL_DIR" ]; then
  # EL ORDEN ES EL ARREGLO (CA-03 (a.3) condición 3). El juez construye los sujetos, obtiene
  # los dos testigos y DEJA LAS TERNAS EN DISCO **antes** de que exista una sola invocación de
  # sonda; la marca de invocación se toma justo aquí, y `sonda_discordante` aborta si no es
  # posterior a la de obtención. La versión anterior obtenía los testigos DESPUÉS de calibrar
  # —de líneas que la sonda escribía y de un tamaño que la sonda publicaba—, y ahí `3 = 3` se
  # cumplía por construcción, hiciera la sonda algo o nada (QA-021-10).
  sonda_disc_prepara
  SONDA_DISC_T_INVOCA=${EPOCHREALTIME/./}
  printf '%s %s %s\n' "$SONDA_DISC_RELOJ_TESTIGO" "$SONDA_DISC_T_ANTES" "$SONDA_DISC_T_INVOCA" > "$RAIZ/testigo-reloj"
  printf '%s %s %s\n' "$SONDA_DISC_PROC_TESTIGO"  "$SONDA_DISC_T_ANTES" "$SONDA_DISC_T_INVOCA" > "$RAIZ/testigo-procesos"
  "$UTIL_DIR/sonda-reloj.sh"    --calibrar --k 1 --r "$SONDA_CAL_R" --disc-sujeto "$SONDA_DISC_RELOJ_SUJ" > "$RAIZ/cal-reloj"    2>"$RAIZ/cal-reloj.err"    || :
  "$UTIL_DIR/sonda-procesos.sh" --calibrar --dir-trabajo "$RAIZ"    --disc-sujeto "$SONDA_DISC_PROC_SUJ"  > "$RAIZ/cal-procesos" 2>"$RAIZ/cal-procesos.err" || :
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
# A MANO, NUNCA DERIVADO DE UNA CORRIDA: es el control. 873 → 880 por la sección 38, que
# pasa de 21 a 28 casos —salen los 3 de `sonda-linea-base.sh`, que sale del alcance, y entran
# 10: la mitad discordante de CA-03 (a.2) con su fail-before por instrumento, el tamaño
# derivado del suelo de (c), el descendiente reparentado con su fail-before, las dos formas
# de inyección del registro y las tres ramas de `vivos` en el juez—. Y 880 → 884, también en
# la 38 (28 → 32): los cuatro casos de las CINCO CONDICIONES del testigo de CA-03 (a.3), que
# es lo que cierra el `3 = 3` de QA-021-10 —anterioridad, no vacuidad, tamaño declarado por la
# sonda y umbral leído del registro juzgado—. Los `CASOS_ESPERADOS_SECCION` de `37/1` y `37/2`
# NO se tocan (CA-07 punto 2). Los dos literales, el de esta línea y el del archivo, se
# actualizan a mano y por separado: son el control.
CASOS_ESPERADOS=1095  # 887 → 906: la sección `28/3` nueva, con los 19 casos de REQ-026 (la
                      # historia de los REQ es una TABLA). Los `CASOS_ESPERADOS_SECCION` de
                      # `28/1` y `28/2` NO se tocan: allí tres casos cambiaron de rama y de
                      # texto —CA-08 reclasifica «tabla sin separadora»— pero no se creó ni
                      # se perdió ninguno.
                      # 906 → 910: los dos hallazgos `usuario/dinero` de la vuelta 1 de QA
                      # (`QA-026-01` el NUL que truncaba la lectura y se publicaba encima del
                      # REQ, `QA-026-02` la segunda tabla que se archivaba como filas de la
                      # primera), cada uno con SU CONTROL — sin el control, «no rota» también
                      # lo cumple un fixture que se quedó bajo el umbral.
                      # 910 → 916: `CA-08 (v)` —la cuarta rama de «no se rota» también deja su
                      # línea en el bloque derivado— y los cinco casos de la PROPIEDAD de
                      # `CA-08 (i)`: tres tablas, la separadora en la última fila, las dos
                      # formas de «una línea que no es fila entre dos filas» (párrafo y tabla
                      # indentada) y el control que las separa de CA-07.
                      # 916 → 924: la sección `28/4` nueva, con los 8 casos de `CA-18` (la
                      # actualización perdida de `SEC-067`). Va en una parte 4 porque la 3
                      # está en 400 de 400 líneas, el techo exacto de `REQ-014 CA-18`.
                      # 924 → 965: la sección 39 nueva, en CUATRO partes, con los 41 casos de
                      # REQ-023 (el carácter invisible que borra un campo de la cabecera y
                      # abre la puerta, SEC-047): 20 en la puerta y el dominio derivado, 10 en
                      # la clase y el corpus, 7 en los lectores y 4 en el coste. Son cuatro
                      # partes y no una porque los lectores y el coste juntos daban 422 líneas
                      # contra el techo de 400 de `REQ-014 CA-18`.
                      # 965 → 966: la vuelta 1 de QA sobre REQ-023. La parte 2 no cambia de
                      # total (10) —salen la entrada RESERVADA del pool tecleado (`QA-023-02`) y
                      # `CA-05`, entran las dos ramas de DENY del sorteo estratificado— y la
                      # parte 1 pasa de 20 a 21 al recibir `CA-05`, que se mudó porque el sorteo
                      # dejó la parte 2 en el techo de `REQ-014 CA-18`.
                      # 966 → 966: la sección 39 pasa a CINCO partes. La 2 quedó en 402 líneas
                      # contra su techo de 400 y `CA-04` —el corpus— sale a la parte 5. El total
                      # NO cambia porque partir REPARTE: 10 = 7 + 3. Que este literal siga en
                      # 966 es la comprobación de que no se creó ni se perdió ningún caso.
                      # 966 → 996: los 30 casos de REQ-024 (la ausencia de un campo de cabecera
                      # resuelta del lado que ABRE, SEC-047 mitad 2 / SEC-050 / SEC-051). Se
                      # reparten en tres archivos y no en dos, y el motivo está medido: la
                      # sección 40 nueva llega a su techo de 400 líneas con `CA-01`, `CA-02`,
                      # `CA-03`, `CA-05`, `CA-07` y `CA-11 (ii)`, así que el bloque B —los 14
                      # casos de la cola de `CA-08`, `CA-09`, `CA-10` y `CA-11 (i)`— va a la
                      # sección 31, que es donde ya viven los casos de REQ-009 cuyos controles de
                      # no-regresión `CA-09` reutiliza. Reparto: `31` 25 → 39, `40/1` 7 nuevos,
                      # `40/2` 9 nuevos. Los `CASOS_ESPERADOS_SECCION` de la 39 NO se tocan: el
                      # arreglo de `REGHER94` cambia un TEXTO de SKIP y no crea ni pierde casos.
                      # 996 → 1012: los 16 casos de `REQ-024 CA-06` —la nota de migración de
                      # `skills/arnes-upgrade/SKILL.md`— en la sección `40/3` nueva. Va en una
                      # parte 3 y no en la 2 porque la 2 está en 400 de 400 líneas, su techo
                      # exacto de `REQ-014 CA-18`, y porque el corte va POR TEMA: la 3 no mide
                      # los hooks, mide TEXTO heredado, y por eso deriva su ruta de `$SEC_DIR` y
                      # su fail-before de `ARNES_SKILL_UPGRADE` en vez de `ARNES_HOOKS_DIR`.
                      # `CA-04` —la fila del rigor de `AGENTS.md` §6/§13— NO tiene casos aquí:
                      # su cambio espera el gate humano que el propio criterio declara.
                      # 1012 → 1015: los 3 casos que ACREDITAN la banda de `REQ-017 CA-03`
                      # (write-back del modo intercalado, 2026-09-09) en `37/2`, que pasa de 5
                      # a 8: la tabla de veredictos en las DOS direcciones, el par
                      # discriminante —la banda sólo puede estrechar, nunca convierte un FAIL
                      # en PASS— y el contenido del SKIP, que cita banda, cociente y techo.
                      # Los cinco casos de antes NO se crean ni se pierden: los dos de CA-03
                      # cambian de instrumento y de puerta, y los de CA-04 y CA-06 sólo
                      # publican más evidencia en el mismo veredicto.
                      # 1015 → 1041: las dos mitades de código de `SEC-082` y `SEC-083`
                      # (`contrato`, altos, abiertos por `R-026`). Reparto: `13` 9 → 15 (+6)
                      # con el par de `SEC-083` en las DOS direcciones —la ausencia de `QA:`
                      # deniega la firma de seguridad y la nombra; la edición que NO toca el
                      # campo sigue pasando, también con los veredictos ya CRUZADOS en disco—,
                      # y `40/4` nueva con 11 casos para `SEC-082` (la entrada `Seguridad` del
                      # sitio único ya no es código muerto: se mide por MUTACIÓN, con la
                      # mutación verificada por su efecto en la tabla derivada y con control
                      # positivo sobre `QA` en la misma corrida, más cinco celdas que acreditan
                      # que la conducta condicional al rigor NO se movió, en los dos estados de
                      # la llave). NINGÚN caso se retira: el de `13` que pedía ALLOW sobre una
                      # firma sin `QA:` conserva fixture y sitio, y lo que cambia es el
                      # veredicto que se le exige — era la codificación del fail-open. Va en una
                      # parte 4 y no en la 1 porque la 1 está en 387 de 400 y la 2 en 400 de
                      # 400: `REQ-014 CA-18` manda partir, no alargar.
                      # 1041 → 1047: `CA-06 (v)`, que nació con el write-back del PRECIO de la
                      # salida (b) de `CA-12` (2026-09-10) y dejó `CA-06` SIN ACREDITAR por lo
                      # entregado el 2026-09-09. `40/3` pasa de 20 a 26: cinco casos para la
                      # viñeta nueva del skill —el acto, su dirección con el estado de la llave,
                      # las dos salidas de una línea, la remisión a `CA-05` como sitio de la
                      # lista, y los ejemplos marcados no exhaustivos— y uno DERIVADO que
                      # publica su denominador: toda promesa de equivalencia del apartado lleva
                      # el ACTO dentro de la promesa. Ningún caso se retira: el de `CA-06 (iv)`
                      # conserva sitio y veredicto y lo que cambia es su patrón, porque la
                      # formulación que exigía —«la resolución de la ausencia … decide
                      # exactamente lo mismo que 1.33.0»— quedó MEDIDA FALSA: las celdas que
                      # divergen son resoluciones de la ausencia de `QA:`, en otro acto.
                      # 1047 → 1054: `CA-05`, que quedó SIN CASO al ser reenunciado POR ACTO
                      # (`ADR-011`): desde el write-back contrata la equivalencia del CIERRE **y**
                      # la divergencia declarada del otro acto, y sólo lo primero estaba medido.
                      # `40/5` nueva con 7 casos: el instrumento (la línea base es OTRO árbol),
                      # la equivalencia del cierre con su denominador y su anti-vacuidad, la
                      # EXISTENCIA de la divergencia del otro acto —que es a la vez el CONTROL
                      # POSITIVO de la equivalencia—, su DIRECCIÓN restrictiva sobre todas las
                      # celdas, y las dos exigencias de texto: declarada en el criterio y en las
                      # dos sedes que ve quien migra. Va en una parte 5 y no en la 2 porque la 2
                      # está en 400 de 400 líneas: `REQ-014 CA-18` manda partir, no alargar. Los
                      # `CASOS_ESPERADOS_SECCION` de `40/1`–`40/4` NO se tocan: no se retira ni
                      # se mueve ningún caso, y el de la parte 2 —el cierre sobre el corpus REAL
                      # de `requirements/`— conserva sitio, fixture y veredicto.
                      # 1054 → 1064: el APARATO DE ANTI-VACUIDAD de `CA-12`, que su dueño
                      # declaró NO ENTREGADO al cerrar el código de `SEC-083`: el criterio pide,
                      # ADEMÁS del cumplimiento, publicar cuántos ACTOS ejerce la corrida con
                      # suelo de 2 y la lista DERIVADA de las ramas de denegación (`ADR-011`),
                      # los tres controles en los DOS estados de la llave, y el fail-before
                      # contra la heredada EN LA MISMA CORRIDA. `40/6` nueva con 10 casos: el
                      # instrumento (la base es otro árbol Y muerde), los actos DERIVADOS con su
                      # denominador, los actos EJERCIDOS identificados por el ancla de la rama
                      # que denegó —no por una etiqueta escrita en el banco—, los tres controles
                      # (`pendiente`, `con-hallazgos`, `aprobado`), la salida (b) por sus dos
                      # vías (ausente y comentada) con la rama DISTINTA de la del veredicto
                      # equivocado, el fail-before de cuatro ALLOW y la ASIMETRÍA por acto sobre
                      # el mismo estado. Va en una parte 6 y no en la 4 —que está en 176 de 400—
                      # porque el corte va POR TEMA: la 4 mide DE DÓNDE SALE LA DECISIÓN por
                      # mutación de la tabla, y ésta mide SOBRE CUÁNTOS ACTOS rige, con un
                      # extractor y una línea base que la 4 no necesita. Los
                      # `CASOS_ESPERADOS_SECCION` de `40/1`–`40/5` NO se tocan: no se retira ni
                      # se mueve ningún caso, y el único de `CA-12` que ya existía —`40/4`, la
                      # tabla que mueve el veredicto del acto de firmar— conserva sitio, fixture
                      # y veredicto.
                      # 1079 → 1090, en la 41 (15 → 26): QA-P48-01. Once casos que miden la
                      # CONDUCTA DE LA PUERTA ante un `Rigor:` con evidencia parentética —no lo
                      # que devuelve el lector—, porque el fail-open de v1.33.1 era una exención
                      # de QA, y una exención sólo existe en la puerta. Seis discriminan (fallan
                      # contra la 1.33.1 publicada) y cinco fijan las filas que NO se pueden
                      # mover: `ligero` limpio conserva su exención, `estandar (x)` sigue
                      # pidiendo QA, `critico (por suelo)` conserva la corrección de v1.33.1 y
                      # el suelo de seguridad sigue mandando sobre el piso del matiz. El caso
                      # 12.º no suma: era `D16: ligero con matiz sigue ligero`, que declaraba
                      # `allow` sobre el propio fail-open, y se corrige en su sitio en vez de
                      # añadirse. Los `CASOS_ESPERADOS_SECCION` de las secciones 39 y 40 NO se
                      # tocan: la AUSENCIA del campo se resuelve en otro camino (`ADR-009`) que
                      # esta guarda no atraviesa, así que ningún caso suyo cambia de veredicto.
                      # 1090 → 1094: la reparación del INSTRUMENTO de `REQ-024 CA-07 (ii)`
                      # (2026-09-11). El caso no tenía tercer estado —decidía con una sola
                      # invocación de la sonda y sin guarda de dispersión, así que una medición
                      # que no resuelve el factor que vigila salía como FAIL— y se lleva a la
                      # sección `40/7` nueva con su guarda de convergencia y de recorrido,
                      # PORTADA de `REQ-017 CA-08 (ii)`. Reparto: `40/2` 9 → 8 (pierde el caso,
                      # y NO se toca ningún otro: (i), (iii) y (iv) conservan sitio, fixture y
                      # veredicto), `40/7` 5 nuevos = el caso real más las cuatro
                      # demostraciones que acreditan la guarda —los tres estados con entradas
                      # sintéticas, el contenido del SKIP, y el par discriminante negativo y
                      # positivo—. Va en una parte 7 y no en la 2 porque la 2 estaba en 400 de
                      # 400 líneas: `REQ-014 CA-18` manda partir, no alargar. El techo 1,250×
                      # va INTACTO y el caso sigue en la puerta requerida.
                      #
                      # 1094 → 1095, en la VUELTA 4 de `CA-07 (ii)`: `40/7` pasa de 5 a 6 casos.
                      # El caso nuevo es la quinta demostración —«una medición inconcluyente es
                      # acreditación PENDIENTE»: se reintenta hasta `INTENTOS07` y, agotado el
                      # presupuesto, el caso emite FAIL y NO SKIP—, con su mitad discordante: la
                      # MISMA entrada por el camino de presentación sigue dando SKIP, que es
                      # exactamente lo que dejó la puerta requerida en VERDE sobre `1b3760e` con
                      # el caso abstenido (`[0,836× , 1,598×]`). Los mandos del caso pasan de
                      # `k=4 r=6` a `k=8 r=15` porque los primeros NO resuelven el factor que
                      # vigilan, medido EN EL RUNNER: la nula recorre [0,805× , 1,123×] con
                      # `k=4 r=6` y [0,997× , 1,018×] con `k=8 r=15`, en la misma corrida
                      # (`docs/arnes/req-024-ca-07-ii-reparacion/03-fase-1-viabilidad-en-el-runner.md`).
                      # La sonda de viabilidad TEMPORAL `40/8`, que declaraba 0 casos y por eso
                      # no movía este número, se RETIRÓ al terminar la fase 1: su medición vive
                      # en el artefacto, no en el banco.
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
# EL TITULAR NO ATRIBUYE UNA CAUSA QUE NO MIDIÓ (QA-021-09). Decía «(casos de otra
# plataforma)» de TODOS los SKIP, y de los tres de la corrida medida sólo UNO lo era: los
# otros dos se abstenían porque su palanca está apagada. La delegación permanente de
# publicación exige «SKIP explicados», y el titular del propio banco los explicaba mal.
# Cada SKIP ya trae su motivo en su línea, así que en vez de inventar una causa común se
# RECAPITULAN: es lo que hace falta para decidir si un SKIP es diseño o avería, y es la
# clase de defecto que este REQ persigue —un resumen que dice más de lo que midió—.
if [ "${SKIP:-0}" -gt 0 ]; then
  echo "Resultado: $PASS PASS, $FAIL FAIL, $SKIP SKIP — ninguna causa común: cada uno con su motivo"
  if [ "${#SALIDAS[@]}" -gt 0 ]; then
    awk '/^  SKIP /{ sub(/^  SKIP[ \t]+/, ""); printf "       · %s\n", $0 }' "${SALIDAS[@]}"
  fi
else
  echo "Resultado: $PASS PASS, $FAIL FAIL"
fi
[ "$FAIL" -eq 0 ] && [ "$PROBLEMAS" -eq 0 ]
