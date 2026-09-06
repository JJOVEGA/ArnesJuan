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
