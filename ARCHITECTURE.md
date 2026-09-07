# ARCHITECTURE — ArnesJuan

> Vista de sistema: cómo encaja todo. La mantiene el `desarrollador`, junto al código,
> para que refleje el sistema *real* (no la intención). Describe el cómo, no el qué.

## Visión general

ArnesJuan es un **plugin de Claude Code**: no es un servicio ni tiene proceso propio. Todo
lo que hace ocurre dentro de una sesión de Claude Code, en dos momentos que la herramienta
concede a un plugin:

- **`PreToolUse`** — antes de ejecutar una herramienta (`Edit`, `Write`, `MultiEdit`,
  `Bash`). Es donde viven los **guardianes**: pueden **denegar** la llamada.
- **`Stop` / `SubagentStop`** — cuando un agente para. Es donde viven los hooks que **no
  deciden nada**: la continuidad derivada y la rotación de artefactos.

Los dos se registran en `hooks/hooks.json`. La configuración que gobierna a los hooks
—qué es código de la app, qué agente lo edita, qué quality gates hay, qué órdenes de git
se prohíben— vive en el manifiesto del proyecto, `.arnes/config.json`, **no** en el
plugin: el arnés trae el mecanismo, el proyecto pone el mapeo. Sin manifiesto los hooks
son **inertes**; sin `jq` también, con aviso por stderr.

## Componentes

| Componente | Responsabilidad | Entradas | Salidas |
|-----------|-----------------|----------|---------|
| `hooks/guard.sh` | Punto de entrada **único** de `PreToolUse`. Hace el preludio una vez (leer stdin, interpretar el JSON, cargar el manifiesto) y corre los tres guardianes como funciones en el **mismo proceso** | JSON de `PreToolUse` por stdin | `deny` (y termina), o `systemMessage` con los avisos acumulados, o nada |
| `hooks/guard-git.sh` | **Ninguna orden destructiva de git**, venga del agente que venga (regla del *comando*, no de la identidad) | `tool_input.command`, `git.*` del manifiesto | `deny` con motivo |
| `hooks/guard-codigo.sh` | Sólo el agente declarado edita `codigo_app.globs` (regla de la *identidad*) | `agent_type`, `file_path` o `command`, `codigo_app.globs` | `deny` con motivo |
| `hooks/guard-completado.sh` | La transición de un REQ a `completado`: veredictos, fecha y caducidad, clase del hallazgo, cola de aprobaciones y quality gates. Por `Bash` no juzga: **deriva** a `Edit`/`Write` | documento resultante del REQ, `PENDING_APPROVAL.md`, `quality_gates`, `veredictos.*` | `deny` con motivo, o aviso de vocabulario |
| `hooks/lib.sh` | Toda la lógica compartida: lectura del input y del manifiesto, normalización de campos y veredictos, **vocabulario** de los veredictos, descuento de comillas y heredocs (`arnes_bash_sin_texto`), detector de escrituras, contención de rutas | — | funciones; ninguna decide por su cuenta |
| `hooks/stop.sh` | Punto de entrada único de `Stop`/`SubagentStop`; **nunca bloquea la parada** | JSON de `Stop` | rc 0 siempre |
| `hooks/estado-derivado.sh` | Reescribe entre marcadores de `docs/ESTADO.md` un bloque **derivado del disco** (estado y veredictos de cada REQ, cola, rama, limpieza del árbol) | `requirements/*.md` vía `campos-req.awk`, `PENDING_APPROVAL.md`, git | bloque en `docs/ESTADO.md` |
| `hooks/rotar-artefactos.sh` | **Mueve** (nunca resume) las secciones viejas de un artefacto de bitácora, o las entradas viejas de **una sección** declarada de un documento | `rotacion.*` del manifiesto | archivo de historia + puntero |
| `hooks/campos-req.awk` | Extrae en **una** pasada los campos de cabecera de todos los REQ | `requirements/*.md` | registros separados por `\001` |
| `tools/arnes-lectura.sh` | Informe en frío: qué lee la máquina en cada REQ. Usa **el mismo lector y el mismo vocabulario** que las puertas (`lib.sh`) | `requirements/*.md`, manifiesto | informe; rc 1 si hay anomalías |
| `tools/arnes-paralelo.sh` | Despacho: dice si dos REQ son **disjuntos** o **colisionan** por su campo `Archivos:`, expandiendo los globs contra el árbol real. Reutiliza la **normalización** de `lib.sh` sin entrar en el lector de las puertas; ningún hook la invoca | `requirements/*.md`, manifiesto, árbol del repo | `disjunto`/`colisiona` (texto o `--json`); rc 1 si colisiona, 2 si no pudo medir |
| `tests/escenarios/hooks/run.sh` | El **corredor** del banco: ayudantes compartidos, canario global, descubrimiento de las secciones (glob de bash, sin forks) y despacho en paralelo con proyecto efímero propio | `secciones/NN-<slug>.sh` | PASS/FAIL/SKIP + cuadre **por archivo y total** |
| `tests/escenarios/hooks/secciones/` | El banco: los casos, **una sección por archivo**, descubiertos por el corredor. Cada uno declara su `CASOS_ESPERADOS_SECCION`; ninguno hace `source` de otro | hooks reales con JSON fabricado | líneas PASS/FAIL/SKIP |
| `tests/escenarios/hooks/autoprueba-corredor.sh` | Certifica al corredor contra directorios de secciones **sintéticos**; sus casos no entran en el inventario del banco | `ARNES_SECCIONES_DIR` | PASS/FAIL |
| `tests/escenarios/hooks/inventario.sh` | Inventario ordenado `veredicto · caso` de una salida del banco: lo que se compara vuelta a vuelta al reorganizarlo | salida del banco | una línea ordenada por caso |

## Flujo de datos

**`PreToolUse` (el camino más frecuente de todos).**

```
Claude Code --stdin(JSON)--> guard.sh
   preludio: parse_input (1 jq) + manifiesto (1 jq), memorizados
   1. arnes_guard_git         ¿es una orden de git que destruye trabajo?   -> deny
   2. arnes_guard_codigo      ¿quién edita código de la app?               -> deny
   3. arnes_guard_completado  ¿se puede cerrar este REQ?                   -> deny
   4. arnes_emitir_avisos     lo que hay que decir sin bloquear   -> {"systemMessage": ...}
```

El orden importa y está fijado: **git primero**, porque su daño es el único
irreversible —una edición denegada se reintenta, un árbol borrado no vuelve—. Una
denegación es **final**: `arnes_deny` termina el proceso y los siguientes no corren. Los
avisos sólo se emiten si nadie denegó (dos objetos JSON en el mismo stdout no son una
respuesta válida).

Un comando de `Bash` que no menciona `git` no llega a leer el manifiesto en `guard-git`;
y `guard-codigo`/`guard-completado` comparten con él **un solo** descuento de comillas y
cuerpos de heredoc (`arnes_bash_sin_texto`), para que no existan dos transcripciones de
esa regla que puedan desfasarse.

**`Stop` / `SubagentStop`.**

```
Claude Code --stdin(JSON)--> stop.sh --> estado-derivado.sh   (bloque derivado del disco)
                                     --> rotar-artefactos.sh  (mueve historia, deja puntero)
```
Ninguno decide nada y ninguno puede bloquear la parada: salen 0 pase lo que pase. La
rotación tiene además prohibido tocar la cabecera de un REQ — escribe en `requirements/`
desde fuera de la vía que vigila `guard-completado`, así que alterar ahí un veredicto
sería cerrar un REQ sin puerta alguna.

**Ciclo de vida de un REQ (lo que el sistema gobierna de verdad).**

```
analista -> requirements/REQ-xxx.md (contrato)
desarrollador -> código + pruebas          guard-codigo vigila quién escribe
qa-tester -> QA: aprobado (ronda, fecha)
auditor -> Seguridad: aprobado             guard-completado exige el orden
Estado: completado                         guard-completado: veredictos, fecha/caducidad,
                                           clase del hallazgo, cola humana, quality gates
```

## Integraciones externas

- **git**, sólo en local y sólo de lectura: `git log -1 --format='%cs %h' -- <globs>` y
  `git status --porcelain -- <globs>` en `guard-completado` (cuando el proyecto enciende
  `veredictos.caducan_con_codigo`), y las consultas de rama/limpieza del bloque derivado.
  Ninguna toca el remoto: un hook que hace red puede colgar una parada.
- **GitHub**: `main` protegido por el ruleset `proteger-main`, con el check
  `hooks-en-linux` (el banco completo) requerido. Fuera del runtime del plugin.
- **jq** como única dependencia dura; si falta, el enforcement queda inactivo con aviso.
- Sin credenciales de ningún tipo: el plugin no las lee, no las escribe y no las registra.

## Decisiones clave

- `docs/decisions/` — ADRs del proyecto.
- `docs/gobernanza/autoalojamiento.md` — la versión N gobierna el desarrollo de N+1.
- `AGENTS.md` §13 — qué invariantes baja el arnés a runtime y **hasta dónde llega**
  (la cobertura de `Bash` es parcial a propósito: es una barandilla, no una jaula).
