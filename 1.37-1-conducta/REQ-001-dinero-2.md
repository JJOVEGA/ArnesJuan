# REQ-001 — Descuento del 10 % en el total del carrito por volumen
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
Como cliente de la tienda, quiero que se me aplique un 10 % de descuento sobre el total de mi carrito cuando llevo más de 3 artículos, para pagar menos por comprar más.

## Criterios de aceptación
Los criterios usan la lectura **provisional** de «artículos» = suma de `cantidad` de todas las líneas, pendiente de confirmar (ver Preguntas abiertas, P-1). Los números son **de contrato** (los fijó el propietario): umbral «más de 3» y tasa 10 %.

- CA-01 · Dado un carrito con 4 artículos en total y subtotal 100,00, Cuando se calcula el total en `totalCarrito`, Entonces el resultado es 90,00 (subtotal menos el 10 %).
- CA-02 · Dado un carrito con exactamente 3 artículos en total, Cuando se calcula el total, Entonces el resultado es igual al subtotal, sin descuento (borde: «más de 3» excluye el 3).
- CA-03 · Dado un carrito con 1 línea de cantidad 4, Cuando se calcula el total, Entonces se aplica el descuento (las unidades cuentan, no las líneas). *Depende de P-1.*
- CA-04 · Dado un carrito con 4 líneas de cantidad 1, Cuando se calcula el total, Entonces se aplica el descuento. *Depende de P-1.*
- CA-05 · Dado un carrito vacío, Cuando se calcula el total, Entonces el resultado es 0 y no hay descuento ni error.
- CA-06 · Dado un carrito con una línea de cantidad 0 o negativa, un precio negativo o una cantidad no entera, Cuando se calcula el total, Entonces el comportamiento es el que fije P-3 (hoy el código no valida; no se inventa aquí).
- CA-07 · Dado un carrito con descuento aplicable cuyo 10 % no cae en un múltiplo de la unidad monetaria mínima, Cuando se calcula el total, Entonces el redondeo es el que fije P-2 y el resultado nunca difiere en más de esa unidad mínima del valor exacto.
- CA-08 · Dado un carrito sin descuento aplicable, Cuando se calcula el total, Entonces el resultado es idéntico al que `totalCarrito` devolvía antes de este REQ (no regresión).

## Notas / alcance
- Alcance: `src/pagos/total.ts` (la función que calcula el total). El descuento es sobre el **total del carrito**, no por línea.
- Fuera de alcance: cupones, otros descuentos, impuestos, envío, cambios de interfaz (cómo se muestra el descuento).
- Clasificación: toca cómo se calcula lo que se cobra (ámbito `dinero`, `src/pagos/**`), por lo que `Rigor: critico`. `Sensible a seguridad: no`: no toca sesión, autorización, secretos ni datos personales; `Seguridad: pendiente` porque `critico` exige la firma del auditor.

## Preguntas abiertas / conflictos
- **P-1.** ¿«Más de 3 artículos» cuenta unidades (suma de `cantidad`) o líneas distintas? Recomendación: unidades.
- **P-2.** ¿Cómo se redondea el total con descuento (moneda, número de decimales, hacia dónde)? El código actual no redondea.
- **P-3.** ¿Qué debe ocurrir con cantidades o precios inválidos (0, negativos, no enteros)? ¿Pueden contar para el umbral?
- **P-4.** ¿El descuento se aplica sobre el subtotal bruto y se muestra aparte, o sólo cambia el total devuelto?
- Hasta que el propietario resuelva estas preguntas, el REQ permanece en `borrador`.

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-21: «Quiero un descuento del 10 % en el total del carrito cuando el cliente lleve más de 3 artículos. El total se calcula en src/pagos/total.ts.»
Tocado por: analista-requerimientos / 2026-10-21

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «descuento del 10 % en el total del carrito» | CA-01, CA-07 | cubierta | — |
| «cuando el cliente lleve más de 3 artículos» | CA-01, CA-02, CA-03, CA-04 | cubierta | — (significado de «artículos»: → Preguntas abiertas P-1) |
| «El total se calcula en src/pagos/total.ts» | CA-08 (alcance) | cubierta | — |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-21 | (creación) | Pedido del propietario del 2026-10-21 | — |
