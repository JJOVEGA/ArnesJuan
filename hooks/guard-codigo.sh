#!/usr/bin/env bash
# guard-codigo.sh — Invariante A1: "la coordinadora no edita código de la app".
#
# Solo el agente de código (por defecto `desarrollador`) puede editar las rutas de
# código de la app. Cualquier edición desde la sesión coordinadora (sin `agent_id`)
# o desde otro subagente se DENIEGA. El editor se distingue por el campo `agent_id`
# del input del hook: presente sólo cuando la llamada viene de un subagente.
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
agent_id="$(printf '%s' "$input" | arnes_jq -r '.agent_id // empty')"
agent_type="$(printf '%s' "$input" | arnes_jq -r '.agent_type // empty')"
agente_codigo="$(arnes_jq -r '.agentes.agente_codigo // "desarrollador"' "$manifest")"

# Ruta relativa a la raíz del proyecto (para comparar contra los globs).
# Comparación en forma canónica: en Windows `proj` y `fp` llegan en formas distintas.
rel="$(arnes_norm_path "$fp")"
rel="${rel#"$(arnes_norm_path "$proj")"/}"

# ¿La ruta es código de la app según los globs del manifiesto?
es_codigo=0
while IFS= read -r g; do
  [ -n "$g" ] || continue
  # shellcheck disable=SC2053  -- glob a la derecha a propósito
  if [[ "$rel" == $g ]]; then es_codigo=1; break; fi
done < <(arnes_jq -r '.codigo_app.globs[]? // empty' "$manifest")

[ "$es_codigo" -eq 1 ] || exit 0   # no es código de app -> permitir

# Es código de app. Permitido SÓLO si es un subagente real (agent_id presente)
# Y además es el agente de código designado.
if [ -n "$agent_id" ] && [ "$agent_type" = "$agente_codigo" ]; then
  exit 0
fi

# Editor no autorizado -> fail-closed, no silencioso.
if [ -n "$agent_id" ]; then
  quien="el subagente '$agent_type'"
else
  quien="la sesión coordinadora"
fi
arnes_deny "ARNES: '$rel' es código de la app; sólo el agente '$agente_codigo' puede editarlo (intento de $quien). Delega el cambio en '$agente_codigo' — ni siquiera al depurar se parchea a mano (ver AGENTS.md §5)."
