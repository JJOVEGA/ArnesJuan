#!/usr/bin/env bash
# 42-nombres-y-proc.sh <hooksdir> <copia-dir> — QA-007-11 (a): (1) nombres raros de BASH_FUNC_*; (2) /proc/self/environ ilegible,
# simulado EN UNA COPIA de hooks/ con la ruta cambiada a una inexistente (nunca en el árbol). Una corrida por punto.
set -u
QA=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa; HD="$1"; CP="$2"
W="${TMPDIR:-/tmp}/qa2-nom-$$"; mkdir -p "$W"; . "$QA/h.sh"; P="$W/p"; mkp "$P"
in_write src/a.ts 'x' > "$W/v1"; in_bash 'git reset --hard' > "$W/v4"
echo "# $(date -Is)"
echo "== (1) nombres raros, Write de la coordinadora a src/a.ts (base: deny) =="
corre "$HD" guard.sh "$W/v1" | sed 's/^/base: /'
for nm in 'jq' $'j\nq' 'a%%b' 'jq%%x' '-f' '*' 'jq ' ' jq' "$(printf 'x%.0s' {1..5000})" 'git' 'cat' 'grep' 'mktemp' 'read' 'printf'; do
  r=$(corre "$HD" guard.sh "$W/v1" "BASH_FUNC_${nm}%%=() { return 0; }"); printf '[%q] %s\n' "${nm:0:20}" "$r"; done
echo "== (1b) dos entradas BASH_FUNC_jq%% (duplicada en el entorno) =="
corre "$HD" guard.sh "$W/v1" 'BASH_FUNC_jq%%=() { return 0; }' 'BASH_FUNC_jq%%=() { return 0; }'
echo "== (2) copia con /proc/self/environ inexistente =="
rm -rf "$CP"; mkdir -p "$CP"; cp -r "$HD" "$CP/hooks"; cp -r "$HD/../tools" "$CP/tools"
sed -i 's|< /proc/self/environ|< /proc/self/no-existe-qa2|' "$CP/hooks/entrada.sh"; grep -c 'no-existe-qa2' "$CP/hooks/entrada.sh"
for e in '' 'BASH_FUNC_jq%%=() { return 0; }' 'BASH_FUNC_printf%%=() { return 0; }' 'FUNCNEST=1' 'SHELLOPTS=keyword'; do
  for v in v1 v4; do r=$(corre "$CP/hooks" guard.sh "$W/$v" ${e:+"$e"}); echo "[${e:-sin}] $v $r"; done; done
rm -rf "$W"
