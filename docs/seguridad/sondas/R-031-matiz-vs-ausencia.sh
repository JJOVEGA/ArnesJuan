#!/usr/bin/env bash
# R-031 — sonda del auditor-seguridad: la guarda del matiz contra el camino de ausencia (ADR-009).
#
# BASE: worktree /home/juan/dev/ArnesJuan-1.34-reparaciones, rama feat/1.34-reparaciones-astra,
#       cabeza 6e3bb90. Padre de comparacion: 2f7c821.
#
# METODO (suficiente para re-derivar cada cifra sin preguntar):
#   Se carga hooks/lib.sh del arbol que se pase como argumento 1 y se invoca `arnes_campos_normaliza`,
#   que es la UNICA cola de produccion que fija ARNES_RIGOR_MATIZ y llama a `arnes_rigor_efectivo`.
#   Invocar `arnes_rigor_efectivo` directamente NO reproduce el camino real y mediria otra cosa.
#   Se cruza {15 formas del campo Rigor} x {sensible si/no} x {ARNES_AUSENCIA_EXIGE false/true} = 60
#   celdas, y se imprime el rigor efectivo resultante. `unset ARNES_RIGOR_MATIZ` antes de cada celda
#   fuerza el peor caso de arrastre: si la guarda dependiera de un valor heredado de la celda
#   anterior, aqui se veria.
#
# COMO SE COMPARO (las cifras de R-031 §1):
#   mkdir -p /tmp/padre/hooks && git show 2f7c821:hooks/lib.sh > /tmp/padre/hooks/lib.sh
#   bash "$0" /tmp/padre                                  > /tmp/out-padre.txt
#   bash "$0" /home/juan/dev/ArnesJuan-1.34-reparaciones  > /tmp/out-cabeza.txt
#   diff /tmp/out-padre.txt /tmp/out-cabeza.txt
#
# RESULTADO MEDIDO el 2026-09-11 (Linux/WSL2, loadavg 0,75 0,84 0,69):
#   - 12 de 60 celdas cambian del padre a la cabeza; LAS 12 son `ligero` -> `estandar`.
#   - 0 celdas cambian hacia un nivel mas bajo.
#   - En la cabeza, 1 sola celda difiere entre ausencia_exige apagada y encendida: el campo Rigor
#     VACIO en REQ no sensible (`estandar` -> `critico`). Ninguna celda del dominio del matiz
#     cambia de opinion al encender la llave: las dos maquinarias no se tocan.
#   - En la cabeza, solo 2 celdas alcanzan `ligero`, y las dos son `Rigor: ligero` DESNUDO en REQ
#     no sensible — con la llave en cualquiera de sus dos estados.
LIB="$1/hooks/lib.sh"
. "$LIB" >/dev/null 2>&1
for exige in false true; do
  for sens in si no; do
    for r in "" "ligero" "ligero (local)" "LIGERO (x)" "ligero  (x)" "ligero ()" "ligero (a) (b)" "ligero (a (b))" "ligero (" "ligero (x) y" "estandar (x)" "critico (x)" "critico (" "basura" "basura (x)"; do
      ARNES_AUSENCIA_EXIGE="$exige"
      unset ARNES_RIGOR_MATIZ
      arnes_campos_normaliza "pendiente" "pendiente" "$sens" "" "$r" 2>/dev/null
      printf 'exige=%-5s sens=%-2s rigor=%-16s -> %s\n' "$exige" "$sens" "[$r]" "$ARNES_RIGOR"
    done
  done
done
