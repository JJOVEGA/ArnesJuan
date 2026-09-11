S="$1"; R="$2"
serie() { local hk="$1" j t0; t0=${EPOCHREALTIME/./}; for ((j=0;j<8;j++)); do CLAUDE_PROJECT_DIR=$S/proj bash "$hk" < $S/ent.json >/dev/null 2>&1; done; echo $(( ${EPOCHREALTIME/./} - t0 )); }
A=999999999; B=999999999
for ((n=0;n<R;n++)); do
  d=$(serie "$S/hooks-3700/guard-completado.sh"); [ "$d" -lt "$A" ] && A=$d
  d=$(serie "$S/her133/hooks/guard-completado.sh"); [ "$d" -lt "$B" ] && B=$d
done
awk -v a=$A -v b=$B 'BEGIN{printf "inyectado-3700 min=%d us · v1.33.0 min=%d us · RAZON VERDADERA (suelo) = %.4f\n", a, b, a/b}'
