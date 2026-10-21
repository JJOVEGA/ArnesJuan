# REQ-001 — Filtrar el listado del catálogo por color
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
Como visitante de la tienda, quiero filtrar el listado del catálogo por color además de por categoría, para encontrar más rápido los artículos que busco.

## Criterios de aceptación
- CA-1. Dado un listado con artículos de varios colores, cuando se filtra con `color: 'rojo'` y sin categoría, entonces el resultado contiene exactamente los artículos cuyo `color` es `'rojo'`, en su orden original.
- CA-2. Dado un listado, cuando se filtra con `categoria` y `color` a la vez, entonces el resultado contiene sólo los artículos que cumplen **ambos** (conjunción).
- CA-3. Dado un listado, cuando se filtra sólo con `categoria` (sin `color`, `undefined` o cadena vacía), entonces el resultado es idéntico al de hoy (no hay regresión del filtro por categoría).
- CA-4. Dado un listado, cuando no se pasa ni `categoria` ni `color`, entonces se devuelve el listado completo.
- CA-5. (borde) Dado un `color` que ningún artículo tiene, cuando se filtra, entonces el resultado es una lista vacía y no se lanza error.
- CA-6. (borde) Dado un artículo sin campo `color`, cuando se filtra por un color, entonces ese artículo no aparece; cuando no se filtra por color, sigue apareciendo.
- CA-7. (borde) Dado un listado vacío, cuando se filtra con cualquier combinación, entonces el resultado es una lista vacía.
- CA-8. La comparación de color es por igualdad exacta de cadena (sensible a mayúsculas), igual que la de categoría hoy; el listado de entrada no se modifica.

## Notas / alcance
- Alcance: sólo la función `filtrar` de `src/catalogo/filtro.ts`; el color es un único valor por artículo (campo `color`), como la categoría.
- Fuera de alcance: filtro por varios colores a la vez, normalización de mayúsculas, interfaz de usuario, y cualquier cosa de precios o cobro.
- Clasificación (política de rigor, `.arnes/config.json`): el efecto no alcanza ningún ámbito (ningún importe, sesión, autorización, dato personal ni el arnés); `src/catalogo/**` no casa con ningún glob. Normal → `ligero`, no sensible.
- Sin NFR: no se pide ninguna cifra de rendimiento.

## Preguntas abiertas / conflictos
(ninguna)

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-21: «Quiero que el listado del catálogo se pueda filtrar también por color, además de por categoría. Está en src/catalogo/filtro.ts.»
Tocado por: analista-requerimientos / 2026-10-21

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «filtrar [el listado del catálogo] también por color» | CA-1, CA-5, CA-6, CA-7 | cubierta | — |
| «además de por categoría» (conservar el filtro por categoría y combinarlos) | CA-2, CA-3, CA-4 | cubierta | — |
| «Está en src/catalogo/filtro.ts» (ubicación del cambio) | Archivos: de la cabecera | cubierta | — |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-21 | (creación) | Pedido del propietario | — |
