#!/usr/bin/env bash
# QA-007-07 (P-136-N (A)): corridas finales, en serie. Uso: corridas-qa00707.sh
set -u; E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118; WT=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base
cd "$WT"
{ for f in hooks/*.sh tools/*.sh; do bash -n "$f" || echo "SINTAXIS $f"; done; jq -e . hooks/hooks.json >/dev/null && jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null; echo "gates rc=$?"; } > "$E/91-gates.txt" 2>&1
{ echo "# banco completo del worktree, ARNES_SEMILLA_41=23062, $(date -Is)"; ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$E/92-banco-candidato.txt"
bash tests/escenarios/hooks/inventario.sh "$E/92-banco-candidato.txt" > "$E/93-inventario-candidato.txt"
diff "$E/73-inventario-candidato.txt" "$E/93-inventario-candidato.txt" > "$E/94-diff-frente-a-73.txt"
(cd "$B" && { echo "# CA-69 2 (a): banco de v1.35.0 tal cual, ARNES_HOOKS_DIR=candidato, ARNES_SEMILLA_41=23062, $(date -Is)"; ARNES_SEMILLA_41=23062 ARNES_HOOKS_DIR="$WT/hooks" bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$E/95-banco-v1.35.0-con-candidato.txt"; bash tests/escenarios/hooks/inventario.sh "$E/95-banco-v1.35.0-con-candidato.txt" > "$E/96-inventario-v1.35.0-con-candidato.txt")
diff /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/22-inventario-v1.35.0.txt "$E/96-inventario-v1.35.0-con-candidato.txt" > "$E/97-diff-2a.txt"
bash "$E/30-procesos.sh" "$WT" v1.35.0="$B/hooks" candidato="$WT/hooks" > "$E/98-procesos.txt" 2>&1
echo listo
