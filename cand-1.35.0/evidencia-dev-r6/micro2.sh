H="$1"; export CLAUDE_PROJECT_DIR="$2"; FORMA="$3"
set -uo pipefail
. "$H/lib.sh"
ARNES_PROJ="$2"; ARNES_MANIFEST="$2/.arnes/config.json"; ARNES_CWD="$2"
ARNES_GIT_PROHIBIDOS_DEFECTO=x; arnes_parse_manifest
N=6000
case $FORMA in A) mk() { D="f$1"; } ;; B) mk() { D="d$1/f"; } ;; C) mk() { D="docs/../f$1"; } ;; esac
out="forma $FORMA us/destino:"
for c in 0 1 2 3 4 5 6 9; do
  t0=${EPOCHREALTIME/./}
  if [ $c = 0 ]; then for ((i=0;i<N;i++)); do mk $i; done
  else CORTE=$c; for ((i=0;i<N;i++)); do mk $i; _arnes_id_calcula "$D"; done; fi
  out+=" c$c=$(( (${EPOCHREALTIME/./} - t0) / N ))"
done
echo "$out"
