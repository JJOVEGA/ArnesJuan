# Pendientes del arnés — lo que sigue, en orden

> **Qué es esto.** La cola de trabajo del arnés, escrita para que sobreviva a cualquier sesión.
> Cada punto nace de una medición en un proyecto real que usa el arnés; **aquí va la forma del
> hallazgo, nunca su instancia** (este repositorio es público; los informes de los proyectos
> viajan por canal privado y no se publican). Se poda cuando se publica: lo hecho vive en el
> `CHANGELOG.md`, no aquí.
>
> **Regla de siempre:** el arnés trae el **mecanismo**; qué archivo, qué sección, qué umbral, qué
> identificador —el **mapeo**— lo declara cada proyecto en su manifiesto.

## Próxima: 1.32.0 — puertas que miden después, y agentes que se coordinan

- **Puerta posterior sobre el código de la app.** Hoy se pregunta *antes* si un comando escribe
  (pregunta abierta: admite formas nuevas sin fin — intérpretes, `npx`, `docker exec`). Un
  `PostToolUse` sobre `Bash` que compare el estado de `codigo_app.globs` antes y después (marca de
  tiempo, no hash: un solo proceso) contesta la pregunta cerrada: *¿cambió algo protegido?* No puede
  deshacer la escritura, pero la delata en el acto y con el comando que la hizo. Cierra como
  **detección** el hueco del intérprete, que como prevención es imposible.
- **Capa 0, opcional.** `PostToolUse` sobre `Write|Edit` que corra las reglas del proyecto
  (`reglas_escritura.comando`, una función pura de ruta y contenido) y devuelva el hallazgo en el
  acto. Medido: siete veces en dos días el mismo patrón —narrar un escenario con el valor concreto—
  se atrapó **tarde**. Apagada por defecto y sólo sobre globs declarados: cada proceso cuesta.
- **El encargo contra las herramientas del agente.** Aviso (no deny) en `PreToolUse` de `Agent`
  cuando el prompt pide ejecutar/medir/descomprimir y el agente destino no tiene `Bash`. Medido: un
  agente sin herramienta de ejecución trabajó a ciegas una ronda entera y la perdió.
- **Reparto de identificadores.** Dos agentes en paralelo reclamaron el mismo bloque `XXX-nnn`
  leyendo el máximo al arrancar. Mecanismo: contador con reserva atómica en un archivo del proyecto
  (`tools/arnes-id.sh <prefijo>`) y detección de identificadores duplicados al parar; el patrón lo
  declara el proyecto.
- **Puertas dependientes.** `quality_gates` como objeto admite `depende_de`: cuando la puerta base
  falla, la dependiente se reporta como *no medible*, no como segundo fallo. Medido: «tres puertas en
  rojo» donde había **una** causa, y la investigación siguiente salió mal dirigida.

## 1.33.0 — la skill de migración y las plantillas

- **`/arnes-upgrade`:** marcadores anclados a su forma estructural (encabezado, fila, clave JSON) y
  no a texto suelto —la prosa que documenta una carencia hoy la hace parecer presente—; consultar
  `git log -- .arnes/config.json` **antes** que los marcadores (un `arnes_version` subido a mano se
  ve ahí y ningún marcador acota por arriba); comparar el **cuerpo** de las secciones que ya existen,
  no sólo detectar las que faltan (dos correcciones de 1.16.0 faltaban el día después de una
  migración «al 100%»); una herramienta que haga esas comprobaciones en vez de `grep` manual.
- **Banco de marcadores en CI:** por cada marcador, verificar que casa con el tag desde el que se
  declara y **no** con el anterior (`fetch-depth: 0`). El marcador `(preventiva)` murió una versión
  después de nacer y nadie lo vio.
- **Plantillas y playbooks** (texto, un lote): los dos planos de autorización (el gate del
  repositorio registra la decisión; el permiso de ejecución lo da el sistema, y un agente puede tener
  el primero y no el segundo); las invariantes de Definition of Ready (un criterio con número nombra
  dos datos; el sujeto de un control es el punto de salida; una aserción «capaz de fallar» se
  demuestra mutando; un criterio más laxo que lo construido programa un debilitamiento; un control se
  escribe entero); write-back agrupado por ronda de auditoría; estado de realización explícito en los
  criterios (`construido` · `desplegado` · `impuesto y medido`); decisiones no delegables (aceptar un
  residual de seguridad); declarar **por qué** algo no es medible, con el comando y su salida;
  clasificar el ambiente el primer día; `isolation: worktree` como opción para los agentes que
  corren las puertas; la higiene del repositorio público. Playbook de **propiedad cerrada frente a
  lista enumerada** y de **sub-afirmación** (el código que dice que un control no existe cuando ya
  existe), como forma, con el guardián de ejemplo.

## 1.34.0 — la puerta que pregunta si las pruebas MIDEN algo

- **Cribado** (del arnés, forma pura): marcar toda aserción de la familia «cero infracciones» o «el
  nombre aparece en el fuente» sin una hermana que exija mayor que cero. Medido: 6 555 de 6 558
  pruebas en verde con la asignación de un módulo entero cortada.
- **Mutación** (mecanismo del arnés, mapeo del proyecto): un runner que aplica una mutación declarada,
  corre las pruebas y exige que **muerdan**. Invariantes aprendidas ejerciendo dieciséis mutaciones
  reales: se niega a arrancar con el árbol sucio; una a la vez, revertida y verificada antes de la
  siguiente; **nunca** en el alijo de git; y **fuera de las seis puertas**, porque es cara y no debe
  bloquear un cierre por lentitud. Se valida contra un proyecto real antes de publicarse.

## Backlog sin versión

- **Marcas de carencia** (versión mínima del «sustrato declarado»): el proyecto declara marcas
  (`⏸`, «no existe», «pendiente de registro») que impiden cerrar un REQ si aparecen fuera de un bloque
  residual con dueño y forzador. La versión completa —comprobar que existan las columnas, tablas u
  operaciones que el REQ nombra— es del proyecto: sólo su esquema versionado puede contestarla.
- **Cola de aprobaciones:** avisar cuando la prosa diga «0 entradas» y haya `###` debajo. La cola en el
  manifiesto **no**: un número tecleado es la misma lista enumerada que se pudre.
- **Consolidar los procesos del hook de parada** (~8 → 4 forks): en esta plataforma cada uno cuesta.
- **Política de QA ausente en dos pasos:** la migración añade `QA: pendiente` donde falte; después se
  exige.
- **Experimento Context Pack** (rama `exp/context-pack`, protocolo en `docs/experimentos/`): medir
  antes de construir; un paquete de contexto pre-materializado por REQ, con `implementa` derivado de
  git. Nunca se construye el grafo entero aunque el experimento gane.
- **Límite documentado, no pendiente:** el hueco del intérprete (`python x.py` que escribe) no se
  cierra como prevención; se cierra como detección con la puerta posterior de 1.32.0.

## Observado en el autoalojamiento (2026-09-05): fricciones del propio arnés sobre sí mismo

Medidas mientras el arnés v1.30.2 gobernaba el desarrollo de 1.30.3. Cada punto es la **forma** del
hallazgo; se convierte en REQ con el analista al abrir la versión que lo recoja.

- **La sonda del guardián es manual.** Versión, commit, ruta de la instalación y una escritura
  denegada sobre código protegido se comprobaron a mano en cada arranque. Un `SessionStart` (o un
  `tools/arnes-guardian.sh`) que lo imprima y lo mida ahorra el ritual y no depende de que la
  coordinadora se acuerde. Candidata: 1.32.0.
- **El arnés no sabe que la sesión no está gobernada.** Dos sesiones seguidas creyeron tener guardián
  y no lo tenían (plugin instalado a mitad de sesión; los hooks se cargan al arrancar). Un `Stop` que
  compare la versión instalada con la que cargó la sesión puede avisar en el bloque derivado.
  Candidata: 1.32.0.
- **Dos transcripciones de la regla de la cola de aprobaciones.** `guard-completado.sh` cuenta
  encabezados `###` bajo `## Pendientes`; `estado-derivado.sh` cuenta viñetas en la misma sección.
  Una entrada real del formato documentado vale 1 para la puerta y 4 para el bloque derivado.
  Misma familia que REQ-003 (vocabulario compartido). Candidata: 1.31.0.
- **Regla de banco: un JSON vacío es FAIL, nunca `allow`.** Un caso de rendimiento pasaba porque el
  helper reventaba el límite de argumento (`MAX_ARG_STRLEN`, 128 KB) y el hook recibía entrada vacía.
  Ya aplicado en `run.sh` (1.30.3); queda extenderlo a toda sonda nueva y a los helpers de los
  proyectos que copien el patrón.
- **Nombres de proyectos en el árbol público.** Entradas antiguas del CHANGELOG, un comentario de
  `lib.sh`, el README del banco y `.gitattributes` nombran proyectos que usan el arnés. Son nombres,
  no hallazgos; retirarlos es una decisión editorial del propietario.
- **REQ ya redactados en la rama 1.30.3 y a la espera de su versión:** REQ-007 (clave decorada y
  destino entrecomillado; 1.31.0) y REQ-008 (informe de proyecto con avance, bloqueos, decisiones
  pendientes y marca, como evolución de `arnes-panel`; 1.33.0).

### Decisiones de la coordinadora al abrir 1.31.0 (2026-09-05)
- **«JSON vacío = FAIL»** no lleva REQ: es un invariante del banco, exigido por el QA y escrito en
  `tests/escenarios/hooks/README.md` por el desarrollador en 1.31.0.
- **Nombres de proyectos consumidores en el árbol público**: decisión editorial del propietario; sin
  versión asignada. Igual que el hallazgo informativo SEC-008 (cuentas de GitHub en `AGENTS.md`); la
  salida propuesta es sustituir nombres por roles.
- **Adyacentes de REQ-009 que quedan en el backlog sin versión:** avisar cuando la prosa diga «0
  entradas» y haya `###` debajo; consolidar los ~8 procesos del hook de parada en ~4 (REQ-009 retira uno).
- **REQ-005:** la lista por defecto de `git.prohibidos` usa `clean -f` (flags cortos casan por letra dentro
  de un grupo) y desglosa `stash`; **REQ-004:** el nombre de sección casa de forma exacta, nunca por prefijo.
  Ambas decisiones ya están en los REQ con su historial.

## 1.35.0 — el working set explícito: qué entra en contexto, y qué se conserva sin entrar

> **Origen:** análisis pedido por el propietario (2026-09-05) sobre administrar «temperaturas de
> contexto» (HOT/WARM/COLD). Veredicto: **hacerlo pero simplificar**, y en este orden. La medición
> va primero porque el reparto del peso **cambia por proyecto**: en este repositorio la historia es
> el 10–20 % de un REQ (14 KB de 69 KB; 7 KB de 72 KB: lo que pesa son los criterios), mientras que
> en un proyecto real el REQ mayor tiene 244 KB dominados por su historia. Un mecanismo que aquí
> ahorra poco, allí ahorra mucho: el arnés trae el mecanismo, el proyecto pone el umbral.

- **1. Medir antes de construir (A/B, sin código nuevo).** Tres ramas sobre una copia de un proyecto
  real: (A) tal cual; (B1) sólo con la historia rotada fuera del REQ —el mecanismo de 1.31.0—;
  (B2) B1 más los REQ cerrados archivados. Tres comisiones repetidas por rama (analista redactando
  un REQ del módulo con más historia, desarrollador corrigiendo, QA validando). Se mide desde la
  transcripción de cada agente: tokens de entrada, lecturas de caché, número de `Read`/`Grep`/`Glob`,
  bytes por lectura, archivos distintos abiertos, tiempo hasta la primera edición, tiempo total, y
  dos de calidad: **veces que faltó un documento histórico** y **veces que se abrió un REQ cerrado
  que no se usó**. Si B1 captura casi todo el ahorro, B2 se justifica por claridad y no por tokens
  — y eso también es una respuesta.
- **2. Adelgazar `AGENTS.md` y su plantilla.** Es el mayor coste **fijo** del working set y se paga
  en cada agente y en cada arranque: 26 KB ≈ 6.600 tokens × 4–5 agentes por REQ. Medido en una sola
  sesión de este repositorio con quince agentes despachados: del orden de **100.000 tokens de
  entrada sólo por ese archivo**. Se conservan las reglas que **gobiernan** (§5, §6, §7, §13) y el
  resto se delega a archivos referenciados que se leen bajo demanda. Rinde más que archivar 135 REQ,
  y rinde en **todos** los proyectos que instalan el arnés, no sólo en los grandes.
- **3. Archivar los REQ cerrados, con índice derivado.** `requirements/archive/<ID>.md` (sin
  subcarpetas por año: el ID ya es único) más `archive/INDEX.md` **derivado** entre marcadores, como
  el bloque de `docs/ESTADO.md`. Cinco columnas y ninguna más: id, título, módulo, fecha de cierre,
  commit; los veredictos no se indexan porque son invariante del archivado, y **ninguna etiqueta
  redactada por el modelo** — un índice interpretado es un resumen disfrazado.
  - **`archivado` NO es un Estado del REQ.** Sería reescribir la cabecera de un documento que debe
    quedar intacto, pasar por la puerta como una edición más, y añadir un valor al vocabulario que
    leen tres lectores. Es **sólo ubicación física**: `git mv`, cabecera intacta, `completado` sigue
    siendo terminal.
  - **Fuera de `guard-completado` y del hook de parada.** Una puerta valida; no mueve archivos ni
    reescribe índices. Operación aparte: `tools/arnes-archivar.sh` con `plan | aplicar | verificar`
    y una skill que sólo lo envuelve y pide confirmación. Precondición: árbol de git limpio. Plan en
    `.arnes/archivado.md`, un **solo** commit, verificación releyendo el disco (origen ausente,
    destino byte a byte igual a `git show HEAD:<origen>`, mismo total de REQ leídos), y rollback por
    `git revert`. `/arnes-upgrade` **nunca** archiva: informa de que hay plan.
  - **Recuperación sin embeddings:** grep sobre el índice, grep de nombres —no de contenido— sobre
    `archive/`, y `git log --follow`. Referencia canónica = el **ID**; `tools/arnes-ref.sh REQ-021`
    resuelve la ruta actual. No se reescriben REQ vivos para arreglar enlaces: sería editar el
    contrato por un motivo de almacenamiento.
- **4. Lo que NO se construye, y conviene dejarlo escrito:** estados nuevos del REQ; subcarpetas por
  año; **resúmenes generados**; clasificador de relevancia (la ubicación y el encargo ya clasifican);
  índices escritos a mano (segunda transcripción, la familia de REQ-003); embeddings, base vectorial,
  grafo, servicio de indexación o «agente de memoria». Si tres carpetas y un índice derivado
  resuelven el 80 %, eso es lo que se construye.
- **Ya cubierto en 1.31.0:** REQ-004 (rotación de `## Historial de cambios` fuera del REQ) es la
  primera mitad de esta estrategia y su MVP: se mide con B1 antes de construir nada de lo demás.

### Observado en el ciclo 2 (2026-09-06): el índice de `requirements/README.md` es una copia a mano

Las columnas `Estado`, `QA` y `Seguridad` del índice **repiten** campos que ya viven en la cabecera de
cada REQ. Se desfasaron **tres veces en un solo día**: el analista las corrigió dos veces y la
coordinadora una tercera. Es la misma familia que REQ-003 (una regla, un lector) y que REQ-009 (una
cuenta, un contador), aplicada a un artefacto de documentación en vez de a una puerta.

**Mecanismo propuesto, para su REQ:** el índice pasa a ser un bloque **derivado** entre marcadores,
escrito por el mismo lector que usan la puerta y el informe —igual que el bloque de `docs/ESTADO.md`—,
y lo de fuera de los marcadores (el título, la descripción, las secciones de vocabulario) se sigue
escribiendo a mano. Encaja con REQ-008, que ya deriva estas mismas cifras para el informe: la función
se escribe una vez y la usan los dos. Candidata: **1.33.0**, con REQ-008.

**Mientras no exista**, en el índice queda escrita la advertencia de que no es fuente y de que manda
el REQ. Es lo barato que se puede hacer hoy sin abrir otro frente.

### 1.32.0 — la rotación de la historia de un REQ no rota nada donde más falta hace (medido)

`REQ-004` (1.31.0) rota **una sección declarada** de un documento, y su caso de uso principal es la
`## Historial de cambios` de un REQ, que es donde se acumula el peso. Medido sobre este repositorio al
cerrar 1.31.0: la sección de un REQ real pesa **19 813 bytes**, unas 20 veces el umbral, y la rotación
reconoce **0 entradas**. Extendido a los 11 REQ: **0 entradas reconocidas y 94 filas de tabla**. La
historia de un REQ se escribe como **tabla Markdown**, y una fila de tabla no es una entrada para el
contador.

**Por qué no entró en 1.31.0, y la decisión está medida:** no cabe como parche. Hay que decidir qué se
hace con el separador `|---|`, con la fila de cabecera —que no se archiva, o el archivo queda sin
encabezado y el origen sin tabla— y cómo queda el puntero dentro de una tabla partida en dos. Son
criterios de aceptación nuevos, no un patrón más. Y el riesgo de esperar es **cero**: la rotación viene
apagada y, desde 1.31.0, quien la encienda **ve el aviso** de que la sección existe pero no tiene
entradas reconocibles. Un fallo mudo pasó a ser un fallo diagnosticable, que es lo que 1.31.0 podía
comprar honestamente.

**Para su REQ en 1.32.0:** reconocer filas de tabla como entradas, con la cabecera y el separador
tratados aparte, el puntero coherente en las dos mitades, y el par fail-before/pass-after sobre un REQ
real de este repositorio. Enlaza con la estrategia de working set de 1.35.0: éste es el mecanismo que
mide su rama B1.

### 1.32.0 — deuda que deja el ciclo 2, ya con dueño y criterio escrito

Todo lo de aquí tiene **criterio en su REQ** y no depende de que nadie lo recuerde:

- **REQ-007 bloques B y C** (cabecera fuera de alcance; destino entrecomillado en el detector de Bash) y
  **CA-36…CA-39**. Con ellos cierra REQ-007, que hoy cruza dos ventanas.
- **REQ-007 CA-64.1-bis y CA-64.2-bis**: el texto humano posterior a los marcadores **sube** por encima
  del bloque en cada parada, y un `docs/ESTADO.md` en modo 444 se reescribe igual y pasa a 644. Los dos
  son heredados de v1.30.3, ninguno pierde un byte, y por eso se aceptaron como residual; el arreglo
  está exigido.
- **REQ-011**: la puerta posterior (`PostToolUse`), que es la respuesta de fondo a la palabra del estado
  terminal partida en expansiones.
- **QA-113 / LIM-10**: un token entrecomillado o escapado no llega al análisis (`git clean "-f"` pasa).
  Se cierra con el bloque C, y las seis formas ya tienen caso para que se muevan **a la vez y en voz alta**.
- **SEC-013**: la nota que heredan los proyectos enumera un envoltorio y ahora se toleran siete; una
  denegación legítima llegaría sin estar anunciada.
- **QA-109 y QA-114**: criterios que llegaron después de la implementación, o que se contradicen entre sí.
- **La rotación no reconoce filas de tabla**, así que no rota la historia de un REQ — su caso de uso
  principal. Medido: 0 entradas y 94 filas en los REQ de este repositorio.
- **Los dos rotadores no retiran su temporal si el proceso muere por señal**, la misma familia que se
  cerró en el hook de parada. Vienen apagados y nadie lo ha medido.

**Y una migración pendiente de este repositorio:** 1.31.0 **sí** cambió plantillas (`AGENTS.md.tpl`,
`requirements-README.md.tpl`, `PENDING_APPROVAL.md.tpl`, `arnes-config.json.tpl`), así que este proyecto
tiene andamiaje que poner al día con `/arnes-upgrade` — y su Fase 5 la ejecuta ahora el `desarrollador`,
porque el manifiesto entró en su propia frontera. Se hace en la sesión siguiente, que es la que corre el
plugin 1.31.0.

### 1.32.0 — dos cosas que llegaron de un proyecto real después de publicar 1.31.0

- **La skill de actualización no dice que hay que reiniciar la sesión, y eso vale para todos.**
  Comprobado con `grep`: ni `skills/arnes-upgrade/SKILL.md` ni ninguna plantilla lo mencionan; sólo lo
  dice `docs/gobernanza/autoalojamiento.md`, que **los proyectos no heredan**. Consecuencia medida por
  un consumidor: actualizó a 1.31.0, la migración quedó aplicada y verificada, y las puertas nuevas
  **no estaban en vigor** — lo descubrió con una sonda que 1.30.3 permite y 1.31.0 deniega, con control
  positivo en la misma tanda para descartar que los hooks estuvieran caídos. Un proyecto que no lo sepa
  cree que está protegido por reglas que no corren. Es barato: un aviso al final de la migración, y una
  línea en la plantilla de `AGENTS.md` §13. Es lo que más rinde de esta lista por lo poco que cuesta.
- **Falso positivo de la regla del orden, sin reproducir aún.** El mismo proyecto reporta que la puerta
  deniega cuando el veredicto de **QA** menciona la cadena `Seguridad:` en su evidencia, aunque no toque
  ese campo. No pude reproducirlo: con un REQ cuyo `QA: aprobado` nombra el campo en el paréntesis, sale
  **permitido** en 1.30.3 y en 1.31.0. Falta el fragmento exacto —la línea del `new_string` tal cual y si
  fue `Edit` o `MultiEdit`—; el reportante dice que molesta a diario, así que merece cerrarse en cuanto
  llegue. **No se redacta REQ hasta tener la reproducción:** un criterio escrito sobre un defecto que no
  se ha visto describe lo que imaginamos, no lo que pasa.
