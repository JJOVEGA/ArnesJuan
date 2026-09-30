# Sección 16 del banco — 16-guard-punto-de-entrada
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=10
PISO_AUTONOMO_SECCION=33  # 8 preámbulo + 0 maquinaria compartida duplicada + 25 bloque indivisible mayor · REQ-014 CA-18

  seccion_nueva "guard.sh — punto de entrada unico (los dos guardianes, un proceso):"
check "A1 por guard.sh: coordinadora edita src/ -> deny" deny guard.sh \
  "$(emite_edit "$PROJ/src/app.ts" "" "" 'hola')"
check "A1 por guard.sh: desarrollador edita src/ -> allow" allow guard.sh \
  "$(emite_edit "$PROJ/src/app.ts" "a1" "arnes-juan:desarrollador" 'hola')"
check "A1 por guard.sh: edicion neutra -> allow" allow guard.sh \
  "$(emite_edit "$PROJ/docs/nota.md" "" "" 'hola')"
# CRITICO: el primer guardian permite y el SEGUNDO debe seguir juzgando.
mkreq "$PROJ/requirements/REQ-030.md" "no" "pendiente" "n/a"
check "guard.sh: el 2o guardian sigue corriendo tras el 1o -> deny" deny guard.sh \
  "$(emite_edit "$PROJ/requirements/REQ-030.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-031.md" "no" "aprobado" "n/a"
check "guard.sh: cierre limpio -> allow" allow guard.sh \
  "$(emite_edit "$PROJ/requirements/REQ-031.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-032.md" "sí" "aprobado" "pendiente"
check "guard.sh: sensible sin seguridad -> deny" deny guard.sh \
  "$(emite_edit "$PROJ/requirements/REQ-032.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-033.md" "no" "aprobado" "n/a" "SEC-9 (instrumento)"
check "guard.sh: hallazgo de instrumento -> allow" allow guard.sh \
  "$(emite_edit "$PROJ/requirements/REQ-033.md" "" "" 'Estado: completado')"
check "guard.sh: Bash escribe en src/ -> deny" deny guard.sh \
  "$(emite_bash "echo x > src/app.ts" "" "")"
check "guard.sh: Bash cierra un REQ -> deny" deny guard.sh \
  "$(emite_bash "sed -i 's/en-revision/completado/' requirements/REQ-031.md" "" "")"
check "guard.sh: Bash de lectura -> allow" allow guard.sh \
  "$(emite_bash "grep -rn foo src/" "" "")"

# --- El asterisco de NOTA AL PIE no es enfasis --------------------------------
# El arreglo de 1.21.0 retiraba todo `*`, y eso convertia `Seguridad: aprobado*`
# en `aprobado`: un asterisco tras una firma es una llamada a nota al pie, y una
# nota al pie apunta a una SALVEDAD -- lo contrario de una firma incondicional.
#
# Fue el mismo error girado: el argumento se hizo sobre `Sensible a seguridad:`
# --donde `**si**` si es el mismo valor-- y el cambio se aplico a los cinco
# campos. El sujeto del arreglo era mas estrecho que su poblacion.
#
# El enfasis de Markdown es PAREADO por definicion: solo se retira cuando envuelve
# el valor entero. Un asterisco suelto nunca envuelve nada.
