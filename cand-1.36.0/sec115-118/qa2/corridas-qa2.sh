#!/usr/bin/env bash
# corridas-qa2.sh — corridas sensibles al reloj de la re-verificación, EN SERIE, sin otras corridas de QA en paralelo.
set -u; E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2/..; Q=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2; S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad; WT=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base; export TMPDIR=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
cd "$WT"
{ echo "# $(date -Is) cabeza $(git rev-parse --short HEAD)"; git status --short; sha256sum hooks/*.sh; git diff --stat 03cbf5e HEAD -- hooks tools tests; } > "$Q/60-arbol.txt"
{ for f in hooks/*.sh tools/*.sh; do bash -n "$f" || echo "SINTAXIS $f"; done; jq -e . hooks/hooks.json >/dev/null && jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null; echo "gates rc=$?"; } > "$Q/61-gates.txt" 2>&1
bash tests/escenarios/hooks/autoprueba-corredor.sh > "$Q/62-autoprueba.txt" 2>&1
{ echo "# banco completo del worktree, ARNES_SEMILLA_41=23062, $(date -Is), carga $(cat /proc/loadavg)"; ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$Q/63-banco-candidato.txt"
bash tests/escenarios/hooks/inventario.sh "$Q/63-banco-candidato.txt" > "$Q/64-inventario-candidato.txt"
diff "$E/correctiva/23-inventario-candidato.txt" "$Q/64-inventario-candidato.txt" > "$Q/65-diff-frente-a-correctiva23.txt"
diff "$E/93-inventario-candidato.txt" "$Q/64-inventario-candidato.txt" > "$Q/65b-diff-frente-a-93.txt"
(cd "$B" && { echo "# CA-69 2 (a): banco de v1.35.0 tal cual, ARNES_HOOKS_DIR=candidato, ARNES_SEMILLA_41=23062, $(date -Is), carga $(cat /proc/loadavg)"; ARNES_SEMILLA_41=23062 ARNES_HOOKS_DIR="$WT/hooks" bash tests/escenarios/hooks/run.sh 2>&1; echo "rc=$?"; } > "$Q/66-banco-v1.35.0-con-candidato.txt"; bash tests/escenarios/hooks/inventario.sh "$Q/66-banco-v1.35.0-con-candidato.txt" > "$Q/67-inventario-v1.35.0-con-candidato.txt")
diff /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/22-inventario-v1.35.0.txt "$Q/67-inventario-v1.35.0-con-candidato.txt" > "$Q/68-diff-2a.txt"
bash "$E/30-procesos.sh" "$WT" v1.35.0="$B/hooks" 8e11f87="$S/t/8e11f87/hooks" candidato="$WT/hooks" > "$Q/70-procesos.txt" 2>&1
bash "$E/06-e1.sh" "$S" "$WT/tests/escenarios/hooks/secciones/37-coste-del-escaner-3-la-pared.sh" 3 "$WT/hooks" "$B/hooks" > "$Q/71-e1.txt" 2>&1
{ echo "# T2b x5 (candidato): seccion 47 con filtro 'T2b', $(date -Is)"; for i in 1 2 3 4 5; do echo "## candidato $i loadavg $(cat /proc/loadavg)"; bash tests/escenarios/hooks/run.sh tests/escenarios/hooks/secciones/47-decision-emitida.sh T2b 2>&1 | grep -E "PASS|FAIL"; done; } > "$Q/72-t2b.txt"
bash "$E/qa/82-fronteras.sh" "$S" "$WT/hooks" > "$Q/73-fronteras.txt" 2>&1
bash "$Q/50-reqs-reales.sh" "$WT/hooks" "$B/hooks" > "$Q/74-reqs-reales.txt" 2>&1
echo "# fin $(date -Is)" >> "$Q/60-arbol.txt"
echo fin
