. "$(dirname "$0")/qa-lib.sh"
R0='Rigor: critico'; T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'
x() { local id="$1" o="$2" n="$3"; printf '%s' "$DOC" > "$F"; juzga "$CAND" "$(jedit "$o" "$n")"; echo "$id cand=$DEC | ${MOT:0:120}"; }
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'Estado: completado'; x 'X1 retirar la 2a linea' $'\nEstado: completado' ''
doc 'ESTADO: completado' "$T" 'QA: pendiente' "$G" "$H" "$R0"; x 'X2 corregir a Estado: completado (es un cierre real; QA pendiente)' 'ESTADO: completado' 'Estado: completado'
doc 'ESTADO: completado' "$T" 'QA: pendiente' "$G" "$H" "$R0"; x 'X2 corregir a Estado: en-revisión' 'ESTADO: completado' 'Estado: en-revisión'
