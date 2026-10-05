#!/usr/bin/env bash
# Reproduccion minima: un destino con `..` seguido de muchos niveles hace que la lectura lexica por directorio
# (`_arnes_lectura_lexica`, recursiva por segmento desde dee5932) agote la pila de bash: el hook muere por
# SIGSEGV (rc 139), sin decision, y la llamada pasa. v1.35.0 sobre la misma entrada decide.
# Uso: 70-segfault.sh ; salida: una linea por (N niveles, comando, arbol): rc, decision, ms.
set -u
B=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/arboles/v1.35.0/hooks
C=/home/juan/dev/ArnesJuan-v1.36/hooks
W=$(mktemp -d /tmp/qa-segv-XXXX); trap 'rm -rf "$W"' EXIT
P="$W/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
printf '%s' '{"agentes":{"agente_codigo":"desarrollador"},"codigo_app":{"globs":["src/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; printf 'x\n' > "$P/src/a.ts"
printf '# REQ-900\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n' > "$P/requirements/REQ-900.md"
for n in 100 300 500 700 1000 1500 1990; do
  prof="docs/../$(printf 'a/%.0s' $(seq 1 $n))f"
  for k in codigo cierre solo; do
    case $k in
      codigo) cmd="echo x > src/a.ts; echo x > $prof" ;;
      cierre) cmd="sed -i 's/en-revisión/completado/' requirements/REQ-900.md; echo x > $prof" ;;
      solo)   cmd="echo x > $prof" ;;
    esac
    js="$(printf '%s' "$cmd" | jq -cRs --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}}')"
    for h in "$B" "$C"; do
      t0=${EPOCHREALTIME/./}; o="$(printf '%s' "$js" | CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/guard.sh" 2>/dev/null)"; rc=$?; t1=${EPOCHREALTIME/./}
      case "$o" in *'"deny"'*) d=deny ;; '') d=sin-salida ;; *) d=allow ;; esac
      printf 'n=%-5s cmd=%-7s bytes=%-5s %-9s rc=%-3s decision=%-10s ms=%s\n' "$n" "$k" "${#cmd}" "$([ "$h" = "$B" ] && echo v1.35.0 || echo candidato)" "$rc" "$d" "$(( (t1-t0)/1000 ))"
    done
  done
done
# Y por cada guardian solo, en el umbral, para saber cual muere
prof="docs/../$(printf 'a/%.0s' $(seq 1 1990))f"; cmd="echo x > src/a.ts; echo x > $prof"
js="$(printf '%s' "$cmd" | jq -cRs --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}}')"
for g in guard-codigo.sh guard-completado.sh guard-git.sh; do
  for h in "$B" "$C"; do
    o="$(printf '%s' "$js" | CLAUDE_PROJECT_DIR="$P" bash "$h/$g" 2>/dev/null)"; rc=$?
    case "$o" in *'"deny"'*) d=deny ;; '') d=sin-salida ;; *) d=allow ;; esac
    echo "guardian=$g $([ "$h" = "$B" ] && echo v1.35.0 || echo candidato) rc=$rc decision=$d"
  done
done
echo "ulimit -s = $(ulimit -s) KiB; bash $BASH_VERSION"
