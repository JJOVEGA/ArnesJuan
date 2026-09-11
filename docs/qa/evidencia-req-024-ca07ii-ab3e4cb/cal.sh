S="$1"; R="$2"
serie() { local hk="$1" j t0; t0=${EPOCHREALTIME/./}; for ((j=0;j<8;j++)); do CLAUDE_PROJECT_DIR=$S/proj bash "$hk" < $S/ent.json >/dev/null 2>&1; done; echo $(( ${EPOCHREALTIME/./} - t0 )); }
declare -A MN
for h in her133/hooks candidato hooks-1500 hooks-3400 hooks-5000; do MN[$h]=999999999; done
for ((n=0;n<R;n++)); do
  for h in her133/hooks candidato hooks-1500 hooks-3400 hooks-5000; do
    if [ "$h" = candidato ]; then p=/home/juan/dev/ArnesJuan-1.34-reparaciones/hooks/guard-completado.sh; else p=$S/$h/guard-completado.sh; fi
    d=$(serie "$p"); [ "$d" -lt "${MN[$h]}" ] && MN[$h]=$d
  done
done
for h in her133/hooks candidato hooks-1500 hooks-3400 hooks-5000; do echo "$h ${MN[$h]}"; done
