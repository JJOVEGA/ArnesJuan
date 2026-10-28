#!/usr/bin/env bash
# tramo.sh <nombre> <modo: concurrente|serie|d47> <n por clase>: la carga de QA (bin/carga.sh, sin cambios, su PGID
# anotado) y los cierres. concurrente: las cuatro clases a la vez; serie: una tras otra; d47: dobles.sh (sin cambios)
# contra d47cfba con `false` y `true`.
V=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/issue-63-f13724-qa
NOM="$1"; M="$2"; N="$3"; W=$V/w-$NOM; rm -rf $W; mkdir -p $W
setsid bash $V/bin/carga.sh $W/pgid >/dev/null 2>&1 &
sleep 2; PG=$(cat $W/pgid); MIO=$(ps -o pgid= -p $$ | tr -d ' ')
echo "# $NOM ($M, $N por clase), qa-tester (Opus), $(date -Is), bash $BASH_VERSION; carga PGID $PG (el mío $MIO)"
echo "$PG" >> $V/pgids-carga.txt
[ -n "$PG" ] && [ "$PG" != "$MIO" ] || { echo "PGID dudoso: aborto"; exit 1; }
sleep 15; echo "loadavg al empezar: $(cut -d' ' -f1-3 /proc/loadavg)"
case $M in
  concurrente) ps_=(); for c in valido rojo caducado ausente; do bash $V/bin/cierres.sh $V/arb/ceb7bf3 $c $N $W > $W/r-$c.txt 2>&1 & ps_+=($!); done; wait "${ps_[@]}"
               cat $W/r-*.txt ;;
  serie) for c in valido rojo caducado ausente; do bash $V/bin/cierres.sh $V/arb/ceb7bf3 $c $N $W; done ;;
  d47) bash $V/bin/dobles.sh $V/arb/d47cfba/hooks $N '["false"]' $W/f; bash $V/bin/dobles.sh $V/arb/d47cfba/hooks $N '["true"]' $W/t ;;
esac
echo "loadavg al terminar: $(cut -d' ' -f1-3 /proc/loadavg) $(date +%T)"
kill -KILL -- "-$PG"; sleep 1; echo "quedan en el grupo de carga $PG: $(pgrep -g $PG | wc -l)"
