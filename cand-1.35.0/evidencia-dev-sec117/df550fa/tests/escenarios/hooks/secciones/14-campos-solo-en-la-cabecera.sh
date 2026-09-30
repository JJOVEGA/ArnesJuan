# Sección 14 del banco — 14-campos-solo-en-la-cabecera
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=36
PISO_AUTONOMO_SECCION=167  # 15 preámbulo + 0 maquinaria compartida duplicada + 152 bloque indivisible mayor · REQ-014 CA-18

  # --- Los campos valen SOLO en la cabecera: la puerta -------------------------------
# Medido: `Seguridad: aprobado (A-009, 2026-09-02)` a columna cero dentro de
# `## Historial de cambios` cerraba un REQ critico cuya cabecera decia `pendiente`. La
# forma con parentesis final es la que normaliza a `aprobado` limpio; la forma con texto
# detras denegaba POR ACCIDENTE. Es la familia de `**si**`: la maquina lee algo distinto
# de lo que la cabecera declara. La regla es estructural --antes del primer `## `--, no
# el nombre de una seccion, que seria mapeo del proyecto.
seccion_nueva "Campos solo en la cabecera (la historia no es un veredicto):"
printf '# REQ-110\nEstado: en-revisión\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: pendiente\n\n## Historial de cambios\n- 2026-09-01: se abrio la auditoria\nSeguridad: aprobado (A-009, 2026-09-02)\n' > "$PROJ/requirements/REQ-110.md"
check "historia con 'Seguridad: aprobado (...)' a col. 0 NO cierra -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-110.md" "" "" 'Estado: completado')"
printf '# REQ-111\nEstado: en-revisión\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: aprobado\n\n## Historial de cambios\nSeguridad: pendiente\n' > "$PROJ/requirements/REQ-111.md"
check "control: la CABECERA si se lee (aprobado arriba, pendiente en historia) -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-111.md" "" "" 'Estado: completado')"
printf '# REQ-112\nEstado: en-revisión\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: pendiente\n\n## Historial\n- Seguridad: aprobado (A-009)\n' > "$PROJ/requirements/REQ-112.md"
check "vineta '- Seguridad:' en historia tampoco cuenta -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-112.md" "" "" 'Estado: completado')"
# Un fragmento de Edit no tiene `##`: se lee entero, como siempre.
printf '# REQ-113\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-113.md"
check "un fragmento sin '##' se lee entero: QA aprobado en el Edit -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-113.md" "" "" 'QA: aprobado
Estado: completado')"
# --- El bypass por MultiEdit (medido en 1.30.1) -------------------------------------
# Un MultiEdit que cerraba el REQ y aprobaba SOLO la linea del historial pasaba: se
# concatenaban los `new_string` y el `## ` se quedaba en el disco. El hook reconstruye
# ahora el documento resultante y lee la cabecera de ahi.
printf '# REQ-114\nEstado: en-revisión\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: pendiente\n\n## Historial\n\nSeguridad: pendiente (registro anterior)\n' > "$PROJ/requirements/REQ-114.md"
check "MultiEdit: cierra y aprueba SOLO la linea del historial -> deny" deny guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-114.md" 'Estado: en-revisión' 'Estado: completado' 'Seguridad: pendiente (registro anterior)' 'Seguridad: aprobado (A-009)')"
check "control: MultiEdit que aprueba la CABECERA y cierra -> allow" allow guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-114.md" 'Estado: en-revisión' 'Estado: completado' $'Seguridad: pendiente\n' $'Seguridad: aprobado (A-009)\n')"
# El mismo bypass sobre un archivo CRLF (Windows): la reconstruccion tiene que casar igual.
printf '# REQ-115\r\nEstado: en-revisión\r\nSensible a seguridad: sí\r\nQA: aprobado\r\nSeguridad: pendiente\r\n\r\n## Historial\r\n\r\nSeguridad: pendiente (registro anterior)\r\n' > "$PROJ/requirements/REQ-115.md"
check "MultiEdit sobre un REQ CRLF: el bypass tambien -> deny" deny guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-115.md" 'Estado: en-revisión' 'Estado: completado' 'Seguridad: pendiente (registro anterior)' 'Seguridad: aprobado (A-009)')"
# Y al reves: `Estado: completado` escrito SOLO en la historia no es una transicion.
check "Edit: 'Estado: completado' solo en la historia NO es una transicion -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-114.md" 'Seguridad: pendiente (registro anterior)' $'Seguridad: pendiente (registro anterior)\n- 2026-08-01: Estado: completado (intento anterior, revertido)')"
# --- El bypass por SUSTITUCION DEL VALOR (medido en 1.30.2) -------------------------
# Una revision externa cerro un REQ con `old_string: en-revisión` / `new_string: completado`.
# El fragmento no escribe la palabra «Estado» en ninguna parte, y el hook exigia esa palabra
# EN EL FRAGMENTO antes de correr las puertas: salia por arriba y devolvia ALLOW con
# `QA: pendiente`. Sustituir el VALOR es la forma mas natural de cerrar un REQ a mano.
# Ahora, con el documento reconstruido, la transicion se lee del DOCUMENTO: la cabecera en
# disco no lo decia y la resultante si.
mkreq "$PROJ/requirements/REQ-120.md" "no" "pendiente" "n/a"
check "transicion por documento: Edit que sustituye SOLO el valor -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-120.md" 'en-revisión' 'completado')"
check_motivo "transicion por documento: ...y el motivo nombra el veredicto que falta" "QA es 'pendiente'" \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-120.md" 'en-revisión' 'completado')"
# Control positivo: el mismo Edit sobre un REQ que SI puede cerrarse no puede estorbar.
mkreq "$PROJ/requirements/REQ-121.md" "no" "aprobado" "n/a"
check "transicion por documento: control, SOLO el valor con todo en verde -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-121.md" 'en-revisión' 'completado')"
# El suelo del REQ sensible tambien se aplica por esta via.
mkreq "$PROJ/requirements/REQ-122.md" "sí" "aprobado" "pendiente"
check "transicion por documento: SOLO el valor sobre un REQ sensible sin auditoria -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-122.md" 'en-revisión' 'completado')"
# MultiEdit: una edicion sustituye el valor y la otra anota el historial.
printf '# REQ-124\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n\n## Historial\n| 2026-09-01 | nace |\n' > "$PROJ/requirements/REQ-124.md"
check "transicion por documento: MultiEdit con SOLO el valor + fila de historial -> deny" deny guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-124.md" 'en-revisión' 'completado' '| 2026-09-01 | nace |' $'| 2026-09-01 | nace |\n| 2026-09-02 | cierra |')"
# `replace_all`: el valor aparece ANTES de la cabecera, asi que solo sustituyendo TODAS las
# ocurrencias queda `Estado: completado`. Es lo que separa "se reconstruyo" de "se adivino".
printf '# REQ-125 (nacio en-revisión)\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-125.md"
check "transicion por documento: replace_all sustituye TODAS las ocurrencias -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-125.md" 'en-revisión' 'completado' 1)"
check "transicion por documento: control, sin replace_all solo la primera y la cabecera no cambia -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-125.md" 'en-revisión' 'completado')"
# El mismo bypass sobre un archivo CRLF: el CR no puede devolver un ALLOW por la puerta de atras.
printf '# REQ-123\r\nEstado: en-revisión\r\nSensible a seguridad: no\r\nQA: pendiente\r\nSeguridad: n/a\r\n' > "$PROJ/requirements/REQ-123.md"
check "transicion por documento: SOLO el valor sobre un REQ CRLF -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-123.md" 'en-revisión' 'completado')"
# --- El fallback sigue vivo: sin documento reconstruido se juzga el fragmento ---------
mkreq "$PROJ/requirements/REQ-126.md" "no" "pendiente" "n/a"
check "transicion por documento: Write con la cabecera completa -> deny" deny guard-completado.sh \
  "$(emite_write "$PROJ/requirements/REQ-126.md" $'# REQ-126\nEstado: completado\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n')"
# Y al reves: un `Write` cuya CABECERA sigue en revision pero cuyo cuerpo cita el estado
# terminal dentro de un criterio. Medido con 1.30.2 mientras se redactaba un REQ: el `grep`
# miraba todo el contenido y lo denegaba. Manda la cabecera, aqui tambien.
check "transicion por documento: control, Write que solo CITA el estado en el cuerpo -> allow" allow guard-completado.sh \
  "$(emite_write "$PROJ/requirements/REQ-126.md" $'# REQ-126\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n\n## Criterios\n- Cuando el REQ queda `Estado: completado (ejemplo citado)`, entonces...\n')"
# QA REQ-001 v2 — CA-45. El REQ declara UN solo cambio de conducta `deny -> allow`
# respecto a v1.30.2 (CA-36) y hasta ahora NO tenia caso: la evidencia de CA-50 no se
# podia correr. Es el `Write` que reescribe entero un REQ que EN DISCO ya estaba en el
# estado terminal; no hay transicion, asi que no corre ninguna de las tres puertas —ni
# con la cola de aprobaciones abierta, ni con `Seguridad: pendiente`, ni con un hallazgo
# `usuario/dinero`—. MEDIDO: v1.30.2 responde `deny`; la candidata, `allow`.
printf '# REQ-131\nEstado: completado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\n' > "$PROJ/requirements/REQ-131.md"
printf '## Pendientes\n\n### Fusionar el PR de la candidata\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check "transicion por documento: Write sobre un REQ que EN DISCO ya estaba terminal -> allow" allow guard-completado.sh \
  "$(emite_write "$PROJ/requirements/REQ-131.md" $'# REQ-131\nEstado: completado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: X-1 (usuario/dinero)\n\n## Historia\nreescrito entero\n')"
# Control obligatorio: el MISMO documento sobre un REQ que en disco NO estaba terminal
# sigue en `deny`. Sin el, el ALLOW de arriba no prueba que la regla sea "no hay
# transicion": probaria que la puerta dejo de mirar.
printf '# REQ-132\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\n' > "$PROJ/requirements/REQ-132.md"
check "transicion por documento: control, el mismo Write sobre un REQ NO terminal -> deny" deny guard-completado.sh \
  "$(emite_write "$PROJ/requirements/REQ-132.md" $'# REQ-132\nEstado: completado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nHallazgos abiertos: X-1 (usuario/dinero)\n\n## Historia\nreescrito entero\n')"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
mkreq "$PROJ/requirements/REQ-127.md" "no" "pendiente" "n/a"
check "transicion por documento: old_string ausente + 'Estado: completado' en el fragmento -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-127.md" "" "" 'Estado: completado')"
check "transicion por documento: old_string ausente y fragmento 'completado' a secas -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-127.md" "" "" 'completado')"
# Un REQ que NO existe en disco: `disk` vacio no puede tumbar el hook con `set -u` ni dejar traza.
if [ -z "$FILTRO" ] || printf '%s' "transicion por documento: REQ inexistente en disco" | grep -qi -- "$FILTRO"; then
salida="$(corre guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-999.md" 'en-revisión' 'completado')")"
if ! printf '%s' "$salida" | grep -Eq '"permissionDecision": *"deny"' && [ ! -s "$ERRLOG" ]; then
  echo "  PASS  transicion por documento: REQ inexistente en disco -> allow y sin traza de bash"; PASS=$((PASS+1))
else
  echo "  FAIL  transicion por documento: REQ inexistente en disco: salida=<$salida>"; diag; FAIL=$((FAIL+1))
fi
fi
# --- No hay transicion: la cabecera en disco YA decia el estado terminal --------------
printf '# REQ-128\nEstado: completado\nSensible a seguridad: no\nQA: pendiente\nSeguridad: n/a\n\n## Historia\ntexto original\n' > "$PROJ/requirements/REQ-128.md"
check "transicion por documento: la cabecera en disco YA decia completado -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-128.md" 'texto original' 'texto corregido')"
check "transicion por documento: reabrir un REQ cerrado a en-progreso -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-128.md" 'completado' 'en-progreso')"
# --- Las puertas A2 y A3 corren sobre el documento reconstruido, no sobre el fragmento --
mkreq "$PROJ/requirements/REQ-129.md" "no" "aprobado" "n/a"
printf '## Pendientes\n\n### Fusionar el PR de la candidata\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
check_motivo "transicion por documento: SOLO el valor con la cola de aprobaciones abierta -> deny" "PENDING_APPROVAL" \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-129.md" 'en-revisión' 'completado')"
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
setgates '.quality_gates = ["false"]'
check_motivo "transicion por documento: SOLO el valor con una quality gate roja -> deny" "quality gate" \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-129.md" 'en-revisión' 'completado')"
setgates '.quality_gates = ["true"]'
# --- El estado terminal es el DEL MANIFIESTO, no la palabra «completado» ---------------
mkreq "$PROJ/requirements/REQ-130.md" "no" "pendiente" "n/a"
setcfg '.estados.completado = "hecho"'
check "transicion por documento: estado terminal 'hecho' del manifiesto -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-130.md" 'en-revisión' 'hecho')"
check "transicion por documento: control, 'completado' ya no es terminal en ese manifiesto -> allow" allow guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-130.md" 'en-revisión' 'completado')"
setcfg '.estados.completado = "completado"'
# QA REQ-001 — variantes de escritura del MISMO cierre, independientes de las del
# desarrollador. Todas dejan la cabecera resultante en el estado terminal, asi que todas
# tienen que denegar; si alguna se colara, la regla nueva estaria leyendo la forma del
# fragmento y no el documento. Todas verificadas en rojo contra 1.30.2 salvo la primera.
mkreq "$PROJ/requirements/REQ-140.md" "no" "pendiente" "n/a"
check "QA: Edit con la LINEA ENTERA 'Estado: completado' -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-140.md" 'Estado: en-revisión' 'Estado: completado')"
check "QA: el valor en MAYUSCULAS -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-140.md" 'en-revisión' 'COMPLETADO')"
check "QA: el valor con su parentesis de evidencia -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-140.md" 'en-revisión' 'completado (por fin)')"
check "QA: el valor en **negrita** -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-140.md" 'en-revisión' '**completado**')"
check "QA: el valor con espacios de mas tras los dos puntos -> deny" deny guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-140.md" 'Estado: en-revisión' 'Estado:   completado')"
# MultiEdit ENCADENADO: la 1a edicion escribe el texto que busca la 2a. Solo aplicando las
# ediciones EN ORDEN sobre el documento —como hara la herramienta— queda la cabecera
# cerrada; leyendo los fragmentos sueltos, ninguno dice el estado terminal.
mkreq "$PROJ/requirements/REQ-141.md" "no" "pendiente" "n/a"
check "QA: MultiEdit encadenado (edit1 crea lo que busca edit2) -> deny" deny guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-141.md" 'en-revisión' 'PROVISIONAL' 'PROVISIONAL' 'completado')"
check "QA: control, edit2 busca lo que edit1 destruyo: la herramienta fallaria -> allow" allow guard-completado.sh \
  "$(emite_multiedit "$PROJ/requirements/REQ-141.md" 'en-revisión' 'PROVISIONAL' 'en-revisión' 'completado')"

