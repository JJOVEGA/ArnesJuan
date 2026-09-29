. "$(dirname "$0")/qa-lib.sh"
V134=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/qa/v134/hooks
R0='Rigor: critico'; T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'
e() { local id="$1"; printf '%s' "$DOC" > "$F"; juzga "$CAND" "$(jedit "$R0" "Rigor: critico ")"; c=$DEC; m=${MOT:0:150}; printf '%s' "$DOC" > "$F"; juzga "$BASE" "$(jedit "$R0" "Rigor: critico ")"; echo "$id | editar otra linea (Rigor): cand=$c base=$DEC | $m"; }
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'ESTADO: completado';  e 'X0 (el caso que el texto nombra: variante terminal + exacto no terminal)'
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'Estado: completado';  e 'X1 (repeticion EXACTA: la segunda Estado: completado, sin variante)'
doc 'ESTADO: completado' "$T" "$Q" "$G" "$H" "$R0";                        e 'X2 (sólo una variante terminal, SIN Estado exacto)'
doc 'Estado:' "$T" "$Q" "$G" "$H" "$R0" 'ESTADO: completado';              e 'X3 (Estado exacto vacío + variante terminal)'
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'Estado: en-revisión' 'estado: completado'; e 'X4 (exacto x2 no terminal + variante terminal)'
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'QA: aprobado';        e 'C0 control: repeticion de otra clave, sin terminal (debe permitir)'
