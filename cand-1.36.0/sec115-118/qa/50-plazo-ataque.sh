#!/usr/bin/env bash
# 50-plazo-ataque.sh <scratch> <hooks>... — CA-68 (SEC-115): ¿hay un juicio que pase de 40 s (o de 60) fuera de
# los vectores T1-T3? Por guard.sh, coordinadora, `timeout 60`, LANG=C.UTF-8, una corrida por punto.
#  T4  Edit pequeño que cierra un REQ GRANDE EN DISCO (el techo de piezas mide la entrada, no el disco):
#      cuerpo de líneas de 80 bytes, LF o CRLF, de 660 KB a 4 MB.
#  T5  la búsqueda del old_string justo por debajo del presupuesto 2^32, ASCII y multibyte (ñ, 𝄞).
#  T6  Write justo por debajo del techo de piezas (~393 000 bytes) con rellenos adversos: LF, CRLF, CR suelto,
#      ñ y 4 bytes.
set -u; S="$1"; shift; QD="$(cd "$(dirname "$0")" && pwd)"; . "$QD/h.sh"
W="$(mktemp -d "$S/plazo-XXXX")"; trap 'rm -rf "$W"' EXIT; P="$W/p"
CAB='# REQ-900\nEstado: en-revisión\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\n\n## Texto\n'
cuerpo() { # <bytes> <fin de línea: lf|crlf> <relleno de 1 byte|ñ|𝄞>
  local n="$1" fl lin; case "$2" in lf) fl=$'\n' ;; crlf) fl=$'\r\n' ;; cr) fl=$'\r' ;; esac
  case "$3" in x) lin="$(printf '%079d' 0 | tr 0 x)" ;; ñ) lin="$(printf 'ñ%.0s' $(seq 39))x" ;; 4) lin="$(printf '𝄞%.0s' $(seq 19))xxx" ;; esac
  lin+="$fl"; local LC_ALL=C; local k=$(( n / ${#lin} + 1 )); local r='' s="$lin"
  while [ "$k" -gt 0 ]; do [ $((k & 1)) -eq 0 ] || r+="$s"; s+="$s"; k=$((k >> 1)); done; printf '%s' "${r:0:n}"; }
caso() { # <nombre> <archivo-entrada>
  local H; for H in "${HS[@]}"; do printf '%-34s %-28s %s\n' "$1" "${H#/home/juan/dev/}" "$(corre "$H" guard.sh "$2")"; done; }
HS=("$@")
echo "# $(date -Is); loadavg $(cat /proc/loadavg); bash $BASH_VERSION"
for fl in lf crlf; do for n in 660000 1000000 2000000 4000000; do
  mkp "$P"; { printf "$CAB"; cuerpo "$n" "$fl" x; } > "$P/requirements/REQ-900.md"
  in_edit requirements/REQ-900.md 'Estado: en-revisión' 'Estado: completado' > "$W/in"
  caso "T4 disco $n $fl, Edit que cierra" "$W/in"
done; done
# T5: título con una racha de N caracteres; old_string = la mitad final de la racha + salto + "Estado: en-revisión", que
# cierra; (bytes doc + new) x bytes old justo bajo 2^32.
for c in a ñ 𝄞; do
  case "$c" in a) b=1 ;; ñ) b=2 ;; 𝄞) b=4 ;; esac
  for par in 131072:32000 65536:65000 262144:16000; do
    nd=$(( ${par%%:*} / b )); no=$(( ${par#*:} / b ))
    mkp "$P"; racha="$(printf "%${nd}s" | sed "s/ /$c/g")"; old="$(printf "%${no}s" | sed "s/ /$c/g")"
    printf '# REQ-900 %s\nEstado: en-revisión\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\n\n## Texto\nx\n' "$racha" > "$P/requirements/REQ-900.md"
    in_edit requirements/REQ-900.md "$old"$'\nEstado: en-revisión' "$old"$'\nEstado: completado' > "$W/in"
    caso "T5 busqueda $c doc ${par%%:*}B old ${par#*:}B" "$W/in"
  done
done
for fl in lf crlf cr; do for r in x ñ 4; do
  mkp "$P"; { printf "$CAB" | sed 's/en-revisión/completado/'; cuerpo 392900 "$fl" "$r"; } > "$W/cont"
  jq -Rs --arg fp "$P/requirements/REQ-900.md" --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$fp,content:.}}' < "$W/cont" > "$W/in"
  caso "T6 Write 392900+cab $fl $r" "$W/in"
done; done
echo "# fin $(date -Is); loadavg $(cat /proc/loadavg)"
