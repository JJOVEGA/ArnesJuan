#!/usr/bin/env bash
# QA-007-06: otras causas de `read` fallido, y el entorno heredado.
source /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127/qa/sonda-qa.sh; prep_proy
JOK="$(jq -cn --arg c "$PQ" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"ls"}}')"
JSRC="$(jq -cn --arg c "$PQ" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:"src/a.ts",content:"x"}}')"
# corre <arbol> <script> <redireccion> [VAR=val ...]  (redireccion: texto evaluado)
corre() { local a=$1 s=$2 red=$3 out rc; shift 3
  out="$(cd "$PQ"; unset LC_ALL POSIXLY_CORRECT ARNES_INPUT; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$PQ"; for v in "$@"; do export "$v"; done
         eval "bash \"\${H[$a]}/$s\" $red" 2>"$S/err.txt")"; rc=$?
  printf '%s rc=%s err=<%s>' "$(dec "$out")" "$rc" "$(head -c 100 "$S/err.txt" | tr '\n' ' ')"; }
printf '%s' "$JOK" > "$S/jok.json"; : > "$S/vacio"
mkfifo "$S/fifo" 2>/dev/null
for caso in \
  "cerrada|<&-" \
  "directorio|< '$PQ/dirent'" \
  "solo-escritura /dev/null|0>/dev/null" \
  "solo-escritura archivo|0>'$S/wo.txt'" \
  "/dev/full|< /dev/full" \
  "/proc/self/mem (EIO)|< /proc/self/mem" \
  "vacio|< '$S/vacio'" \
  "JSON valido (control)|< '$S/jok.json'" \
  ; do
  nom="${caso%%|*}"; red="${caso#*|}"
  for a in cand 413c v135; do for s in guard.sh guard-codigo.sh guard-completado.sh guard-git.sh; do
    printf '%-26s %-5s %-20s %s\n' "$nom" $a $s "$(corre $a $s "$red")"; done; done
done
echo "##### ARNES_INPUT heredado del entorno, entrada estandar cerrada (el heredado escribiria en src/ siendo coordinadora)"
for a in cand 413c v135; do for s in guard.sh guard-codigo.sh; do
  printf 'heredado-Write-src cerrada  %-5s %-16s %s\n' $a $s "$(corre $a $s '<&-' "ARNES_INPUT=$JSRC")"
  printf 'heredado-Bash-ls  cerrada   %-5s %-16s %s\n' $a $s "$(corre $a $s '<&-' "ARNES_INPUT=$JOK")"
  printf 'heredado-Write-src dir      %-5s %-16s %s\n' $a $s "$(corre $a $s "< '$PQ/dirent'" "ARNES_INPUT=$JSRC")"
  printf 'heredado-Bash-ls legible    %-5s %-16s %s\n' $a $s "$(corre $a $s "< '$S/jok.json'" "ARNES_INPUT=$JSRC")"
done; done
