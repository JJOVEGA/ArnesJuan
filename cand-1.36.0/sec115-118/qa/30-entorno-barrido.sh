#!/usr/bin/env bash
# 30-entorno-barrido.sh <hooksdir> <salida> [lista-de-variables] — CA-68 (ii) (P-136-N): para cada variable que leen hooks/*.sh
# (lista: 30-vars.txt), exportada con cada valor de VALS, la decisión de 9 vectores por guard.sh debe ser la
# misma que sin ella. Imprime una línea por (variable, valor, vector) que DIFIERE de la base (decisión o
# los primeros 50 caracteres del motivo), más la base.
set -u
QD="$(cd "$(dirname "$0")" && pwd)"; HD="$1"; OUT="$2"
W="${TMPDIR:-/tmp}/qa6-barrido-$$"; mkdir -p "$W"
. "$QD/h.sh"
P="$W/p"; mkp "$P"
in_write src/a.ts 'x' > "$W/v1"
in_edit src/a.ts 'orig' 'nuevo' > "$W/v2"
in_bash 'echo x > src/a.ts' > "$W/v3"
in_bash 'git reset --hard' > "$W/v4"
in_write requirements/REQ-900.md "$(printf '# REQ-900\nEstado: completado\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\n\n## Texto\nx\n')" > "$W/v5"
in_bash "sed -i 's/en-revisión/completado/' requirements/REQ-900.md" > "$W/v6"
in_write src/a.ts 'x' desarrollador > "$W/v7"
in_bash 'ls -la' > "$W/v8"
in_edit requirements/REQ-900.md 'QA: pendiente' 'QA: quizas' > "$W/v9"
# vector 10: Write relativo con un cwd que no existe -> deny (no se puede anclar)
jq -cn --arg c "$P/no-existe" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"echo x > src/a.ts"}}' > "$W/v10"
VECS="v1 v2 v3 v4 v5 v6 v7 v8 v9 v10"
fp() { local r; r="$(corre "$HD" guard.sh "$W/$1" "${@:2}")"; IFS='|' read -r d rc ms b m <<< "$r"; printf '%s|%s|%s' "$d" "$rc" "${m:0:50}"; }
declare -A BASE
{ echo "# base, hooks=$HD, $(date -Is)"; for v in $VECS; do BASE[$v]="$(fp $v)"; echo "BASE $v ${BASE[$v]}"; done; } > "$OUT"
VALS=(1 0 fin x / "$P/no-existe" desarrollador)
n=0; nd=0
while IFS= read -r var; do
  case "$var" in BASH_SOURCE|BASHPID|PWD|_|BASH_REMATCH|SECONDS|DIR|LC_ALL|LC_CTYPE|LANG|CLAUDE_PROJECT_DIR|CR) continue ;; esac
  for val in "${VALS[@]}"; do
    for v in $VECS; do
      n=$((n+1)); r="$(fp $v "$var=$val")"
      if [ "$r" != "${BASE[$v]}" ]; then nd=$((nd+1)); echo "DIFIERE $var=$val $v: base=[${BASE[$v]}] con=[$r]" >> "$OUT"; fi
    done
  done
done < "${3:-$QD/30-vars.txt}"
echo "# fin $(date -Is): $n combinaciones, $nd diferencias" >> "$OUT"
rm -rf "$W"
