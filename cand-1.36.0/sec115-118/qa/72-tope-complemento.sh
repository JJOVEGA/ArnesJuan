#!/usr/bin/env bash
# 72-tope-complemento.sh <scratch> <hooks> — repara dos defectos de MI instrumento en 70-: (1) los motivos de
# 327 680 bytes iban como argumento de `bash -c` (pasan de 128 KiB y no arrancaba: salida vacía, no es del hook);
# (2) la entrada del aviso de 140 KB se armaba con `jq --arg` (mismo límite: entrada vacía). Aquí por archivo.
# Y el caso «Sensible» de 70- tenía QA y Seguridad aprobados: cerrar es legítimo y no hay nada que denegar (sin
# decisión en los dos árboles, correcto); se sustituye por Seguridad: n/a con Sensible dudoso de 140 KB.
set -u; S="$1"; H="$2"; QD="$(cd "$(dirname "$0")" && pwd)"; . "$QD/h.sh"
W="$(mktemp -d "$S/tope2-XXXX")"; trap 'rm -rf "$W"' EXIT; P="$W/p"
rep() { local k="$1" s="$2" r=''; while [ "$k" -gt 0 ]; do [ $((k & 1)) -eq 0 ] || r+="$s"; s+="$s"; k=$((k >> 1)); done; printf '%s' "$r"; }
juzga() { local o="$2" m b ok=OK why=''
  jq -e . >/dev/null 2>&1 <<< "$o" || { ok=MAL; why+=' json-invalido'; }
  if [ "$3" = deny ]; then m="$(jq -j '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$o" 2>/dev/null; printf x)"; else m="$(jq -j '.systemMessage // empty' <<< "$o" 2>/dev/null; printf x)"; fi
  m="${m%x}"; b="$(LC_ALL=C; printf '%s' "${#m}")"; [ "$b" -le 16384 ] && [ "$b" -gt 0 ] || { ok=MAL; why+=" bytes($b)"; }
  printf '%s' "$m" | iconv -f UTF-8 -t UTF-8 >/dev/null 2>&1 || { ok=MAL; why+=' utf8'; }; [[ "$m" == ARNES:* ]] || { ok=MAL; why+=' comienzo'; }
  printf '%-3s %-58s bytes=%-6s nota=%s%s\n' "$ok" "$1" "$b" "$([[ "$m" == *'motivo acortado'* ]] && echo si || echo no)" "$why"; }
echo "# $(date -Is); hooks $H"
for c in x ñ € 𝄞; do LCB="$(LC_ALL=C; printf '%s' "${#c}")"; rep $(( 327680 / LCB )) "ARNES:$c" > "$W/m"
  o="$(bash -c '. "$1/lib.sh" >/dev/null 2>&1; IFS= read -r -d "" t < "$2"; arnes_deny "$t"' _ "$H" "$W/m" 2>/dev/null)"; juzga "L deny ~327680 B relleno $c (por archivo)" "$o" deny; done
for c in x ñ 𝄞; do case "$c" in x) k=143360 ;; ñ) k=71680 ;; 𝄞) k=35840 ;; esac; rep $k "$c" > "$W/g"
  mkp "$P"; printf '# REQ-900\nEstado: en-revisión\nQA: aprobado\nSeguridad: aprobado\nSensible a seguridad: sí\n\n## Texto\nx\n' > "$P/requirements/REQ-900.md"
  jq -n --arg fp "$P/requirements/REQ-900.md" --arg c "$P" --rawfile g "$W/g" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:"QA: aprobado",new_string:("QA: raro "+$g)}}' > "$W/in"
  o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$H/guard.sh" < "$W/in" 2>/dev/null)"; juzga "H aviso QA: 140KB $c por Edit sin cerrar" "$o" aviso
  mkp "$P"; { printf '# REQ-900\nEstado: en-revisión\nQA: aprobado\nSeguridad: n/a\nSensible a seguridad: quizas '; cat "$W/g"; printf '\n\n## Texto\nx\n'; } > "$P/requirements/REQ-900.md"
  in_edit requirements/REQ-900.md 'Estado: en-revisión' 'Estado: completado' > "$W/in"
  o="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" LANG=C.UTF-8 bash "$H/guard.sh" < "$W/in" 2>/dev/null)"; juzga "H Sensible dudoso 140KB $c, Seguridad n/a, Edit que cierra" "$o" deny
done
