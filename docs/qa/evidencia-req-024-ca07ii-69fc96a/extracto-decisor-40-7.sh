num07() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }
FMT07=''
fmt07() { printf -v FMT07 '%d.%03d×' $(( ${1} / 1000 )) $(( ${1} % 1000 )); }
R07=''; MOT07=''; CONV07=0
razon07() {   # <ue:ue2:uh:uh2 en µs> -> R07 y CONV07, o R07 vacío y MOT07 con el motivo
  local rep="$1" ue ue2 uh uh2 ce ch x rob
  R07=''; MOT07=''; CONV07=0
  ue="${rep%%:*}"; x="${rep#*:}"; ue2="${x%%:*}"; x="${x#*:}"; uh="${x%%:*}"; uh2="${x##*:}"
  for x in "$ue" "$ue2" "$uh" "$uh2"; do
    num07 "$x" && [ "$x" -gt 0 ] && continue
    MOT07="la sonda no dio $SER07 series por árbol con sus dos mínimos (este ${ue:-vacío}/${ue2:-vacío}µs · heredada ${uh:-vacío}/${uh2:-vacío}µs)"; return 0
  done
  if [ "$uh" -lt 50000 ] || [ "$ue" -lt 50000 ]; then
    MOT07="serie por debajo del suelo de 50 ms (este ${ue}µs · heredada ${uh}µs): el reloj no distingue del ruido"; return 0
  fi
  ce=$(( ue2 * 1000 / ue )); ch=$(( uh2 * 1000 / uh ))
  CONV07="$ce"; [ "$ch" -gt "$ce" ] && CONV07="$ch"
  if [ "$CONV07" -gt "$TECHO07" ]; then
    # LA RAZÓN OBTENIDA SE CALCULA AQUÍ, ANTES DE ABSTENERSE, Y VA EN `MOT07` — NUNCA EN `R07`,
    # que no vacío significa «hay razón válida para juzgar». Un SKIP sin la cifra que sí se
    # obtuvo no dice DE QUÉ se abstiene; se perdió así una vez (QA-017-16, `contrato`).
    fmt07 $(( ue * 1000 / uh )); rob="$FMT07"
    fmt07 "$ce"; x="$FMT07"; fmt07 "$ch"; ce="$FMT07"; fmt07 "$TECHO07"; ch="$FMT07"
    MOT07="la sonda NO convergió: segundo mínimo / mínimo = $x (este) y $ce (heredada), por encima de su propio techo $ch — no puede distinguir una regresión de su ruido. La razón que sí obtuvo es $rob, y sobre eso no se firma"
    return 0
  fi
  R07=$(( ue * 1000 / uh ))
}
# LA CONVERGENCIA ES NECESARIA Y NO SUFICIENTE, y está MEDIDO arriba: responde «¿se asentó CADA
# serie?», no «¿puede ESTE COCIENTE distinguir el factor que vigila?». Por eso ENCIMA va la
# resolución sobre la RAZÓN: PASS si máx(r) <= techo (conforme en TODAS), FAIL si mín(r) > techo
# (excedido en TODAS, así que no lo puso ahí el vecino) y SKIP en cuanto el techo cae DENTRO del
# recorrido. La unanimidad es DE CONTRATO —la definición de «la decisión no depende del ruido»—
# y no admite mayoría, promedio ni «la mejor de k». `guarda = no` reproduce la regla ANTERIOR y
# existe sólo para el par discriminante: sin ella, un SKIP no demuestra que lo causara la
# guarda. No toca los contadores: no es un caso, es el testigo de uno.
veredicto07() {   # <nombre> <guarda: si|no> <rep...>, rep = ue:ue2:uh:uh2 en µs
  local nombre="$1" guarda="$2"; shift 2
  local rep n=0 rmin='' rmax='' cmax=0 lista='' techo mn mx rec
  fmt07 "$TECHO07"; techo="$FMT07"
  if [ "$guarda" = no ]; then
    for rep in "$@"; do
      razon07 "$rep"
      if [ -z "$R07" ]; then echo "  SKIP  $nombre  $MOT07"; continue; fi
      fmt07 "$R07"
      if [ "$R07" -le "$TECHO07" ]; then echo "  PASS  $nombre  $FMT07 <= $techo"
      else echo "  FAIL  $nombre  $FMT07 > $techo"; fi
    done
    return 0
  fi
  for rep in "$@"; do
    n=$((n + 1))
    razon07 "$rep"
    [ -n "$R07" ] || { echo "  SKIP  $nombre  repetición $n de $#: $MOT07"; return 0; }
    if [ "$CONV07" -gt "$cmax" ]; then cmax="$CONV07"; fi
    fmt07 "$R07"; lista="$lista $FMT07"
    if [ -z "$rmin" ] || [ "$R07" -lt "$rmin" ]; then rmin="$R07"; fi
    if [ -z "$rmax" ] || [ "$R07" -gt "$rmax" ]; then rmax="$R07"; fi
  done
  [ "$n" -ge 1 ] || { echo "  SKIP  $nombre  no llegó ninguna repetición del par intercalado"; return 0; }
  rec=$(( rmax * 1000 / rmin ))
  fmt07 "$rmin"; mn="$FMT07"; fmt07 "$rmax"; mx="$FMT07"; fmt07 "$rec"; rec="$FMT07"; fmt07 "$cmax"; cmax="$FMT07"
  # Las k razones, el recorrido y el techo se publican SIEMPRE: son la evidencia de que la
  # decisión no depende del ruido, no el adorno del SKIP.
  lista="$n razones:$lista · recorrido $rec · techo $techo · peor convergencia $cmax · k=$K07 r=$SER07"
  if [ "$rmax" -le "$TECHO07" ]; then
    echo "  PASS  $nombre  máx(r) $mx <= techo en las $lista"; PASS=$((PASS+1))
  elif [ "$rmin" -gt "$TECHO07" ]; then
    echo "  FAIL  $nombre  mín(r) $mn > techo en TODAS: es regresión, no ruido — el techo es OPERATIVO y no se sube, lo que baja es el coste del lector — $lista"; FAIL=$((FAIL+1))
  else
    echo "  SKIP  $nombre  el techo cae DENTRO del recorrido observado [$mn, $mx]: el instrumento no distingue el factor que vigila, y una medición inconclusa NO es una aprobación. Vía de acreditación: repetir con ARNES_COSTE_RUTA_CRITICA=1 (r=30, k=8) o en un host menos cargado — nunca subir el techo — $lista"
  fi
}
