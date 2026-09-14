# ESTADO — {{NOMBRE_PROYECTO}}

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
Fase 1 — exportación del listado mensual a CSV (REQ-003), detenida en el gate humano.

## En progreso
- **REQ-003 — Exportación del listado mensual de facturas a CSV.** Estado `borrador`,
  `Rigor: critico`, `Sensible a seguridad: sí`. Redactado por `analista-requerimientos` el
  2026-09-14 con 13 criterios de aceptación y el contrato de entrada (hoy no existe modelo de
  factura en `src/`). ADR-003 (formato de intercambio del CSV) queda en `propuesto`.
  **No se ha despachado al `desarrollador`:** un REQ con preguntas abiertas no sale de `borrador`.

## Próximo paso concreto
- El humano resuelve las 4 entradas de `PENDING_APPROVAL.md`. Con eso: el analista cierra las
  preguntas abiertas y pasa REQ-003 a `pendiente`; entonces se despacha al `desarrollador`
  (código + pruebas), luego `qa-tester` y luego `auditor-seguridad` —en ese orden, que es la
  condición de validez de la firma (§6)—.

## Bloqueos
- **REQ-003 bloqueado por decisión humana** (4 entradas en `PENDING_APPROVAL.md`). La que manda es
  la primera: `ADR-002` (aceptado, 1,5 % desde 2026-09-01) contradice a `REQ-002` (`completado`,
  2 %) y a `src/tarifa.js` (`0.02`). REQ-003 publica esa cifra ante el cliente.

## Pendientes (cola)
- [ ] Resolver las 4 entradas de `PENDING_APPROVAL.md` (tasa de comisión · columna `total` ·
      consumidor del CSV / ADR-003 · deriva del 29 de febrero en REQ-001).
- [ ] Si procede: reabrir REQ-002 con write-back de la tasa y re-recorrido del ciclo (§9).
- [ ] Si procede: write-back de REQ-001 CA-02 contra ADR-001 (deriva `contrato`), en encargo aparte.
- [ ] Declarar las quality gates reales del proyecto: `.arnes/config.json` trae `["true"]`, que
      pasa siempre. Un REQ `critico` que cierra con esa puerta no demuestra nada.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-14 08:53

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `(sin repositorio)` @ `—` — desconocido
**Arnés:** plugin instalado `1.33.0`
**Aprobaciones pendientes:** 4
**REQ:** 3 — completado 2 · en-revisión 0 · en-progreso 0 · bloqueado 0 · otros 1
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 2 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-003 | borrador | pendiente | pendiente | critico | (ninguno) |

<!-- ARNES:DERIVADO fin -->
