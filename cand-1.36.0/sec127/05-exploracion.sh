#!/usr/bin/env bash
# SEC-127 + QA-007-06, fase 1: exploracion previa a los casos del banco (sin reparar). A nivel de hook y de
# libreria, sobre los hooks del worktree (= 413c6bd) y sobre v1.35.0 (/home/juan/dev/ArnesJuan-v1.35.0-base).
# Uso: 05-exploracion.sh <scratch>   (la salida va a stdout; se guarda en 06-exploracion.txt)
set -u
S="${1:?scratch}"; W=$(mktemp -d "$S/x127-XXXX"); trap 'rm -rf "$W"' EXIT
CAND=/home/juan/dev/ArnesJuan-v1.36/hooks; V135=/home/juan/dev/ArnesJuan-v1.35.0-base/hooks
echo "# bash ${BASH_VERSION}; grep $(grep --version | head -1); LANG=${LANG-} LC_ALL=${LC_ALL-<sin definir>}"
P="$W/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$W/dir"
jq -nc '{agentes:{agente_codigo:"desarrollador"},codigo_app:{globs:["src/*"]},quality_gates:["true"],estados:{completado:"terminé"},requirements_dir:"requirements",pending_approval:"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-900\nEstado: en-revision\n' > "$P/requirements/REQ-900.md"
dec() { case "$1" in *'"permissionDecision":"deny"'*) echo deny ;; *'"permissionDecision":"allow"'*) echo allow ;; *) echo sin-decision ;; esac; }

echo; echo "## QA-007-06: read de la entrada falla (con CLAUDE_PROJECT_DIR, y sin ella)"
for arb in CAND V135; do h=${!arb}
  for g in guard.sh guard-codigo.sh guard-completado.sh guard-git.sh; do
    for causa in cerrada directorio; do
      for pd in con sin; do
        if [ "$pd" = con ]; then
          if [ "$causa" = cerrada ]; then o="$(CLAUDE_PROJECT_DIR="$P" bash "$h/$g" <&- 2>"$W/e")"; else o="$(CLAUDE_PROJECT_DIR="$P" bash "$h/$g" < "$W/dir" 2>"$W/e")"; fi
        else
          if [ "$causa" = cerrada ]; then o="$(cd "$P" && env -u CLAUDE_PROJECT_DIR bash "$h/$g" <&- 2>"$W/e")"; else o="$(cd "$P" && env -u CLAUDE_PROJECT_DIR bash "$h/$g" < "$W/dir" 2>"$W/e")"; fi
        fi
        rc=$?
        printf '%-5s %-20s stdin=%-10s project_dir=%-3s decision=%-12s rc=%s stderr=<%s>\n' "$arb" "$g" "$causa" "$pd" "$(dec "$o")" "$rc" "$(tr '\n' '|' < "$W/e" | cut -c1-140)"
      done
    done
  done
done

echo; echo "## SEC-127 caso 2: cierre por Bash con estado no ASCII (estado terminal del manifiesto: terminé)"
for cmd in "sed -i 's/en-revision/TERMINÉ/' requirements/REQ-900.md" "sed -i 's/en-revision/terminé/' requirements/REQ-900.md"; do
  for ag in - desarrollador; do
    js="$(printf '%s' "$cmd" | jq -cRs --arg c "$P" --arg a "$ag" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}} + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)')"
    for ent in "LANG=C.UTF-8" "LANG=C.UTF-8 LC_ALL=C" "LANG=C.UTF-8 POSIXLY_CORRECT=1"; do
      for arb in CAND V135; do h=${!arb}
        for g in guard.sh guard-completado.sh; do
          o="$(printf '%s' "$js" | env -u LC_ALL -u POSIXLY_CORRECT $ent CLAUDE_PROJECT_DIR="$P" bash "$h/$g" 2>/dev/null)"
          printf '%-5s %-20s ag=%-13s [%-31s] decision=%-6s %s\n' "$arb" "$g" "$ag" "$ent" "$(dec "$o")" "$cmd"
        done
      done
    done
  done
done

echo; echo "## SEC-127 caso 1: el locale del proceso DESPUES de arnes_estado_ausente (libreria, LANG=C.UTF-8)"
for modo in normal posix; do
  for txt in 'echo hola' 'echo ñandú TERMINÉ'; do
    for arb in CAND V135; do h=${!arb}
      r="$(env -u LC_ALL LANG=C.UTF-8 bash -c '
        [ "$1" = posix ] && set -o posix
        . "$2/lib.sh" 2>/dev/null
        x="ñandú"; a="LC_ALL=${LC_ALL-<sin definir>} len=${#x}"
        if ! declare -F arnes_estado_ausente >/dev/null; then echo "no existe arnes_estado_ausente"; exit 0; fi
        arnes_estado_ausente "$3" terminé; rc=$?
        echo "antes[$a] rc=$rc despues[LC_ALL=${LC_ALL-<sin definir>} len=${#x}]"' _ "$modo" "$h" "$txt")"
      printf '%-5s modo=%-6s texto=%-20s %s\n' "$arb" "$modo" "$txt" "$r"
    done
  done
done
