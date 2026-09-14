# CHANGELOG — {{NOMBRE_PROYECTO}}

> Bitácora de cambios del proyecto. Cada entrada registra: fecha, **Origen**, usuario, modelo de IA, agente(s) y detalle.
>
> **Origen:**
> - `GitHub` → generado en un commit; el cambio está respaldado en el repo remoto.
> - `Interno` → disparado manualmente; control interno, aún sin commit.
>
> Regla: todo commit debe actualizar este archivo (lo exige el hook `pre-commit`).

---

## [2026-09-14] — Origen: Interno — La comisión por factura baja de 2 % a 1,5 % (ADR-002)
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5 coordinadora + analista/desarrollador/qa-tester
- **Agente(s):** coordinadora, analista-requerimientos, desarrollador, qa-tester

### Cambios
- `src/tarifa.js`: `COMISION` pasa de `0.02` a `0.015`. Interfaz pública (`comision`,
  `COMISION`) y redondeo sin cambios.
- `test/tarifa.test.js` (nuevo): pruebas de CA-01 y CA-02 con el runner nativo de Node
  (`node --test test/tarifa.test.js`).
- `requirements/REQ-002.md`: write-back de ADR-002. CA-01 pasa de 2 % a 1,5 %, declarado como
  número **de contrato** y con vigencia desde el 2026-09-01. El REQ estaba `completado` y
  re-recorre el ciclo (AGENTS.md §9). `Rigor:` sube de `estandar` a `critico` —la comisión es
  dinero, criterio de §6—, `Seguridad:` pasa de `n/a` a `pendiente`.
- `docs/qa/REQ-002.md` (nuevo): log de hallazgos de QA.
- `PENDING_APPROVAL.md`: tres decisiones escaladas al humano; pipeline detenido.

### Ciclo de agentes (trazabilidad)
- `analista-requerimientos`: write-back de ADR-002 en REQ-002, subida de rigor a `critico`,
  y supuesto de alcance (A) —tasa única, sin parametrizar por fecha— declarado explícito.
- `desarrollador`: cambio de tasa y pruebas. **Sin shell en su sesión: no ejecutó nada.**
- `qa-tester`: **tampoco tuvo shell.** Validó por análisis estático y aritmético. Veredicto
  `QA: con-hallazgos (2026-09-14)` con tres hallazgos: QA-002-01 (`instrumento`, ninguna
  ejecución real de las pruebas), QA-002-02 (`usuario/dinero`, CA-02 no contrata la regla de
  desempate del redondeo, que el 1,5 % introduce para todo monto entero impar) y QA-002-03
  (`contrato`, montos inválidos/negativos sin contratar).
- `auditor-seguridad`: **no invocado.** Su firma exige `QA: aprobado` previo (AGENTS.md §6):
  firmar sobre un árbol con hallazgos abiertos sería acreditar algo que nadie validó.
- **Estado:** REQ-002 queda `bloqueado` a la espera de decisión humana. No cerró.

## [AAAA-MM-DD] — Origen: (GitHub|Interno) — Título del cambio
- **Usuario:** (correo/identificador)
- **Modelo IA:** (ej. claude-opus-4-8 coordinadora + claude-sonnet-4-6 dev/QA)
- **Agente(s):** (analista-requerimientos | desarrollador | qa-tester | auditor-seguridad | coordinadora)

### Cambios
- (detalle de lo que se hizo)

### Ciclo de agentes (trazabilidad)
- (qué hizo cada agente; veredicto de QA y seguridad)
