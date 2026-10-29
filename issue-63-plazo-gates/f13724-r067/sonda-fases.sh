R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r067
. $R/arb/cand/hooks/lib.sh
ARNES_HASH_PRESUPUESTO_S=120; SECONDS=0; t0=${EPOCHREALTIME/./}; arnes_hash_arbol $R/w/enl; echo "sin corte: rc=$? ms=$(( (${EPOCHREALTIME/./}-t0)/1000 ))"
( ARNES_HASH_PRESUPUESTO_S=5; SECONDS=0; arnes_hash_arbol $R/w/enl & sleep 4.5; echo "a 4,5 s: readlink en curso=$(pgrep -c readlink)"; wait )
