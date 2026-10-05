#!/usr/bin/env bash
# Casos PROPIOS de QA en el maximo declarado (REQ-007 CA-54, «No acredita»: «QA puede romper la propiedad con
# casos propios en el maximo, y uno que tarde 5 s o mas es hallazgo contra este criterio»). Mismo procedimiento
# que S1 (copia de QA, qa/s1/qa-lib.sh, sin cambiarla): techo 131072 en el manifiesto, una corrida de
# calentamiento descartada por arbol y caso, cinco alternadas v1.35.0/candidato, a nivel de hook (guard.sh),
# coordinadora (sin agent_id), decision y rc por corrida. Las entradas son las de S1 (formas A, B y C) con un
# PREFIJO que cambia el camino del candidato, y el relleno se ajusta para que el comando quede en el mismo
# rango de bytes que S1 (techo - 60 .. techo):
#   M  = «: completado; »  -> el comando menciona el estado terminal: el atajo de guard-completado no aplica
#   N  = «: ñ; »           -> un byte no ASCII: ni el atajo ni la fase de tokens en locale C aplican
#   MR = M y el ULTIMO destino en requirements/REQ-900.md -> deny de guard-completado al final del recorrido
source /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa/s1/qa-lib.sh
N="${N:-5}"; techo=131072
P="$Q/propios-$techo"; rm -rf "$P"; mkproj "$P"
jq --argjson t "$techo" '.limites.bash_max_analisis = $t' <<< "$MANIF" > "$P/.arnes/config.json"
printf '# REQ-900\nEstado: en-revisión\nQA: pendiente\nSeguridad: pendiente\n' > "$P/requirements/REQ-900.md"
for caso in M N MR; do
  for forma in A B C; do
    case $caso in M|MR) cmd=': completado; ' ;; N) cmd=': ñ; ' ;; esac
    i=0; fin=''; [ "$caso" = MR ] && fin='echo x > requirements/REQ-900.md'
    while [ "${#cmd}" -lt $(( techo - 60 - ${#fin} )) ]; do
      case $forma in A) cmd+="echo x > f$i; " ;; B) cmd+="echo x > d$i/f; " ;; C) cmd+="echo x > docs/../f$i; " ;; esac
      i=$((i+1))
    done
    cmd+="$fin"; [ -z "$fin" ] || i=$((i+1))
    js="$Q/propio-$caso-$forma.json"
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
    echo "caso=$caso forma=$forma caracteres=${#cmd} bytes=$bytes destinos=$i | v1.35.0 ms:$lb | candidato ms:$lc | max-candidato=$max $([ $max -ge 5000 ] && echo '>=5000 FAIL' || echo '<5000') | carga=$(cut -d' ' -f1-3 /proc/loadavg)"
  done
done
