#!/usr/bin/env bash
# La CELDA HEREDADA de SEC-084 (REQ-024 CA-12(ii)(B) salida b), oracion por oracion.
set -u
REPO=/home/juan/dev/ArnesJuan-1.34-reparaciones
PROJ=/tmp/claude-1000/-home-juan-dev-ArnesJuan/23a8ee5a-8587-4923-8f15-1fc9bf03aaf2/scratchpad/p84
mk() { rm -rf "$PROJ"; mkdir -p "$PROJ/.arnes" "$PROJ/requirements"
  cat > "$PROJ/.arnes/config.json" <<J
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "campos": { "ausencia_exige": $1 },
  "requirements_dir": "requirements", "pending_approval": "PENDING_APPROVAL.md" }
J
  printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"; }
export CLAUDE_PROJECT_DIR="$PROJ"

firma() { # <rotulo> <cabecera COMPLETA sin la linea que se escribe> <linea nueva>
  local rot="$1" cab="$2" ns="$3" out deny msg
  printf '# REQ-960\nEstado: en-revisión\nSensible a seguridad: sí\nRigor: critico\n%s\n' "$cab" > "$PROJ/requirements/REQ-960.md"
  out="$(jq -n --arg fp "$PROJ/requirements/REQ-960.md" --arg ns "$ns" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,old_string:"Seguridad: pendiente",new_string:$ns}}' \
    | "$REPO/hooks/guard-completado.sh" 2>/dev/null)"
  deny=ALLOW; printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"' && deny=DENY
  msg="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null | tr '\n' ' ')"
  printf '  %-52s %-5s :: %s\n' "$rot" "$deny" "$(printf '%s' "$msg" | head -c 130)"
}

for llave in false true; do
  mk "$llave"
  echo "########## campos.ausencia_exige = $llave ##########"
  echo "-- oracion 1: 'tampoco cuando la linea QA: no llega a declararse -> deniega nombrando el campo'"
  firma "QA: AUSENTE, se firma Seguridad: aprobado"     'Seguridad: pendiente'                 'Seguridad: aprobado'
  firma "[control] QA: pendiente, se firma Seguridad"   $'QA: pendiente\nSeguridad: pendiente' 'Seguridad: aprobado'
  firma "[control] QA: aprobado, se firma Seguridad"    $'QA: aprobado\nSeguridad: pendiente'  'Seguridad: aprobado'
  firma "QA: comentado <!-- -->, se firma Seguridad"    $'<!-- QA: aprobado -->\nSeguridad: pendiente' 'Seguridad: aprobado'
  echo "-- oracion 2: 'una linea que el lector NO lee como Seguridad:, esta guarda NO la juzga'"
  firma "firma escrita 'seguridad:' minuscula (desfase)" $'QA: pendiente\nSeguridad: pendiente' 'seguridad: aprobado'
  firma "firma escrita 'Ѕeguridad:' homoglifo (clase no)" $'QA: pendiente\nSeguridad: pendiente' $'\xd0\x85eguridad: aprobado'
  echo
done
