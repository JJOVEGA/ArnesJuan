# REQ-001 — Descuento del 10 % en el total del carrito con más de 3 artículos
Estado: borrador
Módulo: pagos
Archivos: src/pagos/total.ts
Prioridad: media
Sensible a seguridad: no
QA: pendiente
Seguridad: pendiente
Hallazgos abiertos: (ninguno)
Rigor: critico
NFR relacionados: (ninguno; ver Preguntas abiertas P-8)

## Historia
Como cliente de la tienda, quiero que se me aplique un descuento del 10 % en el total del carrito cuando llevo más de 3 artículos, para pagar menos cuando compro más.

## Criterios de aceptación
Los números de este REQ son **de contrato** (los ve y los cobra el cliente): el 10 % y el umbral de 3 no cambian sin ADR. Los criterios dependen de las decisiones pendientes de «Preguntas abiertas»; las suposiciones provisionales están marcadas.

- CA-01 · Dado un carrito con **4 o más** artículos (suposición provisional: se cuentan **unidades**, P-1) y base descontable B, Cuando se calcula el total en `src/pagos/total.ts`, Entonces el descuento es exactamente 10 % de B, y el total = B − descuento (más lo que P-2 determine que queda fuera de la base).
- CA-02 · Dado un carrito con **exactamente 3** artículos, Cuando se calcula el total, Entonces el descuento es 0 y el total es igual al que se calculaba antes de este REQ.
- CA-03 · Dado un carrito con 0 artículos (vacío), Cuando se calcula el total, Entonces no se aplica descuento, el total no es negativo y no se lanza error.
- CA-04 · Dado un carrito con 4 artículos, Cuando se elimina uno y quedan 3, Entonces el total se recalcula sin descuento.
- CA-05 · Dado un carrito con cantidad no válida en alguna línea (negativa, cero, no entera, NaN), Cuando se calcula el total, Entonces el cálculo se rechaza con error explícito y no devuelve un total con descuento.
- CA-06 · Dado un descuento con resultado de más de 2 decimales (p. ej. 10 % de 33,33), Cuando se calcula el total, Entonces el redondeo sigue la regla de P-3 y el total cobrado es igual al total mostrado.
- CA-07 · Dado el conjunto de casos de CA-01 a CA-06, Cuando se ejecuta `npm test`, Entonces existe al menos una prueba automatizada por criterio, incluidos los bordes 3 y 4 artículos, y todas pasan (principio rector: lo que se cobra se prueba).

## Notas / alcance
- Dinero: el cambio altera lo que se cobra y se muestra como importe; ámbito `dinero` de `rigor_politica` (`src/pagos/**`) y «Crítico: pagos» en `AGENTS.md` §6 → `Rigor: critico`. No toca sesión, autorización, datos personales ni secretos, así que `Sensible a seguridad: no`; aun así el rigor `critico` exige `Seguridad: aprobado` para cerrar, por eso `Seguridad: pendiente` y no `n/a`.
- Fuera de alcance (salvo que el propietario decida lo contrario): cupones, otros descuentos, descuentos escalonados, impuestos, envío.
- Archivos: sólo se declara `src/pagos/total.ts`, que el propietario nombró; las pruebas las ubicará el desarrollador (si añade archivos, se actualiza este campo).

## Preguntas abiertas / conflictos
No había nadie a quien preguntar al crear este REQ; por eso queda en `borrador` y no se entrega a desarrollo.
- P-1 · «Más de 3 artículos»: ¿se cuentan **unidades** (3 camisetas = 3) o **líneas/productos distintos**? ¿«Más de 3» es ≥ 4 (lo asumido)?
- P-2 · ¿El 10 % se aplica sobre el **subtotal de productos**, o también sobre impuestos y envío? ¿Hay artículos excluidos del descuento (ya rebajados, tarjetas regalo)?
- P-3 · Moneda, número de decimales y regla de **redondeo** del descuento (¿a favor del cliente o de la tienda?).
- P-4 · ¿Es **acumulable** con otros descuentos o cupones existentes o futuros? ¿Hay un conflicto con algún REQ existente? (No hay otros REQ en el índice al crear este.)
- P-5 · ¿El descuento se muestra como línea aparte en el carrito/recibo o sólo en el total? (decide qué ve el cliente)
- P-6 · Comportamiento si el cálculo falla o falta precio de un artículo: ¿se bloquea el pago o se cobra sin descuento? (se asume bloquear; confirmar)
- P-7 · ¿Hay tope máximo de unidades o de importe descontado (volumen alto)?
- P-8 · NFR de rendimiento del cálculo del total: sin umbral dado; si se requiere, hace falta número y unidad (p. ej. p95 en ms con N líneas) antes de cerrarlo.

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-26 (encargo a la sesión coordinadora, citado abajo; no es un resumen del agente)
Tocado por: analista-requerimientos / 2026-10-26

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «un descuento del 10 % en el total del carrito» | CA-01 | cubierta | n/a (pendiente el detalle de P-2 y P-3) |
| «cuando el cliente lleve más de 3 artículos» | CA-01, CA-02 | cubierta | n/a (pendiente la medida de P-1) |
| «El total se calcula en src/pagos/total.ts» | CA-01 (el cálculo vive en ese archivo) | cubierta | n/a |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-26 | (creación) | Encargo del propietario, mensaje del 2026-10-26 | — |
