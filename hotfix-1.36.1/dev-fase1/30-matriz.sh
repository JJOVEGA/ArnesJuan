#!/usr/bin/env bash
# repro <hooksdir>
H="$1"; P="$(mktemp -d)"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
cat > "$P/.arnes/config.json" <<'J'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] }, "quality_gates": ["true"], "estados": { "completado": "completado" },
  "requirements_dir": "requirements", "pending_approval": "PENDING_APPROVAL.md" }
J
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-X\nEstado: en-revisión\n' > "$P/requirements/REQ-X.md"; echo n > "$P/docs/notas.md"; echo a > "$P/src/a.ts"
ln -s notas.md "$P/docs/enlace-notas"; ln -s ../src/a.ts "$P/docs/enlace-src"; mkfifo "$P/docs/fifo"
j() { jq -cn --arg c "$1" --arg cwd "$2" --arg a "$3" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$cwd,tool_input:{command:$c}} + (if $a!="" then {agent_id:"x1",agent_type:$a} else {} end)'; }
r() { local out; out="$(j "$1" "${3:-$P}" "${2:-}" | CLAUDE_PROJECT_DIR="$P" bash "$H/guard.sh" 2>/dev/null)"; case "$out" in *'"deny"'*) d=deny;; *) d=allow;; esac; printf '%-6s %-12s %s\n' "$d" "${2:-coord}" "$1"; }
for o in cp mv install; do
 r "$o S $P/requirements/REQ-X.md"
 r "$o S requirements/REQ-X.md"
 r "$o S $P/docs/notas.md"
 r "$o -T S $P/requirements/REQ-X.md"
 r "$o S $P/docs/notas.md" qa-tester
 r "$o S $P/requirements/REQ-X.md" analista-requerimientos
 r "$o S $P/docs/enlace-notas"
 r "$o S $P/requirements/REQ-X.md" desarrollador
 r "$o S $P/docs/nuevo.md"
 r "$o S $P/src/nuevo.ts" desarrollador
 r "$o S $P/docs/enlace-src"
 r "$o S $P/docs/enlace-src" qa-tester
 r "$o S $P/docs/fifo"
 r "$o S /dev/null"
 r "$o S $P/docs/notas.md/"
 r "$o S $P/src"
done
r "cat S > $P/requirements/REQ-X.md"
rm -rf "$P"
