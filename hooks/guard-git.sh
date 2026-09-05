#!/usr/bin/env bash
# guard-git.sh — los agentes no ejecutan git destructivo.
#
# POR QUE EXISTE. Medido en un proyecto real: ~52 archivos de trabajo sin comitear se
# perdieron en un incidente. Y el trabajo de un subagente NO es atomico para git:
# mientras escribe, el arbol contiene estados intermedios que no son de nadie — ni
# suyos ni del ultimo commit. Un `git clean`, un `reset --hard` o un `checkout .` los
# borra sin dejar rastro, y quien lo ejecuta suele estar arreglando OTRA cosa. El
# alijo (`stash`) es la misma familia: esconde trabajo que despues nadie recuerda
# recuperar, y ninguna mutacion de pruebas debe guardarse ahi.
#
# ES UNA BARANDILLA, Y ES UNA LISTA. La trae el arnes por defecto y el proyecto la
# amplia o la apaga en el manifiesto (`git.prohibidos`, `git.activo`). Se sabe que una
# lista enumerada se pudre; aqui se acepta porque el coste de un falso negativo es el
# mismo que hoy (nada) y el de un falso positivo es una linea en el manifiesto.
#
# Mira el comando SIN su texto (heredocs y comillas fuera): `git commit -m "no uses
# git clean"` no es un `git clean`. Y no paga jq si el comando no menciona `git`.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

# ⚠️ "permitir" se dice con `return 0`, NUNCA con `exit 0`: este guardian corre en el
# mismo proceso que los otros dos y un `exit` los dejaria sin correr — fallo abierto.
arnes_guard_git() {
  arnes_parse_input
  [ "$ARNES_TOOL" = "Bash" ] || return 0
  [[ "$ARNES_CMD" == *git* ]] || return 0      # barato y primero: un `ls` no paga el manifiesto
  arnes_parse_manifest
  [ "$ARNES_GIT_ACTIVO" = "true" ] || return 0
  [ -n "$ARNES_GIT_PROHIBIDOS" ] || return 0

  local limpio seg sub regla i n k ok
  local -a t reglas args palabras
  IFS=$'\t' read -r -a reglas <<< "$ARNES_GIT_PROHIBIDOS"
  arnes_bash_sin_texto "$ARNES_CMD"; limpio="$ARNES_SIN_TEXTO"
  # Cada orden por separado: operadores, sustituciones y subshells se vuelven saltos de
  # linea, y se juzga el PRIMER token de cada orden. Asi `cd x && git clean -fd` y
  # `(git reset --hard)` se ven, y `echo git clean` no.
  limpio="${limpio//&&/$'\n'}"; limpio="${limpio//||/$'\n'}"; limpio="${limpio//|/$'\n'}"
  limpio="${limpio//;/$'\n'}";  limpio="${limpio//\$(/$'\n'}"; limpio="${limpio//\`/$'\n'}"
  limpio="${limpio//(/$'\n'}";  limpio="${limpio//)/$'\n'}"   # `(git reset --hard)`: el `)` pegado al token lo escondia

  local reponer_f=0; case $- in *f*) reponer_f=1 ;; esac
  set -f
  while IFS= read -r seg; do
    # shellcheck disable=SC2206  -- se quiere el word splitting, con globbing apagado
    t=($seg); n=${#t[@]}; [ "$n" -gt 0 ] || continue
    i=0
    while [ "$i" -lt "$n" ]; do
      case "${t[i]}" in *=*|sudo|command|exec|time|nice|env|builtin) i=$((i+1)) ;; *) break ;; esac
    done
    case "${t[i]:-}" in git|*/git|git.exe) ;; *) continue ;; esac
    i=$((i+1))
    # Opciones globales antes del subcomando: `-C ruta`, `-c k=v`, `--git-dir=...`, `--no-pager`.
    while [ "$i" -lt "$n" ]; do
      case "${t[i]}" in -C|-c) i=$((i+2)) ;; -*) i=$((i+1)) ;; *) break ;; esac
    done
    sub="${t[i]:-}"; [ -n "$sub" ] || continue
    args=("${t[@]:i+1}")
    for regla in "${reglas[@]}"; do
      [ -n "$regla" ] || continue
      # Una regla es "subcomando [token token...]": el subcomando tiene que ser ESE, y
      # cada token tiene que aparecer entre los argumentos, exacto (`--hard`, `.`).
      # shellcheck disable=SC2206
      palabras=($regla)
      [ "${palabras[0]}" = "$sub" ] || continue
      ok=1
      for ((k = 1; k < ${#palabras[@]}; k++)); do
        arnes_tiene_token "${palabras[k]}" ${args[@]+"${args[@]}"} || { ok=0; break; }
      done
      [ "$ok" -eq 1 ] || continue
      # Tres matices que evitan falsos positivos conocidos, y solo esos tres:
      # `stash list|show` no esconde nada; `restore --staged` solo des-indexa;
      # `clean -n|--dry-run` solo enseña lo que borraria.
      case "$sub" in
        stash)   case "${args[0]:-}" in list|show) continue ;; esac ;;
        restore) if arnes_tiene_token --staged ${args[@]+"${args[@]}"} && ! arnes_tiene_token --worktree ${args[@]+"${args[@]}"}; then continue; fi ;;
        clean)   if arnes_tiene_token -n ${args[@]+"${args[@]}"} || arnes_tiene_token --dry-run ${args[@]+"${args[@]}"}; then continue; fi ;;
      esac
      [ "$reponer_f" -eq 1 ] || set +f
      arnes_deny "ARNES: 'git $sub ${args[*]}' descarta o esconde trabajo que puede no ser tuyo: con agentes en vuelo el arbol contiene estados intermedios de otros, y esta orden los borra sin dejar rastro. La prohibe el manifiesto (git.prohibidos: '$regla'). Si hace falta de verdad, que la ejecute el humano fuera de la sesion; para retirar la regla, edita .arnes/config.json a sabiendas."
    done
  done <<< "$limpio"
  [ "$reponer_f" -eq 1 ] || set +f
  return 0
}

arnes_tiene_token() {  # <token> <args...> -> 0 si algun argumento es exactamente el token
  local buscado="$1" a; shift
  for a in "$@"; do [ "$a" = "$buscado" ] && return 0; done
  return 1
}

# Ejecutado directamente (no `source`): hace su propio preludio y corre.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  arnes_preludio || exit 0
  arnes_guard_git
  exit 0
fi
