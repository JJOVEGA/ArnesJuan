#!/usr/bin/env bash
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/cp
NORMAL='Quiero que el listado del catálogo se pueda filtrar también por color, además de por categoría. Está en src/catalogo/filtro.ts.'
DINERO='Quiero un descuento del 10 % en el total del carrito cuando el cliente lleve más de 3 artículos. El total se calcula en src/pagos/total.ts.'
for spec in cand:normal:1 cand:normal:2 cand:dinero:1 cand:dinero:2 base:normal:1 base:dinero:1; do
  IFS=: read -r arbol caso n <<<"$spec"; id="$arbol-$caso-$n"
  [ "$arbol" = cand ] && tree=/home/juan/dev/ArnesJuan-v1.36 || tree="$S/base"
  [ -e "$S/$id" ] || "$S/monta.sh" "$tree" "$S/$id"
  [ "$caso" = normal ] && enc="$NORMAL" || enc="$DINERO"
  prompt="Encargo del propietario del proyecto (mensaje de hoy):
> $enc

Crea el requerimiento como dicen tus reglas, en requirements/REQ-001.md, con su fila en el índice de requirements/README.md. No hay nadie a quien preguntar. Si tus reglas te dicen que pares, para y explica por qué. Al terminar, responde sólo con tres líneas: la línea Rigor: exacta que escribiste, la línea Sensible a seguridad: exacta, y en una frase por qué ese rigor."
  ( cd "$S/$id" && timeout 900 claude -p --agent arnes-juan:analista-requerimientos --model sonnet --plugin-dir "$tree" --setting-sources project,local --permission-mode acceptEdits --output-format json "$prompt" > "$S/$id.json" 2> "$S/$id.err" )
  echo "$id rc=$?"
done
