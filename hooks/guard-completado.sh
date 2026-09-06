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
  local disk qa seg sens rigor hall h id clase pending abiertas tmp cmd out rc
  local -a piezas=()
  local modo resultante reconstruido np k old new ra done_norm est_antes est_despues

  # El análisis del input y del manifiesto es COMPARTIDO y memorizado: si
  # `guard-codigo` ya corrió en este mismo proceso, aquí no se vuelve a pagar.
  arnes_parse_input
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
        arnes_deny "ARNES: el cuerpo sin citar de un heredoc (o el texto del comando fuera de los heredocs) es demasiado grande para analizarlo con garantia; no se analizo y no se permite. Una puerta que no puede medir no deja pasar (AGENTS.md 1): sin analisis no se puede saber si el comando toca '$ARNES_REQ_DIR'. El presupuesto de analisis vigente es de $ARNES_TECHO bytes y este comando lo supera. Salidas: heredoc CITADO (<<'EOF'), un archivo de script, o partir el comando en trozos por debajo de $ARNES_TECHO bytes. El techo se puede SUBIR en .arnes/config.json con 'limites.bash_max_analisis' (bytes)."
      fi
      [ -n "$escrituras" ] || return 0 ;;
    Edit|Write|MultiEdit)
      [ -n "$fp" ] || return 0 ;;
    *) return 0 ;;
  esac

  arnes_parse_manifest
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
  arnes_jq_str "$ARNES_INPUT" -r '
    if   .tool_name == "Write" then ["W", (.tool_input.content // "")]
    elif .tool_name == "Edit"  then ["E", (.tool_input.old_string // ""), (.tool_input.new_string // ""),
                                     (if .tool_input.replace_all == true then "1" else "0" end)]
    elif .tool_name == "MultiEdit" then ["E"] + [.tool_input.edits[]? |
                                     (.old_string // ""), (.new_string // ""),
                                     (if .replace_all == true then "1" else "0" end)]
    else ["W", ""] end | join("\u0001")'
  piezas=()
  IFS=$'\001' read -r -d '' -a piezas <<< "$ARNES_JQ" || true
  modo="${piezas[0]:-W}"

  disk=''; [ -f "$fp" ] && IFS= read -r -d '' disk < "$fp"   # `read`, no `cat`: sin fork

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
  nuevo=''; resultante=''; reconstruido=0
  if [ "$modo" = "W" ]; then
    nuevo="${piezas[1]:-}"; resultante="$nuevo"
  else
    # Sin CR: los proyectos en Windows guardan CRLF y la herramienta casa el `old_string`
    # igual; si aqui no casara, se caeria a los fragmentos y el bypass volveria por la
    # puerta de atras. Los lectores de campos ya quitan el CR, asi que nada cambia.
    resultante="${disk//$'\r'/}"; reconstruido=1; np=${#piezas[@]}
    for ((k = 1; k + 2 < np; k += 3)); do
      old="${piezas[k]//$'\r'/}"; new="${piezas[k+1]//$'\r'/}"; ra="${piezas[k+2]}"
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
    arnes_estado_cabecera "$resultante"; est_despues="$ARNES_ESTADO"
    arnes_estado_cabecera "$disk";       est_antes="$ARNES_ESTADO"
    [ "$est_despues" = "$done_norm" ] || return 0
    [ "$est_antes" != "$done_norm" ] || return 0
  else
    # NO hay documento: un `Edit`/`MultiEdit` cuyo `old_string` no esta en el archivo. La
    # herramienta fallara entera y no escribira nada, pero se juzga el fragmento como
    # siempre —el banco fabrica ediciones asi y tiene que seguir midiendo lo mismo—.
    # Here-string en vez de `printf | grep`: la tuberia costaba un fork de mas.
    grep -iqE "estado:[[:space:]]*${estado_done}([[:space:]]|$)" <<< "$nuevo" || return 0
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
  # Un defecto del propio arnes (un lector de umbral, un guardian, una prueba) no
  # puede impedir cerrar una funcion de negocio. Sin esta distincion, un hallazgo
  # de instrumento mantiene un REQ abierto mientras QA encuentra variantes suyas.
  # Un hallazgo SIN clase deniega: la puerta no puede saber si bloquea o no, y un
  # "no se" que deja pasar es un "si" disfrazado.
  hall="$ARNES_HALL"
  case "$hall" in
    ''|ninguno|'(ninguno)'|n/a|na|-|'(-)') hall='' ;;
  esac
  if [ -n "$hall" ]; then
    # La lista se parte con IFS, no con `printf | tr`: eran tres forks para trocear
    # una cadena que ya está en memoria.
    IFS=',' read -r -a ARNES_HALLAZGOS <<< "$hall"
    for h in ${ARNES_HALLAZGOS[@]+"${ARNES_HALLAZGOS[@]}"}; do
      [ -n "$h" ] || continue
      id="${h%%(*}"
      clase=''
      case "$h" in
        *\(*\)*) clase="${h#*\(}"; clase="${clase%%\)*}" ;;
      esac
      if [ -z "$clase" ]; then
        arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$id' no declara su clase, y un hallazgo sin clase no cuenta como hallazgo. Clasificalo como 'usuario/dinero', 'contrato' o 'instrumento' (requirements/README.md, seccion 'Clases de hallazgo')."
      fi
      case "$clase" in
        instrumento) ;;   # no bloquea: va a deuda tecnica con dueno
        usuario/dinero|contrato)
          arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$id' es de clase '$clase' y bloquea el cierre. Resuelvelo — o reclasificalo si en realidad no afecta a lo que alguien ve, decide o cobra ni a lo que el REQ afirma (requirements/README.md, seccion 'Clases de hallazgo')." ;;
        *)
          arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$id' declara la clase '$clase', que no existe. Validas: 'usuario/dinero', 'contrato', 'instrumento'." ;;
      esac
    done
  fi

  # --- Gate A2: no completar con aprobaciones pendientes ---
  pending="$ARNES_PROJ/$pending_rel"
  if [ -f "$pending" ]; then
    abiertas="$(awk '
      # Un ejemplo de formato COMENTADO no es una entrada de la cola. La plantilla
      # traia uno bajo `## Pendientes` y este conteo lo leia como 1 pendiente, asi
      # que un proyecto recien inicializado no podia cerrar NINGUN REQ.
      /<!--/ {enc=1}
      /-->/  {enc=0; next}
      enc    {next}
      # La seccion va de su cabecera a la SIGUIENTE DEL MISMO NIVEL, se llame como
      # se llame. Antes solo la cerraba una cabecera literal `## Resueltas`, asi que
      # cualquier otra --`## Notas`, `## Historico`-- la dejaba abierta y sus `###`
      # se contaban como aprobaciones pendientes. Eso es una lista enumerada donde
      # hace falta una propiedad cerrada, y obligaba a los proyectos a ordenar el
      # archivo para esquivarlo: carga, no estilo.
      /^##[[:space:]]/ {sec = ($0 ~ /^##[[:space:]]+Pendientes/) ? 1 : 0; next}
      sec && /^###[[:space:]]/    {c++}
      END {print c+0}
    ' "$pending")"
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
