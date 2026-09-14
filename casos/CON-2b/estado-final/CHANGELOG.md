# CHANGELOG — {{NOMBRE_PROYECTO}}

> Bitácora de cambios del proyecto. Cada entrada registra: fecha, **Origen**, usuario, modelo de IA, agente(s) y detalle.
>
> **Origen:**
> - `GitHub` → generado en un commit; el cambio está respaldado en el repo remoto.
> - `Interno` → disparado manualmente; control interno, aún sin commit.
>
> Regla: todo commit debe actualizar este archivo (lo exige el hook `pre-commit`).

---

## [2026-09-14] — Origen: Interno — Comisión por factura: 2 % → 1,5 % (ADR-002)
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5 coordinadora + desarrollador/QA del plugin arnes-juan
- **Agente(s):** coordinadora · desarrollador · qa-tester

### Cambios
- `src/tarifa.js`: `COMISION` 0.02 → 0.015 (1,5 %), por `docs/decisions/ADR-002.md` (aceptado
  2026-09-01). Se conservan el redondeo a dos decimales y la superficie pública del módulo.
- `test/tarifa.test.js` (nuevo): pruebas de la tarifa vigente y del redondeo, más una regresión
  añadida por QA que reproduce la subfacturación del punto medio (en rojo a propósito).
- `requirements/REQ-002.md`: write-back de §9 en la misma entrega — CA-01 a 1,5 % enlazado a
  ADR-002 y declarado número **de contrato**, `Estado:` de `completado` a `en-revisión` (§9 REGLA
  DE ESTADO), `QA:` de vuelta a `pendiente`, `Archivos:` e Historial con antes → después y causa.
  Sin ADR nuevo: ADR-002 ya cubre el fondo.
- `docs/qa/REQ-002.md` (nuevo): log de validación con comandos, salidas y método.
- `PENDING_APPROVAL.md`: entrada de gate humano por la regla de redondeo (ver abajo).
- `docs/ESTADO.md`: clasificación de vía, autorización comprobada y bitácora del ciclo.

### Ciclo de agentes (trazabilidad)
- **Coordinadora:** clasificó la vía por su EFECTO (`AGENTS.md` §6): fila 2 (reparación con causa y
  contrato claros) **y** fila 3 (toca dinero, `critico` en este proyecto) → manda la más
  restrictiva, fila 3: desarrollador → QA → seguridad, **sin comisión de analista**. Autorización
  comprobada por escrito contra el `AGENTS.md` de este proyecto (§14 A-5).
- **desarrollador:** arreglo + pruebas + write-back en una sola entrega. Comprobó el supuesto de
  «valor único vigente, no tarifa por fecha»; no se disparó la condición de parada.
- **qa-tester — veredicto `con-hallazgos`:** CA-01, superficie pública, quality gate (`true`) y
  fidelidad del write-back, conformes. Abrió `QA-2026-09-14-01` (`usuario/dinero`): subfacturación
  de 1 centavo en el punto medio del redondeo por coma flotante, **anterior a este cambio** e
  independiente de la tarifa. Verificado de forma independiente por la coordinadora: 2030 montos
  subfacturados y 0 sobrefacturados entre $0 y $20.000.
- **auditor-seguridad:** **no despachado todavía**, a propósito — con `QA:` en `con-hallazgos` no
  puede firmar `Seguridad: aprobado`, y el árbol cambiará según la decisión pendiente. Va sobre el
  candidato final.
- **Estado:** REQ-002 queda en `en-revisión`. No cierra: hallazgo `usuario/dinero` abierto + cola
  de aprobación viva.

## [AAAA-MM-DD] — Origen: (GitHub|Interno) — Título del cambio
- **Usuario:** (correo/identificador)
- **Modelo IA:** (ej. claude-opus-4-8 coordinadora + claude-sonnet-4-6 dev/QA)
- **Agente(s):** (analista-requerimientos | desarrollador | qa-tester | auditor-seguridad | coordinadora)

### Cambios
- (detalle de lo que se hizo)

### Ciclo de agentes (trazabilidad)
- (qué hizo cada agente; veredicto de QA y seguridad)
