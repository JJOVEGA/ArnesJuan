#!/usr/bin/env bash
# 10-ataque-ampliado.sh <salida> <nombre=hooksdir>... — QA-007-13 sobre 39e6128: funciones importadas con nombres que el hook
# USA y que la lista estática de entrada.sh NO retira (builtins especiales: protegidos sólo mientras dura el modo POSIX),
# controles de la lista con cuerpos nuevos (rc 2, escribir en stdout, imprimir un "allow"), y nombres raros. 9 vectores de
# qa2/40-. timeout 10 s (el techo de CA-68 es 5 s; lo que pasa de 5 s es cuelgue). Una corrida.
set -u
QA=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa; OUT="$1"; shift
W="${TMPDIR:-/tmp}/qa3-amp-$$"; mkdir -p "$W"; . "$QA/h.sh"; P="$W/p"; mkp "$P"
in_write src/a.ts 'x' > "$W/v1"; in_bash 'echo x > src/a.ts' > "$W/v3"; in_bash 'git reset --hard' > "$W/v4"
in_write requirements/REQ-900.md "$(printf '# REQ-900\nEstado: completado\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\n\n## Texto\nx\n')" > "$W/v5"
in_bash 'ls -la' > "$W/v8"; in_edit requirements/REQ-900.md 'QA: pendiente' 'QA: quizas' > "$W/v9"
G="guard.sh:v1 guard.sh:v3 guard.sh:v4 guard.sh:v5 guard.sh:v8 guard.sh:v9 guard-codigo.sh:v1 guard-git.sh:v4 guard-completado.sh:v5"
c3() { # c3 <hd> <g> <f> [env...] -> decision[+allow][+json-roto]|rc|tiempo
  local hd="$1" g="$2" f="$3" o rc t0 t1 d; shift 3; t0=${EPOCHREALTIME/./}
  o="$(cd "$P" && env -u LC_ALL -u POSIXLY_CORRECT -u BASH_ENV LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P" "$@" timeout 10 bash "$hd/$g" < "$f" 2>/dev/null)"; rc=$?
  t1=${EPOCHREALTIME/./}
  case "$o" in *'"permissionDecision":"deny"'*) d=deny ;; *'"systemMessage"'*) d=aviso ;; '') d=nada ;; *) d=otra ;; esac
  case "$o" in *'"allow"'*) d="$d+allow" ;; esac
  [ -z "$o" ] || jq -e . >/dev/null 2>&1 <<<"$o" || d="$d+json-roto"
  local ms=$(( (t1-t0)/1000 )); local lento=''; [ $ms -ge 5000 ] && lento=" LENTO ${ms}ms"
  printf '%s|rc=%s%s\n' "$d" "$rc" "$lento"
}
NOMBRES='return break continue eval exec exit export readonly set shift times trap unset : jq printf read builtin mktemp git'
ALLOW='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
CUERPOS=('return0:() { return 0; }' 'return1:() { return 1; }' 'return2:() { return 2; }' 'exit0:() { exit 0; }' "allow:() { echo '$ALLOW'; return 0; }")
{ echo "# $(date -Is) bash $BASH_VERSION"
for spec in "$@"; do n="${spec%%=*}"; HD="${spec#*=}"
  declare -A BASE=()
  for gv in $G; do g="${gv%%:*}"; v="${gv#*:}"; BASE[$gv]="$(c3 "$HD" "$g" "$W/$v")"; echo "$n BASE $gv ${BASE[$gv]}"; done
  nd=0; nc=0
  for f in $NOMBRES; do for cb in "${CUERPOS[@]}"; do cn="${cb%%:*}"; body="${cb#*:}"
    for gv in $G; do g="${gv%%:*}"; v="${gv#*:}"; nc=$((nc+1))
      r="$(c3 "$HD" "$g" "$W/$v" "BASH_FUNC_${f}%%=$body")"
      [ "$r" = "${BASE[$gv]}" ] || { nd=$((nd+1)); echo "$n DIFIERE [BASH_FUNC_${f}%%=$cn] $gv: base=[${BASE[$gv]}] con=[$r]"; }
    done; done; done
  echo "# $n: $nc combinaciones, $nd diferencias"
  echo "== $n nombres raros (Write a src/a.ts y ls -la por guard.sh) =="
  for nm in 'jq=' 'a b' $'j\nq' 'jq%%x' '-f' '--' '*' 'jq ' ' jq' '\\jq' '/usr/bin/jq' 'é' "$(printf 'r%.0s' {1..3000})"; do
    for v in v1 v8; do printf '%s [%q] %s %s\n' "$n" "${nm:0:20}" "$v" "$(c3 "$HD" guard.sh "$W/$v" "BASH_FUNC_${nm}%%=() { return 0; }")"; done; done
  for v in v1 v8; do echo "$n [jq=() sin %%, forma pre-shellshock] $v $(c3 "$HD" guard.sh "$W/$v" 'jq=() { return 0; }')"; done
  for v in v1 v8; do echo "$n [BASH_FUNC_jq%% duplicada] $v $(c3 "$HD" guard.sh "$W/$v" 'BASH_FUNC_jq%%=() { return 0; }' 'BASH_FUNC_jq%%=() { return 0; }')"; done
done; } > "$OUT"
rm -rf "$W"
