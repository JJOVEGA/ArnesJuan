# Sección 13 del banco — 13-orden-del-ciclo
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=15
PISO_AUTONOMO_SECCION=40  # 8 preámbulo + 0 maquinaria compartida duplicada + 32 bloque indivisible mayor · REQ-014 CA-18

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
# --- SEC-083 · LA AUSENCIA DE `QA:` NO ES UN `QA: aprobado` --------------------------
# ESTE CASO DECÍA LO CONTRARIO, y por eso el defecto vivió aquí sin que nadie lo viera: se
# llamaba «REQ antiguo sin campo QA -> allow» y exigía ALLOW sobre una edición que ESCRIBE
# `Seguridad: aprobado`. Lo que protegía era un fail-open —la guarda llevaba un
# `[ -n "$qa" ]` delante, así que sin línea `QA:` la condición salía falsa y la firma
# pasaba—, y el nombre lo vestía de compatibilidad. La compatibilidad que sí es legítima es
# la de abajo (los dos discriminantes): una edición que NO TOCA el campo no se juzga, y eso
# lo sirve el `grep 'Seguridad:'` de dentro de la guarda, no el estado del campo `QA:`.
#
# NO SE RETIRA NINGÚN CASO: el fixture y su nombre se conservan y lo que cambia es el
# veredicto que se le exige. Un caso borrado no deja rastro de que alguna vez decidió al
# revés.
#
# Y LA DIRECCIÓN CONTRARIA SE MIDE EN LA MISMA CORRIDA, porque sin ella este `deny` no
# acredita nada: también lo daría una guarda que denegara toda edición de un REQ sin `QA:`.
mkreq_r "REQ-053" "no" "" "pendiente" ""
check "SEC-083 firmar Seguridad SIN ninguna linea QA -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-053.md" "" "" 'Seguridad: aprobado')"
# La otra mitad de `deniega` es NOMBRAR el campo que falta: un motivo que dice «su 'QA:' es
# ''» deja a la persona buscando un valor que no existe.
check_motivo "SEC-083 y el motivo NOMBRA el campo ausente, no un valor vacio" \
  "NO declara ningun 'QA:'" guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-053.md" "" "" 'Seguridad: aprobado')"
# COMENTAR LA LÍNEA ES LA MISMA AUSENCIA, y era la vía barata de SEC-047: la puerta no mide
# la VÍA, mide que el campo no llegue a declararse.
{ printf '# REQ-057\nEstado: en-revisión\nSensible a seguridad: no\n'
  printf '<!-- QA: pendiente -->\nSeguridad: pendiente\n'; } > "$PROJ/requirements/REQ-057.md"
check "SEC-083 con la linea QA COMENTADA (misma ausencia) -> deny" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-057.md" "" "" 'Seguridad: aprobado')"
# Y CUANDO LA LÍNEA SÍ ESTÁ PERO LA CLAVE NO SE LEE, manda la MEDIBILIDAD (`REQ-023 CA-02`):
# se deniega igual —eso no se negocia, es la misma ausencia por otra vía— pero el motivo cita
# el carácter INSERTADO y no «no declara ningún QA:», que mandaría a buscar una línea que
# existe y que el diff tampoco muestra. El caso vive aquí, en la puerta del ORDEN, porque esta
# vía no es una transición a `completado` y la guarda de medibilidad del cierre no la ve.
{ printf '# REQ-060\nEstado: en-revisión\nSensible a seguridad: no\n'
  printf '\xef\xbb\xbfQA: aprobado\nSeguridad: pendiente\n'; } > "$PROJ/requirements/REQ-060.md"
check_motivo "SEC-083 con un BOM DENTRO de la clave QA, manda la medibilidad y el motivo cita el caracter" \
  "INSERTADO DENTRO DE LA CLAVE" guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-060.md" "" "" 'Seguridad: aprobado')"
# La excepción nombrada sobrevive al arreglo: sin ella el auditor preventivo se queda sin
# vía y la fricción termina con alguien apagando el guard.
check "SEC-083 la firma PREVENTIVA sobre un REQ sin QA sigue pasando -> allow" allow \
  guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-053.md" "" "" 'Seguridad: preventiva')"
# DISCRIMINANTE (i): los veredictos YA CRUZADOS en disco —`$qa` NO vacío, que es justo el
# caso que el `-n` retirado no cubría— y una edición que no escribe `Seguridad:`.
mkreq_r "REQ-058" "no" "pendiente" "aprobado" ""
check "SEC-083 discriminante (i): cruzados en disco y la edicion no toca Seguridad -> allow" \
  allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-058.md" "" "" 'Notas: reordeno una seccion')"
# DISCRIMINANTE (ii): el REQ viejo de verdad —sin `QA:` y con la firma ya puesta— sigue
# editándose sin estorbo mientras nadie vuelva a escribir el campo.
mkreq_r "REQ-059" "no" "" "aprobado" ""
check "SEC-083 discriminante (ii): sin QA, firma en disco, edicion ajena -> allow" allow \
  guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-059.md" "" "" 'Notas: reordeno una seccion')"
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
