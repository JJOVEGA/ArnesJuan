#!/usr/bin/env bash
# compara2.sh <dir de logs> — como compara.sh, pero compara la DECISION en toda posicion (aunque la
# entrada no coincida por una ruta temporal aleatoria) y normaliza las rutas temporales del motivo.
# Ademas cuadra, por seccion, la lista PASS/FAIL/SKIP de la corrida base y la de la candidata.
set -uo pipefail
L="$1"
for base in "$L"/*.base.log; do
  s="${base##*/}"; s="${s%.base.log}"; cand="$L/$s.cand.log"
  out="$(paste -d '\n' "$base" "$cand" | LC_ALL=C awk -F'\t' -v s="$s" '
    function nz(x) { gsub(/\/tmp\/tmp\.[A-Za-z0-9]+\/[a-z0-9]+-[0-9]+/, "<P>", x); gsub(/\/tmp\/tmp\.[A-Za-z0-9]+/, "<T>", x); return x }
    NR % 2 == 1 { bs=$1; bk=$2; bd=$3; br=nz($4); next }
    { n++; cr=nz($4); al = ($2 == bk) ? "" : " [entrada distinta]"
      if ($3 != bd) printf "  %s #%d DECISION%s %s: base %s <%s> | cand %s <%s>\n", s, n, al, $1, bd, substr(br,1,80), $3, substr(cr,1,80)
      else if (cr != br) printf "  %s #%d MOTIVO%s (%s) %s: base <%s> | cand <%s>\n", s, n, al, bd, $1, substr(br,1,80), substr(cr,1,80) }')"
  pb="$(grep -E '^  (PASS|FAIL|SKIP)' "$L/$s.base.salida" | sed -E 's/^  (PASS|FAIL|SKIP)  (.{0,90}).*/\1 \2/' | sort)"
  pc="$(grep -E '^  (PASS|FAIL|SKIP)' "$L/$s.cand.salida" | sed -E 's/^  (PASS|FAIL|SKIP)  (.{0,90}).*/\1 \2/' | sort)"
  dif="$(diff <(printf '%s\n' "$pb") <(printf '%s\n' "$pc") | grep '^[<>]' || true)"
  nb=$(wc -l < "$base"); nc=$(wc -l < "$cand")
  if [ "$nb" -ne "$nc" ] || [ -n "$out" ] || [ -n "$dif" ]; then
    echo "== $s: $nb llamadas en base, $nc en candidata"
    [ -z "$out" ] || printf '%s\n' "$out"
    [ -z "$dif" ] || { echo "  -- veredictos del banco que cambian (base < | > candidata):"; printf '     %s\n' "$dif"; }
  fi
done
echo "== resumen: $(ls "$L"/*.base.log | wc -l) secciones comparadas"
