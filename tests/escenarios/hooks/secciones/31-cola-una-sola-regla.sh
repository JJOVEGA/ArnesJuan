# Sección 31 del banco — 31-cola-una-sola-regla
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=25
PISO_AUTONOMO_SECCION=49  # 9 preámbulo + 24 maquinaria compartida duplicada + 16 bloque indivisible mayor · REQ-014 CA-18

# --- REQ-009: la cola de aprobaciones se cuenta UNA vez, con la regla de la puerta ----
  seccion_nueva "Cola de aprobaciones: una sola regla, la de la puerta (REQ-009):"

# Un REQ listo para cerrar: lo unico que puede bloquearlo es la cola.
printf '# REQ-900\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-900.md"
CIERRE="$(emite_edit_real "$PROJ/requirements/REQ-900.md" 'en-revisión' 'completado')"

# La ENTRADA REAL del formato que documenta el propio PENDING_APPROVAL.md: un `###` y sus
# cuatro vinetas. Contra v1.30.3 la puerta decia 1 y el bloque derivado decia 4.
ENTRADA='## Pendientes

### [2026-09-05] (desarrollador) — Una decision que espera
- **Contexto** por que se detuvo aqui
- **Opciones** A / B
- **Recomendación del agente** A
- **Espera** aprobación del humano

## Resueltas
'
printf '%s' "$ENTRADA" > "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-01 la puerta cuenta 1 sobre la entrada del formato documentado" \
  'hay 1 aprobación' guard-completado.sh "$CIERRE"

# El MISMO archivo, leido por el bloque derivado: tiene que decir 1, no 4.
DER9="$(mktemp -d)"
mkdir -p "$DER9/.arnes" "$DER9/requirements" "$DER9/docs"
printf '%s\n' "$MANIFIESTO_BASE" > "$DER9/.arnes/config.json"
printf '# ESTADO\n' > "$DER9/docs/ESTADO.md"
der9_cola() {   # -> imprime lo que el bloque derivado escribe como cola
  local json
  json="$(CLAUDE_PROJECT_DIR="$DER9" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')"
  : > "$ERRLOG"
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$DER9" "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>"$ERRLOG"
  sed -n 's/^\*\*Aprobaciones pendientes:\*\* //p' "$DER9/docs/ESTADO.md" | tail -1
}
der9_check() {
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=<$2> obtenido=<$3>"; diag; FAIL=$((FAIL+1)); fi
}
printf '%s' "$ENTRADA" > "$DER9/PENDING_APPROVAL.md"
der9_check "REQ-009 CA-01 el bloque derivado dice 1 sobre la misma entrada (decia 4)" "1" "$(der9_cola)"

# CA-12: CRLF. El retorno de carro no puede cambiar la cuenta en ninguno de los dos.
printf '%s' "$ENTRADA" | sed 's/$/\r/' > "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-12 CRLF: la puerta sigue contando 1" 'hay 1 aprobación' guard-completado.sh "$CIERRE"
printf '%s' "$ENTRADA" | sed 's/$/\r/' > "$DER9/PENDING_APPROVAL.md"
der9_check "REQ-009 CA-12 CRLF: el bloque derivado tambien dice 1" "1" "$(der9_cola)"

# CA-07: un ejemplo COMENTADO dentro de la seccion no es una entrada.
COMENTADO='## Pendientes

<!--
### [AAAA-MM-DD] (agente) — Título de la decisión
- **Contexto** …
-->

## Resueltas
'
printf '%s' "$COMENTADO" > "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-07 un ejemplo comentado bajo Pendientes no bloquea el cierre" allow guard-completado.sh "$CIERRE"
printf '%s' "$COMENTADO" > "$DER9/PENDING_APPROVAL.md"
der9_check "REQ-009 CA-07 el bloque derivado tambien dice 0 con el ejemplo comentado" "0" "$(der9_cola)"

# CA-06: el archivo de arranque del arnes, con el ejemplo FUERA de la cola.
cp "$TPL_DIR/PENDING_APPROVAL.md.tpl" "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-06 la plantilla de PENDING no bloquea (ejemplo fuera de la cola)" allow guard-completado.sh "$CIERRE"

# CA-09 / CA-10: lo resuelto no bloquea, y CUALQUIER seccion cierra la cola.
printf '## Pendientes\n\n## Resueltas\n### a\n### b\n### c\n### d\n### e\n' > "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-09 cinco entradas bajo Resueltas no bloquean" allow guard-completado.sh "$CIERRE"
printf '## Pendientes\n\n## Notas\n### a\n### b\n' > "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-10 cualquier seccion cierra la cola, no solo Resueltas" allow guard-completado.sh "$CIERRE"

# CA-11: solo el nivel `###` es una entrada.
printf '## Pendientes\n### [2026-09-05] (dev) — una\n#### un subapartado suyo\n' > "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-11 un '####' no es una entrada: sigue siendo 1" 'hay 1 aprobación' guard-completado.sh "$CIERRE"

# CA-13: la forma del encabezado. Abre por prefijo; sin espacio no abre nada.
printf '## Pendientes (2 abiertas)\n### [2026-09-05] (dev) — una\n' > "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-13 '## Pendientes (2 abiertas)' abre la seccion por prefijo" 'hay 1 aprobación' guard-completado.sh "$CIERRE"
printf '##Pendientes\n### [2026-09-05] (dev) — una\n' > "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-13 '##Pendientes' sin espacio no abre la seccion (como en v1.30.3)" allow guard-completado.sh "$CIERRE"

# CA-05: control de no regresion, 0 / 1 / 3 entradas.
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-05 con 0 entradas el cierre pasa" allow guard-completado.sh "$CIERRE"
printf '## Pendientes\n### a\n### b\n### c\n' > "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-05 con 3 entradas deniega y dice cuantas" 'hay 3 aprobación' guard-completado.sh "$CIERRE"

# CA-14: sin archivo de cola, no hay cola. Ni error ni bloqueo.
rm -f "$PROJ/PENDING_APPROVAL.md"
check "REQ-009 CA-14 sin PENDING_APPROVAL.md el cierre no se bloquea" allow guard-completado.sh "$CIERRE"
rm -f "$DER9/PENDING_APPROVAL.md"
der9_check "REQ-009 CA-14 sin archivo el bloque derivado dice 0, no error" "0" "$(der9_cola)"

# --- Bloque C: la cola es una puerta. Si no se puede contar, no deja pasar ---
# CA-15: un NUL antes de la seccion truncaria la lectura y la cuenta saldria 0 sobre un
# archivo que nadie leyo entero. Eso ABRE el cierre de cualquier REQ con aprobaciones
# humanas abiertas: es exactamente lo que no puede pasar.
printf 'basura' > "$PROJ/PENDING_APPROVAL.md"
printf '\000' >> "$PROJ/PENDING_APPROVAL.md"
printf '\n## Pendientes\n### [2026-09-05] (dev) — una decision de verdad\n' >> "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-009 CA-15 un NUL en la cola: DENY con motivo propio, nunca allow por 0" \
  'no se pudo leer entera' guard-completado.sh "$CIERRE"
# CA-16: el bloque derivado informa, no decide: no bloquea la parada, pero tampoco puede
# afirmar un numero que no midio.
cp "$PROJ/PENDING_APPROVAL.md" "$DER9/PENDING_APPROVAL.md"
DER9_COLA="$(der9_cola)"; DER9_RC=$?
der9_check "REQ-009 CA-16 con NUL el bloque dice 'sin datos', no 0" "sin datos" "$DER9_COLA"
der9_check "REQ-009 CA-16 con NUL la parada NO se bloquea (rc 0)" "0" "$DER9_RC"

# CA-17: archivo ilegible. Con root todo es legible y el caso no mide nada: se salta
# diciendolo, que es distinto de pasar.
printf '## Pendientes\n### [2026-09-05] (dev) — una\n' > "$PROJ/PENDING_APPROVAL.md"
chmod 000 "$PROJ/PENDING_APPROVAL.md" 2>/dev/null
if [ -r "$PROJ/PENDING_APPROVAL.md" ]; then
  echo "  SKIP  REQ-009 CA-17 cola ilegible (condicion: corriendo como root, chmod 000 sigue siendo legible)"
else
  check_motivo "REQ-009 CA-17 una cola ilegible deniega el cierre con el mismo motivo" \
    'no se pudo leer entera' guard-completado.sh "$CIERRE"
fi
chmod 644 "$PROJ/PENDING_APPROVAL.md" 2>/dev/null

# --- Bloque A: la regla es UNA. Se prueba por mutacion, no por lectura ---
# CA-02: ningun consumidor conserva transcripcion propia de la regla.
PROPIOS=$(grep -c -e '\^###' -e "'- '\*|'\* '\*|'1\. '\*" \
  "$HOOKS_DIR/guard-completado.sh" "$HOOKS_DIR/estado-derivado.sh" 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')
der9_check "REQ-009 CA-02 ningun consumidor conserva su propio patron de conteo" "0" "$PROPIOS"

# CA-03: se muta SOLO la funcion de lib.sh —que `###` case tambien con `####`— y se mira
# si los TRES lectores cambian. No mide que la regla sea correcta: mide que sea UNA.
MUT="$(mktemp -d)"
cp -r "$HOOKS_DIR" "$MUT/hooks"
cp -r "$HOOKS_DIR/../tools" "$MUT/tools" 2>/dev/null || true
cp -r "$HOOKS_DIR/../.claude-plugin" "$MUT/.claude-plugin" 2>/dev/null || true
mkdir -p "$MUT/proy/.arnes" "$MUT/proy/requirements" "$MUT/proy/docs"
printf '%s\n' "$MANIFIESTO_BASE" > "$MUT/proy/.arnes/config.json"
printf '# ESTADO\n' > "$MUT/proy/docs/ESTADO.md"
printf '# REQ-901\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n' > "$MUT/proy/requirements/REQ-901.md"
printf '## Pendientes\n### [2026-09-05] (dev) — una\n#### y un subapartado\n' > "$MUT/proy/PENDING_APPROVAL.md"
tres_cuentas() {   # -> "puerta|bloque|informe"
  local j p b i
  j="$(CLAUDE_PROJECT_DIR="$MUT/proy" jq -n '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
        tool_input:{file_path:(env.CLAUDE_PROJECT_DIR+"/requirements/REQ-901.md"),old_string:"en-revisión",new_string:"completado"}}')"
  p="$(printf '%s' "$j" | CLAUDE_PROJECT_DIR="$MUT/proy" "$MUT/hooks/guard-completado.sh" 2>/dev/null \
       | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' | sed -n 's/.*hay \([0-9]*\) aprobación.*/\1/p')"
  printf '%s' "$(CLAUDE_PROJECT_DIR="$MUT/proy" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')" \
    | CLAUDE_PROJECT_DIR="$MUT/proy" "$MUT/hooks/estado-derivado.sh" >/dev/null 2>&1
  b="$(sed -n 's/^\*\*Aprobaciones pendientes:\*\* //p' "$MUT/proy/docs/ESTADO.md" | tail -1)"
  i="$("$MUT/tools/arnes-lectura.sh" "$MUT/proy" 2>/dev/null | sed -n 's/.*cola de aprobaciones ([^)]*): \([0-9]*\) pendiente.*/\1/p')"
  printf '%s|%s|%s' "$p" "$b" "$i"
}
der9_check "REQ-009 CA-03 sin mutar, los tres lectores dicen 1" "1|1|1" "$(tres_cuentas)"
sed -i "s/'###'\[\[:space:\]\]\*)/'###'*)/" "$MUT/hooks/lib.sh"
der9_check "REQ-009 CA-03 mutada SOLO lib.sh, los tres cambian a 2 (la regla es una)" "2|2|2" "$(tres_cuentas)"
sed -i "s/'###'\*)/'###'[[:space:]]*)/" "$MUT/hooks/lib.sh"
der9_check "REQ-009 CA-03 retirada la mutacion, los tres vuelven a 1" "1|1|1" "$(tres_cuentas)"

# CA-20: la unificacion se paga en NEGATIVO. La puerta pagaba un `awk` por cierre y ahora
# no arranca ninguno; la parada no gana ninguno. Se mide con un awk instrumentado en PATH.
BIN9="$(mktemp -d)"
printf '#!/bin/sh\necho awk >> "%s/awk.log"\nexec /usr/bin/awk "$@"\n' "$BIN9" > "$BIN9/awk"
chmod +x "$BIN9/awk"
printf '## Pendientes\n### [2026-09-05] (dev) — una\n' > "$PROJ/PENDING_APPROVAL.md"
: > "$BIN9/awk.log"
printf '%s' "$CIERRE" | PATH="$BIN9:$PATH" "$HOOKS_DIR/guard-completado.sh" >/dev/null 2>&1
der9_check "REQ-009 CA-20 el cierre no arranca ningun awk para contar la cola" "0" "$(wc -l < "$BIN9/awk.log" | tr -d ' ')"
rm -rf "$MUT" "$DER9" "$BIN9"
