#!/usr/bin/env bash
# Transcripción EJECUTABLE de la mitad mecánica de la comprobación de §6
# («Cómo se comprueba la autorización, y hacia dónde falla»).
#
# NO es una herramienta del arnés y no vive en `tools/`: existe para que el
# resultado de la prueba de despacho se pueda RE-DERIVAR sin volver a leer a mano.
# La otra mitad —clasificar el cambio en una fila de la tabla— la hace una persona
# o un agente leyendo, y aquí NO se automatiza ni se simula.
#
# Uso: comprobar-autorizacion.sh <ruta-del-proyecto>
# Sale 0 si el proyecto AUTORIZA la vía; 1 en cualquier otro desenlace (fail-closed).
set -u
proy="${1:-}"
[ -n "$proy" ] || { echo "uso: $0 <ruta-del-proyecto>" >&2; exit 2; }
doc="$proy/AGENTS.md"

if [ ! -r "$doc" ]; then
  echo "archivo leído : $doc (NO LEGIBLE)"
  echo "resuelve      : NO-AUTORIZADA (fail-closed: no se pudo leer)"
  echo "ruta           : procedimiento anterior — se despacha al analista"
  exit 1
fi

# Forma (a): la frase de autorización. Forma (b): la fila de la tabla de vías.
a=$(grep -n "autoriza la vía proporcional de reparación" "$doc" | head -3)
b=$(grep -n "Sin comisión de analista" "$doc" | head -3)

echo "archivo leído : $doc"
if [ -n "$a" ] || [ -n "$b" ]; then
  echo "forma (a) frase «autoriza la vía proporcional de reparación»: ${a:-(ausente)}"
  echo "forma (b) fila  «Sin comisión de analista»                  : ${b:-(ausente)}"
  echo "resuelve      : AUTORIZADA"
  echo "ruta           : la vía proporcional de §6 puede omitir al analista"
  exit 0
fi
echo "forma (a) frase «autoriza la vía proporcional de reparación»: (ausente)"
echo "forma (b) fila  «Sin comisión de analista»                  : (ausente)"
echo "resuelve      : NO-AUTORIZADA"
echo "ruta           : procedimiento anterior — se despacha al analista"
exit 1
