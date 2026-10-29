#!/usr/bin/env bash
# reloj.sh — las ramas de reloj de REQ-033 CA-06 (sección 49) a mano: candidata (6dde1a1 = f900a98), d89316c (antes de
# SEC-151) y v1.36.1 (referencia de la sección), alternadas, N por árbol. Mide guard.sh con la entrada de cada rama.
set -u
Q=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/qa-s151
D=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/issue-63-f13724-qa-pasada/arb/d89316c
V=$Q/arb-v1361; [ -d "$V/hooks" ] || { mkdir -p "$V"; git -C /home/juan/dev/ArnesJuan-1.36.3 archive v1.36.1 hooks | tar -x -C "$V"; }
N=${1:-31}; P=$Q/w/p-reloj; rm -rf "$P"; mkdir -p "$P/.arnes" "$P/hooks" "$P/docs"
jq -n '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["hooks/*"]},quality_gates:[]}' > "$P/.arnes/config.json"
echo x > "$P/hooks/lib.sh"; echo y > "$P/docs/PLAN.md"; (cd "$P" && git init -q && git add -A && git -c user.name=q -c user.email=q@x commit -qm b)
bashin() { jq -cn --arg c "$1" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$cwd,tool_input:{command:$c}}'; }
echo "# reloj REQ-033 a mano, N=$N, $(date -Is), loadavg $(cut -d' ' -f1-3 /proc/loadavg)"
for rama in 'rm .arnes/config.json' 'mv hooks/lib.sh docs/PLAN.md' 'ls -la'; do
  in=$(bashin "$rama"); declare -A t=()
  for ((i = 0; i < N; i++)); do
    for a in C D V; do
      case $a in C) h=$Q/arb/hooks;; D) h=$D/hooks;; V) h=$V/hooks;; esac
      t0=${EPOCHREALTIME/./}; (cd "$P" && CLAUDE_PROJECT_DIR="$P" bash "$h/guard.sh" <<< "$in" >/dev/null 2>&1); t[$a]+="$(( ${EPOCHREALTIME/./} - t0 )) "
    done
  done
  for a in C D V; do
    read -r mn md <<< "$(tr ' ' '\n' <<< "${t[$a]}" | grep . | sort -n | awk '{v[NR]=$1} END{printf "%.1f %.1f", v[1]/1000, v[int((NR+1)/2)]/1000}')"
    case $a in C) n=candidata;; D) n=d89316c;; V) n=v1.36.1;; esac; echo "[$rama] $n min=$mn mediana=$md ms"
  done
  unset t
done
