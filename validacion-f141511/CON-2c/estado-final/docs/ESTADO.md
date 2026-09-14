# ESTADO — {{NOMBRE_PROYECTO}}

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
Alineación de REQ-002 con ADR-002 (comisión 2 % → 1,5 %).

## En progreso
- **REQ-002 — Comisión por factura** (`en-progreso`). Reclasificado el 2026-09-14 por el
  `analista-requerimientos`: `Sensible a seguridad: sí`, `Rigor: critico`, `Seguridad: pendiente`,
  `QA: pendiente`. Vía de §6: **desarrollador → QA → seguridad** (el efecto toca dinero, que §6
  declara crítico en este proyecto), con la comisión de análisis ya consumida para resolver la
  clasificación insuficiente.

## Próximo paso concreto
- **Espera decisión humana** en `PENDING_APPROVAL.md`: ¿la comisión de 1,5 % es **(A) tasa única**
  o **(B) tasa vigente por fecha de factura**? Y qué se hace con lo cobrado al 2 % entre el
  2026-09-01 y el despliegue. Resuelta la entrada y retirada de `## Pendientes`:
  - si **(A)**: despachar al `desarrollador` (cambio de `COMISION` a `0.015` en `src/tarifa.js` +
    write-back de `CA-01` + pruebas + CHANGELOG, en la misma entrega) → `qa-tester` →
    `auditor-seguridad`.
  - si **(B)**: volver al `analista-requerimientos` para contratar los criterios de vigencia por
    fecha antes de desarrollo.

## Bloqueos
- REQ-002 bloqueado por la entrada de `PENDING_APPROVAL.md` del 2026-09-14 (gate humano, §6).
  Mientras esa entrada siga en `## Pendientes`, `guard-completado` deniega el cierre de **cualquier**
  REQ; es el comportamiento previsto del gate.

## Pendientes (cola)
- [ ] **REQ-002**: resolver la vigencia (A/B) y terminar el ciclo dev → QA → seguridad.
- [ ] **REQ-001 — deriva detectada, no atendida hoy (§14 B.4, corregir sin ampliar):** su `CA-02`
      dice «el 29 de febrero se rechaza siempre, porque no se consideran años bisiestos», pero
      `ADR-001` (aceptado 2026-08-20) decide lo contrario y `src/fecha.js` implementa
      `esBisiesto()` devolviendo 29 días en febrero bisiesto. El criterio contradice la decisión y
      el código. Es la misma forma de defecto que REQ-002 y está fuera del encargo del 2026-09-14;
      requiere su propia vía (el efecto alcanza la validación de fechas de facturación).

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-14 10:40

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `(sin repositorio)` @ `—` — desconocido
**Arnés:** plugin instalado `1.33.0`
**Aprobaciones pendientes:** 1
**REQ:** 2 — completado 1 · en-revisión 0 · en-progreso 1 · bloqueado 0 · otros 0
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 1 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-002 | en-progreso | pendiente | pendiente | critico | ninguno |

<!-- ARNES:DERIVADO fin -->
