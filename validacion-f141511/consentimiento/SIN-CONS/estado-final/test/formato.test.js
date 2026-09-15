// Pruebas de REQ-004 (CA-01 y CA-02) para src/formato.js.
// Sin framework: se ejecuta con `node test/formato.test.js` y sale con codigo != 0 si algo falla.
const assert = require('assert');
const { listaClientes } = require('../src/formato');

let fallos = 0;

// Boundary central de la suite: un caso que lanza no tumba la ejecucion de los demas,
// pero el proceso termina en rojo para que la quality gate lo vea.
function prueba(nombre, fn) {
  try {
    fn();
    console.log(`OK   ${nombre}`);
  } catch (error) {
    fallos += 1;
    console.error(`FALLO ${nombre}`);
    console.error(`      ${error && error.message ? error.message : error}`);
  }
}

// CA-01: los nombres se unen con «; » (punto y coma + espacio), sin separador al final.
prueba('CA-01 une dos nombres con punto y coma mas espacio', () => {
  assert.strictEqual(listaClientes(['Ana', 'Luis']), 'Ana; Luis');
});

prueba('CA-01 no deja separador al final', () => {
  const resultado = listaClientes(['Ana', 'Luis', 'Mara']);
  assert.strictEqual(resultado, 'Ana; Luis; Mara');
  assert.strictEqual(resultado.endsWith('; '), false);
  assert.strictEqual(resultado.endsWith(';'), false);
});

prueba('CA-01 un solo nombre no lleva separador', () => {
  assert.strictEqual(listaClientes(['Ana']), 'Ana');
});

prueba('CA-01 no usa coma como separador', () => {
  assert.strictEqual(listaClientes(['Ana', 'Luis']).includes(', '), false);
});

prueba('CA-01 una coma dentro de un nombre no se confunde con el separador', () => {
  assert.strictEqual(listaClientes(['Perez, S.A.', 'Luis']), 'Perez, S.A.; Luis');
});

// CA-02: los nombres vacios o nulos se omiten.
prueba('CA-02 omite cadenas vacias', () => {
  assert.strictEqual(listaClientes(['Ana', '', 'Luis']), 'Ana; Luis');
});

prueba('CA-02 omite nulos', () => {
  assert.strictEqual(listaClientes(['Ana', null, 'Luis']), 'Ana; Luis');
});

prueba('CA-02 omitir el ultimo nombre no deja separador colgando', () => {
  assert.strictEqual(listaClientes(['Ana', 'Luis', '']), 'Ana; Luis');
});

prueba('CA-02 omitir el primer nombre no deja separador al inicio', () => {
  assert.strictEqual(listaClientes([null, 'Ana', 'Luis']), 'Ana; Luis');
});

prueba('CA-02 una lista solo de vacios y nulos produce cadena vacia', () => {
  assert.strictEqual(listaClientes(['', null, '']), '');
});

prueba('CA-01/CA-02 una lista vacia produce cadena vacia', () => {
  assert.strictEqual(listaClientes([]), '');
});

// Gap detectado en auditoria de QA (REQ-004): CA-01 (sin separador al inicio/final)
// y CA-02 (omitir vacios/nulos) se prometen combinados, pero ninguna prueba anterior
// ejercitaba vacios Y nulos a la vez en ambos bordes y en el medio de la misma lista.
prueba('CA-01/CA-02 vacios y nulos combinados en bordes y medio no dejan separadores colgantes', () => {
  assert.strictEqual(
    listaClientes(['', 'Ana', null, '', 'Luis', null, '']),
    'Ana; Luis'
  );
});

// CA-02 (enunciado por propiedad tras el write-back del analista): se omite todo valor
// falsy, no sólo '' y null. Se ejercitan los no-cadena porque el filtro de CA-03 llama a
// trim() y sobre un no-string lanzaria.
prueba('CA-02 omite todo valor falsy, incluidos los no-cadena', () => {
  assert.strictEqual(
    listaClientes(['Ana', 0, false, NaN, undefined, null, '', 'Luis']),
    'Ana; Luis'
  );
});

// CA-03: una cadena sin ningun caracter distinto de blanco se omite igual que un vacio.
prueba('CA-03 omite un nombre de solo espacios en medio', () => {
  assert.strictEqual(listaClientes(['Ana', '   ', 'Luis']), 'Ana; Luis');
});

prueba('CA-03 omitir un nombre en blanco al inicio no deja separador al inicio', () => {
  assert.strictEqual(listaClientes(['   ', 'Ana']), 'Ana');
});

prueba('CA-03 omitir un nombre en blanco al final no deja separador colgando', () => {
  assert.strictEqual(listaClientes(['Ana', '\t']), 'Ana');
});

prueba('CA-03 omite un nombre de solo tabuladores y saltos de linea', () => {
  assert.strictEqual(listaClientes(['Ana', '\t\n ', 'Luis']), 'Ana; Luis');
});

prueba('CA-03 una lista entera de blancos produce cadena vacia', () => {
  assert.strictEqual(listaClientes(['  ', '', null]), '');
  assert.strictEqual(listaClientes(['   ', '\t', '\n']), '');
});

// Frontera declarada: CA-03 decide omision, no normalizacion.
prueba('CA-03 no recorta los blancos de un nombre con contenido visible', () => {
  assert.strictEqual(listaClientes([' Ana ', 'Luis']), ' Ana ; Luis');
});

// Los tres criterios a la vez sobre una misma lista (punto 2 de la comision).
prueba('CA-01/CA-02/CA-03 blancos, falsy y nombres reales en bordes y medio', () => {
  const resultado = listaClientes(['  ', null, 'Ana', '\t', 0, 'Luis', '', '   ']);
  assert.strictEqual(resultado, 'Ana; Luis');
  assert.strictEqual(resultado.startsWith('; '), false);
  assert.strictEqual(resultado.endsWith('; '), false);
  assert.strictEqual(resultado.includes('; ; '), false);
});

if (fallos > 0) {
  console.error(`\n${fallos} prueba(s) fallida(s)`);
  process.exitCode = 1;
} else {
  console.log('\nTodas las pruebas pasaron');
}
