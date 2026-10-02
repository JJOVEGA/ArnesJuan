# lib-r7.sh — arnés de medición a nivel de hook para QA-023-13 (vuelta de la séptima autorización).
# Se hace `source`. Define el proyecto efímero, los cuatro árboles y el emisor de JSON PreToolUse.
E=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-dev-r7
declare -A ARB=(
  [cd6afa6]="$E/arboles/cd6afa6/hooks"
  [9596e39]="$E/arboles/9596e39/hooks"
  [1.33.2]="$HOME/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.2/hooks"
  [cand]="/home/juan/dev/ArnesJuan-v1.35/hooks"
)
ORDEN=(cd6afa6 9596e39 1.33.2 cand)
CR=$'\r'; NL=$'\n'

nuevo_proyecto() {   # -> P (raíz), F (fuera de la raíz)
  T="$(mktemp -d "$E/sb.XXXXXX")"; P="$T/proj"; F="$T/fuera"
  mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs" "$F"
  cat > "$P/.arnes/config.json" <<'J'
{ "agentes": { "agente_codigo": "desarrollador" },
  "codigo_app": { "globs": ["src/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
J
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  req "$P/requirements/REQ-900.md" pendiente
  req "$P/requirements/REQ-901.md" aprobado
  printf 'x\n' > "$P/src/a.ts"
}
req() { printf '# %s\nEstado: en-revisión\nSensible a seguridad: sí\nQA: %s\nSeguridad: %s\nRigor: critico\n\n## Historia\nnota\n' "${1##*/}" "$2" "$2" > "$1"; }

# j <herramienta> <cwd|-> <agente|-> <k=v…> — herramienta, cwd y agente LITERALES (con CR o LF).
j() {
  local t="$1" c="$2" a="$3"; shift 3
  jq -cn --arg t "$t" --arg c "$c" --arg a "$a" --args \
    '{hook_event_name:"PreToolUse",tool_name:$t,tool_input:($ARGS.positional | map(index("=") as $i | {(.[:$i]): .[$i+1:]}) | add)}
     + (if $c != "-" then {cwd:$c} else {} end) + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)' "$@"
}

# g <dir de hooks> <guardián> <json> -> D (deny|allow) y M (motivo)
g() {
  local out; out="$(printf '%s' "$3" | CLAUDE_PROJECT_DIR="$P" bash "$1/$2" 2>/dev/null)"
  case "$out" in *'"permissionDecision":"deny"'*) D=deny ;; *) D=allow ;; esac
  M="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}

# fila <id> <guardián> <json>: la decisión en los cuatro árboles, una línea, y el motivo de la candidata.
fila() {
  local id="$1" s="$2" json="$3" r k linea="$1 [$2]"
  for k in "${ORDEN[@]}"; do g "${ARB[$k]}" "$s" "$json"; linea+="  $k=$D"; [ "$k" != cand ] || r="$M"; done
  printf '%s\n      motivo(cand): %s\n' "$linea" "${r:0:330}"
}
