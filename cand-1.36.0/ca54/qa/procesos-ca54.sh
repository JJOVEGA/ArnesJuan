#!/usr/bin/env bash
# Conteo de procesos de CA-54 («Coste en procesos», REQ-007, nota del 2026-10-03; P-136-A: 0 procesos añadidos).
# Instrumento: tests/util/sonda-procesos.sh, INVOCADO tal cual (no se hace source, no se modifica), sobre las
# entradas que S1 y S2 acaban de generar en su carpeta de trabajo, con los dos árboles: v1.35.0 y el candidato.
# No mide reloj: el reloj es de S1/S2 y una muestra mixta no se publica (la sonda lo declara: instrumentada=si).
# Uso: procesos-ca54.sh <raíz del worktree con tests/util/sonda-procesos.sh> <hooks del candidato>
set -uo pipefail
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa
WT="${1:?worktree}"; CANDH="${2:?hooks del candidato}"
BASEH=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/arboles/v1.35.0/hooks
SONDA="$WT/tests/util/sonda-procesos.sh"
TRAB="${TMPDIR:-/tmp}"
declare -a ENTRADAS=(
  "s1/trabajo/ca54-65536:s1/trabajo/ca54-65536-A.json"
  "s1/trabajo/ca54-65536:s1/trabajo/ca54-65536-B.json"
  "s1/trabajo/ca54-65536:s1/trabajo/ca54-65536-C.json"
  "s1/trabajo/ca54-131072:s1/trabajo/ca54-131072-A.json"
  "s1/trabajo/ca54-131072:s1/trabajo/ca54-131072-B.json"
  "s1/trabajo/ca54-131072:s1/trabajo/ca54-131072-C.json"
  "s2/trabajo/ca54x-131072:s2/trabajo/ca54x-original.json"
  "s2/trabajo/ca54x-131072:s2/trabajo/ca54x-control-A.json"
  "s2/trabajo/ca54x-131072:s2/trabajo/ca54x-control-B.json"
  "s2/trabajo/ca54x-131072:s2/trabajo/ca54x-control-C.json"
)
for par in "${ENTRADAS[@]}"; do
  P="$E/${par%%:*}"; J="$E/${par#*:}"
  [ -d "$P/.arnes" ] && [ -s "$J" ] || { echo "FALTA entrada: $P / $J"; exit 1; }
  for arbol in v1.35.0 candidato; do
    case $arbol in v1.35.0) H=$BASEH ;; *) H=$CANDH ;; esac
    ARNES_ARBOL="$arbol" bash "$SONDA" --dir-trabajo "$TRAB" --etiqueta "${J##*/}" \
      --sujeto "CLAUDE_PROJECT_DIR='$P' bash '$H/guard.sh' < '$J'"
  done
done
