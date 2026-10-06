#!/usr/bin/env bash
# Procesos de SEC-120 (REQ-007 CA-47 punto 20, «Coste: no más de 0 procesos añadidos»), fase 2.
# Dos instrumentos sobre las MISMAS entradas y los mismos árboles:
#   (1) el del contrato: tests/util/sonda-procesos.sh del worktree, INVOCADO tal cual;
#   (2) el recuento exacto de la comisión de CA-54 (ca54/forks-pidns.sh): un espacio de PID propio
#       (`unshare -Urpf`), PID final menos 2 = procesos creados por la invocación, incluido el `bash` del hook.
# Uso: procesos-sec120.sh <worktree> <etiqueta=dir de hooks>...   (R repeticiones del recuento exacto, defecto 2)
set -uo pipefail
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120/qa2/proc
WT="${1:?worktree}"; shift
SONDA="$WT/tests/util/sonda-procesos.sh"; R="${R:-2}"; TRAB="${TMPDIR:-/tmp}"
P="$E/proyecto"; D="$E/entradas"
[ -d "$P/.arnes" ] || { echo "FALTA el proyecto $P"; exit 1; }
for J in "$D"/*.json; do
  [ -e "$J" ] || { echo "FALTA entrada: $J"; exit 1; }
  linea="${J##*/}"
  for par in "$@"; do
    arbol="${par%%=*}"; H="${par#*=}"
    # (1) la sonda del contrato
    s="$(ARNES_ARBOL="$arbol" bash "$SONDA" --dir-trabajo "$TRAB" --etiqueta "${J##*/}" \
          --sujeto "CLAUDE_PROJECT_DIR='$P' bash '$H/guard.sh' < '$J'" 2>&1 | grep -o 'estado=[a-z-]*\|procesos=[0-9a-z-]*' | tr '\n' ' ')"
    # (2) el recuento exacto
    v=''
    for ((k = 1; k <= R; k++)); do
      n="$(P="$P" H="$H" J="$J" unshare -Urpf --mount-proc bash -c 'CLAUDE_PROJECT_DIR="$P" bash "$H/guard.sh" < "$J" > /dev/null 2>&1; sh -c "echo \$\$"; :')"
      v+=" $((n - 2))"
    done
    # La decisión, para que el recuento se lea con lo que hizo el hook
    d="$(CLAUDE_PROJECT_DIR="$P" bash "$H/guard.sh" < "$J" 2>/dev/null)"
    case "$d" in *'"permissionDecision":"deny"'*) d=deny ;; '') d=sin-decision ;; *) d=otra ;; esac
    linea+=" | $arbol: $d; sonda ${s% }; exacto$v"
  done
  echo "$linea"
done
