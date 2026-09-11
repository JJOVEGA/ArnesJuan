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
  local g rc
  ARNES_MANIFEST_ROTO=0
  # `if type != "object" then error` NO es adorno: un manifiesto que es `null`, un array o
  # un numero es JSON VALIDO y jq lo atravesaria devolviendo los valores por defecto y una
  # lista de globs VACIA — es decir, un proyecto sin nada protegido, en silencio. Aqui la
  # unica lectura aceptable es un OBJETO; cualquier otra cosa es "no se puede leer".
  # EL TIPO LO DECIDE EL JSON, NO LA FORMA DEL TEXTO, Y VALE PARA TODAS LAS CLAVES.
  #
  # `"exigir_fecha": "true"` (una cadena) apagaba la puerta EN SILENCIO mientras el techo
  # de Bash si avisaba ante el MISMO error de tipo (QA-106/QA-107). La regla es una sola y
  # ahora se aplica igual a todas: lo que no tiene el tipo que esa clave espera cae al
  # valor por defecto del arnes Y SE DICE, nombrando la clave y el valor recibido. Caer del
  # lado seguro esta bien; hacerlo sin decirlo deja al proyecto creyendo que declaro algo.
  #
  # Alcance: las claves HOJA que leen las puertas. Si el CONTENEDOR es de otro tipo
  # (`"veredictos": "x"`), jq falla al indexarlo y el manifiesto entero se declara
  # ilegible — el fail-closed de SEC-005, que aqui no se toca.
  arnes_jq_file "$ARNES_MANIFEST" --arg gitdef "$ARNES_GIT_PROHIBIDOS_DEFECTO" \
                                  -r 'if type != "object" then error("no-objeto") else . end
                                      | . as $m
                                      | [(if ($m.agentes.agente_codigo|type) == "string" then $m.agentes.agente_codigo else "desarrollador" end),
                                       (if ($m.requirements_dir|type) == "string" then $m.requirements_dir else "requirements" end),
                                       (if ($m.estados.completado|type) == "string" then $m.estados.completado else "completado" end),
                                       (if ($m.pending_approval|type) == "string" then $m.pending_approval else "PENDING_APPROVAL.md" end),
                                       (if   ($m.limites.bash_max_analisis|type) == "number" then ($m.limites.bash_max_analisis|tostring)
                                        elif  $m.limites.bash_max_analisis == null           then ""
                                        else  "!tipo" end),
                                       (if $m.veredictos.exigir_fecha == true then "true" else "false" end),
                                       (if $m.veredictos.caducan_con_codigo == true then "true" else "false" end),
                                       (if $m.campos.ausencia_exige == true then "true" else "false" end),
                                       (if $m.git.activo == false then "false" else "true" end),
                                       ((if ($m.git.prohibidos|type) == "array" then $m.git.prohibidos
                                         else ($gitdef | split("\t")) end)
                                        | map(select(type == "string")) | join("\t")),
                                       ([["agentes.agente_codigo",        $m.agentes.agente_codigo,         "string"],
                                         ["requirements_dir",             $m.requirements_dir,              "string"],
                                         ["estados.completado",           $m.estados.completado,            "string"],
                                         ["pending_approval",             $m.pending_approval,              "string"],
                                         ["limites.bash_max_analisis",    $m.limites.bash_max_analisis,     "number"],
                                         ["veredictos.exigir_fecha",      $m.veredictos.exigir_fecha,       "boolean"],
                                         ["veredictos.caducan_con_codigo",$m.veredictos.caducan_con_codigo, "boolean"],
                                         ["campos.ausencia_exige",        $m.campos.ausencia_exige,         "boolean"],
                                         ["git.activo",                   $m.git.activo,                    "boolean"],
                                         ["git.prohibidos",               $m.git.prohibidos,                "array"],
                                         ["codigo_app.globs",             $m.codigo_app.globs,              "array"]]
                                        | map(select(.[1] != null and (.[1]|type) != .[2]) | .[0] + " = " + (.[1]|tojson))
                                        | join("\u0001"))]
                                      + (if ($m.codigo_app.globs|type) == "array" then ($m.codigo_app.globs | map(select(type == "string"))) else [] end) | .[]'
  rc=$?
  ARNES_GLOBS=()
  # SEC-005 — UN MANIFIESTO ILEGIBLE NO ES UN MANIFIESTO AUSENTE, Y NO SE PARECEN EN NADA.
  #
  # Ausente es una decision del proyecto: no usa el arnes, y los hooks son INERTES a
  # proposito para no estorbar. Presente-y-roto es lo contrario: el proyecto SI declaro
  # invariantes y la puerta no puede leerlas. Confundirlos permite todo en silencio.
  #
  # Y habia algo peor que el silencio, medido en la auditoria R-001: `arnes_jq_file` deja
  # `ARNES_JQ` CON SU VALOR ANTERIOR cuando jq falla, y el valor anterior es el analisis
  # del INPUT. Asi que el bucle de lectura de abajo rellenaba las variables del manifiesto
  # con campos que controla quien llama: `ARNES_AGENTE_CODIGO` se quedaba valiendo `Bash`
  # —el `tool_name`— y los globs vacios. La identidad del agente autorizado la escribia el
  # llamante. Por eso lo primero es VACIAR `ARNES_JQ`: ningun dato del input puede
  # atravesar esta frontera.
  # Un archivo VACIO no hace fallar a jq: no produce entrada, asi que rc=0 y la salida es
  # vacia — y una salida vacia rellenaba todas las variables con la cadena vacia y los
  # globs con nada, que se lee igual que "este proyecto no protege nada". Rc cero no es
  # lo mismo que lectura buena.
  if [ "$rc" -ne 0 ] || [ -z "$ARNES_JQ" ]; then
    ARNES_JQ=''
    ARNES_MANIFEST_ROTO=1
    arnes_warn "'.arnes/config.json' existe pero no se puede leer como objeto JSON (invalido, vacio, 'null' o un array). NO se aplica ningun valor por defecto silencioso: mientras siga asi, toda escritura que las puertas deban juzgar se DENIEGA, y 'guard-git' deniega el git destructivo de su LISTA POR DEFECTO (una puerta que no puede medir no deja pasar, tampoco esa). Un manifiesto ausente si deja los hooks inertes; uno roto, no."
  fi
  # `limites.bash_max_analisis` es OPCIONAL: el valor por defecto vive en el codigo
  # (`ARNES_BASH_MAX_ANALISIS`) y ningun proyecto tiene que declararlo. Solo se acepta si
  # es un entero positivo; cualquier otra cosa se ignora y manda el defecto —un techo
  # escrito a mano no puede desactivar la puerta por una errata.
  { IFS= read -r ARNES_AGENTE_CODIGO; IFS= read -r ARNES_REQ_DIR
    IFS= read -r ARNES_ESTADO_DONE;   IFS= read -r ARNES_PENDING
    IFS= read -r ARNES_BASH_MAX
    # Los booleanos se comparan con `==` y no con `//`: para jq `false // x` es `x`, y
    # un `activo: false` se leeria como activo -- fallo en abierto por la puerta trasera.
    # `git.prohibidos` ausente -> lista por defecto; `[]` explicito -> ninguna regla, que
    # es una decision declarada del proyecto y no un error.
    IFS= read -r ARNES_VER_FECHA;     IFS= read -r ARNES_VER_CADUCAN
    # `campos.ausencia_exige` viaja en la MISMA llamada a jq que todo lo demas: la
    # activacion de REQ-024 no cuesta NI UN PROCESO en el camino de evaluacion, que es lo
    # que `REQ-024 CA-07 (i)` contrata. Nace APAGADA (ver `arnes_resuelve_ausencia`).
    IFS= read -r ARNES_AUSENCIA_EXIGE
    IFS= read -r ARNES_GIT_ACTIVO;    IFS= read -r ARNES_GIT_PROHIBIDOS
    IFS= read -r ARNES_TIPOS
    while IFS= read -r g; do [ -n "$g" ] && ARNES_GLOBS+=("$g"); done
  } <<< "$ARNES_JQ"
  # Una entrada por clave con el tipo equivocado: la clave y el valor TAL COMO SE RECIBIO
  # (en JSON, para que `"true"` se distinga de `true`). Sin denegar: un tipo mal escrito no
  # puede convertirse en un bloqueo, pero tampoco en un silencio.
  if [ -n "${ARNES_TIPOS:-}" ]; then
    local _t
    while IFS= read -r -d $'\001' _t || [ -n "$_t" ]; do
      _t="${_t%$'\n'}"          # el here-string anade un salto al ultimo campo
      [ -n "$_t" ] || continue
      arnes_warn "'${_t%% = *}' de .arnes/config.json no tiene el tipo que esa clave espera (se recibio ${_t#* = }); se ignora y manda el valor por defecto del arnes. Lo que la puerta no entiende cae del lado seguro, y lo dice."
    done <<< "$ARNES_TIPOS"
  fi
  # El TIPO lo decide el JSON, no la forma del texto: `"999999"` entrecomillado es una
  # cadena, no un número, y se comportaba como si lo fuera (SEC-006(b), R-001). Un techo
  # escrito a mano no puede desactivar la puerta por una errata ni por un tipo.
  case "${ARNES_BASH_MAX:-}" in
    '')      ;;                       # ausente: ni aviso ni techo; manda el del codigo
    '!tipo') ARNES_BASH_MAX='' ;;     # el tipo ya lo aviso el bloque de arriba
    # Es un numero JSON, pero no un entero positivo de bytes que la puerta pueda aplicar:
    # `1e9` (jq lo escribe `1E+9`), `1.5`, `-5` o `0`. Caia al defecto SIN DECIR NADA, por
    # el hueco entre «supera el maximo» y «no es un numero» (QA-107).
    *[!0-9]*|0) arnes_warn "'limites.bash_max_analisis' de .arnes/config.json vale $ARNES_BASH_MAX, que no es un entero positivo de bytes (la forma exponencial '1e9' y los decimales tampoco lo son); se ignora y manda el techo por defecto del arnes."
                ARNES_BASH_MAX='' ;;
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

# --- Avisos que llegan a la PERSONA sin bloquear la llamada ------------------------
# Un hook PreToolUse solo tiene dos salidas que Claude Code escucha: DENEGAR, o
# `systemMessage`, que se muestra a la persona. LA DOCUMENTACION DE HOOKS NO OFRECE
# NINGUNA FORMA DE ANADIR CONTEXTO AL MODELO SIN BLOQUEAR: `permissionDecision:"ask"`
# detiene la llamada hasta que un humano responde, y eso para un valor mal tecleado es
# peor que el defecto que avisa. La limitacion se declara aqui, no se descubre despues.
#
# Se ACUMULAN y se emiten UNA vez al final del proceso, y solo si ningun guardian
# denego: una denegacion ya lo dice todo, y dos salidas JSON en el mismo stdout no son
# un objeto valido.
ARNES_AVISOS=''
arnes_aviso() { ARNES_AVISOS+="ARNES: $1"$'\n'; }
arnes_emitir_avisos() {
  [ -n "$ARNES_AVISOS" ] || return 0
  jq -cn --arg m "${ARNES_AVISOS%$'\n'}" '{systemMessage:$m}'
  return 0
}

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
#
# SE RETIRA EL CR DE TRANSPORTE Y SÓLO ESE, y esto es un arreglo, no un detalle. Estas
# tres funciones retiraban TODOS los retornos de carro, incluidos los que vienen DENTRO
# del dato —el `content` de un `Write`, por ejemplo—, y aguas abajo ese texto lo lee el
# lector de cabecera, que escanea el rango `<!-- … -->`. Retirar un carácter no puede
# destruir un delimitador pero SÍ puede crearlo: medido, un `-\r->` en el contenido
# entrante llegaba al lector como `-->` y cerraba un REQ `critico` con su
# `Seguridad: pendiente` vigente (H-01, `docs/qa/1.32.1-hallazgos.md`; CA-02 de REQ-016
# nombra esta clase). Lo que Windows añade es el CR que TERMINA cada línea, así que es
# eso lo que se descuenta: pregunta cerrada, no un patrón que ensanchar.
#
# La regla vive en `arnes_sin_cr_transporte` —una sola vez, sin forks—: tres copias de la
# misma normalización se desfasan, y ésta ya se desfasó una vez contra `campos-req.awk`.
arnes_sin_cr_transporte() {   # <texto> -> ARNES_SIN_CR
  # El CRLF de cada línea. Y el CR final SUELTO aparte, porque la sustitución de comandos
  # que envuelve a `jq` se come el último `\n` y deja su `\r` colgando: sin esta segunda
  # mitad, el glob del manifiesto volvería a ser `src/*\r` y no casaría nunca (el
  # fallo en abierto que documenta el bloque de arriba).
  local s="${1//$'\r\n'/$'\n'}"
  ARNES_SIN_CR="${s%$'\r'}"
}
arnes_jq() {
  local out
  out="$(jq "$@")" || return $?
  arnes_sin_cr_transporte "$out"
  printf '%s\n' "$ARNES_SIN_CR"
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
  arnes_sin_cr_transporte "$out"; ARNES_JQ="$ARNES_SIN_CR"
}

arnes_jq_file() {  # <archivo> <args de jq...> -> ARNES_JQ
  local f="$1"; shift
  local out
  out="$(jq "$@" "$f")" || return $?
  arnes_sin_cr_transporte "$out"; ARNES_JQ="$ARNES_SIN_CR"
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

# --- Publicacion por temporal: el nombre es del PROCESO, no solo del destino -------
#
# TODO PUNTO DE `hooks/` QUE PUBLICA escribe el contenido completo en un temporal y lo
# mueve encima del destino: el `mv` (un `rename` dentro del mismo directorio) es lo que
# impide que el destino se quede a medias. Lo que faltaba era la otra mitad: el nombre del
# temporal se derivaba SOLO de la ruta del destino, asi que dos paradas de agente
# simultaneas escribian EL MISMO archivo.
#
# Y lo que se publica entonces no es "el borrador de una de las dos": cuando la primera
# hace `mv`, el inodo que la segunda tiene abierto con O_TRUNC pasa a SER el destino, y su
# escritura --que ya iba tarde-- cae encima del texto publicado, empezando por el byte 0.
# En `docs/ESTADO.md` el byte 0 es justo donde vive lo que escribio una persona. Medido
# (H-12 / SEC-015, 2026-09-06): desaparecio 1 de 25 vueltas completas del banco. Es lo
# unico de ese archivo que no se puede volver a derivar.
#
# DOS CONDICIONES, Y NINGUNA BASTA SOLA (REQ-015 CA-01). El error de R-003 fue acreditar
# la segunda y dar por hecha la primera:
#   (i)  NO COLISION: el nombre lleva una componente propia del proceso, asi que dos
#        procesos VIVOS no pueden designar nunca la misma ruta temporal.
#   (ii) UBICACION: el temporal se queda en el directorio DEL DESTINO. Un `mv` entre
#        sistemas de archivos deja de ser un rename --copia y vuelve a introducir el
#        archivo a medias-- y reintroduciria justo lo que el temporal viene a evitar.
#
# LA COMPONENTE ES `BASHPID`, Y ESO ES PARTE DEL CONTRATO DE COSTE (CA-11): es una
# variable que el interprete YA TIENE, no un programa. Un `mktemp` seria un fork mas en el
# camino mas caliente del arnes --cada parada de cada subagente-- y en Windows/MSYS un
# fork cuesta 1,2-6 s (AGENTS.md 2). `$$` no serviria: dentro de un subshell devuelve el
# pid del PADRE, y dos subshells hermanos volverian a compartir nombre.
#
# FAIL-CLOSED: si la componente no se puede obtener o no es un numero, NO se cae al nombre
# compartido. Caer seria reintroducir la carrera en silencio, que es peor que no publicar:
# se devuelve error y quien publica avisa y no escribe nada.
arnes_tmp_publicacion() {   # <ruta destino> -> ARNES_TMP ; 1 = sin componente unica
  local id="${BASHPID:-}"
  case "$id" in ''|*[!0-9]*) ARNES_TMP=''; return 1 ;; esac
  arnes_purga_tmp "$1"
  ARNES_TMP="$1.arnes.tmp.$id"
  return 0
}

# EL REVERSO DEL NOMBRE UNICO, Y HAY QUE PAGARLO (REQ-015 CA-02): un archivo que antes se
# sobrescribia a si mismo pasa a ser una FAMILIA de nombres, y un temporal que sobreviva a
# su dueno --SIGKILL, corte de luz-- ya no lo retira la parada siguiente al reutilizarlo.
# Se retira aqui, y solo el que no tiene dueno vivo: el de un proceso que sigue corriendo
# es una publicacion EN CURSO y borrarlo seria crear el problema que este REQ cierra.
#
# Cuesta un glob (sin fork) y `kill -0`, que es un builtin. El `rm` --el unico fork-- solo
# se paga cuando de verdad hay restos, que es lo que CA-11 admite: el camino ordinario no
# gasta ni un proceso mas que la linea base.
#
# LOS DOS BORDES, DICHOS: (a) si el pid pertenece a otro usuario, `kill -0` falla por
# permisos y el temporal se toma por huerfano; el peor caso es que a su dueno le falle el
# `mv`, y ese camino ya deja el destino intacto y avisa. (b) si el pid se reciclo en un
# proceso ajeno, el resto se conserva y lo retira una parada posterior. Ninguno de los dos
# puede perder contenido del destino.
arnes_purga_tmp() {   # <ruta destino> — retira los temporales de publicacion sin dueno vivo
  local t pid
  local -a huerfanos=()
  for t in "$1".arnes.tmp "$1".arnes.tmp.*; do
    [ -f "$t" ] || continue                      # el glob sin coincidencias llega literal
    pid="${t##*.arnes.tmp}"; pid="${pid#.}"
    # `<destino>.arnes.tmp` a secas es el nombre COMPARTIDO de <=1.32.0: no declara dueno
    # y ninguna version nueva lo escribe, asi que es un resto por definicion.
    if [ -n "$pid" ]; then
      case "$pid" in *[!0-9]*) continue ;; esac   # no es un temporal del arnes: no se toca
      kill -0 "$pid" 2>/dev/null && continue      # dueno vivo: publicacion en curso
    fi
    huerfanos+=("$t")
  done
  [ "${#huerfanos[@]}" -gt 0 ] || return 0
  rm -f -- "${huerfanos[@]}" 2>/dev/null
  return 0
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
  # BARRAS REPETIDAS (SEC-003, R-001). Era la evasión más barata medida en todo el
  # arnés: UN carácter de más —`<raíz>//src//a.ts`— y las DOS puertas se apagaban a la
  # vez. `arnes_ruta_relativa` recorta el prefijo del proyecto TEXTUALMENTE, así que la
  # ruta no empezaba por `<raíz>/`, el prefijo no se recortaba, la relativa quedaba con
  # `/` inicial y ningún glob de `codigo_app.globs` casaba; por la misma razón ninguna
  # ruta caía dentro de `requirements/` y el cierre de un REQ dejaba de juzgarse.
  # Se colapsa AQUÍ —antes de recortar el prefijo—, con expansión de parámetros y sin
  # ningún proceso. El bucle es O(log n) sobre la ristra de barras, no sobre la ruta.
  #
  # La doble barra INICIAL se conserva: en Windows `//servidor/recurso` es una ruta UNC
  # y comérsela cambiaría de máquina, no de forma.
  case "$p" in
    //*) d='//'; p="${p#//}" ;;
    *)   d='' ;;
  esac
  while [ "$p" != "${p//\/\//\/}" ]; do p="${p//\/\//\/}"; done
  p="$d$p"
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
# EL VALOR (65536 = 64 KiB) sale de MEDIR el peor caso por byte. LA SERIE CITABLE ES UNA
# SOLA y esta escrita abajo, junto a `ARNES_BASH_MAX_MANIFIESTO`: aqui NO se repite, para
# que no vuelva a haber dos. (Hubo dos, con materiales distintos y sin decirlo, y no
# coincidian en el mismo tamano: 128 KiB salia a 1,8 s en una y a 2,3 s en la otra. Se
# re-midieron las dos el 2026-09-05 con el mismo detector y el mismo material; la buena es
# la de abajo y la otra se retira. Dos series para el mismo numero significan que el
# numero operativo se apoya en la equivocada, y ese numero decide si la puerta responde
# antes de que el hook muera.)
#
# De esa serie: 64 KiB de material denso se analizan de punta a punta en 0,61 s, frente a
# los 60 s en que el hook muere PERMITIENDO. El doble (128 KiB) ya cuesta 2,31 s, asi que
# el margen se agota rapido: por eso el techo por defecto esta aqui y no mas arriba. El
# material real de un comando normal son decenas de bytes; esto solo lo toca una entrada
# construida a proposito.
ARNES_BASH_MAX_ANALISIS=65536
# MÁXIMO que un manifiesto puede declarar en `limites.bash_max_analisis`. Es OPERATIVO,
# no arbitrario: en este techo el peor caso analizable —cuerpo denso en `$(`— tiene que
# seguir respondiendo por debajo de los 5 s, muy lejos de los 60 s en que el hook muere
# PERMITIENDO.
#
# LA SERIE — es la UNICA de este archivo, y la citan los dos techos. Plataforma de
# desarrollo (Linux/WSL2), re-medida el 2026-09-05 sobre `arnes_bash_escrituras`, material
# `$(x)` repetido hasta el tamano indicado + una escritura real al final:
#     64 KiB -> 0,61 s   128 KiB -> 2,31 s   192 KiB -> 5,06 s   256 KiB -> 8,76 s
# Así que el máximo es 128 KiB y no los 256 KiB que se propusieron: el criterio manda
# bajarlo hasta que cumpla el umbral absoluto de 5 s, y 192 KiB ya no lo cumple —por poco,
# y «por poco» tambien es no cumplir. El número
# vigente sale impreso en el motivo del deny. Si el detector se abarata, se vuelve a
# medir y sube; nunca al revés.
ARNES_BASH_MAX_MANIFIESTO=131072

# LA LISTA POR DEFECTO DE `guard-git`, EN EL CODIGO Y UNA SOLA VEZ.
#
# Vivia dentro del programa de jq, que es donde se lee el manifiesto. Con el manifiesto
# ILEGIBLE no hay jq que valga y la puerta necesita la lista igual (SEC-010): repetirla en
# bash serian dos transcripciones de la misma regla, y dos transcripciones se desfasan. Se
# declara aqui, se le pasa a jq con `--arg`, y las dos vias leen la misma cadena.
# Separador TABULADOR, como el resto de las listas que cruzan de jq a bash en este arnes.
ARNES_GIT_PROHIBIDOS_DEFECTO=$'clean -f\treset --hard\tcheckout .\trestore .\tstash\tstash push\tstash pop\tstash drop\tstash clear'

# PRESUPUESTO de la reconstruccion de un REQ en `guard-completado`, en bytes-edicion
# (tamano del documento en disco x numero de ediciones). El techo fail-closed del analisis
# de Bash vivia SOLO en el detector de escrituras, mientras la via Edit/MultiEdit aplicaba
# cada edicion sobre una copia completa del texto —coste del orden de ediciones x tamano,
# SIN techo—. Medido (Linux/WSL2, 2026-09-05) sobre un REQ de ~300 KB: 101 ediciones 2,2 s ·
# 401 ediciones 8,0 s · 1.501 ediciones 25,7 s; y con un REQ de 3,1 MB + 401 ediciones, SIN
# respuesta a los 30 s. Por encima de 60 s el hook muere, no emite nada y el resultado
# efectivo es PERMITIR: la familia del reloj, otra vez. 64 MiB-edicion deja holgadamente
# dentro el caso ordinario (un REQ grande con un punado de ediciones) y corta antes de que
# el reloj decida. Igual que el otro techo: el numero es operativo y sale impreso en el deny.
ARNES_EDIT_MAX_PRESUPUESTO=67108864
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
  local v m
  if [ -z "${ARNES_TECHO:-}" ]; then
    ARNES_TECHO="$ARNES_BASH_MAX_ANALISIS"
    arnes_parse_manifest
    if [ -n "${ARNES_BASH_MAX:-}" ]; then
      # TOPE DEL VALOR DECLARADO (SEC-006(b), R-001). El coste del análisis crece con el
      # tamaño y un hook `PreToolUse` MUERE a los 60 s permitiendo: sin máximo, subir el
      # techo desde el manifiesto reabre POR CONFIGURACIÓN el fallo en abierto que el
      # presupuesto cerró. `4294967296` se aceptaba tal cual.
      #
      # La comparación es por LONGITUD y luego lexicográfica sobre dígitos, no aritmética:
      # `99999999999999999999` desborda el entero de 64 bits de bash y `(( ))` daría un
      # número cualquiera —incluido uno pequeño—, que es fallar en abierto justo en la
      # comprobación que existe para no fallar en abierto.
      v="${ARNES_BASH_MAX}"; m="$ARNES_BASH_MAX_MANIFIESTO"
      while [ "${v:0:1}" = 0 ] && [ ${#v} -gt 1 ]; do v="${v:1}"; done
      if [ ${#v} -gt ${#m} ] || { [ ${#v} -eq ${#m} ] && [ "$v" \> "$m" ]; }; then
        arnes_warn "'limites.bash_max_analisis' de .arnes/config.json declara $ARNES_BASH_MAX bytes y el maximo admitido es $ARNES_BASH_MAX_MANIFIESTO; se aplica el maximo. Un techo mas alto deja de responder antes de que el hook muera, y un hook muerto no deniega."
        ARNES_TECHO="$ARNES_BASH_MAX_MANIFIESTO"
      elif (( v > ARNES_TECHO )); then
        ARNES_TECHO="$v"
      fi
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

# EL COMANDO SIN SU TEXTO: descuenta los cuerpos literales de heredoc y lo
# entrecomillado, y anade al final el interior EJECUTABLE de las expansiones que
# viajan dentro de un heredoc sin citar. Es lo que miran los detectores que juzgan
# UNA ORDEN dentro de un comando de shell: el de escrituras (`arnes_bash_escrituras`)
# y el de git destructivo (`guard-git.sh`).
#
# VIVE APARTE PARA QUE HAYA UN SOLO DESCUENTO. Dos detectores con su propia copia de
# esta regla se desfasan, y la mitad del valor de este arnes es no tener dos
# transcripciones de la misma regla: `git commit -m "no uses git clean"` y
# `cp README.md src/` dentro de un heredoc citado tienen que descontarse EXACTAMENTE
# igual en los dos, hoy y cuando alguien arregle un borde en uno de ellos.
#
# Devuelve 0 con el texto en `ARNES_SIN_TEXTO`, y `$ARNES_RC_EXCESO` (2) SIN ANALIZAR
# NADA cuando el material supera el presupuesto (ver `ARNES_BASH_MAX_ANALISIS`). Un
# `return 2` no deja nada en `ARNES_SIN_TEXTO` que se pueda confundir con "no hay nada":
# los llamadores miran el codigo y lo traducen a una denegacion con motivo.
arnes_bash_sin_texto() {   # <comando> -> ARNES_SIN_TEXTO
  local cmd="$1" limpio
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
  ARNES_SIN_TEXTO="$limpio"
  return 0
}

arnes_bash_escrituras() {  # <comando> -> rutas escritas, una por línea
  #
  # Devuelve 0 con las rutas (ninguna, una o varias) y `$ARNES_RC_EXCESO` (2) SIN
  # ANALIZAR NADA cuando el material a analizar supera el presupuesto: ver
  # `ARNES_BASH_MAX_ANALISIS`. Los dos guardianes traducen ese 2 a una denegacion con
  # motivo. Un `return 2` nunca sale por la salida estandar, asi que un llamador que
  # ignore el codigo ve una lista vacia: eso seria permitir, y por eso los dos
  # llamadores lo miran (y hay caso de banco para cada uno).
  local limpio i j n tok
  # IFS explicito: el troceado en palabras de esta funcion (y el de sus auxiliares) no
  # puede depender de como lo haya dejado el llamador.
  local IFS=$' \t\n'
  arnes_bash_sin_texto "$1" || return $?
  limpio="$ARNES_SIN_TEXTO"
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

# --- Lectura de un archivo del disco, sin procesos y SIN mentir ----------------
# `IFS= read -r -d '' x < f` es la forma barata de leer un archivo entero en bash: un
# solo builtin, cero forks. Tiene un borde que costó un fallo en abierto medido
# (SEC-002, R-001): el delimitador es NUL, así que un NUL DENTRO del archivo hace que
# `read` termine ahí y devuelva 0 — la variable queda TRUNCADA y el llamador cree que
# tiene el documento entero. Un REQ con un NUL en la primera línea se leía sin
# veredictos, y un campo vacío no dispara ninguna exigencia.
#
# La distinción es gratis y estaba ahí desde siempre: `read -d ''` devuelve 0 SÓLO si
# encontró el delimitador. Al final del archivo (lo normal) devuelve 1. Así que
#   rc==0  ->  había un NUL  ->  lo leído NO es el archivo
#   rc!=0  ->  se leyó hasta el final  ->  lo leído ES el archivo
# Esta función invierte ese código a la pregunta que hace el llamador —«¿puedo fiarme
# de esto?»— y añade el otro modo de no poder medir: un archivo sin permiso de lectura.
arnes_lee_archivo() {   # <ruta> -> ARNES_TEXTO ; 0 = leído entero, 1 = NO medible
  ARNES_TEXTO=''
  [ -e "$1" ] || return 0        # no existe: no hay texto, y eso sí se sabe
  [ -f "$1" ] && [ -r "$1" ] || return 1
  if IFS= read -r -d '' ARNES_TEXTO < "$1" 2>/dev/null; then
    ARNES_TEXTO=''               # truncado por un NUL: no se devuelve la mitad de un documento
    return 1
  fi
  return 0
}

# --- La cola de aprobaciones: UNA regla, la de la puerta ----------------------
# Había DOS transcripciones de la misma regla: `guard-completado` contaba encabezados
# `###` bajo `## Pendientes` con un awk, y el bloque derivado de `docs/ESTADO.md`
# contaba viñetas (`- `, `* `, `1. `) con un bucle. Una entrada real del formato que
# documenta el propio `PENDING_APPROVAL.md` —un `###` con cuatro viñetas debajo— valía
# 1 para la puerta y 4 para el bloque. Ninguno de los dos números miente por sí solo;
# lo que miente es que haya dos, porque el que se lee deja de ser el que bloquea.
#
# Gana la de la PUERTA: es la que decide, la que está documentada y la que ya distingue
# el ejemplo comentado de una entrada real.
#
# LA REGLA, escrita una vez: una entrada es una línea que empieza por `###` + espacio,
# dentro de la sección que abre un encabezado `## ` cuyo texto empieza por `Pendientes`
# y que cierra el siguiente encabezado `## ` de CUALQUIER nombre, descontando lo que
# caiga dentro de un comentario HTML (`<!--` … `-->`).
#
# Sin `awk`: la puerta pierde el fork que pagaba y la parada no gana ninguno. En esta
# plataforma cada fork cuesta 1,2-6 s, así que unificar no puede pagarse con un proceso.
#
# Y es una PUERTA: si el archivo no se puede medir —un NUL que trunca la lectura, un
# archivo ilegible, o un rango de comentario que ABRE y no cierra antes del fin del
# archivo— no devuelve 0, devuelve «no lo sé» (rc 1). Contar 0 sobre un archivo truncado
# abriría el cierre de cualquier REQ con aprobaciones humanas pendientes.
#
# La tercera de esas tres es de 1.34.0 (REQ-024 CA-08): hasta 1.33.0 el contrato de esta
# cabecera sólo se honraba en la rama de `arnes_lee_archivo`, y un rango sin cerrar
# devolvía el contador con rc 0. El motivo de la denegación cita la línea donde abre
# (`ARNES_COLA_ABRE_LN` / `ARNES_COLA_ABRE_TEXTO`, publicadas aquí).
arnes_cola_pendientes() {   # <archivo> -> ARNES_COLA ; 0 = medido, 1 = NO medible
  local linea resto dentro=0 enc=0 n=0 ln=0
  ARNES_COLA=0; ARNES_COLA_ABIERTA=0; ARNES_COLA_ABRE_LN=0; ARNES_COLA_ABRE_TEXTO=''
  [ -e "$1" ] || return 0        # sin archivo no hay cola: cero, y es una medida
  arnes_lee_archivo "$1" || { ARNES_COLA=''; return 1; }
  while IFS= read -r linea; do
    ln=$((ln + 1))
    linea="${linea%$'\r'}"       # CRLF: el retorno de carro no puede cambiar la cuenta
    # Comentarios HTML, con la misma semántica que tenía el awk de la puerta: la línea
    # que ABRE ya no cuenta, y la que CIERRA tampoco.
    #
    # DONDE ABRE SE RECUERDA, y no es adorno: si al final del archivo el rango sigue
    # abierto, la cola no se pudo MEDIR y el motivo de la puerta tiene que decir en qué
    # línea empezó (REQ-024 CA-08 i). Un «no se pudo medir» sin sitio deja a la persona
    # buscando un `<!--` en un archivo entero.
    case "$linea" in *'<!--'*)
      [ "$enc" -eq 1 ] || { ARNES_COLA_ABRE_LN="$ln"; ARNES_COLA_ABRE_TEXTO="${linea:0:120}"; }
      enc=1 ;;
    esac
    # UN CIERRE SIN APERTURA NO RETIRA NADA (REQ-024 CA-09, SEC-051 parte B). Hasta 1.33.0
    # este `continue` era INCONDICIONAL, así que una línea con `-->` se descartaba aunque
    # no hubiera ningún rango abierto: `### Migrar A --> B` —un título ordinario, sin
    # comentario ninguno— hacía desaparecer una aprobación humana de la cuenta, y la
    # puerta, el informe y el bloque derivado coincidían en el número equivocado. El
    # cierre de un rango sólo tiene efecto si hay un rango ABIERTO; una secuencia de
    # cierre huérfana no delimita nada. La línea que SÍ cierra un rango sigue sin contar,
    # y una línea que abre y cierra dentro de sí misma sigue descartándose entera: es la
    # frontera de grano de LÍNEA que `ADR-010` mantiene y que REQ-009 CA-04/CA-07
    # contratan.
    case "$linea" in *'-->'*)
      if [ "$enc" -eq 1 ]; then enc=0; continue; fi ;;
    esac
    [ "$enc" -eq 0 ] || continue
    case "$linea" in
      '##'[[:space:]]*)
        resto="${linea#\#\#}"
        while :; do
          case "$resto" in [[:space:]]*) resto="${resto#?}" ;; *) break ;; esac
        done
        case "$resto" in Pendientes*) dentro=1 ;; *) dentro=0 ;; esac
        continue ;;
      '###'[[:space:]]*)
        [ "$dentro" -eq 1 ] && n=$((n+1))
        continue ;;
    esac
  done <<< "$ARNES_TEXTO"
  # UN RANGO QUE ABRE Y NO CIERRA: LA COLA NO SE PUDO MEDIR (REQ-024 CA-08, SEC-051 parte C).
  #
  # Hasta 1.33.0 esta función llegaba aquí con `enc=1` y devolvía el contador con rc 0, o
  # sea CERO sobre un archivo con aprobaciones visibles detrás del rango abierto: los tres
  # canales de observabilidad —la puerta, el informe y el bloque derivado— publicaban el
  # mismo número equivocado, y no quedaba ni un sitio donde una persona pudiera notarlo.
  # Contradecía el contrato que esta función se escribe en su propia cabecera y la conducta
  # que REQ-009 CA-15/CA-16 ya habían contratado para el byte NUL: la condición de salida
  # existía, sólo no se alcanzaba.
  #
  # Y LA ASIMETRÍA QUE PRUEBA QUE ERA UN DEFECTO Y NO UNA DECISIÓN: en la cabecera de un
  # REQ un rango sin cerrar DENIEGA con motivo propio (REQ-016, `ARNES_CITA_ABIERTA`); en
  # la cola contaba cero en silencio. Dos transcripciones de la misma noción decidiendo al
  # contrario, y la buena es la del REQ.
  #
  # SE MIRA AL FINAL DEL ARCHIVO Y NO SÓLO DENTRO DE `## Pendientes`, a propósito: con el
  # rango abierto todas las líneas siguientes se descartaron, así que no se sabe si dentro
  # había una entrada —ni si había otra sección `## Pendientes`—. Lo que no se pudo leer no
  # se puede acotar.
  if [ "$enc" -eq 1 ]; then
    ARNES_COLA=''; ARNES_COLA_ABIERTA=1
    return 1
  fi
  ARNES_COLA="$n"
  return 0
}

# --- SEC-004: el arnes juzga LA RUTA ESCRITA, no su destino ---------------------
# Los dos guardianes clasifican por el nombre de la ruta —los globs del manifiesto, el
# `requirements_dir`—, asi que un enlace simbolico colocado en una ruta libre que apunte
# a codigo protegido o a un REQ recibiria el veredicto de SU NOMBRE y no el de lo que
# toca. Medido: allow en v1.30.2 y en 1.30.3.
#
# SALIDA ELEGIDA: fail-closed SIN RESOLVER. Si el ultimo componente de la ruta escrita es
# un enlace, no se escribe a traves de el. Y NO se resuelve el destino a proposito, por
# dos razones que apuntan al mismo sitio:
#   * resolver cuesta un proceso (`readlink`/`realpath`) en el camino de TODA edicion, y
#     en esta plataforma cada fork cuesta 1,2-6 s; aqui basta la prueba `[ -L ]` del
#     propio bash, que no bifurca.
#   * resolver abriria una CARRERA entre la comprobacion y la escritura: lo que el hook
#     mide y lo que la herramienta escribe no serian el mismo archivo. Una puerta que
#     mide otra cosa no es una puerta.
# El precio, dicho en voz alta: no se puede escribir a traves de un enlace ni siquiera
# cuando su destino es inocente. Es el lado que cierra, y la salida esta a la vista —
# escribir sobre la ruta real.
#
# ALCANCE: solo `Edit`/`Write`/`MultiEdit` (donde hay una ruta que mirar) y solo DENTRO
# del proyecto. Una ruta externa no es asunto del arnes, y `Bash` no paga nada de esto:
# el camino comun no gana ni un proceso ni una llamada al sistema.
arnes_deny_enlace() {   # -> deniega si `file_path` es un enlace simbolico dentro del proyecto
  case "$ARNES_TOOL" in Edit|Write|MultiEdit) ;; *) return 0 ;; esac
  [ -n "$ARNES_FP" ] || return 0
  [ -L "$ARNES_FP" ] || return 0
  arnes_ruta_relativa "$ARNES_FP" "$ARNES_PROJ"
  # Si tras recortar la raiz la ruta sigue siendo absoluta o sube, esta FUERA del
  # proyecto: se trata como externa y no se juzga, igual que cualquier otra ruta de fuera.
  case "$ARNES_REL" in ''|/*|[A-Za-z]:*|..|../*|*/../*) return 0 ;; esac
  arnes_deny "ARNES: '$ARNES_REL' es un ENLACE SIMBOLICO y no se escribe a traves de el. El arnés juzga la ruta escrita, no su destino: un enlace en una ruta libre que apunte a código protegido o a un REQ recibiría el veredicto de su nombre y no el de lo que realmente toca. Resolver el destino tampoco valdría —entre la comprobación y la escritura el enlace puede cambiar, y una puerta que mide otra cosa no es una puerta—. Salida: escribe directamente sobre la ruta real (SEC-004, REQ-007 CA-49)."
}

# SEC-005 — la consecuencia de un manifiesto roto: DENY en lo que escribe, con aviso.
#
# No se puede denegar "solo en las rutas protegidas" porque justo lo que no se puede leer
# es CUALES son. Asi que se deniega toda escritura que una puerta tendria que juzgar: es
# el mismo razonamiento del presupuesto de analisis de Bash —una puerta que no puede medir
# no deja pasar—, y la salida esta a la vista y es de un minuto: arreglar el JSON.
#
# ALCANCE ACOTADO A PROPOSITO: `Edit`/`Write`/`MultiEdit`, donde la escritura es cierta, y
# `Bash` SOLO cuando el detector ya encontro un destino de escritura (lo pasa el llamador,
# que ya lo analizo: aqui no se vuelve a pagar). Un `ls -la` con el manifiesto roto sigue
# pasando, porque no escribe nada y bloquearlo no protegeria ninguna invariante.
#
# LA UNICA ESCRITURA QUE SE PERMITE ES LA DEL PROPIO MANIFIESTO (QA-105). El motivo de la
# denegacion ofrece una salida --"corrige el JSON"-- que estaba prohibida por la propia
# denegacion en cuanto `.arnes/config.json` figura en `codigo_app.globs`: ni por `Edit`, ni
# por `Write`, ni por `Bash`, y para NINGUN agente. Un proyecto con una coma de mas quedaba
# con todo bloqueado hasta que una persona editara el archivo fuera de la sesion. Es el
# unico archivo cuya reparacion devuelve la capacidad de medir, y no depende de leerlo, asi
# que se exceptua: cualquier otra ruta sigue denegada mientras el manifiesto este roto, y
# con el manifiesto sano vuelve a estar protegido como cualquier otro archivo de los globs.
#
# NO SE FILTRA POR AGENTE, y es a proposito: QUIEN es el agente de codigo se lee del
# manifiesto, que es justo lo que no se puede leer. Exigir un nombre aqui seria inventarlo.
arnes_deny_manifiesto_roto() {   # [destinos de escritura ya detectados por Bash, uno por linea]
  [ "${ARNES_MANIFEST_ROTO:-0}" = "1" ] || return 0
  local destinos d solo_manifiesto=1 manif_rel
  case "$ARNES_TOOL" in
    Edit|Write|MultiEdit) destinos="$ARNES_FP" ;;
    Bash) destinos="${1:-}"; [ -n "$destinos" ] || return 0 ;;
    *) return 0 ;;
  esac
  arnes_ruta_relativa "$ARNES_MANIFEST" "$ARNES_PROJ"; manif_rel="$ARNES_REL"
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    arnes_ruta_relativa "$d" "$ARNES_PROJ"
    [ "$ARNES_REL" = "$manif_rel" ] || { solo_manifiesto=0; break; }
  done <<< "$destinos"
  # Un comando que repara el manifiesto Y ademas escribe en otro sitio no es una
  # reparacion: la excepcion vale cuando TODO lo que escribe es el manifiesto.
  #
  # SEC-011 — Y LA REPARACION DEJA RASTRO. Acotar el radio de una excepcion no es lo mismo
  # que hacerla visible: hasta aqui el `stderr` de una escritura sobre el archivo que
  # declara las invariantes era IDENTICO al de cualquier otra llamada durante la averia, asi
  # que la unica escritura privilegiada del arnes era indistinguible de que no hubiera
  # pasado nada. Se dice quien y sobre que, con un texto propio que no se confunde con el
  # aviso generico del manifiesto roto. NO se registra ningun contenido: solo el tipo de
  # agente y la ruta relativa.
  if [ "$solo_manifiesto" -eq 1 ]; then
    # Una vez por llamada, no una por guardian: los dos corren en el mismo proceso y el
    # aviso es del hecho, no de quien lo mira.
    [ -z "${ARNES_AVISO_REPARACION:-}" ] || return 0
    ARNES_AVISO_REPARACION=1
    arnes_warn "REPARACION DEL MANIFIESTO permitida excepcionalmente: '$manif_rel' se esta escribiendo (herramienta $ARNES_TOOL) por '${ARNES_AGENT_TYPE:-sesion coordinadora}' mientras el manifiesto esta ilegible. Es la UNICA escritura que la averia deja pasar, porque es la que devuelve la capacidad de medir; cualquier otra ruta sigue denegada, y con el manifiesto sano este archivo vuelve a estar protegido como cualquier otro."
    return 0
  fi
  arnes_deny "ARNES: '.arnes/config.json' existe pero NO se puede leer como objeto JSON (invalido, vacio, 'null' o un array), asi que ninguna puerta sabe que rutas protege este proyecto, quien es el agente de codigo ni cual es el estado terminal. Un manifiesto AUSENTE deja los hooks inertes a proposito; uno ROTO no puede, porque el proyecto si declaro invariantes y la puerta no puede leerlas — permitir aqui seria apagar el enforcement en silencio, que es justo el fallo que este arnes existe para impedir. Salida: corrige el JSON (pruebalo con 'jq -e . .arnes/config.json') o borra el archivo si este proyecto no usa el arnes. Mientras siga roto, la UNICA escritura permitida es la del propio '$manif_rel': es la que repara la averia, y esa si se puede hacer desde la sesion."
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

# --- Ortografia: el ACENTO NO ES PARTE DEL VALOR -------------------------------
# El mismo argumento con el que ya se pliegan el CASO y el MARCADO, aplicado al eje que
# faltaba. `en-revision` y `en-revisión` no son dos valores: son el mismo valor escrito
# por dos personas, y el manifiesto declara uno de los dos. Un acento no es una VARIANTE
# del valor —una lista de variantes se pudre—: es ORTOGRAFIA, un conjunto cerrado y
# ajeno al dominio, exactamente como la sintaxis de Markdown.
#
# EL DEFECTO QUE CIERRA, dicho sin adornos: hasta 1.30.3 aqui se plegaba `Í`/`í` y NADA
# MAS — la unica pareja que `sí` necesitaba—, de modo que el sujeto del control era mas
# estrecho que su poblacion. Es la cuarta vez que reaparece esa misma familia en este
# arnes, asi que el arreglo NO es anadir la letra que faltaba: es declarar la clase.
#
# QUE SE PLIEGA: la vocal con acento (grave, agudo, circunflejo, tilde) y con dieresis,
# en sus DOS formas de guardado —precompuesta (NFC) y descompuesta (NFD: vocal + un
# diacritico combinante)—, en minuscula y en mayuscula.
# QUE NO SE PLIEGA, y la frontera va escrita a proposito:
#   * la `ñ` (y la `ç`, y la `å`): NO son una letra con adorno, son OTRA letra. Plegarlas
#     haria iguales dos palabras distintas (`año` y `ano`), que es el error contrario y
#     peor. Por eso el diacritico combinante solo se retira cuando sigue a una VOCAL:
#     asi `n`+U+0303 se conserva y la `ñ` sobrevive tambien en NFD.
#   * los SEPARADORES y las variantes de palabra (`en revision`, `enrevision`,
#     `revisión` a secas, `en-revisión-parcial`): son valores DISTINTOS y siguen
#     marcandose. Esto pliega ortografia, no vocabulario.
#
# COSTE: cero procesos y cero forks, solo expansion de parametros — en esta plataforma
# cada fork cuesta 1,2-6 s y una normalizacion que se pagara por REQ leido multiplicaria
# ese coste por el numero de REQ. Las dos tablas van detras de una GUARDA sobre el byte
# de cabecera (`\xc3` para NFC, `\xcc` para NFD), asi que un valor ASCII —el caso comun:
# `pendiente`, `aprobado`, `completado`— paga DOS comparaciones y ni una sustitucion.
#
# Y se escribe con ESCAPES DE BYTES, nunca con el caracter tecleado: asi ni el editor
# que guarde este archivo ni el locale con el que arranque el hook pueden re-normalizar
# la tabla. Por lo mismo el resultado es IDENTICO bajo `LC_ALL=C` y bajo un locale
# UTF-8: las secuencias son literales y no hay rangos ni clases sujetas a colacion.
_arnes_pliega_nfd() {   # <valor> <marca combinante> -> ARNES_PLEGADO
  local v="$1" m="$2"
  # Solo tras una VOCAL: ver arriba, es lo que salva a la `ñ` descompuesta.
  v="${v//"a$m"/a}"; v="${v//"e$m"/e}"; v="${v//"i$m"/i}"; v="${v//"o$m"/o}"; v="${v//"u$m"/u}"
  v="${v//"A$m"/a}"; v="${v//"E$m"/e}"; v="${v//"I$m"/i}"; v="${v//"O$m"/o}"; v="${v//"U$m"/u}"
  ARNES_PLEGADO="$v"
}

arnes_pliega_ortografia() {   # <valor> -> ARNES_PLEGADO
  local v="$1" m
  # NFC: vocal acentuada precompuesta (U+00C0-U+00FC, todas con cabecera \xc3).
  case "$v" in *$'\xc3'*)
    v="${v//$'\xc3\xa0'/a}"; v="${v//$'\xc3\x80'/a}"   # à À
    v="${v//$'\xc3\xa1'/a}"; v="${v//$'\xc3\x81'/a}"   # á Á
    v="${v//$'\xc3\xa2'/a}"; v="${v//$'\xc3\x82'/a}"   # â Â
    v="${v//$'\xc3\xa3'/a}"; v="${v//$'\xc3\x83'/a}"   # ã Ã
    v="${v//$'\xc3\xa4'/a}"; v="${v//$'\xc3\x84'/a}"   # ä Ä
    v="${v//$'\xc3\xa8'/e}"; v="${v//$'\xc3\x88'/e}"   # è È
    v="${v//$'\xc3\xa9'/e}"; v="${v//$'\xc3\x89'/e}"   # é É
    v="${v//$'\xc3\xaa'/e}"; v="${v//$'\xc3\x8a'/e}"   # ê Ê
    v="${v//$'\xc3\xab'/e}"; v="${v//$'\xc3\x8b'/e}"   # ë Ë
    v="${v//$'\xc3\xac'/i}"; v="${v//$'\xc3\x8c'/i}"   # ì Ì
    v="${v//$'\xc3\xad'/i}"; v="${v//$'\xc3\x8d'/i}"   # í Í
    v="${v//$'\xc3\xae'/i}"; v="${v//$'\xc3\x8e'/i}"   # î Î
    v="${v//$'\xc3\xaf'/i}"; v="${v//$'\xc3\x8f'/i}"   # ï Ï
    v="${v//$'\xc3\xb2'/o}"; v="${v//$'\xc3\x92'/o}"   # ò Ò
    v="${v//$'\xc3\xb3'/o}"; v="${v//$'\xc3\x93'/o}"   # ó Ó
    v="${v//$'\xc3\xb4'/o}"; v="${v//$'\xc3\x94'/o}"   # ô Ô
    v="${v//$'\xc3\xb5'/o}"; v="${v//$'\xc3\x95'/o}"   # õ Õ
    v="${v//$'\xc3\xb6'/o}"; v="${v//$'\xc3\x96'/o}"   # ö Ö
    v="${v//$'\xc3\xb9'/u}"; v="${v//$'\xc3\x99'/u}"   # ù Ù
    v="${v//$'\xc3\xba'/u}"; v="${v//$'\xc3\x9a'/u}"   # ú Ú
    v="${v//$'\xc3\xbb'/u}"; v="${v//$'\xc3\x9b'/u}"   # û Û
    v="${v//$'\xc3\xbc'/u}"; v="${v//$'\xc3\x9c'/u}"   # ü Ü
  ;; esac
  # NFD: vocal + diacritico combinante (U+0300 grave, U+0301 agudo, U+0302 circunflejo,
  # U+0303 tilde, U+0308 dieresis; todos con cabecera \xcc). Es la MISMA clase de arriba
  # en su otra forma de guardado: un archivo escrito en macOS puede traer la tilde
  # descompuesta y no hay NADA en el REQ que lo delate a la vista.
  case "$v" in *$'\xcc'*)
    for m in $'\xcc\x80' $'\xcc\x81' $'\xcc\x82' $'\xcc\x83' $'\xcc\x88'; do
      case "$v" in *"$m"*) _arnes_pliega_nfd "$v" "$m"; v="$ARNES_PLEGADO" ;; esac
    done
  ;; esac
  ARNES_PLEGADO="$v"
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
  # El TABULADOR se retira igual que el espacio. No es una forma exotica: es lo que
  # deja un editor que alinea la cabecera, y hasta 1.30.3 `Estado:<TAB>completado` se
  # leia como `\tcompletado`, que no casa con el estado terminal — la puerta no veia la
  # transicion y respondia allow. Un blanco es un blanco.
  v="${v// /}"; v="${v//$'\t'/}"
  arnes_desenvuelve "$v"; v="$ARNES_DESENV"
  arnes_pliega_ortografia "$v"; v="$ARNES_PLEGADO"
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
# AUSENTE sigue siendo «no» MIENTRAS EL PROYECTO NO ACTIVE LA EXIGENCIA, y eso no se toca:
# exigir auditoría a todo REQ que no declara el campo rompería cualquier proyecto anterior a
# que el campo existiera. La dirección de la ausencia la decide UN solo sitio
# (`arnes_resuelve_ausencia`, ADR-009); aquí ya no se decide, se pregunta.
arnes_sens_efectiva() {   # ARNES_SENS -> si|no ; ARNES_SENS_DUDOSA -> 0|1
  local corte
  ARNES_SENS_DUDOSA=0; ARNES_SENS_CRUDO="$ARNES_SENS"; ARNES_SENS_AUSENTE=0
  if [ -z "$ARNES_SENS" ]; then
    # AUSENTE. Sin la exigencia activada el sitio único devuelve la cadena vacía y manda el
    # valor heredado —`no`—, que es lo que `REQ-024 CA-05` contrata: un proyecto que no
    # activa nada CIERRA exactamente como cerraba. (La equivalencia se contrata sobre el
    # acto de CIERRE y no sobre «la puerta», que juzga más de uno: `ADR-011`, `SEC-083`.)
    # Con la exigencia activada devuelve el valor
    # que MÁS restringe (`si`), que CONSERVA el suelo de rigor en vez de retirarlo. La
    # bandera se publica para que un motivo de denegación pueda nombrar el campo que falta.
    ARNES_SENS_AUSENTE=1
    arnes_resuelve_ausencia "$ARNES_CLAVE_SENS" ''
    ARNES_SENS="${ARNES_AUSENCIA_APLICA:-no}"
    return 0
  fi
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
# --- La CLAVE del campo tambien se decora ---------------------------------------
# Es la OTRA MITAD de la misma linea que `arnes_norm_campo`, y hasta 1.30.3 solo una de
# las dos se leia con tolerancia: el VALOR se desenvolvia y la CLAVE se casaba contra el
# literal `^Clave:`. Quien escribe `**Estado:** completado` esta diciendo
# `Estado: completado`, y la maquina leia OTRA COSA.
#
# FALLA EN ABIERTO, que es lo que lo hace grave y no cosmetico: con
# `**Hallazgos abiertos:** SEC-9 (usuario/dinero)` la clave no casaba, el campo quedaba
# VACIO — y un campo vacio significa «ningun hallazgo». El REQ cerraba con un hallazgo
# de clase bloqueante declarado a la vista de cualquiera que leyera el documento.
#
# LA REGLA ES LA MISMA QUE LA DEL VALOR, y a proposito: se retira el espacio en blanco de
# los extremos y el enfasis de Markdown. NO es una lista de formas enumeradas —`**X:**`,
# `__X:__`, `*X:*`, `` `X:` ``, `X :`, ` X:`— porque una lista se pudre: es una REGLA, y
# vale para las formas que nadie ha escrito todavia.
#
# POR QUE NO SIRVE `arnes_desenvuelve` TAL CUAL: el par de enfasis puede CRUZAR los dos
# puntos (`**Estado:**`), asi que abre en la clave y cierra en el valor y ninguna de las
# dos mitades esta envuelta por su cuenta. Por eso, cuando la clave venia decorada, se
# retira tambien el cierre que quedo al principio del valor — y solo entonces, para que
# `Estado:**completado**` (valor decorado, clave limpia) siga siendo asunto del
# desenvoltorio del valor y no se le coma un asterisco.
#
# LO QUE **NO** CAMBIA: DONDE vale un campo. Los campos siguen valiendo solo en la
# cabecera, antes del primer `## ` — esta tolerancia es sobre COMO se escribe la clave,
# nunca sobre donde. Y no toca el sentido: leer de mas cae siempre del lado que CIERRA la
# puerta (un `**Rigor:** critico` se lee `critico`, nunca se rebaja).
#
# Sin procesos: solo expansion de parametros, igual que el resto del lector.
_arnes_recorta_blancos() {   # <texto> -> ARNES_TRIM
  local s="$1"
  s="${s#"${s%%[![:blank:]]*}"}"
  s="${s%"${s##*[![:blank:]]}"}"
  ARNES_TRIM="$s"
}

# --- LA CABECERA TIENE NOCION DE CITA: el interior de `<!-- ... -->` no declara ----
#
# EL DEFECTO QUE CIERRA, y es una REGRESION medida: un REQ `critico` cuyo veredicto de
# seguridad vigente NO autorizaba el cierre cerraba igual si su cabecera llevaba un rango
# de comentario con una linea que empezara por la clave del campo y un valor autorizante
# —incluso diciendo dentro del propio comentario que era historico—. Sale de la suma de
# TRES reglas que ninguna esta mal por separado: la tolerancia de enfasis en la CLAVE
# (`arnes_norm_clave`, que cerro un fail-open real y NO se recorta), que estos campos
# toman la ULTIMA aparicion de la cabecera, y que el lector no tenia noción de CITA.
# Juntas, cualquier linea de la cabecera que EMPIECE por la clave —viva donde viva— se
# convertia en el veredicto vigente.
#
# Y EL SITIO LO EMPEORA: el lugar donde un proyecto disciplinado escribe «este veredicto
# es historico y no es el vigente» es precisamente un comentario HTML. La convencion que
# existe para no confundir a la maquina era la que la confundia, asi que quien mejor
# documentaba la historia de sus veredictos se exponia mas.
#
# POR QUE ESTA SALIDA Y NO MAS TOLERANCIA. Es la cuarta instancia de una leccion propia
# (AGENTS.md 13, ADR-002, SEC-020): cuando un mecanismo interpreta texto humano libre,
# ensanchar la tolerancia no gana la clase. Aqui no hace falta interpretar nada: el rango
# del comentario esta DELIMITADO, asi que la pregunta es CERRADA. No se toca DONDE vale un
# campo ni CUAL gana; se acota DONDE se lee.
#
# LA REGLA, escrita una vez:
#   * lo que cae dentro de un rango `<!--` … `-->` no declara campo;
#   * el hueco se sustituye por UN ESPACIO, nunca por nada: pegar los dos extremos podria
#     FABRICAR una clave que nadie escribio (`Est<!--x-->ado: completado`), y un
#     comentario solo puede estrechar el juicio de la puerta, nunca abrirlo;
#   * NINGUN CARACTER SE DESCUENTA ANTES DE ESCANEAR EL RANGO, por la MISMA razon que el
#     hueco lleva un espacio: retirar un caracter no puede destruir un delimitador, pero
#     SI puede crearlo. Con el retorno de carro estaba medido —`-\r->` se convertia en
#     `-->` y `<!\r--` en `<!--`— y por esa via un veredicto CITADO gobernaba y un rango
#     que nunca cerraba parecia cerrado: el fail-open que esta regla vino a cerrar seguia
#     abierto (H-01, `docs/qa/1.32.1-hallazgos.md`). El descuento del CR ocurre DESPUES,
#     en `arnes_norm_clave`, donde ya no queda ningun delimitador que fabricar; asi la
#     tolerancia al CRLF no cambia y la clase entera —no una forma— queda cerrada;
#   * el rango CRUZA lineas, asi que el estado (`ARNES_CITA`) vive en el llamador: se pone
#     a 0 antes de recorrer una cabecera y se consulta al terminarla;
#   * un rango que ABRE y no CIERRA antes del fin de la cabecera deja una cabecera que no
#     se puede MEDIR, y una puerta que no puede medir no deja pasar: quien recorre la
#     cabecera lo publica (`ARNES_CITA_ABIERTA` / `ARNES_ESTADO_CITA`) y la puerta DENIEGA
#     citando el rango — nunca permite por AUSENCIA del campo que el rango se trago.
#
# DONDE NO SE APLICA, y la frontera va escrita a proposito: la cola de aprobaciones
# (`arnes_cola_pendientes`) tiene su propia noción de comentario, de grano de LINEA, que
# documenta REQ-009 (CA-04/CA-07) y que decide cuantas entradas bloquean el cierre.
# Unificarla aqui cambiaria ese CONTEO —`### Real <!-- nota -->` cuenta con esta regla y no
# con la suya—, y un cambio de conteo en la cola es un cambio de veredicto en la puerta.
# Son dos documentos y dos contratos distintos; el sitio unico de ESTA regla es esta
# funcion y `hooks/campos-req.awk` es su transcripcion declarada.
#
# LA FRONTERA SE MANTIENE, Y YA NO ES SOLO UN COMENTARIO: LO DECIDE `ADR-010` (REQ-024
# CA-10). La forma medida sobre la que los dos lectores deciden AL CONTRARIO es una
# anotacion de comentario CERRADA dentro de la propia linea —`### Real <!-- nota -->`—: la
# cabecera de un REQ sustituye el rango por un espacio y sigue juzgando el resto, y la cola
# descarta la linea entera. Cruzar la frontera cambiaria el conteo, o sea el veredicto de
# la puerta, o sea el contrato de REQ-009 CA-04/CA-07, que esta en estado terminal; asi que
# no se cruza en esta version. Y para que una divergencia futura falle una prueba en vez de
# descubrirse en una auditoria, el banco MIDE esa diferencia sobre esa misma forma
# (`tests/escenarios/hooks/secciones/31-cola-una-sola-regla.sh`, casos de REQ-024 CA-10).
#
# Sin procesos: solo expansion de parametros, como el resto del lector. Recorrer la
# cabecera entera —en vez de salir en la primera aparicion— no añade ni un fork.
# --- UN CR QUE NO TERMINA LA LINEA DEJA UNA CABECERA QUE NO SE PUEDE MEDIR ---------
#
# «NO FABRICAR» TIENE DOS CONSECUENCIAS OPUESTAS, Y AHI ESTUVO EL DEFECTO. La regla de
# arriba —ningun caracter se descuenta antes de escanear el rango— es correcta, y cierra
# la fabricacion del CIERRE: un `-\r->` ya no se lee como `-->`, el rango queda ABIERTO y
# la puerta DENIEGA. Pero aplicada al ABRE se invierte: un `<!\r--` ya no se lee como
# `<!--`, asi que el rango NUNCA SE ABRE y lo que el autor aparco dentro del comentario
# GOBIERNA. Medido (SEC-024, R-007): sobre una cabecera `critico` que no declaraba
# `Seguridad:` en absoluto, añadirle un rango con el abre fabricado y un
# `Seguridad: aprobado` dentro convertia un `deny` en `allow`. La clase tenia dos caras y
# solo una tenia caso.
#
# Y LA MISMA CARA POR OTRO OBJETIVO, sin comentario ninguno: `Seg\ruridad: aprobado`
# cerraba un `critico` porque `arnes_norm_clave` descuenta el CR DESPUES y FABRICA LA
# CLAVE. Bisecado: venia de <=1.30.3, no de este parche.
#
# POR QUE NO SE PERSIGUE LA VIA SINO EL ESTADO. Cubrir el `<!\r--` reconociendolo como
# delimitador seria volver a fabricar —y reabrir el cierre—; enumerar objetivos (`<!`,
# `-->`, cada clave) es la caza que este repositorio ha perdido cinco veces. La pregunta
# que no envejece no habla del objetivo: **una linea de la cabecera que contiene un CR que
# no es el que la TERMINA deja una cabecera que no se puede MEDIR**, y una puerta que no
# puede medir no deja pasar (AGENTS.md 1). Cubre las dos caras y cualquier objetivo futuro
# del mismo caracter.
#
# LO QUE NO TOCA, y por eso esta salida y no otra:
#   * NO estrecha ninguna tolerancia, asi que no reabre nada. `Estado: comple\rtado` deja
#     de leerse como estado terminal — pero por DENEGACION, no por AUSENCIA, que es la
#     unica direccion que el descarte de esa alternativa exigia.
#   * NO toca el CRLF: el CR que TERMINA la linea es transporte y sigue siendo transporte.
#     Un REQ entero en CRLF decide identico a su gemelo en LF (casos CA-04 del banco).
#   * NO cambia NADA de lo que este escaner devuelve: solo OBSERVA. Asi la transcripcion
#     de `hooks/campos-req.awk` sigue diciendo lo mismo byte a byte —el fuzz diferencial
#     compara valores de campo, no esta guarda— y el bloque derivado no cambia de opinion.
#   * Es coherente con lo que el arnes ya hace: los bytes de control C0 distintos de tab,
#     LF y CR se DENIEGAN, no se limpian. Esto solo retira la excepcion del CR alli donde
#     no es transporte.
#
# EL ORDEN ES LA MITAD DEL ARREGLO, y va aqui por CONSTRUCCION y no por inspeccion: la
# comprobacion es la PRIMERA sentencia del UNICO escaner de cabecera que hay. Toda boca
# que alimenta a un lector —el lector de linea, `arnes_jq_str`, la reconstruccion del
# documento del `Edit` con el CR en disco y `tools/arnes-paralelo.sh`— pasa por aqui con
# la linea cruda, asi que ninguna puede llegar «ya limpia» al escaner. Una guarda en una
# sola boca deja las otras tres abiertas; esta no vive en ninguna boca, vive en el escaner.
#
# El estado CRUZA lineas igual que el del rango, asi que vive en el llamador: se pone a 0
# antes de recorrer una cabecera y se consulta al terminarla. Quien la recorre lo publica
# (`ARNES_CR_INTERIOR` / `ARNES_ESTADO_CR`) y la puerta decide; aqui no se decide nada.
ARNES_CITA=0
ARNES_CR=0
ARNES_CR_LINEA=''
arnes_sin_cita() {   # <linea> -> ARNES_LINEA ; usa y actualiza ARNES_CITA / ARNES_CR
  # La linea se escanea CRUDA, con sus retornos de carro: descontarlos aqui FABRICABA los
  # delimitadores (ver la regla, arriba). Los quita `arnes_norm_clave`, aguas abajo.
  local l="$1" out=''
  # ANTES DE TOCAR NADA. La pregunta es la MISMA de siempre: descontado el CR final —el de
  # transporte—, ¿queda alguno? Y se hace SIN descontarlo, porque preguntar «hay un CR con
  # al menos un caracter detras» es la MISMA pregunta y cuesta lineal en vez de cuadratico:
  # `${l%$CR}` es eliminacion de sufijo CON PATRON, y bash la resuelve PROBANDO CADA
  # POSICION —O(n) intentos de O(n) cada uno—, asi que sobre una linea sin CR final recorre
  # la linea entera una vez por caracter. Medido (10 llamadas, 140 000 bytes, REQ-017):
  # `${l%$CR}` 3,63 s frente a 0,036 s de este glob, y el banco entero 92 s -> 39 s.
  # La EQUIVALENCIA es por construccion, no por casuistica: `*$CR?*` dice «existe un CR en
  # una posicion que no es la ultima», que es exactamente «tras quitar UN CR final todavia
  # queda un CR» — el CR final es el unico que la eliminacion podia retirar, y solo se
  # retira si esta al final. Frontera dura verificada de todos modos por comparacion
  # diferencial contra el arbol heredado (seccion 37 del banco, CA-01 de REQ-017).
  # Lo que NO cambia, y es la restriccion que gobierna esta linea: sigue siendo la PRIMERA
  # sentencia del UNICO escaner. Se abarata CUANDO se paga, no DONDE vive la comprobacion:
  # moverla a una de las cuatro bocas dejaria las otras tres abiertas (ver la regla arriba,
  # y REQ-016). Una expansion y un `case`: ni un fork.
  case "$l" in *$'\r'?*)
      # Se recuerda la PRIMERA, para que el motivo pueda citarla. El CR se muestra como
      # `\r`: un motivo con un CR crudo dentro se pisa a si mismo en cualquier terminal.
      [ "$ARNES_CR" -eq 1 ] || ARNES_CR_LINEA="${l//$'\r'/\\r}"
      ARNES_CR=1 ;;
  esac
  if [ "$ARNES_CITA" -ne 0 ]; then
    case "$l" in
      *'-->'*) l="${l#*-->}"; ARNES_CITA=0 ;;
      *)       ARNES_LINEA=''; return 0 ;;
    esac
  fi
  while :; do
    case "$l" in *'<!--'*) ;; *) break ;; esac
    out+="${l%%<!--*} "
    l="${l#*<!--}"
    case "$l" in
      *'-->'*) l="${l#*-->}" ;;
      *)       ARNES_CITA=1; ARNES_LINEA="$out"; return 0 ;;
    esac
  done
  ARNES_LINEA="$out$l"
}

# --- LAS CLAVES DE LA CABECERA: DECLARADAS UNA VEZ, Y DE AHI LAS DERIVA TODO -------
#
# POR QUE UNA CONSTANTE Y NO LOS BRAZOS DE UN `case`. Hasta 1.33.0 el conjunto de claves
# que este lector reconoce NO EXISTIA en ninguna parte de bash: vivia como la UNION de dos
# despachos DISJUNTOS —los cinco brazos de `arnes_campos_req` y el de
# `arnes_estado_cabecera`, que es el unico sitio donde vive la clave del estado terminal—,
# asi que nada podia preguntar «¿es esto un campo de cabecera?» sin volver a teclear la
# lista. Y una guarda que teclee su propia copia envejece hacia el lado que ABRE: un campo
# nuevo entra en los brazos, no entra en la guarda, y deja de estar protegido EN SILENCIO
# — que es exactamente la clase de SEC-050.
#
# Cada clave se escribe UNA vez, en su propia constante, y de esas constantes salen las dos
# cosas que antes se repetian: el CONJUNTO (`ARNES_CLAVES`, delimitado al estilo de
# `ARNES_VOCAB_*`, con pertenencia exacta por `arnes_en_vocab`) y los BRAZOS de los dos
# despachos, que siguen existiendo —cada uno asigna a SU variable, y la precedencia de cada
# clave no se toca— pero ya no DECIDEN quien es campo: eso lo decide la constante. El numero
# de transcripciones del conjunto BAJA de dos a una (REQ-023 CA-06).
#
# `Archivos:` NO esta aqui, y no es un hueco: lo resuelve `tools/arnes-paralelo.sh` con su
# propio mapeo —declarado por escrito alli—, su ausencia se resuelve del lado que CIERRA
# (`SIN DECLARAR` colisiona con todos y sale != 0) y NINGUNA puerta lo lee. Meterlo aqui
# meteria un campo de COORDINACION dentro del mecanismo de la puerta.
ARNES_CLAVE_QA='QA'
ARNES_CLAVE_SEG='Seguridad'
ARNES_CLAVE_SENS='Sensible a seguridad'
ARNES_CLAVE_HALL='Hallazgos abiertos'
ARNES_CLAVE_RIGOR='Rigor'
ARNES_CLAVE_ESTADO='Estado'
ARNES_CLAVES="$ARNES_CLAVE_QA|$ARNES_CLAVE_SEG|$ARNES_CLAVE_SENS|$ARNES_CLAVE_HALL|$ARNES_CLAVE_RIGOR|$ARNES_CLAVE_ESTADO"

# EL ALFABETO DE LAS CLAVES SE DERIVA DE LA CONSTANTE, NUNCA SE TECLEA. Una clave futura que
# llevara `-`, `]` o `^` romperia la expresion de corchete que la guarda construye, y una
# expresion de corchete rota no deniega: CALLA. Los tres se colocan donde son literales —`]`
# primero, `-` ultimo, `^` en cualquier posicion que no sea la primera— y de paso se
# deduplica, que abarata la comparacion. Se hace UNA vez al cargar la biblioteca y no cuesta
# ni un proceso: solo expansion de parametros.
_arnes_deriva_alfabeto() {   # ARNES_CLAVES -> ARNES_CLAVES_ALFA
  local resto="${ARNES_CLAVES//|/}" c letras='' cierra='' circun='' guion=''
  while [ -n "$resto" ]; do
    c="${resto:0:1}"; resto="${resto:1}"
    case "$cierra$letras$circun$guion" in *"$c"*) continue ;; esac
    case "$c" in
      ']') cierra=']' ;;
      '-') guion='-' ;;
      '^') circun='^' ;;
      *)   letras="$letras$c" ;;
    esac
  done
  ARNES_CLAVES_ALFA="$cierra$letras$circun$guion"
}
_arnes_deriva_alfabeto

# EL MAPA «CLAVE SIN BLANCOS -> CLAVE», TAMBIEN DERIVADO DE LA CONSTANTE Y POR EL MISMO
# MOTIVO. La guarda tiene que reconstruir la clave cuando lo insertado ES un blanco o cuando
# SUSTITUYO a uno (SEC-047 / QA-023-01, abajo), asi que compara sin blancos; pero el motivo de
# denegacion y la rama del estado terminal necesitan la clave TAL CUAL se escribe. El mapa
# guarda las dos, en pares `|sin-blancos|clave|`, y se construye UNA vez al cargar.
#
# LA BUSQUEDA ES INAMBIGUA POR CONSTRUCCION, no por casuistica: lo que se busca nunca lleva
# blancos —se le acaban de quitar—, y toda clave que no lleve blancos es IDENTICA a su forma
# sin blancos, asi que el primer `|x|` que aparece es siempre el primer campo de un par y el
# campo siguiente es su clave. `|` ya era el delimitador de `ARNES_CLAVES`: no se supone nada
# nuevo sobre lo que una clave puede contener.
ARNES_CLAVES_MAPA=''
_arnes_deriva_mapa() {   # ARNES_CLAVES -> ARNES_CLAVES_MAPA
  local resto="$ARNES_CLAVES" k
  ARNES_CLAVES_MAPA='|'
  while :; do
    k="${resto%%|*}"
    ARNES_CLAVES_MAPA="$ARNES_CLAVES_MAPA${k//[[:blank:]]/}|$k|"
    case "$resto" in *'|'*) resto="${resto#*|}" ;; *) break ;; esac
  done
}
_arnes_deriva_mapa

# --- EL SITIO UNICO DE LA DIRECCION DE LA AUSENCIA (REQ-024 CA-02, ADR-009) -----------
#
# LA PREGUNTA QUE ESTA TABLA CONTESTA: cuando un campo de cabecera NO llega a declararse
# —comentado, borrado, o nunca escrito: la puerta no mide la VIA, mide la AUSENCIA—, ¿que
# hace la maquina? Hasta 1.33.0 la respuesta vivia en DOS sitios y para cuatro de los seis
# campos era «abrir»: `arnes_sens_efectiva` retiraba el SUELO de sensibilidad,
# `arnes_rigor_efectivo` caia a `estandar`, y en la puerta los `[ -n "$qa" ]` /
# `[ -n "$hall" ]` saltaban la comprobacion entera. Medido (SEC-047 mitad 2, R-013 §2): un
# REQ `critico` con los dos veredictos en `pendiente` cerraba comentando UNA linea.
#
# LAS TRES DIRECCIONES POSIBLES, Y LA PROHIBIDA ES LA TERCERA:
#   * `gobierna:<valor>` — se aplica el valor que MAS RESTRINGE. Vale cuando existe tal
#     valor y aplicarlo no inventa nada que nadie haya firmado: el suelo de sensibilidad y
#     el nivel de rigor son exactamente eso.
#   * `deniega` — no se deja pasar, y el motivo NOMBRA el campo que falta. Vale para los
#     VEREDICTOS y para la clase del hallazgo: «gobernar» ahi seria fabricar una firma que
#     nadie emitio, que es peor que no tenerla.
#   * `n/a` — el campo no es una EXIGENCIA que su ausencia pueda activar. Solo `Estado`:
#     es el SUJETO de la transicion. Sin el no hay cierre que juzgar, asi que su ausencia
#     no abre ninguna puerta — no hay puerta.
#   Y la tercera salida, la de hasta 1.33.0, es la que esta tabla existe para no tener:
#   ABRIR. Cual corresponde a cada campo lo decide `ADR-009`; que ninguno abra lo contrata
#   `REQ-024 CA-01`.
#
# POR QUE ES UNA TABLA DERIVADA Y NO UN `case` EN CADA SITIO. Las claves salen de las
# constantes `ARNES_CLAVE_*` de arriba (REQ-023 CA-06), asi que un campo nuevo entra en la
# tabla por el MISMO sitio por el que entra en el lector, y `REQ-024 CA-02` exige que un
# campo que llegue al lector SIN declarar su direccion aqui haga fallar el banco NOMBRANDO
# esa clave. Los dos despachos (`arnes_campos_req`, `arnes_estado_cabecera`) siguen
# existiendo y siguen enrutando cada clave a SU variable; lo que ya no hacen es DECIDIR.
#
# COSTE: cero procesos. Es una cadena delimitada al estilo de `ARNES_CLAVES` y se consulta
# con `case` + expansion de parametros, igual que `arnes_en_vocab` (REQ-024 CA-07 i).
#
# LA BUSQUEDA ES INAMBIGUA POR CONSTRUCCION, como la de `ARNES_CLAVES_MAPA`: lo que se
# busca es siempre una CLAVE entre barras (`|Rigor|`), ninguna clave es subcadena
# delimitada de otra, y ningun VALOR de direccion coincide con una clave.
ARNES_AUSENCIA_GOBIERNA_SENS='si'        # el valor que MAS restringe: conserva el suelo
ARNES_AUSENCIA_GOBIERNA_RIGOR='critico'  # el valor que MAS restringe: el techo de ceremonia
ARNES_AUSENCIA=''
_arnes_deriva_ausencia() {   # ARNES_CLAVE_* -> ARNES_AUSENCIA
  ARNES_AUSENCIA="|$ARNES_CLAVE_QA|deniega|$ARNES_CLAVE_SEG|deniega|"
  ARNES_AUSENCIA+="$ARNES_CLAVE_SENS|gobierna:$ARNES_AUSENCIA_GOBIERNA_SENS|"
  ARNES_AUSENCIA+="$ARNES_CLAVE_HALL|deniega|"
  ARNES_AUSENCIA+="$ARNES_CLAVE_RIGOR|gobierna:$ARNES_AUSENCIA_GOBIERNA_RIGOR|"
  ARNES_AUSENCIA+="$ARNES_CLAVE_ESTADO|n/a|"
}
_arnes_deriva_ausencia

# La direccion declarada para una clave -> ARNES_AUSENCIA_DIR. Rc 1 = esa clave NO declara
# direccion en el sitio unico, y eso es fail-closed: quien pregunte trata el rc 1 como
# `deniega`. Un campo nuevo que llegue al lector sin pasar por aqui no queda perdonado en
# silencio; ademas el banco falla nombrandolo (REQ-024 CA-02).
arnes_ausencia() {   # <clave> -> ARNES_AUSENCIA_DIR ; 0 = declarada, 1 = NO declarada
  local r
  ARNES_AUSENCIA_DIR=''
  case "$ARNES_AUSENCIA" in
    *"|$1|"*) r="${ARNES_AUSENCIA#*"|$1|"}"; ARNES_AUSENCIA_DIR="${r%%|*}" ;;
    *) return 1 ;;
  esac
  [ -n "$ARNES_AUSENCIA_DIR" ] || return 1
  return 0
}

# EL UNICO SITIO QUE DECIDE. Los tres lectores que resuelven ausencia —la puerta, el
# informe y el bloque derivado— pasan por aqui y por ningun otro sitio.
#
# LA EXIGENCIA ESTA APAGADA SALVO QUE EL PROYECTO LA ENCIENDA (`campos.ausencia_exige`),
# y eso NO es timidez: si la ausencia dejara de perdonarse por defecto, todo REQ heredado
# de todo proyecto instalado que no declare un campo dejaria de cerrar el dia de la
# actualizacion, y la friccion termina con alguien apagando el guard (AGENTS.md 13) — un
# guard apagado protege menos que uno parcial. `REQ-024 CA-05` lo contrata como criterio:
# en ESTA version, un proyecto que no activa nada CIERRA exactamente como cerraba.
#
# Y EL SUJETO ES UN ACTO, NO «la puerta»: esta funcion es la que perdona la ausencia sin la
# llave, pero la guarda del ORDEN de las firmas NO pasa por ella —pregunta la DIRECCION a
# `arnes_ausencia` y deniega en los DOS estados de la llave (SEC-083, salida (b) de CA-12)—,
# asi que la equivalencia contratada es la del CIERRE y no la de cualquier acto (ADR-011).
arnes_resuelve_ausencia() {   # <clave> <valor leido> -> ARNES_AUSENCIA_APLICA ; 1 = DENIEGA
  ARNES_AUSENCIA_APLICA="$2"; ARNES_AUSENCIA_FALTA=''
  [ -z "$2" ] || return 0                                    # presente: nada que resolver
  [ "${ARNES_AUSENCIA_EXIGE:-false}" = true ] || return 0     # sin activar: como siempre
  arnes_ausencia "$1" || { ARNES_AUSENCIA_FALTA="$1"; return 1; }
  case "$ARNES_AUSENCIA_DIR" in
    gobierna:*) ARNES_AUSENCIA_APLICA="${ARNES_AUSENCIA_DIR#gobierna:}"; return 0 ;;
    n/a)        return 0 ;;
    *)          ARNES_AUSENCIA_FALTA="$1"; return 1 ;;
  esac
}

# LOS BYTES AJENOS DE UNA CLAVE, EN HEXADECIMAL -> ARNES_REPR.
#
# Un motivo de denegacion que lleva dentro el caracter invisible deja a la persona buscando
# texto que su editor no le muestra: es la misma leccion que el CR escrito `\r`. Aqui se
# escribe cada byte que no pertenece al alfabeto como `\xNN` y se deja el resto legible, asi
# que el motivo dice DONDE esta y QUE es.
#
# `local LC_ALL=C` y no una comparacion de rangos: en un locale UTF-8 `${s:i:1}` devuelve un
# CARACTER y en locale C un BYTE, de modo que sin fijarlo el motivo cambiaria con el entorno
# — y un veredicto o un motivo que dependen de `LC_CTYPE` son un fallo en abierto POR
# ENTORNO, invisible en la puerta requerida de `main` (REQ-023 CA-05). `printf -v` es un
# builtin: cero procesos. Solo se ejecuta cuando la guarda ya ha disparado.
# EL BLANCO PERTENECE AL ALFABETO —viene de las claves multi-palabra— asi que por defecto se
# imprime tal cual, que es lo legible: `\xef\xbb\xbfSensible a seguridad`. Pero cuando lo
# insertado ES un blanco o SUSTITUYO a uno, imprimirlo tal cual deja el motivo diciendo
# exactamente la misma palabra que la persona cree haber escrito, y entonces el motivo no
# diagnostica nada: «Sensible a  seguridad» y «Sensible a seguridad» son la misma linea en
# cualquier terminal. El segundo argumento decide, y quien lo decide NO es una lista de casos:
# es si retirar lo AJENO bastaba para reconstruir la clave (ver `_arnes_clave_oculta`). Si
# bastaba, los blancos estan intactos y no son la insercion; si no bastaba, alguno de ellos
# forma parte de lo insertado y se escribe en hexadecimal.
ARNES_REPR=''
_arnes_repr_clave() {   # <clave> <blancos-en-hexadecimal: 0|1> -> ARNES_REPR
  local LC_ALL=C s="$1" hexblanco="$2" i c out='' n
  for ((i = 0; i < ${#s}; i++)); do
    c="${s:i:1}"
    if [ "$hexblanco" -eq 1 ]; then
      case "$c" in [[:blank:]]) printf -v n '%02x' "'$c"; out+="\\x$n"; continue ;; esac
    fi
    case "$c" in
      [$ARNES_CLAVES_ALFA]) out+="$c" ;;
      *) printf -v n '%02x' "'$c"; out+="\\x$n" ;;
    esac
  done
  ARNES_REPR="$out"
}

# La GUARDA, en su propia funcion y por dos motivos MEDIDOS, no por estilo -----------
#
# 1. EL LOCALE SE FIJA A `C`, Y ES LA DIFERENCIA ENTRE LINEAL Y CUADRATICO. La limpieza es
#    `${clave//[!alfabeto]/}`, y esa sustitucion en un locale UTF-8 sale SUPERLINEAL:
#    medido con `tests/util/sonda-reloj.sh` sobre una clave de tipo titulo, cociente de
#    duplicacion **3,78 (1000→2000) y 5,59 (2000→4000)** contra un techo de 2,2, y **11,9 ms
#    a 4 000 bytes**. La MISMA expresion con `LC_ALL=C` da **1,79 y 2,01** y baja el coste
#    absoluto **17×** (33 µs contra 564 µs a 1 000 bytes). El motivo es que en UTF-8 cada
#    posicion se decodifica; en C la comparacion es de bytes. Es exactamente la regresion de
#    orden de crecimiento que `REQ-023 CA-09 (iii)` existe para cazar, y la cazo: la primera
#    version de esta guarda no cumplia su propio techo.
# 2. Y NO ES SOLO COSTE: EL VEREDICTO TIENE QUE SER INVARIANTE AL LOCALE (CA-05). Una
#    clasificacion que dependa de `LC_CTYPE` deniega en el CI de Linux y permite en
#    Windows/MSYS —que es donde viven los proyectos consumidores y de donde sale el BOM—:
#    seria un fallo en abierto POR ENTORNO, invisible en la puerta requerida de `main`.
#    Con bytes no hay nada que decodificar, asi que el resultado es el mismo por
#    construccion, no por casuistica.
#
# EL LOCALE SE FIJA CON `local` Y AQUI DENTRO, no en `arnes_norm_clave`: fuera de esta
# funcion `[[:blank:]]` y el recorte de blancos siguen decidiendo con el locale del entorno,
# exactamente como antes de esta version. Cambiarlo alli seria mover una tolerancia que este
# REQ no toca (CA-04).
#
# Y LA RECONSTRUCCION TIENE QUE IGNORAR LOS BLANCOS, porque EL ALFABETO CONTIENE EL BLANCO.
# Sin eso la guarda falla EN ABIERTO para todo lo que pertenezca al alfabeto, y SEC-047 fila 1
# y fila 2 seguian abiertas con un caracter distinto: medido en `QA-023-01`. El alfabeto se
# DERIVA de las seis claves y dos son multi-palabra, asi que `0x20` esta dentro de el —
# retirar «lo ajeno» no retira un blanco INSERTADO (`Est ado`, `Sensible a  seguridad`) y
# retira el ajeno que SUSTITUYO a un blanco sin reponerlo (`Sensible a<NBSP>seguridad`,
# `Hallazgos<TAB>abiertos`)—. En los dos casos lo que quedaba NO era una clave, la guarda
# CALLABA, y la linea se resolvia como AUSENCIA del campo, que es justo lo que la puerta
# perdona: un `allow` con otro nombre.
#
# La salida son DOS pasos y ninguna enumeracion: (1) se retira lo ajeno al alfabeto, (2) se
# retiran TODOS los blancos, y se pregunta si lo que queda es una clave SIN SUS BLANCOS.
# Insercion, sustitucion y duplicacion del blanco caen con la MISMA pregunta. Y no deniega de
# mas: sigue denegando SOLO cuando la reconstruccion ES una clave del lector, asi que lo que
# no reconstruye ninguna —`Modulo`, `Version destino`, `Archivos`, una linea de titulo— sigue
# sin disparar nada (CA-04). Lo que queda FUERA, dicho aqui y no descubierto luego: sustituir
# una LETRA (`Еstado` con la `Е` cirilica) no reconstruye nada, porque reponer *que* letra
# exige elegir entre candidatos — reponer un blanco no elige (REQ-023, «Fuera de alcance»).
_arnes_clave_oculta() {   # <clave normalizada> -> ARNES_CLAVE_OCULTA[_CLAVE|_REPR]
  local LC_ALL=C ajeno limpio resto canon
  # EL ATAJO YA NO PUEDE SER «no contiene nada ajeno»: `Sensible a  seguridad` no contiene
  # nada ajeno y es exactamente uno de los dos casos que faltaban. Es «ES una clave», que
  # ademas es mas barato —un `case` sobre una cadena corta contra un barrido de corchete— y
  # deja fuera, por construccion, toda clave legitima: la que se escribe bien no se toca.
  arnes_en_vocab "$1" "$ARNES_CLAVES" && return 0
  ajeno="${1//[!$ARNES_CLAVES_ALFA]/}"      # (1) retirado lo ajeno al alfabeto...
  limpio="${ajeno//[[:blank:]]/}"           # (2) ...y retirados los blancos
  case "$ARNES_CLAVES_MAPA" in
    *"|$limpio|"*) resto="${ARNES_CLAVES_MAPA#*"|$limpio|"}"; canon="${resto%%|*}" ;;
    *) return 0 ;;                          # no reconstruye ninguna clave: aqui no hay nada
  esac
  ARNES_CLAVE_OCULTA=1
  ARNES_CLAVE_OCULTA_CLAVE="$canon"
  if [ "$ajeno" = "$canon" ]; then _arnes_repr_clave "$1" 0; else _arnes_repr_clave "$1" 1; fi
  ARNES_CLAVE_OCULTA_REPR="$ARNES_REPR"
  return 0
}

# --- UNA CABECERA QUE NO SE PUEDE MEDIR NO DEJA CERRAR: EL ESTADO ACUMULADO --------
# Igual que `ARNES_CITA` y `ARNES_CR`: cruza lineas, asi que vive en el llamador. Se pone a
# 0 antes de recorrer una cabecera y se consulta al terminarla.
ARNES_OCULTA=0
ARNES_OCULTA_CLAVE=''
ARNES_OCULTA_REPR=''
ARNES_OCULTA_ESTADO=''

# La UNICA puerta de entrada de un lector de cabecera: retira las citas y normaliza la
# clave. Existe para que ningun recorrido de cabecera pueda quedarse con la mitad de la
# regla — que es exactamente como nacio este defecto.
arnes_campo_linea() {   # <linea> -> 0 + ARNES_CLAVE/ARNES_VALOR; 1 si no declara campo
  arnes_sin_cita "$1"
  arnes_norm_clave "$ARNES_LINEA" || return 1
  # LA PUBLICACION DE LA GUARDA VIVE AQUI, EN LA PUERTA DE ENTRADA, Y NO EN
  # `arnes_norm_clave` — y no es una preferencia, es lo que la medicion obliga.
  # `arnes_estado_cabecera` llama a `arnes_norm_clave` TAMBIEN con la linea CRUDA, pre-cita
  # y a proposito, para distinguir «aqui no hay estado» de «alguien declara el estado desde
  # dentro de una cita». Publicando desde ahi, un campo LEGITIMAMENTE COMENTADO sin espacio
  # —`<!--Estado: completado -->`— disparia la guarda y el de CON espacio no: un falso
  # positivo cuyo veredicto depende de si quien escribio el comentario puso un espacio
  # (medido; REQ-023 CA-06 y CA-11). Aqui la cita ya se retiro, asi que lo que llega es lo
  # que el documento DECLARA.
  if [ "$ARNES_CLAVE_OCULTA" -eq 1 ]; then
    # La PRIMERA manda, para que el motivo pueda citarla.
    if [ "$ARNES_OCULTA" -eq 0 ]; then
      ARNES_OCULTA=1
      ARNES_OCULTA_CLAVE="$ARNES_CLAVE_OCULTA_CLAVE"
      ARNES_OCULTA_REPR="$ARNES_CLAVE_OCULTA_REPR"
      # Y EL ESTADO QUE ESA LINEA DECLARABA, por el mismo motivo que `ARNES_ESTADO_CITADO`:
      # sin esto, un caracter invisible sobre la clave del estado terminal se resolveria
      # como AUSENCIA del estado —«aqui no hay transicion»— y la ausencia es justo lo que
      # esta puerta perdona. El documento diria `completado` y ninguna puerta lo habria
      # medido nunca: un `allow` con otro nombre.
      case "$ARNES_OCULTA_CLAVE" in "$ARNES_CLAVE_ESTADO")
        arnes_norm_campo "$ARNES_VALOR"; arnes_veredicto "$ARNES_CAMPO"
        ARNES_OCULTA_ESTADO="$ARNES_VEREDICTO" ;;
      esac
    fi
  fi
  return 0
}

arnes_norm_clave() {   # <linea> -> 0 + ARNES_CLAVE/ARNES_VALOR; 1 si la linea no declara campo
  ARNES_CLAVE=''; ARNES_VALOR=''; ARNES_CLAVE_DECORADA=0
  ARNES_CLAVE_OCULTA=0; ARNES_CLAVE_OCULTA_CLAVE=''; ARNES_CLAVE_OCULTA_REPR=''
  local l="${1//$'\r'/}" k r crudo limpio
  case "$l" in *:*) ;; *) return 1 ;; esac
  crudo="${l%%:*}"
  _arnes_recorta_blancos "$l"; l="$ARNES_TRIM"
  k="${l%%:*}"; r="${l#*:}"
  # ¿El enfasis abria en la clave? Entonces su cierre quedo al principio del valor.
  case "$k" in [*_\`]*) r="${r#"${r%%[!*_\`]*}"}" ;; esac
  k="${k//\*/}"; k="${k//_/}"; k="${k//\`/}"
  _arnes_recorta_blancos "$k"
  ARNES_CLAVE="$ARNES_TRIM"; ARNES_VALOR="$r"
  # ¿La clave venia DECORADA o sangrada? Se DERIVA de la propia normalizacion —lo que la
  # regla tuvo que retirar—, nunca de una lista de formas: `**Estado:**`, ` Estado:`,
  # `Estado :` y las que nadie ha escrito todavia caen igual. No cambia NADA de lo que la
  # puerta decide (CA-04: la tolerancia sigue gobernando); existe para que
  # `tools/arnes-lectura.sh` pueda NOMBRAR la linea que gobierna cuando la forma es
  # legitima pero el documento se lee distinto de como parece.
  [ "$ARNES_CLAVE" = "$crudo" ] || ARNES_CLAVE_DECORADA=1
  # --- UNA CLAVE CON ALGO INSERTADO DENTRO NO SE PUEDE MEDIR (REQ-023 CA-01) --------
  #
  # EL DEFECTO QUE CIERRA, medido ejecutando la puerta real (SEC-047, R-012) e IDENTICO en
  # `v1.30.3`, `v1.31.0`, `v1.32.0` y `v1.32.1`: un BOM delante de `Sensible a seguridad: si`
  # —el que PowerShell añade al redirigir— con `Rigor: ligero` cerraba a `completado` un REQ
  # con `QA: pendiente` y `Seguridad: pendiente`; sin el BOM, denegaba. Un `0xc3` suelto o un
  # U+200B delante de `Hallazgos abiertos:` retiran un hallazgo `contrato` que bloqueaba. El
  # caracter BORRA el campo, y para todo campo cuya AUSENCIA esta puerta resuelve del lado
  # que abre, borrarlo es abrirla. Nada lo delata: el diff tampoco lo muestra.
  #
  # POR QUE NO SE PERSIGUE EL CARACTER SINO EL ESTADO. La guarda del CR (REQ-016 CA-12) esta
  # bien construida y aun asi no ve esto: nombra EL CR cuando la propiedad verdadera es «una
  # linea de la cabecera que la maquina no puede MEDIR». Añadir el BOM y el U+200B a una
  # lista seria la SEXTA derrota medida de esa via en este repositorio (ADR-002, SEC-020,
  # SEC-024, SEC-025, H-01): un `0xc3` suelto, un U+2060, un multibyte invalido o el que
  # nadie ha pensado la reproducen, y una lista escrita en un contrato envejece hacia el lado
  # que ABRE.
  #
  # LA PREGUNTA QUE NO ENVEJECE, y no enumera ningun caracter porque enumera lo que YA esta
  # enumerado, que son las CLAVES: retirado de la clave todo lo ajeno al ALFABETO de las
  # claves que este lector reconoce Y TODOS SUS BLANCOS, ¿lo que queda ES una de esas claves
  # sin sus blancos? Si lo es, alguien inserto algo DENTRO de una clave y la linea no se puede
  # medir. Cubre las tres familias —bytes de control C0, puntos de codigo de anchura cero o de
  # formato, y secuencias UTF-8 mal formadas—, cubre el BLANCO insertado, sustituido o
  # duplicado (que pertenece al alfabeto y por eso se le escapaba: `QA-023-01`), y cubre
  # cualquier entrada que nadie haya nombrado todavia.
  #
  # LO QUE NO TOCA, y por eso esta salida y no otra:
  #   * NO estrecha ninguna tolerancia, asi que no puede reabrir nada. La clave decorada o
  #     sangrada, el paréntesis de evidencia, el plegado de ortografia y un documento entero
  #     en CRLF siguen gobernando idéntico: el CR se descuenta arriba, antes de llegar aqui.
  #   * NO deniega por AUSENCIA: publica que la cabecera no se puede medir, y la puerta
  #     deniega por eso. Un `deny` por «el campo falta» seria un `allow` con otro nombre en
  #     cuanto el rigor declarado fuese `ligero`.
  #   * CALLA sobre lo que no es una clave del lector: `Modulo:`, `Version destino:`,
  #     `Archivos:`, `Prioridad:` y las lineas de titulo con `—` o `«»` llevan caracteres
  #     ajenos al alfabeto y no quedan en ninguna clave al limpiarlas. Una guarda que
  #     denegara `Modulo:` produciria friccion constante, y la friccion termina con alguien
  #     apagando el guard (AGENTS.md 13) — un guard apagado protege menos que uno parcial.
  #   * NO cambia NINGUN valor de campo: solo OBSERVA. Asi la transcripcion declarada de
  #     `hooks/campos-req.awk` sigue diciendo lo mismo y el bloque derivado no cambia de
  #     opinion.
  #   * Un comentario legitimo no dispara nada porque la publicacion vive en
  #     `arnes_campo_linea`, DESPUES de retirar la cita — y no porque `<!-- Estado` limpie a
  #     ` Estado`, que era lo que sostenia esta linea hasta que la reconstruccion empezo a
  #     ignorar los blancos. Con el blanco fuera de la comparacion, `<!--Estado` y
  #     `<!-- Estado` reconstruyen los DOS, asi que la unica cosa que separa un comentario de
  #     una clave corrompida es el orden: primero la cita, despues la guarda.
  #
  # COSTE: la comparacion contra el alfabeto es la GUARDA, asi que una clave legitima paga
  # UNA expansion de corchete y ni una sustitucion. Cero procesos (REQ-023 CA-09).
  _arnes_clave_oculta "$ARNES_CLAVE"
  return 0
}

arnes_campos_normaliza() {   # <qa> <seg> <sens> <hall> <rigor> -> ARNES_QA/SEG/SENS/HALL/RIGOR
  arnes_norm_campo "$1"; arnes_veredicto "$ARNES_CAMPO"; ARNES_QA="$ARNES_VEREDICTO"
  arnes_norm_campo "$2"; arnes_veredicto "$ARNES_CAMPO"; ARNES_SEG="$ARNES_VEREDICTO"
  arnes_norm_campo "$3"; ARNES_SENS="$ARNES_CAMPO"
  arnes_norm_campo "$4"; ARNES_HALL="$ARNES_CAMPO"
  arnes_norm_campo "$5"
  # Los niveles simples ya quedaron normalizados arriba; sólo la evidencia
  # parentética necesita el veredicto común. Así el camino habitual no paga
  # una segunda normalización por cada cabecera leída.
  #
  # Y se ANOTA que el nivel salió de desenvolver un paréntesis. No es
  # contabilidad: es la diferencia entre leer y CONCEDER. Desenvolver
  # `critico (por suelo)` corrige un fail-open; desenvolver `ligero (local)`
  # abre otro más ancho, porque `ligero` es el unico nivel exento de
  # `QA: aprobado`. El desenvoltorio no puede decidir eso solo -- necesita
  # saber `arnes_rigor_efectivo` que el valor venia envuelto.
  ARNES_RIGOR_MATIZ=0
  case "$ARNES_CAMPO" in
    *'('*) arnes_veredicto "$ARNES_CAMPO"; ARNES_RIGOR="$ARNES_VEREDICTO"; ARNES_RIGOR_MATIZ=1 ;;
    *) ARNES_RIGOR="$ARNES_CAMPO" ;;
  esac
  arnes_sens_efectiva
  arnes_rigor_efectivo
}

# Campo crudo anterior para distinguir una firma de una edición de prosa.
# Comparte el lector de campos, incluida la decoración y las citas, y sólo se
# consulta al juzgar el orden; no agrega trabajo al cierre normal.
arnes_seguridad_cabecera() {   # <documento> -> ARNES_SEG_CABECERA
  local l ARNES_CITA=0 ARNES_CR=0 ARNES_CR_LINEA=''
  local ARNES_LINEA ARNES_CLAVE ARNES_VALOR ARNES_CLAVE_DECORADA
  ARNES_SEG_CABECERA=''
  while IFS= read -r l; do
    case "$l" in '## '*) break ;; esac
    arnes_campo_linea "$l" || continue
    [ "$ARNES_CLAVE" != "$ARNES_CLAVE_SEG" ] || ARNES_SEG_CABECERA="$ARNES_VALOR"
  done <<< "$1"
}

# --- ¿QUE HACE ESTE TEXTO CON ESTA CLAVE? SE PREGUNTA AL LECTOR, NUNCA A UNA CADENA ---
#
# EXISTE PORQUE LA PREGUNTA SE ESTABA HACIENDO DOS VECES Y CON DOS ALFABETOS. Una guarda
# que decide si un acto «se entra» tiene que reconocer EL MISMO conjunto de formas que
# despues gobierna la decision; si no, la diferencia entre los dos conjuntos es
# exactamente el agujero. Medido dos veces en esta misma familia:
#   * `SEC-084`: el disparador del ORDEN reconocia la cadena `Seguridad:` y el lector
#     reconoce la clave DECORADA (`REQ-016 CA-04`, tolerancia contratada), asi que
#     `_Seguridad_: aprobado` se firmaba sin que ninguna guarda la juzgara Y GOBERNABA el
#     cierre. `v1.33.1` lo cerro en esa sede cambiando el disparador por el VALOR leido.
#   * `QA-024-19` y lo que aquel arreglo no toco: el disparador del AVISO —la otra sede,
#     en el mismo archivo— seguia siendo la MISMA cadena literal. De ahi las dos mitades
#     que esta funcion responde, y que son una sola propiedad.
#
# LA PROPIEDAD, Y POR ESO SON TRES RESPUESTAS Y NO DOS:
#   `lee`     el lector lee esa linea COMO ese campo. Es el conjunto que gobierna, con
#             las formas de hoy y con las que nadie ha escrito todavia: no se enumera
#             ninguna, se pregunta al lector.
#   `desfase` hay una linea que UNA PERSONA lee como ese campo y el lector NO. Plegada la
#             clave con `arnes_norm_campo` —el mismo plegado que el arnes ya aplica a los
#             valores: blancos, marcado, ortografia y caja— coincide con la clave, y sin
#             plegar no. La minuscula (`seguridad:`) es la INSTANCIA medida; la clase la
#             cierra el plegado, no una lista de tres cadenas.
#   `no`      esa clave no aparece en la cabecera de este texto.
#
# `desfase` NO ES UN VEREDICTO Y NO PUEDE SERLO. El camino fail-closed es correcto —el
# lector no lee esa linea, asi que el REQ sigue SIN ese campo y el cierre lo deniega por
# ausencia— pero era MUDO: quien escribio la firma creia haberla escrito y nada se lo
# decia. Esto no cambia ninguna decision; da el diagnostico que faltaba. Ensanchar el
# LECTOR para que aceptara la minuscula si moveria decisiones y estrecharia `CA-04` por el
# otro lado: no se hace.
#
# NO SE SALE EN EL PRIMER `desfase`: la cabecera se recorre hasta encontrar un `lee`, que
# manda. Una cabecera con `seguridad: aprobado` Y `Seguridad: pendiente` declara el campo,
# y quedarse con el desfase avisaria de algo que no es cierto.
#
# COSTE: cero procesos. Sustituye DOS `grep` —dos forks por edicion de un REQ— por un
# recorrido de cabecera que ademas para en el primer `## `, donde el `grep` leia el
# documento entero. La guarda de entrada es la del propio lector (`arnes_norm_clave`: sin
# dos puntos no hay campo), asi que un texto sin `:` no paga ni el recorrido.
#
# LOS ACUMULADORES DEL ESCANER VAN `local` A PROPOSITO. `arnes_campo_linea` publica el
# estado de la cabecera que las puertas consultan (`ARNES_OCULTA…`, `ARNES_CITA`,
# `ARNES_CR`); esta funcion se llama en mitad del juicio y no debe moverlo. Solo OBSERVA:
# si pisara esos acumuladores cambiaria veredictos ajenos sin que nadie lo viera, que es
# la forma de defecto que este arreglo viene a cerrar.
arnes_declara_clave() {   # <texto> <clave> -> ARNES_DECLARA=lee|desfase|no ; ARNES_DECLARA_LINEA
  ARNES_DECLARA='no'; ARNES_DECLARA_LINEA=''
  case "$1" in *:*) ;; *) return 0 ;; esac
  local l objetivo
  local ARNES_CITA=0 ARNES_CR=0 ARNES_CR_LINEA='' ARNES_LINEA
  local ARNES_CLAVE ARNES_VALOR ARNES_CLAVE_DECORADA ARNES_CAMPO
  local ARNES_CLAVE_OCULTA ARNES_CLAVE_OCULTA_CLAVE ARNES_CLAVE_OCULTA_REPR
  local ARNES_OCULTA=0 ARNES_OCULTA_CLAVE='' ARNES_OCULTA_REPR='' ARNES_OCULTA_ESTADO=''
  arnes_norm_campo "$2"; objetivo="$ARNES_CAMPO"
  while IFS= read -r l; do
    case "$l" in '## '*) break ;; esac
    arnes_campo_linea "$l" || continue
    if [ "$ARNES_CLAVE" = "$2" ]; then ARNES_DECLARA='lee'; ARNES_DECLARA_LINEA=''; return 0; fi
    [ "$ARNES_DECLARA" = 'no' ] || continue
    arnes_norm_campo "$ARNES_CLAVE"
    [ "$ARNES_CAMPO" = "$objetivo" ] || continue
    ARNES_DECLARA='desfase'; ARNES_DECLARA_LINEA="$ARNES_CLAVE"
  done <<< "$1"
  return 0
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
# --- Vocabulario de los veredictos: declarado UNA vez ---------------------------
# Lo usan la puerta (para avisar de un valor que no existe) y `tools/arnes-lectura.sh`
# (para no reportar como anomalia lo que la puerta lee perfectamente). Dos copias de la
# misma lista se desfasan -- es el mismo defecto que tenia el parentesis de evidencia,
# solo que con el vocabulario: medido en un proyecto real, 28 de 42 anomalias del
# informe eran falsas porque el informe leia distinto de la puerta.
#
# NO es configurable desde el manifiesto: los veredictos son el MECANISMO del arnes, no
# mapeo del proyecto. Un proyecto que redefiniera "aprobado" redefiniria la puerta.
ARNES_VOCAB_QA='pendiente|aprobado|con-hallazgos'
# `con-hallazgos` tambien en Seguridad: entre `pendiente` ("no he mirado") y `vetado`
# (freno formal con remedio, dueno y umbral) faltaba lo intermedio, que es el estado mas
# comun de una auditoria real. Medido: cinco REQ de un proyecto ya lo escribian porque el
# vocabulario no les daba la palabra -- cuando la gente escribe un valor que la
# herramienta no tiene, la incompleta es la herramienta. Sigue sin cerrar: sirve para
# decir la verdad, no para firmar.
ARNES_VOCAB_SEG='n/a|pendiente|aprobado|con-hallazgos|preventiva|vetado'
ARNES_VOCAB_RIGOR='ligero|estandar|critico'
# Pertenencia EXACTA y delimitada (`|valor|`), nunca por prefijo: `en-revision-parcial`
# no es `en-revision`. Sin procesos.
arnes_en_vocab() {   # <valor normalizado> <vocabulario a|b|c>
  case "|$2|" in *"|$1|"*) return 0 ;; esac
  return 1
}

# Primera fecha ISO dentro de un texto -> ARNES_FECHA (vacio si no hay ninguna).
# Es como viaja la fecha de un veredicto: dentro de su parentesis de evidencia y en
# CUALQUIER posicion --`QA: aprobado (R-045, 2026-09-01)`--, porque la evidencia es
# prosa y fijarle una posicion seria inventar una convencion que nadie sigue.
#
# La forma es ESTRICTA a proposito: `AAAA-MM-DD` con mes 01-12 y dia 01-31. Un
# `2026-13-05` no es una fecha aunque lo parezca, y aceptarlo como tal la volveria
# incomparable contra la del codigo -- que es justo para lo que se lee. Lo que no case
# se trata como "sin fecha", que es una denegacion con motivo, no un pase.
arnes_fecha_en() {   # <texto> -> ARNES_FECHA
  ARNES_FECHA=''
  if [[ "$1" =~ ([0-9][0-9][0-9][0-9]-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])) ]]; then
    ARNES_FECHA="${BASH_REMATCH[1]}"
  fi
}

# Recorta un texto a N caracteres con elipsis -> ARNES_CORTO. Sin procesos: es una
# expansion de parametro, ni un fork por REQ. Para las celdas del bloque derivado
# (ver estado-derivado.sh); NUNCA para el camino de lectura de ninguna puerta.
arnes_recorta() {   # <texto> <n>
  ARNES_CORTO="$1"
  [ "${#ARNES_CORTO}" -le "$2" ] && return 0
  ARNES_CORTO="${ARNES_CORTO:0:$2}"
  _arnes_sin_cola_partida
  ARNES_CORTO+='…'
  return 0
}

# EL CORTE ES POR CARACTERES, NO POR BYTES. En un locale UTF-8 la expansion de bash ya
# cuenta caracteres y aqui no hay nada que hacer. En locale C cuenta BYTES, y cortar a
# mitad de una secuencia multibyte dejaria un byte partido dentro de un archivo que se
# publica como UTF-8: se retira esa cola incompleta. El locale se mira por su NOMBRE y no
# probando rangos de bytes, porque en un locale UTF-8 los rangos de `case` se comparan por
# COLACION y un caracter acentuado casaria por error -- la comprobacion se equivocaria
# justo con las entradas que dice proteger.
_arnes_sin_cola_partida() {   # ARNES_CORTO -> sin una secuencia UTF-8 incompleta al final
  case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
    *UTF-8*|*utf-8*|*UTF8*|*utf8*) return 0 ;;
  esac
  local b i n=0
  for ((i = 1; i <= 4; i++)); do
    b="${ARNES_CORTO: -i:1}"
    case "$b" in
      [$'\x80'-$'\xBF']) continue ;;                                  # continuacion: sigue hacia atras
      [$'\xC0'-$'\xDF']) n=2 ;; [$'\xE0'-$'\xEF']) n=3 ;; [$'\xF0'-$'\xF7']) n=4 ;;
      *) return 0 ;;                                                  # ASCII: no hay nada partido
    esac
    (( i < n )) && ARNES_CORTO="${ARNES_CORTO:0:${#ARNES_CORTO}-i}"
    return 0
  done
  return 0
}

arnes_campos_req() {   # <texto en disco> <texto entrante>
  ARNES_QA=''; ARNES_SEG=''; ARNES_SENS=''; ARNES_HALL=''; ARNES_RIGOR=''
  ARNES_QA_CRUDO=''; ARNES_SEG_CRUDO=''; ARNES_CITA_ABIERTA=0
  ARNES_CR_INTERIOR=0; ARNES_CR_INTERIOR_LINEA=''
  # El CR interior NO se reinicia por texto, a diferencia del rango: un CR en CUALQUIERA
  # de las dos cabeceras que esta funcion lee deja lo que se leyo sin medir, y da igual en
  # cual estaba.
  ARNES_CR=0; ARNES_CR_LINEA=''
  # Y por el MISMO motivo la clave con algo insertado dentro: da igual en cual de las dos
  # cabeceras estuviera, lo que se leyo se leyo sin poder medirlo.
  ARNES_OCULTA=0; ARNES_OCULTA_CLAVE=''; ARNES_OCULTA_REPR=''; ARNES_OCULTA_ESTADO=''
  local texto l
  for texto in "$1" "$2"; do
    [ -n "$texto" ] || continue
    # El rango de comentario CRUZA lineas, asi que su estado se reinicia por texto: el
    # fragmento entrante y el documento en disco son dos cabeceras, no una.
    ARNES_CITA=0
    while IFS= read -r l; do
      # LOS CAMPOS VALEN SOLO EN LA CABECERA: antes del primer `## `. Medido: una linea
      # `Seguridad: aprobado (A-009, 2026-09-02)` dentro de `## Historial de cambios` se
      # leia como EL veredicto y cerraba un REQ critico cuya cabecera decia `pendiente`.
      # Es la familia de `**si**`: la maquina lee algo distinto de lo que la cabecera
      # declara. La regla es estructural --lo que dice la plantilla-- y no depende del
      # nombre de ninguna seccion, que seria mapeo del proyecto.
      case "$l" in '## '*) break ;; esac
      arnes_campo_linea "$l" || continue
      # LA PERTENENCIA LA DECIDE `ARNES_CLAVES`, NO ESTOS BRAZOS — y esa es la mitad del
      # arreglo de REQ-023 CA-06. Antes, quien era campo de cabecera lo decidia el `case` de
      # abajo, asi que el conjunto no existia como lista en ninguna parte y una guarda no
      # podia preguntar por el sin volver a teclearlo. Ahora se pregunta al sitio unico —con
      # `arnes_en_vocab`, que es tambien el sitio unico de la pertenencia exacta— y el `case`
      # se queda con lo que si es suyo: ENRUTAR cada clave a SU variable. Un campo que
      # alguien añada al `case` y no a la constante no llega aqui, y eso se ve; al contrario
      # —en la constante y no en el `case`— tampoco queda protegido en silencio, porque la
      # guarda de medibilidad lo cubre desde el mismo sitio.
      arnes_en_vocab "$ARNES_CLAVE" "$ARNES_CLAVES" || continue
      # La precedencia heredada NO se toca: estos cinco toman la ULTIMA aparicion de la
      # cabecera y `Estado` la primera (`arnes_estado_cabecera`, `hooks/campos-req.awk:74`).
      # Un despacho unificado que la igualara decidiria distinto sin cambiar ningun valor «a
      # proposito», y eso es lo que la comparacion campo a campo de CA-04 caza.
      case "$ARNES_CLAVE" in
        'QA')                   ARNES_QA="$ARNES_VALOR" ;;
        'Seguridad')            ARNES_SEG="$ARNES_VALOR" ;;
        'Sensible a seguridad') ARNES_SENS="$ARNES_VALOR" ;;
        'Hallazgos abiertos')   ARNES_HALL="$ARNES_VALOR" ;;
        'Rigor')                ARNES_RIGOR="$ARNES_VALOR" ;;
      esac
    done <<< "$texto"
    # El fin de la cabecera con un rango ABIERTO: la cabecera no se puede medir. Se
    # publica y la puerta decide; aqui no se decide nada.
    [ "$ARNES_CITA" -eq 0 ] || ARNES_CITA_ABIERTA=1
  done
  # Igual que el rango abierto: se PUBLICA y la puerta decide.
  ARNES_CR_INTERIOR="$ARNES_CR"; ARNES_CR_INTERIOR_LINEA="$ARNES_CR_LINEA"
  # El valor CRUDO se conserva ANTES de normalizar: la fecha del veredicto vive en el
  # parentesis de evidencia, que la normalizacion retira a proposito (el parentesis es
  # evidencia, no veredicto). Se lee del crudo con el MISMO lector, no con un segundo
  # normalizador -- dos transcripciones de la misma regla se desfasan.
  ARNES_QA_CRUDO="$ARNES_QA"; ARNES_SEG_CRUDO="$ARNES_SEG"
  arnes_campos_normaliza "$ARNES_QA" "$ARNES_SEG" "$ARNES_SENS" "$ARNES_HALL" "$ARNES_RIGOR"
}

# `Estado:` de la CABECERA de un documento, normalizado y sin su parentesis de
# evidencia. La PRIMERA aparicion manda, como en campos-req.awk: la cabecera declara
# el estado una vez. Existe para juzgar la transicion sobre el documento RESULTANTE,
# no sobre el fragmento editado (ver guard-completado.sh).
arnes_estado_cabecera() {   # <texto> -> ARNES_ESTADO
  ARNES_ESTADO=''; ARNES_ESTADO_CITADO=''; ARNES_ESTADO_CITA=0
  ARNES_ESTADO_CR=0; ARNES_ESTADO_CR_LINEA=''
  ARNES_CITA=0; ARNES_CR=0; ARNES_CR_LINEA=''
  local l crudo visto=0
  while IFS= read -r l; do
    case "$l" in '## '*) break ;; esac
    arnes_sin_cita "$l"
    # SE COMPARA CONTRA LA LINEA CRUDA, sin tocarle nada. Antes se le descontaba el CR
    # aqui —y `arnes_sin_cita` tambien— para que en un archivo CRLF la linea no difiriera
    # de su version sin cita por el retorno de carro y la rama de abajo no se disparara
    # sobre documentos sin un solo comentario. Ya no hace falta, y ademas no debe hacerse:
    # `arnes_sin_cita` escanea la linea cruda, asi que sin comentarios devuelve el mismo
    # texto byte a byte. Descontar el CR en un solo lado reintroduciria la asimetria.
    crudo="$l"
    # LA LINEA QUE EL RANGO SE TRAGO SE LEE APARTE, y NO como veredicto: solo para que la
    # puerta pueda distinguir «aqui no hay estado» de «aqui alguien intenta declarar el
    # estado terminal desde dentro de una cita». Sin esto, un rango sin cerrar que se
    # tragara la linea del estado se resolveria como AUSENCIA —y la ausencia se permite—,
    # que es la unica forma en que este arreglo podria abrir lo que vino a cerrar.
    if [ "$visto" -eq 0 ] && [ -z "$ARNES_ESTADO_CITADO" ] && [ "$ARNES_LINEA" != "$crudo" ]; then
      if arnes_norm_clave "$crudo"; then
        # La clave sale de `ARNES_CLAVES` (ver arriba) y no de un literal tecleado aqui:
        # este era el UNICO sitio donde vivia la clave del estado terminal, y un puntero que
        # lo dejara fuera dejaba sin proteger justo la clave que decide el cierre.
        case "$ARNES_CLAVE" in "$ARNES_CLAVE_ESTADO")
          arnes_norm_campo "$ARNES_VALOR"; arnes_veredicto "$ARNES_CAMPO"
          ARNES_ESTADO_CITADO="$ARNES_VEREDICTO" ;;
        esac
      fi
    fi
    # La PRIMERA aparicion manda, y `visto` —no «el valor sigue vacio»— es lo que lo
    # dice: un `Estado:` sin valor es una aparicion, y hasta ahora la funcion salia con
    # las manos vacias en cuanto lo veia. Cambiar eso seria cambiar de opinion en
    # silencio sobre un malformado.
    if [ "$visto" -eq 0 ] && arnes_norm_clave "$ARNES_LINEA"; then
      case "$ARNES_CLAVE" in "$ARNES_CLAVE_ESTADO")
        arnes_norm_campo "$ARNES_VALOR"; arnes_veredicto "$ARNES_CAMPO"; ARNES_ESTADO="$ARNES_VEREDICTO"
        visto=1 ;;
      esac
    fi
  done <<< "$1"
  # NO se sale en la primera aparicion: la cabecera se recorre entera para saber si algun
  # rango quedo abierto —o si alguna linea llevaba un CR que no la termina—. Son unas
  # pocas lineas de expansion de parametros y ni un fork.
  [ "$ARNES_CITA" -eq 0 ] || ARNES_ESTADO_CITA=1
  ARNES_ESTADO_CR="$ARNES_CR"; ARNES_ESTADO_CR_LINEA="$ARNES_CR_LINEA"
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
  local declarado="$ARNES_RIGOR" nd ns nh heredado
  ARNES_RIGOR_AUSENTE=0
  # EL NIVEL HEREDADO: el que este REQ tendria si su `Rigor:` no se pudiera leer.
  # Es el comportamiento anterior a que los niveles existieran, y se calcula UNA
  # vez porque tiene dos usos: es el valor por defecto (no hay nada declarado y la
  # exigencia de ausencia no aplica, o lo declarado no se entiende) y es el PISO
  # del matiz (abajo).
  case "$ARNES_SENS" in
    si) heredado='critico' ;;
    *)  heredado='estandar' ;;
  esac

  # SUELO DE SEGURIDAD: `Sensible a seguridad: si` obliga a `critico` y eso no se
  # puede bajar. Un REQ que NO es sensible no tiene suelo.
  #
  # Es distinto del VALOR POR DEFECTO, y confundirlos hace que `ligero` no pueda
  # activarse nunca: si el defecto de un REQ no sensible fuera tambien un suelo,
  # cualquier declaracion mas baja quedaria anulada y el nivel no serviria para
  # nada. El suelo limita hacia abajo; el defecto solo aplica si no hay nada
  # declarado.
  if [ -z "$declarado" ]; then
    # AUSENTE. Se pregunta al sitio único (`arnes_resuelve_ausencia`, ADR-009) y sólo si la
    # exigencia está activada devuelve algo: `critico`, el valor que MÁS restringe. Sin
    # activar devuelve vacío y aquí se juzga EXACTAMENTE como antes de existir los niveles
    # —el defecto derivado de la sensibilidad—, que es lo que `REQ-024 CA-05` contrata.
    ARNES_RIGOR_AUSENTE=1
    arnes_resuelve_ausencia "$ARNES_CLAVE_RIGOR" ''
    if [ -n "$ARNES_AUSENCIA_APLICA" ]; then ARNES_RIGOR="$ARNES_AUSENCIA_APLICA"; return 0; fi
    ARNES_RIGOR="$heredado"
    return 0
  fi

  arnes_rigor_nivel "$declarado"; nd=$?
  if [ "$nd" -eq 0 ]; then
    # Valor no reconocido: se ignora y se cae al comportamiento de siempre.
    ARNES_RIGOR="$heredado"
    return 0
  fi

  # Declarado y valido. Sube libremente; bajar del suelo de seguridad, no.
  ARNES_RIGOR="$declarado"

  # UN MATIZ QUE LLEGA HASTA AQUI SOLO PUEDE SUBIR O MANTENER EL RIGOR, NUNCA
  # BAJARLO. La frase sin esa condicion es FALSA y estaba escrita asi: el alcance
  # de esta guarda son los matices BIEN FORMADOS, y lo acota `arnes_veredicto`,
  # que desenvuelve SOLO si el valor termina en `)`.
  #
  # LO QUE QUEDA FUERA, medido y con nombre (SEC-087, clase `contrato`): si el
  # parentesis NO cierra al final del valor --`critico (por suelo`, `critico (`,
  # `critico (x) y`--, el valor entero deja de reconocerse y `arnes_rigor_efectivo`
  # ya retorno por la rama `nd -eq 0` de arriba, con la derivacion heredada. Este
  # `if` NO CORRE en ese camino. Efecto real: un `critico` asi escrito en un REQ
  # no sensible se juzga `estandar` y deja de exigir la firma de seguridad, en
  # silencio. Es la unica proteccion que esa forma pierde --en `ligero` y
  # `estandar` la derivacion heredada da lo mismo, y en un REQ sensible el suelo
  # lo impide--. La via es PREEXISTENTE e identica en 1.33.0, 1.33.1 y 1.33.2: no
  # la abrio este arreglo, y cerrarla es otra reparacion con su propio REQ. Lo que
  # este parche corrigio fue la frase absoluta que la tapaba.
  #
  # Y TAMPOCO CORRE CUANDO EL CAMPO ESTA AUSENTE, que en esta linea es un camino
  # APARTE: `arnes_resuelve_ausencia` (ADR-009) ya retorno mas arriba, antes de
  # llegar aqui. Es correcto --una ausencia no es un matiz: no hay nada
  # desenvuelto que pudiera bajar el nivel, y esa rama resuelve hacia `critico` o
  # hacia lo heredado, nunca hacia `ligero`--, pero queda dicho para que nadie
  # lea esta guarda como si cubriera tambien ese camino.
  #
  # Cuando el nivel salio de desenvolver un parentesis bien formado, el nivel
  # efectivo es el MAS RESTRICTIVO entre lo desenvuelto y el nivel heredado -- que
  # es, exacto, lo que ese mismo valor daba antes de que el desenvoltorio
  # existiera.
  #
  # POR QUE, y esto se pago publicando. v1.33.1 enruto la forma con parentesis
  # por el lector comun para TODOS los valores. En `critico (por suelo)` eso
  # cerro un fail-open. En `ligero (local)` abrio otro MAS ANCHO: `ligero` es el
  # unico nivel exento de `QA: aprobado` (AGENTS.md 6), asi que un REQ no
  # sensible con `Rigor: ligero (<lo que sea>)` paso a cerrarse SIN QA y SIN
  # veredicto de seguridad, donde v1.33.0 lo denegaba. La conducta anterior
  # --"valor no reconocido: se cae al defecto de la sensibilidad"-- no era un
  # descuido que el parche corrigiera: en `ligero` era PROTECTORA.
  #
  # La asimetria no es un caso especial pegado con cinta: es la misma doctrina
  # que el proyecto ya tiene escrita en AGENTS.md 6 --"el rigor se puede subir,
  # nunca bajar"-- y la regla de que una guarda solo puede ESTRECHAR. Un
  # parentesis es evidencia que alguien anadio a mano; puede pedir mas ceremonia,
  # no regalar una exencion.
  #
  # Consecuencia que hay que saber: no existe forma de declarar `ligero` CON
  # matiz. Quien quiera la exencion escribe `Rigor: ligero` a secas y pone la
  # evidencia en el cuerpo del REQ. Es deliberado -- la exencion de QA es
  # justo lo que no debe poder concederse de pasada.
  if [ "${ARNES_RIGOR_MATIZ:-0}" = "1" ]; then
    arnes_rigor_nivel "$heredado"; nh=$?
    if [ "$nd" -lt "$nh" ]; then ARNES_RIGOR="$heredado"; nd=$nh; fi
  fi

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
