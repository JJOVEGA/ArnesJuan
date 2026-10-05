#!/usr/bin/env bash
# EVIDENCIA COMPLEMENTARIA, no la del contrato (que es `tests/util/sonda-procesos.sh`, en 32-…). Cuenta
# TODA creacion de proceso del sistema —fork, clone, vfork: tambien subshells, `$( )` y tuberias— con el
# contador del nucleo (`processes` en /proc/stat), leido sin procesos antes y despues de UNA invocacion
# del hook. Es de todo el sistema, asi que lleva ruido: se repite R veces y se publica el MINIMO (el ruido
# solo suma). El valor incluye el `bash` que arranca el hook (1). Sin strace en este host.
set -u
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54; WT=/home/juan/dev/ArnesJuan-v1.36; R="${R:-7}"
lee() { local l; while read -r l; do case "$l" in processes\ *) N="${l#processes }"; return ;; esac; done < /proc/stat; }
for par in s1/trabajo/ca54-65536:ca54-65536-A s1/trabajo/ca54-65536:ca54-65536-B s1/trabajo/ca54-65536:ca54-65536-C \
           s1/trabajo/ca54-131072:ca54-131072-A s1/trabajo/ca54-131072:ca54-131072-B s1/trabajo/ca54-131072:ca54-131072-C \
           s2/trabajo/ca54x-131072:ca54x-original s2/trabajo/ca54x-131072:ca54x-control-A s2/trabajo/ca54x-131072:ca54x-control-B s2/trabajo/ca54x-131072:ca54x-control-C; do
  P="$E/${par%%:*}"; J="$E/${par%%/trabajo*}/trabajo/${par#*:}.json"
  linea="${par#*:}"
  for arbol in v1.35.0 candidato; do
    case $arbol in v1.35.0) H=$E/arboles/v1.35.0/hooks ;; *) H=$WT/hooks ;; esac
    min=''; todos=''
    for ((k = 1; k <= R; k++)); do
      lee; a=$N; CLAUDE_PROJECT_DIR="$P" bash "$H/guard.sh" < "$J" > /dev/null 2>&1; lee; b=$N
      d=$((b - a)); todos+=" $d"; [ -z "$min" ] || [ "$d" -lt "$min" ] && min=$d
    done
    linea+=" | $arbol min=$min (todas:$todos)"
  done
  echo "$linea | carga=$(cut -d' ' -f1-3 /proc/loadavg)"
done
