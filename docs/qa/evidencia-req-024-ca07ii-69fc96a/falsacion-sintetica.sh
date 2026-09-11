set -u
TECHO07=1250; SER07=6; K07=4; PASS=0; FAIL=0
. "$1/decisor.sh"
p(){ echo "--- $1"; shift; veredicto07 sonda si "$@"; }
# regresion GRANDE (1,6x) con UNA repeticion ruidosa baja
p "1,6x en 3 de 4 y 1,2x en la cuarta (regresion grande + una toma ruidosa)" \
  1600000:1610000:1000000:1010000 1600000:1610000:1000000:1010000 1600000:1610000:1000000:1010000 1200000:1210000:1000000:1010000
# regresion de 5x con una toma buena
p "5x en 3 de 4 y 1,0x en la cuarta" \
  5000000:5010000:1000000:1010000 5000000:5010000:1000000:1010000 5000000:5010000:1000000:1010000 1000000:1010000:1000000:1010000
# justo en el techo: 1,250x exacto -> PASS (<=)
p "exactamente 1,250x en las cuatro" \
  1250000:1260000:1000000:1010000 1250000:1260000:1000000:1010000 1250000:1260000:1000000:1010000 1250000:1260000:1000000:1010000
# 1,251x -> FAIL
p "1,251x en las cuatro" \
  1251000:1260000:1000000:1010000 1251000:1260000:1000000:1010000 1251000:1260000:1000000:1010000 1251000:1260000:1000000:1010000
# CERO repeticiones
p "sin repeticiones"
# valores NEGATIVOS / no numericos
p "valor no numerico" abc:1010000:1000000:1010000
# division por cero potencial: uh=0
p "heredada = 0" 1000000:1010000:0:1010000
# arbol MAS RAPIDO que la base
p "este mas rapido que la base (0,5x)" 500000:510000:1000000:1010000
echo "contadores: PASS=$PASS FAIL=$FAIL"
