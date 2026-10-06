#!/usr/bin/env bash
# 20-tope.sh <hooksdir> — QA-007-12 / CA-67: el tope de 16 384 bytes del motivo con bytes que NO son UTF-8 venidos del
# disco, y control con UTF-8 válido. Por guard.sh, a nivel de hook. Una corrida por punto.
# Por caso: decisión; bytes del motivo decodificado (jq -j); UTF-8 válido (iconv); empieza por "ARNES:"; nota de acortado;
# conserva el comienzo esperado (prefijo fijo del valor); bytes de la línea emitida. MAL si: no JSON, motivo > 16384,
# no UTF-8 o no empieza por ARNES: (v2: corregidos tres defectos de la v1, ver descartadas/LEEME.txt).
set -u
QA=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec115-118/qa; HD="$1"
W="${TMPDIR:-/tmp}/qa2-tope-$$"; mkdir -p "$W"; . "$QA/h.sh"; P="$W/p"; mkp "$P"
export LC_ALL=C
rep() { local s="$1" n="$2" o=''; while [ "${#o}" -lt "$n" ]; do o+="$s$s$s$s$s$s$s$s"; done; printf '%s' "${o:0:n}"; }   # bytes (LC_ALL=C)
mal=0; tot=0
caso() {  # <etiqueta> <campo> <valor-bytes> <via: cierre|aviso>
  local et="$1" campo="$2" val="$3" via="$4" o d mb utf ini nota lb res=OK
  { printf '# REQ-900\nEstado: en-revisión\n'; [ "$campo" = QA ] && printf 'QA: %s\n' "$val" || printf 'QA: aprobado\n'
    [ "$campo" = Seguridad ] && printf 'Seguridad: %s\n' "$val" || printf 'Seguridad: pendiente\n'
    printf 'Sensible a seguridad: sí\n\n## Texto\nx\n'; } > "$P/requirements/REQ-900.md"
  if [ "$via" = cierre ]; then in_edit requirements/REQ-900.md 'Estado: en-revisión' 'Estado: completado' > "$W/in"
  else in_edit requirements/REQ-900.md 'QA: ' 'QA: z' > "$W/in"; fi   # aviso: la línea resultante lleva los bytes del disco
  o="$(cd "$P" && env -u POSIXLY_CORRECT -u BASH_ENV LC_ALL=C.UTF-8 LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$HD/guard.sh" < "$W/in" 2>/dev/null)"
  lb=${#o}
  if ! printf '%s' "$o" | jq -e . >/dev/null 2>&1; then d=NOJSON; res=MAL
  else
    d=$(printf '%s' "$o" | jq -r 'if .hookSpecificOutput then .hookSpecificOutput.permissionDecision else (if .systemMessage then "aviso" else "otra" end) end')
    printf '%s' "$o" | jq -j '.hookSpecificOutput.permissionDecisionReason // .systemMessage // ""' > "$W/m"
    mb=$(wc -c < "$W/m"); iconv -f UTF-8 -t UTF-8 "$W/m" >/dev/null 2>&1 && utf=si || utf=NO
    [ "$(head -c 6 "$W/m")" = "ARNES:" ] && ini=si || ini=NO
    grep -q 'motivo acortado' "$W/m" && nota=si || nota=no
    [ "$mb" -le 16384 ] || res=MAL; [ "$utf" = si ] || res=MAL; [ "$ini" = si ] || res=MAL
    grep -qi "QAPFX\|SEGPFX" "$W/m" && pfx=si || pfx=no
  fi
  tot=$((tot+1)); [ "$res" = OK ] || mal=$((mal+1))
  printf '%s|%s|%s|motivo=%sB|utf8=%s|ARNES=%s|nota=%s|prefijo=%s|linea=%sB\n' "$res" "$et" "$d" "${mb:-?}" "${utf:-?}" "${ini:-?}" "${nota:-?}" "${pfx:-?}" "$lb"
}
echo "# 20-tope.sh hooks=$HD $(date -Is)"
for campo in QA Seguridad; do pf=QAPFX; [ $campo = Seguridad ] && pf=SEGPFX
 for via in cierre aviso; do
  [ $campo = Seguridad ] && [ $via = aviso ] && continue
  # 1) bytes inválidos puros, varios tamaños (por debajo y por encima del tope tras U+FFFD)
  for b in ff 80 c3 c0af eda080 f09d84 f5 fe; do bb=$(printf "$(echo $b | sed 's/../\\x&/g')")
   for n in 4000 5300 5500 6000 20000 140000; do caso "$campo/$via inval=$b n=$n" $campo "$pf$(rep "$bb" $n)" $via; done; done
  # 2) prefijo válido largo y bytes inválidos en el punto de corte (posición final)
  for pre in 15000 16100 16300 16350; do for b in ff c3 e282 f09d84; do bb=$(printf "$(echo $b | sed 's/../\\x&/g')")
   caso "$campo/$via ascii=$pre+inval=$b x400" $campo "$pf$(rep a $pre)$(rep "$bb" 400)" $via; done; done
  # 3) inválidos alternados con multibyte válido (ñ, €, 𝄞)
  for v in $'\xc3\xb1' $'\xe2\x82\xac' $'\xf0\x9d\x84\x9e'; do caso "$campo/$via alterna valido+ff n=60000" $campo "$pf$(rep "$v"$'\xff' 60000)" $via; done
  # 4) control: UTF-8 válido de 1 a 4 bytes, desfase 0-3, alrededor del tope y grande
  for v in a $'\xc3\xb1' $'\xe2\x82\xac' $'\xf0\x9d\x84\x9e'; do for off in 0 1 2 3; do for n in 16000 16384 16500 140000; do
   caso "$campo/$via valido=${#v}B off=$off n=$n" $campo "$pf$(rep z $off)$(rep "$v" $n)" $via; done; done; done
 done
done
echo "# fin $(date -Is): $tot casos, $mal MAL"
rm -rf "$W"
