#!/usr/bin/env bash
# E2 (REQ-007 CA-69 punto 7): la sección 37/3 del banco de v1.35.0, SIN cambiarla, 6 corridas en serie con
# ARNES_HOOKS_DIR en los hooks del candidato, intercaladas con 6 contra los de v1.35.0. Clasifica la línea
# del caso de la pared (REQ-017 CA-09 «la pared de los 60 s …») en PASS / SKIP por solape / SKIP estructural / FAIL.
# Uso: 41-e2.sh <candidato/hooks> <v1.35.0 base> [k=6]
set -u; C="${1:?}"; B="${2:?}"; K="${3:-6}"
echo "# E2 $(date -Is); v1.35.0 tests/ en $(git -C "$B" rev-parse --short HEAD) ($(git -C "$B" status --short -- tests | wc -l) cambios); k=$K"
clasifica() { case "$1" in
  *'  PASS  REQ-017 CA-09 la pared'*) echo PASS ;;
  *'  FAIL  REQ-017 CA-09 la pared'*) echo FAIL ;;
  *'SE SOLAPAN'*) echo SKIP-solape ;;
  *'  SKIP  REQ-017 CA-09 la pared'*) echo SKIP-estructural ;;
  *) echo SIN-LINEA ;; esac; }
for ((r = 1; r <= K; r++)); do
  for par in candidato="$C" v1.35.0="$B/hooks"; do
    et="${par%%=*}"; h="${par#*=}"
    o="$(cd "$B" && ARNES_HOOKS_DIR="$h" bash tests/escenarios/hooks/run.sh secciones/37-coste-del-escaner-3-la-pared.sh 2>&1)"
    l="$(grep -E '^  (PASS|FAIL|SKIP)  REQ-017 CA-09 la pared' <<< "$o")"
    printf 'r=%s %-9s %-17s | %s\n' "$r" "$et" "$(clasifica "$l")" "${l:0:330}"
  done
done
