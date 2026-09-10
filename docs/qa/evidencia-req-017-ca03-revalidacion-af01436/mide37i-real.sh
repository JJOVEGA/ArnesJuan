mide37i() {
  local lib="$1" fn="$2" na="$3" nb="$4" k="$5" reg x
  MED37_A=''; MED37_AX=''; MED37_B=''; MED37_BX=''; MED37_MOTIVO=''; MED37_REG=''
  MED37_PLAT=''; MED37_CARGA=''
  if [ ! -r "$lib" ]; then MED37_MOTIVO="no existe $lib"; return 1; fi
  reg="$("$UTIL_DIR/sonda-reloj.sh" --k "$k" --r 3 --etiqueta "$fn-$na-vs-$nb-intercalado" \
    --prep "source '$lib' >/dev/null 2>&1 || :; s37=''; while [ \${#s37} -lt 512 ]; do s37+='Estado: en-revision -- relleno de cabecera '; done; a37=''; while [ \${#a37} -lt $na ]; do a37+=\"\$s37\"; done; a37=\"\${a37:0:$na}\"; b37=\"\${a37:0:$nb}\"" \
    --sujeto-a "ARNES_CITA=0; ARNES_CR=0; $fn \"\$a37\"" \
    --sujeto-b "ARNES_CITA=0; ARNES_CR=0; $fn \"\$b37\"" 2>/dev/null)"
  MED37_REG="$reg"
  if [ -z "$reg" ]; then MED37_MOTIVO='la sonda de reloj no dejó registro'; return 1; fi
  if ! sonda_lee "$reg"; then MED37_MOTIVO="$SONDA_MOTIVO"; return 1; fi
  MED37_PLAT="${SONDA[plataforma]:-n/a}"; MED37_CARGA="${SONDA[carga]:-n/a}"
  MED37_A="${SONDA[min_a]:-}"; MED37_AX="${SONDA[max_a]:-}"
  MED37_B="${SONDA[min_b]:-}"; MED37_BX="${SONDA[max_b]:-}"
  for x in "$MED37_A" "$MED37_AX" "$MED37_B" "$MED37_BX"; do
    num37 "$x" && continue
    MED37_MOTIVO="la sonda no publicó los cuatro términos del par intercalado: estado=${SONDA[estado]:-?} motivo=${SONDA[motivo]:-sin motivo}"
    MED37_A=''; MED37_AX=''; MED37_B=''; MED37_BX=''; return 1
  done
  # `estado=suelo` NO se descarta: las cuatro cifras están completas y son «el número que
  # sí obtuvo», que es lo que CA-06 obliga a citar. El suelo lo juzga `razon37`, que es
  # donde vive la regla de los 50 ms para las tres razones de esta sección — reimplementarla
  # aquí sería la segunda transcripción que siempre acaba desfasada.
  case "${SONDA[estado]}" in
    ok)    ;;
    suelo) MED37_MOTIVO="la sonda declaró estado=suelo (${SONDA[motivo]:-sin motivo})" ;;
    *)     MED37_MOTIVO="la sonda no pudo medir: estado=${SONDA[estado]} motivo=${SONDA[motivo]:-sin motivo}"
           MED37_A=''; MED37_AX=''; MED37_B=''; MED37_BX=''; return 1 ;;
  esac
  return 0
}
