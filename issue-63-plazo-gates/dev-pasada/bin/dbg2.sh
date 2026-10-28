trap \[\ \"\$BASHPID\"\ \!=\ \"\$\$\"\ \]\;\ echo\ \"rc=\$\?\" EXIT
for ((i=0;i<6;i++)); do sleep 3 </dev/null >/dev/null 2>&1 & p=$!; kill $p; wait $p 2>/dev/null; done
