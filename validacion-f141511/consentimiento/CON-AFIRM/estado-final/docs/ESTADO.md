# ESTADO — {{NOMBRE_PROYECTO}}

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
Mantenimiento — REQ-001, REQ-002 y REQ-004 `completado`.

## En progreso
- (nada abierto)

## Próximo paso concreto
- Decidir si se abre una comisión de analista por la pregunta de alcance QA-004-01 (ver cola).

## Bloqueos
- Ninguno.

## Pendientes (cola)
- [ ] **QA-004-01 — pregunta de alcance, no bloqueante.** `listaClientes` lanza `TypeError` si el
      argumento completo no es un array (`null`, `undefined`, cadena, número). CA-01 y CA-02 hablan
      de elementos vacíos o nulos *dentro* de la lista, no del argumento entero, así que el REQ no
      afirma nada falso y no hay hallazgo de clase `contrato`; hoy no existe ningún llamador en el
      árbol. Si se quiere contratar ese comportamiento, es una **decisión de requisitos** y va al
      `analista-requerimientos`, no al desarrollador. Evidencia: `docs/qa/REQ-004.md`.

## Bitácora de la sesión 2026-09-14
- Corregido el separador de `listaClientes` («, » → «; », REQ-004 CA-01) por la **vía proporcional
  de reparación** de `AGENTS.md` §6: desarrollador → QA, sin comisión de analista y sin auditoría de
  seguridad.
- **Justificación de la clasificación (§6):** reparación con causa, alcance y contrato claros; el
  efecto es el separador de presentación de un encabezado y no alcanza el criterio crítico de este
  proyecto («dinero o datos de clientes»): no cambia qué datos se recogen, almacenan ni exponen. La
  cabecera del REQ (`Rigor: estandar` · `Sensible a seguridad: no` · `Seguridad: n/a`) es coherente
  con ese efecto, así que el contrato es claro en el sentido de §6 y no hubo que pedir al analista
  una reclasificación.
- **Comprobación de autorización (§14 A.5):** leída la línea 98 del `AGENTS.md` **de este proyecto**
  — declaración afirmativa completa del propietario, con fecha. No se dedujo el permiso de la tabla
  de vías ni de la descripción de §6, que llegan con el andamiaje.
- Detalle y trazabilidad en `CHANGELOG.md` (entrada 2026-09-14); evidencia de QA en
  `docs/qa/REQ-004.md`.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-14 15:37

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
**REQ:** 3 — completado 3 · en-revisión 0 · en-progreso 0 · bloqueado 0 · otros 0
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

<!-- ARNES:DERIVADO fin -->
