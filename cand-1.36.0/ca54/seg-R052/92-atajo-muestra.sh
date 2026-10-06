#!/usr/bin/env bash
# Muestra del auditor (R-052): atajo de guard-completado frente a v1.35.0, por guard.sh y por guard-completado.sh,
# comparando stdout y rc byte a byte. Arboles por git archive en el scratchpad de la sesion.
set -u
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
W=$(mktemp -d "$S/w-XXXX"); trap 'rm -rf "$W"' EXIT
iguales=0; difieren=0
for est in completado COMPLETADO Fin_2-x 'terminé' i; do
  P="$W/p"; rm -rf "$P"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
  jq -nc --arg e "$est" '{agentes:{agente_codigo:"desarrollador"},codigo_app:{globs:["src/*"]},quality_gates:["true"],estados:{completado:$e},requirements_dir:"requirements",pending_approval:"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  printf '# REQ-900\nEstado: en-revision\n' > "$P/requirements/REQ-900.md"
  lo="${est,,}"; up="${est^^}"
  for cmd in "sed -i 's/en-revision/$est/' requirements/REQ-900.md" \
             "sed -i 's/en-revision/$up/' requirements/REQ-900.md" \
             "sed -i 's/en-revision/$lo/' requirements/REQ-900.md" \
             "sed -i 's/en-revision/x$est/' requirements/REQ-900.md" \
             "sed -i 's/en-revisión/$est/' requirements/REQ-900.md" \
             "sed -i 's/en-revision/listo/' requirements/REQ-900.md" \
             "sed -i 's/en-revisión/listo/' requirements/REQ-900.md" \
             "echo $est > docs/../requirements/REQ-900.md" \
             "echo hola > requirements/REQ-900.md" \
             "echo ${est}x > requirements/REQ-900.md; : İ ı K ſ" ; do
    for g in guard.sh guard-completado.sh; do
      for ag in - desarrollador; do
        js="$(printf '%s' "$cmd" | jq -cRs --arg c "$P" --arg a "$ag" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}} + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)')"
        o1="$(printf '%s' "$js" | CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$S/t/v1.35.0/hooks/$g" 2>&1; echo "rc=$?")"
        o2="$(printf '%s' "$js" | CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$S/t/82ceb63/hooks/$g" 2>&1; echo "rc=$?")"
        case "$o1" in *'"deny"'*) d=deny ;; *) d=allow ;; esac
        if [ "$o1" = "$o2" ]; then iguales=$((iguales+1)); r=IGUAL; else difieren=$((difieren+1)); r=DIFIERE; fi
        printf '%-8s est=%-11s %-20s ag=%-13s v1.35.0=%-5s %s\n' "$r" "$est" "$g" "$ag" "$d" "$cmd"
      done
    done
  done
done
echo "TOTAL: $iguales IGUAL, $difieren DIFIERE (stdout+stderr+rc)"
