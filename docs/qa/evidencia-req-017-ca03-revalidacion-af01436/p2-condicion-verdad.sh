#!/usr/bin/env bash
# P2 — La CONDICION DE VERDAD del par plataforma/carga, rama por rama.
# Funciones REALES: mide37i (37/2:209-240), sonda_lee + sonda_num (run.sh:417,432-482),
# num37 (37/2:34), y razon37 + banda37 + mil37 del extracto de P1.
cd /home/juan/dev/ArnesJuan
D="$(dirname "$0")"
UTIL_DIR="/home/juan/dev/ArnesJuan/tests/util"
declare -A SONDA; SONDA_MOTIVO=''
FILTRO=""; PASS=0; FAIL=0
sed -n '417p;432,482p' tests/escenarios/hooks/run.sh > "$D"/sonda-lee-real.sh
source "$D"/sonda-lee-real.sh
source "$D"/fn-reales.sh          # num37, mil37, banda37, razon37
source "$D"/mide37i-real.sh       # mide37i
S37=70000

echo "### RAMA 1 — ABSTENCION/EMISION HABIENDO MEDIDO: el par es el de ESA medicion"
echo "Se invoca mide37i DOS veces sobre el MISMO arbol, con carga forzada distinta en medio."
echo "Si el par fuera heredado, las dos publicarian lo mismo."
mide37i "$PWD/hooks/lib.sh" arnes_sin_cita "$(( S37*2 ))" "$S37" 20
echo "  m1: PLAT=<$MED37_PLAT> CARGA=<$MED37_CARGA>   (loadavg real: $(cut -d' ' -f1 /proc/loadavg))"
# Forzador de carga: 8 bucles de CPU durante la 2a medicion
for i in 1 2 3 4 5 6 7 8; do ( while :; do :; done ) & done
sleep 25
mide37i "$PWD/hooks/lib.sh" arnes_sin_cita "$(( S37*2 ))" "$S37" 20
echo "  m2: PLAT=<$MED37_PLAT> CARGA=<$MED37_CARGA>   (loadavg real: $(cut -d' ' -f1 /proc/loadavg))"
kill %1 %2 %3 %4 %5 %6 %7 %8 2>/dev/null
wait 2>/dev/null
echo

echo "### RAMA 2 — SIN LINEA BASE (HER37_OK != si): mide37i NO SE LLAMA"
mide37i "$PWD/hooks/lib.sh" arnes_sin_cita "$(( S37*2 ))" "$S37" 20 && {
  u2="$MED37_A"; x2="$MED37_AX"; u1="$MED37_B"; x1="$MED37_BX"; }
echo "  tras la DIRECTA: PLAT=<$MED37_PLAT> CARGA=<$MED37_CARGA>"
razon37 'REQ-017 CA-03 directa' "$u2" "$u1" 2600 "cociente" "$x2" "$x1" no-excede \
  "modo=intercalado k=20 series=3 · plataforma=${MED37_PLAT:-n/a} carga=${MED37_CARGA:-n/a}"
HER37_OK=no
if [ "$HER37_OK" != si ]; then MED37_MOTIVO='no hay línea base v1.32.1 (tag ausente o árbol a medias)'; fi
razon37 'REQ-017 CA-03 fail-before' '' '' 2600 "el mismo cociente" '' '' excede \
  "modo=intercalado k=1 series=3 · plataforma=${MED37_PLAT:-n/a} carga=${MED37_CARGA:-n/a}"
echo "  >>> el par del fail-before es el de LA DIRECTA: no hay 'medicion que lo produjo'"
echo

echo "### RAMA 3 — FALLO ANTES DE LEER EL REGISTRO: par = n/a"
mide37i "/no/existe/lib.sh" arnes_sin_cita 140000 70000 20; rc=$?
echo "  rc=$rc motivo=<$MED37_MOTIVO> PLAT=<$MED37_PLAT> CARGA=<$MED37_CARGA>"
razon37 'REQ-017 CA-03 fail-before' '' '' 2600 "el mismo cociente" '' '' excede \
  "modo=intercalado k=1 series=3 · plataforma=${MED37_PLAT:-n/a} carga=${MED37_CARGA:-n/a}"
echo

echo "### RAMA 4 — SUELO DE 50 ms NO ALCANZADO: que vale el par? (el REQ NO lo afirma)"
mide37i "$PWD/hooks/lib.sh" arnes_sin_cita "$(( S37*2 ))" "$S37" 1   # k=1 -> muy por debajo del suelo
rc=$?
echo "  rc=$rc estado/motivo=<$MED37_MOTIVO> PLAT=<$MED37_PLAT> CARGA=<$MED37_CARGA>"
echo "  A=$MED37_A B=$MED37_B  (suelo = 50000 us)"
razon37 'REQ-017 CA-03 directa' "$MED37_A" "$MED37_B" 2600 "cociente" "$MED37_AX" "$MED37_BX" no-excede \
  "modo=intercalado k=1 series=3 · plataforma=${MED37_PLAT:-n/a} carga=${MED37_CARGA:-n/a}"
