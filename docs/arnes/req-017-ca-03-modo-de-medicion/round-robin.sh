#!/usr/bin/env bash
# Comparacion CONTROLADA: las configuraciones se intercalan round-robin dentro de la misma
# corrida y bajo carga ya estabilizada, para que ninguna vea un entorno privilegiado.
SP=/tmp/claude-1000/-home-juan-dev-ArnesJuan/23a8ee5a-8587-4923-8f15-1fc9bf03aaf2/scratchpad
LIB="$SP/her321/hooks/lib.sh"
OUT="$SP/medidas-rr.tsv"
printf 'ronda\tconfig\tmin1\tmax1\tmin2\tmax2\tcoc_milesimas\tcarga\tus\n' > "$OUT"
campo() { local reg=" $1" c="$2"; reg="${reg##* $c=}"; printf '%s' "${reg%% *}"; }
PIDS=''
for _ in $(seq 12); do bash -c 'while :; do :; done' & PIDS="$PIDS $!"; done
trap 'kill $PIDS 2>/dev/null' EXIT
sleep 90   # que la carga llegue a su meseta ANTES de la primera medida
for i in 1 2 3 4 5; do
  for cfg in bloque:1:3 bloque:2:9 bloque:1:15 bloque:8:3 inter:2:9; do
    IFS=: read -r modo k r <<< "$cfg"
    if [ "$modo" = inter ]; then
      reg="$("$SP/probe-int.sh" "$LIB" arnes_sin_cita 70000 "$k" "$r")"
      e=$(campo "$reg" estado)
      m1=$(campo "$reg" min_b); x1=$(campo "$reg" max_b)
      m2=$(campo "$reg" min_a); x2=$(campo "$reg" max_a)
      us=$(campo "$reg" us); cg=$(campo "$reg" carga)
      if [ "$e" != ok ]; then coc="estado:$e"; else coc=$(campo "$reg" razon); fi
    else
      r1="$("$SP/probe.sh" "$LIB" arnes_sin_cita 70000  "$k" "$r")"
      r2="$("$SP/probe.sh" "$LIB" arnes_sin_cita 140000 "$k" "$r")"
      m1=$(campo "$r1" min); x1=$(campo "$r1" max)
      m2=$(campo "$r2" min); x2=$(campo "$r2" max)
      us=$(( $(campo "$r1" us) + $(campo "$r2" us) )); cg=$(campo "$r2" carga)
      e1=$(campo "$r1" estado); e2=$(campo "$r2" estado)
      if [ "$e1" != ok ] || [ "$e2" != ok ]; then coc="estado:$e1/$e2"; else coc=$(( m2 * 1000 / m1 )); fi
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$i" "$cfg" "$m1" "$x1" "$m2" "$x2" "$coc" "$cg" "$us" >> "$OUT"
  done
  echo "ronda $i hecha" >&2
done
echo FIN
