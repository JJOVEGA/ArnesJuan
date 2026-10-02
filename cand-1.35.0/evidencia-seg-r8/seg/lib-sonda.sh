# lib-sonda.sh — instrumento propio del auditor (R-046). Se hace `source`.
# JSON PreToolUse contra el entrypoint real hooks/guard.sh de cada árbol. Salida vacía = allow.
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/seg
ARBOLES="${ARBOLES:-cand 3bc7d3c 9596e39 v1.33.2}"

MANIF='{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}'

REQ_ROJO='# REQ-900 — sonda
Estado: en-revisión
Sensible a seguridad: sí
Rigor: critico
QA: pendiente
Seguridad: pendiente
Hallazgos abiertos: ninguno

## Historia
texto
'
REQ_VERDE='# REQ-901 — sonda verde
Estado: en-revisión
Sensible a seguridad: sí
Rigor: critico
QA: aprobado
Seguridad: aprobado
Hallazgos abiertos: ninguno

## Historia
texto
'

# proyecto_nuevo <dir>  (fuera de /tmp si se pasa otra raíz)
proyecto_nuevo() {
  P="$1"; rm -rf "$P"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
  printf '%s\n' "$MANIF" > "$P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  printf '%s' "$REQ_ROJO" > "$P/requirements/REQ-900.md"
  printf '%s' "$REQ_VERDE" > "$P/requirements/REQ-901.md"
  printf 'original\n' > "$P/src/a.ts"
}

# juzga <arbol> <json-file> -> DEC (deny|allow|SIN-JSON) MOT
juzga() {
  local a="$1" jf="$2" out
  DEC=''; MOT=''
  [ -s "$jf" ] || { DEC=SIN-JSON; return; }
  out="$(CLAUDE_PROJECT_DIR="$P" bash "$S/arb/$a/hooks/guard.sh" < "$jf" 2>/dev/null)"
  case "$out" in *'"permissionDecision":"deny"'*) DEC=deny ;; '') DEC=allow ;; *) DEC="otra:${out:0:60}" ;; esac
  MOT="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}

# fila <nombre> <json-file>: una línea con la decisión en cada árbol y el motivo del candidato
fila() {
  local nom="$1" jf="$2" a linea="" mc=""
  for a in $ARBOLES; do juzga "$a" "$jf"; linea+="$a=$DEC "; [ "$a" = cand ] && mc="${MOT:0:170}"; done
  printf '%-52s %s | %s\n' "$nom" "$linea" "$mc"
}

# Emisores (escriben el JSON a un archivo). El cwd y los campos van por --arg, sin pasar por el shell.
J="$S/j.json"
j_edit() {   # <fp> <old> <new> [cwd] [agent_type]
  jq -n --arg fp "$1" --arg o "$2" --arg n "$3" --arg c "${4:-$P}" --arg at "${5:-}" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:$o,new_string:$n}}
     + (if $at!="" then {agent_id:"a1",agent_type:$at} else {} end)' > "$J"
}
j_write() {  # <fp> <contentfile> [cwd] [agent_type] [tool_name]
  jq -n --arg fp "$1" --rawfile ct "$2" --arg c "${3:-$P}" --arg at "${4:-}" --arg tn "${5:-Write}" \
    '{hook_event_name:"PreToolUse",tool_name:$tn,cwd:$c,tool_input:{file_path:$fp,content:$ct}}
     + (if $at!="" then {agent_id:"a1",agent_type:$at} else {} end)' > "$J"
}
j_bash() {   # <cmd> [cwd] [agent_type]
  jq -n --arg cmd "$1" --arg c "${2:-$P}" --arg at "${3:-}" \
    '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$cmd}}
     + (if $at!="" then {agent_id:"a1",agent_type:$at} else {} end)' > "$J"
}
