. /home/juan/dev/ArnesJuan-v1.35/hooks/lib.sh
E1=$(printf '\xf0\x9f\x98\x80%.0s' $(seq 20))
D=$'# REQ\nEstado: en-revisión\nSensible a seguridad: sí\n'"${E1}Sensible a seguridad: sí"$'\n'"${E1}Sensible a seguridad: sí"$'\n\n## x\n'
arnes_campos_req "$D" ''
echo "LC_ALL=${LC_ALL-<unset>} AMB=$ARNES_AMBIGUA lineas=${ARNES_AMB_N[*]} veces=${ARNES_AMB_VECES[*]} variante=${ARNES_AMB_VARIANTE[*]} SENS=[$ARNES_SENS]"
# linea a linea
while IFS= read -r l; do case "$l" in '## '*) break;; esac; arnes_campo_linea "$l" || continue
  if _arnes_clave_control; then r="ctrl=$ARNES_CTRL var=$ARNES_CTRL_VARIANTE"; else r="no-ctrl"; fi
  printf '  clave=%q -> %s\n' "$ARNES_CLAVE" "$r"; done <<< "$D"
