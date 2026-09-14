# Lista de clientes en el encabezado del informe (REQ-004)

> Documentación de usuario final. Refleja el comportamiento **real, probado y aprobado** de
> `listaClientes` (`src/formato.js`) tras la re-validación de QA del 2026-09-14 (vuelta 2 de 3
> del ciclo dev↔QA). Los cuatro criterios de aceptación de REQ-004 (CA-01 a CA-04) pasan sin
> hallazgos abiertos; pendiente sólo el visto bueno de seguridad para el cierre formal del REQ
> (no afecta el comportamiento descrito aquí).

## Qué hace

`listaClientes(nombres)` arma la línea del encabezado del informe mensual con los nombres de
los clientes del período, separados por `; ` (punto y coma seguido de un espacio), sin dejar
separador colgando al final.

```js
listaClientes(['Ana', 'Luis', 'Marta']);
// → "Ana; Luis; Marta"
```

## Qué se omite del encabezado

Un elemento se omite —y sólo se omite por esto— si:

- es `null`,
- es `undefined`, o
- es una cadena que queda vacía al quitarle los espacios/blancos de ambos extremos (una
  cadena de solo espacios, tabuladores o saltos de línea **cuenta como vacía y se omite**).

```js
listaClientes(['Ana', '', null, 'Luis', undefined]); // → "Ana; Luis"
listaClientes(['Ana', '   ', 'Luis']);               // → "Ana; Luis"   (antes NO se omitía)
listaClientes([' Ana ', 'Luis']);                    // → " Ana ; Luis" (el nombre conservado
                                                      //   se emite tal cual, sin recortar)
```

Si todos los elementos se omiten, el resultado es la cadena vacía `''`.

## Cambio de comportamiento importante — antes vs. ahora

Esta versión **deja de tolerar en silencio** entradas que antes se colaban en el encabezado o
lo rompían de forma poco clara. Si tu código llama a `listaClientes` con datos que no vienen
saneados, revisa esta tabla:

| Entrada | Antes (hasta la vuelta 1) | Ahora |
|---|---|---|
| `nombres` no es un arreglo (`null`, `undefined`, un texto, un número, un objeto) | Excepción críptica del motor JS (p.ej. `Cannot read properties of null (reading 'filter')`) | **Lanza `TypeError`** con mensaje claro: `listaClientes: se esperaba un arreglo de nombres` |
| Un elemento del arreglo es `0`, `false` o `NaN` | Se omitía en silencio (como si fuera un nombre vacío) | **Lanza `TypeError`**: `listaClientes: el elemento en la posición N no es un nombre` (ya no se trata como "vacío": es un dato malformado) |
| Un elemento del arreglo es un objeto, un arreglo, un número, etc. | Se incrustaba tal cual en el texto (p.ej. `"Ana; [object Object]; Luis"` o `"Ana; 42; Luis"`) | **Lanza `TypeError`**: `listaClientes: el elemento en la posición N no es un nombre`. Nunca se incrusta un valor que no sea texto |
| Una cadena de solo espacios (`'   '`) | Se conservaba tal cual en el encabezado | **Se omite**, igual que una cadena vacía |
| El arreglo `[]` (vacío) | Cadena vacía `''` | Sin cambio: sigue siendo `''`, **no** lanza error |

**Por qué el cambio:** un encabezado con `[object Object]`, con un `42` suelto, o que se cae
con un error del motor de JavaScript en vez de uno diagnosticable, es peor que fallar de forma
clara y ruidosa. La función ahora prefiere **detener la generación del informe con un mensaje
útil** antes que producir (o dejar pasar a producción) un encabezado corrupto o parcial.

## Mensajes de error exactos

Si tu código captura estos errores para mostrar un mensaje al usuario o para loguear, los
mensajes son literales (no cambian de una versión a otra sin aviso):

- `nombres` no es un arreglo:
  `listaClientes: se esperaba un arreglo de nombres`
- Un elemento no es texto ni `null`/`undefined` (posición `N`, base 0, contada sobre la
  entrada tal como llegó — los elementos que se iban a omitir **no corren el número**):
  `` listaClientes: el elemento en la posición N no es un nombre ``

En ambos casos la función **no** devuelve ninguna cadena (ni vacía ni parcial): o entrega el
encabezado completo, o lanza. No hay un resultado a medias.

## Ejemplo de uso recomendado

```js
const { listaClientes } = require('./src/formato.js');

let encabezado;
try {
  encabezado = listaClientes(clientesDelPeriodo);
} catch (error) {
  // Aquí `error.message` ya trae un texto diagnosticable — decide si el período
  // realmente no tiene clientes (usa `[]`, no `null`/`undefined`) o si los datos
  // de origen están malformados y hay que corregirlos antes de facturar.
  throw error;
}
```

Si un período no tiene clientes, pasa el arreglo vacío `[]` (produce `''`), nunca `null` o
`undefined`.
