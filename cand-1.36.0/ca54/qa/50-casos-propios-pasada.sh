#!/usr/bin/env bash
# Re-verificacion de la pasada correctiva de QA-007-01 (dee5932). Casos PROPIOS de QA en el maximo, mismo
# procedimiento que 20-casos-propios-tiempo.sh (y que S1): biblioteca qa/s1/qa-lib.sh sin cambios, techo
# 131072 en el manifiesto, guard.sh, 1 calentamiento descartado por arbol y caso, 5 corridas alternadas
# v1.35.0/candidato, decision y rc por corrida. Casos (formas A, B, C de S1 salvo que se diga):
#   M, N, MR   = los de 20- (QA-007-01): «: completado; », «: ñ; », M con el ultimo destino en requirements/
#   MN         = «: completado ñ; » (las dos cosas a la vez)
#   ND         = multibyte DENTRO de cada destino: A «echo x > fñ$i; », B «echo x > dñ$i/f; »
#   MD         = el DESARROLLADOR, con «: completado; echo x > src/a.ts; » delante: el primer destino es codigo,
#                el bucle de guard-codigo para en el y no juzga los demas (la pasada reutiliza ese juicio)
#   M0         = M en un proyecto SIN globs de codigo (codigo_app.globs = []): guard-codigo no recorre nada
source /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa/s1/qa-lib.sh
N="${N:-5}"; techo=131072
P="$Q/pasada-$techo"; rm -rf "$P"; mkproj "$P"
jq --argjson t "$techo" '.limites.bash_max_analisis = $t' <<< "$MANIF" > "$P/.arnes/config.json"
printf '# REQ-900\nEstado: en-revisión\nQA: pendiente\nSeguridad: pendiente\n' > "$P/requirements/REQ-900.md"
P0="$Q/pasada0-$techo"; rm -rf "$P0"; mkproj "$P0"
jq --argjson t "$techo" '.limites.bash_max_analisis = $t | .codigo_app.globs = []' <<< "$MANIF" > "$P0/.arnes/config.json"
for cf in M:A M:B M:C N:A N:B N:C MR:A MR:B MR:C MN:A MN:B MN:C ND:A ND:B MD:A MD:B MD:C M0:A M0:B M0:C; do
  caso=${cf%%:*}; forma=${cf#*:}; pr="$P"; ag='-'
  case $caso in M|MR|M0) cmd=': completado; ' ;; N) cmd=': ñ; ' ;; MN) cmd=': completado ñ; ' ;; ND) cmd='' ;;
                MD) cmd=': completado; echo x > src/a.ts; '; ag=desarrollador ;; esac
  [ "$caso" = M0 ] && pr="$P0"
  i=0; fin=''; [ "$caso" = MR ] && fin='echo x > requirements/REQ-900.md'
  while [ "${#cmd}" -lt $(( techo - 60 - ${#fin} )) ]; do
    if [ "$caso" = ND ]; then case $forma in A) cmd+="echo x > fñ$i; " ;; B) cmd+="echo x > dñ$i/f; " ;; esac
    else case $forma in A) cmd+="echo x > f$i; " ;; B) cmd+="echo x > d$i/f; " ;; C) cmd+="echo x > docs/../f$i; " ;; esac; fi
    i=$((i+1))
  done
  cmd+="$fin"; [ -z "$fin" ] || i=$((i+1))
  js="$Q/pasada-$caso-$forma.json"
  printf '%s' "$cmd" | jq -Rs --arg c "$pr" --arg a "$ag" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}} + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)' > "$js"
  bytes=$(LC_ALL=C; printf '%s' "$cmd" | wc -c)
  for h in "$BASE" "$CAND"; do CLAUDE_PROJECT_DIR="$pr" timeout 60 bash "$h/guard.sh" < "$js" >/dev/null 2>&1; done
  lb=''; lc=''; max=0
  for ((k = 1; k <= N; k++)); do
    for h in "$BASE" "$CAND"; do
      t0=${EPOCHREALTIME/./}; o="$(CLAUDE_PROJECT_DIR="$pr" timeout 60 bash "$h/guard.sh" < "$js" 2>/dev/null)"; rc=$?; t1=${EPOCHREALTIME/./}
      case "$o" in *'"deny"'*) d=deny ;; *) d=allow ;; esac
      ms=$(( (t1 - t0) / 1000 ))
      if [ "$h" = "$BASE" ]; then lb+=" ${ms}($d,rc$rc)"; else lc+=" ${ms}($d,rc$rc)"; (( ms > max )) && max=$ms; fi
    done
  done
  echo "caso=$caso forma=$forma agente=$ag caracteres=${#cmd} bytes=$bytes destinos=$i | v1.35.0 ms:$lb | candidato ms:$lc | max-candidato=$max $([ $max -ge 5000 ] && echo '>=5000 FAIL' || echo '<5000') | carga=$(cut -d' ' -f1-3 /proc/loadavg)"
done
