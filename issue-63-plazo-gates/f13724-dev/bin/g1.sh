#!/usr/bin/env bash
# g1.sh <hooks 46ee7ca> <hooks candidata> <out> — CA-08 (b): la reproducción de #63, a nivel de hook, fuera del banco.
# La gate verde `sleep 35` deja un marcador al empezar: así se ve si la puerta la ejecuta.
set -u
B="$1"; C="$2"; OUT="$3"; X="$(cd "$(dirname "$0")" && pwd)"; R=/home/juan/dev/ArnesJuan-1.36.3; W="${OUT%.txt}-w"; mkdir -p "$W"
M="$W/marca"; G="$(jq -cn --arg c ": > '$W/marca'; sleep 35" '[$c]')"
uno() {   # <etiqueta> <hooks> <proyecto>
  local t0 o rc ms; rm -f "$M"; t0=${EPOCHREALTIME/./}
  o="$(cd "$3" && CLAUDE_PROJECT_DIR="$3" timeout 60 bash "$2/guard.sh" < "$3/in" 2>/dev/null)"; rc=$?
  ms=$(( (${EPOCHREALTIME/./} - t0) / 1000 ))
  printf '%-34s rc=%s %6d ms  docs=%s  marcador=%s  %s\n' "$1" "$rc" "$ms" "$(printf '%s' "$o" | jq -s length 2>/dev/null)" \
    "$([ -e "$M" ] && echo SI || echo no)" "$(printf '%s' "$o" | jq -r '.hookSpecificOutput.permissionDecisionReason // "ALLOW"' 2>/dev/null | cut -c1-150)"
}
{ echo "# CA-08 (b) #63, $(date -Is), bash $BASH_VERSION, loadavg $(cut -d' ' -f1-3 /proc/loadavg); gate: $G"
  bash "$X/fixture.sh" "$W/b" "$G"; uno "46ee7ca (v1.36.2)" "$B" "$W/b"
  bash "$X/fixture.sh" "$W/c" "$G"; uno "candidata sin veredicto" "$C" "$W/c"
  t0=${EPOCHREALTIME/./}; ( cd "$W/c" && bash "$R/tools/arnes-gates.sh" --quien banco --proyecto "$W/c" ); echo "herramienta rc=$? $(( (${EPOCHREALTIME/./} - t0) / 1000 )) ms"
  uno "candidata con veredicto" "$C" "$W/c"
  echo "registro:"; cat "$W/c/.arnes/gates-veredicto.json"
} > "$OUT" 2>&1
