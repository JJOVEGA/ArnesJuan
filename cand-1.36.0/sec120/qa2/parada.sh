#!/usr/bin/env bash
# Los hooks que NO son guardianes (stop.sh, estado-derivado.sh, rotar-artefactos.sh) con entradas vacías, con NUL
# y normales, en v1.35.0, aba1c9b y el candidato. Cada corrida en una copia nueva del proyecto de qa/ con un
# docs/ESTADO.md con texto humano; se anotan rc, bytes de stdout y stderr, y el árbol resultante, que se compara
# entre árboles de hooks (diff -r de las copias).
set -u
Q=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120; S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/parada
declare -A H=([v135]=/home/juan/dev/ArnesJuan-v1.35.0-base/hooks [aba]=$S/../taba1c9b/hooks [cand]=/home/juan/dev/ArnesJuan-v1.36/hooks)
rm -rf $S; mkdir -p $S/e
N='{"session_id":"s","hook_event_name":"Stop","stop_hook_active":false}'
: > $S/e/vacia; printf '\0' > $S/e/un-NUL; printf '\0%s' "$N" > $S/e/NUL-objeto; printf '%s\0' "$N" > $S/e/objeto-NUL
printf '%s\0basura' "$N" > $S/e/objeto-NUL-basura; printf '\n' > $S/e/salto; printf 'basura{' > $S/e/basura; printf '%s' "$N" > $S/e/normal
for h in stop.sh estado-derivado.sh rotar-artefactos.sh; do for e in $(ls $S/e); do
  linea="$h $e"
  for t in v135 aba cand; do
    d=$S/p-$t-$h-$e; cp -r $Q/qa/proyecto $d; printf '# Estado\n\ntexto humano antes\n\ntexto humano despues\n' > $d/docs/ESTADO.md
    out="$(cd $d && CLAUDE_PROJECT_DIR=$d timeout 60 bash ${H[$t]}/$h < $S/e/$e 2>$S/err-$t-$h-$e)"; rc=$?
    linea+=" | $t rc=$rc out=${#out} err=$(wc -c < $S/err-$t-$h-$e) estado=$(sha256sum < $d/docs/ESTADO.md | cut -c1-8)"
  done
  r1="$(diff -r $S/p-aba-$h-$e $S/p-cand-$h-$e >/dev/null && echo igual || echo DISTINTO)"; r2="$(diff -r $S/p-v135-$h-$e $S/p-cand-$h-$e >/dev/null && echo igual || echo DISTINTO)"
  e1="$(cmp -s $S/err-aba-$h-$e $S/err-cand-$h-$e && echo igual || echo DISTINTO)"
  echo "$linea || arbol aba=cand: $r1, v135=cand: $r2; stderr aba=cand: $e1"
done; done
