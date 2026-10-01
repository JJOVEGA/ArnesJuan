#!/usr/bin/env bash
# Sonda de QA para REQ-007 CA-54 (en el máximo declarado, el peor caso analizable responde en < 5 s) y
# CA-48 (i.2) (el trabajo por destino no depende del resto del comando). Base 9596e39 frente al candidato.
# Tres formas de destino: A = la del desarrollador (`echo x > f$i`, todos en el cwd), B = un directorio
# que no existe por destino (`echo x > d$i/f`), C = con `..` (`echo x > docs/../f$i`).
# Calentamiento de 1 corrida por árbol y forma (descartada), y 5 corridas alternadas base/candidato.
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-sec119/qa-lib.sh
N="${N:-5}"
for techo in 65536 131072; do
  P="$Q/ca54-$techo"; rm -rf "$P"; mkproj "$P"
  jq --argjson t "$techo" '.limites.bash_max_analisis = $t' <<< "$MANIF" > "$P/.arnes/config.json"
  for forma in A B C; do
    cmd=''; i=0
    while [ "${#cmd}" -lt $(( techo - 60 )) ]; do
      case $forma in A) cmd+="echo x > f$i; " ;; B) cmd+="echo x > d$i/f; " ;; C) cmd+="echo x > docs/../f$i; " ;; esac
      i=$((i+1))
    done
    printf '%s' "$cmd" | jq -Rs --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}}' > "$Q/ca54-$techo-$forma.json"
    for h in "$BASE" "$CAND"; do CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/guard.sh" < "$Q/ca54-$techo-$forma.json" >/dev/null 2>&1; done
    lb=''; lc=''
    for ((k = 1; k <= N; k++)); do
      for h in "$BASE" "$CAND"; do
        t0=${EPOCHREALTIME/./}; o="$(CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/guard.sh" < "$Q/ca54-$techo-$forma.json" 2>/dev/null)"; rc=$?; t1=${EPOCHREALTIME/./}
        case "$o" in *'"deny"'*) d=deny ;; *) d=allow ;; esac
        ms=$(( (t1 - t0) / 1000 ))
        if [ "$h" = "$BASE" ]; then lb+=" ${ms}($d,rc$rc)"; else lc+=" ${ms}($d,rc$rc)"; fi
      done
    done
    echo "techo=$techo forma=$forma bytes=${#cmd} destinos=$i | 9596e39 ms:$lb | candidato ms:$lc | carga=$(cut -d' ' -f1-3 /proc/loadavg)"
  done
done
