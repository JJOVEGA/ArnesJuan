# REQ-001 — Filtrar el listado del catálogo por color
Estado: borrador
Módulo: catálogo (src/catalogo/)
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
- CA-01 (color solo) — Dado un listado con artículos de distintos colores, Cuando se filtra indicando solo un color, Entonces el resultado contiene únicamente los artículos cuyo color es ese y ninguno de otro color.
- CA-02 (color y categoría) — Dado un listado con artículos de varias categorías y colores, Cuando se filtra indicando una categoría y un color, Entonces el resultado contiene únicamente los artículos que cumplen ambas condiciones a la vez (interpretación de «además de»; confirmar en Preguntas abiertas, P-1).
- CA-03 (sin regresión) — Dado un listado, Cuando se filtra indicando solo categoría, o ningún criterio, Entonces el resultado es idéntico al que devuelve hoy `filtrar` en `src/catalogo/filtro.ts` (solo categoría: los de esa categoría; sin criterios: todos).
- CA-04 (borde: sin coincidencias) — Dado un listado, Cuando se filtra por un color que ningún artículo tiene, Entonces el resultado es una lista vacía y no se produce error.
- CA-05 (borde: listado vacío) — Dado un listado vacío, Cuando se filtra por color, por categoría o por ambos, Entonces el resultado es una lista vacía y no se produce error.
- CA-06 (no mutación) — Dado un listado, Cuando se filtra por color, Entonces el listado de entrada queda sin modificar y el resultado contiene los mismos elementos (no copias alteradas) en su orden original.

## Notas / alcance
- Efecto: cambia qué artículos se muestran en el listado; no toca importes, precios, sesión, autorización, datos personales ni esquema. Política de rigor (`rigor_politica`, declarada con los cinco ámbitos): `src/catalogo/filtro.ts` no casa con ningún glob de ámbito y el efecto no alcanza ninguno → normal: `ligero`, no sensible.
- Fuera de alcance (no pedido): ordenar, buscar por texto, filtrar por otros atributos, interfaz gráfica del selector de color.
- Sin NFR: el pedido no da umbral de rendimiento ni volumen; no se inventa ninguno.

## Preguntas abiertas / conflictos
- P-1: «además de por categoría», ¿significa combinar ambos filtros (el artículo debe cumplir categoría Y color, como asume CA-02) o que se pueda usar uno u otro de forma alternativa (O)?
- P-2: ¿Cómo se compara el color? Mayúsculas/minúsculas («Rojo» vs «rojo»), acentos y espacios sobrantes.
- P-3: ¿Un artículo puede tener varios colores (p. ej. «rojo y azul»)? Si sí, ¿coincide con cualquiera de ellos?
- P-4: ¿Qué se hace con artículos sin color definido cuando se filtra por color: se excluyen (supuesto actual) o se muestran?
- P-5: ¿Se puede filtrar por varios colores a la vez (p. ej. rojo o azul), o solo por uno?
- P-6: ¿Una cadena de color vacía equivale a «sin filtro de color»? (supuesto actual: sí, igual que hoy con categoría).
- P-7: ¿El color se identifica en los datos por un campo `color` de cada artículo? (No consta en el repositorio: `filtro.ts` solo usa `categoria`.)
- Mientras estas preguntas sigan abiertas el REQ permanece en `borrador` y no se entrega a desarrollo. No hay interlocutor disponible en esta sesión para resolverlas.

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-26 (sesión con el analista)
Tocado por: analista-requerimientos / 2026-10-26

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «Quiero que el listado del catálogo se pueda filtrar también por color» | CA-01, CA-04, CA-05, CA-06 | cubierta | n/a |
| «además de por categoría» (conservar el filtro por categoría y poder usarlo con el de color) | CA-02, CA-03 | cubierta | n/a (el significado Y/O de «además» queda en P-1) |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-26 | (creación) | Encargo del propietario | — |
