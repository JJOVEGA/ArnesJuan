#!/usr/bin/env bash
# Prueba de los campos de R-047 sobre una COPIA de los cuatro REQ, con la puerta del candidato y con la instalada
# (1.33.2), como edición del auditor-seguridad; luego el lector y un cierre simulado. No toca el worktree.
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/lib-sonda8.sh
C=$S/campos; R=/home/juan/dev/ArnesJuan-v1.35
INST=/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.2/hooks
proyecto_nuevo "$S/pcampos"; rm -f "$P"/requirements/*
for r in REQ-023 REQ-031 REQ-001 REQ-007; do cp "$R/requirements/$r.md" "$P/requirements/"; done
corre() { local out; out="$(cd "$P" && CLAUDE_PROJECT_DIR="$P" bash "$1/guard.sh" < "$2" 2>/dev/null)"
  DEC=allow; [[ "$out" == *'"permissionDecision":"deny"'* ]] && DEC=deny
  AV=no; [[ "$out" == *systemMessage* ]] && AV=si
  MOT="$(jq -r '.hookSpecificOutput.permissionDecisionReason // .systemMessage // empty' <<< "$out" 2>/dev/null)"; }
cambia() { # <req> <old exacto> <new> <etiqueta>
  local f="$P/requirements/$1.md" t dc
  grep -qF -- "$2" "$f" || { echo "$1 $4: OLD NO ENCONTRADO"; return; }
  jq -n --arg fp "$f" --arg o "$2" --arg n "$3" --arg c "$P" '{tool_name:"Edit",cwd:$c,agent_id:"a9",agent_type:"auditor-seguridad",tool_input:{file_path:$fp,old_string:$o,new_string:$n}}' > "$J"
  corre "$S/arb/cand/hooks" "$J"; dc="$DEC/aviso=$AV"; corre "$INST" "$J"
  printf '%-8s %-24s cand=%s instalada=%s/aviso=%s %s\n' "$1" "$4" "$dc" "$DEC" "$AV" "${MOT:0:120}"
  t="$(cat "$f"; printf x)"; t="${t%x}"; t="${t/"$2"/"$3"}"; printf '%s' "$t" > "$f"
}
lin() { grep -m1 "^$2" "$P/requirements/$1.md"; }
cambia REQ-023 "$(lin REQ-023 'Seguridad:')" "$(cat $C/seg-023.txt)" Seguridad
cambia REQ-031 "$(lin REQ-031 'Seguridad:')" "$(cat $C/seg-031.txt)" Seguridad
cambia REQ-001 "$(lin REQ-001 'Seguridad:')" "$(cat $C/seg-001.txt)" Seguridad
cambia REQ-007 "$(lin REQ-007 'Seguridad:')" "$(cat $C/seg-007.txt)" Seguridad
o119="$(grep -o ', SEC-119 (instrumento, R-045-A y R-046: [^)]*)' "$P/requirements/REQ-023.md")"
cambia REQ-023 "$o119" "" "Hallazgos -SEC-119"
o122="$(grep -o 'SEC-122 (contrato, R-046: [^)]*)' "$P/requirements/REQ-007.md")"
cambia REQ-007 "$o122" "$(cat $C/hall-007-nuevos.txt)" "Hallazgos SEC-122->123/124/125"
echo "== lector: tools/arnes-lectura.sh (candidato) sobre la copia =="
( cd "$P" && CLAUDE_PROJECT_DIR="$P" bash "$R/tools/arnes-lectura.sh" > "$S/campos/lector.txt" 2>&1; echo "rc lector: $?" )
grep -iE "anómal|anomal|AMBIG|variante|no medido" "$S/campos/lector.txt" | cut -c1-200 | head; grep -E "REQ-0(23|31|01|07)" "$S/campos/lector.txt" | cut -c1-200 | head
echo "== cierre simulado: cola vacía, gates true =="
cierra() { # <req> <etiqueta> [forzar QA y Seguridad a aprobado: 1] [sustituir Hallazgos por: texto]
  local r="$1" f="$P/requirements/$1.md" t q s e h
  cp "$f" "$f.bak"
  if [ "${3:-0}" = 1 ]; then
    q="$(lin $r 'QA:')"; s="$(lin $r 'Seguridad:')"
    t="$(cat "$f"; printf x)"; t="${t%x}"; t="${t/"$q"/QA: aprobado (simulado)}"; t="${t/"$s"/Seguridad: aprobado (simulado)}"; printf '%s' "$t" > "$f"
  fi
  if [ -n "${4:-}" ]; then h="$(lin $r 'Hallazgos abiertos:')"; t="$(cat "$f"; printf x)"; t="${t%x}"; t="${t/"$h"/Hallazgos abiertos: $4}"; printf '%s' "$t" > "$f"; fi
  e="$(lin $r 'Estado:')"
  jq -n --arg fp "$f" --arg o "$e" --arg c "$P" '{tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:$o,new_string:"Estado: completado"}}' > "$J"
  corre "$S/arb/cand/hooks" "$J"; printf '%-8s %-34s cand=%s %s\n' "$r" "$2" "$DEC" "${MOT:0:170}"
  corre "$INST" "$J"; printf '%-8s %-34s instalada=%s %s\n' "$r" "$2" "$DEC" "${MOT:0:170}"
  mv "$f.bak" "$f"
}
cierra REQ-023 "tal cual"; cierra REQ-031 "tal cual"; cierra REQ-001 "tal cual"; cierra REQ-007 "tal cual"
cierra REQ-007 "QA y Seg forzados" 1
h7="$(lin REQ-007 'Hallazgos abiertos:')"
s124="$(grep -o 'SEC-124 (contrato, R-047: [^)]*)' <<< "$h7")"; s123="$(grep -o 'SEC-123 (instrumento, R-047: [^)]*)' <<< "$h7")"; s125="$(grep -o 'SEC-125 (instrumento, R-047: [^)]*)' <<< "$h7")"
cierra REQ-007 "forzados + sólo SEC-124" 1 "$s124"
cierra REQ-007 "forzados + sólo SEC-123, SEC-125" 1 "$s123, $s125"
for r in REQ-023 REQ-031 REQ-001 REQ-007; do cp "$P/requirements/$r.md" "$C/$r.propuesto.md"; done
echo "== diff de cabecera propuesta frente al worktree (sólo líneas cambiadas) =="
for r in REQ-023 REQ-031 REQ-001 REQ-007; do printf '%s: ' "$r"; diff <(cat "$R/requirements/$r.md") "$C/$r.propuesto.md" | grep -c '^[<>]'; done
