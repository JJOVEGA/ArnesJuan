#!/usr/bin/env bash
# Round-robin CONTROLADO bloque vs intercalado, para las DOS mediciones de REQ-017 CA-03.
# Las cuatro configuraciones se intercalan dentro de la MISMA ronda y el orden ROTA en cada
# ronda, para que ninguna vea siempre la misma posición del entorno. `carga` fila a fila,
# la que publica la propia sonda. r=3 en todas: el único parámetro que se mueve es el MODO.
SP=/tmp/claude-1000/-home-juan-dev-ArnesJuan/23a8ee5a-8587-4923-8f15-1fc9bf03aaf2/scratchpad
SANO=/home/juan/dev/ArnesJuan/hooks/lib.sh
HER="$SP/her321/hooks/lib.sh"
OUT="${1:-$SP/medidas-modo.tsv}"
N="${2:-5}"
printf 'ronda\tmedicion\tmodo\tk\tmin_S\tmax_S\tmin_2S\tmax_2S\tcoc\tbanda_lo\tbanda_hi\tanchura\tcarga\tus\n' > "$OUT"
campo() { local reg=" $1" c="$2"; reg="${reg##* $c=}"; printf '%s' "${reg%% *}"; }
CFGS=(directa:$SANO:20:bloque directa:$SANO:20:inter failbefore:$HER:1:bloque failbefore:$HER:1:inter)
for ((i = 1; i <= N; i++)); do
  for ((j = 0; j < ${#CFGS[@]}; j++)); do
    IFS=: read -r med lib k modo <<< "${CFGS[$(( (j + i - 1) % ${#CFGS[@]} ))]}"
    if [ "$modo" = inter ]; then
      reg="$("$SP/probe-int.sh" "$lib" arnes_sin_cita 70000 "$k" 3)"
      e=$(campo "$reg" estado)
      m1=$(campo "$reg" min_b); x1=$(campo "$reg" max_b)
      m2=$(campo "$reg" min_a); x2=$(campo "$reg" max_a)
      us=$(campo "$reg" us); cg=$(campo "$reg" carga)
    else
      r1="$("$SP/probe.sh" "$lib" arnes_sin_cita 70000  "$k" 3)"
      r2="$("$SP/probe.sh" "$lib" arnes_sin_cita 140000 "$k" 3)"
      m1=$(campo "$r1" min); x1=$(campo "$r1" max)
      m2=$(campo "$r2" min); x2=$(campo "$r2" max)
      us=$(( $(campo "$r1" us) + $(campo "$r2" us) ))
      cg="$(campo "$r1" carga)/$(campo "$r2" carga)"
      e="$(campo "$r1" estado)/$(campo "$r2" estado)"; [ "$e" = ok/ok ] && e=ok
    fi
    if [ "$e" != ok ]; then
      printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\testado:%s\t-\t-\t-\t%s\t%s\n' \
        "$i" "$med" "$modo" "$k" "$m1" "$x1" "$m2" "$x2" "$e" "$cg" "$us" >> "$OUT"
      continue
    fi
    coc=$(( m2 * 1000 / m1 )); lo=$(( m2 * 1000 / x1 )); hi=$(( x2 * 1000 / m1 ))
    anch=$(( hi * 1000 / lo ))
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$i" "$med" "$modo" "$k" "$m1" "$x1" "$m2" "$x2" "$coc" "$lo" "$hi" "$anch" "$cg" "$us" >> "$OUT"
  done
done
