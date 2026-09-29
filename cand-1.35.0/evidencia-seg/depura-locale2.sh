. /home/juan/dev/ArnesJuan-v1.35/hooks/lib.sh
E1=$(printf '\xf0\x9f\x98\x80%.0s' $(seq 20))
D=$'# REQ-900 — sonda\nEstado: en-revisión\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: aprobado\nHallazgos abiertos: (ninguno)\nRigor: critico\n'
for i in $(seq ${N:-30}); do D+="${E1}Sensible a seguridad: sí"$'\n'; done; D+=$'\n## x\n'
arnes_campos_req "$D" ''
echo "LC_ALL=${LC_ALL-<unset>} N=${N:-30} AMB=$ARNES_AMBIGUA n_lineas=${#ARNES_AMB_N[@]} primeras=${ARNES_AMB_N[*]:0:3} veces0=${ARNES_AMB_VECES[0]} var0=${ARNES_AMB_VARIANTE[0]}"
