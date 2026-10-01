H="$1"; export CLAUDE_PROJECT_DIR="$2"
set -uo pipefail
. "$H/lib.sh"
arnes_preludio < "$3" || exit 0; arnes_parse_input
c="$ARNES_CMD"
T0=${EPOCHREALTIME/./}; arnes_bash_sin_texto "$c"; echo "sin_texto: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
l="$ARNES_SIN_TEXTO"
T0=${EPOCHREALTIME/./}
l="${l//'$('/ }"; l="${l//)/ }"; l="${l//>|/>}"; l="${l//>>/>}"; l="${l//>/ > }"; l="${l//|/ | }"; l="${l//;/ ; }"
echo "7 sustituciones: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; set -f; IFS=$' \t\n'; t=($l); set +f; echo "troceo (${#t[@]} palabras): $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; x="$(arnes_bash_escrituras "$c")"; echo "detector entero: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; mapfile -t arr <<< "$x"; echo "mapfile ${#arr[@]}: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; n=0; while IFS= read -r d; do n=$((n+1)); done <<< "$x"; echo "while-read $n: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
