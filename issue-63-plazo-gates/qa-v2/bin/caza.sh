#!/usr/bin/env bash
# caza.sh <arbol> <n> <gate> <dir>: cierres en sesión propia; si uno no decide en 3 s, foto de su sesión y sigue esperando
# hasta 30 s; luego KILL a la sesión (acotado por su SID). Sin cambios de los hooks.
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
A="$1"; N="$2"; G="$3"; O="$4"; mkdir -p "$O"; P=$O/p; . $S/proy.sh "$P" "[\"$G\"]"; caz=0
for ((i = 0; i < N; i++)); do
  ( cd "$P" && CLAUDE_PROJECT_DIR="$P" exec setsid bash "$S/arb/$A/hooks/guard.sh" < "$P/in" > "$O/out" 2>/dev/null ) & l=$!
  t0=${EPOCHREALTIME/./}; k=0
  while kill -0 $l 2>/dev/null && (( ${EPOCHREALTIME/./} - t0 < 3000000 )); do sleep 0.05; done
  if kill -0 $l 2>/dev/null; then
    caz=$((caz + 1)); h=$(pgrep -P $l 2>/dev/null | head -1); [ -n "$h" ] || h=$l
    sid=$(ps -o sid= -p "$h" | tr -d ' ')
    { echo "== it=$i $(date +%T.%N) hook=$h sid=$sid loadavg=$(cut -d' ' -f1-3 /proc/loadavg)"
      ps -s "$sid" -o pid,ppid,pgid,stat,wchan:22,etimes,args 2>/dev/null
      for p in $(ps -s "$sid" -o pid= 2>/dev/null); do echo "-- $p: $(tr '\0' ' ' < /proc/$p/cmdline 2>/dev/null | cut -c1-80)"; grep -E '^(State|SigQ|SigPnd|ShdPnd|SigBlk|SigIgn|SigCgt)' /proc/$p/status 2>/dev/null | tr '\n' ' '; echo; ls -l /proc/$p/fd 2>/dev/null | awk 'NR>1{print "   fd",$9,$11}'; done
      echo "salida hasta ahora: <$(cat $O/out)>"; } >> "$O/foto.$i"
    while kill -0 $l 2>/dev/null && (( ${EPOCHREALTIME/./} - t0 < 30000000 )); do sleep 0.2; done
    echo "it=$i: $(( (${EPOCHREALTIME/./} - t0) / 1000 )) ms; salida <$(head -c 200 $O/out)>" | tee -a "$O/foto.$i"
    [ -n "$sid" ] && for p in $(ps -s "$sid" -o pid= 2>/dev/null); do kill -KILL "$p" 2>/dev/null; done
  fi
  wait $l 2>/dev/null
done
echo "$A gate=$G n=$N cazados(>3 s)=$caz"
