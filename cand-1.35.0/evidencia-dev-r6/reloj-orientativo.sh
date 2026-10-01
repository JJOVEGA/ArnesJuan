# reloj-orientativo.sh <etiqueta> <hooks...> : una corrida por forma y árbol (ORIENTATIVO durante el desarrollo)
EV=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-dev-r6; P=$(cat $EV/.perfproj)
et="$1"; shift
for forma in A B C; do
  l="[$et] forma=$forma"
  for h in "$@"; do
    t0=${EPOCHREALTIME/./}; o="$(CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/guard.sh" < $EV/perf-$forma.json 2>/dev/null)"; t1=${EPOCHREALTIME/./}
    case "$o" in *'"deny"'*) d=deny ;; *) d=allow ;; esac
    l+=" | ${h#$EV/arboles/} $(( (t1-t0)/1000 ))ms $d"
  done
  echo "$l | carga=$(cut -d' ' -f1-3 /proc/loadavg)"
done
