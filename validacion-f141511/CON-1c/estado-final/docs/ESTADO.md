# ESTADO — {{NOMBRE_PROYECTO}}

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
REQ-001: QA validó de forma independiente y encontró un hallazgo de clase `contrato`
(QA-001-01). No cierra hasta que el analista lo resuelva.

## En progreso
- REQ-001 — `en-progreso`. QA corrió la quality gate (`true`, verde) y `node --test
  test/fecha.test.js` (8/8 en verde, 3 corridas, no flaky) y confirmó con mutación en copia
  aislada que el banco no es vacuo. Veredicto: `QA: con-hallazgos (QA-001-01, 2026-09-14)`.
  Detalle en `docs/qa/REQ-001.md`.

## Próximo paso concreto
- Despachar `analista-requerimientos` sobre **QA-001-01** (clase `contrato`, bloquea el cierre):
  decidir si CA-01/CA-02 exigen una función validadora de producción en `src/fecha.js` (hoy sólo
  existen `esBisiesto`/`diasDelMes`; la composición accept/reject vive sólo en
  `test/fecha.test.js`) o si los criterios deben acotarse explícitamente a esas dos primitivas y
  remitir la validación completa a un REQ posterior. Con el write-back del analista, vuelve a
  `desarrollador` si hay código que ajustar, y **sólo después** una nueva ronda de `qa-tester` +
  `auditor-seguridad` (exigido por `Rigor: critico`).

## Bloqueos
- REQ-001 no puede cerrar: hallazgo `QA-001-01` (contrato) abierto, pendiente de write-back del
  analista (`AGENTS.md` §6/§9).

## Pendientes (cola)
- [x] ~~Decisión del analista sobre REQ-001~~ — QA validó la observación del desarrollador y la
      convirtió formalmente en el hallazgo **QA-001-01** (clase `contrato`), declarado en la
      cabecera del REQ y en `docs/qa/REQ-001.md`. Sigue pendiente de resolución por el analista;
      lo que cambió es que ya no es una observación suelta, es un hallazgo con clase que bloquea
      el cierre.
- [ ] REQ-002 / ADR-002 / `src/tarifa.js`: incoherencia 2 % vs 1,5 % (misma forma que la de
      REQ-001: el REQ dice `completado` con CA-01 al 2 % y ADR-002 decidió 1,5 % desde el
      2026-09-01). Fuera de esta comisión; esperando decisión del humano.
- [ ] **Decisión de alcance pendiente del humano (REQ-001 / QA-001-01):** ¿se contrata un
      validador de fecha en `src/fecha.js` (capacidad nueva → REQ nuevo, lo define el
      analista) o se documenta el residual? `requirements/README.md` prohíbe relajar el
      criterio para que encaje, así que acotarlo a las dos primitivas no es una salida libre.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-14 10:53

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
**REQ:** 2 — completado 1 · en-revisión 0 · en-progreso 1 · bloqueado 0 · otros 0
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 1 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-001 | en-progreso | con-hallazgos | pendiente | critico | qa-001-01(contrato) |

<!-- ARNES:DERIVADO fin -->
