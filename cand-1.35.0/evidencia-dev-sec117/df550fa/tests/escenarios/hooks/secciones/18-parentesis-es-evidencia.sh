# Sección 18 del banco — 18-parentesis-es-evidencia
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=6
PISO_AUTONOMO_SECCION=32  # 8 preámbulo + 0 maquinaria compartida duplicada + 24 bloque indivisible mayor · REQ-014 CA-18

  seccion_nueva "Parentesis = evidencia (el veredicto no cambia):"
mkreq "$PROJ/requirements/REQ-080.md" "no" "aprobado (medido el 3/9, 42 pruebas)" "n/a"
check "QA con su evidencia entre parentesis cierra -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-080.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-081.md" "sí" "aprobado" "aprobado (auditado el 3/9)"
check "Seguridad con evidencia cierra un critico -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-081.md" "" "" 'Estado: completado')"
# Balanceado y final, la misma leccion que el enfasis pareado: si no cierra, no es
# un parentesis, es texto -- y el texto sobra en un veredicto.
mkreq "$PROJ/requirements/REQ-083.md" "sí" "aprobado" "aprobado (sin cerrar"
check "parentesis sin cerrar no es evidencia -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-083.md" "" "" 'Estado: completado')"
# `preventiva` es SU PROPIO veredicto, no un matiz de aprobado. Sigue sin cerrar.
mkreq "$PROJ/requirements/REQ-082.md" "sí" "aprobado" "preventiva"
check "preventiva NO cierra un critico -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-082.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-084.md" "no" "pendiente" "pendiente"
check "preventiva desbloquea el ORDEN del ciclo -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-084.md" "" "" 'Seguridad: preventiva')"
# Medido por DOS proyectos: `aprobado (medido)` contaba y `**aprobado** (medido)` no,
# porque al normalizar el enfasis no envolvia el valor entero -- el parentesis estaba
# detras. Mismo valor, dos escrituras, veredictos opuestos: la asimetria de `n/a`.
mkreq "$PROJ/requirements/REQ-086.md" "no" "**aprobado** (medido el 3/9)" "n/a"
check "enfasis + evidencia: misma escritura, mismo veredicto -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-086.md" "" "" 'Estado: completado')"

# --- La cola de aprobaciones acaba donde acaba su seccion ----------------------
# Antes solo la cerraba una cabecera literal `## Resueltas`, asi que cualquier otra
# --`## Notas`, `## Historico`-- la dejaba abierta y sus `###` contaban como
# aprobaciones pendientes. Los proyectos lo esquivaban ordenando el archivo: carga,
# no estilo.
