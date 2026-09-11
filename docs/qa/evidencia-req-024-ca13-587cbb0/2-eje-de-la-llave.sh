#!/usr/bin/env bash
# Segunda tanda: el EJE DE LA LLAVE (campos.ausencia_exige), que la primera no cubrio.
set -u
REPO=/home/juan/dev/ArnesJuan-1.34-reparaciones
PROJ=/tmp/claude-1000/-home-juan-dev-ArnesJuan/23a8ee5a-8587-4923-8f15-1fc9bf03aaf2/scratchpad/p13b
mk() { # <true|false>
  rm -rf "$PROJ"; mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
  cat > "$PROJ/.arnes/config.json" <<J
{ "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "campos": { "ausencia_exige": $1 },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
J
  printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
}
export CLAUDE_PROJECT_DIR="$PROJ"

cierre() { # <rotulo> <cabecera extra> <rigor>
  local rot="$1" cab="$2" rigor="$3" out deny motivo
  { printf '# REQ-951\nEstado: en-revisión\nSensible a seguridad: no\n'
    printf '%s\n' "$cab"
    printf 'Hallazgos abiertos: (ninguno)\nRigor: %s\n\n## Historia\n' "$rigor"; } > "$PROJ/requirements/REQ-951.md"
  out="$(jq -n --arg fp "$PROJ/requirements/REQ-951.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' \
    | "$REPO/hooks/guard-completado.sh" 2>/dev/null)"
  deny=ALLOW; printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"' && deny=DENY
  motivo="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null | tr '\n' ' ')"
  printf '  %-44s rigor=%-9s %-5s :: %s\n' "$rot" "$rigor" "$deny" "$(printf '%s' "$motivo" | head -c 150)"
}

for llave in false true; do
  mk "$llave"
  echo "################ campos.ausencia_exige = $llave ################"
  echo "-- QA: AUSENTE (el aviso de QA NO lleva condicion de rigor)"
  for r in ligero estandar critico; do cierre "QA AUSENTE + Seguridad: aprobado" 'Seguridad: aprobado' "$r"; done
  echo "-- Seguridad: AUSENTE (el aviso SI lleva condicion de rigor)"
  for r in ligero estandar critico; do cierre "SEG AUSENTE + QA: aprobado" 'QA: aprobado' "$r"; done
  echo "-- clase 'no': homoglifo en la clave de SEGURIDAD"
  for r in ligero estandar critico; do cierre "Ѕeguridad: U+0405" $'QA: aprobado\n\xd0\x85eguridad: aprobado' "$r"; done
  echo "-- clase 'no': homoglifo en la clave de QA (Q cirilica no existe; uso А U+0410)"
  for r in ligero estandar critico; do cierre "QА: U+0410 en QA" $'Q\xd0\x90: aprobado\nSeguridad: aprobado' "$r"; done
  echo "-- desfase: qa: minuscula"
  for r in ligero estandar critico; do cierre "qa: minuscula + Seguridad: aprobado" $'qa: aprobado\nSeguridad: aprobado' "$r"; done
  echo
done
