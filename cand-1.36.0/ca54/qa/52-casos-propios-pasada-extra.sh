#!/usr/bin/env bash
# Re-verificacion de la pasada correctiva de QA-007-01: mas casos PROPIOS en el maximo, mismo procedimiento que
# 50- (y que S1). Formas que la pasada declara NO medidas o que caen fuera de sus memorias:
#   B2   = «: completado; » + «echo x > d$i/e/f; » (DOS niveles inexistentes: fuera de `_arnes_lf_memo`)
#   B2S  = B2 sin mencion (el atajo aplica; guard-codigo sigue juzgando todos)
#   DEEP = «: completado; » + destinos «docs/../» + 200 niveles «a/» + «f$i» (la lectura lexica por directorio, en
#          recursion de 200 niveles; y los niveles no existen)
#   DEEPX= un unico destino de ~4 000 bytes: «docs/../» + 1 990 niveles «a/» + «f», relleno con «: x; » (la
#          recursion mas profunda que cabe bajo ARNES_ID_MAX), con mencion
source /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa/s1/qa-lib.sh
N="${N:-5}"; techo=131072
P="$Q/extra-$techo"; rm -rf "$P"; mkproj "$P"
jq --argjson t "$techo" '.limites.bash_max_analisis = $t' <<< "$MANIF" > "$P/.arnes/config.json"
a200="$(printf 'a/%.0s' $(seq 1 200))"; a1990="$(printf 'a/%.0s' $(seq 1 1990))"
for caso in B2 B2S DEEP DEEPX; do
  case $caso in B2S) cmd='' ;; DEEPX) cmd=": completado; echo x > docs/../${a1990}f; " ;; *) cmd=': completado; ' ;; esac
  i=0
  while [ "${#cmd}" -lt $(( techo - 60 )) ]; do
    case $caso in B2|B2S) cmd+="echo x > d$i/e/f; " ;; DEEP) cmd+="echo x > docs/../${a200}f$i; " ;; DEEPX) cmd+=': x; ' ;; esac
    case $caso in DEEPX) ;; *) i=$((i+1)) ;; esac
  done
  [ "$caso" = DEEPX ] && i=1
  js="$Q/extra-$caso.json"
  printf '%s' "$cmd" | jq -Rs --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}}' > "$js"
  bytes=$(LC_ALL=C; printf '%s' "$cmd" | wc -c)
  for h in "$BASE" "$CAND"; do CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/guard.sh" < "$js" >/dev/null 2>&1; done
  lb=''; lc=''; max=0
  for ((k = 1; k <= N; k++)); do
    for h in "$BASE" "$CAND"; do
      t0=${EPOCHREALTIME/./}; o="$(CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/guard.sh" < "$js" 2>/dev/null)"; rc=$?; t1=${EPOCHREALTIME/./}
      case "$o" in *'"deny"'*) d=deny ;; *) d=allow ;; esac
      ms=$(( (t1 - t0) / 1000 ))
      if [ "$h" = "$BASE" ]; then lb+=" ${ms}($d,rc$rc)"; else lc+=" ${ms}($d,rc$rc)"; (( ms > max )) && max=$ms; fi
    done
  done
  echo "caso=$caso caracteres=${#cmd} bytes=$bytes destinos=$i | v1.35.0 ms:$lb | candidato ms:$lc | max-candidato=$max $([ $max -ge 5000 ] && echo '>=5000 FAIL' || echo '<5000') | carga=$(cut -d' ' -f1-3 /proc/loadavg)"
done
