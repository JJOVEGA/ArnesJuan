#!/usr/bin/env bash
# vivos.sh <arbol> <n>: n cierres con `true` y n con `false` en una sesión propia; al final, lo que queda vivo en ella
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad; A="$1"; N="$2"
for g in true false; do P=$S/w-vivos/$A-$g; . $S/proy.sh $P "[\"$g\"]"; done
setsid bash -c 'echo $$ > "$1/sid"; for g in true false; do P=$1/$2-$g; : > $1/lentos-$2-$g; for ((i=0;i<$3;i++)); do t=${EPOCHREALTIME/./}; o=$(cd $P && CLAUDE_PROJECT_DIR=$P timeout 30 bash $4/guard.sh < $P/in 2>/dev/null); rc=$?; ms=$(( (${EPOCHREALTIME/./}-t)/1000 )); d=$(grep -o permissionDecision\" <<<"$o" | wc -l); case $ms:$g:$d in ?:true:0|??:true:0|???:true:0|????:true:0|?:false:1|??:false:1|???:false:1|????:false:1) ok=1;; *) ok=0;; esac; [ $ms -lt 3000 ] && [ $ok = 1 ] || echo "$g it=$i rc=$rc ms=$ms docs=$d" >> $1/lentos-$2-$g; done; done' _ $S/w-vivos $A $N $S/arb/$A/hooks &
w=$!; wait $w; sid=$(cat $S/w-vivos/sid); sleep 1
v=$(ps -eo pid=,sid=,etimes=,args= | awk -v s="$sid" '$2==s')
echo "$A: $N + $N cierres; sesión $sid; procesos que quedan en ella: $(printf '%s' "$v" | grep -c .) $(printf '%s' "$v" | head -3 | tr '\n' ';')"
for g in true false; do echo "  anomalías ($g): $(wc -l < $S/w-vivos/lentos-$A-$g) $(head -3 $S/w-vivos/lentos-$A-$g | tr "\n" ";")"; done
ls /tmp/arnes_gate.* 2>/dev/null | sed 's/^/  temporal: /'
for p in $(ps -eo pid=,sid= | awk -v s="$sid" '$2==s {print $1}'); do kill -KILL "$p"; done
