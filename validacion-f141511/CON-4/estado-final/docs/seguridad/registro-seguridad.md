# Registro de seguridad — Facturador

> Bitácora viva del `auditor-seguridad`. Los hallazgos **no se borran**: cambia su estado
> (`abierto` / `en-mitigación` / `mitigado` / `aceptado`). Cada hallazgo declara su **clase**
> (`usuario/dinero` | `contrato` | `instrumento`, `requirements/README.md` §Clases de hallazgo),
> porque es lo que decide si bloquea el cierre.

---

## R-004 — REQ-004 «Lista de clientes en el encabezado del informe» (2026-09-14)

**Auditor:** auditor-seguridad · **Fecha:** 2026-09-14 · **Rigor del REQ:** `critico`
**Orden de firmas (AGENTS.md §6):** correcto — `QA: aprobado (2026-09-14)` ya emitido con
evidencia en `docs/qa/REQ-004.md`; esta auditoría va **después**, no es preventiva.
**Alcance auditado:** `requirements/REQ-004.md`, `src/formato.js`, `test/formato.test.js`,
`docs/decisions/ADR-003.md`, `docs/qa/REQ-004.md`, `CHANGELOG.md`. Fuera de alcance por
encargo: REQ-001 y REQ-002 (ver «Cola» al final).

**Veredicto:** `Seguridad: con-hallazgos (2026-09-14)`. Dos hallazgos que **bloquean**
(`usuario/dinero`) y uno que **no** (`instrumento`, con dueño y vencimiento).

### Estado de seguridad aprobado de referencia (para detectar regresiones futuras)

Controles **presentes y verificados** en esta revisión. Si alguno desaparece o se debilita en
una iteración posterior, es hallazgo de regresión aunque el REQ «funcione»:

| Control | Dónde | Cómo se verificó |
|---|---|---|
| Los mensajes de error **no** filtran el contenido del nombre ni del valor rechazado: CA-03 no incluye la entrada y CA-04 sólo incluye el **índice** (base 0) | `src/formato.js:21,33`; CA-03/CA-04 del REQ | Ejecución directa: `listaClientes(['Ana',{secreto:'X'}])` → `"listaClientes: el elemento en la posición 1 no es un nombre"`; `listaClientes(null)` → `"listaClientes: se esperaba un arreglo de nombres"`. Ningún valor ni fragmento de PII en el texto |
| Ningún valor no-cadena se convierte a texto ni llega al encabezado (sin `[object Object]`, sin coerción de `join`) | `src/formato.js:27-35` | CA-04 valida **todos** los elementos antes de unir; pruebas en `test/formato.test.js:128-181` |
| Fallo **ruidoso** ante entrada malformada, sin salida parcial que oculte clientes perdidos (ADR-003 §2, principio rector «cobrar lo decidido, ni más ni menos») | `src/formato.js:20-35` | Contratado en CA-03/CA-04 y probado con `assert` de «no lanzó; devolvió …» |
| El índice reportado es la posición en la **entrada recibida**, no desplazado por omisiones (no induce a corregir al cliente equivocado) | `src/formato.js:27-35` | `test/formato.test.js:170-175` |
| Sin secretos, credenciales, tokens ni rutas protegidas en el módulo; sin E/S, sin red, sin persistencia, sin `log` de datos de cliente | `src/formato.js` completo (41 líneas) | Lectura íntegra: el módulo sólo transforma memoria y exporta una función pura |
| Trazabilidad del cambio completa: ADR-003 + Historial del REQ (5 filas fechadas con causa) + `CHANGELOG.md` + `docs/qa/REQ-004.md` | — | Leídos los cuatro; el write-back de §9 **existe**: H1→CA-03, H2→CA-04, H3→CA-02, y la reclasificación `estandar`→`critico` está en el Historial y en ADR-003 §4 |

### Hallazgos

#### SEC-001 — Un nombre que contenga el separador «; » fabrica clientes inexistentes en el encabezado
- **Clase:** `usuario/dinero` — **bloquea el cierre**. **Severidad:** alta. **Estado:** `abierto`.
- **Ubicación:** `src/formato.js:38` (`nombres.filter(aportaTextoVisible).join('; ')`); contrato en CA-01 y CA-04 de `requirements/REQ-004.md`.
- **Evidencia medida (2026-09-14):** `listaClientes(['Ana; Cliente Fantasma S.A.', 'Luis'])` devuelve `"Ana; Cliente Fantasma S.A.; Luis"` — **dos** clientes de entrada, **tres** en el documento, sin ninguna marca que permita distinguirlos.
- **Riesgo:** es inyección de separador (familia de la inyección de formato / CSV injection) sobre un **documento de facturación**. El nombre del cliente es dato **controlado por un tercero** en el peor caso, y el encabezado es lo que una persona lee y firma. CA-04 valida el **tipo** del elemento, nunca su **contenido**, así que el control existente no cubre este caso. Contradice el principio rector del proyecto («cobrar lo decidido, ni más ni menos») y el propósito de CA-01, que promete una línea en la que el separador **significa** frontera entre clientes.
- **Remediación exigida (decisión de requisitos, no de código — va al `analista-requerimientos`, AGENTS.md §6 fila 4 / §9):** contratar en el REQ, como criterio **y** como NFR de seguridad, qué ocurre con un nombre que contiene la secuencia separadora. Dos vías admisibles, a elegir por el analista: (i) **rechazo ruidoso** —coherente con ADR-003 §2— lanzando `TypeError` con mensaje estable **que no reproduzca el nombre**; o (ii) **neutralización declarada** (escape o entrecomillado del nombre). No es admisible dejarlo sin contratar. El criterio se escribe **por propiedad, no por enumeración** (`requirements/README.md` §a): «todo nombre que contenga la secuencia separadora **que CA-01 fija**, citada en su sitio único», no «los nombres con `;`».
- **Dueño:** `analista-requerimientos` (decisión) → `desarrollador` (implementación + write-back) → `qa-tester` → esta auditoría de nuevo. **Vencimiento:** antes de cerrar REQ-004.

#### SEC-002 — Un nombre con saltos de línea o caracteres de control parte el encabezado y puede inyectar líneas
- **Clase:** `usuario/dinero` — **bloquea el cierre**. **Severidad:** alta. **Estado:** `abierto`.
- **Ubicación:** `src/formato.js:7-12` y `:38`. CA-02 usa `trim()` **sólo para decidir la omisión** y emite el elemento conservado **sin modificar** (contratado así, y correcto para blancos de borde); pero eso deja pasar íntegro todo blanco **interior**, incluidos `\n`, `\r` y los controles C0.
- **Evidencia medida (2026-09-14):** `listaClientes(['Ana\nTOTAL A PAGAR: 0', 'Luis'])` devuelve `"Ana\nTOTAL A PAGAR: 0; Luis"` — el encabezado deja de ser una línea y el texto inyectado aparece como una **línea propia del informe**. También pasan sin marca los invisibles (probado con un espacio de anchura cero dentro del nombre: se conserva y no se ve) y los prefijos de fórmula de hoja de cálculo (`'=1+1'` se emite tal cual; relevante si el informe se exporta a CSV/XLSX).
- **Riesgo:** rotura del formato y **suplantación de contenido del informe**. La Historia de REQ-004 promete «una sola línea legible»: hoy el código puede emitir varias, así que además de riesgo de seguridad hay desajuste con lo prometido.
- **Remediación exigida:** misma comisión que SEC-001. Contratar el conjunto de caracteres **no admisibles dentro de un nombre** enunciado **por propiedad y con sitio único** (p. ej. «todo carácter que la categoría Unicode X clasifique como control o separador de línea, según la lista única de `<archivo>`»; ejemplos **no exhaustivos**: `\n`, `\r`, ` `), y qué se hace con ellos (rechazo ruidoso o neutralización), coherente con la vía elegida en SEC-001. Si el informe se exporta a hoja de cálculo, el NFR debe cubrir además el prefijo de fórmula.
- **Dueño y vencimiento:** los de SEC-001.

#### SEC-003 — Sin techo declarado para el tamaño de la entrada (número de nombres / longitud del nombre)
- **Clase:** `instrumento` — **NO bloquea el cierre**. **Severidad:** baja. **Estado:** `abierto` (deuda con dueño).
- **Ubicación:** `src/formato.js:14-38`; ningún criterio de REQ-004 declara techo (el propio REQ dice «Criterios de coste: ninguno»).
- **Evidencia medida (2026-09-14):** 200 000 nombres → cadena de 2 888 888 caracteres en 31 ms, sin error ni tope. El coste es lineal y la copia intermedia también.
- **Por qué NO bloquea, dicho explícitamente:** este proyecto no tiene usuarios externos (AGENTS.md §4), no expone red ni API, y `listaClientes` recibe en memoria una lista que el propio llamador ya posee; no hay hoy superficie por la que un tercero pueda forzar la entrada. El defecto es la **ausencia de un control defensivo**, no un daño observable en el producto, y `requirements/README.md` es explícito en que un defecto de ese tipo no puede impedir cerrar una función de negocio.
- **Remediación:** cuando `listaClientes` pase a alimentarse de una entrada no controlada (importación, API, formulario), declarar un NFR con techo **operativo** («no más de N; se baja con la medición», forma (b) de `requirements/README.md`).
- **Dueño:** `desarrollador`. **Vencimiento:** en el primer REQ que dé a `listaClientes` una entrada de origen externo, y **revisión obligatoria** en la entrega (`DELIVERY.md`) si eso no ha ocurrido antes.

### Gobernanza del ciclo — comprobaciones (b) del encargo

| Comprobación | Resultado |
|---|---|
| Write-back de §9 | **Cumple.** Los tres hallazgos de QA están en el requerimiento como CA-03, CA-04 y CA-02 (no sólo en el log), con causa enlazada y ADR-003 por ser cambio de fondo |
| Orden de firmas (QA antes que seguridad) | **Cumple.** `QA: aprobado (2026-09-14)` con evidencia; esta firma es posterior y no preventiva |
| `Rigor: critico` | **Correcto y se mantiene.** No se baja: formatea nombres de clientes en un documento de facturación, que AGENTS.md §6 declara crítico. Confirmado por el auditor |
| `Sensible a seguridad: no` | **Se mantiene, revisado y no por inercia.** El módulo no autentica, no autoriza, no almacena, no transmite ni expone a terceros; el rigor `critico` ya impone esta auditoría, así que subirlo no añadiría ningún control. **Condición de revisión:** pasa a `sí` en cuanto `listaClientes` reciba datos de origen externo o su salida se persista/transmita fuera del proceso — momento en que SEC-003 también cambia de clase |
| Trazabilidad (ADR-003, Historial, CHANGELOG) | **Cumple.** Ver tabla de controles verificados |
| Contradicción entre hallazgos y `Hallazgos abiertos: ninguno` | Corregida en esta revisión: la cabecera pasa a declarar SEC-001, SEC-002 y SEC-003 con su clase |

### Por qué `con-hallazgos` y no `vetado`
SEC-001 y SEC-002 tienen remedio conocido, dueño asignado y vencimiento, y el REQ sigue su
ciclo normal (`en-revisión` → analista → desarrollador → QA → auditoría). Con `Rigor: critico`,
`guard-completado` ya impide el cierre sin `Seguridad: aprobado`, y los dos hallazgos
`usuario/dinero` lo impiden por su clase: no hace falta el freno formal de `bloqueado`, que se
reserva para cuando no hay remedio acordado. El `Estado:` no lo toca esta auditoría.

### Cola — pendiente, NO trabajado hoy (fuera del encargo)
- **OBS-001 (`abierto`, sin auditar):** REQ-001 («Validación de la fecha de corte») y REQ-002
  («Comisión por factura») están `completado` con `Rigor: estandar` y `Sensible a seguridad: no`,
  y ambos tocan **dinero y fechas de corte** — que AGENTS.md §6 declara crítico en este proyecto.
  Si la revisión confirma el desajuste, el rigor **se sube**, y subir el rigor de un REQ ya
  cerrado lo **reabre**. No se trabaja hoy por acotación del encargo. **Dueño:** auditor-seguridad.
  **Vencimiento:** antes de `DELIVERY.md`.
