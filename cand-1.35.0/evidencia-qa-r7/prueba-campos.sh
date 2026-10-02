#!/usr/bin/env bash
# Prueba de los campos que QA escribe, SOBRE UNA COPIA, con la puerta real: la instalada (1.33.2, la que corre
# en esta sesión) y la del candidato (fa070b7). (1) Cada edición de cabecera, sobre el REQ actual, se permite
# y no avisa de vocabulario. (2) Con los campos nuevos, un intento de cierre: lo que dice la puerta de
# veredictos y de `Hallazgos abiertos:` (que se interpreta y que cada clase se lee). Cola vacía y gates `true`
# en la copia, para aislar la lectura de la cabecera; el repositorio real tiene la cola llena.
E=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r7
REPO=/home/juan/dev/ArnesJuan-v1.35
INST=/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.2/hooks
CAND=$REPO/hooks
C=$E/campos; rm -rf "$C"; mkdir -p "$C/proj/.arnes" "$C/proj/requirements"
jq '.quality_gates = ["true"]' "$REPO/.arnes/config.json" > "$C/proj/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$C/proj/PENDING_APPROVAL.md"
python3 "$E/campos-nuevos.py" "$REPO/requirements" "$C/nuevos"
gate() {   # <hooks> <json> -> línea
  local out; out="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$C/proj" timeout 55 bash "$1/guard.sh" 2>&1)"
  case "$out" in *'"permissionDecision":"deny"'*) printf 'deny  :: %s' "$(jq -r '.hookSpecificOutput.permissionDecisionReason' <<< "$out" 2>/dev/null | head -c 420)" ;;
                 *systemMessage*) printf 'allow+AVISO :: %s' "$(jq -r '.systemMessage' <<< "$out" | head -c 300)" ;;
                 *) printf 'allow %s' "$(printf '%s' "$out" | head -c 200)" ;; esac
}
echo "== Prueba de los campos de QA r7 sobre una copia, $(date -Iseconds) =="
echo "-- (1) cada edición de cabecera sobre el REQ ACTUAL (Edit de la línea entera, agente qa-tester)"
for ej in "$C"/ediciones/*.json; do
  f="$(jq -r .file "$ej")"; cp "$REPO/requirements/$f" "$C/proj/requirements/$f"
  # aplicar las ediciones previas del mismo archivo para que la siguiente parta del estado intermedio
  for prev in "$C"/ediciones/*.json; do [ "$prev" = "$ej" ] && break; [ "$(jq -r .file "$prev")" = "$f" ] || continue
    python3 -c 'import json,sys;e=json.load(open(sys.argv[1]));p=sys.argv[2];t=open(p,encoding="utf-8").read();assert t.count(e["old"])==1;open(p,"w",encoding="utf-8").write(t.replace(e["old"],e["new"]))' "$prev" "$C/proj/requirements/$f"; done
  J="$(jq -c --arg fp "$C/proj/requirements/$f" --arg cwd "$C/proj" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"q1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:.old,new_string:.new}}' "$ej")"
  printf '   %-24s instalada: %s\n' "${ej##*/}" "$(gate "$INST" "$J")"
  printf '   %-24s candidato: %s\n' "${ej##*/}" "$(gate "$CAND" "$J")"
done
echo "-- (2) con los campos nuevos, un intento de CIERRE (Estado -> completado) en la copia"
for f in REQ-007.md REQ-023.md REQ-031.md REQ-001.md; do
  cp "$C/nuevos/$f" "$C/proj/requirements/$f"
  est="$(grep -m1 '^Estado:' "$C/proj/requirements/$f")"
  J="$(jq -cn --arg fp "$C/proj/requirements/$f" --arg cwd "$C/proj" --arg o "$est" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"q1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:$o,new_string:"Estado: completado"}}')"
  printf '   %-12s instalada: %s\n' "$f" "$(gate "$INST" "$J")"
  printf '   %-12s candidato: %s\n' "$f" "$(gate "$CAND" "$J")"
done
echo "-- (3) lo que lee el lector de la puerta (tools/arnes-lectura.sh del candidato) de las copias:"
( cd "$C/proj" && bash "$REPO/tools/arnes-lectura.sh" 2>&1 | grep -E "REQ-007|REQ-023|REQ-031|REQ-001" | cut -c1-260 ) || true
