# PENDING_APPROVAL — ArnesJuan

> Cola de decisiones que esperan visto bueno humano antes de que el pipeline continúe.
> Un agente AÑADE una entrada y se detiene; el humano la resuelve y la mueve a "Resueltas".
> Mientras haya algo en "Pendientes", el pipeline NO avanza en ese hilo.
>
> **Formato de una entrada** (va bajo `## Pendientes`, con `###`):
> `### [AAAA-MM-DD] (agente) — Título de la decisión`, y debajo: **Contexto** (por qué se
> detuvo aquí) · **Opciones** (A / B / …) · **Recomendación del agente** · **Espera**
> (aprobación / elección del humano).
>
> **Cómo se cuenta esta cola — una sola regla, la misma para todos.** Una entrada es una
> línea que empieza por `###` + espacio, dentro de la sección que abre un encabezado `## `
> cuyo texto empieza por «Pendientes» y que cierra el siguiente encabezado `## ` de
> cualquier nombre; lo que caiga dentro de un comentario HTML (`<!-- … -->`) no cuenta. Esa
> regla vive UNA vez en el código (`arnes_cola_pendientes`, `hooks/lib.sh`) y la usan por
> igual la puerta de cierre (`guard-completado`), el bloque derivado de `docs/ESTADO.md` y
> `tools/arnes-lectura.sh`: el número que se lee es exactamente el que bloquea. Y si la
> cola no se puede leer entera —un byte NUL, un archivo sin permiso—, la puerta DENIEGA y
> el bloque derivado dice `sin datos`: nunca 0.
>
> El ejemplo vive AQUÍ, fuera de la cola, y a propósito: un ejemplo dentro de la sección se
> cuenta como una pendiente real y bloquea todos los cierres.

## Pendientes


## Resueltas

### RESUELTA 2026-09-08 (propietario, autorización expresa) — partir las dos secciones 37 paga desarrollador + QA, sin analista ni auditor

- **Contexto.** La autoprueba del corredor sale `rc=1`: `CA-18` limita los archivos de sección a **400
  líneas** y `37-coste-del-escaner-1-escala.sh` mide **751** y `37-…-2-la-seccion-caliente.sh` **614**.
  El CI la corre como paso propio, sin `continue-on-error`, así que `hooks-en-linux` —la puerta
  requerida de `main`— se pone roja y **la fusión de 1.33.0 está bloqueada**.

  Lleva roja **desde el delta final de REQ-017**, y nadie lo vio porque el CI que marcaba `pass` en el
  PR #43 había medido `0bab7a1`, donde esas secciones median **346 y 266** líneas: la rama local estaba
  **20 commits por delante**. Es H-08 con otra cara — un verde sobre un árbol que ya no existe.

  `AGENTS.md` §6 clasifica como **crítico** «todo cambio en … el banco que los certifica (`tests/`)», y
  el rigor `critico` exige analista, desarrollador, QA **y** auditor. Sólo el propietario puede bajar
  ese nivel, y nunca por reclasificación automática de un agente.

- **Opciones.** **A)** desarrollador + QA, con autorización expresa. **B)** ciclo completo de cuatro
  agentes (~2 h). **C)** aplazar a 1.34.0 y no fusionar 1.33.0. *(Descartada de entrada: subir el límite
  de `CA-18` derrota el propósito de REQ-014 — el banco se partió en archivos para que dos agentes de QA
  puedan trabajar a la vez, y un archivo de 751 líneas es el cuello que eso vino a quitar.)*

- **Decisión del propietario: opción A.** El cambio es **mecánico** —mismo contenido, mismos casos,
  menos líneas por archivo— y su acreditación **ya existe y es fuerte**: un inventario ordenado de caso
  y veredicto **idéntico byte a byte** antes y después, que es el criterio central de REQ-014. El
  auditor no añade casi nada sobre una partición que no cambia lógica.

- **Lo que la autorización NO cubre, dicho aquí para que no se estire:** ninguna otra edición de
  `tests/`, ningún cambio de lógica dentro de las secciones partidas, y ningún ajuste de
  `CASOS_ESPERADOS` total ni de `CASOS_ESPERADOS_SECCION` más allá del reparto aritmético que la
  partición obliga. Cualquier cosa fuera de eso vuelve a `critico`.

- **Contra-argumento que quedó sobre la mesa y no se resolvió:** la auditoría preventiva **R-011** midió
  que `tests/` **no está en `codigo_app.globs`**, así que el juez de todas las sondas no lo vigila nadie
  —tampoco contra esta sesión coordinadora, que acredita, decide y publica—. Es el residual `SEC-045`,
  abierto, y esta autorización lo asume sabiéndolo.

- **Orden, y por qué no se adelanta:** la partición va **después** de cerrar REQ-021, no antes. `CA-07
  punto 2` de REQ-021 **congela** los `CASOS_ESPERADOS_SECCION` de esas dos secciones, y esa congelación
  es lo que hace acreditable la mudanza de las sondas. Partirlas antes obligaría a re-medir la
  acreditación de REQ-021 contra una línea base distinta.

### RESUELTA 2026-09-07 (coordinadora, por delegación del propietario) — aprobada la opción A: el cambio del workflow de CI viaja en 1.32.0
- **Contexto.** `AGENTS.md` §6 lista entre los gates humanos «cambiar el ruleset, **el workflow de CI**
  o el manifiesto» y clasifica como **crítico** «todo cambio en … el banco que los certifica
  (`tests/`) [y] en el workflow de CI». REQ-014 hace las dos cosas: parte `tests/escenarios/hooks/run.sh`
  (4.096 líneas) en un corredor más 35 archivos de sección, y añade a `.github/workflows/banco.yml`
  tres cosas — `bash -n` sobre `secciones/*.sh`, la comprobación del bit de ejecución en sus dos
  mitades (puntos de entrada `100755`, secciones `100644`) y un paso nuevo para
  `autoprueba-corredor.sh`. El REQ lo pide explícitamente en su CA-25.
- **Evidencia con la que se llega aquí.** Inventario de 683 casos **byte a byte idéntico** al de
  v1.31.0 publicada (`diff` vacío), tres corridas antes y tres después idénticas entre sí; cero FAIL;
  cuadre exacto global y por archivo; las 35 secciones dan el mismo veredicto en solitario que dentro
  de la vuelta completa; `git diff v1.31.0 -- hooks/ tools/` vacío; tiempo mediano 16,3 s frente a
  17,7 s antes (más rápido, dentro del techo de CA-20).
- **Opciones.** **A)** Aprobar el cambio de `tests/` y del workflow tal como está. **B)** Aprobar la
  partición del banco y dejar el workflow como estaba (se pierden `bash -n` sobre las secciones, la
  comprobación de modos y la autoprueba: el CI dejaría de ver los tres modos de fallo que la
  estructura nueva introduce). **C)** Rechazar y volver al monolito.
- **Recomendación del agente.** **A.** La partición sin las puertas nuevas en CI es la mitad peligrosa
  del cambio: una sección con la sintaxis rota no falla, **desaparece**, y sin `bash -n` en CI nadie lo
  ve hasta que el cuadre por archivo lo delate — que es exactamente lo que este paso adelanta.
- **Espera.** Aprobación del propietario para fusionar el PR de `cand/1.32.0` con el cambio de
  `.github/workflows/banco.yml` incluido.
- **Resolución.** El propietario eligió **publicar 1.32.0** el 2026-09-07, aprobando expresamente
  el cambio de `.github/workflows/banco.yml`. El `auditor-seguridad` no puso objeción de seguridad
  al cambio en R-004 y la confirmó en R-006: no añade secretos ni acciones de terceros, no usa
  `pull_request_target`, `bash -n` no ejecuta nada y `git ls-files -s` sólo lee el índice. Las dos
  observaciones que dejó —falta `permissions: contents: read` explícito y `actions/checkout@v4`
  anclado por etiqueta y no por SHA— son **preexistentes**, no las trae esta ventana, y quedan como
  deuda de endurecimiento sin dueño de ventana.


### RESUELTA 2026-09-05 (coordinadora, por delegación del propietario) — aprobada la opción B ampliada

- **Decisión:** se añaden a `codigo_app.globs` de **este** repositorio `.arnes/config.json` y
  `.claude-plugin/*`. **No** se añade `.arnes/*` entero, y no es un descuido: `/arnes-upgrade`
  escribe `.arnes/migracion.md` y `.arnes/plantillas-origen/` desde la sesión coordinadora, y
  protegerlos convertiría cada migración en una comisión al `desarrollador` sin ganar nada —
  ninguno de los dos declara una invariante.
- **Coste aceptado, dicho en voz alta:** `arnes_version` vive en el manifiesto, así que la Fase 5
  de `/arnes-upgrade` en este repositorio pasa a ser trabajo del `desarrollador`. Ocurre una vez
  por versión y coincide con el commit en el que ya sube `plugin.json` y `marketplace.json`.
- **Se conserva el control obligatorio:** la ampliación **no** se propaga a
  `templates/arnes-config.json.tpl`. Es mapeo de este repositorio, no mecanismo.
- **Lo aplica el `desarrollador`** en la vuelta siguiente, junto con REQ-010. La coordinadora no
  edita el manifiesto, ni siquiera para meterlo dentro de la frontera.

### [2026-09-05] (desarrollador) — Meter `.arnes/config.json` y `.claude-plugin/*` dentro de `codigo_app.globs` de ESTE repositorio

- **Contexto** — SEC-006 parte (a) de la auditoría R-001 (REQ-007, CA-53): hoy
  `codigo_app.globs` es `["hooks/*", "tools/*", ".github/*"]`, así que **quien no puede
  escribir `hooks/` sí puede cambiar la regla que dice qué es `hooks/`**. El manifiesto es
  la fuente de verdad ejecutable de las invariantes —quién es el agente de código, qué
  rutas protege, qué quality gates corren, cuál es el estado terminal y cuál es el techo de
  análisis de Bash—, y `.claude-plugin/plugin.json` / `marketplace.json` declaran la versión
  publicada. Es escalada de privilegios dentro del arnés. `AGENTS.md` §6 ya exige
  aprobación humana para tocar el manifiesto de este repositorio, pero eso es política, no
  enforcement. **El mecanismo que hace falta ya existe** (`guard-codigo` deniega cualquier
  ruta que case con los globs): lo único que falta es el mapeo, y el mapeo es este archivo.
- **Opciones** — **A)** Añadir `.arnes/*` y `.claude-plugin/*` a `codigo_app.globs` de
  `/.arnes/config.json` (sólo de este repositorio). **B)** Añadir sólo
  `.arnes/config.json` y dejar el resto de `.arnes/` libre. **C)** No aplicarlo y dejar el
  hueco declarado como límite en `docs/seguridad/registro-seguridad.md`.
- **Recomendación del agente** — **A**. Es el mapeo del arnés sobre sí mismo y cierra la
  escalada completa; el coste es que a partir de ahí sólo el `desarrollador` toca el
  manifiesto y la versión, que es exactamente lo que `AGENTS.md` §6 ya dice en prosa.
  Efecto colateral esperado y **no** un fallo: mientras el manifiesto no esté en los globs,
  `guard-codigo` tampoco protege el cambio que lo mete en ellos.
- **Espera** — Aprobación del propietario (Juan) para editar
  `/.arnes/config.json`, y elección entre A, B y C. **Control obligatorio de esta
  decisión, ya verificado en la candidata:** la ampliación **no** se propaga a
  `templates/arnes-config.json.tpl` — es mapeo de este repositorio, no mecanismo, y
  ningún proyecto que instale el arnés puede heredarla.

<!-- Mover aquí con: decisión tomada, quién, fecha. No borrar (histórico). -->
