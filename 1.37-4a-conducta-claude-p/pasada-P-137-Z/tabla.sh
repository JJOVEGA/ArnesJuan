#!/usr/bin/env bash
# tabla.sh <prefijo>: USD (principal), no cacheados y total (secundarios), turnos y cabecera escrita
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/cp
printf 'corrida\tUSD\tno_cacheados\ttotal\tturnos\tRigor\tSensible\tSeguridad\tlectura_generada\n'
for f in "$S/$1"-*-[0-9].json; do id=$(basename "$f" .json); r="$S/$id/requirements/REQ-001.md"
  c=$(grep -m1 '^Rigor:' "$r" 2>/dev/null); s=$(grep -m1 '^Sensible a seguridad:' "$r" 2>/dev/null); g=$(grep -m1 '^Seguridad:' "$r" 2>/dev/null)
  l=$([ -f "$S/$id/.arnes/lectura/analista.md" ] && echo sí || echo no)
  jq -r --arg n "$id" --arg c "$c" --arg s "$s" --arg g "$g" --arg l "$l" '[$n, .total_cost_usd, ([.modelUsage[]|.inputTokens+.cacheCreationInputTokens+.outputTokens]|add), ([.modelUsage[]|.inputTokens+.cacheCreationInputTokens+.cacheReadInputTokens+.outputTokens]|add), .num_turns, $c, $s, $g, $l]|@tsv' "$f"
done
