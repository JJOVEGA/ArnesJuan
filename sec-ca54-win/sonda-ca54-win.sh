#!/usr/bin/env bash
# Sonda de QA para REQ-007 CA-54, ADAPTADA para Windows/MSYS (séptima autorización, punto 4).
# Cambios frente a evidencia-qa-sec119/sonda-ca54-qa.sh, y sólo éstos: (1) el `source` de qa-lib.sh se sustituye
# por las cuatro definiciones que usa (Q, MANIF, mkproj, BASE/CAND) con rutas de Windows; (2) sólo el techo
# 131072 (el caso máximo). Formas, calentamiento, N=5 alternadas, timeout 60, reloj y salida, idénticos.
Q=/c/Users/JVega/AppData/Local/Temp/arnes-ca54-r7/salida
BASE=/c/Users/JVega/AppData/Local/Temp/arnes-ca54-r7/base/hooks
CAND=/c/Users/JVega/AppData/Local/Temp/arnes-ca54-r7/cand/hooks
MANIF='{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}'
mkproj() {   # <dir>
  mkdir -p "$1/.arnes" "$1/requirements" "$1/src" "$1/docs"
  printf '%s\n' "$MANIF" > "$1/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$1/PENDING_APPROVAL.md"
  printf 'x\n' > "$1/src/a.ts"
}
N="${N:-5}"
for techo in 131072; do
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
    echo "techo=$techo forma=$forma bytes=${#cmd} destinos=$i | 9596e39 ms:$lb | candidato ms:$lc | carga=$(cut -d' ' -f1-3 /proc/loadavg)"
  done
done
