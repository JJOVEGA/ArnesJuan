#!/usr/bin/env bash
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev/lib-sonda.sh
C=$S/campos; R=/home/juan/dev/ArnesJuan-v1.35
INST=/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.2/hooks
proyecto_nuevo "$S/pcampos"; rm -f "$P"/requirements/*
for r in REQ-023 REQ-031 REQ-001 REQ-007; do cp "$R/requirements/$r.md" "$P/requirements/"; done
corre() { # <hooksdir> <json> -> DEC MOT AVISO
  local out; out="$(CLAUDE_PROJECT_DIR="$P" bash "$1/guard.sh" < "$2" 2>/dev/null)"
  DEC=allow; [[ "$out" == *'"permissionDecision":"deny"'* ]] && DEC=deny
  AV=no; [[ "$out" == *systemMessage* ]] && AV=si
  MOT="$(jq -r '.hookSpecificOutput.permissionDecisionReason // .systemMessage // empty' <<< "$out" 2>/dev/null)"
}
cambia() { # <req> <linea vieja exacta> <linea nueva>
  local f="$P/requirements/$1.md" t
  jq -n --arg fp "$f" --arg o "$2" --arg n "$3" --arg c "$P" '{tool_name:"Edit",cwd:$c,agent_id:"a9",agent_type:"auditor-seguridad",tool_input:{file_path:$fp,old_string:$o,new_string:$n}}' > "$J"
  corre "$S/arb/cand/hooks" "$J"; local dc="$DEC/aviso=$AV"; corre "$INST" "$J"
  printf '%-8s %-26s cand=%s instalada=%s/aviso=%s %s\n' "$1" "${4:-}" "$dc" "$DEC" "$AV" "${MOT:0:120}"
  t="$(cat "$f"; printf x)"; t="${t%x}"; t="${t/"$2"/"$3"}"; printf '%s' "$t" > "$f"
}
lin() { grep -m1 "^$2" "$P/requirements/$1.md"; }
cambia REQ-023 "$(lin REQ-023 'Seguridad:')" "$(cat $C/seg-023.txt)" Seguridad
cambia REQ-031 "$(lin REQ-031 'Seguridad:')" "$(cat $C/seg-031.txt)" Seguridad
cambia REQ-001 "$(lin REQ-001 'Seguridad:')" "$(cat $C/seg-001.txt)" Seguridad
cambia REQ-007 "$(lin REQ-007 'Seguridad:')" "$(cat $C/seg-007.txt)" Seguridad
o119="$(grep -o 'SEC-119 (instrumento, R-045-A: [^)]*)' "$P/requirements/REQ-023.md")"
o120="$(grep -o 'SEC-120 (instrumento, R-045-A: [^)]*)' "$P/requirements/REQ-023.md")"
cambia REQ-023 "$o119" "$(cat $C/hall-023-sec119-nuevo.txt)" "Hallazgos SEC-119"
cambia REQ-023 "$o120" "$(cat $C/hall-023-sec120-nuevo.txt)" "Hallazgos SEC-120"
fin7="$(lin REQ-007 'Hallazgos abiertos:' | tail -c 60)"
cambia REQ-007 "$fin7" "$fin7$(cat $C/hall-007-anexo.txt)" "Hallazgos +SEC-122"
echo "== lector: tools/arnes-lectura.sh sobre la copia =="
( cd "$P" && CLAUDE_PROJECT_DIR="$P" bash "$R/tools/arnes-lectura.sh" 2>&1 | grep -E "REQ-0(23|31|01|07)|AMBIG|variante" | cut -c1-200 ); echo "rc lector: ${PIPESTATUS[0]}"
echo "== cierre simulado: QA y Seguridad en verde, cola vacía, gates true =="
for r in REQ-023 REQ-031 REQ-001 REQ-007; do
  f="$P/requirements/$r.md"; cp "$f" "$f.bak"
  q="$(lin $r 'QA:')"; [ "$r" = REQ-007 ] && { t="$(cat "$f"; printf x)"; t="${t%x}"; t="${t/"$q"/QA: aprobado (simulado)}"; printf '%s' "$t" > "$f"; }
  s="$(lin $r 'Seguridad:')"; [ "$r" = REQ-007 ] && { t="$(cat "$f"; printf x)"; t="${t%x}"; t="${t/"$s"/Seguridad: aprobado (simulado)}"; printf '%s' "$t" > "$f"; }
  e="$(lin $r 'Estado:')"
  jq -n --arg fp "$f" --arg o "$e" --arg c "$P" '{tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:$o,new_string:"Estado: completado"}}' > "$J"
  corre "$S/arb/cand/hooks" "$J"; printf '%-8s cierre cand=%s %s\n' "$r" "$DEC" "${MOT:0:200}"
  corre "$INST" "$J"; printf '%-8s cierre instalada=%s %s\n' "$r" "$DEC" "${MOT:0:200}"
  mv "$f.bak" "$f"
done
for r in REQ-023 REQ-031 REQ-001 REQ-007; do cp "$P/requirements/$r.md" "$C/$r.propuesto.md"; done
