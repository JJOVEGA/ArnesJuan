#!/usr/bin/env bash
# sonda-procesos.sh — cuántos procesos gasta una invocación (REQ-021, CA-01 y CA-04).
#
# SE INVOCA, NO SE HACE `source` (CA-01 punto 1). Emite UN registro de una línea
# `clave=valor` por la salida estándar y nada más; el diagnóstico va por la salida de
# error, y el veredicto es del ayudante de `tests/escenarios/hooks/run.sh` (CA-01 punto 3).
#
# QUÉ CIERRA, MEDIDO. (a) El envoltorio de `grep` que —construido con `command -v` sobre un
# binario SOMBREADO POR UNA FUNCIÓN DE SHELL— se resolvió a sí mismo, se llamó a sí mismo y
# vivió 3 h 41 min al 99,6 % de un núcleo, falseando la línea base de otra medición. (b) El
# `jq --arg` de más de 128 KB que dejaba el JSON vacío y hacía que la curva de coste saliera
# plana y perfecta.
#
# Uso:
#   sonda-procesos.sh --sujeto 'snippet' [--prep 'snippet'] [--binarios 'jq awk grep']
#                     [--dir-trabajo DIR] [--etiqueta txt]
#   sonda-procesos.sh --calibrar [--n N] [--rastro ARCHIVO] [--binarios '...'] [--dir-trabajo DIR]
#
# El sujeto se evalúa EN ESTE PROCESO con el PATH instrumentado delante. Todo nombre propio
# de esta sonda lleva prefijo `SP_`/`sp_` para no pisar los del sujeto.
set -uo pipefail

SP_T0_INV=${EPOCHREALTIME/./}
SP_PROCS=0
SP_SONDA=procesos
SP_MODO=medicion
SP_ESTADO=ok
SP_MOTIVO='-'
SP_N=0
SP_PREP=''; SP_SUJ=''
SP_ETIQ='-'
SP_BIN_LISTA='jq awk grep sed tr date cat basename dirname mktemp wc head tail sort git'
SP_TRABAJO="${TMPDIR:-/tmp}"
SP_CUENTA=''
SP_CAL_A=''; SP_CAL_B=''
SP_CAL_N=''
SP_RASTRO=''
SP_DISC_PARAM=''; SP_DISC_VECES=''; SP_DISC_OBS=''
SP_VIVOS=desconocido; SP_DESC=ninguna
SP_DIR=''
SP_FOTO=''
SP_PLAZO=${ARNES_SONDA_PLAZO:-300}
SP_PLAZO_ORIGEN=arranque
# CA-03 (c): el tamaño de cada mitad se deriva de la RESOLUCIÓN del instrumento por un
# margen declarado, en la propia corrida, y nunca de un absoluto escrito a mano. Aquí la
# resolución NO es un suelo de ruido: es UNA INVOCACIÓN, exacta y sin dispersión —el factor
# de esta sonda salió 2,000 y 1,000 EXACTOS en todas las corridas medidas—, así que el
# tamaño derivado es el margen tal cual. El margen es OPERATIVO y sólo puede SUBIR.
SP_RESOLUCION=1
SP_CAL_MARGEN=${ARNES_SONDA_CAL_MARGEN:-4}

sp_diag() { printf '%s\n' "$*" >&2; }
sp_num() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# sp_lim <valor> -> SP_LIM: UN SOLO CAMPO del registro, y nunca vacío (QA-021-04).
# El registro no escapaba nada, así que un valor con un espacio dejaba de ser un valor y
# sus palabras con `=` se volvían CAMPOS —un `estado=ok` inyectado pisaba el estado
# verdadero y el juez lo dejaba pasar como medición—, y un valor con un salto de línea
# sacaba el registro en DOS líneas, la segunda con la forma que el `awk` de recuento cuenta
# como caso: una sonda dictando veredicto (CA-01 puntos 2 y 3). Sin `$( )`: una sustitución
# por campo es un fork por campo.
SP_LIM=''
sp_lim() { SP_LIM="${1-}"; SP_LIM="${SP_LIM//[[:space:]]/_}"; [ -n "$SP_LIM" ] || SP_LIM='-'; }

while [ "$#" -gt 0 ]; do
  case "$1" in
    --sujeto)       SP_SUJ="${2:-}"; shift 2 ;;
    --prep)         SP_PREP="${2:-}"; shift 2 ;;
    --binarios)     SP_BIN_LISTA="${2:-}"; shift 2 ;;
    --n)            SP_N="${2:-}"; shift 2 ;;
    --rastro)       SP_RASTRO="${2:-}"; shift 2 ;;
    --dir-trabajo)  SP_TRABAJO="${2:-}"; shift 2 ;;
    --etiqueta)     SP_ETIQ="${2:-}"; shift 2 ;;
    --calibrar)     SP_MODO=calibracion; shift ;;
    -h|--ayuda)
      sp_diag "uso: sonda-procesos.sh --sujeto 'snippet' [--prep 'snippet'] [--binarios '...']"
      sp_diag "     sonda-procesos.sh --calibrar [--n N] [--rastro ARCHIVO]"
      exit 0 ;;
    *) sp_diag "argumento no reconocido: <$1>"; SP_ESTADO=error; SP_MOTIVO=argumento-no-reconocido; break ;;
  esac
done

SP_CORRIDA="${ARNES_CORRIDA:-desconocido}"
SP_INVOCACION="$$-${SP_T0_INV}"
SP_ARBOL="${ARNES_ARBOL:-desconocido}"
SP_PLATAFORMA="${OSTYPE:-desconocido}-${HOSTTYPE:-x}-bash${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
SP_JOBS="${ARNES_JOBS:-desconocido}"
SP_CARGA=desconocido
if [ -r /proc/loadavg ]; then read -r SP_CARGA _ < /proc/loadavg 2>/dev/null || SP_CARGA=desconocido; fi
[ -n "$SP_CARGA" ] || SP_CARGA=desconocido

# Esta sonda SÍ instrumenta: lo declara en el registro (CA-02 punto 5). Una muestra mixta
# —reloj y conteo de procesos en la misma pasada— no es publicable, y por eso mientras el
# sujeto corre se exporta la marca que hace que `sonda-reloj.sh` se niegue a publicar.
SP_INSTRUMENTADA=si

# --- CA-04 punto 1: la MARCA que hace visible al descendiente REPARENTADO ------
# QA-021-05, medido en tres formas —`( ( sleep 300 & ) & )`, `setsid sh -c`, doble fork—:
# recorrer `children` hasta punto fijo tiene la tercera ceguera que el criterio nombra por
# su nombre («ni lo que quedó reparentado»), y las tres publicaban `estado=ok vivos=0` con
# el superviviente vivo. Una marca de ENTORNO única por invocación sobrevive a la
# reparentación Y al cambio de sesión, así que caza las tres formas donde el grupo de
# procesos sólo cazaría dos; y se lee con builtins, sin gastar un proceso.
SP_MARCA="arnes-sonda-procesos-$$-${SP_T0_INV}"
export ARNES_SONDA_MARCA="$SP_MARCA"

# --- CA-04 punto 5: el PATH no lleva componentes vacíos ni relativos -----------
sp_path_sano() {
  local sp_resto="${1:-}" sp_tramo
  case "$sp_resto" in ''|*::*|:*|*:) return 1 ;; esac
  while [ -n "$sp_resto" ]; do
    sp_tramo="${sp_resto%%:*}"
    case "$sp_tramo" in /*) ;; *) return 1 ;; esac
    [ "$sp_tramo" = "$sp_resto" ] && break
    sp_resto="${sp_resto#*:}"
  done
  return 0
}

# sp_foto — los PIDs que ya existían al arrancar. Sólo acota el coste del barrido: lo que
# decide quién muere es la marca, que es única por invocación.
sp_foto() {
  local sp_d
  SP_FOTO=' '
  [ -d /proc ] || return 0
  for sp_d in /proc/[0-9]*; do SP_FOTO="$SP_FOTO${sp_d#/proc/} "; done
}

# --- CA-04 punto 1: ningún DESCENDIENTE sobrevive, en el nivel que sea --------
# Dos recorridos complementarios, los dos con builtins: (1) la cadena de `children` hasta
# punto fijo —exacta mientras la cadena esté intacta— y (2) la MARCA entre los procesos que
# no existían al arrancar, que es lo único que ve al reparentado. Se enumera entero y sólo
# después se mata: al revés, matar al padre reparenta a los nietos y los saca del recorrido.
sp_descendencia() {
  local sp_yo=$$ sp_cola sp_pid sp_hijo sp_tid sp_n=0 sp_linea sp_ppid sp_d sp_v
  local sp_vistos='' sp_por_marca=0
  SP_VIVOS=desconocido; SP_DESC=ninguna
  [ -d /proc ] || return 0
  if [ -r "/proc/$sp_yo/task/$sp_yo/children" ]; then
    SP_DESC=proc
    sp_cola=" $sp_yo "
    while [ -n "${sp_cola// /}" ]; do
      sp_pid="${sp_cola## }"; sp_pid="${sp_pid%% *}"
      sp_cola="${sp_cola#* $sp_pid }"; sp_cola=" $sp_cola"
      for sp_tid in /proc/"$sp_pid"/task/[0-9]*; do
        [ -r "$sp_tid/children" ] || continue
        sp_linea=''
        # SIN `|| continue`: `children` no termina en salto de línea, así que `read` deja la
        # variable puesta y devuelve 1 (ver la nota en `sonda-reloj.sh`).
        read -r sp_linea < "$sp_tid/children" 2>/dev/null || :
        [ -n "$sp_linea" ] || continue
        for sp_hijo in $sp_linea; do
          sp_num "$sp_hijo" || continue
          case " $sp_vistos " in *" $sp_hijo "*) continue ;; esac
          sp_vistos="$sp_vistos $sp_hijo"; sp_cola="$sp_cola$sp_hijo "; sp_n=$((sp_n + 1))
        done
      done
    done
  else
    declare -A SP_HIJOS_DE=()
    for sp_d in /proc/[0-9]*; do
      sp_pid="${sp_d#/proc/}"
      sp_num "$sp_pid" || continue
      [ -r "$sp_d/stat" ] || continue
      sp_linea=''
      read -r sp_linea < "$sp_d/stat" 2>/dev/null || continue
      sp_linea="${sp_linea##*') '}"
      sp_ppid="${sp_linea#* }"; sp_ppid="${sp_ppid%% *}"
      sp_num "$sp_ppid" || continue
      SP_HIJOS_DE[$sp_ppid]="${SP_HIJOS_DE[$sp_ppid]:-} $sp_pid"
    done
    SP_DESC=proc-ppid
    sp_cola=" $sp_yo "
    while [ -n "${sp_cola// /}" ]; do
      sp_pid="${sp_cola## }"; sp_pid="${sp_pid%% *}"
      sp_cola="${sp_cola#* $sp_pid }"; sp_cola=" $sp_cola"
      for sp_hijo in ${SP_HIJOS_DE[$sp_pid]:-}; do
        case " $sp_vistos " in *" $sp_hijo "*) continue ;; esac
        sp_vistos="$sp_vistos $sp_hijo"; sp_cola="$sp_cola$sp_hijo "; sp_n=$((sp_n + 1))
      done
    done
  fi
  for sp_d in /proc/[0-9]*; do
    sp_pid="${sp_d#/proc/}"
    sp_num "$sp_pid" || continue
    [ "$sp_pid" = "$sp_yo" ] && continue
    case " $sp_vistos " in *" $sp_pid "*) continue ;; esac
    if [ -n "$SP_FOTO" ]; then case "$SP_FOTO" in *" $sp_pid "*) continue ;; esac; fi
    [ -r "$sp_d/environ" ] || continue
    while IFS= read -r -d '' sp_v; do
      [ "$sp_v" = "ARNES_SONDA_MARCA=$SP_MARCA" ] || continue
      sp_vistos="$sp_vistos $sp_pid"
      sp_n=$((sp_n + 1)); sp_por_marca=$((sp_por_marca + 1))
      break
    done < "$sp_d/environ" 2>/dev/null
  done
  [ "$SP_DESC" = ninguna ] || SP_DESC="$SP_DESC+marca"
  for sp_hijo in $sp_vistos; do kill -9 "$sp_hijo" 2>/dev/null || :; done
  SP_VIVOS="$sp_n"
  [ "$sp_n" -eq 0 ] || sp_diag "sonda-procesos: quedaron $sp_n descendientes vivos ($sp_por_marca sólo visibles por la marca); se han matado (CA-04.1)."
  return 0
}

SP_EMITIDO=no
sp_emite() {
  [ "$SP_EMITIDO" = no ] || return 0
  SP_EMITIDO=si
  sp_descendencia
  # CA-04 punto 4: el directorio de envoltorios se retira en la MISMA salida, INCLUIDOS los
  # caminos de error. Hoy los dos caminos medidos lo dejaban detrás: la salida
  # ENVOLTORIO-RECURSIVO con rc 9 y el fallo de `chmod` con rc 1. Va DESPUÉS del barrido:
  # el `rm` hereda la marca y no debe contarse como descendiente superviviente.
  if [ -n "$SP_DIR" ] && [ -d "$SP_DIR" ]; then
    rm -rf "$SP_DIR" 2>/dev/null || :
    SP_PROCS=$((SP_PROCS + 1))
  fi
  local sp_us=$(( ${EPOCHREALTIME/./} - SP_T0_INV ))
  local sp_motivo sp_etiq sp_corrida sp_arbol sp_carga sp_jobs
  sp_lim "$SP_MOTIVO";  sp_motivo="$SP_LIM"
  sp_lim "$SP_ETIQ";    sp_etiq="$SP_LIM"
  sp_lim "$SP_CORRIDA"; sp_corrida="$SP_LIM"
  sp_lim "$SP_ARBOL";   sp_arbol="$SP_LIM"
  sp_lim "$SP_CARGA";   sp_carga="$SP_LIM"
  sp_lim "$SP_JOBS";    sp_jobs="$SP_LIM"
  printf 'sonda=%s modo=%s estado=%s motivo=%s corrida=%s invocacion=%s arbol=%s plataforma=%s carga=%s jobs=%s k=1 r=1 us=%s procesos=%s vivos=%s descendencia=%s instrumentada=%s plazo=%s plazo_origen=%s etiqueta=%s cuenta=%s cal_a=%s cal_b=%s cal_n=%s cal_margen=%s cal_resolucion=%s disc_param=%s disc_veces=%s disc_obs=%s\n' \
    "$SP_SONDA" "$SP_MODO" "$SP_ESTADO" "$sp_motivo" "$sp_corrida" "$SP_INVOCACION" \
    "$sp_arbol" "$SP_PLATAFORMA" "$sp_carga" "$sp_jobs" "$sp_us" "$SP_PROCS" \
    "$SP_VIVOS" "$SP_DESC" "$SP_INSTRUMENTADA" "$SP_PLAZO" "$SP_PLAZO_ORIGEN" "$sp_etiq" \
    "${SP_CUENTA:-desconocido}" "${SP_CAL_A:-desconocido}" "${SP_CAL_B:-desconocido}" \
    "${SP_CAL_N:-desconocido}" "$SP_CAL_MARGEN" "$SP_RESOLUCION" \
    "${SP_DISC_PARAM:-desconocido}" "${SP_DISC_VECES:-desconocido}" "${SP_DISC_OBS:-desconocido}"
}
trap 'sp_emite' EXIT
trap 'SP_ESTADO=interrumpida; SP_MOTIVO=señal; sp_emite; exit 130' INT TERM
sp_falla() { SP_ESTADO="$1"; SP_MOTIVO="$2"; sp_emite; exit 1; }

[ "$SP_ESTADO" = ok ] || { sp_emite; exit 1; }
[ -n "${EPOCHREALTIME:-}" ] || sp_falla sin-reloj no-hay-EPOCHREALTIME
sp_num "$SP_N" || sp_falla error n-no-es-un-entero
sp_num "$SP_CAL_MARGEN" && [ "$SP_CAL_MARGEN" -ge 4 ] || sp_falla error el-margen-sobre-la-resolucion-solo-puede-subir-de-4
sp_path_sano "${PATH:-}" || sp_falla path-inseguro path-con-componente-vacio-o-relativo
sp_foto

# --- Las rutas reales, con `type -P` y ANTES de tocar el PATH (CA-04 punto 3) ---
# `command -v` VE funciones de shell y `type -P` no: el envoltorio recursivo de 1.32.1
# nació exactamente ahí.
#
# Y LA RESOLUCIÓN NO PASA POR `$( )`, que es UN FORK POR BINARIO: catorce binarios eran
# catorce procesos gastados en resolver rutas, y `type` es un builtin —lo único que costaba
# era la sustitución (medido: 24 procesos propios frente a 38 en el oráculo)—. Se redirige la
# salida del builtin a un archivo del propio directorio de envoltorios y se lee con `read`:
# cero procesos, y `type -P` sigue siendo quien resuelve, que es lo que el criterio pide.

# --- El directorio de envoltorios: PRIVADO, DESDE ESTE PROCESO, NUNCA FIJO -----
# CA-04 punto 4. El corredor corre las secciones EN PARALELO: un directorio de nombre fijo
# es la clase medida de REQ-015 —el temporal compartido— aplicada esta vez a EJECUTABLES,
# con una sonda ejecutando el envoltorio de otra a mitad de medición. Se crea ANTES de
# resolver porque crearlo no toca el `PATH`, y así el archivo de resolución se va con él.
SP_DIR="${SP_TRABAJO%/}/sonda-procesos-$$-${SP_T0_INV}"
mkdir -p "$SP_DIR" 2>/dev/null || sp_falla error no-se-pudo-crear-el-directorio-de-envoltorios
SP_PROCS=$((SP_PROCS + 1))
SP_REG="$SP_DIR/reg"
: > "$SP_REG" || sp_falla error no-se-pudo-crear-el-registro

declare -A SP_REAL=()
for sp_b in $SP_BIN_LISTA; do
  sp_r=''
  type -P "$sp_b" > "$SP_DIR/.ruta" 2>/dev/null || :
  read -r sp_r < "$SP_DIR/.ruta" 2>/dev/null || :
  [ -n "$sp_r" ] && SP_REAL[$sp_b]="$sp_r"
done
[ "${#SP_REAL[@]}" -gt 0 ] || sp_falla sin-binarios ninguno-de-los-binarios-esta-en-el-PATH

for sp_b in "${!SP_REAL[@]}"; do
  # (1) La resolución previa no puede caer dentro del propio envoltorio...
  case "${SP_REAL[$sp_b]}" in "$SP_DIR"/*) sp_falla envoltorio-recursivo "resolucion-dentro-del-envoltorio:$sp_b" ;; esac
  # (2) ...y el envoltorio NO re-resuelve por PATH en tiempo de llamada: `exec` lleva la
  # ruta ABSOLUTA. Un envoltorio que re-resolviera reproduce el incidente de 1.32.1 tal
  # cual, con la resolución previa impecable.
  printf '#!/bin/sh\necho %s >> "%s"\nexec %s "$@"\n' "$sp_b" "$SP_REG" "${SP_REAL[$sp_b]}" > "$SP_DIR/$sp_b" \
    || sp_falla error "no-se-pudo-escribir-el-envoltorio:$sp_b"
done
# Un solo `chmod` para el lote: un fork por envoltorio serían catorce.
chmod +x "$SP_DIR"/* 2>/dev/null || sp_falla error chmod-de-los-envoltorios-fallo
SP_PROCS=$((SP_PROCS + 1))

# (3) LA COMPROBACIÓN SE HACE SOBRE LA RUTA QUE QUEDÓ ESCRITA EN EL ENVOLTORIO GENERADO,
# no sólo sobre la resolución previa (CA-04 punto 3). Se relee el archivo: es la única
# forma de ver lo que de verdad se va a ejecutar.
for sp_b in "${!SP_REAL[@]}"; do
  sp_linea=''
  while IFS= read -r sp_l || [ -n "$sp_l" ]; do
    case "$sp_l" in 'exec '*) sp_linea="$sp_l"; break ;; esac
  done < "$SP_DIR/$sp_b"
  sp_ruta="${sp_linea#exec }"; sp_ruta="${sp_ruta%% \"\$@\"}"
  case "$sp_ruta" in
    /*) ;;
    *)  sp_falla envoltorio-recursivo "ruta-no-absoluta-en-el-envoltorio:$sp_b" ;;
  esac
  case "$sp_ruta" in "$SP_DIR"/*) sp_falla envoltorio-recursivo "ruta-dentro-del-envoltorio:$sp_b" ;; esac
done

# --- El PATH instrumentado, ACOTADO A LA INVOCACIÓN (CA-04 punto 5) -----------
SP_PATH_INSTR="$SP_DIR:$PATH"
sp_path_sano "$SP_PATH_INSTR" || sp_falla path-inseguro path-instrumentado-con-componente-vacio-o-relativo

SP_PLAZO_T0=${EPOCHREALTIME/./}
sp_plazo_vencido() { [ $(( ( ${EPOCHREALTIME/./} - SP_PLAZO_T0 ) / 1000000 )) -ge "$SP_PLAZO" ]; }

# sp_ejerce <snippet> -> SP_CUENTA_EJ = líneas del registro que ese ejercicio añadió.
# ES EL ÚNICO CAMINO QUE EJECUTA UN SUJETO, y la calibración lo recorre tal cual
# sustituyendo SÓLO el sujeto (CA-03 punto 4).
SP_CUENTA_EJ=0
sp_ejerce() {
  local sp_snip="$1" sp_n=0 sp_x
  : > "$SP_REG"
  PATH="$SP_PATH_INSTR" ARNES_SONDA_INSTRUMENTANDO=1 eval "$sp_snip" >/dev/null 2>&1 </dev/null
  while IFS= read -r sp_x || [ -n "$sp_x" ]; do sp_n=$((sp_n + 1)); done < "$SP_REG"
  SP_CUENTA_EJ="$sp_n"
  SP_PROCS=$((SP_PROCS + sp_n))
  if sp_plazo_vencido; then SP_CUENTA="$sp_n"; sp_falla plazo-agotado "plazo-de-${SP_PLAZO}s-agotado"; fi
}

if [ "$SP_MODO" = calibracion ]; then
  # (a) SUJETO SENSIBLE: N invocaciones de un binario instrumentado. El coste en procesos es
  #     EXACTAMENTE N, así que duplicar N da factor 2 POR CONSTRUCCIÓN — y medido: 2,000 en
  #     todas las corridas.
  # (b) SUJETO INSENSIBLE: un número FIJO de invocaciones, que no mira N. Factor ≈ 1.
  # (a.2) DISCORDANTE: ver abajo.
  #
  # CA-03 (c): el tamaño sale de la resolución del instrumento por el margen declarado, y no
  # de un absoluto. El env sólo puede SUBIRLO.
  SP_CAL_N=$(( SP_RESOLUCION * SP_CAL_MARGEN ))
  if [ "$SP_N" -gt "$SP_CAL_N" ]; then
    SP_CAL_N="$SP_N"
  elif [ "$SP_N" -gt 0 ]; then
    sp_diag "sonda-procesos: --n $SP_N es MENOR que el tamaño derivado ($SP_CAL_N); se ignora (CA-03 c)."
  fi
  [ -n "${SP_REAL[grep]:-}" ] || sp_falla sin-binarios grep-no-esta-en-el-PATH

  sp_cal_sens()   { local sp_i; for ((sp_i = 0; sp_i < SP_CAL_VECES; sp_i++)); do grep -q x /dev/null || :; done; }
  sp_cal_insens() { local sp_i; for ((sp_i = 0; sp_i < SP_CAL_FIJO;  sp_i++)); do grep -q x /dev/null || :; done; }
  # (a.2) LA MITAD DISCORDANTE — la procedencia del factor, acreditada de forma OBSERVABLE.
  # La procedencia NO SE LEE EN EL REGISTRO: la sonda honesta y la tautológica publican el
  # mismo número (QA-021-01). Así que el discordante ejerce el binario instrumentado un
  # número de veces DISTINTO del parámetro —`cal_n - 1`, que además cuesta MENOS de una
  # unidad, como CA-08 (iii) exige de este término— y deja, POR OTRO CAMINO, una marca por
  # iteración en el archivo de rastro que EL JUEZ creó y pasó. La magnitud publicada
  # (`disc_obs`) sale de contar el registro de los ENVOLTORIOS; el testigo lo cuenta el juez
  # sobre SU archivo. Son dos caminos distintos a propósito: contar el testigo sobre el mismo
  # registro de envoltorios lo haría producto de la propia sonda, que es lo que (a.3)
  # prohíbe —y ese registro se retira en la misma salida por CA-04 punto 4—.
  # La sonda NO trunca el rastro y NO lo lee: sólo añade. Quien lo crea vacío y quien lo
  # cuenta es el juez.
  sp_cal_disc() {
    local sp_i
    for ((sp_i = 0; sp_i < SP_DISC_VECES; sp_i++)); do
      grep -q x /dev/null || :
      [ -n "$SP_RASTRO" ] && printf 'x\n' >> "$SP_RASTRO"
    done
    return 0
  }
  SP_DISC_VECES=$(( SP_CAL_N - 1 ))
  [ "$SP_DISC_VECES" -ge 1 ] || SP_DISC_VECES=1
  SP_DISC_PARAM="$SP_CAL_N"

  SP_CAL_FIJO="$SP_CAL_N"
  SP_CAL_VECES="$SP_CAL_N";          sp_ejerce 'sp_cal_sens';   SP_A1="$SP_CUENTA_EJ"
  SP_CAL_VECES=$(( SP_CAL_N * 2 ));  sp_ejerce 'sp_cal_sens';   SP_A2="$SP_CUENTA_EJ"
  SP_CAL_VECES="$SP_CAL_N";          sp_ejerce 'sp_cal_insens'; SP_B1="$SP_CUENTA_EJ"
  SP_CAL_VECES=$(( SP_CAL_N * 2 ));  sp_ejerce 'sp_cal_insens'; SP_B2="$SP_CUENTA_EJ"
  sp_ejerce 'sp_cal_disc';           SP_DISC_OBS="$SP_CUENTA_EJ"
  SP_CUENTA="$SP_A1"
  if [ "${SP_A1:-0}" -lt 1 ] || [ "${SP_B1:-0}" -lt 1 ]; then
    sp_falla sin-cuenta el-sujeto-sintetico-no-gasto-ningun-proceso
  fi
  SP_CAL_A=$(( SP_A2 * 1000 / SP_A1 ))
  SP_CAL_B=$(( SP_B2 * 1000 / SP_B1 ))
elif [ -n "$SP_SUJ" ]; then
  [ -z "$SP_PREP" ] || eval "$SP_PREP"
  sp_ejerce "$SP_SUJ"
  SP_CUENTA="$SP_CUENTA_EJ"
  # Un cero NO es una medida: un sujeto que no gastó un solo proceso instrumentado es, casi
  # siempre, un sujeto que no se ejecutó — la misma familia que el JSON vacío.
  [ "${SP_CUENTA:-0}" -ge 1 ] || sp_falla sin-cuenta el-sujeto-no-gasto-ningun-proceso-instrumentado
else
  sp_falla sin-sujeto no-se-declaro-ningun-sujeto
fi

sp_emite
exit 0
