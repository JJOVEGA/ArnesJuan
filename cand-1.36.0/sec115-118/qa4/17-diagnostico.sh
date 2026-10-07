#!/usr/bin/env bash
# 17-diagnostico.sh <salida> <hooksdir> — AÑADIDO DESPUÉS de ver 16- y 22- (no estaba en 00-; no repite ninguna corrida
# ni sustituye a ninguna): (a) atribuir las 3 diferencias de «SIETE» en los guardianes sueltos; (b) el coste de las 12
# palabras añadidas al unset -f de entrada.sh, frente a la lista de 39e6128, en 20 000 vueltas en modo POSIX.
set -u
QA=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa; OUT="$1"; HD="$2"
W="${TMPDIR:-/tmp}/qa4-diag-$$"; mkdir -p "$W"; . "$QA/h.sh"; P="$W/p"; mkp "$P"
in_write src/a.ts 'x' > "$W/v1"; in_bash 'git reset --hard' > "$W/v4"
in_write requirements/REQ-900.md "$(printf '# REQ-900\nEstado: completado\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\n\n## Texto\nx\n')" > "$W/v5"
c() { local g="$1" f="$2" o rc; shift 2; o="$(cd "$P" && env -u LC_ALL -u POSIXLY_CORRECT -u BASH_ENV LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P" "$@" timeout 10 bash "$HD/$g" < "$f" 2>/dev/null)"; rc=$?
  case "$o" in *'"permissionDecision":"deny"'*) echo "deny|rc=$rc" ;; '') echo "nada|rc=$rc" ;; *) echo "otra|rc=$rc" ;; esac; }
fx() { local a=(); for n in "$@"; do a+=("BASH_FUNC_${n}%%=() { return 0; }"); done; printf '%s\0' "${a[@]}"; }
{ echo "# $(date -Is) (a) guardianes sueltos, cuerpos return 0"
for gv in guard-codigo.sh:v1 guard-git.sh:v4 guard-completado.sh:v5; do g="${gv%%:*}"; v="${gv#*:}"
  for combo in "" "set" "return" "set return" "return exit break continue shift :" "return exit break continue set shift :"; do
    mapfile -d '' -t A < <(fx $combo); echo "$gv [${combo:-ninguna}] $(c "$g" "$W/$v" "${A[@]}")"; done; done
echo "# (b) coste del unset -f: lista de 39e6128 (63 nombres) frente a la del candidato (75), 20000 vueltas, 3 alternadas"
L39='builtin shopt printf read [ test echo local declare typeset type command cd pwd true false kill mapfile readarray let wait hash enable getopts umask source jq grep git readlink realpath mktemp cat tail head sed awk tr cut sort wc find ls cp mv rm ln mkdir dirname basename stat date sleep touch chmod tee cmp iconv timeout env sh bash'
LC="return exit break continue set shift : eval trap unset exec . $L39"
for r in 1 2 3; do for L in "$L39" "$LC"; do n=$(wc -w <<<"$L")
  t=$( { TIMEFORMAT=%R; time bash -c 'POSIXLY_CORRECT=y; for ((i=0;i<20000;i++)); do unset -f '"$L"'; done' ; } 2>&1 )
  echo "rep=$r nombres=$n 20000 vueltas: ${t}s"; done; done
} > "$OUT"; rm -rf "$W"
