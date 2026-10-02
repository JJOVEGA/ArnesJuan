#!/usr/bin/env bash
# t2b — SEC-123 por Bash con un cwd que lleva CR (no ancla: QA-023-13). El cwd es un directorio real cuyo nombre
# acaba en CR, situado DENTRO del proyecto a la misma profundidad que la raíz+1; el shell escribe desde él.
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/lib-sonda8.sh
proyecto_nuevo "$S/p2b"; D="$P/docs/w$CR"; mkdir -p "$D"
IFS=/ read -r -a comp <<< "${D#/}"; d=${#comp[@]}
for k in 4 5; do
  r="/proc/self/cwd"; for ((i=0;i<k;i++)); do r+="/.."; done
  baja=""; for ((i=d-k;i<d-2;i++)); do baja+="/${comp[i]}"; done   # sube k desde docs/w<CR> y baja hasta la raíz
  R="$r$baja/src/a.ts"
  j_bash "echo x > $R" "$D"; fila "k=$k Bash cwd=<raiz>/docs/w<CR>: echo > …src/a.ts" "$J"
  PG="$P"; T="$S/efe2b"; proyecto_nuevo "$T"; DT="$T/docs/w$CR"; mkdir -p "$DT"
  IFS=/ read -r -a ct <<< "${DT#/}"; bt=""; for ((i=${#ct[@]}-k;i<${#ct[@]}-2;i++)); do bt+="/${ct[i]}"; done
  ( cd "$DT" && echo "INTRUSO-k$k" >> "$r$bt/src/a.ts" ) 2>&1
  echo "   efecto: $(tr '\n' '|' < "$T/src/a.ts")"; rm -rf "$T"; P="$PG"
done
