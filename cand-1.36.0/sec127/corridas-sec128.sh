#!/usr/bin/env bash
# SEC-128 (P-136-J (A, acotada)), fase 2 corta del paso 5: corridas del desarrollador, una tras otra.
set -u
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127; W=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad; TA59="$S/ta59"
rm -rf "$TA59"; mkdir -p "$TA59" && git -C "$W" archive a59917d hooks tools | tar -x -C "$TA59"
{ date -Is; uname -a; bash --version | head -1; jq --version; echo "LANG=${LANG-} LC_ALL=${LC_ALL-<sin definir>}"
  echo "worktree $(git -C $W rev-parse --short HEAD) + la reparacion de SEC-128 sin comitear"; git -C $W status --short
  git -C $W diff --stat a59917d -- hooks tools
  sha256sum $W/hooks/guard-codigo.sh $TA59/hooks/guard-codigo.sh $W/hooks/lib.sh $TA59/hooks/lib.sh
  echo "v1.35.0 $(git -C $B rev-parse --short HEAD); hooks/ y tools/ frente a 3956a6f: $(git -C $B diff --quiet 3956a6f -- hooks tools && echo identicos || echo DIFIEREN)"; } > "$E/90-entorno-sec128.txt" 2>&1
cd "$W" || exit 1
S47=tests/escenarios/hooks/secciones/47-lectura-fallida-y-locale.sh; S44=tests/escenarios/hooks/secciones/44-integridad-de-la-entrada.sh
ARNES_HOOKS_DIR=$W/hooks    bash tests/escenarios/hooks/run.sh $S47 > "$E/91-s47-candidato.txt" 2>&1
ARNES_HOOKS_DIR=$TA59/hooks bash tests/escenarios/hooks/run.sh $S47 > "$E/92-s47-a59917d.txt" 2>&1
ARNES_HOOKS_DIR=$B/hooks    bash tests/escenarios/hooks/run.sh $S47 > "$E/93-s47-v1.35.0.txt" 2>&1
ARNES_HOOKS_DIR=$W/hooks    bash tests/escenarios/hooks/run.sh $S44 > "$E/94-s44-candidato.txt" 2>&1
ARNES_HOOKS_DIR=$TA59/hooks bash tests/escenarios/hooks/run.sh $S44 > "$E/95-s44-a59917d.txt" 2>&1
cd "$B" || exit 1
( time ARNES_HOOKS_DIR=$W/hooks ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh ) > "$E/a0-banco-v1.35.0-hooks-candidato.txt" 2>&1
bash tests/escenarios/hooks/inventario.sh "$E/a0-banco-v1.35.0-hooks-candidato.txt" > "$E/a1-inventario.txt" 2>&1
diff "$E/../ca54/22-inventario-v1.35.0.txt" "$E/a1-inventario.txt" > "$E/a2-diff-inventario.txt"
cd "$W" || exit 1
( time ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh ) > "$E/b0-banco-worktree.txt" 2>&1
bash tests/escenarios/hooks/inventario.sh "$E/b0-banco-worktree.txt" > "$E/b1-inventario-worktree.txt" 2>&1
diff "$E/71-inventario-worktree.txt" "$E/b1-inventario-worktree.txt" > "$E/b2-diff-inventario-worktree-fase2.txt"
bash tests/escenarios/hooks/autoprueba-corredor.sh > "$E/b3-autoprueba.txt" 2>&1
{ for f in hooks/*.sh tools/*.sh; do bash -n "$f" || { echo "sintaxis: $f"; exit 1; }; done
  jq -e . hooks/hooks.json >/dev/null && jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null
  echo "gates rc=$?"; } > "$E/b4-gates.txt" 2>&1
{ echo "== procesos SEC-128; $(date -Is); carga $(cut -d' ' -f1-3 /proc/loadavg)"
  bash "$E/procesos-sec127.sh" "$W" "v1.35.0=$B/hooks" "a59917d=$TA59/hooks" "candidato=$W/hooks"; } > "$E/c0-procesos.txt" 2>&1
sha256sum hooks/guard-codigo.sh hooks/lib.sh tests/escenarios/hooks/secciones/44-integridad-de-la-entrada.sh \
  tests/escenarios/hooks/secciones/47-lectura-fallida-y-locale.sh tests/escenarios/hooks/run.sh > "$E/c1-huellas.txt"
echo FIN
