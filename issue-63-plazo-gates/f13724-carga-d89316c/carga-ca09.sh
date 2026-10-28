#!/usr/bin/env bash
# carga-ca09.sh <cabeza>: la carga de CA-09 de REQ-037 sobre <cabeza>, lanzada por la coordinadora (P-137-AM).
# Usa bin/carga.sh y bin/cierres.sh de QA (issue-63-f13724-qa) sin cambios; el árbol, por git archive (hooks + tools).
# Tramo 1: las cuatro clases a la vez, 850 por clase; tramo 2: una clase tras otra, 150 por clase (4 000 cierres).
set -u
H="$1"; R=/home/juan/dev/ArnesJuan-1.36.3
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
Q=$S/issue-63-f13724-qa; C=$S/issue-63-f13724-carga-$H
rm -rf "$C"; mkdir -p "$C/bin" "$C/arb/$H"
cp $Q/bin/carga.sh $Q/bin/cierres.sh "$C/bin/"
git -C "$R" archive "$H" hooks tools | tar -x -C "$C/arb/$H"
{
  echo "# CA-09 sobre $H, lanzada por la coordinadora (Opus), $(date -Is), bash $BASH_VERSION, $(nproc) núcleos"
  echo "# sha256 de los guiones (iguales a los de QA):"; sha256sum $Q/bin/carga.sh $C/bin/carga.sh $Q/bin/cierres.sh $C/bin/cierres.sh
  echo "# sha256 del árbol congelado:"; (cd "$C/arb/$H" && find hooks tools -type f | sort | xargs sha256sum | sha256sum)
} > "$C/00-cabecera.txt"
tramo() {  # tramo <nombre> <concurrente|serie> <n>
  local NOM=$1 M=$2 N=$3 W=$C/w-$1 PG MIO ps_ c
  mkdir -p "$W"
  setsid bash $C/bin/carga.sh $W/pgid >/dev/null 2>&1 &
  sleep 2; PG=$(cat $W/pgid); MIO=$(ps -o pgid= -p $$ | tr -d ' ')
  echo "# $NOM ($M, $N por clase), $(date -Is); carga PGID $PG (el mío $MIO)"
  echo "$PG" >> $C/pgids-carga.txt
  [ -n "$PG" ] && [ "$PG" != "$MIO" ] || { echo "PGID dudoso: aborto"; return 1; }
  sleep 15; echo "loadavg al empezar: $(cut -d' ' -f1-3 /proc/loadavg)"
  case $M in
    concurrente) ps_=(); for c in valido rojo caducado ausente; do bash $C/bin/cierres.sh $C/arb/$H $c $N $W > $W/r-$c.txt 2>&1 & ps_+=($!); done
                 wait "${ps_[@]}"; cat $W/r-*.txt ;;
    serie) for c in valido rojo caducado ausente; do bash $C/bin/cierres.sh $C/arb/$H $c $N $W; done ;;
  esac
  echo "loadavg al terminar: $(cut -d' ' -f1-3 /proc/loadavg) $(date +%T)"
  kill -KILL -- "-$PG"; sleep 1; echo "quedan en el grupo de carga $PG: $(pgrep -g $PG | wc -l)"
}
tramo t1-concurrente concurrente 850 > "$C/01-carga-concurrente.txt" 2>&1
tramo t2-serie serie 150 > "$C/02-carga-serie.txt" 2>&1
grep -h '^==' "$C"/0[12]-*.txt > "$C/resumen.txt"
echo "fin $(date -Is)" >> "$C/resumen.txt"
