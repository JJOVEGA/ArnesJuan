#!/usr/bin/env bash
# Sin CLAUDE_PROJECT_DIR (límite declarado de CA-47 punto 20; QA-007-05 está pendiente del propietario y NO se juzga
# aquí: sólo se registran las formas de la pasada). Proceso con el directorio de trabajo en el proyecto y en /tmp.
set -u
Q=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120; P=$Q/qa/proyecto
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
declare -A H=([v135]=/home/juan/dev/ArnesJuan-v1.35.0-base/hooks [aba]=$S/taba1c9b/hooks [cand]=/home/juan/dev/ArnesJuan-v1.36/hooks)
for f in qa/entradas/I01-vacia qa/entradas2/X13-solo-NUL qa2/entradas/Z06-un-NUL qa2/entradas/Z16-1MiB-de-NUL qa/entradas/I12-NUL-objeto qa2/entradas/Z01-ls-c-NUL-final qa2/entradas/Z04-ls-c-NUL-escritura-c qa2/entradas/Z08-escritura-d-NUL-ls-d qa2/entradas/T03-Write-file_path-false-c qa2/entradas/T05-Bash-command-false-c qa2/entradas/G02-git-status-c qa2/entradas/G08-edit-src-c; do
  for dir in $P /tmp; do l="$f cwd=${dir##*/}"
    for t in v135 aba cand; do out="$(cd $dir && env -u CLAUDE_PROJECT_DIR bash ${H[$t]}/guard.sh < $Q/$f.json 2>/dev/null)"; rc=$?
      case "$out" in *'"deny"'*) d=deny;; '') d=nada;; *) d=otro;; esac; l+=" | $t $d rc=$rc"; done; echo "$l"; done; done
