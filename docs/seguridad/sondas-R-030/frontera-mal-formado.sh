#!/usr/bin/env bash
# R-030 · Comprueba la FRONTERA que el contrato nombra: la unica proteccion que
# un parentesis mal formado puede perder es un `critico` declarado en un REQ que
# no sea efectivamente sensible. Version base: d82d6cd. Solo lee.
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${1:-$(cd "$AQUI/../../.." && pwd)/hooks/lib.sh}"
[ -r "$LIB" ] || { echo "no puedo leer el lector: $LIB" >&2; exit 2; }
echo "lector: $LIB"
. "$LIB" >/dev/null 2>&1
ef() { ARNES_RIGOR_MATIZ=''; arnes_campos_normaliza '' '' "$2" '' "$1" 2>/dev/null; printf '%s' "$ARNES_RIGOR"; }
dif=0; tot=0; fuera=0
for niv in ligero estandar critico; do
  for s in si no '' quiza; do
    ok="$(ef "$niv (x)" "$s")"
    for mala in "$niv (x" "$niv (" "$niv (x) y" "$niv )(" "$niv ((x"; do
      m="$(ef "$mala" "$s")"; tot=$((tot+1))
      [ "$m" = "$ok" ] && continue
      dif=$((dif+1))
      printf '  DIFIERE  nivel=%-9s sens=%-6s cerrado=%-9s [%s]=%s\n' "$niv" "${s:-<aus>}" "$ok" "$mala" "$m"
      # Fuera de la frontera declarada = cualquier perdida que NO sea
      # `critico` con sensibilidad efectiva distinta de `si`.
      if [ "$niv" != critico ] || [ "$s" = si ] || [ "$s" = quiza ]; then fuera=$((fuera+1)); fi
    done
  done
done
printf 'pares=%d   celdas que cambian=%d   FUERA de la frontera declarada=%d\n' "$tot" "$dif" "$fuera"
[ "$fuera" -eq 0 ] && echo 'RESULTADO: OK — la frontera del contrato es EXACTA.' \
                   || { echo 'RESULTADO: FALLA — se pierde proteccion fuera de lo que el contrato nombra.'; exit 1; }
