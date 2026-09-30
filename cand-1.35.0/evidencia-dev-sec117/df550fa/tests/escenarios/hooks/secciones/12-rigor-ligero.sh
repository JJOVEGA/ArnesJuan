# Sección 12 del banco — 12-rigor-ligero
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=4
PISO_AUTONOMO_SECCION=29  # 9 preámbulo + 0 maquinaria compartida duplicada + 20 bloque indivisible mayor · REQ-014 CA-18

  # --- `ligero` salta los VEREDICTOS, no las PUERTAS -------------------------------
seccion_nueva "Rigor ligero: salta veredictos, no puertas:"
# La plantilla promete "analista + desarrollador + quality gates" para ligero. Hasta
# 1.28.0 el codigo hacia `return 0` antes de la clase del hallazgo, de las aprobaciones
# pendientes y de las quality gates: un REQ ligero cerraba con el build en rojo. Lo
# encontro una revision externa leyendo el codigo; estos casos lo fijan.
mkreq_r "REQ-090" "no" "pendiente" "n/a" "ligero"
setgates '.quality_gates = ["false"]'
check "ligero con quality gate ROJA -> deny (la plantilla promete gates)" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-090.md" "" "" 'Estado: completado')"
setgates '.quality_gates = ["true"]'
printf '## Pendientes\n### [2026-09-05] (qa) — decision humana\n- Contexto: x\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "ligero con aprobacion humana PENDIENTE -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-090.md" "" "" 'Estado: completado')"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
mkreq "$PROJ/requirements/REQ-091.md" "no" "pendiente" "n/a" "SEC-7 (usuario/dinero)"
printf 'Rigor: ligero\n' >> "$PROJ/requirements/REQ-091.md"
check "ligero con hallazgo usuario/dinero ABIERTO -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-091.md" "" "" 'Estado: completado')"
# Control positivo de lo que SI salta: sin veredicto de QA, con todo lo demas verde.
check "ligero SIN veredicto de QA y todo verde -> allow (eso si lo salta)" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-090.md" "" "" 'Estado: completado')"

