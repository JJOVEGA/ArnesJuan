# lib8.sh — instrumento del desarrollador, octava autorizacion (SEC-122, QA-023-14, P-023-13-A).
# Se hace `source`. JSON PreToolUse contra el punto de entrada real (guard.sh) o un guardian, en
# CUATRO arboles: la candidata (el worktree), 3bc7d3c (= 01b4a59, el fail-before), 9596e39 (la
# referencia de los movimientos) y 1.33.2 (la instalacion estable, cache del plugin).
# A NIVEL DE HOOK: esto no es el host.
EV8=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8/rerun
declare -A ARB=(
  [cand]=/home/juan/dev/ArnesJuan-v1.35/hooks
  [3bc7d3c]=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8/arb/3bc7d3c/hooks
  [9596e39]=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8/arb/9596e39/hooks
  [1.33.2]=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8/arb/v1.33.2/hooks
)
ORDEN=(cand 3bc7d3c 9596e39 1.33.2)
NL=$'\n'; CR=$'\r'
MANIF='{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*.ts"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}'
req8() { printf '# %s\nEstado: en-revisión\nSensible a seguridad: sí\nQA: %s\nSeguridad: %s\nRigor: critico\n\n## Historia\nnota\n' "${1##*/}" "$2" "$2" > "$1"; }
# proyecto8 <dir>: proyecto nuevo con REQ-900 (rojo), REQ-901 (verde), REQ-920 (SEC-117) y src/a.ts.
proyecto8() {
  P="$1"; rm -rf "$P"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs" "$P/app"
  printf '%s\n' "$MANIF" > "$P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  req8 "$P/requirements/REQ-900.md" pendiente; req8 "$P/requirements/REQ-901.md" aprobado
  printf '# REQ-920\nEstado: en-revisión (tras “R-4”)\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n' > "$P/requirements/REQ-920.md"
  printf 'original\n' > "$P/src/a.ts"
  R="$P/requirements"
}
# j8 <herramienta> <cwd|-> <agente|-> <k=v…>  (todo LITERAL: saltos y CR incluidos)
j8() {
  local t="$1" c="$2" a="$3"; shift 3
  jq -cn --arg t "$t" --arg c "$c" --arg a "$a" --args \
    '{hook_event_name:"PreToolUse",tool_name:$t,tool_input:($ARGS.positional | map(index("=") as $i | {(.[:$i]): .[$i+1:]}) | add)}
     + (if $c != "-" then {cwd:$c} else {} end) + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)' "$@"
}
cierre8() { j8 Edit "${2:-$P}" - "file_path=$1" 'old_string=Estado: en-revisión' 'new_string=Estado: completado'; }
# llama8 <arbol> <guardian> <json> -> D (deny|allow|SIN-JSON|TIMEOUT|rcN) y M
llama8() {
  local out rc; D=''; M=''
  [ -n "$3" ] || { D=SIN-JSON; return; }
  out="$(printf '%s' "$3" | CLAUDE_PROJECT_DIR="$P" timeout 55 bash "${ARB[$1]}/$2" 2>/dev/null)"; rc=$?
  case "$out" in *'"permissionDecision":"deny"'*) D=deny ;; *) D=allow ;; esac
  [ "$rc" -ne 124 ] || D=TIMEOUT
  M="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}
# fila8 <id> <guardian> <json> [esperado en la candidata]: una linea por caso, con el motivo de la candidata.
fila8() {
  local id="$1" g="$2" js="$3" esp="${4:-}" a linea='' mc='' dc='' d95='' d33='' dfb='' mv=''
  for a in "${ORDEN[@]}"; do
    llama8 "$a" "$g" "$js"; linea+="$a=$D "
    case "$a" in cand) dc="$D"; mc="$M" ;; 3bc7d3c) dfb="$D" ;; 9596e39) d95="$D" ;; 1.33.2) d33="$D" ;; esac
  done
  case "$dc:$d95" in allow:deny) mv+=' <<deny->allow vs 9596e39>>' ;; esac
  case "$dc:$d33" in allow:deny) mv+=' <<deny->allow vs 1.33.2>>' ;; esac
  case "$dc:$dfb" in allow:deny) mv+=' <<deny->allow vs 3bc7d3c>>' ;; deny:allow) mv+=' [allow->deny vs 3bc7d3c]' ;; esac
  local ok=''; [ -z "$esp" ] || { [ "$dc" = "$esp" ] && ok=' OK' || ok=" ESPERADO=$esp"; }
  printf '%-74s %s%s%s\n      motivo(cand): %s\n' "$id [$g]" "$linea" "$mv" "$ok" "$(printf '%q' "${mc:0:260}")"
}
