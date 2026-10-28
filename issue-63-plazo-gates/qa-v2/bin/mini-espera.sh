#!/usr/bin/env bash
# mini-espera.sh <hooks> <n>: el camino de una gate `true` del hook (arnes_gates_reloj + arnes_gate, de lib.sh, sin cambios),
# con un reloj de 3 s: cuenta las gates cuya espera volvió por el RELOJ (ARNES_GATE_FIN distinto de fin, o > 1,5 s).
o="$(timeout 600 bash -c '. "$1/entrada.sh"; set -uo pipefail; . "$1/lib.sh"; ARNES_PROJ=$PWD; f=$(mktemp)
  for ((i = 0; i < $2; i++)); do t=${EPOCHREALTIME/./}; arnes_gates_reloj 3000000; arnes_gate true "$f"
    ms=$(( (${EPOCHREALTIME/./} - t) / 1000 )); [ "$ARNES_GATE_FIN" = fin ] && (( ms < 1500 )) || echo "ESPERA it=$i fin=$ARNES_GATE_FIN rc=$ARNES_GATE_RC ms=$ms"
    arnes_gates_sin_reloj; done; rm -f "$f"; ARNES_JUICIO=fin' _ "$1" "$2" 2>&1)"
echo "$(basename $(dirname $1)) n=$2 esperas=$(grep -c ESPERA <<<"$o") documentos=$(grep -o '"permissionDecision"' <<<"$o" | wc -l)"; grep ESPERA <<<"$o" | head -5
