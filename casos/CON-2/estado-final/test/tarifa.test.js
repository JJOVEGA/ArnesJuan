// Pruebas de REQ-002 — Comisión por factura (CA-01: 1,5 % · CA-02: dos decimales).
// Causa del cambio de valor esperado: ADR-002 (aceptado 2026-09-01), 2 % → 1,5 %.
// Ejecutar:  node test/tarifa.test.js     (sin dependencias; sale != 0 si algo falla)
const assert = require('assert');
const { comision, COMISION } = require('../src/tarifa');

// Las comparaciones de importe van sobre toFixed(2) a propósito: el contrato de CA-02 es el
// importe redondeado a dos decimales, no la representación binaria exacta del double.
const casos = [];
const test = (nombre, fn) => casos.push({ nombre, fn });

// --- CA-01: la comisión es el 1,5 % del monto (número de contrato, ADR-002) ---
test('CA-01 · la constante de comisión es 1,5 % (0.015)', () => {
  assert.strictEqual(COMISION, 0.015);
});

test('CA-01 · 100 → 1.50', () => {
  assert.strictEqual(comision(100).toFixed(2), '1.50');
});

test('CA-01 · 1000 → 15.00', () => {
  assert.strictEqual(comision(1000).toFixed(2), '15.00');
});

test('CA-01 · 2000 → 30.00', () => {
  assert.strictEqual(comision(2000).toFixed(2), '30.00');
});

test('CA-01 · monto 0 → 0.00', () => {
  assert.strictEqual(comision(0).toFixed(2), '0.00');
});

// No-regresión explícita contra el valor derogado: con el 2 % viejo esto daría 20.00.
test('CA-01 · no se aplica ya el 2 % derogado (1000 no da 20.00)', () => {
  assert.notStrictEqual(comision(1000).toFixed(2), '20.00');
  assert.notStrictEqual(COMISION, 0.02);
});

// --- CA-02: el resultado se redondea a dos decimales ---
test('CA-02 · 10.03 → 0.15 (0.15045 redondeado)', () => {
  assert.strictEqual(comision(10.03).toFixed(2), '0.15');
});

test('CA-02 · 66.67 → 1.00 (1.00005 redondeado)', () => {
  assert.strictEqual(comision(66.67).toFixed(2), '1.00');
});

test('CA-02 · 999.99 → 15.00 (14.99985 redondeado)', () => {
  assert.strictEqual(comision(999.99).toFixed(2), '15.00');
});

test('CA-02 · el resultado nunca tiene más de dos decimales', () => {
  for (const monto of [10.03, 66.67, 999.99, 1234.56, 7.77]) {
    const decimales = String(comision(monto)).split('.')[1] || '';
    assert.ok(decimales.length <= 2, `comision(${monto}) = ${comision(monto)}`);
  }
});

// --- Contrato del módulo: la reparación no cambia firma ni exportaciones ---
test('contrato · comision es función de un único parámetro (monto)', () => {
  assert.strictEqual(typeof comision, 'function');
  assert.strictEqual(comision.length, 1);
});

test('contrato · el módulo exporta comision y COMISION', () => {
  const mod = require('../src/tarifa');
  assert.deepStrictEqual(Object.keys(mod).sort(), ['COMISION', 'comision']);
});

// Boundary único: ningún caso tumba el proceso; cada fallo se reporta y se acumula.
let fallidos = 0;
for (const { nombre, fn } of casos) {
  try {
    fn();
    console.log(`ok    ${nombre}`);
  } catch (err) {
    fallidos++;
    console.error(`FALLA ${nombre}\n      ${err.message}`);
  }
}
console.log(`\n${casos.length - fallidos}/${casos.length} pruebas en verde`);
if (fallidos > 0) process.exitCode = 1;
