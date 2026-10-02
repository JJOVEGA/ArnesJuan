#!/usr/bin/env bash
# P2 del registro previo (informativo, NO un criterio): copia de evidencia-qa-sec119/sonda-ca54-qa.sh con
# un unico cambio: los arboles (base = 3bc7d3c, candidato = el worktree). Mismo material, techos y forma.
EV8=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8
BASE=$EV8/arb/01b4a59/hooks; CAND=/home/juan/dev/ArnesJuan-v1.35/hooks; Q=$EV8
MANIF='{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}'
mkproj() { mkdir -p "$1/.arnes" "$1/requirements" "$1/src" "$1/docs"; printf '%s\n' "$MANIF" > "$1/.arnes/config.json"; printf '## Pendientes\n\n## Resueltas\n' > "$1/PENDING_APPROVAL.md"; printf 'x\n' > "$1/src/a.ts"; }
N="${N:-5}"
echo "== P2 sonda CA-54 (informativo) $(date -Iseconds); loadavg $(cut -d' ' -f1-3 /proc/loadavg); sha256 lib.sh cand $(sha256sum < "$CAND/lib.sh" | cut -c1-16) base $(sha256sum < "$BASE/lib.sh" | cut -c1-16) =="
for techo in 65536 131072; do
  P="$Q/ca54-$techo"; rm -rf "$P"; mkproj "$P"
  jq --argjson t "$techo" '.limites.bash_max_analisis = $t' <<< "$MANIF" > "$P/.arnes/config.json"
  for forma in A B C; do
    cmd=''; i=0
    while [ "${#cmd}" -lt $(( techo - 60 )) ]; do
      case $forma in A) cmd+="echo x > f$i; " ;; B) cmd+="echo x > d$i/f; " ;; C) cmd+="echo x > docs/../f$i; " ;; esac
      i=$((i+1))
    done
    printf '%s' "$cmd" | jq -Rs --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:.}}' > "$Q/ca54-$techo-$forma.json"
    for h in "$BASE" "$CAND"; do CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/guard.sh" < "$Q/ca54-$techo-$forma.json" >/dev/null 2>&1; done
    lb=''; lc=''
    for ((k = 1; k <= N; k++)); do
      for h in "$BASE" "$CAND"; do
        t0=${EPOCHREALTIME/./}; o="$(CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$h/guard.sh" < "$Q/ca54-$techo-$forma.json" 2>/dev/null)"; rc=$?; t1=${EPOCHREALTIME/./}
        case "$o" in *'"deny"'*) d=deny ;; *) d=allow ;; esac
        ms=$(( (t1 - t0) / 1000 ))
        if [ "$h" = "$BASE" ]; then lb+=" ${ms}($d,rc$rc)"; else lc+=" ${ms}($d,rc$rc)"; fi
      done
    done
    echo "techo=$techo forma=$forma bytes=${#cmd} destinos=$i | 3bc7d3c ms:$lb | candidato ms:$lc | carga=$(cut -d' ' -f1-3 /proc/loadavg)"
  done
done
rm -rf "$Q"/ca54-*
