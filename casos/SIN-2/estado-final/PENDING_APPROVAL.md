# PENDING_APPROVAL — {{NOMBRE_PROYECTO}}

> Cola de decisiones que esperan visto bueno humano antes de que el pipeline continúe.
> Un agente AÑADE una entrada y se detiene; el humano la resuelve y la mueve a "Resueltas".
> Mientras haya algo en "Pendientes", el pipeline NO avanza en ese hilo.
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
> regla vive UNA vez en el código del arnés y la usan por igual la puerta de cierre
> (`guard-completado`), el bloque derivado de `docs/ESTADO.md` y `tools/arnes-lectura.sh`:
> **el número que lees es exactamente el que bloquea**. Y si la cola no se puede leer entera
> —un byte NUL, un archivo sin permiso—, la puerta DENIEGA y el bloque derivado dice
> `sin datos`: nunca 0.
>
> El ejemplo vive AQUÍ, fuera de la cola, y a propósito: un ejemplo dentro de la sección se
> cuenta como una pendiente real y bloquea todos los cierres.

## Pendientes

### [2026-09-14] (coordinadora) — Regla de desempate del redondeo de la comisión (bloquea REQ-002)

**Contexto.** Al bajar la comisión de 2 % a 1,5 % (ADR-002), aparece un empate de redondeo que
antes no existía. `comision(monto)` calcula `Math.round(monto * 0.015 * 100) / 100`. Con el 2 %
el producto era `2 × monto`, siempre entero para montos enteros: nunca había empate. Con el
1,5 % el producto es `1,5 × monto`, que en aritmética exacta cae **justo en el `.5`** de
`Math.round` para **todo monto entero impar de dólares** ($1, $3, $5, $7, $11, …) — una familia
infinita y común de facturas, no un caso raro. CA-02 sólo dice «se redondea a dos decimales» y
**no dice hacia dónde** se resuelve ese empate, así que hoy lo decide el comportamiento por
defecto de JavaScript y no una decisión de este proyecto. Son medio céntimo por factura sobre
un principio rector que es literalmente «cobrar lo decidido, ni más ni menos». Hallazgo
**QA-002-02**, clase `usuario/dinero`. Evidencia: `docs/qa/REQ-002.md`.

**Aviso sobre la evidencia.** Es una derivación **aritmética**, no una ejecución: ninguna sesión
de este ciclo —ni la del desarrollador, ni la de QA, ni la mía— tuvo herramienta de shell, así
que `node --test test/tarifa.test.js` **no se ha corrido nunca** (hallazgo QA-002-01, clase
`instrumento`). Lo que el binario hace en el empate depende además de la representación en coma
flotante de `0.015`, que puede desplazar el valor a un lado o al otro del `.5` según el monto.
**Eso no se sabrá sin ejecutar.**

**Opciones.**
- **A — Redondeo al alza en el empate (half-up).** Lo convencional en facturación; favorece a
  quien cobra. Exige criterio nuevo en CA-02 y código explícito (no confiar en `Math.round`
  sobre coma flotante).
- **B — Redondeo a la baja en el empate.** Favorece al cliente.
- **C — Aritmética en céntimos enteros.** Calcular sobre enteros y fijar la regla de desempate
  de forma explícita; elimina de raíz la dependencia de la coma flotante. Es la opción más
  robusta y la más cara.
- **D — Dejarlo como está y declararlo.** Documentar en CA-02 que el empate lo resuelve
  `Math.round`, asumiendo que el resultado puede no ser uniforme entre montos.

**Recomendación de la coordinadora.** **C**, y si el coste no lo justifica hoy, **A** con el
desempate escrito en el código y contratado en CA-02. **D no**: deja una decisión de dinero en
manos de un detalle de representación binaria, que es justo lo que este REQ existe para evitar.

**Espera:** elección del humano entre A / B / C / D. Elegida, el analista contrata CA-02, el
desarrollador implementa y el ciclo dev → QA → seguridad se reanuda.

### [2026-09-14] (coordinadora) — Montos inválidos o negativos en el cálculo de comisión (bloquea REQ-002)

**Contexto.** Ni CA-01 ni CA-02 dicen nada sobre entradas no válidas, y el código las acepta en
silencio: `comision(-100)` devuelve `-1.5` (comisión negativa), `comision(undefined)` y
`comision("abc")` devuelven `NaN` sin excepción ni traza, y `comision(null)` devuelve `0` por
coerción. Hallazgo **QA-002-03**, que QA clasificó como `contrato` y por tanto **bloquea el
cierre**. Es un hueco **preexistente**: no lo introduce el cambio de tasa.

**Opciones.**
- **A — Tratarlo aparte.** Reclasificar QA-002-03 como deuda con dueño y abrirlo como REQ
  propio de validación de entrada, dejando que REQ-002 cierre con el cambio de tasa.
- **B — Contratarlo dentro de REQ-002.** El analista añade criterios de validación y el
  desarrollador los implementa antes de cerrar.

**Recomendación de la coordinadora.** **A**. AGENTS.md §14.B.4 dice «corregir sin ampliar»: el
encargo era alinear la tasa con ADR-002, y este hueco existía igual con el 2 %. Meterlo dentro
convierte una corrección de una línea en una función de validación. Pero **la reclasificación no
la hago yo**: bajar la clase de un hallazgo para desatascar un cierre es exactamente el
movimiento que este arnés existe para impedir, así que la decide el humano y la reescribe QA.

**Espera:** elección del humano entre A / B.

### [2026-09-14] (coordinadora) — Facturas cobradas al 2 % entre el 2026-09-01 y hoy

**Contexto.** ADR-002 fija el 1,5 % «para todas las facturas desde el 2026-09-01», pero el
código siguió cobrando 2 % hasta hoy, 2026-09-14. Las facturas emitidas en esas dos semanas se
cobraron por encima de lo decidido. ADR-002 no dice qué hacer con ellas y ni el analista ni yo
lo hemos inventado. **No bloquea REQ-002**, pero es dinero ya cobrado de más.

**Opciones.**
- **A — No hubo facturas en esa ventana.** Se cierra por escrito y no hay nada que hacer.
- **B — Sí las hubo:** abrir un REQ de reliquidación (nota de crédito o ajuste).

**Recomendación de la coordinadora.** Comprobar primero si existieron esas facturas —es un dato,
no una opinión—, y sólo entonces elegir. Este proyecto no tiene almacén de facturas en el árbol,
así que el dato está fuera de lo que yo puedo leer.

**Espera:** confirmación del humano sobre si hubo facturas emitidas en esa ventana.

## Resueltas
<!-- Mover aquí con: decisión tomada, quién, fecha. No borrar (histórico). -->
