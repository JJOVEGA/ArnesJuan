#!/usr/bin/env bash
# P-136-M (A): medición dirigida de REQ-017 CA-08 (ii), «un REQ real de 6 líneas», con el anfitrión en reposo.
# Banco de v1.35.0 tal cual (/home/juan/dev/ArnesJuan-v1.35.0-base), filtro del corredor sobre ese caso y selector
# de su sección (37/5, la única que lo emite), ARNES_HOOKS_DIR en cada árbol materializado por SHA con `tools/`
# hermano. Orden: v1.35.0 -> 82ceb63 -> 413c6bd -> a59917d -> 78a2f33. Una corrida por commit (SONDA_COSTE_R=5
# mediciones, el literal del corredor). Sin repetir.
# Antes: carga de 1 min < 0,5, esperando como mucho 20 min; si no baja, NO se mide.
set -u
M=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127/m-ca08; W=/home/juan/dev/ArnesJuan-v1.36; B=/home/juan/dev/ArnesJuan-v1.35.0-base
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/mca08
SEC=tests/escenarios/hooks/secciones/37-coste-del-escaner-5-el-camino-normal.sh
FIL='REQ-017 CA-08 (ii) un REQ real de 6 líneas'
L="$M/00-carga.txt"
# Árboles por SHA (hooks/ y tools/ hermanos), antes de esperar: no cuentan en la medida.
rm -rf "$S"; mkdir -p "$S"
for c in 82ceb63 413c6bd a59917d 78a2f33; do
  mkdir -p "$S/$c" && git -C "$W" archive "$c" hooks tools | tar -x -C "$S/$c"
done
{ date -Is; uname -a; bash --version | head -1
  echo "v1.35.0: $B ($(git -C $B rev-parse --short HEAD); hooks/ y tools/ frente a 3956a6f: $(git -C $B diff --quiet 3956a6f -- hooks tools && echo identicos || echo DIFIEREN))"
  for c in 82ceb63 413c6bd a59917d 78a2f33; do
    printf '%s: %s; diff frente a git: ' "$c" "$S/$c"
    ( cd "$S/$c" && git -C "$W" diff --quiet "$c" -- hooks tools 2>/dev/null; for f in hooks/*.sh tools/*.sh; do [ "$(git -C "$W" rev-parse "$c:$f")" = "$(git hash-object "$f")" ] || echo "DIFIERE $f"; done; echo "comprobado archivo a archivo" )
  done
  sha256sum "$B/$SEC"; } > "$M/01-entorno.txt" 2>&1
echo "== espera de reposo (carga de 1 min < 0,5; tope 20 min)" > "$L"
t0=$SECONDS; ok=no
while :; do
  read -r l1 l5 l15 _ < /proc/loadavg
  printf '%s  %s %s %s\n' "$(date +%T)" "$l1" "$l5" "$l15" >> "$L"
  if awk -v x="$l1" 'BEGIN{exit !(x < 0.5)}'; then ok=si; break; fi
  [ $((SECONDS - t0)) -lt 1200 ] || break
  sleep 30
done
if [ "$ok" != si ]; then echo "NO SE MIDE: la carga no bajó de 0,5 en 20 min" >> "$L"; echo FIN; exit 0; fi
echo "== reposo alcanzado: empieza la medida ($(cat /proc/loadavg))" >> "$L"
cd "$B" || exit 1
n=1
for par in "v1.35.0=$B/hooks" "82ceb63=$S/82ceb63/hooks" "413c6bd=$S/413c6bd/hooks" "a59917d=$S/a59917d/hooks" "78a2f33=$S/78a2f33/hooks"; do
  c="${par%%=*}"; h="${par#*=}"
  echo "== $c: inicio $(date +%T), carga $(cat /proc/loadavg)" >> "$L"
  ( time ARNES_HOOKS_DIR="$h" bash tests/escenarios/hooks/run.sh "$SEC" "$FIL" ) > "$M/1$n-$c.txt" 2>&1
  echo "== $c: fin $(date +%T), carga $(cat /proc/loadavg)" >> "$L"
  n=$((n + 1))
done
echo FIN
