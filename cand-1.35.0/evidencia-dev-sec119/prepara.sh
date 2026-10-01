#!/usr/bin/env bash
# prepara.sh <dir de hooks reales> <dir envoltorio> <log>
# Crea en <dir envoltorio>/hooks un envoltorio por script que ejecuta el real y registra una linea
# por llamada: script, sha1 del JSON de entrada (sin la ruta del proyecto efimero), decision, motivo.
# Es un instrumento de la comision (fuera del arbol): no forma parte del banco.
set -uo pipefail
real="$1"; env="$2"; log="$3"
rm -rf "$env"; mkdir -p "$env/hooks"
ln -s "$(cd "$real/.." && pwd)/tools" "$env/tools"
ln -s "$(cd "$real/.." && pwd)/templates" "$env/templates" 2>/dev/null || true
for f in "$real"/*.sh "$real"/*.awk "$real"/hooks.json; do
  b="${f##*/}"
  case "$b" in
    guard.sh|guard-codigo.sh|guard-completado.sh|guard-git.sh)
      cat > "$env/hooks/$b" <<EOF
#!/usr/bin/env bash
in="\$(cat)"
out="\$(printf '%s' "\$in" | bash '$real/$b' 2>/dev/null)"
norm="\$(printf '%s' "\$in" | sed -E 's#/tmp/tmp\.[A-Za-z0-9]+/[a-z0-9]+-[0-9]+#<P>#g')"
k="\$(printf '%s' "\$norm" | sha1sum | cut -c1-12)"
case "\$out" in *'"permissionDecision":"deny"'*) d=deny ;; *) d=allow ;; esac
r="\$(printf '%s' "\$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null | cut -c1-90 | tr '\t\n' '  ')"
printf '%s\t%s\t%s\t%s\n' '$b' "\$k" "\$d" "\$r" >> "\${MOTIVOS_LOG:-/dev/null}"
printf '%s' "\$out"
EOF
      chmod +x "$env/hooks/$b" ;;
    *) ln -s "$f" "$env/hooks/$b" ;;
  esac
done
