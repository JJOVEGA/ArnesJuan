#!/usr/bin/env bash
# t10 — la pasada correctiva (befc17a) contra 9220c71: P-122-A (1), QA-023-16, QA-023-17. Sólo JSON al hook; sin git real.
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/lib-sonda8.sh
ARBOLES="cand 9220c71 9596e39 v1.33.2"
proyecto_nuevo "$S/p10"; ln -s /dev/stderr "$P/src/log"
j_bash "git stash$CR"; fila "P1 git stash<CR> (P-122-A 1)" "$J"
j_bash "git checkout .$CR"; fila "P2 git checkout .<CR> (QA-023-16)" "$J"
j_bash "git checkout -- .$CR"; fila "P3 git checkout -- .<CR>" "$J"
j_bash "git restore .$CR"; fila "P4 git restore .<CR>" "$J"
j_bash "git checkout HEAD .$CR"; fila "P5 git checkout HEAD .<CR>" "$J"
j_bash "git reset --hard$CR"; fila "P6 git reset --hard<CR> (G1)" "$J"
j_bash "echo x > src/log"; fila "P7 echo > src/log -> /dev/stderr (QA-023-17)" "$J"
j_bash "echo x 2> src/log"; fila "P8 2> src/log" "$J"
