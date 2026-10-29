#!/usr/bin/env bash
# normal.sh — (4): el cierre legítimo sigue en allow y el tiempo de un árbol normal no cambia. Proyecto = copia del
# árbol de este repositorio en 6dde1a1 (git archive), gate `true`, verde de la herramienta de la candidata (el hash
# es el mismo en d89316c: 03-). N cierres alternados candidata / d89316c.
set -u
Q=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/qa-s151
D=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/issue-63-f13724-qa-pasada/arb/d89316c
N=${1:-21}; P=$Q/w/p-repo; rm -rf "$P"; mkdir -p "$P"
git -C /home/juan/dev/ArnesJuan-1.36.3 archive 6dde1a1 | tar -x -C "$P"
jq '.quality_gates=["true"]' "$P/.arnes/config.json" > "$P/m.tmp" && mv "$P/m.tmp" "$P/.arnes/config.json"
mkdir -p "$P/requirements"; printf '# REQ-901 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-901.md"
printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
(cd "$P" && git init -q && git add -A && git -c user.name=q -c user.email=q@x commit -qm b)
(cd "$P" && bash "$Q/arb/tools/arnes-gates.sh" --quien qa-tester >/dev/null 2>&1); echo "herramienta rc=$? archivos=$(git -C "$P" ls-files | wc -l)"
in=$(jq -cn --arg fp "$P/requirements/REQ-901.md" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}')
declare -A t=() dec=()
for ((i = 0; i < N; i++)); do for a in C D; do
  case $a in C) h=$Q/arb/hooks;; D) h=$D/hooks;; esac
  t0=${EPOCHREALTIME/./}; o=$(cd "$P" && CLAUDE_PROJECT_DIR="$P" bash "$h/guard.sh" <<< "$in" 2>/dev/null); t[$a]+="$(( ${EPOCHREALTIME/./} - t0 )) "
  [ -z "$o" ] && dec[$a]+=a || dec[$a]+=d
done; done
echo "# cierre legítimo en un árbol normal, N=$N alternados, $(date -Is), loadavg $(cut -d' ' -f1-3 /proc/loadavg)"
for a in C D; do
  read -r mn md <<< "$(tr ' ' '\n' <<< "${t[$a]}" | grep . | sort -n | awk '{v[NR]=$1} END{printf "%.1f %.1f", v[1]/1000, v[int((NR+1)/2)]/1000}')"
  case $a in C) n=candidata;; D) n=d89316c;; esac
  echo "$n: allow=$(tr -cd a <<< "${dec[$a]}" | wc -c)/$N deny=$(tr -cd d <<< "${dec[$a]}" | wc -c) min=$mn mediana=$md ms"
done
