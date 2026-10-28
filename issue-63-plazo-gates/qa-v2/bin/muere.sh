#!/usr/bin/env bash
# muere.sh <arbol> <señal> <gate>: el hook, con una gate en curso, recibe <señal> a los 2 s. Cuenta documentos y lista
# lo que queda vivo en su sesión (setsid: el hook encabeza la sesión; lo que quede se mata acotado por ese SID).
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
A="$1"; SIG="$2"; G="$3"; P=$S/w-muere/$A-$SIG; . $S/proy.sh "$P" "[\"$G\"]"
( cd "$P" && CLAUDE_PROJECT_DIR="$P" exec env --default-signal=INT setsid bash "$S/arb/$A/hooks/guard.sh" < "$P/in" > "$P/out" 2>"$P/err" ) &
sleep 2; h=$(pgrep -f "^bash $S/arb/$A/hooks/guard.sh" -s 0 2>/dev/null | head -1)
h=$(ps -eo pid=,args= | awk -v a="bash $S/arb/$A/hooks/guard.sh" '$0 ~ a {print $1; exit}')
sid=$(ps -o sid= -p "$h" | tr -d ' ')
[ "$sid" = "$h" ] || { echo "$A $SIG: SID dudoso ($h/$sid)"; exit 1; }
t0=${EPOCHREALTIME/./}; kill -s "$SIG" "$h"; for ((k = 0; k < 200; k++)); do kill -0 "$h" 2>/dev/null || break; sleep 0.1; done; [ $k -lt 200 ] || echo "  el hook SIGUE VIVO a los 20 s"; ms=$(( (${EPOCHREALTIME/./}-t0)/1000 ))
sleep 0.5
d=$(grep -o '"permissionDecision":"[a-z]*"' "$P/out" | tr '\n' ' ')
vivos=$(ps -eo pid=,sid=,args= | awk -v s="$sid" '$2==s {printf "%s[%s] ", $1, substr($0, index($0,$3))}')
echo "$A señal=$SIG gate=$G: docs=<$d> en ${ms} ms; vivos en la sesión $sid: <${vivos}>"
for p in $(ps -eo pid=,sid= | awk -v s="$sid" '$2==s {print $1}'); do kill -KILL "$p" 2>/dev/null; done
ls /tmp/arnes_gate.* "${TMPDIR:-/tmp}"/arnes_gate.* 2>/dev/null | sed 's/^/  temporal que queda: /' | sort -u
