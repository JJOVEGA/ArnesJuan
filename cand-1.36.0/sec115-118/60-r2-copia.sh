#!/usr/bin/env bash
# Fase 2, CA-68 (i) por finales que NO vienen del modo POSIX (la matriz de la sección 47 no los ejerce): fallos
# INYECTADOS en COPIAS de los hooks del candidato, nunca en el árbol. Por cada copia, la decisión por guard.sh:
#   F1  `arnes_guard_git` abandonada a mitad por una expansión que aborta la orden (indirecta inválida)
#   F2  el analizador de escrituras devuelve un código fuera de su vocabulario (7)
#   F3  el proceso termina por `set -u` (variable sin definir) dentro de `arnes_guard_completado`
#   F4  `arnes_deny` no consigue que jq escriba la decisión (jq sustituido por una orden inexistente)
# y los controles sin fallo: `ls -la` y un Write a docs/ (sin decisión), y un proyecto sin manifiesto (inerte).
# Uso: 60-r2-copia.sh <scratch> <candidato/hooks>
set -u
S="${1:?}"; H="${2:?}"; W="$(mktemp -d "$S/r2-XXXX")"; trap 'rm -rf "$W"' EXIT
P="$W/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs" "$W/sinarnes"
jq -nc '{agentes:{agente_codigo:"desarrollador"},codigo_app:{globs:["src/*"]},quality_gates:["true"],estados:{completado:"completado"},requirements_dir:"requirements",pending_approval:"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-900\nEstado: en-revision\nQA: pendiente\nSeguridad: pendiente\n' > "$P/requirements/REQ-900.md"
copia() {   # <nombre> <archivo> <sed> -> $W/<nombre>/hooks
  mkdir -p "$W/$1"; cp -r "$H" "$W/$1/hooks"; cp -r "$H/../tools" "$W/$1/tools" 2>/dev/null
  [ -z "$2" ] || sed -i "$3" "$W/$1/hooks/$2"
  [ -z "$2" ] || ! cmp -s "$H/$2" "$W/$1/hooks/$2" || echo "AVISO: la inyección $1 no cambió $2"
}
copia F0 '' ''
copia F1 guard-git.sh '/^arnes_guard_git() {/a\  : "${!ARNES_REFERENCIA_QUE_NO_ES_UN_NOMBRE@@}"'
copia F2 lib.sh '/^arnes_bash_escrituras() {/a\  return 7'
copia F3 guard-completado.sh '/^arnes_guard_completado() {/a\  : "$ARNES_VARIABLE_QUE_NADIE_DEFINE"'
copia F4 lib.sh 's/^  jq -cRs .rtrimstr("\\n") | {hookSpecificOutput/  jq_que_no_existe -cRs '"'"'rtrimstr("\\n") | {hookSpecificOutput/'
e() { jq -cn --arg c "$1" --arg t "$2" --arg x "$3" \
  'if $t == "Bash" then {hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$x}}
   else {hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:($c+"/"+$x),content:"x"}} end'; }
corre() {   # <copia> <proyecto> <herramienta> <objetivo>
  local o rc
  o="$(cd "$2" && export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$2" && e "$2" "$3" "$4" | bash "$W/$1/hooks/guard.sh" 2>/dev/null)"; rc=$?
  case "$o" in *'"permissionDecision":"deny"'*) d=deny ;; '') d=nada ;; *) d=otra ;; esac
  printf '%-3s %-5s %-24s rc=%s dec=%-4s motivo<%s>\n' "$1" "$3" "$4" "$rc" "$d" \
    "$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$o" 2>/dev/null | cut -c1-150)"
}
echo "# $(date -Is); bash $BASH_VERSION; candidato $H"
for c in F0 F1 F2 F3 F4; do
  corre "$c" "$P" Bash 'echo x > src/a.ts'
  corre "$c" "$P" Bash 'git reset --hard'
  corre "$c" "$P" Bash 'ls -la'
  corre "$c" "$P" Write 'docs/n.md'
  corre "$c" "$P" Write 'src/a.ts'
  corre "$c" "$W/sinarnes" Bash 'echo x > src/a.ts'
done
