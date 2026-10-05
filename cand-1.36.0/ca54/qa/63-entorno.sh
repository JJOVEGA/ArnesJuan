#!/usr/bin/env bash
# Testigo del entorno durante la re-verificacion: cada 10 s, la carga y lo que tarda un bucle FIJO de bash
# (100 000 vueltas de `:`), que no depende de los hooks. Un salto del testigo en el mismo minuto que un salto de
# v1.35.0 y del candidato señala contencion del anfitrion (WSL2 no publica el tiempo robado). Coste: ~1 % de UNA CPU.
while [ ! -f /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa/59-fin2.txt ]; do
  t0=${EPOCHREALTIME/./}; for ((i=0;i<100000;i++)); do :; done; t1=${EPOCHREALTIME/./}
  echo "$(date +%H:%M:%S) carga=$(cut -d' ' -f1-3 /proc/loadavg) testigo_ms=$(( (t1-t0)/1000 ))"
  sleep 10
done
