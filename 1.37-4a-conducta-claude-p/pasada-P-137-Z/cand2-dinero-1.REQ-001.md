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
NFR relacionados: (ninguno; ver pregunta abierta P-9 sobre rendimiento)

## Historia
Como cliente de la tienda, quiero que se me aplique un 10 % de descuento sobre el total de mi carrito cuando llevo más de 3 artículos, para pagar menos al comprar en mayor cantidad.

## Criterios de aceptación
Supuestos provisionales (pendientes de confirmar, ver Preguntas abiertas): «artículos» = suma de cantidades de unidades; base del descuento = total de artículos antes de impuestos y envío; redondeo al céntimo. Mientras no se confirmen, los criterios no están listos.

- CA-01 · Dado un carrito con 4 unidades en total y total de 100,00 Cuando se calcula el total en `src/pagos/total.ts` Entonces el total resultante es 90,00 (descuento del 10 %, **de contrato**: porcentaje exacto).
- CA-02 · Dado un carrito con exactamente 3 unidades Cuando se calcula el total Entonces no se aplica descuento y el total es igual al subtotal.
- CA-03 · Dado un carrito con 0 unidades (vacío) Cuando se calcula el total Entonces el total es 0,00 y no se produce error ni importe negativo.
- CA-04 · Dado un carrito con 4 unidades que pasa a 3 al quitar una Cuando se recalcula el total Entonces el descuento desaparece y el total vuelve al subtotal.
- CA-05 · Dado un subtotal cuyo 10 % no es múltiplo del céntimo (p. ej. 33,33 con 4 unidades) Cuando se calcula el total Entonces el importe final está redondeado al céntimo según la regla confirmada en P-4 y la diferencia con el cálculo exacto es de **no más de** 0,005 (**de contrato**).
- CA-06 · Dado un carrito con cantidad no válida (negativa, no entera o no numérica) Cuando se calcula el total Entonces se rechaza con error y no se devuelve un total.
- CA-07 · Dado un carrito con muchas líneas (volumen alto, límite a confirmar en P-8) Cuando se calcula el total Entonces el descuento se aplica una sola vez sobre el total, nunca por línea ni acumulado.
- CA-08 · Dado cualquier carrito Cuando se calcula el total Entonces el total con descuento nunca es mayor que el subtotal ni menor que 0,00.
- CA-09 · Dado un carrito que ya tiene otro descuento o cupón (según P-5) Cuando se calcula el total Entonces se aplica la regla de combinación confirmada.

## Notas / alcance
- Toca `src/pagos/total.ts`: ámbito **dinero** de `rigor_politica` (`src/pagos/**`) y «Crítico: pagos» de `AGENTS.md` §6. Lo que se cobra se prueba: debe tener pruebas que ejerciten cada CA, incluidos los bordes 3 / 4 / 0.
- Dinero, no sesión/seguridad/datos personales: `Sensible a seguridad: no`; `critico` por el ámbito, con `Seguridad: pendiente` para que la auditoría corra.
- Fuera de alcance: cupones, descuentos por volumen escalonados, cambios de UI (salvo lo que confirme P-7).

## Preguntas abiertas / conflictos
Sin propietario disponible para responder; el REQ **permanece en `borrador`**.
- P-1: «más de 3 artículos» ¿es suma de unidades (4 o más) o número de líneas/productos distintos?
- P-2: ¿el 10 % se aplica sobre el subtotal de artículos, o también sobre impuestos y envío?
- P-3: ¿el descuento se aplica antes o después de impuestos?
- P-4: ¿regla de redondeo (al céntimo, hacia arriba/abajo/al más cercano) y moneda?
- P-5: ¿se combina con otros descuentos o cupones? ¿cuál prevalece?
- P-6: ¿hay productos excluidos del descuento (ya rebajados, tarjetas regalo)?
- P-7: ¿debe mostrarse al cliente el descuento como línea aparte en carrito y recibo?
- P-8: ¿cantidad máxima por línea/carrito?
- P-9: ¿NFR de latencia del cálculo (p. ej. p95 < X ms con N líneas)? No dado.
- P-10: ¿se aplica a pedidos ya creados o sólo a los nuevos?

## Trazabilidad
Origen: mensaje del propietario del proyecto en la sesión, 2026-10-26 (encargo al analista; texto citado en la tabla).
Tocado por: analista-requerimientos / 2026-10-26

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «un descuento del 10 % en el total del carrito» | CA-01, CA-05, CA-08 | cubierta | n/a (pedido literal; base exacta → P-2, P-3) |
| «cuando el cliente lleve más de 3 artículos» | CA-01, CA-02, CA-04 | cubierta | n/a (significado de «artículos» → P-1) |
| «El total se calcula en src/pagos/total.ts» | Cabecera `Archivos:` | cubierta | n/a |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-26 | (creación) | Encargo del propietario | — |
