#!/usr/bin/env bash
# Casos del spike 1.37 · 3a. Proyectos efímeros; la orden corre DE VERDAD entre el Pre y el Post simulados.
set -u
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
SPIKE=/home/juan/dev/ArnesJuan-spike-1.37-3
PP="$SPIKE/hooks/puerta-posterior.sh"
V136="$S/v1362/hooks"          # hooks de v1.36.2: columna «hoy»
export TMPDIR="$S/estado"; mkdir -p "$TMPDIR"
n=0

nuevo_proyecto() {   # <dir> [sin-manifiesto]
  rm -rf "$1"; mkdir -p "$1/.arnes" "$1/src" "$1/docs"
  cp -a "$SPIKE/hooks" "$1/hooks"                      # hooks/ del tamaño real
  [ "${2:-}" = sin-manifiesto ] || cp "$SPIKE/.arnes/config.json" "$1/.arnes/config.json"
  printf 'x\n' > "$1/x"
  git -C "$1" init -q && git -C "$1" add -A && git -C "$1" -c user.email=a@b -c user.name=a commit -qm base
  rm -rf "$1.orig"; cp -a "$1" "$1.orig"
}
json() {   # <proj> <agente> <orden> <tid>
  jq -cn --arg c "$3" --arg a "$2" --arg p "$1" --arg t "$4" \
    '{session_id:"s1", tool_use_id:$t, tool_name:"Bash", cwd:$p, tool_input:{command:$c}}
     + (if $a == "" then {} else {agent_type:$a, agent_id:"ag1"} end)'
}
vigilado_igual() {   # <proj> -> 0 si .arnes/config.json y hooks/ coinciden con el original
  diff -rq "$1.orig/hooks" "$1/hooks" >/dev/null 2>&1 || return 1
  if [ -e "$1.orig/.arnes/config.json" ]; then cmp -s "$1.orig/.arnes/config.json" "$1/.arnes/config.json" || return 1
  else [ ! -e "$1/.arnes/config.json" ] || return 1; fi
}
caso() {   # <etiqueta> <agente> <orden> [sin-manifiesto]
  local et="$1" ag="$2" ord="$3" P="$S/p/caso" tid hoy salida rc tocado restaurado
  n=$((n+1)); tid="toolu_$n"
  nuevo_proyecto "$P" "${4:-}"
  hoy="$(json "$P" "$ag" "$ord" "$tid" | CLAUDE_PROJECT_DIR="$P" bash "$V136/guard.sh" 2>/dev/null \
         | jq -r '.hookSpecificOutput.permissionDecision // "allow"' 2>/dev/null)"
  [ -n "$hoy" ] || hoy="allow (inerte)"
  json "$P" "$ag" "$ord" "$tid" | CLAUDE_PROJECT_DIR="$P" bash "$PP" pre 2>/dev/null
  (cd "$P" && bash -c "$ord" >/dev/null 2>&1); rc=$?
  vigilado_igual "$P" && tocado=no || tocado=sí
  salida="$(json "$P" "$ag" "$ord" "$tid" | CLAUDE_PROJECT_DIR="$P" bash "$PP" post 2>/dev/null)"
  vigilado_igual "$P" && restaurado=sí || restaurado=no
  printf '| %s | %s | `%s` | rc %s | %s | %s | %s | %s |\n' "$et" "${ag:-coordinadora}" "$ord" "$rc" "$hoy" "$tocado" \
    "$( [ -n "$salida" ] && jq -r .decision <<< "$salida" || echo '—')" "$restaurado"
}

printf '| Caso | Agente | Orden | rc orden | v1.36.2 Pre | ¿cambió lo vigilado? | Post | ¿vigilado = antes al final? |\n|---|---|---|---|---|---|---|---|\n'
caso SEC-135 qa-tester 'cp x hooks/lib.sh 2>/dev/null'
caso SEC-135 qa-tester '\cp x hooks/lib.sh'
caso SEC-135 "" 'cp x hooks/lib.sh 2>/dev/null'
caso SEC-136 qa-tester 'rm hooks/guard.sh'
caso SEC-137 qa-tester 'mv hooks h2'
caso SEC-138 qa-tester "printf '{}' > .arnes/config.json"
caso SEC-138 qa-tester 'cp /dev/null .arnes/config.json'
caso SEC-138 qa-tester "python3 -c \"open('.arnes/config.json','w').write('{}')\""
caso PR-137-2 qa-tester "python3 -c \"open('hooks/lib.sh','a').write('#x')\""
caso PR-137-2 qa-tester "perl -e 'open(F,\">>hooks/lib.sh\"); print F \"#x\"'"
caso 'cp -p + touch -r' qa-tester 'cp hooks/lib.sh /tmp/l.$$ && printf "#x" >> hooks/lib.sh && touch -r /tmp/l.$$ hooks/lib.sh'
caso 'orden que falla' qa-tester 'cp x hooks/lib.sh; false'
caso 'agente_codigo reescrito' qa-tester "printf '{\"agentes\":{\"agente_codigo\":\"qa-tester\"}}' > .arnes/config.json"
caso 'sin manifiesto + ataque' qa-tester 'cp x hooks/lib.sh' sin-manifiesto
caso 'manifiesto y hooks a la vez' qa-tester 'rm .arnes/config.json && rm hooks/guard.sh'
caso CONTROL desarrollador "printf '#x' >> hooks/lib.sh"
caso CONTROL arnes-juan:desarrollador 'rm hooks/guard.sh'
caso 'FP ls' qa-tester 'ls'
caso 'FP git status' qa-tester 'git status'
caso 'FP cat' qa-tester 'cat hooks/lib.sh'
caso 'FP src' qa-tester 'printf y > src/a.js'
caso 'FP docs' "" "python3 -c \"open('docs/n.md','w').write('n')\""
caso 'FP? cambio de rama' "" 'git checkout -q -b otra && cp x hooks/x.sh && git add -A && git -c user.email=a@b -c user.name=a commit -qm c && git checkout -q - && git checkout -q otra'
caso 'FP? git checkout sin cambio' "" 'git checkout -q -b otra2 && git checkout -q -'
