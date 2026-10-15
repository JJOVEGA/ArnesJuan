HC="$1"; HV="$2"; P="$(mktemp -d)"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs/sub"
cat > "$P/.arnes/config.json" <<'J'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] }, "quality_gates": ["true"], "estados": { "completado": "completado" },
  "requirements_dir": "requirements", "pending_approval": "PENDING_APPROVAL.md" }
J
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; echo n > "$P/docs/notas.md"; echo a > "$P/src/a.ts"; echo 2 > "$P/2"
j() { jq -cn --arg c "$1" --arg cwd "$P" --arg a "$2" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$cwd,tool_input:{command:$c}} + (if $a!="" then {agent_id:"q",agent_type:$a} else {} end)'; }
d() { local out; out="$(j "$2" "$3" | CLAUDE_PROJECT_DIR="$P" bash "$1/guard.sh" 2>/dev/null)"; case "$out" in *'"deny"'*) printf deny;; *) printf allow;; esac; }
for a in "" qa-tester; do for o in cp mv install; do
for c in "$o S src/a.ts < docs/notas.md" "$o S src/a.ts 2>/dev/null" "$o S src/a.ts 2>&1" "$o S src/a.ts  # copia de docs/notas.md" "$o -t src docs/notas.md" "$o -rt src docs/notas.md" "$o \"-t\" src docs/notas.md" "$o '-t' src docs/notas.md" "$o \\-t src docs/notas.md" "$o -\"\"t src docs/notas.md" "$o \"--target-directory=src\" docs/notas.md" "T=-t; $o \$T src docs/notas.md" "$o \"-t\" requirements docs/notas.md && echo completado" "$o S \"src/a.ts\"" "$o docs/notas.md \"src/a.ts\"" "$o S docs/notas.md"; do
printf '%-6s %-6s %-10s %s\n' "$(d "$HC" "$c" "$a")" "$(d "$HV" "$c" "$a")" "${a:-coord}" "$c"; done; done; done; rm -rf "$P"
