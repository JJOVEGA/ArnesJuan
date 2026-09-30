# Coste de la busqueda literal del old_string: disco con una racha de N 'a' en la cabecera; old = N/2 'a' + '\nEstado: en-revision' (literal, al final de la racha).
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2/lib-sonda.sh
for n in 8000 16000 32000; do
  A=$(head -c $n /dev/zero | tr '\0' a); H=$(head -c $((n/2)) /dev/zero | tr '\0' a)
  DOC="# REQ-900 $A"$'\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n\n## x\n'
  printf '%s' "$H"$'\nEstado: en-revisión' > $E2/.old; printf '%s' "$H"$'\nEstado: completado' > $E2/.new
  jq -cn --rawfile o $E2/.old --rawfile n $E2/.new --arg f "$F" --arg p "$P" '{tool_name:"Edit",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,old_string:$o,new_string:$n}}' > $E2/.jb
  for h in "$CAND" "$BASE"; do printf '%s' "$DOC" > $F; t0=$(date +%s.%N); out=$(CLAUDE_PROJECT_DIR=$P timeout 120 bash $h/guard.sh < $E2/.jb 2>/dev/null); rc=$?; t1=$(date +%s.%N)
    d=allow; [ -n "$out" ] && d=$(jq -r .hookSpecificOutput.permissionDecision <<< "$out")
    echo "racha=$n old=$((n/2+20))B $(basename $(dirname $h)) dec=$d rc=$rc t=$(awk -v a=$t0 -v b=$t1 'BEGIN{printf "%.2f",b-a}')s"; done
done
