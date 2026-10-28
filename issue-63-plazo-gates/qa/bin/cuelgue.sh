#!/usr/bin/env bash
# cuelgue.sh <hooks> <n> <outdir> — cierres legítimos (gate `true`) hasta el primer cuelgue (> 8 s); entonces foto de procesos y espera hasta 480 s.
set -u
H="$1"; N="$2"; O="$3"; mkdir -p "$O"
P=$(mktemp -d $O/p.XXXXXX); mkdir -p "$P/requirements" "$P/.arnes"
jq -n '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:["true"]}' > "$P/.arnes/config.json"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
jq -n --arg fp "$P/requirements/REQ-001.md" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$P/in"
foto() { for p in $(pgrep -u "$(id -u)" .); do [ "$(readlink /proc/$p/cwd 2>/dev/null)" = "$P" ] && { ps -o pid=,ppid=,pgid=,stat=,etimes=,wchan:20=,args= -p $p; ls -l /proc/$p/fd 2>/dev/null | awk 'NR>1{print "      fd",$9,$10,$11}'; }; done; }
ok=0; otros=0
for ((i=0;i<N;i++)); do
  t0=${EPOCHREALTIME/./}
  ( cd "$P" && CLAUDE_PROJECT_DIR="$P" exec timeout 480 bash "$H/guard.sh" < "$P/in" > "$O/out.cur" 2>"$O/err.cur"; echo $? > "$O/rc.cur" ) &
  w=$!; snap=no
  while kill -0 $w 2>/dev/null; do
    if [ $snap = no ] && [ $(( (${EPOCHREALTIME/./}-t0)/1000000 )) -ge 8 ]; then snap=si; echo "== it=$i cuelgue: foto a los 8 s" ; foto; fi
    sleep 0.05
  done
  ms=$(( (${EPOCHREALTIME/./}-t0)/1000 )); rc=$(cat "$O/rc.cur")
  if [ ! -s "$O/out.cur" ] && [ "$rc" = 0 ] && [ $snap = no ]; then ok=$((ok+1)); else otros=$((otros+1)); echo "it=$i rc=$rc ms=$ms out=$(cut -c1-160 "$O/out.cur") err=$(head -c 300 "$O/err.cur")"; cp "$O/out.cur" "$O/out.$i"; [ $snap = si ] && break; fi
done
echo "allow=$ok otros=$otros"
for p in $(pgrep -u "$(id -u)" .); do [ "$(readlink /proc/$p/cwd 2>/dev/null)" = "$P" ] && kill -KILL "$p" 2>/dev/null; done
