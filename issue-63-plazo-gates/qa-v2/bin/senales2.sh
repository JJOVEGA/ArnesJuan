#!/usr/bin/env bash
# variante sin KILL de respaldo: sólo la señal, para ver si el hijo se la traga (espera = 3 s del sleep)
H="$1"; SIG="$2"; N="$3"
o="$(timeout 300 bash -c '. "$1/entrada.sh"; set -uo pipefail
  for ((i = 0; i < $3; i++)); do t=${EPOCHREALTIME/./}
    sleep 3 </dev/null >/dev/null 2>&1 & p=$!; kill -s "$2" "$p" 2>/dev/null; wait "$p" 2>/dev/null
    (( ${EPOCHREALTIME/./} - t < 1500000 )) || echo LENTA; done; ARNES_JUICIO=fin' _ "$H" "$SIG" "$N" 2>/dev/null)"; rc=$?
d=$(grep -o '"permissionDecision"' <<<"$o" | wc -l); l=$(grep -c LENTA <<<"$o")
echo "$(basename $(dirname $H)) solo-señal=$SIG n=$N rc=$rc documentos=$d lentas=$l"
