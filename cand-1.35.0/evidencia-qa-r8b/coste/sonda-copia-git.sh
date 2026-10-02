#!/usr/bin/env bash
EVQ=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8b
declare -A H=([CAND]=/home/juan/dev/ArnesJuan-v1.35/hooks [B922]=$EVQ/arb/9220c71/hooks)
. "$EVQ/rerun/lib8.sh"; proyecto8 "$EVQ/coste/proj"
J=$EVQ/coste/j.json; C=$EVQ/coste/cmd.txt
cmd() {   # <forma> <N> -> $C
  case "$1" in
    A) yes 'echo aaaaaaaaaa' | head -n $(( $2 / 17 )) | sed 's/$/\r/' > "$C" ;;
    B) yes 'echo aaaaaaaaaa' | head -n $(( $2 / 16 )) > "$C" ;;
    C) { printf 'echo '; yes a | head -n $(( $2 / 2 )) | tr '\n' '\r'; } > "$C" ;;
    D) yes 'git status' | head -n $(( $2 / 12 )) | sed 's/$/\r/' > "$C" ;;
  esac
  jq -cn --rawfile c "$C" --arg p "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$p,tool_input:{command:$c}}' > "$J"
}
mide() { local t0 t1 out rc; t0=${EPOCHREALTIME/./}; out="$(CLAUDE_PROJECT_DIR="$P" timeout 120 bash "${H[$1]}/guard.sh" < "$J" 2>/dev/null)"; rc=$?; t1=${EPOCHREALTIME/./}
  T=$(( (t1 - t0) / 1000 )); case "$out" in *'"permissionDecision":"deny"'*) D=deny ;; *) D=allow ;; esac; [ $rc -ne 124 ] || D=TIMEOUT120; }
echo "== coste de la copia sin CR en guard-git ($(date -Iseconds)); loadavg $(cut -d' ' -f1-3 /proc/loadavg) =="
for N in 65536 131072 262144; do for f in A B C D; do cmd $f $N
  for k in CAND B922; do mide $k; printf '  forma=%s N=%7d bytes=%7d %-5s %7d ms %s\n' $f $N "$(wc -c < "$C")" $k $T $D; done; done; done
echo "== fin $(date -Iseconds); loadavg $(cut -d' ' -f1-3 /proc/loadavg) =="
rm -rf "$EVQ/coste/proj" "$J" "$C"
