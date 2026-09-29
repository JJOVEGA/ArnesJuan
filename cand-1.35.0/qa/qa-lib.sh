#!/usr/bin/env bash
# Arnés de QA independiente (REQ-023, vuelta 1). No reutiliza ayudantes del banco.
# Invoca el PUNTO DE ENTRADA real (hooks/guard.sh) con el JSON PreToolUse, en tres árboles:
#   CAND = candidato (worktree, cabeza ace43c2), BASE = 713ac68 materializado por SHA, N = 1.33.2 instalada.
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/qa
CAND=/home/juan/dev/ArnesJuan-v1.35/hooks
BASE=$S/base713/hooks
NHK=/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.2/hooks
LOCQA="${LOCQA:-C.UTF-8}"
PROJ="$(mktemp -d -p "$S" proj.XXXX)"
mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
cat > "$PROJ/.arnes/config.json" <<'JSON'
{ "agentes": { "agente_codigo": "desarrollador",
    "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
JSON
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
F="$PROJ/requirements/REQ-950.md"
export CLAUDE_PROJECT_DIR="$PROJ"

# doc <lineas de cabecera...> -> DOC (documento completo, LF)
doc() { local l; DOC='# REQ-950 — prueba'; for l in "$@"; do DOC+=$'\n'"$l"; done; DOC+=$'\n\n## Historia\n\nTexto.\n'; }

# juzga <hooks> <json> [locale] -> DEC (deny|allow|NOSALIDA) MOT RC
juzga() {
  local out
  out="$(printf '%s' "$2" | LC_ALL="${3:-$LOCQA}" CLAUDE_PROJECT_DIR="$PROJ" bash "$1/guard.sh" 2>"$S/stderr.last")"; RC=$?
  OUT="$out"
  case "$out" in
    *'"permissionDecision":"deny"'*) DEC=deny ;;
    *) DEC=allow ;;
  esac
  [ "$RC" -eq 0 ] || DEC="allow(rc=$RC)"
  MOT="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}

jedit()  { jq -cn --arg fp "$F" --arg o "$1" --arg n "$2" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:$o,new_string:$n}}'; }
jwrite() { jq -cn --arg fp "$F" --arg c "$1" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,content:$c}}'; }
# jmulti o1 n1 [o2 n2 ...]
jmulti() {
  local ed='[]'
  while [ "$#" -ge 2 ]; do ed="$(jq -c --arg o "$1" --arg n "$2" '. + [{old_string:$o,new_string:$n}]' <<< "$ed")"; shift 2; done
  jq -cn --arg fp "$F" --argjson e "$ed" '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,edits:$e}}'
}

# prueba <id> <E|W|M> <disco> <old> <new> [esperado-cand] -> una fila; usa CAND, BASE y N
# E: Edit old->new sobre el disco. W: Write del disco con old->new (primera). M: MultiEdit de una edicion.
TOT=0; MAL=0
prueba() {
  local id="$1" via="$2" disco="$3" o="$4" n="$5" esp="${6:-}" json res dc db dn mc
  printf '%s' "$disco" > "$F"
  case "$via" in
    E) json="$(jedit "$o" "$n")" ;;
    M) json="$(jmulti "$o" "$n")" ;;
    W) res="${disco/"$o"/"$n"}"; json="$(jwrite "$res")" ;;
  esac
  [ -n "$json" ] || { echo "JSON VACIO $id"; return 1; }
  if [ -n "${VOLCAR_DIR:-}" ]; then VN=$((${VN:-0}+1)); printf '%s' "$disco" > "$VOLCAR_DIR/$(printf %04d $VN)-$id-$via-disco.md"; [ "$via" != W ] || printf '%s' "$res" > "$VOLCAR_DIR/$(printf %04d $VN)-$id-$via-res.md"; fi
  juzga "$CAND" "$json"; dc="$DEC"; mc="$MOT"
  printf '%s' "$disco" > "$F"; juzga "$BASE" "$json"; db="$DEC"
  printf '%s' "$disco" > "$F"; juzga "$NHK" "$json"; dn="$DEC"
  TOT=$((TOT+1))
  local marca=''
  if [ -n "$esp" ] && [ "$esp" != "$dc" ]; then marca='  <<< INESPERADO'; MAL=$((MAL+1)); fi
  printf '%-34s %s cand=%-6s base=%-6s N=%-6s | %s%s\n' "$id" "$via" "$dc" "$db" "$dn" "${mc:0:230}" "$marca"
}
