cd "$1"
for v in c b d; do
t=${EPOCHREALTIME/./}
exec {f}< <(exec git ls-files -z -t -c -o --exclude-standard); n=0
case $v in
c) while IFS= read -r -d "" -u $f e; do n=$((n+1)); done ;;
b) fin=$((SECONDS+30)); while r=$((fin-SECONDS)); ((r>0)) && IFS= read -r -d "" -t $r -u $f e; do n=$((n+1)); done ;;
d) fin=$((SECONDS+30)); while IFS= read -r -d "" -t 30 -u $f e; do n=$((n+1)); done ;;
esac; exec {f}<&-
echo $v $n $(( (${EPOCHREALTIME/./}-t)/1000 )) ms; done
