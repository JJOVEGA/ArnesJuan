#!/usr/bin/env bash
# (b) La lista cerrada de opciones de REQ-032 CA-15 (vuelta 2), opción por opción, y nombres del conjunto
# permitido. Para cada orden (cp, mv, install) y cada opción de la lista, con un origen ARCHIVO, DIRECTORIO
# o ENLACE a código protegido, y el destino `docs/notas.md` (archivo regular, un enlace, no protegido):
# decisión de guard.sh en la candidata y en v1.36.0 (coordinadora), y el efecto real de la orden en una
# copia limpia: ¿cambió algo bajo src/? ¿qué quedó en docs/notas.md? Uso: bash 40-opciones.sh <cand> <v136>
set -u
HC="$1"; HV="$2"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
nuevo() {
  P="$T/p$1"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs/sub"
  printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  printf 'n\n' > "$P/docs/notas.md"; printf 'a\n' > "$P/src/a.ts"; printf 'S\n' > "$P/S"; printf 'u\n' > "$P/docs/sub/u.md"
  ln -s src/a.ts "$P/ES"
  for x in = : @x % + , ; do printf 'r\n' > "$P/$x"; done
}
dec() { local out; out="$(cd "$T" && jq -cn --arg c "$P" --arg k "$2" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}}' | CLAUDE_PROJECT_DIR="$P" bash "$1/guard.sh" 2>/dev/null)"; case "$out" in *'"deny"'*) echo deny ;; *) echo allow ;; esac; }
foto() { ( cd "$P" && find src -printf '%p %y %s\n' 2>/dev/null | sort; cat src/a.ts 2>/dev/null ) | md5sum | cut -c1-8; }
n=0
caso() {   # <comando>
  n=$((n + 1)); nuevo "$n"
  local dv dc a b rc n