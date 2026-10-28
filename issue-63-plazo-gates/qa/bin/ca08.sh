#!/usr/bin/env bash
# ca08.sh <tag> <base-dir> <evidencia-out-prefix>
# Una corrida: plugin limpio del tag (git archive), proyecto desechable con el cierre legítimo y la gate `sleep 700`,
# cliente real `claude -p` (Edit de Estado: en-revisión -> completado). Observa el hook con un vigía por PID.
set -u
TAG="$1"; B="$2"; OUT="$3"; REPO=/home/juan/dev/ArnesJuan-1.36.3
rm -rf "$B"; mkdir -p "$B/plugin" "$B/proj"
git -C "$REPO" archive "$TAG" | tar -x -C "$B/plugin"
P="$B/proj"; mkdir -p "$P/requirements" "$P/.arnes" "$P/src"
jq -n '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:["sleep 700"]}' > "$P/.arnes/config.json"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
( cd "$P" && git init -q && git add -A && git -c user.email=x@x -c user.name=x commit -qm base )
T0=$(date +%s)
echo "tag=$TAG commit=$(git -C "$REPO" rev-parse "$TAG^{commit}") cli=$(claude --version) uname=$(uname -sr) bash=$BASH_VERSION t0=$T0 $(date -Is)" > "$OUT.meta"
PROMPT='Usa la herramienta Edit (no Bash, no Write) exactamente una vez: en el archivo requirements/REQ-001.md reemplaza la línea "Estado: en-revisión" por "Estado: completado". No hagas nada más, no leas otros archivos, y cuando termine la llamada responde sólo con OK o con el error recibido.'
( cd "$P" && timeout 1500 claude -p "$PROMPT" --plugin-dir "$B/plugin" --model sonnet --permission-mode acceptEdits \
    --output-format stream-json --verbose --include-hook-events --max-budget-usd 1 --settings '{"enabledPlugins":{"arnes-juan@arnes-juan":false}}' --debug-file "$OUT.debug.log" \
    > "$OUT.stream.jsonl" 2> "$OUT.stderr" ) &
CP=$!
# vigía: cada segundo, procesos guard.sh y el sleep 700 con cwd en el proyecto
while kill -0 "$CP" 2>/dev/null; do
  now=$(( $(date +%s) - T0 ))
  g=$(pgrep -f "$B/plugin/hooks/guard" | tr '\n' ',')
  s=''; for p in $(pgrep -x sleep); do [ "$(readlink /proc/$p/cwd 2>/dev/null)" = "$P" ] && s+="$p,"; done
  echo "$now guard=[$g] gate=[$s]"
  sleep 1
done > "$OUT.vigia.txt"
wait "$CP"; echo "claude_rc=$? t_fin=$(( $(date +%s) - T0 ))" >> "$OUT.meta"
echo "--- REQ-001 en disco al terminar:" >> "$OUT.meta"; sed -n 2p "$P/requirements/REQ-001.md" >> "$OUT.meta"
( cd "$P" && git diff --stat ) >> "$OUT.meta"
# limpieza acotada: sólo los `sleep` cuyo cwd es ESTE proyecto
for p in $(pgrep -x sleep); do [ "$(readlink /proc/$p/cwd 2>/dev/null)" = "$P" ] && { echo "huérfano sleep pid=$p (se mata)" >> "$OUT.meta"; kill "$p"; }; done
