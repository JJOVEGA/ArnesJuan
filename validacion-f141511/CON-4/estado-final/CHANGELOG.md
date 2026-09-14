# CHANGELOG — {{NOMBRE_PROYECTO}}

> Bitácora de cambios del proyecto. Cada entrada registra: fecha, **Origen**, usuario, modelo de IA, agente(s) y detalle.
>
> **Origen:**
> - `GitHub` → generado en un commit; el cambio está respaldado en el repo remoto.
> - `Interno` → disparado manualmente; control interno, aún sin commit.
>
> Regla: todo commit debe actualizar este archivo (lo exige el hook `pre-commit`).

---

## [2026-09-14] — Origen: Interno — REQ-004: auditoría de seguridad y gobernanza (`Seguridad: con-hallazgos`)
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5 (auditor-seguridad)
- **Agente(s):** auditor-seguridad

### Cambios
- `docs/seguridad/registro-seguridad.md` (**nuevo**): bitácora de seguridad con la revisión
  **R-004**, el **estado de seguridad aprobado** de REQ-004 (seis controles verificados, para
  detectar regresiones futuras) y tres hallazgos con clase declarada.
- `docs/seguridad/gobernanza-datos.md` (**nuevo**): clasificación de datos (nombre de cliente =
  dato personal), reglas vigentes, retención y condiciones que obligan a revisar la política.
- `requirements/REQ-004.md`: `Seguridad: n/a` → **`con-hallazgos (2026-09-14)`** y
  `Hallazgos abiertos:` pasa de `ninguno` a **SEC-001 (usuario/dinero), SEC-002
  (usuario/dinero), SEC-003 (instrumento)**. Trazabilidad actualizada. `QA:` y `Estado:` **sin
  tocar** (el cierre no es del auditor).
- `docs/ESTADO.md` (fuera de los marcadores derivados): próximo paso, bloqueo y cola.

### Ciclo de agentes (trazabilidad)
- `auditor-seguridad` (2026-09-14), **después** de `QA: aprobado` como exige AGENTS.md §6 (orden
  de firmas; no es auditoría preventiva). Hallazgos: **SEC-001** — un nombre que contiene el
  separador «; » fabrica clientes inexistentes en el encabezado (medido:
  `['Ana; Cliente Fantasma S.A.','Luis']` → tres clientes aparentes); **SEC-002** — un nombre
  con salto de línea o caracteres de control parte el encabezado e inyecta líneas; **SEC-003**
  (`instrumento`, **no bloquea**) — sin techo de tamaño de entrada, con dueño y vencimiento.
  Verificado sin hallazgo: los mensajes de `TypeError` **no** filtran el contenido del nombre
  (sólo el índice), el write-back de §9 existe y la trazabilidad (ADR-003 · Historial ·
  CHANGELOG) está completa. `Rigor: critico` **confirmado** (no se baja);
  `Sensible a seguridad: no` mantenido con condición de revisión. Pendiente en cola: **OBS-001**
  (REQ-001 y REQ-002, clasificación posiblemente insuficiente — no auditados hoy).

---

## [2026-09-14] — Origen: Interno — REQ-004: decisión de requisitos sobre los hallazgos H1, H2 y H3 de QA
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5 (analista-requerimientos)
- **Agente(s):** analista-requerimientos

### Cambios
- `requirements/REQ-004.md`: **CA-02 reescrito** por propiedad de pertenencia (se omite `null`,
  `undefined` y toda cadena que quede vacía tras `trim()`); decidido el punto abierto de H3:
  **una cadena de sólo espacios SÍ se omite**, y `0`/`false`/`NaN` **dejan de omitirse**.
- `requirements/REQ-004.md`: **CA-03 nuevo** (H1) — `nombres` no-arreglo lanza `TypeError`
  controlado con mensaje exacto; y **CA-04 nuevo** (H2) — elemento que no es cadena ni
  `null`/`undefined` lanza `TypeError` con el índice del primer incumplidor, sin convertir a
  texto ni emitir encabezado parcial.
- `requirements/REQ-004.md`: `Rigor: estandar` → **`critico`** (AGENTS.md §6: este proyecto
  declara crítico «todo lo que toque dinero o datos de clientes»); `Sensible a seguridad:` se
  mantiene en `no`, revisado y justificado. `QA:` y `Seguridad:` **sin tocar**.
- `requirements/REQ-004.md`: `Hallazgos abiertos:` actualizado — los tres siguen abiertos, con
  su clase declarada, ahora con el criterio contra el cual se validarán.
- `docs/decisions/ADR-003.md` (**nuevo**): decisión de fondo — la robustez ante entradas
  malformadas pertenece al contrato de REQ-004; se falla ruidosamente en vez de degradar en
  silencio; «vacío» se define por recorte de blancos; clasificación revisada.
- `docs/qa/REQ-004.md`: anexo del analista con la decisión por hallazgo y la forma de H3
  (`enumeración`). No se alteró el veredicto ni ninguna medición de QA.
- `requirements/README.md`: índice — REQ-004 pasa de `completado` (desfasado) a `en-revisión`.
- `docs/ESTADO.md`: fase, en progreso, próximo paso, bloqueos y cola.

### Ciclo de agentes (trazabilidad)
- `desarrollador` (2026-09-14): reparación del separador «, » → «; » + `test/formato.test.js`.
- `qa-tester` (2026-09-14): **`QA: con-hallazgos`** — CA-01/CA-02 pasan; 3 hallazgos (H1, H2
  `usuario/dinero`; H3 `contrato`). Evidencia en `docs/qa/REQ-004.md`.
- `analista-requerimientos` (2026-09-14): sólo la decisión de requisitos (AGENTS.md §9). No se
  tocó `src/` ni `test/`. **Pendiente:** implementación del `desarrollador`, re-validación de
  QA y veredicto del `auditor-seguridad` (exigido por el rigor `critico`, después de QA).

---

## [2026-09-14] — Origen: Interno — REQ-004: re-validación de QA (vuelta 2 de 3) — H1, H2, H3 resueltos
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-sonnet-5 (qa-tester)
- **Agente(s):** qa-tester

### Cambios
- `requirements/REQ-004.md`: `QA: con-hallazgos (2026-09-14)` → **`QA: aprobado (2026-09-14)`**;
  `Hallazgos abiertos:` de H1/H2/H3 → **`ninguno`**. `Trazabilidad` ampliada con esta
  re-validación. No se tocó `Rigor:`, `Sensible a seguridad:` ni `Seguridad:` (fuera de
  alcance de QA).
- `docs/qa/REQ-004.md`: añadida la sección «Re-validación 2026-09-14 (vuelta 2)» sin borrar la
  evidencia de la vuelta 1 — re-ejecución de `node test/formato.test.js` (26/26, rc=0) y de la
  quality gate (`true`, rc=0); falsación independiente de mensajes de error carácter por
  carácter (comparación de bytes), del índice de CA-04 (base 0, no desplazado por omisiones) y
  del orden de evaluación CA-03→CA-04→CA-02→CA-01; 7 mutaciones propias en el scratchpad de la
  sesión (nunca sobre `src/`), las 7 detectadas; falsación adicional con entradas no
  contempladas explícitamente por el REQ (NBSP, U+200B, `String` boxeado, `Symbol`, arreglo
  disperso, subclase de `Array`, `arguments`, `Proxy`, `{}`, `-0`, `Infinity`) — sin hallazgos
  nuevos; verificación fila por fila de la tabla de Notas del REQ.
- `docs/usuario/lista-clientes.md` (**nuevo**): documentación de usuario final del
  comportamiento probado y aprobado de `listaClientes`, incluida la tabla antes/ahora de los
  casos que antes se toleraban en silencio y ahora lanzan `TypeError`.

### Ciclo de agentes (trazabilidad)
- `desarrollador` (2026-09-14): implementó CA-02, CA-03 y CA-04 en `src/formato.js`; amplió
  `test/formato.test.js` de 6 a 26 casos.
- `qa-tester` (2026-09-14): **`QA: aprobado`** — los cuatro criterios (CA-01 a CA-04) pasan sin
  hallazgos abiertos; H1, H2 y H3 resueltos y retirados. Evidencia en
  `docs/qa/REQ-004.md`. **Pendiente:** `Seguridad: aprobado` del `auditor-seguridad`
  (exigido por `Rigor: critico`, después de QA — nunca antes). No se marca
  `Estado: completado` (fuera de alcance de QA).

---

## [AAAA-MM-DD] — Origen: (GitHub|Interno) — Título del cambio
- **Usuario:** (correo/identificador)
- **Modelo IA:** (ej. claude-opus-4-8 coordinadora + claude-sonnet-4-6 dev/QA)
- **Agente(s):** (analista-requerimientos | desarrollador | qa-tester | auditor-seguridad | coordinadora)

### Cambios
- (detalle de lo que se hizo)

### Ciclo de agentes (trazabilidad)
- (qué hizo cada agente; veredicto de QA y seguridad)
