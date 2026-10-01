H="$1"; export CLAUDE_PROJECT_DIR="$2"
set -uo pipefail
. "$H/lib.sh"; . "$H/guard-git.sh"; . "$H/guard-codigo.sh"; . "$H/guard-completado.sh"
T0=${EPOCHREALTIME/./}; arnes_preludio < "$3" || exit 0; arnes_parse_input; echo "preludio+parse: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; arnes_guard_git; echo "guard_git: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; arnes_guard_codigo; echo "guard_codigo: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
T0=${EPOCHREALTIME/./}; arnes_guard_completado; echo "guard_completado: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
