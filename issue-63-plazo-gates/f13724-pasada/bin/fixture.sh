#!/usr/bin/env bash
# fixture.sh <dir> <gates-json> [QA:] — el cierre legítimo de REQ-037 (repro.sh del issue), con git: proyecto mínimo,
# un manifiesto con esas gates, REQ-001 en revisión con todo en orden, el commit inicial y la entrada del Edit de
# qa-tester en <dir>/in. Sin datos de ningún consumidor.
set -u
P="$1"; G="$2"; QA="${3:-aprobado}"
rm -rf "$P"; mkdir -p "$P/requirements" "$P/.arnes" "$P/src" "$P/docs"
jq -n --argjson g "$G" '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:$g}' > "$P/.arnes/config.json"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf 'n\n' > "$P/docs/notas.md"; printf 'x\n' > "$P/src/a.txt"
printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: %s\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' "$QA" > "$P/requirements/REQ-001.md"
( cd "$P" && git init -q && git add -A && git -c user.email=x@x -c user.name=x commit -qm base )
jq -cn --arg fp "$P/requirements/REQ-001.md" --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$P/in"
