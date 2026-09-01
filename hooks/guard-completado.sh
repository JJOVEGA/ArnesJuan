#!/usr/bin/env bash
# guard-completado.sh — Invariantes A2, A3 y anti-deriva sobre la transición de un REQ a `completado`.
#
#   A2: no completar con aprobaciones pendientes en PENDING_APPROVAL.md.
#   A3: no completar si alguna quality gate falla.
#   Veredictos (anti-deriva): no completar sin `QA: aprobado`, ni un REQ marcado
#       `Sensible a seguridad: sí` sin `Seguridad: aprobado`. Así ningún REQ se cierra con la
#       validación o la auditoría pendientes/abiertas; el write-back del hallazgo al
#       requerimiento es lo que lleva esos veredictos a "aprobado" (ver AGENTS.md §9).
#
# Se dispara cuando una edición dentro de `requirements/` deja el `Estado:` del REQ en el
# valor terminal (`completado`). Si la transición no ocurre, el hook no hace nada.
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

fp="$(printf '%s' "$input" | arnes_jq -r '.tool_input.file_path // empty')"
[ -n "$fp" ] || exit 0

req_dir="$(arnes_jq -r '.requirements_dir // "requirements"' "$manifest")"
# Comparación en forma canónica: en Windows `proj` y `fp` llegan en formas distintas.
rel="$(arnes_norm_path "$fp")"
rel="${rel#"$(arnes_norm_path "$proj")"/}"
case "$rel" in
  "$req_dir"/*) ;;          # dentro de requirements/ -> seguimos
  *) exit 0 ;;
esac

estado_done="$(arnes_jq -r '.estados.completado // "completado"' "$manifest")"

# Texto entrante según la herramienta usada.
tool="$(printf '%s' "$input" | arnes_jq -r '.tool_name // empty')"
case "$tool" in
  Edit)      nuevo="$(printf '%s' "$input" | arnes_jq -r '.tool_input.new_string // empty')" ;;
  Write)     nuevo="$(printf '%s' "$input" | arnes_jq -r '.tool_input.content // empty')" ;;
  MultiEdit) nuevo="$(printf '%s' "$input" | arnes_jq -r '[.tool_input.edits[]?.new_string] | join("\n")')" ;;
  *) exit 0 ;;
esac

# ¿El cambio deja el REQ en `completado`? Normalizado: case-insensitive y espacios.
printf '%s' "$nuevo" | grep -iqE "estado:[[:space:]]*${estado_done}([[:space:]]|$)" || exit 0

# --- Veredictos QA/Seguridad (anti-deriva) ---
# Los campos viven en el archivo del REQ; se prefiere el contenido entrante y se respalda en disco
# (pre-edición), porque QA/seguridad fijan su veredicto antes de la transición a completado.
disk="$(cat "$fp" 2>/dev/null || true)"
campo() {  # $1=etiqueta -> valor normalizado (minúsculas, sin espacios)
  local v
  v="$(printf '%s\n' "$nuevo" | sed -n -E "s/^$1:[[:space:]]*//p" | head -1)"
  [ -z "$v" ] && v="$(printf '%s\n' "$disk" | sed -n -E "s/^$1:[[:space:]]*//p" | head -1)"
  printf '%s' "$v" | tr '[:upper:]' '[:lower:]' | tr -d ' \r'
}
qa="$(campo 'QA')"
seg="$(campo 'Seguridad')"
sens="$(campo 'Sensible a seguridad')"

# Solo se exige el campo cuando está presente (compatibilidad con REQ antiguos sin veredictos).
if [ -n "$qa" ] && [ "$qa" != "aprobado" ]; then
  arnes_deny "ARNES: no se puede completar '$rel': el veredicto de QA es '$qa' (se requiere 'QA: aprobado'). Resuelve los hallazgos de QA y refléjalos en el REQ antes de cerrar (AGENTS.md §9)."
fi
case "$sens" in
  sí|si)
    if [ "$seg" != "aprobado" ]; then
      arnes_deny "ARNES: no se puede completar '$rel': es 'Sensible a seguridad: sí' y el veredicto de seguridad es '${seg:-ausente}' (se requiere 'Seguridad: aprobado'). El control hallado debe quedar como NFR antes de cerrar (AGENTS.md §9)."
    fi ;;
esac

# --- Gate A2: no completar con aprobaciones pendientes ---
pending_rel="$(arnes_jq -r '.pending_approval // "PENDING_APPROVAL.md"' "$manifest")"
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
done < <(arnes_jq -r '.quality_gates[]? | if type=="object" then (.comando // empty) else . end' "$manifest")
rm -f "$tmp"

exit 0
