# REQ-001 — Descuento del 10 % en el total del carrito por más de 3 artículos
Estado: borrador
Módulo: pagos
Archivos: src/pagos/total.ts
Prioridad: media
Sensible a seguridad: no
QA: pendiente
Seguridad: pendiente
Hallazgos abiertos: (ninguno)
Rigor: critico
NFR relacionados: (ninguno)

## Historia
Como cliente de la tienda, quiero que se me aplique un 10 % de descuento en el total del carrito cuando llevo más de 3 artículos, para pagar menos por compras de mayor tamaño.

## Criterios de aceptación
Borrador: dependen de las preguntas abiertas (unidad de «artículo», base del 10 %, redondeo). Se escriben con la interpretación mínima y no se entregan hasta resolverlas.

- CA-01 · Dado un carrito con N artículos, N > 3 (de contrato: el umbral es «más de 3», es decir, 4 o más) Cuando se calcula el total en `src/pagos/total.ts` Entonces el total es el total sin descuento menos el 10 % (de contrato) de la base definida en la pregunta P2.
- CA-02 · Dado un carrito con exactamente 3 artículos Cuando se calcula el total Entonces no se aplica ningún descuento (total igual al total sin descuento).
- CA-03 · Dado un carrito con 4 artículos Cuando se calcula el total Entonces se aplica el descuento (borde inferior del umbral).
- CA-04 · Dado un carrito vacío (0 artículos) Cuando se calcula el total Entonces el total es 0 y no se aplica descuento ni se produce error.
- CA-05 · Dado un carrito con cantidad de artículos negativa, no entera o no numérica Cuando se calcula el total Entonces se rechaza con error explícito y no se devuelve un total.
- CA-06 · Dado un total con descuento Cuando se redondea Entonces el resultado cumple la regla de redondeo y moneda de P3, y nunca es negativo ni mayor que el total sin descuento.
- CA-07 · Dado un carrito con más de 3 artículos y otro descuento o promoción vigente Cuando se calcula el total Entonces se aplica la regla de acumulación de P4.
- CA-08 · Dado el mismo carrito calculado dos veces Cuando se compara el resultado Entonces el total es idéntico (el descuento no se aplica dos veces ni depende del estado previo).

## Notas / alcance
- Efecto sobre dinero (lo que se cobra y se muestra como importe): ámbito `dinero` de `rigor_politica` (`src/pagos/**`) y «pagos» crítico en `AGENTS.md` §6 → `Rigor: critico`, `Seguridad: pendiente`. No toca sesión, autorización, secretos ni datos personales → `Sensible a seguridad: no`.
- Principio rector del proyecto: «lo que se cobra se prueba»; el desarrollador debe cubrir los bordes (0, 3, 4 artículos) con pruebas.
- Fuera de alcance (no pedido): cupones, descuentos escalonados, descuento por línea de producto, mostrar el ahorro en la interfaz.

## Preguntas abiertas / conflictos
- P1. ¿«Artículos» son unidades (suma de cantidades) o líneas distintas del carrito? Ej.: 1 línea con cantidad 4, ¿cuenta como 4?
- P2. ¿El 10 % se calcula sobre el subtotal de productos, o incluye envío e impuestos? ¿Se aplica antes o después de impuestos?
- P3. Moneda y regla de redondeo del importe con descuento (decimales, modo de redondeo, a quién favorece).
- P4. ¿Se acumula con otras promociones o cupones existentes, o prevalece el mejor/uno solo?
- P5. ¿Hay artículos excluidos del conteo o del descuento (ya rebajados, regalos, tarjetas)?
- P6. ¿Cómo se muestra el descuento al cliente (línea aparte o total ya rebajado)? Afecta lo que «se muestra como importe».
- Sin interlocutor disponible en esta sesión: ninguna se resolvió; el REQ permanece en `borrador` y no se entrega a desarrollo.
- Conflictos con otros REQs: ninguno (no existen otros REQ).

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-26 (sesión de análisis; no archivado en el repositorio)
Tocado por: analista-requerimientos / 2026-10-26

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «un descuento del 10 % en el total del carrito» | CA-01, CA-06 | cubierta | — |
| «cuando el cliente lleve más de 3 artículos» | CA-01, CA-02, CA-03 | cubierta | — |
| «El total se calcula en src/pagos/total.ts» | CA-01 (módulo y `Archivos:`) | cubierta | — |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-26 | (creación) | Encargo del propietario | — |
