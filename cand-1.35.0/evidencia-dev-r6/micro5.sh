H="$1"; export CLAUDE_PROJECT_DIR="$2"
set -uo pipefail
N=20000
t() { local t0=${EPOCHREALTIME/./}; for ((i=0;i<N;i++)); do "$@"; done; printf '%-40s %6d ns\n' "$*" $(( (${EPOCHREALTIME/./}-t0)*1000/N )); }
pp1() { local amb="$1" x rel; [ "${CORTE:-9}" = 1 ] && return 0; }
t pp1 codigo
. "$H/lib.sh"
ARNES_PROJ="$2"; ARNES_MANIFEST="$2/.arnes/config.json"; ARNES_CWD="$2"
t pp1 codigo
arnes_parse_manifest
t pp1 codigo
arnes_identidad "f1"
t pp1 codigo
for ((k=0;k<8000;k++)); do arnes_identidad "g$k"; done
t pp1 codigo
echo "vars: $(compgen -v | wc -l)  IDM_E: ${#ARNES_IDM_E[@]}"
