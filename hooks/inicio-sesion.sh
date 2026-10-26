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
builtin printf '%s\n' \
  'Recordatorio del arnés (sesión principal = coordinadora): lee AGENTS.md ENTERO antes de tu primer encargo.' \
  'CLAUDE.md ya no lo importa; cada subagente lo lee según su rol, por sus marcas [[<id> · obliga: <roles>]], y la coordinadora lee todos los bloques.' \
  2>/dev/null
GEN="${CLAUDE_PLUGIN_ROOT:-${BASH_SOURCE[0]%/*}/..}/tools/arnes-lectura-rol.sh"
[ -r "$GEN" ] && "${BASH:-bash}" "$GEN" "${CLAUDE_PROJECT_DIR:-.}" >/dev/null 2>&1
exit 0
