# CHANGELOG — {{NOMBRE_PROYECTO}}

> Bitácora de cambios del proyecto. Cada entrada registra: fecha, **Origen**, usuario, modelo de IA, agente(s) y detalle.
>
> **Origen:**
> - `GitHub` → generado en un commit; el cambio está respaldado en el repo remoto.
> - `Interno` → disparado manualmente; control interno, aún sin commit.
>
> Regla: todo commit debe actualizar este archivo (lo exige el hook `pre-commit`).

---

## [2026-09-14] — Origen: Interno — REQ-001: verificación de la regla de fecha de corte y primer banco de pruebas
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5[1m]
- **Agente(s):** desarrollador

### Cambios
- **Verificado por ejecución** que `src/fecha.js` cumple CA-01 y CA-02 tal como el analista los
  reescribió: `esBisiesto(a)` coincide con la propiedad gregoriana y `diasDelMes(2, a)` devuelve 29
  exactamente cuando `esBisiesto(a)` y 28 en el resto (años 1–3000); la tabla de los 12 meses
  coincide con un oráculo independiente (`Date.UTC(a, m, 0)`). **No se cambió el código:** cumple.
- **Nuevo `test/fecha.test.js`** — primer banco de pruebas del proyecto. Runner nativo `node --test`
  y CommonJS (stack: JavaScript sin framework). 8 pruebas, 8 en verde. Fuera de `src/` a propósito:
  `.arnes/config.json` declara `codigo_app.globs: ["src/*"]` y los tests quedan fuera para que el
  `qa-tester` pueda editarlos. Se comprobó que las pruebas no son vacías: tres mutantes del código
  (29-feb siempre rechazado, regla gregoriana sin la excepción del 400, septiembre con 31 días) las
  hacen fallar.
- **REQ-001:** `Estado: en-progreso` → `en-revisión`; `Archivos:` incorpora `test/fecha.test.js`
  (ruta sin decoración de Markdown, por SEC-020); entrada nueva en el Historial de cambios.
- `docs/ESTADO.md` actualizado (fase, próximo paso y cola).

### Ciclo de agentes (trazabilidad)
- `analista-requerimientos` (previo): reescribió CA-01/CA-02 contra ADR-001, subió a `Rigor: critico`
  y reabrió el REQ.
- `desarrollador`: verificación, pruebas y cierre de su fase. **No** escribió `QA:` ni `Seguridad:`
  ni marcó `completado` — no son suyos y el orden de firmas de `AGENTS.md` §6 es condición de
  validez de esas firmas.
- **Observación elevada al analista (no resuelta aquí):** `src/fecha.js` no expone ninguna función
  que ejecute el rechazo/aceptación que CA-01 y CA-02 enuncian; hoy esa comparación vive en la
  prueba. Decidirlo es alcance/diseño.
- `qa-tester`: pendiente. `auditor-seguridad`: pendiente (exigido por `Rigor: critico`).

## [2026-09-14] — Origen: Interno — REQ-001: validación de QA, hallazgo QA-001-01 (contrato)
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-sonnet-5
- **Agente(s):** qa-tester

### Cambios
- **Validación independiente:** corrida propia de la quality gate declarada (`true`, exit 0) y de
  `node --test test/fecha.test.js` (8/8 en verde, repetido 3 veces sin variación de resultado —
  no flaky).
- **Supuesto verificado en copia aislada** (scratchpad, sin tocar `src/` del proyecto): mutado
  `esBisiesto` para (1) rechazar siempre el 29 de febrero y (2) omitir la excepción del siglo en la
  regla gregoriana. Ambos mutantes hacen fallar el banco (3 pruebas cada uno): confirma que
  `test/fecha.test.js` no es vacuo.
- **Casos de ruptura adicionales** (día 0/negativo, mes 0/13/decimal, año no entero/string/
  negativo/`NaN`/`undefined`) ejercitados contra el código real: comportamiento consistente con la
  ausencia de contrato sobre esos dominios; **no** se abren como hallazgo porque el propio REQ
  (`Notas / alcance`) ya los declara fuera de esta revisión.
- **Juicio sobre la observación elevada por el desarrollador:** declarado hallazgo **QA-001-01**,
  clase `contrato` — CA-01/CA-02 afirman con verbo de comportamiento que el sistema valida y
  rechaza/acepta una fecha de corte; `src/fecha.js` sólo expone las dos primitivas de calendario
  (`esBisiesto`, `diasDelMes`); la composición accept/reject vive sólo en código de prueba, que
  declara explícitamente no ser producción. No es `usuario/dinero` (no existe hoy módulo de
  facturación que consuma esta validación) ni `instrumento` (el defecto no está en el arnés).
  Bloquea el cierre hasta el write-back del `analista-requerimientos` (decisión de diseño/contrato
  pendiente, `AGENTS.md` §6/§9).
- **REQ-001:** `Estado: en-revisión` → `en-progreso`; `QA: pendiente` → `QA: con-hallazgos
  (QA-001-01, 2026-09-14)`; `Hallazgos abiertos: ninguno` → `QA-001-01 (contrato)`. No se tocó
  `Seguridad:` (no corresponde a esta comisión) ni se marcó `completado`.
- Nuevo `docs/qa/REQ-001.md` (log de QA con reproducción completa, evidencia y razonamiento).
- `docs/ESTADO.md` actualizado (próximo paso: despachar `analista-requerimientos`).

### Ciclo de agentes (trazabilidad)
- `qa-tester`: validación independiente + juicio sobre la observación del desarrollador. Veredicto
  emitido: `QA: con-hallazgos (QA-001-01, 2026-09-14)`. **No** escribió `Seguridad:` ni marcó
  `completado` — no son suyos.
- Próximo: `analista-requerimientos` (resolver QA-001-01), y sólo después una nueva ronda de
  `qa-tester` + `auditor-seguridad` (exigido por `Rigor: critico`).

## [2026-09-14] — Origen: Interno — REQ-001: write-back de ADR-001 en el contrato y reclasificación a `critico`

- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5 coordinadora + claude-opus-5 analista-requerimientos
- **Agente(s):** analista-requerimientos (ejecución) · coordinadora (esta entrada)

### Cambios
- **Deriva cerrada (`AGENTS.md` §9).** `REQ-001` CA-02 decía «El 29 de febrero se rechaza siempre,
  porque no se consideran años bisiestos», mientras `docs/decisions/ADR-001.md` (aceptado
  2026-08-20) había decidido lo contrario y `src/fecha.js` ya lo implementaba. El requerimiento
  decía algo falso sobre lo construido; se corrigió **el requerimiento**, no el código.
- CA-02 reescrito: el 29 de febrero se **acepta** en años bisiestos, enunciado por **propiedad**
  (regla gregoriana) con puntero al **sitio único** (`esBisiesto(a)` en `src/fecha.js`) y ejemplos
  marcados como no exhaustivos, según `requirements/README.md` §«Cómo se escribe un criterio que
  no se desmiente». CA-01 reenunciado por coherencia (los días de febrero dependen del año).
- **Reclasificación:** `Rigor: estandar` → `critico` y `Seguridad: n/a` → `pendiente`. Motivo: el
  efecto del REQ **toca dinero** (la fecha de corte decide qué periodo se factura), que es el
  criterio de `critico` declarado en `AGENTS.md` §6 para este proyecto. La cabecera anterior
  prometía menos revisión de la que el efecto exige — el «contrato no claro» de §6.
  `Sensible a seguridad: no` se mantuvo, razonado en las Notas del REQ.
- **Estado:** `completado` → `en-progreso` y `QA: aprobado (2026-08-15)` → `pendiente`
  (`AGENTS.md` §9, REGLA DE ESTADO: un REQ cerrado cuyo contrato cambia re-recorre el ciclo; la
  firma anterior juzgaba el CA-02 que decía lo contrario de lo construido).
- No se creó ADR nuevo: ADR-001 ya documenta esta decisión de fondo y el REQ la **enlaza**.
- Índice de `requirements/README.md` sincronizado con el estado real del REQ.

### Ciclo de agentes (trazabilidad)
- `analista-requerimientos`: resolvió la clasificación que §6 exigía y transcribió ADR-001 al
  contrato. No tocó `src/` ni emitió veredictos.
- Vía aplicada (`AGENTS.md` §6): **fila 4** (cambio de contrato) — analista → desarrollador → QA →
  seguridad. Se descartó la fila 1 porque CA-02 **sí cambia obligaciones**, y la vía proporcional
  de reparación porque el contrato no era claro en el sentido de §6.

## [AAAA-MM-DD] — Origen: (GitHub|Interno) — Título del cambio
- **Usuario:** (correo/identificador)
- **Modelo IA:** (ej. claude-opus-4-8 coordinadora + claude-sonnet-4-6 dev/QA)
- **Agente(s):** (analista-requerimientos | desarrollador | qa-tester | auditor-seguridad | coordinadora)

### Cambios
- (detalle de lo que se hizo)

### Ciclo de agentes (trazabilidad)
- (qué hizo cada agente; veredicto de QA y seguridad)
