# CA-13 (SEC-117) contra la puerta real: cand (5dfabb3 = 8745b3f) / r045 (31d2a21) / base (713ac68).
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2/lib-sonda.sh
BS=$(printf '\\'); S0='Estado: en-revisión (tras “R-4”)'; C='Estado: completado'
ROJO() { doc "$S0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: SEC-1 (contrato)' 'Rigor: critico' 'Prioridad: alta'; }
VERDE() { doc "$S0" 'Sensible a seguridad: sí' 'QA: aprobado' 'Seguridad: aprobado' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico' 'Prioridad: alta'; }
echo "## A. No reconstruible sobre requirements/ -> deny (REQ rojo)"
ROJO; caso "K1 control literal, cierre" jedit "en-revisión (tras “R-4”)" 'completado'
ROJO; caso "N1 comillas rectas (el caso del host), cierre" jedit 'en-revisión (tras "R-4")' 'completado'
ROJO; caso "N2 \\u00f3 literal, cierre" jedit "en-revisi${BS}u00f3n" 'completado'
ROJO; caso "N3 old inexistente, sin estado" jedit 'NO-EXISTE' 'x'
ROJO; caso "N4 old vacio sobre archivo existente" jedit '' "$C"
ROJO; caso "N5 old con blanco final de mas" jedit 'Prioridad: alta ' 'Prioridad: baja'
ROJO; caso "N6 MultiEdit: 1 literal + 2 no literal" jmulti2 'Prioridad: alta' 'Prioridad: media' 'en-revisi'"${BS}"'u00f3n' 'completado'
VERDE; caso "N7 MultiEdit: 2 casa lo que deja 1 (legitimo)" jmulti2 'Prioridad: alta' 'Prioridad: media' 'Prioridad: media' 'Prioridad: baja'
VERDE; caso "N8 no literal en el cuerpo, sin tocar estado (REQ verde)" jedit '- CA-01 x ' 'y'
ROJO; FP=$P/requirements/NUEVO.md caso "N9 Edit sobre REQ inexistente, old no vacio" jedit 'algo' "$C"
echo "## B. Legitimo y reapertura (reconstruible) -> como antes"
VERDE; caso "L1 cierre literal, REQ verde" jedit "en-revisión (tras “R-4”)" 'completado'
VERDE; caso "L2 edicion literal de prosa" jedit 'Prioridad: alta' 'Prioridad: media'
doc 'Estado: completado (tras “R-4”)' 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: SEC-1 (contrato)' 'Rigor: critico'
printf '## Pendientes\n\n### [x] (c) — algo\n\n## Resueltas\n' > $P/PENDING_APPROVAL.md
caso "L3 reapertura literal con cola ocupada" jedit 'completado (tras “R-4”)' 'en-progreso'
caso "L4 reapertura NO literal (comillas rectas)" jedit 'completado (tras "R-4")' 'en-progreso'
rm -f $P/PENDING_APPROVAL.md
echo "## C. Creacion por Edit (old vacio, archivo inexistente)"
NUEVO=$P/requirements/REQ-901.md
CRE() { local id="$1" cont="$2" j h d=''; j=$(jq -cn --arg f "$NUEVO" --arg n "$cont" --arg p "$P" '{tool_name:"Edit",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,old_string:"",new_string:$n}}')
  for h in "$CAND" "$R045" "$BASE"; do rm -f "$NUEVO"; juzga "$h" "$j"; d+="$DEC "; done; printf '%-58s cand/r045/base= %s| %s\n' "$id" "$d" "${MOT:0:0}"; }
CRE "C1 nace completado con QA pendiente" $'# REQ-901\nEstado: completado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\n\n## x\n'
CRE "C2 nace **Estado:** completado con QA pendiente (O-3)" $'# REQ-901\n**Estado:** completado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\n\n## x\n'
CRE "C3 nace en-progreso" $'# REQ-901\nEstado: en-progreso\nQA: pendiente\n\n## x\n'
CRE "C4 nace completado en verde" $'# REQ-901\nEstado: completado\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: aprobado\nHallazgos abiertos: (ninguno)\n\n## x\n'
MC=$(jq -cn --arg f "$NUEVO" --arg p "$P" '{tool_name:"MultiEdit",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,edits:[{old_string:"",new_string:"# REQ-901\nEstado: completado\nQA: pendiente\n\n## x\n"},{old_string:"QA: pendiente",new_string:"QA: pendiente"}]}}')
d=''; for h in "$CAND" "$R045" "$BASE"; do rm -f "$NUEVO"; juzga "$h" "$MC"; d+="$DEC "; done; printf '%-58s cand/r045/base= %s\n' "C5 MultiEdit de creacion con 2 ediciones" "$d"
echo "## D. Otras vias y alcance"
ROJO; FP=$P/docs/nota.md; printf 'Nota “x”\n' > $P/docs/nota.md; j=$(jq -cn --arg f "$P/docs/nota.md" --arg p "$P" '{tool_name:"Edit",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,old_string:"Nota \"x\"",new_string:"y"}}'); juzga "$CAND" "$j"; echo "D1 no literal FUERA de requirements/ (docs/nota.md)            cand=$DEC"; unset FP
ROJO; AG=desarrollador caso "D2 no literal desde el agente desarrollador" jedit 'en-revisión (tras "R-4")' 'completado'
ROJO; printf '%s' "$DOC" > $F; j=$(jq -cn --arg p "$P" --arg c "sed -i 's/en-revisión/completado/' $F" '{tool_name:"Bash",cwd:$p,agent_type:"auditor-seguridad",tool_input:{command:$c}}'); juzga "$CAND" "$j"; echo "D3 Bash sed -i con el estado terminal                         cand=$DEC"
ROJO; C2=$(printf '%s' "$DOC" | sed 's/^Estado: .*/Estado: completado/'); caso "D4 Write de cierre, REQ rojo" jwrite "$C2"
ROJO; DOC="${DOC//$'\n'/$'\r\n'}"; caso "D5 disco CRLF, cierre literal con old LF (rojo)" jedit "en-revisión (tras “R-4”)" 'completado'
VERDE; DOC="${DOC//$'\n'/$'\r\n'}"; caso "D6 disco CRLF, cierre literal con old LF (verde)" jedit "en-revisión (tras “R-4”)" 'completado'
echo "## E. Motivo de CA-13: no hereda SEC-118"
ROJO; BIG=$(printf 'ñ%.0s' $(seq 100000)); printf '%s' "$DOC" > $F; j="$(jedit "$BIG" 'completado')"; printf '%s' "$j" > $E2/.jbig
juzga "$CAND" "$(cat $E2/.jbig)"; echo "E1 old_string no literal de 200 000 bytes multibyte: dec=$DEC motivo=$(printf '%s' "$MOT" | wc -c) bytes; crudo>=0x80: $(printf '%s' "$MOT" | LC_ALL=C grep -c $'[\x80-\xff]')"
echo "   ${MOT:0:0}$(grep -o "El old_string de .\{0,140\}" <<< "$MOT")"
