#!/usr/bin/env bash
# Medicion del auditor (R-052): profundidad de destino a nivel de hook, con pila normal y reducida.
set -u
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
W=$(mktemp -d "$S/w-XXXX"); trap 'rm -rf "$W"' EXIT
P="$W/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
printf '%s' '{"agentes":{"agente_codigo":"desarrollador"},"codigo_app":{"globs":["src/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; printf 'x\n' > "$P/src/a.ts"
printf '# REQ-900\nEstado: en-revision\nSensible a seguridad: si\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n' > "$P/requirements/REQ-900.md"
uno() {   # <etiqueta> <pila KiB> <comando> [agente]
  local js r o rc d
  js="$(printf '%s' "$3" | jq -cRs --arg c "$P" --arg a "${4:--}" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}} + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)')"
  for r in v1.35.0 82ceb63 dee5932; do
    o="$(printf '%s' "$js" | (ulimit -s "$2"; CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$S/t/$r/hooks/guard.sh" 2>/dev/null))"; rc=$?
    case "$o" in *'"deny"'*) d=deny ;; '') d=sin-salida ;; *) d=allow ;; esac
    printf '%-46s pila=%-5s %-8s rc=%-3s decision=%s\n' "$1" "$2" "$r" "$rc" "$d"
  done
}
for pila in 8192 1024 256; do
  for n in 300 2040; do
    pr="docs/../$(printf 'a/%.0s' $(seq 1 $n))f"
    uno "n=$n (${#pr} c) + src/a.ts (coordinadora)" $pila "echo x > $pr; echo x > src/a.ts"
    uno "n=$n + cierre de REQ (desarrollador)" $pila "echo x > $pr; sed -i 's/en-revision/completado/' requirements/REQ-900.md" desarrollador
  done
  p2="docs//$(printf 'a//%.0s' $(seq 1 1360))f"
  uno "dobles barras 1360 (${#p2} c) + src/a.ts" $pila "echo x > $p2; echo x > src/a.ts"
done
echo "bash $BASH_VERSION; ulimit -s por defecto $(ulimit -s)"
