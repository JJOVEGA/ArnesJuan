#!/usr/bin/env bash
# SEC-127 + QA-007-06, fase 1 (sin reparar): corridas del desarrollador. Se lanza desde cualquier sitio.
set -u
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127; W=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base
cd "$W" || exit 1
{ date -Is; uname -a; bash --version | head -1; jq --version; env --version | head -1; locale -a 2>/dev/null | grep -i '^c\.utf' ; echo "LANG=${LANG-} LC_ALL=${LC_ALL-<sin definir>}"
  echo "worktree $(git rev-parse --short HEAD) (cand/1.36.0); hooks/ y tools/ frente a 413c6bd: $(git diff --quiet 413c6bd -- hooks tools && echo identicos || echo DIFIEREN)"
  echo "base v1.35.0 $(git -C "$B" rev-parse --short HEAD); hooks/ y tools/ frente a 3956a6f: $(git -C "$B" diff --quiet 3956a6f -- hooks tools && echo identicos || echo DIFIEREN)"
  sha256sum tests/escenarios/hooks/secciones/47-lectura-fallida-y-locale.sh tests/escenarios/hooks/run.sh; } > "$E/00-entorno.txt" 2>&1
S47=tests/escenarios/hooks/secciones/47-lectura-fallida-y-locale.sh
ARNES_HOOKS_DIR=$W/hooks bash tests/escenarios/hooks/run.sh $S47 > "$E/10-s47-hooks-413c6bd.txt" 2>&1
ARNES_HOOKS_DIR=$B/hooks bash tests/escenarios/hooks/run.sh $S47 > "$E/11-s47-hooks-v1.35.0.txt" 2>&1
ARNES_HOOKS_DIR=$W/hooks bash tests/escenarios/hooks/run.sh $S47 > "$E/12-s47-hooks-413c6bd-repeticion.txt" 2>&1
bash tests/escenarios/hooks/inventario.sh "$E/10-s47-hooks-413c6bd.txt" > "$E/20-inv-s47-413c6bd.txt"
bash tests/escenarios/hooks/inventario.sh "$E/11-s47-hooks-v1.35.0.txt" > "$E/21-inv-s47-v1.35.0.txt"
diff "$E/20-inv-s47-413c6bd.txt" "$E/21-inv-s47-v1.35.0.txt" > "$E/22-diff-inv-s47.txt"
( time ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh ) > "$E/30-banco-worktree-semilla23062.txt" 2>&1
bash tests/escenarios/hooks/inventario.sh "$E/30-banco-worktree-semilla23062.txt" > "$E/31-inv-banco-worktree.txt"
grep -v -e '	SEC-127 ' -e '	QA-007-06 ' "$E/31-inv-banco-worktree.txt" > "$E/32-inv-sin-s47.txt"
diff ../ArnesJuan-evidencia/cand-1.36.0/sec120/qa2/33-inventario-worktree.txt "$E/32-inv-sin-s47.txt" > "$E/33-diff-sin-s47-vs-qa2.txt"
bash tests/escenarios/hooks/autoprueba-corredor.sh > "$E/40-autoprueba.txt" 2>&1
{ for f in hooks/*.sh tools/*.sh; do bash -n "$f" || { echo "sintaxis: $f"; exit 1; }; done
  jq -e . hooks/hooks.json >/dev/null && jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null
  echo "gates rc=$?"; } > "$E/41-gates.txt" 2>&1
echo hecho
