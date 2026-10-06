#!/usr/bin/env bash
# 34-localvar-inherit.sh <hooksdir> <salida> <lista> — CA-68 (ii): BASHOPTS=localvar_inherit (que solo, en qa/33-, no cambia nada)
# COMBINADA con una variable de nombre de local exportada: con esa opción `local x` hereda el valor de `x` del entorno.
# 8 vectores por guard.sh, valores 0, 1, x. Una línea por diferencia con la base (que lleva también localvar_inherit).
set -u
QA=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa; HD="$1"; OUT="$2"
W="${TMPDIR:-/tmp}/qa2-lvi-$$"; mkdir -p "$W"; . "$QA/h.sh"; P="$W/p"; mkp "$P"
in_write src/a.ts 'x' > "$W/v1"; in_bash 'echo x > src/a.ts' > "$W/v3"; in_bash 'git reset --hard' > "$W/v4"
in_write requirements/REQ-900.md "$(printf '# REQ-900\nEstado: completado\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\n\n## Texto\nx\n')" > "$W/v5"
in_bash "sed -i 's/en-revisión/completado/' requirements/REQ-900.md" > "$W/v6"; in_bash 'ls -la' > "$W/v8"
in_edit requirements/REQ-900.md 'QA: pendiente' 'QA: quizas' > "$W/v9"
jq -cn --arg c "$P/no-existe" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"echo x > src/a.ts"}}' > "$W/v10"
VECS="v1 v3 v4 v5 v6 v8 v9 v10"
fp() { local r; r="$(corre "$HD" guard.sh "$W/$1" BASHOPTS=localvar_inherit "${@:2}")"; IFS='|' read -r d rc ms b m <<< "$r"; printf '%s|%s|%s' "$d" "$rc" "${m:0:50}"; }
declare -A BASE; { echo "# base con BASHOPTS=localvar_inherit, hooks=$HD, $(date -Is)"; for v in $VECS; do BASE[$v]="$(fp $v)"; echo "BASE $v ${BASE[$v]}"; done; } > "$OUT"
n=0; nd=0
while IFS= read -r var; do for val in 0 1 x; do for v in $VECS; do n=$((n+1)); r="$(fp $v "$var=$val")"
  [ "$r" = "${BASE[$v]}" ] || { nd=$((nd+1)); echo "DIFIERE $var=$val $v: base=[${BASE[$v]}] con=[$r]" >> "$OUT"; }
done; done; done < "$3"
echo "# fin $(date -Is): $n combinaciones, $nd diferencias" >> "$OUT"; rm -rf "$W"
