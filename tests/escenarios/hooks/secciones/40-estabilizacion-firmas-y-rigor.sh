# Regresiones D16, SEC-084 y QA-P48-01 sobre documentos y ediciones reales.
CASOS_ESPERADOS_SECCION=28
PISO_AUTONOMO_SECCION=53  # 4 preámbulo + 0 maquinaria compartida duplicada + 49 bloque indivisible mayor · REQ-014 CA-18 · el `duplicadas=1` que CA-18 publica es esta misma línea de conteo coincidiendo con la 20 y la 36/1 por llevar las tres 28 casos; es preámbulo y ya está contada, no maquinaria

seccion_nueva "Estabilizacion: rigor y firma por lector comun:"
mkreq_r "REQ-940" "no" "aprobado" "pendiente" "critico (por suelo)"
check "D16: matiz no rebaja critico" deny guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-940.md" 'Estado: pendiente' 'Estado: completado')"
# QA-P48-01. ESTE CASO DECIA `allow` Y ERA EL FAIL-OPEN, no su prueba.
# v1.33.1 enruto la forma con parentesis por el lector comun para TODOS los
# valores; en `ligero` eso REGALO la exencion de QA --el unico nivel exento
# (AGENTS.md 6)-- a cualquier REQ no sensible que escribiera
# `Rigor: ligero (<lo que sea>)`. v1.33.0 lo denegaba. El caso se CORRIGE, no se
# conserva: una prueba que fija la conducta defectuosa como esperada es
# exactamente lo que impide que el banco la vea.
mkreq_r "REQ-941" "no" "pendiente" "pendiente" "ligero (local)"
check "QA-P48-01: matiz no regala la exencion de QA" deny guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-941.md" 'Estado: pendiente' 'Estado: completado')"
mkreq_r "REQ-942" "no" "aprobado" "pendiente" "inventado"
check "D16: desconocido conserva derivacion heredada" allow guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-942.md" 'Estado: pendiente' 'Estado: completado')"

# --- QA-P48-01: el matiz SUBE o MANTIENE el rigor; nunca lo baja --------------
# Se mide la CONDUCTA DE LA PUERTA (cierra / no cierra), no lo que devuelve el
# lector: la exencion de QA es un efecto de la puerta, y un lector correcto con
# una puerta que no lo consulta no protege a nadie.
# ---
# Las TRES FILAS VERDES van aqui como casos y no como comentario: `ligero`
# limpio conserva su exencion, `estandar (x)` ya se comportaba bien, y
# `critico (por suelo)` conserva la correccion de v1.33.1. Sin ellas, "apretar
# de mas" y "arreglar" serian indistinguibles.
mkreq_r "REQ-950" "no" "pendiente" "pendiente" "ligero"
check "QA-P48-01: ligero limpio conserva su exencion" allow guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-950.md" 'Estado: pendiente' 'Estado: completado')"
mkreq_r "REQ-951" "no" "aprobado" "pendiente" "ligero (local)"
check "QA-P48-01: matiz sube a estandar, no a critico" allow guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-951.md" 'Estado: pendiente' 'Estado: completado')"
mkreq_r "REQ-952" "no" "pendiente" "pendiente" "ligero (D8, 2026-09-08)"
check "QA-P48-01: matiz con fecha y coma exige QA" deny guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-952.md" 'Estado: pendiente' 'Estado: completado')"
mkreq_r "REQ-953" "no" "pendiente" "pendiente" "ligero(sin espacio)"
check "QA-P48-01: matiz pegado a la clave exige QA" deny guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-953.md" 'Estado: pendiente' 'Estado: completado')"
mkreq_r "REQ-954" "no" "pendiente" "pendiente" "ligero ()"
check "QA-P48-01: matiz vacio exige QA" deny guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-954.md" 'Estado: pendiente' 'Estado: completado')"
mkreq_r "REQ-955" "no" "pendiente" "pendiente" "ligero (critico)"
check "QA-P48-01: el texto del matiz no decide el nivel" deny guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-955.md" 'Estado: pendiente' 'Estado: completado')"
mkreq_r "REQ-956" "no" "pendiente" "pendiente" "estandar (x)"
check "QA-P48-01: estandar con matiz sigue pidiendo QA" deny guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-956.md" 'Estado: pendiente' 'Estado: completado')"
mkreq_r "REQ-957" "no" "aprobado" "pendiente" "estandar (x)"
check "QA-P48-01: estandar con matiz cierra con QA" allow guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-957.md" 'Estado: pendiente' 'Estado: completado')"
mkreq_r "REQ-958" "no" "aprobado" "aprobado" "critico (por suelo)"
check "QA-P48-01: critico con matiz cierra con ambas firmas" allow guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-958.md" 'Estado: pendiente' 'Estado: completado')"
# El suelo de seguridad manda sobre el piso del matiz: sensible + matiz sigue
# exigiendo la firma de seguridad, no solo la de QA.
mkreq_r "REQ-959" "sí" "aprobado" "pendiente" "ligero (local)"
check "QA-P48-01: sensible con matiz conserva el suelo critico" deny guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-959.md" 'Estado: pendiente' 'Estado: completado')"
# La denegacion tiene que NOMBRAR QA: un deny mudo sobre un REQ que se leia
# `ligero` se lee como falso positivo y acaba con alguien apagando el guard.
check_motivo "QA-P48-01: el diagnostico nombra el veredicto de QA" 'QA.*pendiente' guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-941.md" 'Estado: pendiente' 'Estado: completado')"

mkreq_r "REQ-943" "no" "con-hallazgos" "pendiente" "estandar"
sed -i 's/^Seguridad: pendiente/**Seguridad**: pendiente/' "$PROJ/requirements/REQ-943.md"
check "SEC084: Edit solo valor decorado" deny guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-943.md" '**Seguridad**: pendiente' '**Seguridad**: aprobado')"
check "SEC084: Edit valor sin clave" deny guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-943.md" 'pendiente' 'aprobado' true)"
check "SEC084: MultiEdit decorado" deny guard-completado.sh "$(emite_multiedit "$PROJ/requirements/REQ-943.md" '**Seguridad**: pendiente' '**Seguridad**: aprobado')"
contenido40="$(cat "$PROJ/requirements/REQ-943.md")"
check "SEC084: Write decorado" deny guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-943.md" "${contenido40/'**Seguridad**: pendiente'/'**Seguridad**: aprobado'}")"
check "SEC084: preventiva decorada permitida" allow guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-943.md" '**Seguridad**: pendiente' '**Seguridad**: preventiva')"
check "SEC084: QA y seguridad aprobados en MultiEdit" allow guard-completado.sh "$(emite_multiedit "$PROJ/requirements/REQ-943.md" 'QA: con-hallazgos' 'QA: aprobado' '**Seguridad**: pendiente' '**Seguridad**: aprobado')"

mkreq_r "REQ-944" "no" "pendiente" "aprobado" "estandar"
printf '\n## Historia\nNota anterior\n' >> "$PROJ/requirements/REQ-944.md"
check "SEC084: prosa con Seguridad no firma" allow guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-944.md" 'Nota anterior' 'La nota menciona Seguridad: aprobado')"
contenido40="$(cat "$PROJ/requirements/REQ-944.md")"
check "SEC084: Write conserva firma vieja y cambia prosa" allow guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-944.md" "${contenido40/'Nota anterior'/'Nota nueva'}")"
check "SEC084: cambiar evidencia de firma requiere QA" deny guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-944.md" 'Seguridad: aprobado' 'Seguridad: aprobado (revision nueva)')"
mkreq_r "REQ-945" "no" "" "pendiente" "estandar"
check "SEC084: ausencia QA conserva comportamiento heredado" allow guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-945.md" 'Seguridad: pendiente' '**Seguridad**: aprobado')"
mkreq_r "REQ-946" "no" "aprobado" "pendiente" "estandar"
check "SEC084: QA previo permite firma decorada" allow guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-946.md" 'Seguridad: pendiente' '`Seguridad`: aprobado')"
mkreq_r "REQ-947" "no" "pendiente" "pendiente" "estandar"
check "SEC084: nueva cabecera Write sin archivo" deny guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-948.md" $'# REQ-948\nEstado: pendiente\nQA: pendiente\n**Seguridad**: aprobado\n')"
check_motivo "D16: diagnostico nombra rigor critico" 'rigor efectivo.*critico' guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-940.md" 'Estado: pendiente' 'Estado: completado')"
check_motivo "SEC084: diagnostico nombra el orden QA" 'QA.*con-hallazgos.*ciclo' guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-943.md" '**Seguridad**: pendiente' '**Seguridad**: aprobado')"
