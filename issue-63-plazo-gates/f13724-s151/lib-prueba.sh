. /home/juan/dev/ArnesJuan-1.36.3/hooks/lib.sh
ARNES_HASH_PRESUPUESTO_S=3
for d in "$@"; do t=${EPOCHREALTIME/./}; arnes_hash_arbol "$d"; echo "rc=$? m=$ARNES_HASH_MOTIVO $(( (${EPOCHREALTIME/./}-t)/1000 )) ms"; done
sleep 0.3; pgrep -af 'hash-object|ls-files' || echo "sin git vivo"
