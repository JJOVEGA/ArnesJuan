# REQ-001 — Descuento del 10 % en el total del carrito con más de 3 artículos
Estado: borrador
Módulo: src/pagos/
Archivos: src/pagos/total.ts
Prioridad: media
Sensible a seguridad: no
QA: pendiente
Seguridad: pendiente
Hallazgos abiertos: (ninguno)
Rigor: critico
NFR relacionados: (ninguno)

## Historia
Como cliente de la tienda, quiero que se me aplique un 10 % de descuento sobre el total del carrito cuando llevo más de 3 artículos, para pagar menos por una compra mayor.

## Criterios de aceptación
Los criterios CA-03 a CA-06 dependen de las decisiones pendientes de «Preguntas abiertas»; se escriben con la interpretación provisional indicada y no se implementan hasta que el propietario las resuelva.

- CA-01. Dado un carrito con más de 3 artículos (interpretación provisional: **4 o más**), Cuando se calcula el total en `src/pagos/total.ts`, Entonces el total devuelto es el total sin descuento multiplicado por 0,90.
- CA-02. Dado un carrito con 3 artículos o menos, Cuando se calcula el total, Entonces el total devuelto es igual al total sin descuento (sin ningún descuento).
- CA-03 (borde, límite). Dado un carrito con exactamente 3 artículos, Cuando se calcula el total, Entonces no se aplica el descuento; y con exactamente 4 artículos sí se aplica.
- CA-04 (borde, vacío). Dado un carrito vacío (0 líneas), Cuando se calcula el total, Entonces el total es 0 y no falla.
- CA-05 (error). Dado un carrito con una línea de cantidad negativa, cero o no entera, o de precio negativo, Cuando se calcula el total, Entonces el cálculo rechaza el carrito con un error explícito y no devuelve un total con descuento. (Conducta ante entrada inválida: pendiente de confirmar, ver pregunta 4.)
- CA-06 (redondeo). Dado un total con descuento que no es un múltiplo exacto de la unidad mínima de la moneda, Cuando se calcula el total, Entonces el importe se redondea según la regla que decida el propietario (pregunta 3), y el resultado difiere de `total × 0,90` en **no más de** media unidad mínima de la moneda (**de contrato**: es lo que el cliente paga).
- CA-07. Dado el descuento aplicado, Cuando se muestra o cobra el total, Entonces el importe cobrado es exactamente el devuelto por `totalCarrito` (el descuento no se aplica dos veces ni en otro sitio).

## Notas / alcance
- Dentro de alcance: el cálculo del total en `src/pagos/total.ts`.
- Fuera de alcance: mostrar el desglose del descuento en la interfaz; códigos promocionales; descuentos por otro concepto.
- Rigor `critico` por efecto: el cambio altera un importe que el cliente paga (ámbito `dinero` de `rigor_politica`, glob `src/pagos/**`). No es sensible a seguridad (no toca sesión, autorización, secretos ni datos personales), por lo que `Sensible a seguridad: no`; el `critico` exige `Seguridad: aprobado` antes de cerrar.

## Preguntas abiertas / conflictos
1. **¿Qué es «artículo»?** ¿La suma de las cantidades de todas las líneas (3 camisas + 1 gorra = 4 artículos) o el número de líneas distintas (2)? Recomendación del analista: suma de cantidades. No hay nadie a quien preguntar; no se asume.
2. **«Más de 3»:** se lee como 4 o más (estrictamente mayor que 3). Confirmar.
3. **Redondeo del importe con descuento:** ¿al céntimo más cercano, hacia abajo o hacia arriba? Y la moneda y su unidad mínima no están declaradas en el código (`totalCarrito` suma `precio * cantidad` sin tipo ni redondeo).
4. **Entrada inválida:** ¿el cálculo debe rechazar cantidades o precios negativos, cero o no enteros, o el comportamiento actual (aceptarlos) se conserva? Hoy el código no valida nada.
5. **Interacción con otros descuentos o impuestos:** ¿el 10 % se aplica antes o después de impuestos, envío o cualquier otro descuento? El código actual sólo tiene la suma de líneas.
6. **Vigencia:** ¿el descuento es permanente o por tiempo limitado? No se dijo.

Mientras haya preguntas abiertas, el REQ permanece en `borrador` y no se entrega a desarrollo.

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-21: «Quiero un descuento del 10 % en el total del carrito cuando el cliente lleve más de 3 artículos. El total se calcula en src/pagos/total.ts.»
Tocado por: analista-requerimientos / 2026-10-21

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «descuento del 10 % en el total del carrito» | CA-01, CA-06, CA-07 | cubierta | — |
| «cuando el cliente lleve más de 3 artículos» | CA-01, CA-02, CA-03 | cubierta | — (el significado de «artículo» queda en → Preguntas abiertas 1 y 2) |
| «El total se calcula en src/pagos/total.ts» | CA-07 | cubierta | — |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-21 | (creación) | Encargo del propietario, 2026-10-21 | — |
