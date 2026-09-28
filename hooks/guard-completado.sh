#!/usr/bin/env bash
# guard-completado.sh — Invariantes A2, A3 y anti-deriva sobre la transición de un REQ a `completado`.
#
#   A2: no completar con aprobaciones pendientes en PENDING_APPROVAL.md.
#   A3: no completar si alguna quality gate falla.
#   Veredictos (anti-deriva): no completar sin `QA: aprobado`, ni un REQ marcado
#       `Sensible a seguridad: sí` sin `Seguridad: aprobado`. Así ningún REQ se cierra con la
#       validación o la auditoría pendientes/abiertas; el write-back del hallazgo al
#       requerimiento es lo que lleva esos veredictos a "aprobado" (ver AGENTS.md §9).
#
# Se dispara cuando una edición dentro de `requirements/` deja el `Estado:` del REQ en el
# valor terminal (`completado`). Si la transición no ocurre, el hook no hace nada.
set -uo pipefail
# Directorio del propio script por expansión de parámetro. La forma habitual
# —`$(cd "$(dirname ...)" && pwd)"`— son DOS forks anidados, y en esta
# plataforma un fork cuesta más que ejecutar el binario que va dentro.
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

# --- Clase del hallazgo: no todo hallazgo bloquea -----------------------------------
# Un defecto del propio arnes (un lector de umbral, un guardian, una prueba) no puede
# impedir cerrar una funcion de negocio. Sin esta distincion, un hallazgo de instrumento
# mantiene un REQ abierto mientras QA encuentra variantes suyas. Un hallazgo SIN clase
# deniega: la puerta no puede saber si bloquea o no, y un "no se" que deja pasar es un
# "si" disfrazado.
#
# QUE LEE LA PUERTA (REQ-031 CA-A11.4): el valor de LA linea de cabecera cuya clave reconoce
# el lector, que tiene que ser UNA sola (CA-A12). Lo que no alcanza a ver no lo lee
# (ejemplos no exhaustivos: una continuacion sin clave, una clave con un caracter invisible o
# un homoglifo —SEC-047/SEC-078—, un comentario HTML de la cabecera, una linea bajo el primer
# `## `): ahi no hay promesa, y el README lo dice.
#
# Se llama SOLO en la transicion a `completado` (reabrir no pasa por aqui, CA-A08). Usa `$rel`
# y lo que publica `arnes_campos_req`. "Permitir" es `return 0`; `arnes_deny` termina.
arnes_clase_hallazgo() {
  # BYTES, NO CARACTERES, y por dos razones medidas (REQ-031 CA-A13/CA-A14, SEC-113): el techo
  # se cuenta en bytes, y en un locale UTF-8 cada `${s:i:1}` recorre la cadena desde el
  # principio, asi que leer un valor largo era CUADRATICO (60 006 bytes: 81 s, y el cliente
  # mata el hook a los 60 s — un hook muerto no deniega). `local` devuelve el locale al salir.
  local LC_ALL=C
  local techo=16384 hall crudo_h n_hall n_crudo est prof e_ini idh id_malo clase err err_ini \
        sin_clase clase_mala clase_mala_v bloq bloq_v ci cj c p t0 trozo id_crudo visto blanco \
        pend noasc id_txt frag_h elem_h

  # CA-A12 (SEC-112): la clave REPETIDA no se resuelve eligiendo una. Para el resto de claves
  # el lector deja ganar a la ultima; aqui eso escondia un `contrato` escrito mas arriba. Se
  # juzga ANTES que el valor, sea cual sea el de cada linea.
  if [ "${ARNES_HALL_N:-0}" -gt 1 ]; then
    arnes_deny "ARNES: no se puede completar '$rel': la cabecera declara 'Hallazgos abiertos:' $ARNES_HALL_N veces (${ARNES_HALL_LINEAS}), y la puerta no elige una: ni la primera ni la ultima, y no las fusiona. Deja UNA sola linea 'Hallazgos abiertos:' en la cabecera y conserva en ella todos los hallazgos, separados por comas (requirements/README.md, seccion 'Clases de hallazgo'). La puerta no reescribe el archivo."
  fi

  # CA-A13 (SEC-113): techo de tamaño, medido en BYTES sobre el valor tal como se escribio
  # (tras los dos puntos, antes de normalizar). Por encima no se interpreta y deniega SI EL HOOK
  # ALCANZA A MEDIRLO dentro del limite del cliente (60 s): `arnes_norm_campo` corre ANTES de
  # este techo y es cuadratico, y con valores del orden de 240 KB o mas el hook muere sin
  # decidir, y un hook muerto no deniega (residuo en docs/PENDIENTES.md; SEC-114). Numero de
  # CONTRATO, anunciado en requirements/README.md (mayor valor real medido al fijarlo:
  # 6 672 bytes); se sube con la medicion, nunca se baja.
  crudo_h="${ARNES_HALL_CRUDO:-}"; n_crudo=${#crudo_h}
  if [ "$n_crudo" -gt "$techo" ]; then
    arnes_deny "ARNES: no se puede completar '$rel': el valor de 'Hallazgos abiertos:' mide $n_crudo bytes (contados en bytes, lo escrito tras los dos puntos y antes de normalizar) y el techo es $techo bytes, asi que no se interpreta: una puerta que no puede medir no deja pasar. Acorta el campo: la evidencia larga va al registro del hallazgo (docs/qa/, docs/seguridad/) y en el parentesis queda la referencia (requirements/README.md, seccion 'Clases de hallazgo')."
  fi

  hall="$ARNES_HALL"
  case "$hall" in
    ''|ninguno|'(ninguno)'|n/a|na|-|'(-)') return 0 ;;
  esac

  # GRAMATICA CERRADA (REQ-031 CA-A01, ADR-013; sede unica de la sintaxis:
  # requirements/README.md, seccion 'Clases de hallazgo'). La lista es uno o mas elementos
  # separados por comas DE FUERA de todo parentesis, y cada elemento es, exactamente:
  # identificador (letras ASCII, digitos, '-') + '(' clase [',' evidencia] ')' y NADA detras
  # salvo la coma separadora o el fin del campo.
  #
  # Por que cerrada: hasta 1.34.0 se partia solo por comas y la clase se tomaba del PRIMER
  # parentesis del elemento; lo que seguia a ese ')' no se leia. Medido
  # (evaluacion-2026-09-27): `SEC-A (instrumento) · SEC-B (usuario/dinero)` y
  # `SEC-A (instrumento); SEC-B (contrato)` CERRABAN con un bloqueante abierto, porque con `·`
  # o `;` la lista entera era UN elemento. Aceptar «cualquier separador» no es una
  # especificacion; lo que la puerta no sabe leer, lo DICE y no deja cerrar.
  #
  # La lista se valida ENTERA antes de juzgar clases, en UNA pasada y sin procesos: asi la
  # decision y el tipo de motivo no dependen del orden de los elementos. Prioridad del motivo:
  # no interpretable > sin clase / clase no valida > clase que bloquea. La evidencia puede
  # llevar comas, ';', '·' y parentesis anidados equilibrados, y NO declara nada (misma regla
  # que el parentesis de un veredicto, `QA: aprobado (medido el 3/9)`).
  #
  # EL ACCESO VA POR TROZOS DE 64 BYTES (CA-A14): leer `${s:i:1}` sobre el valor entero cuesta,
  # incluso con LC_ALL=C, lo que mide la cadena (bash la mide en cada acceso) — medido: doblar la
  # longitud cuadruplicaba el tiempo tambien en C. Sobre un trozo de 64 bytes, el acceso cuesta lo
  # mismo sea cual sea la posicion; lo unico que queda proporcional a la longitud es sacar cada
  # trozo (una medida de la cadena en C por cada 64 bytes), acotado ademas por el techo.
  # Un caracter multibyte (`·`, `—`, una tilde) se ve como varios bytes >= 0x80: ninguno es del
  # alfabeto ni de la sintaxis, asi que su decision no cambia respecto a leerlo entero.
  n_hall=${#hall}; est=0; prof=0; e_ini=0; idh=''; id_malo=''; clase=''
  err=''; err_ini=0; sin_clase=''; clase_mala=''; clase_mala_v=''; bloq=''; bloq_v=''
  t0=-64; trozo=''
  for ((ci = 0; ci <= n_hall; ci++)); do
    (( ci - t0 < 64 )) || { t0=$ci; trozo="${hall:ci:64}"; }
    c="${trozo:ci-t0:1}"   # '' en ci = n_hall: centinela del fin del campo
    if [ "$est" -eq 3 ]; then
      # Tras el ')' que equilibra al de apertura: solo la coma o el fin.
      case "$c" in
        ''|,) ;;
        ')') err="sobra un ')' detras del parentesis del hallazgo"; err_ini=$ci ;;
        '(') err="el elemento lleva dos parentesis; cada hallazgo lleva UNO, con su clase" ; err_ini=$ci ;;
        *)   err="hay texto detras del parentesis del hallazgo (un separador que no es la coma, una nota u otro hallazgo); tras el parentesis solo cabe la coma o el fin del campo"; err_ini=$ci ;;
      esac
    elif [ "$est" -ge 1 ]; then
      # Dentro del parentesis: est 1 = clase (hasta la primera coma de profundidad 1),
      # est 2 = evidencia (no se lee).
      case "$c" in
        '')  err="un parentesis abierto no se cierra"; err_ini=$e_ini ;;
        '(') prof=$((prof+1)); [ "$est" -eq 1 ] && clase+="$c"; continue ;;
        ')') prof=$((prof-1))
             if [ "$prof" -eq 0 ]; then est=3; else [ "$est" -eq 1 ] && clase+="$c"; fi
             continue ;;
        ',') if [ "$est" -eq 1 ] && [ "$prof" -eq 1 ]; then est=2; elif [ "$est" -eq 1 ]; then clase+="$c"; fi
             continue ;;
        *)   [ "$est" -eq 1 ] && clase+="$c"; continue ;;
      esac
    else
      # Identificador. Un elemento SIN parentesis sigue siendo «hallazgo sin clase»
      # (REQ-007 CA-41: `QA-006 [instrumento]`), no «no interpretable».
      case "$c" in
        '(') if [ -z "$idh" ]; then
               err="el elemento no empieza por un identificador (o mezcla una ausencia como '(ninguno)' con hallazgos)"; err_ini=$e_ini
             elif [ -n "$id_malo" ]; then
               err="el identificador lleva caracteres fuera de letras ASCII, digitos y '-' (el marcado de Markdown de un elemento suelto no se desenvuelve)"; err_ini=$e_ini
             else
               est=1; prof=1; clase=''; continue
             fi ;;
        ''|,) if [ -z "$idh" ]; then
                err="hay un elemento vacio (una coma al principio, al final o dos seguidas)"; err_ini=$e_ini
              else
                [ -n "$sin_clase" ] || sin_clase="$idh"
              fi ;;
        [abcdefghijklmnopqrstuvwxyz0123456789-]) idh+="$c"; continue ;;   # ya en minusculas
        *)   id_malo=1; idh+="$c"; continue ;;
      esac
    fi
    [ -z "$err" ] || break
    # Fin de un elemento bien formado: se anota su clase, sin decidir todavia.
    if [ "$est" -eq 3 ]; then
      case "$clase" in
        instrumento) ;;   # no bloquea: va a deuda tecnica con dueno
        usuario/dinero|contrato) [ -n "$bloq" ] || { bloq="$idh"; bloq_v="$clase"; } ;;
        '') [ -n "$sin_clase" ] || sin_clase="$idh" ;;
        *)  [ -n "$clase_mala" ] || { clase_mala="$idh"; clase_mala_v="$clase"; } ;;
      esac
    fi
    est=0; prof=0; e_ini=$((ci+1)); idh=''; id_malo=''; clase=''
  done
  # Dos reglas del identificador necesitan el valor TAL COMO SE ESCRIBIO, porque la
  # normalizacion borra su huella: (a) blancos DENTRO del identificador (los retira todos:
  # `SEC-A y SEC-B` se leeria `sec-aysec-b`) y (b) letras fuera de ASCII (pliega las tildes:
  # `SÉC-A` se leeria `sec-a`; en bytes, cualquier byte >= 0x80). Una pasada mas sobre el
  # crudo, solo si la estructura ya se leyo entera; mira solo lo que va ANTES del primer '(' de
  # cada elemento, fuera de parentesis. Un blanco cuenta como interno solo entre dos caracteres
  # del alfabeto del identificador (un blanco junto a un marcado envolvente, `** SEC-A`, no).
  id_crudo=''
  if [ -z "$err" ]; then
    # `pend`/`noasc` se comprometen SOLO al llegar al '(' del elemento: un elemento sin
    # parentesis (`SEC-A y SEC-B`) sigue siendo «sin clase», como arriba.
    prof=0; est=0; visto=''; blanco=''; pend=''; noasc=''; id_txt=''; t0=-64; trozo=''
    for ((ci = 0; ci < n_crudo; ci++)); do
      (( ci - t0 < 64 )) || { t0=$ci; trozo="${crudo_h:ci:64}"; }
      c="${trozo:ci-t0:1}"
      case "$c" in
        '(') if [ "$prof" -eq 0 ] && [ "$est" -eq 0 ]; then
               [ -z "$pend$noasc" ] || { id_crudo=1; break; }
               est=1
             fi
             prof=$((prof+1)) ;;
        ')') [ "$prof" -gt 0 ] && prof=$((prof-1)) ;;
        ,)   [ "$prof" -eq 0 ] && { est=0; visto=''; blanco=''; pend=''; noasc=''; id_txt=''; } ;;
        ' '|$'\t') [ "$est" -eq 0 ] && { [ -z "$visto" ] || blanco=1; id_txt+="$c"; } ;;
        # Alfabeto escrito entero y no como rango: `[a-z]` depende del locale.
        [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-])
             if [ "$est" -eq 0 ]; then
               [ -z "$blanco" ] || pend=1
               visto=1; id_txt+="$c"
             fi ;;
        *)   if [ "$est" -eq 0 ]; then
               case "$c" in [[:ascii:]]) ;; *) noasc=1 ;; esac
               visto=''; blanco=''; id_txt+="$c"
             fi ;;
      esac
    done
    if [ -n "$id_crudo" ]; then
      id_txt="${id_txt#"${id_txt%%[![:blank:]]*}"}"; id_txt="${id_txt%"${id_txt##*[![:blank:]]}"}"
      if [ -n "$pend" ]; then
        err="el identificador '${id_txt,,}' lleva blancos dentro: si son dos hallazgos, cada uno lleva su propio parentesis con su clase"
      else
        err="el identificador '${id_txt,,}' lleva letras fuera de ASCII (una tilde o una letra de otro alfabeto)"
      fi
      frag_h="${id_txt,,}"; frag_h="${frag_h//[[:blank:]]/}"; elem_h="$frag_h"
    fi
  else
    # El fragmento no interpretado llega hasta el fin de su elemento (la siguiente coma de
    # fuera de parentesis). Solo corre una vez, ante el error: no es un recorrido por elemento.
    p=0; t0=-64; trozo=''
    for ((cj = ci; cj < n_hall; cj++)); do
      (( cj - t0 < 64 )) || { t0=$cj; trozo="${hall:cj:64}"; }
      case "${trozo:cj-t0:1}" in
        '(') p=$((p+1)) ;;
        ')') [ "$p" -gt 0 ] && p=$((p-1)) ;;
        ,)   [ "$p" -eq 0 ] && [ "$cj" -gt "$err_ini" ] && break ;;
      esac
    done
    frag_h="${hall:err_ini:cj-err_ini}"; elem_h="${hall:e_ini:cj-e_ini}"
    [ -n "$frag_h" ] || { frag_h="$hall"; elem_h="$hall"; }
  fi
  if [ -n "$err" ]; then
    arnes_deny "ARNES: no se puede completar '$rel': la lista de 'Hallazgos abiertos:' no se puede interpretar, y una lista que la puerta no sabe leer no deja cerrar (podria esconder un hallazgo que bloquea). En el elemento '$elem_h' no se interpreta '$frag_h' (leido sin blancos y en minusculas): $err. Los hallazgos se separan SOLO con comas y cada uno lleva su propio parentesis con su clase: 'ID (clase)'. Conserva la evidencia DENTRO del parentesis del hallazgo, tras la clase y una coma: 'ID (clase, evidencia)' —p. ej. 'QA-006 (instrumento, REQ-007)'—. La puerta no reescribe el campo. Sintaxis: requirements/README.md, seccion 'Clases de hallazgo'."
  fi
  if [ -n "$sin_clase" ]; then
    arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$sin_clase' no declara su clase, y un hallazgo sin clase no cuenta como hallazgo. Clasificalo como 'usuario/dinero', 'contrato' o 'instrumento' (requirements/README.md, seccion 'Clases de hallazgo')."
  fi
  if [ -n "$clase_mala" ]; then
    arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$clase_mala' declara '$clase_mala_v', que no es una clase valida, asi que no declara su clase y un hallazgo sin clase no cuenta como hallazgo. Validas: 'usuario/dinero', 'contrato', 'instrumento'. La clase va la PRIMERA dentro del parentesis; la evidencia va detras, tras una coma y DENTRO del mismo parentesis (dueno, forzador, vencimiento)."
  fi
  if [ -n "$bloq" ]; then
    arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$bloq' es de clase '$bloq_v' y bloquea el cierre. Resuelvelo — o reclasificalo si en realidad no afecta a lo que alguien ve, decide o cobra ni a lo que el REQ afirma (requirements/README.md, seccion 'Clases de hallazgo')."
  fi
  return 0
}

# ⚠️ REGLA CRÍTICA DE ESTA FUNCIÓN: "permitir" se dice con `return 0`, NUNCA con
# `exit 0`. Un `exit` aquí mataría el proceso entero y el otro guardián no llegaría
# a correr — fallo abierto y en silencio, que es justo la familia de defecto que
# este arnés existe para impedir. `arnes_deny` sí termina el proceso, y eso es
# correcto: una denegación es final y no hay nada más que juzgar.
arnes_guard_completado() {
  local tool fp bash_cmd req_dir estado_done pending_rel rel d escrituras nuevo
  local disk qa seg sens rigor hall h id clase pending abiertas tmp cmd out rc disk_medible acc c prof ci
  local -a piezas=()
  local modo resultante reconstruido np k old new ra done_norm est_antes est_despues
  local cita_desp est_citado cr_desp cr_linea
  local seg_antes

  # El análisis del input y del manifiesto es COMPARTIDO y memorizado: si
  # `guard-codigo` ya corrió en este mismo proceso, aquí no se vuelve a pagar.
  arnes_parse_input
  # SEC-004: una escritura a traves de un enlace simbolico no se juzga, se deniega.
  arnes_deny_enlace
  tool="$ARNES_TOOL"; fp="$ARNES_FP"; bash_cmd="$ARNES_CMD"

  case "$tool" in
    Bash)
      # Salida temprana barata: la inmensa mayoría de los comandos son lecturas y
      # no escriben nada. Se descartan aquí sin haber tocado el manifiesto.
      [ -n "$bash_cmd" ] || return 0
      # Igual que en `guard-codigo`: un `$ARNES_RC_EXCESO` no es "no escribe nada".
      # Aqui la denegacion alcanza a TODOS los agentes, porque la regla que este
      # guardian aplica tambien alcanza a todos: nadie cierra un REQ desde la shell.
      escrituras="$(arnes_bash_escrituras "$bash_cmd")"; rc=$?
      if [ "$rc" -eq "$ARNES_RC_EXCESO" ]; then
        arnes_parse_manifest
        # Igual que en `guard-codigo`: el techo se resuelve aqui porque el detector corrio
        # en un subshell y su memorizacion no vuelve (REQ-001, QA-016).
        arnes_techo_bash
        arnes_deny "ARNES: el cuerpo sin citar de un heredoc (o el texto del comando fuera de los heredocs) es demasiado grande para analizarlo con garantia; no se analizo y no se permite. Una puerta que no puede medir no deja pasar (AGENTS.md 1): sin analisis no se puede saber si el comando toca '$ARNES_REQ_DIR'. El presupuesto de analisis vigente es de $ARNES_TECHO bytes y este comando lo supera. Salidas: heredoc CITADO (<<'EOF'), un archivo de script, o partir el comando en trozos por debajo de $ARNES_TECHO bytes. El techo se puede SUBIR en .arnes/config.json con 'limites.bash_max_analisis' (bytes), hasta un maximo de $ARNES_BASH_MAX_MANIFIESTO bytes: por encima el analisis dejaria de responder antes de que el hook muera, y un hook muerto no deniega."
      fi
      [ -n "$escrituras" ] || return 0 ;;
    Edit|Write|MultiEdit)
      [ -n "$fp" ] || return 0 ;;
    *) return 0 ;;
  esac
  # SEC-005: si el manifiesto existe pero no se puede leer, `requirements_dir` y el estado
  # terminal son desconocidos y esta puerta no puede juzgar nada. No deja pasar.
  arnes_parse_manifest
  # Los destinos ya estan detectados en la via Bash; en Edit/Write la escritura es cierta
  # y la ruta viaja en `ARNES_FP`. La funcion no vuelve a analizar nada.
  arnes_deny_manifiesto_roto "${escrituras:-}"

  req_dir="$ARNES_REQ_DIR"; estado_done="$ARNES_ESTADO_DONE"; pending_rel="$ARNES_PENDING"

  # --- Vía Bash: no se juzga aquí, se DERIVA ---
  # `guard-codigo` ya cubre A1 por esta vía. Lo que quedaba abierto —y estaba
  # declarado como limitación conocida— es el CIERRE de un REQ: un `sed -i` podía
  # cerrarlo sin que ninguna puerta lo evaluara.
  #
  # Aquí NO se reimplementan los veredictos, la cola ni las quality gates: sería la
  # segunda transcripción de la misma regla, y dos transcripciones se desfasan. Se
  # deniega diciendo por dónde hay que pasar.
  #
  # La detección del estado terminal es DELIBERADAMENTE ancha —en cualquier parte
  # del comando, no `estado:` seguido del valor—. Razón medida: la forma más natural
  # de cerrar un REQ por shell es `sed -i 's/en-revision/completado/' REQ-001.md`,
  # que sustituye el VALOR y no escribe nunca la palabra "Estado".
  if [ "$tool" = "Bash" ]; then
    while IFS= read -r d; do
      [ -n "$d" ] || continue
      case "$d" in /dev/*|/tmp/*) continue ;; esac
      case "$d" in
        /*|[A-Za-z]:*) arnes_ruta_relativa "$d" "$ARNES_PROJ"; rel="$ARNES_REL" ;;
        *)             arnes_norm_path "$d"; rel="${ARNES_NORM#./}" ;;
      esac
      case "$rel" in
        "$req_dir"/*)
          if grep -iqE "(^|[^a-zA-Z])${estado_done}([^a-zA-Z]|$)" <<< "$bash_cmd"; then
            arnes_deny "ARNES: este comando escribe en '$rel' y menciona '$estado_done'. La transicion de estado de un REQ no puede juzgarse desde Bash: las puertas A2/A3 necesitan el contenido resultante (veredictos de QA y Seguridad, cola de $pending_rel y quality gates). Hazlo con Edit/Write para que este mismo hook lo evalue (AGENTS.md 6)."
          fi ;;
      esac
    done <<< "$escrituras"
    return 0
  fi

  # --- Via Edit/Write/MultiEdit ---
  arnes_ruta_relativa "$fp" "$ARNES_PROJ"; rel="$ARNES_REL"
  case "$rel" in
    "$req_dir"/*) ;;          # dentro de requirements/ -> seguimos
    *) return 0 ;;
  esac

  # Lo que entra, por herramienta, en UNA llamada a jq. Piezas separadas por \001 —un
  # byte que ningun Markdown lleva; bash no puede guardar NUL en una variable—:
  #   Write     -> W \001 contenido
  #   Edit      -> E \001 old \001 new \001 replace_all
  #   MultiEdit -> E \001 old1 \001 new1 \001 ra1 \001 old2 \001 new2 \001 ra2 ...
  # PRIMER campo: bandera de bytes de control C0 en el `tool_input` (SEC-001, R-001).
  # El separador `\001` viaja DENTRO del dato que controla quien llama, y un `\001` metido
  # en un `new_string` metia campos de mas: el bucle de tripletas leia como `(old,new,ra)`
  # cosas que no lo eran y EL DOCUMENTO QUE EL HOOK SIMULA DEJABA DE SER EL QUE LA
  # HERRAMIENTA IBA A ESCRIBIR. Con eso se saltaban las cuatro puertas del cierre a la vez.
  # Se elige la salida (b) del criterio —RECHAZAR el input con bytes de control— y no la
  # (a) —pasarlo fuera de banda—: es una comprobacion en la MISMA llamada a jq (cero
  # procesos nuevos), la direccion segura es cerrar, y un REQ legitimo no lleva bytes C0.
  # Se excluyen tabulador (09), salto de linea (0A) y retorno de carro (0D): el Markdown
  # normal —una tabla, un bloque de codigo, un archivo CRLF— los lleva y no puede volverse
  # un falso positivo.
  arnes_jq_str "$ARNES_INPUT" -r '
    (if ([.tool_input | .. | strings] | join("\n") | test("[\\x00-\\x08\\x0b\\x0c\\x0e-\\x1f]"))
     then "!" else "-" end) as $ctl |
    (if   .tool_name == "Write" then ["W", (.tool_input.content // "")]
     elif .tool_name == "Edit"  then ["E", (.tool_input.old_string // ""), (.tool_input.new_string // ""),
                                      (if .tool_input.replace_all == true then "1" else "0" end)]
     elif .tool_name == "MultiEdit" then ["E"] + [.tool_input.edits[]? |
                                      (.old_string // ""), (.new_string // ""),
                                      (if .replace_all == true then "1" else "0" end)]
     else ["W", ""] end) | [$ctl] + . | join("\u0001")'
  piezas=()
  IFS=$'\001' read -r -d '' -a piezas <<< "$ARNES_JQ" || true
  if [ "${piezas[0]:-!}" = "!" ]; then
    arnes_deny "ARNES: no se juzga esta edicion de '$rel': el tool_input trae bytes de control (C0 distintos de tabulador, salto de linea y retorno de carro). El hook trocea las piezas de la edicion con un separador que viaja dentro del propio dato, asi que un byte de control desincroniza la simulacion y el documento que se juzga deja de ser el que se escribiria. Un REQ legitimo no los lleva: quitalos y reintenta. Una puerta que no puede medir no deja pasar (AGENTS.md 1)."
  fi
  modo="${piezas[1]:-W}"

  # El REQ en disco, leido de forma que DICE si no pudo leerse entero (SEC-002, R-001).
  # `read -d ''` se detiene en el primer NUL y devuelve el trozo: un NUL en la primera
  # linea dejaba `disk` vacio, los veredictos se leian de un texto incompleto —y un campo
  # vacio no exige nada—, y ademas el `old_string` no se encontraba, asi que la puerta
  # caia a la via mas laxa. Bastaba una escritura previa en requirements/, que ninguna
  # puerta restringe.
  disk=''; disk_medible=1
  if [ -f "$fp" ]; then
    arnes_lee_archivo "$fp" || disk_medible=0
    disk="$ARNES_TEXTO"
  fi
  if [ "$disk_medible" -eq 0 ]; then
    # No se puede reconstruir el documento resultante ni leer los veredictos que hay en
    # disco. Lo que decide sigue siendo LA TRANSICION: solo se deniega si la edicion trae
    # el estado terminal —la regla ancha de la via Bash, por la misma razon: sustituir el
    # VALOR es la forma mas natural de cerrar un REQ a mano y no escribe «Estado» en ninguna
    # parte—. Una edicion que no lo menciona no queda bloqueada por el byte.
    if grep -iqE "(^|[^a-zA-Z])${estado_done}([^a-zA-Z]|$)" <<< "$ARNES_JQ"; then
      arnes_deny "ARNES: no se puede tocar el estado de '$rel': el archivo en disco no se puede leer entero —un byte NUL lo trunca, o no hay permiso de lectura—, asi que no se pueden leer sus veredictos ni simular el documento resultante, y esta edicion menciona '$estado_done'. Una puerta que no puede medir no deja pasar (AGENTS.md 1). Quita el byte NUL del archivo y reintenta."
    fi
    return 0
  fi

  # --- El documento RESULTANTE, no los fragmentos ----------------------------------
  # FALLO EN ABIERTO medido en 1.30.1: un MultiEdit que cerraba el REQ y aprobaba SOLO
  # la linea del historial pasaba. Se concatenaban los `new_string`, y el `## ` que
  # separa cabecera de historia se quedaba en el disco: el fragmento del historial se
  # leia como cabecera. La cabecera existe en el DOCUMENTO, no en los fragmentos. Asi
  # que se aplica cada edicion al texto en disco —lo mismo que hara la herramienta— y
  # los campos se leen de lo que quedara escrito.
  #
  # Si algun `old_string` no esta en el texto, la herramienta fallara entera y no
  # escribira nada: entonces se leen los fragmentos como hasta ahora (y el banco, que
  # fabrica ediciones con `old_string:"x"`, sigue midiendo lo mismo).
  # `Write` trae el documento COMPLETO: es su propio resultante, y por eso la transicion
  # tambien se lee de su cabecera. Medido con 1.30.2: un `Write` cuyo CUERPO citaba
  # `Estado: completado (...)` dentro de un criterio fue denegado, porque el `grep` miraba
  # todo el contenido y no la cabecera. Los VEREDICTOS de un `Write` se siguen leyendo con
  # la precedencia de siempre (entrante sobre disco), que es la lectura estricta: un `Write`
  # que borrara la linea `QA:` no se libra del veredicto que hay en disco.
  # PRESUPUESTO DE RECONSTRUCCION (SEC-007, R-001). Reconstruir cuesta del orden de
  # `ediciones x tamano` y no tenia techo: 1.501 ediciones sobre un REQ de 300 KB tardaban
  # 25,7 s, y un REQ de 3 MB con 401 ediciones no respondia en 30 s. A los 60 s el hook
  # MUERE, no emite nada y el resultado efectivo es PERMITIR. Asi que por encima del
  # presupuesto no se reconstruye: se deniega, y el deny alcanza TAMBIEN al agente de
  # codigo, porque nadie cierra un REQ desde una llamada que la puerta no puede medir.
  np=${#piezas[@]}
  if [ "$modo" != "W" ]; then
    k=$(( (np - 2) / 3 )); [ "$k" -lt 1 ] && k=1
    if (( ${#disk} * k > ARNES_EDIT_MAX_PRESUPUESTO )); then
      arnes_deny "ARNES: no se juzga esta edicion: reconstruir el documento resultante costaria mas de lo que esta puerta puede medir antes de morir (documento en disco x numero de ediciones supera el presupuesto de $ARNES_EDIT_MAX_PRESUPUESTO bytes-edicion). No es un veredicto sobre la edicion: es que la puerta no puede medirla, y una puerta que no puede medir no deja pasar (AGENTS.md 1). Salidas: parte el cambio en llamadas mas pequenas, o escribe el documento entero con Write."
    fi
  fi

  nuevo=''; resultante=''; reconstruido=0
  if [ "$modo" = "W" ]; then
    nuevo="${piezas[2]:-}"; resultante="$nuevo"
  else
    # CRLF -> LF, y SOLO eso: los proyectos en Windows guardan CRLF y la herramienta casa
    # el `old_string` con LF; si aqui no casara, se caeria a los fragmentos y el bypass
    # volveria por la puerta de atras. Los lectores de campos descuentan el resto del CR.
    #
    # POR QUE NO SE RETIRA TODO CR, que es lo que hacia hasta 1.32.1: el texto resultante
    # es lo que LEE el lector de cabecera, y ese lector escanea el rango `<!-- … -->` sobre
    # la linea cruda precisamente porque retirar un caracter puede FABRICAR un delimitador
    # (`-\r->` -> `-->`). Retirarlo aqui reintroducia la misma fabricacion un paso antes,
    # por la via del `Edit`: medido, un REQ `critico` con `-\r->` en DISCO cerraba con
    # `Seguridad: pendiente` vigente (H-01, `docs/qa/1.32.1-hallazgos.md`; CA-02 de REQ-016
    # nombra esta clase). Un CR seguido de LF es un fin de linea y se normaliza; un CR
    # suelto en mitad de una linea NO lo es, y ya no se toca aqui. Pregunta cerrada.
    resultante="${disk//$'\r\n'/$'\n'}"; reconstruido=1
    # k arranca en 2: piezas[0] es la bandera de bytes de control y piezas[1] el modo.
    for ((k = 2; k + 2 < np; k += 3)); do
      old="${piezas[k]//$'\r\n'/$'\n'}"; new="${piezas[k+1]//$'\r\n'/$'\n'}"; ra="${piezas[k+2]}"
      nuevo+="$new"$'\n'
      if [ -z "$old" ] || [[ "$resultante" != *"$old"* ]]; then reconstruido=0; continue; fi
      # Sustitucion literal: patron y reemplazo entre comillas, asi `*`, `[` o `&` en
      # un veredicto no significan nada (patsub_replacement esta activo en bash 5.2+).
      case "$ra" in
        1*) resultante="${resultante//"$old"/"$new"}" ;;
        *)  resultante="${resultante/"$old"/"$new"}" ;;
      esac
    done
  fi

  # --- Veredictos QA/Seguridad (anti-deriva) ---
  # Reconstruido: los campos son los de la cabecera del documento que quedara en disco.
  # Sin reconstruir: se prefiere el fragmento entrante y se respalda en disco (pre-edicion),
  # porque QA/seguridad fijan su veredicto antes de la transicion a completado.
  # Comparar el campo de cabecera, no buscar su nombre en el fragmento: el
  # lector acepta decoración y Edit puede sustituir sólo el valor. El crudo
  # incluye la evidencia: renovar la firma también requiere QA. Una firma
  # idéntica conservada al editar prosa no es una firma nueva.
  if [ "$reconstruido" -eq 1 ]; then arnes_campos_req "$resultante" ''
  else arnes_campos_req "$disk" "$nuevo"; fi
  qa="$ARNES_QA"; seg="$ARNES_SEG"; sens="$ARNES_SENS"; rigor="$ARNES_RIGOR"

  # --- Aviso al ESCRIBIR un veredicto fuera del vocabulario (NO deniega) ------------
  # Medido en un proyecto real: cuatro REQ llevaban SEMANAS con un `QA:` que la puerta no
  # reconocia, y nadie lo supo hasta que un cierre fallo. El defecto no era el valor: era
  # que nada lo dijera AL ESCRIBIRLO.
  #
  # POR QUE NO DENIEGA. Escribir `QA: aprobadisimo` no es un ataque ni un cierre
  # indebido: es una errata que la puerta ya atrapa al cerrar. Denegar la edicion añadiria
  # friccion constante a algo inocuo, y esa friccion termina con alguien apagando el
  # guard. El hook lo DICE y sigue (`systemMessage`; ver `arnes_aviso` en lib.sh).
  #
  # SOLO SI ESTA EDICION TOCA EL CAMPO, no por el estado del archivo: si no, cada edicion
  # del REQ repetiria el mismo aviso hasta que alguien lo silencie. Y el valor juzgado es
  # el de la CABECERA —`arnes_campos_req` no mira mas alla del primer `## `—, asi que una
  # linea igual dentro de una seccion no dispara nada.
  if [ -n "$qa" ] && ! arnes_en_vocab "$qa" "$ARNES_VOCAB_QA" && grep -q 'QA:' <<< "$nuevo"; then
    arnes_aviso "'$rel': 'QA:${ARNES_QA_CRUDO}' se lee como <$qa>, que NO es un veredicto ($ARNES_VOCAB_QA). Asi este REQ no podra cerrarse. Un matiz va entre parentesis —'QA: aprobado (R-045, 2026-09-01)'—; un veredicto distinto es otro valor."
  fi
  if [ -n "$seg" ] && ! arnes_en_vocab "$seg" "$ARNES_VOCAB_SEG" && grep -q 'Seguridad:' <<< "$nuevo"; then
    arnes_aviso "'$rel': 'Seguridad:${ARNES_SEG_CRUDO}' se lee como <$seg>, que NO es un veredicto ($ARNES_VOCAB_SEG). Si el rigor efectivo es critico, asi este REQ no podra cerrarse."
  fi

  # --- Orden del ciclo: seguridad no firma lo que QA no ha validado -------------
  # `AGENTS.md` §6 fija desarrollador -> qa-tester -> auditor-seguridad. La regla
  # ya estaba escrita; lo que faltaba es que se cumpliera. Buscando paralelismo se
  # emitio la firma de seguridad sobre arboles que QA no habia validado, y el
  # argumento del propio auditor lo zanja: "yo no miro seis de las siete quality
  # gates".
  #
  # Corre en CUALQUIER edicion del REQ, no solo al cerrarlo: el dano se hace al
  # escribir el veredicto, no al cierre. Por eso este bloque va ANTES de la
  # comprobacion de transicion a `completado`.
  #
  # EXCEPCION NOMBRADA: la auditoria PREVENTIVA —sin codigo todavia— si puede ir
  # por delante, porque no firma nada construido. Se declara escribiendo
  # `Seguridad: preventiva`, y se declara AL EMITIRLA, no al invocarla:
  # una excepcion que se inventa cuando hace falta no es una excepcion.
  #
  # Solo se juzga si esta edicion TOCA el campo: reordenar un REQ viejo que ya
  # tuviera los veredictos cruzados no debe bloquearse por algo que no hizo.
  if [ "$seg" = "aprobado" ] && [ -n "$qa" ] && [ "$qa" != "aprobado" ]; then
    arnes_seguridad_cabecera "$disk"; seg_antes="$ARNES_SEG_CABECERA"
    if [ "$ARNES_SEG_CRUDO" != "$seg_antes" ]; then
      arnes_deny "ARNES: '$rel' lleva 'Seguridad: aprobado' pero su 'QA:' es '$qa'. El ciclo es desarrollador -> qa-tester -> auditor-seguridad (AGENTS.md 6): la auditoria no firma sobre un arbol que QA no ha validado, porque no mira las quality gates. Si es una auditoria PREVENTIVA —sin codigo todavia— declarala con su propio veredicto: 'Seguridad: preventiva'."
    fi
  fi

  # ¿El cambio deja el REQ en `completado`? Normalizado: case-insensitive y espacios.
  arnes_norm_campo "$estado_done"; done_norm="$ARNES_CAMPO"
  if [ "$reconstruido" -eq 1 ] || [ "$modo" = "W" ]; then
    # HAY DOCUMENTO: la transicion se determina SOLO con el, nunca con el fragmento.
    # Transicion = la cabecera en disco NO decia el estado terminal y la cabecera
    # resultante SI lo dice.
    #
    # Dos fallos medidos contra 1.30.2, uno en cada sentido:
    #  · Un `Edit` con `old_string: en-revisión` y `new_string: completado` —un fragmento
    #    que no escribe en ninguna parte la palabra «Estado»— cerraba el REQ con QA
    #    pendiente: el hook ya reconstruia el documento, pero ADEMAS exigia la palabra en
    #    el FRAGMENTO y salia antes de llegar a las puertas. Y sustituir solo el VALOR es
    #    la forma mas natural de cerrar un REQ a mano.
    #  · Un `Write` cuyo CUERPO citaba `Estado: completado (...)` dentro de un criterio era
    #    denegado, porque el `grep` miraba todo el contenido en vez de la cabecera.
    #
    # La regla que resuelve los dos es la misma que ya regia para MultiEdit: manda la
    # cabecera del documento que quedara escrito. Por eso una linea de historia
    # `Estado: completado (revertido)` no es una transicion, y reabrir un REQ ya cerrado
    # tampoco.
    arnes_estado_cabecera "$resultante"
    est_despues="$ARNES_ESTADO"; cita_desp="$ARNES_ESTADO_CITA"; est_citado="$ARNES_ESTADO_CITADO"
    cr_desp="$ARNES_ESTADO_CR"; cr_linea="$ARNES_ESTADO_CR_LINEA"
    arnes_estado_cabecera "$disk";       est_antes="$ARNES_ESTADO"
    # UN CR QUE NO TERMINA LA LINEA: tampoco se juzga, se DENIEGA. Es la MISMA regla que el
    # rango sin cerrar, aplicada al caracter: la cabecera no se puede MEDIR (SEC-024,
    # R-007). El motivo cita la linea con el CR escrito `\r`, porque un renderizador de
    # HTML puede ESCONDER el bloque entero —trata `<!` seguido de algo que no sea `--` como
    # bogus comment y lo consume hasta el primer `>`—, asi que decir «hay un CR» sin decir
    # DONDE deja a la persona buscando texto que su editor no le muestra.
    #
    # Y AQUI NO SE EXIGE QUE EL ESTADO CAMBIE, a diferencia del rango sin cerrar, que si lo
    # exige. No es una inconsistencia: el CR puede FABRICAR el propio estado terminal
    # —`Estado: comple\rtado` se lee `completado` porque la normalizacion de la clave
    # descuenta el CR—, asi que sobre una cabecera que no se puede medir el «ya estaba
    # cerrado» puede ser un artefacto del mismo defecto que se esta midiendo, y usarlo como
    # eximente seria preguntarle al defecto si hay defecto. La friccion queda acotada a los
    # REQ que DECLARAN el estado terminal, y la salida es de una linea: retirar el CR (la
    # edicion que lo retira no lleva CR y no se deniega). Reabrir un REQ nunca se bloquea.
    if [ "$cr_desp" = "1" ] && [ "$est_despues" = "$done_norm" ]; then
      arnes_deny "ARNES: no se puede completar '$rel': su cabecera lleva un retorno de carro (CR) que NO termina la linea, en «$cr_linea». Un CR suelto en mitad de una linea no es un fin de linea: es un caracter invisible que puede FABRICAR delimitadores para unos lectores y no para otros —un '<!'+CR+'--' que un renderizador de HTML esconde y esta puerta no lee como comentario, o un 'Seg'+CR+'uridad:' que se lee como la clave 'Seguridad'—, asi que la cabecera no se puede MEDIR y una puerta que no puede medir no deja pasar (AGENTS.md 1). Salida: retira ese CR. El CR que TERMINA una linea es transporte (CRLF de Windows) y no cuenta: un REQ guardado entero en CRLF cierra igual que en LF."
    fi
    # UN RANGO DE COMENTARIO QUE ABRE Y NO CIERRA EN LA CABECERA: no se juzga, se DENIEGA.
    #
    # El interior de un `<!-- ... -->` no declara campo (arnes_sin_cita, lib.sh), y eso
    # cierra el fail-open por el que un veredicto CITADO gobernaba. Pero si el rango no
    # cierra, la cabecera deja de poder MEDIRSE: no se sabe cuantos veredictos se trago ni
    # cual gobierna. Ahi la regla es la de siempre —una puerta que no puede medir no deja
    # pasar— y, sobre todo, NUNCA se permite por AUSENCIA del campo que el rango se trago:
    # un campo vacio significa «no lo declara», y eso es justo lo que la puerta perdona.
    #
    # Se exige que HAYA un intento de cierre, no cualquier edicion: el estado terminal
    # leido de la cabecera, o —cuando el rango se trago la propia linea del estado— el que
    # esa linea declaraba desde dentro de la cita. Denegar toda edicion de un REQ con un
    # comentario mal cerrado seria friccion constante sobre algo que no cierra nada, y la
    # friccion termina con alguien apagando el guard (AGENTS.md 13).
    if [ "$cita_desp" = "1" ] && [ "$est_antes" != "$done_norm" ] &&
       { [ "$est_despues" = "$done_norm" ] || [ "$est_citado" = "$done_norm" ]; }; then
      arnes_deny "ARNES: no se puede completar '$rel': su cabecera ABRE un rango de comentario '<!--' que NO se cierra con '-->' antes del fin de la cabecera (el primer '## '). Lo que cae dentro de un comentario no declara campo, asi que con el rango abierto esta puerta no puede saber que veredictos se han quedado dentro ni cual gobierna — y no permite por AUSENCIA de un campo que un comentario se trago. Salida: cierra el comentario con '-->' dentro de la cabecera, o saca la nota fuera de ella. Un veredicto historico se documenta en el Historial de cambios, no en la cabecera."
    fi
    [ "$est_despues" = "$done_norm" ] || return 0
    [ "$est_antes" != "$done_norm" ] || return 0
  else
    # NO hay documento: un `Edit`/`MultiEdit` cuyo `old_string` no esta en el archivo. La
    # herramienta fallara entera y no escribira nada, pero se juzga el fragmento como
    # siempre —el banco fabrica ediciones asi y tiene que seguir midiendo lo mismo—.
    # Here-string en vez de `printf | grep`: la tuberia costaba un fork de mas.
    grep -iqE "estado:[[:space:]]*${estado_done}([[:space:]]|$)" <<< "$nuevo" || return 0
    # Y el mismo criterio sobre el FRAGMENTO: si la cabecera que se leyo —en disco o en lo
    # entrante— dejo un rango de comentario abierto (`ARNES_CITA_ABIERTA`, lo publica
    # `arnes_campos_req`), los campos que siguen a ese rango no se han leido y el cierre no
    # se puede medir.
    if [ "${ARNES_CITA_ABIERTA:-0}" = "1" ]; then
      arnes_deny "ARNES: no se puede completar '$rel': la cabecera que esta puerta pudo leer ABRE un rango de comentario '<!--' que no se cierra con '-->' antes del primer '## ', asi que los campos que vienen detras no se han leido y el cierre no se puede medir. Una puerta que no puede medir no deja pasar. Salida: cierra el comentario dentro de la cabecera, o saca la nota fuera de ella."
    fi
    # Y el mismo criterio para el CR que no termina la linea (`ARNES_CR_INTERIOR`, lo
    # publica `arnes_campos_req` por la misma via que el rango abierto): si la cabecera que
    # esta puerta pudo leer —en disco o en lo entrante— lleva uno, no se puede medir.
    if [ "${ARNES_CR_INTERIOR:-0}" = "1" ]; then
      arnes_deny "ARNES: no se puede completar '$rel': la cabecera que esta puerta pudo leer lleva un retorno de carro (CR) que NO termina la linea, en «${ARNES_CR_INTERIOR_LINEA}». Un CR suelto en mitad de una linea es un caracter invisible que puede FABRICAR delimitadores para unos lectores y no para otros, asi que la cabecera no se puede MEDIR y una puerta que no puede medir no deja pasar (AGENTS.md 1). Salida: retira ese CR. El CR que TERMINA una linea es transporte (CRLF de Windows) y no cuenta."
    fi
  fi

  # --- Nivel de rigor: cuanta ceremonia exige ESTE requerimiento ---
  # `ligero` no pide veredictos: es para lo que no tiene logica —textos, etiquetas,
  # ajustes de presentacion—. `estandar` pide QA. `critico` pide QA y auditoria.
  #
  # Un REQ que no declara `Rigor:` se juzga EXACTAMENTE como antes de que los
  # niveles existieran, asi que un proyecto sin migrar no nota ningun cambio.
  # Y `Sensible a seguridad: si` impone `critico` como suelo: el nivel se puede
  # subir, nunca bajar (ver `arnes_rigor_efectivo` en lib.sh).
  # `ligero` salta SOLO los veredictos de QA y seguridad. NO salta la clase del
  # hallazgo, ni las aprobaciones humanas pendientes, ni las quality gates: la
  # plantilla promete "analista + desarrollador + quality gates" para ligero, y hasta
  # 1.28.0 el codigo hacia `return 0` aqui mismo, ANTES de las tres puertas de abajo.
  # Un REQ ligero cerraba con el build en rojo y con una aprobacion humana pendiente.
  # La maquina hacia menos de lo que el papel decia -- deriva, desde 1.19.0.
  if [ "$rigor" != "ligero" ]; then

    # Solo se exige el campo cuando está presente (compatibilidad con REQ antiguos sin veredictos).
    if [ -n "$qa" ] && [ "$qa" != "aprobado" ]; then
      arnes_deny "ARNES: no se puede completar '$rel': el veredicto de QA es '$qa' (se requiere 'QA: aprobado'). Resuelve los hallazgos de QA y refléjalos en el REQ antes de cerrar (AGENTS.md §9)."
    fi
    # `si` a secas: el normalizador pliega la tilde y retira el marcado de Markdown,
    # así que `SÍ`, `sí`, `**sí**` y `sí — porque toca auth` llegan aquí como la misma
    # forma. Y un valor que NO se entiende se trata como sensible, no como «no»: ver
    # `arnes_sens_efectiva` en lib.sh.
    case "$rigor" in
      critico)
        if [ "$seg" != "aprobado" ]; then
          # Si el rigor salió de un valor que no se entendió, la denegación TIENE que
          # decirlo: un deny que no explica de dónde sale se lee como un falso positivo
          # y acaba con alguien apagando el guard.
          if [ "${ARNES_SENS_DUDOSA:-0}" = "1" ]; then
            arnes_deny "ARNES: no se puede completar '$rel': su 'Sensible a seguridad:' dice '${ARNES_SENS_CRUDO}', que no se reconoce ni como si ni como no, y un valor que no se entiende se trata como SENSIBLE —no saber no puede abrir una puerta—. Escribe 'si' o 'no' (el énfasis de Markdown y un comentario tras el valor si se toleran), o declara 'Seguridad: aprobado' si de verdad lo es."
          fi
          arnes_deny "ARNES: no se puede completar '$rel': su rigor efectivo es 'critico' y el veredicto de seguridad es '${seg:-ausente}' (se requiere 'Seguridad: aprobado'). El control hallado debe quedar como NFR antes de cerrar (AGENTS.md §9)."
        fi ;;
    esac

    # --- Veredicto FECHADO y no CADUCO (opt-in del proyecto) -----------------------
    # Medido en un proyecto real: cuatro REQ se habrian cerrado con un `QA: aprobado`
    # emitido contra codigo que cambio DESPUES de la firma; otro llevaba `Seguridad:
    # aprobado` a secas, sin ronda ni fecha, y era justo el unico que nadie sabia que
    # estaba caduco. Un veredicto es una foto, y una foto solo vale si el sujeto estaba
    # quieto.
    #
    # LA FECHA VIAJA EN EL PARENTESIS DE EVIDENCIA —`QA: aprobado (R-045, 2026-09-01)`—,
    # que ya es la convencion del arnes, y se lee del valor CRUDO: la normalizacion corta
    # ese parentesis a proposito, porque la evidencia no cambia el veredicto.
    #
    # LAS DOS CLAVES NACEN APAGADAS: un proyecto que no las active no nota ningun cambio.
    # El arnes trae el mecanismo; que se mida, y contra que globs, lo declara el
    # manifiesto.
    #
    # SOLO SE LE EXIGE FECHA A `aprobado`: es la unica firma que cierra, y un veredicto
    # que no cierra ya deniega por su propio motivo unas lineas mas arriba.
    #
    # ASIMETRIA DECLARADA: `git log -1 --format=%cs` tiene resolucion de DIA, asi que un
    # veredicto del MISMO dia que el commit NO caduca (la comparacion es estrictamente
    # anterior). Y una fecha FUTURA se acepta como fecha y nunca caduca: esta puerta mide
    # el veredicto contra el CODIGO, no contra el reloj, y hacerla depender del reloj de
    # la maquina la volveria sensible a la zona horaria justo en el limite del dia.
    # Falsear la fecha es de la familia de `aprobado (con reservas)`: una violacion de la
    # convencion, declarada aqui y en la plantilla, no un agujero silencioso.
    if [ "${ARNES_VER_FECHA:-}" = "true" ] || [ "${ARNES_VER_CADUCAN:-}" = "true" ]; then
      local -a vered=("QA:|$qa|$ARNES_QA_CRUDO")
      [ "$rigor" = "critico" ] && vered+=("Seguridad:|$seg|$ARNES_SEG_CRUDO")
      local fecha_codigo='' commit_codigo='' sucio='' v campo valor crudo linea_git rc_git
      if [ "${ARNES_VER_CADUCAN:-}" = "true" ]; then
        # Sin globs no se puede medir "el codigo": la consulta miraria el repositorio
        # entero, que es OTRA pregunta y siempre responderia que si.
        if [ "${#ARNES_GLOBS[@]}" -eq 0 ]; then
          arnes_deny "ARNES: no se puede completar '$rel': el manifiesto exige que el veredicto no sea anterior al ultimo cambio del codigo (veredictos.caducan_con_codigo) pero 'codigo_app.globs' esta vacio. Sin globs declarados la consulta mediria el repositorio entero, que es otra pregunta. Declara los globs del codigo de la app, o apaga la opcion."
        fi
        if ! command -v git >/dev/null 2>&1; then
          arnes_deny "ARNES: no se puede completar '$rel': el manifiesto exige medir la caducidad del veredicto contra el codigo (veredictos.caducan_con_codigo) y no hay 'git' en el PATH. Una puerta que no puede medir no deja pasar (AGENTS.md 1)."
        fi
        # DOS invocaciones de git por evaluacion, ni una mas, y solo en esta via: la
        # existencia del repositorio se DERIVA del fallo de la primera en vez de gastar
        # un tercer proceso en preguntarla.
        linea_git="$(git -C "$ARNES_PROJ" log -1 --format='%cs %h' -- "${ARNES_GLOBS[@]}" 2>/dev/null)"; rc_git=$?
        if [ "$rc_git" -ne 0 ]; then
          arnes_deny "ARNES: no se puede completar '$rel': el manifiesto exige medir la caducidad del veredicto contra el codigo (veredictos.caducan_con_codigo) y 'git log' no pudo responder en '$ARNES_PROJ' (¿no es un repositorio git?). Una puerta que no puede medir no deja pasar (AGENTS.md 1)."
        fi
        if [ -n "$linea_git" ]; then
          fecha_codigo="${linea_git%% *}"; commit_codigo="${linea_git#* }"
          # Un git anterior a `%cs` devuelve el literal en vez de una fecha. Tomarlo por
          # fecha y compararlo lexicograficamente seria dejar pasar por no entender la
          # salida, que es la peor forma de permitir.
          arnes_fecha_en "$fecha_codigo"
          if [ "$ARNES_FECHA" != "$fecha_codigo" ]; then
            arnes_deny "ARNES: no se puede completar '$rel': 'git log --format=%cs' devolvio '$fecha_codigo', que no es una fecha AAAA-MM-DD (git demasiado antiguo para ese formato). No se puede medir la caducidad del veredicto y no se deja pasar por no entender la salida (AGENTS.md 1)."
          fi
        fi
        # Vacio = ningun commit ha tocado los globs: no hay codigo posterior al veredicto
        # porque no hay codigo comiteado, y el arbol si se pudo medir.
        sucio="$(git -C "$ARNES_PROJ" status --porcelain -- "${ARNES_GLOBS[@]}" 2>/dev/null)"; rc_git=$?
        if [ "$rc_git" -ne 0 ]; then
          arnes_deny "ARNES: no se puede completar '$rel': 'git status' no pudo responder en '$ARNES_PROJ' y el manifiesto exige medir la caducidad del veredicto contra el codigo (veredictos.caducan_con_codigo). Una puerta que no puede medir no deja pasar (AGENTS.md 1)."
        fi
        sucio="${sucio%%$'\n'*}"
      fi
      for v in "${vered[@]}"; do
        campo="${v%%|*}"; crudo="${v#*|}"; valor="${crudo%%|*}"; crudo="${crudo#*|}"
        [ "$valor" = "aprobado" ] || continue
        arnes_fecha_en "$crudo"
        if [ -z "$ARNES_FECHA" ]; then
          arnes_deny "ARNES: no se puede completar '$rel': el veredicto '$campo$crudo' no lleva fecha y el manifiesto la exige (veredictos). Un veredicto sin fecha no se puede caducar, y uno que no caduca sobrevive a los cambios del codigo que juzga. Escribe la ronda y la fecha en formato AAAA-MM-DD dentro del parentesis de evidencia: '$campo aprobado (R-000, AAAA-MM-DD)'."
        fi
        if [ -n "$fecha_codigo" ] && [[ "$ARNES_FECHA" < "$fecha_codigo" ]]; then
          arnes_deny "ARNES: no se puede completar '$rel': el veredicto '$campo$crudo' es del $ARNES_FECHA y el codigo de la app cambio el $fecha_codigo ($commit_codigo). Un veredicto anterior al codigo que juzga no lo juzga: hace falta re-validar y volver a firmar con la fecha nueva (AGENTS.md 9). El empate no caduca: 'git log --format=%cs' tiene resolucion de dia."
        fi
      done
      if [ -n "$sucio" ]; then
        arnes_deny "ARNES: no se puede completar '$rel': hay cambios SIN COMITEAR en el codigo de la app ('${sucio#???}'). Un veredicto no puede ser posterior a codigo que aun no existe en git, asi que la caducidad no se puede medir: comitea —o descarta— antes de cerrar (veredictos.caducan_con_codigo)."
      fi
    fi
  fi

  # --- Clase del hallazgo: no todo hallazgo bloquea ---
  # Vive en su propia funcion (arriba) por el `local LC_ALL=C` que necesita su recorrido:
  # asi el locale vuelve al salir y las quality gates de abajo no lo heredan.
  arnes_clase_hallazgo

  # --- Gate A2: no completar con aprobaciones pendientes ---
  # La regla de conteo vive en `hooks/lib.sh` (`arnes_cola_pendientes`) y es la MISMA
  # que lee el bloque derivado de `docs/ESTADO.md` y `tools/arnes-lectura.sh`. Antes
  # este `awk` era una de dos transcripciones y el informe decía otro número que la
  # puerta; dos transcripciones de la misma regla se desfasan (REQ-009).
  pending="$ARNES_PROJ/$pending_rel"
  if [ -f "$pending" ]; then
    if ! arnes_cola_pendientes "$pending"; then
      arnes_deny "ARNES: no se puede marcar '$rel' como '$estado_done': la cola de aprobaciones ($pending_rel) no se pudo leer entera —un byte NUL la trunca, o el archivo no es legible—, asi que no se sabe cuantas aprobaciones humanas hay abiertas. Una puerta que no puede medir no deja pasar (AGENTS.md 1). Arregla el archivo y reintenta."
    fi
    abiertas="$ARNES_COLA"
    if [ "${abiertas:-0}" -gt 0 ]; then
      arnes_deny "ARNES: no se puede marcar '$rel' como '$estado_done': hay $abiertas aprobación(es) pendiente(s) en $pending_rel. El humano debe resolverlas primero (ver AGENTS.md §6)."
    fi
  fi

  # --- Gate A3: quality gates en verde antes de completar ---
  arnes_jq_file "$ARNES_MANIFEST" -r '.quality_gates[]? | if type=="object" then (.comando // empty) else . end'
  ARNES_GATES="$ARNES_JQ"
  tmp="$(mktemp 2>/dev/null || echo /tmp/arnes_gate.$$)"
  while IFS= read -r cmd; do
    [ -n "$cmd" ] || continue
    if ! ( cd "$ARNES_PROJ" && eval "$cmd" ) >"$tmp" 2>&1; then
      out="$(tail -c 600 "$tmp" 2>/dev/null)"
      rm -f "$tmp"
      arnes_deny "ARNES: no se puede marcar '$rel' como '$estado_done': falló la quality gate \`$cmd\`. Corrígela y reintenta (ver AGENTS.md §7). Últimas líneas: $out"
    fi
  done <<< "$ARNES_GATES"
  rm -f "$tmp"

  return 0
}

# Ejecutado directamente (no `source`): hace su propio preludio y corre.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  arnes_preludio || exit 0
  arnes_guard_completado
  arnes_emitir_avisos
  exit 0
fi
