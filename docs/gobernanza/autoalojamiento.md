# Autoalojamiento controlado — el arnés se desarrolla a sí mismo

> **Estado: ACTIVO desde 2026-09-05.** Este repositorio usa el arnés para modificar el arnés.
> El principio que lo hace posible, y que no se negocia:
>
> **La versión estable N gobierna el desarrollo de N+1. La versión que está siendo modificada
> nunca puede convertirse en su propio guardián durante esa misma ejecución.**

## Por qué hace falta un principio y no sólo cuidado

Un hook que se edita mientras gobierna la sesión que lo edita tiene dos formas de fallar en
abierto: la edición lo rompe y desde ese instante nada deniega; o la edición lo relaja "un
momento" para que pase un cambio, y ese momento se publica. Las dos son silenciosas, y este
arnés existe para impedir exactamente esa familia. Por eso el guardián y el candidato son
**dos copias distintas en dos rutas distintas**, y sólo una de ellas se edita.

## Las dos copias

| | Qué es | Dónde vive | Quién la cambia |
|---|---|---|---|
| **Estable (N)** | La versión publicada e instalada del plugin; corre los hooks de la sesión | `~/.claude/plugins/cache/arnes-juan/arnes-juan/<N>/` (la ruta que registra `installed_plugins.json`) | Sólo el instalador del plugin, y sólo **después** de publicar y verificar N+1 |
| **Candidata (N+1)** | El worktree de este repositorio, en una rama aparte | `<worktree>/` en la rama `cand/<N+1>-<tema>` | El `desarrollador`, gobernado por N |

**Antes de editar nada, se verifica y se muestra** — no se asume:
1. versión y commit exactos de la instalación que ejecuta los hooks (`installed_plugins.json`:
   `version`, `gitCommitSha`, `installPath`);
2. que sus archivos son **byte a byte** los del tag `v<N>` del repositorio;
3. que esa ruta **no es** el worktree que se va a modificar;
4. la rama de trabajo de la candidata.

Si los hooks activos apuntan al mismo árbol que se va a modificar, **se para**. No se continúa
hasta separar guardián y candidato.

## El manifiesto del arnés sobre sí mismo

`.arnes/config.json` de este repositorio declara `hooks/`, `tools/` y `.github/` como
`codigo_app.globs`: **sólo el agente `desarrollador` los edita**, y la sesión coordinadora que
lo intente recibe la denegación de N, con el motivo.

Desde 1.31.0 esa frontera **se incluye a sí misma**: `.arnes/config.json` y `.claude-plugin/*` están
dentro de los globs, porque quien no puede escribir `hooks/` no debe poder cambiar la regla que dice
qué es `hooks/` (hallazgo de la auditoría del ciclo 1). Queda fuera el resto de `.arnes/` —
`migracion.md` y `plantillas-origen/`—, que los escribe la migración desde la sesión coordinadora y
no declaran ninguna invariante. **Consecuencia práctica y aceptada:** `arnes_version` vive en el
manifiesto, así que la Fase 5 de `/arnes-upgrade` en este repositorio la ejecuta el `desarrollador`.
Ocurre una vez por versión y coincide con el commit en el que ya sube `plugin.json` y
`marketplace.json`. **Esto es mapeo de este repositorio y no se traslada a las plantillas:** un
proyecto que instale el arnés decide su propia frontera. Las quality gates del manifiesto son
rápidas (sintaxis y JSON) porque un hook `PreToolUse` muere a los 60 s y un hook muerto no
deniega; el banco completo es la puerta de `main` en CI (`hooks-en-linux`, requerido y estricto).

**Cuál es «la plataforma del desarrollador» de `AGENTS.md` §7, porque dejó de ser obvia.** Desde el
traslado del desarrollo a WSL/Linux (2026-09-05), el banco se corre **aquí**: tarda segundos en vez de
media hora, y esa diferencia no es comodidad — un banco de treinta minutos se corre una vez y se cree,
uno de diez segundos se corre veinte veces y se comprueba. La exigencia de §7 se cumple con las corridas
de esta plataforma, y **está cumplida de sobra**. Lo que **no** queda cubierto, y hay que decirlo cada
vez en lugar de darlo por hecho, es el **coste en Windows/MSYS**, donde un `fork` cuesta entre 1,2 y 6 s:
las cifras de proceso que declaran los REQ se miden aquí y se razonan allí. Un proyecto que corra el
arnés en Windows paga por cada proceso que añadamos, y por eso los criterios cuentan **procesos**, que
son comparables entre plataformas, y no milisegundos, que no lo son.

## El ciclo, con los roles reales del arnés

1. **Requerimiento.** Todo cambio del mecanismo nace como REQ en `requirements/` con
   `Rigor: critico`, `Sensible a seguridad: sí`, `QA: pendiente`, `Seguridad: pendiente`. Lo
   redacta el `analista-requerimientos`, con criterios de aceptación que nombran la evidencia:
   **el caso falla contra N y pasa contra N+1**, más sus controles positivos.
2. **Código y pruebas.** El `desarrollador` modifica `hooks/`, `tools/` y el banco, en la rama
   candidata. La coordinadora dirige y **no suplanta** al desarrollador para escribir código
   protegido; si lo intenta, N la deniega — y eso es lo que se quiere.
3. **Romperlo.** El `qa-tester` intenta romper la solución con casos **independientes** de los
   del desarrollador, y los deja en el banco.
4. **Bypasses.** El `auditor-seguridad` busca las formas de rodear la puerta que el cambio abre o
   deja abiertas, y las escribe en `docs/seguridad/`.
5. **Evidencia.** Cada bypass corregido tiene su par *fail-before / pass-after*: el mismo caso del
   banco, ejecutado con `ARNES_HOOKS_DIR` apuntando a la instalación estable (N) tiene que
   **fallar**, y contra el worktree candidato tiene que **pasar**. Sin ese par, el caso no prueba
   que el arreglo arregle.
6. **Banco completo en Linux** (CI del PR): `PASS`, `FAIL` y `SKIP` por separado; **ningún**
   `FAIL`; cada `SKIP` explica la plataforma o condición que lo salta; bits de ejecución de todo
   punto de entrada; y se comprueba que `hooks-en-linux` sigue siendo puerta estricta de `main`.
7. **Un humano aprueba la fusión.** El CI en verde es necesario, no suficiente. Se presenta la
   evidencia y se **espera**. No se fusiona, no se etiqueta, no se publica sin esa aprobación.
8. **Publicación y verificación de N+1.** Tras la fusión: tag `v<N+1>` sobre el commit de merge,
   verificación de que el tag declara esa versión, y **sólo entonces** se actualiza la
   instalación estable.
9. **N+1 gobierna N+2.** La versión recién instalada sólo empieza a gobernar el desarrollo de la
   siguiente, en una sesión nueva: los hooks se cargan al arrancar.

## Lo que está prohibido durante el ciclo

- Debilitar temporalmente los hooks, el manifiesto, las quality gates, el workflow o el
  ruleset para que el cambio pase. Si una puerta estorba, se corrige **en la candidata, con su
  REQ**, y pasa por el mismo ciclo.
- Editar la instalación estable. Si N tiene un defecto que bloquea el trabajo, el defecto se
  documenta y se corrige en N+1; mientras, se convive con él o se para.
- Cerrar el REQ del cambio antes de que N+1 esté publicada y verificada: el cierre es el último
  paso, no el primero.

## Dos advertencias medidas

- **`autoUpdate` del marketplace.** Si está en `true`, la instalación estable se actualiza sola
  al publicar; en esa máquina la nueva versión pasa a gobernar **la siguiente sesión** sin
  decisión explícita. Es aceptable si el paso 8 se cumplió; si se quiere control manual, se
  desactiva y la actualización se hace a mano tras verificar.
- **Los hooks se cargan al arrancar la sesión.** Un plugin actualizado a mitad de sesión no
  gobierna hasta reiniciarla. Por eso el paso 1 mide con una sonda —no lee la configuración—:
  una edición de la coordinadora sobre `hooks/` que N debe denegar, y un comando que distinga
  el comportamiento de N del de N-1.

## Política de rigor (dictada por el propietario, 2026-09-05)

Todo REQ de este repositorio pasa por **analista → desarrollador → QA → auditor de seguridad →
coordinador reúne la evidencia → Juan aprueba la fusión y la publicación**. Se declara por defecto
`Rigor: critico` y `Sensible a seguridad: sí`, con `QA: pendiente` y `Seguridad: pendiente`. Una
excepción editorial sólo baja ese nivel con autorización expresa del propietario; nunca por
reclasificación automática de un agente. **Esta política pertenece únicamente a ArnesJuan**: no se
traslada a las plantillas ni a los proyectos que instalan el arnés, que conservan su propio mapeo.

### Excepción medida: cuándo un REQ de este repositorio baja a `estandar` (delegado por el propietario, 2026-09-06)

El suelo sigue siendo `critico` **y no se declara al nacer**. Lo que se delega es **saltar el pase del
auditor al cierre**, y sólo cuando la máquina puede demostrar que no había nada que auditar:

| Condición, las tres a la vez | Cómo se comprueba |
|---|---|
| El campo `Archivos:` del REQ no declara ninguna ruta bajo `hooks/`, `tools/`, `tests/`, `.github/`, `.arnes/` ni `.claude-plugin/` | `tools/arnes-paralelo.sh`, que normaliza igual que las puertas |
| El diff del REQ sobre esas rutas es **vacío**, con `git diff` **y** `git status --short` | los dos, porque `git diff` es ciego a lo no rastreado — medido, H-08 |
| El banco corre **idéntico**: ninguna línea del inventario suprimida, modificada ni cambiada de veredicto | `tests/escenarios/hooks/inventario.sh` |

**Por qué al cierre y no al empezar.** Un REQ que *promete* no tocar la máquina no ha demostrado nada;
uno cuyo diff sale vacío, sí. Declarar `estandar` de entrada sería confiar en la intención, que es
exactamente lo que este arnés no hace. Así la excepción es **fail-closed**: si la prueba no se puede
producir, el rigor se queda donde estaba.

**Qué NO cambia.** `QA:` sigue siendo obligatorio —esta excepción sólo salta al auditor—; el suelo por
`Sensible a seguridad: sí` sigue vigente para todo lo demás; y **nada de esto se propaga a las
plantillas**: es política de autoalojamiento de este repositorio, no del arnés que heredan los
proyectos.

**Qué ahorra, medido y sin inflar.** Una comisión de auditoría por REQ que califique: ~15-20 min y unos
4 USD. En el ciclo 3 habría calificado **uno de tres** (REQ-012, cuya CA-11 exige precisamente ese diff
vacío). Es una palanca pequeña; las grandes son el tope de criterios por REQ y que un defecto de forma
deje de costar una vuelta.

## Enmienda: autoalojamiento aligerado (decisión expresa del propietario, 2026-09-10, aplicación INMEDIATA)

**Alcance: sólo cómo desarrollamos ArnesJuan.** No cambia las protecciones ni los valores por defecto
que reciben los proyectos nuevos o existentes. **Sustituye** la instrucción anterior de esperar a la
ventana siguiente, y se aplica también a las tareas pendientes del trabajo en curso.

**Objetivo declarado:** reducir análisis repetidos, comisiones innecesarias y revisiones demasiado
amplias, **manteniendo las protecciones del producto**.

### La vía se elige por el EFECTO del cambio, no por la extensión del archivo

| Naturaleza del cambio | Vía |
|---|---|
| Documentación informativa, índices y erratas **sin cambio de obligaciones** | **la coordinadora**, con las comprobaciones pertinentes |
| Reparación con **causa, alcance y contrato claros** | desarrollador → QA. **Sin comisión de analista** |
| Cambio que afecta **hooks, protecciones, firmas, permisos, instalación, migración o publicación** | desarrollador → QA → **seguridad**. El analista interviene **sólo** si hay una decisión de diseño o contrato **pendiente** |
| **Capacidad nueva** o **cambio de contrato** | analista → desarrollador → QA → seguridad |

Y la regla que impide que esta tabla se convierta en una salida: **clasificar por el efecto**. *«Una
regla de autorización en Markdown es gobernanza sensible; una prueba que decide si una protección
funciona tampoco es una simple edición documental.»*

**Lo que esta tabla NO cambia, y va escrito porque su ausencia sería la ambigüedad peligrosa:** el
**write-back** del §9 de `AGENTS.md` **sigue siendo obligatorio**. *«Un hallazgo resuelto solo en el
código o en un log es deriva»*, y sigue siéndolo. Lo que la enmienda cambia es **quién puede
transcribirlo** —el desarrollador, cuando no hay decisión de diseño ni de contrato pendiente—, no
**si** hay que hacerlo. Un hallazgo sigue sin cerrarse hasta que el requerimiento lo refleje, y QA y
seguridad siguen sin firmar `aprobado` antes de que exista.

La coordinadora **clasifica** aplicando estas reglas y **registra una justificación breve**. No se
abre una comisión sólo para clasificar. Se escala **únicamente** una ambigüedad concreta que pueda
**reducir una protección**.

### Revisión proporcional

Cada encargo indica, brevemente: **objetivo · archivos que puede modificar · evidencia disponible ·
condición de entrega**. Se revisa el cambio y sus dependencias relevantes; **no** se relee ni se
audita todo el historial por rutina, y la revisión se amplía **sólo** ante un riesgo o una dependencia
concreta. Durante el desarrollo, pruebas **enfocadas**. El **banco completo** va sobre el **candidato
final** y tras cambios que invaliden esa evidencia — **no** por una errata informativa. Los controles
obligatorios de integración y publicación **se mantienen todos**.

Se puede **reutilizar evidencia** cuando se demuestre que el cambio posterior no afecta lo
acreditado, y esa comprobación **se registra**. Y no se da por acreditado un árbol porque otro pasara.

### Alcance y vueltas

**Un defecto, una reparación.** Un hallazgo nuevo que implique un **fallo en abierto para
consumidores** se atiende con alcance explícito. Las mejoras de eficiencia, documentación e
instrumentos **se registran para otra ventana**, salvo que impidan validar el cambio en curso. No se
convierte cada observación en un REQ nuevo, y no se añaden mejoras a un parche porque estén cerca del
código que se toca.

**Presupuesto de dos vueltas ordinarias dev↔QA** para trabajo **nuevo**. Si no alcanzan, se presenta
**la causa y la reparación restante** antes de otra vuelta. El trabajo **en curso conserva su
contador y las extensiones ya autorizadas**. **Agotar vueltas nunca equivale a aprobar.**

### Los cinco límites, que son la mitad de esta enmienda

Para implementar este piloto **no** se modifican:

1. **Plantillas heredables** ni **agentes distribuidos**.
2. **Hooks** ni **controles mecánicos**.
3. El **comportamiento de instalación y actualización**.
4. El **rigor** ni la **sensibilidad** de un REQ **para evitar una puerta**.

Y el quinto, que es el que da carácter a los otros cuatro: **si un control mecánico impide una
simplificación, se conserva el control y se presenta la incompatibilidad concreta. No se desactiva.**

Esta enmienda **no** cierra ni reclasifica hallazgos, **no** cambia criterios de aceptación y **no**
amplía permisos de publicación.

### Cómo se comprobará si de verdad ahorra

Al cerrar la ventana en curso, y **con los registros que ya existen** —sin construir ninguna
herramienta nueva para medirlo—: tiempo, tokens si los hay, **comisiones evitadas**, **vueltas**, y
**defectos detectados después de aprobar**, distinguiendo **dato medido** de **estimación**.

---


### Presupuesto del bucle `analista`↔QA — **dos vueltas** (decisión expresa del propietario, 2026-09-11)

`AGENTS.md` §6 acota el bucle **`dev`↔QA** en tres vueltas por REQ. **No acotaba ningún otro**, y eso se
descubrió midiendo: al remediar `QA-024-19`, el `qa-tester` observó que había **dos bucles vivos y sólo
uno con tope** — el write-back del `analista-requerimientos` volvía a QA, QA encontraba un defecto nuevo
de `contrato` en el texto recién escrito, y el ciclo podía repetirse **sin que ninguna regla lo notara**.
Giró **tres** veces antes de que nadie lo nombrara.

**Presupuesto ordinario: dos vueltas** de `analista`↔QA por hallazgo remediado, en el autoalojamiento.

- **Agotado el presupuesto no se aprueba por agotamiento.** Se entrega una **lista consolidada** de las
  contradicciones restantes, su **efecto** y la **decisión concreta** que hace falta, y se para. Una
  vuelta más exige **autorización expresa del propietario**.
- **El contador se lleva por el trabajo, no por la etiqueta.** Una segunda entrega del analista sobre el
  **mismo** write-back es la vuelta 2, se llame como se llame. Y **no se mezcla** con el contador de
  `dev`↔QA: son dos cuentas distintas y las dos van declaradas en el campo del veredicto.
- **Vale para este repositorio.** **No se copia a las plantillas de proyectos consumidores**: llevar la
  proporcionalidad afuera es la iniciativa registrada en `docs/PENDIENTES.md` § «Propuesta — La política
  de trabajo proporcional, del arnés a los proyectos», **todavía sin implementar y sin versión**.

## Aprobación humana delegada (propietario, 2026-09-05) — con la frontera escrita el 2026-09-08

El propietario autorizó de forma **permanente** que, cuando **todo** esté en verde, la coordinadora
fusione, etiquete y publique sin volver a preguntar. «Todo en verde» significa, a la vez:
CI `hooks-en-linux` con **0 FAIL** y cada `SKIP` explicado; el par *fail-before / pass-after*
presente para cada bypass del REQ; `QA: aprobado` y `Seguridad: aprobado` (o hallazgos abiertos
sólo de clase `instrumento`, con dueño); plantillas de los consumidores sin cambios exclusivos del
autoalojamiento; instalación nueva y actualización verificadas. **Cualquier** `FAIL`, un `SKIP` sin
explicar, un hallazgo abierto de clase `usuario/dinero` o `contrato`, o un veto del auditor devuelve
la decisión al propietario: se presenta la evidencia y se para. La delegación cubre la fusión, el
tag y la publicación; la instalación estable se actualiza después (`autoUpdate`) y gobierna la
sesión siguiente.

### La frontera del recuento — lectura GLOBAL (decisión del propietario, 2026-09-08)

Hasta el 2026-09-08 el criterio decía «cualquier hallazgo abierto» y **no decía abierto dónde**. Ése
era el defecto, y no es de redacción: sin frontera escrita, la lectura la elige —en el momento de
publicar— la parte que quiere publicar, y **siempre hay una que concede el permiso** (`SEC-053`,
`docs/seguridad/registro-seguridad.md`). El propietario eligió la lectura **global** y rechazó las
otras dos —«por ventana» y «por los REQ que la ventana cierra»— por el motivo exacto que las hacía
cómodas: eran las que concedían el permiso justo para lo que se quería publicar.

**1. Qué se cuenta: por CLASE, no por origen.** Cuenta **todo** hallazgo cuya **clase** sea
`usuario/dinero` o `contrato`, **del proyecto entero**: cuelgue o no de un REQ, lo haya levantado
quien lo haya levantado, y sea cual sea el prefijo de su identificador — el prefijo **no dice nada
de la clase** *(ejemplos, no exhaustivo: `SEC-`, `QA-`, `DEV-`, `AN-`, `H-`)*. La definición de las
clases vive en `requirements/README.md:109`, §«Clases de hallazgo», y **sólo ahí**. `instrumento` es la
única clase que no cuenta.

**2. Qué cuenta como abierto: el complemento del cierre.** Cuenta como abierto **todo estado que no
sea `mitigado` ni `aceptado`**. Se enuncia por el complemento, y no listando los estados que abren,
porque **el conjunto que abre es el que crece**: el día que aparezca un estado nuevo contará como
abierto sin que nadie tenga que acordarse de añadirlo. Y un hallazgo cuyo estado **no se pueda
establecer** leyendo su sede cuenta como abierto, por la misma razón por la que una puerta que no
puede medir no deja pasar.

**3. Dónde se lee: dos sedes, por unión, y fail-closed en la discrepancia.**
- El **«Índice de hallazgos de clase bloqueante»** de `docs/seguridad/registro-seguridad.md` — sitio
  único de la lista **exhaustiva**, una fila por hallazgo, mantenido por el `auditor-seguridad`.
- El campo `Hallazgos abiertos:` de **cada** archivo de `requirements/`, en la forma cerrada
  `ID (clase)` que declara `requirements/README.md`.

El recuento es la **unión** de las dos. Si un identificador sale bloqueante en una y cerrado en la
otra, **cuenta como bloqueante** — y además **la discrepancia por sí sola devuelve la decisión al
propietario**: un recuento que no cuadra no es un recuento. No es hipotético: hoy hay **dos**
discrepancias declaradas —`SEC-052` y `SEC-014`, los dos `mitigado` en el registro y todavía
declarados en los campos de `REQ-023` y `REQ-013`—, y la de `SEC-014` llevaba **dos ventanas** sin
verse.

**Y no se cuenta «a ojo» sobre la prosa del registro.** Medido el 2026-09-08: sus entradas usan
encabezados de **dos** niveles distintos, unas declaran la clase en el encabezado y otras en una
línea `- **Clase:**`, y el estado cambia en entradas **posteriores** a la de apertura. Contarlas
leyendo exige interpretar, y un criterio que depende de interpretar prosa es el mismo defecto una
capa más arriba. El índice existe **para poder contar**; la prosa sigue siendo dónde vive la
evidencia.

**4. Sobre qué árbol.** Sobre **el commit que se va a etiquetar**, leído del propio árbol
(`git show <commit>:<archivo>`), nunca de la memoria de la sesión ni del estado de la rama de
trabajo. Es lo que permite que un tercero repita la medición dentro de un año con los mismos
comandos y obtenga el mismo número.

**5. Cómo se acredita: publicando el recuento, no afirmando el resultado.** La delegación **no** se
acredita diciendo que no había hallazgos bloqueantes. Se acredita **publicando el recuento** en la
entrada de `CHANGELOG.md` que anuncia el tag: el número, la lista de identificadores si no es cero,
y el commit sobre el que se leyeron las dos sedes. **Una publicación sin ese recuento publicado no
está acreditada, aunque el recuento hubiera sido cero.** El motivo es el que importa dentro de un
año: un veredicto sin cifras no se puede desmentir leyéndolo.

**6. Lo que esta frontera NO es: una puerta.** Ninguna máquina la mide. `guard-completado` lee el
campo `Hallazgos abiertos:` **del REQ que se cierra** y nada más
(`hooks/guard-completado.sh:484-527`), y hoy **ninguna** herramienta enumera el conjunto: medido,
`tools/arnes-lectura.sh` no reporta ese campo. Es una obligación de **escritura**; se cumple o se
incumple por escrito, y por escrito se audita.

### La consecuencia, hoy: la delegación no autoriza nada

Medido el 2026-09-08 sobre `cand/1.33.0` (`b199e08`) con la regla de arriba: **30 hallazgos de clase
`contrato` abiertos**, **0** de clase `usuario/dinero` — **31** contando `SEC-055`, que abre la propia
revisión que escribe esta frontera. De los 31, **19** están declarados en campos `Hallazgos abiertos:`
de REQ y **12** sólo en el registro; **5** esperan que el auditor verifique un write-back ya hecho y
**2** son las discrepancias declaradas. Descontando esos siete discutibles quedan **24**. El detalle,
hallazgo por hallazgo, está en el índice del registro de seguridad.

**Con esa cifra, la delegación está en pie como texto y no autoriza nada: en la práctica queda
retirada, y cada fusión, cada tag y cada publicación vuelven al propietario.** Queda dicho aquí, sin
suavizar y en el mismo sitio que la concede, porque un texto que promete una delegación
inejercitable **promete más de lo que se aplica** — que es exactamente la clase `contrato` que este
proyecto lleva ventanas persiguiendo en los documentos de otros.

**Qué la volvería a activar, en forma medible:** que el recuento del punto 3 dé **cero** en las dos
sedes, sin discrepancias, sobre el commit que se va a etiquetar, y que ese cero se **publique** con
el tag. No hay versión parcial de esta condición.

**Y la evaluación honesta de si eso va a ocurrir: no, no en este proyecto mientras desarrolle su
propio mecanismo.** No es pesimismo: es la forma de la cifra. Los 31 no son un atasco puntual, son
el régimen. Este repositorio produce en cada ventana texto firmado que afirma algo sobre la máquina,
y `contrato` es precisamente «un texto firmado describe un control con un alcance que no tiene»: las
auditorías la encuentran **por diseño**. Medido en la ventana 1.33.0: las revisiones de seguridad
abrieron **19** hallazgos `contrato` y se cerraron **6**; QA abrió otros dos. Se abren más rápido de
lo que los write-backs los cierran, y eso es el mecanismo funcionando, no una avería. **Una
delegación cuya condición de activación no se cumple nunca es mejor retirada que en pie:** en pie,
cada publicación obliga a explicar por qué no se ejerció; retirada, no hay nada que explicar.
**Retirarla del texto es decisión del propietario, y el auditor no la toma** — queda escrito aquí
para que sea una decisión y no un olvido. Mientras siga en pie, rige el párrafo de arriba: hoy no
autoriza nada.

### Quién escribió esta frontera, y por qué no la coordinadora

La escribió el **`auditor-seguridad`** —por decisión del propietario del 2026-09-08— y no la sesión
coordinadora, que es quien se beneficia de ella. El motivo no es de cortesía. Redactar la regla que
gobierna el propio permiso de publicar es la forma exacta de dos hallazgos que este proyecto ya
tiene nombrados: `SEC-052`, *una condición de escalada escrita por quien se libra de ella es un
argumento con la firma de otro*, y `SEC-053`, *sin frontera escrita la lectura la elige quien
publica*. Así que la escribe quien levantó el hallazgo, que es además el único que no puede usarla
para publicar nada. **La decisión de fondo —qué lectura rige— es del propietario; el auditor la
redacta y la mide, y no puede ni ampliarla ni ejercerla.**

### Publicaciones bajo este criterio — barrido completo de los 40 tags (2026-09-08)

Mismo método para todos, y se publica el **denominador** para que el veredicto se pueda desmentir
leyéndolo: `git show <tag>:docs/seguridad/registro-seguridad.md`, el campo `Hallazgos abiertos:` de
cada REQ **de ese tag**, y la entrada de `CHANGELOG.md` que anuncia la publicación.

| Tags examinados | Bajo este criterio | Conformes | De autoridad **no acreditada** |
|---|---|---|---|
| **40** (todos los publicados) | **4** — `v1.30.3`, `v1.31.0`, `v1.32.0`, `v1.32.1` | **2** | **2** — `v1.31.0` y `v1.32.1` |

- **Los 36 anteriores a `v1.30.3` quedan fuera, y no es un tecnicismo:** en ninguno existía este
  criterio —el bloque de delegación entra en el árbol **con** `v1.30.3`—, ni el registro de
  seguridad, ni un solo `requirements/REQ-*.md`; medido: 0 en los tres. No hay nada que acreditar
  contra una regla que no existía. Lo que **no** se afirma, para no prometer más de lo medido: quién
  decidió cada una de esas 36 publicaciones.
- **`v1.30.3` — conforme.** Cero hallazgos de clase bloqueante en las dos sedes de su propio árbol.
- **`v1.31.0` — de autoridad NO acreditada.** Tres `contrato` abiertos contra REQ-007 (`QA-114`,
  `QA-116`, `QA-117`), declarados en **las dos** sedes del propio tag, y ninguna constancia en el
  árbol de una decisión expresa del propietario: la entrada que la anuncia es «*[Interno] —
  2026-09-06 · cierre del ciclo 2 del autoalojamiento*», **agente: sesión coordinadora**, y
  `PENDING_APPROVAL.md` no registra ninguna entrada de publicación. **Lo encontró este barrido**; no
  estaba medido antes.
- **`v1.32.0` — conforme, y no por delegación.** Tenía `SEC-020` (`contrato`) abierto, pero la
  decisión fue **expresa del propietario**: la entrada resuelta de `PENDING_APPROVAL.md` dice «*El
  propietario eligió publicar 1.32.0 el 2026-09-07*». Conforme bajo cualquiera de las tres lecturas.
- **`v1.32.1` — de autoridad NO acreditada.** `SEC-020` seguía `contrato` · `abierto`, y la entrada
  que anuncia la publicación —«*[Cierre] — 2026-09-07 · Cierre documental de la ventana 1.32.1*»,
  **agente: coordinadora**— **lo nombra** entre lo que cruza a 1.33.0. Sin entrada en la cola.
- **Ratificación.** El propietario **ratifica a posteriori `v1.32.1`** el 2026-09-08. No se revierte
  ni se retira nada: lo que se corrige es que quedara sin acreditar. **`v1.31.0` queda anotada y su
  ratificación está pendiente** — es del propietario, y el auditor no ratifica en su nombre. Las dos
  quedan registradas como lo exige la cláusula de escalada del propio hallazgo, con cifras, blobs y
  citas, en `docs/seguridad/registro-seguridad.md`, revisión **R-016**.
- **`v1.33.0` NO está cubierto.** Con 31 `contrato` abiertos, la delegación no lo alcanza: su
  fusión, su tag y su publicación son decisión del propietario.

## Disciplina de coste (medida el 2026-09-06, obligatoria desde el ciclo 3)

El ciclo 2 costó **~4 M de tokens y ~253 USD** a precios de API. La medición dice dónde, y no era donde
parecía: **el 87 % del gasto es caché —60 % lecturas, 27 % escrituras— y sólo el 13 % es lo que los
modelos escriben.** No se paga por pensar: se paga por **releer**.

**La fórmula que gobierna todo lo demás: el coste de una comisión es `turnos × contexto`.** Medido sobre
3.384 turnos: 107 k de contexto medio por turno, mediana de pico 149 k, máximo 304 k. La comisión más
cara fue de **138 turnos y 12,48 USD**; la más barata que hizo trabajo real, de **8 turnos y 0,06 USD**.
Doscientas veces de diferencia, y la variable no es el modelo ni cuántos archivos hay en el repositorio.

Tres consecuencias que cambian cómo se despacha:

1. **El encargo declara un presupuesto de turnos y de tokens**, y el agente lo reporta al entregar.
   `AGENTS.md` §6 ya pedía anotar las comisiones por encima de 200 k y nadie lo cumplía, empezando por
   la coordinadora.
2. **Lo grande se lee tarde y en trozos.** Un documento de 38 k leído en el turno 5 de 138 se paga 133
   veces; el mismo leído al final, dos. Por eso importa que la **historia** de un REQ salga del archivo
   que el desarrollador y el QA leen, y que los **criterios** describan la regla en vez de enumerar la
   lista: en un REQ los criterios son el 54 % del peso y la historia sólo el 20 %.
3. **La elección de modelo casi no mueve la aguja.** Medido: la misma coordinadora cuesta 196,63 USD en
   Opus 5 y 208,48 USD en Fable 5.1, un 6 % más, porque el gasto es caché y ahí Fable lee a mitad de
   precio. Ahorrar bajando de modelo es la optimización equivocada; la que rinde es reducir contexto.

**Lo que NO se construye, y la razón:** el arnés no lleva un medidor de coste. Medir esto exige leer las
transcripciones de la herramienta anfitriona, cuyo formato no está documentado y puede cambiar; meterlo
en el plugin haría que todos los proyectos heredaran esa dependencia. El arnés trae el mecanismo, no el
mapeo, y aquí el mapeo es del anfitrión. **La coordinadora mide y reporta el coste de cada ventana**, con
el método escrito arriba, que es estable aunque el script se reescriba.

## Defectos del guardián descubiertos mientras gobierna (regla del propietario, 2026-09-06)

El guardián de la sesión es la versión estable instalada, y es la única copia que se ve **en uso
real**. Sus defectos aparecen aquí y en ningún otro sitio: un `deny` que no debía denegar, una
escritura que debía denegar y pasó, un mensaje que no dice cómo salir. **Se registran en el acto**, con
su clase, en `docs/PENDIENTES.md`. Eso no se discute.

Lo que sí se decide es **en qué ventana entra la reparación**, y el criterio es la clase del hallazgo,
no lo molesto que resulte:

| Qué se encontró | Dónde se repara |
|---|---|
| Deja pasar algo que debía parar, o para algo legítimo y **bloquea el trabajo del ciclo en curso** | **En la ventana abierta**, sin preguntar: un guardián que estorba el ciclo se arregla ya |
| Clase `usuario/dinero` o `contrato` | En la ventana abierta |
| Clase `instrumento` que no bloquea | **Ventana siguiente**, con dueño y criterio escritos |

**Por qué el reparto y no «se arregla todo ya».** Una ventana que admite cualquier hallazgo del
guardián deja de tener alcance, y un ciclo sin alcance no se cierra: el ciclo 2 terminó con siete REQ
porque cada hallazgo abrió el siguiente. La ventana 1.32.0 tiene tres REQ declarados y la reserva es
deliberada.

Dos ejemplos vivos, ambos defectos de **1.31.0, la versión que gobierna ahora mismo**, ambos
`instrumento`, y ambos aparcados en 1.33.0 por esta regla: la nota heredable de `guard-git` enumera un
envoltorio cuando el código tolera siete (SEC-013), y la skill de migración no dice en ninguna parte
que **hay que reiniciar la sesión** para que las puertas nuevas corran — un proyecto que actualiza cree
estar protegido por puertas que aún no se han cargado.

**Y la reparación no la escribe la coordinadora.** `hooks/` y `tools/` son del `desarrollador`, gobernado
por la versión anterior, con QA y auditoría después. Un arreglo urgente del guardián sigue siendo un
REQ; lo único que cambia es en qué ventana entra.

## Registro

| Ciclo | N (guardián) | N+1 (candidata) | REQ | Resultado |
|---|---|---|---|---|
| 1 | v1.30.2 (38b59fb) | rama `cand/1.30.3-autoalojamiento` → `main` 6c1b58a | REQ-001 | **publicado** 2026-09-05: tag `v1.30.3` sobre 6c1b58a (PR #31, `hooks-en-linux` 309/0/1). Tres vueltas dev↔QA; QA y seguridad aprobados; SEC-001..007 preexistentes → REQ-007. El REQ se cierra al verificar la instalación estable en 1.30.3 |
| 2 | v1.30.3 (6c1b58a) | rama `cand/1.31.0-mecanismos` → `main` 2fecae1 | REQ-002..006, 009, 010 (007 parcial) | **publicado** 2026-09-06: tag `v1.31.0` sobre 2fecae1 (PR #33, `hooks-en-linux` 682/0/1). Tres vueltas dev↔QA **más una extra autorizada por delegación tras un veto del auditor**, con su razón y su límite escritos en REQ-005. Siete REQ con las dos firmas; REQ-007 sigue `en-progreso` y cruza a 1.32.0 |
| 3 | v1.31.0 (2fecae1) | rama `cand/1.32.0-…` | REQ-007 (bloques B y C), REQ-011, y lo que docs/PENDIENTES.md asigna a 1.32.0 | pendiente de abrir (el guardián nuevo gobierna desde la sesión siguiente) |

### Lo que enseñó el ciclo 2, y no estaba previsto

- **El arnés destruía el archivo del usuario.** Con el manifiesto averiado, el hook de parada tenía
  cuatro caminos que mataban o borraban; dos reescribían `docs/ESTADO.md` **a partir de una lectura que
  había fallado**. Lo encontró la auditoría buscando otra cosa, y el QA lo **reprodujo** en la versión
  anterior antes de dar por bueno el arreglo. Regla que se queda: **lo que no se puede leer no se
  reescribe**, y lo que se verifica es el archivo entero por hash, no la parte que a uno le interesa.
- **Un veto se levanta arreglando, no declarando** — y antes de arreglar se mide el **radio**: comprobar
  que el detector de escrituras no estaba afectado convirtió un susto en un cambio acotado a una puerta.
- **La deriva tiene dos direcciones.** Un criterio que promete de más es deriva conocida; uno que promete
  **de menos**, porque el código acabó cubriendo más, lo es igual y nadie lo vigila. Se cierra el límite
  en silencio y el documento deja de describir la máquina.
- **El cierre de un REQ lo juzga el guardián de la sesión, no la versión que se acaba de publicar.** Al
  cerrar los REQ de 1.31.0 con 1.30.3 gobernando, la puerta rechazó el campo `Hallazgos abiertos:`
  escrito en la forma ancha que **1.31.0** aprendió a leer. No es un fallo: es el principio funcionando.
  La consecuencia práctica, que vale para cualquier proyecto: **el campo se escribe en la forma cerrada
  —`ID (clase)`— y la evidencia vive en el informe**, que es donde no la lee ninguna puerta.
