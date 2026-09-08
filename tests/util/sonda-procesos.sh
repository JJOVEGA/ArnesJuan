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
#   sonda-procesos.sh --calibrar [--n N] [--binarios '...'] [--dir-trabajo DIR]
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
SP_N=4
SP_PREP=''; SP_SUJ=''
SP_ETIQ='-'
SP_BIN_LISTA='jq awk grep sed tr date cat basename dirname mktemp wc head tail sort git'
SP_TRABAJO="${TMPDIR:-/tmp}"
SP_CUENTA=''
SP_CAL_A=''; SP_CAL_B=''
SP_VIVOS=desconocido; SP_DESC=ninguna
SP_DIR=''
SP_PLAZO=${ARNES_SONDA_PLAZO:-300}
SP_PLAZO_ORIGEN=arranque

sp_diag() { printf '%s\n' "$*" >&2; }
sp_num() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

while [ "$#" -gt 0 ]; do
  case "$1" in
    --sujeto)       SP_SUJ="${2:-}"; shift 2 ;;
    --prep)         SP_PREP="${2:-}"; shift 2 ;;
    --binarios)     SP_BIN_LISTA="${2:-}"; shift 2 ;;
    --n)            SP_N="${2:-}"; shift 2 ;;
    --dir-trabajo)  SP_TRABAJO="${2:-}"; shift 2 ;;
    --etiqueta)     SP_ETIQ="${2:-}"; shift 2 ;;
    --calibrar)     SP_MODO=calibracion; shift ;;
    -h|--ayuda)
      sp_diag "uso: sonda-procesos.sh --sujeto 'snippet' [--prep 'snippet'] [--binarios '...']"
      sp_diag "     sonda-procesos.sh --calibrar [--n N]"
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

# --- CA-04 punto 1: ningún DESCENDIENTE sobrevive, en el nivel que sea --------
sp_descendencia() {
  local sp_yo=$$ sp_cola sp_pid sp_hijo sp_tid sp_n=0 sp_linea sp_ppid sp_d sp_vistos=''
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
  for sp_hijo in $sp_vistos; do kill -9 "$sp_hijo" 2>/dev/null || :; done
  SP_VIVOS="$sp_n"
  [ "$sp_n" -eq 0 ] || sp_diag "sonda-procesos: quedaron $sp_n descendientes vivos; se han matado (CA-04.1)."
  return 0
}

SP_EMITIDO=no
sp_emite() {
  [ "$SP_EMITIDO" = no ] || return 0
  SP_EMITIDO=si
  sp_descendencia
  # CA-04 punto 4: el directorio de envoltorios se retira en la MISMA salida, INCLUIDOS los
  # caminos de error. Hoy los dos caminos medidos lo dejaban detrás: la salida
  # ENVOLTORIO-RECURSIVO con rc 9 y el fallo de `chmod` con rc 1.
  if [ -n "$SP_DIR" ] && [ -d "$SP_DIR" ]; then
    rm -rf "$SP_DIR" 2>/dev/null || :
    SP_PROCS=$((SP_PROCS + 1))
  fi
  local sp_us=$(( ${EPOCHREALTIME/./} - SP_T0_INV ))
  printf 'sonda=%s modo=%s estado=%s motivo=%s corrida=%s invocacion=%s arbol=%s plataforma=%s carga=%s jobs=%s k=1 r=1 us=%s procesos=%s vivos=%s descendencia=%s instrumentada=%s plazo=%s plazo_origen=%s etiqueta=%s cuenta=%s cal_a=%s cal_b=%s\n' \
    "$SP_SONDA" "$SP_MODO" "$SP_ESTADO" "$SP_MOTIVO" "$SP_CORRIDA" "$SP_INVOCACION" \
    "$SP_ARBOL" "$SP_PLATAFORMA" "$SP_CARGA" "$SP_JOBS" "$sp_us" "$SP_PROCS" \
    "$SP_VIVOS" "$SP_DESC" "$SP_INSTRUMENTADA" "$SP_PLAZO" "$SP_PLAZO_ORIGEN" "$SP_ETIQ" \
    "${SP_CUENTA:-desconocido}" "${SP_CAL_A:-desconocido}" "${SP_CAL_B:-desconocido}"
}
trap 'sp_emite' EXIT
trap 'SP_ESTADO=interrumpida; SP_MOTIVO=señal; sp_emite; exit 130' INT TERM
sp_falla() { SP_ESTADO="$1"; SP_MOTIVO="$2"; sp_emite; exit 1; }

[ "$SP_ESTADO" = ok ] || { sp_emite; exit 1; }
[ -n "${EPOCHREALTIME:-}" ] || sp_falla sin-reloj no-hay-EPOCHREALTIME
sp_num "$SP_N" && [ "$SP_N" -ge 1 ] || sp_falla error n-no-es-un-entero-positivo
sp_path_sano "${PATH:-}" || sp_falla path-inseguro path-con-componente-vacio-o-relativo

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
  #     las dos corridas de la comisión de medición previa.
  # (b) SUJETO INSENSIBLE: un número FIJO de invocaciones, que no mira N. Factor ≈ 1.
  sp_cal_sens() { local sp_i; for ((sp_i = 0; sp_i < SP_CAL_N; sp_i++)); do grep -q x /dev/null || :; done; }
  SP_CAL_FIJO="$SP_N"
  sp_cal_insens() { local sp_i; for ((sp_i = 0; sp_i < SP_CAL_FIJO; sp_i++)); do grep -q x /dev/null || :; done; }
  [ -n "${SP_REAL[grep]:-}" ] || sp_falla sin-binarios grep-no-esta-en-el-PATH
  SP_CAL_N="$SP_N";          sp_ejerce 'sp_cal_sens';   SP_A1="$SP_CUENTA_EJ"
  SP_CAL_N=$(( SP_N * 2 ));  sp_ejerce 'sp_cal_sens';   SP_A2="$SP_CUENTA_EJ"
  SP_CAL_N="$SP_N";          sp_ejerce 'sp_cal_insens'; SP_B1="$SP_CUENTA_EJ"
  SP_CAL_N=$(( SP_N * 2 ));  sp_ejerce 'sp_cal_insens'; SP_B2="$SP_CUENTA_EJ"
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
