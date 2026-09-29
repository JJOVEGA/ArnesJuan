. "$(dirname "$0")/qa-lib.sh"
E0='Estado: en-revisión'; EC='Estado: completado'; S0='Sensible a seguridad: sí'; Q0='QA: aprobado'; G0='Seguridad: aprobado'; H0='Hallazgos abiertos: (ninguno)'; HC='Hallazgos abiertos: SEC-1 (contrato)'; R0='Rigor: critico'
cmp_mot() { local id="$1" j; for v in E W; do printf '%s' "$DOC" > "$F"; if [ $v = E ]; then j="$(jedit "$E0" "$EC")"; else j="$(jwrite "${DOC/"$E0"/"$EC"}")"; fi
  juzga "$CAND" "$j"; mc="$MOT"; dc=$DEC; printf '%s' "$DOC" > "$F"; juzga "$BASE" "$j"; mb="$MOT"
  if [ "$mc" = "$mb" ]; then r=IGUAL; else r=DISTINTO; fi
  case "$mc" in *AMBIGUA*) a=con-motivo-REQ-023;; *) a=sin-motivo-REQ-023;; esac
  echo "$id $v cand=$dc base=$DEC motivo=$r $a | ${mc:0:170}"; done; }
doc "$E0" "$S0" "$Q0" "$G0" "$HC" "$R0" "$H0"; cmp_mot U1
doc "$E0" "$S0" "$Q0" "$G0" "$HC" "$R0" "**Hallazgos abiertos:** (ninguno)"; cmp_mot U1b-decorada
doc "$E0" "$S0" "$Q0" "$G0" "$HC" "$H0" "$R0" "$H0"; cmp_mot U1c-tres
doc "$E0" "$S0" "$Q0" "$G0" "$HC" "$R0" "$H0" "$Q0"; cmp_mot U1d-mas-otra-repeticion
doc "$E0" "$S0" "$Q0" "$G0" "$HC" "$R0" "hallazgos abiertos: (ninguno)"; cmp_mot U1e-canonica+variante
