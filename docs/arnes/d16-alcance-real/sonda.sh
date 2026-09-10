. hooks/lib.sh
for sens in no sí; do
 for r in "critico" "critico (por suelo)" "**critico**" "estandar" "basura" ""; do
  ARNES_AUSENCIA_APLICA=''
  arnes_campos_normaliza "pendiente" "aprobado" "$sens" "" "$r" 2>/dev/null
  norm="$ARNES_RIGOR"
  arnes_rigor_efectivo 2>/dev/null
  printf 'Rigor:%-22s Sens:%-3s  normalizado=<%-10s>  EFECTIVO=<%s>\n' "$r" "$sens" "$norm" "$ARNES_RIGOR"
 done
done
