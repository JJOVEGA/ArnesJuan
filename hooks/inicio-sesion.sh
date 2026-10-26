#!/usr/bin/env bash
# inicio-sesion.sh — recordatorio de SessionStart (REQ-036 CA-17, P-137-Y (A)).
#
# POR QUÉ EXISTE. Desde 1.37.0 `CLAUDE.md` ya no importa `AGENTS.md`: el import lo cargaba entero en el
# contexto de todo agente y anulaba la lectura por destinatario. Cada subagente lo lee por sus marcas; la
# sesión principal —la coordinadora— lo tiene que leer ENTERO, y este hook se lo recuerda al abrirse.
#
# QUÉ NO ES. No es una puerta: no decide, no deniega y no bloquea la apertura. Que la coordinadora lo lea
# y obedezca no lo comprueba ninguna máquina (límite declarado de CA-17).
#
# SIN COSTE EN EL CAMINO COMÚN. Sólo está registrado en `SessionStart` (hooks.json): ninguna orden lo
# lanza. No lee la entrada, no lee `.arnes/config.json` y no usa `jq` ni ningún otro programa —sólo
# órdenes internas del intérprete—, así que avisa igual sin manifiesto o sin `jq`, y sale 0 pase lo que pase.
builtin printf '%s\n' \
  'Recordatorio del arnés (sesión principal = coordinadora): lee AGENTS.md ENTERO antes de tu primer encargo.' \
  'CLAUDE.md ya no lo importa; cada subagente lo lee según su rol, por sus marcas [[<id> · obliga: <roles>]], y la coordinadora lee todos los bloques.' \
  2>/dev/null
exit 0
