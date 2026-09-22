#!/usr/bin/env bash
# REQ-019 piloto: lanza UN brazo. Uso: lanzar-brazo.sh <SHA-arbol> <nombre-brazo> <SHA-plugin> [REPO]
# Proyecto = git archive <SHA-arbol> del repo (con git init dentro); plugin = git archive <SHA-plugin>, cargado solo.
set -euo pipefail
SHA=$1; NOM=$2; PSHA=$3; REPO=${4:-/home/juan/dev/ArnesJuan-req019}
source /tmp/arnes-piloto-ultimo.env; T=$TMP; H=/home/juan/.claude; AQUI=$(cd "$(dirname "$0")" && pwd)
C=$T/plugin-$PSHA; if [ ! -d "$C" ]; then mkdir -p "$C"; git -C "$REPO" archive --format=tar "$PSHA" | tar -x -C "$C"; fi
R=$T/casos/$NOM; O=$T/salidas/$NOM; rm -rf "$R" "$O"; mkdir -p "$R" "$O"
git -C "$REPO" archive --format=tar "$SHA" | tar -x -C "$R"
( cd "$R" && git init -q && git add -A && git -c user.name=piloto -c user.email=piloto@local commit -q -m "estado inicial del brazo $NOM ($SHA)" )
cp "$AQUI/prompt.txt" "$O/prompt.txt"; echo "$SHA" > "$O/arbol.sha"; echo "$PSHA" > "$O/plugin.sha"
BW=(bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /tmp --bind "$R" "$R" --bind "$O" "$O" --ro-bind "$C" "$C" --bind /tmp/claude-1000 /tmp/claude-1000 --bind /home/juan/.claude.json /home/juan/.claude.json --tmpfs "$H")
for e in backups file-history projects shell-snapshots; do [ -e "$H/$e" ] && BW+=(--bind "$H/$e" "$H/$e"); done
for e in cache ide plugins policy-limits.json remote-settings.json session-env sessions settings.json .credentials.json .last-cleanup; do [ -e "$H/$e" ] && BW+=(--ro-bind "$H/$e" "$H/$e"); done
BW+=(--die-with-parent --chdir "$R")
FLAGS="--plugin-dir $C --setting-sources project,local --strict-mcp-config --tools Read,Edit,Write,Glob,Grep,Agent,Bash --allowedTools Bash --permission-mode acceptEdits --max-budget-usd 12 --output-format stream-json --verbose --debug-file $O/debug.log"
{ printf '%q ' "${BW[@]}"; printf 'env HOME=/home/juan claude -p "$(cat %q)" %s\n' "$O/prompt.txt" "$FLAGS"; } > "$O/comando.txt"
( setsid nohup bash -c "$(cat "$O/comando.txt") > '$O/salida.jsonl' 2> '$O/err.log' < /dev/null; echo \$? > '$O/rc.txt'; date -u +%FT%TZ > '$O/fin.txt'" > /dev/null 2>&1 & )
date -u +%FT%TZ > "$O/inicio.txt"; echo "  lanzado $NOM arbol=$SHA plugin=$PSHA $(cat "$O/inicio.txt") -> $O"
