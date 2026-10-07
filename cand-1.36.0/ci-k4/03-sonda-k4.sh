#!/bin/bash
# sonda-k4.sh: decisión de guard.sh y guard-completado.sh (candidata c5bf6d4 y v1.35.0) ante el cierre de un REQ
# critico con QA pendiente y una clave extra "x" de N niveles, bajo el jq que haya en el PATH.
set -u
CAND=/home/juan/dev/ArnesJuan-v1.36/hooks; V135=/home/juan/dev/ArnesJuan-v1.35.0-base/hooks
P="$(mktemp -d)"; trap 'rm -rf "$P"' EXIT
mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
cat > "$P/.arnes/config.json" <<J
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] }, "quality_gates": ["true"], "estados": { "completado": "completado" },
  "requirements_dir": "requirements", "pending_approval": "PENDING_APPROVAL.md" }
J
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-900\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n' > "$P/requirements/REQ-900.md"
echo "jq en uso: $(command -v jq) -> $(jq --version 2>&1)"
for n in ${NIVELES:-254 255 256 1000 9000 9998 9999 10001}; do
  printf -v A '%*s' "$n" ''; printf -v B '%*s' "$n" ''; X="${A// /[}${B// /]}"
  J="{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Edit\",\"cwd\":\"$P\",\"tool_input\":{\"file_path\":\"$P/requirements/REQ-900.md\",\"old_string\":\"Estado: en-revisión\",\"new_string\":\"Estado: completado\"},\"x\":$X}"
  if printf '%s' "$J" | jq -e 'type' >/dev/null 2>&1; then lee=si; else lee=no; fi
  for arb in candidata v1.35.0; do h=$CAND; [ $arb = candidata ] || h=$V135
    for s in guard.sh guard-completado.sh; do
      out="$(printf '%s' "$J" | CLAUDE_PROJECT_DIR="$P" bash "$h/$s" 2>/dev/null)"
      case "$out" in *'"permissionDecision":"deny"'*) d=deny ;; *) d=allow ;; esac
      m="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null | head -c 90 | tr '\n' ' ')"
      printf 'niveles=%-5s jq_lee=%-2s %-9s %-20s %-5s %s\n' "$n" "$lee" "$arb" "$s" "$d" "$m"
    done; done; done
