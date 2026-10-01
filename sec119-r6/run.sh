#!/usr/bin/env bash
S="$(cd "$(dirname "$0")" && pwd)"; c="$1"; cd "$S/$c/proj" || exit 2
case "$c" in r6-req) AL="Bash,Read,Write" ;; *) AL="Bash,Write" ;; esac
DIS="Edit,MultiEdit,NotebookEdit"
sha256sum "$S/$c/proj/requirements/REQ-900.md" > "$S/$c/sha-antes.txt"
claude -p "$(cat "$S/prompt-$c.txt")" --setting-sources project --plugin-dir "$S/plugin-sonda" \
  --allowedTools "$AL" --disallowedTools "$DIS" --output-format stream-json --verbose --include-hook-events \
  > "$S/$c/stream.jsonl" 2> "$S/$c/stderr.txt"
echo "$?" > "$S/$c/rc-cli.txt"
sha256sum "$S/$c/proj/requirements/REQ-900.md" > "$S/$c/sha-despues.txt"; cp "$S/$c/proj/requirements/REQ-900.md" "$S/$c/REQ-900-despues.md"
( cd "$S/$c/proj" && find . -path ./.arnes -prune -o -type f -print | sort ) > "$S/$c/arbol-despues.txt"
