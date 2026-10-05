#!/usr/bin/env bash
# EVIDENCIA COMPLEMENTARIA, no la del contrato (que es `tests/util/sonda-procesos.sh`, en 32-…). Cuenta
# EXACTAMENTE todo proceso creado por una invocacion del hook —fork, clone, vfork: binarios, subshells,
# `$( )`, tuberias— en un espacio de PID propio (`unshare -Urpf`), donde los PID se asignan en secuencia
# desde 1: PID 1 es el `bash -c` que lanza, el hook y todo lo que crea toman los siguientes, y un `sh`
# final imprime el suyo. `procesos` = ese PID final menos 2 (el `bash -c` y el `sh`): incluye el `bash`
# que arranca el hook. Determinista: no depende del resto del sistema. Sin strace en este host.
set -u
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa; BH=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/arboles/v1.35.0/hooks; WT=/home/juan/dev/ArnesJuan-v1.36; R="${R:-2}"
for par in s1/trabajo/ca54-65536:ca54-65536-A s1/trabajo/ca54-65536:ca54-65536-B s1/trabajo/ca54-65536:ca54-65536-C \
           s1/trabajo/ca54-131072:ca54-131072-A s1/trabajo/ca54-131072:ca54-131072-B s1/trabajo/ca54-131072:ca54-131072-C \
           s2/trabajo/ca54x-131072:ca54x-original s2/trabajo/ca54x-131072:ca54x-control-A s2/trabajo/ca54x-131072:ca54x-control-B s2/trabajo/ca54x-131072:ca54x-control-C s1/trabajo/propios-131072:propio-M-A s1/trabajo/propios-131072:propio-M-B s1/trabajo/propios-131072:propio-M-C s1/trabajo/propios-131072:propio-N-A s1/trabajo/propios-131072:propio-N-B s1/trabajo/propios-131072:propio-N-C s1/trabajo/propios-131072:propio-MR-A; do
  P="$E/${par%%:*}"; J="$E/${par%%/trabajo*}/trabajo/${par#*:}.json"; linea="${par#*:}"
  for arbol in v1.35.0 candidato; do
    case $arbol in v1.35.0) H=$BH ;; *) H=$WT/hooks ;; esac
    v=''
    for ((k = 1; k <= R; k++)); do
      n="$(P="$P" H="$H" J="$J" unshare -Urpf --mount-proc bash -c 'CLAUDE_PROJECT_DIR="$P" bash "$H/guard.sh" < "$J" > /dev/null 2>&1; sh -c "echo \$\$"; :')"
      v+=" $((n - 2))"
    done
    linea+=" | $arbol procesos:$v"
  done
  echo "$linea"
done
