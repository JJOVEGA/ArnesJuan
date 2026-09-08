#!/usr/bin/env bash
# sonda-reloj.sh — el coste TEMPORAL de un sujeto repetido (REQ-021, CA-02).
#
# SE INVOCA, NO SE HACE `source` (CA-01 punto 1). Corriendo en su propio proceso,
# `$BASHPID` deja de hacer falta y el defecto que dos comisiones cometieron —`$BASHPID`
# dentro de `$( )`, que devuelve el PID del subshell de la sustitución— deja de ser
# EXPRESABLE, no sólo de estar prohibido.
#
# EL ESTADÍSTICO LO IMPONE LA SONDA, NO QUIEN LA LLAMA (CA-02). Mide r series de k
# repeticiones y publica el MÍNIMO. No hay ninguna vía para pedir la media: la regla ya
# estaba escrita y se incumplió dos veces en catorce días.
#
# NO DICTA VEREDICTO (CA-01 punto 3). Emite UN registro de una línea `clave=valor` por la
# salida estándar y nada más; todo diagnóstico va por la salida de error. Quien juzga es el
# ayudante de veredicto de `tests/escenarios/hooks/run.sh`, que es también donde viven el
# factor esperado, la banda de la calibración y el TESTIGO de la mitad discordante
# (CA-03 puntos 1 y 2, CA-03 (a.2)).
#
# Uso:
#   sonda-reloj.sh --k K --r R --sujeto 'snippet' [--prep 'snippet'] [--etiqueta txt]
#   sonda-reloj.sh --k K --r R --sujeto-a 'A' --sujeto-b 'B' [--prep 'snippet']
#   sonda-reloj.sh --calibrar --disc-sujeto 'snippet' [--k K] [--r R] [--n N]
#
# EL SUJETO DISCORDANTE DE LA CALIBRACIÓN LO FIJA QUIEN JUZGA, y por eso es OBLIGATORIO en
# `--calibrar` (CA-03 (a.3) condición 4). Esta sonda no lo dimensiona y no lo declara en su
# registro: recibe el snippet y publica LO QUE MIDIÓ al ejercerlo.
#
# `--prep` y los sujetos se evalúan EN ESTE PROCESO. Por eso todo nombre propio de esta
# sonda lleva prefijo `SR_`/`sr_`: un sujeto que use `i`, `l` o `s` no debe pisar nada.
set -uo pipefail

SR_T0_INV=${EPOCHREALTIME/./}
# PROCESOS: `no-aplica`, y NO un cero (QA-021-07). Hasta la vuelta 1 este campo salía de un
# contador que NUNCA se incrementaba: 121 forks reales del sujeto contra `procesos=0`
# publicado, y la mitad en procesos de CA-08 (iii) se calculaba como 0/0 y salía `0,000×`
# —PASA en vacío—. Contarlos DE VERDAD exigiría envoltorios en el `PATH`, y una muestra
# MIXTA —reloj y conteo en la misma pasada— no es publicable (CA-02 punto 5); contarlos con
# el oráculo de forks del núcleo mete ruido AJENO en un campo publicado, que es lo que
# QA-021-03 ya obligó a retirar. Así que se dice: un cero y un «no aplica» no son lo mismo,
# que es la doctrina de CA-01 punto 5 aplicada al propio registro.
SR_PROCS=no-aplica
SR_SONDA=reloj
SR_MODO=medicion
SR_ESTADO=ok
SR_MOTIVO='-'
SR_K=1; SR_R=3; SR_N=0
SR_PREP=''; SR_PREP_B=''; SR_SUJ=''; SR_SUJ_A=''; SR_SUJ_B=''
SR_ETIQ='-'
SR_MIN=''; SR_MAX=''; SR_MIN2=''
SR_MIN_A=''; SR_MAX_A=''; SR_MIN2_A=''
SR_MIN_B=''; SR_MAX_B=''; SR_MIN2_B=''
SR_CAL_A=''; SR_CAL_B=''
SR_CAL_N=''; SR_CAL_NS=''
SR_DISC_PARAM=''; SR_DISC_SUJ=''; SR_DISC_OBS=''; SR_DISC_ESTADO='-'
SR_VIVOS=desconocido; SR_DESC=ninguna
SR_FOTO=''

# --- El suelo: su sede única es `requirements/README.md` § «Cómo se escribe un criterio
# que no se desmiente» (50 ms). Aquí sólo se LEE de una constante nombrada; redeclararlo
# con otro valor sería la segunda transcripción que CA-01 punto 4 prohíbe.
SR_SUELO_US=50000
# CA-03 (c): EL TAMAÑO DE CADA MITAD SE DERIVA DEL SUELO MEDIDO EN LA MISMA CORRIDA, y
# nunca de un absoluto escrito a mano. El margen es el número de veces el suelo que cada
# mitad tiene que superar; es OPERATIVO y sólo puede SUBIR.
# Medido (QA-021-06) lo que costaba el absoluto: con `ARNES_SONDA_CAL_N=200000` fijo, el
# insensible quedaba a 1,4× del suelo, el ruido del planificador dominaba y 5 de 30
# calibraciones caían fuera de banda —2 con la máquina en reposo—, cada una enrojeciendo la
# puerta requerida de `main`. En una máquina bastante más rápida el mismo absoluto habría
# dicho `suelo` y el banco habría salido rojo hasta que alguien subiera un env.
SR_CAL_MARGEN=${ARNES_SONDA_CAL_MARGEN:-4}
# El sondeo con el que se deriva el tamaño: un bloque PEQUEÑO del mismo sujeto, medido por
# EL MISMO CAMINO. Cuesta ~3 ms frente a los ~200 ms de una unidad de sujeto, así que no
# mueve el techo de CA-08 (iii) —que además lo mediría si lo moviera—. Va PRIMERO también
# porque calienta: el `cal_a=1,093` que QA midió en frío era la primera invocación pagando
# páginas y caché dentro del numerador de un factor.
SR_CAL_SONDEO=2000
# Umbral de dispersión (máximo/mínimo, en milésimas) por encima del cual la medida se
# marca como ACOMPAÑADA (CA-06 punto 2). OPERATIVO: se baja con la medición.
SR_DISP_UMBRAL=${ARNES_SONDA_DISP_UMBRAL:-1250}
# Plazo de ARRANQUE (CA-04 punto 2), en segundos, con su origen: no se deriva de ninguna
# medición porque en la primera repetición todavía no hay ninguna —eso es circular, y la
# primera repetición es exactamente donde colgó el envoltorio recursivo de 1.32.1—. Techo
# OPERATIVO: se baja con la medición.
SR_PLAZO=${ARNES_SONDA_PLAZO:-300}
SR_PLAZO_ORIGEN=arranque

sr_diag() { printf '%s\n' "$*" >&2; }

sr_uso() {
  sr_diag "uso: sonda-reloj.sh --k K --r R --sujeto 'snippet' [--prep 'snippet']"
  sr_diag "     sonda-reloj.sh --k K --r R --sujeto-a A --sujeto-b B [--prep 'snippet']"
  sr_diag "     sonda-reloj.sh --calibrar --disc-sujeto 'snippet' [--k K] [--r R] [--n N]"
}

sr_num() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# sr_lim <valor> -> SR_LIM: UN SOLO CAMPO del registro, y nunca vacío.
# QA-021-04: el registro no escapaba nada, así que un valor con un espacio dejaba de ser un
# valor y sus palabras con `=` se volvían CAMPOS —`--ref 'zzz estado=ok'` convertía un
# `estado=sin-linea-base` en `estado=ok` y el juez lo dejaba pasar como medición—; y un
# valor con un salto de línea sacaba el registro en DOS líneas, la segunda con la forma que
# el `awk` de recuento cuenta como caso: una sonda dictando veredicto (CA-01 puntos 2 y 3).
# Se traduce en vez de rechazar porque el valor viene de fuera —`--etiqueta`, `--ref`, y
# `motivo=…:<ruta>` con una ruta del árbol medido— y perder el motivo sería peor que verlo
# con guiones bajos. Sin `$( )`: una sustitución por campo es un fork por campo.
SR_LIM=''
sr_lim() { SR_LIM="${1-}"; SR_LIM="${SR_LIM//[[:space:]]/_}"; [ -n "$SR_LIM" ] || SR_LIM='-'; }

while [ "$#" -gt 0 ]; do
  case "$1" in
    --k)         SR_K="${2:-}"; shift 2 ;;
    --r)         SR_R="${2:-}"; shift 2 ;;
    --n)         SR_N="${2:-}"; shift 2 ;;
    --prep)      SR_PREP="${2:-}"; shift 2 ;;
    --prep-b)    SR_PREP_B="${2:-}"; shift 2 ;;
    --sujeto)    SR_SUJ="${2:-}"; shift 2 ;;
    --sujeto-a)  SR_SUJ_A="${2:-}"; shift 2 ;;
    --sujeto-b)  SR_SUJ_B="${2:-}"; shift 2 ;;
    --disc-sujeto) SR_DISC_SUJ="${2:-}"; shift 2 ;;
    --etiqueta)  SR_ETIQ="${2:-}"; shift 2 ;;
    --calibrar)  SR_MODO=calibracion; shift ;;
    -h|--ayuda)  sr_uso; exit 0 ;;
    *)           sr_diag "argumento no reconocido: <$1>"; sr_uso; SR_ESTADO=error; SR_MOTIVO=argumento-no-reconocido; break ;;
  esac
done

# --- CA-06 punto 1: las condiciones que la sonda PUEDE observar sin adivinar ----
# Lo que no se pueda leer va como `desconocido`, NUNCA omitido.
SR_CORRIDA="${ARNES_CORRIDA:-desconocido}"
SR_INVOCACION="$$-${SR_T0_INV}"
SR_ARBOL="${ARNES_ARBOL:-desconocido}"
SR_PLATAFORMA="${OSTYPE:-desconocido}-${HOSTTYPE:-x}-bash${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
SR_JOBS="${ARNES_JOBS:-desconocido}"
SR_CARGA=desconocido
if [ -r /proc/loadavg ]; then read -r SR_CARGA _ < /proc/loadavg 2>/dev/null || SR_CARGA=desconocido; fi
[ -n "$SR_CARGA" ] || SR_CARGA=desconocido

# --- CA-04 punto 1: la MARCA que hace visible al descendiente REPARENTADO ------
# QA-021-05: recorrer `/proc/<pid>/task/<tid>/children` hasta punto fijo tiene EXACTAMENTE
# la tercera ceguera que el criterio nombra —«ni lo que quedó reparentado»—: en cuanto un
# padre intermedio muere, el descendiente pasa a init y SALE del recorrido. Medido en tres
# formas (`( ( sleep 300 & ) & )`, `setsid sh -c`, doble fork clásico), las tres con
# `estado=ok vivos=0` publicado y el superviviente vivo.
# El mecanismo que se elige es una MARCA DE ENTORNO única por invocación: el entorno se
# hereda a través de `fork`/`exec` y SOBREVIVE a la reparentación y al cambio de sesión, así
# que caza las tres formas donde el grupo de procesos sólo caza dos. No cuesta un proceso
# —se lee con builtins— y el recorrido se acota a los PIDs que NO existían al arrancar, así
# que en la salida normal son unos pocos archivos.
SR_MARCA="arnes-sonda-reloj-$$-${SR_T0_INV}"
export ARNES_SONDA_MARCA="$SR_MARCA"

# --- CA-02 punto 5: el reloj NO se toma bajo instrumentación ------------------
# «Un envoltorio por proceso mide el envoltorio.» Una muestra MIXTA —reloj y conteo de
# procesos en la misma pasada— no es publicable: mediría los envoltorios y CA-08 (ii)
# quedaría contratando una razón contaminada. `sonda-procesos.sh` exporta esta marca
# mientras instrumenta, así que la sonda de reloj sabe que no debe publicar número.
SR_INSTRUMENTADA=no
if [ -n "${ARNES_SONDA_INSTRUMENTANDO:-}" ]; then
  SR_INSTRUMENTADA=si
  SR_ESTADO=mixta; SR_MOTIVO=reloj-bajo-instrumentacion
  sr_diag "sonda-reloj: hay instrumentación de procesos activa (ARNES_SONDA_INSTRUMENTANDO);"
  sr_diag "             una muestra mixta mediría los envoltorios y no es publicable (CA-02.5)."
fi

# --- CA-04 puntos 4 y 5: PATH acotado y sin componentes vacíos ni relativos ----
# Cualquier componente vacío (`::`, un `:` final) o relativo (`.`) pone el DIRECTORIO DE
# TRABAJO delante de los binarios reales. Se comprueba la PROPIEDAD, no una lista.
sr_path_sano() {
  local sr_resto="${PATH:-}" sr_tramo
  case "$sr_resto" in ''|*::*|:*|*:) return 1 ;; esac
  while [ -n "$sr_resto" ]; do
    sr_tramo="${sr_resto%%:*}"
    case "$sr_tramo" in /*) ;; *) return 1 ;; esac
    [ "$sr_tramo" = "$sr_resto" ] && break
    sr_resto="${sr_resto#*:}"
  done
  return 0
}
if [ "$SR_ESTADO" = ok ] && ! sr_path_sano; then
  SR_ESTADO=path-inseguro; SR_MOTIVO=path-con-componente-vacio-o-relativo
  sr_diag "sonda-reloj: el PATH tiene un componente vacío o relativo; el directorio de trabajo"
  sr_diag "             quedaría delante de los binarios reales (CA-04.5)."
fi

# sr_foto — los PIDs que ya existían al arrancar. Es sólo una ACOTACIÓN de coste: lo que
# decide quién muere es la marca, que es única por invocación.
sr_foto() {
  local sr_d
  SR_FOTO=' '
  [ -d /proc ] || return 0
  for sr_d in /proc/[0-9]*; do SR_FOTO="$SR_FOTO${sr_d#/proc/} "; done
}

# --- CA-04 punto 1: ningún DESCENDIENTE sobrevive, en el nivel que sea --------
# No se apoya en `jobs`, que sólo lista los jobs del shell que la ejecuta: no ve los
# nietos, ni los hijos de un programa invocado, ni lo que quedó reparentado. Se usan DOS
# recorridos complementarios, los dos con builtins y sin gastar un proceso:
#   (1) la cadena de `children` hasta punto fijo —exacta y barata mientras la cadena esté
#       intacta: alcanza hijo, nieto y más lejano—;
#   (2) la MARCA de entorno entre los procesos que no existían al arrancar —lo que la (1)
#       no puede ver: el reparentado y el que se fue a otra sesión (QA-021-05)—.
# SE ENUMERA ENTERO Y SÓLO DESPUÉS SE MATA. Al revés se pierde a los nietos: matar al padre
# antes de leer sus hijos los reparenta y salen del recorrido — y la propiedad que este
# criterio contrata es precisamente por DESCENDENCIA, no por hijos directos.
sr_descendencia() {
  local sr_yo=$$ sr_cola sr_pid sr_hijo sr_tid sr_n=0 sr_linea sr_ppid sr_d sr_v
  local sr_vistos='' sr_por_marca=0
  SR_VIVOS=desconocido; SR_DESC=ninguna
  [ -d /proc ] || return 0
  # (1) La cadena de `children`.
  if [ -r "/proc/$sr_yo/task/$sr_yo/children" ]; then
    SR_DESC=proc
    sr_cola=" $sr_yo "
    while [ -n "${sr_cola// /}" ]; do
      sr_pid="${sr_cola## }"; sr_pid="${sr_pid%% *}"
      sr_cola="${sr_cola#* $sr_pid }"; sr_cola=" $sr_cola"
      for sr_tid in /proc/"$sr_pid"/task/[0-9]*; do
        [ -r "$sr_tid/children" ] || continue
        sr_linea=''
        # SIN `|| continue`, y no es estilo: `/proc/<pid>/task/<tid>/children` NO termina en
        # salto de línea, así que `read` DEJA LA VARIABLE PUESTA y devuelve 1. Con la guarda
        # en el código de salida la lista se descartaba siempre y `vivos` salía 0 con la
        # descendencia viva — un cero plausible, que es exactamente el defecto que este
        # criterio existe para cerrar (medido al escribir esta sonda).
        read -r sr_linea < "$sr_tid/children" 2>/dev/null || :
        [ -n "$sr_linea" ] || continue
        for sr_hijo in $sr_linea; do
          sr_num "$sr_hijo" || continue
          case " $sr_vistos " in *" $sr_hijo "*) continue ;; esac
          sr_vistos="$sr_vistos $sr_hijo"
          sr_cola="$sr_cola$sr_hijo "
          sr_n=$((sr_n + 1))
        done
      done
    done
  else
    # Respaldo: la tabla PPID entera. Más cara, pero la propiedad es la misma y NO se apoya
    # en `jobs`, que sólo ve los jobs del shell que la ejecuta.
    declare -A SR_HIJOS_DE=()
    for sr_d in /proc/[0-9]*; do
      sr_pid="${sr_d#/proc/}"
      sr_num "$sr_pid" || continue
      [ -r "$sr_d/stat" ] || continue
      sr_linea=''
      read -r sr_linea < "$sr_d/stat" 2>/dev/null || continue
      # El campo 2 (comm) va entre paréntesis y puede llevar espacios: se corta por el
      # ÚLTIMO `) `, y a partir de ahí el primer campo es el estado y el segundo el PPID.
      sr_linea="${sr_linea##*') '}"
      sr_ppid="${sr_linea#* }"; sr_ppid="${sr_ppid%% *}"
      sr_num "$sr_ppid" || continue
      SR_HIJOS_DE[$sr_ppid]="${SR_HIJOS_DE[$sr_ppid]:-} $sr_pid"
    done
    SR_DESC=proc-ppid
    sr_cola=" $sr_yo "
    while [ -n "${sr_cola// /}" ]; do
      sr_pid="${sr_cola## }"; sr_pid="${sr_pid%% *}"
      sr_cola="${sr_cola#* $sr_pid }"; sr_cola=" $sr_cola"
      for sr_hijo in ${SR_HIJOS_DE[$sr_pid]:-}; do
        case " $sr_vistos " in *" $sr_hijo "*) continue ;; esac
        sr_vistos="$sr_vistos $sr_hijo"
        sr_cola="$sr_cola$sr_hijo "
        sr_n=$((sr_n + 1))
      done
    done
  fi
  # (2) La MARCA, entre los que no existían al arrancar. Aquí es donde aparece el
  # reparentado, que la cadena de arriba no puede ver por construcción.
  for sr_d in /proc/[0-9]*; do
    sr_pid="${sr_d#/proc/}"
    sr_num "$sr_pid" || continue
    [ "$sr_pid" = "$sr_yo" ] && continue
    case " $sr_vistos " in *" $sr_pid "*) continue ;; esac
    if [ -n "$SR_FOTO" ]; then case "$SR_FOTO" in *" $sr_pid "*) continue ;; esac; fi
    [ -r "$sr_d/environ" ] || continue
    while IFS= read -r -d '' sr_v; do
      [ "$sr_v" = "ARNES_SONDA_MARCA=$SR_MARCA" ] || continue
      sr_vistos="$sr_vistos $sr_pid"
      sr_n=$((sr_n + 1)); sr_por_marca=$((sr_por_marca + 1))
      break
    done < "$sr_d/environ" 2>/dev/null
  done
  [ "$SR_DESC" = ninguna ] || SR_DESC="$SR_DESC+marca"
  for sr_hijo in $sr_vistos; do kill -9 "$sr_hijo" 2>/dev/null || :; done
  SR_VIVOS="$sr_n"
  [ "$sr_n" -eq 0 ] || sr_diag "sonda-reloj: quedaron $sr_n descendientes vivos ($sr_por_marca sólo visibles por la marca); se han matado (CA-04.1)."
  return 0
}

# --- El registro: UNO por invocación, UNA línea, y nada más (CA-01 punto 2) ----
SR_EMITIDO=no
sr_emite() {
  [ "$SR_EMITIDO" = no ] || return 0
  SR_EMITIDO=si
  sr_descendencia
  local sr_us=$(( ${EPOCHREALTIME/./} - SR_T0_INV )) sr_disp=desconocido sr_acomp=desconocido
  local sr_motivo sr_etiq sr_corrida sr_arbol sr_carga sr_jobs
  if sr_num "${SR_MIN:-}" && sr_num "${SR_MAX:-}" && [ "${SR_MIN:-0}" -gt 0 ]; then
    sr_disp=$(( SR_MAX * 1000 / SR_MIN ))
    if [ "$sr_disp" -gt "$SR_DISP_UMBRAL" ]; then sr_acomp=si; else sr_acomp=no; fi
  fi
  # Todo valor que venga de fuera se reduce a UN campo antes de emitir (QA-021-04).
  sr_lim "$SR_MOTIVO";  sr_motivo="$SR_LIM"
  sr_lim "$SR_ETIQ";    sr_etiq="$SR_LIM"
  sr_lim "$SR_CORRIDA"; sr_corrida="$SR_LIM"
  sr_lim "$SR_ARBOL";   sr_arbol="$SR_LIM"
  sr_lim "$SR_CARGA";   sr_carga="$SR_LIM"
  sr_lim "$SR_JOBS";    sr_jobs="$SR_LIM"
  # EL REGISTRO NO DECLARA EL TAMAÑO DEL SUJETO DISCORDANTE, y su ausencia es criterio
  # (CA-03 (a.3) condición 4, CA-10 punto 1): el campo `disc_vueltas=` existió hasta esta
  # vuelta —lo decidía la sonda, `cal_n / 50`— y el juez LO LEÍA para cronometrar su propio
  # testigo, así que no lo conocía ANTES de invocarla y el tamaño salía del juzgado. El juez
  # ABORTA si el campo reaparece. `suelo=` se sigue publicando como condición de la medida
  # (CA-06), pero el juez NO decide con él: quien es juzgado no aporta la vara (condición 5).
  printf 'sonda=%s modo=%s estado=%s motivo=%s corrida=%s invocacion=%s arbol=%s plataforma=%s carga=%s jobs=%s k=%s r=%s us=%s procesos=%s vivos=%s descendencia=%s instrumentada=%s plazo=%s plazo_origen=%s etiqueta=%s min=%s max=%s min2=%s disp=%s acompanada=%s min_a=%s max_a=%s min2_a=%s min_b=%s max_b=%s min2_b=%s razon=%s cal_a=%s cal_b=%s cal_n=%s cal_margen=%s cal_ns_vuelta=%s disc_param=%s disc_obs=%s disc_estado=%s suelo=%s\n' \
    "$SR_SONDA" "$SR_MODO" "$SR_ESTADO" "$sr_motivo" "$sr_corrida" "$SR_INVOCACION" \
    "$sr_arbol" "$SR_PLATAFORMA" "$sr_carga" "$sr_jobs" "$SR_K" "$SR_R" \
    "$sr_us" "$SR_PROCS" "$SR_VIVOS" "$SR_DESC" "$SR_INSTRUMENTADA" \
    "$SR_PLAZO" "$SR_PLAZO_ORIGEN" "$sr_etiq" \
    "${SR_MIN:-desconocido}" "${SR_MAX:-desconocido}" "${SR_MIN2:-desconocido}" "$sr_disp" "$sr_acomp" \
    "${SR_MIN_A:-desconocido}" "${SR_MAX_A:-desconocido}" "${SR_MIN2_A:-desconocido}" \
    "${SR_MIN_B:-desconocido}" "${SR_MAX_B:-desconocido}" "${SR_MIN2_B:-desconocido}" \
    "${SR_RAZON:-desconocido}" \
    "${SR_CAL_A:-desconocido}" "${SR_CAL_B:-desconocido}" \
    "${SR_CAL_N:-desconocido}" "$SR_CAL_MARGEN" "${SR_CAL_NS:-desconocido}" \
    "${SR_DISC_PARAM:-desconocido}" \
    "${SR_DISC_OBS:-desconocido}" "$SR_DISC_ESTADO" "$SR_SUELO_US"
}
# También en los caminos de error: un campo ausente y un cero no son lo mismo (CA-04.4).
trap 'sr_emite' EXIT
trap 'SR_ESTADO=interrumpida; SR_MOTIVO=señal; sr_emite; exit 130' INT TERM

sr_falla() { SR_ESTADO="$1"; SR_MOTIVO="$2"; sr_emite; exit 1; }

[ "$SR_ESTADO" = ok ] || { sr_emite; exit 1; }
[ -n "${EPOCHREALTIME:-}" ] || sr_falla sin-reloj no-hay-EPOCHREALTIME
sr_num "$SR_K" && [ "$SR_K" -ge 1 ] || sr_falla error k-no-es-un-entero-positivo
sr_num "$SR_R" && [ "$SR_R" -ge 1 ] || sr_falla error r-no-es-un-entero-positivo
sr_num "$SR_N" || sr_falla error n-no-es-un-entero
sr_num "$SR_CAL_MARGEN" && [ "$SR_CAL_MARGEN" -ge 4 ] || sr_falla error el-margen-sobre-el-suelo-solo-puede-subir-de-4
sr_foto

# --- El camino de la medida. LA CALIBRACIÓN RECORRE ESTE MISMO (CA-03 punto 4) --
# `sr_serie`, `sr_minimo` y `sr_intercala` son las ÚNICAS funciones que cronometran, y la
# calibración las usa tal cual sustituyendo SÓLO el sujeto. Un camino propio para calibrar
# calibraría en verde y mentiría sobre el sujeto real.
SR_US=0
sr_serie() {   # <snippet> -> SR_US
  local sr_snip="$1" sr_a sr_b sr_rep
  sr_a=${EPOCHREALTIME/./}
  for ((sr_rep = 0; sr_rep < SR_K; sr_rep++)); do eval "$sr_snip"; done
  sr_b=${EPOCHREALTIME/./}
  SR_US=$(( sr_b - sr_a ))
}

# El plazo se comprueba entre unidades de trabajo —cada serie— y DESDE LA PRIMERA: su
# vencimiento es un resultado publicado (`estado=plazo-agotado`) con el número que sí se
# obtuvo, nunca un SKIP mudo y nunca un PASS.
sr_plazo_vencido() {
  local sr_transcurrido=$(( ( ${EPOCHREALTIME/./} - SR_T0_INV ) / 1000000 ))
  [ "$sr_transcurrido" -ge "$SR_PLAZO" ]
}

# sr_mete <muestra> — deja SR_M/SR_M2/SR_MX con la muestra dentro. El SEGUNDO mínimo va al
# lado del mínimo porque es lo que mide si el mínimo CONVERGIÓ: dos series que caen cerca
# dicen que la sonda resuelve; un mínimo solitario no dice nada. El MÁXIMO es lo que hace
# legible la dispersión sin recalcularla (CA-02 punto 3).
SR_M=''; SR_M2=''; SR_MX=''
sr_mete() {
  local sr_x="$1"
  if [ -z "$SR_M" ] || [ "$sr_x" -lt "$SR_M" ]; then SR_M2="$SR_M"; SR_M="$sr_x"
  elif [ -z "$SR_M2" ] || [ "$sr_x" -lt "$SR_M2" ]; then SR_M2="$sr_x"; fi
  if [ -z "$SR_MX" ] || [ "$sr_x" -gt "$SR_MX" ]; then SR_MX="$sr_x"; fi
}
sr_guarda() {   # <destino: A|B|U>
  case "$1" in
    A) SR_MIN_A="$SR_M"; SR_MAX_A="$SR_MX"; SR_MIN2_A="$SR_M2" ;;
    B) SR_MIN_B="$SR_M"; SR_MAX_B="$SR_MX"; SR_MIN2_B="$SR_M2" ;;
  esac
}
# sr_minimo <snippet> <destino: A|B|U> — r series, guarda mínimo, segundo mínimo y máximo.
sr_minimo() {
  local sr_snip="$1" sr_dst="$2" sr_s
  SR_M=''; SR_M2=''; SR_MX=''
  for ((sr_s = 0; sr_s < SR_R; sr_s++)); do
    sr_serie "$sr_snip"
    sr_mete "$SR_US"
    if sr_plazo_vencido; then
      sr_guarda "$sr_dst"; SR_MIN="$SR_M"; SR_MAX="$SR_MX"; SR_MIN2="$SR_M2"
      sr_falla plazo-agotado "plazo-de-${SR_PLAZO}s-agotado"
    fi
  done
  sr_guarda "$sr_dst"
  SR_MIN="$SR_M"; SR_MAX="$SR_MX"; SR_MIN2="$SR_M2"
}

# sr_intercala <A> <B> — CA-02 punto 2: con DOS sujetos las series van a, b, a, b, … dentro
# de la MISMA invocación. En bloque cada sujeto ve vecinos distintos, y la contención del
# entorno se cuela entera en la razón (QA-017-06: 1,217 en bloque frente a 1,012 intercalado).
sr_intercala() {
  local sr_a="$1" sr_b="$2" sr_s
  local sr_ma='' sr_m2a='' sr_mxa='' sr_mb='' sr_m2b='' sr_mxb=''
  for ((sr_s = 0; sr_s < SR_R; sr_s++)); do
    SR_M="$sr_ma"; SR_M2="$sr_m2a"; SR_MX="$sr_mxa"
    sr_serie "$sr_a"; sr_mete "$SR_US"
    sr_ma="$SR_M"; sr_m2a="$SR_M2"; sr_mxa="$SR_MX"
    SR_M="$sr_mb"; SR_M2="$sr_m2b"; SR_MX="$sr_mxb"
    sr_serie "$sr_b"; sr_mete "$SR_US"
    sr_mb="$SR_M"; sr_m2b="$SR_M2"; sr_mxb="$SR_MX"
    if sr_plazo_vencido; then
      SR_MIN_A="$sr_ma"; SR_MAX_A="$sr_mxa"; SR_MIN2_A="$sr_m2a"
      SR_MIN_B="$sr_mb"; SR_MAX_B="$sr_mxb"; SR_MIN2_B="$sr_m2b"
      SR_MIN="$sr_ma"; SR_MAX="$sr_mxa"; SR_MIN2="$sr_m2a"
      sr_falla plazo-agotado "plazo-de-${SR_PLAZO}s-agotado"
    fi
  done
  SR_MIN_A="$sr_ma"; SR_MAX_A="$sr_mxa"; SR_MIN2_A="$sr_m2a"
  SR_MIN_B="$sr_mb"; SR_MAX_B="$sr_mxb"; SR_MIN2_B="$sr_m2b"
  SR_MIN="$sr_ma"; SR_MAX="$sr_mxa"; SR_MIN2="$sr_m2a"
}

# CA-02 punto 4: si el mínimo de CUALQUIER serie queda por debajo del suelo, no se publica
# número — se publica `estado=suelo` CON el número que sí se obtuvo.
sr_bajo_suelo() {
  local sr_x
  for sr_x in "$@"; do
    sr_num "$sr_x" || return 0
    [ "$sr_x" -lt "$SR_SUELO_US" ] && return 0
  done
  return 1
}

# sr_bucle <vueltas> — el sujeto sintético de la calibración, en UN solo sitio: un bucle
# aritmético puro. Su coste es REALMENTE lineal en el número de vueltas —no hay reserva de
# memoria, no hay realloc—, así que duplicarlo duplica el coste POR CONSTRUCCIÓN. El
# APILADO DE CADENAS que se probó primero NO sirve: es superlineal por el realloc y dio
# 2,048 y 2,566 en dos corridas del mismo sujeto (DEV-021-04). Lo que se cambia es el
# sujeto, nunca la banda.
sr_bucle() { printf -v SR_BUCLE 'for ((SR_CAL_I = 0; SR_CAL_I < %s; SR_CAL_I++)); do :; done' "$1"; }
SR_BUCLE=''

SR_RAZON=''
if [ "$SR_MODO" = calibracion ]; then
  # ---- LA CALIBRACIÓN (CA-03) --------------------------------------------------
  # (a) SENSIBLE: el bucle con N y con 2N, INTERCALADAS (CA-02 punto 2). Antes se medían en
  #     bloque, y eso no era sólo peor estadística: la calibración recorría un camino
  #     —`sr_minimo`— que la medición de una razón NO recorre, mientras CA-03 punto 4 exige
  #     identidad de camino. Medido lo que costaba: 1,217 en bloque frente a 1,012
  #     intercalado sobre el mismo par (QA-017-06), y `cal_a` derivando 1,093–2,444 con el
  #     frío de la primera serie cayendo entero dentro de un factor (QA-021-06).
  # (b) INSENSIBLE: el MISMO bucle con una cuenta FIJA que NO mira el parámetro, medido
  #     también intercalado contra sí mismo. Factor ≈ 1.
  # (a.2) DISCORDANTE: un tercer sujeto DELIBERADAMENTE BAJO EL SUELO, cuya magnitud
  #     observada (µs) no se puede calcular a partir del parámetro. Ver abajo.
  # La sonda publica los factores y la magnitud observada, y NO los compara contra ninguna
  # expectativa NI contra el testigo: eso es del juez (CA-03 puntos 1 y 2, CA-01 punto 3).

  # El sujeto discordante es OBLIGATORIO y lo fija el juez (CA-03 (a.3) condición 4). Se
  # falla en vez de omitir la mitad discordante: omitirla en silencio sería la ausencia que
  # calla de CA-01 punto 5, y una calibración sin ella es la que pasó entera sobre una sonda
  # que no ejercía nada.
  [ -n "$SR_DISC_SUJ" ] || sr_falla error falta---disc-sujeto-el-sujeto-discordante-lo-fija-el-juez

  # --- CA-03 (c): el tamaño se DERIVA del suelo, en esta corrida ---------------
  # Se mide un bloque pequeño por el MISMO camino y se extrapola al mínimo que supere el
  # suelo por el margen declarado. El `--n` (o `ARNES_SONDA_CAL_N`) sólo puede SUBIRLO:
  # bajarlo es lo que (c) prohíbe, porque un tamaño por debajo del margen compra el techo
  # de CA-08 (iii) con la capacidad de discriminar del instrumento.
  sr_bucle "$SR_CAL_SONDEO"
  sr_minimo "$SR_BUCLE" U
  SR_CAL_SONDEO_US="$SR_MIN"
  sr_num "${SR_CAL_SONDEO_US:-}" && [ "$SR_CAL_SONDEO_US" -ge 1 ] \
    || sr_falla sin-reloj el-sondeo-del-suelo-midio-cero-no-hay-resolucion-para-derivar-el-tamano
  SR_CAL_NS=$(( SR_CAL_SONDEO_US * 1000 / SR_CAL_SONDEO ))
  SR_CAL_N=$(( SR_SUELO_US * SR_CAL_MARGEN * SR_CAL_SONDEO / SR_CAL_SONDEO_US ))
  [ "$SR_CAL_N" -ge "$SR_CAL_SONDEO" ] || SR_CAL_N="$SR_CAL_SONDEO"
  # El env sólo SUBE. Un `--n` menor que el derivado se ignora, y se dice por la salida de
  # error para que nadie crea que lo bajó.
  if [ "$SR_N" -gt "$SR_CAL_N" ]; then
    SR_CAL_N="$SR_N"
  elif [ "$SR_N" -gt 0 ]; then
    sr_diag "sonda-reloj: --n $SR_N es MENOR que el tamaño derivado del suelo ($SR_CAL_N); se ignora (CA-03 c)."
  fi

  # (a.2) LA MITAD DISCORDANTE — la procedencia del factor se acredita de forma OBSERVABLE.
  # La procedencia NO SE LEE EN EL REGISTRO: la sonda honesta y la tautológica publican el
  # mismo número (QA-021-01: `2N/N = 2000` por aritmética, con una copia que no materializaba
  # nada dando PASS). Así que se ejerce una entrada cuya MAGNITUD OBSERVADA es distinta del
  # parámetro y conocida por el juez SIN la sonda. Una sonda que MIDE publica microsegundos
  # muy por debajo del suelo y dice `disc_estado=suelo` sin factor (CA-02 punto 4); una que
  # CALCULA sin medir publica un número por encima del suelo, y ahí el juez la caza con su
  # propio cronómetro.
  #
  # EL SUJETO LLEGA DEL JUEZ Y LA SONDA NO LO DIMENSIONA (QA-021-10, CA-03 (a.3)). Hasta esta
  # vuelta lo decidía ella —`cal_n / 50`— y lo PUBLICABA, y el juez leía ese `disc_vueltas`
  # del registro para cronometrar su testigo: no lo conocía ANTES de invocarla, y parámetro y
  # testigo volvían a salir de la misma fuente. Ahora el juez deriva el tamaño con SU reloj,
  # cronometra el snippet ANTES de invocar (condición 3) y se lo pasa por `--disc-sujeto`.
  # Se mide por el MISMO camino que la medición —`sr_minimo`, CA-03 punto 4— y cuesta lo
  # mismo que antes: el término de CA-08 (iii) sigue siendo 1.
  SR_DISC_PARAM="$SR_CAL_N"
  sr_minimo "$SR_DISC_SUJ" U
  SR_DISC_OBS="$SR_MIN"
  if sr_bajo_suelo "$SR_DISC_OBS"; then SR_DISC_ESTADO=suelo; else SR_DISC_ESTADO=ok; fi

  # (a) el par SENSIBLE, intercalado: N contra 2N.
  sr_bucle "$SR_CAL_N";              SR_SENS_1="$SR_BUCLE"
  sr_bucle "$(( SR_CAL_N * 2 ))";    SR_SENS_2="$SR_BUCLE"
  sr_intercala "$SR_SENS_1" "$SR_SENS_2"
  SR_A1="$SR_MIN_A"; SR_A1MAX="$SR_MAX_A"; SR_A1MIN2="$SR_MIN2_A"
  SR_A2="$SR_MIN_B"; SR_A2MAX="$SR_MAX_B"
  # (b) el par INSENSIBLE, intercalado: la MISMA cuenta fija las dos veces.
  sr_bucle "$SR_CAL_N";              SR_INSENS="$SR_BUCLE"
  sr_intercala "$SR_INSENS" "$SR_INSENS"
  SR_B1="$SR_MIN_A"; SR_B1MAX="$SR_MAX_A"; SR_B1MIN2="$SR_MIN2_A"
  SR_B2="$SR_MIN_B"; SR_B2MAX="$SR_MAX_B"
  # `min_a`/`min_b` describen el ejercicio BASE de cada mitad —que es el que se compara con
  # el suelo—; `min`/`max` resumen la invocación entera, para que `disp` sea legible.
  SR_MIN_A="$SR_A1"; SR_MAX_A="$SR_A1MAX"; SR_MIN2_A="$SR_A1MIN2"
  SR_MIN_B="$SR_B1"; SR_MAX_B="$SR_B1MAX"; SR_MIN2_B="$SR_B1MIN2"
  SR_M=''; SR_M2=''; SR_MX=''
  sr_mete "$SR_A1"; sr_mete "$SR_A1MAX"; sr_mete "$SR_A2"; sr_mete "$SR_A2MAX"
  sr_mete "$SR_B1"; sr_mete "$SR_B1MAX"; sr_mete "$SR_B2"; sr_mete "$SR_B2MAX"
  SR_MIN="$SR_M"; SR_MAX="$SR_MX"; SR_MIN2="$SR_M2"
  if sr_bajo_suelo "$SR_A1" "$SR_A2" "$SR_B1" "$SR_B2"; then
    sr_falla suelo "serie-bajo-el-suelo-de-${SR_SUELO_US}us"
  fi
  SR_CAL_A=$(( SR_A2 * 1000 / SR_A1 ))
  SR_CAL_B=$(( SR_B2 * 1000 / SR_B1 ))
elif [ -n "$SR_SUJ_A" ] && [ -n "$SR_SUJ_B" ]; then
  [ -z "$SR_PREP" ]   || eval "$SR_PREP"
  [ -z "$SR_PREP_B" ] || eval "$SR_PREP_B"
  sr_intercala "$SR_SUJ_A" "$SR_SUJ_B"
  if sr_bajo_suelo "$SR_MIN_A" "$SR_MIN_B"; then
    sr_falla suelo "serie-bajo-el-suelo-de-${SR_SUELO_US}us"
  fi
  SR_RAZON=$(( SR_MIN_A * 1000 / SR_MIN_B ))
elif [ -n "$SR_SUJ" ]; then
  [ -z "$SR_PREP" ] || eval "$SR_PREP"
  sr_minimo "$SR_SUJ" U
  if sr_bajo_suelo "$SR_MIN"; then
    sr_falla suelo "serie-bajo-el-suelo-de-${SR_SUELO_US}us"
  fi
else
  sr_falla sin-sujeto no-se-declaro-ningun-sujeto
fi

sr_emite
exit 0
