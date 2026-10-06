#!/usr/bin/env bash
# SEC-127 a nivel de hook: el cierre por Bash con estado terminal no ASCII / ASCII con I, en en_US, tr_TR (UTF-8 e
# ISO-8859-9) y C.UTF-8, normal y POSIX, candidato frente a v1.35.0 (CA-69 punto 3: ninguna decisión se mueve).
source /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127/qa/sonda-qa.sh
L=$LOCQ; n=0; d=0
for est in terminé listo; do
  T=$S/lk-$est; rm -rf $T; mkdir -p $T/.arnes $T/requirements
  jq --arg e "$est" '.estados.completado = $e' $W/../ArnesJuan-evidencia/cand-1.36.0/sec120/proyecto/.arnes/config.json > $T/.arnes/config.json 2>/dev/null || jq --arg e "$est" '.estados.completado = $e' /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120/proyecto/.arnes/config.json > $T/.arnes/config.json
  printf '## Pendientes\n\n## Resueltas\n' > $T/PENDING_APPROVAL.md; printf '# REQ-900\nEstado: en-revision\n' > $T/requirements/REQ-900.md
  case $est in terminé) cmds=("sed -i 's/en-revision/TERMINÉ/' requirements/REQ-900.md" "sed -i 's/en-revision/terminé/' requirements/REQ-900.md" "sed -i 's/en-revision/TERMINE/' requirements/REQ-900.md");;
               listo)   cmds=("sed -i 's/en-revision/LISTO/' requirements/REQ-900.md" "sed -i 's/en-revision/LİSTO/' requirements/REQ-900.md" "sed -i 's/en-revision/lısto/' requirements/REQ-900.md");; esac
  for loc in C.UTF-8 en_US.UTF-8 tr_TR.UTF-8 tr_TR.ISO-8859-9; do for modo in normal posix; do for ag in - desarrollador; do for k in "${cmds[@]}"; do
    j="$(jq -cn --arg c "$T" --arg a "$ag" --arg k "$k" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}} + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)')"
    for s in guard.sh guard-completado.sh; do
      r=""; for a in cand v135; do
        px=; [ $modo = posix ] && px=POSIXLY_CORRECT=1
        out="$(cd $T; printf '%s' "$j" | env -i PATH="$PATH" HOME="$HOME" LOCPATH=$L LANG=$loc CLAUDE_PROJECT_DIR=$T $px bash ${H[$a]}/$s 2>/dev/null)"
        r+="$a=$(dec "$out" | cut -c1-40) "; eval "o_$a=\$(dec \"\$out\" | cut -c1-6)"; done
      n=$((n+1)); m=IGUAL; [ "$o_cand" = "$o_v135" ] || { m=DISTINTO; d=$((d+1)); }
      printf '%-8s %-7s %-16s %-6s %-13s %-20s %-48s %s\n' $m $est $loc $modo "${ag/#-/coord}" $s "$k" "$r"
    done; done; done; done; done
done
echo "TOTAL $n; DISTINTOS cand/v1.35.0: $d"
