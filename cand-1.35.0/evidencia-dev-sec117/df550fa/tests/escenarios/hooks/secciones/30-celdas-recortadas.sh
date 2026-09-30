# Sección 30 del banco — 30-celdas-recortadas
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=13
PISO_AUTONOMO_SECCION=99  # 9 preámbulo + 12 maquinaria compartida duplicada + 78 bloque indivisible mayor · REQ-014 CA-18

# --- REQ-006: las celdas del bloque derivado, recortadas ------------------------------
  seccion_nueva "Celdas del bloque derivado recortadas (presentacion, no lectura):"

DER="$(mktemp -d)"
mkdir -p "$DER/.arnes" "$DER/requirements" "$DER/docs"
printf '%s\n' "$MANIFIESTO_BASE" > "$DER/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$DER/PENDING_APPROVAL.md"
printf '# ESTADO\n\n## Fase\nlo que escribio una persona\n' > "$DER/docs/ESTADO.md"
LARGO="$(printf 'a%.0s' $(seq 1 1296))"
C40="$(printf 'b%.0s' $(seq 1 40))"
C41="$(printf 'c%.0s' $(seq 1 41))"
printf '# REQ-600\nEstado: en-revisión\nQA: %s\nSeguridad: pendiente\n' "$LARGO" > "$DER/requirements/REQ-600.md"
printf '# REQ-601\nEstado: en-revisión\nQA: aprobado\nSeguridad: con-hallazgos\nHallazgos abiertos: SEC-121 (instrumento)\n' > "$DER/requirements/REQ-601.md"
printf '# REQ-602\nEstado: en-revisión\nQA: %s\nSeguridad: %s\n' "$C40" "$C41" > "$DER/requirements/REQ-602.md"
printf '# REQ-603\nEstado: en-revisión\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: SEC-1|SEC-2 (contrato)\n' > "$DER/requirements/REQ-603.md"
der_corre() {
  local json
  json="$(CLAUDE_PROJECT_DIR="$DER" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')"
  : > "$ERRLOG"
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$DER" "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>"$ERRLOG"
}
der_check() {
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=$2 obtenido=$3"; diag; FAIL=$((FAIL+1)); fi
}
der_corre; DER_RC=$?
DER_FILA="$(grep '^| REQ-600 ' "$DER/docs/ESTADO.md" || true)"
DER_QA="$(printf '%s' "$DER_FILA" | awk -F' \\| ' '{print $3}')"
der_check "CA-01 la celda mide 41 como mucho y termina en elipsis" "41-si" \
  "${#DER_QA}-$(case "$DER_QA" in *…) echo si ;; *) echo no ;; esac)"
der_check "CA-02 el valor completo no entra en el archivo" "no" \
  "$(grep -qF -- "$LARGO" "$DER/docs/ESTADO.md" && echo si || echo no)"
# CA-05: una fila que no cabe deja de renderizarse como fila. La tabla es lo que el
# bloque existe para dar.
der_check "CA-05 toda fila de la tabla tiene 7 separadores" "0" \
  "$(grep '^| REQ-' "$DER/docs/ESTADO.md" | awk -F'|' 'NF!=8 {n++} END {print n+0}')"
# CA-06: una barra en el VALOR abriria una columna nueva. Se neutraliza al componer.
der_check "CA-06 una barra dentro del valor no crea una columna" "1" \
  "$(grep -c '^| REQ-603 .*sec-1¦sec-2' "$DER/docs/ESTADO.md")"
der_check "CA-03 los valores cortos salen intactos y sin elipsis" "1" \
  "$(grep -c '^| REQ-601 | en-revision | aprobado | con-hallazgos | estandar | sec-121(instrumento) |' "$DER/docs/ESTADO.md")"
DER_F602="$(grep '^| REQ-602 ' "$DER/docs/ESTADO.md" || true)"
der_check "CA-04 borde exacto: 40 intacto, 41 recortado" "40-41" \
  "$(printf '%s' "$DER_F602" | awk -F' \\| ' '{print length($3)"-"length($4)}')"
der_check "CA-10 un 'Hallazgos abiertos:' vacio sigue mostrando el guion" "1" \
  "$(grep -c '^| REQ-600 .* — |$' "$DER/docs/ESTADO.md")"
der_check "CA-17 el hook sale 0 (la parada no se bloquea nunca)" "0" "$DER_RC"
# CA-09: idempotencia. Una celda no puede ganar una segunda elipsis en cada parada.
#
# DEV 1.31.0 v5 (QA-119): LA COMPARACION NEUTRALIZA LA MARCA DE TIEMPO; EL BLOQUE LA
# CONSERVA. El bloque derivado se encabeza con la fecha y la hora AL MINUTO, y este caso
# comparaba las dos pasadas byte a byte: si cruzaban un cambio de minuto, fallaba sin que
# nada estuviera roto (medido: 1 de 9 corridas completas). El banco es la puerta requerida
# de `main`, asi que un rojo aleatorio bloquea una fusion legitima y —peor— ensena a
# relanzar el CI hasta que salga verde, que es como se pierde la confianza en una puerta.
#
# Se NEUTRALIZA LA LINEA en la comparacion; no se quita la hora del bloque ni se fija el
# reloj. La hora es para el humano que lee el archivo de continuidad, asi que no se toca.
# Y fijar el reloj obligaria a interponer un `date` falso en el PATH del hook: seria medir
# una plataforma que no es la de produccion y, de paso, taparia cualquier otro uso de la
# fecha que apareciera manana. Tampoco se BORRA la linea: se sustituye su valor por un
# testigo, para que la comparacion siga exigiendo que la cabecera este y en su sitio.
der_marca_fija() { sed 's/^## Estado derivado — .*/## Estado derivado — <marca>/' "$1"; }
# Lo que la comparacion deja de mirar, lo mira un caso propio: neutralizar sin medir la
# marca aparte seria dejar de probarla.
der_check "DEV 1.31.0 v5: QA-119 la cabecera lleva la marca de tiempo, con su formato" "1" \
  "$(grep -cE '^## Estado derivado — [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$' "$DER/docs/ESTADO.md")"
cp "$DER/docs/ESTADO.md" "$DER/antes.md"
der_corre
der_check "CA-09 idempotente: el bloque no cambia ni la celda gana otra elipsis" "iguales" \
  "$(cmp -s <(der_marca_fija "$DER/antes.md") <(der_marca_fija "$DER/docs/ESTADO.md") && echo iguales || echo distintos)"
# DEV 1.31.0 v5 (QA-119): EL CRUCE DE MINUTO, FORZADO. Esperar 60 s a que ocurra de verdad
# seria la prueba mas lenta del banco y SEGUIRIA sin ser determinista. Se falsea la marca de
# la pasada anterior —exactamente lo que ve el caso cuando el reloj avanza— y se exige lo
# mismo de siempre. El segundo miembro es el canario: byte a byte tiene que salir DISTINTOS,
# porque si saliera iguales el cruce no se habria forzado y este caso estaria en verde por
# no medir nada. Si alguien quita la hora del bloque, ese canario lo dira en voz alta.
sed 's/^## Estado derivado — .*/## Estado derivado — 1999-01-01 00:00/' "$DER/antes.md" > "$DER/antes-otro-minuto.md"
der_corre
der_check "DEV 1.31.0 v5: QA-119 cruzar el minuto no rompe la idempotencia (y byte a byte si)" "iguales-distintos" \
  "$(cmp -s <(der_marca_fija "$DER/antes-otro-minuto.md") <(der_marca_fija "$DER/docs/ESTADO.md") && echo iguales || echo distintos)-$(cmp -s "$DER/antes-otro-minuto.md" "$DER/docs/ESTADO.md" && echo iguales || echo distintos)"
# CA-11/CA-12: EL RECORTE ES DE PRESENTACION. La puerta lee el campo ENTERO: si el
# recorte llegara a la lectura, un `Hallazgos abiertos:` largo podria perder su clase
# bloqueante por el camino y cerrar un REQ que no debia cerrarse.
cp "$DER/requirements/REQ-603.md" "$PROJ/requirements/REQ-603.md"
printf '# REQ-604\nEstado: en-revisión\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: SEC-9999999999999999999999999999999999999 (contrato)\n' > "$PROJ/requirements/REQ-604.md"
check "CA-11 hallazgo largo de clase contrato: la puerta lee el campo entero -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-604.md" "" "" 'Estado: completado')"
printf '# REQ-605\nEstado: en-revisión\nQA: aprobado con la condicion de que se repita la ronda cuando el modulo cambie\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-605.md"
check "CA-12 un QA largo que empieza por aprobado se lee como siempre -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-605.md" "" "" 'Estado: completado')"
rm -rf "$DER"
