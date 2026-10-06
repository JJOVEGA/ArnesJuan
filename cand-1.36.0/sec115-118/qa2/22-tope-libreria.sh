#!/usr/bin/env bash
# 22-tope-libreria.sh <hooksdir> — arnes_deny y arnes_emitir_avisos de la librería, en subshell, en las fronteras: motivos de
# 16 380 a 16 390 bytes que terminan en un carácter completo, partido o en un byte inválido; y U+FFFD que cruza el corte.
set -u; HD="$1"; export LC_ALL=C
echo "# 22-tope-libreria.sh hooks=$HD $(date -Is)"; mal=0; n=0
mide() { local o="$1" m b; m=$(printf '%s' "$o" | jq -j '.hookSpecificOutput.permissionDecisionReason // .systemMessage' 2>/dev/null) || { echo NOJSON; return; }
  b=$(printf '%s' "$m" | wc -c); printf '%s' "$m" | iconv -f UTF-8 -t UTF-8 >/dev/null 2>&1 && u=si || u=NO
  printf 'motivo=%s utf8=%s nota=%s' "$b" "$u" "$(printf '%s' "$m" | grep -c 'motivo acortado')"; [ "$b" -le 16384 ] && [ "$u" = si ]; }
for total in 16380 16382 16383 16384 16385 16386 16390 20000; do
  for fin in '' $'\xc3' $'\xe2\x82' $'\xf0\x9d\x84' $'\xff' $'\xc3\xb1' $'\xf0\x9d\x84\x9e'; do
    pre=$(( total - ${#fin} )); t="ARNES: $(head -c $((pre-7)) /dev/zero | tr '\0' a)$fin"
    for f in deny aviso; do n=$((n+1))
      if [ $f = deny ]; then o=$( ( . "$HD/lib.sh"; arnes_deny "$t" ) 2>/dev/null ); else o=$( ( . "$HD/lib.sh"; ARNES_AVISOS="$t"$'\n'; arnes_emitir_avisos ) 2>/dev/null ); fi
      r=$(mide "$o") && res=OK || { res=MAL; mal=$((mal+1)); }
      printf '%s|%s|entrada=%sB fin=%s|%s\n' "$res" "$f" "${#t}" "$(printf '%s' "$fin" | od -An -tx1 | tr -d ' ')" "$r"
    done; done; done
echo "# fin: $n casos, $mal MAL"
