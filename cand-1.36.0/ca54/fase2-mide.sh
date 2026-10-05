#!/usr/bin/env bash
# Fase 2 de la decima autorizacion (CA-54): las 35 corridas de S1 y S2 y el conteo de procesos, en la
# MISMA sesion, con la carga anotada. Las sondas y `procesos-ca54.sh` son los de la fase 1, sin cambiar
# una linea (sha256 en 30-…/31-…); `CAND` ya apunta a /home/juan/dev/ArnesJuan-v1.36/hooks, que ahora
# lleva el codigo de la fase 2. Columna `9596e39 ms` = v1.35.0; columna `candidato ms` = candidato.
set -u
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54; cd "$E" || exit 1
WT=/home/juan/dev/ArnesJuan-v1.36
cab() { echo "== $1. Cabeza del worktree: $(git -C "$WT" rev-parse --short HEAD)$(git -C "$WT" diff --quiet -- hooks || echo ' + hooks/ sin commitear'); sha256 hooks/lib.sh $(sha256sum "$WT/hooks/lib.sh" | cut -c1-16); sondas: $(sha256sum s1/sonda-ca54-qa.sh s1/qa-lib.sh s2/sonda-r6-extra.sh s2/qa-lib.sh procesos-ca54.sh | cut -c1-16 | tr '\n' ' '). Inicio $(date -Iseconds); carga inicial $(cut -d' ' -f1-3 /proc/loadavg) =="; }
{ cab "S1 (sonda-ca54-qa.sh restaurada en la fase 1, sin cambios)"; bash s1/sonda-ca54-qa.sh; echo "rc=$? fin $(date -Iseconds) carga $(cut -d' ' -f1-3 /proc/loadavg)"; } > 30-s1-reloj.txt 2>&1
{ cab "S2 (sonda-r6-extra.sh restaurada en la fase 1, sin cambios). Columnas '9596e39' y '43b948a' = v1.35.0 (la intermedia apunta a v1.35.0 y se funde en la primera); 'candidato' = worktree"; bash s2/sonda-r6-extra.sh; echo "rc=$? fin $(date -Iseconds) carga $(cut -d' ' -f1-3 /proc/loadavg)"; } > 31-s2-reloj.txt 2>&1
{ cab "procesos CA-54 (tests/util/sonda-procesos.sh del worktree, invocado tal cual por procesos-ca54.sh)"; bash procesos-ca54.sh "$WT" "$WT/hooks"; echo "rc=$? fin $(date -Iseconds) carga $(cut -d' ' -f1-3 /proc/loadavg)"; } > 32-procesos.txt 2>&1
