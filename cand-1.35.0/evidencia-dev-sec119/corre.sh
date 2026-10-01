#!/usr/bin/env bash
# corre.sh <salida> — corre cada seccion (salvo 37, 38 y 43) con los hooks envueltos de la base y de la
# candidata, secuencial, y deja un log por seccion y arbol: una linea por llamada a un guardian.
set -uo pipefail
M="$(cd "$(dirname "$0")" && pwd)"; OUT="$1"; REPO=/home/juan/dev/ArnesJuan-v1.35
mkdir -p "$OUT"
cd "$REPO"
for f in tests/escenarios/hooks/secciones/[0-9][0-9]-*.sh; do
  b="${f##*/}"; b="${b%.sh}"
  case "$b" in 37-*|38-*|43-*) continue ;; esac
  for arbol in base cand; do
    : > "$OUT/$b.$arbol.log"
    MOTIVOS_LOG="$OUT/$b.$arbol.log" ARNES_JOBS=1 ARNES_HOOKS_DIR="$M/env-$arbol/hooks" \
      bash tests/escenarios/hooks/run.sh "secciones/$b.sh" > "$OUT/$b.$arbol.salida" 2>&1
    echo "rc=$?" >> "$OUT/$b.$arbol.salida"
  done
done
