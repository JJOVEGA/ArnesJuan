#!/usr/bin/env bash
# Inventario ordenado de un banco: `<veredicto> TAB <identificador de caso>`, una línea
# por caso, en orden estable.
#
# POR QUÉ EXISTE (REQ-014 CA-12). Cuando el banco se reorganiza, «el banco pasa» no dice
# nada: dos casos que intercambian PASS y FAIL dan el mismo total, y esa es exactamente la
# forma en que un refactor del banco pierde cobertura sin que nadie lo vea. Lo que se
# compara es el INVENTARIO, caso por caso, byte a byte:
#
#   bash tests/escenarios/hooks/run.sh > /tmp/despues.txt
#   bash tests/escenarios/hooks/inventario.sh /tmp/antes.txt   > /tmp/inv-antes.txt
#   bash tests/escenarios/hooks/inventario.sh /tmp/despues.txt > /tmp/inv-despues.txt
#   diff /tmp/inv-antes.txt /tmp/inv-despues.txt   # vacío o no se ha hecho el trabajo
#
# ============================================================================
# EL ORÁCULO, POR PROPIEDAD Y CON SU SITIO ÚNICO AQUÍ (REQ-014 CA-12 (b), DEV-014-02)
# ============================================================================
# La propiedad: **se normaliza todo campo que sea MEDIDA o SORTEO de un caso, y no su
# IDENTIDAD**. Ya estaba escrita en este archivo —«los milisegundos son la MEDIDA de un
# caso, no su identidad»— y lo que envejeció fue su EXTENSIÓN: nombraba UNA unidad (`ms`)
# cuando la propiedad es «todo campo que mide».
#
# Medido con el oráculo anterior (2026-09-08, tres corridas INTACTAS del banco en esta
# máquina; cifras operativas): 884 casos las tres, pero **74.047 · 74.055 · 74.047 bytes**
# y `cmp` distinto en el **byte 42.027, línea 545** — **25 de 884** líneas volátiles (µs,
# ns/vuelta, cocientes, `cal_n`, PID, sellos epoch, ternas sorteadas y los tamaños de un
# dominio muestreado). Con esta regla las tres salen **idénticas: 884 líneas, 73.508 bytes,
# `cmp` limpio**. (El REQ registra la misma clase medida ese día con otro reparto de ruido:
# 74.046 vs 74.047 bytes y el byte 42.659 — DEV-014-02.) Por eso aquí NO hay una lista de
# unidades: una lista envejece con el primer campo volátil nuevo. Hay una regla.
#
# LO QUE ES IDENTIDAD Y SE CONSERVA CARÁCTER POR CARÁCTER (CA-12 (c)) — sin esta mitad el
# oráculo no mide nada: uno que normalizara «todo» saldría idéntico siempre.
#   1. El VEREDICTO (PASS/FAIL/SKIP).
#   2. Todo numeral que DESIGNA en vez de medir, en cualquier parte de la línea:
#        a. pegado a un nombre por `-` o `.`, o detrás de una letra: `REQ-017`, `CA-02.1`,
#           `SEC-030`, `v1.32.1`, `(a.3)`, `07-bash-falsos-positivos.sh`;
#        b. con tres o más partes separadas —una versión o una fecha: `1.31.0`,
#           `2026-09-07`—, que es lo que distingue una designación de una magnitud: una
#           magnitud lleva como mucho UN separador decimal;
#        c. entre comillas: es la ENTRADA que el caso ejercita, no algo que él midió
#           (`'2026-13-05' no es una fecha`).
#   3. En el NOMBRE del caso, todo entero suelto: es un dato o una cota del caso, no lo que
#      midió (`borde exacto: 40 intacto, 41 recortado`, `el hook sale 0`, `techo 6×`).
#
# LO QUE ES MEDIDA O SORTEO Y SE NORMALIZA A `N`:
#   4. TODA la EVIDENCIA que el caso publica detrás de su nombre —separada por dos
#      espacios—: por construcción es lo que esta corrida midió y contra qué lo comparó.
#   5. Y dentro del nombre, el numeral escrito en NOTACIÓN DE MAGNITUD: con parte decimal
#      (`= 3.641×`) o con una unidad pegada (`responde deny (113ms)`). Es la FORMA de una
#      magnitud, no una lista de unidades: un campo volátil con una unidad nueva ya está
#      cubierto el día que aparece.
#
# LA DIRECCIÓN DEL ERROR, DECLARADA. Si algún día un caso publica una magnitud volátil
# como ENTERO SUELTO DENTRO DE SU NOMBRE, esta regla NO la normaliza y el positivo de
# CA-12 (d) se pone ROJO. Es la dirección elegida a propósito: un inventario que enrojece
# se investiga; uno que normaliza de más pierde casos EN SILENCIO, que es el defecto que
# este oráculo viene a cerrar.
#
# LÍMITES HONESTOS, MEDIDOS (2026-09-08, 884 casos) — están aquí porque es lo que la
# máquina hace, y prometer más sería la deriva que AGENTS.md §9 prohíbe:
#   * una letra pegada a un numeral no distingue una UNIDAD de un ORDINAL: `el 2o guardián
#     … tras el 1o` sale `el No guardián … tras el No` (1 línea; no colisiona con nada).
#   * dos casos que se distinguen SÓLO por una magnitud son indistinguibles bajo un
#     oráculo que borra magnitudes; no es un defecto del oráculo, es lo que significa
#     borrar la magnitud. Hoy: 1 grupo de 2 líneas (`heredoc sin citar: 1.500/5.000 líneas
#     con expansión…`). SUPRIMIR cualquiera de las dos SÍ se detecta, porque cambia la
#     multiplicidad de la línea. (Otros 2 grupos ya estaban duplicados con el oráculo
#     anterior: no los crea esto.)
#   * una cota normativa que viva en la EVIDENCIA se normaliza con ella (`techo 2.600×`):
#     ahí no hay forma de distinguirla de lo medido, y su sitio único es el texto de la
#     sección, no este inventario.
set -uo pipefail

if [ "$#" -ne 1 ] || [ ! -r "$1" ]; then
  echo "uso: inventario.sh <salida-del-banco.txt>" >&2
  exit 2
fi

# `LC_ALL=C` en las tres etapas: el orden y el recorrido de bytes no pueden depender del
# idioma del entorno, o el inventario de dos máquinas deja de ser comparable.
sed -nE 's/^  (PASS|FAIL|SKIP)  (.*)$/\1\t\2/p' "$1" | LC_ALL=C awk '
  # ¿el numeral de este token DESIGNA (identidad) en vez de medir? Ver los puntos 2a-2c.
  function designa(t) {
    return (t ~ /[A-Za-z][-.]?[0-9]/) || (t ~ /[0-9][-.][A-Za-z]/) ||
           (t ~ /[0-9]([-.][0-9]+){2}/) || (t ~ /['"'"'"]/)
  }
  # Normaliza las magnitudes de un token. `todo`=1 en la evidencia (punto 4); `todo`=0 en
  # el nombre, donde sólo cae lo escrito en notación de magnitud (punto 5).
  function magnitudes(t, todo,   out, num, sig) {
    out = ""
    while (match(t, /[0-9]+([.,][0-9]+)?/)) {
      num = substr(t, RSTART, RLENGTH)
      sig = substr(t, RSTART + RLENGTH, 1)          # lo que va PEGADO detrás: ¿unidad?
      out = out substr(t, 1, RSTART - 1) \
            ((todo || num ~ /[.,]/ || sig ~ /[A-Za-z]/) ? "N" : num)
      t = substr(t, RSTART + RLENGTH)
    }
    return out t
  }
  # Se recorre por tokens separados por UN espacio y se rearma igual: la propiedad es de
  # cada campo, y el texto de fuera —espaciado incluido— no se toca.
  function normaliza(txt, todo,   n, i, t, out, tok) {
    n = split(txt, tok, / /); out = ""
    for (i = 1; i <= n; i++) {
      t = tok[i]
      if (!designa(t)) t = magnitudes(t, todo)
      out = (i == 1 ? t : out " " t)
    }
    return out
  }
  {
    tab = index($0, "\t"); ver = substr($0, 1, tab); resto = substr($0, tab + 1)
    corte = index(resto, "  ")     # el nombre del caso termina donde empieza su evidencia
    if (corte > 0)
      print ver normaliza(substr(resto, 1, corte - 1), 0) "  " normaliza(substr(resto, corte + 2), 1)
    else
      print ver normaliza(resto, 0)
  }
' | LC_ALL=C sort
