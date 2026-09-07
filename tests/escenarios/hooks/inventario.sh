#!/usr/bin/env bash
# Inventario ordenado de un banco: `<veredicto> TAB <identificador de caso>`, una línea
# por caso, en orden estable.
#
# POR QUÉ EXISTE (REQ-014 CA-12). Cuando el banco se reorganiza, «el banco pasa» no dice
# nada: dos casos que intercambian PASS y FAIL dan el mismo total, y esa es exactamente la
# forma en que un refactor del banco pierde cobertura sin que nadie lo vea. Lo que se
# compara es el INVENTARIO, caso por caso, byte a byte:
#
#   bash tests/escenarios/hooks/run.sh > /tmp/despues.txt
#   bash tests/escenarios/hooks/inventario.sh /tmp/antes.txt   > /tmp/inv-antes.txt
#   bash tests/escenarios/hooks/inventario.sh /tmp/despues.txt > /tmp/inv-despues.txt
#   diff /tmp/inv-antes.txt /tmp/inv-despues.txt   # vacío o no se ha hecho el trabajo
#
# Los milisegundos se normalizan a `Nms`: son la MEDIDA de un caso, no su identidad, y
# cambian en cada vuelta. Todo lo demás del nombre se conserva tal cual.
set -uo pipefail

if [ "$#" -ne 1 ] || [ ! -r "$1" ]; then
  echo "uso: inventario.sh <salida-del-banco.txt>" >&2
  exit 2
fi

sed -nE 's/^  (PASS|FAIL|SKIP)  (.*)$/\1\t\2/p' "$1" | sed -E 's/[0-9]+ms/Nms/g' | LC_ALL=C sort
