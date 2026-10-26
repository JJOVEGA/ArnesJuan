# REQ-001 — Filtrar el listado del catálogo por color
Estado: borrador
Módulo: src/catalogo
Archivos: src/catalogo/filtro.ts
Prioridad: media
Sensible a seguridad: no
QA: pendiente
Seguridad: n/a
Hallazgos abiertos: (ninguno)
Rigor: ligero
NFR relacionados: (ninguno)

## Historia
Como visitante de la tienda, quiero filtrar el listado del catálogo por color además de por categoría, para encontrar más rápido los productos del color que busco.

## Criterios de aceptación
- CA-01. Dado un listado con productos de varios colores, cuando se filtra por un color, entonces `filtrar` devuelve solo los productos cuyo color es exactamente ese color y ninguno de otro color.
- CA-02. Dado un listado, cuando se filtra por categoría y por color a la vez, entonces `filtrar` devuelve solo los productos que cumplen ambas condiciones (Y, no O). *(Sujeto a la pregunta abierta 2.)*
- CA-03. Dado un listado, cuando se filtra solo por categoría (sin color), entonces el resultado es idéntico al que devuelve hoy `filtrar` (sin regresión).
- CA-04. Borde: dado un listado, cuando el color del filtro está ausente, vacío o es `undefined`/`null`, entonces no se aplica ningún filtro de color (mismo tratamiento que hoy tiene `categoria`).
- CA-05. Borde: dado un color que ningún producto tiene, cuando se filtra, entonces el resultado es una lista vacía y no se produce error.
- CA-06. Borde: dado un listado vacío, cuando se filtra por cualquier color, entonces el resultado es una lista vacía y no se produce error.
- CA-07. Error: dado un producto sin color definido, cuando se filtra por un color, entonces ese producto no aparece en el resultado y no se produce error; cuando no se filtra por color, sí aparece.
- CA-08. `filtrar` no modifica la lista de entrada: tras la llamada, la lista original conserva los mismos elementos en el mismo orden, y el resultado conserva el orden relativo de la entrada.

## Notas / alcance
- Cambio de presentación/consulta sobre `src/catalogo/filtro.ts`; no toca dinero, sesión, autorización, datos personales ni esquema, por eso no es sensible.
- Rigor: la política de `.arnes/config.json` está declarada (cinco ámbitos con globs) y `src/catalogo/**` no cae en ninguno; el efecto no cambia importes, identidad, permisos ni datos persistidos. Normal → `ligero`.
- Supuesto declarado: cada producto expone su color en un campo `color` de tipo cadena, análogo a `categoria` (ver pregunta abierta 1).
- Fuera de alcance: filtros por otros atributos, UI del listado, alta o edición de colores, normalización de datos de colores.
- Sin NFR cuantificado: el filtro es una pasada lineal sobre una lista en memoria; el propietario no pidió un umbral de rendimiento.

## Preguntas abiertas / conflictos
1. ¿Cómo se llama el campo de color en los productos y qué tipo tiene? `filtro.ts` no tipa los items y el código no lo dice; se supone `color` (cadena). Si un producto puede tener varios colores (lista), CA-01 y CA-07 cambian.
2. ¿«También por color, además de por categoría» significa combinar ambos filtros con Y (CA-02) o permitir cualquiera de ellos con O? Se redactó Y por coherencia con el filtro actual, pero no está confirmado.
3. ¿La comparación de color distingue mayúsculas/minúsculas (`Rojo` vs `rojo`)? CA-01 supone igualdad exacta, como `categoria` hoy.
Mientras estas preguntas no se resuelvan, el REQ permanece en `borrador`. No hay conflictos con otros REQ (es el primero).

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-26 (sesión de hoy)
Tocado por: analista-requerimientos / 2026-10-26

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «Quiero que el listado del catálogo se pueda filtrar también por color» | CA-01, CA-04, CA-05, CA-06, CA-07 | cubierta | — |
| «además de por categoría» (el filtro por categoría se conserva y se combina) | CA-02, CA-03 | cubierta | — (la combinación Y/O → Preguntas abiertas 2) |
| «Está en src/catalogo/filtro.ts» (el cambio va en ese archivo) | Cabecera `Archivos:` | cubierta | — |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-26 | (creación) | Encargo del propietario | — |
