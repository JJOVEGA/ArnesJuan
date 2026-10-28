#!/usr/bin/env bash
# cierres.sh <arbol> <clase> <n> <dir> — CA-08 (a) y CA-09 sobre la candidata (diseño F-137-24). El cierre legítimo de
# dobles.sh (vuelta 1), en un repositorio git, con el veredicto en el estado de <clase>:
#   valido   gate `true`, la herramienta corrió (verde)            -> allow (0 documentos)
#   rojo     gate `false`, la herramienta corrió (rojo)            -> 1 deny «no salio 0»
#   caducado gate `true`, verde, y después un archivo nuevo no ignorado -> 1 deny «no es del arbol actual»
#   ausente  gate `true`, sin correr la herramienta                -> 1 deny «no hay veredicto»
# Cuenta por respuesta: documentos JSON, ms (> 5000 = cuelgue), y si la decisión es la esperada.
set -u
A="$1"; C="$2"; N="$3"; O="$4"; H="$A/hooks"; T="$A/tools/arnes-gates.sh"
P="$O/p-$C"; rm -rf "$P"; mkdir -p "$P/requirements" "$P/.arnes" "$P/src"
g='true'; [ "$C" = rojo ] && g='false'
jq -n --arg g "$g" '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:[$g]}' > "$P/.arnes/config.json"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
echo 'x' > "$P/src/a.txt"; printf '.arnes/gates-veredicto.json\n' > "$P/.gitignore"
jq -n --arg fp "$P/requirements/REQ-001.md" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$O/in-$C"
( cd "$P" && git init -q && git add -A && git -c user.name=qa -c user.email=qa@x commit -qm base ) || { echo "git init falló"; exit 1; }
case "$C" in valido|rojo|caducado) ( cd "$P" && bash "$T" --quien qa-tester ) > "$O/herr-$C.txt" 2>&1; echo "herramienta rc=$?" >> "$O/herr-$C.txt" ;; esac
[ "$C" = caducado ] && echo nuevo > "$P/src/nuevo.txt"
case "$C" in valido) esp='';; rojo) esp='no salio 0';; caducado) esp='no es del arbol actual';; ausente) esp='no hay veredicto';; esac
dob=0; cue=0; desp=0; aesp=0; otro=0; maxms=0; t_ini=$SECONDS
for ((i = 0; i < N; i++)); do
  t0=${EPOCHREALTIME/./}
  out=$(cd "$P" && CLAUDE_PROJECT_DIR="$P" timeout 30 bash "$H/guard.sh" < "$O/in-$C" 2>/dev/null); rc=$?
  ms=$(( (${EPOCHREALTIME/./} - t0) / 1000 )); (( ms > maxms )) && maxms=$ms
  d=$(grep -o '"permissionDecision"' <<< "$out" | wc -l)
  mal=''
  (( ms > 5000 )) && { cue=$((cue + 1)); mal="cuelgue"; }
  if (( d > 1 )); then dob=$((dob + 1)); mal="$mal doble"
  elif [ -z "$esp" ]; then (( d == 0 )) && [ "$rc" = 0 ] || { desp=$((desp + 1)); mal="$mal deny-espurio"; }
  elif (( d == 0 )); then aesp=$((aesp + 1)); mal="$mal allow-espurio"
  elif [[ $out != *'"permissionDecision":"deny"'* || $out != *"$esp"* ]]; then otro=$((otro + 1)); mal="$mal otro-motivo"; fi
  [ -z "$mal" ] || { echo "  it=$i rc=$rc ms=$ms docs=$d:$mal"; printf '%s\n' "$out" > "$O/out-$C.$i"; }
done
echo "== $(basename "$A") $C n=$N s=$((SECONDS - t_ini)) max_ms=$maxms dobles=$dob cuelgues=$cue deny_espurios=$desp allow_espurios=$aesp otro_motivo=$otro"
