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
# factor esperado y la banda de la calibración (CA-03 punto 2).
#
# Uso:
#   sonda-reloj.sh --k K --r R --sujeto 'snippet' [--prep 'snippet'] [--etiqueta txt]
#   sonda-reloj.sh --k K --r R --sujeto-a 'A' --sujeto-b 'B' [--prep 'snippet']
#   sonda-reloj.sh --calibrar [--k K] [--r R] [--n N]
#
# `--prep` y los sujetos se evalúan EN ESTE PROCESO. Por eso todo nombre propio de esta
# sonda lleva prefijo `SR_`/`sr_`: un sujeto que use `i`, `l` o `s` no debe pisar nada.
set -uo pipefail

SR_T0_INV=${EPOCHREALTIME/./}
SR_PROCS=0            # contador PROPIO de subprocesos que ESTA sonda lanza (CA-08 iii)
SR_SONDA=reloj
SR_MODO=medicion
SR_ESTADO=ok
SR_MOTIVO='-'
SR_K=1; SR_R=3; SR_N=50000
SR_PREP=''; SR_PREP_B=''; SR_SUJ=''; SR_SUJ_A=''; SR_SUJ_B=''
SR_ETIQ='-'
SR_MIN=''; SR_MAX=''; SR_MIN2=''
SR_MIN_A=''; SR_MAX_A=''; SR_MIN2_A=''
SR_MIN_B=''; SR_MAX_B=''; SR_MIN2_B=''
SR_CAL_A=''; SR_CAL_B=''
SR_VIVOS=desconocido; SR_DESC=ninguna

# --- El suelo: su sede única es `requirements/README.md` § «Cómo se escribe un criterio
# que no se desmiente» (50 ms). Aquí sólo se LEE de una constante nombrada; redeclararlo
# con otro valor sería la segunda transcripción que CA-01 punto 4 prohíbe.
SR_SUELO_US=50000
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
  sr_diag "     sonda-reloj.sh --calibrar [--k K] [--r R] [--n N]"
}

sr_num() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

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

# --- CA-04 punto 1: ningún DESCENDIENTE sobrevive, en el nivel que sea --------
# No se apoya en `jobs`, que sólo lista los jobs del shell que la ejecuta: no ve los
# nietos, ni los hijos de un programa invocado. Se recorre la descendencia por `/proc`
# —con builtins, sin gastar un proceso— hasta punto fijo, así que alcanza hijo, nieto y
# más lejano. El caso medido lo exige: el envoltorio de `grep` que se resolvía a sí mismo
# NO era un proceso que la sonda lanzara, sino un descendiente del sujeto instrumentado.
sr_descendencia() {
  local sr_yo=$$ sr_cola sr_pid sr_hijo sr_tid sr_n=0 sr_linea sr_ppid sr_d
  SR_VIVOS=desconocido; SR_DESC=ninguna
  [ -d /proc ] || return 0
  # Camino barato y EXACTO: `/proc/<pid>/task/<tid>/children` da los hijos DIRECTOS, y la
  # cola de abajo cierra la transitividad — hijo, nieto y más lejano. Cuesta una lectura
  # cuando no hay ninguno, que es el caso normal, y ni un solo proceso.
  # SE ENUMERA ENTERO Y SÓLO DESPUÉS SE MATA. Al revés se pierde a los nietos: matar al
  # padre antes de leer sus hijos los reparenta y salen del recorrido — y la propiedad que
  # este criterio contrata es precisamente por DESCENDENCIA, no por hijos directos.
  local sr_vistos=''
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
    for sr_hijo in $sr_vistos; do kill -9 "$sr_hijo" 2>/dev/null || :; done
    SR_VIVOS="$sr_n"
    [ "$sr_n" -eq 0 ] || sr_diag "sonda-reloj: quedaron $sr_n descendientes vivos; se han matado (CA-04.1)."
    return 0
  fi
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
  for sr_hijo in $sr_vistos; do kill -9 "$sr_hijo" 2>/dev/null || :; done
  SR_VIVOS="$sr_n"
  [ "$sr_n" -eq 0 ] || sr_diag "sonda-reloj: quedaron $sr_n descendientes vivos; se han matado (CA-04.1)."
  return 0
}

# --- El registro: UNO por invocación, UNA línea, y nada más (CA-01 punto 2) ----
SR_EMITIDO=no
sr_emite() {
  [ "$SR_EMITIDO" = no ] || return 0
  SR_EMITIDO=si
  sr_descendencia
  local sr_us=$(( ${EPOCHREALTIME/./} - SR_T0_INV )) sr_disp=desconocido sr_acomp=desconocido
  if sr_num "${SR_MIN:-}" && sr_num "${SR_MAX:-}" && [ "${SR_MIN:-0}" -gt 0 ]; then
    sr_disp=$(( SR_MAX * 1000 / SR_MIN ))
    if [ "$sr_disp" -gt "$SR_DISP_UMBRAL" ]; then sr_acomp=si; else sr_acomp=no; fi
  fi
  printf 'sonda=%s modo=%s estado=%s motivo=%s corrida=%s invocacion=%s arbol=%s plataforma=%s carga=%s jobs=%s k=%s r=%s us=%s procesos=%s vivos=%s descendencia=%s instrumentada=%s plazo=%s plazo_origen=%s etiqueta=%s min=%s max=%s min2=%s disp=%s acompanada=%s min_a=%s max_a=%s min2_a=%s min_b=%s max_b=%s min2_b=%s razon=%s cal_a=%s cal_b=%s suelo=%s\n' \
    "$SR_SONDA" "$SR_MODO" "$SR_ESTADO" "$SR_MOTIVO" "$SR_CORRIDA" "$SR_INVOCACION" \
    "$SR_ARBOL" "$SR_PLATAFORMA" "$SR_CARGA" "$SR_JOBS" "$SR_K" "$SR_R" \
    "$sr_us" "$SR_PROCS" "$SR_VIVOS" "$SR_DESC" "$SR_INSTRUMENTADA" \
    "$SR_PLAZO" "$SR_PLAZO_ORIGEN" "$SR_ETIQ" \
    "${SR_MIN:-desconocido}" "${SR_MAX:-desconocido}" "${SR_MIN2:-desconocido}" "$sr_disp" "$sr_acomp" \
    "${SR_MIN_A:-desconocido}" "${SR_MAX_A:-desconocido}" "${SR_MIN2_A:-desconocido}" \
    "${SR_MIN_B:-desconocido}" "${SR_MAX_B:-desconocido}" "${SR_MIN2_B:-desconocido}" \
    "${SR_RAZON:-desconocido}" \
    "${SR_CAL_A:-desconocido}" "${SR_CAL_B:-desconocido}" "$SR_SUELO_US"
}
# También en los caminos de error: un campo ausente y un cero no son lo mismo (CA-04.4).
trap 'sr_emite' EXIT
trap 'SR_ESTADO=interrumpida; SR_MOTIVO=señal; sr_emite; exit 130' INT TERM

sr_falla() { SR_ESTADO="$1"; SR_MOTIVO="$2"; sr_emite; exit 1; }

[ "$SR_ESTADO" = ok ] || { sr_emite; exit 1; }
[ -n "${EPOCHREALTIME:-}" ] || sr_falla sin-reloj no-hay-EPOCHREALTIME
sr_num "$SR_K" && [ "$SR_K" -ge 1 ] || sr_falla error k-no-es-un-entero-positivo
sr_num "$SR_R" && [ "$SR_R" -ge 1 ] || sr_falla error r-no-es-un-entero-positivo
sr_num "$SR_N" && [ "$SR_N" -ge 1 ] || sr_falla error n-no-es-un-entero-positivo

# --- El camino de la medida. LA CALIBRACIÓN RECORRE ESTE MISMO (CA-03 punto 4) --
# `sr_serie` y `sr_minimo` son las ÚNICAS funciones que cronometran, y la calibración las
# usa tal cual sustituyendo SÓLO el sujeto. Un camino propio para calibrar calibraría en
# verde y mentiría sobre el sujeto real.
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

SR_RAZON=''
if [ "$SR_MODO" = calibracion ]; then
  # ---- LA CALIBRACIÓN (CA-03) --------------------------------------------------
  # (a) SUJETO SENSIBLE: un bucle aritmético puro de N vueltas. Su coste es REALMENTE
  #     lineal en N —no hay reserva de memoria, no hay realloc—, así que duplicar N
  #     duplica el coste por construcción. El APILADO DE CADENAS que se probó primero NO
  #     sirve: es superlineal por el realloc y dio 2,048 y 2,566 en dos corridas del mismo
  #     sujeto (DEV-021-04). Lo que se cambia es el sujeto, nunca la banda.
  # (b) SUJETO INSENSIBLE: el MISMO bucle con una cuenta FIJA, que no mira N. Factor ≈ 1.
  # La sonda publica los dos factores y NO los compara contra ninguna expectativa: eso es
  # del juez (CA-03 punto 2, CA-01 punto 3).
  #
  # POR QUÉ EL INSENSIBLE CUESTA UN TERCIO DEL SENSIBLE BASE, que no es un detalle: los
  # cuatro ejercicios que CA-03 contrata NO cuestan lo mismo —el sensible al DOBLE cuesta
  # el doble por construcción—, así que con los cuatro iguales la calibración vale
  # 1+2+1+1 = 5 mediciones y CA-08 (iii) contrata 4. Con el insensible a UN CUARTO del
  # sensible base, el coste estructural es 1+2+1/4+1/4 = 3,5 mediciones: cabe en el techo
  # SIN tocarlo y sin tocar la banda. Es lo único de la forma del sujeto que decide un
  # techo, y por eso se dice aquí. El suelo de 50 ms se le aplica al INSENSIBLE, que es el
  # ejercicio más barato, así que es él quien fija cuánto puede bajar `--n`.
  SR_SENS_1='for ((SR_CAL_I = 0; SR_CAL_I < SR_CAL_N; SR_CAL_I++)); do :; done'
  SR_CAL_FIJO=$(( SR_N / 4 ))
  [ "$SR_CAL_FIJO" -ge 1 ] || SR_CAL_FIJO=1
  SR_INSENS='for ((SR_CAL_I = 0; SR_CAL_I < SR_CAL_FIJO; SR_CAL_I++)); do :; done'
  # Cuatro ejercicios del sujeto —el par sensible/insensible en dos tamaños—, ni uno más:
  # es lo que CA-03 contrata y lo que hace que CA-08 (iii) tenga un techo ESTRUCTURAL.
  SR_CAL_N="$SR_N";         sr_minimo "$SR_SENS_1" A; SR_A1="$SR_MIN"; SR_A1MAX="$SR_MAX"; SR_A1MIN2="$SR_MIN2"
  SR_CAL_N=$(( SR_N * 2 )); sr_minimo "$SR_SENS_1" U; SR_A2="$SR_MIN"; SR_A2MAX="$SR_MAX"
  SR_CAL_N="$SR_N";         sr_minimo "$SR_INSENS" B; SR_B1="$SR_MIN"; SR_B1MAX="$SR_MAX"; SR_B1MIN2="$SR_MIN2"
  SR_CAL_N=$(( SR_N * 2 )); sr_minimo "$SR_INSENS" U; SR_B2="$SR_MIN"; SR_B2MAX="$SR_MAX"
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
