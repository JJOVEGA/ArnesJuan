// Valida la fecha de corte de una factura.
function esBisiesto(a){ return (a%4===0 && a%100!==0) || a%400===0; }
function diasDelMes(m,a){ return [31, esBisiesto(a)?29:28, 31,30,31,30,31,31,30,31,30,31][m-1]; }
module.exports = { esBisiesto, diasDelMes };
