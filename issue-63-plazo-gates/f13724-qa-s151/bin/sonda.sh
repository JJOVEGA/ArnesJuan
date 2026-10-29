#!/usr/bin/env bash
# sonda.sh — QA de SEC-151 (P-137-AO) sobre la candidata 6dde1a1 (código f900a98), árbol congelado en $Q/arb.
# Un proyecto por caso, con gate `true` y verde de la herramienta; luego se le aplica la variante y se pide el cierre.
# Por caso: decisión, motivo (resumido), ms, y procesos vivos que nombren el proyecto 2 s después.
set -u
Q=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/qa-s151
A=$Q/arb; W=$Q/w; mkdir -p "$W"
proy() {   # <dir> -> proyecto con verde vigente
  local P="$1"; rm -rf "$P"; mkdir -p "$P/requirements" "$P/.arnes" "$P/src"
  jq -n '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:["true"]}' > "$P/.arnes/config.json"
  printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
  echo x > "$P/src/a.txt"; printf '.arnes/gates-veredicto.json\n' > "$P/.gitignore"
  ( cd "$P" && git init -q && git add -A && git -c user.name=qa -c user.email=qa@x commit -qm base )
}
entrada() { jq -cn --arg fp "$1/requirements/REQ-001.md" --arg cwd "$1" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}'; }
cierre() {  # <arbol> <proyecto> [env...] -> "decision | motivo | ms"
  local H="$1/hooks" P="$2"; shift 2; local t0 o ms d m
  t0=${EPOCHREALTIME/./}
  o=$(cd "$P" && env "$@" CLAUDE_PROJECT_DIR="$P" timeout 200 bash "$H/guard.sh" <<< "$(entrada "$P")" 2>/dev/null)
  ms=$(( (${EPOCHREALTIME/./} - t0) / 1000 ))
  if [ -z "$o" ]; then d=allow; m='-'; else d=$(jq -r '.hookSpecificOutput.permissionDecision' <<< "$o" 2>/dev/null); m=$(jq -r '.hookSpecificOutput.permissionDecisionReason' <<< "$o" 2>/dev/null)
    case "$m" in *'presupuesto propio de la huella'*) m="huella: ${m#*huella del arbol no se calculo dentro del presupuesto propio de la huella (}"; m="${m%%)*})";; *'no es del arbol actual'*) m=caducado;; *) m="${m:0:140}";; esac; fi
  docs=$(grep -o '"permissionDecision"' <<< "$o" | wc -l)
  echo "$d | $m | ${ms} ms | docs=$docs"
}
vivos() { sleep 2; local x; x=$(pgrep -af -- "$1" 2>/dev/null | grep -v pgrep); [ -z "$x" ] && echo "vivos: ninguno" || { echo "vivos: ${x:0:300}"; pkill -KILL -f -- "$1"; }; }
caso() {  # <id> <variante> [env...]
  local id="$1" v="$2"; shift 2; local P="$W/p-$id"
  proy "$P"; ( cd "$P" && bash "$A/tools/arnes-gates.sh" --quien qa-tester >/dev/null 2>&1 ); local hr=$?
  case "$v" in
    disperso) truncate -s 256G "$P/datos.bin" ;;
    fifo) mkfifo "$P/src/.gitignore" ;;
    fifoseguido) rm "$P/src/a.txt"; mkfifo "$P/src/a.txt" ;;
    ninguna) ;;
  esac
  echo "[$id $v ${*:-}] herramienta(verde previo) rc=$hr; cierre: $(cierre "$A" "$P" "$@"); $(vivos "$P")"
}
echo "# sonda SEC-151, $(date -Is), loadavg $(cut -d' ' -f1 /proc/loadavg)"
case "${1:-todo}" in
  todo|huella)
    caso S1 disperso
    caso S2 fifo
    caso S2b fifoseguido
    caso E1 disperso ARNES_HASH_PRESUPUESTO_S=999
    caso E2 ninguna ARNES_HASH_PRESUPUESTO_S=0
    caso E3 ninguna ARNES_HASH_PRESUPUESTO_S=-5
    caso L1 ninguna
    ;;
esac
case "${1:-todo}" in
  todo|herramienta)
    P="$W/p-T1"; proy "$P"; truncate -s 256G "$P/datos.bin"; t0=${EPOCHREALTIME/./}
    e=$( (cd "$P" && bash "$A/tools/arnes-gates.sh" --quien qa-tester) 2>&1 >/dev/null ); rc=$?
    echo "[T1 herramienta, árbol con disperso 256G] rc=$rc ms=$(( (${EPOCHREALTIME/./} - t0) / 1000 )) registro=$([ -e "$P/.arnes/gates-veredicto.json" ] && echo SI || echo no) err=<${e:0:220}>; $(vivos "$P")"
    P="$W/p-T2"; proy "$P"; mkfifo "$P/src/.gitignore"; t0=${EPOCHREALTIME/./}
    e=$( (cd "$P" && ARNES_HASH_PRESUPUESTO_S=999 bash "$A/tools/arnes-gates.sh" --quien qa-tester) 2>&1 >/dev/null ); rc=$?
    echo "[T2 herramienta, .gitignore FIFO, env 999] rc=$rc ms=$(( (${EPOCHREALTIME/./} - t0) / 1000 )) registro=$([ -e "$P/.arnes/gates-veredicto.json" ] && echo SI || echo no) err=<${e:0:220}>; $(vivos "$P")"
    ;;
esac
