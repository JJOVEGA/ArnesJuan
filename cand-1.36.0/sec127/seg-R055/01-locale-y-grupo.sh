#!/usr/bin/env bash
# R-055, sonda A y B, a nivel de libreria (bash del anfitrion).
# A: estado de LC_ALL despues de `arnes_estado_ausente` -- definida/no definida, valor, atributo de
#    exportacion -- en cuatro estados de partida, modo normal y modo POSIX, con `set -u`; y su rc.
# B: si la redireccion `2>/dev/null` del grupo NO se puede hacer (aqui: limite de descriptores),
#    que devuelve `arnes_estado_ausente` en 413c6bd y en 78a2f33 con un texto QUE CONTIENE el estado.
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r055
declare -A H=([413c]=$S/413c6bd/hooks [78a2]=$S/78a2f33/hooks)

echo "== A: LC_ALL tras el atajo (78a2f33), set -u"
for modo in normal posix; do
  for ini in noDef vacia expC.UTF-8 shellC.UTF-8; do
    for txt in 'ls -la' 'x completado' 'TERMINÉ'; do
      r="$(env -u LC_ALL bash -c '
        set -u; [ "$1" = posix ] && set -o posix
        case "$2" in vacia) LC_ALL=""; export LC_ALL ;; expC.UTF-8) export LC_ALL=C.UTF-8 ;; shellC.UTF-8) LC_ALL=C.UTF-8 ;; esac
        . "$3/lib.sh" 2>/dev/null
        arnes_estado_ausente "$4" completado; rc=$?
        printf "rc=%s def=%s val=<%s> attr=<%s>" "$rc" "${LC_ALL+si}" "${LC_ALL-}" "$(declare -p LC_ALL 2>/dev/null | cut -d" " -f2)"
      ' _ "$modo" "$ini" "${H[78a2]}" "$txt" 2>&1)"
      printf '%-6s %-13s %-14s %s\n' "$modo" "$ini" "$txt" "$r"
    done
  done
done

echo "== B: la redireccion del grupo falla (ulimit -n), texto 'sed -i s/en-revision/completado/ requirements/REQ-900.md'"
for a in 413c 78a2; do
  for n in 3 4 5 8 10 11 12; do
    r="$(bash -c '
      . "$1/lib.sh" 2>/dev/null
      ulimit -n "$2" 2>/dev/null || { echo "ulimit-fallo"; exit; }
      arnes_estado_ausente "sed -i s/en-revision/completado/ requirements/REQ-900.md" completado; echo "rc=$?"
    ' _ "${H[$a]}" "$n" 2>&1 | tr "\n" " ")"
    printf '%-5s ulimit-n=%-3s %s\n' "$a" "$n" "$r"
  done
done
