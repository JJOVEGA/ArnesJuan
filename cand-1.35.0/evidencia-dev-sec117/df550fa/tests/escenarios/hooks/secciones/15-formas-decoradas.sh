# Sección 15 del banco — 15-formas-decoradas
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=15
PISO_AUTONOMO_SECCION=64  # 8 preámbulo + 0 maquinaria compartida duplicada + 56 bloque indivisible mayor · REQ-014 CA-18

seccion_nueva "Formas decoradas (marcado de Markdown en el valor):"
mkreq "$PROJ/requirements/REQ-060.md" "**sí**" "aprobado" "pendiente"
check "sensible en **negrita** exige auditoria -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-060.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-061.md" "**sí** — toca autenticación" "aprobado" "pendiente"
check "negrita + comentario tras el valor -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-061.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-062.md" "sí — gobierna la puerta" "aprobado" "pendiente"
check "comentario tras el valor, sin negrita -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-062.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-063.md" "_sí_" "aprobado" "pendiente"
check "sensible en _cursiva_ -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-063.md" "" "" 'Estado: completado')"
# El tercer estado: un valor que no se entiende cae del lado seguro. Sin esto, la
# lista de formas reconocidas seria una lista enumerada, y esas se pudren.
mkreq "$PROJ/requirements/REQ-064.md" "por evaluar" "aprobado" "pendiente"
check "valor que NO se entiende -> deny (lado seguro)" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-064.md" "" "" 'Estado: completado')"
check_motivo "...y la denegacion dice por que" "no se reconoce" guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-064.md" "" "" 'Estado: completado')"
# Controles negativos: el arnes NO puede estorbar a quien declara que no es sensible.
mkreq "$PROJ/requirements/REQ-065.md" "**no**" "aprobado" "pendiente"
check "no sensible en **negrita** -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-065.md" "" "" 'Estado: completado')"
# El conjunto que ABRE la puerta es minimo: solo una negacion explicita. `n/a` y
# `ninguna` son lo que se escribe cuando NO se ha clasificado, no cuando se ha
# decidido que no es sensible -- le abrian un hueco al fallo cerrado justo en el
# caso para el que se construyo. Lo delataba una asimetria: `n/a` abria y
# `no aplica`, la misma frase, cerraba. Ahora coinciden, y ninguna abre.
mkreq "$PROJ/requirements/REQ-066.md" "n/a" "aprobado" "pendiente"
check "'n/a' no abre la puerta -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-066.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-072.md" "no aplica" "aprobado" "pendiente"
check "...y 'no aplica' dice lo mismo -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-072.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-073.md" "ninguna" "aprobado" "pendiente"
check "'ninguna' tampoco abre -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-073.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-067.md" "no — es solo texto" "aprobado" "pendiente"
check "no + comentario tras el valor -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-067.md" "" "" 'Estado: completado')"
# Los otros campos tambien se comparan contra forma cerrada, y tambien se decoran.
mkreq "$PROJ/requirements/REQ-068.md" "no" "**aprobado**" "n/a"
check "QA en **negrita** cuenta como aprobado -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-068.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-069.md" "sí" "aprobado" "**aprobado**"
check "Seguridad en **negrita** cierra un critico -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-069.md" "" "" 'Estado: completado')"
# Y la firma PREVENTIVA sigue sin cerrar aunque venga decorada: quitar el marcado
# no puede convertirla en una firma completa. Es el fallo que el arreglo obvio
# --cortar el valor en el primer parentesis-- habria introducido.
mkreq "$PROJ/requirements/REQ-070.md" "sí" "aprobado" "**preventiva**"
check "preventiva decorada TAMPOCO cierra -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-070.md" "" "" 'Estado: completado')"
mkreq_r "REQ-071" "no" "pendiente" "n/a" "**ligero**"
check "Rigor **ligero** decorado se reconoce -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-071.md" "" "" 'Estado: completado')"

