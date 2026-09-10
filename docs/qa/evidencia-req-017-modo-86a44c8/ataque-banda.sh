#!/usr/bin/env bash
set -uo pipefail
source "$1"          # la guarda REAL, extraida byte a byte
T=2600
# ORACULO INDEPENDIENTE de QA: no toca banda37 ni razon37.
oraculo() { # <mn> <md> <dir> -> PASS|FAIL  (el veredicto del cociente SOLO)
  local c=$(( $1 * 1000 / $2 ))
  if [ "$3" = no-excede ]; then [ "$c" -le "$T" ] && echo PASS || echo FAIL
  else [ "$c" -gt "$T" ] && echo PASS || echo FAIL; fi
}
prueba() { # <mn> <xn> <md> <xd> <dir> <etiqueta>
  local sin con
  sin="$(oraculo "$1" "$3" "$5")"
  BAN37_V='?'
  banda37 "$1" "$2" "$3" "$4" "$T" "$5" 2>/dev/null || BAN37_V='RC1'
  con="$BAN37_V"
  local marca=''
  [ "$sin" = FAIL ] && [ "$con" = PASS ] && marca='  <<<< FAIL->PASS'
  printf '%-34s mn=%-7s xn=%-7s md=%-7s xd=%-7s %-9s sin=%-4s con=%-4s%s\n' \
    "$6" "$1" "$2" "$3" "$4" "$5" "$sin" "$con" "$marca"
}
echo "=== A. Las 7 entradas del desarrollador (reproduccion) ==="
prueba 200000 210000 100000 105000 no-excede "1 banda bajo techo"
prueba 400000 410000 100000 102000 no-excede "2 banda encima"
prueba 250000 300000 100000 120000 no-excede "3 techo dentro, coc conforme"
prueba 270000 320000 100000 120000 no-excede "4 techo dentro, coc no conf"
prueba 400000 410000 100000 102000 excede    "5 fail-before toda encima"
prueba 200000 210000 100000 105000 excede    "6 fail-before ninguna"
prueba 270000 320000 100000 120000 excede    "7 techo dentro invertido"
echo
echo "=== B. Lo que su tabla NO contiene: max < min (precondicion no comprobada) ==="
prueba 270000 100000 100000 100000 no-excede "B1 xn<mn (max num absurdo)"
prueba 270000 270000 100000  60000 no-excede "B2 xd<md (max den absurdo)"
prueba 400000  90000 100000 100000 no-excede "B3 xn<mn extremo"
prueba 200000 200000 100000  50000 excede    "B4 xd<md en fail-before"
echo
echo "=== C. Cero y vacio en el maximo (num37 acepta 0) ==="
prueba 270000 320000 100000      0 no-excede "C1 xd=0 division por cero"
prueba 270000      0 100000 120000 no-excede "C2 xn=0"
echo
echo "=== D. Frontera exacta del techo ==="
prueba 260000 260000 100000 100000 no-excede "D1 HI == techo justo"
prueba 260001 260100 100000 100000 no-excede "D2 HI un pelo encima"
prueba 260000 260000 100000 100000 excede    "D3 LO == techo (excede)"
prueba 260100 260100 100000 100000 excede    "D4 LO un pelo encima"
echo
echo "=== E. Banda de anchura cero (min==max): debe decidir igual que sin guarda ==="
prueba 270000 270000 100000 100000 no-excede "E1"
prueba 250000 250000 100000 100000 no-excede "E2"
prueba 270000 270000 100000 100000 excede    "E3"
echo
echo "=== F. Desbordamiento ==="
prueba 9223372036854775 9223372036854775 100000 100000 no-excede "F1 cerca de 2^63/1000"
prueba 92233720368547758 92233720368547758 100000 100000 no-excede "F2 lo pasa"
