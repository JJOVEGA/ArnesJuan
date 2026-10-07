#!/usr/bin/env bash
# corridas-qa4.sh — re-verificación acotada de la línea de P-136-R, EN SERIE, sin otras corridas de QA en paralelo.
set -u; E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118; Q=$E/qa4; S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad; WT=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base; T=$S/q4t; export TMPDIR=$S
cd "$WT"
{ echo "# $(date -Is) cabeza $(git rev-parse --short HEAD)"; git status --short; sha256sum hooks/*.sh; git diff --stat c5bf6d4 HEAD -- hooks tools tests; echo "# frente a 39e6128:"; git diff --stat 39e6128 HEAD -- hooks tools tests; } > "$Q/19-arbol.txt"
{ for f in hooks/*.sh tools/*.sh; do bash -n "$f" || echo "SINTAXIS $f"; done; jq -e . hooks/hooks.json >/dev/null && jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null; echo "gates rc=$?"; } > "$Q/20-gates.txt" 2>&1
{ echo "# seccion 47 (selector), hooks=candidato, $(date -Is), carga $(cat /proc/loadavg)"; bash tests/escenarios/hooks/run.sh tests/escenarios/hooks/secciones/47-decision-emitida.sh 2>&1; echo "rc=$?"; } > "$Q/01-seccion47-candidato.txt"
{ echo "# seccion 47 (selector), hooks=39e6128 ($T/39e6128/hooks), $(date -Is), carga $(cat /proc/loadavg)"; ARNES_HOOKS_DIR="$T/39e6128/hooks" bash tests/escenarios/hooks/run.sh tests/escenarios/hooks/secciones/47-decision-emitida.sh 2>&1; echo "rc=$?"; } > "$Q/02-seccion47-39e6128.txt"
bash "$Q/14-estatico.sh" "$WT" > "$Q/14-estatico.txt" 2>&1
bash "$E/qa2/40-limpieza-ataque.sh" "$Q/03-limpieza-567.txt" candidato="$WT/hooks"
bash "$E/qa3/10-ataque-ampliado.sh" "$Q/11-ataque-ampliado-900.txt" candidato="$WT/hooks"
bash "$Q/15-cuerpos-extra.sh" "$Q/16-cuerpos-extra.txt" candidato="$WT/hooks"
bash tests/escenarios/hooks/autoprueba-corredor.sh > "$Q/21-autoprueba.txt" 2>&1
{ echo "# banco completo del worktree, ARNES_SEMILLA_41=23062, $(date -Is), carga $(cat /proc/loadavg)"; ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$Q/22-banco-candidato.txt"
bash tests/escenarios/hooks/inventario.sh "$Q/22-banco-candidato.txt" > "$Q/23-inventario-candidato.txt"
{ echo "# frente a qa00714/23-"; diff "$E/qa00714/23-inventario-candidato.txt" "$Q/23-inventario-candidato.txt"; echo "# frente a qa3/23-"; diff "$E/qa3/23-inventario-candidato.txt" "$Q/23-inventario-candidato.txt"; } > "$Q/24-diff-inventario.txt"
(cd "$B" && { echo "# CA-69 2 (a): banco de v1.35.0 tal cual, ARNES_HOOKS_DIR=candidato, ARNES_SEMILLA_41=23062, $(date -Is), carga $(cat /proc/loadavg)"; ARNES_SEMILLA_41=23062 ARNES_HOOKS_DIR="$WT/hooks" bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$Q/25-banco-v1.35.0-con-candidato.txt"; bash tests/escenarios/hooks/inventario.sh "$Q/25-banco-v1.35.0-con-candidato.txt" > "$Q/26-inventario-v1.35.0-con-candidato.txt")
diff "$E/../ca54/22-inventario-v1.35.0.txt" "$Q/26-inventario-v1.35.0-con-candidato.txt" > "$Q/27-diff-2a.txt"
bash "$E/30-procesos.sh" "$WT" v1.35.0="$B/hooks" 39e6128="$T/39e6128/hooks" candidato="$WT/hooks" > "$Q/28-procesos.txt" 2>&1
bash "$E/06-e1.sh" "$S" "$WT/tests/escenarios/hooks/secciones/37-coste-del-escaner-3-la-pared.sh" 3 "$WT/hooks" "$B/hooks" > "$Q/29-e1.txt" 2>&1
bash "$E/20-tope.sh" "$S" "$WT/hooks" > "$Q/30-tope.txt" 2>&1
echo "# fin $(date -Is)" >> "$Q/19-arbol.txt"
echo fin
