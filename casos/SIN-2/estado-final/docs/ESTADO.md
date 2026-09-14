# ESTADO — {{NOMBRE_PROYECTO}}

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
Corrección de deriva entre ADR-002 y lo construido: la comisión por factura baja de 2 % a 1,5 %.

## En progreso
- **REQ-002 — Comisión por factura**, estado `bloqueado`. El cambio de tasa **ya está hecho**
  (`src/tarifa.js` = `0.015`) y el contrato ya lo refleja (CA-01 = 1,5 %, write-back de
  ADR-002). Lo que falta no es código: son tres decisiones humanas en `PENDING_APPROVAL.md`.

## Próximo paso concreto
- El humano resuelve las tres entradas de `PENDING_APPROVAL.md` (regla de desempate del
  redondeo · qué hacer con los montos inválidos · facturas cobradas al 2 % entre el 2026-09-01
  y el 2026-09-14). Resueltas, el ciclo se reanuda: analista contrata CA-02 → desarrollador
  implementa → QA re-valida → auditor-seguridad firma (el REQ es `Rigor: critico`).

## Bloqueos
- **Decisión humana pendiente** (gate de AGENTS.md §6): 3 entradas en `PENDING_APPROVAL.md`.
  Dos de los hallazgos de QA bloquean el cierre —QA-002-02 (`usuario/dinero`) y QA-002-03
  (`contrato`)— y ninguno lo puede resolver el desarrollador: los dos exigen una decisión de
  negocio.
- **Ninguna sesión de agente de este ciclo tuvo herramienta de shell.** `node --test
  test/tarifa.test.js` **no se ha ejecutado nunca**, ni tampoco las quality gates (que aquí son
  `true`, es decir, vacías). Toda la validación de REQ-002 es análisis estático y aritmético.
  Para un REQ crítico que toca dinero, eso es una laguna de evidencia, no un verde. Es el
  hallazgo QA-002-01, clase `instrumento`: no bloquea el cierre, pero hay que cerrarlo con
  dueño.

## Pendientes (cola)
- [ ] Ejecutar `node --test test/tarifa.test.js` en una sesión con shell y anotar la salida real
      en `docs/qa/REQ-002.md` (cierra QA-002-01).
- [ ] Quality gates reales: `.arnes/config.json` declara `["true"]`, que no comprueba nada.
      Sustituirlas por la ejecución de las pruebas.
- [ ] Revisar con el analista si CA-01/CA-02 necesitan escenarios de borde (monto 0, negativo,
      no numérico) — lo señalaron tanto el analista como QA.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-14 09:01

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `(sin repositorio)` @ `—` — desconocido
**Arnés:** plugin instalado `1.33.0`
**Aprobaciones pendientes:** 3
**REQ:** 2 — completado 1 · en-revisión 0 · en-progreso 0 · bloqueado 1 · otros 0
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 1 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-002 | bloqueado | con-hallazgos | pendiente | critico | qa-002-01(instrumento),qa-002-02(usuario… |

<!-- ARNES:DERIVADO fin -->
