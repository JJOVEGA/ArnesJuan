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

# Campos del input que usan los guardianes. UNA llamada a jq para los dos. Esta lista es la sede de
# los campos de la entrada que leen las puertas (REQ-007 CA-47, punto 11). `cwd` es el directorio de
# trabajo de la llamada, en el que se ANCLA una ruta relativa (CA-47, punto 1).
#
# LOS LIMITES ENTRE CAMPOS LOS FIJA EL FORMATO, NUNCA EL CONTENIDO (QA-023-09, CA-47 punto 11). jq
# escribe los campos uno tras otro, separados por saltos de linea, y CUALQUIERA puede llevar saltos
# dentro: el `cwd` es el nombre de un directorio —ni el host ni nadie impide que lo lleve— y el
# `file_path` lo escribe el modelo. Leidos a «una linea por campo», un salto dentro de uno desplazaba
# todos los siguientes: medido en 104ffd1, con `"cwd": "/tmp\nb"` el hook juzgo `b` como destino, la
# ruta real acabo en `command`, y un cierre en rojo por la ruta canonica salio allow. Ninguna premisa
# sobre quien escribe un campo protege a los demas.
#
# Por eso la PRIMERA linea declara, para cada campo menos el ultimo, cuantos saltos de linea lleva
# (`indices("\n")`, en la misma llamada a jq), y de cada campo se leen exactamente esas lineas mas una.
# El ultimo, `command`, se lleva el resto. Nada se prohibe y nada se sustituye: cada campo llega
# entero, con sus saltos. Dos detalles que lo hacen exacto:
#   * la normalizacion de transporte de `arnes_jq_str` (CRLF -> LF, por el jq de Windows) no cambia
#     el numero de LF que cuenta jq;
#   * `$( )` solo retira saltos FINALES de la salida, es decir, lineas vacias del final: leer mas
#     alla del final del flujo devuelve vacio, que es exactamente lo que eran.
# Un valor que no es una cadena se lee con `tostring` (su JSON compacto, en una linea) — salvo el
# `cwd`, que si no es una cadena no ancla nada, como antes. Sin procesos nuevos. Que un `file_path` o
# un `tool_name` CON salto no se puedan juzgar como cualquier otro lo deciden CA-47 puntos 12 y 13
# (`_arnes_id_calcula` y los guardianes), no esta lectura: aqui solo se lee, entero.
#
# EL RETORNO DE CARRO DEL DATO LLEGA ENTERO: EL CR DE TRANSPORTE SE RETIRA SOLO SI LO HAY (octava
# autorizacion; QA-023-14 y P-023-13-A). El jq de Windows escribe en modo texto y anade un CR delante
# de CADA salto de linea de su salida; ese CR es de transporte y hay que retirarlo. Pero en el flujo de
# bytes es indistinguible de un CR del dato que preceda a un salto —el ultimo caracter de un campo, que
# va seguido del separador, o el de una linea interna—, y retirarlo a ciegas, como hacia hasta aqui
# `arnes_jq_str`, borraba ese CR del dato EN LINUX, donde jq no anade ninguno: medido en cd6afa6, con
# `"cwd": "<fuera>/d\r"` la relativa de `Bash` se anclaba en `<fuera>/d`, otro directorio que el del
# shell (QA-023-13); y el texto de un comando de `Bash` perdia su CR final y el que precede a un salto,
# asi que `printf x > k\r` se juzgaba como `printf x > k` mientras el shell escribe `k\r` (P-023-13-A).
# La reposicion que lo remediaba en dos campos (`_arnes_repone_cr`, 3bc7d3c) contaba los CR del valor
# con `${v//[!\r]/}`, que crece mas que linealmente, antes de cualquier techo (QA-023-14).
#
# Ahora la salida de jq se lee CRUDA y la PRIMERA linea, que escribe esta misma llamada y solo lleva
# digitos y espacios, dice si hay transporte que retirar: si acaba en CR, jq anadio un CR a cada salto
# y se retira exactamente ese —`arnes_sin_cr_transporte`, cuya sustitucion `\r\n` -> `\n` es la inversa
# exacta de anadir un CR delante de cada salto: un CR del dato delante de un salto llega como `\r\r\n` y
# sale como `\r\n`—; si no, no se toca nada. En los dos casos cada campo llega con sus CR, y nada
# recorre el valor para reponer nada. Sin procesos nuevos: es la misma llamada a jq.
#
# Y AUN ASI LO QUE DECIDE EN TRES CAMPOS ES LA CUENTA SOBRE EL VALOR CRUDO (QA-023-13, CA-47 punto 11).
# La misma llamada a jq declara en la primera linea cuantos CR traen el `tool_name`, el `cwd` y el
# `file_path` (`indices`, en C), y con eso:
#   * un `cwd` con un CR, en cualquier posicion, NO ANCLA: se vacia y queda marcado
#     (`ARNES_CWD_CR`), y la ruta relativa que dependa de el es no determinable (`_arnes_id_calcula`,
#     CA-47 punto 7). Las rutas absolutas no dependen de el y se juzgan como siempre;
#   * el `file_path` y el `tool_name` con un CR quedan marcados (`ARNES_FP_CR`, `ARNES_TOOL_CR`) y se
#     tratan como los que llevan un salto (CA-47 puntos 12 y 13, por coherencia). El motivo cita el valor
#     tal como llego, con su CR, porque ahora llega con el.
# Los campos del agente no se marcan: `arnes_norm_ident` retira todo CR al comparar, por su propia
# regla, y un `agent_id` que solo era un CR se lee vacio, que es la sesion coordinadora, el lado
# estricto. El `command` tampoco se marca: llega con sus CR y lo juzga el analizador de `Bash`, que
# trata el CR como el shell —un caracter de palabra— y DENIEGA donde no puede seguir su significado
# (`arnes_bash_sin_texto`, `ARNES_RC_CR`).
#
# Si jq no puede leer la entrada, los campos quedan VACIOS: nunca se reparte entre los campos una
# salida anterior de jq (el fallo de jq al leer la entrada es SEC-120, fuera de esta reparacion).
arnes_parse_input() {
  [ -z "${ARNES_INPUT_LISTO:-}" ] || return 0
  local n_tool='' n_aid='' n_aty='' n_cwd='' n_fp='' r_tool='' r_cwd='' r_fp='' out
  ARNES_JQ=''
  if out="$(jq -r '[.tool_name // "",
                    .agent_id // "",
                    .agent_type // "",
                    (.cwd // "" | if type == "string" then . else "" end),
                    .tool_input.file_path // "",
                    .tool_input.command // ""]
                   | map(tostring)
                   | ((.[0:5] | map(indices("\n") | length))
                      + ([.[0], .[3], .[4]] | map(indices("\r") | length))
                      | map(tostring) | join(" ")),
                     .[]' <<< "$ARNES_INPUT")"; then
    # La primera linea solo lleva digitos y espacios: un CR al final es el de transporte (arriba).
    case "${out%%$'\n'*}" in
      *$'\r') arnes_sin_cr_transporte "$out"; ARNES_JQ="$ARNES_SIN_CR" ;;
      *)      ARNES_JQ="$out" ;;
    esac
  fi
  ARNES_TOOL=''; ARNES_AGENT_ID=''; ARNES_AGENT_TYPE=''; ARNES_CWD=''; ARNES_FP=''; ARNES_CMD=''
  ARNES_TOOL_CR=0; ARNES_CWD_CR=0; ARNES_FP_CR=0
  if [ -n "$ARNES_JQ" ]; then
    { IFS=' ' read -r n_tool n_aid n_aty n_cwd n_fp r_tool r_cwd r_fp
      _arnes_lee_campo "$n_tool"; ARNES_TOOL="$ARNES_CAMPO"
      _arnes_lee_campo "$n_aid";  ARNES_AGENT_ID="$ARNES_CAMPO"
      _arnes_lee_campo "$n_aty";  ARNES_AGENT_TYPE="$ARNES_CAMPO"
      _arnes_lee_campo "$n_cwd";  ARNES_CWD="$ARNES_CAMPO"
      _arnes_lee_campo "$n_fp";   ARNES_FP="$ARNES_CAMPO"
      IFS= read -r -d '' ARNES_CMD; } <<< "$ARNES_JQ"
    ARNES_CMD="${ARNES_CMD%$'\n'}"
    # Fail-closed: un contador que no sea exactamente 0 marca el campo.
    [ "$r_cwd" = 0 ] || { ARNES_CWD_CR=1; ARNES_CWD=''; }
    [ "$r_tool" = 0 ] || ARNES_TOOL_CR=1
    [ "$r_fp" = 0 ] || ARNES_FP_CR=1
  fi
  ARNES_INPUT_LISTO=1
}

# La causa de que el `tool_name` no identifique ninguna herramienta (CA-47 punto 13), para el motivo
# de los dos guardianes: el salto si lo hay —el motivo de siempre—, y si no, el retorno de carro.
arnes_causa_herramienta() {   # -> ARNES_CAUSA_HERR
  if [[ "$ARNES_TOOL" == *$'\n'* ]]; then ARNES_CAUSA_HERR='lleva un salto de linea'
  else ARNES_CAUSA_HERR='lleva un retorno de carro'; fi
}

# Lee UN campo de `arnes_parse_input`: su primera linea y tantas mas como saltos declaro jq.
# El contador se compara con `[ -gt ]`, que exige un entero literal y no evalua expresiones.
_arnes_lee_campo() {   # <saltos de linea del campo> -> ARNES_CAMPO (del flujo abierto por el llamador)
  local n="$1" l
  IFS= read -r ARNES_CAMPO
  while [ "$n" -gt 0 ] 2>/dev/null; do
    l=''; IFS= read -r l
    ARNES_CAMPO+=$'\n'"$l"; n=$((n - 1))
  done
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

# Emite una decisión DENY de PreToolUse y termina con `exit 0`. La decisión existe SÓLO si
# `jq` llegó a escribir el JSON: el `exit 0` no la acredita.
# APARTE, LA LIMITACIÓN CONOCIDA Y SIN REPARAR: SEC-118. El motivo viaja como UN argumento de
# `jq`; si supera el límite de un argumento (128 KiB en Linux) —o `jq` no arranca por otra
# causa—, no se escribe nada y el hook sale sin decisión, que no es una denegación. Los motivos
# de REQ-023 CA-01 y CA-13 llevan tope por eso; los que interpolan contenido sin tope están en
# docs/seguridad/registro-seguridad.md, R-045 §4, en una lista que no es exhaustiva.
# Salida compacta (-c): una sola línea, el formato que esperan los hooks.
arnes_deny() {
  jq -cn --arg r "$1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

# Motivo UNICO de la Excepcion nombrada LC10 (SEC-125; REQ-007 CA-47, punto 19), compartido por las cuatro
# puertas: texto fijo, sin interpolar el comando ni la linea (no hereda SEC-118) y sin nombrar ninguna
# herramienta como salida. <puerta> es el nombre de quien deniega, para la lectura del motivo.
arnes_deny_lc10() {   # <puerta>
  local quien
  if [ -n "${ARNES_AGENT_ID:-}" ]; then quien="el subagente $(arnes_agente_legible "${ARNES_AGENT_TYPE:-desconocido}")"
  else quien="la sesion coordinadora"; fi
  arnes_deny "ARNES (SEC-125, LC10): la linea que abre un heredoc acaba en una continuacion de linea (una barra invertida seguida del salto). Para el shell esa orden sigue en la linea siguiente y el cuerpo del heredoc empieza despues de ella; esta puerta ($1) no une las dos lineas para juzgar el comando como si continuara ni mueve la frontera del cuerpo: deniega esta forma concreta, a cualquier agente (intento de $quien), sin alterar el texto del comando (REQ-007 CA-47, punto 19, Excepcion nombrada). Para corregirlo, escribe entera la linea que abre el heredoc, sin la continuacion al final."
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
# Y SU COSTE, QUE NO ES CERO (QA-023-13): en el flujo de bytes, un CR DEL DATO que
# precede a un salto —el último carácter de un campo, que va seguido del separador, o el
# de una línea interna— no se distingue del de transporte, y en Linux también se retira.
# Para un texto que se lee por cabecera da igual; para un campo cuyo valor DESIGNA algo
# —un directorio, una ruta, una herramienta, el texto de un comando— es leer otro. Quien
# lea campos así no usa estas funciones a ciegas: lee la salida cruda y aplica ésta SÓLO
# si la propia salida dice que hay transporte (`arnes_parse_input`, octava autorización).
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
  # vez. `arnes_ruta_relativa` (retirada el 2026-09-30: la pertenencia es ahora la identidad del
  # destino, REQ-007 CA-47) recortaba el prefijo del proyecto TEXTUALMENTE, así que la
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

# --- IDENTIDAD DEL DESTINO de una escritura (REQ-007 CA-47, ADR-016; SEC-119) -------------
# La norma vive en REQ-007 CA-47 (sede unica); aqui, su implementacion y el porque:
# - Hasta 9596e39 las puertas decidian por el TEXTO de la ruta —la raiz recortada como cadena y la
#   relativa leida desde la raiz— y las dos premisas estan desmentidas: en el host real un `Edit`
#   por `docs/enlace/REQ-X.md` cerro un REQ en rojo y `printf > docs/../src/a.ts` creo codigo; y la
#   relativa desde la raiz no era «falso negativo, nunca positivo» (CA-66, L8).
# - DOS lecturas: la FISICA (la del sistema al abrir la ruta, la que sufre `Bash` y la unica que ve
#   los enlaces) y la LEXICA (la que el host aplica al `file_path` de `Edit`/`Write`). Si designan
#   archivos distintos, no se sabe cual escribira la herramienta: no determinable.
# - SIN PROCESOS: `cd -P` y `$PWD` son de bash, y se vuelve siempre al directorio de antes. El unico
#   proceso es leer el destino de un enlace en el ultimo componente (CA-49 (ii)): uno por destino.
# - UNA VEZ por invocacion (CA-48 (i.2)): destino, raices, tramos fijos, patrones de cada ambito y
#   cada directorio resuelto quedan memorizados.
# - COSTE MEDIDO (WSL2): cada sentencia de bash cuesta microsegundos, un here-string ~100 µs y cada
#   `arnes_norm_path` recorre el PATH buscando `cygpath`; por eso no hay here-strings, la ruta limpia
#   sale por el camino rapido y la forma de comparacion lexica solo se calcula si la via (b) falta.
#   Aun asi, identificar cuesta del orden de medio milisegundo por destino: un comando de `Bash` con
#   miles de destinos lo multiplica (medido y declarado en REQ-007, Historial del 2026-09-30).
# - Sin promesa (F1-F7 de CA-47): carreras, `cd` dentro del comando, enlaces duros y montajes,
#   mayusculas, hosts no ejercidos. `arnes_norm_path` no cambia: la usa `tools/arnes-paralelo.sh`.
# - NINGUN PREFIJO QUEDA FUERA DE LA IDENTIDAD (SEC-122, octava autorizacion). Hasta 3bc7d3c todo
#   destino cuya lectura lexica caia bajo `/dev/` o `/proc/` salia sin lectura fisica, sin enlace y
#   sin existencia: un enlace corriente en `/dev/shm` hacia `requirements/` cerraba un REQ en rojo
#   (cara a, preexistente), y en un proyecto situado bajo `/dev/` se apagaban CA-49 (i) y la
#   existencia (cara b, regresion de 104ffd1). Ahora esos destinos se identifican como cualquier otro.
#   Lo que no es resolucion de nombres es lo que DEPENDE DEL PROCESO QUE ABRE LA RUTA: el nucleo
#   resuelve `/proc/self` y `/proc/thread-self` —y por ellos `/dev/fd` y `/dev/std*`— hacia la
#   entrada en /proc de quien resuelve, y la puerta no es quien escribira. Eso se DETECTA, no se
#   enumera: una resolucion que aterriza en la entrada propia del proceso que resuelve depende de el
#   (`_arnes_propio`), y la que pasa por su directorio de trabajo se resuelve desde el directorio del
#   que escribira, si la puerta lo sabe, o desde dentro de esa entrada propia, si no
#   (`_arnes_cd_resolucion`). Un descriptor abierto del shell se juzga como descriptor; todo lo demas
#   que dependa del proceso es no determinable (`_arnes_id_propio`). Detalle y limites, alli.
ARNES_ID_MAX=4096   # PATH_MAX: una ruta mas larga no la abre el sistema; es no determinable
declare -gA ARNES_IDM_E=() ARNES_IDM_C=() ARNES_IDM_A=() ARNES_IDM_F=() ARNES_IDM_F2=() \
            ARNES_IDM_L=() ARNES_IDM_LN=() ARNES_IDM_B=() ARNES_IDM_K=() ARNES_IDM_X=() \
            ARNES_IDM_V=() ARNES_IDM_FD=() ARNES_IDM_O=() ARNES_IDM_R=()
declare -gA ARNES_TRAMO_FIS=() ARNES_TRAMO_TXT=() ARNES_DIRFIS=() ARNES_AMB_LISTO=()
declare -ga ARNES_AMB_req_P=() ARNES_AMB_req_T=() ARNES_AMB_req_F=() ARNES_AMB_req_Q=() \
            ARNES_AMB_codigo_P=() ARNES_AMB_codigo_T=() ARNES_AMB_codigo_F=() ARNES_AMB_codigo_Q=() \
            ARNES_AMB_manifiesto_P=() ARNES_AMB_manifiesto_T=() ARNES_AMB_manifiesto_F=() ARNES_AMB_manifiesto_Q=()
ARNES_RAICES_LISTAS=''; ARNES_ID_RUTA=''; ARNES_DOBLE_ES_RAIZ=0; ARNES_HAY_CYGPATH=''; ARNES_MANIF_REL='.arnes/config.json'

# `$PWD` tras `cd -P`. Linux conserva la doble barra inicial (`//tmp`) y alli `//` es `/`; en Windows
# `//servidor` es otra maquina: lo decide `[ / -ef // ]`, que compara el archivo, no el texto.
_arnes_pwd_fisico() {   # -> ARNES_PWD_FIS
  ARNES_PWD_FIS="$PWD"
  case "$PWD" in //|//[!/]*) [ "$ARNES_DOBLE_ES_RAIZ" = 1 ] && ARNES_PWD_FIS="${PWD#/}" ;; esac
  return 0
}

# Las raices, una vez por invocacion (CA-47, punto 5): la fisica aqui; en forma de comparacion
# lexica (`_arnes_raices_n`), solo si la via (b) hace falta. Sin raiz fisica, ningun destino se
# puede situar: todos son no determinables.
_arnes_raices() {
  [ -z "$ARNES_RAICES_LISTAS" ] || return 0
  ARNES_RAICES_LISTAS=1
  local orig="$PWD" CDPATH=''
  ARNES_DOBLE_ES_RAIZ=0; [ / -ef // ] && ARNES_DOBLE_ES_RAIZ=1
  ARNES_RAIZ_FIS=''; ARNES_RAICES_N=''
  if cd -P -- "$ARNES_PROJ" 2>/dev/null; then _arnes_pwd_fisico; ARNES_RAIZ_FIS="$ARNES_PWD_FIS"; fi
  cd -- "$orig" 2>/dev/null
  return 0
}
_arnes_raices_n() {
  [ -z "$ARNES_RAICES_N" ] || return 0
  ARNES_RAICES_N=1
  local r="$ARNES_PROJ"; [ "$r" = / ] || r="${r%/}"
  ARNES_HAY_CYGPATH=0; command -v cygpath >/dev/null 2>&1 && ARNES_HAY_CYGPATH=1
  arnes_norm_path "$r"; ARNES_RAIZ_ENV_N="$ARNES_NORM"
  ARNES_RAIZ_FIS_N=''
  [ -z "$ARNES_RAIZ_FIS" ] || { arnes_norm_path "$ARNES_RAIZ_FIS"; ARNES_RAIZ_FIS_N="$ARNES_NORM"; }
}
# La lectura lexica del destino en forma de comparacion (via (b) y CA-49 (i)), cuando hace falta.
# Sin `cygpath` y sin unidad de Windows, `arnes_norm_path` devolveria la lectura lexica tal cual —ya
# no lleva barras invertidas ni repetidas—, y llamarla por destino recorreria el PATH una vez por
# destino (medido: miles de destinos en un comando multiplicaban el reloj del hook).
_arnes_id_ln() {
  [ -z "$ARNES_ID_LN" ] || return 0
  [ -n "$ARNES_ID_L" ] || return 0
  _arnes_raices_n
  case "$ARNES_HAY_CYGPATH:$ARNES_ID_L" in
    1:*|0:[A-Za-z]:*) arnes_norm_path "$ARNES_ID_L"; ARNES_ID_LN="$ARNES_NORM" ;;
    *) ARNES_ID_LN="$ARNES_ID_L" ;;
  esac
  [ -z "$ARNES_ID_RUTA" ] || ARNES_IDM_LN[$ARNES_ID_RUTA]="$ARNES_ID_LN"
}

# ¿<ruta> esta en <raiz> o debajo? -> 0 y ARNES_BAJO (relativa; vacia si es la raiz misma). Por
# subcadena y no con `${1#"$r"/}`: quitar un prefijo literal largo es cuadratico en bash (medido).
_arnes_bajo() {
  [ -n "$2" ] || return 1
  case "$1" in
    "$2")   ARNES_BAJO=''; return 0 ;;
    "$2"/*) ARNES_BAJO="${1:${#2}+1}"; return 0 ;;
  esac
  [ "$2" = / ] && [ "${1:0:1}" = / ] && { ARNES_BAJO="${1:1}"; return 0; }
  return 1
}

# No determinable: la causa y como corregirlo, SIN nombrar ninguna herramienta (CA-47, punto 7).
_arnes_nodet() { ARNES_ID_E=nodet; ARNES_ID_C="$1"; ARNES_ID_A="$2"; }

# --- Lo que depende del proceso que abre la ruta (SEC-122, octava autorizacion) ------------------
# ¿<ruta> esta en la entrada de /proc del proceso que esta resolviendo, o debajo? Es donde aterriza
# toda resolucion que pasa por `/proc/self` o `/proc/thread-self` —y por ellos `/dev/fd/N`—; y, desde
# `_arnes_cd_resolucion`, tambien la que pasa por el directorio de trabajo cuando la puerta no sabe
# cual es el del proceso que escribira. `$BASHPID` y no `$$`: en un subshell resuelve el subshell.
_arnes_propio() { case "$1/" in "/proc/$BASHPID/"*) return 0 ;; esac; return 1; }

# ¿La lectura fisica del tramo <ruta> (ARNES_PWD_FIS) es su propio texto? Entonces no atraveso ningun
# enlace —tampoco `/proc/self`— y el directorio desde el que se resolvio no pinto nada.
_arnes_mismo_texto() {
  case "$1/" in */./*|*/../*) return 1 ;; esac
  [ "$ARNES_PWD_FIS" = "$1" ]
}

# ¿El `cwd` de la entrada ancla? Las mismas condiciones que CA-47, punto 1: absoluto, sin retorno de
# carro, y un directorio que existe. -> ARNES_ANCLA
_arnes_ancla() {
  local c="${ARNES_CWD:-}"
  [ "${ARNES_CWD_CR:-0}" = 0 ] || return 1
  case "$c" in /*) ;; [A-Za-z]:[/\\]*) c="${c//\\//}" ;; *) return 1 ;; esac
  [ -d "$c" ] || return 1
  ARNES_ANCLA="$c"
}

# El directorio desde el que se resuelve una ruta que atraviesa un enlace (SEC-122). Un enlace puede
# llevar al directorio de trabajo del proceso que lo abre —`/proc/self/cwd`, o cualquier enlace que
# apunte ahi— y el de este hook no es el del proceso que escribira:
#   * por `Bash`, la puerta sabe cual es: el `cwd` de la entrada, el mismo en que ancla una relativa
#     (CA-47, punto 1, sobre la premisa que declara F7). Se resuelve desde el, y queda como en el shell;
#   * por `Edit`/`Write`/`MultiEdit` escribe el proceso del host, cuyo directorio la puerta no conoce,
#     y por `Bash` sin un `cwd` que ancle, tampoco. Se resuelve desde DENTRO de la entrada en /proc del
#     propio proceso: toda dependencia del directorio de trabajo aterriza en ella, y `_arnes_propio` la
#     ve. Sin /proc no hay `/proc/self` por el que depender, y se resuelve desde donde se este.
# LIMITE, declarado (REQ-007 CA-47, F3 y punto 16; sede unica de la cifra y de la consecuencia): una
# cadena que, tras llegar al directorio de trabajo, sube con `..` lo bastante para SALIR de la entrada
# propia de /proc desde la que se resuelve deja de verse desde ella, y la puerta juzga el archivo al que
# llega el hook, no el que abre quien escribe: la consecuencia es un permiso (SEC-123, P-119-A).
# Vale igual en un subshell (lo usa `_arnes_id_resuelve_enlace`): `$BASHPID` es el suyo.
# 1 = el `cwd` que ancla ya no se deja recorrer.
_arnes_cd_resolucion() {
  if [ "${ARNES_TOOL:-}" = Bash ] && _arnes_ancla; then cd -- "$ARNES_ANCLA" 2>/dev/null; return; fi
  cd -- "/proc/$BASHPID/task/$BASHPID/fdinfo" 2>/dev/null || cd -- "/proc/$BASHPID" 2>/dev/null
  return 0
}

# Un destino que aterrizo en la entrada de /proc del proceso que lo resolvio: lo que designa depende de
# ese proceso, que no es el que escribira.
#   * Una RANURA DE DESCRIPTOR —`fd/<x>` del proceso o de uno de sus hilos, sin nada detras— designa un
#     descriptor abierto. Por `Bash` es un descriptor del shell: se los da el host (la salida que
#     captura) o los abre el propio comando, y lo que el comando abre antes de escribir es la frontera
#     de construir su propio contexto (F2). Se juzga como descriptor, fuera de todo ambito: es lo que
#     hace legitimo `> /dev/stderr`, sin excepcion por su nombre. Por otra herramienta el descriptor es
#     del proceso del host, que la puerta no ve: no determinable.
#   * Todo lo demas —el directorio del proceso, sus pseudoarchivos, una ruta que sigue detras de un
#     descriptor, el directorio de trabajo cuando no se conoce el del que escribe— no determinable.
# <dir> es el directorio fisico, <resto> 1 si lleva segmentos que no existen, <base> el ultimo
# componente (vacio si la ruta designa un directorio) y <pid> el del proceso que resolvio.
ARNES_PROC_CAUSA='depende del proceso que la abre —pasa por su entrada en /proc, como /proc/self, /proc/thread-self o /dev/fd, o es uno de sus descriptores—, y esta puerta, que no es ese proceso, no puede saber a que archivo llega'
ARNES_PROC_ARREGLO='escribe la ruta del archivo por su nombre, sin pasar por la entrada en /proc de un proceso ni por sus descriptores'
_arnes_id_propio() {   # <dir fisico> <resto 0|1> <base> <pid>
  local p="/proc/$4" t
  if [ "$2" = 0 ] && [ -n "$3" ]; then
    case "$1" in
      "$p/fd") _arnes_id_descriptor; return 0 ;;
      "$p/task/"*/fd)
        t="${1#"$p/task/"}"; t="${t%/fd}"
        case "$t" in ''|*[!0-9]*) ;; *) _arnes_id_descriptor; return 0 ;; esac ;;
    esac
  fi
  _arnes_nodet "$ARNES_PROC_CAUSA" "$ARNES_PROC_ARREGLO"
}
_arnes_id_descriptor() {
  if [ "${ARNES_TOOL:-}" = Bash ]; then ARNES_ID_E=desc; ARNES_ID_C=''; ARNES_ID_A=''
  else _arnes_nodet "$ARNES_PROC_CAUSA" "$ARNES_PROC_ARREGLO"; fi
}

# Lectura LEXICA (CA-47, punto 3): la ruta absoluta con `.`, `..` y las barras repetidas retirados
# como texto, conservando la doble barra inicial de una ruta UNC. `..` en la raiz se queda en ella.
_arnes_lectura_lexica() {   # <ruta absoluta> -> ARNES_LL
  local p="$1" pre rest seg
  local -a pila=()
  case "$p/" in
    *//*|*/./*|*/../*|*\\*) ;;
    *) ARNES_LL="$p"; return 0 ;;
  esac
  p="${p//\\//}"
  case "$p" in
    //|//[!/]*) pre='//'; rest="${p#//}" ;;
    /*)          pre='/';  rest="${p#/}" ;;
    [A-Za-z]:/*) pre="${p:0:3}"; rest="${p:3}" ;;
    *)           pre='';   rest="$p" ;;
  esac
  while [ -n "$rest" ]; do
    seg="${rest%%/*}"
    if [ "$seg" = "$rest" ]; then rest=''; else rest="${rest#*/}"; fi
    case "$seg" in
      ''|.) ;;
      ..) [ "${#pila[@]}" -eq 0 ] || unset "pila[$(( ${#pila[@]} - 1 ))]" ;;
      *)  pila+=("$seg") ;;
    esac
  done
  local IFS=/
  ARNES_LL="$pre${pila[*]-}"
}

# Lectura FISICA (CA-47, punto 2): el tramo existente mas largo, resuelto por el nucleo con sus
# enlaces y sus `..` (`cd -P`), mas los segmentos restantes, que tienen que ser NOMBRES sobre
# directorios que todavia no existen. <dir>=1: la ruta designa un directorio y se resuelve entera.
# «TODAVIA NO EXISTE» NO ES «NO SE PUDO DETERMINAR» (punto 8): se sube un nivel solo si el
# componente no existe; si existe y no deja entrar (sin permiso, no es un directorio, un enlace roto
# o en bucle) es no determinable. Un `-e` que falla porque un antecesor no se deja recorrer no
# engana: al subir se llega a ese antecesor, que existe y no deja entrar. (Un `cd` que falla no
# cambia de directorio: solo hay que volver tras el que acierta.) Cada directorio resuelto se
# memoriza por invocacion: miles de destinos en el mismo `cwd` pagan UN `cd -P`, no miles.
#
# DESDE DONDE SE RESUELVE (SEC-122). La primera pasada se hace desde donde este el proceso, que es lo
# barato y basta casi siempre: si el tramo resuelto da como lectura fisica exactamente su propio
# texto, no atraveso ningun enlace y el directorio de trabajo no pinto nada. Si no —un enlace, un
# `..`, `/proc/self`—, se rehace entera desde el directorio que fija `_arnes_cd_resolucion`, y vale
# esa. Asi el camino comun no paga ni un `cd` mas. Una resolucion que aterriza en la entrada propia de
# /proc depende del proceso y NO se memoriza: otro proceso —un subshell— aterrizaria en la suya.
_arnes_lectura_fisica() {   # <ruta absoluta, sin barra final> <dir 0|1> -> ARNES_LF, ARNES_LF_DIR, ARNES_LF_RESTO ; 1 = no determinable
  local dir="$1" base='' cur resto seg d r orig="$PWD" CDPATH='' pasada=1 rc=0
  [ "$2" = 1 ] || { base="${1##*/}"; dir="${1%/*}"; }
  while :; do
    cur="${dir:-/}"; resto=''
    while :; do
      if [ -n "${ARNES_DIRFIS[$cur]+x}" ]; then ARNES_PWD_FIS="${ARNES_DIRFIS[$cur]}"; break; fi
      if cd -P -- "$cur" 2>/dev/null; then
        _arnes_pwd_fisico
        if [ "$pasada" = 1 ] && ! _arnes_mismo_texto "$cur"; then rc=2; break; fi
        _arnes_propio "$ARNES_PWD_FIS" || ARNES_DIRFIS[$cur]="$ARNES_PWD_FIS"
        break
      fi
      if [ -e "$cur" ] || [ -L "$cur" ]; then
        arnes_cita_ruta "$cur"
        _arnes_nodet "el directorio $ARNES_CITA_RUTA de la ruta existe pero no se puede recorrer (sin permiso, no es un directorio, o es un enlace roto o en bucle)" \
                     "escribe la ruta a traves de directorios que se puedan recorrer"
        rc=1; break
      fi
      case "$cur" in
        /|//|[A-Za-z]:|[A-Za-z]:/)
          _arnes_nodet "ni siquiera su raiz se puede recorrer" "escribe la ruta a traves de directorios que se puedan recorrer"
          rc=1; break ;;
      esac
      resto="${cur##*/}${resto:+/$resto}"; cur="${cur%/*}"
      case "$cur" in '') cur=/ ;; [A-Za-z]:) cur="$cur/" ;; esac
    done
    [ "$rc" = 2 ] || break
    # Atraveso un enlace: se rehace desde el directorio del proceso que escribira (arriba).
    rc=0; pasada=2; cd -- "$orig" 2>/dev/null
    if ! _arnes_cd_resolucion; then
      _arnes_nodet "el directorio de trabajo de la entrada ('cwd'), desde el que se resuelve la ruta, ya no se puede recorrer" \
                   "escribe la ruta desde un directorio de trabajo que exista"
      rc=1; break
    fi
  done
  [ "$PWD" = "$orig" ] || cd -- "$orig" 2>/dev/null
  [ "$rc" = 0 ] || return 1
  ARNES_LF_RESTO=0
  if [ -n "$resto" ]; then
    ARNES_LF_RESTO=1; r="$resto"
    while [ -n "$r" ]; do
      seg="${r%%/*}"
      if [ "$seg" = "$r" ]; then r=''; else r="${r#*/}"; fi
      case "$seg" in
        ''|.|..)
          _arnes_nodet "lleva '$seg' sobre un directorio que todavia no existe, y el sistema no puede resolverlo" \
                       "escribe la ruta sin '..' ni '.' sobre directorios que no existen"
          return 1 ;;
      esac
    done
  fi
  d="$ARNES_PWD_FIS"; [ "$d" != / ] || d=''
  ARNES_LF_DIR="$d${resto:+/$resto}"
  if [ -n "$base" ]; then ARNES_LF="$ARNES_LF_DIR/$base"; else ARNES_LF="${ARNES_LF_DIR:-/}"; fi
  ARNES_LF_DIR="${ARNES_LF_DIR:-/}"
  return 0
}

# arnes_identidad <ruta tal como llego> — la identidad de UN destino, memorizada por invocacion.
# Publica: ARNES_ID_E (ok|nodet|desc: un descriptor del shell, SEC-122), ARNES_ID_C/ARNES_ID_A
# (causa y arreglo, si nodet), ARNES_ID_F
# (lectura fisica), ARNES_ID_F2 (fisica de la lexica, si la ruta lleva `..`), ARNES_ID_L (lexica;
# su forma de comparacion, ARNES_ID_LN, la da `_arnes_id_ln` cuando hace falta), ARNES_ID_B (barra
# final), ARNES_ID_K (el ultimo componente es un enlace), ARNES_ID_FD (directorio fisico del ultimo
# componente), ARNES_ID_V (1: las dos lecturas designan archivos distintos; 2: la lexica no se puede
# situar), ARNES_ID_O (el archivo que se leeria: el fisico, o el destino del enlace una vez
# resuelto), ARNES_ID_X (existe algo en ARNES_ID_O) y ARNES_ID_R (enlace ya resuelto).
arnes_identidad() {
  local d="$1"
  # La vigente —la ultima calculada o cargada— ya esta en las variables: no se recarga.
  [ -z "$d" ] || [ "$d" != "$ARNES_ID_RUTA" ] || return 0
  if [ -n "$d" ] && [ -n "${ARNES_IDM_E[$d]+x}" ]; then
    # Una sola orden de asignaciones: cada orden de bash cuesta microsegundos (medido).
    ARNES_ID_E="${ARNES_IDM_E[$d]}" ARNES_ID_C="${ARNES_IDM_C[$d]}" ARNES_ID_A="${ARNES_IDM_A[$d]}" \
    ARNES_ID_F="${ARNES_IDM_F[$d]}" ARNES_ID_F2="${ARNES_IDM_F2[$d]}" ARNES_ID_L="${ARNES_IDM_L[$d]}" \
    ARNES_ID_LN="${ARNES_IDM_LN[$d]}" ARNES_ID_B="${ARNES_IDM_B[$d]}" ARNES_ID_K="${ARNES_IDM_K[$d]}" \
    ARNES_ID_X="${ARNES_IDM_X[$d]}" ARNES_ID_V="${ARNES_IDM_V[$d]}" ARNES_ID_FD="${ARNES_IDM_FD[$d]}" \
    ARNES_ID_O="${ARNES_IDM_O[$d]}" ARNES_ID_R="${ARNES_IDM_R[$d]}" ARNES_ID_RUTA="$d"
    return 0
  fi
  _arnes_id_calcula "$d"
  _arnes_id_guarda
}

_arnes_id_guarda() {
  local d="$ARNES_ID_RUTA"
  [ -n "$d" ] || return 0
  ARNES_IDM_E[$d]="$ARNES_ID_E" ARNES_IDM_C[$d]="$ARNES_ID_C" ARNES_IDM_A[$d]="$ARNES_ID_A" \
  ARNES_IDM_F[$d]="$ARNES_ID_F" ARNES_IDM_F2[$d]="$ARNES_ID_F2" ARNES_IDM_L[$d]="$ARNES_ID_L" \
  ARNES_IDM_LN[$d]="$ARNES_ID_LN" ARNES_IDM_B[$d]="$ARNES_ID_B" ARNES_IDM_K[$d]="$ARNES_ID_K" \
  ARNES_IDM_X[$d]="$ARNES_ID_X" ARNES_IDM_V[$d]="$ARNES_ID_V" ARNES_IDM_FD[$d]="$ARNES_ID_FD" \
  ARNES_IDM_O[$d]="$ARNES_ID_O" ARNES_IDM_R[$d]="$ARNES_ID_R"
}

_arnes_id_calcula() {
  local p="$1" abs c dirref=0
  ARNES_ID_RUTA="$1" ARNES_ID_E=ok ARNES_ID_C='' ARNES_ID_A='' ARNES_ID_F='' ARNES_ID_F2='' \
  ARNES_ID_L='' ARNES_ID_LN='' ARNES_ID_B=0 ARNES_ID_K=0 ARNES_ID_X=0 ARNES_ID_V=0 ARNES_ID_FD='' \
  ARNES_ID_O='' ARNES_ID_R=0
  _arnes_raices
  if [ -z "$p" ]; then _arnes_nodet "la ruta esta vacia" "escribe la ruta del archivo"; return 0; fi
  # CA-47, punto 12: el `file_path` que la puerta juzga, si su texto TAL COMO LLEGA lleva un salto de
  # linea, es no determinable (y se aplica el punto 7). La ruta se lee entera (punto 11), pero que
  # archivo escribira la herramienta con ese argumento —el nombre literal, con el salto, o uno
  # recortado— no esta medido, y juzgar solo la ruta entera daria permiso apoyandose en esa conducta.
  # SOLO el `file_path`: ni el `cwd` (que solo ancla: con un salto se admite, y con un retorno de
  # carro no ancla, mas abajo) ni los destinos de `Bash`, que el shell escribe
  # tal como los deletrea el comando —y que ademas nunca llevan un salto: el detector trocea por
  # palabras y sus llamadores leen sus destinos de uno en uno, por lineas—.
  case "$p" in
    *$'\n'*) if [ "${ARNES_TOOL:-}" != Bash ] && [ "$p" = "${ARNES_FP:-}" ]; then
               _arnes_nodet "lleva un salto de linea, y no se sabe que archivo se escribiria con esa ruta: el nombre literal, con el salto, o uno recortado" \
                            "escribe la ruta sin saltos de linea"; return 0
             fi ;;
  esac
  # Lo mismo con un retorno de carro, por coherencia con el punto 12 (QA-023-13). Lo decide la cuenta
  # que hizo jq sobre el valor crudo (`ARNES_FP_CR`, `arnes_parse_input`), no el texto que llega aqui:
  # el transporte retira el CR del final, y hasta cd6afa6 la puerta juzgaba `<raiz>/docs/l` cuando la
  # herramienta escribe en `<raiz>/docs/l␍` —un enlace a `src/a.ts`—, que es permitir otra ruta. Mismo
  # alcance que el salto: el `file_path` de toda llamada que no sea de `Bash`.
  if [ "${ARNES_FP_CR:-0}" = 1 ] && [ "${ARNES_TOOL:-}" != Bash ] && [ "$p" = "${ARNES_FP:-}" ]; then
    _arnes_nodet "lleva un retorno de carro, y no se sabe que archivo se escribiria con esa ruta: el nombre literal, con el retorno de carro, o uno recortado" \
                 "escribe la ruta sin retornos de carro"; return 0
  fi
  if [ "${#p}" -gt "$ARNES_ID_MAX" ]; then
    _arnes_nodet "mide ${#p} caracteres, mas de los $ARNES_ID_MAX que el sistema abre" "acorta la ruta"; return 0
  fi
  if [ -z "$ARNES_RAIZ_FIS" ]; then
    _arnes_nodet "la raiz del proyecto no se puede resolver en el sistema de archivos" "comprueba que la raiz del proyecto se pueda recorrer"; return 0
  fi
  # CA-47, punto 10: la barra final (el detector la emite para `cp`/`mv`/`install` hacia un
  # directorio) designa una escritura DENTRO de ese directorio, y ese sentido se conserva.
  case "$p" in ?*/) while [ "${#p}" -gt 1 ] && [ "${p%/}" != "$p" ]; do p="${p%/}"; ARNES_ID_B=1; done ;; esac
  # CA-47, punto 1: una relativa se ancla en el `cwd` de la entrada, NO en la raiz.
  case "$p" in
    /*) abs="$p" ;;
    [A-Za-z]:[/\\]*) abs="${p//\\//}" ;;
    *)
      # QA-023-13: un `cwd` con un retorno de carro no ancla. El transporte de la entrada retira el
      # CR que lo cierra, y anclar en lo que queda era juzgar OTRO directorio que el del shell;
      # `arnes_parse_input` lo detecta en el valor crudo y lo vacia. Se dice por que, no «falta».
      if [ "${ARNES_CWD_CR:-0}" = 1 ]; then
        _arnes_nodet "es relativa y el directorio de trabajo de la entrada ('cwd') contiene un retorno de carro, que la lectura de la entrada no conserva con certeza (el del final se confunde con el fin de linea de Windows), asi que no se sabe en que directorio se anclaria" \
                     "escribe la ruta absoluta, o trabaja desde un directorio cuyo nombre no lleve retornos de carro"; return 0
      fi
      c="${ARNES_CWD:-}"
      case "$c" in
        /*) ;;
        [A-Za-z]:[/\\]*) c="${c//\\//}" ;;
        *) _arnes_nodet "es relativa y la entrada del hook no trae un directorio de trabajo absoluto ('cwd') en el que anclarla" \
                        "escribe la ruta absoluta"; return 0 ;;
      esac
      # El `cwd` es el mismo para todos los destinos de la llamada: se comprueba una vez.
      if [ "$c" != "${ARNES_CWD_VISTO:-}" ]; then
        if [ ! -d "$c" ]; then
          _arnes_nodet "es relativa y el directorio de trabajo de la entrada ('cwd') no es un directorio que exista y se pueda recorrer" \
                       "escribe la ruta absoluta"; return 0
        fi
        ARNES_CWD_VISTO="$c"
      fi
      [ "$c" = / ] || c="${c%/}"
      abs="$c/$p" ;;
  esac
  _arnes_lectura_lexica "$abs"; ARNES_ID_L="$ARNES_LL"
  # Ningun prefijo queda fuera (SEC-122): `/dev/…` y `/proc/…` se identifican como cualquier otra
  # ruta, con su lectura fisica, su enlace y su existencia. Lo que dependa del proceso se ve abajo.
  # Las barras repetidas no cambian el archivo (salvo la doble INICIAL, que es de la plataforma).
  case "$abs" in
    *//*) case "$abs" in //|//[!/]*) c='//'; abs="${abs#//}" ;; *) c='' ;; esac
          while [ "$abs" != "${abs//\/\//\/}" ]; do abs="${abs//\/\//\/}"; done
          abs="$c$abs" ;;
  esac
  case "$abs" in */.|*/..) dirref=1 ;; esac
  [ "$ARNES_ID_B" = 0 ] || dirref=1
  _arnes_lectura_fisica "$abs" "$dirref" || return 0
  ARNES_ID_F="$ARNES_LF"; ARNES_ID_FD="$ARNES_LF_DIR"; ARNES_ID_O="$ARNES_LF"
  # SEC-122: aterrizo en la entrada propia de /proc -> depende del proceso (`_arnes_id_propio`).
  if _arnes_propio "$ARNES_LF_DIR"; then
    c=''; [ "$dirref" = 1 ] || c="${ARNES_LF##*/}"
    _arnes_id_propio "$ARNES_LF_DIR" "$ARNES_LF_RESTO" "$c" "$BASHPID"; return 0
  fi
  if [ "$ARNES_LF_RESTO" = 0 ]; then
    if [ "$dirref" = 0 ] && [ -L "$ARNES_LF" ]; then ARNES_ID_K=1; ARNES_ID_X=1
    elif [ -e "$ARNES_LF" ]; then ARNES_ID_X=1; fi
  fi
  # CA-47, punto 4: con un `..` en la ruta, las dos lecturas pueden designar archivos distintos
  # (un `..` detras de un directorio enlazado). Sin `..` no pueden: `.` y `//` no cambian nada.
  case "/$abs/" in
    */../*)
      if _arnes_lectura_fisica "$ARNES_ID_L" "$dirref"; then
        # La lectura del texto, sin los `..`, depende del proceso (SEC-122): no se sabe que designa.
        if _arnes_propio "$ARNES_LF_DIR"; then _arnes_nodet "$ARNES_PROC_CAUSA" "$ARNES_PROC_ARREGLO"; return 0; fi
        ARNES_ID_F2="$ARNES_LF"; [ "$ARNES_ID_F2" = "$ARNES_ID_F" ] || ARNES_ID_V=1
      else
        # La lectura lexica no se puede situar: no se sabe si designan el mismo archivo.
        ARNES_ID_E=ok; ARNES_ID_C=''; ARNES_ID_A=''; ARNES_ID_V=2
      fi ;;
  esac
  return 0
}

# CA-49 (ii): el ultimo componente es un enlace y hay que juzgar su DESTINO. Es lo unico de esta
# seccion que cuesta un proceso —bash no lee un enlace sin uno— y se paga solo aqui: como mucho uno
# por destino, y memorizado. `readlink -f` resuelve la cadena entera en esa sola llamada; si no
# puede (un bucle, un destino cuyo directorio no existe, `readlink` ausente), no determinable.
#
# LO QUE DEPENDE DEL PROCESO (SEC-122), en dos pasos y sin procesos de mas:
#   1. ¿El enlace lleva a un descriptor ESTANDAR de quien lo abre —`/dev/stderr`, `/dev/stdout`,
#      `/dev/stdin`, o cualquier enlace a `/proc/self/fd/{0,1,2}`—? Se le PREGUNTA al sistema, no a una
#      lista de nombres: se cambian por un instante los descriptores 0, 1 y 2 de este proceso (a
#      `/dev/null`, y luego cerrados) y se mira si el enlace existe en los dos casos. Si su existencia
#      cambia con nuestros descriptores, lleva a uno de ellos: es un descriptor (`_arnes_id_propio`).
#      Sin proceso, que es lo que deja `> /dev/stderr` en 0 procesos (CA-48 (i.1)). Hace falta antes de
#      `readlink`, porque hay `readlink` que reabren sus descriptores estandar al arrancar y responden
#      `/dev/null` (medido en uutils coreutils 0.8.0).
#   2. Si no, `readlink -f` en un subshell que, antes de convertirse en `readlink`, se situa en el
#      directorio de `_arnes_cd_resolucion` y dice su propio PID: lo que aterrice en SU entrada de /proc
#      depende del proceso (`/proc/self/…`, `/dev/fd/N` con N >= 3, su directorio de trabajo cuando no
#      se conoce el del que escribe). Sigue siendo un solo proceso: `exec`.
_arnes_id_resuelve_enlace() {
  local t pid a=1 b=1
  [ "$ARNES_ID_K" = 1 ] && [ "$ARNES_ID_R" = 0 ] || return 0
  ARNES_ID_R=1
  { [ -e "$ARNES_ID_F" ] && a=0; } 0</dev/null 1>/dev/null 2>/dev/null
  { [ -e "$ARNES_ID_F" ] && b=0; } 0<&- 1>&- 2>&-
  if [ "$a" != "$b" ]; then _arnes_id_descriptor; _arnes_id_guarda; return 0; fi
  t="$(_arnes_cd_resolucion && printf '%s\n' "$BASHPID" && exec readlink -f -- "$ARNES_ID_F" 2>/dev/null)"
  case "$t" in *$'\n'*) pid="${t%%$'\n'*}"; t="${t#*$'\n'}" ;; *) pid=''; t='' ;; esac
  case "$t" in
    /*|[A-Za-z]:/*)
      case "$t" in //|//[!/]*) [ "${ARNES_DOBLE_ES_RAIZ:-0}" = 1 ] && t="${t#/}" ;; esac
      case "$t/" in
        "/proc/$pid/"*) _arnes_id_propio "${t%/*}" 0 "${t##*/}" "$pid" ;;
        *) ARNES_ID_O="$t"; ARNES_ID_X=0
           if [ -e "$t" ] || [ -L "$t" ]; then ARNES_ID_X=1; fi ;;
      esac ;;
    *)
      _arnes_nodet "su ultimo componente es un enlace simbolico cuyo destino no se puede resolver (un bucle, o un destino cuyo directorio no existe)" \
                   "escribe sobre el archivo al que apunta, por su ruta" ;;
  esac
  _arnes_id_guarda
}

# El tramo fijo de un patron (CA-47, punto 6 (c)): el `requirements_dir` entero; en un glob, sus
# segmentos de directorio anteriores al primero que contiene un comodin. Vacio = la raiz misma.
_arnes_tramo_fijo() {   # <patron> <1 si es un glob> -> ARNES_TRAMO (memorizado por patron)
  local r seg k="$2:$1"
  if [ -n "${ARNES_TRAMO_TXT[$k]+x}" ]; then ARNES_TRAMO="${ARNES_TRAMO_TXT[$k]}"; return 0; fi
  ARNES_TRAMO="$1"
  if [ "$2" = 1 ]; then
    ARNES_TRAMO=''
    case "$1" in */*) r="${1%/*}" ;; *) r='' ;; esac
    while [ -n "$r" ]; do
      seg="${r%%/*}"
      if [ "$seg" = "$r" ]; then r=''; else r="${r#*/}"; fi
      case "$seg" in *[\*\?\[]*) break ;; esac
      ARNES_TRAMO="${ARNES_TRAMO:+$ARNES_TRAMO/}$seg"
    done
  fi
  ARNES_TRAMO_TXT[$k]="$ARNES_TRAMO"
}

# La identidad fisica de un tramo, una vez por invocacion. Un tramo que no existe no aporta
# pertenencia por esta via (queda vacio); las otras dos siguen valiendo.
_arnes_tramo_fisico() {   # <tramo> -> ARNES_TRAMO_F
  local t="$1" orig="$PWD" CDPATH=''
  if [ -n "${ARNES_TRAMO_FIS[$t]+x}" ]; then ARNES_TRAMO_F="${ARNES_TRAMO_FIS[$t]}"; return 0; fi
  ARNES_TRAMO_F=''
  if cd -P -- "$ARNES_RAIZ_FIS/$t" 2>/dev/null; then _arnes_pwd_fisico; ARNES_TRAMO_F="$ARNES_PWD_FIS"; fi
  cd -- "$orig" 2>/dev/null
  ARNES_TRAMO_FIS[$t]="$ARNES_TRAMO_F"
}

# ¿La ruta relativa <rel> pertenece al patron <p> del ambito <amb>?
_arnes_casa_patron() {   # <amb> <patron> <rel>
  case "$1" in
    req)        case "$3" in "$2"/*) return 0 ;; esac; return 1 ;;
    # shellcheck disable=SC2053  -- glob a la derecha a proposito
    codigo)     [[ "$3" == $2 ]] ;;
    manifiesto) [ "$3" = "$2" ] ;;
  esac
}

# arnes_id_pertenece <req|codigo|manifiesto> — la pertenencia del destino identificado por la
# ultima `arnes_identidad` al ambito de una puerta (CA-47, punto 6): pertenece si pertenece por
# CUALQUIERA de las tres vias —(a) la fisica respecto de la raiz fisica, (b) la lexica respecto de
# la raiz del entorno o de la fisica, (c) la fisica bajo el tramo fijo de un patron— y queda fuera
# solo si no pertenece por ninguna. 0 = dentro (ARNES_ID_REL), 1 = fuera, 2 = no determinable, que
# cada puerta trata como dentro con su regla (CA-47, punto 7).
# Los patrones de un ambito y, de sus tramos fijos, SOLO los que aportan algo por la via (c) —los que
# son o atraviesan un enlace—, preparados una vez por invocacion: un comando de `Bash` con miles de
# destinos no vuelve a calcularlos por destino (medido). Un tramo cuya identidad fisica es exactamente
# `<raiz fisica>/<tramo>` reconstruye la misma ruta relativa que la via (a), que ya se probo contra
# todos los patrones, y un tramo que no existe no aporta pertenencia por esta via.
_arnes_ambito() {   # <req|codigo|manifiesto> -> ARNES_AMB_<amb>_P (patrones), _T/_F/_Q (tramo, su identidad fisica, su patron)
  [ -z "${ARNES_AMB_LISTO[$1]:-}" ] || return 0
  ARNES_AMB_LISTO[$1]=1
  local -n p="ARNES_AMB_${1}_P" t="ARNES_AMB_${1}_T" f="ARNES_AMB_${1}_F" q="ARNES_AMB_${1}_Q"
  local x g=1
  case "$1" in
    req)        g=0; [ -z "${ARNES_REQ_DIR:-}" ] || p=("$ARNES_REQ_DIR") ;;
    codigo)     for x in ${ARNES_GLOBS[@]+"${ARNES_GLOBS[@]}"}; do p+=("$x"); done ;;
    manifiesto) p=("$ARNES_MANIF_REL") ;;
  esac
  for x in ${p[@]+"${p[@]}"}; do
    _arnes_tramo_fijo "$x" "$g"; [ -n "$ARNES_TRAMO" ] || continue
    _arnes_tramo_fisico "$ARNES_TRAMO"; [ -n "$ARNES_TRAMO_F" ] || continue
    [ "$ARNES_TRAMO_F" != "$ARNES_RAIZ_FIS/$ARNES_TRAMO" ] || continue
    t+=("$ARNES_TRAMO"); f+=("$ARNES_TRAMO_F"); q+=("$x")
  done
}

arnes_id_pertenece() {
  local amb="$1" x r rel via
  local -a fis=() rels=()
  _arnes_ambito "$amb"
  local -n pats="ARNES_AMB_${amb}_P" ct="ARNES_AMB_${amb}_T" cf="ARNES_AMB_${amb}_F" cq="ARNES_AMB_${amb}_Q"
  # Un ambito sin ningun patron no tiene «dentro»: ni siquiera un destino no determinable cae en el.
  [ "${#pats[@]}" -gt 0 ] || return 1
  # Un descriptor del shell (SEC-122, `_arnes_id_propio`) no es un archivo de ningun ambito, pero la
  # RUTA por la que se llega a el se juzga por las tres vias de abajo, como la de cualquier otro enlace
  # (QA-023-17, pasada correctiva de la octava autorizacion): `src/log -> /dev/stderr` esta en `src/*`
  # por su lectura fisica y por la lexica, y salia «fuera» antes de mirarlas. Su destino —la ranura
  # del descriptor— no aporta pertenencia: no entra en `fis` (`ARNES_ID_O` sigue siendo el enlace).
  case "$ARNES_ID_E" in ok|desc) ;; *) return 2 ;; esac
  if [ "$ARNES_ID_K" = 1 ]; then
    _arnes_id_resuelve_enlace
    case "$ARNES_ID_E" in ok|desc) ;; *) return 2 ;; esac
  fi
  [ -z "$ARNES_ID_F" ]  || fis+=("$ARNES_ID_F")
  [ -z "$ARNES_ID_F2" ] || fis+=("$ARNES_ID_F2")
  [ "$ARNES_ID_O" = "$ARNES_ID_F" ] || [ -z "$ARNES_ID_O" ] || fis+=("$ARNES_ID_O")
  ARNES_ID_REL=''
  # (a), y si no basta (b): las lecturas relativas a las raices, contra todos los patrones del
  # ambito. La (b) necesita la forma de comparacion, que se calcula aqui y solo si hace falta.
  for x in ${fis[@]+"${fis[@]}"}; do _arnes_bajo "$x" "$ARNES_RAIZ_FIS" && rels+=("${ARNES_BAJO:-.}"); done
  for via in a b; do
    if [ "$via" = b ]; then
      rels=(); _arnes_id_ln
      [ -n "$ARNES_ID_LN" ] || break
      # Con la lectura lexica igual a la fisica y las tres raices iguales, (b) daria las mismas
      # rutas relativas que (a), que ya se probaron contra todos los patrones.
      if [ "$ARNES_ID_LN" = "$ARNES_ID_F" ] && [ "$ARNES_RAIZ_ENV_N" = "$ARNES_RAIZ_FIS" ] \
         && [ "$ARNES_RAIZ_FIS_N" = "$ARNES_RAIZ_FIS" ]; then break; fi
      _arnes_bajo "$ARNES_ID_LN" "$ARNES_RAIZ_ENV_N" && rels+=("${ARNES_BAJO:-.}")
      _arnes_bajo "$ARNES_ID_LN" "$ARNES_RAIZ_FIS_N" && rels+=("${ARNES_BAJO:-.}")
    fi
    for rel in ${rels[@]+"${rels[@]}"}; do
      [ "$ARNES_ID_B" = 1 ] && rel="$rel/"
      for ((r = 0; r < ${#pats[@]}; r++)); do
        if _arnes_casa_patron "$amb" "${pats[r]}" "$rel"; then ARNES_ID_REL="$rel"; break 3; fi
      done
    done
  done
  # (c): la fisica bajo la identidad fisica del tramo fijo de cada patron, reconstruida desde el; solo
  # los tramos que aportan (`_arnes_ambito`).
  if [ -z "$ARNES_ID_REL" ]; then
    for ((r = 0; r < ${#ct[@]}; r++)); do
      for x in ${fis[@]+"${fis[@]}"}; do
        _arnes_bajo "$x" "${cf[r]}" || continue
        rel="${ct[r]}${ARNES_BAJO:+/$ARNES_BAJO}"; [ "$ARNES_ID_B" = 1 ] && rel="$rel/"
        if _arnes_casa_patron "$amb" "${cq[r]}" "$rel"; then ARNES_ID_REL="$rel"; break 2; fi
      done
    done
  fi
  [ -n "$ARNES_ID_REL" ] || return 1
  # CA-47, punto 4: dentro del ambito por alguna lectura y con las dos designando archivos
  # distintos, la puerta no puede saber cual escribira la herramienta. Es no determinable PARA ESTE
  # AMBITO —«y alguna cae en el ambito»—, asi que se publica la causa y NO se memoriza como estado
  # del destino: otra puerta, con otro ambito, puede tenerlo fuera.
  case "$ARNES_ID_V" in
    1) ARNES_ID_C="sus dos lecturas —la del sistema de archivos, que sigue los enlaces, y la del texto, que retira los '..'— designan archivos distintos (un '..' detras de un directorio enlazado), y alguna cae en la zona protegida"
       ARNES_ID_A="escribe la ruta sin '..' detras de un directorio enlazado" ;;
    2) ARNES_ID_C="la lectura de su texto, que retira los '..', no se puede situar en el sistema de archivos, asi que no se sabe si designa el mismo archivo que la del sistema, y alguna cae en la zona protegida"
       ARNES_ID_A="escribe la ruta sin '..'" ;;
    *) return 0 ;;
  esac
  return 2
}

# Una ruta citada en un motivo, CON TOPE: como mucho ARNES_CITA_RUTA_BYTES bytes, y con todo byte
# >= 0x80 o de control escapado (`printf %q` bajo LC_ALL=C), para que se vea lo que no se ve y el
# motivo no herede SEC-118 (el motivo viaja como UN argumento de `jq`). Sin procesos.
ARNES_CITA_RUTA_BYTES=200
arnes_cita_ruta() {   # <ruta> -> ARNES_CITA_RUTA
  local LC_ALL=C q="$1" corte=''
  if [ "${#q}" -gt "$ARNES_CITA_RUTA_BYTES" ]; then
    corte="... (mide ${#q} bytes; se muestran los primeros $ARNES_CITA_RUTA_BYTES)"
    q="${q:0:$ARNES_CITA_RUTA_BYTES}"
  fi
  case "$q" in
    *[!" $ARNES_ESQ_LETRAS$ARNES_ESTRUCTURA_ASCII"]*) printf -v ARNES_CITA_RUTA '%q' "$q" ;;
    *) ARNES_CITA_RUTA="'$q'" ;;
  esac
  ARNES_CITA_RUTA+="$corte"
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
# Codigo de salida cuando NO analizo porque un retorno de carro del comando cae donde el analizador no
# puede seguir su significado (P-023-13-A, octava autorizacion; ver `arnes_bash_sin_texto`). Como el de
# arriba, nunca sale por la salida estandar y los dos guardianes lo traducen a una denegacion con motivo.
ARNES_RC_CR=3
# Codigo de salida cuando NO analizo porque una linea DEL CUERPO de un heredoc es su delimitador seguido
# de un retorno de carro y NO es la ultima linea del comando (SEC-124; REQ-007 CA-47, punto 18; novena
# autorizacion, opcion B del propietario). Para bash esa linea no cierra el cuerpo; pero el retorno de
# carro es un dato del transporte, y un shell que lo retire cerraria el cuerpo ahi y ejecutaria lo que va
# detras. No se retira en silencio ni se juzga otro comando: se deniega la forma. Como los dos de arriba,
# nunca sale por la salida estandar y las puertas lo traducen a una denegacion con motivo que cita SEC-124.
ARNES_RC_CUERPO_CR=4
# Codigo de salida cuando NO analizo porque la linea que abre un heredoc de delimitador limpio acaba en una
# continuacion de linea (SEC-125, LC10; REQ-007 CA-47, punto 19, «Excepcion nombrada»; P-LC10-A = A). Para el
# shell la orden sigue en la linea siguiente y el cuerpo empieza despues de ella; el analizador empezaba el
# cuerpo EN ella (QA-023-23). No se unen las lineas ni se mueve la frontera: se deniega la forma, a todo agente y
# en las cuatro puertas, con el motivo unico de `arnes_deny_lc10`. Precede REQ-001 CA-53: si el comando supera
# el presupuesto, sale `$ARNES_RC_EXCESO` y no este (QA-023-25).
ARNES_RC_LC10=5

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

# --- Continuaciones de linea (SEC-125; REQ-007 CA-47, punto 19) ----------------------------------
# `_arnes_fin_linea <linea>`: lee una linea DE ORDEN (nunca de cuerpo de heredoc) y deja ARNES_CONT=1 si acaba
# en una continuacion de linea EFECTIVA —una barra invertida que el shell no tiene citada ni escapada, seguida
# del salto—, actualizando ARNES_SQ y ARNES_DQ, el estado de comillas simples y dobles que cruza de una linea a
# la siguiente. La regla es la del shell (manual de bash, «Escape Character» y «Quoting») y no se redefine:
# dentro de comillas simples nada se escapa y `\`+salto es literal; dentro de dobles la barra escapa al caracter
# siguiente y `\`+salto SI es continuacion; una barra ya escapada (`\\`) no lo es; un caracter entre la barra y
# el salto (un espacio, un retorno de carro) tampoco; y en un comentario (`#` al empezar una palabra, fuera de
# comillas) nada lo es. Sin procesos. Recorre caracter a caracter SOLO las lineas que llevan comillas, barras o
# almohadillas, y solo se llama cuando el comando entero contiene alguna barra seguida de salto (ver abajo):
# el camino comun de `Bash` no paga nada.
ARNES_SQ=0; ARNES_DQ=0; ARNES_CONT=0
_arnes_fin_linea() {
  local l="$1" i n c esc=0 com=0 prev=' '
  ARNES_CONT=0
  case "$l" in *[\'\"\\#]*) ;; *) return 0 ;; esac
  n=${#l}
  for ((i = 0; i < n; i++)); do
    c="${l:i:1}"
    if [ "$com" -eq 1 ]; then break; fi
    if [ "$ARNES_SQ" -eq 1 ]; then [ "$c" != "'" ] || ARNES_SQ=0; prev="$c"; continue; fi
    if [ "$esc" -eq 1 ]; then esc=0; prev="$c"; continue; fi
    case "$c" in
      \\) esc=1 ;;
      \") if [ "$ARNES_DQ" -eq 1 ]; then ARNES_DQ=0; else ARNES_DQ=1; fi ;;
      \') [ "$ARNES_DQ" -eq 1 ] || ARNES_SQ=1 ;;
      \#) if [ "$ARNES_DQ" -eq 0 ]; then case "$prev" in ' '|$'\t'|';'|'|'|'&'|'(') com=1 ;; esac; fi ;;
    esac
    prev="$c"
  done
  if [ "$esc" -eq 1 ] && [ "$com" -eq 0 ]; then ARNES_CONT=1; fi
  return 0
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
#
# Y `$ARNES_RC_CR` (3), TAMBIEN SIN ANALIZAR NADA, cuando el delimitador de un heredoc lleva
# un retorno de carro (P-023-13-A, octava autorizacion). El texto del comando llega ahora con
# sus CR (`arnes_parse_input`), y para el shell un CR es un caracter de palabra: el troceado
# de abajo lo trata igual (`IFS` sin CR) y un destino `k\r` se juzga como `k\r`, que es lo que
# el shell escribe. El unico sitio donde este analizador NO lo sigue es el delimitador del
# heredoc: lo corta en `[[:space:]]`, que incluye el CR, mientras que para el shell `EOF\r` es
# la palabra entera y el cuerpo acaba en una linea `EOF\r`. Con el CR conservado, un
# `cat <<'EOF'\r` haria buscar una linea `EOF` que no llega nunca, y todo lo que sigue se
# descontaria como cuerpo —tambien un `echo x > src/a.ts` que el shell SI ejecuta—: el
# fallo en abierto que la autorizacion prohibe («nunca lo elimines silenciosamente para
# juzgar un comando distinto»). No se reescribe el analizador para seguirlo: se deniega,
# como ordena la misma autorizacion cuando el analisis no puede preservar el significado.
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
  #
  #    Y LAS CONTINUACIONES DE LINEA (SEC-125; CA-47, punto 19): un `\`+salto que el shell une se une aqui
  #    tambien, SOLO entre lineas de orden y SOLO donde el shell lo une (`_arnes_fin_linea`), de modo que el
  #    destino de una escritura partida en dos lineas se juzga entero, el que el shell escribe. Nunca se une
  #    nada dentro de un cuerpo de heredoc, y la deteccion del heredoc sigue siendo por linea fisica, como
  #    antes: el pliegue no mueve ninguna frontera. La unica forma que no se une es la que abre un heredoc y
  #    acaba en continuacion (LC10): se deniega entera, despues del presupuesto.
  local cont_hay=0 pend=0 lc10=0
  case "$limpio" in *\\$'\n'*) cont_hay=1; ARNES_SQ=0; ARNES_DQ=0 ;; esac
  if [[ "$limpio" == *'<<'* ]] || [ "$cont_hay" -eq 1 ]; then
    local linea delim='' dentro=0 citado=0 resto sinhs cr_delim=0 cuerpo_cr=0 pos=0
    local -a sin=()
    while IFS= read -r linea || [ -n "$linea" ]; do
      pos=$(( pos + ${#linea} + 1 ))   # donde empieza la linea SIGUIENTE dentro de `$limpio`
      if [ "$dentro" -eq 1 ]; then
        resto="${linea#"${linea%%[![:blank:]]*}"}"     # `<<-` admite sangria delante del cierre
        if [ "$resto" = "$delim" ]; then dentro=0; continue; fi
        # SEC-124 (CA-47, punto 18): la linea del cuerpo que es el delimitador seguido de un retorno de
        # carro, con algo mas que blancos detras en el comando. Para bash no cierra el cuerpo; para un
        # shell que retire el CR, si, y lo que sigue seria orden. No se decide cual: se deniega la forma.
        # Como ultima linea del comando no hay nada detras que pudiera ejecutarse, y se trata como cuerpo.
        if [ "$resto" = "$delim"$'\r' ] && [[ "${limpio:pos}" == *[![:space:]]* ]]; then cuerpo_cr=1; break; fi
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
      ARNES_CONT=0
      if [ "$cont_hay" -eq 1 ]; then
        _arnes_fin_linea "$linea"
        # La linea anterior acabo en continuacion efectiva: esta es su continuacion, y se unen como las une el
        # shell (fuera la barra y el salto). La deteccion del heredoc, abajo, sigue mirando la linea fisica.
        if [ "$pend" -eq 1 ]; then sin[-1]="${sin[-1]%\\}$linea"; else sin+=("$linea"); fi
        pend=$ARNES_CONT
      else
        sin+=("$linea")
      fi
      sinhs="${linea//<<</ }"
      case "$sinhs" in
        *'(('*'<<'*) ;;                                  # `$((1<<n))` es aritmetica, no heredoc
        *'<<'*)
        resto="${sinhs#*<<}"; resto="${resto#-}"
        resto="${resto#"${resto%%[! ]*}"}"             # espacios entre `<<` y la palabra
        # Citado o escapado -> cuerpo literal. Se anota ANTES de pelar las comillas,
        # que es justo la marca que las distingue.
        citado=0; case "$resto" in \'*|\"*|\\*) citado=1 ;; esac
        # La palabra del delimitador tal como la corta el shell —hasta un blanco o un metacaracter,
        # y el CR no es ninguna de las dos cosas—: si lleva un CR, este analizador no la sigue
        # (arriba). Lineal: el `%%` se detiene en el primer metacaracter.
        case "${resto%%[[:blank:]\;\|\&\(\)\<\>]*}" in *$'\r'*) cr_delim=1; break ;; esac
        delim="${resto%%[[:space:]\;\|\&\)\<\>]*}"
        delim="${delim#\'}"; delim="${delim%\'}"; delim="${delim#\"}"; delim="${delim%\"}"
        delim="${delim#\\}"
        # Una PALABRA: empieza por letra o `_` (EOF, PY, END, SQL...). `1<<2` da `2` y no lo es.
        case "$delim" in
          [A-Za-z_]*) case "$delim" in *[!A-Za-z0-9_]*) delim='' ;; *) dentro=1 ;; esac ;;
          *) delim='' ;;
        esac ;;
      esac
      # LC10 (CA-47, punto 19, «Excepcion nombrada»): esta linea abre un heredoc y acaba en una continuacion
      # efectiva. Se anota y se sigue analizando como hasta ahora (ni se une ni se mueve la frontera), para que
      # el presupuesto se cuente igual que siempre y REQ-001 CA-53 mande si lo supera (QA-023-25).
      if [ "$dentro" -eq 1 ]; then pend=0; if [ "$ARNES_CONT" -eq 1 ]; then lc10=1; fi; fi
    done <<< "$limpio"
    [ "$cr_delim" -eq 0 ] || return "$ARNES_RC_CR"
    [ "$cuerpo_cr" -eq 0 ] || return "$ARNES_RC_CUERPO_CR"
    IFS=$'\n'; limpio="${sin[*]}"; IFS=$' \t\n'
  fi
  # Segundo sumando del presupuesto: el texto de comando que queda FUERA de los cuerpos
  # de heredoc. Es el que recorre el camino comun, y tiene su propio acantilado.
  if [ "$exceso" -eq 0 ] && (( analizado + ${#limpio} > max_analisis )); then
    arnes_techo_bash; max_analisis="$ARNES_TECHO"
    (( analizado + ${#limpio} > max_analisis )) && exceso=1
  fi
  [ "$exceso" -eq 0 ] || return "$ARNES_RC_EXCESO"
  # LC10, despues del presupuesto (QA-023-25) y antes de analizar nada mas.
  [ "$lc10" -eq 0 ] || return "$ARNES_RC_LC10"
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
  # llamadores lo miran (y hay caso de banco para cada uno). Lo mismo con
  # `$ARNES_RC_CR` (3): el delimitador de un heredoc con un retorno de carro. Y con
  # `$ARNES_RC_CUERPO_CR` (4): una linea del cuerpo que es el delimitador seguido de un
  # retorno de carro y no es la ultima del comando (SEC-124). Y con `$ARNES_RC_LC10` (5):
  # la linea que abre un heredoc acaba en una continuacion de linea (SEC-125, LC10).
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
#
# «NO EXISTE» SOLO LO SABE QUIEN RESOLVIO EL CAMINO (REQ-007 CA-47, punto 8). `-e` tambien
# falla cuando un directorio de la ruta no se puede recorrer, y eso no es «no existe»: es «no
# se pudo determinar». Por eso `guard-completado` ya no llama aqui con la ruta escrita: decide
# la existencia con `arnes_identidad`, que resolvio el tramo existente, y solo pregunta aqui por
# un archivo que existe en su lectura fisica. La cola de aprobaciones (`arnes_cola_pendientes`)
# lee una ruta fija bajo la raiz y conserva esta conducta.
arnes_lee_archivo() {   # <ruta> -> ARNES_TEXTO ; 0 = leído entero, 1 = NO medible
  ARNES_TEXTO=''
  [ -e "$1" ] || return 0        # no existe —o su camino no se deja recorrer: aqui no se distingue (arriba)
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
# archivo ilegible— no devuelve 0, devuelve «no lo sé» (rc 1). Contar 0 sobre un archivo
# truncado abriría el cierre de cualquier REQ con aprobaciones humanas pendientes.
arnes_cola_pendientes() {   # <archivo> -> ARNES_COLA ; 0 = medido, 1 = NO medible
  local linea resto dentro=0 enc=0 n=0
  ARNES_COLA=0
  [ -e "$1" ] || return 0        # sin archivo no hay cola: cero, y es una medida
  arnes_lee_archivo "$1" || { ARNES_COLA=''; return 1; }
  while IFS= read -r linea; do
    linea="${linea%$'\r'}"       # CRLF: el retorno de carro no puede cambiar la cuenta
    # Comentarios HTML, con la misma semántica que tenía el awk de la puerta: la línea
    # que ABRE ya no cuenta, y la que CIERRA tampoco.
    case "$linea" in *'<!--'*) enc=1 ;; esac
    case "$linea" in *'-->'*)  enc=0; continue ;; esac
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
  ARNES_COLA="$n"
  return 0
}

# --- SEC-004: un enlace en el ULTIMO componente, dentro del proyecto, no se atraviesa --------
# REQ-007 CA-49 (i), versionado el 2026-09-30 (ADR-016). La decision del 2026-09-05 se apoyaba
# en «el arnes juzga la ruta escrita, no su destino», y esa premisa la desmintio SEC-119: por un
# DIRECTORIO enlazado, que esta regla no miraba, un REQ `critico` en rojo quedo `completado` en
# el host real. La identidad del destino es ahora la de CA-47 (`arnes_identidad`, arriba), y de
# aquella decision se conserva SOLO la regla del ultimo componente: por `Edit`/`Write`/`MultiEdit`,
# si el ultimo componente es un enlace situado DENTRO de la raiz —su directorio, por la lectura
# fisica o por la lexica—, se deniega sea cual sea su destino y sea cual sea el agente. Se
# comprueba sin resolver el destino y sin procesos (`[ -L ]` sobre la lectura fisica).
#
# Lo demas lo juzga la identidad: un directorio enlazado en otro componente, un enlace situado
# FUERA de la raiz y todo enlace en un destino de `Bash` se juzgan por el archivo al que llevan
# (CA-49 (ii) y (iii)). Y ya no se excluyen las rutas con `..`: donde esta el enlace lo decide
# CA-47, no la forma del texto (CA-49 (iv)).
#
# ALCANCE: solo `Edit`/`Write`/`MultiEdit`. El camino comun de `Bash` no llega aqui ni paga nada.
arnes_deny_enlace() {   # -> deniega si el ultimo componente del `file_path` es un enlace dentro de la raiz
  local ldir vista="$ARNES_FP"
  case "$ARNES_TOOL" in Edit|Write|MultiEdit) ;; *) return 0 ;; esac
  [ -n "$ARNES_FP" ] || return 0
  arnes_identidad "$ARNES_FP"
  [ "$ARNES_ID_E" = ok ] && [ "$ARNES_ID_K" = 1 ] || return 0
  _arnes_id_ln
  ldir="${ARNES_ID_LN%/*}"; [ -n "$ldir" ] || ldir=/
  _arnes_bajo "$ARNES_ID_FD" "$ARNES_RAIZ_FIS" || _arnes_bajo "$ldir" "$ARNES_RAIZ_ENV_N" \
    || _arnes_bajo "$ldir" "$ARNES_RAIZ_FIS_N" || return 0
  # El enlace se nombra relativo a la raiz cuando su lectura lexica cae en ella; si no, tal como llego.
  _arnes_bajo "$ARNES_ID_LN" "$ARNES_RAIZ_ENV_N" && vista="${ARNES_BAJO:-.}"
  arnes_cita_ruta "$vista"
  arnes_deny "ARNES: $ARNES_CITA_RUTA es un ENLACE SIMBOLICO situado dentro del proyecto, y no se escribe a traves de un enlace dentro del proyecto, apunte adonde apunte y lo intente quien lo intente. Salida: escribe sobre el archivo al que apunta, por su ruta (SEC-004, REQ-007 CA-49)."
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
#
# «ES EL MANIFIESTO» SE DECIDE POR IDENTIDAD, NO POR EL TEXTO (REQ-007 CA-60, versionado el
# 2026-09-30): toda escritura cuyo destino sea, por CA-47, el manifiesto del proyecto —tambien por
# una ruta equivalente— es la reparacion, con las mismas tres condiciones. Un destino que no se
# puede determinar NO es el manifiesto y sigue denegado.
arnes_deny_manifiesto_roto() {   # [destinos de escritura ya detectados por Bash, uno por linea]
  [ "${ARNES_MANIFEST_ROTO:-0}" = "1" ] || return 0
  local destinos d solo_manifiesto=1 manif_rel="$ARNES_MANIF_REL"
  case "$ARNES_TOOL" in
    # El `file_path` es UN destino y se identifica ENTERO, nunca linea a linea (CA-47, puntos 11 y
    # 12): troceado por lineas, `<manifiesto>\n` pasaba por la reparacion. Con un salto es no
    # determinable, y un destino que no se puede determinar no es el manifiesto (CA-60).
    Edit|Write|MultiEdit)
      if [ -n "$ARNES_FP" ]; then arnes_identidad "$ARNES_FP"; arnes_id_pertenece manifiesto || solo_manifiesto=0; fi ;;
    Bash)
      destinos="${1:-}"; [ -n "$destinos" ] || return 0
      while IFS= read -r d; do
        [ -n "$d" ] || continue
        arnes_identidad "$d"
        arnes_id_pertenece manifiesto || { solo_manifiesto=0; break; }
      done <<< "$destinos" ;;
    *) return 0 ;;
  esac
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
# (Tomar la ultima sigue siendo la regla de LECTURA; desde REQ-023, al CERRAR, una clave de
# control declarada mas de una vez fuera de toda cita deja la cabecera ambigua y deniega.)
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

# La UNICA puerta de entrada de un lector de cabecera: retira las citas y normaliza la
# clave. Existe para que ningun recorrido de cabecera pueda quedarse con la mitad de la
# regla — que es exactamente como nacio este defecto.
arnes_campo_linea() {   # <linea> -> 0 + ARNES_CLAVE/ARNES_VALOR; 1 si no declara campo
  arnes_sin_cita "$1"
  arnes_norm_clave "$ARNES_LINEA"
}

arnes_norm_clave() {   # <linea> -> 0 + ARNES_CLAVE/ARNES_VALOR; 1 si la linea no declara campo
  ARNES_CLAVE=''; ARNES_VALOR=''; ARNES_CLAVE_DECORADA=0
  local l="${1//$'\r'/}" k r crudo
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
}

# --- CABECERA AMBIGUA: UNA CLAVE DE CONTROL ESCRITA DE OTRA FORMA, O DECLARADA DOS VECES ---
#
# EL DEFECTO (SEC-047, QA-031-01; contrato REQ-023, decision ADR-014): el lector casa la
# clave por IGUALDAD EXACTA tras la tolerancia de siempre (blancos de los extremos, `*`, `_`,
# `` ` ``). `HALLAZGOS ABIERTOS:`, `Hallazgos  abiertos:`, un BOM o un U+200B delante o
# dentro, un NBSP en lugar del espacio, `- Rigor:` o `1. QA:` no casan, y la linea se
# resolvia como «no declara campo». Para una clave de control la AUSENCIA puede abrir: sin
# `Sensible a seguridad:` no hay suelo, sin `QA:` no se exige QA, sin `Hallazgos abiertos:`
# no hay hallazgos, sin `Rigor:` rige el heredado, y un `Estado:` que no se lee esconde la
# propia transicion. Y dos declaraciones de la misma clave se resolvian eligiendo una en
# silencio (la primera para `Estado`, la ultima para las demas).
#
# LA RESPUESTA ES OBSERVACIONAL: nada de aqui cambia ARNES_CLAVE ni ARNES_VALOR, asi que
# ningun lector —la puerta, `tools/arnes-lectura.sh`, `hooks/campos-req.awk`,
# `tools/arnes-paralelo.sh`— cambia el valor que lee. La variante NO se lee como la clave y
# la repeticion no se resuelve: quien recorre la cabecera las ANOTA (`arnes_campos_req`) y la
# puerta DENIEGA por cabecera ambigua un intento de cierre sobre el documento resultante
# (guard-completado; lo que no se bloquea y la frontera (g), en REQ-023 CA-01). Leer la
# variante como la clave ensancharia la tolerancia y obligaria a ELEGIR entre declaraciones.
#
# LA FRONTERA, escrita una vez y sin lista de caracteres (REQ-023 CA-01):
#   * CLAVES DE CONTROL: la constante de abajo, lista CERRADA de contrato. Todo lo nuevo de
#     esta guarda la lee de aqui —tambien el mensaje—, y el ESQUELETO de cada una se DERIVA de
#     ella (`_arnes_deriva_esqueletos`): una clave añadida a la constante queda cubierta sin
#     editar nada mas. `Archivos:` no es clave de control (`arnes-paralelo.sh` ya falla
#     cerrado cuando falta).
#   * MARCADOR: se retira COMO MUCHO UNO inicial —`-` o `+` y un blanco ASCII; o de 1 a 3
#     digitos, `.` o `)` y un blanco ASCII—, buscado TRAS SALTAR los bytes descartados: un BOM
#     delante de `- ` no decide si la linea es estructura o declaracion.
#   * ESTRUCTURA: si lo que queda contiene un imprimible ASCII que no es letra (0x21-0x7E
#     salvo A-Z y a-z) o uno de los nueve delimitadores de cita tipograficos
#     (« » “ ” ‘ ’ „ ‹ ›), la linea es una cita, mencion o referencia, no una declaracion.
#   * ESQUELETO: las letras ASCII de lo que queda, en minusculas y en orden. Para calcularlo
#     —NUNCA para leer— se descartan el espacio, los bytes de control, DEL y todo byte >= 0x80.
#   * VARIANTE: esqueleto de una clave de control, clave de no mas de 256 bytes, y distinta
#     byte a byte de esa clave tal como la entrega el lector. La clave exacta es CANONICA.
#
# LO QUE QUEDA FUERA, declarado y SIN promesa: un homoglifo (`Е` cirilica: la letra cae del
# esqueleto), una letra ASCII de mas, de menos o cambiada (otra palabra), unos dos puntos no
# ASCII (la linea no es candidata), una linea con un signo de estructura visible —tambien un
# NBSP en lugar del blanco que sigue al marcador— y una clave de mas de 256 bytes, que es una
# LIMITACION: se sigue leyendo como ausencia y ese limite no la protege. No se normaliza
# Unicode ni se enumera ningun caracter.
#
# LOCALE Y COSTE (REQ-023 CA-05, CA-09): todo bajo `LC_ALL=C` —bytes, sin colacion— y con las
# clases escritas SIN RANGOS, porque una clasificacion que dependa de LC_CTYPE denegaria en el
# CI de Linux y permitiria en Windows/MSYS, que es de donde sale el BOM. Lo PRIMERO es medir
# la clave en bytes: por encima de 256 no se hace nada mas SOBRE LA CLAVE, y por debajo el
# trabajo nuevo sobre ella —marcador, estructura, esqueleto— queda acotado por una constante.
# Eso NO acota todo el trabajo nuevo por linea: la medicion de la clave crece con la clave, y
# la captura de la cita de cada linea de control (`${l:0:80}` en `arnes_campos_req`, que en un
# locale UTF-8 recorre la linea, valor incluido) crece con la linea. Las dos son LINEALES, y
# no mas (REQ-023 CA-09 (iii); QA-023-04). Sin procesos, y en el recorrido que
# `arnes_campos_req` YA hace: una pasada mas multiplicaba un coste que ya existe (SEC-115).
ARNES_CLAVES_CONTROL='Estado|QA|Seguridad|Sensible a seguridad|Hallazgos abiertos|Rigor'
# La clave de control de la que se lee la TRANSICION (la que lee `arnes_estado_cabecera`).
# Es un PAPEL, no una lista: el banco comprueba que sea miembro de la constante.
ARNES_CLAVE_ESTADO='Estado'
ARNES_CLAVE_CONTROL_MAX_BYTES=256
ARNES_ESQ_LETRAS='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
ARNES_ESTRUCTURA_ASCII=$'!"#$%&\'()*+,-./0123456789:;<=>?@[\\]^_`{|}~'
# Los nueve delimitadores de cita, en bytes UTF-8 (« » “ ” ‘ ’ „ ‹ ›): lista cerrada de contrato.
ARNES_DELIM_CITA=($'\xc2\xab' $'\xc2\xbb' $'\xe2\x80\x9c' $'\xe2\x80\x9d' $'\xe2\x80\x98' \
                  $'\xe2\x80\x99' $'\xe2\x80\x9e' $'\xe2\x80\xb9' $'\xe2\x80\xba')
# Cuanto de cada linea ambigua se guarda para citarla (bytes), y cuantas cita el motivo de la
# puerta. El TOPE del motivo no es estilo: `arnes_deny` pasa el motivo como UN argumento de
# `jq`, y un argumento de mas de 128 KB (MAX_ARG_STRLEN) mata a `jq` sin salida — y una puerta
# sin salida PERMITE. `tools/arnes-lectura.sh` las nombra todas.
ARNES_AMBIGUA_CITA_BYTES=80
ARNES_AMBIGUA_MOTIVO_LINEAS=20
# Se DERIVAN al primer uso: los esqueletos (`|esqueleto=Clave|…|`) y las letras AJENAS —las del
# alfabeto del esqueleto que no aparecen, en ninguna de sus dos formas, en ninguna clave de
# control—. Se vacian al cargar para que ningun valor heredado del entorno las sustituya.
ARNES_ESQ_CONTROL=''; ARNES_ESQ_AJENAS=''

# Llamada SOLO desde `_arnes_clave_control`, que ya corre bajo `LC_ALL=C`.
_arnes_deriva_esqueletos() {
  local resto="$ARNES_CLAVES_CONTROL|" c e todas=''
  ARNES_ESQ_CONTROL='|'
  while [ -n "$resto" ]; do
    c="${resto%%|*}"; resto="${resto#*|}"
    e="${c//[!"$ARNES_ESQ_LETRAS"]/}"
    ARNES_ESQ_CONTROL+="${e,,}=$c|"; todas+="${e,,}"
  done
  ARNES_ESQ_AJENAS="${ARNES_ESQ_LETRAS//["$todas${todas^^}"]/}"
}

# ¿La linea declara una clave de control, canonica o variante? Lee ARNES_CLAVE (lo que el
# lector entrega de la linea SIN citas) y NADA mas de la linea: la clave se MIDE en bytes
# antes de cualquier otra cosa, y por encima del techo no se hace nada mas (REQ-023 CA-09 (iii)).
# -> 0 + ARNES_CTRL (la clave de control) + ARNES_CTRL_VARIANTE (0|1);
# -> 1 si la linea no declara ninguna clave de control (o queda fuera de la frontera).
# `local LC_ALL=C` devuelve el locale al salir: el lector de alrededor no cambia de lectura.
_arnes_clave_control() {
  local LC_ALL=C k r d c
  ARNES_CTRL=''; ARNES_CTRL_VARIANTE=0
  [ "${#ARNES_CLAVE}" -le "$ARNES_CLAVE_CONTROL_MAX_BYTES" ] || return 1
  k="$ARNES_CLAVE"
  # `|` es el separador de la constante: una clave que lo lleve no es ninguna de sus claves
  # (y como signo de estructura tampoco es variante).
  case "$k" in *'|'*) return 1 ;; esac
  # PREFILTRO, derivado de la constante y no una regla nueva: toda letra ASCII de la clave acaba
  # en su esqueleto (el marcador y los bytes descartados no llevan letras), asi que una clave con
  # una letra AJENA no tiene el esqueleto de ninguna clave de control, y tampoco es canonica. Es
  # la salida de casi toda clave corriente (`Prioridad`, `Archivos`, `Módulo`), y sin el la
  # clasificacion costaba lo bastante por linea como para comerse el margen del reloj de la
  # cabecera de 200 lineas (REQ-017 CA-08 (ii)).
  [ -n "$ARNES_ESQ_CONTROL" ] || _arnes_deriva_esqueletos
  if [ -n "$ARNES_ESQ_AJENAS" ]; then case "$k" in *["$ARNES_ESQ_AJENAS"]*) return 1 ;; esac; fi
  if arnes_en_vocab "$k" "$ARNES_CLAVES_CONTROL"; then ARNES_CTRL="$k"; return 0; fi
  # Las condiciones son CONJUNTIVAS —marcador, estructura, esqueleto, delimitadores—, asi que
  # el orden no cambia QUE lineas son variante; va de la que mas claves descarta a la mas cara.
  # Los bytes descartados del principio (todo lo que no es imprimible ASCII) no impiden
  # reconocer el marcador. Un delimitador de cita en CUALQUIER punto de la clave la saca abajo,
  # y eso incluye el que estuviera delante del marcador, que la definicion no deja saltar.
  r="${k%%["$ARNES_ESQ_LETRAS$ARNES_ESTRUCTURA_ASCII"]*}"
  r="${k:${#r}}"
  case "$r" in
    [-+][$' \t']*)                                        r="${r:2}" ;;
    [0123456789][.\)][$' \t']*)                           r="${r:3}" ;;
    [0123456789][0123456789][.\)][$' \t']*)               r="${r:4}" ;;
    [0123456789][0123456789][0123456789][.\)][$' \t']*)   r="${r:5}" ;;
  esac
  case "$r" in *["$ARNES_ESTRUCTURA_ASCII"]*) return 1 ;; esac
  r="${r//[!"$ARNES_ESQ_LETRAS"]/}"; r="${r,,}"
  case "$ARNES_ESQ_CONTROL" in *"|$r="*) ;; *) return 1 ;; esac
  for d in "${ARNES_DELIM_CITA[@]}"; do
    case "$k" in *"$d"*) return 1 ;; esac
  done
  c="${ARNES_ESQ_CONTROL#*"|$r="}"
  ARNES_CTRL="${c%%|*}"; ARNES_CTRL_VARIANTE=1
  return 0
}

# Una linea ambigua escrita para una PERSONA -> ARNES_AMB_ITEM. La usan la puerta y el
# informe: una sola forma de decirlo. Si la linea lleva algun byte que no es imprimible ASCII
# —todo byte >= 0x80, todo byte de control—, sale ESCAPADA con `%q` bajo `LC_ALL=C`
# (`$'\357\273\277Hallazgos…'`): el motivo ENSEÑA el caracter invisible en vez de
# reproducirlo, y dice lo mismo en cualquier locale. Si no lleva ninguno, entre comillas
# simples y tal cual, que es como mejor se ve un blanco doble.
arnes_ambigua_item() {   # <indice en ARNES_AMB_*>
  local LC_ALL=C i="$1" q que cortada
  cortada="${ARNES_AMB_CORTADA[i]}"
  # La cita llega con ARNES_AMBIGUA_CITA_BYTES CARACTERES del locale de quien la tomo, que son
  # al menos otros tantos bytes: el corte a BYTES se hace aqui, y sale igual en cualquier locale.
  q="${ARNES_AMB_CITA[i]}"
  [ "${#q}" -le "$ARNES_AMBIGUA_CITA_BYTES" ] || { q="${q:0:$ARNES_AMBIGUA_CITA_BYTES}"; cortada=1; }
  case "$q" in
    *[!" $ARNES_ESQ_LETRAS$ARNES_ESTRUCTURA_ASCII"]*) printf -v q '%q' "$q" ;;
    *) q="'$q'" ;;
  esac
  [ "$cortada" = 0 ] || q+='...'
  if [ "${ARNES_AMB_VARIANTE[i]}" = 1 ]; then
    que="variante de '${ARNES_AMB_CLAVE[i]}:', que la maquina NO lee como esa clave"
    [ "${ARNES_AMB_VECES[i]}" -le 1 ] || que+=", y la clave se declara ${ARNES_AMB_VECES[i]} veces"
  else
    que="'${ARNES_AMB_CLAVE[i]}:' declarada ${ARNES_AMB_VECES[i]} veces en la cabecera"
  fi
  ARNES_AMB_ITEM="linea ${ARNES_AMB_N[i]}: $q ($que)"
}

# El motivo de la puerta: las primeras ARNES_AMBIGUA_MOTIVO_LINEAS lineas ambiguas y cuantas
# quedan -> ARNES_AMBIGUA_MOTIVO.
arnes_ambigua_motivo() {
  local i n=${#ARNES_AMB_N[@]}
  ARNES_AMBIGUA_MOTIVO=''
  for ((i = 0; i < n && i < ARNES_AMBIGUA_MOTIVO_LINEAS; i++)); do
    arnes_ambigua_item "$i"
    ARNES_AMBIGUA_MOTIVO+="${ARNES_AMBIGUA_MOTIVO:+; }$ARNES_AMB_ITEM"
  done
  [ "$n" -le "$ARNES_AMBIGUA_MOTIVO_LINEAS" ] ||
    ARNES_AMBIGUA_MOTIVO+="; y $((n - ARNES_AMBIGUA_MOTIVO_LINEAS)) linea(s) ambigua(s) mas (tools/arnes-lectura.sh las nombra todas)"
}

# TECHO DE `Hallazgos abiertos:` (REQ-031 CA-A13/CA-A15, SEC-113): 16 384 BYTES del valor crudo.
# Numero de CONTRATO, anunciado en requirements/README.md § «Clases de hallazgo»; se sube con la
# medicion, nunca se baja (mayor valor real medido al fijarlo: 6 672 bytes). Vive AQUI porque se
# comprueba AQUI, antes de normalizar, y la puerta lo lee de este mismo nombre: un solo numero.
ARNES_HALL_TECHO_BYTES=16384

# Longitud en BYTES de una cadena, sin procesos: `${#v}` cuenta caracteres en un locale UTF-8.
# El `local` devuelve el locale al salir, asi que nada de lo que sigue cambia de lectura.
_arnes_bytes() { local LC_ALL=C; ARNES_BYTES=${#1}; }

arnes_campos_normaliza() {   # <qa> <seg> <sens> <hall> <rigor> -> ARNES_QA/SEG/SENS/HALL/RIGOR
  arnes_norm_campo "$1"; arnes_veredicto "$ARNES_CAMPO"; ARNES_QA="$ARNES_VEREDICTO"
  arnes_norm_campo "$2"; arnes_veredicto "$ARNES_CAMPO"; ARNES_SEG="$ARNES_VEREDICTO"
  arnes_norm_campo "$3"; ARNES_SENS="$ARNES_CAMPO"
  # EL TECHO SE MIDE ANTES DE NORMALIZAR (CA-A15). `arnes_norm_campo` es cuadratico en la longitud
  # del valor (`${v// /}` en UTF-8): medido, 255 371 bytes -> 67,0 s, y el cliente mata el hook a
  # los 60 s sin decision. Por encima del techo el valor NO se normaliza, NO se recorta y NO queda
  # vacio: ARNES_HALL lleva un marcador que no es ninguna ausencia legitima ni ninguna lista, para
  # que ningun lector —la puerta, el bloque derivado— lo lea como «sin hallazgos». La puerta
  # deniega por tamaño antes de mirarlo (guard-completado, CA-A13). Por debajo, lo de siempre.
  _arnes_bytes "$4"; ARNES_HALL_BYTES=$ARNES_BYTES
  if [ "$ARNES_HALL_BYTES" -gt "$ARNES_HALL_TECHO_BYTES" ]; then
    ARNES_HALL="(no medido: $ARNES_HALL_BYTES bytes, techo $ARNES_HALL_TECHO_BYTES)"
  else
    arnes_norm_campo "$4"; ARNES_HALL="$ARNES_CAMPO"
  fi
  arnes_norm_campo "$5"
  # Los niveles simples ya quedaron normalizados arriba; sólo la evidencia
  # parentética necesita el veredicto común. Así el camino habitual no paga
  # una segunda desenvuelta por cada cabecera leída.
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

# Campo crudo anterior para distinguir una firma de una edición de prosa.
# Se consulta sólo al juzgar el orden; no agrega otra lectura al cierre normal.
arnes_seguridad_cabecera() {   # <documento> -> ARNES_SEG_CABECERA
  local l ARNES_CITA=0 ARNES_CR=0 ARNES_CR_LINEA=''
  local ARNES_LINEA ARNES_CLAVE ARNES_VALOR ARNES_CLAVE_DECORADA
  ARNES_SEG_CABECERA=''
  while IFS= read -r l; do
    case "$l" in '## '*) break ;; esac
    arnes_campo_linea "$l" || continue
    [ "$ARNES_CLAVE" != 'Seguridad' ] || ARNES_SEG_CABECERA="$ARNES_VALOR"
  done <<< "$1"
}

arnes_campos_req() {   # <texto en disco> <texto entrante>
  ARNES_QA=''; ARNES_SEG=''; ARNES_SENS=''; ARNES_HALL=''; ARNES_RIGOR=''
  ARNES_QA_CRUDO=''; ARNES_SEG_CRUDO=''; ARNES_HALL_CRUDO=''; ARNES_CITA_ABIERTA=0
  ARNES_CR_INTERIOR=0; ARNES_CR_INTERIOR_LINEA=''
  # El CR interior NO se reinicia por texto, a diferencia del rango: un CR en CUALQUIERA
  # de las dos cabeceras que esta funcion lee deja lo que se leyo sin medir, y da igual en
  # cual estaba.
  ARNES_CR=0; ARNES_CR_LINEA=''
  # `Hallazgos abiertos:` REPETIDA en una misma cabecera (REQ-031 CA-A12, SEC-112): para LEER,
  # las demas claves toman la ultima aparicion (regla que REQ-016 conservo), y asi un
  # `contrato` escrito en una linea anterior no se leia y el cierre pasaba. Aqui solo se CUENTA
  # y se publica —por texto, porque disco y fragmento son dos cabeceras—; decide la puerta.
  # (Al CERRAR, cualquier clave de control repetida deja la cabecera ambigua: abajo, REQ-023.)
  ARNES_HALL_N=0; ARNES_HALL_LINEAS=''
  # CABECERA AMBIGUA (REQ-023, ADR-014; la frontera, en `_arnes_clave_control`). En ESTE
  # recorrido y no en otro: la clave ya la ha normalizado el lector sobre la linea SIN citas, y
  # una pasada mas multiplicaria un coste que ya existe (SEC-115). Se reinicia POR TEXTO y queda
  # publicada la del ULTIMO texto no vacio, que es la cabecera resultante cuando hay documento
  # (el `Write`, o el documento reconstruido de un `Edit`); la puerta solo la usa entonces.
  #   ARNES_AMBIGUA=1        una variante, o una clave de control declarada mas de una vez,
  #                          salvo que la unica ambiguedad sea la repeticion exacta que ya
  #                          cuenta y decide REQ-031 CA-A12 (`n_h`): esa conserva su motivo.
  #   ARNES_AMB_*            TODAS las lineas ambiguas —tambien esa—, para citarlas.
  #   ARNES_ESTADO_OTROS     los valores CRUDOS de los `Estado` que NO gobiernan (variantes y
  #                          declaraciones tras la primera): la puerta los normaliza solo si la
  #                          cabecera es ambigua, para saber si hay intento de cierre.
  local texto l n_l n_h lin_h i n_rep k_rep est_visto
  local -a c_n=() c_k=() c_v=() c_c=() c_x=()
  local -A c_cnt=()
  ARNES_AMBIGUA=0; ARNES_AMB_N=(); ARNES_AMB_CLAVE=(); ARNES_AMB_VARIANTE=(); ARNES_AMB_CITA=()
  ARNES_AMB_CORTADA=(); ARNES_AMB_VECES=(); ARNES_ESTADO_OTROS=()
  for texto in "$1" "$2"; do
    [ -n "$texto" ] || continue
    # El rango de comentario CRUZA lineas, asi que su estado se reinicia por texto: el
    # fragmento entrante y el documento en disco son dos cabeceras, no una.
    ARNES_CITA=0; n_l=0; n_h=0; lin_h=''
    c_n=(); c_k=(); c_v=(); c_c=(); c_x=(); c_cnt=(); n_rep=0; k_rep=''; est_visto=0
    ARNES_ESTADO_OTROS=()
    while IFS= read -r l; do
      n_l=$((n_l+1))
      # LOS CAMPOS VALEN SOLO EN LA CABECERA: antes del primer `## `. Medido: una linea
      # `Seguridad: aprobado (A-009, 2026-09-02)` dentro de `## Historial de cambios` se
      # leia como EL veredicto y cerraba un REQ critico cuya cabecera decia `pendiente`.
      # Es la familia de `**si**`: la maquina lee algo distinto de lo que la cabecera
      # declara. La regla es estructural --lo que dice la plantilla-- y no depende del
      # nombre de ninguna seccion, que seria mapeo del proyecto.
      case "$l" in '## '*) break ;; esac
      arnes_campo_linea "$l" || continue
      if _arnes_clave_control; then
        # La cita, SOLO de las lineas de control: sus primeros caracteres y si sigue algo detras
        # (el corte a bytes, igual en cualquier locale, lo hace `arnes_ambigua_item`).
        c_n+=("$n_l"); c_k+=("$ARNES_CTRL"); c_v+=("$ARNES_CTRL_VARIANTE")
        c_c+=("${l:0:$ARNES_AMBIGUA_CITA_BYTES}"); c_x+=("${l:$ARNES_AMBIGUA_CITA_BYTES:1}")
        c_cnt[$ARNES_CTRL]=$(( ${c_cnt[$ARNES_CTRL]:-0} + 1 ))
        [ "${c_cnt[$ARNES_CTRL]}" -ne 2 ] || { n_rep=$((n_rep+1)); k_rep="$ARNES_CTRL"; }
        if [ "$ARNES_CTRL" = "$ARNES_CLAVE_ESTADO" ]; then
          # El que gobierna es la PRIMERA declaracion exacta, y ese ya lo normaliza
          # `arnes_estado_cabecera`: aqui no se normaliza ninguno (REQ-023 CA-09 (iv)).
          if [ "$ARNES_CTRL_VARIANTE" = 1 ] || [ "$est_visto" = 1 ]; then
            ARNES_ESTADO_OTROS+=("$ARNES_VALOR")
          else
            est_visto=1
          fi
        fi
      fi
      case "$ARNES_CLAVE" in
        'QA')                   ARNES_QA="$ARNES_VALOR" ;;
        'Seguridad')            ARNES_SEG="$ARNES_VALOR" ;;
        'Sensible a seguridad') ARNES_SENS="$ARNES_VALOR" ;;
        'Hallazgos abiertos')   ARNES_HALL="$ARNES_VALOR"
                                n_h=$((n_h+1)); lin_h+="${lin_h:+; }linea $n_l: '${l:0:60}'" ;;
        'Rigor')                ARNES_RIGOR="$ARNES_VALOR" ;;
      esac
    done <<< "$texto"
    [ "$n_h" -le "$ARNES_HALL_N" ] || { ARNES_HALL_N=$n_h; ARNES_HALL_LINEAS="$lin_h"; }
    # El fin de la cabecera con un rango ABIERTO: la cabecera no se puede medir. Se
    # publica; aqui no se decide nada. (Desde REQ-023 CA-13 ninguna puerta lee esta
    # publicacion: la leia solo la via de fragmentos, que ya no existe; `guard-completado`
    # juzga el rango abierto sobre el documento resultante, con `ARNES_ESTADO_CITA`.)
    [ "$ARNES_CITA" -eq 0 ] || ARNES_CITA_ABIERTA=1
    # La cabecera ambigua de ESTE texto. Solo se publica; decide la puerta.
    ARNES_AMBIGUA=0; ARNES_AMB_N=(); ARNES_AMB_CLAVE=(); ARNES_AMB_VARIANTE=(); ARNES_AMB_CITA=()
    ARNES_AMB_CORTADA=(); ARNES_AMB_VECES=()
    for ((i = 0; i < ${#c_n[@]}; i++)); do
      [ "${c_v[i]}" = 1 ] || [ "${c_cnt[${c_k[i]}]}" -gt 1 ] || continue
      [ "${c_v[i]}" = 0 ] || ARNES_AMBIGUA=1
      ARNES_AMB_N+=("${c_n[i]}"); ARNES_AMB_CLAVE+=("${c_k[i]}"); ARNES_AMB_VARIANTE+=("${c_v[i]}")
      ARNES_AMB_CITA+=("${c_c[i]}"); ARNES_AMB_VECES+=("${c_cnt[${c_k[i]}]}")
      if [ -n "${c_x[i]}" ]; then ARNES_AMB_CORTADA+=(1); else ARNES_AMB_CORTADA+=(0); fi
    done
    # Sin variantes, una repeticion deja la cabecera ambigua salvo que sea UNA sola clave y
    # EXACTAMENTE las lineas que cuenta REQ-031 CA-A12 (`n_h`, las canonicas de esa clave): esa
    # repeticion ya la deniega su puerta con su motivo, y este REQ no emite el suyo.
    if [ "$n_rep" -gt 1 ] || { [ "$n_rep" -eq 1 ] && [ "${c_cnt[$k_rep]}" -ne "$n_h" ]; }; then
      ARNES_AMBIGUA=1
    fi
  done
  # Igual que el rango abierto: se PUBLICA, y desde REQ-023 CA-13 ninguna puerta lo lee (la
  # puerta juzga el CR interior sobre el documento resultante, con `ARNES_ESTADO_CR`).
  ARNES_CR_INTERIOR="$ARNES_CR"; ARNES_CR_INTERIOR_LINEA="$ARNES_CR_LINEA"
  # El valor CRUDO se conserva ANTES de normalizar: la fecha del veredicto vive en el
  # parentesis de evidencia, que la normalizacion retira a proposito (el parentesis es
  # evidencia, no veredicto). Se lee del crudo con el MISMO lector, no con un segundo
  # normalizador -- dos transcripciones de la misma regla se desfasan.
  # `Hallazgos abiertos:` tambien: la normalizacion retira TODOS los blancos, y la gramatica
  # del campo (REQ-031 CA-A01) prohibe blancos DENTRO de un identificador —`SEC-A y SEC-B
  # (instrumento)` son dos hallazgos con una sola clase, y normalizado se lee `sec-aysec-b`,
  # un identificador valido—. Solo esa regla mira el crudo; todo lo demas, el normalizado.
  ARNES_QA_CRUDO="$ARNES_QA"; ARNES_SEG_CRUDO="$ARNES_SEG"; ARNES_HALL_CRUDO="$ARNES_HALL"
  arnes_campos_normaliza "$ARNES_QA" "$ARNES_SEG" "$ARNES_SENS" "$ARNES_HALL" "$ARNES_RIGOR"
}

# `Estado:` de la CABECERA de un documento, normalizado y sin su parentesis de
# evidencia. La PRIMERA aparicion manda, como en campos-req.awk: la cabecera declara
# el estado una vez. Existe para juzgar la transicion sobre el documento RESULTANTE,
# no sobre el fragmento editado (ver guard-completado.sh). Es la regla de LECTURA y no
# cambia: si la cabecera resultante declara `Estado` mas de una vez, o una variante suya,
# y alguna de esas lineas dice el estado terminal, la puerta DENIEGA por cabecera ambigua
# (REQ-023; lo publica `arnes_campos_req`) en vez de dejar que gane la primera.
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
        case "$ARNES_CLAVE" in 'Estado')
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
      case "$ARNES_CLAVE" in 'Estado')
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
  # EL NIVEL HEREDADO: el que este REQ tendria si su `Rigor:` no se pudiera leer.
  # Es el comportamiento anterior a que los niveles existieran, y se calcula UNA
  # vez porque ahora tiene dos usos: es el valor por defecto (no hay nada
  # declarado, o lo declarado no se entiende) y es el PISO del matiz (abajo).
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
    # Nada declarado -> se juzga EXACTAMENTE como antes de existir los niveles.
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
