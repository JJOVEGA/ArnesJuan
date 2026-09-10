#!/usr/bin/env bash
SP=/tmp/claude-1000/-home-juan-dev-ArnesJuan/23a8ee5a-8587-4923-8f15-1fc9bf03aaf2/scratchpad
LIB="$SP/her321/hooks/lib.sh"
OUT="$SP/medidas-carga.tsv"
printf 'k\tr\tcorrida\tmin1\tmax1\tdisp1\tmin2\tmax2\tdisp2\tcoc_milesimas\tcarga\n' > "$OUT"
campo() { local reg=" $1" c="$2"; reg="${reg##* $c=}"; printf '%s' "${reg%% *}"; }
# 12 quemadores en 12 nucleos: emula un runner de CI contendido.
PIDS=''
for _ in $(seq 12); do bash -c 'while :; do :; done' & PIDS="$PIDS $!"; done
trap 'kill $PIDS 2>/dev/null' EXIT
sleep 2
for par in "1 3" "8 3" "20 3" "1 15" "8 9"; do
  set -- $par; k="$1"; r="$2"
  for i in 1 2 3 4 5; do
    r1="$("$SP/probe.sh" "$LIB" arnes_sin_cita 70000  "$k" "$r")"
    r2="$("$SP/probe.sh" "$LIB" arnes_sin_cita 140000 "$k" "$r")"
    m1=$(campo "$r1" min); x1=$(campo "$r1" max); d1=$(campo "$r1" disp)
    m2=$(campo "$r2" min); x2=$(campo "$r2" max); d2=$(campo "$r2" disp)
    e1=$(campo "$r1" estado); e2=$(campo "$r2" estado); cg=$(campo "$r2" carga)
    if [ "$e1" != ok ] || [ "$e2" != ok ]; then coc="estado:$e1/$e2"; else coc=$(( m2 * 1000 / m1 )); fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$k" "$r" "$i" "$m1" "$x1" "$d1" "$m2" "$x2" "$d2" "$coc" "$cg" >> "$OUT"
  done
  echo "hecho k=$k r=$r" >&2
done
echo FIN
