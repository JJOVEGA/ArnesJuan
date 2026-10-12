# REQ-007 — historia: Correspondencia con el encargo, los dieciséis versionados de 1.36.0

> **Movido desde `requirements/REQ-007.md` el 2026-10-12** por la undécima autorización del propietario
> (ficha **F-136-17**), cabeza de origen **`cecf9b6`**, líneas **4419–4789** (371 líneas, 60 229 bytes medidos).
> **Copia verbatim: no se resumió, no se reordenó y no se corrigió nada.**
> Índice: `docs/historia/REQ-007/README.md`. Contrato: `docs/arnes/v1.37.0-f136-17-fase1.md`.
> Comprobación de que no se perdió ninguna línea: ese contrato, §5, y el índice.

### Correspondencia con el encargo (apertura de 1.36.0, 2026-10-03)

Pedido: «Encargo 2 — Apertura de v1.36.0», literal en la transcripción de la coordinadora (fuente en «Origen del
versionado del 2026-10-03 (apertura de 1.36.0)», arriba). **Autorización de las filas:** el propio pedido, que es
la decisión de alcance del propietario; **no está en ninguna sede del repositorio**, y por eso esta tabla no la cita
por ruta: queda como pregunta para la coordinadora registrarla en `PENDING_APPROVAL.md` § Resueltas antes de
despachar la implementación (`AGENTS.md` §6, regla 1). Las obligaciones de implementación, de QA, de seguridad y de
publicación no son contrato de este REQ y no dan fila.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «CA-54 / QA-023-10: el análisis de Bash en el máximo declarado (131072 bytes) termina en menos de 5 s en Linux/WSL2» | CA-54, nota del 2026-10-03: «Propiedad» y «Medida», 1 | cubierta, con dos precisiones del analista: el umbral se aplica a cada una de las 35 corridas de S1 y S2 en 131 072, no sólo a las 15 de S1; y es un absoluto que la forma (d) no admitiría si no lo fijara el propietario, declarado como tal | pedido del 2026-10-03, prioridad 1 (sin sede en el repositorio: ver el preámbulo) |
| «sin cambiar ningún veredicto del banco (2050 casos)» | CA-54, nota, «Medida», 2 y 4; CA-69, punto 2 (inventario caso a caso con el banco de v1.35.0 sin cambiar, contra los dos árboles de hooks) | cubierta, con una precisión: un SKIP o un INCONCLUSO deja el caso **no acreditado** (decisión 7 de 1.35.0) | ídem |
| «y sin subir el umbral ni reducir la entrada» | CA-54, nota, «Prohibido por nombre» (a) a (c) y «Medida», 2 y 3; la regla «el máximo baja hasta que cumpla» no se aplica en 1.36.0 | cubierta | ídem |
| «Es optimización de rendimiento; se mide con el banco y las sondas existentes.» | CA-54, nota, «Instrumento» (S1 y S2, con sólo las rutas cambiadas) y «Prohibido», (d); CA-69, punto 2 | cubierta, con una precisión: las sondas de CA-54 no están en `tests/util/`, sino en el árbol de evidencia, y cargan una biblioteca de un scratchpad que ya no existe; el coste en procesos que pide la forma (d) queda en **P-136-A** | ídem; → Preguntas abiertas, P-136-A |
| «SEC-120 (vence 2026-10-29): fallo de jq al leer o trocear la entrada → deny en las herramientas que las puertas juzgan.» | CA-47, punto 20 | cubierta, con una precisión: «las herramientas que las puertas juzgan» se lee del `matcher` de `hooks/hooks.json`, sitio único; y en el troceo deniega la puerta que necesita lo que no pudo trocear (como CA-51) | pedido del 2026-10-03, prioridad 2 |
| «Comprobación de código de salida, sin procesos nuevos.» | CA-47, punto 20, «Coste» (0 procesos añadidos, sonda de procesos) | cubierta; la técnica se comprueba leyendo el código, la propiedad con los casos | ídem |
| «SEC-115 y SEC-118: fail-closed cuando el hook agota tiempo o el motivo excede el tope: emitir decisión siempre» | CA-67 (motivo) y CA-68 (tiempo); ADR-017 | cubierta, con el límite que la propiedad no puede superar, dicho en CA-68: un hook que el cliente mata no deniega, y sin proceso aparte una operación bloqueada por dentro no se interrumpe | pedido del 2026-10-03, prioridad 3; → P-136-B y P-136-C |
| «medir el tope en bytes y ASCII/multibyte en Linux» | CA-67, «El tope» y «Medida»; CA-68, techos de tamaño en bytes con ASCII y multibyte | cubierta en la medida; **qué es «el tope»** no lo resuelve el pedido | → P-136-B |
| «Windows declarado no medido» | CA-54, nota, «No acredita»; CA-47, punto 20; CA-67; CA-68; CA-69, punto 4 | cubierta | pedido del 2026-10-03 |
| «Fuera de alcance: hueco C, P-119-A (F2/F5/F7), SEC-123 mecanismo.» | ninguno: no se versionan; Notas / alcance lo dice | cubierta | ídem |
| «en este orden de prioridad» | Bloque L, preámbulo; Notas / alcance; `Versión destino:` | cubierta | ídem |
| «El analista redacta el contrato de 1.36.0 POR PROPIEDAD Y MEDIDA … reutilizando el banco y las sondas que ya existen. No enumera formas de comando ni variantes; cita los casos existentes por su identificador.» | CA-54, nota; CA-47 punto 20; CA-67 a CA-69: cada uno con su propiedad, su instrumento, su plataforma, su umbral y lo que no acredita; los casos se citan por su sede del registro o de QA | cubierta, con una precisión: los vectores de SEC-115, SEC-118 y SEC-120 no tienen identificador propio en el registro, y se citan por su sección y su descripción (V1–V4, T1–T3), sin comandos | ídem |
| «Un REQ nuevo solo si AGENTS.md §9 lo exige para CA-54; si no, versionado de los criterios vigentes.» | CA-54 versionado (nota); razón en la propia nota y en Notas / alcance | cubierta | ídem |
| «Deja listas las decisiones que necesite del propietario como fichas en la cola, no las toma.» | P-136-A, P-136-B y P-136-C, en `PENDING_APPROVAL.md` § Pendientes | cubierta | ídem |

### Correspondencia con el encargo (décima autorización, 2026-10-03, registro de las decisiones)

Pedido: la décima autorización, literal en `PENDING_APPROVAL.md` § Resueltas, «RESUELTA (propietario, 2026-10-03,
décima autorización)». Sólo dan fila las obligaciones que son contrato de este REQ: sus cuatro decisiones sobre
criterios. La plantilla, los enlaces, la ficha del campo derivado y el índice no son contrato de este REQ; el
plan de fases 1 a 4 es implementación y validación de lo contratado. Las filas de la tabla de la apertura que
remitían a P-136-A, P-136-B y P-136-C («→ Preguntas abiertas», «→ P-136-B y P-136-C», «→ P-136-B») quedan resueltas
por éstas y no se reescriben.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «P-136-A: 0 procesos añadidos.» | CA-54, nota del 2026-10-03, «Coste en procesos» | cubierta, con una precisión del analista: el 0 es techo —menos es conforme— y se mide con la sonda que ya nombraba la ficha (`tests/util/sonda-procesos.sh`, entradas de S1 y S2), en la misma sesión que el reloj, porque la forma (d) pide las dos vías en la misma corrida | `PENDING_APPROVAL.md` § Resueltas, entrada de la décima autorización, «Decisiones del propietario» |
| «P-136-B: criterio por propiedad: toda denegación decidida llega al cliente, entera o acotada, nunca perdida; el desarrollador elige la técnica; …» | CA-67, propiedad y «El tope» (las dos técnicas, con las condiciones del motivo acotado que el criterio ya tenía) | cubierta | ídem |
| «…los avisos entran.» | CA-67, «Los avisos entran», «Medida» (los avisos y su fail-before) y «No acredita» | cubierta, con una precisión del analista: el vector de los avisos reutiliza los valores de `QA:` y `Seguridad:` que ya mide CA-67, escritos sin cerrar; y el fail-before de CA-69, punto 1, se lee con «sin aviso» en lugar de «sin decisión», porque un aviso no cambia la decisión | ídem |
| «P-136-C: techos de tamaño más plazo propio de 40 s, sin procesos.» | CA-68, «Cómo, y con qué plazo», «Lo que esta propiedad no puede prometer» y «Medida» (a); CA-69, punto 3 | cubierta, con una precisión del analista: el plazo es un tiempo límite interno y se declara **operativo** —«no más de 40 s», se baja con la medición; subirlo es decisión del propietario— y se mide a nivel de hook, como lo proponía la ficha | ídem |
| «CA-68 / REQ-017 CA-09: se evalúa al construir SEC-115; si afecta, §9.» | CA-68, «No regresión» | cubierta | ídem |

### Correspondencia con el encargo (P-136-D, 2026-10-05)

Pedido: la decisión del propietario sobre P-136-D, literal en `PENDING_APPROVAL.md` § Resueltas, «RESUELTA
(propietario, 2026-10-05) — P-136-D: opción (A) con condición de equivalencia». Sólo dan fila las obligaciones que
son contrato de este REQ: la aclaración de CA-54 (c), las condiciones del atajo y su prueba, y la semilla de la
sección 41. No dan fila, porque no son contrato de este REQ: el punto 4 (lo que QA ataca, que es validación de lo
contratado, fase 3 del plan), el punto 5 (presupuesto), «Continúa el plan desde la fase 2» y los defectos que manda
registrar como fichas o como hallazgo de proceso, que viven en `docs/PENDIENTES.md` (F-136-1 a F-136-3 y PR-136-1).

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «El atajo de guard-completado puede omitir el RECORRIDO DE DESTINOS cuando el comando entero no menciona el estado terminal.» | CA-54, nota del 2026-10-03, «Decisión del propietario sobre la implementación de CA-54» | cubierta | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-05) — P-136-D…», punto 1 |
| «No puede omitir el análisis del comando ni ninguna denegación por forma que guard-completado emite sin mirar destinos: presupuesto (ARNES_RC_EXCESO), CR del delimitador (ARNES_RC_CR), SEC-124 (ARNES_RC_CUERPO_CR) y LC10 (ARNES_RC_LC10). Esas salen antes del atajo, exactamente como en v1.35.0.» | ídem | cubierta | ídem, punto 1 |
| «Prueba: inventario del banco caso a caso idéntico al de referencia (2050 líneas, f35c9c04…), con la semilla de la sección 41 fijada.» | ídem; CA-54, «Medida», 4; CA-69, punto 2 (a), con la precisión de la semilla | cubierta | ídem, punto 2 |
| «Si difiere en una sola línea, el atajo está mal colocado y se corrige; no se cambia el veredicto.» | ídem; CA-69, punto 2 (a) («Para CA-54 no admite ninguna excepción») | cubierta | ídem, punto 2 |
| «el analista aclara CA-54 (c) así: «comprobar primero una condición necesaria de una regla, leyendo la entrada entera, no es analizar menos, siempre que ninguna denegación que no dependa de esa condición deje de emitirse». Ni más ni menos.» | CA-54, nota del 2026-10-03, «Aclaración de (c), del propietario» (texto literal, sin añadidos) | cubierta | ídem, punto 3 |
| «la semilla de la sección 41 se fija ahora (ajuste del banco sin cambio de veredicto: lo decides tú)» | CA-69, punto 2 (a): `ARNES_SEMILLA_41` fijada en la invocación al valor del inventario de referencia; el banco no cambia | cubierta, con la forma que eligió la coordinadora por la delegación del propio texto (en la invocación, no en el banco) | ídem, «Defectos registrados», y «Lo que añade la coordinadora», «Semilla de la sección 41» |

### Correspondencia con el encargo (P-136-F, 2026-10-05)

Pedido: la decisión del propietario sobre P-136-F, literal en `PENDING_APPROVAL.md` § Resueltas, «RESUELTA
(propietario, 2026-10-05) — **P-136-F: opción (C)**…». Sólo dan fila las obligaciones que son contrato o campo de
cabecera de este REQ: el cierre de QA-007-02, el límite declarado de CA-54 (punto 3) y el registro del punto 4. No dan
fila, porque no son contrato de este REQ: la reversión (punto 1, del `desarrollador`), la ficha de la recursión (punto
2, segunda mitad: vive en `docs/PENDIENTES.md`, F-136-5), la fase 4 y el commit validado (punto 5), el plan de versión
(puntos 6 y 7, en `docs/PLAN.md`) y el presupuesto.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «QA-007-02 queda CERRADO POR REVERSIÓN en el candidato» | `Hallazgos abiertos:` (sale del campo); CA-54, nota del 2026-10-03, «Límite declarado del candidato `82ceb63`», «El candidato» | cubierta | `PENDING_APPROVAL.md` § Resueltas, entrada P-136-F, punto 2 |
| «QA-007-01 queda como LÍMITE DECLARADO del candidato» | `Hallazgos abiertos:` (QA-007-01 anotado, con su clase `contrato` sin cambiar); CA-54, nota, «Límite declarado del candidato `82ceb63`» | cubierta, con una precisión: la clase no cambia por instrucción de la coordinadora; cómo se lee un `contrato` cuyo criterio ya se acotó lo decide quien firmó el hallazgo | ídem, punto 3 |
| «CA-54 se cumple en su medición (las 35 corridas)» | CA-54, nota, «Límite declarado…», «CA-54 se cumple en su medición» (corrida de la fase 3 sobre `82ceb63`) | cubierta | ídem, punto 3 |
| «las formas que QA añadió (sus casos M/N, un proyecto sin globs de código, el desarrollador con primer destino en código) quedan fuera del criterio» | CA-54, nota, «No acredita» (acotado) y «Límite declarado…», «Fuera del criterio» (cuatro formas, con sus cifras y su sede) | cubierta, con dos precisiones del analista: M0 y MD **no tienen cifra sobre `82ceb63`** —QA las midió sólo sobre `dee5932` con el anfitrión degradado—; y las otras entradas que QA midió sólo sobre `dee5932` (MN, ND, B2, B2S y DEEP) no las nombra la decisión, y esta nota no las clasifica | ídem, punto 3 |
| «y escritas en las notas» | `skills/arnes-upgrade/SKILL.md`, «Hacia 1.36.0», párrafo del límite declarado, para copiarlo a las notas `[1.36.0]` | cubierta, con una precisión: las notas `[1.36.0]` todavía no existen; copiar el párrafo es tarea de quien las escriba | ídem, punto 3 |
| «La medición en anfitrión degradado se registra como tal, no se repite.» | CA-54, nota, «Límite declarado…», «La medición con el anfitrión degradado» | cubierta | ídem, punto 3 |
| «El bloqueo del proveedor sobre QA (locales GB18030/BIG5, leído como rm sin haberlo) se registra; no se reintenta.» | CA-54, nota, «Límite declarado…», «El ataque de equivalencia y el control del proveedor» | cubierta | ídem, punto 4 |
| «El ataque de equivalencia sobre 82ceb63 vale el que ya se hizo; el que faltaba era sobre dee5932, que ya no existe.» | ídem | cubierta, con una precisión: `dee5932` sigue en la historia de la rama, revertido en `74da4c5`; lo que ya no existe es en el candidato | ídem, punto 4 |

### Correspondencia con el encargo (SEC-120, fase 2: los tres puntos, 2026-10-05)

Pedido: la decisión del propietario, literal en `PENDING_APPROVAL.md` § Resueltas, «RESUELTA (propietario, 2026-10-05,
posterior a `0c31cdd`) — SEC-120: los tres puntos abiertos de la fase 2». Sólo dan fila sus puntos 1 a 3, que cambian
el texto de CA-47 punto 20. No dan fila, porque no son contrato de este REQ: el orden de trabajo al volver los créditos
(QA, seguridad, commit validado, 2b de CA-54, SEC-115/118) y la mención de P-136-G.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «"0 procesos añadidos" rige sobre el CAMINO COMÚN: toda entrada legible cuesta lo mismo que en v1.35.0. En una entrada ilegible el hook antes no decidía y ahora emite deny: el jq que emite esa decisión es el coste de decidir, no un proceso añadido al análisis. CA-47 punto 20 lo dice así, con las dos cifras medidas (normal: +0; ilegible: +1).» | CA-47, punto 20, «Coste» y sus tres subviñetas | cubierta, con una precisión del analista: las entradas cuyo troceo falla se leen como las ilegibles —en v1.35.0 tampoco recibían decisión, y miden +1—, porque la pregunta que el propietario contesta era el «+1 proceso en entradas de SEC-120» (commit `0c31cdd`), que las incluye | `PENDING_APPROVAL.md` § Resueltas, entrada «SEC-120: los tres puntos abiertos de la fase 2», punto 1 |
| «todo lo que no sea exactamente un objeto JSON (null, número, vacío, dos objetos seguidos). Fail-closed» | CA-47, punto 20, «Qué es «no poder leer la entrada»» | cubierta; los cuatro ejemplos van marcados **no exhaustivos**, porque la regla es «exactamente un objeto» | ídem, punto 2 |
| «Sin CLAUDE_PROJECT_DIR el hook sigue inerte, como en v1.35.0: denegar ahí rompería proyectos que no usan el arnés. Se declara como límite en el punto 20.» | CA-47, punto 20, «Límite declarado: sin `CLAUDE_PROJECT_DIR`…» | cubierta, con una precisión del analista: se escribe en el ámbito del punto 20, el de una entrada ilegible —la que deja el hook sin raíz—; una entrada legible sin esa variable se juzga con la raíz que sale del `cwd` de la entrada (`docs/arnes/v1.36.0-sec120-fase2.md` §6), y este límite no la toca | ídem, punto 3 |

### Correspondencia con el encargo (P-136-H y P-136-I, 2026-10-05)

Pedido: las decisiones del propietario, literales en `PENDING_APPROVAL.md` § Resueltas, «RESUELTA (propietario,
2026-10-05) — **P-136-H: (A)** … y **P-136-I: (B)** …». Sólo dan fila las obligaciones que son contrato o campo de
cabecera de este REQ. No dan fila, porque no son contrato de este REQ: el plan de SEC-127 y sus casos de banco (la
ficha, en `docs/PLAN.md`), y el orden de trabajo («write-back de QA-007-05, seguridad de SEC-120, commit validado,
SEC-127»).

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «El texto del límite del punto 20 queda: «sin CLAUDE_PROJECT_DIR, el hook es inerte si no puede obtener el proyecto; si del cwd de la entrada obtiene uno con manifiesto, deniega».» | CA-47, punto 20, «Límite declarado: sin CLAUDE_PROJECT_DIR…» (título literal y su explicación) | cubierta | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-05) — P-136-H: (A) … y P-136-I: (B) …», P-136-H |
| «SEC-120 se cierra con QA-007-06 como residual declarado […]. Se repara dentro de SEC-127» | `Hallazgos abiertos:`, QA-007-06 («residual declarado (P-136-I), se repara en SEC-127», clase sin cambiar); CA-47, punto 20, «Pendiente hasta SEC-127, no límite» | cubierta | ídem, P-136-I |
| «El punto 20 conserva la promesa «deny por cualquier causa» con QA-007-06 anotado como pendiente hasta SEC-127, no como límite.» | CA-47, punto 20, primera viñeta (sin cambio) y «Pendiente hasta SEC-127, no límite» | cubierta | ídem, P-136-I |

### Correspondencia con el encargo (P-136-J y P-136-K, 2026-10-06)

Pedido: las decisiones del propietario, literales en `PENDING_APPROVAL.md` § Resueltas, «RESUELTA (propietario,
2026-10-06) — **P-136-J (A, acotada), P-136-K (A) y P-136-L (A)**…» (mensaje del 2026-10-06 a la sesión coordinadora
del worktree `ArnesJuan-v1.36`). Sólo dan fila las obligaciones que son contrato de este REQ. No dan fila, porque no
son contrato de este REQ: P-136-L entera (la revisión corta de `POSIXLY_CORRECT`, del `auditor-seguridad`, y su
reparación dentro de SEC-115/118), la reparación de SEC-128 en el código (del `desarrollador`) y el orden de trabajo
(«Encadena sin parar…»). La ficha de O-52-3 da fila porque este punto la cita como su frontera.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «la reparación es únicamente que un file_path que no es texto no deje pasar a nadie (fail-closed)» | CA-47, punto 20, subviñeta «SEC-128 — en `guard-codigo`, un `file_path` que no es texto no deja pasar a nadie (fail-closed)» | cubierta, con una precisión del analista: «a nadie» se escribe en `guard-codigo`, la puerta de SEC-128, porque `guard-completado` ya denegaba a todo agente (R-053 §4); y se declara el movimiento de `allow` a `deny` del agente de código con un `file_path` no textual que no nombra un enlace, que CA-69 punto 3 exige declarar | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-06) — P-136-J (A, acotada)…», P-136-J |
| «con su caso de banco» | ídem, «Caso de banco» y «La fila K5» | cubierta, con una precisión del analista: la fila K5, cuyo rótulo afirma la conducta contraria, pasa a esperar `deny`; no es un caso añadido, sino la consecuencia de la regla sobre una fila existente (R-053 §4, remediación (a)) | ídem, P-136-J |
| «Nada más entra en esta fase 2 corta. Si al abrirla aparece algo más, ficha.» | ídem, «Nada más entra en esta fase» (literal) | cubierta | ídem, P-136-J |
| «SEC-127 se acredita con los casos de la sección 47 y la lectura del código» | CA-47, punto 20, «SEC-127 — cómo se acredita (P-136-K)», sus dos primeras subviñetas | cubierta, con una precisión del analista: los casos se nombran (LO1 a LO4 y LK) y se dice lo que no acreditan —no son fail-before en bash 5.3.9— | ídem, P-136-K |
| «la prueba en bash 5.0 en modo POSIX queda declarada como no medida en CA-47 y en las notas» | ídem, «No medido, declarado»; y `skills/arnes-upgrade/SKILL.md`, «Hacia 1.36.0», párrafo de SEC-127, para copiarlo a las notas `[1.36.0]` | cubierta, con dos precisiones: se escribe «bash 5.0 o anterior», que es el alcance de SEC-127 en R-052 §4 y en la ficha de P-136-K; y las notas `[1.36.0]` todavía no existen, así que el párrafo va a la guía como se hizo con QA-007-01 (lo añade la coordinadora en la misma entrada) | ídem, P-136-K |
| «O-52-3 pasa a ficha de seguridad» | `docs/PENDIENTES.md`, F-136-7; CA-47, punto 20, «Fuera de este criterio: O-52-3» | cubierta; la clase la fija el `auditor-seguridad` y no tiene ventana en 1.36.0 | ídem, P-136-K |

### Correspondencia con el encargo (paso 6, fase 0, 2026-10-06)

Pedido, literal en `PENDING_APPROVAL.md` § Resueltas:
- el **plan autorizado del paso 6**, entrada «RESUELTA (coordinadora, por delegación expresa del propietario del
  2026-10-06) — Plan autorizado: paso 6 de 1.36.0, SEC-115 y SEC-118 (CA-67, CA-68, CA-69; ADR-017), con la
  reparación de SEC-129 (`POSIXLY_CORRECT`)», commit `2cf0934`. Sus obligaciones para esta fase son las de su «Fase 0»
  y los párrafos «Propiedad que CA-68 gana para SEC-129» y «Restricción para los techos de tamaño»;
- las decisiones del propietario que ese plan cita como fuente de su delegación: P-136-L (A), en la entrada
  «RESUELTA (propietario, 2026-10-06) — P-136-J (A, acotada), P-136-K (A) y P-136-L (A)»; y el punto 4 del «Resumen
  del plan vigente…» (2026-10-06).

*(Antes: la entrada del plan se declaraba `fuente no disponible`. No estaba en el archivo en la cabeza `e02f8e3`, en
la que arrancó esta comisión, y entró en `2cf0934`.)* Sólo dan fila las obligaciones que son contrato de este REQ.

No dan fila, porque no son contrato de este REQ:
- la reparación en el código y las fases 1 a 4 del plan;
- el presupuesto;
- P-136-B y P-136-C, que no cambian: sus filas son las de la décima autorización;
- la frase «Lo medido como «sin decisión» en 1.35.0 … tiene que dar `deny`», que ya está en CA-67, «Medida», sin
  cambio.

**Lo que el plan no dice, y por eso esta comisión lo escribió como suyo** (Trazabilidad):
- que la cota de 296 976 bytes sea **de contrato**: es el valor por defecto de la forma (b);
- la parada si SEC-115 exige un techo fuera de la restricción.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «la reparación va dentro de SEC-115/118, que ya trata «el hook siempre emite decisión»» (P-136-L) | CA-68, viñeta «Un final que no es un juicio no deja pasar, y ninguna decisión depende del modo del intérprete heredado», partes (i) y (ii), con el texto de R-054 §5 citado | cubierta, con una precisión del analista. «El hook siempre emite decisión», tal como estaba escrito en CA-67 y CA-68, no cubría SEC-129 (R-054 §5): CA-67 habla de una denegación decidida que no se emite, y CA-68 de un hook que no termina a tiempo. Por eso CA-68 gana la propiedad de R-054 §5 en vez de remitir a la que ya tenía | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-06) — P-136-J (A, acotada), P-136-K (A) y P-136-L (A)», P-136-L |
| «para fijar qué apaga exactamente POSIXLY_CORRECT=1 y desde cuándo (también en v1.35.0: no es regresión)» (P-136-L) | CA-68, «Medida de SEC-129», fail-before contra `78a2f33` y v1.35.0, y la frase «preexistente, medido igual desde v1.30.3 … no es una regresión de 1.36.0» | cubierta | ídem, P-136-L |
| «SEC-115/118 — CA-67, CA-68, CA-69; ADR-017. … Incluye la reparación de POSIXLY_CORRECT (P-136-L).» (Resumen, punto 4) | CA-68 (SEC-129); CA-69, punto 3 (el movimiento); ADR-017, «Nota posterior (2026-10-06)» | cubierta | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-06, sobre `df0b4f0`) — Resumen del plan vigente…», punto 4 |
| «ANTES de construir: evaluar CA-68 frente a REQ-017 CA-09» (Resumen, punto 4) | `docs/arnes/v1.36.0-sec115-118-ca68-vs-req017.md` (hecha por lectura); CA-68, «No regresión», «Evaluado por lectura el 2026-10-06»; CA-69, punto 7, E1 a E3 | cubierta, con una precisión del analista. La lectura concluye que no se puede saber sin medir, así que la evaluación se completa con E1 a E3. La propia evaluación (§5) los pone en la fase de construcción, antes de entregar, porque dependen de dónde se coloquen los techos | ídem, punto 4 |
| «si afecta, parar y presentarlo al propietario con §9» (Resumen, punto 4) | CA-69, punto 7, «Regla de «afecta»»; CA-68, «Techos de tamaño», párrafo de la parada | cubierta | ídem, punto 4 |
| «write-back de CA-67/CA-68/CA-69 con la propiedad de SEC-129» y «el hook sólo sale sin decisión cuando ha terminado un juicio que concluye que la llamada no toca nada protegido; cualquier otro final emite `deny` con motivo propio, a todo agente; y ninguna decisión depende del modo del intérprete heredado del entorno» (plan, Fase 0 y «Propiedad que CA-68 gana para SEC-129») | CA-68, viñeta «Un final que no es un juicio no deja pasar…», partes (i) y (ii); CA-69, punto 3. CA-67 no cambia | cubierta | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (coordinadora, por delegación expresa del propietario del 2026-10-06) — Plan autorizado: paso 6 de 1.36.0…», commit `2cf0934` |
| «(y QA-007-07 según P-136-N)»; «Si P-136-N = (A), la propiedad se enuncia sobre todo lo heredado del entorno e incluye `ARNES_INPUT_LISTO` y `ARNES_MANIFEST_LISTO` (QA-007-07); si (B), QA-007-07 va a 1.37» (plan, Fase 0 y «Propiedad…») | CA-68, viñeta «QA-007-07 queda pendiente de P-136-N» | cubierta mientras P-136-N siga pendiente: hoy no hay decisión que aplicar, y la línea lo dice. Cuando el propietario decida, se escribe la variante que elija. *(Decidida el 2026-10-06, (A): escrita en «Correspondencia con el encargo (P-136-O y P-136-N, 2026-10-06)».)* | ídem; P-136-N, en `PENDING_APPROVAL.md` § Pendientes |
| «Restricción para los techos de tamaño: ninguno puede caer sobre las entradas de la sonda 37/3 de REQ-017 CA-09 (un techo sobre `content` de `Write` queda por encima de los 296 976 bytes de `REQ-021.md`; ninguno por línea de cabecera en el camino común)» (plan) | CA-68, «Techos de tamaño», «Dónde no puede caer un techo nuevo», puntos 1 a 3 | cubierta, con dos precisiones del analista que el plan no dice: la cota de 296 976 bytes se clasifica de contrato, y si SEC-115 exige un techo fuera de la restricción se para y se presenta la ficha de la evaluación, §7 | ídem, plan |
| «la restricción de los techos y E1–E3 como medida» (plan, Fase 0); «E2 (sección 37/3 ≥ 6 veces) y E3 (la línea de CA-09 en los inventarios)» (Fase 2); «E1, E2 o E3 dan «afecta» → parar y presentar con §9» («Cuándo paras») | CA-69, punto 7, E1, E2, E3 y «Regla de «afecta»» | cubierta, con una precisión del analista: el plan resume la evaluación como «leyendo, no afecta». La evaluación (§5) concluye que no se puede saber sin medir, y así se escribe en CA-68, «No regresión». La obligación de medir E1 a E3 es la misma | ídem, plan |
| «comprueba si R2 cubre SEC-130 por construcción (F-136-12)» (Fase 3); «SEC-130 sólo como comprobación de QA» («Límites») | CA-69, punto 7, «Una comprobación de QA que no amplía el alcance: SEC-130» | cubierta | ídem, plan |
| «nota posterior fechada en ADR-017 si cambia su alcance» (plan, Fase 0) | ADR-017, «Nota posterior (2026-10-06)» | cubierta | ídem, plan |
| «`Archivos:` con la sección prevista» (plan, Fase 0) | `Archivos:` sin cambio: ya declara `47-decision-emitida.sh` y `47-lectura-fallida-y-locale.sh`. La previsión está en CA-68, «Medida de SEC-129» | cubierta | ídem, plan |

**Reutilizada por el write-back de estado de la fase 2 (2026-10-06).** El pedido es el mismo plan autorizado del
paso 6 (`PENDING_APPROVAL.md` § Resueltas, commit `2cf0934`), «Fase 2». Sus obligaciones son de construcción y de
entrega —la reparación, los casos en verde, E2, E3, el inventario, el banco, la autoprueba, las gates, los procesos y
el tope del motivo medido en bytes, con Windows declarado no medido—, y no dan fila porque no son contrato de este
REQ. El write-back sólo registra su estado en CA-67, CA-68 y CA-69, punto 7, rotulado SIN VALIDAR. **No cambia el
alcance, así que no hay tabla nueva** (plantilla de `requirements/README.md`, «Trazabilidad»). Lo que depende de
**P-136-O** (`PENDING_APPROVAL.md` § Pendientes) no se escribe: el alcance de los techos sobre llamadas legítimas,
su movimiento en CA-69, punto 3, y el FAIL no reproducido del inventario de CA-69, punto 2. *(Escrito después, en
«Correspondencia con el encargo (P-136-O y P-136-N, 2026-10-06)», abajo.)*

### Correspondencia con el encargo (P-136-O y P-136-N, 2026-10-06)

Pedido, literal en `PENDING_APPROVAL.md` § Resueltas, primera entrada, «RESUELTA (propietario, 2026-10-06) —
P-136-O: (1) (A) y (2) (A); P-136-N: (A)» (mensaje del 2026-10-06 a la sesión coordinadora del worktree
`ArnesJuan-v1.36`): «Decisión propuesta, lista para adoptar: «P-136-O: (1) (A) y (2) (A). P-136-N: (A).»». El
propietario hace suyo con esa respuesta el «Texto adoptado» de la misma entrada, que es el que se cita abajo. Las
fichas que resuelve están debajo de ella.

No dan fila, porque no son contrato de este REQ:
- la reparación de QA-007-07 en el código y su orden de despacho («Lo que añade la coordinadora»);
- la ficha para adelgazar `REQ-007.md`, que ya existe como F-136-17 en `docs/PENDIENTES.md` y aquí sólo se cita;
- las notas `[1.36.0]`, que todavía no existen: el párrafo va a la guía para copiarlo a ellas, como con P-136-F y
  P-136-K.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «los techos de tamaño (`ARNES_PIEZAS_MAX_BYTES` = 393 216 y `ARNES_EDIT_MAX_BUSQUEDA` = 2³²) quedan como **cambio de compatibilidad declarado**» (P-136-O (1) (A)) | CA-68, «Techos de tamaño», subviñeta «Cambio de compatibilidad declarado…»; CA-68, «Estado», viñeta de los dos techos, sin la marca de pendiente | cubierta | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-06) — P-136-O: (1) (A) y (2) (A); P-136-N: (A)» |
| «el analista lo escribe en CA-68, CA-69 p. 3, la guía y las notas» | CA-68 (arriba); CA-69, punto 3, «Declarado aparte: lo legítimo que cae en los techos…»; `skills/arnes-upgrade/SKILL.md`, «Hacia 1.36.0», párrafo del cambio de compatibilidad | cubierta, con una precisión: las notas `[1.36.0]` no existen todavía, y el párrafo de la guía es el que se copia a ellas | ídem |
| «(consecuencia: un REQ de más de 393 216 bytes no se escribe entero de una vez, y un `Edit` con `old_string` de más de ~6,5 KB sobre un documento de ese tamaño se deniega: se parte la edición)» | CA-68, «Cambio de compatibilidad declarado…», sus dos reglas y «La salida está en el motivo» | cubierta, con dos precisiones del analista. (1) El techo de piezas mide el texto troceado —el `content` más 4 bytes, sin el salto final—, así que la frontera medida es 393 213 / 393 214 bytes de `content` (`62-`). (2) Los ~6,5 KB valen para `REQ-007.md` (660 431 bytes): el presupuesto es un producto y la frontera del `old_string` depende del tamaño del documento; se escribe la regla con las cifras medidas en ese documento —3 000 a 6 400 bytes pasan; 7 000 y 12 000 deniegan—, no una cifra fija | ídem |
| «**Ficha para adelgazar `REQ-007.md`** a `historial/` en 1.37» | No da criterio: F-136-17 en `docs/PENDIENTES.md`, citada desde CA-68 | cubierta | ídem |
| «QA observa el FAIL de la sección 24 en su propio inventario y en varias corridas de la sección en reposo; si lo reproduce, es hallazgo; si no, INS-136-3» (P-136-O (2) (A)) | CA-69, punto 7, «Una observación de QA que no amplía el alcance: el FAIL de la sección 24…» | cubierta, con dos precisiones del analista. (1) El pedido no fija cuántas corridas son «varias»: QA registra el número antes de correr, para que no se decida a la vista del resultado. (2) El FAIL sigue escrito por CA-69, 2 (c): la observación decide su clase, no lo borra | ídem |
| «QA-007-07 entra en el paso 6 con SEC-129, bajo la propiedad de CA-68 enunciada sobre el entorno heredado: ninguna decisión del hook depende de nada que herede del entorno (modo del intérprete, variables `ARNES_*`; `BASH_ENV` queda como ficha F-136-9)» (P-136-N (A)) | CA-68, parte (ii) ampliada, con el modo del intérprete y `ARNES_INPUT_LISTO` y `ARNES_MANIFEST_LISTO` como ejemplos no exhaustivos; «Fuera de esta propiedad» (F-136-9), sin cambio; viñeta «QA-007-07 entra en esta propiedad» | cubierta, con una precisión del analista: las entradas que el host da al hook por contrato —ejemplo no exhaustivo, `CLAUDE_PROJECT_DIR`, cuyo límite fijó el propietario en CA-47, punto 20 (P-136-H)— no son «estado heredado» en el sentido de (ii) y deciden como dicen sus criterios. Sin esa precisión, (ii) contradiría CA-47, punto 20. El texto adoptado enumera el modo del intérprete y las variables `ARNES_*`, y la precisión no deja fuera ninguna de las dos | ídem |
| «Caso de banco para cada variable.» | CA-68, «Medida de QA-007-07: un caso de banco por variable, con fail-before» | cubierta, con una precisión del analista: el caso de `ARNES_INPUT_LISTO` incluye la entrada estándar cerrada, el segundo vector que QA midió en QA-007-07, y cada variable lleva su control (`ls -la` sin decisión) | ídem |
| «Nada más entra.» | CA-68, viñeta «QA-007-07 entra en esta propiedad», literal | cubierta | ídem |

**Reutilizada por el write-back de estado del QA del paso 6 (2026-10-06).** No hay pedido nuevo del propietario: el
encargo es de la coordinadora y sólo registra el estado de lo validado por QA —QA-007-07 en CA-68 (ii), la
observación de la sección 24 y la comprobación de SEC-130 en CA-69, punto 7, el cierre de QA-023-10 en la nota de
CA-54— y corrige punteros de línea. **No cambia el alcance, así que no hay tabla nueva** (plantilla de
`requirements/README.md`, «Trazabilidad»). Las filas de arriba de P-136-N y de P-136-O (2) (A) siguen cubiertas por
los mismos criterios. Lo que depende de **P-136-P** (`PENDING_APPROVAL.md` § Pendientes) no se escribe. *(Escrito
después, en «Correspondencia con el encargo (P-136-P, 2026-10-06)», abajo.)*

### Correspondencia con el encargo (P-136-P, 2026-10-06)

Pedido, literal en `PENDING_APPROVAL.md` § Resueltas, primera entrada, «RESUELTA (propietario, 2026-10-06) —
**P-136-P: (1) (A) y (2) (A)** — adoptada la decisión propuesta, literal» (mensaje del 2026-10-06 a la sesión
coordinadora del worktree `ArnesJuan-v1.36`): «Decisión propuesta, lista para adoptar: «P-136-P: (1) (A): QA-007-08
es INS-136-4; F-136-8 se amplía a CA-09; REQ-017 no se reabre. (2) (A): la pasada correctiva repara QA-007-10,
QA-007-12 y QA-007-11 (a); QA-007-11 (b) y QA-007-09 quedan como límites declarados con ficha para 1.37. Nada más
entra.»». La ficha que resuelve está debajo de esa entrada, con las opciones (A), (B) y (C) de cada punto y sus
consecuencias.

No dan fila, porque no son contrato de este REQ:
- la reparación en el código y el orden de despacho («Lo que añade la coordinadora»);
- las fichas INS-136-4, F-136-18 y F-136-19 y la ampliación de F-136-8, que existen en `docs/PENDIENTES.md` y aquí
  sólo se citan;
- la reclasificación de QA-007-08 y el cierre de lo reparado en `Hallazgos abiertos:`, que son de QA y seguridad;
- las notas `[1.36.0]`, que todavía no existen: los párrafos van a la guía para copiarlos a ellas, como con P-136-O.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «(1) (A): QA-007-08 es INS-136-4» | CA-69, punto 7, «Medido por QA: E2 dio 1 FAIL en 6; por decisión del propietario no es «afecta»», y la precisión de la «Regla de «afecta»» | cubierta, con una precisión del analista: la regla de «afecta» sigue vigente y la decisión resuelve **esta instancia**, por la dirección de la cifra (0,962×, el candidato más rápido) y por E1 sin cambio, que son las razones de la ficha (A); y el FAIL sigue escrito por CA-69, 2 (c) | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-06) — P-136-P: (1) (A) y (2) (A)» |
| «F-136-8 se amplía a CA-09» | No da criterio de este REQ: es una ficha de REQ-017 en `docs/PENDIENTES.md`, citada desde CA-69, punto 7 | cubierta | ídem |
| «REQ-017 no se reabre» | CA-69, punto 7, misma viñeta («REQ-017 no se reabre y sigue `completado`») | cubierta | ídem |
| «(2) (A): la pasada correctiva repara QA-007-10, QA-007-12 y QA-007-11 (a)» | CA-68 (ii), viñeta «QA-007-10 y QA-007-11 (a): en la pasada correctiva del paso 6, SIN VALIDAR»; CA-67, viñeta «QA-007-12: en la pasada correctiva del paso 6, SIN VALIDAR» | cubierta, con dos precisiones del analista. (1) Se escriben como **en la pasada, sin validar**, con la propiedad que cada uno tiene que cumplir —la de CA-68 (ii) y la de CA-67, sin cambio—: ninguna sede dice «reparado» antes de validar (CA-69, punto 5). (2) Que las funciones importadas del entorno son estado heredado de (ii), que QA dejó al analista, lo resuelve la propia decisión, porque la fila de QA-007-11 (a) de la ficha las incluye | ídem |
| «QA-007-11 (b) y QA-007-09 quedan como límites declarados con ficha para 1.37» | CA-68, «Límites declarados de 1.36.0», con alcance, causa, consecuencia, lo no medido y qué lo resolvería; `skills/arnes-upgrade/SKILL.md`, «Hacia 1.36.0», un párrafo por límite | cubierta, con una precisión del analista: «límite declarado» no es «aceptado» ni «reparado»; la propiedad de CA-68 no cambia y esos vectores siguen dentro de ella | ídem |
| «Nada más entra.» | CA-68 (ii), viñeta de QA-007-10 y QA-007-11 (a), «Lo que no entra («Nada más entra»)» | cubierta, con una precisión del analista: `PATH` como estado heredado, que QA no midió, queda fuera por esta frase; no se clasifica aquí | ídem |

### Correspondencia con el encargo (P-136-Q, 2026-10-07)

Pedido, literal en `PENDING_APPROVAL.md` § Resueltas, primera entrada, «RESUELTA (propietario, 2026-10-07) —
**P-136-Q: (A), con tope de una hora y acotada a QA-007-13**…» (mensaje del 2026-10-07 a la sesión coordinadora del
worktree `ArnesJuan-v1.36`), con la ficha que resuelve debajo, sus opciones (A), (B) y (C) y sus consecuencias.

No dan fila, porque no son contrato de este REQ:
- el tope de una hora de reloj y el alcance de la re-verificación de QA, que organizan el trabajo («Lo que añade la
  coordinadora»); el tope sí se cita en CA-68 (ii) como condición de la salida (B);
- la ficha F-136-20 y «PR-136-4 registrada; va con PR-136-1 a 3», que viven en `docs/PENDIENTES.md` y aquí sólo se
  citan;
- el cierre o la reclasificación de QA-007-13 en `Hallazgos abiertos:`, que son de QA y seguridad;
- las notas `[1.36.0]`, que todavía no existen: el párrafo va a la guía para copiarlo a ellas, como con P-136-P.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «(A), con tope de una hora y acotada a QA-007-13» | CA-68 (ii), viñeta «QA-007-13, la parte de `builtin`: en la pasada acotada de P-136-Q, SIN VALIDAR» | cubierta, con una precisión del analista: se escribe como **en la pasada, sin validar**, con la propiedad de (ii) dicha para este caso —misma decisión que sin la función, y la función no impide terminar—; ninguna sede dice «reparado» antes de validar (CA-69, punto 5) | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-07) — P-136-Q: (A), con tope de una hora y acotada a QA-007-13» |
| «entrada.sh arranca con POSIXLY_CORRECT=y; `unset -f` de una LISTA ESTÁTICA escrita en el archivo (builtins regulares que el hook usa + externos que invoca), sin descubrir nombres con declare/compgen/read; bucle sin órdenes suplantables o con tope; `set +o posix` al terminar el preludio» | CA-68 (ii), misma viñeta, «La técnica, contratada por el propietario» | cubierta, con una precisión del analista: que una orden usada por el preludio y ausente de la lista es incumplimiento de la propiedad, no frontera, aplica la regla (a) de `requirements/README.md` («Cómo se escribe un criterio que no se desmiente»): la pertenencia la decide el código | ídem |
| «Caso de banco: funciones `builtin` y `read` exportadas (la de `builtin` devolviendo 0), orden inocua, decisión emitida en < 5 s» | CA-68 (ii), misma viñeta, «Medida», con fail-before sobre `03cbf5e` | cubierta, con tres precisiones del analista. (1) «Decisión emitida», para una orden inocua, es el resultado que el hook entrega al terminar —sin decisión, como sin las funciones—, porque la parte (ii) y sus controles exigen que lo inocuo no reciba `deny`. (2) La cifra se declara **operativa** (techo; se baja con la medición; subirla es del propietario) y se aplica a la orden inocua, no a todo juicio, que sigue con el plazo de 40 s. (3) Contra v1.35.0 no hay fail-before, porque es una regresión de `03cbf5e`; se declara como control (CA-69, punto 1) | ídem |
| «Límites declarados (F-136-20, 1.37): `.`/`[` antes de entrada.sh, errexit, […] resolución desde hooks.json» | CA-68, «Límites declarados de 1.36.0», «Ampliación por P-136-Q: F-136-20», (i) y (ii), con alcance, causa, consecuencia, lo no medido y qué lo resolvería; `skills/arnes-upgrade/SKILL.md`, «Hacia 1.36.0», un párrafo | cubierta, con una precisión del analista: «límite declarado» no es «aceptado» ni «reparado», y la causa de `errexit` se escribe como **inferida**, porque nadie localizó la orden en la que termina | ídem |
| «y BASH_ENV si no está ya cubierto» | CA-68 (ii), «Fuera de esta propiedad» (P-136-N; F-136-9), sin cambio; remisión en «Ampliación por P-136-Q: F-136-20», (iii); el párrafo de la guía lo nombra | cubierta: ya estaba cubierto en este REQ y no se reescribe; la guía, que no lo explicaba, lo nombra en el párrafo nuevo | ídem |
| «si no cabe en pocas líneas, (B)» | CA-68 (ii), misma viñeta, «Si no cabe» | cubierta | ídem |
| «Nada más entra; contadores sin reiniciar.» | CA-68 (ii), misma viñeta, «Lo que no entra» y «Estado» | cubierta, con una precisión del analista: lo que QA registró y la decisión no nombra —el límite de `/proc/self/environ` ilegible que declara el comentario de `hooks/entrada.sh`, y `set` en los guardianes sueltos— no se escribe aquí por esta frase; no se clasifica | ídem |

### Correspondencia con el encargo (P-136-R, 2026-10-07)

Pedido, literal en `PENDING_APPROVAL.md` § Resueltas, primera entrada, «RESUELTA (propietario, 2026-10-07) —
**P-136-R: (A)** — adoptada la decisión propuesta, literal» (mensaje del 2026-10-07 a la sesión coordinadora del
worktree `ArnesJuan-v1.36`), con la ficha que resuelve debajo, sus opciones (A), (B) y (C) y sus consecuencias.

No dan fila, porque no son contrato de este REQ:
- la re-verificación acotada de QA y que la línea la añada el `desarrollador` dentro del tope de P-136-Q, que
  organizan el trabajo;
- la ficha F-136-20, que vive en `docs/PENDIENTES.md` y aquí sólo se cita;
- el cierre de QA-007-13 y la clase de QA-007-14 en `Hallazgos abiertos:`, que son de QA y seguridad.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «P-136-R: (A). La lista estática cubre los builtins que el hook usa, regulares y especiales (return, exit, break, continue, set, shift, :), retirados en modo POSIX» | CA-68 (ii), viñeta «QA-007-14: en la pasada de P-136-R, SIN VALIDAR», «La letra, corregida por P-136-R» y «La propiedad»; nota de corrección en «La técnica, contratada por el propietario» de la viñeta de QA-007-13 | cubierta, con una precisión del analista: la propiedad se escribe sobre esos siete nombres con la de (ii) sin cambio —misma decisión que sin la función y decisión en < 5 s, **operativo**—; la regla de la viñeta de QA-007-13 («una orden que el preludio use y no esté en la lista es incumplimiento, no frontera») sigue vigente | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-07) — P-136-R: (A)» |
| «caso de banco con return y break exportadas, decisión en < 5 s» | CA-68 (ii), misma viñeta, «Medida», con fail-before sobre `39e6128` | cubierta, con dos precisiones del analista. (1) «Decisión» se lee como una llamada que sin las funciones recibe `deny` y lo recibe igual; la cifra es un techo **operativo**. (2) Contra `03cbf5e` no hay fail-before por `guard.sh`, porque es una regresión de esta pasada; se declara como control (CA-69, punto 1) | ídem |
| «re-verificación acotada de QA» | CA-68 (ii), misma viñeta, «Medida», «No acredita», y «Estado» (SIN VALIDAR) | cubierta | ídem |
| «BASH_FUNC_set%% en guardianes sueltos → F-136-20» | CA-68, «Límites declarados de 1.36.0», «Ampliación por P-136-Q: F-136-20», punto (v), con alcance, causa, lo preexistente, lo no medido y qué lo resolvería | cubierta, con una precisión del analista: la numeración sigue la de la ficha (su (iv) es F-136-19); «límite declarado» no es «aceptado» ni «reparado» | ídem |
| «Nada más entra; contadores sin reiniciar.» | CA-68 (ii), misma viñeta, «Lo que no entra» y «Estado» | cubierta | ídem |

### Correspondencia con el encargo (P-136-S, 2026-10-07)

Pedido, literal en `PENDING_APPROVAL.md` § Resueltas, primera entrada, «RESUELTA (propietario, 2026-10-07) —
**P-136-S: (1) (A), (2) (A) y (3)** — adoptada la decisión propuesta, literal; autoriza el write-back de `AGENTS.md`
§13…» (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`), con la ficha que resuelve
debajo, sus opciones y sus consecuencias.

No dan fila, porque no son contrato de este REQ:
- el tope de una hora, la re-verificación acotada de QA y la determinación corta de seguridad, que organizan el
  trabajo; y el reparto en paralelo de «Lo que añade la coordinadora»;
- (3) (b) y (3) (c) —la versión 1.36.0 en los dos archivos de distribución, `arnes_version` en 1.33.0, el push y el
  PR fuera de borrador— y «Fusión, tag y publicación los decido yo», que son del `desarrollador`, de la coordinadora
  y del propietario, no de este criterio;
- las fichas F-136-21 y F-136-22, que viven en `docs/PENDIENTES.md` y aquí sólo se citan;
- la clase de SEC-131 y SEC-132 en `Hallazgos abiertos:`, que es de QA y seguridad;
- las notas `[1.36.0]`, que no son de esta comisión: los párrafos van a la guía para copiarlos a ellas.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «(1) (A): se repara SEC-132 (a) en una pasada acotada con tope de una hora (plazo comprobado entre gates, caso de banco con gates lentas, […])» | CA-68, viñeta «SEC-132 (a) — el plazo se comprueba entre una quality gate y la siguiente: en la pasada acotada de P-136-S, SIN VALIDAR», «La propiedad», «Medida» y «Estado» | cubierta, con una precisión del analista y una pregunta abierta. La precisión: la propiedad lleva el techo de 40 s de CA-68 y el caso de cuatro gates de 20 s con fail-before sobre `c5bf6d4`, que son del encargo de la coordinadora, no del texto del propietario. La pregunta: con la técnica literal la gate en curso no se interrumpe y el caso queda en la frontera de los 40 s, y el código observado sin commit corta la gate en curso, que va más allá de la decisión | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-07) — P-136-S: (1) (A), (2) (A) y (3)»; pregunta abierta en «Preguntas abiertas / conflictos», «SEC-132 (a): la gate en curso y el techo de 40 s» |
| «cambio de compatibilidad declarado» | CA-68, misma viñeta, «Cambio de compatibilidad declarado»; CA-69, punto 3, «Declarado aparte: lo legítimo que cae en el plazo comprobado entre quality gates» | cubierta, con una precisión del analista: «gates lentas» incluye el cierre legítimo con sus gates en verde que antes pasaba dentro de los 60 s del cliente, y se dice | ídem |
| «SEC-132 (b) límite declarado, ficha 1.37» | CA-68, «Límites declarados de 1.36.0», «Ampliación por P-136-S», viñeta de SEC-132 (b), con alcance, causa, consecuencia, lo no medido y qué lo resolvería; `skills/arnes-upgrade/SKILL.md`, «Hacia 1.36.0», un párrafo | cubierta, con una precisión del analista: «límite declarado» no es «aceptado» ni «reparado»; la causa se escribe **por lectura, sin localizar por medida**, como la dejó R-056 | ídem |
| «(2) (A): SEC-131 límite declarado, ficha F-136-21 con F-136-20 (frontera de confianza del entorno; lista blanca en `hooks.json` en 1.37)» | CA-68, «Límites declarados de 1.36.0», «Ampliación por P-136-S», viñeta de SEC-131; la guía, un párrafo | cubierta, con una precisión del analista: en 1.36.0 sólo se declara el límite; la frontera de confianza por propiedad y la lista blanca se escriben como lo que la ficha resuelve en 1.37, no como propiedad vigente | ídem |
| «(3) autorizo el write-back de AGENTS.md §13 y su plantilla por el analista» | `AGENTS.md` §13 y `templates/AGENTS.md.tpl`, el mismo texto: la cláusula 1 de los límites, la fila de los hallazgos, la de la cabecera ambigua y el párrafo de cierre; filas nuevas de CA-68 (ii) y de SEC-120; CA-69, punto 5, «Estado» | cubierta, con dos precisiones del analista: (1) dicen `mitigado` con los residuales de R-056 y nunca «reparado», y las cifras de SEC-118 de 1.35.0 quedan fechadas como historia; (2) `requirements/README.md`, su plantilla y la guía se tocan por la misma razón —son sedes de la promesa que CA-69, punto 5, nombra— y no por esta frase | ídem |
| «Nada más entra; contadores sin reiniciar.» | CA-68, viñeta de SEC-132 (a), «Estado»; los límites, sin reparar | cubierta | ídem |

### Correspondencia con el encargo (P-136-T, 2026-10-07)

Pedido, literal en `PENDING_APPROVAL.md` § Resueltas, primera entrada, «RESUELTA (propietario, 2026-10-07) —
**P-136-T: (B)** — la gate en curso se acota al tiempo que queda del plazo; cambio de compatibilidad declarado; caso
de banco con las dos formas» (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`), con la
ficha que resuelve debajo, sus opciones (A) y (B) y sus consecuencias. Resuelve la pregunta abierta que dejó la fila
de «(1) (A)» de la correspondencia de P-136-S, arriba, cuyo texto no se cambia.

No dan fila, porque no son contrato de este REQ:
- «Lo que añade la coordinadora» —que el `desarrollador` añada la forma al caso dentro de su tope y el reparto del
  write-back—, que organiza el trabajo;
- la técnica de la espera y el corte (`read -t`, `kill`), que es del `desarrollador`; aquí sólo se cita su frontera
  declarada en «No acredita».

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «P-136-T: (B). El plazo se comprueba entre gates y la gate en curso se acota al tiempo que queda del plazo: un cierre cuyas gates agotan el plazo se deniega por plazo con motivo propio, antes de los 40 s, incluida una gate colgada.» | CA-68, viñeta «SEC-132 (a) — el plazo se comprueba entre una quality gate y la siguiente», «La propiedad (P-136-T (B))»; `AGENTS.md` §13 y `templates/AGENTS.md.tpl`, cláusula 1, residual de SEC-132 (a), el mismo texto | cubierta, con dos precisiones del analista: (1) los 40 s siguen siendo el techo **operativo** de CA-68; (2) la frontera de «Lo que esta propiedad no puede prometer» sigue para las operaciones del propio hook, y se dice que una gate no es una de ellas; lo que la gate interrumpida haya lanzado por su cuenta va a «No acredita», como frontera declarada por el `desarrollador` y sin medir, sin prometer nada sobre ello | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-07) — P-136-T: (B)» |
| «Cambio de compatibilidad declarado: una gate que no termine dentro del plazo se interrumpe y el cierre se deniega.» | CA-68, misma viñeta, «Cambio de compatibilidad declarado», segunda forma; CA-69, punto 3, «Declarado aparte: lo legítimo que cae en el plazo comprobado entre quality gates»; `skills/arnes-upgrade/SKILL.md`, «Hacia 1.36.0», el párrafo de SEC-132 (a), marcado «su validación no está cerrada» | cubierta, con una precisión del analista: lo que el cliente hacía antes en v1.35.0 y `c5bf6d4` con una gate que no terminaba dentro de sus 60 s —matar el hook sin decisión— se escribe de la ficha de la coordinadora, no del texto adoptado; la frase «una sola gate que pasa de 60 s sigue siendo el límite declarado» se retira con su «Antes» | ídem |
| «El caso de banco cubre las dos formas: cuatro gates de 20 s y una gate colgada.» | CA-68, misma viñeta, «Medida», con fail-before sobre `c5bf6d4` y v1.35.0 | cubierta | ídem |
| «Nada más entra.» | CA-68, misma viñeta, «Estado» (SIN VALIDAR); la parte (b) de SEC-132, límite declarado sin cambio | cubierta | ídem |

### Correspondencia con el encargo (P-136-U, 2026-10-07)

Pedido, literal en `PENDING_APPROVAL.md` § Resueltas, primera entrada, «RESUELTA (propietario, 2026-10-07) —
**P-136-U: (A)** — se revierte el código de `cd63066`; SEC-132 (a) queda como límite declarado con (b) en F-136-22;
QA-007-15/16/17 se cierran por reversión» (mensaje del 2026-10-07 a la sesión coordinadora del worktree
`ArnesJuan-v1.36`), con la ficha que resuelve debajo, sus opciones (A), (B) y (C) y sus consecuencias. Deja superada,
en lo que toca a 1.36.0, la correspondencia de P-136-T, arriba, cuyo texto no se cambia.

No dan fila, porque no son contrato de este REQ:
- «QA comprueba que hooks/ es byte a byte c5bf6d4» y «QA-007-15, 16 y 17 se cierran por reversión»: son actos del
  `qa-tester`, y el campo `Hallazgos abiertos:` lo lleva él; este REQ los cita y no los acredita;
- «Lo que añade la coordinadora» —quién revierte, con qué orden, y el orden de las comisiones siguientes—, que
  organiza el trabajo.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «Se revierte el código de cd63066 (hooks y banco vuelven a c5bf6d4; se conservan el registro, la versión b43d7ea y la evidencia como historia)» | CA-68, viñeta «SEC-132 (a) — el plazo propio no alcanza a las quality gates», «La pasada que lo cubría, revertida»; CA-69, punto 3, «Retirado: el movimiento de las quality gates por el plazo» | cubierta, con una precisión del analista: la reversión la hace el `desarrollador` y la comprueba QA; este REQ la registra como hecho del candidato, y de ella deduce que el caso de banco de las dos formas se va con el banco | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-07) — P-136-U: (A)» |
| «SEC-132 (a) queda como límite declarado con (b) en F-136-22, para 1.37» | CA-68, misma viñeta (título, «Alcance», «Causa», «Consecuencia», «No medido», «Qué lo resolvería», «Estado»); «Límites declarados de 1.36.0», encabezado, y «Ampliación por P-136-S», el puntero a la parte (a); `AGENTS.md` §13 y `templates/AGENTS.md.tpl`, cláusula 1, el mismo texto; `skills/arnes-upgrade/SKILL.md`, «Hacia 1.36.0», el párrafo de SEC-132 (a) | cubierta, con una precisión del analista: la viñeta queda en su sitio, con remisión desde «Límites declarados de 1.36.0», y no se mueve dentro de «Ampliación por P-136-S»; «límite declarado» no es «aceptado» ni «reparado» | ídem |
| «con las tres lecciones de diseño escritas» | CA-68, misma viñeta, «Tres lecciones de diseño para 1.37», citadas de F-136-22; resumidas en la guía y remitidas desde `AGENTS.md` §13 | cubierta, con una precisión del analista: se escriben como lecciones para no repetir, no como contrato de la reparación de 1.37, que se propone antes de implementarse | ídem |
| «y la nota de que v1.35.0 cerraba el REQ sin decisión en ese caso» | CA-68, misma viñeta, «Consecuencia»; `AGENTS.md` §13 y su plantilla, cláusula 1; la guía | cubierta | ídem |
| «El analista lo escribe en CA-68, CA-69 p. 3, AGENTS.md §13 y la guía.» | CA-68 y CA-69, punto 3, arriba; `AGENTS.md` §13 y `templates/AGENTS.md.tpl`; la guía | cubierta, con una precisión del analista: la plantilla lleva el mismo texto que `AGENTS.md` §13, como en P-136-S (3); y CA-69, punto 5, recibe una precisión de una frase porque registraba el texto anterior de esas sedes | ídem |
| «Nada más entra; contadores sin reiniciar.» | CA-68, misma viñeta, «Estado»; ningún otro criterio cambia de contrato | cubierta | ídem |

### Correspondencia con el encargo (P-136-V, 2026-10-07)

Pedido, literal en `PENDING_APPROVAL.md` § Resueltas, primera entrada, «RESUELTA (propietario, 2026-10-07) —
**P-136-V: SEC-133 límite declarado para 1.37, con la fila de §13 acotada (qué no cubre y su consecuencia)**…»
(mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`), con la ficha que resuelve debajo,
sus opciones (A) y (B) y sus consecuencias. Las fuentes del hallazgo: R-057 §3 (L4, L5) y §4 (SEC-133), y su §6
sobre la fila de §13, en `docs/seguridad/registro-seguridad.md`; la ficha F-136-23 en `docs/PENDIENTES.md`.

No dan fila, porque no son contrato de este REQ:
- «último commit, push», que son de la coordinadora; y «Lo que añade la coordinadora» —quién escribe qué—, que
  organiza el trabajo;
- la ficha F-136-23, que vive en `docs/PENDIENTES.md` y aquí sólo se cita;
- la clase de SEC-133 en `Hallazgos abiertos:`, que es de QA y seguridad;
- «notas [1.36.0] con fecha»: las notas no son contrato de este REQ (la misma comisión las cierra en
  `docs/arnes/notas-1.36.0-borrador.md`, con el último commit como único hueco).

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «P-136-V: límite declarado para 1.37» | CA-68, «Límites declarados de 1.36.0», encabezado y «Ampliación por P-136-V: SEC-133», con alcance, causa, consecuencia, lo no medido y qué lo resolvería; `skills/arnes-upgrade/SKILL.md`, «Hacia 1.36.0», un párrafo | cubierta, con una precisión del analista: «límite declarado» no es «aceptado» ni «reparado»; lo que lo resolvería se escribe por propiedad (L4 y L5 de R-057) y las técnicas que cita R-057 quedan como ejemplos, no como contrato de la reparación de 1.37, que se propone antes de hacerse | `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-07) — P-136-V…» |
| «con la fila de §13 acotada (qué no cubre y su consecuencia). Write-back de §13» | `AGENTS.md` §13 y `templates/AGENTS.md.tpl`, el mismo texto: la fila «No completar un REQ con quality gates en rojo» | cubierta, con una precisión del analista: «qué no cubre» nombra SEC-133 y SEC-131 (a), las dos formas que R-057 §6 cita contra la fila, marcadas como ejemplos **no exhaustivos**; la cláusula 1 de los límites no se toca, porque la decisión nombra la fila | ídem |
| «Nada más entra.» | ningún otro criterio cambia de contrato; SEC-133 sin reparar | cubierta | ídem |

