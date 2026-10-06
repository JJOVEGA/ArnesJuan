#!/usr/bin/env bash
# SEC-129 (R-054): que puertas y que herramientas quedan sin decision cuando el hook arranca en modo POSIX,
# por cada via por la que el modo POSIX puede llegar al proceso del hook, y en cada arbol.
# Uso: 02-matriz.sh <scratch> <arbol-hooks>...   (la coordinadora: sin agent_id)
set -u
S="${1:?scratch}"; shift
W=$(mktemp -d "$S/mx-XXXX"); trap 'rm -rf "$W"' EXIT
printf 'set -o posix\n' > "$W/bashenv"
nuevo_proyecto() {
  rm -rf "$W/p"; P="$W/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
  jq -nc '{agentes:{agente_codigo:"desarrollador"},codigo_app:{globs:["src/*"]},quality_gates:["true"],estados:{completado:"completado"},requirements_dir:"requirements",pending_approval:"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  printf '# REQ-900\nEstado: en-revision\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: si\n\n## Texto\nx\n' > "$P/requirements/REQ-900.md"
}
nuevo_proyecto
casos() {
  jq -cn --arg c "$P" '{tool_name:"Write",tool_input:{file_path:($c+"/src/a.ts"),content:"x"}}'
  jq -cn --arg c "$P" '{tool_name:"Write",tool_input:{file_path:($c+"/requirements/REQ-900.md"),content:"# REQ-900\nEstado: completado\nQA: pendiente\nSeguridad: pendiente\n"}}'
  jq -cn --arg c "$P" '{tool_name:"Edit",tool_input:{file_path:($c+"/requirements/REQ-900.md"),old_string:"Estado: en-revision",new_string:"Estado: completado"}}'
  jq -cn '{tool_name:"Bash",tool_input:{command:"echo x > src/a.ts"}}'
  jq -cn '{tool_name:"Bash",tool_input:{command:"printf x | tee src/a.ts"}}'
  jq -cn '{tool_name:"Bash",tool_input:{command:"sed -i s/en-revision/completado/ requirements/REQ-900.md"}}'
  jq -cn '{tool_name:"Bash",tool_input:{command:"git reset --hard"}}'
  jq -cn '{tool_name:"Bash",tool_input:{command:"git clean -fd"}}'
  jq -cn '{tool_name:"Bash",tool_input:{command:"ls -la"}}'
}
echo "# bash $BASH_VERSION; $(uname -sr); LANG=C.UTF-8; coordinadora (sin agent_id)"
echo "# modos: normal | PC=1 (POSIXLY_CORRECT=1) | PC= (POSIXLY_CORRECT vacio) | SHELLOPTS=posix (exportada) | BASH_ENV (set -o posix) | --posix (bash --posix guard.sh)"
for h in "$@"; do
  mapfile -t CS < <(casos)
  for js0 in "${CS[@]}"; do
    js=$(jq -c --arg c "$P" '. + {hook_event_name:"PreToolUse",cwd:$c,session_id:"s"}' <<< "$js0")
    fila=""
    for m in normal PC=1 PC= SHELLOPTS BASH_ENV --posix; do
      nuevo_proyecto
      o="$( (unset LC_ALL POSIXLY_CORRECT BASH_ENV; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P"; cd "$P"
             case $m in
               normal)    printf '%s' "$js" | "$h/guard.sh" ;;
               PC=1)      printf '%s' "$js" | POSIXLY_CORRECT=1 "$h/guard.sh" ;;
               PC=)       printf '%s' "$js" | POSIXLY_CORRECT= "$h/guard.sh" ;;
               SHELLOPTS) printf '%s' "$js" | env SHELLOPTS=posix "$h/guard.sh" ;;
               BASH_ENV)  printf '%s' "$js" | BASH_ENV="$W/bashenv" "$h/guard.sh" ;;
               --posix)   printf '%s' "$js" | bash --posix "$h/guard.sh" ;;
             esac) 2>"$W/e")"; rc=$?
      case "$o" in *'"deny"'*) d=deny ;; *'"ask"'*) d=ask ;; '') d=nada ;; *) d=otro ;; esac
      # el estado del disco tras la llamada no cuenta: el hook no ejecuta la herramienta
      ne=$(grep -c . "$W/e")
      fila+=$(printf ' %-9s %-4s rc%s e%s |' "$m" "$d" "$rc" "$ne")
    done
    printf '%-30s %-5s %-58s |%s\n' "$(basename "$(dirname "$h")")/$(basename "$h")" "$(jq -r .tool_name <<< "$js")" \
      "$(jq -r '.tool_input.command // (.tool_input.file_path|sub(".*/p/";""))' <<< "$js")" "$fila"
    [ "$ne" -gt 0 ] && printf '    stderr(--posix): %s\n' "$(head -c 200 "$W/e" | tr '\n' '|' | sed "s|$h|<arbol>|g")"
  done
done
