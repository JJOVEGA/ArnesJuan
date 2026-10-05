#!/usr/bin/env bash
# Pasada correctiva de SEC-120 (QA-007-03 y QA-007-04): entradas y procesos. Reutiliza el proyecto y las entradas
# normales de la fase 2 (../proyecto, ../entradas/n*.json) y añade las formas de los dos hallazgos. Mide con la
# sonda del contrato (tests/util/sonda-procesos.sh, invocada tal cual) y con el recuento exacto por espacio de PID
# de la comisión de CA-54. Uso: genera-y-mide.sh <worktree> <etiqueta=dir de hooks>...
set -uo pipefail
C=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120; E="$C/correctiva"; P="$C/proyecto"; D="$E/entradas"
WT="${1:?worktree}"; shift; SONDA="$WT/tests/util/sonda-procesos.sh"; R="${R:-2}"; TRAB="${TMPDIR:-/tmp}"
rm -rf "$D"; mkdir -p "$D"; cp "$C"/entradas/n*.json "$D/"
LS="$(cat "$C/entradas/n1-bash-ls.json")"; WR="$(cat "$C/entradas/n6-bash-escribe-src.json")"
: > "$D/c1-vacia.json"
printf '\0%s' "$LS" > "$D/c2-nul-objeto.json"
printf '\0\0' > "$D/c3-solo-nul.json"
printf '%s\0%s' "$LS" "$WR" > "$D/c4-objeto-nul-escritura.json"
jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",cwd:$c,tool_name:"Write",tool_input:{file_path:false,content:"x"}}' > "$D/c5-file-path-false.json"
jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",cwd:$c,tool_name:"Bash",tool_input:{command:false}}' > "$D/c6-command-false.json"
jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",cwd:$c,agent_id:"a1",agent_type:"desarrollador",tool_name:"Edit",tool_input:{file_path:false,old_string:"a",new_string:"b"}}' > "$D/c7-file-path-false-dev.json"
for J in "$D"/*.json; do
  linea="${J##*/}"
  for par in "$@"; do
    arbol="${par%%=*}"; H="${par#*=}"
    s="$(ARNES_ARBOL="$arbol" bash "$SONDA" --dir-trabajo "$TRAB" --etiqueta "${J##*/}" \
          --sujeto "CLAUDE_PROJECT_DIR='$P' bash '$H/guard.sh' < '$J'" 2>&1 | grep -o 'estado=[a-z-]*\|procesos=[0-9a-z-]*' | tr '\n' ' ')"
    v=''
    for ((k = 1; k <= R; k++)); do
      n="$(P="$P" H="$H" J="$J" unshare -Urpf --mount-proc bash -c 'CLAUDE_PROJECT_DIR="$P" bash "$H/guard.sh" < "$J" > /dev/null 2>&1; sh -c "echo \$\$"; :')"
      v+=" $((n - 2))"
    done
    d="$(CLAUDE_PROJECT_DIR="$P" bash "$H/guard.sh" < "$J" 2>/dev/null)"
    case "$d" in *'"permissionDecision":"deny"'*) d=deny ;; '') d=sin-decision ;; *) d=otra ;; esac
    linea+=" | $arbol: $d; sonda ${s% }; exacto$v"
  done
  echo "$linea"
done
# Los hooks de parada no cambian con la entrada vacía (no pasan `guardian` al preludio): sin salida y rc 0.
for par in "$@"; do
  H="${par#*=}"; o="$(CLAUDE_PROJECT_DIR="$P" bash "$H/stop.sh" < "$D/c1-vacia.json" 2>&1)"; echo "stop.sh con entrada vacia | ${par%%=*}: rc=$? salida=<${o:0:80}>"
done
