. "$(dirname "$0")/qa-lib.sh"
E0='Estado: en-revisión'; EC='Estado: completado'
c() { local id="$1" j="$2" h r; for h in "$BASE" "$CAND"; do printf '%s' "$DOC" > "$F"; r=$(printf '%s' "$j" | CLAUDE_PROJECT_DIR="$PROJ" bash cuenta.sh "$h" 2>&1 >/dev/null | tail -1); echo "$id $( [ $h = $CAND ] && echo cand || echo base ): $r"; done; }
doc "$E0" 'Sensible a seguridad: sí' 'QA: aprobado' 'Seguridad: aprobado' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico'
c A1-Edit "$(jedit "$E0" "$EC")"; c A1-Write "$(jwrite "${DOC/"$E0"/"$EC"}")"
L=("$E0" 'Sensible a seguridad: sí' 'QA: aprobado' 'Seguridad: aprobado' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico'); for i in $(seq 200); do L+=("Nota $i: texto"); done; doc "${L[@]}"
c N200-Edit "$(jedit "$E0" "$EC")"
doc "$E0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: aprobado' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico'
c R17-Edit "$(jedit 'Rigor: critico' $'Rigor: critico\nEstado: completado')"
doc "$E0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: aprobado' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico' 'estado: x1' 'estado: x2' 'estado: x3' 'ESTADO: completado' 'estado: x4'
c OTROS5-Edit-otra-linea "$(jedit 'Rigor: critico' 'Rigor: critico ')"
doc "$E0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: aprobado' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico'
c R12-Write "$(jwrite "${DOC/"$E0"/ESTADO: completado}")"
