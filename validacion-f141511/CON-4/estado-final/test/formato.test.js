// Pruebas de REQ-004 — Lista de clientes en el encabezado del informe.
//
// Cómo se corre (JavaScript sin framework, AGENTS.md §2):
//   node test/formato.test.js
// desde la raíz del repositorio. Sale con código 0 si todo pasa y ≠ 0 si algo falla.
//
// Cada caso declara o bien `esperado` (la cadena que debe devolver) o bien `lanza` (el
// mensaje EXACTO del `TypeError` que debe lanzar, carácter por carácter como lo fija el
// REQ). Un caso `lanza` también comprueba que no se devuelve ninguna cadena.

const assert = require('node:assert/strict');
const { listaClientes } = require('../src/formato.js');

// Mensajes literales del contrato (REQ-004 CA-03 y CA-04). Se escriben una sola vez para
// que la prueba compare contra el texto del criterio y no contra el del código.
const MSG_NO_ARREGLO = 'listaClientes: se esperaba un arreglo de nombres';
const msgNoNombre = (n) => `listaClientes: el elemento en la posición ${n} no es un nombre`;

const casos = [
  // ---------------------------------------------------------------- CA-01
  // Los nombres se unen con «; », sin separador al final.
  {
    ca: 'CA-01',
    nombre: 'une varios nombres con «; »',
    entrada: ['Ana', 'Luis', 'Marta'],
    esperado: 'Ana; Luis; Marta',
  },
  {
    ca: 'CA-01',
    nombre: 'no deja separador al final con un solo nombre',
    entrada: ['Ana'],
    esperado: 'Ana',
  },
  {
    ca: 'CA-01',
    nombre: 'lista vacía produce cadena vacía, sin separador',
    entrada: [],
    esperado: '',
  },

  // ---------------------------------------------------------------- CA-02
  // Se omite todo elemento que no aporte texto visible, y sólo ése.
  {
    ca: 'CA-02',
    nombre: 'omite cadenas vacías, null y undefined',
    entrada: ['Ana', '', null, 'Luis', undefined],
    esperado: 'Ana; Luis',
  },
  {
    ca: 'CA-02',
    nombre: 'omitir el último nombre no deja separador colgando',
    entrada: ['Ana', 'Luis', ''],
    esperado: 'Ana; Luis',
  },
  {
    ca: 'CA-02',
    nombre: 'una lista sólo de vacíos produce cadena vacía',
    entrada: ['', null],
    esperado: '',
  },
  {
    ca: 'CA-02',
    nombre: 'una cadena de sólo espacios SÍ se omite',
    entrada: ['Ana', '   ', 'Luis'],
    esperado: 'Ana; Luis',
  },
  {
    ca: 'CA-02',
    nombre: 'blancos que no son el espacio (tabulador, salto de línea) también se omiten',
    entrada: ['Ana', '\t', '\n', ' \t\n ', 'Luis'],
    esperado: 'Ana; Luis',
  },
  {
    ca: 'CA-02',
    nombre: 'los elementos conservados se emiten SIN modificar (el recorte sólo decide la omisión)',
    entrada: [' Ana ', 'Luis'],
    esperado: ' Ana ; Luis',
  },
  {
    ca: 'CA-02',
    nombre: 'si todo se omite, el resultado es la cadena vacía sin separador',
    entrada: ['   ', null, '', undefined],
    esperado: '',
  },

  // ---------------------------------------------------------------- CA-03
  // `nombres` que no es arreglo: TypeError con mensaje exacto, sin salida parcial.
  {
    ca: 'CA-03',
    nombre: 'null no es un arreglo: lanza con el mensaje exacto',
    entrada: null,
    lanza: MSG_NO_ARREGLO,
  },
  {
    ca: 'CA-03',
    nombre: 'undefined no es un arreglo: lanza con el mensaje exacto',
    entrada: undefined,
    lanza: MSG_NO_ARREGLO,
  },
  {
    ca: 'CA-03',
    nombre: 'una cadena no es un arreglo (no se trata como lista de caracteres)',
    entrada: 'Ana',
    lanza: MSG_NO_ARREGLO,
  },
  {
    ca: 'CA-03',
    nombre: 'un número no es un arreglo',
    entrada: 42,
    lanza: MSG_NO_ARREGLO,
  },
  {
    ca: 'CA-03',
    nombre: 'un objeto no es un arreglo, ni siquiera uno con forma de arreglo',
    entrada: { 0: 'Ana', length: 1 },
    lanza: MSG_NO_ARREGLO,
  },
  {
    ca: 'CA-03',
    nombre: 'borde: el arreglo vacío SÍ es entrada válida y no lanza',
    entrada: [],
    esperado: '',
  },

  // ---------------------------------------------------------------- CA-04
  // Elemento que no es cadena ni null/undefined: TypeError con el índice del PRIMER
  // incumplidor, sin convertir a texto ni emitir encabezado parcial.
  {
    ca: 'CA-04',
    nombre: 'un objeto no se incrusta como [object Object]: lanza con el índice 1',
    entrada: ['Ana', { n: 1 }, 'Luis'],
    lanza: msgNoNombre(1),
  },
  {
    ca: 'CA-04',
    nombre: 'un número no se incrusta como texto: lanza con el índice 1',
    entrada: ['Ana', 42, 'Luis'],
    lanza: msgNoNombre(1),
  },
  {
    ca: 'CA-04',
    nombre: '0 ya NO se omite: es entrada malformada y lanza',
    entrada: ['Ana', 0, 'Luis'],
    lanza: msgNoNombre(1),
  },
  {
    ca: 'CA-04',
    nombre: 'false ya NO se omite: es entrada malformada y lanza',
    entrada: ['Ana', false, 'Luis'],
    lanza: msgNoNombre(1),
  },
  {
    ca: 'CA-04',
    nombre: 'NaN ya NO se omite: es entrada malformada y lanza',
    entrada: ['Ana', NaN, 'Luis'],
    lanza: msgNoNombre(1),
  },
  {
    ca: 'CA-04',
    nombre: 'un arreglo anidado tampoco es un nombre',
    entrada: [['x'], 'Ana'],
    lanza: msgNoNombre(0),
  },
  {
    ca: 'CA-04',
    nombre: 'el índice es el del PRIMER incumplidor, no el del último',
    entrada: ['Ana', 'Luis', 7, 'Marta', {}],
    lanza: msgNoNombre(2),
  },
  {
    ca: 'CA-04',
    nombre: 'el índice es la posición en la ENTRADA: los omitidos de CA-02 no la desplazan',
    entrada: ['', null, '   ', 42],
    lanza: msgNoNombre(3),
  },
  {
    ca: 'CA-04',
    nombre: 'CA-04 manda sobre CA-02: un elemento malformado al final invalida toda la lista',
    entrada: ['Ana', 'Luis', {}],
    lanza: msgNoNombre(2),
  },
  {
    ca: 'CA-04',
    nombre: 'borde: null y undefined NO disparan CA-04 (los omite CA-02)',
    entrada: ['Ana', null, undefined, 'Luis'],
    esperado: 'Ana; Luis',
  },
];

function ejecutar(caso) {
  if (typeof caso.lanza === 'string') {
    let lanzado = null;
    let devuelto;
    try {
      devuelto = listaClientes(caso.entrada);
    } catch (error) {
      lanzado = error;
    }
    assert.ok(
      lanzado !== null,
      `no lanzó; devolvió ${JSON.stringify(devuelto)}`,
    );
    assert.ok(
      lanzado instanceof TypeError,
      `se esperaba un TypeError y llegó ${lanzado && lanzado.constructor && lanzado.constructor.name}`,
    );
    // Comparación del mensaje carácter por carácter contra el literal del REQ.
    assert.equal(lanzado.message, caso.lanza);
    return;
  }
  assert.equal(listaClientes(caso.entrada), caso.esperado);
}

let fallos = 0;
for (const caso of casos) {
  try {
    ejecutar(caso);
    console.log(`ok   ${caso.ca} — ${caso.nombre}`);
  } catch (error) {
    fallos += 1;
    console.error(`FALLA ${caso.ca} — ${caso.nombre}: ${error.message}`);
  }
}

console.log(`\n${casos.length - fallos}/${casos.length} pruebas en verde`);
if (fallos > 0) {
  process.exitCode = 1;
}
