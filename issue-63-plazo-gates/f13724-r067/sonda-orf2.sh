R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r067
. $R/arb/cand/hooks/lib.sh
ARNES_HASH_PRESUPUESTO_S=6; SECONDS=0; t0=${EPOCHREALTIME/./}; arnes_hash_arbol $R/w/enl; echo "rc=$? ms=$(( (${EPOCHREALTIME/./}-t0)/1000 ))"
