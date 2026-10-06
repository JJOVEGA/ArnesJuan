#!/usr/bin/env bash
# 70-tope.sh <scratch> <hooks> — CA-67 (SEC-118), medido por QA con casos propios.
#  L  librería: arnes_deny y arnes_emitir_avisos con motivos de 16 376 a 16 392 bytes y 2x/20x el tope, rellenos de
#     1, 2, 3 y 4 bytes, con desfase 0-3 (el corte cae en cada byte de un carácter), y rellenos de bytes NO UTF-8
#     (0xFF, 0x80 sueltos, una cabecera de 3 bytes sin cola).
#  H  hook: motivos que interpolan contenido grande: QA:, Seguridad:, Sensible a seguridad: de ~140 KB (ASCII, ñ,
#     𝄞) por Edit que cierra; el MISMO QA: con bytes no UTF-8 que vienen DEL DISCO; un aviso de QA: grande sin cerrar;
#     una ruta larga a requirements/; git destructivo con un argumento de 200 KB.
# Por caso: JSON válido (jq), bytes del motivo emitido (decodificado) <= 16384, UTF-8 válido (iconv), empieza por
# «ARNES:», y la nota de acortado presente.
set -u; S="$1"; H="$2"; QD="$(cd "$(dirname "$0")" && pwd)"; . "$QD/h.sh"
W="$(mktemp -d "$S/tope-XXXX")"; trap 'rm -rf "$W"' EXIT; P="$W/p"; mkp "$P"
T=16384; n=0; mal=0
juzga() { # <nombre> <salida-json> <campo: deny|aviso>
  local o="$2" m b u ok=si why=''
  n=$((n+1))
  if ! jq -e . >/dev/null 2>&1 <<< "$o"; then ok=no; why+=' json-invalido'; fi
  if [ "$3" = deny ]; then m="$(jq -j '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$o" 2>/dev/null; printf x)"; else m="$(jq -j '.systemMessage // empty' <<< "$o" 2>/dev/null; printf x)"; fi
  m="${m%x}"; b="$(LC_ALL=C; printf '%s' "${#m}")"
  [ "$b" -le "$T" ] || { ok=no; why+=" pasa-del-tope($b)"; }
  [ "$b" -gt 0 ] || { ok=no; why+=' vacio'; }
  printf '%s' "$m" | iconv -f UTF-8 -t UTF-8 >/dev/null 2>&1 || { ok=no; why+=' utf8-invalido'; }
  [[ "$m" == ARNES:* ]] || { ok=no; why+=' sin-comienzo'; }
  local nota=no; [[ "$m" == *'motivo acortado'* ]] && nota=si
  [ "$ok" = si ] || mal=$((mal+1))
  printf '%-3s %-60s bytes=%-6s nota=%s %s\n' "$([ $ok = si ] && echo OK || echo MAL)" "$1" "$b" "$nota" "$why"
}
rep() { local k="$1" s="$2" r=''; while [ "$k" -gt 0 ]; do [ $((k & 1)) -eq 0 ] || r+="$s"; s+="$s"; k=$((k >> 1)); done; printf '%s' "$r"; }
echo "# $(date -Is); hooks $H; bash $BASH_VERSION"
# L — librería
for c in x ñ € 𝄞 $'\xff' $'\x80' $'\xe2\x82'; do
  for d in 0 1 2 3; do
    for tot in 16376 16383 16384 16385 16386 16387 16388 16392 32768 327680; do
      pre="ARNES: $(rep "$d" y)"; LCB="$(LC_ALL=C; printf '%s' "${#c}")"; k=$(( (tot - ${#pre}) / LCB + 1 ))
      txt="$pre$(rep "$k" "$c")"; txt="$(LC_ALL=C; printf '%s' "${txt:0:tot}")"
      o="$(bash -c '. "$1/lib.sh" >/dev/null 2>&1; arnes_deny "$2"' _ "$H" "$txt" 2>/dev/null)"
      juzga "L deny relleno=$(printf %q "$c") desfase=$d total=$tot" "$o" deny
    done
    o="$(bash -c '. "$1/lib.sh" >/dev/null 2>&1; ARNES_AVISOS=""; arnes_aviso "$2"; arnes_emitir_avisos' _ "$H" "$(rep 20000 "$c")" 2>/dev/null)"
    juzga "L aviso relleno=$(printf %q "$c") ~20000 caracteres" "$o" aviso
  done
done
# H — hook
CAB() { printf '# REQ-900\nEstado: %s\nQA: %s\nSeguridad: %s\nSensible a seguridad: %s\n\n## Texto\nx\n' "$@"; }
for c in x ñ 𝄞; do
  case "$c" in x) k=143360 ;; ñ) k=71680 ;; 𝄞) k=35840 ;; esac; g="$(rep $k "$c")"
  mkp "$P"; CAB en-revisión "pendiente $g" aprobado sí > "$P/requirements/REQ-900.md"
  in_edit requirements/REQ-900.md 'Estado: en-revisión' 'Estado: completado' > "$W/in"; o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$H/guard.sh" < "$W/in" 2>/dev/null)"
  juzga "H QA: 140KB $c del disco, Edit que cierra" "$o" deny
  mkp "$P"; CAB en-revisión aprobado "pendiente $g" sí > "$P/requirements/REQ-900.md"
  o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$H/guard.sh" < "$W/in" 2>/dev/null)"; juzga "H Seguridad: 140KB $c del disco, Edit que cierra" "$o" deny
  mkp "$P"; CAB en-revisión aprobado aprobado "quizas $g" > "$P/requirements/REQ-900.md"
  o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$H/guard.sh" < "$W/in" 2>/dev/null)"; juzga "H Sensible: 140KB $c del disco, Edit que cierra" "$o" deny
  mkp "$P"; CAB en-revisión aprobado aprobado sí > "$P/requirements/REQ-900.md"
  in_edit requirements/REQ-900.md 'QA: aprobado' "QA: raro $g" > "$W/in2"; o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$H/guard.sh" < "$W/in2" 2>/dev/null)"
  juzga "H aviso QA: 140KB $c por Edit sin cerrar" "$o" aviso
done
for c in $'\xff' $'\x80' $'\xc3'; do
  g="$(rep 143360 "$c")"
  mkp "$P"; CAB en-revisión "pendiente $g" aprobado sí > "$P/requirements/REQ-900.md"
  in_edit requirements/REQ-900.md 'Estado: en-revisión' 'Estado: completado' > "$W/in"; o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$H/guard.sh" < "$W/in" 2>/dev/null)"
  juzga "H QA: 140KB de bytes $(printf %q "$c") del disco (no UTF-8), Edit que cierra" "$o" deny
  mkp "$P"; CAB en-revisión aprobado "pendiente $g" sí > "$P/requirements/REQ-900.md"
  o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$H/guard.sh" < "$W/in" 2>/dev/null)"; juzga "H Seguridad: 140KB de bytes $(printf %q "$c") del disco, Edit que cierra" "$o" deny
done
mkp "$P"; in_write "requirements/$(rep 3000 d/)REQ-1.md" x > "$W/in"; o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$H/guard.sh" < "$W/in" 2>/dev/null)"; juzga "H ruta de 6 KB bajo requirements/ (Write)" "$o" deny
in_bash "git reset --hard $(rep 200000 a)" > "$W/in"; o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$H/guard.sh" < "$W/in" 2>/dev/null)"; juzga "H git reset --hard con argumento de 200 KB" "$o" deny
in_bash "echo x > src/$(rep 100000 ñ)" > "$W/in"; o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$H/guard.sh" < "$W/in" 2>/dev/null)"; juzga "H escritura por Bash a src/ con nombre de 200 KB de ñ" "$o" deny
echo "# total $n casos, $mal MAL"
