#!/usr/bin/env bash
# Re-verificación de la pasada de REQ-032: comandos LLANOS (sin ningún carácter que `_arnes_cmd_llano`
# rechace) en los que el último operando de cp/mv/install puede no ser el destino. Proyecto limpio por caso;
# la orden se ejecuta de verdad para ver si toca src/. Uso: bash 34-llano.sh <hooks candidata> <hooks v1.36.0>
set -u
HC="$1"; HV="$2"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
nuevo() {
  P="$T/p$1"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs/sub"
  printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  printf 'n\n' > "$P/docs/notas.md"; printf 'a\n' > "$P/src/a.ts"; printf 'S\n' > "$P/S"; printf 'src/a.ts\n' > "$P/docs/lista"
}
dec() { local out; out="$(cd "$T" && jq -cn --arg c "$P" --arg k "$2" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}}' | CLAUDE_PROJECT_DIR="$P" bash "$1/guard.sh" 2>/dev/null)"; case "$out" in *'"deny"'*) echo deny ;; *) echo allow ;; esac; }
n=0
caso() {   # <id> <comando>
  n=$((n + 1)); nuevo "$n"
  local dv dc a b ef
  dv="$(dec "$HV" "$2")"; dc="$(dec "$HC" "$2")"
  a="$(cat "$P/src/a.ts"; ls "$P/src")"; ( cd "$P" && timeout 5 bash -c "$2" ) </dev/null >/dev/null 2>&1; b="$(cat "$P/src/a.ts" 2>/dev/null; ls "$P/src")"
  ef='src/ intacto'; [ "$a" = "$b" ] || ef='src/ CAMBIA'
  printf '%-4s v1.36.0=%-5s candidata=%-5s %-12s | %s\n' "$1" "$dv" "$dc" "$ef" "$2"
}
echo "fecha: $(date -Iseconds)  candidata: $HC  v1.36.0: $HV"
caso L1 'echo src/a.ts | xargs cp S'
caso L2 'xargs -a docs/lista cp S'
caso L3 'cat docs/lista | xargs mv S'
caso L4 'cat docs/lista | xargs install S'
caso L5 'echo docs/notas.md | xargs cp S'
caso L6 'cp S docs/notas.md && cp S src/a.ts'
caso L7 'cp S src/a.ts;cp S docs/notas.md'
caso L8 'cp S docs/notas.md & cp S src/a.ts'
echo "casos: $n"
