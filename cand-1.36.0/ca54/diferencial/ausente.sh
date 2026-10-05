. /home/juan/dev/ArnesJuan-v1.36/hooks/lib.sh
RANDOM=777
est=( completado COMPLETADO Completado done en-revision terminado_1 x 'a.b' 'compl[e]tado' '' 'é' 'completádo' 'K' 'i' 'I' 's' 'cOmPlEtAdO-2' )
piezas=( completado COMPLETADO CompLetado completad o ado ' ' $'\n' x y 'é' 'ñ' 'İ' 'ı' 'K' 'ſ' 'done' 'DONE' 'en-revision' 'EN-REVISION' terminado_1 'a.b' 'aXb' '-' '_' 'K' 'i' 'I' 's' '(' '"' "'" 1 2 'cOmPlEtAdO-2' 'compl' 'etado' 'Completado-2' )
viol=0; afirma=0; total=0
for ((n = 0; n < 6000; n++)); do
  t=''; m=$(( RANDOM % 8 + 1 )); for ((i = 0; i < m; i++)); do t+="${piezas[RANDOM % ${#piezas[@]}]}"; done
  for e in "${est[@]}"; do
    total=$((total+1))
    if arnes_estado_ausente "$t" "$e"; then
      afirma=$((afirma+1))
      if grep -iqE "(^|[^a-zA-Z])${e}([^a-zA-Z]|$)" <<< "$t"; then viol=$((viol+1)); printf 'VIOLACION %q %q\n' "$t" "$e"; fi
    fi
  done
done
echo "locale=${LC_ALL:-$LANG} pares=$total afirma_ausente=$afirma violaciones=$viol"
