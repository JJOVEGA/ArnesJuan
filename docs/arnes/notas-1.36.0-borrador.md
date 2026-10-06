# BORRADOR — notas de versión `[1.36.0]`

> **Esto es un borrador y no es la entrada del CHANGELOG.** Lo escribió el `analista-requerimientos` el 2026-10-06,
> por encargo de la coordinadora (paso 7 del plan de 1.36.0, adelantado en lo que no depende de la validación). Al
> cerrar, la coordinadora lo copia a la entrada `[1.36.0]` de `CHANGELOG.md`. Se leyó del disco del worktree
> `ArnesJuan-v1.36` (rama `cand/1.36.0`). **El analista no tuvo acceso a `git` en esta comisión:** los commits se
> citan por las entradas del `CHANGELOG.md` y por las sedes que los nombran, no por `git log`.
>
> **Los huecos van marcados `[PENDIENTE: …]`** y no se rellenan por adelantado. Ningún veredicto que no esté escrito
> en su sede se afirma aquí.
>
> **Regla que este borrador no puede saltarse** (REQ-007 CA-69, punto 5): las sedes de la promesa —entre ellas estas
> notas— cambian «sólo cuando esté construido y validado, y sólo hasta lo medido». Lo del paso 6 está construido y
> **sin validar**: aquí se describe como tal y en ningún sitio dice «reparado».

---

## [1.36.0] — [PENDIENTE: fecha de publicación] · Una puerta que no puede leer, terminar o emitir su juicio deja de dejar pasar: entrada ilegible, motivo acotado, plazo propio y techos de tamaño, y el modo del intérprete heredado deja de apagar las puertas de `Bash`; y el análisis de `Bash` en el máximo baja de 5 s, con cuatro formas fuera como límite declarado

> Origen: [PENDIENTE: GitHub (commit de versión)] · usuario: Juan · modelo de IA: [PENDIENTE] · agente: [PENDIENTE] ·
> gobernado por la instalación estable **1.35.0** (`docs/ESTADO.md`, bloque vigente, punto «1.35.0 publicada»).

**Estas notas no publican nada.** Fusionar, etiquetar y publicar son del propietario (`docs/PLAN.md` § 1.36.0, paso 7:
«Fusión, tag y publicación: propietario»). La cabeza que se publique tendrá su propia corrida de CI, y estas notas no
afirman su resultado por adelantado: [PENDIENTE: CI sobre la cabeza final].

**De dónde salen.** Las decisiones del propietario están literales en `PENDING_APPROVAL.md` § Resueltas:
- «Alcance de 1.36.0 y apertura de la ventana» (2026-10-03, «Encargo 2»);
- la décima autorización (2026-10-03), con P-136-A, P-136-B y P-136-C;
- P-136-D a P-136-O (2026-10-05 y 2026-10-06), el «Ajuste de alcance de 1.36.0» (2026-10-05), los tres puntos de
  SEC-120 (2026-10-05) y el «Resumen del plan vigente» (2026-10-06).

El contrato vive en `requirements/REQ-007.md` (nota de CA-54 del 2026-10-03, CA-47 punto 20, CA-67 a CA-69) y en
[ADR-017](../decisions/ADR-017-la-puerta-que-no-puede-leer-terminar-o-emitir-no-deja-pasar.md).

**Cómo están ordenadas** (calcado de las notas `[1.35.0]`):
- **Qué cambia:** por intervención, qué recibe un consumidor, los cambios de compatibilidad y Semver.
- **Límites declarados, con alcance y consecuencia.**
- **Lo no medido: el host y Windows/MSYS.**
- **Decisiones de riesgo del propietario.**
- **Firmas.**
- **Hacia 1.37.0.**
- **Historia.**

---

### Qué cambia

**Los cambios de compatibilidad, en una línea cada uno** (detalle y decisión citada, en «Cambios de compatibilidad»,
abajo). En todos el movimiento va **hacia `deny`**; ninguno pasa de `deny` a `allow` (REQ-007 CA-69, punto 3, y
CA-24):
1. Una entrada del hook que no es exactamente un objeto JSON, o que no se puede leer, se deniega (SEC-120).
2. Un valor de `tool_input` que la puerta necesita y no puede trocear como texto —también `false`— se deniega.
3. En `guard-codigo`, un `file_path` que no es texto se deniega también al agente de código (SEC-128).
4. Dos techos de tamaño deniegan llamadas legítimas sobre un REQ muy grande (P-136-O). *Construido, sin validar.*
5. El motivo de una denegación y el texto de un aviso salen acotados a 16 384 bytes. *Construido, sin validar.*
6. Un juicio que agota el plazo propio del hook se deniega, también el legítimo. *Construido, sin validar.*
7. Con el modo POSIX heredado del entorno, la vía `Bash` de las tres puertas vuelve a decidir, y un final que no es un
   juicio concluido deniega (SEC-129). *Construido, sin validar.*

*(El 6 lo añade el analista a la lista del encargo: CA-68 y CA-69, punto 3, lo declaran.)*

#### Por intervención: lo construido y lo que no

El orden es el del propietario (`docs/PLAN.md` § 1.36.0, «Orden final de 1.36.0»; literal en `PENDING_APPROVAL.md`
§ Resueltas, «Ajuste de alcance de 1.36.0»).

- **Intervención 1 — CA-54 / QA-023-10 (candidato `82ceb63`).** *Cerrada como intervención* (`docs/PLAN.md` § 1.36.0,
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
  - **Recursión:** `82ceb63` da `deny` y rc 0 hasta 2 040 niveles, con tres tamaños de pila (R-052, citado en
    `CHANGELOG.md`, entrada «Décima autorización, fase 4…»). La pasada correctiva `dee5932`, que introducía una
    recursión sin tope (QA-007-02), se **revirtió** en `74da4c5`, con `hooks/` igual a `82ceb63` (P-136-F, punto 1).
  - **Lo que no:** QA-007-01 —cuatro formas que pueden tardar 5 s o más— sale como **límite declarado** (abajo). La
    segunda pasada (la «2b») sale a 1.37 (abajo, «Decisiones de riesgo»).
  - **Firmas de la intervención:** QA «con hallazgos: QA-007-01 declarado como límite»; seguridad R-052 «con hallazgos,
    sin veto», que abrió SEC-127 (`docs/ESTADO.md`, bloque vigente; registro, R-052 §6).

- **Pasos 1 a 4 — SEC-120 (candidato `413c6bd`).** *Cerrada como intervención; SEC-120 `mitigado` en el candidato*
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
  - **Firmas de la intervención:** QA «con hallazgos» (QA-007-06 como residual, P-136-I); seguridad R-053 «con
    hallazgos, sin veto», SEC-120 `mitigado`, SEC-128 abierto (registro, R-053 §6 y §7).
  - **Vencimiento:** el de SEC-120, 2026-10-29, se refiere a la reparación; llega a los proyectos sólo al publicar.

- **Paso 5 — SEC-127, QA-007-06 y SEC-128 (código de `a59917d` y `78a2f33`).** *Cerrado como intervención*
  (`CHANGELOG.md`, entrada «Paso 5: commit validado…»).
  - **SEC-127:** el atajo de `guard-completado` ya no cambia el locale con una asignación delante de una llamada de
    función: guarda `LC_ALL`, lo pone en C y lo restaura con sentencias sueltas, sin subshell y sin procesos
    (`a59917d`; `CHANGELOG.md`, entrada «Paso 5 (SEC-127 y QA-007-06), fase 2…»). Seguridad: no queda ninguna
    asignación de ese tipo en el proceso que juzga; «la reparación elimina la premisa de versión por construcción»
    (registro, R-055 §2).
  - **QA-007-06:** un `read` fallido de la entrada —la entrada estándar cerrada, entre otras causas— deja la entrada
    vacía, que es ilegible, y recibe `deny` en los cuatro guardianes (REQ-007 CA-47 p. 20, «Reparado en SEC-127…»).
  - **SEC-128:** en `guard-codigo`, un `file_path` que no es texto deniega a todo agente, también al agente de código,
    en `Edit`, `Write` y `MultiEdit` (`78a2f33`; REQ-007 CA-47 p. 20, subviñeta SEC-128). Por `guard.sh` no cambia
    ninguna decisión: `guard-completado` ya lo denegaba (R-053 §4).
  - **Medido:** sección 47, 44/0, con su fail-before; R-055: `LC_ALL` restaurado en 24 combinaciones y la condición
    nueva de `guard-codigo` en `deny` en 72 (`CHANGELOG.md`, entrada «Paso 5: commit validado…»).
  - **Firmas de la intervención:** QA «código conforme; con hallazgos de contrato» (QA-007-06 pendiente de su
    write-back, ya cerrado; QA-007-07 nuevo y preexistente) (`docs/qa/REQ-007.md`, «Paso 5…», «Veredicto» y nota del
    2026-10-06). Seguridad R-055 «conforme, sin veto»: SEC-127 y SEC-128 `mitigado` en el candidato; SEC-130 abierto
    (`instrumento`, baja) (registro, R-055 §7 y §9).

- **Paso 6 — SEC-118, SEC-115 y SEC-129, más QA-007-07 (código de `0efd3c2` y [PENDIENTE: commit de QA-007-07]).**
  *Construido y medido por el desarrollador; **SIN VALIDAR por QA ni por seguridad*** (REQ-007 CA-67 y CA-68,
  «Estado»).
  - **SEC-118 (CA-67):** el motivo de una denegación y el texto de un aviso viajan a `jq` por la entrada estándar y se
    acotan a **16 384 bytes** (`ARNES_MOTIVO_MAX_BYTES`, operativo), conservando el comienzo, con una nota de que se
    acortó y sin partir un carácter UTF-8. Según el desarrollador: 273 casos de tope, ninguno mal; sección 47, D 9 + 2
    controles y A 6, todos conformes (REQ-007 CA-67, «Estado»).
  - **SEC-115 (CA-68):**
    - plazo propio: **30 s** (`ARNES_PLAZO_S`), comprobado sin procesos entre unidades de trabajo, para que la
      respuesta llegue en **no más de 40 s** (el plazo de P-136-C);
    - dos techos: piezas de la escritura, **393 216 bytes** (`ARNES_PIEZAS_MAX_BYTES`), y presupuesto de búsqueda de
      `old_string`, **2³²** (`ARNES_EDIT_MAX_BUSQUEDA`), los dos operativos;
    - según el desarrollador, T1, T2a, T2b y T3 dan `deny` en 4,3, 0,6, 0,4 y 2,7 s (REQ-007 CA-68, «Estado»).
  - **SEC-129 (CA-68 (i) y (ii)):** `hooks/entrada.sh`, nuevo, sale del modo POSIX al arrancar (R1), arranca el reloj
    y arma una trampa que emite un `deny` fijo si el proceso termina sin juicio; una puerta abandonada a mitad o un
    código del analizador fuera de su vocabulario deniegan (R2). Según el desarrollador: las 40 filas de `Bash` en modo
    POSIX en `deny`, los 32 controles sin cambio y +0 procesos en el camino común (REQ-007 CA-68, «Estado»).
  - **QA-007-07 (CA-68 (ii), P-136-N (A)):** las variables `ARNES_INPUT_LISTO` y `ARNES_MANIFEST_LISTO` heredadas del
    entorno dejan de apagar las puertas. [PENDIENTE: commit de QA-007-07 y su medida, un caso de banco por variable].
  - **CA-68 frente a REQ-017 CA-09** (CA-69, punto 7): E1–E3 medidos por el desarrollador, resultado «no afecta»
    (E2: 12 de 12 PASS). Sin validar.
  - **Banco del worktree según el desarrollador:** 2 290/0/13; autoprueba 117/0; gates rc 0 (`CHANGELOG.md`, entrada
    «Paso 6, fase 2 (desarrollador)…»).
  - **Lo que no:** SEC-130 **no** queda cubierto por R2 por construcción, según el desarrollador (REQ-007 CA-69,
    punto 7, «SEC-130, por lectura del desarrollador»); la comprobación es de QA: [PENDIENTE: QA paso 6].
  - [PENDIENTE: QA paso 6] — incluida la observación del FAIL de la sección 24 (P-136-O (2) (A)): hallazgo si lo
    reproduce, INS-136-3 si no.
  - [PENDIENTE: seguridad paso 6] — reclasificación de SEC-115, SEC-118 y SEC-129 (y de SEC-130 si R2 lo cubre).

**Sin cambiar ningún hook:** la plantilla `templates/autorizacion.md` (décima autorización; `CHANGELOG.md`, entrada
«Décima autorización, fase 0…»), con la regla de parada afinada por P-136-E.

#### Qué recibe un consumidor al actualizar

**Con el plugin, sin migrar nada.** Actúa desde que se actualiza. Lista según las sedes; la lista exacta de archivos
es [PENDIENTE: `git diff --stat v1.35.0..<cabeza final> -- hooks/ tools/ templates/ skills/`]:
- `hooks/lib.sh`: CA-54 (análisis único, tokens en C sobre ASCII, atajo), SEC-120, SEC-127, QA-007-06, el motivo
  acotado, el plazo, los techos y R2.
- `hooks/entrada.sh` (**nuevo**): R1, el arranque del plazo y la trampa de salida. Lo cargan `guard.sh` y, cuando se
  ejecutan por su cuenta, los tres guardianes (REQ-007 CA-68, «Estado»).
- `hooks/guard.sh`, `hooks/guard-codigo.sh`, `hooks/guard-completado.sh` y `hooks/guard-git.sh`: la carga de
  `entrada.sh`, la marca de puerta terminada y, en `guard-codigo` y `guard-completado`, el código no declarado del
  analizador (R2); en `guard-codigo`, SEC-128; en `guard-completado`, el atajo de CA-54.
- `tools/arnes-lectura.sh`: comparte `lib.sh` con los hooks (P-136-O, contexto del punto (2)).
- `templates/autorizacion.md` (**nuevo**): no migra nada por sí sola (guía, «Hacia 1.36.0», primera entrada).
- La guía `arnes-upgrade`, § «Hacia 1.36.0»: hoy tiene cuatro entradas —la plantilla, el límite de QA-007-01, lo no
  medido de SEC-127 y el cambio de compatibilidad de los techos—. [PENDIENTE: entradas de la guía para los cambios
  1, 2, 3, 5, 6 y 7, que hoy no tiene].
- [PENDIENTE: si `hooks/hooks.json` cambia; ninguna sede de esta ventana dice que cambie, y F-136-9 lo deja sin
  ventana en 1.36.0].

**Sólo si el proyecto migra con `arnes-upgrade`.** [PENDIENTE: write-back de las sedes de la promesa tras validar,
REQ-007 CA-69, punto 5]: hoy `AGENTS.md` §13 —la cláusula 1 de los límites y la fila de los hallazgos—,
`templates/AGENTS.md.tpl` y `requirements/README.md` § «Clases de hallazgo» **siguen declarando SEC-115 y SEC-118
como limitaciones conocidas y sin reparar**, y así deben seguir hasta que QA y seguridad validen el paso 6.

**Un proyecto que actualiza el plugin y no migra** tendrá la puerta nueva con el texto viejo, como en 1.35.0. [PENDIENTE:
confirmar, cuando exista el write-back, qué sedes cambian].

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
   sobre él se deniega.** *Construido en `0efd3c2`, sin validar.* Norma: REQ-007 CA-68, «Techos de tamaño», «Cambio de
   compatibilidad declarado…», y CA-69, punto 3.
   - **Decisión del propietario (P-136-O (1) (A), texto adoptado):** «los techos de tamaño (`ARNES_PIEZAS_MAX_BYTES` =
     393 216 y `ARNES_EDIT_MAX_BUSQUEDA` = 2³²) quedan como **cambio de compatibilidad declarado** …».
   - **Texto de la guía** (`skills/arnes-upgrade/SKILL.md`, «Hacia 1.36.0», tercera entrada de límites; copiado):
     Para que un hook que no termina de juzgar a tiempo no deje pasar, `guard-completado` mide el tamaño antes de las
     operaciones que crecen más que linealmente, y deniega a todo agente por encima de dos techos. **(1)** El `Write`
     de un REQ cuyo `content` pasa de unos **393 216 bytes** (el techo cuenta el texto troceado: el `content` más
     4 bytes, sin el salto final; medido, 393 213 bytes pasan y 393 214 deniegan) **se deniega**: un REQ de ese tamaño
     no se escribe entero de una vez. **(2)** Un `Edit` cuyo producto (bytes del documento más los de los
     `new_string`) × (bytes de los `old_string`) pasa de **2³²** **se deniega**; en un `MultiEdit` cuentan todas sus
     ediciones. La frontera depende del tamaño del REQ: sobre uno de 660 431 bytes, un `old_string` de 3 000 a
     6 400 bytes pasa y uno de 7 000 o más deniega. **Consecuencia y salida:** con 1.35.0 esas llamadas salían sin
     decisión; ahora el motivo del `deny` lo dice y dice cómo salir: edita el REQ por fragmentos con `Edit`, usa un
     `old_string` más corto —basta con el trozo que identifica el sitio— o parte la edición en varias llamadas. Los
     REQ por debajo de esos tamaños no cambian (medido: un `Write` de 296 973 bytes sigue igual). Medido en
     Linux/WSL2, una corrida por punto; Windows/MSYS y el host, sin medir.
   - **Caso legítimo medido** (REQ-007 CA-68, misma viñeta): el `Write` de `REQ-007.md` entero, 660 431 bytes, salía
     sin decisión en 11,5 s con v1.35.0 y sale con `deny` en el candidato.
   - **Dirección admitida:** las cifras son operativas; bajarlas es cambio menor con su Historial, y **subirlas queda
     fuera**: «el propietario no eligió las opciones (B) ni (C) de P-136-O» (REQ-007 CA-68, misma viñeta).
   - **El síntoma**, un REQ de 660 KB, va a F-136-17, para 1.37 (abajo).
5. **SEC-118: el motivo y el aviso salen acotados a 16 384 bytes.** *Construido en `0efd3c2`, sin validar.* Norma:
   REQ-007 CA-67.
   - **Decisión del propietario (P-136-B, literal):** «criterio por propiedad: toda denegación decidida llega al
     cliente, entera o acotada, nunca perdida; el desarrollador elige la técnica; los avisos entran.»
   - **Qué cambia para quien lee la salida:** un motivo o un aviso de más de 16 384 bytes llega cortado, con su
     comienzo —que nombra la causa— y la nota «[...] (ARNES: motivo acortado: medía N bytes y el tope es 16384; se
     conserva su comienzo)» (REQ-007 CA-67, «Estado»). En v1.35.0, por encima del límite de un argumento, no llegaba
     **nada** y el hook salía sin decisión (SEC-118). **La decisión no cambia** por acotar; lo que cambia es el texto.
6. **SEC-115: un juicio que agota el plazo propio se deniega, también el legítimo.** *Construido en `0efd3c2`, sin
   validar.* Norma: REQ-007 CA-68, «Un plazo propio del hook de 40 s», y CA-69, punto 3.
   - **Decisión del propietario (P-136-C, literal):** «techos de tamaño más plazo propio de 40 s, sin procesos.»
   - **Qué deja de pasar:** «Lo legítimo que agote el plazo se deniega igual, a todo agente» (CA-68). Construido con
     el plazo en 30 s para responder en no más de 40 s.
   - **Lo que no hay en las sedes:** ninguna llamada legítima medida que agote el plazo. El plazo vencido «sólo está
     demostrado en una copia con `ARNES_PLAZO_S=1`», y no alcanza a una quality gate en curso, porque se comprueba
     antes de lanzarla (REQ-007 CA-68, «Estado»).
7. **SEC-129: con el modo POSIX heredado, la vía `Bash` vuelve a decidir; y un final que no es un juicio deniega.**
   *Construido en `0efd3c2`, sin validar.* Norma: REQ-007 CA-68, partes (i) y (ii); ADR-017, notas posteriores del
   2026-10-06.
   - **Decisión del propietario (P-136-L (A), literal):** «Revisión corta de seguridad ahora, para fijar qué apaga
     exactamente POSIXLY_CORRECT=1 y desde cuándo (también en v1.35.0: no es regresión); la reparación va dentro de
     SEC-115/118, que ya trata «el hook siempre emite decisión».» Y P-136-N (A), texto adoptado: «ninguna decisión del
     hook depende de nada que herede del entorno (modo del intérprete, variables `ARNES_*`; `BASH_ENV` queda como
     ficha F-136-9). Caso de banco para cada variable. Nada más entra.»
   - **Qué cambia:** con `POSIXLY_CORRECT` exportada (también vacía), `SHELLOPTS` con `posix`, un `BASH_ENV` que hace
     `set -o posix` o `bash --posix`, la vía `Bash` de `guard-codigo`, `guard-completado` y `guard-git` salía **sin
     decisión** para toda llamada —también el git destructivo—, medido desde v1.30.3 (registro, R-054 §1 y §2). Ahora
     recibe la misma decisión que en modo normal: `deny` donde el modo normal deniega, y `ls -la` sigue sin decisión.
     Un error del intérprete, una puerta abandonada o un código del analizador fuera de su vocabulario deniegan.
   - **Para un consumidor:** si su entorno exporta `POSIXLY_CORRECT` —una variable estándar que algunos usuarios
     exportan, según R-054 §3, «Lectura de amenaza»—, dejará de ver pasar sin decisión escrituras por shell a código
     protegido, cierres por shell y git destructivo. **Sobre lo legítimo no se espera movimiento**, porque (ii) exige la
     misma decisión que sin ese estado (ADR-017, nota posterior SEC-129, «Consecuencias»).
   - **QA-007-07**, la misma propiedad: `ARNES_INPUT_LISTO` o `ARNES_MANIFEST_LISTO` heredadas pasan de «sin
     decisión» a la decisión que reciben sin ellas; «es protección, no compatibilidad» (REQ-007 CA-69, punto 3).
     [PENDIENTE: commit de QA-007-07].

#### Semver: `minor` por la convención de este arnés

El número `1.36.0` es el de la ventana que abrió el propietario («Encargo 2 — Apertura de v1.36.0», `PENDING_APPROVAL.md`
§ Resueltas, «Alcance de 1.36.0…»). **En SemVer estricto no es `minor` pura:** los cambios 3, 4 y 6 deniegan
llamadas que v1.35.0 dejaba pasar sin esconder ningún bloqueante —sobre todo el 4, medido sobre un REQ legítimo—, y
el 5 cambia el texto que recibe el cliente. Aplicada a la letra, esa regla pediría una versión mayor.

La convención de este arnés publica como `minor` o `patch` los cambios que cierran un fail-open de la puerta, aunque
hagan denegar lo que antes pasaba, y declara una por una las incompatibilidades que no esconden nada (notas `[1.35.0]`,
«Semver»). Por eso van **declaradas arriba, una por una**. Si el propietario prefiere SemVer estricto, la versión
sería `2.0.0`, y esa decisión es suya.

[PENDIENTE: subida de `1.35.0` a `1.36.0` en los tres campos de distribución —`.claude-plugin/plugin.json` `.version`
y `.claude-plugin/marketplace.json` `.metadata.version` y `.plugins[0].version`—, comprobada con `jq`].

---

### Límites declarados, con alcance y consecuencia

**«Límite declarado» no es «riesgo aceptado», y declarar no repara.** Lo que sigue se publica abierto. **SKIP e
INCONCLUSO no acreditan** (decisión 7 de 1.35.0; REQ-007 CA-69, punto 2 (c)).

1. **QA-007-01: el análisis de `Bash` en el máximo puede tardar 5 s o más con cuatro formas** (REQ-007, nota de CA-54,
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
     garantía: en un equipo más lento o más cargado, el hook podría agotar el tiempo, y eso es la clase de SEC-115.
     Windows/MSYS, sin medir.
   - **Reparación:** la 2b, que sale a 1.37 (abajo, «Decisiones de riesgo»). QA-007-01 sigue en `Hallazgos abiertos:`
     de REQ-007 con su clase `contrato`.
2. **SEC-127: la corrección en bash 5.0 o anterior en modo POSIX, no medida** (REQ-007 CA-47 p. 20, «SEC-127 — cómo
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
3. **Sin `CLAUDE_PROJECT_DIR`, el hook es inerte cuando no obtiene el proyecto** (REQ-007 CA-47 p. 20, «Límite
   declarado…»; P-136-H (A), literal arriba, cambio 1).
   - **Consecuencia:** una entrada ilegible sin esa variable de la que no se obtiene un proyecto **no recibe `deny`**
     de este hook. Que el host fije siempre la variable está «observado y **no verificado**».
4. **SEC-130 (`instrumento`, baja): abierto.** El atajo de `guard-completado` afirma «el comando no menciona el estado
   terminal» sin comprobarlo si la redirección de su grupo falla; medido a nivel de librería, **no alcanzado a nivel de
   hook** en lo medido, y ninguna decisión cambia (registro, R-055 §4). Lo introduce `a59917d`.
   - **Destino:** ficha F-136-12, para 1.37, si R2 no lo cubre (REQ-007 CA-69, punto 7). Según el desarrollador, no lo
     cubre. [PENDIENTE: QA paso 6, la comprobación de si R2 lo cubre por construcción].
   - **Efecto sobre la publicación:** «no bloquea **cerrar**. Abierto, devuelve **publicar** al propietario» (R-055 §7).
5. **`BASH_ENV` con otro contenido que `set -o posix`: fuera de la propiedad** (REQ-007 CA-68, «Fuera de esta
   propiedad»; ficha F-136-9; observación O-54-1). Corre antes de la primera línea del hook y no se neutraliza desde
   dentro; sólo se podría en la orden de `hooks/hooks.json`. Sin ventana en 1.36.0.
6. **O-52-3: con `LC_ALL=C` en el entorno desde el arranque, el cierre por `Bash` con `TERMINÉ`/`terminé` sale sin
   decisión, también en v1.35.0** (ficha F-136-7; REQ-007 CA-47 p. 20, «Fuera de este criterio»). Sin clase asignada:
   la clasifica el auditor. Sin ventana en 1.36.0 (P-136-K: «O-52-3 pasa a ficha de seguridad»).
7. **Lo que CA-68 no puede prometer** (REQ-007 CA-68, «Lo que esta propiedad no puede prometer»): si el cliente mata
   el proceso, nada que el hook haga deniega; y sin un proceso aparte, una sola operación que se bloquea por dentro no
   se interrumpe: el plazo se comprueba entre unidades de trabajo.
8. **SEC-115 y SEC-118 siguen declarados como limitaciones** en `AGENTS.md` §13 y en `requirements/README.md` §
   «Clases de hallazgo» hasta que se valide el paso 6 (REQ-007 CA-69, punto 5). [PENDIENTE: QA paso 6] y [PENDIENTE:
   seguridad paso 6] deciden qué dicen esas sedes al publicar.
9. **Heredados de 1.35.0, fuera de 1.36.0 por decisión del propietario** («Alcance de 1.36.0…», literal: «Fuera de
   alcance: hueco C, P-119-A (F2/F5/F7), SEC-123 mecanismo.»): siguen **abiertos y no aceptados como riesgo**, con su
   descripción en las notas `[1.35.0]`, «Límites declarados»:
   - **el hueco C:** las escrituras por intérpretes o scripts no se detectan. La ficha b) de 1.37 propone convertirlo
     en detección (abajo);
   - **P-119-A (F2, F5, F7) y SEC-123.**
10. **Otros hallazgos que siguen en `Hallazgos abiertos:` de REQ-007** (cabecera, línea 10; lista leída del disco, sin
    juzgarla): QA-114, QA-116, QA-117, QA-023-10, SEC-123, SEC-124, SEC-125, QA-023-23, QA-007-01, QA-007-07,
    SEC-129 y SEC-130. [PENDIENTE: QA paso 6 y seguridad paso 6, sobre QA-007-07 y SEC-129].
    - *Nota del analista, sin resolver:* QA-023-10 sigue en ese campo con su texto de 1.35.0 («la optimización se
      detuvo por el propietario y quedó fuera del candidato»), mientras `docs/PLAN.md` da CA-54 por cerrada en
      `82ceb63`. Cambiar ese campo es de quien firmó el hallazgo; estas notas no lo dan por cerrado.
11. **Ruido de instrumento, sin reparar** (`docs/PENDIENTES.md`): INS-136-1 (la calibración de `sonda-reloj.sh` sale
    fuera de banda; F-136-4), INS-136-2 (REQ-017 CA-08 (ii) oscila alrededor de su techo de 1,25× en los cinco
    commits medidos; F-136-8) y F-136-16 (el nombre de un caso de la sección 43 depende del PID). Un inventario puede
    diferir en esos casos sin que cambie el código.
12. **Fronteras de SEC-120 que no se contratan** (registro, R-053 §5): O-53-1, un `tool_name` que no es texto sale sin
    decisión en v1.35.0 y en el candidato; queda fuera de la letra del punto 20 y el `matcher` lo hace inalcanzable
    desde el host.

---

### Lo no medido: el host y Windows/MSYS

**La regla, la de 1.35.0:** una conducta está medida sólo en la capa y la plataforma en que se ejecutó su caso. Las
listas son **no exhaustivas**, y que algo no aparezca **no lo hace medido**.

- **Medido:** a nivel de hook en Linux/WSL2, bash 5.3.9 (las sedes de cada intervención, arriba).
- **El host (`claude -p`):** no ejercido para nada de 1.36.0 en las sedes leídas. «No comprobado en el host» en cada
  criterio: CA-47 p. 20 («No acredita»), CA-67, CA-68 y CA-69, punto 4. [PENDIENTE: si la coordinadora ejerce el host
  antes de publicar, con registro previo y una ejecución por caso (CA-69, punto 4)].
- **Windows/MSYS:** declarado no medido en CA-54 (allí se midió 20,4–28,9 s sobre `3bc7d3c`, sin promesa en esta
  ventana; nota de CA-54, «No acredita»), en CA-47 p. 20, en CA-67 —que el límite de `CreateProcess` ya no alcance al
  motivo, al ir por la entrada estándar, es inferido— y en CA-68 —allí la retirada del transporte es superlineal y un
  mismo juicio tarda varias veces más—.
- **Otros intérpretes:** bash 5.0 o anterior en modo POSIX (límite 2); de 4.3 a 5.2, la conducta de SEC-129 es
  inferida (R-054 §2); bash 3.2, no medido.
- **Las expansiones `$'…'` en modo POSIX:** sin medir; un control del proveedor detuvo la sonda (O-54-3).
- **El CI sobre la cabeza final:** [PENDIENTE: CI sobre la cabeza final].

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
   hook.» F-136-5 «queda con destino 1.37» (`docs/PENDIENTES.md`, F-136-6).
3. **Adelgazar `REQ-007.md` sale a 1.37** (P-136-O (1) (A), texto adoptado): «**Ficha para adelgazar `REQ-007.md`** a
   `historial/` en 1.37.» Ficha F-136-17.
4. **QA-007-01, M0 y MD como límites declarados** (P-136-F, punto 3, y la decisión posterior a `39e68bb`, punto 1;
   literales en el límite 1, arriba). QA-007-01 «mantiene la clase `contrato` hasta que QA decida» (misma decisión,
   punto 2).
5. **El límite sin `CLAUDE_PROJECT_DIR`** (P-136-H (A)) y **QA-007-06 como residual que se repara antes de publicar**
   (P-136-I (B)); ya reparado y cerrado en el paso 5.
6. **SEC-127 sin medir en bash ≤ 5.0 en modo POSIX** (P-136-K (A)), y **O-52-3 a ficha de seguridad** (F-136-7).
7. **El reloj de REQ-017 CA-08 (ii) como instrumento** (P-136-M (A), rama «sin escalón»): «se registra como
   instrumento con las cinco cifras, y sigue. … ficha para REQ-017 … se revisa en 1.37, no ahora.» (INS-136-2,
   F-136-8.)
8. **Las calibraciones de reloj como instrumento** (P-136-E (A)): INS-136-1, «no atribuible al cambio», y F-136-4.
9. **Los techos como cambio de compatibilidad, no como riesgo** (P-136-O (1) (A)): cambio 4, arriba.
10. **`BASH_ENV` fuera** (P-136-N (A), texto adoptado: «`BASH_ENV` queda como ficha F-136-9»).
11. **Fuera de 1.36.0:** el hueco C, P-119-A (F2, F5, F7) y el mecanismo de SEC-123 («Alcance de 1.36.0…»).
12. **Lo que se publica sin reparar**, por las decisiones de arriba y por lo que sigue abierto: QA-007-01 (límite),
    SEC-130 (`instrumento`), F-136-5, F-136-7, F-136-9, los heredados del límite 9 y los hallazgos del límite 10.
    [PENDIENTE: QA paso 6 y seguridad paso 6, que dirán si SEC-115, SEC-118, SEC-129 y QA-007-07 salen reparados o
    abiertos].

**Quién decide publicar.** Con cualquier hallazgo abierto, publicar no puede hacerse por la delegación del propietario
y vuelve a él (`AGENTS.md` §4 y §6, política de autoalojamiento; R-055 §7 lo aplica a SEC-129 y SEC-130). [PENDIENTE:
el estado de `Hallazgos abiertos:` de REQ-007 sobre la cabeza final].

---

### Firmas

**Lo que una firma cubre:** la cabeza sobre la que se emitió. Su cobertura sobre la cabeza que se publique se identifica
en el PR del candidato (PR #60, en borrador; `PENDING_APPROVAL.md` § Resueltas, «PR #60 en borrador…»).

**REQ-007 no está firmado.** Su cabecera dice `QA: pendiente` y `Seguridad: pendiente`, y su `Estado:` es
`en-progreso` (`requirements/REQ-007.md`, líneas 2, 8 y 9). Las revisiones de esta ventana son **determinaciones sobre
un delta**, no la firma del REQ, y así se rotulan en su sede. Estas notas no anticipan ningún cierre.

| Intervención | QA | Seguridad |
|---|---|---|
| CA-54 (`82ceb63`) | con hallazgos: QA-007-01 declarado como límite (`docs/qa/REQ-007.md`, «Décima autorización, fase 3»; re-verificación de `dee5932`, con hallazgos) | R-052: con hallazgos, sin veto; abre SEC-127 |
| SEC-120 (`413c6bd`) | con hallazgos, en la validación y en la re-verificación (`docs/qa/REQ-007.md`, «SEC-120: …») | R-053: con hallazgos, sin veto; SEC-120 `mitigado`; abre SEC-128 |
| Paso 5 (`78a2f33`) | código conforme; con hallazgos de contrato (QA-007-06, cerrado después por su write-back; QA-007-07 nuevo) (`docs/qa/REQ-007.md`, «Paso 5…») | R-054: registro y clasificación de SEC-129, no determinación; R-055: conforme, sin veto; SEC-127 y SEC-128 `mitigado`; abre SEC-130 |
| Paso 6 (`0efd3c2` + [PENDIENTE: commit de QA-007-07]) | [PENDIENTE: QA paso 6] | [PENDIENTE: seguridad paso 6] |

- [PENDIENTE: commit validado del paso 6].
- [PENDIENTE: CI sobre la cabeza final].
- Los controles del proveedor que detuvieron una línea de trabajo se registraron y no se reintentaron: los locales
  GB18030 y BIG5 de QA (P-136-F, punto 4), la sonda de `$'…'` (O-54-3) y una búsqueda del auditor (O-55-1).

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

**Fichas registradas con destino o candidatura 1.37, rotuladas como tales** (`docs/PENDIENTES.md`; no son fichas
a–e del propietario): F-136-6 (la 2b), F-136-5 (la recursión), F-136-17 (adelgazar `REQ-007.md`), F-136-8 (REQ-017
CA-08 (ii)), F-136-12 (SEC-130, si R2 no lo cubre), y como candidatas F-136-14, F-136-15 y F-136-16.

*(1.38.0: fichas f–i en `docs/PLAN.md` § «1.38.0 — fichas registradas».)*

---

### Historia

**Una línea por commit de código**, con la entrada del `CHANGELOG.md` que lo registra. No se reescribe nada. Cada
cifra es de la cabeza que nombra.

| Commit | Qué trae | Registro |
|---|---|---|
| `82ceb63` | CA-54: análisis de `Bash` en el máximo por debajo de 5 s (35/35, máx. 3 711 ms según el desarrollador) con las mismas decisiones; atajo de `guard-completado` readmitido por P-136-D | `CHANGELOG.md`, «Décima autorización, fase 2 (CA-54)…» |
| `413c6bd` | SEC-120, pasada correctiva única: QA-007-03 (entrada vacía o con NUL) y QA-007-04 (`false` en `file_path` o en `command`) | «SEC-120, pasada correctiva única…» |
| `a59917d` | Paso 5, fase 2: SEC-127 (locale sin asignación delante de una función) y QA-007-06 (`read` fallido → ilegible) en `hooks/lib.sh` | «Paso 5 (SEC-127 y QA-007-06), fase 2…» |
| `78a2f33` | SEC-128: en `guard-codigo`, un `file_path` que no es texto no deja pasar a nadie | «Paso 5, SEC-128 (P-136-J (A, acotada))…» |
| `0efd3c2` | Paso 6, fase 2: SEC-118 (motivo por la entrada estándar, acotado a 16 384 bytes), SEC-115 (plazo y techos) y SEC-129 (`hooks/entrada.sh`, R1 y R2) — SIN VALIDAR | «Paso 6, fase 2 (desarrollador)…» |
| [PENDIENTE: commit de QA-007-07] | QA-007-07: las variables `ARNES_*_LISTO` heredadas dejan de apagar las puertas | [PENDIENTE] |

**Otros commits que tocan código protegido según el `CHANGELOG.md`** (lista **no exhaustiva**; la exacta es
[PENDIENTE: `git log --first-parent v1.35.0..<cabeza final> -- hooks/ tools/ tests/`]):
- `aba1c9b`, SEC-120 fase 2, la reparación sobre la que va la pasada `413c6bd` («Intervención 2 (SEC-120), fase 2…»);
- `dee5932`, la pasada correctiva de QA-007-01, **revertida** en `74da4c5` («Revert del código de `dee5932` por
  P-136-F…»);
- los commits de casos del banco sin reparación: `6759a8e` (SEC-120, fase 1), `ab52c9b` (paso 5, fase 1) y `738b74d`
  (paso 6, fase 1).

**La certificación de una cabeza es la corrida que se ejecutó sobre ella, y nada más amplio.** Ningún CI verde
acredita rendimiento, conducta ni ahorro (notas `[1.35.0]`, «Historia»).
