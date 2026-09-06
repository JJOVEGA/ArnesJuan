#!/usr/bin/env bash
# lib.sh — helpers compartidos por los hooks de enforcement del arnés.
#
# Filosofía (coherente con AGENTS.md y los agentes):
#   - INERTE fuera de un proyecto del arnés: si no hay `.arnes/config.json`, el hook
#     no hace nada (exit 0). Así el plugin puede estar activo globalmente sin estorbar
#     en repos que no usan el arnés.
#   - FAIL-CLOSED pero NO silencioso para la regla de identidad: ante un editor no
#     autorizado se deniega Y se explica el motivo (nunca un bloqueo mudo).
#   - Si falta una herramienta de base (jq), el enforcement queda inactivo con un
#     aviso por stderr; NO se bloquean ediciones por falta de tooling (no brickear).

# Lee TODO el stdin de forma bloqueante. El harness a veces tarda en enviarlo.
arnes_read_stdin() { cat; }

# --- Preludio y analisis compartidos ------------------------------------------
# Los dos guardianes hacian EXACTAMENTE el mismo trabajo previo —arrancar, leer
# stdin, interpretar el mismo JSON, leer el mismo manifiesto— cada uno en su
# propio proceso. Aqui se hace UNA vez y se memoriza, para que `guard.sh` pueda
# ejecutar los dos en un solo arranque.

# Lee stdin y localiza proyecto y manifiesto. Devuelve 1 si no hay nada que
# vigilar (sin input, sin proyecto, o proyecto que no usa el arnes -> INERTE).
arnes_preludio() {
  arnes_require_jq || return 1
  IFS= read -r -d '' ARNES_INPUT || true
  [ -n "${ARNES_INPUT:-}" ] || return 1
  arnes_project_dir "$ARNES_INPUT"
  [ -n "$ARNES_PROJ" ] || return 1
  ARNES_MANIFEST="$ARNES_PROJ/.arnes/config.json"
  [ -f "$ARNES_MANIFEST" ] || return 1
  return 0
}

# Campos del input que usan los guardianes. UNA llamada a jq para los dos.
# `command` va al final porque puede ser multilinea: se lleva el resto del texto.
arnes_parse_input() {
  [ -z "${ARNES_INPUT_LISTO:-}" ] || return 0
  arnes_jq_str "$ARNES_INPUT" -r '[.tool_name // "",
                                   .agent_id // "",
                                   .agent_type // "",
                                   .tool_input.file_path // "",
                                   .tool_input.command // ""] | .[]'
  { IFS= read -r ARNES_TOOL; IFS= read -r ARNES_AGENT_ID; IFS= read -r ARNES_AGENT_TYPE
    IFS= read -r ARNES_FP; IFS= read -r -d '' ARNES_CMD; } <<< "$ARNES_JQ"
  ARNES_CMD="${ARNES_CMD%$'\n'}"
  ARNES_INPUT_LISTO=1
}

# Campos del manifiesto, tambien en UNA llamada. Los globs van al final porque son
# una lista de longitud variable: se leen como el resto del flujo.
arnes_parse_manifest() {
  [ -z "${ARNES_MANIFEST_LISTO:-}" ] || return 0
  local g
  arnes_jq_file "$ARNES_MANIFEST" -r '[(.agentes.agente_codigo // "desarrollador"),
                                       (.requirements_dir // "requirements"),
                                       (.estados.completado // "completado"),
                                       (.pending_approval // "PENDING_APPROVAL.md"),
                                       (.limites.bash_max_analisis // "" | tostring)]
                                      + (.codigo_app.globs // []) | .[]'
  ARNES_GLOBS=()
  # `limites.bash_max_analisis` es OPCIONAL: el valor por defecto vive en el codigo
  # (`ARNES_BASH_MAX_ANALISIS`) y ningun proyecto tiene que declararlo. Solo se acepta si
  # es un entero positivo; cualquier otra cosa se ignora y manda el defecto —un techo
  # escrito a mano no puede desactivar la puerta por una errata.
  { IFS= read -r ARNES_AGENTE_CODIGO; IFS= read -r ARNES_REQ_DIR
    IFS= read -r ARNES_ESTADO_DONE;   IFS= read -r ARNES_PENDING
    IFS= read -r ARNES_BASH_MAX
    while IFS= read -r g; do [ -n "$g" ] && ARNES_GLOBS+=("$g"); done
  } <<< "$ARNES_JQ"
  case "${ARNES_BASH_MAX:-}" in
    ''|*[!0-9]*|0) ARNES_BASH_MAX='' ;;
  esac
  ARNES_GLOBS_CARGADOS=1
  ARNES_MANIFEST_LISTO=1
}

# Raíz del proyecto: prioriza $CLAUDE_PROJECT_DIR; si no, el campo `cwd` del input.
arnes_project_dir() {   # <input json> -> ARNES_PROJ
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    ARNES_PROJ="$CLAUDE_PROJECT_DIR"      # caso normal: cero forks
  else
    ARNES_PROJ="$(printf '%s' "$1" | jq -r '.cwd // empty')"
  fi
}

# Ruta del manifiesto del arnés para este proyecto.
arnes_manifest_path() { printf '%s/.arnes/config.json' "$1"; }

# ¿Está jq disponible? Si no, avisa y pide al llamador que se desactive.
arnes_require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    printf 'ARNES (hook): jq no encontrado; enforcement inactivo en esta sesión.\n' >&2
    return 1
  fi
  return 0
}

# Emite una decisión DENY de PreToolUse y termina (exit 0 = decisión aplicada).
# Salida compacta (-c): una sola línea, el formato que esperan los hooks.
arnes_deny() {
  jq -cn --arg r "$1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

# Aviso por stderr (no silencioso), sin bloquear.
arnes_warn() { printf 'ARNES (hook): %s\n' "$1" >&2; }

# --- Compatibilidad Windows ---------------------------------------------------
# En Windows `jq` suele ser un binario NATIVO, no MSYS. Eso rompe dos cosas a la vez:
#   1. Traducción de rutas: bash ve `/tmp/x`, pero jq devuelve `C:/Users/.../Temp/x`.
#      Al restar el prefijo del proyecto, `rel` conserva la ruta absoluta y NINGÚN
#      glob casa jamás -> el hook permite todo.
#   2. stdout en modo texto: cada línea llega con CRLF, así que un glob leído del
#      manifiesto es `src/*\r` y tampoco casa nunca.
# Ambos fallan ABIERTO y en silencio: el enforcement parece activo y no lo está.

# jq con el CR de Windows retirado de la salida, SIN arrancar un segundo proceso.
#
# La forma obvia —`jq "$@" | tr -d '\r'`— cuesta DOS arranques de proceso por
# lectura. Medido en Windows con emulación MSYS y antivirus de por medio, un
# arranque ronda el segundo, y los guardianes hacen varias lecturas por
# invocación: el `tr` llegaba a ser la mitad del coste del hook.
#
# Bash quita los CR con expansión de variable, que no arranca nada. El
# `printf` final repone el salto que la sustitución de comandos se come, para
# que esto siga sirviendo igual en `$(...)` que en `< <(...)`.
arnes_jq() {
  local out
  out="$(jq "$@")" || return $?
  printf '%s\n' "${out//$'\r'/}"
}

# Las dos formas que SÍ hay que usar en el camino caliente: dejan el resultado en
# ARNES_JQ y cuestan UN solo fork.
#
# `arnes_jq` imprime, así que sus llamadas acaban envueltas en `< <(printf ... |
# arnes_jq ...)`, y eso son TRES forks para una sola lectura: la sustitución de
# proceso, la tubería, y el `$( )` interno de la propia función. Con here-string
# —que bash resuelve con un archivo temporal, sin bifurcar— y asignando en vez de
# imprimir, queda uno.
arnes_jq_str() {   # <json> <args de jq...> -> ARNES_JQ
  local json="$1"; shift
  local out
  out="$(jq "$@" <<< "$json")" || return $?
  ARNES_JQ="${out//$'\r'/}"
}

arnes_jq_file() {  # <archivo> <args de jq...> -> ARNES_JQ
  local f="$1"; shift
  local out
  out="$(jq "$@" "$f")" || return $?
  ARNES_JQ="${out//$'\r'/}"
}

# Una ruta CONFIGURABLE del manifiesto tiene que quedarse DENTRO del proyecto.
#
# `estado_derivado.archivo` y las `ruta` de la rotacion se concatenaban a la raiz tal
# cual, asi que `"archivo": "../fuera.md"` hacia que el hook de parada escribiera fuera
# del repositorio en cada parada. El manifiesto lo escribe el proyecto -- pero tambien
# lo puede escribir un agente, y no esta protegido por guard-codigo. Un hook que escribe
# fuera del arbol es un hook que puede escribir en cualquier sitio.
#
# Regla CERRADA, sin forks: relativa, sin `..` como segmento, sin `~`, sin barra
# invertida (aqui no se normaliza; lo que no sea una ruta POSIX relativa limpia, no pasa).
arnes_ruta_interna() {   # <ruta configurada> -> 0 si es interna, 1 si no
  local r="$1"
  case "$r" in
    ''|/*|[A-Za-z]:*|'~'*) return 1 ;;
    ..|../*|*/..|*/../*)   return 1 ;;
  esac
  case "$r" in *'\'*) return 1 ;; esac
  return 0
}

# La contencion LEXICA de arriba no basta: un enlace simbolico `docs -> /externo`
# atraviesa una ruta que parece interna. Medido por una revision externa en 1.29.1:
# `estado_derivado.archivo = docs/ESTADO.md` con `docs` enlazado escribio fuera del
# proyecto. Esta es la contencion FISICA: el directorio destino, RESUELTO, tiene que
# quedar dentro de la raiz RESUELTA. `pwd -P` es POSIX y resuelve enlaces; cuesta dos
# subshells, que se pagan solo en una parada de agente, nunca en un PreToolUse.
#
# Se comprueba el DIRECTORIO padre, no el archivo: el archivo puede no existir aun
# (primera escritura) y un archivo enlazado se escribe donde apunte su directorio.
arnes_dir_interno() {   # <directorio existente> -> 0 si su ruta fisica queda dentro del proyecto
  local d="$1" fis raiz
  [ -d "$d" ] || return 1
  fis="$(cd -- "$d" 2>/dev/null && pwd -P)" || return 1
  raiz="$(cd -- "$ARNES_PROJ" 2>/dev/null && pwd -P)" || return 1
  case "$fis/" in "$raiz/"*) return 0 ;; esac
  return 1
}


# Ruta canónica para COMPARAR (no para abrir): separadores `/` y, en Windows, forma
# mixta `c:/...` con la unidad en minúscula. Fuera de Windows es la identidad.
arnes_norm_path() {   # <ruta> -> ARNES_NORM
  local p="$1" d
  # `cygpath` SÓLO cuando hace falta. Su trabajo es traducir la forma MSYS
  # (`/tmp/x`) a forma Windows (`C:/Users/.../Temp/x`); una ruta que ya llega
  # como `X:\...` o `X:/...` no necesita conversión. Saltárselo ahorra un fork
  # —el coste dominante en esta plataforma— en el caso más común de Windows,
  # donde tanto `file_path` como la raíz del proyecto ya vienen calificadas.
  case "$p" in
    [A-Za-z]:*) ;;                       # ya es forma Windows: nada que traducir
    /*) if command -v cygpath >/dev/null 2>&1; then
          p="$(cygpath -m -- "$p" 2>/dev/null)" || p="$1"
        fi ;;
  esac
  p="${p//\\//}"
  case "$p" in
    [A-Za-z]:*) d="${p%%:*}"; p="${d,,}:${p#*:}" ;;   # unidad en minúscula, sin `tr`
  esac
  ARNES_NORM="$p"
}

# --- Rutas relativas al proyecto ----------------------------------------------
# Devuelve la ruta con la que se comparan los globs del manifiesto: relativa a la
# raíz del proyecto. Una ruta ya relativa (típica en comandos de Bash) se deja tal
# cual, asumiendo que el comando corre en la raíz; si el agente hizo `cd` a otro
# sitio, el resultado no casará con ningún glob (falso negativo, nunca positivo).
arnes_ruta_relativa() {  # <ruta> <raíz del proyecto> -> ARNES_REL
  local p pp
  arnes_norm_path "$1"; p="$ARNES_NORM"
  arnes_norm_path "$2"; pp="$ARNES_NORM"
  p="${p#"$pp"/}"
  ARNES_REL="${p#./}"
}

# ¿La ruta relativa cae dentro de `codigo_app.globs`?
#
# Los globs se leen UNA sola vez por invocación del hook y quedan cacheados:
# `guard-bash` llama a esta función una vez por cada destino de escritura que
# encuentra en el comando, y sin caché cada llamada pagaba otro `jq` más su
# sustitución de proceso — dos forks por destino.
arnes_es_codigo_app() {  # <ruta relativa> <manifiesto>
  local rel="$1" manifest="$2" g
  [ -n "$rel" ] || return 1
  if [ -z "${ARNES_GLOBS_CARGADOS:-}" ]; then
    ARNES_GLOBS=()
    arnes_jq_file "$manifest" -r '.codigo_app.globs[]? // empty'
    while IFS= read -r g; do
      [ -n "$g" ] && ARNES_GLOBS+=("$g")
    done <<< "$ARNES_JQ"
    ARNES_GLOBS_CARGADOS=1
  fi
  # Si `arnes_parse_manifest` ya corrio, los globs vienen de ahi y este bloque no
  # se ejecuta: una lectura del manifiesto para todo, no una por pregunta.
  for g in ${ARNES_GLOBS[@]+"${ARNES_GLOBS[@]}"}; do
    # shellcheck disable=SC2053  -- glob a la derecha a propósito
    if [[ "$rel" == $g ]]; then return 0; fi
  done
  return 1
}

# --- Identidad del agente -----------------------------------------------------
# Claude Code entrega el agente en `agent_type` CON el prefijo del plugin que lo
# provee (`arnes-juan:desarrollador`), mientras que el manifiesto lo declara por su
# nombre corto (`desarrollador`). Comparar en crudo no casaba nunca y el guard
# terminaba denegando justo al único agente autorizado (bug hallado en SENDA).
#
# Regla de coincidencia — tolerante al prefijo, sin volverse permisiva:
#   1. Se compara el NOMBRE CORTO (lo que va tras el último ':'), normalizado
#      (minúsculas, sin espacios ni CR): el manifiesto lo escribe una persona.
#   2. Si AMBOS lados traen prefijo, además deben coincidir los prefijos. Un
#      proyecto que necesite desambiguar declara `arnes-juan:desarrollador` y con
#      eso rechaza a `otro-plugin:desarrollador`.
#   3. Si el manifiesto NO trae prefijo, cualquier proveedor con ese nombre corto
#      casa. El manifiesto no dijo de qué plugin viene, y exigirlo obligaría a cada
#      proyecto a conocer el nombre del plugin — que es el fallo que se corrige.
# RENDIMIENTO — por qué estas funciones ASIGNAN en vez de imprimir.
# Una función que devuelve su valor por stdout obliga a un `$( )` en cada punto de
# llamada, y en MSYS un `fork` está emulado copiando memoria: medido en Windows,
# un subshell que sólo ejecuta un builtin cuesta ~554 ms, y añadirle un binario
# real sólo suma ~80 ms más. El coste NO son los programas, son las sustituciones.
# La versión anterior de `arnes_norm_ident` era `printf | tr | tr | sed` —cuatro
# procesos— y `arnes_agente_coincide` la invocaba cuatro veces dentro de `$( )`:
# ~20 forks para comparar dos nombres. Aquí no queda ninguno.
arnes_norm_ident() {   # -> ARNES_IDENT
  local s="${1//$'\r'/}"
  s="${s,,}"
  s="${s#"${s%%[![:space:]]*}"}"   # recorta espacios por la izquierda
  s="${s%"${s##*[![:space:]]}"}"   # ...y por la derecha
  ARNES_IDENT="$s"
}

arnes_ident_nombre() {   # nombre corto, sin prefijo de plugin -> ARNES_NOMBRE
  arnes_norm_ident "$1"
  ARNES_NOMBRE="${ARNES_IDENT##*:}"
}

arnes_ident_prefijo() {  # prefijo del proveedor, o vacío -> ARNES_PREFIJO
  arnes_norm_ident "$1"
  case "$ARNES_IDENT" in
    *:*) ARNES_PREFIJO="${ARNES_IDENT%:*}" ;;
    *)   ARNES_PREFIJO='' ;;
  esac
}

arnes_agente_coincide() {  # <agent_type recibido> <nombre declarado>
  local rn dn rp dp
  arnes_ident_nombre "$1"; rn="$ARNES_NOMBRE"
  arnes_ident_nombre "$2"; dn="$ARNES_NOMBRE"
  [ -n "$rn" ] && [ "$rn" = "$dn" ] || return 1
  arnes_ident_prefijo "$1"; rp="$ARNES_PREFIJO"
  arnes_ident_prefijo "$2"; dp="$ARNES_PREFIJO"
  if [ -n "$dp" ] && [ -n "$rp" ] && [ "$rp" != "$dp" ]; then return 1; fi
  return 0
}

# Nombre del agente para un mensaje humano: corto y, si venía calificado, con el
# identificador completo entre paréntesis para poder diagnosticar el origen.
# Ésta sí imprime: sólo se usa al construir el motivo de una denegación, así que
# el fork de su `$( )` ocurre una vez y en un camino que ya terminó en bloqueo.
arnes_agente_legible() {  # <agent_type>
  local ident nombre
  arnes_norm_ident "$1";   ident="$ARNES_IDENT"
  arnes_ident_nombre "$1"; nombre="$ARNES_NOMBRE"
  if [ "$ident" != "$nombre" ]; then
    printf "'%s' (%s)" "$nombre" "$ident"
  else
    printf "'%s'" "$nombre"
  fi
}

# --- Escrituras evidentes dentro de un comando de Bash ------------------------
# COBERTURA DELIBERADAMENTE PARCIAL. Un hook no puede analizar shell arbitrario de
# forma fiable (heredocs, scripts, herramientas que escriben por su cuenta), y un
# intento de cobertura total produce falsos positivos que terminan con alguien
# desactivando el guard. Aquí sólo se detectan las formas obvias y directas:
#   redirección `>`/`>>`, `tee`, `cp`, `mv`, `install`, `sed -i`, `perl -i`, `dd of=`.
# Todo lo demás (compiladores, formateadores, `git apply`, `patch`, scripts) queda
# fuera a propósito: es una barandilla, no una jaula.
#
# Sesgo explícito al FALSO NEGATIVO: primero se descarta el texto entrecomillado,
# así una mención de una ruta dentro de un mensaje no dispara nada.

# --- Presupuesto de analisis del detector de Bash -----------------------------
# "Una puerta que no puede medir no deja pasar" (AGENTS.md 1). El detector de escrituras
# es ahora LINEAL en todos sus ejes, pero ningun algoritmo carece de acantilado: un hook
# PreToolUse muere a los 60 s y UN HOOK MUERTO NO DENIEGA — guard.sh recibe salida vacia y
# el comando pasa. Antes de llegar ahi por agotamiento, se deniega por TAMANO y se dice
# como salir. Fallar cerrado y a tiempo es preferible a fallar abierto y en silencio.
#
# QUE SE MIDE, exactamente (y no otra cosa):
#   (a) los bytes de las lineas del cuerpo de un heredoc SIN CITAR que llevan `$(` o un
#       acento grave — el unico material del cuerpo que el shell EJECUTA y que por eso
#       hay que analizar; y
#   (b) los bytes del texto del comando que quedan FUERA de los cuerpos de heredoc.
#
# QUE NO SE MIDE: el tamano del comando. Un `cat > docs/x.md <<'EOF'` de 300 KB con el
# delimitador CITADO es la forma legitima y corriente de escribir un archivo grande, la
# usan todos los agentes y su cuerpo se descuenta entero sin analizarse: sigue en `allow`
# y sigue siendo barato. Poner el techo sobre el comando entero lo habria roto.
#
# EL VALOR (65536 = 64 KiB) sale de MEDIR en la plataforma de desarrollo (Linux/WSL2,
# 2026-09-05) el peor caso por byte —una linea de cuerpo densa en `$(...)`, que gasta un
# fragmento cada 7 bytes—: 64 KiB de ese material se analizan de punta a punta en 0,71 s,
# frente al tope de 2 s que se fijo para el tamano maximo admitido y a los 60 s en que el
# hook muere. El doble (128 KiB) ya cuesta 1,8 s y el cuadruple 6,3 s, asi que el margen
# se agota rapido: por eso el techo esta aqui y no mas arriba. El material real de un
# comando normal son decenas de bytes; esto solo lo toca una entrada construida.
ARNES_BASH_MAX_ANALISIS=65536
# Codigo de salida de `arnes_bash_escrituras` cuando NO analizo por presupuesto.
ARNES_RC_EXCESO=2

# Techo efectivo, resuelto UNA vez por proceso y SOLO cuando hace falta.
#
# La clave OPCIONAL `limites.bash_max_analisis` del manifiesto solo puede SUBIRLO. No es
# un descuido: leer el manifiesto cuesta un `jq`, y el camino comun —todo comando de
# shell de todo agente, el mas frecuente que hay— no puede pagar un proceso por comando
# (CA-39). Por eso el techo del codigo se aplica sin preguntar a nadie y el manifiesto
# solo se consulta cuando ese techo ya se quedo corto, que es justo el caso en el que
# subirlo tiene sentido. Un proyecto que quisiera un techo MAS BAJO que el del codigo no
# obtendria nada que la puerta no le de ya: el techo no autoriza, solo acota el analisis.
arnes_techo_bash() {   # -> ARNES_TECHO
  if [ -z "${ARNES_TECHO:-}" ]; then
    ARNES_TECHO="$ARNES_BASH_MAX_ANALISIS"
    arnes_parse_manifest
    if [ -n "${ARNES_BASH_MAX:-}" ] && (( ARNES_BASH_MAX > ARNES_TECHO )); then
      ARNES_TECHO="$ARNES_BASH_MAX"
    fi
  fi
  return 0
}

# Descuenta el texto ENTRECOMILLADO de UN fragmento, por pares. Sin procesos.
#
# Por fragmento y no sobre el comando entero, por dos razones medidas (revision de
# REQ-001, vuelta 1):
#
#   1. CORRECCION. Las comillas del cuerpo de un heredoc son TEXTO para bash: ahi dentro
#      no abren ni cierran nada. Al descontar sobre TODO el comando, una comilla IMPAR del
#      cuerpo (`$(date) don't`) se emparejaba con la primera comilla del comando REAL
#      posterior al cierre y borraba lo que hubiera en medio -- la redireccion se evaporaba
#      y el hook permitia una escritura que el shell si hacia. Un fragmento no puede ver
#      comillas que no sean suyas, asi que esa asimetria deja de existir.
#
#   2. COSTE. El bucle anterior RECONSTRUIA la cadena entera por cada par: cuadratico
#      sobre el texto conservado. Medido: 500 lineas de cuerpo con expansiones 5,5 s,
#      1.000 -> 40 s, 1.500 -> sin respuesta en 65 s. Un hook PreToolUse muere a los 60 s
#      y UN HOOK MUERTO NO DENIEGA: el coste era, el solo, un fallo en abierto.
#
# COSTE, SEGUNDA VUELTA (REQ-001 v3). Consumir el prefijo con `${s#*"$q"}` acoto el
# problema al fragmento, pero NO lo elimino: cada `${s#...}` COPIA el resto de la cadena,
# asi que un fragmento de n comillas seguia costando O(n^2) DENTRO de si mismo. Medido en
# la vuelta 1: 2.000 comillas 527 ms, 4.000 -> 2,1 s, 8.000 -> 8,7 s (doblar cuadruplica).
#
# Aqui no se copia ningun resto: el texto se PARTE UNA VEZ por la comilla, usando el
# troceado en palabras de bash con `IFS` (una sola pasada del interprete, en C), y los
# trozos PARES —los de fuera de comillas— se vuelven a unir con `${a[*]}`, que tambien es
# una sola pasada. Todo el descuento es O(n). No hay procesos: `IFS` + expansion de array.
#
#   "a'b'c"  ->  trozos [a][b][c]  ->  se conservan 0 y 2  ->  "a c"
#
# La marca `\001` del final evita la unica asimetria del troceado: bash DESCARTA el campo
# vacio final, asi que sin ella `a'b'` y `a'b` producirian el mismo numero de trozos y la
# paridad —que es la que decide si la ultima comilla esta huerfana— se leeria mal.
# Con un numero IMPAR de comillas la ultima no cierra nada: se conserva tal cual, con su
# comilla, exactamente como hacia el bucle anterior (no se inventa un cierre que no hay).
_arnes_desentrecomilla() {   # <texto> -> ARNES_SINCOM
  local s="$1" q k np i
  local -a p keep
  local reponer_f=0; case $- in *f*) reponer_f=1 ;; esac
  local IFS
  for q in '"' "'"; do
    case "$s" in *"$q"*) ;; *) continue ;; esac
    IFS="$q"; set -f
    # shellcheck disable=SC2206  -- se quiere el troceado por IFS, con globbing apagado
    p=($s$'\001')
    [ "$reponer_f" -eq 1 ] || set +f
    np=${#p[@]}; k=$((np - 1))
    p[k]="${p[k]%$'\001'}"
    keep=()
    for ((i = 0; i < np; i += 2)); do keep+=("${p[i]}"); done
    IFS=' '
    s="${keep[*]}"
    (( k % 2 )) && s+="$q${p[k]}"
  done
  ARNES_SINCOM="$s"
}

# De una linea del cuerpo de un heredoc SIN CITAR, extrae SOLO lo que el shell EJECUTA:
# el interior de cada `$( ... )` y de cada par de acentos graves.
#
# El resto de la linea es texto que se ENTREGA al comando, y analizarla entera por llevar
# una expansion devolvia el falso positivo de 1.29.1: `ver $(date) y luego cp README.md
# src/x.ts` se denegaba sin que nada copiara nada. La regla queda escrita: dentro del
# cuerpo, comando es lo que va dentro de la expansion; lo demas es texto.
#
# Cada fragmento se acumula como un elemento de `ARNES_EXPS`, que se une con `;`
# —separador que el tokenizador ya entiende— UNA sola vez al final: ni las comillas ni
# los operandos de un fragmento cruzan a otro.
#
# DONDE TERMINA UN FRAGMENTO (REQ-001 v4, hallazgo QA-015). La version anterior tomaba
# de cada trozo el prefijo hasta el PRIMER `)`. Medido, eso perdia TODO lo que siguiera
# a ese `)` dentro de la misma sustitucion —incluida la redireccion— en tres formas
# corrientes que el shell SI ejecuta:
#     $(cat "$(ls README.md)" > src/a.ts)   el `)` de la sustitucion INTERIOR trunca
#     $(echo "a)b" > src/a.ts)              el `)` va DENTRO de comillas
#     $(echo "(hola)" > src/a.ts)           parentesis literal entrecomillado
# El primer `)` no es el cierre: el cierre es el `)` que devuelve la PROFUNDIDAD a cero,
# contando solo los parentesis que NO estan entrecomillados. Comillas y profundidad se
# resuelven en la MISMA pasada, que es la unica forma de no depender de un orden
# imposible: para saber que comillas descontar hace falta saber donde acaba el
# fragmento, y para saber donde acaba hace falta haber descontado las comillas.
#
# COMO, SIN VOLVER A SER CUADRATICO. La linea se marca UNA vez (unas pocas sustituciones
# `${s//x/y}`, cada una una pasada de bash en C) y se PARTE UNA vez en ATOMOS: cada
# atomo es un caracter con significado (`\`, `$(`, `(`, `)`, `"`, `'`) seguido del texto
# que va detras. El recorrido toca cada atomo exactamente una vez, y el texto del
# fragmento se acumula en un ARRAY que se une al cerrar —nunca concatenando cadenas, que
# es copiar, y copiar dentro de un bucle es justo lo que hacia cuadratica a la version de
# la vuelta 1 (2.000 expansiones 1.151 ms, 4.000 -> 5,1 s, 8.000 -> 18,2 s, 16.000 -> el
# hook muere a los 60 s y guard.sh recibe salida vacia: FALLO EN ABIERTO).
# Sin procesos: solo `IFS`, expansion de parametros y arrays.
#
# LAS COMILLAS SOLO SON SINTAXIS DENTRO DE LA SUSTITUCION, y no es un detalle: en el
# cuerpo de un heredoc sin citar una comilla es TEXTO —`don't $(cp README.md src/a.ts)`
# ejecuta el `cp`—, mientras que dentro de `$( )` bash reinterpreta como comando y ahi si
# abre y cierra. Por eso el estado de comillas nace vacio al abrir cada fragmento y muere
# al cerrarlo: no cruza de un fragmento a otro ni contagia al texto de alrededor. Con la
# comilla IMPAR —la que no cierra nunca— se conserva lo que va detras, tal cual, igual que
# hace `_arnes_desentrecomilla`: no se inventa un cierre que no hay, y lo que no se puede
# descontar se analiza.
#
# ESCAPE (REQ-001 v3, ampliado en v4): `\$(` NO es una sustitucion —bash imprime el texto
# literal—, y denegarlo era un falso positivo en un detector cuyo sesgo declarado es el
# contrario. Se cuenta la barra invertida por PARIDAD, que es la unica lectura correcta:
# `\$(` no ejecuta, `\\$(` SI ejecuta (la primera barra escapa a la segunda).
# La paridad vale para TODOS los caracteres con significado, no solo para `$(`, y eso no
# es simetria decorativa: un `\)` es un parentesis LITERAL y no cierra nada, asi que
# tratarlo como cierre partia el fragmento antes de tiempo y perdia la redireccion.
# Medido en un sandbox real: `$(echo \) > src/x.ts)` CREA el archivo. Es la misma familia
# que QA-015 y se cierra en el mismo sitio.
# Los acentos graves NO reciben este trato a proposito: un acento escapado cambia la
# PAREJA de todos los demas, y equivocarse ahi produce un falso NEGATIVO. Se prefiere el
# falso positivo.
#
# FUERA DE ALCANCE, dicho en voz alta (cobertura parcial, AGENTS.md 13):
#   - Una sustitucion que ABRE en una linea y CIERRA en otra aporta solo el resto de SU
#     linea (si la profundidad no vuelve a cero, se toma hasta el final): se ve el
#     comando que la abre, no lo que siga en las lineas siguientes.
#   - Los acentos graves NO entran en la cuenta de profundidad: se siguen leyendo por
#     PAREJAS sobre la linea, y del interior de cada pareja se toma todo. Un acento sin
#     pareja abre y llega al final de la linea. Es el trato de siempre y se mantiene a
#     proposito: un acento escapado cambia la pareja de todos los demas (ver arriba).
#   - Un byte `\001` en la linea se neutraliza a un espacio antes de marcar: es el
#     separador interno del troceado y no puede venir del texto sin confundir los atomos.
# Anota UN fragmento ejecutable. El descuento de comillas solo se llama cuando el
# fragmento LLEVA comillas: en un cuerpo denso en expansiones se pagaba una llamada a
# funcion por fragmento, y la llamada costaba mas que el trabajo. Lo usa el camino de los
# acentos graves; el de `$( )` ya entrega el fragmento descontado por construccion.
_arnes_frag() {   # <interior de la expansion>
  case "$1" in
    *\"*|*\'*) _arnes_desentrecomilla "$1"; ARNES_EXPS+=("$ARNES_SINCOM") ;;
    *)          ARNES_EXPS+=("$1") ;;
  esac
}

_arnes_expansiones() {   # <linea del cuerpo> -> acumula fragmentos en ARNES_EXPS
  local linea="$1" s i np ty tx ch prof q nbs
  local -a p frag qbuf
  local reponer_f=0; case $- in *f*) reponer_f=1 ;; esac
  local IFS
  if [[ "$linea" == *'$('* ]]; then
    # Marcado. El ORDEN no es cosmetico: la barra invertida va primero para poder leer
    # su paridad delante de un `$(`, y `$(` antes que `(` suelto para no partirlo en dos.
    # Las sustituciones que no tocan nada se saltan con un `case`, que no copia la cadena.
    s="$linea"
    case "$s" in *$'\001'*) s="${s//$'\001'/ }" ;; esac
    case "$s" in *\\*)      s="${s//\\/$'\001'B}" ;; esac
    s="${s//'$('/$'\001'D}"
    case "$s" in *'('*)     s="${s//'('/$'\001'A}" ;; esac
    s="${s//')'/$'\001'C}"
    case "$s" in *'"'*)     s="${s//'"'/$'\001'Q}" ;; esac
    case "$s" in *"'"*)     s="${s//"'"/$'\001'S}" ;; esac
    IFS=$'\001'; set -f
    # shellcheck disable=SC2206  -- se quiere el troceado por IFS, con globbing apagado
    p=($s)
    [ "$reponer_f" -eq 1 ] || set +f
    np=${#p[@]}
    # `prof` = profundidad de parentesis del fragmento abierto (0 = fuera de todo
    # fragmento). `q` = comilla abierta DENTRO del fragmento. `nbs` = barras invertidas
    # pegadas justo antes del atomo actual, para la paridad del escape.
    prof=0; q=''; nbs=0; frag=(); qbuf=()
    # El cuerpo del bucle esta escrito para NO copiar texto que no se vaya a usar:
    # `${p[i]:1}` COPIA la cola del atomo, asi que solo se pide en las ramas que la
    # necesitan. La rama mas frecuente —el `)` que cierra de verdad el fragmento— no la
    # pide: lo que sigue al cierre es texto del cuerpo y ya no es de nadie.
    for ((i = 1; i < np; i++)); do
      ty="${p[i]:0:1}"
      if [ -n "$q" ]; then
        # Dentro de comillas todo es literal: ni abre, ni cierra, ni cuenta profundidad.
        # Lo entrecomillado se guarda aparte y se TIRA al cerrar la comilla (ese es el
        # descuento); solo vuelve si la comilla resulta ser IMPAR (al final del bucle).
        nbs=0
        if [ "$ty" = "$q" ]; then q=''; qbuf=(); frag+=("${p[i]:1}")
        else
          case $ty in
            B) ch='\' ;;  D) ch='$(' ;;  A) ch='(' ;;
            C) ch=')' ;;  Q) ch='"' ;;   S) ch="'" ;;
            *) continue ;;
          esac
          qbuf+=("$ch${p[i]:1}")
        fi
        continue
      fi
      case $ty in
        D) if (( nbs % 2 )); then                    # `\$(` es texto, no sustitucion
             nbs=0; (( prof > 0 )) && frag+=("\$(${p[i]:1}")
           elif (( prof == 0 )); then
             nbs=0; prof=1; frag=("${p[i]:1}")       # abre: el estado de comillas nace limpio
           else
             nbs=0; prof=$((prof + 1)); frag+=("\$(${p[i]:1}")
           fi ;;
        C) if (( nbs % 2 )); then                    # `\)` NO cierra: es un parentesis literal
             nbs=0; (( prof > 0 )) && frag+=(")${p[i]:1}")
           else
             nbs=0
             if (( prof > 0 )); then
               prof=$((prof - 1))
               if (( prof == 0 )); then              # este SI es el cierre real
                 IFS=''; ARNES_EXPS+=("${frag[*]}"); IFS=$'\001'; frag=()
               else frag+=(")${p[i]:1}"); fi
             fi
           fi ;;
        B) tx="${p[i]:1}"; nbs=$((nbs + 1)); [ -z "$tx" ] || nbs=0
           (( prof > 0 )) && frag+=("\\$tx") ;;
        A) if (( nbs % 2 )); then nbs=0; (( prof > 0 )) && frag+=("(${p[i]:1}")
           else nbs=0; (( prof > 0 )) && { prof=$((prof + 1)); frag+=("(${p[i]:1}"); }
           fi ;;
        Q) if (( nbs % 2 )); then nbs=0; (( prof > 0 )) && frag+=("\"${p[i]:1}")
           else nbs=0; (( prof > 0 )) && { q=Q; qbuf=("\"${p[i]:1}"); }
           fi ;;
        S) if (( nbs % 2 )); then nbs=0; (( prof > 0 )) && frag+=("'${p[i]:1}")
           else nbs=0; (( prof > 0 )) && { q=S; qbuf=("'${p[i]:1}"); }
           fi ;;
      esac
    done
    if (( prof > 0 )); then     # no cerro en esta linea -> se analiza el resto, entero
      [ -z "$q" ] || frag+=("${qbuf[@]}")
      IFS=''; ARNES_EXPS+=("${frag[*]}")
    fi
  fi
  if [[ "$linea" == *'`'* ]]; then
    IFS='`'; set -f
    # shellcheck disable=SC2206
    p=($linea$'\001')
    [ "$reponer_f" -eq 1 ] || set +f
    np=${#p[@]}
    p[np - 1]="${p[np - 1]%$'\001'}"
    for ((i = 1; i < np; i += 2)); do             # impares: lo que va entre pareja y pareja
      _arnes_frag "${p[i]}"
    done
  fi
}

arnes_bash_escrituras() {  # <comando> -> rutas escritas, una por línea
  #
  # Devuelve 0 con las rutas (ninguna, una o varias) y `$ARNES_RC_EXCESO` (2) SIN
  # ANALIZAR NADA cuando el material a analizar supera el presupuesto: ver
  # `ARNES_BASH_MAX_ANALISIS`. Los dos guardianes traducen ese 2 a una denegacion con
  # motivo. Un `return 2` nunca sale por la salida estandar, asi que un llamador que
  # ignore el codigo ve una lista vacia: eso seria permitir, y por eso los dos
  # llamadores lo miran (y hay caso de banco para cada uno).
  local cmd="$1" limpio i j n tok
  local ARNES_SINCOM=''
  local -a ARNES_EXPS=()
  # IFS explicito: el troceado en palabras de esta funcion (y el de sus auxiliares) no
  # puede depender de como lo haya dejado el llamador.
  local IFS=$' \t\n'
  # Presupuesto: bytes de material que SI se analiza con coste. Se acumula aqui.
  local analizado=0 max_analisis="$ARNES_BASH_MAX_ANALISIS" exceso=0
  # Las dos limpiezas se hacen SIN procesos. Antes eran dos `printf | sed`, o sea
  # cuatro bifurcaciones, y este camino se recorre en CADA comando de shell que
  # ejecuta un agente — el más frecuente de todos.
  #
  # 1) Fuera el texto entrecomillado, para que una ruta mencionada dentro de un
  #    mensaje (`git commit -m "toca src/a.ts"`) no dispare nada. Se recorta por
  #    pares de comillas en un bucle, que es lo que bash sabe hacer sin regex.
  limpio="$cmd"
  # 0) Fuera el CUERPO de cada heredoc. Medido (1.29.1, proyecto real): un comando cuyo
  #    resumen en heredoc contenia la linea `cp README.md src/...` COMO TEXTO fue
  #    denegado; el detector leia el cuerpo como si fuera el comando. Reproducido con
  #    `cp`, con `>` y con `tee` dentro del cuerpo. Un heredoc es texto que se ENTREGA
  #    a un comando, igual que lo entrecomillado: se descuenta igual, y ANTES que las
  #    comillas, porque el delimitador puede ir entrecomillado (`<<'EOF'`).
  #    Solo cuenta como heredoc `<<` o `<<-` seguido de una PALABRA (EOF, PY, END...):
  #    `<<<` es una here-string y `1<<2` es aritmetica, y un delimitador que no fuera
  #    palabra tragaria el resto del comando —fallo abierto—. Sin procesos.
  #
  #    PERO EL CUERPO NO SIEMPRE ES TEXTO, y esto era un fallo en abierto medido en
  #    1.30.2 por una revision externa: con el delimitador SIN CITAR (`<<EOF`) bash
  #    ejecuta de verdad las sustituciones `$( ... )` y los acentos graves del cuerpo,
  #    asi que `$(echo x > src/generated.ts)` creaba el archivo y ninguna puerta lo
  #    veia. Con el delimitador CITADO o ESCAPADO (`<<'EOF'`, `<<"EOF"`, `<<\EOF`) el
  #    cuerpo si es literal entero, exactamente como en el shell real.
  #    Por eso, sin citar, se conserva SOLO EL INTERIOR de cada `$( ... )` y de cada par
  #    de acentos graves (ver `_arnes_expansiones`); el resto del cuerpo se descuenta como
  #    antes. Conservar la LINEA ENTERA que lleva la expansion —como hizo el primer
  #    arreglo— devuelve el falso positivo de 1.29.1 por otra puerta, y ademas mete en el
  #    analisis comillas que en el cuerpo son texto (ver `_arnes_desentrecomilla`).
  #    Las limitaciones de este recorte estan escritas en `_arnes_expansiones`.
  if [[ "$limpio" == *'<<'* ]]; then
    local linea delim='' dentro=0 citado=0 resto sinhs
    local -a sin=()
    while IFS= read -r linea || [ -n "$linea" ]; do
      if [ "$dentro" -eq 1 ]; then
        resto="${linea#"${linea%%[![:blank:]]*}"}"     # `<<-` admite sangria delante del cierre
        if [ "$resto" = "$delim" ]; then dentro=0; continue; fi
        if [ "$citado" -eq 0 ]; then
          case "$linea" in
            *'$('*|*'`'*)
              # PRESUPUESTO, antes de analizar la linea y no despues: pasado el techo se
              # deja de trabajar. Asi el coste total queda acotado por el propio techo, y
              # no por el tamano de la entrada (que lo elige quien la escribe).
              if (( analizado + ${#linea} > max_analisis )); then
                arnes_techo_bash; max_analisis="$ARNES_TECHO"
                if (( analizado + ${#linea} > max_analisis )); then exceso=1; break; fi
              fi
              analizado=$(( analizado + ${#linea} ))
              _arnes_expansiones "$linea" ;;
          esac
        fi
        continue
      fi
      sin+=("$linea")
      sinhs="${linea//<<</ }"
      case "$sinhs" in
        *'(('*'<<'*) ;;                                  # `$((1<<n))` es aritmetica, no heredoc
        *'<<'*)
        resto="${sinhs#*<<}"; resto="${resto#-}"
        resto="${resto#"${resto%%[! ]*}"}"             # espacios entre `<<` y la palabra
        # Citado o escapado -> cuerpo literal. Se anota ANTES de pelar las comillas,
        # que es justo la marca que las distingue.
        citado=0; case "$resto" in \'*|\"*|\\*) citado=1 ;; esac
        delim="${resto%%[[:space:]\;\|\&\)\<\>]*}"
        delim="${delim#\'}"; delim="${delim%\'}"; delim="${delim#\"}"; delim="${delim%\"}"
        delim="${delim#\\}"
        # Una PALABRA: empieza por letra o `_` (EOF, PY, END, SQL...). `1<<2` da `2` y no lo es.
        case "$delim" in
          [A-Za-z_]*) case "$delim" in *[!A-Za-z0-9_]*) delim='' ;; *) dentro=1 ;; esac ;;
          *) delim='' ;;
        esac ;;
      esac
    done <<< "$limpio"
    IFS=$'\n'; limpio="${sin[*]}"; IFS=$' \t\n'
  fi
  # Segundo sumando del presupuesto: el texto de comando que queda FUERA de los cuerpos
  # de heredoc. Es el que recorre el camino comun, y tiene su propio acantilado.
  if [ "$exceso" -eq 0 ] && (( analizado + ${#limpio} > max_analisis )); then
    arnes_techo_bash; max_analisis="$ARNES_TECHO"
    (( analizado + ${#limpio} > max_analisis )) && exceso=1
  fi
  [ "$exceso" -eq 0 ] || return "$ARNES_RC_EXCESO"
  # El comando REAL se desentrecomilla de una pieza —igual que antes, para no cambiar su
  # conducta— y los fragmentos ejecutables del cuerpo se le añaden YA descontados, cada uno
  # por su cuenta. La frontera del heredoc no se cruza en ninguna direccion.
  _arnes_desentrecomilla "$limpio"; limpio="$ARNES_SINCOM"
  # `;` como pegamento: el tokenizador de mas abajo ya lo separa (`${limpio//;/ ; }`) y
  # es lo que impide que el operando de un fragmento se lea como operando del siguiente.
  if [ "${#ARNES_EXPS[@]}" -gt 0 ]; then IFS=';'; limpio+=" ; ${ARNES_EXPS[*]}"; IFS=$' \t\n'; fi
  # 2) Separa los operadores de su operando: `>src/a.ts` -> `> src/a.ts`.
  #    Y las sustituciones de comando pierden sus parentesis, para que el destino de
  #    `$(echo x > src/a.ts)` quede como operando limpio de `>` y no como `src/a.ts)`,
  #    que no casaria con ningun glob —fallo abierto—. El patron va entrecomillado
  #    para que `$(` sea texto, no una expansion.
  limpio="${limpio//'$('/ }"
  limpio="${limpio//)/ }"
  limpio="${limpio//>|/>}"
  limpio="${limpio//>>/>}"
  limpio="${limpio//>/ > }"
  limpio="${limpio//|/ | }"
  limpio="${limpio//;/ ; }"

  local reponer_f=0
  case $- in *f*) reponer_f=1 ;; esac
  set -f
  # shellcheck disable=SC2206  -- se quiere el word splitting, con globbing apagado
  local -a t=($limpio)
  [ "$reponer_f" -eq 1 ] || set +f

  n=${#t[@]}
  _arnes_es_separador() { case "$1" in '>'|'|'|';'|'&&'|'||'|'&') return 0 ;; *) return 1 ;; esac; }
  _arnes_emite() { [ -n "${1:-}" ] && ! _arnes_es_separador "$1" && printf '%s\n' "$1"; }

  for ((i = 0; i < n; i++)); do
    tok="${t[i]}"
    case "$tok" in
      '>')
        _arnes_emite "${t[i + 1]:-}" ;;
      tee|*/tee)
        for ((j = i + 1; j < n; j++)); do
          _arnes_es_separador "${t[j]}" && break
          case "${t[j]}" in -*) continue ;; esac
          _arnes_emite "${t[j]}"
        done ;;
      cp|mv|install|*/cp|*/mv|*/install)
        # El destino es el último operando del segmento; se prueba también su forma
        # de directorio (`cp x src` debe casar con el glob `src/*`).
        local dest=""
        for ((j = i + 1; j < n; j++)); do
          _arnes_es_separador "${t[j]}" && break
          case "${t[j]}" in -*) continue ;; esac
          dest="${t[j]}"
        done
        if [ -n "$dest" ]; then
          _arnes_emite "$dest"
          case "$dest" in */) ;; *) _arnes_emite "$dest/" ;; esac
        fi ;;
      sed|perl|*/sed|*/perl)
        local en_sitio=0
        for ((j = i + 1; j < n; j++)); do
          _arnes_es_separador "${t[j]}" && break
          # Sólo cuenta como in-place `--in-place[=x]` o un flag corto con `i`
          # (`-i`, `-i.bak`, `-pi`). `--expression` también lleva una `i` y NO lo es.
          case "${t[j]}" in
            --in-place|--in-place=*) en_sitio=1 ;;
            --*) : ;;
            -*i*) en_sitio=1 ;;
          esac
        done
        [ "$en_sitio" -eq 1 ] || continue
        for ((j = i + 1; j < n; j++)); do
          _arnes_es_separador "${t[j]}" && break
          case "${t[j]}" in -*) continue ;; esac
          _arnes_emite "${t[j]}"
        done ;;
      of=*)
        _arnes_emite "${tok#of=}" ;;
    esac
  done
  return 0
}

# --- Campos de cabecera del REQ ---------------------------------------------
# Normaliza un valor de campo: minúsculas, sin espacios ni CR, y con la tilde de
# "sí" plegada. La versión anterior era `printf | tr | tr` — tres procesos.
#
# EL PLIEGUE DE LA TILDE CORRIGE UN FALLO ABIERTO QUE YA EXISTÍA. La conversión a
# minúsculas trabaja byte a byte y, sin locale definido, no toca la `Í`: un REQ
# que declarara `Sensible a seguridad: SÍ` quedaba como `sÍ`, NO casaba con
# `sí|si`, y se saltaba la puerta de seguridad EN SILENCIO. Plegar el acento deja
# una sola forma cerrada (`si`) contra la que comparar, en vez de una lista de
# variantes que se pudre — que es justo lo que este arnés predica.
# Retira el enfasis de Markdown SOLO cuando envuelve el valor entero (pareado).
# Vive aparte porque hace falta en dos momentos: al normalizar el campo, y otra vez
# tras quitar un parentesis final -- porque `**aprobado** (medido)` no esta envuelto
# hasta que el parentesis desaparece.
arnes_desenvuelve() {   # <valor> -> ARNES_DESENV
  local v="$1" antes
  while :; do
    antes="$v"
    case "$v" in
      '**'*'**') v="${v#\*\*}"; v="${v%\*\*}" ;;
      '__'*'__') v="${v#__}";   v="${v%__}"   ;;
      '*'*'*')   v="${v#\*}";   v="${v%\*}"   ;;
      '_'*'_')   v="${v#_}";    v="${v%_}"    ;;
      '`'*'`')   v="${v#\`}";   v="${v%\`}"   ;;
    esac
    [ "$v" != "$antes" ] || break
  done
  ARNES_DESENV="$v"
}

arnes_norm_campo() {   # <valor> -> ARNES_CAMPO
  local v="${1//$'\r'/}"
  # El MARCADO no es parte del valor. `**sí**` es el mismo valor que `sí`: el
  # énfasis lo pone quien escribe para que se lea bonito, no para decir otra cosa.
  # Medido: siete REQ de un proyecto real declaraban `Sensible a seguridad: **sí**`
  # y NINGUNO casaba, así que la puerta de seguridad no llegó a existir para ellos.
  # Esto NO es una lista de variantes del valor —que se pudre—: es quitar sintaxis
  # de Markdown, que es un conjunto cerrado y ajeno al dominio.
  #
  # PERO SOLO CUANDO ENVUELVE EL VALOR ENTERO, y esto se pago aprendiendo: retirar
  # todo `*` suelto convertia `Seguridad: aprobado*` en `aprobado`. Un asterisco tras
  # una firma no es adorno, es una LLAMADA A NOTA AL PIE, y una nota al pie apunta a
  # una salvedad -- lo contrario de una firma incondicional.
  #
  # El enfasis de Markdown es PAREADO por definicion: abre y cierra. Un asterisco
  # suelto nunca lo es. Asi que `**si**` se desenvuelve y `aprobado*` se respeta, y
  # el argumento de arriba sigue en pie sin abrir una puerta nueva.
  v="${v// /}"
  arnes_desenvuelve "$v"; v="$ARNES_DESENV"
  v="${v//Í/i}"; v="${v//í/i}"
  ARNES_CAMPO="${v,,}"
}

# UN PARENTESIS FINAL ES EVIDENCIA, Y LA EVIDENCIA NO CAMBIA EL VEREDICTO.
#
# La convencion que hace valioso a este arnes es que el veredicto lleve al lado lo
# que lo sostiene: `QA: aprobado (medido el 3/9, 42 pruebas)`. Comparar contra la
# palabra exacta obligaba a elegir entre que el hook funcione o que la evidencia
# viva en el encabezado del REQ -- y quitar la evidencia seria destruir justo lo
# que el arnes viene a dar. Medido en un proyecto real: 26 REQ paralizados.
#
# La primera version metia el matiz DENTRO del parentesis --`aprobado (preventiva)`--
# y eso creaba una ambiguedad imposible: el mismo signo significaba "evidencia" en
# un caso y "matiz que invierte el veredicto" en el otro. Cortar servia a uno y
# rompia al otro.
#
# La ambiguedad era un error de diseño, y se QUITA en vez de arbitrarse: un matiz
# que cambia el veredicto ES OTRO VEREDICTO, no un parentesis. Por eso `preventiva`
# pasa a ser su propio valor. Ahora el parentesis significa una sola cosa.
#
# Se exige que el parentesis sea FINAL y BALANCEADO, la misma leccion que el
# enfasis pareado: `aprobado(medido)` -> `aprobado`; `aprobado(sin cerrar` se
# respeta tal cual, porque no es un parentesis, es texto.
#
# Riesgo residual, dicho en voz alta: `aprobado (con reservas)` contaria como
# aprobado. Es una violacion de la convencion --el matiz debe ser un veredicto--
# y no un agujero silencioso: esta escrito en la plantilla y en la ficha de los
# dos agentes que firman.
arnes_veredicto() {   # <valor normalizado> -> ARNES_VEREDICTO
  local v="$1"
  case "$v" in
    *')') case "$v" in *'('*) v="${v%%(*}" ;; esac ;;
  esac
  # Y se desenvuelve OTRA VEZ. Medido por dos proyectos: `aprobado (medido)` contaba
  # y `**aprobado** (medido)` no, porque al normalizar el enfasis no envolvia el
  # valor entero -- el parentesis estaba detras. Mismo valor, dos escrituras,
  # veredictos opuestos: la misma asimetria que `n/a` / `no aplica`.
  arnes_desenvuelve "$v"; v="$ARNES_DESENV"
  ARNES_VEREDICTO="$v"
}

# `Sensible a seguridad:` es un BOOLEANO tecleado a mano dentro de un Markdown.
#
# Su población no es {si,no}: es lo que a un agente le dé por escribir en una
# cabecera. Una forma cerrada sólo funciona si algo obliga a producirla, y aquí no
# hay nada que lo obligue —el sujeto del control es más estrecho que su población—,
# así que perseguirlo añadiendo variantes es la lista enumerada que se pudre.
#
# El arreglo estructural es otro: TRES estados, y el tercero cae del lado seguro.
# Un valor presente que no se entiende NO significa «no es sensible», significa «no
# lo sé», y no saber se resuelve pidiendo la auditoría, no saltándosela. Antes el
# `*)` del `case` decía «no» en silencio: es exactamente la regla que
# `/arnes-upgrade` aplica a `UNKNOWN` —una comprobación que no puede responder no
# dice «no sé», dice «sí»— y que aquí faltaba.
#
# AUSENTE sigue siendo «no», y eso no se toca: exigir auditoría a todo REQ que no
# declara el campo rompería cualquier proyecto anterior a que el campo existiera.
arnes_sens_efectiva() {   # ARNES_SENS -> si|no ; ARNES_SENS_DUDOSA -> 0|1
  local corte
  ARNES_SENS_DUDOSA=0; ARNES_SENS_CRUDO="$ARNES_SENS"
  if [ -z "$ARNES_SENS" ]; then ARNES_SENS='no'; return 0; fi
  # Un comentario tras el valor no es el valor: `sí — gobierna la puerta…`.
  # El paréntesis se corta AQUÍ y no en `arnes_norm_campo`, porque
  # `Seguridad: aprobado (preventiva)` necesita conservarlo: cortarlo allí
  # convertiría una auditoría preventiva en una firma completa.
  corte="$ARNES_SENS"
  corte="${corte%%—*}"; corte="${corte%%–*}"; corte="${corte%%-*}"
  corte="${corte%%(*}"; corte="${corte%%[*}"; corte="${corte%%,*}"; corte="${corte%%;*}"
  # LA GENEROSIDAD VA DE UN SOLO LADO, y esto tambien se pago aprendiendo.
  #
  # El conjunto que ABRE la puerta tiene que ser minimo e inequivoco; el que la
  # cierra puede ser generoso, porque equivocarse ahi no cuesta nada. La primera
  # version metia `n/a` y `ninguna` entre los negativos, y eso es exactamente lo que
  # alguien escribe cuando NO HA CLASIFICADO -- no cuando ha decidido que no es
  # sensible. Esas dos entradas le abrian un hueco a la regla de fallo cerrado justo
  # en el caso para el que se construyo.
  #
  # Lo delataba una asimetria: `n/a` abria la puerta y `no aplica`, que es la misma
  # frase, la cerraba. Alargar la lista para taparlo seria la lista enumerada que se
  # pudre; lo correcto es que SOLO UNA NEGACION EXPLICITA abra. Ahora las dos formas
  # coinciden, y ninguna abre.
  case "$corte" in
    si|s|true|x|yes|verdadero)  ARNES_SENS='si' ;;
    no|n|false)                 ARNES_SENS='no' ;;
    *) ARNES_SENS='si'; ARNES_SENS_DUDOSA=1 ;;
  esac
}

# La cola de normalizacion de arnes_campos_req, separada para que el bloque derivado
# --que extrae los campos con UNA pasada de awk sobre todos los REQ-- pase por EL MISMO
# camino que la puerta. Dos normalizadores se desfasan; uno solo, no.
arnes_campos_normaliza() {   # <qa> <seg> <sens> <hall> <rigor> -> ARNES_QA/SEG/SENS/HALL/RIGOR
  arnes_norm_campo "$1"; arnes_veredicto "$ARNES_CAMPO"; ARNES_QA="$ARNES_VEREDICTO"
  arnes_norm_campo "$2"; arnes_veredicto "$ARNES_CAMPO"; ARNES_SEG="$ARNES_VEREDICTO"
  arnes_norm_campo "$3"; ARNES_SENS="$ARNES_CAMPO"
  arnes_norm_campo "$4"; ARNES_HALL="$ARNES_CAMPO"
  arnes_norm_campo "$5"; ARNES_RIGOR="$ARNES_CAMPO"
  arnes_sens_efectiva
  arnes_rigor_efectivo
}

# Extrae en UNA pasada los campos de cabecera del REQ que gobiernan el cierre.
#
# RENDIMIENTO. La versión anterior leía cada campo con `printf | sed | head`
# —tres procesos y dos tuberías para sacar una línea de un texto que YA está en
# memoria— y se invocaba cinco veces, con una rama de respaldo que podía
# duplicarlo. Medido en esta máquina: 5.116 ms por campo contra 326 ms leyendo en
# bash. Era, con diferencia, el punto más caro de todo el enforcement.
#
# Precedencia idéntica a la anterior: se prefiere el contenido ENTRANTE y se
# respalda en el del disco (pre-edición), porque QA y seguridad fijan su veredicto
# antes de la transición a completado. Por eso se recorre primero el disco y
# después lo entrante: lo segundo pisa a lo primero.
arnes_campos_req() {   # <texto en disco> <texto entrante>
  ARNES_QA=''; ARNES_SEG=''; ARNES_SENS=''; ARNES_HALL=''; ARNES_RIGOR=''
  local texto l
  for texto in "$1" "$2"; do
    [ -n "$texto" ] || continue
    while IFS= read -r l; do
      # LOS CAMPOS VALEN SOLO EN LA CABECERA: antes del primer `## `. Medido: una linea
      # `Seguridad: aprobado (A-009, 2026-09-02)` dentro de `## Historial de cambios` se
      # leia como EL veredicto y cerraba un REQ critico cuya cabecera decia `pendiente`.
      # Es la familia de `**si**`: la maquina lee algo distinto de lo que la cabecera
      # declara. La regla es estructural --lo que dice la plantilla-- y no depende del
      # nombre de ninguna seccion, que seria mapeo del proyecto.
      case "$l" in '## '*) break ;; esac
      case "$l" in
        'QA:'*)                   ARNES_QA="${l#QA:}" ;;
        'Seguridad:'*)            ARNES_SEG="${l#Seguridad:}" ;;
        'Sensible a seguridad:'*) ARNES_SENS="${l#Sensible a seguridad:}" ;;
        'Hallazgos abiertos:'*)   ARNES_HALL="${l#Hallazgos abiertos:}" ;;
        'Rigor:'*)                ARNES_RIGOR="${l#Rigor:}" ;;
      esac
    done <<< "$texto"
  done
  arnes_campos_normaliza "$ARNES_QA" "$ARNES_SEG" "$ARNES_SENS" "$ARNES_HALL" "$ARNES_RIGOR"
}

# `Estado:` de la CABECERA de un documento, normalizado y sin su parentesis de
# evidencia. La PRIMERA aparicion manda, como en campos-req.awk: la cabecera declara
# el estado una vez. Existe para juzgar la transicion sobre el documento RESULTANTE,
# no sobre el fragmento editado (ver guard-completado.sh).
arnes_estado_cabecera() {   # <texto> -> ARNES_ESTADO
  ARNES_ESTADO=''
  local l
  while IFS= read -r l; do
    case "$l" in '## '*) break ;; esac
    case "$l" in 'Estado:'*)
      arnes_norm_campo "${l#Estado:}"; arnes_veredicto "$ARNES_CAMPO"; ARNES_ESTADO="$ARNES_VEREDICTO"
      return 0 ;;
    esac
  done <<< "$1"
}

# Nivel de rigor con el que se juzga este REQ.
#
# EL VALOR POR DEFECTO REPRODUCE EXACTAMENTE EL COMPORTAMIENTO ANTERIOR. Un REQ
# que no declare `Rigor:` se juzga como siempre: si esta marcado
# `Sensible a seguridad: si` se le exige auditoria, y si no, no. Asi un proyecto
# que no haya migrado no nota NINGUN cambio — y la velocidad que dan los niveles
# se gana con un acto deliberado, nunca por sorpresa.
#
# El arnes trae el MECANISMO, no el MAPEO: que REQ de un proyecto es critico lo
# decide ese proyecto en su `AGENTS.md`, no el plugin.
arnes_rigor_efectivo() {
  local declarado="$ARNES_RIGOR" nd ns
  # SUELO DE SEGURIDAD: `Sensible a seguridad: si` obliga a `critico` y eso no se
  # puede bajar. Un REQ que NO es sensible no tiene suelo.
  #
  # Es distinto del VALOR POR DEFECTO, y confundirlos hace que `ligero` no pueda
  # activarse nunca: si el defecto de un REQ no sensible fuera tambien un suelo,
  # cualquier declaracion mas baja quedaria anulada y el nivel no serviria para
  # nada. El suelo limita hacia abajo; el defecto solo aplica si no hay nada
  # declarado.
  if [ -z "$declarado" ]; then
    # Nada declarado -> se juzga EXACTAMENTE como antes de existir los niveles.
    case "$ARNES_SENS" in
      si) ARNES_RIGOR='critico' ;;
      *)  ARNES_RIGOR='estandar' ;;
    esac
    return 0
  fi

  arnes_rigor_nivel "$declarado"; nd=$?
  if [ "$nd" -eq 0 ]; then
    # Valor no reconocido: se ignora y se cae al comportamiento de siempre.
    case "$ARNES_SENS" in
      si) ARNES_RIGOR='critico' ;;
      *)  ARNES_RIGOR='estandar' ;;
    esac
    return 0
  fi

  # Declarado y valido. Sube libremente; bajar del suelo de seguridad, no.
  ARNES_RIGOR="$declarado"
  case "$ARNES_SENS" in
    si) arnes_rigor_nivel critico; ns=$?
        [ "$nd" -lt "$ns" ] && ARNES_RIGOR='critico' ;;
  esac
  return 0
}

# Orden de los niveles como codigo de retorno: ligero(1) < estandar(2) < critico(3).
# Un valor no reconocido vale 0, asi que nunca puede ganarle a lo derivado.
arnes_rigor_nivel() {
  case "$1" in
    ligero)   return 1 ;;
    estandar) return 2 ;;
    critico)  return 3 ;;
    *)        return 0 ;;
  esac
}
