# Registro de seguridad — Facturador

> **Bitácora viva.** La mantiene el `auditor-seguridad`. Cada hallazgo se registra con
> identificador, clase (`usuario/dinero` · `contrato` · `instrumento`, según
> `requirements/README.md`), severidad, dueño, remedio y estado de mitigación
> (`abierto` / `en-mitigación` / `mitigado` / `aceptado`). **Los hallazgos cerrados no se
> borran**: se les cambia el estado, porque la serie histórica es lo que permite detectar una
> **regresión** entre iteraciones.
>
> Un hallazgo registrado aquí **no está cerrado** hasta que el control viva en el
> **requerimiento** (criterio o NFR) **y** el código lo implemente (`AGENTS.md` §9,
> write-back). Un control que sólo existe en este archivo es deriva.

---

## Revisión 2026-09-21 — REQ-004 «Lista de clientes en el encabezado del informe»

- **Auditor:** `auditor-seguridad` · **Fecha:** 2026-09-21
- **Disparador:** `Sensible a seguridad: sí` · `Rigor: critico` (obligatorio, `AGENTS.md` §6).
- **Orden de fases cumplido:** `QA: aprobado (2026-09-21)` con `node --test` 8/8 verde
  (`docs/qa/REQ-004.md`). Ésta **no** es una auditoría `preventiva`: el código existe y es lo
  revisado.
- **Alcance revisado:** `src/formato.js`, `test/formato.test.js`, `requirements/REQ-004.md`,
  `docs/qa/REQ-004.md`, `docs/usuario/lista-de-clientes-en-el-encabezado.md`,
  `ARCHITECTURE.md`, `CHANGELOG.md`, `PENDING_APPROVAL.md`, `requirements/README.md`.
- **Método:** lectura de código y de contrato + ejecución de la función pura `listaClientes`
  con entradas de borde en un proceso local (`node -e`). **No** se ejecutó ningún ataque
  contra un entorno productivo: este proyecto no tiene red, servidor ni persistencia
  (`ARCHITECTURE.md`).
- **Veredicto:** `Seguridad: vetado (2026-09-21)`.

### Alcance del veto (`AGENTS.md` §6, regla 2)

1. **Qué acción impide:** dos, y se nombran las dos.
   - **cerrar** — marcar `REQ-004` como `completado` (transición de su campo `Estado:`).
     Regla que lo impide: este veto, más `guard-completado`, que en un REQ `critico` exige
     `Seguridad: aprobado`.
   - **publicar** — poner el informe mensual en manos de los clientes (la acción de `D1` en
     `PENDING_APPROVAL.md`), mientras `SEC-001` y `SEC-002` sigan abiertos. Regla que lo
     impide: este veto (`AGENTS.md` §6, «Loop de error»: la seguridad puede vetar en
     cualquier momento, y el veto conserva el alcance que le da quien lo firma).
   - **No** impide **implementar** ni **probar**: el `desarrollador` y el `qa-tester` pueden
     trabajar en el remedio en cuanto el contrato exista.
2. **Qué parte de la entrega afecta:** la línea de clientes del encabezado del informe
   mensual (versión destino 1.0.0) y su publicación al cliente. No afecta a `REQ-001`,
   `REQ-002` ni `REQ-005`.
3. **Qué evidencia lo sostiene:** `src/formato.js:15-19` (no hay validación ni codificación de
   salida de ningún tipo); mediciones de esta sesión, reproducidas abajo en cada hallazgo;
   `requirements/REQ-004.md` (ningún criterio ni NFR menciona el destinatario del informe ni
   los caracteres con significado en el formato de salida); `requirements/README.md` línea
   426 («No hay **NFR** declarados en este proyecto»).
4. **Qué lo resuelve:** el write-back de `SEC-001` y `SEC-002` como **NFR/criterio** por el
   `analista-requerimientos` (queda decisión de diseño y de contrato: es suya, `AGENTS.md`
   §9, y este proyecto **no** declara la vía proporcional), su implementación por el
   `desarrollador`, la validación del `qa-tester`, y una nueva auditoría en mi turno. El
   levantamiento del veto lo firmo yo y nadie más.

---

## Hallazgos

### SEC-001 — Un nombre de cliente puede falsear a quién corresponde el informe (inyección en el formato de salida)

- **Clase:** `usuario/dinero` · **Severidad:** alta · **Estado:** `abierto`
- **REQ:** REQ-004 · **Ubicación:** `src/formato.js:15-19` (`listaClientes`), en concreto
  `return nombres.filter(...).join(SEPARADOR)` — no hay validación de entrada ni codificación
  de salida en ninguna capa (`ARCHITECTURE.md` describe `src/formato.js` como **la** capa de
  presentación).
- **Riesgo.** El valor de cada nombre se incrusta **literalmente** en una línea del documento
  que reciben los clientes, y el separador contratado no está reservado ni protegido. Medido
  hoy contra el código entregado:

  | Entrada | Salida | Lo que el destinatario **lee** |
  |---|---|---|
  | `["Ana","Gomez; Ruiz S.A.","Marta"]` | `"Ana; Gomez; Ruiz S.A.; Marta"` | **cuatro** clientes donde hay **tres** |
  | `["Ana","Luis\nTotal a pagar: 0,00","Marta"]` | `"Ana; Luis\nTotal a pagar: 0,00; Marta"` | una **línea nueva** dentro del encabezado, con aspecto de renglón del informe |
  | `["Ana","Luis\r\nOtro","Marta"]` | `"Ana; Luis\r\nOtro; Marta"` | ídem, con terminador CRLF |
  | `["Ana","<b>Luis</b>","Marta"]` | `"Ana; <b>Luis</b>; Marta"` | marcado sin codificar, si el informe se publica en un formato que lo interprete |

  Esto contradice directamente la historia de usuario del propio REQ-004 («que el destinatario
  identifique **sin ambigüedad** a qué clientes corresponde el informe») y el principio rector
  del proyecto («cobrar lo decidido, ni más ni menos»): un cliente de más o de menos en el
  encabezado es una afirmación falsa sobre a quién se está cobrando. **No es hipotético**: hay
  razones sociales reales que contienen `;`, y `REQ-005` va a añadir un **importe** al mismo
  encabezado, con lo que una línea inyectada pasa a poder imitar una cifra de dinero.
- **Qué NO es.** No está cubierto por `P-01`/`D3` (que trata la **omisión** de vacíos) ni por
  `P-02`/`D4` (entrada que no es un arreglo): un nombre con `;` o con salto de línea es un
  **nombre presente y no vacío**, dentro del alcance exigible de CA-01.
- **Dueño del remedio:** `analista-requerimientos` (write-back: queda una decisión de diseño y
  de contrato) → después `desarrollador` → `qa-tester` → `auditor-seguridad`.
- **Remedio exigido.** Un **NFR nuevo** (y el criterio de CA-01 que lo refleje) que contrate el
  tratamiento **por propiedad, no por enumeración** (`requirements/README.md` §«Cómo se escribe
  un criterio que no se desmiente», forma (a)): *todo carácter o secuencia con significado en
  el formato en que se publica el informe* —el separador contratado, los terminadores de línea
  y el marcado del formato de salida son **ejemplos no exhaustivos**— no puede alterar la
  estructura de la línea ni el número de elementos que el destinatario percibe; la lista
  exhaustiva vive en **un solo sitio**, citado desde el NFR. La **decisión de diseño** (rechazar
  el nombre, codificarlo, o sustituir la secuencia) es del analista y **no la tomo yo**.
  Prerrequisito del NFR: declarar **en qué formato se publica el informe** — hoy no consta en
  ningún documento del proyecto, y sin eso no se puede saber qué hay que codificar.

### SEC-002 — No está declarado quién recibe el informe, y la lista expone nombres de clientes a terceros

- **Clase:** `usuario/dinero` · **Severidad:** alta · **Estado:** `abierto`
- **REQ:** REQ-004 · **Ubicación:** `requirements/REQ-004.md` (Historia y criterios),
  `PENDING_APPROVAL.md` `D1`, `docs/usuario/lista-de-clientes-en-el-encabezado.md`.
- **Riesgo.** `listaClientes` construye una línea con **varios** nombres de cliente
  (CA-01 contrata explícitamente el caso de N nombres) que se publica en «el informe mensual»,
  y `D1` dice que ese informe **se envía a los clientes**. Ningún documento del proyecto
  declara si el destinatario de un informe es **un** cliente, **varios**, o un destinatario
  interno. Si un informe que lista a N clientes se entrega a cada uno de ellos, cada cliente
  recibe los **nombres de los demás**: divulgación de datos personales de terceros —nombres de
  personas físicas o de razones sociales con las que el destinatario no tiene relación—, en un
  documento que además dice a quién se está facturando (revela una relación comercial). El
  proyecto no tiene ningún NFR, ninguna política de datos y ninguna base declarada para esa
  divulgación (`requirements/README.md`: «No hay **NFR** declarados en este proyecto»).
- **Por qué es un hallazgo y no una opinión.** `AGENTS.md` §6 declara crítico en este proyecto
  «todo lo que toque dinero o **datos de clientes**», y el REQ fue reclasificado por
  exactamente ese motivo. Un REQ `critico` por datos de clientes que **no declara a quién se
  los entrega** tiene el contrato incompleto en la dimensión que motivó su criticidad.
- **Dueño del remedio:** decisión del **propietario del proyecto** (escalada hoy como `D6` en
  `PENDING_APPROVAL.md`, con la forma de `AGENTS.md` §6, regla 4) → write-back del
  `analista-requerimientos` como NFR + criterio.
- **Remedio exigido.** (i) Declarar el **destinatario** de cada informe y la **regla de qué
  nombres pueden aparecer en él** (enunciada por propiedad: *qué clientes puede ver el
  destinatario de un informe*, no una lista de casos); (ii) reflejarlo como **NFR** y como
  criterio de REQ-004; (iii) recogerlo en `docs/seguridad/gobernanza-datos.md`. Mientras no
  exista, **publicar** queda vetado.

### SEC-003 — La traza del ciclo de REQ-004 no permite reconstruirlo entero

- **Clase:** `instrumento` · **Severidad:** media · **Estado:** `abierto`
- **Dueño:** sesión **coordinadora**.
- **Qué falta.** (i) `CHANGELOG.md` **no tiene entrada para la comisión del `qa-tester`**: el
  veredicto `QA: aprobado (2026-09-21)`, la corrida `node --test` 8/8, `docs/qa/REQ-004.md` y
  `docs/usuario/lista-de-clientes-en-el-encabezado.md` no aparecen en la bitácora, que
  `AGENTS.md` §8 y §6 regla 6 exigen por comisión; la última entrada sigue diciendo
  «Pendiente: `qa-tester`». (ii) El **índice** de `requirements/README.md` (línea 423) declara
  REQ-004 `en-progreso` · `QA: pendiente` · `Hallazgos abiertos: QA-004-01`, cuando la cabecera
  del REQ dice `en-revisión` · `aprobado` · `ninguno`. El propio README avisa de que el índice
  es informativo y manda el REQ, así que **no es una contradicción de contrato**, pero sí deja
  la traza desalineada en el mismo día del incidente que la traza debía documentar.
- **Qué sí reconstruye bien la traza, para no exagerar el hallazgo:** el Historial de cambios
  de `requirements/REQ-004.md` (11 filas fechadas, con antes → después y causa) y
  `docs/qa/REQ-004.md` permiten reconstruir **por qué** cambió el comportamiento, quién lo
  decidió y con qué evidencia. El defecto es de **completitud de la bitácora**, no de
  trazabilidad del cambio.
- **Efecto en el cierre:** ninguno (clase `instrumento`, `requirements/README.md`). Se registra
  como deuda con dueño; no reabre ni bloquea la función de negocio.
- **Remedio:** entrada de `CHANGELOG.md` para la comisión de QA y para esta auditoría, y
  actualización del índice.

### SEC-004 — La clasificación insuficiente que causó el incidente sigue viva en REQ ya cerrados que tocan dinero

- **Clase:** `instrumento` · **Severidad:** media-alta · **Estado:** `abierto`
- **Dueño:** sesión **coordinadora** (registro y escalada) + **propietario del proyecto**
  (decisión de reabrir); la facultad de **subir el rigor** es del `auditor-seguridad` y
  permanece intacta.
- **El incidente.** `REQ-004` estuvo `completado` con `QA: aprobado (2026-08-20)` sobre un
  `src/formato.js` que no cumplía **ninguno** de sus dos criterios, y con una cabecera
  (`Sensible a seguridad: no` · `Rigor: estandar` · `Seguridad: n/a`) que prometía **menos
  revisión de la que el efecto exigía**. Lo detectó una revisión posterior, no el proceso.
  **Sí merece un control de gobernanza registrado**, y por dos motivos distintos:
  1. **Ninguna puerta compara un criterio con el código.** `guard-completado` mide veredictos,
     hallazgos, cola y quality gates; en agosto no había pruebas que ligaran CA-01/CA-02 al
     código, así que las quality gates estaban en verde **sobre nada**. El control que faltaba
     es el que hoy sí existe en este REQ: **una prueba automatizada por criterio, que lo cite**
     (`test/formato.test.js`), más la revisión de correspondencia prueba↔criterio que el
     `qa-tester` documentó en `docs/qa/REQ-004.md`. Ese control debería ser **norma escrita del
     proyecto**, no una virtud de esta vuelta.
  2. **La clasificación no se revisa contra el efecto.** `AGENTS.md` §6 declara crítico «todo lo
     que toque dinero o datos de clientes». Con ese criterio en la mano:
     - **`REQ-002` — «Comisión por factura»** (`src/tarifa.js`, el porcentaje que se cobra a
       cada factura) está `completado` con `Sensible a seguridad: no` · `Rigor: estandar` ·
       `Seguridad: n/a`. **Toca dinero de forma directa.** Su clasificación es insuficiente por
       la misma causa que la de REQ-004.
     - **`REQ-001` — «Validación de la fecha de corte»** (decide qué facturas entran en un
       periodo) está en la misma situación, y además tiene una deriva `contrato` ya registrada
       como `D5`.
- **Por qué no lo reclasifico en esta comisión.** Subir el rigor de un REQ ya cerrado **lo
  reabre** (el cierre se emitió sin la ceremonia que ahora se le exigiría), REQ-001 y REQ-002
  quedan **fuera** del alcance de esta comisión, y no los he auditado. Así que **lo declaro y lo
  escalo** (`D7` en `PENDING_APPROVAL.md`) en vez de ejecutarlo por sorpresa — igual que la
  coordinadora hizo con `D5`. **Mi facultad de subirlo no caduca**: si el propietario no decide,
  la ejerceré en una comisión propia sobre esos REQ.
- **Remedio exigido:** (i) control escrito en el proyecto —cada criterio de aceptación con una
  prueba automatizada que lo cite, y verificación explícita de correspondencia antes de firmar
  `QA: aprobado`—; (ii) revisión de la clasificación (`Sensible a seguridad:` / `Rigor:`) de
  todos los REQ contra el criterio de `AGENTS.md` §6, empezando por REQ-002.
- **Efecto en el cierre de REQ-004:** ninguno. Es deuda de proceso con dueño, no un defecto del
  producto entregado por este REQ.

---

## Observaciones (no son hallazgos; se registran para que no se pierdan)

- **O-01 — La omisión de CA-02 es silenciosa y no deja señal.** Si un nombre llega vacío o nulo
  por un fallo de datos aguas arriba, el cliente **desaparece** del encabezado y el resultado
  es, por contrato, «idéntico al que produciría CA-01 sobre la lista sin ellos»: nadie —ni el
  operador ni el destinatario— puede notar que faltó alguien en un documento cuyo propósito es
  decir a quién corresponde el cobro. No abro hallazgo bloqueante porque es el comportamiento
  **contratado** por CA-02 y la frontera del conjunto ya está escalada en `D3`; **recomiendo
  añadir a esa decisión** la pregunta de si la omisión debe dejar traza para quien genera el
  informe. No lo contrato yo.
- **O-02 — El proyecto no tiene ni un solo NFR.** `requirements/README.md` lo dice
  explícitamente. Un proyecto que maneja dinero y nombres de clientes sin ningún requisito no
  funcional escrito no tiene dónde aterrizar un control de seguridad, que es justo lo que
  `AGENTS.md` §9 exige para cerrar un hallazgo. El remedio de `SEC-001` y `SEC-002` crea los
  dos primeros.
- **O-03 — Los bordes escalados siguen midiendo lo reportado.** Confirmado en esta sesión, sin
  convertirlo en criterio: `"   "` y `undefined` **no** se omiten (`"Ana;    ; Marta"`,
  `"Ana; ; Marta"`), los no textuales se **coercionan** (`42` → `"42"`, un objeto →
  `"[object Object]"`, un arreglo anidado → `"B,C"`), y una entrada que no es un arreglo lanza
  `TypeError` genérico. Un matiz para `D3`: la coerción de un valor no textual **ejecuta su
  `toString`**, y un objeto cuyo `toString` devuelve `"X; Y"` produce dos elementos aparentes
  — es la misma familia de `SEC-001`, por si la decisión de `D3` se toma antes que la de
  `SEC-001`.

---

## Estado de seguridad aprobado por REQ (línea base anti-regresión)

> Lo que este auditor da por revisado y en qué estado, para detectar en iteraciones futuras
> que un control **desapareció o se debilitó** aunque el REQ «funcione».

| REQ | Fecha | Veredicto | Controles verificados presentes | Controles ausentes (hallazgo) |
|---|---|---|---|---|
| REQ-004 | 2026-09-21 | `vetado` | Separador exacto «; » sin separador colgante (CA-01); omisión de `""`/`null` sin hueco (CA-02); función **pura**, sin I/O, red, estado ni concurrencia; 8 pruebas que citan su criterio; sin secretos, sin dependencias externas, sin `eval`/deserialización | **Sin** validación de entrada; **sin** codificación de salida (`SEC-001`); **sin** regla de destinatario ni de exposición de nombres de terceros (`SEC-002`); **sin** NFR de ningún tipo |
| REQ-001 | — | `n/a` (no auditado) | — | Clasificación posiblemente insuficiente (`SEC-004`) |
| REQ-002 | — | `n/a` (no auditado) | — | Toca dinero con `Rigor: estandar` y `Seguridad: n/a` (`SEC-004`) |
| REQ-005 | — | `pendiente` | — | Aún no construido; heredará `SEC-001` (mismo encabezado, mismo módulo) |

**Superficie que hoy NO existe en este proyecto**, y por eso no genera hallazgo (revisar si
alguna vez aparece): no hay red, servidor, HTTP, cookies, sesiones, autenticación,
autorización, base de datos, almacenamiento de objetos, dependencias de terceros
(`package.json` inexistente, cero paquetes instalados), secretos, criptografía, subida de
archivos, parseo de XML/SVG, LLM ni herramientas MCP conectadas a este código.
