#!/usr/bin/env bash
# Corre N=10 corridas secuenciales del ensayo con límite de 150 min de pared. No amplía ni ajusta.
set -u
T=/home/juan/dev/ArnesJuan-ensayo-sondas; O=/home/juan/dev/ArnesJuan-evidencia/sondas-coste/ensayo-local/corridas; mkdir -p "$O"
LIM=$((150*60)); T0=$(date +%s); date -u +%FT%TZ > "$O/inicio.txt"
for n in 01 02 03 04 05 06 07 08 09 10; do
  el=$(( $(date +%s) - T0 )); if [ "$el" -gt "$LIM" ]; then echo "$n: NO ARRANCADA (límite de 150 min agotado a los $el s)" >> "$O/limite.txt"; continue; fi
  { echo "corrida=$n inicio=$(date -u +%FT%TZ) loadavg=$(cut -d' ' -f1-3 /proc/loadavg)"; } > "$O/corrida-$n.meta"
  s=$(date +%s.%N)
  ( cd "$T" && ARNES_JOBS=6 bash tests/escenarios/hooks/run.sh tests/escenarios/hooks/secciones/37-*.sh ) > "$O/corrida-$n.txt" 2> "$O/corrida-$n.err"; rc=$?
  e=$(date +%s.%N)
  { echo "rc=$rc fin=$(date -u +%FT%TZ) segundos=$(awk -v a=$s -v b=$e 'BEGIN{printf "%.1f", b-a}') loadavg_fin=$(cut -d' ' -f1-3 /proc/loadavg)"; } >> "$O/corrida-$n.meta"
done
date -u +%FT%TZ > "$O/fin.txt"
