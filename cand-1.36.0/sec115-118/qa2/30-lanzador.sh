#!/usr/bin/env bash
# 30-lanzador.sh — barridos de QA (scripts de qa/ sin cambiar, lista de variables qa2/30-vars.txt en 5 particiones) y tope.
export TMPDIR=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
( bash /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2/20-tope.sh /home/juan/dev/ArnesJuan-v1.36/hooks > /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2/21-tope-candidato.txt 2>&1; bash /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2/20-tope.sh /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/t/8e11f87/hooks > /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2/21-tope-8e11f87.txt 2>&1 ) &
for p in /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/parts/v.*; do k=${p##*.}
  bash /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2/../qa/30-entorno-barrido.sh /home/juan/dev/ArnesJuan-v1.36/hooks /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/parts/r30.$k $p &
  bash /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2/../qa/30b-entorno-barrido.sh /home/juan/dev/ArnesJuan-v1.36/hooks /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/parts/r30b.$k $p &
done
bash /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2/../qa/32-modo-barrido.sh /home/juan/dev/ArnesJuan-v1.36/hooks /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2/33-modo-candidato.txt &
wait
for k in 00 01 02 03 04; do cat /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/parts/r30.$k; done > /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2/31-entorno-barrido-candidato.txt
for k in 00 01 02 03 04; do cat /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/parts/r30b.$k; done > /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa2/31b-entorno-barrido-candidato.txt
echo fin
