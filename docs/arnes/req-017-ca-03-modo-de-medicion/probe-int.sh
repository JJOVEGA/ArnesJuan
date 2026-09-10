#!/usr/bin/env bash
# Dos sujetos INTERCALADOS en una sola invocación: a = 2S, b = S, razon = min_a/min_b.
LIB="$1"; FN="$2"; S="$3"; K="$4"; R="${5:-3}"
exec /home/juan/dev/ArnesJuan/tests/util/sonda-reloj.sh --k "$K" --r "$R" --etiqueta "$FN-$S-int" \
  --prep "source '$LIB' >/dev/null 2>&1 || :; s37=''; while [ \${#s37} -lt 512 ]; do s37+='Estado: en-revision -- relleno de cabecera '; done; l37=''; while [ \${#l37} -lt $(( S * 2 )) ]; do l37+=\"\$s37\"; done; b37=\"\${l37:0:$S}\"; a37=\"\${l37:0:$(( S * 2 ))}\"" \
  --sujeto-a "ARNES_CITA=0; ARNES_CR=0; $FN \"\$a37\"" \
  --sujeto-b "ARNES_CITA=0; ARNES_CR=0; $FN \"\$b37\"" 2>&1
