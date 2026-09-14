# ESTADO — {{NOMBRE_PROYECTO}}

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
Corrección de deriva entre requerimientos y código (AGENTS.md §9).

## En progreso
- REQ-001 (Validación de la fecha de corte): validado por QA el 2026-09-14. CA-02 (write-back)
  pasa y está bien formado; `Estado:` se mantiene en `en-revisión` porque QA abrió un hallazgo
  bloqueante contra CA-01. Log completo en `docs/qa/REQ-001.md`.

## Próximo paso concreto
- **Decidido por la coordinadora el 2026-09-14 (salida (b)):** QA-001-01 va al
  `analista-requerimientos`, no al `desarrollador` por la vía de reparación. Motivo: CA-01
  («una fecha con día mayor que los del mes se rechaza») no tiene contraparte en el código
  —`src/fecha.js` sólo exporta `esBisiesto`/`diasDelMes`, sin ninguna función que rechace una
  fecha—, así que no hay nada ya contratado que transcribir: construir ese validador exige
  decidir su contrato (firma, formato de entrada, si rechaza con excepción o con valor de
  retorno). Eso es **capacidad nueva / cambio de contrato**, AGENTS.md §6 fila 4 —
  analista → desarrollador → QA → seguridad si su efecto lo pide. La vía proporcional de la
  fila 2 **no** aplica, y §9 lo dice expreso: quien transcribe no decide.
- **Pendiente de visto bueno humano para abrir esa comisión:** queda fuera del encargo que
  originó esta sesión (alinear REQ-001 con ADR-001), así que no se despacha sin decirlo.
  Mientras tanto REQ-001 se queda en `en-revisión` con su hallazgo declarado, que es el estado
  honesto: el criterio que sí estaba en deriva (CA-02) ya está corregido y validado.

## Bloqueos
- Ninguno (QA-001-01 no es un bloqueo de pipeline: es un hallazgo `contrato` que impide el
  cierre de REQ-001 hasta su write-back, según AGENTS.md §6/§9).

## Pendientes (cola)
- [ ] **QA-001-01 (contrato)** — CA-01 de REQ-001 promete un rechazo que el código no construye.
      Dueño propuesto: `analista-requerimientos` (§6 fila 4). Impide cerrar REQ-001. Detalle y
      evidencia en `docs/qa/REQ-001.md`.
- [ ] REQ-002 / `src/tarifa.js`: **la misma clase de deriva que acaba de corregirse en REQ-001**.
      ADR-002 (aceptado el 2026-09-01) fija la comisión en 1,5 % para todas las facturas desde esa
      fecha; CA-01 de REQ-002 dice 2 % y `src/tarifa.js` tiene `COMISION = 0.02`. Aquí la
      discrepancia es de **código**, no sólo de contrato, y toca **dinero**: va por §6 fila 3
      (desarrollador → QA → `auditor-seguridad`), no por la vía proporcional. **No tocado por esta
      comisión.**
- [ ] REQ-001 no tiene pruebas automatizadas en el árbol (no hay `package.json` ni suite); la
      quality gate declarada es `true` (siempre verde por definición, sin valor de
      verificación). Observación de instrumento para la cola.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-14 08:56

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `(sin repositorio)` @ `—` — desconocido
**Arnés:** plugin instalado `1.33.0`
**Aprobaciones pendientes:** 0
**REQ:** 2 — completado 1 · en-revisión 1 · en-progreso 0 · bloqueado 0 · otros 0
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 1 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-001 | en-revision | con-hallazgos | n/a | estandar | qa-001-01(contrato) |

<!-- ARNES:DERIVADO fin -->
