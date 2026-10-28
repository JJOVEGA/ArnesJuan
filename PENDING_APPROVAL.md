# PENDING_APPROVAL — ArnesJuan

> Cola de decisiones que esperan visto bueno humano. Un agente AÑADE una entrada con su forma
> —pregunta, opciones, recomendación y consecuencia de cada opción (`AGENTS.md` §6, regla 4)—;
> el humano la resuelve y la mueve a "Resueltas".
>
> **Qué impide esta cola, dicho con su alcance y no en absoluto.** Mientras haya algo en
> "Pendientes", `guard-completado` deniega **marcar cualquier REQ como `completado`** —la
> transición del campo `Estado:` de ese REQ al valor `completado`—. Y sus tres fronteras:
> **no** impide **implementar** ni **probar**, así que el trabajo que **no dependa** de la
> decisión, esté **autorizado** y esté **suficientemente definido** continúa; **no es** ninguna
> de las aprobaciones humanas normativas de `AGENTS.md` §6, y **vaciar la cola no concede
> ninguna**; y **no absorbe** ninguna otra restricción normativa —el orden de fases, el veto de
> seguridad, el tope de vueltas dev↔QA—, que bloquean por su propia regla. Por eso **cada
> entrada declara qué trabajo sigue**, o que **ninguno sigue** y el proyecto espera.
>
> **Formato de una entrada** (va bajo `## Pendientes`, con `###`):
> `### [AAAA-MM-DD] (agente) — Título de la decisión`, y debajo: **Contexto** (por qué se
> detuvo aquí) · **Opciones** (A / B / …) · **Recomendación del agente** · **Espera**
> (aprobación / elección del humano).
>
> **Cómo se cuenta esta cola — una sola regla, la misma para todos.** Una entrada es una
> línea que empieza por `###` + espacio, dentro de la sección que abre un encabezado `## `
> cuyo texto empieza por «Pendientes» y que cierra el siguiente encabezado `## ` de
> cualquier nombre; lo que caiga dentro de un comentario HTML (`<!-- … -->`) no cuenta. Esa
> regla vive UNA vez en el código (`arnes_cola_pendientes`, `hooks/lib.sh`) y la usan por
> igual la puerta de cierre (`guard-completado`), el bloque derivado de `docs/ESTADO.md` y
> `tools/arnes-lectura.sh`: el número que se lee es exactamente el que bloquea. Y si la
> cola no se puede leer entera —un byte NUL, un archivo sin permiso—, la puerta DENIEGA y
> el bloque derivado dice `sin datos`: nunca 0.
>
> El ejemplo vive AQUÍ, fuera de la cola, y a propósito: un ejemplo dentro de la sección se
> cuenta como una pendiente real e impide la acción de clase «cerrar» —**marcar cualquier REQ
> como `completado`**, la transición de su campo `Estado:` a ese valor—, porque la regla que lo
> impide, `guard-completado`, no distingue un ejemplo de una pendiente.
>
> **Autorizaciones por fases.** Una autorización del propietario se escribe con la plantilla
> `templates/autorizacion.md` —sus cuatro bloques: plan autorizado, lo que decide la coordinadora
> sola, cuándo parar y preguntar, y qué hacer si la sesión se corta— y se registra literal en
> "Resueltas", citada con `> `: un encabezado `## ` sin citar cerraría la sección en la que cae. En
> este proyecto la llevan todas desde la décima autorización del propietario (2026-10-03, en
> "Resueltas").

## Pendientes

### [2026-10-28] (qa-tester) — REQ-036, tope de QA agotado: una línea propia que empieza por `# ` antes de la primera marca no la lee ningún subagente

**Contexto.** QA terminó la vuelta 3 de 3, la última, sobre `d24b383`. Su veredicto es `con-hallazgos`, y la evidencia
está en `docs/qa/REQ-036.md`, «Vuelta 3».
- **Qué se sostiene:**
  - el texto propio entre el título y la primera marca llega a los cuatro archivos por rol (S9);
  - L4 está reparado por la frase de las definiciones;
  - QA-036-11 queda cerrado;
  - el banco da 3093/0/34.
- **Qué no se sostiene:** QA-036-03 (`usuario/dinero`) sigue abierto en una forma más estrecha.
  - El caso: una línea **propia** que empieza por `# ` está entre el título y la primera marca. Por ejemplo,
    «# Regla del equipo: todo cambio en src/pagos/ es de cobro y es crítico.».
  - Esa línea no llega a ninguno de los cuatro archivos. No hay aviso y el generador sale con rc 0.
  - Tras `arnes-upgrade`, `CLAUDE.md` ya no importa `AGENTS.md`, así que ningún subagente la lee. En 1.36 la leían
    todos.
  - La causa: CA-18 y el generador tratan como título **toda** línea `# ` que va antes del primer texto. Eso
    contradice la frase de CA-18 «contiene todo el texto de la fuente que no sea el título».
  - La frecuencia es baja, porque exige una regla escrita como encabezado de nivel 1, pero la clase es la misma.
- **No quedan vueltas:** «Loop de error» manda `bloqueado` y escalar.

**Opciones.**
- **(A) Una pasada acotada más, autorizada fuera del tope.**
  - El título pasa a ser **sólo la primera línea no en blanco** de la fuente, si empieza por `# `.
  - Cualquier otra línea no en blanco antes de la primera marca abre el bloque sin marca, que va a los cuatro con
    aviso.
  - **Quién y qué:**
    - el analista escribe CA-18 («Qué contiene» y pieza 1);
    - el desarrollador cambia una condición del generador y el extractor de las dos partes de la sección 52, y añade
      un caso con fail-before contra `d24b383`;
    - QA re-verifica sólo eso.
  - *Consecuencia:* no hay bytes nuevos en las definiciones y **B5 no se mueve**, porque las plantillas y este
    repositorio sólo tienen el título y blancos (S3c). Cuesta una pasada corta más.
- **(B) Aceptar la laguna por escrito.** Una línea `# ` entre el título y la primera marca se trata como título.
  - *Consecuencia:* esa línea se pierde en silencio tras `arnes-upgrade` cuando hay archivo por rol.
  - Aceptarla no la acredita. QA-036-03 se cerraría con la aceptación escrita, como residual con dueño.

**Recomendación de QA: (A).** Es la regla general «ante la duda, se lee» (P-137-X (D)) y no cuesta bytes de lectura.
Texto listo para adoptar:
> Adopto (A) para QA-036-03: en el archivo por rol, el título es sólo la primera línea no en blanco de la fuente si
> empieza por `# `; cualquier otra línea no en blanco antes de la primera marca es texto propio y va a los cuatro, con
> aviso. Autorizo una pasada acotada fuera del tope de vueltas: analista (CA-18), desarrollador (generador, extractor y
> un caso con fail-before contra `d24b383`) y QA sólo sobre eso. B5 no se mueve.

**Qué impide** (`AGENTS.md` §6, regla 2):
- (i) **Acción impedida: cerrar.**
  - REQ-036 no puede pasar a `completado`, por el hallazgo `usuario/dinero` abierto y por `Estado: bloqueado`
    (`guard-completado`; §6, «Loop de error»).
  - Mientras esta entrada siga bajo § Pendientes, `guard-completado` también deniega marcar **cualquier** REQ como
    `completado`.
- (ii) **Parte de la entrega:** REQ-036, CA-18 (pieza 1, «Qué contiene»). La firma de seguridad espera a QA (§6).
- (iii) **Evidencia:**
  - `docs/qa/REQ-036.md`, «Vuelta 3», con la reproducción;
  - `tools/arnes-lectura-rol.sh`, el `case "$l" in '# '*) ;;` del bucle de fuentes;
  - `requirements/REQ-036.md`, CA-18.
- (iv) **Lo resuelve:** la elección del propietario.

**Qué trabajo sigue:** el que no depende de esta decisión, por ejemplo F-137-24. Implementar y probar no quedan
impedidos.

**Espera:** elección del propietario.

## Resueltas

### RESUELTA (propietario, 2026-10-28) — **P-137-AG (A)** y el matiz de P-137-Y confirmado; **P-137-AF**: 1.36.3 no se publica, y el arreglo de #63 va a 1.37 como F-137-24, con prioridad alta

> Adopto P-137-AG (A) y confirmo el matiz de P-137-Y. Sigue la vuelta 3 de
> QA de REQ-036.
>
> P-137-AF: 1.36.3 no se publica. El arreglo de #63 va a 1.37 como
> F-137-24, con prioridad alta (primera intervención tras cerrar 4a), y
> partiendo de lo aprendido: las respuestas dobles con carga vienen del
> arreglo, no del problema original. Redáctame el comentario del issue #63
> (causa, por qué no sale 1.36.3, que va en 1.37, y la salida manual del
> propietario mientras tanto); lo publico yo.
>
> Antes de seguir: comitea en la rama de evidencia todo lo de
> issue-63-plazo-gates/ y recuérdame el push.

**Lo que añade la coordinadora, rotulado como suyo:**
- **P-137-AG (A)** se adopta con el texto propuesto en la ficha de abajo:
  - la frase va a las cuatro definiciones (+70 B cada una);
  - B5 queda en 75 590 B como trinquete, con su razón;
  - el techo de contrato sigue en 75 000 B.
- **Orden.** El mismo desarrollador aplica la frase dentro de la última pasada. Después, el analista escribe CA-20 y la correspondencia (P-137-AG y la confirmación de P-137-Y). Por último, QA vuelta 3 de 3.
- **P-137-Y.** Desde aquí, la autorización verificable del matiz (`arnes-upgrade` conserva el import de CLAUDE.md mientras AGENTS.md no tenga marcas) es esta resolución.
- **P-137-AF.** El registro del hotfix vive en la rama `hotfix/1.36.3`: su `PENDING_APPROVAL.md` la transcribe y deja P-137-AE sin efecto (SEC-133 sigue en F-136-23).
  - En esta rama, F-137-24 pasa de 1.38 a 1.37 en `docs/PENDIENTES.md`.
  - La duda de 1.37 o 1.38 en P-137-AD queda resuelta por este texto: 1.37.
- **Evidencia.** `issue-63-plazo-gates/` comiteado en la rama de evidencia como `51bb090`.

### P-137-AG (texto de la consulta, conservado; resuelta arriba) — REQ-036, última pasada correctiva. **Un residual `usuario/dinero` (L4) sólo se cierra con una frase en las definiciones, y esa frase sube B5 por encima de los 75 520 B.** Además, falta confirmar el matiz de P-137-Y.

**Qué queda tras la vuelta 2 de QA y el write-back del analista** (`f648e94`):
- **QA-036-03 (`usuario/dinero`), variante con marcas parciales.** Si el texto propio del proyecto está entre el título y la primera marca, después de `arnes-upgrade` no lo lee ningún subagente. En 1.36 lo leían todos, por el import de CLAUDE.md.
- **El analista eligió la opción (a), sin bytes nuevos:** el generador manda ese texto, intacto, a los cuatro archivos por rol, con un aviso. Lo construye ahora el desarrollador.
- **Queda L4:** si hay texto previo **y** el archivo por rol no se puede generar por una causa del entorno, el respaldo por marcas no lee ese texto, y CLAUDE.md, ya sin import, tampoco. Las causas son:
  - `.arnes` enlazado;
  - destino no escribible;
  - falta `sha256sum` (`tools/arnes-lectura-rol.sh:106`). macOS no lo trae de serie (sin medir aquí).
- **El REQ declara L4 como «ni aceptado ni reparado».** Una etiqueta no cierra un `usuario/dinero`, así que QA, en la vuelta 3, lo dejará abierto, y la puerta no deja cerrar REQ-036.

**Opciones para L4.**
- **(A) Cerrar L4 con una frase en las cuatro definiciones.** En el respaldo por marcas: «Si una fuente tiene texto antes de su primera marca, léelo también».
  - **Medido por el desarrollador en una copia:** +70 B en cada una de las cuatro definiciones. **B5 pasa de 75 520 B a 75 590 B** en modo proyecto y a 75 526 B en modo plantilla. Se escribe la razón y queda como trinquete, igual que en P-137-AC.
  - El techo de contrato sigue en 75 000 B.
- **(B) Aceptar L4 como laguna declarada.** No hay bytes nuevos.
  - *Coste:* el texto previo se pierde en silencio en esos entornos, y aceptar una laguna no la acredita. QA-036-03 sólo podría cerrarse con tu aceptación escrita.

**Confirmación de P-137-Y.**
- La pieza 3 de la reparación de QA-036-03 condiciona P-137-Y en un caso límite: `arnes-upgrade` conserva el import de CLAUDE.md mientras AGENTS.md no tenga marcas.
- Te lo informé, pero tu respuesta no consta en ninguna sede.
- El REQ lo apoya en P-137-X (D) y P-137-W. QA pide que la autorización sea verificable.

**Recomendación de la coordinadora: (A) y confirmar el matiz.** Texto listo para adoptar:

> Adopto P-137-AG (A): las cuatro definiciones leen también el texto anterior a la primera marca de una fuente cuando caen al respaldo por marcas; B5 sube a 75 590 B (lo medido con esa frase: +70 B por definición), con su razón escrita, como trinquete; el techo de contrato sigue en 75 000 B. Confirmo el matiz de P-137-Y: `arnes-upgrade` conserva el import de CLAUDE.md mientras AGENTS.md no tenga marcas.

**Qué bloquea.** La vuelta 3 de QA, que es la última, y el cierre de REQ-036.
- La pasada del desarrollador ya terminó con la opción (a): banco 3094/0/31.
- Si adoptas (A), el mismo desarrollador aplica la frase en el árbol dentro de la misma pasada. Luego van el write-back del analista en CA-20 y B5 sube a 75 590 B. Después, QA de la vuelta 3.
- Si eliges (B), QA de la vuelta 3 sale ya, con tu aceptación escrita.

### RESUELTA (propietario, 2026-10-27) — **P-137-AC (A)** y **P-137-AB (A)**: B5 sube a 75 520 B; hotfix 1.36.3 mínimo desde `main`, con prioridad sobre el resto de 1.37; ficha para 1.38 (gates fuera del hook, veredicto con hash)

**Texto del propietario, literal** (mensaje del 2026-10-27 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-AC (A): B5 sube a 75 520 B, con la razón escrita (las dos
> frases que hacen leer más); el techo sigue funcionando como trinquete. El
> desarrollador corrige B10 en el mismo encargo. QA vuelta 2 de 3 y
> seguridad.
>
> Adopto P-137-AB (A): hotfix 1.36.3 mínimo, rama desde main (v1.36.2),
> PRIORIDAD sobre el resto de 1.37. Alcance, sólo esto:
> 1. El plazo propio de 30 s mide el ANÁLISIS de la puerta, no el tiempo de
>    las quality gates: el reloj del plazo no cuenta lo que tardan las gates.
> 2. Las gates tienen su propio presupuesto, por debajo de lo que el cliente
>    tarda en matar el hook (medir ese valor: el issue dice ~600 s, no 60;
>    corregir el texto de SEC-132 (a) con la cifra medida). Si las gates lo
>    exceden, deny con un motivo propio de gates («las quality gates no
>    terminaron dentro de su presupuesto de N s»), nunca un cierre sin
>    veredicto.
> 3. Fail-before contra v1.36.2 con la reproducción del issue (una gate
>    `sleep 35`, cierre legítimo → hoy deny, con el arreglo allow) y un caso
>    con gates por encima del presupuesto (→ deny con el motivo de gates).
> 4. El «hallazgo colateral» del issue (cierres que pasaron sin veredicto en
>    versiones anteriores al morir el hook): se comprueba en v1.35.0 y
>    v1.36.0 y se declara en las notas con lo que salga.
> Ciclo completo, desarrollador y QA en Opus (es crítico). Tope: una pasada.
> Al publicar 1.36.3: fusión de main en cand/1.37.0.
>
> Ficha para 1.38 (pieza de veredictos con hash): las gates no deberían
> correr dentro del hook. QA o la coordinadora las corren antes y registran
> el resultado con el hash del árbol; la puerta sólo comprueba que el árbol
> actual es ese. Así el cierre tarda un segundo sea cual sea el proyecto.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Hotfix:**
  - worktree `/home/juan/dev/ArnesJuan-1.36.3`, rama `hotfix/1.36.3` desde `origin/main` (`46ee7ca`, `v1.36.2`);
  - REQ nuevo **REQ-037**, numerado después de los de `cand/1.37.0` (034–036) para que no choquen al fusionar;
  - orden: analista (Sonnet) → desarrollador (Opus) → QA (Opus) → seguridad (Opus);
  - «tope: una pasada» = una sola pasada correctiva.
- **REQ-036 (P-137-AC):** la dependencia acotada del desarrollador (B5 y B10) es pequeña y va en otro worktree y otra rama, así que corre a la vez que el analista del hotfix, sin retrasarlo. QA vuelta 2 y seguridad de REQ-036 van detrás del hotfix si compiten por el mismo turno.
- **La ficha para 1.38** se registra en `docs/PENDIENTES.md` como F-137-24.

### P-137-AC (texto de la consulta, conservado; resuelta arriba) — **REQ-036: la reparación de QA añade 240 B de texto de seguridad a la definición del analista, y B5 pasa de 75 280 B (lo que aceptaste) a 75 520 B.** ¿Se acepta?

**Qué pasó.** El desarrollador (Opus) construyó QA-036-03 a 09 en `330dc86` (sin validar), y paró en B5, como manda CA-20. Banco: 3082 PASS, 2 FAIL, 34 SKIP; los 2 FAIL son B5 y su fixture. `--verificar` sale 0.
- **Origen del exceso:** sólo la definición del analista, que pasa de 16 481 a 16 721 B (+240 B). Son las dos frases que la reparación exige:
  - «una fuente sin ninguna marca, léela entera» (QA-036-03, el hallazgo `usuario/dinero`);
  - «si llega truncado, sigue leyendo hasta el final» (QA-036-08).
- **Lo que no cambia:** el archivo por rol del analista y el guion.
- **Por qué no hay holgura:** el techo se fijó en la cifra exacta medida (75 280), así que cualquier byte de texto lo pasa. Recortar otra parte de la definición es condensar normativa, y eso CA-13 lo reserva al propietario.

**Qué detiene, y qué no.** Detiene el paso de REQ-036 a `en-revisión` y, por tanto, QA, seguridad y el cierre. Nada más.

**Opciones**
- **(A) — recomendada: aceptar 75 520 B como nuevo techo de regresión de B5.** Los 240 B son texto que hace leer **más** a los agentes, no menos. En la misma dependencia acotada, el desarrollador corrige B10, que todavía compara procesos por **igualdad** cuando CA-17 ya es un techo (QA-036-06). Lo vio él mismo.
  *Consecuencia:* ≈ 60 k más de desarrollador; luego QA, en la vuelta 2 de 3, y seguridad. El objetivo de 75 000 B ya estaba incumplido y aceptado (P-137-AA), y lo sigue estando.
- **(B): condensar en la definición del analista otros 240 B de texto normativo**, sin mover nada. *Consecuencia:* ataca la regla que lleva toda 4a, «nada normativo se condensa», por 0,3 % de bytes; y otro desarrollador más.
- **(C): sacar las dos frases de la definición y dejarlas sólo en `AGENTS.md`.** *Consecuencia:* el respaldo de «fuente sin marcas» tiene que estar en la definición, porque es lo que se lee cuando el archivo por rol no sirve. Quitarlo deshace la reparación de QA-036-03. No la recomiendo.

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-AC (A): B5 pasa a 75 520 B como techo de regresión, porque los 240 B son el texto de seguridad de QA-036-03 y QA-036-08; el desarrollador corrige además B10 a techo (QA-036-06); siguen QA y seguridad.

### P-137-AB (texto de la consulta, conservado; resuelta arriba) — **Issue #63: con gates de más de 30 s, `guard-completado` no deja cerrar nada desde 1.36.0, y el cliente no mata el hook a los 60 s sino a ≈ 600 s.** ¿Hotfix 1.36.3 o dentro de 1.37?

**Qué se midió** (evidencia en `issue-63-plazo-gates/` del árbol de evidencia, `bca0598`; proyecto mínimo, sin datos de ningún consumidor):
- **Reproducido en 1.36.0, 1.36.1, 1.36.2 y en el candidato `d722aed`:** un cierre con todo en orden y una gate `sleep 35` se deniega siempre por el plazo propio.
  - Con `sleep 25` pasa.
  - Los controles se comportan como deben: una gate `false` deniega y una `true` deja pasar.
- **No lo introdujo 1.36.2: viene de 1.36.0.** La comprobación del plazo detrás de las gates cuenta el tiempo de las propias gates.
- **El límite del cliente, medido en 2.1.289 con un plugin de prueba** (una corrida por punto):
  - un hook de 75 s **no se mata**, y su `deny` se aplica;
  - uno de 620 s se mata a **≈ 600 s**, y la llamada sigue **sin su decisión**.
- **La premisa del arnés es falsa.** §13, `hooks/lib.sh`, `guard-completado.sh` y el propio motivo de la denegación dicen que el cliente mata a los **60 s**. **Sobre esa premisa se fijó el plazo de 30 s.**

**Qué significa:**

| Gates del proyecto | Qué ocurre hoy |
|---|---|
| menos de 30 s | se juzga bien |
| entre 30 s y ≈ 600 s | **el cierre se deniega siempre**, aunque todo esté en verde. Es el issue: en la práctica, cualquier proyecto real |
| más de ≈ 600 s | el cliente mata el hook y **el cierre se aplica sin veredicto**. Es SEC-132 (a), ya declarado, pero con la cifra equivocada (60 s) |

**Qué detiene, y qué no:**
- **Detiene la acción «cerrar»** en los proyectos instalados cuyas gates sumen más de 30 s. Lo impide `guard-completado`, por su plazo propio (REQ-007 CA-68).
- **La única salida hoy** es que el propietario de cada proyecto haga la transición a mano.
- **A este repositorio no le afecta**: sus tres gates tardan menos de 1 s. REQ-036 sigue su curso.
- **Esta entrada, mientras esté en `## Pendientes`, impide cerrar cualquier REQ de este repositorio**, también REQ-036 (`guard-completado`, cola de aprobaciones).

**Opciones**
- **(A) — recomendada: hotfix 1.36.3 mínimo, desde `v1.36.2`, con su ciclo completo** (analista Sonnet; desarrollador, QA y seguridad en Opus). Alcance:
  1. el plazo propio **deja de contar el tiempo de las gates**, de modo que un cierre con gates en verde de menos de ≈ 600 s se juzga;
  2. **`timeout` explícito en `hooks.json`** para `guard.sh`, para que el límite no dependa del valor por defecto del cliente;
  3. **se corrige la promesa entera** que dice «60 s»: §13, el motivo de la denegación, los comentarios y SEC-132 (a), con la cifra medida;
  4. casos de banco, con las lecciones L4 y L5 de F-136-22 delante:
     - una gate verde de 35 s → deja cerrar;
     - una gate roja de 35 s → deniega;
     - ninguna gate roja pasa nunca.

  **Residual que se declara:** unas gates que, sumadas, se acercan al límite del cliente siguen pudiendo dejar el hook sin decisión (SEC-132 (a)). Su arreglo de fondo sigue en F-136-22, dentro de 1.37.

  **Después:** se fusiona en `cand/1.37.0`.

  *Consecuencia:* desbloquea el cierre en los proyectos instalados en una intervención corta. Coste estimado ≈ 500–650 k tokens en los cuatro roles. Interrumpe 4a entre QA y seguridad, o espera a que REQ-036 cierre; lo eliges tú.
- **(B): dentro de 1.37, con F-136-22** (la intervención única sobre el bucle de gates). *Consecuencia:* los proyectos instalados no pueden cerrar desde el agente hasta 1.37. Quedan por delante 4b, 3b y 5.
- **(C): hotfix sólo del punto 1**, sin corregir la promesa de los 60 s. *Consecuencia:* más barato, pero deja escrita una cifra falsa en §13 y en el motivo, y SEC-132 (a) sigue describiendo un límite que no es el real. No la recomiendo.

**Lo que no se ha medido:**
- Windows/MSYS.
- Otras versiones del CLI.
- Un `guard.sh` real con gates de más de 600 s (sólo el plugin de prueba).
- Qué versión corría en un cierre de un consumidor que pasó el 2026-10-21. Por debajo de 1.36.0 no hay plazo propio, y unas gates de menos de 600 s se habrían juzgado con decisión.

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-AB (A): hotfix 1.36.3 mínimo desde v1.36.2 —el plazo propio no cuenta las gates, timeout explícito en hooks.json, se corrige la promesa de los 60 s con la cifra medida, y casos de banco verde/rojo de 35 s—, con su ciclo completo; se hace después de cerrar REQ-036 y antes de 4b; luego se fusiona en cand/1.37.0.

### RESUELTA (propietario, 2026-10-26) — **P-137-AA (A)**: se acepta lo medido, con las tres cifras en REQ-036; 4a cumplida por USD (−28 %) y 4/4; sin más pasadas; siguen QA y seguridad, y la parada antes de 4b

**Texto del propietario, literal** (mensaje del 2026-10-26 a la sesión coordinadora del worktree `ArnesJuan-v1.36`; justo antes había reenviado el texto de P-137-Z, ya registrado, y no se aplicó dos veces):

> Adopto P-137-AA (A): se acepta lo medido, con las tres cifras escritas en
> REQ-036 (75 280 B por el guion; 66,4 KB leídos de verdad; ≈82,8 KB
> contados como la línea base) y la razón de cada una. El criterio de éxito
> de 4a queda cumplido por la métrica principal: 0,220 USD por corrida
> frente a 0,308 de la base (−28 %), 4/4. Sin más pasadas. Sigue con QA y
> seguridad, y después la parada antes de 4b.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Orden:**
  1. el analista (Sonnet) transcribe P-137-AA en REQ-036 (CA-01 y CA-02, con las tres cifras y su razón) y deja el REQ en `en-revisión`;
  2. QA (Opus explícito);
  3. seguridad (Opus);
  4. cierre por `Edit` y métrica por rol;
  5. parada antes de 4b.
- **El FAIL B5 del banco** (el techo de 75 000 B) **queda abierto**: lo resuelve este write-back, no se arregla tocando el techo por fuera. Si hace falta cambiar el caso del banco para que refleje lo aceptado, es del desarrollador y se le encarga como una dependencia acotada.

### P-137-AA (texto de la consulta, conservado; resuelta arriba) — **REQ-036, última pasada de 4a: tu condición de cierre se cumple (4/4 y USD −28 %), pero el techo de bytes de CA-01, que fijaste tú, no.** ¿Se acepta lo medido?

**Qué se midió.** Árbol `cfdc60e`, 4 corridas con `claude -p`, mismo método. Evidencia en `1.37-4a-conducta-claude-p/pasada-P-137-Z/` del árbol de evidencia (`a1d2032`).

| | USD por corrida | No cacheados | Total de tokens | Turnos | Cabecera correcta |
|---|---|---|---|---|---|
| Base (`081cb10`) | 0,308 | 64 770 | 212 564 | 6,0 | 2/2 |
| Pasada anterior (`d4e68d6`) | 0,267 | 48 992 | 248 432 | 15,0 | 3/4 |
| **Esta pasada** | **0,220 (−28 %)** | **44 283 (−32 %)** | **163 660 (−23 %)** | 7,75 | **4/4** |

- **Cumple las dos condiciones de P-137-Z.**
  - Las 4 corridas escriben la cabecera que su caso exige, y el caso de dinero ya lleva `Seguridad: pendiente` (CA-19).
  - El USD medio queda por debajo de 0,308.
- **Las 4 leen su archivo por rol en un solo `Read`** y ninguna vuelve a leer por marcas. La comprobación de frescura va en el mismo mensaje que el `Read` en 3 de 4; en la cuarta va en el mensaje anterior.
- **Las 4 escriben sólo en `requirements/`.**

**Lo que no se cumple: el techo de bytes (CA-01, 75 000 B, P-137-X (D)).** Hay tres formas de contarlo, y las tres se escriben:

| Cómo se cuenta | Bytes |
|---|---|
| Lo que la definición manda leer, contando sólo el bloque `rigor_politica` del manifiesto (método del guion de CA-01, el mismo que dio 74 547 B en la pasada anterior) | **75 280** |
| Lo que el analista **leyó de verdad** con `Read` en las corridas: archivo por rol 57 089 + manifiesto **entero** 9 274 (+ 117 de código) | **66 363–66 480** |
| **Lo que recibe**, contado como la línea base de 138 574 B: definición inyectada 16 481 + manifiesto entero + archivo por rol | **≈ 82 844** |

- **El desarrollador paró en 75 280 B (CA-13)** y no condensó normativa.
  - El exceso, 280 B, lo ponen la cabecera del archivo por rol y la línea de CA-19.
- **La coordinadora añade lo que la cifra de 75 280 no dice:**
  - el analista lee el manifiesto entero, no sólo el bloque de la política;
  - la línea base lo contaba entero.

  Contado como la base, lo que recibe baja de 138,6 KB a ≈ 82,8 KB (−40 %), por encima de 75 KB y de 70 KB.

**Qué detiene, y qué no.**
- **Detiene que QA dé por cumplido CA-01**, y con ello el cierre de REQ-036.
- **No detiene nada más:** el resto de lo construido no depende de esta respuesta.
- **No despacho QA hasta tener tu respuesta.** Si eliges (B), QA tendría que repetirse sobre otro árbol.

**Opciones**
- **(A) — recomendada: aceptar lo medido y cerrar 4a.** CA-01 se cierra con las tres cifras declaradas en el REQ como residual con dueño, sin más pasadas. La métrica con la que aprueba 4a es la que fijaste en P-137-Z, USD, y ésa baja un 28 %. *Consecuencia:* el objetivo de bytes queda incumplido y escrito. Siguen QA (Opus) y seguridad (Opus), y luego la parada entre 4a y 4b.
- **(B): otra pasada para bajar de 75 KB.** Por ejemplo:
  - que el analista lea sólo la política del manifiesto, con un `Grep` en vez del `Read` entero (≈ −7,5 KB leídos, y quizá un turno más);
  - o quitar de las definiciones la lista «Hoy son…» (−299 B).

  *Consecuencia:* rompe tu tope («ésta es la última pasada de 4a»). Cuesta otro desarrollador (≈ 150 k) y otras 4 corridas, para una cifra que ya no es la métrica de aprobado.
- **(C): aceptar sólo con el método del guion (75 280 B), sin declarar las otras dos cifras.** No la recomiendo: esconde que el analista lee el manifiesto entero.

**Coste de REQ-036 hasta aquí:**
- analista: 191 274 + 70 532 = 261 806 (notificaciones);
- desarrollador: 527 679 + 233 526 = 761 205. El último pasó el aviso de 1,5× de su presupuesto de ≈ 150 k por ≈ 8,5 k;
- corridas de esta pasada: 0,88 USD en total.

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-AA (A): CA-01 se cierra con lo medido, declarado en el REQ con sus tres cifras (75 280 B por el método del guion; 66,4 KB leídos; ≈ 82,8 KB recibidos contados como la base), sin más pasadas; 4a se aprueba por USD (−28 %) y 4/4; siguen QA y seguridad.

### RESUELTA (propietario, 2026-10-26) — **P-137-Z (A)**: lectura por rol generada como derivado y comprobada byte a byte por el banco; se cierra el hueco de `Seguridad:`; se repite la medida. **Cambio de métrica:** USD por corrida como principal. **Tope:** última pasada de 4a

**Texto del propietario, literal** (mensaje del 2026-10-26 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-Z (A): un archivo de lectura por rol, generado por el arnés
> como derivado (concatenación exacta de los bloques marcados), comprobado
> byte a byte por el banco; el analista lo lee en un solo Read. Se cierra
> el hueco de Seguridad: (ámbito alcanzado no sensible) en la plantilla, y
> se repite la medida.
>
> Cambio de métrica, decisión del propietario: desde aquí la métrica
> principal de coste es USD por corrida (o, si no está disponible, tokens
> NO cacheados de entrada + salida), y el total de tokens se registra como
> dato secundario. Las tablas de 1.36.2–1.37 · 2 se dejan como están; las
> nuevas llevan las dos columnas.
>
> Tope: esta es la última pasada de 4a. Si con el archivo por rol la
> prueba no da 4/4 o el USD por corrida no baja de la base, se cierra con
> (B): se acepta lo medido, se cierra el hueco y se declara.

**Lo que añade la coordinadora, rotulado como suyo** (decisiones que no cambian una protección, un alcance ni un riesgo):
- **Las comisiones no tienen USD.** La notificación de un subagente da sólo el total de tokens. Para ellas, la métrica principal se calcula sumando, turno a turno, el `usage` de su transcripción: `input_tokens` + `cache_creation_input_tokens` + `output_tokens`. Es la lectura de «no cacheados» que tomo: la creación de caché tampoco sale de la caché. Los tres sumandos se registran por separado, así que la otra lectura (sin la creación de caché) se puede recalcular sin repetir nada. El total de la notificación sigue como dato secundario.
- **La base de la comparación es la ya medida:** 0,308 USD por corrida (2 corridas sobre `081cb10`). No se vuelve a correr, porque la base no cambia. Ojo: el candidato actual ya está en 0,267, así que de las dos condiciones del tope la que decide en la práctica es el 4/4.
- **4/4** significa que las 4 corridas del candidato escriben la cabecera que el caso exige: `Rigor:` y `Seguridad:` coherentes con su ámbito.
- **Orden:**
  1. El analista (Sonnet) transcribe P-137-Z en REQ-036. Incluye el contrato de frescura del archivo generado y el write-back de `skills/arnes-init/SKILL.md` y `ARCHITECTURE.md` en `Archivos:`.
  2. El desarrollador (Opus explícito) lo implementa.
  3. La coordinadora hace las 4 corridas con `claude -p`.
  4. QA y seguridad.

### P-137-Z (texto de la consulta, conservado; resuelta arriba) — **REQ-036, medida de CA-02 con `claude -p`: el import fuera ahorra mucho, pero leer bloque a bloque sube los turnos y los tokens.** ¿Cómo seguimos?

**Qué se midió** (evidencia en `1.37-4a-conducta-claude-p/` del árbol de evidencia, commit `6c59cde`). El analista corrió como sesión principal de `claude -p`, aislado, con el `CLAUDE.md` de cada plantilla y su plugin (`--plugin-dir`): 4 corridas sobre el candidato (`d4e68d6`) y 2 sobre la base (`081cb10`, con import). El número de corridas de la base lo decidió la coordinadora, para no duplicar el coste.

| | Contexto al empezar | Tokens procesados por corrida (media) | Turnos | USD por corrida |
|---|---|---|---|---|
| Base (con import) | 39 673 | 212 564 | 6,0 | 0,308 |
| Candidato | **10 895 (−73 %)** | **248 432 (+17 %)** | **15,0** | **0,267 (−13 %)** |

- **Rigor:** 6 de 6 correctos. **Lo que lee el analista:** 74 547 B, dentro de tus 75 KB.
- **Por qué suben los tokens:** el analista localiza sus bloques con `Grep` y los lee **uno a uno** con `Read` por rangos; son ≈ 15 turnos, y **cada turno vuelve a procesar todo el contexto**. Esas relecturas salen de la caché, así que el USD baja y el recuento de tokens sube.
- **Un fallo de cabecera, en 1 de 4:** `cand-dinero-2` escribió `Seguridad: n/a` con `Rigor: critico`. **La causa es un hueco de la plantilla heredado de REQ-034**, no el corte: dice qué lleva `Seguridad:` en un cambio normal (`n/a`), pero no en un ámbito alcanzado que no es sensible, como el de dinero. Falla hacia lo cerrado (la puerta no cierra un `critico` sin `Seguridad: aprobado`), pero **no es «4/4 igual»**.

**Qué detiene, y qué no.** Detiene QA de REQ-036: el objetivo de bytes se cumple, pero el de coste, medido como pediste, no. **El ahorro grande ya está ganado y no depende de esto:** sin el import, **cada subagente** de un consumidor arranca con ≈ 29 k tokens menos de contexto, y eso se repite en cada uno de sus turnos.

**Opciones**
- **(A) — recomendada: una lectura por rol, generada.** El arnés genera, para cada rol, **un archivo con la concatenación exacta de sus bloques** (por ejemplo `lectura-analista.md`). Es **derivado**, como el bloque de ESTADO: no es una segunda redacción, y el banco comprueba byte a byte que coincide con las marcas. La definición lo lee de **una vez**: un `Read`, pocos turnos y ≈ 45 KB en vez de 75. `arnes-init` y `arnes-upgrade` lo generan en los proyectos. Además se cierra el hueco de la plantilla («ámbito alcanzado → `Seguridad: pendiente`»). Luego se repite la medida. *Consecuencia:* una pasada más del desarrollador, ≈ 100–150 k, más QA y seguridad.
- **(B):** aceptar lo medido (USD −13 % y tokens +17 % en el analista), cerrar el hueco de la plantilla y seguir. *Consecuencia:* por tu métrica de tokens, el analista empeora en este caso.
- **(C):** la definición del analista lee `AGENTS.md` **entero, de una vez**, sin bloques, y el import sigue fuera. *Consecuencia:* pocos turnos y el ahorro de los subagentes se conserva, pero los ≈ 138 KB que lee el analista vuelven, y no se cumple tu objetivo de bytes.

**Coste de REQ-036 hasta aquí:** analista 191 274 (dos agentes) · desarrollador **527 679** (pasó el aviso de 1,5× por ≈ 2,7 k, con tu autorización) · prueba de conducta: 6 corridas a ≈ 0,27–0,31 USD cada una.

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-Z (A): lectura por rol generada y comprobada por el banco, una sola lectura por comisión; se cierra el hueco de Seguridad en ámbito alcanzado; se repite la medida con claude -p.

### RESUELTA (propietario, 2026-10-26) — **P-137-Y (A)**: `CLAUDE.md` deja de importar `@AGENTS.md` (plantilla, `arnes-upgrade` y este repositorio); medida con `claude -p` aislado; el desarrollador puede pasar de su presupuesto; recordatorio de inicio de sesión si no cuesta en el camino común

**Texto del propietario, literal** (mensaje del 2026-10-26 a la sesión coordinadora del worktree `ArnesJuan-v1.36`; lo envió dos veces seguidas, y se registra una):

> Adopto P-137-Y (A): CLAUDE.md deja de importar @AGENTS.md y lleva sólo
> la instrucción corta («lee AGENTS.md según tu rol, por sus marcas; la
> coordinadora lo lee entero al empezar»). Aplica a la plantilla de
> CLAUDE.md, a arnes-upgrade y también al CLAUDE.md de este repositorio.
> Acepto la medida corregida (claude -p aislado, --plugin-dir, tokens del
> JSON de uso). Autorizo que el desarrollador pase de su presupuesto para
> esta pasada; el aviso de 1,5× sigue en pie.
> Salvaguarda: si se puede sin coste en el camino común, el hook de inicio
> de sesión recuerda a la coordinadora que lea AGENTS.md entero; si no,
> queda como instrucción en CLAUDE.md y se declara.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Comprobado:** hoy `hooks/hooks.json` no registra ningún hook de inicio de sesión (sólo `PreToolUse`, `Stop` y `SubagentStop`). Un `SessionStart` corre **una vez al abrir la sesión principal** —no en cada orden ni en los subagentes—, así que **no toca el camino común**. Se hace, y por eso REQ-036 pasa a tocar `hooks/`, que es crítico: el ciclo lleva seguridad, como ya tenía.
- **Presupuesto del desarrollador:** lleva 357 467; el aviso de 1,5× está en 525 k.
- **Orden:** el analista nuevo (Sonnet) transcribe P-137-Y en REQ-036; después, un desarrollador nuevo en Opus explícito; luego, las 4 corridas con `claude -p` aislado (la coordinadora), QA y seguridad.

### P-137-Y (texto de la consulta, conservado; resuelta arriba) — **REQ-036: `CLAUDE.md` importa `@AGENTS.md` entero en el contexto de todo agente, así que la lectura por destinatario no baja lo que recibe.** ¿Cómo seguimos?

**Qué pasó.** El desarrollador terminó la fase 1, **sin validar**:
- lo que la definición del analista le manda leer mide **74 294 B** (antes 138 574), dentro de tus 75 KB;
- banco 3029/0/14 (3043); autoprueba 117/0; `hooks/` sin diff.

Pero registró **D-036-1**, y la coordinadora lo confirma: `templates/CLAUDE.md.tpl` (l. 6) y el `CLAUDE.md` de este repositorio importan **`@AGENTS.md`**, y Claude Code lo inyecta **entero en el contexto de cada agente, subagentes incluidos**. Esta sesión y sus subagentes lo reciben así. Consecuencias:
1. **En un consumidor, lo inyectado no baja.** La lectura por destinatario sólo ahorra lo que el agente **vuelve a leer**. Y la plantilla de `AGENTS.md` **creció** de 69 888 a 74 863 B por las marcas, así que lo inyectado **sube ≈ 5 KB**.
2. **La medida de PC-034-1 no ve esto.** El proyecto de prueba no tiene `CLAUDE.md`, y sus corridas eran subagentes de esta sesión. Sus ≈ 88 k por corrida incluyen el `AGENTS.md` de **este** repositorio, ≈ 75 KB inyectados, además de los 138 KB leídos del proyecto. La coordinadora no lo vio al explicarte el coste.

**Qué detiene, y qué no.** Detiene QA de REQ-036, porque validaría un objetivo que en la práctica no se cumple. Lo construido sirve para cualquiera de las opciones.

**Opciones**
- **(A) — recomendada:** **`CLAUDE.md` deja de importar `@AGENTS.md`.** En su lugar lleva una instrucción corta: lee `AGENTS.md` según tu rol, por sus marcas, y la coordinadora lo lee entero al empezar (§0). **Nada normativo se mueve ni se duplica:** `AGENTS.md` sigue siendo la sede y lo leen también otras herramientas. *Riesgo:* que la sesión principal no lea `AGENTS.md` entero. Lo controla la instrucción del propio `CLAUDE.md`, y las invariantes de máquina siguen en los hooks, que no dependen de él. *Alcance nuevo:* `templates/CLAUDE.md.tpl` y `arnes-upgrade` para `CLAUDE.md`; y, si lo autorizas, el `CLAUDE.md` de **este** repositorio, que hoy inyecta ≈ 78 KB a cada subagente.
- **(B):** se mantiene el import y lo que hay que achicar es **`AGENTS.md` mismo**: las reglas de la coordinadora y §13 pasan a archivos por rol. *Consecuencia:* **mueve normativa**, en contra de tu «nada normativo se mueve», y crea sedes nuevas.
- **(C):** se cierra 4a tal cual, y se declara que en consumidores con el import el ahorro es sólo de relectura. *Consecuencia:* el objetivo de P-137-W no se cumple en la práctica.

**Medida corregida, para cualquier opción** (lo decide la coordinadora por fidelidad, y te lo informa): CA-02 se mide con **`claude -p`** en el proyecto de prueba, con su `CLAUDE.md` de plantilla y el plugin del candidato (`--plugin-dir`), aislado de este repositorio. Los tokens salen del JSON de uso; son 4 corridas, como en PC-034-1.

**Coste hasta aquí (REQ-036):** analista 124 089 · desarrollador **357 467** (≈ 350 k, 1,02×).

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-Y (A): CLAUDE.md sin import de AGENTS.md, con instrucción de lectura por rol; también en este repositorio. CA-02 se mide con claude -p aislado.

### RESUELTA (propietario, 2026-10-21) — **P-137-X (D)**: lectura por destinatario; criterio de éxito de hasta 75 KB con 4/4; la salvaguarda de QA bloque por bloque; si no hay raíz del plugin demostrable, lo explicativo se queda en el proyecto

**Texto del propietario, literal** (mensaje del 2026-10-21 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-X (D): lectura por destinatario. Cada bloque normativo de
> AGENTS.md y del README declara a quién obliga; cada definición de agente
> lee los suyos; la coordinadora lo lee todo. Lo explicativo sale a
> docs/explicacion/ dentro del plugin, con puntero.
>
> Criterio de éxito ajustado: el objetivo sigue siendo < 70 KB para el
> analista, pero acepto hasta 75 KB medidos si la prueba de conducta da 4/4;
> no paso a (C) por unos pocos KB. Sólo si (D) mide por encima de 75 KB se
> evalúa (C), con la cifra delante.
>
> Salvaguarda obligatoria: QA comprueba bloque por bloque que todo agente
> obligado por una regla la tiene entre sus lecturas, y lo deja en una tabla
> en la evidencia. Si un bloque no tiene obligado claro, lo lee todo el
> mundo (ante la duda, se lee).
> Si no se demuestra cómo un agente del consumidor encuentra la raíz del
> plugin, lo explicativo se queda en el proyecto y se declara.

**Lo que añade la coordinadora, rotulado como suyo:** el analista transcribe la decisión en REQ-036 y lo pasa a `pendiente`. Después, la fase 1 al desarrollador en Opus explícito.

### P-137-X (texto de la consulta, conservado; resuelta arriba) — **REQ-036 (4a): mover sólo lo explicativo no llega a 70 KB. ¿Cómo se alcanza el objetivo?** (Q-036-1)

**Qué pasó.** El analista escribió REQ-036 en `borrador`, con 13 CA, y paró en tu parada: «que no se alcance el objetivo». Su estimación es **por muestreo, no medida** (no tiene consola): mover lo explicativo e histórico saca ≈ 29–40 KB, y la lectura quedaría en **≈ 100 KB**. Casi todo §6 y §13 es normativo.

**Lo que midió la coordinadora** (plantilla de `AGENTS.md`, en bytes): §6 = 37 295, y de eso son **reglas de la coordinadora** el bloque de las seis reglas (8 921), el de vías, despacho y comprobación (6 730), el mecanismo de la cola (1 956) y el paralelo (≈ 970), **≈ 18,6 KB**. §13 = 21 312, que aplican desarrollador, QA y seguridad. En el README de requisitos, «Veredictos de validación» (9 006) y «Clases de hallazgo» (7 828) son sobre todo de QA, seguridad y la puerta. **Lo que sí es del analista:** el nivel de rigor, qué es crítico, la escritura de criterios, `Archivos:`, la trazabilidad y §9.

**Qué detiene, y qué no.** Detiene la fase 1 de REQ-036. Nada más está en curso.

**Opciones**
- **(A):** aceptar lo que dé mover sólo lo explicativo, ≈ 100 KB (−28 %). *Consecuencia:* no cumple tu objetivo.
- **(B), la del analista:** la definición del analista no lee §13. *Consecuencia:* ≈ 80–85 KB estimados; tampoco llega.
- **(D) — recomendada, de la coordinadora:** **lectura por destinatario**. Cada bloque normativo de `AGENTS.md` y del README declara **a quién obliga**, y la definición de cada agente le manda leer **los suyos**. La coordinadora, que orquesta, sigue leyendo todo. Además, lo explicativo sale con su puntero. **Nada normativo se mueve ni se condensa:** cada regla sigue donde la lee quien debe cumplirla. *Estimación:* ≈ 65–75 KB; las secciones están medidas y el reparto es estimación mía. *Riesgo:* que un agente deje de leer una regla que le obliga. *Control:* QA comprueba que todo bloque normativo tiene al menos a su obligado entre sus lectores, y la prueba de conducta da 4/4.
- **(C):** condensar la redacción normativa, con revisión de equivalencia por seguridad. *Consecuencia:* es la única que asegura bajar de 70 KB y la que más arriesga el significado. **Sólo** si (D) no llega, y con el número medido delante.

**Coste hasta aquí:** analista 116 926 (≈ 170 k para su rol).

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-X (D): lectura por destinatario en `AGENTS.md` y en el README, más lo explicativo fuera con punteros; nada normativo se mueve ni se condensa. Si no llega a 70 KB, vuelve con el número medido antes de (C).

### RESUELTA (propietario, 2026-10-21) — **P-137-W adoptada: 1.37 · 4 autorizada**; `arnes-upgrade` muestra antes el diff; lo explicativo de un consumidor, preferiblemente dentro del plugin; parada entre 4a y 4b

**Texto del propietario, literal** (mensaje del 2026-10-21 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-W, con:
> - arnes-upgrade lleva la versión delgada a los proyectos instalados,
>   conservando lo que cada proyecto escribió en sus propios bloques; antes
>   de aplicarla muestra el diff de lo que sale y adónde va. La prueba se
>   hace en Adelantos después de publicar 1.37, como con 1.35.0.
> - Lo explicativo en un consumidor: decide el analista en la fase 0; mi
>   preferencia es que viva dentro del plugin (consultable, no leído en cada
>   comisión), no copiado en cada proyecto.
> - Los seis problemas de F-137-22, como los anotaste.
> - Parada entre 4a y 4b como propones.

**Lo que añade la coordinadora, rotulado como suyo:** las precisiones prevalecen sobre la autorización conservada debajo. La prueba en el proyecto consumidor es **posterior a publicar 1.37**, así que no entra en el ciclo de REQ-036. Fase 0 de 4a despachada al analista en Sonnet; desarrollador y QA, en Opus explícito.

### P-137-W (texto de la propuesta, conservado; adoptada arriba con sus precisiones) — **1.37 · 4: adelgazar lo que lee el analista y partir REQ-007. Autorización lista para adoptar**

**Punto de partida, medido** (los cuatro archivos que lee el analista de un consumidor, en bytes): la plantilla de `AGENTS.md`, 69 888 (§6 ocupa 37 295 y §13, 20 898); la del README de requisitos, 43 245 (las cinco secciones mayores van de 5 a 10 KB); la definición del analista, 15 471; el manifiesto con sus `_doc`, 9 970. **Total, ≈ 138 KB.** Para bajar de 70 KB hay que **recortar ≈ 70 KB**, casi todo de §6, §13 y el README. En este repositorio, `AGENTS.md` pesa 75 448, `requirements/README.md` 78 607 y REQ-007 479 582.

> ## Autorización — 1.37 · 4
>
> ## Decisiones del propietario
> - **Objetivo medible:** lo que lee el analista por comisión baja de ≈ 138 KB a **menos de 70 KB**. Se verifica **repitiendo la prueba de conducta de PC-034-1** (4 corridas, el mismo proyecto y los mismos encargos) con **el mismo resultado 4/4** y su coste por corrida.
> - **Nada se pierde:** lo normativo queda en el sitio que lee el agente; lo histórico y lo explicativo pasan a `docs/` con punteros. Salvaguardas de F-136-17: lo que cita un hallazgo abierto no se mueve; cada bloque movido deja un puntero con ruta, ancla e identificadores; antes de mover, se barren las citas.
> - **Dentro:** PR-137-1/2, qué archivos van **siempre por `Edit`** aunque ninguna puerta los mire; y F-137-19, borrar texto propio de la misma intervención no cuenta como pasada.
> - **Proyectos ya instalados:** `arnes-upgrade` les lleva la versión delgada **conservando lo que el proyecto escribió en sus bloques propios**. Si no, el ahorro no les llega. *(Si prefieres sólo proyectos nuevos por ahora, dilo al adoptar.)*
> - La coordinadora decide sola lo que no cambie una protección, un alcance o un riesgo, y lo informa al cierre.
>
> ## Plan autorizado (cada fase termina en commit local en `cand/1.37.0`)
> **4a — adelgazar** (REQ-036, `critico`): las plantillas de `AGENTS.md` y del README, la definición del analista, los `_doc` del manifiesto, `arnes-upgrade` y, con la misma estructura, `AGENTS.md` y `requirements/README.md` de este repositorio.
> - Fase 0, analista (Sonnet): el contrato corto. Qué es normativo y qué no, dónde va lo explicativo de un consumidor (que no tiene el `docs/` de este repositorio), y cómo se mide «lo que lee».
> - Fase 1, desarrollador (Opus). Fase 2, QA (Opus). Fase 3, seguridad (Opus).
> - Verificación: la prueba de conducta repetida.
>
> **4b — partir REQ-007** (F-137-9): el analista escribe el contrato de la partición y **para antes de ejecutar** (P-137-F); luego ejecución, QA y seguridad. Su ahorro es de este repositorio, no de los consumidores.
>
> ## Presupuesto (calibrado sobre REQ-034, 773 k, y REQ-035, 960 k más 355 k de conducta)
> **4a:** analista ≈ 170 k · desarrollador ≈ 350 k · QA ≈ 250 k · seguridad ≈ 200 k · conducta ≈ 200 k (4 corridas con menos lectura) · **≈ 1,17 M**.
> **4b:** analista ≈ 150 k · ejecución ≈ 150 k · QA ≈ 200 k · seguridad ≈ 150 k · **≈ 650 k**.
> Aviso a 1,5× por rol. **Entre 4a y 4b, parada con la cifra medida**: si 4a no baja de 70 KB, se decide antes de seguir.
>
> ## Cuándo paras y me preguntas (sólo esto)
> Mover algo que pudiera reducir una protección; que no se alcance el objetivo; el contrato de 4b antes de ejecutar; pasar de 1,5× en un rol; publicar.
>
> ## Tope
> Dos pasadas correctivas por REQ; borrar texto propio no cuenta.

**Decisión propuesta, lista para adoptar:** «Adopto P-137-W.»

### RESUELTA (propietario, 2026-10-21) — **P-137-V adoptada: spike de la puerta posterior**; y **ajuste del plan**: 1.37 · 4 va antes del REQ completo de la puerta posterior, con un objetivo medible

**Texto del propietario, literal** (mensaje del 2026-10-21 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-V: spike de la puerta posterior en spike/1.37-3-puerta-posterior,
> desarrollador en Opus, aviso a 225k, sin entrar en cand/1.37.0 ni
> instalarse.
>
> Ajuste del plan: después del spike, 1.37 · 4 (adelgazar AGENTS.md y el
> README de requisitos, y partir REQ-007) va ANTES del REQ completo de la
> puerta posterior. La prueba de conducta mostró que leer reglas cuesta ~88k
> por comisión del analista en cualquier proyecto; ese es el ahorro más
> amplio que queda, y abarata también el REQ de la puerta posterior.
> Objetivo medible de 1.37 · 4: lo que lee el analista por comisión baja de
> ~138 KB a menos de 70 KB, verificado con la misma prueba de conducta.

**Lo que añade la coordinadora, rotulado como suyo:**
- **El spike vive en su propio worktree,** `/home/juan/dev/ArnesJuan-spike-1.37-3`, en la rama `spike/1.37-3-puerta-posterior`, que sale de `cand/1.37.0` en **`7e84a2c`** *(corrección del 2026-10-21: aquí se escribió primero `a625c4f`, pero la rama se creó después del commit de este registro)*. Así no toca `cand/1.37.0` ni el árbol de esta sesión.
- **El orden del plan queda así:** 1.37 · 3a, el spike; luego 1.37 · 4, adelgazar y partir REQ-007, con el objetivo de bajar de ≈ 138 KB a menos de 70 KB, medido con la prueba de conducta de PC-034-1; luego 1.37 · 3b, el REQ completo de la puerta posterior; luego 1.37 · 5.

### P-137-V (texto de la propuesta, conservado; adoptada arriba) — **1.37 · 3, spike de la puerta posterior (≈ 150 k): autorización lista para adoptar**

**Dos cosas que la coordinadora comprobó y que la autorización recoge:**
1. **Un spike que no se publica no es un REQ.** Si el prototipo vive en una rama propia, **no entra en `cand/1.37.0`**, no se instala y no gobierna nada, entonces no lleva el ciclo de cuatro fases de `AGENTS.md` §6, que es para lo que llega a los proyectos. Así cabe en ≈ 150 k: un analista sólo para leer las reglas ya gasta ≈ 88 k (PC-034-1). Lo que salga del spike entra después como **REQ con su ciclo completo**, presupuestado con la cifra medida.
2. **El requisito de la pieza b** (P-032-6 (2)): «la puerta posterior no puede depender sólo del manifiesto que vigila». Por eso el spike vigila una **lista fija** —`.arnes/config.json` y `hooks/`— que no lee del manifiesto.

> ## Autorización — 1.37 · 3, spike de la puerta posterior
>
> ## Decisiones del propietario
> - **Alcance, sólo esto:** un prototipo de puerta posterior que, alrededor de cada orden de `Bash`, toma una **foto** (huella) de `.arnes/config.json` y de `hooks/` **antes y después**, y **deniega** si cambió sin ser el agente de código. La lista es fija y no depende del manifiesto.
> - **Qué mide** (contra v1.36.2 instalada):
>   - detección, con éxito sobre intentos, en las formas que hoy escapan: SEC-135 (`cp … 2>/dev/null` a `hooks/`), SEC-136 (`rm hooks/x`), SEC-137 (`mv hooks …`), SEC-138 (vaciar el manifiesto) y la escritura por intérprete (`python3` a `hooks/`, la clase de PR-137-2);
>   - falsos positivos en órdenes legítimas (`ls`, `git status`, escribir fuera de lo vigilado);
>   - coste por orden, en ms y procesos;
>   - **qué puede hacer de verdad un «deny» después de la orden**: bloquear, restaurar desde la foto o avisar. Esta respuesta es parte del resultado.
> - **No entra en `cand/1.37.0`:** vive en la rama `spike/1.37-3-puerta-posterior` y se prueba con `ARNES_HOOKS_DIR` en proyectos efímeros. No se instala, no gobierna esta sesión y no se publica.
>
> ## Plan autorizado
> Desarrollador (**Opus explícito**): prototipo, casos y medida, con un informe en `docs/arnes/v1.37.0-spike-puerta-posterior.md` en la rama del spike. La coordinadora verifica las cifras y te trae el resultado y el presupuesto del REQ de la pieza b.
>
> ## Presupuesto
> **≈ 150 k en total**, con aviso a 1,5× (225 k).
>
> ## Cómo se decide
> Lo que no cambie una protección, un alcance o un riesgo, lo decide la coordinadora sola y te lo informa al cierre.
>
> ## Cuándo paras y me preguntas (sólo esto)
> Que el spike necesite tocar `cand/1.37.0` o la instalación estable; que una forma de vigilar cambie una protección vigente; pasar de 225 k; publicar.

**Decisión propuesta, lista para adoptar:** «Adopto P-137-V.»

### RESUELTA (propietario, 2026-10-21) — **QA-035-04 a REQ-021**; el residual del modelo por defecto se cierra **por proceso**; **dos condiciones de coste para 1.37 · 3**

**Texto del propietario, literal** (mensaje del 2026-10-21 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> QA-035-04: ficha de REQ-021 (sonda de procesos), no de la pieza b; baja
> prioridad, sin fecha.
>
> Residual del modelo por defecto: se mantiene sonnet en la cabecera (es el
> ahorro para los proyectos), y se cierra por proceso: cada despacho de un
> REQ crítico registra el modelo efectivo en la evidencia, y QA lo comprueba
> antes de aprobar. Ficha para la puerta posterior: si es comprobable
> mecánicamente, que lo sea.
>
> Antes de preparar 1.37 · 3: dame el resultado de la prueba de conducta
> (qué Rigor: escribió el analista en cada una de las cuatro corridas) y por
> qué costó 355k.
>
> Para 1.37 · 3, dos condiciones de coste:
> - Empieza por un spike acotado (≈150k): la puerta posterior sólo sobre
>   .arnes/config.json y hooks/, con foto antes/después y deny. Con esa cifra
>   medida se presupuesta el resto.
> - Menos paradas a mitad: lo que no cambie una protección, un alcance o un
>   riesgo lo decide la coordinadora sola y me lo informa al cierre.

**Lo que añade la coordinadora, rotulado como suyo:**
- **QA-035-04 es F-137-20** (REQ-021, sonda de procesos; baja; sin fecha). Sale de la fila de la pieza b.
- **El modelo efectivo, por proceso, es F-137-21.** Desde hoy, cada despacho de un REQ `critico` registra el modelo efectivo en su evidencia: el recuento de `"model"` en los turnos del asistente de su transcripción. QA lo comprueba antes de aprobar. Va también como ficha de la puerta posterior: que sea mecánico si se puede.
- **La prueba de conducta** se respondió en el mensaje que acompaña esta entrada. Está en PC-034-1 y en el árbol de evidencia, `1.37-1-conducta/`.
- **La autorización del spike de 1.37 · 3 es P-137-V**, en `## Pendientes`.

### RESUELTA (propietario, 2026-10-21) — **P-137-U (A)**: C3 se queda en (b); precisión a la regla del inventario; CA-04 fail-before en (a), sin cambios; QA re-verifica y entra seguridad

**Texto del propietario, literal** (mensaje del 2026-10-21 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-U (A): C3 se queda en (b). Es una decisión sobre la serie
> completa, con su propio filtro de ruido, y sólo corre con
> ARNES_SONDA_CONTROLES=1. Precisión a la regla, para el inventario: una
> sonda cuyo resultado es un juicio que ya distingue ruido de avería (FAIL
> sólo con avería demostrada) es (b) aunque use el reloj. REQ-017 CA-04
> fail-before se queda en (a) sin cambios. QA re-verifica y entra seguridad.
>
> Sigue sin respuesta: el modelo efectivo con que corrieron el desarrollador
> (369k) y QA en REQ-035. Necesito saberlo antes de la firma de seguridad.

**Lo que añade la coordinadora, rotulado como suyo:**
- **El modelo efectivo**, recontado el 2026-10-21 sobre las transcripciones, sólo en los turnos `"role":"assistant"`:
  - desarrollador del banco (≈ 295 k de los 369 k), **`claude-opus-5-5` en 222 de 222**;
  - desarrollador de textos (≈ 74 k), **Opus en 37 de 37**;
  - QA, **Opus en 126 de 126**;
  - analista, Sonnet en 101 de 101.

  **Ninguna comisión de REQ-035 que debía ir en Opus corrió en Sonnet.** La misma cifra está en la resolución de P-137-T.
- La precisión a la regla la escribe el analista en el inventario. Después, QA re-verifica en Opus explícito, y entra seguridad en Opus.

### P-137-U (texto de la consulta, conservado; resuelta arriba) — **C3 mide reloj, al contrario de lo que suponía «como C3» de P-137-T. ¿Pasa a (a) o se queda en (b) por ser una decisión?**

**Qué se releyó** (el analista y la coordinadora, en el código):
- **REQ-017 CA-04 fail-before** (`37-coste-del-escaner-2-las-razones.sh` l. 295-303) compara una **razón de µs** entre v1.32.1 y v1.32.0 contra 2,000×, en **una medida que corre siempre**. Por tu regla es **(a)**, ya va a INCONCLUSO (`coste_inconcluso`) y **no cambia nada**. **QA-035-02 queda resuelto así.**
- **C3** (l. 263-270) compara un **cociente medido con reloj** contra 2,6× (`sonda_juez_control_c3 … 2600`). Por la letra de tu regla sería **(a)**, y tu «como C3» suponía (b). Pero tiene dos rasgos que la regla no contempla:
  1. **Es un control a demanda:** sin `ARNES_SONDA_CONTROLES=1` da `SKIP «no se pide»`. **Nunca pone rojo el CI ni el banco normal.**
  2. **Su juez ya separa el ruido** (`run.sh`, `sonda_juez_control_c3`). Da INCONCLUSO si falta línea base, si hay pocas corridas resueltas o si caen a ambos lados del techo. Sólo da FAIL con **«AVERÍA DEMOSTRADA»**: todas las corridas resueltas por debajo del techo. Es una **decisión** tomada sobre la serie entera.

**Qué detiene, y qué no.** Detiene la re-verificación de QA, porque (B) cambiaría código. Con (A) no hay nada que tocar, y QA sigue.

**Opciones**
- **(A) — recomendada:** C3 **se queda en (b)** como **decisión** («avería demostrada»), que tu regla manda a (b) («si mide procesos o **una decisión**»). *Consecuencia:* sin cambio de código; el inventario lo dice con estas líneas. La pasada 1 se cierra y QA re-verifica ya.
- **(B):** C3 a **(a)**: su «avería demostrada» pasa a INCONCLUSO. *Consecuencia:* hay que tocar el juez en `run.sh` y el control WD de 37/7, que necesita ver ese FAIL (lo advirtió el desarrollador). Es más trabajo y una pasada más, y un instrumento averiado de verdad dejaría de verse, aunque sólo cuando se pide el control.

**Coste de REQ-035 hasta aquí:** analista 159 201 · desarrollador 369 193 · QA 222 483 · **750 877**; falta seguridad.

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-U (A): C3 se queda en (b) como decisión («avería demostrada», a demanda); CA-04 fail-before sigue en (a); QA-035-02 resuelto; QA re-verifica.

### RESUELTA (propietario, 2026-10-21) — **P-137-T**: REQ-017 CA-04 fail-before se clasifica **por lo que mide**, releyendo la línea; desarrollador y QA, **Opus explícito** en este repositorio; PR-137-2 a 1.37 · 4 y a la pieza b

**Texto del propietario, literal** (mensaje del 2026-10-21 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-137-T: REQ-017 CA-04 fail-before se clasifica por lo que mide. Si su
> veredicto depende del reloj (el árbol viejo supera un techo de coste), es
> clase (a), INCONCLUSO al salirse de banda. Si mide procesos o una decisión,
> es (b), como C3. El analista relee la línea antes de clasificar, como
> hiciste tú con 33-…-2, y el desarrollador ajusta según eso. Cierra la
> pasada 1; sigue con QA y seguridad.
>
> Y confírmame el modelo efectivo con que corrieron el desarrollador de
> textos y el del banco en REQ-035 (crítico). Si alguno fue Sonnet,
> regístralo para QA. Desde aquí, en este repositorio, desarrollador y QA se
> despachan con Opus explícito. PR-137-2 a la ficha de 1.37 · 4 y como caso
> de prueba de la puerta posterior en 1.37 · 3.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Modelo efectivo, medido en las transcripciones**, contando sólo los turnos del asistente: desarrollador del banco, **Opus** (222 de 222); desarrollador de textos, **Opus** (37 de 37); QA, **Opus** (126 de 126); analista, **Sonnet** (92 de 92). **Ninguno de los dos desarrolladores corrió en Sonnet**, así que no hay nada que registrar para QA. Un registro con «opus» en la transcripción del analista es un resultado de herramienta, no un turno.
- **Desde el 2026-10-21, en este repositorio, desarrollador y QA se despachan con `model: opus` explícito**, sea cual sea el rigor.
- **PR-137-2:** a la fila 1.37 · 4 de `docs/PLAN.md` (qué archivos van siempre por `Edit` aunque ninguna puerta los mire) y como **caso de prueba de la puerta posterior** en 1.37 · 3: una edición de `AGENTS.md` por un intérprete, que la pieza b tiene que ver.
- **QA-035-02:** el analista relee la línea de REQ-017 CA-04 fail-before y la de C3 y las clasifica por lo que miden; el desarrollador ajusta según eso; así se cierra la pasada 1.

### P-137-T (texto de la consulta, conservado; resuelta arriba) — **REQ-035, QA-035-02: REQ-017 CA-04 fail-before, ¿(a) o (b)?** Te di una premisa inexacta en P-137-S

**Qué pasó.** En P-137-S escribí que, «por la regla del inventario», `REQ-017 CA-04 fail-before` (37/2) es (a), y adoptaste D2 sobre esa frase. **QA en Opus demuestra que no es exacta** (`docs/qa/REQ-035.md`, QA-035-02, `contrato`). Esa sonda no da FAIL porque una medida supere un techo: da FAIL cuando el árbol **enfermo** (el que se construye lento a propósito) **no** supera 2×. Es decir, cuando el instrumento **no detecta** la regresión que debería ver. Es la misma forma que el control **C3** de 37/2, que el inventario deja en **(b)** como «avería del instrumento». Hoy el banco trata distinto dos casos iguales.

**Qué detiene, y qué no.** Detiene **cerrar** REQ-035 (QA `con-hallazgos`). Lo demás sigue: el analista completa el inventario (QA-035-01) en paralelo, sin depender de esto.

**Opciones**
- **(A) — recomendada:** pasa a **(b)**, como C3. Un fail-before que comprueba que el instrumento ve una regresión es **lógica del instrumento**, no coste. Si deja de verla, debe ser rojo. *Riesgo de ruido bajo:* el árbol enfermo se hace lento a propósito y la carga frena por igual a los dos. *Consecuencia:* el desarrollador deshace el traductor en un solo sitio y el analista corrige su línea, ≈ 10–15 k dentro de la pasada correctiva 1. El banco sigue en 0 FAIL salvo que el instrumento se averíe.
- **(B):** queda en (a) y **C3 también pasa a (a)**, por coherencia: todo control con reloj de un instrumento deja de poner rojo. *Consecuencia:* un instrumento que deja de detectar regresiones pasa sin verse. Como las sondas de coste ya no bloquean, eso no abre nada que bloquee hoy, pero la pieza b y F-137-18 dependen de que los instrumentos sirvan.
- **(C):** se deja como está, con la descripción exacta registrada. *Consecuencia:* el banco mantiene dos casos iguales en clases distintas.

**Además, registrado y sin reparar** (`instrumento`, preexistentes, dueño `desarrollador`): **QA-035-03**, ningún vector prueba la puerta de calibración de `sonda_usable`; **QA-035-04**, la sonda de procesos **no cuenta una orden con ruta absoluta** (`/bin/true`), así que un fork por ruta absoluta pasa la puerta de «0 procesos añadidos». La segunda importa para cualquier contrato de coste en procesos; propongo que vaya a la pieza b.

**Coste de REQ-035 hasta aquí:** analista 149 517 · desarrollador 369 193 (banco y textos; 1,42×) · QA **222 483** (en Opus, 1,31×) · seguridad pendiente · **total 741 193**, sobre ≈ 730 k sin la prueba de conducta.

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-T (A): REQ-017 CA-04 fail-before pasa a (b), como C3; QA-035-04 a la pieza b.

### RESUELTA (propietario, 2026-10-21) — **P-137-S**: D1 (A), con un registro de calibración fijo; D2, las dos sondas a (a); los textos se adelantan en paralelo; REQ-035 vuelve a `pendiente`

**Texto del propietario, literal** (mensaje del 2026-10-21 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-S:
> - D1 (A): REQ-021 CA-10 y CA-10.2 con registro de calibración fijo; se
>   demuestra mutando el juez (sigue dando FAIL). Clase (b), veredicto.
> - D2: el analista añade REQ-021 CA-03 (c) y REQ-017 CA-04 fail-before al
>   inventario como clase (a); el desarrollador las trata igual que las
>   demás. Objetivo: banco a 0 FAIL.
> - Autorizo adelantar los textos (CA-05 a CA-08) en paralelo; no dependen
>   del banco. REQ-035 vuelve a pendiente.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Orden:** el analista (Sonnet) primero, con el inventario y el write-back de D1. Después, el desarrollador del banco (Opus, retomado), con D1, D2 y D3.
- **En paralelo con los dos**, un desarrollador **nuevo** (Opus, REQ `critico`) **sólo** para los textos: `AGENTS.md` §5, `templates/AGENTS.md.tpl` §5 y `agents/*.md`. Sus archivos no coinciden con los del banco ni con el inventario, y **no escribe en REQ-035**. La disyunción la declara el propietario; `tools/arnes-paralelo.sh` no la puede medir, porque decide por REQ y aquí hay uno solo.
- REQ-035 `bloqueado` → `pendiente`, con una fila de Historial.

### P-137-S (texto de la consulta, conservado; resuelta arriba) — **REQ-035: el desarrollador paró en tu parada.** Dos casos de veredicto dependen del reloj real, y dos sondas de reloj faltaban en el inventario

**Qué pasó.** El banco está hecho, **sin validar**:
- 17 casos de clase (a) pasan a INCONCLUSO, con fail-before contra `ca6eb53`.
- Los controles de clase (b) siguen en FAIL, idénticos en los dos árboles: un hook que no responde (07, 08, 25 y los 8 plazos de la 47), un proceso añadido y un `deny` que pasa a `allow`.
- `hooks/` y `tools/` tienen 0 bytes de diff.
- Banco 3004 PASS, 1 FAIL, 14 SKIP (3019); autoprueba 117/0.

Los textos (CA-05 a CA-08) **no** se han hecho, porque mandaste el banco primero. REQ-035 está `bloqueado` (B-035-1).

**D1 — tu parada («una sonda que no se sepa si es coste o veredicto»).** `REQ-021 CA-10` y `CA-10.2` (`38-…-3-la-descendencia.sh`) son **lógica del juez**, clase (b). Pero no le dan al juez un registro fijo: leen la **calibración real del reloj de la corrida**. Con la máquina cargada, la calibración se sale de su banda y estos dos casos dan **FAIL en los dos árboles**. El desarrollador lo reprodujo; es INS-034-2.
- **(A) — recomendada:** **desacoplarlos**. Se les da un registro de calibración **fijo**, en vez del de la corrida. Siguen siendo (b), comprueban la misma lógica del juez y dejan de depender de la carga. Se acredita con una **mutación del juez**, que tiene que seguir dando FAIL. *Consecuencia:* ≈ 20–30 k del desarrollador. No es «cambiar el caso para que pase»: lo que cambia es la entrada, y la propiedad probada es la misma.
- **(B):** cuando la calibración real que leen está fuera de banda, **heredan el INCONCLUSO**. *Consecuencia:* es más barato, pero la lógica del juez deja de probarse justo cuando la máquina va cargada.
- **(C):** dejarlos así. *Consecuencia:* el CI puede salir rojo por carga.

**D2 — dos sondas con reloj que el inventario no recoge** (CA-01):
- `REQ-021 CA-03 (c)` (38/2) compara microsegundos medidos contra `suelo × (margen − 1)`. Es **el único FAIL** del banco, y también falla en `ca6eb53` con carga.
- `REQ-017 CA-04 fail-before` (37/2) mide con reloj.

Por la regla del inventario («una magnitud medida con reloj que supera un techo o sale de su banda»), las dos son **(a)**.
- **Recomendación:** que el analista las añada al inventario como (a), y el desarrollador las pase por el mismo traductor. *Consecuencia:* el banco puede llegar a 0 FAIL (CA-04).

**Qué detiene, y qué no.** Detiene el banco de REQ-035, y por tanto **cerrar** REQ-035. Los textos de CA-05 a CA-08 no dependen de esto. Tu orden fue «primero el banco», así que **esperan** a que decidas, salvo que digas otra cosa.

**Coste hasta aquí (REQ-035):** analista 144 102 (presupuesto ≈ 130 k) · desarrollador **256 486** (presupuesto ≈ 260 k; su informe decía ≈ 175 k), con los textos y la pasada de D1/D2 todavía por hacer. Previsión del desarrollador: ≈ 320–340 k, **1,25–1,3×**, por debajo del aviso de 1,5× (390 k).

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-S: D1 (A), CA-10 y CA-10.2 con un registro de calibración fijo, acreditado con una mutación del juez; D2, las dos sondas al inventario como (a). Después, los textos de CA-05 a CA-08.

### RESUELTA (propietario, 2026-10-21) — **P-137-R adoptada: 1.37 · 2, modelo por rol, autorizada**; los plazos son veredicto; desarrollador y QA según el rigor

**Texto del propietario, literal** (mensaje del 2026-10-21 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-R, con:
> - Los plazos (SEC-115, sección 47 y cualquier otra que garantice que el
>   hook decide a tiempo) son veredicto: siguen dando FAIL. Sólo las sondas
>   de coste y calibración pasan a INCONCLUSO. El analista hace primero el
>   inventario sonda por sonda.
> - Desarrollador: Sonnet en ligero y estándar, Opus en crítico. La regla
>   completa: analista Sonnet siempre; desarrollador y QA según rigor
>   (Sonnet en ligero/estándar, Opus en crítico); seguridad Opus. La cabecera
>   model: de cada agente lleva el modelo por defecto (Sonnet en analista,
>   desarrollador y QA; Opus en seguridad) y quien despacha sube a Opus en
>   crítico.
> - La prueba de conducta usa la definición del analista del candidato, y el
>   registro lo dice.

**Lo que añade la coordinadora, rotulado como suyo:**
- Las precisiones de arriba prevalecen sobre la autorización conservada debajo.
- **Esta intervención es `critico`**, por la política de autoalojamiento. Por la regla nueva: analista en Sonnet, y desarrollador, QA y seguridad en Opus.
- **La prueba de conducta** usa la definición del analista copiada de `cand/1.37.0` en `f5f002d`, la de REQ-034, antes de que la fase 1 la toque.
- Fase 0 despachada.

### P-137-R (texto de la propuesta, conservado; adoptada arriba con sus precisiones) — **1.37 · 2, modelo por rol: autorización lista para adoptar**

**Tres cosas que la coordinadora comprobó y que la autorización recoge:**
1. **Un plazo no es un coste.** La sección 47 (`47-decision-emitida.sh`) prueba que el hook **emite su decisión** antes de 40 s (SEC-115). Si pasara a INCONCLUSO, un hook que el cliente mata sin denegar dejaría de verse. Por eso la autorización lo trata como **veredicto**, y sigue dando FAIL.
2. **La cabecera de un agente declara un solo modelo** (`model:` en `agents/*.md`; hoy: analista `opus`, QA `sonnet`, desarrollador `opus`, seguridad `opus`). «QA en Opus si el REQ es crítico» no cabe ahí: lo aplica **quien despacha**, con el parámetro `model`. Por eso la regla se escribe en §5 y en las definiciones, y la cabecera lleva el modelo por defecto.
3. **La prueba de conducta necesita el analista NUEVO.** El agente instalado es el de 1.36.2, que no conoce la política. La prueba tiene que correr con la definición del candidato (`agents/analista-requerimientos.md` de `cand/1.37.0`) y decir cuál usó.

> ## Autorización — 1.37 · 2, modelo por rol
>
> ## Decisiones del propietario
> - **Primero, P-137-K en todo el banco:** toda sonda de **reloj o calibración** que pase su techo da INCONCLUSO. Sólo dan FAIL los **procesos** y los **veredictos**, y un **plazo que decide si una decisión se emite** (sección 47, SEC-115) cuenta como veredicto. El analista hace antes el inventario de las sondas, una línea por sonda. Cierra INS-033-1, INS-034-1 e INS-034-2.
> - **La regla del modelo por rol:** en `ligero` y `estandar`, analista y QA en Sonnet; en `critico`, analista en Sonnet, y QA y seguridad en Opus. El desarrollador, en Opus. Se escribe en `AGENTS.md` §5 de este repositorio, en `templates/AGENTS.md.tpl` §5 y en las definiciones de agente: analista `sonnet`, QA `sonnet` por defecto y `opus` en `critico` al despachar. Sustituye el bloque «QA corre con Opus en el autoalojamiento».
> - **Contratos cortos:** el analista escribe lo **mínimo verificable**, no todo lo previsible. Rige en esta intervención, y se escribe en una frase de su definición.
> - **Tope: dos pasadas correctivas.** Borrar texto propio de la misma intervención **no cuenta**. La regla general para la plantilla sigue siendo F-137-19, de 1.37 · 4.
>
> ## Plan autorizado (cada fase termina en commit local en `cand/1.37.0`)
> Fase 0 — analista (Sonnet): REQ-035, contrato corto, con el inventario de sondas (reloj o calibración frente a plazo o veredicto) y la regla de §5.
> Fase 1 — desarrollador (Opus): el banco primero, luego los textos: §5 de este repositorio y de la plantilla, y las cuatro definiciones. Banco completo y autoprueba.
> Fase 2 — QA (**Opus**: el REQ es `critico`). Fase 3 — seguridad (Opus), sólo con QA favorable. Puede vetar.
> Fase 4 — la coordinadora cierra REQ-035 con `Edit` juzgado en vivo y registra la métrica frente a 1.37 · 1.
> **En paralelo, la prueba de conducta de 1.37 · 1** (la coordinadora; no toca el repositorio): un proyecto de prueba en el scratchpad con los cinco ámbitos declarados; el analista **candidato** (Sonnet) recibe dos encargos, un cambio normal y uno de dinero, **dos veces cada uno**. Se registra qué `Rigor:` escribe en cada corrida. El resultado va a `docs/PENDIENTES.md` y al árbol de evidencia, sin reparar nada.
>
> ## Presupuesto (calibrado sobre lo medido en 1.37 · 1: 171/261/170/171 k)
> Analista ≈ 130 k (por debajo de lo medido; si el contrato corto no lo baja, se verá) · desarrollador ≈ 260 k · QA ≈ 170 k · seguridad ≈ 170 k · prueba de conducta ≈ 60 k · **total ≈ 790 k**. Aviso a 1,5× por rol.
>
> ## Cuándo paras y me preguntas (sólo esto)
> Una sonda que no se sepa si es coste o veredicto; tocar `hooks/`; un veredicto del banco que cambie en un caso que ejecuta el código del cambio; un veto de seguridad; pasar de 1,5× en un rol; publicar.
>
> ## Límites
> Nada de 1.37 · 3 a 5. Sólo §5 de `AGENTS.md` de este repositorio. Push: recordármelo al final de cada fase. Fusión, tag y publicación: míos.

**Decisión propuesta, lista para adoptar:** «Adopto P-137-R.» Si quieres al desarrollador en Sonnet en `ligero` y `estandar`, dilo al adoptar; la regla de arriba no lo nombra, y la coordinadora lo deja en Opus.

### RESUELTA (propietario, 2026-10-21) — **P-137-Q (A)**, como excepción explícita y única: sólo borrar «y no rebaja nada» en los cuatro sitios; y una **regla nueva para la plantilla**: corregir borrando no es una pasada

**Texto del propietario, literal** (mensaje del 2026-10-21 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-Q (A), como excepción explícita y única a la regla de
> «bloqueado sin más vueltas»: se autoriza sólo borrar «y no rebaja nada» en
> los cuatro sitios, sin escribir texto nuevo. Comprobación de QA y firma de
> seguridad. Si seguridad no firma, REQ-034 se queda bloqueado y la frase
> queda borrada igualmente.
>
> Para la plantilla (regla nueva, no excepción): una corrección que SÓLO
> borra texto introducido en la misma intervención, sin añadir nada, no
> cuenta como pasada correctiva. Cualquier corrección que añada texto, sí.

**Lo que añade la coordinadora, rotulado como suyo:**
- **El borrado lo hace el analista**, porque el write-back de un hallazgo es suyo en este repositorio (`AGENTS.md` §9). Después, comprobación de QA y re-firma de seguridad. REQ-034 sigue `bloqueado` hasta la firma.
- **La regla nueva para la plantilla es la ficha F-137-19** (`docs/PENDIENTES.md`). Cambia la norma de «Loop de error» que heredan los proyectos (`templates/AGENTS.md.tpl` §6), así que es cambio de contrato y **no** se escribe en esta intervención. Va con 1.37 · 4, adelgazamiento de `AGENTS.md`, salvo que el propietario la quiera antes. **No toca el `AGENTS.md` de este repositorio**, que no se edita.

### P-137-Q (texto de la consulta, conservado; resuelta arriba) — **REQ-034 `bloqueado`, como ordenaste: la tercera pasada no cerró por una frase falsa. ¿Se queda así o autorizas quitar esa frase?**

**Qué pasó.** La tercera pasada resolvió **SEC-139**, declarado como riesgo y ya `instrumento` para este REQ, y **SEC-140**, `mitigado`. QA aprobó sobre `bd48920`. Pero la re-firma de seguridad (adenda a R-061, 2026-10-21) deja **SEC-141 abierto** (`contrato`, baja) por una frase **que la propia pasada introdujo**: «Vaciar un ámbito a `[]` lo deja sin declarar y **no rebaja nada**». Es **falsa**. Sin declarar, rige la regla de antes, y un cambio de texto de `AGENTS.md` puede nacer `ligero`; con el ámbito arnés declarado, ese mismo cambio es `critico`. La frase exime de la firma del auditor justo esa palanca. **El error es de una premisa de R-061**, que el analista copió y QA no vio; el auditor lo corrige en su adenda.

**Lo que hizo la coordinadora, por tu regla** («Si no cierra, REQ-034 pasa a bloqueado sin más vueltas»): REQ-034 **`bloqueado`**, con su fila de Historial y la del índice. No se abrió ninguna vuelta más.

**El bloqueo** (`AGENTS.md` §6, regla 2):
- **(i) Qué impide:** **cerrar** REQ-034 (`guard-completado`, con un `contrato` abierto) y **publicar** 1.37.0 por delegación con REQ-034 dentro.
- **(ii) Qué parte afecta:** sólo una frase, en cuatro sitios: `requirements/REQ-034.md:84`, `requirements/README.md:173`, `templates/requirements-README.md.tpl:173` y el `_doc` de `templates/arnes-config.json.tpl:58`. El código, `hooks/` y el banco no.
- **(iii) Evidencia:** la adenda a R-061 en `docs/seguridad/registro-seguridad.md`, y `requirements/README.md:158-161` (sin declarar = como antes).
- **(iv) Qué lo resuelve:** quitar «y no rebaja nada» en los cuatro sitios. La regla general de la línea anterior ya cubre vaciar un ámbito.

**Opciones**
- **(A) — recomendada, como excepción a tu regla y diciéndolo:** autorizar **sólo** borrar esas cuatro palabras en los cuatro sitios, sin texto nuevo. Después, comprobación de QA y re-firma, ≈ 25–35 k en total. *Por qué:* el defecto lo introdujo una premisa del revisor, no el trabajo; el arreglo es borrar, no escribir. Y lo construido —390 decisiones sin ninguna diferencia, el banco y la orden de `arnes-upgrade`— quedaría acreditado. *Consecuencia:* REQ-034 puede cerrar, y la regla «sin más vueltas» queda con una excepción tuya registrada.
- **(B):** se queda **`bloqueado`**, como ordenaste. *Consecuencia:* 1.37 · 1 no se acredita; lo construido queda en la rama; la frase falsa sigue en lo que heredarían los proyectos, y habría que quitarla antes de publicar 1.37 con cualquier otro REQ. Se sigue con 1.37 · 2.

**Coste de REQ-034 hasta aquí:** analista 167 612 · desarrollador 260 921 · QA 160 332 · seguridad 163 492 · **total 752 357**, contra ≈ 670 k (1,12×). Ningún rol pasa de 1,5×; el analista está en 1,40×.

**Decisión propuesta, lista para adoptar** (si eliges A):
> Adopto P-137-Q (A), como excepción a «sin más vueltas»: sólo borrar «y no rebaja nada» en los cuatro sitios, sin texto nuevo; QA comprueba y seguridad re-firma. Si no cierra, REQ-034 se queda bloqueado.

### RESUELTA (propietario, 2026-10-21) — **P-137-P (A)**: tercera pasada, sólo texto, limitada a SEC-139, SEC-140 y SEC-141; SEC-139 se resuelve declarando el riesgo; ficha de puerta para la pieza b

**Texto del propietario, literal** (mensaje del 2026-10-21 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-P (A): tercera pasada, sólo texto, limitada a SEC-139, SEC-140
> y SEC-141. Si no cierra, REQ-034 pasa a bloqueado sin más vueltas.
>
> SEC-139 se resuelve escribiendo el riesgo, no ocultándolo: el ahorro del
> ligero descansa en el juicio del analista al clasificar, y así se declara
> en CA-07, en el README de requisitos y en las notas. Ficha para la pieza b
> (no ahora): al cerrar un REQ ligero, si sus cambios tocan rutas de los
> cinco ámbitos declarados, el cierre exige estandar. Eso convierte el juicio
> del analista en algo que la máquina comprueba.

**Lo que añade la coordinadora, rotulado como suyo:**
- Es la vuelta 3 de 3 de dev↔QA de REQ-034.
- **Orden:** el analista primero, con CA-07, la sede de `requirements/README.md` y su gemela, y el párrafo para las notas `[1.37.0]` en un borrador; después el desarrollador, con la lista y el `_doc` de la plantilla, que corre el banco sobre todo; luego la comprobación de QA y la re-firma de seguridad.
- **La ficha de la puerta es F-137-18**, en `docs/PENDIENTES.md` y en la fila 1.37 · 3 de `docs/PLAN.md`.

### P-137-P (texto de la consulta, conservado; resuelta arriba) — **REQ-034: seguridad encontró tres hallazgos de texto con el tope agotado. ¿Una tercera pasada, sólo de texto?** (R-061)

**Qué pasó.** Seguridad (R-061, 2026-10-19) dio `con-hallazgos`, **sin veto**. La puerta no abre nada: `hooks/` no cambia, y en **384 decisiones** propias comparadas con v1.36.2 no hay ninguna diferencia, con la política declarada, malformada o ausente. Tu parada no se activa. Los hallazgos son de **texto que heredan los proyectos**, clase `contrato`:
- **SEC-139 (media):** la reducción de revisión descansa en **un solo juicio**, el del analista, y no se declara. Si clasifica como «normal» un cambio que toca dinero, sesión, seguridad o datos, el REQ cierra sin QA ni seguridad, y las tres salvaguardas dependen de ese mismo juicio: el suelo de sensibilidad, «ante la duda, completo» y el auditor que sube el rigor, que nunca recibe el REQ. *Resolución:* declararlo en CA-07 y en la sede. Analista.
- **SEC-140 (baja):** la lista precargada del ámbito arnés no incluye `PENDING_APPROVAL.md`, que la puerta lee. *Resolución:* añadirlo y marcar la lista como no exhaustiva. Desarrollador.
- **SEC-141 (baja):** la norma contra rebajar la política habla de «quitar un glob o vaciar un ámbito». Pero vaciar a `[]` **sube** la revisión, y la palanca real, declarar `"ninguno"`, no se nombra. *Resolución:* escribirla por propiedad: todo cambio que reduzca lo que alcanza un ámbito exige la firma del auditor. Analista, en CA-07 y la sede, y desarrollador, en el `_doc` de la plantilla.

**Por qué te lo pregunto.** REQ-034 gastó sus **dos pasadas correctivas**, una por QA-034-01 y otra por QA-034-02, y a la tercera se decide contigo (P-137-L; `AGENTS.md` §6, regla 5). Agotar el tope no aprueba nada.

**Qué detiene, y qué no.** Impide **cerrar** REQ-034, porque `guard-completado` deniega con un `contrato` abierto, y **publicar** 1.37.0 con REQ-034 dentro por delegación. No impide empezar a preparar 1.37 · 2.

**Opciones**
- **(A) — recomendada:** una **tercera pasada, sólo de texto**, acotada a SEC-139, SEC-140 y SEC-141. El analista escribe CA-07 y la sede; el desarrollador, la lista y el `_doc` de la plantilla. Después, comprobación corta de QA y re-firma de seguridad. Es la **vuelta 3 de 3** de dev↔QA: si no cierra, REQ-034 pasa a `bloqueado`, sin cuarta. *Consecuencia:* ≈ 50–60 k más, sin tocar código ni `hooks/`. Cabe en el techo de texto de CA-11 (van 3 020 de 4 096 B), y REQ-034 puede cerrar.
- **(B):** REQ-034 a **`bloqueado`**, con los tres hallazgos abiertos. *Consecuencia:* 1.37 · 1 no se cierra; lo construido queda en la rama sin acreditar, y 1.37 no se publica por delegación con él dentro.

**Coste hasta aquí (REQ-034):** analista 151 536 · desarrollador 256 034 · QA 146 607 · seguridad 148 882 · **total 703 059**, sobre el ≈ 670 k. Ningún rol pasa de 1,5×. Seguridad estimó «≈ 75 k» en su informe; la notificación dice 148 882.

**Dato para 1.37 · 2 (modelo por rol):** QA en Sonnet aprobó sin ver tres hallazgos de texto que seguridad en Opus sí encontró. Es la segunda vez, tras SEC-137 y SEC-138 en 1.36.2.

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-P (A): tercera pasada sólo de texto, acotada a SEC-139, SEC-140 y SEC-141; es la vuelta 3 de 3 y, si no cierra, REQ-034 pasa a bloqueado.

### RESUELTA (propietario, 2026-10-19) — **P-137-O: 1 (A), 2 (A)**; P-137-K queda en la sección 49 y el inventario de sondas de reloj va a la pieza b; «como hoy» conserva el `ligero` de lo sin lógica

**Texto del propietario, literal** (mensaje del 2026-10-19 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-O: 1 (A), 2 (A). Sin declarar los cinco ámbitos, el ligero de
> cambios sin lógica sigue como hoy; lo que no se aplica es la ampliación a
> todo cambio normal. El analista reescribe CA-04, CA-09, CA-10 y la skill en
> ese sentido; QA re-verifica, incluida la autoprueba por separado; después
> seguridad. F-137-17 registrada.

**Lo que añade la coordinadora, rotulado como suyo:**
- El punto 1 (A) lleva a la fila 1.37 · 3 de `docs/PLAN.md` el inventario previo de las sondas de reloj: cuáles son operativas y cuáles contrato de tiempo, y qué pasa con cada una.
- La Correspondencia de REQ-034 declara la acotación de CA-13 con esta autorización citada.
- El write-back es del analista; es la vuelta 1 de 3 de dev↔QA del REQ, y no hay pasada del desarrollador.

### P-137-O (texto de la consulta, conservado; resuelta arriba) — **REQ-034, fase 1 entregada: dos lecturas de tus decisiones que conviene que confirmes** (QA sigue mientras tanto)

**Qué detiene, y qué no** *(actualizado tras QA, 2026-10-16)*. **Ahora detiene la intervención.** QA dio `con-hallazgos` por **QA-034-01** (`contrato`): CA-04, CA-09 y CA-10 dicen «`ligero` no se aplica», y lo construido conserva el de lo sin lógica. Es exactamente la pregunta 2. Hasta que decidas no se puede escribir el write-back, QA no re-verifica y seguridad no empieza: sólo entra con QA favorable (`AGENTS.md` §6). El código y el banco están limpios: 3002/0/12, y ningún cierre denegado pasa a `allow` en 42 combinaciones. Si eliges ampliar en la pregunta 1, añade una pasada del desarrollador, que no gasta vuelta del tope porque no viene de un hallazgo.

**1. ¿P-137-K alcanza a todas las sondas de reloj o sólo a las de la sección 49?** Tu decisión dice «una sonda de reloj que pasa su techo en el CI da INCONCLUSO», y que entra en «la intervención que toque el banco primero». Esta intervención lo toca. El contrato (CA-13), en cambio, lo **acotó** a «las sondas de reloj operativas de la sección 49 (INS-033-1) y nada más», y la Correspondencia no lo declaró como diferencia. El desarrollador lo implementó así, con un fail-before forzado: 5 FAIL de reloj pasan a 5 INCONCLUSO. Quedan sondas de reloj en las secciones 25, 37 y 38, y en 1.36.1 una de ellas ya dio FAIL (INS-032-1). Algunas miden un **contrato que es de tiempo** (REQ-017 CA-08: «el análisis de `Bash` en el máximo baja de 5 s»), no una cifra operativa.
- **(A) — recomendada:** queda en la sección 49 en 1.37 · 1. El resto entra en la **pieza b (1.37 · 3)**, que rehace el banco de `Bash`, con un **inventario** previo del analista: cada sonda de reloj, si es operativa o contrato de tiempo, y qué pasa con ella. *Consecuencia:* 1.37 · 1 no crece. El rojo de `main` (INS-033-1) queda cerrado, y otra sonda de reloj puede dar un rojo hasta 1.37 · 3.
- **(B):** se amplía ahora a todas las sondas de reloj operativas. *Consecuencia:* una pasada más del analista (el inventario) y otra del desarrollador, ≈ 60–100 k; y hay que decidir sonda a sonda las que son contrato de tiempo.

**2. «Como hoy» conserva el `ligero` de lo que no tiene lógica.** Tu P-137-N dice «ligero no se aplica y el analista clasifica con los criterios de siempre (estandar, o critico si es sensible)» y «nunca sube el coste». Leído al pie de la letra, un proyecto instalado perdería el `ligero` que hoy usa para cambios sin lógica, y le subiría el coste. El desarrollador lo escribió como «**como antes de la política**»: el `ligero` ampliado no se aplica, y el de lo sin lógica sigue como estaba.
- **(A) — recomendada:** confirmar esa lectura. *Consecuencia:* cumple las dos frases a la vez.
- **(B):** al pie de la letra, sin ningún `ligero` hasta declarar los ámbitos. *Consecuencia:* sube el coste de los proyectos instalados que hoy usan `ligero`, que es lo que «nunca sube el coste» prohíbe.

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-O: 1 (A), con el inventario de sondas de reloj en la pieza b; 2 (A), «como hoy» = como antes de la política, incluido el `ligero` de lo sin lógica.

### RESUELTA (propietario, 2026-10-16) — **P-137-N (A)**: sin declarar los cinco ámbitos, el proyecto se comporta como hoy; nunca sube el coste de un proyecto instalado por actualizar

**Texto del propietario, literal** (mensaje del 2026-10-16 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-N (A): sin declarar los cinco ámbitos, el proyecto se
> comporta como hoy; ligero no se aplica y el analista clasifica con los
> criterios de siempre (estandar, o critico si es sensible). Nunca sube el
> coste de un proyecto instalado por actualizar. El analista corrige CA-04,
> CA-09 y CA-10 en una pasada corta; sigue con la fase 1.

**Lo que añade la coordinadora, rotulado como suyo:** el propietario hizo el push de `cand/1.37.0`, y está comprobado. El analista corrige los tres criterios y después va la fase 1.

### P-137-N (texto de la consulta, conservado; resuelta arriba) — **«Sin declarar, flujo completo»: ¿«como hoy» o «todo `critico`»?** (REQ-034, contradicción interna)

**Qué pasó.** Tu precisión en P-137-M dice «sin declarar, flujo completo». El analista la escribió como **`critico`**: en CA-04, CA-09 y CA-10, los REQ nuevos de un proyecto sin los cinco ámbitos declarados van «con QA y auditoría de seguridad» (l. 16). Pero en el mismo REQ, la pregunta 2 resuelta (l. 155–157) sigue diciendo, como la opción 2 (A) que adoptaste, que un proyecto instalado recibe el bloque **inerte** y **su comportamiento no cambia** hasta que lo completa. Las dos cosas no pueden ser ciertas a la vez.

**Qué detiene, y qué no.** Detiene la fase 1, para no implementar una de las dos lecturas y tener que rehacerla. Afecta a una regla del analista y a su texto en las plantillas, no a la puerta: en ninguno de los dos casos cambia `hooks/`, y ninguno baja un rigor.

**Opciones**
- **(A) — recomendada: «sin declarar = como hoy».** `ligero` no opera, y el analista clasifica con los criterios de siempre (`estandar`, o `critico` si es sensible o toca lo que el proyecto declara crítico). *Consecuencia:* un proyecto instalado no cambia hasta que declare sus ámbitos, que es lo que dice 2 (A). Ahorrar es opcional para quien lo active.
- **(B) — literal: «sin declarar = `critico`».** Todo REQ nuevo de un proyecto sin declarar lleva QA y seguridad. *Consecuencia:* sube el coste en **todos** los proyectos instalados desde que actualicen. Los empuja a declarar los ámbitos, pero contradice 2 (A) («inerte») y el objetivo del coste.

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-N (A): sin los cinco ámbitos declarados, ligero no opera y se clasifica como hoy; un proyecto instalado no cambia hasta que los declare. El analista lo corrige en CA-04, CA-09 y CA-10 y sigue la fase 1.

### RESUELTA (propietario, 2026-10-16) — **P-137-M: 1 (A), 2 (A), 3 (A)**; REQ-034 a `pendiente`, fase 1

**Texto del propietario, literal** (mensaje del 2026-10-16 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-M: 1 (A), 2 (A), 3 (A).
> - Ligero = el Rigor: ligero de hoy, ampliado a todo cambio fuera de los
>   cinco ámbitos; sin QA ni seguridad; REQ corto del analista.
> - Sólo funciona cuando el proyecto declara sus cinco ámbitos; sin
>   declarar, flujo completo. arnes-init los pregunta al instalar.
> - «Sesión» = identidad y autenticación del usuario final.
> Sigue con la fase 1.

**Lo que añade la coordinadora, rotulado como suyo:** el analista refleja la decisión en REQ-034, en las Preguntas abiertas y en la Correspondencia, con esta entrada como autorización citada, y lo pasa a `pendiente`. Después, la fase 1 al desarrollador en Opus.

### P-137-M (texto de la consulta, conservado; resuelta arriba) — **REQ-034 (1.37 · 1): tres preguntas del contrato antes de implementar** (`requirements/REQ-034.md` § «Preguntas abiertas», «Correspondencia con el encargo»)

**Qué detiene, y qué no.** REQ-034 está en `borrador` y **no se implementa** hasta que decidas (`AGENTS.md` §6, regla 1). No detiene nada más: no hay otra intervención en curso. Esta entrada impide **cerrar** un REQ mientras esté en la cola, y no hay ninguno que cerrar.

**Lo que el analista resolvió sin preguntarte, porque cabe en la autorización:** la puerta **no lee** la política. La aplica el analista al nacer el REQ, escribiendo `Rigor:`, así que `hooks/` no cambia y **tu parada no se activa**: ningún cierre que hoy se deniega pasa a `allow` (CA-06, con un diff vacío de `hooks/` y la misma batería de cierres con y sin la política).

**1. El flujo ligero.** Pediste «desarrollador → banco → hecho». Hoy `Rigor: ligero` es analista + desarrollador + quality gates, para cambios «sin lógica», y la puerta ya lo cierra sin QA.
- **(A) — recomendada:** el flujo ligero **es** el `ligero` de hoy, ensanchado a «normal: fuera de los cinco ámbitos». *Consecuencia:* se ahorran QA y seguridad, que es casi todo el coste. Queda un REQ corto del analista, porque omitirlo exige que cada proyecto declare la vía proporcional (§6).
- **(B):** además se omite al analista, como dice tu texto. *Consecuencia:* es otro contrato. Sólo vale donde el propietario de cada proyecto declare la vía proporcional, y el arnés no puede declararla por él.
- **(C):** lo normal sigue siendo `estandar`, con QA. *Consecuencia:* no ahorra lo que pediste.

**2. El defecto sin mapeo.** «Por defecto ligero» choca con «el arnés trae el mecanismo, nunca el mapeo».
- **(A) — recomendada:** `ligero` sólo opera cuando el proyecto declara sus cinco ámbitos. `arnes-init` los pregunta, y un proyecto ya instalado recibe el bloque **inerte** hasta que lo complete. Ante la duda, completo. *Consecuencia:* un proyecto nuevo ahorra desde el primer día; uno instalado, cuando rellena el bloque. Nadie trata un cobro como cambio normal sin haberlo dicho.
- **(B):** `ligero` opera desde el primer día en los proyectos instalados. *Consecuencia:* el máximo ahorro, pero baja en silencio la revisión de proyectos que no lo pidieron.

**3. «Sesión».** **(A) — recomendada:** la sesión del **usuario final**, es decir, identidad y autenticación. **(B):** la sesión de trabajo de los agentes. *Consecuencia de (B):* el ámbito cambia de sentido y el analista lo reescribe.

**Dato de coste, por si cambia algo:** el analista ya gastó **124 895 tokens** (frente a ≈ 120 k para todo su rol); su informe estimaba 60–70 k. Todavía no llega al aviso de 1,5× (180 k).

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-M: 1 (A), 2 (A), 3 (A). REQ-034 pasa a `pendiente` y sigue la fase 1.

### RESUELTA (propietario, 2026-10-16) — **P-137-L adoptada: 1.37 · 1, rigor proporcional por defecto, autorizada**; SEC-137 y SEC-138 a la pieza b; modelo por rol como **regla de 1.37**

**Texto del propietario, literal** (mensaje del 2026-10-16 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-L, con:
> - SEC-137 y SEC-138 a la fila 1.37 · 3 (pieza b); las notas publicadas no
>   se tocan.
> - Modelo por rol confirmado como regla de 1.37, no como excepción:
>   analista y QA en Sonnet, desarrollador y seguridad en Opus. Así entra en
>   §5 cuando 1.37 · 2 lo escriba.
> - Presupuesto ~670k con aviso a 1,5× por rol; tope de dos pasadas;
>   parada si el rigor derivado del manifiesto hace pasar un cierre que hoy
>   se deniega.
> Al cerrar: métrica por rol frente a 1.36.2.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Vigente:** la autorización de abajo, con estas precisiones, que prevalecen sobre su texto. El modelo por rol deja de ser una excepción y es la regla de 1.37; `AGENTS.md` §5 lo recogerá en 1.37 · 2, y hasta entonces su texto no se toca. Al cerrar, la métrica se compara con 1.36.2.
- **Hecho al registrar:** SEC-137 y SEC-138 añadidos a la fila 1.37 · 3 de `docs/PLAN.md`.
- **Fase 0 despachada:** al analista en Sonnet, que redacta REQ-034.

### P-137-L (texto de la propuesta, conservado; adoptada arriba con sus precisiones) — **1.37 · 1, rigor proporcional por defecto: autorización lista para adoptar**

**Tres cosas que la coordinadora comprobó, por escrito (`AGENTS.md` §6):**
1. **El analista no se omite.** Este proyecto no declara la vía proporcional, y además es una **capacidad nueva**, que lleva analista → desarrollador → QA → seguridad. Hace falta un REQ nuevo, **REQ-034**.
2. **SEC-137 y SEC-138: declarados, pero no a la pieza b, y te lo digo en vez de confirmarlo.**
   - Las notas `[1.36.2]` los declaran los dos, con su forma y su severidad, pero cada uno termina en «**A 1.37**», no en «a la pieza b».
   - La fila 1.37 · 3 de `docs/PLAN.md` sólo nombra SEC-135, SEC-136 y el hueco C.
   - Encajan en la pieza b: SEC-137 es una forma de `Bash` que una puerta posterior cierra como clase, y SEC-138 cae bajo su requisito («no depende sólo del manifiesto que vigila»).
   - La autorización los lleva allí. Al adoptarla, añado SEC-137 y SEC-138 a esa fila. Las notas publicadas no se reescriben.
3. **P-137-K (A) entra aquí si esta intervención toca el banco**, que es lo esperable si cambia algo que el banco certifica. Si no lo toca, va a la siguiente intervención que lo haga.

> ## Autorización — 1.37 · 1, rigor proporcional por defecto
>
> ## Decisiones del propietario
> - **Alcance, sólo esto:** lo que un proyecto hereda (plantillas, `arnes-init`/`arnes-upgrade`, agentes) trae el **flujo ligero por defecto** para lo normal, y el **completo** para dinero, sesión, seguridad, datos y el propio arnés. La política se declara en `.arnes/config.json` del proyecto.
> - **Este repositorio no cambia de política:** todo REQ del arnés sigue `critico` por autoalojamiento. Ni `AGENTS.md` ni el `.arnes/config.json` de este repo se tocan.
> - **El suelo no se toca:** `Sensible a seguridad: sí` sigue imponiendo `critico`; el auditor sube el rigor; nadie lo baja sin su firma.
> - **SEC-137 y SEC-138 van a la pieza b (1.37 · 3)** junto con SEC-135 y SEC-136.
> - **QA y analista en Sonnet**, como en 1.36.2, extendiendo mi excepción a §5 a esta intervención. Desarrollador y seguridad, en Opus. *(Dato de 1.36.2: QA en Sonnet no vio dos hallazgos preexistentes que encontró seguridad.)*
>
> ## Plan autorizado (cada fase termina en commit local en `cand/1.37.0`; la siguiente empieza sin pedir permiso)
> Fase 0 — analista: REQ-034 con contrato corto. Qué es «lo normal» y qué es «completo», con los cinco ámbitos. Dónde vive la política y quién la aplica al nacer un REQ. Qué heredan los proyectos ya instalados. El fail-before y los controles: lo que hoy es `critico` sigue siéndolo.
> Fase 1 — desarrollador: plantillas, skills y agentes; los casos del banco con fail-before; P-137-K si toca el banco; el banco completo y la autoprueba.
> Fase 2 — QA: el fail-before, el pass-after y el banco, e intentar romperlo; sobre todo, que nada que hoy exige seguridad deje de exigirla.
> Fase 3 — seguridad, sólo con QA favorable. Puede vetar.
> Fase 4 — analista: write-back. La coordinadora cierra REQ-034 con `Edit` juzgado en vivo, hace commit validado y registra la métrica por rol. No se publica: 1.37 sale entera.
>
> ## Presupuesto (calibrado sobre lo real de 1.36.2, no sobre la estimación anterior)
> Total de cada rol en 1.36.2, incluidas sus pasadas: analista 113 k, desarrollador 277 k, QA 124 k, seguridad 135 k; en total, 649 k. **Para 1.37 · 1: ≈ 120 k analista, ≈ 280 k desarrollador, ≈ 130 k QA, ≈ 140 k seguridad; total ≈ 670 k.** Cada agente se retoma entre sus fases en vez de lanzarse de nuevo. Si un rol pasa de 1,5× su cifra, la coordinadora para y me lo dice antes de seguir.
>
> ## Lo que decide la coordinadora sola
> El texto, el registro y los índices; el orden de los despachos; registrar defectos nuevos sin repararlos; aplicar el tope.
>
> ## Cuándo paras y me preguntas (sólo esto)
> - Un cambio de alcance.
> - Que el contrato exija que la **puerta** derive el rigor del manifiesto y con eso un cierre hoy denegado pase a `allow`: es un movimiento sobre una protección.
> - Tocar `hooks/` más allá de lo que el contrato declare.
> - Un veredicto del banco que cambie en un caso que ejecuta el código del cambio. Las sondas de reloj, `instrumento`.
> - Un veto de seguridad; pasar de 1,5× el presupuesto de un rol; publicar.
>
> ## Tope
> **Dos pasadas correctivas**; a la tercera se decide. Los contadores no se reinician.
>
> ## Si la sesión se corta
> Se lee este plan en la cola y en ESTADO, y se sigue desde la última fase comiteada.
>
> ## Límites
> Nada de 1.37 · 2 a 5. No se toca `AGENTS.md` ni `.arnes/config.json` de este repo. Push: recordármelo al final de cada fase. Fusión, tag y publicación: míos.

**Decisión propuesta, lista para adoptar:** «Adopto P-137-L.» Si corriges algo, basta con decir qué.

### RESUELTA (propietario, 2026-10-16) — **P-137-K (A)**: una sonda de reloj que pasa su techo en el CI da INCONCLUSO; el FAIL queda para los contratos que no dependen del reloj; entra en 1.37 en la intervención que toque el banco primero

**Texto del propietario, literal** (mensaje del 2026-10-16 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-K (A): una sonda de reloj que pasa su techo en el CI da
> INCONCLUSO (no acredita, no pone el CI en rojo); el FAIL queda para los
> contratos que no dependen del reloj (procesos, veredictos). Entra en 1.37
> sin hotfix, dentro de la intervención que toque el banco primero.
>
> Prepara la autorización de 1.37 · 1 (rigor proporcional por defecto), en
> una página, con presupuesto calibrado sobre las cifras reales de 1.36.2,
> no sobre la estimación anterior. Confirma en ella que SEC-137 y SEC-138
> están declarados en las notas [1.36.2] y van a la pieza b.

**Lo que añade la coordinadora, rotulado como suyo:** la decisión dice «procesos, **veredictos**», más que la propuesta, que decía sólo «procesos»; manda la tuya. La ficha INS-033-1 queda con su decisión. La autorización pedida es **P-137-L**, en `## Pendientes`. Push de `cand/1.37.0` hecho por el propietario y comprobado: `origin` = `d9f4b12`.

### P-137-K (texto de la consulta, conservado; adoptada arriba) — **Una sonda de reloj operativa que supera su techo en el CI, ¿FAIL o INCONCLUSO?** (INS-033-1)

**Qué pasó.** El CI de `main` sobre `46ee7ca` (run `38917844057`) dio **3 FAIL**; el del PR sobre `3a0e221` (run `38915129365`), 0. **Mismo árbol** (`dd3e505`). Los tres son las sondas de reloj de REQ-033 CA-06, por rama, contra el techo operativo de **1,30×**: 1,33× (`mv` con origen protegido), 1,47× (`rm` del manifiesto), 1,31× (`Write` vacío). El contrato de **procesos** (0 / +1 / +2) no falló. No se relanzó.

**Qué detiene, y qué no.** No detiene nada ahora: no hay REQ que cerrar y 1.36.2 ya está publicada. Pero el CI de `main` queda en rojo, y cualquier PR de 1.37 hereda las mismas sondas, así que puede salir rojo por el ruido del ejecutor. **Sigue el trabajo** que no depende de esto: preparar la autorización de 1.37 · 1. Esta entrada impide **cerrar** un REQ mientras esté en la cola (`guard-completado`), y nada más.

**Opciones**
- **(A) — recomendada.** Una sonda de reloj **operativa** que supera su techo da **INCONCLUSO de rendimiento**, que no acredita y no hace rojo. El FAIL queda para lo que es contrato: los **procesos**. Entra en 1.37 con el primer cambio del banco, sin hotfix. *Consecuencia:* el CI deja de ponerse rojo por ruido, y el reloj sigue medido y a la vista, como cifra. Es lo que ya dice P-137-J: las sondas de reloj se registran como `instrumento` (P-136-E).
- **(B)** Subir el techo, por ejemplo a 1,60×. *Consecuencia:* menos rojos, pero el número sigue siendo arbitrario frente al ruido del ejecutor (el `rm` llegó a 1,47×), y volverá a fallar alguna vez.
- **(C)** Dejarlo como está. *Consecuencia:* `main` sigue en rojo y cada PR de 1.37 puede salir rojo por ruido. Eso empuja a relanzar hasta ver verde, que es justo lo que no se hace.

**Decisión propuesta, lista para adoptar:**
> Adopto P-137-K (A): una sonda de reloj operativa que supere su techo da INCONCLUSO de rendimiento, no FAIL; el FAIL queda para el contrato de procesos. Entra en 1.37 con el primer cambio del banco, sin hotfix. El rojo de `main` sobre `46ee7ca` queda registrado como INS-033-1 y no se relanza.

### RESUELTA (propietario, 2026-10-16) — **v1.36.2 PUBLICADA** (`main` `46ee7ca`, tag `v1.36.2`, PR #62); registrar, actualizar la instalación estable y seguir con el paso 2b

**Texto del propietario, literal** (mensaje del 2026-10-16 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Publicada: main <cabeza de la fusión>, tag v1.36.2, PR #62. Registra la
> publicación con el CI (run 38915129365), actualiza la instalación estable y
> sigue con el paso 2b: fusión de main en cand/1.37.0 y reconciliación del
> plan. Tráeme en el mismo resumen la métrica de 1.36.2: tokens por rol
> frente al presupuesto (~410k) y frente a 1.36.0 y 1.36.1, y cómo le fue a
> QA en Sonnet (hallazgos, pasadas).

**Lo que añade la coordinadora, rotulado como suyo:**
- **Comprobado en el remoto:** PR #62 `MERGED` 2026-10-16T14:41:44Z; `main` = `46ee7ca`, la cabeza de la fusión que el mensaje dejaba por rellenar; tag anotado `v1.36.2` (`8fe4fa7`) → `46ee7ca`.
- **CI:** el run que cita el propietario, `38915129365`, es el del **PR** sobre `3a0e221`: **success** (2922/0/38). El de **`main`** sobre `46ee7ca`, con el mismo árbol, es `38917844057`: **failure** (2919/3/38), tres sondas de reloj. `instrumento` (INS-033-1) y decisión en P-137-K, arriba.
- **Instalación estable 1.36.2** (`user` y `project`, `46ee7ca`; `hooks/` idéntico al tag). Rige desde el próximo reinicio.
- **Paso 2b:** hecho en `cand/1.37.0` (ESTADO, bloque vigente).

### RESUELTA (propietario, 2026-10-16) — **P-137-J adoptada con sus tres decisiones de redacción: hotfix 1.36.2 mínimo autorizado**

**Texto del propietario, literal** (mensaje del 2026-10-16 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-J, con sus tres decisiones de redacción:
> - AGENTS.md no se toca; SEC-135 y SEC-136 sólo en las notas.
> - QA en Sonnet en esta intervención, como excepción a §5 decidida por mí;
>   el cambio de §5 entra en 1.37 con el modelo por rol.
> - Cierras REQ-033 con Edit al final de la fase 4.
> Al cerrar, la métrica de tokens por rol frente a 1.36.0 y 1.36.1, y la
> calidad de QA en Sonnet: hallazgos que encontró, pasadas que hicieron falta.

**Lo que añade la coordinadora:** la medida de tokens se toma del uso que el arnés de Claude Code informa por comisión, sumado por rol, y se dice cómo se obtuvo. La calidad de QA en Sonnet se registra con sus hallazgos, su clase y las pasadas que hicieron falta, y con lo que encontraran después seguridad o la coordinadora y QA no vio.

### P-137-J (texto de la propuesta, conservado; adoptada arriba) — **Hotfix 1.36.2 mínimo: autorización lista para adoptar** (sustituye a P-137-I, retirada)

**Dos cosas que la coordinadora comprobó y que la autorización recoge:** (1) este proyecto no declara la vía proporcional (`AGENTS.md` §6) y hace falta un REQ nuevo (REQ-033), así que el analista no se omite, como pediste; (2) `AGENTS.md` §5 manda QA en Opus en este repositorio, y **tu decisión lo sustituye para esta intervención**: QA y analista en Sonnet.

> ## Autorización — hotfix 1.36.2 mínimo (una sesión)
>
> ## Decisiones del propietario (2026-10-15; sustituyen lo que en P-032-6 (1) y (2) decía de 1.36.2)
> - **Alcance, sólo esto:** borrar, mover o vaciar `.arnes/config.json` se deniega a todo agente; y se juzga el **origen** de `mv`, porque mover un archivo protegido es escribirlo.
> - **Fuera:** SEC-135 pasa entero a la pieza b de 1.37; `rm`, `unlink` y `git rm` (SEC-136), también a 1.37. Los dos se declaran en las notas `[1.36.2]` con sus formas exactas; SEC-135, con su gravedad alta.
> - **Tope: una pasada correctiva.** Si no cierra, 1.36.2 se publica sin esa parte, y la parte que no cerró se declara.
>
> ## Plan autorizado (cada fase termina en commit local; la siguiente empieza sin pedir permiso)
> Fase 0 — analista (**Sonnet**): REQ-033, un contrato corto. Las dos propiedades; el fail-before contra v1.36.1 (`rm .arnes/config.json`, `mv .arnes/config.json x`, `: > .arnes/config.json`, `mv hooks/lib.sh docs/x.md`, `mv hooks/lib.sh docs/PLAN.md`); los controles (lo legítimo sigue igual); y las notas como entregable.
> Fase 1 — desarrollador (Opus): el arreglo, los casos del banco con su fail-before, el banco completo, la autoprueba y la versión 1.36.2. Sin procesos nuevos en el camino común.
> Fase 2 — QA (**Sonnet**): el fail-before y el pass-after, el banco, e intentar romperlo. Una pasada correctiva como máximo.
> Fase 3 — seguridad (Opus), sólo con QA favorable. Puede vetar.
> Fase 4 — analista (Sonnet): write-back y notas `[1.36.2]`. La coordinadora cierra REQ-033 con `Edit`, juzgado en vivo, y hace commit validado, push y CI. Y registra **la métrica**: tokens por rol en REQ-033, comparados con 1.36.0 y 1.36.1.
>
> ## Lo que decide la coordinadora sola
> Texto, registro e índices; orden y presupuesto de los despachos (orientativo: ≈ 60 k analista, ≈ 150 k desarrollador, ≈ 100 k QA, ≈ 100 k seguridad); registrar defectos nuevos sin repararlos; aplicar el tope (retirar la parte que no cierre y declararla); el push al cerrar y marcar el PR listo con el CI en verde.
>
> ## Cuándo paras y me preguntas (sólo esto)
> Cambio de alcance; un movimiento de `deny` a `allow` sobre algo protegido o fuera de lo declarado; un veredicto del banco que cambia en un caso que ejecuta el código del cambio (las sondas de reloj se registran como `instrumento`: P-136-E); un veto de seguridad; publicar, fusionar o etiquetar.
>
> ## Si la sesión se corta
> Se lee este plan en la cola y en ESTADO, y se continúa desde la última fase comiteada.
>
> ## Límites
> Rama `hotfix/1.36.2` (desde `e21baef`). **No se toca `AGENTS.md`:** SEC-135 y SEC-136 se declaran en las notas; §13 va con el adelgazamiento de 1.37. Nada de 1.37. **Lo que 1.36.2 no resuelve:** SEC-135, `rm`/`unlink`/`git rm` y el hueco C, que son de la pieza b, y su requisito: la puerta posterior no puede depender sólo del manifiesto que vigila. Push de la rama: recordármelo al final de cada fase. Fusión, tag y publicación: míos.

### RESUELTA (propietario, 2026-10-15) — **CORRECCIÓN DE RUMBO: P-137-I retirada; 1.36.2 mínima (una sesión); 1.37 empieza por el coste; métrica del objetivo: tokens por REQ cerrado**

**Texto del propietario, literal** (mensaje del 2026-10-15 a la sesión coordinadora del worktree `ArnesJuan-v1.36`; los encabezados `##` del original van citados con `> ` para no cerrar esta sección):

> No adopto P-137-I. La sustituye esta decisión del propietario; regístrala
> literal en la cola, docs/PLAN.md y ESTADO, y marca P-137-I como retirada.
>
> El objetivo del Arnés es que los agentes construyan software real con
> disciplina, RÁPIDO y con POCO COSTE. Las últimas versiones han pagado
> demasiado por perseguir formas de bash; se corrige el rumbo.
>
> ## 1.36.2 — mínima (una sesión)
> Alcance, sólo esto:
> - Borrar, mover o vaciar .arnes/config.json → deny a todo agente.
> - Juzgar el ORIGEN de mv (mover un archivo protegido = escribirlo).
> Fuera: SEC-135 pasa entero a la pieza b de 1.37 (la puerta posterior
> cierra la clase sin perseguir formas). Se declara en las notas [1.36.2] con
> sus formas exactas y su gravedad alta. rm/unlink/git rm, igual: 1.37.
> Tope: una pasada correctiva. Si no cierra, se publica sin esa parte.
> Ciclo: analista (contrato corto) → desarrollador → QA → seguridad; QA y
> analista en Sonnet para esta intervención.
>
> ## 1.37 — empieza por el coste, en este orden
> 1. Rigor proporcional por defecto: flujo ligero (desarrollador → banco →
>    hecho) para cambios normales; flujo completo sólo para dinero, sesión,
>    seguridad, datos y el propio Arnés. Política en .arnes/config.json.
> 2. Modelo por rol: analista y QA de rutina en Sonnet; Opus para
>    desarrollador en trabajo difícil y para seguridad. /compact entre fases.
> 3. Pieza b: puerta posterior (qué cambió después de cada orden), con el
>    requisito del manifiesto; cierra SEC-135, SEC-136 y el hueco C.
> 4. F-137-9 (partir REQ-007) y adelgazamiento de AGENTS.md.
> 5. Plan de desarrollo; spike de mod; 2b.
> Tope por intervención: dos pasadas correctivas; a la tercera se decide.
>
> ## Métrica del objetivo
> Tokens por REQ cerrado, por rol, en el Arnés y en SENDA. Se registra al
> cerrar cada intervención y se compara con 1.36.0. Si 1.37 no la baja, se
> para y se revisa.
>
> Prepara la autorización nueva de 1.36.2 con este alcance, lista para
> adoptar. Debe caber en una página.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Lo que esta decisión sustituye:** P-137-I (retirada, abajo) y, en lo que decían de 1.36.2, P-032-6 (1) y (2). **SEC-135 entero** y `rm`/`unlink`/`git rm` de SEC-136 **pasan a la pieza b de 1.37**. Se conservan el requisito de la pieza b (la puerta posterior no depende sólo del manifiesto) y la fusión de `main` en `cand/1.37.0` tras 1.36.2.
- **Registrado también** en `docs/PLAN.md` de esta rama, como plan vigente, y en ESTADO. En `cand/1.37.0`, su tabla de 1.37 queda **sustituida** por esta decisión (nota en esa rama), y se reconcilia al fusionar (paso 2b).
- **La autorización nueva de 1.36.2 es `P-137-J`**, en `## Pendientes`, en una página. **Nota sobre `AGENTS.md` §5:** manda QA en Opus en este repositorio, y la decisión del propietario lo sustituye para esta intervención.

### P-137-I (RETIRADA por el propietario el 2026-10-15; texto conservado) — **Hotfix 1.36.2 (SEC-135 y la parte de SEC-136 decidida): autorización lista para adoptar**, con la forma de `templates/autorizacion.md`

**Qué detiene, y qué no.** Mientras no la adoptes, el hotfix 1.36.2 **no empieza**. La rama `hotfix/1.36.2` ya existe desde `e21baef`, y su primer commit registra la publicación de 1.36.1. No detiene nada más.

**Comprobaciones de la coordinadora antes de redactarla** (`AGENTS.md` §6):
1. **El analista no se omite.** Este proyecto no declara la vía proporcional, y hace falta un REQ nuevo (REQ-033, el siguiente libre en esta rama), así que la fase 0 es suya.
2. **La rama sale de `v1.36.1`** (= `e21baef` = `origin/main`), sin nada de 1.37.
3. **Nos gobierna la instalación estable 1.36.1** desde el próximo reinicio (actualizada el 2026-10-15; hooks idénticos al tag). Sigue teniendo SEC-135 y SEC-136: quien no es el agente de código no hace `cp` con caracteres de shell, y nadie toca `.arnes/config.json`.

---

**La autorización, lista para adoptar** (si estás de acuerdo, basta «adopto P-137-I»; si no, corrige):

> ## Autorización — hotfix 1.36.2 (SEC-135 y SEC-136, parte decidida)
>
> ## Decisiones del propietario (P-032-3, P-032-4 y P-032-6, ya adoptadas; aquí se citan, no se reabren)
> - **Contrato por propiedad de SEC-135:** «toda invocación efectiva de cp/mv/install, se escriba como se escriba, se juzga por su destino real; si no se puede determinar, deny». Incluye reconocer `\cp`, `command cp`, `(cp …)`, subshells, `find -exec` y `xargs` como `cp`/`mv`/`install`, y leer los operandos como lo hace la orden (opciones, `-t`/`-T`, redirecciones y comentarios aparte), no «el último operando».
> - **Objetivo:** quitar las restricciones de 1.36.1 (sólo `cp`/`mv`/`install` sueltos y sin caracteres de shell) leyendo el destino con la gramática de la orden.
> - **SEC-136 en 1.36.2:** se juzga el **origen de `mv`**; **borrar, mover o vaciar `.arnes/config.json` se deniega a todo agente**; y se declara SEC-136 en `AGENTS.md` §13 (y en su plantilla), nombrando `rm .arnes/config.json`. `rm`, `unlink` y `git rm` van con la puerta posterior de 1.37.
> - **Fail-before contra v1.36.1** con las formas ya reproducidas: `2>/dev/null`, `2> /dev/null`, `2>&1`, `1>&2`, `2>archivo`, comentario final, `< directorio`, `-rt`, `-t` disfrazado, `\cp`, `command cp`, `(cp …)`, `find -exec`, `xargs`, y el origen protegido de `mv`. Más los controles: lo protegido sigue en `deny`; lo que 1.36.1 permite sigue permitido o se declara.
> - **Tope de pasadas: dos pasadas correctivas como máximo.** Si QA sigue encontrando formas nuevas tras la segunda, **no hay tercera**: 1.36.2 se publica con lo que cierra de verdad —como mínimo, el manifiesto y el origen de `mv`—, SEC-135 queda declarado con sus formas exactas, y su reparación pasa a la pieza b de 1.37 (post-condición), que cierra la clase entera.
>
> ## Plan autorizado (cada fase termina en commit local; la siguiente empieza sin pedir permiso)
> Fase 0 — analista: REQ-033 con el contrato de arriba, los casos del fail-before, las clases de movimiento que se declaran (de `allow` a `deny`: las formas de SEC-135 y SEC-136 que se cierran; de `deny` a `allow`: lo legítimo que 1.36.1 restringía y 1.36.2 libera), el coste, la regresión y las notas `[1.36.2]` como entregable. Y la salida del tope, escrita.
> Fase 1 — desarrollador: el arreglo, los casos en el banco con su fail-before contra v1.36.1, la regresión completa, la autoprueba y la versión 1.36.2 en `plugin.json` y en el marketplace. Sin procesos nuevos en el camino común; si hacen falta en una rama, se declaran con su cifra.
> Fase 2 — QA (Opus): repite el fail-before y el pass-after, el banco y la autoprueba, e **intenta romperlo** con formas propias. Como máximo, dos pasadas correctivas dentro del contador (y el tope de arriba).
> Fase 3 — seguridad, sólo con QA favorable: que lo protegido no se abre por ninguna forma, que los movimientos están declarados, y la clase de lo que quede de SEC-135 si se activa el tope. Puede vetar.
> Fase 4 — analista: write-back de REQ-033, la fila de SEC-136 en `AGENTS.md` §13 y su plantilla, y el borrador de las notas `[1.36.2]`. La coordinadora: copia las notas, **cierra REQ-033 con `Edit`, juzgado en vivo**, y hace commit validado, push y CI.
>
> ## Lo que decide la coordinadora sola
> Texto, trazabilidad, CHANGELOG, ESTADO e índices; orden y presupuesto de cada despacho (≈ 200 k analista, ≈ 400 k desarrollador, ≈ 350 k QA, ≈ 250 k seguridad: la escala que se midió en 1.36.1); ajustes del banco que no cambian ningún veredicto ni contrato; registrar defectos nuevos sin repararlos; el push de la rama al cerrar y marcar el PR listo cuando el CI esté en verde.
>
> ## Cuándo paras y me preguntas (sólo esto)
> Cambio de contrato o de alcance; un movimiento de `deny` a `allow` sobre algo protegido, o cualquier movimiento fuera de las clases declaradas; un veredicto del banco que cambia fuera de lo declarado, en un caso que ejecuta el código del cambio (una sonda que mide la máquina se registra como `instrumento` y el plan sigue: P-136-E); aceptar o aplazar un riesgo; **activar el tope de dos pasadas** (te presento lo que cierra y lo que pasa a la pieza b); un control del proveedor que detenga algo; publicar, fusionar o etiquetar.
>
> ## Si la sesión se corta
> La siguiente lee este plan en la cola y en ESTADO y continúa desde la última fase comiteada. No vuelve a pedir la autorización.
>
> ## Límites
> - **Lo que 1.36.2 no resuelve, y queda para la pieza b de 1.37:** `rm`, `unlink` y `git rm` de SEC-136, y la clase entera de escrituras que ningún detector de texto ve (intérpretes, programas que escriben por su cuenta). **Requisito ya decidido para esa pieza (P-032-6 (2)): la puerta posterior no puede depender sólo del manifiesto que vigila; si el manifiesto desaparece en un proyecto que lo tenía, eso mismo es un evento a denegar o revertir.**
> - Nada de F-137-9 ni de las piezas a–d. Nada de F-137-12 (el glob con sufijo) salvo que caiga por la misma propiedad, y entonces se dice.
> - Fusión, tag y publicación: míos. Al publicar 1.36.2, se fusiona `main` en `cand/1.37.0` (paso 2b).
> - Push de `hotfix/1.36.2`: recordármelo al terminar cada fase.

### RESUELTA (propietario, 2026-10-15) — **v1.36.1 PUBLICADA** (`main` `e21baef`, tag `v1.36.1`, PR #61) por orden expresa del propietario; **registro, instalación estable y autorización de 1.36.2**, con dos condiciones

**Textos del propietario, literales** (mensajes del 2026-10-15 a la sesión coordinadora del worktree `ArnesJuan-v1.36`). El primero, con las órdenes de publicación:

> Luego has esto o
>
>     cd ~/dev/ArnesJuan-v1.36
>     gh pr merge 61 --repo JJOVEGA/ArnesJuan --merge
>     git fetch origin && git log --oneline -1 origin/main
>     git tag -a v1.36.1 origin/main -m "ArnesJuan v1.36.1 — cp/mv/install sobre archivo existente (F-137-10, REQ-032); SEC-135 y SEC-136 declarados; ver CHANGELOG [1.36.1]"
>     git push origin v1.36.1

El segundo:

> Confirmo los tres: registra la publicación de 1.36.1 como primer commit de
> hotfix/1.36.2 (desde e21baef), actualiza la instalación estable a 1.36.1 y
> prepara la autorización de 1.36.2 con el contrato de P-032-6.
>
> Dos condiciones para esa autorización:
> - Tope: dos pasadas correctivas como máximo. Si QA sigue encontrando formas
>   nuevas tras la segunda, no hay tercera: 1.36.2 se publica con lo que
>   cierra de verdad (como mínimo el manifiesto y el origen de mv), SEC-135
>   queda declarado con sus formas exactas y su reparación pasa a la pieza b
>   de 1.37 (post-condición), que cierra la clase entera.
> - La puerta posterior de 1.37 no puede depender sólo del manifiesto que
>   vigila (requisito ya decidido): que figure en la autorización como límite
>   de lo que 1.36.2 no resuelve.
>
> Avísame cuando el CI de main termine sobre e21baef.

**Lo que hizo y comprobó la coordinadora:**
- **Fusión** del PR #61 (`gh pr merge --merge`): `MERGED` 2026-10-15T23:44:33Z, commit **`e21baef`**, que une `f22b905` (v1.36.0) y `4d4a6a5` (la cabeza validada). El primer `fetch` falló por un corte de TLS **después** de la fusión; se comprobó con `gh` antes de repetir nada, y sólo se repitió el `fetch`.
- **Tag `v1.36.1`** (anotado, objeto `7cebafe`) → `e21baef`, y su push a `origin`.
- **CI de `main` sobre `e21baef`:** run `38825377862`, **success** (2824 PASS, 0 FAIL, 38 SKIP; 2 de ellos INCONCLUSO de rendimiento, que no acreditan).
- **Instalación estable 1.36.1** en este equipo: marketplace actualizado; alcances `user` y `project` (`/mnt/c/Users/JVega`) en `1.36.1`, `gitCommitSha` `e21baef`; **los hooks instalados son idénticos a los de `v1.36.1`** (`diff -r` vacío contra `git archive v1.36.1 hooks`). **Rige desde el próximo reinicio.**
- **Rama `hotfix/1.36.2`** desde `e21baef`; este registro es su primer commit. **La autorización de 1.36.2 está arriba, en `## Pendientes` (`P-137-I`)**, con las dos condiciones.

### RESUELTA (propietario, 2026-10-15) — **P-032-6**: 1.36.2 reconoce toda invocación efectiva de `cp`/`mv`/`install`; SEC-136 como propone el auditor **más** una excepción para `.arnes/config.json` y un requisito para la pieza b; cierre de REQ-032 autorizado

**Texto del propietario, literal** (mensaje del 2026-10-15 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-032-6:
>
> 1. Alcance de 1.36.2: incluye reconocer \cp, command cp, (cp …), subshells,
>    find -exec y xargs como cp/mv/install. Misma garantía, misma gravedad.
>    Contrato por propiedad: «toda invocación efectiva de cp/mv/install, se
>    escriba como se escriba, se juzga por su destino real; si no se puede
>    determinar, deny».
>
> 2. SEC-136: como propone el auditor (juzgar el origen de mv en 1.36.2;
>    rm/unlink/git rm con la puerta posterior de 1.37; declarado en §13), MÁS
>    una excepción estrecha en 1.36.2: borrar, mover o vaciar .arnes/config.json
>    se deniega a todo agente. Es el interruptor que apaga todas las puertas,
>    incluida la posterior de 1.37. Y requisito escrito para la pieza b: la
>    puerta posterior no puede depender sólo del manifiesto que vigila; si el
>    manifiesto desaparece en un proyecto que lo tenía, eso mismo es un evento
>    a denegar o revertir.
>
> 3. Cierre de REQ-032 al terminar la fase 4: autorizado, por Edit con la
>    puerta en vivo. El PR #61 me llega listo para fusionar; la publicación
>    (fusión, tag v1.36.1) es mía.
>
> Notas [1.36.1]: SEC-135 y SEC-136 declarados con su forma, su gravedad y la
> versión en que se reparan; la restricción del arreglo (sólo cp/mv/install
> sueltos y sin caracteres de shell), con su salida.

**Lo que añade la coordinadora:** el alcance de 1.36.2, la excepción del manifiesto y el requisito de la pieza b quedan escritos en las fichas F-137-14 y F-137-15. La pieza b vive en el plan de `cand/1.37.0`, y su requisito se lleva a esa fila **al fusionar `main` en `cand/1.37.0` (paso 2b)**; queda anotado en ESTADO para que no se pierda. Las notas `[1.36.1]` las redacta el analista en un borrador, y la coordinadora las copia a `CHANGELOG.md` comprobando el ancla: es la lección de `a23a026`.

### P-032-6 (texto de la consulta, conservado; resuelta arriba) — Hotfix 1.36.1, fase 3 cerrada **sin veto**. Tres decisiones agrupadas antes de las notas y del cierre: (1) ¿1.36.2 reconoce también la orden (subshell, `\cp`, `find -exec`)? (2) ¿Cuándo se arregla SEC-136, la retirada de archivos protegidos? (3) ¿Cierro REQ-032 al terminar la fase 4?

**Qué detiene, y qué no.** **No detiene** la fase 4 en lo que no depende de esto: el write-back del analista. Las **notas `[1.36.1]`** sí dependen de (1) y (2), porque dicen dónde se arregla cada cosa. **Cerrar** REQ-032 es una de tus condiciones de parada, y por eso va en (3).

**Lo que dijo seguridad (R-059, `docs/seguridad/registro-seguridad.md`), en corto:**
- **Sin veto: el paso de `deny` a `allow` queda acotado a destinos no protegidos y declarado.** Lo comprobó con un barrido de 700 comandos ejecutados de verdad.
- **V7** (el `mv` que borra un origen protegido): `instrumento` para REQ-032, **no bloquea**. Ya era `allow` en 1.33.2, y en v1.36.0 se llega al mismo estado con `cat … > …; rm …`.
- **F-137-14 = SEC-135, `contrato`, ALTA.** Dos mecanismos: (i) el último operando no es el destino; (ii) **el detector no reconoce la orden**: `\cp`, `find -exec` y, **nuevo, el subshell `(cp S src/a.ts)`**.
- **SEC-136, `contrato`, media:** ninguna puerta juzga la **retirada** de un archivo protegido. **Lo reproduje yo en v1.36.0:** `rm hooks/lib.sh`, `git rm hooks/lib.sh` y **`rm .arnes/config.json`, que deja inertes todas las puertas**, pasan. Ficha F-137-15.

#### (1) ¿El contrato de 1.36.2 incluye reconocer la orden?

Tu texto de 1.36.2 dice: «el destino de cp/mv/install se determina leyendo los operandos como lo hace la orden (opciones, -t/-T, redirecciones y comentarios aparte)». Eso cubre el mecanismo (i). El (ii) —que `\cp`, `(cp …)` o `find -exec cp` no se reconozcan como `cp`— **no está en tu literal**.
- **(A) Sí:** 1.36.2 reconoce la orden por propiedad, con el subshell, `\cp` y `find -exec` en el fail-before.
  - *Consecuencia:* cierra SEC-135 entero, que es lo que pide su severidad. Un contrato algo más grande.
- **(B) No:** 1.36.2 cubre sólo (i), y (ii) queda como límite declarado hasta 1.37.
  - *Consecuencia:* 1.36.2 sale antes, pero `(cp S src/a.ts)` sigue escribiendo código protegido.

**Recomendación: (A).**

#### (2) SEC-136: la ventana

- **(A) Lo que recomienda el auditor:** 1.36.2 juzga **los orígenes de `mv`**, que es lo que §5 promete; `rm`, `unlink` y `git rm` van con la **puerta posterior de 1.37** (pieza b); y en 1.36.2 se **declara en `AGENTS.md` §13**, con `rm .arnes/config.json` nombrado.
  - *Consecuencia:* cumple la promesa de §5 en el próximo hotfix y deja la clase general para el mecanismo que la resuelve de fondo.
- **(B) Todo a 1.37.**
  - *Consecuencia:* §5 sigue prometiendo `mv` sin cumplirlo hasta entonces.
- **(C) Todo a 1.36.2**, incluido `rm`.
  - *Consecuencia:* 1.36.2 crece mucho: una puerta para retiradas es un mecanismo nuevo, no un arreglo.

**Recomendación: (A).**

#### (3) ¿Cierro REQ-032 al terminar la fase 4?

REQ-032 tiene `QA: aprobado` y `Seguridad: aprobado`, y sus `Hallazgos abiertos:` son todos `instrumento`; la puerta deja cerrarlo (lo comprobó el auditor, con control). Marcarlo `completado` es «cerrar un REQ», una de tus condiciones de parada.
- **(A) Sí:** al terminar la fase 4 (write-back y notas), lo marco `completado` con `Edit`, la puerta lo juzga en vivo, y hago commit, push y CI.
  - *Consecuencia:* el PR #61 llega a ti listo para fusionar.
- **(B) No:** lo cierras tú al publicar.

**Recomendación: (A).**

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-032-6»; si no, corrige):

> **P-032-6. (1) (A):** el contrato de 1.36.2 incluye reconocer la orden por propiedad (subshell, `\cp`, `find -exec`, en el fail-before), además de leer los operandos. **(2) (A):** 1.36.2 juzga los orígenes de `mv` y declara SEC-136 en `AGENTS.md` §13, nombrando `rm .arnes/config.json`; `rm`, `unlink` y `git rm` van con la puerta posterior de 1.37. Las notas `[1.36.1]` lo dicen así. **(3) (A):** al terminar la fase 4, la coordinadora cierra REQ-032 con `Edit`, juzgado en vivo; después, commit, push y CI. Fusión, tag y publicación: míos.

### RESUELTA (propietario, 2026-10-15) — **P-032-5 (C), vuelta 2 de 3**: el arreglo sólo actúa sobre UNA invocación simple de `cp`/`mv`/`install` con una lista cerrada de opciones; **si la vuelta 2 no cierra QA-032-01, no hay vuelta 3: 1.36.1 no se publica**

**Texto del propietario, literal** (mensaje del 2026-10-15 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-032-5 (C), vuelta 2 de 3. El arreglo sólo actúa cuando el comando
> entero es UNA invocación de cp, mv o install, con estas condiciones, todas:
> - es la primera palabra del comando, escrita literalmente (no \cp,
>   command cp, sudo/nice/env/timeout cp, ni asignaciones VAR=x delante);
> - sin caracteres de shell, sin tuberías, sin encadenar (;, &&, ||, &),
>   sin subshells, sin redirecciones;
> - opciones sólo de una lista cerrada que el desarrollador propone y QA
>   revisa (las de uso diario: -f, -i, -n, -p, -v y similares); cualquier
>   otra opción, -t/-T y -- incluidos, vuelve a v1.36.0.
> Fuera de eso, todo igual que en v1.36.0. Las formas sueltas que vuelven a
> deny (cp … && echo, etc.) se declaran como restricción en las notas.
>
> QA-032-02: write-back del analista en REQ-032 (enlace duro y esta regla);
> no gasta vuelta. QA re-verifica la vuelta 2 incluyendo xargs, find -exec,
> y todas las formas de las rondas anteriores.
>
> Si la vuelta 2 no cierra QA-032-01, no hay vuelta 3: 1.36.1 no se publica,
> el código vuelve a v1.36.0 y F-137-10 entra en 1.36.2 junto con F-137-14,
> con la gramática de la orden.

**Lo que añade la coordinadora:** el orden es analista (write-back de QA-032-02, con la regla y el enlace duro) → desarrollador (vuelta 2) → QA (re-verificación). El PR #61 (borrador, cabeza `0f717d6`) **sigue en borrador**: esa cabeza tiene QA-032-01 abierto. **La salida si la vuelta 2 no cierra** queda escrita también en `docs/ESTADO.md`, para que ninguna sesión abra una vuelta 3.

### P-032-5 (texto de la consulta, conservado; resuelta arriba) — Hotfix 1.36.1: **la re-verificación de QA encontró otra forma llana que abre `allow` sobre código protegido: `xargs`** (QA-032-01 sigue abierto). ¿Vuelta 2, y con qué regla?

**Qué detiene, y qué no.** Detiene la vuelta 2, la fase 3 (seguridad) y el cierre del hotfix. **No detiene** el write-back del analista (QA-032-02), que se hace con la regla que elijas y no gasta vuelta.

**Lo que midió QA** (`docs/qa/REQ-032.md`, «Re-verificación de la pasada correctiva»; ejecutando de verdad) **y reproduje yo fuera de banda sobre `hooks/lib.sh`, sin escribir nada:**

| Forma (coordinadora) | v1.36.0 | Candidata `264dfa9` |
|---|---|---|
| `echo hooks/lib.sh \| xargs cp docs/PLAN.md` | deny | **allow** (escribe `hooks/lib.sh`) |
| `xargs -a docs/lista cp docs/PLAN.md` | deny | **allow** |
| `cp S hooks/lib.sh` | deny | deny |

`xargs` añade el destino desde su entrada, así que el último operando que ve el detector es un **origen**. También con `mv` e `install`. Tiene una hermana preexistente: `echo src | xargs cp -r docs/sub` ya pasaba en v1.36.0, de la familia de F-137-14.

**Todo lo demás de la pasada, conforme:**
- Las formas de QA-032-01 de la fase 2 y el **enlace duro** (H1–H3, con su fail-before contra `759ff50`) dan `deny`; si `find` falta o falla, también.
- Sección 48: 406/0. **Banco completo: 2709/0/13**, cuadrado. Autoprueba 117/0. 0 procesos añadidos en el camino común.
- **Los FAIL de reloj y de calibración no son atribuibles:** INS-032-1 (mediana 1,001), INS-032-2 e INS-032-3, confirmados como `instrumento`.
- La regla del comando llano hace exactamente lo declarado.

**QA-032-02 (`contrato`):** REQ-032 todavía dice que el enlace duro queda en `allow` y que la regla es por segmento. Falta el write-back del analista.

**Lo que dejan tres pasadas.** QA ha encontrado ya **tres tandas** de formas en las que «el último operando» no es el destino: redirecciones, comentarios y `-t` disfrazado; luego un destino entrecomillado y un salto de línea; ahora `xargs`. La regla de la pasada es una **lista de lo que no se acepta**, y cada pasada encuentra un nombre más que no estaba en ella. **Es la misma lección que la de CA-66 en F-136-17:** cerrar el tipo de defecto, no el caso.

**Opciones:**
- **(A) Vuelta 2 con la lista ampliada:** no retirar la marca si delante de la orden hay algo que le añade argumentos (`xargs` y semejantes).
  - *Consecuencia:* cierra este caso. Lo previsible es que la vuelta 3, la última, encuentre otro.
- **(B) Aceptarlo:** declararlo en las notas con F-137-14 y repararlo en 1.36.2.
  - *Consecuencia:* 1.36.1 abre por `xargs` lo que hoy está cerrado, contra tu autorización («sobre un archivo protegido no hay movimiento»). **No la recomiendo.**
- **(C) Vuelta 2 con una lista de lo que sí se acepta:** la marca **sólo** se retira cuando **el comando entero** es una sola invocación simple: `cp`, `mv` o `install` como **primera palabra**, llana, sin tubería, sin encadenar (`&&`, `||`, `;`, `&`), sin subshell y sin nada delante. Cualquier otra forma conserva la decisión de v1.36.0.
  - *Consecuencia:* **cierra el tipo de defecto**: lo que no es exactamente `cp|mv|install … DESTINO` se queda como en v1.36.0, y no hay que adivinar qué otra orden aporta argumentos. **Restringe más el arreglo:** `cp S docs/notas.md && echo hecho` vuelve a `deny`, como en v1.36.0. Ya no hay movimiento, pero sí una restricción que se declara, y el caso G1 de la sección 48 cambia de expectativa con su justificación. La 1.36.2, que leerá el destino con la gramática de la orden, es la que quita todas estas restricciones.

**Mi recomendación: (C).** El arreglo de 1.36.1 queda pequeño y seguro: corrige el `cp` llano y suelto, que es el caso diario, y no puede abrir nada que hoy esté cerrado. La versión completa es la 1.36.2. Gasta la vuelta 2 de 3.

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-032-5 (C)»; si no, corrige):

> **P-032-5 (C):** vuelta 2 de 3. La forma `destino/` sólo se deja de juzgar cuando el comando entero es una sola invocación simple de `cp`, `mv` o `install` como primera palabra, llana, sin tubería, sin encadenar, sin subshell y sin nada delante. Cualquier otra forma conserva la decisión de v1.36.0. Las formas con `xargs` (y `mv`, `install`) entran como casos del banco, en `deny`. Lo que vuelve a `deny` respecto de la pasada (por ejemplo, `cp S D && echo hecho`) se declara como restricción, y las notas `[1.36.1]` lo dicen junto al resto del alcance. El analista hace el write-back de QA-032-02 con esta regla; el desarrollador repara; QA verifica.

### RESUELTA (propietario, 2026-10-15) — **P-032-4 (B)**: el enlace duro entra en la pasada correctiva; las notas `[1.36.1]` dicen el alcance del arreglo; el contrato de 1.36.2 nombra quitar esa restricción

**Texto del propietario, literal** (mensaje del 2026-10-15 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-032-4 (B). Un destino de cp/mv/install que existe, es archivo
> regular y tiene más de un enlace duro (número de enlaces > 1) no se juzga
> como ese archivo: vuelve al deny de v1.36.0. Si leer el número de enlaces
> exige un proceso, sólo se paga en esa rama (destino existente de
> cp/mv/install), nunca en el camino común; se declara con su cifra, como el
> coste de decidir de SEC-120. Casos de banco: enlace duro en docs/ a
> hooks/lib.sh y a src/a.ts, deny; enlace duro entre dos archivos de docs/,
> deny declarado como restricción aceptada.
>
> Después: QA verifica la pasada entera sobre el código final (una vuelta),
> seguridad con la gravedad de F-137-14, notas [1.36.1].
>
> Las notas [1.36.1] dicen explícitamente el alcance del arreglo: sólo cubre
> cp/mv/install escritos sin caracteres de shell (comillas, $, #, <, saltos);
> con ellos la orden sigue denegándose como en v1.36.0, y la salida es
> escribir el comando sin esos caracteres o usar una redirección simple.
> INS-032-2 y PR-137-1, registrados. El contrato de 1.36.2 nombra como
> objetivo quitar esa restricción leyendo el destino con la gramática de la
> orden.

**Lo que añade la coordinadora:** el enlace duro lo añade el **mismo desarrollador** dentro de la **misma pasada correctiva** (vuelta 1 de 3, sin gastar otra). QA verifica después la pasada entera, una sola vez. El objetivo de 1.36.2 queda escrito en la ficha F-137-14.

### P-032-4 (texto de la consulta, conservado; resuelta arriba) — Hotfix 1.36.1: **el enlace duro, ¿dentro o fuera de la pasada correctiva?** La opción (A) de P-032-3 que redacté **lo listaba**; tu texto adoptado **no lo nombra**

**Actualización (2026-10-15):** la pasada correctiva **está hecha** sin el enlace duro (CA-15 cerrado: R1 a R17 en `deny`, sección 48 con 370/0; banco 2673/1/12, y el FAIL es la calibración de una sonda que no ejecuta hooks, INS-032-2). **La re-verificación de QA espera esta decisión**, para correr el banco una vez sobre el código final y no dos. Si eliges (B), el desarrollador lo añade: dejó marcado dónde va.

**Qué detiene, y qué no.** Detiene **sólo** la decisión sobre el enlace duro dentro de la pasada correctiva. El desarrollador **empieza ya** con lo que no depende de ella: CA-15, es decir redirecciones, comentarios y `-t`/`-rt` en cualquier forma. Si eliges (B), se le añade en la misma pasada.

**El error es mío, y lo digo primero.** La opción (A) de P-032-3 decía, literal: «no retirar la marca cuando el segmento no permite afirmar que su último operando es el destino (redirecciones, comentarios, `-t` escrito de otra forma, **enlace duro**…)». Tú adoptaste «(A)» con tu propio texto: «donde no se pueda asegurar que el último operando es el destino (redirección detrás, comentario detrás, -t/-rt)». Después, en mi nota de la cola, dejé el enlace duro fuera por la letra de tu regla, **sin decirte que mi opción lo incluía**. El analista lo vio al escribir CA-15.

**Qué es el caso.** `cp S docs/hl`, con `docs/hl` como **enlace duro** a `src/a.ts` (protegido): la coordinadora **reescribe `src/a.ts`**. Lo midió QA ejecutándolo de verdad. v1.36.0 lo denegaba por accidente, y la candidata lo permite. Aquí el último operando **sí es** el destino: lo que falla es que la identidad de REQ-007 CA-47 **no ve los enlaces duros** (frontera «sin promesa»). Por eso, ya en v1.36.0, `cat S > docs/hl` pasa.

**Opciones:**
- **(A) Fuera.** Queda como límite declarado en REQ-032 (CA-04 (ii) y CA-09, ya escritos así), con F-137-13, y el auditor lo clasifica en la fase 3.
  - *Consecuencia:* 1.36.1 abre por `cp` una instancia que hoy está cerrada, aunque la hermana por redirección ya estaba abierta. Contradice tu frase de P-137-H: «Sobre un archivo protegido no hay movimiento: sigue en `deny`».
- **(B) Dentro.** La marca **no** se retira cuando el destino es un archivo regular con **más de un enlace**, y esa forma vuelve a lo de v1.36.0 (`deny`). Lleva un caso del banco.
  - *Consecuencia:* cumple tu frase de P-137-H. **Cuesta un proceso** (`stat`) sólo en el camino de `cp`/`mv`/`install` sobre un archivo existente, nunca en el camino común: bash no sabe contar enlaces sin él. REQ-032 CA-12 (b) admite ese coste **declarado**. Un archivo con varios enlaces que no toque nada protegido seguirá denegándose como en v1.36.0: no es regresión, sólo no se arregla.

**Mi recomendación: (B).** Es la lectura que tu autorización ya decía («sobre un archivo protegido no hay movimiento»), y el coste es un proceso en un camino poco frecuente, declarado. La hermana por redirección (`cat S > docs/hl`) sigue abierta como límite de CA-47, y eso es otra cosa, preexistente.

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-032-4 (B)»; si no, corrige):

> **P-032-4 (B):** el enlace duro entra en la pasada correctiva. Cuando el destino es un archivo regular con más de un enlace, la forma `destino/` no se retira y vuelve lo de v1.36.0. Lleva un caso del banco, y el proceso de más en ese camino se declara en CA-12 (b). El analista ajusta CA-04, CA-09 y CA-15 en el write-back de la fase 4; QA lo verifica en la misma re-verificación.

### RESUELTA (propietario, 2026-10-15) — **P-032-3 (A)**: pasada correctiva acotada a QA-032-01; **F-137-14 → hotfix 1.36.2 inmediato**, abierto al publicar 1.36.1; la fusión de `main` en `cand/1.37.0`, **después de 1.36.2**

**Texto del propietario, literal** (mensaje del 2026-10-15 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-032-3: (A). Pasada correctiva limitada a QA-032-01: donde no se
> pueda asegurar que el último operando es el destino (redirección detrás,
> comentario detrás, -t/-rt), se vuelve al comportamiento de v1.36.0 (deny).
> Caso de banco por cada forma. QA re-verifica; seguridad; notas [1.36.1];
> publicación mía. Nada más entra.
>
> F-137-14: es un bypass de la garantía central (quien no es el agente de
> código escribe código protegido) por una forma cotidiana (2>/dev/null).
> Preexistente en 1.35.0 y 1.36.0; 1.36.1 no lo empeora y se publica
> declarándolo. Seguridad fija la gravedad en la fase 3 y la nota de 1.36.1
> la lleva con su forma y su salida. Decisión: 1.36.2 inmediato, abierto al
> publicar 1.36.1, con su contrato propio: el destino de cp/mv/install se
> determina leyendo los operandos como lo hace la orden (opciones, -t/-T,
> redirecciones y comentarios aparte), no «el último operando». Fail-before
> con las formas ya reproducidas. No entra en 1.37.
>
> Al cerrar 1.36.1: push, CI, y la fusión de main en cand/1.37.0 después de
> 1.36.2, no antes, para traer los dos arreglos juntos.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Un caso de QA-032-01 que la regla adoptada no cubre por su letra: el enlace duro.** `cp S docs/hl`, con `docs/hl` como enlace duro a `src/a.ts`: aquí el último operando **sí es** el destino. Lo que pasa es que la identidad de CA-47 no ve los enlaces duros, y eso es un límite declarado «sin promesa». Ya en v1.36.0, `cat S > docs/hl` pasa. **Queda con F-137-13** (formas de M-032 que alcanzan lo protegido por límites anteriores), cuya clase fija el auditor en la fase 3. No se repara en la pasada, porque «nada más entra». Si el propietario lo quiere dentro, lo dice.
- **El `-t` escrito de otra forma** (`"-t"`, `'-t'`, `\-t`, `-""t`, `"--target-directory=…"`, `$T`) cae en «no se puede asegurar»: una opción entrecomillada, escapada o expandida no se puede leer sin interpretar el shell, y por la regla adoptada se vuelve a `deny`.
- **La fila 2b de `docs/PLAN.md`** (en `cand/1.37.0`) pasa a decir «después de 1.36.2». Se corrige en esa rama.

### P-032-3 (texto de la consulta, conservado; resuelta arriba) — Hotfix 1.36.1, fase 2: **el arreglo abre un `allow` sobre código protegido en formas donde el último operando no es el destino (QA-032-01)**; y QA encontró que **v1.36.0 ya deja pasar** formas corrientes de esa misma raíz (F-137-14). ¿Qué entra en la pasada correctiva, y qué se hace con lo preexistente?

**Qué detiene, y qué no.** Detiene la pasada correctiva, la fase 3 (seguridad) y el cierre del hotfix. **No detiene** nada más.

**Lo que midió QA** (`docs/qa/REQ-032.md`; ejecutando de verdad en proyectos limpios) **y reproduje yo fuera de banda, sin escribir nada**, sobre `hooks/lib.sh` (protegido) con `docs/PLAN.md` como señuelo:

| Forma, emitida por la coordinadora | v1.36.0 | Candidata | Qué es |
|---|---|---|---|
| `cp S hooks/lib.sh < docs/PLAN.md` | deny | **allow** | **QA-032-01**: el arreglo lo abre |
| `cp S hooks/lib.sh  # copia de docs/PLAN.md` | deny | **allow** | QA-032-01 |
| `cp "-t" hooks docs/PLAN.md` (y `'-t'`, `\-t`, `$T`…) | deny | **allow** | QA-032-01 |
| `cp S hooks/lib.sh` | deny | deny | control |
| `cp S hooks/lib.sh 2>/dev/null` | **allow** | allow | **F-137-14**: ya abierto en v1.36.0 |
| `cp S hooks/lib.sh # nada` | **allow** | allow | F-137-14 |
| `cp -rt hooks docs/sub` | **allow** | allow | F-137-14 |

**La raíz es una sola.** El detector toma como destino el **último operando**, y con una redirección, un comentario, un `-t` disfrazado o un enlace duro, ese operando no es el destino. En v1.36.0 esas formas se denegaban **por accidente** cuando el último operando era un archivo existente. El arreglo quita el accidente, y aparece lo que había debajo. **Cada forma de QA-032-01 tiene una hermana que v1.36.0 ya dejaba abierta**, así que el arreglo no abre una clase nueva de agujero, pero sí abre instancias que hoy están cerradas. Y eso contradice tu autorización («Sobre un archivo protegido no hay movimiento: sigue en `deny`») y REQ-032 CA-04.

**El resto de la fase 2 sale bien:** el fail-before y el pass-after (sección 48: 254/0 la candidata; v1.36.0, 28 FAIL); el banco completo (2557/0/13, inventario sin cambios de decisión fuera de la 48); la autoprueba (117/0); 0 procesos añadidos. La marca de tabulador **no se puede fabricar**; enlaces, `..`, `cwd`, FIFO y dispositivos, sin cambio. **El FAIL de reloj no es atribuible:** mediana 1,013 frente a v1.36.0, con un procedimiento fijado antes de medir. Queda como **INS-032-1**, `instrumento`.

**Las opciones:**

- **(A) Pasada correctiva acotada a QA-032-01:** no retirar la marca cuando el segmento no permite afirmar que su último operando es el destino (redirecciones, comentarios, `-t` escrito de otra forma, enlace duro…). Esas formas vuelven a lo de v1.36.0. **F-137-14 se queda como estaba**, registrado, con su ventana por decidir.
  - *Consecuencia:* 1.36.1 sale cumpliendo tu autorización y CA-04, sin abrir nada que hoy esté cerrado, y respetando «nada más entra». Es la pasada prevista (vuelta 1 de 3). Pero 1.36.1 se publica **sabiendo** que `cp … 2>/dev/null` deja escribir código protegido.
- **(B) Aceptar QA-032-01 como límite declarado:** el analista reescribe CA-04 y lo declara.
  - *Consecuencia:* 1.36.1 abre `allow` sobre código protegido en formas que hoy se deniegan, contra tu propia autorización. **No la recomiendo.**
- **(C) Ensanchar el hotfix para que el detector identifique bien el destino**, lo que cierra QA-032-01 **y** F-137-14.
  - *Consecuencia:* cierra un fallo en abierto de una protección publicada, y en su forma más corriente. Pero rompe «nada más entra», mete un cambio mayor en el detector dentro de un hotfix, y pide un contrato nuevo del analista (otra comisión) y una superficie mayor para QA y seguridad.

**Mi recomendación: (A) para 1.36.1, y decidir F-137-14 aparte y pronto.** Para F-137-14, el auditor fija su clase y severidad en la fase 3 de este mismo hotfix, y con esa clase delante decides si va en un **1.36.2** inmediato o en 1.37 (la pieza b, la post-condición de filesystem, es la defensa de fondo de esta especie). Que compartan raíz no obliga a llevarlos en el mismo vehículo, y mezclarlos ahora retrasa un arreglo ya medido por uno que todavía no tiene contrato.

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-032-3»; si no, corrige):

> **P-032-3: opción (A).** Pasada correctiva acotada a QA-032-01: la marca no se retira cuando el segmento no permite afirmar que su último operando es el destino, y esas formas vuelven a lo de v1.36.0. El analista lo escribe en REQ-032, el desarrollador lo repara y QA verifica (vuelta 1 de 3). F-137-14 no entra en 1.36.1: el auditor fija su clase y severidad en la fase 3, y con eso decido si va en 1.36.2 o en 1.37. INS-032-1 queda como `instrumento`.

### RESUELTA (propietario, 2026-10-14) — **P-032-1 (A) y P-032-2 (A), con una precisión**: un directorio se juzga como hoy; «archivo» es un archivo regular **después de resolver la identidad de CA-47**; corrección de la medida del `desarrollador` registrada

**Texto del propietario, literal** (mensaje del 2026-10-14 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-032-1 (A): el destino que es directorio se sigue juzgando como
> directorio/, como hoy (CA-47 punto 10). Nada más entra.
>
> Adopto P-032-2 (A): «archivo» es un archivo regular, juzgado DESPUÉS de la
> resolución de identidad de CA-47 (SEC-122): un enlace simbólico a un
> archivo regular cuenta como ese archivo, no como «otro tipo». FIFO,
> dispositivo y demás se quedan como en v1.36.0: ante la duda, deny.
>
> La corrección de tu medida es correcta y se registra: la regresión deniega
> a quien no es el agente de código; el desarrollador con agent_id pasa.
> Sigue siendo hotfix: la coordinadora, QA y el analista hacen cp a diario.
> Notas de 1.36.1 y F-137-10 con la forma exacta.
>
> El analista cierra el contrato sin otra comisión; fase 1. Recuérdame el push
> al terminar.

**Lo que añade la coordinadora:** «sin otra comisión» se aplica **retomando la misma comisión del analista de la fase 0**, con el contexto que ya tiene, para que escriba las dos decisiones en REQ-032. No se abre un análisis nuevo. La ficha F-137-10 vive en `cand/1.37.0`, y su forma exacta se corrige en el paso 2b; las notas `[1.36.1]` se escriben con ella en la fase 4.

### P-032-1 y P-032-2 (texto de la consulta, conservado; resueltas arriba) — Hotfix 1.36.1, fase 0: **dos preguntas sobre el criterio de REQ-032**. La primera nace de un error de redacción de la coordinadora en P-137-H

**Qué detiene, y qué no.** Detiene **cerrar el contrato** de REQ-032 (sigue en `borrador`) y, por tanto, el arreglo del desarrollador, cuya condición depende de P-032-2. **No detiene** nada más: el REQ está escrito con 14 criterios (`requirements/REQ-032.md`), y los casos del banco de CA-02 a CA-05 y CA-07 no dependen de estas preguntas.

#### P-032-1 — Un destino que es un **directorio** existente: ¿«`directorio/nombre`» como dice P-137-H, o como hoy?

**El error es mío.** En la autorización que redacté puse: «`cp` a un **directorio** existente se juzga como `directorio/nombre`». **Hoy no es así:** el detector juzga el destino y su forma `destino/` (`hooks/lib.sh:2252-2263`; REQ-007 CA-47, punto 10, «la barra final es para `cp`, `mv` e `install` hacia un directorio»). Un directorio se juzga como **`directorio/`**, y con eso `cp x src` casa con el glob `src/*`. Leerlo al pie de la letra sería una **capacidad nueva**: con globs con sufijo (`src/*.ts`) puede dar veredictos distintos de los de hoy. Lo ha razonado el analista; no está medido.

- **(A) Conservar lo de hoy:** un directorio existente se juzga como hoy, y su veredicto no cambia (CA-06).
  - *Consecuencia:* cumple «nada más entra» y no toca CA-47. **Mi recomendación.**
- **(B) Al pie de la letra, `directorio/nombre`:**
  - *Consecuencia:* capacidad nueva dentro de un hotfix; mueve veredictos de `allow` a `deny` y obliga a versionar CA-47, punto 10. Contradice «nada más entra».

#### P-032-2 — ¿Qué es «archivo» en tu criterio («un destino que existe y es archivo se juzga como archivo»)?

- **(A) Sólo un archivo regular** (`-f`). Cualquier otra cosa que exista —FIFO, dispositivo, socket— se queda como hoy (se juzga también `destino/`).
  - *Consecuencia:* falla del **lado cerrado**: lo que no sea un archivo regular sigue denegándose a quien no es el agente de código. **Recomendación del analista y mía.**
- **(B) Todo lo que existe y no es directorio**, `/dev/null` incluido.
  - *Consecuencia:* abre más; los tipos especiales pasan a juzgarse por su nombre. Nadie ha pedido ese caso, y el arnés ya tiene reglas propias para `/dev/` y `/proc/` (REQ-007 CA-47, puntos 14 a 16) con las que habría que reconciliarlo.

#### Una corrección de la coordinadora, que tienes que conocer aunque no decide nada

**Mi medición del caso del `desarrollador` (2026-10-12) estaba mal construida:** le pasé `agent_type` sin `agent_id`, y un subagente real lleva los dos. **Re-medido fuera de banda (2026-10-13, puerta 1.36.0 instalada):** un `cp` sobre un archivo existente **se le permite al `desarrollador`** con su `agent_id`, tanto sobre `docs/PLAN.md` como sobre un REQ. Se deniega al `qa-tester`, al `analista-requerimientos`, a la coordinadora y a toda entrada sin `agent_id`. La razón: «no determinable» se trata como código de la app, y el agente de código puede escribirlo (`hooks/guard-codigo.sh:169-171`). **La forma correcta del defecto es: se deniega a todo el que no es el agente de código.** La nota de regresión de las notas `[1.36.0]` y la ficha F-137-10, en `cand/1.37.0`, dicen «también el `desarrollador`», y **es falso**. Las corrijo en el paso 2b (al fusionar `main` en `cand/1.37.0`), y las notas `[1.36.1]` saldrán con la forma correcta. **No es pública todavía:** `main` no tiene esa nota. REQ-032 ya trata ese caso como «se mide» (CA-02, F5).

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-032-1 (A) y P-032-2 (A)»; si no, corrige):

> **P-032-1 (A):** un directorio existente se juzga como hoy (REQ-007 CA-47, punto 10) y su veredicto no cambia; la frase «`directorio/nombre`» de P-137-H queda corregida. **P-032-2 (A):** «archivo» es un archivo regular; cualquier otro tipo que exista conserva el veredicto de v1.36.0. El analista cierra el contrato de REQ-032 con esto, sin otra comisión de análisis, y el plan sigue con la fase 1.

### RESUELTA (propietario, 2026-10-13) — **Hotfix 1.36.1 (F-137-10) autorizado: P-137-H adoptada con tres ajustes**; rama `hotfix/1.36.1` desde `v1.36.0`

**Esta rama parte de `v1.36.0`**, así que esta cola no tiene las entradas de 1.37 (P-137-A a P-137-G, en `cand/1.37.0`, `origin` `ab22d02`). Allí está registrada la propuesta P-137-H, y aquí, la autorización vigente del hotfix. Al fusionar `main` en `cand/1.37.0` se juntan las dos historias.

**Texto del propietario, literal** (mensaje del 2026-10-13 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-H, con sus tres ajustes: analista en fase 0 (REQ nuevo del
> hotfix, criterio por propiedad: «un destino que existe y es archivo se
> juzga como archivo, en cp, mv e install»; sin declarar en §6 la vía que
> lo omite), rama hotfix/1.36.1 desde v1.36.0 (f22b905), y los controles de
> seguridad del fail-before: cp sobre archivo protegido sigue en deny, y el
> paso de deny a allow se declara como clase de movimiento con sus casos.
>
> Límite del hotfix: nada más entra. Si el desarrollador encuentra la causa
> en un sitio compartido con otra puerta, se registra y se repara sólo lo
> que el REQ del hotfix nombra.
>
> Anota en docs/PLAN.md el paso que sigue a la publicación de 1.36.1: fusión
> de main en cand/1.37.0, para que 1.37 lleve el arreglo del cp y no vuelva
> a publicarlo roto.
>
> Al cerrar: notas [1.36.1], push, CI; la publicación es mía. Recuérdame el
> push de hotfix/1.36.1 al terminar cada fase.

**La propuesta que adoptó** (redactada por la coordinadora con la forma de `templates/autorizacion.md`, conservada literal; **los ajustes de arriba prevalecen**):

> ## Autorización — hotfix 1.36.1 (F-137-10)
>
> ## Decisiones del propietario
> - Alcance único: el detector de escrituras reconoce el destino de `cp` —y de `mv` e `install`, si comparten la causa— como **archivo** cuando lo es. Nada más entra en 1.36.1.
> - Sede: un **REQ nuevo** (REQ-032), con `Sensible a seguridad: sí` y `Rigor: critico` por la política de autoalojamiento. No se añade a REQ-007, que F-137-9 va a partir.
> - El movimiento que el arreglo produce —de `deny` a `allow` para `cp`/`mv`/`install` sobre un archivo existente **no protegido**— se declara como **clase** de movimiento, restituyendo lo que daba 1.33.2 (regla de CA-24: un movimiento de `deny` a `allow` no declarado es un hallazgo). Sobre un archivo **protegido** no hay movimiento: sigue en `deny`.
> - Rama `cand/1.36.1` desde `v1.36.0`. Fusión, tag `v1.36.1`, publicación y actualización de la instalación estable: míos.
>
> ## Plan autorizado (cada fase termina en commit local; la siguiente empieza sin pedir permiso)
> Fase 0 — analista: REQ-032 con el contrato. Propiedad; fail-before contra v1.36.0 con los casos ya medidos a mano (`cp` sobre el REQ con ruta absoluta y relativa, sobre `docs/PLAN.md`, emitido por el `desarrollador`, con `cp -T`; y destino inexistente como control); y los controles de seguridad: `cp` sobre un archivo **protegido** existente, de un agente que no es el de código, sigue en `deny` antes y después; `cp` a un **directorio** existente se juzga como `directorio/nombre`; la misma matriz para `mv` e `install` si comparten la causa. Declara la clase de movimiento. Regresión completa del banco. Notas `[1.36.1]` como entregable.
> Fase 1 — desarrollador: el arreglo, los casos en el banco con su fail-before contra v1.36.0, la regresión completa, la autoprueba y la versión 1.36.1 en `plugin.json` y en el marketplace. Sin procesos nuevos en el camino común.
> Fase 2 — QA (Opus): repite el fail-before y el pass-after, el banco y la autoprueba, y **intenta romperlo**, sobre todo para que no abra un `allow` sobre algo protegido. Una pasada correctiva como máximo, dentro del contador.
> Fase 3 — seguridad, sólo con QA favorable: que el movimiento de `deny` a `allow` queda acotado a lo no protegido y declarado. Puede vetar.
> Fase 4 — analista: write-back y notas `[1.36.1]`. La coordinadora: commit validado, push de la rama y PR.
>
> ## Lo que decide la coordinadora sola
> Texto, trazabilidad, CHANGELOG, ESTADO e índices; crear la rama, hacer push de la candidata y abrir el PR en borrador, porque el CI es la puerta requerida; orden y presupuesto de cada despacho (≈ 150 k analista, ≈ 300 k desarrollador, ≈ 250 k QA, ≈ 150 k seguridad); ajustes del banco que no cambian ningún veredicto ni contrato; registrar defectos nuevos sin repararlos.
>
> ## Cuándo paras y me preguntas (sólo esto)
> Cambio de contrato o de alcance —por ejemplo, que `mv` o `install` tengan **otro** defecto, o que el arreglo exija tocar la identificación del destino de CA-47 más allá del detector de `cp`/`mv`/`install`—; cualquier movimiento de `deny` a `allow` fuera de la clase declarada; un veredicto del banco que cambia fuera de lo declarado; aceptar o aplazar un riesgo; más pasadas que la prevista; un control del proveedor que detenga algo; publicar, fusionar, etiquetar o cerrar un REQ.
>
> ## Si la sesión se corta
> La siguiente lee este plan en la cola y en ESTADO y continúa desde la última fase comiteada. No vuelve a pedir la autorización.
>
> ## Límites
> Nada más que F-137-10 en 1.36.1. Nada de F-137-9 ni de las piezas a–d. No `AGENTS.md`. Fusión, tag, publicación e instalación estable: míos.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Lo que cambian los ajustes respecto de la propuesta:** la rama se llama **`hotfix/1.36.1`**; el criterio del REQ es el de la cita; y el **push de la rama no lo decide la coordinadora en cada fase: se lo recuerda al propietario**, y lo hace ella al cerrar, junto con las notas `[1.36.1]` y el CI.
- **Comprobación de `AGENTS.md` §6, por escrito:** este proyecto «todavía no ha declarado esa autorización» (§6), así que **el analista no se omite** y hace la fase 0. El propietario lo confirma: «sin declarar en §6 la vía que lo omite».
- **Se trabaja en el worktree de la sesión, cambiando de rama**, porque los hooks juzgan contra `CLAUDE_PROJECT_DIR`. Gobierna la instalación estable 1.36.0, **que tiene el defecto**: ningún agente hace `cp` sobre un archivo existente; se usa `Edit`/`Write` o la redirección.
### RESUELTA (propietario, 2026-10-13) — **P-137-G: (A), CA-66 vuelve entero**; cuatro «Punto 5» confirmadas; segunda pasada autorizada (2.ª de 3); write-back con la lección: **CA-66 no es registro, es contrato**

**Texto del propietario, literal** (mensaje del 2026-10-13 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-G: (A). Devolver CA-66 entero al REQ. Confirmo las cuatro
> «Punto 5» aplicadas. Autorizo esta segunda pasada (2.ª de 3; contador sin
> reiniciar). Aplicar por Edit con la puerta en vivo; QA verifica la pasada
> y repite la búsqueda de contraejemplos sólo sobre CA-66; seguridad;
> commit validado; push.
>
> Write-back, con esta lección añadida: CA-66 no es registro, es contrato
> (clases de movimiento, compatibilidad y filas contratadas que los hallazgos
> abiertos usan como sede). La regla «el rótulo no inmuniza» vale para
> Historial, Trazabilidad, Preguntas, notas y CA-67/68, que QA ya probó sin
> contraejemplos; para CA-66 no. Resultado final de F-136-17: REQ en ~479 KB,
> Edit en ~9 KB por llamada (1,8× el original), ~388 KB de historia fuera con
> punteros. Cumple a medias, y así se declara.
>
> Al cerrar: push, y abre el hotfix 1.36.1 con su autorización lista.

### P-137-G (texto de la consulta, conservado; resuelta arriba) — F-136-17: **la pasada correctiva cerró QA-007-19 y 20, pero encontró más texto de CA-66 que hallazgos abiertos citan y sigue fuera (QA-007-22).** Repararlo es una segunda pasada, y eso es tu condición de parada. ¿Vuelve CA-66 entero, o sólo lo citado?

**Qué trabajo detiene, y qué no.** Detiene la segunda pasada, la fase 4 y el commit validado; y, como el hotfix 1.36.1 se abre al cerrar F-136-17, también su apertura. **No detiene nada más.**

**Lo que encontró QA en su pasada correctiva** (`docs/qa/REQ-007.md`, «7. Pasada correctiva de P-137-F»). **Comprobado en disco por la coordinadora:**
- **QA-007-19 y QA-007-20: cerrados.** CA-69 y las cuatro «Punto 5» están en el REQ, verbatim y en su sitio. §5 conforme otra vez: 12/12 destinos con `cmp`, 69 `CA-xx`, 17/17 hallazgos con sede, 12/12 enlaces. **Presupuesto de `Edit` medido por QA con la puerta: 9 933 B pasan y 9 934 se deniegan**, frente a 4 947 con el original.
- **QA-007-22 (`contrato`, media), nuevo:**
  - **SEC-124** (abierto) cita en el registro «el punto 7 de compatibilidad («Pasa a permitirse la clase de K6»)» y nombra entre sus sedes «CA-66 punto 5 y punto 7». Esa frase sólo existe en la viñeta «Punto 7» de la octava autorización (2035–2051 de `cecf9b6`), que sigue fuera. Hay **cuatro** «Punto 7», los cambios de compatibilidad de cada versionado, y suman 3 733 B.
  - **QA-023-23** (abierto, en la cabecera de REQ-007) dice en el registro: «REQ-007 CA-47 punto 19 y **CA-66 LC10** tienen que cumplirse para cerrar REQ-007». Las filas LC10 están en la tabla del «Punto 3» de la fase 2 (2072–2120; 9 190 B), que sigue fuera y dice de sí misma «La columna «Candidato» es el contrato».
- **QA-007-21:** queda como residual `instrumento`, que no bloquea: el hash `7c6baea` sigue sin rastro desde el REQ. Su arreglo es mecánico y va con la próxima pasada.
- **QA se atribuye su parte:** en la primera pasada leyó «punto 7» como el punto 7 base de CA-66 sin comprobar el texto citado. Y yo **había llevado la decisión con «tres» «Punto 5» cuando eran cuatro**: apliqué cuatro, porque tu regla era devolver las listas de movimientos declarados, pero **lo aplicado no coincide con tu texto literal**, y te lo digo para que lo confirmes o lo corrijas.

**La lección que dejan dos pasadas seguidas.** El bloque D1 —la evidencia por versionado de CA-66 en 1.35.0— **no es sólo registro de cómo se midió**: los hallazgos abiertos lo usan como **sede de las clases de movimiento, de los cambios de compatibilidad y de filas contratadas**. Cada pasada encuentra una cita más dentro de él. QA tampoco ha barrido las sedes que no son registros de hallazgos (ADR-016, la guía, el banco), que también citan «CA-66 (versionado del …)». Lo demás que salió del REQ —Historial, Trazabilidad, Preguntas, sedes de versionado de Notas, notas de CA-54/58/60 y viñetas de CA-67/68— **ya pasó la búsqueda de contraejemplos de QA sin hallazgos**.

**Opciones, medidas** (REQ hoy: 432 382 B):

| Opción | Qué vuelve | REQ queda en | Presupuesto de `Edit` |
|---|---|---|---|
| **(A)** | **CA-66 entero**: lo que queda de D1, 47 127 B | ≈ 479 100 | ≈ 8 960 B |
| **(B)** | Sólo lo citado: las cuatro «Punto 7» y la tabla del «Punto 3» de la fase 2, ≈ 12 900 B | ≈ 445 300 | ≈ 9 640 B |
| hoy | — | 432 382 | 9 933 B (medido) |
| original | — | 868 108 | 4 947 B |

- **(A)** *Consecuencia:* **cierra la clase**, no la instancia. Con CA-66 completo, ninguna cita a «CA-66 (versionado del …)» puede volver a quedar sin sede. Sigue fuera ≈ 388 KB de historia. El `Edit` se queda en 1,8× el original y el REQ, a la mitad. La aplicación es mecánica (el puntero de CA-66 se sustituye por su texto), juzgada en vivo, con una pasada de QA.
- **(B)** *Consecuencia:* **cierra la instancia.** Devuelve sólo lo que hoy se sabe citado y gana unos 34 KB más que (A), pero deja dentro de D1 texto que las sedes sin barrer citan. Lo previsible, visto lo que ha pasado dos veces, es **una tercera pasada con otro hallazgo**.

**Contadores:** la que viene sería la **segunda pasada correctiva** de esta entrega (tu plan preveía una). El tope de vueltas por REQ de §6 es 3, y esta sería la 2.ª.

**Mi recomendación: (A).** Dos pasadas han demostrado que en D1 la frontera entre registro y sede no se puede trazar con fiabilidad, y que cada intento deja otra cita sin sede. Devolver CA-66 entero cuesta 34 KB más que (B), y a cambio se termina el problema en vez de buscar el siguiente.

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-137-G»; si no, corrige):

> **P-137-G: opción (A).** Vuelve al REQ CA-66 entero (lo que queda de D1: 1649–1687, 1710–1780, 1807–1920, 2013–2123 y 2154–2194 de `cecf9b6`), verbatim y en su sitio, por `Edit` juzgado en vivo; `evidencia-ca66-1.35.0.md` se retira; `7c6baea` va a un puntero. Confirmo las **cuatro** «Punto 5» aplicadas en P-137-F. Autorizo esta segunda pasada correctiva de la entrega, con los contadores tal cual. QA verifica una vez; después, seguridad; commit validado; push. Si QA encuentra otro texto citado fuera, se para y se me dice.

### RESUELTA (propietario, 2026-10-13) — **P-137-F: (A)**; write-back de cierre de F-136-17 («cumple a medias»); **orden de lo que sigue**: hotfix 1.36.1, F-137-9 (partir REQ-007 por dominio), y después a), c), b), d), 2b

**Texto del propietario, literal** (mensaje del 2026-10-13 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Adopto P-137-F: (A). Devolver CA-69 entero, las tres viñetas «Punto 5»
> completas de CA-66 y «La regla, no un inventario» al REQ; añadir REQ-009,
> O-16 y los 14 hashes a los punteros. Aplicar por Edit, con la puerta en
> vivo. Una sola pasada correctiva de QA sobre todo junto; después seguridad;
> commit validado; push.
>
> Write-back de cierre de F-136-17, honesto: cumple a medias. Gana: Edit de
> 4,9 a ~10 KB por llamada; historia separada de los criterios con punteros;
> 13 destinos exactos. No gana: el REQ queda en 418–481 KB, por encima del
> techo del Write; el ahorro del analista no queda demostrado (135 909
> tokens, 15 % bajo la mediana, que ya leía por tramos). Conclusión
> registrada: lo vigente de REQ-007 (~378 KB) no cabe en un archivo por
> diseño; la salida es F-137-9.
>
> Orden decidido para lo que sigue, en docs/PLAN.md:
> 1. Hotfix 1.36.1 — F-137-10 (cp sobre archivo existente denegado desde
>    1.35.0; y mv/install si comparten causa). Alcance único. Fail-before
>    contra v1.36.0 con los casos medidos a mano (REQ, PLAN.md, desarrollador,
>    cp -T, destino inexistente); regresión completa del banco; ciclo entero
>    desarrollador → QA → seguridad; notas [1.36.1]; publicación mía.
>    Mientras, declarado en las notas de 1.36.0 como regresión conocida con
>    su salida (redirección o destino nuevo).
> 2. F-137-9 — partir REQ-007 por dominio (CA-47 y los puntos de Bash en un
>    REQ propio; cabeceras y cierre en otro). Cambio de contrato: el analista
>    escribe primero el contrato de la partición y para antes de ejecutar.
> 3. Después: a) plan de desarrollo, c) adelgazamiento, b) post-condición,
>    d) spike de mod, 2b.
>
> Ejecuta el cierre de F-136-17 sin pararte salvo por lo de la plantilla.
> Al terminar, recuérdame el push y abre el hotfix 1.36.1 con su autorización
> en la forma de templates/autorizacion.md, lista para que yo la adopte.

**Lo que añade la coordinadora:** «La regla, no un inventario» (1999–2012 de `cecf9b6`) vive **dentro** de la tercera viñeta «Punto 5» (1921–2012), así que vuelve con ella; no hay un bloque aparte. El orden queda en `docs/PLAN.md` § 1.37.0. «Lo de la plantilla» son las condiciones de parada de la undécima autorización (forma de `templates/autorizacion.md`), que siguen vigentes.

### P-137-F (texto de la consulta, conservado; resuelta arriba) — F-136-17, fase 3: **QA encontró texto vigente fuera del REQ que hallazgos abiertos citan por su nombre** (tu salvaguarda 1). Devolverlo saca el REQ del techo del `Write` en cualquier variante. ¿Cuánto se devuelve?

**Qué trabajo detiene, y qué no.** Detiene la pasada correctiva, la fase 4 y el commit validado. **No detiene nada más:** el hotfix 1.36.1 se abre al cerrar F-136-17.

**Los hallazgos de QA** (`docs/qa/REQ-007.md` § «F-136-17 — partición (fase 3)»; **comprobados en disco por la coordinadora**):
- **QA-007-19 (`contrato`, alta):** los **puntos 1 a 6 de CA-69** son el **enunciado** del criterio —qué evidencia se exige, la línea base, los movimientos y cambios de compatibilidad declarados—, no el registro de cómo se midió, y salieron. **SEC-132** (abierto) dice en el registro que su arreglo «se declara en **CA-69 punto 3**»; **SEC-130** (abierto) lo cita por su nombre. **33 líneas que se quedaron en el REQ** remiten a «CA-69, punto N», entre ellas CA-47 p. 20, CA-67 y CA-68, que §13 declara norma única. Y la fila nueva del Historial dice «el contrato no cambia», lo que con esto es falso. **El error de origen es mío:** en el encargo de la fase 2 propuse yo que CA-69 saliera entero salvo su primera frase, y el analista lo confirmó.
- **QA-007-20 (`contrato`, media):** el texto que **SEC-124** cita desde la propia cabecera, «CA-66 punto 5 (octava autorización, «la regla, no un inventario»)», salió con D1, aunque se quedó el rótulo. Es el ejemplo exacto que pusiste en P-137-A. Ahora el REQ se contradice: CA-66 punto 5 habla de «seis» clases y la nota de CA-24 de «ocho».
- **QA-007-21 (`instrumento`):** REQ-009, O-16 y 14 hashes de commit quedaron sin rastro desde el REQ. **Mi comprobación no los cubría:** el patrón no incluía `REQ-`, `O-` ni hashes. Su arreglo es mecánico: van en los punteros.
- **El resto, conforme:** la mecánica (13/13 destinos verbatim, rehecho por QA con `cmp`, sin fiarse de mi salida); los enlaces; y **el banco: 2304 PASS, 0 FAIL, 12 SKIP, autoprueba 117/0** sobre el mismo total de casos que el CI. Los 26 SKIP de menos se explican caso por caso (instalación 1.33.2, `jq` 1.7.1 y bash del runner).

**Por qué no lo corrijo sin preguntarte.** CA-69 sí es mecánico: vuelve entero y no hay nada que juzgar. **CA-66 no lo es:** SEC-124 cita «punto 5», y en D1 hay **tres** «Punto 5», uno por versionado. Cada uno lista los movimientos de `deny` a `allow` que ese versionado declaró admitidos. Si esas listas son las sedes de las clases que la nota de CA-24 cuenta («sólo los movimientos de esas ocho clases no son hallazgo»), son vigentes y deben volver. **No sé si son historia o vigentes**, y ésa es tu condición de parada.

**Las opciones, medidas** (REQ hoy: 391 307 B; techo del `Write`: 393 216; presupuesto de `Edit` = 4 294 967 296 / tamaño del REQ):

| Opción | Qué vuelve al REQ | REQ queda en | Sobre el techo del `Write` | Presupuesto de `Edit` |
|---|---|---|---|---|
| hoy | — | 391 307 | 0 | **10 975** (QA lo midió: 10 975/10 976) |
| **(A)** | CA-69 entero + los **tres «Punto 5»** de D1 | ≈ 430 800 | ≈ 37 600 | ≈ 9 970 |
| **(B)** | CA-69 entero + **sólo** «la regla, no un inventario» (1999–2012) | ≈ 418 400 | ≈ 25 200 | ≈ 10 270 |
| **(C)** | CA-69 entero + **D1 entero** (toda la evidencia de CA-66) | ≈ 481 100 | ≈ 87 900 | ≈ 8 930 |
| original | — | 868 108 | 474 892 | 4 947 |

En las tres opciones, además: REQ-009, O-16 y los hashes van a los punteros; la fila del Historial se corrige; los destinos se rehacen (`evidencia-ca69-1.36.0.md` desaparece si CA-69 vuelve entero); y se actualiza la fila de REQ-007 en `requirements/README.md`, que el contrato §4 pedía y no se hizo. **Lo aplico por `Edit`, y así la puerta juzga en vivo el documento reconstruido.** Es posible porque el `old_string` es un puntero corto: el presupuesto no se acerca al límite. Después, **la única pasada correctiva de QA** verifica todo junto, y luego la fase 4.

- **(A)** *Consecuencia:* devuelve todo lo que SEC-124 y la nota de CA-24 pueden estar citando, con un corte **estructural** (la viñeta «Punto 5» entera) que no pide al analista otra lectura. El `Edit` se queda en ≈ 2× el original.
- **(B)** *Consecuencia:* devuelve sólo lo que SEC-124 nombra literalmente. Es la más pequeña, pero si QA juzga normativas las listas de movimientos, sale **otro hallazgo y una segunda pasada**, que es tu otra condición de parada.
- **(C)** *Consecuencia:* no hace falta ningún juicio, pero devuelve también registro puro, como el fail-before del punto 1. Es la más conservadora y la que menos gana.

**Lo que esto le hace a tu medida, sin adornos.** **El objetivo «REQ bajo el techo de un `Write`» se pierde en cualquier variante**, y la salida de verdad es F-137-9 (partir REQ-007). Lo que se mantiene es lo que declaraste válido en P-137-D: el `Edit` pasa de 4,9 a ≈ 10 KB por llamada. **Y la medida del coste del analista, según QA:** la comisión de medida (135 909 tokens) es **≈ 15 % más barata** que la mediana de once comisiones comparables de 1.36.0 (≈ 160 k), y cuatro de esas once costaron igual o menos. **Las once ya estaban por debajo de 300 k**, porque el analista ya leía por rangos (`Read` corta en 256 KB). Además, la comparación es sólo parcialmente del mismo tipo: no aplicó nada, y eso sesga la cifra hacia abajo. **«La lectura a menos de la mitad» no está medida:** lo medido es el archivo, al 45 % de sus bytes.

**Mi recomendación: (A).** Cumple tu salvaguarda 1 con un corte que no depende de que nadie interprete nada, y conserva casi todo el beneficio práctico.

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-137-F»; si no, corrige):

> **P-137-F: opción (A).** Vuelven al REQ, verbatim y en su sitio, CA-69 entero (3141–3397 de `cecf9b6`) y las tres viñetas «Punto 5» de D1 (1688–1709, 1781–1806 y 1921–2012). REQ-009, O-16 y los hashes de commit se añaden a los punteros. Se corrigen la fila del Historial y la fila de REQ-007 en `requirements/README.md`, y se rehacen los destinos y el índice. La coordinadora lo aplica por `Edit`, juzgado en vivo; QA hace su única pasada correctiva sobre todo junto; después, seguridad. Queda aceptado que REQ-007 supere el techo de un `Write`; la medida que vale es el presupuesto de `Edit`, re-medido por QA, y la salida de fondo es F-137-9.

### RESUELTA (propietario, 2026-10-12) — **P-137-E: (A), aplicar con redirección juzgada en vivo**; y **F-137-10 pasa a HOTFIX 1.36.1**, que se abre al cerrar F-136-17 y antes de la pieza a)

**Texto del propietario, literal** (mensaje del 2026-10-12 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-137-E: (A). Aplicar con redirección (cat … > …) como llamada Bash normal,
> con la puerta juzgando en vivo; si deniega, parar; después comprobación
> completa, commit y push. Mismas condiciones de P-137-C.
>
> F-137-10 se trata como HOTFIX 1.36.1, no como ficha de 1.37:
> - Se abre al cerrar F-136-17 (fase 4 y commit validado), antes de la pieza
>   a). Alcance único: el detector de escrituras reconoce el destino de cp
>   (y de mv e install, si comparten la causa) como archivo cuando lo es;
>   fail-before contra v1.36.0 con los casos ya medidos a mano (REQ,
>   PLAN.md, desarrollador, cp -T, destino inexistente); regresión completa
>   del banco. Ciclo entero: desarrollador → QA → seguridad.
> - Mientras tanto, se declara en las notas de 1.36.0 como regresión conocida
>   con su forma, su efecto (sobre-denegación) y la salida (redirección o
>   destino nuevo).
> - Nada más entra en 1.36.1.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Las «notas de 1.36.0» son la entrada `[1.36.0]` de `CHANGELOG.md`**: no hay release de GitHub para `v1.36.0` (`gh release view` → «release not found»), así que declararla no publica nada fuera del repositorio. La declaración se **añade** a la entrada, fechada y rotulada como posterior a la publicación; el texto publicado no se reescribe.
- **Hotfix 1.36.1 anotado en `docs/PLAN.md`** con el alcance literal, entre F-136-17 y la pieza a). Al abrirse, el `analista-requerimientos` fija el contrato: el propietario pidió el ciclo desarrollador → QA → seguridad, y **este repositorio no declara la vía proporcional** (`AGENTS.md` §6), así que el analista no se omite. **Esa comprobación la hace la coordinadora por escrito en el encargo**, como manda §6.

### P-137-E (texto de la consulta, conservado) — F-136-17: **la puerta en vivo denegó el `cp`, y la causa no es el contenido.** Desde 1.35.0 todo `cp` que sobrescribe un archivo existente se deniega (F-137-10). ¿Se aplica con la redirección `cat … > …`, que la puerta sí juzga en vivo?

**Lo que pasó.** Hice lo que autorizaste en P-137-C: una llamada `Bash` normal, `cp <scratchpad>/REQ-007.md requirements/REQ-007.md`. **La puerta instalada la denegó en vivo**: «no se pudo determinar a qué archivo escribe '…/requirements/REQ-007.md/'». **Paré**, como mandaste, y **deshice la aplicación parcial**: había copiado ya los 13 destinos y el índice, y los retiré para que no hubiera historia «movida» que seguía también en el REQ. **El REQ está intacto (`cmp` contra la foto de `cecf9b6`).** Los archivos siguen en el scratchpad, con el mismo `sha256`.

**Por qué la denegó: no es el contenido ni esta partición.** Medido fuera de banda, sin escribir nada:
- `cp` sobre un archivo **existente** → **`deny`**: el REQ con ruta absoluta o relativa, y `docs/PLAN.md`, que no es un REQ ni código protegido.
- `cp` sobre un archivo que **no existe** → pasa.
- Con el agente `desarrollador` → **`deny`** igual. Con `cp -T` → **`deny`** igual.
- **Por versión:** 1.33.2 pasaba; **1.35.0 y 1.36.0 deniegan**.

El detector juzga `destino/` como si fuera un directorio, y la identificación del destino de CA-47 falla cerrada. **Es una regresión de 1.35.0, publicada también en 1.36.0, y no está declarada en ningún sitio.** Queda como ficha `F-137-10`; está en `hooks/`, fuera de los límites de esta intervención.

**Lo que sí juzga la puerta en vivo:** `cat <scratchpad>/REQ-007.md > requirements/REQ-007.md`. Medido fuera de banda: la puerta **determina el destino** —la redirección es la forma que su detector lee mejor—, lo juzga y **lo deja pasar**. El juicio en vivo es el mismo que pedías para `cp`: el comando y su destino, no el contenido. El contenido ya tiene su juicio fuera de banda (`allow`) y la §5 después.

**Opciones:**
- **(A) Aplicar con `cat … > …` como llamada `Bash` normal**, juzgada en vivo, con todas las condiciones de P-137-C: sin desactivar nada y, si la puerta deniega, paro. Después, la comprobación completa, commit y push.
  - *Consecuencia:* el paso 1 aterriza hoy, con la puerta mirando el comando en vivo. **No rodea nada:** es una forma que la puerta entiende y juzga, no una que se le escapa.
- **(B) Copias tú.**
  - *Consecuencia:* ningún agente elige la forma del comando. Cuesta una acción tuya.
- **(C) Se espera a que se repare el detector de `cp`** (F-137-10, `hooks/`).
  - *Consecuencia:* F-136-17 queda parada esta ventana con todo preparado.

**Mi recomendación: (A).** La razón por la que pediste `cp` en vivo era que la puerta lo juzgara. Con `cp` no puede juzgar: falla cerrada antes de mirar nada. Con la redirección sí.

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-137-E»; si no, corrige):

> **P-137-E: opción (A).** La coordinadora aplica el paso 1 con `cat <scratchpad>/REQ-007.md > requirements/REQ-007.md` (y los destinos y el índice como antes), en una llamada `Bash` normal juzgada en vivo, con las condiciones de P-137-C: sin desactivar nada y, si la puerta deniega, se para y se registra. Después, la comprobación completa, commit y push. F-137-10 queda como ficha para 1.37, con el `auditor-seguridad` para clasificarla.

### RESUELTA (propietario, 2026-10-12) — **P-137-C adoptada con la copia juzgada EN VIVO, y P-137-D (A)**: el paso 2 no mueve nada; los 30 KB, inalcanzables con la regla; QA y seguridad, sólo sobre el paso 1

**Texto del propietario, literal** (mensaje del 2026-10-12 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-137-C: adoptada. La copia la ejecuta la coordinadora como una llamada
> Bash normal de Claude Code (cp desde el scratchpad a requirements/REQ-007.md),
> de modo que la puerta instalada la juzgue EN VIVO, no sólo en la prueba
> manual previa. Sin core.hooksPath, sin consola externa, sin desactivar
> nada. Después: la comprobación completa (13 destinos exactos, ninguna línea
> ni identificador perdido, 17 hallazgos en su sitio, 13 enlaces), commit y
> push. Si la puerta en vivo deniega, se para y se registra.
>
> P-137-D: (A). El paso 2 no mueve nada. Los 30 KB se declaran inalcanzables
> con esta regla; ficha para 1.37 con las dos salidas: partir REQ-007 en
> varios REQ (cambio de contrato, el más probable) o revisar el techo
> midiendo (toca hooks/). La medida que vale es la del paso 1: Edit pasa de
> 4,9 a 11 KB por llamada y la lectura del analista a menos de la mitad; QA
> la mide en la fase 3. QA y seguridad revisan sólo el paso 1.
>
> F-137-8 queda como ficha. Continúa: aplicar, fase 3, fase 4, commit
> validado.

**Y, en el mismo mensaje:** «Haz el push cuando termines».

**Lo que añade la coordinadora, rotulado como suyo:**
- **Qué juzga la puerta «en vivo» sobre un `cp`, dicho con precisión para que no se lea de más:** los hooks `PreToolUse` corren sobre la llamada `Bash` y juzgan **el comando** —`guard-codigo` la ruta de destino, que no es `codigo_app.globs`; `guard-completado` si el comando menciona el estado terminal, que no lo hace—, **no el contenido del archivo copiado**. El juicio del contenido es la corrida fuera de banda del `Write` equivalente (`allow`, 4,8 s, `sha256` `2edf95c0…48c3`), y la comprobación de que no se pierde nada es la §5, después. Se registran las tres cosas por separado.
- **Ficha nueva `F-137-9`** con las dos salidas estructurales, sin decidir entre ellas.
- **Las firmas de QA y seguridad de F-136-17 van en sus sedes** (`docs/qa/REQ-007.md`, `docs/seguridad/registro-seguridad.md`), **no en la cabecera de REQ-007**: sus `QA:` y `Seguridad:` responden por todos los criterios abiertos del REQ, no por esta partición, y la partición no cambia la cabecera salvo `Archivos:`.

### P-137-C (texto de la consulta, conservado) — F-136-17, paso 1: **ningún agente puede hacer «un solo `Write`» de 390 KB**, y la única otra vía, copiar por consola, rodea el juicio de `guard-completado`. ¿Cómo entra la partición en `requirements/REQ-007.md`?

**Qué trabajo detiene, y qué no.** Detiene **aplicar** el paso 1 al repositorio (y su commit y push). **No detiene** al analista, que ya está acortando su texto (paso 1) y clasificando los doce versionados (paso 2) en una sola comisión; tampoco el ensamblado ni las comprobaciones, que hago en el scratchpad. Cuando decidas, el paso 1 se aplica en minutos.

**El problema, medido.** Adoptaste «un solo `Write`», que era mi redacción, y la escribí sin comprobar que se pudiera ejecutar:

- **Un `Write` lleva el archivo entero dentro de la llamada.** El REQ partido mide ≈ 390 KB, unos **120 k tokens** que habría que emitir **verbatim** en una sola respuesta. No es fiable, y su forma de fallar es la peor posible.
- **Lo comprobé ejecutando a mano la puerta instalada (1.36.0) sobre `Write` equivalentes:** el candidato actual (393 740 B) → **`deny`**, por el techo; el original (868 108 B) → **`deny`**; **ese mismo candidato truncado a 200 KB → la puerta lo deja pasar** (sin decisión = `allow`). Es decir: **si el `Write` gigante se corta, borra media REQ y nada lo detiene**, porque la puerta juzga veredictos y techos, no que el cuerpo siga entero. Lo registro como ficha `F-137-7`.
- **Un `Edit` no sirve:** su presupuesto (|documento| × |`old_string`|) no deja retirar bloques de decenas de KB.
- **La consola (`cp` del archivo ya ensamblado) sí puede**, pero la puerta **no lo juzga**: `guard-completado` sólo deriva por `Bash` lo que menciona el estado terminal, y aquí no lo hace. `AGENTS.md` §13 la admite **diciendo por qué y asumiendo que ninguna puerta lo mide**; y tu instrucción sobre `core.hooksPath` dice que **si un control impide algo, se para y decides tú**. Por eso estoy aquí.

**Opciones:**

- **(A) Copia por consola la coordinadora, con el juicio de la puerta hecho antes y fuera de banda.** Antes de copiar: ejecuto el `guard.sh` **instalado** sobre el `Write` equivalente —mismo `file_path`, mismo contenido byte a byte— y **sólo copio si devuelve `allow`**; registro su salida en el índice. Después: §5 completo sobre el repositorio (13 destinos verbatim, ninguna línea perdida, ningún `CA-xx` perdido, cabecera sólo `Archivos:`), y QA **lo reproduce todo** en la fase 3 sin fiarse de mi salida. El commit lo declara: «aplicado por consola; juzgado fuera de banda por la puerta instalada».
  - *Consecuencia:* el mismo veredicto que daría la puerta, **más** la comprobación de contenido que la puerta no hace, y que un `Write` no tendría. **Pero el juicio en banda no existe:** su registro es mi corrida más la de QA, no la del arnés. Es una excepción **declarada y autorizada**, y hoy es la forma manual de lo que la pieza b) de 1.37 haría solo: preguntar **después** si algo protegido cambió.
- **(B) Copias tú.** Te dejo la orden exacta, el veredicto fuera de banda y el `sha256` esperado; yo corro §5 después.
  - *Consecuencia:* ningún agente rodea una puerta; el acto es humano, como el push. Cuesta una acción tuya y una espera.
- **(C) No se aplica hasta que exista la pieza b).**
  - *Consecuencia:* F-136-17 queda parada esta ventana con todo preparado; el analista seguirá caro hasta entonces.

**Mi recomendación: (A).** La copia no rebaja nada: la puerta dice lo mismo antes de copiar, y además se comprueba lo que la puerta no mira. Lo que la hace aceptable es que **tú la autorices para esta aplicación concreta**: no se convierte en costumbre, y el paso 2 llevará el mismo procedimiento sólo si lo dices.

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-137-C»; si no, corrige):

> **P-137-C: opción (A), sólo para F-136-17 (pasos 1 y 2).** La coordinadora aplica la partición copiando por consola el archivo ensamblado, con dos condiciones: **antes**, la puerta instalada (`guard.sh` de la 1.36.0) juzga fuera de banda el `Write` equivalente, byte a byte, y sólo se copia si devuelve `allow`; **después**, se ejecuta §5 completo sobre el repositorio. Las dos salidas quedan en el índice. El commit lo declara como aplicación por consola juzgada fuera de banda. QA reproduce ambas en la fase 3 sin fiarse de la salida de la coordinadora. Fuera de F-136-17 no vale como precedente.

**Actualización (2026-10-12, después de abrir esta entrada): el paso 1 está ensamblado y comprobado, y sólo espera esta decisión.** Con el texto nuevo acortado por el analista (de 6 194 a 3 761 bytes), el REQ ensamblado mide **391 307 bytes, 1 909 bajo el techo**. §5 en el scratchpad: 13/13 destinos verbatim; ninguna línea perdida salvo las dos ediciones en sitio declaradas; ningún `CA-xx` ni ningún identificador sin rastro desde el REQ (R-050 incluido); los 17 hallazgos abiertos con sede en el REQ; las 13 `ruta#ancla` casan con el título de su destino. **La puerta instalada, fuera de banda, sobre el `Write` equivalente: sin decisión (`allow`), en 4,8 s.** `sha256` del REQ que se copiaría: `2edf95c065e93e771b04efb5e06d67b2a469364e95c72e903b7db8aad91548c3`.

### P-137-D (texto de la consulta, conservado; resuelta arriba) — F-136-17, paso 2: **con tu regla, los 30 KB de margen no se alcanzan.** De los doce versionados no sale nada sin duda; aunque las tres dudas fueran historia, el margen quedaría en ≈ 14,9 KB. ¿Qué se hace con ellas, y con el objetivo?

**Qué trabajo detiene, y qué no.** Detiene el paso 2 y, como QA y seguridad revisan «una vez el resultado de los dos pasos», también las fases 3 y 4. **No detiene** el paso 1, que sólo espera `P-137-C`.

**Lo que encontró el analista, y lo que comprobé yo.** Clasificó los doce bloques con tu regla (`docs/arnes/v1.37.0-f136-17-paso2-clasificacion.md`):
- **CA-41, CA-48, CA-49 y CA-50: se quedan enteros.** Son el texto vigente; en CA-41, la línea 150 dice «manda este versionado» (comprobado), el mismo caso que CA-46.
- **CA-45 (165–206) y CA-47 (266–441) se quedan:** sede única; los puntos 1–10 y F1–F7, que citan SEC-123 y CA-49.
- **CA-47, puntos 11 a 20, se quedan, punto por punto, como pediste.** Del 18 y el 19 cuelgan SEC-124, SEC-125 y QA-023-23; el 20 es norma única de §13 y QA-007-18 cita su «Medida».
- **Quedan tres dudas, y las tres son de CA-45 o CA-47**, así que paró, como mandaste. **Bytes medidos por mí con `wc -c`, no estimados:**

| Duda | Qué es | Bytes | Lectura «historia» | Lectura «vigente» |
|---|---|---|---|---|
| **D-45-1** | CA-45, 207–226 | 1 992 | registro de un experimento en el host sobre `43b948a` | contiene la declaración del límite de R5 que la norma de 199–200 exige que exista, y la cabecera la nombra (l. 6) |
| **D-47-1** | los cinco rótulos «Versionado el …» de CA-47 | 4 752 | ningún rótulo contiene una regla | llevan «manda esta versión»; 742–744 es la **única** frase que da el estado del punto 18; y sin ellos, «11.», «14.» y «18.» siguen a un párrafo y **la lista se muestra mal** |
| **D-47-2** | registro dentro de los puntos 11 y 20 (lo medido, los «Por qué», las notas «Antes») | 6 634 | lo medido y los porqués son registro | «ese texto se queda» cubre también sus sub-viñetas |
| | **total** | **13 378** | | |

**La aritmética:** tras el paso 1, el REQ mide 391 307. Con **las tres** hacia historia queda en ≈ 377 900 más sus punteros: **margen ≈ 14,9 KB, la mitad del objetivo**. Con sólo lo medido de D-47-2, ≈ 3,4 KB. Sin nada, 1,9 KB.

**Y un dato que cambia lo que vale ese margen.** El techo protege el `Write` entero, pero `P-137-C` ha mostrado que **ningún agente emite un `Write` de ~390 KB de forma fiable** (ficha F-137-7). Por eso el margen bajo ese techo **compra poco en la práctica**. Lo que sí compra el paso 1, con o sin margen:
- **El presupuesto de un `Edit` se duplica:** de ≈ 4,9 KB a ≈ 11 KB de `old_string` por llamada.
- **La lectura del analista baja a menos de la mitad.**

Lo segundo es tu otra medida, y la mide QA en la fase 3. **El margen duradero no sale de mover historia: el contenido vigente de REQ-007 son ≈ 378 KB.** Sólo hay dos salidas, y las dos quedan fuera de los límites de esta intervención: **partir REQ-007 en varios REQ**, que es un cambio de contrato del analista, o **revisar el techo midiendo**, que toca `hooks/`.

**Opciones:**

- **(A) El paso 2 no mueve nada.** Las tres dudas se resuelven como **vigentes**. F-136-17 se cierra con el paso 1, y el objetivo de 30 KB se declara **inalcanzable con esta regla**, con una ficha para 1.37 que recoja las dos salidas estructurales. QA y seguridad revisan el paso 1.
  - *Consecuencia:* margen de 1,9 KB. El próximo criterio que crezca vuelve a pasar el techo del `Write`, pero los `Edit` siguen funcionando con el doble de presupuesto. No se toca la norma única de CA-45 y CA-47. Lo más barato y lo más seguro.
- **(B) Las tres dudas, hacia historia.**
  - *Consecuencia:* margen ≈ 14,9 KB, la mitad del objetivo. Saca de la norma única los rótulos que mantienen numerada la lista de CA-47 y la única frase de estado del punto 18. Además pide otra aplicación, más punteros y más superficie para QA y seguridad.
- **(C) Sólo lo medido de D-47-2** (555–562 y 986–990, ≈ 1,5 KB).
  - *Consecuencia:* margen ≈ 3,4 KB. Un paso entero para muy poco.

**Mi recomendación: (A).** Lo que de verdad cambia el coste y el trabajo diario ya lo da el paso 1. Los 13 KB de (B) no llegan al objetivo y salen de la norma única. Y el problema de fondo —que REQ-007 sea un REQ vigente de 378 KB— no lo resuelve mover historia, así que conviene decidirlo en 1.37 con su nombre.

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-137-D»; si no, corrige):

> **P-137-D: opción (A).** El paso 2 no mueve nada: D-45-1, D-47-1 y D-47-2 se quedan como texto vigente. El objetivo de 30 KB queda declarado inalcanzable con la regla de P-137-A, porque el contenido vigente de REQ-007 son ≈ 378 KB; se registra una ficha para 1.37 con las dos salidas estructurales (partir REQ-007 en varios REQ, cambio de contrato con el analista; o revisar el techo midiendo, en `hooks/`), sin decidir entre ellas. F-136-17 sigue con el paso 1 aplicado según P-137-C, y QA y seguridad revisan sólo el paso 1 en las fases 3 y 4. F-137-8 sigue como ficha.

### RESUELTA (propietario, 2026-10-12) — **P-137-B: opción (A)**, dos pasos; CA-47 punto por punto; objetivo ≥ 30 KB de margen; dos pasadas del analista aceptadas sin reiniciar contadores

**Texto del propietario, literal** (mensaje del 2026-10-12 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-137-B: (A).
> Paso 1, ya: el analista acorta su texto nuevo (punteros, fila del
> Historial) hasta que el REQ quepa bajo el techo; un solo Write; comprobación
> línea a línea; commit; push. Los 474 KB comprobados quedan en origin.
> Paso 2: el analista clasifica los doce «Versionado el …» de CA-41/45/47/
> 48/49/50 con la misma regla (enunciado vigente se queda; registro de cómo
> se midió en versión publicada sale), sobre el REQ ya partido. Se para ante
> CUALQUIER duda de CA-45 o CA-47, y CA-47 se revisa punto por punto, no por
> bloque: donde nació un punto vigente (11 a 20), ese texto se queda aunque
> esté bajo un rótulo de versionado. Objetivo: margen ≥ 30 KB bajo el techo.
> QA y seguridad revisan una vez el resultado de los dos pasos. Acepto las
> dos pasadas del analista por encima de lo previsto; los contadores no se
> reinician. R-050 con puntero; índice borrador donde lo dejaste.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Pasos 1 y 2 en una sola comisión del analista**, con el entregable del paso 1 escrito antes de empezar el paso 2, para no pagar dos veces la lectura. Objetivo del paso 1: REQ ensamblado ≤ 392 000 bytes (el máximo que admite la puerta es 393 213 de contenido).
- **El analista lee los versionados en la foto de `cecf9b6`, no en el repositorio:** son idénticos byte a byte en el REQ partido, y una sola numeración es lo que mantiene verificable «nada se borra».
- **«Un solo `Write»` no se puede ejecutar** tal como está escrito, y eso es una decisión tuya: `P-137-C`, arriba.

### P-137-B (texto de la consulta, conservado) — F-136-17, fase 2: **con las salvaguardas aplicadas, la partición autorizada deja REQ-007 en 393 740 bytes, 524 por encima del techo — y por eso ni siquiera se puede aplicar.** ¿De dónde sale el margen, y en qué orden?

**Qué trabajo detiene, y qué no.** Detiene **aplicar la partición** al repositorio (fase 2) y, con ella, las fases 3 y 4. **No detiene** nada más: la partición está **ensamblada y comprobada en el scratchpad** de la coordinadora, y se aplica en minutos en cuanto haya decisión. Mientras esta entrada esté aquí, `guard-completado` deniega marcar cualquier REQ como `completado`; no hay ninguno en camino de cierre.

**Lo medido — ensamblado y medido, no derivado** (cabeza de origen `cecf9b6`; script y salidas en el scratchpad de la sesión):

- **REQ-007 candidato: 2 880 líneas, 393 740 bytes.** Techo de un `Write` del REQ: 393 216 de contenido **más 4** de cabecera de piezas, es decir **393 212 de contenido como máximo**. **Pasa por 528 bytes.**
- **La mecánica está limpia** (contrato de la fase 1, §5): los 13 archivos de destino son **verbatim** (`diff` vacío, uno a uno); los rangos son disjuntos; **ningún `CA-xx` desaparece** del REQ; la cabecera sólo cambia en `Archivos:`; y las únicas líneas del original que no aparecen tal cual son las dos ediciones en sitio declaradas (`Archivos:`, `Tocado por:`, cuyo valor viejo está entero en su archivo de destino). **Lo único que falla es el tamaño.**
- **Por qué no se puede aplicar a 393 740, y no es un tecnicismo:** un `Write` del REQ por encima del techo lo deniega `guard-completado` (`hooks/guard-completado.sh:490`), **y hace bien**. Un `Edit` **no puede retirar un bloque grande**: su presupuesto es |documento| × |`old_string`| ≤ 4 294 967 296, unos **4,9 KB de `old_string` por llamada** con el REQ en 868 KB, y aquí hay bloques de 64, 70 y 85 KB. Copiar el archivo por consola **rodearía la puerta** y no se hace (`AGENTS.md` §13). **Conclusión: la partición sólo se puede aplicar si el resultado cabe bajo el techo.** Era la advertencia del contrato de la fase 1, §6.1, y se ha cumplido.

**Por qué el margen se fue — y mi cifra anterior estaba mal.** En P-137-A te di «≈ 362 700 con D4». Era el **prorrateo de la fase 1, antes de aplicar las salvaguardas** a los rangos; no lo medí, y tenía que haberlo hecho. Al aplicarlas, el analista **devolvió al REQ ≈ 19,5 KB**, y yo **comprobé en disco cada una** de sus razones:
- **CA-24 no sale:** SEC-124 (abierto, `contrato`) cita «**la nota de CA-24**» por nombre. *Tu salvaguarda 1.*
- **CA-46 no sale, y no por salvaguarda: es el texto que manda.** La línea 242 dice «**manda este versionado**», y 232 y 248 sustituyen los apartados (c) y (b) del enunciado de 227. Moverlo dejaría el criterio **afirmando lo contrario de lo que hace el código**.
- **CA-67 sale sólo en parte** (38 de 63 líneas): se quedan el tope de 16 384 bytes y la vía de los avisos, que §13 refleja (*salvaguarda 2*).
- **CA-68 sale sólo en parte** (43 de 103): se quedan la «Medida» con su techo de 40 s, el plazo propio, la trampa de salida, los dos techos (*salvaguarda 2*) y **R2, que SEC-130 cita por nombre** (*salvaguarda 1*).
- **CA-69 sale sin su enunciado ni su punto 7**: E2 lo cita **QA-007-08**, abierto (*salvaguarda 1*).
- Y **cuatro rangos del contrato estaban mal trazados**: CA-24 y CA-58 (los encontré yo) y CA-66 (el analista) **se tragaban o dejaban huérfano un encabezado**; CA-69 empezaba en el enunciado.

**Las dos palancas que hay, medidas:**
- **Compactar el texto nuevo** (punteros, fila del Historial, `Tocado por:`): hoy son ≈ **7 KB**. Apretándolo, el REQ baja a ≈ 389–391 KB: **aplicable, pero con 2–4 KB de margen**, que es menos todavía que los 11 KB que ya rechazaste.
- **Los «Versionado el …» de CA-41, CA-45, CA-47, CA-48, CA-49 y CA-50**, que la fase 1 no inventarió: doce bloques, ≈ **101 KB**. Pero **≈ 83 KB son de CA-47**, y `AGENTS.md` §13 cita CA-47 (y CA-45) como **norma única**; esos versionados son probablemente **donde nacieron los puntos 11 a 20 de CA-47**, y CA-46 acaba de demostrar que un versionado puede **ser** el texto vigente. **Cuánto de esos 101 KB es historia no se sabe sin leerlos bloque a bloque**, y lo más probable es que sea bastante menos de la mitad.

**Opciones:**

- **(A) Dos pasos, y el primero ya.** **Paso 1:** el analista **aprieta su propio texto nuevo** hasta dejar el REQ bajo el techo y añade R-050 (abajo); aplico en un solo `Write`, compruebo §5, commit y push. **Paso 2, dentro de F-136-17:** el analista clasifica los doce versionados **con tu misma regla y tus tres salvaguardas**, leyendo el REQ **ya partido** (≈ 390 KB en vez de 868: más barato), y **para en cualquier duda** de CA-45 o CA-47; lo que salga, sale en un segundo `Write`. **QA y seguridad, una sola vez, sobre el resultado de los dos pasos.**
  - *Consecuencia:* los 474 KB **verificados** quedan en el repositorio y en `origin` ya, que es lo que pediste con el push. El margen real **depende del paso 2** y puede quedar corto si CA-47 resulta normativo. **Gasta dos pasadas del analista más de las previstas** (la condición de parada que nombraste).
- **(B) Primero el paso 2, después una sola aplicación.**
  - *Consecuencia:* un solo `Write`, con el margen que haya. Pero **nada aterriza** hasta que el analista termine de clasificar el núcleo normativo de CA-47 en el archivo de 868 KB —el caro—, y si para en dudas (probable), **la partición entera espera por ellas**.
- **(C) Sólo el paso 1, y los versionados a una ficha de 1.37.**
  - *Consecuencia:* el `Write` entero vuelve a funcionar **hoy**, con 2–4 KB de margen; **el primer criterio nuevo de 1.37 lo vuelve a pasar del techo**. Es la medida cumplida en la letra y no en lo que pediste («margen real»).

**Mi recomendación: (A).** El paso 1 asegura lo verificado, y el paso 2 es más barato y menos arriesgado sobre un archivo de 390 KB que sobre uno de 868. Entre (A) y (B) cambia cuándo aterriza lo seguro, no lo que se decide. (C) sólo si prefieres no gastar ahora el paso 2.

**Lo que hago sin preguntarte, y te lo digo.** (i) **R-050** quedaría sin rastro desde el REQ: vivía en la línea `Tocado por:`, que se reduce, y ningún puntero lo nombra. Tu tercera salvaguarda manda que lo nombre, y el analista lo añade al puntero de `## Trazabilidad` en cualquiera de las tres opciones. (ii) **El índice borrador del analista lo saqué de `docs/historia/REQ-007/`** a `docs/arnes/v1.37.0-f136-17-fase2-indice-borrador.md`: afirma que la historia vive ahí, y hoy sería falso. Vuelve a su sitio cuando la partición se aplique.

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-137-B»; si no, corrige):

> **P-137-B: opción (A).** **Paso 1:** el analista aprieta su texto nuevo (punteros, fila del Historial, `Tocado por:`) hasta que el REQ quede bajo el techo con el máximo margen que permita sin perder la ruta, el ancla ni los identificadores de cada puntero, y añade R-050; la coordinadora aplica en un solo `Write`, comprueba §5, hace commit y push. **Paso 2, dentro de F-136-17:** el analista clasifica los doce «Versionado el …» de CA-41, CA-45, CA-47, CA-48, CA-49 y CA-50 con la misma regla y las mismas tres salvaguardas, sobre el REQ ya partido, y **para en cualquier duda de CA-45 o CA-47**, que son norma única; lo que salga, en un segundo `Write`. **QA y seguridad, una vez, sobre el resultado de los dos pasos.** Si después del paso 2 el margen sigue por debajo de 30 KB, se me dice con la cifra y no se busca más dentro de los criterios.

### RESUELTA (propietario, 2026-10-12) — **P-137-A adoptada con una salvaguarda más y D4 incluida**: el rótulo `CA-xx` no inmuniza; la partición la ejecuta la coordinadora; `rotacion.artefactos` no se enciende

**Texto del propietario, literal** (mensaje del 2026-10-12 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-137-A:
>
> 1. El rótulo CA-xx no inmuniza. Se queda el enunciado de cada criterio;
>    sale el registro de cómo se midió en una versión publicada. Salen D1,
>    D2, D3 y también D4 (quiero margen real, no 11 KB). Salvaguardas, las
>    dos tuyas y una más:
>    - lo que un hallazgo abierto cita por nombre no se mueve;
>    - lo que AGENTS.md §13 declara norma única conserva su texto normativo;
>    - cada bloque movido deja en REQ-007 una línea de puntero con la ruta y
>      el ancla del destino, para que un `grep` del identificador (CA-66
>      punto 5, R-047 §3…) siga encontrándolo desde el REQ.
>
> 2. La partición la ejecuta la coordinadora desde la especificación línea a
>    línea del contrato; el analista escribe punteros, índice y prosa del
>    destino y valida; QA verifica aparte en la fase 3 con conteo y diff.
>    rotacion.artefactos no se enciende: no movería un byte sobre este
>    artefacto. Archivos: se actualiza, como decidiste.
>
> Ficha para la pieza c (no ahora): el analista no tiene Bash y Read corta
> en 256 KB, así que no puede verificar lo que escribe. Hay que decidir en
> 1.37 si el rol recibe una herramienta de verificación acotada o si todo
> conteo/diff es siempre de la coordinadora o de QA.
>
> Continúa con la fase 2.

**Y, en el mismo mensaje, sobre el push:**

> Y haz el push de los cuatro commits antes de que arranque; la fase 2 mueve 400 KB de texto y es justo el tipo de cambio que no quieres tener sólo en local

**Lo que añade la coordinadora, rotulado como suyo:**
- **Push hecho** antes de arrancar la fase 2: `origin/cand/1.37.0` creada en `d8022cc` (los cuatro commits `f7d3c0d`, `408b433`, `23feefe`, `cecf9b6` + `d8022cc`).
- **La tercera salvaguarda cambia el contrato de la fase 1** (§3.3, «una por sección movida»): el puntero pasa a ser **por bloque movido** y debe llevar **ruta y ancla del destino más el inventario de identificadores** que ese bloque contenía, para que un `grep` de `CA-66 punto 5`, `R-047 §3`, `P-136-x`, `QA-xxx` o `SEC-xxx` siga dando resultado **desde el REQ**. El inventario se computa mecánicamente sobre el rango antes de moverlo; no se redacta de memoria.
- **D4 entra**, así que sale también el Grupo 2 completo: previsión ≈ 362 700 bytes, margen ≈ 30 500 sobre el techo de 393 216.
- **Reparto de la fase 2, derivado del punto 2:** la coordinadora hace el movimiento mecánico (foto, medición, extracción verbatim por rangos, ensamblado del REQ y las comprobaciones §5.0–5.6); el `analista-requerimientos` tiene **la autoría final** de los punteros, del índice y de la prosa de destino, y **valida**. La coordinadora redacta un borrador a partir de las plantillas **literales** del contrato (§3.1, §3.2, §3.3) para que el analista no tenga que inventar la forma ni medir; el analista reescribe lo que haga falta, y lo que reescriba se aplica.
- **Ficha de la pieza c registrada:** `F-137-6` en `docs/PENDIENTES.md`. **No se repara ahora**, por orden del propietario.

### P-137-A (texto de la consulta, conservado) — F-136-17, fase 1: **una regla y un despacho**. (1) ¿Un `CA-xx` cuyo contenido es evidencia ya rendida de una versión publicada es «criterio vigente» o «versionado»? (2) ¿Quién ejecuta la fase 2, si el `analista-requerimientos` no tiene consola?

**Qué trabajo detiene, y qué no.** Detiene la **fase 2** (ejecutar la partición) por las dos preguntas. **No detiene** el registro de fichas (hecho: F-137-1 a F-137-5 en `docs/PENDIENTES.md`) ni la lectura del contrato. **Y mientras esta entrada esté aquí, `guard-completado` deniega marcar cualquier REQ como `completado`** — no hay ninguno en camino de cierre, así que no bloquea nada más.

---

#### Decisión 1 — la regla que decide las cuatro dudas de golpe

**La pregunta.** Tu definición dice: «Historia = todo lo de REQ-007 (Historial, versionados, notas de decisiones) anterior a la publicación de v1.36.0 que no sea un criterio vigente ni un hallazgo abierto. Los criterios (CA-xx) y sus notas vigentes se quedan». Las cuatro dudas del analista son **el mismo caso cuatro veces**: un bloque que es *a la vez* las dos cosas — lleva rótulo `CA-xx`, y su contenido es la **evidencia ya rendida** de una ventana que ya se publicó. ¿Se queda por el rótulo, o sale por el contenido?

**Por qué no es una duda de matiz: sin resolverla, la medida de éxito no se cumple.** Cifras releídas del disco sobre la cabeza `cecf9b6` (`REQ-007.md` = 868 108 bytes; techo = 393 216):

| Paso | Qué sale | Bytes que salen | REQ-007 queda en | ¿< 393 216? |
|---|---|---|---|---|
| Grupo 1 | Historial, Trazabilidad, Preguntas abiertas (todas resueltas) y 2 bloques de Notas | 379 680 | **488 428** | **NO**, por 95 212 |
| + D1 | CA-66, evidencia por versionado (l. 1653–2194) | 63 799 | **424 629** | **NO**, por 31 413 |
| + D2 | CA-69 entero (l. 3139–3397), «evidencia obligatoria de la ventana 1.36.0» | 25 778 | **398 851** | **NO**, por 5 635 |
| + D3 | CA-67/CA-68, viñetas de técnica y medición (l. 2286–2348, 3036–3138) | 17 389 | **381 462** | **SÍ**, margen 11 754 |
| + D4 | notas de versionados pasados en CA-24, CA-46, CA-54, CA-58, CA-60 | ≈ 18 800 | ≈ 362 700 | SÍ, margen ≈ 30 500 |

**Léelo así: D1, D2 y D3 no son opcionales — sin las tres, el archivo no baja del techo. La única duda que de verdad es optativa es D4.** Y el margen con D1+D2+D3 es de ~11,7 KB sobre 393 216: **el 3 %**, que un par de criterios nuevos de 1.37 se comen.

**Opciones:**

- **(A) El rótulo `CA-xx` no inmuniza; lo que decide es qué hace el bloque.** Se queda el **enunciado** del criterio —lo que exige, lo que hay que cumplir— y sale el **registro de cómo se midió** en una versión ya publicada, con su puntero. Con dos salvaguardas que no se negocian: **(i)** lo que un **hallazgo abierto** cita por su nombre se queda donde está (SEC-124 cita «CA-66 punto 5»: ese punto no se mueve); **(ii)** lo que `AGENTS.md` §13 declara **norma única** —CA-67 y CA-68, «Límites declarados de 1.36.0»— conserva su **texto normativo** en REQ-007; sólo sale la crónica de construcción. Cumple la medida con D1+D2+D3 y deja D4 a criterio del analista bajo la misma regla.
  - *Consecuencia:* REQ-007 queda en ≈ 362 700–381 500. La evidencia sigue existiendo y citable en `docs/historia/REQ-007/1.36.0/`. **Riesgo:** la frontera «enunciado» / «registro de medición» la traza el analista bloque a bloque, y en CA-67/CA-68 esa línea es fina — por eso la fase 4 (seguridad) existe y revisa exactamente eso.
- **(B) El rótulo `CA-xx` manda: ningún criterio se mueve.** Sólo sale el Grupo 1.
  - *Consecuencia:* REQ-007 queda en **488 428 bytes**, un 24 % **por encima** del techo. **La medida de éxito no se cumple y el `Write` entero sigue denegado**, que es el problema que F-136-17 existe para resolver. El trabajo rebaja el archivo un 44 % y no arregla nada de lo que te molestaba. Honesto, pero es decidir que la intervención no alcanza su objetivo.
- **(C) Como (A), pero D4 también sale, y de entrada.** Margen ≈ 30 500 (el 8 %).
  - *Consecuencia:* la más duradera —aguanta las ventanas siguientes sin volver a partir el archivo— y la que más toca criterios vigentes, incluido CA-54, que es donde más se ha discutido texto. Más superficie para la fase 4.

**Mi recomendación: (A)**, y que D4 lo resuelva el analista aplicando la misma regla, caso por caso, en vez de decidirlo en bloque ahora. Motivo: (B) no cumple el objetivo y lo sabemos antes de empezar; entre (A) y (C), la diferencia es sólo **cuándo** se decide D4, y decidirlo con el bloque delante es mejor que decidirlo en una tabla. Si el analista llega a D4 y el margen le parece corto, lo aplica; si no, lo deja y queda ficha.

#### Decisión 2 — quién ejecuta la fase 2

**La pregunta.** Escribiste «Fase 2 — analista (es texto, no código)». **El `analista-requerimientos` no tiene la herramienta `Bash`** (su definición en el plugin le da `Read`, `Write`, `Edit`, `Glob`, `Grep`). Eso tiene dos consecuencias que no se arreglan con empeño: **(i)** no puede correr el conteo ni el `diff` que el propio contrato exige para demostrar que no se perdió una línea; **(ii)** no puede siquiera **leer** `REQ-007.md` entero —la herramienta `Read` corta en 256 KB—, así que no puede componer el archivo resultante sin retranscribir ~380 KB a mano. Una partición que no se puede verificar **no debe ejecutarse**.

**Opciones:**

- **(A) La ejecuta la coordinadora**, desde la especificación línea a línea del analista, con las órdenes de verificación del contrato; el analista escribe los punteros, el índice y la prosa del destino, y valida el resultado; QA verifica aparte en la fase 3.
  - *Consecuencia:* ninguna comisión nueva, y respeta tu «es texto, no código». El movimiento es **determinista** (rangos de líneas) y **comprobable byte a byte**, así que quién lo teclee importa menos que que se compruebe — y se comprueba dos veces. **Riesgo:** mete a la coordinadora dentro del cuerpo de un REQ, que `AGENTS.md` §5 desaconseja por costumbre aunque ninguna puerta lo impida (`requirements/` no es `codigo_app.globs`).
- **(B) La ejecuta el `desarrollador`**, que sí tiene consola y puede escribir en `requirements/`, bajo la misma especificación.
  - *Consecuencia:* respeta la costumbre de §5 al milímetro. **Pero contradice tu paréntesis**: traes al dueño del código a mover texto, y gastas una comisión más en el rol más caro de convocar.
- **(C) Lo intenta el analista sin consola.**
  - *Consecuencia:* **no la recomiendo y la nombro para descartarla por escrito**: retranscribir 380 KB a mano, sin poder comprobar el resultado, es justo la forma en que se pierde una línea sin que nadie se entere. «Nada se borra» dejaría de ser verificable.

**Mi recomendación: (A).**

#### Lo que decido yo y no te pregunto (te lo digo, no te lo consulto)

El campo **`Archivos:` de la cabecera** (l. 4) sí se actualiza en la fase 2 para declarar `docs/historia/REQ-007/`. Mi encargo le había dicho al analista que no tocara la cabecera y por eso lo devolvió; lo levanto yo porque me diste «trazabilidad», porque ninguna puerta lee ese campo —lo lee `tools/arnes-paralelo.sh` para decidir si dos comisiones son disjuntas— y porque un `Archivos:` desfasado es exactamente la clase de riesgo de SEC-020. No toco ningún otro campo de la cabecera.

---

**Decisión propuesta, lista para adoptar** (si estás de acuerdo, basta «adopto P-137-A»; si no, corrige lo que sea):

> **P-137-A. (1) Regla: opción (A).** El rótulo `CA-xx` no inmuniza un bloque. Se queda el **enunciado** del criterio y sale el **registro de cómo se midió** en una versión ya publicada, con su puntero. Dos salvaguardas: lo que un **hallazgo abierto** cita por su nombre no se mueve (SEC-124 → «CA-66 punto 5» se queda), y lo que `AGENTS.md` §13 declara **norma única** (CA-67, CA-68, «Límites declarados de 1.36.0») conserva su texto normativo en REQ-007; sólo sale la crónica de construcción. D1, D2 y D3 salen. **D4 lo resuelve el analista aplicando esta misma regla, bloque a bloque**, y lo que deje fuera queda como ficha. Si al terminar el REQ no baja de 393 216, **no se ensancha la regla**: se para y se me dice con la cifra.
> **(2) Fase 2: opción (A).** La ejecuta la coordinadora desde la especificación línea a línea del analista; el analista escribe los punteros, el índice y la prosa del destino y valida el resultado; QA verifica aparte en la fase 3. Queda constancia de que es una excepción de ejecución, no un cambio de dueño del texto.
> **(3)** `Archivos:` se actualiza; el resto de la cabecera no se toca. **(4)** `rotacion.artefactos` **no** se declara: el analista lo desaconsejó y lo comprobé en el código (F-137-2 y F-137-3). No vuelve a preguntarse.

_(Pendiente también, de antes: `cand/1.37.0` lleva **4 commits locales sin push**.)_ — **resuelto el 2026-10-12: push hecho, `origin/cand/1.37.0` @ `d8022cc`.**

### RESUELTA (propietario, 2026-10-09) — **Undécima autorización: F-136-17, `REQ-007.md` deja de ser un archivo de 660 KB** (plan de 4 fases; la coordinadora para sólo en las cuatro condiciones declaradas)

**Texto del propietario, literal** (mensaje del 2026-10-09 a la sesión coordinadora del worktree `ArnesJuan-v1.36`; los encabezados `##` del original van citados con `> ` para no cerrar esta sección):

> Undécima autorización — F-136-17: REQ-007 deja de ser un archivo de 660 KB.
>
> ## Decisiones del propietario
> - Historia = todo lo de REQ-007 (Historial, versionados, notas de
>   decisiones) anterior a la publicación de v1.36.0 que no sea un criterio
>   vigente ni un hallazgo abierto. Los criterios (CA-xx) y sus notas vigentes
>   se quedan; lo demás sale.
> - Destino de la historia: docs/historia/REQ-007/ por versión, con un índice;
>   REQ-007 conserva un puntero por sección movida. Nada se borra.
> - rotacion.artefactos: autorizo declararlo ahí si el analista lo justifica;
>   es archivo protegido y lleva gate humano, así que esa edición concreta me
>   la presentas antes de hacerla.
> - Medida de éxito: REQ-007 por debajo del techo de un Write entero (REQ-014)
>   y, de paso, una comisión del analista sobre REQ-007 por debajo de 300k
>   tokens, medida sobre el mismo tipo de encargo que en 1.36.0.
> - Si al partirlo aparece un criterio que ya no es cierto, se registra como
>   ficha; no se corrige en esta intervención.
>
> ## Plan autorizado (cada fase termina en commit local; la siguiente empieza
> ## sin pedir permiso)
> Fase 1 — analista: contrato: qué secciones son historia (lista exacta con
>   líneas), estructura de destino, qué enlaces y anclas cambian (índice,
>   guía, registro de seguridad, docs/qa, PLAN) y cómo se verifica que no se
>   pierde ninguna línea (conteo y diff de contenido movido). Propuesta de
>   rotacion.artefactos, si aplica, como ficha para mi gate.
> Fase 2 — analista (es texto, no código): ejecuta la partición según el
>   contrato; tools/arnes-lectura.sh sin anomalías; verificación de que todo
>   lo movido existe en destino línea a línea.
> Fase 3 — QA: comprueba la verificación, los enlaces, que el banco no cambia
>   (las secciones que crean REQ propios no dependen de REQ-007), y mide una
>   comisión del analista sobre el REQ nuevo. Una pasada correctiva.
> Fase 4 — seguridad: sólo que ningún hallazgo abierto ni criterio vigente
>   desapareció. Commit validado.
>
> ## Lo que decide la coordinadora sola
> Texto, trazabilidad, índices, estructura de docs/historia, orden y
> presupuesto de los despachos, registrar fichas sin repararlas.
>
> ## Cuándo paras y me preguntas (sólo esto)
> La edición de rotacion.artefactos; cualquier criterio o hallazgo que no
> sepas si es historia o vigente; más pasadas que la prevista; publicar.
>
> ## Si la sesión se corta
> Lee ESTADO y la cola y continúa desde la última fase comiteada.
>
> ## Límites
> No hooks/, tools/, tests/ ni AGENTS.md. Nada de las piezas a–d. Push de la
> candidata: recordármelo al final de cada fase.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Medido en disco hoy (cabeza `23feefe`), no estimado:** `requirements/REQ-007.md` son **868 108 bytes** y 4 857 líneas, no los 660 431 que registró la ficha F-136-17 en 1.36.0; el REQ creció durante esa ventana. El techo de un `Write` entero es `ARNES_PIEZAS_MAX_BYTES` = **393 216 bytes** (`hooks/lib.sh:1673`), así que la medida de éxito exige quitar **más de 474 892 bytes**, el 55 % del archivo.
- **Consecuencia aritmética que el encargo de la fase 1 lleva por escrito:** las dos secciones que son historia por su nombre —«Historial de cambios» (188 495 bytes) y «Trazabilidad» (144 287)— suman 332 782 y dejarían el REQ en **535 326 bytes, todavía por encima del techo**. La sección «Criterios de aceptación» mide ella sola **419 441 bytes**. Para cumplir la medida hay que aplicar la definición de historia del propietario **también dentro de los criterios** —sus notas de versiones anteriores a 1.36.0 que no sean nota vigente—, que es justo donde la decisión de «historia o vigente» deja de ser mecánica. De ahí que la condición de parada «cualquier criterio o hallazgo que no sepas si es historia o vigente» sea la que más probablemente se ejerza.
- **Cabecera:** mide 38 287 bytes (el campo `Hallazgos abiertos:` ronda los 13,9 KB, bajo su techo de 16 384). **No se toca:** es el contrato y lo leen las puertas.
- **Precedente del destino:** `docs/historia/propuesta-v1.35.0/`, movido con `git mv` en el cierre de 1.36.0.
- **Despacho:** fase 1 al `analista-requerimientos`. La edición de `.arnes/config.json` (`rotacion.artefactos`) **no se despacha**: si el analista la justifica, vuelve aquí como entrada pendiente antes de hacerse.
- **Recordatorio pendiente al propietario:** `cand/1.37.0` lleva **3 commits locales sin push** (`f7d3c0d`, `408b433`, `23feefe`), y el push se le recuerda al final de cada fase.

### RESUELTA (propietario, 2026-10-08) — **v1.36.0 PUBLICADA** (`main` `f22b905`, tag `v1.36.0`, PR #60) **y orden del plan de 1.37.0**: F-136-17 primero; después a), c), b), d) y la 2b de CA-54; coordinadora en Opus

**Texto del propietario, literal** (mensaje del 2026-10-08 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Publicada: main <cabeza de la fusión>, tag v1.36.0, PR #60. Registra la
> publicación, actualiza la instalación estable en este host y abre 1.37.
> Orden del plan de 1.37, decidido: primero F-136-17 (partir REQ-007 y sacar
> su historial; es la causa del coste del analista), después a) plan de
> desarrollo, c) adelgazamiento con rigor proporcional, b) post-condición de
> filesystem, d) spike de guard-git como mod, y la 2b de CA-54 con los
> contrato declarados. Coordinadora en Opus para 1.37; la prueba con Fable
> se repite, si se repite, sobre una intervención acotada después de
> F-136-17.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Comprobado:** `origin/main` = `f22b905` (fusión de `3956a6f` y `a23a026`); `v1.36.0` → `f22b905`; PR #60 `MERGED` 2026-10-08T14:11:23Z; CI de `main` run `37790430987`: **success** (2278/0/38; autoprueba 117/0).
- **Apertura de 1.37.0:** rama `cand/1.37.0` desde `f22b905`; plan en `docs/PLAN.md` § 1.37.0 con el orden literal del propietario; cada intervención con su autorización en la forma de `templates/autorizacion.md`. **Ninguna intervención está autorizada todavía:** F-136-17 empieza con su encargo al `analista-requerimientos` cuando el propietario lo autorice.
- **La cola queda vacía.**

### RESUELTA (propietario, 2026-10-07) — **P-136-V: SEC-133 límite declarado para 1.37, con la fila de §13 acotada (qué no cubre y su consecuencia)**; write-back de §13, notas `[1.36.0]` con fecha, último commit, push. Nada más entra

**Texto del propietario, literal** (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-V: límite declarado para 1.37, con la fila de §13 acotada (qué no
> cubre y su consecuencia). Write-back de §13, notas [1.36.0] con fecha,
> último commit, push. Nada más entra.

**Lo que añade la coordinadora:** F-136-23 queda confirmada como ficha de 1.37 (con F-136-21/22 y las lecciones L4/L5). El analista acota la fila «No completar un REQ con quality gates en rojo» de `AGENTS.md` §13 y su plantilla (qué no cubre: una gate que lea su entrada estándar, SEC-133; una función importada con el nombre de la orden de una gate, SEC-131 (a); consecuencia: el cierre puede salir sin decisión aunque una gate esté en roja), escribe SEC-133 como límite en CA-68 y en la guía, y cierra las notas con la fecha. La coordinadora copia las notas al `CHANGELOG.md`, hace el último commit y el push. **Fusión, tag y publicación: propietario.** La cola queda vacía.

### RESUELTA (propietario, 2026-10-07; entrada de arriba) — [2026-10-07] (coordinadora) — P-136-V: SEC-133 (`contrato`, media, preexistente): una quality gate que lee su entrada estándar se come la lista de las gates siguientes, y el cierre sale sin decisión aunque una gate posterior esté en rojo. ¿Límite declarado para 1.37 o un arreglo de una línea antes de publicar?

**Contexto.** R-057 (`docs/seguridad/registro-seguridad.md`; evidencia `cand-1.36.0/sec115-118/seg-R057/`, `1f73698`): **determinación final de 1.36.0: conforme con hallazgos, sin veto.** Publicar no empeora nada; retener retendría seis hallazgos mitigados (SEC-115 ×3 vías, SEC-118, SEC-120, SEC-127, SEC-128, SEC-129). El código final es el de R-056 (`c5bf6d4`); la pasada revertida no deja rastro.

**SEC-133.** `hooks/guard-completado.sh:951-958` lee la lista de gates con `done <<< "$ARNES_GATES"` y cada gate (`:953`) hereda esa entrada estándar. Una gate que la lea (`cat >/dev/null`, `read -r x; true`) consume la lista: las gates siguientes no se ejecutan y el cierre sale **sin decisión** aunque una de ellas esté en rojo. **Medido igual en v1.35.0.** Con `</dev/null` en la gate deniega. Es la propiedad que el auditor llama **L4** («la gate es código no confiable dentro del proceso del hook: su veredicto es sólo su código de salida; nada de lo que hereda puede alimentar la lista, el veredicto ni la salida»), de la que QA-007-15 y SEC-131 (a) son otras instancias. También contradice la fila de `AGENTS.md` §13 «No completar un REQ con quality gates en rojo», que promete más de lo medido.

**Opciones.**
- **(A) Límite declarado para 1.37** (ficha F-136-23, con F-136-21/22 y las lecciones L4 y L5 de R-057), y la fila de §13 acotada en el write-back («…salvo las formas declaradas: una gate que lee su entrada estándar, SEC-133; una función importada con el nombre de su orden, SEC-131»). **Consecuencia:** 1.36.0 publica un fail-open **preexistente** más, declarado; no se toca el bucle de gates, que P-136-U acaba de cerrar; cero vueltas. Recomendación del auditor.
- **(B) Arreglo de una línea ahora** (`</dev/null` en la ejecución de cada gate) con caso de banco, re-verificación acotada de QA y determinación corta de seguridad. **Consecuencia:** otra vuelta sobre el mismo bucle (la que P-136-U cortó), ≈ 1 h, y los vectores adversarios de L5 (QA-007-15 y SEC-133) tendrían que entrar al banco antes, como pide el auditor para cualquier intento.

**Recomendación de la coordinadora: (A).** Es preexistente, está medido igual en lo publicado, y el auditor pide que cualquier intento sobre las gates lleve primero los vectores adversarios al banco: eso es una intervención de 1.37, no una línea de hoy.

**Decisión propuesta, lista para adoptar:** «P-136-V: (A). SEC-133 queda como límite declarado, ficha F-136-23 para 1.37 junto con F-136-21/22 y las lecciones L4 y L5 de R-057; la fila «No completar un REQ con quality gates en rojo» de `AGENTS.md` §13 y su plantilla se acota a las formas declaradas (SEC-133, SEC-131 (a)). SEC-134 se corrige como texto antes del tag. Nada más entra.»

**Qué trabajo sigue mientras no se decida:** la corrección de texto de SEC-134 (analista, en curso) y las notas finales; QA investiga el CI rojo. El push espera a esta decisión sólo por el texto de §13.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-07) — **P-136-U: (A)** — se revierte el código de `cd63066`; SEC-132 (a) queda como límite declarado con (b) en F-136-22; QA-007-15/16/17 se cierran por reversión

**Texto del propietario, literal** (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> «P-136-U: (A). Se revierte el código de cd63066 (hooks y banco vuelven a c5bf6d4; se conservan el registro, la versión b43d7ea y la evidencia como historia); QA comprueba que hooks/ es byte a byte c5bf6d4. SEC-132 (a) queda como límite declarado con (b) en F-136-22, para 1.37, con las tres lecciones de diseño escritas y la nota de que v1.35.0 cerraba el REQ sin decisión en ese caso. QA-007-15, 16 y 17 se cierran por reversión. El analista lo escribe en CA-68, CA-69 p. 3, AGENTS.md §13 y la guía. Nada más entra; contadores sin reiniciar.»

**Lo que añade la coordinadora:** la reversión la hace el `desarrollador` (`git revert --no-commit cd63066` sobre `hooks/` y `tests/`, conservando `docs/arnes/` y `CHANGELOG.md`), con la comprobación `git diff c5bf6d4 -- hooks/ tests/` vacía; QA la comprueba; el analista escribe el límite y las lecciones; después seguridad (determinación corta sobre el estado final), notas finales, push, CI y PR fuera de borrador. La cola queda vacía.

### RESUELTA (propietario, 2026-10-07; entrada de arriba) — [2026-10-07] (coordinadora) — P-136-U: la pasada de SEC-132 (a) (`cd63066`) introduce QA-007-15 (`contrato`, media): una gate roja puede escribir «0» en el canal del veredicto y **el REQ se cierra**; más QA-007-16 (stderr retenido) y QA-007-17 (corte superlineal). ¿Se revierte a `c5bf6d4` o se intenta otra pasada?

**Contexto.** Re-verificación acotada de QA sobre `cd63066` (`docs/qa/REQ-007.md`, «SEC-132 (a): re-verificación acotada»; evidencia `cand-1.36.0/sec115-118/qa5/`, `26f6131`). **Conforme:** los cuatro casos de P-136-T pasan (cuatro gates de 20 s y una colgada → `deny` a los 30,2 s; 0 huérfanos; dos cierres a la vez no se interfieren); frontera 29 s pasa / 31 s se corta; fail-before de la gate colgada acreditado en `c5bf6d4` y v1.35.0 (sin decisión a los 60 s; en v1.35.0 el REQ queda cerrado); banco 2306/1/13 (INS-136-1); inventario sin movimientos; +0 procesos; E1 igual; versión 1.36.0 con `jq -e .` rc 0.

**Los tres hallazgos, todos introducidos por `cd63066`:**
- **QA-007-15 (`contrato`, media) — fail-open en la puerta de cierre.** El veredicto de la gate se lee de la tubería que la propia gate hereda (`guard-completado.sh:964`). Una gate roja con `echo 0 >&3; false`, o con `trap "echo 0" EXIT; false`, sale **sin decisión y el REQ queda `completado`**; `c5bf6d4` y v1.35.0 deniegan. Y una gate verde con `exec true`, o con su propia trampa `EXIT`, recibe `deny` con un motivo falso («falló la quality gate»). Son movimientos en las dos direcciones que CA-69 p. 3 no declara.
- **QA-007-16 (`contrato`, baja; efecto en el cliente sin medir):** lo que sobrevive a una gate (también a una que pasa, con un bucle en segundo plano) mantiene abierto el **stderr** del hook después de que decide: en `c5bf6d4` cierra a los 108 ms, en el candidato sólo cerró al matar los procesos a los 75 s. Si el cliente espera a que cierre stderr, el `deny` no llega.
- **QA-007-17 (`contrato`, baja):** `arnes_corta_gate` crece más que linealmente con el ancho del árbol (el tope 4096 limita las vueltas, no la cola): 9 000 descendientes → `deny` a los 50,9 s; 14 000 → sin decisión a los 60 s.

**Opciones.**
- **(A) Revertir el código de `cd63066`** (vuelta a `c5bf6d4`, que tiene QA favorable y R-056 sin veto), conservar la versión `b43d7ea`, y **SEC-132 (a) queda como límite declarado**, junto con (b), en F-136-22 para 1.37, con las tres lecciones de diseño escritas: el canal del veredicto no puede ser escribible por la gate (subshell anidado con el descriptor cerrado); el corte tiene que ser lineal (grupo de procesos, no recorrido del árbol); y la salida de la gate no puede retener el stderr del hook. QA-007-15/16/17 se cierran por reversión. **Consecuencia:** 1.36.0 publica SEC-115 mitigado en sus tres vías medidas y declara la de las gates (preexistente: v1.35.0 también moría a los 60 s, y además **cerraba el REQ** sin decisión, que es peor que lo que publica el candidato). Coste: la reversión del desarrollador (minutos) y una comprobación de QA de que `hooks/` = `c5bf6d4`.
- **(B) Otra pasada acotada** (sería la sexta vuelta del paso 6), con las tres correcciones a la vez y re-verificación completa de QA y seguridad. **Consecuencia:** ≥ 1,5–2 h; el mecanismo necesita diseño (es exactamente el caso de «una mejora se propone antes de implementarse»), y cada pasada de esta serie ha abierto algo nuevo al atacar lo anterior.
- **(C) Publicar con QA-007-15 declarado:** no es una opción: es un fail-open en la puerta de cierre introducido por la ventana.

**Recomendación de la coordinadora: (A).** Un fail-open en `guard-completado` es el defecto más caro que este arnés puede tener, y lo introdujo la pasada. La vía de las gates era preexistente y en v1.35.0 era peor; declararla con sus lecciones es honesto y cabe en las notas. La sexta vuelta sobre el mismo paso contradice «calidad proporcional: sin cadena interminable».

**Decisión propuesta, lista para adoptar:** «P-136-U: (A). Se revierte el código de `cd63066` (hooks y banco vuelven a `c5bf6d4`; se conservan el registro, la versión `b43d7ea` y la evidencia como historia); QA comprueba que `hooks/` es byte a byte `c5bf6d4`. SEC-132 (a) queda como límite declarado con (b) en F-136-22, para 1.37, con las tres lecciones de diseño escritas y la nota de que v1.35.0 cerraba el REQ sin decisión en ese caso. QA-007-15, 16 y 17 se cierran por reversión. El analista lo escribe en CA-68, CA-69 p. 3, `AGENTS.md` §13 y la guía. Nada más entra; contadores sin reiniciar.»

**Qué trabajo sigue mientras no se decida:** nada del cierre que dependa del código. El borrador de notas espera.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-07) — **P-136-T: (B)** — la gate en curso se acota al tiempo que queda del plazo; cambio de compatibilidad declarado; caso de banco con las dos formas

**Texto del propietario, literal** (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisión propuesta, lista para adoptar: «P-136-T: (B). El plazo se comprueba entre gates y la gate en curso se acota al tiempo que queda del plazo: un cierre cuyas gates agotan el plazo se deniega por plazo con motivo propio, antes de los 40 s, incluida una gate colgada. Cambio de compatibilidad declarado: una gate que no termine dentro del plazo se interrumpe y el cierre se deniega. El caso de banco cubre las dos formas: cuatro gates de 20 s y una gate colgada. Nada más entra.»

**Lo que añade la coordinadora:** el desarrollador añade la forma «gate colgada» al caso de banco dentro de su tope; el analista cierra la pregunta abierta de REQ-007 y escribe la propiedad y el cambio de compatibilidad en CA-68, CA-69 p. 3, `AGENTS.md` §13 (ya autorizado) y la guía. La cola queda vacía.

### RESUELTA (propietario, 2026-10-07; entrada de arriba) — [2026-10-07] (coordinadora) — P-136-T: SEC-132 (a) — ¿«plazo comprobado entre gates» (literal de P-136-S) o «la gate en curso se acota al tiempo que queda del plazo» (lo que el código construye)? Cambia el límite declarado y el alcance del cambio de compatibilidad

**Contexto.** P-136-S (1) (A) dice «plazo comprobado entre gates». El encargo de la coordinadora al desarrollador añadió «y, si cabe sin procesos, acota la gate en curso al tiempo que quede del plazo»: eso fue ampliar la letra del propietario, y aquí se corrige. El analista, al escribir CA-68, lo vio y lo dejó como pregunta abierta en REQ-007 («SEC-132 (a): la gate en curso y el techo de 40 s»), sin recomendación.
- **(A) Literal: el plazo se comprueba entre gates.** No interrumpe la gate en curso. Con cuatro gates de 20 s, el `deny` llega hacia los 40 s, **justo en el techo** de respuesta; una sola gate que cuelgue deja al hook **sin decisión** a los 60 s (queda como límite declarado: «el plazo no alcanza a una gate en curso»). Cambio de compatibilidad: sólo los cierres cuyas gates **en conjunto** pasen del plazo.
- **(B) La gate en curso se acota al tiempo que queda del plazo** (lo que el código sin comitear hace: espera con `read -t` y corta con `kill`). Garantiza la decisión antes de los 40 s en todos los casos, incluida una gate colgada. Cambio de compatibilidad mayor: **una sola gate legítima de más de ~30 s**, que en `c5bf6d4` y en v1.35.0 pasa, pasa a `deny` por plazo (en el cliente, de todos modos, un hook de más de 60 s muere sin decisión).
- **Coste:** (B) ya está construido y es lo que QA mediría; (A) exige quitar la interrupción.

**Recomendación de la coordinadora: (B).** La promesa del paso 6 es «el hook siempre emite decisión», y una gate colgada es el caso que (A) no cubre. El plazo propio de 30 s ya es la cifra que decidiste en P-136-C; que las gates lo respeten en conjunto es coherente con ella. El precio es declarar que una gate de más de ~30 s no cabe, y hoy tampoco cabía: la mataba el cliente a los 60 s sin decir nada.

**Decisión propuesta, lista para adoptar:** «P-136-T: (B). El plazo se comprueba entre gates y la gate en curso se acota al tiempo que queda del plazo: un cierre cuyas gates agotan el plazo se deniega por plazo con motivo propio, antes de los 40 s, incluida una gate colgada. Cambio de compatibilidad declarado: una gate que no termine dentro del plazo se interrumpe y el cierre se deniega (en v1.35.0 el cliente mataba el hook a los 60 s sin decisión). El caso de banco cubre las dos formas: cuatro gates de 20 s y una gate colgada. Nada más entra.»

**Qué trabajo sigue mientras no se decida:** el desarrollador termina y comitea su pasada y la versión; QA **espera** a esta decisión para saber qué propiedad valida. El write-back de `AGENTS.md` §13 sigue, con la frase de SEC-132 (a) marcada «sin validar».

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-07) — **P-136-S: (1) (A), (2) (A) y (3)** — adoptada la decisión propuesta, literal; autoriza el write-back de `AGENTS.md` §13, la versión 1.36.0 en los dos archivos de distribución y el push de la candidata

**Texto del propietario, literal** (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisión propuesta, lista para adoptar: «P-136-S: (1) (A): se repara SEC-132 (a) en una pasada acotada con tope de una hora (plazo comprobado entre gates, caso de banco con gates lentas, cambio de compatibilidad declarado, re-verificación acotada de QA y determinación corta de seguridad); SEC-132 (b) límite declarado, ficha 1.37. (2) (A): SEC-131 límite declarado, ficha F-136-21 con F-136-20. (3) autorizo el write-back de AGENTS.md §13 y su plantilla por el analista, la subida de versión a 1.36.0 en los dos archivos de distribución (arnes_version se conserva en 1.33.0), y el push de la candidata al terminar; el PR sale de borrador cuando el CI esté en verde. Fusión, tag y publicación los decido yo con las notas finales delante. Nada más entra; contadores sin reiniciar.»

**Lo que añade la coordinadora:** en paralelo sobre archivos disjuntos, el `desarrollador` repara SEC-132 (a) con tope de una hora y sube la versión en `.claude-plugin/plugin.json` y `marketplace.json` (archivos protegidos), y el `analista-requerimientos` escribe los límites en CA-68, `AGENTS.md` §13 y `templates/AGENTS.md.tpl`. Fichas F-136-21 (SEC-131, con F-136-20) y F-136-22 (SEC-132 (b)) en `docs/PENDIENTES.md`. Después: re-verificación acotada de QA, determinación corta de seguridad, notas finales, push, CI y PR fuera de borrador. La cola queda vacía.

### RESUELTA (propietario, 2026-10-07; entrada de arriba) — [2026-10-07] (coordinadora) — P-136-S: con el paso 6 validado (QA favorable, R-056 sin veto), seguridad abrió SEC-132 (`contrato`, media) y SEC-131 (`contrato`, baja), los dos preexistentes; y el cierre (paso 7) necesita tres autorizaciones tuyas. ¿Qué entra antes de publicar 1.36.0?

**Contexto.** R-056 (`docs/seguridad/registro-seguridad.md`; evidencia `cand-1.36.0/sec115-118/seg-R056/`, `4bd3464`) sobre `c5bf6d4`: en 3 162 combinaciones de entorno más la matriz POSIX, ningún `deny` pasa a `allow` ni a «sin decisión»; todos los movimientos van hacia `deny` y están declarados. **SEC-115, SEC-118 y SEC-129 → `mitigado` en el candidato.** SEC-130 → `instrumento`, F-136-12 (texto corregido). Un control del proveedor detuvo una sonda del auditor (O-56-2); sin reintentar.

**(1) SEC-132 — `contrato`, media, preexistente: el plazo propio no alcanza dos recorridos.**
- **(a) Las quality gates en serie:** el plazo se comprueba **antes** del bucle (`guard-completado.sh:946`), no dentro. Cuatro gates de 20 s → sin decisión a los 60 s. **Alcanzable con una configuración normal** del manifiesto. La reparación es comprobar el plazo entre gates (una línea) y denegar si se agota; es un cambio de compatibilidad (un proyecto con gates lentas verá `deny` por plazo donde antes veía «sin decisión»).
- **(b) `Hallazgos abiertos:` repetida en la cabecera en disco** crece más que linealmente (`lib.sh:3376`, situado por lectura): 20 000 líneas cortas → `deny` a los 48,5 s; 20 000 de 66 caracteres → sin decisión. Un techo sobre el disco de > 660 KB no lo cubriría.
- **Opciones:** **(A)** reparar **(a)** ahora, en una pasada acotada y con tope (una línea, un caso de banco con gates lentas simuladas, re-verificación acotada; cambio de compatibilidad declarado), y **(b)** como límite declarado con ficha para 1.37; **(B)** los dos como límites declarados, ficha para 1.37; **(C)** reparar los dos (b exige otro techo o una normalización lineal: no cabe sin diseño).
- **Recomendación: (A).** (a) contradice la promesa central del paso 6 («el hook siempre emite decisión») con una configuración que cualquier proyecto puede tener; (b) exige diseño.

**(2) SEC-131 — `contrato`, baja, preexistente: estado heredado sin neutralizar ni declarar.** (i) una función importada con el nombre de la orden de una gate hace pasar una gate roja (`guard-completado.sh:953`, el único `eval` del hook); (ii) `ulimit -n` 4 o 5 → el preludio falla y se lee como inerte; (iii) `PATH` (y `#!/usr/bin/env bash` lo resuelve antes de la primera línea). El auditor recomienda para 1.37 declarar la **frontera de confianza del entorno del host** por propiedad y resolver F-136-20 con una **lista blanca** del entorno en `hooks.json`, no con una lista negra.
- **Opciones:** **(A)** límite declarado ahora, ficha F-136-21 para 1.37 junto con F-136-20 (misma frontera); **(B)** reparar (ii) ahora (que el fallo del preludio deniegue en vez de leerse inerte) y declarar (i) y (iii).
- **Recomendación: (A).** Es la misma frontera que ya declaraste en F-136-20; partirla en reparaciones sueltas no la cierra.

**(3) Autorizaciones del cierre (paso 7) que el plan reserva a ti:**
- **(a) `AGENTS.md` §13 y `templates/AGENTS.md.tpl`:** las filas que declaran SEC-115 y SEC-118 como limitaciones tienen que decir lo que hoy es cierto (`mitigado`, con los residuales de R-056). El plan dice «No AGENTS.md», así que necesita tu autorización expresa; lo escribe el analista.
- **(b) La subida de versión** a 1.36.0 en `.claude-plugin/plugin.json` y `marketplace.json` (archivos protegidos: el desarrollador), y `arnes_version` de `.arnes/config.json` **se conserva** en 1.33.0 como en 1.35.0 (es la migración del proyecto), salvo que digas otra cosa.
- **(c) Push** de la candidata para que el PR #60 tenga CI sobre la cabeza final, y después el PR fuera de borrador. Fusionar, etiquetar y publicar siguen siendo tuyos.

**Decisión propuesta, lista para adoptar:** «P-136-S: (1) (A): se repara SEC-132 (a) en una pasada acotada con tope de una hora (plazo comprobado entre gates, caso de banco con gates lentas, cambio de compatibilidad declarado, re-verificación acotada de QA y determinación corta de seguridad); SEC-132 (b) límite declarado, ficha 1.37. (2) (A): SEC-131 límite declarado, ficha F-136-21 con F-136-20 (frontera de confianza del entorno; lista blanca en `hooks.json` en 1.37). (3) autorizo el write-back de `AGENTS.md` §13 y su plantilla por el analista, la subida de versión a 1.36.0 en los dos archivos de distribución (`arnes_version` se conserva en 1.33.0), y el push de la candidata al terminar; el PR sale de borrador cuando el CI esté en verde. Fusión, tag y publicación los decido yo con las notas finales delante. Nada más entra; contadores sin reiniciar.»

**Qué trabajo sigue mientras no se decida:** el commit validado del paso 6 (hecho con esta entrada), el write-back de estado del analista (SEC-115/118/129 `mitigado`; F-136-20 (i) corregida con el `allow` explícito), las notas finales y la guía en lo que no depende de (1) y (3). Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-07) — **P-136-R: (A)** — adoptada la decisión propuesta, literal

**Texto del propietario, literal** (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisión propuesta, lista para adoptar: «P-136-R: (A). La lista estática cubre los builtins que el hook usa, regulares y especiales (return, exit, break, continue, set, shift, :), retirados en modo POSIX; caso de banco con return y break exportadas, decisión en < 5 s; re-verificación acotada de QA. BASH_FUNC_set%% en guardianes sueltos → F-136-20. Nada más entra; contadores sin reiniciar.»

**Lo que añade la coordinadora:** la línea la añade el `desarrollador` (sigue dentro del tope de P-136-Q: 18 minutos usados de 60); F-136-20 gana el `set` suplantado en guardianes sueltos; el analista corrige en CA-68 (ii) la letra «regulares» → «regulares y especiales». La cola queda vacía.

### RESUELTA (propietario, 2026-10-07; entrada de arriba) — [2026-10-07] (coordinadora) — P-136-R: QA-007-14 (`contrato`, baja): la lista estática de `entrada.sh` no retira los builtins **especiales** que el hook usa (`return`, `exit`, `break`, `continue`, `set`, `shift`, `:`); tras `set +o posix` vuelven a ser suplantables. Una línea lo repara. ¿Entra o es límite?

**Contexto.** Re-verificación acotada de QA sobre `39e6128` (`docs/qa/REQ-007.md`, «Paso 6: re-verificación de la pasada acotada de P-136-Q»; evidencia `cand-1.36.0/sec115-118/qa3/`, `84fbf80`). **QA-007-13 cerrado:** `builtin` da 0 diferencias en 567 combinaciones; `ls -la` sin decisión en 110 ms y `Write` con `deny` en 111 ms donde `03cbf5e` moría a los 60 s; sin dependencia de `/proc/self/environ`; matriz POSIX, bloque P, QA-007-10/12, T1–T3 y E1 sin cambio; banco 2301/0/13; inventario 2038/0/12; +0 procesos.

**QA-007-14.** P-136-Q dice «`unset -f` de una LISTA ESTÁTICA … (builtins **regulares** que el hook usa + externos que invoca)». El desarrollador siguió esa letra. Los builtins **especiales** (`return`, `exit`, `break`, `continue`, `set`, `shift`, `:`) quedaron fuera: el modo POSIX los protege sólo hasta el `set +o posix` del final del preludio, y después una función importada con ese nombre vuelve a suplantarlos. Medido por `guard.sh`:
- `BASH_FUNC_return%%`: `Write` a `src/a.ts`, `Bash` que escribe en `src/`, `git reset --hard` y completar un REQ salen **sin decisión** (rc 139);
- `BASH_FUNC_break%%`: el hook **no termina** (cortado a 10 s) y `git reset --hard` sale sin decisión;
- `BASH_FUNC_exit%%`: la decisión sale con rc 1, 2 o 139; `continue` con `exit 0`: sin decisión en `Bash`.
- Con esos 7 nombres difieren **156 de 315** combinaciones; en `03cbf5e` difieren 6 (las preexistentes de `set` en guardianes sueltos); en **v1.35.0, 200**. Es regresión frente a `03cbf5e` y mejora frente a lo publicado.
- **Reparación medida por QA fuera del hook (`qa3/14-`):** en modo POSIX, `unset -f return exit break continue set shift :` retira esas funciones; sin procesos. Una línea en la lista estática.
- **Resto preexistente:** `BASH_FUNC_set%%` en los guardianes ejecutados sueltos: ejecutan `set -uo pipefail` **antes** de cargar `entrada.sh` (`guard-codigo.sh:19`, `guard-git.sh:32`, `guard-completado.sh:18`); fuera del camino de producción (`hooks.json` sólo lanza `guard.sh`). F-136-20 no lo nombra.

**Opciones.**
- **(A) Completar la lista estática con los builtins especiales que el hook usa** (una línea; sigue siendo la técnica de P-136-Q, con la letra corregida: «builtins que el hook usa, regulares y especiales»), un caso de banco con `return` y `break` exportadas, y re-verificación acotada de QA. `BASH_FUNC_set%%` en guardianes sueltos → F-136-20 (preexistente; fuera del camino de producción). **Consecuencia:** ≈ 30–40 minutos; el candidato queda mejor que `03cbf5e` en todo lo medido.
- **(B) Límite declarado** (F-136-20 ampliada): una función importada con el nombre de un builtin especial deja al hook sin decisión o colgado. **Consecuencia:** se publica una regresión frente a `03cbf5e` (aunque mejora frente a v1.35.0), y CA-68 (ii) queda contradicho por su propio ejemplo.
- **(C) Volver a `03cbf5e`** (la limpieza por `/proc/self/environ`, que sí retiraba todo): recupera el cuelgue de 60 s con `builtin` suplantado. No.

**Recomendación de la coordinadora: (A).** Es la misma reparación que ya autorizaste, con la palabra «regulares» corregida: la lista tiene que cubrir los builtins que el hook usa, sean regulares o especiales. El coste es una línea y una re-verificación corta.

**Decisión propuesta, lista para adoptar:** «P-136-R: (A). La lista estática cubre los builtins que el hook usa, regulares y especiales (`return`, `exit`, `break`, `continue`, `set`, `shift`, `:`), retirados en modo POSIX; caso de banco con `return` y `break` exportadas, decisión en < 5 s; re-verificación acotada de QA. `BASH_FUNC_set%%` en guardianes sueltos → F-136-20. Nada más entra; contadores sin reiniciar.»

**Qué trabajo sigue mientras no se decida:** nada del paso 6 (seguridad espera a QA favorable).

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-07) — **P-136-Q: (A), con tope de una hora y acotada a QA-007-13**; lista estática de `unset -f`; caso de banco con `builtin` y `read` exportadas y decisión en < 5 s; F-136-20 como límite declarado

**Texto del propietario, literal** (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-Q: (A), con tope de una hora y acotada a QA-007-13:
> - entrada.sh arranca con POSIXLY_CORRECT=y; `unset -f` de una LISTA ESTÁTICA
>   escrita en el archivo (builtins regulares que el hook usa + externos que
>   invoca), sin descubrir nombres con declare/compgen/read; bucle sin
>   órdenes suplantables o con tope; `set +o posix` al terminar el preludio.
> - Caso de banco: funciones `builtin` y `read` exportadas (la de `builtin`
>   devolviendo 0), orden inocua, decisión emitida en < 5 s.
> - Límites declarados (F-136-20, 1.37): `.`/`[` antes de entrada.sh,
>   errexit, y BASH_ENV si no está ya cubierto; resolución desde hooks.json.
> - Re-verificación de QA acotada; si no cabe en pocas líneas, (B). Nada más
>   entra; contadores sin reiniciar.
> PR-136-4 registrada; va con PR-136-1 a 3.

**Lo que añade la coordinadora:** la pasada la hace el `desarrollador` con tope de una hora de reloj; la re-verificación de QA se acota al bloque nuevo, a la regresión y a una regresión corta del preludio. F-136-20 en `docs/PENDIENTES.md`. La cola queda vacía.

### RESUELTA (propietario, 2026-10-07; entrada de arriba) — [2026-10-06] (coordinadora) — P-136-Q: QA-007-13 (`contrato`, baja): una función importada del entorno llamada `builtin` deja al hook sin decisión, y si devuelve 0 **toda llamada muere a los 60 s** (regresión de la pasada correctiva). No quedan pasadas en el plan. ¿Una pasada acotada más, o límite declarado?

**Contexto.** Re-verificación de QA de `03cbf5e` (`docs/qa/REQ-007.md`, «Paso 6: re-verificación de la pasada correctiva»; evidencia `cand-1.36.0/sec115-118/qa2/`, `6cf1ba0`). **Conforme:** QA-007-10, QA-007-11 (a) y QA-007-12 **cerrados** (393 casos con bytes no UTF-8 sin fallo; 38 930 combinaciones de variables sin diferencias; 7 272 con `localvar_inherit`); T1–T3 y la matriz POSIX en `deny`; E1 igual; inventario sólo con INS-136-2 y 2 (c); banco 2299/0/13; autoprueba 117/0; gates rc 0; +0 procesos. QA-007-08 reclasificado a `instrumento` (INS-136-4).

**QA-007-13.** CA-68 (ii) promete «la misma decisión que sin ese estado» para cualquier estado heredado, y cita las funciones importadas como ejemplo. Atacando la limpieza de `entrada.sh` con funciones importadas que llevan el nombre de 21 órdenes que usa el preludio (567 combinaciones por árbol):
- **`builtin` — REGRESIÓN de `03cbf5e`:** la limpieza protege sus órdenes con `builtin`, que **no** es un builtin especial y una función puede suplantarlo. Con `BASH_FUNC_builtin%%` exportada, todo lo que debería denegarse sale sin decisión; si esa función devuelve 0, el bucle `while IFS= builtin read …` sobre `/proc/self/environ` no avanza y **cualquier llamada tarda 60 100 ms y sale con rc 124**, incluso `ls -la` (107 ms en `8e11f87` y v1.35.0).
- **`.` y `[` — preexistentes:** `guard.sh` los ejecuta antes de cargar `entrada.sh`, así que ninguna limpieza interna llega a tiempo (sólo la orden de `hooks.json` podría).
- **`SHELLOPTS=errexit` — preexistente, falla hacia el lado cerrado:** deniega todo, también lo legítimo.
- **Dato medido por QA fuera del hook:** con `POSIXLY_CORRECT=y` activo, las funciones no pueden suplantar a los builtins **especiales** (`unset`, `set`, `.`, `eval`, `export`…), sin crear procesos; `builtin`, `shopt`, `printf`, `read` y `[` **no** son especiales.
- **Vector:** exige un entorno que exporte una función con ese nombre al proceso de Claude Code; quien puede hacerlo ya podía exportar `BASH_FUNC_jq%%` en v1.35.0 (sin decisión). Severidad baja según QA; la consecuencia nueva es la **disponibilidad** (60 s por llamada).

**Opciones.**
- **(A) Una pasada más, acotada y con tope**, que excede el plan: en `entrada.sh`, antes de cualquier otra orden, `POSIXLY_CORRECT=y` para que los builtins especiales no puedan ser suplantados, retirar con `unset -f` (especial) las funciones homónimas de todas las órdenes que la limpieza va a usar (`builtin`, `shopt`, `printf`, `read`, `[`…), y sólo después la limpieza actual y `set +o posix`; sin bucle que dependa de órdenes suplantables (o con tope de iteraciones). Caso de banco por `builtin` (sin decisión y la variante que cuelga, con `timeout`). `.` y `[` en `guard.sh` antes de `entrada.sh` → **límite declarado** (F-136-20: la frontera es la orden de `hooks.json`, 1.37). `errexit` → límite declarado del lado cerrado. Re-verificación de QA acotada al bloque nuevo y a la regresión. **Consecuencia:** ≈ 1 h más; el candidato no publica un cuelgue de 60 s nuevo. Si la reparación no cabe en unas pocas líneas, se para y se vuelve a (B).
- **(B) Límite declarado**, sin más pasadas: una función importada con el nombre de una orden del preludio (`builtin`, `.`, `[`) deja al hook sin decisión o colgado 60 s; ficha F-136-20 para 1.37 (`hooks.json`). **Consecuencia:** se publica una regresión de disponibilidad introducida en esta ventana, declarada; el contrato CA-68 (ii) tendría que acotar «funciones importadas» para no contradecirse.
- **(C) Revertir la parte de QA-007-11 (a)** (la limpieza de funciones importadas) y declararla límite, conservando QA-007-10 y QA-007-12. **Consecuencia:** vuelve `BASH_FUNC_jq%%` → sin decisión (que ya tenía v1.35.0) y desaparece el cuelgue; también es un cambio de código que QA tiene que volver a mirar, así que no ahorra la re-verificación.

**Recomendación de la coordinadora: (A), con tope de una hora.** Un cuelgue de 60 s por llamada es la clase de defecto que el paso 6 existe para eliminar («el hook siempre emite decisión»), y lo introdujo esta ventana; publicarlo como límite declarado contradice la promesa que estamos a punto de firmar. La técnica ya está medida por QA fuera del hook y es de pocas líneas. Si no cabe en el tope, (B).

**Decisión propuesta, lista para adoptar:** «P-136-Q: (A), con tope: una pasada acotada a QA-007-13 (`POSIXLY_CORRECT=y` al arrancar, `unset -f` de las homónimas de las órdenes del preludio, bucle sin órdenes suplantables o con tope, `set +o posix` después), con caso de banco y re-verificación de QA acotada; `.`/`[` antes de `entrada.sh` y `errexit` como límites declarados (F-136-20). Si no cabe en pocas líneas, (B). Nada más entra. Los contadores no se reinician.»

**Qué trabajo sigue mientras no se decida:** nada del paso 6 (seguridad espera a QA favorable). El borrador de las notas y la ficha F-136-20 se preparan.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-06) — **P-136-P: (1) (A) y (2) (A)** — adoptada la decisión propuesta, literal

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisión propuesta, lista para adoptar: «P-136-P: (1) (A): QA-007-08 es INS-136-4; F-136-8 se amplía a CA-09; REQ-017 no se reabre. (2) (A): la pasada correctiva repara QA-007-10, QA-007-12 y QA-007-11 (a); QA-007-11 (b) y QA-007-09 quedan como límites declarados con ficha para 1.37. Nada más entra.»

**Lo que añade la coordinadora:** INS-136-4, la ampliación de F-136-8, y las fichas F-136-18 (QA-007-09) y F-136-19 (QA-007-11 (b)) en `docs/PENDIENTES.md`. En paralelo y sobre archivos disjuntos: el desarrollador hace la **única pasada correctiva** del paso 6 (`hooks/`, banco, `docs/arnes/`) y el analista escribe los límites declarados y el cierre de QA-007-08 como instrumento (`requirements/`, guía). Después, QA re-verifica; seguridad (fase 4); commit validado; paso 7. La cola queda vacía.

### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-06] (coordinadora) — P-136-P: QA del paso 6 CON HALLAZGOS; (1) E2 dio 1 FAIL en 6 corridas de REQ-017 CA-09 (regla «afecta» → §9, decisión tuya); (2) alcance de la única pasada correctiva ante cinco hallazgos `contrato` más (QA-007-09 a QA-007-12)

**Contexto.** `docs/qa/REQ-007.md`, «Paso 6: validación de SEC-115, SEC-118, SEC-129 y QA-007-07»; evidencia `cand-1.36.0/sec115-118/qa/`, commit `e19b708`; código `8e11f87`. **Conforme:** sección 47 95/0 con fail-before (`78a2f33` y v1.35.0 36/59); SEC-118 con UTF-8 válido (motivos de 16 382–16 384 bytes; los avisos de 140 KB se emiten); SEC-115: T1–T3 en `deny` en 0,4–2,6 s, T2b en 0,2–0,4 s (v1.35.0: 32–38 s), el plazo actúa en una llamada real (REQ de 3 MB → `deny` a los 36,3 s); E1 sin cambio; E3 PASS; techos: fronteras reproducidas, nada cambia fuera de `requirements/`; matriz POSIX en `deny`; QA-007-07 reparado; R2 deniega `exit` inesperado y códigos no declarados; banco 2292/0/13; autoprueba 117/0; gates rc 0; +0 procesos; **INS-136-3** (la sección 24 no se reproduce en 15 corridas + inventario). **Cerrados por QA:** QA-007-07 y **QA-023-10** (en su medición, 35 corridas sobre `82ceb63`). **SEC-130: confirmado que R2 no lo cubre** (`ulimit -n 3` → cierre por `sed` sin decisión); sigue F-136-12.

**(1) QA-007-08 — E2 «afecta».** CA-69 p. 7 dice: un FAIL en E2 → parar y presentar con §9. El candidato dio **4 PASS, 1 SKIP por solape y 1 FAIL (corrida 4, 0,962×)**; v1.35.0, 5 PASS y 1 por solape. E1 (las tres entradas de la sonda a nivel de hook) **no muestra ningún cambio** de decisión ni de duración, así que la causa que la ficha preparada presuponía (un techo o el plazo) no aparece. La cifra 0,962× es **por debajo de 1**: el candidato salió más rápido que la referencia en esa corrida, no más lento. REQ-017 está `completado`.
- **(A) Registrarlo como instrumento (INS-136-4)** y ampliar F-136-8 a CA-09: la sonda 37/3 también decide sobre una banda que el ruido del anfitrión cruza (INS-136-1 y 2 ya lo documentan para CA-03 y CA-08 (ii)); E1 es la medida directa y no cambia. **Consecuencia:** REQ-017 no se reabre; la revisión del instrumento queda en 1.37 con F-136-8. Sin código.
- **(B) Reabrir REQ-017 por §9** (vuelve a `en-revisión` y re-recorre el ciclo). **Consecuencia:** un ciclo completo sobre un REQ cerrado, por una corrida de 6 con el candidato más rápido.
- **(C) Repetir E2 en anfitrión sano** (≥ 6 corridas, carga < 0,5 registrada), sin repetir hasta el verde: si vuelve a dar FAIL en la misma dirección, (A); si da FAIL con el candidato más lento, (B). **Consecuencia:** 20–30 minutos.

**(2) Los cinco hallazgos `contrato` y la única pasada correctiva del plan:**

| Id | Qué | Preexistente | Cabe en la pasada sin cambiar alcance |
|---|---|---|---|
| **QA-007-10** | `ARNES_CWD_VISTO` heredada del entorno cambia la decisión (barrido de 32 810 combinaciones; sólo ésa) | sí | **Sí:** es la propiedad (ii) de P-136-N; vaciarla al cargar y un caso |
| **QA-007-12** | con bytes no UTF-8 venidos del disco, el motivo emitido llega a 48 781 bytes (se acota antes de que `jq` sustituya cada byte por U+FFFD); la decisión se emite | no (lo introduce la fase 2) | **Sí:** acotar después de sanear; CA-67 lo exige |
| **QA-007-11 (a)** | estado del intérprete heredado: `FUNCNEST=1/2`, `BASH_COMPAT` 31–42, `compat*`, `keyword`, funciones importadas (`BASH_FUNC_jq%%`) dejan sin decisión o rompen el JSON | sí | **Sí:** neutralizables en `hooks/entrada.sh` (propiedad (ii)) |
| **QA-007-11 (b)** | `SHELLOPTS=noexec` u `onecmd`, y `xtrace` con `BASH_XTRACEFD=1`: no se pueden neutralizar desde dentro del hook; piden actuar en `hooks.json` o declarar la frontera | sí | **No:** decisión de alcance |
| **QA-007-09** | un `Edit` pequeño que cierra un REQ con **CRLF en disco** de ≥ 3,6 MB sale sin decisión a los 60 s (`guard-completado.sh:604`, superlineal y sin techo: el techo mide la entrada, no el disco); v1.35.0 falla desde 3 MB | sí | **No:** un techo sobre el documento en disco es otro cambio de compatibilidad (y `REQ-007.md` tiene 660 KB) |

- **(A) La pasada repara QA-007-10, QA-007-12 y QA-007-11 (a).** QA-007-11 (b) y QA-007-09 quedan como **límites declarados** con ficha para 1.37 (la frontera de `hooks.json`, y un techo sobre el disco o una normalización lineal del CRLF, propuestos antes de hacerse). **Consecuencia:** una pasada acotada y una re-verificación; 1.36.0 publica dos límites más, declarados en las notas, los dos preexistentes y peores en v1.35.0.
- **(B) La pasada repara también QA-007-09** con un techo sobre el tamaño del documento en disco para la vía CRLF (cifra por fijar, por encima de 660 KB). **Consecuencia:** otro movimiento `allow` → `deny` que el contrato tiene que declarar; alarga la pasada.
- **(C) Sin pasada:** todo como límite declarado. **Consecuencia:** se publica con QA-007-12 (introducido por esta ventana) y QA-007-10 abiertos.

**Recomendación de la coordinadora: (1) = (A); (2) = (A).**

**Decisión propuesta, lista para adoptar:** «P-136-P: (1) (A): QA-007-08 es INS-136-4; F-136-8 se amplía a CA-09; REQ-017 no se reabre. (2) (A): la pasada correctiva repara QA-007-10, QA-007-12 y QA-007-11 (a); QA-007-11 (b) y QA-007-09 quedan como límites declarados con ficha para 1.37. Nada más entra.»

**Qué trabajo sigue mientras no se decida:** el write-back de estado del analista (QA-007-07 construido en `8e11f87`; punteros de `lib.sh`; QA-023-10 cerrado), que no depende de esto. La pasada y seguridad esperan.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-06) — **P-136-O: (1) (A) y (2) (A); P-136-N: (A)** — adoptada la decisión propuesta por la coordinadora, literal

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisión propuesta, lista para adoptar: «P-136-O: (1) (A) y (2) (A). P-136-N: (A).»

**Texto adoptado** (el de la coordinadora en las fichas P-136-O y P-136-N, que el propietario hace suyo con esa respuesta):
- **P-136-O (1) (A):** los techos de tamaño (`ARNES_PIEZAS_MAX_BYTES` = 393 216 y `ARNES_EDIT_MAX_BUSQUEDA` = 2³²) quedan como **cambio de compatibilidad declarado**; el analista lo escribe en CA-68, CA-69 p. 3, la guía y las notas (consecuencia: un REQ de más de 393 216 bytes no se escribe entero de una vez, y un `Edit` con `old_string` de más de ~6,5 KB sobre un documento de ese tamaño se deniega: se parte la edición). **Ficha para adelgazar `REQ-007.md`** a `historial/` en 1.37.
- **P-136-O (2) (A):** QA observa el FAIL de la sección 24 en su propio inventario y en varias corridas de la sección en reposo; si lo reproduce, es hallazgo; si no, INS-136-3.
- **P-136-N (A):** QA-007-07 entra en el paso 6 con SEC-129, bajo la propiedad de CA-68 enunciada sobre el entorno heredado: ninguna decisión del hook depende de nada que herede del entorno (modo del intérprete, variables `ARNES_*`; `BASH_ENV` queda como ficha F-136-9). Caso de banco para cada variable. Nada más entra.

**Lo que añade la coordinadora:** en paralelo y sobre archivos disjuntos, el desarrollador repara QA-007-07 (`hooks/lib.sh`, banco, `docs/arnes/`) y el analista escribe el movimiento de los techos y la propiedad ampliada (`requirements/`, guía). Después QA (fase 3), seguridad (fase 4), commit validado y paso 7. La cola queda vacía.

### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-06] (coordinadora) — P-136-N: QA-007-07 (`contrato`, baja, preexistente): variables `ARNES_*_LISTO` heredadas del entorno dejan a las puertas sin decidir. ¿Entra en el paso 6 junto a SEC-129, o va a 1.37?

**Contexto.** Hallazgo nuevo de QA en el paso 5 (F-136-11 en `docs/PENDIENTES.md`). No lo introduce el paso 5: v1.35.0 se comporta igual. Es la misma familia que SEC-129 (`POSIXLY_CORRECT`): un estado heredado del entorno apaga las puertas sin ruido. La reparación es inicializar dos variables al cargar `lib.sh` (una línea; sin procesos). La propiedad que R-054 propone para CA-68 lo cubre si se enuncia sobre «el entorno heredado» y no sólo sobre «el modo del intérprete».

**Opciones.**
- **(A) Entra en el paso 6 (SEC-115/118), junto a SEC-129,** como parte de la misma propiedad: «ninguna decisión depende de nada heredado del entorno». El analista lo escribe en CA-68 con SEC-129; el desarrollador lo repara en la misma fase; QA y seguridad lo cubren con un caso de banco. **Consecuencia:** coste marginal (una línea y un caso); el paso 6 crece en una variable de la misma clase que ya trata.
- **(B) Ficha para 1.37.** **Consecuencia:** 1.36.0 se publica con un `contrato` abierto que una variable de entorno puede explotar, declarado en las notas; REQ-007 sigue sin poder cerrarse por él.

**Recomendación de la coordinadora: (A).** Sirve a «calidad proporcional» sin dañar «autonomía útil»: no abre ningún ciclo nuevo, va dentro del que ya existe para la misma clase de defecto.

**Decisión propuesta, lista para adoptar:** «P-136-N: (A). QA-007-07 entra en el paso 6 con SEC-129, bajo la propiedad de CA-68 enunciada sobre el entorno heredado: ninguna decisión del hook depende de nada que herede del entorno (modo del intérprete, variables `ARNES_*`, `BASH_ENV` queda como ficha F-136-9). Caso de banco para cada variable. Nada más entra.»

**Qué trabajo sigue mientras no se decida:** todo lo del paso 5 (write-back de QA-007-06, su cierre por QA, la determinación de seguridad y el commit validado), que no depende de esto. La apertura del paso 6 espera a esta decisión sólo en su alcance; su plan se redacta con las dos variantes.

**Espera:** elección del propietario.


### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-06] (coordinadora) — P-136-O: la fase 2 del paso 6 (`0efd3c2`) cumple el contrato, pero (1) sus techos de tamaño deniegan dos llamadas legítimas sobre `REQ-007.md` (660 KB) que v1.35.0 dejaba pasar, y (2) un FAIL no reproducido en el inventario, en un caso que ejecuta código del delta

**Contexto.** `docs/arnes/v1.36.0-sec115-118-fase2.md`; evidencia `cand-1.36.0/sec115-118/`, commit `65092c8`. **Conforme:** sección 47 93/0 (D y A con motivos de ≤ 16 384 bytes; T1–T3 en `deny` en 0,4–4,3 s; las 40 filas POSIX en `deny`); tope del motivo medido en 273 casos ASCII y multibyte; E1 sin cambio, E2 12/12 PASS, E3 PASS; inventario 2 (a) sólo con 2 (c), INS-136-2 y un nombre de caso que depende del PID; banco 2290/0/13; autoprueba 117/0; gates rc 0; +0 procesos. Técnica: el motivo va a `jq` por la entrada estándar y se acota a 16 384 bytes; plazo propio a 30 s (responde en ≤ 40); techos `ARNES_PIEZAS_MAX_BYTES` = 393 216 y `ARNES_EDIT_MAX_BUSQUEDA` = 2³²; `hooks/entrada.sh` nuevo con `unset POSIXLY_CORRECT; set +o posix` y una trampa de salida que emite `deny` fijo si el proceso termina sin juicio; R2 para códigos no declarados y puertas abandonadas. **SEC-130 no queda cubierto por R2** (su 0 es respuesta válida de su vocabulario): sigue como F-136-12, para 1.37.

**(1) Las llamadas legítimas que pasan a `deny`** (`65-`), todas sobre `REQ-007.md`, 660 431 bytes:

| Llamada | v1.35.0 | candidato |
|---|---|---|
| `Write` del archivo entero | sin decisión (allow), 11,5 s | `deny` por el techo de piezas (393 216 B) |
| `Edit` con `old_string` de 3 000–6 400 B | sin decisión | sin decisión |
| `Edit` con `old_string` de 7 000 o 12 000 B | sin decisión | `deny` por el presupuesto de búsqueda |

`REQ-021.md` (296 976 B) y `REQ-023.md` siguen igual. Subir el techo de piezas costaría margen: un `Write` de 786 428 B tarda 15,7–18,4 s solo, y bajo carga roza los 40 s. Optimizar la normalización de transporte sería una mejora que se propone antes de hacerse y movería el perfil de la sonda 37/3. **Es un movimiento `allow` → `deny` que CA-69 p. 3 no declara:** cambio de contrato, del propietario.

**Opciones para (1).**
- **(A) Aceptar los techos como cambio de compatibilidad declarado,** con el write-back del analista en CA-68 y CA-69 p. 3 (el movimiento, sus dos cifras y la consecuencia: un REQ de más de 393 216 bytes no se escribe entero de una vez, y un `Edit` con `old_string` de más de ~6,5 KB sobre un documento de ese tamaño se deniega; se parte la edición), notas y guía. **Y una ficha para adelgazar `REQ-007.md`** (su historia a `historial/` con la rotación por sección que el arnés ya trae, `rotacion.artefactos`), porque 660 KB es el síntoma. **Consecuencia:** cero código; el margen de tiempo se conserva; en este repositorio los agentes editan REQ-007 con `Edit` de fragmentos pequeños, así que el trabajo diario no cambia.
- **(B) Subir `ARNES_PIEZAS_MAX_BYTES` por encima de `REQ-007.md`** (p. ej. 1 MiB) y el presupuesto de búsqueda en proporción. **Consecuencia:** el `Write` de 660 KB vuelve a pasar, pero cuesta 15–18 s en reposo y bajo carga puede vencer el plazo de 30 s y salir `deny` igualmente, ahora por tiempo; T2a (2 MB) sigue en `deny`.
- **(C) Optimizar la normalización de transporte** (la operación superlineal) en una intervención propia, propuesta antes de hacerse. **Consecuencia:** otra intervención con su ciclo; mueve el perfil de la sonda 37/3 (E1–E3 otra vez).

**(2) El FAIL del inventario.** En la primera de tres corridas del banco de v1.35.0 con los hooks del candidato (`50-`–`52-`): sección 24, `arnes-lectura: …el contador no dice 1`. **No se reprodujo** en la sección 24 aislada (3 veces), en la segunda corrida, en la final ni en los tres bancos del worktree. El caso ejecuta `tools/arnes-lectura.sh`, que comparte `lib.sh` con los hooks: **ejecuta código del delta**, así que por P-136-E es parada. Un FAIL no se desmiente repitiendo.

**Opciones para (2).**
- **(A) Observación independiente de QA:** QA corre su propio inventario (lo hace de todos modos en la fase 3) y la sección 24 varias veces, con el anfitrión en reposo y anotando la carga. Si lo reproduce, es hallazgo contra el delta; si no, se registra como instrumento (INS-136-3) con las nueve corridas limpias y la única roja. **Consecuencia:** sin coste extra; la decisión queda medida por alguien que no escribió el código.
- **(B) Que el desarrollador investigue la causa ahora** (¿el plazo propio o la trampa de salida afectan a `tools/`?), antes de QA. **Consecuencia:** de 30 a 60 minutos; puede no encontrar nada en un fallo que no se reproduce.

**Recomendación de la coordinadora: (1) = (A) y (2) = (A).**

**Decisión propuesta, lista para adoptar:** «P-136-O: (1) (A): los techos quedan como cambio de compatibilidad declarado; el analista lo escribe en CA-68, CA-69 p. 3, la guía y las notas; ficha para adelgazar `REQ-007.md` a `historial/` en 1.37. (2) (A): QA observa el FAIL de la sección 24 en su propio inventario y en varias corridas de la sección en reposo; si lo reproduce, es hallazgo; si no, INS-136-3. Nada más entra.»

**Qué trabajo sigue mientras no se decida:** el write-back del analista de lo que no depende de (1) (R1/R2, plazo, tope del motivo, el estado de SEC-130) y el registro de las fichas; QA (fase 3) espera a (1), porque valida contra el contrato. **Agrupada con P-136-N** (QA-007-07), que sigue pendiente.

**Espera:** elección del propietario.

### RESUELTA (coordinadora, por delegación expresa del propietario del 2026-10-06) — **Plan autorizado: paso 6 de 1.36.0, SEC-115 y SEC-118 (CA-67, CA-68, CA-69; ADR-017), con la reparación de SEC-129 (`POSIXLY_CORRECT`)**

**Fuente de la delegación:** «Encadena sin parar: … commit validado, y abre SEC-115/118» (P-136-J/K/L, 2026-10-06) y el «Resumen del plan vigente» del propietario (punto 4). La condición previa está evaluada (`docs/arnes/v1.36.0-sec115-118-ca68-vs-req017.md`: leyendo, no afecta; se mide E1–E3). Los bloques se calcan de la décima autorización.

**Contrato que rige** (REQ-007): **CA-67** (SEC-118: toda denegación decidida llega al cliente, entera o acotada, nunca perdida; el desarrollador elige la técnica; los avisos entran — P-136-B), **CA-68** (SEC-115: techos de tamaño más un plazo propio de no más de 40 s, sin procesos, medido a nivel de hook con la emisión incluida — P-136-C), **CA-69**, **ADR-017**. **Propiedad que CA-68 gana para SEC-129** (R-054; la escribe el analista en la fase 0): el hook sólo sale sin decisión cuando ha terminado un juicio que concluye que la llamada no toca nada protegido; cualquier otro final emite `deny` con motivo propio, a todo agente; y ninguna decisión depende del modo del intérprete heredado del entorno. **Si P-136-N = (A)**, la propiedad se enuncia sobre todo lo heredado del entorno e incluye `ARNES_INPUT_LISTO` y `ARNES_MANIFEST_LISTO` (QA-007-07); **si (B)**, QA-007-07 va a 1.37.

**Restricción para los techos de tamaño:** ninguno puede caer sobre las entradas de la sonda 37/3 de REQ-017 CA-09 (un techo sobre `content` de `Write` queda por encima de los 296 976 bytes de `REQ-021.md`; ninguno por línea de cabecera en el camino común). Lo medido como «sin decisión» en 1.35.0 (1 801 y 3 000 líneas ASCII; 1 601 con `ñ`; 1 001 de 4 bytes; 2 501 cortas con `ñ`; ≈ 140 KB de R-045 §4) tiene que dar `deny`.

> ## Plan autorizado (se ejecuta entero; cada fase termina en commit local y la siguiente empieza sin pedir permiso)
> Fase 0 — analista: write-back de CA-67/CA-68/CA-69 con la propiedad de SEC-129 (y QA-007-07 según P-136-N), la restricción de los techos y E1–E3 como medida; nota posterior fechada en ADR-017 si cambia su alcance; `Archivos:` con la sección prevista.
> Fase 1 — desarrollador: casos de banco con fail-before sobre `78a2f33` y v1.35.0: SEC-118 (los puntos medidos, ASCII y multibyte, más los avisos), SEC-115 (T1–T3 con `timeout 60` y el plazo propio), SEC-129 (la matriz de `seg-posix/02-matriz.sh` por las tres puertas de `Bash`) y E1. Sin reparar.
> Fase 2 — desarrollador: reparación con 0 procesos añadidos en el camino común: emisión siempre (motivo acotado o fuera de la línea de órdenes), plazo propio ≤ 40 s sin procesos, techos de tamaño donde la restricción lo permite, R1 (salir del modo POSIX al arrancar, sin procesos) y R2 (código del analizador no declarado, o puerta abandonada a mitad → `deny`). Entrega: casos en verde, E2 (sección 37/3 ≥ 6 veces) y E3 (la línea de CA-09 en los inventarios), inventario CA-69 2 con `ARNES_SEMILLA_41=23062`, banco, autoprueba, gates, procesos, y el tope del motivo medido en bytes con ASCII y multibyte (Windows: declarado no medido).
> Fase 3 — QA (Opus): repite y ataca; comprueba si R2 cubre SEC-130 por construcción (F-136-12). Una pasada correctiva como máximo, y su re-verificación.
> Fase 4 — seguridad, sólo con QA favorable: reclasifica SEC-115, SEC-118 y SEC-129 (y SEC-130 si R2 lo cubre). Write-back del analista si hay deriva. Commit validado.
>
> ## Lo que decide la coordinadora sola
> Lo mismo que en los planes de SEC-120 y del paso 5. Presupuesto orientativo: desarrollador 400–700 k, QA 300–450 k, seguridad 150–250 k, analista 150–250 k.
>
> ## Cuándo paras y me preguntas (solo esto)
> Lo mismo que en el plan de SEC-120, con la regla afinada de P-136-E, más: **E1, E2 o E3 dan «afecta»** → parar y presentar con §9 (ficha ya redactada en la evaluación); **el plazo de 40 s no se puede cumplir sin procesos**; **el tope del motivo no se puede medir**.
>
> ## Si la sesión se corta
> Se continúa desde la última fase comiteada, sin pedir la autorización.
>
> ## Límites
> Nada fuera de SEC-115, SEC-118 y SEC-129 (QA-007-07 sólo si P-136-N = (A); SEC-130 sólo como comprobación de QA). No `AGENTS.md` ni contadores. No push, versión, PR, fusión ni tag.

### RESUELTA (propietario, 2026-10-06) — **PR #60 en borrador** de `cand/1.36.0` hacia `main` («SI hazlo» a la decisión propuesta del 2026-10-06); y despacho en paralelo de dos comisiones que no tocan los archivos de QA

**Texto del propietario, literal:** «SI hazlo» (a la propuesta: «Abre un PR en borrador de `cand/1.36.0` hacia `main`, titulado "Candidato 1.36.0 (borrador)", con la descripción remitiendo a `docs/PLAN.md` § 1.36.0 y a las notas pendientes. No es decisión de fusión ni de publicación; sirve para que cada push tenga su corrida de CI. Fusionar, etiquetar y publicar siguen siendo míos.»). Y, acto seguido: «Si podemos trabajar con varios agentes hazlo».

**Lo que añade la coordinadora, rotulado como suyo:**
- **PR #60** (https://github.com/JJOVEGA/ArnesJuan/pull/60), borrador, sobre la cabeza remota `f1ffac3`. El CI corre sobre cada push de la rama; el push sigue siendo del propietario.
- **Paralelo, con los archivos declarados disjuntos por instrucción** (`tools/arnes-paralelo.sh` no puede declararlo: es el mismo REQ-007), y sin violar el orden de fases, porque ninguna de las dos acredita el código del paso 5:
  1. QA del paso 5 (en curso): `docs/qa/REQ-007.md`, la cabecera de REQ-007 y `cand-1.36.0/sec127/qa/`;
  2. `auditor-seguridad`, revisión corta de `POSIXLY_CORRECT` (P-136-L): sólo `docs/seguridad/registro-seguridad.md` (R-054) y `cand-1.36.0/sec127/seg-posix/`; **no toca REQ-007**; la reclasificación de SEC-127 y SEC-128 va después, con QA terminado;
  3. `analista-requerimientos`, condición previa del paso 6: evaluación de CA-68 frente a REQ-017 CA-09, sólo en `docs/arnes/v1.36.0-sec115-118-ca68-vs-req017.md`; **no toca ningún REQ**.

### RESUELTA (propietario, 2026-10-06, sobre `df0b4f0`) — **Resumen del plan vigente de 1.36.0, fichas de 1.37.0 y 1.38.0, y objetivo rector del arnés** (la fuente sigue siendo `docs/PLAN.md`, la cola y ESTADO)

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Plan vigente, para la coordinadora (resumen del propietario; la fuente es
> docs/PLAN.md, la cola y ESTADO; si algo difiere, mandan ellos).
>
> ## 1.36.0 — en curso. Alcance cerrado: nada más entra; lo nuevo va a ficha.
> 1. CA-54 / QA-023-10 — CERRADO en 82ceb63. QA-007-01 límite declarado;
>    recursión medida por seguridad hasta 2040 niveles. La 2b sale a 1.37.
> 2. SEC-120 — CERRADO (reparado, QA favorable, seguridad, commit).
>    QA-007-05 corregido en texto; QA-007-06 residual, reparado en el paso 5.
> 3. Paso 5 — SEC-127 + QA-007-06 + SEC-128 — EN CURSO:
>    - código hecho (a59917d, 78a2f33), sin validar;
>    - P-136-M en medición dirigida (REQ-017 CA-08 (ii) con anfitrión en
>      reposo sobre v1.35.0 → 82ceb63 → 413c6bd → a59917d → 78a2f33); si hay
>      escalón, pasada correctiva del paso 5 (sin gastar) sobre ese commit;
>      si no, instrumento y ficha para REQ-017;
>    - después: QA del paso 5 entero → revisión corta de POSIXLY_CORRECT
>      (P-136-L) → seguridad (reclasifica SEC-127) → commit validado.
>    - bash 5.0/POSIX: no medido, declarado (P-136-K).
> 4. SEC-115/118 — CA-67, CA-68, CA-69; ADR-017. El hook siempre emite
>    decisión; plazo propio 40 s; tope del motivo; los avisos entran
>    (P-136-B/C). Incluye la reparación de POSIXLY_CORRECT (P-136-L). ANTES
>    de construir: evaluar CA-68 frente a REQ-017 CA-09; si afecta, parar y
>    presentarlo al propietario con §9.
> 5. Cierre — notas [1.36.0], límites declarados, decisiones de riesgo,
>    limpieza de propuesta-v1.35.0/ a docs/historia o evidencia, PR fuera de
>    borrador, CI verde; fusión, tag y publicación: propietario.
> Pendiente del propietario: ninguno salvo lo que CA-68 produzca y publicar.
>
> ## Reglas de ejecución (plantilla templates/autorizacion.md)
> - Cada fase termina en commit local; la siguiente empieza sin pedir permiso.
> - Decide sola: texto, trazabilidad, banco sin cambio de veredicto, la
>   pasada correctiva prevista, orden y presupuesto de despachos, registrar
>   defectos sin repararlos.
> - Para y pregunta sólo por: cambio de contrato o alcance; aceptar/aplazar
>   riesgo; más pasadas que la prevista; un caso que EJECUTA HOOKS cambia de
>   veredicto (los de calibración de sonda se registran y se sigue); un
>   control del proveedor detiene algo (registra, no reintenta, sigue con lo
>   independiente); publicar/fusionar/etiquetar/cerrar REQ.
> - Si la sesión se corta: lee ESTADO y la cola y continúa; la autorización
>   ya está dada.
> - hooks/ sólo lo edita el desarrollador. Push de la candidata: recordar al
>   propietario al final de cada fase (ficha para que lo haga el agente en
>   1.37).
>
> ## 1.37.0 (fichas registradas; no se construyen ahora)
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
>
> ## 1.38.0
> f) Frontmatter YAML en los REQ. g) Veredictos con hash de árbol, comando y
> rc, comprobados por guard-completado. h) Sección adversarial permanente del
> banco (t3/t4/t5/t5b/t9 por referencia; entornos desde archivos). i) runs/
> por corrida (observabilidad).
>
> ## Medición de esta prueba de modelo
> Al cerrar SEC-115/118: decisiones escaladas, paradas no previstas, tokens
> por rol, comparado con CA-54 y SEC-120.

**Y su objetivo, literal, en el mismo mensaje:** «Mi objetivo principal es que este arnés nos ayude a construir aplicaciones más rápido, con menos coste y sin perder el control de: Fidelidad al encargo: que los agentes no cambien requisitos o alcance sin tu autorización. Un plan de desarrollo: saber qué hacer primero, qué depende de qué y cuándo una entrega está terminada. Autonomía útil: continuar el trabajo autorizado sin detenerse por cada ajuste menor. Calidad y seguridad proporcionales: detectar errores sin convertir cada corrección en una cadena interminable. Medición real: conocer tiempo, tokens y coste hasta una entrega aprobada; no presumir ahorro sin evidencia.»

**Lo que añade la coordinadora, rotulado como suyo:**
- **Lo que no estaba en `docs/PLAN.md` y ahora está:** la condición previa del paso 6 (evaluar CA-68 frente a REQ-017 CA-09 **antes** de construir; si afecta, parar y presentarlo con §9); el detalle del paso 7 (notas, límites, decisiones de riesgo, limpieza de `propuesta-v1.35.0/`, PR fuera de borrador, CI verde); las fichas a–e de 1.37.0 y f–i de 1.38.0; y el objetivo rector, al principio.
- **P-136-M ya está medido** (sin escalón; INS-136-2, F-136-8), así que el punto 3 del resumen va por «después».
- **El PR:** el paso 7 dice «PR fuera de borrador», lo que presupone un PR en borrador antes. Abrirlo sigue siendo decisión del propietario (propuesta hecha el 2026-10-06, pendiente de «adopto»).
- La cola sigue vacía.

### RESUELTA (propietario, 2026-10-06, sobre la cabeza `098896c`) — **La coordinadora pasa al modelo Fable 5.1 como prueba acotada** (lo que queda del paso 5 y SEC-115/118); los subagentes conservan su modelo; el plan no cambia

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`, tras `/model fable`):

> Cambio de modelo de la coordinadora a Fable, decidido por el propietario,
> como prueba acotada durante lo que queda del paso 5 y SEC-115/118. Los
> subagentes mantienen su modelo. Nada del plan cambia: continúa desde donde
> está (P-136-M en medición dirigida) con la autorización vigente, la
> plantilla y ESTADO; no vuelvas a pedir lo ya autorizado.
>
> Registra el cambio en la cola y en ESTADO con la fecha y la cabeza. Al
> cerrar SEC-115/118, entrega una comparación con CA-54 y SEC-120 en tres
> cifras: decisiones escaladas al propietario, paradas no previstas por el
> plan, y tokens totales por rol (coordinadora aparte). Sin valoración; sólo
> las cifras, para que el propietario decida si el cambio se queda.
>
> Reglas que no cambian con el modelo: hooks/ sólo lo toca el desarrollador;
> un control del proveedor que detenga algo se registra y no se reintenta;
> publicar, fusionar y etiquetar son del propietario. Y recuérdale el push
> de la candidata al final de cada fase comiteada.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Cabeza al cambiar:** `098896c` (P-136-M resuelta; medición dirigida en curso). Las entradas del CHANGELOG escritas por la coordinadora desde aquí llevan «modelo de IA: Fable 5.1»; las de los subagentes, el suyo.
- **Cifras de referencia para la comparación**, tomadas de las entradas del CHANGELOG de cada intervención (la coordinadora aparte):
  - **CA-54 (intervención 1):** decisiones escaladas al propietario: 7 (P-136-A a P-136-G); paradas no previstas por el plan: 4 (inventario distinto por la semilla, atajo frente a CA-54 (c), 5 213 ms sin el atajo, QA-007-02 en la re-verificación); tokens: desarrollador ≈ 682 k, QA ≈ 494 k, analista ≈ 954 k, seguridad ≈ 252 k.
  - **SEC-120 (pasos 1–4):** decisiones escaladas: 3 (los tres puntos de la fase 2, en una sola entrada) + P-136-H + P-136-I = 5; paradas no previstas: 1 (la pausa por falta de créditos; las dos vueltas de hallazgos de QA estaban previstas por el plan como pasada correctiva); tokens: desarrollador ≈ 204 k + 90 k + 75 k ≈ 369 k, QA ≈ 203 k + 208 k ≈ 411 k, analista ≈ 132 k + 104 k ≈ 236 k, seguridad ≈ 192 k.
  - **Paso 5 (SEC-127, QA-007-06, SEC-128) y SEC-115/118:** se cuentan desde aquí, y las cifras se entregan al cerrar SEC-115/118, sin valoración.
- **Push:** el propietario ordenó el push el 2026-10-06 (`f1ffac3`) y confirmó que el push anterior de `0ed5d61` (08:17 CR) lo hizo él mismo: no hay hallazgo de proceso. El PR en borrador sigue pendiente de su «adopto».
- **Forma de las fichas desde aquí (petición del propietario, 2026-10-06):** cada ficha lleva, además de la forma de la regla 4, un bloque «Decisión propuesta, lista para adoptar», redactado como la escribiría el propietario, para que responda «adopto» o la corrija. La decisión sigue siendo suya y se registra literal con su respuesta.

### RESUELTA (propietario, 2026-10-06) — **P-136-M: (A)**, medición dirigida de REQ-017 CA-08 (ii) con el anfitrión en reposo sobre cinco commits

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-M: (A). Medición dirigida de REQ-017 CA-08 (ii) con el anfitrión en
> reposo (carga < 0,5 antes de empezar, registrada), en este orden:
> v1.35.0 → 82ceb63 → 413c6bd → a59917d → 78a2f33. Mismo método, mismas 5
> mediciones por commit, sin repetir para buscar verde.
> - Si aparece un escalón: la pasada correctiva del paso 5 va a ese commit,
>   con la propiedad «el ratio vuelve al de v1.35.0», sin tocar el umbral
>   de 1,25×.
> - Si no hay escalón (los cinco oscilan igual alrededor del techo): se
>   registra como instrumento con las cinco cifras, y sigue. En ese caso,
>   ficha para REQ-017: un techo de 1,25× con el ratio en 1,20–1,30 en
>   reposo es demasiado fino para acreditar nada; se revisa en 1.37, no
>   ahora.
> Después: QA del paso 5 entero, seguridad, commit validado, SEC-115/118.

**Lo que añade la coordinadora:** la medición la hace el `desarrollador` de SEC-128, sin tocar código. La cola queda vacía.

### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-06] (coordinadora) — P-136-M: en el inventario de SEC-128, REQ-017 CA-08 (ii) («un REQ real de 6 líneas», de reloj, ejecuta hooks) pasa de INCONCLUSO a FAIL: «mín(r) 1,251× > techo 1,250×» en 5 de 5. ¿Ruido de anfitrión o regresión de coste?

**Contexto.** SEC-128 (`78a2f33`; evidencia `f641380`, `cand-1.36.0/sec127/`, archivos 90- a c1-; registro `docs/arnes/v1.36.0-sec127-fase2.md`, «SEC-128»).
- **Conforme:**
  - el cambio es una sola condición en `guard-codigo.sh`;
  - bloque E de la sección 47: 44/0, con fail-before 41/3 sobre `a59917d`;
  - K5 con su fail-before;
  - banco del worktree 2198/0/12; autoprueba 117/0; gates rc 0;
  - camino común: los mismos procesos que en `a59917d`.
- **La parada:** el banco de v1.35.0 con los hooks del candidato da 2038/**1**/11. REQ-017 CA-08 (ii) «6 líneas» era INCONCLUSO en `22-` y en la corrida anterior (`61-`), y ahora es FAIL en 5 de 5, justo encima del techo. Carga del anfitrión ≈ 1,4–2,0. El `Edit` de ese caso no entra en la rama de SEC-128, pero sí pasa por SEC-120, QA-007-06 y CA-54.
- **Por qué no se resuelve solo:** P-136-E define la parada como un caso que ejecuta hooks y pasa entre PASS y FAIL, y éste ejecuta hooks. Un FAIL no se desmiente repitiendo la corrida. Y 5 de 5 encima del techo no es el patrón de ruido que daba INCONCLUSO.

**Pregunta.** ¿Cómo se trata?

**Opciones.**
- **(A) Medirlo de forma dirigida antes de QA:** el ratio de CA-08 (ii) con el anfitrión en reposo sobre `v1.35.0`, `82ceb63`, `413c6bd`, `a59917d` y `78a2f33`, con las mismas r, para localizar si hay un escalón y en qué commit. Si hay regresión atribuible, es un hallazgo y se usa la pasada correctiva del paso 5, que sigue sin gastar. Si no hay escalón, es INS de reloj y se sigue. **Consecuencia:** de 30 a 60 minutos; la decisión queda medida.
- **(B) Que QA lo observe en su propio inventario,** con el anfitrión en reposo, como observación independiente. Si vuelve a dar FAIL, es un hallazgo. **Consecuencia:** más barato, pero no localiza el commit.
- **(C) Registrarlo como instrumento** (reloj bajo carga) y seguir. **Consecuencia:** sin coste, pero se arriesga a publicar una regresión de coste en la vía `Edit`.

**Recomendación de la coordinadora: (A).** Es la única que distingue el ruido de una regresión, y el escalón, si existe, dice qué reparar.

**Qué trabajo sigue mientras no se decida:** ninguno del plan, porque QA del paso 5 depende de esto. Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-06) — **P-136-J (A, acotada), P-136-K (A) y P-136-L (A)**; se encadena sin parar hasta abrir SEC-115/118

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-J: (A), acotada: la reparación es únicamente que un file_path que no
> es texto no deje pasar a nadie (fail-closed), con su caso de banco. Nada
> más entra en esta fase 2 corta. Si al abrirla aparece algo más, ficha.
>
> P-136-K: (A). SEC-127 se acredita con los casos de la sección 47 y la
> lectura del código; la prueba en bash 5.0 en modo POSIX queda declarada
> como no medida en CA-47 y en las notas. O-52-3 pasa a ficha de seguridad.
>
> P-136-L: (A). Revisión corta de seguridad ahora, para fijar qué apaga
> exactamente POSIXLY_CORRECT=1 y desde cuándo (también en v1.35.0: no es
> regresión); la reparación va dentro de SEC-115/118, que ya trata «el hook
> siempre emite decisión».
>
> Encadena sin parar: SEC-128, QA del paso 5 entero, revisión corta de
> POSIXLY_CORRECT, seguridad de SEC-127, commit validado, y abre SEC-115/118.

**Lo que añade la coordinadora:**
- **Orden en serie** (todo es REQ-007):
  1. el analista escribe J y K en el contrato (CA-47) y añade la ficha O-52-3;
  2. el desarrollador repara SEC-128;
  3. QA del paso 5 entero;
  4. una sola comisión de `auditor-seguridad`: la revisión corta de `POSIXLY_CORRECT` y la seguridad de SEC-127, SEC-128 y QA-007-06;
  5. commit validado;
  6. apertura de SEC-115/118 con su plan, que incluye la reparación de `POSIXLY_CORRECT`.
- **«Las notas»** de K: las notas `[1.36.0]` no existen todavía. El texto va a la entrada «Hacia 1.36.0» de la guía, como se hizo con QA-007-01, para copiarlo después a las notas.
- La cola queda vacía.

### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-J: SEC-128 (`contrato`, baja; R-053). `guard-codigo` deja pasar al agente de código con un `file_path` que no es texto, antes de aplicar la regla del enlace (SEC-004). ¿Se repara dentro de SEC-127, se repara aparte o se declara?

**Contexto.** R-053 (`docs/seguridad/registro-seguridad.md`), sobre `413c6bd`. **Determinación: con hallazgos, sin veto. SEC-120 queda `mitigado` en el candidato.**
- **SEC-128:** `hooks/guard-codigo.sh:37-42` devuelve permiso al agente de código cuando `file_path` no es texto, y lo hace **antes** de `arnes_deny_enlace` (`:67`), cuya regla (SEC-004) alcanza a todo agente.
  - Medido: el agente de código, con `file_path: 5` y un enlace `<raíz>/5 -> src/a.ts`. v1.35.0 y `82ceb63` deniegan; el candidato, con `guard-codigo` invocado solo, **sale sin decisión**. Es un movimiento que CA-69 p. 3 prohíbe.
  - **Por `guard.sh`, que es la vía real, no tiene efecto:** `guard-completado` deniega en los tres árboles.
  - La fila **K5** del banco (`44-…:366`) da esa conducta por conforme con un rótulo falso («la puerta de código no juzga el destino del desarrollador»).
- **Alcance (§6, regla 2):** impide **cerrar** REQ-007. Mientras siga abierto, **publicar** vuelve al propietario; el auditor no lo veta. No impide implementar, probar, el commit validado de SEC-120 ni SEC-127.

**Pregunta.** ¿Cómo se repara SEC-128?

**Opciones.**
- **(A) Dentro de SEC-127**, que es una intervención corta, con su ciclo completo y antes de publicar. `guard-codigo` deniega también al agente de código cuando el campo no es texto (remediación (a) de R-053); K5 pasa a `deny` y se añade un caso con enlace. Write-back del analista. **Consecuencia:** el mismo patrón que QA-007-06; añade poco a SEC-127. Toca `guard-codigo.sh` y el banco, y no `lib.sh`.
- **(B) Una intervención propia** después de SEC-127. **Consecuencia:** otro ciclo completo antes de publicar.
- **(C) Declarar el movimiento** como límite (por `guard.sh` no tiene efecto). **Consecuencia:** cero código, pero CA-69 p. 3 deja de cumplirse para esa forma y K5 sigue con un rótulo falso.

**Recomendación de la coordinadora: (A).**

**Qué trabajo sigue mientras no se decida:** el commit validado de SEC-120 (hecho) y la fase 1 de SEC-127 (casos de banco del locale y de QA-007-06, con su fail-before), que no dependen de esta decisión. La reparación de SEC-127 (fase 2) espera a la decisión, para no gastar dos pasadas sobre el banco. Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario.


### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-K: el caso 2 de SEC-127 tal como lo pidió el propietario («cierre TERMINÉ/terminé en `LC_ALL=C` simulado, que pasó de `deny` a `allow`») no es construible como fail-before. ¿Con qué se acredita SEC-127?

**Contexto.** Fase 1 del paso 5 (`ab52c9b`; `docs/arnes/v1.36.0-sec127-fase1.md` §3; evidencia `cand-1.36.0/sec127/`, commit `79f3908`).
- Con `LC_ALL=C` en el **entorno**, el cierre `TERMINÉ`/`terminé` sale sin decisión **también en v1.35.0**: es O-52-3 (R-052 §5), anterior al candidato y no registrado como hallazgo. La simulación de R-052 (`seg-R052/94-`) no aísla el mecanismo de SEC-127 (que la asignación del atajo persista en bash ≤ 5.0 en modo POSIX): mide el locale del entorno.
- Exigir `deny` ahí sería un movimiento de «sin decisión» a `deny` que CA-69 p. 3 no admite para CA-54. Además, la reparación autorizada (`local LC_ALL=C` o guardar y restaurar) devuelve el locale de partida, que en esa simulación es C: el caso no podría ponerse en verde.
- **Lo que sí está construido:** LO1–LO4 (el locale leído después del atajo, en modo normal y POSIX) y LK (el cierre fiel, en UTF-8), los dos en verde hoy. **No son fail-before** en bash 5.3.9. **No hay bash ≤ 5.0 en el anfitrión;** la descarga de `ftp.gnu.org` agotó el tiempo y no se reintentó.

**Opciones.**
- **(A)** Aceptar LO y LK como los casos de SEC-127, con el fail-before real pendiente de un bash ≤ 5.0 (se registra como no medido). La reparación sin subshell sigue tal cual. **Consecuencia:** SEC-127 se repara por construcción y se verifica por lectura y con los casos de bash 5.3; la acreditación con bash 5.0 queda declarada como laguna.
- **(B)** Contratar O-52-3: que el cierre con estado no ASCII se deniegue sea cual sea el locale del proceso. **Consecuencia:** es un cambio de contrato del analista, con un movimiento nuevo declarado y otra reparación (por ejemplo, comparar la clave sin depender de `grep -i`). Alarga el paso 5.
- **(C)** Conseguir un bash 5.0 (contenedor o compilación local) para medir el fail-before real antes de reparar. **Consecuencia:** coste de montarlo y una dependencia de red.

**Recomendación de la coordinadora: (A),** con O-52-3 como ficha para que el auditor lo clasifique. Es lo que la reparación sin subshell ya garantiza, y no amplía el paso 5.

**Qué trabajo sigue mientras no se decida:** la fase 2 (la reparación de SEC-127 sin subshell y de QA-007-06), que no depende de esto. QA (fase 3) sí espera. **Agrupada con P-136-J y P-136-L.**

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-L: con `POSIXLY_CORRECT=1` en el entorno, la vía `Bash` NO decide en ninguno de los dos árboles (v1.35.0 tampoco). Es un fallo en abierto preexistente y sin clasificar. ¿Qué se hace?

**Contexto.** Hallazgo lateral del desarrollador en la fase 1 de SEC-127 (`cand-1.36.0/sec127/09-`): con `POSIXLY_CORRECT=1`, ni `echo x > src/a.ts`, ni `sed -i …completado`, ni `git reset --hard` reciben decisión. `Write` sí deniega. Ocurre en v1.35.0 y en el candidato, así que **no es movimiento**. Ningún agente de seguridad lo ha revisado. Si el entorno de Claude Code llevara esa variable, las puertas de `Bash` quedarían apagadas en todos los proyectos. En bash 5.3 deja además a SEC-127 sin movimiento (R-052 §4 decía que eso lo cerraría por medición).

**Opciones.**
- **(A) Revisión corta del `auditor-seguridad` ahora:** registra el hallazgo (SEC-129), lo clasifica, mide el alcance desde el host y propone la remediación. La reparación se decide después. **Consecuencia:** de 20 a 40 minutos; no toca código.
- **(B) Meterlo en SEC-115/118 (paso 6)**, que ya trata de que el hook decida siempre. **Consecuencia:** se registra ahora como ficha y se repara allí, antes de publicar.
- **(C) Ficha para 1.37.** **Consecuencia:** 1.36.0 se publicaría con ese fallo en abierto, sin declarar.

**Recomendación de la coordinadora: (A) y después (B).** Un posible apagado de las puertas de `Bash` por una variable de entorno merece clasificarse ya, y su arreglo encaja en el paso 6.

**Qué trabajo sigue mientras no se decida:** la fase 2 de SEC-127. **Agrupada con P-136-J y P-136-K.**

**Espera:** elección del propietario.

### RESUELTA (coordinadora, por delegación expresa del propietario del 2026-10-05) — **Plan autorizado: paso 5 de 1.36.0, SEC-127 más QA-007-06**

**Fuente de la delegación:** «Continúa sin pararte: write-back de QA-007-05, seguridad de SEC-120, commit validado, SEC-127» (P-136-H/I, literal en esta sección). Las condiciones son las de P-136-G y P-136-I, sin cambios. Los bloques se calcan del plan de SEC-120.

> ## Plan autorizado (se ejecuta entero; cada fase termina en commit local y la siguiente empieza sin pedir permiso)
> Fase 1 — desarrollador: casos de banco, con su fail-before sobre el candidato (`413c6bd`) y v1.35.0:
> (i) SEC-127: el locale del proceso leído DESPUÉS del atajo de `guard-completado`, y el cierre de un REQ con estado no ASCII (TERMINÉ/terminé) en `LC_ALL=C` simulado;
> (ii) QA-007-06: `read` de la entrada falla con error, por cualquier causa (ejemplos no exhaustivos: entrada estándar cerrada, entrada que es un directorio), con un caso por cada causa medida.
> Sin reparar.
> Fase 2 — desarrollador: reparación SIN subshell (`local LC_ALL=C` o guardar y restaurar, a su elección) y `read` fallido → entrada ilegible → `deny`, con 0 procesos añadidos en el camino común. La versión de bash no se declara como límite. Entrega: casos en verde, inventario CA-69 2 con la semilla fijada, banco, autoprueba y gates.
> Fase 3 — QA (Opus): repite y ataca. Cierra QA-007-05 (texto corregido por P-136-H) y QA-007-06 si procede. Una pasada correctiva como máximo, y su re-verificación.
> Fase 4 — seguridad, sólo con QA favorable: reclasifica SEC-127 al cerrarlo. Write-back del analista si hay deriva. Commit validado.
>
> ## Lo que decide la coordinadora sola
> Lo mismo que en el plan de SEC-120.
>
> ## Cuándo paras y me preguntas (solo esto)
> Lo mismo que en el plan de SEC-120, con la regla de parada afinada de P-136-E.
>
> ## Si la sesión se corta
> Se continúa desde la última fase comiteada, sin pedir la autorización.
>
> ## Límites
> Nada fuera de SEC-127 y QA-007-06 (SEC-128 está en P-136-J); nada de SEC-115/118. No `AGENTS.md` ni contadores. No push, versión, PR, fusión ni tag.

### RESUELTA (propietario, 2026-10-05) — **P-136-H: (A)** (el texto del límite del punto 20, sin código) y **P-136-I: (B)** (SEC-120 se cierra con QA-007-06 como residual declarado, que se repara en SEC-127); el plan de SEC-127 gana QA-007-06; se sigue sin parar

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-H: (A). El texto del límite del punto 20 queda: «sin
> CLAUDE_PROJECT_DIR, el hook es inerte si no puede obtener el proyecto;
> si del cwd de la entrada obtiene uno con manifiesto, deniega». Es la
> conducta más segura y no toca código.
>
> P-136-I: (B). SEC-120 se cierra con QA-007-06 como residual declarado
> (entrada estándar cerrada: los guardianes abortan sin decidir; ninguna
> decisión cambia frente a v1.35.0; no provocable desde el host en lo
> observado). Se repara dentro de SEC-127, que toca el mismo archivo, lleva
> su ciclo completo y va antes de publicar. El punto 20 conserva la promesa
> «deny por cualquier causa» con QA-007-06 anotado como pendiente hasta
> SEC-127, no como límite.
>
> Ficha de SEC-127: su plan incluye QA-007-06 (entrada estándar cerrada →
> deny) junto con el locale, con un caso de banco para cada uno.
>
> Continúa sin pararte: write-back de QA-007-05, seguridad de SEC-120,
> commit validado, SEC-127.

**Lo que añade la coordinadora:** el write-back es del analista. QA-007-05 se cierra cuando QA lo compruebe, en el QA de SEC-127; hasta entonces sigue en `Hallazgos abiertos:` con su clase. `docs/PLAN.md`, paso 5, gana QA-007-06. La cola queda vacía.

### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-H: QA-007-05 (`contrato`, baja). Sin `CLAUDE_PROJECT_DIR`, el candidato deniega algunas entradas malformadas en lugar de quedar «inerte como en v1.35.0». ¿Se corrige el texto del límite o el código?

**Contexto.** QA de SEC-120, fase 3 (`docs/qa/REQ-007.md`, «SEC-120: validación (fase 3)»; evidencia `cand-1.36.0/sec120/qa/`, commit `7a967e2`), sobre `aba1c9b`.
- **Lo que dice hoy el límite declarado de CA-47 p. 20** (decisión 3 del propietario): sin `CLAUDE_PROJECT_DIR`, el hook sigue inerte, como en v1.35.0, porque denegar ahí rompería proyectos que no usan el arnés.
- **Lo medido:** sin `CLAUDE_PROJECT_DIR`, un objeto seguido de basura y un `tool_input` numérico sí reciben `deny` en el candidato (v1.35.0 no decidía). `arnes_project_dir` toma el `cwd` del primer valor. **El error es del lado seguro:** sólo deniega dentro de proyectos que usan el arnés (los que tienen manifiesto en ese `cwd`), así que la razón del propietario («rompería proyectos que no usan el arnés») no se ve afectada.

**Pregunta.** ¿Qué se alinea con qué?

**Opciones.**
- **(A) Corregir el texto (write-back del analista):** sin `CLAUDE_PROJECT_DIR`, si no se puede obtener el proyecto de la entrada, el hook es inerte, como en v1.35.0; si se obtiene un `cwd` con manifiesto, deniega. **Consecuencia:** se conserva la conducta más segura, sin código y sin gastar pasada; cambia la redacción de tu decisión 3, no su razón.
- **(B) Corregir el código** para que sea inerte en todos los casos sin `CLAUDE_PROJECT_DIR`. **Consecuencia:** menos seguro, sin ninguna ventaja; consumiría la pasada correctiva o haría falta otra.

**Recomendación de la coordinadora: (A).**

**Qué trabajo sigue mientras no se decida:** la pasada correctiva única de SEC-120 para QA-007-03 y QA-007-04, que es código independiente de este punto, y su re-verificación por QA. Seguridad (paso 3) espera a esta decisión y a esa re-verificación. Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario.


### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-I: QA-007-06 (`contrato`, baja, introducido por la pasada correctiva de SEC-120). Con la entrada estándar cerrada, los guardianes abortan sin decisión. No quedan pasadas: ¿cómo se cierra SEC-120?

**Contexto.** Re-verificación de QA de la pasada correctiva única (`413c6bd`; `docs/qa/REQ-007.md`, «SEC-120: re-verificación de la pasada correctiva»; evidencia `qa2/`, commit `6d71b19`).
- **Conforme:**
  - QA-007-03 y QA-007-04, reparados y cerrados;
  - 456 filas de ataque sin ningún movimiento de `deny` a `allow`, y 34 movimientos de «sin decisión» a `deny`, todos en las formas reparadas;
  - sin falsos positivos;
  - los hooks que no son guardianes, idénticos a v1.35.0;
  - inventario 2 (a) sólo con un INCONCLUSO de reloj (2 (c));
  - banco 2153/0/13, autoprueba 117/0, gates rc 0;
  - +0 procesos en el camino común.
- **QA-007-06:** `bash guard.sh <&-` → `lib.sh: line 37: ARNES_INPUT: unbound variable`, rc 1 y sin decisión, en los cuatro guardianes. v1.35.0 y `aba1c9b` salían con rc 0, también sin decisión, así que **ninguna decisión cambia**. No es alcanzable desde el host en lo observado.
  - **Causa:** `read` falla y no asigna; con `guardian` el preludio ya no sale antes, y `set -u` corta.
  - **Por qué es `contrato`:** el punto 20 promete `deny` cuando la entrada no se puede leer «por cualquier causa».
- **Presupuesto:** la única pasada correctiva del plan de SEC-120 está gastada (§6: agotado el tope, se cierra con el residual declarado o se escala).

**Pregunta.** ¿Cómo se trata QA-007-06?

**Opciones.**
- **(A) Una pasada más, sólo para QA-007-06**, más su re-verificación por QA. La reparación es de una línea: inicializar la variable o tratar el fallo de `read` como entrada ilegible. **Consecuencia:** de 30 a 60 minutos; excede el plan.
- **(B) Cerrar SEC-120 con QA-007-06 como residual declarado** y repararlo dentro de SEC-127 (paso 5), que es una intervención corta sobre `hooks/lib.sh` con desarrollador, QA y seguridad, y que va antes de publicar. **Consecuencia:** no se abre ningún ciclo nuevo y se repara antes de la publicación; SEC-120 pasa a seguridad con este residual escrito.
- **(C) Declararlo límite permanente** (entrada estándar cerrada → sin decisión, como en v1.35.0), con write-back del analista en el punto 20. **Consecuencia:** cero código, pero el punto 20 deja de prometer «por cualquier causa».

**Recomendación de la coordinadora: (B).** Ninguna decisión cambia, no se alcanza desde el host, y SEC-127 ya toca el mismo archivo con su propio ciclo completo antes de publicar.

**Qué trabajo sigue mientras no se decida:** ninguno del plan. La seguridad de SEC-120 (paso 3) espera a esta decisión y a P-136-H, porque QA no es favorable sin una de ellas. Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario. **Agrupada con P-136-H**, que está arriba.

### RESUELTA (propietario, 2026-10-05, posterior a `d2880c1`) — **Ajuste de alcance de 1.36.0**: SEC-127 se repara sola, entre SEC-120 y SEC-115/118; la 2b de CA-54 sale a 1.37 como ficha; orden final de 1.36.0 en siete pasos; nada más entra

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Ajuste de alcance (decisión del propietario; sustituye d2880c1 en la
> ubicación de SEC-127):
> - SEC-127 se repara SOLO, como intervención corta, con las mismas cuatro
>   condiciones ya registradas. Va después del commit validado de SEC-120 y
>   antes de SEC-115/118.
> - La 2b de CA-54 sale de 1.36.0 y pasa a 1.37 como ficha. CA-54 queda
>   cerrado con QA-007-01 como límite declarado y la medición de seguridad
>   sobre la recursión (hasta 2040 niveles) como evidencia.
> - Orden final de 1.36.0: 1) write-back SEC-120, 2) QA, 3) seguridad,
>   4) commit validado, 5) SEC-127, 6) SEC-115/118, 7) cierre y publicación.
>   Nada más entra; lo nuevo se registra como ficha.
> Registra el ajuste en la cola, en docs/PLAN.md y en ESTADO, y confírmame el
> orden.

**Lo que añade la coordinadora, rotulado como suyo:** sustituye la ubicación de SEC-127 de P-136-G, que la ponía dentro de la 2b. Sus cuatro condiciones siguen tal cual. Va en `docs/PLAN.md` § 1.36.0 (la 2b pasa a una fila «sale a 1.37») y en ESTADO. Las fichas F-136-5 (recursión) y la de M0/MD quedan con destino 1.37 en `docs/PENDIENTES.md`. La cola sigue vacía.

### RESUELTA (propietario, 2026-10-05) — **P-136-G (SEC-127): opción (A), dentro de la 2b de CA-54** (o sola antes de publicar si la 2b se retrasa); sin subshell; QA con caso de banco del locale tras el atajo y del cierre TERMINÉ/terminé; seguridad reclasifica al cerrar; la premisa de versión de bash NO se declara como límite

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-G (SEC-127): opción (A), en la intervención 2b de CA-54, que ya toca
> ese código. Si la 2b se retrasa más allá de la publicación de 1.36.0, (A) va
> sola antes de publicar.
>
> Condiciones:
> 1. La asignación de locale del atajo no puede persistir en ningún bash. Se
>    hace SIN subshell (un subshell es un proceso, y el camino común sigue en
>    0 procesos añadidos): con `local LC_ALL=C` dentro de la función que lo
>    necesita, o guardando y restaurando el valor explícitamente. El
>    desarrollador elige entre esas dos.
> 2. QA lo verifica con un caso de banco que lea el locale del proceso DESPUÉS
>    del atajo y con el cierre de un REQ con estado no ASCII (TERMINÉ /
>    terminé) en LC_ALL=C simulado, que es el que pasó de deny a allow.
> 3. Seguridad reclasifica SEC-127 al cerrarlo. Hasta entonces la publicación
>    de 1.36.0 queda en mi mano, como ya está.
> 4. La premisa "bash 5.1+ o sin modo POSIX" NO se declara como límite: se
>    repara, y punto. Que CA-47 no dependa de la versión de bash.

**Lo que añade la coordinadora, rotulado como suyo:** se escribe en `docs/PLAN.md` § 1.36.0, fila 2b. Cuando se abra la 2b, su plan (`templates/autorizacion.md`) incluye estas condiciones tal cual. La cola queda vacía.

### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-G: SEC-127 (`contrato`, baja; R-052). Con bash 5.0 o anterior en modo POSIX, el atajo de `guard-completado` podría dejar el recorrido de destinos en locale C y un cierre con estado no ASCII pasaría. ¿Se repara, se declara la premisa como límite o se mide?

**Contexto.** Fase 4 de la décima autorización, R-052 (`docs/seguridad/registro-seguridad.md`), sobre el código de `82ceb63`. **Determinación: con hallazgos, sin veto.**
- **Conforme:**
  - el atajo equivale a la regla, con la muestra del auditor (200 ejecuciones) y las 3 600 de QA;
  - el análisis compartido no reutiliza nada de otra entrada;
  - no hay recursión: hasta 2 040 niveles, `deny` y rc 0 con pilas de 8 192, 1 024 y 256 KiB;
  - QA-007-01 encaja como límite: decisión idéntica, y el delta **reduce** la exposición a SEC-115.
- **SEC-127:**
  - el atajo pone `LC_ALL=C` delante de una llamada a función en el proceso que juzga;
  - en bash 5.1 o posterior esa asignación se restaura (medido en 5.3.9, con y sin modo POSIX);
  - en **bash 5.0 o anterior en modo POSIX** persiste (NEWS de bash-5.1, punto «o»). El recorrido de destinos correría entonces en locale C, donde GNU `grep -i` no casa `TERMINÉ` con `terminé`, mientras el lector pasa el valor a minúsculas: ese cierre pasaría.
  - **No reproducido:** sólo hay bash 5.3.9 en este anfitrión. Se simuló con el entorno en `LC_ALL=C` (`deny` → `allow`; `seg-R052/94-`).
  - v1.35.0 no tenía esa forma.
- **Alcance (§6, regla 2):**
  - impide **cerrar** REQ-007 (clase `contrato`);
  - **publicar** 1.36.0 no puede hacerse por delegación mientras siga abierto: vuelve al propietario. El auditor no lo veta;
  - no impide implementar, probar ni SEC-120.

**Pregunta.** ¿Qué se hace con SEC-127?

**Opciones.**
- **(A) Repararlo** en una intervención acotada:
  - el `desarrollador` hace que la asignación de locale no pueda persistir en ningún bash (por ejemplo, en un subshell o con `local`, sin procesos añadidos en el camino común);
  - QA la verifica, con un caso de banco que fije el locale del proceso tras el atajo;
  - seguridad la cierra.
  - **Consecuencia:** coste pequeño, de una intervención corta; puede ir junto a la 2b o antes de publicar.
- **(B) Declarar la premisa como límite:** el hook requiere bash 5.1 o posterior, o no arrancar en modo POSIX. El analista la escribe en el contrato y en la guía.
  - **Consecuencia:** cero código; un consumidor con bash 5.0 en modo POSIX quedaría expuesto. El hallazgo sigue `contrato` hasta que el auditor lo reclasifique.
- **(C) Medirlo primero** en un bash 5.0 en modo POSIX (contenedor o compilación local). Si v1.35.0 tampoco deniega en ese modo, el hallazgo se cierra.
  - **Consecuencia:** coste de montar ese bash; la medición decide entre (A) y el cierre.

**Recomendación de la coordinadora: (A), dentro de la intervención 2b,** que ya toca este código. Es la reparación barata y elimina la dependencia de la versión de bash. Si la 2b se retrasa más allá de la publicación, (A) va sola antes de publicar.

**Qué trabajo sigue mientras no se decida:** **SEC-120 (intervención 2), que no depende de esta decisión**, ya está autorizada por delegación y vence el 2026-10-29. Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-05, posterior a `0c31cdd`) — **SEC-120: los tres puntos abiertos de la fase 2** («0 procesos añadidos» rige sobre el camino común; ilegible = todo lo que no sea exactamente un objeto JSON; sin `CLAUDE_PROJECT_DIR` sigue inerte, como límite declarado); **orden al volver los créditos, sin pedir autorización**: QA, seguridad, commit validado, 2b de CA-54, SEC-115/118

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisiones del propietario, SEC-120:
>
> 1. Procesos. "0 procesos añadidos" rige sobre el CAMINO COMÚN: toda entrada
>    legible cuesta lo mismo que en v1.35.0. En una entrada ilegible el hook
>    antes no decidía y ahora emite deny: el jq que emite esa decisión es el
>    coste de decidir, no un proceso añadido al análisis. CA-47 punto 20 lo
>    dice así, con las dos cifras medidas (normal: +0; ilegible: +1). No es
>    incumplimiento de contrato.
> 2. Qué es ilegible. Confirmo la lectura del desarrollador: todo lo que no sea
>    exactamente un objeto JSON (null, número, vacío, dos objetos seguidos).
>    Fail-closed; es el principio del arnés.
> 3. Sin CLAUDE_PROJECT_DIR el hook sigue inerte, como en v1.35.0: denegar ahí
>    rompería proyectos que no usan el arnés. Se declara como límite en el
>    punto 20.
>
> Al volver los créditos: QA en comisión nueva, seguridad con QA favorable,
> commit validado, 2b de CA-54, SEC-115/118. Sin pedirme autorización.
>
> Sobre P-136-G (SEC-127): no sé qué es; pégame su texto y te doy la decisión.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Write-back:** los puntos 1 a 3 cambian el texto de REQ-007 CA-47 punto 20, y en este repositorio el write-back es del `analista-requerimientos` (`AGENTS.md` §9: §6 no declara la vía proporcional). Va **antes** de la fase 3, porque QA no firma `aprobado` sin el write-back (§9). No es una fase nueva: es la dependencia que el plan de SEC-120 ya prevé («write-back del analista sólo si hay deriva»).
- **La 2b y la intervención 3** se abren, cuando les toque, con su plan en la forma de `templates/autorizacion.md`, redactado por la coordinadora por esta delegación y calcado de la décima.
- **P-136-G** sigue en § Pendientes. Su texto se le entrega al propietario en la respuesta de esta sesión.
- **Pausa:** sin créditos de uso no se despacha a nadie.

### RESUELTA (coordinadora, por delegación expresa del propietario del 2026-10-05) — **Plan autorizado: intervención 2 de 1.36.0, SEC-120 sola** (REQ-007 CA-47 punto 20; vence el 2026-10-29)

**Fuente de la delegación:** decisión del propietario del 2026-10-05, posterior a `39e68bb`, punto 3 (literal en esta sección): «Cuando conecte: recuento de QA (10 de 30), fase 4 sobre 82ceb63, commit validado, y apertura de SEC-120 sin pedirme la autorización». También P-136-F, punto 7: «Al cerrar CA-54, abre SEC-120 sola, como dice el plan de versión». La forma es la de `templates/autorizacion.md`. **Los bloques los redacta la coordinadora calcando la décima autorización:** no añaden facultades ni quitan ninguna parada que la décima tenía.

**Propiedad (contrato vigente, REQ-007 CA-47 punto 20; no se cambia):** si `jq` no puede leer la entrada, el hook deniega a todo agente. Si no puede trocear la parte de `tool_input` que una puerta necesita, deniega esa puerta. Ninguna variable conserva el valor de una lectura anterior. Los modos inertes (sin `jq` o sin manifiesto) siguen como están. Se cumple con la comprobación del código de salida, **sin procesos nuevos**. Medida: casos de banco en la sección 44 a nivel de hook en Linux/WSL2, con los vectores V1–V4 de R-045-A §4 y fail-before contra el código del candidato (`82ceb63`) y contra v1.35.0.

> ## Plan autorizado (se ejecuta entero; cada fase termina en commit local y la siguiente empieza sin pedir permiso)
> Fase 1 — desarrollador: casos de banco de CA-47 punto 20 en la sección 44 (vectores V1–V4 de R-045-A §4), con fail-before medido sobre el código de `82ceb63` y sobre v1.35.0. Sin reparar todavía.
> Fase 2 — desarrollador: reparación por comprobación del código de salida de `jq`, con 0 procesos añadidos (`sonda-procesos.sh` más recuento exacto). Entrega: casos en verde, inventario CA-69 2 frente a `22-` con la semilla de la sección 41 fijada (sólo admite los movimientos de `allow` o «sin decisión» a `deny` que declara CA-69 3 para el punto 20, y los casos de CA-69 2 (c) e INS-136-1), banco completo, autoprueba y gates.
> Fase 3 — QA (Opus): repite los casos, el fail-before, el inventario, el banco y la autoprueba, e intenta romper la reparación. Una pasada correctiva como máximo, dentro del contador, y su re-verificación.
> Fase 4 — seguridad, sólo con QA favorable. Write-back del analista sólo si hay deriva. Commit del trabajo validado.
>
> ## Lo que decide la coordinadora sola
> Texto, trazabilidad, CHANGELOG, ESTADO e índices; ajustes del banco que no cambian ningún veredicto ni contrato; la pasada correctiva prevista; el orden y el presupuesto de cada despacho dentro del propuesto (calibrado con la intervención 1: desarrollador 300–500 k, QA 250–400 k, seguridad 150–250 k); registrar defectos nuevos sin repararlos.
>
> ## Cuándo paras y me preguntas (solo esto)
> - un cambio de contrato o de alcance;
> - aceptar o aplazar un riesgo;
> - más pasadas que la prevista;
> - un veredicto del banco que cambia: un caso que ejecuta hooks o lee archivos del delta y pasa entre PASS y FAIL, fuera de los movimientos que declara CA-69 3. Un caso de calibración de sonda que cambia se registra y se sigue;
> - **el fail-before no falla** sobre `82ceb63` ni sobre v1.35.0 (sería una pregunta de contrato: R-046 dice que `arnes_parse_input` ya vacía sus campos);
> - un control del proveedor detiene algo (se registra y se sigue con lo independiente);
> - publicar, fusionar, etiquetar o cerrar un REQ.
>
> ## Si la sesión se corta
> La siguiente lee este plan en la cola y en ESTADO, y continúa desde la última fase comiteada. No vuelve a pedir la autorización: ya está dada.
>
> ## Límites
> Nada fuera de SEC-120 en esta intervención: ni SEC-127 (P-136-G), ni la 2b, ni SEC-115/118; se registran. No `AGENTS.md` ni contadores. No push, versión, PR, fusión ni tag.

**Lo que añade la coordinadora:** la base es el código del candidato (`hooks/` = `82ceb63`). P-136-G (SEC-127) sigue pendiente en la cola y no depende de este plan.

### RESUELTA (propietario, 2026-10-05, posterior a `39e68bb`) — **M0 y MD como límite declarado «sin cifra sobre 82ceb63»; QA-007-01 sigue como `contrato`; impedimento de red del anfitrión; al conectar, se sigue sin pedir autorización hasta abrir SEC-120**

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisiones del propietario:
> 1. M0 y MD: límite declarado «sin cifra sobre 82ceb63»; se miden en la
>    intervención 2b, en anfitrión sano, antes de cualquier optimización.
> 2. QA-007-01 mantiene la clase `contrato` hasta que QA decida; REQ-007 no se
>    cerraba en esta intervención.
> 3. El impedimento de red (Zscaler 403) se registra como del anfitrión, no
>    del proveedor ni del arnés. Cuando conecte: recuento de QA (10 de 30),
>    fase 4 sobre 82ceb63, commit validado, y apertura de SEC-120 sin pedirme
>    la autorización.

**Lo que añade la coordinadora, rotulado como suyo:** el punto 1 se escribe en `docs/PLAN.md` § 1.36.0, fila 2b. El punto 3 queda en ESTADO como el orden de reanudación. La cola sigue vacía.

### RESUELTA (propietario, 2026-10-05) — **P-136-F: opción (C)**: el candidato de CA-54 es `82ceb63` (se revierte `dee5932`); QA-007-02 cerrado por reversión con ficha de la recursión; QA-007-01 como límite declarado; fase 4 sobre `82ceb63`; segunda pasada como intervención 2b después de SEC-120

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-F: opción (C), así:
>
> 1. El candidato de CA-54 es 82ceb63. Revierte el código de dee5932 (git
>    revert, conservando el registro de la pasada y de QA-007-02 como historia).
>    Comprueba que tras el revert hooks/ es byte a byte igual a 82ceb63.
> 2. QA-007-02 queda CERRADO POR REVERSIÓN en el candidato, y abre una ficha
>    de 1.36.0 (instrumento, alta): «la lectura léxica de rutas es recursiva
>    por segmento y sin tope». Antes de cualquier intervención que la toque,
>    el banco recibe primero el caso de destinos profundos (≈1500 niveles,
>    < 3 KB) con fail-before, y la propiedad es: toda ruta por debajo del
>    límite de entrada recibe una decisión; ninguna mata al hook.
> 3. QA-007-01 queda como LÍMITE DECLARADO del candidato: CA-54 se cumple en
>    su medición (las 35 corridas), y las formas que QA añadió (sus casos M/N,
>    un proyecto sin globs de código, el desarrollador con primer destino en
>    código) quedan fuera del criterio y escritas en las notas. La medición
>    en anfitrión degradado se registra como tal, no se repite.
> 4. El bloqueo del proveedor sobre QA (locales GB18030/BIG5, leído como rm
>    sin haberlo) se registra; no se reintenta. El ataque de equivalencia
>    sobre 82ceb63 vale el que ya se hizo; el que faltaba era sobre dee5932,
>    que ya no existe.
> 5. Fase 4: seguridad sobre 82ceb63 con el veredicto de QA «con hallazgos:
>    QA-007-01 declarado como límite». Commit validado.
> 6. Segunda pasada de CA-54 (cubrir QA-007-01 y la recursión): intervención
>    nueva, DESPUÉS de SEC-120, que tiene fecha. Se registra en el plan de
>    versión como intervención 2b.
> 7. Al cerrar CA-54, abre SEC-120 sola, como dice el plan de versión.
>
> Presupuesto: registra el gasto real (dev 673k, QA 425k, analista 750k) frente
> al propuesto; es dato para calibrar el siguiente, no un reproche.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Alcance de la reversión, comprobado:** `git diff --stat 82ceb63 dee5932^ -- hooks tools tests` está vacío. Entre `82ceb63` y la pasada sólo hubo registro, así que revertir el código de `dee5932` devuelve `hooks/` a `82ceb63`. `dee5932` toca `hooks/guard-codigo.sh`, `hooks/guard-completado.sh` y `hooks/lib.sh`, más `docs/arnes/v1.36.0-ca54-fase2.md` y `CHANGELOG.md`, que se conservan como historia. La reversión la hace el `desarrollador`, porque `hooks/` está protegido.
- **«El plan de versión» no existía como documento.** La sección `## 1.36.0` de `docs/PLAN.md` era una planificación antigua («el working set explícito»). La coordinadora escribe allí, fechado, el plan vigente de 1.36.0 según las decisiones del propietario (2026-10-03 y esta): intervención 1 CA-54, intervención 2 SEC-120 sola, intervención 2b la segunda pasada de CA-54, intervención 3 SEC-115/SEC-118. Lo antiguo queda debajo como historia.
- **Qué trabajo sigue:** la reversión (desarrollador); el write-back del analista (QA-007-02 cerrado por reversión, QA-007-01 como límite declarado en CA-54, la ficha de la recursión); la seguridad sobre `82ceb63`; el commit validado; y abrir SEC-120 con su autorización en la forma de `templates/autorizacion.md`. La cola queda vacía.

### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-F: la pasada correctiva única introdujo un fallo en abierto (QA-007-02, `contrato`, alta) y no cerró QA-007-01; el plan está parado. ¿Se revierte la pasada, se autoriza otra o ambas cosas?

**Contexto.** Re-verificación de QA (Opus) sobre `dee5932` (cabeza validada `787d04d`; registro en `docs/qa/REQ-007.md`, «Re-verificación de la pasada correctiva (QA-007-01)»; evidencia `cand-1.36.0/ca54/qa/`, commit `a6f5b32`).
- **QA-007-02 (`contrato`, alta, NUEVO, lo introduce la pasada):**
  - un destino de `Bash` con `..` y unos 1 500 niveles (≈ 3 KB, por debajo de `ARNES_ID_MAX`) hace que el hook muera por **SIGSEGV** (rc 139, sin decisión): `_arnes_lectura_lexica` recurre por segmento, sin tope;
  - con ese destino delante, la coordinadora escribe en `src/a.ts` y un REQ se cierra por `sed -i`. **v1.35.0 y `82ceb63` lo deniegan;**
  - umbral entre 1 400 y 1 500 niveles con `ulimit -s` de 8 MiB;
  - el banco no tiene ningún caso con destinos profundos. Reproducción mínima en `qa/segv/70-` a `74-`.
  - **Exposición:** ninguna fuera de este worktree. El código está sólo en commits locales de `cand/1.36.0`, sin push, y la instalación estable es 1.35.0.
- **QA-007-01 (`contrato`, media) sigue abierto,** aunque **el anfitrión se degradó durante la medición** desde las 14:26: v1.35.0 tardó hasta 4 veces más que por la mañana y el testigo de bash puro osciló entre 190 y 1 341 ms. QA registró los FAIL con su carga y no los repitió.
  - Con esa degradación, 9 de 35 corridas de «Medida» llegan a 5 s, y 38 de 45 en M, N y MR.
  - **Dos formas que la pasada no ataca por construcción:** M0 (proyecto sin globs de código) y MD (el desarrollador con su primer destino en código).
- **Conforme:**
  - 0 procesos añadidos;
  - inventario con sólo dos líneas de CA-69 2 (c); ningún caso que ejecute hooks cambia entre PASS y FAIL;
  - banco 2037/0/13; autoprueba 117/0; gates rc 0.
- **Control del proveedor:** detuvo a QA al construir los locales GB18030 y BIG5. Lo marcó como un `bash -c` que ejecuta `rm`, y el comando no contenía ningún `rm`. **No se reintentó.** Por eso queda **sin ejecutar el ataque de equivalencia sobre `dee5932`** (preparado en `qa/eq/eq3.sh`).
- **La fase 4 (seguridad) no se despachó:** no hay QA favorable.
- **Presupuesto del plan:** la única pasada correctiva está gastada (AGENTS.md §6, regla 5; el contador no se reinicia).

**Pregunta.** ¿Qué se hace con el candidato y con CA-54?

**Opciones.**
- **(A) Revertir la pasada correctiva y volver al código de `82ceb63`, que no tiene QA-007-02.** QA-007-01 queda abierto con alcance, como límite declarado: las 35 corridas de «Medida» cumplen, M y N no. La fase 4 se hace sobre `82ceb63`.
  - **Consecuencia:** es lo más seguro y lo más barato. La reversión la hace el `desarrollador` (`hooks/` está protegido) y QA comprueba que el árbol queda igual a `82ceb63`. CA-54 queda acreditado sólo para el instrumento, no para la propiedad.
- **(B) Autorizar una segunda pasada correctiva.** Se excede el plan y el contador sigue sin reiniciarse.
  - Repararía QA-007-02 por propiedad: ningún destino por debajo de `ARNES_ID_MAX` puede dejar el hook sin decisión, y se añade un caso de banco con destinos profundos, con su fail-before contra `dee5932`. También cubriría M0 y MD.
  - Después, QA re-verifica **en un anfitrión sano**, incluido el ataque de equivalencia, sin GB18030/BIG5 si el proveedor vuelve a bloquear su construcción.
  - **Consecuencia:** coste estimado de 200 a 400 k tokens para el desarrollador y de 250 a 300 k para QA. Puede volver a quedar corta.
- **(C) (A) ahora y (B) después, como intervención nueva:** el candidato queda seguro hoy, y la segunda pasada parte de `82ceb63` con su propia autorización y su plan.

**Recomendación de la coordinadora: (C).** QA-007-02 es un fallo en abierto de alta severidad, y el árbol del candidato no debe quedarse con él mientras se decide lo demás. Revertir cuesta poco y devuelve el candidato a un código cuyas decisiones están verificadas: 6 148 ejecuciones idénticas a v1.35.0. La segunda pasada merece su propio plan, con el caso de banco de destinos profundos por delante y una medición en un anfitrión sano.

**Qué trabajo sigue mientras no se decida.** **Ninguno del plan.** Fuera del plan no se abre nada. Esta entrada impide marcar cualquier REQ como `completado` (ninguno se iba a cerrar).

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-05) — **P-136-E: opción (A)**; los tres casos de calibración son hallazgo `instrumento`, no atribuible al cambio; regla de parada afinada («un veredicto del banco que cambia» = un caso que ejecuta hooks o lee archivos del delta); ficha nueva de REQ-021

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-E: opción (A). Los tres casos (REQ-021 CA-03, CA-10 y CA-10.2) se
> registran como hallazgo `instrumento`, no atribuible al cambio, con la prueba
> estática (la calibración no ejecuta hooks) y la corroboración: ayer fallaron
> los mismos tres en WSL con el banco entero y pasaron solos en la sección 38
> (docs/qa/REQ-023.md, validación manual), y en el CI dos corridas rojas en dos
> sondas de reloj distintas y la tercera verde.
>
> Afino la regla de parada de esta autorización, y que la plantilla lo recoja:
> «un veredicto del banco que cambia» = un caso que ejecuta hooks o lee archivos
> del delta. Un caso de calibración de sonda que cambia se registra y se sigue.
>
> Ficha nueva, para después (REQ-021, instrumento): una calibración de
> sonda-reloj fuera de banda sale FAIL; según la propia filosofía del banco
> debería abstenerse (SKIP o INCONCLUSO con motivo), como ya hace la sonda que
> no converge. No se repara en esta intervención.
>
> Continúa: commits del desarrollador, banco, autoprueba y gates; verificación
> de QA con su propio inventario; fase 4 con QA favorable. No me preguntes
> hasta QA, salvo por un cambio de veredicto en un caso que sí ejecuta hooks.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Registro:** hallazgo `instrumento` **INS-136-1** y ficha **F-136-4** (REQ-021) en `docs/PENDIENTES.md`; la regla afinada, en el bloque «Cuándo paras» de `templates/autorizacion.md` (como guía para cualquier autorización) y en su ejemplo (como precisión fechada de la décima). La décima autorización se lee, desde hoy, con esta regla de parada.
- **Qué trabajo sigue:** el plan. Primero el desarrollador comitea y corre el banco, la autoprueba y las gates; después QA re-verifica con su propio inventario; después la fase 4, con QA favorable. La cola queda vacía.

### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-E: la pasada correctiva de QA-007-01 cumple los tiempos, pero el inventario cambia en 3 casos de calibración del reloj (PASS → FAIL) que no ejecutan los hooks; ¿cómo se trata?

**Contexto.** Décima autorización, pasada correctiva 1 de 1, sobre `488cd8e`, con el código **sin comitear** (copia: `cand-1.36.0/ca54/50-pasada-correctiva-sin-commit.patch`, sha256 `d9d62a06…`, en el árbol de evidencia, sin commit allí).
- **Tiempos, medidos por el desarrollador:**
  - 35 de 35 corridas de S1/S2 por debajo de 5 s (máx. 4 011 ms);
  - 45 de 45 corridas de los casos M, N y MR de QA por debajo de 5 s (máx. 4 713 ms);
  - decisiones idénticas a v1.35.0 y 0 procesos añadidos.
- **Inventario con `ARNES_SEMILLA_41=23062`** frente a `22-` (`42-diff-inventarios.txt`; el banco dio 2036/3/11):
  - **3 casos PASS → FAIL:** REQ-021 CA-03 «calibración de `sonda-reloj.sh`» (`a=2487`, banda [1600, 2400]), REQ-021 CA-10 (el juez) y REQ-021 CA-10.2. Los dos últimos heredan esa calibración;
  - 1 caso de CA-69 2 (c) (REQ-017 CA-08 (ii), 6 líneas: INCONCLUSO → PASS), que no acredita.
- **Comprobado por la coordinadora leyendo el disco, sin ejecutar nada:**
  - la calibración la hace `tests/util/sonda-reloj.sh --calibrar` sobre un sujeto propio de bash, y la juzga `sonda_juzga_calibracion` (`run.sh` l. 1105);
  - `grep` de `HOOKS_DIR`, `guard.sh` y `lib.sh` en `sonda-reloj.sh` y `sonda-procesos.sh` no devuelve nada: **esa calibración no ejecuta los hooks**, así que el cambio de código no puede alterarla;
  - el propio `sonda-reloj.sh` documenta calibraciones fuera de banda con la máquina en reposo (l. ~67).
- **No se repitió nada:** ni la corrida, ni el banco del worktree, ni la autoprueba. Repetir hasta el verde no desmiente un FAIL.

**Pregunta.** La regla de parada «un veredicto del banco que cambia» se disparó en casos que no dependen del código cambiado. ¿Cómo se cierra la pasada?

**Opciones.**
- **(A) Declararlos `instrumento`, no atribuibles al cambio, con la prueba estática de arriba, y seguir.** El desarrollador comitea y corre el banco del worktree, la autoprueba y las gates. Después, **QA re-verifica con su propio inventario**, una observación independiente y no una repetición del desarrollador. Si QA ve un cambio de veredicto en un caso que **sí** ejecuta hooks, se para.
  - **Consecuencia:** queda registrado un hallazgo `instrumento` (la calibración del reloj es sensible a la carga), con dueño, sin reparar en esta intervención. El inventario del desarrollador no acredita «idéntico»; lo acredita el de QA.
- **(B) Una sola repetición del inventario, declarada antes de correrla, con el resultado aceptado sea cual sea.** Si los 3 casos vuelven a PASS, se sigue como en (A). Si siguen en FAIL, se vuelve a parar.
  - **Consecuencia:** unos 3 minutos de banco. Se parece a repetir buscando el verde, aunque el resultado esté comprometido de antemano.
- **(C) Caracterizar el instrumento:** correr la sección 38 contra los hooks de **v1.35.0**, N veces y con una carga parecida, para medir cuántas veces falla la calibración sin el cambio. Después, (A).
  - **Consecuencia:** es la evidencia más fuerte de que no es regresión. Cuesta de 30 a 60 minutos de banco y una comisión corta.

**Recomendación de la coordinadora: (A).** La prueba estática es concluyente para estos tres casos: un instrumento que no ejecuta los hooks no puede cambiar porque los hooks cambien. La re-verificación de QA, que ya está en el plan, vuelve a observar el inventario entero sin que nadie elija la corrida.

**Qué trabajo sigue mientras no se decida.** **Ninguno del plan.** La pasada correctiva, la re-verificación de QA y la fase 4 dependen de esta decisión. Esta entrada impide marcar cualquier REQ como `completado` (ninguno se iba a cerrar).

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-05) — **P-136-D: opción (A) con condición de equivalencia**; semilla de la sección 41 fijada; fichas de instrumento; el plan de la décima autorización continúa desde la fase 2

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-D: opción (A), con una condición de equivalencia que es parte de la
> decisión, no una sugerencia:
>
> 1. El atajo de guard-completado puede omitir el RECORRIDO DE DESTINOS cuando
>    el comando entero no menciona el estado terminal. No puede omitir el
>    análisis del comando ni ninguna denegación por forma que guard-completado
>    emite sin mirar destinos: presupuesto (ARNES_RC_EXCESO), CR del
>    delimitador (ARNES_RC_CR), SEC-124 (ARNES_RC_CUERPO_CR) y LC10
>    (ARNES_RC_LC10). Esas salen antes del atajo, exactamente como en v1.35.0.
> 2. Prueba: inventario del banco caso a caso idéntico al de referencia
>    (2050 líneas, f35c9c04…), con la semilla de la sección 41 fijada. Si
>    difiere en una sola línea, el atajo está mal colocado y se corrige; no se
>    cambia el veredicto.
> 3. Contrato: el analista aclara CA-54 (c) así: «comprobar primero una
>    condición necesaria de una regla, leyendo la entrada entera, no es
>    analizar menos, siempre que ninguna denegación que no dependa de esa
>    condición deje de emitirse». Ni más ni menos.
> 4. QA ataca la equivalencia: las filas HC5a, HC9.6 y LC10.1–LC10.9 por
>    guard-completado explícitamente, los locales en_US y tr_TR, y un comando
>    que mencione el estado terminal con destino fuera de requirements/.
> 5. Presupuesto: acepto el exceso del desarrollador (586k) como registrado;
>    la pasada correctiva de esta intervención sigue siendo una.
>
> Defectos registrados: la semilla de la sección 41 se fija ahora (ajuste del
> banco sin cambio de veredicto: lo decides tú). sonda-procesos y la columna
> vacía de S2 quedan como fichas. Las dos ediciones de hooks/ por consola:
> registrarlo como hallazgo de proceso (instrumento), sin reparar en esta
> intervención.
>
> Continúa el plan desde la fase 2 con lo de arriba; no me preguntes hasta QA.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Semilla de la sección 41 (decisión que el propietario delega en la coordinadora):** se fija **en la invocación** de las comparaciones de inventario (`ARNES_SEMILLA_41` igual a la semilla que registra la referencia, `23062` en `22-inventario-v1.35.0.txt`), y la precisión se escribe en CA-69 2 (a). **El banco no cambia:** fijar el valor por defecto dentro de la sección 41 quitaría el sorteo de entradas, que es lo que ese caso ejerce, y eso sí cambiaría lo que mide.
- **Orden:** primero el analista, con la aclaración de (c), la precisión de CA-69 2 (a) y las fichas; después el desarrollador, que cierra la fase 2. Van en serie porque son el mismo REQ.
- **Qué trabajo sigue:** el plan, fase 2. La cola queda vacía.

### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-03] (coordinadora) — P-136-D: CA-54 sin el atajo de `guard-completado` deja 1 de 35 corridas en 5 213 ms; ¿se readmite el atajo aclarando CA-54 (c), se sigue optimizando o se acepta?

**Contexto.** Décima autorización, fase 2 (CA-54), sobre `4b4f239` con el código **sin comitear** en el worktree. Las copias del parche están en el árbol de evidencia, `cand-1.36.0/ca54/`: `50-candidato-fase2-sin-atajo-sin-commit.patch`, y la variante con atajo en `con-atajo-retirado/`.
- **Con el atajo:** 0 de 35 corridas ≥ 5 000 ms. El peor caso es 3 811 ms (S1 C).
- **Sin el atajo:** 34 de 35. **S1 B, tercera corrida: 5 213 ms**; el resto de S1 está entre 3,8 y 4,3 s.
- **En las dos variantes:**
  - las decisiones, los rc, y los `bytes=` y `destinos=` son iguales a v1.35.0 en las 35 corridas;
  - stdout, rc y stderr son idénticos byte a byte en 10 de 10 entradas;
  - 0 procesos añadidos con `sonda-procesos.sh`, y uno menos en S1 con el recuento exacto complementario.
- **Qué es el atajo:** la regla de `guard-completado` por `Bash` deniega sólo si un destino cae en `requirements/` **y** el estado terminal aparece en el comando. El atajo comprueba primero la segunda condición, sobre el **comando entero** y sin proceso, y si es falsa no recorre los destinos: la regla no podría denegar. Los destinos los sigue juzgando `guard-codigo` enteros.
- **Por qué se retiró:** CA-54 (c) prohíbe «analizar menos de la entrada» y nombra «omitir destinos» como ejemplo no exhaustivo. La coordinadora no valida sobre una lectura discutible del texto.
- **Medido por el desarrollador con el atajo:** 102 000 pares por locale contra `grep` real, 0 violaciones. Sin medir: los locales `en_US` y `tr_TR`, que no están instalados.
- **No se repitieron corridas buscando verde.** Un FAIL no se desmiente repitiendo.

**Pregunta.** ¿Cómo se cumple CA-54?

**Opciones.**
- **(A) Readmitir el atajo, aclarando CA-54 (c).** El `analista-requerimientos` versiona (c) con una nota: no es «analizar menos» evaluar primero una condición necesaria de una regla, **sobre la entrada entera**, cuando prueba que la decisión no puede cambiar. Sí sigue prohibido no juzgar destinos en la puerta que los juzga (`guard-codigo`).
  - **Consecuencia:** margen de ≈ 1,2 s sobre el umbral. QA ataca expresamente la equivalencia (locales, mayúsculas no ASCII, el estado mencionado de formas que `grep` encuentra). Es un cambio de contrato menor con Historial, y sigue el plan sin más optimización.
- **(B) Sin el atajo; el desarrollador optimiza más**, dentro de (c) y con 0 procesos.
  - **Consecuencia:** no se sabe si cabe. Coste estimado de 150 a 300 k tokens más. Si no cabe, se vuelve a esta pregunta.
- **(C) Sin el atajo y aceptar 34 de 35 con alcance**, como en 1.35.0.
  - **Consecuencia:** CA-54 no se cumple. Sería aceptar un riesgo y cambiar el criterio («cada una de las 35»), y QA-023-10 sigue abierto.

**Recomendación de la coordinadora: (A).** El atajo no deja ninguna parte de la entrada sin leer: lee todo el comando para decidir que la regla no puede denegar, y la puerta que juzga los destinos los sigue juzgando todos. Es la única opción con margen medido. La equivalencia ya tiene evidencia diferencial, y QA tiene que intentar romperla, empezando por los locales no medidos.

**Qué trabajo sigue mientras no se decida.** **Ninguno del plan:** las fases 2 a 4 dependen de esta decisión. Fuera del plan no se abre nada. Esta entrada impide marcar cualquier REQ como `completado` (ninguno se iba a cerrar en esta intervención).

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-03, décima autorización) — **Fichas P-136-A/B/C resueltas; plantilla de autorización; PLAN AUTORIZADO VIGENTE «décima autorización», CA-54 en fases 0 a 4**

**Texto del propietario, literal** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.36`, tras reiniciar con 1.35.0):

> `JJOVEGA/ArnesJuan`, worktree `/home/juan/dev/ArnesJuan-v1.36`, rama
> `cand/1.36.0`, cabeza reportada `4b4138f`, hooks 1.35.0 ya vigentes tras el
> reinicio. Décima autorización: fichas, plantilla de autorización y primera
> intervención de CA-54.
>
> ## Decisiones del propietario (registrar literales; cierran las fichas)
> - P-136-A: 0 procesos añadidos.
> - P-136-B: criterio por propiedad: toda denegación decidida llega al cliente,
>   entera o acotada, nunca perdida; el desarrollador elige la técnica; los
>   avisos entran.
> - P-136-C: techos de tamaño más plazo propio de 40 s, sin procesos.
> - CA-68 / REQ-017 CA-09: se evalúa al construir SEC-115; si afecta, §9.
> - Las paradas entre fases de un plan autorizado son un defecto de proceso.
>   Desde esta autorización, toda autorización lleva los cuatro bloques de
>   abajo, la plantilla se guarda en templates/autorizacion.md (referida desde
>   la guía y la cola), y ESTADO lleva en su bloque manual «Plan autorizado
>   vigente: <id>, fase N de M, siguiente acción: …» mientras haya uno. El
>   campo derivado queda como ficha de 1.36.0.
>
> ## Plan autorizado (se ejecuta entero; cada fase termina en commit local y
> ## la siguiente empieza sin pedir permiso)
> Fase 0 — analista: plantilla templates/autorizacion.md con los cuatro
>   bloques y esta autorización como ejemplo; ficha del campo derivado;
>   enlaces; filas de REQ-001 y REQ-031 del índice al día; registro de las
>   decisiones. Línea de plan vigente en ESTADO.
> Fase 1 — desarrollador: restaura las dos sondas de CA-54 sin cambiar su
>   medición (solo la ruta de la biblioteca), registra el diff; toma la línea
>   base sobre v1.35.0 (las 35 corridas); inventario.sh del banco con los hooks
>   de v1.35.0 como referencia caso a caso. Sin optimizar todavía.
> Fase 2 — desarrollador: optimiza arnes_bash_sin_texto y lo que haga falta
>   para < 5 s con 131072 bytes en Linux/WSL2, con 0 procesos añadidos, sin
>   cambiar umbral, máximo ni medición. Entrega: las 35 corridas, inventario
>   idéntico caso a caso al de la fase 1, banco completo y autoprueba.
> Fase 3 — QA (Opus): repite las 35 corridas, compara inventarios, banco y
>   autoprueba, intenta romper la optimización. Una pasada correctiva como
>   máximo, dentro del contador, y su re-verificación.
> Fase 4 — seguridad, solo con QA favorable. Write-back del analista solo si
>   hay deriva. Commit del trabajo validado.
>
> ## Lo que decide la coordinadora sola
> Texto, trazabilidad, CHANGELOG, ESTADO, índices; ajustes del banco que no
> cambian ningún veredicto ni contrato; la pasada correctiva prevista; orden
> y presupuesto de cada despacho dentro del propuesto (~300–400k dev, 250–300k
> QA, 150–200k seguridad); registrar defectos nuevos sin repararlos.
>
> ## Cuándo paras y me preguntas (solo esto)
> Cambio de contrato o de alcance; aceptar o aplazar un riesgo; más pasadas
> que la prevista; un veredicto del banco que cambia (inventario distinto);
> un control del proveedor detiene algo (registra, sigue con lo
> independiente); publicar, fusionar, etiquetar, cerrar un REQ.
>
> ## Si la sesión se corta
> La siguiente lee este plan en la cola y en ESTADO y continúa desde la última
> fase comiteada. No vuelve a pedir la autorización: ya está dada.
>
> ## Límites
> No SEC-120, SEC-115/118 ni nada fuera de CA-54 en esta intervención (se
> registran). No AGENTS.md ni contadores. No push, versión, PR, fusión ni tag.
>
> ## Entrega
> Cabeza final por fase; línea base y resultado de las 35 corridas; inventario
> caso a caso (idéntico o diferencias); veredictos de QA y seguridad con su
> alcance; pendientes exactos.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Hooks 1.35.0 vigentes, comprobado tras el reinicio:** una sonda inofensiva con la forma LC10 (`cat` de un heredoc cuya línea de apertura acaba en continuación) la denegó `guard-git` con el motivo «ARNES (SEC-125, LC10)», que sólo existe desde 1.35.0. `installed_plugins.json`: 1.35.0 en los alcances `user` y `project`.
- **`/arnes-upgrade` no hace falta en este repositorio:** el contenido que migran «Hacia 1.34.0» y «Hacia 1.35.0» ya está en `AGENTS.md`, `PENDING_APPROVAL.md` y `requirements/README.md`, que se desarrollaron aquí. Sólo difiere `arnes_version` (`1.33.0`), que se conserva por decisión del propietario (`5d810f0`). Correrlo tocaría `AGENTS.md`, excluido por esta autorización.
- **Las tres fichas pasan debajo** sin cambiar su texto. **Qué trabajo sigue:** el plan de arriba, fase 0.

### RESUELTA (propietario, 2026-10-03, décima autorización; entrada de arriba) — [2026-10-03] (analista-requerimientos) — P-136-A: CA-54, ¿puede la optimización gastar procesos que v1.35.0 no gasta al analizar un comando grande?

**Contexto.** El pedido fija el reloj de CA-54: menos de 5 s en el máximo declarado, en Linux/WSL2, sin cambiar veredictos, sin subir el umbral ni reducir la entrada. `requirements/README.md`, forma (d), exige que un criterio de coste contrate **todas** las vías por las que el coste se degrada. Si no, un arreglo que compra reloj con un proceso da verde en Linux.

Hay dos caminos:
- **El camino común** (un comando sin escrituras) ya lo gobierna REQ-007 CA-59, con línea base en v1.35.0: no cambia.
- **El camino de un comando grande**, que es el que se optimiza, no tiene techo de procesos.

En Windows/MSYS cada proceso cuesta de 1,2 a 6 s (`AGENTS.md` §2). Allí CA-54 ya mide de 20,4 a 28,9 s en el máximo (`sec-ca54-win/RESULTADO.md`), sin promesa en esta ventana.

**Pregunta.** Al analizar un comando grande, ¿la optimización puede lanzar más procesos que v1.35.0?

**Opciones.**
- **(A) No: 0 procesos añadidos frente a v1.35.0**, medido con `tests/util/sonda-procesos.sh` sobre las entradas de las sondas de CA-54. Menos es conforme.
  *Consecuencia:* la optimización tiene que hacerse dentro del proceso que ya existe. Se cierra la vía de comprar reloj con un proceso, que en Windows sumaría segundos. Puede costar más llegar a menos de 5 s.
- **(B) Sí, con techo: hasta N procesos añadidos y sólo por encima de un tamaño de comando.** N y el tamaño se declaran y se miden en Linux. El camino común sigue en CA-59.
  *Consecuencia:* el desarrollador tiene más técnicas a su alcance. En Windows, cada proceso añadido suma de 1,2 a 6 s en esos comandos, y esta ventana no lo mide.
- **(C) No contratar procesos en CA-54; sólo el reloj.**
  *Consecuencia:* CA-54 queda fuera de la forma (d), y se declara. Un arreglo que compre reloj con procesos pasa en Linux y empeora Windows sin que ningún criterio lo vea.

**Recomendación del agente: (A).** Es la regla del stack («sin procesos donde se pueda») y la única que no traslada el coste a la plataforma que no se mide.

**Qué trabajo sigue mientras no se decida.** Siguen implementar y medir una optimización que **no añade procesos**: es conforme con las tres opciones. Depende de esta decisión cualquier técnica que añada procesos.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-03, décima autorización; entrada de arriba) — [2026-10-03] (analista-requerimientos) — P-136-B: CA-67 (SEC-118), ¿qué es «el tope» que se mide, y entran los avisos?

**Contexto.** El pedido dice: «fail-closed cuando … el motivo excede el tope: emitir decisión siempre; medir el tope en bytes y ASCII/multibyte en Linux».

Hoy, el motivo de una denegación viaja a `jq` como un argumento de línea de órdenes. Por encima del límite de bytes de un argumento, el hook sale sin decisión, y eso equivale a permitir. Lo medido en 1.35.0 está en `requirements/README.md` § «Clases de hallazgo» y en `docs/seguridad/registro-seguridad.md` § R-045, §4.

La remediación registrada admite dos técnicas: acotar el motivo en bytes, o sacarlo de la línea de órdenes. Con la primera hay un número que es «el tope». Con la segunda no hay tope del motivo. El pedido no dice cuál de las dos lecturas es la suya.

Además, la remediación nombra `arnes_emitir_avisos`: los avisos que no acompañan a una decisión. El pedido habla de «decisión».

**Preguntas.** (1) ¿Qué es «el tope»? (2) ¿Entran los avisos?

**Opciones para (1).**
- **(A) Un límite en bytes que el arnés pone al motivo.**
  Se declara la cifra. Se mide con contenido ASCII, de 2 y de 4 bytes, en el tope y por encima. El motivo emitido no pasa del tope, conserva la causa, dice que se acortó y no parte un carácter.
  *Consecuencia:* el desarrollador queda obligado a acotar. La cifra pasa a ser contrato operativo.
- **(B) No se acota el motivo: sale de la línea de órdenes.**
  «El tope» es el límite de argumento medido en 1.35.0. Se mide que la decisión sale por encima de él, en ASCII y multibyte.
  *Consecuencia:* el desarrollador queda obligado a no usar la línea de órdenes para el motivo. No hay cifra nueva.
- **(C) Las dos valen; el criterio va por propiedad.**
  La decisión se emite siempre. Si el desarrollador acota, rige además (A). En cualquier caso se mide en los puntos de 1.35.0, ASCII y multibyte. Es lo que hoy está escrito en REQ-007 CA-67.
  *Consecuencia:* la técnica es del desarrollador. La medida cubre las dos lecturas.

**Opciones para (2).**
- **(i) Entran.** El aviso que el hook decide emitir también sale.
  *Consecuencia:* se cierra todo lo que nombra la remediación de SEC-118, con un poco más de alcance que el pedido.
- **(ii) No entran en 1.36.0.** Quedan declarados.
  *Consecuencia:* el alcance es el del pedido. SEC-118 podría no cerrarse entero: eso lo decide el auditor.

**Recomendación del agente: (C) para (1) y (i) para (2).** (C) no elige una técnica en nombre del desarrollador y satisface las dos lecturas del pedido. (i) evita que SEC-118 quede abierto por una parte que cuesta lo mismo reparar.

**Qué trabajo sigue mientras no se decida.** Siguen implementar y probar que **toda denegación se emite** (CA-67, propiedad) y los casos de los puntos medidos en 1.35.0: valen igual con cualquier opción. Dependen de esta decisión la cifra del tope, si la hay, y los avisos.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-03, décima autorización; entrada de arriba) — [2026-10-03] (analista-requerimientos) — P-136-C: CA-68 (SEC-115), ¿con qué mecanismo y con qué plazo se emite la decisión cuando el hook agota el tiempo?

**Contexto.** El pedido dice: «fail-closed cuando el hook agota tiempo … emitir decisión siempre».

Si el cliente mata el hook, nada que el hook haga deniega (SEC-030; REQ-031 CA-A16 lo observó en el cliente). Así que el hook sólo puede **decidir antes**.

La remediación registrada (`docs/seguridad/registro-seguridad.md` § R-044-C, §2) es poner techos de tamaño antes de toda operación que crezca más que linealmente. Eso cubre las vías **identificadas**, y no un tiempo cualquiera. «Siempre» pide algo más, y hay tres formas de acercarse, con fronteras distintas.

**Pregunta.** ¿Qué mecanismo se contrata, y si hay plazo, cuál?

**Opciones.**
- **(A) Sólo techos de tamaño.** Cada techo se declara en bytes y se mide con contenido ASCII y multibyte en el techo y un byte por encima. La promesa llega hasta lo medido.
  *Consecuencia:* no hay reloj. «Siempre» queda acotado a las operaciones cubiertas, y una vía no identificada puede seguir muriendo sin decisión. Un valor legítimo por encima de un techo se deniega.
- **(B) Techos de (A) más un plazo propio del hook.** El plazo se comprueba entre unidades de trabajo, sin procesos, y al vencer el hook emite `deny` con motivo. Es operativo y se baja con la medición; el agente propone **no más de 40 s a nivel de hook, en Linux/WSL2**.
  *Consecuencia:* cubre también las vías no identificadas, salvo una sola operación que se bloquee por dentro. Un juicio legítimo que pase del plazo se deniega a todo agente, también al `desarrollador`. En Windows los juicios tardan varias veces más (CA-54 allí: de 20,4 a 28,9 s) y esta ventana no lo mide. Puede cambiar lo que mide REQ-017 CA-09 (sección 37/3, la pared de los 60 s): si cambia, se escala antes de entregar.
- **(C) Techos de (A) más un vigilante en proceso aparte, que deniega al vencer el plazo.**
  *Consecuencia:* cubre incluso la operación bloqueada. A cambio, añade un proceso a cada llamada, también a un `ls`, y en Windows eso son de 1,2 a 6 s por llamada. Choca con REQ-007 CA-59 (procesos del camino común), que habría que versionar.

**Recomendación del agente: (B), con el plazo en 40 s.** Deja al menos 20 s para emitir la decisión aun con un proceso lento: el `jq` de la emisión, que en Windows cuesta de 1,2 a 6 s. Además, queda por encima del juicio legítimo más lento medido: 28,9 s, CA-54 en Windows sobre `3bc7d3c`. Y no añade procesos.

**Qué trabajo sigue mientras no se decida.** Siguen implementar y probar los **techos de tamaño** para las vías medidas, T1 a T3 de CA-68, y reproducir cada vía en v1.35.0 (fail-before): son comunes a las tres opciones. Dependen de esta decisión el plazo, su valor y el vigilante.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-03) — **Alcance de 1.36.0 y apertura de la ventana**: CA-54 / QA-023-10, SEC-120 y SEC-115/SEC-118, en ese orden; contrato del analista por propiedad y medida; sin implementación

**Texto del propietario, literal** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.36`, «Encargo 2»; registrado aquí para que la «Correspondencia con el encargo» de REQ-007 pueda citarlo por su sede):

> ## Encargo 2 — Apertura de v1.36.0 (coordinadora + analista; sin código)
> Alcance decidido por el propietario, en este orden de prioridad:
> 1. CA-54 / QA-023-10: el análisis de Bash en el máximo declarado (131072
>    bytes) termina en menos de 5 s en Linux/WSL2, sin cambiar ningún veredicto
>    del banco (2050 casos) y sin subir el umbral ni reducir la entrada. Es
>    optimización de rendimiento; se mide con el banco y las sondas existentes.
> 2. SEC-120 (vence 2026-10-29): fallo de jq al leer o trocear la entrada →
>    deny en las herramientas que las puertas juzgan. Comprobación de código de
>    salida, sin procesos nuevos.
> 3. SEC-115 y SEC-118: fail-closed cuando el hook agota tiempo o el motivo
>    excede el tope: emitir decisión siempre; medir el tope en bytes y ASCII/
>    multibyte en Linux; Windows declarado no medido.
> Fuera de alcance: hueco C, P-119-A (F2/F5/F7), SEC-123 mecanismo.
>
> El analista redacta el contrato de 1.36.0 POR PROPIEDAD Y MEDIDA: qué debe
> cumplirse y cómo se mide, reutilizando el banco y las sondas que ya existen.
> No enumera formas de comando ni variantes; cita los casos existentes por su
> identificador. Un REQ nuevo solo si AGENTS.md §9 lo exige para CA-54; si no,
> versionado de los criterios vigentes. Deja listas las decisiones que
> necesite del propietario como fichas en la cola, no las toma.
> Commit local con CHANGELOG. Sin push.
>
> ## Lo que NO haces en esta sesión
> No despaches al desarrollador, QA ni seguridad: esta sesión abre, no
> implementa. La implementación de CA-54 la autorizo aparte, sobre el contrato
> que entregues. No toques hooks/, tools/ ni tests/. No AGENTS.md. No push,
> versión, PR, fusión ni tag.

**Lo que añade la coordinadora, rotulado como suyo:** el contrato está en `requirements/REQ-007.md` (nota de CA-54 del 2026-10-03, CA-47 punto 20, bloque L con CA-67 a CA-69) y en ADR-017 (`propuesta`). Las decisiones que necesita están en § Pendientes (P-136-A, P-136-B y P-136-C). **Esta entrada no autoriza implementar:** la implementación de CA-54 la autoriza el propietario aparte.

### RESUELTA (propietario, 2026-10-03) — **Publicación de v1.35.0 ejecutada**: `main` `3956a6f`, tag `v1.35.0`, PR #59, CI final run 37169938675 (success) sobre `c0f8493`

**Datos del propietario** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.36`, «Encargo 1»): publicada el 2026-10-03; `main` `3956a6f`; tag `v1.35.0`; PR #59; CI final run 37169938675 (success) sobre `c0f8493`. Plugin instalado: 1.35.0.

**Lectura del propietario, literal** (mismo mensaje):

> El impedimento del proveedor de la novena autorización fue sobre el contenido del despacho de SEC-124/125 y la lectura de su diff, no sobre los roles. Los encargos de 1.36.0 se redactan por propiedad y medida.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Discrepancia detectada después (2026-10-03, durante el encargo 2):** en este host (WSL2), `~/.claude/plugins/installed_plugins.json` registra `arnes-juan` **1.33.2** (`10eac80`, `lastUpdated` 2026-09-11), tanto con alcance `user` como con alcance `project`, y el bloque derivado de `docs/ESTADO.md` dice lo mismo. El «Plugin instalado: 1.35.0» de arriba es el dato del mensaje del propietario y no coincide con este host. La actualización de la instalación estable (punto 5 de «Lo que el propietario hace a mano») **no estaba comprobada aquí**. **Hecha después, por petición expresa del propietario (2026-10-03):** 1.35.0 instalada en los alcances `user` y `project` (`gitCommitSha` `3956a6f`), con `hooks/` idéntico al tag; rige desde el próximo reinicio.
- **Comprobado con `git` y `gh` (2026-10-03):** `git tag --points-at 3956a6f` da `v1.35.0`; `3956a6f` es la fusión de `713ac68` y `c0f8493`; el PR #59 está `MERGED` con `mergeCommit` `3956a6f` y `headRefOid` `c0f8493`; el run `37169938675` (`banco`) está `completed`/`success` con `headSha` `c0f8493`.
- **Cierra** lo que quedaba de «Lo que el propietario hace a mano para publicar» en el bloque de 1.35.0 de `docs/ESTADO.md`, puntos 3 a 5 (push, CI, PR, fusión, tag e instalación estable). El punto 1 (`arnes_version`) se resolvió de otro modo: se conserva en `1.33.0` por decisión del propietario (`5d810f0`).
- **No había entrada pendiente que mover:** la cola ya estaba vacía. Esta entrada sólo deja escrito el cierre. **No** autoriza cerrar ningún REQ, y no cambia veredictos, contratos ni contadores.
- **Qué trabajo sigue:** la apertura de 1.36.0 (contrato del analista), autorizada en el mismo mensaje. La implementación de CA-54 la autoriza el propietario aparte.

### RESUELTA (propietario, 2026-10-03, posterior a `8522e4f`) — **Cierre de v1.35.0, tramo 3**: P-119-A resuelta como límites declarados; los motivos de los SKIP remiten al log del CI; la nota histórica de «ocho» no se toca; SEC-126 corregido por el propietario; versión 1.35.0

**Texto del propietario, literal** (mensaje del 2026-10-03, sección «Decisiones del propietario (registrar literales)»):

> 1. P-119-A en REQ-007 pasa de «Preguntas abiertas» a resuelta como limites
>    declarados (decision 5 de publicacion); F2, F5 y F7 siguen abiertos y no
>    aceptados como riesgo. Indice coherente.
> 2. Los motivos de los SKIP no se copian a las notas: viven en el log del CI y
>    en docs/qa/REQ-023.md; las notas remiten alli.
> 3. La nota historica del CHANGELOG con «ocho» no se toca; si hace falta, una
>    aclaracion entre parentesis en la nota nueva.
> 4. SEC-126: corregido por el propietario en hooks/lib.sh (edicion ya en el
>    arbol). Pasa a «reparado» en el registro (solo registro, sin firma) y en
>    las notas. La coordinadora verifica que el diff de hooks/ es SOLO ese
>    comentario: `git diff --stat hooks/` debe mostrar un archivo y
>    `git diff hooks/ | grep '^[-+][^-+#]'` no debe mostrar nada (solo lineas
>    de comentario). Si muestra algo mas, para y avisa.
> 5. Version: arnes_version 1.35.0 en .arnes/config.json; version 1.35.0 en
>    .claude-plugin/plugin.json y marketplace.json. Como esos archivos estan
>    protegidos, los edita el propietario si guard-codigo lo deniega; la
>    coordinadora indica los tres cambios exactos (archivo, clave, valor).

**Lo que añade la coordinadora, rotulado como suyo:**
- **Base:** `8522e4f`, más la edición del propietario en `hooks/lib.sh` sin comitear.
- **Decisión 4, verificada el 2026-10-03:**
  - `git diff --stat hooks/` muestra un archivo, `hooks/lib.sh`, con 4 inserciones y 2 borrados;
  - `git diff hooks/ | grep '^[-+][^-+#]'` no muestra nada (rc 1): sólo hay líneas de comentario;
  - las tres gates de §7 dan rc 0.
- **Decisión 5:**
  - `.claude-plugin/plugin.json` (`version`) y `.claude-plugin/marketplace.json` (`metadata.version` y `plugins[0].version`) **ya están en `1.35.0`**;
  - **sólo falta** `.arnes/config.json`, clave `arnes_version`: `"1.33.0"` → `"1.35.0"`, l. 3. Está en `codigo_app.globs` y lo edita el propietario. La coordinadora no lo intenta.

### RESUELTA (propietario, 2026-10-03, posterior a `52a1d39`) — **Decisiones de publicación de v1.35.0**: CA-54 aceptado con alcance; SEC-115/118, SEC-120, hueco C, P-119-A (F2, F5, F7) y SEC-123 como límites declarados; SEC-126 si es sólo comentario; SKIP/INCONCLUSO no acreditan; «siete» → «ocho»; firmas de QA y seguridad de la fase 2 ausentes y declaradas. Resuelve las fichas 1 y 2, la decisión 9b, P-119-A y SEC-120 de la entrada que estaba pendiente (debajo)

**Texto del propietario, literal** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.35`, sección «Decisiones del propietario para la publicación de v1.35.0»):

> 1. CA-54 / QA-023-10 (decisión 9b) — ACEPTADO CON ALCANCE para v1.35.0. El
>    análisis de Bash tarda 9,0–9,2 s en el máximo declarado (131072 bytes)
>    frente al criterio de < 5 s; igual que 43b948a. No se sube el umbral ni se
>    reduce la entrada. Consecuencia declarada: un comando de ese tamaño se
>    juzga, pero tarda; no es un fallo abierto. Reparación: v1.36.0, foco
>    principal.
> 2. SEC-115 y SEC-118 — LÍMITES DECLARADOS en v1.35.0, no aceptados como
>    definitivos: un hook que agota tiempo o un motivo demasiado grande pueden
>    no emitir decisión; se declaran en notas y guía con sus condiciones
>    medidas. Reparación (fail-closed): v1.36.0.
> 3. SEC-120 — LÍMITE DECLARADO en v1.35.0; reparar en v1.36.0 antes de su
>    vencimiento (2026-10-29): fallo de jq al leer o trocear la entrada → deny.
> 4. Hueco C — LÍMITE DECLARADO del análisis estático: escrituras mediante
>    intérpretes o scripts no se detectan. Permanece abierto; su detección se
>    evalúa por propiedad en una versión posterior, sin fecha.
> 5. P-119-A (F2, F5, F7) y SEC-123 — LÍMITES DECLARADOS, con F3 corregido
>    (R-048). Permanecen abiertos y no aceptados como riesgo.
> 6. SEC-126 — se corrige en este tramo si es sólo el comentario de
>    hooks/lib.sh con la cifra antigua (edición de texto en un comentario, sin
>    cambio de comportamiento); si requiere más, v1.36.0.
> 7. Ningún SKIP ni INCONCLUSO del banco acredita lo que mide; se publican con
>    su motivo.
> 8. Autorizo la corrección de una palabra: «siete clases de casos, y sólo
>    ésas» → «ocho clases» en las notas [1.35.0] y en la guía, para que
>    coincida con la enumeración que sigue.
> 9. Firmas de QA y seguridad del delta de la fase 2: ausentes por impedimento
>    del proveedor; así se publica, declarado en notas y guía. El impedimento
>    fue sobre el contenido del despacho de SEC-124/125 y la lectura de su diff,
>    no sobre los roles.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Base:** `cand/1.35.0` en `52a1d39`.
- **La cola queda vacía.** Estas decisiones resuelven lo último que seguía abierto en la entrada pendiente (fichas 1 y 2, 9b, P-119-A y SEC-120; lo demás ya estaba resuelto), así que esa entrada pasa a § Resueltas, debajo, sin cambiar su texto. Con la cola vacía, `guard-completado` deja de denegar el cierre de REQ **por la cola**. Las demás puertas siguen igual, y cerrar requisitos no está autorizado.
- **SEC-126 (decisión 6):** es sólo el comentario de `hooks/lib.sh`, l. 704. **La coordinadora no lo edita:** `hooks/*` está en `codigo_app.globs` y `guard-codigo` deniega esa edición a quien no es el `desarrollador`. `AGENTS.md` §6 manda ese arreglo al `desarrollador` («la fila 1 no levanta el control de edición»), y este tramo no lo despacha. No se intentó ningún rodeo. Queda para el propietario (edición manual) o para v1.36.0.
- **Contratos, `QA:`/`Seguridad:` y contadores:** sin cambios. «Aceptado con alcance» y «límite declarado» se escriben en las notas y la guía, no en los criterios.

### RESUELTA (propietario, 2026-10-03, decisiones de publicación de v1.35.0; entrada de arriba) — [2026-09-27, puesta al día 2026-10-03] (coordinadora) — Decisión de publicación de 1.35.0: SEC-115/SEC-118, hueco C, P-119-A, SEC-120 y **9b (QA-023-10)** pendientes y no aceptados; **decisión 11 resuelta (opción B), SEC-125 «reparar antes de publicar» y SEC-123 «corregir F3» decididos el 2026-10-03, con la ejecución pendiente de autorización**; fichas 3 y 4 y decisiones 4 a 10 resueltas

- **Contexto:** el 2026-09-29 el propietario autorizó implementar SEC-047 (mitad 1 de REQ-023) y preparar el candidato v1.35.0 (§ Resueltas, entrada de esa fecha, texto literal). **Esa autorización NO acepta el aplazamiento de SEC-115 ni del hueco C**: los dos siguen pendientes aquí, con sus fichas finales abajo. El antiguo asunto 3 (SEC-047 y la celda de §13) queda resuelto por esa autorización; los asuntos 1 y 2 de la redacción del 2026-09-28 se sustituyen por las fichas, sin perder nada de lo que decían.
- **Acción que impide (regla 2):** **publicar** 1.35.0 —tag, publicación, actualización de la instalación estable— hasta que el propietario decida las fichas 1 y 2, P-119-A y la decisión 9b, y se complete la reparación de SEC-119 y O-11 (fichas 3 y 4 y decisiones 4 a 8 resueltas); y, mientras esta entrada esté aquí, **cerrar**: marcar **cualquier** REQ `completado` (`guard-completado`; deliberado). **No** impide **implementar** ni **probar** el candidato. **Parte afectada:** la publicación de 1.35.0 y el cierre de REQ-023 y REQ-031. **Evidencia:** la de cada ficha. **Qué lo resuelve:** la decisión del propietario sobre cada ficha. *(Puesta al día 2026-10-03: la reparación de SEC-119 y O-11 está hecha y con seguridad conforme (R-047). Para **publicar** faltan ahora, además de las fichas 1 y 2, P-119-A y 9b: la ejecución, la validación y la revisión de SEC-124 (B) y SEC-125 y la corrección de F3 (SEC-123), decididas el 2026-10-03 y sin autorización de ejecución; la decisión sobre SEC-120; y una corrida de CI sobre la cabeza final.)*

**Ficha 1 — SEC-115 y SEC-118 (`instrumento`, abiertos, NO aceptados): un hook que no emite decisión —por tiempo (SEC-115) o por el tamaño de su propio motivo (SEC-118)— deja pasar el cierre entero.** *(SEC-118 añadido y fórmula de la limitación corregida el 2026-09-29, por R-045 §6.)*
- **Consecuencia reproducida.** R-044-C sobre `cdcad5d` (2026-09-28, WSL2/Linux): `QA: pendiente (…)` con ≈ 255 KB de evidencia → deny en **73,6 s**; `Write` de 2 025 113 bytes → **80,2 s** (1 012 650 bytes → 20,5 s). CA-A16 (Claude Code CLI 2.1.272, `claude -p`, WSL2, un intento más un control `deny`, 2026-09-28): un hook que agota su timeout sin decidir **deja pasar la herramienta**. El REQ se cerraría con QA y seguridad pendientes: dejan de correr **todas** las puertas del cierre. **No comprobado** en la sesión interactiva del editor ni en Windows.
- **Segunda vía, SEC-118** (R-045, 2026-09-29, severidad media, preexistente: medido igual en el candidato y en `713ac68`). `arnes_deny` pasa el motivo como un argumento de `jq`, y por encima de ~128 KiB el hook sale **sin decisión**. Que el cliente lo trate como permitir es **inferido**, no observado en el host (ver abajo). Medido a nivel de hook:
  - `QA:` de ≈ 140 KB sin paréntesis final → **sin decisión en 0,5 s**, e igual con `Seguridad:`, con `Sensible a seguridad:` y con una línea de 140 KB que lleva un CR interior;
  - REQ-031 CA-A12 con líneas **ASCII** de 60 caracteres o más: 1 601 repeticiones de `Hallazgos abiertos:` deniegan y 1 801 salen **sin decisión**. **El límite es de bytes:** con caracteres multibyte en los primeros 60 caracteres el umbral baja. QA midió el 2026-09-29, igual en `e7562e7` y en `713ac68`, que salen sin decisión 1 601 líneas con `ñ`, 1 001 con caracteres de 4 bytes y 2 501 cortas con `ñ` (QA-023-06).

  Sin medir en Windows, donde el umbral podría bajar a unas 32 KiB. El motivo de REQ-023 tiene tope (20 líneas) y no está afectado.
  - **Qué es observado y qué no, en SEC-118** (segunda autorización, punto 4; sin ensayos nuevos):
    - **Observado directamente**, a nivel de hook, con la entrada JSON `PreToolUse` real alimentada a `guard.sh` en la candidata y en `713ac68` (R-045 §4): el hook termina **sin emitir decisión** en los casos citados, y el control con el mismo valor entre paréntesis (motivo de 314 bytes) deniega. Los recuentos de CA-A12 los midió el auditor (1 601 deniega, 1 801 permite) y los de 3 000 repeticiones, el desarrollador y QA.
    - **Inferido, no observado:**
      - que el host trate como permitir un hook que termina sin decisión en este caso concreto. Se apoya en el contrato de hooks y en CA-A16, que se observó en el CLI 2.1.272 por *timeout* y no por esta causa;
      - el mecanismo exacto («Argument list too long» de `jq` con `MAX_ARG_STRLEN`), leído del código y del error;
      - el umbral en Windows;
      - los candidatos sin medir de R-045 §4.
    - **Ningún caso de SEC-118 se ha ejecutado en el host real.**
- **Protección efectiva hoy:** techo de 16 384 bytes para `Hallazgos abiertos:`, medido antes de normalizar (255 371 bytes → deny en 0,31 s por `Edit`); presupuesto de reconstrucción del `Edit`; el REQ real más grande (296 976 bytes) tarda 1,71 s por `Write`; la línea de control más larga de las 29 cabeceras mide 1 926 bytes.
- **Qué depende de la disciplina del agente:** no escribir evidencia de cientos de KB en `QA:`, `Seguridad:`, `Rigor:`, `Sensible a seguridad:` ni `Estado:`, ni un REQ de MB por `Write`. Sólo `Hallazgos abiertos:` tiene regla escrita (`requirements/README.md`).
- **Alternativa — reparar antes de publicar:** para SEC-115, la propiedad «ninguna operación que crezca más que linealmente corre antes de una comprobación de tamaño que deniegue»: techo por campo de control antes de `arnes_norm_campo`, y techo del `content` de `Write` antes de `arnes_sin_cr_transporte`. Para SEC-118, un solo sitio: que el motivo no viaje como argumento de `jq` (por la entrada estándar, o acotado en bytes). Exige un REQ nuevo (hoy no tienen sede de remediación) y la vía completa. Retrasa el tag lo que dure ese ciclo.
- **Alternativa — aplazar (propuesta, no decisión):** responsable propuesto `desarrollador` (mecanismo) y `analista-requerimientos` (REQ), para los dos; **fecha de revisión propuesta: 2026-10-29**; revisión **anticipada** si ocurre cualquiera de estas: un informe de un hook que sale sin decisión; una medición en Windows del umbral de SEC-118; una comisión que toque `arnes_deny`; una línea de control de más de 16 KB en este repositorio o en un informe de consumidor; un informe de consumidor de un hook muerto por tiempo; una medición en el editor o en Windows de que un timeout también deja pasar; o una comisión que toque `arnes_norm_campo`, `arnes_sin_cr_transporte` o los presupuestos de los hooks (el forzador ya escrito en R-044-C).
- **Limitación para las notas si se publica sin reparar:** la puerta de cierre decide sólo si el hook alcanza a medir **y a emitir su decisión**. Un hook que agota el límite del cliente (60 s; comprobado en el CLI 2.1.272) no deniega, y lo agotan, medido, un veredicto de ≈ 255 KB o un `Write` de ≈ 2 MB (SEC-115). Tampoco deniega un hook cuyo motivo pasa de ~128 KiB **en bytes** (SEC-118): un veredicto de ≈ 140 KB sin paréntesis, o líneas repetidas de `Hallazgos abiertos:` en número suficiente (unas 1 800 si son ASCII, y menos con caracteres multibyte). **La versión no puede prometer** que ningún REQ se cierre sin QA ni seguridad en absoluto, ni que una clave repetida deniegue sin límite: sólo «si el hook alcanza a medir y a emitir su decisión».

**Ficha 2 — hueco C (escrituras por intérprete o script), NO aceptado como aplazado.**
- **Consecuencia reproducida.** 2026-09-27, `guard-codigo` de `a7a60c2` (sin cambios desde `v1.34.0` ni en el candidato), proyecto temporal en WSL2: desde la sesión coordinadora, `python3 -c "open('src/app.ts','w')…"`, `node -e "…writeFileSync…"` y `bash escribe.sh` → **allow**, y el archivo queda escrito (`src/app.ts = py`); `echo >`, `sed -i`, `dd of=` y `Edit` → deny. No hay `PostToolUse`: ninguna detección posterior. `docs/PENDIENTES.md` registra además tres instancias en un proyecto real el 2026-09-07.
- **Protección efectiva hoy:** `Edit`/`Write`/`MultiEdit` sobre `codigo_app.globs` fuera del `desarrollador`, y las escrituras evidentes por `Bash` (`>`, `>>`, `tee`, `cp`, `mv`, `install`, `sed -i`, `perl -i`, `dd of=`).
- **Qué depende de la disciplina del agente:** que ninguno use un intérprete, un script, un formateador o `patch`/`git apply` para escribir código protegido (`AGENTS.md` §5 y §13, que ya lo declaran).
- **Alternativas — reparar antes de publicar:** (A1) ampliar el detector a `python -c`/`node -e` cuando el texto del comando nombra una ruta protegida: impediría las dos formas en línea medidas, **no** `bash script.sh` ni una ruta construida dentro del programa; crítico, vía completa, riesgo de falsos positivos (§13). (A2) REQ-011, la «puerta posterior» (`pendiente`, destino 1.33.0 vencido): **sólo una propuesta de detección** posterior; **no** es prevención, ni recuperación, ni mitigación disponible (no está implementada), y su tamaño es el de una versión propia.
- **Alternativa — aplazar (propuesta, no decisión):** responsable propuesto `desarrollador` (`guard-codigo`) y `analista-requerimientos` (ventana de REQ-011); **fecha de revisión propuesta: 2026-10-15** — antes que SEC-115 porque C está **observado** en un proyecto real y SEC-115 no; revisión **anticipada** si ocurre cualquiera de estas: una nueva instancia observada, en este repositorio o en un consumidor, de código protegido escrito por intérprete o script desde un agente distinto del `desarrollador`; o una comisión que toque `guard-codigo` o el detector de escrituras compartido.
- **Limitación para las notas si se publica sin reparar:** `guard-codigo` no ve escrituras hechas por intérpretes o scripts (`python`, `node`, `bash script.sh`), formateadores que reescriben archivos, `patch` ni `git apply`, y no hay detección posterior. **La versión no puede prometer** que sólo el `desarrollador` modifique código protegido: promete que las herramientas de edición y las escrituras evidentes por shell lo deniegan.

**Ficha 3 — RESUELTA por el propietario el 2026-09-29 (tercera autorización): SEC-117 se REPARA antes de publicar; no se acepta aplazarlo.** *Texto original de la ficha, conservado:* QA-023-02 (`instrumento`, severidad crítica, preexistente; NO aceptado; añadida el 2026-09-29 al escalarla QA). Un `Edit` que el hook no encuentra literal y la herramienta sí, y que sustituye **sólo el valor** del estado, cierra un REQ sin ninguna puerta.
- **Consecuencia reproducida.**
  - **Lado del hook, ejecutado** por QA (2026-09-29, `docs/qa/REQ-023.md` § QA-023-02, evidencia `frontera-g-edit-normaliza.txt`). Sobre un REQ `critico` con `QA: pendiente`, `Seguridad: pendiente` y `SEC-1 (contrato)` abierto:
    - `Edit` con `old_string` = `en-revisi\u00f3n` (barra invertida literal) y `new_string` = `completado` → **ALLOW** en el candidato `ace43c2`, en `713ac68`, en `v1.34.0` (`cc8972c`, medido en la vuelta 2 de QA) y en 1.33.2;
    - `MultiEdit` con la misma edición → ALLOW;
    - comillas rectas donde el archivo las tiene tipográficas → ALLOW;
    - con una entrada bajo `## Pendientes` → ALLOW.
  - **Lado de la herramienta:** QA leyó en el binario del CLI 2.1.284 que el `Edit` normaliza ‘ ’ “ ” y desescapa `\uXXXX`.
  - **REPRODUCIDO EN EL HOST REAL el 2026-09-29** (segunda autorización, punto 3). Registro previo comiteado antes de ejecutar (`6c947ef`); resultado en `sec117-real/RESULTADO.md`, rama local de evidencia, `1c8c81c`. Claude Code **2.1.285**, `claude -p`, WSL2, `Edit` real del host, `guard.sh` del candidato sin cambios; el plugin 1.33.2 instalado no se cargó. Una ejecución por caso:
    - **control positivo:** `old_string` literal → deny, el host bloquea y el archivo no cambia;
    - **caso sospechoso:** comillas rectas donde el archivo tiene tipográficas → el hook sale sin decisión, el host aplica el `Edit` (su `tool_response.oldString` muestra las tipográficas del archivo: normalizó) y el REQ queda **`Estado: completado` con QA y seguridad pendientes, un `contrato` abierto y la cola ocupada**;
    - **control legítimo:** se permite y se aplica.

    **No ensayado en el host:** el escape `\uXXXX`, `MultiEdit`, el editor interactivo, Windows y otras versiones del CLI.
  - **Propuesta mínima de reparación, no aplicada:** fallar cerrado en la vía de fragmentos. Cuando la puerta no puede reconstruir el documento de un REQ, deniega si la edición puede dejar el estado terminal (la «regla ancha» de la vía de `Bash`). No imitar la normalización del host. Sede: `hooks/guard-completado.sh`, con un REQ nuevo y la versión de REQ-001 CA-10/CA-11.
- **Protección efectiva hoy:** ninguna mecánica en esa vía. La rama de fragmentos sólo sigue si el `new_string` contiene «estado: completado». Con la línea `Estado:` completa en el fragmento, juzga veredictos, clase, cola y quality gates (caso G3), pero **no** la regla de la cabecera ambigua de REQ-023: por esa vía la fila crítica de SEC-047 cierra aunque el agente escriba la línea entera (caso B6 de QA, vuelta 3, corregido el 2026-09-29).
- **Qué depende de la disciplina del agente:** cerrar escribiendo la línea `Estado:` entera y con un `old_string` literal.
- **No es regresión:** existe en `v1.33.2` y en `v1.34.0`. Publicar 1.35.0 no lo introduce ni lo agrava, y tampoco lo cierra.
- **Alternativa — reparar antes de publicar:** un REQ nuevo (hoy no tiene sede; la premisa falsa de que «la herramienta falla y no escribe nada» vive también en REQ-001 CA-10/CA-11, `completado`) y la vía completa. Por ejemplo, que la reconstrucción del hook emule la búsqueda de la herramienta, o que deniegue cuando no pueda reconstruir y el fragmento pueda dejar el estado terminal. Retrasa el tag lo que dure ese ciclo.
- **Alternativa — aplazar (propuesta, no decisión):**
  - **Responsables propuestos:** `desarrollador` (mecanismo), `analista-requerimientos` (REQ, y qué hacer con REQ-001) y `auditor-seguridad` (registro y alcance).
  - **Fecha de revisión propuesta: 2026-10-06**, la más temprana de las tres por su severidad.
  - **Revisión anticipada** si ocurre cualquiera de estas: se observa un cierre por esa vía; cambia el respaldo del `Edit` del CLI; o una comisión toca la reconstrucción del `Edit` en `guard-completado`.
- **Limitación para las notas si se publica sin reparar:** la puerta de cierre no juzga un cierre hecho con un `Edit` o `MultiEdit` cuyo `old_string` sólo coincide tras la normalización de la herramienta y cuyo `new_string` no contiene la línea `Estado:`. **La versión no puede prometer** que ningún cierre por `Edit` se salte las puertas.

**Decisión 4 — RESUELTA por el propietario el 2026-09-29 (segunda autorización, § Resueltas): opción (A), corrección documental excepcional fuera del contador, que sigue agotado.** *Texto original de la decisión, conservado:* REQ-023 `bloqueado`: tope de vueltas dev↔QA agotado (3 de 3) con un hallazgo `contrato` de SÓLO TEXTO abierto (QA-023-05). Añadida el 2026-09-29.
- **Qué ocurrió.** QA validó la conducta de CA-01…CA-12 en las tres vueltas sin un solo FAIL. El código ejecutable es el mismo desde `ad793ab`. Sobre `c4cc32c`: banco completo 1137 PASS · 0 FAIL · 12 SKIP, con 1 INCONCLUSO de REQ-017 CA-08 (ii) que se conserva; 37 de 37 decisiones coinciden con la propiedad escrita.
  - Las vueltas 2 y 3 fueron sólo de texto: cerraron QA-023-01, QA-023-03 y QA-023-04.
  - En la vuelta 3 el barrido encontró **QA-023-05**. `requirements/README.md` y su plantilla (líneas 89–98, sede heredada de la frontera) dicen «Cuándo deniega, dicho entero» y «se deniega toda edición…», pero no excluyen la vía (g): la del `Edit`/`MultiEdit` con `old_string` no literal que la herramienta aplica. Por esa vía la puerta permite (B2, B3, B4, B6), igual en `713ac68`, 1.33.2 y `v1.34.0`: es QA-023-02, preexistente.
  - «Toda edición», sin acotar, aparece también en `SKILL.md`, ADR-014 y las notas, que sí declaran (g) en el mismo apartado.
- **Acción que impide (regla 2):** **cerrar** REQ-023: `guard-completado` deniega con un `contrato` abierto, y QA no puede firmar `aprobado` sin el write-back (§9). Por consecuencia impide también **publicar** con ese texto heredado falso. **Parte afectada:** sólo esas sedes de texto; ni el código ni la conducta. **Evidencia:** `docs/qa/REQ-023.md` § «Vuelta 3 de 3» (§3 y §5). **Qué lo resuelve:** el write-back de texto y una reverificación de texto por QA, que ya no caben en el contador.
- **Opciones** («Loop de error»):
  - **(A) Autorizar una corrección documental fuera del contador,** acotada a QA-023-05 y a las condiciones de texto de R-045 §6, como la del 2026-09-28 con REQ-031.
    - **Qué se toca en REQ-023:** el analista acota el «Cuándo deniega» del README y de la plantilla a las ediciones que la puerta reconstruye (`Write`, o `Edit`/`MultiEdit` con `old_string` literal), añade la vía (g) a «Fuera, y sin promesa» remitiendo a QA-023-02 / SEC-117, y acota «toda edición» en `SKILL.md`, ADR-014 y las notas.
    - **Qué se toca por R-045 §6:** declarar SEC-118 en las notas; corregir la fórmula «si el hook alcanza a medir» por «si alcanza a medir y a emitir su decisión» en el cambio de compatibilidad 1 de las notas y en la entrada de REQ-031 de la guía; y citar SEC-117 en la guía. El barrido se hace por propiedad, con esta advertencia: la promesa de que la clave repetida deniega sin límite también está en texto de **REQ-031** ya publicado en `main`, en `AGENTS.md` §13 y su plantilla y en el README («Si hay más de una, deniega»), y SEC-118 la desmiente a partir de unas 1 700 repeticiones.
    - QA reverifica sólo ese texto, y seguridad lo confirma de forma documental.
    - **Qué no cambia:** ningún código y ninguna conducta.
    - **Consecuencia:** una comisión corta de cada uno; después, la firma de seguridad sobre el árbol resultante.
  - **(B) Cerrar con el residual declarado:** **no es posible**. El residual es `contrato` y la puerta no deja cerrar con uno abierto; rebajar su clase sería mover el hallazgo de sitio, y eso lo prohíbe §6.
  - **(C) Mantener REQ-023 `bloqueado` y publicar 1.35.0 sin él,** retirando su código y sus textos del candidato. **Consecuencia:** SEC-047 mitad 1 no se publica, se rehace el candidato y se vuelve a validar.
- **Recomendación de la coordinadora:** (A). El defecto es de texto, la conducta está validada tres veces sin fallos, y la corrección tiene alcance cerrado. Recibido (A), el trabajo sigue sin más autorizaciones.
- **Trabajo que sigue mientras tanto** (no depende de esta decisión):
  - la revisión de seguridad del código del candidato: es una revisión, **no** una firma `Seguridad: aprobado`, que exige `QA: aprobado`;
  - el registro formal de QA-023-02 y del fail-open del motivo de CA-A12;
  - el push, el PR en borrador y el CI.

**Decisión 5 — RESUELTA por el propietario el 2026-09-29 (tercera autorización): se corrige QA-023-06 conservando las cifras medidas con sus condiciones, incluida la restricción ASCII, y separando la propiedad del control de las limitaciones SEC-115/118.** Es una forma propia del propietario, distinta de las opciones (A) y (B). *Texto original de la decisión, conservado:* QA-023-06 (`contrato`, sólo texto), abierto por la revisión de QA del delta documental. Añadida el 2026-09-29.
- **Qué ocurrió.** La intervención excepcional autorizada cerró QA-023-05. QA confirmó ciertos, contra la evidencia en crudo:
  - SEC-117 reproducido en la 2.1.285;
  - la separación de SEC-118 entre observado, inferido y no medido;
  - el fail-before local frente a los 18 SKIP del CI;
  - las tres condiciones de la cláusula nueva de §13.

  Pero **el mismo delta publicó cifras de SEC-118 como frontera medida** («1 601 líneas de 60 caracteres o más deniegan», «2 501 cortas deniegan», «umbral ≈ 1 700 / 2 900») cuando **sólo están medidas con líneas ASCII**, y el límite es de bytes. Con multibyte salen sin decisión 1 601, 1 001 y 2 501 líneas (QA, con la puerta real, igual en `e7562e7` y `713ac68`).
  - **Sedes:** README y plantilla, `AGENTS.md` §13 y su gemela, REQ-031 CA-A12 (nota de versionado) y su Historial, REQ-023, ADR-013, ADR-014, la guía y las notas.
  - **El origen es de la coordinadora:** su encargo pidió al analista escribir la propiedad «con lo medido».
- **Acción que impide (regla 2):** **cerrar** REQ-023 y **REQ-031**, que tienen ahora `QA: con-hallazgos` con QA-023-06. La cola ya lo impedía. Impide también **publicar**, porque el texto heredado afirmaría algo falso. **Parte afectada:** sólo cifras de texto; ni código ni conducta. **Evidencia:** `docs/qa/REQ-023.md` § «Intervención documental excepcional», §5. **Qué lo resuelve:** una reescritura de esas cifras y la revisión de QA sobre el texto. La autorización de una sola intervención ya está consumida.
- **Opciones:**
  - **(A) Autorizar una segunda corrección documental fuera del contador, acotada a QA-023-06,** con la forma que menos riesgo de repetición tiene. Las sedes heredadas se quedan con la **propiedad sin cifras** («deniega si el hook alcanza a medir y a emitir su decisión; el límite es de bytes y lo medido está en el registro»), y las cifras viven **sólo** en R-045, con «medido con líneas ASCII».
    - **Flujo:** analista, después QA sobre el texto, después la determinación de seguridad.
    - **Consecuencia:** dos o tres comisiones cortas, sin código.
  - **(B) Lo mismo, conservando cifras en las sedes** con la precisión de bytes y la salvedad ASCII. **Consecuencia:** más sedes que mantener en sincronía con el registro, y más superficie para el mismo tipo de defecto.
  - **(C) Publicar con QA-023-06 abierto:** **no es posible**. Es `contrato`: la puerta no deja cerrar con uno abierto, y el texto heredado afirmaría algo falso.
- **Recomendación de la coordinadora:** (A). Una cifra repetida en diez sedes se desfasa en cuanto cambia una medición, y eso es lo que acaba de pasar.
- **Observaciones de QA sin identificador, que no bloquean** (detalle en la misma adenda, §5):
  - **O-1:** la condición 2 de la cláusula de §13, leída literalmente, vacía la fila de `Bash`; promete de menos.
  - **O-2:** con la línea `Estado:` entera pero decorada (`**Estado:** completado`), con punto final o entre comillas invertidas, la vía (g) pasa sin puertas. Es más ancho que lo que dice la cláusula.
  - **O-3:** a nivel de hook, un `Edit` con `old_string` vacío que crea un REQ con `**Estado:** completado` sale allow, y el mismo documento por `Write` deniega. Es superficie de SEC-117 no medida en el host; debe registrarla el auditor.
  - **O-4:** la cláusula remite las cifras al registro, pero la fila de hallazgos lleva cifras.
  - **O-5:** la guía no manda migrar la cláusula nueva de §13, así que un proyecto que actualice no la recibe.
  - **O-6:** la frase del README sobre `MultiEdit` promete de menos.

  Si se autoriza (A), O-1, O-2, O-4, O-5 y O-6 son del mismo tipo (el texto de §13, del README y de la guía) y conviene que entren en la misma corrección, **sólo si el propietario lo autoriza expresamente**. O-2 y O-3 son superficie de SEC-117 y van a su registro, no a esta corrección.

**Decisión 6 — RESUELTA por el propietario el 2026-09-30 (cuarta autorización): opción (A).** *Texto original, conservado:* P-SEC117: la reparación de SEC-117 que exige la propiedad choca con criterios vigentes de REQ-001 (`completado`) y REQ-007. Añadida el 2026-09-29, durante la vuelta excepcional de la tercera autorización.
- **Pregunta.** ¿Autorizas que la reparación de SEC-117, dentro de esta misma vuelta excepcional, haga cuatro cosas?
  1. Versionar **REQ-001 CA-10, CA-11 y CA-12** y **REQ-007 CA-46 (c)**. Con eso **REQ-001 se reabre** (§9) y queda `en-revisión` en el candidato, sin cerrarse.
  2. Adaptar los casos del banco que fabrican un `old_string` no literal sobre `requirements/`.
  3. Extender la revisión de QA y seguridad de la vuelta a esos dos REQ.
  4. Lo que implica la condición «no reconstruible → deny».
- **Por qué hace falta.** La propiedad que fijaste —«esa incertidumbre no puede convertirse en permiso silencioso»— obliga a denegar el `Edit`/`MultiEdit` sobre `requirements/` que el hook no puede reconstruir. Pero:
  - **REQ-001 CA-11 contrata literalmente lo contrario:** ALLOW para `old_string` inexistente y `new_string` = `completado`, «la herramienta fallará entera». Es la premisa que el experimento real desmintió (SEC-117).
  - CA-10 («el fallback sigue vivo») y CA-12 (un `Edit` sobre una ruta inexistente «cae al fragmento y no bloquea») van en el mismo sentido, y también REQ-007 CA-46 (c) («no elimina el fallback»).
  - **El banco:** 111 llamadas a `emite_edit`, que fabrica `old_string:"x"`, en 20 secciones; unas 49 esperan allow y 55 deny, contadas por la coordinadora con `grep`. Las que apuntan a `requirements/` dejarían de medir las puertas que miden hoy, porque la regla nueva deniega antes, y habría que convertirlas en ediciones literales.
  - La tercera autorización nombra sólo REQ-023 y REQ-031 como alcance de la revisión de QA.
- **Opciones:**
  - **(A) Sí, cumplir la propiedad.**
    - **Contrato:** el analista versiona REQ-001 CA-10, CA-11 y CA-12 y REQ-007 CA-46 (c), con un ADR de fondo (SEC-117 supersede la premisa), y escribe el criterio nuevo en REQ-023 (su borrador de CA-13 está en REQ-023, «Preguntas abiertas», P-SEC117).
    - **Código y banco:** el desarrollador implementa y convierte los casos afectados.
    - **Revisión:** QA y seguridad revisan también REQ-001 y REQ-007.
    - **Consecuencia:** es una vuelta mayor, con más riesgo de no cerrarla en su único intento, y REQ-001 queda reabierto en el candidato.
  - **(B) Regla ancha sólo sobre el fragmento no reconstruible:** denegar si la edición menciona el estado terminal. **No cumple la propiedad.** El analista lo deriva leyendo, sin medirlo: un valor escrito con `\uXXXX` que el host desescapa, o retirar la línea `Estado` que gobierna para que gobierne otra terminal, siguen dando permiso silencioso. Además exige igual versionar CA-11.
  - **(C) No reparar ahora:** ya lo rechazaste.
- **Recomendación de la coordinadora:** (A), con el alcance escrito arriba y nada más. Es la única opción que cumple la propiedad. REQ-001 queda reabierto y **no** se cierra, porque cerrar requisitos no está autorizado.
- **Acción que impide (regla 2):** **implementar** la reparación de SEC-117, porque su contrato no se puede escribir sin decidir esto. **Parte afectada:** SEC-117 y todo lo que depende de ella: la frontera (g), la condición 3 de la cláusula de §13, la fila nueva de §13, los comentarios de código de esa vía, la validación en el host, QA y seguridad. **Evidencia:** REQ-023, «Preguntas abiertas», P-SEC117; REQ-001 CA-10, CA-11 y CA-12; REQ-007 CA-46 (c); el recuento del banco. **Qué lo resuelve:** tu elección.
- **Qué sigue mientras tanto:**
  - La **corrección de texto de QA-023-06** ya está hecha por el analista, sin validar, en commit local. La vuelta agrupada no se parte, así que el desarrollador, QA y seguridad esperan a esta decisión.
  - La coordinadora decide por su cuenta, sin necesitarte, que el principio «una frase condicional no acredita protección» se aplique también a REQ-031 CA-A13 (el techo) en la misma pasada del analista. Es una sede de REQ-031 afectada por el mismo principio y está dentro de la autorización.

**Ficha 4 — RESUELTA por el propietario el 2026-09-30 (quinta autorización): SEC-119 se REPARA en esta frontera.** *Texto original, conservado:* QA-023-07 (`instrumento`, severidad alta, PREEXISTENTE; NO aceptado; añadida el 2026-09-30, escalada por QA como urgencia de seguridad). Una ruta con segmentos `..` que entra en `requirements/` o en el código protegido desde un directorio libre no la juzga ninguna puerta.
- **Consecuencia medida a nivel de hook, no en el host** (QA, 2026-09-30, igual en el candidato `cd47f06`, en `df550fa` y en 1.33.2; `docs/qa/REQ-023.md`, adenda de la vuelta excepcional, §10):
  - un `Edit` que cierra un REQ `critico` con QA pendiente, a través de una ruta con `..`, sale **allow**, sea literal o no literal;
  - un `Write` de la coordinadora a `<raíz>/docs/../src/a.ts` sale **allow** en `guard-codigo`.
- **Causa:** `arnes_ruta_relativa` y `arnes_norm_path` no resuelven los segmentos `..`.
- **Protección efectiva hoy:** ninguna mecánica en esa vía. **Depende de la disciplina:** que ningún agente construya rutas con `..`.
- **No es regresión:** 1.35.0 no lo introduce ni lo agrava; tampoco lo cierra.
- **Qué impide:** nada de REQ-023 por su clase. Puede impedir **publicar**, si el propietario lo decide.
- **Alternativas:**
  - **reparar antes de publicar**, con una reparación en ciclo propio, que la autorización vigente no abre automáticamente;
  - **aplazar**, con responsable propuesto `desarrollador` (lector de rutas) y `analista-requerimientos` (contrato), revisión propuesta el 2026-10-07 y revisión anticipada ante cualquier observación de una escritura por ruta con `..` en este repositorio o en un consumidor.
- **Valoración de seguridad** (R-045-A, 2026-09-30):
  - registrado como **SEC-119** (`instrumento`, alta), ampliado por propiedad: las puertas deciden por la **ruta escrita**, no por la canónica. A nivel de hook, en tres árboles, `docs/../requirements/`, `././requirements/` y un directorio enlazado evaden `guard-completado`, y lo mismo pasa con `guard-codigo` para `src/`;
  - remedio de sede única: canonicalizar la ruta y usar `test -ef` en `arnes_ruta_relativa`, sin procesos nuevos;
  - **recomienda reparar antes de publicar**, porque tiene el mismo efecto que SEC-117, un bypass total y silencioso, y alcanza además a `guard-codigo`;
  - en contra: no está ensayado en el host, no hay exposición accidental observada, y retener 1.35.0 deja a los consumidores sin SEC-117 ni SEC-047;
  - si se aplaza, la cláusula de §13 y las notas deben declarar SEC-119 como limitación de todas las filas.
- **Recomendación de la coordinadora:** coincide con el auditor en que es la misma clase de efecto que SEC-117, y tú ya fijaste no publicar con un bypass total aplazado. Recomiendo **reparar antes de publicar**, con una autorización expresa, porque la vuelta vigente no lo cubre.

**Decisión 7 — RESUELTA por el propietario el 2026-09-30 (quinta autorización): O-11 se corrige dentro de esta misma frontera.** *Texto original, conservado:* O-11 (QA, 2026-09-30): la vía del archivo ilegible (NUL en disco, SEC-002) queda fuera de CA-13. Con NUL en el disco, una edición no reconstruible que no escribe la palabra del estado terminal recibe permiso, y CA-13 (iv) lo excluye con la causa que da la tercera autorización («porque no encuentra literalmente el texto anterior»). Pero tu cuarta autorización reformula la propiedad **sin esa causa** («una edición sobre un REQ protegido que el hook no puede reconstruir no puede recibir permiso silencioso»).
- **Pregunta:** ¿la vía del archivo ilegible entra en la propiedad?
- **Opciones:**
  - **(A)** No: se queda como está, declarada en CA-13 (iv), con SEC-002 como sede. La **consecuencia** es un residuo estrecho: requiere un NUL ya escrito en el REQ.
  - **(B)** Sí: se repara en ciclo propio (denegar toda edición de un REQ ilegible), fuera de esta vuelta.
- **Recomendación de la coordinadora:** (B) como trabajo siguiente, fuera de esta vuelta, y declararlo mientras tanto. Es la misma clase de defecto, pero su causa, el disco ilegible, es distinta de la que reparó esta vuelta.
- **Valoración de seguridad** (R-045-A): **(B)**. La propiedad de la cuarta autorización lo alcanza de lleno. Tiene un productor natural conocido: PowerShell 5.1 escribiendo en UTF-16LE. El remedio es denegar todo `Edit`/`MultiEdit` de un REQ que no se puede leer entero, dejando `Write` como salida. Si se elige (A), la cláusula de §13 tiene que llevar escrita la excepción antes de publicar.
- **Qué sigue mientras tanto:** la determinación de seguridad.

**Decisión 8 — RESUELTA por el propietario el 2026-10-01 (sexta autorización, § Resueltas): opción (A), con la condición de parada de QA-023-10 escrita por él.** *Texto original, conservado:* la vuelta excepcional de la quinta autorización termina con QA NO favorable. ¿Cómo sigue la reparación de SEC-119 y O-11?
- **Qué ocurrió.** QA revisó el delta `104ffd1..43b948a` (`docs/qa/REQ-023.md` § «Vuelta excepcional de la quinta autorización»).
  - **Conforme:** CA-45, CA-46 (b), (d) y (e), CA-47 a CA-50, la nota de CA-58, CA-60 y CA-66 puntos 1 a 5, 7 y 8, con el fail-before re-derivado contra `9596e39` y 1.33.2. Banco completo 1322 PASS · 0 FAIL · 12 SKIP, cuadre 1334; autoprueba 117/0; gates rc 0. QA-023-07 y QA-023-08 quedan **cerrados**.
  - **Tres hallazgos nuevos, los tres `contrato` en REQ-007:**
    - **QA-023-09 (alta a nivel de hook; regresión de `104ffd1`).** `arnes_parse_input` lee varios campos de una sola salida de `jq`, uno por línea, y el delta añadió el `cwd` delante de la ruta. Un `cwd` con salto de línea desplaza los campos, y las dos puertas juzgan otra ruta. Medido por inyección, por la ruta canónica: el cierre de un REQ `critico` con QA pendiente, la edición no reconstruible de SEC-117 y un `Write` de la coordinadora a código protegido salen **allow**, donde `9596e39` y 1.33.2 deniegan. Es un movimiento de deny a allow que CA-24 y CA-66 punto 5 no declaran. En REQ-023 QA lo registra como `instrumento`, porque la promesa que falla tiene su sede en REQ-007 CA-47.
    - **QA-023-10 (media).** CA-54 exige menos de 5 s en el máximo de análisis de `Bash` (131 072 bytes). El candidato tarda de 9,5 a 12,1 s, en quince corridas: concluyente en WSL2. `9596e39` tardaba de 2,9 a 6,9 s y ya lo superaba en una de las tres formas. En el valor por defecto (65 536 bytes) el candidato también lo supera. No hay fallo en abierto medido: queda un margen de unas cinco veces hasta los 60 s.
    - **QA-023-11 (media).** La validación en el host no ejecutaba ni declaraba R5 ni el `cwd` tras un `cd` (CA-45 y CA-66 punto 6).
- **Lo que hizo después la coordinadora.** Es validación ya autorizada (quinta autorización, punto 5), no una reparación. Ejecutó en el host real los dos casos que faltaban, con registro previo `f209d06` y resultado `7a3cb6e` (rama local de evidencia, `sec119-v3b/`). CLI 2.1.285, una ejecución por caso:
  - el `cwd` que recibe el hook **sigue** a un `cd` hecho en una llamada anterior de `Bash`;
  - **QA-023-09 se manifiesta en el host.** Con un directorio cuyo nombre lleva un salto de línea, el `cwd` llega literal al hook. El hook no juzgó la ruta canónica que pidió la herramienta: juzgó un fragmento del `cwd`. Denegó **sólo** porque, con el nombre ensayado, ese destino desplazado no se podía determinar, y CA-47 hace que lo no determinable no pase. No se ensayó un nombre con el que sí se pueda determinar, así que **un permiso desde el host no está observado ni descartado**. El control sin salto de línea se juzgó por su ruta real;
  - **R5 no llega al hook:** el `Read` previo falla con `EACCES` y no hay `Edit` que juzgar. CA-45 frente a un archivo sin permiso de lectura sigue verificado sólo a nivel de hook. Para ese caso, QA-023-11 pide que el analista lo declare como límite.
- **Acción que impide (regla 2):**
  - **publicar** 1.35.0. En la ficha 4 decidiste no publicar con un rodeo total aplazado, y QA-023-09 rodea las dos puertas por completo; 1.33.2 y `v1.34.0` no tienen ese rodeo;
  - **cerrar** REQ-007, que suma tres `contrato` (ya no cerraba por QA-114, QA-116 y QA-117);
  - la **determinación de seguridad** de esta vuelta: el auditor no firma sobre un árbol sin QA favorable (§6).

  Por su clase, **no** impide cerrar REQ-023, REQ-031 ni REQ-001: QA mantiene su `QA: aprobado` sobre el código final, sin cubrir QA-023-09. Cerrarlos lo impide ya la cola.
  - **Parte afectada:** las dos puertas, ante cualquier entrada cuyo `cwd` lleve un salto de línea (QA-023-09); el análisis de `Bash` en su máximo y en su defecto (QA-023-10); el texto de CA-45 y CA-66 (QA-023-11).
  - **Evidencia:** `docs/qa/REQ-023.md` §9, con sus anexos `11-cwd-salto-de-linea.txt` y `30-ca54-coste.txt` (rama local de evidencia, `cand-1.35.0/evidencia-qa-sec119/`, `66de607`), y `sec119-v3b/RESULTADO.md` (`7a3cb6e`).
  - **Qué lo resuelve:** tu decisión. La quinta autorización dice que una vuelta que termina con un bloqueo no abre otra automáticamente.
- **Opciones:**
  - **(A) Otra vuelta excepcional, acotada a los tres hallazgos y sin reiniciar contadores** (el de REQ-023 sigue en 3 de 3).
    - **Desarrollador, QA-023-09:** se corrige en el código, sin cambio de contrato. Ningún salto de línea en el `cwd` puede desplazar un campo; la técnica la elige él. Lleva fail-before contra `43b948a` y control opuesto.
    - **Desarrollador, QA-023-10:** optimizar la identificación por destino.
    - **Analista:** declara R5 como límite en CA-45 y en el punto 6 de CA-66 (QA-023-11).
    - **Después:** QA, y seguridad con QA favorable.
    - **Consecuencia:** una vuelta más. QA-023-09 es un delta pequeño y localizado en un solo sitio; QA-023-10 es la parte con resultado incierto.
  - **(B) Retirar del candidato la reparación de SEC-119 y O-11** (el código de los hooks vuelve a `9596e39` más SEC-117) y publicar con SEC-119 y O-11 declarados como limitación.
    - **Consecuencia:** contradice tu decisión de la ficha 4. Además, vuelven a quedar abiertos los vectores alcanzables desde el host que la v3 mostró cerrados: el directorio enlazado por `Edit`, `..` por `Bash` y el REQ en UTF-16. Se nombra sólo porque es la alternativa a reparar.
  - **(C) Esperar:** ni reparar ahora ni publicar.
    - **Consecuencia:** 1.35.0 queda retenida, y SEC-047 y SEC-117 no llegan a los consumidores.
- **Recomendación de la coordinadora:** **(A)**, con una condición de parada para QA-023-10. Si la optimización no deja el máximo por debajo de 5 s, el desarrollador para y la cifra vuelve a ti. La regla de CA-54 permite bajar el máximo sin ADR, pero el candidato tampoco cumple en el valor por defecto. Bajar de ahí cambia lo que se deniega por presupuesto en todos los proyectos, y eso no es una medición: es una decisión. QA-023-09 es una regresión de este mismo delta, tiene causa localizada y no cambia el contrato; la v3b muestra que se manifiesta en el host.
- **Relación con P-119-A**, la pregunta abierta de REQ-007 sobre las fronteras F2, F3, F5 y F7, que también espera tu respuesta.
  - Aceptar F7 declarada **no** cubre QA-023-09. F7 deja fuera lo que el host haga con la ruta, y que el `cwd` sea el directorio del comando. QA-023-09, en cambio, es una puerta que lee mal un campo que sí recibe, y CA-24 prohíbe ese movimiento sin excepción.
  - La v3b además ya midió parte de F7: el `cwd` sigue al `cd`.
- **Trabajo que sigue mientras tanto:** ninguno de implementación ni de revisión. Esta vuelta queda registrada en el candidato con un commit local, y la evidencia en la rama local de evidencia. **El push de `cand/1.35.0` y el CI sobre la cabeza actual no se han hecho:** `origin` y el PR #59 siguen en `9596e39`. No hacen falta para decidir.

**Decisión 9 — 9a RESUELTA por el propietario el 2026-10-02 (séptima autorización, § Resueltas): se repara QA-023-13, y puede denegarse un `cwd` que contenga CR. 9b SIGUE PENDIENTE y NO está autorizada: «medir en Windows no sustituye el criterio vigente de menos de 5 segundos ni equivale a aceptar que un timeout deje pasar la operación». En esta vuelta se prepara su decisión.** *Texto original, conservado:* la vuelta de la sexta autorización termina con QA NO favorable por un hallazgo nuevo, QA-023-13; y QA-023-10 sigue abierto tras su parada. ¿Cómo sigue el candidato?
- **Qué ocurrió.** La vuelta se hizo entera: desarrollador, analista, host y QA con Opus (`docs/qa/REQ-023.md` § «Vuelta excepcional de la sexta autorización»; evidencia en la rama local de evidencia, `0d3d0c9`).
  - **QA-023-09, cerrado.** La entrada del hook se lee campo a campo y entera (`cd6afa6`). Un `file_path` o un `tool_name` con LF es no determinable (CA-47 puntos 12 y 13). En el host real, con un `cwd` con salto de línea, las dos puertas juzgan la ruta pedida y el control legítimo pasa (`sec119-r6/`, `3eb279d`).
  - **QA-023-11, cerrado.** CA-45 incorpora la v3b: el `cwd` sigue al `cd`, y R5 queda como límite de la comprobación en el host.
  - **QA-023-10, abierto.** La optimización no alcanzó los 5 s (6,5–9,5 s en 131 072), se detuvo como mandaste y salió del candidato. Queda conservada como parche en la evidencia (`3b947a1`). El árbol final cuesta lo mismo que `43b948a`: 8,6–10,3 s según el desarrollador y 9,0–9,2 s según QA, frente a 2,9–7,2 s de `9596e39`. QA verificó que la parada fue fiel.
  - **QA-023-13, nuevo** (`contrato` en REQ-007, `instrumento` en REQ-023). `arnes_sin_cr_transporte` recorta el CR final de cada campo, porque el `jq` de Windows termina las líneas en CRLF. Un CR que forma parte del nombre del `cwd` desaparece, y la puerta ancla las rutas relativas de `Bash` en otro directorio que el shell.
    - **Medido a nivel de hook en la cabeza actual** (`evidencia-qa-r6/27-repro-CR-cwd.txt`): desde un directorio cuyo nombre termina en CR y enlaza a la raíz, el shell escribe en `<raíz>/src/a.ts`. Pero `echo x > src/a.ts` de la coordinadora y un `sed -i` que cierra un REQ en rojo salen **allow**, donde `9596e39` y 1.33.2 deniegan.
    - **De dónde viene:** nace con el anclaje en el `cwd` que introdujo la reparación de SEC-119 (`104ffd1`). No es del delta de esta vuelta.
    - **Qué exige:** un directorio con ese nombre, enlazado a la zona protegida, y un `cd` a él. Es ofuscación deliberada, no descuido. Alcanzable desde el host: sin medir.
    - **Qué desmiente:** CA-47 punto 11 («anclado en el `cwd` entero») y CA-66 punto 5 («ninguno nuevo de deny a allow»).
- **Acción que impide (regla 2):**
  - la **determinación de seguridad** del delta de SEC-119/O-11: el auditor no firma sin QA favorable (§6), y no ha firmado nada desde R-045-A (`8745b3f`);
  - **publicar** 1.35.0: QA-023-13 es un rodeo frente a lo publicado, y en las fichas 3 y 4 decidiste no publicar con un rodeo total aplazado;
  - **cerrar** REQ-007.

  **No** impide cerrar REQ-023, REQ-031 ni REQ-001 por clase (`QA: aprobado` sobre `9c53232`), pero lo impide ya la cola.
  - **Parte afectada:** las rutas relativas de `Bash`, en las dos puertas, cuando el `cwd` termina en CR (QA-023-13); y el coste del análisis de `Bash` (QA-023-10).
  - **Evidencia:** la citada arriba.
  - **Qué lo resuelve:** tu decisión. La sexta autorización no abre otra vuelta automáticamente.
- **9a — QA-023-13. Opciones:**
  - **(A) Reparar fallando cerrado, en una vuelta excepcional acotada, sin reiniciar contadores.** El analista añade en CA-47 la causa, como hizo con el punto 12: un `cwd` cuyo texto contiene un CR no ancla una relativa, que pasa a ser no determinable. Otra técnica que preserve el CR del contenido la elige el desarrollador, si existe sin procesos nuevos. Después, desarrollador, QA y seguridad.
    - **Consecuencia:** una vuelta más, de delta pequeño. Una escritura relativa por `Bash` desde un directorio con CR en el nombre se deniega, y eso en la práctica no existe.
  - **(B) Aceptar la frontera del CR y declararla.** El analista la escribe en CA-47 y la añade como séptimo movimiento de deny a allow en CA-66 punto 5. Después, QA del texto y seguridad.
    - **Consecuencia:** 1.35.0 publicaría un rodeo frente a 1.33.2 que exige ofuscación deliberada. Es coherente con «barandilla, no jaula» (§13), pero no con la línea que mantuviste en SEC-117 y SEC-119.
- **9b — QA-023-10. Opciones:**
  - **(A) Publicar con CA-54 incumplido, como residual declarado.** Dueños: `desarrollador` y `analista-requerimientos`. Vencimiento: la versión siguiente. Forzador: un hook de `Bash` muerto por tiempo, o una medición en Windows. Las notas ya lo declaran.
    - **Consecuencia:** el análisis de `Bash` en el máximo tarda unos 9 s en WSL2, frente a 3–7 s en 1.33.2. No hay fallo en abierto medido: hay más de cuatro veces de margen hasta los 60 s. **Pero en Windows/MSYS no está medido**, y allí cada sentencia de bash cuesta más. Si el factor pasara de unas seis veces, el hook moriría por tiempo y dejaría pasar, que es la clase de SEC-115.
  - **(B) Incorporar la optimización conservada** (6,5–9,5 s) y decidir el diseño del trabajo por destino.
    - **Consecuencia:** sigue sin cumplir los 5 s. Reintroduce un refactor de las funciones de identidad de SEC-119, con otra vuelta de QA y de seguridad.
  - **(C) Bajar el máximo, y el defecto, por la regla de CA-54** hasta que cumpla.
    - **Consecuencia:** cambia, en todos los proyectos, qué comandos de `Bash` se deniegan por presupuesto. Bajar el defecto no es una medición: es una decisión.
- **Recomendación de la coordinadora:**
  - **9a (A).** El defecto es de identidad, la misma clase que reparaste en SEC-119, y fallar cerrado cuesta un delta pequeño.
  - **9b (A),** con una condición antes de publicar: medir el caso del máximo en Windows/MSYS. Si se acerca a los 60 s, la decisión vuelve a ti con esa cifra.
  - Las dos caben en una sola vuelta excepcional.
- **Junto a esta decisión siguen pendientes:** la ficha 1 (SEC-115/SEC-118), la ficha 2 (C) y P-119-A. Ninguna está aceptada. Aceptar F7 no cubre QA-023-09 ni QA-023-13.
- **Trabajo que sigue mientras tanto:** ninguno de implementación ni de revisión. La coordinadora sólo completa lo que la sexta autorización ya cubre: push, CI sobre la cabeza final y actualización del PR #59 en borrador.

**Decisión 9b, preparada el 2026-10-02 (séptima autorización, punto 4): QA-023-10, separando tres cosas. NO autorizada. Ningún residual aceptado.**
1. **El incumplimiento de latencia medido.** CA-54 exige menos de 5 s en el máximo de análisis de `Bash` (131 072 bytes). El candidato no cumple en ninguna de las dos plataformas medidas:

   | Plataforma | Candidato | `9596e39` | Fuente |
   |---|---|---|---|
   | WSL2 (Linux) | 8,6–10,3 s (desarrollador) y 9,0–9,2 s (QA) | 2,9–7,2 s | `evidencia-dev-r6/38-`, `evidencia-qa-r6/25-` |
   | Windows/MSYS | **20,4–28,9 s**, en las 15 corridas | — (ver punto 2) | `sec-ca54-win/`, `c51c5c7` |

   En WSL2, la base ya incumplía en una de las tres formas. **El incumplimiento está medido y es concluyente en las dos plataformas.**
2. **El riesgo de agotar el tiempo límite y terminar sin decisión.** Es otra cosa, y es la clase de SEC-115 (ficha 1, no aceptada).
   - **En WSL2:** ninguna corrida se acerca a los 60 s, ni en el candidato ni en la base.
   - **En Windows/MSYS, en esta máquina y con una ejecución:** el candidato no llegó al límite (máximo 28,9 s, unas 2,1 veces de margen). **`9596e39` llegó al límite en las 15 corridas del caso máximo**, y un hook cortado así termina sin decisión.
   - **Lectura:** en estas condiciones, el candidato está más lejos del límite que la base. La base equivale a lo publicado en esta vía, aunque 1.33.2 no se midió en Windows. Eso **no** demuestra que el riesgo no exista: un equipo más lento o más cargado podría llegar al límite, y un margen de 2,1 veces no es una garantía. Tampoco convierte la latencia en aceptable.
3. **Las plataformas y condiciones realmente comprobadas.**
   - **WSL2:** Linux 6.18, bash 5.3.9 y jq 1.8.2, en varias corridas de la sonda de QA, de desarrollador y de QA.
   - **Windows:** 10.0.26200, PortableGit con bash 5.3.15, MSYS 3.6.9 y jq 1.8.2 nativo, con el hook invocado directamente, archivos en NTFS, una ejecución en una máquina y registro previo (`5510675`).
   - **No comprobado:** el cliente de Claude Code ejecutándose en Windows, otras máquinas, otras versiones de MSYS o Git Bash, Cygwin, y Windows bajo carga.
   - **Nada de esto valida Windows.**
- **Opciones** (sustituyen a las de 9b de arriba, que se conservan como historia):
  - **(A) Aceptar QA-023-10 como residual declarado de 1.35.0**: CA-54 incumplido, con la latencia de la tabla en las notas. Necesita que tú fijes el dueño, el forzador y el vencimiento. REQ-007 no se cierra.
    - **Consecuencia:** el análisis de `Bash` es más lento que en `9596e39` en Linux (2–3 veces). En Windows, en esta máquina, el candidato termina con decisión donde la base agotaba el tiempo. El riesgo de la ficha 1 sigue sin aceptar y aparte.
  - **(B) Retener la publicación hasta cumplir CA-54.**
    - **Consecuencia:** hace falta otra vuelta de diseño. La optimización conservada no bastaba ni en WSL2 (6,5–9,5 s), y en Windows la distancia es de 4 a 6 veces. Es trabajo del tamaño de una versión propia, y mientras tanto los proyectos siguen con la versión publicada.
  - **(C) Cambiar el contrato de CA-54**, por ejemplo bajando el máximo y el defecto o declarando la cifra por plataforma. **Es decisión exclusivamente tuya:** tu autorización me prohíbe reducir el máximo o subir umbrales.
    - **Consecuencia:** cambia, en todos los proyectos, qué comandos se deniegan por presupuesto.
- **Recomendación de la coordinadora:** **(A)**, si tú fijas sus condiciones.
  - **Por qué:** el incumplimiento es real, pero retener 1.35.0 por él dejaría a los proyectos con una base que, en esta medición de Windows, sí agotaba el tiempo en el caso máximo.
  - **Lo que (A) no hace:** no acepta que un timeout deje pasar la operación. Ese riesgo sigue en la ficha 1, sin aceptar.

**Decisión 10 — RESUELTA por el propietario el 2026-10-02 (octava autorización, § Resueltas): se reparan las dos caras de SEC-122, junto con QA-023-14 y P-023-13-A, en una intervención agrupada.** *Texto original, conservado:* SEC-122, registrado por seguridad en R-046.
- **Qué es:** una exclusión de ciertas rutas de sistema en la identificación del destino deja sin aplicar parte de CA-47 y CA-49 en casos concretos.
  - Una cara es **preexistente**.
  - La otra es una **regresión frente a 1.33.2, introducida por `104ffd1`** (la reparación de SEC-119, quinta autorización), y sólo afecta a proyectos situados bajo esas rutas.
  - No la introduce la séptima autorización.
  - Detalle y evidencia: `docs/seguridad/registro-seguridad.md` § R-046 y `cand-1.35.0/evidencia-seg-r7/` (`d7da950`).
- **Acción que impide (regla 2):**
  - **publicar**, a juicio del auditor, mientras no decidas;
  - **cerrar** REQ-007 (es `contrato`).
  - **Evidencia:** R-046.
  - **Qué lo resuelve:** tu decisión.
- **Opciones:**
  - **(A) Una vuelta acotada** que repare SEC-122 por la propiedad que fija R-046, con QA-023-14 dentro. **Lo recomiendan el auditor y la coordinadora.**
    - **Consecuencia:** otra vuelta corta: analista, desarrollador, QA y seguridad.
  - **(B) Declararlo como séptimo movimiento** y corregir F3, CA-49, CA-66 y las notas.
    - **Consecuencia:** 1.35.0 publicaría una regresión frente a 1.33.2, contra la línea que mantuviste en QA-023-09 y QA-023-13.
  - **(C) Retener la publicación** sin reparar.
- **Además:** P-119-A no puede presentarse con el texto actual de F3 hasta que el analista lo corrija (R-046).

**P-023-13-A — RESUELTA por el propietario el 2026-10-02 (octava autorización): se corrige el transporte del CR en el texto de los comandos de `Bash`, denegando explícitamente si no se puede preservar su significado.** *Texto original, conservado:* abierta por el analista el 2026-10-02; = QA-023-15, `instrumento`, preexistente en los cuatro árboles. El texto del comando de `Bash` sigue perdiendo un CR en el transporte, y eso queda fuera de esta reparación, porque excluiste reescribir el analizador de `Bash`. Está declarado en CA-47 punto 11 como límite conocido, no protegido y **no aceptado**.
- **Opciones:**
  - **(A) Declararlo fuera de la promesa de 1.35.0.**
  - **(B) Repararlo** en una vuelta propia.
  - **(C) Llevarlo con P-119-A.**
- **Recomendación del analista:** (A), sin que eso acepte nada.
- **Recomendación de la coordinadora:** decidirlo junto con la decisión 10. Si eliges una vuelta para SEC-122, que ésta valore si cabe dentro sin reescribir el analizador.

**QA-023-14** (`instrumento`, introducido por `3bc7d3c`; R-046 coincide): va con la **ficha 1**, como regresión de coste del candidato. Si se abre la vuelta de la decisión 10, se repara en ella.

**Decisión 11 — RESUELTA por el propietario el 2026-10-03 (§ Resueltas, entrada de esa fecha, texto literal): opción (B), con denegación por motivo explícito, sin eliminar caracteres ni juzgar un comando distinto, y aceptando la restricción de uso legítimo descrita en R-047 §3. La ejecución NO está autorizada todavía.** *Texto original, conservado:* **Decisión 11 — PENDIENTE (añadida el 2026-10-02): SEC-124, registrado por seguridad en R-047 sobre el delta de la octava autorización.**
- **Qué es:** un movimiento de deny a allow introducido por `9220c71` y no declarado. Está en el tratamiento del CR en un heredoc.
  - Medido como seguro por efecto en bash de Linux.
  - Descansa en una premisa no escrita sobre el shell.
  - Deja falsa la frase «siete clases, y sólo ésas» de CA-66 punto 5, de la nota de CA-24, de las notas `[1.35.0]` y de la guía.
  - Detalle: R-047 en `docs/seguridad/registro-seguridad.md`; evidencia en `cand-1.35.0/evidencia-seg-r8/` (`8837d3f`, `af2eddd`).
- **Acción que impide (regla 2):**
  - **publicar** con las notas actuales;
  - el **push y la corrida de CI** de esta intervención: la octava autorización los condiciona a que seguridad sea favorable para el delta;
  - **cerrar** REQ-007, que ya no cerraba.
  - **El presupuesto de la octava autorización está agotado:** se gastaron la implementación, QA, la pasada correctiva y su re-verificación.
- **Opciones:**
  - **(A) Write-back documental,** sin tocar código. Declara la clase por su propiedad y la premisa del shell, y después pasa por QA de texto y la determinación de seguridad. **Lo recomienda el auditor.**
  - **(B) Volver a denegar ese caso en código,** en una vuelta corta: desarrollador, QA y seguridad.
  - **(C) Retener la publicación.**
- **Recomendación de la coordinadora:** **(B).**
  - La premisa sobre el shell no está medida en Windows/MSYS, que es una plataforma donde se usa el arnés.
  - Volver al veredicto publicado cierra la clase sin depender de esa premisa.
  - Si prefieres no tocar código, (A) es coherente con la propiedad, siempre que la premisa quede escrita.

**Junto a esta decisión, registrados en R-047 (`instrumento`, no impiden por sí solos):**
- **SEC-123:** un límite ya declarado en F3 y en el punto 16 de CA-47, que está mal cuantificado y no dice que su consecuencia es un permiso. Es preexistente (1.33.2 también lo permite), y desde el host sólo se alcanza inyectando. P-119-A no puede presentarse sin corregir esos datos.
  - **Decidido por el propietario el 2026-10-03 (§ Resueltas):** corregir la descripción de F3, separando lo medido de lo inferido y declarando la consecuencia. **No** acepta el riesgo, **no** da por reparado el mecanismo y **no** resuelve P-119-A. Ejecución pendiente de autorización.
- **SEC-125:** preexistente y fuera del delta: una forma de escritura por `Bash` que el detector de escrituras no reconoce. No está declarada como límite.
  - **Opciones:** declararla en las notas (el mínimo que recomienda el auditor), o repararla en su propio vehículo.
  - **Decidido por el propietario el 2026-10-03 (§ Resueltas):** **reparar antes de publicar**; «una continuación de línea no demuestra por sí sola intención de evadir controles». Ejecución pendiente de autorización; el plan propone hacerlo en la misma comisión que SEC-124.

**Registrado, cerrado el 2026-09-30: QA-023-08** (`contrato`, baja, preexistente, contra REQ-007 CA-46 (b)). Lo cerró QA en la vuelta de la quinta autorización (`docs/qa/REQ-023.md` §9): CA-46 (b) está versionado y la puerta deniega todo `Edit`/`MultiEdit` sobre un REQ ilegible. *Texto original:* el criterio decía que con NUL en disco decide «la transición», y la puerta decidía si la edición menciona el estado terminal. Responsable: `analista-requerimientos` (write-back).

- **Recomendación de la coordinadora (propuesta, no decisión):**
  - **SEC-115 y C:** aplazarlos con esas fechas y publicar sus limitaciones en las notas de 1.35.0. SEC-115 tiene realismo bajo y un margen medido de más de 30× sobre los REQ reales; C no tiene reparación que quepa en esta versión sin ser otra versión.
  - **QA-023-02 / SEC-117:** es de severidad crítica y de realismo no bajo, pero preexistente y ajeno al alcance de 1.35.0. **El auditor (R-045 §3) recomienda lo mismo que la coordinadora:** publicarlo declarado y abrir su REQ de reparación de inmediato, como parche propio, con revisión el 2026-10-06. Motivo: el defecto ya está en 1.33.2 y en `v1.34.0`, que son las versiones instaladas, así que retener 1.35.0 no protege a nadie y deja vivo el bypass por variante que 1.35.0 cierra dentro de su frontera.
    - **Condiciones del auditor:** notas correctas y ficha 1 corregida (ya hecho aquí). Además, conviene ejecutar el lado del CLI en una sesión real antes de reparar.
    - **REQ-001:** el auditor recomienda añadir `SEC-117 (instrumento)` a su `Hallazgos abiertos:` sin tocar su `Estado:`. REQ-001 se reabriría por §9 cuando el REQ de reparación versione CA-10/CA-11. QA pide que tu decisión sobre esta ficha lo resuelva de forma expresa. **Registrarlas aquí no las convierte en riesgos aceptados.**
- **Espera (puesta al día 2026-10-03; manda sobre el párrafo histórico de debajo):**
  - **Estado:** `cand/1.35.0` local en `c0c8be2`, **sin push**; `origin` y el PR #59 (borrador) en `45368ce`, con CI `37032468437` en verde **sólo para `45368ce`**. La intervención de la octava autorización **terminó**: implementación, QA, pasada correctiva, re-verificación y seguridad R-047. **Su presupuesto está agotado** y su push y su CI siguen sin hacer, condicionados a una determinación de seguridad favorable al delta que SEC-124 impidió.
  - **Decidido el 2026-10-03 (§ Resueltas):** decisión 11 = (B); SEC-125 = reparar antes de publicar; SEC-123 = corregir la descripción de F3. **Ninguna de las tres autoriza ejecutar.**
  - **Pendiente del propietario, sin aceptar:** la **autorización de ejecución** de esas tres (plan en `propuesta-v1.35.0/plan-implementacion.md`); la **decisión 9b** (QA-023-10, CA-54); las **fichas 1** (SEC-115/SEC-118) y **2** (C); **P-119-A** (F2, F5, F7 y el límite de F3); **SEC-120** (vence el 2026-10-29).
  - **Trabajo que sigue mientras tanto:** ninguno de implementación ni de revisión. **Cerrar cualquier REQ** sigue impedido mientras esta entrada esté aquí.
- **Espera (texto anterior, conservado como historia):** decisión del propietario sobre las fichas 1 (SEC-115/SEC-118) y 2 (C), sobre **P-119-A** (REQ-007, «Preguntas abiertas») y sobre la **decisión 9b** (QA-023-10). La ficha 4 y la decisión 7 se resolvieron en la quinta autorización (2026-09-30). La decisión 8 (sexta autorización, 2026-10-01) cerró QA-023-09 y QA-023-11, y su vuelta terminó con QA no favorable por QA-023-13. La 9a (séptima autorización, 2026-10-02) abrió la vuelta que lo repara, en curso. La reparación de SEC-117 tiene QA favorable y seguridad aprobada (R-045-A, 2026-09-30), y SEC-117 quedó `mitigado`. La ficha 3 y la decisión 5 se resolvieron en la tercera autorización del 2026-09-29. La decisión 4 está resuelta y su corrección se hizo (`e7562e7`), con QA-023-05 cerrado. **Trabajo que sigue mientras tanto:** la vuelta de la séptima autorización (QA-023-13 y la preparación de la decisión 9b), que no depende de las fichas 1 y 2 ni de P-119-A. **Cerrar cualquier REQ queda pendiente** mientras esta entrada esté aquí.

### RESUELTA (propietario, 2026-10-03, novena autorización) — **Intervención excepcional en dos fases: fase 1 SEC-123 (corrección documental de F3), fase 2 SEC-124 (B) y SEC-125 (código, contrato y pruebas)**; analista → desarrollador → QA → seguridad con QA favorable; como máximo una pasada correctiva y su re-verificación; sin reiniciar contadores ni crear otro REQ; commits locales de trabajo validado; sin push

**Texto del propietario, literal e íntegro** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.35`, posterior al commit `fff53f4`):

> Continuemos con la reparación defensiva de `JJOVEGA/ArnesJuan`, candidato v1.35.0.
>
> ## Base y comprobación inicial
> Worktree `/home/juan/dev/ArnesJuan-v1.35`, rama `cand/1.35.0`, cabeza local
> reportada `fff53f4` sobre `c0c8be2`. Antes de cualquier cambio: `git status`,
> `git log -1`, confirma cabeza y rama, y conserva intactos los archivos sin
> seguimiento de `propuesta-v1.35.0/` (README.md, SEC-047.diff, evidencia/).
> No los añadas al índice.
>
> Instrucciones normativas: CLAUDE.md → AGENTS.md de ESTE worktree. No uses
> `rel/registro-1.33.0` como normativa.
>
> Lee antes de despachar: PENDING_APPROVAL.md (decisiones del 3 de octubre),
> docs/ESTADO.md (bloque vigente), propuesta-v1.35.0/TRASPASO.md y
> plan-implementacion.md, docs/seguridad/registro-seguridad.md R-047 §2, §3 y §4,
> requirements/REQ-007.md (CA-47 p.17, CA-66 p.5), ADR-016, notas [1.35.0] y los
> criterios afectados de REQ-001, REQ-023 y REQ-031.
>
> ## Decisiones del propietario ya registradas (no reabrir)
> - SEC-124: opción B. Denegación explícita del caso delimitado en R-047 §3.
>   No se eliminan caracteres en silencio, no se modifica el comando, no se
>   juzga ningún otro comando. Se acepta sólo la restricción concreta del uso
>   legítimo allí descrito.
> - SEC-125: reparar antes de publicar. Una continuación de línea por sí sola
>   no demuestra intención de evadir.
> - SEC-123: corregir la descripción de F3. El riesgo NO está aceptado y el
>   mecanismo NO está reparado.
>
> ## Autorización: novena intervención, excepcional
> Analista → desarrollador → QA → seguridad si QA es favorable. Como máximo una
> pasada correctiva y su re-verificación. Regístrala como excepción en la sede
> que exige el repositorio, sin reiniciar contadores ni crear otro REQ.
>
> El analista fija el comportamiento esperado y los criterios de aceptación; el
> desarrollador elige la técnica. No se exige diseño exhaustivo previo, pero cada
> cambio debe tener un resultado verificable. Resuelve sin consultarme los ajustes
> ordinarios de código, pruebas, contrato y trazabilidad dentro del alcance.
> Reutiliza firmas y evidencia vigentes; revisa sólo lo afectado y sus
> dependencias.
>
> ## Alcance en dos fases secuenciales, con commit local por fase validada
>
> ### Fase 1 — SEC-123 (documental, independiente)
> Corregir la descripción de F3 en REQ-007, ADR-016 y las notas [1.35.0]:
> - separar lo medido de lo inferido; lo medido son cuatro componentes de subida
>   desde una raíz de proyecto a cinco o más niveles de profundidad; permiso
>   indebido y efecto en disco medidos en hook y shell, no ejercidos en el host;
> - declarar la consecuencia operativa;
> - mantener F3 dentro de P-119-A como pendiente; ninguna redacción puede leerse
>   como "reparado", "mitigado" ni "riesgo aceptado".
> Verificación: revisión de QA documental y seguridad sobre coherencia entre las
> tres sedes. Commit local al validar. Esta fase se ejecuta completa antes de
> empezar la fase 2 y no depende de ella.
>
> ### Fase 2 — SEC-124 y SEC-125 (código, contrato y pruebas)
> Orden propuesto: SEC-124 y después SEC-125, porque SEC-125 debe preservar las
> reglas de comillas, CR y heredocs que SEC-124 toca. Si el desarrollador
> justifica invertirlo, que lo registre; en cualquier orden, la segunda
> reparación corre la regresión de la primera.
>
> Propiedades SEC-124 (sede: analizador de heredocs en hooks/lib.sh; sección 45
> del banco; REQ-007 CA-47 p.17 y CA-66 p.5; notas y referencias afectadas):
> - P1. El caso delimitado en R-047 §3 recibe DENY con motivo explícito que
>   identifica SEC-124.
> - P2. El texto del comando no se altera, sanea ni reescribe en ningún camino.
> - P3. Ningún otro caso de la sección 45 ni del banco cambia de decisión.
> - P4. El contrato describe la denegación como restricción concreta de ese caso,
>   no como regla general sobre heredocs ni CR.
> - P5. Windows: no medido para este delta. Declararlo; no afirmar cobertura.
>
> Propiedades SEC-125 (sede: reconocimiento de destinos de escritura; evidencia
> en R-047 §4; precedente en guard-git sólo como referencia a comprobar):
> - P6. Un destino de escritura que sería denegado sin la continuación de línea
>   descrita en R-047 §4 se deniega también con ella.
> - P7. El significado del comando se preserva: no se elimina la continuación
>   si eso cambia la semántica; no hay DENY por la mera presencia de una
>   continuación.
> - P8. Se preservan las reglas vigentes de comillas, CR y heredocs: regresión
>   obligatoria de los casos SEC-047, SEC-119 y SEC-122 y de la sección 45.
> - P9. No se copia la lógica de guard-git sin comprobar P7 y P8; si se reutiliza,
>   registrar qué se comprobó.
> - P10. Cobertura declarada por capa: hook directo, shell aparte, CLI real si
>   está disponible, extensión no. Sin medición del host, decirlo.
>
> ## Manejo del contenido técnico sensible
> - Los agentes referencian R-047 §3 y §4 por sección. No reproducen ni
>   reescriben las condiciones de explotación en documentos nuevos.
> - Los casos de prueba se construyen reutilizando la evidencia existente
>   (rama evidencia/prueba-despacho-2026-09-14, cand-1.35.0/evidencia-seg-r8/,
>   baterías t2–t5) por copia o referencia. No se redactan catálogos nuevos de
>   variantes.
> - Si un control del proveedor detiene una acción: no reintentar por vía
>   indirecta, no delegar ese contenido, no cambiar de modelo ni de
>   configuración. Registrar el impedimento en el bloque manual de
>   docs/ESTADO.md y continuar con el siguiente elemento independiente de la
>   lista: fase 1 completa; dentro de la fase 2, la reparación no bloqueada y
>   sus pruebas; regresiones y banco sobre lo que sí cambió. No declarar
>   reparado nada cuya validación quedó pendiente.
>
> ## Validación
> Por reparación: pruebas aisladas del caso, controles legítimos (lo que debe
> seguir permitido) y regresiones afectadas. Sobre la cabeza final: banco
> completo y gates exigidos. Conservar todo FAIL con su cabeza y entorno; un
> SKIP o INCONCLUSO no acredita. Distinguir hook directo, shell aparte, CLI
> real y extensión.
>
> ## Límites
> Fuera de alcance y sin aceptar: CA-54 / QA-023-10, SEC-115, SEC-118, hueco C,
> SEC-120, F2/F5/F7 de P-119-A, coste de normalización en Windows, integración
> VS Code. No subir umbrales ni reducir límites de entrada. No cambiar contrato
> para acomodar un resultado. Defectos nuevos independientes: registrar sin
> encadenar reparaciones. Nada en AGENTS.md.
> Autorizo commits locales de trabajo validado. No autorizo push, CI remoto,
> fusión, cierre de requisitos, tags, publicación ni cambios en SENDA, Adelantos
> o demo-conciliador.
>
> ## Entrega
> Un único resumen: cabeza final; cambios por fase con archivos; evidencia de
> funcionamiento por capa; cobertura de QA y seguridad con firmas y su delta;
> impedimentos registrados; pendientes concretos. Si el presupuesto o un control
> impiden terminar, conserva el trabajo validado y di exactamente qué quedó
> incompleto y por qué.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Base comprobada antes de editar (2026-10-03):** `cand/1.35.0` en `fff53f4`. En el árbol: `M docs/ESTADO.md` (la línea del impedimento anterior y el bloque derivado) y, sin seguimiento, `propuesta-v1.35.0/README.md`, `SEC-047.diff` y `evidencia/`, que no se añaden al índice.
- **Contadores:** no se reinicia ninguno y no se crea ningún REQ. El de REQ-023 sigue agotado (3 de 3). Todo el trabajo es de REQ-007.
- **Orden, en serie:**
  - **Fase 1:** analista (F3) → QA documental (Opus, §5) → seguridad documental → commit local.
  - **Fase 2:** analista (contrato) → desarrollador → QA (Opus) → como mucho una pasada correctiva y su re-verificación → seguridad con QA favorable → commit local.
- **Precisión que la coordinadora pasa al analista:** el resumen de la fase 1 («cuatro componentes de subida desde una raíz de proyecto a cinco o más niveles») no coincide palabra por palabra con R-047 §2. R-047 midió con la raíz a siete niveles, con permiso a cuatro, cinco y seis subidas, y declara que la exigencia de una raíz a cinco o más niveles se sigue de su análisis. Como el propio encargo pide separar lo medido de lo inferido, el analista escribe lo que R-047 midió y lo registra como precisión en la «Correspondencia con el encargo», sin cambiar el pedido.
- **Resuelve:** la autorización de ejecución pendiente de las decisiones del 2026-10-03. **Siguen pendientes y sin aceptar:** CA-54 (9b), SEC-115/118 (ficha 1), C (ficha 2), F2/F5/F7 (P-119-A) y SEC-120.
- **Aclaración del propietario, 2026-10-03, durante la fase 1** (pregunta de la coordinadora y respuesta elegida, literales). La revisión documental de QA de la fase 1 salió con hallazgos (QA-023-18, `contrato`, baja; `docs/qa/REQ-023.md`). Pregunta: «QA-023-18 (contrato, baja; F3 presenta como medida una generalización inferida) exige una pasada correctiva en la fase 1. Tu autorización dice «como máximo una pasada correctiva y su re-verificación». ¿Cómo se cuenta?». **Respuesta: «Una por fase (Recomendado)»**, cuya descripción decía: «La gasto ahora en QA-023-18 (analista corrige, QA re-verifica, seguridad documental, commit de la fase 1) y la fase 2 conserva su propia pasada». **Contador:** la fase 1 gasta su única pasada correctiva en QA-023-18, y la fase 2 conserva la suya.
- **Decisiones del propietario, 2026-10-03, durante la fase 2, sobre el contrato del analista** (preguntas de la coordinadora y respuestas elegidas, literales; contrato en REQ-007 CA-47 puntos 18 y 19 y CA-66, versionado de la fase 2):
  - Pregunta: «SEC-124 (B): para cumplir P1, P2 y «no se juzga ningún otro comando», el analista fija la denegación POR LA FORMA del caso de R-047 §3, a todo agente (también el desarrollador) y aunque lo que sigue sea inocuo (HC5, HC6). Lo publicado sólo denegaba cuando lo que seguía era una escritura protegida, así que esto deniega algo más que lo publicado. ¿Lo aceptas?». **Respuesta: «Sí, por la forma (Recomendado)»**.
  - Pregunta: «SEC-125: preservar el significado (P7) hace que un caso que lo publicado denegaba sólo porque el trozo previo a la continuación casaba con el ámbito pase a permitirse, porque el destino real, una vez unido, está fuera (LC8). Es un movimiento deny→allow nuevo, seguro por efecto. ¿Lo aceptas?». **Respuesta: «Sí, declarado (Recomendado)»**.
  - **Efecto:** la frontera de SEC-124 (por la forma y a todo agente) y la clase LC8 de SEC-125 (deny→allow declarado) quedan confirmadas por el propietario. Ya no son sólo una precisión del analista.
- **Autorización del propietario, 2026-10-03, posterior a `c4ad408` (literal, la tarea del mensaje):**

  > ## Tarea única — completar el contrato con el caso (b)
  > Autorizo al analista a escribir UN caso en CA-66: la continuación de línea al
  > final de la línea que abre un heredoc. Debe fijar el comportamiento esperado
  > en las cuatro puertas, coherente con los puntos 18 y 19 de CA-47 y con la
  > decisión registrada sobre SEC-124 (denegar por la forma, a todo agente). Sin
  > cambiar ningún otro caso HC/LC ni ningún otro criterio. Actualiza sólo las
  > sedes que ese caso obliga a tocar (ADR-016, notas e índice si procede).
  >
  > Después, QA mide ese caso sobre el código vigente sin modificarlo: hook
  > directo y shell aparte, con cabeza, entorno y capa. Si contradice el
  > contrato, se registra como hallazgo sin reparar ni ajustar el contrato.
  >
  > Commit local al terminar, marcado SIN VALIDAR, con trazabilidad en ESTADO y
  > docs/qa/REQ-023.md. El caso (a), pliegue de guard-git ante barra escapada,
  > queda registrado como no medido y fuera de esta versión.

  **Lo que no hace, según el mismo mensaje:** no se despacha al desarrollador, no se implementan SEC-124 ni SEC-125, y no se tocan SEC-126, los no aceptados, `AGENTS.md` ni los contadores.
- **Decisiones del propietario, 2026-10-03, posteriores a `598792c` (literales):**

  > 1. P-LC10-A: opción A. La forma de LC10 (continuación de línea al final de la
  >    línea que abre un heredoc) se deniega por la forma, a todo agente, en las
  >    cuatro puertas, igual que SEC-124. Acepto que eso restrinja un uso legítimo
  >    raro. No se emula la unión de líneas del shell (B rechazada); no se deja
  >    QA-023-23 abierto en esta forma (C rechazada).
  > 2. QA-023-23: se registra en `Hallazgos abiertos:` de REQ-007 y en el registro
  >    de seguridad como hallazgo preexistente de clase instrumento. La forma de
  >    LC10 lo cierra; cualquier otra forma que lo exhiba sigue abierta y sin
  >    aceptar.

  **Tarea del mismo mensaje (literal):** «El analista ajusta el punto 19 de CA-47 y LC10 en CA-66 para reflejar A: denegación por la forma, a todo agente, con motivo que identifique SEC-125 y LC10, en guard-codigo, guard-completado, guard.sh y guard-git. El caso que hoy es "falso positivo" (la línea siguiente cierra el heredoc) queda cubierto por la misma denegación; declararlo. Sin tocar HC1–HC9 ni LC1–LC9 salvo referencias cruzadas. Actualiza ADR-016, notas, guía e índice sólo en lo que esta decisión obliga. Registra QA-023-23 donde indica la decisión 2, con su estado y la referencia a la medición de docs/qa/REQ-023.md. QA revisa la coherencia del contrato ajustado (documental; no hace falta volver a medir: la medición sobre c4ad408 sigue vigente como fail-before). Commit local al terminar, SIN VALIDAR, con trazabilidad en ESTADO.»

  **Lo que añade la coordinadora, rotulado como suyo:** cada sede tiene su dueño según `AGENTS.md` §5. El analista escribe el contrato. QA anota su propio hallazgo QA-023-23 en `Hallazgos abiertos:` de REQ-007, como en las vueltas anteriores. El `auditor-seguridad`, que mantiene `docs/seguridad/`, lo anota en el registro de seguridad: sólo el registro, sin revisión ni firma.
- **Decisiones del propietario, 2026-10-03, posteriores a `3158bf9` (literales; registradas sin despachar a ningún agente):**

  > 1. QA-023-25: precedencia de REQ-001 CA-53. Un comando que supera el
  >    presupuesto se deniega sin analizar con el motivo de CA-53; el motivo
  >    SEC-125/LC10 sólo aplica a denegaciones producidas por el análisis. El
  >    texto del punto 19 y de LC10 se ajusta en ese sentido.
  > 2. QA-023-24: corregir el punto 5 de CA-66 y las notas para reflejar que la
  >    forma ya se denegaba hoy cuando la escritura o la orden de git están en
  >    la propia línea, no sólo en LC10.8.
  > 3. Ambas correcciones de texto las aplica el propietario en el tramo de
  >    implementación manual, junto con el código. La única pasada correctiva de
  >    la fase 2 se reserva para el código. QA verifica texto y código juntos.
  > 4. La precisión declarada sobre guard-codigo y guard-git en LC10 se mantiene
  >    tal como está.

  **Lo que añade la coordinadora, rotulado como suyo:**
  - **Quién edita:** con la decisión 3, las correcciones de texto de REQ-007 (puntos 19 y LC10, punto 5 de CA-66) y de las notas las hace el propietario, no el `analista-requerimientos`. Es una excepción expresa a quién transcribe por §9.
  - **La pasada correctiva de la fase 2** queda sin gastar y reservada para el código.
  - **QA-023-24 y QA-023-25** siguen abiertos hasta que QA verifique el texto y el código juntos. Siguen fuera de `Hallazgos abiertos:`, como el precedente de QA-023-18.
  - **Nada cambia hoy** en REQ-007 ni en el código.
- **Decisión del propietario, 2026-10-03, posterior a `093e81e` (literal, la parte de la decisión):**

  > Autorizo un despacho al desarrollador para implementar SEC-124 y SEC-125
  > sobre el contrato ya comiteado. Es una autorización nueva sobre un estado
  > distinto al del impedimento anterior: el contrato está completo en el
  > repositorio y las decisiones P-LC10-A, QA-023-24 y QA-023-25 están
  > registradas. Si un control del proveedor detiene este despacho, se registra
  > en ESTADO y la implementación vuelve a manual, sin reintentos ni
  > reformulaciones.

  **Lo que hace la coordinadora, rotulado como suyo: el despacho NO se ejecuta.**
  - El control del proveedor ya detuvo antes este mismo despacho al `desarrollador` para implementar SEC-124 y SEC-125, y la instrucción que acompaña a ese bloqueo prohíbe volver a producirlo, también reformulado.
  - Un despacho nuevo con el mismo objetivo lo sería, aunque sólo remita a las sedes. Una autorización del propietario no levanta esa restricción.
  - Por la propia regla de esta decisión («sin reintentos ni reformulaciones»), **la implementación sigue siendo manual**.
  - No se despachó a nadie, y no cambian el código, REQ-007 ni los contadores. La pasada correctiva de la fase 2 sigue sin gastar.

- **Decisión del propietario, 2026-10-03, posterior a `92ec1fa` (literal; registrada por el propietario):**

  > 1. Validación del delta de la fase 2 por vía manual. Un control del proveedor
  >    detuvo al qa-tester al leer el diff de hooks/; no se reintenta ni se
  >    reformula. La validación la ejecuto yo con el protocolo de QA de CA-66
  >    fase 2 (gates, sección 46, regresiones, fail-before, banco, autoprueba y
  >    shell aparte), con una segunda medición de un revisor externo (Fable,
  >    Claude en claude.ai) sobre un clon, y con el CI remoto sobre la misma
  >    cabeza (run 37163342218: success). Registro en docs/qa/REQ-023.md.
  > 2. Sin firma del qa-tester ni del auditor-seguridad, y así se declara.
  >    QA: y Seguridad: de REQ-007 siguen pendiente. SEC-124 y SEC-125 se
  >    declaran reparados en su alcance; QA-023-23 cerrado en la forma de LC10 y
  >    abierto en cualquier otra; QA-023-24 y QA-023-25 cerrados por esta
  >    validación.
  > 3. El impedimento del proveedor de la novena autorización fue sobre el
  >    contenido del despacho de SEC-124/125 y sobre la lectura de su diff; no
  >    sobre los roles. Los encargos siguientes se redactan por propiedad y
  >    medida.
  > 4. La pasada correctiva de la fase 2 no se gastó.

  **Encargo del propietario, 2026-10-03, posterior a `ddd1241` (literal, la parte del despacho):**

  > ## Despacho: analista-requerimientos (sólo texto)
  > Write-back de estado en REQ-007, ADR-016, notas [1.35.0] del CHANGELOG, guía
  > (skills/arnes-upgrade/SKILL.md) e índice (requirements/README.md):
  > - Puntos 18 y 19 de CA-47 y CA-66 fase 2: de «pendiente de implementación y
  >   de validación» a «construido en 10ac6c4 y 36a0d27; validado por el
  >   propietario por vía manual (docs/qa/REQ-023.md, CI run 37163342218); sin
  >   firma del qa-tester ni del auditor-seguridad por impedimento del
  >   proveedor». Ni más ni menos que eso: no «aprobado», no «validado por QA».
  > - Hallazgos abiertos de REQ-007: SEC-124 y SEC-125 pasan a «reparado en su
  >   alcance (validación manual del propietario)»; QA-023-23 «cerrado en la
  >   forma de LC10; abierto en cualquier otra»; QA-023-24 y QA-023-25 cerrados
  >   por esa validación. QA: y Seguridad: de REQ-007 siguen `pendiente`.
  > - Registro de seguridad: entrada de sólo registro (R-050) que remite a la
  >   validación manual, sin firma del auditor.
  > - Las frases «Hasta que esté construido y validado, el candidato deja pasar
  >   esa forma» de las notas pasan a describir el estado construido.
  > Nada de nuevos hallazgos ni cambios de contrato. Commit local con CHANGELOG.

  **Lo que añade la coordinadora, rotulado como suyo:** por esta instrucción expresa del propietario, la entrada R-050 la escribe el `analista-requerimientos`, aunque `docs/seguridad/` es sede del `auditor-seguridad` (`AGENTS.md` §5). La entrada es **sólo de registro** y no lleva firma. Lo mismo vale para el cambio de estado de SEC-124 y SEC-125 en `Hallazgos abiertos:`.

### RESUELTA (propietario, 2026-10-03) — **Decisión 11 (SEC-124): opción B; SEC-125: reparar antes de publicar; SEC-123: corregir la descripción de F3**; autoriza sólo una actualización documental de continuidad y plan; **no autoriza implementación ni despachos**

**Texto del propietario, literal e íntegro** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.35`; es la fuente de estas decisiones, por declaración del propio mensaje):

> Autorizo una única actualización documental para dejar coherente la continuidad de v1.35.0 y preparar la siguiente ejecución. No autoriza modificar código ni despachar todavía al desarrollador, QA o seguridad.
>
> **Base**
>
> Trabaja en `/home/juan/dev/ArnesJuan-v1.35`, rama `cand/1.35.0`, cabeza reportada `c0c8be2`. El PR #59 y el remoto siguen en `45368ce`; su CI no acredita la cabeza local.
>
> Conserva los cambios preexistentes. No cambies de rama ni uses instrucciones de otro worktree.
>
> **1. Registra estas decisiones; este mensaje es su fuente**
>
> Yo, Juan Vega, el 2026-10-03, confirmo:
>
> - **SEC-124: opción B.** Restaurar la denegación mediante un motivo explícito para el caso descrito en R-047 §3, sin eliminar silenciosamente caracteres ni juzgar un comando distinto. Acepto la restricción concreta de uso legítimo descrita en ese informe.
> - **SEC-125: reparar antes de publicar.** Una continuación de línea no demuestra por sí sola intención de evadir controles.
> - **SEC-123: corregir la descripción de F3**, separando lo medido de lo inferido y declarando la consecuencia. No acepto el riesgo ni doy por reparado el mecanismo.
>
> Conserva una copia literal de estas decisiones en la sede vigente de `PENDING_APPROVAL.md`, identificando este mensaje y su fecha. Referénciala desde el plan, sin reconstruir mensajes anteriores.
>
> Resuelve únicamente las preguntas que estas elecciones contestan. La ejecución, los demás riesgos y la publicación siguen pendientes.
>
> **2. Corrige la continuidad**
>
> Actualiza las partes manuales de `docs/ESTADO.md` y el cierre «Espera» de la cola:
>
> - cabeza local y remota;
> - intervención terminada y presupuesto agotado;
> - decisiones ya tomadas;
> - siguiente paso real.
>
> Elimina las contradicciones entre bloques vigentes conservando el historial como historial. No edites manualmente el bloque derivado ni borres cambios ajenos.
>
> **3. Completa el plan al nivel necesario para encargar el trabajo**
>
> En `propuesta-v1.35.0/plan-implementacion.md`:
>
> - Sustituye el diseño técnico obligatorio por las propiedades que deben cumplirse, las restricciones y las dependencias. La técnica de implementación corresponde al desarrollador.
> - Completa la validación prevista con resultados esperados, controles legítimos y referencias a los casos existentes de R-047. No hace falta copiar reproducciones ejecutables.
> - Incluye ambas reparaciones en una misma comisión propuesta del desarrollador y la corrección documental de F3.
> - Define los archivos y contratos afectados, la evidencia reutilizable, las condiciones de salida y la condición de parada.
> - Propón el presupuesto de comisiones y pasadas correctivas sin reiniciar contadores.
> - Distingue la comprobación pendiente en el CLI dentro de WSL de la integración con la extensión de VS Code.
>
> Conserva las propuestas históricas de SEC-047 del 29 de septiembre. Identifica su fecha y carácter histórico desde el plan; no las mezcles con el alcance actual ni las reescribas.
>
> Si el documento queda completo para decidir la ejecución, cambia su aviso a **«Plan propuesto completo; implementación pendiente de autorización»**. Si falta una parte esencial, conserva el aviso de incompleto y nombra el impedimento.
>
> **4. Límites**
>
> No aceptes CA-54, SEC-115/118, el hueco C, SEC-120 ni las fronteras restantes de P-119-A. No cambies criterios normativos, estados de requisitos, veredictos ni contadores en esta intervención.
>
> Reutiliza la evidencia existente: sin pruebas, mediciones, auditorías generales ni nuevas comisiones. Si las reglas vigentes exigen un rol específico para alguna edición, identifica esa dependencia sin asumir sus facultades.
>
> La pausa de seguridad de la sesión anterior sigue siendo un impedimento registrado. No intentes reproducir contenido bloqueado ni sortear controles. Completa sólo las partes permitidas y declara cualquier limitación restante.
>
> **Entrega**
>
> Un resumen breve con:
> - documentos actualizados;
> - decisiones registradas y fuente;
> - orden de implementación;
> - presupuesto propuesto;
> - autorización concreta que faltaría para ejecutar.
>
> Sin commits, push, CI, fusión, cierre de requisitos, tags, publicación ni cambios en consumidores. No habilites conectores: no son necesarios para este encargo.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Base comprobada antes de editar (2026-10-03):** worktree `/home/juan/dev/ArnesJuan-v1.35`, rama `cand/1.35.0` en `c0c8be2`, 8 commits por delante de `origin/cand/1.35.0`. `origin` y el PR #59 (borrador) están en `45368ce`, comprobado con `git ls-remote` y `gh pr view`; su CI `37032468437` es de `45368ce` y **no acredita `c0c8be2`**. En el árbol, sólo lo preexistente: `M docs/ESTADO.md` y `?? propuesta-v1.35.0/`. Instrucciones: el `AGENTS.md` de este worktree.
- **Qué resuelve, y sólo eso:**
  - **Decisión 11 (SEC-124):** opción (B). Se elige entre las opciones de la entrada pendiente; R-047 §3 recomendaba (A) y objetaba a (B) que «juzgaría una estructura distinta de la que ejecuta el shell». La forma que fija el propietario —denegación con **motivo explícito**, **sin** eliminar caracteres **ni** juzgar un comando distinto— es la que responde a esa objeción, y el plan la escribe como propiedad.
  - **SEC-125:** de las dos opciones de R-047 §4 (declarar en las notas, o reparar en su propio vehículo), **reparar antes de publicar**. Meter la reparación en la misma comisión que SEC-124 es una **propuesta** del plan, pedida en el punto 3 de este mensaje, no una autorización.
  - **SEC-123:** corregir la descripción de F3 (CA-47 F3 y punto 16, adenda de ADR-016, notas, descripción de P-119-A). **No** acepta el riesgo, **no** da por reparado el mecanismo y **no** resuelve P-119-A, que sigue pendiente (F2, F5, F7 y el límite de F3).
- **Qué NO resuelve:** la ejecución (ninguna comisión autorizada; el presupuesto de la octava autorización está agotado), CA-54 (9b), SEC-115/118 (ficha 1), el hueco C (ficha 2), P-119-A, SEC-120 y la publicación. **Ningún residual queda aceptado.**
- **Qué no cambia esta entrada:** ningún criterio, estado, veredicto, campo `Hallazgos abiertos:` ni contador. SEC-123, SEC-124 y SEC-125 siguen `abierto` en REQ-007 hasta que se reparen o corrijan y se verifiquen. El de REQ-023 sigue agotado (3 de 3).
- **Dependencias de rol para ejecutarlo:** el contrato y el write-back (§9) son del `analista-requerimientos`, porque §6 de este `AGENTS.md` no declara la vía proporcional; el código de `hooks/` es sólo del `desarrollador`; después QA (Opus, §5) y seguridad con QA favorable. Plan: `propuesta-v1.35.0/plan-implementacion.md`.

### RESUELTA (propietario, 2026-10-02, octava autorización) — **Reparación agrupada de SEC-122 (ambas caras), QA-023-14, P-023-13-A / QA-023-15 y la corrección de F3**; intervención excepcional agrupada sin reiniciar contadores, con una pasada correctiva dentro del alcance; texto de plataformas autorizado

**Texto del propietario, literal e íntegro** (mensaje del 2026-10-02 a la sesión coordinadora del worktree `ArnesJuan-v1.35`):

> Autorizo la reparación agrupada de **SEC-122, ambas caras; QA-023-14; P-023-13-A / QA-023-15; y la corrección contractual de F3 directamente relacionada**.
>
> El objetivo es preparar v1.35.0 para publicar, cerrando estos problemas de identificación de rutas y transporte de entradas, sin abrir una reparación general del arnés.
>
> **1. Base y conservación**
>
> Trabaja en `cand/1.35.0`, partiendo de la cabeza reportada `45368ce`, PR #59. Comprueba la cabeza real y las instrucciones del worktree antes de modificar.
>
> Conserva los cambios preexistentes de `docs/ESTADO.md`, `propuesta-v1.35.0/`, las evidencias y todas las corridas anteriores. No recuperes la optimización descartada de CA-54.
>
> **2. Reparación autorizada**
>
> - **SEC-122:** elimina la exclusión indiscriminada de `/dev/` y `/proc/`. Los destinos resolubles por nombres deben pasar por la identificación y las reglas de protección correspondientes, conservando las comprobaciones de existencia y enlaces. Una identidad dependiente del proceso que no pueda determinarse de forma fiable no recibe permiso por esa incertidumbre. Conserva los usos legítimos previstos de `/dev/null` y `/dev/stderr` sin convertir sus nombres en una excepción general.
> - **QA-023-14:** elimina la sustitución superlineal introducida en `_arnes_repone_cr`. Puedes usar la detección en la lectura con `jq` propuesta, conservando íntegros los valores y las decisiones de protección. No sustituyas este coste por otra pasada superlineal.
> - **P-023-13-A:** corrige el transporte del CR en el texto de comandos Bash. Si el análisis no puede preservar su significado, deniega explícitamente; nunca lo elimines silenciosamente para juzgar un comando distinto. No reescribas el analizador general de Bash.
> - **Contrato:** el analista actualiza F3, CA-49, CA-66 punto 5 y las sedes directamente afectadas. F3 no debe desactivar las reglas de existencia, enlaces ni protección de destinos resolubles. Conserva el historial y declara los cambios de compatibilidad.
>
> **3. Autonomía y presupuesto**
>
> Autorizo una intervención excepcional agrupada, registrada sin reiniciar contadores: implementación, revisión de QA y, si aparecen defectos dentro de este mismo alcance, una pasada correctiva con su re-verificación de QA.
>
> No me pidas otra autorización por cada ajuste de código, fixture o texto directamente necesario para cumplir estas propiedades. Las decisiones técnicas ordinarias quedan delegadas dentro de este alcance.
>
> Después, seguridad revisa el delta cuando QA sea favorable. No abras más vueltas automáticamente ni incluyas defectos independientes. Si se agota este presupuesto, entrega el impedimento concreto y conserva el trabajo.
>
> **4. Validación proporcional**
>
> Reutiliza la evidencia vigente. Comprueba:
>
> - Las dos caras de SEC-122, con las dos puertas y controles legítimos.
> - El caso de CR en comandos Bash y la conservación de las reparaciones de LF/CR ya acreditadas.
> - Los casos relacionados de SEC-117 y SEC-119 que puedan verse afectados.
> - El coste de QA-023-14 con los tamaños ya usados, bajo un procedimiento fijado antes y sin repetir hasta obtener una cifra favorable.
> - Las secciones 41 a 44 y un banco completo sobre el código candidato final. Repite sólo lo necesario para verificar una corrección concreta o cumplir un gate vigente.
>
> Distingue decisión del hook, efecto en disco y comportamiento del host. No atribuyas al host lo que sólo se inyectó al hook.
>
> Mi entorno es VS Code con WSL. Conserva separadas las pruebas del CLI dentro de WSL y las de la extensión. Esta intervención no incluye una campaña nueva de plataformas ni instalar entornos. Si un control de seguridad impide una prueba, registra la limitación sin intentar rodearlo.
>
> **5. Plataformas y alcance de las conclusiones**
>
> Autorizo registrar el texto de plataformas propuesto, limitado a los casos realmente ejecutados:
>
> - Hook en Linux/WSL2.
> - CLI 2.1.285 en WSL2 mediante `claude -p`.
> - Hook en Windows/MSYS, en una máquina.
> - Sin comprobación de la extensión de VS Code, del CLI en Windows ni de otros clientes.
>
> Esto describe dónde se ejecutaron los casos; no acredita toda la plataforma ni todos sus comportamientos.
>
> La reparación agrupada tampoco garantiza por sí sola que el candidato quede publicable. CA-54, SEC-115/118, el hueco C y las fronteras restantes conservan sus decisiones pendientes.
>
> **6. Decisiones que siguen sin autorizarse**
>
> Esta autorización no acepta:
>
> - El incumplimiento de los 5 segundos de CA-54.
> - SEC-115 ni SEC-118.
> - El hueco C de escrituras mediante intérpretes.
> - F2, F5 ni F7 de P-119-A.
> - SEC-120 ni otros defectos independientes.
>
> No subas umbrales, no reduzcas límites de entrada y no conviertas un timeout sin decisión en un riesgo aceptado. La reparación de QA-023-14 no acredita por sí sola el cumplimiento de CA-54.
>
> **7. Entrega y PR**
>
> Autorizo los commits de esta intervención. Cuando QA y seguridad sean favorables para el delta autorizado, actualiza el PR #59 mediante push sin force y observa una sola corrida de CI sobre la cabeza final. Conserva el resultado; no relances para buscar verde.
>
> Entrega un único resumen con:
>
> - Cabeza final y alcance real del cambio.
> - Resultado antes/después de los tres problemas.
> - Mediciones de coste y sus límites.
> - Cobertura exacta de QA, seguridad y host.
> - Una lista consolidada de decisiones pendientes para publicar, sin duplicados.
>
> Si un hallazgo ajeno al alcance impide alguna firma, explica esa dependencia sin repararlo ni ocultarlo. Las firmas del delta no deben presentarse como aprobación completa del candidato si quedan impedimentos.
>
> No cierres requisitos, fusiones, crees tags, publiques ni actualices instalaciones o consumidores. No toques los PR #54, #57 ni #45.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Base comprobada antes de editar (2026-10-02):** `cand/1.35.0` local = `origin` = PR #59 = `45368ce`, en borrador. En el árbol, sólo los cambios preexistentes: `docs/ESTADO.md` y `propuesta-v1.35.0/`.
- **Contadores:** el de REQ-023 sigue agotado (3 de 3); no se reinicia ninguno y no se crea ningún REQ.
- **Orden, en serie (todo es REQ-007):** desarrollador → analista → QA (Opus, §5), con como mucho una pasada correctiva y su re-verificación → seguridad con QA favorable → push y una sola corrida de CI.
- **Resuelve:** la decisión 10 (SEC-122) y P-023-13-A, en reparación. **Siguen pendientes y sin aceptar:** CA-54 (9b), SEC-115/118 (ficha 1), C (ficha 2), F2/F5/F7 (P-119-A) y SEC-120.

### RESUELTA (propietario, 2026-10-02, séptima autorización) — **Decisión 9a: se repara QA-023-13** en una vuelta excepcional acotada, sin reiniciar contadores; **9b NO autorizada todavía** (QA-023-10: se prepara su decisión, con una comprobación acotada en Windows/MSYS si está disponible)

**Texto del propietario, literal e íntegro** (mensaje del 2026-10-02 a la sesión coordinadora del worktree `ArnesJuan-v1.35`):

> Continuamos con el objetivo de preparar una versión publicable del arnés, sin ampliar esta intervención a otras reparaciones.
>
> **Autorizo la decisión 9a y una vuelta excepcional acotada**, sin reiniciar contadores. **No autorizo todavía 9b**: medir en Windows no sustituye el criterio vigente de menos de 5 segundos ni equivale a aceptar que un timeout deje pasar la operación.
>
> ### 1. Base y conservación
>
> Trabaja en `cand/1.35.0`, partiendo de la cabeza reportada `452098e`. Comprueba la cabeza real, el estado del PR #59 y las instrucciones del worktree antes de modificar.
>
> Conserva los cambios preexistentes de `docs/ESTADO.md`, `propuesta-v1.35.0/`, las evidencias y todas las corridas anteriores. No recuperes la optimización descartada de QA-023-10.
>
> ### 2. Reparar QA-023-13
>
> Corrige el tratamiento del `cwd` con retorno de carro antes de que cualquier lectura o normalización pueda recortarlo.
>
> La propiedad exigida es: **las puertas deben juzgar la ruta real de la operación o denegar explícitamente cuando no puedan determinarla; nunca juzgar otra ruta por haber modificado silenciosamente el directorio recibido.**
>
> Autorizo denegar un `cwd` que contenga CR con un motivo preciso. Conserva el tratamiento ya validado de LF y las denegaciones de `file_path` y nombre de herramienta que quedaron registradas en la vuelta anterior.
>
> Revisa los puntos de lectura y transporte de estos campos directamente relacionados con el defecto. No conviertas esto en una reescritura general del analizador de Bash.
>
> ### 3. Validación acotada
>
> Reutiliza la evidencia y los casos existentes. Comprueba:
>
> - El caso de QA-023-13 antes y después, tanto para `guard-completado` como para `guard-codigo`.
> - Que siguen conformes los casos de LF de QA-023-09 y las reparaciones de SEC-117 y SEC-119 afectadas por este cambio.
> - Una operación legítima, verificando la decisión y el archivo resultante.
> - El caso CR en el host real, si el host permite construirlo. Si no, registra el impedimento y distingue expresamente la prueba directa del hook de la prueba del host.
>
> No repitas hasta obtener verde ni amplíes plataformas o matrices sin una necesidad concreta de esta reparación.
>
> ### 4. QA-023-10: preparar la decisión, sin cambiar el contrato
>
> No abras otra optimización en esta vuelta. Conserva el hallazgo y el criterio de menos de 5 segundos.
>
> Prepara una decisión breve con la evidencia existente que separe:
>
> 1. El incumplimiento de latencia medido.
> 2. El riesgo de agotar el timeout y terminar sin decisión.
> 3. Las plataformas y condiciones realmente comprobadas.
>
> Si Windows/MSYS está disponible, autorizo una comprobación acotada del caso máximo con procedimiento fijado antes de ejecutarla y todas las ejecuciones conservadas. Si no está disponible, declara esa ausencia; no instales otro entorno ni presentes Windows como validado.
>
> No reduzcas el máximo admitido, no subas umbrales y no aceptes residuales por mí. Una medición inferior a 60 segundos no satisface por sí sola CA-54.
>
> ### 5. Revisión y condición de parada
>
> El analista actualiza únicamente las sedes afectadas. El desarrollador repara y QA revisa el delta, conservando la cobertura anterior que siga siendo válida.
>
> Si QA es favorable para la reparación, despacha seguridad conforme a las reglas vigentes. Si QA-023-10 impide ese veredicto, entrega primero su decisión concreta: no lo ocultes, no lo conviertas en aprobado y no repitas el ciclo de implementación por ese motivo.
>
> No abras otra vuelta excepcional automáticamente. Si aparece un impedimento nuevo, identifica su causa, si lo introduce este cambio y qué decisión concreta requiere.
>
> ### 6. Entrega
>
> Autorizo commits locales de esta intervención. Actualiza el PR #59 mediante push sin force y observa una sola corrida sobre la cabeza final únicamente si la reparación obtiene las revisiones favorables requeridas. Conserva cualquier resultado sin relanzarlo.
>
> Entrega un resumen con:
>
> - Cabeza final y archivos modificados.
> - QA-023-13 antes/después y cobertura real del host.
> - Cobertura exacta de QA y seguridad.
> - Decisión pendiente sobre QA-023-10.
> - Impedimentos restantes para publicar, sin mezclarlos con lo ya resuelto.
>
> Esta autorización no acepta SEC-115, SEC-118, el hueco C ni P-119-A; tampoco autoriza fusionar, cerrar requisitos, crear tags, publicar o actualizar SENDA, Adelantos u otros consumidores.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Base comprobada antes de editar (2026-10-02):** `cand/1.35.0` local = `origin/cand/1.35.0` = PR #59 = `452098e`, en borrador. En el árbol, sólo los cambios preexistentes: `docs/ESTADO.md` y `propuesta-v1.35.0/`.
- **Windows/MSYS está disponible y no se instala nada:** PortableGit en el perfil de Windows (`bash` 5.3.15, MSYS 3.6.9), `jq` 1.8.2 y `timeout`, accesibles desde WSL por interoperabilidad.
- **Contadores:** el de REQ-023 sigue **agotado (3 de 3)**. Ésta es la cuarta vuelta excepcional autorizada sobre esta entrega, y no reinicia nada. No se crea ningún REQ.
- **Orden de la vuelta, en serie** porque todo es de REQ-007:
  1. desarrollador;
  2. host del caso CR y comprobación en Windows/MSYS, las dos de la coordinadora y con registro previo;
  3. analista;
  4. QA (Opus, §5);
  5. seguridad, sólo si QA es favorable para la reparación.

  Push y una sola corrida de CI, sólo si las revisiones salen favorables.

### RESUELTA (propietario, 2026-10-01, sexta autorización) — **Decisión 8: opción A.** Vuelta excepcional agrupada para QA-023-09 (integridad de la entrada), QA-023-10 (coste de `Bash`, REQ-007 CA-54) y QA-023-11 (cobertura real en CA-45), sin reiniciar contadores y sin retirar la reparación de SEC-119/O-11

**Texto del propietario, literal e íntegro** (mensaje del 2026-10-01 a la sesión coordinadora del worktree `ArnesJuan-v1.35`):

> Autorizo la opción A de la decisión 8: una vuelta excepcional agrupada para QA-023-09, QA-023-10 y QA-023-11. Conserva los contadores y registra esta excepción sin reiniciarlos.
>
> Objetivo: eliminar la regresión introducida por SEC-119/O-11, cumplir el coste contratado y completar la declaración de cobertura. No retirar la reparación ni abrir mejoras independientes.
>
> 1. Base y contexto
>
> Trabaja en `cand/1.35.0`. La cabeza local reportada es `8f4dda7`; el PR #59 sigue en `9596e39`. Verifica ambas y el árbol de trabajo antes de editar.
>
> Conserva los cambios preexistentes de `docs/ESTADO.md`, `propuesta-v1.35.0/` y la evidencia. No los descartes ni los incluyas indiscriminadamente. Utiliza las instrucciones del worktree correcto.
>
> 2. QA-023-09: integridad de la entrada
>
> Corrige la extracción de los datos para que un salto de línea dentro de `cwd` no desplace campos ni cambie la ruta que juzgan las puertas.
>
> La solución debe preservar los límites entre campos del formato de entrada; no basta con prohibir el nombre ensayado o sustituir caracteres silenciosamente.
>
> Añade pruebas que fallen con la reparación defectuosa y pasen después. Comprueba ambas puertas, la ruta realmente juzgada y el efecto en disco. Incluye un control legítimo.
>
> Reutiliza el caso del host real. No presentes su denegación anterior por ruta irresoluble como protección acreditada ni extiendas las conclusiones a hosts no ensayados.
>
> 3. QA-023-10: coste de Bash
>
> Autoriza esta instrucción la optimización interna necesaria para cumplir REQ-007 CA-54, conservando:
> - Techo de menos de 5 segundos.
> - Valor por defecto y máximo admitido.
> - Cobertura de seguridad y decisiones del control.
>
> No subas el techo, reduzcas límites admitidos, omitas comprobaciones ni cambies el procedimiento de medición para obtener un PASS.
>
> Antes de medir, identifica el procedimiento y los casos exigidos por el contrato, reutilizando la evidencia existente. Registra todas las ejecuciones y compara el mismo trabajo antes y después.
>
> Si la optimización no consigue cumplir dentro de esta vuelta, detén esa reparación y presenta las cifras y el impedimento concreto. No sigas ensayando hasta obtener una lectura favorable. Continúa y conserva la validación independiente de QA-023-09 y QA-023-11.
>
> 4. QA-023-11: cobertura real
>
> El analista incorpora en CA-45 la evidencia ya obtenida:
> - El cwd recibido por el hook sigue al cd observado.
> - El caso de archivo ilegible falló antes de llegar al hook.
>
> Declara ese segundo caso como límite de la comprobación en el host. No lo conviertas en prueba de denegación del hook ni repitas el experimento sin una pregunta nueva imprescindible.
>
> 5. Ciclo completo de esta vuelta
>
> Agrupa la reparación del desarrollador, el write-back del analista y las pruebas dirigidas. QA revisa los tres puntos y las regresiones de los caminos afectados, reutilizando evidencia intacta.
>
> Si QA es favorable, despacha seguridad sobre el delta. Si no lo es, conserva los resultados parciales y entrega el bloqueo exacto; no abras otra vuelta automáticamente ni apruebes por agotamiento.
>
> Los ajustes internos necesarios para resolver estos tres hallazgos están autorizados. Sólo exige otra decisión un cambio de alcance, contrato o cobertura que exceda expresamente estos límites.
>
> 6. PR y resultado
>
> Autorizo commits, push sin force y actualización del PR #59 en borrador. Obtén el CI requerido sobre la cabeza final de esta entrega. Conserva todas las corridas, sin relanzar buscando verde.
>
> Entrega un único resumen:
> - Estado de cada hallazgo.
> - Antes/después de la ruta juzgada y del coste.
> - Evidencia de host frente a pruebas directas del hook.
> - Firmas y cobertura, SHA y CI.
> - Impedimentos de publicación que permanezcan.
>
> Ficha 1 (SEC-115/SEC-118), ficha 2 (hueco C) y P-119-A siguen pendientes y sin aceptación. No uses una aceptación de F7 para cubrir QA-023-09.
>
> Sin fusión, cierre automático de requisitos, tag, publicación, cambios de modelos, workflow, ruleset ni consumidores. El resultado esperado es esta vuelta terminada y una decisión concreta sobre el candidato, no otra propuesta preliminar.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Base comprobada antes de editar (2026-10-01):** `cand/1.35.0` local = `8f4dda7`; `origin/cand/1.35.0` = PR #59 = `9596e39`, en borrador y ancestro de `8f4dda7`, así que el push no necesita force. En el árbol, sólo los cambios preexistentes: `docs/ESTADO.md` y `propuesta-v1.35.0/`.
- **Contadores:** el de REQ-023 sigue **agotado (3 de 3)**. Ésta es la tercera vuelta excepcional autorizada sobre esta entrega, después de la tercera/cuarta y de la quinta autorización. No reinicia ningún contador y no se crea otro REQ.
- **Orden de la vuelta, en serie** porque las tres partes son de REQ-007 y comparten archivos: desarrollador (QA-023-09 y QA-023-10, con su parada) → validación en el host del caso reutilizado (coordinadora, con registro previo) → analista (write-back) → QA (lanzado con Opus, §5) → seguridad, sólo si QA es favorable.
- **Siguen pendientes y sin aceptación:** ficha 1 (SEC-115/SEC-118), ficha 2 (C) y P-119-A. Una aceptación de F7 no cubre QA-023-09.

### RESUELTA (propietario, 2026-09-30, quinta autorización) — **Reparación acotada de la identificación y lectura de archivos protegidos: SEC-119 y O-11** (SEC-120 sólo si comparte la causa); nueva vuelta excepcional agrupada, sin reiniciar contadores; resuelve la ficha 4 (reparar) y la decisión 7 (se corrige dentro de esta frontera)

**Texto del propietario, literal e íntegro** (mensaje del 2026-09-30 a la sesión coordinadora del worktree `ArnesJuan-v1.35`). Un primer envío del mismo mensaje llegó cortado y el propietario lo reenvió completo; se transcribe el completo.

> Autorizo una reparación acotada de la identificación y lectura de archivos protegidos: SEC-119 y su relación con O-11. El objetivo es terminar esta frontera de seguridad, conservando la reparación de SEC-117 y evitando otra revisión general.
>
> 1. Base y contexto
>
> Parte de `cand/1.35.0`, cabeza conocida `9596e39fca6c8eda6506ee1b26f4bdbd71918313`, PR #59. Verifica el estado y utiliza las instrucciones del worktree correcto. Conserva cambios ajenos y toda la evidencia anterior.
>
> SEC-117 está mitigado dentro de lo ensayado. No reabras su investigación; comprueba únicamente las regresiones que pueda introducir este cambio.
>
> 2. SEC-119: identificar el archivo protegido
>
> Propiedad exigida: las rutas equivalentes que apuntan al mismo archivo protegido no pueden recibir permisos distintos por su escritura.
>
> Reutiliza las reproducciones existentes de `..`, `././` y directorios enlazados. Distingue:
> - Lo que recibe realmente el hook desde el host.
> - Lo que sólo se ha inyectado directamente al hook.
> - La ruta utilizada finalmente por la herramienta.
>
> Implementa una resolución de rutas coherente para `guard-completado` y `guard-codigo`, conforme a sus contratos. No basta con borrar segmentos del texto: considera el directorio de trabajo y los enlaces simbólicos.
>
> Preserva las operaciones legítimas fuera del ámbito protegido. Contempla archivos nuevos mediante su directorio padre existente, sin confundir «todavía no existe» con «no se pudo determinar el destino».
>
> No prometas resolver carreras de enlaces o cambios concurrentes si no existe un mecanismo que lo garantice; declara esa frontera.
>
> 3. O-11: lectura fallida
>
> Autorizo corregir el tratamiento del archivo ilegible dentro de esta misma frontera.
>
> Distingue archivo inexistente, archivo existente pero ilegible y error al resolver la ruta. Para una operación dentro del ámbito protegido, no poder leer o reconstruir lo necesario para juzgarla no puede convertirse en permiso silencioso.
>
> No supongas que, porque el hook no puede leer, la herramienta tampoco podrá escribir. Comprueba esa relación donde sea reproducible; si no lo es, declara el límite.
>
> El mensaje debe indicar la causa y cómo corregirla, sin recomendar otra herramienta para eludir la puerta.
>
> 4. SEC-120 y contratos afectados
>
> Lee primero la ficha existente de SEC-120 y resume causa, consecuencia y evidencia. Inclúyelo en esta reparación sólo si comparte directamente la causa de identificación o lectura del archivo. Si es independiente, consérvalo pendiente y no abras su reparación.
>
> Autorizo al analista a versionar los criterios existentes directamente afectados, con ADR si corresponde, y a reabrir los requisitos que lo exijan. No conserves una expectativa de allow basada en una premisa desmentida. Registra el cambio de compatibilidad y no cierres requisitos automáticamente.
>
> No crees otro REQ para eludir contadores. Antes de despachar, deja identificados los criterios, archivos y pruebas afectados, sin volver a pedirme autorización por las dependencias indispensables de esta frontera.
>
> 5. Validación y presupuesto
>
> Autorizo una nueva vuelta excepcional agrupada: analista para el contrato, desarrollador, QA y seguridad. Registra la excepción sin reiniciar los contadores anteriores.
>
> Prueba al menos:
> - Ruta canónica y rutas equivalentes hacia el mismo archivo protegido.
> - Enlace de directorio que conduce a un destino protegido.
> - Operación legítima fuera del ámbito protegido.
> - Creación legítima de un archivo nuevo.
> - Archivo ilegible y error de resolución.
> - Edición literal, rechazo de la edición no reconstruible de SEC-117 y reapertura legítima.
>
> Comprueba en el host real los casos alcanzables mediante sus herramientas, con control de denegación y verificación del archivo final. Separa esas pruebas de las realizadas sólo a nivel de hook. No atribuyas cobertura a Windows, MultiEdit u otros hosts no ejercidos.
>
> Adapta los fixtures afectados para que cada prueba siga llegando al control que pretende medir. No cambies expectativas indiscriminadamente a deny ni retires casos para obtener verde.
>
> QA revisa el delta y sus regresiones; seguridad después de QA favorable. Reutiliza evidencia intacta. Si esta vuelta termina con un bloqueo, entrega el impedimento preciso y no abras otra automáticamente.
>
> 6. Entrega y límites
>
> Autorizo commits, push sin force y actualización del PR #59 en borrador. Ejecuta las comprobaciones exigidas y observa el CI sobre la cabeza final. Conserva todas las corridas y no relances buscando verde.
>
> Actualiza notas, guía y comentarios únicamente para describir fielmente esta reparación, su compatibilidad y sus límites.
>
> Entrega un único resultado: antes/después, cobertura real por host, determinación de SEC-119/O-11/SEC-120, contratos afectados, firmas, SHA, CI y decisiones pendientes de publicación.
>
> SEC-115, SEC-118 y el hueco C siguen sin aceptación. No abras trabajo independiente sobre ellos, modelos, sondas, workflow, ruleset o consumidores.
>
> Sin fusión, cierres automáticos, tag ni publicación. El resultado buscado es esta frontera reparada y un candidato concreto; no otra propuesta preliminar ni una campaña nueva de mejoras.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Cabeza de partida comprobada:** `9596e39fca6c8eda6506ee1b26f4bdbd71918313` = `origin/cand/1.35.0` = PR #59, en borrador.
- **Contadores:** el de REQ-023 sigue **agotado (3 de 3)**. Ésta es una segunda vuelta excepcional, autorizada, que no reinicia ningún contador. No se crea otro REQ.
- **Siguen abiertos y sin aceptar:** SEC-115, SEC-118 y C.

### RESUELTA (propietario, 2026-09-30, cuarta autorización) — **Decisión 6 (P-SEC117): opción A.** Se amplía el alcance para corregir los contratos (REQ-001 CA-10, CA-11 y CA-12, y REQ-007 CA-46 (c), con ADR) y las pruebas que dependen de la premisa desmentida por la reproducción real de SEC-117; se reabre REQ-001 según §9; QA y seguridad cubren también REQ-001 y REQ-007; todo dentro de la misma vuelta excepcional agrupada

**Texto del propietario, literal e íntegro** (mensaje del 2026-09-30 a la sesión coordinadora del worktree `ArnesJuan-v1.35`):

> Autorizo la opción A de la decisión 6. Amplío expresamente el alcance para corregir los contratos y las pruebas que dependen de la premisa desmentida por la reproducción real de SEC-117.
>
> 1. Contrato
>
> El analista versiona REQ-001 CA-10, CA-11 y CA-12, y REQ-007 CA-46(c), con el ADR correspondiente y trazabilidad al experimento real. Completa el criterio de SEC-117 en REQ-023 sin duplicar la norma en varias sedes.
>
> Autorizo reabrir REQ-001 según §9. No lo cierres automáticamente al terminar ni atribuyas sus firmas anteriores al contrato modificado.
>
> La propiedad se mantiene: una edición sobre un REQ protegido que el hook no puede reconstruir no puede recibir permiso silencioso. No adoptes la opción B ni vuelvas a confiar únicamente en que new_string mencione el estado terminal.
>
> 2. Implementación y banco
>
> El desarrollador implementa la denegación acotada al supuesto anterior, con un mensaje que permita realizar una edición verificable. Preserva las operaciones legítimas reconstruibles y la reapertura.
>
> Autorizo adaptar las llamadas del banco afectadas por old_string ficticios:
> - Las que prueban otras puertas deben usar ediciones literales válidas, para seguir llegando al control que pretenden medir.
> - Las que prueban reconstrucción fallida deben conservar esa condición y comprobar la nueva denegación.
> - No cambies masivamente expectativas a deny: una prueba que pasa porque la detuvo otra puerta no acredita su propósito original.
> - No retires casos para obtener verde; justifica cualquier sustitución y conserva su cobertura.
>
> Usa el inventario de llamadas existente. No amplíes esta tarea a una limpieza general del banco.
>
> 3. Revisión agrupada
>
> Amplío la revisión de QA y seguridad a los criterios y caminos afectados de REQ-001 y REQ-007, además de REQ-023 y REQ-031. Reutiliza la evidencia de las partes intactas; no repitas la revisión completa de cada requisito.
>
> Esta ampliación forma parte de la vuelta excepcional agrupada ya autorizada: no reinicia contadores ni concede vueltas ilimitadas. Registra la ampliación y continúa el trabajo pendiente sin separar artificialmente nuevas rondas.
>
> Incluye en la misma entrega QA-023-06, la precisión de REQ-031 CA-A13 y los comentarios incorrectos ya autorizados. Mantén separadas la propiedad del control y las limitaciones SEC-115/118.
>
> 4. Validación y entrega
>
> Repite de forma acotada la comprobación con Edit real: caso que escapaba, denegación de control y edición legítima. Verifica también reapertura y los caminos compartidos afectados. Distingue argumentos, decisión y efecto en disco.
>
> Después de QA favorable, seguridad determina su aprobación y cobertura. Autorizo commits, push sin force y actualización del PR #59, con CI sobre la cabeza final. Conserva los resultados y no relances buscando verde.
>
> Si la vuelta termina con un bloqueo, entrega el hallazgo exacto y el delta pendiente; no apruebes por agotamiento ni abras otra reparación automáticamente.
>
> SEC-115, SEC-118 y el hueco C continúan abiertos y sin aceptación. Sin fusión, cierres automáticos, tag, publicación ni cambios en consumidores.
>
> El resultado esperado es la reparación completa de SEC-117 con sus contratos y pruebas coherentes, no otra propuesta previa. Continúa con esta autorización sin volver a solicitar aprobación por las dependencias enumeradas aquí.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Cabeza de partida:** `0e5df92`, local y sin push; el PR #59 está en `df550fa`.
- **ADR-015 está libre** en todas las ramas: será el ADR que supersede la premisa «un `Edit` cuyo `old_string` no está literal falla y no escribe nada».
- **Contadores:** el de REQ-023 sigue **agotado (3 de 3)** y no se reinicia. Esta ampliación es parte de la vuelta excepcional de la tercera autorización, no una vuelta nueva. REQ-001 se reabre por §9 sin contador nuevo, y sus firmas anteriores quedan acotadas al contrato anterior.
- **Siguen abiertos y sin aceptar:** SEC-115, SEC-118 y C.

### RESUELTA (propietario, 2026-09-29, tercera autorización) — **Reparación agrupada del candidato del PR #59: SEC-117, QA-023-06 y los comentarios de código que describen mal ese comportamiento**; vuelta excepcional agrupada desarrollador → QA → seguridad, más el write-back indispensable del analista, sin reiniciar el contador; **no se acepta publicar con SEC-117 aplazado**; resuelve la ficha 3 (reparar) y la decisión 5

**Texto del propietario, literal e íntegro** (mensaje del 2026-09-29 a la sesión coordinadora del worktree `ArnesJuan-v1.35`; llegó completo):

> Autorizo una reparación agrupada del candidato del PR #59: SEC-117, QA-023-06 y los comentarios que describen incorrectamente ese comportamiento. No acepto publicar con SEC-117 aplazado.
>
> Parte de `cand/1.35.0`, cabeza conocida `df550fa2e8e7ae7906b39ede8711143d2488936b`. Verifica el estado y trabaja con las instrucciones del worktree correcto, preservando cambios ajenos.
>
> 1. Reparar SEC-117
>
> La reproducción real ya permite implementar; no prepares otra investigación general.
>
> Propiedad exigida: cuando el hook no puede reconstruir una edición de un REQ protegido porque no encuentra literalmente el texto anterior, esa incertidumbre no puede convertirse en permiso silencioso.
>
> Define la condición de denegación de forma comprobable. No vuelvas a depender sólo de encontrar «estado: completado» en `new_string` ni intentes imitar toda la normalización del host.
>
> La denegación debe explicar cómo realizar una edición verificable. Conserva las ediciones legítimas y la reapertura cuando el hook pueda reconstruirlas. No autorices otra herramienta como atajo para eludir el control.
>
> Revisa los caminos que comparten esa reconstrucción, incluido MultiEdit si corresponde, sin ampliar el encargo a todas las herramientas o formas de escritura.
>
> 2. Corregir QA-023-06 y comentarios afectados
>
> Autorizo corregir las sedes de REQ-023 y REQ-031 afectadas:
> - Expresa correctamente que el límite relevante es de bytes.
> - Conserva las cifras medidas en la evidencia junto con sus condiciones, incluida la restricción ASCII.
> - No extrapoles resultados a caracteres, hosts o tamaños no probados.
> - Separa la propiedad del control de las limitaciones SEC-115/118; una frase condicional no acredita protección.
>
> Autorizo modificar los comentarios de código señalados cuando describan incorrectamente el comportamiento, además de la documentación correspondiente. No es autorización para otras refactorizaciones.
>
> Las seis observaciones menores quedan fuera, salvo que una sea inseparable de estas correcciones; en ese caso explica la dependencia y limita el cambio.
>
> 3. Presupuesto y gobernanza
>
> Autorizo expresamente una vuelta excepcional agrupada de desarrollador → QA → seguridad para esta reparación, más el write-back contractual indispensable del analista. Conserva el contador agotado y registra la excepción sin reiniciarlo ni crear otro REQ para eludirlo.
>
> Reutiliza las firmas y evidencias que sigan siendo aplicables. QA revisa el delta y sus efectos sobre REQ-023 y REQ-031; seguridad emite su determinación después de QA favorable.
>
> Si esta vuelta termina con un hallazgo bloqueante, entrega el impedimento exacto y lo pendiente. No abras otra vuelta ni apruebes por agotamiento.
>
> 4. Validación
>
> Reutiliza el experimento real de SEC-117 y sus precondiciones. En un proyecto temporal aislado verifica:
> - El caso de comillas que antes escapaba ahora queda bloqueado y el archivo no cambia.
> - El control positivo de denegación sigue bloqueando.
> - Una edición legítima reconstruible sigue funcionando.
> - La reapertura reconstruible sigue permitida.
> - Los caminos afectados por el cambio tienen pruebas de regresión.
>
> Distingue argumentos recibidos, decisión del hook, tratamiento del host y efecto en disco. No presentes una emulación como ejecución real ni extiendas la conclusión a Windows o al editor sin evidencia.
>
> Ejecuta las comprobaciones necesarias del candidato. Conserva todas las corridas; un resultado posterior no borra uno anterior.
>
> 5. PR y entrega final
>
> Autorizo commits, push sin force y actualización del PR #59 en borrador. Obtén el CI requerido sobre la cabeza final y no lo relances buscando verde.
>
> Verifica que la copia íntegra de este encargo quede conservada en la sede de autorización. No reconstruyas el mensaje anterior que llegó cortado: este texto define el alcance autorizado ahora.
>
> Entrega un único resumen:
> - SEC-117 antes/después, con evidencia real.
> - QA-023-06 y comentarios corregidos.
> - Compatibilidad y límites.
> - Firmas y cobertura sobre el candidato.
> - SHA, CI y decisiones de publicación todavía pendientes.
>
> SEC-115, SEC-118 y el hueco C siguen abiertos y sin aceptación mía. Sin nuevas reparaciones de esos asuntos, modelos, sondas, workflow, ruleset o consumidores.
>
> No fusiones, no cierres requisitos, no crees tags ni publiques. El objetivo es dejar esta reparación terminada y un candidato concreto para decidir la salida.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Cabeza de partida comprobada:** `df550fa2e8e7ae7906b39ede8711143d2488936b` = `origin/cand/1.35.0`.
- **Sede de la reparación de SEC-117:** REQ-023. Hoy su frontera (g) lo declara fuera; el write-back del analista lo pasa dentro. **No se crea otro REQ**, como ordena el punto 3.
- **Contador de REQ-023:** sigue **agotado (3 de 3)**. Ésta es una vuelta **excepcional** autorizada, no la cuarta vuelta del contador, y no lo reinicia.
- **Entregas anteriores:** la autorización del 2026-09-29 que llegó truncada no se reconstruye; este texto define el alcance.
- **Siguen abiertos y sin aceptar:** SEC-115, SEC-118 y el hueco C.

### RESUELTA (propietario, 2026-09-29, segunda autorización) — **Candidato del PR #59: corrección documental excepcional fuera del contador (QA-023-05 y R-045 §6, con las promesas de REQ-031 afectadas) y reproducción real y aislada de SEC-117**; resuelve la decisión 4 con la opción (A); SEC-115, SEC-118, C y SEC-117 **NO** aceptados

**Texto del propietario, literal e íntegro TAL COMO LLEGÓ** (mensaje del 2026-09-29 a la sesión coordinadora del worktree `ArnesJuan-v1.35`). **El mensaje llegó truncado:** termina en «Registra con precisión la cobertura de QA y», sin punto final. La coordinadora no reconstruye lo que falta; aplica lo que está completo y lo declara en su entrega.

> Autorizo un encargo acotado sobre el candidato del PR #59: corregir las promesas documentales pendientes y comprobar SEC-117 en una sesión real. El objetivo es obtener evidencia suficiente para decidir la publicación, sin ampliar otra vez la reparación.
>
> 1. Base y contexto
>
> Parte de `cand/1.35.0`, cabeza conocida `45c2e5c5ce90c5eae15e817d65522f3ee6b788cd`. Comprueba el estado antes de actuar y conserva cambios ajenos, la propuesta original y el bloque derivado de ESTADO.
>
> Trabaja con las instrucciones del worktree correcto, sin heredar como normativa las de `rel/registro-1.33.0`.
>
> 2. Corrección documental excepcional
>
> Autorizo una intervención documental fuera del contador agotado, registrada expresamente y sin reiniciarlo.
>
> Agrupa QA-023-05 y las correcciones de texto señaladas por R-045, incluidas las promesas de REQ-031 afectadas. Describe la propiedad realmente comprobada y sus límites; no conviertas una denegación condicionada en garantía universal.
>
> El analista actualiza las sedes contractuales correspondientes; QA revisa el delta documental y seguridad emite su determinación después de QA favorable. Reutiliza las pruebas y revisiones cuyo contenido no cambió. No repitas el banco completo por rutina ni modifiques código para resolver este apartado.
>
> La corrección documental no acepta SEC-115, SEC-118, C ni SEC-117 como riesgos de publicación.
>
> 3. SEC-117: reproducción real y aislada
>
> Autorizo un experimento acotado en un proyecto temporal, sin datos reales ni archivos de consumidores.
>
> Antes de ejecutarlo, registra:
> - Versión y host del CLI, plugin y hook utilizados.
> - Entrada exacta del caso derivado de la evidencia existente.
> - Precondiciones que deberían impedir el cierre.
> - Resultado esperado y cómo observarás el efecto.
>
> Presupuesto: un caso positivo de denegación, el caso sospechoso y un control legítimo permitido. Una ejecución por caso. Si falla la instrumentación, admite una sola repetición diagnóstica, conservando y explicando el intento anterior.
>
> Observa por separado:
> - Argumentos que recibe el hook.
> - Decisión emitida y tratamiento por el entorno.
> - Resultado de la herramienta y contenido final del archivo.
>
> Utiliza la herramienta Edit real del host comprobado. Una emulación, un script que edite el archivo o una lectura del binario no sustituyen esta prueba. No desactives las puertas para conseguir el resultado.
>
> Si no puedes ejecutar la prueba real, informa de la limitación; no la presentes como reproducida. Si el control de denegación no funciona, el ensayo no permite atribuir el resultado a SEC-117.
>
> No repares SEC-117 dentro de este encargo. Si se confirma, entrega causa acotada, superficie afectada y propuesta mínima de reparación. Si no se reproduce, limita la conclusión a las condiciones ensayadas.
>
> 4. Precisiones con evidencia existente
>
> Sin nuevos ensayos adicionales:
> - Separa en SEC-118 lo observado directamente de lo inferido o emulado.
> - Identifica qué archivos se escribieron con Python, por qué rol y bajo qué permisos. No des por resuelto el asunto sólo porque la cabecera de REQ-023 no cambió; tampoco declares infracción por el nombre de la herramienta.
> - Contrasta los cambios de compatibilidad con la política de versiones del repositorio. Presenta una recomendación fundada sobre 1.35.0; no cambies nuevamente la versión por tu cuenta.
> - Mantén diferenciados los fail-before locales y los SKIP de CI.
>
> 5. Registro y CI
>
> Autorizo commits de la corrección documental, push sin force y actualización del PR #59. Si cambia la cabeza, observa el CI requerido sobre la cabeza resultante una vez; no relances buscando verde.
>
> Conserva la evidencia del experimento por separado, sin incorporar binarios ni volcados de terceros. Registra con precisión la cobertura de QA y

**Lo que la coordinadora añade, rotulado como suyo:**
- **Intervención documental excepcional:** fuera del contador dev↔QA de REQ-023, que **sigue agotado (3 de 3) y no se reinicia**. Es una comisión de analista, una de QA sobre el delta documental y una determinación de seguridad **después** de un QA favorable. Sin código.
- **Cabeza de partida comprobada:** `45c2e5c5ce90c5eae15e817d65522f3ee6b788cd` = `origin/cand/1.35.0`. CLI del host: **2.1.285**; QA leyó el binario de la 2.1.284.
- **El experimento de SEC-117** lo ejecuta la coordinadora, con registro previo en la rama local de evidencia antes de correrlo. No es una medición de QA, como no lo fue CA-A16.

### RESUELTA (propietario, 2026-09-29) — **SEC-047 (mitad 1 de REQ-023) y candidato v1.35.0**: implementación y preparación autorizadas, sin publicación; SEC-115 y hueco C **NO** aceptados

**Texto del propietario, literal e íntegro** (mensaje del 2026-09-29 a la sesión coordinadora del worktree `ArnesJuan-v1.35`):

> Autorizo avanzar con SEC-047 y preparar el candidato v1.35.0. Completa este encargo de punta a punta dentro del alcance siguiente, sin pedir nuevamente autorización para cada paso ya incluido.
>
> 1. Contexto y base
>
> Trabaja en `/home/juan/dev/ArnesJuan-v1.35`, desde la sesión nueva con las instrucciones de ese worktree. Comprueba rama, SHA y estado antes de editar.
>
> Usa `origin/main` como referencia, no la rama local main desfasada. Conserva el cambio preexistente de `docs/ESTADO.md` y la propuesta sin seguimiento; no los descartes ni los incluyas indiscriminadamente en commits.
>
> Lee `propuesta-v1.35.0/README.md` y `propuesta-v1.35.0/SEC-047.diff`. Conserva la propuesta original como antecedente.
>
> 2. Implementar SEC-047
>
> Autorizo implementar la mitad 1 de REQ-023 y versionar los criterios y sedes afectados. REQ-024 queda fuera.
>
> Acepto expresamente que una clave de control repetida deniegue el cierre aunque sus valores coincidan. Registra este cambio de compatibilidad.
>
> La corrección debe:
> - Impedir que las variantes cubiertas se conviertan silenciosamente en ausencia y reduzcan el rigor u oculten un bloqueante.
> - Respetar la estructura de una declaración: extraer letras ASCII no debe convertir una cita, ejemplo o explicación en campo de control.
> - Mantener coherencia entre lectores, ausencias legítimas y reapertura de REQ.
> - Evitar elegir silenciosamente entre declaraciones contradictorias.
> - Conservar las fronteras de cobertura propuestas y declararlas sin prometer reconocimiento universal.
>
> Las claves de más de 256 bytes que queden fuera siguen siendo una limitación; no las presentes como protegidas por ese límite. No amplíes este encargo para resolver todo Unicode ni SEC-115.
>
> 3. Validar y preparar la entrega
>
> Recorre el ciclo correspondiente al cambio de hooks, reutilizando las reproducciones y el inventario existentes. Agrupa los hallazgos de cada revisión antes de reparar; no reinicies contadores ni repitas revisiones sin un delta o riesgo concreto.
>
> Verifica casos legítimos, variantes, duplicados, prosa, reapertura, CRLF y las fronteras relevantes. Ejecuta el banco completo y las comprobaciones exigidas sobre el candidato; no presentes el ±1 % del ensayo preliminar como rendimiento acreditado.
>
> Autorizo rama de trabajo, commits, push sin force y PR en borrador. Conserva los resultados de CI; no relances buscando verde.
>
> Si se agota el presupuesto vigente con un bloqueo real, entrega el impedimento exacto y lo pendiente. No apruebes por agotamiento.
>
> 4. Preparar v1.35.0
>
> Con la reparación validada, prepara el cambio de versión en los manifiestos correspondientes, las notas y la guía de actualización necesaria. Autorizo esos cambios como preparación del candidato, no su publicación.
>
> Describe el contenido realmente incluido desde v1.34.0. REQ-025 aporta sólo su entrega 1; no cierres el requisito completo ni incorpores trabajo de la rama antigua.
>
> Las notas deben explicar los cambios de compatibilidad y conservar los resultados históricos, los inconclusos y las limitaciones. No transformes un CI verde en acreditación de rendimiento, conducta o ahorro.
>
> Obtén el CI requerido sobre la cabeza final del candidato y deja identificada la cobertura de las firmas.
>
> 5. Riesgos pendientes
>
> Este encargo NO acepta el aplazamiento de SEC-115 ni del hueco C. Conserva sus decisiones pendientes y prepara sus fichas finales con consecuencia, protección efectiva, responsable propuesto, fecha de revisión y condición de revisión anticipada.
>
> Reutiliza la fecha propuesta de SEC-115, 2026-10-29. Para C propone una fecha concreta. Ninguna propuesta cuenta como aceptación mía.
>
> No repares esos dos asuntos dentro de SEC-047 ni detengas el trabajo independiente autorizado únicamente porque esperan mi decisión. Si una regla impide un cierre, deja ese cierre pendiente y continúa lo permitido.
>
> 6. Límites y resultado final
>
> Sin fusión, tag, publicación ni actualización de instalaciones o consumidores. PR #54 y #57 intactos. Sin reconciliar `rel/registro-1.33.0`, cambiar modelos, sondas, umbrales, workflow o ruleset.
>
> Entrega una sola propuesta de salida: reparación y compatibilidad verificadas, SHA y PR del candidato, firmas y CI, contenido de v1.35.0 y decisiones exactas que falten para publicarla.
>
> No propongas otra investigación general. El resultado buscado es un candidato concreto que yo pueda revisar y decidir.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Antecedente citado por la autorización** («Lee `propuesta-v1.35.0/README.md` y `propuesta-v1.35.0/SEC-047.diff`»): la propuesta se conserva sin seguimiento en el worktree, intacta, y su copia literal queda versionada en `docs/arnes/v1.35.0-propuesta-sec-047.md`, `docs/arnes/v1.35.0-propuesta-sec-047.diff` y `docs/arnes/v1.35.0-propuesta-sec-047-humo.txt` para poder citarla con commit. Sus cifras de coste (±1 %) son de un **ensayo preliminar** y **no** acreditan rendimiento.
- **El encargo anterior** del que nace la propuesta está íntegro en `traspaso-v1.35.0/README.md`, rama `evidencia/prueba-despacho-2026-09-14`, commit `94e2d3b`.
- **Cambio de compatibilidad aceptado expresamente:** una clave de control repetida deniega el cierre **aunque sus valores coincidan**.
- **Contador:** REQ-023 no ha gastado ninguna vuelta dev↔QA (sólo trabajo de analista y una cata); el tope es 3 y no se reinicia.
- **Rama del candidato:** `cand/1.35.0`, desde `origin/main` = `713ac68`. La rama local `main` (`cf2009e`) está desfasada y no se usa.
- **El asunto 3** de la entrada pendiente de publicación (SEC-047/§13) queda resuelto por esta autorización; **SEC-115 y C siguen pendientes** en esa entrada, con sus fichas finales.

### RESUELTA (propietario, 2026-09-28) — **REQ-031: comprobación acotada de procedencia de instrucciones y referencias**; intervención documental excepcional sin reiniciar el contador

**Texto del propietario, literal e íntegro:**

> Autorizo una comprobación acotada de la procedencia de instrucciones y referencias de REQ-031. El objetivo es determinar si el uso de AGENTS.md de otra rama afectó la entrega y dejar el PR #58 listo para una decisión de integración. No abrir otra revisión general del arnés.
>
> Base de la comprobación: cabeza `19c5ca762ec039958572c537a74a909c6caf0207` del PR #58, con CI verde. Verifica que sigue siendo la cabeza antes de actuar.
>
> **1. Establecer el contexto correcto**
>
> Identifica el directorio de trabajo, rama y archivos de instrucciones que cargó la sesión y cada comisión relevante. Distingue lo demostrado por registros de lo inferido.
>
> Para esta comprobación utiliza las instrucciones del worktree de REQ-031. Cambiar de directorio no demuestra que una sesión haya descargado instrucciones heredadas: si hace falta una sesión nueva para conseguir un contexto limpio, úsala con un encargo acotado y fuente explícita.
>
> No modifiques ni reconcilies `rel/registro-1.33.0`, no cambies la rama de una sesión que siga trabajando y no toques cambios ajenos.
>
> **2. Determinar el efecto de la mezcla de instrucciones**
>
> Compara sólo las instrucciones que pudieron afectar:
> - Alcance de A y D.
> - Permisos y separación de roles.
> - Presupuesto de vueltas.
> - Validación, firmas y conclusiones sobre SEC-047, SEC-078 y R-024.
>
> Indica qué diferencia influyó realmente y qué parte de la entrega afecta. No invalidez toda la evidencia por su procedencia ni la declares válida únicamente porque el código no cambió.
>
> **3. Corregir referencias del candidato**
>
> Autorizo una intervención documental excepcional, sin reiniciar el contador 3 de 3, para corregir referencias inexistentes o atribuidas a la rama equivocada en los archivos de esta entrega.
>
> Si una referencia sólo existe en otra rama, cita explícitamente su procedencia y commit cuando sea necesaria como antecedente; no la presentes como sede vigente en main. No inventes identificadores ni importes aquella rama para hacer resoluble una cita.
>
> La celda de §13 ausente de main no debe añadirse para luego corregirla. Registra que esa parte del encargo nació de una atribución equivocada.
>
> Reutiliza las aprobaciones existentes donde su evidencia siga siendo aplicable. QA y seguridad deben revisar únicamente las conclusiones o textos afectados por esta comprobación. No les atribuyas una ratificación que no hayan emitido.
>
> Si aparece una necesidad de cambiar código, criterios, permisos o alcance, entrega el delta concreto pendiente y detén sólo esa reparación; esta autorización no incluye implementarla.
>
> **4. Separar los riesgos de publicación**
>
> Conserva abiertos y sin aceptación mía:
> - C: escrituras por intérpretes que el detector no reconoce.
> - SEC-115: entradas que agotan el hook y permiten continuar sin decisión, observado en el CLI.
>
> Corrige cualquier texto de esta entrega que presente una futura comprobación posterior como prevención ya disponible. Detectar un cambio después no demuestra que se impidió ni que se deshicieron sus efectos.
>
> No diseñes ni implementes ahora una puerta posterior, límites globales o una nueva arquitectura. No conviertas estos pendientes en riesgos aceptados por registrarlos en CHANGELOG.
>
> **5. Entrega y límites**
>
> Autorizo commits documentales, push sin force y actualización del PR #58. Si cambia la cabeza, observa el CI requerido correspondiente, conserva su resultado y no relances buscando verde.
>
> Si no hace falta cambiar el candidato, conserva su SHA y registra la comprobación en la evidencia y un comentario del PR.
>
> Entrega un único resumen breve:
> - Instrucciones ajenas que influyeron y efecto concreto.
> - Referencias corregidas.
> - Evidencia y aprobaciones reutilizadas, con su alcance.
> - SHA y CI aplicables.
> - Si recomiendas integrar #58 y, por separado, qué decisiones siguen pendientes para publicar.
>
> No fusiones, no cierres REQ-031, no publiques versión ni tag. No toques modelos, PR #54/#57, consumidores, sondas, umbrales, workflow ni ruleset. No abras otra campaña de mejoras.

**Lo que la coordinadora añade, rotulado como suyo:** cabeza verificada `19c5ca7` (remoto idéntico, árbol limpio). Demostrado por registros (transcripts de las seis comisiones de REQ-030/031): todas cargaron «Contents of /home/juan/dev/ArnesJuan/AGENTS.md» (worktree de la sesión, rama `rel/registro-1.33.0`, 503 líneas, con §14 y la celda R-024), no el `AGENTS.md` de `main`/este worktree (807 líneas). Diferencias por sección: §5 y §7 idénticas; §13 difiere en dos filas (main: sólo CR; rel: celda ancha con BOM/R-024) y en el marcador de coordinación; §6 difiere mucho (main trae la política de «vía proporcional», 480 líneas frente a 132); §14 sólo en rel. Ambas fijan «Máximo 3 vueltas dev↔QA» y la regla de `arnes-paralelo.sh`.

### RESUELTA (propietario, 2026-09-28) — **REQ-031, vuelta 3 de 3: reparación agrupada** — SEC-113 remedio B (límite antes de normalizar, en `lib.sh`), celda de §13 / R-024 (SEC-047) y registro de evidencia (cuadre 920 → 978; PENDIENTES)

**Texto del propietario, literal e íntegro:**

> Autorizo usar la vuelta 3 de 3 de REQ-031 para una reparación agrupada y acotada. Trabaja sobre la rama del PR #58, partiendo de `373563f42605d1840d76d629c127110bd6e28e4b`, verificando primero su estado y preservando cambios ajenos.
>
> Objetivo: resolver SEC-113 y corregir las afirmaciones documentales señaladas, conservando la reparación A y el recorrido D. No ampliar esta entrega a una revisión general del arnés.
>
> **1. SEC-113: comprobar el tamaño antes de normalizar**
>
> Autorizo el remedio B, incluido el cambio necesario en `lib.sh`: aplicar el límite antes de la operación costosa, sin alterar el umbral autorizado ni truncar contenido para hacerlo pasar.
>
> Mantén las entradas legítimas dentro del límite y la reapertura de REQ. Verifica las fronteras del límite, la entrada de 255 371 bytes ya medida y los caminos del parser afectados.
>
> Comprueba por separado:
> - La respuesta y duración del hook.
> - La decisión que recibe el entorno.
> - Si el archivo protegido queda modificado.
>
> Si puedes reproducir de forma aislada cómo trata el entorno la terminación del hook sin decisión, hazlo con presupuesto acotado. Si no puedes, declara esa parte no comprobada: un código de salida por sí solo no demuestra que la escritura quedó bloqueada.
>
> Reutiliza las pruebas anteriores de A y D; amplía únicamente lo necesario por el cambio compartido en `lib.sh`.
>
> **2. SEC-047: coherencia documental y exposición**
>
> Autorizo corregir la celda de §13 que promete una cobertura que no existe y retirar o sustituir la referencia a R-024 tras comprobar su procedencia. Actualiza las sedes espejo aplicables sin duplicar la explicación.
>
> Conserva SEC-047 y QA-031-01 abiertos si el mecanismo sigue permitiendo el caso. No presentes la corrección documental como reparación del control ni como aceptación mía del riesgo.
>
> Haz un inventario de sólo lectura de las cabeceras actuales del propio arnés para comprobar si hay claves que el lector ignora y que puedan reducir el rigor o evitar una comprobación. Distingue ausencia de exposición actual de ausencia del defecto.
>
> No modifiques consumidores, no normalices cabeceras automáticamente y no implementes ahora una nueva política de reconocimiento de claves.
>
> **3. Corregir el registro de evidencia**
>
> Aclara el cuadre del banco contra la base real `a7a60c2`: el reporte anterior indicó 912 → 978, pero REQ-030 había dejado 920 casos. Identifica añadidos y retirados y corrige el resumen según el diff; no ajustes el recuento esperado para ocultar una discrepancia.
>
> Actualiza la referencia de `docs/PENDIENTES.md` que todavía presenta como extrapolación el caso ya medido de 255 371 bytes. Conserva la procedencia y el resultado histórico.
>
> **4. Validación y entrega**
>
> Agrupa estas reparaciones en la última vuelta disponible, con write-back del analista donde corresponda, QA sobre el delta y sus efectos, y seguridad después de QA favorable. No reinicies contadores ni abras otra vuelta automáticamente.
>
> Autorizo commits, push sin force y actualización del PR #58 en borrador. Ejecuta el CI requerido sobre la cabeza final; conserva todas las corridas y no relances buscando verde. Comprueba qué contenido cubren las firmas y qué cambios posteriores son sólo registros.
>
> Si se agota la vuelta con un bloqueo, entrega el impedimento exacto y el delta pendiente; no apruebes por agotamiento.
>
> **5. Límites**
>
> El hueco C de escrituras por intérpretes sigue separado y no aceptado como aplazado. No implementes la puerta posterior en este encargo. Presenta su decisión pendiente antes de publicar, sin convertir su documentación en una aceptación.
>
> Sin cambios de modelos, sondas de coste, umbrales, workflow, ruleset, rotación ni consumidores. Sin fusionar #58, #57 o #54, cerrar REQ-031, crear tags ni publicar versiones.
>
> Entrega un único resumen breve: antes/después de SEC-113, exposición encontrada de SEC-047, cuadre del banco, firmas, SHA, CI y decisiones concretas que falten para publicar. No añadas otro programa de mejoras.

**Lo que la coordinadora añade, rotulado como suyo:** el asunto 1 de la entrada pendiente «Decisión de publicación de 1.35.0» (remedio B) queda decidido por esta autorización; los asuntos 2 (hueco C) y 3 (§13/SEC-047 en lo que exceda la corrección documental autorizada) siguen pendientes. Corrección del registro: el cuadre real es **920 → 978** (+58 casos, todos en la sección 08: 7 → 65; la sección 32 conserva 40 y cambia la expectativa de REQ-717); el «912 → 978» del informe anterior era un error de la coordinadora (912 era el cuadre anterior a REQ-030). Cabeza de partida verificada: `373563f`, árbol limpio, remoto idéntico.

### RESUELTA (propietario, 2026-09-27) — **REQ-031, decisión P-1: opción B** (tras el paréntesis de un hallazgo sólo el separador de la gramática o el fin del campo; texto adicional deniega); versionar REQ-007 CA-41 y REQ-717 pasa a deny

**Pregunta del analista (P-1):** REQ-007 CA-41 (`requirements/REQ-007.md:101`) exige aceptar texto detrás del paréntesis (`QA-006 (instrumento) — REQ-007`), certificado por el caso REQ-717 de `tests/escenarios/hooks/secciones/32-huecos-auditoria-r001.sh`; la propiedad de REQ-031 lo trata como no interpretable. Opciones: (a) aceptar texto sin paréntesis detrás (deja pasar `SEC-A (instrumento) · SEC-B`); (b) denegar y versionar REQ-007 CA-41.

**Texto del propietario, literal e íntegro:**

> Autorizo la opción B de P-1: después del paréntesis completo de un hallazgo sólo se admite el separador definido por la gramática o el final del campo. El texto adicional no interpretable deniega el cierre con un motivo claro; no se descarta silenciosamente.
>
> Autorizo versionar REQ-007 CA-41 y cambiar REQ-717 de allow a deny. Conserva el historial y declara que una forma antes aceptada deja de serlo. No clasifiques el cambio como menor únicamente por su tamaño; aplica la regla contractual vigente para determinar si necesita ADR.
>
> El mensaje debe indicar cómo conservar la evidencia: dentro del paréntesis del hallazgo, respetando la sintaxis admitida. No borres información ni normalices automáticamente hallazgos ambiguos.
>
> Incluye como mínimo estos casos:
> - `QA-006 (instrumento) — REQ-007`: deniega.
> - `SEC-A (instrumento) · SEC-B`: deniega; no ignora el segundo identificador.
> - La forma equivalente admitida con la evidencia dentro del paréntesis: permite si no existe otro bloqueo.
> - Evidencia con comas y paréntesis internos: no debe confundirse con otro hallazgo.
> - Reapertura: sigue permitida.
>
> Haz una comprobación acotada de compatibilidad en los REQ del propio arnés para identificar usos de la forma retirada. Si aparecen, informa cuáles; no modifiques consumidores ni reescribas registros históricos.
>
> Para D, queda conforme que la herramienta la ejecute quien solicita el paralelismo: el analista declara las rutas y quien despacha comprueba la disjunción antes de hacerlo. No amplíes permisos del analista.
>
> Registra esta decisión y continúa el desarrollo, QA, seguridad, push, PR en borrador y CI ya autorizados. No necesitas otra confirmación para despachar al desarrollador. Conserva el presupuesto de vueltas y agrupa las reparaciones de cada revisión.
>
> La estimación de tiempo queda como estimación, no como permiso para ampliar el alcance. Sin fusión, publicación ni cambios en consumidores.

### RESUELTA (propietario, 2026-09-27, decisión registrada íntegra ANTES de despachar) — **REQ-031: entrega acotada para la próxima versión — reparar el cierre indebido por separadores en `Hallazgos abiertos:` (A) y completar la preparación del paralelismo (D)**

**Por qué está aquí:** es la fuente íntegra del encargo (fidelidad al encargo, REQ-029). Nació como mensaje del propietario a la sesión coordinadora tras la evaluación acotada del 2026-09-27 (rama de evidencia `evidencia/prueba-despacho-2026-09-14`, `evaluacion-2026-09-27/`, commit `37ab81e`).

**Texto del propietario, literal e íntegro:**

> Autorizo una entrega acotada para preparar la próxima versión del arnés: reparar el cierre indebido por separadores y completar la preparación del paralelismo. El objetivo es resolver estos dos puntos, sin abrir una revisión general.
>
> Trabaja en una rama aislada desde main, identificando su SHA y conservando los cambios ajenos.
>
> **1. Reparar A: hallazgos bloqueantes ignorados**
>
> Usa la reproducción de `evaluacion-2026-09-27/` como evidencia inicial.
>
> La propiedad exigida es: ningún hallazgo bloqueante puede quedar ignorado por su posición o por el separador utilizado. Una lista ambigua o no interpretable debe denegar el cierre con un motivo útil; nunca se toma sólo la primera clase descartando lo demás.
>
> Define la sintaxis admitida conforme al contrato existente. No uses «cualquier separador» como especificación ni amplíes la tolerancia sin límites. Conserva las formas legítimas y distingue separadores de la prosa dentro de la evidencia.
>
> Incluye pruebas de:
> - Coma, punto y coma y `·`, con hallazgo bloqueante primero y después.
> - Hallazgos exclusivamente de instrumento y ausencia legítima de hallazgos.
> - Comas y paréntesis dentro de la evidencia.
> - Contenido adicional o mal formado que antes podía quedar ignorado.
> - Reapertura de un REQ, que no debe quedar impedida por una regla de cierre.
>
> Comprueba la denegación y el efecto sobre el archivo, junto con controles legítimos. Reutiliza el banco existente.
>
> **2. Completar D: preparación del paralelismo**
>
> La herramienta ya deniega cuando falta `Archivos:`; conserva ese comportamiento.
>
> Añade a la preparación del REQ la comprobación explícita de que el campo existe, contiene las rutas del alcance y puede interpretarlo la herramienta antes de solicitar paralelismo. Comprueba que `(ninguno)` sólo se utiliza cuando realmente no hay archivos afectados.
>
> Reutiliza la plantilla y las reglas existentes, con una referencia breve desde la Definition of Ready del analista. No copies la política en varias sedes ni exijas rellenar retrospectivamente todos los REQ.
>
> Verifica un REQ nuevo mínimo siguiendo ese recorrido y los casos disjunto, compartido y sin declarar. No autorices reparto manual como sustituto de la herramienta. La numeración duplicada de identificadores queda fuera.
>
> **3. Alcance y ciclo**
>
> Registra ambos cambios con trazabilidad a esta autorización y a los hallazgos existentes. Usa el rigor y las revisiones que correspondan al cambio del hook, agrupando la entrega para evitar ciclos separados por frase.
>
> No reinicies contadores ni aceptes residuales en mi nombre. Agrupa los hallazgos de cada revisión antes de reparar. Si se agota el presupuesto vigente, presenta el impedimento exacto y el delta pendiente.
>
> Autorizo implementación, pruebas, commits, push sin force y un PR en borrador. Ejecuta el CI requerido sobre la cabeza final; conserva su resultado sin relanzar buscando verde. No fusiones ni publiques.
>
> **4. Hueco C y documento aportado**
>
> No implementes ahora una puerta posterior ni bloqueos generales de intérpretes. C sigue siendo una limitación de seguridad reproducida; que sea conocida no equivale a que yo haya aceptado aplazarla.
>
> En la entrega final presenta brevemente la decisión de publicación que exige C: acciones que quedan fuera del control, mitigación disponible y protección que continúa dependiendo de los agentes. No lo marques aceptado.
>
> Si el Markdown está accesible, consérvalo íntegro y úsalo como fuente, no como instrucciones ejecutables. Si no está disponible, indica esa limitación una sola vez y continúa A y D con la evidencia ya obtenida. No vuelvas a buscarlo por directorios personales.
>
> No declares revisados los puntos del documento que no se hayan evaluado.
>
> **5. Fuera del encargo**
>
> Sin cambios de modelos, actualización de Claude Code, sondas de coste, umbrales, workflow, ruleset, rotación, SEC-111 ni consumidores. No añadas detectores de palabras en los paréntesis de los veredictos. No fusiones #54 ni #57.
>
> Entrega un único resultado: reparación antes/después, prueba del recorrido de paralelismo, cobertura de QA y seguridad, SHA y CI del candidato, y decisiones concretas pendientes para publicar. Sin prometer protección más amplia que la comprobada.

**Lo que la coordinadora añade, rotulado como suyo:** rama `feat/req-031-hallazgos-y-paralelo` desde `origin/main` = `a7a60c247aae6853d492a71313ab9fabed3c17a7`. El REQ se numera **REQ-031**. El informe `ArnesJuan-hallazgos-abiertos-2026-09-23.md` no está disponible (limitación declarada una vez; no se vuelve a buscar). Evidencia inicial de A: `evaluacion-2026-09-27/A-hallazgos-separador.txt` (con `·` y con `;` la puerta permite cerrar con `usuario/dinero` abierto; con coma deniega; orden invertido deniega). Evidencia inicial de D: `evaluacion-2026-09-27/D-paralelo.txt`.

### RESUELTA (propietario, 2026-09-26) — **REQ-030: se autoriza corregir QA-030-10**, segunda intervención documental por excepción adicional; historial y contadores conservados

**Texto del propietario, literal e íntegro:**

> Autorizo corregir QA-030-10 en `feat/req-030-sondas-r5`, partiendo de la cabeza local verificada. Registra esta intervención documental como excepción adicional, conservando todo el historial y los contadores.
>
> **Alcance autorizado**
>
> Corrige las dos frases señaladas en CA-07 (g) y el README del banco, y cualquier aparición equivalente de esa misma promesa excesiva en las sedes afectadas por REQ-030.
>
> La autorización cubre el defecto por propiedad, no sólo dos cadenas literales: no necesitas otra decisión mía para corregir otra repetición de la misma afirmación dentro de ese alcance.
>
> La redacción debe distinguir:
>
> - FAIL: se cumple la condición de fallo definida por el control.
> - INCONCLUSO: el funcionamiento no quedó acreditado; no demuestra por sí solo una avería.
> - PASS: acredita únicamente lo que el control mide, con los límites ya declarados.
>
> Usa la formulación acotada de ADR-012 —«sale FAIL o queda no acreditada»— donde corresponda, conservando sus condiciones. No prometas detectar toda avería ni amplíes la cobertura atribuida a C3.
>
> **Ejecución y revisión**
>
> Agrupa las correcciones en un único write-back del analista. Haz un barrido de coherencia de la misma promesa en las sedes vigentes; conserva los textos históricos como historia, sin reescribir veredictos anteriores.
>
> QA verifica el delta documental y determina QA-030-10. Sólo después de QA favorable, seguridad revisa el texto y determina SEC-110 y SEC-109. Cada veredicto debe identificar su cabeza y alcance.
>
> No repitas ensayos ni revisiones del código que no cambió. Esta intervención no demuestra mejoras de rendimiento, fiabilidad o frecuencia de resultados concluyentes.
>
> **Pendiente separado**
>
> La regla para resolver una acreditación de rendimiento pendiente de un cambio del mecanismo sigue sin definirse. No la inventes, no la des por resuelta y no conviertas una corrida favorable en resolución automática.
>
> En la entrega, explica concretamente qué acciones impide ese vacío: cierre de qué clase de REQ, integración o publicación, citando la regla aplicable. Distingue los impedimentos actuales de las limitaciones para trabajos futuros.
>
> **Límites**
>
> Sin código, mediciones nuevas, cambios de umbral, workflow, ruleset, otras sondas, consumidores, REQ-029 o PR #53. Sin nuevas familias de identificadores, formularios ni obligaciones ajenas a esta corrección.
>
> Puedes realizar los commits locales necesarios con los controles activos. Sin push, CI remoto, fusión, publicación ni cambio de versión.
>
> Entrega un único resultado breve: cabeza final, sedes corregidas, veredictos y cobertura, estado de los hallazgos y lista consolidada de impedimentos restantes. Si aparece un defecto distinto, regístralo sin encadenar su reparación. No cierres REQ-029.

**Lo que la coordinadora añade, rotulado como suyo:** sexta intervención sobre el REQ (tres vueltas, vuelta 4 por excepción, dos intervenciones documentales por excepción); nada se reinicia. Sin código, sin ensayos. Cabeza local verificada de partida: `db70d31` (código = `ccdc7e4`).

**La entrada tal como estaba, conservada:**

#### [2026-09-26] (coordinadora) — REQ-030 `bloqueado` tras la intervención documental: QA-030-10 (`contrato`, dos frases) deja SEC-110 sin cerrar; ¿se autoriza corregir esas dos sedes?

- **Contexto:** la intervención documental por excepción corrigió SEC-110 en siete sedes e incorporó SEC-109(b) fiel en sus cinco puntos (QA lo contrastó literalmente). Pero en dos sedes —`requirements/REQ-030.md` CA-07 (g) («**Qué avería detecta:** toda la que impida eso… sale FAIL si…») y `tests/escenarios/hooks/README.md` («Detecta toda avería que lo impida: sale FAIL si…»)— la promesa principal sigue siendo absoluta con la condición colgando detrás: una avería que impide el PASS dejando resueltas a ambos lados del techo o < 3 resueltas **no** se detecta, queda INCONCLUSO «no demuestra avería» (medido: `v4-fb-mezcla.log`). Es la misma forma que SEC-110 y la decisión D prohíben, y es el defecto de barrido incompleto de la promesa. **QA-030-10 (`contrato`)**, dueño `analista-requerimientos`; corrección sólo de texto: alinear las dos frases con la de ADR-012 («toda avería que lo impida sale FAIL **o queda no acreditada**»). QA no pasó a seguridad (instrucción: sólo tras QA favorable). SEC-110 y SEC-109 siguen como los dejó R-043-A. Contadores y excepciones conservados: tres vueltas, vuelta 4 por excepción, intervención documental por excepción.
- **Acción que impide (regla 2):** cerrar REQ-030. No impide presentar la entrega ni preparar el PR; no afecta a REQ-029/PR #53.
- **Opciones:** **A** — autorizar la corrección de las dos frases (analista), re-verificación documental de QA y determinación del auditor sobre SEC-110/SEC-109 (sin código, sin ensayos), registrada como segunda intervención documental por excepción. **B** — dejar REQ-030 `bloqueado`.
- **Recomendación de la coordinadora:** A. La causa es mía y del analista (barrido incompleto de la promesa, pese a la regla de barrer por propiedad); no se presenta como avance.
- **Espera:** decisión del propietario. **Trabajo que sigue mientras tanto:** ninguno de REQ-030.

*(histórica; resuelta arriba)*

### RESUELTA (propietario, 2026-09-26) — **REQ-030: intervención documental acotada para SEC-110 y decisión sobre SEC-109(b)**, excepción expresa al presupuesto agotado; contadores y excepciones anteriores conservados

**Texto del propietario, literal e íntegro:**

> Autorizo una intervención documental acotada para SEC-110 y la decisión de SEC-109(b) en `feat/req-030-sondas-r5`. Es una excepción expresa al presupuesto agotado para este write-back y su revisión; conserva todas las vueltas y excepciones anteriores, sin reiniciar contadores ni declarar que la intervención no cuenta.
>
> El objetivo sigue siendo terminar esta dependencia de REQ-029. No abras otra investigación ni reparación de código.
>
> **SEC-110**
>
> El analista corrige las cuatro sedes que prometen más cobertura de la demostrada, usando la propiedad verdadera identificada por el auditor. Deben distinguir qué avería detecta C3, qué no cubre y bajo qué condiciones queda inconcluso.
>
> Conserva los resultados medidos y sus límites. No cambies el código, los umbrales, el presupuesto de mediciones ni la regla de validación para acomodarlos a la redacción.
>
> **Decisión sobre SEC-109(b)**
>
> 1. Un inconcluso heredado de `main` no impide por sí solo integrar un PR documental que no altere el sujeto ni el instrumento medidos. Deben comprobarse los dos SHA y el conjunto de rutas correspondiente, y citarse el pendiente por identificador. Esto no elimina otros requisitos de integración ni convierte el inconcluso en PASS.
>
> 2. En un REQ que cambia el mecanismo, si la acreditación de rendimiento es un criterio exigido, su ausencia impide dar ese criterio por satisfecho y cerrar el REQ. No autorizo convertirla en deuda no bloqueante mediante la etiqueta `instrumento`, trasladarla para cerrar "por otra vía" ni exceptuarla por inferencia.
>
> 3. Registra el pendiente en la sede existente del REQ afectado, con dueño —su desarrollador— y revisión de QA y seguridad según corresponda. Si se referencia desde `docs/PENDIENTES.md`, usa un puntero: no crees una segunda versión del pendiente.
>
> 4. No acepto "una corrida posterior en PASS" como resolución automática. La acreditación debe seguir un procedimiento y presupuesto fijados antes de medir, conservar todas las ejecuciones y considerar el conjunto de resultados. No elijas una corrida favorable ni borres resultados adversos.
>
> 5. Puedes fijar 1.35.0 como hito de revisión del pendiente. Llegar a ese hito obliga a revisarlo; no lo resuelve ni autoriza el cierre automáticamente.
>
> Usa el procedimiento vigente donde sea suficiente. Si falta una regla concreta para acreditar el conjunto de resultados, identifica ese hueco y su consecuencia; no inventes otro diseño de medición dentro de este write-back.
>
> **Revisión**
>
> Agrupa el write-back en una sola intervención. QA verifica la coherencia con esta decisión y, después de QA favorable, seguridad determina el estado de SEC-110 y SEC-109. Las firmas deben indicar la cabeza y el alcance revisados.
>
> No repitas ensayos: esta autorización es documental. Conserva como limitaciones las 10 de 16 calibraciones inconclusas, el PASS cercano al techo y el carácter no medido de la estimación de rechazo. No presentes la corrección textual como mejora de fiabilidad o rendimiento.
>
> **Límites y entrega**
>
> Sin cambios en código, workflow, ruleset, otras sondas, consumidores, REQ-029 o el PR #53. El delta de workflow sigue sin aplicar.
>
> Puedes realizar commits locales con los controles activos. Sin push, CI remoto, fusión, publicación ni cambio de versión.
>
> Entrega un único resultado breve: cabeza local, textos corregidos, estados determinados por QA y seguridad, cobertura de las firmas y cualquier impedimento restante. No encadenes reparaciones adicionales ni cierres REQ-029.

**Lo que la coordinadora añade, rotulado como suyo:** se registra como **«intervención documental por excepción expresa (2026-09-26)»**, quinta intervención sobre el REQ tras las tres vueltas y la vuelta 4 por excepción; nada se reinicia ni se declara «no contado». Sin código, sin ensayos.

**Las dos entradas tal como estaban, conservadas:**

#### [2026-09-26] (coordinadora) — REQ-030: SEC-110 (`contrato`, sólo texto) impide cerrar; ¿se autoriza el write-back textual fuera del contador?

- **Contexto:** tras la vuelta 4 (excepción, opción D), `QA: aprobado` sobre `ccdc7e4` y `Seguridad: con-hallazgos` (R-043-A sobre `44f9d58`): **SEC-108 `mitigado`** (C3 en 37/2 juzga la misma calibración que decide CA-03; la avería reproducida pasó de C3 PASS a C3 FAIL), QA-030-07 y QA-030-09 cerrados. El auditor abrió **SEC-110** (`contrato`, severidad baja): la cobertura de C3 está escrita más ancha de lo que es en cuatro sedes de texto —`requirements/REQ-030.md`:270 («un instrumento averiado no puede producir PASS»; lo contradice CA-07 (g), que admite que una avería del brazo «este árbol» salga PASS) y :327-328, `ADR-012`:114 y `tests/escenarios/hooks/README.md`:452 («cubre toda avería que altere lo que mide la calibración»; una avería que la altere sin bajarla del techo da PASS, p. ej. una línea base que no es v1.32.1 pero supera 2,600×, vía SEC-048)—. Es la forma que el propietario prohibió («no prometas cobertura de toda avería posible»). Los mensajes que imprime el programa son correctos. La propiedad verdadera está redactada por el auditor en R-043-A §4. **No hay código ni medición que cambiar**; la regla de aceptación de CA-07 (e) no cambia.
- **Acción que impide (regla 2):** cerrar REQ-030 (hallazgo `contrato` abierto). No impide presentar la entrega ni preparar el PR.
- **Opciones:**
  - **A — Autorizar el write-back textual** (analista, cuatro sedes, con la propiedad de R-043-A §4) y su re-verificación por el auditor (R-043-B) y por QA sobre el texto (sin corridas nuevas: el código no cambia). No es una vuelta dev↔QA (no hay desarrollador); se registra como write-back autorizado fuera del contador, igual que SEC-102 en REQ-025.
  - **B — Dejar SEC-110 abierto** y REQ-030 sin cerrar hasta otra ventana.
- **Recomendación de la coordinadora:** A. La instrucción vigente («si aparece otro impedimento, informa sin encadenar su reparación») es la razón de que no se haya hecho ya.
- **Espera:** decisión del propietario. **Trabajo que sigue mientras tanto:** ninguno de REQ-030.

#### [2026-09-26] (analista-requerimientos) — SEC-109(b): dónde vive la «acreditación pendiente» de REQ-030 CA-08 (ii), y si un inconcluso heredado de `main` impide acogerse a la clase (i)

> **Nota del analista (2026-09-26), no del propietario: esta propuesta NO es texto vigente.** El
> propietario la resolvió arriba con otra redacción. Su «texto propuesto» —el pendiente en `Hallazgos
> abiertos:` como `instrumento` y su traslado a `docs/PENDIENTES.md` si el REQ se cerraba por otra vía—
> y su forzador «una corrida sobre la cabeza integrada o posterior con el caso en PASS» quedan
> **rechazados** por los puntos 2 a 4 de su decisión. Lo vigente está en `requirements/REQ-030.md`
> CA-08 (i) y (ii). La entrada se conserva sólo como historia.

- **Contexto:** SEC-109 (`instrumento`, R-043, `docs/seguridad/registro-seguridad.md`:7443-7462). REQ-030
  CA-08 (ii) dice que, si un PR cambia el mecanismo (`hooks/`, `tools/`) y sale con un INCONCLUSO de
  CA-03 o CA-08 (ii), la acreditación de rendimiento queda **pendiente** y no se da por satisfecha. Pero
  no dice **dónde** se registra ese pendiente, **quién** lo sigue, **qué** lo resuelve ni **cuándo**
  vence. Queda abierta esta secuencia: un PR de mecanismo con una regresión real que sale INCONCLUSO se
  integra con el check verde; desde entonces `main` da INCONCLUSO; y cada PR documental siguiente se
  integra por (i) declarando «no acreditado sobre esta cabeza». Ningún paso es falso, y la regresión
  queda **sin acreditar indefinidamente**. La mitad (a) de SEC-109, las tres formas en que una regresión
  real sale INCONCLUSO, ya está escrita en REQ-030 CA-08. Esta mitad **no** se incorporó: impone
  obligaciones nuevas y cambia qué PR puede integrar, y el propietario pidió presentarla como decisión
  pendiente.
- **Texto propuesto para REQ-030 CA-08 (ii)**, a añadir tras «…no tenga esos casos en PASS»:
  > La acreditación pendiente tiene **sede**: el REQ que cambia el mecanismo la lleva en su campo
  > `Hallazgos abiertos:` como `instrumento` mientras dure —p. ej., `PERF-<REQ>-01 (instrumento)`—, y si
  > ese REQ se cierra por otra vía autorizada, pasa a `docs/PENDIENTES.md` con los mismos datos. **Dueño:**
  > el `desarrollador` de ese REQ. **Forzador:** una corrida sobre la cabeza integrada o posterior con el
  > caso en PASS, o el siguiente cambio de clase (iii), que obliga a validar el instrumento. **Vencimiento:**
  > la ventana de versión abierta (hoy 1.35.0). Resolverlo exige esa corrida en PASS; ni la ausencia de FAIL
  > ni la integración lo resuelven.
- **Pregunta: ¿un inconcluso heredado de `main` impide acogerse a la clase (i) mientras haya un
  pendiente abierto?**
  - **Opción 1 (recomendada): no lo impide, pero obliga a citarlo.** Un PR documental puede acogerse a
    (i) con un INCONCLUSO del mismo caso; su declaración en el PR tiene que **citar por identificador** el
    pendiente abierto, y no puede presentarse como acreditación de rendimiento.
    - *Consecuencia para la integración:* los PR documentales siguen integrándose; el pendiente sigue
      visible en cada PR y no desaparece, porque tiene sede, dueño y vencimiento.
    - *Riesgo:* la regresión puede seguir viva hasta el vencimiento.
  - **Opción 2: lo impide.** Mientras exista un pendiente abierto sobre CA-03 o CA-08 (ii), ningún PR
    puede acogerse a (i) por un INCONCLUSO de ese caso.
    - *Consecuencia para la integración:* todo PR, también los documentales, queda bloqueado hasta que
      alguien obtenga el PASS o el propietario decida.
    - *Ventaja:* fuerza la acreditación enseguida.
    - *Coste:* con la frecuencia medida de calibración no resuelta (7 de 12 en local), puede bloquear
      trabajo que no toca nada medido.
  - **Sin ninguna regla (lo que hay hoy):** la secuencia de arriba no tiene forzador. La visibilidad (la
    línea `Resultado:`) existe; el seguimiento, no.
- **Responsable de aplicarlo si se aprueba:** el `analista-requerimientos` hace el write-back en REQ-030
  CA-08 (ii) y, si la opción cambia qué PR puede integrar, en CA-08 (i). El `desarrollador` de cada REQ de
  mecanismo futuro lleva el pendiente. QA y el auditor lo verifican al validar ese REQ.
- **Acción afectada:**
  - *Integrar:* qué PR puede integrarse con un INCONCLUSO de CA-03/CA-08 (ii). La opción 2 lo restringe;
    la opción 1 sólo añade una cita.
  - *Cerrar:* un REQ de mecanismo con el pendiente abierto como `instrumento` **puede** cerrarse, porque
    `guard-completado` no bloquea `instrumento`. Si el propietario quiere que no cierre, la clase tendría
    que ser `contrato`, y esa es otra decisión.
  - *Esta entrada, mientras siga en `## Pendientes`:* `guard-completado` deniega marcar **cualquier**
    REQ como `completado`, incluido REQ-030. Es deliberado.
- **Recomendación del analista:** opción 1 con el texto propuesto, que da seguimiento sin bloquear
  trabajo que no toca lo medido.
- **Trabajo que sigue mientras tanto:** la vuelta 4 de REQ-030 (SEC-108, QA-030-07 y QA-030-09) no
  depende de esta decisión y continúa.
- **Espera:** decisión del propietario.

*(históricas; resueltas arriba)*

### RESUELTA (propietario, 2026-09-26) — **REQ-030: opción D para QA-030-07/SEC-108**, una vuelta adicional por excepción, acotada a SEC-108, QA-030-07 y QA-030-09; contador 3 de 3 conservado

**Texto del propietario, literal e íntegro:**

> Elijo la opción D. Autorizo una vuelta adicional por excepción, acotada a SEC-108, QA-030-07 y QA-030-09, en `feat/req-030-sondas-r5`. Conserva las tres vueltas consumidas y registra esta autorización sin reiniciar contadores.
>
> El objetivo sigue siendo terminar la dependencia de medición que espera REQ-029, sin ampliar REQ-030.
>
> **Corrección autorizada**
>
> - Mueve el control a 37/2 y aplica el juez de C3 a la calibración que CA-03 ya ejecuta, utilizando el mismo medidor, ruta y tamaños. Retira la copia redundante de 37/7 y actualiza referencias, contrato, recuentos y autoprueba que dependan de esa retirada.
> - Esta decisión sustituye expresamente mi indicación anterior de ubicar C3 en 37/7. No autoriza levantar la restricción de compartir código entre secciones.
> - Corrige QA-030-09: el resumen debe distinguir instrumento no acreditado de rendimiento no acreditado, conservando el detalle de cada caso.
> - Mantén R=5, los umbrales y la distinción entre avería demostrada y resultado inconcluso. No transformes una calibración insuficiente en aprobación del instrumento.
>
> **Validación decisiva**
>
> Reutiliza la avería que QA reprodujo: modifica la ruta de la línea base en una copia de prueba de 37/2 y verifica que el instrumento roto ya no puede darse por acreditado por un control independiente que siga pasando.
>
> Comprueba también el recorrido normal y las distinciones existentes. Conserva todos los resultados y declara qué consecuencia es mecánica y cuál deben aplicar QA y seguridad. No prometas cobertura de toda avería posible.
>
> Fija el presupuesto antes de medir; no repitas hasta obtener verde ni abras una batería general nueva. Ejecuta las verificaciones exigidas sobre la cabeza corregida y reutiliza la evidencia que siga siendo válida.
>
> **Revisión**
>
> Desarrollador → QA del delta → seguridad sólo después de QA favorable. Cada rol determina los hallazgos y veredictos que le corresponden. No aceptes residuales en mi nombre ni apruebes por agotamiento.
>
> Para SEC-109(b), presenta la decisión pendiente de forma concreta: texto propuesto, responsable, acción afectada y consecuencia para la integración. No la incorpores como si ya estuviera autorizada ni la declares resuelta.
>
> **Límites**
>
> Conserva como limitación las 7 de 12 calibraciones locales sin resolver. Esta reparación no demuestra que esa frecuencia mejore.
>
> Sin tocar CA-09, la sección 25, otros fallos, hooks, workflow, ruleset, consumidores, REQ-029 o el PR #53. Sin ajuste de continuidad.
>
> Puedes realizar commits locales con los controles activos. Sin push, CI remoto, fusión, publicación, cambio de versión ni cierre de REQ-029.
>
> Entrega un único resultado: cabeza local, delta, reproducción antes/después, comprobaciones, veredictos y su cobertura, estado de los tres hallazgos y decisión pendiente de SEC-109(b). Si aparece otro impedimento, informa sin encadenar su reparación.

**Lo que la coordinadora añade, rotulado como suyo:** esta vuelta se registra como **«vuelta 4, por excepción expresa del propietario (2026-09-26)»**; las tres vueltas consumidas se conservan en el Historial y el contador no se reinicia. La decisión pendiente de SEC-109(b) se presentará como entrada nueva bajo `## Pendientes`, con texto propuesto, responsable, acción afectada y consecuencia, sin incorporarla al REQ.

**La entrada tal como estaba, conservada:**

#### [2026-09-26] (coordinadora) — REQ-030 `bloqueado`: tope de 3 vueltas dev↔QA agotado con QA-030-07 y QA-030-09 (`contrato`) abiertos; SEC-108 sigue abierto

- **Contexto:** vuelta 3 de 3 (opción A del propietario) sobre `7b96dcc`. La regla de CA-07 (e) **se cumplió** en las 3 corridas fijadas (I/W0 sin FAIL, WD PASS 3/3 en las dos entradas, C3 PASS 3/3 con mínimos 3,611× · 3,396× · 3,221×) y el fail-before de C3 **se cumplió** (reloj constante → FAIL «avería demostrada»; bajo el suelo → INCONCLUSO; mezcla → INCONCLUSO; los tres distintos). Pero QA reprodujo que **C3 comprueba una COPIA del instrumento** (`mat57`/`mide57`, copias de `mat37`/`mide37` de 37/2, decisión del desarrollador para no compartir código entre secciones, CA-19/H-04 de REQ-014): una avería que vive sólo en 37/2 (QA cambió la ruta de la línea base en 37/2:228-229) deja **C3 en PASS** y CA-03 en INCONCLUSO indistinguible de QA-030-05 → la regla de CA-07 (e) **acreditaría** un cambio de clase (iii) con el instrumento de CA-03 roto. Es exactamente lo que el propietario pidió que no pasara («debe comprobar que una avería del instrumento impide acreditar un cambio de la propia sonda»). **QA-030-07 (`contrato`).** Además **QA-030-09 (`contrato`)**: la línea `INCONCLUSO: N — rendimiento NO acreditado…` del resumen (`run.sh`:1549) rotula igual un C3 INCONCLUSO (instrumento no acreditado) que una medición real inconclusa; la línea del caso sí distingue. QA no pasó a seguridad (instrucción: «sólo después de QA favorable»). **SEC-108 sigue abierto** (`contrato`); SEC-109 parcialmente escrito (las tres formas), su mitad de obligaciones nuevas sigue abierta por decisión del propietario.
- **Acción que impide (regla 2):** cerrar REQ-030 y, con ello, la dependencia que REQ-029 necesita para una integración defendible. **No** impide nada de REQ-029/PR #53 por sí mismo (siguen como estaban). Contador **3 de 3 agotado**: cualquier vuelta más es excepción expresa del propietario.
- **Opciones (las tres primeras las enumeró QA sin elegir; la cuarta es de la coordinadora):**
  - **A — C3 invoca el medidor y la materialización de 37/2:** cubre el instrumento real, pero exige compartir código entre secciones (mudanza AN-021-01 de REQ-021 o excepción a CA-19/H-04 de REQ-014). Levantar un límite escrito para que quepa: señal de alcance mal elegido.
  - **B — Guarda byte a byte entre las copias de 37/7 y sus originales de 37/2** (normalizando las etiquetas `c3-`): convierte AN-021-01 en comprobado, pero **no cubre** lo que vive fuera de las funciones copiadas (el bucle de 37/2, la ruta `HER37`, tamaños y k que pasa: la avería reproducida por QA está ahí). No cierra QA-030-07 entero.
  - **C — Acotar por write-back lo que C3 promete** («avería de lo compartido») y declarar el resto residual con dueño: es aceptar un residual; **documentar no es remediar**; sólo el propietario.
  - **D — Mover el control a 37/2, aplicando el juez de C3 a la calibración que CA-03 ya mide** (la serie de v1.32.1, k=20, R=5, con el mismo `mide37`, misma ruta, mismos tamaños y k): con la palanca, «todas ≤ 2,600× → FAIL avería demostrada», mezcla o < 3 → INCONCLUSO «instrumento no acreditado», resuelta → PASS; sin palanca, la calibración sigue siendo precondición silenciosa de CA-03 como hoy. Es el fail-before retirado, con la regla de R=5 y los tres resultados, **en su sitio original**. Cubre el instrumento que decide, no comparte nada entre secciones, retira la copia de AN-021-01 y ahorra los 166–193 s de C3 con la palanca (la medición ya se hace). Se aparta de la letra «añade a 37/7» de la decisión A, no de su fin. Exige **una vuelta más** (desarrollador + QA + seguridad) por excepción expresa; QA-030-09 (una línea de `run.sh` + autoprueba) cabe en la misma.
- **Recomendación de la coordinadora:** **D**, con QA-030-09 agrupado, como excepción única y declarada al contador. Si el propietario no concede la excepción: REQ-030 queda `bloqueado` con SEC-108, QA-030-07 y QA-030-09 abiertos, y la integración de REQ-029 sigue sin esta dependencia.
- **Espera:** decisión del propietario. **Trabajo que sigue mientras tanto:** ninguno de REQ-030. *(histórica; resuelta arriba)*

### RESUELTA (propietario, 2026-09-26) — **REQ-030: opción A para SEC-108**, intervención conjunta y acotada en la vuelta 3 de 3

**Texto del propietario, literal e íntegro:**

> Elijo la opción A para SEC-108. Autorizo una intervención conjunta y acotada en `feat/req-030-sondas-r5`, usando la vuelta 3 de 3 disponible. Conserva el historial y los contadores; no los reinicies.
>
> El objetivo sigue siendo terminar esta dependencia para integrar REQ-029. No amplíes REQ-030 a otras sondas.
>
> **Reparación autorizada**
>
> Añade a 37/7 el control de medición de CA-03 necesario para cerrar SEC-108. Debe comprobar que una avería del instrumento impide acreditar un cambio de la propia sonda.
>
> Distingue expresamente:
> - Una medición real inconclusa.
> - Un control que demuestra una avería.
> - Un control que no pudo acreditar el funcionamiento del instrumento.
>
> No conviertas esos tres resultados en una misma abstención que permita aprobar el instrumento. Un control inconcluso no acredita su funcionamiento. Declara qué consecuencia aplica mecánicamente y cuál deben aplicar QA y seguridad.
>
> Fija antes de ejecutarlo el presupuesto y los resultados esperados. Reutiliza los controles y la evidencia existentes; no ajustes parámetros después de ver los resultados ni repitas hasta obtener verde.
>
> **Agrupa en esta misma vuelta**
>
> - El write-back contractual y documental necesario para SEC-108.
> - SEC-109: primero lee y explica brevemente su contenido. Si es únicamente el write-back asociado a esta reparación, inclúyelo; si requiere otra decisión o cambio de comportamiento, déjalo fuera y señálalo.
> - La actualización de la fila desfasada de REQ-030 en `requirements/README.md`, conforme a los veredictos realmente emitidos.
>
> No hace falta detenerte por la explicación de SEC-109 si encaja en ese alcance.
>
> **Validación**
>
> QA revisa el delta y sus controles; sólo después de QA favorable pasa a seguridad para determinar el estado de SEC-108 y la cobertura de su firma. No apruebes por agotamiento ni aceptes residuales en mi nombre.
>
> Reutiliza las comprobaciones válidas y ejecuta las necesarias sobre la cabeza corregida. Mantén separados el veredicto de QA y el resultado del banco completo.
>
> Conserva los FAIL de la sección 25 y los resultados inconclusos de calibración. No los atribuyas al entorno sin evidencia ni investigues sus causas en este encargo. Que la calibración no resolviera en 4 de 7 corridas sigue siendo una limitación de utilidad del procedimiento.
>
> **Límites**
>
> Sin cambios en umbrales, hooks, otras sondas, workflow o ruleset. El delta del resumen del workflow sigue preparado, sin aplicar.
>
> Sin tocar REQ-029, el PR #53, consumidores ni el ajuste de continuidad. Sin nuevas investigaciones o reparaciones colaterales.
>
> Puedes hacer commits locales con los controles activos. No hagas push ni ejecutes CI remoto todavía.
>
> **Entrega única**
>
> Cabeza local, cambios, resultado de cada control y su consecuencia, veredictos con su cobertura, estado de SEC-108 y SEC-109, y pendientes concretos. Si queda un impedimento al agotar esta vuelta, informa sin abrir otra.
>
> Sin fusión, publicación, cambio de versión ni cierre de REQ-029. No prometas que esta reparación resuelve CA-09 o el reloj de la sección 25.

**La entrada tal como estaba, conservada:**

#### [2026-09-26] (coordinadora) — REQ-030: SEC-108 (`contrato`) y QA-030-05 — qué detector mecánico conserva CA-03 cuando su instrumento se rompe, y cómo se acredita la clase (iii) si la calibración no resuelve en local

- **Contexto:** REQ-030 recorrió el ciclo completo sobre la rama local `feat/req-030-sondas-r5` (sin push): analista → desarrollador → `QA: aprobado` (vuelta 2 de 3, `322bc7c`) → `Seguridad: con-hallazgos` (R-043, `3c9b7e6`). El auditor abrió **SEC-108** (`contrato`, impide cerrar): al sustituir el caso *fail-before* de CA-03 (k=1, en `main`) por la calibración k=20 dentro del propio caso —tal como se ensayó—, **desapareció el único detector mecánico de un instrumento de CA-03 roto**: antes daba FAIL; ahora un instrumento ciego deja CA-03 en INCONCLUSO indefinidamente con el check verde, y una entrega de clase (iii) que lo rompa cumple la letra de CA-08 (iii) (CA-06 valida sólo el juez; CA-07 sólo la sonda de CA-08 (ii)). Esta entrega **no** está afectada (calibraciones resueltas medidas: CI 5/5, local 3/7). Y está ligado a **QA-030-05** (`instrumento`): en local la calibración no resolvió en 4 de 7 corridas completas, siempre por la repetición #1 de v1.32.1 (2,10–2,55× contra 2,600); en CI resolvió 5/5 con mínimos 2,699–2,809×. **SEC-109** (`instrumento`): la «acreditación pendiente» de CA-08 (ii) no tiene sede, dueño, forzador ni vencimiento, y no está declarado cuándo una regresión real sale INCONCLUSO donde la base daba FAIL. El contador dev↔QA está en **2 de 3**: queda una vuelta.
- **Acción que impide (regla 2):** **cerrar** REQ-030 (`Seguridad: con-hallazgos` + hallazgo `contrato`). **No** impide presentar la entrega ni preparar el PR; **no** afecta a REQ-029 ni al PR #53. Punto 3 del propietario («conserva los controles de regresión necesarios») es la regla que SEC-108 invoca.
- **Opciones:**
  - **A — Control de medición para CA-03 en 37/7 (a demanda, clase (iii)):** un séptimo control «la calibración de CA-03 resuelve» (v1.32.1 con k=20 supera 2,600× en ≥ 3 de 5 repeticiones): PASS si resuelve, FAIL si no. Regla de aceptación **fijada de antemano** por el analista para la validación (iii): 3 corridas fijas, todas registradas, ninguna descartada; propuesta: resuelve en **al menos 1 de 3** (un instrumento ciego no resuelve nunca; uno sano puede no resolver por ruido, QA-030-05). Tensión declarada: una regla «≥ 1 de 3» se parece a «repetir hasta verde»; lo que la distingue es el presupuesto fijo previo, que todas cuentan y que la propiedad es asimétrica (detectar lo que un instrumento ciego no puede). **Consume la vuelta 3 de 3** (desarrollador + QA + auditor). Consecuencia si QA encuentra algo más: `bloqueado` y escalado.
  - **B — Restaurar el caso fail-before en cada corrida del banco** (k=1 como en `main`, o k=20): recupera el detector mecánico en la puerta requerida, pero reintroduce el rojo por ruido que este REQ retira (2,443× medido en CI `d413405`). Contrario al objetivo del encargo.
  - **C — Aceptar SEC-108 como residual declarado** (dueño, forzador = el próximo cambio de clase (iii), vencimiento 1.35.0) y hacer el write-back de SEC-109 (sede, dueño, forzador, vencimiento de la «acreditación pendiente» y las tres formas en que una regresión sale INCONCLUSO). Sólo el propietario puede bajar un `contrato`; el auditor re-verificaría (R-043-A) sin gastar vuelta dev↔QA. Deja el banco sin detector mecánico de un instrumento de CA-03 roto hasta 1.35.0.
- **Sobre QA-030-05, en cualquier opción:** no se ajusta el techo ni k. Queda registrado con dueño (`desarrollador`, hipótesis de calentamiento de la repetición #1 **no medida**) y forzador (el primer INCONCLUSO de CA-03 en CI); investigar la causa es trabajo nuevo y no se abre sin autorización.
- **Recomendación de la coordinadora:** **A**, con el write-back de SEC-109 en la misma vuelta (analista), porque es lo que el punto 3 del propietario pide literalmente y porque C convierte el hallazgo en documentación. Si el propietario prefiere no gastar la última vuelta, C con vencimiento 1.35.0.
- **Espera:** elección del propietario entre A, B y C, y confirmación de la regla de aceptación de A si la elige. **Trabajo que sigue mientras tanto:** ninguno de REQ-030. *(histórica; resuelta arriba)*

### RESUELTA (propietario, 2026-09-26, decisión tomada fuera de la cola y registrada aquí íntegra ANTES de despachar) — **REQ-030: se AUTORIZA implementar de forma acotada el procedimiento ensayado para CA-03 y CA-08 (ii) de REQ-017, con la decisión sobre inconclusos**

**Por qué está aquí:** es la fuente íntegra y literal del encargo (`AGENTS.md` §14 y regla de fidelidad: el pedido del propietario viaja entero, nunca resumido por la coordinadora). Nació como mensaje del propietario a la sesión coordinadora tras el informe de las cinco corridas del ensayo en CI (`evidencia/prueba-despacho-2026-09-14` → `sondas-coste/ensayo-ci/resultados.md`, commit `d5ddc01`). Se copia sin cortes.

**Texto del propietario, literal e íntegro:**

> Autorizo implementar de forma acotada el procedimiento ensayado para CA-03 y CA-08 (ii) de REQ-017. Terminamos la fase experimental: reutiliza la evidencia local y las cinco corridas de CI, sin ampliar la muestra.
>
> El objetivo sigue siendo permitir una integración defendible de REQ-029 y mejorar la fiabilidad de estas dos sondas. No estamos rehaciendo todo el banco.
>
> **Decisión sobre resultados inconclusos**
>
> - Los umbrales permanecen intactos.
> - Un inconcluso significa rendimiento no acreditado; debe quedar visible en el resumen, no sólo en el log detallado.
> - Puede permitir integrar un cambio que no altere el sujeto medido ni el procedimiento de medición, con esa identidad comprobada y la limitación declarada. Esto no elimina ningún FAIL ni sustituye los demás requisitos de integración.
> - Si el cambio afecta al rendimiento medido, un inconcluso deja pendiente su acreditación y no permite darla por satisfecha.
> - Un cambio al propio instrumento, como esta entrega, requiere validar el instrumento; no puede acogerse a la excepción por "hooks idénticos".
> - No se obtiene acreditación seleccionando una corrida favorable entre otras adversas.
>
> La detección de la demora artificial es un control de la prueba, no su finalidad ni garantía de detectar cualquier regresión.
>
> **Implementación autorizada**
>
> 1. Trabaja desde `main` verificada, en una rama nueva y separada de los PR #53 y #54.
> 2. Abre el REQ acotado correspondiente y versiona los criterios afectados de REQ-017 mediante el ADR necesario, conservando su historia y los resultados anteriores.
> 3. Incorpora el presupuesto fijo de repeticiones, el evaluador y la calibración de CA-03 conforme al procedimiento ensayado. Conserva los controles de regresión necesarios, distinguiendo pruebas sintéticas del evaluador y pruebas de medición.
> 4. Los FAIL esperados de los controles deben comprobarse como resultados esperados; no deben dejar deliberadamente rojo el banco de producción.
> 5. Define quién determina si un cambio afecta al sujeto o al instrumento, qué evidencia utiliza y quién verifica esa determinación. Reutiliza el análisis de alcance y las revisiones existentes, sin crear otro agente ni una aprobación general adicional.
> 6. Declara qué parte de esta disciplina es mecánica y cuál depende de QA y seguridad. No atribuyas al workflow una protección que no implementa.
>
> **Validación**
>
> Realiza el ciclo exigido por las reglas vigentes, acotado al cambio. Reutiliza la evidencia experimental y ejecuta las verificaciones necesarias sobre la implementación final, sin repetir la investigación.
>
> Comprueba especialmente las fronteras, repeticiones no resueltas, calibración insuficiente y resultados mezclados. Mide el tiempo de la parte adoptable durante la validación normal; no abras otro experimento sólo para medirlo.
>
> No ajustes parámetros o umbrales para obtener verde. Conserva contadores y agrupa reparaciones dentro del alcance.
>
> **Fuera de alcance**
>
> CA-09 permanece intacto y con sus resultados conservados. Puede seguir bloqueando una integración; no prometas que esta entrega garantiza desbloquear el PR #53.
>
> No modifiques hooks, rulesets, consumidores, REQ-029 ni el ajuste de continuidad. El PR #54 es evidencia experimental y no se fusiona.
>
> Si la aplicación de esta decisión necesita cambiar el workflow, prepara ese delta concreto para mi aprobación antes de aplicarlo. No sustituyas esa necesidad por una afirmación documental de control automático.
>
> Puedes hacer commits locales con los controles activos. Sin push ni CI remoto todavía.
>
> **Entrega**
>
> Presenta la cabeza local, cambios, contrato actualizado, veredictos y su cobertura, resultados de validación, duración medida y limitaciones pendientes. Explica exactamente qué ocurrirá con un inconcluso en un PR documental, en un cambio del mecanismo y en un cambio de la propia sonda.
>
> Sin cerrar REQ-029, fusionar, publicar ni cambiar la versión. No encadenes otras reparaciones.

**Lo que la coordinadora añade, rotulado como suyo (no es texto del propietario):** rama `feat/req-030-sondas-r5` creada desde `origin/main` = `cfb1106` (el `main` local estaba en `cf2009e`, desfasado; no se usó). El REQ acotado se numera **REQ-030** (REQ-029 vive en el PR #53 y no está en `main`). Evidencia reutilizable, por ruta en la rama `evidencia/prueba-despacho-2026-09-14`: `sondas-coste/propuesta.md`, `sondas-coste/propuesta-sondas-REQ-017.patch`, `sondas-coste/ensayo-local/{preregistro.md,resultados.md,juez-sintetico.sh,37-coste-del-escaner-9-ensayo-controles.sh}`, `sondas-coste/ensayo-ci/{preregistro.md,resultados.md,contenido-del-experimento.diff}`.

### RESUELTA (propietario, 2026-09-23, decisión tomada fuera de la cola y registrada aquí íntegra) — **REQ-029 / QA-029-02 y QA-029-03: corrección conjunta, excepción acotada al contador agotado**

**Por qué está aquí:** procedencia de una decisión fuera del artefacto que autoriza (REQ-029 remite). Única copia literal.

> Autorizo corregir juntos QA-029-02 y QA-029-03 en `feat/fidelidad-encargo`, partiendo de la cabeza local verificada. Esta es una excepción acotada al contador agotado de REQ-029: registra la autorización y conserva todas las vueltas consumidas, sin reiniciarlas.
>
> **Correcciones autorizadas**
>
> 1. **QA-029-02:** acota la frase de QA y la referencia del analista a decisiones nuevas que requieren aprobación del propietario. Una autorización inaccesible no acredita esas decisiones. Un REQ existente con contrato y aprobaciones registrados conserva su situación aunque falte la conversación original, declarando la limitación. No cambies esta distinción ni añadas nuevos requisitos de aprobación.
>
> 2. **QA-029-03:** el analista añade `docs/ESTADO.md` al campo `Archivos:` y registra el write-back correspondiente. Comprueba que el campo cubre las rutas realmente modificadas dentro del alcance contratado. Dejar de editar ESTADO no subsana las modificaciones ya realizadas.
>
> Agrupa ambas correcciones en una sola intervención. Reutiliza el contrato, la correspondencia y la evidencia existentes; actualiza únicamente lo afectado, sin rehacer la tabla completa ni transcribir nuevamente mis instrucciones.
>
> **Validación y cierre de esta intervención**
>
> * QA revisa el delta y determina el estado de los dos hallazgos. Comprueba especialmente que la redacción distingue decisiones nuevas pendientes de autorización y contratos existentes aprobados.
> * Sólo después de QA favorable, seguridad revisa el control corregido y determina el estado de SEC-106 y la cobertura de su firma.
> * Ejecuta las comprobaciones locales exigidas y reutiliza la evidencia válida. No repitas la demo ni abras ensayos generales.
> * No aceptes residuales en mi nombre ni apruebes por agotamiento. Si aparece otro impedimento, informa de su acción afectada y su evidencia sin encadenar reparaciones.
>
> **Límites**
>
> Puedes hacer commits locales con los controles activos. Sin push, nuevas corridas de CI, cambios en sondas, umbrales, mecanismos, versión o consumidores. El FAIL del run 35924622453 se conserva.
>
> No trabajes en Adelantos. Tampoco incorpores todavía el ajuste de continuidad: queda para el siguiente encargo, contrastándolo primero con REQ-025, sin añadir otra capa de reglas.
>
> Entrega un único resultado breve: cabeza local, correcciones, comprobaciones, veredictos con su cobertura y pendientes concretos. Distingue revisión del texto de conducta observada. Sin cerrar REQ-029, fusionar ni publicar.

### RESUELTA (propietario, 2026-09-23, decisión tomada fuera de la cola y registrada aquí íntegra) — **REQ-029 / SEC-106: intervención adicional acotada, excepción expresa al contador agotado**

**Por qué está aquí:** procedencia de una decisión fuera del artefacto que autoriza (REQ-029 remite). Es la **única copia literal**.

> Autorizo una intervención adicional, acotada exclusivamente a SEC-106 en `feat/fidelidad-encargo`, PR #53. Es una excepción expresa al contador agotado de REQ-029: conserva las vueltas consumidas y registra esta autorización; no reinicies contadores.
>
> **Decisión de fondo**
>
> No acepto como autorización comprobada una referencia cuyo contenido no puede verificarse. Distingue estos dos casos:
>
> * **REQ existente con contrato y aprobaciones registrados:** la ausencia de su conversación original no invalida esas aprobaciones ni lo devuelve automáticamente a borrador. Conserva la limitación de trazabilidad.
> * **Decisión nueva que requiere al propietario:** citar una autorización inaccesible no acredita que exista ni qué alcance tiene. Aporta una copia fiel y verificable de la decisión o solicita mi confirmación concreta. Hasta resolverlo no se implementa lo dependiente; el trabajo independiente autorizado continúa conforme a las reglas vigentes.
>
> No exijas archivar conversaciones completas, no crees otra firma de QA ni conviertas decisiones técnicas ordinarias en aprobaciones humanas.
>
> **Trabajo autorizado**
>
> 1. Verifica la cabeza vigente del PR y el texto exacto que origina SEC-106.
> 2. Aplica la corrección mínima en su sede normativa y ajusta sólo las referencias, gemelas, contrato y registro necesarios para evitar contradicciones. Reutiliza los roles existentes y las revisiones exigidas, acotadas a este delta.
> 3. Corrige la presentación de SEC-106: el residual y la fecha 2026-10-23 eran propuestas del auditor, no decisiones mías. Conserva el historial y registra esta decisión sin atribuirle efecto retroactivo.
> 4. Comprueba estos casos:
>
>    * REQ previamente aprobado sin conversación original: conserva su situación.
>    * Cambio nuevo con autorización citada pero inaccesible: no se da por autorizado.
>    * Copia verificable o confirmación explícita: permite resolver la decisión dentro de su alcance.
>    * Trabajo independiente y decisión técnica ordinaria: no quedan bloqueados por esa carencia.
> 5. QA y seguridad determinan el resultado y el estado del hallazgo. Distingue comprobación del texto de conducta observada; no repitas la demo ni abras ensayos generales.
>
> **CI y límites**
>
> El FAIL del run `35924622453` sobre `d413405` se conserva. Esta autorización no permite relanzarlo, cambiar sondas, umbrales, tests, workflows ni rulesets.
>
> Puedes realizar commits locales con los controles activos. No hagas push todavía: así separamos la reparación de SEC-106 de la decisión sobre las sondas y evitamos disparar otra corrida sin autorización.
>
> No atiendas paralelismo, otros hallazgos, reparaciones de consumidores ni mejoras colaterales. Si aparece otro impedimento, identifícalo sin encadenar su reparación.
>
> Entrega un único resultado: cabeza local, diff acotado, comprobaciones, veredictos y su cobertura, estado determinado de SEC-106 y pendientes. Sin cerrar REQ-029, fusionar, publicar ni cambiar la versión.

### RESUELTA (propietario, 2026-09-23, decisión tomada fuera de la cola y registrada aquí) — **REQ-029, fidelidad al encargo: autorizada la implementación de la propuesta `fidelidad-encargo/` (`d4e7a4f`) con tres precisiones**

**Por qué está aquí:** la decisión nació en respuesta a la propuesta de la coordinadora, no como entrada pendiente; **esta entrada es su única copia literal** (`requirements/REQ-029.md` §Trazabilidad remite aquí desde el write-back de QA-029-01; corregido por SEC-105), y esta cola es la sede donde la procedencia de una decisión vive **fuera** del artefacto que autoriza (misma figura que SEC-104).

**Texto del propietario, ÍNTEGRO y literal (mensaje del 2026-09-23 a la coordinadora; esta copia sustituye a una anterior «en lo esencial» que cortaba pasajes sin marca — hallazgo QA-029-01):**

> Autorizo implementar la propuesta de fidelidad del encargo preparada en `fidelidad-encargo/`, commit `d4e7a4f`, incorporando estas tres precisiones en la misma entrega. No prepares otra ronda de propuestas.
>
> 1. **Un solo veredicto de QA.** No crees dos firmas, campos ni estados de aprobación. En la evidencia del veredicto vigente, QA indica si contrastó el REQ con la fuente, encontró diferencias o no pudo comprobarlo. La conformidad del código con el REQ no acredita por sí sola fidelidad al pedido ni permite cerrar con decisiones de alcance pendientes.
>
> 2. **Sin bloqueo retroactivo por conversaciones ausentes.** La falta del pedido original no devuelve automáticamente a `borrador` un REQ existente con contrato y decisiones aprobados. Conserva esas aprobaciones y declara la limitación de trazabilidad. Pregunta únicamente por decisiones realmente pendientes o contradicciones detectadas. En encargos nuevos, conserva la fuente desde el inicio; no reconstruyas palabras del propietario.
>
> 3. **Partir un REQ no concede autoridad sobre el alcance.** El analista puede preparar y registrar la partición conforme a las reglas vigentes. Si implica excluir, sustituir o diferir alcance comprometido, necesita la decisión correspondiente del propietario. No uses una partición para esquivar preguntas pendientes o reiniciar contadores.
>
> **Objetivo de esta entrega**
>
> Detectar omisiones, sustituciones y decisiones de negocio no autorizadas antes de implementar. Reutiliza la correspondencia en reparaciones sin cambio contractual; no exijas una tabla nueva ni una revisión completa para cada corrección.
>
> **Ejecución autorizada**
>
> * Verifica la cabeza vigente de `main` y trabaja en una rama aislada, respetando los cambios ajenos.
> * Abre el REQ acotado necesario y realiza el ciclo exigido por las reglas actuales: analista, desarrollador, QA y seguridad cuando corresponda.
> * Incluye el write-back de REQ-025 y la entrada de migración necesarios para mantener las sedes coherentes, sin reabrir sus otras entregas.
> * Conserva una sede normativa con referencias; no copies la regla completa en cada rol.
> * Agrupa las reparaciones de esta entrega y conserva sus contadores. No abras trabajos adicionales por observaciones independientes.
>
> **Validación**
>
> Comprueba gemelas y referencias, ejecuta las verificaciones locales exigidas y verifica que se distinguen estos casos:
>
> * Encargo nuevo con una obligación omitida o sustituida sin autorización.
> * REQ existente aprobado cuya conversación original no está disponible.
> * Reparación que conserva el contrato y reutiliza la correspondencia.
> * Decisión técnica ordinaria que puede avanzar sin aprobación humana adicional.
>
> Usa ejemplos acotados para verificar esas distinciones, sin repetir la demo completa. Distingue revisión del texto de conducta observada: no presentes una lectura del diff como prueba de que los agentes lo cumplirán.
>
> No inventes un encargo para medir ahorro. El coste y la utilidad en un REQ real quedan pendientes de observación si no hay uno disponible y autorizado. No afirmes reducción de tokens, tiempo o dinero.
>
> **Fuera de alcance**
>
> Reparaciones de la demo, REQ-019, otras entregas de REQ-025, sondas de coste, cambios en hooks, herramientas, permisos o umbrales. No cambies la versión ni actualices consumidores.
>
> Puedes hacer los commits locales necesarios con los controles activos. Sin push, fusión ni publicación; cualquier validación de CI pendiente debe quedar identificada.
>
> Entrega un único resultado con la cabeza revisada, cambios realizados, veredictos y su alcance, comprobaciones efectuadas, crecimiento neto del texto obligatorio y pendientes concretos. No declares acreditado lo que todavía no se haya observado.

**Ejecución:** REQ-029 creado por el analista (`1e3ac6f`), con la fila de write-back en REQ-025; implementación, QA y seguridad por el ciclo de autoalojamiento en la rama local `feat/fidelidad-encargo`.

### RESUELTA (propietario, 2026-09-21, decisión tomada fuera de la cola y registrada aquí a posteriori) — **REQ-025 entrega 1: write-back excepcional de SEC-102 y confirmaciones del residual**

**Por qué está aquí:** estas dos decisiones no nacieron como entrada pendiente —el propietario las tomó en respuesta al informe de la coordinadora— y su única copia literal vivía dentro de `requirements/REQ-025.md`, el documento que autorizan (SEC-104, `instrumento`, registro de seguridad R-041-A). La cola es la sede donde la procedencia de una decisión vive **fuera** del artefacto al que da permiso; por eso se pegan aquí literales. **Registrarlas no las convierte en aprobación de nada más.**

**Texto del propietario, literal:** «Autorizo excepcionalmente el write-back de SEC-102: incorporar las dos rutas omitidas en Archivos: y registrar la corrección en el Historial. No reinicies contadores ni abras otras reparaciones. Después, seguridad reverifica ese hallazgo y emite el estado correspondiente sobre la cabeza corregida. Reutiliza la evidencia vigente para lo que no cambie. Confirmo el 2026-10-21 como fecha de revisión del residual. Acepto que la coordinadora señale el primer caso aplicable; QA conserva la responsabilidad de verificarlo. S4 sigue "no observado". No presentes REQ-028 como dependencia para cerrar REQ-025 salvo que el contrato la establezca: haber separado trabajo no crea por sí solo esa dependencia. La entrega 1b sí permanece pendiente. Conserva SEC-103 separado y sin aceptación. Identifica la fuente exacta de la preferencia de edición por consola, sin aplicarla ni modificar configuraciones dentro de este encargo. Actualiza el PR y verifica el CI sobre la cabeza resultante. Sin nuevos ensayos, sin iniciar otras entregas, sin fusionar ni publicar.»

**Ejecución:** write-back del analista en `1932492`; reverificación de seguridad `R-041-A` sobre esa cabeza → SEC-102 `mitigado`, `Seguridad: aprobado`. Fuente de la preferencia identificada (rama de evidencia, `req-025/preferencia-consola-fuente.md`), nada modificado.

### RESUELTA (propietario, 2026-09-21) — **REQ-025 entrega 1: se ACEPTA la laguna de evidencia de QA-025-08 (opción B)**, con residual y sin sustituir ninguna firma

**Texto del propietario, literal:** «Acepto la laguna de evidencia de QA-025-08 para la entrega 1. Conserva S4 como "no observado"; no lo conviertas en satisfecho ni borres el hallazgo. Registra el residual con dueño y fecha de revisión. En el primer caso real aplicable se comprobará si la coordinadora conserva el bloqueo de QA. Si no aparece antes de la fecha, se revisa la aceptación; no se da por acreditado. Pide a QA que determine el veredicto correspondiente con esta aceptación y, si permite avanzar según las reglas vigentes, continúa con seguridad acotada. Mi aceptación no sustituye ninguna firma. OBS-H queda separado y expresamente pendiente: lo observado cuestiona una protección declarada y no queda aceptado por esta decisión. No abras su reparación ahora. Entrega el resultado con el CI de la cabeza actual. Sin nuevos ensayos, sin iniciar 1b ni REQ-028, sin fusión ni publicación.»

**Qué cambia y qué no:** QA-025-08 pasa a **residual aceptado** en `requirements/REQ-025.md` (CA-11 punto 3), con S4 conservado como **no observado**; el veredicto de QA y la firma de seguridad se emiten por sus autores con esta aceptación como dato. **OBS-H** (`guard-codigo` y un `cp` con efecto en el ensayo) **no queda aceptado** ni se repara por esta decisión.

**La entrada tal como estaba, conservada:**

#### [2026-09-21] (coordinadora) — REQ-025 entrega 1: cómo se resuelve la condición de aceptación que QA determinó pendiente (QA-025-08) *(histórica; resuelta arriba)*
- **Contexto:** la vuelta 3 de 3 se agotó con `QA: con-hallazgos` (R-3, sobre `a441e04`). Lo encargado a la vuelta 3 quedó reparado (QA-025-07, ENS-01, OBS-C, OBS-E). QA determinó, como el propietario le pidió, que **falta una condición de aceptación**: la conducta que la entrega 1 modifica —el tratamiento de un **hallazgo de QA** bajo la regla 3— no tiene evidencia de tercero; en la única corrida del ensayo QA aprobó y S4 no se disparó, y el bloqueo se conservó por la vía del **veto de seguridad**, que esta entrega **no** modifica. El propietario escribió: «no se elimina esa condición por agotarse las vueltas», «no aceptes residuales en mi nombre», «no autorizo repetir el ensayo completo ni construir mecanismos nuevos».
- **Acción que impide (regla 2):** **cerrar** — marcar `REQ-025` como `completado`. **Regla que lo impide:** `QA: con-hallazgos` y CA-13 (`guard-completado`, `AGENTS.md` §6 y §13). **No** impide implementar ni probar; **no** afecta a la entrega 1b ni a REQ-028. **Evidencia:** `docs/qa/REQ-025.md`, §«Acreditación del ensayo S1…S4» (S4) y §«Vuelta 3 de 3» (QA-025-08).
- **Opciones:**
  - ~~**A — Observación acotada de UNA sola situación**~~ — **AUTORIZADA Y CONSUMIDA (propietario, 2026-09-21; sesión `ENS-S4-P` sobre `9f908d9`): resultado NO OBSERVADO.** El desarrollador corrigió los dos defectos sembrados (CA-01 y CA-03) en su entrega, así que QA no tuvo defecto que retener y la conducta no ocurrió; nadie escribió veredictos ajenos ni cerró el REQ. QA lo acreditó en `docs/qa/REQ-025.md` §«R-3b» y determinó que **QA-025-08 sigue abierto**: dos ausencias no son una confirmación. Por instrucción del propietario («si la situación vuelve a no producirse, informa "no observado" y detente; no encadenes intentos») **no se repite**. **Ya no está disponible.**
  - **B — Cerrar con la laguna declarada**: aceptar que la entrega se acredita sin observar esa conducta, con dueño, forzador y vencimiento. **Sólo el propietario puede elegirla.** Consecuencia: la sede queda acreditada sobre el camino que el cambio no toca. Forzador propuesto por QA, que se arma solo: «la primera vez que un hallazgo de QA de cualquier REQ llegue a la clasificación de la regla 3, se anota si el bloqueo se conservó», en vez de otra sesión de ensayo.
  - **C — Mantener `Estado: bloqueado`**: detener la entrega 1 hasta otra ventana. Consecuencia: para la entrega entera por una laguna de evidencia, no por un defecto medido.
- **Recomendación (2026-09-21, tras consumir A):** B con el forzador de QA. Es la recomendación de QA y de la coordinadora; la elección es del propietario.
- **Estado tras A:** `QA: con-hallazgos (R-3b, sobre 9f908d9)`; **QA-025-05 cerrado** (CI verde verificado por QA sobre la cabeza exacta; CA-13 satisfecho; el verde no desmiente el FAIL local); `Hallazgos abiertos: QA-025-08 (instrumento)`. Seguridad (CA-11 punto 4) no emitida.
- **Espera:** elección del propietario entre B y C. **Trabajo que sigue mientras tanto:** ninguno de esta entrega. La entrega 1b y REQ-028 no dependen de esta decisión y no se arrancan sin autorización.

### RESUELTA (propietario, 2026-09-09) — **se PUBLICA `v1.33.0`**: revierte el aplazamiento de ayer, con límite declarado

**Decisión posterior y explícita del propietario**, tomada con un dato que la primera no tenía: la puerta
requerida `hooks-en-linux` está **en verde sobre el commit exacto** (`7dc0699`: 875 PASS · 0 FAIL · 9
SKIP), así que **no hacía falta saltarse nada** — la opción B (autorización para publicar en rojo) quedó
sin objeto.

**Fusionado con `jvega-habitat`, que NO tiene admin, deliberadamente.** La cuenta `JJOVEGA` estaba
autorizada por el propietario y disponible (`admin=true`, verificado), y **no se usó**: fusionar con la
cuenta sin privilegios demuestra **por construcción** que el control se satisfizo de verdad. Merge
`810128a`; tag `v1.33.0` sobre él.

**El límite bajo el que se publicó, que es la parte que importa.** La evidencia de rendimiento es el
`0,125×` acreditado de `REQ-017 CA-05` (9,60 s frente a 76,19 s, 2026-09-07), **NO** el verde de
`CA-08 (ii)`. Ese caso mide **0,973×–1,364× sobre código idéntico** contra un techo de 1,25×: su verde y
su rojo son igual de poco informativos. **No se fusionó porque el semáforo se pusiera verde** —eso habría
sido elegir la corrida que conviene, el atajo que esta misma entrada nombró y descartó— sino porque la
sustancia está acreditada por otra vía y el banco entero pasa.

**Lo que NO se revierte:** arreglar la sonda sigue siendo el **primer trabajo de 1.34.0**, por delante de
`REQ-019`. Detalle y las tres formas conformes, en `docs/PENDIENTES.md`.

### RESUELTA (propietario, 2026-09-08) — **se APLAZA el tag `v1.33.0`; la sonda se arregla en 1.34.0 por DELANTE de `REQ-019`**

Opción **C** elegida. Descartadas: **(A)** arreglar la sonda ahora dentro de esta ventana —ciclo completo, ~4 comisiones— y **(B)** publicar con el rojo bajo autorización expresa. **No se ejerció (D)**: relanzar el CI hasta obtener un verde y fusionar en esa corrida, que con una sonda cuya dispersión cubre el techo no es esperar a que pase, sino elegir la corrida que da la respuesta que se quiere.

**El argumento del propietario, en una línea:** mientras el techo viva dentro del ruido, **el verde de esa puerta no acredita nada más que el rojo** — así que publicar hoy no compraría confianza, compraría una firma vacía. Registrado en `docs/PLAN.md` como enmienda al alcance de 1.34.0.

**Estado al resolver:** `cand/1.33.0` @ `651806c`, empujada, árbol limpio. PR **#43** en `DRAFT`, sin fusionar. `REQ-014` `completado` con los tres veredictos fechados el 2026-09-08 y **cero hallazgos `contrato`**. Bloqueantes `contrato` en el repositorio: **12**, ninguno en `REQ-014`.

### La puerta requerida de `main` está ROJA, y su rojo no es evidencia — decisión del propietario (2026-09-08)

**Qué detiene.** La fusión de `cand/1.33.0` a `main` y el tag `v1.33.0`. `REQ-014` está `completado`
con los tres veredictos fechados hoy y **cero hallazgos `contrato`**; la cola estaba en 0 antes de esta
entrada. Lo único que queda en rojo es el check requerido y estricto `hooks-en-linux`.

**El caso que falla.** `REQ-017 CA-08 (ii) una cabecera de 200 líneas: el reloj no sube más de 1,25× el
de v1.32.1`. Su salida dice literalmente *«esto es una regresión, no ruido»*.

**Y está medido que no lo es.** Cuatro corridas de CI **sobre código idéntico** —ningún commit desde
`b9afa01` toca `hooks/`, `tools/` ni `.github/`, verificado de forma independiente por el
`auditor-seguridad` en `R-019`:

| Corrida | Razón publicada | Convergencia | Veredicto |
|---|---:|---|---|
| 23:39 (`921dc74`) | **1,131×** | 1,012× / 1,142× | PASS |
| 23:53 (`516e849`) | **0,973×** | 1,185× / 1,138× | PASS |
| 00:00 (`d4e0033`) | **1,337×** | 1,025× / 1,232× | FAIL |
| 00:24 (`eff143b`) | **1,364×** | 1,002× / 1,249× | FAIL |

**El argumento que cierra la discusión: `0,973×` significa que este árbol salió MÁS RÁPIDO que
`v1.32.1`.** Una regresión real no puede ser más rápida. La dispersión de la sonda va de 0,97 a 1,36
—factor **1,40**— y el techo que vigila es **1,25**: **el techo vive dentro del ruido del instrumento**,
así que el caso no puede distinguir la regresión que dice medir de su propia varianza.

**CORRECCIÓN (coordinadora, 2026-09-08): el defecto NO es «el umbral está mal puesto».** Una primera
lectura concluyó eso; **es falso**. El umbral de convergencia y el techo son el mismo número **a
propósito**, y `REQ-017 CA-08` lo argumenta: *«no es un número nuevo: es el mismo, porque un instrumento
tiene que resolver al menos el factor que vigila»*. **El caso hace exactamente lo que su criterio
prescribe**, y su hermano también.

**Lo que las cuatro corridas muestran es peor:** `CA-08` ya había pagado esta lección —documenta el
recorrido 0,821–1,010 en aislamiento y la subida sistemática bajo `JOBS=6`— y prescribió **intercalar las
series** más la comprobación de convergencia. **Está todo implementado, y no basta.**

**El hueco:** la convergencia compara el segundo mínimo de **cada árbol** con su propio mínimo —mide si
cada **serie** se asentó—, mientras que el ruido de la **razón** viene de las condiciones **entre
brazos**. Dos series pueden converger cada una a 1,2× y su cociente oscilar 1,4×. Los datos lo enseñan:
**los dos rojos son justo aquellos en que un brazo converge al borde** (1,232× y 1,249× contra el límite
de 1,250×) mientras el otro converge holgado (1,025× y 1,002×); los dos verdes están equilibrados. A
1,249× el instrumento resuelve **exactamente** 1,25 y ni un poco mejor, y sobre esa resolución afirma un
1,364×.

**La clase:** `CA-08` dice «**al menos** el factor que vigila» y eligió el valor **más flojo** compatible
con ese argumento **sin medir si alcanzaba**. Es *un criterio derivado sin comprobar su factibilidad*, la
misma clase que ya se corrigió dos veces en esta ventana.

**Clase: `instrumento`** —es un defecto de una prueba del propio arnés, no del producto—, pero **bloquea
igual**, porque el ruleset `proteger-main` hace ese check **requerido y estricto**. Es el primer caso de
la ventana en que un `instrumento` detiene una publicación, y por eso no va a `docs/PENDIENTES.md` bajo
la regla de acumulación: la regla dice que un `instrumento` no impide **cerrar un REQ**, y aquí no está
impidiendo eso.

### Las opciones, con su coste, y la que NO se hace

**A) Arreglar la sonda.** Que la convergencia se exija **estrictamente más apretada** que el techo que
protege, o que el caso haga **SKIP con motivo** cuando su propia dispersión supere ese techo — que es
exactamente lo que ya hace su caso hermano. Es cambio en `tests/`, o sea `critico` por `AGENTS.md` §6:
ciclo completo analista → desarrollador → QA → auditor. **Estimado: 4 comisiones, ~1–2 h.**

**B) Publicar con el rojo, con autorización expresa y fechada del propietario.** El check es *requerido y
estricto*, así que sólo `JJOVEGA` —dueño de los rulesets— puede saltarlo; `jvega-habitat` no tiene admin.
Queda escrito que se publicó con la puerta en rojo y por qué.

**C) Aplazar 1.33.0.** La rama queda empujada y verificada; el tag espera a que la sonda se arregle en
1.34.0, detrás de `REQ-019`.

**D) Lo que NO se hace, y se nombra para que no aparezca como atajo:** volver a lanzar el CI hasta que
salga verde y fusionar en esa corrida. Con una sonda cuya dispersión cubre el techo, eso no es esperar a
que pase: es **elegir la corrida que da la respuesta que se quiere**. Tampoco `continue-on-error` ni
sacar el caso del CI — pondría la puerta en verde **apagando la señal**, que es el modo de fallo que
`AGENTS.md` §13 nombra y que `REQ-014 CA-18 (ii)` prohíbe por escrito.

**Recomendación de la coordinadora: (C), y (A) en 1.34.0 delante de `REQ-019`.** Motivo: el rojo no
acredita ningún defecto del producto, pero **el verde tampoco acreditaría nada** mientras el techo viva
dentro del ruido — así que publicar hoy no compra confianza, compra una firma vacía. Y (A) hecho antes de
que la sonda vuelva a decidir una publicación evita repetir esta conversación en 1.34.0.

**Estado del repositorio al escribir esto:** rama `cand/1.33.0` @ `eff143b`, empujada, árbol limpio.
PR **#43** en `DRAFT`. `REQ-014` `completado`. Bloqueantes `contrato` en el repositorio: **12**, en
`REQ-013` (2), `REQ-019` (1), `REQ-020` (8) y `REQ-023` (1) — ninguno en `REQ-014`.


### RESUELTA 2026-09-08 (propietario) — La auto-auditoría se congela: los hallazgos `instrumento` sobre el propio arnés dejan de abrir REQ y de entrar en la ventana en curso

- **Contexto, con los números que la motivan.** En un solo día: **9 hallazgos de seguridad abiertos**
  (`SEC-047`…`SEC-057`), **2 REQ nuevos** (`REQ-024`, `REQ-025`), **1 REQ cerrado** (`REQ-017`) y **2 que
  fueron hacia atrás** (`REQ-021` a `bloqueado`, `REQ-014` reabierto desde `completado`). Última versión
  publicada: **v1.32.1, hace más de un día**. El propietario lo nombró así: *«siento que cada corrida de
  QA y Seguridad traen un requerimiento nuevo, y me preocupa que estemos en círculos»*.

- **La causa, y no es que los agentes sean quisquillosos.** El arnés se audita a sí mismo, y la
  auto-auditoría **no tiene punto fijo**: el estándar que aplica —*«¿este criterio mide lo que dice
  medir?»*— **se aplica también al criterio que audita**. Siempre hay una capa más abajo. Y la
  consecuencia que importa: **esto es un plugin para otros proyectos y lleva más de un día sin entregarles
  nada**, mientras consume toda la capacidad en mirarse.

- **Qué sí fue círculo y qué no, porque la distinción decide el remedio.** Círculo: `REQ-021`, cuatro
  variantes de la **misma** tautología, cada arreglo destapando la siguiente — y el arnés lo paró solo,
  que es para lo que existe el tope de 3 vueltas. **No** círculo: `REQ-017` retiró una puerta no
  determinista que corría en producción; `CA-18` en verde desbloqueó la fusión; `SEC-053` descubrió que
  **`v1.31.0` se publicó fuera de delegación** sin que nadie lo supiera.

- **DECISIÓN — la regla, y su alcance exacto.** Un hallazgo de clase **`instrumento`** sobre los textos o
  los instrumentos del propio arnés:
  1. **se registra igual** en `docs/seguridad/registro-seguridad.md` — no se deja de mirar ni de anotar;
  2. **no abre un REQ nuevo** ni entra en la ventana en curso;
  3. **se acumula en un solo backlog** que se revisa **una vez por ventana**, al planificarla.

  **Lo que la regla NO toca, dicho para que no se estire:** los hallazgos `contrato` y `usuario/dinero`
  siguen bloqueando el cierre y siguen exigiendo write-back, exactamente como hoy. Esto no baja ningún
  rigor ni apaga ninguna puerta: sólo impide que un defecto **que ya está declarado como no bloqueante**
  genere trabajo de ventana.

- **Corrección de la coordinadora sobre su propia recomendación, hecha antes de aplicarla.** Al proponer
  esta regla afirmé que **«7 de los 9 hallazgos de hoy son `instrumento`»**. Es falso: medidos, son
  **4 `instrumento` y 5 `contrato`**. La regla, por tanto, **habría frenado menos de la mitad** de lo que
  se abrió hoy — es una palanca real pero **más pequeña de lo que la vendí**, y las cinco de clase
  `contrato` habrían entrado igual. Se aplica sabiendo eso.

- **Consecuencia operativa inmediata:** 1.33.0 se publica con lo que hay —`REQ-017` cerrado y la partición
  de `CA-18` en verde— y **no entra ningún hallazgo nuevo en esta ventana**. `REQ-019` sigue siendo el
  primer y único trabajo de 1.34.0, con la protección ya escrita en `docs/PLAN.md`.


### RESUELTA 2026-09-08 (propietario) — ratificación de `v1.31.0`, publicada de autoridad no acreditada

- **Contexto.** R-016 (`auditor-seguridad`) barrió los 40 tags publicados y encontró que `v1.31.0` se
  publicó por delegación con **tres `contrato` abiertos** —`QA-114`, `QA-116`, `QA-117`—, declarados en
  las dos sedes del tag, sin entrada en la cola de aprobaciones. No se había visto en R-015 porque ese
  barrido buscó prefijos `SEC-` y estos tres son `QA-`. `SEC-053` quedó en `en-mitigación` con esta
  ratificación como su **único residual pendiente**, vencimiento antes del tag de `v1.33.0`.
- **Decisión del propietario, 2026-09-08: ratificada.** Misma resolución que ya dio para `v1.32.1`. El
  auditor cierra el residual de `SEC-053` en su registro; la coordinadora no lo hace por sí misma —es la
  misma frontera que ya se aplicó al escribir la propia regla de escalada.


### RESUELTA 2026-09-08 (propietario) — La partición autorizada es IMPOSIBLE: se reabre REQ-014 y se re-deriva CA-18

- **Contexto.** Autorizaste partir las secciones sobre 400 líneas con **desarrollador + QA**, sin analista
  ni auditor, sobre dos premisas escritas: *«el cambio es **mecánico** —mismo contenido, mismos casos,
  menos líneas por archivo—»* y *«su acreditación **ya existe y es fuerte**: un inventario ordenado de
  caso y veredicto **idéntico byte a byte**»*. El desarrollador **paró antes de tocar `tests/`** y midió
  las dos. **Las dos son falsas.**

- **Premisa 1 falsa: no es mecánico, es aritméticamente imposible.** Tres invariantes se multiplican —
  cada sección corre en **su propio subshell y en paralelo** (`run.sh:1168`, invariante `CA-04`), así que
  todo archivo partido tiene que ser **autocontenido**; `CA-19` **prohíbe** que una sección haga `source`
  de otra; y `H-04` **aborta** ante cualquier archivo de `secciones/` que no case `NN-*.sh`, así que
  tampoco cabe un auxiliar. La maquinaria compartida **no se puede factorizar**. Mínimo autónomo medido,
  **antes de meter un solo caso**:

  | | preámbulo | maquinaria | bloque indivisible | mínimo |
  |---|---|---|---|---|
  | `37/1` | 26 | 122 | 312 | **460** |
  | `37/2` | 32 | 92 | 269 + 74 | **467** |

  **El límite de `CA-18` es 400. No hay ninguna partición conforme que lo cumpla.** Y la mejor posible
  deja `CA-18` **rojo igual**: `37/1`-A **564**, `37/2`-A **467**, más `38-sondas-compartidas.sh` **827**.
  Duplicar el clasificador para separar `CA-01` de `CA-10` da **516 y 511** —las dos siguen fuera— y
  además duplica cuatro evaluaciones y la clasificación, coste que `CA-08 (i)` presupuesta. Recortar
  comentarios tampoco basta: con el código puro, el archivo del clasificador sigue en **~410**.

  > **Esto es la clase de `DEV-021-05`, y conviene nombrarla:** un criterio **derivado sin comprobar su
  > factibilidad**. `CA-18` fijó 400 sin medir cuánto mide una sección autónoma mínima. Es el mismo
  > defecto que `CA-08 (iii)`, cuyo techo de `4×` contaba cuatro ejercicios como si costaran lo mismo y
  > hubo que **re-derivarlo término a término a 6×**. Y aplica la regla que salió de ahí: **un techo no
  > se compra deformando el sujeto**, y aquí el sujeto ya no se puede deformar más — el mínimo es
  > estructural, no de estilo.

- **Premisa 2 falsa: la acreditación en la que se apoyó tu firma ya no discrimina.** Medido con **dos
  corridas intactas del banco, sin tocar nada**: 884 casos las dos, **74.046 y 74.047 bytes**, y `cmp`
  **difiere en el byte 42.659, línea 548**. **20 de 884 líneas son volátiles** —µs, razones, PID, sellos
  epoch— en `REQ-017 CA-03/04/08/09` y `REQ-021 CA-02/03/04/08`. La causa está verificada en una línea:
  `tests/escenarios/hooks/inventario.sh:24` normaliza **sólo** `[0-9]+ms` → `Nms`, y estas cifras no son
  ms.

  **Consecuencia:** el `cmp` crudo que exige `REQ-014 CA-12` **ya no puede distinguir «la partición
  cambió algo» de «el reloj avanzó»**. Es decir, la acreditación que sustituía al analista y al auditor
  **no es aplicable en este árbol**. El desarrollador construyó un oráculo **normalizado** y lo validó
  —dos corridas intactas **sí** salen idénticas bajo él: 884 líneas, 72.108 bytes, `cmp` limpio—, así que
  la acreditación es **factible**; pero el criterio, tal como está escrito, no lo es.

  > Y la sospecha del desarrollador, que suena correcta: **es probablemente la causa real de que la
  > partición se ordenara «después de cerrar REQ-021»** — las secciones que hay que partir son justo las
  > que publican las cifras volátiles.

- **Lo que el desarrollador NO hizo, y estuvo bien:** no tocó `tests/`, no comiteó, no tocó el índice, y
  **no escribió `Estado: bloqueado` en ningún REQ**. `CA-18` es de **`REQ-014`, que está `completado` con
  `QA: aprobado` y `Seguridad: aprobado`**; reabrirlo es la **REGLA DE ESTADO** de §9 y una decisión de
  gobernanza, no un efecto colateral de una comisión. Gates en verde: las tres de §7, `bash -n` sobre las
  **45** secciones con **0 rotas**, banco **880 PASS · 0 FAIL · 4 SKIP · rc 0**, y `git diff HEAD --
  tests/` **vacío**.

- **Opciones.**
  - **A) Reabrir `REQ-014` para re-derivar `CA-18` y arreglar el oráculo del inventario, y partir
    después.** Absorbe las dos premisas falsas en un solo trabajo: el analista **re-deriva el límite
    término a término** —como se hizo con `CA-08 (iii)`— desde el mínimo autónomo **medido**, y lo escribe
    como **propiedad y no como número**; y `inventario.sh` normaliza los campos volátiles, con el oráculo
    que ya está construido y validado. Después la partición es posible y su acreditación vuelve a
    discriminar. **No toca el mecanismo del corredor.** Reabre un REQ `completado`, que es exactamente lo
    que §9 manda cuando un criterio cambia.
  - **B) Mover los ayudantes compartidos a `run.sh`.** La única salida que hace `CA-18` verde **sin**
    tocar el límite. Pero es **cambio de mecanismo** → `critico` con analista y auditor, y **cambia el
    conjunto que `autoprueba-corredor.sh` deriva y vigila en `H-01`**. Más riesgo por el mismo precio.
  - **C) No fusionar 1.33.0.** `CA-18` se queda rojo y la candidata entera espera a 1.34.0, junto con
    REQ-021. Deja sin publicar el trabajo de REQ-017, que retira una puerta **no determinista** que hoy
    está publicada en `v1.32.1`.

- **Recomendación de la coordinadora: A.** El número estaba mal derivado y el árbol lo demuestra con
  aritmética, no con opinión. Re-derivar un techo infactible **no es debilitar una puerta**: es lo que
  este REQ ya hizo una vez, con el número delante. Y B cambia el corredor para no tener que admitir que
  el 400 estaba mal.

- **Lo que NO recomiendo y digo por qué, para que no aparezca luego como atajo:** poner
  `continue-on-error` en el paso de la autoprueba, o sacar `CA-18` del CI. Haría verde la puerta
  requerida **apagando la señal**, que es exactamente el modo de fallo que `AGENTS.md` §13 describe —
  *«un guard apagado protege menos que uno parcial»*— y que el propio `CA-18` existe para evitar.

- **Espera.** Tu elección entre A, B y C. **Nota de honestidad sobre el calendario:** cualquiera de las
  tres deja `v1.33.0` **fuera de hoy**, porque A y B son ciclos de cuatro agentes (~2 h cada uno) y C no
  publica. La estimación de «≈1 h al tag» que la coordinadora venía dando **era falsa**, y lo era porque
  se apoyaba en que la partición era mecánica — la misma premisa que acaba de caer.

- **RESOLUCIÓN del propietario, 2026-09-08: opción A.** Se reabre `REQ-014` por la **REGLA DE ESTADO**
  de §9: el analista re-deriva `CA-18` **término a término** desde el mínimo autónomo medido y lo enuncia
  **por propiedad, no por número**, y `inventario.sh` pasa a normalizar **lo que es medida y no
  identidad** —la propiedad que su propio comentario ya declara y cuya extensión envejeció al nombrar una
  unidad—. Los dos criterios ganan **par discriminante**: un límite que nadie puede exceder y un oráculo
  que normaliza todo no miden nada. Después la partición es posible, incluida la de
  `38-sondas-compartidas.sh`, cuya firma el propietario ya dio hoy.

- **Corrección de la coordinadora a su propia estimación, hecha en el mismo día:** el «fuera de hoy» de
  arriba **también era pesimista**. Medido con las duraciones reales de las comisiones de esta sesión
  —analista 13–21 min, desarrollador 9–43 min, QA 45 min, auditor 8–20 min—, la reapertura completa sale
  a **≈2 h 45** y `v1.33.0` **sí cabe hoy**, con **≈3 h 45** si hay una vuelta dev↔QA. Se deja escrito
  porque las dos estimaciones del día —la de «≈1 h» y la de «fuera de hoy»— fallaron en direcciones
  opuestas y ninguna publicó el dato del que salían.

### RESUELTA 2026-09-08 (propietario) — REQ-021 sale de 1.33.0: se publica sin él y su código se queda

### RESUELTA 2026-09-08 (propietario) — REQ-021 sale de 1.33.0: se publica sin él y su código se queda

- **Contexto.** `AGENTS.md` §6: máximo **3 vueltas dev↔QA por REQ**, el contador **no se reinicia**, y
  agotado el tope el REQ **o cierra con residual declarado o pasa a `bloqueado` y se escala al humano**.
  La vuelta 3 está gastada y **el residual no está disponible**: `QA-021-10` es `contrato`, y
  `guard-completado` deniega el cierre con un `contrato` abierto. Sólo existiría si QA o el auditor lo
  **reclasificaran**, y QA se negó expresamente con la evidencia delante.

- **Lo que la vuelta 3 SÍ consiguió, para que la decisión no se tome sobre un fracaso que no lo es.** El
  mecanismo cambió de razonable a comprobable: el juez obtiene el testigo **antes** de invocar la sonda,
  a coste **cero procesos**. La mutación del forzador —no ejercer el binario ni una vez— **por fin
  FALLA** (`rc 1 · 74/3`) mientras la misma copia sin mutar **PASA** (`rc 0 · 77/0`). `CA-08 (iii)`
  **mejoró** en las dos magnitudes. Banco **880 PASS · 0 FAIL · 4 SKIP, rc 0**, cuadre 884 verificado por
  QA contra 45 literales. `CA-07` acreditado en sus tres puntos (**828 casos, 61.287 bytes, `cmp`
  idénticos** contra un worktree de `794fa4c`). Las tres gates de §7 en verde.

- **Por qué no basta, y es una sola frase que conviene leer despacio.** QA reprodujo el forzador y
  **cuatro mutaciones más, tres de las cuales no leen el sujeto, y las cuatro PASAN**. La causa:
  `SP_RESOLUCION=1`, `SP_CAL_MARGEN=4` y `SONDA_DISC_PROC_VECES=2` son **literales**, así que
  `testigo = parámetro / 2` se cumple **por construcción en toda máquina**. La condición 1 exige que el
  testigo **no coincida** con el parámetro —y no coincide, 2 ≠ 4— pero **«no coincidir no es no ser
  predecible»**: lo que hace que un contraste pueda fallar es que la sonda no pueda **saber** el testigo
  sin trabajar. **El forzador nombraba un ejemplar; la clase sobrevive.** Es la **cuarta** variante de la
  misma clase dentro del mismo REQ (`2N/N`, `N−1`, el rastro que la sonda escribe, y ahora el testigo
  derivable).

- **Y una cadena de acreditación que se rompe.** `CA-03 (d)` **falla** con la carga acreditada por su
  **efecto** (tarea de referencia: 262–282 ms en reposo → 402–508 ms con 4/12 → 675–1426 ms con 12/12):
  saturación **9 de 16 corridas** con FAIL, y **8 de 13 casos son `CA-03 (c)`**, no la mitad discordante.
  El `0 de 30 en cuatro regímenes` de la vuelta 2 **se retira**: su registro **no publica ni una
  evidencia de que sus cuatro regímenes existieran**, y un régimen declarado y no acreditado es un número
  que no puede salir mal. Con él se retira **el permiso que autorizaba bajar `r` a 3** («sólo mientras
  (d) siga en 0 de 30», `REQ-021.md:788`). Las dos ramas quedan cerradas: con `r=5`, `(ii)` da **1,2825×
  > 1,25×**; con `r=3`, cumple **sobre un permiso inexistente**. **`CA-08 (ii)` no queda acreditado.**

- **Lo que QA dejó nombrado y medido, que es lo que hace esta decisión barata en cualquier dirección:**
  las dos piezas que faltan cuestan **cero procesos** — el tamaño del discordante **sorteado por
  corrida**, y la terna **fuera de todo directorio que la sonda reciba**. Con ellas, el conjunto de
  mutaciones que pasan se reduce exactamente a «lee el sujeto», y la frontera que el REQ declara
  —«falsificación deliberada, no descuido»— pasa a ser **verdadera**. Hoy es una **salida**, porque
  clasifica por la intención del autor, que ningún control mide.

- **Opciones.**
  - **A) Publicar 1.33.0 sin REQ-021.** La ventana entrega **REQ-017** —que retira una puerta **no
    determinista** y baja el reloj del banco de 95,66 s a 45,14 s— más la **partición de las tres
    secciones**. REQ-021 pasa a **1.34.0** con las dos piezas ya nombradas. *Sub-decisión que va con
    esta opción y que no resuelvo yo:* **el código de la vuelta 3 ya está comiteado** (`2ce7804`) y el
    banco está verde con él. ¿Se queda en 1.33.0 —con sus hallazgos declarados y su REQ `bloqueado`— o se
    revierte? Se queda es lo que yo haría: el árbol con él es **mejor** que sin él y el banco lo
    certifica, pero publicar código de un REQ `bloqueado` es una decisión de gobernanza tuya.
  - **B) Autorizar una vuelta 4**, excediendo el tope de §6 por decisión expresa. QA nombró exactamente
    qué falta y cuesta cero procesos, así que el trabajo está bien especificado. **El argumento en
    contra está medido:** el tope existe *«porque cada arreglo cierra el hallazgo documentado y la vuelta
    siguiente encuentra una variante»*, y ésta sería la **cuarta variante de la misma clase**. Autorizar
    la vuelta 4 es apostar contra un patrón que este REQ ha exhibido tres veces.
  - **C) A, más reducir el alcance de REQ-021 en 1.34.0** a **sólo la sonda de procesos** —**0 FAIL en
    las 48 corridas** de QA, `cal_a=2,000`/`cal_b=1,000` exactos— sacando la de reloj, que es de donde
    salen `(c)`, `(d)` y **todo** el coste que dejó `CA-08 (ii)` sin acreditar. Es el mismo patrón que ya
    aplicaste una vez en este REQ: **reducir el sujeto en vez de debilitar el techo**. No unblokea nada
    hoy —`QA-021-10` vive en la sonda de procesos— pero hace el REQ de 1.34.0 mucho más pequeño.

- **Recomendación de la coordinadora: A, con el código quedándose, y la forma de C para 1.34.0.** El
  motivo no es de calendario: es que **B apuesta contra la única cosa que este REQ ha medido tres veces
  de sí mismo**. Y 1.33.0 no se va vacía — REQ-017 retira una puerta no determinista, que es exactamente
  el tipo de defecto que este arnés existe para no publicar.

- **Espera.** Tu elección entre A, B y C, y —si eliges A o C— si el código de la vuelta 3 se queda en
  1.33.0 o se revierte. **El pipeline está detenido**: mientras esta entrada esté aquí,
  `guard-completado` deniega marcar **cualquier** REQ como `completado`.

- **RESOLUCIÓN del propietario, 2026-09-08: opción A, y el código de la vuelta 3 SE QUEDA.** 1.33.0 se
  publica con **REQ-017** y la partición de secciones; **REQ-021 pasa a 1.34.0** con las dos piezas que
  QA nombró (tamaño del discordante sorteado por corrida, y la terna fuera de todo directorio que la
  sonda reciba), las dos a coste cero procesos. El código de `2ce7804` **no se revierte**: el árbol con
  él es medible mejor que sin él y el banco lo certifica (880/0/4, `rc 0`).

- **Dos cosas que esta resolución NO decide, y quedan nombradas para que nadie las resuelva por su
  cuenta:**
  1. **`Estado:` de REQ-021 se queda en `bloqueado`**, no vuelve a `pendiente`. El tope de vueltas
     **sigue agotado** y nada de esta decisión lo cambia; ponerlo en `pendiente` borraría ese hecho.
  2. **Si el contador de vueltas se reinicia al cambiar de ventana, NO está escrito en `AGENTS.md` §6.**
     La sección sólo dice que no se reinicia «con cada hallazgo nuevo». Es una pregunta abierta con
     efecto real —decide si 1.34.0 tiene tres vueltas o cero— y la resuelve el `analista-requerimientos`
     en el write-back, con **ADR** si es cambio de fondo. La coordinadora no la interpreta.

### RESUELTA 2026-09-08 (propietario, autorización expresa) — partir las dos secciones 37 paga desarrollador + QA, sin analista ni auditor

> **AMPLIACIÓN del propietario, 2026-09-08, misma firma extendida a `38-sondas-compartidas.sh`.** La
> vuelta 3 de REQ-021 hizo crecer esa sección de **722 a 827** líneas, así que `CA-18` la nombra junto a
> las dos 37 y **la fusión seguía bloqueada aunque las 37 se partieran**. La autorización original decía
> «las dos secciones 37» y excluía por escrito «ninguna otra edición de `tests/`»: **extenderla por
> analogía habría sido la reclasificación automática que §6 prohíbe**, así que se preguntó. Mismo trato y
> mismo motivo —el cambio es mecánico y su acreditación es el inventario ordenado de caso y veredicto
> **idéntico byte a byte**, criterio central de REQ-014— y **los mismos límites**: ninguna otra edición
> de `tests/`, ningún cambio de lógica, y ningún ajuste de `CASOS_ESPERADOS` (hoy **884**) ni de
> `CASOS_ESPERADOS_SECCION` más allá del reparto aritmético que la partición obliga.
>
> **Va en comisión aparte y en SERIE, no en paralelo:** las dos particiones escriben
> `tests/escenarios/hooks/run.sh`, `tests/escenarios/hooks/README.md` y `CHANGELOG.md`, así que
> `AGENTS.md` §6 punto 3 las hace colisionar por líneas, con independencia de que sean la misma fase.
>
> **Y una nota que la ampliación obliga a dejar escrita:** la sección 38 es la de **REQ-021**, que acaba
> de quedar `bloqueado`. Partirla **no toca su lógica** ni sus veredictos —es el mismo contenido en menos
> líneas por archivo— pero el REQ vuelve a 1.34.0 con sus secciones ya repartidas, y quien retome allí
> las dos piezas que QA nombró se las encontrará en archivos distintos de los que su Historial cita.

- **Contexto.** La autoprueba del corredor sale `rc=1`: `CA-18` limita los archivos de sección a **400
  líneas** y `37-coste-del-escaner-1-escala.sh` mide **751** y `37-…-2-la-seccion-caliente.sh` **614**.
  El CI la corre como paso propio, sin `continue-on-error`, así que `hooks-en-linux` —la puerta
  requerida de `main`— se pone roja y **la fusión de 1.33.0 está bloqueada**.

  Lleva roja **desde el delta final de REQ-017**, y nadie lo vio porque el CI que marcaba `pass` en el
  PR #43 había medido `0bab7a1`, donde esas secciones median **346 y 266** líneas: la rama local estaba
  **20 commits por delante**. Es H-08 con otra cara — un verde sobre un árbol que ya no existe.

  `AGENTS.md` §6 clasifica como **crítico** «todo cambio en … el banco que los certifica (`tests/`)», y
  el rigor `critico` exige analista, desarrollador, QA **y** auditor. Sólo el propietario puede bajar
  ese nivel, y nunca por reclasificación automática de un agente.

- **Opciones.** **A)** desarrollador + QA, con autorización expresa. **B)** ciclo completo de cuatro
  agentes (~2 h). **C)** aplazar a 1.34.0 y no fusionar 1.33.0. *(Descartada de entrada: subir el límite
  de `CA-18` derrota el propósito de REQ-014 — el banco se partió en archivos para que dos agentes de QA
  puedan trabajar a la vez, y un archivo de 751 líneas es el cuello que eso vino a quitar.)*

- **Decisión del propietario: opción A.** El cambio es **mecánico** —mismo contenido, mismos casos,
  menos líneas por archivo— y su acreditación **ya existe y es fuerte**: un inventario ordenado de caso
  y veredicto **idéntico byte a byte** antes y después, que es el criterio central de REQ-014. El
  auditor no añade casi nada sobre una partición que no cambia lógica.

- **Lo que la autorización NO cubre, dicho aquí para que no se estire:** ninguna otra edición de
  `tests/`, ningún cambio de lógica dentro de las secciones partidas, y ningún ajuste de
  `CASOS_ESPERADOS` total ni de `CASOS_ESPERADOS_SECCION` más allá del reparto aritmético que la
  partición obliga. Cualquier cosa fuera de eso vuelve a `critico`.

- **Contra-argumento que quedó sobre la mesa y no se resolvió:** la auditoría preventiva **R-011** midió
  que `tests/` **no está en `codigo_app.globs`**, así que el juez de todas las sondas no lo vigila nadie
  —tampoco contra esta sesión coordinadora, que acredita, decide y publica—. Es el residual `SEC-045`,
  abierto, y esta autorización lo asume sabiéndolo.

- **Orden, y por qué no se adelanta:** la partición va **después** de cerrar REQ-021, no antes. `CA-07
  punto 2` de REQ-021 **congela** los `CASOS_ESPERADOS_SECCION` de esas dos secciones, y esa congelación
  es lo que hace acreditable la mudanza de las sondas. Partirlas antes obligaría a re-medir la
  acreditación de REQ-021 contra una línea base distinta.

### RESUELTA 2026-09-07 (coordinadora, por delegación del propietario) — aprobada la opción A: el cambio del workflow de CI viaja en 1.32.0
- **Contexto.** `AGENTS.md` §6 lista entre los gates humanos «cambiar el ruleset, **el workflow de CI**
  o el manifiesto» y clasifica como **crítico** «todo cambio en … el banco que los certifica
  (`tests/`) [y] en el workflow de CI». REQ-014 hace las dos cosas: parte `tests/escenarios/hooks/run.sh`
  (4.096 líneas) en un corredor más 35 archivos de sección, y añade a `.github/workflows/banco.yml`
  tres cosas — `bash -n` sobre `secciones/*.sh`, la comprobación del bit de ejecución en sus dos
  mitades (puntos de entrada `100755`, secciones `100644`) y un paso nuevo para
  `autoprueba-corredor.sh`. El REQ lo pide explícitamente en su CA-25.
- **Evidencia con la que se llega aquí.** Inventario de 683 casos **byte a byte idéntico** al de
  v1.31.0 publicada (`diff` vacío), tres corridas antes y tres después idénticas entre sí; cero FAIL;
  cuadre exacto global y por archivo; las 35 secciones dan el mismo veredicto en solitario que dentro
  de la vuelta completa; `git diff v1.31.0 -- hooks/ tools/` vacío; tiempo mediano 16,3 s frente a
  17,7 s antes (más rápido, dentro del techo de CA-20).
- **Opciones.** **A)** Aprobar el cambio de `tests/` y del workflow tal como está. **B)** Aprobar la
  partición del banco y dejar el workflow como estaba (se pierden `bash -n` sobre las secciones, la
  comprobación de modos y la autoprueba: el CI dejaría de ver los tres modos de fallo que la
  estructura nueva introduce). **C)** Rechazar y volver al monolito.
- **Recomendación del agente.** **A.** La partición sin las puertas nuevas en CI es la mitad peligrosa
  del cambio: una sección con la sintaxis rota no falla, **desaparece**, y sin `bash -n` en CI nadie lo
  ve hasta que el cuadre por archivo lo delate — que es exactamente lo que este paso adelanta.
- **Espera.** Aprobación del propietario para fusionar el PR de `cand/1.32.0` con el cambio de
  `.github/workflows/banco.yml` incluido.
- **Resolución.** El propietario eligió **publicar 1.32.0** el 2026-09-07, aprobando expresamente
  el cambio de `.github/workflows/banco.yml`. El `auditor-seguridad` no puso objeción de seguridad
  al cambio en R-004 y la confirmó en R-006: no añade secretos ni acciones de terceros, no usa
  `pull_request_target`, `bash -n` no ejecuta nada y `git ls-files -s` sólo lee el índice. Las dos
  observaciones que dejó —falta `permissions: contents: read` explícito y `actions/checkout@v4`
  anclado por etiqueta y no por SHA— son **preexistentes**, no las trae esta ventana, y quedan como
  deuda de endurecimiento sin dueño de ventana.


### RESUELTA 2026-09-05 (coordinadora, por delegación del propietario) — aprobada la opción B ampliada

- **Decisión:** se añaden a `codigo_app.globs` de **este** repositorio `.arnes/config.json` y
  `.claude-plugin/*`. **No** se añade `.arnes/*` entero, y no es un descuido: `/arnes-upgrade`
  escribe `.arnes/migracion.md` y `.arnes/plantillas-origen/` desde la sesión coordinadora, y
  protegerlos convertiría cada migración en una comisión al `desarrollador` sin ganar nada —
  ninguno de los dos declara una invariante.
- **Coste aceptado, dicho en voz alta:** `arnes_version` vive en el manifiesto, así que la Fase 5
  de `/arnes-upgrade` en este repositorio pasa a ser trabajo del `desarrollador`. Ocurre una vez
  por versión y coincide con el commit en el que ya sube `plugin.json` y `marketplace.json`.
- **Se conserva el control obligatorio:** la ampliación **no** se propaga a
  `templates/arnes-config.json.tpl`. Es mapeo de este repositorio, no mecanismo.
- **Lo aplica el `desarrollador`** en la vuelta siguiente, junto con REQ-010. La coordinadora no
  edita el manifiesto, ni siquiera para meterlo dentro de la frontera.

### [2026-09-05] (desarrollador) — Meter `.arnes/config.json` y `.claude-plugin/*` dentro de `codigo_app.globs` de ESTE repositorio

- **Contexto** — SEC-006 parte (a) de la auditoría R-001 (REQ-007, CA-53): hoy
  `codigo_app.globs` es `["hooks/*", "tools/*", ".github/*"]`, así que **quien no puede
  escribir `hooks/` sí puede cambiar la regla que dice qué es `hooks/`**. El manifiesto es
  la fuente de verdad ejecutable de las invariantes —quién es el agente de código, qué
  rutas protege, qué quality gates corren, cuál es el estado terminal y cuál es el techo de
  análisis de Bash—, y `.claude-plugin/plugin.json` / `marketplace.json` declaran la versión
  publicada. Es escalada de privilegios dentro del arnés. `AGENTS.md` §6 ya exige
  aprobación humana para tocar el manifiesto de este repositorio, pero eso es política, no
  enforcement. **El mecanismo que hace falta ya existe** (`guard-codigo` deniega cualquier
  ruta que case con los globs): lo único que falta es el mapeo, y el mapeo es este archivo.
- **Opciones** — **A)** Añadir `.arnes/*` y `.claude-plugin/*` a `codigo_app.globs` de
  `/.arnes/config.json` (sólo de este repositorio). **B)** Añadir sólo
  `.arnes/config.json` y dejar el resto de `.arnes/` libre. **C)** No aplicarlo y dejar el
  hueco declarado como límite en `docs/seguridad/registro-seguridad.md`.
- **Recomendación del agente** — **A**. Es el mapeo del arnés sobre sí mismo y cierra la
  escalada completa; el coste es que a partir de ahí sólo el `desarrollador` toca el
  manifiesto y la versión, que es exactamente lo que `AGENTS.md` §6 ya dice en prosa.
  Efecto colateral esperado y **no** un fallo: mientras el manifiesto no esté en los globs,
  `guard-codigo` tampoco protege el cambio que lo mete en ellos.
- **Espera** — Aprobación del propietario (Juan) para editar
  `/.arnes/config.json`, y elección entre A, B y C. **Control obligatorio de esta
  decisión, ya verificado en la candidata:** la ampliación **no** se propaga a
  `templates/arnes-config.json.tpl` — es mapeo de este repositorio, no mecanismo, y
  ningún proyecto que instale el arnés puede heredarla.

<!-- Mover aquí con: decisión tomada, quién, fecha. No borrar (histórico). -->
