# Autorización — <id>

> **Qué es esta plantilla.** La forma de una autorización del propietario que encarga un trabajo en
> varias fases para que se ejecute **entero, sin parar entre fases**. Una parada entre dos fases ya
> autorizadas no protege nada: deja el trabajo esperando una respuesta que ya estaba dada. Por eso la
> autorización dice de antemano **qué se hace**, **qué decide la coordinadora sola**, **cuándo se para**
> y **cómo se retoma**.
>
> **Qué NO es.** La plantilla no autoriza nada: autoriza el texto que el propietario escribe con ella.
> Y una autorización con esta forma **no retira** ninguna revisión, firma, puerta ni aprobación humana
> que las reglas del proyecto exijan (`AGENTS.md` §6): decide **cuándo se para y se pregunta**, no **qué
> se valida**. El orden de fases, el veto de seguridad, el tope de vueltas y las puertas de cierre
> siguen rigiendo por su propia regla.
>
> **Dónde se registra.** La coordinadora la copia **literal** en `PENDING_APPROVAL.md`, sección
> «Resueltas», separada de lo que ella añada, y **citada con `> `**: un encabezado `## ` sin citar
> cerraría la sección de la cola en la que cae.
>
> **Mientras el plan esté vigente**, el bloque manual de `docs/ESTADO.md` —fuera de los marcadores del
> bloque derivado— lleva esta línea, que la coordinadora pone al día al terminar cada fase:
>
> `Plan autorizado vigente: <id>, fase N de M, siguiente acción: …`
>
> (`<id>` es el nombre con que la autorización se registra en la cola; `N` y `M`, con la numeración del
> propio plan.) Cuando el plan termina, la línea deja de estar.
>
> **Re-despachos.** Una pasada acotada o una re-firma se hacen **reanudando al mismo agente** que hizo
> la pasada anterior **sólo si su contexto es pequeño (menos de ~150 k)**. Con un contexto mayor, o si
> ese agente ya no está disponible, se despacha **uno nuevo con un encargo corto y bien escrito**. La
> reanudación no cambia qué se valida: el agente reanudado hace la misma verificación que haría uno
> nuevo. **El coste se mide en tokens no cacheados**, no con el total que da la notificación del
> agente. Ese total no cuenta la escritura de caché, y la caché de un subagente dura 5 minutos.
> Pasado ese plazo, reanudar vuelve a escribir todo su contexto: en el repositorio del arnés, con
> contextos de 300–600 k, una pasada reanudada costó más que una nueva.
>
> **Cargas largas.** Una prueba de carga o cualquier comando que dure más de unos minutos lo lanza la
> coordinadora **fuera de los agentes**, y el agente sólo lee el resultado. Un agente que espera un
> comando largo deja caducar su caché en cada espera: en el repositorio del arnés, dos comisiones con
> cargas largas costaron ≈ 1,2 M no cacheados cada una.
>
> (Normas del propietario del arnés: P-137-AJ, 2026-10-28; cifras corregidas y cargas largas por
> P-137-AM, el mismo día; umbral de ~150 k por su ajuste, en P-137-AN.)

## Plan autorizado
<!-- Qué va aquí: las fases, en orden; de cada una, quién la ejecuta y qué deja hecho. Cada fase termina en
     un commit local, y la siguiente empieza sin pedir permiso. -->

- Fase 0 — <rol>: <resultado que deja construido o escrito>. Commit local.
- Fase 1 — <rol>: <…>. Commit local.
- …

## Lo que decide la coordinadora sola
<!-- Qué va aquí: las decisiones que la coordinadora toma sin preguntar dentro de este plan (por ejemplo, no
     exhaustivo: textos, registros, orden y presupuesto de cada despacho dentro de lo propuesto). -->

- …

## Cuándo paras y me preguntas (solo esto)
<!-- Qué va aquí: la lista cerrada de motivos para parar y preguntar al propietario. Lo que no esté aquí no
     detiene el plan; las reglas del proyecto que ya exigen al propietario siguen exigiéndolo. -->

- …

<!-- Si la lista incluye «un veredicto del banco que cambia», dilo con su alcance: un caso que ejecuta el
     código del cambio o lee archivos del delta. Un caso de calibración de un instrumento (una sonda que
     mide la máquina, no el código) que cambia se registra como hallazgo `instrumento` y el plan sigue.
     (Precisión del propietario del arnés, 2026-10-05, P-136-E.) -->

## Si la sesión se corta
<!-- Qué va aquí: cómo retoma la sesión siguiente: dónde lee el plan, desde qué fase continúa (la última
     comiteada) y que no vuelve a pedir la autorización. -->

- …

<!-- Bloques optativos que el ejemplo también usa: «Decisiones del propietario», «Límites», «Entrega». -->

---

## Ejemplo (rotulado como ejemplo; no es una autorización de este proyecto)

Es la autorización que dio origen a esta plantilla, en el repositorio del arnés (ArnesJuan): **décima
autorización del propietario, 2026-10-03**, registrada íntegra en su `PENDING_APPROVAL.md` § Resueltas,
entrada «RESUELTA (propietario, 2026-10-03, décima autorización)». Se copian **literales** los cuatro
bloques y los límites; se omiten la línea de contexto del repositorio, las decisiones de su contrato y la
entrega, que están en esa sede. Los identificadores (CA-54, SEC-120…) son de aquel proyecto.

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
> *(Precisión del propietario, 2026-10-05, P-136-E: «un veredicto del banco que cambia» = un caso que ejecuta hooks o lee archivos del delta. Un caso de calibración de sonda que cambia se registra y se sigue.)*
>
> ## Si la sesión se corta
> La siguiente lee este plan en la cola y en ESTADO y continúa desde la última
> fase comiteada. No vuelve a pedir la autorización: ya está dada.
>
> ## Límites
> No SEC-120, SEC-115/118 ni nada fuera de CA-54 en esta intervención (se
> registran). No AGENTS.md ni contadores. No push, versión, PR, fusión ni tag.
