. "$1"
for r in "ligero" "ligero (local)" "ligero (D8, 2026-09-08)" "ligero(sin espacio)" "ligero ()" "ligero (critico)" "estandar (x)" "critico (por suelo)"; do
  for sens in no sí; do
    ARNES_AUSENCIA_APLICA=''
    arnes_campos_normaliza "pendiente" "pendiente" "$sens" "" "$r" 2>/dev/null
    arnes_rigor_efectivo 2>/dev/null
    printf '  %-26s Sens=%-4s -> %s\n' "$r" "$sens" "$ARNES_RIGOR"
  done
done
