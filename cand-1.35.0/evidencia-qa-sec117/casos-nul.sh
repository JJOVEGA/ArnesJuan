#!/usr/bin/env bash
# casos-nul.sh <hooks_dir> — REQ con NUL (SEC-002; REQ-007 CA-45/46 (b); REQ-023 CA-13 (iv))
set -uo pipefail
H="$1"; R="$(mktemp -d)"; trap 'rm -rf "$R"' EXIT
P="$R/proj"; mkdir -p "$P/.arnes" "$P/requirements"
printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["desarrollador"]},"codigo_app":{"globs":["src/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; export CLAUDE_PROJECT_DIR="$P"
F="$P/requirements/REQ-8.md"
mk() { printf '# REQ-8\nEstado: %s\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: SEC-1 (contrato)\nRigor: critico\n\n## Historia\ncola\0byte\n' "$1" > "$F"; }
ed() { jq -n --arg fp "$F" --arg o "$1" --arg n "$2" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:$o,new_string:$n}}'; }
dec() { if printf '%s' "$2" | "$H/guard.sh" 2>/dev/null | grep -Eq '"permissionDecision": *"deny"'; then echo "$1 -> deny"; else echo "$1 -> allow"; fi; }
mk en-revisión; dec "N1 NUL, cierre que escribe la palabra (Estado: en-revisión -> Estado: completado)        " "$(ed 'Estado: en-revisión' 'Estado: completado')"
mk en-revisión; dec "N2 NUL, sin transicion, la palabra en prosa (## Historia -> ## Historia (ver REQ-9 completado))" "$(ed '## Historia' '## Historia (ver REQ-9 completado)')"
mk en-revisión; dec "N3 NUL, sin transicion ni palabra (## Historia -> ## Historia.)                          " "$(ed '## Historia' '## Historia.')"
mk ado;         dec "N4 NUL, transicion SIN escribir la palabra (disco 'Estado: ado'; 'Estado: ' -> 'Estado: complet')" "$(ed 'Estado: ' 'Estado: complet')"
