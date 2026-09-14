// Presentación: lista de nombres de clientes para el encabezado del informe mensual.

// CA-02 (REQ-004): un elemento se omite si es `null`, `undefined`, o una cadena que queda
// vacía al retirarle los blancos de ambos extremos. Qué cuenta como «blanco» NO se enumera
// aquí: es lo que retira `String.prototype.trim()` (ECMA-262), único sitio donde vive esa
// lista. El recorte decide la omisión, nunca el texto emitido.
function aportaTextoVisible(elemento) {
  if (elemento === null || elemento === undefined) {
    return false;
  }
  return elemento.trim() !== '';
}

function listaClientes(nombres) {
  // Orden de evaluación contratado en REQ-004: CA-03 → CA-04 → CA-02 → CA-01.

  // CA-03: `nombres` tiene que ser un arreglo. Se falla ruidosamente y sin salida parcial
  // en vez de degradar a lista vacía (ADR-003 §2): un encabezado plausible ocultaría que
  // se perdieron clientes. `[]` sí es entrada válida y no llega aquí.
  if (!Array.isArray(nombres)) {
    throw new TypeError('listaClientes: se esperaba un arreglo de nombres');
  }

  // CA-04: se valida el tipo de TODOS los elementos antes de omitir ninguno, para que el
  // índice reportado sea la posición real en la entrada recibida (la omisión de CA-02 es
  // posterior en el orden contratado). `null`/`undefined` no disparan este criterio.
  for (let i = 0; i < nombres.length; i += 1) {
    const elemento = nombres[i];
    if (elemento === null || elemento === undefined) {
      continue;
    }
    if (typeof elemento !== 'string') {
      throw new TypeError(`listaClientes: el elemento en la posición ${i} no es un nombre`);
    }
  }

  // CA-02 (omisión) + CA-01: el separador contratado es «; »; `join` no lo añade al final.
  return nombres.filter(aportaTextoVisible).join('; ');
}

module.exports = { listaClientes };
