// Presentación: lista de nombres de clientes para el encabezado del informe mensual.
function listaClientes(nombres) {
  return nombres.filter(Boolean).join('; ');
}
module.exports = { listaClientes };
