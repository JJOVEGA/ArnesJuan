# ESTADO — {{NOMBRE_PROYECTO}}

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
Mantenimiento — reparación de REQ-002 (comisión por factura) por la vía proporcional de `AGENTS.md` §6.

## En progreso
- **REQ-002 — Comisión por factura** · `en-revisión`. El desarrollador aplicó ADR-002 (2 % → 1,5 %)
  en `src/tarifa.js`, añadió `test/tarifa.test.js` y entregó el write-back del §9 en el REQ
  (CA-01 a 1,5 % como número de contrato + Historial). QA hizo análisis estático completo
  (criterios, dependencias, write-back) sin encontrar defectos en el delta, pero **tampoco** esta
  comisión de QA tuvo herramienta Bash/ejecución: `node test/tarifa.test.js` sigue sin corrida
  real. `QA: pendiente` (evidencia y detalle en `docs/qa/REQ-002.md`).

## Próximo paso concreto
- Despachar una comisión de **`qa-tester` con acceso real a shell** (o que el humano corra el
  comando) para ejecutar `node test/tarifa.test.js` y reportar la salida real (12 casos
  esperados) y, si aplica, las quality gates de `.arnes/config.json` (`true` — puerta vacía, no
  demuestra corrección). Sólo entonces escribir `QA: aprobado` con esa evidencia.
- Después, y sólo después, el **`auditor-seguridad`** (fila 3 de §6: el cambio toca dinero). No
  antes: seguridad no firma sobre un árbol que QA no validó (§6).

## Bloqueos
- Ninguno formal, pero REQ-002 no puede avanzar a `auditor-seguridad` hasta que exista ejecución
  real de `test/tarifa.test.js` (ver Pendientes).

## Pendientes (cola)
- [ ] QA de REQ-002: ejecución REAL de `node test/tarifa.test.js` (12 casos) — ni el desarrollador
      ni esta comisión de QA tuvieron acceso a shell; sigue sin medirse. Ver `docs/qa/REQ-002.md`
      §0 y hallazgo `QA-002-01 (instrumento)`.
- [ ] Revisión del `auditor-seguridad` sobre REQ-002, tras QA `aprobado` con evidencia real.
- [ ] **Para el auditor:** valorar si `Rigor: estandar` / `Sensible a seguridad: no` siguen siendo
      correctos en un REQ que fija cuánto se cobra, cuando §6 declara crítico «todo lo que toque
      dinero». El desarrollador **no** tocó esos campos (§6 punto 2); subirlos es competencia del
      auditor (y del analista para la sensibilidad).
- [ ] **Fuera de alcance de REQ-002, hallazgo nuevo para la cola (no confirmado, sin abrir
      trabajo):** REQ-001 (`completado`, `QA: aprobado 2026-08-15`) tiene CA-02 = «El 29 de
      febrero se rechaza siempre, porque no se consideran años bisiestos», pero `src/fecha.js`
      implementa `esBisiesto` correctamente y `diasDelMes` devuelve 29 en años bisiestos — el
      código SÍ considera años bisiestos. Posible deriva entre REQ-001 y el código
      (`AGENTS.md` §9). No se investiga ni se reabre aquí: es ajeno al delta de REQ-002
      (§14 B.4); queda para que el analista/QA lo evalúe en su propio ciclo.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-14 08:57

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
| REQ-002 | en-revision | pendiente | n/a | estandar | qa-002-01(instrumento) |

<!-- ARNES:DERIVADO fin -->
