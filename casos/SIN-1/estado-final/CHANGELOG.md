# CHANGELOG — {{NOMBRE_PROYECTO}}

> Bitácora de cambios del proyecto. Cada entrada registra: fecha, **Origen**, usuario, modelo de IA, agente(s) y detalle.
>
> **Origen:**
> - `GitHub` → generado en un commit; el cambio está respaldado en el repo remoto.
> - `Interno` → disparado manualmente; control interno, aún sin commit.
>
> Regla: todo commit debe actualizar este archivo (lo exige el hook `pre-commit`).

---

## [2026-09-14] — Origen: Interno — REQ-001 CA-02 alineado con ADR-001 (años bisiestos)
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5 coordinadora + analista-requerimientos y qa-tester
- **Agente(s):** analista-requerimientos, qa-tester (coordinadora: orquestación y registro)

### Cambios
- `requirements/REQ-001.md` — `CA-02` decía «el 29 de febrero se rechaza siempre, porque no se
  consideran años bisiestos», lo que **contradecía** a `docs/decisions/ADR-001.md` (aceptado
  2026-08-20) y a lo ya implementado en `src/fecha.js`. Hallazgo de clase `contrato` (el
  requerimiento decía algo falso sobre lo construido). Se reescribió `CA-02` enunciando la
  **propiedad de pertenencia** al conjunto de años bisiestos y citando su **sitio único**
  (`esBisiesto` en `src/fecha.js`), con ejemplos marcados como no exhaustivos y enlace a `ADR-001`.
- `requirements/REQ-001.md` — cabecera: `Estado: completado` → `en-revisión` → `completado`, y
  `QA: aprobado (2026-08-15)` → `pendiente` → `aprobado (2026-09-14)`. El veredicto viejo juzgaba
  el criterio viejo, así que el REQ **re-recorrió el ciclo** (AGENTS.md §9, regla de estado).
- `requirements/REQ-001.md` — entrada nueva en `## Historial de cambios` (antes → después + causa).
- `docs/qa/REQ-001.md` — log de QA nuevo con la evidencia de la re-validación.
- **Sin cambios en `src/`**: el código ya cumplía la decisión; lo que estaba mal era el contrato.
- **Sin ADR nuevo**: la decisión de fondo ya estaba registrada en `ADR-001`; este cambio sólo la
  refleja en el requerimiento.

### Ciclo de agentes (trazabilidad)
- `analista-requerimientos` — write-back de `CA-02` + Historial; reabrió el REQ a `en-revisión`.
- `qa-tester` — re-validó CA-01 y CA-02 contra `src/fecha.js` (29-feb en bisiesto y en no bisiesto,
  más bordes 1600/1800/2100/2400); veredicto **`QA: aprobado (2026-09-14)`**; marcó `completado`.
  `Seguridad: n/a` (Rigor `estandar`, no sensible: QA es la última puerta).
- **Limitación declarada:** la sesión de QA **no tuvo `Bash`**, así que la verificación fue
  **manual determinista** (traza a mano de las 4 líneas de aritmética pura de `src/fecha.js`) y la
  quality gate del manifiesto (`true`) **no se ejecutó**. No es evidencia de ejecución real; queda
  como deuda de clase `instrumento` en `docs/qa/REQ-001.md`.

## [AAAA-MM-DD] — Origen: (GitHub|Interno) — Título del cambio
- **Usuario:** (correo/identificador)
- **Modelo IA:** (ej. claude-opus-4-8 coordinadora + claude-sonnet-4-6 dev/QA)
- **Agente(s):** (analista-requerimientos | desarrollador | qa-tester | auditor-seguridad | coordinadora)

### Cambios
- (detalle de lo que se hizo)

### Ciclo de agentes (trazabilidad)
- (qué hizo cada agente; veredicto de QA y seguridad)
