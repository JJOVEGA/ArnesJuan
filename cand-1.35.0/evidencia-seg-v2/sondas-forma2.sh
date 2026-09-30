. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2/lib-sonda.sh
S0='Estado: en-revisión'; C='Estado: completado'
doc "$S0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico'
for d in 9000 10001; do
  nest=$(printf '[%.0s' $(seq $d))$(printf ']%.0s' $(seq $d))
  j="{\"tool_name\":\"Edit\",\"cwd\":\"$P\",\"agent_type\":\"auditor-seguridad\",\"tool_input\":{\"file_path\":\"$F\",\"old_string\":\"$S0\",\"new_string\":\"$C\",\"x\":$nest}}"
  for h in "$CAND" "$BASE"; do printf '%s' "$DOC" > "$F"; juzga "$h" "$j"; echo "N$d anidamiento $d en clave extra, cierre con QA pendiente: $(basename $(dirname $h)) dec=$DEC err=$(head -c 120 $E2/.err | tr '\n' ' ')"; done
done
