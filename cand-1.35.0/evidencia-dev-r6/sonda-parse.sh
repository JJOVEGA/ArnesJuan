# sonda-parse.sh <hooks dir> : imprime los campos tal como los deja arnes_parse_input, en %q
H="$1"; shift
set -uo pipefail
. "$H/lib.sh"
while IFS= read -r -d '' js; do
  ARNES_INPUT="$js"; unset ARNES_INPUT_LISTO
  arnes_parse_input
  printf 'TOOL=%q AID=%q ATY=%q CWD=%q FP=%q CMD=%q\n' "$ARNES_TOOL" "$ARNES_AGENT_ID" "$ARNES_AGENT_TYPE" "${ARNES_CWD-<sin campo>}" "$ARNES_FP" "$ARNES_CMD"
done
