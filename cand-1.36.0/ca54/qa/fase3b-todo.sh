#!/usr/bin/env bash
# Orden de la re-verificacion, en serie y sin otra carga: S1/S2/procesos (fase3b-mide.sh) y despues los casos propios.
cd /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa || exit 1
bash fase3b-mide.sh
WT=/home/juan/dev/ArnesJuan-v1.36
{ echo "== Casos propios, re-verificacion de la pasada (QA-007-01). Worktree $(git -C $WT rev-parse --short HEAD), hooks/ = dee5932: $(git -C $WT diff --quiet dee5932 -- hooks && echo si); sha256 script $(sha256sum 50-casos-propios-pasada.sh | cut -c1-16); LANG=$LANG; inicio $(date -Iseconds); carga $(cut -d' ' -f1-3 /proc/loadavg) =="; bash 50-casos-propios-pasada.sh; echo "rc=$? fin $(date -Iseconds) carga $(cut -d' ' -f1-3 /proc/loadavg)"; } > 51-casos-propios-pasada.txt 2>&1
echo TODO-FIN > 59-fin.txt
