#!/usr/bin/env bash
# SEC-129: codigo de salida y lista de `arnes_escrituras_de` (el detector que comparten guard-codigo y
# guard-completado) en modo normal y en modo POSIX, a nivel de libreria. Y que hace guard-git tras el error.
# Uso: 04-rc-detector.sh <arbol-hooks>...
for h in "$@"; do
  for m in normal posix; do
    r=$( { [ $m = posix ] && export POSIXLY_CORRECT=1; bash -c '
      . "$1/lib.sh" 2>/dev/null
      for c in "echo x > src/a.ts" "sed -i s/a/completado/ requirements/R.md" "echo ñ > src/a.ts"; do
        if declare -F arnes_escrituras_de >/dev/null; then arnes_escrituras_de "$c"; rc=$?; out=$ARNES_ESCRITURAS
        else out=$(arnes_bash_escrituras "$c"); rc=$?; fi
        printf "  [%s] rc=%s lista=<%s>\n" "$c" "$rc" "${out//$'"'"'\n'"'"'/,}"
      done' _ "$h" 2>&1; } )
    printf '%s %s\n%s\n' "$h" "$m" "$r"
  done
done
