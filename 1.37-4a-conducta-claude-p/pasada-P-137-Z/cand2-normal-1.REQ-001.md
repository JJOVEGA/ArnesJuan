# REQ-001 — Filtrar el listado del catálogo por color
Estado: borrador
Módulo: catálogo
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
- CA-01. Dado un listado con productos de distintos colores, Cuando se filtra por un color, Entonces el resultado contiene todos los productos cuyo color es ese y ninguno cuyo color es otro.
- CA-02. Dado un listado, Cuando se filtra por categoría y por color a la vez, Entonces el resultado contiene sólo los productos que cumplen ambas condiciones (intersección).
- CA-03. Dado un listado, Cuando se filtra sólo por categoría (sin color), Entonces el resultado es idéntico al que devolvía el filtro antes de este cambio (sin regresión).
- CA-04. Dado un listado, Cuando no se indica color (ausente, `undefined`, `null` o cadena vacía), Entonces el filtro de color no se aplica y no se excluye ningún producto por ese motivo.
- CA-05. Dado un color que ningún producto tiene, Cuando se filtra por él, Entonces el resultado es una lista vacía, sin error.
- CA-06. Dado un listado vacío, Cuando se filtra por color, Entonces el resultado es una lista vacía, sin error.
- CA-07. Dado un producto sin valor de color, Cuando se filtra por un color, Entonces ese producto no aparece en el resultado, y sin error; Cuando no se filtra por color, sí aparece.
- CA-08. Dado un listado, Cuando se filtra por color, Entonces el listado de entrada no se modifica (el filtro devuelve una lista nueva).
- CA-09. Dado el mismo color escrito con distinta capitalización o espacios sobrantes en los extremos (p. ej. `Rojo`, ` rojo `), Cuando se filtra, Entonces la coincidencia ignora esa diferencia. *(Depende de la pregunta abierta 3.)*

## Notas / alcance
- Alcance: la función de filtrado de `src/catalogo/filtro.ts`. Fuera de alcance: ordenar, paginar, UI de selección de color, cambiar el origen de los datos.
- Clasificación de rigor: la política de `rigor_politica` está declarada (los cinco ámbitos con globs). `src/catalogo/filtro.ts` no casa ningún glob y el efecto es de presentación (qué productos se listan): no cobra, no calcula importes, no toca identidad, acceso, secretos ni datos personales, y no cambia esquema. Por eso `ligero`, sensible `no`. **Supuesto de esa clasificación:** el color ya existe como campo de los productos. Si no existe y hay que añadir una columna o migración, el efecto alcanza el ámbito `datos` (`db/**`) y el REQ se reclasifica a `critico`.
- Sin dependencias externas: el filtro opera en memoria; no hay dependencia que pueda caer.
- NFR de rendimiento: no se declara ninguno; un filtro lineal en memoria sobre el listado no lo justifica. Si el propietario tiene un volumen esperado, indicarlo (pregunta 5).

## Preguntas abiertas / conflictos
1. ¿Los productos ya tienen un campo de color? ¿Con qué nombre (`color`?) y tipo? Si hay que crearlo, cambia el alcance y el rigor (ver Notas).
2. ¿Un producto tiene un solo color o varios (lista)? Cambia la semántica de CA-01.
3. ¿La coincidencia de color debe ignorar mayúsculas/minúsculas y espacios (CA-09), o ser exacta?
4. ¿Se debe poder filtrar por varios colores a la vez (p. ej. rojo o azul), o por uno solo? Este REQ asume uno solo.
5. ¿Hay un volumen máximo esperado del catálogo que justifique un NFR de rendimiento?
6. ¿Qué debe hacer la interfaz cuando el filtro devuelve vacío? (fuera de alcance de este REQ salvo que se indique.)

Sin respuesta del propietario, el REQ permanece en `borrador` y no se entrega a desarrollo.

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-26
Tocado por: analista-requerimientos / 2026-10-26

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «Quiero que el listado del catálogo se pueda filtrar también por color» | CA-01, CA-04 a CA-08 | cubierta | — |
| «además de por categoría» (el filtro por categoría se conserva y se combina) | CA-02, CA-03 | cubierta | — |
| «Está en src/catalogo/filtro.ts» (ubicación del cambio) | cabecera `Archivos:` | cubierta | — |

Nota: CA-09 (insensibilidad a mayúsculas) y la exclusión de productos sin color en CA-07 son decisiones mías no pedidas; quedan sujetas a las preguntas 3 y 2 y no están autorizadas por el propietario.

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-26 | (creación) | Encargo del propietario | — |
