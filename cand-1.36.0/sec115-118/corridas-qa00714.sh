#!/usr/bin/env bash
# QA-007-14 (P-136-R (A)): corridas finales, en serie. Uso: corridas-correctiva.sh <scratch>
set -u; S="${1:?}"; E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118; C="$E/qa00714"; WT=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base
cd "$WT"
{ echo "# $(date -Is) cabeza $(git rev-parse --short HEAD) + cambios"; git status --short; sha256sum hooks/*.sh; } > "$C/19-arbol.txt"
{ for f in hooks/*.sh tools/*.sh; do bash -n "$f" || echo "SINTAXIS $f"; done; jq -e . hooks/hooks.json >/dev/null && jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null; echo "gates rc=$?"; } > "$C/20-gates.txt" 2>&1
bash tests/escenarios/hooks/autoprueba-corredor.sh > "$C/21-autoprueba.txt" 2>&1
{ echo "# banco completo del worktree, ARNES_SEMILLA_41=23062, $(date -Is)"; ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$C/22-banco-candidato.txt"
bash tests/escenarios/hooks/inventario.sh "$C/22-banco-candidato.txt" > "$C/23-inventario-candidato.txt"
diff "$E/qa00713/23-inventario-candidato.txt" "$C/23-inventario-candidato.txt" > "$C/24-diff-frente-a-qa00713-23.txt"
(cd "$B" && { echo "# CA-69 2 (a): banco de v1.35.0 tal cual, ARNES_HOOKS_DIR=candidato, ARNES_SEMILLA_41=23062, $(date -Is)"; ARNES_SEMILLA_41=23062 ARNES_HOOKS_DIR="$WT/hooks" bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$C/25-banco-v1.35.0-con-candidato.txt"; bash tests/escenarios/hooks/inventario.sh "$C/25-banco-v1.35.0-con-candidato.txt" > "$C/26-inventario-v1.35.0-con-candidato.txt")
diff /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/22-inventario-v1.35.0.txt "$C/26-inventario-v1.35.0-con-candidato.txt" > "$C/27-diff-2a.txt"
bash "$E/30-procesos.sh" "$WT" v1.35.0="$B/hooks" candidato="$WT/hooks" > "$C/28-procesos.txt" 2>&1
bash "$E/06-e1.sh" "$S" "$WT/tests/escenarios/hooks/secciones/37-coste-del-escaner-3-la-pared.sh" 3 "$WT/hooks" "$B/hooks" > "$C/29-e1.txt" 2>&1
bash "$E/20-tope.sh" "$S" "$WT/hooks" > "$C/30-tope.txt" 2>&1
echo listo
