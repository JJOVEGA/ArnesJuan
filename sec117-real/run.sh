#!/usr/bin/env bash
# run.sh <caso> : UNA ejecucion del CLI real, en el proyecto temporal del caso.
S="$(cd "$(dirname "$0")" && pwd)"; c="$1"; cd "$S/$c/proj" || exit 2
claude -p "$(cat "$S/prompt-$c.txt")" \
  --setting-sources project \
  --plugin-dir "$S/plugin-sonda" \
  --allowedTools "Read,Edit" \
  --disallowedTools "Bash,Write,MultiEdit,NotebookEdit" \
  --output-format stream-json --verbose --include-hook-events \
  > "$S/$c/stream.jsonl" 2> "$S/$c/stderr.txt"
echo "$?" > "$S/$c/rc-cli.txt"
sha256sum "$S/$c/proj/requirements/REQ-900.md" > "$S/$c/sha-despues.txt"
cp "$S/$c/proj/requirements/REQ-900.md" "$S/$c/REQ-900-despues.md"
