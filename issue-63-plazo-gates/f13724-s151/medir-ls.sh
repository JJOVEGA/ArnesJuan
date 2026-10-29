cd "$1"
for v in a b a b; do
t=${EPOCHREALTIME/./}
if [ $v = a ]; then n=0; while IFS= read -r -d "" e; do n=$((n+1)); done < <(git ls-files -z -t -c -o --exclude-standard)
else exec {f}< <(exec git ls-files -z -t -c -o --exclude-standard); n=0; fin=$((SECONDS+30)); while r=$((fin-SECONDS)); ((r>0)) && IFS= read -r -d "" -t $r -u $f e; do n=$((n+1)); done; exec {f}<&-; fi
echo $v $n $(( (${EPOCHREALTIME/./}-t)/1000 )) ms; done
