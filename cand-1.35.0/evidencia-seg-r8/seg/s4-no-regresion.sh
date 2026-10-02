#!/usr/bin/env bash
# s4 — no-regresión por muestreo frente a R-045 / R-045-A (SEC-047 mitad 1 / REQ-023, REQ-031, REQ-001) y SEC-118/SEC-120.
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/seg/lib-sonda.sh
ARBOLES="cand 3bc7d3c 9596e39 v1.33.2"
proyecto_nuevo "$S/p4"
mkreq() {  # <archivo> <cabecera extra o sustituciones vía printf>
  printf '%s' "$2" > "$P/requirements/$1"
}
cierra() { # <nombre> <archivo> : Edit literal Estado: en-revisión -> completado
  j_edit "$P/requirements/$2" "Estado: en-revisión" "Estado: completado"; fila "$1" "$J"
}
V='Estado: en-revisión
Rigor: critico
QA: aprobado
Seguridad: aprobado
'
echo "== REQ-023 / SEC-047 mitad 1: claves de control ambiguas (verde por lo demás) =="
mkreq R1.md "# R1
${V}Sensible a seguridad: sí
Hallazgos abiertos: ninguno
"; cierra "N0 control verde, cierra" R1.md
mkreq R2.md "# R2
Estado: en-revisión
Rigor: ligero
QA: aprobado
Seguridad: pendiente
Sensible${NBSP:=$'\xc2\xa0'}a seguridad: sí
Hallazgos abiertos: ninguno
"; cierra "N1 NBSP en 'Sensible a seguridad' + Rigor ligero" R2.md
mkreq R3.md "# R3
${V}Sensible a seguridad: sí
"$'\xef\xbb\xbf'"Hallazgos abiertos: SEC-1 (contrato)
Hallazgos abiertos: ninguno
"; cierra "N2 BOM delante de 'Hallazgos abiertos:' contrato" R3.md
mkreq R4.md "# R4
${V}Sensible a seguridad: sí
Hallazgos abiertos: ninguno
- Estado: completado
"; j_edit "$P/requirements/R4.md" "Estado: en-revisión" "Estado: en-revisión"; fila "N3 variante '- Estado: completado' añadida (sin cambiar gobernante)" "$J"
mkreq R5.md "# R5
${V}Sensible a seguridad: sí
Hallazgos abiertos: ninguno
QA: aprobado
"; cierra "N4 QA repetida igual (ambigua)" R5.md
echo "== REQ-031: gramática y techo de 'Hallazgos abiertos:' =="
mkreq H1.md "# H1
${V}Sensible a seguridad: sí
Hallazgos abiertos: SEC-1 (contrato)
"; cierra "H1 un contrato abierto" H1.md
mkreq H2.md "# H2
${V}Sensible a seguridad: sí
Hallazgos abiertos: SEC-1 (instrumento), SEC-2 (contrato)
"; cierra "H2 instrumento; contrato" H2.md
mkreq H3.md "# H3
${V}Sensible a seguridad: sí
Hallazgos abiertos: SEC-1 (instrumento) texto suelto
"; cierra "H3 texto tras el paréntesis (P-1 opción B)" H3.md
mkreq H4.md "# H4
${V}Sensible a seguridad: sí
Hallazgos abiertos: SEC-1
"; cierra "H4 hallazgo sin clase" H4.md
mkreq H5.md "# H5
${V}Sensible a seguridad: sí
Hallazgos abiertos: SEC-1 (instrumento)
Hallazgos abiertos: SEC-2 (contrato)
"; cierra "H5 campo repetido" H5.md
big="$(head -c 20000 /dev/zero | tr '\0' 'a')"
mkreq H6.md "# H6
${V}Sensible a seguridad: sí
Hallazgos abiertos: SEC-1 (instrumento) $big
"; cierra "H6 campo > techo de 16 384 bytes" H6.md
mkreq H7.md "# H7
${V}Sensible a seguridad: sí
Hallazgos abiertos: SEC-1 (instrumento), SEC-2 (instrumento)
"; cierra "H7 sólo instrumento (control: cierra)" H7.md
echo "== REQ-001 (CA-10/11/12 versionados) y cola =="
j_edit "$P/requirements/H7.md" "no-esta" "Estado: completado"; fila "U1 old_string inexistente en REQ verde (CA-11 v.)" "$J"
j_edit "$P/requirements/NOEXISTE.md" "x" "Estado: completado"; fila "U2 Edit sobre REQ inexistente, old no vacío (CA-12 v.)" "$J"
j_edit "$P/requirements/NUEVO.md" "" "# N
Estado: completado
Rigor: critico
QA: pendiente
Seguridad: pendiente
Sensible a seguridad: sí
"; fila "U3 creación por Edit con old vacío, completado en rojo" "$J"
printf '## Pendientes\n\n### algo pendiente\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
cierra "U4 cola ocupada, REQ verde" H7.md
j_edit "$P/requirements/H7.md" "Estado: en-revisión" "Estado: en-progreso"; fila "U5 reabrir con cola ocupada (permitido)" "$J"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
echo "== SEC-118 (sin cambio esperado): QA de 140 KB sin paréntesis final =="
q="$(head -c 140000 /dev/zero | tr '\0' 'q')"
mkreq Q1.md "# Q1
Estado: en-revisión
Rigor: critico
QA: pendiente $q
Seguridad: aprobado
Sensible a seguridad: sí
Hallazgos abiertos: ninguno
"; cierra "Q1 QA pendiente de 140 KB (SEC-118)" Q1.md
echo "== SEC-120 (sin cambio esperado) =="
jq -n --arg c "$P" --arg fp "$P/requirements/REQ-900.md" '{tool_name:"MultiEdit",cwd:$c,tool_input:{file_path:$fp,edits:"x"}}' > "$J"; fila "X1 MultiEdit con edits cadena" "$J"
{ printf '{"tool_name":"Edit","cwd":"%s","tool_input":{"file_path":"%s/requirements/REQ-900.md","old_string":"Estado: en-revisión","new_string":"Estado: completado"},"z":' "$P" "$P"; head -c 10001 /dev/zero | tr '\0' '['; head -c 10001 /dev/zero | tr '\0' ']'; printf '}'; } > "$J"; fila "X2 Edit de cierre + 10 001 niveles de anidamiento" "$J"
