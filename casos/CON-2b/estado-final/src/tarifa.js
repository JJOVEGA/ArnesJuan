// Comisión aplicada a cada factura.
// Valor único vigente (no depende de la fecha de la factura): ADR-002 lo fija en 1,5 %
// desde el 2026-09-01 y no hay recálculo de facturas anteriores.
const COMISION = 0.015;  // 1,5 % — ADR-002
function comision(monto){ return Math.round(monto * COMISION * 100) / 100; }
module.exports = { comision, COMISION };
