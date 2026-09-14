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

### [2026-09-14] (coordinadora) — Cómo se redondea la comisión en el punto medio (REQ-002)

**Contexto.** El encargo pedido —comisión 2 % → 1,5 % según `docs/decisions/ADR-002.md`, y los
requisitos coherentes con esa decisión— está **entregado y verificado**: `src/tarifa.js` cobra
1,5 %, REQ-002 CA-01 lo dice y enlaza el ADR, con su Historial. Pero al validarlo, el `qa-tester`
abrió el hallazgo `QA-2026-09-14-01`, clase **`usuario/dinero`**, que **impide cerrar** REQ-002.

El hallazgo **no lo introdujo este cambio** y es **independiente de la tarifa**: `Math.round(monto
* COMISION * 100) / 100` opera en coma flotante IEEE-754, y los montos cuya comisión cae justo en
el medio centavo se redondean **hacia abajo** porque el producto no es representable exacto
(`11 * 0.015` da `0.16499999999999998`, no `0.165`). Reproducido por QA y **verificado de forma
independiente por la coordinadora** con el mismo método y el mismo resultado: barriendo los
2.000.001 montos de $0 a $20.000 centavo a centavo contra el cálculo exacto en enteros con
redondeo half-up, hay **2030 montos subfacturados y 0 sobrefacturados** — el error va **siempre en
contra de la empresa**. Ejemplos: $11 → cobra 0,16 en vez de 0,17; $15, $19, $37, $61, $67. El
mismo patrón existía con la tarifa anterior del 2 % (710 casos), así que lleva ahí desde el origen.
Evidencia y método: `docs/qa/REQ-002.md`.

**Por qué se detiene aquí y no lo resuelve un agente.** CA-02 dice «el resultado se redondea a dos
decimales», y el código **sí** devuelve dos decimales: lo que CA-02 **no contrata** es hacia dónde
redondear en el punto medio (half-up, half-even/bancario, o truncar). Elegir esa regla es una
**decisión de significado** sobre lo que se cobra, no una transcripción, así que ni el
`desarrollador` ni la coordinadora pueden tomarla (`AGENTS.md` §9, «quien transcribe no decide»).
Además choca de frente con el principio rector del proyecto —«cobrar lo decidido, ni más ni
menos»—, que hoy no se cumple.

**Opciones.**
- **A — Arreglarlo dentro de REQ-002.** El `analista-requerimientos` fija la regla de redondeo en
  CA-02, y luego `desarrollador` → `qa-tester` → `auditor-seguridad` (vía de la fila 3 de §6: toca
  dinero). REQ-002 cierra con la tarifa **y** el redondeo correctos. Es más trabajo del que se
  pidió.
- **B — Separarlo en un REQ nuevo.** El analista abre un REQ propio para la regla de redondeo con
  su prioridad, y REQ-002 queda en `en-revisión` hasta que ese trabajo cierre el hallazgo. No
  cierra antes: `QA-2026-09-14-01` es `usuario/dinero` y `guard-completado` deniega el cierre.
- **C — Cerrar REQ-002 con el residual declarado.** Sólo si se acepta seguir subfacturando esos
  montos por ahora; exige declarar dueño, forzador medido y vencimiento (§6). La tarifa quedaría
  correcta y el centavo, mal, por escrito.

**Recomendación de la coordinadora: A.** El defecto está en el mismo criterio (CA-02) y en el mismo
archivo que acabamos de tocar, es dinero, y el error va sistemáticamente en contra de la empresa.
Separarlo (B) paga dos veces el ciclo sobre `src/tarifa.js`; cerrarlo con residual (C) deja
incumplido el principio rector justo en el REQ que existe para cumplirlo. Si la prioridad es
entregar sólo lo pedido, **B** es la alternativa honesta; **C** sólo con la decisión explícita de
convivir con el defecto.

**Espera:** elección del humano entre A, B y C. Si es A o B, hace falta además que decidas **qué
regla** de redondeo se contrata (la habitual en facturación es **half-up**: el medio centavo sube).
Mientras esta entrada siga aquí, ningún REQ puede marcarse `completado`.

## Resueltas
<!-- Mover aquí con: decisión tomada, quién, fecha. No borrar (histórico). -->
