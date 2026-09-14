// Pruebas de REQ-003 — Exportar el listado mensual de facturas a CSV.
// Runner: `node --test` (node:test, sin dependencias nuevas).
'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const path = require('node:path');

const { exportarFacturasACsv } = require('../src/exportar-csv');

const RUTA_MODULO = path.join(__dirname, '..', 'src', 'exportar-csv.js');

// Encabezado literal de CA-01 (escrito a mano a propósito: comprobarlo contra una
// constante del módulo sería una tautología).
const ENCABEZADO = '"id","fecha","cliente","descripcion","monto","comision","total"';
const COLUMNAS = ['id', 'fecha', 'cliente', 'descripcion', 'monto', 'comision', 'total'];

// --- Ayudas ---------------------------------------------------------------

function factura(cambios) {
  return {
    id: 'F-001',
    fecha: '2026-09-10',
    cliente: 'ACME',
    descripcion: 'servicio',
    monto: 100,
    comision: 2,
    total: 102,
    ...cambios,
  };
}

function facturaSin(campo, cambios) {
  const resultado = factura(cambios);
  delete resultado[campo];
  return resultado;
}

/** Analizador CSV conforme a RFC 4180 (CA-04): campos entrecomillados, `""` escapado, registros CRLF. */
function analizarCsv(texto) {
  const registros = [];
  let registro = [];
  let campo = '';
  let dentro = false;
  let i = 0;
  while (i < texto.length) {
    const caracter = texto[i];
    if (dentro) {
      if (caracter === '"') {
        if (texto[i + 1] === '"') {
          campo += '"';
          i += 2;
          continue;
        }
        dentro = false;
        i += 1;
        continue;
      }
      campo += caracter;
      i += 1;
      continue;
    }
    if (caracter === '"') {
      dentro = true;
      i += 1;
      continue;
    }
    if (caracter === ',') {
      registro.push(campo);
      campo = '';
      i += 1;
      continue;
    }
    if (caracter === '\r' && texto[i + 1] === '\n') {
      registro.push(campo);
      registros.push(registro);
      registro = [];
      campo = '';
      i += 2;
      continue;
    }
    campo += caracter;
    i += 1;
  }
  if (campo !== '' || registro.length > 0) {
    registro.push(campo);
    registros.push(registro);
  }
  return registros;
}

/** Celda de una columna en la primera línea de datos. */
function celda(csv, columna) {
  return analizarCsv(csv)[1][COLUMNAS.indexOf(columna)];
}

function celdasTodasEntrecomilladas(texto) {
  let dentro = false;
  for (let i = 0; i < texto.length; i += 1) {
    const caracter = texto[i];
    if (caracter === '"') {
      dentro = !dentro;
      continue;
    }
    if (dentro) continue;
    if (caracter === ',') continue;
    if (caracter === '\r' && texto[i + 1] === '\n') {
      i += 1;
      continue;
    }
    return false; // carácter desnudo fuera de un campo entrecomillado
  }
  return !dentro;
}

function hayLfSueltoFueraDeCampo(texto) {
  let dentro = false;
  for (let i = 0; i < texto.length; i += 1) {
    const caracter = texto[i];
    if (caracter === '"') {
      dentro = !dentro;
      continue;
    }
    if (!dentro && caracter === '\n' && texto[i - 1] !== '\r') return true;
  }
  return false;
}

// --- CA-01: columnas y encabezado ----------------------------------------

test('CA-01 la primera línea es exactamente el encabezado contratado', () => {
  const csv = exportarFacturasACsv([factura()], 2026, 9);
  assert.equal(csv.split('\r\n')[0], ENCABEZADO);
});

test('CA-01 hay una línea de datos por factura, con los valores en el orden de columnas', () => {
  const csv = exportarFacturasACsv([factura(), factura({ id: 'F-002' })], 2026, 9);
  const registros = analizarCsv(csv);
  assert.equal(registros.length, 3);
  assert.deepEqual(registros[1], ['F-001', '2026-09-10', 'ACME', 'servicio', '100.00', '2.00', '102.00']);
});

// --- CA-02: terminador de registro ---------------------------------------

test('CA-02 toda línea termina en CRLF, incluida la última', () => {
  const csv = exportarFacturasACsv([factura(), factura({ id: 'F-002' })], 2026, 9);
  assert.ok(csv.endsWith('\r\n'));
  assert.equal(csv.split('\r\n').length - 1, 3); // encabezado + 2 datos
});

test('CA-02 no aparece ningún LF suelto fuera de un campo entrecomillado', () => {
  const csv = exportarFacturasACsv([factura({ cliente: 'arriba\nabajo' })], 2026, 9);
  assert.equal(hayLfSueltoFueraDeCampo(csv), false);
});

// --- CA-03: entrecomillado incondicional ----------------------------------

test('CA-03 todas las celdas van entrecomilladas, también las del encabezado y los importes', () => {
  const csv = exportarFacturasACsv([factura({ descripcion: '' })], 2026, 9);
  assert.equal(celdasTodasEntrecomilladas(csv), true);
});

test('CA-03 cada comilla doble del valor se emite duplicada dentro de los delimitadores', () => {
  const csv = exportarFacturasACsv([factura({ cliente: 'el "grande"' })], 2026, 9);
  assert.ok(csv.includes('"el ""grande"""'));
  assert.equal(celda(csv, 'cliente'), 'el "grande"');
});

// --- CA-04: escapado, propiedad de ida y vuelta ---------------------------

test('CA-04 un analizador RFC 4180 devuelve el texto idéntico carácter por carácter', () => {
  const textos = [
    'Pérez, S.A.',
    'el "grande"',
    'línea1\nlínea2',
    'a, "b"\r\nc',
    '',
    '   con espacios   ',
    'tab\they',
    '😀 emoji y ñ',
    '"',
    ',,,',
    '\r',
  ];
  for (const texto of textos) {
    const csv = exportarFacturasACsv([factura({ cliente: texto, descripcion: texto })], 2026, 9);
    assert.equal(celda(csv, 'cliente'), texto, `cliente no vuelve idéntico: ${JSON.stringify(texto)}`);
    assert.equal(celda(csv, 'descripcion'), texto === '' ? '' : texto);
  }
});

test('CA-04 ningún carácter parte ni desplaza un registro', () => {
  const csv = exportarFacturasACsv(
    [factura({ cliente: 'a,b\r\nc"d\ne' }), factura({ id: 'F-002', cliente: '","' })],
    2026,
    9,
  );
  const registros = analizarCsv(csv);
  assert.equal(registros.length, 3);
  for (const registro of registros) assert.equal(registro.length, 7);
});

// --- CA-05: codificación y ausencia de BOM --------------------------------

test('CA-05 los caracteres no ASCII sobreviven a la ida y vuelta por UTF-8', () => {
  const texto = 'Muñoz Álvarez 😀';
  const csv = exportarFacturasACsv([factura({ cliente: texto })], 2026, 9);
  const recuperado = Buffer.from(csv, 'utf8').toString('utf8');
  assert.equal(recuperado, csv);
  assert.equal(celda(recuperado, 'cliente'), texto);
});

test('CA-05 el primer byte es la comilla que abre la primera celda: no hay BOM', () => {
  const csv = exportarFacturasACsv([factura()], 2026, 9);
  assert.equal(Buffer.from(csv, 'utf8')[0], 0x22);
});

// --- CA-06 / CA-07: la exportación no recalcula ---------------------------

test('CA-06 los importes leídos de vuelta son estrictamente iguales a los de la entrada', () => {
  const monto = 1234.5678;
  const comision = 0.1 + 0.2;
  const total = 99.995;
  const csv = exportarFacturasACsv([factura({ monto, comision, total })], 2026, 9);
  // `===`, como pide el criterio: `assert.strictEqual` usa Object.is y distingue 0 de -0.
  assert.ok(Number(celda(csv, 'monto')) === monto);
  assert.ok(Number(celda(csv, 'comision')) === comision);
  assert.ok(Number(celda(csv, 'total')) === total);
});

test('CA-06 el módulo no invoca src/tarifa.js ni ninguna otra función de cálculo', () => {
  const fuente = readFileSync(RUTA_MODULO, 'utf8');
  assert.equal(/tarifa/i.test(fuente), false);
  assert.equal(/\brequire\s*\(/.test(fuente), false);
});

test('CA-07 una incoherencia entre monto, comision y total se emite tal cual y no es error', () => {
  const csv = exportarFacturasACsv([factura({ monto: 100, comision: 2, total: 999 })], 2026, 9);
  assert.equal(celda(csv, 'total'), '999.00');
  assert.equal(Number(celda(csv, 'total')), 999);
});

// --- CA-08 / CA-09: formato del importe -----------------------------------

test('CA-08 el importe usa punto decimal, sin miles ni moneda, con al menos 2 decimales', () => {
  const csv = exportarFacturasACsv([factura({ monto: 1234567.5 })], 2026, 9);
  assert.equal(celda(csv, 'monto'), '1234567.50');
  assert.match(celda(csv, 'monto'), /^-?\d+\.\d{2,}$/);
});

test('CA-08 el texto emitido releído con Number es estrictamente igual al valor de entrada', () => {
  const valores = [
    0, -0, 1, -1, 0.1, 0.2, 0.1 + 0.2, 1 / 3, 1234.5678, 99.995, -12.5,
    1e21, 1e-7, 1.5e-8, 5e-324, Number.MAX_VALUE, -Number.MAX_VALUE,
  ];
  for (const valor of valores) {
    const csv = exportarFacturasACsv([factura({ monto: valor, comision: valor, total: valor })], 2026, 9);
    const texto = celda(csv, 'monto');
    // `===` explícito: Object.is (el de assert.strictEqual) distinguiría 0 de -0.
    assert.ok(Number(texto) === valor, `no vuelve al mismo valor: ${valor} → ${texto}`);
    assert.match(texto, /^-?\d+\.\d{2,}$/, `forma decimal inesperada para ${valor}: ${texto}`);
  }
});

test('CA-08 los decimales por encima de 2 se emiten todos, sin truncar ni redondear', () => {
  const csv = exportarFacturasACsv([factura({ monto: 1 / 3, comision: 0.125, total: 2.5 })], 2026, 9);
  assert.equal(celda(csv, 'monto'), '0.3333333333333333');
  assert.equal(celda(csv, 'comision'), '0.125');
  assert.equal(celda(csv, 'total'), '2.50');
});

test('CA-09 el cero se emite como 0.00 y la exportación termina con éxito', () => {
  const csv = exportarFacturasACsv([factura({ monto: 0, comision: 0, total: 0 })], 2026, 9);
  assert.equal(celda(csv, 'monto'), '0.00');
  assert.equal(celda(csv, 'comision'), '0.00');
});

test('CA-09 un importe negativo se emite con el signo delante', () => {
  const csv = exportarFacturasACsv([factura({ monto: -12.5, comision: -0.25, total: -12.75 })], 2026, 9);
  assert.equal(celda(csv, 'monto'), '-12.50');
  assert.equal(celda(csv, 'comision'), '-0.25');
});

// --- CA-10: formato de la fecha -------------------------------------------

test('CA-10 una fecha en cadena AAAA-MM-DD se emite tal cual', () => {
  const csv = exportarFacturasACsv([factura({ fecha: '2026-09-05' })], 2026, 9);
  assert.equal(celda(csv, 'fecha'), '2026-09-05');
});

test('CA-10 un Date se emite en AAAA-MM-DD sin hora y sin que la zona lo desplace un día', () => {
  const primero = exportarFacturasACsv([factura({ fecha: new Date(Date.UTC(2026, 8, 1, 0, 0, 0)) })], 2026, 9);
  const ultimo = exportarFacturasACsv([factura({ fecha: new Date(Date.UTC(2026, 8, 30, 23, 59, 59)) })], 2026, 9);
  assert.equal(celda(primero, 'fecha'), '2026-09-01');
  assert.equal(celda(ultimo, 'fecha'), '2026-09-30');
});

// --- CA-11 / CA-12: selección del mes -------------------------------------

test('CA-11 salen exactamente las facturas del mes pedido, incluidos el día 1 y el último', () => {
  const listado = [
    factura({ id: 'A', fecha: '2026-08-31' }),
    factura({ id: 'B', fecha: '2026-09-01' }),
    factura({ id: 'C', fecha: '2026-09-30' }),
    factura({ id: 'D', fecha: '2026-10-01' }),
  ];
  const registros = analizarCsv(exportarFacturasACsv(listado, 2026, 9));
  assert.deepEqual(registros.slice(1).map((r) => r[0]), ['B', 'C']);
});

test('CA-11 las facturas de otro mes se excluyen en silencio y no son error', () => {
  const csv = exportarFacturasACsv([factura({ fecha: '2025-09-10' }), factura({ id: 'F-002', fecha: '2026-09-10' })], 2026, 9);
  assert.equal(analizarCsv(csv).length, 2);
});

test('CA-12 un listado vacío produce sólo el encabezado terminado en CRLF, con éxito', () => {
  assert.equal(exportarFacturasACsv([], 2026, 9), `${ENCABEZADO}\r\n`);
});

test('CA-12 un listado cuyas facturas son todas de otros meses produce sólo el encabezado', () => {
  const listado = [factura({ fecha: '2026-08-10' }), factura({ id: 'F-002', fecha: '2026-10-10' })];
  assert.equal(exportarFacturasACsv(listado, 2026, 9), `${ENCABEZADO}\r\n`);
});

// --- CA-13: orden determinista --------------------------------------------

test('CA-13 las líneas de datos salen ascendentes por fecha', () => {
  const listado = [
    factura({ id: 'C', fecha: '2026-09-30' }),
    factura({ id: 'A', fecha: '2026-09-01' }),
    factura({ id: 'B', fecha: '2026-09-15' }),
  ];
  const registros = analizarCsv(exportarFacturasACsv(listado, 2026, 9));
  assert.deepEqual(registros.slice(1).map((r) => r[1]), ['2026-09-01', '2026-09-15', '2026-09-30']);
});

test('CA-13 a igualdad de fecha ordena por id comparando por punto de código Unicode', () => {
  // '😀' es U+1F600: por punto de código va DESPUÉS de U+FFFD, aunque su primera
  // unidad UTF-16 (0xD83D) sea menor. Esta prueba distingue las dos comparaciones.
  const listado = [
    factura({ id: '\u{1F600}', fecha: '2026-09-10' }),
    factura({ id: '�', fecha: '2026-09-10' }),
    factura({ id: 'A', fecha: '2026-09-10' }),
  ];
  const registros = analizarCsv(exportarFacturasACsv(listado, 2026, 9));
  assert.deepEqual(registros.slice(1).map((r) => r[0]), ['A', '�', '\u{1F600}']);
});

test('CA-13 dos exportaciones de la misma entrada, en distinto orden de llegada, son idénticas byte a byte', () => {
  const a = factura({ id: 'X', fecha: '2026-09-02', cliente: 'Uno' });
  const b = factura({ id: 'X', fecha: '2026-09-02', cliente: 'Dos' }); // mismo id y fecha
  const c = factura({ id: 'A', fecha: '2026-09-20' });
  const primera = exportarFacturasACsv([a, b, c], 2026, 9);
  const segunda = exportarFacturasACsv([c, b, a], 2026, 9);
  assert.equal(primera, segunda);
  assert.deepEqual(Buffer.from(primera, 'utf8'), Buffer.from(segunda, 'utf8'));
});

// --- CA-14 / CA-15 / CA-16: alcance de lo que sale ------------------------

test('CA-14 la salida tiene exactamente las columnas contratadas y en su orden', () => {
  const registros = analizarCsv(exportarFacturasACsv([factura()], 2026, 9));
  assert.deepEqual(registros[0], COLUMNAS);
  assert.equal(registros[1].length, COLUMNAS.length);
});

test('CA-14 ninguna propiedad adicional del objeto de entrada aparece en la salida', () => {
  const csv = exportarFacturasACsv(
    [factura({ idClienteInterno: 'CLI-77', notas: 'moroso', telefono: '+506 8888 8888' })],
    2026,
    9,
  );
  for (const rastro of ['idClienteInterno', 'CLI-77', 'notas', 'moroso', 'telefono', '8888']) {
    assert.equal(csv.includes(rastro), false, `la salida filtra ${rastro}`);
  }
});

test('CA-15 un texto que parece fórmula de hoja de cálculo se emite sin anteponer ni sustituir nada', () => {
  const csv = exportarFacturasACsv([factura({ cliente: '=SUMA(A1:A2)', descripcion: '+1-2' })], 2026, 9);
  assert.equal(celda(csv, 'cliente'), '=SUMA(A1:A2)');
  assert.equal(celda(csv, 'descripcion'), '+1-2');
  assert.ok(csv.includes('"=SUMA(A1:A2)"'));
});

test('CA-15 no se recortan los espacios del principio ni del final', () => {
  const csv = exportarFacturasACsv([factura({ cliente: '  Ana  ' })], 2026, 9);
  assert.equal(celda(csv, 'cliente'), '  Ana  ');
});

test('CA-16 la descripcion ausente, null, undefined o vacía se emite como celda vacía', () => {
  const variantes = [facturaSin('descripcion'), factura({ descripcion: null }), factura({ descripcion: undefined }), factura({ descripcion: '' })];
  for (const entrada of variantes) {
    const csv = exportarFacturasACsv([entrada], 2026, 9);
    assert.equal(celda(csv, 'descripcion'), '');
    assert.ok(csv.includes('"ACME","",'), 'la celda vacía debe ser un par de comillas');
  }
});

test('CA-16 nunca se emite el texto null, undefined ni NaN en lugar de la descripcion', () => {
  for (const entrada of [facturaSin('descripcion'), factura({ descripcion: null })]) {
    const csv = exportarFacturasACsv([entrada], 2026, 9);
    for (const literal of ['null', 'undefined', 'NaN']) {
      assert.equal(csv.includes(literal), false, `la salida contiene el literal ${literal}`);
    }
  }
});

// --- CA-17 / CA-18: facturas defectuosas ----------------------------------

test('CA-17 si falta el id, el error nombra la posición en el listado y el campo', () => {
  assert.throws(
    () => exportarFacturasACsv([factura(), facturaSin('id')], 2026, 9),
    /posición 1[\s\S]*"id"/,
  );
});

test('CA-17 si falta un campo obligatorio, el error nombra el id de la factura y el campo', () => {
  assert.throws(() => exportarFacturasACsv([facturaSin('cliente')], 2026, 9), /la factura "F-001"/);
  assert.throws(() => exportarFacturasACsv([facturaSin('cliente')], 2026, 9), /"cliente"/);
  assert.throws(() => exportarFacturasACsv([facturaSin('total')], 2026, 9), /"total"/);
  assert.throws(() => exportarFacturasACsv([facturaSin('fecha')], 2026, 9), /"fecha"/);
});

test('CA-17 un campo con el tipo equivocado falla nombrando el campo', () => {
  assert.throws(() => exportarFacturasACsv([factura({ cliente: 42 })], 2026, 9), /"cliente"/);
  assert.throws(() => exportarFacturasACsv([factura({ id: '' })], 2026, 9), /"id"/);
  assert.throws(() => exportarFacturasACsv([factura({ fecha: '10/09/2026' })], 2026, 9), /"fecha"/);
  assert.throws(() => exportarFacturasACsv([factura({ fecha: new Date('no es fecha') })], 2026, 9), /"fecha"/);
  assert.throws(() => exportarFacturasACsv([factura({ descripcion: 7 })], 2026, 9), /"descripcion"/);
});

test('CA-17 no se devuelve un CSV parcial ni con la fila defectuosa omitida', () => {
  let salida = 'centinela';
  assert.throws(() => {
    salida = exportarFacturasACsv([factura({ id: 'BUENA' }), factura({ id: 'MALA', cliente: null })], 2026, 9);
  });
  assert.equal(salida, 'centinela');
});

test('CA-18 un importe que no es un número finito falla nombrando la factura y el campo', () => {
  for (const valor of [NaN, Infinity, -Infinity, '12.00', null, undefined, {}]) {
    assert.throws(
      () => exportarFacturasACsv([factura({ monto: valor })], 2026, 9),
      /la factura "F-001"[\s\S]*"monto"/,
      `un monto de tipo ${typeof valor} debería fallar`,
    );
  }
  assert.throws(() => exportarFacturasACsv([factura({ comision: NaN })], 2026, 9), /"comision"/);
  assert.throws(() => exportarFacturasACsv([factura({ total: Infinity })], 2026, 9), /"total"/);
});

test('CA-18 un importe no representable nunca se sustituye por 0, por vacío ni por una aproximación', () => {
  let salida = null;
  assert.throws(() => {
    salida = exportarFacturasACsv([factura({ total: NaN })], 2026, 9);
  });
  assert.equal(salida, null);
});

// --- CA-19 / CA-20: argumentos de la llamada ------------------------------

test('CA-19 un mes que no es un entero entre 1 y 12 falla nombrando el argumento', () => {
  for (const mes of [0, 13, -1, 1.5, '9', NaN, null, undefined]) {
    assert.throws(() => exportarFacturasACsv([factura()], 2026, mes), /"mes"/, `mes ${String(mes)}`);
  }
});

test('CA-19 un año que no es un entero falla nombrando el argumento', () => {
  for (const anio of [2026.5, '2026', NaN, null, undefined]) {
    assert.throws(() => exportarFacturasACsv([factura()], anio, 9), /"anio"/, `anio ${String(anio)}`);
  }
});

test('CA-20 un listado que no es un arreglo falla y no se interpreta como listado vacío', () => {
  for (const listado of [null, undefined, {}, 'facturas', 42, new Set()]) {
    let salida = null;
    assert.throws(() => {
      salida = exportarFacturasACsv(listado, 2026, 9);
    }, /"facturas"/);
    assert.equal(salida, null);
  }
});
