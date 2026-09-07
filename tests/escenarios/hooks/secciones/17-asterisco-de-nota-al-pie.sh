# Sección 17 del banco — 17-asterisco-de-nota-al-pie
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=4

  seccion_nueva "Asterisco de nota al pie (una salvedad no es una firma):"
mkreq "$PROJ/requirements/REQ-074.md" "sí" "aprobado" "aprobado*"
check "'aprobado*' NO cierra un critico -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-074.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-075.md" "sí" "aprobado" "*aprobado"
check "'*aprobado' tampoco -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-075.md" "" "" 'Estado: completado')"
# Control positivo: el enfasis PAREADO si se retira, o el arreglo habria roto lo
# que 1.21.0 vino a arreglar.
mkreq "$PROJ/requirements/REQ-076.md" "sí" "aprobado" "*aprobado*"
check "'*aprobado*' pareado si cierra -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-076.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-077.md" "**sí**" "aprobado" "pendiente"
check "y '**sí**' sigue exigiendo auditoria -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-077.md" "" "" 'Estado: completado')"

# --- El parentesis es EVIDENCIA, y la evidencia no cambia el veredicto ---------
# Medido en un proyecto real: 26 REQ paralizados porque su convencion es
# `QA: aprobado (medido el 3/9, 42 pruebas)` -- el veredicto con lo que lo sostiene
# al lado-- y la comparacion exigia la palabra exacta. La alternativa era quitar los
# parentesis de 35 lineas, o sea BORRAR LA EVIDENCIA del encabezado del REQ, que es
# media razon de ser de este arnes.
#
# La primera version metia el matiz DENTRO del parentesis (`aprobado (preventiva)`),
# y el mismo signo significaba "evidencia" en un caso y "matiz que invierte el
# veredicto" en el otro. Esa ambiguedad era un error de diseño y se QUITO en vez de
# arbitrarse: un matiz que cambia el veredicto ES OTRO VEREDICTO.
