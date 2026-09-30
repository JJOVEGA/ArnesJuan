# Sección 02 del banco — 02-guard-completado-transicion
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=2
PISO_AUTONOMO_SECCION=10  # 8 preámbulo + 0 maquinaria compartida duplicada + 2 bloque indivisible mayor · REQ-014 CA-18

  seccion_nueva "A3/A2 — guard-completado.sh (transición a completado):"
check "REQ -> en-progreso (no completado) -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: en-progreso')"
check "REQ -> completado, sin pendientes, gate ok -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-001.md" "" "" 'Estado: completado')"

