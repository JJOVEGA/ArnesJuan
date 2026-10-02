#!/usr/bin/env bash
# sonda-raiz-desde-cwd.sh — sin CLAUDE_PROJECT_DIR la raíz sale del `cwd` (arnes_project_dir, otra lectura,
# sin transporte de CR). Solo se OBSERVA: CA-47 punto 11 la deja fuera, y esta comisión no la toca.
set -u
. "$(dirname "$0")/lib-r7.sh"
nuevo_proyecto; mkdir -p "$F/d"; ln -s "$P" "$F/d$CR"
for k in "${ORDEN[@]}"; do
  out="$(j Bash "$F/d$CR" - 'command=echo x > src/a.ts' | env -u CLAUDE_PROJECT_DIR bash "${ARB[$k]}/guard.sh" 2>/dev/null)"
  case "$out" in *'"deny"'*) d=deny ;; *) d=allow ;; esac
  printf 'sin CLAUDE_PROJECT_DIR, cwd <fuera>/d␍ (enlace a la raíz), echo x > src/a.ts: %-8s %s  %s\n' "$k" "$d" "$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" | cut -c1-150)"
done
rm -rf "$T"
