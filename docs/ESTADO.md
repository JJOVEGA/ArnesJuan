# ESTADO — ArnesJuan

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparece un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.

## Fase actual
Fase 0 — autoalojamiento. **v1.33.0 PUBLICADA** el 2026-09-08 (merge `810128a`, tag y Release creados;
instalación estable actualizada y verificada: 880 PASS · 0 FAIL en el banco completo). Ventana **1.34.0
abierta**, gobernada por **1.33.0**. PR #43 y #44 fusionados y cerrados.

**Cómo se publicó, porque es parte del estado y no una anécdota:** la fusión se hizo con la cuenta
`jvega-habitat`, que **no tiene admin**, teniendo la de propietario autorizada y disponible. Fusionar sin
privilegios demuestra **por construcción** que la puerta requerida se satisfizo y no se saltó nada.
**Límite declarado:** la evidencia de rendimiento de 1.33.0 es el `0,125×` acreditado de `REQ-017 CA-05`,
**no** el verde de `CA-08 (ii)` — ese caso mide **0,973×–1,364× sobre código idéntico** contra un techo de
1,25×, así que hoy no acredita nada en ninguna dirección.

**Alcance de 1.34.0.** Su **primer trabajo es la sonda de `REQ-017 CA-08`** (enmienda del propietario del
2026-09-08), **por delante de `REQ-019`**: mientras el techo viva dentro del ruido, ese caso decide cada
publicación sin poder distinguir. Detrás van `REQ-019`, `REQ-020`, `REQ-023`, `REQ-024` y `REQ-025`.
*(Recomendación de la coordinadora, pendiente de decisión: 1.34.0 son **tres** trabajos —la sonda,
adelgazar el arranque y archivar las bitácoras—, no diez. Diez es el patrón que descontroló 1.33.0.)*

**Esta ventana se movió cuatro veces en dos días, y conviene tenerlo escrito.** Nació el 2026-09-07 con
`REQ-017 + REQ-019 + REQ-021`; el 2026-09-08 entró **REQ-023** —el carácter invisible— y salió
**REQ-019** al pasar su estimación de ~2 h a **7–11 h en cuatro fases**; y ese mismo día **salió también
REQ-023**, cuando su coste se midió *después* de meterlo: cuatro comisiones en serie tras REQ-021, sin
paralelismo, con dos precondiciones ajenas. Es exactamente el mecanismo con que `docs/PLAN.md` explica
el descontrol del ciclo 3.

> **Aplazar REQ-023 no incumple ningún vencimiento**, y esto hubo que comprobarlo porque el REQ decía lo
> contrario: el vencimiento de `SEC-047` es el cierre de **1.34.0** (`registro-seguridad.md:3684`), así
> que meterlo en 1.33.0 había sido un **adelanto**. La cláusula que afirmaba lo contrario —«sube a
> `contrato` si 1.33.0 cierra sin él», atribuida al auditor— **no existía**: es `SEC-052`, y el auditor
> la trazó a un solo commit, el del propio REQ-023.

> **Y lo que esta ventana NO entrega: la reducción de tokens.** REQ-017 abarató el **reloj** del banco
> (95,66 s → 45,14 s), y esperar al banco es gratis en tokens. REQ-021 ahorra ~150 k por ventana **cuando
> exista**. La palanca de tokens es **REQ-019**, y está en 1.34.0.

## PUNTO DE CONTINUIDAD — 2026-09-08, ventana 1.34.0

> **Léelo antes de actuar, junto con las reglas vigentes.** Y **comprueba el estado de los agentes de
> abajo antes de despachar ninguno**: varios siguen reanudables y despachar de nuevo duplica trabajo.
> Rama `rel/registro-1.33.0` @ `0019598`, empujada, sin commits pendientes.

### Alcance aprobado de 1.34.0 (propietario, 2026-09-08) — CUATRO trabajos

Fijado en `docs/PLAN.md` §«ALCANCE DE 1.34.0». **No se ha ampliado**: `REQ-027` se escribió dentro de la
ventana por petición expresa, y **su implementación no tiene ventana decidida**.

1. **La sonda de `REQ-017 CA-08`** — primero, por enmienda del propietario.
2. **`REQ-019`** — adelgazar los dos documentos de arranque.
3. **La rotación de historiales (`REQ-026`)**.
4. **`REQ-023` + `REQ-024`** — remediación de `SEC-047`, cuyo **vencimiento es el cierre de 1.34.0**
   (`docs/seguridad/registro-seguridad.md:3684`, escrito por el auditor **en su sede**). Cerrar sin ellos
   sube `SEC-047` y `SEC-051` a `contrato`.

### Estado por REQ — implementado / contratado / pendiente de verificar

| REQ | Estado | Qué hay hecho de verdad |
|---|---|---|
| **REQ-017** | `en-progreso` | **CONTRATADO** (`CA-08 (ii)` reescrito: cota sobre la razón). **Código EN CURSO.** `QA:`/`Seguridad:` de la cabecera son de **1.33.0** y **no cubren** este trabajo |
| **REQ-026** | `pendiente` | **CONTRATADO** (17 criterios). Nada implementado |
| **REQ-027** | `pendiente` | **CONTRATADO** (10 criterios). Nada implementado. **Crear el REQ no instala las reglas** |
| **REQ-019** | `pendiente` | Contrato **corregido** (techo `0,72×`, línea base 521, `D-2/3/5/9`). `SEC-033` (`contrato`) **abierto**. Sin implementar |
| **REQ-023 / REQ-024** | `borrador` | Sin contrato cerrado. Son la remediación de `SEC-047` |
| **REQ-021** | `bloqueado` | 3 vueltas agotadas. **No se retoma sin decisión del propietario** |
| **REQ-025** | `borrador` | Fuera de esta ventana. `REQ-027` lo enlaza como **continuación**, sin condicionar su cierre |

### Agentes — comprobar antes de despachar

| Id | Rol / trabajo | Estado |
|---|---|---|
| `a3f8b1dcaceab4f10` | `desarrollador` · sonda de `REQ-017` | **ACTIVO**, >1 h. Tiene `run.sh` y `37-coste-del-escaner-5-el-camino-normal.sh` modificados sin comitear |
| `a22f39d25dbc01323` | `analista` · `REQ-027` | Terminado, **reanudable** |
| `afc7860e40e10399b` | `analista` · `REQ-026` | Terminado, reanudable |
| `a515fa2cde6a9d5d4` | `analista` · `REQ-019` | Terminado, reanudable |
| `a98ae536310d73d8a` | `analista` · `REQ-017` | Terminado, reanudable |

### Métricas de `REQ-017` — PENDIENTES DE VERIFICAR, no confirmadas por la coordinadora

El propietario mencionó del desarrollador: **~5,1 s**, un **4 s + 6 s**, **~55 s para `k=4`** y una
**emulación de 2 CPU**. **La coordinadora NO las ha visto ni verificado**, y **no encajan entre sí** bajo
una misma definición de «repetición» (4+6 = 10, no 5,1). Se le pidieron por escrito: qué es exactamente
una repetición, la **aritmética** de los ~55 s, y separar **emulación** de **validación en el CI real**.
Más tanda terminada, **repeticiones válidas** y tiempo acumulado. **Nada de esto se da por bueno hasta
que llegue su informe.**

### Condiciones de parada vigentes

- **`REQ-017`**: si el `k` necesario **no cabe bajo el techo de coste**, el desarrollador **para y lo
  dice**. La salida —sacar `CA-08 (ii)` de la puerta requerida y dejarlo como acreditación fechada, la
  vía que `CA-05` ya usa— **es decisión del propietario**, no de la coordinadora ni del agente.
- **`REQ-017`** (vigilancia): si **repeticiones válidas** se estancan o el tiempo acumulado crece sin
  acercarse a un `k` conforme, se aplica la parada. **No editar archivos no es señal de bloqueo, y crear
  y limpiar temporales no es señal de progreso.**
- **Tope de vueltas** dev↔QA: **3 por REQ**, sin reiniciarse.
- **Publicación**: con `contrato` abiertos en el repositorio, **el tag vuelve al propietario**.

### Decisiones pendientes del propietario

1. **Ventana de implementación de `REQ-027`** — no decidida. Compite con `REQ-019` por `AGENTS.md`.
2. **`REQ-021`** sigue `bloqueado` sin salida decidida.

### Siguiente acción

Esperar al `desarrollador` de la vuelta 1 (`QA-017-16`). Después **QA otra vez**, y sólo entonces el
`auditor-seguridad` (§6, no se relaja). El auditor **no puede firmar** mientras `QA:` diga
`con-hallazgos`.

### ACTUALIZACIÓN — 2026-09-08, noche (sesión autónoma)

**Desarrollador entregó `19b1822`; QA lo validó y lo devolvió.**

- `REQ-017`: `Estado: en-revisión`, `QA: con-hallazgos (2026-09-08)`. **Siete hallazgos nuevos**,
  `QA-017-16` a `QA-017-22`, en `docs/qa/1.34.0.md` (creado).
- **`QA-017-16` es clase `contrato` y bloquea el cierre.** `razon08_47` retorna en la comprobación
  de convergencia (`37/5:276`) y la razón se calcula **después** (`:278`), así que el SKIP por
  no-convergencia **no puede citar la tercera cifra** que `REQ-017.md:80` contrata. Ningún caso del
  banco lo habría visto: la autoprueba reduce cada salida a la palabra del veredicto y **descarta el
  mensaje**. Los otros seis son `instrumento` y no entran en esta ventana.
- **Verificado de forma independiente por la coordinadora y reproducido por QA:** banco
  `881 PASS · 0 FAIL · 5 SKIP`, `rc=0`, total 886. El desarrollador había informado `882/4`: el caso
  `REQ-017 CA-09` alterna PASS/SKIP según el ruido, así que **su cifra no es reproducible**. No es
  defecto.
- **`0,750×` es un techo y muerde**: QA calculó que `k = 5` daría 0,759×–0,821×, por encima. No es un
  número puesto para que cupiera el `0,569×`.

**LECTURA DE LA COORDINADORA sobre el tope de vueltas — no es una decisión del propietario y se puede
revertir.** `REQ-017.md:455` dice que la vuelta 2 fue «la última que permite `AGENTS.md`». Esas vueltas
0/1/2 pertenecen al ciclo de **1.33.0**, que **cerró** (`completado`, QA y seguridad aprobados,
publicado). El REQ se reabrió por **§9** porque cambió el criterio, no porque QA hallara un defecto. Si
el contador sobreviviera a una reapertura de §9, la REGLA DE ESTADO —«re-recorre el ciclo»— sería
**inoperante** para todo REQ que hubiera gastado su tope: nacería bloqueado. Por eso se cuenta la
corrección de `QA-017-16` como **vuelta 1 de 3 del ciclo nuevo**, y quedan 2. **`AGENTS.md` §6 no
resuelve el caso por escrito**: si el propietario lee el tope como acumulativo entre ventanas, la
salida correcta era `Estado: bloqueado` con entrada en `PENDING_APPROVAL.md`, y revertir cuesta una
comisión.

**Deuda medida que NO se toca, con su motivo:** `QA-017-22` dice que el `Archivos:` de `REQ-017` nombra
dos secciones que **no existen** (`-1-escala.sh`, `-2-la-seccion-caliente.sh`; son `-1-el-dominio.sh` y
`-2-las-razones.sh`). **`REQ-021` declara los mismos dos nombres fantasma**, de modo que hoy los dos
defectos se tapan mutuamente y corregir **sólo uno** puede producir un `disjunto` **en falso** entre
ellos. Se corrigen juntos o no se corrigen.

**Sin medir, dicho expresamente:** si `k = 4` basta en el CI real **no está medido** — todo lo anterior
es local, y sólo lo dirán las corridas siguientes de `hooks-en-linux`. La derivación de `k` (56
repeticiones) **no se reprodujo**: QA auditó el razonamiento, no las cifras. El techo de coste
`+28,0 s = 0,569×` está **acreditado por el desarrollador y no verificado por QA**.

### Deuda anotada y NO resuelta

`REQ-019` y `REQ-026` conservan **20 fechas** un día por delante (12 y 8) — se corrigen en la próxima
comisión que toque cada archivo. Falta la entrada de «Migraciones conocidas» de `arnes-upgrade`
(contratada en `REQ-027 CA-10` como **condición de entrega**). El techo de **2.600 B** de `REQ-027 CA-05`
es un **límite propuesto sin validar**. **El consumo de la coordinadora sigue sin instrumentar**: lo
único medido son **≈1,10 M tokens en 11 comisiones** de subagente.

## En progreso
**REQ-021 — `pendiente`, `QA: con-hallazgos`. VUELTA 3 DE 3, con el desarrollador trabajando. Es la
última.**

> **Y ya no hay salida de residual.** El write-back del 2026-09-08 declaró `QA-021-10` en
> `Hallazgos abiertos:` como **`contrato`**, así que `guard-completado` **deniega** el cierre mientras
> siga abierto. Después de esta vuelta hay exactamente dos finales: la vuelta trae código **y**
> acreditación ejercida por quien no escribió la sonda → cierra; o el REQ pasa a `bloqueado` y se escala
> al propietario. Un residual sólo sería viable si QA o el auditor **reclasifican** el hallazgo, y eso no
> es de la coordinadora.
>
> **El delta está medido y es más barato que la vuelta 2:** cinco archivos, ~115 líneas, y la sonda de
> procesos **pierde** código (fuera `sp_cal_disc`, `SP_DISC_VECES`, `--rastro`, el campo `disc_veces=`).
> La anterioridad del testigo **cuesta cero procesos**: es un cambio de orden. Y el fail-before sale
> gratis, porque las dos sondas de hoy **abortan con sólo mover el orden**.
>
> **La propiedad nueva de `(a.3)` tiene cinco condiciones**, y la tercera es la que carga el peso:
> **el juez obtiene el testigo ANTES de invocar la sonda** — *lo que no existe antes de que el sujeto
> corra, pudo haberlo producido el sujeto*. Las otras cuatro: tamaño del sujeto en un rango que el
> parámetro no puede alcanzar por construcción; el **valor** lo produce el juez, nunca un artefacto que
> la sonda pueda escribir; el sujeto discordante lo fija el juez y la sonda no lo declara; y el umbral no
> se lee del registro del juzgado (hoy la sonda de reloj podía **comprarse su propia abstención**).
>
> **`(a.4)` nombra la lección estructural:** *quien escribe el instrumento diseña el control que sabe
> pasar* — con las tres instancias medidas del mismo día y su consecuencia de sedes: la **forma** del
> camino la fija el criterio (analista), el **valor** lo obtiene el juez, la **acreditación** la ejerce
> quien no escribió la sonda.
>
> **Límite declarado, para no repetir la afirmación de eficacia que QA desmintió:** `(a.3)` cierra que el
> testigo *salga* de la sonda; **no** cierra una sonda que **lea el sujeto que el juez le entrega** y
> publique su cuenta sin ejercerlo — eso es falsificación deliberada, no descuido, y su respuesta es la
> barandilla (§13) más la custodia y el tercero.

**Lo que la vuelta 1 de QA encontró y motivó todo esto:**

> **`QA-021-10` (`contrato`, alta) — la tautología sobrevivió a la reducción de alcance.** En
> `tests/util/sonda-procesos.sh` **el testigo lo escribe la propia sonda**, que es lo que `CA-03 (a.3)`
> prohíbe por nombre: el juez sólo crea el archivo vacío y cuenta, pero el **valor** lo pone la sonda.
> Con `disc_obs = cal_n−1` y el testigo saliendo de las mismas marcas, **`3 = 3` se cumple por
> construcción, haga la sonda algo o nada**. Es el `2N/N = 2000` de `QA-021-01` con otra aritmética:
> `N−1`. QA construyó una copia que **no invoca `grep` ni una vez** y calcula las cinco magnitudes por
> aritmética, y el juez real dijo **PASS**.
>
> **La clase de `QA-021-01` salió del árbol con la sonda retirada y sobrevive en el instrumento que se
> quedó.** La mutación del desarrollador era la **estrecha** —publicar el parámetro—, y ésa sí la caza.
>
> El arreglo: el testigo tiene que obtenerlo **el juez, por un camino que la sonda no pueda alimentar**.
> Write-back del analista primero (el REQ afirma dos cosas falsas sobre lo construido), luego código.

**Conteo de vueltas dev↔QA: 3 de 3, la última en curso, y el contador NO se reinicia.** La vuelta 1
cuenta aunque quedara interrumpida, porque **produjo un bloqueante que obliga a volver al
desarrollador** — que es lo que define una vuelta, no cuántos criterios se alcanzaron a validar.

**Lo que QA NO llegó a mirar, y está tabulado como NO MIRADO —nunca como PASA—:** la banda de `(d)` bajo
carga provocada, `(ii)` y `(d)` con `r=3`, la honestidad de `(i.1)`, `QA-021-04`/`05`, `DEV-021-08`, el
cuadre de `CA-07`, el banco desde un worktree, y el hueco (b). La reanudación empieza por ahí.

**Lo conseguido y medido en la vuelta 2** (árbol `87d2609`, máquina en reposo, una sola comisión viva,
oráculo `/proc/stat:processes` con builtins):

| | Vuelta 0 (QA) | Vuelta 2 |
|---|---|---|
| `CA-03 (d)` calibraciones fuera de banda | **5 de 30**, 2 en reposo | **0 de 30** en cuatro regímenes |
| `CA-08 (ii)` razón de reloj | no ejercida | **1,1734×** contra techo 1,25× |
| `CA-08 (i.2)` sonda de reloj | — | **−4** procesos, idéntico 6/6 |
| `CA-08 (i.2)` sonda de procesos | — | **−30/−31** procesos |
| `CA-07 (1)` inventario | — | **828 casos / 61.287 B idénticos byte a byte** |
| Banco | 870/0/3 | **876 PASS · 0 FAIL · 4 SKIP**, cuadre 880 |

**Alcance reducido por decisión del propietario:** `sonda-linea-base.sh` **sale**; sólo se mudan la de
reloj y la de procesos. Era la causa de los tres problemas más duros a la vez —la calibración
tautológica, los 21 procesos que hicieron insatisfacible `CA-08 (i)` y el `+6` con los internos de
`git`—, y es la cláusula que el propio contrato tenía **pre-decidida**.

**Tres cosas de método que valen más que las cifras:**

1. **El desarrollador se desmintió a sí mismo.** Declaró `r` 3→5 como la palanca contra la fragilidad y
   la medición lo negó: con `r=3` la tasa es la misma **0/30**. Lo que la arregló fue el **tamaño
   derivado del suelo** (1,4× → 4×) y el **intercalado del par**, que además tapaba una falta de
   **identidad de camino**. Devolvió `r` a 3 y corrigió el `README` donde él mismo había escrito lo
   contrario. Y resultó decisivo: `(ii)` **no cabía** con `r=5`.
2. **`(i.1)` queda NO CONCLUYENTE, con rango y sin afirmar el signo.** El oráculo observa **31–78 forks
   ajenos** en ventanas de 25 s —amplitud 47— y el delta es **+4 a +22**. Y la nota que vale por sí sola:
   la amplitud **pareada** (18) es menor que la del suelo suelto (47), lo que indica que el pareado
   cancela deriva ambiental, **pero atenuar no es medir**.
3. **La calibración es todo el exceso de `(ii)`.** Sin ella la corrida sale **≈0,98–1,00×**: la mudanza
   en sí es neutra en reloj, y lo que cuesta es capacidad **que ninguna línea base tiene**.

## PAUSADA 2026-09-08 ~14:35 CST — presupuesto de tokens del usuario, no de decisión

**Árbol limpio en `9809fc2`, empujado.** Nada en vuelo, ningún agente vivo, `PENDING_APPROVAL.md` en 0.

**Lo próximo, en orden:**
1. **Analista** — Historial de `REQ-014` documentando la comisión del desarrollador (máquina de `CA-18` +
   oráculo de `CA-12`): corregir el desfase de piso (461/468, no 460/467; `k` sigue conforme) y anotar
   que `38-sondas-compartidas.sh` necesita **tres** archivos, no dos.
2. **Auditor** — retomar la evaluación de si `REQ-014` admite rigor menor que `critico`. Quedó
   **interrumpida sin veredicto** (parada por presupuesto, no por decisión): había encontrado «dos
   hallazgos concretos» y estaba verificando «la aritmética del techo autodeclarado y la numeración del
   registro» cuando se detuvo. Empezar de cero, no asumir ningún resultado previo.
3. **Desarrollador** — partir los tres archivos (autorización ya extendida a la 38).
4. **QA** de `REQ-014` completo.
5. **Auditor** de `REQ-014` (si el veredicto del punto 2 dice que aplica el ciclo completo).
6. Los dos ADR pendientes (re-derivación de `CA-18`; mandato de `ADR-005`).
7. Versión, PR, CI en verde, tag, instalación estable.

**El tag es del propietario, no por delegación** (R-016, R-017): 30 `contrato` abiertos, dos
discrepancias entre sedes, tres hallazgos apuntando a la publicación misma (`SEC-050`, `SEC-054`,
`SEC-055`). Nada de esto lo resuelve el trabajo pendiente arriba.

**Y la protección ya escrita para la próxima ventana:** `docs/PLAN.md` §1.34.0 — `REQ-019` es el
primer trabajo y **el único** hasta que cierre, sin excepción salvo lo que bloquee la publicación
misma. Lleva **dos** salidas de ventana y cero líneas de código tocadas.

## Próximo paso concreto
1. **REQ-021 vuelta 3 de 3: desarrollador** *(corriendo)* → **QA vuelta 3** → auditor → cerrar REQ-021.
2. **Partir las tres secciones que pasan de 400 líneas** (`848 / 678 / 722`). `CA-18` es el **único FAIL
   de la autoprueba** y **bloquea la fusión**, porque `hooks-en-linux` es la puerta requerida. Lleva roja
   desde el delta final de REQ-017 y el CI nunca lo había medido: el verde del PR era sobre un árbol de
   **346 y 266** líneas. Autorizado con **desarrollador + QA** por firma expresa del propietario
   (`PENDING_APPROVAL.md`, resuelta del 2026-09-08); va **después** de cerrar REQ-021, porque `CA-07.2`
   congela los `CASOS_ESPERADOS_SECCION` de las 37.
3. Versión, PR, CI, **tag `v1.33.0`** e instalación estable — con el gate de abajo.

*(REQ-023 ya no está en esta lista: salió de la ventana el 2026-09-08.)*

## Bloqueos
- **La fusión está bloqueada por `CA-18`** (punto 2 de arriba). No es un bloqueo de decisión: está
  autorizado y sólo falta hacerlo. Verificado en CI el 2026-09-08 a las 17:59: es el **único** rojo del
  árbol — `Autoprueba: 72 PASS, 1 FAIL`, y el FAIL nombra los tres archivos (`848 / 678 / 722`).
- **El tag vuelve al propietario, y NO por REQ-021.** `docs/gobernanza/autoalojamiento.md:148-155`:
  «**Cualquier** … hallazgo abierto de clase `usuario/dinero` o `contrato` … devuelve la decisión al
  propietario». **Corregido tras R-015:** los `contrato` abiertos ajenos a esta ventana son `SEC-050`
  (de REQ-016) y **`SEC-053`**; `SEC-052` pasó a **`mitigado`**; y **`SEC-054` SÍ es de esta ventana** y
  trata precisamente de lo que este tag publicaría. Ninguno bloquea una puerta de máquina —bloquean el
  REQ que los declara— pero por gobernanza la coordinadora **no fusiona ni etiqueta por delegación**:
  presenta la evidencia y para.
- **`SEC-053` (`contrato`, dueño PROPIETARIO) — el permiso para publicar no tiene frontera escrita, y hay
  una publicación pasada que lo prueba.** Medido en R-015: **`v1.32.1` se publicó por delegación con un
  `contrato` abierto** —`git show v1.32.1:…registro-seguridad.md` trae `SEC-020 · contrato · abierto`, y
  la entrada que anuncia la publicación **lo nombra**—, sin entrada en la cola. Son **tres** lecturas
  posibles y la única que hace conformes las publicaciones pasadas **no aparece en ningún documento**. La
  prueba de que no se puede aplicar como está la dio el auditor sobre sí mismo: *«no sé decir si mi
  propio hallazgo cuenta»*. Y la forma: **sin frontera escrita, la lectura se elige en el momento de
  publicar la parte que se quiere publicar, y siempre hay una que concede el permiso.**
- **`SEC-054` (`contrato`, alta) — 1.33.0 publicaría tres textos firmados que la medición desmiente:**
  `ADR-005:42` («cada corrida acredita que el instrumento responde al sujeto», con `Estado: aceptada`),
  `tests/util/README.md:50`, y la sección 38 publicando **PASS** sobre eso **en la puerta requerida**. El
  plugin se distribuye con `source: "./"`, así que **el ADR y el README llegan a los consumidores**.
  Remediación **barata y sin revertir código**: nota fechada en ADR-005 declarando su punto 4 no
  acreditado (**gate humano**: los ADR no se reescriben) más una línea en el README. Mitad buena, medida
  por objeto de árbol: **`hooks/` en HEAD es el mismo objeto (`88c1465…`) que firmó R-012** y no hay
  diferencia en `hooks/ tools/ .github/ .arnes/`, así que **no hay regresión de enforcement**.
- Ninguno de presupuesto.

## Pendientes (cola)
- [ ] **Enrutar el hueco (b), medido dos veces:** `37/1` y `37/2` **no llaman a `sonda_usable` ni una
      vez**, así que publican razones con la procedencia de la calibración **desmentida en la misma
      corrida** — con la sonda mutada la sección 38 sale roja y ellas dan PASS. Es superficie de REQ-017 y
      convertir sus PASS en FAIL no cabe sin decisión del propietario.
- [ ] **`REQ-017 CA-03` es flaky y REQ-017 está `completado`:** `1 de 8` corridas no alcanza a demostrar
      su fail-before (la de la máquina cargada). §9 dice que un REQ `completado` que cambia re-recorre el
      ciclo; hay que decidir si esto es hallazgo o reapertura.
- [ ] **Dos preguntas de REQ-025 para el propietario, aplazadas a propósito hasta cerrar 1.33.0:** si
      `CA-08` entra en CI, y si `requirements/` entra en `codigo_app.globs` —hoy **no está**, así que la
      sesión coordinadora **puede escribir `QA: aprobado`** y ninguna puerta lo impide.
- [x] **`SEC-050` y `SEC-051`** (R-013) — **enrutados el 2026-09-08, los dos a 1.34.0.** `SEC-050` va al
      write-back de **REQ-023** (`CA-02`/`CA-03`) más la reparación del puntero de REQ-016 en
      **REQ-024**. `SEC-051` va **entero a REQ-024** (`CA-08`/`CA-09`), y **no** a REQ-023, por un motivo
      que salió de leer el código y que ningún documento decía: `hooks/lib.sh:1577-1583` declara **por
      escrito** la frontera con `arnes_cola_pendientes` y deja escrito el precio de cruzarla — unificar
      la noción de cita cambia el **conteo** de la cola, que es un cambio de **veredicto** de la puerta,
      que es un cambio del contrato de **REQ-009** (`completado`) **sin ADR**. Corrección a la
      estimación que estaba aquí escrita: **no era «un arreglo de dos líneas»** — la remediación de
      R-013 pide una transcripción compartida, conducta nueva cuadrada en **tres** lectores y casos
      fail-before/pass-after en un archivo que REQ-023 **no** declara en `Archivos:`.
- [ ] **`SEC-052`** (R-014, `contrato`, dueño `analista-requerimientos`) — write-back **hecho** el
      2026-09-08 y declarado en `Hallazgos abiertos:` de REQ-023; **falta que el auditor lo verifique y
      lo cierre**. Bloquea el `completado` de REQ-023 y de nada más.
- [ ] **El `_doc` del manifiesto es documentación que ninguna migración toca** (reportado por un
      proyecto consumidor). `arnes-upgrade` clasifica **secciones de Markdown** y un valor JSON no es una
      sección, así que los diez `_doc` de la plantilla derivan para siempre. Análisis en
      `docs/PENDIENTES.md`.
- [ ] Decisión editorial del propietario: nombres de proyectos consumidores en el árbol público y las dos
      cuentas de GitHub nombradas en `AGENTS.md` (`SEC-008`, informativo; la salida propuesta es
      sustituir nombres por roles).
- [ ] **1.35.0 — working set explícito**: análisis y reglas de diseño en `docs/PENDIENTES.md`. El
      adelgazamiento de los documentos de arranque ya salió de aquí: es REQ-019, en 1.34.0.
- [ ] Windows/MSYS: el coste allí no está medido, y es donde un `fork` cuesta entre 1,2 y 6 s.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-08 23:24

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `rel/registro-1.33.0` @ `c59fd83` — limpio
**Arnés:** plugin instalado `1.33.0`
**Aprobaciones pendientes:** 1
**REQ:** 27 — completado 13 · en-revisión 1 · en-progreso 1 · bloqueado 2 · otros 10
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 13 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-007 | en-progreso | pendiente | pendiente | critico | qa-114(contrato,dueñoanalista-requerimie… |
| REQ-008 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-011 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-013 | en-revision | con-hallazgos | con-hallazgos | critico | sec-014(contrato),sec-020(contrato),qa-2… |
| REQ-018 | borrador | pendiente | pendiente | critico | (ninguno) |
| REQ-019 | bloqueado | pendiente | preventiva | critico | sec-033(contrato) |
| REQ-020 | pendiente | pendiente | preventiva | critico | sec-038(contrato),sec-039(contrato),sec-… |
| REQ-021 | bloqueado | con-hallazgos | preventiva | critico | dev-021-05(instrumento,dueñoanalista-req… |
| REQ-022 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-023 | borrador | pendiente | pendiente | critico | sec-052(contrato) |
| REQ-024 | borrador | pendiente | pendiente | critico | (ninguno) |
| REQ-025 | borrador | pendiente | pendiente | critico | (ninguno) |
| REQ-026 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-027 | pendiente | pendiente | pendiente | critico | (ninguno) |

<!-- ARNES:DERIVADO fin -->
