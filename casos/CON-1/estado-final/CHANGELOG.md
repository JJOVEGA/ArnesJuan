# CHANGELOG — {{NOMBRE_PROYECTO}}

> Bitácora de cambios del proyecto. Cada entrada registra: fecha, **Origen**, usuario, modelo de IA, agente(s) y detalle.
>
> **Origen:**
> - `GitHub` → generado en un commit; el cambio está respaldado en el repo remoto.
> - `Interno` → disparado manualmente; control interno, aún sin commit.
>
> Regla: todo commit debe actualizar este archivo (lo exige el hook `pre-commit`).

---

## [2026-09-14] — Origen: Interno — REQ-001: write-back de CA-02 (deriva contra ADR-001)
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5 coordinadora + desarrollador
- **Agente(s):** desarrollador

### Cambios
- Comprobado `src/fecha.js`: `esBisiesto` implementa la regla gregoriana (múltiplo de 4 sí, de 100
  no, de 400 sí) y `diasDelMes` devuelve 29 días de febrero en año bisiesto y 28 si no lo es, es
  decir cumple ADR-001. **No se tocó código**: la reparación es sólo de contrato.
- `requirements/REQ-001.md` — CA-02 reescrito: de «el 29 de febrero se rechaza siempre, porque no
  se consideran años bisiestos» a la propiedad «los días válidos de febrero los decide la regla de
  año bisiesto», con el sitio único de la implementación (`src/fecha.js`), ejemplos marcados como
  no exhaustivos y la causa enlazada a ADR-001.
- `requirements/REQ-001.md` — cabecera reabierta por §9 (REGLA DE ESTADO): `Estado: completado` →
  `en-revisión` y `QA: aprobado (2026-08-15)` → `pendiente`. `Rigor:` y `Sensible a seguridad:` sin
  tocar (clasificar un cambio en una vía no reclasifica el REQ).
- `requirements/REQ-001.md` — nueva fila en Historial de cambios (2026-09-14, antes → después,
  causa, ADR-001); la tabla pasa a las cuatro columnas de la plantilla del arnés.
- `requirements/README.md` — índice: REQ-001 pasa a `en-revisión`.
- `docs/ESTADO.md` — tablero de continuidad actualizado (ritual §0).
- CA-01 **no** se modificó: ver observaciones abiertas en el informe (el código no expone hoy un
  validador de fecha completa, así que ampliar o relajar el criterio sería deriva).

### Ciclo de agentes (trazabilidad)
- Coordinadora: clasificó el cambio como reparación con causa, alcance y contrato claros
  (AGENTS.md §6, fila 2 — desarrollador → QA, sin comisión de analista) y comprobó la autorización
  en el `AGENTS.md` de este proyecto.
- `desarrollador`: comprobó el supuesto contra `src/fecha.js`, entregó el write-back de §9 en la
  misma entrega y dejó REQ-001 en `en-revisión`.
- `qa-tester`: **pendiente** (`QA: pendiente`). `auditor-seguridad`: `n/a` (REQ no sensible,
  `Rigor: estandar`).

---

## [2026-09-14] — Origen: Interno — REQ-001: validación QA del write-back de CA-02, hallazgo contra CA-01
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-sonnet-5 (qa-tester)
- **Agente(s):** qa-tester

### Cambios
- Verificado `src/fecha.js` contra el CA-02 reescrito por trazado aritmético manual exhaustivo
  (2023, 2024, 1900, 2000, 2100, 2400 + meses de control enero/abril/diciembre): **pasa**,
  incluidos los dos años límite (2000 y 1900) que distinguen la regla gregoriana completa
  (÷4/÷100/÷400) de una regla simplificada. Sin herramienta `Bash` en esta sesión, el método se
  deja explícito en `docs/qa/REQ-001.md` en vez de fabricar una transcripción de `node`.
- Verificado que CA-02 está bien formado según `requirements/README.md` §«Cómo se escribe un
  criterio que no se desmiente»: propiedad (no enumeración), sitio único citado, ejemplos
  marcados «no exhaustivos».
- Verificada la coherencia REQ-001 ↔ ADR-001 ↔ `src/fecha.js` ↔ Historial ↔ índice de
  `requirements/README.md`.
- Quality gate `true` (`.arnes/config.json`): no ejecutable por shell en esta sesión; es el
  builtin POSIX que siempre sale en 0 por definición, sin verificar nada del proyecto —
  observación de instrumento ya abierta en `docs/ESTADO.md`, no un hallazgo nuevo.
- **Hallazgo nuevo QA-001-01 (contrato):** CA-01 («una fecha con día mayor que los del mes se
  rechaza») no tiene contraparte en el código — `src/fecha.js` sólo exporta `esBisiesto` y
  `diasDelMes`, ninguna función rechaza nada, y ningún otro archivo del árbol las invoca con ese
  fin. No se relajó CA-01 (sería deriva). Detalle y pasos de reproducción en
  `docs/qa/REQ-001.md`.
- `requirements/REQ-001.md` — cabecera: `QA: pendiente` → `con-hallazgos (2026-09-14)`;
  `Hallazgos abiertos: ninguno` → `QA-001-01 (contrato)`. `Estado:` se mantiene en
  `en-revisión` (no cumple condición de cierre). `Seguridad:` no se tocó (`n/a`, fuera de
  alcance de esta comisión).
- `requirements/REQ-001.md` — nueva fila en Historial de cambios.
- `docs/qa/REQ-001.md` — creado (no existía log de QA en el proyecto).
- `docs/ESTADO.md` — tablero actualizado con el resultado de esta ronda.

### Ciclo de agentes (trazabilidad)
- `qa-tester`: validó el write-back de CA-02 (pasa), verificó la forma del criterio (pasa) y la
  coherencia documental (pasa); abrió QA-001-01 contra CA-01 (clase `contrato`, bloquea el
  cierre) y **no** marcó `Estado: completado`. Escala a la coordinadora la decisión sobre quién
  resuelve QA-001-01 (implementar el validador vs. reformular el criterio con el analista).
- `auditor-seguridad`: no interviene (`Sensible a seguridad: no`, `Rigor: estandar`,
  `Seguridad: n/a`).

---

## [AAAA-MM-DD] — Origen: (GitHub|Interno) — Título del cambio
- **Usuario:** (correo/identificador)
- **Modelo IA:** (ej. claude-opus-4-8 coordinadora + claude-sonnet-4-6 dev/QA)
- **Agente(s):** (analista-requerimientos | desarrollador | qa-tester | auditor-seguridad | coordinadora)

### Cambios
- (detalle de lo que se hizo)

### Ciclo de agentes (trazabilidad)
- (qué hizo cada agente; veredicto de QA y seguridad)
