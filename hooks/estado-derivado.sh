#!/usr/bin/env bash
# Hook Stop / SubagentStop: deja en `docs/ESTADO.md` un bloque DERIVADO del disco.
#
# POR QUE EXISTE
# El coste mas caro de una sesion larga no es el tiempo: es tener que reconstruir
# donde quedo todo cuando el contexto se pierde. Y pedirle a un agente que resuma
# lo que hizo no lo resuelve, porque un resumen redactado por el modelo miente
# justo cuando mas falta hace -- cuando le queda poco contexto, que es cuando peor
# recuerda.
#
# Por eso este bloque NO SE REDACTA, SE DERIVA. Cada linea sale de leer un archivo:
# el estado de cada REQ, sus veredictos, la cola de aprobaciones, la rama y si el
# arbol esta limpio. Nada aqui es una opinion sobre el trabajo; todo es una lectura
# del trabajo. Si el bloque se equivoca, es que el disco dice eso.
#
# INVARIANTES
# - NUNCA bloquea. Un hook Stop que falla deja la sesion colgada, y una herramienta
#   de continuidad que impide terminar es peor que no tenerla. Sale 0 pase lo que pase.
# - IDEMPOTENTE. Reescribe entre marcadores; correrlo dos veces da lo mismo.
# - NO TOCA LO QUE ESCRIBIO UNA PERSONA, y esto tiene DOS MITADES porque una de ellas se
#   midio falsa. SI: fuera de los marcadores no se modifica nada; el bloque se anade al
#   final si no existia; si lo de fuera no se puede LEER no se escribe nada; y cada parada
#   publica por un temporal PROPIO DE SU PROCESO, asi que dos paradas simultaneas no se
#   pisan (hasta 1.32.0 el temporal tenia nombre fijo y por ahi se perdio texto humano
#   1 de 25 vueltas del banco: H-12/SEC-015, cerrado en REQ-015). NO: no hay
#   serializacion ni orden entre paradas simultaneas --gana la ultima que publica, y es
#   conforme porque el bloque es derivado del mismo disco--, y si al proceso lo matan sin
#   darle salida su temporal puede sobrevivir hasta la parada siguiente, que lo retira.
# - INERTE sin `.arnes/config.json`, como los demas hooks.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

arnes_estado_derivado() {
  local destino cuerpo tmp v_plugin v_proyecto aviso_version
  local total=0 hechos=0 revision=0 progreso=0 bloqueados=0 otros=0 notas=0
  local f base linea filas='' pend_abiertas='?' rama='?' sha='?' limpio='?'

  arnes_parse_manifest_estado || return 0
  [ "$ARNES_ESTADO_ACTIVO" != "false" ] || return 0

  arnes_ruta_interna "$ARNES_ESTADO_ARCHIVO" || return 0   # fuera del proyecto: no se escribe
  destino="$ARNES_PROJ/$ARNES_ESTADO_ARCHIVO"
  [ -d "${destino%/*}" ] || return 0     # sin la carpeta, no se inventa (y sin fork: sin dirname)
  arnes_dir_interno "${destino%/*}" || return 0   # contencion FISICA: un symlink no saca la escritura del proyecto

  # --- Los REQ, en UNA pasada de awk (no linea a linea en bash) ------------------
  # Antes: dos bucles `while read` en bash POR ARCHIVO (uno para Estado:, otro dentro de
  # arnes_campos_req). Con REQ de 5 lineas, como los del banco, microsegundos. Medido en
  # un proyecto real --47 REQ, 3,73 MB, uno de 244 KB--: 92 s por parada, dos veces por
  # turno. Reproducido aqui con un fixture del mismo tamano: 126 818 ms. El banco no lo
  # vio porque sus artefactos no tienen tamano.
  #
  # awk procesa los 4 MB en un solo proceso y devuelve una linea por archivo con los seis
  # campos crudos; bash normaliza 47 lineas cortas por el MISMO camino que la puerta.
  # La semantica se conserva byte a byte (Estado: primera aparicion; el resto, ultima):
  # ver hooks/campos-req.awk.
  local -a REQS=()
  for f in "$ARNES_PROJ/$ARNES_REQ_DIR"/*.md; do
    [ -f "$f" ] || continue
    case "${f##*/}" in README.md|readme.md) continue ;; esac
    # Un .md VACIO no tiene lineas, asi que awk (FNR==1) nunca lo ve y no emitiria nada:
    # desapareceria del conteo. Antes del awk contaba como "archivo sin Estado", y eso
    # se conserva contandolo aqui. Lo encontro una revision externa comparando 1.29.2
    # con 1.29.3 archivo por archivo.
    if [ ! -s "$f" ]; then notas=$((notas+1)); continue; fi
    REQS+=("$f")
  done
  local extraidos=''
  if [ "${#REQS[@]}" -gt 0 ]; then
    extraidos="$(awk -f "$DIR/campos-req.awk" "${REQS[@]}" 2>/dev/null)" || extraidos=''
  fi
  local ruta c_est c_qa c_seg c_sens c_hall c_rig est
  while IFS=$'\001' read -r ruta c_est c_qa c_seg c_sens c_hall c_rig; do
    [ -n "$ruta" ] || continue
    base="${ruta##*/}"
    arnes_norm_campo "$c_est"; arnes_veredicto "$ARNES_CAMPO"; est="$ARNES_VEREDICTO"
    # Sin `Estado:` no es un REQ, es una nota que vive en la misma carpeta. Medido:
    # el bloque decia 58 REQ y habia 57. Se cuentan aparte y se DICE.
    if [ -z "$est" ]; then notas=$((notas+1)); continue; fi
    arnes_campos_normaliza "$c_qa" "$c_seg" "$c_sens" "$c_hall" "$c_rig"
    total=$((total+1))
    case "$est" in
      "$ARNES_ESTADO_DONE") hechos=$((hechos+1)) ;;
      en-revision|en-revisión) revision=$((revision+1)) ;;
      en-progreso)            progreso=$((progreso+1)) ;;
      bloqueado)              bloqueados=$((bloqueados+1)) ;;
      *)                      otros=$((otros+1)) ;;
    esac
    # Solo lo ABIERTO va a la tabla: el bloque responde "donde quedamos".
    if [ "$est" != "$ARNES_ESTADO_DONE" ]; then
      # CELDAS RECORTADAS A 40 CARACTERES. Medido en un proyecto con 57 REQ: cuatro celdas
      # de veredicto eran el 37 % del bloque, y la mayor —1 296 caracteres sin un solo
      # espacio— ademas ROMPIA la tabla; una fila que no cabe deja de renderizarse como
      # fila, asi que el bloque dejaba de servir para lo unico que existe. Para saber
      # donde quedamos basta ver que la maquina lee `aprobadoconlacondicion…` y no
      # `aprobado`.
      #
      # EL RECORTE ES DE PRESENTACION, Y ESA ES LA INVARIANTE QUE LO HACE SEGURO: pasa
      # DESPUES del normalizador y SOLO al componer esta fila. Ningun lector —ni la
      # puerta, ni tools/arnes-lectura.sh— ve el valor recortado; si llegara a la lectura,
      # un `Hallazgos abiertos:` largo podria perder su clase bloqueante por el camino y
      # cerrar un REQ que no debia cerrarse.
      #
      # 40 es una constante y no una clave del manifiesto: el ancho de una celda no cambia
      # lo que ninguna puerta decide, y obligaria a cada proyecto a tener una opinion
      # sobre un numero que no le afecta.
      #
      # Solo las tres celdas de TEXTO LIBRE. `REQ`, `Estado` y `Rigor` son de vocabulario
      # cerrado y su longitud ya esta acotada por el vocabulario.
      #
      # Y la barra vertical del VALOR se neutraliza: en Markdown abriria una columna nueva
      # y la fila perderia la forma que este recorte viene a proteger. Se sustituye por
      # `¦` (barra partida) en vez de escaparla con `\|`, porque asi la fila conserva
      # exactamente 7 separadores y se puede contar; escapada, el caracter seguiria ahi.
      local c_qa_v c_seg_v c_hall_v
      arnes_recorta "${ARNES_QA:-—}" 40;   c_qa_v="${ARNES_CORTO//|/¦}"
      arnes_recorta "${ARNES_SEG:-—}" 40;  c_seg_v="${ARNES_CORTO//|/¦}"
      arnes_recorta "${ARNES_HALL:-—}" 40; c_hall_v="${ARNES_CORTO//|/¦}"
      filas+="| ${base%.md} | ${est:-—} | $c_qa_v | $c_seg_v | ${ARNES_RIGOR:-—} | $c_hall_v |"$'\n'
    fi
  done <<< "$extraidos"

  # --- La cola de aprobaciones ---
  # UNA sola regla, la de la puerta, en `hooks/lib.sh`. Este bloque contaba VIÑETAS y
  # la puerta contaba encabezados `###`: una entrada real valía 4 aquí y 1 allí, y el
  # número que se leía dejaba de ser el que bloquea (REQ-009). Si la cola no se puede
  # medir, se dice `sin datos`: el bloque informa y no decide, pero tampoco puede
  # afirmar un número que no midió.
  # Sin `if [ -f ]`: un proyecto SIN archivo de cola no tiene aprobaciones pendientes, y
  # eso es un 0 medido, no un `?`. La funcion ya distingue «no hay archivo» (0) de «hay
  # archivo y no se pudo leer» (sin datos).
  if arnes_cola_pendientes "$ARNES_PROJ/$ARNES_PENDING_REL"; then pend_abiertas="$ARNES_COLA"
  else pend_abiertas='sin datos'; fi

  # --- Git: unos pocos forks, y solo en una parada de agente (no en cada Edit) ---
  #
  # Si git no puede responder --no hay repo, no esta instalado-- el estado del arbol
  # es DESCONOCIDO, y eso es lo que se escribe. No "limpio" ni "con cambios": las dos
  # serian afirmar un hecho que no se tiene. Es la misma regla que el resto del arnes
  # aplica a los valores que no entiende, y aqui costaria igual de barato equivocarse.
  rama='(sin repositorio)'; sha='—'; limpio='desconocido'
  if command -v git >/dev/null 2>&1 && git -C "$ARNES_PROJ" rev-parse --git-dir >/dev/null 2>&1; then
    rama="$(git -C "$ARNES_PROJ" rev-parse --abbrev-ref HEAD 2>/dev/null)" || rama='?'
    sha="$(git -C "$ARNES_PROJ" rev-parse --short HEAD 2>/dev/null)" || sha='?'
    if git -C "$ARNES_PROJ" diff --quiet 2>/dev/null && git -C "$ARNES_PROJ" diff --cached --quiet 2>/dev/null; then
      limpio='limpio'
    else
      limpio='CON CAMBIOS SIN COMITEAR'
    fi
  fi

  # --- Version instalada, visible en cada parada -------------------------------
  # Un proyecto real corrio 1.13.0 durante un MES con 1.24.0 publicada, sin ninguna
  # senal: el plugin no se actualiza solo. No se consulta la red --un hook que hace
  # DNS puede colgar una parada-- pero SI se ensena lo que es gratis: la version
  # instalada y la que el proyecto declara haber migrado. Verlo en cada sesion es lo
  # que faltaba; comparar contra el remoto es trabajo de /arnes-upgrade.
  if arnes_jq_file "$DIR/../.claude-plugin/plugin.json" -r '.version // "?"' 2>/dev/null
    then v_plugin="$ARNES_JQ"; else v_plugin='?'; fi
  if arnes_jq_file "$ARNES_MANIFEST" -r '.arnes_version // ""' 2>/dev/null
    then v_proyecto="$ARNES_JQ"; else v_proyecto=''; fi
  aviso_version="**Arnés:** plugin instalado \`$v_plugin\`"
  if [ -n "$v_proyecto" ] && [ "$v_proyecto" != "$v_plugin" ]; then
    aviso_version+=" · el proyecto declara \`$v_proyecto\` — **migración pendiente** (\`/arnes-upgrade\`)"
  fi

  # --- El bloque ---
  cuerpo="<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — $(date '+%Y-%m-%d %H:%M')

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** \`$rama\` @ \`$sha\` — $limpio
$aviso_version
**Aprobaciones pendientes:** $pend_abiertas
**REQ:** $total — completado $hechos · en-revisión $revision · en-progreso $progreso · bloqueado $bloqueados · otros $otros
**Otros archivos en \`$ARNES_REQ_DIR/\` sin \`Estado:\` (notas, no REQ):** $notas
"
  # SEC-011 — LA AVERIA SE DICE EN EL ARTEFACTO, NO SOLO EN UN stderr QUE NADIE GUARDA.
  # Mientras el manifiesto sea ilegible el enforcement esta degradado: las puertas de
  # escritura deniegan, `guard-git` cae a su lista por defecto y las rutas de este bloque
  # son las del codigo, no las del proyecto. Esa frase vale mas aqui que en un aviso que
  # se pierde con la sesion.
  if [ "${ARNES_ESTADO_MANIF_ROTO:-0}" -eq 1 ]; then
    cuerpo+="**Manifiesto ilegible: enforcement degradado** — \`.arnes/config.json\` existe y no se puede leer como objeto JSON. Las puertas de escritura DENIEGAN, \`guard-git\` aplica su lista por defecto y este bloque usa las rutas por defecto del arnes. Salida: corrige el JSON (\`jq -e . .arnes/config.json\`).
"
  fi
  # ROTACION: una seccion DECLARADA que no aparece en el documento (CA-09, QA-102).
  #
  # No se vuelve a mirar el disco ni se reimplementa la comparacion: el dato lo deja la
  # rotacion, que ya la hizo, en la misma parada y en el mismo proceso (ver hooks/stop.sh,
  # que por eso rota ANTES de derivar). Aqui solo se ensena. Si no hubo ninguna, no se
  # escribe nada: el bloque informa de lo que pasa, no de lo que no pasa.
  if [ "${ARNES_ROT_SIN_SECCION:-0}" -gt 0 ] 2>/dev/null; then
    local rot_ej="${ARNES_ROT_SIN_SECCION_EJ:-}"
    cuerpo+="**Rotación:** $ARNES_ROT_SIN_SECCION archivo(s) casan un artefacto declarado pero **no contienen la sección declarada**"
    [ -z "$rot_ej" ] || cuerpo+=" (p. ej. \`${rot_ej%%|*}\` → \`${rot_ej#*|}\`)"
    cuerpo+=" — ahí no se rota nada; la comparación del nombre es exacta. Revisa \`rotacion.artefactos[].seccion\`.
"
  fi
  # La RAMA HERMANA (QA-109): la sección declarada SÍ está, pero no tiene ni una entrada
  # reconocible. Se enseña por separado —no se suma a la de arriba— porque lo que hay que
  # corregir es distinto: allí, el nombre en el manifiesto; aquí, el formato de la sección
  # o la expectativa de rotarla.
  if [ "${ARNES_ROT_SIN_ENTRADAS:-0}" -gt 0 ] 2>/dev/null; then
    local rot_ej2="${ARNES_ROT_SIN_ENTRADAS_EJ:-}"
    cuerpo+="**Rotación:** $ARNES_ROT_SIN_ENTRADAS archivo(s) contienen la sección declarada y superan el umbral, pero **sin ninguna entrada reconocible**"
    [ -z "$rot_ej2" ] || cuerpo+=" (p. ej. \`${rot_ej2%%|*}\` → \`${rot_ej2#*|}\`)"
    cuerpo+=" — ahí tampoco se rota nada; una entrada es una línea de lista (\`- \`, \`* \`, \`### \`, \`N. \`) o una fila de datos de la tabla que ES la sección.
"
  fi
  # LA TERCERA RAMA (REQ-026 CA-08): la sección está, supera el umbral, y su estructura de
  # tabla es AMBIGUA. No se archiva nada —fail-closed— y aquí se DICE, por el mismo motivo
  # que las dos de arriba: el aviso por stderr de una parada no sobrevive a la sesión, y un
  # fail-closed que nadie ve es una sección que lleva meses sin rotar sin que nadie lo sepa.
  # Contador propio y línea propia: lo que hay que arreglar es la tabla, no el manifiesto.
  if [ "${ARNES_ROT_AMBIGUA:-0}" -gt 0 ] 2>/dev/null; then
    local rot_ej3="${ARNES_ROT_AMBIGUA_EJ:-}"
    cuerpo+="**Rotación:** $ARNES_ROT_AMBIGUA archivo(s) contienen la sección declarada y superan el umbral, pero con una **estructura de tabla ambigua**"
    [ -z "$rot_ej3" ] || cuerpo+=" (p. ej. \`${rot_ej3%%|*}\` → \`${rot_ej3#*|}\`)"
    cuerpo+=" — ahí no se archiva nada a propósito; la fila de cabecera y la separadora (\`|---|---|\`) tienen que ir seguidas y en el preámbulo de la sección.
"
  fi
  # LA CUARTA RAMA (REQ-026 CA-08 (iii) y (v)): el documento NO SE PUDO LEER ENTERO. Está aquí
  # por la misma razón que las otras tres, y por una más: es la única cuyo daño ya ocurrió en
  # abierto (`QA-026-01`: −17.697 B publicados encima de un REQ), así que es la última que
  # podría permitirse un canal que muere con la sesión. NO delega en `guard-completado`: esa
  # denegación depende de que alguien edite ese REQ y de dónde caiga el NUL, mientras que este
  # silencio no depende de nada, y un canal condicionado a un segundo suceso no es un canal.
  # Contador y línea propios: aquí no se corrige el manifiesto ni el formato de la sección, se
  # corrige EL ARCHIVO. Y el ejemplo es sólo el nombre: esta rama ocurre ANTES de saber si el
  # documento tiene la sección declarada —no se pudo leer—, así que nombrar una sección aquí
  # sería inventarse un dato que el hook no tiene.
  if [ "${ARNES_ROT_NO_MEDIBLE:-0}" -gt 0 ] 2>/dev/null; then
    local rot_ej4="${ARNES_ROT_NO_MEDIBLE_EJ:-}"
    cuerpo+="**Rotación:** $ARNES_ROT_NO_MEDIBLE archivo(s) casan un artefacto declarado y **no se pueden leer enteros** (un byte NUL los trunca, o no hay permiso de lectura)"
    [ -z "$rot_ej4" ] || cuerpo+=" (p. ej. \`$rot_ej4\`)"
    cuerpo+=" — ahí no se rota nada y el archivo no se toca: publicar una lectura a medias borraría todo lo que viniera detrás. Salida: quita el byte NUL, o arregla los permisos.
"
  fi
  # LA QUINTA RAMA (REQ-026 CA-18): el documento cambió MIENTRAS se calculaba su rotación.
  # No es un error del manifiesto ni del formato ni del archivo: es una CARRERA, y lo que hay
  # que poder ver es que la escritura ajena ganó y que por eso no se archivó nada. Línea
  # propia porque la acción que pide es distinta de las otras cuatro: aquí no hay nada que
  # corregir —el arnés hizo lo correcto— y se archivará en una parada posterior. Sin esta
  # línea, «no roté» y «roté y me comí tu cambio» se ven igual desde fuera, que es
  # exactamente como se midió `SEC-067`: rc 0 y silencio.
  if [ "${ARNES_ROT_CADUCADA:-0}" -gt 0 ] 2>/dev/null; then
    local rot_ej5="${ARNES_ROT_CADUCADA_EJ:-}"
    cuerpo+="**Rotación:** $ARNES_ROT_CADUCADA archivo(s) **cambiaron en el disco mientras se calculaba su rotación**"
    [ -z "$rot_ej5" ] || cuerpo+=" (p. ej. \`${rot_ej5%%|*}\` → \`${rot_ej5#*|}\`)"
    cuerpo+=" — no se publicó nada y se conserva la escritura ajena byte a byte: la rotación cede siempre ante un cambio posterior a su lectura, y esa sección se archivará en una parada posterior. No hay nada que corregir.
"
  fi
  if [ -n "$filas" ]; then
    cuerpo+="
_Sólo los REQ abiertos; los $hechos completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
$filas"
  fi
  cuerpo+="
<!-- ARNES:DERIVADO fin -->"

  # --- Escritura idempotente: se reemplaza entre marcadores, o se anade al final ---
  #
  # LA INVARIANTE QUE MANDA AQUI: ningun camino puede dejar el archivo peor de como estaba.
  # `docs/ESTADO.md` es el archivo de continuidad —lo unico que queda cuando el contexto se
  # pierde— y ademas contiene texto de una PERSONA fuera de los marcadores. Medido antes de
  # este arreglo, dos caminos lo destruian: (a) un byte NUL en el archivo cortaba la lectura
  # ahi mismo y todo lo que venia detras se perdia al reescribir; (b) un archivo con
  # contenido pero SIN PERMISO DE LECTURA se leia como vacio y el bloque sustituia al
  # documento entero. Los dos son la misma familia: se reescribia a partir de una lectura
  # que habia fallado. La regla es: si no se puede leer lo de fuera de los marcadores, NO SE
  # ESCRIBE NADA y se avisa. Un bloque de continuidad que no se escribe es un inconveniente;
  # uno que borra el documento es una perdida.
  # Y LA TERCERA PATA DE ESA MISMA INVARIANTE, QUE LAS DOS DE ARRIBA NO CUBRIAN: dos
  # paradas A LA VEZ. El temporal se llamaba igual siempre --se derivaba solo de la ruta
  # del destino--, asi que dos procesos escribian el mismo archivo y, tras el `mv` de uno,
  # la escritura tardia del otro caia sobre el destino desde el byte 0: exactamente donde
  # vive el texto de la persona. Medido: 1 perdida en 25 vueltas del banco (H-12/SEC-015).
  # El nombre lo forma ahora `arnes_tmp_publicacion`, propio de este proceso y junto al
  # destino (las dos condiciones de REQ-015 CA-01, que se verifican juntas).
  if ! arnes_tmp_publicacion "$destino"; then
    arnes_warn "no se pudo formar un nombre de temporal propio de este proceso ('BASHPID' vacio o no numerico): NO se escribe nada y '$ARNES_ESTADO_ARCHIVO' queda como estaba. Caer al nombre compartido reintroduciria la carrera de dos paradas simultaneas, que es como se perdio texto humano de este archivo (REQ-015)."
    return 0
  fi
  tmp="$ARNES_TMP"
  if [ -f "$destino" ]; then
    local texto='' fuera='' saltando=0
    if [ ! -r "$destino" ]; then
      arnes_warn "'$ARNES_ESTADO_ARCHIVO' existe pero no se puede leer; NO se escribe nada y el archivo queda como estaba. Reescribirlo sin haber leido lo que hay fuera de los marcadores borraria texto que no es del arnes."
      return 0
    fi
    # `read -d ''` devuelve 0 SOLO si encontro el delimitador, es decir un NUL: entonces hay
    # bytes detras que esta lectura no puede traer, y reescribir los perderia. En el caso
    # normal (sin NUL) devuelve !=0 al llegar a EOF, que es el camino de siempre.
    if IFS= read -r -d '' texto < "$destino" 2>/dev/null; then
      arnes_warn "'$ARNES_ESTADO_ARCHIVO' contiene un byte NUL: no se puede leer entero sin perder lo que hay detras, asi que NO se escribe nada y el archivo queda como estaba. Quita el NUL y el bloque volvera a derivarse."
      return 0
    fi
    # Contenido en disco pero lectura vacia: la apertura fallo entre la comprobacion y la
    # lectura. Es el mismo caso que el de arriba y se trata igual, no se adivina.
    if [ -z "$texto" ] && [ -s "$destino" ]; then
      arnes_warn "'$ARNES_ESTADO_ARCHIVO' tiene contenido pero se leyo vacio; NO se escribe nada y el archivo queda como estaba."
      return 0
    fi
    while IFS= read -r linea; do
      case "$linea" in
        '<!-- ARNES:DERIVADO inicio'*) saltando=1; continue ;;
        '<!-- ARNES:DERIVADO fin'*)    saltando=0; continue ;;
      esac
      [ "$saltando" -eq 1 ] || fuera+="$linea"$'\n'
    done <<< "$texto"
    # Se recorta la cola de lineas vacias que deja el bloque retirado.
    while [ "${fuera%$'\n\n'}" != "$fuera" ]; do fuera="${fuera%$'\n'}"; done
    arnes_estado_publica "$tmp" "$destino" "$fuera
$cuerpo"
  else
    arnes_estado_publica "$tmp" "$destino" "$cuerpo"
  fi
  return 0
}

# Publicacion: se escribe COMPLETO en un temporal y solo entonces se mueve encima.
#
# EL TEMPORAL LO NOMBRA QUIEN LLAMA, con `arnes_tmp_publicacion` (lib.sh): un nombre por
# PROCESO, junto al destino. Sigue llegando por parametro a proposito --el banco puede
# apuntar esta funcion a un temporal concreto para medir un fallo de escritura (ENOSPC)
# sin adivinar el pid del hook--, pero en produccion no hay mas de un llamador y ninguno
# construye el nombre a mano.
#
# El `mv` es lo que hace que el destino nunca quede a medias: si el temporal no se pudo
# escribir entero —disco lleno, carpeta sin permiso—, el `&&` no llega al `mv` y el
# original sigue intacto. Lo que faltaba era la otra mitad: DECIRLO y no dejar el temporal
# huerfano. Un fallo de escritura que nadie ve es el mismo problema que un guardian mudo.
arnes_estado_publica() {   # <tmp> <destino> <contenido>
  # QA-118 — EL TEMPORAL SE BORRA AUNQUE AL PROCESO LO MATEN A MITAD DE LA ESCRITURA.
  # El `rm -f` de abajo cubre el fallo que devuelve error (ENOSPC, permisos), pero NO la
  # muerte por señal: con un límite de tamaño de archivo (`ulimit -f`) el kernel manda
  # SIGXFSZ, el intérprete muere en el `printf` y el `rm` nunca corre — medido: el hook
  # salía 153 y dejaba un `ESTADO.md.arnes.tmp` a medias, sin decir nada. Un artefacto
  # huérfano al lado del archivo de continuidad es basura que alguien tendrá que
  # interpretar, justo cuando el contexto ya se perdió.
  #
  # El trap cubre las dos mitades: limpia el temporal en la salida y en las señales que
  # lo interrumpen. Y al ATENDER SIGXFSZ, la señal deja de ser mortal: `printf` devuelve
  # !=0, el `&&` no llega al `mv` —el destino sigue intacto— y el fallo sale por el mismo
  # camino que los demás: aviso propio y `return 0`. Es lo que ya prometía el resto del
  # hook: nunca bloquear una parada, nunca callar la avería.
  # La ruta viaja por una GLOBAL y el trap va en comillas simples a propósito: el cuerpo
  # se evalúa cuando la señal llega, no cuando se instala, así que `$1` ahí dentro sería
  # el parámetro de quien esté ejecutando en ese momento, y una expansión en comillas
  # dobles rompería con una ruta que llevara comillas.
  ARNES_ESTADO_TMP="$1"
  trap 'rm -f "$ARNES_ESTADO_TMP" 2>/dev/null' EXIT INT TERM XFSZ
  if printf '%s\n' "$3" > "$1" 2>/dev/null && mv -f "$1" "$2" 2>/dev/null; then
    trap - EXIT INT TERM XFSZ
    return 0
  fi
  rm -f "$1" 2>/dev/null
  trap - EXIT INT TERM XFSZ
  arnes_warn "no se pudo escribir '$ARNES_ESTADO_ARCHIVO' (¿disco lleno o carpeta sin permiso?); el archivo queda EXACTAMENTE como estaba y no se dejo ningun temporal."
  return 0
}

# Campos del manifiesto que este hook necesita. Uno solo de jq.
# EL MANIFIESTO ILEGIBLE NO PUEDE APAGAR LA CONTINUIDAD, Y MENOS EN SILENCIO (SEC-011).
#
# Antes: `arnes_jq_file … || return 1` y el bloque no se escribia, con el error crudo de jq
# por stderr como unica senal. Justo en el estado degradado —el unico en el que hace falta
# saber donde quedamos— la observabilidad que `AGENTS.md` 13 promete se apagaba. Y con un
# manifiesto VACIO era peor: jq salia 0 sin producir nada, las variables se quedaban SIN
# ASIGNAR y `set -u` mataba el hook de parada (medido: rc=1).
#
# Ahora los valores por defecto se fijan ANTES de leer nada, la lectura exige un OBJETO
# —`null`, un array o una cadena son "no se puede leer", la misma regla que
# `arnes_parse_manifest`— y si falla se DERIVA IGUAL con los defectos del codigo, se avisa
# y el bloque lo dice. Derivar no necesita el manifiesto: el bloque sale del disco.
arnes_parse_manifest_estado() {
  # Los mismos valores que declara el codigo en el resto del arnes. Asignados SIEMPRE:
  # ninguna ruta puede dejar una variable sin definir con `set -u` activo.
  ARNES_ESTADO_ARCHIVO='docs/ESTADO.md'; ARNES_ESTADO_ACTIVO='true'
  ARNES_REQ_DIR='requirements'; ARNES_PENDING_REL='PENDING_APPROVAL.md'
  ARNES_AUSENCIA_EXIGE=false
  arnes_norm_campo 'completado'; ARNES_ESTADO_DONE="$ARNES_CAMPO"
  ARNES_ESTADO_MANIF_ROTO=0
  arnes_jq_file "$ARNES_MANIFEST" -r 'if type != "object" then error("no-objeto") else . end |
    [ (.estado_derivado.archivo   // "docs/ESTADO.md"),
      # OJO con `//` en jq: trata `false` IGUAL QUE ausente, asi que
      # `.activo // true` devuelve true cuando alguien escribio false y el
      # interruptor quedaba soldado en encendido. Solo un `false` EXPLICITO apaga;
      # ausente, null o cualquier otra cosa deja el hook activo, que es el lado
      # inocuo (solo escribe un bloque derivado).
      (if .estado_derivado.activo == false then "false" else "true" end),
      (.requirements_dir          // "requirements"),
      (.estados.completado        // "completado"),
      (.pending_approval          // "PENDING_APPROVAL.md"),
      # `campos.ausencia_exige` viaja en la MISMA llamada: este bloque publica el RIGOR
      # EFECTIVO en su tabla, y sin leer la llave lo derivaria del lado HEREDADO mientras la
      # puerta lo deriva del lado que cierra — el tablero diria `estandar` donde la puerta
      # dice `critico`. Cero procesos añadidos (REQ-024 CA-07 i). DESVIACION DECLARADA:
      # este archivo no esta en el `Archivos:` de REQ-024, que lo dejo fuera porque el
      # bloque B no lo necesitaba; el bloque A si, y por un solo renglon.
      (if .campos.ausencia_exige == true then "true" else "false" end) ] | join("\n")' 2>/dev/null || ARNES_JQ=''
  # Un archivo VACIO no hace fallar a jq: no produce entrada, asi que rc=0 y la salida es
  # vacia. Rc cero no es lectura buena — es la misma trampa que ya cerro `arnes_parse_manifest`.
  # Y cuando jq falla, `ARNES_JQ` conserva el valor de la lectura ANTERIOR (aqui, la de la
  # rotacion), asi que se vacia a proposito antes de mirarlo.
  if [ -z "$ARNES_JQ" ]; then
    ARNES_ESTADO_MANIF_ROTO=1
    arnes_warn "'.arnes/config.json' existe pero no se puede leer como objeto JSON (invalido, vacio, 'null' o un array): el bloque derivado se escribe igual, con las rutas por defecto del arnes ('docs/ESTADO.md', 'requirements/', 'PENDING_APPROVAL.md') y con una linea que dice que el enforcement esta degradado. Corrige el JSON ('jq -e . .arnes/config.json')."
    return 0
  fi
  local i=0 l
  while IFS= read -r l; do
    case "$i" in
      0) ARNES_ESTADO_ARCHIVO="$l" ;;
      1) ARNES_ESTADO_ACTIVO="$l" ;;
      2) ARNES_REQ_DIR="$l" ;;
      3) arnes_norm_campo "$l"; ARNES_ESTADO_DONE="$ARNES_CAMPO" ;;
      4) ARNES_PENDING_REL="$l" ;;
      5) ARNES_AUSENCIA_EXIGE="$l" ;;
    esac
    i=$((i+1))
  done <<< "$ARNES_JQ"
  return 0
}

# Ejecutado directamente (no `source`).
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  # `|| exit 0` en TODO: una parada nunca se bloquea por este hook.
  arnes_preludio || exit 0
  arnes_estado_derivado || true
  exit 0
fi
