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
# ORDEN. Primero git destructivo (¿esta orden borra trabajo que puede no ser suyo?),
# después identidad (¿quién edita?), después cierre (¿se puede cerrar?). Si uno deniega,
# `arnes_deny` termina el proceso y los siguientes no corren — lo cual es correcto: la
# denegación ya es final y no hay nada más que juzgar.
#
# `guard-git` va PRIMERO porque su daño es el único irreversible de los tres: una edición
# denegada se vuelve a intentar, un árbol borrado no vuelve.
#
# Si NINGUNO deniega, se emiten al final los AVISOS acumulados (un veredicto escrito
# fuera del vocabulario, p. ej.) como `systemMessage`. Nunca junto a una denegación: dos
# salidas JSON en el mismo stdout no son un objeto válido, y una denegación ya lo dice
# todo.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"
# shellcheck source=/dev/null
. "$DIR/guard-git.sh"
# shellcheck source=/dev/null
. "$DIR/guard-codigo.sh"
# shellcheck source=/dev/null
. "$DIR/guard-completado.sh"

arnes_preludio || exit 0
arnes_guard_git
arnes_guard_codigo
arnes_guard_completado
arnes_emitir_avisos
exit 0
