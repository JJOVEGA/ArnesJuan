#!/usr/bin/env bash
# casos-punto-punto.sh <hooks_dir> — una ruta con `..` que entra desde un directorio libre
set -uo pipefail
H="$1"; R="$(mktemp -d)"; trap 'rm -rf "$R"' EXIT
P="$R/proj"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["desarrollador","qa-tester"]},"codigo_app":{"globs":["src/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; export CLAUDE_PROJECT_DIR="$P"
printf '# REQ-1\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: SEC-1 (contrato)\nRigor: critico\n' > "$P/requirements/REQ-1.md"
: > "$P/src/a.ts"
ed() { jq -n --arg fp "$1" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}'; }
wr() { jq -n --arg fp "$1" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,content:"x"}}'; }
dec() { if printf '%s' "$2" | "$H/guard.sh" 2>/dev/null | grep -Eq '"permissionDecision": *"deny"'; then echo "$1 -> deny"; else echo "$1 -> allow"; fi; }
dec "P1 Edit cierre (QA pendiente) <raiz>/requirements/REQ-1.md      " "$(ed "$P/requirements/REQ-1.md")"
dec "P2 Edit cierre (QA pendiente) <raiz>/docs/../requirements/REQ-1.md" "$(ed "$P/docs/../requirements/REQ-1.md")"
dec "P3 Edit cierre (QA pendiente) docs/../requirements/REQ-1.md (rel)" "$(ed "docs/../requirements/REQ-1.md")"
dec "P4 Write coordinadora <raiz>/src/a.ts                            " "$(wr "$P/src/a.ts")"
dec "P5 Write coordinadora <raiz>/docs/../src/a.ts                    " "$(wr "$P/docs/../src/a.ts")"
