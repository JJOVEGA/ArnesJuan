. "$(dirname "$0")/qa-lib.sh"
doc 'Estado: en-revisión' 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: SEC-1 (contrato)' 'Rigor: critico'
D0="$DOC"
uno() { local id="$1" j="$2"; printf '%s' "$D0" > "$F"; juzga "$CAND" "$j"; c="$DEC"; printf '%s' "$D0" > "$F"; juzga "$BASE" "$j"; b="$DEC"; printf '%s' "$D0" > "$F"; juzga "$NHK" "$j"; echo "$id cand=$c base=$b N=$DEC | ${MOT:0:100}"; }
# control: el mismo cierre con old_string literal -> deny (QA pendiente)
uno G0-control-literal "$(jedit 'en-revisión' 'completado')"
# (1) escape ó literal en old_string: el hook no lo encuentra; el Edit de CC 2.1.284 lo convierte (_()) y lo encuentra
BS=$(printf '\\'); ESC="en-revisi${BS}u00f3n"; echo "old_string usado: $ESC (bytes: ${#ESC})"
uno G1-escape-u00f3 "$(jedit "$ESC" 'completado')"
uno G1m-multiedit-escape "$(jmulti "$ESC" 'completado')"
# (2) comillas: cabecera con comillas tipograficas junto al Estado
doc 'Estado: en-revisión' 'Nota: “ver R-1”' 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: SEC-1 (contrato)' 'Rigor: critico'; D0="$DOC"
uno G2-comillas-rectas "$(jedit $'en-revisión\nNota: "ver R-1"' $'completado\nNota: "ver R-1"')"
# (3) con la palabra Estado en el fragmento: la via de fragmentos juzga veredictos
uno G3-escape-con-Estado "$(jedit "Estado: $ESC" 'Estado: completado')"
