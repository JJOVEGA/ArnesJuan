#!/usr/bin/env bash
# P1 del registro previo (00-registro-previo-coste.md): la sonda de QA de r7 (sonda-coste-cr.sh) con los
# arboles candidato / 3bc7d3c / cd6afa6 y el JSON construido SIEMPRE por archivo. Una corrida por celda.
EV8=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8
declare -A H=([CAND]=/home/juan/dev/ArnesJuan-v1.35/hooks [FB3BC]=$EV8/arb/01b4a59/hooks [CD6]=$EV8/arb/cd6afa6/hooks)
CR=$'\r'
PRJ=$EV8/proj-coste; rm -rf "$PRJ"; mkdir -p "$PRJ/.arnes" "$PRJ/requirements" "$PRJ/src" "$PRJ/docs"
printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$PRJ/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$PRJ/PENDING_APPROVAL.md"; printf 'x\n' > "$PRJ/src/a.ts"
J=$EV8/coste.json; RF=$EV8/relleno.txt
# json <tipo> <N> <con_cr 0|1>: escribe $J con el relleno leido por archivo (--rawfile), nunca por argumentos.
json() {
  head -c "$2" /dev/zero | tr '\0' a > "$RF"
  local cr=''; [ "$3" = 1 ] && cr="$CR"
  case "$1" in
    fp)   jq -cn --rawfile r "$RF" --arg p "$PRJ" --arg cr "$cr" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$p,tool_input:{file_path:($p+"/src/"+$r+$cr),content:"x"}}' > "$J" ;;
    tool) jq -cn --rawfile r "$RF" --arg p "$PRJ" --arg cr "$cr" '{hook_event_name:"PreToolUse",tool_name:("Write"+$r+$cr),cwd:$p,tool_input:{file_path:($p+"/src/a.ts"),content:"x"}}' > "$J" ;;
    cwd)  jq -cn --rawfile r "$RF" --arg cr "$cr" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:("/tmp/"+$r+$cr),tool_input:{command:"echo x > src/a.ts"}}' > "$J" ;;
    bashfp) jq -cn --rawfile r "$RF" --arg p "$PRJ" --arg cr "$cr" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$p,tool_input:{command:"echo x > src/a.ts",file_path:("/tmp/"+$r+$cr)}}' > "$J" ;;
  esac
}
mide() {   # <arbol> -> T (ms), D
  local out t0 t1 rc
  t0=${EPOCHREALTIME/./}
  out="$(CLAUDE_PROJECT_DIR="$PRJ" timeout 120 bash "${H[$1]}/guard.sh" < "$J" 2>/dev/null)"; rc=$?
  t1=${EPOCHREALTIME/./}; T=$(( (t1 - t0) / 1000 ))
  case "$out" in *'"permissionDecision":"deny"'*) D=deny ;; *) D=allow ;; esac
  [ "$rc" -ne 124 ] || D=TIMEOUT120
}
celda() {   # <etiqueta> <tipo> <N> <cr>
  json "$2" "$3" "$4"
  local k ok; ok="$(jq -r '[.tool_name,.cwd,.tool_input.file_path] | map(select(. != null) | endswith("\r")) | any' "$J")"
  for k in CAND FB3BC CD6; do mide "$k"; printf '   %-14s | %7d | %-5s | %6d ms | %s\n' "$1" "$3" "$k" "$T" "$D"; done
  printf '     (json %d bytes; algun campo con CR final: %s)\n' "$(wc -c < "$J")" "$ok"
}
echo "== P1 coste del CR ($(date -Iseconds)); $(uname -r); bash $BASH_VERSION; $(jq --version); loadavg $(cut -d' ' -f1-3 /proc/loadavg) =="
echo "   sha256 lib.sh: CAND $(sha256sum < "${H[CAND]}/lib.sh" | cut -c1-16) · FB3BC $(sha256sum < "${H[FB3BC]}/lib.sh" | cut -c1-16) · CD6 $(sha256sum < "${H[CD6]}/lib.sh" | cut -c1-16)"
echo "   campo | N | arbol | ms | decision"
echo "-- Bloque 1 --"
for N in 20000 50000 100000; do
  celda fp fp "$N" 1; celda fp-sin-cr fp "$N" 0; celda tool tool "$N" 1; celda cwd cwd "$N" 1
done
echo "-- Bloque 2 (file_path con CR final) --"
for N in 200000 300000 400000 600000; do celda fp fp "$N" 1; done
echo "-- Bloque 3 (Bash de la coordinadora con tool_input.file_path grande) --"
celda bash+fp bashfp 100000 1; celda bash+fp bashfp 500000 1; celda bash+fp-sin-cr bashfp 500000 0
echo "== fin $(date -Iseconds); loadavg $(cut -d' ' -f1-3 /proc/loadavg) =="
rm -f "$J" "$RF"
