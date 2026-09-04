# AGENTS.md — {{NOMBRE_PROYECTO}}

> Archivo canónico de contexto y reglas del proyecto (estándar AGENTS.md, leído por
> Claude Code, Codex, Cursor y otros). Cualquier IA que abra el proyecto lo lee primero.
> Para Claude Code, `CLAUDE.md` importa este archivo.

---

## 0. Ritual de inicio y cierre de sesión (leer primero)

**Al iniciar una sesión**, todo agente se orienta leyendo, en orden:
1. `AGENTS.md` (este archivo) — contexto y reglas.
2. `docs/ESTADO.md` — dónde quedamos y cuál es el próximo paso concreto.
3. `requirements/README.md` — qué está pendiente.

**Al cerrar trabajo**, el agente activo debe:
- Actualizar `docs/ESTADO.md` (fase, en progreso, próximo paso, bloqueos).
- Actualizar el `Estado:` de los REQ que cambiaron.
- Registrar en `CHANGELOG.md` (manual si no hay commit; obligatorio si hay commit).

## 1. Qué es este proyecto

{{DESCRIPCION_PROYECTO}}

**Principio rector:** {{PRINCIPIO_RECTOR}}

## 2. Stack

| Capa | Tecnología |
|------|-----------|
| Framework | {{FRAMEWORK}} |
| Lenguaje | {{LENGUAJE}} |
| Autenticación | {{AUTENTICACION}} |
| Hosting | {{HOSTING}} |
| Repo | {{REPO_URL}} |

### Playbooks de plataforma aplicables
<!-- Lista los playbooks de convenciones que aplican a este proyecto. Los agentes
     dev/qa/auditor DEBEN leerlos. Ej: `plugins/ArnesJuan/playbooks/power-apps-dataverse.md` -->
- (ninguno / listar)

## 3. Módulos / alcance

{{TABLA_MODULOS}}

## 4. Permisos

{{MODELO_PERMISOS}}

## 5. Equipo de agentes de IA

4 subagentes especializados (en `.claude/agents/`) + la sesión principal como **coordinadora**.
Los subagentes NO se invocan entre sí; la sesión principal orquesta el bucle y el humano
aprueba cada fase.

> **La sesión coordinadora no edita el código de la app en directo.** Todo cambio de código
> —incluida la **depuración de errores**— se delega en el `desarrollador`; luego `qa-tester`
> valida y `auditor-seguridad` revisa si aplica. La coordinadora orquesta, mantiene el
> pipeline y los quality gates, y pide la aprobación humana; no parchea a mano. Es justo al
> depurar cuando aparece la tentación de "arreglar rápido" saltándose el arnés: no se hace.
>
> 🔒 **La máquina te lo recuerda; no te lo impide del todo.** El hook `guard-codigo` (plugin)
> deniega en runtime cualquier `Edit/Write/MultiEdit` sobre `codigo_app.globs` (de
> `.arnes/config.json`) que no venga del agente `desarrollador`, y también las escrituras
> **evidentes** por `Bash` (redirección `>`/`>>`, `tee`, `cp`/`mv`, `sed -i`, `dd`). La
> coordinadora y los demás subagentes reciben un rechazo con motivo. Es una **barandilla, no
> una jaula**: impide el desvío por descuido, no contiene a quien se empeñe en rodearla
> (alcance y límites reales en §13). Para cambiar qué cuenta como "código de la app", edita
> el manifiesto.

| Agente | Modelo | Responsabilidad |
|--------|--------|-----------------|
| `analista-requerimientos` | Opus | Levanta y documenta requerimientos en `requirements/` |
| `desarrollador` | Opus | Codifica los requerimientos + documentación **técnica**, dueño de `ARCHITECTURE.md` (vista de sistema e integración) |
| `qa-tester` | Sonnet | Prueba el trabajo del desarrollador, corre quality gates, escribe documentación de **usuario final** |
| `auditor-seguridad` | Opus | Revisa seguridad y gobernanza; mantiene `docs/seguridad/`; puede vetar |

Modelo asignado por dificultad y criticidad del rol; ajustable por proyecto.

> Documentación distribuida (no hay 5º agente "documentador"): cada agente documenta su
> rebanada con el contexto vivo, y el `desarrollador` consolida la vista de arquitectura en
> `ARCHITECTURE.md`. Si el proyecto crece y la consolidación pesa, se puede añadir luego un
> agente `documentador` dedicado.

## 6. Orquestación, loops de error y gates humanos

**Flujo:** analista define REQ → desarrollador codifica → qa-tester valida → auditor-seguridad revisa → REQ `completado`.

**El orden no es una sugerencia: es la condición de validez de la firma.** El
`auditor-seguridad` no firma `Seguridad: aprobado` sobre un árbol que el `qa-tester` no ha
validado, porque **no mira las quality gates**: su veredicto acredita la revisión de seguridad,
no que el código funcione. Firmar antes convierte una revisión parcial en un sello de calidad
que nadie emitió. Buscar paralelismo aquí no ahorra tiempo: produce una firma falsa.

> **Excepción nombrada — la auditoría preventiva.** Una revisión de seguridad hecha **antes de
> que exista el código** —sobre el diseño, el modelo de amenaza o el REQ mismo— sí puede ir por
> delante, porque no acredita nada construido. Se declara **al emitirla**, escribiendo
> `Seguridad: preventiva` en el REQ; nunca al invocarla: una excepción que se inventa
> cuando hace falta no es una excepción, es una salida. Esa firma **no** cubre el código
> posterior: cuando el código exista, la auditoría se repite en su turno.

**Loop de error:** si QA o seguridad encuentran fallos, el REQ vuelve al desarrollador.
Máximo **{{MAX_REINTENTOS}}** vueltas dev↔QA **por REQ**, y el contador **NO se reinicia con
cada hallazgo nuevo**. Esto es deliberado: un tope por hallazgo no acota nada, porque cada
arreglo cierra el hallazgo documentado y la vuelta siguiente encuentra una variante. Un REQ
puede pasar semanas en `en-revisión` sin haber gastado nunca tres vueltas del mismo hallazgo.

Agotado el tope, el REQ **no se queda abierto**: o cierra con el residual **declarado**
(dueño, forzador medido y vencimiento) o pasa a `bloqueado` y se escala al humano. La
seguridad puede **vetar** en cualquier momento.

**No todo hallazgo bloquea.** Cada hallazgo abierto declara su clase en el campo
`Hallazgos abiertos:` del REQ — `usuario/dinero`, `contrato` o `instrumento` (tabla completa
en `requirements/README.md`). Sólo las dos primeras impiden cerrar. Un defecto **del propio
arnés** —un lector de umbral, un guardián, una prueba— es `instrumento` y va a deuda técnica
con dueño: atacar guardianes es valioso, pero **no puede ser condición para cerrar una
función de negocio**.

> 🔒 **Cumplido por máquina:** `guard-completado` lee `Hallazgos abiertos:` y deniega el
> cierre si alguno es `usuario/dinero` o `contrato` — y también si alguno **no declara clase**,
> porque entonces la puerta no puede saber si bloquea.

**Nivel de rigor — cuánta ceremonia paga cada REQ.** No todo requerimiento merece el mismo
esfuerzo. Cada REQ declara `Rigor:` en su cabecera: `ligero` (analista + desarrollador +
quality gates), `estandar` (+ QA) o `critico` (+ auditoría de seguridad). Tabla completa en
`requirements/README.md`.

**Qué es crítico EN ESTE PROYECTO:**
{{CRITERIO_RIGOR_CRITICO}}
*(criterios genéricos que suelen aplicar: dinero · datos personales · identidad o acceso ·
documento con efecto legal · cambio irreversible de esquema o borrado. Sustitúyelos por los
ejemplos concretos de este dominio.)*

Lo fija el analista; el auditor **puede subirlo** y nadie lo baja sin su firma. `Sensible a
seguridad: sí` impone `critico` como **suelo**. Si se omite, se deriva del campo de
sensibilidad — exactamente como se juzgaba antes de que existieran los niveles.

> 🔒 **Cumplido por máquina:** `guard-completado` calcula el rigor efectivo y sólo exige
> `Seguridad: aprobado` en `critico`. Un `Rigor: ligero` escrito sobre un REQ sensible **no
> baja nada**: el suelo manda.

**Gates de aprobación humana** — el pipeline se detiene y espera tu visto bueno antes de:
{{GATES_HUMANOS}}
(por defecto: cierre de cada fase, decisiones arquitecturales, y cambios que tocan datos/credenciales de producción).

**Mecanismo de gate:** cuando una acción requiere aprobación, el agente escribe la decisión
pendiente en `PENDING_APPROVAL.md` y **detiene** el pipeline. No continúa hasta que el humano
resuelve (aprueba/rechaza) y limpia esa entrada. Así el bloqueo queda visible y por escrito.

> 🔒 **Vigilado por máquina:** mientras `PENDING_APPROVAL.md` tenga entradas en "## Pendientes",
> el hook `guard-completado` (plugin) deniega marcar cualquier REQ como `completado`. El avance
> no depende de que el modelo "recuerde" detenerse — con el alcance real descrito en §13.

**Gates por fase (patrón tipo SPARC):** cada fase del roadmap tiene una puerta explícita —
no se entra a la fase siguiente hasta cumplir el criterio de terminado de la actual + tu visto
bueno. Las fases no se solapan en silencio.

**Control de costo:** modelo por dificultad (arriba) + el límite de reintentos + el criterio de
terminado (evita trabajo de más). Presupuesto del proyecto: {{PRESUPUESTO}}. El músculo de
medición de tokens en runtime es opcional vía MCP (ver `.mcp.json.example`); el arnés no
depende de él.

**Observabilidad (en archivos, no en infra):** la traza del proyecto vive en archivos legibles
— `CHANGELOG.md` (qué cambió, quién, qué modelo), `docs/seguridad/registro-seguridad.md`
(hallazgos) y `docs/ESTADO.md` (dónde vamos). Esa es la observabilidad por defecto; un backend
de trazas/métricas es opcional vía MCP.

## 7. Quality Gates

Señales automáticas de verdad. El `qa-tester` las usa como fuente de verdad antes de aprobar:

{{QUALITY_GATES}}

(por defecto, para stack Node/TS: `npm run typecheck`, `npm run lint`, `npm run build`, `npm test`)

Un REQ no pasa a `completado` si alguna puerta falla.

Las **pruebas automatizadas** son parte de cada REQ: las escribe el `desarrollador` y el REQ
no pasa a `en-revisión` sin ellas. El tipo (unitarias/integración/e2e) y la cobertura mínima
se fijan por proyecto; si no se definieron, se usa el estándar del stack.

> 🔒 **Vigilado por máquina:** el hook `guard-completado` (plugin) corre las quality gates de
> `.arnes/config.json` justo antes de aceptar la transición de un REQ a `completado` y la
> **deniega** si alguna falla (alcance real en §13). Mantén la lista de gates idéntica aquí y
> en el manifiesto.

## 8. CHANGELOG — reglas

Cada entrada en `CHANGELOG.md` lleva: fecha, **Origen** (`GitHub` = commit / `Interno` = manual),
usuario, modelo de IA, agente(s) y detalle. Todo commit DEBE actualizar `CHANGELOG.md` en el
mismo commit (lo exige el hook `pre-commit`).

## 9. Cambios de requerimientos (versionado y deriva)

**PRINCIPIO:** un requerimiento NO se reescribe encima. Se **versiona** dejando rastro del
antes, el después y, sobre todo, el **PORQUÉ** (enlazado a su causa: `SEC-xxx`, un NFR, un
cambio de legislación, una limitación detectada en pruebas, un parche de dependencia, etc.).

- **Cambio MENOR** (ajusta un criterio o un detalle): edita el REQ y registra en su
  **Historial de cambios**: fecha, qué cambió (antes → después) y la causa. Añade entrada en
  `CHANGELOG.md`.
- **Cambio DE FONDO** (cambia el alcance, la decisión base o el significado del REQ): crea un
  **ADR nuevo** (contexto, qué cambió y por qué, decisión, consecuencias); el REQ se actualiza
  y **enlaza** a ese ADR. Mismo patrón que un `ADR-005` que supersede al `ADR-003`.
- **DERIVA** (el código terminó distinto de lo que dice el REQ): **no se deja en silencio**. Se
  actualiza el REQ para reflejar la realidad implementada, con su trazabilidad y causa; si el
  desvío fue de fondo, además un ADR.
- **CAMBIOS POR HALLAZGO** (un hallazgo de QA o de seguridad obliga a cambiar comportamiento o a
  añadir un control): es la deriva más común en este arnés, porque los agentes hallan cosas por
  diseño. El hallazgo **no se cierra** hasta que el requerimiento lo refleje — un **criterio de
  aceptación** nuevo (hallazgo de QA) o un **NFR** nuevo/actualizado (hallazgo de seguridad) —,
  con la causa enlazada al hallazgo y un ADR si es de fondo. Un hallazgo resuelto solo en el
  código o en un log (`docs/qa/…`, `registro-seguridad.md`) es deriva. El `analista-requerimientos`
  hace el write-back; el `qa-tester` y el `auditor-seguridad` no dan su veredicto `aprobado`
  (campos `QA:`/`Seguridad:` del REQ) hasta que existe.
- **REGLA DE ESTADO:** cuando un REQ ya `completado` cambia, vuelve a `en-progreso` o
  `en-revisión` y **re-recorre el ciclo** (dev ajusta → QA re-valida contra los criterios
  nuevos → seguridad revisa). Un cambio de requerimiento **reabre** el trabajo; no es solo
  editar texto.

## 10. Convenciones de trabajo

- Idioma de documentación y comunicación: **español**.
- No introducir abstracciones ni features fuera del alcance del REQ en curso.
- Secretos solo en variables de entorno; nunca en el código ni en el cliente.
- Al cerrar trabajo: actualizar el REQ, el CHANGELOG y, si aplica, un ADR en `docs/decisions/`.
- **ADRs (decisiones de arquitectura):** toda decisión técnica significativa se registra como
  un ADR usando la plantilla del arnés (`templates/ADR.md.tpl`). No se borran; si una decisión
  se revierte, se crea un ADR nuevo que supersede al anterior.

## 11. Entrega

El proyecto no se considera cerrado hasta generar `DELIVERY.md` (artefacto de cierre:
resumen ejecutivo, changelog consolidado, estado de docs, módulos entregados, handoff)
y obtener la aprobación del destinatario.

## 12. Mapa de carpetas

```
AGENTS.md              ← este archivo (canónico, cross-tool)
CLAUDE.md              ← importa AGENTS.md (Claude Code)
CHANGELOG.md           ← bitácora de cambios
requirements/          ← requerimientos (el contrato)
docs/
  ESTADO.md            ← tablero de continuidad
  PLAN.md              ← plan maestro
  decisions/           ← ADRs
  seguridad/           ← gobernanza-datos.md + registro-seguridad.md
  usuario/             ← documentación de usuario final
  qa/                  ← hallazgos de QA por REQ (artefacto persistente)
DELIVERY.md            ← artefacto de cierre (al entregar)
.arnes/config.json     ← manifiesto machine-readable (lo leen los hooks de enforcement)
.claude/agents/        ← definiciones de los 4 agentes (del plugin)
memory/                ← memoria/preferencias (no versionar secretos)
```

## 13. Enforcement por runtime (hooks del plugin)

Las invariantes de este documento que no se quedan en la prosa las vigila la máquina, vía hooks
`PreToolUse` del plugin, que leen `.arnes/config.json`.

| Invariante | Sección | Hook | Herramientas cubiertas |
|------------|---------|------|------------------------|
| La coordinadora no edita código de la app (sólo el `desarrollador`) | §5 | `guard-codigo` | `Edit`/`Write`/`MultiEdit` + `Bash` (parcial) |
| No completar un REQ con aprobaciones pendientes | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| No completar un REQ con quality gates en rojo | §7 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| No completar con un hallazgo `usuario/dinero` o `contrato` abierto —ni con uno **sin clase** | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| El rigor se puede subir, nunca bajar: `Sensible a seguridad: sí` impone `critico` | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| No completar sin `QA: aprobado` (salvo `Rigor: ligero`), ni un REQ `critico` sin `Seguridad: aprobado` | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| La transición a `completado` no se hace por shell | §6 | `guard-completado` | `Bash` (parcial) |
| Seguridad no firma lo que QA no ha validado (salvo `Seguridad: preventiva`) | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |

**Es una barandilla, no una jaula.** El hook impide que el modelo **se desvíe por descuido**;
no contiene a un agente decidido a rodearlo. Concretamente:

- **Un comando Bash de lectura no arranca el guardián.** Cada handler lleva un `if` que Claude Code
  evalúa antes de crear el proceso; sólo las formas de escritura conocidas llegan al hook. Lo que
  ese filtro no desenvuelve —`npx`, `docker exec`, `bash -c`, `xargs -n1`— queda fuera, y se dice.
- **`Bash` sólo está cubierto en parte, y las dos puertas comparten esa cobertura.** Ambos
  guardianes usan el mismo detector de escrituras (redirección `>`/`>>`, `tee`, `cp`, `mv`,
  `install`, `sed -i`, `perl -i`, `dd of=`). Quedan fuera, **a propósito**, los scripts, **los
  intérpretes** —`node script.mjs`, `python x.py`: la ruta vive dentro del archivo y el
  detector sólo lee el texto del comando; es el agujero más grande de los que quedan—, los
  heredocs indirectos, los formateadores que reescriben archivos (`prettier --write`,
  `eslint --fix`), `patch`/`git apply` y cualquier programa que escriba por su cuenta. Un hook
  no puede analizar shell arbitrario de forma fiable, y perseguirlo produce falsos positivos
  que acaban con alguien desactivando el guard: un guard apagado protege menos que uno parcial.
- **`guard-completado` sí mira `Bash`, pero no lo juzga: lo DERIVA.** Un comando que escribe en
  `requirements/` y menciona el estado terminal se deniega pidiendo que la transición se haga
  con `Edit`/`Write`, que es donde el hook puede ver el contenido resultante y evaluar
  veredictos, cola y quality gates. Reimplementar esas puertas para la shell sería una segunda
  transcripción de la misma regla, y dos transcripciones se desfasan.
  Dentro de esa vía la detección del estado terminal es **deliberadamente ancha** —lo busca en
  cualquier parte del comando, no como `estado:` seguido del valor—, porque la forma más natural
  de cerrar un REQ por shell sustituye el **valor** y no escribe nunca la palabra «Estado».

**Otro que tampoco decide: la rotación.** Un artefacto de bitácora —`CHANGELOG.md`, el registro
de seguridad— crece sin tope, y todo lo que crece sin tope acaba entrando entero en la ventana
de contexto. Con `rotacion.activo: true`, al parar un agente el arnés **mueve** las secciones
sobrantes a `<nombre>-archivo.md` y deja un puntero. **Mueve; no resume** — un resumen
convertiría la bitácora en la versión que el modelo recuerda de ella. Viene apagada.

**Un hook que no decide nada: la continuidad.** Al parar un agente (`Stop` / `SubagentStop`),
el arnés reescribe en `docs/ESTADO.md`, entre marcadores, un bloque **derivado** del disco:
estado y veredictos de cada REQ, cola de aprobaciones, rama y limpieza del árbol. No permite ni
impide nada — existe porque **un resumen redactado por el modelo miente justo cuando más falta
hace**, que es cuando le queda poco contexto. Por eso no se redacta: se deriva, y cada línea
sale de leer un archivo. Nunca bloquea la parada, no toca nada fuera de los marcadores, y se
apaga con `estado_derivado.activo: false`.

La consecuencia práctica: el enforcement por runtime es la última red, no la primera. La regla
sigue siendo la de §5, y saltársela por otra vía es un incumplimiento aunque ningún hook grite.

**Anti-deriva — el techo honesto:** la máquina puede impedir que un REQ se cierre con la
validación/auditoría pendientes (campos `QA:`/`Seguridad:`), pero **no** puede verificar que el
requerimiento describa *semánticamente* lo construido. Esa reconciliación es responsabilidad del
write-back (§9) y se verifica al cierre: `/arnes-close` comprueba la **trazabilidad y no-deriva**
de cada REQ `completado` antes de generar `DELIVERY.md`.

Si `.arnes/config.json` no existe, los hooks son **inertes** (no estorban). Requieren `jq`;
sin él, el enforcement queda inactivo con aviso (no bloquea). El changelog sigue cubierto por
el hook `pre-commit` de git (§8).

**Nombre del agente en el manifiesto:** basta el nombre corto (`desarrollador`). El hook tolera
el prefijo del plugin que Claude Code añade en runtime (`arnes-juan:desarrollador`), así que no
hay que escribirlo. Escribirlo es opcional y hace la comparación **estricta**: `agentes.agente_codigo`
con prefijo sólo acepta a ese proveedor, útil si conviven dos plugins con un agente homónimo.
