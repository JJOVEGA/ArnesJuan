#!/usr/bin/env bash
# entrada-gate.sh — P-137-AD (2): gates que leen su entrada estándar o tocan la terminal, con y sin pty (rq.sh de QA,
# sin cambios). Árboles: v1.36.2, d47cfba y la candidata; las dos últimas en copia con el presupuesto en 5 s.
set -u
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
D=$S/dev; QB=/home/juan/dev/ArnesJuan-evidencia/issue-63-plazo-gates/qa/bin
for t in d47cfba cand; do
  src=$S/arb/d47cfba/hooks; [ "$t" = cand ] && src=$D/arb-cand/hooks
  rm -rf "$D/n5-$t"; mkdir -p "$D/n5-$t"; cp -r "$src" "$D/n5-$t/hooks"
  sed -i 's/^ARNES_GATES_PRESUPUESTO_S=420$/ARNES_GATES_PRESUPUESTO_S=5/' "$D/n5-$t/hooks/lib.sh"
  grep -c '^ARNES_GATES_PRESUPUESTO_S=5$' "$D/n5-$t/hooks/lib.sh" | sed "s/^/# copia $t con N=5: /"
done
echo "# $(date -Is), bash $BASH_VERSION; columnas: árbol rc ms decisión motivo gates"
for g in '["read -r x; true","false"]' '["read -r r && [ \"$r\" = s ]"]' '["if [ -t 0 ]; then while :; do sleep 1; done; fi; true"]' '["stty sane </dev/tty"]'; do
  for modo in sin-pty pty; do
    w=''; [ "$modo" = pty ] && w=pty
    echo "-- $modo"
    bash "$QB/rq.sh" v1.36.2 "$S/arb/v1.36.2/hooks" "$g" 30 $w
    bash "$QB/rq.sh" d47-N5 "$D/n5-d47cfba/hooks" "$g" 30 $w
    bash "$QB/rq.sh" cand-N5 "$D/n5-cand/hooks" "$g" 30 $w
  done
done
