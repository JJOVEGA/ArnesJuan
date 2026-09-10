#!/usr/bin/env bash
# mutar.sh <etiqueta> <sed-expr>
set -uo pipefail
D="$1"; W="$2"; ET="$3"; EXPR="$4"
S="$W/tests/escenarios/hooks/secciones/37-coste-del-escaner-2-las-razones.sh"
cp "$D/37-2.orig" "$S"
sed -i "$EXPR" "$S"
# LA COMPROBACION QUE NO SE SALTA: que la mutacion TOMO EFECTO
if cmp -s "$D/37-2.orig" "$S"; then echo "$ET|MUTACION-NO-TOMO-EFECTO|-"; exit 0; fi
if ! bash -n "$S" 2>/dev/null; then echo "$ET|MUTANTE-NO-COMPILA|-"; exit 0; fi
out="$(cd "$W" && bash tests/escenarios/hooks/run.sh secciones/37-coste-del-escaner-2-las-razones.sh 2>&1)"
res="$(printf '%s' "$out" | grep -oE 'Resultado: [0-9]+ PASS, [0-9]+ FAIL')"
cazado="$(printf '%s' "$out" | grep -E '^  FAIL' | sed -E 's/^  FAIL  ([^ ]+ [^ ]+ [^ ]+ [^ ]+).*/\1/' | tr '\n' ';')"
echo "$ET|${res:-SIN-RESULTADO}|${cazado:-NINGUNO}"
