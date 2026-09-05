#!/usr/bin/env bash
# guard.sh — punto de entrada único de los guardianes del arnés.
#
# POR QUÉ EXISTE. `guard-codigo` y `guard-completado` hacían EXACTAMENTE el mismo
# trabajo previo —arrancar el intérprete, cargar la librería, leer stdin,
# interpretar el mismo JSON de entrada y leer el mismo manifiesto— cada uno en su
# propio proceso. En esta plataforma arrancar un intérprete cuesta ~1,2 s y cada
# bifurcación ~0,55 s, así que ese trabajo duplicado era la mitad del coste.
#
# Aquí el preludio se hace UNA vez y los dos guardianes corren como funciones en
# el mismo proceso, reutilizando el análisis memorizado.
#
# LOS DOS ARCHIVOS SIGUEN SIENDO EJECUTABLES POR SU CUENTA, y el banco de pruebas
# los invoca así. Eso es deliberado: producción y pruebas ejecutan LA MISMA
# función, no dos copias que puedan desfasarse.
#
# ORDEN. Primero identidad (¿quién edita?), después cierre (¿se puede cerrar?).
# Si el primero deniega, `arnes_deny` termina el proceso y el segundo no corre —
# lo cual es correcto: la denegación ya es final y no hay nada más que juzgar.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"
# shellcheck source=/dev/null
. "$DIR/guard-codigo.sh"
# shellcheck source=/dev/null
. "$DIR/guard-completado.sh"

arnes_preludio || exit 0
arnes_guard_codigo
arnes_guard_completado
exit 0
