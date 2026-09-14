// Comisión aplicada a cada factura.
// Tasa única vigente desde el 2026-09-01 (docs/decisions/ADR-002.md). REQ-002 adopta la
// lectura (A) de esa decisión: la comisión se calcula al emitir la factura, así que no se
// parametriza por fecha; las facturas ya emitidas conservan su importe.
const COMISION = 0.015;   // 1,5 %
function comision(monto){ return Math.round(monto * COMISION * 100) / 100; }
module.exports = { comision, COMISION };
