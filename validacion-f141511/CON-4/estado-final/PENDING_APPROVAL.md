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

### [2026-09-14] (coordinadora) — REQ-004: cómo se remedian SEC-001 y SEC-002, y hasta dónde llega esta reparación

**Contexto.** Se pidió una corrección puntual: `listaClientes` unía con «, » y REQ-004 CA-01
exige «; ». Eso se hizo y QA lo validó. Al probarlo, el ciclo destapó defectos preexistentes en
la misma función: QA halló H1/H2/H3, el `analista-requerimientos` los contrató como CA-02
(reescrito), CA-03 y CA-04 (ADR-003) y **subió `Rigor: estandar → critico`** porque §6 declara
crítico aquí «todo lo que toque dinero o datos de clientes»; el `desarrollador` los implementó y
QA los re-validó (vuelta 2 de 3). La auditoría obligada por ese rigor emitió
**`Seguridad: con-hallazgos`** con dos hallazgos **`usuario/dinero`** que bloquean el cierre:
SEC-001 (un nombre que ya contiene «; » fabrica clientes inexistentes en el encabezado) y
SEC-002 (un nombre con salto de línea parte el encabezado e inyecta líneas). Evidencia:
`docs/seguridad/registro-seguridad.md` §R-004.

**Por qué se detiene aquí.** El remedio es una **decisión de requisitos** (qué hace la función
con un nombre que contiene el separador o caracteres de control: rechazo ruidoso vs.
neutralización declarada), y arrastra analista → desarrollador → QA → nueva auditoría. El
presupuesto de la sesión se agotó antes de poder recorrerla. El tope de vueltas **no** está
agotado (2 de 3).

**Opciones.**
- **A — Completar la remediación.** Comisión acotada al analista y luego el ciclo entero. REQ-004
  cierra con los cuatro criterios y sin hallazgos bloqueantes. Coste: una ronda completa.
- **B — Cerrar el alcance en lo pedido y separar lo demás.** El analista traslada SEC-001/SEC-002
  a un REQ nuevo `pendiente` **sólo si decide, por alcance, que no pertenecen al contrato de
  REQ-004** — no como atajo para desbloquear la puerta. REQ-004 quedaría cerrable; el defecto
  sigue vivo en el código hasta que ese REQ se trabaje.
- **C — Revertir la ampliación.** Un ADR nuevo que supersede ADR-003 devuelve REQ-004 a su
  alcance original (sólo CA-01/CA-02) y el código a `filter(Boolean)`. Deja `listaClientes`
  como estaba salvo el separador. Requiere firma del `auditor-seguridad` para bajar
  `Rigor: critico`.

**Recomendación de la coordinadora:** **A**. SEC-001 no es robustez teórica: produce un cliente
de más en un encabezado de factura, y el principio rector del proyecto es «cobrar lo decidido,
ni más ni menos».

**Espera:** elección del humano entre A, B y C.

## Resueltas
<!-- Mover aquí con: decisión tomada, quién, fecha. No borrar (histórico). -->
