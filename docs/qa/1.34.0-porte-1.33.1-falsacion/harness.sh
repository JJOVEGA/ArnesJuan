#!/usr/bin/env bash
# Harness de falsacion (QA). Ejerce guard-completado.sh real contra un proyecto efimero.
set -uo pipefail
HD="${1:?hooks dir}"
RAIZ="$(mktemp -d)"; trap 'rm -rf "$RAIZ"' EXIT
PROJ="$RAIZ/p"; mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
cat > "$PROJ/.arnes/config.json" <<'J'
{ "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requerimientos": { "glob": "requirements/REQ-*.md" },
  "aprobaciones": { "archivo": "PENDING_APPROVAL.md", "seccion": "## Pendientes" }
}
J
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$PROJ"

corre() { printf '%s' "$1" > "$RAIZ/in"; timeout 60 bash "$HD/guard-completado.sh" < "$RAIZ/in" 2>"$RAIZ/err"; }
veredicto() { local o; o="$(corre "$1")"
  if printf '%s' "$o" | grep -Eq '"permissionDecision": *"deny"'; then echo deny; else echo allow; fi; }
motivo() { corre "$1" | tr -d '\n' | sed 's/.*"permissionDecisionReason": *"//; s/".*//' | cut -c1-160; }

ed()  { jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:$os,new_string:$ns}}'; }
wr()  { jq -n --arg fp "$1" --arg c "$2" \
  '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,content:$c}}'; }

# req <nombre> <sens> <qa> <seg> <rigor>   (cadena vacia = linea omitida)
req() { local f="$PROJ/requirements/$1.md"
  { printf '# %s\nEstado: en-revisión\n' "$1"
    [ -n "$2" ] && printf 'Sensible a seguridad: %s\n' "$2"
    [ -n "$3" ] && printf 'QA: %s\n' "$3"
    [ -n "$4" ] && printf 'Seguridad: %s\n' "$4"
    [ -n "$5" ] && printf 'Rigor: %s\n' "$5"
    printf '\n## Cuerpo\ntexto\n'
  } > "$f"; echo "$f"; }
