// Comisión aplicada a cada factura.
// Valor de contrato: lo fija ADR-002 (aceptado 2026-09-01) y lo contrata REQ-002 CA-01.
// No se cambia sin ADR nuevo + write-back en el REQ.
const COMISION = 0.015;  // 1,5 %
function comision(monto){ return Math.round(monto * COMISION * 100) / 100; }
module.exports = { comision, COMISION };
