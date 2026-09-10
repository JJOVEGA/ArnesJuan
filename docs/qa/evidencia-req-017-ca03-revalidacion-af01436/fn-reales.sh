num37() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }
mil37() { printf -v MIL37 '%d.%03d' $(( ${1} / 1000 )) $(( ${1} % 1000 )); }
banda37() {
  local mn="$1" xn="$2" md="$3" xd="$4" techo="$5" dir="$6"
  BAN37_V=''; BAN37_LO=''; BAN37_HI=''
  BAN37_LO=$(( mn * 1000 / xd )); BAN37_HI=$(( xn * 1000 / md )); BAN37_V=SKIP
  case "$dir" in
    no-excede) if [ "$BAN37_HI" -le "$techo" ]; then BAN37_V=PASS; elif [ "$BAN37_LO" -gt "$techo" ]; then BAN37_V=FAIL; fi ;;
    excede)    if [ "$BAN37_LO" -gt "$techo" ]; then BAN37_V=PASS; elif [ "$BAN37_HI" -le "$techo" ]; then BAN37_V=FAIL; fi ;;
    *)         BAN37_V=''; return 1 ;;
  esac
  return 0
}
razon37() {
  local nombre="$1" med="$2" base="$3" techo="$4" que="$5"
  local xmed="${6:-}" xbase="${7:-}" dir="${8:-}" mue="${9:-}" coc ev qc qt lo hi
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  mil37 "$techo"; qt="$MIL37"
  # La evidencia se arma UNA vez y sale en TODAS las ramas —PASS, FAIL y las abstenciones—:
  # es lo que hace atribuible el próximo rojo, no el adorno del SKIP.
  ev="mín/máx ${med:-n/a}/${xmed:-n/a}µs sobre ${base:-n/a}/${xbase:-n/a}µs · techo $qt×${mue:+ · $mue}"
  if [ -z "$med" ] || [ -z "$base" ]; then
    echo "  SKIP  $nombre  no hay con qué medir: ${MED37_MOTIVO:-falta uno de los dos términos} (medido=<${med:-vacío}> base=<${base:-vacío}>) · $ev"; return 0
  fi
  if [ "$med" -lt 50000 ] || [ "$base" -lt 50000 ]; then
    echo "  SKIP  $nombre  serie por debajo del suelo de 50 ms: el reloj no distingue del ruido · $ev"; return 0
  fi
  coc=$(( med * 1000 / base )); mil37 "$coc"; qc="$MIL37"
  if [ -n "$dir" ]; then
    if ! num37 "$xmed" || ! num37 "$xbase"; then
      echo "  SKIP  $nombre  la banda necesita el MÁXIMO de los dos términos y no llegó (máx medido=<${xmed:-vacío}> máx base=<${xbase:-vacío}>) · $ev"; return 0
    fi
    if ! banda37 "$med" "$xmed" "$base" "$xbase" "$techo" "$dir"; then
      echo "  SKIP  $nombre  dirección de banda no reconocida <$dir>: la puerta no puede decidir · $ev"; return 0
    fi
    mil37 "$BAN37_LO"; lo="$MIL37"; mil37 "$BAN37_HI"; hi="$MIL37"
    ev="$que = $qc× · banda compatible [$lo×, $hi×] · $ev"
    case "$BAN37_V" in
      PASS) echo "  PASS  $nombre  TODA la banda cae del lado conforme · $ev"; PASS=$((PASS+1)) ;;
      FAIL) echo "  FAIL  $nombre  TODA la banda cae del lado NO conforme · $ev"; FAIL=$((FAIL+1)) ;;
      *)    echo "  SKIP  $nombre  el techo $qt× cae DENTRO de la banda: el veredicto dependería del ruido de esta corrida · $ev" ;;
    esac
    return 0
  fi
  if [ "$coc" -le "$techo" ]; then
    echo "  PASS  $nombre  $que = $qc× (techo $qt×; ${med}µs sobre ${base}µs) · $ev"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  $que = $qc× > techo $qt× (${med}µs sobre ${base}µs) · $ev"; FAIL=$((FAIL+1))
  fi
}
