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
# valor terminal (`completado`). Si la transición no ocurre, el hook no hace nada — salvo
# lo que no puede medir: un `Edit`/`MultiEdit` de `requirements/` cuyo documento resultante
# no puede reconstruir se DENIEGA, toque o no el estado (REQ-023 CA-13, ADR-015), y también
# el que cae sobre un archivo que no puede leer entero, y toda escritura cuyo destino no puede
# determinar (REQ-007 CA-45 y CA-47, ADR-016). «Dentro de `requirements/`» es por la identidad
# del destino, no por el texto de la ruta.
set -uo pipefail
# Directorio del propio script por expansión de parámetro. La forma habitual
# —`$(cd "$(dirname ...)" && pwd)"`— son DOS forks anidados, y en esta
# plataforma un fork cuesta más que ejecutar el binario que va dentro.
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# Ejecutado por su cuenta es un punto de entrada: R1, plazo y trampa de salida (entrada.sh, SEC-129/115).
# shellcheck source=/dev/null
[ "${BASH_SOURCE[0]}" != "$0" ] || . "$DIR/entrada.sh"
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
# el lector, que tiene que ser UNA sola (CA-A12). Una VARIANTE de la clave —escrita de otra
# forma: mayusculas, un blanco de mas, un caracter invisible, un marcador de lista— tampoco se
# lee, pero ya no se resuelve como ausencia: deja la cabecera AMBIGUA y el cierre se deniega
# antes de llegar aqui (REQ-023, SEC-047; frontera en `_arnes_clave_control`, lib.sh). Aqui
# siempre llega un documento resultante: el `Edit`/`MultiEdit` cuyo documento la puerta no
# puede reconstruir —un `old_string` que no esta LITERAL en el archivo— ya no se juzga por su
# fragmento, se DENIEGA antes, toque o no el estado (REQ-023 CA-13, ADR-015; SEC-117). Lo
# demas que no alcanza a ver no lo lee (ejemplos no exhaustivos: una continuacion sin clave,
# un homoglifo y lo que queda fuera de esa frontera, un comentario HTML de la cabecera, una
# linea bajo el primer `## `): ahi no hay promesa, y el README lo dice.
#
# Se llama SOLO en la transicion a `completado` (reabrir no pasa por aqui, CA-A08). Usa `$rel`
# y lo que publica `arnes_campos_req`. "Permitir" es `return 0`; `arnes_deny` termina.
arnes_clase_hallazgo() {
  # BYTES, NO CARACTERES, y por dos razones medidas (REQ-031 CA-A13/CA-A14, SEC-113): el techo
  # se cuenta en bytes, y en un locale UTF-8 cada `${s:i:1}` recorre la cadena desde el
  # principio, asi que leer un valor largo era CUADRATICO (60 006 bytes: 81 s, y el cliente
  # mata el hook a los 60 s — un hook muerto no deniega). `local` devuelve el locale al salir.
  local LC_ALL=C
  local techo="$ARNES_HALL_TECHO_BYTES" hall crudo_h n_hall n_crudo est prof e_ini idh id_malo clase err err_ini \
        sin_clase clase_mala clase_mala_v bloq bloq_v ci cj c p t0 trozo id_crudo visto blanco \
        pend noasc id_txt frag_h elem_h

  # CA-A12 (SEC-112): la clave REPETIDA no se resuelve eligiendo una. Para LEER, el resto de
  # claves deja ganar a la ultima; aqui eso escondia un `contrato` escrito mas arriba. Se
  # juzga ANTES que el valor, sea cual sea el de cada linea. (Al cerrar, cualquier otra clave
  # de control repetida ya denego antes, por cabecera ambigua: REQ-023. Esta repeticion, cuando
  # es la unica ambiguedad, conserva esta puerta y este motivo.)
  # APARTE, SU LIMITACION CONOCIDA Y SIN REPARAR, que no forma parte de la propiedad: SEC-118.
  # Este motivo cita cada linea repetida sin tope y `arnes_deny` lo pasa a `jq` como UN
  # argumento, cuyo limite es de BYTES (128 KiB en Linux): por encima `jq` no arranca, no se
  # emite nada y el hook sale sin decision. Lo medido, con sus condiciones (ASCII y multibyte),
  # esta en REQ-031 CA-A12 y en docs/seguridad/registro-seguridad.md, R-045 §4.
  if [ "${ARNES_HALL_N:-0}" -gt 1 ]; then
    arnes_deny "ARNES: no se puede completar '$rel': la cabecera declara 'Hallazgos abiertos:' $ARNES_HALL_N veces (${ARNES_HALL_LINEAS}), y la puerta no elige una: ni la primera ni la ultima, y no las fusiona. Deja UNA sola linea 'Hallazgos abiertos:' en la cabecera y conserva en ella todos los hallazgos, separados por comas (requirements/README.md, seccion 'Clases de hallazgo'). La puerta no reescribe el archivo."
  fi

  # CA-A13 (SEC-113): techo de tamaño, medido en BYTES sobre el valor tal como se escribio
  # (tras los dos puntos, antes de normalizar). Por encima no se interpreta y deniega. Desde
  # CA-A15 el lector (`arnes_campos_normaliza`, hooks/lib.sh) mide el techo ANTES de
  # `arnes_norm_campo`, que es cuadratico, y por encima no normaliza. El numero vive en
  # `ARNES_HALL_TECHO_BYTES` (hooks/lib.sh): es de CONTRATO, anunciado en requirements/README.md
  # (mayor valor real medido al fijarlo: 6 672 bytes); se sube con la medicion, nunca se baja.
  # APARTE, SU LIMITACION CONOCIDA Y SIN REPARAR, que no forma parte de la propiedad: SEC-115.
  # Un hook que el cliente mata por tiempo (60 s) no deniega. Medido, 255 371 bytes deniegan a
  # tiempo: 0,31 s por Edit y 1,6 s por Write (Linux/WSL2, una corrida por punto). Por encima de
  # lo medido no hay promesa (por Write, otra operacion anterior sobre el contenido crece mas que
  # linealmente; residuo en docs/PENDIENTES.md), y en Windows/MSYS no esta medido.
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

# --- Una edicion que la puerta no puede RECONSTRUIR se DENIEGA (REQ-023 CA-13, ADR-015) ---
# SEC-117, reproducido en el host real (CLI 2.1.285): un `Edit` cuyo `old_string` no esta LITERAL
# en el archivo NO necesariamente falla —el `Edit` del host normaliza las comillas tipograficas
# antes de aplicar la edicion—, asi que la herramienta puede escribir un documento que esta puerta
# no ha simulado. Hasta df550fa esa via juzgaba el FRAGMENTO y permitia si no escribia
# `estado: <terminal>`: un cierre podia no pasar por ninguna puerta. Ahora la incertidumbre no se
# convierte en permiso: se deniega, sea cual sea el `new_string` y el agente, SIN buscar ninguna
# cadena y SIN imitar la normalizacion del host (una emulacion parcial deja pasar lo que no emula,
# y la del host cambia con la version del CLI).
#
# El motivo dice QUE edicion, enseña como mucho ARNES_NO_RECONS_CITA_BYTES bytes del comienzo de su
# `old_string` —todo byte >= 0x80 y todo byte de control escapados con `%q` bajo `LC_ALL=C`, como
# el motivo de CA-01 (iii)—, y explica como hacer una edicion verificable SIN proponer otra
# herramienta. El texto fijo va en ASCII. Con la cita acotada el motivo mide unos pocos cientos de
# bytes, lejos del limite de un argumento de `jq`: este motivo no hereda SEC-118. El 80 es
# OPERATIVO (CA-13 (ii)): se cambia con entrada en el Historial. Sin procesos: expansion de
# parametros y `printf -v`. Usa `$tool` y `$rel` del llamador; `arnes_deny` termina.
ARNES_NO_RECONS_CITA_BYTES=80
arnes_deny_no_reconstruible() {   # <n.o de la edicion> <total de ediciones> <old_string> <causa>
  local LC_ALL=C n="$1" total="$2" q="$3" causa="$4" cual cita corte='' multi=''
  if [ "$tool" = "MultiEdit" ]; then
    cual="la edicion $n de $total de este MultiEdit"
    multi=" En un MultiEdit, cada old_string se copia del texto que dejan las ediciones anteriores de la misma llamada."
  else
    cual="la unica edicion de este Edit"
  fi
  if [ "${#q}" -gt "$ARNES_NO_RECONS_CITA_BYTES" ]; then
    corte=" (mide ${#q} bytes; se muestran los primeros $ARNES_NO_RECONS_CITA_BYTES)"
    q="${q:0:$ARNES_NO_RECONS_CITA_BYTES}"
  fi
  case "$q" in
    *[!" $ARNES_ESQ_LETRAS$ARNES_ESTRUCTURA_ASCII"]*) printf -v cita '%q' "$q" ;;
    *) cita="'$q'" ;;
  esac
  [ -z "$corte" ] || cita+='...'
  arnes_deny "ARNES: no se permite $cual sobre '$rel': esta puerta no puede reconstruir el documento que quedaria escrito, porque $causa. Sin ese documento no se puede saber si la edicion cierra el REQ, cambia un veredicto o no toca nada, y una puerta que no puede medir no deja pasar: la incertidumbre no se convierte en permiso (REQ-023 CA-13). El old_string de $cual es $cita$corte. Para hacer una edicion verificable: lee el archivo y repite la edicion con un old_string copiado LITERALMENTE de el, con las comillas, los guiones, los espacios y los acentos tal como estan escritos, sin retocarlos.$multi La puerta no reescribe el archivo."
}

# ⚠️ REGLA CRÍTICA DE ESTA FUNCIÓN: "permitir" se dice con `return 0`, NUNCA con
# `exit 0`. Un `exit` aquí mataría el proceso entero y el otro guardián no llegaría
# a correr — fallo abierto y en silencio, que es justo la familia de defecto que
# este arnés existe para impedir. `arnes_deny` sí termina el proceso, y eso es
# correcto: una denegación es final y no hay nada más que juzgar.
arnes_guard_completado() {
  local tool fp bash_cmd req_dir estado_done pending_rel rel d escrituras nuevo
  local disk qa seg sens rigor hall h id clase pending abiertas tmp cmd out rc acc c prof ci
  local -a piezas=()
  local modo resultante reconstruido np ne k old new ra causa done_norm est_antes est_despues
  local cita_desp est_citado cr_desp cr_linea
  local seg_antes amb intento v
  local obj existe ilegible arreglo

  # El análisis del input y del manifiesto es COMPARTIDO y memorizado: si
  # `guard-codigo` ya corrió en este mismo proceso, aquí no se vuelve a pagar.
  arnes_parse_input
  arnes_deny_entrada_ilegible   # SEC-120: a todo agente
  # SEC-120 (REQ-007 CA-47, punto 20): sin el `file_path` o el `command` como texto esta puerta no sabe
  # si la escritura cae en un REQ, y su regla alcanza a todos los agentes.
  if arnes_campo_no_texto; then
    arnes_deny_no_texto "esta puerta no puede saber si escribe en un REQ ni leer el documento que quedaria escrito" "no se permite a ningun agente; "
  fi
  # REQ-007 CA-47, punto 13: un `tool_name` con un salto de linea no identifica ninguna herramienta,
  # y se trata como una escritura no determinable por Edit/Write/MultiEdit (punto 7): esta puerta la
  # deniega a TODO agente, porque no hay archivo que leer ni documento que reconstruir. Con un retorno
  # de carro, igual (QA-023-13): el transporte retiraba el del final y `Edit␍` se leia como `Edit` aqui
  # y como otra herramienta en la segunda llamada a jq, que juzgaba un `Write` vacio y dejaba pasar el
  # cierre de un REQ en rojo.
  if [[ "$ARNES_TOOL" == *$'\n'* ]] || [ "${ARNES_TOOL_CR:-0}" = 1 ]; then
    arnes_cita_ruta "$ARNES_TOOL"; arnes_causa_herramienta
    arnes_deny "ARNES: el nombre de la herramienta de esta llamada, $ARNES_CITA_RUTA, $ARNES_CAUSA_HERR y no identifica ninguna herramienta, asi que esta puerta no puede saber si escribe en un REQ ni leer el documento que quedaria escrito: se trata como una escritura que no se puede determinar, y una puerta que no puede medir no deja pasar; no se permite a ningun agente (REQ-007 CA-47, punto 13)."
  fi
  # SEC-004 (REQ-007 CA-49 (i)): por Edit/Write/MultiEdit, un enlace en el ULTIMO componente
  # situado dentro de la raiz se deniega sea cual sea su destino. Cualquier otro enlace —un
  # directorio enlazado, uno de fuera de la raiz— lo juzga la identidad del destino, abajo.
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
      # El mismo analisis que `guard-codigo` en esta invocacion, reutilizado si ya se hizo (`arnes_escrituras_de`).
      arnes_escrituras_de "$bash_cmd"; rc=$?; escrituras="$ARNES_ESCRITURAS"
      if [ "$rc" -eq "$ARNES_RC_EXCESO" ]; then
        arnes_parse_manifest
        # Igual que en `guard-codigo`: el techo se resuelve aqui porque el detector corrio
        # en un subshell y su memorizacion no vuelve (REQ-001, QA-016).
        arnes_techo_bash
        arnes_deny "ARNES: el cuerpo sin citar de un heredoc (o el texto del comando fuera de los heredocs) es demasiado grande para analizarlo con garantia; no se analizo y no se permite. Una puerta que no puede medir no deja pasar (AGENTS.md 1): sin analisis no se puede saber si el comando toca '$ARNES_REQ_DIR'. El presupuesto de analisis vigente es de $ARNES_TECHO bytes y este comando lo supera. Salidas: heredoc CITADO (<<'EOF'), un archivo de script, o partir el comando en trozos por debajo de $ARNES_TECHO bytes. El techo se puede SUBIR en .arnes/config.json con 'limites.bash_max_analisis' (bytes), hasta un maximo de $ARNES_BASH_MAX_MANIFIESTO bytes: por encima el analisis dejaria de responder antes de que el hook muera, y un hook muerto no deniega."
      fi
      # P-023-13-A: un delimitador de heredoc con un retorno de carro, que el analizador no puede
      # seguir como el shell. Como el presupuesto, alcanza a TODOS los agentes: sin analisis no se sabe
      # si el comando toca un REQ.
      if [ "$rc" -eq "$ARNES_RC_CR" ]; then
        arnes_parse_manifest
        arnes_deny "ARNES: el comando lleva un heredoc cuyo delimitador contiene un retorno de carro. Para el shell ese retorno de carro es parte del delimitador, y el analisis de esta puerta no puede seguirlo asi: no sabria donde acaba el cuerpo ni que escribe lo que va detras, asi que no se puede saber si el comando toca '$ARNES_REQ_DIR'; no se analiza y no se permite a ningun agente. Una puerta que no puede medir no deja pasar, y el retorno de carro no se retira en silencio para juzgar otro comando (REQ-007 CA-47, punto 11). Para corregirlo, escribe el comando sin retornos de carro: lineas terminadas solo en salto de linea."
      fi
      # SEC-124 (REQ-007 CA-47, punto 18): una linea del cuerpo de un heredoc es el delimitador seguido de
      # un retorno de carro y no es la ultima del comando. Alcanza a TODOS los agentes, como el CR de arriba.
      if [ "$rc" -eq "$ARNES_RC_CUERPO_CR" ]; then
        arnes_parse_manifest
        arnes_deny "ARNES (SEC-124): dentro del cuerpo de un heredoc hay una linea que es su delimitador seguido de un retorno de carro, y no es la ultima del comando. Para bash esa linea no cierra el cuerpo, pero el retorno de carro es un dato del transporte y un shell que lo retire cerraria el cuerpo ahi y ejecutaria como orden lo que va detras, asi que no se puede saber si el comando toca '$ARNES_REQ_DIR'; esta puerta no retira el retorno de carro ni juzga otro comando: deniega la forma a cualquier agente (REQ-007 CA-47, punto 18). Para corregirlo, escribe el comando sin retornos de carro —lineas terminadas solo en salto de linea— o usa en el cuerpo otra palabra que no sea el delimitador."
      fi
      # SEC-125, LC10 (REQ-007 CA-47, punto 19, «Excepcion nombrada»): a todo agente, motivo unico.
      if [ "$rc" -eq "$ARNES_RC_LC10" ]; then arnes_parse_manifest; arnes_deny_lc10 guard-completado; fi
      # R2 (SEC-129, REQ-007 CA-68 (i)): cualquier otro codigo que 0 no es «no escribe»: el analisis no
      # concluyo. Medido en modo POSIX: rc 1 y la lista vacia, que se leia como un comando que no escribe.
      [ "$rc" -eq 0 ] || arnes_deny_rc_analizador "$rc" guard-completado
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
  #
  # «ESCRIBE EN requirements/» SE DECIDE POR LA IDENTIDAD DEL DESTINO (REQ-007 CA-47), no por su
  # texto: el host no normaliza el comando, y `sed -i … docs/../requirements/REQ-X.md` cerro un REQ
  # en el host real. Ningun atajo textual decide que un destino esta fuera —hasta 9596e39 todo lo
  # que empezaba por `/tmp/` se saltaba, y un proyecto puede vivir bajo `/tmp`—. Un destino que no
  # se puede determinar se trata como dentro, con la misma regla (CA-47, punto 7).
  if [ "$tool" = "Bash" ]; then
    # EL RECORRIDO DE DESTINOS, SOLO SI EL COMANDO PUEDE MENCIONAR EL ESTADO TERMINAL (CA-54, nota del
    # 2026-10-03, «Decision del propietario sobre la implementacion de CA-54», P-136-D). Abajo se deniega
    # solo si un destino cae en `req_dir` Y `grep` encuentra el estado terminal en el comando, y esa
    # busqueda es la misma para todos los destinos. Si es SEGURO que no lo encuentra
    # (`arnes_estado_ausente`, que lee el comando entero y solo afirma cuando puede probarlo), ningun
    # destino puede denegar y se sale por el mismo `return 0` del final del bucle. COLOCACION, que es parte
    # de la decision: el atajo omite SOLO este recorrido. El analisis del comando y todas las denegaciones
    # que esta puerta emite sin mirar destinos —presupuesto (`ARNES_RC_EXCESO`), CR del delimitador
    # (`ARNES_RC_CR`), SEC-124 (`ARNES_RC_CUERPO_CR`), LC10 (`ARNES_RC_LC10`) y el manifiesto roto— ya
    # se han emitido arriba, en el orden de v1.35.0; no se mueve ninguna por debajo de esta linea.
    arnes_estado_ausente "$bash_cmd" "$estado_done" && return 0
    while IFS= read -r d; do
      [ -n "$d" ] || continue
      arnes_identidad "$d"; arnes_id_pertenece req; rc=$?
      [ "$rc" -ne 1 ] || continue
      if grep -iqE "(^|[^a-zA-Z])${estado_done}([^a-zA-Z]|$)" <<< "$bash_cmd"; then
        if [ "$rc" -eq 2 ]; then
          arnes_cita_ruta "$d"
          arnes_deny "ARNES: este comando escribe en $ARNES_CITA_RUTA y menciona '$estado_done', y no se pudo determinar a que archivo escribe: $ARNES_ID_C. Podria ser un REQ de '$req_dir', y la transicion de estado de un REQ no puede juzgarse desde Bash; una puerta que no puede medir no deja pasar (REQ-007 CA-47). Para corregirlo, $ARNES_ID_A."
        fi
        arnes_deny "ARNES: este comando escribe en '$ARNES_ID_REL' y menciona '$estado_done'. La transicion de estado de un REQ no puede juzgarse desde Bash: las puertas A2/A3 necesitan el contenido resultante (veredictos de QA y Seguridad, cola de $pending_rel y quality gates). Hazlo con Edit/Write para que este mismo hook lo evalue (AGENTS.md 6)."
      fi
    done <<< "$escrituras"
    return 0
  fi

  # --- Via Edit/Write/MultiEdit ---
  # Dentro de `requirements_dir` POR IDENTIDAD (REQ-007 CA-47): la ruta equivalente se juzga como
  # la canonica, y la edicion no reconstruible de SEC-117 se deniega tambien por ella (REQ-023
  # CA-13). Un destino que no se puede determinar se DENIEGA a todo agente: no hay archivo que leer
  # ni documento que reconstruir (CA-45 (iii), CA-47 punto 7).
  arnes_identidad "$fp"; arnes_id_pertenece req; rc=$?
  case "$rc" in
    1) return 0 ;;
    2) arnes_cita_ruta "$fp"
       arnes_deny "ARNES: no se pudo determinar a que archivo escribe $ARNES_CITA_RUTA: $ARNES_ID_C. Sin saber que archivo es, esta puerta no puede leerlo ni reconstruir el documento que quedaria escrito, y una puerta que no puede medir no deja pasar: no se permite a ningun agente (REQ-007 CA-45 y CA-47). Para corregirlo, $ARNES_ID_A." ;;
  esac
  rel="$ARNES_ID_REL"
  # Lo que se lee es el archivo de la lectura FISICA —o el destino del enlace, ya resuelto—, nunca
  # la ruta escrita tomada desde el directorio del proceso del hook (CA-47, punto 9). Y «no existe»
  # lo dice la identidad, que resolvio el tramo existente (punto 8).
  obj="$ARNES_ID_O"; existe="$ARNES_ID_X"

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
  #
  # SEC-120 (REQ-007 CA-47, punto 20): LAS PIEZAS QUE NO SE PUEDEN TROCEAR NO SE JUZGAN. Hasta 82ceb63
  # unas ediciones que no eran una lista (cadena, numero) salian de jq como ninguna edicion, y la puerta
  # juzgaba el REQ en disco como si no cambiara; y si jq fallaba al trocear —una lista de cadenas, un
  # objeto—, su codigo de salida no se miraba y `ARNES_JQ` conservaba la lectura ANTERIOR, que se
  # troceaba como si fuera esta edicion. Ahora el filtro exige la forma —las ediciones, una lista de
  # objetos; el contenido y las cadenas de una edicion, texto o ausentes— y un fallo de jq deniega con
  # su motivo, sin citar la entrada. La misma llamada: sin procesos nuevos.
  #
  # SEC-115 (REQ-007 CA-68): la misma llamada que `arnes_jq_str`, partida en dos para poner el TECHO
  # `ARNES_PIEZAS_MAX_BYTES` entre jq y la normalizacion de transporte, que es la operacion que crece mas
  # que linealmente. Por debajo del techo, las mismas operaciones en el mismo orden que antes.
  if ! ARNES_JQ="$(jq -r '
    def texto: if . == null then "" elif type == "string" then . else error("no-texto") end;
    (if ([.tool_input | .. | strings] | join("\n") | test("[\\x00-\\x08\\x0b\\x0c\\x0e-\\x1f]"))
     then "!" else "-" end) as $ctl |
    (if   .tool_name == "Write" then ["W", (.tool_input.content | texto)]
     elif .tool_name == "Edit"  then ["E", (.tool_input.old_string | texto), (.tool_input.new_string | texto),
                                      (if .tool_input.replace_all == true then "1" else "0" end)]
     elif .tool_name == "MultiEdit" then ["E"] + [.tool_input.edits
                                      | if type == "array" then .[] else error("no-lista") end
                                      | if type == "object" then . else error("no-objeto") end
                                      | (.old_string | texto), (.new_string | texto),
                                        (if .replace_all == true then "1" else "0" end)]
     else ["W", ""] end) | [$ctl] + . | join("\u0001")' <<< "$ARNES_INPUT")"; then
    ARNES_JQ=''
    arnes_deny "ARNES: no se juzga esta edicion de '$rel': su tool_input no tiene la forma que esta puerta necesita para reconstruir el documento que quedaria escrito (las ediciones tienen que ser una lista de objetos, y el contenido y las cadenas de cada edicion, texto). Sin reconstruirlo no se puede saber si cierra el REQ ni con que veredictos, asi que no se permite a ningun agente: una puerta que no puede medir no deja pasar (REQ-007 CA-47, punto 20). Para corregirlo, envia la edicion con esa forma."
  fi
  arnes_bytes "$ARNES_JQ"
  if [ "$ARNES_BYTES" -gt "$ARNES_PIEZAS_MAX_BYTES" ]; then
    ARNES_JQ=''
    arnes_deny "ARNES: no se juzga esta escritura de '$rel': el texto que trae (el contenido del Write, o las cadenas de las ediciones) mide $ARNES_BYTES bytes y el techo de esta puerta es $ARNES_PIEZAS_MAX_BYTES bytes. Por encima, prepararlo para leerlo costaria mas de lo que la puerta puede medir antes de que el cliente la mate, y un hook muerto no deniega: una puerta que no puede medir no deja pasar, a ningun agente (REQ-007 CA-68). No es un veredicto sobre el contenido. Salidas: edita el REQ con Edit en cambios mas pequenos, o parte el documento."
  fi
  arnes_sin_cr_transporte "$ARNES_JQ"; ARNES_JQ="$ARNES_SIN_CR"
  arnes_plazo
  piezas=()
  IFS=$'\001' read -r -d '' -a piezas <<< "$ARNES_JQ" || true
  if [ "${piezas[0]:-!}" = "!" ]; then
    arnes_deny "ARNES: no se juzga esta edicion de '$rel': el tool_input trae bytes de control (C0 distintos de tabulador, salto de linea y retorno de carro). El hook trocea las piezas de la edicion con un separador que viaja dentro del propio dato, asi que un byte de control desincroniza la simulacion y el documento que se juzga deja de ser el que se escribiria. Un REQ legitimo no los lleva: quitalos y reintenta. Una puerta que no puede medir no deja pasar (AGENTS.md 1)."
  fi
  modo="${piezas[1]:-W}"

  # --- El REQ en disco: INEXISTENTE, LEGIBLE o EXISTENTE PERO ILEGIBLE (REQ-007 CA-45) -------
  # `read -d ''` se detiene en el primer NUL y devuelve el trozo (SEC-002, R-001), asi que se lee
  # con `arnes_lee_archivo`, que DICE si no pudo leer el archivo entero.
  #
  # Hasta 9596e39, con el archivo ilegible solo se denegaba la edicion que MENCIONABA el estado
  # terminal, con la premisa de que «lo que decide es la transicion». Era falso en las dos
  # direcciones (QA-023-08): decidia la mencion, y una edicion que cierra sin escribir la palabra
  # —`Estado: ado` y el `Edit` literal 'Estado: ' -> 'Estado: complet'— pasaba sin juzgarse
  # (O-11). Y no poder leer el archivo no significa que la herramienta no pueda escribirlo: medido
  # en el host (CLI 2.1.285), el `Edit` aplico una edicion sobre un REQ en UTF-16LE que este hook
  # no podia leer. Ahora:
  #   * un `Edit`/`MultiEdit` sobre un archivo ilegible NO se puede reconstruir: se DENIEGA, toque
  #     o no el estado, sin buscar ninguna cadena y sin juzgar ninguna otra regla del cierre;
  #   * un `Write` trae el documento entero y se juzga ENTERO, como posible transicion y sin tomar
  #     NADA del disco: el estado anterior se desconoce, asi que se trata como si no dijera el
  #     terminal, y veredictos, clase, rigor y sensibilidad salen solo del documento que llega.
  # Frontera sin promesa: un error de lectura a mitad del archivo, que el shell no distingue del
  # final, y un cambio del archivo entre esta lectura y la escritura (CA-47, F1).
  disk=''; ilegible=''
  if [ "$existe" = 1 ]; then
    if arnes_lee_archivo "$obj"; then
      disk="$ARNES_TEXTO"
    elif [ ! -f "$obj" ]; then
      ilegible="en esa ruta hay algo que no es un archivo regular (un directorio, un dispositivo o una tuberia)"
      arreglo="deja en esa ruta un archivo regular de texto"
    elif [ ! -r "$obj" ]; then
      ilegible="el archivo no tiene permiso de lectura"
      arreglo="devuelvele el permiso de lectura"
    else
      ilegible="el archivo contiene un byte NUL, que corta la lectura (lo lleva todo archivo en UTF-16 o UTF-32 con texto ASCII, por ejemplo las claves de la cabecera)"
      arreglo="quita el byte NUL o guarda el archivo en UTF-8"
    fi
  fi
  if [ -n "$ilegible" ] && [ "$modo" != "W" ]; then
    arnes_cita_ruta "$rel"
    arnes_deny "ARNES: no se permite esta edicion de $ARNES_CITA_RUTA: el archivo existe pero no se puede leer entero como archivo de texto —$ilegible—, asi que esta puerta no puede reconstruir el documento que quedaria escrito ni leer sus veredictos. Sin ese documento no se puede saber si la edicion cierra el REQ, cambia un veredicto o no toca nada, y una puerta que no puede medir no deja pasar, toque o no el estado (REQ-007 CA-45). Para corregirlo, deja el archivo legible entero: $arreglo. La puerta no reescribe el archivo."
  fi

  # --- El documento RESULTANTE, no los fragmentos ----------------------------------
  # FALLO EN ABIERTO medido en 1.30.1: un MultiEdit que cerraba el REQ y aprobaba SOLO
  # la linea del historial pasaba. Se concatenaban los `new_string`, y el `## ` que
  # separa cabecera de historia se quedaba en el disco: el fragmento del historial se
  # leia como cabecera. La cabecera existe en el DOCUMENTO, no en los fragmentos. Asi
  # que se aplica cada edicion al texto en disco —lo mismo que hara la herramienta— y
  # los campos se leen de lo que quedara escrito.
  #
  # Si algun `old_string` no esta LITERAL en el texto que va resultando, la puerta no puede
  # reconstruir el documento y DENIEGA (REQ-023 CA-13, ADR-015; `arnes_deny_no_reconstruible`,
  # arriba). Hasta df550fa se juzgaban los fragmentos, con la premisa de que la herramienta
  # fallaria y no escribiria nada; es falsa: el `Edit` del host normaliza las comillas
  # tipograficas antes de aplicar la edicion, y escribia un documento que esta puerta no habia
  # simulado (SEC-117, reproducido en el CLI 2.1.285). Ya no hay respaldo por fragmentos.
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
  elif [ "$np" -eq 5 ] && [ -z "${piezas[2]}" ] && [ "$existe" != 1 ]; then
    # (b) CREACION (REQ-023 CA-13 (i)): el archivo NO existe, la llamada trae UNA sola edicion
    # (np = bandera + modo + una tripleta) y su `old_string` es vacio. El documento resultante
    # es el `new_string`, y se juzga ENTERO, como el contenido de un `Write` sobre un archivo que
    # no existe. Hasta df550fa se juzgaba como fragmento: `**Estado:** completado` con QA
    # pendiente salia allow (O-3 de QA). «No existe» es el de la identidad (REQ-007 CA-47,
    # punto 8): nada en la lectura fisica, con el tramo existente resuelto. Una ruta que existe y
    # no es un archivo normal no es una creacion, y entonces no se reconstruye.
    nuevo="${piezas[3]//$'\r\n'/$'\n'}"; resultante="$nuevo"; reconstruido=1
  else
    # (a) LITERAL (REQ-023 CA-13 (i)): cada edicion, en su orden, con un `old_string` NO vacio
    # que esta literal en el texto que va resultando. La primera que no lo cumple DENIEGA, y el
    # motivo la nombra. Sin buscar cadenas en el `new_string` y sin imitar al host.
    #
    # CRLF -> LF, y SOLO eso: los proyectos en Windows guardan CRLF y la herramienta casa
    # el `old_string` con LF; si aqui no casara, la edicion se denegaria por no reconstruible
    # sobre un archivo legitimo. Los lectores de campos descuentan el resto del CR.
    #
    # POR QUE NO SE RETIRA TODO CR, que es lo que hacia hasta 1.32.1: el texto resultante
    # es lo que LEE el lector de cabecera, y ese lector escanea el rango `<!-- … -->` sobre
    # la linea cruda precisamente porque retirar un caracter puede FABRICAR un delimitador
    # (`-\r->` -> `-->`). Retirarlo aqui reintroducia la misma fabricacion un paso antes,
    # por la via del `Edit`: medido, un REQ `critico` con `-\r->` en DISCO cerraba con
    # `Seguridad: pendiente` vigente (H-01, `docs/qa/1.32.1-hallazgos.md`; CA-02 de REQ-016
    # nombra esta clase). Un CR seguido de LF es un fin de linea y se normaliza; un CR
    # suelto en mitad de una linea NO lo es, y ya no se toca aqui. Pregunta cerrada.
    resultante="${disk//$'\r\n'/$'\n'}"; reconstruido=1; ne=$(( (np - 2) / 3 ))
    # SEC-115 (REQ-007 CA-68, R-045-A §5): PRESUPUESTO DE LA BUSQUEDA. Buscar y sustituir cada `old_string`
    # cuesta, en el peor caso, |texto| x |old_string|, y es UNA operacion que el plazo no interrumpe. Se
    # acota ANTES de buscar: (documento + todos los new_string) x (todos los old_string), en bytes.
    local doc_b old_b=0
    arnes_bytes "$resultante"; doc_b=$ARNES_BYTES
    for ((k = 2; k + 2 < np; k += 3)); do
      arnes_bytes "${piezas[k]}"; old_b=$(( old_b + ARNES_BYTES ))
      arnes_bytes "${piezas[k+1]}"; doc_b=$(( doc_b + ARNES_BYTES ))
    done
    if (( doc_b * old_b > ARNES_EDIT_MAX_BUSQUEDA )); then
      arnes_deny "ARNES: no se juzga esta edicion de '$rel': buscar sus old_string en el documento costaria, en el peor caso, $doc_b x $old_b bytes, por encima del presupuesto de $ARNES_EDIT_MAX_BUSQUEDA de esta puerta; por encima no termina de medir antes de que el cliente la mate, y un hook muerto no deniega. Una puerta que no puede medir no deja pasar, a ningun agente (REQ-007 CA-68). No es un veredicto sobre la edicion. Salidas: usa un old_string mas corto (basta con el trozo que identifica el sitio) o parte la edicion."
    fi
    # k arranca en 2: piezas[0] es la bandera de bytes de control y piezas[1] el modo.
    for ((k = 2; k + 2 < np; k += 3)); do
      arnes_plazo
      old="${piezas[k]//$'\r\n'/$'\n'}"; new="${piezas[k+1]//$'\r\n'/$'\n'}"; ra="${piezas[k+2]}"
      nuevo+="$new"$'\n'
      if [ -z "$old" ] || [[ "$resultante" != *"$old"* ]]; then
        if [ "$existe" != 1 ]; then
          causa="el archivo no existe y esta llamada no es una creacion: crear un archivo es UNA sola edicion con old_string vacio y el documento entero como new_string"
        elif [ -z "$old" ]; then
          causa="su old_string esta vacio y el archivo ya existe: un old_string vacio solo describe la creacion de un archivo que no existe, no que texto se sustituye"
        elif [ "$k" -gt 2 ]; then
          causa="su old_string no esta LITERAL en el texto que dejan el archivo y las ediciones anteriores de la misma llamada"
        else
          causa="su old_string no esta LITERAL en el texto del archivo"
        fi
        arnes_deny_no_reconstruible "$(( (k - 2) / 3 + 1 ))" "$ne" "${piezas[k]}" "$causa"
      fi
      # Sustitucion literal: patron y reemplazo entre comillas, asi `*`, `[` o `&` en
      # un veredicto no significan nada (patsub_replacement esta activo en bash 5.2+).
      case "$ra" in
        1*) resultante="${resultante//"$old"/"$new"}" ;;
        *)  resultante="${resultante/"$old"/"$new"}" ;;
      esac
    done
  fi

  # --- Veredictos QA/Seguridad (anti-deriva) ---
  # Edit/MultiEdit reconstruido (o creacion): los campos son los de la cabecera del documento
  # que quedara en disco. Write: se prefiere el contenido entrante y se respalda en disco
  # (pre-edicion), porque QA/seguridad fijan su veredicto antes de la transicion a completado.
  # (Un Edit/MultiEdit sin reconstruir ya no llega aqui: CA-13 lo denego arriba.)
  # Comparar el campo de cabecera, no buscar su nombre en el fragmento: el
  # lector acepta decoración y Edit puede sustituir sólo el valor. El crudo
  # incluye la evidencia: renovar la firma también requiere QA. Una firma
  # idéntica conservada al editar prosa no es una firma nueva.
  if [ "$reconstruido" -eq 1 ]; then arnes_campos_req "$resultante" ''
  else arnes_campos_req "$disk" "$nuevo"; fi
  qa="$ARNES_QA"; seg="$ARNES_SEG"; sens="$ARNES_SENS"; rigor="$ARNES_RIGOR"; amb="$ARNES_AMBIGUA"

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
  # HAY DOCUMENTO, SIEMPRE: el contenido del `Write`, la creacion o el documento reconstruido
  # de un `Edit`/`MultiEdit`. Lo que no se puede reconstruir ya se denego arriba (REQ-023
  # CA-13), y con ello desaparecio la via de fragmentos y sus dos guardas —rango abierto y CR
  # interior leidos del FRAGMENTO—: las mismas reglas se aplican aqui sobre el documento.
  # La transicion se determina SOLO con el documento, nunca con el fragmento.
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
  # CABECERA AMBIGUA (REQ-023, ADR-014; SEC-047, QA-031-01): una VARIANTE de una clave de
  # control —la clave escrita de otra forma, que el lector no lee como tal; frontera en
  # `_arnes_clave_control`, lib.sh— o una clave de control declarada MAS DE UNA VEZ, aunque
  # diga lo mismo. La puerta no lee la variante como la clave ni elige entre declaraciones, y
  # sobre todo NO permite por la AUSENCIA que eso produciria: DENIEGA el cierre, sean cuales
  # sean los veredictos, citando las lineas. Lo publica `arnes_campos_req` sobre la cabecera
  # resultante (la del ultimo texto que leyo, que aqui es `resultante`, si no esta vacia).
  #
  # INTENTO DE CIERRE = la cabecera resultante es AMBIGUA, ALGUNA de sus lineas `Estado`
  # —la exacta, una repetida o una variante— dice el estado terminal (un `ESTADO: completado`
  # no se lee y esconderia la transicion), y el `Estado` que GOBIERNA en disco —la primera
  # declaracion exacta; si no hay ninguna, nada lo decia— NO lo decia. No se juzga nada mas:
  # reabrir o editar un REQ cuyo `Estado` que gobierna en disco ya es el terminal no se bloquea
  # (mismo alcance que el rango sin cerrar), ni una edicion cuya cabecera resultante no dice el
  # terminal en ninguna linea `Estado`. CONSECUENCIA (REQ-023 CA-01): si en disco el terminal
  # esta en una linea `Estado` que NO es la que gobierna —una variante, o una exacta que no es la
  # primera— y la que gobierna no lo dice o no existe, se deniega TODA edicion que conserve esa
  # linea mientras la cabecera siga siendo ambigua; la que la retira, la corrige o deshace la
  # ambiguedad no se deniega por esto. El `Estado` que gobierna ya esta normalizado (`est_despues`);
  # los demas se normalizan SOLO aqui, SOLO si la cabecera es ambigua y SOLO hasta encontrar
  # el terminal: es la unica lectura del valor de una variante, y solo puede denegar.
  if [ -n "$resultante" ] && [ "$amb" = 1 ] && [ "$est_antes" != "$done_norm" ]; then
    intento=0
    if [ "$est_despues" = "$done_norm" ]; then
      intento=1
    else
      for ((k = 0; k < ${#ARNES_ESTADO_OTROS[@]}; k++)); do
        v="${ARNES_ESTADO_OTROS[k]}"
        arnes_norm_campo "$v"; arnes_veredicto "$ARNES_CAMPO"
        if [ "$ARNES_VEREDICTO" = "$done_norm" ]; then intento=1; break; fi
      done
    fi
    if [ "$intento" -eq 1 ]; then
      arnes_ambigua_motivo
      # El texto fijo va en ASCII: asi NINGUN byte >= 0x80 aparece crudo en el motivo, y el
      # que lleve una linea citada sale escapado (REQ-023 CA-01 (iii)).
      arnes_deny "ARNES: no se puede completar '$rel': su cabecera es AMBIGUA para esta puerta: $ARNES_AMBIGUA_MOTIVO. Una clave de control escrita de otra forma no se lee como esa clave, y declarada mas de una vez obligaria a elegir una; la puerta no elige, no lee la variante como la clave y no permite por la AUSENCIA que eso produciria (AGENTS.md 1). Salida: escribe cada clave de control (${ARNES_CLAVES_CONTROL//|/, }) una sola vez y como la escribe la plantilla de requirements/README.md, seccion 'Veredictos de validacion'. La puerta no reescribe el archivo."
    fi
  fi
  [ "$est_despues" = "$done_norm" ] || return 0
  [ "$est_antes" != "$done_norm" ] || return 0

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
  # El plazo propio (SEC-115) se comprueba ANTES de lanzarlas: lo que tarde una gate no lo interrumpe.
  arnes_plazo
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
  arnes_preludio guardian || { ARNES_JUICIO=fin; exit 0; }
  arnes_plazo
  { arnes_guard_completado; ARNES_PUERTA_FIN=guard-completado; }
  arnes_juicio_puerta guard-completado
  arnes_emitir_avisos
  ARNES_JUICIO=fin
  exit 0
fi
