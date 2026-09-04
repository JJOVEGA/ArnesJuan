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
                                       (.pending_approval // "PENDING_APPROVAL.md")]
                                      + (.codigo_app.globs // []) | .[]'
  ARNES_GLOBS=()
  { IFS= read -r ARNES_AGENTE_CODIGO; IFS= read -r ARNES_REQ_DIR
    IFS= read -r ARNES_ESTADO_DONE;   IFS= read -r ARNES_PENDING
    while IFS= read -r g; do [ -n "$g" ] && ARNES_GLOBS+=("$g"); done
  } <<< "$ARNES_JQ"
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
arnes_bash_escrituras() {  # <comando> -> rutas escritas, una por línea
  local cmd="$1" limpio i j n tok pre post q
  # Las dos limpiezas se hacen SIN procesos. Antes eran dos `printf | sed`, o sea
  # cuatro bifurcaciones, y este camino se recorre en CADA comando de shell que
  # ejecuta un agente — el más frecuente de todos.
  #
  # 1) Fuera el texto entrecomillado, para que una ruta mencionada dentro de un
  #    mensaje (`git commit -m "toca src/a.ts"`) no dispare nada. Se recorta por
  #    pares de comillas en un bucle, que es lo que bash sabe hacer sin regex.
  limpio="$cmd"
  for q in '"' "'"; do
    while [[ "$limpio" == *"$q"*"$q"* ]]; do
      pre="${limpio%%"$q"*}"
      post="${limpio#*"$q"}"; post="${post#*"$q"}"
      limpio="$pre $post"
    done
  done
  # 2) Separa los operadores de su operando: `>src/a.ts` -> `> src/a.ts`.
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
arnes_norm_campo() {   # <valor> -> ARNES_CAMPO
  local v="${1//$'\r'/}"
  v="${v// /}"
  v="${v//Í/i}"; v="${v//í/i}"
  ARNES_CAMPO="${v,,}"
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
      case "$l" in
        'QA:'*)                   ARNES_QA="${l#QA:}" ;;
        'Seguridad:'*)            ARNES_SEG="${l#Seguridad:}" ;;
        'Sensible a seguridad:'*) ARNES_SENS="${l#Sensible a seguridad:}" ;;
        'Hallazgos abiertos:'*)   ARNES_HALL="${l#Hallazgos abiertos:}" ;;
        'Rigor:'*)                ARNES_RIGOR="${l#Rigor:}" ;;
      esac
    done <<< "$texto"
  done
  arnes_norm_campo "$ARNES_QA";   ARNES_QA="$ARNES_CAMPO"
  arnes_norm_campo "$ARNES_SEG";  ARNES_SEG="$ARNES_CAMPO"
  arnes_norm_campo "$ARNES_SENS"; ARNES_SENS="$ARNES_CAMPO"
  arnes_norm_campo "$ARNES_HALL"; ARNES_HALL="$ARNES_CAMPO"
  arnes_norm_campo "$ARNES_RIGOR"; ARNES_RIGOR="$ARNES_CAMPO"
  arnes_rigor_efectivo
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
