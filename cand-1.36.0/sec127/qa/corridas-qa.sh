#!/usr/bin/env bash
# QA del paso 5 de 1.36.0 (SEC-127, QA-007-06, SEC-128): corridas del qa-tester, una tras otra.
# Uso: corridas-qa.sh secciones | banco | procesos
set -u
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127; Q=$E/qa; W=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/qa5
mat() { rm -rf "$S/$1"; mkdir -p "$S/$1" && git -C "$W" archive "$1" hooks tools | tar -x -C "$S/$1"; }
case "${1:?}" in
secciones)
  mkdir -p "$S"; for r in 413c6bd a59917d 82ceb63; do mat $r; done
  { date -Is; uname -a; bash --version | head -1; jq --version; echo "LANG=${LANG-} LC_ALL=${LC_ALL-<sin definir>} carga $(cut -d' ' -f1-3 /proc/loadavg)"
    echo "worktree $(git -C $W rev-parse --short HEAD); estado:"; git -C $W status --short
    echo "hooks/ tools/ tests/ frente a 78a2f33: $(git -C $W diff --quiet 78a2f33 -- hooks tools tests && echo identicos || echo DIFIEREN)"
    sha256sum $W/hooks/lib.sh $W/hooks/guard-codigo.sh $S/*/hooks/lib.sh $S/*/hooks/guard-codigo.sh
    echo "v1.35.0 $(git -C $B rev-parse --short HEAD); hooks/ tools/ frente a 3956a6f: $(git -C $B diff --quiet 3956a6f -- hooks tools && echo identicos || echo DIFIEREN)"; } > "$Q/00-entorno.txt" 2>&1
  cd "$W" || exit 1
  S47=tests/escenarios/hooks/secciones/47-lectura-fallida-y-locale.sh; S44=tests/escenarios/hooks/secciones/44-integridad-de-la-entrada.sh
  ARNES_HOOKS_DIR=$W/hooks          bash tests/escenarios/hooks/run.sh $S47 > "$Q/10-s47-candidato.txt" 2>&1
  ARNES_HOOKS_DIR=$W/hooks          bash tests/escenarios/hooks/run.sh $S47 > "$Q/11-s47-candidato-repeticion.txt" 2>&1
  ARNES_HOOKS_DIR=$S/413c6bd/hooks  bash tests/escenarios/hooks/run.sh $S47 > "$Q/12-s47-413c6bd.txt" 2>&1
  ARNES_HOOKS_DIR=$S/a59917d/hooks  bash tests/escenarios/hooks/run.sh $S47 > "$Q/13-s47-a59917d.txt" 2>&1
  ARNES_HOOKS_DIR=$B/hooks          bash tests/escenarios/hooks/run.sh $S47 > "$Q/14-s47-v1.35.0.txt" 2>&1
  ARNES_HOOKS_DIR=$W/hooks          bash tests/escenarios/hooks/run.sh $S44 > "$Q/15-s44-candidato.txt" 2>&1
  ARNES_HOOKS_DIR=$S/a59917d/hooks  bash tests/escenarios/hooks/run.sh $S44 > "$Q/16-s44-a59917d.txt" 2>&1
  ARNES_HOOKS_DIR=$B/hooks          bash tests/escenarios/hooks/run.sh $S44 > "$Q/17-s44-v1.35.0.txt" 2>&1
  ;;
banco)
  echo "carga al empezar: $(cut -d' ' -f1-3 /proc/loadavg) $(date -Is)" > "$Q/20-carga.txt"
  cd "$B" || exit 1
  ( time ARNES_HOOKS_DIR=$W/hooks ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh ) > "$Q/20-banco-v1.35.0-hooks-candidato.txt" 2>&1
  bash tests/escenarios/hooks/inventario.sh "$Q/20-banco-v1.35.0-hooks-candidato.txt" > "$Q/21-inventario.txt" 2>&1
  diff "$E/../ca54/22-inventario-v1.35.0.txt" "$Q/21-inventario.txt" > "$Q/22-diff-inventario.txt"
  echo "carga entre bancos: $(cut -d' ' -f1-3 /proc/loadavg) $(date -Is)" >> "$Q/20-carga.txt"
  cd "$W" || exit 1
  ( time ARNES_SEMILLA_41=23062 bash tests/escenarios/hooks/run.sh ) > "$Q/30-banco-worktree.txt" 2>&1
  bash tests/escenarios/hooks/inventario.sh "$Q/30-banco-worktree.txt" > "$Q/31-inventario-worktree.txt" 2>&1
  diff "$E/b1-inventario-worktree.txt" "$Q/31-inventario-worktree.txt" > "$Q/32-diff-inventario-worktree-vs-b1.txt"
  bash tests/escenarios/hooks/autoprueba-corredor.sh > "$Q/33-autoprueba.txt" 2>&1
  { for f in hooks/*.sh tools/*.sh; do bash -n "$f" || { echo "sintaxis: $f"; exit 1; }; done
    jq -e . hooks/hooks.json >/dev/null && jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null
    echo "gates rc=$?"; } > "$Q/34-gates.txt" 2>&1
  echo "carga al terminar: $(cut -d' ' -f1-3 /proc/loadavg) $(date -Is)" >> "$Q/20-carga.txt"
  ;;
procesos)
  { echo "== procesos QA paso 5; $(date -Is); carga $(cut -d' ' -f1-3 /proc/loadavg)"
    bash "$E/procesos-sec127.sh" "$W" "v1.35.0=$B/hooks" "82ceb63=$S/82ceb63/hooks" "413c6bd=$S/413c6bd/hooks" "candidato=$W/hooks"; } > "$Q/40-procesos.txt" 2>&1
  ;;
esac
echo FIN
