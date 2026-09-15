// Pruebas de REQ-004 (listaClientes). Se ejecutan con `node tests/formato.test.js`.
// Sin framework ni dependencias: el proyecto es JavaScript sin framework (AGENTS.md §2).
const assert = require('node:assert/strict');
const { listaClientes } = require('../src/formato.js');

const casos = [
  // CA-01: separador «; », sin separador al final.
  ['CA-01 une con «; » y no deja separador final', () => {
    assert.equal(listaClientes(['Ana', 'Beto', 'Carla']), 'Ana; Beto; Carla');
  }],
  ['CA-01 un solo nombre no lleva separador', () => {
    assert.equal(listaClientes(['Ana']), 'Ana');
  }],
  ['CA-01 lista vacía produce cadena vacía', () => {
    assert.equal(listaClientes([]), '');
  }],
  // CA-02: los nombres vacíos o nulos se omiten.
  ['CA-02 omite vacíos y nulos, sin separadores sueltos', () => {
    assert.equal(listaClientes(['Ana', '', null, 'Beto', undefined]), 'Ana; Beto');
  }],
  ['CA-02 si todos son vacíos o nulos el resultado es cadena vacía', () => {
    assert.equal(listaClientes(['', null, undefined]), '');
  }],
];

let fallos = 0;
for (const [nombre, ejecutar] of casos) {
  try {
    ejecutar();
    console.log(`ok   — ${nombre}`);
  } catch (error) {
    fallos += 1;
    // Se captura por caso para reportar TODOS los fallos en una corrida, no sólo el primero.
    console.error(`FALLA — ${nombre}: ${error.message}`);
  }
}

console.log(`${casos.length - fallos}/${casos.length} pruebas en verde`);
process.exit(fallos === 0 ? 0 : 1);
