#!/usr/bin/env bash
# Comparacion del hook entero (guard.sh): stdout, rc y stderr, v1.35.0 frente al candidato.
B="$1"; C="$2"; R="$PWD/rh"; rm -rf "$R"; mkdir -p "$R"
bash ./prepara.sh "$R/p"; P="$R/p/proy"; chmod 755 "$P/sinpermiso"
cat > "$P/.arnes/config.json" <<'J'
{"agentes":{"agente_codigo":"desarrollador","conocidos":["desarrollador","qa-tester"]},"codigo_app":{"globs":["src/*","app/*","docs/?.md"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}
J
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
mapfile -d '' -t K < <(head -c 400000 esc-corpus.bin | tr '\0' '\n' | head -n 700 | tr '\n' '\0'; printf '%s\0' 'sed -i s/en-revision/completado/ requirements/REQ-001.md' 'echo completado > docs/../requirements/x.md' 'echo COMPLETADO > lnreq/x' 'echo x > requirements/a; echo completado' 'echo é > requirements/a # completado' 'echo x > src/a.ts # completado' 'git clean -fd' 'echo x > noexiste/n/requirements' 'cp a requirements/' 'tee requirements/a <<< completadoX')
n=0; d=0
for k in "${K[@]}"; do
  for ag in - desarrollador qa-tester; do
    if [ "$ag" = - ]; then j="$(jq -cn --arg c "$k" --arg w "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$w,tool_input:{command:$c}}')"
    else j="$(jq -cn --arg c "$k" --arg w "$P" --arg a "$ag" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$w,agent_id:"a1",agent_type:$a,tool_input:{command:$c}}')"; fi
    for h in "$B" "$C"; do
      o="$(cd "$P" && printf '%s' "$j" | CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/guard.sh" 2>"$R/err")"; rc=$?
      printf '%s\n%s\n' "rc=$rc out=$o" "err=$(cat "$R/err")" > "$R/r-$([ "$h" = "$B" ] && echo b || echo c)"
    done
    n=$((n+1))
    cmp -s "$R/r-b" "$R/r-c" || { d=$((d+1)); printf 'DIFERENCIA agente=%s cmd=%q\n' "$ag" "$k"; diff "$R/r-b" "$R/r-c" | head -4; }
  done
done
echo "casos=$n diferencias=$d"
