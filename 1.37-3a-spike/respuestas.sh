#!/usr/bin/env bash
# Qué hace de verdad cada respuesta, y los huecos del estado.
set -u
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad
. <(sed -n '/^SPIKE=/,/^}$/p;/^json()/,/^}$/p;/^vigilado_igual()/,/^}$/p' "$S/casos.sh")
SPIKE=/home/juan/dev/ArnesJuan-spike-1.37-3; PP="$SPIKE/hooks/puerta-posterior.sh"
export TMPDIR="$S/estado2"; rm -rf "$TMPDIR"; mkdir -p "$TMPDIR"
P="$S/p/resp"
ventana() {   # <tid> <orden> [agente]
  json "$P" "${3:-qa-tester}" "$2" "$1" | CLAUDE_PROJECT_DIR="$P" bash "$PP" pre
  (cd "$P" && bash -c "$2" >/dev/null 2>&1)
  json "$P" "${3:-qa-tester}" "$2" "$1" | CLAUDE_PROJECT_DIR="$P" bash "$PP" post
}
for r in bloquear restaurar ambas; do
  nuevo_proyecto "$P"
  out="$(ARNES_PP_RESPUESTA=$r ventana t-$r 'rm hooks/guard.sh' 2>&1)"
  vigilado_igual "$P" && d="restaurado" || d="SIGUE el cambio"
  printf '%-10s disco: %-16s salida: %s\n' "$r" "$d" "${out:-(ninguna)}"
done
echo '--- la orden borra el estado de la puerta además de atacar'
nuevo_proyecto "$P"
out="$(ventana t-e "rm -rf \"$TMPDIR\"/arnes-pp-* && cp x hooks/lib.sh" 2>&1)"
vigilado_igual "$P" && d="restaurado" || d="SIGUE el cambio"; echo "disco: $d | $out"
echo '--- la orden falsifica la foto de antes (escribe la de después en el estado)'
nuevo_proyecto "$P"
out="$(ventana t-f "cp x hooks/lib.sh && f=\$(find .arnes/config.json hooks -printf '%y %i %s %C@ %T@ %m %p -> %l\n') && printf '%s' \"\$f\" > \"$TMPDIR\"/arnes-pp-$UID/s1/pre/t-f" 2>&1)"
vigilado_igual "$P" && d="restaurado" || d="SIGUE el cambio"; echo "disco: $d | ${out:-(ninguna)}"
echo '--- escritura diferida (segundo plano): ocurre después del Post'
nuevo_proyecto "$P"
out="$(ventana t-g '(sleep 1; cp x hooks/lib.sh) & disown' 2>&1)"; echo "post: ${out:-(ninguna)}"
sleep 2
out="$(ventana t-h 'ls' 2>&1)"
vigilado_igual "$P" && d="restaurado" || d="SIGUE el cambio"; echo "siguiente orden: disco: $d | $out"
echo '--- sin tool_use_id'
nuevo_proyecto "$P"
out="$(ventana '' 'cp x hooks/lib.sh' 2>&1)"
vigilado_igual "$P" && d="restaurado" || d="SIGUE el cambio"; echo "disco: $d | ${out:-(ninguna)}"
