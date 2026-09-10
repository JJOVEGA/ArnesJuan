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

## ★ PUNTO DE CONTINUIDAD VIGENTE — 2026-09-09, antes de compactar

> **Éste es el bueno.** Todo lo que siga por debajo es **anterior** y, donde discrepe, **manda éste**.
> Rama `rel/registro-1.33.0` @ `67eabfb`, **todo empujado**. Cola de aprobaciones: **`ARNES_COLA=0`**,
> así que **la cola no bloquea ningún cierre**.

### ⏸ PARADA LIMPIA — 2026-09-09, cambio de red del propietario. **Manda sobre todo lo que sigue**

**El árbol quedó consistente y medido, no a medias.** Se detuvo a propósito la comisión del
`desarrollador` sobre la mitad de código de `QA-023-05`, antes de que una caída de sesión la cortara a
media escritura. Comprobado **después** de la parada: `bash -n` sobre las 57 secciones, `run.sh`,
`hooks/*.sh` y `tools/*.sh` **compila todo**; las **tres quality gates en verde**; **cero worktrees
huérfanos**; autoprueba **106 PASS · 0 FAIL**; banco **960 PASS · 0 FAIL · 6 SKIP**, con el total
cuadrando en **966**.

**Lo que el agente alcanzó a dejar hecho, y es lo que se le pidió:** el caso de `CA-09 (iii)` ya mide
la **forma contratada** por el write-back del analista —crece el segmento de **clave** desde una clave
que el lector reconoce, esqueleto `Sensible a @ seguridad: no`— y **abstiene con SKIP en vez de
pasar**, publicando las tomas y la dispersión. De ahí los **dos SKIP nuevos** (4 → 6): no son una
regresión, son la cláusula del margen funcionando por primera vez.

| sujeto | tomas | mediana | dispersión | margen al techo 2,2 | veredicto |
|---|---|---|---|---|---|
| `arnes_norm_clave` | 2,943 · 2,136 · 2,277 | **2,277** | 0,807 | 0,077 | **no se puede afirmar** |
| `arnes_campo_linea` | 2,563 · 2,318 · 2,211 | **2,318** | 0,352 | 0,118 | **no se puede afirmar** |

Las dos medianas están **por encima** del techo, pero la dispersión es mayor que el margen, así que el
criterio **prohíbe afirmar** y abstiene: ni pasa en falso ni suspende por ruido. Es la conducta correcta
y deja `(iii)` **sin acreditar**, que es lo que hay que resolver.

**La pista que dejó el agente en su última línea, y vale más que las cifras:** «*la candidata apenas
mueve el número, así que el coste puede no estar en la guarda*». Si `v1.33.0` heredada paga el mismo
cociente sobre la **misma forma**, entonces `CA-09 (iii)` **no mide lo que este REQ añade** y el
hallazgo es contra el **criterio**, no contra el código. **Medir la línea base heredada sobre la forma
«clave» es el siguiente paso concreto**, y era exactamente lo que el agente iba a hacer cuando se le
detuvo. Sin ese número, la decisión de §6 se tomaría a ciegas.

#### Retomar por aquí, en este orden

1. **`desarrollador`** — medir `v1.33.0` heredada sobre la forma «clave», mismo par y mismo `k`, misma
   tanda. Es una medición, no un arreglo. **No** subir el techo, **no** cambiar la forma, **no** tocar
   `hooks/` sin volver al humano (gate de §6).
2. Según salga: si la base paga lo mismo → hallazgo contra `CA-09 (iii)` y va al
   **`analista-requerimientos`**; si sólo la candidata lo paga → hallazgo contra el código y la
   decisión es del propietario, porque **no queda vuelta 4**.
3. **`qa-tester`** cierra la **vuelta 3 de 3** validando todo el árbol, incluido el fail-before.
4. **`auditor-seguridad`**, sólo después de QA.

#### Lo que la coordinadora dejó pendiente para sí misma

**El índice de `requirements/README.md` está desfasado en SIETE filas**, y no se corrigió a propósito:
el corpus del banco hace `cat requirements/*.md`, así que editarlo mientras un agente mide **mueve sus
cifras**. Se arregla con el banco parado. Las siete, con la cabecera real al lado:

| REQ | cabecera (verdad) | índice (falso) |
|---|---|---|
| `REQ-012` | `completado` · aprobado · aprobado | pendiente · pendiente · pendiente |
| `REQ-014` | `completado` | en-progreso |
| `REQ-017` | `completado` | en-progreso |
| `REQ-019` | `bloqueado` | pendiente |
| `REQ-023` | `en-progreso` · con-hallazgos | pendiente · pendiente |
| `REQ-026` | `en-revisión` · aprobado · con-hallazgos | pendiente · pendiente · pendiente |
| `REQ-027` | `completado` · aprobado · aprobado | pendiente · pendiente · pendiente |

**Nada está comiteado.** Todo el trabajo de la sesión vive en el árbol (partición de la sección 39,
informe de QA de la vuelta 2, los cuatro `instrumento` cerrados, el write-back del analista y esta
medición). Sobrevive a un reinicio porque está en disco; **no** sobrevive a un `git` destructivo, que
por eso está prohibido en `git.prohibidos`. `gh` **sigue sin autenticar** en esta máquina: hace falta
para el PR, no para trabajar.

### ⏸⏸ PAUSA — 2026-09-09, a petición del propietario. **Manda sobre todo lo que sigue**

**Hay trabajo SIN VALIDAR en el árbol, y es del mecanismo. Nadie debe confiar en él ni comitearlo
sin correr el banco.** El `desarrollador` de `REQ-023` (vuelta 1 de 3) fue detenido **justo antes de
correr la sección 39** — sus últimas palabras fueron que iba a ejecutarla. Ya había escrito:

| Archivo | Delta |
|---|---:|
| `hooks/lib.sh` | +99/−… |
| `hooks/guard-completado.sh` | ±4 |
| `tools/arnes-lectura.sh` | ±2 |
| `tests/escenarios/hooks/run.sh` | ±7 |
| `39-caracter-invisible-1-la-puerta.sh` | ±33 |
| `39-caracter-invisible-2-la-clase-y-el-corpus.sh` | ±260 |

**Total: 294 inserciones, 111 borrados.** No hay entrada de CHANGELOG y no hay commit.

**MEDIDO por la coordinadora después de la parada** (esto ya no es «sin validar a ciegas»):

| Puerta | Resultado |
|---|---|
| Banco completo (`run.sh`) | **962 PASS · 0 FAIL · 4 SKIP**, `rc=0`. Los cuatro SKIP son los de siempre, con su motivo; **ninguno nuevo** |
| Autoprueba del corredor | **105 PASS · 1 FAIL** (antes 106 · 0) |

**El único FAIL, y es pequeño y conocido:** `CA-18` — `39-caracter-invisible-2-la-clase-y-el-corpus.sh`
quedó en **402 líneas contra su techo de 400**. El `desarrollador` fue detenido **antes** de partir la
sección, que es lo que `CA-18` ordena (partir, **no** subir el techo). Es trabajo de minutos.

**Lo que sigue SIN acreditar, y no lo arregla un banco verde:** el **fail-before / pass-after**. Nadie
ha comprobado que el caso nuevo **falle** contra el código de hoy, así que **un verde no prueba todavía
que el caso discrimine** — podría estar pasando por tautología. Eso lo decide QA, no esta medición.

El trabajo no se descarta: `git` destructivo está prohibido (`git.prohibidos`).

#### Traslado a otra instancia de WSL — lo que NO viaja con el repositorio

Todo el trabajo está en `origin/rel/registro-1.33.0` @ **`29b06eb`** (dos commits: el cierre de
`REQ-027` y el WIP marcado). Lo que **no** viaja, en orden de daño si se olvida:

1. **`jq` vive en `~/.local`, no en el sistema.** Una WSL nueva no lo tiene. **Y sin `jq` los hooks
   del arnés quedan INERTES con un aviso: el enforcement se apaga sin que nada falle.** Es el olvido
   más caro de esta lista, porque no se manifiesta como error sino como silencio.
   **Corrección del 2026-09-09: `node` NO es dependencia del arnés y no debía figurar aquí.** En el
   clon nuevo `node` está ausente y no se echó en falta: las tres quality gates del manifiesto piden
   sólo `bash` y `jq`, y las únicas apariciones de `node`/`npm` en el árbol son **prosa** (§13 de
   `AGENTS.md`, el `README`, el CHANGELOG) y **cadenas de caso** que el guardián debe juzgar como
   texto (`npm run build > /tmp/build.log` en `07-bash-falsos-positivos.sh`). Nada las ejecuta.
   Listar una dependencia falsa junto a la única que apaga el enforcement **abarata la que sí importa**.
2. **`core.hooksPath` es configuración LOCAL y no se versiona.** En el clon nuevo hay que correr
   `git config core.hooksPath .githooks` o **la puerta del CHANGELOG queda apagada**, también en silencio.
3. **La identidad de git tampoco viaja, y faltaba en esta lista.** `user.name` y `user.email` son
   configuración local o global; un clon nuevo no tiene ninguna de las dos. Es el **tercer apagado
   silencioso de la misma familia** que 1 y 2 —el commit no falla: sale firmado con la identidad que
   el sistema derive (`juan@sysvega-dev`), y la autoría del historial se parte sin que nada avise—.
   Se restituye con la identidad **que el historial ya usa**: `Juan Vega <jvega@habitat.org>`,
   configurada **local al repositorio** para no decidir por los demás repos de la máquina.
4. **El plugin estable.** Instalado desde el marketplace `JJOVEGA/ArnesJuan`, versión **1.33.0**.
   Por autoalojamiento, **la 1.33.0 publicada gobierna el desarrollo de 1.34.0**: se instala la
   publicada, **nunca el árbol de trabajo**.
   **Precisión del 2026-09-09: el `gitCommitSha` que registra la instalación es `5f37946`, no
   `810128a`.** No es un error de instalación y conviene no volver a alarmarse: `810128a` es el
   **tag** `v1.33.0` y `5f37946` es `origin/main` («Registro de la publicacion de v1.33.0», #44), un
   commit **posterior**; el marketplace instala desde `main`. Lo que decide no es el sha sino **si el
   mecanismo difiere**, y no difiere: entre los dos commits sólo cambian `CHANGELOG.md`,
   `PENDING_APPROVAL.md`, `docs/ESTADO.md` y `docs/PLAN.md` —ni un archivo de `hooks/`, `tools/`,
   `.github/`, `.claude-plugin/`, `agents/`, `skills/` ni `templates/`—, y comparado **archivo por
   archivo contra el tag**, todo el mecanismo instalado coincide **byte a byte**. Esa comparación, y
   no la igualdad de shas, es la que hay que repetir en el próximo traslado.
5. **Sesión de Claude Code**: la cuenta activa es `juan.vega@sysvega.cr` (org *Consisa*).
6. **`gh` con dos cuentas**: `jvega-habitat` (activa, push sin admin) y `JJOVEGA` (dueño, rulesets).
   Hay que volver a autenticar las dos; `gh auth switch` alterna. **Es el único punto de esta lista
   que un agente no puede cerrar solo**: `gh auth login` es interactivo y el token no está en disco.

**Comprobación de que el traslado quedó bien hecho** —y es la misma que acredita que el arnés está
vivo—: correr el banco (`bash tests/escenarios/hooks/run.sh`) y la autoprueba. Un resultado **mejor**
que el esperado es sospechoso: significaría que algo no se está midiendo.

**El número de SKIP OSCILA entre 4 y 5 en la misma máquina, y no es la plataforma: es un caso de
reloj.** La primera corrida del clon dio **961 PASS · 0 FAIL · 5 SKIP** y la segunda, sobre el árbol
ya partido, **962 · 0 · 4**. El total cuadra en **966** las dos veces.

> **Corrección de una causa que esta misma sección afirmó mal, y se deja escrita porque el error es
> instructivo.** Al ver 5 SKIP se atribuyó la diferencia al SKIP de `cygpath` —`ruta estilo Windows
> con backslashes -> deny`, de `04-windows-formas-del-manifiesto.sh`— y se concluyó que «la cifra
> esperada no es una constante del proyecto sino de la máquina». **Es falso, y la prueba es que ese
> SKIP aparece en las DOS corridas**: estaba también entre los 4 SKIP de la máquina anterior, así que
> nunca pudo ser la diferencia. El caso que **entra y sale** es `REQ-017 CA-08 (ii) un REQ real de 6
> líneas: el reloj no sube más de 1,25× el de v1.32.1`, y su propio motivo de SKIP lo dice: «*el techo
> cae DENTRO del recorrido observado [1.010×, 1.302×]: el instrumento no distingue el factor que
> vigila*». Un caso así **salta cuando no converge y pasa cuando sí**, según la carga de la máquina.
> La lección real no es sobre plataformas: **una diferencia de una unidad en el recuento se explica
> leyendo la LISTA de SKIP, nunca el total** — comparar totales invita a inventarle una causa a un
> caso que sólo estaba oscilando. (El `desarrollador` reportó la oscilación como `REQ-017 CA-09, la
> pared de los 60 s`; el nombre no coincide con ninguna de las dos listas medidas, así que **el caso
> que oscila es el `CA-08 (ii)` de arriba**, que es el que sí aparece y desaparece entre ellas.)

Sobre `cygpath`, lo que sí es cierto y conviene conservar: aquí está **ausente** —el interop de WSL
está activo (`/mnt/c` montado, `WSLInterop` `enabled`) pero el host **no tiene Git para Windows** y el
`PATH` no lleva ninguna ruta `/mnt/c`—, el caso es de Windows y **no hay nada que arreglar**: el banco
lo salta declarando su motivo, que es lo que se le pide.

La autoprueba dio **105 PASS · 1 FAIL** al llegar —el `CA-18` conocido:
`39-caracter-invisible-2-la-clase-y-el-corpus.sh` en 402 líneas contra su techo de 400— y **106 PASS ·
0 FAIL** después de que el `desarrollador` partiera la sección.

**Lo cerrado en esta sesión, que sí está firme:** `REQ-027` **`completado`** — ciclo completo en
orden (analista → QA `aprobado` → auditor `aprobado`, `R-023`), quality gates verdes, cola 0, y sus
cuatro hallazgos abiertos son `instrumento`. **Sin comitear todavía**, junto con `R-023` en el
registro y el §S de QA.

**Decisión del propietario pendiente, y no bloquea ningún cierre:** la **clase de `SEC-075`**. QA lo
encoló como `instrumento`; el `auditor-seguridad` sostiene **`contrato`** (`R-023`), porque
`arnes-upgrade` no mide nada, **es el canal de entrega**, y falta la entrada «Hacia 1.33.0» siendo
1.33.0 la versión publicada e instalada que cambió andamiaje heredado. Si es `contrato`, hay que
resolverlo **antes de publicar `v1.34.0`**. **No se metió en `PENDING_APPROVAL.md` a propósito:** una
entrada ahí congela el cierre de **cualquier** REQ, y esta decisión sólo muerde al publicar.

### ⏸ SESIÓN DETENIDA — 2026-09-09, cambio de cuenta. **Retomar exactamente por aquí**

**Cero pérdida.** El `desarrollador` de `REQ-023` (`a347fe27f3ac56805`) se detuvo **antes de escribir un
byte**: `git status` no mostraba nada en `hooks/`, `tools/` ni `tests/`. **Ninguna comisión viva.**

**▶ RETOMADA el 2026-09-09 tras el cambio de cuenta** (`jvega@habitat.org`, org *Habitat_LAC* →
`juan.vega@sysvega.cr`, org *Consisa*). Dos hechos medidos al retomar, que cambian el plan de despacho:

- **Ningún subagente sobrevivió al cambio de cuenta.** `ListAgents` sólo ve esta sesión y una sesión
  par, así que **todos los IDs «reanudables» de la sección de agentes están muertos**: cada comisión
  se abre nueva. Se pierde el ~4× de ahorro por reanudación; **no se pierde trabajo** — todo lo que
  las comisiones anteriores produjeron está comiteado.
- **Los dos frentes de cabeza van EN SERIE, no en paralelo.** `tools/arnes-paralelo.sh REQ-027 REQ-023`
  responde **`colisiona` en `AGENTS.md`** (rc 1; los dos lo declaran en su campo `Archivos:`, junto a
  `templates/AGENTS.md.tpl` y `skills/arnes-upgrade/SKILL.md`). Se empezó por **`REQ-027`**, que es lo
  que manda el orden de abajo.

**Lo primero al retomar, en este orden:**

1. **`REQ-027` — dos write-backs de UNA CLÁUSULA cada uno, y QA ya dijo que con ellos aprueba.**
   Analista `a22f39d25dbc01323` (reanudable):
   - **`QA-027-06`** (`instrumento`): en `CA-05` deben quedar **`1.037 B` y `1.844 B`**, no 1.036/1.843.
     Las dos cifras son ciertas sobre rangos distintos, pero **`CA-05` cita ese desglose como su
     corrida**, y la única convención con la que el desglose **suma** es la que atribuye cada blanco al
     tramo que cierra. El **49,8 % no se mueve**.
   - **`QA-027-07`** (**`contrato`**, bloquea): el REQ **no declara** que la vía real de
     `/arnes-upgrade` **no se ejecutó**. `CA-10` se acredita por **conducta** —comprobada dos veces con
     transcripciones independientes— pero el contrato debe decir **qué se acreditó y qué queda
     pendiente**, con dueño **coordinadora**. Sin esa cláusula, el pendiente **desaparece al cerrar**.
   Después: QA re-valida **sólo eso** (`a6dc6356bb177db68`) y **luego el auditor**
   (`abeaf052ce49ea3a2`). Orden §6, no se relaja.

2. **`REQ-023` — vuelta 1 de 3 al `desarrollador`** (`a347fe27f3ac56805`, reanudable con su contexto).
   El encargo ya estaba escrito; lo esencial:
   - **`QA-023-01`** (`usuario/dinero`, **crítica**): **`SEC-047` NO está cerrado.** El alfabeto se
     deriva de las seis claves, **dos son multi-palabra**, así que **contiene `0x20`**. La guarda borra
     lo **ajeno** y pregunta si lo que queda **es** una clave ⇒ si lo insertado **pertenece** al
     alfabeto no se borra, y si **sustituye** al blanco interno **se borra y el blanco no se repone**.
     En los dos casos **calla** y se resuelve como **ausencia**. Medido: `U+0020`, **NBSP** y **TAB**
     dan **allow en las dos versiones**; `U+FEFF` y `Ω` dan deny.
   - **Mecanismo conforme ya derivado por el analista** (leyendo, **no ejecutado**): **reponer un
     blanco en el sitio de la retirada y colapsar blancos repetidos** antes de preguntar si lo que
     queda es una clave. Cubre sustitución y duplicación sin denegar nada legítimo.
   - **`CA-03` fue reescrito** y ahora su caso **puede fallar**: sorteo **estratificado** en E1/E2
     derivados de la constante de claves, **tres** procedimientos (insertar · sustituir el blanco ·
     **duplicarlo**), veredicto **por rama**, y **anti-tautología como criterio** — publica las tiradas
     por rama junto a la semilla, **SKIP y nunca PASS** si una rama de DENY se queda sin tirada, y **un
     pool escrito a mano incumple**.
   - **`QA-023-04`**: arreglar la derivación que pasó de **6 a 5** claves y **perdió `Estado`**
     (`36-…-2-los-lectores.sh:228`). **PARADA:** ese archivo y `36-…-3-comentar-retira.sh:33` **NO
     están en el `Archivos:`** del REQ — si el arreglo los escribe, **para y avisa**; ampliar el campo
     es enrutado de la coordinadora.
   - **Fuera de esta vuelta:** `CA-12 (iii)` (fuera de alcance con dueño, ventana propuesta 1.35.0 y
     forzador), `CA-08` (gate humano de `SEC-048`) y `CA-10`.

3. **`CA-10` de `REQ-023`** — fila de `AGENTS.md` §13 y su apartado en la skill. `AGENTS.md` está
   **libre** ahora.

4. **`REQ-024`** — contrato cerrado y despachable. **Colisiona con `REQ-023`** en `hooks/lib.sh`,
   `hooks/guard-completado.sh`, `tools/arnes-lectura.sh`, `run.sh` y `README.md`, y **dentro del
   primero, la misma región de funciones**. Su factibilidad **ya está resuelta y medida**: hay vía a
   **0 procesos añadidos** plegando la llave en el `jq` que ya existe en `arnes_parse_manifest`
   (`docs/arnes/req-024-activacion-cero-procesos.md`). Defecto a cerrar al implementar: la llave como
   cadena `"true"` cae a **ALLOW sin aviso**.

**Dato que hay que conservar o se pierde — línea base de `CA-08 (c)` de `REQ-027`:** la señal se fija
en la **primera comisión despachada ya con el bloque**, y el bloque existe desde `6dd3f8a`. Esa
comisión fue la **1.ª vuelta de QA de `REQ-027`** (`a6dc6356bb177db68`), y su
**`subagent_tokens` = 140.349**. QA no puede tomarla porque el numerador **existe fuera de su proceso**
y sólo lo ve quien despacha. Si esa cifra se pierde, la honesta es tomarla sobre la primera cuyo
número exista **con la desviación escrita**. Y `CA-08` **no define qué cuenta como «un resultado
entregado»**, así que cualquier razón formada hoy sería **incomparable** con la de otra comisión.

**Serie que continúa esa línea base — `subagent_tokens` medidos por la coordinadora el 2026-09-09,
todas con lista de lectura cerrada por rangos:**

| Comisión | `subagent_tokens` | Objetivo dado | Herramientas |
|---|---:|---:|---:|
| Analista · write-back `QA-027-06`/`-07` | **46 095** | < 60 k | 11 |
| QA · 3.ª vuelta documental de `REQ-027` | **52 407** | < 50 k | 13 |

**Dos límites que hay que leer con la cifra, o engaña.** (a) La comparación con los **140 349** de la
1.ª vuelta de QA **no es una medida del bloque**: aquélla midió y reprodujo, éstas contrastan
documentos, así que la caída mezcla el efecto del bloque con un cambio de trabajo — es justo lo que
`CA-08` no puede separar mientras no defina «un resultado entregado». (b) **Las dos estimaciones que
los agentes escribieron en sus informes (≈35–45 k y ≈32 k) quedaron por debajo del número real**:
sirven de orden de magnitud, no de medición. La medida es la de esta tabla, y sólo la ve quien despacha.

### Alcance vigente: CUATRO trabajos (`docs/PLAN.md` §«ALCANCE VIGENTE DE 1.34.0»)

`REQ-019` **aplazado a 1.35.0** por el propietario. `REQ-027` **entró como quinto y luego la ventana se
reordenó a cuatro**: sonda (`REQ-017`), `REQ-026`, `REQ-023`+`REQ-024`, `REQ-027`.

### Estado por REQ, medido ahora

| REQ | Estado | Bloqueantes |
|---|---|---|
| **REQ-017** | **`completado`** | — |
| **REQ-023** | `en-revisión` | ninguno declarado; **QA en curso** |
| **REQ-024** | `pendiente` | contrato cerrado y **despachable**; espera archivos |
| **REQ-026** | `en-revisión` | **`SEC-072`** (`contrato`), **`SEC-073`** (`contrato`), y `usuario/dinero` |
| **REQ-027** | `en-progreso` | **`QA-027-01`** (`contrato`) + `QA-027-03` en corrección |
| **REQ-019** | `bloqueado` | `SEC-033` (`contrato`). **Aplazado a 1.35.0** |
| **REQ-021** | `bloqueado` | 3 vueltas agotadas, sin salida decidida |

### Agentes — ⚠ TODOS LOS IDs DE ABAJO ESTÁN MUERTOS desde el cambio de cuenta (2026-09-09)

> Se conservan como **traza de quién midió qué**, no como direcciones: ninguno resuelve ya. La regla
> «reanudar cuesta ~4× menos que abrir nuevo» sigue siendo cierta y vuelve a aplicar a los agentes
> que se abran **a partir de ahora**, dentro de esta sesión.

**VIVOS ahora:** `a581adc9758dd701d` (`qa-tester` · `REQ-023`) y `a67b1bb3ed3cd75c8`
(`desarrollador` · `QA-027-03` + correcciones + vía real de `/arnes-upgrade`).

**Reanudables:** `afc7860e40e10399b` (analista `REQ-026`, autor de `CA-08`/`CA-18`/`ADR-008`) ·
`a22f39d25dbc01323` (analista `REQ-027`) · `a0926dca26256f347` (analista `REQ-024`) ·
`a053fc8da6af7d93b` (analista `REQ-023`) · `a515fa2cde6a9d5d4` (analista `REQ-019`, tiene el plan por
fases) · `ae0b88aa7187979d4` (dev `REQ-026`) · `a347fe27f3ac56805` (dev `REQ-023`) ·
`ad9d3d84a75b0d243` (dev `REQ-027`) · `a4453da209b8dd7e5` (dev `REQ-019`) ·
`a7cfac0c040308909` (QA `REQ-026`) · `a6dc6356bb177db68` (QA `REQ-027`) ·
`abeaf052ce49ea3a2` (auditor, `R-021`/`R-022`) · `a67c98b758286fd20`, `ad6299cb1acaca246`,
`a3f8b1dcaceab4f10`, `aab196e5d94807e0c`, `a98ae536310d73d8a`, `a80898cb0a6602cbf` (`REQ-017`, `REQ-024`).

### Evidencia en disco — enlazada, no copiada

`docs/decisions/ADR-008-…-escrituras-concurrentes.md` (`propuesta`) · `docs/arnes/req-019-techo-propuesto.md`
· `docs/arnes/req-019-fechas-desfasadas.md` · `docs/arnes/req-024-activacion-cero-procesos.md` ·
`docs/arnes/req-023-coste-y-dominio.md` · `docs/arnes/req-023-registro-ruta-critica.txt` ·
`docs/qa/1.34.0.md` · `docs/qa/REQ-027.md` · `docs/seguridad/registro-seguridad.md` (`R-020`–`R-022`).

### Siguiente acción, en este orden

1. Esperar a los **dos frentes vivos**.
2. **QA re-valida sólo lo afectado** de `REQ-027`, y **luego seguridad**. Orden §6, no se relaja.
3. **`CA-10` de `REQ-023`** —fila de `AGENTS.md` §13 y su apartado en la skill— **en cuanto QA suelte
   `requirements/REQ-023.md`**. Es la única dependencia de escritura pendiente.
4. **`REQ-024` implementación**: colisiona con `REQ-023` en `hooks/lib.sh`, `guard-completado.sh`,
   `tools/arnes-lectura.sh`, `run.sh` y `README.md` — y **dentro del primero, la misma región de
   funciones**. Entra cuando `REQ-023` suelte esos archivos.
5. `CA-08 (c)` de `REQ-027`: **de oportunidad**, como subproducto del próximo encargo. Nunca con
   comisión propia.

### Lo que NO se puede hacer, y por qué

**`v1.34.0` NO se publica.** No sólo por `REQ-026`: hay **`contrato` abiertos** en `REQ-007` (tres),
`REQ-013` (dos), `REQ-020` (**ocho**), `REQ-019`, `REQ-021`, `REQ-026` y `REQ-027`. Por la regla global
del propietario (2026-09-08) **cualquiera devuelve el tag a él**, y su instrucción vigente es no
publicar sin resolver **o aceptar explícitamente**. La decisión que llegará al cerrar el trabajo no es
«publicamos», sino **cuáles se resuelven, cuáles se declaran residuales con dueño y vencimiento, y
cuáles se aceptan**.

**No hay riesgo vivo en `REQ-026`**: la rotación está **apagada** (`activo: false`, `artefactos: []`) y
**ningún REQ real se ha rotado nunca**.

### Coste

**≈3,1 M tokens en 19 comisiones cerradas**, por `subagent_tokens`, que es **acumulado por agente** —
no se suma dos veces al reanudar; ese error se cometió y está corregido. **El consumo de la
coordinadora sigue sin instrumentar.**

## PUNTO DE CONTINUIDAD — 2026-09-08, ventana 1.34.0 [ANTERIOR]

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
| **REQ-017** | **`completado`** (2026-09-08, `496068c`) | **TERMINADO.** `QA: aprobado` y `Seguridad: aprobado (R-020)` **re-emitidos sobre este árbol**. Nueve hallazgos abiertos, los nueve `instrumento` |
| **REQ-026** | `en-revisión` | **MECANISMO IMPLEMENTADO Y VALIDADO** (`CA-01`–`CA-12`, `CA-15`): `QA: aprobado`, `Seguridad: con-hallazgos (R-021)`. **NO cierra**: `SEC-067` (`usuario/dinero`) y `QA-026-04` (`contrato`). `CA-13`, `CA-14`, `CA-16`, `CA-17` y `CA-18` **contratados y sin implementar** |
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

## PUNTO DE CONTINUIDAD — 2026-09-09, cierre de la sesión autónoma

> **Léelo antes de actuar.** Sustituye a lo de arriba donde discrepe. Rama `rel/registro-1.33.0`,
> **todo empujado**, árbol limpio.

### Terminado

- **`REQ-017` — `completado`** (`496068c`). El ciclo entero en **una** vuelta: analista → desarrollador
  (`19b1822`) → QA (`con-hallazgos`, 7 hallazgos) → desarrollador (`538c266`) → QA (`aprobado`) →
  auditoría (`R-020`). `CA-08 (ii)` decide ahora por **unanimidad de `k = 4`** razones, con `k`
  derivado por **saturación** sobre 56 repeticiones y el techo `≤ 1,25×` intacto.
- **`REQ-026` — mecanismo implementado y validado.** El rotador **ya sabe mover una tabla**: 29 casos
  nuevos, `CA-01`–`CA-12` y `CA-15` acreditados, banco de 887 → **916 casos**.
- **Deuda cerrada de paso:** `SEC-066` (el README del banco desfasado) y la colisión `ADR-006`, que
  `REQ-019` reclamaba y era de `REQ-014`.

### Bloqueado, y por qué exactamente

| Qué | Clase | Quién lo desbloquea |
|---|---|---|
| **`REQ-019`** — el techo `CA-07 0,72×` es **insatisfacible en bytes** (suelo `0,810×`, exceso 6.705 B) | decisión | **Tú**, `PENDING_APPROVAL.md`, entrada del 09-08 |
| **`REQ-026`** — `SEC-067` (`usuario/dinero`): actualización perdida en concurrencia | defecto | `CA-18` implementado + parte 4 del banco |
| **`REQ-026`** — `QA-026-04` (`contrato`): `_doc_artefactos` describe el mecanismo viejo, y vive en la **plantilla que los proyectos heredan** | decisión | **Tú**, entrada del 09-09 opción **A**. **Vence antes del tag `v1.34.0`** |
| **`REQ-023` + `REQ-024`** — `borrador`, sin contrato | trabajo | analista, no empezado |
| **Tag `v1.34.0`** | — | vuelve a ti por §6: hay `usuario/dinero` y `contrato` abiertos |

### Decisiones vigentes que se aplicaron esta sesión

1. **El tope dev↔QA se cuenta por CICLO, no por REQ, cuando §9 reabre.** Lectura **de la
   coordinadora**, revocable: si el contador sobreviviera a una reapertura, la REGLA DE ESTADO
   —«re-recorre el ciclo»— sería inoperante para todo REQ que hubiera gastado su tope. `AGENTS.md` §6
   **no resuelve el caso por escrito**. Si lo lees como acumulativo, `REQ-017` debió pasar a
   `bloqueado` en vez de cerrar, y revertirlo cuesta una comisión.
2. **La medición de factibilidad va ANTES del trabajo, no al final.** Se aplicó a `REQ-019` y ahorró
   7–11 h de reparto hacia un blanco inalcanzable. Es la quinta aparición de *«criterio derivado sin
   comprobar su factibilidad»*.
3. **Reanudar agentes en vez de abrir nuevos.** Medido: la re-validación de QA de `REQ-017` costó
   **39 k** de delta contra los **148 k** de una validación completa.

### Agentes — comprobar antes de despachar

Todos **terminados y reanudables**. Reanudar cuesta mucho menos que abrir nuevo.

| Id | Rol · trabajo |
|---|---|
| `ae0b88aa7187979d4` | `desarrollador` · `REQ-026`, el rotador. **Es quien tiene que implementar `CA-18`** |
| `a7cfac0c040308909` | `qa-tester` · `REQ-026` |
| `abeaf052ce49ea3a2` | `auditor-seguridad` · `R-021`. **Es quien cierra `SEC-067`** |
| `afc7860e40e10399b` | `analista` · `REQ-026`, autor de `CA-08` y `CA-18` |
| `a4453da209b8dd7e5` | `desarrollador` · `REQ-019` F1, midió el suelo en bytes |
| `a515fa2cde6a9d5d4` | `analista` · `REQ-019`, tiene el plan por fases |
| `a3f8b1dcaceab4f10`, `a67c98b758286fd20`, `ad6299cb1acaca246`, `a22f39d25dbc01323`, `a98ae536310d73d8a` | `REQ-017` y `REQ-027`, cerrados |

### Siguiente acción

**Con la rotación APAGADA no hay riesgo vivo: nada de esto es urgente.**

1. Resolver la entrada **A** de la cola (`_doc_artefactos`) — comisión corta, cierra un `contrato`
   que bloquea el tag.
2. Firmar el techo de `REQ-019` o elegir otra opción. Sin eso, F2 no se despacha.
3. Implementar **`CA-18`** con su par discriminante en una **parte 4** del banco —
   `28-rotacion-seccion-3-la-tabla.sh` está en **400 de 400 líneas**, el techo exacto de
   `REQ-014 CA-18`, así que **el próximo caso obliga a partir, no a alargar** — y que el auditor
   cierre `SEC-067`.
4. `REQ-022`: la dimensión que el analista dejó redactada — `arnes-paralelo.sh` no conoce a los
   escritores **no-comisión**. **Antes** de encender la rotación, no después.

### Lo NO verificado, dicho expresamente

- **Que `k = 4` resuelva en el runner de `hooks-en-linux`: SIN MEDIR.** Todo lo verificado es local.
  Y su modo de fallo es **silencioso** — es `SEC-064`.
- **El techo de coste de `REQ-017`** (`+28,0 s = 0,569×`): acreditado por el desarrollador, **no
  verificado por nadie**.
- **El techo de `CA-15`** (`≤ 0,140 s`): QA auditó estadístico, aritmética y orden; **no re-midió** la
  campaña. Sin medir en el runner real ni en Windows/MSYS.
- **Con la rotación encendida sobre `requirements/` no hay NINGUNA medición, de nadie.** Todo el
  trabajo fue sobre copias en `/tmp`, y ningún REQ real se rotó.
- **`(iv)` de `CA-18`** —que dos paradas dupliquen el bloque— es **modelado, no medido**.
- **La ausencia de una séptima forma ambigua es evidencia acotada, no demostración**, y lo declaran
  los dos: QA y el auditor.
- **Mi propio consumo sigue sin instrumentar.** Lo único medido son los subagentes.

### Decisiones del propietario del 2026-09-09 — YA APLICADAS

1. **`REQ-026`: autorizado SÓLO `_doc_artefactos`** en `.arnes/config.json:48` y
   `templates/arnes-config.json.tpl:53`, **sin activar la rotación**. `rotacion.activo` y
   `rotacion.artefactos` quedan fuera. Cierra `QA-026-04` (`contrato`) cuando se aplique.
2. **`REQ-027` entra como QUINTO trabajo de 1.34.0**, y su implementación va **después de `REQ-019`,
   sobre la estructura resultante** — plantilla + `arnes-init` + `arnes-upgrade` con sus
   verificaciones. `docs/PLAN.md` §«ALCANCE DE 1.34.0» actualizado; `REQ-027.md:7` queda **ratificado**.
   Hereda el bloqueo de `REQ-019` por transitividad.
3. **`REQ-019`: mantener el alcance y ajustar el objetivo.** El techo propuesto está calculado en
   `docs/arnes/req-019-techo-propuesto.md`: **≤ 0,93× / ≤ 0,89× / ≤ 0,91×**, es decir **−7.188 B de
   lectura obligatoria** por comisión. **Falta sólo su firma.**
4. **Revisión de fechas CERRADA por el propietario**, sin convertir las dudas en bloqueantes.

### Instrucciones vigentes del propietario que ejecutan OTROS agentes, más tarde (2026-09-09)

**1. `REQ-027 CA-08` señal (c) — se toma DE OPORTUNIDAD, nunca con una comisión propia.**
*«Aprovechá el próximo encargo autorizado que cargue el bloque; no abras una comisión solo para
producir esa señal.»* El criterio la fija en la primera comisión despachada **ya con** el bloque `§14`
de `AGENTS.md`, y `REQ-027` se entregó en `6dd3f8a`, así que **toda comisión posterior es candidata**.
Va **como subproducto** en el encargo de la próxima que corra, y el numerador ya existe sin medir nada
nuevo: el `subagent_tokens` que el arnés reporta al terminar cada comisión.

**Mientras la señal no se tome, la consecuencia es de contrato y está escrita en tres sitios**
—`REQ-027:127-128`, `docs/qa/REQ-027.md` §5 y el `CHANGELOG`—: **NO se declara que las reglas
sirven**, y `REQ-025` no puede citar este REQ como evidencia de que bastan.

**2. Las limitaciones de Codex y Cursor se CONSERVAN explícitamente**, y no se tocan sin evidencia
nueva:

| Herramienta | Estado | Por qué |
|---|---|---|
| **Claude Code** | `verificada` | `@AGENTS.md` en `CLAUDE.md:6` y `templates/CLAUDE.md.tpl:6`, comprobado por el desarrollador **y** por QA |
| **Codex** | **`no verificada`** | Sólo hay una **afirmación del proveedor** (`codex-self-knowledge.md:52`). QA validó el descarte: una afirmación del fabricante **no es** la observación de que el bloque llegue a una coordinadora de Codex, y la regla `B.1` no la acepta |
| **Cursor** | **`no verificada`** | **No está instalado** y no hay configuración suya en el repositorio: no hay nada que observar |

**La consecuencia, dicha como es:** `REQ-027` entrega su objetivo **para UNA de las tres herramientas**.
Quien escriba `verificada` en las otras dos necesita **la observación**, no la promesa del fabricante —
y ése es exactamente el fallo que este REQ persigue.

### Deuda anotada y NO resuelta

~~20 fechas un día por delante~~ — **cerrado el 2026-09-09, y el número era falso.** La deuda decía
«12 en `REQ-019` y 8 en `REQ-026`» y **nadie lo había comprobado**. Medido ahora en `REQ-019`:
**15** apariciones del literal, **0 desfasadas confirmadas**, 2 correctas por evidencia no-git y **13
indeterminadas**. Y el método que la coordinadora prescribió **no sirve**: `git blame` devuelve
`Not Committed Yet` en **14 de las 15**, porque son posteriores al último commit; comprometer primero
daría la fecha del día en que se comprometa, no del día en que se escribió. Evidencia conservada en
`docs/arnes/req-019-fechas-desfasadas.md`, con dos avisos para quien alguna vez las toque: **cuatro**
son la fecha de la **firma del propietario** sobre `0,72×`, y **seis** viven dentro de texto de
criterio. **Decisión del propietario: no se editan y no bloquean.** `SEC-070` y `SEC-071`: un **tercer y cuarto** sitio con la forma cruda
de lectura, uno de ellos en un punto que **sí escribe**. `SEC-058`: el tercer término de un piso de
`CA-18` **no lo verifica ninguna máquina**. El epígrafe de `REQ-026` que dice «Dos decisiones» y
lista tres. Y el `Archivos:` de `REQ-017` nombra **dos secciones que no existen** — se corrige
**junto con `REQ-021`**, que declara los mismos nombres fantasma, porque arreglar sólo uno puede
producir un `disjunto` en falso.

### [SECCIÓN OBSOLETA — sustituida el 2026-09-09; sus tres primeros datos son FALSOS]

Escrita por la coordinadora el 2026-09-08 y **contradice** la sección «Deuda anotada y NO resuelta» de
arriba, que es la vigente. Se marca en vez de borrarse porque el defecto —dos versiones del mismo
tablero, una falsa— es la clase que este proyecto persigue, y verlo señalado enseña más que verlo
desaparecer. Qué era falso, punto por punto:

- **«20 fechas un día por delante»** — la deuda **nunca se comprobó**. Medido el 2026-09-09: **15**
  apariciones en `REQ-019`, **0 desfasadas confirmadas**, 13 indeterminadas, y `git blame` **no sirve**
  en 14 de 15. **Cerrada por el propietario**, sin convertir las dudas en bloqueantes.
- **«Falta la entrada de Migraciones conocidas de `arnes-upgrade`»** — **ya existe**, añadida en
  `6dd3f8a` (`skills/arnes-upgrade/SKILL.md`, entrada «Hacia 1.34.0»).
- **«El techo de 2.600 B de `REQ-027 CA-05` es un límite propuesto sin validar»** — **se validó y no
  cabía**: el bloque mide **3.703 B**, y el techo se **re-derivó** con entrada en Historial, como el
  propio criterio ordena.
- Lo único que **sigue siendo cierto**: **el consumo de la coordinadora no está instrumentado**. La
  cifra de «≈1,10 M en 11 comisiones» sí está superada — hoy van **≈3,1 M en 19 comisiones cerradas**,
  contadas por `subagent_tokens`, que es **acumulado por agente** y no se suma dos veces al reanudar.

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
## Estado derivado — 2026-09-09 22:09

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `rel/registro-1.33.0` @ `2535628` — CON CAMBIOS SIN COMITEAR
**Arnés:** plugin instalado `1.33.0`
**Aprobaciones pendientes:** 4
**REQ:** 27 — completado 14 · en-revisión 2 · en-progreso 2 · bloqueado 3 · otros 6
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 14 completados no se listan._

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
| REQ-023 | bloqueado | con-hallazgos | con-hallazgos | critico | qa-023-11(instrumento),qa-023-12(instrum… |
| REQ-024 | en-progreso | pendiente | pendiente | critico | (ninguno) |
| REQ-025 | borrador | pendiente | pendiente | critico | (ninguno) |
| REQ-026 | en-revision | aprobado | con-hallazgos | critico | qa-026-03(instrumento),qa-026-07(instrum… |

<!-- ARNES:DERIVADO fin -->
