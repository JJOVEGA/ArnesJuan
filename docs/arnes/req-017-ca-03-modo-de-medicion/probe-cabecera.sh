#!/usr/bin/env bash
. "$1/hooks/lib.sh" >/dev/null 2>&1 || { echo "no carga"; exit 2; }
ARNES_TEXTO="$(cat "$2")"
ARNES_OCULTA=0; ARNES_OCULTA_CLAVE=''; ARNES_OCULTA_REPR=''
arnes_campos_req "$ARNES_TEXTO" 2>/dev/null
echo "QA=<${ARNES_QA:-}>"
echo "SEG=<${ARNES_SEG:-}>"
echo "SENS=<${ARNES_SENS:-}>"
echo "RIGOR=<${ARNES_RIGOR:-}>"
echo "HALL=<${ARNES_HALL:0:120}>"
echo "GUARDA ARNES_OCULTA=${ARNES_OCULTA:-0} clave=${ARNES_OCULTA_CLAVE:-()} repr=${ARNES_OCULTA_REPR:-()}"
