#!/usr/bin/env bash
# guard-completado.sh — Invariantes A3 y A2 sobre la transición de un REQ a `completado`.
#
#   A2: no se completa un REQ si hay aprobaciones pendientes en PENDING_APPROVAL.md.
#   A3: no se completa un REQ si alguna quality gate falla.
#
# Se dispara cuando una edición dentro de `requirements/` deja el `Estado:` del REQ en
# el valor terminal (`completado`). Si la transición no ocurre, el hook no hace nada.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$DIR/lib.sh"

input="$(arnes_read_stdin)"
arnes_require_jq || exit 0

proj="$(arnes_project_dir "$input")"
[ -n "$proj" ] || exit 0
manifest="$(arnes_manifest_path "$proj")"
[ -f "$manifest" ] || exit 0   # no es un proyecto del arnés -> inerte

fp="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
[ -n "$fp" ] || exit 0

req_dir="$(jq -r '.requirements_dir // "requirements"' "$manifest")"
rel="${fp#"$proj"/}"
case "$rel" in
  "$req_dir"/*) ;;          # dentro de requirements/ -> seguimos
  *) exit 0 ;;
esac

estado_done="$(jq -r '.estados.completado // "completado"' "$manifest")"

# Texto entrante según la herramienta usada.
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
case "$tool" in
  Edit)      nuevo="$(printf '%s' "$input" | jq -r '.tool_input.new_string // empty')" ;;
  Write)     nuevo="$(printf '%s' "$input" | jq -r '.tool_input.content // empty')" ;;
  MultiEdit) nuevo="$(printf '%s' "$input" | jq -r '[.tool_input.edits[]?.new_string] | join("\n")')" ;;
  *) exit 0 ;;
esac

# ¿El cambio deja el REQ en `completado`? Normalizado: case-insensitive y espacios.
printf '%s' "$nuevo" | grep -iqE "estado:[[:space:]]*${estado_done}([[:space:]]|$)" || exit 0

# --- Gate A2: no completar con aprobaciones pendientes ---
pending_rel="$(jq -r '.pending_approval // "PENDING_APPROVAL.md"' "$manifest")"
pending="$proj/$pending_rel"
if [ -f "$pending" ]; then
  abiertas="$(awk '
    /^##[[:space:]]+Pendientes/ {sec=1; next}
    /^##[[:space:]]+Resueltas/  {sec=0}
    sec && /^###[[:space:]]/    {c++}
    END {print c+0}
  ' "$pending")"
  if [ "${abiertas:-0}" -gt 0 ]; then
    arnes_deny "ARNES: no se puede marcar '$rel' como '$estado_done': hay $abiertas aprobación(es) pendiente(s) en $pending_rel. El humano debe resolverlas primero (ver AGENTS.md §6)."
  fi
fi

# --- Gate A3: quality gates en verde antes de completar ---
tmp="$(mktemp 2>/dev/null || echo /tmp/arnes_gate.$$)"
while IFS= read -r cmd; do
  [ -n "$cmd" ] || continue
  if ! ( cd "$proj" && eval "$cmd" ) >"$tmp" 2>&1; then
    out="$(tail -c 600 "$tmp" 2>/dev/null)"
    rm -f "$tmp"
    arnes_deny "ARNES: no se puede marcar '$rel' como '$estado_done': falló la quality gate \`$cmd\`. Corrígela y reintenta (ver AGENTS.md §7). Últimas líneas: $out"
  fi
done < <(jq -r '.quality_gates[]? // empty' "$manifest")
rm -f "$tmp"

exit 0
