#!/usr/bin/env bash
# Fase 2 (paso 6 de 1.36.0): las corridas FINALES sobre el árbol final del worktree, en serie.
# Uso: corridas-fase2.sh <scratch>
set -u; S="${1:?}"; E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118; WT=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base
cd "$WT"
{ echo "# $(date -Is) arbol final: cabeza $(git rev-parse --short HEAD) + cambios sin confirmar"; git status --short; sha256sum hooks/*.sh hooks/*.awk 2>/dev/null; } > "$E/69-arbol-final.txt"
{ for f in hooks/*.sh tools/*.sh; do bash -n "$f" || echo "SINTAXIS $f"; done; jq -e . hooks/hooks.json >/dev/null && jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null; echo "gates rc=$?"; } > "$E/70-gates.txt" 2>&1
bash tests/escenarios/hooks/autoprueba-corredor.sh > "$E/71-autoprueba.txt" 2>&1
{ echo "# banco completo del worktree, ARNES_SEMILLA_41=23062, $(date -Is)"; ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$E/72-banco-candidato.txt"
bash tests/escenarios/hooks/inventario.sh "$E/72-banco-candidato.txt" > "$E/73-inventario-candidato.txt"
comm -23 <(sort /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/22-inventario-v1.35.0.txt) <(sort "$E/73-inventario-candidato.txt") > "$E/74-lineas-de-22-que-faltan-en-candidato.txt"
(cd "$B" && { echo "# CA-69 2 (a) final: banco de v1.35.0 tal cual, ARNES_HOOKS_DIR=candidato, ARNES_SEMILLA_41=23062, $(date -Is)"; ARNES_SEMILLA_41=23062 ARNES_HOOKS_DIR="$WT/hooks" bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$E/75-banco-v1.35.0-con-candidato.txt"; bash tests/escenarios/hooks/inventario.sh "$E/75-banco-v1.35.0-con-candidato.txt" > "$E/76-inventario-v1.35.0-con-candidato.txt")
diff /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/22-inventario-v1.35.0.txt "$E/76-inventario-v1.35.0-con-candidato.txt" > "$E/77-diff-2a.txt"
bash "$E/06-e1.sh" "$S" "$WT/tests/escenarios/hooks/secciones/37-coste-del-escaner-3-la-pared.sh" 3 "$WT/hooks" "$B/hooks" > "$E/78-e1.txt" 2>&1
bash "$E/41-e2.sh" "$WT/hooks" "$B" 6 > "$E/79-e2.txt" 2>&1
bash "$E/30-procesos.sh" "$WT" v1.35.0="$B/hooks" candidato="$WT/hooks" > "$E/80-procesos.txt" 2>&1
bash "$E/20-tope.sh" "$S" "$WT/hooks" > "$E/81-tope.txt" 2>&1
echo listo
