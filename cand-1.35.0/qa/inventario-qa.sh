# inventario-qa.sh <hooks> <archivos...>: cuántas cabeceras son ambiguas (lector de la puerta)
. "$1/lib.sh"; shift; n=0; a=0
for f in "$@"; do case "${f##*/}" in README.md) continue;; esac
  arnes_lee_archivo "$f" || { echo "ILEGIBLE $f"; continue; }; n=$((n+1))
  arnes_campos_req "$ARNES_TEXTO" ''
  if [ "${#ARNES_AMB_N[@]}" -gt 0 ] || [ "${ARNES_AMBIGUA:-0}" = 1 ]; then a=$((a+1)); echo "AMBIGUA ${f##*/}: ${#ARNES_AMB_N[@]} lineas (ARNES_AMBIGUA=$ARNES_AMBIGUA)"; fi
done
echo "cabeceras=$n ambiguas=$a"
