#!/usr/bin/env bash
S="$(cd "$(dirname "$0")" && pwd)"; c="$1"; cd "$S/$c/proj" || exit 2
claude -p "$(cat "$S/prompt-$c.txt")" --setting-sources project --plugin-dir "$S/plugin-sonda" \
  --allowedTools "Bash" --disallowedTools "Edit,Write,MultiEdit,NotebookEdit,Read" --output-format stream-json --verbose --include-hook-events \
  > "$S/$c/stream.jsonl" 2> "$S/$c/stderr.txt"
echo "$?" > "$S/$c/rc-cli.txt"
sha256sum "$S/$c/proj/requirements/REQ-900.md" > "$S/$c/sha-despues.txt"; cp "$S/$c/proj/requirements/REQ-900.md" "$S/$c/REQ-900-despues.md"
ls -la "$S/$c/proj/src/" > "$S/$c/src-despues.txt" 2>&1
