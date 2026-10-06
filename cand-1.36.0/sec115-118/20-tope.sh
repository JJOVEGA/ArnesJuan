#!/usr/bin/env bash
# Fase 2, SEC-118 / REQ-007 CA-67: el TOPE del motivo y del aviso (ARNES_MOTIVO_MAX_BYTES), medido.
# Uso: 20-tope.sh <scratch> <dir-hooks>
# Parte 1 — a nivel de librería: `arnes_deny` y `arnes_emitir_avisos` de <dir-hooks>/lib.sh, cada uno en
#   un subshell, con motivos de N bytes alrededor del tope —tope-1, tope, tope+1 … tope+4, 2×tope y
#   300 000— y contenido ASCII, de 2, de 3 y de 4 bytes, con el desfase 0..3 que hace que el corte caiga en
#   cada byte de un carácter. Por cada uno: rc, JSON válido (jq lo relee), bytes del motivo emitido (≤ tope),
#   UTF-8 válido (iconv), comienzo conservado y la nota de acortado sólo si hacía falta.
# Parte 2 — a nivel de hook: los vectores D y A de 01-sonda.sh por guard.sh, con la salida entera guardada.
set -u
S="${1:?scratch}"; H="${2:?hooks}"; W="$(mktemp -d "$S/tope-XXXX")"; trap 'rm -rf "$W"' EXIT
export LANG=C.UTF-8; unset LC_ALL
TOPE="$(bash -c '. "$1/lib.sh"; printf %s "$ARNES_MOTIVO_MAX_BYTES"' _ "$H")"
echo "# tope declarado: $TOPE bytes; $(date -Is); bash $BASH_VERSION"
mal=0; n_casos=0
mide() {   # <etiqueta> <archivo de salida> <archivo del texto original> [acortado esperado: si|no]
  local et="$1" o="$2" orig="$3" m b v ini acort esper="${4:-}"
  n_casos=$((n_casos + 1))
  if ! jq -e . "$o" >/dev/null 2>&1; then echo "MAL $et: la salida no es JSON válido"; mal=$((mal + 1)); return; fi
  jq -j '.hookSpecificOutput.permissionDecisionReason // .systemMessage' "$o" > "$W/m"
  b="$(LC_ALL=C wc -c < "$W/m")"; v=ok; iconv -f UTF-8 -t UTF-8 "$W/m" >/dev/null 2>&1 || v=NO-UTF8
  local nc; nc="$(LC_ALL=C wc -c < "$orig")"; [ "$nc" -le 40 ] || nc=40
  ini=ok; cmp -s -n "$nc" "$W/m" "$orig" || ini=NO-COMIENZO
  acort=no; grep -q 'motivo acortado' "$W/m" && acort=si
  if [ -z "$esper" ]; then esper=no; [ "$(LC_ALL=C wc -c < "$orig")" -gt "$TOPE" ] && esper=si; fi
  local r=ok; { [ "$b" -le "$TOPE" ] && [ "$v" = ok ] && [ "$ini" = ok ] && [ "$acort" = "$esper" ]; } || { r=MAL; mal=$((mal + 1)); }
  printf '%-4s %-40s emitido=%6s bytes utf8=%s comienzo=%s acortado=%s (esperado %s)\n' "$r" "$et" "$b" "$v" "$ini" "$acort" "$esper"
}
gen() {   # <bytes objetivo> <unidad> <desfase> -> $W/t (texto de ~N bytes: prefijo ASCII + relleno)
  local n="$1" u="$2" d="$3" p
  p="ARNES: causa medida del tope ($u, desfase $d) $(printf '%*s' "$d" '' | tr ' ' 'x')"
  { printf '%s' "$p"; head -c $(( n * 2 )) /dev/zero | tr '\0' 'Q' | sed "s/Q/$u/g" | LC_ALL=C head -c "$(( n - ${#p} ))"; } > "$W/t0"
  # head -c en bytes puede partir el último carácter del relleno: se retira para que el ORIGINAL sea UTF-8 válido
  iconv -f UTF-8 -t UTF-8 -c "$W/t0" > "$W/t" 2>/dev/null
}
echo "## Parte 1: librería"
for u in a ñ € 𝄞; do
  for d in 0 1 2 3; do
    for n in $((TOPE - 1)) "$TOPE" $((TOPE + 1)) $((TOPE + 2)) $((TOPE + 3)) $((TOPE + 4)) $((TOPE * 2)) 300000; do
      gen "$n" "$u" "$d"
      (. "$H/lib.sh"; arnes_deny "$(cat "$W/t")") > "$W/o" 2>/dev/null; rc=$?
      [ "$rc" -eq 0 ] || { echo "MAL rc=$rc"; mal=$((mal + 1)); }
      mide "deny  u=$u d=$d n=$(LC_ALL=C wc -c < "$W/t")" "$W/o" "$W/t"
      (. "$H/lib.sh"; ARNES_AVISOS="$(cat "$W/t")"$'\n'; arnes_emitir_avisos) > "$W/o" 2>/dev/null
      mide "aviso u=$u d=$d n=$(LC_ALL=C wc -c < "$W/t")" "$W/o" "$W/t"
    done
  done
done
echo "## Parte 2: hook (guard.sh), vectores de 01-sonda.sh"
for v in h-ascii60-1601 h-corta-2501 h-ascii60-1801 h-corta-3000 h-n2-1601 h-n4-1001 h-cn-2501 qa140 seg140 sens140 cr140 \
         qa140-aviso-a seg140-aviso-a qa140-aviso-2 seg140-aviso-2 qa140-aviso-4 seg140-aviso-4; do
  SONDA_GUARDA="$W/o" bash "$(dirname "$0")/01-sonda.sh" "$S" "$v" "$H" 60 > "$W/linea"
  printf 'ARNES: ' > "$W/pref"   # el comienzo que todo motivo y todo aviso del arnés llevan
  # Todos los originales de estos vectores pasan del tope (de 111 846 a 286 994 bytes, fase 1, 05-).
  mide "hook $v" "$W/o" "$W/pref" si
  printf '     %s\n' "$(grep -o 'dec=[a-z]* aviso=[a-z]* rc=[0-9]* *ms=[0-9]*' "$W/linea")"
done
echo "# casos: $n_casos; MAL: $mal"
