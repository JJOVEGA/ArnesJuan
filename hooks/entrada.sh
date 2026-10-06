# entrada.sh — lo que cada punto de entrada de los guardianes hace ANTES de cargar nada más.
# Lo cargan con `.` `guard.sh` y, cuando se ejecutan por su cuenta, `guard-git.sh`, `guard-codigo.sh` y
# `guard-completado.sh`. Una sola sede: cuatro copias de la misma trampa se desfasarían.
#
# UN FINAL QUE NO ES UN JUICIO NO DEJA PASAR (SEC-129, SEC-115; REQ-007 CA-68):
#   * R1: se sale del modo POSIX heredado del entorno —`POSIXLY_CORRECT` exportada (también vacía),
#     `SHELLOPTS=posix`, un `BASH_ENV` que hace `set -o posix`, o `bash --posix`—. En ese modo el analizador
#     de Bash fallaba y las tres puertas de Bash salían sin decisión para toda llamada (R-054). Va antes de
#     cargar `lib.sh`, para que ninguna función se lea en ese modo. Sin procesos: un `unset` y un `set`.
#     Lo que NO alcanza: un `BASH_ENV` con otro contenido corre antes de la primera línea del hook
#     (O-54-1, ficha F-136-9).
#   * El plazo propio del hook arranca aquí: `SECONDS=0` es una asignación, así que un `SECONDS` heredado
#     del entorno no lo mueve (`arnes_plazo`, lib.sh).
#   * La trampa de salida: si el proceso termina sin que el juicio haya concluido —sólo `ARNES_JUICIO=fin`
#     lo dice: la salida inerte, el final de un punto de entrada y una denegación que `jq` llegó a
#     escribir—, emite una denegación FIJA, con `printf`, sin `jq` y sin interpolar nada, para que nada
#     pueda impedir emitirla. `ARNES_JUICIO` se vacía aquí: un valor heredado del entorno no cuenta.
#   * Y el resto del estado del intérprete heredado que se puede deshacer desde dentro (QA-007-11 (a); REQ-007
#     CA-68 (ii), P-136-P (2) (A)), sin procesos:
#       - las FUNCIONES importadas del entorno (`BASH_FUNC_<nombre>%%`): una `jq`, `printf` o `read` importada
#         sustituía a la orden y el hook salía sin decisión. Se leen los nombres de `/proc/self/environ` —una
#         redirección, sin procesos— y se retiran con `unset -f` antes de que la librería defina las suyas. Las
#         órdenes de esta limpieza van con `builtin`, para que una función homónima no la rodee;
#       - `FUNCNEST` (con 1 o 2 el preludio fallaba y se leía como «inerte»);
#       - `BASH_COMPAT` y las opciones `compat31`…`compat44` (se perdía el aviso);
#       - la opción `keyword` (`set -k`, rompía el JSON de la salida).
#     LÍMITES, DECLARADOS (QA-007-11 (b), F-136-19): `noexec`, `onecmd` y `xtrace` hacia la salida estándar
#     actúan antes de la primera línea útil y no se deshacen desde aquí; sin `/proc/self/environ` legible
#     (fuera de Linux, no medido) las funciones importadas no se retiran; y una función importada con el nombre
#     `builtin` rodearía esta limpieza.
builtin unset POSIXLY_CORRECT; builtin set +o posix
while IFS= builtin read -r -d '' ARNES_ENTRADA_V; do
  case "$ARNES_ENTRADA_V" in BASH_FUNC_*%%=*) ARNES_ENTRADA_V="${ARNES_ENTRADA_V#BASH_FUNC_}"; builtin unset -f -- "${ARNES_ENTRADA_V%%\%\%=*}" ;; esac
done < /proc/self/environ 2>/dev/null
builtin unset ARNES_ENTRADA_V FUNCNEST BASH_COMPAT
builtin shopt -u compat31 compat32 compat40 compat41 compat42 compat43 compat44 2>/dev/null
builtin set +o keyword
SECONDS=0; ARNES_JUICIO=''; ARNES_EN_HOOK=1
trap '[ "${ARNES_JUICIO:-}" = fin ] || { builtin printf "%s\n" "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"ARNES: el hook termino sin concluir el juicio de esta llamada (un error del interprete o una salida inesperada), asi que no se sabe si toca algo protegido. Una puerta que no puede medir no deja pasar, a ningun agente (REQ-007 CA-68).\"}}"; exit 0; }' EXIT
