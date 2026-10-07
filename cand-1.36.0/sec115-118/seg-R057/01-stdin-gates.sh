#!/usr/bin/env bash
# R-057: ¿una quality gate que lee su entrada estándar consume la lista de gates restantes? (c5bf6d4 = HEAD y v1.35.0)
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r057
export S
. "$S/h.sh"
H_CAND=/home/juan/dev/ArnesJuan-v1.36/hooks
H_V135=/home/juan/dev/ArnesJuan-v1.35.0-base/hooks
caso() { # <nombre> <gates...>
  local n="$1"; shift
  for H in cand:$H_CAND v135:$H_V135; do
    local P="$S/p-$n-${H%%:*}"; [ -e "$P" ] && mv "$P" "$P.viejo.$$"
    proyecto "$P" "$@" >/dev/null 2>&1
    printf '%-28s %-5s e-900: %s' "$n" "${H%%:*}" "$(corre "${H#*:}" "$P" e-900)"
    printf '%-28s %-5s estado en disco tras la llamada: %s\n' "" "" "$(grep -m1 '^Estado:' "$P/requirements/REQ-900.md")"
  done
}
echo "# control: una sola gate roja"
caso control-roja 'false'
echo "# control: gate verde que no lee stdin, luego roja"
caso verde-luego-roja 'true' 'false'
echo "# gate verde que LEE stdin (cat), luego roja"
caso cat-luego-roja 'cat >/dev/null' 'false'
echo "# gate verde que lee una linea (read), luego roja"
caso read-luego-roja 'read -r x; true' 'false'
echo "# gate verde con un programa que lee stdin por defecto (sh -s sin script: lee ordenes de stdin)"
caso sh-s-luego-roja 'sh -s' 'false'
echo "# control: misma gate con </dev/null explicito, luego roja"
caso cat-devnull-luego-roja 'cat >/dev/null </dev/null' 'false'
