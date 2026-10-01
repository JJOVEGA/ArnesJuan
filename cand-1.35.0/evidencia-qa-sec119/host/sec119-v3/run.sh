#!/usr/bin/env bash
# run.sh <caso> : UNA ejecucion del CLI real en el proyecto del caso.
S="$(cd "$(dirname "$0")" && pwd)"; c="$1"; cd "$S/$c/proj" || exit 2
case "$c" in v-bash-*) AL="Bash"; DIS="Edit,Write,MultiEdit,NotebookEdit,Read" ;; v-fuera|v-creacion) AL="Write"; DIS="Bash,Edit,MultiEdit,NotebookEdit" ;; *) AL="Read,Edit"; DIS="Bash,Write,MultiEdit,NotebookEdit" ;; esac
claude -p "$(cat "$S/prompt-$c.txt")" --setting-sources project --plugin-dir "$S/plugin-sonda" \
  --allowedTools "$AL" --disallowedTools "$DIS" --output-format stream-json --verbose --include-hook-events \
  > "$S/$c/stream.jsonl" 2> "$S/$c/stderr.txt"
echo "$?" > "$S/$c/rc-cli.txt"
sha256sum "$S/$c/proj/requirements/REQ-900.md" > "$S/$c/sha-despues.txt"; cp "$S/$c/proj/requirements/REQ-900.md" "$S/$c/REQ-900-despues.md"
ls -la "$S/$c/proj/src/" "$S/$c/proj/docs/" "$S/$c/proj/requirements/" > "$S/$c/arbol-despues.txt" 2>&1
