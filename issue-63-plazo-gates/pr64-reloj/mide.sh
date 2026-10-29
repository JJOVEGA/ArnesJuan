#!/usr/bin/env bash
# mide.sh: medición dirigida de REQ-033 RELOJ CA-06 pedida por el propietario tras el CI del PR #64 (run 40897033461).
# Lanzada por la coordinadora fuera de los agentes, con la máquina en reposo. Mínimo de 10 corridas por rama y árbol,
# con los árboles alternados en cada ronda. Las entradas son las de la sección 49 del banco (ramas49).
set -u
R=/home/juan/dev/ArnesJuan-1.36.3; D=$(cd "$(dirname "$0")" && pwd); N=10
ARBOLES=(v1.36.1 v1.36.2 hotfix/1.36.3)
rm -rf "$D/arb" "$D/p"; mkdir -p "$D/arb"
for a in "${ARBOLES[@]}"; do d="$D/arb/${a//\//_}"; mkdir -p "$d"; git -C "$R" archive "$a" hooks | tar -x -C "$d"; done
# El proyecto: el de la sección 49 (MANIFIESTO_BASE con globs hooks/* y src/*, sin git).
P="$D/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/tests" "$P/docs" "$P/hooks"
jq '.codigo_app.globs = ["hooks/*", "src/*"]' > "$P/.arnes/config.json" <<'EOF'
{ "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] }, "quality_gates": [],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements", "pending_approval": "PENDING_APPROVAL.md" }
EOF
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf 'l\n' > "$P/hooks/lib.sh"; printf 'p\n' > "$P/docs/PLAN.md"; printf 'n\n' > "$P/docs/notas.md"
M="$P/.arnes/config.json"; MC="$(cat "$M")"
jb() { jq -cn --arg c "$P" --arg k "$1" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}}'; }
jw() { jq -cn --arg c "$P" --arg f "$M" --arg t "$1" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$f,content:$t},agent_id:"a49",agent_type:"desarrollador"}'; }
jb 'ls -la' > "$D/e1.json"; jb 'mv hooks/lib.sh docs/PLAN.md' > "$D/e2.json"; jw "$MC" > "$D/e3.json"; jw '' > "$D/e4.json"
RAMAS=("e1|camino común" "e2|mv con origen protegido" "e3|Write del manifiesto con contenido" "e4|Write vacío del manifiesto")
echo "# $(date -Is) · bash $BASH_VERSION · $(nproc) núcleos · carga $(cut -d' ' -f1-3 /proc/loadavg)"
for a in "${ARBOLES[@]}"; do echo "# $a = $(git -C "$R" rev-parse --short "$a^{commit}")"; done
for r in "${RAMAS[@]}"; do
  e="${r%%|*}"; nom="${r#*|}"; declare -A T=()
  # la decisión de cada árbol, para constatar que miden lo mismo
  dec=''; for a in "${ARBOLES[@]}"; do h="$D/arb/${a//\//_}/hooks"
    o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" bash "$h/guard.sh" < "$D/$e.json" 2>/dev/null)"
    case "$o" in *'"deny"'*) dec+="$a=deny " ;; *) dec+="$a=allow " ;; esac; done
  for ((i = 0; i < N; i++)); do
    for a in "${ARBOLES[@]}"; do h="$D/arb/${a//\//_}/hooks"
      t0=${EPOCHREALTIME/./}; (cd "$P" && CLAUDE_PROJECT_DIR="$P" bash "$h/guard.sh" < "$D/$e.json" >/dev/null 2>&1); t1=${EPOCHREALTIME/./}
      T[$a]+="$(( t1 - t0 )) "
    done
  done
  echo "== $nom  [$dec]"
  for a in "${ARBOLES[@]}"; do
    s=$(tr ' ' '\n' <<< "${T[$a]}" | grep . | sort -n); mn=$(head -1 <<< "$s"); md=$(sed -n "$(( (N + 1) / 2 ))p" <<< "$s")
    eval "MIN_${a//[^a-z0-9]/_}=$mn"
    printf '   %-14s min %6d µs  mediana %6d µs  (%s)\n' "$a" "$mn" "$md" "$(tr '\n' ' ' <<< "$s")"
  done
  awk -v c="$MIN_hotfix_1_36_3" -v b2="$MIN_v1_36_2" -v b1="$MIN_v1_36_1" 'BEGIN{printf "   cociente de mínimos: candidato/v1.36.2 %.3f×  candidato/v1.36.1 %.3f×  v1.36.2/v1.36.1 %.3f×\n", c/b2, c/b1, b2/b1}'
  unset T
done
echo "# fin $(date -Is) · carga $(cut -d' ' -f1-3 /proc/loadavg)"
