#!/usr/bin/env bash
# senales.sh <hooks> <señal> <n> <forma>: n hijos recién bifurcados (forma: sleep = como el reloj; sub = subshell con
# redirección; cs = sustitución de órdenes en segundo plano) reciben <señal> nada más nacer, con la trampa de entrada.sh.
# Cuenta documentos de decisión en la salida estándar del «hook» y esperas > 1,5 s (la señal tragada).
H="$1"; SIG="$2"; N="$3"; F="$4"
o="$(timeout 120 bash -c '. "$1/entrada.sh"; set -uo pipefail
  for ((i = 0; i < $3; i++)); do t=${EPOCHREALTIME/./}
    case $4 in
      sleep) sleep 3 </dev/null >/dev/null 2>&1 & ;;
      sub) ( exec sleep 3 ) </dev/null >/dev/null 2>&1 & ;;
      cs) ( x=$(sleep 3); : ) </dev/null >/dev/null 2>&1 & ;;
    esac
    p=$!; kill -s "$2" "$p" 2>/dev/null; kill -KILL "$p" 2>/dev/null; wait "$p" 2>/dev/null
    (( ${EPOCHREALTIME/./} - t < 1500000 )) || echo LENTA; done; ARNES_JUICIO=fin' _ "$H" "$SIG" "$N" "$F" 2>/dev/null)"; rc=$?
d=$(grep -o '"permissionDecision"' <<<"$o" | wc -l); l=$(grep -c LENTA <<<"$o")
echo "$(basename $(dirname $H)) señal=$SIG forma=$F n=$N rc=$rc documentos=$d lentas=$l"
