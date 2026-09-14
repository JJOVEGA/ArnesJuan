# Exportar el listado mensual de facturas a CSV

> Documenta el comportamiento **probado y verificado** (revisión estática, R-01) de
> `src/exportar-csv.js`. Hay un punto todavía en discusión con el analista (ver «Pendiente de
> aclarar» al final): no se documenta como comportamiento definitivo.

## Qué hace

`exportarFacturasACsv(facturas, anio, mes)` recibe el listado completo de facturas (de
cualquier mes) y devuelve una **cadena de texto CSV** con las facturas del año y mes pedidos.
No escribe ningún archivo: quien llama decide dónde y cómo guardar el resultado.

```js
const { exportarFacturasACsv } = require('./src/exportar-csv');

const csv = exportarFacturasACsv(facturas, 2026, 9); // facturas de setiembre de 2026
require('fs').writeFileSync('facturas-2026-09.csv', csv, 'utf8');
```

## Forma de cada factura

| Campo | Tipo | Obligatorio |
|---|---|---|
| `id` | cadena no vacía | sí |
| `fecha` | `"AAAA-MM-DD"` o `Date` | sí |
| `cliente` | cadena | sí |
| `descripcion` | cadena | no (si falta, es `null`/`undefined`/vacía, se exporta como celda vacía) |
| `monto` | número finito | sí |
| `comision` | número finito | sí |
| `total` | número finito | sí |

Cualquier otra propiedad que traiga el objeto (por ejemplo un identificador interno de
cliente) se ignora: no aparece en la salida.

## Formato de la salida

- Encabezado fijo: `"id","fecha","cliente","descripcion","monto","comision","total"`.
- Todas las celdas van entre comillas dobles, siempre — también las que no tienen ni comas ni
  saltos de línea. Una comilla dentro del valor se duplica (`""`).
- Cada línea termina en `CRLF` (`\r\n`), incluida la última.
- Codificación UTF-8 sin BOM.
- Los importes se emiten en notación decimal con punto, sin separador de miles ni símbolo de
  moneda, con al menos 2 decimales (rellenando con ceros si hace falta) y **nunca** truncados
  ni redondeados: si el valor de entrada tiene más decimales, todos se emiten.
- La exportación **no recalcula nada**: los importes que salen son exactamente los que
  entraron, aunque no cuadren entre sí (`monto + comision ≠ total`) — eso no es su trabajo.
- Las líneas de datos salen ordenadas por fecha y, a igual fecha, por `id`; dos exportaciones
  de la misma entrada (en cualquier orden) producen el mismo texto, siempre.

## Selección del mes

Se exportan las facturas cuya `fecha` cae dentro del año y mes indicados (incluye el primer y
el último día del mes). Las facturas de otros meses simplemente no aparecen; un mes sin
facturas produce una salida con sólo el encabezado, y **eso no es un error**.

## Cuándo falla (y qué se recibe)

La función **lanza un error** (no devuelve ningún texto parcial) cuando:
- `facturas` no es un arreglo.
- `anio` no es un número entero, o `mes` no es un entero entre 1 y 12.
- Alguna factura **del mes que se está exportando** no trae uno de sus campos obligatorios, o
  lo trae con un tipo distinto del contratado (por ejemplo `monto: "cien"` o `cliente: 42`).
- Alguna factura del mes tiene un importe que no es un número finito (`NaN`, `Infinity`,
  texto, `null`, etc.): nunca se sustituye por `0` ni se aproxima.

El mensaje de error identifica la factura (por su `id`, o por su posición en el listado si es
el `id` el que falta) y el campo defectuoso.

## Pendiente de aclarar (no cerrado aún)

Hay una ambigüedad abierta con el analista sobre facturas que **no** pertenecen al mes
exportado: hoy sólo se comprueba que su `fecha` tenga forma válida (para poder decidir que no
son del mes pedido); el resto de sus campos no se valida, porque no se van a exportar. Si esto
cambia (por ejemplo, para exigir que *todo* el listado esté bien formado, no sólo el mes
exportado), se actualizará esta guía. Ver `docs/qa/REQ-003.md` (hallazgo QA-003-01).
