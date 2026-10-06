#!/usr/bin/env bash
# SEC-127 + QA-007-06, fase 2 (reparación): corridas del desarrollador, una tras otra.
set -u
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127; W=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad; T413="$S/t413"
{ date -Is; uname -a; bash --version | head -1; jq --version; echo "LANG=${LANG-} LC_ALL=${LC_ALL-<sin definir>}"
  echo "worktree $(git -C $W rev-parse --short HEAD) + la reparación sin comitear"; git -C $W status --short; git -C $W diff --stat 413c6bd -- hooks tools
  sha256sum $W/hooks/lib.sh $T413/hooks/lib.sh $B/hooks/lib.sh
  echo "413c6bd materializado con git archive en $T413: $(cd $T413 && git -C $W archive 413c6bd hooks | tar -t | wc -l) rutas"
  echo "v1.35.0 $(git -C $B rev-parse --short HEAD); hooks/ y tools/ frente a 3956a6f: $(git -C $B diff --quiet 3956a6f -- hooks tools && echo identicos || echo DIFIEREN)"; } > "$E/50-entorno-fase2.txt" 2>&1
cd "$W" || exit 1
S47=tests/escenarios/hooks/secciones/47-lectura-fallida-y-locale.sh; S44=tests/escenarios/hooks/secciones/44-integridad-de-la-entrada.sh
ARNES_HOOKS_DIR=$W/hooks    bash tests/escenarios/hooks/run.sh $S47 > "$E/51-s47-candidato.txt" 2>&1
ARNES_HOOKS_DIR=$T413/hooks bash tests/escenarios/hooks/run.sh $S47 > "$E/52-s47-413c6bd.txt" 2>&1
ARNES_HOOKS_DIR=$B/hooks    bash tests/escenarios/hooks/run.sh $S47 > "$E/53-s47-v1.35.0.txt" 2>&1
ARNES_HOOKS_DIR=$W/hooks    bash tests/escenarios/hooks/run.sh $S44 > "$E/54-s44-candidato.txt" 2>&1
# CA-69 2 (a): el banco de v1.35.0 tal cual, con los hooks del candidato, frente a ca54/22-
cd "$B" || exit 1
( time ARNES_HOOKS_DIR=$W/hooks ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh ) > "$E/60-banco-v1.35.0-hooks-candidato.txt" 2>&1
bash tests/escenarios/hooks/inventario.sh "$E/60-banco-v1.35.0-hooks-candidato.txt" > "$E/61-inventario.txt" 2>&1
diff "$E/../ca54/22-inventario-v1.35.0.txt" "$E/61-inventario.txt" > "$E/62-diff-inventario.txt"
cd "$W" || exit 1
( time ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh ) > "$E/70-banco-worktree.txt" 2>&1
bash tests/escenarios/hooks/inventario.sh "$E/70-banco-worktree.txt" > "$E/71-inventario-worktree.txt" 2>&1
diff "$E/31-inv-banco-worktree.txt" "$E/71-inventario-worktree.txt" > "$E/72-diff-inventario-worktree-fase1.txt"
bash tests/escenarios/hooks/autoprueba-corredor.sh > "$E/73-autoprueba.txt" 2>&1
{ for f in hooks/*.sh tools/*.sh; do bash -n "$f" || { echo "sintaxis: $f"; exit 1; }; done
  jq -e . hooks/hooks.json >/dev/null && jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null
  echo "gates rc=$?"; } > "$E/74-gates.txt" 2>&1
{ echo "== procesos fase 2; $(date -Is); carga $(cut -d' ' -f1-3 /proc/loadavg)"
  bash "$E/procesos-sec127.sh" "$W" "v1.35.0=$B/hooks" "413c6bd=$T413/hooks" "candidato=$W/hooks"; } > "$E/80-procesos.txt" 2>&1
echo FIN
