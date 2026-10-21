# REQ-001 — Filtrar el catálogo por color además de por categoría
Estado: pendiente
Módulo: src/catalogo/
Archivos: src/catalogo/filtro.ts
Prioridad: media
Sensible a seguridad: no
QA: pendiente
Seguridad: n/a
Hallazgos abiertos: (ninguno)
Rigor: ligero
NFR relacionados: (ninguno)

## Historia
Como cliente de la tienda, quiero filtrar el listado del catálogo también por color, además de por categoría, para encontrar más rápido lo que busco.

## Criterios de aceptación
- CA-01 · Dado un listado con ítems de varios colores, cuando se filtra sólo por `color` = «rojo», entonces el resultado contiene exactamente los ítems cuyo `color` es igual a «rojo» y ninguno más.
- CA-02 · Dado un listado, cuando se filtra por `categoria` y por `color` a la vez, entonces el resultado contiene sólo los ítems que cumplen **ambas** condiciones (conjunción).
- CA-03 · Dado un listado, cuando se filtra sólo por `categoria` (sin `color`), entonces el resultado es el mismo que antes de este REQ.
- CA-04 · Dado un listado, cuando no se indica ni `categoria` ni `color` (ausentes, `undefined`, `null` o cadena vacía), entonces se devuelven todos los ítems, en su orden original.
- CA-05 · Dado un `color` que ningún ítem tiene, cuando se filtra, entonces el resultado es una lista vacía y no se produce error.
- CA-06 · Dado un listado vacío, cuando se filtra por cualquier combinación, entonces el resultado es una lista vacía.
- CA-07 · Dado un ítem sin atributo `color`, cuando se filtra por un `color`, entonces ese ítem no aparece en el resultado; y cuando no se filtra por color, sí aparece (si cumple los demás filtros).
- CA-08 · Dado cualquier filtrado, entonces la lista de entrada no se modifica y el orden relativo de los ítems devueltos es el de la entrada.
- CA-09 · La comparación de `color` es de igualdad exacta, la misma que se usa hoy para `categoria` (sin distinguir ni normalizar mayúsculas: «Rojo» ≠ «rojo»).

## Notas / alcance
- Alcance: sólo `src/catalogo/filtro.ts`. El filtro actual (`filtrar(items, {categoria})`) acepta únicamente categoría.
- Efecto: cambia qué productos del catálogo ve el cliente; no calcula ni muestra importes, no toca sesión, autorización, datos personales ni esquema. No alcanza ningún ámbito de `rigor_politica` (dinero, sesión, seguridad, datos, arnés) ni `AGENTS.md` §6 «Qué es crítico».
- Supuestos (decisiones por defecto, coherentes con el comportamiento actual de `categoria`; el propietario no las especificó): la combinación es conjunción (CA-02); la comparación es exacta (CA-09); el ítem expone su color en un campo `color`. Si los datos reales del catálogo usan otro nombre de campo o mezclan mayúsculas, el desarrollador lo reporta como discrepancia y no la decide.
- Fuera de alcance: filtrar por varios colores a la vez, orden, paginación, interfaz de usuario (`src/ui/`), y cambios en `src/pagos/`.

## Preguntas abiertas / conflictos
(ninguna)

## Trazabilidad
Origen: mensaje del propietario, 2026-10-21 (sesión de levantamiento; no archivado en el repositorio): «Quiero que el listado del catálogo se pueda filtrar también por color, además de por categoría. Está en src/catalogo/filtro.ts.»
Tocado por: analista-requerimientos / 2026-10-21

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «se pueda filtrar también por color» | CA-01, CA-04, CA-05 | cubierta | — |
| «además de por categoría» (se conserva el filtro por categoría y se combinan) | CA-02, CA-03 | cubierta | — |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-21 | (creación) | Encargo del propietario | — |
