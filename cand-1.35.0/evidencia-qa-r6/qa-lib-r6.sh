# Ayudante de QA (vuelta excepcional de la sexta autorización, 2026-10-01). Se hace `source`.
# Invoca los hooks A NIVEL DE HOOK (JSON PreToolUse inyectado) en cuatro árboles:
#   CAND  = hooks del worktree en 9c53232 (código de cd6afa6)
#   T43   = 43b948a materializado y verificado por oid (el árbol con la regresión QA-023-09)
#   BASE  = 9596e39 materializado y verificado por oid (la referencia de los movimientos)
#   V1332 = instalación 1.33.2 (cache del plugin, verificada contra el tag v1.33.2)
Q=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r6
CAND=/home/juan/dev/ArnesJuan-v1.35/hooks
T43=$Q/arboles/43b948a/hooks
BASE=$Q/arboles/9596e39/hooks
V1332=/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.2/hooks
NL=$'\n'; CR=$'\r'
MANIF='{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}'
mkproj() {   # <dir>
  mkdir -p "$1/.arnes" "$1/requirements" "$1/src" "$1/docs"
  printf '%s\n' "$MANIF" > "$1/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$1/PENDING_APPROVAL.md"
  printf 'x\n' > "$1/src/a.ts"
}
req() {   # <archivo> [estado] [qa]
  printf '# %s\nEstado: %s\nSensible a seguridad: sí\nQA: %s\nSeguridad: %s\nRigor: critico\n\n## Historia\nnota\n' \
    "${1##*/}" "${2:-en-revisión}" "${3:-pendiente}" "${3:-pendiente}" > "$1"
}
# j <tool> <cwd|-> <agente|-> k=v ...  (todo LITERAL: saltos y CR incluidos)
j() {
  local t="$1" c="$2" a="$3"; shift 3
  jq -cn --arg t "$t" --arg c "$c" --arg a "$a" --args \
    '{hook_event_name:"PreToolUse",tool_name:$t,tool_input:($ARGS.positional | map(index("=") as $i | {(.[:$i]): .[$i+1:]}) | add)}
     + (if $c != "-" then {cwd:$c} else {} end) + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)' "$@"
}
cierre() { j Edit "$1" "${3:--}" "file_path=$2" 'old_string=Estado: en-revisión' 'new_string=Estado: completado'; }
# call <hooksdir> <guard> <json> -> D (deny|allow|TIMEOUT|ERROR), M (motivo), RC
call() {
  local out
  out="$(printf '%s' "$3" | CLAUDE_PROJECT_DIR="$PRJ" timeout 55 bash "$1/$2" 2>"$Q/.err")"; RC=$?
  case "$out" in *'"permissionDecision":"deny"'*) D=deny ;; *) D=allow ;; esac
  [ "$RC" -ne 124 ] || D="TIMEOUT"
  [ "$RC" -eq 0 ] || [ "$RC" -eq 124 ] || D="rc$RC/$D"
  M="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}
# quad <id> <guard> <json>: decisión en los cuatro árboles y el motivo del candidato (visible con %q)
quad() {
  local id="$1" g="$2" json="$3" dc d43 db dv mc mv
  call "$CAND" "$g" "$json"; dc="$D"; mc="$M"
  call "$T43" "$g" "$json"; d43="$D"
  call "$BASE" "$g" "$json"; db="$D"
  call "$V1332" "$g" "$json"; dv="$D"
  mv=''
  case "$dc:$db" in allow:deny) mv=' <<MOV deny->allow vs 9596e39>>' ;; esac
  case "$dc:$dv" in allow:deny) mv+=' <<MOV deny->allow vs 1.33.2>>' ;; esac
  printf '%-64s cand=%-5s 43b948a=%-5s 9596e39=%-5s 1.33.2=%-5s%s | %s\n' "$id" "$dc" "$d43" "$db" "$dv" "$mv" "$(printf '%q' "${mc:0:230}")"
}
