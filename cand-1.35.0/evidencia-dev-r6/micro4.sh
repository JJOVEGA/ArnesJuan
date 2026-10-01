H="$1"; export CLAUDE_PROJECT_DIR="$2"
set -uo pipefail
. "$H/lib.sh"
ARNES_PROJ="$2"; ARNES_MANIFEST="$2/.arnes/config.json"; ARNES_CWD="$2"
arnes_parse_manifest; arnes_identidad "f1"; arnes_id_pertenece codigo
N=10000; out=''
for c in 0 1 2 3 4 5 6 9; do CORTE=$c; t0=${EPOCHREALTIME/./}; if [ $c = 0 ]; then for ((i=0;i<N;i++)); do :; done; else for ((i=0;i<N;i++)); do arnes_id_pertenece codigo; done; fi; out+=" c$c=$(( (${EPOCHREALTIME/./}-t0)*1000/N ))"; done
echo "$out"
