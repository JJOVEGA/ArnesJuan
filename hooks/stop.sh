#!/usr/bin/env bash
# stop.sh — punto de entrada único de los hooks de parada (Stop / SubagentStop).
#
# POR QUÉ EXISTE. `estado-derivado` y `rotar-artefactos` iban como dos hooks
# independientes: dos intérpretes por cada parada de cada subagente. Y como la
# rotación viene APAGADA por defecto, el segundo arrancaba sólo para descubrir que
# no tenía nada que hacer. En esta plataforma arrancar el intérprete es justo la
# parte cara (~1,2 s, medido), así que era pagar lo caro para no hacer nada.
#
# Es exactamente el mismo principio que `guard.sh` aplica a los dos guardianes:
# el preludio —intérprete, librería, stdin, manifiesto— se hace UNA vez y los dos
# corren como funciones en el mismo proceso.
#
# LOS DOS ARCHIVOS SIGUEN SIENDO EJECUTABLES POR SU CUENTA, y el banco los invoca
# así. Deliberado: producción y pruebas ejecutan LA MISMA función.
#
# NUNCA BLOQUEA. Un hook de parada que falla deja la sesión colgada. Cada paso va
# con `|| true` y el proceso sale 0 pase lo que pase.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"
# shellcheck source=/dev/null
. "$DIR/estado-derivado.sh"
# shellcheck source=/dev/null
. "$DIR/rotar-artefactos.sh"

arnes_preludio || exit 0
arnes_estado_derivado  || true
arnes_rotar_artefactos || true
exit 0
