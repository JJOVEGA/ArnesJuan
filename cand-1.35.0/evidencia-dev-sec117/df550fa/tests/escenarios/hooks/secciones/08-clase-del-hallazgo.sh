# Sección 08 del banco — 08-clase-del-hallazgo
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=67
PISO_AUTONOMO_SECCION=23  # 8 preámbulo + 0 maquinaria compartida duplicada + 15 bloque indivisible mayor · REQ-014 CA-18

  seccion_nueva "Clase del hallazgo:"
mkreq "$PROJ/requirements/REQ-020.md" "no" "aprobado" "n/a" "SEC-1 (instrumento)"
check "hallazgo de instrumento -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-020.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-021.md" "no" "aprobado" "n/a" "SEC-2 (usuario/dinero)"
check "hallazgo de usuario/dinero -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-021.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-022.md" "no" "aprobado" "n/a" "SEC-3 (contrato)"
check "hallazgo de contrato -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-022.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-023.md" "no" "aprobado" "n/a" "SEC-4"
check "hallazgo SIN clase -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-023.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-024.md" "no" "aprobado" "n/a" "SEC-5 (instrumento), SEC-6 (usuario/dinero)"
check "mezcla: basta uno bloqueante -> deny" deny guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-024.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-025.md" "no" "aprobado" "n/a" "(ninguno)"
check "sin hallazgos abiertos -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-025.md" "" "" 'Estado: completado')"
# Compatibilidad: un REQ anterior a este campo no puede quedar bloqueado por el.
mkreq "$PROJ/requirements/REQ-026.md" "no" "aprobado" "n/a"
check "REQ antiguo sin el campo -> allow" allow guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-026.md" "" "" 'Estado: completado')"

# --- REQ-031 (ADR-013): gramatica CERRADA de `Hallazgos abiertos:` ---------------
# Medido sobre 1.34.0 (evaluacion-2026-09-27): con `·` o `;` entre dos hallazgos la lista
# entera era UN elemento, la clase se tomaba del PRIMER parentesis y el resto no se leia,
# asi que `SEC-A (instrumento) · SEC-B (usuario/dinero)` CERRABA. Cada caso comprueba la
# decision Y el efecto sobre el archivo (`check_efecto`: deny -> sigue `en-revisión`;
# allow -> aplicada la edicion queda `completado`). REQ «listo para cerrar»: sensible,
# QA y Seguridad aprobados, cola vacia, gates en verde; el unico motivo posible es el campo.
# r31 <n> <estado> [valor] — sin 3.er argumento el REQ NO lleva la linea (compatibilidad).
r31() {
  { printf '# REQ-%s\nEstado: %s\nPrioridad: alta\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: aprobado\nRigor: critico\n' "$1" "$2"
    [ "$#" -lt 3 ] || printf 'Hallazgos abiertos: %s\n' "$3"
    printf '\n## Historia\nx\n'; } > "$PROJ/requirements/REQ-$1.md"
}
R31="$PROJ/requirements"
NOI='no se puede interpretar'
# CA-A02: todos los elementos cuentan, y el orden no.
r31 800 en-revisión 'SEC-A (instrumento), SEC-M (contrato), SEC-Z (instrumento)'
check_efecto "REQ-031 CA-A02 bloqueante EN MEDIO -> deny por su clase" deny "$R31/REQ-800.md" \
  "$(emite_edit_real "$R31/REQ-800.md" 'en-revisión' 'completado')" en-revisión "'sec-m' es de clase 'contrato'"
r31 801 en-revisión 'SEC-Z (instrumento), SEC-A (instrumento), SEC-M (contrato)'
check_efecto "REQ-031 CA-A02 permutacion: bloqueante al final -> deny por su clase" deny "$R31/REQ-801.md" \
  "$(emite_edit_real "$R31/REQ-801.md" 'en-revisión' 'completado')" en-revisión "'sec-m' es de clase 'contrato'"
# CA-A03: coma, `;` y `·`, con el bloqueante primero y despues.
r31 802 en-revisión 'SEC-A (instrumento), SEC-B (usuario/dinero)'
check_efecto "REQ-031 CA-A03 coma, bloqueante detras -> deny por su clase" deny "$R31/REQ-802.md" \
  "$(emite_edit_real "$R31/REQ-802.md" 'en-revisión' 'completado')" en-revisión "'sec-b' es de clase 'usuario/dinero'"
r31 803 en-revisión 'SEC-B (usuario/dinero), SEC-A (instrumento)'
check_efecto "REQ-031 CA-A03 coma, bloqueante delante -> deny por su clase" deny "$R31/REQ-803.md" \
  "$(emite_edit_real "$R31/REQ-803.md" 'en-revisión' 'completado')" en-revisión "'sec-b' es de clase 'usuario/dinero'"
r31 804 en-revisión 'SEC-A (instrumento); SEC-B (contrato)'
check_efecto "REQ-031 CA-A03 ';' con el bloqueante detras (era allow) -> deny no interpretable" deny "$R31/REQ-804.md" \
  "$(emite_edit_real "$R31/REQ-804.md" 'en-revisión' 'completado')" en-revisión "$NOI.*';sec-b\(contrato\)'"
r31 805 en-revisión 'SEC-B (contrato); SEC-A (instrumento)'
check_efecto "REQ-031 CA-A03 ';' con el bloqueante delante -> deny no interpretable" deny "$R31/REQ-805.md" \
  "$(emite_edit_real "$R31/REQ-805.md" 'en-revisión' 'completado')" en-revisión "$NOI.*';sec-a\(instrumento\)'"
r31 806 en-revisión 'SEC-A (instrumento) · SEC-B (usuario/dinero)'
check_efecto "REQ-031 CA-A03 '·' con el bloqueante detras (era allow) -> deny no interpretable" deny "$R31/REQ-806.md" \
  "$(emite_edit_real "$R31/REQ-806.md" 'en-revisión' 'completado')" en-revisión "$NOI.*'·sec-b\(usuario/dinero\)'"
r31 807 en-revisión 'SEC-B (usuario/dinero) · SEC-A (instrumento)'
check_efecto "REQ-031 CA-A03 '·' con el bloqueante delante -> deny no interpretable" deny "$R31/REQ-807.md" \
  "$(emite_edit_real "$R31/REQ-807.md" 'en-revisión' 'completado')" en-revisión "$NOI.*'·sec-a\(instrumento\)'"
r31 808 en-revisión 'SEC-A (instrumento); SEC-B (instrumento)'
check_efecto "REQ-031 CA-A03 ';' aunque todo sea instrumento -> deny no interpretable" deny "$R31/REQ-808.md" \
  "$(emite_edit_real "$R31/REQ-808.md" 'en-revisión' 'completado')" en-revisión "$NOI.*';sec-b"
r31 809 en-revisión 'SEC-A (instrumento) · SEC-B (instrumento)'
check_efecto "REQ-031 CA-A03 '·' aunque todo sea instrumento -> deny no interpretable" deny "$R31/REQ-809.md" \
  "$(emite_edit_real "$R31/REQ-809.md" 'en-revisión' 'completado')" en-revisión "$NOI.*'·sec-b"
# CA-A04: las formas legitimas se conservan (controles).
r31 810 en-revisión 'SEC-A (instrumento)'
check_efecto "REQ-031 CA-A04 control: un instrumento -> allow" allow "$R31/REQ-810.md" \
  "$(emite_edit_real "$R31/REQ-810.md" 'en-revisión' 'completado')" completado
r31 811 en-revisión 'SEC-A (instrumento), SEC-B (instrumento), SEC-C (instrumento)'
check_efecto "REQ-031 CA-A04 control: tres instrumento separados por coma -> allow" allow "$R31/REQ-811.md" \
  "$(emite_edit_real "$R31/REQ-811.md" 'en-revisión' 'completado')" completado
r31 812 en-revisión '(ninguno)'
check_efecto "REQ-031 CA-A04 control: '(ninguno)' -> allow" allow "$R31/REQ-812.md" \
  "$(emite_edit_real "$R31/REQ-812.md" 'en-revisión' 'completado')" completado
r31 813 en-revisión ''
check_efecto "REQ-031 CA-A04 control: campo vacio -> allow" allow "$R31/REQ-813.md" \
  "$(emite_edit_real "$R31/REQ-813.md" 'en-revisión' 'completado')" completado
r31 814 en-revisión
check_efecto "REQ-031 CA-A04 control: REQ sin la linea -> allow" allow "$R31/REQ-814.md" \
  "$(emite_edit_real "$R31/REQ-814.md" 'en-revisión' 'completado')" completado
r31 815 en-revisión 'QA-006 (instrumento, dueño REQ-007)'
check_efecto "REQ-031 CA-A04 control: evidencia tras la clase (REQ-007 CA-40) -> allow" allow "$R31/REQ-815.md" \
  "$(emite_edit_real "$R31/REQ-815.md" 'en-revisión' 'completado')" completado
r31 816 en-revisión 'QA-006 (instrumento, REQ-007)'
check_efecto "REQ-031 CA-A04 caso minimo: la forma equivalente, evidencia DENTRO del parentesis -> allow" allow "$R31/REQ-816.md" \
  "$(emite_edit_real "$R31/REQ-816.md" 'en-revisión' 'completado')" completado
r31 817 en-revisión 'SEC-9 (instrumento, dueño desarrollador (vence 1.35.0), forzador: x)'
check_efecto "REQ-031 CA-A04 caso minimo: comas y parentesis en la evidencia son UN hallazgo -> allow" allow "$R31/REQ-817.md" \
  "$(emite_edit_real "$R31/REQ-817.md" 'en-revisión' 'completado')" completado
r31 818 en-revisión 'SEC-A (instrumento, visto en CA-03 (c), dueño X; vence 2026-10-01 · R-2), SEC-B (instrumento)'
check_efecto "REQ-031 CA-A04 control: comas, ';', '·' y parentesis DENTRO de la evidencia no separan -> allow" allow "$R31/REQ-818.md" \
  "$(emite_edit_real "$R31/REQ-818.md" 'en-revisión' 'completado')" completado
r31 819 en-revisión 'SEC-A (instrumento, relacionado con SEC-B (contrato))'
check_efecto "REQ-031 CA-A04 frontera: la evidencia no declara -> allow" allow "$R31/REQ-819.md" \
  "$(emite_edit_real "$R31/REQ-819.md" 'en-revisión' 'completado')" completado
r31 820 en-revisión 'SEC-9 (usuario/dinero, dueño desarrollador, vence 2026-10-01)'
check_efecto "REQ-031 CA-A04 la evidencia no cambia la clase -> deny por la clase" deny "$R31/REQ-820.md" \
  "$(emite_edit_real "$R31/REQ-820.md" 'en-revisión' 'completado')" en-revisión "clase 'usuario/dinero'"
r31 821 en-revisión 'QA-006 (Instrumento)'
check_efecto "REQ-031 CA-A04 control: '(Instrumento)' -> allow" allow "$R31/REQ-821.md" \
  "$(emite_edit_real "$R31/REQ-821.md" 'en-revisión' 'completado')" completado
r31 822 en-revisión 'QA-006 ( instrumento )'
check_efecto "REQ-031 CA-A04 control: '( instrumento )' -> allow" allow "$R31/REQ-822.md" \
  "$(emite_edit_real "$R31/REQ-822.md" 'en-revisión' 'completado')" completado
# Dos cabeceras reales, literales de la base a7a60c2 (requirements/REQ-017.md:9 y REQ-007.md:10).
r31 823 en-revisión 'QA-017-07 (instrumento), QA-017-11 (instrumento), QA-017-13 (instrumento), QA-017-15 (instrumento), SEC-047 (instrumento, preexistente desde v1.30.3 o antes, dueño analista-requerimientos, R-012), SEC-048 (instrumento, dueño propietario para el ruleset de tags y desarrollador para el workflow, R-012), SEC-049 (instrumento, texto de CA-10 incompleto, dueño analista-requerimientos, R-012)'
check_efecto "REQ-031 CA-A04 control: la cabecera real de REQ-017 (siete instrumento) -> allow" allow "$R31/REQ-823.md" \
  "$(emite_edit_real "$R31/REQ-823.md" 'en-revisión' 'completado')" completado
r31 824 en-revisión 'QA-114 (contrato, dueño analista-requerimientos; CA-59 exige a `git status` un conteo que REQ-005 CA-26/CA-27 declara imposible, y su margen de reloj no discrimina), QA-116 (contrato, dueño desarrollador, ventana 1.33.0; heredado de v1.30.3 y reproducido por el auditor en R-003 en las DOS versiones: con `docs/ESTADO.md` en modo 444 y la carpeta escribible el bloque se escribe igual y el modo pasa a 644 en silencio, sin perder contenido humano. La verdad ya esta escrita en CA-64.2 y el arreglo —conservar el modo— exigido en CA-64.2-bis; no cierra hasta que el codigo lo implemente), QA-117 (contrato, dueño desarrollador, ventana 1.33.0; heredado de v1.30.3 y reproducido por el auditor en R-003 en las DOS versiones: el texto humano posterior a los marcadores sube por encima del bloque en cada parada —sin perder un byte, 4 de 4 lineas, e idempotente—. La verdad ya esta escrita en CA-64.1 y el arreglo del ORDEN exigido en CA-64.1-bis; no cierra hasta que el codigo lo implemente)'
check_efecto "REQ-031 CA-A04 la cabecera real de REQ-007 (';' y '—' dentro de la evidencia) -> deny por la clase, no por ilegible" deny "$R31/REQ-824.md" \
  "$(emite_edit_real "$R31/REQ-824.md" 'en-revisión' 'completado')" en-revisión "'qa-114' es de clase 'contrato'"
# CA-A05 + CA-A06: lo mal formado que antes quedaba ignorado deniega, y el motivo lo nombra.
r31 825 en-revisión 'SEC-A (instrumento) (usuario/dinero)'
check_efecto "REQ-031 CA-A05 dos parentesis en un elemento -> deny" deny "$R31/REQ-825.md" \
  "$(emite_edit_real "$R31/REQ-825.md" 'en-revisión' 'completado')" en-revisión "$NOI.*'\(usuario/dinero\)'.*dos parentesis"
r31 826 en-revisión 'SEC-A (instrumento'
check_efecto "REQ-031 CA-A05 parentesis sin cerrar -> deny" deny "$R31/REQ-826.md" \
  "$(emite_edit_real "$R31/REQ-826.md" 'en-revisión' 'completado')" en-revisión "$NOI.*'sec-a\(instrumento'.*no se cierra"
r31 827 en-revisión 'SEC-A (instrumento))'
check_efecto "REQ-031 CA-A05 ')' sobrante (antes se ignoraba) -> deny" deny "$R31/REQ-827.md" \
  "$(emite_edit_real "$R31/REQ-827.md" 'en-revisión' 'completado')" en-revisión "$NOI.*sobra un '\)'"
r31 828 en-revisión 'SEC-A (instrumento),'
check_efecto "REQ-031 CA-A05 elemento vacio al final (antes se saltaba) -> deny" deny "$R31/REQ-828.md" \
  "$(emite_edit_real "$R31/REQ-828.md" 'en-revisión' 'completado')" en-revisión "$NOI.*elemento vacio"
r31 829 en-revisión 'SEC-A (instrumento),, SEC-B (instrumento)'
check_efecto "REQ-031 CA-A05 elemento vacio en medio -> deny" deny "$R31/REQ-829.md" \
  "$(emite_edit_real "$R31/REQ-829.md" 'en-revisión' 'completado')" en-revisión "$NOI.*elemento vacio"
r31 830 en-revisión '(instrumento)'
check_efecto "REQ-031 CA-A05 elemento sin identificador -> deny" deny "$R31/REQ-830.md" \
  "$(emite_edit_real "$R31/REQ-830.md" 'en-revisión' 'completado')" en-revisión "$NOI.*'\(instrumento\)'.*no empieza por un identificador"
r31 831 en-revisión 'SEC-A y SEC-B (instrumento)'
check_efecto "REQ-031 CA-A05 identificador con blancos internos -> deny" deny "$R31/REQ-831.md" \
  "$(emite_edit_real "$R31/REQ-831.md" 'en-revisión' 'completado')" en-revisión "$NOI.*'sec-a y sec-b' lleva blancos dentro"
r31 832 en-revisión '`SEC-A` (instrumento)'
check_efecto "REQ-031 CA-A05 identificador fuera del alfabeto (marcado por elemento) -> deny" deny "$R31/REQ-832.md" \
  "$(emite_edit_real "$R31/REQ-832.md" 'en-revisión' 'completado')" en-revisión "$NOI.*'\`sec-a\`\(instrumento\)'.*fuera de letras ASCII"
r31 846 en-revisión 'SÉC-A (instrumento)'
check_efecto "REQ-031 CA-A05 identificador con una letra fuera de ASCII (la normalizacion pliega la tilde) -> deny" deny "$R31/REQ-846.md" \
  "$(emite_edit_real "$R31/REQ-846.md" 'en-revisión' 'completado')" en-revisión "$NOI.*fuera de ASCII"
r31 833 en-revisión '(ninguno), SEC-B (contrato)'
check_efecto "REQ-031 CA-A05 ausencia mezclada con una lista -> deny" deny "$R31/REQ-833.md" \
  "$(emite_edit_real "$R31/REQ-833.md" 'en-revisión' 'completado')" en-revisión "$NOI.*'\(ninguno\)'"
r31 834 en-revisión 'QA-006 (instrumento) — REQ-007'
check_efecto "REQ-031 CA-A05 caso minimo: texto detras del parentesis (forma retirada) -> deny y dice como conservar la evidencia" deny "$R31/REQ-834.md" \
  "$(emite_edit_real "$R31/REQ-834.md" 'en-revisión' 'completado')" en-revisión \
  "$NOI.*'—req-007'.*texto detras del parentesis.*Conserva la evidencia DENTRO del parentesis del hallazgo, tras la clase y una coma.*'QA-006 \(instrumento, REQ-007\)'.*requirements/README.md, seccion 'Clases de hallazgo'"
r31 835 en-revisión 'SEC-A (instrumento) · SEC-B'
check_efecto "REQ-031 CA-A05 caso minimo: '·' y un segundo identificador sin clase -> deny que nombra sec-b" deny "$R31/REQ-835.md" \
  "$(emite_edit_real "$R31/REQ-835.md" 'en-revisión' 'completado')" en-revisión "$NOI.*'·sec-b'.*cada uno lleva su propio parentesis con su clase"
# CA-A07: la interpretacion no depende de la herramienta (Write y MultiEdit).
MAL31='SEC-A (instrumento) · SEC-B (usuario/dinero)'; BIEN31='SEC-A (instrumento), SEC-B (instrumento)'
r31 836 en-revisión "$MAL31"; T836="$(<"$R31/REQ-836.md")"
check_efecto "REQ-031 CA-A07 Write: '·' con el bloqueante detras -> deny" deny "$R31/REQ-836.md" \
  "$(emite_write "$R31/REQ-836.md" "${T836/en-revisión/completado}")" en-revisión "$NOI.*'·sec-b"
r31 837 en-revisión "$BIEN31"; T837="$(<"$R31/REQ-837.md")"
check_efecto "REQ-031 CA-A07 Write: control, dos instrumento -> allow" allow "$R31/REQ-837.md" \
  "$(emite_write "$R31/REQ-837.md" "${T837/en-revisión/completado}")" completado
r31 838 en-revisión "$MAL31"
check_efecto "REQ-031 CA-A07 MultiEdit: '·' con el bloqueante detras -> deny" deny "$R31/REQ-838.md" \
  "$(emite_multiedit "$R31/REQ-838.md" 'Prioridad: alta' 'Prioridad: media' 'en-revisión' 'completado')" en-revisión "$NOI.*'·sec-b"
r31 839 en-revisión "$BIEN31"
check_efecto "REQ-031 CA-A07 MultiEdit: control, dos instrumento -> allow" allow "$R31/REQ-839.md" \
  "$(emite_multiedit "$R31/REQ-839.md" 'Prioridad: alta' 'Prioridad: media' 'en-revisión' 'completado')" completado
# CA-A08: reabrir no lo impide esta regla, y fuera de la transicion no se juzga.
r31 840 completado "$MAL31"
check_efecto "REQ-031 CA-A08 reabrir completado -> en-progreso con la lista no interpretable -> allow" allow "$R31/REQ-840.md" \
  "$(emite_edit_real "$R31/REQ-840.md" 'Estado: completado' 'Estado: en-progreso')" en-progreso
r31 841 completado "$MAL31"
check_efecto "REQ-031 CA-A08 reabrir completado -> en-revisión con la lista no interpretable -> allow" allow "$R31/REQ-841.md" \
  "$(emite_edit_real "$R31/REQ-841.md" 'Estado: completado' 'Estado: en-revisión')" en-revisión
r31 842 completado 'QA-006 (instrumento) — REQ-007'
check_efecto "REQ-031 CA-A08 caso minimo: reabrir con '(instrumento) — REQ-007' -> allow" allow "$R31/REQ-842.md" \
  "$(emite_edit_real "$R31/REQ-842.md" 'Estado: completado' 'Estado: en-progreso')" en-progreso
r31 843 completado 'SEC-A (instrumento) · SEC-B'
check_efecto "REQ-031 CA-A08 caso minimo: reabrir con '(instrumento) · SEC-B' -> allow" allow "$R31/REQ-843.md" \
  "$(emite_edit_real "$R31/REQ-843.md" 'Estado: completado' 'Estado: en-progreso')" en-progreso
r31 844 en-progreso "$MAL31"
check_efecto "REQ-031 CA-A08 en-progreso -> en-revisión con la lista no interpretable -> allow" allow "$R31/REQ-844.md" \
  "$(emite_edit_real "$R31/REQ-844.md" 'Estado: en-progreso' 'Estado: en-revisión')" en-revisión
r31 845 en-progreso "$MAL31"
check_efecto "REQ-031 CA-A08 editar otra linea de un REQ en-progreso con la lista no interpretable -> allow" allow "$R31/REQ-845.md" \
  "$(emite_edit_real "$R31/REQ-845.md" 'Prioridad: alta' 'Prioridad: media')" en-progreso
# --- REQ-031 vuelta 2 · CA-A12 (SEC-112): la clave REPETIDA deniega ---------------
# Medido en R-044 (base y vuelta 1): con dos lineas `Hallazgos abiertos:` ganaba la ULTIMA, y un
# `contrato` escrito en la de arriba no se leia. La puerta no elige ni fusiona: deniega.
# r31d <n> <estado> <linea 1> <linea 2> [linea bajo el primer ##] — cabecera con dos lineas del campo.
r31d() {
  { printf '# REQ-%s\nEstado: %s\nPrioridad: alta\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: aprobado\nRigor: critico\n' "$1" "$2"
    printf '%s\n' "$3"; [ -z "$4" ] || printf '%s\n' "$4"
    printf '\n## Historia\nx\n'; [ -z "${5:-}" ] || printf '%s\n' "$5"; } > "$PROJ/requirements/REQ-$1.md"
}
REP31="declara 'Hallazgos abiertos:' 2 veces \(linea [0-9]+: .*; linea [0-9]+: .*\).*no elige una.*Deja UNA sola linea"
r31d 850 en-revisión 'Hallazgos abiertos: SEC-1 (contrato)' 'Hallazgos abiertos: (ninguno)'
check_efecto "REQ-031 CA-A12 Edit: 'contrato' arriba y '(ninguno)' abajo (era allow) -> deny por clave repetida" deny "$R31/REQ-850.md" \
  "$(emite_edit_real "$R31/REQ-850.md" 'en-revisión' 'completado')" en-revisión "$REP31"
r31d 851 en-revisión 'Hallazgos abiertos: SEC-1 (contrato)' 'Hallazgos abiertos: (ninguno)'; T851="$(<"$R31/REQ-851.md")"
check_efecto "REQ-031 CA-A12 Write: 'contrato' arriba y '(ninguno)' abajo (era allow) -> deny por clave repetida" deny "$R31/REQ-851.md" \
  "$(emite_write "$R31/REQ-851.md" "${T851/en-revisión/completado}")" en-revisión "$REP31"
r31d 852 en-revisión 'Hallazgos abiertos: SEC-1 (contrato)' '**Hallazgos abiertos:** (ninguno)'
check_efecto "REQ-031 CA-A12 la segunda linea DECORADA tambien cuenta (era allow) -> deny por clave repetida" deny "$R31/REQ-852.md" \
  "$(emite_edit_real "$R31/REQ-852.md" 'en-revisión' 'completado')" en-revisión "$REP31"
r31d 853 en-revisión 'Hallazgos abiertos: QA-2 (instrumento)' 'Hallazgos abiertos: SEC-1 (contrato)'
check_efecto "REQ-031 CA-A12 'instrumento' arriba y 'contrato' abajo -> deny por clave repetida, no por la clase" deny "$R31/REQ-853.md" \
  "$(emite_edit_real "$R31/REQ-853.md" 'en-revisión' 'completado')" en-revisión "$REP31"
r31d 854 en-revisión 'Hallazgos abiertos: SEC-1 (contrato)' ''
check_efecto "REQ-031 CA-A12 control: una sola linea -> deny por su clase, como siempre" deny "$R31/REQ-854.md" \
  "$(emite_edit_real "$R31/REQ-854.md" 'en-revisión' 'completado')" en-revisión "'sec-1' es de clase 'contrato'"
r31d 855 en-revisión 'Hallazgos abiertos: SEC-1 (instrumento)' '' 'Hallazgos abiertos: SEC-9 (contrato)'
check_efecto "REQ-031 CA-A12 control: la segunda linea bajo el primer '## ' no cuenta -> allow" allow "$R31/REQ-855.md" \
  "$(emite_edit_real "$R31/REQ-855.md" 'en-revisión' 'completado')" completado
r31d 856 completado 'Hallazgos abiertos: SEC-1 (contrato)' 'Hallazgos abiertos: (ninguno)'
check_efecto "REQ-031 CA-A12 reabrir con la clave repetida -> allow" allow "$R31/REQ-856.md" \
  "$(emite_edit_real "$R31/REQ-856.md" 'Estado: completado' 'Estado: en-progreso')" en-progreso
# --- REQ-031 vuelta 2 · CA-A13 (SEC-113): techo de 16 384 BYTES ---------------------
# v31 <bytes> [primer elemento] -> V31: un valor cuyo texto tras los dos puntos (con el blanco que
# los sigue) mide EXACTAMENTE <bytes> bytes. Lleva `dueño`: en bytes mide mas que en caracteres,
# asi que un techo contado en caracteres dejaria pasar el caso de 16 385.
v31() {
  local LC_ALL=C objetivo=$(( $1 - 1 )) v="${2:+$2, }" e i=0
  while :; do
    e="SEC-$i (instrumento, dueño x; vence 1.35.0)"
    [ $(( ${#v} + ${#e} + 2 + 40 )) -lt "$objetivo" ] || break
    v+="$e, "; i=$((i+1))
  done
  v+='SEC-Z (instrumento, '
  while [ $(( ${#v} + 1 )) -lt "$objetivo" ]; do v+=x; done
  V31="$v)"
}
# TOPE31: tope OPERATIVO de las tres comprobaciones (CA-A15.4): la mitad de los 60 s del cliente, para
# que un hook que no decide se note sin esperarlo entero. No es un reloj contratado.
TOPE31=30
v31 16384; r31 857 en-revisión "$V31"
check_efecto "REQ-031 CA-A13 exactamente 16 384 bytes, todo instrumento -> allow" allow "$R31/REQ-857.md" \
  "$(emite_edit_real "$R31/REQ-857.md" 'en-revisión' 'completado')" completado '' "$TOPE31"
v31 16384 'SEC-X (contrato)'; r31 858 en-revisión "$V31"
check_efecto "REQ-031 CA-A13 exactamente 16 384 bytes con un contrato -> deny por la clase" deny "$R31/REQ-858.md" \
  "$(emite_edit_real "$R31/REQ-858.md" 'en-revisión' 'completado')" en-revisión "'sec-x' es de clase 'contrato'" "$TOPE31"
v31 16385; r31 859 en-revisión "$V31"
check_efecto "REQ-031 CA-A13 16 385 bytes, todo instrumento -> deny por tamaño" deny "$R31/REQ-859.md" \
  "$(emite_edit_real "$R31/REQ-859.md" 'en-revisión' 'completado')" en-revisión "mide 16385 bytes.*techo es 16384 bytes.*no puede medir no deja pasar" "$TOPE31"
v31 60006 'SEC-X (contrato)'; r31 860 en-revisión "$V31"
check_efecto "REQ-031 CA-A13 60 006 bytes con un contrato delante (el caso de R-044) -> deny por tamaño" deny "$R31/REQ-860.md" \
  "$(emite_edit_real "$R31/REQ-860.md" 'en-revisión' 'completado')" en-revisión "mide 60006 bytes.*techo es 16384 bytes" "$TOPE31"
# Vuelta 3 · CA-A15 (SEC-113, remedio B): el techo se mide ANTES de normalizar, en el lector. El caso de
# 255 371 bytes es el de R-044-A (67,0 s sin decision en 373563f): contra el lector anterior, el tope
# operativo de este caso lo corta y sale FAIL (a) en ${TOPE31}s, sin esperar los 67 s.
v31 255371 'SEC-X (contrato)'; r31 861 en-revisión "$V31"
check_efecto "REQ-031 CA-A15 255 371 bytes con un contrato delante (R-044-A: 67 s sin decision) -> deny por tamaño a tiempo" deny "$R31/REQ-861.md" \
  "$(emite_edit_real "$R31/REQ-861.md" 'en-revisión' 'completado')" en-revisión "mide 255371 bytes.*techo es 16384 bytes" "$TOPE31"
r31 862 completado "$V31"
check_efecto "REQ-031 CA-A15 reabrir con 255 371 bytes (sobre el techo) -> allow" allow "$R31/REQ-862.md" \
  "$(emite_edit_real "$R31/REQ-862.md" 'Estado: completado' 'Estado: en-progreso')" en-progreso '' "$TOPE31"

# --- Cierre de un REQ por Bash: se DERIVA a Edit/Write -------------------------
# Era la limitacion conocida de la version anterior: `guard-completado` no miraba
# Bash, asi que un `sed -i` cerraba un REQ sin que ninguna puerta lo evaluara.
