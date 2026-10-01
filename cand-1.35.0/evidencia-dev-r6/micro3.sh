H="$1"; export CLAUDE_PROJECT_DIR="$2"
set -uo pipefail
. "$H/lib.sh"
ARNES_PROJ="$2"; ARNES_MANIFEST="$2/.arnes/config.json"; ARNES_CWD="$2"
arnes_parse_manifest
N=10000
t() { local t0=${EPOCHREALTIME/./}; for ((i=0;i<N;i++)); do "$@"; done; printf '%-50s %6d ns\n' "$*" $(( (${EPOCHREALTIME/./}-t0)*1000/N )); }
arnes_identidad "f1"
t :
t arnes_id_pertenece codigo
t arnes_id_pertenece req
t _arnes_bajo "$ARNES_ID_F" "$ARNES_RAIZ_FIS"
t _arnes_casa_patron codigo f1 'src/*' 'app/*.ts' 'cfg/main.json'
t _arnes_casa_patron req f1 requirements
t _arnes_id_ln
f_nr() { local -n pats="ARNES_AMB_codigo_P"; :; }; t f_nr
f_set() { set -- "$ARNES_ID_F" "$ARNES_ID_F2"; [ "$ARNES_ID_O" = "$ARNES_ID_F" ] || set -- "$@" "$ARNES_ID_O"; }; t f_set
f_amb() { [ -n "${ARNES_AMB_LISTO[codigo]:-}" ] || _arnes_ambito codigo; }; t f_amb
t arnes_identidad f1
ARNES_ID_RUTA=''; f_rest() { ARNES_ID_RUTA=''; arnes_identidad f1; }; t f_rest
f_calc() { _arnes_id_calcula f1; }; t f_calc
t _arnes_lectura_fisica "$2/f1" 0
t _arnes_lectura_lexica "$2/f1"
t _arnes_id_guarda
