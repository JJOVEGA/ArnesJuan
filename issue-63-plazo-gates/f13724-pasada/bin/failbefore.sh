#!/usr/bin/env bash
# failbefore.sh <arbol-antes> <arbol-candidata> — QA-037-11 contra 42a320c y la candidata, a nivel de hook:
# (1) la puerta con el registro verde convertido en enlace simbólico y en enlace duro (y el control regular);
# (2) la puerta de Bash con `ln` / `ln -s` sobre el registro (agente de código), y los controles cat, rm, unlink.
set -u
A="$1"; C="$2"; X="$(cd "$(dirname "$0")" && pwd)"; W="$X/../w"; mkdir -p "$W"
dec() { local o; o="$(cd "$2" && CLAUDE_PROJECT_DIR="$2" bash "$1/guard.sh" < "${3:-$2/in}" 2>/dev/null)"
  case "$o" in '') echo allow ;; *'"deny"'*) printf 'deny: %s\n' "$(jq -r '.hookSpecificOutput.permissionDecisionReason' <<< "$o" | cut -c1-110)" ;; *) echo "otra" ;; esac; }
for arb in "$A" "$C"; do
  echo "== árbol: $arb"
  for forma in regular simbolico duro; do
    P="$W/p-$forma"; bash "$X/fixture.sh" "$P" '["true"]'
    ( cd "$P" && bash "$arb/../tools/arnes-gates.sh" --quien qa-tester --proyecto "$P" >/dev/null 2>&1 )
    case "$forma" in
      simbolico) mv "$P/.arnes/gates-veredicto.json" "$W/copia-verde.json"; ln -s "$W/copia-verde.json" "$P/.arnes/gates-veredicto.json" ;;
      duro) rm -f "$W/otro-nombre.json"; ln "$P/.arnes/gates-veredicto.json" "$W/otro-nombre.json" ;;
    esac
    printf '  puerta, registro %-10s -> %s\n' "$forma" "$(dec "$arb/../hooks" "$P")"
  done
  P="$W/p-bash"; bash "$X/fixture.sh" "$P" '["true"]'; R=.arnes/gates-veredicto.json
  for c in "ln -s VJ $R" "ln -sf VJ $R" "ln VJ $R" "ln -f VJ $R" "ln $R otro.json" "ln -t .arnes VJ/gates-veredicto.json" "cat $R" "rm -f $R" "unlink $R" "ln -s $R otro.json"; do
    jq -cn --arg c "$P" --arg cmd "$c" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,agent_id:"a1",agent_type:"desarrollador",tool_input:{command:$cmd}}' > "$P/inb"
    printf '  Bash %-40s -> %s\n' "\`$c\`" "$(dec "$arb/../hooks" "$P" "$P/inb")"
  done
done
