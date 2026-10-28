#!/usr/bin/env bash
# conduce-caza2.sh: la carga de QA MÁS cierres concurrentes de la candidata (vivos.sh, su propia sesión), como en 01- cuando salió el cuelgue
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
Q=/home/juan/dev/ArnesJuan-evidencia/issue-63-plazo-gates/qa/bin; W=$S/w-caza; rm -rf $W; mkdir -p $W
setsid bash $Q/carga.sh $W/pgid >/dev/null 2>&1 &
sleep 2; PG=$(cat $W/pgid); MIO=$(ps -o pgid= -p $$ | tr -d ' ')
echo "# caza de cuelgues, $(date -Is), carga PGID $PG (el mío $MIO)"; [ -n "$PG" ] && [ "$PG" != "$MIO" ] || exit 1
sleep 20; echo "loadavg $(cut -d' ' -f1-3 /proc/loadavg)"
bash $S/vivos.sh "$3" 500 > $W/vivos.txt 2>&1 & v=$!
bash $S/caza.sh "$3" "$1" "$2" $W/c-$3-$2
wait $v; cat $W/vivos.txt
echo "fin $(date +%T) loadavg $(cut -d' ' -f1-3 /proc/loadavg)"
kill -KILL -- "-$PG"; sleep 1; echo "quedan en el grupo de carga: $(pgrep -g $PG | wc -l)"
