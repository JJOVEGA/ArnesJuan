#!/usr/bin/env bash
SP=/tmp/claude-1000/-home-juan-dev-ArnesJuan/23a8ee5a-8587-4923-8f15-1fc9bf03aaf2/scratchpad
LIB="$SP/her321/hooks/lib.sh"
COND="$1"; shift
OUT="$SP/medidas-$COND.tsv"
printf 'cond\tk\tcorrida\tmin1\tmax1\tdisp1\tmin2\tmax2\tdisp2\tcoc_milesimas\n' > "$OUT"
campo() { local r="$1" c="$2"; r=" $r"; r="${r##* $c=}"; printf '%s' "${r%% *}"; }
for k in "$@"; do
  for i in 1 2 3 4 5; do
    r1="$("$SP/probe.sh" "$LIB" arnes_sin_cita 70000  "$k")"
    r2="$("$SP/probe.sh" "$LIB" arnes_sin_cita 140000 "$k")"
    m1=$(campo "$r1" min); x1=$(campo "$r1" max); d1=$(campo "$r1" disp)
    m2=$(campo "$r2" min); x2=$(campo "$r2" max); d2=$(campo "$r2" disp)
    e1=$(campo "$r1" estado); e2=$(campo "$r2" estado)
    if [ "$e1" != ok ] || [ "$e2" != ok ]; then coc="estado:$e1/$e2"; else coc=$(( m2 * 1000 / m1 )); fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$COND" "$k" "$i" "$m1" "$x1" "$d1" "$m2" "$x2" "$d2" "$coc" >> "$OUT"
  done
done
echo "FIN $COND"
