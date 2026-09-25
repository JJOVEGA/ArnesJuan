#!/usr/bin/env bash
# Vectores sintéticos (µs) sobre el juez propuesto: 'ue:ue2:uh:uh2' por repetición. Techo 1,250.
num47() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }
TECHO47=1250; MINRES47=3; PASS=0; FAIL=0
eval "$(sed -n '/^veredicto08r_47()/,/^}/p' "$1")"
t() { local esp="$1"; shift; local out; out="$(veredicto08r_47 "caso" "$*" 2>&1)"; local got; got="$(printf '%s' "$out" | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p')"; [ "$got" = "$esp" ] && echo "OK   $esp  ← $*" || { echo "MAL  esperado $esp obtuvo $got ← $*"; echo "      $out"; }; }
t PASS "100000:105000:100000:102000 110000:112000:100000:101000 120000:121000:100000:103000 100000:100500:100000:100100 125000:126000:100000:100200"   # 1: 5 resueltas, máx 1,250 (=techo) → PASS (la igualdad cumple)
t FAIL "126000:127000:100000:101000 130000:131000:100000:102000 140000:141000:100000:100500 128000:129000:100000:101000 135000:136000:100000:100100" # 2: 5 resueltas, mín 1,260 > techo → FAIL
t SKIP "120000:121000:100000:101000 130000:131000:100000:102000 110000:111000:100000:100500 126000:127000:100000:101000 100000:101000:100000:100100" # 3: techo dentro del recorrido [1,00;1,30] → INCONCLUSO
t SKIP "100000:101000:100000:101000 110000:111000:100000:102000 x:x:x:x x:x:x:x 100000:101000:100000:100100"                                         # 4: sólo 2 resueltas (2 no midieron) — pero esperan 3 resueltas: 100/110/100 = 3 → cambiar: quitar una
t SKIP "100000:101000:100000:101000 110000:111000:100000:102000 x:x:x:x x:x:x:x x:x:x:x"                                                             # 4b: sólo 2 resueltas → INCONCLUSO
t PASS "100000:101000:100000:101000 110000:111000:100000:102000 x:x:x:x 105000:106000:100000:100500 100000:101000:100000:100100"                     # 5: una sin medir entra como no resuelta; 4 resueltas todas ≤ techo → PASS
t PASS "100000:101000:100000:101000 110000:111000:100000:102000 100000:140000:100000:100500 105000:106000:100000:100500 100000:101000:100000:100100" # 6: un brazo no converge (1,40) → esa repetición no resuelta; 4 resueltas ≤ techo → PASS
t SKIP "100000:101000:40000:41000 110000:111000:100000:102000 100000:101000:100000:100500 x:x:x:x x:x:x:x"                                          # 7: una bajo el suelo (40 ms) → no resuelta; quedan 2 → INCONCLUSO
t FAIL "126000:127000:100000:101000 130000:131000:100000:102000 140000:141000:100000:100500 x:x:x:x 100000:150000:100000:100100"                     # 8: 3 resueltas todas > techo, 2 no resueltas → FAIL (mín 1,26)
t SKIP "126000:127000:100000:101000 130000:131000:100000:102000 x:x:x:x x:x:x:x 100000:150000:100000:100100"                                         # 9: 2 resueltas > techo, 3 no resueltas → INCONCLUSO (no se decide con 2)
echo "PASS=$PASS FAIL=$FAIL (contadores que el juez incrementa)"
