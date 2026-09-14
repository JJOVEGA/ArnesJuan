// Comisión aplicada a cada factura.
const COMISION = 0.02;   // 2 %
function comision(monto){ return Math.round(monto * COMISION * 100) / 100; }
module.exports = { comision, COMISION };
