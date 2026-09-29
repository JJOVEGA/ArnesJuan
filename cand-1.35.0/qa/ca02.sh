. "$(dirname "$0")/qa-lib.sh"
# Para cada campo: cabecera base que CIERRA salvo por ese campo; se compara «declarado en su valor más restrictivo» contra «ausente» (base 713ac68),
# y luego «declarado con una VARIANTE de la clave» en la candidata. Cierre por Write (documento completo).
w() { local h="$1"; shift; doc "$@"; rm -f "$F"; printf '%s' "# REQ-950"$'\nEstado: en-revisión\n\n## Historia\n' > "$F"; juzga "$h" "$(jwrite "$DOC")"; echo "$DEC"; }
EC='Estado: completado'
campo() { local nom="$1" pres="$2" var="$3"; shift 3
  local p a v
  p=$(w "$BASE" "$@" "$pres"); a=$(w "$BASE" "$@"); v=$(w "$CAND" "$@" "$var")
  local clase=no; [ "$p" = deny ] && [ "$a" = allow ] && clase=SI
  echo "$nom | base presente-restrictivo=$p base ausente=$a -> clase=$clase | candidata con variante '$var' = $v"; }
campo 'QA' 'QA: pendiente' 'Qa: pendiente' "$EC" 'Sensible a seguridad: no' 'Rigor: estandar'
campo 'Seguridad' 'Seguridad: pendiente' 'SEGURIDAD: pendiente' "$EC" 'Sensible a seguridad: sí' 'QA: aprobado' 'Rigor: critico'
campo 'Seguridad(estandar)' 'Seguridad: pendiente' 'SEGURIDAD: pendiente' "$EC" 'Sensible a seguridad: no' 'QA: aprobado' 'Rigor: estandar'
campo 'Sensible a seguridad' 'Sensible a seguridad: sí' 'sensible a seguridad: sí' "$EC" 'QA: pendiente' 'Seguridad: pendiente' 'Rigor: ligero'
campo 'Hallazgos abiertos' 'Hallazgos abiertos: SEC-1 (contrato)' 'HALLAZGOS abiertos: SEC-1 (contrato)' "$EC" 'Sensible a seguridad: no' 'QA: aprobado' 'Rigor: estandar'
campo 'Rigor' 'Rigor: critico' 'rigor: critico' "$EC" 'Sensible a seguridad: no' 'QA: aprobado' 'Seguridad: pendiente'
# Estado: presente-terminal frente a ausente, con QA pendiente
campo 'Estado' "$EC" 'estado: completado' 'Sensible a seguridad: no' 'QA: pendiente' 'Rigor: estandar'
