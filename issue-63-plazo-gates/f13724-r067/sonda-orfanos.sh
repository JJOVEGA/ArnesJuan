#!/usr/bin/env bash
# r067: a nivel de LIBRERIA, con el presupuesto bajado a 2 s DESPUES de cargarla (no es el hook: el hook lo fija en 30),
# para que el corte caiga durante los readlink (no anunciados). Mira si queda algun proceso vivo y cuanto tarda en volver.
R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r067
. $R/arb/cand/hooks/lib.sh
for b in 1 2 3 5 8; do
  ARNES_HASH_PRESUPUESTO_S=$b; SECONDS=0; t0=${EPOCHREALTIME/./}
  arnes_hash_arbol $R/w/enl; rc=$?; t1=${EPOCHREALTIME/./}
  sleep 0.3; v=$(pgrep -c -P 1 readlink 2>/dev/null; pgrep -fc "readlink -z" )
  echo "presupuesto=$b rc=$rc ms=$(( (t1-t0)/1000 )) motivo=${ARNES_HASH_MOTIVO:0:60} vivos_readlink=$(pgrep -c readlink) bash_hijos=$(pgrep -c -P $$)"
done
