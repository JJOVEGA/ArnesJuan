#!/usr/bin/env bash
# r067 (auditor-seguridad): re-firma de REQ-037 sobre f900a98, a nivel de hook (guard.sh). Columnas: candidato | v1.36.2.
set -u
R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r067
R66=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r066
C=$R/arb/cand; B=$R66/arb/base; T=$C/tools/arnes-gates.sh; W=$R/w
eval "$(sed -n '/^mk() {/,/^}/p; /^cierra() {/,/^}/p' $R66/sondas.sh)"
herr() { ( cd "$1" && bash "$T" --quien auditor-seguridad >/dev/null 2>&1 ); echo "herramienta rc=$?"; }
t() { local t0=${EPOCHREALTIME/./} d; d=$(cierra "$1" "$2"); echo "${d:0:90} [$(( (${EPOCHREALTIME/./}-t0)/1000 )) ms]"; }

echo "## S1 cierre legitimo"
mk $W/c1 '["grep -q bien src/a.txt"]'; herr $W/c1; echo "  cand: $(t $C $W/c1)"; echo "  base: $(t $B $W/c1)"
echo "## S2 caducado normal (cambio de codigo tras el verde)"
echo mal > $W/c1/src/a.txt; echo "  cand: $(t $C $W/c1)"; echo "  base: $(t $B $W/c1)"
echo "## S10 caducado + disperso de 64 GiB, con ARNES_HASH_PRESUPUESTO_S=1000 en el entorno del hook"
truncate -s 64G $W/c1/datos.bin; export ARNES_HASH_PRESUPUESTO_S=1000
echo "  cand: $(t $C $W/c1)"; echo "  base: $(t $B $W/c1)"; unset ARNES_HASH_PRESUPUESTO_S
echo "  vivos tras el corte: git=$(pgrep -c git)"
echo "## S10b la herramienta sobre ese arbol (verde de gates, huella que no termina)"
echo bien > $W/c1/src/a.txt; herr $W/c1; echo "  registro: $(ls $W/c1/.arnes/gates-veredicto.json 2>&1 | grep -c 'No such')=ausente"; rm -f $W/c1/datos.bin
echo "## S12 .gitignore que es una FIFO, con verde previo"
mk $W/c12 '["grep -q bien src/a.txt"]'; herr $W/c12; rm $W/c12/.gitignore; mkfifo $W/c12/.gitignore
echo "  cand: $(t $C $W/c12)"; echo "  base: $(t $B $W/c12)"; echo "  vivos tras el corte: git=$(pgrep -c git)"
rm -rf $W/c1 $W/c12
