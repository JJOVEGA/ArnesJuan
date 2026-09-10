# Sección 31 del banco — 31-cola-una-sola-regla
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=39
PISO_AUTONOMO_SECCION=76  # 9 preámbulo + 24 maquinaria compartida duplicada + 43 bloque indivisible mayor (el proyecto D24, los tres canales `tres24` y el comparador `chk24`, líneas 184-226: ningún caso de REQ-024 puede prescindir de ellos) · REQ-014 CA-18

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

# --- REQ-024 · bloque B: la cola que contaba cero sobre lo que no pudo medir (SEC-051) ---
# Las tres partes de `SEC-051` se enrutan distinto a proposito y aqui se mide la conducta de
# ESTA version. La mitad heredada de cada control discriminante —el `0` con `rc=0` y el
# ALLOW de v1.33.0, sin el cual estos casos no acreditan nada— vive en
# `40-ausencia-que-abre-2-migracion-y-punteros.sh`, que es donde esta el materializador de
# la linea base; las dos mitades corren en la MISMA vuelta del banco.
D24="$(mktemp -d)"
mkdir -p "$D24/.arnes" "$D24/requirements" "$D24/docs"
printf '%s\n' "$MANIFIESTO_BASE" > "$D24/.arnes/config.json"
printf '# ESTADO\n' > "$D24/docs/ESTADO.md"
# Un REQ listo para cerrar: lo unico que puede bloquearlo es la cola.
printf '# REQ-902\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n' > "$D24/requirements/REQ-902.md"
CIERRE24="$(CLAUDE_PROJECT_DIR="$D24" jq -n --arg fp "$D24/requirements/REQ-902.md" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"completado"}}')"
# LOS TRES CANALES DE OBSERVABILIDAD, en una sola funcion: son los tres que `SEC-051` midio
# coincidiendo en el numero equivocado, y la propiedad de UNA sola regla de REQ-009 es lo que
# propago el error a los tres. Consistencia no es correccion.
tres24() {   # -> "puerta|bloque|informe", cada uno con lo que publica (numero o `sin datos`)
  local o p b i d
  o="$(printf '%s' "$CIERRE24" | CLAUDE_PROJECT_DIR="$D24" "$HOOKS_DIR/guard-completado.sh" 2>/dev/null)"
  d="$(printf '%s' "$o" | jq -r '.hookSpecificOutput.permissionDecision // "allow"' 2>/dev/null)"
  p="$(printf '%s' "$o" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null)"
  # UN DENY POR OTRO MOTIVO NO SE MAQUILLA COMO UN 0. Si la puerta denegara por una quality
  # gate o por un veredicto, mapearlo a «0 pendientes» daria verde a un caso que no midio la
  # cola: se publica como lo que es y el caso falla ensenandolo.
  if [ "$d" != "deny" ]; then p='0'
  else
    case "$p" in
      *'no se pudo leer entera'*|*'ABRE un rango de comentario'*) p='sin datos' ;;
      *'aprobación(es) pendiente(s)'*) p="$(printf '%s' "$p" | sed -n 's/.*hay \([0-9]*\) aprobación.*/\1/p')" ;;
      *) p='deny-por-otro-motivo' ;;
    esac
  fi
  printf '%s' "$(CLAUDE_PROJECT_DIR="$D24" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')" \
    | CLAUDE_PROJECT_DIR="$D24" "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>&1
  b="$(sed -n 's/^\*\*Aprobaciones pendientes:\*\* //p' "$D24/docs/ESTADO.md" | tail -1)"
  # DOS expresiones y no una: `\([^ ]*\)` recortaba `sin datos` a `sin`, y un caso que compara
  # contra una cadena truncada pasa por el motivo equivocado.
  i="$(bash "$HOOKS_DIR/../tools/arnes-lectura.sh" "$D24" 2>/dev/null \
       | sed -n -e 's/.*cola de aprobaciones ([^)]*): \([0-9]*\) pendiente.*/\1/p' \
                -e 's/.*cola de aprobaciones ([^)]*): sin datos.*/sin datos/p')"
  printf '%s|%s|%s' "$p" "$b" "$i"
}
chk24() {   # <nombre> <esperado> <obtenido>
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=<$2> obtenido=<$3>"; diag; FAIL=$((FAIL+1)); fi
}

# CA-08 — un rango que ABRE y no cierra: `arnes_cola_pendientes` devuelve «no lo se», nunca
# `0` con `rc=0`. El fixture lleva DOS entradas reales detras del rango abierto (fila 5 de la
# tabla de SEC-051): denominador publicado, 2 entradas visibles y 0 contadas en la heredada.
COLA24_ABIERTA='## Pendientes
<!-- una nota que nadie cerro
### [2026-09-05] (dev) — una decision de verdad
### [2026-09-06] (dev) — y otra
'
printf '%s' "$COLA24_ABIERTA" > "$D24/PENDING_APPROVAL.md"
cp "$D24/PENDING_APPROVAL.md" "$PROJ/PENDING_APPROVAL.md"
# (i) La puerta DENIEGA citando el rango abierto Y LA LINEA DONDE ABRE. Un `rc!=0` a secas lo
# pasaria tambien una comprobacion que falla siempre: se exige que el motivo cite las dos.
check_motivo "REQ-024 CA-08 (i) la puerta DENIEGA citando el rango abierto y la linea donde abre" \
  "ABRE un rango de comentario '<!--' en la linea 2" guard-completado.sh "$CIERRE"
chk24 "REQ-024 CA-08 los tres canales dicen 'sin datos', no 0 (SEC-051 los tres decian 0)" \
  "sin datos|sin datos|sin datos" "$(tres24)"
# (ii) La parada NO se bloquea: el bloque derivado informa y no decide.
printf '%s' "$(CLAUDE_PROJECT_DIR="$D24" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')" \
  | CLAUDE_PROJECT_DIR="$D24" "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>&1
chk24 "REQ-024 CA-08 (ii) con el rango abierto la parada NO se bloquea (rc 0)" "0" "$?"
# (iii) El informe sale != 0, dice `sin datos`, NOMBRA la consecuencia y NO afirma que todo
# esta bien. Las dos mitades son el criterio: hasta 1.33.0 decia `sin datos` en el RESUMEN y
# ademas «Ningún valor anómalo» tres bloques mas arriba, y salia 0.
LEC24="$(bash "$HOOKS_DIR/../tools/arnes-lectura.sh" "$D24" 2>/dev/null)"; RC24=$?
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-08 (iii) el informe" | grep -qi -- "$FILTRO"; then
  if [ "$RC24" -ne 0 ] && printf '%s' "$LEC24" | grep -q 'sin datos' \
     && printf '%s' "$LEC24" | grep -q 'la puerta de cierre DENIEGA'; then
    echo "  PASS  REQ-024 CA-08 (iii) el informe sale $RC24 (!=0), dice 'sin datos' y nombra la consecuencia"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-08 (iii) el informe: rc=$RC24 (esperado !=0) o no dice 'sin datos'/la consecuencia"; FAIL=$((FAIL+1))
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-08 (iii) y NO afirma" | grep -qi -- "$FILTRO"; then
  # LA AFIRMACION es la linea que EMPIEZA por esa frase. El texto del bloque nuevo la
  # menciona para NEGARLA («este informe NO puede afirmar …»), asi que buscarla en
  # cualquier posicion hacia fallar el caso por el propio arreglo: el ancla es el criterio.
  if printf '%s' "$LEC24" | grep -q '^Ningún valor anómalo'; then
    echo "  FAIL  REQ-024 CA-08 (iii) y NO afirma «Ningún valor anómalo»: lo afirma con la cola sin medir"; FAIL=$((FAIL+1))
  else
    echo "  PASS  REQ-024 CA-08 (iii) y NO afirma «Ningún valor anómalo» con la cola sin medir"; PASS=$((PASS+1))
  fi
fi
# CONTROL EN LA OTRA DIRECCION, en la misma corrida: el MISMO archivo con el rango CERRADO
# cuenta 2 en los tres lectores y la puerta deniega POR LA COLA, no por medibilidad. Sin este
# control, «deniega» tambien lo cumpliria una funcion que rechazara cualquier archivo.
printf '%s' "${COLA24_ABIERTA/<!-- una nota que nadie cerro/<!-- una nota que si cierro -->}" > "$D24/PENDING_APPROVAL.md"
cp "$D24/PENDING_APPROVAL.md" "$PROJ/PENDING_APPROVAL.md"
chk24 "REQ-024 CA-08 control: con el rango CERRADO los tres cuentan 2 (lo visible = lo contado)" \
  "2|2|2" "$(tres24)"
check_motivo "REQ-024 CA-08 control: y la puerta deniega POR LA COLA, no por medibilidad" \
  'hay 2 aprobación' guard-completado.sh "$CIERRE"

# CA-09 — un CIERRE SIN APERTURA no retira nada. `### Migrar A --> B` es un titulo ordinario,
# sin comentario ninguno, y hasta 1.33.0 hacia desaparecer una aprobacion humana de la cuenta
# porque el `continue` de la rama de cierre era INCONDICIONAL. La regla va por PROPIEDAD: el
# cierre de un rango solo tiene efecto si hay un rango abierto.
printf '## Pendientes\n### [2026-09-05] (dev) — Migrar A --> B\n' > "$D24/PENDING_APPROVAL.md"
cp "$D24/PENDING_APPROVAL.md" "$PROJ/PENDING_APPROVAL.md"
check_motivo "REQ-024 CA-09 un cierre HUERFANO no retira la entrada: la puerta deniega y dice 1" \
  'hay 1 aprobación' guard-completado.sh "$CIERRE"
chk24 "REQ-024 CA-09 los tres lectores cuentan 1 sobre esa misma forma (contaban 0)" \
  "1|1|1" "$(tres24)"
# (i) NO-REGRESION de REQ-009 CA-07: el ejemplo multilinea COMPLETAMENTE comentado de la
# plantilla sigue contando 0. Es correcto y deseable, y es lo primero que un arreglo mal
# hecho de CA-09 rompe.
cp "$TPL_DIR/PENDING_APPROVAL.md.tpl" "$D24/PENDING_APPROVAL.md"
cp "$TPL_DIR/PENDING_APPROVAL.md.tpl" "$PROJ/PENDING_APPROVAL.md"
chk24 "REQ-024 CA-09 (i) el ejemplo multilinea comentado de la plantilla sigue contando 0" \
  "0|0|0" "$(tres24)"
# (ii) NO-REGRESION de la frontera de grano de LINEA: una anotacion de comentario CERRADA
# dentro de su propia linea sigue contando lo que cuenta hoy —0—, porque este REQ NO cambia
# ese conteo mientras el ADR del grano de la cola no lo decida (CA-10, ADR-010).
printf '## Pendientes\n### [2026-09-05] (dev) — Real <!-- nota -->\n' > "$D24/PENDING_APPROVAL.md"
cp "$D24/PENDING_APPROVAL.md" "$PROJ/PENDING_APPROVAL.md"
chk24 "REQ-024 CA-09 (ii) la anotacion cerrada en su propia linea sigue contando 0 (grano de linea)" \
  "0|0|0" "$(tres24)"

# CA-10 — LA FRONTERA SE MANTIENE Y EL BANCO LA MIDE. `ADR-010` decide no cruzarla: cambiar el
# conteo de la cola es cambiar el veredicto de la puerta y el contrato de REQ-009 CA-04/CA-07,
# que esta en estado terminal. Lo que este caso mide es la DIFERENCIA entre los dos lectores
# sobre la misma forma —la cola descarta la linea entera; la cabecera de un REQ sustituye el
# rango por un espacio y sigue juzgando el resto—, para que una divergencia futura falle una
# prueba en vez de descubrirse en una auditoria. Si algun dia se unifican, este caso falla y
# obliga a pasar por el ADR y por el write-back de REQ-009.
GRANO24="$(bash -c '. "$1/lib.sh" >/dev/null 2>&1
  l="### [2026-09-05] (dev) — Real <!-- nota -->"
  ARNES_CITA=0; ARNES_CR=0; arnes_sin_cita "$l"
  case "$ARNES_LINEA" in "###"[[:space:]]*) cab=cuenta ;; *) cab=descarta ;; esac
  arnes_cola_pendientes /dev/null >/dev/null 2>&1
  printf "## Pendientes\n%s\n" "$l" > "$2"
  if arnes_cola_pendientes "$2"; then col="$ARNES_COLA"; else col=nomedible; fi
  printf "cabecera=%s cola=%s" "$cab" "$col"' _ "$HOOKS_DIR" "$D24/g24.md")"
chk24 "REQ-024 CA-10 los dos lectores DECIDEN AL CONTRARIO sobre la misma forma, y se mide" \
  "cabecera=cuenta cola=0" "$GRANO24"

# CA-11 (i) — NI UNA TRANSCRIPCION MAS de la nocion de comentario DE LA COLA.
#
# QUE SE CUENTA, y no es «cuantas veces aparece el texto `<!--`»: la FORMA en que una
# transcripcion se escribe, que es un brazo de `case` sobre la linea (`*'<!--'*)`,
# `*'-->'*)`). Un motivo de denegacion que MENCIONA el delimitador entre comillas es prosa,
# no una regla, y contarlo daria rojo por el propio arreglo — que es lo que paso al escribir
# este caso la primera vez.
#
# LAS DOS MITADES, y las dos son el criterio:
#   (a) los CONSUMIDORES —la puerta, el bloque derivado, el informe— tienen CERO. Si alguno
#       tuviera su propia copia, mutar `hooks/lib.sh` no le cambiaria la respuesta, que es lo
#       que REQ-009 CA-03 ya mide por mutacion tres bloques mas arriba.
#   (b) dentro de `hooks/lib.sh` hay EXACTAMENTE DOS funciones con esa forma, y se NOMBRAN:
#       `arnes_cola_pendientes` (el grano de LINEA de la cola) y `arnes_sin_cita` (el grano de
#       RANGO de la cabecera). Son las dos reglas declaradas y distintas que `ADR-010`
#       mantiene separadas. Una TERCERA seria la transcripcion que este criterio prohibe, y
#       una sola seria que alguien las unifico sin pasar por el ADR ni por el write-back de
#       REQ-009: el caso falla en los dos sentidos, no solo hacia arriba.
TRANS24=$(grep -c -e "\*'<!--'\*)" -e "\*'-->'\*)" \
  "$HOOKS_DIR/guard-completado.sh" "$HOOKS_DIR/estado-derivado.sh" \
  "$HOOKS_DIR/../tools/arnes-lectura.sh" 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')
FUNS24="$(awk "/^[a-z_]+\\(\\)[ \t]*\\{/ { f = \$0; sub(/\\(\\).*/, \"\", f) }
                index(\$0, \"*'<!--'*)\") || index(\$0, \"*'-->'*)\") { v[f] = 1 }
                END { n = 0; for (k in v) { n++; s = s (s ? \",\" : \"\") k }; print n \" \" s }" \
          "$HOOKS_DIR/lib.sh" | tr ' ' '|')"
chk24 "REQ-024 CA-11 (i) los consumidores tienen 0 transcripciones propias del par de comentario" \
  "0" "$TRANS24"
chk24 "REQ-024 CA-11 (i) y en lib.sh siguen siendo DOS reglas declaradas y distintas, nombradas" \
  "2|arnes_cola_pendientes,arnes_sin_cita" "$FUNS24"
rm -rf "$D24"
