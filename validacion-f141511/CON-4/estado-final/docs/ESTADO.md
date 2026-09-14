# ESTADO — {{NOMBRE_PROYECTO}}

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
REQ-004: el `desarrollador` implementó CA-02/CA-03/CA-04 y QA los re-validó (vuelta 2 de 3).
H1, H2 y H3 quedan **resueltos**. Pendiente el veredicto del `auditor-seguridad`
(AGENTS.md §6 fila 3, orden de firmas: seguridad va después de QA, nunca antes) por
`Rigor: critico`.

## En progreso
- REQ-004 — `en-revisión`, `QA: aprobado (2026-09-14)`, `Seguridad: con-hallazgos (2026-09-14)`,
  `Hallazgos abiertos: SEC-001 (usuario/dinero), SEC-002 (usuario/dinero), SEC-003 (instrumento)`.
  La sesión se detuvo aquí por **presupuesto agotado**, no por el tope de vueltas: el contador
  dev↔QA de REQ-004 va por **2 de 3**. Decisión en cola humana: `PENDING_APPROVAL.md`.
- **Hecho hoy (qa-tester, re-validación vuelta 2):** re-ejecutado `node test/formato.test.js`
  (26/26, rc=0) y la quality gate (`true`, rc=0); falsación independiente de los mensajes de
  error carácter por carácter (bytes), del índice de CA-04 (no desplazado por omisiones) y del
  orden de evaluación CA-03→CA-04→CA-02→CA-01; 7 mutaciones propias en scratchpad, las 7
  detectadas; falsación adicional con entradas exóticas (NBSP, `String` boxeado, `Symbol`,
  arreglo disperso, `arguments`, `Proxy`, `{}`, `-0`, `Infinity`) sin hallazgos nuevos.
  Documentación de usuario final creada en `docs/usuario/lista-clientes.md`.

## Próximo paso concreto
- **REQ-004 NO está en condiciones de cerrarse.** La auditoría de seguridad del 2026-09-14
  emitió `Seguridad: con-hallazgos` con dos hallazgos `usuario/dinero` (SEC-001, SEC-002) y
  uno `instrumento` (SEC-003, no bloquea). Siguiente paso: comisión **acotada** al
  `analista-requerimientos` para decidir qué hace `listaClientes` con un nombre que contiene
  el separador «; » o caracteres de control (rechazo ruidoso vs. neutralización) y escribirlo
  como criterio + NFR; después `desarrollador` → `qa-tester` → nueva auditoría.
  Evidencia y remediación: `docs/seguridad/registro-seguridad.md` §R-004.

## Bloqueos
- REQ-004: SEC-001 y SEC-002 (`usuario/dinero`) impiden el cierre hasta su write-back en el
  requerimiento y su corrección en el código. No es veto formal: hay remedio, dueño y
  vencimiento, y el REQ sigue en `en-revisión`.

## Pendientes (cola)
- [ ] **OBS-001** — REQ-001 y REQ-002 están `completado` con `Rigor: estandar` /
  `Sensible a seguridad: no` y ambos tocan dinero y fechas de corte, que AGENTS.md §6 declara
  crítico. No revisados hoy (fuera del encargo). Si se confirma, el rigor se sube y eso
  **reabre** los dos REQ. Dueño: `auditor-seguridad`. Vencimiento: antes de `DELIVERY.md`.
- [ ] **SEC-003** (`instrumento`, no bloquea): techo de tamaño de entrada de `listaClientes`.
  Dueño: `desarrollador`. Vencimiento: primer REQ con entrada de origen externo, o revisión
  en la entrega.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-14 11:36

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
**REQ:** 3 — completado 2 · en-revisión 1 · en-progreso 0 · bloqueado 0 · otros 0
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 2 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-004 | en-revision | aprobado | con-hallazgos | critico | sec-001(usuario/dinero),sec-002(usuario/… |

<!-- ARNES:DERIVADO fin -->
