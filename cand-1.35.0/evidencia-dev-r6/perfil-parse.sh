H="$1"; export CLAUDE_PROJECT_DIR="$2"
. "$H/lib.sh"
IFS= read -r -d '' ARNES_INPUT < "$3"
T0=${EPOCHREALTIME/./}; out="$(jq -r '.tool_input.command' <<< "$ARNES_INPUT")"; echo "jq solo: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; arnes_sin_cr_transporte "$out"; echo "sin_cr UTF-8: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
g() { local LC_ALL=C; T0=${EPOCHREALTIME/./}; arnes_sin_cr_transporte "$out"; echo "sin_cr C: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"; }; g
T0=${EPOCHREALTIME/./}; arnes_parse_input; echo "parse_input entero: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
