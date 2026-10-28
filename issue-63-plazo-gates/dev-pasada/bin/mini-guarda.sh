#!/usr/bin/env bash
# mini.sh <n> <senal> — reproducción mínima: un padre con trampa EXIT mata con <senal> un `sleep` recién bifurcado.
# Cuenta: trampas ejecutadas por hijos (otra BASHPID) y esperas de más de 1 s (el TERM que el hijo se tragó).
N="$1"; SIG="$2"
trap 'case ${BASHPID:-}:${ARNES_JUICIO:-} in "$$:fin") ;; "$$:"*|:*) echo "TRAMPA pid=$BASHPID padre=$$" ;; esac' EXIT
hijos=0; lentos=0
for ((i = 0; i < N; i++)); do
  t0=${EPOCHREALTIME/./}
  sleep 3 </dev/null >/dev/null 2>&1 &
  p=$!
  kill "-$SIG" "$p" 2>/dev/null; wait "$p" 2>/dev/null
  [ $(( ${EPOCHREALTIME/./} - t0 )) -lt 1000000 ] || lentos=$((lentos + 1))
done
echo "n=$N senal=$SIG esperas_de_mas_de_1s=$lentos"
