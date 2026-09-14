# CHANGELOG — {{NOMBRE_PROYECTO}}

> Bitácora de cambios del proyecto. Cada entrada registra: fecha, **Origen**, usuario, modelo de IA, agente(s) y detalle.
>
> **Origen:**
> - `GitHub` → generado en un commit; el cambio está respaldado en el repo remoto.
> - `Interno` → disparado manualmente; control interno, aún sin commit.
>
> Regla: todo commit debe actualizar este archivo (lo exige el hook `pre-commit`).

---

## [2026-09-14] — Origen: Interno — REQ-003: exportación del listado mensual a CSV (detenido en gate humano)
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5 coordinadora + claude-opus-5 analista-requerimientos
- **Agente(s):** coordinadora, analista-requerimientos

### Cambios
- Alta de `requirements/REQ-003.md` — exportación del listado mensual de facturas a CSV.
  `Rigor: critico`, `Sensible a seguridad: sí` (toca dinero **y** datos de clientes, AGENTS.md §6).
  Estado `borrador`: quedan preguntas abiertas.
- Alta de `docs/decisions/ADR-003.md` (formato de intercambio del CSV), en `propuesto`.
- Fila de REQ-003 añadida al Índice de `requirements/README.md`.
- 4 entradas nuevas en `PENDING_APPROVAL.md`; pipeline detenido.
- `docs/ESTADO.md` actualizado (fase, en progreso, próximo paso, bloqueos, cola).

### Ciclo de agentes (trazabilidad)
- `analista-requerimientos`: redactó REQ-003 (13 criterios + contrato de entrada, porque en `src/`
  no existe modelo de factura) y ADR-003. Escaló 4 preguntas abiertas.
- `coordinadora`: verificó contra el disco los dos conflictos escalados —`ADR-002` (1,5 % desde
  2026-09-01) contra `REQ-002` CA-01 (2 %) y `src/tarifa.js` (`0.02`); y `REQ-001` CA-02 (rechaza el
  29 de febrero) contra `ADR-001` y `src/fecha.js` (lo aceptan)— y detuvo el pipeline en el gate.
- **No se despachó** `desarrollador`, ni `qa-tester`, ni `auditor-seguridad`: REQ-003 sigue en
  `borrador`. Veredictos: `QA: pendiente`, `Seguridad: pendiente`.

## [AAAA-MM-DD] — Origen: (GitHub|Interno) — Título del cambio
- **Usuario:** (correo/identificador)
- **Modelo IA:** (ej. claude-opus-4-8 coordinadora + claude-sonnet-4-6 dev/QA)
- **Agente(s):** (analista-requerimientos | desarrollador | qa-tester | auditor-seguridad | coordinadora)

### Cambios
- (detalle de lo que se hizo)

### Ciclo de agentes (trazabilidad)
- (qué hizo cada agente; veredicto de QA y seguridad)
