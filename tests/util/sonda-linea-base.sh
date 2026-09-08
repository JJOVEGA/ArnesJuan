#!/usr/bin/env bash
# sonda-linea-base.sh — materializar el árbol de una REFERENCIA de `git` (REQ-021, CA-05).
#
# SE INVOCA, NO SE HACE `source` (CA-01 punto 1). Emite UN registro de una línea
# `clave=valor` por la salida estándar y nada más; el diagnóstico va por la salida de error.
# No dicta veredicto: eso es del ayudante de `tests/escenarios/hooks/run.sh` (CA-01 punto 3).
#
# MEDIA LÍNEA BASE ES PEOR QUE NINGUNA, y los dos casos son de la ventana 1.33.0:
#   (a) un árbol copiado SIN `.git`: el tag no se materializaba, media comprobación salía
#       SKIP, la copia hacía la mitad del trabajo y la razón salió 2,008× donde el trabajo
#       entero da 0,964× — lo delató el RECUENTO DE SKIP, no el número;
#   (b) el CI clonaba sin tags: once criterios salieron SKIP y el PR dio verde sin medir
#       ninguno (H-08).
# En los dos el instrumento hizo lo correcto y el defecto fue que NADIE MIRABA CUÁNTO SE
# HABÍA DEJADO DE MATERIALIZAR. Por eso `archivos=<n>` es un campo del registro, no una nota.
#
# LO QUE DECIDE ES QUE `git` RESUELVA LA REFERENCIA, NO DE QUÉ TIPO SEA (CA-05): tag, commit
# o rama dan exactamente el mismo trabajo.
#
# Uso:
#   sonda-linea-base.sh --ref REF --destino DIR [--rutas 'hooks tools'] [--repo DIR]
#   sonda-linea-base.sh --calibrar [--ref REF] [--repo DIR] [--n N] [--dir-trabajo DIR]
set -uo pipefail

SLB_T0_INV=${EPOCHREALTIME/./}
SLB_PROCS=0
SLB_SONDA=linea-base
SLB_MODO=medicion
SLB_ESTADO=ok
SLB_MOTIVO='-'
SLB_REF=''; SLB_DESTINO=''; SLB_RUTAS='hooks tools'; SLB_REPO=''
SLB_N=2; SLB_ETIQ='-'
SLB_TRABAJO="${TMPDIR:-/tmp}"
SLB_ARCHIVOS=''
SLB_CAL_A=''; SLB_CAL_B=''
SLB_VIVOS=desconocido; SLB_DESC=ninguna
SLB_DIRCAL=''
SLB_PLAZO=${ARNES_SONDA_PLAZO:-300}
SLB_PLAZO_ORIGEN=arranque

slb_diag() { printf '%s\n' "$*" >&2; }
slb_num() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

while [ "$#" -gt 0 ]; do
  case "$1" in
    --ref)          SLB_REF="${2:-}"; shift 2 ;;
    --destino)      SLB_DESTINO="${2:-}"; shift 2 ;;
    --rutas)        SLB_RUTAS="${2:-}"; shift 2 ;;
    --repo)         SLB_REPO="${2:-}"; shift 2 ;;
    --n)            SLB_N="${2:-}"; shift 2 ;;
    --dir-trabajo)  SLB_TRABAJO="${2:-}"; shift 2 ;;
    --etiqueta)     SLB_ETIQ="${2:-}"; shift 2 ;;
    --calibrar)     SLB_MODO=calibracion; shift ;;
    -h|--ayuda)
      slb_diag "uso: sonda-linea-base.sh --ref REF --destino DIR [--rutas '...'] [--repo DIR]"
      slb_diag "     sonda-linea-base.sh --calibrar [--ref REF] [--n N]"
      exit 0 ;;
    *) slb_diag "argumento no reconocido: <$1>"; SLB_ESTADO=error; SLB_MOTIVO=argumento-no-reconocido; break ;;
  esac
done

SLB_CORRIDA="${ARNES_CORRIDA:-desconocido}"
SLB_INVOCACION="$$-${SLB_T0_INV}"
SLB_ARBOL="${ARNES_ARBOL:-desconocido}"
SLB_PLATAFORMA="${OSTYPE:-desconocido}-${HOSTTYPE:-x}-bash${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
SLB_JOBS="${ARNES_JOBS:-desconocido}"
SLB_CARGA=desconocido
if [ -r /proc/loadavg ]; then read -r SLB_CARGA _ < /proc/loadavg 2>/dev/null || SLB_CARGA=desconocido; fi
[ -n "$SLB_CARGA" ] || SLB_CARGA=desconocido
SLB_INSTRUMENTADA=no

slb_path_sano() {
  local slb_resto="${PATH:-}" slb_tramo
  case "$slb_resto" in ''|*::*|:*|*:) return 1 ;; esac
  while [ -n "$slb_resto" ]; do
    slb_tramo="${slb_resto%%:*}"
    case "$slb_tramo" in /*) ;; *) return 1 ;; esac
    [ "$slb_tramo" = "$slb_resto" ] && break
    slb_resto="${slb_resto#*:}"
  done
  return 0
}

# --- CA-04 punto 1: ningún DESCENDIENTE sobrevive, en el nivel que sea --------
slb_descendencia() {
  local slb_yo=$$ slb_cola slb_pid slb_hijo slb_tid slb_n=0 slb_linea slb_ppid slb_d slb_vistos=''
  SLB_VIVOS=desconocido; SLB_DESC=ninguna
  [ -d /proc ] || return 0
  if [ -r "/proc/$slb_yo/task/$slb_yo/children" ]; then
    SLB_DESC=proc
    slb_cola=" $slb_yo "
    while [ -n "${slb_cola// /}" ]; do
      slb_pid="${slb_cola## }"; slb_pid="${slb_pid%% *}"
      slb_cola="${slb_cola#* $slb_pid }"; slb_cola=" $slb_cola"
      for slb_tid in /proc/"$slb_pid"/task/[0-9]*; do
        [ -r "$slb_tid/children" ] || continue
        slb_linea=''
        # SIN `|| continue`: `children` no termina en salto de línea, así que `read` deja la
        # variable puesta y devuelve 1 (ver la nota en `sonda-reloj.sh`).
        read -r slb_linea < "$slb_tid/children" 2>/dev/null || :
        [ -n "$slb_linea" ] || continue
        for slb_hijo in $slb_linea; do
          slb_num "$slb_hijo" || continue
          case " $slb_vistos " in *" $slb_hijo "*) continue ;; esac
          slb_vistos="$slb_vistos $slb_hijo"; slb_cola="$slb_cola$slb_hijo "; slb_n=$((slb_n + 1))
        done
      done
    done
  else
    declare -A SLB_HIJOS_DE=()
    for slb_d in /proc/[0-9]*; do
      slb_pid="${slb_d#/proc/}"
      slb_num "$slb_pid" || continue
      [ -r "$slb_d/stat" ] || continue
      slb_linea=''
      read -r slb_linea < "$slb_d/stat" 2>/dev/null || continue
      slb_linea="${slb_linea##*') '}"
      slb_ppid="${slb_linea#* }"; slb_ppid="${slb_ppid%% *}"
      slb_num "$slb_ppid" || continue
      SLB_HIJOS_DE[$slb_ppid]="${SLB_HIJOS_DE[$slb_ppid]:-} $slb_pid"
    done
    SLB_DESC=proc-ppid
    slb_cola=" $slb_yo "
    while [ -n "${slb_cola// /}" ]; do
      slb_pid="${slb_cola## }"; slb_pid="${slb_pid%% *}"
      slb_cola="${slb_cola#* $slb_pid }"; slb_cola=" $slb_cola"
      for slb_hijo in ${SLB_HIJOS_DE[$slb_pid]:-}; do
        case " $slb_vistos " in *" $slb_hijo "*) continue ;; esac
        slb_vistos="$slb_vistos $slb_hijo"; slb_cola="$slb_cola$slb_hijo "; slb_n=$((slb_n + 1))
      done
    done
  fi
  for slb_hijo in $slb_vistos; do kill -9 "$slb_hijo" 2>/dev/null || :; done
  SLB_VIVOS="$slb_n"
  [ "$slb_n" -eq 0 ] || slb_diag "sonda-linea-base: quedaron $slb_n descendientes vivos; se han matado (CA-04.1)."
  return 0
}

SLB_EMITIDO=no
slb_emite() {
  [ "$SLB_EMITIDO" = no ] || return 0
  SLB_EMITIDO=si
  slb_descendencia
  # También en los caminos de error (CA-04 punto 4).
  if [ -n "$SLB_DIRCAL" ] && [ -d "$SLB_DIRCAL" ]; then
    rm -rf "$SLB_DIRCAL" 2>/dev/null || :
    SLB_PROCS=$((SLB_PROCS + 1))
  fi
  local slb_us=$(( ${EPOCHREALTIME/./} - SLB_T0_INV ))
  printf 'sonda=%s modo=%s estado=%s motivo=%s corrida=%s invocacion=%s arbol=%s plataforma=%s carga=%s jobs=%s k=1 r=1 us=%s procesos=%s vivos=%s descendencia=%s instrumentada=%s plazo=%s plazo_origen=%s etiqueta=%s ref=%s archivos=%s cal_a=%s cal_b=%s\n' \
    "$SLB_SONDA" "$SLB_MODO" "$SLB_ESTADO" "$SLB_MOTIVO" "$SLB_CORRIDA" "$SLB_INVOCACION" \
    "$SLB_ARBOL" "$SLB_PLATAFORMA" "$SLB_CARGA" "$SLB_JOBS" "$slb_us" "$SLB_PROCS" \
    "$SLB_VIVOS" "$SLB_DESC" "$SLB_INSTRUMENTADA" "$SLB_PLAZO" "$SLB_PLAZO_ORIGEN" "$SLB_ETIQ" \
    "${SLB_REF:--}" "${SLB_ARCHIVOS:-desconocido}" "${SLB_CAL_A:-desconocido}" "${SLB_CAL_B:-desconocido}"
}
trap 'slb_emite' EXIT
trap 'SLB_ESTADO=interrumpida; SLB_MOTIVO=señal; slb_emite; exit 130' INT TERM
# CA-05 punto 3: cuando NO puede, `estado=sin-linea-base` CON el motivo, y nunca un árbol
# parcial ni un `ok`.
slb_falla() { SLB_ESTADO="$1"; SLB_MOTIVO="$2"; slb_emite; exit 1; }

[ "$SLB_ESTADO" = ok ] || { slb_emite; exit 1; }
[ -n "${EPOCHREALTIME:-}" ] || slb_falla sin-reloj no-hay-EPOCHREALTIME
slb_path_sano || slb_falla path-inseguro path-con-componente-vacio-o-relativo
slb_num "$SLB_N" && [ "$SLB_N" -ge 1 ] || slb_falla error n-no-es-un-entero-positivo
[ -n "$SLB_REPO" ] || SLB_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd || true)"
[ -n "$SLB_REPO" ] || slb_falla sin-linea-base no-se-pudo-situar-el-repositorio
[ -d "$SLB_REPO/.git" ] || slb_falla sin-linea-base no-hay-.git-en-el-repositorio

SLB_T0_PLAZO=${EPOCHREALTIME/./}
slb_plazo_vencido() { [ $(( ( ${EPOCHREALTIME/./} - SLB_T0_PLAZO ) / 1000000 )) -ge "$SLB_PLAZO" ]; }

# --- EL ÚNICO CAMINO QUE MATERIALIZA. La calibración lo recorre tal cual, cambiando SÓLO
# el sujeto —la referencia, las rutas y el límite— (CA-03 punto 4).
# slb_materializa <ref> <destino> <rutas> <límite: n o 0 = sin límite> -> SLB_ARCHIVOS_EJ
SLB_ARCHIVOS_EJ=0
slb_materializa() {
  local slb_ref="$1" slb_dst="$2" slb_rutas="$3" slb_lim="$4"
  local slb_lista slb_l slb_modo slb_tipo slb_oid slb_ruta slb_n=0
  local slb_dirs='' slb_paths='' slb_shs='' slb_calc slb_i slb_obtenido
  local -a slb_oids=() slb_rutas_a=()
  SLB_ARCHIVOS_EJ=0
  # (1) Lo que decide es que `git` RESUELVA la referencia a un árbol; el tipo no cambia ni
  # una línea de lo que se materializa (CA-05).
  git -C "$SLB_REPO" rev-parse -q --verify "$slb_ref^{tree}" >/dev/null 2>&1 || {
    SLB_PROCS=$((SLB_PROCS + 1)); SLB_MOTIVO="la-referencia-no-resuelve:$slb_ref"; return 1; }
  SLB_PROCS=$((SLB_PROCS + 1))
  # (2) Una sola llamada da la lista Y los identificadores de objeto: la comprobación del
  # punto 1 de CA-05 no paga un recorrido aparte.
  slb_lista="$(git -C "$SLB_REPO" ls-tree -r "$slb_ref" -- $slb_rutas 2>/dev/null)"
  SLB_PROCS=$((SLB_PROCS + 1))
  [ -n "$slb_lista" ] || { SLB_MOTIVO="la-referencia-no-tiene-esas-rutas:$slb_ref"; return 1; }
  while IFS= read -r slb_l || [ -n "$slb_l" ]; do
    [ -n "$slb_l" ] || continue
    slb_modo="${slb_l%% *}"; slb_l="${slb_l#* }"
    slb_tipo="${slb_l%% *}"; slb_l="${slb_l#* }"
    slb_oid="${slb_l%%$'\t'*}"; slb_ruta="${slb_l#*$'\t'}"
    [ "$slb_tipo" = blob ] || continue
    slb_n=$((slb_n + 1))
    [ "$slb_lim" -eq 0 ] || [ "$slb_n" -le "$slb_lim" ] || { slb_n=$((slb_n - 1)); break; }
    slb_dirs="$slb_dirs $slb_dst/${slb_ruta%/*}"
    slb_paths="$slb_paths$slb_dst/$slb_ruta"$'\n'
    slb_oids+=("$slb_oid")
    slb_rutas_a+=("$slb_dst/$slb_ruta")
    case "$slb_ruta" in *.sh) slb_shs="$slb_shs $slb_dst/$slb_ruta" ;; esac
  done <<< "$slb_lista"
  [ "$slb_n" -ge 1 ] || { SLB_MOTIVO='la-referencia-no-materializa-ningun-archivo'; return 1; }
  mkdir -p $slb_dirs 2>/dev/null || { SLB_PROCS=$((SLB_PROCS + 1)); SLB_MOTIVO='no-se-pudo-crear-el-destino'; return 1; }
  SLB_PROCS=$((SLB_PROCS + 1))
  slb_i=0
  while IFS= read -r slb_ruta || [ -n "$slb_ruta" ]; do
    [ -n "$slb_ruta" ] || continue
    slb_i=$((slb_i + 1))
    git -C "$SLB_REPO" show "$slb_ref:${slb_ruta#$slb_dst/}" > "$slb_ruta" 2>/dev/null || {
      SLB_PROCS=$((SLB_PROCS + 1)); SLB_MOTIVO="no-se-pudo-materializar:${slb_ruta#$slb_dst/}"; return 1; }
    SLB_PROCS=$((SLB_PROCS + 1))
    if slb_plazo_vencido; then SLB_ARCHIVOS_EJ="$slb_i"; SLB_ESTADO=plazo-agotado; SLB_MOTIVO="plazo-de-${SLB_PLAZO}s-agotado"; slb_emite; exit 1; fi
  done <<< "$slb_paths"
  # (3) `git show` escribe el CONTENIDO, no el MODO: sin el bit de ejecución un árbol
  # heredado sirve para `source` pero el canario no arranca, la corrida sale «sin casos» y
  # es un SKIP correcto por un motivo que no es el suyo (medido).
  if [ -n "$slb_shs" ]; then
    chmod +x $slb_shs 2>/dev/null || :
    SLB_PROCS=$((SLB_PROCS + 1))
  fi
  # (4) COMPRUEBA LO QUE DEJÓ: cada archivo materializado coincide con el objeto DEL ÁRBOL DE
  # ESA REFERENCIA. Un solo `git hash-object` para el lote entero (CA-05 punto 1).
  slb_calc="$(git -C "$SLB_REPO" hash-object --stdin-paths <<< "${slb_paths%$'\n'}" 2>/dev/null)"
  SLB_PROCS=$((SLB_PROCS + 1))
  [ -n "$slb_calc" ] || { SLB_MOTIVO='no-se-pudo-verificar-el-contenido-materializado'; return 1; }
  slb_i=0
  while IFS= read -r slb_obtenido || [ -n "$slb_obtenido" ]; do
    [ -n "$slb_obtenido" ] || continue
    [ "$slb_i" -lt "$slb_n" ] || { SLB_MOTIVO='la-verificacion-devolvio-mas-lineas-que-archivos'; return 1; }
    [ "${slb_oids[slb_i]}" = "$slb_obtenido" ] || { SLB_MOTIVO="el-contenido-materializado-no-coincide-en:${slb_rutas_a[slb_i]##*/}"; return 1; }
    slb_i=$((slb_i + 1))
  done <<< "$slb_calc"
  [ "$slb_i" -eq "$slb_n" ] || { SLB_MOTIVO="se-verificaron-$slb_i-de-$slb_n-archivos"; return 1; }
  # (5) …y TODO script materializado es ejecutable.
  for slb_ruta in $slb_shs; do
    [ -x "$slb_ruta" ] || { SLB_MOTIVO="script-materializado-sin-bit-de-ejecucion:${slb_ruta##*/}"; return 1; }
  done
  SLB_ARCHIVOS_EJ="$slb_n"
  return 0
}

if [ "$SLB_MODO" = calibracion ]; then
  # (a) SUJETO SENSIBLE: materializar los N primeros archivos del árbol. El coste lo domina
  #     un `git show` POR ARCHIVO, así que duplicar N duplica el trabajo por construcción y
  #     el factor sale EXACTO. La magnitud contrastada es el número de archivos
  #     materializados, que es el número de `git show`: el término que crece.
  # (b) SUJETO INSENSIBLE: un límite FIJO que no mira N. Factor ≈ 1.
  [ -n "$SLB_REF" ] || SLB_REF=HEAD
  SLB_DIRCAL="${SLB_TRABAJO%/}/sonda-linea-base-$$-${SLB_T0_INV}"
  mkdir -p "$SLB_DIRCAL/a1" "$SLB_DIRCAL/a2" "$SLB_DIRCAL/b1" "$SLB_DIRCAL/b2" 2>/dev/null \
    || slb_falla error no-se-pudo-crear-el-directorio-de-calibracion
  SLB_PROCS=$((SLB_PROCS + 1))
  SLB_FIJO="$SLB_N"
  slb_materializa "$SLB_REF" "$SLB_DIRCAL/a1" "$SLB_RUTAS" "$SLB_N"             || slb_falla sin-linea-base "$SLB_MOTIVO"
  SLB_A1="$SLB_ARCHIVOS_EJ"
  slb_materializa "$SLB_REF" "$SLB_DIRCAL/a2" "$SLB_RUTAS" "$(( SLB_N * 2 ))"   || slb_falla sin-linea-base "$SLB_MOTIVO"
  SLB_A2="$SLB_ARCHIVOS_EJ"
  slb_materializa "$SLB_REF" "$SLB_DIRCAL/b1" "$SLB_RUTAS" "$SLB_FIJO"          || slb_falla sin-linea-base "$SLB_MOTIVO"
  SLB_B1="$SLB_ARCHIVOS_EJ"
  slb_materializa "$SLB_REF" "$SLB_DIRCAL/b2" "$SLB_RUTAS" "$SLB_FIJO"          || slb_falla sin-linea-base "$SLB_MOTIVO"
  SLB_B2="$SLB_ARCHIVOS_EJ"
  SLB_ARCHIVOS="$SLB_A1"
  [ "${SLB_A1:-0}" -ge 1 ] || slb_falla sin-linea-base la-calibracion-no-materializo-ningun-archivo
  SLB_CAL_A=$(( SLB_A2 * 1000 / SLB_A1 ))
  SLB_CAL_B=$(( SLB_B2 * 1000 / SLB_B1 ))
else
  [ -n "$SLB_REF" ]     || slb_falla sin-linea-base no-se-declaro-ninguna-referencia
  [ -n "$SLB_DESTINO" ] || slb_falla sin-linea-base no-se-declaro-destino
  slb_materializa "$SLB_REF" "$SLB_DESTINO" "$SLB_RUTAS" 0 || slb_falla sin-linea-base "$SLB_MOTIVO"
  SLB_ARCHIVOS="$SLB_ARCHIVOS_EJ"
fi

slb_emite
exit 0
