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
  # `Seguridad: aprobado (preventiva)`, y se declara AL EMITIRLA, no al invocarla:
  # una excepcion que se inventa cuando hace falta no es una excepcion.
  #
  # Solo se juzga si esta edicion TOCA el campo: reordenar un REQ viejo que ya
  # tuviera los veredictos cruzados no debe bloquearse por algo que no hizo.
  if [ "$seg" = "aprobado" ] && [ -n "$qa" ] && [ "$qa" != "aprobado" ]; then
    if grep -q 'Seguridad:' <<< "$nuevo"; then
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
    # UNA CLAVE DE LA CABECERA CON ALGO INSERTADO DENTRO: tampoco se juzga, se DENIEGA.
    #
    # Misma regla que el rango sin cerrar y que el CR interior, aplicada a la clase entera:
    # la linea DECLARA el campo —una persona la lee y ve la clave de la plantilla—, ninguna
    # regla contratada la retira, y este lector no la resuelve como ese campo. Entonces la
    # cabecera no se puede MEDIR, y una puerta que no puede medir no deja pasar (AGENTS.md
    # 1). Medido: un BOM delante de `Sensible a seguridad: si` con `Rigor: ligero` cerraba
    # con los dos veredictos en `pendiente` (SEC-047, R-012).
    #
    # Y NUNCA SE PERMITE POR AUSENCIA DEL CAMPO QUE EL CARACTER BORRO: es exactamente lo que
    # esta puerta perdona por compatibilidad, asi que resolver esto como «el campo falta»
    # seria un `allow` con otro nombre en cuanto el rigor declarado fuese `ligero`.
    #
    # SE EXIGE QUE HAYA UN INTENTO DE CIERRE, y de las dos formas en que puede haberlo: el
    # estado terminal leido de la cabecera, o —cuando el caracter cayo sobre la clave del
    # ESTADO— el que esa misma linea declaraba (`ARNES_OCULTA_ESTADO`). Sin la segunda, un
    # invisible sobre `Estado:` se resolveria como «aqui no hay transicion» y el documento
    # quedaria diciendo `completado` sin que ninguna puerta lo hubiera medido nunca. Denegar
    # toda edicion de un REQ con un invisible seria friccion constante sobre algo que no
    # cierra nada, y la friccion termina con alguien apagando el guard (AGENTS.md 13).
    # REABRIR nunca se bloquea: si el estado en disco ya era el terminal, aqui no se entra.
    if [ "${ARNES_OCULTA:-0}" = "1" ] && [ "$est_antes" != "$done_norm" ] &&
       { [ "$est_despues" = "$done_norm" ] || [ "${ARNES_OCULTA_ESTADO:-}" = "$done_norm" ]; }; then
      arnes_deny "ARNES: no se puede completar '$rel': su cabecera declara el campo '${ARNES_OCULTA_CLAVE}:' con algo INSERTADO DENTRO DE LA CLAVE, que esta puerta no puede leer como ese campo. La clave, con sus bytes ajenos en hexadecimal: «${ARNES_OCULTA_REPR}:». Puede ser un BOM (\\xef\\xbb\\xbf, el que PowerShell añade al redirigir), un espacio de anchura cero (\\xe2\\x80\\x8b), un byte de control, un multibyte partido, o un BLANCO de mas o puesto en el sitio de otro ('Sensible a  seguridad'): son invisibles y el diff tampoco los muestra. Los blancos salen en hexadecimal solo cuando alguno de ellos ES lo insertado. Una persona lee ahi un campo y la maquina no lo lee, asi que la cabecera no se puede MEDIR y una puerta que no puede medir no deja pasar (AGENTS.md 1) — y NUNCA permite por AUSENCIA del campo que ese caracter borro. Salida: reescribe esa linea de la cabecera dejando la clave limpia. 'tools/arnes-lectura.sh' la señala antes de que llegues a esta puerta."
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
    # Y el mismo criterio para la clave con algo insertado dentro (`ARNES_OCULTA`, lo publica
    # `arnes_campo_linea` y lo acumula `arnes_campos_req`, por la misma via que las dos de
    # arriba): si la cabecera que esta puerta pudo leer —en disco o en lo entrante— declara
    # un campo que la maquina no lee como ese campo, no se puede medir. Aqui no hay documento
    # que reconstruir, asi que el intento de cierre ya lo comprobo el `grep` de arriba.
    if [ "${ARNES_OCULTA:-0}" = "1" ]; then
      arnes_deny "ARNES: no se puede completar '$rel': la cabecera que esta puerta pudo leer declara el campo '${ARNES_OCULTA_CLAVE}:' con algo INSERTADO DENTRO DE LA CLAVE, que no se lee como ese campo. La clave, con sus bytes ajenos en hexadecimal: «${ARNES_OCULTA_REPR}:». Es un caracter invisible —un BOM, un espacio de anchura cero, un byte de control, un multibyte partido, un BLANCO de mas o puesto en el sitio de otro— y el diff no lo muestra: una persona lee ahi un campo y la maquina no, asi que la cabecera no se puede MEDIR y una puerta que no puede medir no deja pasar (AGENTS.md 1). Nunca permite por AUSENCIA del campo que ese caracter borro. Salida: reescribe esa linea dejando la clave limpia."
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

    # LA AUSENCIA YA NO SE RESUELVE AQUI, SE PREGUNTA AL SITIO UNICO (REQ-024 CA-02).
    #
    # Hasta 1.33.0 esta linea era `[ -n "$qa" ] &&`, y ese `-n` ERA la decision: un `QA:`
    # que no llegaba a declararse —comentado, borrado o nunca escrito— saltaba la
    # comprobacion entera. La direccion de la ausencia la declara ahora `ARNES_AUSENCIA`
    # (hooks/lib.sh, ADR-009) y para los VEREDICTOS es `deniega` NOMBRANDO el campo que
    # falta, porque «gobernar» un veredicto seria fabricar una firma que nadie emitio.
    # Con la exigencia apagada —el defecto— `arnes_resuelve_ausencia` devuelve 0 y aqui se
    # decide EXACTAMENTE lo mismo que antes (REQ-024 CA-05).
    if ! arnes_resuelve_ausencia "$ARNES_CLAVE_QA" "$qa"; then
      arnes_deny "ARNES: no se puede completar '$rel': su cabecera NO declara el campo '$ARNES_CLAVE_QA:', y este proyecto exige que los campos de cabecera esten declarados ('campos.ausencia_exige' en .arnes/config.json). Un campo que falta no es un campo aprobado: la ausencia se resolvia del lado que ABRE y por esa via un REQ critico cerraba con la validacion pendiente (SEC-047). Salida: escribe la linea '$ARNES_CLAVE_QA: aprobado' con su evidencia, o el veredicto que corresponda."
    fi
    # Solo se exige el VALOR cuando está presente (compatibilidad con REQ antiguos sin
    # veredictos); la AUSENCIA la acaba de resolver el sitio único, arriba.
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
          # UN FAIL-CLOSED NO PUEDE SER SILENCIOSO (REQ-024 CA-01, direccion `gobierna`).
          # Cuando el rigor llego a `critico` porque un campo AUSENTE se resolvio con el
          # valor que mas restringe, el motivo lo dice: sin esto la persona lee «tu REQ es
          # critico» sobre un documento que no declara ni sensibilidad ni rigor y no tiene
          # forma de saber de donde salio. «Entra pero no ve nada, sin explicacion» es un
          # bug de diagnostico, no una puerta.
          if [ "${ARNES_AUSENCIA_EXIGE:-false}" = "true" ] &&
             { [ "${ARNES_SENS_AUSENTE:-0}" = "1" ] || [ "${ARNES_RIGOR_AUSENTE:-0}" = "1" ]; }; then
            arnes_deny "ARNES: no se puede completar '$rel': su rigor efectivo es 'critico' y el veredicto de seguridad es '${seg:-ausente}' (se requiere 'Seguridad: aprobado'). Y el rigor es 'critico' PORQUE su cabecera no declara$([ "${ARNES_SENS_AUSENTE:-0}" = "1" ] && printf " '%s:'" "$ARNES_CLAVE_SENS")$([ "${ARNES_RIGOR_AUSENTE:-0}" = "1" ] && printf " '%s:'" "$ARNES_CLAVE_RIGOR"): este proyecto exige que los campos de cabecera esten declarados ('campos.ausencia_exige' en .arnes/config.json) y un campo que falta se resuelve con el valor que MAS restringe, nunca retirando el suelo (ADR-009). Salida: declara esos campos con su valor real."
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
  # Un defecto del propio arnes (un lector de umbral, un guardian, una prueba) no
  # puede impedir cerrar una funcion de negocio. Sin esta distincion, un hallazgo
  # de instrumento mantiene un REQ abierto mientras QA encuentra variantes suyas.
  # Un hallazgo SIN clase deniega: la puerta no puede saber si bloquea o no, y un
  # "no se" que deja pasar es un "si" disfrazado.
  hall="$ARNES_HALL"
  # LA AUSENCIA DEL CAMPO NO ES «NINGUN HALLAZGO» (REQ-024 CA-01/CA-02). `(ninguno)` es una
  # declaracion —alguien miro y no habia—; que la linea no exista es que nadie la escribio,
  # y hasta 1.33.0 las dos cosas se resolvian igual: del lado que ABRE. Por esa via un
  # hallazgo `contrato` que bloqueaba el cierre se retiraba comentando su linea (SEC-047).
  # La direccion la declara el sitio unico y para este campo es `deniega`: inventar
  # «ninguno» abre, e inventar un hallazgo bloqueante seria fabricar lo contrario. Se juzga
  # el valor CRUDO, antes de normalizar, porque despues de normalizar `(ninguno)` y la
  # ausencia son la misma cadena vacia — que es precisamente la confusion que esto cierra.
  if ! arnes_resuelve_ausencia "$ARNES_CLAVE_HALL" "$hall"; then
    arnes_deny "ARNES: no se puede completar '$rel': su cabecera NO declara el campo '$ARNES_CLAVE_HALL:', y este proyecto exige que los campos de cabecera esten declarados ('campos.ausencia_exige' en .arnes/config.json). Que la linea no exista no es lo mismo que declarar que no hay hallazgos: la ausencia se resolvia del lado que ABRE, asi que un hallazgo bloqueante se retiraba comentando su linea (SEC-047). Salida: escribe '$ARNES_CLAVE_HALL: (ninguno)' si de verdad no hay ninguno, o la lista con la clase de cada uno."
  fi
  case "$hall" in
    ''|ninguno|'(ninguno)'|n/a|na|-|'(-)') hall='' ;;
  esac
  if [ -n "$hall" ]; then
    # La lista se parte por las comas DE FUERA del parentesis, sin procesos. Antes se
    # partia con IFS a secas, y entonces `SEC-9 (usuario/dinero, dueno desarrollador)` se
    # troceaba EN MEDIO de la clase: la puerta leia «un hallazgo sin clase» y denegaba el
    # cierre. Es decir, castigaba precisamente la anotacion de dueno que AGENTS.md 6 pide
    # para la deuda de instrumento (QA-014). Dentro del parentesis, la CLASE es el primer
    # elemento y lo que venga tras ella es EVIDENCIA — la misma regla que ya rige el
    # parentesis de un veredicto (`QA: aprobado (medido el 3/9)`).
    ARNES_HALLAZGOS=(); acc=''; prof=0
    for ((ci = 0; ci < ${#hall}; ci++)); do
      c="${hall:ci:1}"
      case "$c" in
        '(') prof=$((prof+1)); acc+="$c" ;;
        ')') [ "$prof" -gt 0 ] && prof=$((prof-1)); acc+="$c" ;;
        ',') if [ "$prof" -eq 0 ]; then ARNES_HALLAZGOS+=("$acc"); acc=''; else acc+="$c"; fi ;;
        *)   acc+="$c" ;;
      esac
    done
    [ -n "$acc" ] && ARNES_HALLAZGOS+=("$acc")
    for h in ${ARNES_HALLAZGOS[@]+"${ARNES_HALLAZGOS[@]}"}; do
      [ -n "$h" ] || continue
      id="${h%%(*}"
      clase=''
      case "$h" in
        # La clase es lo que va hasta la primera coma de dentro del parentesis; el resto
        # ACOMPANA al veredicto y nunca lo cambia.
        *\(*\)*) clase="${h#*\(}"; clase="${clase%%\)*}"; clase="${clase%%,*}" ;;
      esac
      if [ -z "$clase" ]; then
        arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$id' no declara su clase, y un hallazgo sin clase no cuenta como hallazgo. Clasificalo como 'usuario/dinero', 'contrato' o 'instrumento' (requirements/README.md, seccion 'Clases de hallazgo')."
      fi
      case "$clase" in
        instrumento) ;;   # no bloquea: va a deuda tecnica con dueno
        usuario/dinero|contrato)
          arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$id' es de clase '$clase' y bloquea el cierre. Resuelvelo — o reclasificalo si en realidad no afecta a lo que alguien ve, decide o cobra ni a lo que el REQ afirma (requirements/README.md, seccion 'Clases de hallazgo')." ;;
        *)
          arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$id' declara '$clase', que no es una clase valida, asi que no declara su clase y un hallazgo sin clase no cuenta como hallazgo. Validas: 'usuario/dinero', 'contrato', 'instrumento'. La clase va la PRIMERA dentro del parentesis; lo que venga tras una coma es evidencia (dueno, forzador, vencimiento)." ;;
      esac
    done
  fi

  # --- Gate A2: no completar con aprobaciones pendientes ---
  # La regla de conteo vive en `hooks/lib.sh` (`arnes_cola_pendientes`) y es la MISMA
  # que lee el bloque derivado de `docs/ESTADO.md` y `tools/arnes-lectura.sh`. Antes
  # este `awk` era una de dos transcripciones y el informe decía otro número que la
  # puerta; dos transcripciones de la misma regla se desfasan (REQ-009).
  pending="$ARNES_PROJ/$pending_rel"
  if [ -f "$pending" ]; then
    if ! arnes_cola_pendientes "$pending"; then
      # DOS MOTIVOS DISTINTOS, DOS MENSAJES: el segundo es de 1.34.0 (REQ-024 CA-08) y cita
      # LA LINEA DONDE ABRE el rango. Decir «no se pudo leer entera» sobre un comentario mal
      # cerrado manda a la persona a buscar un byte NUL que no existe.
      if [ "${ARNES_COLA_ABIERTA:-0}" = "1" ]; then
        arnes_deny "ARNES: no se puede marcar '$rel' como '$estado_done': la cola de aprobaciones ($pending_rel) ABRE un rango de comentario '<!--' en la linea ${ARNES_COLA_ABRE_LN} —«${ARNES_COLA_ABRE_TEXTO}»— que NO se cierra con '-->' antes del fin del archivo. Todo lo que viene detras quedo descartado, asi que no se sabe cuantas aprobaciones humanas hay abiertas: hasta 1.33.0 esto contaba CERO en silencio y dejaba cerrar (SEC-051). Una puerta que no puede medir no deja pasar (AGENTS.md 1). Salida: cierra ese comentario con '-->', o saca la nota fuera del archivo."
      fi
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
