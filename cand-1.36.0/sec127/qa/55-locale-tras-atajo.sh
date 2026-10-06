#!/usr/bin/env bash
# SEC-127: el locale del proceso tras arnes_estado_ausente, en en_US.UTF-8, tr_TR.UTF-8, tr_TR.ISO-8859-9, C.UTF-8,
# modo normal y POSIX, con LC_ALL definida, vacía, sin definir (LANG o LC_CTYPE). Además de las variables se mide
# el EFECTO: longitud de «ñandú» y plegado de «I» en el proceso, y `grep -ci` en un hijo, antes y después.
L=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa/eq/loc
W=/home/juan/dev/ArnesJuan-v1.36; S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/qa5
n=0; f=0
for arbol in cand:$W/hooks 82ceb63:$S/82ceb63/hooks; do
 for loc in en_US.UTF-8 tr_TR.UTF-8 tr_TR.ISO-8859-9 C.UTF-8; do
  for como in LC_ALL LANG LC_CTYPE LC_ALL-vacia LC_ALL-no-exportada; do
   for modo in normal posix; do
    for t in "ascii:echo hola > requirements/REQ-900.md:completado" "noascii:sed -i s/en-revisión/listo/ requirements/REQ-900.md:completado" "ascii-I:sed -i s/x/LISTO/ r.md:listo" "noascii-estado:echo TERMIN > r.md:terminé"; do
     IFS=: read -r tn tx te <<< "$t"
     case $como in
       LC_ALL) set -- LC_ALL=$loc ;; LANG) set -- LANG=$loc ;; LC_CTYPE) set -- LANG=C LC_CTYPE=$loc ;;
       LC_ALL-vacia) set -- LC_ALL= LANG=$loc ;; LC_ALL-no-exportada) set -- LANG=$loc NOEXP=$loc ;;
     esac
     px=; [ $modo = posix ] && px=POSIXLY_CORRECT=1
     r="$(env -i PATH="$PATH" LOCPATH=$L "$@" $px bash -c '
       [ "$0" = posix ] && set -o posix; [ -n "${NOEXP:-}" ] && LC_ALL=$NOEXP
       . "$1/lib.sh" 2>/dev/null
       sonda() { local x="ñandú" y=I; printf "vars[LC_ALL=%s LC_CTYPE=%s LANG=%s exp=%s] len=%s low=%s grep=%s posix=%s" "${LC_ALL-<sd>}" "${LC_CTYPE-<sd>}" "${LANG-<sd>}" "$(declare -p LC_ALL 2>/dev/null | cut -c1-11)" "${#x}" "$(printf %s "${y,,}" | od -An -tx1 | tr -d " ")" "$(echo I | grep -ci i)" "$([[ :$SHELLOPTS: == *:posix:* ]] && echo si || echo no)"; }
       a="$(sonda)"; arnes_estado_ausente "$2" "$3" >/dev/null 2>&1; rc=$?; b="$(sonda)"
       if [ "$a" = "$b" ]; then printf "IGUAL rc=%s %s" "$rc" "$a"; else printf "DISTINTO rc=%s antes{%s} despues{%s}" "$rc" "$a" "$b"; fi
     ' "$modo" "${arbol#*:}" "$tx" "$te" 2>&1)"
     n=$((n+1)); case "$r" in IGUAL*) ;; *) f=$((f+1));; esac
     printf '%-8s %-17s %-20s %-6s %-14s %s\n' "${arbol%%:*}" "$loc" "$como" "$modo" "$tn" "$r"
    done; done; done; done; done
echo "TOTAL $n; no IGUAL: $f"
