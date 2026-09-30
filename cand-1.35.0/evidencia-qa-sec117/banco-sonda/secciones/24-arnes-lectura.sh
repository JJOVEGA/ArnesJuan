# Sección 24 del banco — 24-arnes-lectura
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=3
PISO_AUTONOMO_SECCION=36  # 8 preámbulo + 0 maquinaria compartida duplicada + 28 bloque indivisible mayor · REQ-014 CA-18

seccion_nueva "tools/arnes-lectura.sh (el informe tiene que poder decir que algo esta mal):"
# FALLO EN ABIERTO medido (1.30.1): el contador de anomalias se incrementaba dentro de un
# subshell y el informe decia «Ningún valor anómalo» y salia 0 con cuatro REQ fuera del
# vocabulario en un proyecto real. Un informe que siempre dice que todo esta bien es peor
# que no tenerlo: estos casos exigen que sepa decir que NO.
if [ -z "$FILTRO" ] || printf '%s' "arnes-lectura" | grep -qi -- "$FILTRO"; then
LECTURA="$HOOKS_DIR/../tools/arnes-lectura.sh"
mkreq "$PROJ/requirements/REQ-240.md" "no" "aprobado con residual declarado" "n/a"
mkreq "$PROJ/requirements/REQ-241.md" "no" "aprobado" "n/a"
salida="$(bash "$LECTURA" "$PROJ" 2>"$ERRLOG")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$salida" | grep -q 'aprobadoconresidualdeclarado'; then
  echo "  PASS  arnes-lectura: un veredicto fuera del vocabulario sale 1 y lo nombra"; PASS=$((PASS+1))
else
  echo "  FAIL  arnes-lectura: un veredicto fuera del vocabulario: rc=$rc (esperado 1)"; diag
  printf '%s\n' "$salida" | head -12 | sed 's/^/          salida| /'; FAIL=$((FAIL+1))
fi
if printf '%s' "$salida" | grep -q 'NO LEE COMO ESTÁN ESCRITOS (1)'; then
  echo "  PASS  arnes-lectura: ...y cuenta 1 anomalia, no 0"; PASS=$((PASS+1))
else
  echo "  FAIL  arnes-lectura: ...el contador no dice 1"; FAIL=$((FAIL+1))
fi
mkreq "$PROJ/requirements/REQ-240.md" "no" "aprobado" "n/a"
salida="$(bash "$LECTURA" "$PROJ" 2>"$ERRLOG")"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$salida" | grep -q 'Ningún valor anómalo'; then
  echo "  PASS  arnes-lectura: control, con todo en vocabulario sale 0 y lo dice"; PASS=$((PASS+1))
else
  echo "  FAIL  arnes-lectura: control: rc=$rc (esperado 0)"; diag; FAIL=$((FAIL+1))
fi
fi

