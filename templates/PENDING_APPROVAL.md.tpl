# PENDING_APPROVAL — {{NOMBRE_PROYECTO}}

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
> regla vive UNA vez en el código del arnés y la usan por igual la puerta de cierre
> (`guard-completado`), el bloque derivado de `docs/ESTADO.md` y `tools/arnes-lectura.sh`:
> **el número que lees es exactamente el que bloquea**. Y si la cola no se puede leer entera
> —un byte NUL, un archivo sin permiso—, la puerta DENIEGA y el bloque derivado dice
> `sin datos`: nunca 0.
>
> El ejemplo vive AQUÍ, fuera de la cola, y a propósito: un ejemplo dentro de la sección se
> cuenta como una pendiente real y bloquea todos los cierres.

## Pendientes

## Resueltas
<!-- Mover aquí con: decisión tomada, quién, fecha. No borrar (histórico). -->
