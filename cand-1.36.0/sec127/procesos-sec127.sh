#!/usr/bin/env bash
# Procesos de la fase 2 de SEC-127 + QA-007-06 («0 procesos añadidos en el camino común»). Mismos dos
# instrumentos que sec120/procesos-sec120.sh, sobre las MISMAS entradas y el mismo proyecto de SEC-120:
#   (1) el del contrato: tests/util/sonda-procesos.sh del worktree, invocado tal cual;
#   (2) el recuento exacto: un espacio de PID propio (`unshare -Urpf`), PID final menos 2.
# Entradas: sec120/entradas/n*.json (el camino común), sec127/entradas/*.json (el atajo con texto no ASCII),
# y dos formas sin archivo: la entrada estándar CERRADA y la que es un DIRECTORIO (QA-007-06).
# Uso: procesos-sec127.sh <worktree> <etiqueta=dir de hooks>...   (R repeticiones del exacto, defecto 2)
set -uo pipefail
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0; WT="${1:?worktree}"; shift
SONDA="$WT/tests/util/sonda-procesos.sh"; R="${R:-2}"; TRAB="${TMPDIR:-/tmp}"; P="$E/sec120/proyecto"; DIRV="$E/sec127/entradas"
[ -d "$P/.arnes" ] || { echo "FALTA el proyecto $P"; exit 1; }
for J in "$E"/sec120/entradas/n*.json "$E"/sec127/entradas/*.json cerrada directorio; do
  case "$J" in
    cerrada)    red='<&-';           linea="stdin-cerrada" ;;
    directorio) red="< '$DIRV'";      linea="stdin-directorio" ;;
    *)          [ -s "$J" ] || { echo "FALTA entrada: $J"; exit 1; }; red="< '$J'"; linea="${J##*/}" ;;
  esac
  for par in "$@"; do
    arbol="${par%%=*}"; H="${par#*=}"
    # Una etiqueta por entrada Y árbol: con la misma, la sonda devolvía también los registros de los
    # árboles anteriores (primera corrida de 80-, descartada).
    s="$(ARNES_ARBOL="$arbol" bash "$SONDA" --dir-trabajo "$TRAB" --etiqueta "${linea%% *}-$arbol-$$" \
          --sujeto "CLAUDE_PROJECT_DIR='$P' bash '$H/guard.sh' $red" 2>&1 | grep -o 'estado=[a-z-]*\|procesos=[0-9a-z-]*' | tr '\n' ' ')"
    v=''
    for ((k = 1; k <= R; k++)); do
      n="$(P="$P" H="$H" RED="$red" unshare -Urpf --mount-proc bash -c 'eval "CLAUDE_PROJECT_DIR=\"\$P\" bash \"\$H/guard.sh\" $RED" > /dev/null 2>&1; sh -c "echo \$\$"; :')"
      v+=" $((n - 2))"
    done
    d="$(eval "CLAUDE_PROJECT_DIR='$P' bash '$H/guard.sh' $red" 2>/dev/null)"
    case "$d" in *'"permissionDecision":"deny"'*) d=deny ;; '') d=sin-decision ;; *) d=otra ;; esac
    linea+=" | $arbol: $d; sonda ${s% }; exacto$v"
  done
  echo "$linea"
done
