#!/usr/bin/env bash
# conducir.sh <salida> <etiqueta>=<hooks-dir>... — QA-037-01 con el arnés de QA (bin/carga.sh y bin/dobles.sh,
# sin cambios): arranca la carga en su propia sesión, comprueba su PGID, corre por árbol 300 cierres con la gate
# `false` y 570 con la gate `true` (dobles.sh), y mata SÓLO el grupo de la carga, comprobado.
set -u
QB=/home/juan/dev/ArnesJuan-evidencia/issue-63-plazo-gates/qa/bin
OUT="$1"; shift
W="$(dirname "$OUT")/w-$(basename "$OUT" .txt)"; mkdir -p "$W"
yo=$(ps -o pgid= -p $$ | tr -d ' ')
rm -f "$W/pgid"
setsid bash "$QB/carga.sh" "$W/pgid" </dev/null >/dev/null 2>&1 &
for _ in $(seq 50); do [ -s "$W/pgid" ] && break; sleep 0.1; done
pg=$(cat "$W/pgid" 2>/dev/null)
case "$pg" in ''|*[!0-9]*) echo "sin PGID de la carga: no se mide" >> "$OUT"; exit 1 ;; esac
[ "$pg" != "$yo" ] || { echo "PGID de la carga = el mío ($yo): no se mide" >> "$OUT"; exit 1; }
mata() { [ "$(ps -o pgid= -p "$pg" 2>/dev/null | tr -d ' ')" = "$pg" ] && kill -KILL -- "-$pg" 2>/dev/null; }
trap mata EXIT
sleep 3
{ echo "# QA-037-01 bajo carga, $(date -Is), bash $BASH_VERSION, $(nproc) núcleos; carga: qa/bin/carga.sh (PGID $pg, el mío $yo)"
  echo "# loadavg al empezar: $(cat /proc/loadavg)"; } >> "$OUT"
for par in "$@"; do
  et="${par%%=*}"; h="${par#*=}"
  for g in '["false"]' '["true"]'; do
    n=300; [ "$g" = '["true"]' ] && n=570
    echo "== $et $(date +%T) loadavg=$(cut -d' ' -f1-3 /proc/loadavg)" >> "$OUT"
    bash "$QB/dobles.sh" "$h" "$n" "$g" "$W/$et-${g//[^a-z]/}" >> "$OUT" 2>&1
  done
done
echo "# loadavg al terminar: $(cat /proc/loadavg); $(date -Is)" >> "$OUT"
