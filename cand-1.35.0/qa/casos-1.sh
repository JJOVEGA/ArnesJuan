#!/usr/bin/env bash
# Casos independientes de QA, REQ-023 vuelta 1. Uso: bash casos-1.sh
. "$(dirname "$0")/qa-lib.sh"
E0='Estado: en-revisión'; EC='Estado: completado'; S0='Sensible a seguridad: sí'; SN='Sensible a seguridad: no'
Q0='QA: aprobado'; QP='QA: pendiente'; G0='Seguridad: aprobado'; GP='Seguridad: pendiente'
H0='Hallazgos abiertos: (ninguno)'; HC='Hallazgos abiertos: SEC-1 (contrato)'; R0='Rigor: critico'; RL='Rigor: ligero'
BOM=$'\xef\xbb\xbf'; ZW=$'\xe2\x80\x8b'; NB=$'\xc2\xa0'; DEL=$'\x7f'; C1=$'\x01'

todas() { local id="$1" esp="$2" v; shift 2; for v in E W M; do prueba "$id" "$v" "$DOC" "$E0" "$EC" "$esp"; done; }

echo "### LEGITIMOS (esperado allow en la candidata)"
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0"; todas L01-F0 allow
doc "**Estado:** en-revisión" "**Sensible a seguridad:** sí" "_QA_: aprobado" '`Seguridad`: aprobado' "**Hallazgos abiertos:** (ninguno)" "__Rigor__: critico"
prueba L02-decoradas E "$DOC" 'en-revisión' 'completado' allow; prueba L02-decoradas W "$DOC" 'en-revisión' 'completado' allow
doc " Estado: en-revisión" $'\t'"$S0" "QA : aprobado" "Seguridad :aprobado" "  $H0  " "$R0"; todas L03-sangria-blancos allow
doc "$E0" "$S0" "QA: aprobado (R-9, 2026-09-29)" "Seguridad: aprobado (R-10)" "$H0" "Rigor: critico (piso)"; todas L04-parentesis allow
doc "Estado: en-revision" "Sensible a seguridad: si" "$Q0" "$G0" "$H0" "$R0"
prueba L05-plegado E "$DOC" 'Estado: en-revision' "$EC" allow; prueba L05-plegado W "$DOC" 'Estado: en-revision' "$EC" allow
doc "$E0" "Módulo: hooks" "Versión destino: 1.35.0" "Prioridad: alta" "Archivos: a.sh, b.sh" "Nota: la seguridad del estado se revisa aparte." "$S0" "$Q0" "$G0" "$H0" "$R0" "Tocado por: qa / 2026-09-29" "Dueño: año · § — ñandú"; todas L06-prosa allow
doc "$E0" "$Q0"; todas L07-ausencias allow
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "<!-- qa: pendiente -->" "<!--Rigor: ligero-->" "<!--"$'\n'"HALLAZGOS ABIERTOS: SEC-1 (contrato)"$'\n'"-->"; todas L08-comentarios allow
doc "$E0" "$S0" "$Q0" "$G0" "Hallazgos abiertos: SEC-1 (instrumento), QA-2 (instrumento, R-3)" "$R0"; todas L09-hall-lista allow
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "> Estado: completado" "> QA: pendiente" "«QA»: pendiente" "“Rigor”: ligero" "‘Estado’: completado" "„QA“: x" "‹Rigor›: ligero" "(Sensible a seguridad): no" "[Hallazgos abiertos]: SEC-1 (contrato)" "Q&A: pendiente" "Estado (histórico): completado" "QA/Seguridad: pendiente" "Rigor.: ligero" "# QA: pendiente" "<b>QA</b>: pendiente" "Estado-previo: borrador" "1234. QA: pendiente" "- - QA: pendiente"
todas L10-estructura allow
echo "### VARIANTES (esperado deny en la candidata; base y N allow)"
doc "$E0" "$S0" "Qa: pendiente" "$G0" "$H0" "$R0"; todas V01-Qa deny
doc "$E0" "$S0" "$Q0" "$G0" $'Hallazgos\tabiertos: SEC-1 (contrato)' "$R0"; todas V02-tab-interior deny
doc "$E0" "$S0" "$Q0" "$G0" "Hallazgos_abiertos: SEC-1 (contrato)" "$R0"; todas V03-guionbajo deny
doc "$E0" "$S0" "$Q0" "$G0" "Hallazgos*abiertos: SEC-1 (contrato)" "$R0"; todas V04-asterisco-interior deny
doc "$E0" "$S0" "$Q0" "$G0" "Hallazgos${DEL}abiertos: SEC-1 (contrato)" "$R0"; todas V05-DEL deny
doc "$E0" "$S0" "$Q0" "$G0" "${C1}Hallazgos abiertos: SEC-1 (contrato)" "$R0"; prueba V06-C0-disco E "$DOC" "$E0" "$EC" deny
doc "$E0" "$S0" "+ QA: pendiente" "$G0" "$H0" "$R0"; todas V07-mas deny
doc "$E0" "10) Sensible a seguridad: sí" "$QP" "$GP" "$H0" "$RL"; todas V08-10paren deny
doc "$E0" "$S0" "123. QA: pendiente" "$G0" "$H0" "$R0"; todas V09-3digitos deny
doc "$E0" "$S0" $'-\tQA: pendiente' "$G0" "$H0" "$R0"; todas V10-guion-tab deny
doc "$E0" "$S0" "-  QA: pendiente" "$G0" "$H0" "$R0"; todas V11-guion-2esp deny
doc "$E0" "$S0" "$QP" "* QA: aprobado" "$G0" "$H0" "$R0"; todas V12-asterisco-marcador-repite deny
doc "$E0" "$S0" "$Q0" "QA: aprobado (R-2)" "$G0" "$H0" "$R0"; todas V13-QA-2-valores-parecidos deny
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "$E0"; prueba V14-Estado-dup-mismo E "$DOC" "$E0" "$EC" deny
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "ESTADO: completado"; prueba V15-Estado-var-terminal-W W "$DOC" "$R0" "$R0 " deny
doc "$E0" "estado: en-revisión" "$S0" "$Q0" "$G0" "$H0" "$R0"; todas V16-Estado-var-no-terminal deny
doc "$E0" "Sensible${NB}a seguridad: sí" "$QP" "$GP" "$H0" "$RL"; todas V17-NBSP-sens deny
doc "$E0" "Sensible a seguridad"$'\xe3\x80\x80'": sí" "$QP" "$GP" "$H0" "$RL"; todas V18-U3000-final deny
doc "$E0" "Sensible a"$'\xe2\x80\x8d'" seguridad: sí" "$QP" "$GP" "$H0" "$RL"; todas V19-ZWJ deny
doc "$E0" "Sensible a"$'\xc2\xad'" seguridad: sí" "$QP" "$GP" "$H0" "$RL"; todas V20-softhyphen deny
doc "$E0" "Esta"$'\xcc\x81'"do: completado" "$S0" "$Q0" "$G0" "$H0" "$R0"; prueba V21-combinante-Estado-terminal E "$DOC" "$R0" "$R0 " deny
doc "$E0" "$S0" "Q<!-- x -->A: pendiente" "$G0" "$H0" "$R0"; todas V22-comentario-dentro-clave deny
doc "$E0" "$S0" $'\xe2\x80\xa2'" QA: pendiente" "$G0" "$H0" "$R0"; todas V23-vineta-unicode deny
doc "$E0" "$S0" $'\xe3\x80\x8c'"QA"$'\xe3\x80\x8d'": pendiente" "$G0" "$H0" "$R0"; todas V24-comillas-cjk-no-listadas deny
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "Rigor: critico"; todas V25-Rigor-dup-mismo deny
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "Seguridad: aprobado"; todas V26-Seguridad-dup-mismo deny
doc "$E0" "$S0" "$S0" "$Q0" "$G0" "$H0" "$R0"; todas V27-Sensible-dup-mismo deny
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "RIGOR: critico"; todas V28-Rigor-var-mismo deny
echo "### ESTADO: detección del intento de cierre"
doc "$E0" "$S0" "$QP" "$G0" "$H0" "$R0" "ESTADO: Completado (2026-09-29)"; prueba T01-var-terminal-mayus-parentesis E "$DOC" "$R0" "$R0 " deny
doc "Estado:" "$S0" "$Q0" "$G0" "$H0" "$R0" "Estado: completado"; prueba T02-primero-vacio W "$DOC" "$R0" "$R0 " deny
doc "$E0" "$S0" "$QP" "$G0" "$H0" "$R0" "- Estado: completado"; prueba T03-marcador-estado-terminal E "$DOC" "$R0" "$R0 " deny
doc "$E0" "$S0" "$QP" "$G0" "$H0" "$R0" "**ESTADO:** completado"; prueba T04-var-decorada E "$DOC" "$R0" "$R0 " deny
doc "$E0" "$S0" "$QP" "$G0" "$H0" "$R0" "Еstado: completado"; prueba T05-homoglifo-terminal-fuera E "$DOC" "$R0" "$R0 " allow
echo "### EDIT / MULTIEDIT / WRITE mecanica"
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0"
printf '%s' "$DOC" > "$F"; J="$(jmulti "$E0" "$EC" "$Q0" "$Q0"$'\n'"qa: pendiente")"; juzga "$CAND" "$J"; c=$DEC; printf '%s' "$DOC" > "$F"; juzga "$BASE" "$J"; echo "M01-multi-cierra+variante      cand=$c base=$DEC"
printf '%s' "$DOC" > "$F"; J="$(jmulti "NOEXISTE" "x" "$E0" "$EC"$'\n'"qa: pendiente")"; juzga "$CAND" "$J"; c=$DEC; cm="${MOT:0:120}"; printf '%s' "$DOC" > "$F"; juzga "$BASE" "$J"; echo "M02-multi-old-ausente(g)       cand=$c base=$DEC | $cm"
doc "$E0" "$S0" "$QP" "$GP" "$H0" "$RL"; printf '%s' "$DOC" > "$F"
J="$(jedit "$E0"$'\n'"$S0" "$EC"$'\n'"${BOM}$S0")"; juzga "$CAND" "$J"; c=$DEC; printf '%s' "$DOC" > "$F"; juzga "$BASE" "$J"; echo "M03-edit-cierra+BOM-en-new     cand=$c base=$DEC"
rm -f "$F"; doc "$EC" "$S0" "qa: pendiente" "$G0" "$H0" "$R0"; J="$(jwrite "$DOC")"; juzga "$CAND" "$J"; c=$DEC; rm -f "$F"; juzga "$BASE" "$J"; echo "M04-write-archivo-nuevo        cand=$c base=$DEC"
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "qa: aprobado"; printf '%s' "$DOC" > "$F"
J="$(jq -cn --arg fp "$F" --arg o 'en-revisión' --arg n 'completado' '{hook_event_name:"PreToolUse",tool_name:"Edit",tool_input:{file_path:$fp,old_string:$o,new_string:$n,replace_all:true}}')"; juzga "$CAND" "$J"; c=$DEC; printf '%s' "$DOC" > "$F"; juzga "$BASE" "$J"; echo "M05-edit-replace_all           cand=$c base=$DEC"
echo "### REAPERTURA / CERRADO"
doc "$EC" "$S0" "qa: pendiente" "$Q0" "$G0" "$H0" "$R0"; prueba C01-reabrir E "$DOC" "$EC" "Estado: en-progreso" allow
prueba C02-cerrado-editar-otra E "$DOC" "$R0" "$R0 " allow
prueba C03-cerrado-write-igual W "$DOC" "x" "x" allow
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "ESTADO: completado"; prueba C04-disco-var-terminal-editar-otra E "$DOC" "$R0" "$R0 " deny
prueba C05-disco-var-terminal-retirarla E "$DOC" $'\nESTADO: completado' "" allow
prueba C06-disco-var-terminal-corregirla E "$DOC" "ESTADO: completado" "Nota: completado" allow
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "qa: pendiente"; prueba C07-editar-otra-sin-cerrar E "$DOC" "$R0" "$R0 " allow
echo "### CRLF entero"
doc "$E0" "$S0" "Qa: pendiente" "$G0" "$H0" "$R0"; D="${DOC//$'\n'/$'\r\n'}"; for v in E W M; do prueba X01-crlf-variante "$v" "$D" "$E0" "$EC" deny; done
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0" "$Q0"; D="${DOC//$'\n'/$'\r\n'}"; for v in E W; do prueba X02-crlf-dup "$v" "$D" "$E0" "$EC" deny; done
doc "$E0" "$S0" "$Q0" "$G0" "$H0" "$R0"; D="${DOC//$'\n'/$'\r\n'}"; for v in E W; do prueba X03-crlf-legitimo "$v" "$D" "$E0" "$EC" allow; done
echo "### FRONTERA F (sigue como hoy; allow en las tres)"
doc "$E0" "$S0" "$Q0" "$G0" "Hallazgоs abiertos: SEC-1 (contrato)" "$R0"; todas F01-homoglifo allow
doc "$E0" "$S0" "$Q0" "$G0" "Hallazgos abiertos：SEC-1 (contrato)" "$R0"; todas F02-dospuntos-ancho allow
doc "$E0" "$S0" "$Q0" "$G0" "Hallazgo abierto: SEC-1 (contrato)" "$R0"; todas F03-letra-menos allow
doc "$E0" "$S0" "$Q0" "$G0" "-${NB}Hallazgos abiertos: SEC-1 (contrato)" "$R0"; todas F04-guion-NBSP allow
doc "$E0" "$S0" "$Q0" "$G0" "-${BOM} Hallazgos abiertos: SEC-1 (contrato)" "$R0"; todas F05-guion-BOM-espacio allow
P=''; for i in $(seq 238); do P+="$C1"; done
doc "$E0" "$S0" "$Q0" "$G0" "${P}Hallazgos abiertos: SEC-1 (contrato)" "$R0"; prueba F06-clave-256-bytes E "$DOC" "$E0" "$EC" deny
doc "$E0" "$S0" "$Q0" "$G0" "${P}${C1}Hallazgos abiertos: SEC-1 (contrato)" "$R0"; prueba F07-clave-257-bytes-LIMITACION E "$DOC" "$E0" "$EC" allow
P=''; for i in $(seq 79); do P+="$ZW"; done
doc "$E0" "$S0" "$Q0" "$G0" "${P}Hallazgos abiertos: SEC-1 (contrato)" "$R0"; prueba F08-79ZW-255B E "$DOC" "$E0" "$EC" deny; prueba F08-79ZW-255B W "$DOC" "$E0" "$EC" deny
doc "$E0" "$S0" "$Q0" "$G0" "${P}${ZW}Hallazgos abiertos: SEC-1 (contrato)" "$R0"; prueba F09-80ZW-258B-LIMITACION W "$DOC" "$E0" "$EC" allow
doc "$E0" "$S0" "QA: apro${ZW}bado" "$G0" "$H0" "$R0"; todas F10-valor-ZW deny
echo "TOTAL=$TOT INESPERADOS=$MAL"
