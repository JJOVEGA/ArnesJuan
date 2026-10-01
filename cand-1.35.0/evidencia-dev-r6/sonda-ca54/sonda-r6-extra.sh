#!/usr/bin/env bash
# Mediciones de REGISTRO que pide la sexta autorización, además de la sonda fijada (sonda-ca54-qa.sh):
#  (1) la forma original de la evidencia de CA-54 —expansión repetida más una escritura al final—, con
#      131 072 bytes de techo: `cat <<EOF` + una línea de `$(date)` repetido + `EOF` + `echo x > src/a.ts`
#      (la de la sección 25 del banco, al tamaño del máximo), 1 calentamiento y 5 corridas alternadas;
#  (2) la variante de CONTROL de cada forma A, B y C de la sonda: la misma lista de destinos y, al final,
#      `echo x > src/a.ts` desde la coordinadora, que tiene que salir DENY (no se omiten destinos);
#      1 calentamiento y 5 corridas alternadas, como la sonda.
# Los mismos tres árboles, el mismo proyecto de la sonda (qa-lib.sh) y el techo 131 072.
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-dev-r6/sonda-ca54/qa-lib.sh
N="${N:-5}"; techo=131072
P="$Q/ca54x-$techo"; rm -rf "$P"; mkproj "$P"
jq --argjson t "$techo" '.limites.bash_max_analisis = $t' <<< "$MANIF" > "$P/.arnes/config.json"
mide() {   # <etiqueta> <json>
  local et="$1" js="$2" h t0 t1 o rc d ms lb='' l43='' lc=''
  for h in "$BASE" "$T43" "$CAND"; do CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/guard.sh" < "$js" >/dev/null 2>&1; done
  for ((k = 1; k <= N; k++)); do
    for h in "$BASE" "$T43" "$CAND"; do
      t0=${EPOCHREALTIME/./}; o="$(CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/guard.sh" < "$js" 2>/dev/null)"; rc=$?; t1=${EPOCHREALTIME/./}
      case "$o" in *'"deny"'*) d=deny ;; *) d=allow ;; esac
      ms=$(( (t1 - t0) / 1000 ))
      if [ "$h" = "$BASE" ]; then lb+=" ${ms}($d,rc$rc)"; elif [ "$h" = "$T43" ]; then l43+=" ${ms}($d,rc$rc)"; else lc+=" ${ms}($d,rc$rc)"; fi
    done
  done
  echo "$et | 9596e39 ms:$lb | 43b948a ms:$l43 | candidato ms:$lc | carga=$(cut -d' ' -f1-3 /proc/loadavg)"
}
# (1) forma original
u='$(date)'; cuerpo=''; while [ $(( ${#cuerpo} + ${#u} )) -le 131040 ]; do cuerpo+="$u"; done
cmd="$(printf 'cat <<EOF\n%s\nEOF\necho x > src/a.ts' "$cuerpo")"
printf '%s' "$cmd" | jq -Rs --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}}' > "$Q/ca54x-original.json"
mide "original techo=$techo bytes=${#cmd} (cuerpo ${#cuerpo} bytes de \$(date), 1 destino: src/a.ts)" "$Q/ca54x-original.json"
# (2) control por forma
for forma in A B C; do
  cmd=''; i=0
  while [ "${#cmd}" -lt $(( techo - 60 )) ]; do
    case $forma in A) cmd+="echo x > f$i; " ;; B) cmd+="echo x > d$i/f; " ;; C) cmd+="echo x > docs/../f$i; " ;; esac
    i=$((i+1))
  done
  cmd+='echo x > src/a.ts'
  printf '%s' "$cmd" | jq -Rs --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}}' > "$Q/ca54x-control-$forma.json"
  mide "control techo=$techo forma=$forma bytes=${#cmd} destinos=$((i+1)) (el último, src/a.ts)" "$Q/ca54x-control-$forma.json"
done
# el motivo de la candidata en cada control: cita src/a.ts
for f in original control-A control-B control-C; do
  m="$(CLAUDE_PROJECT_DIR="$P" bash "$CAND/guard.sh" < "$Q/ca54x-$f.json" 2>/dev/null | jq -r '.hookSpecificOutput.permissionDecisionReason // empty')"
  echo "motivo candidato [$f]: ${m:0:160}"
done
