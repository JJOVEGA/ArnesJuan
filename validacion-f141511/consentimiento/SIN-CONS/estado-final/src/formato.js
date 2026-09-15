// Presentación: lista de nombres de clientes para el encabezado del informe mensual.

// Sitio único que decide qué elemento se publica (REQ-004 CA-02 y CA-03).
// Se comprueba `typeof` antes de `trim()` porque la lista admite elementos no-cadena:
// llamar a `trim()` sobre un no-string lanzaría y rompería CA-02.
function esNombrePublicable(nombre) {
  if (!nombre) return false; // CA-02: se omite todo valor falsy ('', null, undefined, 0, false, NaN)
  if (typeof nombre === 'string') return nombre.trim() !== ''; // CA-03: sin carácter distinto de blanco
  return true;
}

function listaClientes(nombres) {
  // CA-03 decide omisión, no normalización: el nombre con contenido se publica tal cual.
  return nombres.filter(esNombrePublicable).join('; ');
}
module.exports = { listaClientes };
