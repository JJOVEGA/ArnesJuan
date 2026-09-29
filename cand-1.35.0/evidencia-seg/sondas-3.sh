# Clase «motivo sin tope»: arnes_deny pasa el motivo como UN argumento de jq; > MAX_ARG_STRLEN (128 KiB) -> jq no arranca -> exit 0 sin salida -> allow.
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
casoT() { local id="$1" o="$2" n="$3" j h
  printf '%s' "$DOC" > "$F"; j="$(jedit "$o" "$n")"; printf '%s' "$j" > $E/.j
  for h in "$CAND" "$BASE"; do printf '%s' "$DOC" > "$F"
    t0=$(date +%s.%N); out=$(CLAUDE_PROJECT_DIR=$P timeout 150 bash "$h/guard.sh" < $E/.j 2>$E/.err); rc=$?; t1=$(date +%s.%N)
    if [ -z "$out" ]; then d=allow; else d=$(jq -r .hookSpecificOutput.permissionDecision <<< "$out"); fi
    printf '%-44s %-5s dec=%-5s rc=%s t=%ss motivo=%sB err=%s\n' "$id" "$([ "$h" = "$CAND" ] && echo cand || echo base)" "$d" "$rc" "$(awk -v a=$t0 -v b=$t1 'BEGIN{printf "%.1f",b-a}')" "${#out}" "$(head -c 90 $E/.err | tr '\n' ' ')"
  done; }
X140=$(head -c 140000 /dev/zero | tr '\0' 'x')
doc "$S0" "$T" "QA: pendiente—$X140" "$G" "$H" "$R0";                 casoT "MA QA sin parentesis ~140KB (\$qa)" "$S0" "$C"
doc "$S0" "$T" "QA: pendiente (${X140})" "$G" "$H" "$R0";              casoT "MA0 control: QA con parentesis ~140KB" "$S0" "$C"
doc "$S0" "$T" "$Q" "$G" "$H" "$R0" "Nota ${X140}"$'\r'" fin";         casoT "MB linea sin ':' con CR interior ~140KB" "$S0" "$C"
doc "$S0" "Sensible a seguridad: quiza$X140" "$Q" 'Seguridad: pendiente' "$H" "$R0"; casoT "MC Sensible dudoso ~140KB (SENS_CRUDO)" "$S0" "$C"
doc "$S0" "$T" "$Q" "Seguridad: pendiente—$X140" "$H" "$R0";          casoT "MD Seguridad sin parentesis ~140KB (\$seg)" "$S0" "$C"
for n in 1500 2000 2500; do
  L=(); for ((i=0;i<n;i++)); do L+=('Hallazgos abiertos: (ninguno)'); done
  doc "$S0" "$T" "$Q" "$G" 'Hallazgos abiertos: SEC-1 (contrato)' "${L[@]}" "$R0"; casoT "ME CA-A12 con $((n+1)) canonicas" "$S0" "$C"
done
