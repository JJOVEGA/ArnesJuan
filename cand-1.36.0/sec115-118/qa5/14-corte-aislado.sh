# coste aislado de arnes_corta_gate sobre un árbol ancho de N sleeps (fuera del hook): se carga la función de lib.sh
eval "$(sed -n '/^arnes_corta_gate() {/,/^}/p' /home/juan/dev/ArnesJuan-v1.36/hooks/lib.sh)"
N=$1; M=7$$
( for i in $(seq $N); do sleep 580.$M & done; wait ) & g=$!
until [ "$(pgrep -fc "580\.$M")" -ge "$N" ]; do sleep 0.2; done
t0=$EPOCHREALTIME; arnes_corta_gate $g; t1=$EPOCHREALTIME
sleep 1; v=$(pgrep -fc "580\.$M"); pkill -9 -f "580\.$M"
echo "N=$N corta_gate=$(echo "$t1 - $t0" | bc) s vivos=$v"
