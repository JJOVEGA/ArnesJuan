# h.sh — arnés de sondas de QA (paso 6). Se hace `source`. Sin dependencias del banco.
# mkp <dir>: proyecto con el manifiesto base del banco, un REQ abierto y un repositorio git.
MANIF='{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}'
mkp() {
  rm -rf "$1"; mkdir -p "$1/.arnes" "$1/requirements" "$1/src" "$1/docs"
  printf '%s\n' "$MANIF" > "$1/.arnes/config.json"; printf '## Pendientes\n\n## Resueltas\n' > "$1/PENDING_APPROVAL.md"
  printf '# REQ-900\nEstado: en-revisión\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\n\n## Texto\nx\n' > "$1/requirements/REQ-900.md"
  printf 'orig\n' > "$1/src/a.ts"
  git -C "$1" init -q 2>/dev/null; git -C "$1" add -A; git -C "$1" -c user.name=qa -c user.email=qa@invalid -c core.hooksPath=/dev/null -c commit.gpgsign=false commit -qm base >/dev/null 2>&1
}
# Entradas (jq). $P es el proyecto.
in_write() { jq -cn --arg fp "$P/$1" --arg c "$P" --arg ct "$2" --arg at "${3:-}" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$fp,content:$ct}} + (if $at!="" then {agent_id:"a1",agent_type:$at} else {} end)'; }
in_edit() { jq -cn --arg fp "$P/$1" --arg c "$P" --arg o "$2" --arg n "$3" --arg at "${4:-}" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:$o,new_string:$n}} + (if $at!="" then {agent_id:"a1",agent_type:$at} else {} end)'; }
in_bash() { jq -cn --arg cmd "$1" --arg c "${2:-$P}" --arg at "${3:-}" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$cmd}} + (if $at!="" then {agent_id:"a1",agent_type:$at} else {} end)'; }
# corre <hooksdir> <guardian> <archivo-entrada> [env...] -> línea: decisión|rc|ms|bytes|motivo80
corre() {
  local hd="$1" g="$2" f="$3" o rc t0 t1 d m; shift 3
  t0=${EPOCHREALTIME/./}
  o="$(cd "$P" && env -u LC_ALL -u POSIXLY_CORRECT -u BASH_ENV LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P" "$@" timeout 60 bash "$hd/$g" < "$f" 2>/dev/null)"; rc=$?
  t1=${EPOCHREALTIME/./}
  case "$o" in
    *'"permissionDecision":"deny"'*) d=deny; m="$(jq -r '.hookSpecificOutput.permissionDecisionReason' <<<"$o" 2>/dev/null | head -c 90 | tr '\n' ' ')" ;;
    *'"systemMessage"'*) d=aviso; m="$(jq -r .systemMessage <<<"$o" 2>/dev/null| head -c 60 | tr '\n' ' ')";;
    '') d=nada; m='' ;;
    *) d=otra; m="${o:0:60}" ;;
  esac
  printf '%s|rc=%s|%sms|%sB|%s\n' "$d" "$rc" "$(( (t1-t0)/1000 ))" "${#o}" "$m"
}
