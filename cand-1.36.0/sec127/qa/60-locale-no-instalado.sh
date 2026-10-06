#!/usr/bin/env bash
# Locale del entorno NO instalado (xx_XX.UTF-8): variables tras el atajo y stderr del hook, candidato frente a v1.35.0.
# (Corrido en línea por QA; este archivo transcribe los mismos comandos.)
Q=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127/qa; source $Q/sonda-qa.sh; prep_proy
for v in LC_ALL LANG; do for m in normal posix; do px=; [ $m = posix ] && px=POSIXLY_CORRECT=1
 r="$(env -i PATH="$PATH" $v=xx_XX.UTF-8 $px bash -c '. "$1/lib.sh" 2>/dev/null; a="${LC_ALL-<sd>}/${LANG-<sd>}"; arnes_estado_ausente "echo hola > r.md" completado; rc=$?; b="${LC_ALL-<sd>}/${LANG-<sd>}"; echo "rc=$rc antes=$a despues=$b"' _ $W/hooks 2>&1)"
 echo "$v $m: $r"; done; done
J="$(jq -cn --arg c "$PQ" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"echo hola > docs/n.md"}}')"
for a in cand v135; do for v in LC_ALL LANG; do e="$(cd $PQ; printf '%s' "$J" | env -i PATH="$PATH" $v=xx_XX.UTF-8 CLAUDE_PROJECT_DIR=$PQ bash ${H[$a]}/guard.sh 2>&1 >/dev/null | wc -l)"; o="$(cd $PQ; printf '%s' "$J" | env -i PATH="$PATH" $v=xx_XX.UTF-8 CLAUDE_PROJECT_DIR=$PQ bash ${H[$a]}/guard.sh 2>/dev/null)"; echo "hook $a $v=xx_XX: decision=$(dec "$o") lineas-stderr=$e"; done; done
