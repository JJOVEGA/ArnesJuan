#!/usr/bin/env bash
# Réplica exacta de la invocación de `mide37` contra un lib dado.
LIB="$1"; FN="$2"; N="$3"; K="$4"; R="${5:-3}"
exec /home/juan/dev/ArnesJuan/tests/util/sonda-reloj.sh --k "$K" --r "$R" --etiqueta "$FN-$N" \
  --prep "source '$LIB' >/dev/null 2>&1 || :; s37=''; while [ \${#s37} -lt 512 ]; do s37+='Estado: en-revision -- relleno de cabecera '; done; l37=''; while [ \${#l37} -lt $N ]; do l37+=\"\$s37\"; done; l37=\"\${l37:0:$N}\"" \
  --sujeto "ARNES_CITA=0; ARNES_CR=0; $FN \"\$l37\"" 2>/dev/null
