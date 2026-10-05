#!/usr/bin/env bash
# esc-corre.sh <hooks> <corpus NUL> [techo] -> por comando: rc y destinos (escapados), de arnes_bash_escrituras
H="$1"; C="$2"
. "$H/lib.sh"
[ -n "${3:-}" ] && { ARNES_MANIFEST_LISTO=1; ARNES_BASH_MAX="$3"; }
mapfile -d '' -t K < "$C"
for k in "${K[@]}"; do
  o="$(arnes_bash_escrituras "$k")"; rc=$?
  printf '%s\t%q\n' "$rc" "$o"
done
