#!/usr/bin/env bash
# Fase 3 (QA) de la decima autorizacion, CA-54: las 35 corridas de S1 y S2 (copias de QA, solo rutas;
# ver 00-diff-sondas-qa.txt) y el conteo de procesos con tests/util/sonda-procesos.sh, en la MISMA sesion.
# Columna `9596e39 ms` = v1.35.0 (nombre heredado de la sonda); en S2 la intermedia `43b948a` tambien es v1.35.0.
set -u
Q=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa; cd "$Q" || exit 1
WT=/home/juan/dev/ArnesJuan-v1.36
cab() { echo "== $1. Worktree $(git -C "$WT" rev-parse --short HEAD); hooks/ igual a 82ceb63: $(git -C "$WT" diff --quiet 82ceb63 -- hooks && echo si || echo NO); sha256 lib.sh cand $(sha256sum "$WT/hooks/lib.sh" | cut -c1-16); sondas: $(sha256sum s1/sonda-ca54-qa.sh s1/qa-lib.sh s2/sonda-r6-extra.sh s2/qa-lib.sh procesos-ca54.sh | cut -c1-16 | tr '\n' ' '). LANG=${LANG:-} LC_ALL=${LC_ALL:-}. Inicio $(date -Iseconds); carga $(cut -d' ' -f1-3 /proc/loadavg) =="; }
{ cab "S1"; bash s1/sonda-ca54-qa.sh; echo "rc=$? fin $(date -Iseconds) carga $(cut -d' ' -f1-3 /proc/loadavg)"; } > 10-s1-reloj.txt 2>&1
{ cab "S2"; bash s2/sonda-r6-extra.sh; echo "rc=$? fin $(date -Iseconds) carga $(cut -d' ' -f1-3 /proc/loadavg)"; } > 11-s2-reloj.txt 2>&1
{ cab "procesos (sonda-procesos.sh tal cual)"; bash procesos-ca54.sh "$WT" "$WT/hooks"; echo "rc=$? fin $(date -Iseconds) carga $(cut -d' ' -f1-3 /proc/loadavg)"; } > 12-procesos.txt 2>&1
