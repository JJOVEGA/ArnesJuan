. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
R=/home/juan/dev/ArnesJuan-v1.35; F=$P/requirements/REQ-023.md
EST=$(sed -n 2p $R/requirements/REQ-023.md)
( . $CAND/lib.sh; arnes_campos_req "$(cat $R/requirements/REQ-023.md)" ''; echo "lector: AMBIGUA=$ARNES_AMBIGUA lineas_ambiguas=${#ARNES_AMB_N[@]} QA=<$ARNES_QA> SEG=<$ARNES_SEG> HALL_N=$ARNES_HALL_N rigor=<$ARNES_RIGOR> bytes_Hallazgos=$(sed -n 9p $R/requirements/REQ-023.md | wc -c)" )
v() { local id="$1" doc="$2" j; printf '%s' "$doc" > "$F"; j=$(jq -cn --arg f "$F" --arg o "$EST" --arg n 'Estado: completado' --arg p "$P" '{tool_name:"Edit",cwd:$p,agent_type:"auditor-seguridad",tool_input:{file_path:$f,old_string:$o,new_string:$n}}')
  juzga "$CAND" "$j"; echo "$id: dec=$DEC | ${MOT:0:230}"; }
D0=$(cat $R/requirements/REQ-023.md)
v "V1 copia tal cual, cierre" "$D0"
D1=$(sed -e '7s/.*/QA: aprobado (copia de prueba)/' -e '8s/^Seguridad: pendiente/Seguridad: aprobado/' <<< "$D0")
v "V2 QA y Seguridad aprobados, cierre (espera deny por QA-023-05 contrato)" "$D1"
D2=$(sed -e '9s/, QA-023-05 (contrato, [^)]*)//' <<< "$D1")
echo "   (V3 lista: $(sed -n 9p <<< "$D2" | grep -o '[A-Z]*-[0-9-]* ([a-z/]*' | tr '\n' ' '))"
v "V3 sin QA-023-05, cierre (espera allow: SEC-117, SEC-118 y QA-023-02 son instrumento)" "$D2"
