#!/usr/bin/env bash
source /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127/qa/sonda-qa.sh; prep_proy; ln -sfn src/a.ts "$PQ/5"
dif=0; n=0
for ti in '{command:5}' '{command:true}' '{command:false}' '{command:[]}' '{command:["ls"]}' '{command:{}}' '{command:null}' '{}' '{command:5,file_path:"src/a.ts"}' '{command:"ls",file_path:5}' '{command:"echo x > src/a.ts",file_path:5}'; do
  for ag in - desarrollador arnes-juan:desarrollador qa-tester intruso SINTIPO; do
    j="$(jq -cn --arg c "$PQ" --arg a "$ag" "{hook_event_name:\"PreToolUse\",tool_name:\"Bash\",cwd:\$c,tool_input:$ti} + (if \$a == \"-\" then {} elif \$a == \"SINTIPO\" then {agent_id:\"a1\"} else {agent_id:\"a1\",agent_type:\$a} end)")"
    for s in guard.sh guard-codigo.sh guard-completado.sh guard-git.sh; do
      c="$(pr cand $s "$j")"; o="$(pr 413c $s "$j")"; n=$((n+1))
      if [ "$c" = "$o" ]; then m=IGUAL; else m=DISTINTO; dif=$((dif+1)); fi
      printf '%-8s %-38s ag=%-26s %-20s cand=%s\n' "$m" "$ti" "$ag" "$s" "${c:0:90}"
      [ $m = IGUAL ] || printf '         413c6bd=%s\n' "${o:0:90}"
    done
  done
done
echo "TOTAL $n casos; DISTINTOS frente a 413c6bd: $dif"
