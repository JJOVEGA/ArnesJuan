#!/usr/bin/env bash
# Complemento de 70-: el destino profundo PRIMERO (antes de la escritura que se deniega), por guard.sh y por cada
# guardian solo; y el umbral fino de niveles. Mismo proyecto que 70-.
set -u
B=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/arboles/v1.35.0/hooks
C=/home/juan/dev/ArnesJuan-v1.36/hooks
W=$(mktemp -d /tmp/qa-segv-XXXX); trap 'rm -rf "$W"' EXIT
P="$W/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
printf '%s' '{"agentes":{"agente_codigo":"desarrollador"},"codigo_app":{"globs":["src/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; printf 'x\n' > "$P/src/a.ts"
printf '# REQ-900\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n' > "$P/requirements/REQ-900.md"
uno() {   # <etiqueta> <guardian> <comando> [agente]
  local js h o rc d
  js="$(printf '%s' "$3" | jq -cRs --arg c "$P" --arg a "${4:--}" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}} + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)')"
  for h in "$B" "$C"; do
    o="$(printf '%s' "$js" | CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/$2" 2>/dev/null)"; rc=$?
    case "$o" in *'"deny"'*) d=deny ;; '') d=sin-salida ;; *) d=allow ;; esac
    printf '%-44s %-20s %-9s rc=%-3s decision=%s\n' "$1" "$2" "$([ "$h" = "$B" ] && echo v1.35.0 || echo candidato)" "$rc" "$d"
  done
}
p1990="docs/../$(printf 'a/%.0s' $(seq 1 1990))f"
for g in guard.sh guard-codigo.sh guard-completado.sh; do
  uno "profundo primero + src/a.ts (coordinadora)" $g "echo x > $p1990; echo x > src/a.ts"
  uno "profundo primero + cierre de REQ (coord.)" $g "echo x > $p1990; sed -i 's/en-revisión/completado/' requirements/REQ-900.md"
  uno "profundo primero + cierre de REQ (desarr.)" $g "echo x > $p1990; sed -i 's/en-revisión/completado/' requirements/REQ-900.md" desarrollador
done
# Umbral fino (solo el destino profundo, mencion del estado para que el recorrido de guard-completado se haga)
for n in 1100 1200 1300 1400; do
  uno "umbral n=$n + cierre" guard.sh "sed -i 's/en-revisión/completado/' requirements/REQ-900.md; echo x > docs/../$(printf 'a/%.0s' $(seq 1 $n))f"
done
# Sin `..`: `//` repetido tambien entra en la lectura por directorio
p2="docs//$(printf 'a//%.0s' $(seq 1 1300))f"
uno "dobles barras (1300 niveles) primero + src/a.ts" guard.sh "echo x > $p2; echo x > src/a.ts"
echo "ulimit -s = $(ulimit -s) KiB"
