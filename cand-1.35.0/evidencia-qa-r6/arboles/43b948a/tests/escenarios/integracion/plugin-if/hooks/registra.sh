#!/usr/bin/env bash
# Registra la etiqueta y el comando Bash recibido. Nunca deniega.
IFS= read -r -d '' IN || true
cmd="$(printf '%s' "$IN" | jq -r '.tool_input.command // "?"' 2>/dev/null)"
printf '%s: %s\n' "$1" "$cmd" >> "$IF_TEST_LOG"
exit 0
