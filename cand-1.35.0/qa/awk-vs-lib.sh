. "$1/lib.sh"
declare -A L
while IFS='|' read -r name est qa seg sens hall rig rest; do L[$name]="$est|$qa|$seg|$sens|$rig"; done < "$2"
n=0; d=0
while IFS=$'\001' read -r f est qa seg sens hall rig; do
  name="${f##*/}"; n=$((n+1)); out=''
  for v in "$est" "$qa" "$seg" "$sens" "$rig"; do arnes_norm_campo "$v"; a="$ARNES_CAMPO"; out+="${out:+|}$a"; done
  IFS='|' read -r le lq ls lse lr <<< "${L[$name]}"
  lib=''; for v in "${le#est=}" "${lq#qa=}" "${ls#seg=}" "${lse#sens=}" "${lr#rig=}"; do arnes_norm_campo "$v"; lib+="${lib:+|}$ARNES_CAMPO"; done
  # Estado: la puerta lo publica ya como veredicto; se compara el veredicto del awk
  arnes_norm_campo "$est"; arnes_veredicto "$ARNES_CAMPO"; ae="$ARNES_VEREDICTO"; out="$ae|${out#*|}"
  [ "$out" = "$lib" ] || { d=$((d+1)); [ $d -le 10 ] && echo "DIF $name awk=<$out> lib=<$lib>"; }
done < "$3"
echo "archivos=$n diferencias=$d"
