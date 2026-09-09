# Pendientes del arnés — lo que sigue, en orden

> **AVISO (2026-09-06): los rótulos de versión de este archivo están desfasados.** La reordenación de
> hoy reservó 1.32.0 para las palancas de coste y movió el resto una ventana. **El reparto vigente por
> versión vive en `docs/PLAN.md`**, que es el que manda; aquí queda la cola cruda con su evidencia y su
> medición, que sigue siendo válida aunque el número de versión de un bloque no lo sea.

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

## Regla de acumulación (propietario, 2026-09-08) — qué se resuelve ya y qué espera aquí

**Las mejoras se acumulan; los errores críticos se resuelven de inmediato.** Dicho por el propietario
tras un día en que se abrieron **9 hallazgos y se cerró 1 REQ**.

**Se resuelve ya** —y sólo esto— lo que hace que **el mecanismo falle en abierto para un proyecto
consumidor**: una puerta que no cierra lo que dice cerrar, un guardián que se puede rodear en silencio,
un veredicto que se firma sin acreditar. Es lo que ya bloquea por máquina: clase `usuario/dinero` o
`contrato`.

**Se acumula aquí, sin excepción:** discrepancias de documentación, criterios mejorables, defectos de
instrumento, y toda mejora de eficiencia. Se **registran igual** en su sede (`registro-seguridad.md`,
`docs/qa/`), **no abren REQ nuevo** y **no entran en la ventana en curso**. Se revisan **una vez por
ventana**, al planificarla.

> **La distinción que hace útil la regla:** un hallazgo que dice *«el documento describe mal lo que el
> código hace»* **no es crítico** si el error va en la dirección segura —el papel promete **menos** de lo
> que la máquina cumple—. Sí lo es si va al revés: el papel promete una protección que no existe, porque
> alguien la usará creyendo que está cubierto.

### Acumulado del 2026-09-08 — `REQ-019` F1, enumeración A (11 discrepancias, **ninguna crítica**)

Medidas por una enumeración ciega de invariantes sobre `AGENTS.md` (66 elementos) y
`requirements/README.md` (40). Clasificadas contra la regla de arriba: **ninguna hace fallar el mecanismo
en abierto para un consumidor**, así que **todas esperan**.

| # | Qué | Por qué NO es crítica |
|---|---|---|
| **D-04** | `AGENTS.md` §8/§13 prometen que el hook `pre-commit` exige el CHANGELOG. Existe y funciona (`.githooks/pre-commit:6`), pero **`.githooks/` no está en `codigo_app.globs`**: cualquier agente puede editarlo sin que `guard-codigo` lo vea | Es gobernanza interna del repositorio, no una puerta que proteja a un consumidor; y una edición ahí **aparece en el diff**. Es la de mayor prioridad del lote |
| **D-03** | §4 describe la superficie protegida **más estrecha que la real**: omite `.arnes/config.json` y `.claude-plugin/*`, que `codigo_app.globs` sí protege | **Dirección segura**: el papel promete menos de lo que la máquina cumple. Un lector cree que no puede editar el manifiesto, y en efecto no puede |
| **D-10** | El tope de 3 vueltas dev↔QA se enuncia como límite duro con consecuencia mecánica, y **ningún hook cuenta vueltas** | Lo cumple la coordinadora, y hoy funcionó: `REQ-021` paró en la tercera |
| **D-01** | El candado `🔒` marca 7 bloques y **2 no los cumple ninguna máquina** (el modelo de QA, la política de autoalojamiento) | Los dos son decisiones del propietario, correctamente descritas; el candado es lo que sobra |
| **D-02** | Un bloque `🔒` con dos obligaciones y **una sin ejecutor**: «mantén la lista de gates idéntica aquí y en el manifiesto» no la comprueba nada | Hoy coinciden **byte a byte**, verificado. El riesgo es futuro |
| **D-05** | El README dice que la puerta exige `Seguridad: aprobado` por **sensibilidad**; el código lo exige por **rigor efectivo `critico`** | Hoy coinciden porque la sensibilidad impone `critico` como suelo |
| **D-06** | La tabla de Estados es una **segunda transcripción** de `.arnes/config.json`; sólo `completado` llega a una puerta | Los otros cinco valores sólo los mira el informe, que **avisa y no deniega** |
| **D-07** | La acotación de `SEC-020` («rutas sin decoración») tiene **dos sedes** con redacciones distintas del mismo fallo | Es la familia de la doble transcripción, ya nombrada; `SEC-020` sigue con su propio dueño |
| **D-08 / D-08b** | El `## Índice` anuncia que «está previsto convertirlo en bloque derivado» y **no hay marcadores ni herramienta**. Y los marcadores de versión de `arnes-upgrade` sobre el README son **3 filas**, sin cubrir la sección del criterio | Anuncio sin dueño; el desfase del índice ya está contratado para 1.34.0 |
| **D-09** | **Dos enumeraciones del mismo conjunto dentro de `AGENTS.md`**: §5 lista el detector de Bash más **estrecho** que §13, sin marca de `no exhaustivo` ni puntero al sitio único | Si §13 se delega y §5 se queda, lo que sobrevive es **la lista corta** — riesgo del reparto de `REQ-019`, no del árbol de hoy |
| **D-11** | Tres pares §13-fila ↔ `🔒` comparten **el mismo ejecutor** en dos sedes. Parecen redundantes y **no lo son** | Trampa para el reparto de `REQ-019`, no defecto del árbol |

**Y el dato que cambia la planificación de `REQ-019`, medido y sin decidir:** el **suelo forzado** es
**≈0,70×** en `AGENTS.md` y **≈0,66×** en el README (**≈0,68×** total) contra el techo de **≤0,60×** que
`CA-07` contrata. **El techo no se alcanza**, y la predicción del propio REQ esperaba el problema **sólo
en el README**. En bytes será peor que en líneas, porque las dos poblaciones de líneas más largas —la
tabla de §13 y el `## Índice`— son suelo al 100%. Además la línea base del REQ está **desfasada**:
declara el README en **433** líneas y tiene **522**. Renegociar ese techo es firma del propietario.

### Acumulado del 2026-09-08 — `REQ-019` F1, enumeración B: **tres defectos en los criterios del propio `REQ-019`**

La segunda enumeración ciega encontró **164** invariantes (103 + 61) contra las **106** de la primera.
**La diferencia es el resultado**: ninguna de las dos era completa, y `CA-15.2` exige la unión
precisamente por eso. Las dos coinciden en el titular —**el suelo excede el techo en los DOS
documentos**, no sólo en el README como el REQ predecía— y las dos midieron por separado que la línea
base del REQ está desfasada (declara el README en **433** líneas; tiene **522**).

**Y encontró tres defectos en los criterios de `REQ-019` mismo, que hay que arreglar ANTES de repartir:**

| # | Defecto en el criterio | Por qué importa |
|---|---|---|
| **D-3** | `CA-02.4.1` contrata las **anclas citadas por el mecanismo** sólo para el README. Pero `AGENTS.md` **también** las tiene: **§1 se cita en 11 mensajes de denegación** (`guard-completado.sh` L55, 138, 160, 192, 320, 359, 436, 443, 452, 459, 539), y §5, §6, §7 y §9 en otros nueve | **§1 es el caso peor**: es la sección más citada de todo el mecanismo **y la que más parece un lema** —«Principio rector», siete líneas—. El filtro la mandaría fuera sin que nadie se equivocara, y once mensajes de runtime quedarían apuntando a una sección que ya no existe |
| **D-5** | Un marcador de versión de `arnes-upgrade` **ya no resuelve**: busca `(preventiva)` con paréntesis, y el texto vigente dice `Seguridad: preventiva`. **Cero apariciones.** No puede dispararse nunca | Es la demostración **medida** de que un marcador se muere sin que nadie lo note — el riesgo exacto que `CA-02.4.2` existe para acotar, ocurriendo ya |
| **D-9** | `CA-02.2` manda conservar **«la primera frase»** de cada bloque `🔒`. En **4 de los 7** esa primera frase es un **rótulo**: «Cumplido por máquina:», «Vigilado por máquina:» | Aplicado literalmente, **conserva el rótulo y delega la obligación** — lo contrario de lo que el criterio busca |

**Más `D-2`**, que es de forma: diez elementos son **mixtos** —una sub-promesa que sí cumple una máquina
dentro de un bloque cuyo resto no cumple nadie— y `CA-17.1` exige **un** valor por fila. El campo no
tiene forma de decir «parcial».

**Lectura para cuando se retome:** `REQ-019` no está listo para repartir. Necesita, en este orden,
(1) renegociar el techo de `CA-07` con firma del propietario —el suelo es 0,63-0,68× contra un techo de
0,60×—, (2) corregir `D-3`, `D-5` y `D-9` en sus propios criterios, y (3) re-medir su línea base contra
el commit real. Es la misma lección de `CA-18`: **comprobar la factibilidad antes de construir**.

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
- **El hueco del intérprete: PENDIENTE, ni prevenido ni detectado.** Un `python x.py` que escribe no se
  cierra como **prevención** —eso es imposible: la ruta vive dentro del archivo y el detector sólo lee
  el texto del comando— y **tampoco está cerrado como detección**: la puerta posterior está
  **diseñada y pendiente en REQ-011**. Verificado el 2026-09-07 contra el plugin instalado:
  `PostToolUse` **no existe en `hooks/`, `tools/` ni `.claude-plugin/`**, y `hooks/hooks.json` registra
  exactamente `PreToolUse`, `Stop` y `SubagentStop`. Aparece cuatro veces en el árbol y **las cuatro en
  documentos de planificación**.

  > **Corrección del 2026-09-07, y la falta era grave.** Esta viñeta decía *«Límite documentado, **no
  > pendiente**: … se cierra como detección con la puerta posterior de 1.32.0»* — en pasado, sobre un
  > mecanismo que nunca se construyó, y **contradiciendo a otras dos viñetas de este mismo archivo** que
  > lo declaran por hacer. Es otra vez **un dato correcto archivado en la categoría equivocada**: «no
  > pendiente» cuando sí lo está. Y no era una fila cualquiera — **es la que le dice al lector que el
  > hueco está atendido, así que quien la lee deja de buscar.**
  >
  > **Coste real y medido, no hipotético:** un proyecto consumidor estuvo a punto de **retirar su regla
  > de usar `Edit`/`Write` para lo que una invariante protege**, cerrando su propia mejora sobre este
  > mecanismo inexistente. Paró porque su encargo exigía comprobar **en el código** y no en el registro
  > ajeno. Su `AGENTS.md` decía *«el arreglo de fondo, ya **diseñado** upstream»* — presente de diseño,
  > no de existencia—, que es la redacción correcta y la que nos salvó.
  >
  > **Y la corrección no es cambiar «1.32.0» por «1.34.0»**: eso vuelve a fechar una promesa. Es decir
  > **qué es hoy**, que es lo que está escrito arriba. La forma que este repositorio ya usa para todo lo
  > demás, aplicada por fin a sí mismo. **Va a la pasada de conformidad de 1.34.0 como cuarta promesa
  > más ancha que el código**, junto a las tres que ya estaban.

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

### 1.32.0 — el ciclo cuesta demasiado, y la causa dominante es evitable

**Línea base medida (ciclo 2, siete REQ, cuatro vueltas del bucle).** Tiempo de reloj de cada agente,
tomado de su propia entrega; no incluye la orquestación ni las corridas de control de la coordinadora:

| Rol | Comisiones | Tiempo | Notas |
|---|---:|---:|---|
| `desarrollador` | 8 | ~2 h 22 | de 3,5 a 27 min cada una |
| `qa-tester` | 4 | ~1 h 32 | de 18 a 31 min |
| `analista-requerimientos` | ~11 | ~1 h 03 | de 2 a 12 min |
| `auditor-seguridad` | 2 | ~26 min | 13 min cada una |
| **Total de agente** | **25** | **~5 h 23** | más orquestación y ~20 corridas de banco a 18 s |

**Una vuelta del bucle cuesta unos 50 minutos** entre desarrollador, QA, control y write-back. Cuatro
vueltas son tres horas y media: **la mayor parte del ciclo**.

**El diagnóstico, con los hallazgos delante.** De los veinte hallazgos del ciclo, **siete fueron que el
criterio decía algo falso sobre lo construido**, no que el código estuviera mal: enumeraba tres
envoltorios cuando el código toleraba siete; fijaba un número que la medición desmintió; exigía
igualdad de coste donde debía exigir techo, convirtiendo una mejora en un fallo. **Uno de ellos costó
una vuelta entera.** Es la clase de hallazgo más frecuente del ciclo y es evitable escribiendo distinto.

**Lo que NO es el problema, para no optimizar la parte equivocada:** que QA vaya antes que el auditor no
se puede paralelizar —su firma acreditaría un árbol sin validar, que es justo el fallo que la regla
evita— y las corridas de banco de la coordinadora suman seis minutos en todo el ciclo. El cuello real
son **dos archivos monolíticos**, `hooks/lib.sh` y el banco, por los que pasa casi todo: mientras lo
sean, dos comisiones en paralelo colisionan.

**Y el contexto que evita la conclusión equivocada:** este repositorio se impone la **ceremonia máxima**
a propósito —todo REQ es crítico y sensible, así que pasa por los cuatro agentes—. Un proyecto con rigor
`estandar` se salta al auditor y con `ligero` también al QA. Las cinco horas son el techo de quien
construye el mecanismo, no lo que paga quien lo usa.

**Tres cambios, en orden de rendimiento, para medir en 1.32.0 contra esta línea base:** criterios por
mecanismo y no por enumeración; paralelizar por REQ con un mapa explícito de qué archivo toca cada
comisión; y partir el banco en archivos por sección para que el QA también pueda paralelizarse.

### Decisión pendiente de aplicar al abrir 1.33.0 (tomada 2026-09-06, no cuesta nada hasta entonces)

Al mover REQ-011 y los bloques B y C de REQ-007 a la misma ventana 1.33.0, el analista señaló que se
pierde una propiedad: REQ-011 iba a medirse contra un árbol donde el detector de REQ-007 ya estuviera
**publicado**, para que un veredicto que cambiara fuera inequívocamente suyo.

**Decisión: van los dos en 1.33.0, REQ-007 bloques B y C primero dentro de la ventana**, y los dos se
miden contra **v1.32.0 publicada**. La propiedad que preocupaba **no se pierde de verdad**, y ésta es la
razón: los dos mecanismos viven en **eventos distintos**. REQ-007 corrige el detector que decide *antes*
(`PreToolUse`); REQ-011 construye la puerta que pregunta *después* (`PostToolUse`). Un veredicto de
permitir o denegar que cambie sólo puede venir del primero; la evidencia del segundo es de otra
naturaleza — «algo protegido cambió en disco y la puerta posterior lo reportó»—, y eso ningún arreglo
del detector previo puede producir. Son distinguibles por construcción, no por orden.

Sí colisionan por archivo (`hooks/lib.sh` y `hooks/hooks.json`), así que **no se despachan a la vez**:
es la primera aplicación real del mapa de archivos de REQ-013, y conviene que lo sea.

**Aplicación:** el write-back va en el REQ cuando se abra 1.33.0, no ahora. Escribirlo hoy costaría una
comisión de analista (~4 USD medidos) para un texto que nadie lee hasta entonces, y la decisión ya está
escrita aquí con su razón. Es la disciplina de coste aplicada a nosotros mismos.

## El cuello del paralelismo no era el que creíamos (medido el 2026-09-06, ciclo 3)

`tools/arnes-paralelo.sh` midió los 15 pares de comisiones del ciclo sobre el árbol de v1.31.0:

| Archivo | Pares que colisiona |
|---|---|
| `skills/arnes-upgrade/SKILL.md` | **15 de 15** |
| `tests/escenarios/hooks/run.sh` | 10 de 15 |
| `hooks/lib.sh` | **1 de 15** |

Llevábamos dos ciclos tratando `hooks/lib.sh` como el cuello. Partirlo **no habría desbloqueado ni un
par**. El que bloquea todo es la skill de migración, y no porque sea grande ni porque se ejecute —no
corre durante el ciclo—, sino porque la regla «todo lo que un proyecto hereda se documenta para la
migración» obliga a **cada** comisión a escribir su párrafo en el mismo archivo.

**La salida, encontrada por accidente en este ciclo y verificada:** la comisión B tenía prohibido tocar
ese archivo, así que **entregó el texto en su informe** y la comisión C lo integró al pasar. Sin
fricción y sin comisión extra. Generalizado: **la nota de migración se escribe una sola vez al cerrar
la ventana**, con el texto que cada comisión dejó, en vez de por cada comisión al terminar. Elimina la
colisión en vez de repartirla.

**Clase `instrumento`.** No bloquea nada; es una palanca de coste. Candidata a 1.33.0 si la ventana lo
admite, y si no, a 1.34.0 junto al resto de lo que los proyectos leen.

## El agujero del intérprete, ejecutado por la coordinadora (medido el 2026-09-07)

**Qué pasó.** Al cerrar la ventana 1.32.0, la coordinadora escribió el estado terminal de dos REQ con
un heredoc de `python3` que abre el archivo y lo reescribe. **`guard-completado` no lo vio**: la
escritura pasó sin que ninguna puerta juzgara veredictos, cola ni quality gates. Se revirtió y se
repitió con `Edit`, que sí pasa por la puerta y esta vez aceptó — los veredictos estaban en su sitio,
así que el cierre era legítimo. Lo que falló no fue el cierre: fue que **nadie lo comprobó**.

**Por qué no es un fallo del hook.** `AGENTS.md` §13 ya declara esta clase como el agujero más grande
de los que quedan: «los **intérpretes** —`node script.mjs`, `python x.py`: la ruta vive dentro del
archivo y el detector sólo lee el texto del comando». El detector leyó `python3 - <<PY` y no vio
ninguna de las formas que reconoce.

**Por qué vale registrarlo.** Hasta hoy esa clase estaba **argumentada** y no **medida**. Ahora hay un
caso real, con fecha, ejecutado por el agente que más ha insistido este ciclo en que las puertas se
respetan — que es exactamente el perfil de quien se salta una barandilla por costumbre y no por
intención. Es el **forzador medido** que le faltaba a **REQ-011, la puerta posterior** (ventana 1.33.0):
deja de preguntar *antes* si un comando va a escribir y pregunta *después* si algo protegido cambió.
Ningún patrón más largo cubre esta clase; un intérprete siempre puede esconder la ruta.

**Y un factor agravante que conviene nombrar:** la coordinadora tenía instrucción de sesión de preferir
`Bash` sobre las herramientas de edición. Una preferencia de herramienta que nadie relacionó con el
enforcement acabó desactivando una puerta. Cuando exista la puerta posterior, esto dejará de depender
de qué herramienta se elija.

**Clase `contrato`** — no porque el cierre fuera indebido, sino porque `AGENTS.md` §13 describe una
cobertura de `Bash` que esta vía deja por debajo de lo que un lector razonable entendería. Dueño:
REQ-011, ventana 1.33.0. Cierra cuando la puerta posterior detecte este mismo caso.


## Una nota al margen desactiva el bloqueo de la cola de aprobaciones (medido el 2026-09-07, QA de 1.32.1)

**Qué se midió.** `arnes_cola_pendientes` descuenta **la línea entera que contiene `<!--`**, así que
una entrada de la cola con una nota detrás deja de contar:

| `PENDING_APPROVAL.md` | 1.32.0 | 1.32.1 |
|---|---|---|
| `### Fusionar el PR 41` | DENY | DENY |
| `### Fusionar el PR 41 <!-- pendiente de Juan -->` | **ALLOW** | **ALLOW** |

**Idéntico en las dos versiones: 1.32.1 no lo introdujo ni lo tocó.** Es la respuesta a la pregunta
que le hice a QA sobre la tercera desviación del desarrollador: la decisión de **no** unificar
`arnes_cola_pendientes` con la noción de cita de REQ-016 fue **correcta**, y no crea ninguna
divergencia nueva. Su noción de comentario es de grano de **línea** y la documenta REQ-009
(CA-04/CA-07); unificarla habría cambiado el **conteo** de la cola, y un cambio de conteo en la cola
es un cambio de veredicto en la puerta.

**Dónde está el defecto entonces.** No entre dos lectores, sino entre el **documento y el código**:
`PENDING_APPROVAL.md` línea 15 promete que «lo que **caiga dentro** de un comentario HTML no cuenta»,
y en `### Pendiente real <!-- nota -->` la entrada **no cae dentro** de nada — y deja de contar igual.
Quien escriba una nota al margen desactivará el gate de `AGENTS.md` §6 sin saberlo, y el gate existe
justo para lo que menos conviene perder: la fusión a `main`, el tag y la publicación.

**Clase `contrato`** — la prosa que un humano lee promete algo más estrecho que lo que el código hace.
**Nace ≤1.30.x. Dueño y ventana: sin asignar, y NO va en `Hallazgos abiertos:` de REQ-015 ni de
REQ-016** — bloquear una ventana por un defecto que no introdujo es exactamente lo que la tabla de
clases de `requirements/README.md` existe para evitar.

**Las dos salidas, y la asimetría entre ellas.** Alinear el código con la prosa (contar la entrada y
descontar sólo lo citado) cambia el **conteo** y por tanto los veredictos: es un cambio de conducta de
un gate, con su REQ y su fail-before. Alinear la prosa con el código es un párrafo. La segunda no
arregla el descuido —seguirá bastando una nota al margen—, pero al menos deja de mentir. La decisión
es de quien tome la ventana.

## Dos cosas que el write-back de 1.32.1 dejó decididas para 1.33.0 (2026-09-07)

### El informe calla cuando un campo existe SÓLO dentro de un comentario — decisión (b): fuera de la ventana

**Qué se midió.** Un REQ cuya cabecera dice en letra `Hallazgos abiertos: SEC-9 (usuario/dinero)`
dentro de un comentario **cierra**, y `tools/arnes-lectura.sh` responde «Ningún valor anómalo» con
`rc=0`. El estado alcanzable **no es nuevo** —comentar equivale a borrar, y la ausencia se perdona por
compatibilidad—, pero la vía de visibilidad que el registro de la ventana daba por existente **no
existe**: CA-05 habla de claves **decoradas** y CA-06 de **dos** declaraciones del mismo campo, y un
campo declarado sólo dentro de un comentario no es ninguna de las dos.

**Por qué se aplaza, y las razones son del analista, que las dio mejor que yo.** El write-back queda
honesto escribiendo la verdad —CA-11 de REQ-016, «comentar retira»— y no añadiendo una función; la
visibilidad es defensa en profundidad, no la corrección de la promesa falsa. Y sobre todo: **el aviso
mal acotado enterraría lo real bajo lo inofensivo**, que es justo lo que CA-06 existe para evitar. Lo
anómalo **no** es que haya veredictos citados —esa es la práctica que REQ-016 protege—, sino que la
**única** declaración de un campo viva dentro de un comentario. Ese discriminante hay que decidirlo,
no improvisarlo en una vuelta de parche.

**Consecuencia asumida y escrita:** ningún criterio de 1.32.1 promete visibilidad, y CA-02 ya no se
apoya en ella. Dueño: `analista-requerimientos`. Ventana **1.33.0**.

### Una promesa sin condición que es falsa cuando el campo no se declara — va a la pasada de conformidad

**Qué se midió** (lo encontró el analista con el control D1/D2 de QA, y a QA se le había escapado):
`requirements/README.md` dice que el hook **impide** marcar `completado` sin `QA: aprobado`, y la fila
de `AGENTS.md` §13 promete lo mismo **sin condición**. Es falso cuando el campo **no se declara**: la
ausencia se perdona por compatibilidad con los REQ anteriores a que los veredictos existieran.

**Clase `contrato`**, y es **superficie heredada más ancha que el código** — la misma clase que
`ADR-002` (el alcance honesto de la guarda estática) y que CA-08 de REQ-015. Nace ≤1.29.0; **esta
ventana no lo introdujo**.

**Decisión de la coordinadora: no entra en 1.32.1.** Son dos líneas de prosa, pero viven en dos
archivos con **dos dueños distintos** —`AGENTS.md` es alcance de desarrollo en esta ventana,
`requirements/README.md` es del analista—, así que meterlo en la vuelta 1 cuesta una comisión más para
arreglar un defecto que el parche no causó, y un parche que crece es cómo se descontroló el ciclo
anterior. Va a la **pasada de conformidad anticipada de 1.33.0**, que existe exactamente para esta
clase: recorrer la superficie heredada y estrechar cada promesa hasta lo que el código hace. Junto a
`ADR-002`/REQ-011 y a la decisión (b) de arriba, ya son **tres** en la misma pasada, y eso la hace
barata en vez de cara.

## SEC-029: el nombre de un proyecto consumidor estuvo publicado, y el control no podía verlo (decisión del propietario, 2026-09-07)

**Qué pasó.** `CHANGELOG.md:1615` nombraba a un proyecto consumidor en el repositorio **público**.
Aparición **única**, introducida por `73f9452` (PR #26), presente en `origin/main` y en los tags
**v1.29.3, v1.31.0 y v1.32.0**. Lo encontró el `auditor-seguridad` en R-007, **fuera de su guion**.

**El presente está corregido** (la línea dice ahora «un proyecto real»), y en el contenido no había
datos, ni REQ, ni hallazgos del cliente: sólo que una medición se hizo allí.

**Decisión del propietario (Juan, 2026-09-07): el historial y los tags se quedan como están, con el
residual declarado.** Reescribir el historial rompe toda clonación existente, choca con la regla
`non_fast_forward` del ruleset, obliga a mover tres tags de los que cuelga la instalación del plugin
y **no recupera ninguna copia que ya exista**. Se paga el residual y se cierra la vía.

**La causa raíz no es el descuido, y esto es lo único que hay que construir.** `docs/seguridad/
gobernanza-datos.md` §3 definía su verificación como `git diff origin/main..HEAD` — **diferencial**.
Un control diferencial **no puede encontrar, por construcción, lo que ya está en la base**: la
auditoría de REQ-001 informó «sin hallazgos» **con razón**. Es el mismo defecto que SEC-025 en otro
sitio: **preguntar por el cambio cuando la propiedad es de estado.** Van tres en una sola ventana —el
barrido de migración, este control, y los cinco casos de banco que medían el cambio y no el estado—,
y esa coincidencia ya no parece coincidencia.

**Lo que se construye, y va a 1.33.0:** un **barrido de base** (no diferencial) sobre el árbol
completo, como NFR de gobernanza de datos, junto a la comprobación por estado de SEC-025 y a la
puerta de «¿la prueba mide algo?». Las tres son la misma pregunta con tres caras, y por eso salen
baratas juntas. Dueño: `auditor-seguridad` para el NFR, `desarrollador` para el mecanismo.

## Cinco decisiones de la coordinadora, con potestad expresa del propietario (2026-09-07)

1. **El rigor pasa de declaración a propiedad comprobable.** Hoy `Rigor:` y `Sensible a seguridad:` los
   escribe una persona y **ninguna puerta los verifica** — misma clase que `arnes_version`, un campo sin
   comprobar que acaba mintiendo. Por eso este repositorio dejó todo en `critico`: bajarlo era un acto
   de fe. **En 1.33.0**, al cerrar, la máquina compara el rigor declarado con las **rutas realmente
   tocadas**; si declaró `estandar` y el diff toca `hooks/`, `tools/`, `tests/`, `.github/`, `.arnes/`
   o `.claude-plugin/`, **DENY**. Es una **pregunta de estado**, así que entra en la columna vertebral
   de la ventana sin coste de diseño propio. Con eso, bajar el rigor deja de ser peligroso y **quita un
   eslabón de la cadena** —el más caro, ~20 min— en las ventanas de documentación y plantillas.
2. **1.33.0 abre por las palancas de coste, no por los REQ.** Matar la vuelta y partir la sección
   caliente del banco valen **124 de los 145 minutos** medidos de ahorro, y son una comisión cada una.
3. **Presupuestos desde la mediana medida.** Nueve de diez comisiones de 1.32.1 se pasaron; las dos
   únicas que no fueron los write-back. Y **toda comisión declara su working set al empezar** — qué va a
   leer y **qué no**. Medido: el analista pasó de 124 804 a **59 647** tokens (y de 11 a 3 minutos)
   declarando que no leía entero ni el registro de seguridad ni el otro REQ.
4. **Publicación de 1.32.1:** si la vuelta 2 cierra SEC-024 y SEC-025 y el auditor firma, **la
   coordinadora publica bajo la delegación permanente**. El `auditor-seguridad` sostiene en R-007 que el
   `contrato` del agujero del intérprete invalida la condición «todo en verde»; **la coordinadora
   discrepa y queda escrito**: ese hallazgo tiene dueño (REQ-011) y ventana (1.33.0), y aplicar ese
   criterio significaría que el arnés no puede publicar **ninguna** versión hasta que exista la puerta
   posterior — un estándar que ninguna versión anterior cumplió.
5. **Lo que la coordinadora NO decide, con potestad o sin ella:** si el auditor **retira la firma o
   veta**, no se publica y la decisión vuelve al propietario. Un veto que el coordinador puede levantar
   no es un veto, y el veto existe justamente para no depender de que el coordinador esté de acuerdo.

## El caso J: acotar el rango no ganó la clase (reportado por un proyecto consumidor, 2026-09-07)

**Qué reportaron, verificado por la coordinadora sobre los hooks de 1.32.1 ya publicados:**

| Caso | 1.32.0 | 1.32.1 |
|---|---|---|
| **I** — `**Seguridad:** aprobado` **dentro** de `<!-- -->` | permite | **DENIEGA** |
| **J** — la misma línea **fuera** de todo comentario | permite | **PERMITE** |

Un `critico` con `Seguridad: pendiente` vigente cierra si más abajo en la cabecera aparece
`**Seguridad:** aprobado` sin comentar. Control: sin esa línea, **DENY**.

**No es un descuido: está contratado.** `CA-04` de REQ-016 declara que la tolerancia a la clave
decorada **fuera** de los rangos no se restringe, y el analista **rechazó** en 1.32.1 la propuesta de
que una ocurrencia decorada no pudiera desbancar a una limpia, con tres razones — la mejor: cambiaría
la semántica de documentos **bien formados** para arreglar uno malformado. La decisión está escrita.

**Y aun así el reportante tiene razón en lo que importa, con nuestra propia lección:** *acotar el
rango tampoco gana la clase*. Es la quinta aparición de la misma forma, y la primera aplicada a un
arreglo nuestro.

**La salida propuesta, que no es ninguna de las dos que ya se descartaron.** Ni prohibir el decorado
ni rankear formas — las dos preguntan por la **vía**. La pregunta de **estado**: *si la cabecera
declara el mismo campo dos veces con valores distintos, la puerta no puede saber cuál gobierna* →
**no es medible → DENY**. Misma familia que CA-03 y CA-12. No toca ningún documento bien formado, que
declara cada campo una vez. Y el arnés **ya lo sabe**: `CA-06` de REQ-016 hace que el informe marque
justo ese caso como anomalía con rc≠0; el conocimiento existe y la puerta no lo usa.

**El coste que tiene que decidir el REQ, no la coordinadora:** un proyecto que corrija veredictos
**añadiendo** la línea nueva en vez de editarla se rompe. Hay que saber si alguno lo hace antes de
elegir entre denegar y avisar.

**Clase `contrato`** — `AGENTS.md` §13 promete que un `critico` no cierra sin `Seguridad: aprobado`, y
por esta vía cierra con el veredicto vigente en `pendiente`. **Nace ≤1.31.0** (la tolerancia a la
clave decorada), no lo introdujo 1.32.1. Dueño: `analista-requerimientos` para la decisión de diseño,
`desarrollador` para el mecanismo. **Ventana 1.34.0** (movida el 2026-09-07 al partirse 1.33.0),
con el núcleo de preguntas de estado. **Seguimiento con el bisecado y dos correcciones medidas, al
final de este archivo.**

## Una bitácora puede perder una entrada entera sin que ningún archivo parezca roto (medido por un proyecto consumidor, 2026-09-07)

**Qué encontraron, auditándose a sí mismos:** cruzaron **toda** cabecera de bitácora que existió alguna
vez en git contra las de hoy — 410 vistas, 404 presentes. Cinco ausencias eran títulos editados
después. La sexta era una pérdida real de hace tres semanas: al escribir una entrada nueva se
**sustituyó** el título de la anterior en vez de insertar encima. Restaurada verbatim desde git.

**Lo que la hace peligrosa y por qué ninguna puerta la ve:** lo que se pierde es **la línea del borde**.
El cuerpo sigue ahí y se lee como parte de la entrada vecina — **atribuido a otro agente, otra fecha y
otro encargo**. No hay archivo corrupto, no hay diff sospechoso, no hay tamaño que baje.

**Y es otra vez la misma forma:** la comprobación que lo cazó es de **una línea**, es una pregunta de
**estado** —«¿toda cabecera que existió alguna vez sigue existiendo?»— y **no estaba escrita en
ninguna parte**. Ninguna de las seis puertas del arnés mira esto.

**Clase `instrumento`** (el arnés no promete integridad de bitácoras; hoy no promete nada sobre
ellas). Candidata a **1.33.0** junto al barrido de base de SEC-029 y al barrido por estado de SEC-025:
las tres son la misma pregunta sobre tres artefactos distintos, y por eso salen baratas juntas.

### Lo que midió el proyecto consumidor sobre el caso J, y las tres cosas que cambia (2026-09-07)

**1. La pregunta de diseño está contestada, y con un corpus real.** Contaron las 6 claves de cabecera
sobre sus **48 REQ**, normalizando el decorado igual que `arnes_norm_clave` y **contando también dentro
de los rangos**: **0 archivos** declaran un campo dos veces. La práctica de «corregir un veredicto
**añadiendo** la línea nueva» **no existe allí**; cuando reabren, editan en su sitio y el veredicto
viejo va en prosa aparte. ⇒ **denegar ante campo duplicado no rompe nada** en ese corpus. Es **un**
proyecto, no una ley: antes de cerrarlo conviene el mismo conteo en los demás.

**2. Y una pregunta de diseño que no habíamos visto, mejor que la nuestra.** Su caso real **no era un
duplicado de clave: era una clave FABRICADA por un corte de párrafo.** El texto decía
``el `Seguridad: aprobado` de R-020`` y al reflowarse dejó `Seguridad:` a columna cero. No había dos
declaraciones compitiendo — había una declaración y un **accidente tipográfico**.

De ahí la pregunta que hay que decidir **explícitamente** y que no está decidida: **¿la guarda cuenta
ocurrencias ANTES o DESPUÉS de descontar los rangos de comentario?**
- **Antes:** caza el accidente aunque viva dentro de un comentario — y marca como duplicado la
  práctica **legítima** que REQ-016 existe para proteger (documentar la historia dentro de un rango).
- **Después:** respeta esa práctica y **no ve** el accidente si cayó dentro del rango.

Las dos son defendibles y dan **puertas distintas**. Elegir sin nombrar la disyuntiva es cómo nace el
próximo fallo en abierto.

**3. Corrección a una expectativa nuestra sobre el impacto de campo.** Su única colisión real **falló
CERRADO, no abierto**: el fragmento que pisaba no terminaba en paréntesis balanceado, así que
`arnes_norm_campo` no lo resolvió y la puerta **habría denegado**.

| `REQ-008` reconstruido antes de su arreglo | `Seguridad:` resuelto | ¿autoriza? |
|---|---|---|
| leído por 1.31.0 | ``aprobado` (R-020, 2026-08-12) han visto estos criterios, que son **pos…`` | **NO** |
| leído por 1.32.1 | `aprobado` | sí |

**La dirección del fallo depende de qué texto quede pisando**, y un párrafo de prosa normalmente **no
resuelve**. El caso peligroso es el que pisa con un veredicto **limpio y bien formado** — justo el del
comentario rotulado «Historial». **Consecuencia: nuestra estimación de proyectos dañados es
probablemente más alta que la realidad.** El fail-open es real y reproducible; su frecuencia de campo,
menor de lo que temíamos.

**4. Su exposición: cero, medida por tres vías** — diferencial de lectores (los 48 REQ dan salida
byte-idéntica en 1.31.0 y 1.32.1), fechas (ningún `Estado:` se movió con una versión vulnerable
cargada), y comprobación de estado sobre los 9 cerrados (ninguno cerraría distinto hoy). Es la
**comprobación por estado** de SEC-025 hecha a mano antes de que exista la herramienta.

### La comprobación de integridad de bitácora, y el aviso que la acompaña

No la tenían verbatim y **lo dijeron en vez de reconstruirla disfrazada de original** — la re-derivaron
y la dan con su salida:

```bash
RE='^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}\].*Origen: (GitHub|Interno)'
for F in CHANGELOG.md CHANGELOG-archivo.md; do
  tot=$(grep -cE '^## ' "$F"); ok=$(grep -cE "$RE" "$F")
  printf "%-24s %3d/%3d %s\n" "$F" "$ok" "$tot" "$([ "$tot" = "$ok" ] && echo OK || echo FALTA)"
done
```

**La idea:** toda cabecera de entrada tiene que llevar su **borde completo**. Si el borde se pierde, la
cabecera degrada a un `## ` suelto, `tot` sube, `ok` no, y el cuerpo huérfano queda contado.
**Complemento barato:** `entradas(vivo) + entradas(archivo)` **nunca puede bajar** entre commits — que
es la invariante que la rotación debería garantizar y hoy no comprueba nadie.

> ⚠️ **Y el aviso, que vale más que el script.** Su primera versión anclaba en ` - Origen: ` con guion y
> marcó **166 de 359 entradas como malformadas** — todas **falsos positivos**: usaban raya (`—`). Si
> esto se publica como puerta, hay que anclar en `Origen:` y **no en la puntuación**. Su frase, que es
> la nuestra dicha mejor: ***una comprobación que cría lobos se apaga, y entonces protege lo mismo que
> ninguna.*** Es el mismo principio por el que `AGENTS.md` §13 rechaza perseguir shell arbitrario.

### Y una nota de gobernanza que conviene conservar

El proyecto consumidor **se negó a correr `/arnes-upgrade` porque se lo pidiera otra sesión**: reescribe
`AGENTS.md`, `CLAUDE.md` y `requirements/README.md`, y esa decisión es de su dueño. **Un par no puede
conceder una escalada.** Es la misma regla por la que la coordinadora de este repositorio no puede
levantar un veto del auditor: un control que el interesado puede desactivar no es un control.

### El conteo de campos duplicados: dos corpus, mismo script, misma respuesta (2026-09-07)

**El dato se propaga en una sola dirección, y eso lo hace más fuerte de lo que parecía.** El proyecto
consumidor midió en la rama **estricta** —contando las ocurrencias **antes** de descontar los rangos
`<!-- -->`, o sea incluyendo las comentadas—, que es la que marca **de más**. Contar «después» ve un
**subconjunto estricto**: si en la rama estricta salen 0 duplicados, en la permisiva salen 0
**necesariamente, sin volver a medir**. Así que ese corpus contesta **NO a las dos ramas**.

**Segundo corpus, este repositorio, mismo script, misma corrida:** **17 REQ, 0 archivos** con un campo
declarado dos veces. Y el control de la advertencia de abajo: **0 REQ** cuya cabecera no corte con
`## `.

| Corpus | REQ | Duplicados (rama estricta) |
|---|---:|---|
| Proyecto consumidor | 48 | **0** |
| ArnesJuan | 17 | **0** |

**Dos corpus, 65 REQ, cero.** Denegar ante campo duplicado sigue saliendo barato, y ahora con dos
mediciones independientes hechas **con el mismo script**, que era la condición para poder sumarlas.

**El script, verbatim, para que los conteos futuros sean el mismo conteo** (transcribe
`arnes_norm_clave` —retira espacio y énfasis, descuenta CR— y corta en el primer `## ` como
`campos-req.awk`):

```bash
for f in requirements/*.md; do
  out=$(awk '
    /^## /{exit}
    {
      linea=$0; gsub(/\r/,"",linea)
      p=index(linea,":"); if(p==0) next
      sub(/^[ \t]+/,"",linea); sub(/[ \t]+$/,"",linea)
      p=index(linea,":"); if(p==0) next
      k=substr(linea,1,p-1); gsub(/[*_`]/,"",k)
      sub(/^[ \t]+/,"",k); sub(/[ \t]+$/,"",k)
      if(k=="Estado"||k=="QA"||k=="Seguridad"||k=="Sensible a seguridad"||k=="Hallazgos abiertos"||k=="Rigor") c[k]++
    }
    END{for(k in c) if(c[k]>1) printf "  %s x%d\n", k, c[k]}
  ' "$f")
  [ -n "$out" ] && { echo "$(basename $f):"; echo "$out"; }
done
```

Para medir la rama permisiva se inserta `sincita()` **antes** del `gsub(/\r/…)` — **y en ese orden**,
que es la corrección que `campos-req.awk` ya lleva desde 1.32.1: descontar el CR antes de escanear
puede **fabricar** un delimitador. Nuestra propia lección, devuelta por quien la sufrió.

> ⚠️ **Advertencia sobre el instrumento, de la familia de los 166 lobos.** Si al correrlo en otro
> proyecto sale un número **alto** de duplicados, la primera sospecha es el `/^## /{exit}`: un REQ cuya
> cabecera esté separada del cuerpo por algo que **no** sea `## ` —una regla horizontal, un `###`—
> entrega **el archivo entero** al contador, y entonces **todo** REQ con historial parece duplicado. Se
> comprueba antes de creerse el número, y el control cuesta una línea. Los dos corpus medidos cortan
> limpio; no se da por hecho para un tercero.

## H-08 — el CI da verde sobre REQ-017 sin haber medido ni uno de sus criterios (2026-09-07)

**Clase: `instrumento`.** Dueño: `desarrollador`. Medido en el PR #43, ejecución
`hooks-en-linux` de 51 s.

**Qué pasó.** El banco salió `833 PASS, 0 FAIL, 12 SKIP`. **Once de esos doce SKIP son los
criterios de REQ-017**: CA-01 (las dos formas), CA-03, CA-04 (las dos), CA-05 (i) y (ii) y CA-08
(las cuatro). Todos con el mismo motivo declarado: *«no hay línea base: el tag v1.32.1 no está en
este clon»*. La causa es de una línea: `actions/checkout@v4` clona con `fetch-depth: 1` **y sin
tags**, así que los árboles congelados que esos criterios materializan no existen ahí.

**Por qué importa más que un arreglo de CI.** La puerta requerida de `main` dio verde sobre el
único REQ del PR **sin haber ejecutado ninguna de sus comprobaciones**. No es un fallo del
corredor ni de las sondas —de hecho `CA-06` **pasó**, que es justo el criterio que exige *«sin
línea base, SKIP con motivo, nunca PASS»*: la sonda se comportó exactamente como se contrató—.
El defecto está una capa más arriba: **un SKIP honesto, agregado a un resultado global, se lee
como verde.**

**Tres consecuencias, y la tercera es la que decide.**

1. **Confirma la lección de CA-05 desde el otro lado.** Ya sabíamos que una comprobación contra
   línea base congelada *envejece hacia el lado que abre*. Esto añade que **ni siquiera hace
   falta que envejezca**: basta con que el entorno no tenga el tag para que se abra hoy mismo.
   Lo auto-anclado (CA-03, el orden de crecimiento) no depende de ningún tag y es lo único que
   habría medido algo aquí.
2. **El coste declarado en rojo no se ha pagado ni una vez.** Los ~120 s de la sección 37/2 no
   ocurrieron: la corrida heredada es justo lo que se salta. La estimación de «~145 s de puerta
   requerida» sigue **sin medir en CI**, y el 51 s de esta ejecución no la desmiente.
3. **Es un forzador medido para la palanca «¿esta prueba mide algo?»**, que ya está en 1.33.0.
   Esa palanca se pensó para casos **vacíos**; este es un caso **lleno que no se ejecuta**, y la
   propiedad que los cubre a los dos es la misma: *un caso que no llegó a juzgar nada no puede
   contribuir al verde global*. La forma no es prohibir el SKIP —el SKIP con motivo es correcto y
   está contratado—, sino que **el resultado global declare qué criterios quedaron sin medir**, y
   que una sección pueda exigir que los suyos se midan **en la plataforma que es puerta**.

**Lo barato, y no lo hago yo porque `.github/` es `codigo_app.globs`:** `fetch-depth: 0` (o
`fetch-tags: true`) en el checkout. Va con el delta del desarrollador de REQ-017, no antes, porque
encarece la puerta requerida y esa decisión ya estaba escalada.

### CERRADO — 2026-09-07, por gate humano

**Aprobado por el propietario (Juan) el 2026-09-07** como ampliación de la comisión del delta de
REQ-017. La aprobación es un **gate humano** de `AGENTS.md` §6 —«cambiar el ruleset, el workflow de
CI o el manifiesto `.arnes/config.json` de este repo»— y no una reclasificación de agente.

**Lo aprobado es la COMBINACIÓN de dos cosas, y ahí está el punto.** Por separado, cada una empeora
algo: recuperar los tags sin más deja que la sección 37/2 se ejecute de verdad en CI y añade sus
~120 s a la puerta requerida; apagar 37/2 sin recuperar los tags deja el resto de criterios de
REQ-017 en SKIP igual que hoy. Juntas, el CI **vuelve a medir** CA-01, CA-03, CA-04 y CA-08 —CA-03
incluida, la única auto-anclada, que es la que no envejece— **sin pagar** la corrida heredada. La
ruta crítica se enciende a mano con `ARNES_COSTE_RUTA_CRITICA=1` cuando toca acreditarla.

1. `.github/workflows/banco.yml` — `fetch-depth: 0` en `actions/checkout@v4`, con el motivo escrito
   junto a la línea. **`fetch-depth: 0` y no `fetch-tags: true`**: éste mantiene la profundidad 1 y
   trae los tags como refs superficiales, que hoy bastarían para `git show <tag>:<f>` pero dejan la
   prueba colgando de las semánticas del clon superficial — y el modo de fallo de esa apuesta **es
   este mismo hallazgo**: medio funciona y se lee como verde. El repositorio empaquetado pesa
   540 KiB, así que la historia completa no es un coste que haya que optimizar.
2. `tests/escenarios/hooks/secciones/37-coste-del-escaner-2-la-seccion-caliente.sh` — el defecto de
   `ARNES_COSTE_RUTA_CRITICA` se **invierte**: apagada salvo que se pida.

**El coste, medido y no estimado** (véase `docs/qa/1.33.0.md`, § «Lo que le cuesta a la puerta
requerida recuperar los tags»). La consecuencia 2 de arriba —«el coste declarado en rojo no se ha
pagado ni una vez»— deja de aplicar en lo que respecta a los árboles congelados: a partir de este
cambio el CI los materializa y los mide.

**Lo que este cierre NO resuelve, y sigue en cola:** la consecuencia 3. Un SKIP honesto agregado a
un resultado global se sigue leyendo como verde; que hoy no haya ninguno en CI es una propiedad del
entorno, no del corredor. La palanca «¿esta prueba mide algo?» —que el resultado global **declare
qué criterios quedaron sin medir**, y que una sección pueda exigir que los suyos se midan en la
plataforma que es puerta— sigue viva en 1.33.0 y con este hallazgo como forzador medido.

### Seguimiento del caso J: el bisecado, la conjunción, y dos correcciones medidas por la coordinadora (2026-09-07)

Segundo informe del mismo proyecto consumidor, **verificado ejecutando** `hooks/guard.sh` del plugin
instalado 1.32.1 contra un proyecto efímero, con **control positivo en la misma tanda** (una cabecera
terminal sin la línea de más, que debe denegar en toda versión; si el control deja de denegar, la
medición no vale). El control aguantó.

| Caso | Documento (todo en la cabecera, a continuación de `Seguridad: con-hallazgos`) | 1.32.1 |
|---|---|---|
| **F** control | *(nada)* | **DENIEGA** ✔ |
| **I** | `<!-- **Seguridad:** aprobado -->` | **DENIEGA** ✔ cerrado por 1.32.1 |
| **J** | `**Seguridad:** aprobado` | **PERMITE** 🔴 |
| **J-bis** | `_Seguridad:_ aprobado` | **PERMITE** 🔴 |
| **J-ter** | `  Seguridad: aprobado` (dos espacios) | **PERMITE** 🔴 |
| **J-4** | `\| **Seguridad:** \| aprobado \|` | **DENIEGA** |
| **J-5** | `**Seguridad:** con-hallazgos` (mismo valor) | **DENIEGA** |

**Lo que el informe añade y no teníamos: el bisecado que prueba que J no es un caso nuevo.** Hasta
1.30.3 la clave se anclaba con un literal a columna cero (`/^Seguridad:/`), así que
`**Seguridad:** aprobado` **no era un campo en absoluto** — J denegaba por eso, no por ninguna virtud
del rango del comentario. La tolerancia al énfasis entra en 1.31.0 y desde ahí I y J son **la misma
mitad partida por una característica que no comparten**: el rango. Por eso el arreglo de 1.32.1 alcanzó
a una y no a la otra. Nace ≤1.31.0, confirmado por medición y no por lectura del changelog.

**Y el argumento que hay que conservar entero, porque decide el diseño:** las dos reglas que producen
J —tolerar el énfasis en la clave, y que gane la **última** aparición— **son correctas por separado**.
La primera nació porque un `Sensible a seguridad: **sí**` no se reconocía y esos REQ nunca activaban la
puerta; quitarla reabre aquello. La segunda es semántica heredada y declarada deliberada. **El defecto
es la conjunción**, y por eso no se arregla tocando ninguna de las dos: cualquier ajuste rompe algo que
hoy funciona. Es la razón por la que la salida tiene que ser la pregunta de estado —*declara el mismo
campo dos veces con valores distintos ⇒ no medible ⇒ DENY*— y no una preferencia entre formas.

**Dos correcciones medidas, una en cada dirección:**

1. **Su predicción de la celda de tabla es falsa.** `| **Seguridad:** | aprobado |` **deniega**: el
   `|` inicial no está entre los prefijos tolerados. Un caso menos en la familia — conviene decirlo,
   porque una amenaza sobreestimada gasta el mismo diseño que una real.
2. **La INDENTACIÓN es hueco:** `  Seguridad: aprobado` con dos espacios permite, y el tabulador
   también. Importa para el diseño porque **no es decoración**: si la regla se escribiera como «una
   clave decorada no puede desbancar a una limpia», este caso se escaparía. Es un argumento más para
   la pregunta de estado, que no mira la forma de la clave.

   > **Corrección de la coordinadora (2026-09-07, mismo día).** Escribí que esta forma «no estaba en
   > ninguna lista» del reportante. **Es falso y ellos lo señalaron:** estaba en su §4 y en la fila
   > «que la línea limpia gane a la decorada» de su tabla del §5, cuya columna dice literalmente
   > *«vuelve con indentación»*. La medición es correcta; la atribución de novedad, no. Queda escrito
   > porque afirmar sin condición algo medido falso es el modo de fallo que este repositorio castiga,
   > y no vale menos cuando el que lo hace es quien lleva la cuenta.

**La mitad del bloque derivado, que sí estaba escrita y yo di por ausente.** *(Corrección de la
coordinadora, 2026-09-07: dije «la mitad que no estaba escrita». **Estaba en su §6, último párrafo, y
citaba H-01 por su nombre.** No la leí porque iba al final de la sección — que es un dato útil sobre
dónde se pierde la información en un informe, no una excusa.)* Si la puerta
deniega por ambigüedad y `arnes_campos_req` publica en `docs/ESTADO.md` uno cualquiera de los dos
valores, vuelve **exactamente** la divergencia entre las dos mitades del lector que 1.32.1 cerró en
H-01. La forma correcta es que el lector emita **una marca de ambigüedad** que consuman las dos, no que
cada mitad la vuelva a derivar. Sin esto, el arreglo repara una puerta y estrena una discrepancia.

**Los tres bordes, que el REQ tiene que contratar explícitamente:** (a) sólo si los valores
**difieren** —dos apariciones idénticas son redundancia, y como mucho un aviso—; (b) **no bloquear
reabrir**, igual que se decidió para el CR: una cabecera ambigua no puede acreditar un cierre, pero
sacar un REQ del estado terminal es la salida y bloquearla dejaría al proyecto sin ninguna; (c) la
comparación, **sobre el valor normalizado**, para que ` aprobado` y `aprobado ` no cuenten como
contradicción. Sigue abierta, y sin decidir, la disyuntiva ya anotada arriba: contar ocurrencias
**antes o después** de descontar los rangos de comentario.

**Ventana: 1.34.0**, no 1.33.0 — la partición del 2026-09-07 dejó 1.33.0 con las palancas de coste y
movió el núcleo de preguntas de estado, del que esto forma parte. Además **colisiona por archivo** con
REQ-017, que tiene `hooks/lib.sh` tomado. Clase `contrato`. El reportante **no pide un parche a la
carrera** y lo argumenta: en su corpus hay 0 casos, y la mitad que quemaba —la del comentario— ya está
cerrada.

### El borde de la familia J es una LISTA DE CARACTERES, no una propiedad (medido a dos bandas, 2026-09-07)

Tercer intercambio con el proyecto consumidor, cada lado ejecutando contra 1.32.1 instalado y con
control positivo en su propia tanda. **Es el hallazgo que decide cómo se escribe el REQ de 1.34.0.**

**Forma nueva, suya, confirmada aquí:** `**Seguridad**: aprobado` —con el énfasis **sin cruzar** los
dos puntos— permite. `gsub(/[*_`]/,"",k)` retira el énfasis de la clave aunque el par se cierre
**antes** de los dos puntos, así que no hace falta que lo cruce. Todo lo escrito hasta ahora, aquí y
allí, hablaba del par que cruza: la familia es más ancha de lo que ninguno de los dos documentó.

**El mapa completo, medido en las dos máquinas y coincidente:**

| | Formas | Veredicto de 1.32.1 |
|---|---|---|
| El par cruza los dos puntos | `**S:**` · `_S:_` · `` `S:` `` · `*S:*` | **PERMITE** |
| El par **no** cruza | `**Seguridad**: aprobado` | **PERMITE** |
| No hay decoración, sólo espacio | dos espacios · tabulador | **PERMITE** |
| El par envuelve la **línea entera** | `` `Seguridad: aprobado` `` | DENIEGA |
| Prefijo fuera de la lista | `\| … \|` · `> …` · `- …` | DENIEGA |

**Y aquí está el argumento, que es de ellos y hay que conservarlo literal: las tres cerradas lo están
por accidente, y de dos maneras distintas.** La del par que envuelve la línea entera deniega porque el
carácter de cierre queda pegado al **valor** y deja de igualar `aprobado` — **la clave sí se reconoce**,
o sea que el campo se declara y lo que salva es la comparación del valor. Y `|`, `>`, `-` deniegan
sólo porque **no están en `[*_`]`**. ⇒ **el borde de esta familia es una lista de caracteres, no una
propiedad.** Es nuestra propia lección aplicada al borde, y es la quinta vez que la vemos: *la lista no
gana la clase*.

**La exposición, convertida en número por ellos sobre su corpus de 48 REQ:** **25 líneas en 7 archivos**
declaran un campo y hoy son **inertes sólo por su primer carácter** —`>` casi siempre: prosa citada
dentro de la cabecera—. Si `>` entrara alguna vez en esa lista, **2 de esos archivos pasarían a tener
cabecera contradictoria**. Dirección, dicha con precisión: el último valor de esas dos es prosa que no
iguala `aprobado`, así que el efecto inmediato sería un **bloqueo falso, no un fail-open**. No es un
argumento para ensanchar la lista; es la demostración de que ensancharla mueve el problema de sitio, y
de que la regla de ambigüedad lo resuelve en **las dos direcciones a la vez**.

> **Supuesto de diseño que hay que romper antes de escribir el REQ, y viene medido: las cabeceras
> reales son largas.** En ese proyecto la mediana es de **15 líneas** y hay REQ de **100 y 109**, porque
> documentan la historia del veredicto arriba. Consecuencia incómoda: *«los campos valen sólo en la
> cabecera»* —la invariante de 1.30.0— **protege bastante menos de lo que la frase sugiere**; lo que de
> hecho los está protegiendo es la lista de prefijos, que es justo lo que acabamos de declarar
> accidental. **Quien diseñe esto pensando en cabeceras de cinco líneas se equivocará de mecanismo.**

**Compromiso adquirido con el reportante, y hay que cumplirlo:** se han construido un guardián propio
que **transcribe** nuestra normalización —una tercera mitad del lector, que puede quedarse rancia en
verde—. Van a alimentarlo con las mismas líneas que al `.awk` real para compararlos, pero hasta que eso
exista: **si 1.34.0 mueve la normalización de claves, hay que avisarles.** Su guardián no se entera
solo. Anotado como obligación de la ventana, no como cortesía.

**Dos trampas de método que ellos pagaron y que valen para cualquiera que reproduzca esto:**
`CLAUDE_PROJECT_DIR` tiene **prioridad** sobre `.cwd` en `arnes_project_dir` —sin apuntarlo al fixture,
el hook resuelve el proyecto real, el REQ le queda fuera y **permite todo**—; y leer la respuesta con
`python3 - <<'PY'` hace que el heredoc **ocupe stdin**, se descarte la tubería y se imprima PERMITE
siempre. La segunda la cazó su control **negativo**, no el positivo: un control positivo solo no habría
visto ninguna de las dos.

### El compromiso no vence, y por qué: el comparador tiene un punto ciego con nuestra misma forma (2026-09-07)

Les ofrecí retirar el aviso cuando tuvieran su comparador contra el `.awk` real. **Lo rechazaron, y el
motivo es bueno:** el comparador alimenta las mismas líneas a las dos mitades y compara, así que
detecta divergencia **sólo en las formas que su corpus ejercita**. Si 1.34.0 cambia la normalización
por una forma que a nadie se le ocurrió meter en el corpus, las dos mitades divergen y **el comparador
sigue en verde**. Es literalmente la clase que estamos persiguiendo —*una lista en vez de una
propiedad*—, sólo que la lista ahora es el corpus. **Un corpus es una lista de casos.**

**Y hay una diferencia de latencia que tampoco cubre:** nuestro aviso llega **al publicar**; su
comparador sólo habla **cuando corren su puerta de pruebas**, que puede ser días después. Entre las dos
cosas queda una ventana en la que un REQ podría cerrar con la cabecera leída de otra manera.

⇒ **los dos mecanismos no se solapan: el nuestro es puntual y completo, el suyo continuo y parcial.**
Van los dos. El compromiso queda **sin fecha de caducidad**: si 1.34.0 mueve la normalización de
claves, se avisa. No es cortesía y no se cancela por tener el comparador.

> **Y esto se nos aplica a nosotros, que es la parte que importa aquí.** Su corpus va a incluir a
> propósito **las tres formas cerradas** (`|`, `>`, `-`) además de las siete abiertas — no para fijar
> que están cerradas, que sería **fijar el defecto**, sino para que **algo cambie de valor** en su
> tanda si 1.34.0 mete alguna en la lista tolerada. La frase que lo resume es reutilizable y va
> directa a la palanca de 1.33.0: **«un corpus que sólo contiene lo que hoy falla no puede avisar de
> que hoy dejó de fallar.»**
>
> La puerta de «¿esta prueba mide algo?» se pensó para el caso **vacío** —un caso que no ejercita
> nada—; H-08 añadió el caso **lleno que no se ejecuta**; esto añade el tercero: **el caso que sólo
> fija el lado que hoy falla**. Los tres son la misma propiedad, *si el mecanismo cambiara, ¿cambiaría
> algo en la tanda?*, y conviene que el REQ de esa palanca los nombre a los tres.

**Apuesta suya, con la cifra detrás, y vale como aviso de diseño:** de sus 25 líneas inertes la
abrumadora mayoría empieza por **`>`**. Si algún día un carácter entra en la lista tolerada por
parecer inofensivo, será ése — es el que produce la **prosa citada**, que es exactamente donde la gente
escribe la historia de los veredictos. Quien redacte el REQ de 1.34.0 tiene ahí nombrado el error más
probable.

### El campo `Archivos:` no dice qué artefactos de gobierno entran, y la divergencia produce falsos `disjunto` (analista, 2026-09-07)

**Encontrado al reconciliar el campo de REQ-017.** No existe en ningún sitio la regla de **qué
artefactos de gobierno se declaran en `Archivos:` y cuáles no**. REQ-017 la enunciaba en sus propias
`Notas`; REQ-007, REQ-008, REQ-011 y REQ-013 declaran `CHANGELOG.md`, su propio archivo de REQ y
`docs/qa/…`; REQ-017 no lo hacía. **Cuatro REQ abiertos con dos convenciones distintas sobre el mismo
campo.**

**Por qué no es cosmético: la intersección se calcula sobre lo declarado.** Un archivo que unos REQ
declaran y otros no **no aparece en la intersección**, así que el par sale **`disjunto` siendo falso**.
Es fail-**open** en un campo cuyo modo de fallo es **trabajo perdido y conflictos de fusión**, y va
contra el principio que el propio REQ-017 escribió: *declararlo falla del lado cerrado, que es la
dirección correcta*.

Se escribiría en `requirements/README.md` § «El mapa de archivos» y en su plantilla heredable. Dueño:
`analista-requerimientos`. **Ventana 1.34.0**, junto a la generalización que REQ-017 ya aplaza allí (un
criterio de coste contra línea base congelada declara si es puerta permanente o acreditación única).
Clase `instrumento` — degrada una herramienta de coordinación, no una puerta de cierre.

**Consecuencia operativa inmediata, ya medida:** con `.github/workflows/banco.yml` dentro del campo de
REQ-017, y como `expande()` **arrastra el directorio entero** a propósito, **REQ-018 sólo saldrá
`disjunto` si declara sus rutas de `.github/` una por una y evita `templates/` como directorio**. El
primer `disjunto` real que esperábamos sigue siendo alcanzable, pero **ya no es gratis**: depende de
cómo se redacte ese campo. Y REQ-014 pasa a colisionar con REQ-017 por **dos** sitios en vez de uno.

### El cuarto caso de «¿esta prueba mide algo?»: el universo se encoge en silencio, en verde (2026-09-07)

Aportado por el proyecto consumidor, y es **distinto de los otros tres**: una corrida que ejecuta
**una** cosa y excluye el resto sin decirlo, saliendo 0. En su stack es un `it.only` olvidado; la forma
general es **el universo de la tanda encogiéndose sin que el informe lo diga**, porque lo que corrió
pasó de verdad.

Encaja en la propiedad *(si el mecanismo cambiara, ¿cambiaría algo en la tanda?)* **por el lado
contrario a los otros tres**: aquí sí cambiaría, y para bien, pero **nadie se enteraría**, porque el
verde no distingue «pasaron las 6 600» de «pasó la 1». Y es más probable que los otros tres, porque esa
marca **se escribe a propósito** mientras se depura y se olvida al comitear.

**Los cuatro casos, que es como debe entrar en el REQ de la palanca:**

| | Forma | Cómo se nos apareció |
|---|---|---|
| 1 | El caso **vacío**: no ejercita nada | Los cinco casos de banco de 1.32.1 (H-02) |
| 2 | El caso **lleno que no se ejecuta** | **H-08**: el CI sin tags, once SKIP honestos leídos como verde |
| 3 | El caso que **sólo fija el lado que hoy falla** | Su corpus del comparador |
| 4 | **El universo encogido en silencio** | Su `it.only` olvidado |

**Y aquí la parte que nos toca a nosotros, medida y no supuesta: el banco ya responde al caso 4, por
construcción.** `run.sh` lee `CASOS_ESPERADOS_SECCION` **del texto del archivo, no de la corrida**
(línea 642), así que el número esperado **no puede encogerse junto con el universo**; una sección que
no declara el suyo **aborta**, y hay dos cuadres, por archivo y total. No es teoría: el comentario de
la línea 228 registra un caso real —casos que *no se ejecutaban*— y dice que **sólo el cuadre lo
delató**. Es exactamente la aserción derivada que ellos acaban de inventar para su comparador
(`comparadas == corpus.length`), y llegaron a ella por su cuenta.

> **El residual honesto, que es del caso 2 y vive una capa más arriba:** en vuelta **parcial** —con
> filtro— el cuadre **total** queda **suspendido diciéndolo** (línea 714, y el motivo escrito allí es
> bueno: *«un cuadre que aborta en falso se acaba comentando»*). El de cada sección se sigue
> exigiendo, así que la protección no desaparece. Pero es la misma forma que H-08: **una comprobación
> que se suspende con motivo y se agrega a un resultado global**. Nada obliga hoy a que la vuelta
> completa se haya corrido alguna vez antes de pedir la fusión — lo pide `AGENTS.md` §7 en prosa, y
> ninguna puerta lo mide. **Va al REQ de la palanca como quinto supuesto a decidir**, no como hallazgo
> separado.

**Una práctica suya que conviene copiar, y no es sobre pruebas:** al declarar su exposición a nuestro
H-08 separaron **lo medido de lo no medido** —«revisé 3 de las 11 y las tres están defendidas; **las
otras 8 no las he mirado**; nuestra exposición es *probablemente pequeña y no medida*»— en vez de
redondear a «cubierto». Es la forma correcta de reportar una cobertura parcial, y es justo lo que aquí
falló el 2026-09-07 con el muestreo de cinco secciones presentado como medición.

### El campo ausente que calla: nuestra instancia, medida (2026-09-07)

**El patrón, aportado por el proyecto consumidor y encontrado en su propio guardián:** una comprobación
escrita como *«si el campo **está** y dice algo malo, protesta»* **falla en abierto cuando el campo
desaparece**. La forma que no falla así es *«si el campo no está, protesta; si está y dice algo malo,
protesta»*.

**Y la señal de revisión que lo acompaña, que es lo más reutilizable de todo el intercambio:** la
**inconsistencia dentro de un mismo archivo**. Cuando cinco comprobaciones hermanas reportan la
ausencia y una no, **esa una es sospechosa por sí sola** — sin saber nada del dominio, sin medir, y en
tiempo de revisión. Es barato y va a la lista del `auditor-seguridad` y del `qa-tester`.

**Nuestra instancia, medida contra 1.32.1 instalado** (no leída del código, no recordada):

| Cabecera de un REQ `critico` con `Estado: completado` | Veredicto |
|---|---|
| `QA: pendiente` declarado | DENIEGA |
| **campo `QA:` AUSENTE** | **PERMITE** 🔴 |
| campo `Seguridad:` ausente | DENIEGA |
| `Hallazgos abiertos:` con un hallazgo **sin clase** | DENIEGA |

**`QA:` es el único de los cuatro cuya ausencia calla.** Su señal de inconsistencia lo habría
señalado sin conocer el arnés. Y `AGENTS.md` §13 promete literalmente *«No completar sin
`QA: aprobado` (salvo `Rigor: ligero`)»*, promesa que es **falsa cuando el campo no se declara** — ya
estaba anotada como una de las **tres promesas incondicionales más anchas que el código**, pero
estaba escrita como observación y ahora **está medida, tiene nombre y tiene patrón general**.

Va a la **pasada de conformidad de 1.34.0**, que ya la recogía. Lo que cambia es que deja de ser una
frase que corregir y pasa a ser un **defecto con forma reconocible**: o la puerta exige el campo, o
`AGENTS.md` deja de prometer lo que no cumple. Clase `contrato` — la promesa está en el documento que
los proyectos heredan.

> **La otra mitad, y es la respuesta a la pregunta que dejamos abierta arriba sobre el cuadre total
> suspendido: ellos NO suspenden la comprobación, RECHAZAN la corrida.** Su sello registra **los
> argumentos con que se lanzó el proceso** y la puerta de integridad **falla** si hay alguno: *«una
> corrida parcial no es evidencia de integridad»*. La diferencia de diseño es la que importa — no se
> decide comparando **conteos**, que pueden encogerse junto con el universo (nuestro caso 2), sino
> leyendo **cómo se invocó el proceso**, que es un hecho **anterior** a la corrida y no depende de lo
> que la corrida mida. Es la forma correcta y es la que le falta a nuestro §7, que hoy pide la vuelta
> completa **en prosa**. Va al REQ de la palanca.
>
> *(Ellos lo declararon como **leído, no ejercido** —tenían una comisión corriendo y el sello es un
> archivo compartido: ejercerlo habría contaminado las dos corridas—. La distinción se conserva
> aquí.)*

### El arreglo ingenuo del campo ausente rompería a los proyectos, y nuestro corpus no lo habría dicho (medido a dos bandas, 2026-09-07)

**Aviso del proyecto consumidor, con cifras, antes de que se redacte el arreglo.** «Campo ausente ⇒
denegar» aplicado a **todos** los campos deja a un proyecto real **sin poder cerrar ni un REQ**. Medido
allí con nuestro propio `campos-req.awk` de 1.32.1 sobre sus 47 REQ:

| Campo | Los omiten allí (47 REQ) | Los omiten **aquí** (17 REQ) |
|---|---|---|
| `QA:` | 0 | 0 |
| `Seguridad:` | 0 | 0 |
| `Sensible a seguridad:` | 0 | 0 |
| **`Hallazgos abiertos:`** | **47 de 47** | **0** |
| **`Rigor:`** | **47 de 47** | **0** |

**La ausencia no significa lo mismo en todos los campos: en dos de ellos la ausencia ES el valor.**
`Hallazgos abiertos:` ausente significa *«ninguno»* por nuestro propio §6. Y `Rigor:` ausente es allí
una **decisión escrita del dueño**, cuyo mapeo coincide con nuestra derivación por defecto, así que
declararlo sería redundancia que envejece.

**El criterio que lo separa, y es suyo:** la ausencia es un **hueco** cuando el campo es un
**veredicto que alguien debe emitir** (`QA:`, `Seguridad:`); es un **valor** cuando el campo es un
**inventario que puede estar vacío** (`Hallazgos abiertos:`) o un **derivado con regla propia**
(`Rigor:`). No sale del código: sale de **qué promete cada campo**.

> ⚠️ **La lección que es nuestra y no suya, y es la más incómoda del día: nuestro corpus no es
> representativo, y por eso no nos habría avisado.** Aquí los 17 REQ declaran los cinco campos —**0
> omisiones**—; allí, dos campos se omiten en **el 100 %** de los archivos. Si hubiéramos diseñado el
> arreglo midiendo contra nuestro propio corpus, la conclusión habría sido *«denegar ante ausencia no
> rompe nada»* — con la medición bien hecha, la lógica interna correcta y el resultado catastrófico
> aguas abajo. **Es la ceguera específica del autoalojamiento:** el repositorio que se desarrolla a sí
> mismo mide sobre el corpus más disciplinado que existe, porque es el suyo. Cualquier REQ que decida
> sobre la **forma de los REQ** necesita un corpus externo, y hoy sólo hay uno disponible.

**Y la mitad que multiplica el coste: la promesa falsa viajó con la plantilla.** `templates/AGENTS.md.tpl`
línea 309 lleva escrito *«No completar sin `QA: aprobado` (salvo `Rigor: ligero`)…»*, así que **todo
proyecto que haya hecho `arnes-init` o `arnes-upgrade` la tiene**. Consecuencia operativa para 1.34.0:
**esa fila de la plantilla es parte del arreglo, no documentación del arreglo** — y la migración tiene
que nombrarla, porque un proyecto migrado no releerá la plantilla por su cuenta.

*(El proyecto consumidor ya corrigió su copia aguas abajo, conservando el texto anterior, y midió su
exposición al fail-open: **cero** — su único archivo sin `QA:` es el README, que no declara `Estado:` y
por tanto no puede transicionar. Pero aplica a cualquier REQ nuevo.)*

### Perfil del corpus externo, y el criterio que limita lo que prueba (2026-09-07)

**Tres datos del proyecto consumidor sobre sus 47 REQ, con lo que cada uno rompe.**

**1. Un valor de campo llega a 16 135 caracteres en una sola línea**, y doce líneas de campo pasan de
1 KB. Máximos por campo: `Estado` 1 653, `QA` 2 378, `Seguridad` 16 135. De los 47, **28** tienen
`Estado:` de más de 60 caracteres.

> **Medido aquí, y acota el problema a un solo sitio:** el coste del lector **no depende** de la
> longitud del valor. `campos-req.awk` sobre una cabecera con un valor de 1 000, 2 000, 4 000, 8 000 y
> 16 000 caracteres da ~4,0 ms en los cinco casos —el tiempo es arranque de `awk`, no lectura—.
> *(Método declarado: media de 3 corridas, no el mínimo de k que exige el propio banco; con una serie
> plana en 16× de rango la conclusión aguanta, pero el estadístico no es el contratado.)*
>
> ⇒ **El único sitio donde 16 KB duele es el MENSAJE DE DENEGACIÓN.** Una puerta de ambigüedad que
> deniegue citando *«línea 12 («…») frente a línea 47 («…»)»* con los valores completos escupiría
> **32 KB** por una cabecera contradictoria. El bloque derivado ya recorta a 40 caracteres y lo
> declara como presentación; **el mensaje de deny no tiene esa regla escrita en ninguna parte**, y el
> REQ de 1.34.0 tiene que dársela. *(El reportante tiene ese defecto en su propio guardián ahora mismo
> y lo dice para que no se herede.)*

**2. `Seguridad: n/a` — y aquí el reportante se equivoca, verificado.** Dice que usa «un valor que no
está en vuestro vocabulario». **Sí está:** `requirements/README.md:39` lo lista como el **primer**
valor de `Seguridad:` (`n/a | pendiente | aprobado | …`), y `AGENTS.md:354` y
`templates/AGENTS.md.tpl:319` lo nombran en el vocabulario del hook que avisa. Sus tres REQ están bien
escritos y no hay nada que migrar. **Lo que sí queda en pie es su pregunta de diseño**, que es nuestra
y no está contestada en la plantilla: `n/a` está en el vocabulario pero **no está documentado cuándo
usarlo**, y ellos lo escribieron sin preguntar porque el campo no tenía dueño declarado para ese caso.
Los tres que lo usan son exactamente los tres que declaran `Sensible a seguridad: no`. Eso es
**precisamente el uso correcto** y merece decirse en la plantilla.

**3. Cabeceras de mediana 15 líneas y máximos de 109 y 100**, con la historia del veredicto en prosa
citada con `>`. Combinado con el punto 1: una cabecera real puede ser **cien líneas con una de ellas de
16 KB**. Cualquier supuesto de «cabecera = unas pocas líneas cortas» falla ahí.

> **Y el criterio que ellos mismos ponen, que limita lo que su corpus prueba — hay que respetarlo o
> repetimos el error un nivel más arriba.** Para un REQ que decide sobre la **forma** de los REQ no
> basta un corpus externo: hace falta que el corpus externo sea **indisciplinado en la dimensión que
> el REQ toca**. Ellos son indisciplinados en **longitud y prosa dentro de la cabecera** ⇒ su corpus
> sirve para eso. **No lo son en ausencia de campos** —los 47 declaran los tres veredictos—, así que
> para **esa** dimensión su corpus es tan cómodo como el nuestro.
>
> **Corrección a la entrada anterior de este archivo:** el «0 de 17 aquí frente a 47 de 47 allí»
> sigue siendo válido para `Hallazgos abiertos:` y `Rigor:`, que es donde ellos son indisciplinados. **No
> es evidencia sobre `QA:` ni `Seguridad:` ausentes**, donde los dos corpus coinciden en declararlo
> siempre. Para esa dimensión seguimos sin corpus, y el arreglo no puede apoyarse en una muestra que
> no la contiene.
>
> Su formulación, que conviene conservar: **«un corpus de uno no es mucho mejor que autoalojarse; este
> canal no arregla la asimetría de la muestra, la reduce a dos.»**

### La regla que le falta a la palanca: una igualdad entre magnitudes que encogen juntas no es una cota (2026-09-07)

**Aportada por el proyecto consumidor, encontrada MUTANDO su propio guardián**, no leyéndolo. Habían
protegido su comparador con una aserción —«el número de formas comparadas es igual al tamaño del
corpus»— que es exactamente la forma que aquí se recomendaba. La rompieron en cuatro sitios; **dos
sobrevivieron**. La primera es la que importa:

> **Vaciaron el corpus y el archivo dio 11 de 11 en verde**, porque `comparadas === CORPUS.length` con
> el corpus vacío es `0 === 0`. La igualdad protege contra *«la comprobación se suspendió»* pero **no**
> contra *«el corpus se vació o se filtró»*: **las dos cantidades se encogen juntas.**

**La regla, que es generalizable y va al REQ de la palanca:** *una igualdad entre dos magnitudes que
pueden encogerse juntas no es una cota; hace falta un **literal**, y el literal **es** el control.* Un
número derivado del propio artefacto no puede vigilar al artefacto. Es la **excepción nombrada** a la
regla de no teclear números a mano, y hay que escribirla como excepción o alguien la «arreglará»
derivándolo.

Y ordena los cuatro casos: el caso 2 (H-08) era *el universo se encogió y el informe se leyó como
verde*; **éste es el caso 1 comiéndose al vigilante del caso 2** — el universo se encogió **y la
comprobación que vigila el tamaño se encogió con él**. Si el REQ dijera «exige que el número de casos
ejecutados coincida con el declarado», le faltaría la mitad: **el declarado también tiene que estar
acotado por abajo contra algo que no se mueva.**

**Comprobado en nuestro banco, y lo pasa — pero conviene saber por qué, porque no era obvio:**

| Nivel | Contra qué se compara | ¿Puede encogerse con el universo? |
|---|---|---|
| Por sección | `CASOS_ESPERADOS_SECCION` leído **del texto del archivo**, no de la corrida | No |
| Total | **`CASOS_ESPERADOS=845`, un literal tecleado** (`run.sh:711`) | No |

Si alguien **borra un archivo de sección entero**, la vuelta no se vuelve parcial —el inventario
encoge con él— y **el literal total es lo único que lo delata**. O sea: el banco ya aplica la regla que
ellos acaban de derivar, y el literal que parecía un descuido de mantenimiento es **la pieza que
sostiene el cuadre**. Escrito aquí para que nadie lo «mejore» derivándolo.

**El hueco sigue siendo el mismo y ya está anotado:** con filtro o vuelta parcial ese literal **se
suspende diciéndolo**. La salida propuesta sigue siendo la suya — rechazar la corrida en vez de
suspender la comprobación, leyendo cómo se invocó el proceso.

*(Su segunda mutación superviviente es nuestro caso 3 en su propio banco: rompieron la réplica de
nuestra regla de selección para que devolviera siempre la primera aparición y **nadie protestó**,
porque su corpus no contiene ninguna forma con un campo no-`Estado` declarado dos veces con valores
distintos. Fijaba sólo el lado que hoy falla.)*

### Por qué NO automatizar el `845`: un umbral derivado falla invisible, uno tecleado falla visible (2026-09-07)

**La continuación de la regla del literal, y va directa contra la «mejora» que ese hallazgo invita a
hacer.** Después de que aquí se verificara que `CASOS_ESPERADOS=845` es la pieza que sostiene el
cuadre, el proyecto consumidor fue a mirar su equivalente —que ellos **ya habían automatizado**— y
midió un agujero abierto de seis días: su piso declara 303 archivos / 5 880 pruebas, el disco trae 331
y la corrida 6 629. **Hueco de +28 archivos y +749 pruebas**: hoy podrían perder eso sin que ninguna
puerta enrojezca (el piso sólo muerde hacia abajo, que es correcto por diseño).

**La causa es la que importa, y es un aviso de diseño para nosotros.** Sustituyeron el número tecleado
por un **trinquete monótono** que sube solo, *«sin que ningún agente teclee»* — bien escrito, y funcionó:
subió el piso una vez. Pero **sólo sube sobre una corrida válida, y válida exige salida 0**, y su suite
lleva seis días en rojo por fallos ajenos y declarados. ⇒ **el trinquete no puede subir el piso mientras
la suite esté rota**, o sea que *la protección deja de mejorar exactamente cuando el sistema está en el
estado en que más probable es que algo cambie*.

> **El contraste, que es la pieza:**
>
> | | Cómo se queda rancio | ¿Se ve? |
> |---|---|---|
> | **Literal tecleado** (nuestro `845`) | por **desidia** — alguien tiene que acordarse | **Sí**: el número está ahí, viejo, y se compara con la realidad de un vistazo |
> | **Trinquete derivado** (el suyo) | porque una **precondición dejó de cumplirse** | **No**: el mecanismo está bien escrito, corrió, hizo su trabajo la última vez, y **nada parece averiado** |
>
> **Automatizar el `845` cambiaría un control que falla por descuido por uno que falla por precondición
> no cumplida, y el segundo es más difícil de ver.** Es la misma familia que H-08 una vez más: la
> condición no se cumple, el mecanismo **se abstiene con toda la razón**, y el resultado agregado se
> lee como normalidad.

**Consecuencia para el REQ de la palanca, que es donde esto entra:** si llega a proponer derivar el
umbral —que es lo natural después de la regla del literal—, **tiene que escribir con él qué pasa cuando
la condición de validez no se cumple, y ese caso tiene que ser RUIDOSO.** Un derivador que se abstiene
en silencio es un control que se apaga solo. Y mientras tanto, el literal **no se toca**.

**Y una segunda mitad, de gobernanza, que aquí no teníamos mirada:** el bloqueo que mantiene su suite
en rojo es **una decisión pendiente de su dueño en otro frente**. O sea: *un bloqueo pendiente en un
frente estaba degradando en silencio un control de otro frente*, y nadie había mirado los dos juntos.
Aquí `PENDING_APPROVAL.md` bloquea el cierre de REQ de forma **visible**, así que no tenemos hoy esa
forma — pero **la pregunta no está escrita en ninguna parte**: *¿qué controles de este proyecto dejan de
funcionar mientras una decisión humana está pendiente?* Va a la pasada de conformidad de 1.34.0 como
pregunta, no como hallazgo.

*(Segunda vez en la misma tarde que este intercambio destapa un hueco real en el proyecto que reporta,
y las dos veces por el mismo mecanismo: una pregunta nuestra les hizo leer con otra intención. Vale como
evidencia de para qué sirve el canal, más allá de transportar informes.)*

### Dos piezas finales del intercambio: quién muta, y qué deja de crecer (2026-09-07)

**1. «Acreditado por mutación» no dice bastante: hay que decir POR QUIÉN.** El proyecto consumidor
acreditó su comparador rompiéndolo en cuatro sitios; su autor ya lo había acreditado por mutación
antes. **Dos de las cuatro sobrevivían.** El motivo es estructural y no de competencia:

> *El autor rompe donde sabe que importa; sólo un tercero rompe donde no ha mirado.*

Medido allí: la mutación de un tercero encontró **el doble** que la del autor. ⇒ el REQ de la palanca,
donde diga «acreditado por mutación», tiene que decir **de quién** — mutación del autor y mutación de un
tercero **no son el mismo control**. Encaja con nuestra propia estructura: en 1.32.1 ninguno de los
cuatro fallos en abierto lo encontró quien escribió el código.

*(Su comparador pasa ya las cuatro y está acreditado, con 16 formas y 16 invocaciones del `.awk` real.
El compromiso de avisarles si 1.34.0 mueve la normalización **no se retira igualmente**: se acordó sin
caducidad y por un motivo —el punto ciego del corpus— que no cambia porque las mutaciones pasen.)*

**2. La pregunta de gobernanza, afinada por ellos, y ya contestada de nuestro lado.** Yo la había
escrito como *«¿qué controles dejan de funcionar mientras una decisión humana está pendiente?»*. Su
versión estrecha es la que se puede contestar:

> **¿Hay algún umbral, piso o inventario que se actualice solo, y qué le pasa mientras su precondición
> no se cumple?**

Y su observación de por qué la ancha no rinde: *«la pregunta que paga no es qué se BLOQUEA, sino qué
deja de CRECER. Un control que se detiene en el nivel que tenía no da ninguna señal, porque sigue
haciendo exactamente lo que hacía ayer.»*

**Respuesta medida para este repositorio: cero instancias.** Lo único que se actualiza solo es el
**bloque derivado** de `docs/ESTADO.md` (`estado_derivado.activo: true`), y **no está condicionado a
ninguna corrida válida**: `stop.sh` no consulta las quality gates ni ningún código de retorno para
decidir si escribe. La **rotación** —lo otro que se actualizaría solo— está **apagada**
(`artefactos: []`). Así que hoy no tenemos la forma «crece sólo si la corrida es válida», y el `845` es
un literal que falla por desidia, que es visible.

> **Método declarado, con la misma franqueza que ellos aplicaron al suyo:** esto es una lectura del
> manifiesto más un `grep` sobre `stop.sh`, no una revisión exhaustiva. La respuesta correcta es
> **«cero encontradas con este método»**, no «cero y sólo cero». La pregunta merece mejor instrumento
> del que se le ha dado hoy, y por eso entra en la pasada de conformidad de 1.34.0 **con las dos
> formulaciones**: la estrecha para contestarla, la ancha para no perderla.

### La lección de la tarde, que no es ninguno de los hallazgos (2026-09-07)

Formulada por el proyecto consumidor al cerrar el intercambio, y es la que ordena todo lo anterior:

> **Un dato puede estar medido, ser correcto, y estar clasificado en la categoría equivocada.**

Tres instancias del mismo día, dos nuestras y una suya:

| Dato | Cómo estaba clasificado | Qué era en realidad |
|---|---|---|
| `CASOS_ESPERADOS=845` | deuda de mantenimiento — «habría que derivarlo» | **el control** que sostiene el cuadre, y que derivarlo destruiría |
| Los 4 fallos en abierto de 1.32.1, ninguno hallado por su autor | «el bucle funciona» | una **propiedad del método**: sólo un tercero rompe donde el autor no ha mirado |
| Su piso congelado seis días | «el trinquete ya funciona» | un control que **dejó de crecer** porque su precondición no se cumple |

**Y lo que las tres comparten, que es lo operativo: ninguna se descubre midiendo mejor.** Las tres
estaban medidas y las tres eran correctas. Se descubrieron **cuando alguien de fuera preguntó por otra
cosa** — dos veces aquí y una allí, siempre porque una pregunta ajena obligó a releer un archivo con
otra intención.

**Consecuencia para el arnés, y va más allá de 1.34.0:** el canal con un proyecto consumidor no es
sólo una vía de informes de defecto. Es el **único mecanismo que tenemos hoy contra el error de
clasificación**, que ninguna puerta puede detectar por construcción: una puerta comprueba que el dato
sea cierto, nunca que esté guardado en la categoría correcta. Eso pesa en cómo se prioriza el canal de
informes (1.34.0) — deja de ser higiene y pasa a ser instrumento.

*(Y por simetría, porque este registro ha ido lleno de hallazgos: allí el `pre-commit` rechazó un commit
suyo por no traer registro de cambio, y la salida fue añadir la entrada, no `--no-verify`. El control
mordió a quien lo mantiene. Conviene que quede escrito junto a los aciertos.)*

## Trabajar con agentes en paralelo: el diseño, con lo medido el 2026-09-07

> **Encargo del propietario.** Escrito el día del **primer despacho paralelo real** de este proyecto
> —tres comisiones a la vez—, así que todo lo de aquí viene de esa tanda o de mediciones de esa tarde,
> no de principios generales. Destino propuesto al final.

### 0. El resumen en una línea

`tools/arnes-paralelo.sh` contesta bien la pregunta que se le hace, y **es la pregunta equivocada**:
responde *«¿estos dos REQ declaran archivos comunes?»*. Las tres cosas que hoy impiden el paralelismo
—y la que lo rompe en silencio— **no son ésa**.

### 1. La colisión universal, medida: `CHANGELOG.md`

**9 archivos de `requirements/` declaran `CHANGELOG.md` en su campo `Archivos:`; de ellos 4 están
`completado`, así que son 5 de los 8 REQ abiertos** (REQ-007, 008, 011, 013, 019).

> **Corrección de la coordinadora (2026-09-07, la levantó el analista de REQ-022 al negarse a
> transcribirla).** Yo escribí aquí y en el CHANGELOG **«8 de los REQ abiertos»**, y de ahí concluí que
> la herramienta dice «colisiona» sobre **cualquier par**. **Las dos cosas son falsas.** Conté los
> archivos que declaran el artefacto y los llamé abiertos sin mirar su `Estado:`, y la conclusión no se
> sigue: un par en el que uno de los dos no lo declare **no colisiona por ahí**.
>
> **Y lo que hay debajo es peor que la colisión que yo describía**, así que la corrección no rebaja el
> problema, lo reencuadra: los tres REQ abiertos que **no** lo declaran —REQ-017, 020, 021— **van a
> escribir en `CHANGELOG.md` igual**, porque toda comisión lo hace. O sea que el campo **miente en las
> dos direcciones a la vez**: de más en cinco REQ (colisión falsa) y **de menos en tres** (`disjunto`
> falso, que es el caro). Es exactamente la regla de las dos mitades, medida sobre el propio corpus.

No es un defecto de la herramienta:
es que **el libro mayor es un destino de escritura compartido por construcción**, igual que
`skills/arnes-upgrade/SKILL.md` colisionaba en **15 de 15** pares por la nota de migración.

**La solución está probada hoy y funcionó: el libro mayor es de la coordinadora.** A las tres
comisiones del 2026-09-07 se les retiró `CHANGELOG.md` **y el commit**; la coordinadora escribió la
entrada y comiteó al final. Con eso, tres comisiones que la herramienta habría declarado colisionantes
corrieron sin pisarse.

⇒ **Regla propuesta:** una comisión **nunca** escribe los artefactos de bitácora y continuidad
(`CHANGELOG.md`, `docs/ESTADO.md`, `docs/PENDIENTES.md`) ni comitea. Los escribe quien orquesta. Y en
consecuencia, **esos archivos dejan de declararse en `Archivos:`** — hoy ocho REQ los declaran y por eso
el campo dice «colisiona» sobre una colisión que la disciplina ya evita.

> ⚠️ **Con su contrapartida, que hay que escribir o el arreglo abre un agujero:** el `pre-commit`
> exige registro de cambio **en el mismo commit**. Si las comisiones dejan de escribirlo, **la
> coordinadora tiene que escribirlo por las tres**, y una entrada olvidada ya no la caza nadie hasta el
> commit. Es un traslado de responsabilidad, no una supresión: hay que decir dónde queda.

### 2. La colisión que ninguna herramienta de archivos puede ver: **la máquina**

**Éste es el hallazgo nuevo del día, y me lo hice a mí mismo.** Despaché en paralelo dos analistas y
**un desarrollador que mide**. Medido en ese momento: 7 procesos de banco vivos, `load average` 0,80.

Los archivos eran disjuntos y aun así el despacho era defectuoso: **una comisión que mide y otra que
consume CPU se invalidan mutuamente los números**, y el fallo es **silencioso** — no hay conflicto, no
hay error, sólo cifras mal. Este repositorio ya tiene el caso extremo documentado: una sonda que
sobrevivió **3 h 41 min al 99,6 % de CPU** y envenenó la línea base de la tarde siguiente, donde el
desarrollador midió 92,6 s donde había 39 y concluyó «dentro del ruido» con lógica interna perfecta.

⇒ **Segunda dimensión de colisión, y hay que declararla igual que la de archivos:** un REQ declara si
su verificación **mide** (`Mide: sí/no`). **Dos comisiones que miden no se despachan a la vez**, aunque
sus archivos sean disjuntos. Las que no miden, sí.

⇒ **Y la mitad barata que sirve mientras eso no exista:** toda cifra que una comisión escriba como
medida declara **en qué condiciones se tomó** —sola o acompañada—. Es una línea, y convierte un número
falso en un número con su condición. *(Aplicado hoy en caliente: se avisó al desarrollador a mitad de
comisión.)*

### 3. Lo que git NO protege, y casi todo el mundo cree que sí

**Dos agentes editando el mismo archivo en el mismo árbol de trabajo no producen un conflicto de
fusión: producen una escritura perdida.** No hay ramas, no hay merge, no hay aviso. El segundo escribe
sobre el resultado del primero y git ve un único archivo cambiado.

Esto invierte la intuición de por qué se pide la comprobación de disjunción. En `AGENTS.md` §6 está
escrito que el riesgo son *«conflictos de fusión y trabajo perdido»*; **de los dos, el que realmente
ocurre en un despacho paralelo dentro del mismo árbol es el segundo, y es el invisible.** Merece
frase propia, porque un conflicto se ve y una escritura perdida no.

### 4. Asignar el ámbito es mejor que comprobarlo

Lo que de hecho hizo posible la tanda de hoy no fue preguntarle a la herramienta: fue **darle a cada
comisión un ámbito de archivos explícito y exclusivo, y prohibirle el resto**. Es una garantía más
fuerte, y la diferencia es la de siempre en este repositorio:

| | Qué es | Modo de fallo |
|---|---|---|
| **Comprobar** (`arnes-paralelo.sh`) | inferir de lo declarado que no se pisan | el campo miente, o está incompleto, o decorado (**SEC-020**) ⇒ **falso `disjunto`**, fail-open |
| **Asignar** (lo de hoy) | imponer a cada comisión dónde puede escribir | la comisión desobedece ⇒ visible en el diff |

⇒ **Propuesta:** el despacho paralelo lleva **ámbito asignado**, y la comprobación pasa a ser lo que
siempre debió ser — una **segunda opinión** que puede desmentir, no la autorización. Y con eso el
`Archivos:` deja de cargar solo con un peso que no aguanta: hoy es simultáneamente el mapa de
coordinación, un campo que **ningún hook lee** y cuya única forma de error —el falso `disjunto`— cuesta
trabajo perdido.

> **Y la regla de higiene del campo, en su forma completa — aportada por el analista de REQ-019 el
> 2026-09-07 y que no estaba escrita en ninguna parte:**
>
> > **`Archivos:` declara exactamente el conjunto de ESCRITURA: ni más, ni menos.** Lo que sólo se lee
> > va en el cuerpo del REQ.
>
> Es **una** regla con dos mitades, y cada mitad produce un error distinto — por eso escribir sólo una
> deja el campo tan roto como estaba:
>
> | Mitad | Qué produce | Coste |
> |---|---|---|
> | **De más** — declarar lo que sólo se lee (REQ-019 lee `templates/AGENTS.md.tpl` y **no** lo declara) | **Colisión falsa** | Devuelve a la serie un trabajo que podía ir en paralelo. Barato y **invisible**: nadie audita el paralelismo que no ocurrió |
> | **De menos** — omitir lo que sí se escribe (`CHANGELOG.md`, el registro de QA) | **`disjunto` falso** | Dos comisiones que van a escribir las dos ahí. **Caro**: escritura perdida |
>
> Con las dos convenciones vivas a la vez —la inclusiva de REQ-019 y la corta de REQ-017— el campo
> comete **los dos** errores a la vez. Y nótese que la regla **no contradice** la pieza 1: el libro
> mayor sale del campo porque deja de ser conjunto de escritura de la comisión —pasa a serlo de la
> coordinadora—, no por excepción.


> **Y la siguiente colisión universal ya está identificada, antes de que muerda: el registro de QA.**
> Con la regla de escritura exacta aplicada, `docs/qa/<versión>.md` entra en el conjunto de escritura de
> **toda** comisión de QA ⇒ **dos QA no podrán ir en paralelo nunca**. Dato que lo confirma: en
> `docs/qa/` ya conviven `1.32.0.md`, `1.32.0-hallazgos-req012-013.md`, `1.32.0-hallazgos-req014.md` y
> tres archivos de vueltas de 1.32.1 — **la partición ya se hace por necesidad y sin convención**, que
> es el estado exacto del que salió el campo `Archivos:`. Dos salidas posibles (archivo por REQ, o
> artefacto de la coordinadora como el libro mayor) y ninguna decidida.

### 4-bis. La tercera dimensión: el **sustrato de lectura compartido**

**Encontrada el 2026-09-07 al intentar despachar una cuarta comisión.** `AGENTS.md` **no aparece en el
`Archivos:` de ningún REQ** —nadie lo escribe salvo el REQ que lo adelgaza— y sin embargo **lo lee todo
agente al arrancar**, porque el ritual del §0 lo obliga. Lo mismo, en menor grado, para
`requirements/README.md` y `docs/ESTADO.md`.

⇒ Una comisión que **reescribe un sustrato de lectura compartido** no puede correr con ninguna otra, y
**ninguna de las tres reglas anteriores lo detecta**: no es colisión de escritura (sólo uno escribe),
no es colisión de máquina (no mide), y el campo `Archivos:` —que declara **escritura**, correctamente—
tampoco lo ve. El daño no es escritura perdida: es que **las otras comisiones leyeron un suelo distinto
del que quedó**, y eso no deja rastro en ningún diff.

**Regla propuesta:** un REQ cuyo conjunto de escritura incluya un artefacto que el ritual de arranque
obliga a leer se despacha **en solitario**. La lista de esos artefactos es corta y se declara una vez
—hoy: `AGENTS.md`, `CLAUDE.md`, `requirements/README.md`, `docs/ESTADO.md`— y **no se infiere**.

*(Caso concreto que la motiva: la implementación de REQ-019 no puede solaparse con nada, y eso cambia el
calendario de 1.33.0. Mejor saberlo antes de despacharla que después de que tres comisiones citen dos
versiones distintas de la misma regla.)*

### 5. La puerta posterior que falta: *¿cambió algo fuera de mi ámbito?*

Todo lo anterior es **prevención**, y este repositorio ya aprendió que preguntar *antes* si algo va a
escribir tiene una vía nueva cada vez. La pregunta de estado equivalente es barata y no envejece:

> **Al cerrar una comisión con ámbito asignado: ¿cambió en el árbol algún archivo fuera de su ámbito?**

Se contesta con un inventario de marcas de tiempo o hashes antes y después; no necesita saber nada de
lo que la comisión hizo. Es la misma forma que **REQ-011** (la puerta posterior sobre `codigo_app`) y
la misma que **CA-06** del banco (*nada de una sección sobrevive a su sección*), un nivel más arriba.
**Detecta la escritura perdida del punto 3** — pero **no la atribuye**, y esa distinción la levantó el
analista de REQ-022 al intentar contratarla, contra lo que yo había escrito aquí:

> En un **árbol de trabajo compartido**, la fotografía «antes/después» de una comisión contiene las
> escrituras concurrentes de las otras. La atribución es imposible **por construcción**, no por falta
> de instrumento.

La salida no es relajar el criterio, es **partir la pregunta en dos granos**: la atribución vive en el
**nivel de llamada** —donde cada escritura pertenece a un emisor conocido antes de que nadie más
escriba—, vía la prevención en `Edit`/`Write`/`MultiEdit` (la ruta ya viaja en el `tool_input`, así que
es gratis) y la puerta posterior de **REQ-011** consumiendo el conjunto de ámbito. El barrido queda
como **red de fondo que detecta y no atribuye**, escrito como límite y no como supuesto.

### 6. Lo que NO se paraleliza, y no cambia

El orden de fases —QA nunca antes que el desarrollador, seguridad nunca antes que QA— **no es una
preferencia de calendario, es la condición de validez de la firma**. La herramienta lo dice en su
propia salida y con razón: *«un «disjunto» no autoriza a correr el auditor a la vez que el QA»*. Nada
de este diseño lo toca. La única salida sigue siendo la excepción nombrada: `Seguridad: preventiva`,
declarada **al emitirla**.

### 7. Orden propuesto y destino

Cinco piezas, de más barata a más cara, y **las tres primeras se pagan solas en la ventana siguiente**:

| | Pieza | Coste | Qué desbloquea |
|---|---|---|---|
| 1 | El **libro mayor es de la coordinadora** (y sale de `Archivos:`) | documental | quita la colisión que afecta a **8 REQ de 8** |
| 2 | **Ámbito asignado** en el despacho paralelo; la herramienta pasa a segunda opinión | documental | convierte un fail-open en un fail-visible |
| 3 | **`Mide: sí/no`** en la cabecera del REQ, y dos que miden no van a la vez | 1 campo + regla | la colisión que hoy nadie ve |
| 4 | La **puerta posterior de ámbito** (¿cambió algo fuera?) | mecanismo | la escritura perdida |
| 5 | Arreglar **SEC-020** y la convención de artefactos de gobierno en `Archivos:` | ya planificado | que la segunda opinión valga |

**Destino: bloque de apertura de 1.34.0, antes del núcleo por estado** — con el mismo argumento que
puso las palancas primero en 1.33.0: **el paralelismo abarata la ventana grande, así que hacerlo antes
es la única forma de cobrarlo**, y 1.34.0 es la que más comisiones tiene. **No se mete en 1.33.0**: esa
ventana se partió hoy justamente para no repetir cómo se descontroló el ciclo 3, y meterle una quinta
palanca sería repetirlo con otro nombre.

**Excepción, y es una sola:** la **pieza 1 ya está en vigor de facto** desde el despacho de hoy —las
tres comisiones corren sin CHANGELOG y sin comitear—. Una práctica en vigor que no está escrita es
deuda desde el primer día, así que **eso se escribe en `AGENTS.md` §6 dentro de 1.33.0**, como
documentación de lo que ya se hace, no como mecanismo nuevo.


### Calibrar un instrumento por COSTE conocido es la forma (d) una capa más arriba (2026-09-07)

**Propuesta de la coordinadora, refutada por el analista de REQ-021 con las instancias medidas
delante.** Yo propuse que cada sonda trajera su **caso de calibración**: una entrada de **coste
conocido por construcción**, y la sonda falla si no lo reproduce. Parecía la forma de contestar «¿esta
sonda mide algo?» sin fiarse de quien la escribió.

**No lo es, y la refutación es empírica: las tres sondas mudas de esta ventana medían tiempo real.**
El JSON vacío daba un hook en 0,1 s con una curva plana y perfecta; el canario sin arrancar decía «sin
casos»; la tercera escribía su salida en otro archivo. **Una calibración por coste absoluto pasa en las
tres.** Verifica que el reloj lee tiempo; **no** verifica que la sonda mida **el sujeto**. Es la forma
prohibida **(d), fijar la magnitud equivocada**, aplicada al **instrumento** en vez de al sujeto — y no
se me ocurrió que la lección se aplicara un nivel más arriba de donde la escribimos.

**Lo que las tres tienen en común no es el coste: es que dejaron de responder al sujeto.** ⇒ la
calibración correcta es de **sensibilidad**, en tres piezas:

1. **Factor conocido, no coste conocido.** Se duplica un parámetro del sujeto sintético y la sonda tiene
   que reproducir **el factor** dentro de una banda declarada. **Auto-anclado**: la velocidad de la
   máquina se cancela, igual que en un cociente de duplicación.
2. **El par sensible / insensible.** Un sujeto cuyo coste **no** depende del parámetro tiene que dar
   ≈1, y la calibración debe **distinguirlos**. Sin la mitad insensible, **una sonda rota que devuelva
   siempre ≈2 pasaría**.
3. **En cada corrida, y FALLA — nunca SKIP.** Una calibración acreditada una vez es *fail-before, no
   puerta*: envejece hacia el lado que abre. Con su coste acotado (≤ 0,25× de la medición que habilita),
   **porque una calibración cara es una calibración que alguien apaga**.

**Y el reparto que lo hace posible sin romper el banco: la sonda MIDE, el corredor JUZGA.** Las sondas
son **programas invocables**, no `source`, así que la invariante de que un ayudante compartido vive en
el corredor queda intacta. Beneficio lateral medido: en su propio proceso `$BASHPID` no hace falta, así
que **el defecto cometido dos veces deja de ser expresable**, no sólo de estar prohibido.

### Una comisión interrumpida puede dejar un documento que se contradice a sí mismo (2026-09-07)

**Medido al parar dos comisiones a mano para bajar el número de agentes en vuelo.** El analista de
REQ-022 había reescrito ya la **cabecera** —`Archivos:` ampliado, `Mide: sí`, y la decisión del
registro de QA— y **no había llegado al cuerpo**, que seguía declarando esa misma pregunta como
abierta. Peor: había puesto `Estado: pendiente`, o sea **«confirmado»** sobre un documento que se
contradice dos secciones más abajo.

**Ninguna puerta mira eso.** `guard-completado` comprueba veredictos, cola de aprobaciones, quality
gates, clase de hallazgo y forma de la cabecera. **No comprueba que el documento sea coherente consigo
mismo**, y no puede: eso es semántica, que es justo el techo honesto que `AGENTS.md` §13 ya declara.

**Dónde entra:** en el diseño del paralelismo, porque el riesgo **nace del despacho** — una comisión
que termina sola deja el documento cerrado; una que se para a mano, no. Y la salida ya está escrita en
otro sitio del arnés y sólo hay que reusarla: `arnes-upgrade` contrata que una migración interrumpida
tiene **dos** caminos válidos y ninguno más —**continuar** comprobando antes qué está ya en su forma
final, o **revertir**—, y prohíbe expresamente *«parece que algunas cosas ya están, sigo desde donde me
parezca»*, que vuelve a inferir el estado del contenido.

⇒ **Regla propuesta: toda comisión interrumpida deja el artefacto en el estado MENOS afirmativo de los
compatibles con lo escrito** (aquí, `borrador` y no `pendiente`), y la nota de interrupción dice **qué
quedó hecho y qué no**. Es barato, lo puede hacer quien para —no hace falta mecanismo— y evita que el
siguiente lea una cabecera que afirma más de lo que el cuerpo sostiene.

### Declararlo una vez no cubre el resto de la sesión (2026-09-07)

**Corrección aceptada del proyecto consumidor, y nos toca a los dos.** Su incidente de hoy —escribir en
un archivo protegido sin que ninguna puerta lo viera— **no era una forma nueva ni un agravante**: era el
**hueco del intérprete ya declarado** (`python3 -c "open(...)"`). Retiran además su propia explicación
inicial —«la evasión fue la ruta relativa tras un `cd`»— porque **el control positivo con la ruta desde
la raíz también pasó**: lo que denegó el otro comando fue el `cp`, no la forma de la ruta. *Leyeron
«denegó» y saltaron a una explicación que no probaron.*

**La causa proximal, que es la parte reutilizable:** declararon el conflicto de herramienta **al empezar**
y **luego no lo aplicaron** cuando el archivo sí estaba protegido.

> **`Declararlo una vez no cubre el resto de la sesión.`**

**Y aquí eso no es una observación ajena: es exactamente lo que hizo la coordinadora hoy.** Declaré la
regla de `AGENTS.md` §13 —*la invariante manda sobre cualquier preferencia de herramienta*— varias veces
a lo largo de la sesión, y aun así escribí con `python3` en **`requirements/REQ-008.md`**, que es un
archivo que `guard-completado` protege. Más tarde, en `REQ-021.md`, cambié a las herramientas de edición
por este mismo motivo. **La declaración no es el cumplimiento**, y una regla que se recuerda por
episodios se incumple entre episodios. Va al REQ de la conformidad de 1.34.0, junto a las promesas más
anchas que el código.

### Un residual descrito en la dirección equivocada hace calcular el riesgo al revés (2026-09-07)

**Aportado por el proyecto consumidor, medido en cuatro rondas sobre un guardián suyo.** Cada arreglo
dejaba a la vista el vecino, y **las cuatro veces la causa fue la misma**: el control perseguía **formas**
—un carácter, un paréntesis, un identificador pegado— y no la **propiedad**. La cuarta lo cerró por
**modo de escaneo** (código / cadena / plantilla / interpolación / comentario), que es lo que de verdad
distingue una invocación de una mención en prosa. **Es la lección del caso `J` en otro dominio: el borde
de una familia no es una lista de caracteres.**

**Y el residual que les quedó trae la mitad nueva.** Un backtick impar dentro de una clase de caracteres
de un regex desincroniza su escáner **hasta el fin del archivo**, así que una marca real detrás queda
**invisible**. Lo declararon —bien— pero **en la dirección equivocada**: lo escribieron como *limitación*
cuando es un **falso negativo**. Exposición medida: 0 archivos.

> **Un residual descrito en la dirección equivocada hace que quien lo lee calcule el riesgo al revés.**
> Una «limitación» se lee como *«hasta aquí llego»*; un **falso negativo** se lee como *«esto puede estar
> pasando ahora mismo y no lo veríamos»*. Son la misma frase y dos decisiones distintas.

**Instancia viva nuestra, del mismo día y sin haberla buscado:** `QA-017-12`. El residual del
acoplamiento de `CA-05` estaba descrito como que falla **«ruidoso — el único PASS desaparece del banco en
la primera corrida»**, y QA midió que **en el modo por defecto no cambia nada**: veredictos idénticos,
`rc 0`. Es **silencioso**, y los dos forzadores declarados lo verían **verde**. Un lector calculaba el
riesgo al revés exactamente como describen. Se está corrigiendo ahora.

### `git add -A` con comisiones vivas: la coordinadora se salta su propia regla (medido 2026-09-07)

**Encontrado por QA al cerrar REQ-017, sobre un commit de la coordinadora.** El commit `7335586`
—titulado «Preventiva R-011…»— **arrastró 192 líneas de `docs/qa/1.33.0.md`** que eran la entrada de
confirmación que QA estaba escribiendo **en ese momento**, bajo un mensaje que **no la menciona**. El
contenido sobrevivió íntegro; lo que quedó falso es **el mensaje del commit**, que es el registro de qué
cambió y por qué.

**La causa es un `git add -A` mientras corrían cuatro comisiones**, y es una instancia exacta de lo que
este mismo documento contrata dos secciones más arriba: el despacho paralelo exige ámbitos disjuntos, y
**quien comitea es una comisión más** — la única, además, que puede tocar **todos** los ámbitos a la vez.

⇒ **Regla, y es barata: mientras haya comisiones vivas, la coordinadora comitea RUTAS NOMBRADAS, nunca
`-A`.** Lo que no sabe nombrar, no lo comitea: está en curso.

**Y la mitad que la hace peor de lo que parece:** el efecto no es una escritura perdida —el contenido
llegó entero— sino un **registro que atribuye mal**. Una bitácora que dice que un commit trae una cosa
cuando trae dos es exactamente el modo de fallo que la rotación existe para no cometer, y el mismo que
midió el proyecto consumidor cuando una entrada de bitácora perdió su título y **su cuerpo quedó
atribuido a otro agente, otra fecha y otro encargo**.

*(Segunda observación de QA en la misma comisión, también de la coordinadora: se le dijo que el árbol
estaba limpio y **no lo estaba** —cuatro archivos modificados y uno sin seguir—. No contaminó la firma,
porque ninguno tocaba el `Archivos:` de REQ-017, pero **la premisa del encargo era falsa** y eso lo tuvo
que descubrir el agente. Un encargo que afirma el estado del árbol debería derivarlo, no recordarlo.)*

---

## El `_doc` del manifiesto es documentación que ninguna migración toca (reportado por un proyecto consumidor, 2026-09-07)

**Medido en el proyecto que reporta, no aquí.** Su `.arnes/config.json` justifica haber apagado el
bloque derivado porque contaba «completado 2 / otros 44» donde a mano salían 9. Comprobado hoy en ese
proyecto: el bloque dice `completado 9 · en-revisión 16 · en-progreso 4 · otros 18` y **cuadra exacto
con el conteo a mano**. El arnés lo arregló aguas arriba y **la justificación escrita sigue ahí**,
describiendo un defecto que ya no existe.

**Por qué es del arnés y no de ese proyecto.** `templates/arnes-config.json.tpl` lleva **diez**
cadenas `_doc`. `arnes-init` las copia. Y `skills/arnes-upgrade/SKILL.md` sabe **añadir bloques
nuevos** al manifiesto —`estado_derivado` (1.22.0), `rotacion` (1.22.0), `veredictos` y `git`
(1.31.0)— pero **no tiene ningún concepto para el texto que ya está dentro**: su merge a tres vías
clasifica **secciones de Markdown** en `NUEVO`/`INTACTO`/`MODIFICADO`/`ELIMINADO`, y un valor JSON no
es una sección. No hay estado que asignarle, así que no se mira.

**El resultado es una deriva garantizada y silenciosa**, de la misma familia que la que motivó
`arnes-upgrade`: la máquina cambia de conducta y la prosa del proyecto sigue describiendo la anterior.
Sólo que aquí es peor por **dónde vive**. Una prosa desfasada en un `.md` está a páginas del código;
ésta está **a tres líneas del valor que describe**, dentro del archivo cuyo trabajo entero es ser la
fuente de verdad legible por máquina. Un lector le da **más** crédito, no menos — y quien la lee suele
estar decidiendo si encender o apagar la clave que tiene al lado.

**Lo que NO es:** no es un fallo en abierto. El valor manda, los hooks leen el valor y el `_doc` no
tiene efecto sobre ninguna puerta. Es `instrumento`.

**Lo que hay que decidir, y no está decidido:**

1. **¿El `_doc` es del arnés o del proyecto?** Si es del arnés, se puede sustituir sin preguntar en
   cada migración y el problema desaparece. Si el proyecto puede anotarlo —y hoy nada se lo
   impide—, entonces sustituirlo pisa trabajo humano y hace falta la misma base a tres vías que el
   resto. **La respuesta cambia el diseño entero, y la barata es la primera**: declarar el `_doc`
   propiedad del arnés y mover cualquier nota del proyecto a una clave hermana (`_nota`) que la
   migración nunca toque.
2. **Un `_doc` que cita una versión o una medida caduca por definición.** El de este caso citaba un
   conteo. Regla candidata: el `_doc` describe **qué hace la clave**, nunca **qué se midió** ni
   **por qué este proyecto la puso así** — eso último es `_nota`, y es del proyecto.

**Dueño:** `desarrollador` (la plantilla y la skill). **Ventana:** sin fijar. Va con el bloque de
plantillas y migración, no antes.

**Y la observación que lo hace más urgente de lo que parece:** este hallazgo **no se podía producir
desde dentro**. El manifiesto de este repositorio no tiene el `_doc` caducado —lo comprobé clave por
clave y los tres bloques son consistentes—, así que ningún barrido del autoalojamiento lo habría
encontrado nunca. Lo encontró un proyecto que lleva un año con el suyo. Es la segunda vez en dos días
que **un corpus externo prueba algo en la dimensión en la que es indisciplinado**, y la primera fue la
ceguera de los cinco campos de cabecera. Sube la prioridad de `REQ-018`, el canal de informes.

## Tres instancias más del agujero del intérprete, en un proyecto real y en un día (2026-09-07)

Amplía la sección «El agujero del intérprete, ejecutado por la coordinadora». El mismo proyecto
reporta haber escrito **tres veces** en un archivo protegido a través del hueco del intérprete, **con
el catch-all encendido**, en una sola sesión.

**Lo que eso mide, y no es lo que parece.** No mide que el guardián esté mal: `AGENTS.md` §13 declara
el hueco por escrito y lo llama «el agujero más grande de los que quedan». Mide **la frecuencia**, que
nadie había puesto en números: una sesión de trabajo normal, sin intención de rodear nada, lo atraviesa
**tres veces**. Hasta hoy el hueco tenía descripción y no tenía tasa.

**Consecuencia sobre el orden de las ventanas.** `REQ-011` —la puerta que pregunta **después**— está
hoy en 1.34.0 y es exactamente el mecanismo que cierra esta clase: deja de preguntar *antes* si un
comando va a escribir y pregunta *después* si algo protegido cambió. Con una tasa medida de tres por
sesión en un proyecto real, su prioridad relativa dentro de 1.34.0 sube.

**Y confirma, con la evidencia en la dirección contraria, que no se debe filtrar.** La propuesta
recurrente de ahorrar el proceso del guardián filtrando por patrón ya se probó en 1.25.0 y produjo
tres versiones (1.25.0–1.27.0) en las que una redirección simple rodeaba las dos puertas, porque el
filtro no ve lo que Claude Code separa del comando antes de evaluar el patrón. 1.28.0 volvió al
catch-all a propósito. **Con el catch-all encendido ya se cuelan tres escrituras por sesión; con
filtro, la superficie sería mayor.** El coste medido del guardián es de ~20 ms por comando y ~35 s en
una sesión de ocho horas: **un 0,1 %**, y en la categoría equivocada. Donde mirar, si el coste
molesta, es cuántos subagentes se despachan.


---

## Las dos banderas del manifiesto que ahorran contexto (medido 2026-09-08, coordinadora)

**Decisión: las dos SÍ, ninguna hoy.** El propietario delegó la decisión («decide tú», 2026-09-08) tras
leer las dos opciones con su coste. No se aplican en la ventana 1.33.0 por un motivo **medido, no de
calendario**: `.arnes/config.json` está dentro de `codigo_app.globs`
(`hooks/*`, `tools/*`, `.github/*`, **`.arnes/config.json`**, `.claude-plugin/*`), así que no es
«encender un flag» — es cambio de mecanismo, con REQ y ciclo de cuatro agentes. Y la rotación reescribe
sus artefactos **en cada parada de agente**, incluidas las dos comisiones que deben cerrar 1.33.0.

**Van detrás de `REQ-019`**, que `docs/PLAN.md` protege como primer trabajo ÚNICO de 1.34.0.

### Por qué valen la pena: el peso real del contexto, medido hoy

| Archivo | KB | ≈ tokens |
|---|---:|---:|
| `CHANGELOG.md` | 467 | ~120 k |
| `docs/seguridad/registro-seguridad.md` | 458 | ~120 k |
| `docs/qa/1.33.0.md` | 226 | ~58 k |
| `requirements/REQ-014.md` | 128 | ~33 k |
| `AGENTS.md` | 34 | ~9 k |
| **`requirements/` entero** | **1 759** | ~450 k |

**El número que cierra el argumento:** un auditor que lee `registro-seguridad.md` entero carga ~120 k que
paga **en cada turno posterior**. Veinte turnos × 120 k = **2,4 M**. Una comisión de auditoría medida el
2026-09-08 en una sesión de Codex consumió **2,56 M de lectura de caché**. **El número reproduce**, y la
causa no era el nivel de esfuerzo: era un archivo de 458 KB dentro de la ventana.

### (a) `rotacion.activo: true` — y los dos artefactos crecen en DIRECCIONES OPUESTAS

Esto es lo caro de averiguar y por eso queda escrito: **la clave `orden` global no sirve aquí**, y usarla
archivaría lo más reciente del registro de seguridad. Medido por lectura, no supuesto:

| Artefacto | Evidencia | `orden` correcto |
|---|---|---|
| `CHANGELOG.md` | la entrada más nueva está en la **línea 5**; la anterior en la 47 | **`nuevo-primero`** |
| `docs/seguridad/registro-seguridad.md` | `R-001` en la línea **14**; `R-018` en la **5311** | **`nuevo-al-final`** |

Los dos superan el `umbral_bytes` actual (262 144): 467 176 y 458 433. Rotarían en la primera parada.
Es exactamente el modo de fallo que la skill `arnes-upgrade` describe para 1.26.0 —artefactos que
comparten un solo `orden`—, así que **cada uno se declara como objeto con el suyo**.

### (b) `veredictos.exigir_fecha` y `veredictos.caducan_con_codigo` — el remedio de `SEC-060`

`SEC-060` (`contrato`, auditor, 2026-09-08) dice que un REQ reabierto **conserva los veredictos de la
ventana anterior y ninguna puerta los caduca**. El remedio ya existe en el plugin y viene apagado.

**Coste de encenderlo, medido como pide su propia documentación:** de **25** veredictos `aprobado` en
cabecera, **20 llevan fecha y 5 no** — `REQ-001` (×2), `REQ-012` (×2), `REQ-014` (×1). Y el coste real es
**casi cero**, porque la puerta muerde en la **transición** a `completado`:

- `REQ-001` y `REQ-012` están `completado` y no vuelven a transicionar; sólo les mordería si se reabren
  — que es precisamente cuando debe morder.
- El de `REQ-014` es el `Seguridad: aprobado` sin fecha del 2026-09-06 que **el propio Historial del REQ
  declara nulo**, y que el `auditor-seguridad` retira en su turno de esta misma ventana.

Encenderlo **no bloquea ningún cierre pendiente**. Esa medición es la parte cara del REQ futuro y ya está
hecha: no se vuelve a derivar, se cita.


---

## PRIMER TRABAJO DE 1.34.0 — la sonda de `REQ-017 CA-08` (propietario, 2026-09-08)

**Va por DELANTE de `REQ-019`**, por enmienda al alcance en `docs/PLAN.md`. No es deuda acumulada bajo la
regla de acumulación: es la condición para que cualquier publicación posterior signifique algo.

### El defecto, con la medición hecha — no se vuelve a derivar

El caso `REQ-017 CA-08 (ii) una cabecera de 200 líneas: el reloj no sube más de 1,25× el de v1.32.1`
falla el check **requerido y estricto** `hooks-en-linux` afirmando en su propia salida
*«esto es una regresión, no ruido»*.

**Cinco corridas de CI sobre código idéntico** *(actualizado el 2026-09-08: eran cuatro; `7dc0699` añadió un PASS de **1,017×**, que **no cambia la conclusión y la refuerza** — el recorrido sigue siendo 0,973×–1,364× y sigue cubriendo el techo)* —ningún commit desde `b9afa01` toca `hooks/`, `tools/` ni
`.github/`, verificado de forma independiente por el `auditor-seguridad` en `R-019`:

| Corrida | Commit | Razón publicada | Convergencia (2.º mín / mín) | Veredicto |
|---|---|---:|---|---|
| 23:39 | `921dc74` | **1,131×** | 1,012× / 1,142× | PASS |
| 23:53 | `516e849` | **0,973×** | 1,185× / 1,138× | PASS |
| 00:00 | `d4e0033` | **1,337×** | 1,025× / 1,232× | FAIL |
| 00:24 | `eff143b` | **1,364×** | 1,002× / 1,249× | FAIL |

**El dato que cierra la discusión:** `0,973×` significa que este árbol salió **más rápido** que
`v1.32.1`. Una regresión real no puede ser más rápida. La dispersión de la sonda va de **0,97 a 1,36**
—factor **1,40**— y el techo que vigila es **1,25**: el techo vive **dentro** del ruido, así que el caso
no puede distinguir la regresión que dice medir de su propia varianza.

### La causa, medida — y NO es «el umbral está mal puesto»

**Corrección de la coordinadora (2026-09-08), escrita antes de que nadie trabaje sobre lo anterior.** Una
primera lectura de estas cifras concluyó que el defecto era que el umbral de convergencia y el techo de
regresión fueran el mismo número. **Es falso: son el mismo número A PROPÓSITO**, y `REQ-017 CA-08` lo
argumenta por escrito — *«no es un número nuevo: es el mismo, porque un instrumento tiene que resolver al
menos el factor que vigila»*. **El caso hace exactamente lo que su criterio prescribe**, y su hermano
también: no está mal configurado, simplemente excedió el umbral y se abstuvo, que es lo previsto.

**Lo que las cuatro corridas muestran es otra cosa, y es peor: el remedio que `CA-08` YA prescribió está
implementado y no basta.** `CA-08` documenta que en aislamiento la razón da **0,821–1,010**, que bajo
`JOBS=6` sube de forma sistemática por contención que el propio banco fabrica, y prescribe la
**intercalación** de series para cancelarla «por construcción», más la comprobación de convergencia. Todo
eso está construido. Y aun así la razón recorre **0,973–1,364**.

**Dónde está el hueco.** La convergencia compara el **segundo mínimo de cada árbol con su propio mínimo**:
mide si **cada serie** se asentó. Pero el ruido de la **razón** no procede de la dispersión interna de
cada brazo — procede de las condiciones **entre brazos**. Dos series pueden converger cada una a 1,2× y su
cociente oscilar 1,4×. La comprobación responde *«¿se asentó cada serie?»* cuando el criterio necesita
*«¿puede este cociente distinguir 1,25×?»*.

**Y los datos lo enseñan:** los **dos** rojos son justo aquellos en que un brazo converge **al borde**
—1,232× y 1,249× contra el límite de 1,250×— mientras el otro converge holgado (1,025× y 1,002×). Los dos
verdes tienen convergencias equilibradas. A 1,249× el instrumento resuelve **exactamente** 1,25 y ni un
poco mejor, y sobre esa resolución afirma un 1,364×.

**La clase, nombrada:** `CA-08` dice «**al menos** el factor que vigila», y eligió el valor **más flojo**
compatible con ese argumento sin medir si alcanzaba. Es **un criterio derivado sin comprobar su
factibilidad** — la misma clase que `DEV-021-05`, que el techo de 400 líneas de `CA-18` y que el techo de
4× de `REQ-021 CA-08 (iii)` re-derivado a 6×. El argumento es correcto; el valor no se comprobó.

### Las formas conformes, y la que ya no vale

Lo que **no** sirve, porque ya está hecho: intercalar más, o repetir la comprobación de convergencia tal
como está. Lo que queda, y hay que **medir antes de elegir**:

1. **Convergencia estrictamente más apretada que el techo** —el «al menos» de `CA-08` admite margen; el
   valor concreto **se deriva midiendo**, no se elige—, y `CA-08` se re-deriva en la misma edición.
2. **Una cota sobre la dispersión de la RAZÓN**, no de cada brazo: repetir el par intercalado **k** veces
   y exigir que el recorrido del cociente quepa bajo el techo antes de emitir veredicto; si no cabe,
   `SKIP` con motivo.
3. **Sacar (ii) de la puerta requerida y dejarlo como acreditación fechada** —la vía que `CA-05 (i)` y
   `(ii)` ya usan en este mismo REQ, con `ARNES_COSTE_RUTA_CRITICA=1`—. **No es apagar la señal**: la
   medición sigue existiendo y se exige al cerrar el REQ; lo que deja de hacer es decidir cada PR con un
   instrumento que no resuelve. Requiere decisión del propietario y queda escrito.

**La opción 2 es la única que ataca la magnitud correcta**, y por eso es la candidata; las otras dos
acotan o rodean. Cuál se toma **se decide midiendo**, y esa medición es el primer trabajo.

### Lo prohibido por nombre

**No** `continue-on-error`, **no** sacar el caso del CI, y **no** relanzar hasta obtener un verde para
fusionar en esa corrida. Los dos primeros ponen la puerta en verde **apagando la señal** —modo de fallo
que `AGENTS.md` §13 nombra y que `REQ-014 CA-18 (ii)` prohíbe por escrito—; el tercero, con una sonda cuya
dispersión cubre el techo, no es esperar a que pase: es **elegir la corrida que da la respuesta que se
quiere**.

### Coste y ceremonia

Es cambio en `tests/`, o sea **`critico`** por `AGENTS.md` §6: ciclo completo
`analista → desarrollador → qa-tester → auditor-seguridad`. Estimado al ritmo medido el 2026-09-08:
**4 comisiones, ~1–2 h**. La medición de arriba es la parte cara del análisis y **ya está hecha**: se
cita, no se rehace.


---

## Mejoras aplazadas A UNA VERSIÓN FUTURA por el propietario (2026-09-08)

Registradas aquí, **no en la ventana actual**, por la regla de acumulación del 2026-09-08. Ninguna es
`contrato`; ninguna bloquea nada hoy.

### 1. ~~El campo que no sabe decir «parcial»~~ — **RESUELTO el 2026-09-08, no aplazado**

> **Corrección honesta del registro.** El propietario pidió aplazarlo a una versión futura, y cuando
> llegó esa instrucción **la comisión que lo arregla ya estaba despachada** (iba como punto 4 de su
> encargo). `CA-17.1` de `REQ-019` tiene desde hoy un tercer valor, **`parcial`**, válido *sólo* con sus
> **dos mitades en la misma fila** —el ejecutor de la sub-promesa que sí cumple una máquina, y el texto
> de la parte que no cumple ninguna—; a una fila `parcial` a la que le falte una mitad se la cuenta como
> **sin ejecutor declarado**. `CA-17.3` (fail-closed) y `CA-17.4` (trinquete asimétrico) se extendieron a
> la mitad con ejecutor. **Se deja escrito el diagnóstico de abajo** porque es el motivo del arreglo y
> porque nombra una clase que reaparece; lo que ya no aplica es el aplazamiento.

#### El diagnóstico que lo motivó (`D-2` de `REQ-019` F1)

**Qué pasa.** `CA-17.1` de `REQ-019` exige **un** valor por fila al clasificar cada promesa del arnés
—«¿esto lo cumple una máquina o no?»—. Pero **diez elementos son mixtos**: una sub-promesa que **sí**
cumple una máquina, dentro de un bloque cuyo resto **no lo cumple nadie**. **El campo no tiene forma de
decir «parcial»**, así que quien clasifique tiene que elegir entre dos respuestas y **las dos son falsas**
para esos diez.

**Por qué importa y no es cosmético.** Es la misma familia que ya costó caro dos veces en este proyecto:
un campo cuya **forma** no admite el estado real obliga a escribir algo falso, y después alguien lee ese
algo y decide. `AGENTS.md` §13 ya describe la versión buena de esta lección —el hook que **avisa sin
decidir** cuando un veredicto sale del vocabulario— y aquí falta el equivalente: **un valor para lo
mixto**, o una forma declarada de partir la fila.

**Por qué se aplaza.** Darle forma al campo obliga a tocar el criterio, el lector y las plantillas que
los proyectos heredan — y **no bloquea** el reparto de `REQ-019`, que puede declararlos por su
sub-promesa y anotarlo. **Dueño:** `analista-requerimientos` (la forma) y `desarrollador` (el lector).
**Ventana:** sin fijar; se retoma cuando estorbe, que es la doctrina de este archivo.

**Cómo se sabrá que estorba, para que no se quede aquí para siempre:** si alguna de esas diez filas se
usa para **decidir** algo —un cierre, un reparto, una acreditación—, deja de ser deuda y sube de clase.


---

## ESTIMADO (no medido) el 2026-09-08: cuánto ocuparía `REQ-019` en 1.34.0

> **CORRECCIÓN de la coordinadora, 2026-09-08.** Esta sección se tituló «MEDIDO … no cabe» y las dos
> cosas eran falsas. **(1)** Las 9–11 comisiones y las 8,5–14 h son **estimación del propio REQ**, que lo
> declara así en `requirements/REQ-019.md:1375`: *«Es estimación, no medición, y se declara como tal»*.
> **(2)** «No cabe» era una **conclusión de la coordinadora**, no una decisión del propietario: el alcance
> aprobado el 2026-09-08 (`docs/PLAN.md`, ALCANCE DE 1.34.0) lista `REQ-019` como **trabajo #2 de los
> cuatro**, no lo incluye en «Lo que SALE de 1.34.0», y el propio REQ declara `Versión destino: 1.34.0`.
> **`REQ-019` SIGUE EN 1.34.0 por decisión vigente.** Lo de abajo es insumo para decidir, no la decisión.

**`REQ-019` se estima a sí mismo en 9–11 comisiones y ≈8,5–14 h** (`requirements/REQ-019.md`, tabla de
fases). **F2 y F3 son ventanas de SOLITARIO** por `CA-16`: mientras corren, **nada más puede correr**.
`REQ-019` no es *un trabajo de* la ventana — **es la ventana**.

**Y eso choca con un plazo que no es negociable.** El vencimiento de `SEC-047` (severidad **crítica**) es
**el cierre de 1.34.0**, escrito por el `auditor-seguridad` en su sede
(`docs/seguridad/registro-seguridad.md:3684`). Su remediación son `REQ-023` + `REQ-024`. Si `REQ-019` se
come la ventana, esos dos no entran y **`SEC-047` y `SEC-051` suben a `contrato`**.

### La aritmética del ahorro, hecha entera y sin adornos

| | |
|---|---|
| **Coste** | 9–11 comisiones ≈ **0,9–1,1 M tokens** |
| **Ahorro** | techo 0,72× sobre 18.500 → **≈5.200 tokens de carga por comisión** |
| **Con el efecto de caché** | ≈5.200 × ~30 turnos ≈ 156 k de lectura de caché por comisión ≈ **15 k equivalentes en fresco** |
| **Por ventana** (~20 comisiones) | **≈300 k equivalentes** |
| **Retorno** | **≈3–4 ventanas** |

**Se paga, pero no pronto.** Y mientras se paga, bloquea la ventana en la que vence un hallazgo crítico.

### Lo que esto NO desmiente

`REQ-019` **sigue siendo la palanca correcta**; lo que se desmiente es que sea la **barata**. Su sitio es
una ventana **propia**, no compartida con un plazo ajeno.

### Y el dato que conviene tener delante antes de invertir 9 comisiones en recortar un 28 %

**La palanca mayor medida en este proyecto no fue ninguna versión del plugin: fue el ENCARGO.** Seis
comisiones del 2026-09-08/09 con el mismo modelo y los mismos agentes: **229 k → 154 k → 107 k → 64 k →
46 k → 58 k**, y las dos del 2026-09-08 en **95 k** y **62 k**. Lo único que cambió fue cerrar la lista de
lectura —rangos de línea en vez de archivos, cifras entregadas ya medidas, prohibiciones explícitas—.
**Un factor 5, gratis, sin ceremonia y ya aplicado.** Ninguna palanca contratada se le acerca.


---

## LA PALANCA QUE NADIE HABÍA MEDIDO: los historiales de REQ pesan el 22 % y la rotación no puede tocarlos

**Origen:** análisis externo (ChatGPT, aportado por el propietario el 2026-09-08). Señaló que adelgazar
`AGENTS.md` **pierde parte del beneficio si después se lee entero un REQ de 150.000 caracteres**.
Verificado y medido por la coordinadora; **es correcto, y el motivo es más preciso de lo que él podía
demostrar**.

### La medición

| | |
|---|---|
| `## Historial de cambios` en todo `requirements/` | **399.182 B de 1.771.828 B = 22 %** ≈ **99 k tokens** |
| `REQ-014` | 67.133 B — el **43 %** de su archivo |
| `REQ-021` | 75.943 B |
| `REQ-017` | 39.672 B — su analista midió que le costó **~13 k tokens** él solo |
| `REQ-013` / `REQ-012` | 43 % y 42 % de sus archivos |

### El bloqueo, medido y exacto

`hooks/rotar-artefactos.sh` **sabe archivar una sección de un documento** —está construido y `AGENTS.md`
§13 lo describe: mueve la historia a `historial/<nombre>.md` y **no toca la cabecera ni los criterios**,
que son el contrato—. Pero reconoce como **entrada** las líneas que empiezan por `- `, `* `, `### ` o
`N. `, **y los historiales de este proyecto son TABLAS**: sus filas empiezan por `|`.

**Medido en tres REQ: 30, 24 y 44 filas de tabla y CERO entradas reconocibles.** El propio hook lo dice
en su aviso: *«SÍ contiene la sección y supera el umbral, pero no tiene ni una ENTRADA reconocible; no se
rota»*.

**Conclusión: el mecanismo existe, está apagado, y encenderlo hoy NO HARÍA NADA** sobre lo que más pesa.

### Por qué esto va por delante de `REQ-019`

| | `REQ-019` | Rotación de historiales |
|---|---|---|
| Coste | **9–11 comisiones, 8,5–14 h**, con F2/F3 en solitario | **una función** de `rotar-artefactos.sh` + su declaración en el manifiesto |
| Ahorro | ≈**5.200 tokens** de carga por comisión | **10–17 k tokens** en cada comisión que toque un REQ grande |
| Riesgo | reparto de los dos documentos de gobierno | la cabecera y los criterios **no se tocan nunca** (ya es invariante del hook) |
| Retorno | ≈3–4 ventanas | **la primera comisión que lea un REQ rotado** |

**No sustituye a `REQ-019`: lo precede.** Y hay una razón de método, no sólo de coste — mientras los
historiales pesen 99 k tokens, **el ahorro de `REQ-019` no se puede atribuir**: quedaría mezclado con el
ruido de qué REQ tocó cada comisión. Es exactamente el error que `docs/PLAN.md` ya documenta («la línea
base envenenada por la sonda desbocada»).

### Alcance del trabajo, para que no crezca

Es cambio en `hooks/`, o sea **`critico`**: ciclo completo. Necesita **REQ nuevo** (no existe). Dos
piezas y ninguna más: **(1)** que el reconocedor de entradas admita la **fila de tabla** —con su
cabecera y su separador conservados como preámbulo, que es lo que ya hace con el preámbulo de sección—;
**(2)** declarar el artefacto en `rotacion.artefactos` con `glob: requirements/REQ-*.md`,
`seccion: "## Historial de cambios"` y su `archivo_dir`. La forma exacta ya está documentada en
`AGENTS.md` §13 y en el `_doc_artefactos` del manifiesto: **no hay que diseñarla, hay que implementarla.**

---

## Contradicción de instrucciones sobre quién comitea (verificada, 2026-09-08)

**Origen:** el mismo análisis externo. **Verificada y cierta.**

- `agents/desarrollador.md:59-60` y su lista de comprobación `:69` le dicen al desarrollador que **haga
  el commit** y actualice `CHANGELOG.md` **en el mismo commit**.
- `requirements/README.md:197-198` dice que la entrada de `CHANGELOG.md` la escribe **«quien comitea, que
  es quien orquesta»** — la coordinadora.

**Dos documentos asignan el mismo trabajo a dos actores distintos.** Consecuencia práctica: consultas,
trabajo duplicado y correcciones — que es justo lo que se quiere dejar de pagar.

**Y agrava, que es lo que lo saca de «erratita»:** `agents/desarrollador.md` **lo heredan todos los
proyectos que instalan el arnés**, así que la contradicción no es local — se propaga. Clase
`instrumento`; **dueño:** `analista-requerimientos` (decidir cuál manda) y `desarrollador` (el texto del
agente). Resolverlo es barato y va con la ventana de coste.


---

## Cuatro precisiones sobre `REQ-026`, para su comisión de implementación (2026-09-08)

**Origen:** revisión externa aportada por el propietario, verificada por la coordinadora contra el REQ.
**No se abre otra ronda de análisis ahora** (decisión del propietario: cerrar el contrato y seguir con la
sonda). Se registran aquí para que quien implemente `REQ-026` **no las descubra a mitad**.

### 1. `CA-15` fija un techo de reloj SIN declarar plataforma — hay que arreglarlo

Dice *«la rotación añade **≤ 1,5 s de reloj** al tiempo de parada (mediana de 5 paradas, medida con la
misma medición de reloj que usa el banco)»* y **no dice en qué máquina**. En este proyecto eso no es una
omisión menor: `AGENTS.md` §7 registra que **el mismo banco tarda ~30 min en Windows y segundos en
Linux**, y ése es el motivo por el que corre en CI y no como puerta del hook. Un techo de reloj sin
plataforma **no se puede desmentir ni acreditar**.

**Qué falta, en concreto:** la plataforma de referencia, y las condiciones —máquina en reposo o no, número
de comisiones vivas, y si la mediana se toma en frío o en caliente—. Sin eso, la primera medición que lo
supere no distinguirá una rotación cara de un runner cargado, que es exactamente el modo de fallo que
`REQ-017 CA-08` acaba de costar una ventana entera.

### 2. Tensión latente entre `CA-13` y `CA-17`: la forma del `glob` contradice la candidatura

- **`CA-13`** pide el `glob` *«con la forma `requirements/REQ-*.md`, ajustado a los candidatos de CA-17»*.
- **`CA-17`** exige que el `glob` *«case **exactamente** con los REQ así justificados, de modo que ningún
  REQ no candidato se rota»*.

**Un glob con la forma `requirements/REQ-*.md` casa con TODOS.** Las dos frases sólo son ciertas a la vez
si todos los REQ son candidatos — que es justo lo que `CA-17` niega. Quien implemente tiene que elegir, y
**la elección es de contrato**: o `glob` enumerado por candidato, o varios elementos en
`rotacion.artefactos`, o una forma que el hook admita y que hoy no está documentada. **No se resuelve
implementando: se resuelve en el REQ**, y quien lo toque debe decirlo antes de escribir código.

### 3. `Archivos:` NO es el conjunto que se rota, y conviene que quede dicho

`REQ-026` declara `requirements/REQ-*.md` en su campo `Archivos:` **a propósito y de forma
conservadora**: al activarse la rotación, cada parada puede reescribir la historia de cualquier REQ que
case, y el campo existe para que `tools/arnes-paralelo.sh` **no autorice paralelismo en falso**. **Eso es
ámbito de ESCRITURA, no ámbito de ROTACIÓN.** Confundirlos convertiría una declaración prudente en la
decisión de rotarlo todo — lo contrario de `CA-17`. Va escrito aquí porque los dos campos llevan el mismo
literal y **la confusión es de una sola lectura distraída**.

### 4. `orden: nuevo-al-final` está acreditado en UN archivo, no en todos

Medido en `requirements/REQ-017.md` (`:436` es la fila de creación, `:462-463` las recientes). **Un
archivo no demuestra el orden de los demás.** Antes de aplicar la rotación a cada candidato hay que
**comprobar su orden**, no heredarlo — y equivocarlo **archiva lo más reciente**, que es el modo de fallo
que `skills/arnes-upgrade` documenta para 1.26.0.

### Corrección de coste, para el registro

El coste de la comisión que escribió `REQ-026` es **≈56 k tokens**, no los ≈46 k del informe preliminar:
la diferencia son las **tres rondas de corrección en vuelo**. La cifra buena es la de cierre.


---

## Desfase de fechas introducido por la coordinadora (2026-09-08) — 20 menciones pendientes en dos REQ

**Causa:** tras publicar `v1.33.0` leí los sellos de GitHub —`mergedAt: 2026-09-09T02:31:08Z`— y empecé a
fechar en **UTC**. El repositorio usa **fecha local**, y lo dice su propio recuento: **42 entradas del
09-08 contra 8 del 09-09**, y el merge y el tag están fechados `2026-09-08 20:31 -0600`. A esa hora eran
las **21:26 CST del 08**, con UTC ya en el 09.

**Corregido (25 menciones):** `CHANGELOG.md` (10), `docs/PENDIENTES.md` (8), `docs/PLAN.md` (5),
`PENDING_APPROVAL.md` (1), `docs/ESTADO.md` (1). Ninguna era una referencia legítima a un sello UTC — se
enumeraron una por una antes de sustituir, y no en bloque: **un `sed` global sin mirar es lo que esta
misma mañana estuvo a punto de hacer que tres criterios pasaran por tautología**.

**PENDIENTE (20 menciones), y no se toca aquí porque es contrato ajeno:**

| Archivo | Menciones | Quién |
|---|---:|---|
| `requirements/REQ-019.md` | **12** | `analista-requerimientos` |
| `requirements/REQ-026.md` | **8** | `analista-requerimientos` |

**Se corrigen en la próxima comisión que toque cada archivo**, no en una propia: son fechas, no
contenido, y una comisión dedicada a dos sustituciones cuesta más de lo que arregla. **Pero no se dejan
sin corregir:** una fila de Historial fechada un día por delante rompe el orden temporal contra todo lo
demás, y este proyecto usa ese orden para saber qué corrigió a qué. `REQ-017` **no está afectado** — su
analista fechó en local, correctamente.

**Clase:** `instrumento`. **Y la lección, que es la que vale:** las horas de las APIs vienen en **UTC** y
las del repositorio son **locales**; a partir de las 18:00 CST son días distintos. Leer un sello de
GitHub y escribirlo como fecha del proyecto es un error que **sólo aparece de noche**, que es cuando
nadie lo revisa.


---

## Reglas para la coordinadora — entrada para `REQ-025`, NO un REQ nuevo (2026-09-08)

**Origen:** propuesta del propietario. `REQ-025` ya existe (`borrador`, «el arnés vigila también a quien
orquesta: la coordinadora es el único actor sin puerta de contenido»). Esto **no abre trabajo nuevo**: es
material para su diseño, y **la propuesta explícitamente NO pide otro agente revisor**.

**La comprobación de antes de despachar, que es la que más rinde** — cuatro preguntas, por escrito en el
propio encargo, y no se despacha sin ellas:

1. ¿Qué **resultado exacto** debe entregar?
2. ¿Los **criterios pueden cumplirse simultáneamente**?
3. ¿Qué **supuesto o cifra** necesita comprobarse primero?
4. ¿Qué queda **fuera**, y **cuándo debe detenerse**?

**Está comprobada contra los fallos del 2026-09-08, y por eso se registra:** la 3 habría cazado el techo
`0,60×` de `REQ-019 CA-07` (insatisfacible con suelo medido 0,68×) y el `≤ 1,5 s` de `REQ-026 CA-15`
(escrito sin medición que lo fundara); la 2, la contradicción entre `CA-13` y `CA-17`.

**Las otras seis reglas**, en una línea cada una: separar **dato medido / cálculo / estimación /
hipótesis** —que una medición sea correcta **no valida la conclusión**—; **no convertir propuestas en
compromisos** (nada de prometer ahorro, duración o cobertura sin base); **mantener visibles las decisiones
vigentes** en una referencia breve en vez de reconstruirlas de conversaciones largas; **corregir sin
ampliar** (lo demás a esta cola salvo que impida el trabajo en curso); **cerrar cuando la evidencia
alcance** —decidir si una observación externa aporta defecto nuevo, algo ya cubierto o mejora opcional, en
vez de abrir otra ronda—; y **responder con evidencia breve** (resultado, evidencia, limitación material,
siguiente paso).

### La separación de responsabilidades, que es la parte accionable hoy

**La coordinadora organiza y propone; las herramientas verifican lo mecánico** — fechas, versiones,
archivos modificados, conteos y pruebas. Pedirle a un modelo que recuerde y calcule todo eso multiplica
las ocasiones de error, y hay una instancia medida del mismo día: **el desfase UTC↔local propagado a 45
sitios**, que una comprobación de tres líneas en `tools/` habría cazado al instante.

**Candidato concreto, sin diseñar aquí:** un comprobador en `tools/` que contraste la fecha de las
entradas nuevas contra la fecha local del último commit, y la versión declarada en los cuatro sitios
(`plugin.json`, los dos campos de `marketplace.json`, `.arnes/config.json`). **No entra en 1.34.0** — se
registra para que `REQ-025` lo evalúe con el resto.

### Cómo se sabrá si sirven, porque sin eso es opinión

Tres señales, todas ya observables sin instrumentar nada nuevo: **encargos corregidos en vuelo** (hoy:
cuatro sobre `REQ-026`), **reaperturas** y **tokens por resultado entregado**. Si las reglas sirven, las
tres bajan; si no, se sabrá con la misma evidencia con la que se propusieron.
