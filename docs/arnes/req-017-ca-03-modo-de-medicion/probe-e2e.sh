#!/usr/bin/env bash
# Sonda QA end-to-end sobre guard-completado.sh @1154417 (solo lectura del arbol).
WT="$1"
RAIZ="$(mktemp -d)"; PROJ="$RAIZ/proj"
mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$PROJ/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$PROJ"
printf '# REQ-980\nEstado: en-revisión\n' > "$PROJ/requirements/REQ-980.md"

caso() {  # <nombre> <contenido>
  local json out dec mot
  json="$(jq -n --arg fp "$PROJ/requirements/REQ-980.md" --arg c "$2" \
    '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,content:$c}}')"
  out="$(printf '%s' "$json" | "$WT/hooks/guard-completado.sh" 2>/dev/null)"
  dec="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // "allow(sin salida)"')"
  mot="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // empty')"
  printf '%-46s -> %-6s %s\n' "$1" "$dec" "${mot:0:150}"
}

SENS_OK='Sensible a seguridad: sí'
SENS_HOM="$(printf 'Sensible \xd0\xb0 seguridad: sí')"   # a cirilica U+0430
EST_OK='Estado: completado'
EST_HOM="$(printf '\xd0\x95stado: completado')"          # E cirilica U+0415
BOM="$(printf '\xef\xbb\xbf')"

caso "1 control: cabecera limpia, QA pendiente" "# REQ-980
$EST_OK
$SENS_OK
QA: pendiente
Seguridad: pendiente
Rigor: ligero
"
caso "2 control: BOM en Sensible (guarda viva)" "# REQ-980
$EST_OK
${BOM}$SENS_OK
QA: pendiente
Seguridad: pendiente
Rigor: ligero
"
caso "3 blanco BORRADO en Sensible" "# REQ-980
$EST_OK
Sensibleaseguridad: sí
QA: pendiente
Seguridad: pendiente
Rigor: ligero
"
caso "4 HOMOGLIFO en Sensible (a cirilica)" "# REQ-980
$EST_OK
$SENS_HOM
QA: pendiente
Seguridad: pendiente
Rigor: ligero
"
caso "5 HOMOGLIFO en Estado (E cirilica)" "# REQ-980
$EST_HOM
$SENS_OK
QA: pendiente
Seguridad: pendiente
Rigor: ligero
"
rm -rf "$RAIZ"
