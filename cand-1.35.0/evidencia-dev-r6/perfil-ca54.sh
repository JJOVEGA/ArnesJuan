#!/usr/bin/env bash
# perfil-ca54.sh <hooks dir> <json> <proyecto> — tiempos por fase (ORIENTATIVO, no es la sonda de CA-54)
H="$1"; J="$2"; export CLAUDE_PROJECT_DIR="$3"
set -uo pipefail
. "$H/lib.sh"; . "$H/guard-git.sh"; . "$H/guard-codigo.sh"; . "$H/guard-completado.sh"
t() { echo $(( (${EPOCHREALTIME/./} - T0) / 1000 )); }
T0=${EPOCHREALTIME/./}
arnes_preludio < "$J" || exit 0
arnes_parse_input; echo "parse_input: $(t) ms"
T0=${EPOCHREALTIME/./}; esc="$(arnes_bash_escrituras "$ARNES_CMD")"; echo "detector (1 vez): $(t) ms, destinos=$(printf '%s\n' "$esc" | grep -c .)"
T0=${EPOCHREALTIME/./}; arnes_parse_manifest; echo "manifiesto: $(t) ms"
T0=${EPOCHREALTIME/./}; n=0; while IFS= read -r c; do [ -n "$c" ] || continue; arnes_identidad "$c"; n=$((n+1)); done <<< "$esc"; echo "identidad x$n: $(t) ms"
T0=${EPOCHREALTIME/./}; while IFS= read -r c; do [ -n "$c" ] || continue; arnes_identidad "$c"; arnes_id_pertenece codigo >/dev/null; done <<< "$esc"; echo "identidad(memo)+pertenece codigo: $(t) ms"
T0=${EPOCHREALTIME/./}; while IFS= read -r c; do [ -n "$c" ] || continue; arnes_identidad "$c"; arnes_id_pertenece req >/dev/null; done <<< "$esc"; echo "identidad(memo)+pertenece req: $(t) ms"
