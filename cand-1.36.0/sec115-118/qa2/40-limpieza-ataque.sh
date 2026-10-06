#!/usr/bin/env bash
# 40-limpieza-ataque.sh <salida> <nombre=hooksdir>... — QA-007-11 (a): funciones importadas homónimas de las órdenes
# que corren ANTES o DENTRO de la limpieza de entrada.sh (y del preludio de cada punto de entrada), por guard.sh y
# por los guardianes sueltos. Una corrida por punto. Compara con la base sin la función.
set -u
QA=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa; OUT="$1"; shift
W="${TMPDIR:-/tmp}/qa2-limp-$$"; mkdir -p "$W"; . "$QA/h.sh"; P="$W/p"; mkp "$P"
in_write src/a.ts 'x' > "$W/v1"; in_bash 'echo x > src/a.ts' > "$W/v3"; in_bash 'git reset --hard' > "$W/v4"
in_write requirements/REQ-900.md "$(printf '# REQ-900\nEstado: completado\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\n\n## Texto\nx\n')" > "$W/v5"
in_bash 'ls -la' > "$W/v8"; in_edit requirements/REQ-900.md 'QA: pendiente' 'QA: quizas' > "$W/v9"
G="guard.sh:v1 guard.sh:v3 guard.sh:v4 guard.sh:v5 guard.sh:v8 guard.sh:v9 guard-codigo.sh:v1 guard-git.sh:v4 guard-completado.sh:v5"
NOMBRES='[ . source builtin set shopt unset read printf exit trap test true local declare eval command return case cat dirname'
CUERPOS=('return0:() { return 0; }' 'return1:() { return 1; }' 'exit0:() { exit 0; }')
# (corrección del 41a-: los cuerpos se partían por blancos y ninguna función llegaba a importarse)
{ echo "# $(date -Is) bash $BASH_VERSION"
for spec in "$@"; do n="${spec%%=*}"; HD="${spec#*=}"
  declare -A BASE=()
  for gv in $G; do g="${gv%%:*}"; v="${gv#*:}"; BASE[$gv]="$(corre "$HD" "$g" "$W/$v" | cut -d'|' -f1,2,5 | cut -c1-70)"; echo "$n BASE $gv ${BASE[$gv]}"; done
  nd=0; nc=0
  for f in $NOMBRES; do for cb in "${CUERPOS[@]}"; do cn="${cb%%:*}"; body="${cb#*:}"
    for gv in $G; do g="${gv%%:*}"; v="${gv#*:}"; nc=$((nc+1))
      r="$(corre "$HD" "$g" "$W/$v" "BASH_FUNC_${f}%%=$body" | cut -d'|' -f1,2,5 | cut -c1-70)"
      [ "$r" = "${BASE[$gv]}" ] || { nd=$((nd+1)); echo "$n DIFIERE [BASH_FUNC_${f}%%=$cn] $gv: base=[${BASE[$gv]}] con=[$r]"; }
    done; done; done
  echo "# $n: $nc combinaciones, $nd diferencias"
done; } > "$OUT"
rm -rf "$W"
