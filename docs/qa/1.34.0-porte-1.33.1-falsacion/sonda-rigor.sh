. "$S/falsa.sh"
# Deduce el rigor EFECTIVO por conducta de la puerta, con dos sondas:
#  A) QA:pendiente Seg:pendiente  -> allow solo si ligero
#  B) QA:aprobado  Seg:pendiente  -> allow si ligero o estandar; deny si critico
sonda() { local sens="$1" rig="$2" f a b
  f="$(req R900 "$sens" pendiente pendiente "$rig")"
  a="$(veredicto "$(ed "$f" 'Estado: en-revisión' 'Estado: completado')")"
  f="$(req R900 "$sens" aprobado pendiente "$rig")"
  b="$(veredicto "$(ed "$f" 'Estado: en-revisión' 'Estado: completado')")"
  case "$a$b" in
    allowallow) echo ligero ;;
    denyallow)  echo estandar ;;
    denydeny)   echo critico ;;
    *)          echo "raro($a/$b)" ;;
  esac; }
printf '%-42s %-6s %s\n' "Rigor declarado" "Sens" "rigor EFECTIVO por conducta"
while IFS='|' read -r rig; do
  for sens in no sí; do
    printf '%-42s %-6s %s\n' "${rig:-<ausente>}" "$sens" "$(sonda "$sens" "$rig")"
  done
done <<'VALS'
ligero
estandar
critico
LIGERO
Ligero
 ligero 
**ligero**
_ligero_
`ligero`
ligero (local)
ligero (D8, 2026-09-01)
estandar (matiz)
critico (por suelo)
critico (R-011, 2026-09-07)
**critico** (por suelo)
ligero(sin espacio)
ligero ()
ligero (
ligero )
ligero (critico)
critico (ligero)
(ligero)
() ligero
basura
basura (matiz)
ligero estandar
ligero, estandar
VALS
