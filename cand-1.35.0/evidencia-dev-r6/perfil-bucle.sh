H="$1"; export CLAUDE_PROJECT_DIR="$2"
set -uo pipefail
. "$H/lib.sh"
arnes_preludio < "$3" || exit 0; arnes_parse_input; arnes_parse_manifest
T0=${EPOCHREALTIME/./}; arnes_escrituras_bash; echo "detector: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
mapfile -t D <<< "$ARNES_ESCRITURAS"; echo "destinos ${#D[@]}"
T0=${EPOCHREALTIME/./}; for c in "${D[@]}"; do :; done; echo "bucle vacio: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; for c in "${D[@]}"; do _arnes_id_calcula "$c"; done; echo "solo calcula: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; for c in "${D[@]}"; do _arnes_id_guarda_x=1; ARNES_ID_RUTA="$c"; _arnes_id_guarda; done; echo "solo guarda: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; for c in "${D[@]}"; do ARNES_ID_RUTA=''; arnes_identidad "$c"; done; echo "restaura (memo): $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; for c in "${D[@]}"; do arnes_identidad "$c"; arnes_id_pertenece codigo; done; echo "restaura+pertenece codigo: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; for c in "${D[@]}"; do arnes_identidad "$c"; arnes_id_pertenece req; done; echo "restaura+pertenece req: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
