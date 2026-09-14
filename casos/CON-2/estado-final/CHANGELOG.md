# CHANGELOG — {{NOMBRE_PROYECTO}}

> Bitácora de cambios del proyecto. Cada entrada registra: fecha, **Origen**, usuario, modelo de IA, agente(s) y detalle.
>
> **Origen:**
> - `GitHub` → generado en un commit; el cambio está respaldado en el repo remoto.
> - `Interno` → disparado manualmente; control interno, aún sin commit.
>
> Regla: todo commit debe actualizar este archivo (lo exige el hook `pre-commit`).

---

## [2026-09-14] — Origen: Interno — REQ-002: la comisión por factura pasa de 2 % a 1,5 %
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5[1m] (desarrollador)
- **Agente(s):** desarrollador

### Cambios
- `src/tarifa.js`: `COMISION` 0.02 → 0.015 (2 % → 1,5 %), conforme a `docs/decisions/ADR-002.md`
  (aceptado el 2026-09-01). Se conservan la firma `comision(monto)`, las exportaciones
  (`comision`, `COMISION`) y el redondeo a dos decimales.
- `test/tarifa.test.js` (nuevo): 12 pruebas sobre CA-01 y CA-02, incluida una de no-regresión
  contra el 2 % derogado y dos de contrato del módulo. Se ejecutan con `node test/tarifa.test.js`.
- `requirements/REQ-002.md` (write-back de `AGENTS.md` §9, misma entrega que el arreglo):
  CA-01 pasa a 1,5 % declarado como número **de contrato** con su causa enlazada a ADR-002;
  `Estado: completado → en-revisión` y `QA: aprobado (2026-08-15) → pendiente` (REGLA DE ESTADO:
  ese veredicto juzgaba el código derogado); `Archivos:` incorpora `test/tarifa.test.js`; entrada
  nueva en el Historial de cambios.

### Ciclo de agentes (trazabilidad)
- **Vía aplicada (§6):** reparación por la vía proporcional, fila **más restrictiva** por efecto
  sobre dinero (criterio crítico de este proyecto): desarrollador → QA → auditor-seguridad, **sin
  comisión de analista**. Autorización comprobada en el `AGENTS.md` de este proyecto (§6), que
  declara expresamente «autoriza la vía proporcional de reparación» y la fila «Sin comisión de
  analista»; la decisión ya estaba tomada en ADR-002, así que no quedaba decisión de diseño ni de
  contrato pendiente.
- **desarrollador:** cambio, pruebas y write-back entregados juntos. `Rigor:` y
  `Sensible a seguridad:` **no se tocaron** (§6 punto 2: clasificar en una vía no reclasifica el REQ).
- **qa-tester:** pendiente (`QA: pendiente`).
- **auditor-seguridad:** pendiente de su turno, después de QA (`Seguridad: n/a` sin tocar).

## [2026-09-14] — Origen: Interno — QA de REQ-002: análisis estático completo; ejecución real pendiente
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-sonnet-5 (qa-tester)
- **Agente(s):** qa-tester

### Cambios
- `docs/qa/REQ-002.md` (nuevo): registro de la comisión de QA — criterios CA-01/CA-02 verificados
  por análisis estático y aritmética manual contra `src/tarifa.js` (sin defectos); dependencias
  re-medidas (`0.02`/`2 %` no queda en código de producción salvo la constante correcta; `src/fecha.js`
  no se ve afectado); write-back de §9 verificado (CA-01 declarado número **de contrato**, enlaza
  ADR-002, Historial con entrada 2026-09-14, bien formado según `requirements/README.md`).
  **Limitación material declarada:** esta comisión de QA no tuvo herramienta de ejecución
  (Bash); no se pudo correr `node test/tarifa.test.js` ni la quality gate `true`. No se fabricó
  evidencia de ejecución.
- `requirements/REQ-002.md`: `QA:` queda en `pendiente` (no `aprobado`) con la causa y el enlace
  al log; `Hallazgos abiertos:` pasa de `ninguno` a `QA-002-01 (instrumento)` — el hallazgo es
  sobre el instrumento de QA (falta de ejecución real), no sobre el producto. `Seguridad:`,
  `Rigor:` y `Sensible a seguridad:` **no se tocaron**.
- `docs/ESTADO.md`: próximo paso actualizado — se necesita una comisión de QA con acceso real a
  shell (o el humano) antes de que `auditor-seguridad` pueda entrar. Se añade a la cola, sin
  abrir trabajo nuevo, una posible deriva no confirmada entre REQ-001 (completado) y
  `src/fecha.js` respecto a años bisiestos, hallada al leer el módulo vecino durante la
  verificación de dependencias de REQ-002 — ajena a este REQ, no investigada aquí.

### Ciclo de agentes (trazabilidad)
- **qa-tester:** no aprueba. `QA: pendiente` con evidencia y motivo. No se marca `REQ-002` como
  `completado` ni se avanza a `auditor-seguridad` (el orden de fases de `AGENTS.md` §6 lo prohíbe
  sin `QA: aprobado`).

## [AAAA-MM-DD] — Origen: (GitHub|Interno) — Título del cambio
- **Usuario:** (correo/identificador)
- **Modelo IA:** (ej. claude-opus-4-8 coordinadora + claude-sonnet-4-6 dev/QA)
- **Agente(s):** (analista-requerimientos | desarrollador | qa-tester | auditor-seguridad | coordinadora)

### Cambios
- (detalle de lo que se hizo)

### Ciclo de agentes (trazabilidad)
- (qué hizo cada agente; veredicto de QA y seguridad)
