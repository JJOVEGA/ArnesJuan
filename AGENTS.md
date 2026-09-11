# AGENTS.md — ArnesJuan

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

Plugin de Claude Code: un arnés de cuatro agentes (analista, desarrollador, QA, auditor de seguridad) con enforcement por hooks (`PreToolUse`, `Stop`), quality gates, trazabilidad y continuidad derivada del disco. Lo usan proyectos reales; sus informes de defectos llegan por canal privado y este repositorio, que es público, describe el arnés y nunca los hallazgos de un cliente.

**Este repositorio se desarrolla a sí mismo (autoalojamiento controlado).** La versión estable instalada del plugin —la que corre los hooks de esta sesión— gobierna el desarrollo de la siguiente. La versión que se está modificando nunca es su propio guardián durante esa misma ejecución. El procedimiento completo vive en `docs/gobernanza/autoalojamiento.md`.

**Principio rector:** el arnés trae el mecanismo, nunca el mapeo; una puerta que no puede medir no deja pasar; y la versión N gobierna el desarrollo de N+1.

## 2. Stack

| Capa | Tecnología |
|------|-----------|
| Framework | Plugin de Claude Code (hooks, agentes, skills, plantillas) |
| Lenguaje | Bash (sin procesos donde se pueda: cada fork cuesta 1,2–6 s en Windows/MSYS), jq, awk; PowerShell sólo en pruebas de integración |
| Autenticación | n/a — no hay usuarios finales. `gh` con dos cuentas: `jvega-habitat` (push, sin admin) y `JJOVEGA` (dueño; rulesets) |
| Hosting | GitHub `JJOVEGA/ArnesJuan` (público) · marketplace del plugin (`.claude-plugin/marketplace.json`) |
| Repo | https://github.com/JJOVEGA/ArnesJuan |

### Playbooks de plataforma aplicables
<!-- Lista los playbooks de convenciones que aplican a este proyecto. Los agentes
     dev/qa/auditor DEBEN leerlos. Ej: `plugins/ArnesJuan/playbooks/power-apps-dataverse.md` -->
- (ninguno / listar)

## 3. Módulos / alcance

| Módulo | Qué es | Quién lo edita |
|---|---|---|
| `hooks/` | El mecanismo: `guard.sh` (PreToolUse: identidad, cierre), `stop.sh` (continuidad, rotación), `lib.sh` | **Sólo el `desarrollador`** (`codigo_app.globs`) |
| `tools/` | Informes que leen con el mismo lector que los hooks (`arnes-lectura.sh`) | **Sólo el `desarrollador`** |
| `.github/workflows/` | CI: bits de ejecución + banco completo en Linux; puerta requerida de `main` | **Sólo el `desarrollador`** |
| `tests/escenarios/hooks/run.sh` | El banco: 23+ secciones, casos deny/allow, canario, cuadre | `desarrollador` y `qa-tester` |
| `templates/`, `skills/`, `agents/`, `playbooks/` | Andamiaje que `arnes-init`/`arnes-upgrade` llevan a los proyectos | Cualquier agente; documentación técnica del `desarrollador` |
| `docs/` | Gobernanza, experimentos, pendientes, seguridad, QA | Coordinadora y agentes según su rebanada |
| `.claude-plugin/` | Versión del plugin y marketplace | `desarrollador` en el commit de versión |

## 4. Permisos

- Repositorio **público**: describe el arnés, nunca los hallazgos de un cliente. Los documentos `mejoras-arnes-*.md` e `insumos/` están en `.gitignore` y no se citan literalmente.
- `main` protegido por el ruleset `proteger-main`: **todo por PR**, sin push directo, con el check `hooks-en-linux` **requerido y estricto**.
- La fusión a `main`, el tag de versión y la publicación son decisiones **humanas**, **delegadas** a la coordinadora por el propietario (2026-09-05) cuando todo está en verde; cualquier rojo o hallazgo abierto las devuelve al humano (§6 y `docs/gobernanza/autoalojamiento.md`). La instalación estable se actualiza después de publicar y verificar.
- El manifiesto `.arnes/config.json` de este repo es el mapeo del arnés sobre sí mismo: `hooks/`, `tools/` y `.github/` son código protegido.

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
| `qa-tester` | **Opus** (sólo aquí; ver abajo) | Prueba el trabajo del desarrollador, corre quality gates, escribe documentación de **usuario final** |
| `auditor-seguridad` | Opus | Revisa seguridad y gobernanza; mantiene `docs/seguridad/`; puede vetar |

Modelo asignado por dificultad y criticidad del rol; ajustable por proyecto.

> 🔒 **QA corre con Opus en el autoalojamiento (decisión del propietario, 2026-09-05).** Aquí el
> `qa-tester` no valida una función de negocio: valida **el mecanismo que gobierna a todos los demás
> proyectos**, e intenta romperlo. Se lanza con el modelo **Opus**, por encima del `sonnet` que
> declara el agente.
>
> **Cómo se aplica, y por qué así:** con el parámetro `model` de la herramienta `Agent` al despachar
> el subagente, que tiene precedencia sobre el frontmatter. **No** se edita `agents/qa-tester.md` del
> plugin: ese archivo lo heredan todos los proyectos que instalan el arnés, y esta decisión es de
> este repositorio, no suya. Misma frontera que el resto de la política de autoalojamiento.

> Documentación distribuida (no hay 5º agente "documentador"): cada agente documenta su
> rebanada con el contexto vivo, y el `desarrollador` consolida la vista de arquitectura en
> `ARCHITECTURE.md`. Si el proyecto crece y la consolidación pesa, se puede añadir luego un
> agente `documentador` dedicado.

## 6. Orquestación, loops de error y gates humanos

**Flujo:** analista define REQ → desarrollador codifica → qa-tester valida → auditor-seguridad revisa → REQ `completado`.

> 🔒 **ALIGERADA por decisión expresa del propietario el 2026-09-10, con aplicación inmediata:** la
> vía de cada cambio se elige por su **efecto** y no por la extensión del archivo, y una reparación con
> causa y contrato claros ya **no** abre comisión de analista. Sede única de la enmienda, con sus cinco
> límites: `docs/gobernanza/autoalojamiento.md` § «Enmienda: autoalojamiento aligerado». **Cambia cómo
> desarrollamos este repositorio; no cambia nada de lo que reciben los proyectos.** Lo que sigue es el
> régimen del 2026-09-05, vigente en todo lo que la enmienda no toca.
>
> 🔒 **Política de autoalojamiento (sólo este repositorio; no se propaga a las plantillas).** Para el
> desarrollo de ArnesJuan, **todo REQ pasa por analista, desarrollador, QA y auditor de seguridad
> antes de llegar a la aprobación humana**, en ese orden. Todo REQ se declara por defecto
> `Rigor: critico` y `Sensible a seguridad: sí`, con `QA: pendiente` y `Seguridad: pendiente` al
> nacer: cualquier cambio puede alterar el mecanismo que controla a los demás proyectos. Una
> excepción editorial —una errata, un texto sin efecto en la máquina ni en lo que los proyectos
> heredan— sólo puede bajar ese nivel con **autorización expresa del propietario (Juan)**, nunca
> por reclasificación automática de un agente. El coordinador reúne la evidencia y, **con todo en verde** (CI sin FAIL, SKIP explicados,
> fail-before/pass-after, QA y auditor aprobados), **fusiona, etiqueta y publica por delegación
> permanente del propietario (2026-09-05)**; cualquier rojo o hallazgo abierto devuelve la decisión a Juan. Procedimiento completo en `docs/gobernanza/autoalojamiento.md`.

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

**Despacho en paralelo: sólo lo que la máquina declara disjunto, nunca por intuición.** La
coordinadora **sólo** despacha comisiones en paralelo sobre REQ que `tools/arnes-paralelo.sh`
declare **disjuntos** por su campo `Archivos:` (forma y fail-closed en `requirements/README.md`), y
**nunca** por intuición. Un despacho paralelo sin esa comprobación es lo que produce **conflictos de
fusión y trabajo perdido**. Medido: el ciclo 2 corrió casi entero en serie —tiempo de reloj ≈ tiempo
de agente— no porque una regla lo prohibiera, sino porque nadie podía afirmar sin adivinar qué dos
comisiones no iban a pisarse; y adivinar bien tres veces y mal la cuarta cuesta más que la serie.

> **Necesaria y no suficiente: un `disjunto` no se toma por bueno sobre un campo decorado.** La
> instrucción de arriba no se relaja —preguntar sigue siendo obligatorio—, pero mientras el hallazgo
> **SEC-020** del propio arnés siga abierto (`contrato`, ventana 1.33.0) la herramienta puede
> responder `disjunto` con rc 0 sobre un mapa corrompido: cuando el campo `Archivos:` lleva el marcado
> de Markdown **elemento por elemento** —`` `a.sh`, `b.sh` `` o `_a.sh_, _b.sh_`— el desenvoltorio
> arranca un par de marcadores que pertenece a **dos elementos distintos** y sustituye las rutas
> declaradas por otras que no existen. De ahí las dos consecuencias operativas: las rutas del campo se
> declaran **sin decoración** (`requirements/README.md`), y un `disjunto` sobre un campo decorado no
> autoriza nada — se limpia el campo y se vuelve a preguntar. Una herramienta con un fail-open abierto
> da condición **necesaria**, no suficiente.

**Lo que NO se paraleliza, con su motivo — no es una lista suelta:**
1. **El `auditor-seguridad` nunca antes ni a la vez que el `qa-tester` sobre el mismo REQ**, porque
   su firma acreditaría un árbol sin validar: convierte una revisión parcial en un sello de calidad
   que nadie emitió. Única salida, y declarada al emitirla: `Seguridad: preventiva`.
2. **El `qa-tester` nunca antes que el `desarrollador` sobre el mismo REQ**, porque validaría un
   árbol que todavía no contiene aquello que dice validar.
3. **Dos comisiones que tocan el mismo archivo**, aunque sean de fases distintas: un conflicto de
   fusión no sabe de fases, sabe de líneas.

Las dos primeras son de **orden de fases** y no se relajan **en ningún caso**: son la condición de
validez de la firma, no una preferencia de calendario. `tools/arnes-paralelo.sh` **no las
comprueba** —responde sobre archivos, y lo dice en su propia salida—, así que un `disjunto` nunca es
permiso para saltárselas.

**Loop de error:** si QA o seguridad encuentran fallos, el REQ vuelve al desarrollador.
Máximo **3** vueltas dev↔QA **por REQ**, y el contador **NO se reinicia con
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
- **Crítico:** todo cambio en `hooks/`, en `tools/` que compartan lector con los hooks, en `hooks.json`, en el banco que los certifica (`tests/`), en el workflow de CI o en el ruleset. Son el mecanismo que gobierna a otros proyectos: un fallo en abierto aquí es un fallo en abierto en todos ellos, y en silencio.
- **Estándar:** plantillas, skills, agentes, playbooks y documentación que los proyectos heredan por `arnes-upgrade`.
- **Ligero:** redacción sin efecto en la máquina ni en lo que los proyectos heredan (README, CHANGELOG, docs de gobernanza).
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
- fusionar cualquier PR a `main` (siempre humano, aunque el CI esté en verde);
- publicar una versión (tag `vX.Y.Z`) y actualizar la instalación estable del plugin;
- cambiar el ruleset, el workflow de CI o el manifiesto `.arnes/config.json` de este repo;
- cualquier cambio en `hooks/` (el mecanismo): se trata como crítico por definición.
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
terminado (evita trabajo de más). Presupuesto del proyecto: sin tope fijo; anotar en el REQ los tokens por agente cuando una comisión pase de ~200 k, y preferir un guardián a un párrafo. El músculo de
medición de tokens en runtime es opcional vía MCP (ver `.mcp.json.example`); el arnés no
depende de él.

**Observabilidad (en archivos, no en infra):** la traza del proyecto vive en archivos legibles
— `CHANGELOG.md` (qué cambió, quién, qué modelo), `docs/seguridad/registro-seguridad.md`
(hallazgos) y `docs/ESTADO.md` (dónde vamos). Esa es la observabilidad por defecto; un backend
de trazas/métricas es opcional vía MCP.

## 7. Quality Gates

Señales automáticas de verdad. El `qa-tester` las usa como fuente de verdad antes de aprobar:

- `for f in hooks/*.sh tools/*.sh; do bash -n "$f" || exit 1; done` — sintaxis de todo el mecanismo.
- `jq -e . hooks/hooks.json >/dev/null` — el registro de hooks es JSON válido.
- `jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null` — versión y marketplace válidos.
- **El banco completo (`tests/escenarios/hooks/run.sh`) corre en CI, no como gate del hook:** en Windows dura ~30 min y un hook `PreToolUse` muere a los 60 s, y un hook muerto no deniega. En Linux dura segundos y es la puerta requerida de `main` (`hooks-en-linux`). Antes de pedir la fusión, el banco tiene que estar en verde en CI y correrse entero al menos una vez en la plataforma del desarrollador.

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
| **Seguridad no firma lo que QA no ha validado, tampoco cuando la línea `QA:` no llega a declararse: la ausencia se trata como no validado y se deniega nombrando el campo** (salvo `Seguridad: preventiva`), y **deniega en los DOS estados de `campos.ausencia_exige`** — el orden de las fases es «la condición de validez de la firma» (§6), no una opción de proyecto. **La salida es pasar por la revisión de QA y escribir el veredicto que ÉSA emita**, con su evidencia; escribir `QA: aprobado` para desatascar la edición, **sin la validación detrás, es exactamente el fallo que esta guarda existe para impedir** — y la otra salida, cuando todavía no hay código que validar, es declarar la auditoría como `Seguridad: preventiva`. **Y la celda declara sobre QUÉ se ENTRA el acto:** esta guarda juzga la firma que el **LECTOR** lee como el campo `Seguridad:` —conjunto de formas cuyo sitio único es el lector (`hooks/lib.sh`), citado y no enumerado—; una línea que una persona lee como esa firma y el lector no, esta guarda **NO la juzga**, y QUÉ le ocurre lo decide el **LECTOR** y no la vista: si el lector la clasifica como **desfase** —no la lee como el campo, pero su plegado sí devuelve la clave— el arnés **AVISA sin denegar**; si ni siquiera eso, esta guarda la deja pasar **SIN aviso**. **Y qué ocurre después NO lo decide esta guarda, ni es UNA sola cosa:** parte de esas líneas las coge la **guarda de medibilidad**, que **deniega citando la línea**; el resto llega al cierre como **campo no declarado**, donde manda la **dirección de la ausencia**, que **no siempre deniega** — medido: una clave con un **homóglifo** deja **CERRAR** el REQ por debajo de `critico`, que es donde el cierre exige esa firma. Frontera declarada y **abierta**: su clase, su dueño y su vencimiento viven en `docs/seguridad/registro-seguridad.md` (**SEC-084**), y la propiedad que sí se garantiza está en `REQ-024 CA-13` | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Los campos del REQ valen sólo en la cabecera: una línea igual dentro de una sección no es un veredicto | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Lo que vive dentro de un `<!-- … -->` de la cabecera **no declara campo**; un rango que abre y no cierra en la cabecera no la deja medir y no deja cerrar | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Una línea de la cabecera que la máquina **no puede medir** no deja cerrar **dentro de lo que la guarda alcanza (acotado en esta misma celda; hay vías medidas que hoy PERMITEN)** — la propiedad es el **estado**, no el carácter: la línea lleva dentro algo que nadie ve en el diff y que cambia lo que el lector resuelve, así que una persona lee ahí un campo y la máquina no lo lee como ese campo (o el carácter le **fabrica** un delimitador). Se **deniega** citando **esa línea** y lo insertado en forma **imprimible** (`\xNN`), aunque los veredictos estén en verde. **La promesa está acotada a lo que la guarda alcanza, y la acota una propiedad y no una lista:** retirado de la clave lo ajeno al alfabeto de las claves **y después todos sus blancos**, **si lo que queda es una clave del lector leída también sin sus blancos** la línea no se puede medir, se deniega y **no** se permite por **ausencia** del campo que ese carácter borró; si esa reconstrucción **no** devuelve ninguna clave —porque lo retirado **sustituía una letra**, y reponer *qué* letra exigiría **elegir entre candidatos**— la guarda **calla** y la puerta resuelve por **ausencia**. El **retorno de carro** que no termina la línea es una **instancia**, no la definición; también lo son un BOM (`\xef\xbb\xbf`, el que PowerShell añade al redirigir), un espacio de anchura cero, un byte de control C0, un multibyte partido y un **blanco de más o puesto en el sitio de otro** (`Sensible a  seguridad`). La clase **no** se cierra con una lista de caracteres: retirado de la clave lo ajeno al alfabeto de las claves **y después todos sus blancos**, **si lo que queda es una clave del lector leída también sin sus blancos**, alguien insertó algo dentro. **Y lo que la guarda NO alcanza va nombrado aquí, no en otro documento** — ejemplo **no exhaustivo**: la **sustitución de una letra de la clave por un homóglifo** (`Еstado`, con la `Е` cirílica) **permite, y permite por ausencia** del campo que el homóglifo borró; **ninguna** versión lo deniega, **tampoco 1.34.0**. Tres fronteras **deliberadas**, lista **no exhaustiva**: el CR/LF **final** es transporte (CRLF decide igual que LF), el **cuerpo** del REQ no se restringe y **reabrir** no se bloquea. Sitio único de las vías abiertas y de las fronteras, con su evidencia, clase, dueño y vencimiento: `docs/seguridad/registro-seguridad.md` § **R-024** — **SEC-078** (la vía) y **SEC-079** (la promesa medida falsa) | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Un veredicto lleva fecha y no es anterior al último cambio del código —si el proyecto lo pide (`veredictos.*`, apagado por defecto) | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Ningún agente —tampoco la coordinadora— ejecuta git destructivo: `clean -f`, `reset --hard`, `checkout .`, `restore .`, `stash` (`git.prohibidos`) | §10 | `guard-git` | `Bash` |

**Un hook que avisa sin decidir.** Al escribir `QA:` o `Seguridad:` con un valor fuera del
vocabulario (`pendiente` \| `aprobado` \| `con-hallazgos`; y en seguridad además `n/a`,
`preventiva`, `vetado`), el arnés lo dice **en ese momento** con un mensaje a la persona y
**no deniega** la edición. **Y el aviso lleva su condición, porque la consecuencia sobre el
cierre NO es incondicional:** lo que la decide es el **rigor efectivo**, y su umbral **no es el
mismo para las dos claves** — un `QA:` fuera de vocabulario impide cerrar en `estandar` y en
`critico`, pero **no** en `ligero`, que no pide veredicto de QA y no juzga su valor; un
`Seguridad:` fuera de vocabulario impide cerrar **sólo** en `critico`. Por debajo de su umbral
el REQ **cierra** con un veredicto que no es ninguno del vocabulario, y la llave
`campos.ausencia_exige` **no mueve** ninguna de esas seis celdas: ahí el campo **está**
declarado. Escrita sin esa condición —«*ese REQ no podrá cerrarse*»— esta promesa quedó
**medida falsa en 4 de las 6 celdas** de su reproducción (los dos estados de la llave por los
tres rigores) y hacia el lado que **tranquiliza**, que es la familia de `SEC-079`
(`QA-024-38`). Donde el umbral sí se alcanza, sin el aviso nadie lo sabría hasta el cierre.
**El arnés avisa además cuando una línea PARECE el campo y el lector no la lee como tal**
(`qa: aprobado`, en minúscula): ahí el campo queda **sin declarar** y el eje **cambia con la
clave** — para `QA:` lo resuelve `campos.ausencia_exige` (**apagada, como nace un proyecto**,
el REQ cierra sin veredicto de QA; encendida, el cierre se deniega en los tres rigores) y para
`Seguridad:` lo sigue resolviendo el **rigor**; el mensaje dice en cuál de los dos estados está
la llave **aquí**, porque declarar los dos no sirve si quien lee no sabe en cuál está. Ninguno
de estos avisos decide nada: lo que esa misma edición tenga de denegable lo resuelven las
guardas de la tabla —la del **orden de las firmas** deniega si emite `Seguridad: aprobado`
sobre un REQ cuyo `QA:` no llega a declararse, y la salida es **pasar por QA**, no rellenar el
campo—. Un matiz va entre paréntesis (`aprobado (R-045, 2026-09-01)`); un veredicto
distinto es **otro valor**, no un paréntesis. Es la única vía documentada para avisar sin
bloquear: `ask` detendría la llamada.

**Las celdas de veredicto del bloque derivado salen recortadas a 40 caracteres.** Es
presentación: la puerta y `tools/arnes-lectura.sh` leen el valor entero. Un bloque de
continuidad en el que cuatro veredictos largos ocupan un tercio —y rompen la tabla— deja
de servir para lo único que existe.

**La invariante manda sobre cualquier preferencia de herramienta.** Si una preferencia de sesión
—una instrucción de estilo, una costumbre, un ajuste de configuración— empuja a hacer por la
**consola** lo que las herramientas de edición hacen, esa preferencia **cede**: las puertas de
este documento están cableadas a `Edit`/`Write`/`MultiEdit`, y sobre `Bash` la cobertura es
**parcial a propósito** (arriba). Preferir la consola no es una opinión sobre estilo: **apaga
una puerta**. Y nace medido —una preferencia por la consola desactivó un guardián sin que nadie
relacionara las dos cosas—, así que va escrito aquí y no en la cabeza de nadie:
**quien configura una sesión no suele ser quien lee esta sección**. Regla operativa: para tocar un
archivo que alguna invariante protege se usan las herramientas de edición; si hace falta la
consola, se dice **por qué** y se asume que ninguna puerta lo va a medir.

**Es una barandilla, no una jaula.** El hook impide que el modelo **se desvíe por descuido**;
no contiene a un agente decidido a rodearlo. Concretamente:

- **Todo comando Bash pasa por el guardián, aunque sea un `ls`.** 1.25.0 intentó filtrar con `if` para
  ahorrar el proceso, y `if` no ve redirecciones: `echo x > archivo` rodeó las dos puertas hasta 1.27.0.
  Una puerta lenta protege; una que no se invoca, no. El coste se acepta.
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
  **Y ancha no es infalible, y está medido:** esa detección lee el **texto crudo del comando**, así
  que partir la palabra del estado terminal entre dos expansiones dentro de un heredoc sin citar la
  evade, y el archivo queda escrito. Ensanchar el patrón cubriría esa forma y no la clase —una
  variable, `printf`, `base64 -d` o un intérprete la reproducen—: es una pregunta abierta y no se
  gana. La respuesta es la **puerta posterior**, que deja de preguntar antes si un comando escribe y
  pregunta después si algo protegido cambió. Hasta que exista, esta vía es exactamente lo que dice
  ser: una barandilla contra el descuido, no contra la ofuscación deliberada.

**Otro que tampoco decide: la rotación.** Un artefacto de bitácora —`CHANGELOG.md`, el registro
de seguridad— crece sin tope, y todo lo que crece sin tope acaba entrando entero en la ventana
de contexto. Con `rotacion.activo: true`, al parar un agente el arnés **mueve** las secciones
sobrantes a `<nombre>-archivo.md` y deja un puntero. **Mueve; no resume** — un resumen
convertiría la bitácora en la versión que el modelo recuerda de ella. Viene apagada.
También puede archivar **una sección** de un documento —típicamente la historia de un REQ— a
`historial/<nombre>.md`, dejando **el resto intacto**: la cabecera con sus veredictos y los
criterios de aceptación no se tocan nunca, porque son el contrato. Qué sección es historia lo
declara este proyecto en `rotacion.artefactos` (`glob` + `seccion`); el arnés no trae ninguna por
defecto, y el nombre se compara **exacto**, nunca por prefijo.

**Un hook que no decide nada: la continuidad.** Al parar un agente (`Stop` / `SubagentStop`),
el arnés reescribe en `docs/ESTADO.md`, entre marcadores, un bloque **derivado** del disco:
estado y veredictos de cada REQ, cola de aprobaciones, rama y limpieza del árbol. No permite ni
impide nada — existe porque **un resumen redactado por el modelo miente justo cuando más falta
hace**, que es cuando le queda poco contexto. Por eso no se redacta: se deriva, y cada línea
sale de leer un archivo. Nunca bloquea la parada y se apaga con
`estado_derivado.activo: false`. **Y sobre el texto que hay fuera de los marcadores, las dos
mitades — porque una se afirmó sin condición y estaba medida falsa.** *Sí:* fuera de los
marcadores no se modifica nada; si eso no se puede **leer** no se escribe nada y se avisa; y
cada parada publica por un temporal **propio de su proceso** y lo mueve encima, así que dos
paradas simultáneas no comparten archivo (hasta 1.32.0 el temporal tenía **nombre fijo** y por
ahí se perdió texto humano **1 de 25** vueltas del banco; cerrado en 1.32.1, REQ-015). *No:*
no hay **serialización ni orden** — con dos paradas a la vez gana la última que publica, y es
conforme porque el bloque es derivado del mismo disco; y si al proceso lo **matan** sin darle
salida, su temporal puede sobrevivir hasta la parada siguiente, que lo retira.

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

<!-- arnes:coordinacion:inicio -->
## 14. Reglas de trabajo de la sesión coordinadora

**A. Comprobación de antes de despachar** — obligatoria y **por escrito en el propio encargo**:
(1) ¿qué **resultado exacto** debe entregar?; (2) ¿los **criterios pueden cumplirse
simultáneamente**?; (3) ¿qué **supuesto o cifra** necesita comprobarse primero?; (4) ¿qué queda
**fuera**, y **cuándo debe detenerse**? Si falta algo, se resuelve **únicamente esa dependencia**;
no se amplía el encargo.

**B. Las siete reglas:**
1. **Separar evidencia de interpretación** — dato medido / cálculo / estimación / hipótesis; una
   medición correcta no valida la conclusión construida encima.
2. **No convertir propuestas en compromisos** — ahorro, duración o cobertura son **hipótesis**
   hasta medirlas.
3. **Mantener visibles las decisiones vigentes** — consultarlas en una referencia breve (alcance
   aprobado, prioridades, excepciones, pendientes), no reconstruirlas de conversaciones largas.
4. **Corregir sin ampliar** — ante un defecto, comprobar su **efecto concreto**; los hallazgos
   adicionales van a la cola salvo que impidan el trabajo en curso.
5. **Cerrar cuando la evidencia alcance** — ante una observación externa, decidir si aporta
   defecto nuevo, algo ya cubierto o mejora opcional, y no abrir una ronda por cada una; no es
   permiso para cerrar con menos de lo que el criterio pide.
6. **Responder con evidencia breve** — resultado, evidencia, limitación material, siguiente paso.
7. **La evidencia intermedia se guarda en disco, no en la conversación** — **condición de
   entrega: la entrega no está completa si la evidencia sólo existe en la conversación.** Todo
   inventario, medición o evidencia que un trabajo posterior vaya a necesitar se escribe en un
   **archivo antes de entregar**, con **versión base** (commit o tag sobre el que se midió o
   enumeró) y **método** (cómo se obtuvo cada cifra, suficiente para re-derivarla sin preguntar)
   **dentro del propio artefacto**; si lo guardado es un **inventario**, va la **lista elemento
   por elemento** y no sólo el total. La **ruta** se cita además en el informe. Frontera **por
   propiedad**: entra toda evidencia cuya ausencia obligaría a **re-medirla o re-enumerarla**
   para cumplir algo **ya escrito** —un criterio, un REQ abierto, una fase pendiente— o para
   **explicar una discrepancia** entre dos mediciones; queda fuera el cálculo de usar y tirar,
   que se consume en la misma comisión y al que nada posterior vuelve.

**C. Separación de responsabilidades** — la coordinadora **organiza y propone**; las
**herramientas verifican lo mecánico**: toda afirmación cuya verdad se decide leyendo el disco o
corriendo un comando (ejemplos **no exhaustivos**: fechas, versiones, archivos modificados,
conteos, pruebas).

**D. Vías de lectura y límites** — cada herramienta con su vía y su **estado de verificación**:
- **Claude Code — `verificada`.** Vía: `CLAUDE.md` → `@AGENTS.md`. Evidencia: esa línea de
  importación existe en `CLAUDE.md` y en `templates/CLAUDE.md.tpl`.
- **Codex — `no verificada`.** Vía: la que declara el estándar `AGENTS.md`; esa frase es una
  afirmación del repositorio, no una comprobación.
- **Cursor — `no verificada`.** Vía sin determinar; no se comprobó.

Y los dos límites: (a) **una herramienta cuya vía no está verificada no cuenta como cubierta**
—esta sección no promete cobertura de todo coordinador—; (b) **un proyecto ya instalado tiene su
`AGENTS.md` congelado**: hasta que `arnes-upgrade` migre este bloque, sus coordinadoras **no
tienen estas reglas**.
<!-- arnes:coordinacion:fin -->
