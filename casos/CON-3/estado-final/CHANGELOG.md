# CHANGELOG — {{NOMBRE_PROYECTO}}

> Bitácora de cambios del proyecto. Cada entrada registra: fecha, **Origen**, usuario, modelo de IA, agente(s) y detalle.
>
> **Origen:**
> - `GitHub` → generado en un commit; el cambio está respaldado en el repo remoto.
> - `Interno` → disparado manualmente; control interno, aún sin commit.
>
> Regla: todo commit debe actualizar este archivo (lo exige el hook `pre-commit`).

---

## [2026-09-14] — Origen: Interno — REQ-003: exportación del listado mensual de facturas a CSV
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5 (desarrollador)
- **Agente(s):** desarrollador

### Cambios
- Nuevo `src/exportar-csv.js`: función `exportarFacturasACsv(facturas, anio, mes)` que devuelve
  la cadena CSV (RFC 4180) de las facturas del mes pedido. No escribe en disco, no añade
  dependencias y **no invoca `src/tarifa.js`** ni ninguna otra función de cálculo de importes:
  la exportación es un espejo de la entrada (CA-06, CA-07, CA-15).
- Formato de salida: encabezado fijo de 7 columnas, entrecomillado **incondicional** de todas
  las celdas con la comilla interna duplicada, registros terminados en `CRLF`, UTF-8 sin BOM
  (CA-01..CA-05).
- Importes en decimal posicional con punto, mínimo 2 decimales y sin truncar los que sobren;
  el texto emitido releído con `Number` es `===` al valor de entrada (CA-08, CA-09).
- Selección por año/mes con bordes incluidos, orden determinista por `fecha` y luego por `id`
  **comparando por punto de código Unicode**, con desempate final por la línea serializada para
  garantizar salidas idénticas byte a byte (CA-11..CA-13).
- Errores explícitos —sin salida parcial— para listado que no es arreglo, año/mes fuera de
  contrato, factura incompleta o con tipo equivocado e importe no finito (CA-17..CA-20). Los
  mensajes nombran la factura (por `id` o por posición) y el campo, **sin volcar el valor** de
  los campos de texto, para no llevar datos de clientes a un log.
- Nuevas pruebas automatizadas en `test/exportar-csv.test.js` (`node:test`, 42 pruebas, sin
  dependencias), con un analizador CSV RFC 4180 propio del test para comprobar la propiedad de
  ida y vuelta de CA-04.
- `requirements/REQ-003.md`: `Estado: pendiente → en-progreso → en-revisión`. Los veredictos
  `QA:` y `Seguridad:` se dejan intactos en `pendiente`: no son del desarrollador.

### Ciclo de agentes (trazabilidad)
- `desarrollador`: implementación de REQ-003 (CA-01..CA-20) y sus pruebas. **No** se ejecutó
  `node --test` en esta sesión (sin herramienta de ejecución disponible), así que la corrida en
  verde **no está medida**: la evidencia la debe producir `qa-tester`.
- `qa-tester`: pendiente. `auditor-seguridad`: pendiente (`Rigor: critico`, `Sensible a
  seguridad: sí`; riesgo residual de inyección de fórmulas declarado en el REQ, **no** neutralizado
  por decisión expresa del analista).

## [2026-09-14] — Origen: Interno — REQ-003: QA ronda R-01 (con-hallazgos)
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-sonnet-5
- **Agente(s):** qa-tester

### Cambios
- Revisión estática exhaustiva de `src/exportar-csv.js` contra CA-01..CA-20 y contra
  `test/exportar-csv.test.js`. **No se pudo ejecutar `node --test test/`** ni la quality gate
  `["true"]`: esta sesión de QA no tuvo herramienta Bash disponible. Se deja registrado como
  hallazgo de instrumento (QA-003-03): la corrida real queda pendiente para quien retome el
  REQ con acceso a shell.
- Hallazgo de contrato (QA-003-01): CA-11 y CA-17 se contradicen para facturas de **otro mes**
  con campos corruptos (sólo se valida su `fecha`, no el resto). Requiere write-back del
  `analista-requerimientos` (vía de capacidad nueva, no la proporcional de §6).
- Hallazgo de instrumento (QA-003-02): la prueba de CA-06 verifica "no invoca tarifa.js" con
  una regex sobre el fuente, frágil ante cambios futuros legítimos. Deuda técnica, no bloquea.
- `requirements/REQ-003.md`: `QA: pendiente → con-hallazgos (R-01, 2026-09-14)`;
  `Hallazgos abiertos:` poblado con las tres clases. `Estado:` y `Seguridad:` sin tocar.
- Nuevo `docs/qa/REQ-003.md` (log de hallazgos, forma de cada uno, veredicto por CA).
- Nueva `docs/usuario/exportar-csv.md` (guía de uso del flujo validado; excluye el escenario
  en disputa de QA-003-01).

### Ciclo de agentes (trazabilidad)
- `qa-tester`: veredicto `con-hallazgos (R-01, 2026-09-14)`. No aprueba mientras QA-003-01
  (contrato) no tenga write-back del analista. `auditor-seguridad`: sigue `pendiente`; no
  corresponde invocarlo todavía (QA no ha aprobado).

## [AAAA-MM-DD] — Origen: (GitHub|Interno) — Título del cambio
- **Usuario:** (correo/identificador)
- **Modelo IA:** (ej. claude-opus-4-8 coordinadora + claude-sonnet-4-6 dev/QA)
- **Agente(s):** (analista-requerimientos | desarrollador | qa-tester | auditor-seguridad | coordinadora)

### Cambios
- (detalle de lo que se hizo)

### Ciclo de agentes (trazabilidad)
- (qué hizo cada agente; veredicto de QA y seguridad)
