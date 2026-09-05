# ArnesJuan

Arnés genérico de agentes para desarrollo asistido por IA en Claude Code (portable a Codex,
Cursor y otras herramientas vía AGENTS.md + MCP).

## Qué incluye
- **4 agentes** (`agents/`): `analista-requerimientos`, `desarrollador` (dueño también de
  `ARCHITECTURE.md`), `qa-tester`, `auditor-seguridad`. Genéricos: el contexto del proyecto
  vive en `AGENTS.md`, no en los agentes.
- **Comandos** (`skills/`): `/arnes-init` (andamia un proyecto, idempotente),
  `/arnes-upgrade` (pone al día el andamiaje de un proyecto ya inicializado cuando el arnés
  sube de versión: aditivo, nunca sobrescribe), `/arnes-close` (genera el entregable
  `DELIVERY.md`) y `/arnes-panel` (panel HTML interactivo de estado del proyecto: solo
  lectura, se regenera; clic para ver el detalle).
- **Plantillas** (`templates/`): AGENTS.md (canónico) + CLAUDE.md (puntero) + CHANGELOG,
  ESTADO, PENDING_APPROVAL, ARCHITECTURE, DELIVERY, ADR, requirements y el hook pre-commit
  que exige changelog.
- **Tests del arnés** (`tests/`): escenarios para validar los agentes antes de versionar.

## Probado en Linux desde 1.29.0, y no antes
Los tres proyectos que estrenaron el arnés estaban en Windows. Hasta 1.28.0 los dos puntos de
entrada de `hooks.json` no tenían bit de ejecución y **en Unix ningún hook corría**: Claude Code
recibía *Permission denied* y seguía. Lo encontró una revisión externa. Desde 1.29.0 un CI en
`ubuntu-latest` comprueba el bit como propiedad cerrada y corre el banco entero en cada PR.

## El plugin no se actualiza solo
Medido en un proyecto real (2026-09-04): el proyecto corría **1.13.0, del 3 de agosto**, con
**1.21.0** publicada. Un mes de correcciones —incluidas tres puertas que no existían— que nunca
llegaron. El registro del marketplace no tenía marca de auto-actualización y su última sincronía
era de un mes antes.

**No cuentes con que llegue sola.** Un proyecto puede quedarse versiones atrás sin ninguna señal,
y las correcciones que más importan —las de una puerta que no se estaba cumpliendo— son
silenciosas por definición: nada falla, simplemente no protege. Actualiza el plugin
explícitamente y después corre `/arnes-upgrade`, en ese orden.

## Enforcement por runtime (hooks)
Las invariantes críticas no se quedan en el markdown: las vigila la máquina vía hooks
`PreToolUse` del plugin (`hooks/`), que leen el manifiesto `.arnes/config.json`:
- **Sólo el `desarrollador` edita el código de la app** (la coordinadora y demás subagentes
  reciben un rechazo en runtime, con el motivo).
- **Un REQ no pasa a `completado`** si hay aprobaciones pendientes en `PENDING_APPROVAL.md`, si
  alguna quality gate está en rojo, o si falta el veredicto de QA/seguridad.
- **El orden del ciclo se cumple:** `Seguridad: aprobado` no se escribe sobre un árbol que QA no
  ha validado —el auditor no mira las quality gates—. La única salida es declarar la auditoría
  **preventiva**, que desbloquea el orden pero **no** cierra un REQ crítico.

### Continuidad: un bloque que se **deriva**, no se redacta
Al parar un agente (`Stop` / `SubagentStop`), el arnés reescribe en `docs/ESTADO.md`, entre
marcadores, un bloque leído del disco: estado y veredictos de cada REQ, cola de aprobaciones,
rama y si el árbol tiene cambios sin comitear.

**Por qué derivado y no un resumen.** Pedirle a un agente que cuente lo que hizo no resuelve la
pérdida de contexto: un resumen redactado por el modelo miente justo cuando más falta hace —
cuando le queda poco contexto, que es cuando peor recuerda. Aquí cada línea sale de leer un
archivo, así que si el bloque se equivoca es que el disco dice eso.

Los veredictos se muestran **como los lee la máquina** —normalizados— y no como están escritos:
si un valor se ve raro ahí, es que la puerta lo está leyendo raro, y eso es justo lo que
conviene ver.

Nunca bloquea la parada, no toca nada fuera de sus marcadores, es idempotente, y se apaga con
`estado_derivado.activo: false`.

### Rotación: una bitácora no crece sin tope
Un `CHANGELOG.md` de **1,17 MB** —medido en un proyecto real— son del orden de **300 000 tokens**
que entran en la ventana cada vez que alguien lo lee. Con `rotacion.activo: true`, el hook `Stop`
**mueve** las secciones sobrantes a `<nombre>-archivo.md` y deja un puntero.

**Mueve; no resume.** Un resumen convertiría la bitácora en la versión que el modelo recuerda de
ella. Nunca borra —añade, relee para comprobar que llegó, y sólo entonces recorta—, corta sólo en
encabezados `## `, y **qué mitad es «lo viejo» se declara, no se adivina**: un CHANGELOG pone lo
nuevo arriba, un registro cronológico al final, y equivocarse archivaría lo más reciente.

**Cada artefacto declara lo suyo.** El orden es una propiedad del artefacto, no del proyecto: un
`CHANGELOG` crece por arriba y un registro cronológico por abajo, así que `artefactos` acepta
cadena (hereda los ajustes globales) u objeto con su `orden`, `umbral_bytes` y
`conservar_secciones` — la misma convención que las `quality_gates`.

Viene **apagada**: reestructurar un documento que escribió una persona no puede ser el
comportamiento por defecto.

Son **inertes** sin `.arnes/config.json` (no estorban en repos ajenos al arnés) y requieren `jq`.
El `pre-commit` de git sigue exigiendo el changelog en cada commit.

**El nombre del agente en el manifiesto va en corto** (`"agente_codigo": "desarrollador"`). En
runtime Claude Code entrega el agente con el prefijo del plugin que lo provee
(`arnes-juan:desarrollador`); el hook lo tolera. Declararlo con prefijo es opcional y vuelve la
comparación estricta con ese proveedor.

### Bash pasa siempre por el guardián, y esto se pagó con un fallo en abierto
1.25.0 puso un handler con `if` por disparador de escritura para que un `ls` no arrancara el
guardián. `if` funciona —medido con control positivo en `2.1.260` y `2.1.261`— **pero sólo para
prefijos de comando**. Una redirección **nunca casa**: Claude Code la separa del comando antes de
evaluar el patrón, así que `Bash(* >*)` no disparó en ninguna versión.

```
echo 'Estado: completado' > requirements/x.md   ->  PASÓ y creó el archivo   (proyecto real)
touch a.txt                                     ->  if dispara
echo hola > b.txt                               ->  ningún if dispara
```

**Desde 1.25.0 hasta 1.27.0, la forma de escritura más común rodeaba las dos puertas en silencio.**
Y mi prueba de integración tenía control positivo para *que `if` existe*, no para el patrón del que
dependía todo. Como la redirección puede ir en cualquier comando, la única puerta posible para Bash
es la que ve **todos**. El coste vuelve al de 1.24.0 y se acepta: una puerta lenta protege; una
puerta que no se invoca, no.

La lección quedó escrita donde se lee: *una optimización que reduce cuándo se invoca un control
puede apagarlo entero sin cambiar una línea de su lógica.*

### Limitación conocida: la cobertura de `Bash` es parcial (y a propósito)
`guard-codigo` mira `Edit`/`Write`/`MultiEdit` y, en `Bash`, sólo las escrituras **evidentes**:
redirección `>`/`>>`, `tee`, `cp`, `mv`, `install`, `sed -i`, `perl -i` y `dd of=`. Quedan fuera
**cualquier intérprete** —`node script.mjs`, `python x.py`, `pwsh -File x.ps1`—, los
formateadores que reescriben archivos (`prettier --write`, `eslint --fix`),
`patch`/`git apply` y cualquier programa que escriba por su cuenta.

`guard-completado` **sí** mira `Bash`, pero no lo juzga: lo **deriva**. Un comando que escribe en
`requirements/` y menciona el estado terminal se deniega pidiendo que la transición se haga con
`Edit`/`Write`, que es donde el hook puede ver el contenido resultante y evaluar veredictos, cola
y quality gates. Reimplementar esas puertas para la shell sería una segunda transcripción de la
misma regla, y dos transcripciones se desfasan. Dentro de esa vía la detección es
**deliberadamente ancha**, porque la forma más natural de cerrar un REQ por shell
—`sed -i 's/en-revisión/completado/'`— sustituye el **valor** y no escribe nunca la palabra
«Estado». Fuera de esas formas evidentes sigue habiendo vías abiertas: la cobertura de `Bash` es
parcial en las dos puertas.

**El porqué:** un hook no puede analizar shell arbitrario de forma fiable — redirecciones
indirectas, heredocs, variables, subshells, scripts que escriben por su cuenta. Perseguir la
cobertura total genera falsos positivos sobre comandos de lectura perfectamente legítimos
(`cat`, `grep`, `git diff`, un build que escupe su log), y un guard que estorba acaba
desactivado. Un guard apagado protege menos que uno parcial, así que el detector se sesga
explícitamente al **falso negativo**: si duda, permite.

**El intérprete es el agujero más grande de los que quedan, y está medido dos veces.** Ni
`node script.mjs`, ni `python - <<EOF`, ni `ruby` arrancan el guardián — y **aunque lo
arrancaran no serviría**, porque el detector lee el *texto del comando* y la ruta vive dentro
del script:

```
python - <<EOF ... open("src/app.ts","w") ... EOF   ->  no detecta
echo x > src/app.ts                                 ->  src/app.ts   (control positivo)
```

Por eso añadir `Bash(python*)` al filtro previo sería **teatro**: coste sin cobertura, y peor
que el hueco porque parecería cerrado. En Windows esto no es rebuscado — `sed -i` es incómodo
aquí y un intérprete es lo primero que alcanza cualquiera.

El arreglo de verdad es **cambiar la pregunta**. En vez de adivinar *antes* si un comando
escribe —una pregunta abierta que admite formas nuevas sin fin— preguntar *después* si
cambiaron los archivos protegidos, que es cerrada y no depende de cómo se escribieran. No
previene, detecta; pero el arnés ya se declara barandilla, y una que avisa siempre vale más
que una que previene a veces. Diseñado, no construido.

Conclusión honesta, la misma que dice `AGENTS.md` §13: **es una barandilla, no una jaula.**
Impide que el modelo se desvíe por descuido; no contiene a un agente decidido a rodearla. Cuando
deniega por `Bash`, el mensaje dice que la cobertura es parcial, para que un falso positivo se
reconozca al instante.

## Qué hace el arnés
Coordina cuatro agentes especializados en un pipeline con el humano siempre al mando:
- **Quality gates por fase:** cada requerimiento recorre análisis → desarrollo → QA →
  seguridad. No avanza de fase sin cumplir los criterios, y el humano aprueba cada salto vía
  `PENDING_APPROVAL.md`.
- **Decisiones trazables (ADRs):** las decisiones de arquitectura se registran como ADRs en
  `docs/decisions/` (con su plantilla), para que siempre quede por qué se hizo cada cosa.
- **Control de costo:** presupuesto por tarea + límite de reintentos dev↔QA. Superado el
  límite, el requerimiento se bloquea y escala en vez de gastar indefinidamente.
- **Observabilidad en archivos:** todo queda en texto auditable — `CHANGELOG.md` (cada
  commit), `docs/seguridad/registro-seguridad.md` (hallazgos) y `docs/ESTADO.md` (estado).
- **Documentación viva:** cada agente es dueño de su documentación (técnica, de usuario, de
  seguridad) y la mantiene junto al código, reflejando el sistema real y no solo la intención.

## Músculo de runtime opcional (MCP)
El arnés funciona solo con markdown, sin dependencias externas. Si quieres capacidades de
runtime "duras" —un escáner real de CVEs, medición de tokens, etc.— se enchufan vía **MCP**
partiendo de `.mcp.json.example`. Son intercambiables (semgrep, bandit, el motor que
prefieras) y **opcionales**: el arnés no depende de ninguno para funcionar.

## Instalar (Claude Code)
```
/plugin marketplace add <tu-usuario>/ArnesJuan
/plugin install arnes-juan@arnes-juan
```
Luego, en un proyecto nuevo: `/arnes-init`. Al cerrar: `/arnes-close`.

Cuando el arnés suba de versión, en cada proyecto ya existente: `/arnes-upgrade`. Hace falta
porque los hooks y los agentes viven en el plugin y se actualizan solos, pero los archivos que
`/arnes-init` copió al proyecto —`AGENTS.md`, `.arnes/config.json`, `requirements/README.md`…—
se quedan como estaban. Sin ese paso, la máquina empieza a exigir cosas que el `AGENTS.md` del
proyecto no describe.

## Las dos capas
- **Maquinaria** (este plugin): agentes, comandos, plantillas. Viaja entre proyectos/clientes.
- **Estado del proyecto** (AGENTS.md, CHANGELOG, ESTADO, PENDING_APPROVAL, ARCHITECTURE, docs,
  requirements): se queda en cada repo. Cero datos de cliente en el plugin.

## Flujo
analista define REQ → desarrollador codifica → qa-tester valida → auditor-seguridad revisa
→ REQ `completado`. La sesión principal coordina; el humano aprueba cada fase (vía
`PENDING_APPROVAL.md`). Máximo de reintentos dev↔QA configurable; superado, el REQ se bloquea
y escala.

## Versionado
SemVer con tags. Mejoras siempre aquí (una sola fuente de verdad); los proyectos actualizan
cuando quieren. Correr `tests/` antes de cada versión.
