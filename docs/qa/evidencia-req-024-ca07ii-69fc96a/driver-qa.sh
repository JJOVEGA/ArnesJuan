#!/usr/bin/env bash
# driver-qa.sh — mide KRAZ pares intercalados con la SONDA REAL y decide con las FUNCIONES
# REALES razon07/veredicto07 extraidas de la seccion 40/7. QA, vuelta 1, REQ-024 CA-07 (ii).
set -uo pipefail
S="$(cd "$(dirname "$0")" && pwd)"
R=/home/juan/dev/ArnesJuan-1.34-reparaciones
UTIL_DIR="$R/tests/util"
DIR_A="${DIR_A:-$S/este}"    # el arbol "este"
DIR_B="${DIR_B:-$S/base}"    # la linea base v1.33.0
SER07="${SER07:-6}"; K07="${K07:-4}"; KRAZ07="${KRAZ07:-4}"
TECHO07=1250; FACTOR07=2000
PV="$S/fix/proj-vacio"; ENT="$S/fix/ent.json"
PASS=0; FAIL=0
declare -A SONDA=(); SONDA_MOTIVO=''
. "$S/helpers.sh"
. "$S/decisor.sh"
REPS07=''
for ((n=1;n<=KRAZ07;n++)); do
  reg="$("$UTIL_DIR/sonda-reloj.sh" --k "$K07" --r "$SER07" --etiqueta "qa-$n" \
    --sujeto-a "CLAUDE_PROJECT_DIR='$PV' bash '$DIR_A/hooks/guard-completado.sh' < '$ENT' >/dev/null 2>&1" \
    --sujeto-b "CLAUDE_PROJECT_DIR='$PV' bash '$DIR_B/hooks/guard-completado.sh' < '$ENT' >/dev/null 2>&1" 2>/dev/null)"
  if sonda_lee "$reg" && [ "${SONDA[estado]}" = ok ]; then
    REPS07="$REPS07 ${SONDA[min_a]:-}:${SONDA[min2_a]:-}:${SONDA[min_b]:-}:${SONDA[min2_b]:-}"
  else
    REPS07="$REPS07 :::"
  fi
done
echo "reps: $REPS07"
veredicto07 "QA-drv k=$K07 r=$SER07 kraz=$KRAZ07 A=${DIR_A##*/} B=${DIR_B##*/}" si $REPS07
