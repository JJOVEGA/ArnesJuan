# R-044-C sobre el codigo final: techo de Hallazgos (255 KB) por Edit/MultiEdit/Write, decorada, reapertura; LC_ALL local.
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
BIG=$(for i in $(seq 7000); do printf 'X-%d (instrumento, evidencia larga de relleno), ' $i; done); BIG="SEC-9 (contrato), ${BIG%, }"
echo "valor Hallazgos: ${#BIG} caracteres"
cT() { local id="$1" via="$2" o="$3" n="$4" j h d
  printf '%s' "$DOC" > "$F"
  case "$via" in E) j="$(jedit "$o" "$n")";; M) j="$(jmulti "$o" "$n")";; W) j="$(jwrite "${DOC/"$o"/"$n"}")";; esac
  printf '%s' "$j" > $E/.j
  for h in "$CAND" "$BASE"; do printf '%s' "$DOC" > "$F"
    t0=$(date +%s.%N); out=$(CLAUDE_PROJECT_DIR=$P timeout 150 bash "$h/guard.sh" < $E/.j 2>/dev/null); t1=$(date +%s.%N)
    if [ -z "$out" ]; then d=allow; else d=$(jq -r .hookSpecificOutput.permissionDecision <<< "$out"); fi
    printf '%-40s %s %-4s dec=%-5s t=%ss | %s\n' "$id" "$via" "$([ "$h" = "$CAND" ] && echo cand || echo base)" "$d" "$(awk -v a=$t0 -v b=$t1 'BEGIN{printf "%.2f",b-a}')" "$(jq -r '.hookSpecificOutput.permissionDecisionReason // ""' <<< "$out" 2>/dev/null | cut -c60-150)"
  done; }
for v in E M W; do doc "$S0" "$T" "$Q" "$G" "Hallazgos abiertos: $BIG" "$R0"; cT "C1 techo, contrato delante" $v "$S0" "$C"; done
doc "$S0" "$T" "$Q" "$G" "**Hallazgos abiertos:** $BIG" "$R0"; cT "C2 techo, decorada" E "$S0" "$C"
doc 'Estado: completado' "$T" "$Q" "$G" "Hallazgos abiertos: $BIG" "$R0"; cT "C3 reapertura con valor sobre techo" E 'Estado: completado' 'Estado: en-progreso'
echo "## LC_ALL local no se filtra (lib.sh candidata, sourced)"
for loc in unset C.UTF-8; do
 ( [ "$loc" = unset ] && unset LC_ALL || export LC_ALL=$loc
   . $CAND/lib.sh
   arnes_campos_req $'# x\nqa: y\n\xef\xbb\xbfRigor: z\n' ''
   v='é·日'; echo "LC_ALL=${LC_ALL-<sin definir>} tras arnes_campos_req: \${#v}=${#v} ARNES_AMBIGUA=$ARNES_AMBIGUA lineas=${#ARNES_AMB_N[@]}"
   arnes_ambigua_motivo; v='é·日'; echo "  tras arnes_ambigua_motivo: \${#v}=${#v} LC_ALL=${LC_ALL-<sin definir>}"; echo "  motivo: $ARNES_AMBIGUA_MOTIVO" )
done
