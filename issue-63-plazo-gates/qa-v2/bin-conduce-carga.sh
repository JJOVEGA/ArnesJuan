#!/usr/bin/env bash
# conduce-carga.sh: QA-037-01 vuelta 2. Arnés de carga de la vuelta 1 SIN cambios (qa/bin/carga.sh y dobles.sh).
set -u
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
E=/home/juan/dev/ArnesJuan-evidencia/issue-63-plazo-gates/qa-v2
Q=/home/juan/dev/ArnesJuan-evidencia/issue-63-plazo-gates/qa/bin
W=$S/w-carga; mkdir -p $W
setsid bash $Q/carga.sh $W/pgid >/dev/null 2>&1 &
sleep 2; PG=$(cat $W/pgid); MIO=$(ps -o pgid= -p $$ | tr -d ' ')
echo "# QA-037-01 vuelta 2 (qa-tester, Opus), $(date -Is), bash $BASH_VERSION, $(nproc) núcleos; carga PGID $PG (el mío $MIO)"
[ "$PG" != "$MIO" ] && [ -n "$PG" ] || { echo "PGID de carga dudoso: aborto"; exit 1; }
sleep 20
run(){ echo "== $1 $(date +%T) loadavg=$(cut -d' ' -f1-3 /proc/loadavg)"; bash $Q/dobles.sh "$S/arb/$1/hooks" "$2" "$3" "$W/$1-$4"; }
for blk in 1 2 3; do
  run cdbe2a8 100 '["false"]' f$blk; run v1.36.2 100 '["false"]' f$blk
  run cdbe2a8 190 '["true"]' t$blk;  run v1.36.2 190 '["true"]' t$blk
done
run d47cfba 300 '["false"]' f
run d47cfba 300 '["true"]' t
echo "== fin $(date +%T) loadavg=$(cut -d' ' -f1-3 /proc/loadavg)"
kill -KILL -- "-$PG"; sleep 1; echo "procesos del grupo de carga que quedan: $(pgrep -g $PG | wc -l)"
