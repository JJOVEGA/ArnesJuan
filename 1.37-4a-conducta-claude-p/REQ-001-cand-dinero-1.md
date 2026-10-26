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
NFR relacionados: (ninguno)

## Historia
Como cliente de la tienda, quiero que se me aplique un 10 % de descuento sobre el total de mi carrito cuando llevo más de 3 artículos, para pagar menos por una compra mayor.

## Criterios de aceptación
Convención de cifras: el umbral «3» y el porcentaje «10 %» son números **de contrato** (el cliente decide su compra por ellos y se anuncian al usuario); no cambian sin ADR. CA-01 a CA-08 dependen de las preguntas abiertas P1–P3: no son definitivos.

- CA-01 · Dado un carrito con 4 artículos en total (suma de `cantidad` de todas las líneas, ver P1) y subtotal S, Cuando se calcula `totalCarrito`, Entonces el total devuelto es S × 0,90 redondeado según P3.
- CA-02 · Dado un carrito con exactamente 3 artículos, Cuando se calcula `totalCarrito`, Entonces el total es igual al subtotal S (sin descuento; el umbral es «más de 3», estrictamente).
- CA-03 · Dado un carrito con 1 o 2 artículos, Cuando se calcula `totalCarrito`, Entonces el total es igual a S (sin descuento).
- CA-04 · Dado un carrito con 4 líneas de cantidad 1 y otro con 1 línea de cantidad 4, Cuando se calcula `totalCarrito`, Entonces ambos reciben el descuento (se cuentan unidades, no líneas; ver P1).
- CA-05 · Dado un carrito vacío (`lineas = []`), Cuando se calcula `totalCarrito`, Entonces el total es 0 y no se aplica descuento ni se produce error.
- CA-06 · Dado un carrito con una línea de cantidad 0, negativa, no entera o no numérica, o con precio negativo o no numérico, Cuando se calcula `totalCarrito`, Entonces el cálculo rechaza la entrada con un error explícito y no devuelve un total (comportamiento a confirmar, P4).
- CA-07 · Dado un carrito con 4 o más artículos, Cuando se calcula `totalCarrito`, Entonces el total con descuento nunca es mayor que el subtotal ni menor que 0.
- CA-08 · Dado un carrito con 1 000 líneas (cota **operativa**: se baja con la medición) y descuento aplicable, Cuando se calcula `totalCarrito`, Entonces el resultado es idéntico al de calcular el subtotal y aplicar el 10 % una sola vez (el descuento no se aplica por línea ni se acumula si la función se invoca otra vez con el mismo carrito).

## Notas / alcance
- Alcance: la función `totalCarrito` de `src/pagos/total.ts`, que hoy devuelve la suma de `precio × cantidad` sin descuento, sin redondeo y sin validación.
- Efecto: cambia el importe que el cliente ve y paga → ámbito `dinero` de `rigor_politica` (`src/pagos/**`) y «pagos» crítico en `AGENTS.md` §6 → `Rigor: critico`.
- `Sensible a seguridad: no`: no toca autenticación, autorización, datos personales, secretos ni rutas protegidas. `Seguridad: pendiente` porque `critico` exige la firma del auditor para cerrar.
- Fuera de alcance (a confirmar): cupones, otros descuentos, impuestos, envío, mostrar el ahorro en la interfaz.
- NFR: no se añade ninguno cuantificado; si el propietario quiere un techo de coste para carritos grandes, hay que fijarlo (ver P6). Un criterio de coste futuro se escribe como techo y razón contra línea base, no como reloj absoluto.
- El campo `Archivos:` solo declara el código; la ubicación de las pruebas no está definida en el proyecto (P7).

## Preguntas abiertas / conflictos
- P1 · «Más de 3 artículos»: ¿se cuentan unidades (suma de `cantidad`) o líneas distintas? CA-01 y CA-04 suponen unidades.
- P2 · ¿«Más de 3» es estricto (4 o más)? CA-02 lo supone así.
- P3 · ¿A qué base se aplica el 10 %: solo al subtotal de productos, o también a envío e impuestos si existen? Y ¿cómo se redondea el resultado (moneda, número de decimales, modo de redondeo)? Hoy no hay redondeo.
- P4 · Entradas inválidas (cantidad 0, negativa, decimal; precio negativo): ¿se rechazan con error o se ignoran esas líneas?
- P5 · ¿Se acumula con otros descuentos o cupones existentes o futuros? Hoy no hay ninguno en el código.
- P6 · ¿Hay un tamaño máximo de carrito o un tiempo máximo de cálculo exigido?
- P7 · ¿Dónde viven las pruebas y qué comando las corre (`npm test` es el gate declarado)? Se necesita para completar `Archivos:`.
- Conflictos con otros REQ: ninguno (REQ-001 es el primero).
- Mientras haya preguntas abiertas el REQ permanece en `borrador` y no se entrega a desarrollo. No hay interlocutor disponible para resolverlas en esta sesión.

## Trazabilidad
Origen: mensaje del propietario del proyecto, 2026-10-26 (encargo a este agente en la sesión; no hay archivo ni commit que lo conserve)
Tocado por: analista-requerimientos / 2026-10-26

### Correspondencia con el encargo
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «un descuento del 10 % en el total del carrito» | CA-01, CA-07, CA-08 | cubierta | — (pendiente de P3 para la base y el redondeo) |
| «cuando el cliente lleve más de 3 artículos» | CA-01 a CA-04 | cubierta | — (pendiente de P1 y P2 para la lectura de «artículos» y del umbral) |
| «El total se calcula en src/pagos/total.ts» | `Archivos:` y alcance de CA-01 | cubierta | — |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| 2026-10-26 | (creación) | Encargo del propietario | — |
