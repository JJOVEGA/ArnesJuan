#!/usr/bin/env bash
# R-056: arnés de sondas a nivel de hook (Linux/WSL2). Fuente para los demás scripts; no decide nada.
# Proyecto de prueba: .arnes con quality gate configurable, REQ-900 en en-revisión con QA y Seguridad aprobados
# (un cierre sólo depende de las gates) y REQ-901 con QA pendiente (un cierre deniega por veredicto).
S="${S:-/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r056}"
H_CAND="$S/c5bf/hooks"; H_V135=/home/juan/dev/ArnesJuan-v1.35.0-base/hooks
proyecto() {   # <dir> <gate1> [gate2 ...]
  local P="$1"; shift; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/bin"
  jq -nc --args '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:$ARGS.positional,estados:{completado:"completado"},requirements_dir:"requirements",pending_approval:"PENDING_APPROVAL.md"}' "$@" > "$P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  printf '# REQ-900\nEstado: en-revisión\nQA: aprobado\nSeguridad: aprobado\nSensible a seguridad: sí\nRigor: critico\n\n## Texto\nx\n' > "$P/requirements/REQ-900.md"
  printf '# REQ-901\nEstado: en-revisión\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\nRigor: critico\n\n## Texto\nx\n' > "$P/requirements/REQ-901.md"
  printf 'x\n' > "$P/src/a.ts"
  ( cd "$P" && git init -q && git add -A && git -c user.email=a@b -c user.name=a commit -qm i )
}
entrada() {   # <P> <vector> -> JSON de la llamada
  local P="$1" c
  case "$2" in
    w-src)    jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:($c+"/src/a.ts"),content:"y"}}' ;;
    w-src-dev) jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Write",agent_type:"desarrollador",cwd:$c,tool_input:{file_path:($c+"/src/a.ts"),content:"y"}}' ;;
    b-src)    jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"echo x > src/a.ts"}}' ;;
    b-git)    jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"git reset --hard"}}' ;;
    b-sed)    jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"sed -i s/en-revisión/completado/ requirements/REQ-900.md"}}' ;;
    b-ls)     jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"ls -la"}}' ;;
    e-901)    jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:($c+"/requirements/REQ-901.md"),old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' ;;
    e-900)    jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:($c+"/requirements/REQ-900.md"),old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' ;;
    e-aviso)  jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:($c+"/requirements/REQ-901.md"),old_string:"QA: pendiente",new_string:"QA: quizas"}}' ;;
  esac
}
clasif() {   # <salida> -> deny | aviso | nada | otra(...)
  local o="$1" n
  [ -n "$o" ] || { printf nada; return; }
  n="$(jq -c . <<< "$o" 2>/dev/null | wc -l)"
  if ! jq -e . >/dev/null 2>&1 <<< "$o"; then printf 'NOJSON'; return; fi
  [ "$n" = 1 ] || { printf 'DOSJSON(%s)' "$n"; return; }
  case "$(jq -r '.hookSpecificOutput.permissionDecision // (if .systemMessage then "aviso" else "?" end)' <<< "$o")" in
    deny) printf deny ;; aviso) printf aviso ;; *) printf 'otra' ;; esac
}
# corre <hooksdir> <P> <vector> [env extra...] -> "decision rc ms motivo60"
corre() {
  local H="$1" P="$2" V="$3"; shift 3
  local in out rc t0 t1 mot
  in="$(entrada "$P" "$V")"
  t0=$(date +%s%N)
  out="$(cd "$P" && printf '%s' "$in" | env -i PATH="$P/bin:/home/juan/.local/bin:/usr/local/bin:/usr/bin:/bin" HOME="$HOME" LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P" "$@" timeout 60 bash "$H/guard.sh" 2>"$S/err.txt")"; rc=$?
  t1=$(date +%s%N)
  mot="$(jq -r '.hookSpecificOutput.permissionDecisionReason // .systemMessage // empty' <<< "$out" 2>/dev/null | head -c 70 | tr '\n' ' ')"
  printf '%s rc=%s %sms <%s>\n' "$(clasif "$out")" "$rc" "$(( (t1 - t0) / 1000000 ))" "$mot"
}
