#!/usr/bin/env bash
# Sonda: ¿el indicador ARNES_RIGOR_MATIZ contamina la lectura SIGUIENTE?
#
# POR QUE EXISTE. La corrección de `QA-P48-01` (v1.33.2) añade un indicador de
# estado —«este nivel salió de desenvolver un paréntesis»— que `arnes_rigor_efectivo`
# consulta. Un indicador que sobreviviera de una cabecera a la siguiente convertiría
# la lectura de un REQ en algo que depende del REQ leído ANTES, y eso es justo la
# clase de defecto que no aparece leyendo el diff: la puerta seguiría decidiendo
# bien caso por caso y mal en una corrida con varios REQ.
#
# QUE SE ESPERA. `arnes_campos_normaliza` pone el indicador a 0 al entrar, así que
# ninguna lectura hereda nada. El escenario (F) es el peor caso a propósito:
# ensucia el indicador A MANO antes de una lectura limpia. Si `ligero` limpio
# devolviera cualquier cosa distinta de `ligero`, el indicador contamina.
#
# Procedencia: la escribió la coordinadora al verificar el arreglo del
# desarrollador (2026-09-10); se guarda en el proyecto para que QA la re-ejecute
# sin reconstruirla. Seis escenarios, todos con `Sensible a seguridad: no` salvo
# donde se indique.
#
# Uso:  bash docs/estabilizacion/sonda-matiz-no-contamina.sh [ruta/a/hooks/lib.sh]
#       (por defecto, el lib.sh de ESTE árbol; se le puede apuntar a otro para
#        comparar contra una versión publicada)
set -u
LIB="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/hooks/lib.sh}"
[ -r "$LIB" ] || { echo "no puedo leer el lector: $LIB" >&2; exit 2; }
echo "lector bajo prueba: $LIB"
echo
# shellcheck source=/dev/null
. "$LIB"

leer() {  # <rigor> <sens>  -> imprime el nivel efectivo y el indicador
  arnes_campos_normaliza "pendiente" "pendiente" "$2" "" "$1" 2>/dev/null
  arnes_rigor_efectivo 2>/dev/null
  printf '    Rigor=%-22s Sens=%-4s -> %-9s (MATIZ=%s)\n' \
    "${1:-<ausente>}" "$2" "$ARNES_RIGOR" "${ARNES_RIGOR_MATIZ:-unset}"
}

echo "A) con matiz -> SIN matiz  (el 2o no debe heredar el indicador)"
leer "ligero (local)" no
leer "ligero" no
echo
echo "B) SIN matiz -> con matiz  (orden inverso)"
leer "ligero" no
leer "ligero (local)" no
echo
echo "C) con matiz -> campo AUSENTE"
leer "critico (por suelo)" no
leer "" no
echo
echo "D) con matiz -> valor no reconocido"
leer "ligero (x)" no
leer "basura" no
echo
echo "E) tres seguidos: matiz, limpio, matiz"
leer "ligero (a)" no; leer "ligero" no; leer "ligero (b)" no
echo
echo "F) indicador sucio A MANO antes de una lectura limpia (el peor caso)"
ARNES_RIGOR_MATIZ=1
arnes_campos_normaliza "pendiente" "pendiente" "no" "" "ligero" 2>/dev/null
arnes_rigor_efectivo 2>/dev/null
printf '    Rigor=ligero (indicador preensuciado) -> %-9s (MATIZ=%s)  %s\n' \
  "$ARNES_RIGOR" "${ARNES_RIGOR_MATIZ:-unset}" \
  "$([ "$ARNES_RIGOR" = ligero ] && echo OK || echo '<<< CONTAMINA')"
