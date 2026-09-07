# Sección 11 del banco — 11-nivel-de-rigor
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=9

  seccion_nueva "Nivel de rigor:"
mkreq_r "REQ-040" "no" "pendiente" "n/a" ""
check "sin Rigor + QA pendiente -> deny (como siempre)" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-040.md" "" "" 'Estado: completado')"
mkreq_r "REQ-041" "sí" "aprobado" "pendiente" ""
check "sin Rigor + sensible sin seguridad -> deny (como siempre)" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-041.md" "" "" 'Estado: completado')"
mkreq_r "REQ-042" "no" "pendiente" "n/a" "ligero"
check "LIGERO no exige veredictos -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-042.md" "" "" 'Estado: completado')"
mkreq_r "REQ-043" "no" "pendiente" "n/a" "estandar"
check "estandar exige QA -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-043.md" "" "" 'Estado: completado')"
mkreq_r "REQ-044" "no" "aprobado" "pendiente" "critico"
check "critico exige seguridad -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-044.md" "" "" 'Estado: completado')"
mkreq_r "REQ-045" "no" "aprobado" "aprobado" "critico"
check "critico con QA y seguridad -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-045.md" "" "" 'Estado: completado')"
# EL SUELO: declarar un nivel menor sobre un REQ sensible NO lo baja.
mkreq_r "REQ-046" "sí" "pendiente" "n/a" "ligero"
check "ligero sobre SENSIBLE no baja el suelo -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-046.md" "" "" 'Estado: completado')"
mkreq_r "REQ-047" "sí" "aprobado" "pendiente" "estandar"
check "estandar sobre SENSIBLE no baja el suelo -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-047.md" "" "" 'Estado: completado')"
# Un valor inventado nunca debe abrir la puerta.
mkreq_r "REQ-048" "no" "pendiente" "n/a" "inventado"
check "Rigor invalido se ignora, no abre -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-048.md" "" "" 'Estado: completado')"

# --- Orden del ciclo: seguridad no firma lo que QA no ha validado --------------
# La regla ya estaba en AGENTS.md 6; lo que faltaba era que se cumpliera. Corre en
# CUALQUIER edicion del REQ, no solo al cerrarlo: el dano se hace al escribir el
# veredicto, no al cierre.
