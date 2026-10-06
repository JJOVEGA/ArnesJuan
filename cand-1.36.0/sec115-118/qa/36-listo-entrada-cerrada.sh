#!/usr/bin/env bash
# 36-listo-entrada-cerrada.sh <scratch> <hooks>... — CA-68 (ii), medida de QA-007-07: con ARNES_INPUT_LISTO=1 (y con
# ARNES_MANIFEST_LISTO=1) exportada, el hook invocado con la entrada estándar CERRADA da deny como sin ella, por
# guard.sh y por los tres guardianes sueltos; y `ls -la` legible sin decisión (control).
set -u; S="$1"; shift; QD="$(cd "$(dirname "$0")" && pwd)"; . "$QD/h.sh"; P="$S/plisto"; mkp "$P"; in_bash 'ls -la' > "$S/ls.in"
echo "# $(date -Is)"
for H in "$@"; do for g in guard.sh guard-codigo.sh guard-completado.sh guard-git.sh; do for e in X=1 ARNES_INPUT_LISTO=1 ARNES_MANIFEST_LISTO=1 "ARNES_INPUT_LISTO=1 ARNES_MANIFEST_LISTO=1"; do
  o="$(cd "$P" && env -u LC_ALL LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P" $e timeout 60 bash "$H/$g" <&- 2>/dev/null)"; rc=$?
  case "$o" in *'"permissionDecision":"deny"'*) d=deny ;; '') d=nada ;; *) d=otra ;; esac
  printf '%-28s %-20s %-46s cerrada: %s rc=%s | ls: %s\n' "${H#/home/juan/dev/}" "$g" "$e" "$d" "$rc" "$(corre "$H" "$g" "$S/ls.in" $e | cut -d'|' -f1-2)"
done; done; done
