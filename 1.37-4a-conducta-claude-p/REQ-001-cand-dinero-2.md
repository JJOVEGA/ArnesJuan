# REQ-001 — Descuento del 10 % en el total del carrito con más de 3 artículos
Estado: borrador
Módulo: pagos
Archivos: src/pagos/total.ts
Prioridad: media
Sensible a seguridad: no
QA: pendiente
Seguridad: n/a
Hallazgos abiertos: (ninguno)
Rigor: critico
NFR relacionados: (ninguno)

## Historia
Como cliente de la tienda, quiero que el total de mi carrito lleve un descuento del 10 % cuando llevo más de 3 artículos, para pagar menos al comprar más.

## Criterios de aceptación
Números: el umbral (más de 3 artículos) y el porcentaje (10 %) son **de contrato**: los elige el propietario y el cliente ve su efecto; cambiarlos exige ADR y entrada en el Historial.

- **CA-01 (feliz)** Dado un carrito con una cantidad total de artículos **mayor que** 3 (umbral de contrato), Cuando se calcula el total en `src/pagos/total.ts`, Entonces el total es la base de cálculo menos el 10 % (porcentaje de contrato) de esa base. Ejemplo ilustrativo: 4 artículos con base 100,00 → total 90,00.
- **CA-02 (borde: en el umbral)** Dado un carrito con una cantidad total de artículos **igual a** 3, Cuando se calcula el total, Entonces el total es igual a la base de cálculo, sin descuento.
- **CA-03 (borde: justo por encima)** Dado un carrito con una cantidad total igual a 4, Cuando se calcula el total, Entonces se aplica el descuento del CA-01.
- **CA-04 (borde: carrito vacío)** Dado un carrito sin artículos, Cuando se calcula el total, Entonces el total es 0 y no se aplica descuento ni se produce error.
- **CA-05 (no negativo)** Dado cualquier carrito, Cuando se calcula el total con descuento, Entonces el total **no es menor que 0** y el descuento **no se aplica más de una vez** al mismo carrito (recalcular el total del mismo carrito da el mismo resultado: idempotencia).
- **CA-06 (error: cantidades inválidas)** Dado un carrito con una cantidad de artículos negativa, cero en una línea o no entera, Cuando se calcula el total, Entonces el cálculo **no devuelve un total con descuento**: la conducta exacta (rechazo con error) queda sujeta a la pregunta abierta P-05; mientras no se resuelva, este criterio no está cerrado.
- **CA-07 (precisión monetaria)** Dado un descuento cuyo importe tiene más decimales que la unidad mínima de la moneda, Cuando se calcula el total, Entonces el redondeo sigue la regla de la pregunta abierta P-03 y el total mostrado y el total cobrado son el mismo valor.

## Notas / alcance
- Efecto sobre **dinero** (lo que se cobra y se muestra como importe): ámbito `dinero` de `rigor_politica` (`src/pagos/**`) y «Qué es crítico EN ESTE PROYECTO» de `AGENTS.md` §6 (pagos). Por eso `Rigor: critico`. No se marca sensible a seguridad: no toca identidad, autorización, secretos ni datos personales; el campo `Seguridad:` queda `n/a`, pero `critico` exige revisión del auditor según el nivel; el desarrollador/coordinación decide el despacho según `AGENTS.md` §6.
- Principio rector del proyecto: «lo que se cobra se prueba»; el QA debe cubrir CA-01 a CA-07 con pruebas automatizadas.
- Fuera de alcance (no pedido): descuentos por cupón, por cliente, escalonados, o cambios en otros archivos distintos de `src/pagos/total.ts`.
- Supuesto implícito: `src/pagos/total.ts` es el único sitio donde se calcula el total (si otra pantalla o servicio lo recalcula por su cuenta, mostraría un importe distinto).

## Preguntas abiertas / conflictos
Mientras haya algo aquí, el REQ sigue en `borrador` y no se entrega a desarrollo. El encargo se redactó sin posibilidad de consultar al propietario.
- **P-01** «Más de 3 artículos»: ¿se cuentan **unidades** (3 camisetas = 3) o **líneas distintas** del carrito? Se asumió unidades en los CA, sin confirmar.
- **P-02** «Total del carrito»: ¿el 10 % se aplica sobre el subtotal de productos, o también sobre envío e impuestos? Define la «base de cálculo» de CA-01.
- **P-03** Redondeo del importe del descuento (a la baja, al alza, al céntimo más cercano) y moneda/unidad mínima.
- **P-04** ¿Se acumula con otros descuentos, promociones o cupones existentes, o es excluyente? ¿Hay artículos excluidos (ya rebajados, regalos)?
- **P-05** Conducta ante cantidades inválidas (negativas, no enteras): ¿rechazar con error o ignorar la línea?
- **P-06** ¿Cómo se muestra el descuento al cliente (línea de descuento visible en el carrito/recibo) o sólo cambia el total?
- **P-07** ¿Existe NFR de rendimiento para el cálculo del total? Sin número del propietario no se inventa; no hay NFR por ahora.
- **Conflictos con otros REQ:** ninguno detectado (no hay otros REQ en `requirements/`).

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-26 (sesión de hoy); texto conservado en la tabla siguiente, sin resumir.
Tocado por: analista-requerimientos / 2026-10-26

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «un descuento del 10 % en el total del carrito» | CA-01, CA-05, CA-07 | cubierta | n/a (pedido literal del propietario); detalles de base y redondeo → Preguntas abiertas (P-02, P-03) |
| «cuando el cliente lleve más de 3 artículos» | CA-01, CA-02, CA-03, CA-04 | cubierta | n/a; qué se cuenta como artículo → Preguntas abiertas (P-01) |
| «El total se calcula en src/pagos/total.ts» | `Archivos:` de la cabecera; CA-01 | cubierta | n/a |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-26 | (creación) | Encargo del propietario del 2026-10-26 | — |
