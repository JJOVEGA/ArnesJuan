// Pruebas de REQ-001 — Validación de la fecha de corte (CA-01 y CA-02).
// Runner nativo de Node (`node --test`), CommonJS: el stack del proyecto es
// JavaScript sin framework (AGENTS.md §2) y src/fecha.js exporta con module.exports.
// Viven fuera de src/ a propósito: .arnes/config.json declara codigo_app.globs
// ["src/*"] y los tests quedan fuera para que el qa-tester pueda editarlos.

const test = require('node:test');
const assert = require('node:assert/strict');

const { esBisiesto, diasDelMes } = require('../src/fecha.js');

// CA-01 enuncia el rechazo por una propiedad ("el día es mayor que el número de
// días que ese mes tiene en ese año") y remite la regla exhaustiva al sitio
// único: diasDelMes(m, a). src/fecha.js NO exporta hoy ninguna función que
// ejecute ese rechazo, así que el predicado vive AQUÍ, en la prueba, copiando
// literalmente la comparación del criterio. No es API de producción ni pretende
// serlo: es el enunciado de CA-01 escrito en código para poder ejercitarlo
// contra el sitio único. (Observación elevada al analista en el informe.)
const diaExcedeElMes = (dia, mes, anio) => dia > diasDelMes(mes, anio);

// Oráculo independiente del código bajo prueba: el día 0 del mes siguiente es el
// último día del mes pedido. Sirve para que la prueba de CA-01 no sea una copia
// de la tabla que valida.
const ultimoDiaSegunDate = (mes, anio) => new Date(Date.UTC(anio, mes, 0)).getUTCDate();

const ANIOS_MUESTRA = [1600, 1700, 1800, 1900, 1999, 2000, 2020, 2023, 2024, 2025, 2100, 2400];

test('CA-02 — ejemplos nombrados en el criterio (no exhaustivos)', () => {
  assert.equal(esBisiesto(2024), true, '2024 es bisiesto');
  assert.equal(esBisiesto(2000), true, '2000 es bisiesto (divisible por 400)');
  assert.equal(esBisiesto(1900), false, '1900 no es bisiesto (divisible por 100, no por 400)');
  assert.equal(esBisiesto(2023), false, '2023 no es bisiesto');
});

test('CA-02 — esBisiesto decide la pertenencia por la propiedad gregoriana', () => {
  for (let anio = 1; anio <= 3000; anio++) {
    const gregoriano = (anio % 4 === 0 && anio % 100 !== 0) || anio % 400 === 0;
    assert.equal(esBisiesto(anio), gregoriano, `esBisiesto(${anio})`);
  }
});

test('CA-02 — febrero tiene 29 días exactamente en los años bisiestos, y 28 en el resto', () => {
  // Los números 29 y 28 son de contrato (los fija el calendario gregoriano).
  for (let anio = 1; anio <= 3000; anio++) {
    assert.equal(diasDelMes(2, anio), esBisiesto(anio) ? 29 : 28, `diasDelMes(2, ${anio})`);
  }
});

test('CA-02 — el 29 de febrero se acepta en año bisiesto', () => {
  // Los años se filtran con el propio esBisiesto, así que se comprueba primero que
  // el conjunto no queda vacío: una iteración vacía pasaría sin medir nada.
  const bisiestos = ANIOS_MUESTRA.filter(esBisiesto);
  assert.ok(bisiestos.length > 0, 'la muestra debe contener años bisiestos');
  for (const anio of bisiestos) {
    assert.equal(diaExcedeElMes(29, 2, anio), false, `29/02/${anio} no debe rechazarse`);
  }
});

test('CA-02 — el 29 de febrero se rechaza en año no bisiesto (por CA-01)', () => {
  const noBisiestos = ANIOS_MUESTRA.filter((a) => !esBisiesto(a));
  assert.ok(noBisiestos.length > 0, 'la muestra debe contener años no bisiestos');
  for (const anio of noBisiestos) {
    assert.equal(diasDelMes(2, anio), 28, `febrero de ${anio} tiene 28 días`);
    assert.equal(diaExcedeElMes(29, 2, anio), true, `29/02/${anio} debe rechazarse`);
  }
});

test('CA-01 — el sitio único da, para cada mes, los días que ese mes tiene en ese año', () => {
  for (let anio = 1; anio <= 3000; anio++) {
    for (let mes = 1; mes <= 12; mes++) {
      assert.equal(diasDelMes(mes, anio), ultimoDiaSegunDate(mes, anio), `diasDelMes(${mes}, ${anio})`);
    }
  }
});

test('CA-01 — un día mayor que los del mes se rechaza', () => {
  for (const anio of ANIOS_MUESTRA) {
    for (let mes = 1; mes <= 12; mes++) {
      const dias = diasDelMes(mes, anio);
      assert.equal(diaExcedeElMes(dias + 1, mes, anio), true, `${dias + 1}/${mes}/${anio} debe rechazarse`);
    }
  }
});

test('CA-01 — un día que no excede los del mes no se rechaza por esta regla', () => {
  for (const anio of ANIOS_MUESTRA) {
    for (let mes = 1; mes <= 12; mes++) {
      const dias = diasDelMes(mes, anio);
      assert.equal(diaExcedeElMes(dias, mes, anio), false, `${dias}/${mes}/${anio} no debe rechazarse`);
      assert.equal(diaExcedeElMes(1, mes, anio), false, `1/${mes}/${anio} no debe rechazarse`);
    }
  }
});
