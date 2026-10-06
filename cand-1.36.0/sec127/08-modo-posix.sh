#!/usr/bin/env bash
# Observacion fuera de alcance (no se repara aqui): con el hook arrancado en modo POSIX (POSIXLY_CORRECT=1 en el
# entorno), ¿deciden los guardianes por la via Bash? Candidata (worktree = 413c6bd) y v1.35.0. bash 5.3.
# Uso: 08-modo-posix.sh <scratch>   -> 09-modo-posix.txt
set -u
S="${1:?scratch}"; W=$(mktemp -d "$S/px-XXXX"); trap 'rm -rf "$W"' EXIT
P="$W/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
jq -nc '{agentes:{agente_codigo:"desarrollador"},codigo_app:{globs:["src/*"]},quality_gates:["true"],estados:{completado:"completado"},requirements_dir:"requirements",pending_approval:"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; printf '# REQ-900\nEstado: en-revision\n' > "$P/requirements/REQ-900.md"
echo "# bash $BASH_VERSION; coordinadora (sin agent_id); LANG=C.UTF-8"
for h in /home/juan/dev/ArnesJuan-v1.36/hooks /home/juan/dev/ArnesJuan-v1.35.0-base/hooks; do
  for js in "$(jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:($c+"/src/a.ts"),content:"x"}}')" \
            "$(jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"echo x > src/a.ts"}}')" \
            "$(jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"sed -i s/en-revision/completado/ requirements/REQ-900.md"}}')" \
            "$(jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"git reset --hard"}}')"; do
    for m in no si; do
      o="$( (unset LC_ALL POSIXLY_CORRECT; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P"; [ "$m" = no ] || export POSIXLY_CORRECT=1; printf '%s' "$js" | bash "$h/guard.sh") 2>"$W/e")"; rc=$?
      case "$o" in *'"deny"'*) d=deny ;; *) d=sin-decision ;; esac
      printf '%-38s posix=%-2s %-12s rc=%s %-5s %-60s stderr=<%s>\n' "${h%/hooks}" "$m" "$d" "$rc" "$(jq -r .tool_name <<< "$js")" \
        "$(jq -r '.tool_input.command // .tool_input.file_path' <<< "$js" | sed "s|$P/||")" "$(head -c 160 "$W/e" | tr '\n' '|')"
    done
  done
done
