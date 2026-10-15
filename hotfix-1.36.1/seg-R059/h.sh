# harness: source me. P = proyecto
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
P=$S/proj
mkproj() {
  rm -rf "$P"; mkdir -p "$P"/{src,hooks,docs/sub,requirements,.arnes}
  cat > "$P/.arnes/config.json" <<'J'
{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},
 "codigo_app":{"globs":["src/*","hooks/*",".arnes/config.json"]},
 "quality_gates":[],"estados":{"completado":"completado","todos":["pendiente","en-revisión","completado"]},
 "estado_derivado":{"activo":false},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}
J
  printf 'a\n' > "$P/src/a.ts"; printf 'l\n' > "$P/hooks/lib.sh"; printf 'n\n' > "$P/docs/notas.md"; printf 'o\n' > "$P/docs/otra.md"
  printf 's\n' > "$P/S"; printf '# REQ-X\nEstado: en-revisión\nQA: pendiente\n' > "$P/requirements/REQ-X.md"
  printf '# Cola\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  (cd "$P" && git init -q . && git add -A && git -c user.email=a@b -c user.name=a commit -qm init)
}
# dec <hooksdir> <cwd> <agente|-> <comando>
dec() {
  local h="$1" c="$2" a="$3" k="$4" j out
  j="$(jq -cn --arg c "$c" --arg a "$a" --arg k "$k" '{hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$k},cwd:$c,session_id:"s"} + (if $a != "-" then {agent_id:"x1",agent_type:$a} else {} end)')"
  out="$(cd /tmp && printf '%s' "$j" | env -i PATH=/home/juan/.local/bin:/usr/local/bin:/usr/bin:/bin HOME="$HOME" CLAUDE_PROJECT_DIR="$P" bash "$h/guard.sh" 2>/dev/null)"
  case "$out" in *'"permissionDecision":"deny"'*) echo deny ;; *'"permissionDecision":"allow"'*) echo allow-expl ;; '') echo allow ;; *) echo "otro:${out:0:80}" ;; esac
}
V=$S/v136/hooks; C=$S/cand/hooks
cmp2() { # <etiqueta> <cwd> <agente> <comando>
  local a b; a="$(dec "$V" "$2" "$3" "$4")"; b="$(dec "$C" "$2" "$3" "$4")"
  local m=''; [ "$a" = "$b" ] || m='  <-- MOVIMIENTO'
  printf '%-6s v136=%-6s cand=%-6s | %s%s\n' "$1" "$a" "$b" "$4" "$m"
}
