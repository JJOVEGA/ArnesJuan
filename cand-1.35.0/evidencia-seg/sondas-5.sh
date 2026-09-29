# Coste por linea de cabecera (observacion, no acreditacion): N lineas de relleno + QA pendiente; Edit de cierre. Una corrida por punto.
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg/lib-sonda.sh
T='Sensible a seguridad: sí'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'; R0='Rigor: critico'; S0='Estado: en-revisión'; C='Estado: completado'
for tipo in 'Nota: x' 'Prioridad: alta' 'Seguridad del estado: x'; do
 for n in 20000 60000; do
  L=(); for ((i=0;i<n;i++)); do L+=("$tipo"); done
  doc "$S0" "$T" 'QA: pendiente' "$G" "$H" "$R0" "${L[@]}"
  j="$(jedit "$S0" "$C")"
  for h in "$CAND" "$BASE"; do printf '%s' "$DOC" > "$F"
    t0=$(date +%s.%N); out=$(CLAUDE_PROJECT_DIR=$P timeout 150 bash "$h/guard.sh" <<< "$j" 2>/dev/null); t1=$(date +%s.%N)
    d=allow; [ -n "$out" ] && d=$(jq -r .hookSpecificOutput.permissionDecision <<< "$out")
    printf '%-26s N=%-6s %-4s dec=%-5s t=%ss doc=%sB\n' "'$tipo'" $n "$([ "$h" = "$CAND" ] && echo cand || echo base)" $d "$(awk -v a=$t0 -v b=$t1 'BEGIN{printf "%.1f",b-a}')" ${#DOC}
  done
 done
done
