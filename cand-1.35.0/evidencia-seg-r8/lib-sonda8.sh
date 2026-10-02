# lib-sonda8.sh — instrumento propio del auditor (R-047). Se hace `source`.
# Derivado de lib-sonda.sh (R-046). JSON PreToolUse contra el entrypoint real hooks/guard.sh de cada
# árbol materializado con `git archive` (00-arboles.txt). Salida vacía = allow.
# Diferencia con R-046: el hook corre con su directorio de trabajo en la raíz del proyecto ($HCWD,
# por defecto $P), que es como lo lanza el host; así lo que dependa del directorio del hook se mide
# en la condición real y no en la del shell del auditor.
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8
ARBOLES="${ARBOLES:-cand 3bc7d3c 9596e39 v1.33.2}"

MANIF='{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*.ts"] },
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

proyecto_nuevo() {
  P="$1"; rm -rf "$P"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs" "$P/app"
  printf '%s\n' "$MANIF" > "$P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  printf '%s' "$REQ_ROJO" > "$P/requirements/REQ-900.md"
  printf '%s' "$REQ_VERDE" > "$P/requirements/REQ-901.md"
  printf 'original\n' > "$P/src/a.ts"
  printf 'original\n' > "$P/app/a.ts"
}

# juzga <arbol> <json-file> -> DEC (deny|allow|SIN-JSON|otra) MOT
juzga() {
  local a="$1" jf="$2" out
  DEC=''; MOT=''
  [ -s "$jf" ] || { DEC=SIN-JSON; return; }
  out="$(cd "${HCWD:-$P}" && CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$S/arb/$a/hooks/guard.sh" < "$jf" 2>/dev/null)"
  case "$out" in *'"permissionDecision":"deny"'*) DEC=deny ;; '') DEC=allow ;; *) DEC="otra:${out:0:60}" ;; esac
  MOT="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
}

fila() {
  local nom="$1" jf="$2" a linea="" mc=""
  for a in $ARBOLES; do juzga "$a" "$jf"; linea+="$a=$DEC "; [ "$a" = cand ] && mc="${MOT:0:150}"; done
  printf '%-58s %s | %s\n' "$nom" "$linea" "$mc"
}

J="$S/j.json"
j_edit() {   # <fp> <old> <new> [cwd] [agent_type]
  jq -n --arg fp "$1" --arg o "$2" --arg n "$3" --arg c "${4-$P}" --arg at "${5:-}" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",tool_input:{file_path:$fp,old_string:$o,new_string:$n}}
     + (if $c!="" then {cwd:$c} else {} end)
     + (if $at!="" then {agent_id:"a1",agent_type:$at} else {} end)' > "$J"
}
j_write() {  # <fp> <contentfile> [cwd] [agent_type] [tool_name]
  jq -n --arg fp "$1" --rawfile ct "$2" --arg c "${3-$P}" --arg at "${4:-}" --arg tn "${5:-Write}" \
    '{hook_event_name:"PreToolUse",tool_name:$tn,tool_input:{file_path:$fp,content:$ct}}
     + (if $c!="" then {cwd:$c} else {} end)
     + (if $at!="" then {agent_id:"a1",agent_type:$at} else {} end)' > "$J"
}
j_bash() {   # <cmd> [cwd] [agent_type]   (cwd vacío = sin campo cwd)
  jq -n --arg cmd "$1" --arg c "${2-$P}" --arg at "${3:-}" \
    '{hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$cmd}}
     + (if $c!="" then {cwd:$c} else {} end)
     + (if $at!="" then {agent_id:"a1",agent_type:$at} else {} end)' > "$J"
}
CR=$'\r'
