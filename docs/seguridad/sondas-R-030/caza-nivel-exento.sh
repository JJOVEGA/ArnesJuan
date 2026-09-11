#!/usr/bin/env bash
# R-030 · Comprueba la mitad ABSOLUTA de la promesa: «ninguna forma que contenga
# `(` alcanza `ligero`», el unico nivel exento de `QA: aprobado`.
# Version base: d82d6cd. Solo lee; no escribe nada.
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${1:-$(cd "$AQUI/../../.." && pwd)/hooks/lib.sh}"
ALF="${2:-$AQUI/alfabeto-hostil.txt}"
[ -r "$LIB" ] || { echo "no puedo leer el lector: $LIB" >&2; exit 2; }
echo "lector: $LIB"
. "$LIB" >/dev/null 2>&1
n=0; hit=0
while IFS= read -r r; do
  case "$r" in *'('*) ;; *) continue ;; esac   # solo formas CON parentesis
  for s in si no '' quiza; do
    ARNES_RIGOR_MATIZ=''
    arnes_campos_normaliza '' '' "$s" '' "$r" 2>/dev/null
    n=$((n+1))
    if [ "$ARNES_RIGOR" = ligero ]; then
      hit=$((hit+1)); printf '  ALCANZA EL NIVEL EXENTO: sens=%-6s [%s]\n' "${s:-<aus>}" "$r"
    fi
  done
done < "$ALF"
printf 'lecturas con parentesis=%d   alcanzan `ligero`=%d\n' "$n" "$hit"
[ "$hit" -eq 0 ] && echo 'RESULTADO: OK — la promesa absoluta se sostiene.' \
                 || { echo 'RESULTADO: FALLA — la promesa absoluta es una SOBREAFIRMACION.'; exit 1; }
