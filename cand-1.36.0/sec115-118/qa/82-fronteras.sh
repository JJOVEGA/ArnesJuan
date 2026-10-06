#!/usr/bin/env bash
# 82-fronteras.sh <scratch> <hooks>... — las dos fronteras de CA-68 «Cambio de compatibilidad declarado», bien
# construidas (en 80- quedaron corridas: el content sin salto final y un disco de 65 545 B). Una corrida por punto.
#  Piezas: Write de un REQ nuevo con content de 393 213 y 393 214 bytes TERMINADO EN SALTO (texto troceado =
#          content + 4 - 1 = 393 216 y 393 217).
#  Búsqueda: disco de exactamente D bytes y old_string de O bytes, new vacío: D x O = 2^32 (pasa a buscar) y
#          2^32 + D (deniega por presupuesto). El old es literal al final de una racha.
set -u; S="$1"; shift; QD="$(cd "$(dirname "$0")" && pwd)"; . "$QD/h.sh"
W="$(mktemp -d "$S/front-XXXX")"; trap 'rm -rf "$W"' EXIT; P="$W/p"
caso() { local H; for H in "${HS[@]}"; do printf '%-66s %-26s %s\n' "$1" "${H#/home/juan/dev/}" "$(corre "$H" guard.sh "$2" | cut -c1-140)"; done; }
HS=("$@"); echo "# $(date -Is)"
for n in 393213 393214; do mkp "$P"; { printf '# REQ-901\nEstado: en-revisión\n\n'; head -c $((n - 33)) /dev/zero | tr '\0' x; printf '\n'; } > "$W/c"
  jq -Rs --arg fp "$P/requirements/REQ-901.md" --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$fp,content:.}}' < "$W/c" > "$W/in"
  caso "Write REQ nuevo, content $(wc -c < "$W/c") B con salto final" "$W/in"; done
for par in 65536:65536 65537:65536 131072:32768 131073:32768; do D=${par%%:*}; O=${par#*:}; mkp "$P"
  { printf '# REQ-900\nEstado: en-revisión\n'; head -c $(( D - 31 )) /dev/zero | tr '\0' a; } > "$P/requirements/REQ-900.md"
  jq -n --arg fp "$P/requirements/REQ-900.md" --arg c "$P" --arg o "$(head -c "$O" /dev/zero | tr '\0' a)" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:$o,new_string:""}}' > "$W/in"
  caso "Edit: disco $(wc -c < "$P/requirements/REQ-900.md") B x old $O B = $(( $(wc -c < "$P/requirements/REQ-900.md") * O ))" "$W/in"; done
