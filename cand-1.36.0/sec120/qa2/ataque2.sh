#!/usr/bin/env bash
# Cada entrada (qa/entradas, qa/entradas2 y qa2/entradas) por guard.sh de v1.35.0, aba1c9b y el candidato (413c6bd),
# y por cada guardián de aba1c9b y del candidato. Con CLAUDE_PROJECT_DIR en qa/proyecto (manifiesto válido).
# Columnas: entrada | g135 gaba gcand | aba: git cod comp | cand: git cod comp | motivo aba (55) || motivo cand (55)
# Decisión: deny | nada (sin salida) | otro ; (rcN) si el rc no es 0.
set -u
Q=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120; P=$Q/qa/proyecto
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
V=/home/juan/dev/ArnesJuan-v1.35.0-base/hooks; A=$S/taba1c9b/hooks; C=/home/juan/dev/ArnesJuan-v1.36/hooks
dec() { local out rc d; out="$(CLAUDE_PROJECT_DIR=$P timeout 60 bash "$1" < "$2" 2>/dev/null)"; rc=$?
  if [ -z "$out" ]; then d=nada; elif printf '%s' "$out" | jq -e '.hookSpecificOutput.permissionDecision=="deny"' >/dev/null 2>&1; then d=deny; else d=otro; fi
  [ $rc = 0 ] || d="$d(rc$rc)"; DEC=$d; MOT="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // .systemMessage // empty' 2>/dev/null | cut -c1-55)"; }
for f in $(ls $Q/qa/entradas/*.json $Q/qa/entradas2/*.json $Q/qa2/entradas/*.json); do n=${f#$Q/}; n=${n%.json}
  dec $V/guard.sh $f; a=$DEC; dec $A/guard.sh $f; b=$DEC; ma="$MOT"; dec $C/guard.sh $f; c=$DEC; mc="$MOT"
  dec $A/guard-git.sh $f; ag=$DEC; dec $A/guard-codigo.sh $f; ak=$DEC; dec $A/guard-completado.sh $f; ax=$DEC
  dec $C/guard-git.sh $f; cg=$DEC; dec $C/guard-codigo.sh $f; ck=$DEC; dec $C/guard-completado.sh $f; cx=$DEC
  printf '%-52s %-6s %-6s %-6s | %-6s %-6s %-6s | %-6s %-6s %-6s | %s || %s\n' "$n" "$a" "$b" "$c" "$ag" "$ak" "$ax" "$cg" "$ck" "$cx" "$ma" "$mc"
done
