. "$S/falsa.sh"
r() { printf '  %-58s -> %s\n' "$1" "$(veredicto "$2")"; }

f="$(req A1 no pendiente pendiente estandar)"
r "B  Edit valor pendiente->aprobado (QA pendiente)"        "$(ed "$f" 'Seguridad: pendiente' 'Seguridad: aprobado')"
r "B2 Edit SOLO el valor (old='pendiente')"                 "$(ed "$f" 'pendiente' 'aprobado')"

f="$(req A2 no pendiente aprobado estandar)"
r "A  Edit de prosa del cuerpo que MENCIONA el token"       "$(ed "$f" 'texto' 'nota: Seguridad: aprobado')"
r "A2 Edit de prosa con clave DECORADA en el cuerpo"        "$(ed "$f" 'texto' 'nota: **Seguridad**: aprobado')"
r "C  Edit que cambia SOLO el parentesis de evidencia"      "$(ed "$f" 'Seguridad: aprobado' 'Seguridad: aprobado (R-029)')"
r "F  Write documento entero, cabecera IGUAL, cuerpo otro"  "$(wr "$f" "$(sed 's/^texto$/otro/' "$f")")"
r "G  Write que BORRA la linea Seguridad (disk=aprobado)"   "$(wr "$f" "$(grep -v '^Seguridad:' "$f")")"
r "I  Edit con old_string INEXISTENTE, new trae la firma"   "$(ed "$f" 'ZZZ-no-existe' 'Seguridad: aprobado')"
r "M1 idempotente: misma edicion, 1a"                       "$(ed "$f" 'Seguridad: aprobado' 'Seguridad: aprobado (R-029)')"
r "M2 idempotente: misma edicion, 2a"                       "$(ed "$f" 'Seguridad: aprobado' 'Seguridad: aprobado (R-029)')"

# N: clave decorada en disco, Edit la deja limpia con el MISMO valor
f="$(req A3 no pendiente pendiente estandar)"; sed -i 's/^Seguridad: pendiente/**Seguridad**: pendiente/' "$f"
r "N1 disk decorado; Edit deja clave limpia, valor IGUAL"   "$(ed "$f" '**Seguridad**: pendiente' 'Seguridad: pendiente')"
r "N2 disk decorado; Edit limpia clave Y aprueba"           "$(ed "$f" '**Seguridad**: pendiente' 'Seguridad: aprobado')"

# D/E: REQ NUEVO, sin valor previo en disco
nf="$PROJ/requirements/A9.md"
docn="$(printf '# A9\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: aprobado\nRigor: estandar\n\n## Cuerpo\nx\n')"
r "D  REQ NUEVO por Write: Seg aprobado + QA pendiente"     "$(wr "$nf" "$docn")"
doce="${docn/QA: pendiente/QA: aprobado}"
r "E  REQ NUEVO por Write: Seg aprobado + QA aprobado"      "$(wr "$nf" "$doce")"
docs2="${docn/QA: pendiente/}"
r "D2 REQ NUEVO por Write: Seg aprobado y SIN linea QA"     "$(wr "$nf" "$docs2")"

# H: disco en CRLF
f="$(req A4 no pendiente pendiente estandar)"; sed -i 's/$/\r/' "$f"
r "H  disk CRLF; Edit SOLO valor pendiente->aprobado"       "$(ed "$f" 'pendiente' 'aprobado')"

# J: DOS lineas Seguridad en cabecera (gana la ultima)
f="$PROJ/requirements/A5.md"
printf '# A5\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: aprobado\nSeguridad: pendiente\nRigor: estandar\n\n## Cuerpo\nx\n' > "$f"
r "J1 dos Seguridad (ult=pendiente); Edit cambia la 1a"     "$(ed "$f" 'Seguridad: aprobado' 'Seguridad: pendiente')"
r "J2 dos Seguridad; Edit cambia la ULTIMA a aprobado"      "$(ed "$f" 'Seguridad: pendiente' 'Seguridad: aprobado')"

# K: Seguridad SOLO en el cuerpo del disco
f="$PROJ/requirements/A6.md"
printf '# A6\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nRigor: estandar\n\n## Historia\nSeguridad: pendiente\n' > "$f"
r "K  cabecera SIN Seguridad; Edit aprueba la del CUERPO"   "$(ed "$f" 'Seguridad: pendiente' 'Seguridad: aprobado')"

# L: caracter oculto en la clave QA del disco + firma
f="$(req A7 no pendiente pendiente estandar)"
perl -i -pe 's/^QA: pendiente/\x{feff}QA: pendiente/' "$f" 2>/dev/null || sed -i '1s/^/\xef\xbb\xbf/' "$f"
r "L  QA con BOM en la clave; Edit firma la seguridad"      "$(ed "$f" 'Seguridad: pendiente' 'Seguridad: aprobado')"
printf '     motivo: %s\n' "$(motivo "$(ed "$f" 'Seguridad: pendiente' 'Seguridad: aprobado')")"
