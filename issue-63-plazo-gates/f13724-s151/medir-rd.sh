cd "$1"; l="$(git ls-files)"
for v in m r m r; do t=${EPOCHREALTIME/./}
if [ $v = m ]; then mapfile -t hs < <(git hash-object --no-filters --stdin-paths <<< "$l"); n=${#hs[@]}
else exec {f}< <(exec git hash-object --no-filters --stdin-paths <<< "$l"); IFS= read -r -d '' -t 30 -u $f s; exec {f}<&-; mapfile -t hs <<< "${s%$'\n'}"; n=${#hs[@]}; fi
echo $v $n $(( (${EPOCHREALTIME/./}-t)/1000 )) ms; done
