#!/usr/bin/env bash
S="$(cd "$(dirname "$0")" && pwd)"; c="$1"; cd "$S/$c/proj" || exit 2
case "$c" in r5) AL="Read,Edit"; DIS="Bash,Write,MultiEdit,NotebookEdit" ;; cwd-cd) AL="Bash"; DIS="Read,Edit,Write,MultiEdit,NotebookEdit" ;; *) AL="Bash,Read,Write"; DIS="Edit,MultiEdit,NotebookEdit" ;; esac
claude -p "$(cat "$S/prompt-$c.txt")" --setting-sources project --plugin-dir "$S/plugin-sonda" \
  --allowedTools "$AL" --disallowedTools "$DIS" --output-format stream-json --verbose --include-hook-events \
  > "$S/$c/stream.jsonl" 2> "$S/$c/stderr.txt"
echo "$?" > "$S/$c/rc-cli.txt"
chmod u+r "$S/$c/proj/requirements/REQ-900.md" 2>/dev/null; sha256sum "$S/$c/proj/requirements/REQ-900.md" > "$S/$c/sha-despues.txt"; cp "$S/$c/proj/requirements/REQ-900.md" "$S/$c/REQ-900-despues.md"
