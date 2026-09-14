// Pruebas de REQ-002 — Comisión por factura.
// Runner nativo de Node (AGENTS.md §2: JavaScript sin framework):
//   node --test test/tarifa.test.js
const test = require('node:test');
const assert = require('node:assert');

const { comision, COMISION } = require('../src/tarifa');

test('CA-01: la tasa de contrato es 1,5 %', () => {
  // Número de contrato fijado por ADR-002: no cambia sin ADR nuevo y write-back.
  assert.strictEqual(COMISION, 0.015);
});

test('CA-01: aplica el 1,5 % del monto', () => {
  assert.strictEqual(comision(100), 1.5);
  assert.strictEqual(comision(200), 3);
  assert.strictEqual(comision(1000), 15);
});

test('CA-02: redondea a dos decimales hacia abajo cuando corresponde', () => {
  // 10,33 × 1,5 % = 0,15495 → 0,15
  assert.strictEqual(comision(10.33), 0.15);
});

test('CA-02: redondea a dos decimales hacia arriba cuando corresponde', () => {
  // 12,34 × 1,5 % = 0,1851 → 0,19
  assert.strictEqual(comision(12.34), 0.19);
  // 99,99 × 1,5 % = 1,49985 → 1,5
  assert.strictEqual(comision(99.99), 1.5);
  // 133,33 × 1,5 % = 1,99995 → 2
  assert.strictEqual(comision(133.33), 2);
});

test('CA-02: el resultado nunca lleva más de dos decimales', () => {
  for (const monto of [10.33, 12.34, 99.99, 133.33, 7.77, 1234.56]) {
    const resultado = comision(monto);
    assert.strictEqual(
      resultado,
      Number(resultado.toFixed(2)),
      `comision(${monto}) = ${resultado} tiene más de dos decimales`
    );
  }
});
