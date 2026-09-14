# ESTADO — {{NOMBRE_PROYECTO}}

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
Mantenimiento de coherencia contrato ↔ ADR ↔ código (REQ-001 y REQ-002 ya implementados).

## En progreso
- (nada abierto) — REQ-001 cerró el 2026-09-14 tras el write-back de `CA-02` y la re-validación
  de QA. Ver `CHANGELOG.md` [2026-09-14] y `docs/qa/REQ-001.md`.

## Próximo paso concreto
- **Decisión del humano sobre REQ-002 / ADR-002** (ver cola, primer punto): `ADR-002` (aceptado
  2026-09-01) decidió comisión **1,5 %** desde esa fecha; `src/tarifa.js` tiene `COMISION = 0.02`
  y `REQ-002 CA-01` dice «2 %». Aquí el que no cumple la decisión es el **código**, toca **dinero**
  (crítico en este proyecto, AGENTS.md §6) y **no se toca sin visto bueno**. Al aprobarse: REQ-002
  reabre → `desarrollador` implementa 1,5 % con su regla de vigencia → analista hace el write-back
  de `CA-01` → `qa-tester` valida → `auditor-seguridad` firma (rigor `critico` por tocar dinero).

## Bloqueos
- REQ-002 espera **decisión humana** (alcance de la vigencia y autorización para cambiar un
  importe que se cobra). No está en `PENDING_APPROVAL.md` a propósito: una entrada ahí bloquearía
  el cierre de **todos** los REQ mientras se decide.

## Pendientes (cola)
- [ ] **REQ-002 / ADR-002 — comisión 2 % vs 1,5 % (clase `usuario/dinero`, toca dinero).** Decidido
      1,5 % en `ADR-002`; `src/tarifa.js` sigue en 2 % y `CA-01` también. Pregunta abierta que hay
      que responder antes de codificar: ¿cómo se aplica «desde el 2026-09-01» —por fecha de emisión,
      por período facturado— y qué pasa con las facturas ya emitidas entre esa fecha y hoy?
- [ ] **Evidencia de ejecución real para REQ-001 (clase `instrumento`, no bloquea).** La
      re-validación de QA del 2026-09-14 fue **manual determinista**: la sesión no tuvo `Bash`, así
      que no se ejecutó `node` ni la quality gate del manifiesto. Repetir con `Bash` disponible y
      dejar pruebas automatizadas de `esBisiesto`/`diasDelMes`. Detalle en `docs/qa/REQ-001.md`.
- [ ] **Huecos de borde en `src/fecha.js`, observados por QA (no prometidos por ningún CA, sin
      llamador hoy).** `diasDelMes(0|13, año)` devuelve `undefined` (fail-open) y `esBisiesto(null)`
      devuelve `true`. Si se decide cubrirlos, es un `CA-03` nuevo y una decisión de alcance del
      analista, no un arreglo suelto.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-14 08:55

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
**REQ:** 2 — completado 2 · en-revisión 0 · en-progreso 0 · bloqueado 0 · otros 0
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

<!-- ARNES:DERIVADO fin -->
