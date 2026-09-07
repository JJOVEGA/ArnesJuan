# Sección 19 del banco — 19-cola-hasta-la-cabecera
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=2

  seccion_nueva "Cola de aprobaciones: la seccion acaba en la siguiente cabecera:"
mkreq "$PROJ/requirements/REQ-085.md" "no" "aprobado" "n/a"
printf '## Pendientes\n\n## Notas\n### [2026-01-01] esto NO es una aprobacion\n- contexto\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "un ### bajo OTRA cabecera no es cola -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-085.md" "" "" 'Estado: completado')"
printf '## Pendientes\n### [2026-01-01] una aprobacion de verdad\n- contexto\n\n## Notas\n### otra cosa\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "...pero uno bajo Pendientes si -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-085.md" "" "" 'Estado: completado')"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"

# --- Continuidad automatica: el bloque DERIVADO de ESTADO.md -------------------
# Este hook no decide nada (no hay deny/allow que mirar): escribe un archivo. Asi
# que se comprueba por CONTENIDO, que es la misma regla que el arnes aplica a todo
# lo demas -- se acredita por lo que quedo escrito, no porque el comando dijera
# que si.
#
# Lo que hay que fijar, por orden de dano si se rompe:
#   1. que NO estorbe donde no le llaman (sin manifiesto, repo ajeno)
#   2. que NUNCA falle (un hook Stop que falla deja la sesion colgada)
#   3. que no pise lo que escribio una persona
#   4. que correrlo dos veces de lo mismo
