#!/usr/bin/env bash
S="$(cd "$(dirname "$0")" && pwd)"; c="$1"; cd "$S/$c/proj" || exit 2
( find . -path ./.git -prune -o -type f -print | sort ) > "$S/$c/arbol-antes.txt"
claude -p "$(cat "$S/prompt-$c.txt")" --setting-sources project --plugin-dir "$S/plugin-sonda" \
  --allowedTools "Bash" --disallowedTools "Edit,MultiEdit,Write,NotebookEdit" --output-format stream-json --verbose --include-hook-events \
  > "$S/$c/stream.jsonl" 2> "$S/$c/stderr.txt"
echo "$?" > "$S/$c/rc-cli.txt"
( find . -path ./.git -prune -o -type f -print | sort ) > "$S/$c/arbol-despues.txt"
for f in docs/nota.md docs/partida.md src/algo; do [ -f "$f" ] && { echo "== $f"; cat "$f"; } ; done > "$S/$c/contenido-despues.txt"
