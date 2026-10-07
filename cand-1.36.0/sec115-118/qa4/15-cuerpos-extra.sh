#!/usr/bin/env bash
# 15-cuerpos-extra.sh <salida> <nombre=hooksdir>... — QA-007-14 sobre c5bf6d4: los 11 especiales de la lista (salvo '.', F-136-20) con 4 cuerpos no medidos, y los 7 de P-136-R exportados a la vez.
# USA y que la lista estática de entrada.sh NO retira (builtins especiales: protegidos sólo mientras dura el modo POSIX),
# controles de la lista con cuerpos nuevos (rc 2, escribir en stdout, imprimir un "allow"), y nombres raros. 9 vectores de
# qa2/40-. timeout 10 s (el techo de CA-68 es 5 s; lo que pasa de 5 s es cuelgue). Una corrida.
set -u
QA=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa; OUT="$1"; shift
W="${TMPDIR:-/tmp}/qa4-ext-$$"; mkdir -p "$W"; . "$QA/h.sh"; P="$W/p"; mkp "$P"
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
  case "$o" in *atacante*) d="$d+atacante" ;; esac
  [ -z "$o" ] || jq -e . >/dev/null 2>&1 <<<"$o" || d="$d+json-roto"
  local ms=$(( (t1-t0)/1000 )); local lento=''; [ $ms -ge 5000 ] && lento=" LENTO ${ms}ms"
  printf '%s|rc=%s%s\n' "$d" "$rc" "$lento"
}
NOMBRES='return exit break continue set shift : eval trap unset exec'
ALLOW='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
DENY='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"atacante"}}'
CUERPOS=('bucle:() { while true; do true; done; }' 'kill9:() { kill -9 $$; }' "deny:() { echo '$DENY'; return 0; }" 'bexit0:() { builtin exit 0; }')
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
  echo "== $n los 7 de P-136-R exportados a la vez, return 0 =="
  SIETE=(); for f in return exit break continue set shift :; do SIETE+=("BASH_FUNC_${f}%%=() { return 0; }"); done
  for gv in $G; do g="${gv%%:*}"; v="${gv#*:}"; r="$(c3 "$HD" "$g" "$W/$v" "${SIETE[@]}")"; m=igual; [ "$r" = "${BASE[$gv]}" ] || m=DIFIERE; echo "$n SIETE $gv base=[${BASE[$gv]}] con=[$r] $m"; done
done; } > "$OUT"
rm -rf "$W"
