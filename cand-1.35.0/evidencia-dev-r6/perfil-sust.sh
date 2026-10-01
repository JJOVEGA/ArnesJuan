H="$1"; export CLAUDE_PROJECT_DIR="$2"
set -uo pipefail
. "$H/lib.sh"
arnes_preludio < "$3" || exit 0; arnes_parse_input
arnes_bash_sin_texto "$ARNES_CMD"; l0="$ARNES_SIN_TEXTO"
s7() { l="${l//'$('/ }"; l="${l//)/ }"; l="${l//>|/>}"; l="${l//>>/>}"; l="${l//>/ > }"; l="${l//|/ | }"; l="${l//;/ ; }"; }
l="$l0"; T0=${EPOCHREALTIME/./}; s7; a="$l"; echo "UTF-8: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"
f() { local LC_ALL=C; l="$l0"; T0=${EPOCHREALTIME/./}; s7; echo "C: $(( (${EPOCHREALTIME/./}-T0)/1000 )) ms"; }; f; b="$l"
[ "$a" == "$b" ] && echo "resultado identico" || echo "DIFIERE"
# con multibyte y bytes invalidos intercalados
l0="${l0//echo/éch$'\xc3'o}"; l="$l0"; s7; a="$l"; f >/dev/null; b="$l"; [ "$a" == "$b" ] && echo "identico con multibyte e invalidos" || echo "DIFIERE con multibyte"
