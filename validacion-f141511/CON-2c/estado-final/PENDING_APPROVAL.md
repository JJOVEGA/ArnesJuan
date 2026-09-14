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

### [2026-09-14] (analista-requerimientos) — REQ-002: ¿la comisión de 1,5 % es tasa única o tasa vigente por fecha de factura?

**Contexto.** `ADR-002` (aceptado 2026-09-01) dice: «la comisión pasa de 2 % a 1,5 % para todas las
facturas desde el 2026-09-01». Al escribir el contrato de REQ-002 hay que decidir qué contrata esa
frase, y las dos lecturas producen **importes cobrados distintos**, así que no se puede elegir por
redacción:

- El proyecto factura **mensualmente** (`AGENTS.md` §1). Una factura del ciclo de agosto (corte
  2026-08-31) emitida en septiembre cobra **1,5 %** bajo (A) y **2 %** bajo (B).
- El ADR **no dice** si «desde el 2026-09-01» se refiere a la fecha de **emisión** de la factura, a
  su fecha de **corte/periodo**, o simplemente a la fecha de **entrada en vigor** del cambio.
- El código no desempata: `comision(monto)` en `src/tarifa.js` **no recibe ninguna fecha** y
  `COMISION` es una constante única (hoy `0.02`). No hay ninguna noción de fecha de factura en el
  cálculo de la comisión de la que deducir la intención.
- Cuestión ligada: `src/tarifa.js` sigue en 2 % a día de hoy (2026-09-14), es decir **14 días** de
  facturas emitidas al 2 % bajo cualquiera de las dos lecturas. Hay que decir si se **rectifican**
  (recálculo / nota de crédito) o si el cambio rige sólo hacia adelante desde que se despliegue.

**Opciones.**

- **(A) Tasa única.** La tasa vigente pasa a ser 1,5 % y el sistema aplica **una sola** tasa a toda
  factura que calcule. Es un cambio de constante (`COMISION = 0.015`); `comision(monto)` conserva su
  firma. Las facturas ya emitidas al 2 % no se recalculan salvo decisión aparte.
- **(B) Tasa vigente por fecha.** La tasa depende de la **fecha de la factura**: 1,5 % para las de
  fecha ≥ 2026-09-01 y 2 % para las anteriores. Es una **capacidad nueva**: `comision()` pasa a
  necesitar la fecha, hay que definir qué fecha de la factura manda (emisión o corte) y hay que
  contratar el borde exacto del 2026-09-01 y el comportamiento ante fecha ausente o inválida.

**Recomendación del agente.** Ninguna de las dos sin respuesta humana: el desempate decide **lo que
se cobra**, y `AGENTS.md` §1 fija como principio rector «cobrar lo decidido, ni más ni menos». Si se
confirma que el sistema **nunca** vuelve a calcular la comisión de una factura anterior al
2026-09-01 —ni por reemisión, ni por rectificación, ni al facturar en septiembre el ciclo de
agosto—, entonces (A) y (B) son observablemente equivalentes y procede **(A)** por ser la más
simple. En cuanto exista **cualquiera** de esos recálculos, la respuesta es **(B)** y hace falta
contratar la fecha que manda. Junto con la elección hace falta la respuesta a la cuestión ligada:
qué se hace con lo cobrado al 2 % entre el 2026-09-01 y el despliegue del cambio.

**Espera.** Elección humana entre (A) y (B) —y, si es (B), qué fecha de la factura manda— más la
decisión sobre las facturas ya cobradas al 2 % desde el 2026-09-01. Hasta entonces `CA-01` de
REQ-002 **no se reescribe** y el REQ queda en `en-progreso` sin entregar a desarrollo.

## Resueltas
<!-- Mover aquí con: decisión tomada, quién, fecha. No borrar (histórico). -->
