#!/usr/bin/env bash
# 14-estatico.sh <worktree> — QA-007-14: palabras en posición de orden en el código de los hooks que cargan entrada.sh,
# frente a la lista estática de hooks/entrada.sh; y export/readonly/times fuera de comentarios. Heurístico: un candidato
# no listado se inspecciona a mano (la salida lo lleva con su tipo).
set -u; cd "$1"
F="hooks/entrada.sh hooks/guard.sh hooks/guard-codigo.sh hooks/guard-git.sh hooks/guard-completado.sh hooks/lib.sh"
L="$(sed -n '/^POSIXLY_CORRECT=y/,/timeout env sh bash/p' hooks/entrada.sh | sed 's/unset -f//; s/\\//g; s/POSIXLY_CORRECT=y//' | tr -s ' \n' '\n' | sed "s/'//g" | sed '/^$/d' | sort -u)"
echo "# $(date -Is) lista estática ($(echo "$L" | wc -l) nombres):"; echo "$L" | tr '\n' ' '; echo
echo "# los 7 de P-136-R en la lista:"; for n in return exit break continue set shift :; do grep -qxF -- "$n" <<<"$L" && echo "  $n: sí" || echo "  $n: NO"; done
echo "# builtins de bash ($(compgen -b | wc -l)) fuera de la lista, con apariciones como palabra fuera de comentarios:"
for b in $(compgen -b); do grep -qxF -- "$b" <<<"$L" && continue; n=$(grep -hv '^\s*#' $F | grep -cwF -- "$b"); echo "  $b=$n"; done | tr '\n' ' '; echo
echo "# export/readonly/times fuera de comentarios (líneas):"; grep -nwE 'export|readonly|times' $F | grep -vE ':[0-9]+:\s*#' || echo "  ninguna"
echo "# palabras en posición de orden, fuera de la lista, que el shell resuelve a builtin/archivo/palabra clave:"
grep -hv '^\s*#' $F | grep -oE '(^|[;&|({`]|\$\(|then|do|else|!|&&|\|\|)\s*[A-Za-z_:.\[][A-Za-z0-9_.:-]*' | grep -oE '[A-Za-z_:.\[][A-Za-z0-9_.:-]*$' | sort | uniq -c | sort -rn |
while read c w; do grep -qxF -- "$w" <<<"$L" && continue; t=$(type -t -- "$w" 2>/dev/null); case $t in builtin|file|keyword) echo "  $w ($t) x$c";; esac; done
echo "# dónde aparecen las de tipo archivo (no comentario):"
for w in join yes xargs sudo strings stdbuf split setsid perl nohup nice ionice install dir help; do grep -nw -- "$w" $F | grep -vE ':[0-9]+:\s*#' | cut -c1-150 | sed "s/^/  [$w] /"; done
