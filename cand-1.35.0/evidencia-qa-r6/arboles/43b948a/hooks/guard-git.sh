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

# Como `arnes_tiene_token`, pero un FLAG casa ESCRITO EN CUALQUIERA DE SUS DOS FORMAS.
#
# POR QUE. `git clean -f`, `git clean -fd` y `git clean -ffdx` son el mismo comando
# destructivo, y quien lo escribe elige el grupo. Exigir el token exacto convertiria la
# regla en una lista de variantes que se pudre —`-f`, `-fd`, `-fdx`, `-ffd`...—, que es
# justo lo que este arnes predica no hacer. Se compara por LETRAS: `-f` casa si todas sus
# letras estan en UN grupo corto del comando, y no casa con `-n` ni con `-d` a secas.
#
# Y LA FORMA LARGA CASA IGUAL QUE LA CORTA (QA-101, medido en la vuelta 1 de 1.31.0). La
# version anterior saltaba explicitamente todo argumento que empezara por `--`, asi que
# `git clean --force` —que borra exactamente lo mismo que `git clean -f`— atravesaba la
# puerta; y al reves, una regla escrita `push --force` no veia `git push -f`. No son dos
# comandos: son dos ortografias del MISMO flag, y el proyecto que teclea una no puede
# quedarse sin la otra. Se resuelve CANONICALIZANDO los dos lados —regla y comando— antes
# de comparar, no duplicando cada entrada de la lista.
#
# FIN DE OPCIONES (`--`). Lo que va detras de `--` es un pathspec, no una opcion: en
# `git clean -- --force`, `--force` es el NOMBRE DE UN ARCHIVO. Un flag deja de buscarse
# ahi; un token literal (`.`, `push`) se sigue buscando en todo el segmento, porque ese si
# puede ser un pathspec —y `git checkout -- .` arrasa el arbol igual.
arnes_casa_token() {   # <token> <args...>
  local buscado="$1" a letras i canon
  shift
  case "$buscado" in
    -*) arnes_git_canon "$buscado"; buscado="$ARNES_TOK" ;;
  esac
  case "$buscado" in
    -|'') arnes_tiene_token "$buscado" "$@"; return $? ;;
    --*)
      # Opcion larga sin equivalencia corta conocida: se compara ENTERA, y tambien en su
      # forma con valor pegado (`--source=HEAD~1` sigue siendo `--source`).
      for a in "$@"; do
        [ "$a" = "--" ] && break
        case "$a" in "$buscado"|"$buscado"=*) return 0 ;; esac
      done
      return 1 ;;
    -?*)
      letras="${buscado#-}"
      for a in "$@"; do
        [ "$a" = "--" ] && break
        case "$a" in
          --*) arnes_git_canon "$a"; canon="$ARNES_TOK"
               # Larga sin equivalencia declarada: no se descompone en letras. Traducir
               # por parecido —la inicial del nombre— haria que `-d` casara `--dry-run`.
               case "$canon" in --*) continue ;; esac ;;
          -?*) canon="$a" ;;
          *)   continue ;;
        esac
        for ((i = 0; i < ${#letras}; i++)); do
          case "${canon#-}" in *"${letras:i:1}"*) ;; *) continue 2 ;; esac
        done
        return 0
      done
      return 1 ;;
    *) arnes_tiene_token "$buscado" "$@"; return $? ;;
  esac
}

# ORTOGRAFIA DE UNA OPCION: la forma larga, traducida a su letra corta.
#
# QUE EQUIVALENCIAS SE RECONOCEN, Y POR QUE ESTAS. Solo las que son un HECHO de git, no
# una suposicion:
#
#   - `--force`≡`-f` y `--dry-run`≡`-n` valen en TODO git (clean, checkout, push, branch,
#     rm, mv, tag...). Por eso no se anotan por subcomando: son la regla, no la excepcion.
#   - Las demas dependen del subcomando, y ahi se anotan con el: LA MISMA LETRA significa
#     cosas distintas en dos subcomandos —`-d` es `--directory` en `clean` y `--delete` en
#     `branch`—. Deducir la letra de la inicial del nombre largo seria peor que no saberla:
#     una regla `clean -d` casaria `--dry-run` y la puerta denegaria una SIMULACION. Se
#     prefiere no conocer una equivalencia (falso negativo, la conducta de siempre) a
#     inventarla (falso positivo, que acaba con alguien apagando el guard).
#
# Una opcion larga que no este aqui se compara entera, como antes: lo que no esta en la
# tabla NO CASA, y eso es declarado, no accidental (REQ-005 CA-21.2). Anadir una linea es
# barato y no toca ninguna regla del proyecto —la equivalencia vive en el MOTOR, no en la
# lista, para que valga tambien para el `git.prohibidos` propio de cada proyecto—, y cada
# entrada nueva entra con SU caso en el banco: una equivalencia que nadie mide es una
# afirmacion, no un mecanismo.
#
# LIMITE DECLARADO: un token de regla con VARIAS letras (`clean -fd`) sigue exigiendo que
# todas esten en un mismo grupo (CA-21), y una opcion larga es un grupo de una sola letra;
# `clean -fd` no casa `git clean --force -d`. Declara un flag por token —`clean -f`, que es
# lo que trae la lista por defecto— y el limite no te alcanza.
arnes_git_canon() {   # <token de opcion> -> ARNES_TOK
  local t
  # `--force=algo`: git admite el valor pegado con `=` y la opcion sigue siendo esa. El
  # corte solo se aplica a las largas: un argumento corto nunca lleva `=` en su nombre.
  case "$1" in --*) t="${1%%=*}" ;; *) t="$1" ;; esac
  case "$t" in
    --force)   t='-f' ;;
    --dry-run) t='-n' ;;
    --*)
      case "${ARNES_GIT_SUB:-} $t" in
        'clean --directory')         t='-d' ;;
        'stash --include-untracked') t='-u' ;;
        'stash --all')               t='-a' ;;
        'restore --staged')          t='-S' ;;
        'restore --worktree')        t='-W' ;;
      esac ;;
  esac
  ARNES_TOK="$t"
}

# ALIAS DE SUBCOMANDO: `git stash save` es `git stash push` escrito con el nombre viejo.
#
# POR QUE ESTA EN EL MOTOR Y NO EN LA LISTA POR DEFECTO (QA-101). Anadir `stash save` a
# `git.prohibidos` seria otra variante en una lista que ya se pudre, y —lo decisivo— un
# proyecto que declare su PROPIA lista la perderia sin enterarse: la lista es del proyecto
# y la ortografia de git no. Aqui la equivalencia vale para cualquier lista.
#
# QUE SE RECONOCE: solo `stash save`, que git desaconseja desde 2.13 (2017) y sigue
# funcionando, y que esconde el arbol exactamente igual que `stash push`. `switch` y
# `restore` NO estan: no son alias de `checkout`, son comandos distintos con semantica
# propia, y un proyecto que quiera prohibirlos los declara en su lista.
arnes_git_alias_sub() {   # <subcomando> <primer argumento> -> ARNES_TOK (el argumento, ya canonico)
  ARNES_TOK="$2"
  case "$1 $2" in 'stash save') ARNES_TOK='push' ;; esac
}

# ⚠️ "permitir" se dice con `return 0`, NUNCA con `exit 0`: este guardian corre en el
# mismo proceso que los otros dos y un `exit` los dejaria sin correr — fallo abierto.
arnes_guard_git() {
  local limpio seg sub regla i n k ok reponer_f a posicional vistos motivo_extra=''
  local -a t reglas args palabras

  arnes_parse_input
  [ "$ARNES_TOOL" = "Bash" ] || return 0
  [ -n "$ARNES_CMD" ] || return 0
  # Barato y PRIMERO: un `ls -la` o un `npm test` no llegan a leer el manifiesto ni
  # arrancan `jq`. El camino comun de Bash es el mas frecuente que hay y no puede pagar
  # un proceso por comando.
  [[ "$ARNES_CMD" == *git* ]] || return 0
  arnes_parse_manifest
  # SEC-010 — UN MANIFIESTO ILEGIBLE NO PUEDE APAGAR ESTA PUERTA.
  #
  # Con el manifiesto roto `ARNES_GIT_ACTIVO` queda vacia (el fail-closed de SEC-005 en las
  # variables) y esta puerta PERMITIA: medido, `git clean -fd` pasaba justo mientras el
  # aviso decia que toda escritura se deniega. Peor aun, en un proyecto plantilla
  # `.arnes/config.json` no esta protegido, asi que la unica puerta encendida por defecto
  # tenia un interruptor de apagado alcanzable en UNA escritura, y por accidente: una coma
  # de mas. Aqui manda el principio rector — una puerta que no puede medir no deja pasar —,
  # asi que se cae a la lista que trae el CODIGO y se deniega, diciendo que es modo
  # degradado y cual es la salida.
  #
  # ALCANCE, dicho en voz alta: esto alcanza tambien a un proyecto que tuviera
  # `git.activo: false` y se le rompa el manifiesto. Pasara a denegar, que es la direccion
  # segura: apagar la puerta es un acto explicito y un JSON roto no lo es. La salida es
  # reparar el manifiesto, que es la unica escritura que la averia deja pasar.
  if [ "${ARNES_MANIFEST_ROTO:-0}" = "1" ]; then
    # (el motivo lo dice; no hace falta otra bandera)
    ARNES_GIT_ACTIVO=true
    ARNES_GIT_PROHIBIDOS="$ARNES_GIT_PROHIBIDOS_DEFECTO"
    motivo_extra=" MODO DEGRADADO: '.arnes/config.json' existe y no se puede leer como objeto JSON, asi que no se sabe que declaro este proyecto y se aplica la LISTA POR DEFECTO del arnes, no la suya. Salida: corrige el JSON ('jq -e . .arnes/config.json') — reparar el manifiesto es la unica escritura que la averia deja pasar —; si de verdad quieres esta puerta apagada, declaralo con 'git.activo: false' en un manifiesto legible."
  else
    [ "${ARNES_GIT_ACTIVO:-}" = "true" ] || return 0
    [ -n "${ARNES_GIT_PROHIBIDOS:-}" ] || return 0    # lista vacia: decision declarada
  fi

  # Si el material excede el presupuesto de analisis no se juzga aqui: `guard-codigo` y
  # `guard-completado` ya deniegan ese comando con su motivo (una puerta que no puede
  # medir no deja pasar), y repetir la denegacion aqui solo cambiaria el mensaje.
  arnes_bash_sin_texto "$ARNES_CMD" || return 0
  limpio="$ARNES_SIN_TEXTO"

  IFS=$'\t' read -r -a reglas <<< "$ARNES_GIT_PROHIBIDOS"
  # LA CONTINUACION DE LINEA SE PLIEGA ANTES DE PARTIR (SEC-009). `\` + salto no separa
  # nada: es UN comando escrito en dos renglones. Sin plegarlo, `git clean \<salto> -fd`
  # se leia como dos ordenes —`git clean` y `-fd`— y ninguna casaba la regla `clean -f`.
  limpio="${limpio//\\$'\n'/ }"
  # Cada ORDEN por separado: los operadores, las sustituciones y los subshells se vuelven
  # saltos de linea y se juzga el PRIMER token de cada orden. Asi `cd x && git clean -fd`,
  # `x=$(git stash)` y `(git reset --hard)` se ven, y `echo git clean` no.
  limpio="${limpio//&&/$'\n'}"; limpio="${limpio//||/$'\n'}"; limpio="${limpio//|/$'\n'}"
  limpio="${limpio//;/$'\n'}";  limpio="${limpio//'$('/$'\n'}"; limpio="${limpio//\`/$'\n'}"
  limpio="${limpio//(/$'\n'}";  limpio="${limpio//)/$'\n'}"   # `(git reset --hard)`: el `)` pegado al token lo escondia
  # EL `&` SENCILLO TAMBIEN SEPARA ORDENES (SEC-009), y por eso va DESPUES de `&&`: en
  # `sleep 0 & git clean -fd` hay dos comandos, y el segundo no se veia porque el segmento
  # entero empezaba por `sleep`. Rompe de paso `2>&1` en dos trozos, y eso es inocuo: los
  # trozos no son `git` y ninguna regla los alcanza.
  limpio="${limpio//&/$'\n'}"

  reponer_f=0; case $- in *f*) reponer_f=1 ;; esac
  set -f
  while IFS= read -r seg; do
    # shellcheck disable=SC2206  -- se quiere el word splitting, con globbing apagado
    t=($seg); n=${#t[@]}; [ "$n" -gt 0 ] || continue
    i=0; vistos=0
    # Prefijos que no son el comando: asignaciones de entorno, envoltorios y PALABRAS
    # RESERVADAS del shell (SEC-009).
    #
    # POR QUE LAS RESERVADAS. `if true; then git clean -fd; fi` parte bien por el `;`, pero
    # el segmento resultante empieza por `then` — que no es `git` ni un prefijo tolerado—,
    # asi que el segmento se descartaba ENTERO y el comando mas ordinario del mundo
    # atravesaba la puerta. Lo mismo con `{ … }`, con `do … done` y con `!`. Ninguna de
    # esas palabras puede ser el comando: son andamiaje, y saltarlas solo puede hacer que
    # la puerta MIRE donde antes no miraba. Una limpieza condicional se escribe asi.
    #
    # Y LAS OPCIONES Y LOS NUMEROS, SOLO DETRAS DE UN ENVOLTORIO (`vistos > 0`): `timeout
    # 30 git clean -fd` necesita saltar el `30`, pero un segmento que EMPIEZA por un numero
    # o por una opcion no es una llamada a git envuelta, y tolerarlo de entrada ensancharia
    # el reconocimiento sin ninguna forma medida que lo pida.
    while [ "$i" -lt "$n" ]; do
      case "${t[i]}" in
        *=*|sudo|command|exec|time|nice|ionice|env|builtin|nohup|setsid|stdbuf|doas|xargs|timeout) ;;
        then|else|elif|do|done|fi|esac|in|if|while|until|for|case|select|function|'{'|'}'|'!'|'[['|'((') ;;
        -*|[0-9]*) [ "$vistos" -gt 0 ] || break ;;
        *) break ;;
      esac
      i=$((i+1)); vistos=$((vistos+1))
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
    # El subcomando manda en la ortografia de sus opciones (`-d` no significa lo mismo en
    # `clean` que en `branch`), asi que viaja en una variable que `arnes_git_canon` lee.
    ARNES_GIT_SUB="$sub"
    # El nombre viejo del subcomando de segundo nivel se traduce al vigente ANTES de
    # comparar: `git stash save "wip"` esconde el arbol igual que `git stash push`.
    if [ "${#args[@]}" -gt 0 ]; then
      arnes_git_alias_sub "$sub" "${args[0]}"; args[0]="$ARNES_TOK"
    fi
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
      arnes_deny "ARNES: 'git $sub ${args[*]}' descarta o esconde trabajo que puede no ser tuyo: con varios agentes en vuelo el arbol contiene cambios intermedios de otros, y esta orden los borra sin dejar rastro — git no puede devolver lo que nunca se comiteo. Lo prohibe el manifiesto (git.prohibidos: '$regla'). Como seguir: comitea lo que quieras conservar; si la limpieza hace falta de verdad, que la ejecute el humano fuera de la sesion. Para retirar la regla, edita .arnes/config.json a sabiendas.$motivo_extra"
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
