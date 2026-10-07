# BORRADOR — notas de versión `[1.36.0]`

> **Esto es un borrador y no es la entrada del CHANGELOG.** Lo escribió el `analista-requerimientos` el 2026-10-06 y
> lo completó el 2026-10-07, por encargo de la coordinadora (paso 7 del plan de 1.36.0). Al cerrar, la coordinadora lo
> copia a la entrada `[1.36.0]` de `CHANGELOG.md`. Se leyó del disco del worktree `ArnesJuan-v1.36` (rama
> `cand/1.36.0`, cabeza `4610004`). **El analista no tuvo acceso a `git` en estas comisiones:** los commits se citan
> por las entradas del `CHANGELOG.md` y por las sedes que los nombran, no por `git log`.
>
> **Los huecos van marcados `[PENDIENTE: …]`** y no se rellenan por adelantado. Ningún veredicto que no esté escrito
> en su sede se afirma aquí.
>
> **Regla que este borrador no puede saltarse** (REQ-007 CA-69, punto 5): las sedes de la promesa —entre ellas estas
> notas— cambian «sólo cuando esté construido y validado, y sólo hasta lo medido». El paso 6 ya está construido y
> validado: QA favorable sobre el código de `c5bf6d4`, R-056 sin veto y R-057 sin veto sobre el estado final. Por eso
> aquí se dice **`mitigado`**, la palabra de R-056, y en ningún sitio «reparado».
>
> **Lo que estas notas no repiten (SEC-134, R-057 §5):** la frase «en 1.35.0, además, el REQ quedaba `completado`»
> sugiere que 1.36.0 lo evita, y no está medido así. Con las gates de SEC-132 (a), los dos árboles salen sin decisión a
> los 60 s y el cierre se aplica: 1.36.0 no cambia ese caso.

---

## [1.36.0] — [PENDIENTE: fecha de publicación] · Una puerta que no puede leer su entrada, terminar su juicio o emitir su decisión deja de dejar pasar —SEC-120, SEC-115, SEC-118 y SEC-129 quedan `mitigado`, con dos techos de tamaño como cambio de compatibilidad—, el análisis de `Bash` en el máximo baja de 5 s, y el plazo que no alcanza a las quality gates sale como límite declarado

> Origen: GitHub (commit de versión) · usuario: Juan · modelo de IA: Fable 5.1 (coordinadora) y Opus 5.5 (subagentes) ·
> gobernado por la instalación estable **1.35.0**

**Estas notas no publican nada.** El propietario lo dejó escrito: «Fusión, tag y publicación los decido yo con las
notas finales delante.» (P-136-S (3), `PENDING_APPROVAL.md` § Resueltas). La cabeza que se publique tendrá su propia
corrida de CI, y estas notas no afirman su resultado por adelantado: [PENDIENTE: CI sobre la cabeza final].

**De dónde salen.** Las decisiones del propietario están literales en `PENDING_APPROVAL.md` § Resueltas:
- «Alcance de 1.36.0 y apertura de la ventana» (2026-10-03, «Encargo 2»);
- la décima autorización (2026-10-03), con P-136-A, P-136-B y P-136-C;
- P-136-D a P-136-O (2026-10-05 y 2026-10-06), el «Ajuste de alcance de 1.36.0» (2026-10-05), los tres puntos de
  SEC-120 (2026-10-05), la decisión posterior a `39e68bb` (M0 y MD) y el «Resumen del plan vigente» (2026-10-06);
- P-136-P (2026-10-06) y P-136-Q a P-136-U (2026-10-07).

El contrato vive en `requirements/REQ-007.md` —nota de CA-54 del 2026-10-03, CA-47 punto 20, CA-67 a CA-69— y en
[ADR-017](../decisions/ADR-017-la-puerta-que-no-puede-leer-terminar-o-emitir-no-deja-pasar.md).

**Cómo están ordenadas** (calcado de las notas `[1.35.0]`):
- **Qué cambia:** por intervención, qué recibe un consumidor, los cambios de compatibilidad y Semver.
- **Límites declarados, con alcance y consecuencia.**
- **Lo no medido: el host y Windows/MSYS.**
- **Decisiones de riesgo del propietario.**
- **Firmas**, con lo que esta ventana midió sobre sí misma.
- **Hacia 1.37.0.**
- **Historia.**

---

### Qué cambia

**El código de 1.36.0 es el de `c5bf6d4`.** Los commits de código que lo componen, en orden: `82ceb63`, `413c6bd`,
`a59917d`, `78a2f33`, `0efd3c2`, `8e11f87`, `03cbf5e`, `39e6128` y `c5bf6d4`; la versión, en `b43d7ea`. Lo comprobó
QA sobre la cabeza `986ea6a`: `git diff c5bf6d4 986ea6a -- hooks/ tests/` vacío y los 11 archivos de `hooks/` iguales
byte a byte (`docs/qa/REQ-007.md`, «P-136-U: comprobación de la reversión», §1). Una pasada posterior (`cd63066`) se
revirtió antes de publicar y no está en la versión: va en «Historia».

**Los cambios de compatibilidad, en una línea cada uno** (detalle y decisión citada, en «Cambios de compatibilidad»,
abajo). En todos el movimiento va **hacia `deny`**; ninguno pasa de `deny` a `allow` (REQ-007 CA-69, punto 3, y
CA-24):
1. Una entrada del hook que no es exactamente un objeto JSON, o que no se puede leer, se deniega (SEC-120).
2. Un valor de `tool_input` que la puerta necesita y no puede trocear como texto —también `false`— se deniega.
3. En `guard-codigo`, un `file_path` que no es texto se deniega también al agente de código (SEC-128).
4. Dos techos de tamaño deniegan llamadas legítimas sobre un REQ muy grande (P-136-O).
5. El motivo de una denegación y el texto de un aviso salen acotados a 16 384 bytes (SEC-118).
6. Un juicio que agota el plazo propio del hook se deniega, también el legítimo (SEC-115).
7. Con el modo POSIX u otro estado del intérprete heredado del entorno, las puertas vuelven a decidir lo mismo que sin
   él, y un final que no es un juicio concluido deniega (SEC-129).

**Y uno que NO está:** las quality gates no se interrumpen por el plazo. La pasada que lo hacía se revirtió (P-136-U),
así que ningún cierre pasa a `deny` por plazo a causa de sus gates. Es un **límite declarado** (SEC-132 (a), abajo).

#### Por intervención: lo construido y lo validado

El orden es el del propietario (`docs/PLAN.md` § 1.36.0, «Orden final de 1.36.0»; literal en `PENDING_APPROVAL.md`
§ Resueltas, «Ajuste de alcance de 1.36.0»).

- **Intervención 1 — CA-54 / QA-023-10 (código de `82ceb63`).** *Cerrada como intervención* (`docs/PLAN.md` § 1.36.0,
  fila «—»).
  - **Qué hace:** el análisis de un comando de `Bash` en el máximo declarado (131 072 bytes) termina en menos de 5 s en
    Linux/WSL2, con la misma decisión que v1.35.0 y sin subir el umbral ni reducir la entrada (REQ-007, nota de CA-54
    del 2026-10-03, «Propiedad»). Es una optimización: cada juicio da el de v1.35.0 y sólo cambia lo que tarda.
  - **Cómo** (`CHANGELOG.md`, entrada «Décima autorización, fase 2 (CA-54)…», y R-052 §6):
    - el comando se analiza **una vez** por invocación (`arnes_escrituras_de`);
    - la fase de tokens del detector corre en **locale C sólo sobre texto ASCII**;
    - las ramas de «no determinable» salen de las funciones calientes;
    - el **atajo de `guard-completado`** omite sólo el recorrido de destinos cuando el comando entero no menciona el
      estado terminal, y sale **después** de toda denegación por forma (`ARNES_RC_EXCESO`, `ARNES_RC_CR`,
      `ARNES_RC_CUERPO_CR`, `ARNES_RC_LC10`). Lo admite la decisión P-136-D del propietario, con la aclaración de
      CA-54 (c), literal: «comprobar primero una condición necesaria de una regla, leyendo la entrada entera, no es
      analizar menos, siempre que ninguna denegación que no dependa de esa condición deje de emitirse».
  - **Medido por QA sobre `82ceb63`** (`docs/qa/REQ-007.md`, «Décima autorización, fase 3: CA-54», §1, §3, §4 y §6;
    repetido en REQ-007, nota de CA-54, «Límite declarado del candidato `82ceb63`»):
    - las 35 corridas de las sondas S1 y S2 por debajo de 5 000 ms, la más lenta en 4 513 ms, con decisión, rc,
      `bytes=` y `destinos=` iguales a v1.35.0;
    - 0 procesos añadidos (P-136-A);
    - inventario del banco de v1.35.0: 2 049 de 2 050 casos idénticos y 1 no acreditado por un INCONCLUSO de
      rendimiento (CA-69, punto 2 (c));
    - equivalencia del atajo: 6 148 ejecuciones sin ninguna diferencia de decisión, rc, stdout ni stderr.
  - **Línea base:** en v1.35.0, 30 de esas 35 corridas pasaban de 5 s (`CHANGELOG.md`, entrada «Décima autorización,
    fase 1 (CA-54)…»).
  - **QA-023-10, cerrado por QA en su medición** (REQ-007, nota de CA-54, «QA-023-10, cerrado por QA en su medición»;
    `docs/qa/REQ-007.md`, «Paso 6: validación…», §9 y §10): lo cierran las 35 corridas sobre `82ceb63` y la decisión
    P-136-F, punto 3. Una corrida posterior, sobre el código de `8e11f87`, se hizo con el anfitrión degradado: **no
    acredita los 5 s**, se registró como tal y no se repitió (misma nota).
  - **Recursión:** `82ceb63` da `deny` y rc 0 hasta 2 040 niveles, con tres tamaños de pila (R-052, citado en
    `CHANGELOG.md`, entrada «Décima autorización, fase 4…»). La pasada correctiva `dee5932`, que introducía una
    recursión sin tope (QA-007-02), se **revirtió** en `74da4c5`, con `hooks/` igual a `82ceb63` (P-136-F, punto 1).
  - **Lo que no:** QA-007-01 —cuatro formas que pueden tardar 5 s o más— sale como **límite declarado** (abajo). La
    segunda pasada (la «2b») sale a 1.37 (abajo, «Decisiones de riesgo»).
  - **Determinaciones de la intervención:** QA «con hallazgos: QA-007-01 declarado como límite»; seguridad R-052 «con
    hallazgos, sin veto», que abrió SEC-127 (registro, R-052 §6).

- **Pasos 1 a 4 — SEC-120 (código de `413c6bd`).** *Cerrada como intervención; SEC-120 `mitigado` en el candidato*
  (registro de seguridad, R-053 §7).
  - **Qué hace:** una entrada que `jq` no puede leer, o que no es exactamente un objeto JSON, se deniega a todo agente;
    un valor de `tool_input` que una puerta necesita y no puede trocear lo deniega esa puerta; ninguna variable conserva
    la lectura anterior (REQ-007 CA-47, punto 20).
  - **Qué es «ilegible»** (decisión del propietario sobre la fase 2 de SEC-120, punto 2, literal): «todo lo que no sea
    exactamente un objeto JSON (null, número, vacío, dos objetos seguidos). Fail-closed; es el principio del arnés.»
  - **Coste** (misma decisión, punto 1): «0 procesos añadidos» rige sobre el camino común; en una entrada ilegible, el
    `jq` que emite el `deny` «es el coste de decidir». Medido: normal +0; ilegible +1 (REQ-007 CA-47 p. 20, «Las dos
    cifras medidas»).
  - **Pasada correctiva** (`413c6bd`): la entrada vacía, la que empieza por NUL y la que trae algo detrás del objeto
    pasan a ilegibles (QA-007-03), y `false` en `file_path` o en `command` se deniega como `true` (QA-007-04)
    (`CHANGELOG.md`, entrada «SEC-120, pasada correctiva única…»).
  - **Medido por QA en la re-verificación** (`docs/qa/REQ-007.md`, «SEC-120: re-verificación de la pasada
    correctiva»; resumido en R-053 §7): sección 44, 363/0, con fail-before 314/49; 456 filas de ataque sin ningún
    `deny` a `allow` y sin falsos positivos; +0 procesos en el camino común.
  - **Determinaciones de la intervención:** QA «con hallazgos» (QA-007-06 como residual, P-136-I); seguridad R-053
    «con hallazgos, sin veto», SEC-120 `mitigado`, SEC-128 abierto (registro, R-053 §6 y §7).
  - **Vencimiento:** el de SEC-120, 2026-10-29, se refiere a la reparación; llega a los proyectos sólo al publicar.

- **Paso 5 — SEC-127, QA-007-06 y SEC-128 (código de `a59917d` y `78a2f33`).** *Cerrado como intervención*
  (`CHANGELOG.md`, entrada «Paso 5: commit validado…»).
  - **SEC-127:** el atajo de `guard-completado` ya no cambia el locale con una asignación delante de una llamada de
    función: guarda `LC_ALL`, lo pone en C y lo restaura con sentencias sueltas, sin subshell y sin procesos
    (`a59917d`). Seguridad: no queda ninguna asignación de ese tipo en el proceso que juzga; «la reparación elimina la
    premisa de versión por construcción» (registro, R-055 §2).
  - **QA-007-06:** un `read` fallido de la entrada —la entrada estándar cerrada, entre otras causas— deja la entrada
    vacía, que es ilegible, y recibe `deny` en los cuatro guardianes (REQ-007 CA-47 p. 20, «Reparado en SEC-127…»).
  - **SEC-128:** en `guard-codigo`, un `file_path` que no es texto deniega a todo agente, también al agente de código,
    en `Edit`, `Write` y `MultiEdit` (`78a2f33`; REQ-007 CA-47 p. 20, subviñeta SEC-128). Por `guard.sh` no cambia
    ninguna decisión: `guard-completado` ya lo denegaba (R-053 §4).
  - **Medido:** sección 47, 44/0, con su fail-before; R-055: `LC_ALL` restaurado en 24 combinaciones y la condición
    nueva de `guard-codigo` en `deny` en 72 (`CHANGELOG.md`, entrada «Paso 5: commit validado…»).
  - **Determinaciones de la intervención:** QA «código conforme; con hallazgos de contrato» —QA-007-06, cerrado
    después por su write-back, y QA-007-07, nuevo y preexistente— (`docs/qa/REQ-007.md`, «Paso 5…»). Seguridad R-055
    «conforme, sin veto»: SEC-127 y SEC-128 `mitigado` en el candidato; SEC-130 abierto (`instrumento`, baja)
    (registro, R-055 §7 y §9).

- **Paso 6 — SEC-118, SEC-115 y SEC-129, con QA-007-07 y las pasadas de P-136-P, P-136-Q y P-136-R (código de
  `0efd3c2`, `8e11f87`, `03cbf5e`, `39e6128` y `c5bf6d4`).** *Validado:* QA favorable sobre el código de `c5bf6d4` y
  R-056 «conforme con hallazgos, sin veto»; **SEC-115, SEC-118 y SEC-129 `mitigado`** en el candidato (REQ-007 CA-67,
  CA-68 y CA-69 p. 7, «Estado»; registro, R-056 §9 y §10).
  - **SEC-118 (CA-67):** el motivo de una denegación y el texto de un aviso viajan a `jq` por la entrada estándar, sin
    ningún dato variable en la línea de órdenes, y se acotan a **16 384 bytes** (`ARNES_MOTIVO_MAX_BYTES`, operativo),
    conservando el comienzo, con una nota de que se acortó y sin partir un carácter UTF-8. Desde `03cbf5e` se acota
    **después** de sanear el UTF-8, también con bytes que no lo son (QA-007-12, cerrado). Medido por QA: con UTF-8
    válido, motivos de 16 382 a 16 384 bytes; con bytes no UTF-8 leídos del disco, 0 casos mal de 393 a nivel de hook,
    donde `8e11f87` llegaba a 48 872 bytes (`docs/qa/REQ-007.md`, «Paso 6: validación…», §2, y «Paso 6: re-verificación
    de la pasada correctiva», §2). R-056: un `QA:` de unos 140 KB da el aviso en un JSON de 16 403 bytes y el `deny` en
    uno de 16 494, donde v1.35.0 no emitía nada (R-056 §1).
  - **SEC-115 (CA-68):**
    - plazo propio: **30 s** (`ARNES_PLAZO_S`), comprobado sin procesos entre unidades de trabajo, para que la
      respuesta llegue en **no más de 40 s** (el plazo de P-136-C); al vencer, `deny` a todo agente con motivo propio;
    - dos techos: piezas de la escritura, **393 216 bytes** (`ARNES_PIEZAS_MAX_BYTES`), y presupuesto de búsqueda de
      `old_string`, **2³²** (`ARNES_EDIT_MAX_BUSQUEDA`), los dos operativos;
    - `hooks/entrada.sh`, nuevo: una **trampa de salida** que emite un `deny` fijo si el proceso termina sin un juicio
      concluido;
    - medido por QA sobre `8e11f87`: T1 a T3 en `deny` en 0,4 a 2,6 s, y T2b en 0,2 a 0,4 s, donde v1.35.0 tardaba 32
      a 38 s; el plazo actúa en una llamada real: el cierre por `Edit` de un REQ de 3 MB con CRLF en disco recibe
      `deny` a los 36,3 s (`docs/qa/REQ-007.md`, «Paso 6: validación…»; resumen en `PENDING_APPROVAL.md` § Resueltas,
      P-136-P, «Contexto»);
    - `mitigado` en sus tres vías registradas —el valor grande, el `Write` grande y la búsqueda de `old_string`— (R-056
      §10), con residuales: QA-007-09, SEC-132 y la operación única que no termina.
  - **SEC-129 (CA-68 (i) y (ii)):** `hooks/entrada.sh` sale del modo POSIX al arrancar (R1), arranca el reloj y arma la
    trampa; una puerta abandonada a mitad o un código del analizador fuera de su vocabulario deniegan (R2). Medido por
    R-056 (bloque 02): con `POSIXLY_CORRECT=1`, `POSIXLY_CORRECT` vacía, `SHELLOPTS=posix`, un `BASH_ENV` con `set -o
    posix` y `bash --posix`, la decisión es la del modo normal en los 7 vectores, donde v1.35.0 sale sin decisión.
  - **La parte (ii) de CA-68 —ninguna decisión depende de nada que el hook herede del entorno—**, por P-136-N (A), con
    sus pasadas:
    - QA-007-07 (`8e11f87`): `ARNES_INPUT_LISTO` y `ARNES_MANIFEST_LISTO` heredadas dejan de apagar las puertas;
    - QA-007-10 (`03cbf5e`): `ARNES_CWD_VISTO` heredada deja de cambiar la decisión;
    - QA-007-11 (a) (`03cbf5e`): `FUNCNEST`, `BASH_COMPAT`, `compat31` a `compat44`, `keyword` y las funciones
      importadas del entorno se neutralizan en `hooks/entrada.sh`;
    - QA-007-13, la parte de `builtin` (`39e6128`): la limpieza ya no se puede suplantar; lista estática de `unset -f`
      escrita en el archivo, sin descubrir nombres;
    - QA-007-14 (`c5bf6d4`): la lista cubre también los builtins **especiales** que el hook usa (`return`, `exit`,
      `break`, `continue`, `set`, `shift`, `:`).

    Todos validados y cerrados por QA (REQ-007 CA-68 (ii), una viñeta por hallazgo con su sede). R-056: 516
    combinaciones de opciones heredadas con 12 diferencias, todas límites declarados (F-136-19, F-136-20 (ii)); 198 de
    variables, 0 diferencias; 2 448 de funciones importadas, 37 diferencias, todas de `.` o `[` (F-136-20 (i))
    (R-056 §3).
  - **CA-68 frente a REQ-017 CA-09** (CA-69, punto 7): **«no afecta»**. E1 sin cambio, medido por el desarrollador y
    por QA, y re-medido por QA hasta el código de `c5bf6d4`. El FAIL de E2 que midió QA (1 de 6, 0,962×, el candidato
    más rápido) es instrumento, INS-136-4, por decisión del propietario (P-136-P (1) (A)); REQ-017 no se reabre.
  - **SEC-130:** R2 **no** lo cubre, medido por QA y confirmado por R-056; sigue abierto (abajo, límites).
  - **Medido por QA sobre `c5bf6d4`** (`docs/qa/REQ-007.md`, «Paso 6: re-verificación de la línea de P-136-R»;
    evidencia `qa4/`, commit `c4afbde`): sección 47, 106/0; banco del worktree 2 303 PASS, 1 FAIL y 12 SKIP, con cuadre
    2 316 —el FAIL es INS-136-2, instrumento, y sigue escrito (CA-69, punto 2 (c))—; inventario de CA-69 2 (a), 2 037/0/13,
    sin movimientos de `deny` a `allow`; autoprueba 117/0; gates rc 0; +0 procesos.
  - **Veredicto de QA, literal:** «No queda ningún hallazgo de QA contra el código del paso 6 fuera de los límites
    declarados (F-136-19, F-136-20) y de los registros de instrumento (INS-136-1 a 4).» (misma sección). Y tras la
    reversión de `cd63066`: «No queda ningún hallazgo de QA contra el código de 1.36.0 (`c5bf6d4`).»
    (`docs/qa/REQ-007.md`, «P-136-U: comprobación de la reversión»).
  - **Determinación de seguridad, R-056** (registro, R-056 §9; evidencia `seg-R056/`, commit `4bd3464`): «Determinación
    sobre el delta del paso 6: CONFORME CON HALLAZGOS, SIN VETO.» En 3 162 combinaciones de entorno más la matriz POSIX,
    ningún `deny` pasa a `allow` ni a «sin decisión» a nivel de hook; los movimientos son sólo hacia `deny` y están
    declarados en CA-69, punto 3. Abrió **SEC-131** y **SEC-132**, los dos `contrato` y preexistentes (abajo, límites).

**Sin cambiar ningún hook:** la plantilla `templates/autorizacion.md` (décima autorización; `CHANGELOG.md`, entrada
«Décima autorización, fase 0…»), con la regla de parada afinada por P-136-E.

#### Qué recibe un consumidor al actualizar

**Con el plugin, sin migrar nada.** Actúa desde que se actualiza. Lista según las sedes; la lista exacta de archivos
es [PENDIENTE: `git diff --stat v1.35.0..<cabeza final> -- hooks/ tools/ templates/ skills/ requirements/README.md`]:
- `hooks/lib.sh`: CA-54 (análisis único, tokens en C sobre ASCII, atajo), SEC-120, SEC-127, QA-007-06, QA-007-07,
  QA-007-10, el motivo acotado, el plazo, los techos y R2.
- `hooks/entrada.sh` (**nuevo**): R1, la limpieza del estado heredado con su lista estática, el arranque del plazo y la
  trampa de salida. Lo cargan `guard.sh` y, cuando se ejecutan por su cuenta, los tres guardianes (REQ-007 CA-68,
  «Estado»).
- `hooks/guard.sh`, `hooks/guard-codigo.sh`, `hooks/guard-completado.sh` y `hooks/guard-git.sh`: la carga de
  `entrada.sh`, la marca de puerta terminada y, en `guard-codigo` y `guard-completado`, el código no declarado del
  analizador (R2); en `guard-codigo`, SEC-128; en `guard-completado`, el atajo de CA-54 (R-056, «Delta»).
- `tools/arnes-lectura.sh`: carga `lib.sh`, así que recibe sus cambios, cambie o no su propio texto (lo dirá el diff).
- `hooks/hooks.json`: ninguna sede de esta ventana dice que cambie; tocarlo es lo que F-136-9, F-136-19, F-136-20 y
  F-136-21 dejan para 1.37.
- `templates/autorizacion.md` (**nuevo**): no migra nada por sí sola (guía, «Hacia 1.36.0», primera entrada).
- La guía `arnes-upgrade`, § «Hacia 1.36.0»: una entrada por cada cambio de compatibilidad y por cada límite declarado
  de esta ventana. **Ninguna migra nada**: dicen lo que deniega la versión que se instala y lo que no cumple.

**Sólo si el proyecto migra con `arnes-upgrade`.** Las sedes de la promesa que el proyecto hereda dicen ya lo validado
(REQ-007 CA-69, punto 5, «Estado», escrito por P-136-S (3)): la cláusula 1 de los límites de `AGENTS.md` §13, la fila
de los hallazgos, la de la cabecera ambigua y dos filas nuevas —la parte (ii) de CA-68 y SEC-120—, con el mismo texto en
`templates/AGENTS.md.tpl`; y `requirements/README.md` § «Veredictos de validación» y § «Clases de hallazgo», con su
plantilla. Dicen **`mitigado`**, nunca «reparado», con sus residuales; lo medido en 1.35.0 queda fechado como historia
de esa versión; y SEC-132 (a) se nombra como **límite declarado**, con la remisión a F-136-22. **Salvedad abierta
(SEC-134, `contrato`, baja; R-057 §5):** esas sedes —la cláusula 1 de `AGENTS.md` §13, su plantilla, la guía, CA-68 y
F-136-22— contrastan SEC-132 (a) con 1.35.0 de un modo que sugiere que en 1.36.0 el REQ ya no queda cerrado; no está
medido así: en 1.36.0 el hook también sale sin decisión y el REQ puede quedar cerrado igual. R-057 recomienda
corregir ese texto antes del tag. [PENDIENTE: P-136-V, y la corrección de SEC-134 en esas sedes]. Y la fila «No
completar un REQ con quality gates en rojo» de §13 **excede lo medido** (R-057 §6): SEC-133 y SEC-131 (a) la
contradicen.

**Un proyecto que actualiza el plugin y no migra** tendrá la puerta nueva con el texto viejo de §13, que todavía llama a
SEC-115 y SEC-118 «limitaciones conocidas y sin reparar», como en 1.35.0.

#### Cambios de compatibilidad

1. **SEC-120: una entrada ilegible se deniega.** Norma: REQ-007 CA-47, punto 20.
   - **Decisión del propietario:** «2. SEC-120 (vence 2026-10-29): fallo de jq al leer o trocear la entrada → deny en
     las herramientas que las puertas juzgan.» («Alcance de 1.36.0…», Encargo 2, punto 2); y qué es ilegible: «todo
     lo que no sea exactamente un objeto JSON (null, número, vacío, dos objetos seguidos)» (tres puntos de SEC-120,
     punto 2). Para el `read` fallido: P-136-I (B), «SEC-120 se cierra con QA-007-06 como residual declarado … Se
     repara dentro de SEC-127».
   - **Qué deja de pasar:** las entradas que v1.35.0 dejaba sin decisión porque `jq` no las leía o no eran un objeto,
     y las que no se pueden leer por un `read` fallido. Ahora reciben `deny`, a todo agente, con motivo propio.
   - **Frontera, por decisión del propietario (P-136-H (A), literal):** «sin CLAUDE_PROJECT_DIR, el hook es inerte si
     no puede obtener el proyecto; si del cwd de la entrada obtiene uno con manifiesto, deniega». En límites, abajo.
   - **Lo que se sabe del host:** «no alcanzable desde el host en lo observado», sin verificar (REQ-007 CA-47 p. 20,
     «No acredita»). Y QA dejó escrito, sin medirlo, que si el host entregara alguna vez una entrada estándar no
     bloqueante, «el candidato denegaría todo, mientras v1.35.0 dejaba pasar todo sin decidir» (`docs/qa/REQ-007.md`,
     «Paso 5…», §8).
2. **Un valor de `tool_input` que la puerta necesita y no puede trocear como texto se deniega; también `false`.**
   Norma: REQ-007 CA-47 p. 20, segunda viñeta («un valor que debía ser texto y es un número», ejemplo no exhaustivo).
   - **Decisión:** la del cambio 1, Encargo 2, punto 2 («leer **o trocear**»). **No hay una decisión del propietario
     que nombre `false`:** QA-007-04 lo midió (`file_path` o `command` en `false` salían sin decisión) y la pasada
     correctiva que lo repara la decidió la coordinadora dentro del plan autorizado de SEC-120, porque «el contrato ya
     decide esos casos» (`CHANGELOG.md`, entrada «SEC-120, paso 2: QA (Opus) CON HALLAZGOS…»).
   - **Qué deja de pasar:** unas ediciones de `MultiEdit` que no son una lista, un número donde va texto, `false` en
     `file_path` o en `command`. Una puerta que no necesita esa parte decide como siempre.
3. **SEC-128: un `file_path` que no es texto se deniega también al agente de código.** Norma: REQ-007 CA-47 p. 20,
   subviñeta SEC-128.
   - **Decisión del propietario (P-136-J (A), literal):** «la reparación es únicamente que un file_path que no es texto
     no deje pasar a nadie (fail-closed), con su caso de banco. Nada más entra en esta fase 2 corta.»
   - **Qué deja de pasar:** para el agente de código, en `Edit`, `Write` y `MultiEdit`, de `allow` a `deny` cuando el
     texto del campo no nombra un enlace dentro de la raíz (v1.35.0 lo leía como texto y lo dejaba pasar; «por lectura
     de R-053 §4, no medido aparte», REQ-007 CA-47 p. 20). **Por `guard.sh` no cambia ninguna decisión.**
4. **Los techos de tamaño: un REQ muy grande no se escribe entero de una vez, y un `Edit` con un `old_string` grande
   sobre él se deniega.** Norma: REQ-007 CA-68, «Techos de tamaño», «Cambio de compatibilidad declarado…», y CA-69,
   punto 3.
   - **Decisión del propietario (P-136-O (1) (A), texto adoptado):** «los techos de tamaño (`ARNES_PIEZAS_MAX_BYTES` =
     393 216 y `ARNES_EDIT_MAX_BUSQUEDA` = 2³²) quedan como **cambio de compatibilidad declarado** …».
   - **Texto de la guía** (`skills/arnes-upgrade/SKILL.md`, «Hacia 1.36.0»; copiado): Para que un hook que no termina
     de juzgar a tiempo no deje pasar, `guard-completado` mide el tamaño antes de las operaciones que crecen más que
     linealmente, y deniega a todo agente por encima de dos techos. **(1)** El `Write` de un REQ cuyo `content` pasa de
     unos **393 216 bytes** (el techo cuenta el texto troceado: el `content` más 4 bytes, sin el salto final; medido,
     393 213 bytes pasan y 393 214 deniegan) **se deniega**: un REQ de ese tamaño no se escribe entero de una vez.
     **(2)** Un `Edit` cuyo producto (bytes del documento más los de los `new_string`) × (bytes de los `old_string`)
     pasa de **2³²** **se deniega**; en un `MultiEdit` cuentan todas sus ediciones. La frontera depende del tamaño del
     REQ: sobre uno de 660 431 bytes, un `old_string` de 3 000 a 6 400 bytes pasa y uno de 7 000 o más deniega.
     **Consecuencia y salida:** con 1.35.0 esas llamadas salían sin decisión; ahora el motivo del `deny` lo dice y dice
     cómo salir: edita el REQ por fragmentos con `Edit`, usa un `old_string` más corto —basta con el trozo que
     identifica el sitio— o parte la edición en varias llamadas. Los REQ por debajo de esos tamaños no cambian
     (medido: un `Write` de 296 973 bytes sigue igual). Medido en Linux/WSL2, una corrida por punto; Windows/MSYS y el
     host, sin medir.
   - **Caso legítimo medido** (REQ-007 CA-68, misma viñeta): el `Write` de `REQ-007.md` entero, 660 431 bytes, salía
     sin decisión en 11,5 s con v1.35.0 y sale con `deny` en el candidato. QA reprodujo las fronteras y no encontró
     ningún movimiento fuera de lo declarado (`docs/qa/REQ-007.md`, «Paso 6: validación…»).
   - **Dirección admitida:** las cifras son operativas; bajarlas es cambio menor con su Historial, y **subirlas queda
     fuera**: «el propietario no eligió las opciones (B) ni (C) de P-136-O» (REQ-007 CA-68, misma viñeta).
   - **El síntoma**, un REQ de 660 KB, va a F-136-17, para 1.37 (abajo).
5. **SEC-118: el motivo y el aviso salen acotados a 16 384 bytes.** Norma: REQ-007 CA-67.
   - **Decisión del propietario (P-136-B, literal):** «criterio por propiedad: toda denegación decidida llega al
     cliente, entera o acotada, nunca perdida; el desarrollador elige la técnica; los avisos entran.»
   - **Qué cambia para quien lee la salida:** un motivo o un aviso de más de 16 384 bytes llega cortado, con su
     comienzo —que nombra la causa— y la nota «[...] (ARNES: motivo acortado: medía N bytes y el tope es 16384; se
     conserva su comienzo)» (REQ-007 CA-67, «Estado»), sin un carácter UTF-8 partido, también cuando el contenido
     interpolado no es UTF-8 válido. En v1.35.0, por encima del límite de un argumento, no llegaba **nada** y el hook
     salía sin decisión (SEC-118). **La decisión no cambia** por acotar; lo que cambia es el texto, y lo que puede
     perderse es lo que va **detrás** del contenido interpolado (O-56-3, abajo).
6. **SEC-115: un juicio que agota el plazo propio se deniega, también el legítimo.** Norma: REQ-007 CA-68, «Un plazo
   propio del hook de 40 s», y CA-69, punto 3.
   - **Decisión del propietario (P-136-C, literal):** «techos de tamaño más plazo propio de 40 s, sin procesos.»
   - **Qué deja de pasar:** «Lo legítimo que agote el plazo se deniega igual, a todo agente» (CA-68). Construido con
     el plazo en 30 s para responder en no más de 40 s.
   - **Medido en una llamada real** (QA, sobre `8e11f87`): el cierre por `Edit` de un REQ de 3 MB con CRLF en disco
     recibe `deny` por el plazo a los 36,3 s, donde v1.35.0 salía sin decisión.
   - **Lo que el plazo no alcanza:** las quality gates (SEC-132 (a)) y una sola operación que no termina —ejemplos
     **no exhaustivos**: QA-007-09 y SEC-132 (b)—; los tres, límites declarados (abajo).
7. **SEC-129 y el estado heredado: las puertas deciden lo mismo que sin él, y un final que no es un juicio deniega.**
   Norma: REQ-007 CA-68, partes (i) y (ii); ADR-017, notas posteriores del 2026-10-06.
   - **Decisiones del propietario, literales:** P-136-L (A), «Revisión corta de seguridad ahora, para fijar qué apaga
     exactamente POSIXLY_CORRECT=1 y desde cuándo (también en v1.35.0: no es regresión); la reparación va dentro de
     SEC-115/118, que ya trata «el hook siempre emite decisión».»; P-136-N (A), texto adoptado: «ninguna decisión del
     hook depende de nada que herede del entorno (modo del intérprete, variables `ARNES_*`; `BASH_ENV` queda como
     ficha F-136-9). Caso de banco para cada variable. Nada más entra.»; y P-136-P (2) (A), P-136-Q (A) y P-136-R (A),
     que repararon QA-007-10, QA-007-11 (a), QA-007-12, la parte de `builtin` de QA-007-13 y QA-007-14 dentro de esa
     propiedad.
   - **Qué cambia:** con `POSIXLY_CORRECT` exportada (también vacía), `SHELLOPTS` con `posix`, un `BASH_ENV` que hace
     `set -o posix` o `bash --posix`, la vía `Bash` de `guard-codigo`, `guard-completado` y `guard-git` salía **sin
     decisión** para toda llamada —también el git destructivo—, medido desde v1.30.3 (registro, R-054 §1 y §2). Ahora
     recibe la misma decisión que en modo normal: `deny` donde el modo normal deniega, y `ls -la` sigue sin decisión.
     Lo mismo con las variables `ARNES_*` y el estado del intérprete de la parte (ii). Un error del intérprete, una
     puerta abandonada o un código del analizador fuera de su vocabulario deniegan.
   - **Para un consumidor:** si su entorno exporta `POSIXLY_CORRECT` —una variable estándar que algunos usuarios
     exportan, según R-054 §3, «Lectura de amenaza»—, dejará de ver pasar sin decisión escrituras por shell a código
     protegido, cierres por shell y git destructivo. **Sobre lo legítimo no se espera movimiento**, porque (ii) exige la
     misma decisión que sin ese estado (ADR-017, nota posterior SEC-129, «Consecuencias»); las variables `ARNES_*`
     heredadas, en particular, «es protección, no compatibilidad» (REQ-007 CA-69, punto 3).
   - **Hacia el lado cerrado, dos estados heredados deniegan lo legítimo:** `SHELLOPTS` con `errexit` (preexistente;
     F-136-20 (ii), abajo) y un `ulimit -f` heredado bajo, que convierte el aviso en `deny` (R-056 §1 y §3).

**Retirado antes de publicar: las quality gates interrumpidas por el plazo (SEC-132 (a)).** P-136-S (1) (A) y P-136-T
(B) decidieron repararlo en 1.36.0 como cambio de compatibilidad —una gate que no termina dentro del plazo se
interrumpe y el cierre se deniega—, y la pasada `cd63066` lo construyó. P-136-U (A) la **revirtió** (`986ea6a`) por los
tres hallazgos que abría. **En 1.36.0 ninguna gate se interrumpe y ningún cierre pasa a `deny` por plazo a causa de sus
gates, tampoco lo legítimo** (REQ-007 CA-69, punto 3, «Retirado…»). No es un cambio de compatibilidad: es un límite
declarado, abajo.

#### Semver: `minor` por la convención de este arnés

El número `1.36.0` es el de la ventana que abrió el propietario («Encargo 2 — Apertura de v1.36.0», `PENDING_APPROVAL.md`
§ Resueltas, «Alcance de 1.36.0…»), y la subida la autorizó él: «la subida de versión a 1.36.0 en los dos archivos de
distribución (arnes_version se conserva en 1.33.0)» (P-136-S (3)). Hecha en `b43d7ea`; QA la comprobó sobre `986ea6a`:
`.claude-plugin/plugin.json` y `marketplace.json` en 1.36.0, `arnes_version` en 1.33.0, `jq -e .` rc 0
(`docs/qa/REQ-007.md`, «P-136-U: comprobación de la reversión», §1).

**En SemVer estricto no es `minor` pura:** los cambios 3, 4 y 6 deniegan llamadas que v1.35.0 dejaba pasar sin esconder
ningún bloqueante —sobre todo el 4, medido sobre un REQ legítimo—, y el 5 cambia el texto que recibe el cliente.
Aplicada a la letra, esa regla pediría una versión mayor. La convención de este arnés publica como `minor` o `patch`
los cambios que cierran un fail-open de la puerta, aunque hagan denegar lo que antes pasaba, y declara una por una las
incompatibilidades que no esconden nada (notas `[1.35.0]`, «Semver»). Por eso van **declaradas arriba, una por una**.

---

### Límites declarados, con alcance y consecuencia

**«Límite declarado» no es «riesgo aceptado», y declarar no repara.** Lo que sigue se publica abierto. **SKIP e
INCONCLUSO no acreditan** (decisión 7 de 1.35.0; REQ-007 CA-69, punto 2 (c)). La lista es **no exhaustiva**: lo que no
esté aquí no queda por ello cubierto.

1. **SEC-132 (a): el plazo propio no alcanza a las quality gates** (REQ-007 CA-68, «SEC-132 (a) — el plazo propio no
   alcanza a las quality gates»; ficha F-136-22, «Ampliación (P-136-U (A), 2026-10-07)»).
   - **Decisión del propietario (P-136-U (A), literal):** «P-136-U: (A). Se revierte el código de cd63066 (hooks y
     banco vuelven a c5bf6d4; se conservan el registro, la versión b43d7ea y la evidencia como historia); QA comprueba
     que hooks/ es byte a byte c5bf6d4. SEC-132 (a) queda como límite declarado con (b) en F-136-22, para 1.37, con las
     tres lecciones de diseño escritas y la nota de que v1.35.0 cerraba el REQ sin decisión en ese caso. QA-007-15, 16
     y 17 se cierran por reversión. El analista lo escribe en CA-68, CA-69 p. 3, AGENTS.md §13 y la guía. Nada más
     entra; contadores sin reiniciar.»
   - **Alcance:** un cierre por `Edit` cuyas quality gates no terminan dentro de los 60 s del cliente. Medido a nivel de
     hook, por `guard.sh`, Linux/WSL2, bash 5.3.9, una corrida por punto: **cuatro gates de 20 s** en serie, o **una
     sola gate colgada**, dejan el hook **sin decisión** a los 60 s. Alcanzable con una configuración ordinaria del
     manifiesto, también con todas las gates en verde.
   - **Causa:** el plazo se comprueba antes de la primera gate (`hooks/guard-completado.sh:946` en `c5bf6d4`; R-056 §7
     (a)), y no entre una gate y la siguiente ni durante la que está en curso.
   - **1.36.0 no cambia este caso frente a v1.35.0** (R-057 §5, SEC-134): con cuatro gates de 20 s o una colgada, los
     dos árboles salen **sin decisión** a los 60 s y el cierre se aplica. En v1.35.0 el hook moría sin salida (rc 124 a
     60 028 ms; `docs/qa/REQ-007.md`, «SEC-132 (a): re-verificación acotada», §4); en el candidato, lo único que sale es
     el `deny` fijo de la trampa **después** de que `timeout` señalara al hook, de un hook que el cliente ya mató. En el
     cliente los dos son «sin decisión», y que eso cuente como permitir es inferido: **el REQ puede quedar `completado`
     también en 1.36.0**.
   - **La pasada revertida:** `cd63066` acotaba la gate en curso y daba `deny` por plazo hacia los 30,2 s, pero QA
     abrió tres hallazgos introducidos por ella: **QA-007-15** (`contrato`, media) —una gate roja con `echo 0 >&3;
     false` salía sin decisión **y cerraba el REQ**, donde `c5bf6d4` y v1.35.0 deniegan—; **QA-007-16** (`contrato`,
     baja) —lo que sobrevivía a una gate retenía el stderr del hook—; y **QA-007-17** (`contrato`, baja) —el corte del
     árbol era superlineal: 14 000 descendientes, sin decisión a los 60 s—. Los tres, cerrados por reversión.
   - **Tres lecciones de diseño para 1.37** (F-136-22): (1) el canal por el que el hook lee el veredicto de una gate
     **no puede ser escribible por la gate**; (2) el corte de una gate que agota el plazo tiene que ser **lineal**
     (grupo de procesos, no recorrido del árbol), con límite declarado para lo que se desligue o ignore TERM; (3) la
     salida de la gate **no puede retener el stderr del hook** después de decidir. Se propone antes de implementarse.
   - **Dos lecciones más, de R-057 §3:** **L4** —la gate es código no confiable dentro del proceso del hook: su
     veredicto es sólo su código de salida, y nada de lo que hereda (entrada estándar, descriptores, salidas, trampas,
     funciones) puede alimentar la lista, el veredicto ni la salida del hook—; y **L5** —reparar la vivacidad no debe
     romper la integridad: una reparación de «siempre emite decisión» se valida también contra «nunca pasa una gate
     roja», con casos adversarios en el banco **antes** del intento de 1.37—.
   - **Consecuencia:** que el cliente tome por permitir un hook sin decisión es inferido. El candidato **no tiene caso de
     banco** que mida este vector: se fue con la reversión.
   - **No medido:** el host, Windows/MSYS, bash distinto de 5.3.9, gates de otras duraciones o en otro número, y los
     cierres por `Write` o `MultiEdit`.
2. **SEC-132 (b): miles de líneas `Hallazgos abiertos:` repetidas en la cabecera en disco** (REQ-007 CA-68, «Ampliación
   por P-136-S»; F-136-22). Decisión (P-136-S (1) (A)): «SEC-132 (b) límite declarado, ficha 1.37.»
   - **Alcance y medida** (R-056 §7 (b)): un `Edit` pequeño que cierra un REQ con esa línea repetida. Con líneas de 66
     caracteres: 12 000, `deny` en 32,8 s; 20 000 (1,6 MB), **sin decisión** a los 60 s. Con líneas cortas, 20 000
     (600 KB), `deny` a los **48,5 s**, por encima de los 40 s del plazo. En v1.35.0, sin decisión.
   - **Causa:** superlineal y sin techo delante; por lectura y **sin localizar por medida** (un control del proveedor
     detuvo la sonda de perfil, O-56-2). **No es QA-007-09**, y un techo sobre el disco por encima de 660 KB no lo
     cubriría (R-056 §5).
3. **QA-007-09: un REQ grande con CRLF en disco deja sin decisión el `Edit` que lo cierra** (REQ-007 CA-68, «Límites
   declarados de 1.36.0»; ficha **F-136-18**). Decisión (P-136-P (2) (A), literal): «QA-007-11 (b) y QA-007-09 quedan
   como límites declarados con ficha para 1.37.»
   - **Alcance y medida** (QA, sobre `8e11f87`, una corrida por punto): 3 MB, `deny` por el plazo en 36,3 s; 3,3 MB,
     `deny` en **50,9 s**, por encima de los 40 s; **3,6 MB y 4 MB, sin decisión** a los 60 s. En v1.35.0, sin decisión
     **desde 3 MB**.
   - **Causa:** la normalización del CRLF del disco (`hooks/guard-completado.sh:604` en `8e11f87`) es superlineal y no
     tiene techo: el techo de piezas mide la entrada, no el disco; y el plazo no interrumpe una sola operación.
   - **No medido:** Windows/MSYS, donde el umbral bajaría; por `Write` o `MultiEdit`.
4. **QA-007-11 (b): `SHELLOPTS` con `noexec` u `onecmd`, y `xtrace` con `BASH_XTRACEFD=1`, heredados** (REQ-007 CA-68,
   «Límites declarados de 1.36.0»; ficha **F-136-19**, agrupada en F-136-20). Misma decisión que el 3.
   - Con `noexec` u `onecmd`, **sin decisión** en todos los vectores que deniegan; con `xtrace` hacia la salida
     estándar, la salida no es un JSON válido. Igual en v1.35.0. No se neutraliza desde dentro del hook.
5. **F-136-20: estado heredado que corre antes de cualquier limpieza del hook** (REQ-007 CA-68, «Ampliación por
   P-136-Q: F-136-20»). Decisión (P-136-Q, literal): «Límites declarados (F-136-20, 1.37): `.`/`[` antes de
   entrada.sh, errexit, y BASH_ENV si no está ya cubierto; resolución desde hooks.json.» Y P-136-R: «BASH_FUNC_set%% en
   guardianes sueltos → F-136-20.»
   - **(i) Funciones importadas con el nombre de `.` o de `[`:** `guard.sh` ejecuta esas órdenes para cargar
     `hooks/entrada.sh`, antes de cualquier limpieza. Las llamadas que deberían denegarse salen **sin decisión**; y,
     dato de R-056 (§3, `seg-R056/04-`), **con una función `[` que imprime un `allow`, el hook emite un `allow`
     explícito** —un único JSON válido— en los 6 vectores del barrido, que además salta el diálogo de permisos del
     cliente. Con ese entorno el efecto puede ser **cualquier decisión, también `allow`**.
   - **(ii) `SHELLOPTS` con `errexit`:** deniega todo, también lo legítimo —falla hacia el lado cerrado, y la sesión no
     puede trabajar—; la orden en la que termina, **inferida**, no localizada.
   - **(iii) `BASH_ENV` con cualquier contenido** corre antes que el hook, con sus permisos (F-136-9, O-54-1).
   - **(v) `BASH_FUNC_set%%` en los guardianes ejecutados sueltos**, fuera del camino de producción: `hooks/hooks.json`
     sólo lanza `guard.sh`.
   - **Preexistentes** y medidos a nivel de hook en Linux/WSL2, bash 5.3.9, salvo (iii), que se sostiene por cómo arranca
     bash. Su frontera es la orden con que `hooks/hooks.json` lanza bash.
6. **SEC-131: una función heredada con el nombre de la orden de una quality gate, un `ulimit -n` heredado y `PATH`**
   (REQ-007 CA-68, «Ampliación por P-136-S»; ficha **F-136-21**). Decisión (P-136-S (2) (A), literal): «SEC-131 límite
   declarado, ficha F-136-21 con F-136-20.»
   - (i) con una función que devuelve 0, una gate **roja** pasa y el cierre sale **sin decisión** (el `eval` de las
     gates hereda las funciones, `hooks/guard-completado.sh:953`); (ii) con `ulimit -n` de 4 o 5, el preludio falla, se
     lee como «inerte» y un cierre por `sed -i` sale sin decisión; (iii) `PATH` se resuelve antes de la primera línea
     del hook y es la raíz de confianza, no un vector medido. Igual en v1.35.0 (R-056 §6).
7. **QA-007-01: el análisis de `Bash` en el máximo puede tardar 5 s o más con cuatro formas** (REQ-007, nota de CA-54,
   «Límite declarado del candidato `82ceb63`»; decisión P-136-F, punto 3, literal: «QA-007-01 queda como LÍMITE
   DECLARADO del candidato: CA-54 se cumple en su medición (las 35 corridas), y las formas que QA añadió (sus casos
   M/N, un proyecto sin globs de código, el desarrollador con primer destino en código) quedan fuera del criterio y
   escritas en las notas. La medición en anfitrión degradado se registra como tal, no se repite.»).
   - **Las cuatro formas,** en el máximo declarado (131 072 bytes), Linux/WSL2, a nivel de hook:
     - **M**, el comando menciona el estado terminal y todos sus destinos quedan fuera de `requirements/`: 2 de 15
       corridas en 5 s o más (5 214 y 5 814 ms);
     - **N**, el comando lleva un carácter no ASCII: 8 de 15, entre 5 012 y 5 613 ms;
     - **M0**, un proyecto sin globs de código, y **MD**, el agente de código con su primer destino en código
       protegido: **sin cifra sobre `82ceb63`** (decisión del propietario posterior a `39e68bb`, punto 1, literal:
       «M0 y MD: límite declarado «sin cifra sobre 82ceb63»; se miden en la intervención 2b, en anfitrión sano, antes
       de cualquier optimización.»).

     En total, 10 de 30 corridas de M y N entre 5 012 y 5 814 ms, con decisión y rc iguales a v1.35.0 en las 30.
   - **La medición con el anfitrión degradado** fue sobre `dee5932`, no sobre el candidato: M0 14 de 15 (máximo
     11 529 ms) y MD 5 de 15 (máximo 8 534 ms). «No acredita ni desmiente nada sobre `82ceb63`.»
   - **Consecuencia:** un comando con esas formas, en el máximo, **se juzga igual pero puede tardar 5 s o más**. No hay
     fallo en abierto medido: la corrida más lenta queda a más de 54 s de los 60 s del cliente. Un margen no es una
     garantía: en un equipo más lento o más cargado, el hook podría agotar el tiempo. Windows/MSYS, sin medir.
   - **Reparación:** la 2b, que sale a 1.37 (abajo, «Decisiones de riesgo»). QA-007-01 sigue en `Hallazgos abiertos:`
     de REQ-007 con su clase `contrato`.
8. **SEC-127: la corrección en bash 5.0 o anterior en modo POSIX, no medida** (REQ-007 CA-47 p. 20, «SEC-127 — cómo
   se acredita (P-136-K)»; decisión P-136-K (A), literal: «SEC-127 se acredita con los casos de la sección 47 y la
   lectura del código; la prueba en bash 5.0 en modo POSIX queda declarada como no medida en CA-47 y en las notas.»).
   - **Texto de la guía** («Hacia 1.36.0», copiado): El atajo de `guard-completado` cambiaba el locale del proceso que
     juzga con una asignación delante de una llamada de función; en bash 5.0 o anterior, en modo POSIX, esa asignación
     persiste al volver de la función, y el cierre por `Bash` de un REQ con un estado terminal no ASCII escrito con
     otras mayúsculas podría pasar (consecuencia simulada, no reproducida). La reparación restaura el locale sin esa
     forma. **SEC-127 se acredita con los casos de la sección 47 del banco (LO1 a LO4 y LK) y con la lectura del
     código.** Esos casos se miden en bash 5.3 y allí no son fail-before. **La prueba en bash 5.0 o anterior en modo
     POSIX queda declarada como no medida:** en ese intérprete la corrección se sostiene por lectura, no por medida.
   - **Estado:** SEC-127 `mitigado` en el candidato, «laguna declarada, no acreditada» (registro, R-055 §2).
9. **Sin `CLAUDE_PROJECT_DIR`, el hook es inerte cuando no obtiene el proyecto** (REQ-007 CA-47 p. 20, «Límite
   declarado…»; P-136-H (A), literal arriba, cambio 1).
   - **Consecuencia:** una entrada ilegible sin esa variable de la que no se obtiene un proyecto **no recibe `deny`**
     de este hook. Que el host fije siempre la variable está «observado y **no verificado**».
10. **SEC-130 (`instrumento`, baja): abierto, no aceptado** (REQ-007 CA-69 p. 7, «Texto final, según R-056»; ficha
    **F-136-12**, 1.37). El atajo de `guard-completado` afirma «el comando no menciona el estado terminal» sin
    comprobarlo si la redirección de su grupo falla. R2 **no** lo cubre: el guardián termina y escribe su marca (medido
    por QA y confirmado por R-056 §4). **Desde fuera del proceso no se alcanza**: con el límite de descriptores
    heredado en 3, rc 127; en 4 y 5, la vía inerte de SEC-131; en 6 o más, la decisión normal. Sólo se alcanza
    cambiando el límite **dentro** del proceso. Lo introduce `a59917d`.
    - **Efecto sobre la publicación:** no bloquea cerrar REQ-007, por su clase; abierto, «devuelve **publicar** al
      propietario» (R-056 §4).
11. **O-52-3: con `LC_ALL=C` en el entorno desde el arranque, el cierre por `Bash` con `TERMINÉ`/`terminé` sale sin
    decisión, también en v1.35.0** (ficha **F-136-7**; REQ-007 CA-47 p. 20, «Fuera de este criterio»). Sin clase
    asignada: la clasifica el auditor. Sin ventana en 1.36.0 (P-136-K: «O-52-3 pasa a ficha de seguridad»).
12. **Lo que CA-68 no puede prometer** (REQ-007 CA-68, «Lo que esta propiedad no puede prometer»): si el cliente mata
    el proceso, nada que el hook haga deniega (SEC-030, abierto aparte); y sin un proceso aparte, una sola operación que
    se bloquea por dentro no se interrumpe: el plazo se comprueba entre unidades de trabajo. Y, por la documentación de
    los hooks, un código de salida distinto de 0 o dos documentos JSON en la salida equivalen a «sin decisión»
    —**inferido, no medido en el host**—; en el candidato sólo aparecen cuando el cliente ya mató el hook o con los
    vectores de F-136-20 (R-056 §2).
13. **Fronteras de SEC-120 que no se contratan** (registro, R-053 §5): O-53-1, un `tool_name` que no es texto sale sin
    decisión en v1.35.0 y en el candidato; queda fuera de la letra del punto 20 y el `matcher` lo hace inalcanzable
    desde el host.
14. **Heredados de 1.35.0, fuera de 1.36.0 por decisión del propietario** («Alcance de 1.36.0…», literal: «Fuera de
    alcance: hueco C, P-119-A (F2/F5/F7), SEC-123 mecanismo.»): siguen **abiertos y no aceptados como riesgo**, con su
    descripción en las notas `[1.35.0]`, «Límites declarados»:
    - **el hueco C:** las escrituras por intérpretes o scripts no se detectan. Esta ventana lo volvió a medir sobre sí
      misma (abajo, «Firmas», PR-136-1 a 3) y un proyecto consumidor también (F-136-13). La ficha b) de 1.37 propone
      convertirlo en detección;
    - **P-119-A (F2, F5, F7) y SEC-123.**
15. **Hallazgos que siguen en `Hallazgos abiertos:` de REQ-007** (cabecera, leída del disco en la cabeza `4610004`,
    antes de R-057; lista sin juzgar, con la clase que declara el campo): QA-114 (`contrato`), QA-116 (`contrato`),
    QA-117 (`contrato`), SEC-123 (`instrumento`), SEC-124 (`contrato`, «reparado en su alcance (validación manual del
    propietario)»), SEC-125 (`instrumento`), QA-023-23 (`instrumento`), QA-007-01 (`contrato`), SEC-130
    (`instrumento`), SEC-131 (`contrato`), SEC-132 (`contrato`), QA-007-08 (`instrumento`, INS-136-4), QA-007-09
    (`contrato`) y QA-007-11 (`contrato`). R-057 añade **SEC-133** y **SEC-134**, los dos `contrato` (R-057 §8).
    Salieron del campo en esta ventana, cerrados por quien los firmó: QA-023-10, QA-007-07, SEC-129, QA-007-15,
    QA-007-16 y QA-007-17, entre otros. Lo que diga el campo sobre la cabeza que se publique es lo que vale.
16. **Ruido de instrumento, sin reparar** (`docs/PENDIENTES.md`): INS-136-1 (la calibración de `sonda-reloj.sh` sale
    fuera de banda; F-136-4), INS-136-2 (REQ-017 CA-08 (ii) oscila alrededor de su techo de 1,25×; F-136-8), INS-136-3
    (el FAIL de la sección 24 que no se reprodujo en 16 corridas de QA), INS-136-4 (E2 de REQ-017 CA-09; F-136-8
    ampliada) y F-136-16 (el nombre de un caso de la sección 43 depende del PID). Un inventario puede diferir en esos
    casos sin que cambie el código; el FAIL sigue escrito y **no se desmiente repitiendo**.
17. **Observaciones de seguridad sin hallazgo** (R-056 §8): **O-56-1**, comentarios del código publicado
    (`hooks/guard-completado.sh:66-70`, `hooks/lib.sh:1466` y `:3048`) que todavía dicen que el motivo viaja «como UN
    argumento» de `jq`; **O-56-3**, el recorte del motivo no cambia ninguna decisión, pero puede perder lo que va detrás
    del contenido interpolado; **O-56-4**, los motivos interpolan contenido del disco en el contexto del modelo, un
    canal de inyección indirecta preexistente que el tope acota y no crea. Y **O-57-1** (R-057 §6): «los techos de
    tamaño deniegan antes de las operaciones que crecen más que linealmente», en §13, es más ancho que lo medido; no es
    hallazgo porque la misma cláusula declara al lado las dos excepciones (SEC-132 (b) y QA-007-09).
18. **SEC-133 (`contrato`, media, preexistente e igual en v1.35.0; abierto, no aceptado): una quality gate que lee su
    entrada estándar se come la lista de las gates siguientes** (registro, R-057 §4; evidencia `seg-R057/01-`, commit
    `1f73698`).
    - **Qué pasa:** el bucle lee la lista de gates de la entrada estándar (`hooks/guard-completado.sh:958`) y cada gate
      la hereda (`:953`). Una gate que lee su entrada —medido con `cat >/dev/null` o `read -r x; true`— consume la lista:
      las gates siguientes **no se ejecutan**, y el cierre sale **sin decisión** aunque una posterior esté en rojo.
      Controles: la gate roja sola, `true` seguida de `false`, y la misma `cat` con `</dev/null`, dan `deny`.
    - **Alcance:** cualquier orden de gate que lea de la entrada estándar sin necesitarlo; no hace falta ningún ataque.
      **No medido:** qué órdenes de gate reales lo hacen; por `Write` y `MultiEdit` (mismo bucle, por lectura); el host,
      Windows/MSYS y otros bash.
    - **Consecuencia:** es un fail-open de la puerta de cierre con configuración ordinaria. Contradice la fila «No
      completar un REQ con quality gates en rojo» de `AGENTS.md` §13 y §7. No lo introduce 1.36.0.
    - **Lo que decide el propietario:** si se declara como límite para 1.37 o se repara antes de publicar. La
      coordinadora recomienda límite declarado, con ficha F-136-23 y las lecciones L4 y L5 de R-057; R-057 §7 recomienda
      lo mismo. [PENDIENTE: P-136-V — su decisión, la ficha F-136-23 si se crea, y el write-back en CA-68 y en §13].
      Hasta entonces **no es un límite declarado**: es un hallazgo abierto y sin decidir.
19. **SEC-134 (`contrato`, baja, de redacción; abierto): una frase de las sedes de la promesa sugiere una mejora que no
    está medida** (registro, R-057 §5). Es la de SEC-132 (a) sobre 1.35.0, que estas notas no repiten (cabecera de este
    borrador y límite 1). Su corrección es del `analista-requerimientos`, y R-057 la recomienda antes del tag.
    [PENDIENTE: P-136-V y la corrección de texto en las sedes].

---

### Lo no medido: el host y Windows/MSYS

**La regla, la de 1.35.0:** una conducta está medida sólo en la capa y la plataforma en que se ejecutó su caso. Las
listas son **no exhaustivas**, y que algo no aparezca **no lo hace medido**.

- **Medido:** a nivel de hook en Linux/WSL2, bash 5.3.9 (las sedes de cada intervención, arriba).
- **El host (`claude -p`):** no ejercido para nada de 1.36.0 en las sedes leídas; «no comprobado en el host» en cada
  criterio: CA-47 p. 20 («No acredita»), CA-67, CA-68 y CA-69, punto 4. Tampoco la interpretación que el cliente hace
  del código de salida, de dos documentos JSON o del `deny` fijo que la trampa emite después de una señal (R-056 §11).
- **Windows/MSYS:** declarado no medido en CA-54 (allí se midió 20,4–28,9 s sobre `3bc7d3c`, sin promesa en esta
  ventana; nota de CA-54, «No acredita»), en CA-47 p. 20, en CA-67 —que el límite de `CreateProcess` ya no alcance al
  motivo, al ir por la entrada estándar, es inferido— y en CA-68 —allí la retirada del transporte es superlineal y un
  mismo juicio tarda varias veces más—. Los límites de tiempo de arriba tendrían allí umbrales más bajos, sin cifra.
- **Otros intérpretes:** bash 5.0 o anterior en modo POSIX (límite 8); de 4.3 a 5.2, la conducta de SEC-129 es
  inferida (R-054 §2); bash 3.2, no medido.
- **Las expansiones `$'…'` en modo POSIX:** sin medir; un control del proveedor detuvo la sonda (O-54-3).
- **Límites de recursos heredados** `ulimit -v`, `-s` y `-t`: sin medir (R-056 §11).
- **El banco completo sobre la cabeza final:** lo da el CI. QA no lo corrió sobre `986ea6a` porque su código es
  `c5bf6d4` byte a byte, ya validado con el banco entero (`docs/qa/REQ-007.md`, «P-136-U…», §3).
  [PENDIENTE: CI sobre la cabeza final].

---

### Decisiones de riesgo del propietario

Literales en `PENDING_APPROVAL.md` § Resueltas, en la entrada que se cita. **Ninguna repara lo que decide.**

1. **La 2b de CA-54 sale a 1.37** («Ajuste de alcance de 1.36.0», 2026-10-05, literal): «La 2b de CA-54 sale de
   1.36.0 y pasa a 1.37 como ficha. CA-54 queda cerrado con QA-007-01 como límite declarado y la medición de seguridad
   sobre la recursión (hasta 2040 niveles) como evidencia.» Ficha F-136-6.
2. **La recursión de la lectura léxica sale a 1.37** (P-136-F, punto 2, y el mismo ajuste de alcance): QA-007-02
   «CERRADO POR REVERSIÓN en el candidato», con la ficha F-136-5 y su condición literal: «Antes de cualquier
   intervención que la toque, el banco recibe primero el caso de destinos profundos (≈1500 niveles, < 3 KB) con
   fail-before, y la propiedad es: toda ruta por debajo del límite de entrada recibe una decisión; ninguna mata al
   hook.»
3. **QA-007-01, M0 y MD como límites declarados** (P-136-F, punto 3, y la decisión posterior a `39e68bb`, punto 1;
   literales en el límite 7). QA-007-01 «mantiene la clase `contrato` hasta que QA decida» (misma decisión, punto 2).
4. **El límite sin `CLAUDE_PROJECT_DIR`** (P-136-H (A)) y **QA-007-06 como residual que se repara antes de publicar**
   (P-136-I (B)); ya reparado y cerrado en el paso 5.
5. **SEC-127 sin medir en bash ≤ 5.0 en modo POSIX** (P-136-K (A)), y **O-52-3 a ficha de seguridad** (F-136-7).
6. **Los instrumentos de reloj, como instrumento:** las calibraciones (P-136-E (A): INS-136-1, «no atribuible al
   cambio», y F-136-4); REQ-017 CA-08 (ii) (P-136-M (A), rama «sin escalón»: «se registra como instrumento con las
   cinco cifras, y sigue. … ficha para REQ-017 … se revisa en 1.37, no ahora.»; INS-136-2, F-136-8); y E2 de REQ-017
   CA-09 (P-136-P (1) (A), literal: «QA-007-08 es INS-136-4; F-136-8 se amplía a CA-09; REQ-017 no se reabre.»).
7. **Los techos como cambio de compatibilidad, no como riesgo** (P-136-O (1) (A)), con la ficha para adelgazar
   `REQ-007.md` (F-136-17, 1.37); y el FAIL de la sección 24, observado por QA y registrado como INS-136-3 (P-136-O (2)
   (A)).
8. **QA-007-07 dentro del paso 6, y `BASH_ENV` fuera** (P-136-N (A), texto adoptado: «`BASH_ENV` queda como ficha
   F-136-9»).
9. **QA-007-09 y QA-007-11 (b) como límites declarados** (P-136-P (2) (A), literal: «la pasada correctiva repara
   QA-007-10, QA-007-12 y QA-007-11 (a); QA-007-11 (b) y QA-007-09 quedan como límites declarados con ficha para 1.37.
   Nada más entra.»): F-136-18 y F-136-19.
10. **Una pasada acotada más, con tope, y F-136-20 como límite** (P-136-Q (A), «con tope de una hora y acotada a
    QA-007-13»), y la lista estática completada con los builtins especiales (P-136-R (A), literal: «La lista estática
    cubre los builtins que el hook usa, regulares y especiales (return, exit, break, continue, set, shift, :), retirados
    en modo POSIX; … BASH_FUNC_set%% en guardianes sueltos → F-136-20. Nada más entra; contadores sin reiniciar.»).
11. **SEC-131 y SEC-132 (b) como límites declarados** (P-136-S (1) (A) y (2) (A)): F-136-21, con F-136-20, y F-136-22.
12. **SEC-132 (a): reparar, precisar y, al final, revertir.** P-136-S (1) (A) decidió repararlo en una pasada acotada;
    P-136-T (B) fijó su forma —«la gate en curso se acota al tiempo que queda del plazo», con su cambio de
    compatibilidad—; y P-136-U (A), literal en el límite 1, revirtió `cd63066` y lo dejó como **límite declarado** en
    F-136-22, con las tres lecciones y la nota de 1.35.0. QA-007-15, 16 y 17, cerrados por reversión. La nota del
    propietario es cierta; lo que R-057 abre como SEC-134 es el contraste que algunas sedes añadieron («además»).
13. **Las autorizaciones del cierre** (P-136-S (3), literal): «autorizo el write-back de AGENTS.md §13 y su plantilla
    por el analista, la subida de versión a 1.36.0 en los dos archivos de distribución (arnes_version se conserva en
    1.33.0), y el push de la candidata al terminar; el PR sale de borrador cuando el CI esté en verde. Fusión, tag y
    publicación los decido yo con las notas finales delante.»
14. **Fuera de 1.36.0:** el hueco C, P-119-A (F2, F5, F7) y el mecanismo de SEC-123 («Alcance de 1.36.0…»).
15. **Lo que se publica sin reparar**, por las decisiones de arriba y por lo que sigue abierto: SEC-132 (a) y (b),
    SEC-131, QA-007-09, QA-007-11 (b), F-136-20, QA-007-01 (límites); SEC-133 y SEC-134 (abiertos; [PENDIENTE:
    P-136-V]); SEC-130 (`instrumento`); F-136-5, F-136-7, F-136-9; SEC-030; los heredados del límite 14 y los hallazgos
    del límite 15. **SEC-115, SEC-118 y SEC-129 salen `mitigado`, no reparados sin residuo** (R-056 §10).
16. **SEC-133 y SEC-134:** [PENDIENTE: P-136-V]. La propuesta de la coordinadora, que no es decisión hasta que el
    propietario la adopte: «P-136-V: (A). SEC-133 queda como límite declarado, ficha F-136-23 para 1.37 junto con
    F-136-21/22 y las lecciones L4 y L5 de R-057; la fila «No completar un REQ con quality gates en rojo» de `AGENTS.md`
    §13 y su plantilla se acota a las formas declaradas (SEC-133, SEC-131 (a)). SEC-134 se corrige como texto antes del
    tag. Nada más entra.» (`PENDING_APPROVAL.md`, § Pendientes).

**Quién decide publicar.** El propietario, por su propia letra (P-136-S (3), arriba). La determinación de seguridad
sobre el estado final es **R-057**, literal: «Determinación sobre el estado final del candidato 1.36.0: CONFORME CON
HALLAZGOS, SIN VETO.» —el código es el de R-056, la reversión no deja rastro, los dos hallazgos nuevos son preexistentes
(SEC-133) o de redacción (SEC-134) y «Publicar 1.36.0 no empeora ninguno; retenerla retiene SEC-115/118/120/127/128/129
`mitigado`» (registro, R-057 §7)—. SEC-131 y SEC-132 siguen **abiertos como límites declarados**, no aceptados, con
vencimiento en 1.37 (R-057 §2).

**Lo que devuelve la publicación al propietario** (`AGENTS.md` §4; R-057 §7, «Qué devuelve la publicación al
propietario»): los `contrato` abiertos, que impiden hacerlo por delegación.
- **Del delta:** QA-007-01, QA-007-09, QA-007-11, SEC-131, SEC-132, y los nuevos SEC-133 y SEC-134.
- **Heredados en REQ-007:** QA-114, QA-116, QA-117 y SEC-124.
- **Heredados en otros REQ** (por búsqueda de R-057, **no exhaustiva**; la sede es la lectura de la puerta): REQ-013,
  SEC-014 y SEC-020; REQ-019, SEC-033; REQ-020, SEC-038 a SEC-045; REQ-021, QA-021-10 y QA-021-11.
- **`instrumento` abiertos, que no bloquean cierre:** SEC-130, SEC-123, SEC-125, QA-023-23 y QA-007-08.

---

### Firmas

**Lo que una firma cubre:** la cabeza sobre la que se emitió. Su cobertura sobre la cabeza que se publique se identifica
en el PR del candidato (PR #60, en borrador; `PENDING_APPROVAL.md` § Resueltas, «PR #60 en borrador…»).

**REQ-007 no está firmado.** Su cabecera dice `QA: pendiente` y `Seguridad: pendiente`, y su `Estado:` es
`en-progreso` (`requirements/REQ-007.md`, líneas 2, 8 y 9, en la cabeza `4610004`). Esos dos campos **cubren todo el
REQ**, no esta ventana: QA lo deja pendiente por lo ajeno al delta —los bloques B y C sin rendir y los hallazgos
`contrato` abiertos— y seguridad lo dice en R-056 §9: «la firma no procede: el REQ tiene QA pendiente en su conjunto y
hallazgos `contrato` abiertos». Las revisiones de esta ventana son **determinaciones sobre un delta**, no la firma del
REQ, y así se rotulan en su sede. Estas notas no anticipan ningún cierre.

| Intervención | QA (sede: `docs/qa/REQ-007.md`) | Seguridad (sede: `docs/seguridad/registro-seguridad.md`) |
|---|---|---|
| CA-54 (`82ceb63`) | con hallazgos: QA-007-01 declarado como límite («Décima autorización, fase 3»; re-verificación de `dee5932`, con hallazgos, revertida) | R-052: con hallazgos, sin veto; abre SEC-127 |
| SEC-120 (`413c6bd`) | con hallazgos, en la validación y en la re-verificación («SEC-120: …») | R-053: con hallazgos, sin veto; SEC-120 `mitigado`; abre SEC-128 |
| Paso 5 (`78a2f33`) | código conforme; con hallazgos de contrato (QA-007-06, cerrado después; QA-007-07, nuevo) («Paso 5…») | R-054: registro y clasificación de SEC-129, no determinación; R-055: conforme, sin veto; SEC-127 y SEC-128 `mitigado`; abre SEC-130 |
| Paso 6 (`8e11f87`, `03cbf5e`, `39e6128`) | con hallazgos en las tres: QA-007-08 a 12; QA-007-13; QA-007-14 («Paso 6: validación…», «…re-verificación de la pasada correctiva», «…re-verificación de la pasada acotada de P-136-Q») | — (seguridad va después de QA favorable) |
| Paso 6 (`c5bf6d4`) | **FAVORABLE** («Paso 6: re-verificación de la línea de P-136-R»; evidencia `c4afbde`) | **R-056: conforme con hallazgos, sin veto**; SEC-115, SEC-118 y SEC-129 `mitigado`; abre SEC-131 y SEC-132 |
| SEC-132 (a) (`cd63066`, revertido) | con hallazgos: QA-007-15, 16 y 17 («SEC-132 (a): re-verificación acotada»; evidencia `26f6131`) | — (revertido antes de la revisión de seguridad) |
| Reversión (`986ea6a`) y estado final (`4610004`) | **FAVORABLE**: «No queda ningún hallazgo de QA contra el código de 1.36.0 (`c5bf6d4`).» («P-136-U: comprobación de la reversión») | **R-057: conforme con hallazgos, sin veto**; «Publicar 1.36.0 no empeora ninguno»; abre SEC-133 y SEC-134; evidencia `seg-R057/`, commit `1f73698` |

- R-057 tampoco firma REQ-007: «`Seguridad:` sigue en `pendiente`, con R-057 en su paréntesis» (R-057 §7).
- [PENDIENTE: P-136-V].
- [PENDIENTE: CI sobre la cabeza final].
- Los controles del proveedor que detuvieron una línea de trabajo se registraron y no se reintentaron: los locales
  GB18030 y BIG5 de QA (P-136-F, punto 4), la sonda de `$'…'` (O-54-3), una búsqueda del auditor (O-55-1) y la sonda de
  perfil de SEC-132 (b) (O-56-2).

#### Lo que esta ventana midió sobre sí misma: seis hallazgos de proceso

Los seis son clase `instrumento`, están en `docs/PENDIENTES.md` y ninguno se reparó en esta ventana. Ninguno cambia lo
que el código hace —eso lo juzgan el inventario, el banco, QA y seguridad—; cambian lo que el proceso puede acreditar
de cómo se hizo.
- **Tres ediciones de código protegido o del banco por consola, que ninguna puerta midió** (`AGENTS.md` §13, «La
  invariante manda sobre cualquier preferencia de herramienta»): **PR-136-1**, dos ediciones de `hooks/` con `python3`
  en la fase 2 de CA-54; **PR-136-2**, un `sed -i` sobre la sección 44 del banco en la fase 1 de SEC-120; **PR-136-3**,
  una edición de `hooks/guard-completado.sh` por consola en la fase 2 del paso 6, deshecha y rehecha con `Edit`. Las
  tres del `desarrollador`; PR-136-2 y PR-136-3 las declaró él mismo, y PR-136-1 consta en la entrada del
  `CHANGELOG.md` que la ficha cita.
- **Dos commits de evidencia con el camino de los hooks de git anulado:** **PR-136-4** (`core.hooksPath=/dev/null`) y
  **PR-136-5** (`-c core.hooksPath=`), los dos del `qa-tester` en el árbol de evidencia, declarados por él. La ruta
  configurada no existía en ese repositorio, así que no se saltó ningún hook; aun así es la forma del bypass.
- **Un error de despacho de la coordinadora:** **PR-136-6**, dos comisiones a la vez sobre `requirements/REQ-007.md`,
  contra `AGENTS.md` §6 («dos comisiones que tocan el mismo archivo»). Una línea de la cabecera quedó pegada y la
  cabecera sin `Rigor:`; QA lo detectó y lo reparó, y la coordinadora comprobó la cabecera y el lector antes de
  comitear.
- **Qué lo cerraría:** para las ediciones por consola, la ficha b) de 1.37 (post-condición de filesystem); para el
  despacho, no declarar disjuntas dos comisiones que nombren el mismo archivo —`tools/arnes-paralelo.sh` compara REQ,
  no comisiones—.

---

### Hacia 1.37.0

**Las fichas del propietario, tal como las dejó** (`docs/PLAN.md` § «1.37.0 — fichas registradas»; literales en
`PENDING_APPROVAL.md` § Resueltas, «Resumen del plan vigente de 1.36.0…», 2026-10-06). Se juzgan contra el objetivo
rector del arnés (`docs/PLAN.md` § «Objetivo rector del arnés»). **No se construyen en 1.36.0.**

> a) Plan de desarrollo (docs/PLAN.md como fuente; la coordinadora continúa
>    sola salvo gates; línea derivada en ESTADO).
> b) Post-condición de filesystem (foto antes / comparación después /
>    reversión; hueco C pasa de límite a detección).
> c) Adelgazamiento: roles, gates y tabla §13 a .arnes/config.json; AGENTS.md
>    a la mitad; historia a docs/; rigor proporcional como regla por
>    defecto; analista en modelo más barato y /compact entre fases.
> d) Spike «ArnesJuan como mod»: guard-git como mod medido contra el banco.
> e) 2b de CA-54 (QA-007-01, recursión), push de candidata por el agente,
>    límite declarado de mods (un mod de usuario puede aprobar lo que las
>    puertas niegan; mitigación allowManagedModsOnly).

**Detalle de e), de `docs/PLAN.md`:** «la **2b de CA-54**: las formas de QA-007-01 (casos M y N, proyecto sin globs de
código, desarrollador con el primer destino en código, M0 y MD medidos en anfitrión sano antes de optimizar) y la
recursión sin tope de la lectura léxica (F-136-5, con el caso de banco de destinos profundos primero).»

**Fichas registradas con destino 1.37, rotuladas como tales** (`docs/PENDIENTES.md`; no son fichas a–e del
propietario, aunque varias caen dentro de ellas):
- **F-136-6**, la 2b, y **F-136-5**, la recursión (dentro de e));
- **F-136-22**, SEC-132 (a) y (b), con las tres lecciones de diseño, más L4 y L5 de R-057 §3;
- SEC-133, si el propietario lo declara para 1.37: [PENDIENTE: P-136-V y la ficha F-136-23];
- **F-136-20**, el estado heredado que sólo la orden de `hooks/hooks.json` puede neutralizar, que agrupa **F-136-9**
  (`BASH_ENV`) y **F-136-19** (QA-007-11 (b)); y **F-136-21**, SEC-131, la frontera de confianza del entorno del host,
  con la lista blanca del entorno que propone el auditor (R-056 §3 y §6);
- **F-136-18**, QA-007-09 (un techo sobre el disco o una normalización lineal del CRLF);
- **F-136-12**, SEC-130;
- **F-136-17**, adelgazar `REQ-007.md`;
- **F-136-8**, las tres sondas de reloj de REQ-017 (CA-03, CA-08 (ii) y CA-09);
- **candidatas:** F-136-14 (la rotación del CHANGELOG sin aviso), F-136-15 (el bloque derivado de `docs/ESTADO.md`) y
  F-136-16 (el nombre de un caso que depende del PID).

**Sin ventana:** F-136-4 («para después»), F-136-7 (O-52-3, la clasifica el auditor) y F-136-1 a F-136-3. Y una
propuesta del auditor sin ficha, para proponerse antes de hacerse: que la trampa salga además con código 2 y el motivo
en la salida de errores, un canal de bloqueo que no depende de la salida estándar (R-056 §2).

*(1.38.0: fichas f–i en `docs/PLAN.md` § «1.38.0 — fichas registradas».)*

---

### Historia

**Una línea por commit de código**, en el orden del `CHANGELOG.md`, con la entrada que lo registra. No se reescribe
nada. Cada cifra es de la cabeza que nombra. La lista exacta, para contrastarla: [PENDIENTE: `git log --first-parent
v1.35.0..<cabeza final> -- hooks/ tools/ tests/ .claude-plugin/`].

| Commit | Qué trae | ¿En 1.36.0? | Registro (`CHANGELOG.md`) |
|---|---|---|---|
| `82ceb63` | CA-54: análisis de `Bash` en el máximo por debajo de 5 s (35/35, máx. 3 711 ms según el desarrollador; 4 513 ms según QA) con las mismas decisiones; atajo de `guard-completado` readmitido por P-136-D | sí | «Décima autorización, fase 2 (CA-54)…» |
| `dee5932` | Pasada correctiva de QA-007-01; introduce QA-007-02 (recursión sin tope, SIGSEGV) | **no: revertido** | «Décima autorización: pasada correctiva de QA-007-01 comiteada…» |
| `74da4c5` | Revert del código de `dee5932` por P-136-F; `hooks/` = `82ceb63` | sí (lo deshace) | «Revert del código de `dee5932` por P-136-F…» |
| `6759a8e` | SEC-120, fase 1: 28 casos del banco con fail-before, sin reparar | sí (banco) | «SEC-120, fase 1 hecha por el desarrollador en `6759a8e`…» |
| `aba1c9b` | SEC-120, fase 2: una entrada que `jq` no puede leer o trocear no pasa | sí | «Intervención 2 (SEC-120), fase 2…» |
| `413c6bd` | SEC-120, pasada correctiva única: QA-007-03 (entrada vacía o con NUL) y QA-007-04 (`false` en `file_path` o en `command`) | sí | «SEC-120, pasada correctiva única…» |
| `ab52c9b` | Paso 5, fase 1: casos de QA-007-06 con su fail-before, sin reparar | sí (banco) | «Paso 5, fase 1 (`ab52c9b`, SIN VALIDAR)…» |
| `a59917d` | Paso 5, fase 2: SEC-127 (locale sin asignación delante de una función) y QA-007-06 (`read` fallido → ilegible) | sí | «Paso 5 (SEC-127 y QA-007-06), fase 2…» |
| `78a2f33` | SEC-128: en `guard-codigo`, un `file_path` que no es texto no deja pasar a nadie | sí | «Paso 5, SEC-128 (P-136-J (A, acotada))…» |
| `738b74d` | Paso 6, fase 1: 93 casos de SEC-118, SEC-115 y SEC-129 con fail-before, sin reparar | sí (banco) | «Paso 6, fase 1 registrada (`738b74d`…)…» |
| `0efd3c2` | Paso 6, fase 2: SEC-118 (motivo por la entrada estándar, acotado a 16 384 bytes), SEC-115 (plazo, techos y trampa) y SEC-129 (`hooks/entrada.sh`, R1 y R2) | sí | «Paso 6, fase 2 (desarrollador)…» |
| `8e11f87` | QA-007-07: las marcas de «ya leído» de `lib.sh` no se heredan del entorno | sí | «Paso 6 (desarrollador): QA-007-07…» |
| `03cbf5e` | Pasada correctiva única del paso 6: QA-007-10, QA-007-12 y QA-007-11 (a); introduce QA-007-13 | sí | «Paso 6, pasada correctiva (desarrollador)…» |
| `39e6128` | P-136-Q: QA-007-13, la limpieza de `entrada.sh` ya no se puede suplantar; introduce QA-007-14 | sí | «Paso 6 (desarrollador): QA-007-13…» |
| `c5bf6d4` | P-136-R: QA-007-14, los builtins especiales entran en la lista estática de `entrada.sh`. **Es el código de 1.36.0** | sí | «Paso 6 (desarrollador): QA-007-14…» |
| `cd63066` | P-136-S/T: SEC-132 (a), el plazo dentro de las quality gates (`arnes_corta_gate`); introduce QA-007-15, 16 y 17 | **no: revertido** | «Paso 6 (desarrollador): SEC-132 (a)…» |
| `b43d7ea` | Versión 1.36.0 en `.claude-plugin/plugin.json` y `marketplace.json`; `arnes_version` sigue en 1.33.0 | sí (distribución) | «Candidato 1.36.0: versión en los dos archivos de distribución» |
| `986ea6a` | Revert del código de `cd63066` por P-136-U; `hooks/` y `tests/` = `c5bf6d4` | sí (lo deshace) | «Revert del código de cd63066 por P-136-U…» |

**La certificación de una cabeza es la corrida que se ejecutó sobre ella, y nada más amplio.** Ningún CI verde
acredita rendimiento, conducta ni ahorro (notas `[1.35.0]`, «Historia»).
