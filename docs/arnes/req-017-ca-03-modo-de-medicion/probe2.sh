set -u
REPO=/home/juan/dev/ArnesJuan
SP="$1"
PROJ="$SP/proj2"; rm -rf "$PROJ"; mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
printf '%s\n' '{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}' > "$PROJ/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$PROJ"
prueba() {
  printf '# REQ-980\nEstado: en-revisión\n' > "$PROJ/requirements/REQ-980.md"
  local out dec
  out="$(jq -n --arg fp "$PROJ/requirements/REQ-980.md" --arg c "$2" \
    '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,content:$c}}' \
    | CLAUDE_PROJECT_DIR="$PROJ" "$REPO/hooks/guard-completado.sh" 2>/dev/null)"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then dec=DENY; else dec=ALLOW; fi
  printf '%-64s %s\n' "$1" "$dec"
}
A=$'\xd0\xb0'  # U+0430
E=$'\xd0\x95'  # U+0415
O=$'\xd0\xbe'  # U+043E cirilica o
echo "--- DOMINIO DE CAMPOS que el HOMOGLIFO abre (rigor efectivo critico por sensibilidad) ---"
prueba "control: todo limpio, QA pendiente, Seg pendiente" "# REQ-980
Estado: completado
Sensible a seguridad: sí
QA: pendiente
Seguridad: pendiente
"
prueba "'Sensible <cir a> seguridad' borrado -> el SUELO de rigor cae" "# REQ-980
Estado: completado
Sensible ${A} seguridad: sí
QA: pendiente
Seguridad: pendiente
Rigor: ligero
"
prueba "'Q<cir a>: pendiente' borrado (Sensible: sí -> critico)" "# REQ-980
Estado: completado
Sensible a seguridad: sí
Q${A}: pendiente
Seguridad: aprobado
"
prueba "'Seguridad' -> 'Segurid<cir a>d' borrado (critico)" "# REQ-980
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Segurid${A}d: pendiente
"
prueba "'Hallazg<cir o>s abiertos' borrado con hallazgo contrato" "# REQ-980
Estado: completado
Sensible a seguridad: no
Hallazg${O}s abiertos: SEC-999 (contrato)
QA: aprobado
Rigor: estandar
"
prueba "control: 'Hallazgos abiertos' limpio con hallazgo contrato" "# REQ-980
Estado: completado
Sensible a seguridad: no
Hallazgos abiertos: SEC-999 (contrato)
QA: aprobado
Rigor: estandar
"
prueba "'Rig<cir o>r: critico' borrado (sensibilidad no, QA pendiente)" "# REQ-980
Estado: completado
Sensible a seguridad: no
Rig${O}r: critico
QA: pendiente
"
