# REQ-001 — Filtrar el listado del catálogo por color
Estado: borrador
Módulo: src/ (catálogo)
Archivos: src/catalogo/filtro.ts
Prioridad: media
Sensible a seguridad: no
QA: pendiente
Seguridad: n/a
Hallazgos abiertos: (ninguno)
Rigor: ligero
NFR relacionados: (ninguno)

## Historia
Como comprador que navega el catálogo, quiero filtrar el listado también por color, además de por categoría, para llegar antes a los productos que me interesan.

## Criterios de aceptación
- CA-01. Dado un listado con productos de varios colores, cuando se filtra por un color, entonces el resultado contiene todos los productos cuyo `color` es igual a ese valor (comparación `===`, igual que `categoria` hoy) y ninguno más.
- CA-02. Dado un listado con productos de varias categorías y colores, cuando se filtra por una categoría y un color a la vez, entonces el resultado contiene sólo los productos que cumplen ambas condiciones (Y lógico).
- CA-03. Dado un listado, cuando se filtra sólo por categoría (sin color), entonces el resultado es idéntico al de hoy: el comportamiento por categoría no cambia.
- CA-04. Borde: dado un filtro de color ausente, `undefined`, `null` o cadena vacía, cuando se filtra, entonces el color no restringe el resultado (misma regla que `categoria`).
- CA-05. Borde: dado un color que ningún producto tiene, cuando se filtra, entonces el resultado es una lista vacía y no se lanza ningún error.
- CA-06. Borde: dado un listado vacío, cuando se filtra por color, entonces el resultado es una lista vacía y no se lanza ningún error.
- CA-07. Error: dado un producto sin campo `color`, cuando se filtra por un color, entonces ese producto queda excluido del resultado y no se lanza ningún error.
- CA-08. La función no modifica el listado de entrada (el arreglo original conserva los mismos elementos y orden) y el resultado conserva el orden relativo del listado de entrada.

## Notas / alcance
- Alcance: lógica de filtrado en `src/catalogo/filtro.ts`. Sin cambios de precios, sesión, permisos ni esquema de datos.
- Fuera de alcance: filtro por varios colores a la vez, coincidencia sin distinguir mayúsculas, UI del selector de color, alta del atributo `color` en los datos de producto.
- Clasificación de rigor: el efecto es una selección en memoria de productos ya visibles; no cobra, no muestra importes, no toca identidad, autorización, datos personales ni esquema, y no está en ningún glob de `rigor_politica`. Normal → `ligero`.
- CA-01 a CA-08 no fijan números ni costes; no hay NFR aplicable.

## Preguntas abiertas / conflictos
- P1. ¿Los productos ya traen el campo `color` en sus datos? `filtro.ts` recibe `items` sin tipo y no hay esquema en el repo para comprobarlo. Si hay que añadir el atributo a la fuente de datos o al esquema, eso es otro cambio (ámbito `datos`) y requiere su propio REQ y clasificación.
- P2. El pedido no dice si el color se compara sin distinguir mayúsculas ("Rojo" = "rojo"), ni si se admite más de un color a la vez. CA-01 asume la misma regla que `categoria` (igualdad estricta, un solo valor); falta que el propietario lo confirme.
- Sin conflictos con otros REQ (no existe ninguno).

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-26: «Quiero que el listado del catálogo se pueda filtrar también por color, además de por categoría. Está en src/catalogo/filtro.ts.»
Tocado por: analista-requerimientos / 2026-10-26

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «el listado del catálogo se pueda filtrar también por color» | CA-01, CA-04, CA-05, CA-06, CA-07 | cubierta | — |
| «además de por categoría» (el filtro por categoría se conserva y se combina) | CA-02, CA-03 | cubierta | — |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-26 | (creación) | Encargo del propietario | — |
