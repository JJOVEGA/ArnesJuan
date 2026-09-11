# Sección 42 del banco — 42-disparador-y-lector
# El disparador de una guarda reconoce el MISMO conjunto de formas que el lector (SEC-084,
# QA-024-19). Se ejecuta con `source` desde el corredor, en su propio subshell y con los
# ayudantes compartidos ya definidos (invariantes 3 y 4 del README del banco).
#
# QUE MIDE ESTA SECCION Y QUE NO, porque el nombre `SEC-084` ya vive en la seccion 41 y
# las dos cosas no son la misma. `v1.33.1` cambio el disparador de la guarda del ORDEN
# —dejo de preguntar por una cadena y paso a preguntar por el VALOR leido— y la 41 fija
# esa matriz. Lo que aquel arreglo NO toco es la OTRA sede del mismo archivo: el
# disparador del AVISO, que seguia siendo el mismo `grep` de cadena literal. Aqui se mide
# esa sede, y la mitad de la propiedad que ninguna de las dos cubria: una linea que una
# PERSONA lee como el campo y el lector no.
#
# LA PROPIEDAD, Y POR ESO LOS CASOS NO SON UNA LISTA DE TRES CADENAS: el conjunto que
# dispara la guarda tiene que ser el conjunto que gobierna. Se ejerce por sus DOS bordes
# —formas que el lector acepta y antes no disparaban; formas que el lector NO acepta y no
# dejaban rastro— y con los discriminantes que impiden que un aviso que se dispara SIEMPRE
# pase por un arreglo.
CASOS_ESPERADOS_SECCION=20
PISO_AUTONOMO_SECCION=59  # 22 preámbulo (líneas 1-22, la blanca y el `seccion_nueva` incluidos) + 0 maquinaria compartida duplicada + 37 bloque indivisible mayor (el bloque B, líneas 53-89) · REQ-014 CA-18 · REGLA para re-derivar los tres términos sin preguntar: «preámbulo» son las líneas previas al primer caso; un «bloque» es un grupo de líneas consecutivas sin blanca en medio, y el mayor es el B —los cuatro avisos de desfase, el caso de que avisar no deniega y el par cierre fail-closed / control positivo, que no se leen sueltos—; «maquinaria» es 0 porque este archivo no define ni un ayudante propio, usa los del corredor

seccion_nueva "El disparador reconoce lo que el lector (SEC-084 · QA-024-19):"

# --- A. LA SEDE QUE EL ARREGLO DEL ORDEN NO TOCO: EL AVISO ------------------------
# El `grep -q 'Seguridad:'` del aviso sobrevivio intacto a `v1.33.1` y a su porte por
# `#48`. Efecto medido en `e53de46` ANTES de esta reparacion: `_Seguridad_: aprobado-ish`
# se LEE como veredicto —impedira cerrar el REQ— y la salida del hook era vacia con
# `rc 0`. El aviso existe justo para que nadie descubra eso semanas despues, en un cierre.
mkreq_r "REQ-950" "no" "pendiente" "pendiente" ""
check_aviso "42/A control: clave limpia y valor fuera de vocabulario -> avisa" si \
  'NO es un veredicto' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" 'Seguridad: aprobado-ish')"
check_aviso "42/A SEC-084 la misma linea con clave '_Seguridad_' -> avisa igual" si \
  'NO es un veredicto' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" '_Seguridad_: aprobado-ish')"
check_aviso "42/A SEC-084 con clave '**Seguridad**' -> avisa igual" si \
  'NO es un veredicto' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" '**Seguridad**: aprobado-ish')"
check_aviso "42/A SEC-084 con clave entre acentos graves -> avisa igual" si \
  'NO es un veredicto' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" '`Seguridad`: aprobado-ish')"
# EL LADO `QA:` LLEVABA LA GEMELA DE LA MISMA CADENA, y sin este caso la reparacion
# quedaria acreditada en un solo campo habiendo dos disparadores identicos.
check_aviso "42/A SEC-084 el lado QA con clave decorada -> avisa igual" si \
  'NO es un veredicto' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" '**QA**: aprobadisimo')"
# DISCRIMINANTE. Sin el, un aviso que se disparara SIEMPRE pasaria los cinco de arriba:
# la forma decorada con un valor que SI esta en el vocabulario no tiene nada que avisar.
check_aviso "42/A discriminante: clave decorada con valor EN vocabulario -> NO avisa" no \
  '' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" '_Seguridad_: preventiva')"

# --- B. LA OTRA MITAD: UNA LINEA QUE PARECE EL CAMPO Y EL LECTOR NO LEE (QA-024-19) ---
# El cierre ya era fail-closed —el lector no lee esa clave, el campo queda sin declarar y
# la ausencia deniega—, pero era MUDO: ni una guarda juzgaba la firma ni nada la comentaba,
# y el estado final es indistinguible de no haber escrito nada. Lo que se repara es el
# DIAGNOSTICO; ninguna decision se mueve, y los casos 42/B-5 y 42/B-6 lo fijan.
check_aviso "42/B QA-024-19 'seguridad:' en minuscula -> avisa y CITA la linea" si \
  "'seguridad:' NO se lee como el campo" guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" 'seguridad: aprobado')"
check_aviso "42/B la clase, no la cadena: 'SEGURIDAD:' en mayusculas -> avisa" si \
  'NO se lee como el campo' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" 'SEGURIDAD: aprobado')"
check_aviso "42/B la clase, no la cadena: decoracion y caja JUNTAS -> avisa" si \
  'NO se lee como el campo' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" '_seguridad_: aprobado')"
check_aviso "42/B la clase, no la cadena: el lado QA en minuscula -> avisa" si \
  "'qa:' NO se lee como el campo" guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" 'qa: aprobado')"
# AVISAR NO ES DECIDIR: la edicion sigue permitida. `check_aviso` ya lo exige por dentro;
# va ademas como veredicto propio porque es la frontera que separa esta reparacion de
# convertir una errata de caja en un bloqueo — y la friccion termina con el guard apagado.
check "42/B QA-024-19 el aviso no deniega: la edicion sigue permitida" allow \
  guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" 'seguridad: aprobado')"
# Y EL CIERRE SIGUE FAIL-CLOSED. Es el control de que el aviso no abrio nada: un `critico`
# cuyo UNICO veredicto de seguridad esta escrito en minuscula no cierra, porque para el
# lector ese campo no existe.
mkreq_r "REQ-951" "si" "aprobado" "" ""
printf 'seguridad: aprobado\n' >> "$PROJ/requirements/REQ-951.md"
check "42/B QA-024-19 el cierre sigue fail-closed: la minuscula no gobierna" deny \
  guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-951.md" 'Estado: en-revisión' 'Estado: completado')"
# CONTROL POSITIVO DEL ANTERIOR: sin el, ese `deny` tambien lo daria una puerta que
# denegara todo cierre de este fixture.
mkreq_r "REQ-952" "si" "aprobado" "aprobado" ""
check "42/B control: el mismo REQ con la clave limpia SI cierra" allow \
  guard-completado.sh \
  "$(emite_edit_real "$PROJ/requirements/REQ-952.md" 'Estado: en-revisión' 'Estado: completado')"

# --- C. LO AJENO NO SE ATRAPA: la propiedad se deriva de las claves, no de una palabra ---
# Una guarda que denegara —o aqui, que avisara— sobre `Modulo:` o `Archivos:` produciria
# friccion constante sobre lineas legitimas, y un guard apagado protege menos que uno
# parcial. La comparacion es contra la CLAVE plegada entera, no contra una subcadena.
check_aviso "42/C 'Sensible a seguridad:' es otra clave, no un desfase -> NO avisa" no \
  '' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" 'Sensible a seguridad: si')"
check_aviso "42/C 'Notas de seguridad:' no es el campo -> NO avisa" no \
  '' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" 'Notas de seguridad: ninguna')"
check_aviso "42/C 'qa-tester:' no es el campo QA -> NO avisa" no \
  '' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" 'qa-tester: juan')"

# --- D. PRECEDENCIA Y RADIO -------------------------------------------------------
# Un `lee` manda sobre un desfase de la misma cabecera: el campo SI queda declarado, y
# avisar de que no lo esta seria avisar de algo falso.
check_aviso "42/D un 'lee' junto a un desfase: manda el lee -> NO avisa" no \
  '' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" 'seguridad: aprobado
Seguridad: preventiva')"
# Y el radio es el del lector: los campos valen SOLO en la cabecera, antes del primer `## `.
check_aviso "42/D tras el primer '## ' ya no hay cabecera -> NO avisa" no \
  '' guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-950.md" "" "" '## Historial
seguridad: aprobado')"

# --- E. LO QUE `v1.33.1` CERRO NO SE MUEVE ----------------------------------------
# La guarda del ORDEN sigue denegando la firma decorada (su matriz vive en la seccion 41;
# aqui va el par minimo que acredita que esta reparacion no la toco) y la minuscula sigue
# sin ser una firma, asi que el orden no tiene nada que juzgar: ALLOW con aviso, no DENY.
mkreq_r "REQ-953" "no" "pendiente" "pendiente" ""
check "42/E el orden sigue denegando la firma con clave decorada" deny guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-953.md" "" "" '_Seguridad_: aprobado')"
check "42/E la minuscula no es una firma: el orden no tiene que juzgarla" allow \
  guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-953.md" "" "" 'seguridad: aprobado')"
