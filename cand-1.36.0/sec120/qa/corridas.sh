#!/usr/bin/env bash
# Corridas de QA (fase 3 de SEC-120). Una tras otra, para no compartir el anfitrión.
set -u
W=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base; Q=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120/qa; T82=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/t82
{ date -Is; uname -a; bash --version | head -1; jq --version; git -C $W rev-parse HEAD; git -C $W status --short | wc -l; sha256sum $W/hooks/*.sh $W/hooks/*.awk; } > $Q/00-entorno.txt 2>&1
cd $W
S44=tests/escenarios/hooks/secciones/44-integridad-de-la-entrada.sh
ARNES_HOOKS_DIR=$W/hooks   bash tests/escenarios/hooks/run.sh $S44 > $Q/10-s44-candidato.txt 2>&1
ARNES_HOOKS_DIR=$T82/hooks bash tests/escenarios/hooks/run.sh $S44 > $Q/11-s44-82ceb63.txt 2>&1
ARNES_HOOKS_DIR=$B/hooks   bash tests/escenarios/hooks/run.sh $S44 > $Q/12-s44-v1.35.0.txt 2>&1
cd $B
( time ARNES_HOOKS_DIR=$W/hooks ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh ) > $Q/20-banco-v1.35.0-hooks-candidato.txt 2>&1
bash tests/escenarios/hooks/inventario.sh $Q/20-banco-v1.35.0-hooks-candidato.txt > $Q/21-inventario.txt 2>&1
diff $Q/../../ca54/22-inventario-v1.35.0.txt $Q/21-inventario.txt > $Q/22-diff-inventario.txt
cd $W
( time ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh ) > $Q/30-banco-worktree.txt 2>&1
bash tests/escenarios/hooks/autoprueba-corredor.sh > $Q/31-autoprueba.txt 2>&1
{ for f in hooks/*.sh tools/*.sh; do bash -n "$f" || { echo "FALLA $f"; exit 1; }; done; jq -e . hooks/hooks.json >/dev/null && jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null; echo "gates rc=$?"; } > $Q/32-gates.txt 2>&1
echo FIN > $Q/.fin
