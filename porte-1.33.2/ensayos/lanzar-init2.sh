#!/usr/bin/env bash
set -euo pipefail
SHA=404e044; source /tmp/arnes-diag-ultimo.env; T=$TMP; H=/home/juan/.claude; C=$T/plugin-$SHA
for n in INIT-P2 INIT-P3; do rm -rf $T/proy-$n.base; cp -r $T/proy-INIT-P.base $T/proy-$n.base; done
RW="projects file-history shell-snapshots todos debug backups statsig"
lanzar(){ local R=$T/casos/$1; rm -rf "$R"; cp -r $T/proy-$1.base "$R"; printf '%s' "$2" > "$R/.prompt.txt"
  local BW=(bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /tmp --bind "$R" "$R" --ro-bind "$C" "$C" --ro-bind "$NODE_DIR" "$NODE_DIR" --bind /tmp/claude-1000 /tmp/claude-1000 --bind /home/juan/.claude.json /home/juan/.claude.json --tmpfs "$H")
  for e in "$H"/* "$H"/.[!.]*; do [ -e "$e" ] || continue; n=$(basename "$e"); case " $RW " in *" $n "*) BW+=(--bind "$e" "$e");; *) BW+=(--ro-bind "$e" "$e");; esac; done
  BW+=(--die-with-parent --chdir "$R")
  local FLAGS="--plugin-dir $C --setting-sources project,local --strict-mcp-config --tools Read,Edit,Write,Glob,Grep,Agent,Bash,Skill --allowedTools Bash --permission-mode acceptEdits --max-budget-usd 10 --output-format stream-json --verbose --debug-file $R/debug.log"
  { printf '%q ' "${BW[@]}"; printf 'env PATH=%q HOME=/home/juan claude -p "$(cat %q)" %s\n' "$NODE_DIR/bin:$PATH" "$R/.prompt.txt" "$FLAGS"; } > "$R/comando.txt"
  ( setsid nohup bash -c "$(cat $R/comando.txt) > '$R/salida.jsonl' 2> '$R/err.log' < /dev/null; echo \$? > '$R/rc.txt'; date -u +%FT%TZ > '$R/fin.txt'" > /dev/null 2>&1 & )
  date -u +%FT%TZ > "$R/inicio.txt"; echo "  lanzado $1 $(cat $R/inicio.txt)"; }
lanzar INIT-P2 "$P2"; lanzar INIT-P3 "$P3"
