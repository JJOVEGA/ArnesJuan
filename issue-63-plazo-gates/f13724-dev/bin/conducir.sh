#!/usr/bin/env bash
# conducir.sh <salida> <hooks d47cfba> <hooks candidata> — CA-08 (a) con la carga de QA-037-01 (qa/bin/carga.sh, sin
# cambios), en su propia sesión con su PGID comprobado. Fail-before: qa/bin/dobles.sh (sin cambios) sobre d47cfba, 300
# cierres con la gate `false` y 570 con `true`. Candidata: bin/dobles-v.sh, 300 cierres por clase (verde, roja, caducado,
# ausente), las cuatro A LA VEZ (cierres concurrentes). Al final mata SÓLO el grupo de la carga.
set -u
QB=/home/juan/dev/ArnesJuan-evidencia/issue-63-plazo-gates/qa/bin; X="$(cd "$(dirname "$0")" && pwd)"
OUT="$1"; HD="$2"; HC="$3"; W="${OUT%.txt}-w"; mkdir -p "$W"
yo=$(ps -o pgid= -p $$ | tr -d ' ')
rm -f "$W/pgid"; setsid bash "$QB/carga.sh" "$W/pgid" </dev/null >/dev/null 2>&1 &
for _ in $(seq 50); do [ -s "$W/pgid" ] && break; sleep 0.1; done
pg=$(cat "$W/pgid" 2>/dev/null)
case "$pg" in ''|*[!0-9]*) echo "sin PGID de la carga: no se mide" >> "$OUT"; exit 1 ;; esac
[ "$pg" != "$yo" ] || { echo "PGID de la carga = el mío ($yo): no se mide" >> "$OUT"; exit 1; }
mata() { [ "$(ps -o pgid= -p "$pg" 2>/dev/null | tr -d ' ')" = "$pg" ] && kill -KILL -- "-$pg" 2>/dev/null; }
trap mata EXIT
sleep 3
{ echo "# CA-08 (a) bajo la carga de QA-037-01, $(date -Is), bash $BASH_VERSION, $(nproc) núcleos; carga PGID $pg (el mío $yo)"
  echo "# loadavg al empezar: $(cat /proc/loadavg)"; echo "# procesos de otros bancos al empezar: $(pgrep -fc 'escenarios/hooks/run.sh' || true)"; } >> "$OUT"
echo "== d47cfba (fail-before), qa/bin/dobles.sh sin cambios, $(date +%T)" >> "$OUT"
bash "$QB/dobles.sh" "$HD" 300 '["false"]' "$W/d47-false" >> "$OUT" 2>&1
bash "$QB/dobles.sh" "$HD" 570 '["true"]' "$W/d47-true" >> "$OUT" 2>&1
echo "== candidata, bin/dobles-v.sh, cuatro clases a la vez, $(date +%T) loadavg $(cut -d' ' -f1-3 /proc/loadavg)" >> "$OUT"
js=(); for k in verde roja caducado ausente; do bash "$X/dobles-v.sh" "$HC" 300 "$k" "$W/cand" > "$W/cand-$k.txt" 2>&1 & js+=($!); done
wait "${js[@]}"
cat "$W"/cand-*.txt >> "$OUT"
echo "# loadavg al terminar: $(cat /proc/loadavg); procesos de otros bancos: $(pgrep -fc 'escenarios/hooks/run.sh' || true); $(date -Is)" >> "$OUT"
