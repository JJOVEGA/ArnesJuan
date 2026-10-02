#!/usr/bin/env bash
# sonda-command-cr.sh — el CR en el `command` de Bash: solo se ANOTA (no se toca el analizador).
set -u
. "$(dirname "$0")/lib-r7.sh"
nuevo_proyecto
ln -s ../src/a.ts "$P/docs/k$CR"; ln -s ../src/a.ts "$P/docs/k${CR}z"
fila "K1 coordinadora: printf x > k␍ (CR final del command), cwd <raíz>/docs" guard.sh "$(j Bash "$P/docs" - "command=printf x > k$CR")"
fila "K2 coordinadora: printf x > k␍␊true (CR antes de un salto), cwd <raíz>/docs" guard.sh "$(j Bash "$P/docs" - "command=printf x > k$CR${NL}true")"
fila "K4 coordinadora: printf x > k␍z (CR en medio: el transporte no lo toca), cwd <raíz>/docs" guard.sh "$(j Bash "$P/docs" - "command=printf x > k${CR}z")"
fila "K5 control: printf x > k␍z ; true (CR en medio, no final)" guard.sh "$(j Bash "$P/docs" - "command=printf x > k${CR}z; true")"
echo "-- lo que el detector extrae, por árbol (lib directa):"
for k in cd6afa6 cand; do
  printf '   %-8s K1 destinos: %s\n' "$k" "$( . "${ARB[$k]}/lib.sh"; ARNES_INPUT="$(j Bash "$P/docs" - "command=printf x > k$CR")"; ARNES_INPUT_LISTO=''; arnes_parse_input; printf '%q ' "$ARNES_CMD"; printf -- '-> '; arnes_bash_escrituras "$ARNES_CMD" | while IFS= read -r d; do printf '%q ' "$d"; done)"
  printf '   %-8s K4 destinos: %s\n' "$k" "$( . "${ARB[$k]}/lib.sh"; ARNES_INPUT="$(j Bash "$P/docs" - "command=printf x > k${CR}z")"; ARNES_INPUT_LISTO=''; arnes_parse_input; printf '%q ' "$ARNES_CMD"; printf -- '-> '; arnes_bash_escrituras "$ARNES_CMD" | while IFS= read -r d; do printf '%q ' "$d"; done)"
done
echo "-- efecto real del shell: (cd docs && printf K > k␍) -> src/a.ts contiene: $( (cd "$P/docs" && printf 'K' > "k$CR"); cat "$P/src/a.ts")"
