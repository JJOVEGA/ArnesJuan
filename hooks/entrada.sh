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
unset POSIXLY_CORRECT; set +o posix
SECONDS=0; ARNES_JUICIO=''; ARNES_EN_HOOK=1
trap '[ "${ARNES_JUICIO:-}" = fin ] || { printf "%s\n" "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"ARNES: el hook termino sin concluir el juicio de esta llamada (un error del interprete o una salida inesperada), asi que no se sabe si toca algo protegido. Una puerta que no puede medir no deja pasar, a ningun agente (REQ-007 CA-68).\"}}"; exit 0; }' EXIT
