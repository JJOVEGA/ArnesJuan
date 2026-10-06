#!/usr/bin/env bash
# 52-t4-crlf.sh <scratch> <hooks>... — T4 con CRLF: Edit pequeño que cierra un REQ de N bytes en disco con fin de
# línea CRLF, por guard.sh, `timeout 60`. Y el coste aislado de la normalización del disco (`${disk//$'\r\n'/$'\n'}`,
# guard-completado.sh:604) en bash puro, para atribuir el tiempo.
set -u; S="$1"; shift; QD="$(cd "$(dirname "$0")" && pwd)"; . "$QD/h.sh"
W="$(mktemp -d "$S/t4-XXXX")"; trap 'rm -rf "$W"' EXIT; P="$W/p"
CAB='# REQ-900\nEstado: en-revisión\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\n\n## Texto\n'
cuerpo() { local n="$1" lin; lin="$(printf '%079d' 0 | tr 0 x)"$'\r\n'; local LC_ALL=C k=$(( n / 81 + 1 )) r='' s="$lin"
  while [ "$k" -gt 0 ]; do [ $((k & 1)) -eq 0 ] || r+="$s"; s+="$s"; k=$((k >> 1)); done; printf '%s' "${r:0:n}"; }
echo "# $(date -Is); loadavg $(cat /proc/loadavg)"
for n in ${QA_TAMANOS:-2000000 3000000 4000000}; do
  mkp "$P"; { printf "$CAB"; cuerpo "$n"; } > "$P/requirements/REQ-900.md"
  in_edit requirements/REQ-900.md 'Estado: en-revisión' 'Estado: completado' > "$W/in"
  for H in "$@"; do printf 'T4 disco %s crlf  %-32s %s\n' "$n" "${H#/home/juan/dev/}" "$(corre "$H" guard.sh "$W/in" | cut -c1-140)"; done
  t0=${EPOCHREALTIME/./}; LANG=C.UTF-8 bash -c 'IFS= read -r -d "" d < "$1"; r="${d//$'"'"'\r\n'"'"'/$'"'"'\n'"'"'}"; echo ${#r}' _ "$P/requirements/REQ-900.md" >/dev/null; t1=${EPOCHREALTIME/./}
  echo "   normalizacion aislada del disco (bash, C.UTF-8): $(( (t1-t0)/1000 )) ms"
done
