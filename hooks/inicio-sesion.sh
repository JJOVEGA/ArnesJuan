#!/usr/bin/env bash
# inicio-sesion.sh — recordatorio de SessionStart (REQ-036 CA-17, P-137-Y (A)) y archivos de lectura por rol
# (REQ-036 CA-18, P-137-Z (A)).
#
# POR QUÉ EXISTE. Desde 1.37.0 `CLAUDE.md` ya no importa `AGENTS.md`: el import lo cargaba entero en el
# contexto de todo agente y anulaba la lectura por destinatario. Cada subagente lo lee según su rol; la
# sesión principal —la coordinadora— lo tiene que leer ENTERO, y este hook se lo recuerda al abrirse.
# Después regenera `.arnes/lectura/<rol>.md` (tools/arnes-lectura-rol.sh), una vez por sesión.
#
# QUÉ NO ES. No es una puerta: no decide, no deniega y no bloquea la apertura. Que la coordinadora lo lea
# y obedezca no lo comprueba ninguna máquina (límite declarado de CA-17).
#
# SIN COSTE EN EL CAMINO COMÚN. Sólo está registrado en `SessionStart` (hooks.json): ninguna orden lo
# lanza. No lee la entrada, no lee `.arnes/config.json` y no usa `jq`: avisa igual sin manifiesto o sin `jq`.
# El recordatorio sale ANTES de generar, sólo con órdenes internas del intérprete, así que ningún fallo del
# generador lo impide; el generador escribe a /dev/null (stdout de SessionStart entra en el contexto) y, si no
# puede generar, borra los archivos por rol (un archivo ausente se lee por marcas). Sale 0 pase lo que pase.
#
# EL BORRADO NO DEPENDE DEL GENERADOR (REQ-036 CA-18 (c), QA-036-05). Si el generador no existe, no se puede leer,
# no arranca o sale con un código distinto de 0 y quedan archivos por rol, este script los quita él —un solo
# `rm -f` sobre las cuatro rutas fijas, sólo en ese caso— y nunca a través de un enlace: con `.arnes` o
# `.arnes/lectura` como enlace simbólico no toca nada (límite declarado L2). Lo que no puede quitar lo avisa por
# stderr con su ruta (L3: destino no escribible). Sigue sin decidir nada.
#
# INERTE SIN `.arnes/` (REQ-036 CA-17, P-137-AI (A), SEC-145). Lo PRIMERO: si `.arnes` del proyecto no resuelve a
# un directorio (ausente, archivo, enlace roto o a algo que no es directorio), el proyecto no es del arnés y el
# script sale 0 sin emitir nada, sin lanzar el generador y sin procesos (`[` es interna). Un enlace a un directorio
# cuenta como «tiene»: avisa como siempre y el generador no escribe a través de él (L2).
[ -d "${CLAUDE_PROJECT_DIR:-.}/.arnes" ] || exit 0
builtin printf '%s\n' \
  'Recordatorio del arnés (sesión principal = coordinadora): lee AGENTS.md ENTERO antes de tu primer encargo.' \
  'CLAUDE.md ya no lo importa; cada subagente lo lee según su rol, por sus marcas [[<id> · obliga: <roles>]], y la coordinadora lee todos los bloques.' \
  2>/dev/null
GEN="${CLAUDE_PLUGIN_ROOT:-${BASH_SOURCE[0]%/*}/..}/tools/arnes-lectura-rol.sh"
P="${CLAUDE_PROJECT_DIR:-.}"; RC=1
[ -r "$GEN" ] && { "${BASH:-bash}" "$GEN" "$P" >/dev/null 2>&1; RC=$?; }
if [ "$RC" -ne 0 ] && [ ! -L "$P/.arnes" ] && [ ! -L "$P/.arnes/lectura" ]; then
  F=("$P/.arnes/lectura/analista.md" "$P/.arnes/lectura/desarrollador.md" "$P/.arnes/lectura/qa.md" "$P/.arnes/lectura/seguridad.md")
  Q=no; for f in "${F[@]}"; do { [ -e "$f" ] || [ -L "$f" ]; } && Q=si; done
  if [ "$Q" = si ]; then
    rm -f -- "${F[@]}" 2>/dev/null
    for f in "${F[@]}"; do
      { [ -e "$f" ] || [ -L "$f" ]; } \
        && builtin printf 'arnes (inicio de sesión): no se pudo quitar %s; puede estar viejo: bórralo a mano\n' "$f" >&2
    done
  fi
fi
exit 0
