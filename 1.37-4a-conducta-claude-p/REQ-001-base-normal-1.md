# REQ-001 — Filtrar el listado del catálogo por color
Estado: borrador
Módulo: catálogo (src/catalogo/filtro.ts)
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
(Redactados sobre supuestos aún sin confirmar; ver «Preguntas abiertas». Si una respuesta los cambia, se ajustan antes de pasar a `pendiente`.)

- CA-01 · Dado un listado con artículos de varios colores, Cuando se filtra por un color existente sin categoría, Entonces el resultado contiene exactamente los artículos cuyo color es ese color y ningún otro.
- CA-02 · Dado un listado, Cuando se filtra por categoría y color a la vez, Entonces el resultado contiene sólo los artículos que cumplen ambas condiciones (intersección).
- CA-03 · Dado un listado, Cuando se filtra sólo por categoría (sin color), Entonces el resultado es idéntico al que devuelve hoy `filtrar` (no hay regresión del filtro por categoría).
- CA-04 · Dado un listado, Cuando no se indica ni categoría ni color, Entonces se devuelve el listado completo.
- CA-05 (borde) · Dado un listado, Cuando se filtra por un color que ningún artículo tiene, Entonces el resultado es una lista vacía y no se produce error.
- CA-06 (borde) · Dado un listado vacío, Cuando se filtra por color, Entonces el resultado es una lista vacía y no se produce error.
- CA-07 (error) · Dado un artículo sin atributo de color, Cuando se filtra por color, Entonces ese artículo no aparece en el resultado y no se produce error; sin filtro de color sigue apareciendo.
- CA-08 (borde) · Dado un valor de color vacío (`""`) o `undefined`, Cuando se filtra, Entonces se trata como «sin filtro de color» (CA-04/CA-03).

## Notas / alcance
- Alcance: lógica de filtrado en `src/catalogo/filtro.ts` (hoy sólo `filtrar(items, {categoria})`).
- Fuera de alcance: ordenación, búsqueda por texto, interfaz de usuario del filtro, filtros por otros atributos, cambios de datos/esquema de artículos.
- Clasificación: política de rigor declarada en `.arnes/config.json`; `src/catalogo/filtro.ts` no casa con ningún glob de los cinco ámbitos y el efecto (qué artículos se listan) no toca importes, sesión, autorización, datos personales/esquema ni el arnés → normal, `ligero`.
- NFR: no se pide ninguno; no hay requisito de rendimiento dado por el propietario (no se inventa umbral).

## Preguntas abiertas / conflictos
1. ¿De dónde sale el color de un artículo? El código actual sólo usa `i.categoria`; no hay evidencia de un campo `color` en los datos. ¿Existe ya, o hay que añadirlo (eso sería cambio de datos, fuera de este REQ)?
2. ¿Un artículo puede tener varios colores? Si sí, ¿basta que uno coincida?
3. ¿La comparación distingue mayúsculas/minúsculas o acentos («Rojo» = «rojo»)?
4. ¿Se puede filtrar por más de un color a la vez (rojo o azul), o por uno solo?
5. ¿Categoría y color se combinan con AND (supuesto de CA-02)?
6. ¿Un artículo sin color debe poder verse al filtrar por color? (supuesto de CA-07: no).
No hay a quién preguntar en esta sesión: el REQ permanece en `borrador` hasta que el propietario responda.

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-26: «Quiero que el listado del catálogo se pueda filtrar también por color, además de por categoría. Está en src/catalogo/filtro.ts.»
Tocado por: analista-requerimientos / 2026-10-26

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «se pueda filtrar también por color» | CA-01, CA-05, CA-07, CA-08 | cubierta | n/a |
| «además de por categoría» (el filtro por categoría se conserva y se combina) | CA-02, CA-03 | cubierta | n/a |
| «Está en src/catalogo/filtro.ts» (ubicación del cambio) | cabecera `Archivos:` | cubierta | n/a |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-26 | (creación) | Encargo del propietario, 2026-10-26 | — |
