# lib-r6.sh — ayudante del desarrollador (sexta autorización, QA-023-09). Se hace `source`.
# Invoca los hooks A NIVEL DE HOOK (JSON PreToolUse inyectado) en cuatro árboles:
#   T43 = 43b948a (materializado y verificado, 00-arboles.txt) · T95 = 9596e39 (idem)
#   T133 = 1.33.2 (cache del plugin, verificada contra el tag) · MIO = hooks del worktree
EV=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-dev-r6
T43=$EV/arboles/43b948a/hooks; T95=$EV/arboles/9596e39/hooks
T133=/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.2/hooks; MIO=/home/juan/dev/ArnesJuan-v1.35/hooks
MANIF='{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*.ts", "cfg/main.json"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}'
mkproj() {
  mkdir -p "$1/.arnes" "$1/requirements" "$1/src" "$1/docs" "$1/app" "$1/cfg"
  printf '%s\n' "$MANIF" > "$1/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$1/PENDING_APPROVAL.md"
  printf 'x\n' > "$1/src/a.ts"; printf 'x\n' > "$1/app/a.ts"; printf '{}\n' > "$1/cfg/main.json"
}
req() {   # <archivo> [estado] [qa]
  printf '# %s\nEstado: %s\nSensible a seguridad: sí\nQA: %s\nSeguridad: %s\nRigor: critico\n\n## Historia\nnota\n' \
    "${1##*/}" "${2:-en-revisión}" "${3:-pendiente}" "${3:-pendiente}" > "$1"
}
# j <tool> <cwd|-> <agente|-> k=v ...   (cwd y agente por argumento, con su contenido literal)
j() {
  local t="$1" c="$2" a="$3"; shift 3
  jq -cn --arg t "$t" --arg c "$c" --arg a "$a" --args \
    '{hook_event_name:"PreToolUse",tool_name:$t,tool_input:($ARGS.positional | map(index("=") as $i | {(.[:$i]): .[$i+1:]}) | add)}
     + (if $c != "-" then {cwd:$c} else {} end) + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)' "$@"
}
call() {   # <hooksdir> <guard> <json> -> D, M, RC
  local out
  out="$(printf '%s' "$3" | CLAUDE_PROJECT_DIR="$PRJ" timeout 55 bash "$1/$2" 2>/dev/null)"; RC=$?
  case "$out" in *'"permissionDecision":"deny"'*) D=deny ;; *) D=allow ;; esac
  [ "$RC" -ne 124 ] || D="TIMEOUT"
  M="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}
NMOV_DA=0; NMOV_AD=0
quad() {   # <id> <guard> <json>
  local id="$1" g="$2" json="$3" d43 d95 d133 dm mm mov=''
  call "$T43" "$g" "$json"; d43="$D"
  call "$T95" "$g" "$json"; d95="$D"
  call "$T133" "$g" "$json"; d133="$D"
  call "$MIO" "$g" "$json"; dm="$D"; mm="$M"
  if [ "$d43" = deny ] && [ "$dm" = allow ]; then mov+=' [43b948a:deny->allow]'; NMOV_DA=$((NMOV_DA+1)); fi
  if [ "$d95" = deny ] && [ "$dm" = allow ]; then mov+=' [9596e39:deny->allow]'; NMOV_DA=$((NMOV_DA+1)); fi
  if [ "$d133" = deny ] && [ "$dm" = allow ]; then mov+=' [1.33.2:deny->allow]'; NMOV_DA=$((NMOV_DA+1)); fi
  if [ "$d43" = allow ] && [ "$dm" = deny ]; then mov+=' [43b948a:allow->deny]'; NMOV_AD=$((NMOV_AD+1)); fi
  printf '%-64s 43b948a=%-5s 9596e39=%-5s 1.33.2=%-5s mio=%-5s%s | %s\n' "$id" "$d43" "$d95" "$d133" "$dm" "$mov" "${mm:0:230}"
}
