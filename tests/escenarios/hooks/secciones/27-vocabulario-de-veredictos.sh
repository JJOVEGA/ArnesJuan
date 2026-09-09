# Sección 27 del banco — 27-vocabulario-de-veredictos
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=19
PISO_AUTONOMO_SECCION=35  # 9 preámbulo + 4 maquinaria compartida duplicada + 22 bloque indivisible mayor · REQ-014 CA-18

# --- REQ-003: un vocabulario, un lector, y un aviso al escribir ----------------------
  seccion_nueva "Vocabulario de veredictos, aviso y lectura (REQ-003):"

# --- Bloque A: `con-hallazgos` es un valor VALIDO de Seguridad, y no cierra ---
mkreq_r "REQ-200" "no" "aprobado" "con-hallazgos" "critico"
check "CA-02 critico con Seguridad: con-hallazgos -> deny (valido, pero no firma)" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-200.md" "" "" 'Estado: completado')"
check "CA-03 escribir con-hallazgos sin cerrar -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-200.md" "" "" 'Seguridad: con-hallazgos')"
# CA-08: la puerta de ORDEN del ciclo solo se dispara con `aprobado`. `con-hallazgos` no
# es una firma, asi que puede escribirse con QA todavia pendiente.
mkreq_r "REQ-201" "no" "pendiente" "con-hallazgos" "critico"
check "CA-08 con-hallazgos con QA pendiente -> allow (no es una firma)" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-201.md" "" "" 'Seguridad: con-hallazgos')"
# CA-06: no regresion. Ninguno de los otros valores cierra un REQ critico.
for v in vetado preventiva pendiente n/a; do
  mkreq_r "REQ-202" "no" "aprobado" "$v" "critico"
  check "CA-06 critico con Seguridad: $v -> deny (como en 1.30.3)" deny guard-completado.sh \
    "$(emite_edit "$PROJ/requirements/REQ-202.md" "" "" 'Estado: completado')"
done
mkreq_r "REQ-203" "no" "pendiente" "con-hallazgos" "ligero"
check "CA-07 ligero con con-hallazgos -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-203.md" "" "" 'Estado: completado')"

# --- Bloque B: el aviso al ESCRIBIR un valor que la maquina no reconoce ---
# No deniega: es una errata, no un ataque, y la puerta ya la atrapa al cerrar. Denegar
# aqui añadiria friccion constante a algo inocuo, y esa friccion acaba con alguien
# apagando el guard.
mkreq_r "REQ-210" "no" "pendiente" "n/a" "estandar"
check_aviso "CA-09 escribir 'QA: aprobadisimo' -> avisa sin denegar" si 'QA:.*pendiente\|aprobado\|con-hallazgos' \
  guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-210.md" "" "" 'QA: aprobadísimo')"
check_aviso "CA-10 escribir un valor del vocabulario -> sin aviso" no "" \
  guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-210.md" "" "" 'QA: aprobado')"
# CA-11: el aviso es por la ESCRITURA del campo, no por el estado del archivo. Si no,
# cada edicion del REQ repetiria el mismo aviso hasta que alguien lo silencie.
printf '# REQ-211\nEstado: en-revisión\nQA: aprobadísimo\nSeguridad: n/a\n\n## Historial de cambios\n| f | a | c |\n' > "$PROJ/requirements/REQ-211.md"
check_aviso "CA-11 el REQ ya lo tenia en disco y la edicion no lo toca -> sin aviso" no "" \
  guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-211.md" "" "" '| 2026-09-05 | otra fila | causa |')"
check_aviso "CA-12 'Seguridad: aprobado' dentro del historial -> sin aviso" no "" \
  guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-211.md" "" "" '| 2026-09-05 | Seguridad: aprobado | causa |')"
check_aviso "CA-15 el mismo texto FUERA de requirements/ -> sin aviso" no "" \
  guard-completado.sh "$(emite_edit "$PROJ/docs/notas.md" "" "" 'QA: loquesea')"
# CA-13: el aviso no compite con la denegacion ni la sustituye.
mkreq_r "REQ-212" "no" "aprobadísimo" "n/a" "estandar"
check "CA-13 valor fuera del vocabulario Y cierre -> deny (manda la puerta)" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-212.md" "" "" 'Estado: completado')"

# --- Bloque C: el informe lee EXACTAMENTE lo que lee la puerta ---
lec_proj() {
  LP="$(mktemp -d)"; mkdir -p "$LP/.arnes" "$LP/requirements"
  printf '%s\n' "$MANIFIESTO_BASE" > "$LP/.arnes/config.json"
}
lec_proj
printf '# REQ-300\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: con-hallazgos\nRigor: critico\n' > "$LP/requirements/REQ-300.md"
lec_check "CA-01 'Seguridad: con-hallazgos' no es una anomalia (sale 0)" 0 'REQ-300' no
# CA-16/CA-17: la regla del parentesis se aplica a `Estado:` igual que en la puerta.
printf '# REQ-301\nEstado: en-revisión (2026-08-25, tras la ronda 3)\nQA: aprobado\nSeguridad: n/a\n' > "$LP/requirements/REQ-301.md"
printf '# REQ-302\nEstado: **completado** (revertido en la ronda 2)\nQA: aprobado\nSeguridad: n/a\n' > "$LP/requirements/REQ-302.md"
lec_check "CA-16/CA-17 Estado con parentesis o enfasis no es anomalia (sale 0)" 0 'REQ-30[12]' no
# CA-18: la comparacion es EXACTA contra el vocabulario delimitado, no por prefijo.
printf '# REQ-303\nEstado: en-revisión-parcial\nQA: aprobado\nSeguridad: n/a\n' > "$LP/requirements/REQ-303.md"
lec_check "CA-18/CA-20 un estado que NO existe sigue siendo anomalia (sale 1)" 1 'REQ-303' si
lec_check "CA-20 ...y se imprime el bloque que lo explica" 1 'NO LEE COMO EST' si
rm -rf "$LP"
# CA-04: el informe no puede tener su propia copia del vocabulario.
if grep -Eq "^(QA_OK|SEG_OK|RIG_OK)='\\|" "$LEC"; then
  echo "  FAIL  CA-04 tools/arnes-lectura.sh conserva su propia lista de valores"; FAIL=$((FAIL+1))
else
  echo "  PASS  CA-04 el vocabulario viene de lib.sh, no de una copia en el informe"; PASS=$((PASS+1))
fi
