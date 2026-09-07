# Sección 13 del banco — 13-orden-del-ciclo
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=9

seccion_nueva "Orden del ciclo (seguridad tras QA):"
mkreq_r "REQ-050" "no" "pendiente" "pendiente" ""
check "firmar Seguridad con QA pendiente -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-050.md" "" "" 'Seguridad: aprobado')"
check "...y tampoco al cerrar de paso -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-050.md" "" "" 'Estado: completado
Seguridad: aprobado')"
# La excepcion se declara AL EMITIRLA, no al invocarla.
check "auditoria PREVENTIVA declarada -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-050.md" "" "" 'Seguridad: preventiva')"
mkreq_r "REQ-051" "no" "aprobado" "pendiente" ""
check "orden correcto: QA ya aprobado -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-051.md" "" "" 'Seguridad: aprobado')"
mkreq_r "REQ-052" "no" "pendiente" "pendiente" ""
check "edicion que NO toca Seguridad -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-052.md" "" "" 'Notas: trabajo en curso')"
# Un REQ anterior al campo QA no puede quedar bloqueado por esto.
mkreq_r "REQ-053" "no" "" "pendiente" ""
check "REQ antiguo sin campo QA -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-053.md" "" "" 'Seguridad: aprobado')"
# La firma preventiva desbloquea el ORDEN, no el CIERRE: se emitio antes de que
# existiera el codigo, luego no acredita el codigo. Un REQ critico sigue exigiendo
# la auditoria de verdad.
mkreq_r "REQ-054" "sí" "aprobado" "preventiva" ""
check "critico: solo firma preventiva no cierra -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-054.md" "" "" 'Estado: completado')"
mkreq_r "REQ-055" "sí" "aprobado" "aprobado" ""
check "critico: auditoria real si cierra -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-055.md" "" "" 'Estado: completado')"
# Sin esto la regla del orden seria un abrazo mortal: QA firma primero, siempre.
mkreq_r "REQ-056" "sí" "pendiente" "pendiente" ""
check "sensible: QA firma sin esperar a seguridad -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-056.md" "" "" 'QA: aprobado')"

# --- Formas DECORADAS: el banco escribia siempre limpio -----------------------
# LECCION (2026-09-04): un proyecto real declaraba `Sensible a seguridad: **si**`
# en siete REQ y NINGUNO casaba -- la puerta de seguridad no llegaba a existir para
# ellos. El banco no lo vio porque escribe sus propios REQ y los escribe limpios:
# veinticuatro fixtures y solo dos valores, "si" y "no".
#
# Es EL MISMO diagnostico que quedo escrito en 1.16.0 sobre otro campo --"el banco
# no lo veia porque escribia su propio archivo limpio, nunca la plantilla"-- y
# reaparecio porque entonces se arreglo el CASO y no el BANCO. Por eso ahora cada
# campo que se compara contra una forma cerrada tiene su fixture decorado, con sus
# controles negativos: probar que no se estorba a quien escribe `no` es lo que da
# valor a los `deny`.
