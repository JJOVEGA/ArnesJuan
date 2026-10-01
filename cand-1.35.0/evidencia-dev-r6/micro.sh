H="$1"; export CLAUDE_PROJECT_DIR="$2"; FORMA="$3"
set -uo pipefail
. "$H/lib.sh"
ARNES_PROJ="$2"; ARNES_MANIFEST="$2/.arnes/config.json"; ARNES_CWD="$2"
ARNES_GIT_PROHIBIDOS_DEFECTO=x; arnes_parse_manifest
N=3000
case $FORMA in A) mk() { D="f$1"; } ;; B) mk() { D="d$1/f"; } ;; C) mk() { D="docs/../f$1"; } ;; esac
t0=${EPOCHREALTIME/./}; for ((i=0;i<N;i++)); do mk $i; done; tb=$(( ${EPOCHREALTIME/./} - t0 ))
t0=${EPOCHREALTIME/./}; for ((i=0;i<N;i++)); do mk $i; _arnes_id_calcula "$D"; done; t1=$(( ${EPOCHREALTIME/./} - t0 - tb ))
t0=${EPOCHREALTIME/./}; for ((i=0;i<N;i++)); do mk $i; _arnes_id_calcula "$D"; _arnes_id_guarda; done; t2=$(( ${EPOCHREALTIME/./} - t0 - tb ))
t0=${EPOCHREALTIME/./}; for ((i=0;i<N;i++)); do mk $i; ARNES_ID_RUTA=''; arnes_identidad "$D"; done; t3=$(( ${EPOCHREALTIME/./} - t0 - tb ))
t0=${EPOCHREALTIME/./}; for ((i=0;i<N;i++)); do mk $i; arnes_identidad "$D"; arnes_id_pertenece codigo; done; t4=$(( ${EPOCHREALTIME/./} - t0 - tb ))
t0=${EPOCHREALTIME/./}; for ((i=0;i<N;i++)); do mk $i; arnes_identidad "$D"; arnes_id_pertenece req; done; t5=$(( ${EPOCHREALTIME/./} - t0 - tb ))
t0=${EPOCHREALTIME/./}; for ((i=0;i<N;i++)); do mk $i; _arnes_lectura_lexica "$2/$D"; done; t6=$(( ${EPOCHREALTIME/./} - t0 - tb ))
t0=${EPOCHREALTIME/./}; for ((i=0;i<N;i++)); do mk $i; _arnes_lectura_fisica "$2/$D" 0; done; t7=$(( ${EPOCHREALTIME/./} - t0 - tb ))
t0=${EPOCHREALTIME/./}; for ((i=0;i<N;i++)); do mk $i; [ -L "$2/$D" ]; [ -e "$2/$D" ]; done; t8=$(( ${EPOCHREALTIME/./} - t0 - tb ))
echo "forma $FORMA, us por destino: calcula=$((t1/N)) calcula+guarda=$((t2/N)) identidad(sin memo,1a vez ya memo)=$((t3/N)) identidad(memo)+pert_codigo=$((t4/N)) identidad(memo)+pert_req=$((t5/N)) lexica=$((t6/N)) fisica=$((t7/N)) stat-L-e=$((t8/N))"
