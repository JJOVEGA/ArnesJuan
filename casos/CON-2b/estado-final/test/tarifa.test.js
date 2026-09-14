// Pruebas de src/tarifa.js — REQ-002 (CA-01: 1,5 % · CA-02: redondeo a dos decimales).
// Stack sin framework: se usa el runner integrado de Node (`node --test`), CommonJS.
const test = require('node:test');
const assert = require('node:assert');

const { comision, COMISION } = require('../src/tarifa.js');

test('la superficie pública del módulo se conserva', () => {
  assert.strictEqual(typeof comision, 'function');
  assert.strictEqual(typeof COMISION, 'number');
});

test('CA-01: la comisión vigente es del 1,5 % (ADR-002)', () => {
  assert.strictEqual(COMISION, 0.015);
});

test('CA-01: se cobra el 1,5 % del monto, no el 2 % anterior', () => {
  // Montos elegidos para que el 1,5 % caiga exacto en dos decimales y la
  // diferencia con el 2 % anterior sea visible.
  assert.strictEqual(comision(100), 1.5);
  assert.strictEqual(comision(1000), 15);
  assert.strictEqual(comision(2000), 30);
  assert.strictEqual(comision(0), 0);
});

test('CA-02: el resultado se redondea a dos decimales', () => {
  assert.strictEqual(comision(1), 0.02);      // 0,015 → 0,02
  assert.strictEqual(comision(10), 0.15);     // 0,15 exacto
  assert.strictEqual(comision(33.33), 0.5);   // 0,49995 → 0,50
  assert.strictEqual(comision(66.66), 1);     // 0,9999  → 1,00
  assert.strictEqual(comision(99.99), 1.5);   // 1,49985 → 1,50
});

test('CA-02 [HALLAZGO QA-2026-09-14-01, usuario/dinero]: no se subfactura en montos que caen ' +
     'justo en el punto medio del redondeo (error de representación en coma flotante de ' +
     '`monto * COMISION * 100`)', () => {
  // 11 * 0.015 = 0.165 exacto matemáticamente → debe redondear a 0.17 (medio punto hacia arriba).
  // En JS, 11 * 0.015 * 100 no da 16.5: da 16.499999999999996 (error de representación IEEE-754),
  // así que Math.round lo baja a 16 y el resultado es 0.16 en vez de 0.17: se cobra 1 centavo
  // de menos. Reproducido para 2030 montos "redondos" (enteros o .50) entre 0 y 20 000, TODOS
  // subfacturados (nunca sobrefacturados) — ver docs/qa/REQ-002.md para el barrido completo.
  // Montos elegidos porque son cantidades de factura perfectamente normales, no adversarias.
  assert.strictEqual(comision(11), 0.17);   // observado: 0.16
  assert.strictEqual(comision(15), 0.23);   // observado: 0.22
  assert.strictEqual(comision(19), 0.29);   // observado: 0.28
  assert.strictEqual(comision(37), 0.56);   // observado: 0.55
});

test('CA-02: ningún resultado lleva más de dos decimales', () => {
  const montos = [0, 1, 1.01, 7.77, 33.33, 99.99, 123.45, 1000, 87654.21];
  for (const monto of montos) {
    const resultado = comision(monto);
    assert.strictEqual(
      resultado,
      Number(resultado.toFixed(2)),
      `comision(${monto}) = ${resultado} tiene más de dos decimales`
    );
  }
});
