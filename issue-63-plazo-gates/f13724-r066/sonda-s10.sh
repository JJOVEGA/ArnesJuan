#!/usr/bin/env bash
# S10: coste del hash en la puerta con un archivo disperso no ignorado (sin ejecutar el caso de 600 s: se extrapola).
set -u
R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r066
. <(sed -n '/^C=/,/^W=/p' $R/sondas.sh)
for g in 1 4 16; do
  P=$W/c10-$g; mk $P '["grep -q bien src/a.txt"]'; herr $P
  echo mal > $P/src/a.txt; truncate -s ${g}G $P/datos.bin
  t0=${EPOCHREALTIME/./}; d=$(cierra $C $P); t1=${EPOCHREALTIME/./}
  echo "  ${g} GiB disperso, veredicto caducado: cand ${d:0:60} en $(( (t1-t0)/1000 )) ms"
  t0=${EPOCHREALTIME/./}; d=$(cierra $B $P); t1=${EPOCHREALTIME/./}
  echo "  ${g} GiB disperso: base ${d:0:60} en $(( (t1-t0)/1000 )) ms"
  rm -rf $P
done
