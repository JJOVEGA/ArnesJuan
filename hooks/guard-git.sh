#!/usr/bin/env bash
# guard-git.sh — ningun agente ejecuta git destructivo.
#
# POR QUE EXISTE. Medido en un proyecto real: ~52 archivos de trabajo SIN COMITEAR se
# perdieron en un incidente. Y la causa de fondo no es el descuido de nadie: EL TRABAJO
# DE UN SUBAGENTE NO ES ATOMICO PARA GIT. Mientras un agente escribe, el arbol contiene
# estados intermedios que no son de nadie —ni suyos ni del ultimo commit—, y otro agente
# que limpia «su» arbol arrasa el del primero. Un `git clean`, un `reset --hard` o un
# `checkout .` los borra sin dejar rastro, y quien los ejecuta suele estar arreglando
# OTRA cosa. El alijo (`stash`) es la misma familia: esconde trabajo que despues nadie
# recuerda recuperar.
#
# ES UNA REGLA DEL COMANDO, NO DE LA IDENTIDAD, y ahi esta la diferencia con
# `guard-codigo`: aquel pregunta QUIEN edita; este, QUE se ejecuta. Alcanza a todos los
# agentes, incluidos el `desarrollador` y la sesion coordinadora. Confundirlas dejaria al
# agente autorizado borrando el trabajo de los demas.
#
# ES UNA BARANDILLA, Y ES UNA LISTA. El arnes trae la lista por defecto y la comparacion;
# el proyecto la cambia o la apaga en su manifiesto (`git.prohibidos`, `git.activo`). Una
# lista enumerada se pudre, y aqui se acepta: el coste de un falso negativo es el de hoy
# (ninguna puerta) y el de un falso positivo es una linea en el manifiesto.
#
# COBERTURA PARCIAL, DICHA EN VOZ ALTA (AGENTS.md 13). Quedan fuera los scripts y los
# interpretes que ejecuten git por su cuenta (`node limpia.mjs`, `make clean`), los alias
# del shell y cualquier programa que invoque git sin que su nombre aparezca en el texto
# del comando. Un hook no puede analizar shell arbitrario de forma fiable, y perseguirlo
# produce falsos positivos que acaban con alguien apagando el guard.
#
# Mira el comando SIN SU TEXTO —con el MISMO descuento de comillas y heredocs que el
# detector de escrituras, no una segunda copia de esa regla—: `git commit -m "no uses git
# clean"` no es un `git clean`. Y no paga `jq` si el comando no menciona `git`.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

# ¿Algun argumento es EXACTAMENTE este token? (`--hard`, `.`, `--staged`, `push`...)
arnes_tiene_token() {   # <token> <args...>
  local buscado="$1" a; shift
  for a in "$@"; do [ "$a" = "$buscado" ] && return 0; done
  return 1
}

# Como `arnes_tiene_token`, pero un FLAG CORTO casa dentro de un grupo de flags cortos.
#
# POR QUE. `git clean -f`, `git clean -fd` y `git clean -ffdx` son el mismo comando
# destructivo, y quien lo escribe elige el grupo. Exigir el token exacto convertiria la
# regla en una lista de variantes que se pudre —`-f`, `-fd`, `-fdx`, `-ffd`...—, que es
# justo lo que este arnes predica no hacer. Se compara por LETRAS: `-f` casa si todas sus
# letras estan en UN grupo corto del comando, y no casa con `-n` ni con `-d` a secas.
# `--dry-run` es una opcion larga y se compara entera, sin descomponer.
arnes_casa_token() {   # <token> <args...>
  local buscado="$1" a letras i
  shift
  case "$buscado" in
    --*|-|'') arnes_tiene_token "$buscado" "$@"; return $? ;;
    -?*)
      letras="${buscado#-}"
      for a in "$@"; do
        case "$a" in
          --*|-) continue ;;
          -?*)
            for ((i = 0; i < ${#letras}; i++)); do
              case "${a#-}" in *"${letras:i:1}"*) ;; *) continue 2 ;; esac
            done
            return 0 ;;
        esac
      done
      return 1 ;;
    *) arnes_tiene_token "$buscado" "$@"; return $? ;;
  esac
}

# ⚠️ "permitir" se dice con `return 0`, NUNCA con `exit 0`: este guardian corre en el
# mismo proceso que los otros dos y un `exit` los dejaria sin correr — fallo abierto.
arnes_guard_git() {
  local limpio seg sub regla i n k ok reponer_f a posicional
  local -a t reglas args palabras

  arnes_parse_input
  [ "$ARNES_TOOL" = "Bash" ] || return 0
  [ -n "$ARNES_CMD" ] || return 0
  # Barato y PRIMERO: un `ls -la` o un `npm test` no llegan a leer el manifiesto ni
  # arrancan `jq`. El camino comun de Bash es el mas frecuente que hay y no puede pagar
  # un proceso por comando.
  [[ "$ARNES_CMD" == *git* ]] || return 0
  arnes_parse_manifest
  [ "${ARNES_GIT_ACTIVO:-}" = "true" ] || return 0
  [ -n "${ARNES_GIT_PROHIBIDOS:-}" ] || return 0      # lista vacia: decision declarada

  # Si el material excede el presupuesto de analisis no se juzga aqui: `guard-codigo` y
  # `guard-completado` ya deniegan ese comando con su motivo (una puerta que no puede
  # medir no deja pasar), y repetir la denegacion aqui solo cambiaria el mensaje.
  arnes_bash_sin_texto "$ARNES_CMD" || return 0
  limpio="$ARNES_SIN_TEXTO"

  IFS=$'\t' read -r -a reglas <<< "$ARNES_GIT_PROHIBIDOS"
  # Cada ORDEN por separado: los operadores, las sustituciones y los subshells se vuelven
  # saltos de linea y se juzga el PRIMER token de cada orden. Asi `cd x && git clean -fd`,
  # `x=$(git stash)` y `(git reset --hard)` se ven, y `echo git clean` no.
  limpio="${limpio//&&/$'\n'}"; limpio="${limpio//||/$'\n'}"; limpio="${limpio//|/$'\n'}"
  limpio="${limpio//;/$'\n'}";  limpio="${limpio//'$('/$'\n'}"; limpio="${limpio//\`/$'\n'}"
  limpio="${limpio//(/$'\n'}";  limpio="${limpio//)/$'\n'}"   # `(git reset --hard)`: el `)` pegado al token lo escondia

  reponer_f=0; case $- in *f*) reponer_f=1 ;; esac
  set -f
  while IFS= read -r seg; do
    # shellcheck disable=SC2206  -- se quiere el word splitting, con globbing apagado
    t=($seg); n=${#t[@]}; [ "$n" -gt 0 ] || continue
    i=0
    # Prefijos que no son el comando: asignaciones de entorno y envoltorios.
    while [ "$i" -lt "$n" ]; do
      case "${t[i]}" in *=*|sudo|command|exec|time|nice|env|builtin) i=$((i+1)) ;; *) break ;; esac
    done
    # `git` como TOKEN de comando, no como subcadena: `github`, `gitk`, `mygit` y `legit`
    # no son git.
    case "${t[i]:-}" in git|*/git|git.exe|*/git.exe) ;; *) continue ;; esac
    i=$((i+1))
    # Opciones globales antes del subcomando: `-C ruta`, `-c k=v`, `--git-dir=...`, `--no-pager`.
    while [ "$i" -lt "$n" ]; do
      case "${t[i]}" in -C|-c) i=$((i+2)) ;; -*) i=$((i+1)) ;; *) break ;; esac
    done
    sub="${t[i]:-}"; [ -n "$sub" ] || continue
    args=("${t[@]:i+1}")
    for regla in ${reglas[@]+"${reglas[@]}"}; do
      [ -n "$regla" ] || continue
      # Una regla es `subcomando [token...]`: el subcomando tiene que ser ESE y cada
      # token aparecer entre los argumentos de ese mismo segmento, exacto y en cualquier
      # posicion (`git reset --hard HEAD~1` y `git reset HEAD~1 --hard` son lo mismo).
      # shellcheck disable=SC2206
      palabras=($regla)
      [ "${palabras[0]}" = "$sub" ] || continue
      ok=1
      for ((k = 1; k < ${#palabras[@]}; k++)); do
        arnes_casa_token "${palabras[k]}" ${args[@]+"${args[@]}"} || { ok=0; break; }
      done
      [ "$ok" -eq 1 ] || continue
      # UNA ENTRADA QUE ES SOLO EL SUBCOMANDO CASA LA FORMA DESNUDA: sin ningun token
      # POSICIONAL detras (los flags no cuentan). `stash` esconde el arbol entero;
      # `stash list` y `stash show` solo lo enseñan, y son el mismo subcomando. Distinguir
      # por la forma —en vez de enumerar las lecturas que hay que perdonar— evita la lista
      # que se pudre: manana `stash export` seria una lectura mas que nadie añadio.
      # Para alcanzar TODAS las formas de un subcomando, la entrada declara su flag
      # (`clean -f`) o la forma concreta (`stash push`).
      if [ "${#palabras[@]}" -eq 1 ]; then
        posicional=0
        for a in ${args[@]+"${args[@]}"}; do
          case "$a" in -*) ;; *) posicional=1; break ;; esac
        done
        [ "$posicional" -eq 0 ] || continue
      fi
      # Un matiz que evita un falso positivo CONOCIDO: `restore --staged` solo saca del
      # indice y no toca el arbol de trabajo, ni siquiera con `.`.
      case "$sub" in
        restore) if arnes_casa_token --staged ${args[@]+"${args[@]}"} && ! arnes_casa_token --worktree ${args[@]+"${args[@]}"}; then continue; fi ;;
      esac
      [ "$reponer_f" -eq 1 ] || set +f
      arnes_deny "ARNES: 'git $sub ${args[*]}' descarta o esconde trabajo que puede no ser tuyo: con varios agentes en vuelo el arbol contiene cambios intermedios de otros, y esta orden los borra sin dejar rastro — git no puede devolver lo que nunca se comiteo. Lo prohibe el manifiesto (git.prohibidos: '$regla'). Como seguir: comitea lo que quieras conservar; si la limpieza hace falta de verdad, que la ejecute el humano fuera de la sesion. Para retirar la regla, edita .arnes/config.json a sabiendas."
    done
  done <<< "$limpio"
  [ "$reponer_f" -eq 1 ] || set +f
  return 0
}

# Ejecutado directamente (no `source`): hace su propio preludio y corre. Produccion y
# banco ejecutan LA MISMA funcion, no dos copias que puedan desfasarse.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  arnes_preludio || exit 0
  arnes_guard_git
  exit 0
fi
