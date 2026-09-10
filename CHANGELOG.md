# CHANGELOG — ArnesJuan

> Bitácora de versiones del plugin. SemVer; cada versión tiene su tag `vX.Y.Z`.

## [Interno] — 2026-09-09 · `CA-06` cumplido y `CA-04` detenido en su gate: el `desarrollador` no asumió que la delegación lo cubriera
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` · consolidación: coordinadora. **Bajo delegación de 24 h.**

**`REQ-024` queda en 10 de 11 criterios.** Banco **1005 PASS · 0 FAIL · 7 SKIP**, cuadre **1012** (de
996: **16 casos nuevos**), rc 0, sin `ABORT`; autoprueba 106 · 0; tres quality gates verdes. **65 s de
reloj con `loadavg` 0,82 al arrancar y 3,05 al terminar** — publicó la carga, como se le pidió.

**Y el inventario cuadra sin pérdidas, comprobado en worktree:** diff de **32** líneas y **ninguna** es
una pérdida — +16 casos nuevos, +1 `REQ-017 CA-08 (ii)` que pasa de SKIP a PASS por carga del host
(988+16+1 = 1005; 8−1 = 7), 2 de semilla del sorteo de `CA-03` y 2 de denominador del corpus de `CA-04`
(5611 → 5660 líneas con campo, y **subir es conforme**). **Ninguno de sus 16 casos abstuvo.**

**`CA-06` cumplido con discriminante en las dos direcciones:** fail-before **3 PASS · 13 FAIL** →
pass-after **16 PASS · 0 FAIL**, con un método que merece nota — un caso **sobre texto** no se puede
mover con `ARNES_HOOKS_DIR`, así que introdujo `ARNES_SKILL_UPGRADE` apuntando a la versión anterior de
la skill. Y **los 3 que pasan en las dos corridas están declarados con su discriminante dentro del
mensaje**: el orden en el apartado ya era cierto (por eso se mide **dos veces**, y restringido a su
sub-bloque **falla** antes), «los barridos declaran las tres cosas» es derivado con denominador (1 → 2, y
**SKIP si 0**), y «ninguna frase afirma completitud» es una invariante que no puede romperse (3/3 → 5/5).
Un PASS que pasa antes y después, **explicado**, vale; callado sería tautología.

**`CA-04` NO se implementó, y es la decisión correcta.** Su gate humano es **previo**, y el
`desarrollador` lo confirmó **leyendo** en vez de asumir que la delegación de 24 h lo cubría:
`REQ-024.md:191-195` dice que «*el cambio **se detiene** en `PENDING_APPROVAL.md` … este REQ **nombra**
ese gate; **no lo sustituye***», §6 pone el gate **antes** del acto, y `D5` dejó la fila del **rigor**
fuera por su propia letra. **No tocó `AGENTS.md`, `templates/AGENTS.md.tpl` ni `PENDING_APPROVAL.md`.**

**Y el proyecto había anticipado este atajo:** `REQ-023` dejó escrito que quien reescribiera la fila del
CR tendría **delante** la fila del rigor y que arreglarla «de paso» sería un cambio de `AGENTS.md` sin
gate y sin su REQ. *Su REQ es éste.* Escalado como **`D7`**, con el paquete **medido** para que el gate no
cueste re-derivar nada.

**Su texto heredado sí es verdadero leído solo:** la promesa de compatibilidad de la skill va **acotada al
sujeto** —«*la resolución de la ausencia de un campo de cabecera decide exactamente lo mismo que
1.33.0*»— y **acompañada** de qué sí cambia sin llave, con **un caso de máquina para cada mitad**. Si se
escribiera absoluta **sería falsa**, porque el bloque B cambia la cola **sin llave y para todos**.

**Y retiró un punto de su propia lista de dudas:** releyó `templates/AGENTS.md.tpl` y **no divergen** —
párrafo y fila son idénticos línea a línea a `AGENTS.md`—, así que el arreglo de `CA-04`, cuando se
autorice, es el mismo texto en dos archivos. Verificó también que la fila de `SEC-079` sigue byte a byte
(`md5 3ead3bd3…`, 2545 B).

**`SEC-081`: no creó una cuarta instancia del defecto, y tampoco lo cerró.** No escribió la fila, así que
no reprodujo la forma; su remediación en `requirements/README.md` sigue siendo del analista.

## [Interno] — 2026-09-09 · `SEC-079` cerrado (`R-025`), y por segunda vez el auditor corrige un rango que le di mal
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: `auditor-seguridad` (Opus) · consolidación: coordinadora. **Bajo delegación de 24 h.**

**`SEC-079` se cierra**, marcado `mitigado` —su entrada **no se borra**—, retirado del campo, y
**`Seguridad: aprobado`** firmado. **`REQ-023` queda sin ningún bloqueante de QA ni de seguridad: 0.**
Sigue `bloqueado` por la decisión del propietario, y la firma no lo desbloquea.

**Qué acredita la firma, y sólo eso:** que el texto que los proyectos **heredan** —las dos sedes de la
fila y el apartado de la skill— **ya no promete más cobertura de la que la máquina tiene**, y que **cada
afirmación de hecho de esa fila es verdadera medida** contra `fcbb7b1`. **No** acredita el mecanismo de
este árbol, ni `REQ-024`, ni que la clase esté cerrada, ni el banco.

**Segundo error de rango de la coordinadora, y es el CONTRARIO al de `R-024`.** Propuse
`1154417..fcbb7b1`, que **excluye `1154417`** — el commit donde la fila se reescribió por primera vez y
donde `CA-10` recibió **135 líneas** de su primer write-back (verificado). El rango dejaba fuera la mayor
parte de la remediación que pedía acreditar. El auditor auditó **`390a0a2..fcbb7b1`** y, además, **lo
restringió por RUTA** con un motivo que no es comodidad: ese mismo rango trae **+270/−22 de mecanismo**
(`hooks/lib.sh` +192, `guard-completado.sh` +42, `estado-derivado.sh` +11, `arnes-lectura.sh` +47, de
`REQ-024`), y «*un rango declarado sólo por commits habría hecho pasar ese delta por revisado*». **Dos
veces he dado el rango mal: una vez corto por delante y otra por detrás. El rango es un parámetro de la
firma y lo estoy tratando como un adorno.**

**El par que decide, con dos documentos idénticos salvo dos bytes:** `Sensible a seguridad: sí` con
`Rigor: ligero` → **DENY** («*su rigor efectivo es `critico`*»); el mismo con `а` cirílica → **ALLOW**; y
el mismo homóglifo con `Rigor: critico` **declarado a mano** → **DENY**. La denegación que desaparece es
**exactamente** la que producía el campo borrado, y vuelve al declarar el rigor. Y «*ninguna versión lo
deniega, tampoco 1.34.0*» queda verificado en **`v1.31.0`, `v1.32.1`, `v1.33.0` y este árbol**, con
control latino DENY en los cuatro.

**Su propio control negativo, contra la fila que él mismo declaró falsa:** incumple por **cuatro sitios
independientes** —titular sin condición, «nunca se permite por ausencia» universal y medida falsa, «Tres
fronteras» cerrada sin marca ni puntero, y cero menciones de la vía—, y la de hoy corrige los cuatro. **El
arreglo es aditivo**: la promesa universal no se borró, se **condicionó** (5 → 8 oraciones, **cero
retiradas**). Y **no-regresión medida**: las 10 fixtures de `R-024` dan veredicto **idéntico** en
`390a0a2` y `fcbb7b1` pese al delta de mecanismo.

**Y se cazó a sí mismo, que es lo que más vale del informe:** su entrada de `SEC-079` nombraba tres
ubicaciones y **elogiaba la skill por honesta** — cierto sobre la vía y **falso sobre el mecanismo**,
porque `SKILL.md` llevaba **los dos** defectos. Localizó por «las sedes que `CA-10` nombra» en vez de
**derivarlas del texto**: la forma (a) cometida **por el auditor sobre sus propias ubicaciones**. Queda
escrito en `R-025` §3.

**`SEC-081` (`instrumento`, media, dueño `analista-requerimientos`) — nuevo, y su diagnóstico es fino:**
la Regla de `requirements/README.md` cubre la lista de fronteras **por propiedad**, así que no hay laguna
doctrinal, **pero sus tres ejemplos marcados son todos de la dirección que ABRE**, y `SEC-079` pasó **tres
filtros** porque «excepto estas tres fronteras» **suena a propiedad y tranquiliza**. Hoy la lección vive
sólo en `CA-10`, **que muere con su REQ**. Remediación: una frase que declare que la propiedad alcanza
**las dos direcciones**. **Su forzador ya está en cola: `REQ-024 CA-04`**, misma tabla y misma forma.

**Dos límites que declara y respeto:** el delta de mecanismo del rango **no está auditado** —su
comprobación fue no-regresión sobre 10 fixtures, «*cota inferior, no auditoría*»—, y de la llave nueva
sólo verificó que **nace apagada**. Y `guard-completado.sh:363`/`:392` conservan «**NUNCA** permite por
AUSENCIA»: mantiene la clase `instrumento` de `QA-023-21` porque **la frase sólo se muestra al denegar**,
donde es localmente cierta, y jamás llega a la persona en el caso expuesto — «*pero quien la lea de más se
equivocará igual*».

**Medido sin ensanchar `SEC-078`:** `tools/arnes-lectura.sh` —el lector **proactivo**— señala el NBSP y
**no** señala el homóglifo: publica ese REQ como normal con `rigor efectivo: ligero`.

## [Interno] — 2026-09-09 · `QA-023-18` y `QA-023-19` retirados, el SKIP de `CA-12 (ii)` probado legítimo con tres ramas vivas, y `SEC-079` listo para firma
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: `qa-tester` (Opus) · consolidación: coordinadora. **Bajo delegación de 24 h.**

**`QA: aprobado` sobre `b5a29d9`.** Banco local **988 PASS · 0 FAIL · 8 SKIP** (996 casos, sin descuadre),
tres quality gates OK, y **CI `hooks-en-linux` en PASS** sobre `b5a29d9`.

**Los dos hallazgos se retiran, medidos.** La titular lleva su condición dentro y **juzgada aislada es
verdadera**; el barrido de `(iii)` sobre las **8** oraciones no encuentra ninguna que prometa sin
condición. Y el **control negativo discrimina cuatro candidatas**: `89440e9` (`721abd51`) incumple,
+«no exhaustivas» incumple, `1154417` (`1f4384ed`) incumple **por su titular**, y `b5a29d9`
(`3ead3bd3`) cumple. Detalle que importa: el delta `1154417`→`b5a29d9` es **aditivo** —8 oraciones antes
y 8 después—, así que **ninguno de los dos defectos se arregló borrando la oración incómoda**.

`QA-023-19` reproducido entero: fragmento **165 B** / `596a237f`, **2+2+1** apariciones, **0** restos
viejos en las tres sedes, sedes idénticas (`3ead3bd3`, 2545 B). Y el punto **(v) ejecutando la puerta**:
las tres entradas dan **DENY** con su byte imprimible y el texto **deriva DENY para las tres en las dos
apariciones**; la oración 6 también es verdadera medida — el homóglifo da **allow**.

**Y coincide con el analista sobre «fragmento, no oración», por razón medible:** «frases equivalentes»
admite cualquier **paráfrasis**, y una paráfrasis es **exactamente** lo que causó `QA-023-19`. La apódosis
libre no afloja porque el mecanismo vive en la prótasis y la consecuencia la clava `(v)`.

**El SKIP de `CA-12 (ii)` es legítimo, y lo prueba con las tres ramas vivas** — que era la pregunta que
importaba, porque un SKIP que sustituye a un rojo es la forma que tomaría un atajo:

| Corrida | Cuerpos | Conteos | Veredicto |
|---|---|---|---|
| `b5a29d9` contra `v1.33.0` | difieren | 2 de 7 movidas | **SKIP** |
| `v1.33.0` contra sí mismo | idénticos | 7 de 7 iguales | **PASS** |
| **sintético** (`v1.33.0` + redefinición **fuera** del cuerpo) | **idénticos** | **7 de 7 movidas** | **FAIL** |

La enumeración de llamadas la comprobó **mecánicamente** completa (único token `arnes_*` del cuerpo:
`arnes_lee_archivo`, idéntico `e9fedaa8`/408 B), las huellas reproducen, y el SKIP es **determinista**:
byte a byte igual en su corrida y en el CI.

**Un detalle mecánico que sólo se ve mirando el código de la puerta:** puso `QA: aprobado` porque
`hooks/guard-completado.sh:274` **deniega `Seguridad: aprobado` si `QA != aprobado`** — dejarlo en
`con-hallazgos` habría **bloqueado al auditor**. No cerró `SEC-079`, no firmó `Seguridad:` y no tocó
`Estado:`.

**Y corrigió su propio instrumento a mitad de camino, dejándolo escrito:** su primera tanda de falsación
corrió en un proyecto sintético **sin `hooks/`**, así que las quality gates fallaban y **todo** salía
`deny` **por un motivo ajeno** — un falso «la puerta cierra». Repobló y repitió todo. Es el mismo modo de
fallo que este proyecto persigue, cazado por quien lo estaba cometiendo.

**Hallazgo nuevo — `QA-023-22` (`instrumento`, dueño `desarrollador`):** la precondición **fija a mano** la
lista que compara (`for fn93 in arnes_cola_pendientes arnes_lee_archivo`, `39-…-3:282`) en vez de
**derivarla**; una llamada nueva daría **PASS** sin comparar el tercer cuerpo. Es `instrumento` y no
`contrato` porque el REQ dice «hoy sólo `arnes_lee_archivo`» y **hoy es verdad**, comprobado. Forzador que
se arma solo; vencimiento propuesto 1.35.0.

**Aviso de la coordinadora, y es material:** la puerta requerida está verde sobre **`b5a29d9`**, **no**
sobre `48b7808`. QA verificó que `48b7808` no toca las tres sedes, `hooks/`, `tools/` ni la sección 39/3,
pero **el CI tendrá que volver a correr**. `CA-09 (iii)` sigue **sin acreditar** (`SEC-080`).

## [Interno] — 2026-09-09 · Mi diagnóstico de `k=1` era falso en su mecanismo: el estadístico nunca estuvo apagado
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` · consolidación y corrección: coordinadora. **Bajo delegación de 24 h.**


**Corrección de hecho, y es la segunda vez hoy que construyo una explicación correcta-en-la-medida y
falsa-en-el-mecanismo.** Escribí que «*con `k=1` no hay mínimo que tomar: el mínimo ES la única
muestra*». **Es falso, y está verificado por mí:** `tests/util/sonda-reloj.sh` tiene **dos** parámetros
—`--k` son las repeticiones **dentro** de una serie (`sr_serie:347`) y `--r` son las **series**, que es
sobre lo que se toma el mínimo (`sr_minimo:381`)— y `mide37` pasa **`--r 3` FIJO** en todas sus llamadas
(`37/2:163`). Así que el fail-before con `k=1` **sí** toma el mínimo de **3** muestras, **las mismas que
la medición directa con `k=20`**. **El estadístico nunca estuvo apagado.** La medición de `D6`
(3,379× → 2,329×) sigue siendo correcta; la explicación que construí encima, no.

**El mecanismo real, medido con round-robin controlado (N=5, `loadavg` publicado fila a fila):** los dos
términos del cociente se miden en **dos invocaciones distintas, dos procesos y dos instantes**, así que
la dispersión la domina **cuál de las dos pilló al vecino**. Y de ahí lo importante: **subir `k` o `r`
alarga cada invocación, las separa MÁS en el tiempo y EMPEORA.**

| configuración | rango, carga 17,6–23,3 | rango, carga baja | coste |
|---|---|---|---|
| `k=1 r=3` (la de hoy) | 64,4 % (mín **2,879×**) | 13,3 % | 1,5–4,6 s |
| `k=1 r=15` | 52,8 % | — | 21 s |
| `k=2 r=9` | 23,9 % | — | 26 s |
| `k=3 r=9` | — | **66,0 %** | 13 s |
| `k=8 r=3` | 50,0 % | — | 31 s |
| **intercalado `k=2/3 r=9`** | **18,4 %** | **9,4 %** | 13–23 s |

**Y lo que hizo el `desarrollador` es exactamente lo que se le pidió y merece quedar escrito:** declaró su
criterio **antes de medir** (escalera fija, variable de decisión = suelo + dispersión, **nunca** el
cociente), el criterio seleccionó **`k=3`**, **midió esa configuración, salió peor, y NO la envió** —
«*enviarla habría sido enviar una regresión medida*». No subió la `k`. Eso es lo contrario de repetir
hasta obtener verde.

**Lo que sí entregó:** el caso ahora **publica** `k`, las series y, de cada término, su **mínimo y su
máximo**, y tiene **un solo nombre** en sus cinco ramas — antes cada rama nombraba un caso distinto, así
que un PASS→FAIL se leía como un caso que desaparece y otro que nace. Eso es lo que impidió atribuir el
rojo la primera vez.

**El remedio medido es el modo INTERCALADO, y no es alcance nuevo: ya está implementado y ya está
contratado.** `sr_intercala` existe en `tests/util/sonda-reloj.sh:399` y su propio comentario cita
**`REQ-021 CA-02` punto 2** —«*con DOS sujetos las series van a, b, a, b, … dentro*»—, con su motivo
medido en `QA-017-06`: **1,217 en bloque contra 1,012 intercalado**, que es **exactamente** nuestro modo
de fallo. Fue la **única** configuración más estrecha en **las dos** cargas y además **más barata** que su
equivalente en bloque.

**Decisión tomada bajo la delegación de 24 h:** se adopta el **modo intercalado** para `CA-03`, **en sus
dos mediciones** —la directa y el fail-before—, porque mover sólo una rompería la coherencia de «el
**mismo** cociente» que el fail-before acredita. **No relaja nada:** el techo sigue en 2,600×, no se
retira ninguna prueba, y la práctica ya la contrata `REQ-021 CA-02`. Cambia **qué instrumento** mide, así
que el orden es **`analista-requerimientos`** (precisar el modo en `CA-03`) → **`desarrollador`** (~20
líneas) → **`qa-tester`** → **CI**.

**Lo que sigue sin certificar, y lo digo yo, no el agente:** **esta máquina no es el juez y nadie puede
afirmar hoy que el CI se ponga verde.** El `2,329×` no se reproduce aquí ni con 12 quemadores; lo que se
reproduce es la **anchura** que lo hace posible. El CI corre con `ARNES_JOBS=6` sobre 4 vCPU, varias
secciones midiendo a la vez. **El intercalado es el remedio con mejor evidencia, no una garantía.**

**Evidencia salvada al repositorio** (era efímera, en scratchpad): **29 archivos** en
`docs/arnes/req-017-ca-03-modo-de-medicion/`, con el criterio declarado antes de medir, las cinco tablas
de medidas, las cinco corridas, los inventarios y los guiones de sonda. Las cifras que deciden quedan
además dentro del comentario del propio archivo del caso.

**A la cola, no abiertos aquí:** `razon37` tiene la **misma** carencia de publicación —da los dos mínimos
y no los máximos— y afecta a **5 casos más**; se dejó intacto a propósito.

## [Interno] — 2026-09-09 · El FAIL desaparece por DECLARACIÓN: la precondición de `CA-12 (ii)` dice que no puede atribuir, y lo publica con huellas
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` · consolidación: coordinadora. **Bajo delegación de decisión del propietario por 24 h.**

**Sección 39 aislada: 39 PASS · 0 FAIL · 3 SKIP.** El único FAIL del banco se fue **por declaración y no
por relajación**, que es la diferencia entera entre este arreglo y el que no se hizo.

**`CA-12 (ii)` da SKIP porque la precondición de atribuibilidad NO se cumple, y está medido con huellas:**
el cuerpo de `arnes_cola_pendientes` difiere entre este árbol (`a060be56`, 3883 B, 72 líneas) y `v1.33.0`
(`008683e6`, 1103 B, 28 líneas), mientras `arnes_lee_archivo` —su **única** llamada externa, **enumerada
y no supuesta**— es **idéntico** (`e9fedaa8`, 408 B en las dos). Confirma midiendo lo que el analista
había derivado leyendo `119e853`.

Y el SKIP **publica lo que cambió, elemento por elemento**: `rango-sin-cerrar` (`0|rc=0` → `|rc=1`,
`REQ-024 CA-08`) y `cierre-huerfano` (`0|rc=0` → `1|rc=0`, `REQ-024 CA-09`) — las **2 de 7** formas que
el comentario del caso ya nombraba. Un instrumento que dice **cuándo no puede medir y por qué** vale más
que uno que da un número.

**`QA-023-19` se queda sin sede.** El fragmento del mecanismo queda **byte a byte idéntico** —165 B,
`md5` corto `596a237f`— en sus **2 apariciones por sede** (oraciones 3 y 5) y en la skill, con **0**
restos de la redacción vieja. Las dos sedes siguen idénticas entre sí, con huella recalculada
**`3ead3bd3…` / 2545 B**: `02756e87…` deja de ser la referencia.

**La skill también queda verdadera leída sola**, con la acotación **dentro de la misma oración** —«*dentro
de lo que la guarda alcanza, que no es toda la clase: la vía del homóglifo de arriba PERMITE, y permite
por ausencia del campo que el homóglifo borró*»— y el fragmento literalmente igual que en las filas. Era
el artefacto que migra a los proyectos, así que es donde más importaba.

**`CA-10 (v)` ejecutando la puerta real:** BOM, blanco borrado y NBSP interno → **DENY** por medibilidad
(«algo INSERTADO DENTRO DE LA CLAVE») **incluso con todos los veredictos en verde**; homóglifo →
**ALLOW**. Y los controles **discriminan por motivo**: clave limpia con `QA: pendiente` deniega **por el
veredicto**, no por medibilidad, y clave limpia en verde permite.

**Dos decisiones que el `desarrollador` declaró en vez de callar:** re-derivó
`PISO_AUTONOMO_SECCION` de 181 a **232** porque el bloque indivisible de `CA-12` creció —y de paso
corrigió los rangos de línea de los otros dos términos, que ya estaban desfasados—, con el archivo en 360
líneas contra techo 400 y las seis de `CA-18` en verde; y dejó dicho que **la preferencia de sesión por
editar en consola cedió** ante `AGENTS.md` §13, porque preferir la consola ahí habría apagado una puerta.

**No corrió el banco entero, y lo argumentó:** hay otra comisión con la sección 37 a medio editar, y «*un
banco completo sobre un árbol con edición ajena viva no mide lo que dice medir*». Correcto.

`SEC-079`, `QA-023-18` y `QA-023-19` **siguen abiertos**: falta `qa-tester` y después
`auditor-seguridad`. `Estado:` sigue `bloqueado`.

## [Interno] — 2026-09-09 · `CA-12 (ii)` queda anclada con una precondición que la degrada declarándolo, y la oración 5 no sólo difería en letra: incumplía (v)
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: `analista-requerimientos` · consolidación: coordinadora. **Bajo delegación de decisión del propietario por 24 h (2026-09-09).**

**(1) `CA-12 (ii)`: se contrata la lectura ANCLADA contra el tag `v1.33.0` materializado, con una
precondición que es la parte buena.** Antes de comparar conteos, el caso comprobará que **el cuerpo de
`arnes_cola_pendientes` y el de cualquier función que ese cuerpo llame** (hoy sólo `arnes_lee_archivo`) es
**byte a byte el mismo** en las dos versiones. Si es idéntico, cualquier diferencia de conteo o `rc` es
**FAIL contra el código**. Si difiere, la comparación **no puede atribuir** y el caso emite **SKIP con su
motivo —nunca PASS y nunca FAIL—**, publicando qué difiere y qué formas cambiaron, elemento por elemento.

**Por qué anclada y no abierta:** la abierta dice «hoy cuento igual que aquella versión», y **el proyecto
ya decidió que eso es falso** — `REQ-024 CA-08`/`CA-09` cambian conteo y `rc` de esas dos formas **a
propósito**, y `ADR-010` los declara defectos que `REQ-024` sí arregla «sin tocar el grano». Hacerla
satisfacible exigiría **perseguir las expectativas de otro REQ dentro de un criterio ajeno**, que es la
coartada que `requirements/README.md` § «Y el reverso» prohíbe, y dejaría de proteger nada. La anclada
protege lo único que este REQ **puede** afirmar: «yo no moví el conteo que `REQ-009` contrata».

**Y la consecuencia medida, leyendo `119e853` sin ejecutar:** `hooks/lib.sh` ya lleva el cambio de
`REQ-024` **dentro** del cuerpo, así que **la precondición habría dado SKIP en este árbol**. El caso **se
degrada solo, declarándolo** — no se retira y no se relaja—, y la propiedad sigue cubierta por
construcción. Es la diferencia entre un rojo que se esquiva y un instrumento que dice cuándo no puede medir.

**La cláusula de `CA-12` se disparó contra sí misma:** decía «si sale abierto es un hallazgo `contrato`
contra este REQ», y salió abierto. Queda **registrado y vivo** en § «Conflictos registrados».

**(2) Punto 1 de `CA-10`: salida (a), y el hallazgo dentro del hallazgo.** La oración 5 no sólo difería en
letra del fragmento de la oración 3: **incumplía (v)**. De «*y sus blancos, si lo que queda **es** una
clave del lector*» —sin «leída también sin sus blancos»— un lector deriva que ante el **blanco borrado**
(`Sensibleaseguridad`) la guarda **calla**, y la máquina **deniega**. O sea que `QA-023-19` estaba
**sobreviviendo en la segunda aparición**, y el residual que el transcriptor nombró sin cerrar era más
grave de lo que parecía.

**Y la precisión que lo vuelve satisfacible:** la unidad de identidad pasa a ser **el fragmento** —la
prótasis, marcado incluido—, byte a byte en todas sus apariciones, **con la apódosis libre**. Exigir «la
misma frase» donde las apódosis difieren sólo se cumplía **borrando** una de las dos apariciones, que es
justo lo que no se quiere. No relaja: la identidad del fragmento es **más estrecha** que «frases
equivalentes», y el fondo lo sigue cerrando **(v)**.

**(3) Enrutado por la coordinadora: la skill lleva los DOS defectos.** El analista lo observó y no lo
actuó por ámbito; verificado por mí en `skills/arnes-upgrade/SKILL.md:820-824`, que contiene **la promesa
absoluta** («*la puerta **deniega** … **nunca** permite por *ausencia* del campo que ese carácter
borró*») **y** la redacción vieja del mecanismo («*y sus blancos, si lo que queda **es** una clave del
lector*»). Es `QA-023-18` y `QA-023-19` **en el artefacto que migra a los proyectos**, y `CA-10` lo nombra
entre sus sedes. Entra en la comisión de transcripción. **Queda además una observación para el analista:**
`CA-10` **no** somete hoy la skill al test de la titular aislada, y por ahí el defecto pudo sobrevivir.

Las dos decisiones son **menores, sin ADR**, con su «qué lo volvería de fondo» escrito. `SEC-079`,
`QA-023-18` y `QA-023-19` **siguen abiertos**: falta `desarrollador` → `qa-tester` → `auditor-seguridad`.

## [Interno] — 2026-09-09 · `REQ-024` implementado (9 de 11) y las dos filas de `SEC-079` transcritas, con dos residuales que ninguno de los dos agentes quiso cerrar solo
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agentes: `desarrollador` (`REQ-024`) y `desarrollador` (transcripción) · consolidación: coordinadora. **Bajo delegación de decisión del propietario por 24 h (2026-09-09).**

### `REQ-024` — 9 de 11 criterios, con sus pruebas

Banco **988 PASS · 1 FAIL · 7 SKIP**, cuadre **996** (de 966: **30 casos nuevos**). Autoprueba 106 · 0.
Tres quality gates verdes. Fail-before/pass-after de las tres secciones contra `v1.33.0`: **44 PASS · 9
FAIL · 2 SKIP** antes, **55 · 0 · 0** después.

**La tensión de fondo se resolvió midiendo, no eligiendo.** `CA-02` (sitio único) contra `CA-03 (i)`: el
dato que decide es que `hooks/lib.sh` lo cargan **siete** puntos de entrada y sólo uno es la puerta; tres
de ellos resuelven la ausencia al derivar el rigor. Una tabla en `guard-completado.sh` sería **invisible
para los otros seis**, y el informe diría `estandar` donde la puerta dice `critico`. Sitio único =
`hooks/lib.sh`, y `CA-03` sale por su salida **(ii)**.

**`CA-01` reproduce la medición del auditor sin heredarla:** M = 6 claves, **N = 4 contra `v1.33.0`** y
**0 en esta versión** — coincide con `R-013` §2. Y **`CA-03` reproduce `SEC-050`**: el puntero no encuentra
**2 de 4**, justo los que retiran el suelo y el nivel.

**Coste (`CA-07`):** 0 procesos añadidos (2 vs 2 en la puerta, 5 vs 5 en la parada), ruta crítica
**1,077×** contra techo 1,25×, duplicación **1,860×** (MAD 0,010) y **1,994×** (MAD 0,022). **Estadístico:
mediana de 5 tomas + MAD, no el rango** — el `desarrollador` aplicó por su cuenta la lección de `QA-023-12`.

**La llave `campos.ausencia_exige` queda en `false`.** Encenderla es política, no implementación, y toca
`.arnes/config.json`, que §6 declara **gate humano**: queda como decisión del propietario, no ejecutada.

**No escribió el caso de banco de `REQ-023 CA-10`**, por la instrucción de secuencia: su redacción de
referencia estaba cambiando.

### El único FAIL es un `contrato` contra `REQ-023`, y el REQ-024 lo había predicho

`REQ-023 CA-12 2 de 7 formas de la cola cambiaron de conteo o de rc`. El caso de `CA-12 (ii)`
(`39-…-3-los-lectores-y-el-coste.sh:284-297`) compara el **árbol actual** contra `v1.33.0` —la afirmación
**abierta**—, mientras su propio comentario (`:230-233`) y el criterio vigente contratan una no-regresión
**anclada a esa versión**. Las 2 formas son exactamente las dos que ese comentario nombra. **El
`desarrollador` no lo resolvió**, y explicó por qué: `REQ-023` está `bloqueado`, su caso lleva firma de QA
sobre ese árbol, y elegir entre «anclada» y «abierta» sería decidir una pregunta de contrato ajena.

### Las dos filas de `SEC-079`, transcritas

`md5 02756e87…`, **2494 B**, `cmp` idénticas, **1/1** por sede. La titular ya lleva su condición **dentro
de la propia oración**. El transcriptor hizo el barrido que `CA-10 (iii)` ahora exige —**8 oraciones,
la 1 juzgada aislada**— y el punto **(v)** ejecutando la puerta en un worktree sobre `8754d98`: BOM,
blanco borrado y NBSP interno dan **DENY** con su motivo citado; el homóglifo da **ALLOW**; y el control
latino idéntico da **DENY**, así que **la única diferencia que decide es la `а` cirílica**.

**Y nombró un residual en vez de cerrarlo por su cuenta**, que es la conducta correcta: `CA-10` punto 1
exige que si el mecanismo aparece dos veces en la celda sean «**literalmente la misma frase**», y tras el
cambio las oraciones 3 y 5 son **equivalentes en contenido pero no idénticas en letra**. Unificarlas
exigía **redactar**, que es del analista y su comisión se lo prohibía. **`QA-023-19` puede quedar abierto
por la letra del punto 1 aunque su defecto de fondo esté corregido.**

### Deudas enrutadas y desviaciones declaradas

`REGHER94` **hecho** en `39-…-4`, y el mismo defecto **existe en tres sitios más** (`39-…-2:100`,
`39-…-3:96`, `39-…-5:105`), preexistentes y de `REQ-023`. **Desviación declarada:**
`hooks/estado-derivado.sh` recibió **un renglón** y no estaba en `Archivos:` — sin él el bloque derivado
publicaría `estandar` donde la puerta dice `critico`. **`40-ausencia-que-abre-2` está en 400 líneas, su
techo exacto**: quien añada un caso ahí **parte** la sección, y hay aviso en su preámbulo.

**`CA-04` y `CA-06` de `REQ-024` NO se tocan ni se acreditan**: exigen la superficie heredada que estaba
reservada para `SEC-079`. Los dos ADR nuevos (`ADR-009`, `ADR-010`) quedan en **`propuesta`**.

## [Interno] — 2026-09-09 · El write-back que convierte el error de verificación de la coordinadora en una guarda del criterio
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: `analista-requerimientos` · consolidación: coordinadora. **Bajo delegación de decisión del propietario por 24 h (2026-09-09).**

Segundo pase de write-back sobre `CA-10`, para `QA-023-18` y `QA-023-19`. Un solo archivo tocado:
`requirements/REQ-023.md`.

**Lo mejor del pase no es lo que arregla, sino lo que impide que vuelva.** «Cómo se comprueba» gana un
apartado de **cómo NO se comprueba**, y cita el fallo real: *el `grep` de la cadena dio 0 sobre una fila
que seguía prometiendo*. Ése fue el error de la coordinadora —verificar una **cadena** en vez de una
**propiedad**— y ahora es una **anti-forma escrita en el criterio**. El barrido de `(iii)` pasa a ser
**enumerativo obligatorio**: oraciones numeradas y **la 1 juzgada aislada**. Además entra un punto **(v)**:
la descripción se comprueba **ejecutando** —las tres entradas dan DENY, así que el texto tiene que derivar
DENY para las tres—, y una **cuarta candidata** al control negativo: la fila de `1154417` **también
incumple**, por su titular.

**`QA-023-18`:** el `Entonces` de `CA-10` pasa de «*no deja cerrar*» a «*no deja cerrar **dentro de lo que
la guarda alcanza, acotado en la propia celda***», y la exigencia de «ninguna frase» gana **dónde**: «*la
PRIMERA —la oración titular— se juzga AISLADA del resto de la celda y tiene que ser verdadera leída
sola*». Eso cierra exactamente la puerta que el `qa-tester` había dejado como **condición** de su veredicto
de «honesto, no coartada».

**`QA-023-19`:** el mecanismo se reescribe **como el código lo hace** —«*retirado lo ajeno **y después
todos sus blancos**… clave **leída también sin sus blancos**»—, con el motivo correcto del silencio (lo
retirado **sustituía una letra**, y reponer *qué* letra exigiría **elegir entre candidatos**). Y se añade
el **sitio único de la conducta** (`hooks/lib.sh`, `_arnes_clave_oculta`) con una regla que vale para todo
el proyecto: **si el texto y el código divergen, el equivocado es el texto**. Más «una sola descripción por
celda»: si el mecanismo aparece dos veces, las dos han de ser **literalmente la misma frase**.

**Y el punto 4 nombra los dos casos que incumplen**, para que no haya que deducirlos: (a) acotación
completa **con titular absoluta**; (b) describir un mecanismo que el código no hace **aunque describa
menos**.

**Las dos entradas del Historial que repetían la descripción falsa NO se reescriben:** quedan **anotadas
en su sitio** con la corrección fechada y su causa, conservando la letra original como rastro. Es la forma
correcta —un historial que se corrige encima deja de ser historial— y conviene que quede dicha.

**Clasificación: menor, sin ADR.** No cambia alcance (12 criterios siguen siendo 12), ni la decisión base,
ni el rigor, ni ningún techo, ni lo que la puerta hace. Corrige **dónde** va una condición que el criterio
ya contrataba y **alinea una descripción con el código** en la dirección que `requirements/README.md` §
«Cuando el código cubre MÁS de lo que el criterio promete» manda arreglar en el mismo cambio que lo
descubre. Lo volvería de fondo: meter el homóglifo en esta ventana, mover el reparto blanco/letra, o
cambiar `hooks/` para que reponga y colapse.

`SEC-079`, `QA-023-18` y `QA-023-19` **siguen abiertos**: faltan `desarrollador` → `qa-tester` →
`auditor-seguridad`. `CA-09 (iii)` sin acreditar; `SEC-078`, `SEC-080`, `QA-023-20` y `QA-023-21` con sus
dueños.

## [Interno] — 2026-09-09 · La promesa absoluta no se había borrado: sobrevivía en la oración titular, y la coordinadora había verificado una cadena en vez de una propiedad
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: `qa-tester` (Opus, revisión acotada al cambio) · consolidación: coordinadora.

**`QA: con-hallazgos` sobre `1154417`**, validado en `git worktree --detach` con el padre `89440e9` como
línea base A/B — la forma correcta, porque el árbol de trabajo tiene trabajo vivo de `REQ-024`.

**El hallazgo que más enseña, y va contra la coordinadora: `QA-023-18` (`contrato`).** La promesa absoluta
se borró de la **oración 2**, sí, pero **sigue palabra por palabra en la oración 1**, la titular: «*Una
línea de la cabecera que la máquina **no puede medir** no deja cerrar*», sin condición — mientras la
**oración 6 de la misma celda** dice que el homóglifo **permite**. La celda se contradice consigo misma.
Medido ejecutando la puerta: `Еstado: completado` → **ALLOW** con salida vacía, y
`Sensible а seguridad: sí` + `Rigor: ligero` → **ALLOW**.

**Y la lección es sobre cómo verifiqué yo.** Dije «la promesa absoluta está **borrada**» apoyándome en un
`grep` de la frase «*y **nunca** se permite por **ausencia***», que efectivamente da **0**. Pero eso
**comprueba una cadena, no una propiedad**: la promesa vivía en otra oración con otras palabras. Es
exactamente el modo de fallo que este proyecto persigue —confundir la forma con el estado— y lo cometí
verificando el arreglo de un hallazgo que era, precisamente, una promesa sin condición. El método de QA
—barrer la celda **oración a oración**, que es lo que el propio `CA-10 (iii)` prescribe— es el que sí
mide, y el mío no lo era.

**`QA-023-19` (`contrato`)**: `CA-10` punto 1, las dos filas y el Historial describen «*repuesto un blanco
en el sitio de la retirada y colapsados los repetidos*», y el código hace otra cosa
(`hooks/lib.sh:2005`): `limpio="${ajeno//[[:blank:]]/}"` — **retira TODOS los blancos**, como dice su
propio comentario. Divergen en tres entradas, entre ellas **el BOM que la propia fila nombra primero**, y
la celda se contradice con su oración 12, que sí lo describe bien. Describe **menos** cobertura de la que
hay, así que **no reabre ningún fail-open**.

**Y el control negativo funciona: discrimina de verdad.** QA construyó tres candidatas y las barrió oración
a oración: la fila anterior **incumple**; añadirle sólo «no exhaustivas» **sigue incumpliendo**; añadirle
además el puntero **también**; la fila nueva cumple en sus oraciones 2–3. Separa tres textos distintos —y
separa justo lo que el propietario quería separar—. **Pero el mismo barrido caza la fila nueva por su
oración 1**, que es el hallazgo de arriba. Un control negativo que también condena el arreglo es la mejor
prueba de que no es decorativo.

**Acotar la fila en vez de `CA-01` queda declarado HONESTO, con una condición.** `CA-01` es byte a byte
idéntico (`md5 4d0d1495…`), el incumplimiento sigue vivo y **contable** en `CA-11`, `CA-12 (iii)` (3/3) y
«Fuera de alcance» (9 ítems), y la fila ahora **publica** que la vía permite. **La condición:** mientras la
oración titular siga prometiendo sin condición, la fila conserva la única lectura que hace quien escanea la
columna «Invariante», y **por ahí «acotar la fila» sí se convertiría en la coartada**.

**El cambio de texto no mueve el banco, confirmado por QA por su vía:** cuadre **966** en las tres
corridas; el único efecto medible es el censo del corpus de `CA-04` (5336→5356 líneas con campo), que va
hacia el lado que **refuerza** la anti-vacuidad; y por construcción no puede mover un veredicto por la vía
de las filas porque **ninguna sección del banco las lee** — que es `QA-023-20`.

**Más evidencia para `D6`, y refuerza el diagnóstico de `k=1`:** el mismo caso del fail-before le dio a QA
**4,667×** sobre el padre y **3,562×** sobre este commit, mismos sujetos, dos corridas — junto a los
**3,379×** y **2,329×** del CI. Cuatro muestras de un sujeto **inmutable** entre 2,3 y 4,7: es el retrato
de una medición de una sola muestra, no de una máquina que cambió.

**Dos `instrumento` nuevos con dueño:** `QA-023-20` (ninguna sección del banco lee las dos filas) y
`QA-023-21` (la promesa absoluta sobrevive en el mensaje de la puerta, `guard-completado.sh:363` y `:392`).

`Hallazgos abiertos:` queda con **13** entradas, **todas con clase**. `Estado:` `bloqueado`, `Seguridad:`
intacto, **`SEC-079` no cerrado**. QA resolvió además la cuenta que el analista dejó abierta: **extendió su
veredicto a la cláusula nueva y no pasa**, conservando dentro del campo lo acreditado sobre `808f9ca`.

## [Interno] — 2026-09-09 · El rojo de la puerta requerida tiene causa concreta: el fail-before mide con `k=1` y apaga el estadístico que su criterio ordena
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: coordinadora (trabajo de coordinación, sin abrir comisión).

**El propietario rechazó la primera lectura y tenía razón:** «*Que `v1.32.1` sea inmutable no demuestra
que sólo cambió la máquina*». La comprobación que pidió encontró **una causa concreta**, y no es la máquina.

**Lo que NO cambió, medido:** entre las tres corridas del CI no cambiaron
`37-coste-del-escaner-2-las-razones.sh`, `run.sh`, `tests/escenarios/hooks/util`, `hooks/`, `tools/`,
`.arnes/config.json` ni `.github/` —`git diff --stat` vacío en los dos saltos—, y la **imagen del runner
fue `ubuntu-24.04` en las tres**. La entrada medida tampoco es un archivo del repositorio: es una cadena
**sintética** de 70 000 y 140 000 bytes, así que el crecimiento del corpus es irrelevante. **Límite
honesto:** «misma imagen» no es «mismo hardware», y la CPU o la vecindad de la máquina virtual no se
pueden verificar desde aquí.

**La causa: el fail-before mide con `k=1`.** `CA-03` contrata «*k tal que el **mínimo** de cada serie
supere 50 ms*» y «*por eso el estadístico es el **mínimo**, no la media*». El caso usa **k=20** en la
medición directa (`:202-203`) y **k=1** en el fail-before (`:213-214`), por un compromiso de coste que su
propio comentario declara: «*así el fail-before cuesta segundos en vez de medio minuto*». **Con `k=1` no
hay mínimo que tomar —el mínimo ES la única muestra—, así que la cancelación de ruido que el criterio
contrata está desactivada justo en ese caso.** Medido sobre el mismo árbol inmutable: **3,379×** (PASS) y
**2,329×** (FAIL) contra techo 2,600×. Dos muestras únicas a distinto lado del techo: es lo que `k=1`
predice, sin que haga falta que cambiara nada.

**Y la objeción del propietario sobre los dos PASS anteriores era la clave:** son evidencia de **esas dos
ejecuciones**, no garantía de reproducibilidad — y con `k=1` son **dos muestras únicas**. No acreditan que
la sonda discrimine de forma reproducible; acreditan que discriminó dos veces. Hacer el caso opcional
**hoy** congelaría como «acreditado» algo que **nunca se midió con el estadístico que el criterio exige**:
convertiría un defecto de medición en una exención permanente.

**Qué cobertura automática se perdería al hacerlo opcional:** la **única** prueba automática de que la
sonda de `CA-03` **discrimina**. Sin ella, el verde de la medición directa de cada PR queda
**inacreditado**, y nada detectaría una sonda que dejó de medir —un `mide37` devolviendo una constante, un
`LIB37` apuntando al archivo equivocado, un `arnes_sin_cita` renombrado o vaciado—.

**Recomendación, y NO es hacerlo opcional: subir la `k` del fail-before** hasta que el mínimo de cada
serie supere el suelo con holgura, y **publicar las k muestras**. Eso es **implementar `CA-03` tal como
está escrito**, no relajarlo: no cambia ningún umbral, no retira ninguna prueba, y no es repetir hasta
obtener verde — si con `k` suficiente el cociente **sigue** bajo 2,600×, entonces la sonda de verdad no
discrimina y **eso es el hallazgo**. Precio: los ~30 s de CI que el comentario quiso ahorrar. Puede **no
reabrir `REQ-017`**, porque `k` no está fijada por el criterio sino **constreñida** por él; si `k=1` ya
incumple esa constricción, es defecto del caso y no cambio de contrato — **esa lectura la decide el
propietario**.

**Cuándo sería obligatoria la acreditación y dónde su evidencia:** obligatoria al tocar la ruta de escaneo
de `hooks/lib.sh`, al tocar la sonda o su andamiaje, en el **commit de versión de cada release** antes del
tag, y cuando la medición directa se mueva más que su margen declarado; con el interruptor que ya existe
(`ARNES_COSTE_RUTA_CRITICA=1`, precedente de `CA-05`) **más un paso de CI que lo active por rutas
tocadas**. La evidencia, en el **Historial de `REQ-017`** —donde `CA-05 (i)`/`(ii)` ya acreditan el
suyo—, con la URL de la corrida, la `k` y **las k muestras**: un número sin su `k` y sin su dispersión es
lo que nos trajo aquí.

**`CA-03` NO se convierte en opt-in**: el propietario no lo autorizó y la comprobación desaconseja hacerlo
antes de arreglar la medición. El PR queda **sin fusionar**, que no detiene el trabajo independiente ni
invalida la corrección documental de `SEC-079`.

## [Interno] — 2026-09-09 · `SEC-079`: la promesa absoluta se BORRA, no se anota — y el control negativo lo hace comprobable
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos` (`CA-10`) y `desarrollador` (las dos filas) · verificación y consolidación: coordinadora.

**Las dos mitades de texto de `SEC-079`, hechas en ese orden.** El propietario autorizó la opción (a) con
un matiz que descartó la solución obvia: «*Añadir solamente «no exhaustiva» no basta si la promesa
principal sigue siendo absoluta*».

**El analista convirtió ese matiz en un criterio FALSABLE, y eso es lo mejor de este cambio.** `CA-10`
gana un bloque de cuatro puntos con **control negativo escrito**: la fila anterior incumple, **y
añadirle sólo «no exhaustivas» sigue incumpliendo**. Así el arreglo se puede **medir** en vez de opinar
sobre si suena suficiente. Y acotó la promesa **por la propiedad que decide la cobertura**: deniega
cuando, retirado lo ajeno al alfabeto, repuesto el blanco y colapsados los repetidos, **lo que queda es
una clave del lector**; si la reconstrucción **no** devuelve clave, la guarda **calla** y la puerta
resuelve por **ausencia**.

**Y evitó que el write-back fuera una coartada.** Acotó **la fila de §13** y **no `CA-01`**, con el
motivo escrito: un criterio dice cómo se quiere el mundo, una fila de §13 **describe lo que la máquina
hace hoy**. De modo que **`CA-01` sigue exigiendo DENY y el homóglifo sigue siendo incumplimiento
abierto** de esa exigencia. Relajar `CA-01` habría hecho desaparecer el problema por definición — lo que
`requirements/README.md` § «Y el reverso» prohíbe, y él lo nombró así.

**Las dos filas, medidas por el `desarrollador` y verificadas por la coordinadora:** `AGENTS.md:349` y
`templates/AGENTS.md.tpl:314` quedan **byte a byte idénticas** (md5 `1f4384ed…`, **2287 B**, `cmp` sin
diferencias), **una sola fila por archivo** —la anterior **sustituida**, no acompañada— y **1/1** de
delta en cada sede. La promesa absoluta vieja está **borrada**: `grep` de «*y **nunca** se permite por
**ausencia***» da **0** en las dos. Ése es el control negativo cumplido: una fila que sólo hubiera
añadido «no exhaustivas» conservaría esa cláusula y el `grep` la seguiría encontrando.

**Dos detalles del `desarrollador` que merecen quedar escritos:**
- **La `Е` del ejemplo es cirílica de verdad** (`d0 95` = U+0415, verificado en hexdump por él y por la
  coordinadora), no una `E` latina. Escribir *sobre* un homóglifo con el carácter equivocado habría
  dejado un ejemplo que no ejemplifica nada.
- **Cita el registro por ID y NO por número de línea** (`SEC-078`, `SEC-079`, `R-024`), porque **en el
  proyecto que nace del template esas líneas no existen**: el ancla estable es el identificador. Es
  exactamente la clase de detalle que distingue una plantilla que funciona de una que se hereda rota.
- Usó `Edit` y no `sed` **a propósito**, citando §13: la preferencia por consola **cede** cuando apagaría
  una puerta cableada a `Edit`/`Write`, y `requirements/REQ-023.md` la tiene.

**Commit SELECTIVO, y el motivo es coordinación real.** Hay un `desarrollador` trabajando en **`REQ-024`
ahora mismo**, con `hooks/lib.sh` (+192), `tools/arnes-lectura.sh` (+47), `hooks/guard-completado.sh`,
`hooks/estado-derivado.sh`, `.arnes/config.json` y su plantilla **a medio hacer**. Nada de eso entra
aquí. Y una precisión que pidió el propio `desarrollador` de las filas, que se respeta: de las ~137
inserciones de `requirements/REQ-023.md`, **una sola es suya** (su fila de Historial); el resto es el
write-back de `CA-10` del analista. Su `bash -n` en verde acredita **el árbol de trabajo del otro**, no
su cambio, que no toca shell — lo dijo él, y es la clase de precisión que hace utilizable una medición.

**`SEC-079` NO se cierra con esto**, por condición del propietario: se cierra **únicamente** tras
`qa-tester` y `auditor-seguridad`. Sigue en el campo `Hallazgos abiertos:`, con `SEC-078` y `SEC-080`
**abiertos** y con sus responsables. `Estado:` sigue `bloqueado`, `CA-09 (iii)` **sin acreditar**.

## [Interno] — 2026-09-09 · D5 autorizada, opción (a) — y el matiz del propietario descarta la solución obvia
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: coordinadora (registro de la decisión y despacho de la cadena).

El propietario autoriza corregir `CA-10` y las dos filas heredadas para que **describan la cobertura
real**, manteniendo **fuera de esta ventana** la vía del homóglifo ya declarada. Y añade el matiz que
convierte esto en un arreglo de verdad y no en un parche:

> «*La redacción debe nombrar explícitamente esa limitación y enlazar su evidencia en el registro.
> **Añadir solamente «no exhaustiva» no basta si la promesa principal sigue siendo absoluta.***»

**Eso descarta la salida obvia**, que era marcar la lista de tres fronteras como «no exhaustiva» y dejar
intacta la promesa. Lo que tiene que cambiar es la **promesa principal**: la fila afirma la clase **por
estado y sin condición**, y eso es lo que `R-024` midió falso. La promesa nueva ha de ser **verdadera
tal como está escrita**, con la limitación **nombrada dentro** y su evidencia **enlazada** al registro
(`SEC-078`/`SEC-079`, revisión `R-024`).

**Condiciones que fija y quedan escritas en `D5`:** `SEC-078` y `SEC-080` **siguen abiertos** con sus
responsables; la autorización **no acepta riesgos nuevos** y **no acredita el criterio de rendimiento**
—`CA-09 (iii)` sigue sin acreditar—; la cadena es **analista → desarrollador → QA → auditor** con
**revisión acotada al cambio** y **reutilizando la evidencia que siga siendo válida**; y **`SEC-079` se
cierra únicamente tras esa validación**, no al escribir el texto.

**Coordinación con `REQ-024`, que corre en paralelo.** Por instrucción del propietario, **las pruebas de
`CA-10` deben comprobar la redacción corregida**, así que ese tramo va **en secuencia**: se avisó al
`desarrollador` de `REQ-024` de que **no escriba** el caso de banco de `CA-10` —lo habría escrito contra
un texto que va a cambiar— y de que la reserva de `AGENTS.md`, `templates/AGENTS.md.tpl` y
`skills/arnes-upgrade/SKILL.md` sigue firme, ahora con dos comisiones comprometidas sobre esa
superficie. **El resto de su encargo no se pausa**: `hooks/`, `tools/`, las dos secciones `40-*`,
`run.sh`, el manifiesto y su plantilla siguen siendo suyos, y `REGHER94` también, porque no depende de
ninguna redacción. Reparto por **escrituras reales**: el analista sólo toca `requirements/REQ-023.md`,
así que no colisiona con él.

`D5` pasa a «Resueltas» con la decisión y sus condiciones. La cola baja de **4 a 3**.

## [Interno] — 2026-09-09 · Primera auditoría de la guarda (R-024): el REQ se disparó su propio forzador, y el rango que le dio la coordinadora no contenía el mecanismo
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: `auditor-seguridad` (Opus) · consolidación: coordinadora.

**Veredicto: `Seguridad: con-hallazgos` (R-024).** Acredita **la revisión de seguridad de la guarda de
medibilidad** —que no abre nada que antes cerrara, que la duda va al lado que cierra, que no hay
inyección ni fail-open por entorno, que ningún control aprobado se retiró y que **dos se refuerzan**— y
**no** acredita el banco, las quality gates, `CA-09` ni el fail-before de `CA-08`.

**Un error de la coordinadora, corregido por el auditor y anotado aquí porque es instructivo.** Se le
dio el rango `5305de9..390a0a2`, y `git diff --stat` de ese rango sobre `hooks/` y `tools/` sale
**VACÍO**: la guarda vive en `e406202` y en el WIP `29b06eb`, los dos **anteriores**. Con
`Seguridad: pendiente`, eso significa que **nadie la había auditado nunca**. El auditor amplió por su
cuenta al delta real (`43bfd47..390a0a2`: **349 inserciones** en `lib.sh`, `guard-completado.sh` y
`arnes-lectura.sh`) y lo dijo: firmar sólo el rango recibido habría sido **una firma sin el mecanismo
dentro**. Un rango es un parámetro de la firma, y darlo mal la vacía.

**`SEC-079` (`contrato`, alta) BLOQUEA, y lo hace por máquina, no por prosa:** con los cuatro veredictos
en verde, `guard-completado` responde `deny :: el hallazgo 'sec-079' es de clase 'contrato' y bloquea el
cierre`. La fila heredada de `AGENTS.md` §13 y de `templates/AGENTS.md.tpl` promete la clase **por estado
y sin condición**, con una lista **cerrada** de tres fronteras que **no incluye la vía abierta** del
homóglifo. Medido ejecutando la puerta con su JSON real: `Sensible <U+0430> seguridad: sí` +
`Rigor: ligero` responde **ALLOW**, y eso **reproduce entera la fila 1 de `SEC-047`**. También abren
`Q<U+0430>: pendiente`, `Hallazg<U+043E>s abiertos: SEC-999 (contrato)` y `<U+0415>stado: completado`,
mientras el control limpio deniega.

**El defecto no es que la vía esté abierta —está declarada fuera de alcance con dueño y ventana— sino
que el documento canónico lo promete sin condición mientras sigue abierta. Y el forzador lo escribió
este REQ contra sí mismo:** «*que algún texto de este REQ o de la superficie heredada afirme sin
condición que la guarda cubre la clase … mientras esta vía siga abierta*». Se disparó solo, que es
exactamente para lo que se escriben los forzadores. Reparto justo: **la skill es honesta** —dice que
«ninguna versión lo deniega, tampoco 1.34.0»—; el que promete de más es el documento canónico, así que
el write-back es del **analista** sobre `CA-10`, no una culpa del `desarrollador`.

**Lo que el auditor acredita A FAVOR de la guarda, ejercitándola y no leyéndola:** la clase **no puede
fabricar** una clave del lector, sólo destruirla —lo que **justifica** su asimetría con la guarda del
CR—; el mapa de claves es **inambiguo por construcción**; `arnes_deny` usa `jq --arg`, así que un
`\xNN` no rompe el JSON; **`ARNES_CLAVES` es asignación incondicional**, así que el entorno no puede
vaciarla (lo miró porque vaciarla habría apagado a la vez la guarda y los cinco brazos de
`arnes_campos_req`); la clase de caracteres no contiene `-`, `]` ni `^`; y **cero falsos positivos**
sobre los 27 REQ reales. Y **dos controles quedan reforzados**: la clave del estado terminal ya está
cubierta, y el informe emite la anomalía **antes** del descarte «este archivo no tiene `Estado:`».

**`SEC-078`** (`instrumento`, alta): la vía del homóglifo reproduce `SEC-047` entero, y el puntero de la
skill —«clase abierta **con dueño en el registro**»— **no resolvía**: `grep 'homógl'` sobre el registro
daba **0**. La entrada nueva lo hace cierto. **`SEC-080`** (`instrumento`, media): un umbral de la puerta
requerida cuyo veredicto **lo decide el ruido de la máquina**, y cuya abstención sale con el **mismo
`rc`** que un verde; extiende `SEC-064` sin duplicarlo. Ninguno de los dos condiciona el cierre.

**Y una honestidad que conviene subrayar: el auditor NO se apropió del `957 · 0 · 9`.** Dice que es de
QA y de la coordinadora, y que es sobre `808f9ca` y no sobre `390a0a2` — verificando, eso sí, que
`808f9ca..390a0a2` no toca `hooks/`, `tools/`, `.github/`, `tests/` ni `.arnes/`, así que la cifra sigue
siendo aplicable «pero no es mía». Tampoco subió la clase de `QA-023-17`: coincide con `instrumento`
porque la guarda medida es lineal y hoy no hay daño.

**Escalado: `D5` en `PENDING_APPROVAL.md`** con las dos salidas —(a) barata y recomendada: cláusula de
lista «no exhaustiva» en `CA-10` que cite el sitio único, y luego la fila en las dos sedes, con el orden
analista → desarrollador → QA → auditor; (b) cara: meter el homóglifo en esta ventana, con sus tres
salidas ya medidas como malas—. La cola sube de **3 a 4**. La fila de `REQ-023` en `D2` queda con
`SEC-079`: es el **tercer relevo** del bloqueante, tras `QA-023-05` y `QA-023-15`, los dos cerrados.

## [Interno] — 2026-09-09 · CI en verde y `QA: aprobado`, con la distinción que lo hace honesto: la prueba está corregida y el criterio NO está acreditado
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: `qa-tester` (Opus, revalidación acotada) · verificación y consolidación: coordinadora.

**`hooks-en-linux` PASA sobre `808f9ca`** (run 34427423326, PR #45): **957 PASS · 0 FAIL · 9 SKIP**,
contra los 955 · 1 · 10 de `6ad9752`. **Cuadre 966 en las dos: nada se retiró.** La puerta requerida y
estricta de `main` deja de estar roja.

**Y aquí va la distinción que el propietario pidió expresamente, porque sin ella el verde miente:**

- **La prueba está CORREGIDA.** Mide la relación emparejada contra `v1.33.0` con sus cuatro parámetros
  publicados, y ya no la magnitud retirada.
- **El criterio NO está ACREDITADO.** `CA-09 (iii)` **abstiene en los dos sujetos en la máquina más
  limpia disponible**: `arnes_norm_clave` mediana 0,986 con margen **0,014** contra rango 0,229;
  `arnes_campo_linea` mediana 0,952 con margen **0,048** contra rango 0,055. Y el **1 PASS de 10**
  corridas locales era **flaky**: un rango que cayó bajo el margen por suerte.

**El FAIL anterior era un ROJO FALSO, y no se deduce: se mide.** El caso nuevo publica los absolutos
como control en la misma tanda, y la base heredada `v1.33.0` paga **2,571 · 2,519 · 2,642** en
`arnes_campo_linea` contra el techo retirado de 2,200×. O sea que el `2,365× > 2,200×` que puso rojo el
CI **condenaba una propiedad que el código heredado ya pagaba más caro**.

**`CA-10` validado y `QA-023-15` (`usuario/dinero`) RETIRADO — por sus dos brazos, no por el texto.**
Par por cláusulas reproducido con script propio: **7/26 → 26/26**, 19 voltean. Las dos filas byte a byte
idénticas (md5 `721abd51…`, 1274 B) y **una sola** por archivo: la del CR fue **sustituida**, no
acompañada, así que ningún documento dice dos cosas. El consumidor ahora **sí** se entera, y la fila que
su coordinadora lee **sí** describe lo que la máquina hace — comprobado **ejerciéndolo**: la puerta
deniega un **guion ASCII** insertado en la clave, que ninguna lista de invisibles contiene, mientras el
control limpio abre. El homóglifo cirílico lo ve el barrido y la puerta lo permite, **tal como el
apartado declara**. Y la completitud de versiones se comprobó sobre **los 41 tags publicados**, no sobre
la muestra de 7. **`QA-023-10` también cierra.**

**El hallazgo nuevo es del criterio y es estructural: `QA-023-17` (`instrumento`, dueño analista).**
`margen = 1,000 − mediana`, y **la mediana no es un parámetro de diseño**. La consecuencia es
incómoda y elegante: **el resultado ideal —que la guarda no añada nada, relación = 1,000— es exactamente
el inafirmable**, porque el margen se hace cero. Cuanto mejor se porta el código, menos acreditable es
el criterio. Con 0,986 haría falta reproducibilidad mejor del **1,4 %** sobre una relación de relaciones
que compone **cuatro** cronometrajes, o sea **< 0,7 %** por cronometraje.

**Y «más tomas» NO puede funcionar**, por una razón que estaba a la vista y nadie había mirado: el
estadístico de dispersión sigue siendo el **rango** (`disp=$(( hi - lo ))`), que es **monótono no
decreciente** — añadir tomas sólo puede ensancharlo. Sólo dos cosas lo mitigan: un **par mayor**, que
fabrica margen, y un **estadístico robusto**. La evidencia exacta que falta, con protocolo y números:
**par 2000→4000, `k`=600, 5 tomas, dispersión por IQR o MAD en vez del rango, corrido en el CI** (≈2-3
min de job).

**Las tres prohibiciones del propietario, medidas y respetadas:** techo `1000` por mil = **1,000×**;
nota de falsación intacta (`39-…-4-el-coste.sh:236-237`); `CASOS_ESPERADOS_SECCION=4` antes y ahora.
**Ninguna prueba retirada, ningún umbral movido.**

**Veredicto: `QA: aprobado` con residual declarado**, nombrando expresamente que `CA-09 (iii)` **no está
acreditado**. Se marca así porque el tope de vueltas está agotado y el residual **no es `usuario/dinero`
ni `contrato`**: los seis hallazgos vivos (`QA-023-11` a `-14`, `-16`, `-17`) son **todos
`instrumento`**. `QA-023-12` se mantiene y **baja de severidad alta a media**: su primera mitad sigue
viva (el rango sin tocar) y la segunda se disuelve, porque el rojo que «ocultaba» era falso.

**`REQ-023` NO se cierra**: sigue `bloqueado` por decisión del propietario y la cola está en **3**.
Siguiente paso: el `auditor-seguridad` en su turno, que ahora sí es su turno.

**Nota de instrumento anotada y no abierta como hallazgo:** el comando de extracción del barrido
documentado en §12.1 del `desarrollador` **no acota el apartado**, así que casa también el de «Hacia
1.32.1» y devuelve 168 líneas en vez de 53. El entregable es correcto; lo que no re-deriva es ese
comando de la nota.

## [Interno] — 2026-09-09 · Extensión acotada de REQ-023: CA-10 cumplido por estado y la prueba de CA-09 (iii) midiendo lo que el contrato pide
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (Opus, extensión excepcional) · verificación y consolidación: coordinadora.

Las tres cosas que el propietario autorizó, y **sólo** esas tres.

**`CA-10` cumplido, y la forma importa más que el hecho:** la fila de `AGENTS.md` §13 y la de
`templates/AGENTS.md.tpl` ya **no definen la invariante por el retorno de carro**. La enuncian **por
estado** —«una línea de la cabecera que la máquina **no puede medir** no deja cerrar»— con el CR como
**instancia**, las demás nombradas (BOM, anchura cero, control C0, multibyte partido, blanco de más o
puesto en el sitio de otro) y la clase cerrada **por reconstrucción de la clave, no por lista de
caracteres**. Verificado por la coordinadora: las dos filas son **byte a byte idénticas**. Y
`skills/arnes-upgrade/SKILL.md` gana el apartado de migración que faltaba, con la pregunta **por estado
antes de cualquier comando** y las tres declaraciones de `REQ-016 CA-09 (ii)` **en el mismo sitio que
el comando**, diciendo además **lo cierto hoy**: ningún comando responde esa pregunta, y el modo de
`tools/arnes-lectura.sh` que «Hacia 1.32.1» anunciaba para 1.33.0 **no llegó**.

**Par fail-before/pass-after de `CA-10`, por cláusulas: 7 de 26 en `v1.33.0` → 26 de 26 en este árbol**
(19 voltean). Y las dos vías del apartado se **midieron antes de escribirlas**: el barrido `awk` **no
ve** `QA-: aprobado` —guion ASCII que la puerta **sí** deniega— y sobre los 27 REQ saca 53 líneas, las
53 legítimas.

**La prueba de `CA-09 (iii)` deja de medir la magnitud retirada.** Ahora mide la **relación emparejada**
`cociente(candidata)/cociente(base)` dentro de cada toma, con las versiones intercaladas al nivel de
`n`, orden alternado **y publicado**, y los **cuatro** parámetros en la línea del veredicto —par, `k`,
forma y **línea base `v1.33.0`**—. Los cocientes absolutos pasan a **«CONTROL no acreditativo»**, que
es exactamente su nuevo papel. Dos precondiciones nuevas abstienen en vez de mentir: base no
materializable, y tag que no define el sujeto.

**Ningún umbral se movió y ninguna prueba se retiró**, que eran dos de las tres prohibiciones del
propietario. Verificado por la coordinadora: el techo de la relación es **1000 por mil = 1,000×**, y la
nota de falsación sigue escrita —«si las medianas emparejadas salieran 1,05, el techo seguiría siendo
1,000»—. El piso de la sección subió de 267 a 330 porque el archivo pasó de 327 a 388 líneas, y **no
para comprar techo**: 388 ya cabía bajo el 400 anterior.

**Resultado de la prueba: 10 veredictos en 5 corridas — 1 PASS · 9 SKIP · 0 FAIL**, con las diez
medianas de la relación en 1,000× o por debajo (0,883 a 1,000). Dispersión 0,053–0,112 aislada y hasta
0,889 con el banco entero. Banco **dos veces 960 PASS · 0 FAIL · 6 SKIP**, cuadre **966**; autoprueba
106 · 0; tres quality gates verdes. **El `desarrollador` NO afirma que el CI saldrá verde** —no lo
corrió— sólo que el caso ya no mide la magnitud retirada. Lo dirá el CI.

**Dos residuales anotados y no arreglados, los dos `instrumento`:** `CA-10` **no tiene caso de banco**,
porque añadirlo obliga a mover `CASOS_ESPERADOS` en `run.sh`, que está en el `Archivos:` de `REQ-024`
(`tools/arnes-paralelo.sh` responde `colisiona hooks/lib.sh`); y `REGHER94` nunca se asigna, así que los
SKIP de `(i)`/`(ii)` publican un paréntesis vacío en vez del registro. Los dos se enrutan con `REQ-024`.

## [GitHub] — 2026-09-09 · Extensión excepcional de REQ-023: la superficie heredada nombra la propiedad, y la prueba del coste deja de medir el techo retirado
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (Opus, extensión de alcance CERRADO autorizada por el propietario; **no** es una cuarta vuelta y **no** reinicia el contador).

**Las dos cosas que el propietario autorizó, y nada más.** `REQ-023` sigue `bloqueado`: no se firmó
`QA:` ni `Seguridad:`, no se movió `Estado:`, no se retiró ningún hallazgo —`QA-023-15` sigue
abierto—, no se eliminó ninguna prueba y **no se relajó ningún umbral**: el techo de la relación
sigue en `1,000×`, el de (ii) en `1,25×`, `k` en 200, el par en 1000→2000 y las tomas en 3.

**(1) `CA-10` — la invariante deja de definirse por el retorno de carro** (`QA-023-15`,
`usuario/dinero`). La fila de `AGENTS.md` §13 y **la misma fila** de `templates/AGENTS.md.tpl`
—idénticas byte a byte— pasan a enunciar la propiedad **por estado**: *una línea de la cabecera que
la máquina no puede medir no deja cerrar*, con el CR como **instancia** y no como definición, con
las otras instancias nombradas (BOM, anchura cero, control C0, multibyte partido, **blanco de más o
puesto en el sitio de otro**), con la frase de que la clase **no** se cierra por lista de caracteres
sino por **reconstrucción de la clave**, y con las **tres fronteras** intactas: CR/LF final =
transporte, el cuerpo del REQ no se restringe, **reabrir** no se bloquea. Por qué importaba y por
qué era `usuario/dinero`: el efecto **sale del repositorio** — un proyecto consumidor con su
`AGENTS.md` congelado no se enteraba de que pudo cerrar un REQ `critico` sin validación ni
auditoría, y ningún guardián cubre esos archivos.

**Y el apartado de migración de `skills/arnes-upgrade/SKILL.md`** («Hacia 1.34.0») dice **sin
eufemismo** que en una versión afectada *pudiste cerrar un REQ `critico` sin validación de QA y sin
auditoría de seguridad aprobada*; enuncia la pregunta **por estado** —«cuáles de tus REQ en estado
terminal NO cerrarían hoy»— **antes** de ofrecer ningún comando; y acompaña **cada** barrido por vía,
en el mismo sitio que el comando, de las tres declaraciones de `REQ-016 CA-09 (ii)`. **Dice lo que
es cierto hoy sobre los comandos, y eso incluye una promesa vencida:** ninguno responde la pregunta
por estado, el modo de `tools/arnes-lectura.sh` que lo haría sigue en «Fuera de alcance» de
`REQ-016` (`instrumento`, dueño `desarrollador`) y el apartado «Hacia 1.32.1» lo anunciaba para
1.33.0, que se publicó sin él. **Las dos vías se midieron antes de escribirlas** sobre seis
fixtures: el barrido `awk` **no ve** `QA-: aprobado` —un guion ASCII que la puerta **sí** deniega— y
**sí** nombra `Módulo:`, que es legítimo; sobre los 27 REQ de este árbol saca 53 líneas y las 53 son
legítimas. Ese es el material de las declaraciones, y por eso van con nombre y no como advertencia
genérica.

**(2) `CA-09 (iii)` — la prueba re-apuntada a la magnitud del contrato VIGENTE** (`QA-023-12`). El
caso seguía midiendo el **cociente absoluto** contra el **techo absoluto de 2,2**, la magnitud que
el write-back del 2026-09-09 retiró por estar medida insatisfacible **también para el código
heredado**. Ahora mide la **relación emparejada** `cociente(candidata)/cociente(base)` **dentro de
cada toma**, con las dos versiones **intercaladas al nivel de `n`** y el **orden alternado por toma
y publicado**, contra techo **1,000×** y con los **cuatro** parámetros en la misma línea del
veredicto: par, `k`, forma y **línea base `v1.33.0`** (el cuarto, nuevo — dos relaciones tomadas
contra bases distintas no son comparables). Los cocientes absolutos siguen publicándose etiquetados
**«CONTROL no acreditativo»**: sin ellos nadie rederiva la relación. **La dispersión que decide es
la de la serie contratada** —la de la relación—, no la de los absolutos, que es la confusión que el
criterio nombra. Y **dos precondiciones nuevas abstienen en vez de mentir:** si la línea base no se
materializa, SKIP con el registro del materializador (el cociente absoluto **no** la sustituye); y
si el tag **no define** el sujeto, SKIP diciendo eso — sin ella un sujeto ausente se cronometraría
como «orden no encontrada», caería bajo el suelo y el caso abstendría **citando el suelo en vez del
motivo verdadero**.

**Lo medido, con dispersión y sin promedios: diez veredictos de (iii) en cinco corridas — 1 PASS, 9
SKIP, 0 FAIL**, y **todas** las medianas de la relación en `1,000×` o por debajo (0,883 · 0,896 ·
0,911 · 0,916 · 0,929 · 0,950 · 0,960 · 0,976 · 0,983 · 1,000). Las corridas **aisladas** dan
dispersión 0,053–0,112; el **banco entero** —57 secciones a la vez— la infla hasta 0,889, y ahí se
ve por qué: una toma con base 1,505 es carga cayendo sobre el término corto. **Y la lección de las
nueve corridas anteriores sigue en pie: una abstención repetida no es un verde acumulado.** Lo único
acreditado es que **el caso no produce FAIL**; quién afirma el techo es el **CI**, y esta comisión
**no lo corrió** porque no comitea ni empuja.

**Puertas:** las tres quality gates en verde; `bash -n` sobre el corredor, su autoprueba y las 57
secciones, rc 0; autoprueba del corredor **106 PASS · 0 FAIL** (incluye la derivación de `CA-18`);
banco entero **dos veces**, **960 PASS · 0 FAIL · 6 SKIP**, cuadre **966** — los 6 SKIP van
enumerados uno por uno en la evidencia, y ninguno es nuevo. `CASOS_ESPERADOS_SECCION` sigue en 4 y
`CASOS_ESPERADOS` en 966: **no se creó ni se perdió ningún caso**. La sección pasa de 327 a 388
líneas y su `PISO_AUTONOMO_SECCION` de 267 a **330** (31 + 78 + 221, término a término); **el piso no
se sube para comprar techo**: 388 ya cabía bajo el techo anterior de 400.

**Y las dos limitaciones que van aquí y no en una nota al pie.** *(a)* **`CA-10` no tiene caso de
banco**: añadirlo obliga a mover `CASOS_ESPERADOS` en `tests/escenarios/hooks/run.sh`, que está en
el `Archivos:` de **`REQ-024`** (`arnes-paralelo.sh` responde `colisiona hooks/lib.sh`), así que el
par fail-before/pass-after se tomó con `grep` contra el tag —**7 de 26** cláusulas en `v1.33.0`
frente a **26 de 26** en este árbol, 19 volteadas— y queda **residual `instrumento`** con el
precedente de que sí se automatiza (`36-…-4-el-informe-y-los-textos.sh` ya lo hace para `REQ-016`).
*(b)* `arnes_norm_clave` **sigue sin resolverse por ninguna vía** (abstenía incluso en el CI con
dispersión 1,088×), y esta comisión no lo resuelve. Evidencia, método re-derivable y las cifras
elemento por elemento: `docs/qa/1.34.0-req023-vuelta3-metodo.md` §12, sobre `710e3e7`.

## [Interno] — 2026-09-09 · REQ-023 pasa a `bloqueado` por decisión del propietario, con una extensión excepcional de alcance cerrado
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: coordinadora (registro de la decisión).

El propietario resuelve `D1` sobre la recomendación de la vuelta 3 del `qa-tester`: **`REQ-023` queda
`bloqueado` mientras se corrige**, y **no** cierra con residual — porque `AGENTS.md` §6 no admite
residual sobre un `usuario/dinero` y `QA-023-15` es de esa clase.

**Autoriza una extensión excepcional limitada a tres cosas:** completar **`CA-10`**, corregir la prueba
de **`CA-09 (iii)`** *conforme al contrato vigente*, y consolidar el write-back pendiente en un commit
coherente. Después: **QA revalida lo afectado**, se ejecuta el **CI requerido** y **seguridad revisa
cuando corresponda**. Manda **conservar el registro de las tres vueltas agotadas**, y así queda: las
tres se nombran una por una en la fila de Historial y el campo `QA:` sigue declarando «vuelta 3 de 3
—la última—». **La extensión no reabre ni reinicia el contador.**

**Y las tres cosas que NO autoriza, escritas porque son exactamente lo que una prisa convertiría en
atajo:** cerrar con `QA-023-15` abierto, eliminar pruebas, y **relajar umbrales para obtener verde**.
Esa última importa de forma concreta: el rojo del CI viene de un techo absoluto que está medido
insatisfacible **también para el código heredado** (la base `v1.33.0` paga **2,446** contra el **2,365**
que el CI marca), así que la tentación no sería subir el techo por pereza sino por un argumento que
suena razonable. No se hace: lo que el contrato vigente pide es **re-apuntar la prueba a la relación
emparejada**, cuyo techo es `1,00×` y cuya medida es `0,856×` y `0,906×`.

`D1` pasa a «Resueltas» con la decisión y sus tres prohibiciones; la cola baja de **4 a 3** y sigue
impidiendo cerrar cualquier REQ. La fila de `REQ-023` en `D2` queda con el hallazgo vigente,
`QA-023-15`, y no con el ya cerrado `QA-023-05`.

## [Interno] — 2026-09-09 · La abstención ocultó un rojo real durante nueve corridas, y el bloqueante de REQ-023 resultó ser otro
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agentes: `qa-tester` (Opus, vuelta 3 de 3) y coordinadora (verificación y escalada).

**La lección de la sesión, y no es agradable: nueve corridas verdes entre tres personas eran
abstenciones, no verdes.** El caso de `CA-09 (iii)` publica `SKIP` cuando la dispersión alcanza al
margen —conducta correcta, escrita en el criterio, «nunca PASS»—, y en la máquina del desarrollo la
dispersión es grande. El `desarrollador`, el `qa-tester` y la coordinadora leímos cinco «0 FAIL de
REQ-023» como evidencia de que el caso estaba bien. **El CI del PR #45, sobre una máquina quieta,
resolvió con holgura y salió ROJO:** `arnes_campo_linea` a **2,365× > 2,200×** con **dispersión 0,023×
contra margen 0,165×**. La dispersión del CI es **17× más estrecha** que la local, y el archivo del caso
es **byte a byte idéntico** en las dos partes, así que la diferencia no era de código.

**Una abstención repetida no es un verde acumulado**, y comparar la dispersión **entre hosts** era el
paso que faltaba. Queda escrito porque el mecanismo funcionó a medias: protegió contra el PASS falso y
mantuvo invisible el rojo.

**Y el rojo, medido, confirma el diagnóstico del analista en vez de contradecirlo:** el techo absoluto
de 2,2 es insatisfacible **también para el código heredado** —la base `v1.33.0` paga mediana **2,446**
en ese mismo sujeto, peor que el 2,365 del CI—. No es una regresión de `REQ-023`. Por eso el arreglo no
es bajar el cociente ni subir el techo, sino **re-apuntar el caso a la relación emparejada** que el
criterio nuevo ya contrata (medida: 0,856× y 0,906× contra techo 1,00×).

**Veredicto de la vuelta 3: `QA: con-hallazgos`.** 10 de 12 criterios pasan. `QA-023-05` (`contrato`)
**cerrado**, y el `qa-tester` **corrigió su propio veredicto de la vuelta 2** diciendo por qué se
equivocó: su argumento de entonces («el producto no se degrada») contestaba a la pregunta de
`usuario/dinero`, no a la de `contrato`. `CA-12 (iii)` pasa contando **3 = 3**. Los cuatro `instrumento`
del `desarrollador` se retiran **tras verificarlos**, incluido un doble par discriminante propio para
`QA-023-08`. La abstención sobre las dos instancias de `28-rotacion-seccion-{1,4}` se declara
**correcta**: viven en el `Archivos:` de `REQ-026`, que tiene `QA: aprobado` sobre otro árbol.

**El bloqueante de `REQ-023` resultó ser otro, y de clase más grave: `QA-023-15` (`usuario/dinero`).**
`CA-10` no está implementado y su precondición **ha vencido**. Verificado por la coordinadora:
`AGENTS.md:349` y `templates/AGENTS.md.tpl:314` siguen definiendo la invariante **por el retorno de
carro** cuando la puerta ya deniega por una propiedad **más ancha** (9 de 20 formas voltean
`allow`→`deny`); `skills/arnes-upgrade/SKILL.md` sólo habla del retorno de carro (`:695`, `:701`); y
los tres archivos **no** están en `codigo_app.globs`, así que ningún guardián los cubre. **El efecto
sale del repositorio:** un proyecto consumidor con su `AGENTS.md` congelado no se entera de que pudo
cerrar un REQ `critico` sin validación ni auditoría.

**`QA-023-12` es `instrumento` y a la vez bloquea el gate de fusión**, y las dos cosas son verdad: no
retiene el cierre del REQ —§6 nombra «una prueba» por su nombre— pero mantiene roja la puerta requerida
y estricta de `main`.

**Escalado al propietario en `PENDING_APPROVAL.md`:** `D1` pasa de «espera el veredicto» a la
recomendación de QA —**`Estado: bloqueado` con escalada, NO cierre con residual**, porque §6 no admite
residual sobre un `usuario/dinero`— y la fila de `REQ-023` en `D2` se corrige: el bloqueante ya no es
`QA-023-05` (`contrato`, cerrado) sino `QA-023-15`. La cola sigue en **4** y ningún REQ puede cerrarse.

## [Interno] — 2026-09-09 · REQ-023 vuelta 3 de 3: cuatro hallazgos cerrados, la clase de `QA-023-05` reconciliada, y `CA-10` que deja de ser un pendiente para ser un incumplimiento
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: qa-tester.

**Veredicto: `QA: con-hallazgos`.** Tercera y última vuelta del ciclo dev↔QA de `REQ-023`
(`AGENTS.md` §6: el contador es por REQ y no se reinicia). **10 de 12 criterios pasan**;
`CA-09 (iii)` queda **no acreditado** y `CA-10` **no cumple**. Veredicto dado sobre `hooks/` y
`tests/` tal como quedan en **`6ad9752`** —el commit aterrizó a mitad de la comisión y comiteó
**exactamente los bytes que ya estaban** en el árbol de trabajo; `hooks/` no entró en él y no se tocó—,
más el write-back del analista a `REQ-023.md`, sin comitear.

**1. La reconciliación que se encargó: `QA-023-05` es `contrato`, y queda CERRADO.** Se confirma la
subida del analista y se **corrige el veredicto propio de la vuelta 2** (que decía `instrumento`): el
argumento de entonces —«el producto no se degrada»— responde a la pregunta de `usuario/dinero`, no a la
de `contrato`, que es si el REQ afirma algo falso sobre lo construido; y lo afirmaba. El write-back del
analista lo cierra, con su **prueba de falsación escrita literalmente** («si las medianas emparejadas
hubieran salido 1,05, el techo seguiría siendo 1,00 y habría hallazgo contra el código») y su
**aritmética verificada** (0,515 · 0,382 contra márgenes 0,144 · 0,094: las cuatro cuadran).

**2. Los cuatro `instrumento` del `desarrollador`, RETIRADOS del campo tras verificarlos.**
`QA-023-04` (`ARNES_CLAVES` da **6** claves con `Estado` dentro), `QA-023-06` (**2** ocurrencias
restantes, **0** en las cinco secciones `39-*`, con el mecanismo de muerte por `set -u` **ejecutado**)
y `QA-023-08`, éste con **doble par discriminante propio**: la sobre-denegación sintética pone en
**FAIL** la mitad (2) nombrando `REQ-001.md`, y la guarda neutralizada pone en **FAIL** el cuarto suelo
de anti-vacuidad. La abstención del dev sobre `28-rotacion-seccion-{1,4}` **fue la correcta** —son del
`Archivos:` de `REQ-026`, con `QA: aprobado` dado sobre otro árbol— y su residual va a `QA-023-11`.

**3. `CA-10` pasa de «pendiente declarado» a INCUMPLIDO, y es lo único que bloquea (`QA-023-15`,
`usuario/dinero`).** Los tres archivos siguen sin tocar (`AGENTS.md:349` y
`templates/AGENTS.md.tpl:314` definen la invariante por el **retorno de carro**;
`skills/arnes-upgrade/SKILL.md` no menciona nada), y la precondición que el Historial declaró —«otra
comisión viva» escribiendo `AGENTS.md`— **ha vencido**: `6dd3f8a` está fusionado y `REQ-027` cerró en
`95764db`. Los tres archivos **no** están en `codigo_app.globs`. La clase no es `instrumento` porque el
efecto **sale del repositorio**: sin el apartado de migración, el dueño de un proyecto consumidor no se
entera de que pudo cerrar un REQ `critico` sin validación ni auditoría —y por tanto no barre su
corpus—, y su `AGENTS.md` congelado (`§14.D`) seguirá hablando sólo del CR mientras la puerta deniega
por una propiedad más ancha: **9 de 20 formas medidas voltean `allow`→`deny`**, entre ellas un BOM, un
NBSP, un TAB, un blanco duplicado y un **emoji** dentro de la clave.

**4. Cinco hallazgos nuevos más, todos `instrumento` y ninguno bloqueante del CAMPO — pero uno de ellos
tiene la puerta requerida de `main` en ROJO.** `QA-023-10` (severidad **crítica**): el caso del banco de
`CA-09 (iii)` mide la magnitud **retirada** (cociente absoluto contra techo 2,200×, tres parámetros y
ningún tag), así que el criterio **no está ejercido por nada** — y en el **CI**, donde la máquina está
quieta, ese caso **resuelve y FALLA**: `hooks-en-linux` sobre `6ad9752` da **955 · 1 · 10** con
`arnes_campo_linea` en mediana **2,365× > 2,200×** y dispersión **0,023×**, entre 10× y 34× más estrecha
que la mía. **No es regresión de `REQ-023`** —falla contra el techo que el write-back retiró por
insatisfacible, y la base heredada paga **2,446** en ese mismo sujeto—, pero **bloquea el gate humano de
fusión** mientras el caso siga apuntado ahí. Verificado por mí: el archivo del caso es byte a byte
idéntico entre `6ad9752` y el local, el techo está codificado literal (`:271`), y el criterio que viajó
en `6ad9752` es el **viejo** (0 apariciones de «relación emparejada» allí, 8 en el local pendiente) — de
donde **el cierre de `QA-023-05` queda CONDICIONADO a que el write-back se comitee**. `QA-023-11`: la abstención
que **mata la sección** sigue viva detrás de un umbral de **reloj** en `28/4:87` — dispara en la máquina
**rápida**, y el arnés está abaratando esa misma ruta. `QA-023-12` (severidad **alta**): la dispersión es el **rango**, y eso hace dos cosas — invalida la vía
conforme que el criterio pone primera («más tomas»), porque el rango es monótono no decreciente, **y
enmascara el rojo en cuanto el host tiene ruido**: las nueve corridas locales «en verde» de tres
personas distintas eran **abstenciones**, no verdes, y la máquina quieta del CI resolvió a la primera.
La cláusula del margen cumple su mitad buena —nunca da un PASS falso— y paga un precio que nadie había
escrito. `QA-023-13`: la
superlinealidad heredada, abierta con ID **por encargo del propio REQ**. `QA-023-14`: **el banco no
está en verde de forma reproducible en este host** — **3 de 4** corridas rojas (1, 4, 1 y **0** FAIL),
**ninguna** de REQ-023; la cuarta, tomada sobre el árbol que se entrega, sale en **verde** (rc 0). El
total cuadra en **966** las cuatro veces y los 42 casos del REQ dan **40 PASS · 0 FAIL · 2 SKIP**
idénticos en las cuatro.

**Y una cifra del encargo que no se sostuvo, medida y explicada:** la cola de `PENDING_APPROVAL.md`
**no está en 0 sino en 4** (`D1`–`D4`), así que hoy `guard-completado` deniega el cierre de **cualquier**
REQ. **No es un defecto del lector**: el archivo se reescribió a mitad de la comisión (18:56:54 → `0`;
19:00:33 reescritura; 19:06:25 → `4`) y su contenido es exactamente el de `HEAD`; 30 lecturas
consecutivas dan 4 con el hash y el `mtime` intactos.

**Lo que NO se acredita, dicho expresamente:** `CA-09 (iii)`, `CA-10`, y **el banco en verde de
`AGENTS.md` §7** —la puerta requerida de `main` se decide en CI, en otro host, que no se midió—. No se
firmó `Seguridad:`, no se tocó `Estado:`, no se hizo write-back, no se fijó ninguna ventana y no se
escribió en `hooks/`, `tools/`, `.github/`, `.arnes/`, `.claude-plugin/` ni `tests/`. Método y
evidencia re-derivable: `docs/qa/1.34.0-req023-vuelta3-qa-metodo.md`.

## [Interno] — 2026-09-09 · El índice cuadrado, la ventana de REQ-019 al día y cuatro decisiones escritas donde la máquina las ve
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: coordinadora.

Tres trabajos de coordinación, ninguno de código, todos por instrucción expresa del propietario.

**1. El índice de `requirements/README.md` estaba desfasado en SIETE filas** y ahora las 27 coinciden
con su cabecera, comprobado fila a fila. Lo grave no era el número: `REQ-012`, `REQ-014`, `REQ-017` y
`REQ-027` figuraban como **pendientes** estando **`completado`**, `REQ-026` como pendiente con QA ya
aprobado, `REQ-019` como pendiente estando **`bloqueado`** y `REQ-023` como pendiente. Es justo la
referencia que `AGENTS.md` §14.B.3 existe para que nadie reconstruya el estado de una conversación
larga, y decía lo contrario de la verdad en una cuarta parte de sus filas.

**2. La ventana de `REQ-019` deja de mentir.** Su cabecera declaraba `Versión destino: 1.34.0`
(«primer trabajo de la ventana») cuando el propietario lo **aplazó a 1.35.0** el 2026-09-09 y
`docs/PLAN.md` lo recoge **literal**. Y la cabecera es lo que **lee la máquina**: `arnes-lectura.sh` y
el bloque derivado lo contaban dentro de la ventana en curso. Corregidos el campo —con la cita del
aplazamiento dentro— y la fila del índice, con su fila de Historial. **No** se reabre el aplazamiento,
**no** se toca `Estado: bloqueado` ni `SEC-033` (`contrato`, abierto), y el texto que explicaba el
movimiento a 1.34.0 **no se borra**: queda marcado como historia, no como ventana vigente.

**3. Cuatro decisiones del propietario escritas en `PENDING_APPROVAL.md`**, y con ellas la cola pasa de
**0 a 4**, así que **`guard-completado` deniega ahora el cierre de cualquier REQ**. Es el mecanismo
funcionando, no un efecto colateral: las cuatro decisiones **bloquean de verdad**. Son **D1** el cierre
de `REQ-023` con residual declarado o `bloqueado` —agotadas las tres vueltas, y marcada como *no
firmar hasta que QA entregue*—; **D2** los **20 hallazgos bloqueantes** de siete REQ, casi la mitad
deuda de 1.31.0 y 1.32.0; **D3** `SEC-072` y `SEC-073`, que **no se cierran por redacción ni por
aceptación implícita** por instrucción expresa del propietario, precisamente porque el informe los
describe como «de redacción, no de código» y eso los hace tentadores de cerrar reescribiendo un
párrafo; y **D4** la ventana **propuesta** 1.35.0 para la superlinealidad heredada, que el analista
propone y no fija.

## [Interno] — 2026-09-09 · Write-back de `QA-023-05`: `CA-09 (iii)` deja de contratar el nivel absoluto del escáner y contrata el DELTA que REQ-023 introduce
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: analista-requerimientos (write-back; sin código, sin pruebas, sin firmar veredictos).

Cierra la **mitad de analista** de `QA-023-05` (`contrato`), el único hallazgo que bloqueaba el
cierre de **REQ-023**. La medición de la entrada anterior desmintió la premisa que el propio REQ
tenía escrita: `CA-09 (iii)` contrataba un **techo absoluto** (cociente de duplicación ≤ 2,2) que la
**línea base heredada `v1.33.0` ya pagaba** —medianas **2,492** y **2,446**—, de modo que **ningún
código que este REQ pueda escribir lo satisfacía**. Un criterio incumplible por construcción no
acredita ni desacredita nada.

**Qué cambia en el criterio.** La magnitud pasa a ser la **relación emparejada** entre el cociente de
la candidata y el de la base, **dentro de cada toma** de una **única tanda** y con las dos versiones
**intercaladas al nivel de `n`**: **no más de 1,00×** (**operativo**, hacia abajo). Gana un **cuarto
parámetro** obligatorio —la **línea base**, el tag—; los **cocientes absolutos** quedan como
**control publicado y no acreditativo**; y la dispersión que decide la afirmabilidad es la de la
**serie emparejada**, no la de cada cociente. Factibilidad con sus dos mitades: **conforme y medida
en relación** (medianas **0,856** y **0,906**, **9 de 10** pares) pero **no afirmable** todavía
(dispersión 0,515 y 0,382 frente a márgenes 0,144 y 0,094), así que **SKIP con los cuatro
parámetros, nunca PASS**, con la vía conforme escrita **antes** de medir: más tomas, `k` mayor o par
mayor — **nunca** cambiar la forma ni subir el techo.

**El 1,00× no sale de esas cifras, y la falsación lo prueba:** es la propiedad estructural «la guarda
no empeora el orden de crecimiento del camino en el que se inserta», escrita como razón contra una
línea base de la misma corrida. Con medianas de 1,05 el techo seguiría siendo 1,00 y habría
**hallazgo contra el código**. Tampoco se declara conforme el 2,295 de la candidata: se declara **no
contratado por este REQ**.

**El precio, dicho y no escondido:** (iii) **deja de ser auto-anclado** y hereda la ruta de
materialización del tag que `CA-08` ya declara (**SEC-048**, citado, no arreglado); si la base no se
materializa, **SKIP**. Y la **superlinealidad heredada no desaparece**: entra en «Fuera de alcance»
con clase `instrumento` declarada allí —ningún `SEC` la abrió—, dueños `desarrollador` (el arreglo
descrito y **no aplicado** en §11.6 del método) y `analista-requerimientos` (el criterio), forzador
propio y **ventana propuesta 1.35.0 que decide el propietario**.

Refrescadas las tres citas que el cambio dejaba falsas: la premisa de la cota algebraica de **(ii)**
—ahora apoyada en la medición `r` = 1,206× a n=1000 y 1,108× a n=2000, con el techo de (ii)
**intacto**—, la frase de `CA-03` que daba la cata como acreditación de (iii), y la fila de
`SEC-048`. **Sin ADR:** no cambia el alcance, la decisión base, el rigor ni los techos de (i) y (ii);
corrige **qué magnitud** mide un número declarado **operativo**, que es cambio menor (`AGENTS.md`
§9). **No** se firmó `QA:` ni `Seguridad:`, **no** se movió `Estado:` y **no** se tocó el valor de
`Hallazgos abiertos:` —`QA-023-05 (contrato)` sigue ahí—: bajar la clase del hallazgo que bloquea el
propio documento sería firmar por otro, y la retirada la enruta `qa-tester`, como con `SEC-052`.
Archivos: `requirements/REQ-023.md`, `CHANGELOG.md`.

## [Interno] — 2026-09-09 · La base heredada `v1.33.0` paga el cociente de `CA-09 (iii)`: `QA-023-05` es un hallazgo contra el CRITERIO, no contra el código
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: desarrollador (una sola medición, sin arreglo).

Comisión de **una sola medición**, la que quedó a medio hacer al parar la anterior. Se midió el
cociente de duplicación de la **`v1.33.0` heredada** sobre la **misma forma «clave»**, con el
**mismo par** (1000→2000), el **mismo `k`** (200) y los **mismos dos sujetos**, **en la misma tanda**
que la candidata y con base/candidata **intercaladas al nivel de `n`** (así una deriva de carga cae
sobre las dos por igual, `REQ-007 CA-59`). 5 tomas, 40 invocaciones de la sonda, 118 s.

| sujeto | versión | tomas | mediana | dispersión | margen al techo 2,2 |
|---|---|---|---|---|---|
| `arnes_norm_clave` | **base `v1.33.0`** | 5,815 · 2,979 · 2,392 · 2,474 · 2,492 | **2,492** | 3,423 | 0,292 |
| `arnes_norm_clave` | candidata | 2,532 · 2,257 · 2,048 · 2,295 · 2,367 | **2,295** | 0,484 | 0,095 |
| `arnes_campo_linea` | **base `v1.33.0`** | 2,528 · 2,135 · 2,587 · 2,446 · 2,318 | **2,446** | 0,452 | 0,246 |
| `arnes_campo_linea` | candidata | 2,291 · 2,586 · 2,145 · 2,237 · 2,022 | **2,237** | 0,564 | 0,037 |

**La base heredada paga tanto o MÁS que la candidata.** Lo robusto en un cociente no es cada cifra
suelta sino la **relación emparejada dentro de la misma toma**: mediana **0,856** en
`arnes_norm_clave` y **0,906** en `arnes_campo_linea`, con la candidata por **debajo** de la base en
**9 de los 10 pares** y en las cinco tomas de `arnes_norm_clave` sin excepción. El mecanismo: la
guarda añade ~20 % de coste absoluto a 1000 bytes y ~10 % a 2000, así que su peso relativo **baja**
al alargar la línea y **diluye** el cociente en vez de empeorarlo.

**Consecuencia, y es quién resuelve el hallazgo:** `CA-09 (iii)` tal como está redactado **no mide
lo que REQ-023 añade** — mide una superlinealidad que `arnes_norm_clave` ya tenía en `v1.33.0`. Un
criterio de aceptación de este REQ que la línea heredada **también** incumple no puede acreditar ni
desacreditar la guarda. **`QA-023-05` es un hallazgo contra el CRITERIO y su dueño es el
`analista-requerimientos`**; no sube al propietario por agotamiento de vueltas, porque **no hay nada
que arreglar en `hooks/`**.

**La mitad que NO se afirma.** Las cuatro series tienen **dispersión ≥ margen**, así que por la regla
del propio caso **ninguna es afirmable** hoy: no se afirma que el techo se supere, ni el de la base
ni el de la candidata. Esta medición resuelve **de quién es el número**, no dónde debe estar el techo
— eso es del analista. Y la máquina daba reloj alto (`DEV v3: heredoc CITADO de ~300 KB` en 4835 ms
contra techo 4000, veredicto `allow` correcto): la `t1` de la base (5,815) es una ráfaga sobre el
término largo, se **publica y no se descarta**, y retirando de cada serie su toma más alta **ninguna
mediana se mueve**.

**Nada se arregló y nada se firmó**: no se tocó `hooks/`, no se subió el techo, no se cambió la forma
ni `k` ni el par, no se firmó `QA:` ni `Seguridad:`, el `Estado:` sigue `en-progreso` y no se retiró
ningún hallazgo. Un arreglo posible se **describe con su coste y no se aplica** (§11.6): tocaría el
camino **heredado** de `arnes_norm_clave`, que es alcance nuevo sobre código que este REQ no
introdujo. Evidencia, método re-derivable y limitaciones en
`docs/qa/1.34.0-req023-vuelta3-metodo.md` **§11**. Quality gates en verde; el banco **no** se
re-corre porque esta comisión no toca ningún caso ni `hooks/`.

## [Interno] — 2026-09-09 · Parada limpia por cambio de red, con `CA-09 (iii)` abstenido por primera vez y una pista que reorienta el hallazgo
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: coordinadora (parada y verificación) sobre trabajo parcial del `desarrollador`.

Se detuvo **a propósito** la comisión del `desarrollador` sobre la mitad de código de `QA-023-05`,
antes de que el cambio de red cortara la sesión a media escritura y dejara el caso a medio editar.
**El árbol quedó consistente, no a medias**, y está verificado después de la parada: `bash -n` sobre
las 57 secciones más `run.sh`, `hooks/*.sh` y `tools/*.sh` compila todo; las tres quality gates en
verde; cero worktrees huérfanos; autoprueba **106 PASS · 0 FAIL**; banco **960 PASS · 0 FAIL · 6 SKIP**
con el total cuadrando en **966**.

**Los dos SKIP nuevos (4 → 6) no son una regresión: son la cláusula del margen ejecutándose por primera
vez.** El caso de `CA-09 (iii)` ya mide la **forma contratada** por el write-back del analista —crece el
segmento de **clave** desde una clave que el lector reconoce— y **abstiene en vez de pasar**, publicando
las tomas y la dispersión, que es exactamente lo que el criterio ordena:

| sujeto | tomas | mediana | dispersión | margen al techo 2,2 |
|---|---|---|---|---|
| `arnes_norm_clave` | 2,943 · 2,136 · 2,277 | **2,277** | 0,807 | 0,077 |
| `arnes_campo_linea` | 2,563 · 2,318 · 2,211 | **2,318** | 0,352 | 0,118 |

Las dos medianas quedan **por encima** del techo, pero la dispersión es mayor que el margen, así que el
criterio **prohíbe afirmarlo** y abstiene: ni pasa en falso ni suspende por ruido. `(iii)` queda **sin
acreditar**, y eso es lo que hay que resolver, no ocultar.

**La pista que vale más que las cifras**, dejada por el agente en su última línea antes de la parada:
«*la candidata apenas mueve el número, así que el coste puede no estar en la guarda*». Si la `v1.33.0`
heredada paga el **mismo** cociente sobre la **misma** forma, entonces `CA-09 (iii)` **no mide lo que
este REQ añade** y el hallazgo es contra el **criterio**, no contra el código — lo que cambia por
completo quién lo resuelve. Medir la base heredada sobre la forma «clave» es el siguiente paso concreto,
y era justo lo que el agente iba a hacer. Sin ese número, la decisión de §6 se tomaría a ciegas.

Queda anotado en `docs/ESTADO.md` que el índice de `requirements/README.md` está desfasado en **siete
filas** y por qué no se corrigió en caliente: el corpus del banco hace `cat requirements/*.md`, así que
editarlo mientras un agente mide **mueve sus cifras**.

## [Interno] — 2026-09-09 · REQ-023 write-back de la vuelta 3: el motivo del homóglifo que se desmentía, el parámetro que decidía el veredicto de `CA-09 (iii)`, y la capitalización decidida
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: analista-requerimientos.

Write-back de los tres hallazgos con dueño en el analista, sobre `requirements/REQ-023.md` (más una
anotación en `requirements/REQ-024.md`). **Sin código y sin pruebas**; el `Estado:` sigue
`en-progreso` y no se firma ningún veredicto. **No se comitea y no se empuja.**

**`QA-023-07` (`contrato`, el único que bloqueaba) — trasladado el motivo ya corregido.** El apartado
«Fuera de alcance» seguía sosteniendo el homóglifo sobre una premisa que `CA-03` declara **medida
falsa** veinte pantallas antes: «la clave resultante no contiene nada ajeno al alfabeto —es *otra*
clave—». Las dos cláusulas son falsas y QA lo remidió ejecutando el lector sobre `Еstado` (`Е` =
U+0415): la clave **sí** contiene algo ajeno, la guarda lo **ve** y lo retira, y lo que queda
(`stado`) **no es** ninguna clave. El motivo pasa a ser el que ya estaba escrito —**retirar lo ajeno
no repone lo sustituido**— con el reparto blanco/letra intacto. **La decisión de fondo no cambia:**
este REQ no cierra la clase del homóglifo, y las superficies que `CA-12 (iii)` cuenta siguen siendo
**tres**.

**`QA-023-05` — `CA-09 (iii)` gana el tercer parámetro del cociente, y el hallazgo sube a
`contrato`.** Con el mismo par (1000→2000), el mismo `k` y el mismo sujeto, tres formas de línea
**todas conformes** con la redacción anterior reparten sus cocientes a los dos lados del techo
(título 2,042 · valor 1,727 · clave real 2,235–2,284, cinco tomas), y la sesión de QA del mismo día
ordena las dos formas de clave **al revés**: el parámetro ausente **decidía el veredicto**. El techo
de **2,2 no se toca** y la forma no se elige por su resultado: el criterio fija ahora **qué forma
mide** (crece el segmento de **clave** partiendo de una clave que el lector reconoce; el **valor** es
control y la **línea de título** queda fuera), obliga a **publicarla** con el par y `k`, declara que
dos cocientes de formas distintas **no son comparables**, y sólo permite **afirmar** el techo con
margen mayor que la reproducibilidad demostrada en la misma corrida —si no, **SKIP, nunca PASS**—.
Consecuencia declarada: la factibilidad de (iii) se **re-deriva** y hoy **no hay solución conforme
medida** sobre la forma contratada. La clase sube porque la doctrina no deja margen (un criterio mal
formado se reporta como `contrato` contra el REQ), así que **bloquea el cierre**; su otra mitad es del
`desarrollador` y no la retira el analista.

**`QA-023-09` — decidido, no arreglado.** La clave con otra capitalización (`sensible a seguridad:
sí`) se resuelve como **ausencia** y abre, igual en las dos versiones. Entra en la superficie de
**REQ-024** como **instancia** de su `CA-01` —no como criterio nuevo—, porque cerrada la dirección de
la ausencia la vía se cierra por construcción, sin tablas de capitalizaciones. Anotado allí con su
cita; retirado del campo de REQ-023.

`Hallazgos abiertos:` de REQ-023 queda en `QA-023-04 (instrumento), QA-023-05 (contrato),
QA-023-06 (instrumento), QA-023-08 (instrumento)`: se retiran los dos que cierro (07 y 09) y **no** se
retiran los tres que cerró el `desarrollador`, porque el analista no firma por otro.

## [Interno] — 2026-09-09 · REQ-023 vuelta 3 de 3: los cuatro hallazgos `instrumento`, y la cláusula anti-tautología de `CA-03` ejecutándose por primera vez
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 · agente: desarrollador.

`REQ-023`, **vuelta 3 de 3** (la última), sobre el **árbol de trabajo** (`5305de9` + la partición de
la sección 39 sin comitear). **Ninguno de los cuatro arreglos toca `hooks/`**: los cuatro son del
instrumento que mide al arnés, y ninguno bloquea el cierre. **No se comitea y no se empuja**: `gh`
no está autenticado y la fusión es un gate humano.

**`QA-023-06` — la abstención mataba la sección, y con ella un criterio de aceptación.** Retirados
**13** de los **15** `SKIP=$((SKIP+1))` del banco (el informe de QA decía 14; el recuento propio da
15). El corredor define `PASS` y `FAIL` antes del despacho pero **no `SKIP`** (`run.sh:23`) y las
secciones corren bajo `set -u`, así que cada rama de abstención mataba su sección en la **primera**
que emitía. Se **retiran** en vez de definir la variable, y no es estilo: el recuento sale **del
texto** (`run.sh:1218`) y los ayudantes del propio corredor ya lo hacen así (`:783`, `:808`) —
definirla dejaría vivo un segundo número que nadie lee. Medido con copias en
`ARNES_SECCIONES_DIR` y la línea base apuntada a un tag inexistente para forzar la abstención:
**fail-before** 4 muertes, 4 `ABORT:` y `Resultado: 21 PASS, 0 FAIL` **con 29 PASS y 6 FAIL en
pantalla**; **pass-after** 0 muertes y **7 SKIP** donde había 4. Entre los tres nuevos está la
**cláusula anti-tautología que `CA-03` eleva a criterio de aceptación** —«aborta con SKIP y su
motivo, nunca PASS, si alguna de las dos ramas que exigen DENY se queda sin ninguna tirada»—, que
**nunca se había ejecutado** porque la rama 1 abstenía primero y la sección moría antes de llegar a
la 2.

**`QA-023-08` — el único criterio que vigila la sobre-denegación no podía fallar en su eje.** El
evaluador de `CA-04` publica ahora la guarda en las **dos** mitades, y con la variable que le toca a
cada una: `ARNES_CLAVE_OCULTA` por línea y `ARNES_OCULTA` por documento —**en los dos** recorridos de
cabecera, porque cada uno la reinicia—. Las columnas observacionales se siguen comparando estrictas
(CA-06) y la de la guarda se **cuenta y se publica**, con un **cuarto suelo** de anti-vacuidad: al
menos **una** línea del corpus donde la guarda dispare, o el «0 divergencias» es cierto por vacío.
Par discriminante contra una **sobre-denegación sintética** (retirado el atajo de `lib.sh:1840` en
una copia): el evaluador ciego da **3 PASS · 0 FAIL** y el arreglado **2 PASS · 1 FAIL** nombrando el
primer REQ divergente. Sobre los hooks reales: 32 líneas del corpus donde la guarda dispara, **0**
divergencias sobre los 27 REQ del árbol.

**`QA-023-04` — la derivación de claves que se estrechó de 6 a 5 y perdió justo `Estado`.**
`36-…-2-los-lectores.sh` deja de raspar el **texto** del `case` con `sed` y lee la **constante**
`ARNES_CLAVES` (1 proceso contra 3). Es la lección que `tools/arnes-lectura.sh` ya tenía escrita para
su propia derivación. Cobertura medida sobre el glob real: **0 de 127** rachas cosechadas contenían
una línea `Estado:` antes; **102 de 154** después.

**`QA-023-05` — la forma de la línea, publicada; y un número que sube la apuesta.** `CA-09 (iii)`
publica ahora la **forma** además del par, con el esqueleto en una sola variable —lo que la sonda
repite es lo que el caso publica—. Y medido con el mismo par (1000→2000) y el mismo `k`: la forma
**clave** (`Sensible a <n> seguridad: sí`, una clave **real** del lector) da **2,235 · 2,284 · 2,260
· 2,255 · 2,240**, cinco tomas **por encima** del techo de 2,2, mientras la forma **título** que el
caso mide da 2,042 y la de **valor** 1,727. El parámetro que falta no es cosmético: **decide el
veredicto**. El techo **no se toca** y la forma que el caso mide **no se cambia** —elegir la que pasa
sería `QA-023-02` un eje más allá—.

**Lo que NO se cierra, dicho con nombre y línea.** Los **2** `SKIP=$((SKIP+1))` restantes viven en
`28-rotacion-seccion-{1,4}.sh`, que están en el `Archivos:` de **REQ-026** con `QA: aprobado` sobre
ese árbol: tocarlos dejaría una firma ajena sobre un árbol que ya no es. El de `28/4:87` depende del
**reloj** (la carrera que no se provoca) y puede matar esa sección en cualquier corrida cargada — va
con dueño, no como hallazgo nuevo. **Y dos defectos DISTINTOS anotados sin arreglar:** la línea
`Resultado:` **descuenta** los casos de una sección muerta (`run.sh:1248-1255`, el `continue` va
antes de la acumulación de `:1271`) y `run.sh` está en el `Archivos:` de REQ-024; y el caso de
`36-…-2` no tiene suelo de anti-vacuidad sobre **las bases que deniegan**, que son las únicas que su
propiedad puede violar.

Puertas propias: las tres quality gates **rc 0**; `bash -n` sobre las 57 secciones **rc 0**; banco
completo **962 PASS · 0 FAIL · 4 SKIP · rc 0** en **dos** corridas (43,8 s y 44,7 s) con la **LISTA**
de SKIP idéntica a la de QA (`cygpath` · `REQ-017 CA-05 (i)` · `REQ-017 CA-05 (ii)` ·
`REQ-021 CA-08 (iii)`); `autoprueba-corredor.sh` **106 PASS · 0 FAIL · rc 0**;
`tools/arnes-lectura.sh .` **rc 0**. Método, árboles de referencia y re-derivación en
`docs/qa/1.34.0-req023-vuelta3-metodo.md`. **No se firma `QA:` ni `Seguridad:`, no se toca `Estado:`
y no se hace write-back**: `QA-023-07` (`contrato`, el único que bloquea) es del
`analista-requerimientos`.

## [Interno] — 2026-09-09 · QA de REQ-023 vuelta 2: los tres bloqueantes cerrados con fail-before medido, y un cuarto que es una premisa que el propio REQ ya declaró falsa
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: qa-tester.

`REQ-023`, **vuelta 2 de 3**, sobre el **árbol de trabajo** (`5305de9` + la partición de la sección
39 sin comitear). Se valida el árbol sucio a propósito, no un commit.

**La pieza que faltaba y ahora existe: el fail-before / pass-after.** Un banco verde no acredita que
un caso discrimine. Medido con el mecanismo del propio banco (`ARNES_HOOKS_DIR`), semilla fija
(`ARNES_SEM_39=508269595`) y árboles montados con `git worktree add --detach` y `git archive`, sin
mover nunca el árbol de trabajo. Los **dos** casos nuevos de `CA-03` **fallan** contra `29b06eb^`
(`95764db`): la rama 1 por un punto de código de cuatro bytes que sustituye al blanco interno
(`<P2:f0b4ae98>`) y la rama 2 por el blanco insertado y duplicado (`<P1:20>` y cuatro `<P3:20>`) —
40 PASS · 2 FAIL · rc 1 antes, 42 PASS · 0 FAIL · rc 0 después. Y los **cuatro** casos marcados
«(era ALLOW)» de `CA-08` fallan contra el **tag** `v1.33.0` (11 PASS · 10 FAIL), mientras los nueve
controles que deben decidir igual —`CA-08 (ii)/(iii)`, los cuatro de `CA-11` y los dos de `CA-04`—
pasan en las dos versiones: el rojo lo produce la guarda y no otra rama.

**Los tres bloqueantes, cerrados con evidencia propia.** `QA-023-01` (`usuario/dinero`): banco propio
de 20 formas de la clase del blanco —insertado, sustituido, duplicado, retirado, NBSP, TAB, ZWSP, al
borde y en clave de una palabra—, **todas deniegan** y **13 eran `allow`**; el motivo saca los blancos
en hexadecimal sólo cuando alguno de ellos **es** lo insertado, que es lo que lo vuelve
diagnosticable. Se buscó una tercera forma dentro de la familia y **no se encontró**, con el
argumento que cierra el hueco escrito. `QA-023-02` y `QA-023-03` (`contrato`): el **write-back existe**
en el Historial del REQ, el sorteo deriva sus dos estratos de la constante única en cada corrida
(6 claves, alfabeto de 21), publica semilla y tiradas por rama, y **aborta con SKIP y no con PASS**
cuando una rama de DENY se queda sin tirada — provocado, no leído; `CA-12 (iii)` se comprueba
contando y cuentan 3 = 3.

**La partición: cuadre verificado de forma independiente.** 966 = 966 líneas de inventario, 42 casos
de `REQ-023` antes y después, reparto **10 = 7 + 3** comprobado **por nombre de caso** y no por total,
y `diff` vacío tras normalizar los cuatro volátiles. El cuadre del `desarrollador` es correcto.

**Cuatro hallazgos nuevos, uno bloqueante.** `QA-023-07` (`contrato`): el apartado «Fuera de alcance»
sigue justificando la exclusión del homóglifo con la premisa que `CA-03` ya declara **medida falsa**
en el mismo documento —medido ejecutando el lector: `Еstado` **sí** contiene algo ajeno, la guarda lo
ve y lo retira, y lo que queda **no** es otra clave—; el texto correcto ya existe literal en `CA-03`,
el write-back es trasladarlo. `QA-023-06` (`instrumento`): toda ruta de SKIP de las secciones hace
`SKIP=$((SKIP+1))` y el corredor **no define `SKIP`** antes de ejecutar una sección, así que con
`set -u` la sección **muere** en su primera abstención — la cláusula anti-tautología que `CA-03` eleva
a criterio nunca se había ejecutado; no es fail-open (ABORT y rc 1), pero la línea `Resultado:`
publicó `0 FAIL` con seis FAIL en pantalla. `QA-023-08` (`instrumento`): el caso de `CA-04` **no
imprime `ARNES_OCULTA`** en ninguna de sus dos mitades, que es la única variable por la que la guarda
puede cambiar una decisión, así que el único criterio que vigila la sobre-denegación no puede fallar
en su propio eje; medidas **131 líneas** del repositorio donde la guarda dispara hoy y no antes, y un
documento real (`docs/gobernanza/autoalojamiento.md:3`) cuya lectura de cabecera cambia de opinión —
ninguna, dentro de `requirements/`. `QA-023-09` (`instrumento`): la clave con otra capitalización se
resuelve como ausencia y abre, igual en las dos versiones; se anota con dueño y **no** se reclama como
incumplimiento, porque la clase de este REQ es la del carácter que nadie ve en el diff.

**Y se retira un número propio.** El «el techo de `CA-09 (iii)` se supera» de la vuelta 1 (2,412 /
2,364) **no se reproduce** con la construcción de hoy: cuatro mediciones conformes del mismo criterio
dan 1,689 · 2,008 · 2,069 · 2,181, la peor al 99,1 % del techo. `QA-023-05` no se debilita, se
confirma: el defecto es que dos mediciones conformes no son comparables porque falta declarar la
**forma** de la línea.

Puertas propias: las tres quality gates en verde; banco **962 PASS · 0 FAIL · 4 SKIP · rc 0** en
**dos** corridas con la **lista** de SKIP idéntica e inventario normalizado idéntico; autoprueba
**106 PASS · 0 FAIL**; `tools/arnes-lectura.sh` rc 0 sobre los 27 REQ. `QA: con-hallazgos`;
`Estado:` sigue en `en-progreso` y no se firma `Seguridad:` (va después de QA, `AGENTS.md` §6).
Hallazgos en `docs/qa/1.34.0.md` § REQ-023; método y evidencia re-derivable en
`docs/qa/1.34.0-req023-vuelta2-metodo.md`.

## [Interno] — 2026-09-09 · La sección 39 pasa a cinco partes: el techo de CA-18 se paga partiendo, no subiéndolo
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: desarrollador.

`REQ-023`, vuelta 1 de 3. Al entrar el sorteo estratificado de `CA-03` (write-back de `QA-023-02`),
`39-caracter-invisible-2-la-clase-y-el-corpus.sh` quedó en **402 líneas contra su techo de 400** y
dejaba la autoprueba del corredor en **105 PASS · 1 FAIL**. Su piso (**294**) está por debajo de
`N / k` = 320, así que quien gobierna ese techo es **`N`** y no `piso × k`, y `N` sólo admite bajar:
la única acción conforme era **partir**, que es lo que `REQ-014 CA-18 (ii)` ordena. No se subió el
techo, no se re-derivó `k` y no se infló el piso para caber —esa última es la **regresión** que ese
criterio nombra por su nombre—.

El corte va por la frontera que el propio nombre del archivo declaraba: la **clase** (`CA-03`) se
queda en `39-caracter-invisible-2-la-clase.sh` (**302** líneas, piso 294) y el **corpus** (`CA-04`)
sale a `39-caracter-invisible-5-el-corpus.sh` (**213** líneas, piso 165 = 30 preámbulo + 76
maquinaria duplicada + 59 bloque indivisible), con el materializador de la línea base duplicado
porque las dos mitades comparan contra `v1.33.0`. Se numera **5** y no 3 para no dejar desfasadas
las citas por nombre y línea a las partes 3 y 4 que ya viven en `requirements/REQ-023.md` y en
`docs/qa/1.34.0.md`: una cita rota cuesta más que un número no contiguo.

**El cuadre, que es la parte que no se puede afirmar sin medirla.** Reparto de casos **10 = 7 + 3**,
y `CASOS_ESPERADOS` de `run.sh` **no cambia** (966): partir reparte, no crea ni pierde. El
inventario da **966 líneas antes y 966 después**, y bajo el oráculo de `CA-12` más los dos volátiles
conocidos —la semilla del sorteo y los conteos del corpus, que crecen porque el corpus se descubre
por glob sobre `secciones/`— los dos salen **idénticos**, `diff` vacío. Puertas: autoprueba
**105 PASS · 1 FAIL → 106 PASS · 0 FAIL**; banco **961/1/4 → 962/0/4**, rc 0; las tres quality gates
en verde. Cuadre completo, con método y versión base, en
`docs/qa/1.34.0-req023-particion-39.md`.

**Lo que este verde NO acredita:** el fail-before/pass-after de los casos de `REQ-023`. Nadie ha
comprobado aún que fallen contra el código anterior, así que no prueba que discriminen; eso lo
decide el `qa-tester`. Y tres observaciones que van a la cola sin bloquear: el caso de reloj de la
sección 25 oscila FAIL↔PASS con la carga (4036 ms contra un techo holgado de 4000, veredicto
correcto) y **no** está declarado en `CA-14`; la semilla de `CA-03` se publica como entero suelto
**dentro del nombre** del caso, justo donde el oráculo del inventario declara que no normaliza; y
`REGHER92`/`REGHER93` nunca se asignan, así que el SKIP por falta de línea base imprimiría un
paréntesis vacío el día que haga falta el diagnóstico. De paso, el total de referencia del
`README.md` del banco decía **924** con el literal ya en **966** —segunda reincidencia de
`SEC-066`—: se corrigió el número; cerrar el hallazgo no es del `desarrollador`.

## [Interno] — 2026-09-09 · Traslado ejecutado en la WSL nueva: tres puntos de la lista no resistieron el contacto con la máquina
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Se instaló y configuró lo necesario para seguir trabajando en el clon nuevo (`sysvega-dev`), y la
propia lista de traslado consignada horas antes **se corrigió con lo medido**. Lo que se hizo:
`git config --local user.name/user.email` con la identidad del historial
(`Juan Vega <jvega@habitat.org>`). Nada más hacía falta instalar.

**Lo que la lista decía y la máquina desmintió** —las tres correcciones ya escritas en `docs/ESTADO.md`:

1. **`node` no es dependencia del arnés** y figuraba en la lista junto a `jq`. Está **ausente** en
   este clon y no se echó en falta: las tres quality gates piden sólo `bash` y `jq`, y las únicas
   apariciones de `node`/`npm` en el árbol son prosa y **cadenas de caso** que el guardián juzga como
   texto. Listar una dependencia falsa al lado de la única que apaga el enforcement **abarata la que
   sí importa**.
2. **La identidad de git faltaba en la lista**, y es el **tercer apagado silencioso de la misma
   familia** que `jq` y `core.hooksPath`: un clon nuevo no tiene `user.name` ni `user.email`, el
   commit **no falla**, sale firmado con lo que el sistema derive (`juan@sysvega-dev`) y la autoría
   del historial se parte sin que nada avise.
3. **El `gitCommitSha` de la instalación es `5f37946`, no el `810128a` que la lista anotó.** No es un
   error: `810128a` es el **tag** `v1.33.0` y `5f37946` es `origin/main` (#44, «Registro de la
   publicacion de v1.33.0»), posterior; el marketplace instala desde `main`. Lo que decide no es el
   sha sino si **el mecanismo difiere**, y no difiere: entre los dos commits sólo cambian
   `CHANGELOG.md`, `PENDING_APPROVAL.md`, `docs/ESTADO.md` y `docs/PLAN.md`, y comparado archivo por
   archivo contra el tag, todo el mecanismo instalado coincide **byte a byte**. Esa comparación
   —y no la igualdad de shas— es la que se repite en el próximo traslado.

**CORRECCIÓN, escrita el mismo día y sobre esta misma entrada: el número de SKIP oscila entre 4 y 5
en la MISMA máquina, y no es la plataforma.** Esta entrada afirmó primero que los **961 PASS · 0 FAIL ·
5 SKIP** medidos aquí, frente a los 962/0/4 de la máquina anterior, se debían al SKIP de `cygpath`, y
concluyó que «la cifra esperada no es una constante del proyecto sino de la máquina». **Es falso.** La
segunda corrida, sobre el árbol ya partido, dio **962 · 0 · 4** en esta misma WSL, y el SKIP de
`cygpath` —`ruta estilo Windows con backslashes -> deny`— **aparece en las dos listas**, de modo que
estaba también entre los 4 SKIP de la máquina anterior y nunca pudo ser la diferencia. El caso que
**entra y sale** es `REQ-017 CA-08 (ii)`, cuyo propio motivo de SKIP declara que «*el techo cae DENTRO
del recorrido observado [1.010×, 1.302×]: el instrumento no distingue el factor que vigila*»: salta
cuando no converge y pasa cuando sí, según la carga. La lección que queda **no es sobre plataformas**:
**una diferencia de una unidad en el recuento se explica leyendo la LISTA de SKIP, nunca el total** —
comparar totales invita a inventarle una causa a un caso que sólo estaba oscilando, que es exactamente
lo que ocurrió aquí. El total cuadró en **966** las tres corridas.

Lo que sí es cierto sobre `cygpath` y se conserva: está **ausente** en esta máquina —interop de WSL
activo (`/mnt/c` montado, `WSLInterop` `enabled`) pero el host **sin Git para Windows** y el `PATH` sin
ninguna ruta `/mnt/c`—, el caso es de Windows y el banco lo salta **declarando su motivo**, que es lo
que se le pide. No hay nada que arreglar ahí.

La autoprueba dio **105 PASS · 1 FAIL** al llegar (4 s), con el FAIL en el `CA-18` conocido
(`39-caracter-invisible-2-la-clase-y-el-corpus.sh`, 402 líneas contra el techo de 400), y **106 PASS ·
0 FAIL** después de que el `desarrollador` partiera la sección.

**El arnés está vivo:** `jq` presente (los hooks **no** están inertes), `core.hooksPath` ya en
`.githooks` (la puerta del CHANGELOG responde), las tres quality gates en **verde** y la cola de
`PENDING_APPROVAL.md` en **0**.

**Pendiente, y es del humano:** `gh` no tiene ninguna cuenta autenticada. `gh auth login` es
interactivo y el token no está en disco, así que ningún agente lo cierra solo. Sin las dos cuentas
(`jvega-habitat` para push, `JJOVEGA` para rulesets) no hay PR ni fusión a `main`.

## [Interno] — 2026-09-09 · Lista de traslado a otra instancia de WSL: lo que NO viaja con el repositorio
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Consignado en `docs/ESTADO.md`, dentro del bloque de pausa. Los dos apagados **silenciosos** que un
clon nuevo produce si nadie los previene: **sin `jq` los hooks del arnés quedan inertes con un aviso**
—el enforcement se apaga sin que nada falle—, y **`core.hooksPath` es configuración local y no se
versiona**, así que la puerta del CHANGELOG queda apagada hasta que alguien corra
`git config core.hooksPath .githooks`. En esta máquina `jq`, `gh` y `node` viven en `~/.local`, no en
el sistema.

Se añaden el plugin estable a instalar (**1.33.0**, `810128a`, del marketplace `JJOVEGA/ArnesJuan` —
por autoalojamiento se instala **la publicada**, nunca el árbol de trabajo), la cuenta de Claude Code
en uso y las dos cuentas de `gh`.

**Y la comprobación de que el traslado quedó bien**, que es la misma que acredita que el arnés está
vivo: banco **962 PASS · 0 FAIL · 4 SKIP** y autoprueba **105 PASS · 1 FAIL** (el `CA-18` conocido).
**Un resultado mejor que ése es sospechoso**: significaría que algo no se está midiendo.

## [GitHub] — 2026-09-09 · TRABAJO EN CURSO de `REQ-023`, detenido a media vuelta y **no acreditado**
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus), detenido · medición y consignación: coordinadora.

**Esto NO es una entrega. Se comitea para que el trabajo viaje a otra máquina, no porque esté validado.**
El `desarrollador` de `REQ-023` (vuelta 1 de 3) fue detenido a petición del propietario **justo antes de
correr la sección 39** — sus últimas palabras fueron que iba a ejecutarla.

**Qué hay dentro:** 294 inserciones y 111 borrados en `hooks/lib.sh` (+99), `hooks/guard-completado.sh`,
`tools/arnes-lectura.sh`, `tests/escenarios/hooks/run.sh` y dos secciones del banco (39/1 y 39/2), sobre
`QA-023-01` (`usuario/dinero`, crítica): el alfabeto se deriva de las seis claves, **dos son
multi-palabra**, así que **contiene `0x20`**, y la guarda callaba en dos formas —cuando lo insertado
pertenece al alfabeto y cuando sustituye al blanco interno—, resolviendo el campo como **ausencia**.

**Medido por la coordinadora después de la parada**, que es lo único que hoy se puede afirmar:

- Banco completo: **962 PASS · 0 FAIL · 4 SKIP**, `rc=0`. Los cuatro SKIP son los de siempre, con su
  motivo declarado; **ninguno nuevo**.
- Autoprueba del corredor: **105 PASS · 1 FAIL** (antes 106 · 0). El FAIL es **`CA-18`**:
  `39-caracter-invisible-2-la-clase-y-el-corpus.sh` quedó en **402 líneas contra su techo de 400**. La
  acción conforme es **partir la sección**, nunca subir el techo; el agente fue detenido antes de hacerlo.

**Lo que un banco verde NO acredita, y hay que decirlo aquí o se lee al revés:** el **fail-before /
pass-after**. Nadie ha comprobado que el caso nuevo **falle** contra el código anterior, así que el
verde **no prueba todavía que el caso discrimine** — podría estar pasando por tautología, que es
exactamente el defecto que la reescritura de `CA-03` existía para cerrar. Eso lo decide QA.

**Al retomar:** partir la sección 39/2 para volver a poner `CA-18` en verde, acreditar el
fail-before/pass-after, y sólo entonces pasar a QA. `Estado` de `REQ-023` sigue en `en-revisión` y sus
cinco hallazgos siguen abiertos: **este commit no cierra ninguno**.

## [GitHub] — 2026-09-09 · `REQ-027` COMPLETADO: la cláusula que impide que un pendiente desaparezca al cerrar
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` (Opus) + `qa-tester` (Opus) + `auditor-seguridad` (Opus) + coordinadora.

Ciclo de §6 recorrido **en orden y completo** en una sola sesión, después de un cambio de cuenta que
mató todos los subagentes reanudables: analista → QA → auditor. Ninguna fase se solapó.

**Los dos write-backs, de una cláusula cada uno.** `QA-027-06` (`instrumento`): `CA-05` pasa a
**1.037 B** y **1.844 B**, nombrando la convención —cada blanco se atribuye al tramo que cierra— que es
la única con la que **suma** el desglose que el propio criterio cita como su corrida. Las dos cifras
eran ciertas sobre rangos distintos; lo que no puede ser es que el número del criterio no aparezca en
su propia corrida. El **49,8 %** y el techo de **3.703 B** no se mueven, y eso queda escrito.

**`QA-027-07`** (`contrato`, el que bloqueaba): `CA-10` declara ahora **qué se acreditó y qué no**. Lo
acreditado es la **conducta transcrita**, con dos corridas independientes; la **vía real
—`/arnes-upgrade` invocado— queda pendiente**, con dueño **coordinadora**, vencimiento «antes de que un
proyecto real migre a 1.34.0» y puntero al artefacto. Sin esa cláusula el pendiente **desaparecía al
cerrar**, porque su dueño no es el REQ: deriva por omisión que `guard-completado` no puede ver.

**QA aprobó en confirmación documental** (3.ª vuelta) sin re-medir nada, apoyada en que `AGENTS.md`, la
plantilla y la skill no cambian desde `a41f8ea`. Y falsó lo que había que falsar: la cláusula nueva se
inserta **antes** del párrafo de condición de entrega, que **no aparece en el diff** y sigue siendo la
última palabra de `CA-10`. Un pendiente bien declarado que aflojara la puerta habría convertido su
propio hallazgo en un permiso.

**Auditoría `R-023`, primera de este REQ**, y corrigió dos cosas de su encargo: el primer `SEC` libre
era **074** y no 075 (la línea «próximos libres» de `R-022` no es un hallazgo), y el rango que se le dio
para comprobar que el REQ no toca el mecanismo era la ventana 1.33.0 entera — sobre la base correcta
(`6dd3f8a`+`cd5dc0c`) la afirmación se sostiene: **cero archivos** de `hooks/`, `tools/`, `.github/`,
`.arnes/` y `tests/`. Acreditó que la tabla de decisión de la migración es **fail-closed en todas las
cuentas** —`UNKNOWN` es globalmente terminal y la fila de descarte está escrita **por propiedad**— y que
**no existe camino a «no tocar y no avisar» con el bloque ausente**. Las dos sedes son idénticas
(`md5` coincidente, 3.702 B), y el único `verificada` de `CA-07` **lo está de verdad**.

**Aceptó el residual de `CA-10` para cerrar**, con su motivo: el criterio contrata una conducta, se
comprobó dos veces, la vía real es **imposible de acreditar con un script** en este árbol, y el
write-back ya la llevó al contrato. *Vetar habría sido pedir una firma falsa.*

**Abierto y no bloqueante:** `SEC-074`, `SEC-076`, `SEC-077` (`instrumento`) más `QA-027-08`. Por la
regla de acumulación del propietario se registran sin abrir REQ ni entrar en la ventana.

**Aparte, y es decisión del propietario:** `SEC-075`. El auditor **discrepa de la clase** que le puso QA
—dice `contrato`, no `instrumento`— porque falta la entrada «Hacia 1.33.0» en `arnes-upgrade` siendo
1.33.0 la versión **publicada e instalada** que cambió andamiaje heredado, y porque el archivo ya declara
qué versiones no requieren migración: **un hueco sin nota no se lee como hueco**. `arnes-upgrade` no mide
nada, **es el canal de entrega**. No bloquea este REQ; debe resolverse **antes de publicar `v1.34.0`**.

**Cierre comprobado por la coordinadora en el momento de hacerlo:** quality gates en verde, cola de
aprobaciones en **0** entradas, y los cuatro hallazgos abiertos con su clase declarada.

## [GitHub] — 2026-09-09 · Re-validación de `REQ-027`: los cinco cerrados, tres nuevos, y una cita que se corrigió a sí misma
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus) + coordinadora.

Segunda vuelta, aislada con `git worktree` sobre `a41f8ea`. Antes de decidir qué no repetir, comprobó
`git diff --stat 6dd3f8a a41f8ea -- AGENTS.md templates/AGENTS.md.tpl` → **vacío**: el bloque es el
mismo, **y eso es lo que autoriza** a no re-validar `CA-01`/`06`/`07`/`09`/`10`/`11`. Y extrajo los dos
comandos **del texto literal de la skill** con `grep -o`, pasándolos por argumento a una transcripción
**nueva** — ni la del desarrollador ni la suya anterior.

**Los cinco hallazgos, CERRADOS.** `QA-027-01`: coherencia interna comprobada (1.036 + 807 = 1.843).
`QA-027-03`: las cuatro transiciones reproducidas exactas, y **la mitad que de verdad mata el fail-open
es contar también el marcador de CIERRE** — con las dos cuentas, incluso la cadena desnuda pasa a
`1/0 → UNKNOWN`, **fail-closed**. `QA-027-05`: `cmp` crudo difiere, sin el `\r` final idéntico.

**`QA-027-02` cerrado sobre la propiedad y no sobre tres celdas**, y con la frase que lo resume:
re-midió fila por fila hasta **3.702 = `wc -c`** y **reprodujo la causa** —`awk '{s+=length($0)+1}'`
da **3.607** (= `wc -m`), con `LC_ALL=C` da **3.702** (= `wc -c`)—. *«Encontrar que el defecto era el
instrumento, no el número, es mejor que el arreglo.»*

**`QA-027-04` cerrado, y QA se corrigió a sí misma:** su «629» **era correcta sobre `6dd3f8a`**, el
commit que midió, y se desfasó **porque `REQ-026` creció**. *«La lección —la línea sin su commit no
basta— aplica a mi cita igual que a la suya.»*

**Y suscribió la reclasificación de `-03` a `contrato` retirando su propio argumento:** la cláusula de
§6 que había invocado habla de **guardianes, lectores y pruebas**, y ésta era **la migración, que es el
entregable**. *«Un proyecto que nunca recibe las reglas tiene una coordinadora que decide distinto.»*

### Tres hallazgos nuevos

- **`QA-027-07`** (**`contrato`**, bloquea): el REQ **no declara** que la vía real de `/arnes-upgrade`
  no se ejecutó. Comprobado y no supuesto: `has("commands")` → **`false`**, no existe `commands/`, un
  solo archivo en la skill. **No retira la acreditación de `CA-10`** —el criterio dice que lo que se
  comprueba es **la conducta**, y se comprobó dos veces con transcripciones independientes— pero sin la
  cláusula el pendiente **desaparece al cerrar**, porque su dueño es la **coordinadora** y no el REQ.
- **`QA-027-06`** (`instrumento`): en `CA-05` deben quedar **1.037 B / 1.844 B**. Las dos cifras son
  ciertas sobre rangos distintos, pero **`CA-05` cita ese desglose como su corrida**, y la única
  convención con la que **suma** es la que atribuye cada blanco al tramo que cierra. *«Un criterio cuyo
  número no aparece en la corrida que él mismo cita es la forma leve del defecto que `QA-027-01` fue en
  su forma grave.»* El **49,8 % no se mueve**.
- **`QA-027-08`** (`instrumento`): **el motivo escrito para descartar el anclaje es falso contra su
  propia tabla nueva.** Medido: con las **dos** cuentas, un espacio final da `0/1 → UNKNOWN` con **1**
  bloque, y tras los dos marcadores `0/0` salta la guarda de `## 14.` → `UNKNOWN`, **1** bloque.
  **El anclaje nunca produce `NUEVO` ni dos bloques** con la conducta de este tramo: ese escenario sólo
  existía con la de **una** cuenta, que este mismo tramo eliminó. **La decisión de no anclar sigue
  siendo correcta por otra razón que sí se sostiene.** Pesa porque la skill **la heredan los
  proyectos** y porque la regla **`B.1`** del bloque que este REQ entrega dice exactamente esto.

### `CA-08` señal (c): PENDIENTE, y no se inventa

QA explica por qué no puede tomarla: el **numerador** es el `subagent_tokens` que el arnés reporta **al
terminar su proceso**, así que **existe fuera de ella** y sólo lo ve quien despacha. Y un hecho que
cambia quién es «la primera»: el bloque existe desde `6dd3f8a`, luego la primera comisión despachada ya
con él fue **su 1.ª vuelta**, cuyo `subagent_tokens` es **140.349** — dato conservado en
`docs/ESTADO.md` para que no se pierda. Además **`CA-08` no define qué cuenta como «un resultado
entregado»**, así que cualquier razón formada hoy sería **incomparable** con la de otra comisión.

### Dos residuos juzgados, y un forzador que QA corrigió a la coordinadora

Citar el marcador entero en prosa es **aceptable**: medidas **las dos** formas, ambas terminales y con
archivo intacto (`2/2 UNKNOWN` rc 3 y `1/1 MODIFICADO` rc 2); la alternativa exigiría interpretar
contexto Markdown, «la clase de detección que termina con alguien apagando el guardián». Y sobre que
ninguna puerta lo vigile: **no comparte** que la candidata sea `REQ-025` —`skills/` no está en el banco
y esperar un comprobador completo es **desproporcionado**—; el forzador barato es **la aserción de una
línea que ella misma corrió**.

**Con los dos write-backs de una cláusula hechos y sin re-medir nada más, QA aprueba.** El cierre
además exige `Seguridad: aprobado`, hoy `pendiente`.

### Sesión detenida por cambio de cuenta

El `desarrollador` de `REQ-023` se detuvo **antes de escribir un byte** — cero pérdida, ninguna
comisión viva. El punto de retomada, con los cuatro pasos en orden y el encargo de la vuelta 1
resumido, queda en `docs/ESTADO.md` §«⏸ SESIÓN DETENIDA».

## [GitHub] — 2026-09-09 · `REQ-023 CA-03`: un sorteo que puede fallar, y `CA-12 (iii)` fuera de alcance con su nombre
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` (Opus), `desarrollador` (Opus).

Write-back de **`QA-023-02`** y **`QA-023-03`** (los dos `contrato`). Ningún hallazgo cerrado: los
cinco siguen en el campo, y `CA-03` **sigue en rojo** hasta que el `desarrollador` arregle
`QA-023-01` — la rama 2 es, **por diseño**, la que hace fallar el caso hoy.

### `CA-03`: veredicto por rama, sorteo estratificado, tres procedimientos

**Por qué ninguna vía sola servía**, escrito por el analista: hacer el criterio satisfacible **no
garantiza que el sorteo LLEGUE** a la rama que hoy abre; y acotar el universo por propiedad vuelve a
ser *«seleccionado para no intersecar la guarda»* — **la tautología un paso más allá**, que es lo que
QA condenó. Y descartó el SKIP como respuesta principal con un motivo fino: la rama de `a`→`QaA` **no
es una abstención por falta de datos**, es una tirada sobre la que `CA-01` **no promete nada**, y
llamarla SKIP confundiría «no medí» con «no exige».

- **Universo sin acotar.** Lo que cambia es que el sorteo se **estratifica** en **E1** (complemento del
  alfabeto) y **E2** (el alfabeto mismo), los dos **derivados de la constante única de claves de
  `CA-06`** y **ninguno escrito a mano**, con no menos de una tirada por estrato.
- **Tres procedimientos:** insertar · sustituir un **blanco interno** · **duplicarlo**, y en éste **la
  entrada se toma de la clave misma** — ni sorteo ni lista. Es la tirada que hoy abre.
- **Veredicto por rama:** E1 → **DENY**. P3, y E2 cuando la entrada es el blanco → **DENY** (hoy abre).
  E2 no-blanco → **ningún veredicto exigido**, publicado y etiquetado «fuera de la propiedad de
  `CA-01`» y **no juzgado**, porque ahí una persona ya no lee una declaración de ese campo.
- **Anti-tautología COMO CRITERIO:** publica cuántas tiradas cayeron en cada rama **junto a la
  semilla**; **SKIP con motivo, nunca PASS**, si alguna rama de DENY se queda sin tirada; y **un pool
  escrito a mano o elegido para no intersecar el alfabeto INCUMPLE** el criterio, con `QA-023-02`
  citado.
- **Satisfacibilidad comprobada, no supuesta:** existe un mecanismo conforme —reponer un blanco en el
  sitio de la retirada y **colapsar blancos repetidos** antes de preguntar si lo que queda **es** una
  clave—, que cubre la sustitución (NBSP/TAB) y la duplicación **sin denegar nada legítimo**. Derivado
  **leyendo, no ejecutado**; la elección del mecanismo es del `desarrollador`.

**Y una premisa medida FALSA, corregida dentro del propio criterio:** el homóglifo no queda fuera
porque «la clave resultante no contenga nada ajeno al alfabeto» —**lo contiene y la guarda lo ve**—
sino porque **retirar lo ajeno no repone lo sustituido**. El reparto no cambia; lo que separa el
blanco (dentro) de la letra (fuera) es que **reponer un blanco no elige entre candidatos y reponer una
letra sí**.

### `CA-12 (iii)`: este REQ NO la cierra, y el motivo no es de calendario

La superficie **no es el segmento de clave** —donde esta guarda se ejerce— sino la regla de **corte**
de la cabecera: el `## ` no tiene clave ni valor, así que es **otra comprobación en otro punto** del
escáner, y arrastra la fila de `AGENTS.md` §13 que promete ese corte, **superficie heredada con gate
humano**. Meterla ahora sería alcance nuevo **por delante de `QA-023-01`**, que es lo que bloquea.

Ítem en «Fuera de alcance» con motivo, la medición y **sus dos controles en las dos versiones**,
dueños repartidos, **ventana propuesta 1.35.0 — la decide el propietario**, clase `instrumento`
**declarada ahí porque ningún `SEC` la abrió**, y **forzador**: que un texto firmado prometa **sin
condición** que los campos valen sólo en la cabecera mientras esto siga abierto.

**Y un cambio que vuelve mecánica la verificación:** `CA-12 (iii)` ahora dice **cuáles** son las
superficies nombradas —**tres**: homóglifo, NUL/UTF-16 y ésta— para que comprobarlo sea **contarlas**
contra el apartado, en vez de **leer intención**.

### Aviso de enrutado que el analista deja explícito, y no resuelve por su cuenta

`QA-023-04` vive en **dos derivaciones que NO están en `Archivos:`** (`36-…-2-los-lectores.sh:228` y
`36-…-3-comentar-retira.sh:33`). Si el arreglo del `desarrollador` las escribe, **el campo se queda
corto**. *«Dilo tú al despachar; yo no lo amplío porque no sé si el arreglo elegido las toca.»* Va en
el encargo como condición de parada.

## [GitHub] — 2026-09-09 · QA de `REQ-023`: `SEC-047` NO está cerrado, y el alfabeto contiene un espacio
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

`QA: con-hallazgos`. `Estado: en-revisión → en-progreso`. Cinco hallazgos, **tres bloquean**. Vuelta
**1 de 3**.

### `QA-023-01` (`usuario/dinero`, severidad crítica) — la remediación no cierra su propia fila 1

El alfabeto se deriva de las seis claves y **dos son multi-palabra**, así que **contiene `0x20`**. La
guarda borra lo **ajeno** al alfabeto y pregunta si lo que queda **es** una clave:

- si lo insertado **pertenece** al alfabeto, **no se borra**;
- si **sustituye** al espacio interno, **se borra y el espacio no se repone**.

En los dos casos `arnes_en_vocab` dice no y **la guarda calla** ⇒ se resuelve como **ausencia**, que es
justo lo que la puerta perdona. Medido con controles en la misma tanda: `U+0020`, **NBSP** y **TAB**
dan **allow en las dos versiones**; `U+FEFF` y `Ω` dan **deny** sólo en la nueva. Es **la fila 1 de
`SEC-047` con otro carácter**: cierra a `completado` con `QA: pendiente` y `Seguridad: pendiente`.

**No lo tapa el «fuera de alcance» del homóglifo:** la premisa de ese apartado —«la clave resultante no
contiene nada ajeno al alfabeto»— es **falsa** para NBSP y TAB; y el caso del espacio es el
**procedimiento de inyección** que `CA-03` fija, con una entrada de **su propio universo declarado**.
Y **`instrumento` no aplica**: la tabla lo reserva para defectos «sin efecto en el producto», y aquí el
producto **es** la guarda.

### `QA-023-02` (`contrato`) — un sorteo que no puede fallar, y una tensión insatisfacible

El sorteo de la entrada **reservada** no ejerce el universo que `CA-03` declara: `RES93_POOL` son
**doce imprimibles escogidos a mano**, todos fuera del alfabeto, así que las ocho tiradas **deniegan por
construcción**. Medido que no es un detalle: **si el pool contuviera `U+0020`, el caso habría fallado**.
Y la tensión que el write-back tiene que resolver: **universo literal + «DENY en todas» no es
satisfacible**.

### `QA-023-03` (`contrato`) — `CA-12 (iii)` incumplido

Un `U+FEFF` delante del `## ` que termina la cabecera hace que **una línea del cuerpo se lea como
veredicto** (base allow / nuevo allow; **sin** el BOM deniega; **sin** la línea en el cuerpo deniega).
Misma propiedad, **no es regresión**, y **no está nombrada** en «Fuera de alcance».

### `QA-023-04` (`instrumento`) — un guardián que envejeció hacia el lado que abre

**No hay cuarta derivación**: son tres, las tres nombradas. Pero **una se estrechó**:
`36-…-2-los-lectores.sh:228` pasó de **6 a 5** claves y **perdió `Estado`**, porque su `sed` casa
literales entre comillas simples y los brazos ahora usan `"$ARNES_CLAVE_ESTADO"`. **Ninguna prueba
falló**: la anti-vacuidad sólo distingue vacío de no vacío. Un guardián que envejeció hacia el lado que
abre, **sobre la clave que decide el cierre** — y es consecuencia directa del arreglo que la
coordinadora pidió.

### Lo que QA reprodujo, y lo que sostiene la cota

**Doce casos** de fail-before/pass-after, no dos, con **cuatro controles**; el del control «sin el
carácter» es **md5 idéntico** en las dos versiones. **`LC_ALL=C` es `local` de verdad**: tras la guarda
`LC_ALL` no existe en el ámbito global y `${#"áé"}` sigue siendo 2. **Dominio 5 de 6 confirmado**, con
`Estado` dentro y `Seguridad` fuera. **`CA-04`: 0 divergencias** sobre 3.687 líneas y **0 falsos
positivos** sobre 382 cabeceras reales.

**La cota de `CA-09 (ii)` no sigue en pie como demostración, y ceden DOS premisas, no una:** la guarda
no queda contenida —comparación por línea en `arnes_campo_linea` **más** `arnes_en_vocab` por línea en
`arnes_campos_req`— y añade dos llamadas. Lo que sostiene la conclusión es **medición**, y la de QA es
**más estricta** que la del desarrollador: **1,116×** sobre el camino de cabecera entero aislado
(k=100, r=6, mínimo de k) contra techo 1,25×. **No es hallazgo** — el criterio exige medición y la
medición cumple. Pero queda dicho que **la cota no es reutilizable: está rota, no debilitada**.

**Y el despacho ya no decide quién es campo**, verificado: `arnes_en_vocab … || continue` va **antes**
del `case`, y las transcripciones del conjunto pasan de 2 a 1.

**Vencimiento de `SEC-047` EN RIESGO:** su fila 1 sigue cerrando un REQ `critico` sin validar ni
auditar, y el vencimiento es **el cierre de 1.34.0**.

## [GitHub] — 2026-09-09 · La migración contaba menciones y no marcadores: un fallo en abierto que dejaba al proyecto sin las reglas, en silencio
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

**`QA-027-03`, cerrado en la conducta y medido en los dos sentidos.** La entrada «Hacia 1.34.0» de
`skills/arnes-upgrade/SKILL.md` prescribía decidir con `grep -c 'arnes:coordinacion:inicio'`, **sin los
delimitadores del comentario**: eso cuenta **menciones, no marcadores**. Un `AGENTS.md` de proyecto
**sin** el bloque que cite la cadena desnuda **una vez** —la nota de migración que el propio proyecto
se escribió— devolvía **1**, la tabla de decisión leía «ya está» y **el proyecto nunca recibía las
reglas, sin aviso**. Ahora se cuenta el **marcador completo** y **también el de cierre**, que es lo que
las filas `1/0`, `0/1` y `2/1` de la tabla ya necesitaban.

**Fail-before / pass-after, con los comandos extraídos del texto literal de la skill** (antes:
`6dd3f8a:773`; después: el árbol de hoy) sobre maquetas construidas desde
`git show 4f647c7:templates/AGENTS.md.tpl`: proyecto sin bloque que menciona la cadena **1 → 0**
(`NUEVO`, recibe las reglas); con dos menciones **2 → 0** (adiós al `UNKNOWN` espurio); proyecto **ya
migrado 1 → 1** —el positivo sigue detectándose, sin regresión—; migrado que además menciona la cadena
**2 → 1**.

**La alternativa se midió y se descartó por su modo de fallo, que es la parte que no se adivina.**
Anclar el patrón a la línea entera (`^…-->$`) arregla además el único residuo, pero un **espacio final**
dejado por un editor lo baja a **0**, y `0` manda a `NUEVO`, que *añade* el bloque y deja **dos**:
cambia un fallo en abierto por otro **peor** —el primero omite las reglas, el segundo rompe la
idempotencia que `CA-10` contrata—. Entre dos detecciones imperfectas se elige la que **falla
cerrada**. El residuo queda **declarado en la propia entrada**: un proyecto que cite el marcador
**entero** en su prosa da **2 → `UNKNOWN`**, que se detiene y pregunta.

**`QA-027-05` (CRLF) entra en el mismo tramo, y no queda como deuda.** «Contenido idéntico» se decide
ahora **tras quitar el `\r` final** de cada línea —la misma normalización que `hooks/lib.sh` ya aplica—,
así que un proyecto Windows que normaliza el archivo entero después de migrar deja de producir un
`MODIFICADO` **falso**. Medido: `cmp` crudo **difiere**, `cmp` con el CR final quitado **idéntico**. Dos
límites dichos: es el `\r` **final** y sólo él, y la comprobación de idempotencia **entre corridas**
sigue siendo `cmp` byte a byte, sin normalizar.

**Y lo que NO se acredita, que es la mitad del encargo: la vía real de `/arnes-upgrade` queda
PENDIENTE.** El desarrollador reprodujo `CA-10` con su transcripción y QA con la suya, y **ninguno
ejecutó `/arnes-upgrade`**: lo acreditado es *«el comportamiento contratado, tal como se transcribió»*,
no *«la vía real funciona»*. Comprobado por qué no se puede desde aquí: `skills/arnes-upgrade/`
contiene **un solo archivo** (`SKILL.md`), `plugin.json` **no** declara `commands`, y las herramientas
de un subagente no despachan una skill. **No se acredita con un script — ni el propio ni el de QA.**
Queda construida la maqueta para que la corrida pendiente no empiece de cero
(`/tmp/arnes-maqueta-req027`, constructor re-derivable en `/tmp/construir-maqueta-req027.sh`, versión
base `4f647c7`): repositorio git limpio, plantillas de origen para que la Fase 1 acredite el origen
como **CONFIRMADO**, texto humano propio en `## 20.` y el caso negativo de `QA-027-03` en `## 21.`.
Dueño: la coordinadora. Vencimiento: **antes de que un proyecto real migre a 1.34.0**.

**`QA-027-02`: el desglose se rehizo entero en bytes, y ahora se ve sumar.** Ocho filas con su **rango
de líneas** y su `wc -c`: 67 · 53 · 415 · 25 · 999 · 1.037 · 299 · 807 = **3.702 B** el bloque, **+1 B**
el separador = **3.703 B** el delta del archivo. Faltaba una fila —el encabezado
`**B. Las siete reglas:**`, 25 B— y tres iban en caracteres. **La causa era el instrumento, no la
cuenta:** el método declarado era «`awk` sumando `length($0)+1`», y `awk` cuenta **caracteres** en
locale UTF-8 mientras el total venía de `wc -c` (medido: 3.607 con `awk`, 3.702 con `LC_ALL=C awk`).
El §0 del artefacto ya prohibía mezclar magnitudes y no bastó porque **la prohibición nombraba una
magnitud y la tabla usaba otro instrumento**.

**`QA-027-04`: las citas, contra un commit nombrado.** El negativo de `CA-04` apuntaba a
`REQ-026.md:88-101`, que es el rango de **`81024c6`**; ahora cita `01dc927` con `CA-13` en la línea
**149** y `CA-17` en la **268**, y dice contra qué commit se midió. Se encontró y corrigió **una
segunda cita desfasada de la misma clase que el hallazgo no traía**: el Historial de `REQ-026` que
registra la contradicción está en la línea **679**, no en la 629 (la 629 habla del coste de `CA-15`), y
el commit corrector `097c50b` **no aparece nombrado** en el REQ: se identifica por su mensaje.

`templates/AGENTS.md.tpl` **no** se tocó y el arreglo no lo exige: el marcador ya vive ahí en su forma
completa (línea 420) y lo defectuoso era el comando que lo cuenta. `cmp` de las dos sedes sigue sin
salida, 3.702 B cada una.

**Banco completo, una corrida sobre el árbol de este tramo: 961 PASS · 0 FAIL · 4 SKIP, `rc=0` —
total 965, 68 s.** Mismo total que la referencia del propietario (960/0/5 sobre `802b47d`): la
diferencia es el caso de `REQ-017 CA-09`, que alterna PASS/SKIP por ruido. `skills/` **no** está en el
banco, así que esta corrida es **testigo de no-regresión**, no acreditación del arreglo — eso lo dan
las maquetas. Los 4 SKIP traen su motivo y ninguno es de este tramo.

**Ningún hallazgo se cierra aquí:** cerrarlos es de QA al re-validar. `Estado: en-progreso`, `QA:` y
`Seguridad:` sin tocar, y `CA-10` de `REQ-023` **deliberadamente fuera** de este tramo por haber un
`qa-tester` vivo escribiendo `requirements/REQ-023.md`.

## [GitHub] — 2026-09-09 · Punto de continuidad vigente, y una sección del propio tablero marcada como falsa
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Punto de continuidad consolidado en `docs/ESTADO.md`, **fuera de los marcadores derivados** y marcado
`★ VIGENTE` porque el tablero acumulaba **tres** secciones de continuidad solapadas. Lleva: alcance
vigente, estado por REQ **medido en el momento**, los **dos agentes vivos y los dieciocho reanudables
con su identificador**, la evidencia **enlazada y no copiada**, la siguiente acción en cinco pasos con
su dependencia concreta, y el coste.

**Y un defecto del propio tablero, marcado en vez de borrado:** la sección «Deuda anotada» del
2026-09-08 **contradecía** a la vigente y tenía **tres datos falsos** — «20 fechas un día por delante»
(la deuda **nunca se comprobó**; medido: 15 apariciones, **0 desfasadas confirmadas**, y `git blame` no
sirve en 14 de 15), «falta la entrada de Migraciones conocidas» (**existe** desde `6dd3f8a`) y «el
techo de 2.600 B sin validar» (**se validó, no cabía, se re-derivó**). Se marca con el desglose de qué
era falso: verlo señalado enseña más que verlo desaparecer. Lo único que seguía siendo cierto es que
**el consumo de la coordinadora no está instrumentado**.

**Dos instrucciones del propietario registradas donde las ejecutará quien deba:**
- **`REQ-027 CA-08` señal (c) se toma DE OPORTUNIDAD**, como subproducto del próximo encargo que cargue
  el bloque, **nunca con una comisión propia**; y el numerador ya existe sin medir nada nuevo — el
  `subagent_tokens` que el arnés reporta al terminar cada comisión. Mientras no se tome, la consecuencia
  contratada sigue en tres sitios: **no se declara que las reglas sirven**.
- **Las limitaciones de Codex y Cursor se conservan en tabla con su motivo**, para que nadie las
  ascienda por descuido: de Codex sólo hay una **afirmación del fabricante**, que la regla `B.1` no
  acepta como observación; Cursor **no está instalado**. Consecuencia dicha como es: **el REQ entrega su
  objetivo para UNA de las tres herramientas**.

## [GitHub] — 2026-09-09 · `REQ-027 CA-05`: los bytes en bytes, y las dos magnitudes separadas donde se confundían
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Write-back de **`QA-027-01`** (`contrato`). Los dos números corregidos **en los dos sitios y en bytes**:
`D` **776 → 807 B**, y `B.7` + `D` **1.812 → 1.843 B**, con «el 49 %» → **«el 49,8 %»**. `B.7` = 1.036 B
no se toca: ése ya estaba en bytes, y es **la mitad que hacía la suma inválida**.

**La causa queda nombrada en el Historial, no sólo corregida:** los **776 eran caracteres** (`wc -m`)
sumados a **1.036 bytes**. Es la misma clase que hoy obligó a corregir `REQ-019` —suelo medido en
**líneas** contra un techo que se paga en **bytes**— y por eso se escribe la causa y no sólo el número.

**Y queda escrito que el techo NO se invalida:** los **3.703 B** siguen en pie, reproducidos por QA en
los dos archivos, y la corrección **refuerza** el criterio — hay **más** contenido contratado de lo que
se decía, no menos, así que el argumento de `CA-05` para no recortar es más sólido.

**La distinción de las dos magnitudes queda en el cuerpo de `CA-05`**, con su sede elegida y
justificada: **3.702 B es el bloque** —lo que compara `CA-01`— y **3.703 B es lo que añade al archivo**
—lo que contrata `CA-05`—, es decir el bloque más su línea en blanco separadora. Las dos correctas. Se
puso ahí, y no en `CA-01`, porque **es el único punto donde las dos cifras se leen juntas, que es donde
se confunden**.

**`QA-027-01` sigue ABIERTO:** cerrarlo es de QA al re-validar. Y el analista declara que **no
comprobó por su cuenta** los 807 B ni los 3.702/3.703 — los toma de la medición de QA, **citada y
atribuida** en el REQ.

## [GitHub] — 2026-09-09 · QA de `REQ-027`: el techo re-derivado es legítimo, y dos magnitudes sumadas no lo son
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus) + coordinadora.

`QA: con-hallazgos`. `Estado: en-revisión → en-progreso`. Un bloqueante y cuatro `instrumento`.

**Cómo aisló la medición, y por qué importa:** usó un **`git worktree`** en vez de `stash`,
`checkout .`, `restore .`, `reset --hard` o `clean -f` —los cinco de `git.prohibidos`— y con eso
**probó por construcción** que los **5 FAIL** que la coordinadora había medido en el árbol de trabajo
**no eran de `REQ-027`**: en el worktree limpio sobre `6dd3f8a`, **920 PASS · 0 FAIL · 4 SKIP**,
`rc=0`. Después comprobó que sus tres archivos **no cambian** entre `6dd3f8a` y HEAD, así que el
veredicto vale sobre el árbol actual. Es la respuesta correcta a un árbol con comisiones vivas.

**El re-derivado del techo queda ACREDITADO, con sus tres condiciones verificadas:** que `CA-05` lo
ordena textualmente y prohíbe recortar contratado; que el recorte fue **de relleno** —comprobado
**componente a componente**: `B.7` trae los seis que exige `CA-11` y `D` las tres vías con estado más
los dos límites de `CA-07`, **no falta nada contratado**—; y que el número **sale de una medición**:
37.530 − 33.827 = **3.703 exactos**, en los dos archivos, sin holgura.

**Y resolvió el «3.702 vs 3.703» que parecía una cifra que no cuadraba: son DOS magnitudes.** 3.702 es
**el bloque**, que es lo que compara `CA-01`; 3.703 es **lo que añade al archivo**, que es la magnitud
que `CA-05` contrata — bloque más la línea en blanco separadora. Verificado quitando tramo **y** línea:
el archivo vuelve a `4f647c7` byte a byte.

**Idempotencia REPRODUCIDA con transcripción propia**, no reusando el script del desarrollador: tres
corridas `NUEVO`→`INTACTO`→`INTACTO` con **el mismo md5**, `cmp` sin salida, **5** negativos con
archivo intacto —incluido **uno que el desarrollador no probó**: cierre antes de apertura— y el
fail-before donde un reemplazo ciego **borra el texto humano del proyecto**. Sus bytes absolutos **no**
coinciden con los del desarrollador, y explica por qué es correcto: el artefacto **no registra qué
texto humano puso**, así que **ese md5 no es re-derivable por nadie**. Lo que reproduce es lo
contratado.

### `QA-027-01` (`contrato`, bloqueante) — dos magnitudes sumadas

`REQ-027:84` y `:312` afirman `D` = **776 B** y `B.7`+`D` = **1.812 B** = «el 49 %». Medido:
**`D` = 807 B**, total **1.843 B**, **49,8 %**. Los 776 son **caracteres** (`wc -m`), no bytes, de modo
que **1.812 = 1.036 bytes + 776 caracteres** — exactamente la mezcla de magnitudes que el §0 del propio
artefacto declara no hacer. **No invalida el techo** (los 3.703 B están reproducidos) y **refuerza** la
conclusión: hay **más** contenido contratado, no menos.

**La coordinadora propagó esa cifra al `CHANGELOG` de `802b47d`**, escribiendo «`D` (776 B) — 1.812 B,
el 49 %». **Queda rectificado aquí**, sin reescribir aquella entrada (§9): los números correctos son
**807 B**, **1.843 B** y **49,8 %**.

### `QA-027-03` (`instrumento`) — el más consecuente: un fail-open silencioso en la migración

`skills/arnes-upgrade/SKILL.md:773,777` prescribe `grep -c 'arnes:coordinacion:inicio'` **sin los
delimitadores**, así que **cuenta menciones, no marcadores**. Medido: un `AGENTS.md` de proyecto **sin
el bloque** que cite la cadena desnuda una vez da **1** ⇒ la tabla de decisión lee «ya está» y **el
proyecto nunca recibe las reglas, en silencio**. Dos menciones dan `UNKNOWN` sin motivo. El arreglo es
**una línea** —contar el marcador completo—, verificado que así resiste.

### Los otros tres, y lo que declaran

`QA-027-02`: el desglose del artefacto suma **3.626 B** y no 3.703 —falta una fila de 25 B y tres van
en caracteres—; correcto en bytes da 3.702. `QA-027-04`: una cita de rango apunta a las líneas de
`81024c6` y no de `6dd3f8a`. `QA-027-05`: un proyecto Windows que normaliza a **CRLF** tras migrar da
`MODIFICADO`/conflicto **falso** — fail-closed y sin pérdida.

### Lo que este REQ NO entrega, dicho con claridad

**`CA-08` señal (c)** sigue sin tomar, y QA acredita que **nadie escribió lo contrario**: el REQ, el
artefacto y el `CHANGELOG` dicen los tres **«no se declara que las reglas sirven»**. Y el descarte de
Codex es **correcto** —una afirmación del proveedor no es la observación de que el bloque llegue a una
coordinadora—, luego **el REQ entrega su objetivo para UNA de las tres herramientas**, y así hay que
decirlo. Cursor no está instalado. Que una coordinadora **aplique** las reglas **ninguna puerta lo
mide, y ninguna debía**.

## [GitHub] — 2026-09-09 · `REQ-026` ajuste de alcance, `REQ-027` entregado y `REQ-023` entregado
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` (Opus), `desarrollador` (Opus) ×2, coordinadora.

### `REQ-026` — ajuste de alcance por decisión del propietario (2026-09-09)

`CA-18 (i)` y `CA-05` conservan su garantía **absoluta y vigente**; `ADR-008` queda en `Estado:
propuesta` **y sin aplicar**; `SEC-072` y `SEC-073` **abiertos**; `Estado: en-revisión` intacto por
instrucción expresa. Todo el código y toda la evidencia **se conservan**: mecanismo, testigo, 37
casos, mediciones, ADR y artefactos. La idempotencia del re-archivado queda **aplazada** y la rotación
de `requirements/` **desactivada**.

**La cadena de publicación, escrita con su fuente:** los dos hallazgos son `contrato` y están en
`Hallazgos abiertos:` ⇒ `guard-completado` **deniega** el cierre (§6/§13) ⇒ con cualquier `contrato`
abierto **el tag vuelve al propietario** (su decisión del 2026-09-08; la delegación **no aplica**) ⇒ su
instrucción vigente de no publicar sin resolver o aceptar ⇒ **`v1.34.0` no se publica y `REQ-026` no
llega a su estado terminal**. Y en la misma frase: **no hay riesgo vivo** — rotación apagada, **ningún
REQ real rotado nunca**, los dos residuos **latentes**.

El vencimiento de la idempotencia **no queda sin fecha**: sigue anclado a «antes de que se declare
`CA-13`», que es correcto **porque `CA-13` también queda aplazado** — el día que se encienda, vence.
El analista **propone** sede propia en 1.35.0 para los cuatro criterios más la idempotencia, y **no la
creó**: abrir un REQ es abrir trabajo.

### `REQ-027` — las reglas en su sede canónica, y el techo que no cabía

`§14` en `AGENTS.md` y en `templates/AGENTS.md.tpl` entre marcadores, más la entrada «Hacia 1.34.0» en
`skills/arnes-upgrade/SKILL.md`. **Nueve de once criterios acreditados.**

**El bloque no cabía: 3.703 B contra 2.600 B propuestos (1,42×).** Se hizo una pasada de recorte de
**relleno**, medida (3.930 → 3.703 B), y después se **re-derivó el techo con entrada en Historial,
porque `CA-05` lo ordena y dice cómo**. Lo que no se recortó es `B.7` (1.036 B) y `D` (776 B) —
**1.812 B, el 49 % del bloque**— porque es **contenido contratado** que `CA-05` prohíbe recortar. En
palabras del desarrollador: *«no cambié ningún umbral para obtener verde: cambié el umbral porque el
criterio manda cambiarlo y dice cómo»*.

**Idempotencia MEDIDA**, que era condición de entrega: tres corridas con **el mismo md5**,
`NUEVO`/`INTACTO`/`INTACTO`, `cmp` sin salida, el `## 20. Instrucciones particulares` del proyecto
**intacto**; cuatro negativos con **archivo sin tocar**; y **fail-before** con una migración ingenua
que deja **2 bloques y borra el texto propio del proyecto**.

**`CA-08` señal (c) NO acreditada, y su consecuencia es contrato:** se fija en la primera comisión
despachada **ya con** el bloque, y ésta se despachó antes de que existiera ⇒ **no se declara que las
reglas sirven**. **Codex y Cursor siguen `no verificada`**: se encontró una **afirmación del
proveedor** y se descartó por insuficiente según la propia regla `B.1`.

**Línea base nueva que hereda 1.35.0:** `AGENTS.md` = **37.530 B**, verificado.

### `REQ-023` — la guarda nombra la propiedad, no el carácter (mitad 1 de `SEC-047`)

**Diez de doce criterios acreditados y medidos.** Banco **960 PASS · 0 FAIL · 5 SKIP**, total **965**
(de 924), `rc=0`, verificado por la coordinadora.

**El aviso de radio de la coordinadora era correcto pero INCOMPLETO, y el desarrollador lo completó
midiendo.** El inventario del contrato nombraba `tools/arnes-lectura.sh:69-72`; hay **dos derivaciones
más** por `sed` sobre el texto de los brazos `case` —`36-…-2-los-lectores.sh:228` y
`36-…-3-comentar-retira.sh:33`— y **ninguna estaba en `Archivos:`**. Su primera forma las rompió: son
los **5 FAIL** que la coordinadora midió en el árbol de trabajo. Forma final: los cinco brazos
conservan su literal y la **pertenencia** se pregunta a `ARNES_CLAVES`, así que el despacho existe pero
**ya no decide** quién es campo — que es literalmente lo que la factibilidad de `CA-06` pedía. **Radio
final: cero archivos fuera de su conjunto de escrituras.**

**El criterio de coste cazó un defecto en su propio código, y no se tocó el techo.**
`${clave//[!alfabeto]/}` en locale **UTF-8 es superlineal**: cociente **3,78** (1000→2000) y **5,59**
(2000→4000) contra techo **2,2**, y **5,053** sobre `arnes_norm_clave`. Con `LC_ALL=C` fijado con
`local` **dentro** de la guarda: **2,098** y **2,050**, y **17× más barata**. Era hallazgo contra su
propio código, así que el techo **queda intacto**.

**`CA-02`: el dominio es 5 de 6, no 4** — y la quinta clave es **exactamente `Estado`**, la que el
puntero medido falso de `CA-01` dejaba fuera. El defecto que el analista corrigió en el contrato
**tenía consecuencia medible**.

**Y una premisa declarada como NO cumplida entera:** la cota algebraica de `CA-09 (ii)` suponía la
guarda contenida en la función medida; la publicación añade una comparación **por línea** fuera de
ella y **dos llamadas** (builtins). Medido `1,002×` contra techo `1,25×`, con sujetos intercalados.

**No acreditados, por precondición ajena y sin forzarlos:** `CA-08` en su letra —espera el gate humano
de **`SEC-048`**, que sigue abierto— y **`CA-10`**, que necesita `AGENTS.md` y la plantilla, en manos
de la otra comisión. Queda por enrutar.

**Nota de mecanismo:** `guard-completado` **denegó** el primer intento de commit de la coordinadora
porque el comando escribía en `requirements/` y su texto mencionaba el estado terminal. Falso positivo
—no había transición— y es la **anchura deliberada** que §13 documenta. Se resolvió separando el
comando, sin alterar el contenido ni rodear ninguna puerta.

## [GitHub] — 2026-09-09 · REQ-023: el carácter que no se ve apaga el enforcement — la guarda pasa a nombrar la propiedad, y el techo de coste cazó la primera versión
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

**El defecto, medido idéntico en `v1.30.3`, `v1.31.0`, `v1.32.0`, `v1.32.1` y este árbol** (`SEC-047`,
severidad crítica, mitad 1): un carácter que no se ve y que el normalizador no retira **borra un campo
de la cabecera** de un REQ, y para todo campo cuya **ausencia** la puerta resuelve del lado que abre,
borrarlo es abrirla. Un **BOM** delante de `Sensible a seguridad: sí` con `Rigor: ligero` cerraba a
`completado` un REQ con `QA: pendiente` y `Seguridad: pendiente`. El diff no lo muestra, y PowerShell lo
añade al redirigir: no hace falta malicia.

**La guarda no persigue el carácter, persigue el estado** —una cabecera que no se puede **medir**— y no
enumera ningún carácter porque enumera **lo que ya está enumerado, que son las claves**: retirado de la
clave todo lo ajeno al **alfabeto** de las claves que el lector reconoce, ¿lo que queda **es** una de
esas claves? Añadir el BOM y el U+200B a una lista habría sido la **sexta** derrota medida de esa vía en
este repositorio.

- `hooks/lib.sh` — las seis claves de la cabecera se declaran **una** vez (`ARNES_CLAVES`, al estilo de
  `ARNES_VOCAB_*`); el **alfabeto** se **deriva** de ellas con escape de `]`, `-` y `^`, nunca se teclea.
  La guarda vive en `_arnes_clave_oculta` y la **publicación** en `arnes_campo_linea`, la única puerta de
  entrada — **no** en `arnes_norm_clave`, porque `arnes_estado_cabecera` la llama también con la línea
  **cruda, pre-cita**, y desde ahí `<!--Rigor: ligero-->` disparaba un falso positivo cuyo veredicto
  dependía de si quien escribió el comentario puso un espacio.
- `hooks/guard-completado.sh` — **dos** ramas de denegación nuevas, una por cada rama que ya tenía, con
  el motivo citando la línea y **los bytes ajenos en hexadecimal**: un carácter invisible dentro del
  motivo deja a la persona buscando texto que su editor no le muestra.
- `tools/arnes-lectura.sh` — lo reporta por su **vía única** (rc≠0), y el aviso va **antes** del descarte
  de «archivo sin `Estado:`», que es donde se escondía el caso peor: con el carácter sobre la clave del
  estado, el informe respondía `rc=0` sobre el documento más peligroso que hay. Su lista de campos deja
  de derivarse con `sed` **del texto del código** y se lee de la constante.

**Y lo que hay que llevarse de esta comisión: el criterio de coste cazó la primera versión de la
guarda.** `${clave//[!alfabeto]/}` en un locale **UTF-8** es superlineal —cociente de duplicación
**3,78** y **5,59** contra un techo de **2,2**—; con `LC_ALL=C` fijado con `local` **dentro** de la
función queda en **2,098** / **2,050** (par 1000→2000) y **17× más barata**. El techo **no se tocó**: era
un hallazgo contra el código. Medido además: **0 procesos** añadidos por evaluación y **1,002×** en el
reloj de la ruta crítica contra `v1.33.0`, con los dos sujetos intercalados en la misma invocación.
Método, versión base y **lo que cada número no acredita**: `docs/arnes/req-023-coste-y-dominio.md`.

**El dominio de campos cuya ausencia abre mide 5 de 6, no 4** — el quinto es **`Estado`**, justo la clave
que el puntero corregido de `CA-01` dejaba fuera. El banco lo **deriva midiendo en cada corrida**, no lo
enumera: es la forma que `SEC-050` existe para no repetir.

**Banco: 961 PASS · 0 FAIL · 4 SKIP** (`rc=0`, 924→965; los 4 SKIP son los heredados) con **41 casos
nuevos** en **cuatro** partes de la sección 39 — cuatro y no tres porque los lectores y el coste juntos
daban 422 líneas contra el techo de 400 de `REQ-014 CA-18`. Autoprueba del corredor **106 PASS · 0 FAIL**
y las tres quality gates de §7 en verde.

**Lo que NO entra, con su motivo, porque un verde parcial que se lee como completo es peor que un rojo:**
`CA-08` no queda acreditado en su letra —el fail-before está medido y es reproducible, pero **no** se
materializa `hooks/` desde un tag dentro del banco: su precondición es el gate humano de `SEC-048`, que
sigue **abierto**—; y `CA-10` **no se escribe**, porque `AGENTS.md` y `templates/AGENTS.md.tpl` los está
escribiendo otra comisión viva. `Estado: en-revisión`. `QA:` y `Seguridad:` sin tocar.

## [GitHub] — 2026-09-09 · REQ-027: las reglas de la coordinadora salen de la conversación y entran en la sede canónica — y el techo que nadie había validado no cabía
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

`AGENTS.md` §14 y `templates/AGENTS.md.tpl` traen, **byte a byte idénticos** y entre los marcadores de
contrato `<!-- arnes:coordinacion:inicio -->` / `<!-- arnes:coordinacion:fin -->`, las reglas de trabajo
de la sesión coordinadora: la **comprobación de antes de despachar** (cuatro preguntas, por escrito en
el encargo), las **siete reglas**, la **separación de responsabilidades** y las **vías de lectura con su
estado de verificación**. `Estado: en-revisión`. `QA:` y `Seguridad:` sin tocar.

**Las tres vías de distribución, todas entregadas — porque modificar una plantilla no actualiza los
proyectos existentes, y ése era el punto entero.** Este repositorio (`AGENTS.md`), los proyectos nuevos
(`templates/AGENTS.md.tpl` → `arnes-init`, verificado simulando la copia y la resolución de los 15
`{{…}}`: **0** marcadores sin resolver, **0** dentro del bloque) y los **ya instalados**, con la entrada
**«Hacia 1.34.0»** de `skills/arnes-upgrade/SKILL.md`, clasificada `NUEVO` y con su tabla de decisión.

**La idempotencia se midió, no se prometió.** Los marcadores hacen el bloque *identificable*;
idempotente es la conducta de contar antes de insertar. Tres corridas de la migración sobre un proyecto
maqueta: `NUEVO` → `INTACTO` → `INTACTO`, **31 886 B y el mismo `md5` en las tres**, `cmp` sin salida,
**exactamente un** bloque, y el `## 20. Instrucciones particulares` del proyecto intacto byte a byte. Y
el **par discriminante**, que es lo que le da valor: una migración **ingenua** falla las mismas tres
comprobaciones —deja **2** bloques y borra el texto propio de dentro de los marcadores—. Los negativos
`MODIFICADO` (conflicto), `## 14.` propia, apertura sin cierre y doble apertura (`UNKNOWN`) salen con
`rc` 2/3 y **el archivo sin tocar**.

**Y el número que nadie había validado: NO cabía, así que se re-derivó el techo en vez de recortar el
contrato.** `CA-05` proponía **2 600 B** declarándolo «límite propuesto sin validar». Medido al escribir
el bloque: **3 703 B**, **1 103 B por encima (1,42×)**. Antes de rendirlo se hizo una pasada de recorte
de relleno **medida** (3 930 → 3 703 B, **−227 B**: la tabla de las vías pasó a lista y salió la
instancia ilustrativa de la regla C, cuyo sitio único es el REQ). Lo que queda son `B.7` (**1 036 B**) y
`D` (**776 B**) —**el 49 % del bloque**—, enumerados componente a componente por `CA-11` y `CA-07`:
recortarlos era eliminar contenido contratado, que es justo lo que `CA-05` prohíbe. Techo re-derivado
**3 703 B**, ahora medición y no propuesta. **Línea base que hereda REQ-019: `AGENTS.md` = 37 530 B**
(33 827 + 3 703), y el **resto del archivo byte a byte idéntico** en las dos sedes: nada creció por la
puerta de atrás.

**Codex y Cursor siguen `no verificada`, y se buscó.** La documentación del propio Codex instalado
describe «Repository `AGENTS.md`: durable team conventions», pero eso es una **afirmación del
proveedor**, no la observación de que este §14 llegue a una coordinadora suya; por la regla B.1 no basta
para escribir `verificada`, y `CA-07` deja esa verificación fuera del REQ. De Cursor no hay nada.

**Lo que NO queda acreditado, dicho aquí y no sólo en el informe:** `CA-08` está **incompleto por
construcción** —su señal (c), tokens por resultado, se toma en la primera comisión despachada **ya con**
el bloque, y ésta se despachó antes de que existiera—, así que **no se declara que las reglas sirven** y
`REQ-025` no puede citar este REQ como evidencia de que bastan. **Ninguna puerta comprueba el bloque**:
es regla escrita, y `CA-11` lo declara como límite.

Evidencia en disco con **versión base (`4f647c7`), método y desglose elemento por elemento** —lo que la
propia regla B.7 exige, aplicada a sí misma— en **`docs/qa/REQ-027.md`**. Banco completo: **920 PASS ·
0 FAIL · 4 SKIP**, `rc=0`; quality gates de §7 en verde.

## [GitHub] — 2026-09-09 · `ADR-008`: dos residuos, dos preguntas, y hoy no hay nada que firmar
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus) + coordinadora.

`docs/decisions/ADR-008-garantia-de-la-rotacion-de-seccion-frente-a-escrituras-concurrentes.md`,
`Estado: propuesta`, enlazado desde `CA-18 (i)`, `CA-05` y el Historial. Sólo evidencia existente.

**El propietario impuso el reencuadre que hizo útil este ADR:** *«`SEC-072` no depende necesariamente
de aceptar una excepción: también podría resolverse corrigiendo el mecanismo y verificándolo. El ADR
debe presentar ambas alternativas, sin convertir tu firma en la única salida.»* El marco que la
coordinadora había dado —«qué garantía se contrata»— **convertía la firma en la única puerta**, y no lo
es.

**Lo que se evaluó y salió NO, con evidencia del estado actual del árbol:** se preguntó si `3+5`
—sacar la rotación del hook de parada más idempotencia del re-archivado— cumple las **dos** promesas
absolutas sin excepción. **No.** La `5` cierra el residuo de interrupción; la `3` **no** cierra el de
publicación **por mecanismo** —el intervalo sigue ahí; el sustrato no cambia porque cambie quién
invoca—, sólo bajo la precondición «nadie más está editando», que **el arnés no puede medir** y que en
el momento de escribirlo **era falsa por observación directa: dos `desarrollador` escribiendo a la vez
en este mismo árbol**. La única vía B que cumple las dos por mecanismo es **no rotar `requirements/`**,
eliminando el caso.

**La decisión se parte en dos, porque los dos residuos no son la misma pregunta:**
- **`CA-05`** tiene arreglo **por mecanismo** (idempotencia del re-archivado): vía B, **sin firma de
  garantía**, y el criterio vuelve a ser absoluto.
- **`CA-18 (i)`** no tiene ninguno en este sustrato. Su vía A exige aceptar un riesgo cuya magnitud
  **nadie ha medido**, así que la alternativa «medir el intervalo residual» se **reclasifica como
  precondición**, no como alternativa. Y hoy esa medición **no está disponible**: el instrumento se
  declaró **no convergente** y depende de `REQ-021`, `bloqueado`. **La decisión queda abierta y
  escrita, no resuelta por silencio.**

**Motivo de la partición, escrito por el analista:** meter los dos en una sola firma **convertiría un
problema con solución en una excepción permanente**; y las dos salidas finales para el segundo son
**opuestas** —aceptar el riesgo, o renunciar a los 409.699 B— y hoy se decidirían **sin el único dato
que las distingue**.

**Descartes con motivo:** el **cerrojo** no es vía A ni B —no da la propiedad que dice dar, porque
`(i)` incluye «una persona» cuyo editor no lo toma, y un cerrojo huérfano deja un documento que no
vuelve a rotar nunca—; **sacar del hook** pierde además la automaticidad, y `CA-14` mide el ahorro
sobre la **lectura real**, así que una rotación que nadie ejecuta ahorra **0**; **no rotar
`requirements/`** queda **viva** como la alternativa real. Y se nombra la **puerta posterior** de
`AGENTS.md` §13 para que no parezca inexplorada: **detectaría** la pérdida, no la evitaría.

### Las dos correcciones que el propietario exigió, aplicadas

1. **«Ninguna fila se pierde» queda ACOTADA** al estado intermedio de `CA-05`, con su evidencia, y en
   **los dos** criterios queda escrito que en el residuo de la ventana de publicación **la pérdida sí
   es posible** — y que si lo perdido era una fila de historia, **la fila se pierde**. Presentarla como
   garantía general era falso, y la coordinadora la propagó así en el informe y en el `CHANGELOG` de
   `8d39bb4`: **queda rectificado aquí, sin reescribir aquella entrada** (§9).
2. **Los «microsegundos» retirados en los dos sitios.** Ahora dicen que ese intervalo **no está medido**
   y que lo medido es el que **sustituye** — 295–312 ms del desarrollador y 355–361 ms de la auditoría,
   las **dos** mediciones. El analista rectifica además su propio informe anterior, donde afirmó que
   esas cifras estaban fuera de su rebanada **sin comprobarlo**.
3. La fila `:622` del Historial **no se borra**: abre con `[FILA RECTIFICADA …]` y remite a las
   posteriores.

**`ADR-008` se asignó por coordinación**, no por carrera: tres REQ lo reclamaban y no existía en disco.
La causa raíz sigue viva y sin dueño — **el número de ADR no tiene asignador**.

## [GitHub] — 2026-09-09 · `REQ-026`: la excepción vuelve a ser PROPUESTA, y la lista de «sin implementar» era falsa
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` (Opus), `desarrollador` (Opus), coordinadora.

**Decisión del propietario (2026-09-09):** *«No doy por aprobadas las nuevas excepciones. Conservá la
evidencia de los límites encontrados, pero mantené abiertos los hallazgos correspondientes hasta
resolver el cambio de garantía por el procedimiento aplicable.»* Y la prohibición que ordena el resto:
**no usar «máximo posible» ni una duración no medida como justificación.**

**El analista RETIRÓ su propia lectura de «cambio menor»** y lo declaró **de fondo**: admitir una
excepción en una promesa absoluta **cambia la decisión base**, que es el disparador de ADR en
`AGENTS.md` §9. En los dos criterios la garantía **absoluta vuelve a ser la vigente**, con la excepción
debajo rotulada **«PROPUESTA de cambio de garantía — NO ES CONTRATO VIGENTE»**, y escrito que hasta la
firma **el código no la cumple y `SEC-072` es un hallazgo, no una tolerancia**.

**Las dos justificaciones retiradas, y con qué se sustituyen:**
1. «El máximo que este mecanismo puede dar» → fuera. En su lugar, **qué garantiza y qué no**: garantiza
   el intervalo del **cálculo**, que es el medido —**295–312 ms** en la medición del desarrollador,
   **355–361 ms** en la de la auditoría—; **no garantiza nada** en el intervalo de **publicar**.
2. La duración residual «en microsegundos», y el «cuatro o cinco órdenes de magnitud» → fuera. Queda
   escrito que **está SIN MEDIR** y que **lo medido es el intervalo que sustituye, no el que queda**. El
   motivo técnico se queda sin valoración: POSIX no ofrece renombrado condicional atómico, y eso
   **describe el sustrato; no autoriza la excepción — quien la autoriza es la firma**.

**Conservado íntegro:** la ventana medida, el modelo determinista de la publicación a medias (2
bloques, 3 filas duplicadas, `rc=0`, sin aviso), el recorte **sin rama de error** y la incapacidad del
testigo de verlo. **Y añadido lo que rige sin excepción:** **ninguna fila se pierde**, así que la
dirección del fallo es hacia el **duplicado declarado**, nunca hacia la pérdida.

### La lista de «sin implementar» era FALSA en sus tres puntos, y la causa está nombrada

Reconciliada contra el código por la coordinadora:

| Lo que el informe daba por pendiente | Comprobado |
|---|---|
| Parte 4 del banco | **Existe** — `28-rotacion-seccion-4-la-carrera.sh`, commit `8248e58` |
| Retirada del comentario `:34-36` | **Hecha** — el texto cita la afirmación vieja y la **refuta**: «Las dos SÍ encuentran qué mover» |
| `CA-08 (v)` en la rama del NUL | **Implementada** — `ARNES_ROT_NO_MEDIBLE` en los dos hooks, cuatro ramas publicando |

**Causa, escrita por el propio analista:** repitió una lista de una pasada anterior **habiendo
declarado que no leyó el código**. Es exactamente la clase que este REQ persigue.

**Sin implementar de verdad:** `CA-13`, `CA-14`, `CA-16`, `CA-17` = `SEC-073`, alcance del propietario.
**Sin contratar:** la **idempotencia del re-archivado**, con dueño `desarrollador` y vencimiento
**antes de que se declare `CA-13`** — porque encenderla es lo que lo vuelve alcanzable.

### `ADR-008` asignado por la coordinadora

**Tres REQ lo reclamaban** —`REQ-026`, `REQ-024`, `REQ-019`— y no existe en disco. Se asigna a este
ADR **por decisión de coordinación y no por carrera**, que es lo que produjo la colisión de `REQ-019`
con los ADR de `REQ-014`. La causa raíz sigue viva y sin dueño: **el número de ADR no tiene asignador**.

### `REQ-024`: factibilidad resuelta con medición, sin reabrir ningún criterio

**Sí existe vía de activación a 0 procesos añadidos**, y es la llave de manifiesto: se pliega en la
llamada a `jq` **que ya existe** en `arnes_parse_manifest` (`hooks/lib.sh:52-102`), memoizada y con 10
claves, que corre **antes** de la resolución de la ausencia. La premisa de `CA-07 (i)` era **cierta pero
incompleta** —sólo miraba el `jq` de las quality gates, que corre después— y lo que faltaba **invierte
la conclusión**. Medido con la sonda del banco y **control discriminante** (+1 proceso con `jq` propio),
así que el `0` no es ceguera del instrumento. Evidencia en
`docs/arnes/req-024-activacion-cero-procesos.md`, con versión base `4f51293` y método.

**Y un defecto que el implementador debe cerrar:** la llave escrita como cadena `"true"` cae a
**no-activado y ALLOW sin aviso** (medido) — la clase `QA-106`/`QA-107`. El arreglo cuesta 0 procesos.

## [GitHub] — 2026-09-09 · Auditoría `R-022` de `REQ-026`: lo que bloquea ya no es código
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `auditor-seguridad` (Opus) + coordinadora.

`Seguridad: con-hallazgos (R-022)`. **`SEC-067` pasa a `en-mitigación`** —no a `mitigado`— y el
**código queda acreditado línea a línea**.

**Lo que el auditor acredita, y es lo que separa un guardián de uno que aprueba lo que debía
rechazar:** la comparación del testigo **no está normalizada de más**. `texto_ini="$texto"` más
`fin_nl` repone el único salto que la normalización quita, y **no** se compara normalizado contra
normalizado — eso habría hecho comparar iguales dos documentos que difieren en el salto final, y
**devolver ese byte al estado viejo también es una actualización perdida**.

**Segunda frontera, encontrada por el auditor y NO declarada por nadie: la publicación a medias.** Si
el `mv` del destino sale bien y el paso 7 falla, queda «bloque archivado, origen sin recortar» —y
`printf … > "$tmp_orig" && mv` **no tiene rama de error**—. La parada siguiente **vuelve a archivar** y
el testigo **no puede verlo**: sus dos lecturas son frescas y coherentes. Medido por modelo
determinista: **2 bloques, 3 filas duplicadas, `rc=0`, sin aviso**.

**Y se aplicó su propia regla a sí mismo**, que es la frase que resume la revisión: *«un hallazgo no se
cierra mientras su control viva sólo en el código, y aquí el control vive en el código y el criterio
que lo describe es falso. Me la aplico igual que se la aplicaría a otro.»* Condición exacta de cierre:
la tolerancia **dentro** de `CA-18 (i)` y la excepción de la publicación a medias declarada en `CA-05`.
Nada más.

**`SEC-072` (`contrato`, bloquea) — `QA-026-10` reclasificado, y con las dos mitades SEPARADAS.**
- Mitad **`(i)` → `contrato`**: el criterio promete «*ninguna publicación puede derivarse de una
  lectura que ya no describe el disco*», **en absoluto**, y en el residuo **sí puede**. La clase se
  deriva del defecto, no de la conveniencia. Con la **segunda instancia del mismo patrón**: `CA-05`
  promete «cero duplicadas» sin declarar la publicación a medias — la promesa que **nace falsa** con su
  excepción en «Notas / alcance», que es justo lo que nadie lee al citar un criterio.
- Mitad **`(iv)` → `instrumento`, sostenido**: declara un **estado de evidencia** y lo declara **peor**
  de lo que es. Y hoy el documento **se contradice consigo mismo** — `(iv)` dice «modelado, no medido»
  y las notas dicen «se midió».

**`SEC-073` (`contrato`, bloquea) — el alcance parcial deja de ser invisible para la puerta.** La
puerta lee el valor `aprobado`; el alcance vivía en el paréntesis, que §13 define como matiz, y
`Hallazgos abiertos:` no nombraba `CA-13`/`CA-14`/`CA-16`/`CA-17`. Vía **(a)** elegida porque es la
única que **no depende de que alguien se acuerde**. Las otras dos quedan escritas como alternativas y
**no se inventan**: reducir el alcance es del propietario. Entrada en `PENDING_APPROVAL.md`.

**`SEC-069` NO cierra, y lo midió:** el paso `4b` está **después** de contar entradas, así que sólo
protege el camino que iba a rotar. Las ramas **ambigua**, **sin entradas** y **no medible** retornan
antes: con `estado_derivado.activo: false` avisan por stderr y el bloque derivado sale **0**. `(vii)` se
cumple **literalmente**; su **motivo**, no. Baja de severidad media a **baja** y no bloquea.

**`SEC-058` no se agrava**, y la parte 4 aplica su propia remediación: piso derivado término a término
**y con fronteras** (19+57+28 = 104). Sigue abierto que **ninguna máquina verifica el valor**.

**La abstención sobre el coste queda acreditada también por el auditor**, con lo que él subraya y
merece quedar escrito: **un guardián se midió a sí mismo y se delató** —+11.841 µs, +9,2 %, por encima
de su propio techo— en la única línea que no era camino de fallo. Y lo que la abstención **deja sin
resolver**: la conformidad del código de hoy con el techo de `CA-15` **no está establecida**.

**Mejora que el auditor hace constar sin habérsela pedido nadie:** el destino pasó de `cat` a
`arnes_lee_archivo`. `cat` copiaba media lectura — era un `SEC-002` **latente en el destino** que él
mismo **no había nombrado en `R-021`**.

## [GitHub] — 2026-09-09 · `REQ-024` despachable y `REQ-026` con `QA: aprobado` en la vuelta 2
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` (Opus), `qa-tester` (Opus), coordinadora.

### `REQ-024` — `borrador` → `pendiente`, contrato cerrado

**La SEXTA instancia de «criterio derivado sin comprobar su factibilidad», y era insatisfacible por
diseño:** `CA-01` abortaba con SKIP *«si la extracción devuelve menos claves que la plantilla»*. El
lector reconoce **6** y la plantilla escribe **10**, así que la condición era cierta **hoy y siempre**:
**el caso no podía dar PASS nunca.** Corregido.

**Evitó que la implementación pisara dos ADR ajenos.** Este REQ declaraba `ADR-006` y `ADR-007` como
suyos en `Archivos:` y en **seis** criterios, y los dos son de `REQ-014` y existen en disco. Ahora los
ADR se identifican por su **papel** y toman el primer número libre al crearse. Y **no reservó
`ADR-008`** a propósito: `REQ-019` (F4) y `REQ-026` lo declaran también candidato, y reservar es la
forma **(b)** — la causa raíz sigue siendo que **el número de ADR no tiene asignador**.

**Colisión entre sus propios criterios, encontrada y resuelta:** la salida barata para `CA-07 (iv)`
cumpliría `CA-11 (i)` pero **viola `CA-10`**, porque su grano es de rango. Los tres se cumplen sólo por
una tercera vía, ahora escrita.

**El conflicto `CA-01` ↔ `REQ-023 CA-11` resuelto SIN el ADR**, vía `CA-05`, de modo que `REQ-023`
**no** necesita write-back ni volver a `en-progreso`. El conflicto no se borra: se **traslada** a
1.35.0 con dueño y forzador. Y **`SEC-050` NO reabre `REQ-016`** — revisión hecha con su resultado
escrito; mover el hallazgo en el registro es del auditor.

**No creó el ADR, a propósito:** sus decisiones no son del analista —la vía de activación es del
`desarrollador` con gate del propietario, y cruzar el grano cambia un contrato terminal—, y escribirlas
habría sido inventar alcance.

### `REQ-026` — `QA: aprobado` en la vuelta 2, y `QA-026-04` CERRADO

Alcance del veredicto: `CA-01`–`CA-12`, `CA-15` y **`CA-18`**. `SEC-067` sigue abierto y **bloquea
correctamente**: lo cierra el auditor.

**QA detectó un fallo de SU PROPIA sonda antes de publicar cifras.** Sus dos primeras mediciones
apuntaban a `$REPO/hooks` con `$REPO` **vacío**, así que invocaban `/hooks/stop.sh`, **el hook no
corría**, y el «no rota, no avisa» que obtuvo era **artefacto de la sonda**. Lo cazó volcando el stderr
crudo y rehizo todo con ruta absoluta y un guardián `[ -f "$H/stop.sh" ]`. Los brazos contra el código
viejo siempre fueron válidos, y por eso ahí sí salía el defecto.

- **`(vi)`, par discriminante:** reproducción propia con 1.200 filas y escritor ajeno a 150 ms —
  `1fe975f` **3/3** devuelve `Seguridad: aprobado` a `pendiente` **en silencio**; HEAD **3/3** lo
  conserva, no rota y avisa por los dos canales. El control **no es vacuo**: exige cuenta exacta de
  filas en los dos archivos.
- **`(iv)` con su número, y es lo honesto:** la intermitencia medida es **2/20 y 3/15** (10–20 %), luego
  tres rondas detectan una regresión con **27–49 %** de probabilidad — *«es una moneda al aire, y lo
  digo con número»*. Aceptado porque el fail-before está medido **fuera** del banco con su frecuencia,
  `SEC-030` prohíbe casos intermitentes aquí, y `(iv)` comparte testigo con `(vi)` y `(ii)`, que sí son
  deterministas.
- **`(c)` el residuo de la ventana de publicar:** leído al pie de la letra, `(i)` **no se cumple** en
  ese subintervalo. No es hallazgo —la ventana baja de 295–312 ms a dos `mv` y un `printf`, es
  irreducible en shell— pero **`(i)` está redactado en absoluto y su excepción vive en otra sección**:
  la tolerancia va **dentro** de `(i)`.
- **La abstención sobre el coste queda ACREDITADA**, con el argumento que la sostiene: la evidencia que
  la invalida es **interna a la medición** —el brazo de control, código viejo sin cambios, se movió un
  **34 %**— y **la afirmación que importa no necesita reloj**: «cero fuera del camino de rotación» es
  propiedad de camino y se verifica leyendo. No re-derivar el techo era lo conservador, porque sólo
  podía **subirlo**, la única dirección que `CA-15` no admite sin medición válida.

**`QA-026-04` cerrado** con evidencia: 1 línea por archivo, `rotacion.activo` en `false`, `artefactos`
en `[]`, `_doc_artefactos` **byte a byte idéntico** en los dos archivos (mismo hash), y la plantilla con
marcadores sustituidos es JSON válido.

**Cuatro `instrumento` nuevos, ninguno bloqueante:** falta un gate de §7 sobre
`templates/arnes-config.json.tpl`, que es **lo que heredan todos los proyectos** (`QA-026-08`); el poder
de `(iv)` más una rama sin caso (`QA-026-09`); dos write-backs para el analista (`QA-026-10`); y el techo
de `CA-15` sin verificar contra el código de hoy (`QA-026-11`).

### Índice sincronizado con el número MEDIDO

Los dos analistas discreparon —uno dijo ocho rutas compartidas, el otro diez— así que se midió con
`tools/arnes-paralelo.sh`: son **diez**. `requirements/README.md` queda con las dos celdas de `REQ-024`
al día y la cifra atribuida a su medición.

## [GitHub] — 2026-09-09 · `REQ-023` despachable: `SEC-052` retirado y cinco defectos en sus propios criterios
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus) + coordinadora.

`REQ-023` pasa de **`borrador` a `pendiente`**: contrato cerrado y despachable. Es la **mitad (1) de
la remediación de `SEC-047`**, severidad crítica, cuyo vencimiento es el cierre de 1.34.0.

**`SEC-052` retirado del campo `Hallazgos abiertos:`** citando la autorización literal del auditor
(`registro-seguridad.md:4429-4436`), y con un párrafo que escribe **lo que ese cierre NO acredita**,
con las palabras del propio auditor: nada sobre los criterios de `REQ-023` como contrato — esa
auditoría no ha ocurrido y va **después** de QA.

**Cinco defectos hallados en sus propios criterios, y el primero es de la clase que el REQ existe
para corregir:**

1. **`CA-01` llevaba un puntero MEDIDO FALSO, y la clave que dejaba fuera era `Estado`.** Decía
   «`arnes_campo_linea` **y sus llamadores**», y `arnes_estado_cabecera` **no** es llamador suyo:
   llama a `arnes_norm_clave` directamente (`hooks/lib.sh:1880`, `:1891`) y es la **única boca** donde
   vive la clave del estado terminal. **Quien auditara la clase siguiendo ese puntero habría concluido
   que la clave que decide el cierre estaba cubierta.** Es la clase de `SEC-050` **dentro** del
   criterio escrito para corregirla, y el propio `CA-06` ya lo desmentía.
2. **El «no más de 0 transcripciones» de `CA-06` NO era satisfacible por la vía obvia:** los dos
   sitios de bash son **disjuntos** —uno enumera 5 claves y despacha, el otro 1— así que **el conjunto
   de las 6 no existe hoy como lista en ninguna parte**: es la *unión* de dos despachos. Una constante
   nueva que esos dos no **usen** sería la tercera transcripción.
3. **Un radio que nadie había escrito:** `tools/arnes-lectura.sh:69-72` deriva la lista con `sed`
   **del texto de los brazos `case`** y **sale 2** si no encuentra ninguna. Reescribirlos **rompe el
   informe** —y con él `CA-07`— salvo que la derivación se re-apunte. El archivo ya estaba declarado;
   **descubrirlo implementando no lo era.**
4. **La séptima clave** (`Archivos:`, resuelta con el mismo normalizador en `arnes-paralelo.sh`) queda
   **fuera** de la constante **con motivo escrito**: su ausencia es fail-closed en su propio lector.
   Antes era un hueco silencioso; ahora es una frontera.
5. **`CA-09 (iii)` fijaba `2,2` sin decir entre qué dos longitudes.** Un cociente de duplicación
   depende del par, así que dos implementaciones podían medir pares distintos y **contradecirse sin
   mentir**. Ahora el caso publica el par, `k` y los dos tiempos, con el punto conforme nombrado.

**Los seis números que el contrato fija llevan o medición o cota con premisas comprobables, y NINGUNO
se convirtió en «derivar midiendo».** `CA-09 (ii)` pasa de un `≤ 1,25×` sin medir a una **cota
algebraica** con sus **tres premisas escritas** para comprobarse.

**`Archivos:` cambia por regla, no por alcance:** sale `CHANGELOG.md` —la regla del propietario del
2026-09-08 dice que los REQ en `borrador` lo retiran al salir a `pendiente`— y entran
`docs/qa/1.34.0*.md` y `docs/seguridad/registro-seguridad.md`, que esa misma regla declara **evidencia
primaria**, con fail-closed **hacia declarar**.

**Registrado sin abrirlo:** `R-015-01` **venció** con esta transición —su vencimiento era literalmente
«antes de que `REQ-023` salga de `borrador`»— y pide subir a doctrina la regla «un REQ *cita* clase,
forzador y vencimiento; no los *declara*». Es `instrumento`, **no bloquea**, y por la regla de
acumulación del propietario queda en `docs/PENDIENTES.md` con **vencimiento nuevo**: la próxima
comisión con ámbito sobre `requirements/README.md`, que hoy es el reparto de `REQ-019`.

Sincronizada la celda de `REQ-023` en el índice de `requirements/README.md`. **No** se tocó la que
dice «comparte nueve rutas»: el contrato de `REQ-024` está reescribiendo su `Archivos:` en este
momento, así que ese número se calcula con `tools/arnes-paralelo.sh` cuando los dos estén quietos, en
vez de escribir un dato que va a ser falso.

## [GitHub] — 2026-09-09 · `REQ-027` entra como quinto trabajo, el techo de `REQ-019` calculado, y la deuda de fechas cerrada por falsa
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` (Opus) ×2, `desarrollador` (Opus), coordinadora.

**Decisión del propietario: `REQ-027` es el QUINTO trabajo de 1.34.0**, con su implementación
**después de `REQ-019`, sobre la estructura resultante** —plantilla, `arnes-init` y `arnes-upgrade`
con sus verificaciones—. `docs/PLAN.md` §«ALCANCE DE 1.34.0» pasa de cuatro trabajos a cinco.
La coordinadora había recomendado 1.35.0; el propietario decidió 1.34.0 **con orden explícito**, que
resuelve el motivo de la recomendación —`REQ-019` mueve el texto de `AGENTS.md` y `REQ-027` inserta un
bloque en él— sin aplazar el trabajo. Queda escrito porque **una recomendación desatendida con motivo
es información, no ruido**.

**Techo de `REQ-019` calculado y ETIQUETADO COMO PROYECCIÓN** (`docs/arnes/req-019-techo-propuesto.md`,
versión base `d6620ea` leída con `git show`, nunca el árbol vivo):
**≤ 0,93× / ≤ 0,89× / ≤ 0,91×**, es decir **de 74.594 B a 67.406 B = −7.188 B de lectura obligatoria
por comisión (−9,6 %)**. Expresado en bytes y **no traducido a tokens**.

- **Medido con `wc -c`:** las dos bases y **tres punteros reales escritos para el cálculo** (269/243/161 B,
  peor caso usado). **Proyección:** el resultante y el techo — los archivos candidatos **no existen**,
  porque no se ha repartido nada, así que no hay `wc -c` posible sobre ellos.
- **Por qué 0,91× y no el ≈0,82× estimado en F1:** los punteros se comen el **49 %** de lo liberado
  (6.994 B contra 14.182 B delegados) y en `AGENTS.md` el **57 %**. El grano que manda es el de `CA-12`
  —26 punteros, **13 + 13**, y no es una división por la mitad: `AGENTS.md` 6 de gobierno + 7 secciones
  narrativas, README 9 + 4—, no los 11 de grano `CA-03` que suponía la estimación previa.
- **Dato de rentabilidad registrado sin proponer cambio de alcance:** el `## Índice` del README pesa
  **7.867 B**, está fuera de alcance y su conversión en bloque derivado **no reparte nada ni añade un
  puntero**, retirando **más** bytes que el reparto completo (7.188 B), que cuesta 7–11 h.
- **Límite declarado:** la tabla por sección **no sustituye** al inventario por bloques de `CA-15`.
  Agrega por sección, y una invariante se pierde por **bloque**.

**La deuda de «20 fechas desfasadas» queda CERRADA, y era falsa.** El número nunca se comprobó.
Medido: **15** apariciones en `REQ-019` —no 12—, **0 desfasadas confirmadas**, 2 correctas por
evidencia no-git, **13 indeterminadas**. Y el método que la coordinadora prescribió **no sirve**:
`git blame` devuelve `Not Committed Yet` en **14 de las 15**. Evidencia en
`docs/arnes/req-019-fechas-desfasadas.md`. **El propietario decidió no editarlas y que no bloqueen.**
El agente **revirtió** la única fila que había escrito, porque sus 15 veredictos eran `indeterminada`
y documentaba dentro del contrato una comisión ya cancelada.

**`REQ-027` gana la regla `B.7` y `CA-11`:** la evidencia intermedia se guarda **en disco**, con
**versión base** y **método** dentro del artefacto y la **ruta** citada en el informe. Nace medido: las
dos enumeraciones de `REQ-019` F1 (106 y 164 elementos) se entregaron por informe y **no sobreviven**,
así que hoy `CA-15.2` no se puede reconciliar sin repetirlas. El analista **se la aplicó a sí mismo** y
declaró qué **no** hizo puerta —el cumplimiento por comisiones futuras, que desde un REQ no se puede
medir—, nombrando el comprobador de `REQ-025` como candidata: *«un pendiente disfrazado de criterio
habría sido peor que un límite declarado»*.

**Corrección de la coordinadora sobre su propio contador de coste:** el `subagent_tokens` que reporta
el arnés es **acumulado por agente**, y se estaban sumando los dos informes de un mismo agente
reanudado. Lo gastado en comisiones cerradas es **≈2,02 M**, no los ≈2,2 M reportados antes. Y el
contador que los agentes citan (14.9xx k y bajando) es **presupuesto restante compartido**, no consumo
propio: con varias comisiones vivas, su delta **no es atribuible** a ninguna.

## [Interno] — 2026-09-09 · Decisiones del propietario: `_doc_artefactos` autorizado, techo de `REQ-019` por presentar
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

**Resuelta la entrada de `REQ-026`.** El propietario autoriza **exclusivamente** actualizar
`_doc_artefactos` en `.arnes/config.json:48` y `templates/arnes-config.json.tpl:53`, **sin activar la
rotación**. Cierra `QA-026-04` (`contrato`) y retira el vencimiento que expiraba antes del tag
`v1.34.0`. `rotacion.activo` y `rotacion.artefactos` quedan **fuera** de lo autorizado; `CA-13` no se
declara, y no hacía falta decidirla — le falta trabajo, no permiso.

**Sigue pendiente la de `REQ-019`, con dirección dada:** mantener el alcance y **ajustar el objetivo**
(opción A), con el número **por presentar** — una propuesta de techo que **incluya los punteros
obligatorios de `CA-03`**, que la medición de F1 dejó fuera declarándose cota inferior. El resultado
se expresa como **reducción de bytes de lectura obligatoria**, nunca como ahorro de tokens.

**Advertencia registrada en la propia entrada, porque «el inventario existente» no está donde
parece:** las dos enumeraciones de F1 (106 y 164 elementos) se entregaron **por informe** y **no
sobreviven en disco**. Lo que sí hay, y basta para dimensionar el reparto sin re-enumerar, es la tabla
**por sección** de §«El suelo forzado MEDIDO EN BYTES», con `base`/`delegable`/`suelo` de cada
sección. **No se abre enumeración nueva.**

**Corrección de algo que la coordinadora había sobreestimado:** la cola sólo cierra la puerta **A2**
—transiciones a `completado`—, no el trabajo. Y ningún REQ estaba listo para cerrar de todas formas:
los tres abiertos ya tenían su propio bloqueante. Verificado además con el lector del arnés
(`arnes_cola_pendientes`), que cuenta las entradas correctamente y por tanto **`SEC-051` no afecta a
éstas**: ninguna usa comentarios HTML.

## [GitHub] — 2026-09-09 · Cierre de la sesión autónoma: punto de continuidad y el segundo gate de `REQ-026`
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Punto de continuidad en `docs/ESTADO.md` **fuera de los marcadores derivados** (comprobado:
posición 10.615 contra el bloque `[31.392, 33.669]`, tres marcadores intactos), con terminado /
bloqueado / no verificado separados, los once agentes reanudables con su identificador, y la
deuda anotada.

Entrada nueva en `PENDING_APPROVAL.md` con los **dos** cambios del manifiesto de `REQ-026` y el
orden entre ellos: **A** corregir `_doc_artefactos` —`contrato`, vence **antes del tag `v1.34.0`**,
no enciende nada— y **B** declarar `CA-13`, que **no** se aprueba hoy porque falta trabajo, no
permiso: `CA-18` existe y su control no.

**Lo que la ventana entrega y lo que no, sin adorno.** `REQ-017` cerrado. El mecanismo de rotación
existe, está probado con 29 casos y está **apagado**. `REQ-019` bloqueado por un techo que su propia
medición desmintió. `REQ-023`/`REQ-024` sin empezar. Y el tag de 1.34.0 **vuelve al propietario** por
§6: hay un `usuario/dinero` y un `contrato` abiertos.

## [GitHub] — 2026-09-09 · `REQ-026 CA-18`: no se publica sobre una lectura caducada
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Write-back de **`SEC-067`** (`usuario/dinero`) y **`SEC-069`**. Criterio nuevo en siete partes, con
la **propiedad** por delante y **sin nombrar ningún mecanismo**:

- **(i)** Si otra escritura modifica el documento **después** de que la rotación lo leyó y **antes**
  de que publique, la rotación **no publica**: el documento conserva **byte a byte** esa escritura
  ajena y se avisa. *Ninguna publicación puede derivarse de una lectura que ya no describe el disco.*
- **(ii)** Dirección hacia **no rotar**, y **ninguna condición bajo la que la duda autorice publicar**.
- **(iii)** El fallo **nombrado**, que es lo que faltaba: **actualización perdida** —escritura completa
  y válida que pisa un cambio posterior a la lectura— **≠ escritura desgarrada** —la que cierra el
  temporal propio del proceso de `REQ-015`—, y **una no implica la otra**. Contrata además que la
  invariante de `hooks/rotar-artefactos.sh:34-36` **es falsa** y se corrige o se retira: un
  comentario que afirma una invariante falsa es deriva (§9).
- **(iv)** Concurrencia: a lo sumo una publica y el destino **no** recibe el mismo bloque dos veces.
  Declarado **modelado, no medido**, frente a (iii) que **sí** se midió 3/3.
- **(v)** Lo único acotado del **cómo**, y por propiedad: ni estado intermedio, ni bloquear la parada,
  ni obligar a superar el techo de `CA-15` — si lo superara, se re-deriva por la vía que `CA-15` ya
  define, **no aflojando esta propiedad**.
- **(vi)** Par discriminante con **sus dos mitades**, y su sede: **parte 4** del banco, porque
  `28-rotacion-seccion-3-la-tabla.sh` está en **400 de 400 líneas**. **No se propone subir el techo.**
- **(vii)** El canal: sede de `CA-08 (v)` **más** el cierre de `SEC-069` — **la rotación no rota
  cuando no puede dejar constancia duradera**. Motivo: un fail-closed invisible es indistinguible de
  una sección que lleva meses sin archivarse.

**Marcado como candidata a `ADR-008`** por el propio analista, con su alternativa declarada, porque
`(vii)` acopla dos ajustes del manifiesto hoy independientes: *«eso lo decide quien firma, no yo»*.

**La consecuencia de gobernanza NO entra en este REQ, y el motivo es correcto:** que
`tools/arnes-paralelo.sh` no conozca a este escritor **no es defecto del rotador**, y `REQ-026` no
puede contratar el comportamiento de una herramienta que no toca ni declara en su `Archivos:`. Sede
**`REQ-022`**, con el texto redactado y esta dependencia anotada: la cadena es
`CA-18` + su control → `CA-13`, y **esa dimensión de `REQ-022` debería resolverse —o quedar como
residual con dueño— ANTES de encender la rotación**, porque encenderla es justo lo que pone al hook
a escribir en `requirements/`.

## [Interno] — 2026-09-09 · `REQ-026`: auditoría de seguridad **R-021** — `con-hallazgos`, y el rotador que ahora escribe contratos
> Origen: Interno (manual, sin commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `auditor-seguridad` (Opus).

Auditoría del rango `2a91c82^..464e0ba`, **después** de QA. Veredicto **`con-hallazgos`**: el
mecanismo está apagado y no puede disparar hoy, pero queda un bloqueante abierto y su control no
existe ni en el código ni en ningún criterio.

- **`SEC-067` (`usuario/dinero`, alta, abierto)** — la rotación de sección reescribe el documento
  **entero** desde una lectura previa sin ninguna comprobación de concurrencia entre la lectura
  (`:297`) y la publicación (`:596-598`). **Medido 3/3 en carrera real:** un `Seguridad: aprobado`
  escrito durante la rotación volvió a `pendiente`, `rc=0`, stderr vacío y **sin línea en el bloque
  derivado**; ventana 355–361 ms. Segunda consecuencia, **modelada**: dos paradas simultáneas
  **duplican** el bloque archivado (3 filas repetidas de 5), contra el «cero duplicadas» de `CA-05`.
  La invariante del propio archivo (`:34-36`) que dice que eso «es conforme» es **falsa**.
- **El fail-closed del reconocedor de tablas se sostiene** — pero el argumento de clase escrito
  nombra el mecanismo equivocado: lo portante es `hueco`/`hueco2`, no el conjunto de caracteres
  (`SEC-068`). Cinco formas nuevas probadas, ninguna rompe nada; barrido del corpus real limpio.
- **`QA-026-04` reclasificado `instrumento` → `contrato`**: `_doc_artefactos` de la **plantilla**
  anuncia a terceros un mecanismo que ya no existe, y **subestima** lo que la máquina toca. Forzador
  real: la publicación de 1.34.0, no `CA-13`.
- **`SEC-069`/`SEC-070`/`SEC-071` (`instrumento`)** — el canal único de `CA-08 (v)` depende de
  `estado_derivado.activo` (medido); y los dos sitios restantes de la familia `SEC-002`/`R-001`.
- **Sin regresión de enforcement**: el rango no toca ninguna puerta; tres controles se refuerzan.
  Contención de rutas del destino medida con cuatro formas. Sin fuga en repositorio público.
- **No ejecuté el banco ni una vez**, no re-medí `CA-15` y **no encendí la rotación**.

## [GitHub] — 2026-09-09 · `REQ-026`: `QA: aprobado` sobre el mecanismo, con la clase de fallo cerrada por argumento
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

Re-validación de la vuelta 1. **Los dos hallazgos `usuario/dinero` cerrados, verificados por
medición propia de QA y no leyendo el commit:**

- **`QA-026-01`** — la forma exacta que destruía 17.697 B deja el archivo en **158.598 → 158.598 B**,
  no rota, avisa citando `SEC-002`/`R-001`, `rc=0`. Contención **por archivo**: `REQ-013` con NUL
  queda intacto y citado mientras `REQ-007` y `REQ-019` rotan en la misma parada.
- **`QA-026-02`** — las dos variantes quedan byte a byte iguales y avisan.

**El argumento que cierra la clase donde vivían la quinta y la sexta forma**, y que vale más que
cualquier caso: `arnes_rot_es_separadora` acepta **exactamente** el conjunto de caracteres que GFM
admite en una fila delimitadora (`-`, `:`, `|`, espacios y tabs) y exige un `-`. Luego **no existe
fila que GFM lea como separadora y el hook lea como dato**: la dirección peligrosa está cerrada y
todo desacuerdo cae del lado seguro. Verificado sobre 9 formas. **Séptima forma: no la hay** —
doce formas probadas, y la ausencia se declara **evidencia acotada, no demostración**.

**Cero regresión sobre corpus real:** 10 REQ en copia, 8 rotan con multiconjunto exacto y todo fuera
de la sección byte a byte; los 2 que no rotan están bajo umbral y **no avisan**, que es `CA-10`.
Ningún fail-closed falso.

`QA-026-05` y `QA-026-06` **cerrados**. El primero porque el registro del techo ya nombra su
estadístico y su orden es **estructuralmente** verificable —regla escrita antes de medir, dos juegos
en invocaciones separadas—; y QA acredita expresamente lo que el desarrollador **no estaba obligado
a escribir**: que la vuelta anterior eligió la regla con el número de validación delante, que la
subida de `0,135` a `0,140` **no** se atribuye a los arreglos, y que lo afirmable es de **camino, no
de reloj**.

**Hallazgo nuevo `QA-026-07`** (`instrumento`, dueño `analista-requerimientos`): el único hueco que
rota sin avisar —una continuación **tras la última** fila— **no incumple `CA-08 (i)`** y su inocuidad
está **verificada en tres configuraciones**, pero ningún criterio lo dice, y es justo la frontera
donde este REQ falló dos veces. Merece cláusula.

**Alcance declarado del veredicto:** `CA-01`–`CA-12` y `CA-15`. `CA-13`, `CA-14`, `CA-16` y `CA-17`
**sin implementar y fuera de ventana**. El veredicto acredita **el mecanismo**, no el cierre.

## [GitHub] — 2026-09-09 · `REQ-026 CA-08`: la propiedad por delante de la lista, y el aviso simétrico
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Write-back de `QA-026-01`, `QA-026-02` y `QA-026-06` (§9: un hallazgo no se cierra hasta que el
requerimiento lo refleje). `CA-08` pasa de una viñeta a cinco partes:

- **(i) La propiedad, y manda sobre cualquier lista.** La estructura se reconoce sin ambigüedad **en
  toda la extensión de la sección, no sólo en su preámbulo**, con la frase que cierra el hueco:
  *«la comprobación recorre la sección completa: detenerla en la primera fila de datos no satisface
  este criterio»*.
- **(ii) La enumeración son ejemplos.** Entra la quinta forma y se escribe *«una implementación que
  satisfaga esta lista y no (i) incumple; la lista puede crecer sin que (i) cambie»*. Queda escrito
  además lo que la hizo invisible: **`CA-05` se conserva** en esa forma, así que ninguna comprobación
  de pérdida veía el dato reetiquetado.
- **(iii) Lectura no fiable**, rama nueva contratada: documento que no se puede leer entero → no se
  rota, no se toca, se avisa, y **nunca** se publica una lectura a medias.
- **(iv)** Todas las ramas salen con código 0: la parada no se bloquea.
- **(v) El aviso es SIMÉTRICO en las cuatro ramas** de «no se rota»: stderr **más** línea con
  contador en el bloque derivado. **Se rechazó la asimetría acotada que proponía el desarrollador**
  —que la rama del NUL bastara con stderr porque `guard-completado` ya denegaría— con este motivo:
  esa denegación está **condicionada a que alguien edite ese REQ**, mientras el silencio de la
  rotación no está condicionado a nada, y **un canal de visibilidad que depende de un segundo suceso
  no es un canal**. `CA-10` queda excluido expresamente: no es fail-closed y por diseño no avisa.

**Consecuencia declarada:** `CA-08 (v)` queda **contratado y NO implementado** en la rama del NUL.
Y el analista declara que **no leyó el código**: que los arreglos satisfagan **(i)** como propiedad
—y no otra vez la enumeración ampliada— **está sin comprobar**. Sugiere un caso con **tres** tablas
o con la segunda separadora en la última fila.

## [GitHub] — 2026-09-09 · QA de `REQ-026`: dos hallazgos `usuario/dinero` en el rotador de tablas
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

`QA: con-hallazgos`. `REQ-026` vuelve al `desarrollador` (vuelta 1 de 3). **La rotación NO se
enciende hasta cerrar los dos primeros.**

- **`QA-026-01`** (`usuario/dinero`) — `hooks/rotar-artefactos.sh:263` lee con
  `IFS= read -r -d '' texto < "$f"`, que **se detiene en el primer NUL y devuelve 0**; el paso 7
  escribe esa mitad encima del REQ. Medido sobre copia de `REQ-007`, determinista 3/3:
  **−17.697 B, 5 filas de historia desaparecidas de documento y archivo, `rc=0`, stderr vacío**.
  **El arnés ya tiene el lector que lo evita** —`arnes_lee_archivo` (`hooks/lib.sh:1120`), nacido de
  `SEC-002`/`R-001` por este fallo exacto, que devuelve rc 1— y su único llamador es
  `guard-completado.sh:150`, que ante un NUL **deniega**. El rotador, que además **escribe**, se
  quedó con la forma cruda. **Atribución precisa:** la lectura cruda es anterior, pero contra
  `c59fd83` una sección en forma de tabla daba cero entradas y se retornaba antes del paso 7 — sobre
  `requirements/` la vía **no era alcanzable**. Este REQ la hace alcanzable en cada rotación.
- **`QA-026-02`** (`usuario/dinero`) — **la quinta forma de `CA-08`, y existe.** La pasada de
  validación hace `break` en la primera fila de datos, así que **nada posterior a ella se valida**.
  Con dos tablas en la sección, la cabecera y la separadora de la segunda se **archivan como filas
  de datos** y sus filas conservadas quedan **bajo las columnas de otra tabla**: dato
  **reetiquetado en silencio**. Y `CA-05` **se conserva** en esa forma, así que ninguna comprobación
  de pérdida lo ve. Cobertura del banco: **cero** casos con dos tablas.

**Ningún criterio está mal formado, y esto importa:** `QA-026-02` existe **porque `CA-08` está bien
escrito** —marca su enumeración «no exhaustivos»—; la implementación cubrió la **enumeración** y no
la **propiedad**.

Cuatro `instrumento` más: `conservar_entradas: -1` mata el hook y deja el bloque derivado sin
escribir (`QA-026-03`, preexistente); `_doc_artefactos` obsoleto (`QA-026-04`, viaja con `CA-13`);
dos defectos del **registro** del techo de `CA-15` —las cifras de validación no dicen qué estadístico
son, y no consta que la regla del margen se fijara antes de ver el juego de validación, así que
«techo derivado» y «número ajustado» son indistinguibles desde el registro (`QA-026-05`)—; y el
cambio de `hooks/estado-derivado.sh`, que **no era alcance tomado por su cuenta** —el REQ lo declara
en `Módulo:` y en `Archivos:`— pero le falta contrato (`QA-026-06`).

## [GitHub] — 2026-09-09 · `QA-026-04`: el manifiesto describía el mecanismo anterior, y la plantilla lo heredaba
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

**Gate humano levantado por el propietario, y sólo para esto:** *«Autorizo la decisión 2
exclusivamente para actualizar `_doc_artefactos` en los dos archivos indicados, sin activar la
rotación.»*

`_doc_artefactos` seguía diciendo que una entrada es sólo `- `, `* `, `### ` o `N. ` — el
mecanismo de antes de `REQ-026`. El código reconoce **filas de tabla** desde 1.34.0, así que ese
texto envejecía **hacia el lado que abre**: **subestimaba lo que la máquina toca**, y vive en la
plantilla que los proyectos heredan por `arnes-upgrade`. De ahí que `R-021` lo reclasificara de
`instrumento` a **`contrato`**. Ahora describe lo que hace hoy: la entrada **por propiedad** —línea
de lista **o** fila de datos de la tabla que ES la sección, con cabecera y separadora como
preámbulo que se queda—, la tabla dentro de una entrada como continuación que viaja con ella, el
puntero **fuera** de la tabla, las **cinco** ramas de «no se rota y se avisa» (sin la sección
declarada, sin entradas reconocibles, estructura ambigua **en toda la extensión** de la sección,
lectura no fiable y **lectura caducada**) con su línea en el bloque derivado, y que con
`estado_derivado.activo: false` la rotación de sección **no rota**.

**El límite de la autorización, verificado y no sólo respetado:** `rotacion.activo` sigue en
`false`, `rotacion.artefactos` sigue **vacío** —eso es `CA-13`, que el propietario no autorizó— y
**ninguna otra clave** cambió. Comprobado comparando los dos documentos con `_doc_artefactos`
descontada (`diff` vacío) y con `git diff --numstat`: **1 línea** por archivo. Al terminar, la
rotación sigue apagada y `requirements/historial/` no existe.

**Los dos archivos quedan byte a byte idénticos** en esa clave, que era la mitad del defecto: dos
copias de la misma frase se desfasan.

**Un detalle de acreditación que conviene registrar:** `jq -e . templates/arnes-config.json.tpl`
**no puede estar en verde** y no lo estaba antes de este cambio — la plantilla lleva tres
marcadores (`{{ARNES_VERSION}}`, `{{CODIGO_APP_GLOBS}}`, `{{QUALITY_GATES_JSON}}`) y por diseño no
es JSON válido; falla igual en `HEAD`. Lo que sí mide algo es sustituir los marcadores y validar
**eso**, que es lo que se hizo: JSON válido, con `activo: false` y `artefactos: []`. El `jq` de §7
cubre `hooks/hooks.json` y `.claude-plugin/*.json`, no la plantilla.

Banco: **920 PASS · 0 FAIL · 4 SKIP** (924, `rc=0`, 1 m 02 s) — no se mueve, como debía ser: es
texto de documentación dentro del JSON. `QA-026-04` **no se cierra aquí**: eso es de QA y del
auditor.

## [GitHub] — 2026-09-09 · `REQ-026 CA-18`: la rotación no publica sobre una lectura caducada, y medir el guardián encontró su propia regresión
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

**El defecto: `SEC-067`, `usuario/dinero`.** La rotación leía el documento entero, calculaba, y
lo reescribía **desde esa lectura**, sin comprobar que nadie lo hubiera cambiado en medio.
Reproducido **3/3** con una ventana de **295–312 ms** (el auditor: 355–361 ms): un
`Seguridad: aprobado` escrito durante la rotación **volvía a `pendiente`**, con `rc 0`, stderr
vacío y sin línea en el bloque derivado. Es la **actualización perdida** —una escritura completa
y válida que pisa un cambio posterior a la lectura— y **no** la escritura desgarrada que cierra
`REQ-015` con el temporal propio del proceso: el arnés sólo tenía defensa para la segunda.

**El mecanismo, que `CA-18 (v)` dejaba a mi elección: un testigo de vigencia por relectura del
documento **y** del archivo de historia, justo antes de publicar. Sin cerrojos.** Y el motivo
importa más que la elección: `(i)` incluye expresamente a **una persona** con su editor, y un
cerrojo sólo obliga a quien lo respeta —habría dado garantía sobre las rotaciones y **ninguna**
sobre el caso que se midió—; además un cerrojo huérfano deja un documento que **no vuelve a rotar
nunca**, y decidir cuándo está rancio es adivinar. Se comprueban los dos archivos porque el
bloque nuevo se arma sobre lo que el archivo de historia decía al leerlo, y publicar encima de
una lectura caducada **de él** borra un bloque ya archivado. Comprueba y **cede**: no espera a
nadie, como exige `(v)(b)`.

**Medir no era opcional, y ahí estaba la lección.** El encargo daba por hecho —y yo también— que
estos cambios eran de camino de fallo y no había que re-medir. **Una línea no lo era:** guardar el
testigo justo después de leer copiaba el documento entero **por archivo y por parada**, también en
los que no se iban a rotar. Medido **pareado** (misma máquina, mismo minuto, montaje de `CA-15`):
**140.583 µs** contra **128.742 µs** del código anterior, **+11.841 µs (+9,2 %)** en régimen
estacionario y **por encima del techo de 140.000 µs**. Corregido reconstruyendo el testigo en el
punto de publicación, con lo que fuera del camino de rotación cuesta **cero**. Un guardián que se
paga en cada parada aunque no haga nada es exactamente lo que `CA-15` existe para no dejar pasar.

**Y el residual se declara NO MEDIDO, en vez de publicar una cifra cómoda.** Tras la corrección,
tres pareados dieron +3.261 µs, +5.659 µs y uno **inválido** (+48.377 µs con el brazo de control
del **mismo código viejo** moviéndose un 34 %, entre 93.110 y 141.277 µs). Con el código anterior
midiendo hoy por encima del propio techo, una comparación absoluta **condenaría también al código
que era conforme**: la máquina no está en el estado en que se derivó. La sonda se **abstiene**
(`REQ-021`), **el techo no se re-deriva**, y lo que falta para publicarlo es la condición (ii) de
`CA-15` —máquina en reposo y **sin el banco corriendo**—, que es justo lo que una comisión no
puede ofrecer al final de su sesión. El protocolo pareado queda escrito en el REQ.

**`CA-18 (iv)` deja de estar «modelado»: se midió.** Dos paradas simultáneas sobre el mismo
documento, contra `1fe975f`: **1 de cada 5** y **1 de cada 10** vueltas dejaron **dos bloques** en
el destino y **1.190 filas duplicadas**, con `CA-05` roto sobre la unión. Con el testigo, **10 de
10** conformes. Consecuencia que se declara en vez de disimularse: como el duplicado es
**intermitente**, el caso del banco es de **conformidad y no un discriminante** —una vuelta suelta
pasa también contra el código viejo— y por eso corre **tres** vueltas.

**`CA-18 (iii)`: retirada una invariante falsa.** El comentario de `hooks/rotar-artefactos.sh:34-36`
afirmaba que con dos paradas «una de las dos no encontrará nada que mover, y eso es conforme». Las
dos **sí** encuentran qué mover. Es la tercera afirmación de esta comisión sobre el mecanismo que
resultó falsa al ejecutarla, y las tres se han cerrado con una medición.

**`CA-18 (vii)` (`SEC-069`): la rotación de sección no rota cuando no puede dejar constancia
duradera.** Con `estado_derivado.activo: false` ninguna línea de «no se rota» se escribe, así que
el fail-closed se volvía invisible por una opción ajena a él. Ahora, con el canal apagado, no rota
y lo dice por stderr; y la rama de la carrera añade su contador y su **quinta** línea al bloque
derivado. El ajuste se lee en la rotación —que corre antes del bloque— con el mismo cuidado con
`//` que `estado-derivado.sh`: sólo un `false` explícito apaga. La decisión se toma después de
saber que había algo que mover (`CA-10`: nada de ruido en cada parada) y antes del `mkdir -p`, para
no crear `historial/` y luego no rotar.

**Banco: parte 4 nueva** (`28-rotacion-seccion-4-la-carrera.sh`, 8 casos, `piso` 104 derivado
término a término) y `CASOS_ESPERADOS` 916 → **924**. La sede la fija `CA-18 (vi)`: la parte 3 está
en 400 de 400 líneas y el criterio no propone subir el techo. Fail-before contra `1fe975f`: **5 de
8** fallan; los 3 que pasan son los **dos controles obligatorios** —que deben pasar a los dos
lados o no controlan nada— y el de `(iv)`. Corrida completa: **920 PASS · 0 FAIL · 4 SKIP** (924,
`rc=0`, 1 m 10 s, +7 s por los fixtures de 1.200 filas); autoprueba 106 PASS; gates de §7 en verde.
Sobre copias en `/tmp` de `REQ-017` y `REQ-021`: rotan, multiconjunto intacto, un bloque, un
puntero, y la segunda parada no dice nada (idempotencia).

**Dos residuos declarados, ninguno escondido en el código:** (1) la ventana **no** se cierra del
todo —lo que queda es la de publicar, microsegundos en vez de 300 ms— porque no existe un
«renombra-si-no-ha-cambiado» atómico en POSIX; (2) la rama «el archivo de historia cambió entre su
lectura y su publicación» está implementada y **sin caso**, porque su ventana es ese residuo y un
caso de reloj ahí sería intermitente — sí tiene caso determinista la otra mitad: que su vigencia
**no se pueda comprobar**. Y una nota de gobernanza que no me toca: `(vii)` acopla `rotacion` con
`estado_derivado` y el propio criterio lo declara candidato a **ADR-008**.

## [GitHub] — 2026-09-09 · `REQ-026 CA-08`: la cuarta rama también se ve, y probar la propiedad encontró una forma más
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

**`CA-08 (v)` implementado — y el criterio tenía razón contra mí.** La entrega anterior dejó la
rama de la **lectura no fiable** avisando sólo por `stderr`, con el argumento de que un NUL ya
hace **denegar** a `guard-completado` en la siguiente edición de ese REQ. El criterio lo rechaza
con un motivo mejor: esa denegación **depende de que alguien edite ese REQ** y de dónde caiga el
NUL, mientras que el silencio de la rotación **no depende de nada** — un canal de visibilidad
condicionado a un segundo suceso no es un canal. Ahora las **cuatro** ramas de «no se rota»
—sin la sección, sin entradas, estructura ambigua y lectura no fiable— dejan contador y línea
propios en el bloque derivado de `docs/ESTADO.md`, con texto que distingue su caso. `CA-10` sigue
sin línea a propósito: no es un fail-closed. La nota de alcance que defendía la asimetría se
reescribe, en vez de dejarse contradiciendo al criterio.

**`CA-08 (i)` comprobado como propiedad — y ahí estaba otro defecto.** Los dos casos que pidió el
analista (**tres** tablas; la segunda separadora en la **última** fila) **pasan contra `6b07f88` y
contra este árbol**: ya estaban cubiertos por construcción, porque la comprobación vive dentro del
bucle que recorre la sección entera. Eso queda **probado con casos**, no argumentado, que es lo que
se pidió. Pero probando la propiedad apareció una forma que la enumeración no nombra: **una línea
que no es fila de datos entre dos filas de datos**. Con un párrafo suelto, una línea vacía o una
**segunda tabla indentada tres espacios** —GFM las admite, así que no llegan al reconocedor de
columna cero— la sección se rotaba **en silencio** y el bloque del destino quedaba con esa línea
**entre dos filas de datos**: dejaba de leerse como tabla, o sea `CA-03` roto. Medido en las tres
formas. Ahora es fail-closed, con un aviso propio, y el arreglo mira la propiedad —un hueco después
de la primera fila invalida la estructura— y no las tres formas.

**Y su control, que es la mitad que impide pasarse de listo:** una continuación **tras la última**
fila **no** corta ninguna tabla —no hay fila detrás— así que se sigue rotando y esa cola viaja con
su entrada, que es exactamente lo que contrata `CA-07`. Sin ese control, el arreglo habría sido
«cualquier línea rara detiene la rotación», y eso dejaría sin rotar media `requirements/`.

**Comprobado que ningún REQ real cae en el fail-closed nuevo:** los 28 archivos de
`requirements/` se escanearon buscando esa forma y **ninguno** la tiene. Sobre copias en `/tmp` de
`REQ-017`, `REQ-021` y `REQ-014`: los dos primeros rotan con multiconjunto intacto y **cero**
líneas intrusas en el bloque; el tercero, al que se le inyectó un NUL, queda **byte a byte igual**
y aparece nombrado en la línea nueva del bloque derivado, con el texto humano de `ESTADO.md` fuera
de los marcadores intacto.

**Banco.** 6 casos nuevos → `28/3` de 23 a **29** y `CASOS_ESPERADOS` de 910 a **916**.
Fail-before contra `6b07f88`: fallan **tres** —`CA-08 (v)` y las dos formas nuevas— y los otros
tres pasan a los dos lados por diseño. Corrida completa: **912 PASS · 0 FAIL · 4 SKIP** (916,
`rc=0`, 1 m 02 s); autoprueba 106 PASS; gates de §7 en verde.

**`CA-15` no se re-mide, y se dice por qué:** los cambios de este tramo son de **camino de
fallo** y en régimen estacionario **no se ejecutan** —la función sale en la comparación de tamaño
antes de trocear, y la línea del bloque derivado sólo existe cuando algo falló—. El techo
`≤ 0,140 s`, derivado con la regla fijada antes y con el estadístico nombrado, sigue en pie.

**Aviso para la próxima comisión:** `28-rotacion-seccion-3-la-tabla.sh` queda **en el techo** de
`REQ-014 CA-18` (400 de 400 líneas). El caso siguiente exige **partir la sección en una parte 4**,
no alargarla; queda escrito en la propia línea del piso, donde se va a leer.

## [GitHub] — 2026-09-09 · `REQ-026` vuelta 1: el NUL que publicaba media lectura encima de un REQ, y la segunda tabla que nadie validaba
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

Los dos hallazgos `usuario/dinero` de QA sobre la entrega anterior, cerrados. Los dos eran
deterministas y los dos están reproducidos en el banco con **su control**.

**`QA-026-01` — la lectura no fiable.** `read -r -d ''` se detiene en el **primer NUL y devuelve
0**: lo leído es media lectura, y el paso final la publicaba **encima del original**. Medido por QA
sobre copia de `REQ-007`: **−17.697 B, 5 filas de historia fuera del documento Y del archivo,
`rc 0`, stderr vacío**; reproducido aquí en −1.631 B. Ahora las **dos** funciones de rotación leen
con `arnes_lee_archivo` (`hooks/lib.sh`, la función que nació de `SEC-002`/`R-001` para esto
exacto y cuyo único llamador era `guard-completado`), y si el archivo no se puede leer entero **no
se rota, no se toca y se avisa** — misma dirección que `CA-08`. La contención es **por archivo**:
en una parada con tres REQ, el del NUL se queda quieto y los otros dos rotan.

**Atribución exacta, porque importa:** la lectura cruda era **anterior** a la entrega anterior,
pero con el reconocedor viejo una sección en forma de tabla daba **cero entradas** y la función
salía antes de llegar a escribir. No es un defecto que introdujera el reconocedor de tablas: es
uno que **activó**, en cada rotación de un REQ.

**`QA-026-02` — la quinta forma, y la causa era una línea.** La pasada que decide la estructura
hacía `break` en la primera fila de datos, así que **nada posterior a esa fila se validaba jamás**.
Con **dos tablas** en la sección, la cabecera y la separadora de la segunda se archivaban **como
filas de datos de la primera** y sus filas quedaban bajo las columnas de otra tabla: **dato
reetiquetado en silencio**. Lo que lo hacía invisible es que en esa forma **`CA-05` se conserva**
—ni se pierde ni se duplica ninguna fila—, así que ninguna comprobación de pérdida lo veía, y la
cobertura del banco con dos tablas era **cero**. Ahora la validación cubre **toda** la sección, y
vive dentro del bucle que ya la recorría (no en una tercera pasada: eso se paga en cada parada).

**La lección, que es la que se repite:** `CA-08` declara su enumeración «**no exhaustivos**», y la
implementación cubrió la **enumeración** en vez de la **propiedad**. La propiedad es *si no se
reconoce la estructura de TODA la sección, no se rota y se avisa*.

**Banco.** 4 casos nuevos (2 de defecto + 2 controles) → `28/3` pasa de 19 a 23 y
`CASOS_ESPERADOS` de 906 a **910**. Fail-before contra `b0774cd`: fallan **exactamente** los dos
casos de defecto y ninguno más. Corrida completa: **906 PASS · 0 FAIL · 4 SKIP** (910, `rc=0`,
1 m 03 s); autoprueba del corredor 106 PASS; gates de §7 en verde.

**`QA-026-05` — el registro del techo, arreglado en las dos cosas que se pedían.** `CA-15` dice
ahora **qué estadístico** son sus cifras (diferencia de **medianas** de 5 paradas; sin eso el
criterio no se podía verificar contra su propio registro) y **cuándo** se fijó la regla del margen:
escrita en la cabecera del arnés de medición **antes de medir**, con base y validación en
**invocaciones separadas**. Techo re-medido tras los arreglos: base 128.881 µs, envolvente 136.059,
**techo 0,140 s**, validación independiente **125.944 µs — conforme** (10,0 % de holgura). Y se
dice lo que no se puede afirmar: la subida desde `0,135 s` **no** se atribuye a los arreglos —las
cuatro medianas de las dos vueltas caen entre 121.192 y 128.881 µs— y en la vuelta anterior la
regla, aunque usaba sólo muestras del juego base, se eligió con el número de validación delante.

Sigue fuera: `CA-13`, `CA-14`, `CA-16`, `CA-17`, el manifiesto y su plantilla (gate humano). **La
rotación sigue apagada y no se rotó ningún REQ real.** `REQ-026` queda en `Estado: en-revisión`.

## [GitHub] — 2026-09-08 · `REQ-026`: el rotador ya sabe mover una TABLA, y cuando no la entiende no adivina
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

El reconocedor de entradas de `hooks/rotar-artefactos.sh` era una **enumeración de prefijos**
(`- `, `* `, `### `, `N. `) y el corpus contra el que corre son **tablas**: medido en tres REQ,
**30, 24 y 44 filas y CERO entradas reconocibles**. El 23 % de `requirements/` —**409.699 B
medidos**, bytes, no tokens ahorrados— era historia que el mecanismo no podía mover, y encenderlo
no habría hecho nada. Ahora una fila es entrada **sólo cuando la tabla ES la estructura de la
sección** (cabecera y separadora seguidas y en el preámbulo): la regla se enuncia por **propiedad**
(`REQ-012`) y no añadiendo `|` a la lista, porque una lista se vuelve a pudrir contra el siguiente
corpus.

**El segundo defecto era peor que no archivar:** el puntero se insertaba **entre la separadora y
las filas conservadas**, o sea rompía la tabla **en el origen** —en un REQ, no en una bitácora—.
Ahora va delante de la cabecera, y cada bloque archivado lleva **su propia** cabecera y separadora
copiadas byte a byte del origen, así que las dos tablas se leen como tablas.

**Y donde no se puede responder, no se contesta «sí»:** si la estructura es ambigua —filas sin
separadora delante, dos separadoras, una línea entre cabecera y separadora, separadora sin
cabecera— **no se archiva nada**, el archivo queda byte a byte igual, la parada sale 0 y se avisa
con texto propio **y** con su línea en el bloque derivado de `docs/ESTADO.md`: el stderr de una
parada no sobrevive a la sesión, y un fail-closed invisible es una sección que lleva meses sin
rotar sin que nadie lo sepa.

**Acreditación.** 19 casos nuevos (sección `28/3` del banco): **16 fallan** contra `c59fd83` y los
**19 pasan** contra este árbol; los 3 que pasan en los dos lados fijan conducta conservada
(CA-07, CA-09, CA-10) y son justo lo que un CA-08 descuidado rompe. Los que podían pasar **en
vacío** —CA-05, CA-06, CA-12— llevan una componente que exige que la rotación **haya ocurrido**.
Banco completo: **901 PASS · 0 FAIL · 5 SKIP** (total 906, `rc=0`, 1 m 04 s) y autoprueba del
corredor 106 PASS. Se corrige `SEC-066`: el README del banco decía 886 casos con
`CASOS_ESPERADOS` en 887.

**`CA-15`, el techo que no se fijó por adelantado: se derivó midiendo.** Coste atribuido a la
rotación ≤ **0,135 s** por parada. Juego base 121.192 µs de diferencia de medianas (25 artefactos,
régimen estacionario **comprobado**), envolvente de su propia dispersión 130.676 µs, techo al paso
de 5 ms; juego de validación independiente **123.312 µs — conforme**, 8,6 % de holgura. Un techo
puesto en la mediana pelada lo habría incumplido el segundo juego: es la quinta aparición de la
clase «criterio derivado sin comprobar su factibilidad» y la primera que se cierra con el margen
**medido** en vez de elegido.

**Lo que NO entra, y por qué:** `.arnes/config.json` y `templates/arnes-config.json.tpl` no se
tocan —cambiarlos es **gate de aprobación humana** (§6) y la cola ya tiene una entrada abierta—,
así que `CA-13`, `CA-14`, `CA-16` y `CA-17` siguen pendientes, **la rotación sigue apagada y no se
rotó ningún REQ real**. El bloque `rotacion.artefactos` propuesto queda **fechado dentro del REQ**.
Consecuencia declarada: hasta ese gate, la documentación del manifiesto y la del código
**discrepan**, y manda la del código. `REQ-026` queda en `Estado: en-revisión`.

## [Interno] — 2026-09-08 · Cola de aprobaciones: el techo de `REQ-019 CA-07` vuelve al propietario
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Entrada en `PENDING_APPROVAL.md` con la medición de F1, las tres opciones y la recomendación. El
techo `0,72×` se firmó sobre líneas y **en bytes no se alcanza**: suelo `0,820×` en `AGENTS.md` y
`0,802×` en el README, exceso de **6.705 B**, y es cota inferior porque no cuenta los punteros de
`CA-03`. `REQ-019` queda en `Estado: bloqueado` y **F2 no se despacha** sin la firma nueva.

**Por qué esto es un acierto del arnés y no un retraso:** la medición se pidió **antes** del reparto
precisamente porque era la quinta vez de la clase *«criterio derivado sin comprobar su
factibilidad»*. Sin ella, 7–11 h de reparto en solitario habrían apuntado a un blanco inalcanzable
y el techo se habría «descubierto» mal fijado al final, dentro de la comisión que lo incumplía —el
modo de fallo que `CA-08` de `REQ-017` describe y prohíbe.

## [GitHub] — 2026-09-08 · `REQ-019` F1: el techo `0,72×` **no es alcanzable en bytes**, y se sabe sin haber movido un byte
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

El techo `CA-07` de `REQ-019` sólo estaba medido en **líneas** (≈0,70× y ≈0,66×) y el propio REQ
predecía que **en bytes sería peor**. Se midió en la magnitud contratada, bloque a bloque y con el
filtro que el REQ registra como suyo: el suelo forzado es **27 730 B (0,820×)** en `AGENTS.md` y
**32 682 B (0,802×)** en `requirements/README.md` — **+6 705 B por encima** del techo. **No se repartió
nada y no se tocó el `0,72×`**: re-firmarlo es del propietario, y ya hay precedente (`0,60× → 0,72×`).
La medición queda por sección en el REQ, para que se audite sin re-medirla.

**Y la línea base había cambiado:** `requirements/README.md` pasó de **31 192 B** (`d266e8f`) a
**40 767 B**, +30,7 %. El crecimiento **no dio holgura, la quitó**: **7 570 de esos 9 575 B (79 %)
cayeron en suelo** —el contrato de forma del campo `Archivos:` y el `## Índice`— contra un techo que
sólo subió 6 894 B. Los derivados quedan en **≤ 53 707 B** (total), **≤ 24 355 B** y **≤ 29 352 B**.

Es la **cuarta vez** en este proyecto de la clase «criterio derivado sin comprobar su factibilidad»
—el techo de 400 líneas de `REQ-014 CA-18`, el `4×` de `REQ-021 CA-08 (iii)`, el `0,60×` de este mismo
criterio— y la **primera** que se descubre **antes** de gastar el reparto: 7–11 h de trabajo que no se
repartieron hacia un techo inalcanzable. La remediación 3 de `SEC-033` en `ADR-003` **no se ejecutó**:
la puerta de salida de F1 detiene el trabajo hasta que el propietario decida sobre el techo.

`REQ-019` pasa a **`Estado: bloqueado`** con el motivo en el campo, porque eso es lo que hay: detenido
por una decisión que no es del `desarrollador`. Dejarlo en `pendiente` habría dejado el disco diciendo
«confirmado, aún no iniciado» sobre un REQ que **no puede despachar F2**, y la parada sólo viviría en
el informe de una comisión.

## [GitHub] — 2026-09-08 · `REQ-019`: el ADR que este REQ anunciaba **ya estaba ocupado**
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

`REQ-019` citaba **ADR-006** como suyo y su fase F4 anunciaba «ADR-006 nuevo». Ese número lo tiene
`REQ-014`: existen en disco `ADR-006-techo-sobre-el-excedente-no-sobre-el-total.md` y
`ADR-007-oraculo-del-inventario-medida-frente-a-identidad.md`. El ADR de `REQ-019` **no existe**.
Corregido por write-back fechado, sin reescribir las filas del 2026-09-08, y el entregable de F4 pasa
a «ADR nuevo, primer número libre al crearlo». Sin esto, F4 pisaba el ADR de `REQ-014`.

Es la **misma causa raíz** que ya se registró en `REQ-017`: el número de ADR **no tiene asignador**,
así que quien escribe uno mira el disco y no las reservas de los REQ `pendiente`.

**Verificado además, y es lo que gobierna el trabajo siguiente:** las tres dimensiones de `SEC-033`
(`contrato`) **están cubiertas en `CA-05`** — documento entero, las dos direcciones y acreditación
única con forzador observable. Lo que falta es la **remediación 3**, que es del `desarrollador` y
vive en `ADR-003`, en **más sitios de los que el hallazgo nombra**.

## [GitHub] — 2026-09-08 · `REQ-017` **completado**: auditoría `R-020` y cierre del ciclo reabierto por §9
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `auditor-seguridad` (Opus) + coordinadora.

`Seguridad: aprobado (R-020, 2026-09-08)` sobre `538c266`, **sin veto**. Con `QA: aprobado` ya
firmado, `REQ-017` pasa a `completado`: cola de aprobaciones vacía, cero hallazgos `contrato` o
`usuario/dinero`, quality gates en verde.

**El agujero que el auditor cerró de camino:** la cabecera llevaba `Seguridad: aprobado (R-012,
2026-09-07)`, firma del árbol de **1.33.0**. Como `veredictos.caducan_con_codigo` está en `false`,
`guard-completado` **habría aceptado cerrar el REQ con una auditoría que no auditó este trabajo**.
La máquina no obliga; el auditor la re-emitió y lo dejó escrito.

**Verificado, no citado:** `TECHO47=1250`, `SER47=6` y `K47=4` idénticos entre `19b1822^` y HEAD, y
`git diff` vacío sobre `hooks/`, `tools/`, `.github/`, `.arnes/`, `templates/`, `skills/`, `agents/`
y `.claude-plugin/`. No se relajó nada para obtener verde.

**Tres hallazgos nuevos, los tres `instrumento`:**

- **`SEC-064`** (severidad **alta**) — **la abstención no tiene cota.** Con el ruido del instrumento
  (0,973–1,364) **mayor** que el techo que vigila (1,25), el estado estable de una regresión real
  entre ~1,25× y ~1,40× es **SKIP corrida tras corrida**, y nada cuenta las abstenciones
  consecutivas: la puerta requerida sigue verde con su mitad de reloj apagada. El proyecto ya tenía
  la clase nombrada en `H-08`, cerrada arreglando su instancia y no la clase.
- **`SEC-065`** (media) — `SEC-058` estaba registrado dos veces, la segunda más floja y sin
  vencimiento.
- **`SEC-066`** (baja) — `tests/escenarios/hooks/README.md:33` dice **886 casos** y
  `CASOS_ESPERADOS` vale **887**.

**Lo que este cierre NO acredita:** que `k = 4` resuelva en el runner de `hooks-en-linux` —todo lo
medido es **local**— ni el techo de coste `+28,0 s = 0,569×`, acreditado por el desarrollador y no
verificado por nadie.

## [GitHub] — 2026-09-08 · `REQ-017`: `QA: aprobado` sobre `538c266`, con el piso de `CA-18` verificado
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

Re-validación acotada de la vuelta 1. `QA-017-16` (`contrato`) **cerrado**: el SKIP por
no-convergencia recupera su tercera cifra y un caso lee el **contenido** del mensaje.

- **Cerrado con mutantes, no leyendo el commit.** Cinco mutaciones, cinco detecciones, cada cifra
  con su nombre propio: quitar `$x`, `$ce` o `$rob` del mensaje, dejar de vaciar `R47`, y envolver
  la llamada en `$( )`. Ninguna cifra se da por presente por casar con otra.
- **El mensaje vuelve a ser byte a byte el anterior al defecto**, así que los tres artefactos que
  lo declaraban se vuelven verdaderos **sin tocarlos** — código verdadero, no texto más laxo
  (`REQ-012 CA-06`).
- **`PISO_AUTONOMO_SECCION` 411 → 448 queda justificado con evidencia.** Fronteras medidas
  (123-449 = 327), crecimiento igual a lo añadido (`290+37`), y las 30 líneas del caso nuevo son
  indivisibles **por medición**: envueltas en `$( )` la aserción muere. El techo pasa de 514 a 560
  porque la fórmula lo pone ahí con el bloque real; el archivo queda en 504 y **ya cabía bajo 514**,
  así que no compró margen para esta entrega.

Quedan **seis** hallazgos `instrumento`, ninguno bloqueante.

**Hueco anotado en `docs/PENDIENTES.md`:** el tercer término de un piso de `CA-18` **no lo verifica
ninguna máquina** — un techo se podría ensanchar sin causa y la puerta no lo vería. Hoy sólo `37/5`
está gobernado por `piso × k`.

## [GitHub] — 2026-09-08 · QA de `REQ-017` en la ventana 1.34.0: siete hallazgos, uno de clase `contrato`
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

Validación de `19b1822`. `QA: con-hallazgos`. Se crea `docs/qa/1.34.0.md` con `QA-017-16` a
`QA-017-22`, cada uno con su clase.

- **`QA-017-16`** (`contrato`, ya corregido en `538c266`): el SKIP por no-convergencia había perdido
  la tercera cifra que `CA-08` contrata. **Ningún caso del banco podía verlo** — la autoprueba
  reduce cada salida a la palabra del veredicto y descarta el mensaje.
- **Seis `instrumento`**, registrados con dueño y vencimiento, fuera de esta ventana por la regla de
  acumulación del propietario: la abstención tira las razones ya calculadas (`-17`), no se comprueba
  que llegaran las `k` repeticiones (`-18`), el parser acepta registros de 2 o 6 campos (`-19`), las
  56 repeticiones existen sólo como prosa y `k = 4` no es auditable sin re-derivarlo (`-20`), el
  techo de coste y `k` salen de campañas distintas (`-21`), y `Archivos:` nombra dos secciones que
  no existen (`-22`).
- **`0,750×` es un techo y muerde:** `k = 5` daría 0,759×–0,821×. No se puso para que cupiera el
  `0,569×`.

Se anota en `docs/PENDIENTES.md` que `REQ-021` declara los **mismos** dos nombres fantasma, de modo
que hoy los dos defectos se tapan mutuamente: corregir sólo uno puede producir un `disjunto` en
falso. Y en `docs/ESTADO.md`, el punto de continuidad de la sesión autónoma, con la lectura del
tope de vueltas declarada como **revocable**.

## [GitHub] — 2026-09-08 · `REQ-017` / `QA-017-16`: el SKIP que perdió su tercera cifra, y el caso que ahora lee el mensaje
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

**El defecto.** La abstención por convergencia de brazo de `CA-08 (ii)` **retornaba con `R47` sin
asignar**, y la razón se calculaba **después** del retorno. El SKIP citaba dos cifras donde `CA-08`
contrata **tres** —«las dos razones de convergencia **y la razón que sí obtuvo**»—:

```
antes:    … por encima de su propio techo 1.250×, y sobre eso no se firma
después:  … por encima de su propio techo 1.250× — no puede distinguir una regresión de su
          ruido. La razón que sí obtuvo es 1.600×, y sobre eso no se firma
```

**El arreglo.** La razón se calcula **antes** de abstenerse y se publica en `MOT47`, **nunca en
`R47`**: `R47` no vacío significa «hay razón válida para juzgar» y así lo lee `veredicto08_47`, de
modo que la abstención lo sigue dejando **vacío**. El mensaje resultante es **byte a byte** el de
`19b1822^` (comprobado con `cmp` sobre la misma entrada). **Nada de lo que decide se mueve:**
`TECHO47 = 1250` intacto, `máx(ce,ch) > TECHO47` intacto, `k = 4` intacto, techo de coste `0,750×`
intacto.

**Y el segundo defecto, que es el que dejó pasar al primero.** La autoprueba de la cláusula reducía
cada salida a la **palabra** del veredicto con `sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p'` y
descartaba el mensaje: **nada del banco miraba el contenido**. Una guarda cuyo contrato es *lo que
dice* estaba verificada sólo por *lo que decide*. Se añade un caso que llama a `razon08_47` —la
función que decide, no una copia— y exige las **tres** cifras, con valores elegidos **distintos entre
sí y del techo** (1,400× · 1,020× · 1,600× frente a 1,250×) para que ninguna se dé por presente por
casar con otra, más que `R47` quede vacío.

**Acreditación.** Fail-before: contra el código de `19b1822` el caso da **FAIL** nombrando la cifra
ausente. Pass-after: **PASS** contra este árbol. Banco completo **882 PASS · 0 FAIL · 5 SKIP · rc 0**,
total **887** (era 886); autoprueba del corredor **106 PASS · 0 FAIL**; quality gates de `AGENTS.md`
§7 en verde. `CASOS_ESPERADOS_SECCION` 9 → 10, `CASOS_ESPERADOS` 886 → 887 y
`PISO_AUTONOMO_SECCION` 411 → **448** —el bloque indivisible crece 37 líneas—; el techo **no se
compra**: el archivo queda en **504** líneas, que ya cabían bajo el techo **anterior** de 514.

**Lo que NO se toca, y por qué.** Los tres artefactos que el hallazgo señalaba como falsos
—`REQ-017.md:80` «mismo umbral, mismo SKIP», `tests/escenarios/hooks/README.md:325-326` y la entrada
de `19b1822` de este mismo archivo— **vuelven a ser verdaderos con el arreglo**, así que se dejan
como están. `QA-017-17` (`instrumento`) **sigue abierto**: las repeticiones 2..k continúan sin
publicarse cuando la primera no converge.

## [GitHub] — 2026-09-08 · `REQ-026`: la selección de qué historiales se rotan deja de copiarse de `Archivos:`
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Write-back del analista que quedó **sin comitear** en el árbol. Dos correcciones de contrato en
`REQ-026`, ninguna de código:

- **`CA-13` contradecía a `CA-17`.** El `glob` declaraba «la forma `requirements/REQ-*.md`», que casa
  con **todos** los REQ, mientras `CA-17` exige que el conjunto case **exactamente** con los
  candidatos. Pasa a **selección explícita**: un elemento de `rotacion.artefactos` por candidato.
  El origen del error queda escrito — el literal se copió de `Archivos:`, que declara ámbito de
  **escritura** para `tools/arnes-paralelo.sh` y **no** el conjunto a rotar. Aviso añadido en los dos
  sitios.
- **`CA-15` fijaba `≤ 1,5 s` sin ninguna medición detrás.** Se retira el número y el criterio pasa a
  **derivar el techo midiendo**, con condiciones completas (plataforma, reposo, corpus, definición de
  «parada», coste = diferencia de medianas con `activo` true/false) y validación contra un **segundo**
  juego de paradas. Es la **cuarta** vez de la clase *criterio derivado sin comprobar su
  factibilidad* en dos ventanas.

Se registra también el bloque derivado de `docs/ESTADO.md`, que reescribe el hook en cada parada.

## [GitHub] — 2026-09-08 · `REQ-017 CA-08 (ii)`: la resolución se comprueba sobre la RAZÓN, con `k` derivado midiendo
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

La sonda que decide la puerta requerida `hooks-en-linux` ya no firma sobre **una** razón. El par
intercalado se repite **k = 4** veces, cada repetición produce **su** razón, y el caso publica **las k
razones, su recorrido `máx(r)/mín(r)` y el techo** antes de decidir: **PASS** si `máx(r) ≤ techo`,
**FAIL** si `mín(r) > techo`, **SKIP** en cuanto el techo cae **dentro** del recorrido. La unanimidad es
de contrato — sin mayoría, sin promedio, sin «la mejor de k». El techo **≤ 1,25× no se toca**.

**La unidad, definida una sola vez, porque las cifras que circulaban no encajaban.** Una **repetición** es
**un par intercalado completo**: una invocación de `sonda-reloj.sh` con `--r 6 --k 4` y los dos sujetos,
o sea 6 series alternadas a,b por árbol × 4 llamadas al hook por serie = **48 llamadas**, y produce
**exactamente una razón**. Cuesta **≈ 4,1 s** con el REQ de 6 líneas y **≈ 6,0 s** con la cabecera de 200:
son **dos casos distintos**, no los dos brazos de uno. El **5,1 s** que circulaba era el **promedio de los
dos casos** en el arnés de medición (102 s / 20 repeticiones) — otra unidad, y por eso no cuadraba.

**La aritmética del coste, para que se recalcule sin volver a medir.** Sección = *constante* + *k* ×
(4,1 + 6,0) s. La constante ≈ **4,9 s** (materializar v1.32.1, sonda de procesos, los dos casos de CA-06 y
el arranque del corredor) sale de la sección medida a k = 1: **15,04 s − 10,1 s**. Con k = 4 → 4,9 + 40,4 =
**45,3 s** previstos, **48,84 s** medidos aislada. Queda **fuera** de esa cuenta lo que el resto del banco
paga por competir con ella bajo `JOBS=6`, que es justo lo que hay que acotar: **banco entero, mínimo de 3
vueltas, 49,19 s sin la guarda y 77,19 s con ella → +28,0 s = 0,569×**, bajo un techo **operativo** de
**0,750×** (dirección **bajar**). **Cabe: no se activa la salida del propietario**, y la regresión que este
criterio vigila valía **92 s** en esa misma puerta.

**`k` se derivó midiendo, que es lo que el criterio manda.** 56 repeticiones reales, **56 válidas de 56
intentadas**, en tres entornos: ociosa, con 5 vecinos del tipo que el banco fabrica, y con todo fijado a
**2 CPU con 6 procesos encima**. El recorrido observado **crece y satura**: k = 4 es el **menor** tamaño de
ventana cuya **peor** ventana ya alcanza el recorrido de la muestra entera en las cuatro series
(**1,268× de 1,268×**, **1,262× de 1,262×**); con k = 3 una veía **1,178× de 1,262×** e **infradeclaraba su
propio ruido**. Se descarta el criterio «el menor k con el recorrido bajo el techo»: el recorrido es
**no decreciente** en k, así que lo cumple k = 1 — la sonda ciega que produjo los dos rojos.

**Emulación ≠ validación, declarado como límite y no como equivalencia.** Los 2 CPU **acotan** el
comportamiento bajo carga; **el CI real es quien decide la puerta**. El recorrido **1,40** y los dos rojos
vienen de `hooks-en-linux`; aquí **ninguna** de las 56 razones cruzó el techo (máx. **1,087×**), así que `k`
está derivado sobre la **saturación del recorrido**, no sobre la frecuencia del rojo, que localmente es 0.

**Y la guarda se entrega con su par discriminante, ejecutado y no argumentado** (`37/5`, casos 7 → **9**;
total del banco 884 → **886**): **(a) negativo** — dispersión ensanchada **sin** regresión → **SKIP**, y con
la guarda **desactivada** la misma entrada da **PASS PASS FAIL PASS**, que es lo que demuestra que el rojo lo
quita la guarda y no la entrada; **(b) positivo** — regresión sintética de **2×** sobre esa misma entrada con
ruido → **FAIL**, y sin regresión ni forzador → **PASS**. La convergencia por brazo **se queda como estaba**
—mismo umbral, mismo SKIP— marcada **necesaria y no suficiente**.

Banco **882 PASS · 0 FAIL · 4 SKIP** (los 4 preexistentes) y autoprueba **106 PASS · 0 FAIL**.

## [GitHub] — 2026-09-08 · Punto de continuidad de la ventana 1.34.0 en `docs/ESTADO.md`
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Escrito **fuera** de los marcadores del bloque derivado (comprobado antes de editar). Recoge: alcance
aprobado de 1.34.0, estado por REQ **distinguiendo implementado / contratado / pendiente de verificar**,
los **identificadores de los agentes** para reanudarlos en vez de duplicarlos, las condiciones de parada,
las decisiones pendientes del propietario y la siguiente acción. Evidencia **enlazada**, no copiada.

**Lo que el punto deja explícito y conviene no perder:** `REQ-017` tiene `QA:` y `Seguridad:` en verde en
su cabecera, pero **son de 1.33.0 y no cubren** el trabajo en curso. `REQ-026` y `REQ-027` están
**contratados y sin implementar** — crear un REQ no instala nada. Y las cifras de la sonda que circulan
(~5,1 s, 4 s + 6 s, ~55 s para `k=4`, emulación de 2 CPU) están marcadas **pendientes de verificar**: la
coordinadora **no las ha visto**, y **no encajan entre sí** bajo una misma definición de «repetición»
(4+6 = 10, no 5,1).

**Regla de reanudación registrada:** comprobar el estado de los agentes existentes **antes** de despachar
otros. Cinco quedan reanudables por identificador; despachar de nuevo duplicaría trabajo ya pagado.

## [GitHub] — 2026-09-08 · `REQ-027`: la distribución completa contratada, y la idempotencia deja de deducirse de una etiqueta
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Ajuste acotado sobre el REQ ya abierto —**16,6 k tokens**, sin reescribirlo—. Pasa de 8 a **10 criterios**.
`skills/arnes-upgrade/SKILL.md` entra en `Archivos:`.

**Crear el REQ no instala las reglas, y ahora el contrato lo refleja: las TRES vías están contratadas**,
no dos y una nota. Este repositorio (`CA-01`) · proyectos **nuevos** (`CA-09`: nacen con el bloque
completo entre marcadores y **sin ningún `{{…}}` dentro**) · proyectos **ya instalados** (`CA-10`).

**`CA-10` convierte la migración en CONDICIÓN DE ENTREGA, no en pendiente.** Dueño `desarrollador`,
ventana 1.34.0. **Puede escribirse al cerrar la versión, pero el REQ no pasa a `completado` sin sus tres
partes**, y la diferencia no es formal: un pendiente se olvida sin que ninguna puerta grite.

**Y la corrección que más vale, porque desmonta una afirmación de la coordinadora:** yo escribí que los
marcadores «hacen la inserción idempotente». **Falso — hacen el bloque IDENTIFICABLE.** La idempotencia
es una **conducta** de la migración y ahora se comprueba **directamente**: correr dos veces, comparar,
**un solo bloque byte a byte igual**. Más `MODIFICADO` → conflicto que se pregunta y no se pisa,
`UNKNOWN` → se detiene, y el **negativo obligatorio**: un caso en que la migración **sobrescriba texto
propio del proyecto debe FALLAR**. Sin ese negativo, «preserva las instrucciones particulares» era una
promesa que nadie podía desmentir.

**`CA-07` pasa de enunciar vías a verificarlas, y el resultado es incómodo y honesto:** **sólo Claude
Code queda `verificada`** —evidencia: la línea `@AGENTS.md` del `CLAUDE.md`, **no** la frase de
`AGENTS.md:3-4`—; **Codex y Cursor quedan `no verificada`**. Límite contratado: *una vía no verificada no
cuenta como cobertura*, con par discriminante — presentarla como cubierta es **no conforme aunque las
reglas estén completas**.

**`CA-05`: el techo de 2 600 B se declara límite propuesto SIN VALIDAR.** `operativo` dice cómo se mueve,
**no que el contenido requerido quepa**. Se valida al escribir el bloque y, si no cabe, **se re-deriva con
entrada en Historial — el contenido contratado no se recorta para que entre**.

`REQ-025` queda como **dependencia explícita**, sin comisión y sin condicionar el cierre.

## [GitHub] — 2026-09-08 · `REQ-027`: las reglas de la coordinadora, en la sede canónica y con sus dos límites contratados
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

REQ nuevo, `pendiente`, 1.34.0, **`Rigor: critico`**. 8 criterios en 210 líneas. Contrata que las reglas
de trabajo de la coordinadora —la comprobación de cuatro preguntas antes de despachar, las seis reglas
compactas y la separación coordinadora/herramientas— vivan en **`AGENTS.md`** y **`templates/AGENTS.md.tpl`**,
entre los marcadores `<!-- arnes:coordinacion:inicio/fin -->` (nombres **de contrato**, para que la
migración sea idempotente).

**La sede se corrigió en vuelo, y el motivo importa.** El encargo inicial las mandaba a
`templates/CLAUDE.md.tpl` para no chocar con `REQ-019`. **Comprobado: `REQ-019` estaba `pendiente`, sin
comisión viva y sin el archivo modificado — la colisión era hipotética**, y evitarla dejaba fuera a los
coordinadores de Codex y Cursor, que leen `AGENTS.md` y no `CLAUDE.md`. Con la sede canónica, el rigor
subió de `estandar` a **`critico`** y la sensibilidad a **sí**.

**`CA-07` contrata las vías de lectura y los dos límites**, con par discriminante: un texto que **insinúe
cobertura universal**, o que **dé por migrados los proyectos ya instalados**, es **no conforme aunque
contenga las reglas completas**. Cambiar una plantilla no actualiza a nadie: `templates/` sólo alimenta
`arnes-init`, y un proyecto instalado tiene su `AGENTS.md` congelado hasta que migre.

**`CA-06` añade una propiedad que nadie había pedido y evita un fallo silencioso:** *el conjunto de
títulos `## N.` no cambia*. El bloque entra **sin renumerar**, o se rompen a la vez **todas** las
referencias `§N` que agentes y REQ llevan escritas.

**`CA-05` mide el delta en bytes sobre `AGENTS.md`** (≤ 2 600 B, **operativo**) y obliga a anotarlo en el
Historial, **para que `REQ-019` mida contra un número** en vez de contra un archivo que cambió de tamaño
por debajo.

**Limitación declarada por el propio analista:** no re-midió ninguna cifra —`33 827 B`, `74 255 B`,
`0,60×/0,68×`, `≤ 1,5 s`— y entran **citadas como dato del encargo**; y sin herramienta de shell, el techo
de 2 600 B es **una estimación**, declarada `operativo` por eso.

**Pendiente que NO se escribió y queda anotado:** la entrada de «Migraciones conocidas» en
`skills/arnes-upgrade/SKILL.md` para 1.34.0. Sin ella, ningún proyecto instalado recibe las reglas.

**Coste: 74,5 k tokens** —por encima del objetivo de 50 k—, y la causa está declarada: la corrección de
sede obligó a reescribir el REQ entero, y el contador acumula el reenvío del contexto de arranque (~18 k)
en cada llamada.

## [Interno] — 2026-09-08 · CORRECCIÓN: `REQ-019` sigue en 1.34.0, y su coste es una ESTIMACIÓN, no una medición
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Corrige dos afirmaciones de la coordinadora del mismo día. **La entrada anterior no se reescribe**
(`CHANGELOG.md:178`, «Pero `REQ-019` NO cabe en 1.34.0, y está medido»): la corrección va fechada.

**1. No estaba medido: es la estimación del propio REQ.** `requirements/REQ-019.md:1375` dice
literalmente *«Es estimación, no medición, y se declara como tal»* sobre las 9–11 comisiones y las
8,5–14 h. Presentarlo como medición convirtió un insumo en un hecho.

**2. «No cabe» era una conclusión de la coordinadora, no una decisión.** El alcance aprobado por el
propietario el 2026-09-08 (`docs/PLAN.md`, ALCANCE DE 1.34.0) lista `REQ-019` como **trabajo #2 de los
cuatro**; **no** aparece en «Lo que SALE de 1.34.0»; y el REQ declara `Versión destino: 1.34.0`.
**`REQ-019` sigue en 1.34.0 por decisión vigente**, y los dos documentos ya coincidían.

**Y la discrepancia que la coordinadora reportó entre `PLAN.md` y el REQ no existía**: fue inventada al
reconstruir el alcance de memoria en vez de consultarlo. `docs/PENDIENTES.md` queda reetiquetado
—«ESTIMADO (no medido)»— con la conclusión de ventana retirada y el insumo conservado.

**Regla que queda en vigor:** antes de despachar o recomendar un cambio de ventana, **consultar la última
decisión aprobada y reconciliar el plan con los REQ afectados**. Si la decisión existe, se **sincronizan
los documentos**; sólo se pregunta cuando falte una decisión real. Y **ninguna estimación de coste o
desplazamiento se presenta como hecho comprobado**.

## [Interno] — 2026-09-08 · Desfase de fechas de la coordinadora: 25 corregidas, 20 anotadas, y la lección que sólo aparece de noche
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Tras publicar `v1.33.0` leí los sellos de GitHub —`mergedAt: 2026-09-09T02:31:08Z`— y empecé a fechar en
**UTC**. El repositorio usa **fecha local**: 42 entradas del 09-08 contra 8 del 09-09, y el merge y el tag
llevan `2026-09-08 20:31 -0600`. Eran las 21:26 CST del 08 con UTC ya en el 09.

**Lo detectó el `analista-requerimientos`**, no yo: al cerrar `REQ-026` avisó de que el sistema declaraba
09-08 y el REQ estaba fechado 09-09, y **fechó sus filas nuevas en 09-09 a propósito** para no dejar una
corrección anterior a la creación en la misma tabla — decisión correcta con la información que tenía, y
lo dijo en vez de callarlo.

**Corregidas 25** (`CHANGELOG.md` 10, `docs/PENDIENTES.md` 8, `docs/PLAN.md` 5, `PENDING_APPROVAL.md` 1,
`docs/ESTADO.md` 1), **enumeradas una por una antes de sustituir** y comprobando que ninguna fuera una
referencia legítima a un sello UTC. No en bloque: un `sed` global sin mirar es lo que esta misma mañana
estuvo a punto de hacer que `CA-05`, `CA-08` y `CA-09` pasaran **por tautología**. En `docs/ESTADO.md` se
verificó además que la mención estuviera **fuera** de los marcadores del bloque derivado.

**Quedan 20 anotadas** en `REQ-019` (12) y `REQ-026` (8): son contrato del analista y se corrigen en la
próxima comisión que toque cada archivo — una comisión dedicada a dos sustituciones cuesta más de lo que
arregla. `REQ-017` no está afectado.

**La lección:** las horas de las APIs vienen en **UTC** y las del repositorio son **locales**; a partir de
las 18:00 CST son días distintos. Leer un sello de GitHub y escribirlo como fecha del proyecto es un error
que **sólo aparece de noche**, que es cuando nadie lo revisa.

## [Interno] — 2026-09-08 · Prioridades de ahorro reordenadas por el propietario, con dos precisiones que invierten el orden anterior
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Sobre un análisis externo aportado por el propietario, con sus cifras **verificadas** (`agents/auditor-seguridad.md`
17.459 B, `agents/qa-tester.md` 10.834 B, el 39 % en `docs/PLAN.md:442`, el tope de 200 k en `AGENTS.md:231`).

**Orden acordado:** (1) **comprobar la factibilidad de los criterios nuevos** y (2) **reducir el contexto
de la coordinadora**, **por delante de** adelgazar las definiciones de agente.

**El primero tiene cuatro instancias medidas en dos ventanas** —400 líneas de `REQ-014 CA-18`, 4× de
`REQ-021 CA-08 (iii)`, `0,60×` de `REQ-019 CA-07` y el `1,5 s` de `REQ-026 CA-15` de hoy—: cuatro veces el
argumento correcto y **el valor sin comprobar**. Una comprobación de factibilidad **dentro del análisis
que ya se hace** las habría cazado las cuatro; es una regla, no un mecanismo nuevo.

### Dos precisiones del propietario que corrigen afirmaciones de la coordinadora

1. **El 39 % es del ciclo documentado, no de esta sesión.** No se sabe cuánto representa la coordinadora
   hoy, y **no se ha medido**: las cifras que sí existen son las de los subagentes (≈1,0 M tokens en diez
   comisiones), y el consumo propio de la coordinadora **no está instrumentado**. Decirlo así en vez de
   estimarlo.
2. **El tamaño de un documento indica contenido potencialmente reducible, NO ahorro efectivo.** Y de ahí
   una **inversión del orden que la coordinadora no había visto**: la definición de agente se carga
   **siempre**, incondicionalmente; el historial de un REQ **sólo cuando se lee**, y la lectura selectiva
   —ya activa— **ya lo evita a menudo**. Así que **el ahorro MARGINAL de adelgazar los agentes puede
   superar al de rotar historiales**, aunque su tamaño sea menor. Es exactamente el principio que
   `REQ-026 CA-14` contrata —la magnitud es la lectura real antes/después, no el tamaño— aplicado a la
   propia priorización.

**Y el `1,5 s` está SIN FUNDAMENTAR, no demostrado imposible.** La distinción importa: la medición dirá
si es alcanzable. Lo que la comprobación previa habría detectado es **la falta de evidencia**, no la
imposibilidad.

## [Interno] — 2026-09-08 · Cuatro precisiones sobre `REQ-026` registradas para su implementación (sin abrir otra ronda)
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Revisión externa verificada contra el REQ. **No se abre otra ronda de análisis** —decisión del
propietario: cerrar el contrato y seguir con la sonda—; van a `docs/PENDIENTES.md` para que la comisión
de implementación no las descubra a mitad.

**Dos son defectos reales del contrato:**

1. **`CA-15` fija «≤ 1,5 s de reloj» SIN declarar plataforma.** Aquí eso no es menor: `AGENTS.md` §7
   registra que el mismo banco tarda **~30 min en Windows y segundos en Linux**. Un techo de reloj sin
   plataforma **no se puede desmentir ni acreditar**, y la primera medición que lo supere no distinguirá
   una rotación cara de un runner cargado — el modo de fallo que `REQ-017 CA-08` acaba de costar una
   ventana entera.
2. **Tensión entre `CA-13` y `CA-17`:** el primero pide el `glob` «con la forma `requirements/REQ-*.md`,
   ajustado a los candidatos»; el segundo, que case **exactamente** con los candidatos. **Un glob con esa
   forma casa con todos**, así que las dos frases sólo son ciertas a la vez si todos los REQ son
   candidatos — que es lo que `CA-17` niega. **No se resuelve implementando: se resuelve en el REQ.**

**Dos son avisos que evitan un error de lectura:** `Archivos:` declara `requirements/REQ-*.md` como
ámbito **de escritura** —para que `arnes-paralelo.sh` no autorice paralelismo en falso—, y **no** como
conjunto a rotar; los dos campos llevan el mismo literal y confundirlos convertiría una declaración
prudente en la decisión de rotarlo todo. Y `orden: nuevo-al-final` está acreditado en **un** archivo
(`REQ-017`), no en todos: **se comprueba por candidato**, porque equivocarlo archiva lo más reciente.

**Corrección de coste para el registro:** la comisión de `REQ-026` costó **≈56 k tokens**, no los ≈46 k
del informe preliminar — la diferencia son las tres rondas de corrección en vuelo.

## [Interno] — 2026-09-08 · `REQ-026` cerrado con la cuarta corrección: el punto de equilibrio cuenta **cuatro** costes, no uno
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

`CA-17` queda contratando el punto de equilibrio contra el **gasto adicional total** de rotar un REQ:
**revisión inicial + extracción/redacción de las decisiones vigentes + la rotación + su validación**.
Leer la historia era sólo una de las cuatro, y presentarla como la única habría hecho que un REQ pareciera
amortizable cuando no lo es. Con cuatro costes en vez de uno, **el umbral para que un REQ sea candidato
sube** — y la consecuencia de `CA-17` (no se rotan todos) se sostiene con más razón.

**17 criterios, 246 líneas. Coste total ≈56 k tokens incluidas las tres rondas de corrección en vuelo.**

**Cierre de la ronda de revisión externa, por acuerdo del propietario: no hay más rondas.** De las
cuatro afirmaciones de la coordinadora que esa revisión desmintió, **tres se corrigieron en el contrato**
(el peso mal medido, «tokens ahorrados» por «estimados», y que rotar hiciera segura la lectura selectiva)
y la cuarta —«una puerta permanente costaría un ciclo entero y cubriría lo mismo»— **se retira sin
sustituirla por otra afirmación**: ni ese coste ni esa equivalencia están medidos, y aplicar hacia atrás
una comprobación a tres fallos ya conocidos **no demuestra que los hubiera evitado**. Lo respaldado es
usarla dentro del trabajo normal y **observar qué caza y qué se le escapa** — prueba prospectiva, no
retrospectiva. Queda anotado como práctica, no como mecanismo, y **no sustituye lo previsto en
`REQ-025`**.

## [GitHub] — 2026-09-08 · `REQ-026`: rotar los historiales de REQ — y el descubrimiento de que rotar hoy rompe la tabla **también en el origen**
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

REQ nuevo, `pendiente`, ventana 1.34.0, `Rigor: critico`. **17 criterios en 235 líneas y 19 KB** — un REQ
que existe para que los REQ pesen menos, y que practica su tesis.

**El descubrimiento que nadie encargó y que decide si el trabajo sale bien.** Con el código actual el
puntero se inserta **al final del preámbulo** (`hooks/rotar-artefactos.sh:367-368`), es decir **entre la
fila separadora y las filas conservadas**: rotar **rompe la tabla también en el ORIGEN**, no sólo en el
destino —que además se abre con un preámbulo de título sin cabecera ni separadora (`:352-353`)—. Por eso
el REQ lleva **dos** criterios de legibilidad, `CA-03` (destino) y `CA-04` (origen), y no uno.

**Esto zanja una afirmación de la coordinadora que ya había retirado.** Dije que arreglar el rotador «es
una función». Un revisor externo objetó que **eso no estaba medido**; tenía razón, y la medición del
analista lo confirma con creces: no es reconocer `|`, es reconstruir la tabla en dos sedes sin perder ni
duplicar filas.

**Y `orden: nuevo-al-final` está MEDIDO, no supuesto:** `requirements/REQ-017.md:436` es
`| 2026-09-07 | (creación) |` y las filas de `:462-463` son del 2026-09-08. Lo más antiguo está arriba.
Equivocar ese campo archiva **lo más reciente**, que es el modo de fallo que `arnes-upgrade` documenta
para 1.26.0.

### Las cuatro correcciones que entraron en vuelo, todas de una revisión externa verificada aquí

1. **El peso, re-medido: 409.699 B / 23 %.** La cifra anterior (399.182 B) estaba **por debajo**: el
   `awk` usaba `length()`, que cuenta **caracteres**, y el español lleva acentos multibyte; además sumaba
   la línea del encabezado siguiente antes de cortar.
2. **Las cifras por comisión se renombran «tokens ESTIMADOS DEL HISTORIAL»**, no «ahorrados»: salen de
   bytes ÷ 4 y miden **tamaño**. `CA-14` contrata la **lectura real antes/después sobre la práctica
   vigente** y **admite explícitamente ahorro 0** — porque si una comisión no leía ese historial, **no
   hay ahorro atribuible**.
3. **`CA-16`, el criterio que hace segura la rotación:** *toda decisión **vigente** queda reflejada en el
   contrato activo o lleva en él una referencia explícita de cuándo consultarla en el archivo*. Corrige
   otra afirmación de la coordinadora: archivar conserva la **evidencia**, pero **no** vuelve seguro
   dejar de leer — sin este criterio, rotar convierte «una decisión difícil de encontrar» en «una
   decisión que nadie sabe que existe».
4. **`CA-17`: no se rotan todos los REQ.** Dos condiciones de candidatura —que su historia **se lea de
   verdad** y que el REQ **siga abriéndose**— y el punto de equilibrio como **propiedad**, contando el
   gasto **completo**: revisión inicial, **extracción de las decisiones vigentes**, la rotación y su
   validación. Leer la historia es sólo una parte. Un REQ enorme y cerrado que nadie abre **no ahorra
   nada al rotarse**, y el `glob` se ajusta a los candidatos.

**Gate humano pendiente:** `CA-13` pone `rotacion.activo` en `true` para este repo, y eso es cambio del
manifiesto (`AGENTS.md` §6). **Consecuencia operativa declarada:** al activarse, cada parada reescribe la
historia de todos los REQ que casen, así que esa comisión **no se despacha en paralelo con ninguna otra
que edite un REQ**.

**Coste: ≈46 k tokens, 27 llamadas.**

## [GitHub] — 2026-09-08 · `REQ-019` ejecutable, y **la palanca que nadie había medido**: los historiales pesan el 22 % y la rotación no los ve
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` (Opus) + coordinadora.

**`REQ-019` queda ejecutable.** Techo de `CA-07` **`0,60×` → `0,72×`** con firma del propietario
(2026-09-08) y por el procedimiento que el propio REQ exigía; derivados en bytes recalculados
(total ≤ 46.813 B; `AGENTS.md` ≤ 24.355 B; README ≤ 22.458 B). Línea base corregida en sus **tres** sedes
(**433 → 521**), con las derivaciones que colgaban de ella **declaradas obsoletas con fecha** en vez de
maquilladas. `D-3`, `D-5` y `D-9` arreglados. **`D-2` resuelto**: `CA-17.1` gana un tercer valor,
**`parcial`**, válido *sólo* con sus dos mitades en la misma fila. **62 k tokens.**

*(El propietario pidió aplazar `D-2` a una versión futura y la comisión que lo arregla **ya estaba
despachada** cuando llegó la instrucción. Queda resuelto, no aplazado; corregido en `docs/PENDIENTES.md`.)*

**Y la clase, nombrada en el Historial por tercera vez en dos ventanas:** el `0,60×` era **un criterio
derivado sin comprobar su factibilidad**, igual que el techo de 400 líneas de `REQ-014 CA-18` y el de 4×
de `REQ-021 CA-08 (iii)`. Las tres con el argumento correcto y **el valor sin comprobar**.

### Pero `REQ-019` NO cabe en 1.34.0, y está medido

Se estima a sí mismo en **9–11 comisiones y ≈8,5–14 h**, con **F2 y F3 en SOLITARIO** (`CA-16`): mientras
corren, nada más corre. **No es un trabajo de la ventana — es la ventana.** Y choca con un plazo que no
se negocia: el vencimiento de `SEC-047` (severidad **crítica**) es **el cierre de 1.34.0**, escrito por el
auditor en su sede. Aritmética completa: coste 0,9–1,1 M tokens; ahorro ≈5.200 de carga por comisión
(≈300 k equivalentes por ventana con el efecto de caché); **retorno ≈3–4 ventanas**. Se paga, **pero no
pronto**, y mientras se paga bloquea la ventana en la que vence un hallazgo crítico.

### La palanca mejor, aportada de fuera y verificada aquí

Un análisis externo (ChatGPT, aportado por el propietario) señaló que adelgazar `AGENTS.md` **pierde
parte del beneficio si después se lee entero un REQ de 150.000 caracteres**. **Correcto — y el motivo es
más preciso de lo que él podía demostrar.** Medido:

| | |
|---|---|
| `## Historial de cambios` en todo `requirements/` | **399.182 B = 22 %** del directorio ≈ **99 k tokens** |
| `REQ-014` | 67.133 B — el **43 %** de su archivo |
| `REQ-021` | 75.943 B · `REQ-017` 39.672 B (su analista midió **~13 k tokens** sólo por él) |

**El bloqueo, exacto:** `hooks/rotar-artefactos.sh` **ya sabe** archivar una sección dejando cabecera y
criterios intactos —es invariante suya—, pero reconoce como entrada las líneas que empiezan por `- `,
`* `, `### ` o `N. `, **y estos historiales son TABLAS**: sus filas empiezan por `|`. Medido en tres REQ:
**30, 24 y 44 filas y CERO entradas reconocibles**. El propio hook lo avisa: *«SÍ contiene la sección y
supera el umbral, pero no tiene ni una ENTRADA reconocible; no se rota»*. **El mecanismo existe, está
apagado, y encenderlo hoy no haría nada sobre lo que más pesa.**

**Va por delante de `REQ-019`, y no sólo por coste:** mientras los historiales pesen 99 k tokens, **el
ahorro de `REQ-019` no se puede atribuir** —quedaría mezclado con qué REQ tocó cada comisión—, que es
exactamente el error que `docs/PLAN.md` ya documenta como «la línea base envenenada».

### Contradicción verificada sobre quién comitea

Del mismo análisis. **Cierta:** `agents/desarrollador.md:59-60,69` manda al desarrollador comitear y
actualizar `CHANGELOG.md` en el mismo commit; `requirements/README.md:197-198` dice que esa entrada la
escribe **«quien comitea, que es quien orquesta»**. Dos documentos, el mismo trabajo, dos dueños — y
`agents/desarrollador.md` **lo heredan todos los proyectos que instalan el arnés**, así que se propaga.

### Lo que del análisis externo ya estaba aplicado, para no cobrarlo dos veces

Sus puntos 3 (**devoluciones breves**) y 4 (**revisar por diferencia**) **ya se aplican desde ayer** y
están medidos: los informes van con evidencia **citada, no transcrita**, y la vuelta de confirmación de
QA sobre el delta costó **64 k** frente a los **229 k** de la validación completa. Lo que no están es
**contratados** — son método de la coordinadora, no regla escrita, y ahí su observación sí añade.

Su punto 1 (`REQ-019` primero) es el que la medición desmiente, arriba.

## [GitHub] — 2026-09-08 · `REQ-017` reabierto: `CA-08 (ii)` deja de acotar el brazo y pasa a acotar **la razón**
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Primer trabajo de 1.34.0 contratado. `REQ-017` vuelve a `en-progreso` con destino **1.34.0** (§9, REGLA
DE ESTADO), y `REQ-011` y `REQ-020` corrigen su `Versión destino:` — declaraban 1.33.0, que se publicó
sin ellos.

**La forma elegida es la 2 de las tres conformes, y el motivo es la magnitud.** La convergencia por brazo
acota la dispersión **dentro** de cada serie; el ruido del cociente viene de las condiciones **entre**
brazos, y ninguna cota sobre los brazos lo acota. Los dos rojos lo enseñan: un brazo al borde —1,232× y
1,249× contra el límite 1,250×— y **sobre esa resolución se afirma un 1,364×**. La forma 1 volvería a
fijar un número sobre la magnitud equivocada; la 3 saca la señal de la puerta y es del propietario —queda
escrita como **contingencia declarada** si el `k` necesario no cabe bajo el techo de coste, con ruta a
`PENDING_APPROVAL.md`.

**Lo que contrata ahora `CA-08 (ii)` — una propiedad, no un número.** *Un instrumento que no puede
distinguir el factor que vigila se abstiene.* El par intercalado se repite **no menos de `k`** veces
(`k` **operativo**, dirección **subir**, **derivado midiendo** por el `desarrollador`, `REQ-012 CA-03`);
el caso publica las `k` razones, su recorrido `máx(r)/mín(r)` y el techo. **PASS** si `máx(r) ≤ techo`;
**FAIL** si `mín(r) > techo`; **SKIP** en cuanto el techo cae **dentro** del recorrido. **La unanimidad de
las `k` es de contrato** —es la definición de «la decisión no depende del ruido»—: sin mayoría, sin
promedio y sin «la mejor de `k`». Y **la guarda paga su propio coste**, con techo `operativo` sobre lo
que añade a la puerta requerida.

**Par discriminante, con la segunda mitad que suele faltar.** *Negativo:* dispersión ensanchada sin
regresión → **SKIP**; y con la guarda **desactivada**, esa **misma** entrada da PASS o FAIL según la
corrida — sin esa mitad, un SKIP no prueba que lo causara la guarda. *Positivo:* regresión sintética de
**no menos de 2×** → **FAIL**, no SKIP.

### Lo que nadie le pidió y es lo mejor de la comisión

`CA-08` llevaba escrita una **condición de disparo** con su consecuencia: *si se dispara, el número está
mal fijado y subirlo es decisión del propietario con ADR*. **Se disparó** — y el analista comprobó que
**la consecuencia era la equivocada**: el `0,973×` sitúa al árbol nuevo **por debajo** de la línea base,
así que no hay techo que subir. Dejó la condición **declarada como cumplida**, **descartó el consecuente**
y escribió una **condición de disparo nueva** (FAIL unánime sobre un árbol sin regresión). Sin eso, el
siguiente que leyera ese párrafo tendría **permiso escrito** para relajar el criterio.

**Decisión de juicio declarada:** añadió `docs/qa/1.34.0.md` al `Archivos:` de `REQ-017`. Sin declararlo,
`tools/arnes-paralelo.sh` respondería `disjunto` **en falso** contra los REQ de 1.34.0 que sí lo declaren.
Consecuencia asumida: `REQ-017` **colisiona** con todo REQ de la ventana que lo declare — fail-closed a
propósito.

**Coste: ≈95 k tokens, 23 llamadas.** 26 líneas cambiadas en `REQ-017` para reescribir un criterio.

## [Interno] — 2026-09-08 · Mejora aplazada a versión futura por el propietario: el campo que no sabe decir «parcial»
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Registrada en `docs/PENDIENTES.md` bajo la regla de acumulación; **no entra en 1.34.0**.

`CA-17.1` de `REQ-019` exige **un** valor por fila al clasificar cada promesa del arnés —«¿esto lo cumple
una máquina?»—, pero **diez elementos son mixtos**: una sub-promesa que **sí** cumple una máquina dentro
de un bloque cuyo resto **no lo cumple nadie**. El campo **no tiene forma de decir «parcial»**, así que
quien clasifique elige entre dos respuestas y **las dos son falsas** para esos diez.

Es la familia que ya costó caro dos veces aquí: **un campo cuya forma no admite el estado real obliga a
escribir algo falso, y después alguien lee ese algo y decide.** `AGENTS.md` §13 tiene la versión buena de
la lección —el hook que **avisa sin decidir** ante un veredicto fuera de vocabulario—; aquí falta el
equivalente.

**Y con su condición de ascenso, para que no se quede en la cola para siempre:** si alguna de esas diez
filas se usa para **decidir** algo —un cierre, un reparto, una acreditación—, deja de ser deuda y sube de
clase.

**Actualizada también la medición de la sonda en `docs/PENDIENTES.md`:** eran **cuatro** corridas y son
**cinco** (`7dc0699`, PASS, 1,017×). **No cambia la conclusión y la refuerza:** el recorrido sigue siendo
0,973×–1,364× y sigue cubriendo el techo de 1,25×.

## [GitHub] — 2026-09-08 · Alcance y orden de 1.34.0: dos correcciones que la medición impuso, y un techo desmentido
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

**Primera corrección: son CUATRO trabajos, no tres.** La recomendación de recortar 1.34.0 a tres olvidó
un **plazo con dueño**: `SEC-047` es de severidad **crítica** y su vencimiento —el cierre de 1.34.0— está
escrito en `docs/seguridad/registro-seguridad.md:3684`, **por el auditor y en su sede**. Cerrar sin
`REQ-023` + `REQ-024` sube `SEC-047` y `SEC-051` a **`contrato`**. La diferencia con `SEC-052` —el
forzador que resultó ser «un argumento con la firma de otro»— es exactamente esa sede: aquél vivía sólo
en el REQ cuyo aplazamiento castigaba. **Un forzador en su sede no se negocia midiendo coste.**

**Segunda corrección: el orden.** El propietario prioriza bajar el coste. La sonda estaba primera porque
bloquea *publicar* — pero bloquea **al final**, y las palancas de tokens abaratan **todo lo de en medio**.
Es la regla del encabezado de `docs/PLAN.md` («lo que compone va primero») aplicada bien.

**El impuesto de arranque, medido y mayor de lo que se venía citando.** `AGENTS.md` 33.827 B +
`requirements/README.md` 40.020 B + `CLAUDE.md` 408 B = **74.255 B ≈ 18.500 tokens en CADA comisión**. Se
citaba ~9 k, que era sólo `AGENTS.md`. **El 72 % vive en seis secciones** ya identificadas por tamaño; la
mayor es «Cómo se escribe un criterio que no se desmiente» (12.609 B) y la quinta es el `## Índice`
(7.025 B), que es **una copia**.

### Y el hallazgo que para la ventana: **el techo de `REQ-019` es INALCANZABLE**

La enumeración F1 lo midió por **dos vías ciegas independientes** y las dos coinciden: el **suelo
forzado** —lo que no se puede quitar sin perder una invariante— es **≈0,70×** en `AGENTS.md` y **≈0,66×**
en el README, **≈0,68× total**, contra el **≤0,60×** que `CA-07` contrata. En bytes será **peor** que en
líneas, porque las dos poblaciones de líneas más largas —la tabla de §13 y el `## Índice`— son suelo al
**100 %**. Su línea base está además desfasada: declara el README en **433** líneas y tiene **522**.

**Renegociar ese techo es firma del propietario**, así que `REQ-019` **no se despacha** hasta que exista:
hacerlo sería pagar cuatro comisiones para chocar contra un número imposible. Y antes de repartir nada
hay que arreglar `D-3`, `D-5` y `D-9` — tres defectos en sus **propios** criterios.

**Consecuencia sobre el ahorro real, sin adornos:** con suelo 0,68×, `REQ-019` recorta como mucho
**~32 %** del impuesto (**≈5.900 tokens/comisión**), no los ~7.400 que sugería el techo escrito.

**Y la palanca mayor medida no es ninguna versión del plugin: es el ENCARGO.** Seis comisiones del
2026-09-08/09 con el mismo modelo: **229 k → 154 k → 107 k → 64 k → 46 k → 58 k**. Lo único que cambió
fue cerrar la lista de lectura. **Un factor 5, gratis y ya aplicado** — ninguna palanca contratada se le
acerca, y conviene tenerlo escrito antes de invertir cuatro comisiones en recortar un 32 %.

## [GitHub] — 2026-09-08 · **PUBLICADA `v1.33.0`** — fusionada con cuenta SIN admin, y con su límite declarado
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Decisión del propietario del 2026-09-08, que **revierte el aplazamiento acordado horas antes**. Merge
commit `810128a`; tag `v1.33.0` sobre él.

**Qué entrega.** `REQ-017` — la guarda del CR era **cuadrática** en la longitud de línea; ganancia
acreditada por `CA-05` el 2026-09-07: **0,125× — 9,60 s frente a 76,19 s** en la ruta crítica. Y
`REQ-014` — el banco pasa de un `run.sh` monolítico a **50 archivos de sección** con cuadre exacto por
archivo, con los inventarios de antes (45) y después (50) **idénticos byte a byte**: 56 casos cambiaron
de archivo y **ninguno** cambió de identidad ni de veredicto.

**Se fusionó con `jvega-habitat`, que NO tiene admin, y eso es parte del registro.** La puerta requerida
`hooks-en-linux` dio **875 PASS · 0 FAIL · 9 SKIP** sobre `7dc0699`, y la fusión pasó con una cuenta sin
privilegios de administración: queda demostrado **por construcción** que el control se satisfizo y no se
saltó. Usar la cuenta de dueño —autorizada por el propietario y disponible— habría dejado esa duda
abierta para siempre; por eso no se usó.

### El límite declarado, que es la condición bajo la que se publicó

**La evidencia de rendimiento de esta versión es el `0,125×` de `CA-05`, NO el verde de `CA-08 (ii)`.**
Ese caso tiene una dispersión **medida** de **0,973× a 1,364× sobre código idéntico** —cinco corridas,
dos rojas y tres verdes, incluida una que dice que el árbol nuevo es **más rápido**— contra un techo de
**1,25×**: vive **dentro de su propio ruido**, así que hoy no acredita nada en ninguna dirección, ni el
rojo ni el verde.

**Por qué eso no impide publicar, y dónde estaría el atajo si lo fuera.** La ganancia que 1.33.0 promete
**está medida por otro criterio y fechada**; lo que `CA-08 (ii)` no puede certificar es algo más
estrecho: que no haya regresión en ese camino concreto, comprobada **en cada PR**. Fusionar *porque el
semáforo se puso verde* habría sido elegir la corrida que conviene — el atajo que esta bitácora nombró
por escrito hace horas y que **no se tomó**. Se fusionó porque la sustancia está acreditada por otra vía
y el banco entero pasa; el verde de ese caso concreto se declara **irrelevante para la decisión**, en las
dos direcciones.

**Arreglar la sonda sigue siendo el primer trabajo de 1.34.0, por delante de `REQ-019`** — y ahora con
más motivo, no con menos: mientras el techo viva dentro del ruido, ese caso decide cada PR sin poder
distinguir. Las tres formas conformes y la medición completa están en `docs/PENDIENTES.md`.

**Pendiente inmediato:** actualizar la instalación estable del plugin a 1.33.0 y verificarla. Hasta que
eso ocurra, el bloque derivado de `docs/ESTADO.md` seguirá avisando de que la instalación corre 1.32.1
—**correcto, no es defecto**: esa instalación es la que gobierna esta sesión.

## [Interno] — 2026-09-08 · **CORRECCIÓN del diagnóstico de la sonda**: el umbral no está «mal puesto», y lo que falla es peor
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Las entradas anteriores de hoy concluyeron que el defecto de `REQ-017 CA-08 (ii)` era **estructural: que
el umbral de convergencia y el techo de regresión fueran el mismo número (1,250×)**. **Eso es falso**, y
se corrige aquí antes de que sea la base del primer trabajo de 1.34.0. Las cifras medidas no cambian; el
diagnóstico sí. *(No se reescriben las entradas anteriores: la corrección va fechada, que es la regla de
este proyecto.)*

**Son el mismo número a propósito, y `CA-08` lo argumenta por escrito:** *«no es un número nuevo: es el
mismo, porque **un instrumento tiene que resolver al menos el factor que vigila**»*. **El caso hace
exactamente lo que su criterio prescribe**, y su hermano también — no está mal configurado: excedió el
umbral y se abstuvo, que es lo previsto.

**Lo que las cuatro corridas muestran es peor.** `CA-08` **ya había pagado esta lección**: documenta que
en aislamiento la razón recorre **0,821–1,010**, que bajo `JOBS=6` sube de forma sistemática por
contención que el propio banco fabrica, y prescribe **intercalar las series** «a, b, a, b» para
cancelarla «por construcción», más la comprobación de convergencia. **Todo eso está implementado. Y no
basta:** la razón recorre **0,973–1,364**.

**Dónde está el hueco.** La convergencia compara el **segundo mínimo de cada árbol con su propio
mínimo** — mide si **cada serie** se asentó. Pero el ruido de la **razón** no procede de la dispersión
interna de cada brazo, sino de las condiciones **entre brazos**: dos series pueden converger cada una a
1,2× y su cociente oscilar 1,4×. La comprobación responde *«¿se asentó cada serie?»* cuando el criterio
necesita *«¿puede este cociente distinguir 1,25×?»*.

**Y los datos lo enseñan, que es lo que convierte esto en medición y no en teoría:**

| Convergencia (2.º mín / mín) | Razón | Veredicto |
|---|---:|---|
| 1,012× / 1,142× | 1,131× | PASS |
| 1,185× / 1,138× | 0,973× | PASS |
| 1,025× / **1,232×** | 1,337× | **FAIL** |
| 1,002× / **1,249×** | 1,364× | **FAIL** |

**Los dos rojos son justo aquellos en que un brazo converge al borde** —1,232× y 1,249× contra el límite
de 1,250×— mientras el otro converge holgado; los dos verdes tienen convergencias equilibradas. A 1,249×
el instrumento resuelve **exactamente** 1,25 y ni un poco mejor, y sobre esa resolución afirma un 1,364×.

**La clase, nombrada:** `CA-08` dice «**al menos** el factor que vigila» y eligió el valor **más flojo**
compatible con ese argumento **sin medir si alcanzaba**. Es **un criterio derivado sin comprobar su
factibilidad** — la misma clase que el techo de 400 líneas de `REQ-014 CA-18` y que el techo de 4× de
`REQ-021 CA-08 (iii)` re-derivado a 6×, las dos corregidas en esta misma ventana. El argumento era
correcto; **el valor no se comprobó**.

**Consecuencia para la decisión del propietario: NO cambia, la refuerza.** Si el defecto hubiera sido un
umbral mal puesto, sería una línea. Siendo que **el remedio prescrito ya está construido y es
insuficiente**, hace falta **medir** cuál de las tres formas conformes alcanza —convergencia
estrictamente más apretada, una cota sobre la dispersión de la **razón**, o sacar (ii) de la puerta
requerida dejándolo como acreditación fechada, la vía que `CA-05` ya usa—. Las tres quedan escritas en
`docs/PENDIENTES.md` con la nota de que **la 2 es la única que ataca la magnitud correcta**.

## [Interno] — 2026-09-08 · La puerta requerida está roja, y su rojo NO es evidencia: medido sobre código idéntico
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Entrada en `PENDING_APPROVAL.md`; el pipeline se detiene. `REQ-014` quedó `completado` con los tres
veredictos fechados y **cero hallazgos `contrato`**, así que lo único que separa a 1.33.0 del tag es el
check requerido y estricto `hooks-en-linux`.

**Falla `REQ-017 CA-08 (ii)`, y su salida afirma «esto es una regresión, no ruido».** Cuatro corridas
sobre **código idéntico** —ningún commit desde `b9afa01` toca `hooks/`, `tools/` ni `.github/`, verificado
por el `auditor-seguridad` en `R-019`— dicen lo contrario:

| Corrida | Razón | Convergencia | Veredicto |
|---|---:|---|---|
| 23:39 `921dc74` | **1,131×** | 1,012× / 1,142× | PASS |
| 23:53 `516e849` | **0,973×** | 1,185× / 1,138× | PASS |
| 00:00 `d4e0033` | **1,337×** | 1,025× / 1,232× | FAIL |
| 00:24 `eff143b` | **1,364×** | 1,002× / 1,249× | FAIL |

**`0,973×` significa que este árbol salió MÁS RÁPIDO que `v1.32.1`, y una regresión real no puede ser más
rápida.** La dispersión va de 0,97 a 1,36 —factor **1,40**— y el techo que vigila es **1,25**: el techo
vive **dentro** del ruido, así que el caso no distingue la regresión que dice medir de su propia varianza.

**El defecto es estructural: el umbral de convergencia y el techo de regresión son el mismo número
(1,250×).** Por eso la convergencia declaró «convergido» en las cuatro corridas —1,138, 1,142, 1,232 y
1,249, todas bajo 1,250— **incluidas las dos que fallaron**. Una comprobación cuyo umbral iguala al del
criterio que protege no filtra nada. Su caso hermano (`un REQ real de 6 líneas`) **sí** hace lo correcto:
no converge y **SKIP con motivo**. El mecanismo existe; el umbral está mal puesto.

Clase **`instrumento`**, y aun así **bloquea**: el ruleset hace ese check requerido y estricto. Es el
primer caso de la ventana en que un `instrumento` detiene una **publicación** — no un cierre de REQ, que
es lo que la regla de acumulación del propietario cubre.

**Y queda nombrado el atajo que NO se toma:** relanzar el CI hasta que salga verde. Con una sonda cuya
dispersión cubre el techo, eso no es esperar a que pase — es **elegir la corrida que da la respuesta que
se quiere**. Tampoco `continue-on-error` ni sacar el caso del CI: pondría la puerta en verde **apagando
la señal**, el modo de fallo que `AGENTS.md` §13 nombra y que `REQ-014 CA-18 (ii)` prohíbe por escrito.

## [Interno] — 2026-09-08 · **Decisión del propietario: se APLAZA el tag `v1.33.0`** y la sonda se arregla en 1.34.0, delante de `REQ-019`
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Opción **C** de la entrada de `PENDING_APPROVAL.md`, ahora resuelta. Descartadas **(A)** arreglar la sonda
dentro de esta ventana y **(B)** publicar con el rojo bajo autorización expresa. **No se ejerció (D)** —
relanzar el CI hasta obtener un verde y fusionar en esa corrida.

**El argumento, en una línea:** mientras el techo viva **dentro** del ruido de la sonda, **el verde de esa
puerta no acredita nada más que el rojo**. Publicar hoy no compraría confianza: compraría una firma vacía.

**Enmienda al alcance de 1.34.0** (`docs/PLAN.md`): su primer trabajo pasa a ser **la sonda de
`REQ-017 CA-08`**, por delante de `REQ-019`. El motivo de ponerla delante y no detrás es que **toda
publicación posterior se firmaría sobre una señal que no distingue**, así que arreglarla antes evita
repetir esta conversación en cada ventana. La medición completa —las cuatro corridas, la causa de una
línea y las dos formas conformes de remediarla— queda en `docs/PENDIENTES.md` para que 1.34.0 la **cite y
no la rehaga**: es la parte cara del análisis y ya está pagada.

**Estado al cerrar la ventana:** `cand/1.33.0` empujada y verificada, árbol limpio, PR **#43** en `DRAFT`
sin fusionar. `REQ-014` **`completado`** con `QA: aprobado` y `Seguridad: aprobado` fechados el
2026-09-08 y **cero hallazgos `contrato`**. Cola de aprobaciones en **0**. Bloqueantes `contrato` en el
repositorio: **12** — `REQ-013` (2), `REQ-019` (1), `REQ-020` (8), `REQ-023` (1).

## [GitHub] — 2026-09-08 · **`REQ-014` COMPLETADO**, y las cifras que la partición desfasó, corregidas antes de cerrar
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` (Opus) + coordinadora.

`Estado: completado`. La transición la **aceptó `guard-completado`**, que es la confirmación por máquina
de lo verificado a mano: `QA: aprobado` y `Seguridad: aprobado` fechados hoy, **11 hallazgos abiertos y
cero de clase `contrato`**, cola de aprobaciones en 0 y quality gates en verde.

### Por qué hubo dos comisiones más antes de cerrar, y por qué no son un círculo

`b9afa01` llevó el árbol de **45 a 50** archivos de sección. En ese instante **toda cifra del REQ que
contara archivos o pisos quedó desfasada** — no son hallazgos que aparecen uno tras otro, es **un solo
evento con varias sedes en el texto**. Se buscaron **todas de golpe** y se verificaron **contra el
árbol**, no contra el texto: 50 secciones · 2 gobernadas por `piso × k` (pisos **470** y **463**) · 48 por
`N` · **ninguna** por encima de su techo.

Cerrar `REQ-014` —cuya reapertura existía **precisamente** para re-derivar `CA-18`— con `CA-18` citando
cifras anteriores a la partición habría sido cerrar sobre la clase de defecto que lo reabrió. Y su propio
criterio lo obliga: *«`k` se re-deriva **en la misma edición** que cambia ese término»*.

- **`k` re-derivado sobre lo construido:** el mayor cociente pasa de `565/461 = 1,2256` (partición
  **prevista**) a **`577/470 = 1,2277`** (árbol **construido**) ⇒ **`k` sigue en 1,25**. Dos caminos
  independientes dan el mismo número: la re-derivación del auditor en `R-019` y la medición de la
  coordinadora leyendo las 50 declaraciones `PISO_AUTONOMO_SECCION`.
- **El bullet de `N`:** «43 de 45» → **48 de 50**, con los pisos **470**/**463**. La frontera derivada
  —`piso × k > N ⇔ piso ≥ 321`— **no se mueve**, y ahora está marcada como lo que no cambia.
- **El «Forzador medido»:** su frase en presente pasa a llevar fecha y a decir **«ANTES de la
  partición»**, con las cifras históricas intactas; el «después» va en un bullet nuevo con su commit.
  **La historia no se reescribe: se fecha.**

**Y el analista se negó a fabricar una cifra, que es el detalle que más vale de estas dos comisiones.**
El argumento de `max(…)` decía «~42 archivos **hoy** conformes saldrían rojos». Esa magnitud **no es** la
misma que «gobernados por `N`» (48), así que las cifras verificadas que se le entregaron **no la
cubrían**: la fechó sobre el árbol de 45 y escribió que **no se ha rehecho**, en vez de poner un 48 que
habría parecido correcto y habría sido inventado.

### La curva del día, mismo modelo en todas

| Comisión | Tokens | Reloj |
|---|---:|---:|
| `qa-tester`, validación completa | **229 k** | 28,4 min |
| `analista`, write-back | **154 k** | 11,5 min |
| `auditor-seguridad`, `R-019` | **107 k** | 13,3 min |
| `qa-tester`, confirmación | **64 k** | 4,4 min |
| `analista`, re-derivación de `k` | **46 k** | 1,5 min |
| `analista`, las dos sedes restantes | **58 k** | 2,8 min |

**No cambió el modelo ni el agente: cambió el encargo.** Rangos de línea en vez de archivos, cifras
entregadas ya medidas, y prohibiciones explícitas —«no corras el banco» tras comprobar con un solo
`git diff --stat` que nada medible había cambiado; «no leas los 458 KB del registro de seguridad, tienes
`grep`»—. Es la primera ventana con el modo austero aplicado, y queda medida para poder desmentirla.

## [GitHub] — 2026-09-08 · `R-019` firma REQ-014, resuelve la doble numeración y halla dos rojos que no son de REQ-014
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `auditor-seguridad` (Opus).

**`Seguridad: aprobado (2026-09-08, R-019, cand/1.33.0 @ d4e0033)`.** Con esto `REQ-014` queda en **11
hallazgos abiertos, CERO de clase `contrato`**, cola de aprobaciones en 0 y quality gates en verde.

**Qué acredita la firma, dicho por el auditor:** la re-derivación de `CA-18` hecha **por él** sobre los 50
archivos; que la conformidad **no se compró inflando ningún piso**; que `CA-19` se cumple en las dos
mitades; que el mecanismo no cambió. **Qué NO acredita:** quality gates ni ejecución del banco — son de
QA, y las cita en vez de re-medirlas.

**La doble numeración, resuelta.** Su revisión pasa a **`R-019`** (`registro-seguridad.md:5492`) y sus
hallazgos se corren: `SEC-057→058`, `058→059`, `059→060`. Y una decisión que evita el defecto que la
comisión venía a cerrar: **el `SEC-060` del worktree NO recibió número nuevo** porque *es* el `SEC-057`
que ya existía — «dos ids para un hallazgo son la misma ambigüedad».

**`SEC-059` (ex-`SEC-058`, `contrato`) → `mitigado`, verificado contra el árbol y no contra el texto.**
`9809fc2:…/38-sondas-compartidas.sh:18` declara `19 + 36 + 78`, luego 55 por archivo extra y ≥442. Y el
árbol real lo confirma **por el otro lado**: los tres archivos suman 198+327+351 = 876, máximo **351 <
400**; el crecimiento real fue de 48 líneas, con lo que dos mitades habrían dado **438 > 400** — tampoco
cabían. La predicción era conservadora y la conclusión aguanta por las dos vías.

### Los dos hallazgos nuevos, los dos `instrumento`

**`SEC-062` (media) — `CA-22 (i)` sale ROJA sobre un árbol correcto.** `REQ-014.md:122` exige
`git diff v1.31.0 -- hooks/` **vacío**; da **5 archivos, +489 líneas**, y **ninguna es de REQ-014**:
vienen de `973448f` (REQ-015) y `ed56f9a` (REQ-017). La **sustancia** se cumple —verificada por la vía
correcta—, falla la **forma**. Lo que lo sube a media: la mitad (ii) **ya recibió esta misma corrección
por `H-09`**, se arregló `tools/` y se dejó intacta la de `hooks/`, que el propio criterio llama «lo que
este control de verdad protege». Es la clase de rojo que enseña a desactivar el control (`H-11`).

**`SEC-063` (baja)** — `.gitignore` no cubre `.env*`. Exposición actual **nula**; se registra por ser
repositorio público.

### Corrección del auditor a su propia `R-018`

Afirmó que `.arnes/config.json` no cambiaba. **Falso sobre este árbol:** cambió en `d01aea1`. Leyó el
hunk entero — **una línea**, `arnes_version` 1.32.1 → 1.33.0, ninguna clave de política tocada.
`hooks/`, `tools/` y `.github/`: **cero** archivos desde `9809fc2`.

**Y midió a fondo la vía por la que la partición podía haber roto el aislamiento:** los tres `38-*` leen
`$RAIZ/cal-*` y `testigo-*`, pero **los produce el corredor** (`run.sh:1138-1141`) y ninguna sección los
escribe — dependencia del corredor hacia abajo, la única que `CA-19` admite. **No hay violación.** Anotó
sin convertirlo en hallazgo que la partición duplicó `her37-321-$BASHPID` entre dos secciones paralelas y
que **sólo el sufijo por proceso impide la colisión** (clase REQ-015).

**Coste: ≈107 k tokens, 35 llamadas, 13,3 min**, con el registro de 458 KB consultado **sólo** por
`grep -n` y `sed -n` de rangos, nunca entero. Es la instrucción que hoy costó $3,26 en una sesión de
Codex por no estar escrita.

## [GitHub] — 2026-09-08 · QA confirma el write-back: `H-13` CERRADO, y el cierre pasa a depender sólo del auditor
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

`QA: aprobado (2026-09-08)`. `H-13` retirado de `Hallazgos abiertos:`, que queda en **11 entradas** con
**2 bloqueantes**, los dos del auditor: `SEC-058` y `SEC-060`.

**Las cuatro comprobaciones, y la que importaba.** La segunda —«el acotamiento no abre una fuga»— es la
que decidía si el write-back cerraba el hallazgo o lo convertía en permiso. Cumple en **dos** sedes
(`REQ-014.md:52` y `:66`): cualquier **otra** línea que difiera es FALLO, y una línea nueva que oscile
**no se acota sola** — se declara con nombre, tasa y dueño, o el criterio falla. **El descuento es de una
línea nombrada, no de una categoría.**

**Riesgo residual que QA anotó y no estaba pedido:** descontar una línea nombrada de ambos lados
ocultaría también su **desaparición**. No abre fuga hoy porque `CA-13` y el cuerpo de `CA-12` no llevan
descuento — y el residual es exactamente que **el descuento no se extienda nunca a ellos**.

**Coste: ≈64 k tokens, 25 llamadas, 4,4 min.** La curva del día con el mismo modelo y agentes de la misma
familia: **229 k → 154 k → 64 k**. Lo que cambió no fue el modelo: fue el encargo. A esta comisión se le
dieron **cinco tramos de líneas** de un archivo de 546, su propio log por rango, y una instrucción
explícita de **no correr el banco** —tras verificar con un solo `git diff --stat` que `tests/`, `hooks/`,
`tools/` y `.github/` no habían cambiado desde su medición de la mañana—. Ahí estaban los 28 minutos de
la primera comisión.

**Colisión de numeración medida por la coordinadora, para el auditor.** El registro principal ya tiene
`R-018` **y** `SEC-057` (`:5437`, `instrumento`, dueño `desarrollador` + propietario). La revisión
archivada en `work/req014-codex` numeró **otra** `R-018` y **otro** `SEC-057` (`:5383`, `instrumento`,
severidad alta, «el techo de CA-18 lo decide el sujeto»), más `SEC-058`…`SEC-061`. Consecuencia en el
contrato: `REQ-014` declara hoy `SEC-057 (instrumento)` y **la línea no distingue cuál de los dos es** —
la puerta lee la clase y pasa; un humano no puede saberlo. Renumerar es acto del `auditor-seguridad`.

## [GitHub] — 2026-09-08 · Write-back de REQ-014: `H-13` reflejado, tres ADR enlazados y CUATRO textos del cuerpo que eran falsos
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

- **`H-13`.** `CA-14` declara ahora **`REQ-017 CA-09 la pared de los 60 s`** por su nombre como inestable
  **en su veredicto**, con la medición de QA, su dueño `SEC-030`, y la conclusión que sostiene el
  acotamiento: **oscila antes de la partición, con tasa igual o mayor ⇒ la partición no lo empeora.** Los
  positivos de `CA-14` y `CA-12 (d)` quedan enunciados **módulo esa línea declarada**, con cláusula
  anti-fuga: cualquier otra diferencia es FALLO, y **una línea nueva que oscile no se acota sola**.
- **`SEC-058`.** `CA-18 (ii)`: **≈424 → ≈442**, con su derivación (`19 + 36 = 55` de duplicación por
  archivo extra) y la frase de que **la conclusión no dependía de la cifra** — `442 > 424 > 400`, sigue
  sin caber en dos y salieron tres.
- **`CA-31 (d)`.** `ADR-002` (H-03), `ADR-006` (CA-18) y `ADR-007` (CA-12/CA-14) enlazados desde las
  **siete** filas que los causaron. Y el criterio se reescribe **por relación** en vez de por recuento
  —«todo ADR que el Historial declare como causa, enlazado desde la fila que lo causó»— porque «dos
  pendientes» pasó a «tres enlazados» **el mismo día**: un criterio que cuenta envejece en horas.
- **Cuatro textos del cuerpo que eran falsos**, no tres. El cuarto lo halló el analista: **`CA-18 (iii)`**
  fechaba su negativo sobre un árbol de 45 secciones con «105 PASS · 1 FAIL» y daba **el positivo real
  por pendiente** — cuando ya estaba acreditado sobre el árbol real en sus dos ramas (106 PASS · 0 FAIL,
  las seis mutaciones de QA). Y entre los otros tres, **el bloque «ADR PENDIENTE … bloquea el cierre»
  afirmaba un bloqueo que no existía desde hacía dos días** (`ADR-002` es del 2026-09-06).
- **`Hallazgos abiertos:`** pasa a **12 entradas, todas con clase**, verificado parseando la línea como lo
  hace la puerta. Tres `contrato`: `H-13`, `SEC-058`, `SEC-060`.

**Lo que el analista NO hizo, y lo dijo:** el cuerpo afirmaba «REQ-021, que está `bloqueado`»; **retiró la
afirmación en vez de sustituirla**, porque no podía verificarla sin leer un REQ fuera de su lista de
lectura. *(Confirmado después por la coordinadora: `REQ-021` **sí** está `bloqueado`. El dato se puede
reponer; retirar en vez de adivinar fue la conducta correcta.)*

**Coste: ≈154 k tokens, 54 llamadas, 11,5 min** — frente a los **229 k / 95 / 28,4 min** de la comisión de
QA de esta misma mañana. La diferencia no es el modelo ni el agente: es que este encargo llevaba **lista
de lectura cerrada con rangos de línea**. Primera medición del modo austero.

**Peaje de `SEC-060`, y ya no es anécdota: dos agentes hoy.** QA y el analista recibieron un `deny` de
`guard-completado` sobre ediciones cuyo texto **nuevo** contenía el literal `Seguridad:`. La causa de
fondo es que la cabecera está en estado contradictorio —`Seguridad: aprobado` sin fecha, del 2026-09-06 y
declarado nulo por el propio Historial, sobre `QA: con-hallazgos`—, así que la puerta se planta, y con
razón. Cada `deny` cuesta un reintento. Es `instrumento` y **acumula** (regla del propietario), pero se
registra con sus dos ocurrencias porque una clase con dos casos el mismo día ya no se descarta por rara.

## [GitHub] — 2026-09-08 · Las dos banderas que ahorran contexto: decididas, medidas y APLAZADAS con su motivo
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

El propietario delegó la decisión («decide tú»). **Las dos sí; ninguna hoy.** Y el motivo del aplazamiento
lo dio una medición que corrigió la decisión antes de tomarla: **`.arnes/config.json` está dentro de
`codigo_app.globs`**, así que no es «encender un flag» — es cambio de mecanismo con REQ y ciclo de cuatro
agentes. Encenderlas dentro de la ventana 1.33.0 sería el atajo que `AGENTS.md` §5 prohíbe por nombre; y
la rotación reescribe sus artefactos **en cada parada de agente**, incluidas las dos comisiones que deben
cerrar esta ventana.

**Lo que sí se hace hoy es dejar medido lo caro**, para que el REQ que las aplique no lo vuelva a derivar
(`docs/PENDIENTES.md`):

- **El peso real del contexto.** `CHANGELOG.md` 467 KB · `registro-seguridad.md` 458 KB ·
  `docs/qa/1.33.0.md` 226 KB · `REQ-014.md` 128 KB · `AGENTS.md` 34 KB · **`requirements/` entero
  1 759 KB**. Un auditor que lee el registro entero carga ~120 k tokens que paga **en cada turno
  posterior**: 20 turnos × 120 k = **2,4 M**. Una comisión de auditoría medida hoy en una sesión de Codex
  consumió **2,56 M de lectura de caché**. **El número reproduce**, y la causa no era el nivel de
  esfuerzo: era un archivo de 458 KB dentro de la ventana.
- **Los dos artefactos crecen en direcciones OPUESTAS**, y ésa es la parte que se paga por averiguar:
  `CHANGELOG.md` es `nuevo-primero` (entrada más nueva en la línea 5) y `registro-seguridad.md` es
  `nuevo-al-final` (`R-001` en la 14, `R-018` en la 5311). La clave `orden` global **archivaría lo más
  reciente del registro**. Es el modo de fallo que `arnes-upgrade` documenta para 1.26.0.
- **Encender `veredictos.*` no bloquea ningún cierre pendiente.** De **25** veredictos `aprobado` en
  cabecera, **20 llevan fecha y 5 no** (`REQ-001` ×2, `REQ-012` ×2, `REQ-014` ×1). Los cuatro primeros
  están en REQ `completado` que no vuelven a transicionar —sólo mordería al reabrirlos, que es cuando
  debe morder— y el quinto es el `Seguridad: aprobado` sin fecha que **el propio Historial de `REQ-014`
  declara nulo**.

**Y una regla de redacción, decidida hoy y con causa medida.** `docs/qa/1.33.0.md` pesaba 0 KB hace tres
días y hoy pesa 226 KB: lo que un agente escribe hoy es contexto que otro paga **en cada turno de
mañana**. El reparto: **el contrato va íntegro** —qué se midió, contra qué, veredicto y clase—, **la
evidencia va citada** (`archivo:línea`), nunca transcrita. La prueba para decidir el lado: *¿se puede
desmentir sin abrir otro archivo?* La recomendación venía de Codex apuntando al gasto de **salida**; los
números la desmienten en su razón (109,5 k de salida sobre 5,5 M, el **2 %**) y la refuerzan en la
contraria: el coste no es escribirlo, es **releerlo para siempre**.

## [GitHub] — 2026-09-08 · QA de REQ-014 reabierto: los dos `contrato` del desarrollador CERRADOS, y un `contrato` nuevo que es un párrafo
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

Veredicto **`QA: con-hallazgos`**, vuelta **0 de 3** consumida. El código de `b9afa01` no vuelve al
desarrollador: lo que bloquea es texto del REQ.

- **`DEV-014-01` cerrado.** Seis mutaciones sobre **copias del árbol real** —no sobre las secciones
  sintéticas, que era lo único acreditado—: exceso por `N`, exceso por `piso×k`, derivación ilegible,
  declaración ausente, términos que no suman, `piso > líneas`. Las seis fallan nombrando lo que deben.
  Con esto el par discriminante **(iii)** de CA-18 queda acreditado sobre el árbol real **en sus dos
  ramas**, que es lo que el criterio dejaba pendiente por escrito.
- **`DEV-014-02` cerrado.** Forzador medido cerrado (74.046 vs 74.047 bytes; 20-25 líneas de MEDIDA
  volátiles), con los tres negativos reproducidos sobre salida real del banco.
- **CA-12 limpio.** Inventario de **antes** de la partición (`9809fc2`, 45 secciones) e inventario de
  **después** (`b9afa01`, 50): **idénticos byte a byte** — 884 líneas, 73.508 bytes, `diff` vacío. **56
  casos cambiaron de archivo y ninguno cambió de identidad ni de veredicto.**
- **CA-20 sin regresión:** mediana 48,63 s → 48,94 s (**+0,6 %**, techo 20 %).

**Hallazgos nuevos.** **`H-13` (`contrato`)** — CA-14 FALLA: `REQ-017 CA-09 la pared de los 60 s` es
inestable **en su veredicto** (PASS↔SKIP) y el REQ no lo declara; al contrario, lo nombra entre las
líneas cuya volatilidad *era de medida*. La atribución a `SEC-030` se sostiene y **mejor de lo que él
podía demostrar**: sus 4 corridas limpias no acreditaban nada (con tasa 1/9, ver 4 limpias tiene
probabilidad 0,62), así que QA lo rehízo **6 y 6, en serie, misma máquina** — `9809fc2` da 3 PASS/3 SKIP
y `b9afa01` da 4 PASS/2 SKIP. **Oscila antes de la partición, con tasa igual o mayor.** Su remedio es
declarar el caso por su nombre y enunciar el positivo **módulo esa línea declarada**.
`H-14`/`H-15`/`H-16` (`instrumento`): piso sobredeclarado en `37-…-4` (463 vs 389, y no compra el
techo), término de preámbulo **autofinanciado** en CA-18, y una cota con decimal en el **nombre** de un
caso que el oráculo normaliza a `N`.

**Los pisos, término a término.** Los ocho suman y sus rangos son ciertos; los seis gobernados por `N`
no compran nada. De los dos gobernados por `piso×k`, `37-…-1` **no compra el techo** (461 → 577, y el
archivo mide 577) y `37-…-4` **sí está sobredeclarado en 74** — pero tampoco compra (con 389 el techo
sale 487 y el archivo mide 468).

**El árbol se movió durante la comisión** (`b9afa01` → `d01aea1`) y QA lo comprobó antes de firmar:
`git diff b9afa01 d01aea1 -- tests/ hooks/ tools/ .github/` está **vacío**. Todas las mediciones son del
árbol que dicen ser.

**Nota de enforcement, registrada por QA:** su primer intento de escribir el veredicto **agrupó las tres
líneas de cabecera** y `guard-completado` lo **denegó correctamente** (`Seguridad: aprobado` conviviendo
con `QA: con-hallazgos`); separando ediciones pasó. Es exactamente el alcance que el hook declara.

## [GitHub] — 2026-09-08 · Versión 1.32.1 → **1.33.0** en los cuatro sitios, y las menciones que NO se tocan
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

`.claude-plugin/plugin.json` `.version`; `.claude-plugin/marketplace.json` en sus **dos** campos
(`.metadata.version` y `.plugins[0].version`); `.arnes/config.json` `.arnes_version`. Las tres
comprobaciones `jq` en verde, más `bash -n` sobre `hooks/*.sh` y `tools/*.sh`. `source: "./"` intacto.

**Es `minor` y no `patch`** porque la ventana entrega comportamiento que los consumidores heredan:
`REQ-017` retira una puerta **no determinista** del mecanismo, y el banco pasa de 45 a **50** secciones.

### La comprobación que valió la comisión: 370 menciones de `1.32.1`, y algunas son FUNCIONALES

De 51 archivos con menciones, la mayoría son históricas —describen lo que pasó— pero **hay un grupo que
es código ejecutable y aun así debe seguir diciendo `1.32.1`**:

> `tests/escenarios/hooks/secciones/37-coste-del-escaner-{1..5}.sh` usan `v1.32.1` como **tag de línea
> base** (`git show v1.32.1:<f>`). Es el árbol «antes» contra el que `REQ-017` mide: **subirlo haría que
> el criterio se comparase consigo mismo, y `CA-05`, `CA-08` y `CA-09` pasarían por tautología.**

Un `sed` global sobre la versión habría convertido tres criterios en verdades vacías **sin romper ni una
prueba** — exactamente la clase que esta ventana lleva todo el día cazando, encontrada esta vez **antes**
de cometerla. El desarrollador lo enumeró archivo por archivo en vez de sustituir a ciegas.

### Aviso esperado en el bloque derivado

`docs/ESTADO.md` dice ahora *«plugin instalado 1.32.1 · el proyecto declara 1.33.0 — migración
pendiente»*. **No es un defecto:** es el estado real del autoalojamiento — la instalación estable sigue
en 1.32.1 y **es la que gobierna esta sesión**. El aviso se apaga solo cuando se publique y se actualice
la instalación.

## [GitHub] — 2026-09-08 · Gráficos de cierres contratados en `REQ-008`; y la enumeración B encontró tres defectos en los criterios del propio `REQ-019`
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` ×2 (REQ-008 y F1-B).

### `REQ-008` — 21 criterios nuevos (`CA-60`…`CA-80`) para el encargo del propietario

*«Gráficos de cuántos cierres por día, mes o semana. Que todo sea interactivo.»* Queda **contratado y en
cola**: el REQ dice explícitamente que **no autoriza abrir comisión de desarrollo** y que `REQ-019` es el
primer y único trabajo de 1.34.0.

**Dos decisiones que el analista tomó en vez de dejarlas abiertas:**

**La fecha de cierre sale de la historia de git, y se etiqueta `derivado`, nunca `medido`** — el commit
más antiguo del tramo final en que la cabecera ya declara el estado terminal, en UTC. Descartado el
paréntesis del veredicto: con `veredictos.exigir_fecha` en `false` es opcional, y **la serie dependería
de una convención cuyas ausencias caen del lado que abre**. Efecto lateral útil: desacopla `REQ-008` de
`SEC-057`. Lo irrecuperable —git caído, clon superficial, historia reescrita— se publica como «sin
fecha» **con cuenta, denominador y motivo**, nunca se omite el punto.

**CDN: no**, y no por preferencia — `CA-38` **ya contrataba** cero recursos externos y «con la red
desconectada se ve idéntico». Lo que eso acota, dicho por su nombre: barras en **SVG en línea**,
generables con `awk` y verificables con texto; fuera zoom continuo y animaciones, que no responden
«cuántos cierres».

Y el par discriminante (`CA-72`) con `esperado.txt` escrito **antes** de correr nada: semanas en domingo
rompen dos construcciones, año de calendario rompe otra. Más `CA-73`, que exige que **la geometría
concuerde con el número** — lo único del informe que se lee sin leer una cifra.

### `REQ-019` F1 — las dos enumeraciones ciegas, y la diferencia ES el resultado

**A encontró 106 invariantes; B encontró 164.** Ninguna era completa, que es exactamente por lo que
`CA-15.2` exige dos. Las dos coinciden en el titular: **el suelo forzado excede el techo en los DOS
documentos** (0,63-0,70× contra `≤0,60×`), no sólo en el README como el REQ predecía; y las dos midieron
que **su línea base está desfasada** (declara 433 líneas de README; hay 522).

**Y B encontró tres defectos en los criterios de `REQ-019` mismo:**

- **`D-3`** — `CA-02.4.1` contrata las anclas citadas por el mecanismo **sólo para el README**. Pero **§1
  de `AGENTS.md` se cita en 11 mensajes de denegación**, y §5/§6/§7/§9 en otros nueve. §1 es el caso
  peor: **la sección más citada de todo el mecanismo y la que más parece un lema**.
- **`D-5`** — un marcador de `arnes-upgrade` **ya no resuelve**: busca `(preventiva)` con paréntesis y el
  texto vigente dice `Seguridad: preventiva`. **Cero apariciones, no puede dispararse nunca.** Es la
  demostración medida de que un marcador se muere sin que nadie lo note.
- **`D-9`** — `CA-02.2` manda conservar «la primera frase» de cada bloque `🔒`, y en **4 de los 7** esa
  frase es un **rótulo** («Cumplido por máquina:»). Aplicado literalmente, **conserva el rótulo y delega
  la obligación**.

Todo archivado en `docs/PENDIENTES.md` bajo la regla de acumulación. **`REQ-019` no está listo para
repartir**, y ahora se sabe **antes** de gastar 8-13 h — que es la lección de `CA-18` aplicada a tiempo.

## [GitHub] — 2026-09-08 · Regla de acumulación del propietario, y las 11 discrepancias de `REQ-019` F1 archivadas sin resolver
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` (F1, enumeración ciega A) y coordinadora.

**Regla del propietario, 2026-09-08:** *«las mejoras se acumulan, no las resolvemos de inmediato; los
errores críticos sí»*. Escrita en `docs/PENDIENTES.md` con la distinción que la hace utilizable: un
hallazgo de tipo «el documento describe mal lo que el código hace» **no es crítico si el error va en la
dirección segura** —el papel promete **menos** de lo que la máquina cumple—; **sí lo es si va al revés**,
porque alguien usará esa protección creyendo que existe.

### `REQ-019` F1 — enumeración ciega A: 106 invariantes, 11 discrepancias, **ninguna crítica**

66 elementos en `AGENTS.md` y 40 en `requirements/README.md`, con el **ejecutor resuelto por búsqueda
literal sobre el mecanismo** y nunca por la decoración. Reparto medido: **61 resueltos**, 14 parciales,
**28 `ninguna máquina`**, 3 `no resuelto`.

Las 11 quedan archivadas con el motivo de por qué esperan. La de mayor prioridad del lote es **`D-04`**:
`AGENTS.md` promete que el hook `pre-commit` exige el CHANGELOG, el hook existe y funciona, pero
**`.githooks/` no está en `codigo_app.globs`** — cualquier agente podría editarlo sin que `guard-codigo`
lo viera. No es crítica porque es gobernanza interna, no una puerta que proteja a un consumidor, y una
edición ahí **aparece en el diff**.

### El dato que cambia la planificación de `REQ-019`

**El suelo forzado excede el techo que el propio REQ contrata.** `AGENTS.md` **≈0,70×**, README
**≈0,66×**, total **≈0,68×** — contra el `≤0,60×` de `CA-07`. Y la predicción del REQ esperaba el
problema **sólo en el README**; con `AGENTS.md` no había ni estimación. En bytes será **peor** que en
líneas, porque las dos poblaciones de líneas más largas —la tabla de §13 y el `## Índice`— son suelo al
100%. La línea base del REQ además está **desfasada**: declara el README en 433 líneas y tiene **522**.

Consecuencia práctica: `REQ-019` **no ahorraría el ~40% que promete**; ahorraría ~32%, y sólo
renegociando su propio techo, que es firma del propietario. Es exactamente el paso —comprobar la
factibilidad **antes** de construir— que faltó en `CA-18` y costó la reapertura de `REQ-014`.

## [GitHub] — 2026-09-08 · `ADR-006` y `ADR-007`; y el segundo ADR «pendiente» llevaba dos días escrito
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `desarrollador` (ADR) y coordinadora (decisión de alcance).

**`ADR-006` — el techo sobre el excedente, no sobre el total.** Captura la re-derivación de `CA-18` con
lo que el REQ no conserva: el defecto de origen (`400` fijado **sin comprobar factibilidad**), por qué el
piso es **estructural** (`CA-04` + `CA-19` + `H-04` se multiplican y no dejan tercera vía), por qué **no**
se compró el techo con una cifra nueva, y por qué `max(…)` y no sólo la razón —comprobado **antes**: con
sólo `piso×k`, ~42 archivos hoy conformes saldrían rojos—. El **límite honesto** va como sección propia,
con la cita del código (*«un piso INFLADO afloja el techo sin que ninguna puerta grite»*) **y su
validación el mismo día**: al partir `37/1`, piso honesto **295** contra los **345** necesarios, mayor
bloque indivisible real **146** contra ≥196 — se partió en tres en vez de declarar el número que
cuadraba.

**`ADR-007` — medida frente a identidad.** El oráculo de `CA-12` (b)(c)(d) y su arrastre sobre `CA-14`.
Incluye el remedio literal de `CA-14` que **era peor que el defecto** —habría ordenado borrar 20 líneas
de medición que REQ-017 y REQ-021 existen para publicar— y la dirección del error declarada: ante la
duda, **rojo**.

### El hallazgo que no estaba en el encargo

Se le pidieron **dos** ADR: la re-derivación de `CA-18` y «el de H-03». El segundo **ya existía**:
**`ADR-002`, del 2026-09-06, `aceptada`**, y su decisión es literalmente la de la fila del Historial.
En sus palabras: *«no es un ADR parecido: es **ese** ADR. Lo que faltaba no era escribirlo, era
enlazarlo. Escribir uno nuevo habría sido el ADR de relleno, y además ilegal aquí — un ADR no se
reescribe.»*

Consecuencia: **tres textos de `REQ-014` quedan desmentidos** —«son ya **dos** ADR pendientes», «esta
comisión no puede escribirlo: queda pendiente y **bloquea el cierre**», y el recuento literal de
`CA-31 (d)`—. El REQ afirmaba un bloqueo que llevaba dos días sin existir. El enlazado de las **nueve**
filas del Historial queda enrutado al analista, **después** de que QA suelte el archivo.

### Y la decisión de alcance del propietario, registrada

**La auto-auditoría se congela:** un hallazgo de clase `instrumento` sobre los textos o instrumentos del
propio arnés **se registra igual**, pero **no abre REQ nuevo ni entra en la ventana en curso** — se
acumula en un backlog revisado una vez por ventana. **No toca** `contrato` ni `usuario/dinero`, que
siguen bloqueando. Motivo medido: en un día, **9 hallazgos abiertos contra 1 REQ cerrado**, y la última
versión publicada llevaba **más de un día**. Con la corrección de la coordinadora sobre su propia
recomendación escrita en la misma entrada: dijo «7 de 9 son `instrumento`» y son **4 de 9**, así que la
regla frena **menos de la mitad** de lo que se abrió hoy.

## [GitHub] — 2026-09-08 · `CA-18` en VERDE: los tres archivos partidos en ocho, y el piso que se midió en vez de declararse dijo que no cabían en dos
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

**La autoprueba pasa de `105 PASS · 1 FAIL` (rc 1) a `106 PASS · 0 FAIL` (rc 0)** — verificado
independientemente por la coordinadora corriéndola, no aceptado de palabra. Es el rojo que bloqueaba la
fusión desde el delta final de REQ-017.

### La advertencia del auditor se confirmó midiendo, y cambió el resultado

El auditor había avisado —antes de que nadie cortara nada— que partir `37/1` en dos dejaría la mitad-B
en ≈434 líneas contra un techo que sólo la conforma con un bloque indivisible de ≈199, y que **ese
número no existía medido en ninguna parte**. El desarrollador lo midió **antes** de cortar:

| Mitad | Líneas | `piso` honesto | Techo | ¿Cabe? |
|---|---|---|---|---|
| A (CA-01 + CA-10) | 570 | 24 + 122 + **312** = 458 | 573 | sí |
| B (CA-03/04/06/09) | 431 | 27 + 122 + **146** = **295** | `max(400, 369)` = 400 | **NO** |

Para que B cupiera haría falta `piso_B ≥ 345`, o sea un bloque indivisible de ≥196 líneas. **El mayor
bloque indivisible real de B mide 146.** No existe. Declarar 345 habría sido exactamente el techo
comprado deformando el sujeto que `CA-18` llama regresión a `contrato` — y las comprobaciones (a)(b)(c)
lo habrían dado por bueno, porque los términos suman.

Así que `37/1` fue a **tres** partes, que es lo que `CA-18 (ii)` reescrito hoy permite. Las cifras del
auditor y las del desarrollador difieren un poco (A=564 vs 570, B≈434 vs 431, umbral 348 vs 345) —
**misma conclusión, y ninguno de los dos alcanzaba**. `37/2` sí cabía en dos, verificado con medición
propia y no con la ajena.

### Ocho archivos nuevos, tres retirados, 50 secciones

`37/1` → dominio · razones · pared · ruta crítica · camino normal (los dos últimos salen de `37/2`).
`38` → registro · calibración · descendencia. **Casos repartidos, no creados ni perdidos:** 6+5+2+4+7 =
**24** (= 13+11 de los originales) y 7+13+12 = **32**; `CASOS_ESPERADOS=884` sin tocar. **48 de 50**
archivos gobernados por `N`, 2 por `piso×k`.

**Independencia verificada por dos vías, no afirmada:** un detector de nombres usados y no definidos,
**calibrado contra los tres originales como control** —su único positivo, `_v37`, es un falso positivo
del propio detector (`read -r _k37 _v37`) y **aparece igual en el original**—; y cobertura de líneas,
con extracción mecánica por rango en vez de transcripción.

### El inventario, y el único caso que difirió

**8 de 9 corridas byte a byte idénticas** a las de antes (884 líneas, 73.508 bytes): cero suprimidas,
cero modificadas, cero añadidas. La novena difirió en **una** línea —`REQ-017 CA-09 la pared de los
60 s`, PASS→SKIP—, que es el no determinismo **preexistente con dueño (`SEC-030`)** que REQ-021 ya había
medido en 9 PASS / 2 SKIP sobre el árbol anterior. El desarrollador lo acreditó con un `git worktree`
sobre HEAD: 4 corridas del árbol sin partir, 4 PASS; después, 8 PASS + 1 SKIP en 9. **La partición no lo
introduce ni lo empeora**, y lo dijo en vez de callarlo.

**Sin regresión de reloj (`CA-20`):** mediana 39,8 s antes → **39,7 s** después.

### Uso de consola declarado, con su motivo — `AGENTS.md` §13

El desarrollador ensambló los ocho archivos por **extracción mecánica de rangos con `sed`** en vez de
transcribirlos con las herramientas de edición, y lo declaró: son ~1.150 líneas copiadas, y una
transcripción manual arriesga **precisamente la pérdida silenciosa de un caso que `CA-12`/`CA-13`
existen para cazar**. La fidelidad queda acreditada por el inventario idéntico y la cobertura de líneas;
las cabeceras nuevas y el README sí fueron por las herramientas de edición. Es la regla de §13 aplicada
como está escrita: *si hace falta la consola, se dice por qué*.

## [GitHub] — 2026-09-08 · REQ-014: corregido el desfase de un piso, `CA-18 (ii)` deja de mandar «en dos», y el rigor se queda en `critico` con un defecto real encontrado antes de cometerlo
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Sonnet 5 · agentes: `analista-requerimientos` (write-back) y `auditor-seguridad` (R-018, Opus).

### El desfase de una línea, corregido con su causa exacta

La línea de declaración de `PISO_AUTONOMO_SECCION` es ella misma **preámbulo** — verificado releyendo
las dos secciones. `37/1`: piso **461** (no 460), techo **577** (no 575). `37/2`: piso **468** (no
467), techo **585** (no 584). `k=1,25` **no cambia**: el cociente que lo gobierna pasa de `564/460` a
`565/461 = 1,2256`, sigue conforme. Corrección **fechada, sin reescribir** la fila original del
Historial — misma disciplina que el resto de la sesión.

**`CA-18 (ii)` deja de decir «se parte en dos»**, que era la magnitud equivocada del remedio, y pasa a
«**en tantas partes como haga falta para que cada una quepa bajo SU propio techo derivado**» — la regla
general que la sección 38 necesitaba y que el texto viejo no permitía.

### El rigor se queda en `critico`, con una prueba de tres preguntas

El auditor evaluó desde cero (la consulta anterior había quedado interrumpida sin veredicto por un
corte de presupuesto) y dio **NO**, con criterio y no por prudencia genérica:

1. **¿El cambio altera lo que una puerta deja pasar?** Sí — `CA-18` decide qué archivos pasan la
   autoprueba, que corre dentro de `hooks-en-linux`, la puerta requerida de `main`.
2. **¿Queda una máquina que cace la clase sin el auditor?** No — el propio código de `CA-18` declara
   por escrito que «un piso inflado afloja el techo sin que ninguna puerta grite», y nombra la
   auditoría como su única defensa real.
3. **¿Qué compra el rigor menor?** Casi nada: la cabecera **ya lleva** `QA: aprobado`/`Seguridad:
   aprobado` del 2026-09-06, declarados nulos en el Historial. Saltarse el turno del auditor no ahorra
   una firma — produce **una firma vigente sobre código que no existía cuando se emitió**.

### Y encontró un defecto real antes de que nadie lo cometiera

Partir `37/1` en dos duplica 149 líneas. Con la mitad-A medida en 564, **la mitad-B queda en ≈434**
contra un techo que sólo la conforma si tiene un bloque indivisible de **≈199 líneas** — **ese número no
existe en ninguna parte**, y la derivación de `k=1,25` sólo citó mitades-A. La salida barata sería
**declarar** un `piso_B` que haga cuadrar la aritmética — exactamente `DEV-014-01` un nivel más abajo, y
las comprobaciones (a)(b)(c) lo dan por bueno si los términos suman. Se pasó al desarrollador como
instrucción explícita antes de que partiera nada: **medir `piso_B`, no declararlo**, y si la mitad
honesta no llega, partir en tres en vez de forzar dos.

### `SEC-057` — `instrumento`, media, no bloquea

`veredictos.exigir_fecha` y `caducan_con_codigo` están **los dos en `false`**: la condición «veredictos
posteriores al 2026-09-08» que `CA-31` exige es prosa que ninguna puerta lee, y toda reapertura futura
hereda la exposición. Remediación enrutada a `PENDING_APPROVAL.md` (cambio de manifiesto = gate humano).

## [Interno] — 2026-09-08 · Sesión pausada por presupuesto de tokens: tablero de continuidad actualizado
> Origen: Interno · usuario: Juan · modelo de IA: Sonnet 5 · agente: coordinadora.

`docs/ESTADO.md` deja el orden exacto de los siete pasos pendientes, con el veredicto de rigor de
`REQ-014` marcado explícitamente como **interrumpido sin resultado** (no asumir nada de lo que la
comisión detenida alcanzó a ver). Árbol limpio, cola en 0, nada en vuelo.

## [GitHub] — 2026-09-08 · REQ-014: la máquina de `CA-18` deriva el techo por archivo, y el oráculo de `CA-12` normaliza por propiedad — verificado independientemente
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

### `CA-18` — el literal `≤400` desaparece; `ca18_deriva()` con tres comprobaciones y fail-closed

Una sola pasada de `awk` deriva `líneas(f) ≤ max(400, ceil(piso(f)×1,25))` y comprueba **(a)** todos
declaran, **(b)** los términos suman el valor declarado —**una derivación que la máquina no puede leer
es ILEGIBLE, fail-closed, no se da por buena**—, **(c)** `piso ≤ líneas`. Publica una fila por archivo:
líneas / piso / techo / **quién gobierna el techo** / líneas duplicadas — publicado y **no comparado**,
a propósito.

**Los 45 techos derivados:** 42 archivos con techo `400` (gobernados por `N`); 2 con techo `piso×k`.
Excedidos hoy, los tres que el REQ nombra: `37/1` **849→577**, `37/2` **679→585**, `38` **828→400**
(su piso, 133, queda muy por debajo del umbral de 320 — lo gobierna `N`, no su piso).

### `CA-12` — el oráculo por propiedad, sin nombrar una sola unidad

Es identidad el numeral que **designa** (pegado a un nombre; ≥3 partes = versión o fecha; entre
comillas = la entrada que el caso ejercita); es medida **toda la evidencia** publicada tras dos
espacios, y en el nombre lo escrito en **notación de magnitud**. Los **tres negativos contratados**,
automatizados en la autoprueba: suprimido → `cmp` falla y **nombra la línea**; renombrado → falla y
**nombra los dos textos**; veredicto invertido → falla y **nombra el caso con los dos valores**. Control:
inyectar en una sola línea de dos que colisionan bajo el oráculo también se detecta — la multiplicidad
no la esconde.

**Y el desarrollador desmintió sus dos primeras propuestas, midiendo:** «normalizar todo numeral que no
sea identificador» destruía 138 líneas de identidad estable; «unidad = cualquier byte no ASCII»
normalizaba las cotas normativas (`2×`, `6×`, `1µs`) dentro del nombre. La versión final las conserva.

### Verificado independientemente antes de comitear

`bash tests/escenarios/hooks/autoprueba-corredor.sh` corrido por la coordinadora, no aceptado de
palabra: **105 PASS, 1 FAIL**, y el FAIL es exactamente `CA-18` nombrando los tres archivos con sus
líneas y su techo — coincide al dígito con el reporte del desarrollador.

**Banco: 4 corridas, todas 880 PASS · 0 FAIL · 4 SKIP · rc 0**, cuadre 884. `CA-12` de su propio
cambio: inventario **byte a byte idéntico** antes y después (884 líneas, 73.508 bytes). `CA-14`
acreditado entero. Gates de §7 en verde; `bash -n` en verde sobre las 45 secciones + corredor +
autoprueba + inventario.

### Un desfase de una línea, encontrado midiendo, y una consecuencia para la comisión siguiente

**El piso de las dos secciones 37 sube en 1**: la línea de declaración de `PISO_AUTONOMO_SECCION` es
ella misma preámbulo, así que `37/1` = 461 (no 460) y `37/2` = 468 (no 467). `k` no cambia — la mejor
partición medida pasa a **565/461 = 1,2256 ≤ 1,25**, sigue conforme. Corrección de Historial, sin ADR.

**Y un hallazgo nuevo para quien parta los archivos:** `37/1` y `37/2` caben en **dos** archivos cada
una; **`38-sondas-compartidas.sh` no** — dos mitades salen a ~424 líneas contra un techo de 400, así
que necesita **tres**.

### `SEC-053` → `mitigado` (auditor, R-017)

Residual único resuelto por la ratificación del propietario, re-verificada contra el árbol de `v1.31.0`.
`SEC-056` nuevo (`instrumento`, no bloqueante): el índice de hallazgos vive dentro de una entrada
fechada. `v1.33.0` sigue sin despejar: **30** `contrato` abiertos.

**Sesión pausada por presupuesto de tokens del usuario.** La evaluación de si `REQ-014` admite rigor
menor quedó **interrumpida sin veredicto** — no se aplicó ningún cambio de rigor. Pendiente para la
próxima sesión.

### Techo honesto de esta comisión

No tocó `Estado:`, `Historial`, `CHANGELOG.md`, los dos ADR pendientes ni `docs/qa/1.33.0.md` — por
instrucción, y no comiteó. Dos líneas de documentación quedan **incompletas, no falsas**:
`tests/escenarios/hooks/README.md` («cómo se añade una sección», ahora cuatro pasos) y
`ARCHITECTURE.md:39`. **Aviso operativo:** el oráculo nuevo invalida cualquier inventario ya
normalizado que se guarde como línea base; hay que regenerarlo desde la salida cruda.

## [Interno] — 2026-09-08 · `v1.31.0` ratificada; y `REQ-019` protegido por escrito como primer e ÚNICO trabajo de 1.34.0
> Origen: Interno · usuario: Juan · modelo de IA: Sonnet 5 · agente: coordinadora.

**Ratificación.** El propietario confirmó `v1.31.0` como publicada de autoridad no acreditada (R-016),
misma resolución que ya dio para `v1.32.1`. Registrado en `PENDING_APPROVAL.md` → `## Resueltas`; el
auditor cierra el residual de `SEC-053` en su propio registro.

**Protección de `REQ-019`.** Con `≈30` comisiones despachadas en la sesión de hoy y `REQ-019` —la única
de las cuatro palancas de coste que reduce **tokens** y no reloj— sin haber avanzado ni una línea de
código pese a llevar **dos** salidas de ventana, `docs/PLAN.md` §1.34.0 gana una nota de apertura: la
ventana **empieza** con `REQ-019` y **nada más** entra hasta que cierre, ni el bloque de paralelismo ni
el núcleo por estado, salvo lo que bloquee la publicación misma. Corregida además una celda **stale** de
la misma tabla que seguía diciendo «adelantado a 1.33.0» — la clase de desfase que el resto de la sesión
llevaba cazando en otros documentos, encontrada aquí en el propio plan.

## [GitHub] — 2026-09-08 · R-016: la frontera del permiso para publicar, escrita por quien no se beneficia de ella — y 2 de 40 tags salieron de autoridad no acreditada
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `auditor-seguridad` (Opus). Lectura **GLOBAL** ratificada por el propietario el 2026-09-08.

### La frontera, seis puntos y todos por propiedad

1. **Qué se cuenta: por CLASE, no por origen.** Todo hallazgo de clase `usuario/dinero` o `contrato`,
   del proyecto entero, **cuelgue o no de un REQ**, sea cual sea el prefijo del ID — porque **el prefijo
   no dice nada de la clase** (`SEC-`, `QA-`, `DEV-`, `AN-`, `H-`, marcado **no exhaustivo**).
2. **Qué es abierto: el complemento del cierre** — todo estado que no sea `mitigado` ni `aceptado`.
   Enunciado por complemento **a propósito**: *el conjunto que abre es el que crece*. **Lo
   indeterminable cuenta como abierto.**
3. **Dónde se lee: dos sedes, por UNIÓN, fail-closed en la discrepancia.** Si un ID sale bloqueante en
   una y cerrado en la otra, **cuenta como bloqueante**, y la discrepancia **por sí sola** devuelve la
   decisión.
4. **Sobre qué árbol:** el commit que se etiqueta, por `git show`.
5. **Cómo se acredita: publicando el recuento** en la entrada de CHANGELOG del tag. Y la mitad que
   importa: **sin recuento publicado la publicación no está acreditada, aunque el recuento hubiera sido
   cero.**
6. **Lo que no es: una puerta.** `guard-completado` sólo lee el campo del REQ que se cierra
   (`hooks/guard-completado.sh:484-527`), y `tools/arnes-lectura.sh` **no reporta ese campo** — medido.

**Por qué hizo falta construir un índice:** midió que **la prosa del registro no se puede contar** —
encabezados `###` y `####` mezclados, clase en el encabezado o en una línea `- **Clase:**`, estado
cambiado en entradas posteriores. *«Un criterio que depende de interpretar prosa es el mismo defecto en
otra capa.»* Nace el **«Índice de hallazgos de clase bloqueante»**, 37 filas, sitio único de la lista
exhaustiva.

**La consecuencia, escrita en el mismo párrafo que concede la delegación:** hoy **no autoriza nada**.
**Reactivación medible:** recuento cero en las dos sedes, sin discrepancias, sobre el commit a
etiquetar, y **publicado**. Y su evaluación, con cifras: en la ventana 1.33.0 seguridad abrió **19**
`contrato` y cerró **6**. *«Una delegación cuya condición nunca se cumple es mejor retirada que en
pie»* — **retirarla es del propietario y no la tomó.**

### El barrido: 40 tags · 4 bajo el criterio · 2 conformes · 2 de autoridad no acreditada

| Tag | Veredicto |
|---|---|
| `v1.2.0`…`v1.30.2` (**36**) | **Fuera del criterio**: no existía el bloque de delegación, ni registro de seguridad, ni **un solo** `requirements/REQ-*.md`. Declara lo que **no** midió: quién decidió esas 36 |
| `v1.30.3` | **Conforme** — cero bloqueantes en las dos sedes |
| **`v1.31.0`** | **De autoridad NO acreditada, y es NUEVO.** Tres `contrato` —`QA-114`, `QA-116`, `QA-117`— declarados en **las dos** sedes del tag, publicación anunciada como «cierre del ciclo 2», agente sesión coordinadora, sin entrada en la cola. **Ratificación PENDIENTE** |
| `v1.32.0` | **Conforme, y no por delegación**: decisión expresa del propietario en `PENDING_APPROVAL.md` |
| `v1.32.1` | De autoridad no acreditada, **ratificada a posteriori por el propietario** el 2026-09-08 |

**Por qué `v1.31.0` no se había visto: R-015 buscó prefijos `SEC-` y esos tres son `QA-`.** Y el auditor
corrigió su propio recuento: los «17» de R-015 estaban **cortos por construcción** — el hueco eran
**trece**, por **tres** motivos distintos (siete por el prefijo, cuatro por la sede, dos por
autoexclusión). 17 + 13 = **30**. Su frase:

> **«Quien enumeró sabía que enumerar falla y falló igual: eso es el argumento, no la anécdota.»**

### `v1.33.0` NO está cubierto, y lo dice en la dirección incómoda

**31** `contrato` abiertos sobre `b199e08` más `SEC-055`; **0** `usuario/dinero`; **24** descontando los
siete discutibles. Cuatro apuntan a la publicación misma: `SEC-050`, `SEC-053`, `SEC-054`, `SEC-055`. Y
la mitad que no le conviene: **descontando los 12 que no cuelgan de ningún REQ, quedan 19** declarados
por QA, desarrollador y analista — **mismo resultado**. La fusión, el tag y la publicación son decisión
del propietario.

`SEC-053` pasa a **`en-mitigación`**, no a `mitigado`: residual único = la ratificación de `v1.31.0`,
vencimiento antes del tag. *«Si se publica sin resolverlo, serán tres, y eso deja de ser descuido.»*

### `SEC-055` — `AGENTS.md` promete una delegación que ya no existe

`contrato` · abierto · severidad **media** · dueño `analista-requerimientos` (write-back) y
**propietario** (decisión de fondo). `AGENTS.md:60` (§4) y `:120` (§6) arrastran la misma ambigüedad que
la frontera acaba de cerrar. **No lo arregló**: `AGENTS.md` está en el `Archivos:` de `REQ-019` y una
edición ahora colisiona. Lo que acota la severidad, **medido**: **no viaja a las plantillas** (`grep`
sobre `templates/*.tpl` y `CLAUDE.md` da **cero**), así que ningún consumidor hereda la promesa falsa.

### Y el caso real que justifica el índice entero

**`SEC-014` estaba `mitigado` desde R-006 y `REQ-013` sigue declarándolo abierto.** Segunda discrepancia
declarada, y llevaba **dos ventanas** sin que nadie la viera. No es un ejemplo inventado para defender
el mecanismo: es el mecanismo encontrando lo que existía.

## [GitHub] — 2026-09-08 · `SEC-054` remediado: el ADR y el README dejan de afirmar lo que la medición desmiente — y aparece un TERCER sitio
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus). Autorización expresa del propietario, 2026-09-08.

### La nota de `ADR-005`, añadida y no sustituida

Bloque de cita **inmediatamente después del punto 4**, sin borrar ni editar una palabra del original y
sin tocar `Estado:` — porque **un ADR no se reescribe** (`AGENTS.md` §10) y lo decidido el 2026-09-07 y
lo medido después tienen que poder leerse **juntos**.

Lo que dice, y la formulación es lo que vale:

> **Qué acredita hoy el verde:** que el control **falla sobre la entrada nombrada en el forzador** —una
> aritmética concreta, **un ejemplar**—; **no** la propiedad «el instrumento responde al sujeto», porque
> el testigo es **predecible sin ejercer nada**. Mientras testigo y parámetro sean constantes del mismo
> sistema en **razón fija**, **toda magnitud alcanzable sin hacer el trabajo pasa**, en toda máquina y
> toda corrida. El par «mutada FALLA · sin mutar PASA» prueba que el control **falla sobre una entrada**,
> no que **distinga**.

Y una consecuencia que el desarrollador derivó y que corrige el propio hallazgo: **el residual no se
puede clasificar por la intención del autor, porque el conjunto que pasa es estrictamente mayor que
«lee el sujeto» — así que incluye el descuido.** La frontera «falsificación deliberada» sólo se vuelve
verdadera **después** de las dos piezas de coste cero.

### Cuatro afirmaciones más, corregidas en `tests/util/README.md`

1. **El `0 de 30 en cuatro regímenes`, en DOS sitios** —la nota de la escalera de `CA-03 (d)` y la fila
   de `ARNES_SONDA_CAL_R`—, sostenía «subir `r` de 3 a 5 no movió la tasa». QA lo retiró. Ahora dice que
   **hoy no hay medición que sostenga esa frase** y publica la que sí existe: **0/16 · 1/16 · 9/16**, con
   **8 de 13 casos en (c)** y `sonda-procesos.sh` **sin un solo FAIL en 48 corridas**. De `r=5` queda
   medido **sólo el coste** (1,2825× contra techo 1,25×), y por eso `r` está en 3.
2. «La palanca que arregló la fragilidad fue (c)» — desmentida **en su generalidad**: la mejora está
   medida **en reposo**; fuera del reposo persiste y no queda acreditada como resuelta.
3. «Lo que esto NO cierra» decía que sólo pasa la sonda que **lee** el snippet. Reescrito por propiedad:
   pasa **toda** sonda cuya magnitud publicada sea **alcanzable sin ejercer el sujeto**.
4. **La anterioridad del testigo** decía que comprueba «esa independencia». Ahora acredita lo que
   acredita: que la sonda no pudo **alimentar** el testigo, **no** que no pueda **predecirlo**.

### El tercer sitio, encontrado y NO tocado

**`tests/escenarios/hooks/README.md:378`** lleva la misma afirmación **sin matizar, literal y en
negrita**. `SEC-054` nombra **dos** sitios y hay **tres**, y el tercero también se distribuye con
`source: "./"`. El desarrollador tenía ese directorio vedado y **no lo tocó**: queda enrutado a la
comisión de partición de REQ-014, que sí lo declara en su huella, y el auditor tiene que ampliar el
alcance de `SEC-054`.

`requirements/REQ-021.md:130` —el título de `CA-03`— lleva la misma frase, y es del write-back del
analista en 1.34.0.

### Y una disciplina que conviene registrar

**No corrió el banco completo, a propósito:** *«hay cuatro comisiones vivas y la regla de despacho dice
que dos que miden no van a la vez»*. Comprobó en su lugar lo que sí podía sin medir —el caso `CA-01.4`
replicado con su propio `awk`, **1** línea apuntando a `sonda_lee` y **0** transcripciones del parser— y
las tres gates de §7. Y dejó **intactas** las cifras de coste del ADR que no pudo re-medir, diciéndolo:
*«no las re-medí y el informe de QA no las desmiente»*.

## [GitHub] — 2026-09-08 · REQ-014 reabierto: el techo se re-deriva comprobando su factibilidad ANTES de escribirlo, que es el paso que faltó
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Reapertura por la **REGLA DE ESTADO** de §9, decidida por el propietario. `Estado: completado` →
**`en-progreso`** — y no `en-revisión`, con el motivo escrito: ese estado significa «terminado, en
validación» y hoy es falso, porque queda código por escribir. Vuelve al desarrollador, no a QA.

`QA:` y `Seguridad:` sin tocar pero **declarados invalidados** en el Historial: se emitieron el
2026-09-06 sobre la redacción anterior de `CA-18` y `CA-12`. Y el dato que hace la nota no decorativa:
`DEV-014-01` y `DEV-014-02` son **`contrato`**, así que `guard-completado` **deniega** el cierre mientras
lo sigan siendo. **Ningún `aprobado` viejo puede cerrar este REQ.**

### El límite, enunciado como fórmula y no como número nuevo

```
líneas(f)  ≤  max( N , piso(f) × k )
```

- **`piso(f)`** = el mínimo autónomo, **la parte que ninguna partición baja** —partir produce *dos*
  pisos, no medio—. Se declara por archivo en `PISO_AUTONOMO_SECCION` **con su derivación término a
  término**, tres comprobaciones de máquina, y un **límite honesto** en la forma de `CA-06`: el término
  «bloque indivisible mayor» es una afirmación sobre la estructura que **ninguna máquina decide**, e
  inflarlo para caber es **regresión** que devuelve el hallazgo a `contrato`.
- **`N` = 400 no cambia.** Mismo número, mismo tipo operativo, misma dirección. Cambia **a qué se
  aplica**: gobierna los **42 de 45** archivos cuyo piso cabe por debajo.
- **`k` = 1,25**, literal **con su derivación escrita**: `564/460`, `467/467`, `516/460`, `511/467` → el
  mayor, redondeado al siguiente múltiplo de 0,05. Con obligación de **re-derivarse en la misma edición
  que cambie cualquiera de sus términos**.

**Y el paso que faltó la vez anterior, hecho esta vez:** comprobó la factibilidad **antes** de escribir.
Con **sólo** la razón, un archivo de 12 líneas con piso ~5 tendría techo 6,25 y **~42 archivos hoy
conformes saldrían rojos**. De ahí el `max(…)`. El defecto original era exactamente ése —fijar 400 sin
medir cuánto mide una sección autónoma mínima— y repetirlo con otra cifra habría sido la misma clase.

**Dos puntos que faltaban:** **(ii)** qué hacer cuando **ni partiendo cabe** —vuelve al analista, y las
dos únicas salidas llevan gate—, porque su ausencia produjo el interbloqueo real de hoy: **puerta
requerida roja sin ninguna acción conforme disponible**, con `continue-on-error` y sacar `CA-18` del CI
**prohibidos por nombre**. Y **(iii) par discriminante**, con el negativo nombrando **archivo, tamaño y
techo** y exigiendo que el positivo exista.

**Dato nuevo que refuerza el argumento:** `37/1` tiene 13 casos declarados → **65,2 líneas por caso**,
frente a **4,1** en `07-bash-falsos-positivos.sh`. Un factor **16×**: «líneas por caso» tampoco era la
magnitud.

### `CA-12` — el oráculo por propiedad

«Todo campo que sea **MEDIDA o SORTEO** y no **IDENTIDAD**», sitio único en `inventario.sh` sin
transcribir la lista, con la mitad que **no** se normaliza dicha aparte, y el negativo exigiendo **tres
inyecciones necesarias** (suprimido, renombrado, veredicto invertido) — porque un oráculo que normalizara
todo saldría idéntico siempre y no distinguiría nada.

### Dos defectos que el analista encontró por su cuenta, y el primero es el mejor del día

**`CA-14` estaba desmentido por la misma medición** (tres corridas intactas no eran idénticas) **y su
remedio literal era peor que el defecto**: «se estabiliza antes de particionar» habría ordenado **borrar
del banco las 20 líneas de medición que REQ-017 y REQ-021 existen para publicar**. Ahora corre bajo el
oráculo de `CA-12` y «inestable» se define como *en su identidad o su veredicto*, **no en su medida**.

**`CA-31` habría quedado cierto sobre un árbol que ya cambió**: todas sus condiciones se cumplen con
1.32.0 publicada y ninguna miraba el trabajo de la reapertura. Gana cuatro condiciones y la exigencia de
veredictos posteriores al 2026-09-08.

### Y una conjetura fechada, no un hallazgo

El orden «la partición va después de cerrar REQ-021» probablemente protegía **un oráculo que ya no
discriminaba**, no la congelación de `CA-07 punto 2` — las secciones a partir son justo las que publican
las cifras volátiles. Además ese orden es hoy **inoperante**: con REQ-021 `bloqueado` y en 1.34.0,
«después de cerrarlo» sería nunca.

**Coste: 5 comisiones, con riesgo real de 7.** Vueltas dev↔QA disponibles: **0 de 3 consumidas**.

## [GitHub] — 2026-09-08 · REQ-021: el REQ deja de afirmar lo que la medición desmiente, y las cifras retiradas quedan marcadas como retiradas
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Write-back de la vuelta 3. `Estado: bloqueado` y `Versión destino: 1.34.0` sin tocar; `QA:` y
`Seguridad:` tampoco.

### El criterio que fallaba, corregido donde vivía

`CA-03 (a.3)` condición 1 se parte en **(1.a) no coincidencia** y **(1.b) impredecibilidad** —
*«**no coincidir no es no ser predecible**»*—, con las dos piezas de coste cero: tamaño **sorteado por
corrida** y terna **fuera de todo directorio que la sonda reciba**. La condición 2 se extiende a «ni
**LEER** el canal». El título pasa a «no pueda ALIMENTAR **ni PREDECIR**».

**Y el forzador de `QA-021-10` deja de enumerar**, que era su defecto de forma: pasa de «la mutación
tautológica medida» —un ejemplar— a un **conjunto de mutaciones por vía de predicción** (no menos de 3,
**operativo**, ejemplos no exhaustivos con sede en el fail-before), en **dos corridas consecutivas con
sorteos distintos**, ejercido por quien no escribió la sonda. La lección, medida tres veces en este
REQ: **acreditar el ejemplar no acredita la clase.**

La frontera de «falsificación deliberada» queda reescrita como **lo que era, una salida** —clasifica por
la intención del autor, que ningún control mide— y sólo se vuelve verdadera con (1.b) y (2). Y se añade
la **vigencia** de los «hoy» de las condiciones 2–5: describen el árbol previo; en `2ce7804` están
implementadas y **aun así no distingue**.

### Las cifras retiradas quedan marcadas como retiradas

`CA-08 (ii)` queda **NO ACREDITADO** con las dos ramas cerradas, y **se borra de su palanca (1) la
cláusula «bajar `r` sólo mientras (d) siga en 0 de 30»** — `r` vuelve a la lista de (d). `CA-03 (d)`
publica el estado real (**0/16 · 1/16 · 9 de 16**), retira el «0 de 30», y declara que **todo rojo sin
regresión cuenta**: antes decía «fuera de banda», que era **la forma (d) dentro del criterio escrito
para cerrarla**. `(iii)` se publica como **rango** (2,568–4,382×, techo 6× cumplido).

Y lo que más vale para quien lea esto en un año: el `0/30` de la vuelta 2, el `1,1734× → CUMPLE` y el
`2,245×` quedan anotados como **RETIRADAS en sus propias filas del Historial**, para que el REQ no siga
publicando cifras retiradas como si fueran medidas.

### `CA-06` punto 6 — cómo se acredita un régimen

**Por su efecto**: magnitud de referencia medida **dentro** del régimen, con rango, muestras y **el
mecanismo de la carga escrito**. Nace de que el «0 de 30 en cuatro regímenes» de la vuelta 2 no publicó
ni una evidencia de que sus cuatro regímenes existieran, y su generador **no está escrito en ninguna
parte**, así que no se puede reproducir. Y `CA-03 (c)` gana la regla que faltaba: **un FAIL de (c) sin
regresión cuenta como falso rojo para (d)**.

### Dos criterios nuevos, y uno que deliberadamente NO se toca

`CA-10` **punto 3**: la puerta se atraviesa en **todo camino** que consuma un registro de sonda,
comprobado **sobre el texto**, con aborto nombrando el archivo (`QA-021-12`). **`CA-11`**: el FILTRO
selecciona **qué casos corren**, no cambia el veredicto de los que corren (`QA-021-13`).

**`QA-021-05` no cambia criterio, a propósito:** `CA-04` punto 1 ya está bien escrito y **ya ofrece dos
mecanismos más fuertes que el elegido** — ampliarlo sería taparlo. Es la distinción entre un criterio
débil y una implementación débil, y aquí es la segunda.

### `Hallazgos abiertos:` — 14 entradas, y una diligencia que conviene copiar

Entran `QA-021-11 (contrato)`, `QA-021-12` y `QA-021-13`; se actualizan `QA-021-05`, `06` y `10` con lo
medido. **Todas con la clase primera dentro de su paréntesis, y el balanceo verificado entrada por
entrada** — porque el parser de `hooks/guard-completado.sh` parte por comas a **profundidad 0** y toma la
clase hasta la primera coma interna. Un paréntesis mal cerrado ahí no da error: **cambia la clase que la
puerta lee**.

### Dos cosas declaradas y no escritas, por estar fuera de la huella

- **ADR para `P-02`** —si el contador de vueltas se reinicia al cambiar de ventana—: es **cambio de
  fondo**, porque cambia el significado de un límite de `AGENTS.md` §6 que los proyectos heredan por
  `templates/AGENTS.md.tpl`, y **aquí sí hay a qué suceder**. Decisión del propietario. Juicio del
  analista, sin cerrarlo: la opción «reinicio sólo si el propietario cambia el alcance, con el gasto
  anterior anotado» es la más fiel al motivo del tope; **«se reinicia al cambiar de ventana» convertiría
  el aplazamiento en un mecanismo de reinicio, que es justo lo que el tope existe para impedir.**
- **Write-back candidato a REQ-023**: su `CA-03` usa **el mismo patrón** «redactado para que una lista de
  prohibidos falle la prueba», y la lección de este REQ es que eso acredita el ejemplar y no la clase.
  Conviene que llegue **antes** de que REQ-023 se implemente.

## [GitHub] — 2026-09-08 · REQ-019: el trinquete protegía el NÚMERO y no la propiedad, medido en las dos direcciones. Nace CA-17
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Comisión previa que `CA-15` exige antes de repartir. **DoR: sí**, con el índice como único pendiente
—y es de la coordinadora, no devuelve el REQ a `borrador`—.

### El riesgo que se le planteó era real, y el propio inventario no lo distinguía

Se le pidió comprobar si `CA-15` separa «texto que describe una invariante **cumplida por máquina**» de
«texto explicativo», porque si no lo hace **el trinquete cuenta líneas y no protege nada**. Lo midió, y
falla en **las dos** direcciones:

- El carácter `🔒` marca **7** bloques de `AGENTS.md` y **2 de los 7 no los cumple ninguna máquina**: son
  decisiones del propietario (el modelo con que corre el QA; la política de autoalojamiento).
- Y al revés: **§13 describe conducta de máquina en bloques que no están en la tabla ni llevan `🔒`** —el
  aviso que no deniega ante un veredicto fuera de vocabulario, el recorte de celdas a 40 caracteres, la
  rotación que mueve y no resume, el bloque de continuidad, «sin manifiesto los hooks son inertes»—.
  Entraban en el inventario sólo como **promesa genérica**, **indistinguibles** de «secretos sólo en
  variables de entorno» de §10, que no cumple nadie.

### `CA-17` — cada fila del inventario declara **su ejecutor**

Ruta del archivo del mecanismo con su función, fila o cadena literal; o la marca literal
`ninguna máquina`. Cinco cosas lo hacen algo más que una columna: **(1)** el ejecutor se determina por
**búsqueda literal sobre el mecanismo** —sitio único: `codigo_app.globs` más `skills/*/SKILL.md`— y
**nunca por la decoración del documento**, que es un campo escrito por una persona y que ninguna puerta
verifica (la clase de `arnes_version` y de `Rigor:`); **(2) fail-closed**: un ejecutor declarado tiene
que resolver, y uno **fabricado es peor que `ninguna máquina`**, porque afirma que el árbol hace algo que
no hace **dentro del artefacto que acredita la no-pérdida**; **(3) trinquete asimétrico**: retirar un
elemento **con** ejecutor exige además **citar el código que dejó de cumplirlo**; **(4)** la discrepancia
**se anota y se enruta, no se arregla** — lo que compra `CA-17` no es la corrección, es que **deje de ser
invisible**; **(5)** declarado **acreditación única, no puerta permanente**, con su acotación entera,
que es lo que `SEC-033` reprochaba no decir.

### El reparto en fases, y por qué «cuatro fases» era un número falso

Son **siete**, y la estimación anterior omitía **tres comisiones estructuralmente necesarias**: `F3-bis`
(`CA-13` obliga a que las preguntas de trabajo las escriba **quien no repartió**, así que no caben en la
comisión que reparte), `F5` (QA) y `F6` (auditoría, obligatoria por §6 y donde el registro cierra
`SEC-033`). Total honesto: **9–11 comisiones y ≈8,5–14 h**, con lo añadido marcado como **estimación**
desde las medianas medidas del ciclo 2. Cada fase declara precondición, entregable con su sede, agente,
solitario, **qué detiene la ventana** y **puerta de salida**. Y una cláusula **«la ventana no crece»**:
lo que el reparto descubra se anota y se enruta, no se arregla dentro; una fase que no cabe **se parte**,
no se amplía la comisión en curso.

### Dos defectos de criterio que habrían llegado a QA como `contrato`

- **`CA-03`** tenía el único número del conjunto **sin declarar su tipo**. Ahora es `no menos de 1`,
  **operativo**, con dirección de subir.
- **`CA-04`** exigía igualdad de esqueletos **sin sujeto**: leída como inmovilidad del archivo,
  **declaraba incumplido un trabajo ajeno y correcto** — la familia de la forma **(c)**, ya corregida en
  `CA-02.1` y para las plantillas, pero no para el esqueleto del propio documento.

**Y se aplicó la regla a sí mismo:** había escrito «se validan **diecisiete** criterios» en dos sitios —
una cardinalidad que el criterio siguiente desmiente. Sustituida por «el conjunto entero de criterios de
este REQ (sitio único: este archivo)».

### `SEC-033` cierra dentro de este REQ, en `F4`

Lo cierran `CA-05` puntos 5 y 6 (cero afirmaciones de detección continua, cero rangos cerrados de
criterios sobrevivientes en `ADR-003`, los dos **de contrato**). Falta una edición de `ADR-003`, dueño
`desarrollador`, y el auditor cierra la entrada del registro en `F6`. **Con una restricción sobre el
arreglo:** `ADR-003` tiene que corregirse **por propiedad** —«cada documento en alcance y su plantilla,
en las dos direcciones»—; corregido nombrando `AGENTS.md.tpl`, el hallazgo cierra y **vuelve a abrirse**
con el segundo documento.

## [GitHub] — 2026-09-08 · R-015: SEC-052 cierra, y el permiso para publicar por delegación no tiene frontera escrita — con una publicación pasada que lo prueba
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `auditor-seguridad` (Opus).

### `SEC-052` → `mitigado`, verificado resolviendo cada cita y no aceptando el reporte

Barrido de las cuatro formas de la atribución retirada (`auditor dejó dicho`, `1.33.0 cerrara sin`,
`bloquea el cierre de la ventana`, `escala a contrato si cierra 1.33.0`): **cero** en el cuerpo. La
cláusula ahora se **cita** contra `registro-seguridad.md:4303-4317` y las dos citas resuelven exactas. La
consecuencia de máquina está corregida y comprobada **en el código**: el bloque de
`guard-completado.sh:486-527` lee el campo del REQ **que se cierra**. Y el punto que más importaba —el
argumento 3— está **rederivado, no corregido de fecha**: retira por escrito el argumento de calendario y
lo sustituye por un hecho del árbol. **Write-back pendiente de enrutar:** retirar `SEC-052 (contrato)` de
`Hallazgos abiertos:` de REQ-023.

### `SEC-053` — `contrato`, alta, dueño **propietario**: son TRES lecturas, y la que se aplicó no está escrita

El criterio de publicación delegada (`docs/gobernanza/autoalojamiento.md:148-155`) dice *«**cualquier** …
hallazgo abierto de clase `usuario/dinero` o `contrato` … devuelve la decisión al propietario»* y **no
declara sobre qué conjunto**. Medido, y sale peor de lo planteado:

- **`v1.32.1` (`973448f`) se publicó por delegación con un `contrato` abierto.**
  `git show v1.32.1:docs/seguridad/registro-seguridad.md` trae `### SEC-020 — contrato · abierto` en su
  línea 1305, y la entrada que anuncia la publicación (`CHANGELOG.md:2343-2350`, **agente:
  coordinadora**) **nombra a SEC-020** entre lo que cruza. Sin entrada en la cola.
- `v1.32.0` sí tuvo aprobación expresa (`CHANGELOG.md:2688`), así que es conforme — pero **no por
  delegación**.
- Lectura **(a) global**: 17 `contrato` abiertos hoy → la delegación estaría muerta desde que se firmó.
  **(b) por ventana**: **tampoco salva a v1.32.0**, porque SEC-020 *es* de la ventana 1.32.0.
  **(c) por los REQ que la ventana cierra**: sólo ésta hace conformes las dos publicaciones, y **no
  aparece en ningún documento**.

**La prueba de que no se puede aplicar como está, y la dio el auditor sobre sí mismo:** *«no sé decir si
mi propio hallazgo cuenta»* — bajo (a) devuelve el tag al propietario, bajo (b) y (c) no, porque no
cuelga de ningún REQ.

> **Y la forma reutilizable, que es lo peor:** sin frontera escrita, **la lectura se elige en el momento
> de publicar la parte que se quiere publicar, y siempre hay una que concede el permiso.** Es `SEC-045` y
> `SEC-052` aplicados al **permiso para publicar el mecanismo que gobierna a los demás proyectos**.

*Forzador:* la primera publicación en que se pretenda ejercer la delegación. *Vencimiento:* antes de ese
tag. *Escalada:* si se publica por delegación con la frontera sin escribir, esa publicación se anota como
**de autoridad no acreditada** y se pide ratificación expresa a posteriori.

### `SEC-054` — `contrato`, alta: 1.33.0 publicaría tres textos firmados que la medición desmiente

Primero la mitad buena, medida **por objeto de árbol**: **`hooks/` en `HEAD` es el mismo objeto
(`88c1465…`) que se firmó en R-012**, y `hooks/ tools/ .github/ .arnes/` no tienen **ninguna** diferencia
con `b6e581b`. No hay regresión en la capa de enforcement y la línea base de R-012 sigue vigente sin
re-auditar.

Lo que hay que declarar: **todo el delta de código desde esa firma es de REQ-021**, y con él se
publicarían tres textos que afirman lo que QA midió falso —

- `docs/decisions/ADR-005-…md:42` — «**Cada corrida acredita que el instrumento responde al sujeto**», en
  un ADR con `Estado: aceptada` y `Versión: 1.33.0`;
- `tests/util/README.md:50` — la misma afirmación;
- `secciones/38-sondas-compartidas.sh` — publica **PASS** sobre esa acreditación **en la puerta requerida
  de `main`**.

Contra `docs/qa/1.33.0.md:2448-2454`: *«la acreditación del propio banco certifica UNA aritmética, no la
propiedad»*. **No es duplicado de `QA-021-10`**: ése bloquea el cierre de REQ-021 y funciona; lo que nada
cubre es que **el texto firmado se publique igual** — `guard-completado` no mira ADRs ni READMEs. Y el
plugin se distribuye con `source: "./"`, **así que el ADR y el README llegan a los consumidores**. Es
literalmente la **condición 3** de la cláusula de escalada de SEC-047, en otra superficie.

**Remediación barata y sin revertir código:** nota fechada en ADR-005 declarando su punto 4 **no
acreditado** —los ADR no se reescriben, así que es **gate humano**— más una línea en
`tests/util/README.md:50` diciendo qué certifica y qué no.

**Agravante que el auditor cita y NO reclasifica:** `QA-021-06` mide 5/30 calibraciones fuera de banda —2
en reposo— y la vuelta 3 añade `CA-03 (d)` en **9 de 16** bajo saturación. Publicar eso hace **no
determinista la única puerta automática de `main`**, y la consecuencia humana está medida en `AGENTS.md`
§13: *la fricción termina con alguien apagando el guard*.

### Y el auditor se negó a fabricar un forzador, que es la parte que más vale

Preguntado si esto debe detener la publicación: **no hay veto de seguridad.** La clase `contrato` de
SEC-053 y SEC-054 gobierna el cierre de **un REQ que las declare**, no la publicación de una ventana.
Que el tag vuelva al propietario **no lo decide su hallazgo** — lo decide el criterio de
`autoalojamiento.md:148-155`, cuya frontera es precisamente SEC-053. En sus palabras: *«afirmar lo
contrario sería fabricar un forzador, que es lo que SEC-052 castiga»*.

## [GitHub] — 2026-09-08 · REQ-021 a `bloqueado`: el tope de 3 vueltas se agota y la clase sobrevive a su cuarta variante. Escalado al propietario
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (**Opus**, por decisión del propietario).

**`AGENTS.md` §6 aplicado tal como está escrito:** agotado el tope de **3 vueltas dev↔QA por REQ** —el
contador no se reinicia—, el REQ **o cierra con residual declarado o pasa a `bloqueado` y se escala al
humano**. El residual **no está disponible**: `QA-021-10` es `contrato` y `guard-completado` deniega el
cierre; sólo existiría si QA o el auditor lo **reclasificaran**, y QA se negó con la evidencia delante.
Decisión en `PENDING_APPROVAL.md`, **pipeline detenido**.

### La frase que cierra el REQ, y vale para cualquier control de este tipo

QA reprodujo el forzador **y cuatro mutaciones más, tres de las cuales no leen el sujeto, y las cuatro
PASAN**. La causa es aritmética: `SP_RESOLUCION=1`, `SP_CAL_MARGEN=4` y `SONDA_DISC_PROC_VECES=2` son
**literales**, así que `testigo = parámetro / 2` se cumple **por construcción en toda máquina**. La
condición 1 de `(a.3)` exige que el testigo **no coincida** con el parámetro —y no coincide, 2 ≠ 4—
pero:

> **«No coincidir no es no ser predecible.»** Lo que hace que un contraste pueda fallar es que la sonda
> no pueda **saber** el testigo sin trabajar.

**El forzador nombraba un ejemplar; la clase sobrevive.** Es la **cuarta** variante dentro del mismo
REQ: `2N/N = 2000`, luego `N−1`, luego el rastro que el juez crea y la sonda escribe, y ahora un testigo
**independiente en su origen pero derivable en su valor**. Cada vuelta cerró la instancia documentada y
la siguiente encontró una variante — que es, literalmente, el motivo por el que §6 pone un tope que no
se reinicia.

### Lo que la vuelta 3 sí consiguió, porque no fue un fracaso

El mecanismo pasó de **razonable a comprobable**: el juez obtiene el testigo **antes** de invocar la
sonda —*lo que no existe antes de que el sujeto corra, pudo haberlo producido el sujeto*— a coste **cero
procesos**, porque es un cambio de orden. La mutación del forzador **por fin FALLA** (`rc 1 · 74/3`)
mientras la misma copia sin mutar **PASA** (`rc 0 · 77/0`). `CA-08 (iii)` **mejoró** en las dos
magnitudes (procesos 3,714× → **3,571×**; reloj 2,921× → **2,245×**, techo 6×). Banco **880 PASS · 0
FAIL · 4 SKIP, rc 0**, cuadre **884 = 884 = suma de 45 literales** verificado por QA. `CA-07` acreditado
en sus tres puntos contra un worktree de `794fa4c`: **828 casos, 61.287 bytes, `cmp` idénticos**.

### La cadena de acreditación que se rompe, y cómo se acredita una carga

**`CA-03 (d)` falla**, con los regímenes acreditados **por su efecto** —una tarea de referencia medida:
262–282 ms en reposo → 402–508 ms con 4 de 12 núcleos → 675–1426 ms con 12 de 12—. Saturación: **9 de 16
corridas** con FAIL, y **8 de 13 casos son `CA-03 (c)`** (el sensible base mide 145.720 µs y no llega a
los 150.000 que (c) exige), **no** la mitad discordante. `sonda-procesos.sh`: **0 FAIL en 48 corridas**.

**El `0 de 30 en cuatro regímenes` de la vuelta 2 se retira**, y el motivo es de forma: su registro **no
publica ni una evidencia de que sus cuatro regímenes existieran**. Un régimen declarado y no acreditado
es un número que no puede salir mal — la misma clase que el REQ perseguía en sus sondas, esta vez en su
propia acreditación. Con él se retira **el permiso que autorizaba bajar `r` a 3** («sólo mientras (d)
siga en 0 de 30», `REQ-021.md:788`), y las dos ramas quedan cerradas: con `r=5`, `CA-08 (ii)` da
**1,2825× > 1,25×**; con `r=3`, **cumple sobre un permiso inexistente**. **`CA-08 (ii)` no queda
acreditado**, y salir de ahí es decisión de alcance del propietario.

### Hallazgos

| | Clase | Estado |
|---|---|---|
| `QA-021-10` el testigo derivable | **`contrato`** | **NO CIERRA** — analista (forma), desarrollador (valor), auditor (tercero) |
| `QA-021-11` cifras publicadas que la medición desmiente, y la cadena que autorizaban | **`contrato`** | **nuevo** — analista + desarrollador + **propietario** |
| `QA-021-12` `37/1` y `37/2` tienen **0 llamadas** a `sonda_usable` e invocan las sondas 2 y 5 veces | `instrumento` alta | **nuevo** — desarrollador |
| `QA-021-13` `run.sh 'REQ-017'` da un **FAIL falso**; preexistente en `794fa4c` | `instrumento` baja | **nuevo** — desarrollador |
| `QA-021-05` la sonda publica `vivos=0` y el `sleep 45` **sobrevivió** (QA lo mató) | `instrumento` alta | NO CIERRA |
| `QA-021-06` acreditación «0 de 30» retirada | `instrumento` alta | NO CIERRA |

**Y lo que hace la decisión barata en cualquier dirección:** QA nombró las dos piezas que faltan y las
dos cuestan **cero procesos** — el tamaño del discordante **sorteado por corrida**, y la terna **fuera
de todo directorio que la sonda reciba**. Con ellas, el conjunto de mutaciones que pasan se reduce
exactamente a «lee el sujeto», y la frontera que el REQ declara —«falsificación deliberada, no
descuido»— pasa a ser **verdadera**. Hoy es una **salida**, porque clasifica por la **intención del
autor**, que ningún control mide.

## [GitHub] — 2026-09-08 · REQ-023 a 1.34.0 sin ADR: la cata desmintió la palanca y encontró un criterio que le habría dado PASS a una guarda cuadrática
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `desarrollador` (cata de viabilidad, sólo lectura) y `analista-requerimientos` (write-back), ambos Opus.

### La cata: sólo lectura, nada escrito en el árbol, y ahorra dos vueltas dev↔QA

**Veredicto: `CA-03` y `CA-04` son satisfacibles a la vez, con el lector que existe, y sin ADR** — pero
no con la palanca que se había estrechado, y sólo bajo una lectura de `CA-03` que el criterio no fijaba.

**Premisa confirmada y más ancha de lo que decía:** el segmento de clave del corpus tiene **10 puntos de
código no ASCII**, no sólo `Módulo:`/`Versión destino:` — también los `—`, `«»`, `¿` de las **líneas de
título**, que llevan `:` y por tanto son «clave» para el lector.

**Conclusión desmentida midiendo.** «Conjunto positivo sobre el alfabeto de la clave con escapes de
bytes» tiene tres formas implementables sin procesos y **las tres mueren**:

| Forma | Cómo muere, medido |
|---|---|
| Por **bytes** | `U+00AD` —de la familia **(ii) declarada**— entra, porque sus bytes se comparten con la `«` y la `í`. Y **diverge por locale**: `ZWSP` y `BOM` admiten bajo `C.UTF-8` y deniegan bajo `LC_ALL=C`, que es `CA-05` — y el fail-open cae del lado del locale que tienen el CI y MSYS |
| Por **secuencias con sustracción** | **El veredicto depende del ORDEN de la tabla**, y para cada orden existe un malformado que admite. Es `H-01` aplicado al alfabeto: retirar no destruye un delimitador, lo **crea**. Iterar a punto fijo lo empeora |
| Conjunto positivo **correcto** | **Cuadrático**: cociente 3,65 contra un techo de 2,2; 315,7 µs frente a 23,1 de la base, **×13,7** |

**El mecanismo que sí pasa no enumera caracteres: enumera lo que ya estaba enumerado, que son las
CLAVES.** *Retirado de la clave todo lo ajeno al alfabeto de las claves que el lector reconoce, ¿lo que
queda **es** una de esas claves?* Dos expansiones y un `case`: **0 procesos** (el subshell más barato de
esta máquina cuesta 675 µs; una guarda de 17,7 µs no puede esconder un fork), **0 falsos positivos en
356 líneas** de cabecera, y veredicto **idéntico** bajo `LC_ALL=C` y `C.UTF-8` por razón estructural —el
corchete contiene sólo bytes ASCII, así que no hay rangos ni clases sujetas a colación—. Denegó las tres
familias completas y las **seis** entradas reservadas imprimibles (`Ω`, CJK, emoji, `U+FE0F`, tag,
`U+2028`); calló sobre `Módulo:`, `Versión destino:`, los títulos decorados y las cinco tolerancias de
`CA-04`.

### Los dos defectos de criterio, que valen más que el mecanismo

**1. `CA-09 (iii)` medía el sujeto equivocado — le habría dado PASS a una guarda cuadrática.** El
criterio anclaba el cociente de duplicación en `arnes_sin_cita`, pero la guarda **no puede vivir ahí**:
necesita el segmento de clave, y partirlo por `:` dentro sería una segunda transcripción de la regla de
clave. Medido: `arnes_sin_cita` marca **1,06 con y sin guarda** —porque la guarda no está ahí— mientras
el candidato cuadrático marca **2,63–3,65 en `arnes_norm_clave`, donde nadie mira**. Corregido a
**propiedad**: el sujeto es *el escáner en el que la guarda resida, determinado por el código y no por
este texto*. Margen sin maquillar: la guarda buena marca **2,05 contra 2,2**, estrecho, y sólo cumple
porque se miden funciones distintas.

**2. La guarda habría denegado un campo legítimamente COMENTADO, y el veredicto dependía de un
espacio.** `arnes_campo_linea` **no es la única boca**: `arnes_estado_cabecera` llama a
`arnes_norm_clave` directamente en `:1880` y `:1891`, y la primera le pasa la línea **cruda, pre-cita, a
propósito**. Medido contra el lector real: `<!--Estado: completado -->` **dispara**;
`<!-- Estado: completado -->` calla. Viola `CA-11` y `CA-04`. Y **las dos salidas tienen precio**, ahora
declarado en el REQ: publicar desde `arnes_campo_linea` deja el campo `Estado` sin guarda en su propio
lector; publicar desde `arnes_norm_clave` exige un interruptor por llamador y rompe la invariante
«primera sentencia del único escáner» de REQ-016.

### Y dos correcciones que el analista encontró fuera del encargo

- **`CA-06` afirmaba algo medido falso**: «todas las bocas siguen entrando por el lector único
  `arnes_campo_linea`». Retirado.
- **El conjunto de claves vive en CUATRO sitios, no en tres**: también en `hooks/campos-req.awk:75-80`.
  Escribir «se usa en las tres» habría sido **la forma (a) dentro del criterio que la prohíbe**. `CA-06`
  enuncia ahora la propiedad, cita los cuatro, y declara que unificar el awk **no** se exige aquí.

### Estado del REQ

`Versión destino: 1.34.0`, `Hallazgos abiertos: SEC-052 (contrato)` —declarado, no cerrado: lo verifica
el auditor—. `CA-03` gana el universo y el procedimiento (**R1, inserción**); el homóglifo (**R2**) y el
sorteo sobre la clase (**R3**, nombrada como *la forma (d)* de REQ-021) van a «Fuera de alcance» con su
motivo medido. `CA-12 (ii)` anclado a su corpus y su versión, con el conflicto de REQ-024 CA-08/CA-09
registrado como resuelto. Añadida la sección **«El techo honesto de la cata»**: ruta crítica del banco,
corpus de fixtures de `CA-04` y `guard-completado.sh` declarados **no medidos**.

**Coste revisado: cinco o seis comisiones, no cuatro** — y no por «más criterios»: `CA-06` se partió en
una decisión de diseño con radio que va **antes** de escribir la guarda, y la constante única de claves
más el `CA-09 (iii)` corregido convierten la sonda de duplicación en trabajo real.

### `requirements/README.md` — el índice, que es una copia a mano

Añadidas las filas de **REQ-023** y **REQ-024** (faltaban las dos; la de REQ-023 era el único punto de
DoR que quedaba). Y corregida la de **REQ-021**, que decía `QA: pendiente` cuando la cabecera dice
`con-hallazgos`, y describía «las tres sondas» después de que el alcance se redujera a dos. **Es la
tercera vez en dos días que estas celdas se desfasan**, y el arreglo real no es corregirlas: es REQ-019,
que las convierte en bloque derivado entre marcadores leído por el mismo lector que la puerta.

## [GitHub] — 2026-09-08 · REQ-021 vuelta 3 de 3: el testigo sale del juez por un camino que la sonda no puede alimentar, y la anterioridad lo hace comprobable
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

Tercera y última vuelta dev↔QA de `REQ-021`, contra `QA-021-10` (`contrato`): **la misma forma por
cuarta vez —el testigo salía de la sonda que se juzgaba— y esta vez el arreglo es de reparto, no de
aritmética.** El sujeto discordante lo **construye el juez** y llega a la sonda como snippet
(`--disc-sujeto`, obligatorio en `--calibrar`); el **valor** del testigo lo pone el juez; y lo tiene
**antes** de invocar, con las dos marcas de reloj publicadas para que la anterioridad se **compruebe**
en vez de razonarse. Cuesta cero procesos: es un cambio de orden.

- **`tests/util/sonda-procesos.sh`**: fuera `sp_cal_disc`, `SP_DISC_VECES`, `--rastro` y el campo
  `disc_veces=`; el discordante pasa de 3 invocaciones (`cal_n − 1`, que decidía la sonda) a **2** del
  juez, por el **camino único** que ejerce el sujeto.
- **`tests/util/sonda-reloj.sh`**: fuera `SR_DISC_VUELTAS` (`cal_n / 50`) y el campo `disc_vueltas=`,
  que el juez **leía** para construir su propio testigo.
- **`run.sh`**: el juez deriva, cronometra y publica las ternas **antes** de la primera invocación;
  `SONDA_SUELO_US` pasa al juez (quien es juzgado no aporta la vara) y `sonda_discordante` gana
  **cinco abortos nombrados**.
- **Sección 38**: el fail-before se re-ancla a la **definición** de la función que ejerce el sujeto y
  no a un literal de su cuerpo, y entran **4 casos** (28 → 32; `CASOS_ESPERADOS` 880 → **884**).

**Acreditación, con el par dentro de la corrida y contra el juez real sin tocarlo:** la copia con la
observación quitada —la mutación que QA midió **pasando**— da `FAIL` nombrando la condición y los
números (`disc_obs=4 · testigo=2 · parámetro=4`) y la misma copia sin mutar, `rc 0`. Banco
**880 PASS · 0 FAIL · 4 SKIP, rc 0**, cuadre 884; `CA-08 (iii)` **3,571×** en procesos (de 3,714×) y
**2,245×** en reloj (de 2,921×), techo 6×; autoprueba 72/1 con `CA-18` como único rojo.

**Y dos afirmaciones desmentidas midiendo, la segunda contra el trabajo de esta propia comisión:**
la sospecha que QA dejó sin medir sobre la banda del reloj es **cierta** —un `disc_obs` **calculado**
(3998 µs) pasa contra un testigo de 639 µs, porque la banda es una ventana de 625×—; y **`CA-03 (d)`
no es 0 de 30 fuera del reposo**: 0/16 en reposo, **6/16** con 4 de 12 núcleos ocupados y **13/16** en
saturación, con el árbol anterior dando **7/16** y **17/16** bajo la misma carga. No es regresión: es
el mismo instrumento, y el modo dominante es `CA-03 (c)` —`cal_n` derivado de un sondeo de 2 ms—, no
la mitad discordante. `sonda-procesos.sh` sale exacto en las 32 corridas del muestreo en que se
registró su valor, y sin un solo FAIL suyo en las 48. **`QA-021-10` no se cierra
aquí**: la acreditación que lo cierra la ejerce quien no escribió la sonda.

## [GitHub] — 2026-09-08 · REQ-024 (borrador): la ausencia que abre, en el segundo lector; y un conflicto con REQ-023 que hay que anclar antes de implementarlo
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Existe porque tres hallazgos sin archivo comparten **una** propiedad: la mitad (2) de **SEC-047** (el
campo comentado, con forzador subido en R-013 a «bypass alcanzable con una edición visible»), las tres
partes de **SEC-051** y la reparación del puntero de **REQ-016 CA-11**. `Versión destino: 1.34.0`,
`Rigor: critico`, `Estado: borrador`.

**Se queda en `borrador` a propósito: ocho preguntas abiertas, cuatro de fondo**, y las cuatro cuelgan
de dos ADR que el propio REQ declara como entregables —cómo se **activa** la exigencia (fija el radio de
migración entero), qué **dirección** de ausencia corresponde a cada campo, **dónde** vive el sitio único
(decide si REQ-016 se reabre) y si ADR-007 cruza la frontera de grano de línea de la cola—. Ninguna se
cierra desde la mesa del analista: son gates humanos.

**Coste estimado: 9 comisiones en el camino feliz, 11–13 realista**, todas en serie (comparten
`hooks/lib.sh` y nueve archivos con REQ-023). Dos precondiciones duras: no arranca hasta que REQ-023
cierre, y `CA-07` no se puede medir hasta que existan las sondas de REQ-021.

### Los dos conflictos con REQ-023, y el segundo hay que anclarlo ya

1. **REQ-023 `CA-11` vs REQ-024 `CA-01`.** CA-11 contrata que la ausencia «se sigue perdonando
   exactamente como antes». CA-01 cambia esa conducta. Compatibles **si y sólo si** ADR-006 elige
   **activación explícita**; si la exigencia fuese el defecto, REQ-023 CA-11 pasaría a describir una
   conducta que el árbol no tiene — hallazgo `contrato` y, si ya estuviera cerrado, reapertura.
2. **REQ-023 `CA-12 (ii)` vs REQ-024 `CA-08`/`CA-09`.** CA-12 (ii) contrata que `arnes_cola_pendientes`
   cuenta y devuelve **exactamente lo mismo**; CA-08 y CA-09 **cambian** el conteo y el `rc` para dos
   formas. No hay contradicción **si** ese criterio queda anclado a **su** corpus y **su** versión — y
   hoy no la hay, porque R-013 midió que ninguna de las formas que abren tiene caso en el banco de
   1.33.0. **Sí** la hay si se implementa como no-regresión **abierta** («la cola nunca cambia su
   conteo»): entonces la implementación de REQ-024 romperá una prueba de REQ-023. Se ancla en el
   write-back de REQ-023, no en 1.34.0.

### `docs/PLAN.md` — cuarta modificación del alcance de 1.33.0 en dos días

Registrada con su motivo: REQ-023 salió el mismo día que entró porque su coste se midió **después** de
meterlo. Y queda escrito que el argumento con el que la coordinadora justificó tenerlo dentro era
**falso y ya estaba medido falso** (R-013 §2): aplazarlo deja `AGENTS.md` §13 igual de honesta. Una
consecuencia inventada para sostener una prioridad es la misma forma que `SEC-052`.

## [GitHub] — 2026-09-08 · Una condición de escalada que sólo existía en el REQ al que beneficiaba: SEC-052, y REQ-023 sale de 1.33.0 por decisión del propietario
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` (write-back de REQ-023) y `auditor-seguridad` (R-014, Opus).

### Lo que decidió el propietario

Con el coste de REQ-023 ya medido —**cuatro comisiones en serie** tras REQ-021: cata del desarrollador,
implementación, QA con una vuelta dev↔QA **por diseño** y auditoría—, el propietario decidió que
**1.33.0 se publica sin REQ-023**, que pasa a **1.34.0**. No es un incumplimiento de ningún
vencimiento: el de SEC-047 es el cierre de **1.34.0**, así que meterlo en 1.33.0 había sido un
**adelanto**, y desandar un adelanto no incumple nada.

### `SEC-052` — `contrato`, media: el REQ citaba al auditor una cláusula que el auditor no emitió

`requirements/REQ-023.md:450-452` y `:566` afirmaban que el auditor había dejado dicho que **SEC-047
sube a `contrato` si 1.33.0 cierra sin REQ-023**. No existe. El auditor lo trazó con
`git log --all -S`: la frase aparece en **un solo commit**, `721cb71` —el borrador de REQ-023 mismo—, y
el blob de R-012 donde nació SEC-047 ya decía **1.34.0**. Su registro nunca dijo otra cosa, y el propio
REQ-023 se desmiente en su línea 431.

**Son dos cosas falsas, no una,** y por la segunda la clase es `contrato` y no `instrumento`: *(i)* la
atribución, y *(ii)* la consecuencia de máquina —«un `contrato` abierto bloquea el cierre de la
ventana»—. `guard-completado` lee el campo `Hallazgos abiertos:` **del REQ que se cierra**, no un
barrido del proyecto: bloquea el REQ que lo declara, y lo que devuelve la publicación al propietario es
la gobernanza (`docs/gobernanza/autoalojamiento.md`), no la puerta.

**La forma, que es lo reutilizable:** una condición de escalada que sólo vive en el documento cuyo
aplazamiento castiga **no es un forzador, es un argumento con la firma de otro**. Es la misma familia
que ya se había medido tres veces en REQ-021 —quien escribe el instrumento diseña el control que sabe
pasar—, aquí aplicada a un forzador en vez de a una sonda.

**Enmienda del auditor para no dejar la escalada colgada de una fecha** (R-014 §4): la mitad (1) de
SEC-047 sube a `contrato` en la primera de tres — que 1.34.0 cierre sin ella; que **deje de ser
latente** (se mida el carácter en la cabecera de algún REQ, de cualquier árbol o de la historia); o que
**un texto firmado empiece a prometer la propiedad y no el carácter** mientras el código guarde sólo el
CR. Formas no exhaustivas, manda la propiedad. Y explícito: **la ventana en que el propietario decida
hacer el trabajo no la sube.**

### Y una afirmación de la coordinadora que la medición desmiente

Al presentar la decisión se dijo que publicar sin REQ-023 «publica una ventana más una promesa falsa en
`AGENTS.md` §6 y §13». **R-013 §2 ya había medido que no:** cerrar la vía del carácter **no cierra la
clase**, porque el comentario y el borrado siguen abiertos; las filas son falsas **desde `v1.30.3`**, en
cinco versiones, de forma **latente** (ningún REQ de toda la historia llevó un carácter invisible en
cabecera). Y en sentido contrario: si se aplaza, la fila del CR de §13 **no** se reescribe —CA-10 es de
REQ-023— y sigue nombrando el CR, que es exactamente lo que el árbol tiene. **Aplazar deja §13 igual de
honesta.** La decisión no cambia; el motivo con que se presentó estaba inflado.

### Write-back de REQ-023 (`analista-requerimientos`)

- **`SEC-051` va aparte, a REQ-024**, y no por tamaño: `hooks/lib.sh:1577-1583` declara **por escrito**
  la frontera con `arnes_cola_pendientes` y deja escrito el precio de cruzarla — unificar la noción de
  cita cambia el **conteo** de la cola, que es un cambio de **veredicto** de la puerta, que es un cambio
  del contrato de REQ-009 (`completado`) **sin ADR**. Verificado leyendo el código.
- **`CA-12` nuevo, y es lo más valioso de la comisión:** la noción de cita de la cabecera gana **no más
  de 0** transcripciones; `arnes_cola_pendientes` cuenta y devuelve **exactamente igual** antes y
  después; y ningún artefacto del REQ afirma que la clase quede cerrada. Existe porque la deriva es
  **previsible**: quien implemente REQ-023 estará editando esa misma función en la misma ventana con
  SEC-051 sugiriéndole unificar, y hacerlo «de paso» es cambio de alcance sin ADR.
- **Seis enumeraciones corregidas.** El REQ llevaba **cinco** listas de dos campos y un «un solo sitio»
  seguido de dos sitios. La propiedad de CA-02 se **deriva midiendo** —campo de cabecera cuya ausencia
  la puerta resuelve del lado que abre— y el recuento va al Historial, nunca al criterio.
- **La frontera de CA-11 estaba medida falsa** y se habría desmentido sola el día que QA la probara:
  decía «¿el documento lo declara **en letra**?», y bajo esa letra `<!-- Sensible a seguridad: sí -->`
  declara en letra. Reescrita por propiedad: *¿la retirada la decide una regla contratada del lector, o
  no la decide nadie?*

### Deuda del auditor descargada en la misma revisión

La remediación (2) de SEC-047 estaba escrita **por enumeración de dos campos** cuando la superficie
medida son cuatro. Queda reescrita **por propiedad** (R-014 §5). `docs/seguridad/gobernanza-datos.md` no
cambia y **ningún estado de seguridad aprobado se mueve**: la línea base de no-regresión de REQ-017
sigue siendo R-012.

## [GitHub] — 2026-09-08 · QA vuelta 1 de REQ-021: la tautología sobrevivió a la reducción de alcance, y esta vez el testigo lo escribe la sonda
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**Vuelta interrumpida por reinicio de la máquina, y cerrada en limpio: `QA:` sin tocar, registro
encabezado como parcial, y lo no mirado tabulado como NO MIRADO — nunca como PASA.** Pero alcanzó a
hacer el experimento que se le pidió primero, y encontró la pieza que decide la vuelta.

### `QA-021-10` — `contrato`, alta: la mutación tautológica que el juez APRUEBA

En `tests/util/sonda-procesos.sh` **el testigo lo escribe la propia sonda**, que es lo que `CA-03 (a.3)`
prohíbe **por nombre**:

```bash
for ((sp_i = 0; sp_i < SP_DISC_VECES; sp_i++)); do
  grep -q x /dev/null || :
  [ -n "$SP_RASTRO" ] && printf 'x\n' >> "$SP_RASTRO"
done
```

El juez **crea el archivo vacío y cuenta**, pero el **valor** lo pone la sonda. Con `disc_obs = cal_n−1`
y el testigo saliendo de las mismas marcas, **`3 = 3` se cumple por construcción, haga la sonda algo o
nada**. Es el `2N/N = 2000` de `QA-021-01` con otra aritmética: **`N−1`**.

QA construyó una copia que **no invoca `grep` ni una vez**, no cuenta ningún proceso y calcula las cinco
magnitudes por aritmética. El juez real, sin tocarlo:
`PASS … (disc_param=4 · disc_obs=3 · testigo del juez=3)`.

**La mutación del desarrollador era la estrecha** —`SP_DISC_OBS="$SP_DISC_PARAM"`, publicar el
parámetro—, y ésa sí la caza. **La clase de `QA-021-01` salió del árbol con la sonda retirada y sobrevive
en el instrumento que se quedó.** Es la lección de método del día en su forma más limpia: *quien escribe
el instrumento muta lo que se imagina*, y por eso la acreditación por mutación tiene que decir **por
quién**.

Es `contrato` y no `instrumento` porque **el REQ afirma dos cosas falsas sobre lo construido**: que el
testigo lo obtiene el juez **sin** la sonda, y que una implementación tautológica **incumple** `(a.2)`.
QA **no reescribió el criterio** — el write-back es del analista.

**Y una abstención que merece registro:** construyó también la mutación de `sonda-reloj.sh` y **no la
ejecutó**, así que dejó su sospecha sobre la banda de 625× anotada **como no medida y por tanto no como
hallazgo**.

**Confirmado de paso:** `QA-021-09` cerrado de verdad —los 4 SKIP salen uno a uno con motivo propio y
«ninguna causa común»—, y con él `QA-021-07`: donde salía `0,000×` ahora sale `procesos=no-aplica` con
motivo. Quality gates §7 **3 de 3**, banco **876/0/4 rc 0**, y **`CA-18` confirmado como único FAIL** de
la autoprueba.

**Validez declarada:** midió sobre `7180739` y el HEAD avanzó a `61063d0` a mitad de comisión;
comprobó que `git diff --stat 7180739..HEAD -- tests/ hooks/ tools/ requirements/REQ-021.md` sale
**vacío**, así que las cifras valen, y lo dejó escrito en el registro en vez de callarlo.

**Conteo de vueltas: 2 de 3 gastadas.** La coordinadora cuenta esta vuelta **aunque quedara
interrumpida**, porque produjo un **bloqueante que obliga a volver al desarrollador** — que es lo que
define una vuelta dev↔QA, no cuántos criterios se alcanzaron a validar.

## [Interno] — 2026-09-08 · Sincronizados `PLAN.md` y `ESTADO.md`, que llevaban dos ventanas de retraso — y la cifra del impuesto de arranque se corrige
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

**Deriva de calendario, corregida.** Los dos tableros situaban `REQ-019` en 1.33.0 y describían la
ventana como «las cuatro palancas de coste», cuando su alcance vigente es **REQ-017 + REQ-021 +
REQ-023**. Lo detectó la comisión de REQ-019 al cerrar su Definition of Ready: era el único punto que no
podía cerrar ella, porque esos dos archivos no están en su `Archivos:`.

**Y el historial del alcance queda escrito, porque vale más que el alcance:** esta ventana **creció tres
veces en un día** —nació con `REQ-017 + REQ-019 + REQ-021`, entró `REQ-023` y salió `REQ-019`—, que es
exactamente el mecanismo con el que este mismo plan explica el descontrol del ciclo 3. Sacar REQ-019 no
pierde su ahorro: el argumento para tenerlo aquí era que *1.34.0 es la ventana con más comisiones*, y eso
se cumple igual siendo **su primer trabajo**.

**Se dice por su nombre lo que la ventana NO entrega: la reducción de tokens.** REQ-017 abarató el
**reloj** del banco y esperar al banco es **gratis en tokens**; REQ-021 ahorra ~150 k por ventana **cuando
exista**; la palanca de tokens es REQ-019 y está en 1.34.0.

**Corrección de una cifra del propio plan.** La tabla de palancas atribuye **~9 k tokens** de impuesto
fijo a `AGENTS.md`. Medido el 2026-09-08: **§0 obliga a tres documentos** y el arranque son **≈17 000–20 000
tokens** —`AGENTS.md` 33 827 B, `requirements/README.md` 31 192 B, `docs/ESTADO.md` 9 707 B; bytes y
palabras **medidos con `wc`**, la conversión a tokens **estimada**—. `requirements/README.md` pesa el
**42 %** y ningún REQ lo tocaba.

**Y la ampliación es menor de lo que la coordinadora anunció**, con dos correcciones suyas registradas: el
**suelo inamovible del README es el 54 % de las líneas y ≈58–64 % de los bytes**, así que el ahorro real
por movimiento son **≈11–13 kB (36–42 %)** y no el doblado que anunció; y **el bloque más caro no lo baja
REQ-019** — el `## Índice`, **19 %** del archivo, es una **copia a mano** de lo que
`tools/arnes-lectura.sh` ya deriva, así que es un **mecanismo** con otro dueño.

**La cola de pendientes se rehace con lo que apareció hoy y no tenía sede:** el hueco (b) por enrutar
(`37/1` y `37/2` no llaman a `sonda_usable`), `REQ-017 CA-03` flaky sobre un REQ ya `completado`, las dos
preguntas de REQ-025 aplazadas a propósito hasta cerrar la ventana, `SEC-050`/`SEC-051` sin ventana, y el
`_doc` del manifiesto que ninguna migración toca. **El bloqueo se nombra:** la fusión está bloqueada por
`CA-18`, y no es un bloqueo de decisión —está autorizado— sino de trabajo por hacer.

## [GitHub] — 2026-09-08 · REQ-021 vuelta 2, medición: `CA-03 (d)` en 0 de 30, y el desarrollador desmiente su propia palanca
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

Máquina en reposo, **una sola comisión viva**, `arbol=87d2609`, bash 5.3.9, 12 núcleos, linux, 2026-09-08.
Oráculo `/proc/stat:processes` leído sólo con builtins.

**`CA-03 (d)`: 0 de 30 fuera de banda**, en cuatro regímenes (reposo · primera invocación en frío · 4 de
12 núcleos al 100 % · 12 de 12 al 100 %). `cal_a` **1,781–2,215**, `cal_b` **0,930–1,154** con la banda
del juez **sin tocar**. Contra el **5/30** que QA midió antes de esta vuelta, con 2 de ellos en reposo.
`sonda-procesos.sh`: **0/30**, `cal_a=2,000` y `cal_b=1,000` **exactos en las 30**, y
`disc_obs = testigo = 3 ≠ disc_param = 4` en las 30.

**Y el desarrollador se desmiente a sí mismo, que es lo que hay que retener.** En la mitad de código
declaró `r` 3→5 como la palanca de `(d)`. **La medición lo niega:** con `r=3` la tasa es la misma **0/30**
en los cuatro regímenes. Lo que arregló la fragilidad fue el **tamaño derivado del suelo** —el insensible
de **1,4× a 4×**— y el **intercalado del par**, que además tapaba una falta de **identidad de camino** (la
calibración recorría `sr_minimo` mientras la medición de una razón recorre `sr_intercala`). Devolvió `r` a
**3** y **corrigió `tests/util/README.md`**, donde él mismo había escrito que `r` era «la palanca gratis
contra la fragilidad».

Y resultó decisivo: **`CA-08 (ii)` NO cabía con `r=5`** —**1,2825×** contra el techo de 1,25×— y **el techo
no se tocó**. Se aplicó la salida pre-decidida bajando `r`, **con `(d)` medido en 0/30 ANTES de bajarlo**,
que es su condición literal: **1,1734×**, cumple.

**El desglose que el criterio obligó a escribir antes de tocar nada dice algo que nadie había medido:** la
calibración sola cuesta **5,635–6,049 s** con `r=5` y **2,103–3,462 s** con `r=3`, así que **la corrida sin
calibración sale ≈0,98–1,00×**. *La mudanza en sí es neutra en reloj; todo el exceso es la calibración*, que
es capacidad que ninguna línea base tiene. Con una nota de método: **al coste de la calibración no le aplica
el mínimo de k**, porque su sujeto se **dimensiona por corrida** — el mínimo elegiría el sujeto más pequeño,
no la muestra menos ruidosa. Se publica rango.

**`(i.1)` — NO CONCLUYENTE, con rango, y sin afirmar el signo.** Resolución del oráculo **sobre la ventana
que mide**: en reposo y ventanas de 25 s observa **31–78 forks ajenos** (6 lecturas, **amplitud 47**); el
delta pareado sobre 7 pares es **+4 a +22**. `|delta| < 47` ⇒ **rango observado**, no concluyente, **y no se
afirma el signo** — la disciplina que costó retirar el `−56`. Y una observación que vale por sí sola: la
amplitud de las diferencias **pareadas** (18) es menor que la del suelo suelto (47), lo que indica que el
pareado cancela deriva ambiental, **pero atenuar no es medir**, así que no mejora el veredicto.

**`(i.2)` — cumple, con causa nombrada.** Sujeto idéntico **acreditado** (`cuenta=7` en los dos lados).
`sonda-reloj.sh` **7 → 3 (−4)**, idéntico en 6/6; `sonda-procesos.sh` **51–52 → 21 (−30/−31)**. La causa: la
línea base gastaba **un fork por binario** resolviendo con `type -P` dentro de `$( )` y **un `chmod` por
envoltorio**; el instrumento redirige el builtin y hace **un solo `chmod` para el lote**. El del reloj queda
bajo la amplitud del suelo, **así que lo sostiene la constancia 6/6 y el conteo estructural, no el oráculo**,
y se dice así.

**`(iii)` — cumple donde es medible**, techo 6×: reloj **2,921×** (5 corridas: 2,652–2,921×) y su mitad en
procesos **SKIP citando el motivo**, nunca el `0,000×` de un contador que nunca se incrementaba; procesos
**1,674×** y **3,714×** estable.

**`CA-07`, los tres puntos, con el recorte ACREDITADO en vez de afirmado.** (1) inventario idéntico byte a
byte, **828 casos / 61.287 bytes**, `cmp` sin diferencia — y `880−828 = 52`, `852−828 = 24`, **exactamente**
los casos que esas secciones producen. (2) **4 corridas de cada árbol**: 24 casos en cada una de las 8, los
24 deterministas, **0 cambian de veredicto, 0 desaparecen**, y la lista de excluidos —**derivada, no
afirmada**— sale **vacía**; con la precisión de que el caso de la pared dio **9 PASS / 2 SKIP en 11**, así
que su no-determinismo es real y medido y simplemente no se manifestó en el experimento pareado (`SEC-030`).
(3) `CASOS_ESPERADOS` **852 → 880 = +28 exactos**, y los de 37/1 y 37/2 **sin cambio** (13 y 11 en los dos
árboles).

### Un defecto que su propia mitad de código introdujo, y que cazó su propia medición

El materializador inline comprobaba `[ -d "$REPO/.git" ]`, y en un **`git worktree`** —y en un submódulo—
`.git` es un **archivo**. Con `-d`, las dos secciones 37 decían `sin-linea-base` y **se abstenían enteras**
dentro de un worktree mientras `git` resolvía el tag perfectamente: **«la copia haciendo la mitad del
trabajo», el caso exacto que `CA-05` existe para cerrar**, reintroducido por la guarda. Pasa a `-e`. Y el
código anterior a la mudanza **no tenía** esa guarda: la trajo la sonda que sale del alcance. Correr el banco
desde un worktree es lo normal cuando trabajan dos comisiones.

### Lo que NO cumple, dicho por él

**`(i.1)` no queda demostrada como valor** —el oráculo no resuelve la magnitud sobre su ventana, y recuperar
resolución exige acotar el conteo al subárbol de procesos, que no existe hoy—; **la banda de `(d)` tiene poca
holgura** (`cal_b=1,154` a **3,8 %** del techo con `r=5`, `cal_a=2,336` a **2,7 %** con `r=3`): *0/30 no es
0/300*; **la mitad en procesos de `(iii)` para el reloj no se mide**, y es un hueco porque `(iii)` es «el
único indicador medible de la identidad de camino»; el **`Archivos:` sigue declarando
`tests/util/sonda-linea-base.sh`**, que ya no existe —no lo tocó porque cambiar la frontera altera el mapa de
colisiones y es del analista, y declarar un archivo inexistente es **conservador** para el despacho, no
fail-open—; y **`CA-18` sigue rojo** (848 / 678 / 722).

**El hueco (b) medido una vez más, gratis:** con la sonda de reloj mutada, `rc=1` con 5 FAIL en la 38
mientras **las dos 37 publicaban `CA-03 fail-before 3,878×` y `CA-04 8,718×` como PASS** con la procedencia
de la calibración **desmentida en la misma corrida**.

**`REQ-017 CA-03` flaky, con tasa:** `3,878 / 3,791 / 2,508 / 3,316 / 3,890 / 3,901 / 3,916 / 4,057` contra
techo 2,600× — **1 de 8 no alcanza a demostrar**, y es la de la máquina cargada. REQ-017 está `completado`.

**Estado: banco `rc=0 · 876 PASS · 0 FAIL · 4 SKIP`**, cuadre 880 y por archivo OK, los 4 SKIP recapitulados
con su motivo. Autoprueba **72 PASS · 1 FAIL** (`CA-18`). Las tres gates de §7 verdes. Worktrees retirados,
`git worktree prune` hecho, **índice vacío** («lección aprendida», dice él). Write-back al Historial del REQ:
**una sola entrada, con las cifras, su corrida y su ventana de resolución**.

**Coste: ~503 k de contexto en total** (≈98 k en esta mitad).

## [GitHub] — 2026-09-08 · REQ-021 vuelta 2, mitad de código: la mitad discordante caza la tautología ejecutando, y la coordinadora comitea un borrado que no puso
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

**Comisión partida a propósito: código ahora, medición después.** Ninguna de las 30 calibraciones de
`CA-03 (d)` ni ninguna de las cuatro vías de `CA-08` se corrió — había otra comisión midiendo. Los
números de abajo son **verificación funcional**, no magnitudes publicables, y ninguno va al Historial.

### La mitad discordante, con fail-before/pass-after EJECUTADO

Es la pieza que decide la vuelta. Mutación sobre una copia (`ARNES_UTIL_DIR`), sin tocar el árbol: se le
**quita la observación** a la sonda de reloj. Los dos registros, **con el par en banda en los dos casos**
—que es exactamente la firma de la tautología—:

```
SIN MUTAR  cal_a=1956 cal_b=995   disc_param=185614 disc_obs=4150    disc_estado=suelo
MUTADA     cal_a=1919 cal_b=1010  disc_param=181159 disc_obs=181159  disc_estado=ok
```

Veredicto del juez real — **fail-before:** *«'reloj' publica `disc_estado=ok` sobre un sujeto que el juez
cronometró en 7077µs, por debajo del suelo de 50000µs: **quien no mide no puede saber que está bajo el
suelo**»*. **pass-after:** `PASS (disc_param=175361 · disc_obs=4267 · testigo del juez=7348)`. Y por
`CA-03` punto 5, con la sonda mutada la **corrida entera** sale `rc=1` con **5 FAIL**.

**Dos caminos distintos a propósito:** la magnitud publicada sale del registro de envoltorios y el
testigo lo **cuenta el juez** sobre un archivo que él crea vacío — contarlo sobre el mismo registro
haría que testigo y magnitud tuvieran **el mismo origen**, que es lo que `(a.3)` prohíbe. Y la
**anti-vacuidad se materializa como FAIL nombrado**, no como `ABORT:` del corredor: *un guardián que
tumba la vuelta por una condición de vacuidad* es la lección de `CA-07.4`, aprendida hace dos horas.

**No hay dos criterios contradiciéndose.** Rehecha la cuenta de `(iii)`: `1+2+1+1 = 5` más el discordante
—que por diseño cuesta **menos de una unidad**— **≤ 6**. Medido: reloj **2,7–3,3×**, procesos **3,7×**
contra 6. Cabe sin deformar nada, que es lo que la vuelta pasada se compró indebidamente.

**Las tres palancas de `(d)` usadas y declaradas, ninguna prohibida:** series **intercaladas** en la
calibración —y ahí apareció que **no había identidad de camino**: la calibración recorría `sr_minimo`
mientras la medición de una razón recorre `sr_intercala`, y es donde estaba la varianza (1,217 en bloque
vs 1,012 intercalado)—; `r` de 3 a 5, la palanca gratis; y margen sobre el suelo de **1,4× a 4×**,
derivado en la corrida. Con un efecto lateral medido: el sondeo va primero, así que **calienta** — el
`cal_a=1,093` que QA vio en frío era la primera serie pagando páginas dentro del numerador. **La banda no
se ensanchó y el sujeto no se encogió.**

Más: `QA-021-04` (parser sin word-splitting **ni glob**, clave repetida → ilegible), `QA-021-05` (barrido
por **marca de entorno**, que sobrevive a la reparentación **y** al cambio de sesión — verificado en las
tres formas, `vivos=1` y **0 supervivientes**, donde el grupo sólo cazaría dos), `QA-021-07`
(`procesos=no-aplica` en vez de contar con el oráculo del núcleo: `QA-021-03` ya obligó a retirar una
cifra por meter ruido de sistema en un campo publicado), `vivos` en el juez con sus tres ramas, y
`sonda_emisor_conocido()` fail-closed.

### Un hueco contrato↔código que NO resolvió, y bien hecho

**`37/1` y `37/2` no llaman a `sonda_usable` ni una vez** (`grep -c` → 0 y 0; en la 38, 14). Publican
razones leyendo el registro con `sonda_lee` directo. **Medido:** con la sonda de reloj mutada, la 38 sale
roja pero **`37/1` y `37/2` publican sus razones como PASS** con la procedencia de la calibración
**desmentida en la misma corrida**. `CA-03` punto 5 dice que esa medición **no es publicable**. Es la
misma clase que `QA-021-02`, un consumidor más arriba.

**No lo tocó**, y el motivo es el correcto: no está en sus diez puntos, cablearlo convierte PASS en FAIL
en casos de REQ-017 —superficie ajena— y *es exactamente la decisión unilateral que quemó la vuelta
pasada*. Queda para enrutar.

**Y una carrera del banco que sí arregló, porque era suya:** el caso `CA-04.4` contaba sobre el temporal
**compartido** que `37/2` usa con la misma sonda, así que veía directorios de **otra invocación viva** y
salía rojo sin que nada estuviera roto. *Es la clase de REQ-015 entrando por el lector.*

**`REQ-017 CA-03` fail-before es flaky, y no es suyo:** cuatro corridas del mismo árbol dan `3,878 ·
3,791 · 2,508 · 3,316` contra un techo de `2,600×` — **con la máquina cargada falla**. Misma clase que
`QA-021-06`, otro criterio y otro dueño. Verificó que su cambio no puede causarlo (modos idénticos).

### `CA-18` empeora, y ahora son tres archivos

| | antes | ahora | límite |
|---|---|---|---|
| `37-…-1-escala.sh` | 751 | **841** | 400 |
| `37-…-2-la-seccion-caliente.sh` | 614 | **674** | 400 |
| `38-sondas-compartidas.sh` | 400 | **722** | 400 |

Deshacer la mudanza devuelve líneas a las 37, y la 38 recibe el doble de casos. **No puede partir la 38**
porque un `39-*.sh` está fuera de su `Archivos:`.

**Banco: `rc=0 · 875 PASS · 0 FAIL · 5 SKIP`**, cuadre `880 = CASOS_ESPERADOS` y cuadre por archivo OK.
`CASOS_ESPERADOS` **873 → 880** y el de la 38 **21 → 28**, los dos **a mano**; los de las 37 **no
cambian**, como `CA-07.2` exige. Los cinco SKIP con su motivo en su línea. Autoprueba **72 PASS · 1
FAIL**, y ese FAIL es `CA-18`.

### Error de la coordinadora: comiteó un borrado que no puso

El commit `64e88c8` —el de **REQ-019**— contiene el borrado de `tests/util/sonda-linea-base.sh`, que está
declarado en el `Archivos:` de **REQ-021** y no en el de REQ-019. **No fue la comisión de REQ-019: fue la
coordinadora.** El `git rm` del `desarrollador` dejó el borrado **preparado en el índice**, y el commit
posterior lo arrastró.

**La lección, y es una clase nueva:** *nombrar rutas en `git add` **no acota** lo que el commit contiene.*
El índice es **estado compartido**, y una comisión viva puede dejar cosas preparadas ahí. La regla que la
coordinadora adoptó hoy —«con comisiones vivas, rutas nombradas, nunca `-A`»— **se cumplió y no bastó**.
Lo que hace falta es `git commit -- <rutas>` o **mirar el índice antes de comitear**. Va a `REQ-025`.

*(Coincidió con lo que la comisión de REQ-021 pedía, así que no se perdió trabajo de nadie — por suerte,
no por diseño.)*

**Coste:** ~405 k de contexto, **de los cuales ~84 k son leer `REQ-021.md` entero**. Es un dato para
REQ-019: el documento que contrata el ahorro cuesta 84 k por comisión que lo lea.

## [GitHub] — 2026-09-08 · REQ-025 (borrador): el arnés vigila también a quien orquesta — el par discriminante y el denominador publicado
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

REQ nuevo, ventana **1.34.0**, `Rigor: critico`, por decisión del propietario tras catalogar **20
errores de la sesión coordinadora** en una jornada. La coordinadora —que orquesta, **acredita, decide y
publica**— es el único actor sobre el que no apunta ninguna puerta de contenido.

**`CA-04`, el criterio central: el par discriminante con inventario auto-anclado.** Cada pregunta que la
herramienta declara tiene en el banco un caso positivo *y* uno negativo; el negativo se obtiene
**mutando el fixture positivo en la única propiedad que la comprobación dice vigilar**, y **tiene que
nombrar el defecto inyectado** — `rc≠0` no basta, porque una comprobación que **siempre** falla también
«pasaría» un negativo que sólo mire el `rc`.

Ataca **la propiedad, no las cinco instancias**: lo que las une no es el descuido, es que **ninguna se
probó con el caso malo**, y una comprobación que sólo se prueba con el caso bueno **no distingue**.
Enumerarlas habría sido el defecto atacándose a sí mismo. Y es **auto-anclado**: el inventario de pares
se **deriva del sitio único** donde la herramienta enumera sus preguntas, así que **añadir una
comprobación sin par rompe el banco nombrando la que falta** — aplicando la lección de `CA-05` de
REQ-017, que una comprobación contra línea base congelada mide una vez y luego envejece **hacia el lado
que abre**. **La cardinalidad no se fija**: los 20 y los 5 van como **operativos**, con corrida,
dirección hacia abajo y la frase de que **menos no acredita nada**.

**`CA-05`, y es la línea más barata del REQ: se publica el denominador.** El caso medido —«8» donde eran
**5 de 8**— es un veredicto **sin población**, y *un veredicto sin denominador no se puede desmentir
leyéndolo*. La misma línea habría delatado los **7 falsos positivos** de la comprobación de ids. **Una
línea, dos de las cinco instancias muertas.**

**El reparto máquina / acreditable / disciplina va DENTRO del REQ (`CA-01`), con lo que cada nivel NO
promete.** Máquina: par discriminante, denominador, marca de procedencia — **propiedades léxicas o de
inventario**, y por eso una puerta puede decidirlas. Acreditable: que la afirmación sea **cierta**, por
un tercero que repite o muta, nunca por quien la escribió. Disciplina declarada: la lista previa al
despacho y el juicio de qué comprobación hace falta, con dueño.

`CA-01` dice **literalmente** que **ninguna puerta de este REQ detecta «esta cifra no la mediste»** —es
semántica, y §13 ya declara ese techo—; lo que sí se detecta es la **ausencia** de procedencia, que es
otra cosa. Y la consecuencia incómoda queda escrita y no disfrazada de puerta: la comprobación posterior
de `CA-08` es **de máquina pero su ejecución es ritual** — *si nadie la corre, no protege*.

**El libro de comisiones sirve, pero no como está, y se midió antes de diseñar.** Hoy registra
**duración sin instante**, y una duración **no permite calcular solape**. Peor: el **único** solape
registrado de todo el corpus vive como **prosa libre en una celda de Notas**, así que depende de que
alguien se acuerde. `CA-10` añade **instante de inicio y de fin**, con lo que «¿algo mide ahora mismo?»
pasa de memoria a **aritmética** — y cubre de paso «¿hay comisiones vivas?», la que faltaba antes del
`git add -A`. Con la lección de la premisa falsa dentro: *un encargo que afirma el estado del árbol lo
**deriva**, no lo recuerda.*

**`CA-11` contrata que la acreditación NO sea de la coordinadora**, con cuatro condiciones que ninguna
puede satisfacer ella: QA verifica los pares **mutando él** el sujeto con sus propios fixtures
—re-ejecutar los del desarrollador no acredita—; la comprobación de `CA-08` la corre **quien no escribió
la entrada**; y el auditor revisa **expresamente** si alguna de las tres quedó satisfecha por una
afirmación suya. **Residual declarado:** el libro que `CA-10` usa **lo escribe la coordinadora**;
mitigación por **cotejo** contra artefactos ajenos, y lo que queda fuera —una entrada completa y falsa—
es semántica, con dueño `auditor-seguridad` y vencimiento al cierre de 1.34.0.

**Un agujero medido y NO absorbido, que va como pregunta abierta:** `requirements/` **no está en
`codigo_app.globs`**, así que `guard-codigo` no cubre esos archivos y **la sesión coordinadora puede
escribir `QA: aprobado` en un REQ** sin que ninguna puerta lo impida (y `veredictos.exigir_fecha` está en
`false`, así que no hay fecha que cotejar). Es la concentración en su forma más pura, y `CA-11` sólo la
cubre **por procedimiento**. No se absorbió porque **un mecanismo nuevo en un hook es gate humano**.

**`Archivos:` con dos decisiones dichas por su nombre:** `run.sh` va dentro **aunque las secciones se
descubran por glob**, porque `CASOS_ESPERADOS=873` es un literal de `run.sh:1173` y omitirlo habría
fabricado un **`disjunto` falso**; y `docs/arnes/*.md` va declarado **de más a propósito**, porque no se
sabe aún dónde aterrizan §6 y §8 tras el reparto de REQ-019 — *bajo incertidumbre se elige el error
barato (colisión falsa) sobre el caro*. Colisiona con REQ-019, REQ-021 y REQ-022; escribir `AGENTS.md` lo
manda **en solitario**, y va **después** de los tres.

**Estimación: 5–8 h.** Y el grueso **no es el script**: es **el par negativo por pregunta**, que es
exactamente lo que las cinco sondas de la línea base se ahorraron.

## [GitHub] — 2026-09-08 · REQ-019 se amplía al README y pasa a 1.34.0 — y la premisa de la coordinadora era falsa: ninguna máquina del arnés lee ese documento
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Dos decisiones del propietario:** `Versión destino: 1.34.0` **como primer trabajo de la ventana** —el
campo **no existía**, y era un defecto en sí: la palanca que justificó partir la ventana no declaraba en
qué ventana estaba— y **ampliación de alcance a `requirements/README.md`**.

### Corrección: la coordinadora afirmó que las puertas leen el README. Es falso, y está medido

`tools/arnes-paralelo.sh:288` y `tools/arnes-lectura.sh:119` lo **saltan explícitamente**
(`case "$base" in README.md|readme.md) continue ;;`), y las dos apariciones en
`hooks/guard-completado.sh` (líneas 519 y 524) están **dentro de cadenas de mensaje**. Las puertas no
leen ese documento: **implementan** el mismo contrato en su código y en `.arnes/config.json`. El README
es la **segunda transcripción**, la legible.

**La premisa era falsa en la letra y verdadera en la consecuencia, y la diferencia importa.** Perder
texto allí **no apaga ninguna puerta**; rompe dos cosas que **no salen en el banco**: (1) **el camino de
remedio** —`guard-completado` deniega y manda a una sección concreta; si el contenido se fue, la
denegación pierde su remedio—; y (2) **el marcador de versión** de `skills/arnes-upgrade/SKILL.md`
(líneas 119-125), que usa **tres frases y nombres de sección del README** para **desmentir** la versión
de origen: su ausencia no da error, da **DESMENTIDO → UNKNOWN → la migración para**.

**Y el hallazgo útil: esos dos acoplamientos cuestan ≈0 bytes extra**, porque caen **dentro** del suelo
que el contrato de forma ya obliga a conservar. El acoplamiento con la máquina no encarece el reparto —
**convierte un error de juicio en un fallo silencioso**. Por eso va contratado (`CA-02.4`, `CA-15.iii`) y
no dejado en la predicción.

### El suelo cae encima del techo, y no se tocó ningún umbral

Suelo inamovible: **≈233 de 433 líneas (54 %)**, y en bytes **≈58–64 %** —las filas del Índice pesan muy
por encima de la media—. **`CA-07 (ii)` pide ≤ 60 %: el suelo estimado cae encima del techo.** El
analista **no escribió ningún techo nuevo**: se aplicó `CA-15` a sí misma —*cardinalidad medida, nunca
fijada*— y dejó la medición previa obligatoria de §CA-14 con la salida por firma del propietario ya
cableada. **Ahorro real por movimiento: ≈11 000–13 000 B (36–42 %)** — no el doblado que la coordinadora
anunció.

**Y el bloque más caro queda fuera con su motivo:** el `## Índice` son ≈6 000 B, el **19 %** del archivo,
y es **una copia a mano de lo que `tools/arnes-lectura.sh` ya deriva** —el propio documento lo dice—. Eso
no es un movimiento, es un **mecanismo**: otro dueño y toca `codigo_app.globs`. *El 19 % más caro del
documento no lo baja este REQ, y quien lo baje no necesita repartir nada.*

### La forma (a) aplicada al propio REQ, y corregida

Se **de-nombraron doce criterios**: donde decían `AGENTS.md` ahora dicen «cada documento en alcance», con
§«Documentos en alcance» como **sede única del conjunto**. Ésa es la corrección de fondo: **el REQ tenía
criterios que enumeraban su propio sujeto**, y por eso ampliar el alcance obligó a reescribir doce.

Extensiones reales, no cosméticas: **`CA-02.4`** (sub-universo del README por propiedad, con tres sitios
únicos: anclas citadas por mensajes, marcadores de versión de la skill, y contrato de forma de los
campos); **`CA-04`** —la extracción de encabezados **ignora los bloques vallados**, porque la plantilla
del REQ vive dentro de un fence con líneas `## ` y un `^## ` ingenuo devuelve **siete encabezados
fantasma**, declarando siete secciones eliminadas sobre un reparto correcto—; **`CA-11`** de una vía a
**tres**, y la nueva es la probable: *el arreglo natural cuando un analista «ya no encuentra las reglas»
es añadir el archivo delegado a `agents/analista-requerimientos.md`; no rompe ningún puntero, cumple
`CA-01` y `CA-03`, y **anula `CA-07` sin dejar rastro***; **`CA-15`** gana el universo (iii) con el
argumento de por qué aquí es más necesario —el README **no tiene** `🔒` ni tabla de §13, así que `CA-15`
no es un cinturón sobre `CA-02`: **es la única enumeración que existe**—.

### `CA-16` estaba escrito por ARCHIVO, y su justificación era falsa para el segundo sujeto

El `Entonces` era por propiedad, pero **el `Dado` nombraba `AGENTS.md`** y su justificación entera
también. Al reformularlo apareció que la premisa *«casi ninguna comisión lo escribe»* es cierta de
`AGENTS.md` y **falsa del README**: su `## Índice` lo actualiza **cada** comisión de analista. Se corrigió
en vez de borrarse — para el README la herramienta **sí** ve buena parte del riesgo; lo que sigue sin ver
son las comisiones de `desarrollador`, `qa-tester` y `auditor-seguridad`, que leen el documento entero y
**no lo declaran nunca**. *Un criterio cuya justificación es falsa para uno de sus dos sujetos es clase
`contrato` aunque su `Entonces` sea correcto.*

### `ADR-006`, decidido con el test que el propio REQ ya tenía escrito

El REQ dice que `CA-15` y `CA-16` no abren ADR «porque ninguno cambia el alcance ni la decisión base».
**Éste cambia el alcance**: un documento → dos, una plantilla divergente → dos. Cambio **DE FONDO** →
**`ADR-006`**, que **extiende y no supersede** a `ADR-003`, cuyos cuatro motivos se comprobaron **uno por
uno** contra el segundo documento y **aguantan todos**. Registra lo que `ADR-003` no podía pesar: el
**quinto motivo de migración** (adelgazar la plantilla del README obliga a **re-derivar y re-fechar** los
marcadores de `arnes-upgrade`); que en el par del README **la divergencia se crea entera en vez de
ampliarse** —los **18 encabezados coinciden uno a uno y en los mismos números de línea hasta la 350**,
desfase total **6 líneas** frente a **113** en `AGENTS.md`—; y que el 19 % del Índice queda fuera a
propósito.

**Estimación nueva: 7–11 h, cuatro fases, ≥5 comisiones.** Con tres notas de orquestación: las dos
enumeraciones de F1 **pueden ir en paralelo y salen mejor así** (`CA-15.2` exige no verse) pero **cada una
escribe su propio artefacto** o se pierde una por escritura perdida; F2 y F3 son **un solo cambio** para
`CA-05` y `CA-07`; y **F1 no necesita solitario**, que es lo que permite descubrir un techo insatisfacible
**sin haber parado a nadie**.

**`Archivos:` nuevo** con `+ requirements/README.md` y `docs/qa/1.33.0.md` → `docs/qa/1.34.0.md` —
retirado a propósito: el REQ ya no escribe en esa ventana y dejarlo pondría en serie, **sin motivo**, a
REQ-020 y al resto de 1.33.0.

## [GitHub] — 2026-09-08 · R-013: confirmado el bypass del campo comentado, y aparece uno peor — se pierde el gate humano escribiendo BIEN la aprobación
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `auditor-seguridad`.

**Investigación del guardián publicado, no auditoría de ningún REQ.** No se firmó nada. Medido
ejecutando el entrypoint real (`hooks/guard.sh`) con JSON de `PreToolUse`, control positivo y negativo en
cada tanda, fixtures fuera del repositorio. **23 filas con veredicto idéntico en la instalada 1.32.1 y en
la candidata** —`guard-completado.sh`, `campos-req.awk`, `guard.sh` y `hooks.json` byte a byte iguales;
`lib.sh` difiere en **una** línea—: **nada que atribuir a 1.33.0**.

**Confirmada la hipótesis que el analista de REQ-023 dejó sin ejecutar:** un `<!-- Sensible a seguridad:
sí -->` junto a `Rigor: ligero` **cierra a `completado` un REQ con `QA: pendiente` y `Seguridad:
pendiente` escritos a la vista**, en silencio total — ni deny, ni `systemMessage`, ni aviso de
vocabulario. Dos variantes nuevas: `<!-- Rigor: critico -->` y `<!-- QA: pendiente -->`.

**Pero la hipótesis en sí NO es defecto nuevo**, y el auditor lo probó con un control de equivalencia
—comentar y borrar dan el **mismo** ALLOW—: es `REQ-016 CA-11` funcionando como se contrató, más la
decisión que él firmó en `R-009`. **No abrió `SEC` para ella.** Alcance, sin exagerarlo: ese `ligero` no
salta la clase del hallazgo, ni las quality gates, ni la cola.

**La clase, contratable:** *un campo de la cabecera cuya **ausencia** la puerta resuelve del lado que
**abre** queda satisfecho haciendo desaparecer su línea, **por cualquier vía** —carácter invisible, rango
de comentario, borrado—; la vía no cambia el veredicto, porque la puerta no mide la vía, mide la
ausencia.* Se cumple en **cuatro** de los seis campos; la única que cierra es `Seguridad:` en `critico`.

### `SEC-050` — `contrato`, alta

Tres cosas que **ningún documento dice**: (1) la superficie son **cuatro** campos y los tres textos que
la describen nombran **dos** —incluida **la propia remediación de `SEC-047` del auditor**, que se aplica
a sí mismo la prohibición de enumerar—; (2) **el puntero «un solo sitio» de `CA-11` es falso para el
campo que más pesa**: manda a `guard-completado.sh` y la regla del suelo de rigor vive en `hooks/lib.sh`,
así que quien audite siguiendo el contrato concluirá que el suelo está a salvo; (3) la variante `<!--
Rigor: critico -->` **desmiente una promesa sin condición** de §6/§13 — aquí lo tapa la política de
autoalojamiento, **en los proyectos consumidores no**.

### `SEC-051` — `instrumento`, alta, independiente, y peor

`arnes_cola_pendientes` (`hooks/lib.sh:1161-1162`) descarta la **línea completa** que contenga `<!--` o
`-->` **en cualquier posición**, con un `continue` **incondicional**:

| Entrada bajo `## Pendientes` | cola | Puerta |
|---|---|---|
| `### Fusionar el PR a main` — control | **1** | **DENY** |
| `### Fusionar el PR a main <!-- pedido a Juan el 8/9 -->` | **0** | **ALLOW** |
| `### Migrar A --> B` — **sin comentario ninguno** | **0** | **ALLOW** |
| `<!-- Nota` sin cerrar + 2 entradas reales detrás | **0**, `rc=0` | **ALLOW** |

**Se pierde el gate humano sin acto deliberado: escribiendo BIEN la aprobación.** Y los **tres** canales
de observabilidad coinciden en el número equivocado —`arnes-lectura.sh` añade «*Ningún valor anómalo*»—:
la propiedad de «una sola regla» de `REQ-009` **se cumple y propaga el error**. *Consistencia no es
corrección.* La asimetría que prueba que es defecto y no decisión: **en la cabecera un rango sin cerrar
DENIEGA; en la cola cuenta cero en silencio.**

**Latente:** barridos **133 blobs únicos** de `requirements/*.md` (136 commits, 24 rutas) y los **4** de
`PENDING_APPROVAL.md`, con control positivo del barrido: **cero comentarios en cabecera**, ningún cierre
pasado contaminado.

**`SEC-045` y la custodia no cambian, y el motivo es bueno:** `SEC-051` existe porque al banco le **falta
un caso**, y **custodia y completitud son ortogonales** — un guardián sobre `secciones/` habría impedido
*debilitar* un caso, no *escribir* el que nunca existió. Es evidencia **a favor** del alcance estrecho
que eligió el propietario.

**Inventario verificado `SEC-001`…`SEC-051`, monótono y sin huecos.**

## [GitHub] — 2026-09-08 · Write-back de R-010 en REQ-019: el criterio de inventario de invariantes NO existía, y el universo lo cerraba quien se beneficiaba de dejarlo corto
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Cierran `SEC-031`, `SEC-032` y `SEC-034`**, verificados remediación por remediación contra el texto del
REQ. **`SEC-033` NO cierra**, y el motivo está medido y no supuesto: su remediación 3 es una edición de
`ADR-003`, cuyo dueño es el `desarrollador`, y ese archivo conserva hoy la formulación de **una sola
dirección** (línea 60), el «**CA-05 lo detectará el día que ocurra**» (línea 68) y el rango cerrado
«criterios **CA-01 a CA-13**» (línea 122). Mientras el ADR diga eso, la mitad de la ubicación del
hallazgo sigue diciendo algo falso. `Hallazgos abiertos:` pasa de cuatro a **`SEC-033 (contrato)`**.

### `CA-15` — el criterio de inventario de invariantes no existía, y el hueco tenía forma precisa

`CA-01` **inventariaba texto, no invariantes**. `CA-02` sí enumera, pero **su universo son dos
marcadores** (las filas de §13 y los bloques `🔒`), así que una obligación en prosa fuera de ellos —el
tope de vueltas de §6, «secretos sólo en variables de entorno» de §10, las reglas del CHANGELOG de §8—
**no pertenecía a ningún conjunto enumerado**. Y la tabla de `CA-13` tiene una fila por bloque
**retirado**, así que una invariante que **se queda** no aparece nunca en ella.

La propiedad entera se sostenía sobre los señalamientos de `CA-14` en **un universo que nadie cerraba
antes del reparto** — y lo cerraba, **mientras repartía**, el agente al que le abarataba dejarlo corto.
Es `SEC-032` aplicado a la propiedad entera: `CA-13` puso terceros ojos en las **preguntas**, no en el
**universo**.

`CA-15` contrata: inventario **cerrado y publicado antes de mover un byte**, sitio único anexo a
`ADR-003`, universo **por propiedad**, **no menos de 2 enumeraciones independientes y sin verse**
—una puede ser de quien reparte, la otra no—, universo por **unión** con reconciliación escrita, **un
señalamiento por elemento** (`no más de 0 sin señalar`, de contrato), **trinquete** (crece libre;
decrecer exige Historial y visto bueno del enumerador independiente), y borde que **no aprueba** si no se
puede producir o cuadrar. **Cardinalidad medida, nunca fijada** — fijarla habría sido la forma (b).

Con dos cosas escritas por lo aprendido hoy: el universo **se re-deriva en la misma edición** que cambie
`CA-14`, `CA-01` o `CA-02`; y **se declara la clase de la comprobación** —acreditación única, no puerta—
porque no declararla es literalmente el defecto que `SEC-033` acaba de medir en `CA-05`.

### `CA-16` — el riesgo del sustrato de lectura no estaba contratado

El REQ sólo contrataba serie respecto de quien **escribe** `AGENTS.md`, que es lo que
`tools/arnes-paralelo.sh` mide. **El riesgo es de quien LEE.** Ahora: cero comisiones ajenas solapadas
durante el reparto (de contrato), acreditado por el libro de comisiones de `docs/qa/1.33.0.md`, con borde
que no aprueba si el libro no registra la ventana. **Escrito como propiedad y no como instrucción de
despacho**, por la misma razón que el REQ ya usa con `SEC-030`: *un orden vive en la cabeza de quien
despacha*.

Más: **`CA-05` punto 6** — la corrección contratada del rango «CA-01 a CA-13» **no es actualizarlo**, es
**retirarlo** y citar el REQ como sitio único: mata la clase, no la instancia. Y en `CA-14`, el
**suelo forzado se mide antes de repartir**: si ya excede el techo de `0,60×`, es insatisfacible por
construcción y se sabe a coste de **una medición**, no de una vuelta sobre el reparto entero. *(El
`0,60×` de `CA-07` no se derivó del suelo que `CA-02` obliga a conservar — la misma trampa que hoy costó
dos vueltas en REQ-021. No se tocó: subirlo exige firma del propietario.)*

**Sin ADR nuevo, con motivo:** ni `CA-15` ni `CA-16` cambian el alcance ni la decisión base de `ADR-003`.
**Y sin NFR nuevo**, también con motivo: los cuatro hallazgos son defectos de **formulación de criterio**,
no umbrales de sistema, y el único NFR cuantificable ya vive en `CA-07` — inventar uno habría creado una
**segunda sede del mismo umbral**.

**Una cifra que el analista se NEGÓ a escribir:** el «cinco veces» que la coordinadora le pasó en el
encargo. No pudo verificarlo, y las cuatro citas del registro (`SEC-015`, `023`, `025`, `030`) son de
**otra clase** —la acotación que envejece, no la acreditación por lectura—. `CA-15` enuncia la propiedad
**sin número**. Es la tercera cifra sin respaldo que un agente devuelve a la coordinadora hoy.

### Y la observación que más incomoda

**El REQ que existe para retirar el impuesto fijo es hoy uno de los documentos más caros del
repositorio.** La entrada obligatoria del desarrollador antes de su primera acción: `AGENTS.md` (~9 k,
medido) + REQ-019 —que **acaba de crecer un ~26 %** y ronda 14–16 k— + `requirements/README.md` (~7 k) +
`ADR-003` (~4 k) ≈ **33–36 k sólo para arrancar**, y los paga enteros.

**Estimación nueva: 500 k – 900 k tokens y 3–5 h de reloj, y NO cabe en una sola comisión** con fidelidad
verbatim —agotar el contexto a mitad del reparto deja `AGENTS.md` inconsistente, y lo lee todo el mundo—.
Reparto propuesto en cinco fases, con tres avisos: **`CA-15` obliga a una comisión de analista NUEVA
antes del desarrollador** (el precio de la independencia del universo, dicho en vez de disimulado);
**`CA-16` detiene la ventana durante dos de las fases**, y ese reloj entra íntegro en la ruta crítica; y
**`CA-06` tiene una tensión de rol** —el write-back de REQ ajenos es trabajo de analista por §5/§9, no de
desarrollador— cuyo endurecimiento es **decisión del propietario**, porque reduce lo delegable y con ello
el ahorro.

## [GitHub] — 2026-09-08 · REQ-021 reduce alcance: sale `sonda-linea-base.sh`, y lo que la reducción deja descubierto se escribe sin endulzar
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Decisión del propietario:** `sonda-linea-base.sh` **sale del alcance**; sólo se mudan a `tests/util/`
la sonda de reloj y la de procesos. **Es la cláusula que el contrato ya tenía pre-decidida** —*«si (i.1)
o (ii) no caben, no se sube el techo, se reduce el alcance»*—, así que ejercerla es **cumplir** el
contrato, no cambiarlo. Y esa sonda era la causa de los tres problemas más duros **a la vez**: la
calibración tautológica de `QA-021-01`, los 21 procesos que hicieron insatisfacible `CA-08 (i)` y el `+6`
de `(i.2)` con los internos de `git`.

**Sin ADR nuevo, y con la condición que lo desmentiría escrita**, para que no sea coartada reutilizable:
*si `ADR-005` ya existiera, esto sería ADR nuevo, sin discusión.* Los tres motivos: no hay a qué suceder
—un ADR que supersede a un archivo que nadie ha escrito es contabilidad, no registro—; las dos
decisiones base no cambian; y la salida estaba escrita **antes** de medir. `ADR-005` amplía mandato con
`(i)`…`(l)`, incluido **lo que la reducción deja descubierto**, porque *un ADR que registra una reducción
sin su residual documenta un alivio, no una decisión*.

**Reparto de criterios, y dos que se salvaron por poco:**

- **`CA-05` se queda**, gobernando la versión inline, con el sujeto reescrito: «el **materializador de
  línea base**, **donde viva**». **El criterio se enuncia sobre la función, no sobre un archivo**, así
  que la reducción no lo deroga. Hereda formato y parser único; **no** hereda `CA-03` ni `CA-09`. Y
  resuelve `DEV-021-08` dentro: el bit pasa a ser **el modo del objeto en el árbol**.
- **`CA-08 (0)` se queda y se refuerza**, dicho por su nombre **porque era lo más fácil de perder**:
  exige una **propiedad del resultado**, no un instrumento. **`H-08` sigue cerrado en el criterio.**
- **`CA-07` punto 4: la materialización SALE del guardián de segunda sede.** Sin eso, la reducción deja
  el banco **abortando la vuelta entera** sobre `mat37`/`mat47` —medido: hoy los **acusa** como control
  positivo—. *Un guardián que acusa la única sede que hay es la forma (a) al revés.*
- **`CA-10` punto 2** corregido: `vivos` obligatorio **en el registro de un instrumento de
  `tests/util/`**, enunciado sobre **el emisor** y no sobre el formato — exigir un campo a quien no puede
  observarlo es un **FAIL garantizado**, la clase de criterio insatisfacible que este REQ ya pagó dos
  veces.
- **`CA-03` entera, sin una coma menos**, aplicada a las dos sondas: **la tautología es una clase, no un
  defecto de esa sonda**. Con la observación de por qué era estructuralmente posible justo ahí: en las
  dos que quedan la magnitud observada **ya es una medición**; la que sale era la única cuyo número **es
  un recuento de cosas que el llamante eligió**.

### `AN-021-01` — lo que la reducción deja descubierto, sin endulzar

`instrumento`, dueños `desarrollador` + `analista-requerimientos`, ventana **1.34.0**. Cuatro cosas:
(1) el materializador queda **sin calibración de ninguna clase** —mejora porque una tautología es un
verde falso, empeora porque **nada acredita que responda al sujeto**—; (2) `mat37` y `mat47` siguen
siendo **dos copias literales** y la duplicación era **uno de los forzadores del REQ**; (3) la clase
«línea base a medias» queda sin instrumento compartido, así que parte del forzador de ~150 k/ventana
**no se cierra**; (4) **si algún día se muda, vuelve con su tautología intacta**, y quien la mude paga
primero ese write-back.

### `QA-021-01` cierra, y el efecto real se dice sin adornos

Cierra porque su segundo motivo desapareció —el propietario decidió **custodiar**— y porque **la
instancia concreta sale del árbol con la sonda**. Pero: *el campo queda sin ningún hallazgo bloqueante
por clase, y **la puerta sigue cerrada igual** — `QA: con-hallazgos` y `Seguridad: preventiva` sobre un
`Rigor: critico` la cierran. Cerrarlo no adelanta nada; sólo deja de mentir sobre por qué está cerrada.*
También cierra **`DEV-021-08`**.

**Residual: de tres instrumentos a dos, y MÁS motivado.** Vence **antes de `completado`**, ahora con dos
razones: un forzador ya ejercido y fallado no se vuelve a aplazar, y **hasta 1.34.0 no hay custodio**, así
que en esta ventana el sustituto **es la única capa**. Queda escrito lo medido a favor —el `qa-tester`
mutó los dos que quedan y el juez cazó las dos; el instrumento que reventó el sustituto **es exactamente
el que se va**— y por qué **no** descarga el residual: *dos mutaciones que aciertan no acreditan la
propiedad*, que es la forma (a) a nuestro favor, y es cuando más tienta darla por buena.

**Estimación nueva: ≈150–250 k tokens y 1,5–2,5 h** (antes 250–400 k / 2–3 h), y **entra en una vuelta**.
El riesgo está en dos sitios, los dos nombrados, y con una buena noticia de método: **la escalera de
salida de `CA-03 (d)` está escrita y ordenada** —subir `r` → subir el margen sobre el suelo → cambiar el
sujeto → sacarla de la puerta—, y **las tres primeras el desarrollador las aplica sin pasar por el
analista**, así que `(d)` fallando **no cuesta una vuelta**. `r` es la palanca gratis: **`(iii)` es
invariante a `r`**.

## [GitHub] — 2026-09-08 · Write-back de la QA de REQ-021: el techo estaba mal derivado y el desarrollador compró el encaje deformando el sujeto
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**`CA-03` gana la propiedad que faltaba, y con su mordida.** (a.1) **procedencia observada**: cada
entrada del factor es una magnitud que la sonda **observa después de ejercer el sujeto**, y **un factor
que se pueda calcular sin ejercer el sujeto INCUMPLE**. (a.2) la **mitad discordante**, que es lo que lo
hace exigible: la procedencia **no se lee en el registro** —la sonda honesta y la tautológica publican el
mismo número—, así que la calibración ejerce una entrada cuya magnitud observada **difiere del
parámetro** y que el juez conoce **sin la sonda**, y contrasta la **magnitud publicada** contra un
**testigo propio**. (a.3) anti-vacuidad: aborta si el testigo coincide con el parámetro o si **lo produce
la propia sonda**, y la copia sin mutar tiene que pasar donde la mutada falla.

**La tensión `CA-03` ↔ `CA-08 (iii)` se rompió por el techo, y la causa raíz es peor que el síntoma.** El
`4` decía derivarse de «lo que CA-03 contrata — cuatro ejercicios del sujeto», contando cuatro ejercicios
**iguales** cuando uno cuesta **el doble por construcción**: la suma del mismo contrato es `1+2+1+1 = 5`,
y con la mitad discordante **6**. **El desarrollador hizo esa cuenta, vio que `5 > 4`, y en vez de
escalar la contradicción compró el encaje deformando el sujeto** —insensible a `N/4` ≈ 72 ms, **1,4× el
suelo**, donde domina el planificador—. De ahí los 5 de 30 fuera de banda.

`(iii)` pasa de **4× a 6×** con la suma **término a término** escrita, y dos reglas nuevas: *un techo
derivado de otro criterio se **re-deriva en la misma edición** que cambia ese criterio* —misma clase que
`DEV-021-05`, que pasa a tener **dos** instancias medidas— y *el techo **no se compra deformando el
sujeto***.

Más: **`CA-03 (c)`** deriva el tamaño de cada mitad **del suelo medido en la corrida** y un env sólo
puede **subirlo** —lo que cierra también el «máquina más rápida → `suelo` → banco rojo»—; y **`CA-03
(d)`** exige **0** veredictos fuera de banda en **≥ 30** corridas y ≥ 2 regímenes, con el motivo dentro
del criterio: *5 de cada 30 no es estricto, es inservible, porque el primer rojo espurio enseña a
re-correr el CI*. **No se ensanchó la banda** ni se sacó la calibración de la corrida, y la salida
pre-decidida queda ordenada, con un hallazgo útil de paso: **`(iii)` es invariante a `r`**, porque
numerador y denominador llevan los mismos mandos.

### El residual: la frase no se borra, se marca DESMENTIDA

«Una sonda alterada no da verde» queda **citada y marcada `DESMENTIDA EJECUTANDO el 2026-09-08`** con su
evidencia, en tres sitios del REQ. **Residual nuevo**, porque un forzador ya ejercido y fallado no se
vuelve a aplazar: re-acreditación **sobre los tres instrumentos**, por mutación **de quien no escribió
la sonda**, con **vencimiento antes de que el REQ pase a `completado`**. Y la lección estructural: *quien
escribe el instrumento muta lo que se imagina* — el autor acreditó **1 de 3** y tituló «demostrado en vez
de prometido»; el tercero rompió otro **a la primera**.

**Corregido además un párrafo que habría nacido falso:** el REQ mandaba a `ADR-005` registrar «la
decisión de no proteger con su sustituto». Escrito así, **el ADR nacería afirmando un argumento medido
falso**. `ADR-005` amplía mandato con el desmentido, la procedencia observada, que una acreditación del
autor sobre 1 de 3 instrumentos no acredita el mecanismo, y el techo que se re-deriva.

### Decisión del propietario, y coincide con la recomendación del analista

**`tests/util/*` entra en `codigo_app.globs`; `tests/` entero, NO.** El motivo que lo desbloquea no
estaba en R-012: **la mutación de un tercero no necesita escribir la ruta protegida** —QA la hizo sobre
una **copia fuera del árbol**, y `guard-codigo` deniega ediciones del glob, no copias—, y las
**secciones** que escribe el `qa-tester` quedan fuera del glob. Así que custodiar los instrumentos **no
le quita oficio al QA**, que era la objeción. Lo que **no** se hace, y queda nombrado sin recomendar:
custodiar **el examen** exigiría alcanzar `run.sh`, y eso sí se lo quitaría. Ventana **1.34.0**: la cola
humana decide **cuándo**, no **si**.

Y una consecuencia honesta que estaba prometida y era falsa: sacar la expectativa al juez **no crea un
custodio**, porque `run.sh` tampoco está en `codigo_app.globs`. Sube el coste del descuido; nada más.

### Qué cierra

`QA-021-02`, `QA-021-03` y `DEV-021-11` **cerrados** — este último porque `CA-07.2` pasa de **igualdad** a
**techo con dirección** (`SKIP → PASS` es conforme **por nombre**), con identidad sólo sobre casos
**deterministas** y el conjunto de excluidos **derivado de ≥4 corridas y publicado**. `DEV-021-10`
**cerrado por absorción** en `QA-021-06`.

**`QA-021-01` sigue ABIERTO y sigue `contrato`, a propósito.** La mitad del analista está hecha, pero
cerrarlo dejaría pasar el REQ apoyado en un criterio **que nadie ha implementado** y con la decisión de
gobernanza vigente **por silencio**. Fail-closed deliberado: `guard-completado` deniega el cierre, y eso
es lo correcto.

## [GitHub] — 2026-09-08 · QA de REQ-021: `con-hallazgos`, y DOS cifras que esta bitácora publicó como medidas se RETIRAN
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**Veredicto `QA: con-hallazgos`, vuelta 0 de 3.** Nueve hallazgos nuevos, **tres `contrato`**. Tres
criterios FALLAN (`CA-01`, `CA-04`, `CA-06`, `CA-10`), uno es **FLAKY** (`CA-03`) y `CA-08` sale **no
concluyente** en tres de sus cuatro mitades. Banco **870/0/3, rc 0, 49,5 s**; las tres quality gates de
§7 en verde.

### Retractación 1 — «los factores salieron EXACTOS» era la firma de una tautología, no de un sujeto bueno

La entrada de esta bitácora del 2026-09-07 sobre la implementación de REQ-021 dice que en la sonda de
procesos y la de línea base «los factores salieron **exactos** (2,000 y 1,000) en todas las corridas», y
lo presenta como evidencia de un sujeto de calibración **bueno**. **Es lo contrario, y está medido**
(`QA-021-01`, `contrato`):

Una `sonda-linea-base.sh` **mutada, que no materializa ni verifica nada**, publica `cal_a=2000
cal_b=1000` y **el juez real dice `PASS`**, con el mismo texto que la original. El factor sale de
`SLB_ARCHIVOS_EJ`, que en la mitad sensible **es el parámetro**: `2N/N = 2000` **por aritmética**, haga
la sonda algo o nada. **Un número que no puede salir mal no está midiendo nada**, y una exactitud
perfecta en un instrumento sujeto a ruido debió leerse como sospecha, no como calidad.

**Y lo que eso desmiente no es un criterio, es una decisión de gobernanza.** El sustituto con el que se
justificó **no poner `tests/` en `codigo_app.globs`** —«acreditar la medida en vez de custodiar el
instrumento», `ADR-005`, residual `SEC-045` del auditor— descansa en que *una sonda alterada no da
verde*. Se ejerció su forzador **antes de su vencimiento** y **no aguantó**.

### Retractación 2 — el `−56` de CA-08 (i.1) no es una medición: cabe dentro del ruido

La misma entrada publica **«(i.1) −56 procesos añadidos»** con su operación al lado. `QA-021-03`
(`contrato`) mide que **el suelo del oráculo se calibró mal**: se declaró **0 forks (12/12)** tomando dos
lecturas **seguidas** de `/proc/stat`, y se aplicó a ventanas de **~50 s**, donde el suelo en reposo es
**184 · 225 · 246 · 247** forks. Con una amplitud de ruido de ~63, un delta de 56 **no se distingue de
cero**: por `CA-06.5` corresponde **rango observado**, nunca un valor.

**La calibración del oráculo midió la magnitud correcta sobre la ventana equivocada.** Es la forma (d), y
van tres hoy.

### Los otros hallazgos

- **`QA-021-02` (`contrato`)** — `CA-04` habla del «`vivos=<n>` publicado **que el juez lee por CA-10**»,
  y `sonda_usable` **no lo lee**. Su único lector es el caso dedicado de la sección 38.
- **`QA-021-04`** (alta) — la puerta de `CA-10` se evade por espacio, por **expansión de glob desde el
  `cwd`** y por clave repetida.
- **`QA-021-05`** (alta) — un descendiente **reparentado** sobrevive con `vivos=0 estado=ok`. Tres formas,
  una con `ppid=850`.
- **`QA-021-06`** (alta) — **`CA-03` es flaky**: `cal_a` **1,093–2,444** y `cal_b` **0,757–1,385** en 30
  corridas, **5 fuera de banda y 2 de ellas en reposo**. Y cada fallo **pone en rojo la puerta requerida
  de `main`** — verificado end-to-end: 3 FAIL, rc 1. **No se ensanchó la banda**: por `CA-03 (a)` vuelve
  como «se cambia el sujeto». Causa de fondo: el insensible se fijó a `N/4` **para caber en `CA-08
  (iii)`** — dos criterios del mismo REQ en tensión.
- **`QA-021-07`** (media) — **`SR_PROCS` nunca se incrementa**, así que el `procesos=` de la sonda de
  reloj es siempre 0: **121 forks reales** contra `procesos=0`. Y `CA-08 (iii)` en procesos es **0/0
  presentado como `0.000×`**.
- **`QA-021-08`**, **`QA-021-09`** (bajas).

### Dos reclasificaciones de los hallazgos del desarrollador

- **`DEV-021-11` pasa de `instrumento` a `contrato`.** `CA-07.2` dice «ningún caso **cambia de
  veredicto**» **sin condición**, y uno cambió (medido: `37/1` pasó de `12 PASS·1 SKIP` a `13 PASS·0
  SKIP`). Un criterio insatisfacible por construcción es exactamente la forma por la que
  `DEV-021-01`…`04` fueron `contrato`. Y además describe sólo `PASS→SKIP` cuando lo ocurrido fue
  `SKIP→PASS`.
- **`DEV-021-10`**: clase correcta, **magnitud subestimada** y dueño equivocado. Lo absorbe `QA-021-06`.

`DEV-021-05`, `07`, `08` y `09` **bien clasificados**, y el `09` **confirmado ejecutando**: con
`ARNES_SONDA_PLAZO=2`, un `--sujeto 'sleep 30'` deja la sonda viva a los 12 s.

### Lo que sí quedó acreditado

`CA-07.1`: **828 líneas idénticas byte a byte** contra un **worktree** de `794fa4c`, `diff` vacío.
`CA-02`, `CA-05` y `CA-09` **pasan**. Los **3 SKIP** del banco son **todos por diseño** y ninguno por
avería: uno de plataforma (`cygpath`/Windows) y dos de `REQ-017 CA-05` con la palanca
`ARNES_COSTE_RUTA_CRITICA` apagada, con el motivo en la propia línea. **`DEV-021-07` es el único rojo**
(`grep -c '^ABORT'` = 0 en las dos corridas).

**Dato incómodo:** la sección 38 mide **exactamente 400 líneas**, justo en el límite de `CA-18`.

**Y una advertencia del propio QA sobre el método de la coordinadora:** el árbol se movió a mitad de su
comisión (`3511929` → `721cb71`, el borrador de REQ-023). Comprobó que ese commit sólo toca `CHANGELOG.md`
y `requirements/REQ-023.md` y que esa comisión **no mide**, así que sus números siguen válidos — **pero
si hubiera medido, se habrían invalidado en silencio**. Es la segunda dimensión de la colisión de
despacho (la máquina) y esta vez salió gratis por suerte, no por diseño.

**Coste:** ~190 k tokens.

## [GitHub] — 2026-09-08 · REQ-023 (borrador): el carácter invisible, enunciado por ESTADO y con un criterio redactado para que una lista de prohibidos lo incumpla
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**REQ nuevo para `SEC-047`**, por decisión del propietario de meterlo en 1.33.0. `Rigor: critico`,
`Sensible a seguridad: sí`, `Estado: borrador`.

**El criterio central se enuncia por estado, no por carácter.** `CA-01`: *si la cabecera declara un
campo en letra y el lector no lo resuelve como ese campo, la cabecera no se puede medir → DENY citando
la línea y el carácter en forma imprimible, y nunca allow por ausencia del campo que ese carácter
borró.* Con `CA-02` encima: la denegación es **por medibilidad y no por veredicto** —un REQ con todo en
verde deniega igual— y **resolverlo como ausencia incumple**, porque la ausencia es justo lo que la
puerta perdona.

**Y la pieza que impide que esto sea la sexta derrota de «ensanchar la lista» es `CA-03`:** el banco
ejerce tres familias declaradas **más una entrada reservada extraída al azar en cada corrida** del
complemento, publicada con su semilla. Está redactado **explícitamente para que una implementación por
lista de prohibidos lo incumpla**. Así la propiedad «envejece hacia el lado que cierra» queda contratada
de forma **observable**, sin dictar el código.

**Dos criterios que `SEC-047` no pedía, con motivo medido cada uno:**

- **`CA-05`, invariancia de locale.** La vía obvia para un conjunto positivo (`[:print:]`, `[A-Za-z]`)
  está **sujeta a colación**, y `hooks/lib.sh` ya explica por qué sus tablas se escriben con escapes de
  bytes. Una clasificación dependiente de `LC_CTYPE` **deniega en el CI de Linux y permite en
  Windows/MSYS** — que es justo de donde sale el BOM. Fail-open por entorno, invisible en la puerta
  requerida.
- **`CA-09 (iii)`, cociente de duplicación ≤ 2,2.** La forma natural de «comprobar cada carácter» en
  bash es un bucle con `${l:i:1}`, **cuadrático por construcción**: exactamente la regresión de 10× que
  REQ-017 acaba de pagar y que el `CA-08` de REQ-016 no vio **por medir la magnitud equivocada**. Las
  tres vías —forks, reloj y orden de crecimiento— van en **un solo criterio y una sola corrida**.

**`CA-04` es la mitad que decide si el arreglo sirve:** equivalencia campo a campo sobre el corpus del
banco *y* las cabeceras reales del árbol, con **anti-vacuidad** (aborta si el corpus no trae una cabecera
no-ASCII y una con clave decorada). Sin ella, un conjunto admitido estrecho convierte la guarda en una
prohibición de escribir en español.

### «La ausencia abre» va a REQ-024, y la coordinadora se equivocaba

La coordinadora lo leyó como «dos hallazgos en uno». **Son un defecto y una decisión**, y el analista lo
desmintió con la evidencia: que un campo ausente se perdone fue decidido **a propósito**
(`arnes_sens_efectiva`: «AUSENTE sigue siendo no, y eso no se toca»), está **contratado en REQ-016
CA-11** y **firmado en R-009**. Cambiarlo exige **ADR** y nota de migración, porque si la ausencia deja
de perdonarse, **todo REQ heredado de todo proyecto consumidor** que no declare el campo deja de cerrar.

Y la frontera entre las dos es **verificable, no cómoda**: lo que §13 promete —y el BOM falsifica— son
la fila del suelo de rigor y la de hallazgos, y **las dos hablan de un documento que declara el campo**.
Con BOM el documento lo declara y la puerta no lo impone: la fila es **falsa**. Sin el campo no hay `sí`
que imponga nada y la fila **no promete nada**. Cerrar REQ-023 restituye la verdad de las dos.

**Pregunta abierta con medición pendiente, no afirmación:** leyendo `arnes_rigor_efectivo` +
`arnes_sens_efectiva` + la rama `if [ "$rigor" != "ligero" ]`, un `<!-- Sensible a seguridad: sí -->`
junto a `Rigor: ligero` **parece** cerrar hoy con QA y Seguridad pendientes —comentar equivale a borrar
(REQ-016 CA-11, medido), sin `sí` no hay suelo, y `ligero` salta los dos veredictos—. **No se ejecutó, a
propósito**, para no falsear las sondas de reloj de la comisión de QA viva. Si se confirma, sube el
forzador de REQ-024; el reparto no depende de ello.

**`Archivos:` declarado de verdad y sin maquillar:** colisiona con REQ-021 (`run.sh`, el `README.md` del
banco), REQ-017 (+`hooks/lib.sh`), REQ-007 (+`guard-completado.sh`, `arnes-lectura.sh`), REQ-020 (su
glob `secciones/*.sh` cubre las tres secciones nuevas) y con casi todo vía `AGENTS.md`. **Implementación
en serie.** Dos omisiones deliberadas con motivo: los artefactos de gobierno, por REQ-016 H-05 —si se
declaran, cualquier par colisiona por una bitácora—; y `hooks/campos-req.awk`, porque `CA-06` exige que
la guarda sea **observacional** y no debería necesitar ni una línea allí: **si hay que tocarlo, es la
señal de que dejó de serlo**, y va como desviación declarada, no como cambio silencioso del campo.

**Estimación del analista:** ~250–350 k de desarrollo, **≈600–700 k con QA y auditor**, y predice **dónde
muere la primera vuelta**: `CA-04` o `CA-09 (iii)`, porque la implementación intuitiva falla una de las
dos **por construcción**. Los dos criterios existen para cazarlas antes de `main`.

## [GitHub] — 2026-09-08 · REQ-021: cuando la misma cifra se desmiente dos veces, lo que sobra es el número — el total ilustrado sale de CA-08
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Write-back de `DEV-021-06`, el único `contrato` que impedía cerrar REQ-021.** `CA-08 (i.2)` ilustraba
los procesos comprados con «hoy: 2»; medidos **6** (`sonda-linea-base.sh` 17 → 23), desglosados en **+1**
por CA-01.1 y **+5** por CA-05.1 — **1** del `git hash-object --stdin-paths` del lote y **~4 que ese
`git` gasta por dentro**. Corrida `ca08-1788843906`, árbol `794fa4c`.

**Y la decisión: el paréntesis se va.** El criterio pasa a acotar **las invocaciones compradas** —una de
la sonda por CA-01.1, una sola de `git hash-object` por lote por CA-05.1— y declara explícitamente que
**no** acota los procesos que cada invocación gasta por dentro. Tres motivos, y el segundo es el que
manda:

1. Es la forma **(b)** que REQ-012 proscribió, y **este mismo criterio la ha pagado dos veces en un
   día**: el `0` de `DEV-021-01` y el `2` de `DEV-021-06`.
2. **El número no es del sistema.** Cuatro de los seis son internos de `git`: no los elige el REQ ni
   quien lo implementa, y no se pueden bajar sin quitarle a CA-05.1 lo que verifica. Un total ilustrado
   quedaría desmentido **sin que nadie hubiera tocado el código** — y por eso tampoco resolvía nada
   fijar la versión de `git`: sería un contrato que caduca con un `apt upgrade` ajeno.
3. Era una **segunda transcripción** de una cifra cuya sede ya existía (el Historial), que es lo que
   **CA-01 punto 4** prohíbe por nombre. Y se desfasó exactamente como ese punto anuncia.

**Lo que NO se relajó:** el techo de 0 añadidos, la obligación de declarar el comprador de cada proceso
y el incumplimiento del proceso sin comprador siguen literales. Lo que sustituye al total es **más**
exigible: contar invocaciones es verificable y estable donde un total no lo era. Y la mordida
anti-cheque-en-blanco se conserva porque el conjunto de criterios compradores sigue **cerrado** — sin
marca de «no exhaustivo», porque si se abriera, «comprado» volvería a ser la coartada.

**Barrido de coherencia, extendido a propósito.** El mismo criterio llevaba otras cuatro cifras del
**prototipo** que la misma corrida desmiente; fijar sólo el `2` habría dejado `(i.2)` diciendo `+2` tres
líneas más abajo. Salen del **texto de criterio** las de `(i.1)` y `(iii)`, sustituidas por la propiedad
más el puntero; las de la prosa quedan **marcadas como del prototipo** y no se borran, porque son el
registro de por qué el número se re-derivó. Ningún techo, alcance ni dirección admitida se movió.

**`ADR-005` gana el punto (d) de su mandato:** *un criterio de coste acota las invocaciones que compra,
no los procesos internos de un programa de terceros.* Doctrina reutilizable, y por eso va al ADR y no al
criterio.

**`Hallazgos abiertos:` queda con seis, todos `instrumento`** — `DEV-021-05` … `DEV-021-11` menos el 06.
Ninguno bloquea. Y **`CA-07 punto 2 no se relajó** para hacerle sitio a `DEV-021-07`: esa congelación es
lo que hace acreditable la mudanza, y queda escrito en el REQ.

**Una observación abierta, no legislada:** el `+5` depende de los internos del `git` de esa corrida, y el
registro de condiciones (`bash=`, `nucleos=`, `carga=`, `arbol=`, `oraculo=`) **no captura la versión de
`git`**, así que esa cifra del Historial no es del todo reproducible en el sentido de CA-06.3. No se tocó
CA-06 —su conjunto exhaustivo de campos vive en el parser de `run.sh` y añadir uno sería alcance nuevo—;
queda como candidato para el desarrollador al implementar el parser.

## [GitHub] — 2026-09-07 · REQ-021 implementado: `tests/util/` con las tres sondas, el banco a 873 casos, y el nieto que cazó un `vivos=0` con la descendencia viva
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

**`tests/util/`**: `sonda-reloj.sh`, `sonda-procesos.sh`, `sonda-linea-base.sh` y su `README.md`.
Programas `100755` con un registro `clave=valor` de una línea por invocación, diagnóstico por stderr y
**ningún veredicto** — el juicio vive en `run.sh`, en sede única: un solo parser (`sonda_lee`), una sola
banda (`sonda_banda`), la puerta de CA-10 (`sonda_usable`) y la calibración **una vez por instrumento y
por corrida** antes del despacho. Sección nueva `38-sondas-compartidas.sh` con 21 casos;
`CASOS_ESPERADOS` **852 → 873**, los dos literales a mano. `PARED37` **se queda a propósito**: es
`SEC-030`, fuera del alcance declarado.

**Banco: `869–870 PASS · 0 FAIL · 3–4 SKIP` sobre 873, rc 0, ~51 s.** Las tres quality gates de §7 en
verde.

### El sujeto lineal que faltaba, y por qué el anterior no servía

CA-03 (a) exige un sujeto sensible de coste **realmente lineal**, y el candidato de la comisión anterior
—apilado de cadenas en bash— es **superlineal** (factores 2,048 y 2,566 donde el contrato pide 2). El
sustituto es un **bucle aritmético puro**, `for ((i=0;i<N;i++)); do :; done`: no reserva memoria, no hay
`realloc`, y duplicar N duplica el coste **por construcción**.

| | `cal_a` (esperado 2,000) | `cal_b` (esperado 1,000) |
|---|---|---|
| Máquina en reposo, 8 corridas | 1,916 – 2,065 | 0,924 – 1,009 |
| Con carga ajena, 8 corridas | 1,663 – 2,362 | 0,779 – 1,058 |

Banda en el juez: `a ∈ [1,600 · 2,400]`, `b ∈ [0,800 · 1,200]`, **33 % de separación**. **No se ensanchó
nada para acomodar deriva**: el sujeto no deriva. `procesos` y `linea-base` dan 2,000 y 1,000 **exactos**.

**Y el `4` de (iii) no cabía con la forma obvia del sujeto — se resolvió en el sujeto, no en el techo.**
Los cuatro ejercicios no cuestan lo mismo (el sensible al doble cuesta el doble por construcción →
`1+2+1+1 = 5`). Dimensionando el insensible a **un cuarto** del sensible base: `1+2+¼+¼ = 3,5`. El techo
no se tocó.

### CA-08 sobre la corrida real

Corrida `ca08-1788843906`, árbol `794fa4c`, oráculo `/proc/stat:processes` (suelo **0/12**, factor
**2,000** exacto, tasa de fondo 3,20–3,36 forks/s en tres ventanas de 25 s). **(0) acreditado:** la línea
base se materializó con la propia `sonda-linea-base.sh` (`archivos=67`, `estado=ok`) y **contiene `37/1`
y `37/2`**.

- **(i.1) −56 procesos añadidos**, calibración excluida: `(2092 − 69) − 2079`, mínimos de **6 series
  intercaladas**. **No gasta ni uno de los comprados.**
- **(i.2)** reloj **−4**, procesos **−31**, línea base **+6** — con su comprador: +1 por CA-01.1 (se
  invoca) y +5 por CA-05.1 (`git hash-object --stdin-paths` del lote: 1 de `git` y ~4 que `git` gasta por
  dentro).
- **(ii) 1,165×** (`26 032 011 / 22 350 191 µs`), techo 1,250×; convergencia 1,006×/1,004×.
- **(iii)** reloj 1,666× · 0,312× · 1,431×; procesos 0,000× · 2,875× · 2,133×; techo 4,000×.

### Dos defectos que la propia mudanza cometió, y el caso que los cazó

- **`$BASHPID` dentro de `$( )`, otra vez** — el mismo error que este REQ existe para no repetir. El
  archivo se escribió `…-3881596.json` y se leyó `…-3882892.json`: `cuenta=0`, FAIL.
- **`/proc/<pid>/task/<tid>/children` no termina en salto de línea**, así que `read … || continue`
  descartaba la lista **siempre** y la sonda publicaba `vivos=0` **con la descendencia viva**. Lo delató
  el caso del **nieto**; **con un hijo directo habría dado verde.** Es la justificación medida de por qué
  CA-04.1 exige acreditar por descendencia y no por hijo.

### `SEC-037` cerrado

Las cinco propiedades sobreviven a la mudanza **y cada una tiene un caso del banco que la interroga**:
CA-02.5 (`estado=mixta`, `instrumentada=si`, sin número), CA-04.3 (`type -P`, sin `command -v`, y la
comprobación **sobre la ruta escrita en el envoltorio generado**), CA-04.4 (camino de error real
`sin-sujeto` y **0** directorios detrás), CA-04.5 (las cuatro formas `:x`, `x:`, `::`, `.` →
`path-inseguro`) y la propiedad por descendencia con nieto, con su fail-before.

### Seis hallazgos nuevos. Uno `contrato`, y uno que BLOQUEA LA FUSIÓN

- **`DEV-021-06` (`contrato`)** — (i.2) ilustra **2** procesos comprados; medido **+6**. La **regla** se
  cumple (cada uno con su comprador nombrado); el **paréntesis** del criterio, escrito sobre un
  prototipo, es falso. Write-back del **número**, no de la regla. **Impide cerrar REQ-021.**
- **`DEV-021-07` (`instrumento`) — la autoprueba del corredor sale `rc=1` y el CI la corre como paso
  propio, sin `continue-on-error`.** `CA-18` exige que ningún archivo de sección pase de **400 líneas** y
  las dos secciones 37 miden **751 y 614**. **No bloquea el cierre —es `instrumento`— pero bloquea la
  fusión**, porque `hooks-en-linux` es la puerta requerida de `main`.

  **Y lleva roja desde el delta final de REQ-017, que es lo que hay que retener.** El CI que marca
  `pass` en el PR #43 midió `0bab7a1`, donde esas secciones median **346 y 266** líneas; local está **20
  commits por delante**. Es **H-08 con otra cara: un verde sobre un árbol que ya no existe.** REQ-017
  cerró por encima de esta roja, y no fue indebido —`CA-18` es `instrumento` y §6 no lo hace
  bloqueante—, pero la ventana no puede fusionar sin partir esas dos secciones. La mudanza de REQ-021
  **mejora y no arregla** (761→751, 646→614), y no se arregla aquí porque **CA-07.2 congela sus
  `CASOS_ESPERADOS_SECCION`**.
- **`DEV-021-08`** — CA-05.1 deja ejecutable **todo** `*.sh` materializado; al materializar `tests/`, la
  copia rompe la CA-27 del propio banco.
- **`DEV-021-09`** — el plazo de CA-04.2 se comprueba **entre** unidades de trabajo, no **dentro** de
  una. Acotar una unidad colgada exige un vigilante en proceso aparte, y eso es justo lo que (i.2) no
  admite: en bash no hay forma de esperar con plazo sin gastar un `fork`. **Declarado** en
  `tests/util/README.md`, no prometido.
- **`DEV-021-10`** — el margen superior de `cal_a` es del **1,6 %** bajo carga ajena (peor observado
  2,362 contra 2,400). **Falla hacia FAIL, no hacia verde.**
- **`DEV-021-11`** — CA-07.2 pide «ninguno pasa de PASS a SKIP» y el caso de la pared **se abstiene por
  diseño**: 4 corridas dieron `SKIP·PASS·PASS·PASS` en la línea base y `PASS×4` en el nuevo.
  Preexistente, dueño `SEC-030`.

**Coste:** ≈430 k tokens y ~3 h de reloj — 3 corridas completas del banco, 12 de `37/*` intercaladas
para (i.1) y (ii), 8 del corredor para la banda y 4+4 para DEV-021-11.

## [GitHub] — 2026-09-07 · REQ-021: el desarrollador midió antes de construir, CA-08 resultó insatisfacible, y la renegociación conservó el techo cambiando el grano
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `desarrollador` (medición), `analista-requerimientos` (renegociación).

**La comisión de desarrollo se despachó con una instrucción: medir `CA-08 (i)` antes de escribir una
línea, y si no cabe, parar. No cabía. Paró.** No implementó nada, el árbol quedó intacto y todo su
aparato de medida vive fuera del repositorio. Coste: ~135 k tokens y 15 minutos **para no construir** —
contra una vuelta de desarrollo y una de QA, con un contador de tres que **no se reinicia**.

**La medida, contra un oráculo y no contra la sonda gemela.** El contador de forks del kernel
(`/proc/stat`, campo `processes`), leído sólo con builtins — leerlo no gasta un fork, así que no se mide
a sí mismo. Calibrado antes de usarlo: suelo de ruido **0 forks** (12/12), sujeto sensible `n=10 → 10` y
`n=20 → 20` (**factor 2,000 exacto**), insensible `0/0`. Corridas **C1** y **C2** nombradas y
reproducibles.

| Medición (una invocación) | Línea base | Sonda, calibración incluida | Añadidos |
|---|---|---|---|
| reloj | 6 | 4 (C1) · 5 (C2) | **−2 / −1** |
| procesos | 45 (C1) · 46 (C2) | 43 | **−2 / −3** |
| **línea base** | **18** | **41** | **+23** |

Aislando la calibración: `sonda-linea-base.sh` **con** calibrar = 41, **sin** = 20 ⇒ **la calibración
sola cuesta 21, contra un presupuesto total de 18**. Aunque la medición nueva costara cero, ya no cabe.
Y no es de implementación: la calibración son cuatro materializaciones por el mismo camino, que es lo
que **CA-03.4 exige**; abaratarlas obliga a quitar pasos del camino, que es lo que CA-03.4 prohíbe.

### La renegociación: se conserva el techo, cambian el grano y el alcance

La propiedad que el `0` protegía —**mudar las sondas no encarece la puerta requerida de `main`**— sigue
en pie y **ahora está medida**. Lo que no se sostenía era el grano:

- **El `0` se conserva**, en el grano en el que la puerta paga: **la corrida**. Medido **−2 en C1 y C2**.
- **La calibración sale de (i)**: es capacidad nueva, ninguna línea base la tiene, y cargarla a la
  cuenta de la no-regresión es lo que hacía el criterio insatisfacible. La acotan el grano de CA-03 y (iii).
- **Lo comprado se declara con su comprador.** (i.2) admite `0 + los procesos que compre un criterio de
  este REQ`, **cada uno nombrado con el criterio que lo compra** (hoy 2, por CA-01.1 y CA-05.1). *Un
  proceso añadido sin criterio que lo compre incumple* — sin esa cláusula, «comprado» sería la coartada.
- **(iii) cambia de denominador, no de holgura:** de `0,25× el reloj de la medición` a **`no más de 4×
  una medición del mismo instrumento, en reloj y en procesos`**. **El 4 se deriva de lo que CA-03
  contrata** —par sensible/insensible × dos tamaños = cuatro ejercicios—, no de lo que cuesta. Medido
  **1,05×**. Y un efecto lateral que vale por sí solo: **(iii) pasa a ser el único indicador medible de
  CA-03.4**, la identidad de camino, que hasta hoy se sostenía por inspección.
- **(0) nuevo:** la línea base se acredita **antes** de medir y, si no contiene `37/1`/`37/2`, no hay
  número — `sin-linea-base` + SKIP, **nunca verde**. Es **H-08 cerrada en el criterio**.
- **La salida está pre-decidida:** si (i.1) o (ii) no caben sobre la corrida real, **no se sube el techo
  — se reduce el alcance**, con residual declarado.

**Cuatro hallazgos `contrato` cerrados por write-back**, los cuatro encontrados **antes del código**:
`DEV-021-01` (el techo insatisfacible), `DEV-021-02` (la línea base nombrada no contiene lo que se mide:
el commit base `cf2009e` no tiene las secciones 37, que las creó REQ-017 dentro de esta misma rama),
`DEV-021-03` (CA-05 pedía un **tag** y CA-08 un **commit**; ahora admite cualquier referencia que `git`
resuelva) y `DEV-021-04` (CA-03 no fijaba si la calibración es por invocación o por corrida — decidido
**por instrumento y por corrida**, con el identificador de corrida atando calibración y mediciones).

### `DEV-021-05` — una auditoría preventiva puede producir un criterio insatisfacible, y §6 no lo advierte

`instrumento`, dueño `analista-requerimientos`, ventana 1.34.0. **No fue un descuido**, y la mecánica
está precisada: (1) la redacción fijó el `0` **sin código y sin medición**; (2) **R-010 endureció CA-03
—la identidad de camino— sin volver a mirar el techo que ese endurecimiento encarecía**. Dos criterios
razonables por separado, **imposibles a la vez**.

Es la segunda de las tres formas que **REQ-012** proscribió —«fijar un número que la medición
desmiente»—, y la auditoría preventiva es exactamente la condición en la que se cuela: `AGENTS.md` §6 la
presenta como puro adelanto y no dice que **endurecer un criterio puede volver insatisfacible a otro que
nadie vuelve a mirar**. Su sede son `AGENTS.md` §6 y `requirements/README.md`, ninguna en el `Archivos:`
del analista; el enrutado queda con la coordinadora.

**Sin ADR:** `ADR-005` **todavía no existe** («a redactar con la implementación»), así que «sucesor» no
tiene objeto, y no cambia alcance ni decisión base. Lo que cambia es su **mandato**, que se amplía con el
grano y su coste medido, la doctrina de quién compra cada proceso, y que (iii) mide la identidad de camino.

**Dos riesgos vivos, de diseño y no de contrato:** CA-03 (a) exige un **sujeto sensible de coste
realmente lineal**, y el candidato medido —apilado de cadenas en bash— **no sirve** (factores 2,048 y
2,566 donde debería haber 2); en procesos salió exacto. Y **(ii) es el único número de CA-08 sin
medición detrás** (1,25×, nunca ejercido porque su línea base no existía): queda `operativo`.

**Coste permanente declarado:** **21 procesos por corrida**, una sola vez, por la calibración de
`sonda-linea-base.sh`.

## [GitHub] — 2026-09-07 · REQ-021: el write-back estaba hecho en los criterios y no en la cabecera, y la obligación heredada de REQ-017 necesitaba un quinto punto para haber cazado su propio caso
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Write-back de los hallazgos preventivos de R-010 en `requirements/REQ-021.md`, cambio MENOR.** Se
despachó antes que el código a propósito: `SEC-035` y `SEC-036` son `contrato`, y `guard-completado`
deniega el cierre de un REQ con un `contrato` abierto. Para eso existe la auditoría **preventiva**
(`AGENTS.md` §6) — para que sus hallazgos sean contrato **antes** de construir, no después.

**Lo que el analista encontró antes de escribir nada:** el write-back **ya estaba hecho a nivel de
criterio**. REQ-021 nació después de R-010 y su propio autor lo incorporó (CA-03, CA-04, CA-06.4,
CA-10 y el residual con forzador observable). Verificadas una por una las **cuatro** remediaciones de
`SEC-035` y las **tres** de `SEC-036` contra el registro: están todas. **Lo que faltaba era el campo de
la cabecera**, que es lo único que la máquina lee. Un contrato correcto con el campo sin actualizar
habría bloqueado el cierre sin que nadie supiera por qué.

`Hallazgos abiertos:` queda en `SEC-037 (instrumento, dueño desarrollador, se cierra con la
implementación, R-010)`. `SEC-035` y `SEC-036` cerrados por write-back; sus entradas en
`docs/seguridad/registro-seguridad.md` siguen diciendo `abierto` y **cerrarlas es del
`auditor-seguridad`** —ese archivo no está en el `Archivos:` de REQ-021—, anotado en la Trazabilidad
para que no se pierda.

**La obligación heredada de REQ-017, y por qué necesitaba un punto que no existía.** REQ-017 cerró con
la regla de que toda cifra publicada nombre su corrida, y REQ-021 construye **las tres sondas que
producen esas cifras** para todo el arnés: si no está aquí, no está en ningún sitio. El analista amplió
CA-06.3 (la corrida se nombra con invocación, árbol y plataforma, y `desconocido` nunca se omite) y
añadió **CA-06.5**: una cifra **derivada** —diferencia, cociente, extrapolación, agregado— sólo es
publicable si **cada entrada** lleva su registro, la operación queda escrita junto a la cifra y ninguna
entrada se tomó fuera de la disciplina de CA-02; si alguna no cumple, se publica **rango observado** y
nunca un valor.

El motivo de que el punto 5 no fuera opcional es el que importa: **los puntos 1 a 4 no habrían visto el
caso de REQ-017**. La última medida podía llevar su registro impecable — la cifra publicada («≈1,60 MB»)
no era esa medida, era una extrapolación cuyas entradas eran muestras únicas. Es la forma (d) —medir
correctamente la magnitud equivocada— **desplazada un paso río abajo**.

**Y una magnitud sin nombrar en CA-08 (iii):** decía `0,25×` a secas, y con (i) midiendo procesos y (ii)
midiendo reloj admitía **dos lecturas que dan verde por separado**. Ahora dice «el coste **de reloj** de
calibrar … no más de 0,25× el **de reloj** de la medición». Ningún número se mueve.

**Sin ADR: es MENOR.** `SEC-035` y `SEC-036` cambian **cómo** se contrata el sustituto, no **qué** se
decide — la decisión base sigue siendo «acreditar la medida en vez de custodiar el instrumento», que
`ADR-005` ya registra con su condicionamiento.

**Una pregunta abierta que el desarrollador tiene que resolver midiendo, antes de construir:** CA-08 (i)
exige «no más de 0 procesos añadidos … calibración incluida», y la calibración corre dos sujetos
sintéticos en cada corrida. Si no cabe, es un hallazgo `contrato` **contra el criterio**, y el número se
renegocia con el analista — **nunca dentro de la comisión que lo incumple**.

## [GitHub] — 2026-09-07 · REQ-017 `completado`: la auditoría firma atacando el contrato y no la gemela, y encuentra que un carácter invisible apaga el enforcement entero
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `auditor-seguridad` (R-012), coordinadora (cierre).

**REQ-017 pasa a `completado`.** Primera palanca de coste de 1.33.0 cerrada, con el ciclo entero
recorrido: analista → desarrollador → QA (tres vueltas, las diez CA en verde) → auditor. La puerta
`guard-completado` midió la transición y la permitió: `SEG=<aprobado>`, `RIGOR=<critico>`, cola de
aprobaciones 0, quality gates en verde, y los siete hallazgos abiertos del campo son `instrumento`.

**`Seguridad: aprobado (R-012, 2026-09-07)`.** El método del auditor es lo que vale la pena registrar:
comparó el árbol nuevo contra un **oráculo de bytes**, no contra la sentencia heredada — *da igual que
los dos árboles coincidan si los dos se apartan del contrato*. **160 015 entradas propias, 0
divergencias**, bajo el locale del entorno y bajo `LC_ALL=C`. La duda concreta que traía era que el
`?` de `*$CR?*` es un **carácter y no un byte**, y que bajo UTF-8 pudiera no casar contra un byte
multibyte inválido dejando `cr=0` donde la verdad es `cr=1`. Medido: **sí casa**. No está.

**Un hallazgo que nadie buscaba, en la dirección contraria a la temida.** Fuera del dominio de
equivalencia de `ADR-004` hay 17 divergencias, y **16 son «la heredada abría de más»**. Es decir que
v1.32.1 tiene una **puerta no determinista** que puede denegar un REQ válido al azar, y este REQ la
retira. La afirmación de CA-10 sobrevivió a 120 invocaciones por árbol con la cabecera diseñada para
maximizar el efecto: 0 deny en los dos.

### Tres hallazgos nuevos, los tres `instrumento`, ninguno introducido por este cambio

- **`SEC-047` · severidad crítica · latente.** Un **carácter invisible borra un campo de la cabecera**,
  y para dos campos la **ausencia abre**. Ejecutado contra el `guard-completado` real: un **BOM**
  delante de `Sensible a seguridad: sí`, con `Rigor: ligero`, cierra a `completado` un REQ con `QA:
  pendiente` y `Seguridad: pendiente`; sin el BOM, deniega. Un `0xc3` o un U+200B delante de
  `Hallazgos abiertos:` retira un hallazgo `contrato` que bloqueaba. Es el **bypass completo del
  enforcement con un carácter que ningún revisor ve en el diff**, y no hace falta malicia: PowerShell
  añade BOM al redirigir y los proyectos consumidores trabajan en Windows.

  **Presente e idéntico en v1.30.3, v1.31.0, v1.32.0, v1.32.1 y este árbol** — REQ-017 no lo
  introduce, no lo agrava y ningún criterio suyo podía verlo. **Latente:** barrido todo el historial
  de `requirements/`, ningún REQ llevó jamás un carácter invisible, así que no hay cierres
  contaminados ni nada que reabrir.

  **La causa es reutilizable y es la tercera aparición de la misma familia.** La guarda del CR está
  **bien construida** —propiedad y no sitio, primera sentencia del único escáner, contratada en
  REQ-016 CA-12 y firmada en R-009— pero su **extensión está mal trazada**: nombra *el CR* cuando la
  propiedad es «un carácter que no se representa y que la normalización no retira». Descripción **por
  enumeración** donde tocaba **por propiedad**, que es el defecto exacto que REQ-012 prohibió en los
  criterios, reaparecido en el código que esos criterios gobiernan. Ensanchar la enumeración pierde
  igual: es la sexta derrota de esa vía. **Decisión del propietario (2026-09-07): entra como REQ
  propio en 1.33.0**, por delante de la recomendación del auditor de ponerlo primero en 1.34.0.

- **`SEC-048` · severidad alta.** `fetch-depth: 0` (H-08) sí abre algo, y **no** lo que se teme por
  defecto: barridos los 128 commits, la historia completa no contiene secretos ni material de cliente,
  nunca los contuvo y nada se borró jamás. Lo que abre es que las secciones 37 **materializan y
  ejecutan** `hooks/` y `tools/` desde los tags — antes salían SKIP. Y el repositorio tiene **un solo
  ruleset, `proteger-main`, con `target: branch`**: **no hay ruleset de tags**. La puerta requerida de
  `main` ejecuta código identificado por **referencias mutables**, y **mover un tag no aparece en el
  diff de ningún PR**. Esa asimetría es todo el hallazgo. Se cierra con un ajuste de repositorio del
  propietario (prohibir actualizar y borrar `v*`), sin REQ ni ventana.

- **`SEC-049` · severidad baja.** CA-10 declara la divergencia en **un solo sentido**; es
  bidireccional.

**No medido, y declarado como tal en vez de supuesto:** `banco.yml` no lleva bloque `permissions:`, y
el auditor recibió `403` al pedir los permisos por defecto del `GITHUB_TOKEN` (hace falta admin), así
que **no acota el radio** de una ejecución hostil en el runner.

### Corregida una colisión de identificador antes de cerrar

R-011 terminaba en `SEC-046` y R-012 arrancó un número por debajo: durante unos minutos hubo **dos
hallazgos distintos numerados `SEC-046`**, y la ambigüedad ya estaba escrita en el campo `Hallazgos
abiertos:` de REQ-017, que **lee la máquina**. Renumerados los tres de R-012 a `SEC-047`/`SEC-048`/
`SEC-049`, con las sustituciones acotadas al tramo de R-012 para no tocar ningún id ajeno; `SEC-046`
(R-011, REQ-020) queda intacto.

**Y la comprobación que la coordinadora dio para verificarlo estaba mal escrita, con la misma forma que
el hallazgo que acababa de leer.** Pedía que no hubiera **encabezados `SEC-` repetidos**, y eso marca
en falso los siete hallazgos que reaparecen para **cambiar de estado** (`SEC-024 — abierto →
en-mitigación → mitigado`), que es el registro funcionando como debe. Enumeración otra vez donde tocaba
propiedad. La que discrimina cuenta sólo las líneas donde el id **declara** un hallazgo (id + clase +
estado) y sale vacía; el inventario va de `SEC-001` a `SEC-049`, monótono y sin huecos.

## [Interno] — 2026-09-07 · REQ-017: write-back del mapa de archivos tras H-08, y CA-04 corregida antes de despachar QA (medía una función que no existe en su línea base)
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Write-back de deriva (`AGENTS.md` §9), cambio MENOR.** El delta de implementación de REQ-017
(`cand/1.33.0`, `bf8ca8f`) tocó tres archivos que el campo `Archivos:` del REQ no declaraba, con
ampliación de comisión **aprobada por el propietario** (gate humano de §6: el workflow de CI es
decisión suya). El `desarrollador` no lo corrigió porque su comisión le acotaba la intervención en el
REQ al `Historial de cambios`, y el mapa es de la **Definition of Ready** del analista; lo dejó
anotado en la fila de H-08 para que el write-back no dependiera de que alguien leyera su informe.

**Añadidos al campo:** `.github/workflows/banco.yml` (el `fetch-depth: 0` que cierra H-08),
`docs/PENDIENTES.md` (donde vive el hallazgo con su dueño) y `docs/qa/1.33.0.md` (el registro de la
ventana). Las rutas van **sin decoración de Markdown**: mientras **SEC-020** siga abierto, un campo
decorado elemento por elemento hace que `tools/arnes-paralelo.sh` responda `disjunto` con rc 0 sobre
rutas que no existen.

**Y la regla de exclusión que este REQ declaraba se estrecha**: `docs/qa/<versión>.md` deja de contar
como «artefacto de gobierno que toda comisión toca». No es universal —es por ventana— ni es un
apéndice: es donde se escribe la evidencia medida que CA-04, CA-05 y CA-09 acreditan. El motivo de
fondo es que la intersección se calcula **sobre lo declarado**: un archivo que REQ-007, REQ-008 y
REQ-011 declaran y REQ-017 no salía `disjunto` **en falso** — fail-open, el modo de fallo exacto que
el campo existe para evitar.

**Consecuencia operativa, dicha por delante:** con `banco.yml` dentro del mapa, **todo REQ que declare
`.github/`, `.github/workflows/` o ese archivo colisiona con REQ-017**, porque la herramienta expande
un directorio a todo lo que cuelga de él. Afecta a REQ-014 (que ya colisionaba por
`tests/escenarios/hooks/`) y al canal de informes previsto para 1.34.0, que sólo saldrá disjunto si
declara sus rutas de `.github/` una por una en vez del directorio.

**Y en el mismo write-back, tres correcciones inline en CA-04 y CA-09, ANTES de despachar QA.** El
motivo no es la pulcritud: es **gastar una de las tres vueltas dev↔QA en un hallazgo de redacción que
cuesta cuatro líneas**, con un contador que **no se reinicia** (`AGENTS.md` §6). Es la vuelta más cara
y más evitable del ciclo, y `requirements/README.md` manda al QA reportar un criterio mal formado
**antes** de ejecutar la prueba.

1. **CA-04, el procedimiento — el criterio apuntaba al vacío.** Decía «se mide `arnes_sin_cita` de
   este árbol **y la del tag v1.32.0**», y `arnes_sin_cita` **no existe** en v1.32.0: la noción de
   cita nace en 1.32.1. La mitad derecha de la razón no designaba nada. Ahora se mide **la boca que
   lee una línea de cabecera** —`arnes_campo_linea` hoy contra `arnes_norm_clave` sola en v1.32.0—,
   con el puntero al sitio único (`hooks/lib.sh`) y con el porqué: lo contratado es el coste de
   **leer una línea de cabecera**, trabajo de la **capa entera** y no de una función con un nombre
   concreto. De las dos lecturas se contrata la **estricta** (1,27× capa contra capa, frente al
   0,21× de comparar sólo el escáner). **El techo ≤ 2,0× no se toca.**
2. **CA-04, referencia:** «hoy es **49×**» → **7,9×** del árbol enfermo medido **en Linux**, más el
   **1,27×** de este árbol; el 49× queda declarado fechado en otra plataforma y no reproducible.
3. **CA-09, referencia y procedencia:** heredada ≈ 0,99 → **≈ 0,94 MB**; v1.32.0 **≈ 1,56 MB
   retirado** (no medible en ese rango en Linux, orden ~1); cada cifra pasa a llevar **la corrida de
   la que sale**, y se **declara** la divergencia abierta —orden 2,01 y 2,00 en la corrida de Linux
   del 2026-09-07 frente a un **1,46** posterior sobre un camino que se sabe cuadrático—. No se
   resuelve aquí: es de **SEC-030** y de QA. CA-09 sigue exigiendo la **medición**, no un valor.

**Clasificación: MENOR, las cuatro.** Ningún techo contratado se mueve, el alcance no cambia y no hay
ADR. La corrección de CA-04 se examinó expresamente por si era **de fondo** —lo habría sido si
cambiara el significado del criterio— y no lo es: la magnitud contratada sigue siendo la misma y la
sustitución cae del lado **estricto**, así que no puede ser una relajación disfrazada
(`requirements/README.md` § «Y el reverso, para que esto no sea una coartada»).

**No se toca nada más:** `Estado:` sigue `en-progreso`, los otros siete criterios quedan **idénticos**
y no hay ADR — el mapa es un dato de coordinación, no una decisión de arquitectura, y corregirlo no
reabre el trabajo ni firma ningún veredicto. QA y auditoría siguen `pendiente`.

## [GitHub] — 2026-09-07 · REQ-017, delta de CA-05: el plazo se deriva del numerador, y el CI vuelve a tener tags (H-08)
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

**Delta de implementación del write-back de CA-05, más el cierre de H-08 por ampliación de comisión
aprobada por el propietario (gate humano de `AGENTS.md` §6: el workflow de CI es decisión humana).**
El `Estado:` de REQ-017 **no se toca**: sigue `en-progreso` hasta que firmen QA y el auditor.

**1 · `ARNES_COSTE_RUTA_CRITICA` invierte su defecto: apagada salvo `=1`.** Corriéndola en cada
vuelta, la sección 37/2 costaba ~120 s —~76 s de ellos la corrida heredada, que cuesta lo que
costaba el defecto porque **es** el defecto corriendo— y dejaba el banco en ~145 s: **la puerta
requerida de `main` más lenta que la regresión de 92 s que REQ-017 arregla**, y de forma permanente,
porque su línea base es un tag congelado. Una razón contra un tag es **acreditación de fail-before,
no puerta permanente**. La vigilancia permanente la da CA-03, auto-anclada y en milisegundos.
Apagada, los dos casos dicen **SKIP citando el número acreditado y su fecha** (0,125× — 9,60 s
frente a 76,19 s), nunca PASS. 37/2 baja de ~120 s a **12,5 s**; encendida cuesta **76,1 s**.

**2 · El denominador ya no se mide: se acota, con un plazo DERIVADO del numerador.** La corrida
heredada se lanza bajo `timeout` de **4 × mín(este árbol)**, calculado en la misma corrida y
**después** del numerador (`⌈4 × u_este / 10⁶⌉` s, redondeo **hacia arriba** — abajo probaría una
desigualdad más floja que la contratada). Un plazo escrito a mano en segundos sería el **reloj
absoluto** que todo REQ-017 combate: lo falsea la máquina, el runner y `nice`. Derivado, la máquina
se cancela igual que en una razón. **El vencimiento es un PASS, nunca un SKIP:** si el plazo vence,
`heredada > 4 × este` y el cociente contratado (≤ 0,25×) queda **demostrado**, no estimado — un SKIP
ahí convertiría el hallazgo en silencio. Sin `--foreground`, `timeout` señala al **grupo de
procesos** entero, así que no queda una corrida de 76 s huérfana envenenando el reloj de la sección
siguiente (CA-06, el fallo de 3 h 41 min de 1.32.1).

**Fail-before / pass-after de la rama nueva, las dos medidas:** con este árbol la heredada **no**
termina en 36 s = 4 × 8,81 s → **PASS**; con `ARNES_HOOKS_DIR` := v1.32.1 —«este árbol» *es* el
enfermo— la heredada **termina** dentro de 285 s = 4 × 71,17 s → **FAIL**. La mitad (ii) pasa a ser
**auto-anclada**: las 3 corridas cronometradas dan el mismo inventario **entre sí** (40 casos); la
igualdad contra el árbol heredado la cierra CA-02 sobre el banco entero.

**3 · H-08 cerrado: `fetch-depth: 0` en el checkout del CI.** Sin tags, el árbol congelado que once
criterios materializan no existe en CI y todos salían SKIP: la puerta requerida dio verde en el PR
#43 sobre el único REQ del PR sin ejecutar ni una de sus comprobaciones. **Lo aprobado es la
combinación de 1 y 3**, y ése es el punto: recuperar los tags sin apagar 37/2 añadiría sus ~120 s a
la puerta requerida; apagar 37/2 sin recuperar los tags dejaría el resto en SKIP igual que hoy.

**El coste, medido y no estimado, porque era la condición de la aprobación:** banco **sin** tags
`833 PASS · 0 FAIL · 12 SKIP · 45,85 s` —que reproduce **exactamente** el resultado del PR #43— →
**con** tags y 37/2 apagada `842 PASS · 0 FAIL · 3 SKIP · 55,98 s`. **+10,1 s (+22 %) compran nueve
criterios que pasan de no medirse a medirse**, CA-03 incluida, que es la única auto-anclada.
Checkout: 0,202 s superficial y sin tags → 0,346 s completo (**+0,14 s**; `.git` 1,2 → 1,6 MB, 40
tags). Se eligió `fetch-depth: 0` y no `fetch-tags: true` porque éste mantiene la profundidad 1 y
deja la prueba colgando de las semánticas del clon superficial, cuyo modo de fallo **es H-08**:
medio funciona y se lee como verde.

**Sigue abierto**, y se dice: la tercera consecuencia de H-08 —un SKIP honesto agregado a un
resultado global se lee como verde— no la cierra esto. Que hoy en CI queden tres es una propiedad
del entorno, no del corredor. Es la palanca «¿esta prueba mide algo?» de 1.33.0.

Quality gates en verde: `bash -n` sobre `hooks/`, `tools/` y el banco entero; `jq -e` sobre
`hooks.json`, `plugin.json` y `marketplace.json`; banco `842 PASS · 0 FAIL · 3 SKIP` con el cuadre
de 845 casos cerrado; autoprueba del corredor `73 PASS · 0 FAIL`.

Archivos: `tests/escenarios/hooks/secciones/37-coste-del-escaner-2-la-seccion-caliente.sh`,
`tests/escenarios/hooks/README.md`, `.github/workflows/banco.yml`, `docs/PENDIENTES.md`,
`docs/qa/1.33.0.md`, `requirements/REQ-017.md`.

## [Interno] — 2026-09-07 · REQ-017: `QA: aprobado`, y la coordinadora se salta su propia regla de paralelismo
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**`QA: aprobado`.** Los **diez** criterios pasan; `QA-017-12` y `QA-017-14` cerrados. Quedan cuatro
residuales `instrumento` con dueño: `QA-017-07` (escalado al auditor), `-11`, `-13` y `-15`.

**Y lo hizo sin medir nada, por una comprobación que lo hace innecesario:** `git diff --stat` entre los
dos commits **sobre `hooks/`, `tools/`, `tests/` y `.github/` sale vacío** — el árbol de código es byte a
byte el que validó en la vuelta 2. Verificó además **mecánicamente** que ningún criterio cambió: la
sección de criterios ocupa las **mismas líneas 20–91** en las dos versiones y difiere en **una sola**, y
las diez líneas que llevan el `Dado/Cuando/Entonces` y los techos son **idénticas incluso en su número
de línea**.

**`QA-017-15` (`instrumento`): cuarta instancia de la clase, en el párrafo que la nombra.** El
write-back escribió «con la palanca encendida **no está medido**» — y **sí lo estaba**, en tres sitios
del registro que la propia frase cita. Con una variante: las tres anteriores se escribieron sin ejecutar
**el mecanismo**; ésta, sin leer **el registro de evidencia citado en la misma frase**. Y una segunda
mitad: una frase compone «9 de 9» de una corrida con los márgenes de **otra** — cada mitad cierta, **la
frase describe una corrida que no existió**.

**⚠️ Y un fallo de la coordinadora que encontró QA:** el commit `7335586` **arrastró 192 líneas del
registro de QA** que se estaban escribiendo en ese momento, bajo un mensaje que no las menciona. Causa:
un **`git add -A` con cuatro comisiones vivas**. El contenido sobrevivió; lo falso es **el mensaje del
commit**. Regla nueva y barata: **mientras haya comisiones vivas se comitean rutas nombradas, nunca
`-A`** — *quien comitea es una comisión más, y la única que puede tocar todos los ámbitos a la vez*.
Segunda observación suya, también de la coordinadora: **se le dijo que el árbol estaba limpio y no lo
estaba**; no contaminó la firma, pero la premisa del encargo era falsa.

## [Interno] — 2026-09-07 · REQ-022 sale de borrador: el registro de QA ya muerde más que el libro mayor
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Medición nueva que cambia la prioridad: `7 de los 8 REQ abiertos declaran el mismo `docs/qa/1.33.0.md`
⇒ los 21 pares que forman esos siete colisionan por UN SOLO archivo.** La pregunta no era «antes de que
muerda»: **ya muerde, y más fuerte que la colisión del libro mayor** (5 de 8). *(21 **pares**; no
confundir con los «21 de 21 **REQ**» de R-010.)*

**Decisión: un archivo de registro de QA por REQ.** Y el corte del argumento cae exacto: **la analogía
del libro mayor aguanta para el índice y se rompe para la evidencia.** La entrada del CHANGELOG es
*resumen de orquestación* —que la coordinadora ya tiene—; el registro de QA es **evidencia primaria que
sólo posee quien la midió**, y centralizarla exigiría una **segunda transcripción** —el modo de fallo
que el propio REQ prohíbe un piso más abajo— arrancándole a cada cifra su condición. Por eso
`docs/qa/<versión>.md` **sí** se queda, pero como **índice de ventana**.

**Y no estrena convención: reconcilia una deriva.** `templates/AGENTS.md.tpl` §12 y `agents/qa-tester.md`
**ya dicen «por REQ»**, y `docs/qa/REQ-001.md` la sigue — es **la práctica** la que derivó. Ese mismo
archivo de agente lleva **las dos convenciones vivas** en dos líneas distintas: **tercera vez** que este
repositorio mide ese patrón. Consecuencia útil: `arnes-upgrade` **no lleva migración**.

**Un `disjunto` falso YA EJECUTADO, encontrado al medir:** REQ-017 **no declara** `requirements/REQ-017.md`
y su write-back del 2026-09-07 **escribió en él**.

⚠️ **Y la consecuencia que hay que decidir: mover el registro de QA REABRE `REQ-012`, que está
`completado` y `critico`.** Su `CA-09` nombra literalmente `docs/qa/<versión>.md` como sitio donde el QA
anota la forma; al moverlo, ese criterio **dice algo falso** y §9 obliga a devolverlo a revisión. **No
cabe la exención de «alcance temporal»**: ésa exime de reescribir contratos cerrados para conformarlos a
una regla de formas, y aquí **cambia el árbol que el criterio describe**. El write-back es de **una
ruta**; el ciclo que reabre es **completo**. Segundo gate: el REQ escribe `.arnes/config.json`, que §6
reserva al propietario — a la cola **antes** de implementar, no al cerrar.

**La cuarta dimensión entra, pero NO como dimensión.** Va como bloque propio, y el motivo es fino: las
tres de la regla principal son propiedades de un **par** de comisiones y se comprueban comparando dos
declaraciones; la de la comisión interrumpida es de **una sola** y no se comprueba comparando nada.
Llamarla cuarta haría que **un veredicto de despacho pareciera responder por algo por lo que no
responde** — que es el error de origen de la herramienta que este REQ corrige.

**El par REQ-019/REQ-022 queda escrito como el único del corpus donde saltan las tres dimensiones a la
vez**, con la lectura que importa: **si SEC-034 no se hubiera levantado, ese par habría salido
`disjunto` con rc 0** y las dos comisiones habrían leído **dos versiones de la misma regla**.

## [Interno] — 2026-09-07 · Preventiva R-011 sobre REQ-020: el juez de todas las sondas no lo vigila nadie
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `auditor-seguridad`.

**`Seguridad: preventiva` con nueve hallazgos, ocho `contrato`. Cinco salen de leer el árbol de hoy**,
no de especular: la mitad de los criterios de REQ-020 hace **afirmaciones verificables sobre el código
actual**, y varias son falsas.

**`SEC-038` — el literal está protegido en su ASIGNACIÓN, no en su USO.** El control es una conjunción
de tres términos —*(término literal) ∧ (es ése el operando) ∧ (la rama se ejecuta)*— y `CA-04` contrata
**el primero**. Tres vías de «arreglarlo» derivándolo sin tocar la asignación, y la tercera es la fina:
**ensanchar la condición de suspensión** del cuadre total apaga el control sin tocar ni el literal ni la
comparación, y **ningún criterio mira esa condición**.

**`SEC-039` — el techo de SKIP se puede subir para tapar, y el propio mensaje de error entrega el
valor.** Recuento estático: la sección `37-…-2` declara **11 casos** y tiene **26 ramas que pueden emitir
SKIP**; la `37-…-1`, 13 y 29. ⇒ **la sección donde ocurrió H-08 puede quedarse entera sin medir**, y el
techo que la cubriría es **11**. Con `SKIP_ADMITIDOS_SECCION=11`, **H-08 reproduce y `CA-02` lo declara
conforme**. Y el flujo natural lleva ahí: el banco aborta, el criterio obliga a imprimir «el número
obtenido», y ese número se pega en la sección. Además **nadie firma subirlo**: el criterio declara cómo
se **baja** y no dice nada de la única dirección que abre.

**`SEC-040` — la acreditación cubre que el universo no encoja, NO que el sujeto sea éste.** Con
`ARNES_HOOKS_DIR` apuntando a otro árbol corren los 852 casos, `PARCIAL=no`, y sale **`Acredita: sí`
sobre otros hooks**. Y lo que lo hace grave: **la instancia que el propio REQ pone al caso 1 es
exactamente ésa** —«pasaban contra los hooks de 1.32.0, la versión con el fail-open»—. El REQ nombra el
incidente y contrata una acreditación que no lo modela. Segunda vía: **`jq` ausente** → `exit 0` con
**cero casos y sin imprimir nada**, falsificando el «siempre» que `CA-01` contrata desde el mismo archivo.

**`SEC-043` — un hallazgo de coste que nadie pidió:** la pasada única de clasificación tendría que leer
**7 518 líneas** donde hoy se leen **339** (la función retorna en la primera coincidencia): **22,18×** en
la magnitud que se paga. Y **la mitad que debía verlo es ciega por construcción**: mide el reloj sobre
un directorio de secciones **triviales**, y leer secciones triviales hasta el final no cuesta nada — la
forma (d) una capa más arriba, **no en la magnitud sino en el material**.

**`SEC-045`, y contesta la pregunta que le hice: ¿quién vigila al vigilante? Nadie, y está medido.**
`codigo_app.globs` **no incluye `tests/`**. Todo lo que REQ-020 construye —el literal, los techos, el
inventario, la autoprueba que los certifica— aterriza donde `guard-codigo` **no deniega a nadie**:
cualquier subagente y **la sesión coordinadora**, que es la misma que reúne la evidencia de «todo en
verde» y **fusiona, etiqueta y publica por delegación**. `AGENTS.md` §6 llama a `tests/` **crítico en
prosa** y ninguna máquina lo respalda; tampoco hay gate humano. **Es la estructura de SEC-036 una capa
más arriba y con más palanca: allí el artefacto sin custodia era una sonda; aquí es el juez de todas las
sondas.** A la pregunta exacta —*¿qué impide que ese «tercero» sea la misma sesión con otro sombrero?*—:
**nada, y hoy es lo que ocurre.**

Concurre con **acreditar > custodiar** y **no** mete `tests/` en el manifiesto en esta ventana, por el
mismo motivo que aceptó en SEC-036: tocar el manifiesto abre gate humano y una entrada en la cola
**deniega el cierre de cualquier REQ**, incluido REQ-017. Asume el residual con forzador observable —en
la pasada de conformidad de 1.34.0 se muta el propio mecanismo de REQ-020 y se exige que la autoprueba
**no dé verde**— y vencimiento.

**Y una nota de método suya, que es la tercera instancia del mismo conflicto hoy:** la comisión llegó
con la preferencia de sesión de «edita por `Bash`» activa y **no la siguió** para la cabecera del REQ,
citando §13 — *editar la cabecera de un REQ por consola apaga una puerta*. Es literalmente el caso que
§13 documenta: **«quien configura una sesión no suele ser quien lee esta sección»**.

## [Interno] — 2026-09-07 · REQ-018, el canal de informes: la privacidad por la forma, y lo que la forma NO puede hacer
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**La regla que gobierna todos los campos está escrita como propiedad, no como lista:** *el dominio de
respuesta natural de un campo no contiene ningún identificador del proyecto que reporta*. Versiones,
desplegables, conteos y una cabecera ficticia cumplen; **«cuéntame tu caso» está prohibido por nombre**,
porque es el campo por el que el nombre del proyecto entra **sin que nadie decida ponerlo** — distinto
de teclearlo a propósito. Con `blank_issues_enabled: false`, sin lo cual la gramática no restringe nada.

**Y el REQ se niega a fingir lo que no puede medir.** No existe propiedad comprobable de «el canal no
filtra», y un criterio que lo afirmara estaría **midiendo la forma del formulario y llamándolo otra
cosa** — la forma (d) aplicada a la seguridad, que *tranquiliza más que no medir*. Lo verificable es más
estrecho y verdadero: **no hay ningún sitio donde el dato quepa sin que alguien lo teclee a propósito**.
El resto es irreductiblemente humano y se gobierna **por respuesta**, no por prevención.

**Cuatro decisiones con su motivo, y las cuatro nacen de errores medidos esta semana:**
- **La cabecera mínima se pide como esqueleto pre-rellenado que se EDITA**, no como hueco: convierte
  una tarea de **composición** en una de **transcripción**. No impide pegar; **hace que pegar cueste
  más que editar**, y eso es todo lo que una forma puede hacer.
- **Toda opción cerrada lleva «no lo sé»**: un desplegable sin salida **fabrica** una respuesta, y lo
  que fabrica es un **error de clasificación** — justo la clase que ninguna puerta detecta y contra la
  que este canal es el único instrumento. Un formulario sin escape envenenaría aquello para lo que existe.
- **Vía de escape declarada**: si el informe no se puede escribir sin nombrar el proyecto, **no se abre
  issue**. *Cerrar una puerta sin abrir otra no reduce la filtración: la concentra.*
- **Un campo para conteos sobre el corpus ajeno**: la aportación más valiosa recibida hasta hoy fue un
  conteo sobre 47 REQ ajenos que **desmintió una conclusión nuestra bien medida sobre 17 propios**, y un
  conteo no lleva ningún dato de cliente. Es la **única mitigación conocida de la ceguera del
  autoalojamiento**.

**Hallazgo que el propio REQ destapa: una issue no es una ruta versionada.** El barrido de base de
`docs/seguridad/gobernanza-datos.md` §3 sostiene que «ninguna ruta versionada nombra un proyecto
consumidor»; abrir este canal crea una superficie de datos que ese control **no puede ver por
construcción** — **exactamente la forma de SEC-029**, un año después y en otro sitio.

**Y el error opuesto, que nadie estaba mirando:** una gramática tan estrecha que **ningún informe real
cabe** es perfectamente segura e **inútil**. Se contrata la reconstrucción de los informes ya recibidos;
el que no quepa es hallazgo `contrato` **contra la gramática**.

**Nota de método del analista, que es de la casa:** descartó publicar el número de informes de campo del
corpus porque su recuento dio 6 coincidencias **con 2 falsos positivos** y omitía aportaciones reales —
*publicarlo habría sido publicar como medido un número cuyo método acababa de fallar delante de quien lo
ejecutó*.

Queda en `borrador`: **tal como está contratado NO es disjunto** —escribe `hooks/lib.sh`,
`hooks/estado-derivado.sh` y `AGENTS.md`, así que iría en solitario y declara `Mide: sí`—, con dos
palancas escritas para partirlo si se quiere el primer `disjunto` real.

## [Interno] — 2026-09-07 · El residual descrito al reves, y la clase que ya va tres veces en el mismo REQ
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**`QA-017-12` cerrado: «ruidoso» → silencioso.** El acoplamiento de `CA-05` se declaraba fallando
*«ruidoso — el único PASS desaparece del banco en la primera corrida»*, y está medido que **en el modo
por defecto la rotura no se nota**: veredictos idénticos, `rc 0`, y las dos únicas líneas que difieren
son cifras que cambian en toda corrida. **Se sigue del propio criterio:** sin la palanca, el caso de (i)
ya es SKIP por «no se pide», así que la guarda (c) **no se ejercita** y **no hay PASS que desaparecer**.

**Y la consecuencia que hace que valiera la pena escribirlo: hubo que cambiar el forzador.** El anterior
—«quien cambie la disposición repunta la sonda»— **funcionaba sólo porque el fallo era ruidoso**. Siendo
silencioso, REQ-014 y REQ-021 cambiarían la disposición, correrían el banco, **lo verían verde** y
cerrarían: el residual **sobrevive a su propio vencimiento** y reaparece meses después, la primera vez
que alguien encienda la palanca para acreditar algo. Ahora es **obligación** —esa comisión corre CA-05
una vez con la palanca encendida— y el vencimiento queda **condicionado a que esa corrida conste en su
evidencia**: *«sin ella el residual no vence: sólo cambia de dueño sin que nadie lo haya mirado»*.
Precedente de esta misma ventana: **SEC-036** obligó a lo mismo — *un residual cuyo disparador es el
daño que debía evitar no vence nunca*.

**El analista se negó además a repetir el error por cuarta vez:** QA midió **el modo por defecto**, así
que «recuento 0 → SKIP con la palanca encendida» queda marcado **esperado, no medido**.

**La clase, escrita con nombre — va TRES veces en este mismo REQ:** *una afirmación sobre cómo se
comporta el mecanismo, escrita sin ejecutarla.* `CA-04` apuntando a una función inexistente en el tag;
la guarda (c) nombrando una señal constante-cero; y «ruidoso» medido silencioso. **Y lo que la separa de
las cuatro formas prohibidas de `CA-07`: aquéllas se ven leyendo el criterio, y ésta no** — la única
manera de verla es **correr contra el árbol lo que el criterio afirma**. Coste medido por tardanza,
dentro del propio REQ: cuatro líneas → un write-back → un hallazgo `contrato` que **bloquea el cierre**.
Propuesta para 1.34.0 como **línea de la Definition of Ready**, no como quinta forma prohibida.

**`CA-09`, márgenes corregidos:** `1,25–3,40×` → **`1,154×–2,523×`**, con la consecuencia que el número
obliga a escribir: la distancia al 1,0 —donde la sonda produce FAIL sobre razón verdadera— es **~0,15×,
no ~0,25×**. *Un colchón declarado de más es cómo un residual aceptado se vuelve un rojo sorpresa.*

## [Interno] — 2026-09-07 · QA vuelta 2: los diez criterios pasan, y lo que bloquea es una frase
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**`QA: con-hallazgos`, vuelta 2 de 3 — pero los diez criterios PASAN.** Lo único que impide `aprobado`
es un hallazgo `contrato` **sobre una frase**. Cerrados: QA-017-01, -02, -05, -06, -08, -09 y -10.

**Lo que verificó en vez de asumir:**
- **CA-08: 38 medidas, 38 PASS**, razones **0,890–1,139×** contra techo 1,250. La abstención por
  convergencia se activó **0 de 38** (máximo observado 1,227×) — no es un SKIP disfrazado. Y lo
  decisivo: **inyectó una regresión real** (un `fork` por línea) y el caso dio **FAIL en las cuatro
  mitades**, con el mensaje «*y la sonda SÍ convergió: esto es una regresión, no ruido*».
- **El dominio, falsado por su cuenta con 3 300 entradas propias** —2 000 aleatorias de cinco semillas
  y 1 300 adversariales sistemáticas—: **0 divergencias dentro del dominio**.
- **Construyó el fail-before de extremo a extremo** de la rama «no clasificables» que el desarrollador
  había declarado que no tenía. Deja de ser residual.

**`QA-017-12` (`contrato`, bloquea): la justificación del residual del acoplamiento es falsa.** CA-05
afirma que romper la disposición del corredor falla «**ruidoso** — el único PASS de (i) desaparece del
banco en la primera corrida». Medido: **en el modo por defecto no cambia nada** — los veredictos son
idénticos y `rc 0`; no hay PASS que desaparecer, porque ya es SKIP por «no se pide». Se cierra con
write-back sobre **esa frase**, sin código y sin re-medición.

**`QA-017-13` (`instrumento`): el banco no es puerta estable bajo carga, y la culpa no es de REQ-017.**
Salió rojo **2 de 12** veces, siempre por el **mismo caso ajeno** —`25-presupuesto-de-analisis.sh`—
que contrata **un reloj absoluto** de 4 000 ms: 4 333 ms bajo `JOBS=6`, y **aislado 12 de 12 verde**,
con este árbol si acaso **más barato** que v1.32.1. Es contención, no regresión, y es **la forma (d)
que `CA-07` acaba de prohibir**, viva en otro archivo.

**`QA-017-11` (`instrumento`): `CA-01` da PASS sobre un dominio vacío o colapsado.** Hay guarda para
`fuera = 0` y para `no clasificables ≠ 0`, **no para `dentro = 0`**. Con la evaluación de la heredada
truncada el dominio cae de **312 a 10** y sigue verde. No muerde hoy (312/320 en 14 de 14).

**Y una corrección al desarrollador que vale la pena conservar:** declaró márgenes de CA-09 de
«1,25–3,40×» y la medición da **1,154×–2,523×**. El suelo real está **por debajo** del declarado —
*un colchón declarado de más es cómo un residual aceptado se vuelve un rojo sorpresa*.

Coste: 1 h 10 de reloj, ~240 k declarados (300–331 k con la corrección), ~35 min de máquina midiendo.

## [Interno] — 2026-09-07 · CA-05: la guarda pasa de inerte a discriminadora, y por qué eso NO es relajarla
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Write-back de deriva sobre `CA-05` (c).** La guarda exigía que la corrida heredada «produjera al menos
un caso — su salida existe y no está vacía», y en este corredor **la salida no existe hasta que todas
las secciones terminan**: una corrida matada por `timeout` deja 0 bytes **siempre**. Ahora contrata el
**recuento de casos que dejó escritos mientras corría** —la sonda le fija la raíz de ese trabajo antes
de lanzarla—, con las fuentes marcadas **no exhaustivas** y con puntero al sitio único, *porque lo que
se contrata es el recuento, no dónde se lee*. El `1` se declara **de contrato**: es la definición de
«esta corrida midió», no una magnitud ajustable. Referencias medidas: **37** casos matada a los 12 s,
**0** si no arranca.

**MENOR, y el argumento es el que impide leerlo como una relajación:** *la versión anterior no era
estricta, era **inerte** — nunca podía dar PASS. Sustituir un always-SKIP por un discriminador real
(0 vs 37) **aumenta** la capacidad de fallar, no la reduce.* La propiedad contratada no cambia
—«un plazo agotado por una corrida que no arrancó no acota nada»—; cambia el observable.

**Y el origen del error, que es reutilizable:** el hallazgo de QA proponía el remedio como «que la
heredada haya producido al menos un caso **o** que su salida exista y no esté vacía», y el write-back
de la vuelta 1 **tomó la glosa por la señal**, sin comprobar que en este corredor la salida no existe
hasta el final.

**Dos residuales con dueño y vencimiento**, ninguno bloquea: el **acoplamiento** entre la guarda y la
disposición en disco del corredor —falla **cerrado y ruidoso**, dueño `desarrollador`, forzador el
primero de REQ-014 o REQ-021 que entre— y la **resolución de la sonda de CA-09** con dos árboles
idénticos (SKIP/FAIL/PASS en tres corridas), que **no muerde hoy** porque el banco compara contra el tag
congelado con márgenes 1,25–3,40×; dueño **SEC-030**.

## [Interno] — 2026-09-07 · REQ-017 vuelta final implementada: CA-08 deja de ser flaky, y CA-05 nombra una señal que no existe
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

**El síntoma que veníamos a matar, medido antes y después.** Reproducido en HEAD: **1 de 6** vueltas del
banco completo en rojo, con `1,255×` contra el techo `1,250×`. Con el procedimiento nuevo —**6 series
intercaladas** en vez de 3 en bloque, más la **cláusula de convergencia**— **0 rojas de 9**, y el margen
al techo pasa de **0,3 %** a **10,4 %**. La abstención por convergencia **no se activó ni una vez** en 18
medidas reales: el caso **sigue midiendo**, no se ha convertido en un SKIP permanente. Y salió gratis:
6 series × k=4 son **las mismas llamadas al hook** que 3 × 8.

**El dominio nuevo, ejercido:** corpus de **320 entradas, 281 con UTF-8 inválido**; clasificación en una
sola pasada que evalúa la **heredada antes** que este árbol; medido **dentro 312 · fuera 8 · no
clasificables 0**, con la heredada incumpliendo **invariancia en 7 de 8** y determinismo en 0–1. Estable
en 9 corridas. Casos del banco **847 → 852**, con los tres literales actualizados a mano.

**DESVIACIÓN DECLARADA, y es la que importa: la guarda (c) de `CA-05` es insatisfacible tal como está
escrita.** `run.sh` **no imprime ni un byte** hasta que todas sus secciones terminan, así que la corrida
heredada matada por `timeout` deja **0 bytes siempre**, trabaje o no. Implementada al pie de la letra
convierte el único PASS de CA-05 (i) en **SKIP permanente** — verificado encendiendo la palanca. **Es la
misma clase que `ADR-004` acaba de diagnosticar en CA-01: una comprobación correcta sobre la señal
equivocada.** Se implementó la **intención** con la señal que sí discrimina —contar los casos escritos
*mientras* corría—: matada a los 12 s deja **37 casos**; una que no arranca deja **0**. **Pendiente de
write-back del analista**, porque el criterio nombra una señal que no existe.

**Aviso para la vuelta 2 de QA:** el patrón de exclusión de CA-02 (`REQ-017 CA-0`) **ya no basta** —los
tres casos de CA-10 dan FAIL contra v1.32.1 **por diseño**, que es su fail-before—; con `REQ-017 CA-`
cierra, y el inventario vuelve a dar **828 casos idénticos, md5 `31400a13e34f`**, el mismo de la vuelta 1.

Coste: 1 h 09 de reloj, ~340 k tokens **medidos del contador** (no estimados), ~30 min de máquina midiendo.

## [Interno] — 2026-09-07 · REQ-017: el dominio se traza por invariancia de locale, y ADR-004
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**El dominio de `CA-01` pasa de «donde la heredada es determinista» a «donde publica el mismo estado
bajo el locale del entorno Y bajo `LC_ALL=C`»** — determinismo **e** invariancia de locale. Y el
argumento es **de construcción**, no un ajuste hasta que el rojo desapareció: bajo `LC_ALL=C` la
heredada **es** la pregunta byte a byte («¿hay un CR que no sea el último byte?»), y este árbol la
implementa en **todos** los locales porque no elimina sufijo con patrón ⇒ **los dos árboles divergen
exactamente donde la heredada se aparta de su propia semántica**. El determinismo nunca fue esa
propiedad: era un síntoma del valor **intermedio**, y el criterio contrata sobre el **publicado**.

| | Dominio anterior | Dominio nuevo |
|---|---|---|
| Dentro y divergente (`CA-01` exige 0) | **6–7 de 106**, 4 de 4 → FALLA | **0** |
| Sujeto de `CA-10` (entradas fuera) | **0 en 3 de 4** → SKIP perpetuo | **≥ 7 en 4 de 4** |

**Y con la regla anti-coartada dentro del criterio:** el dominio se traza por una propiedad de la
**heredada sola**, clasificando **sin haber evaluado este árbol**. Un dominio definido como «donde los
dos coinciden» haría un criterio **incapaz de fallar**.

**`CA-08` (ii): lectura (a) —la varianza es del procedimiento— con un argumento que no era el de la
carga.** El estimando y el estimador **se contradicen**: en aislamiento la misma razón da
**0,821–1,010**, y un coste real **no puede ser negativo**; un recorrido de 0,821–1,443 sobre el mismo
estimando es **ruido del instrumento**. Y contra subir el techo: ponerlo por encima del ruido (≥ 1,5×)
**dejaría de ver la regresión de 10× para la que el criterio existe** — fijar el umbral por encima de
la resolución del instrumento. El techo **≤ 1,25× queda intacto**, con **cláusula de convergencia**
nueva: si `segundo mínimo / mínimo` de un árbol supera el propio techo —*un instrumento tiene que
resolver al menos el factor que vigila*— la sonda emite **SKIP citando sus dos razones**, nunca PASS ni
FAIL. No tapa una regresión real: **una regresión sube los dos mínimos del mismo árbol por igual; lo
que separa una serie de sí misma es el vecino.**

**`ADR-004`** registra el dominio como cambio **DE FONDO**, aceptando el dictamen de QA: la
clasificación «menor» de la vuelta 0 queda **revocada** — cambia el significado de `CA-01`, que es donde
el REQ define «equivalencia», y **la decisión nueva era justo la que salió mal**, tomada dentro de un
write-back donde nadie tenía que justificar la elección de la propiedad.

**Choque de numeración, resuelto y con su causa dicha:** REQ-021 tenía **reservado** `ADR-004` para un
archivo **que no existe**; el analista tomó el número **mirando el disco**. Se renumera el de REQ-021 a
`ADR-005` —`pendiente`, sin archivo que mover, referencias de texto— por la coordinadora, sin comisión.
**Causa raíz: el número de ADR no tiene asignador**, y «reparto de identificadores con reserva atómica»
llevaba en el backlog sin versión desde antes: acaba de cobrarse su **primera colisión real**.

## [Interno] — 2026-09-07 · Auditoría preventiva R-010 y su write-back: seis `contrato` antes de escribir código
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `auditor-seguridad`, `analista-requerimientos`.

**`Seguridad: preventiva (R-010)` en REQ-019 y REQ-021** —la excepción nombrada de §6, declarada al
emitirla y **sin cubrir el código posterior**—. Seis hallazgos `contrato` y uno `instrumento`, **todos
antes de que exista una línea**: con los dos REQ en `pendiente`, cada uno cuesta **una edición de
criterio y no una vuelta del bucle**.

**`SEC-031` — se puede perder el LÍMITE de una obligación sin borrar una letra.** El filtro de REQ-019
tiene dos cajones —lo que *manda* se queda, lo que *explica* se va— y una **acotación** («la cobertura
sobre `Bash` es parcial a propósito», «un hook muerto no deniega», «es una barandilla, no una jaula»)
**no ordena nada**, así que se delega **por construcción**. La tabla de §13, conservada byte a byte, es
**una lista de promesas de cobertura**: separada de su acotación, **lo escrito queda más fuerte que la
verdad**. El criterio de no-pérdida era asimétrico —prohibía **añadir** una obligación y no decía nada
de **restar** un límite—. Cerrado con `CA-14` nuevo: *una acotación no se separa de la promesa que
acota*; se delega la casuística, nunca el enunciado.

**Y el cruce de calendario que nadie había hecho:** `SEC-030` está abierto en esta misma ventana y su
remediación exige **añadir** el hueco del temporizador a §13. Si REQ-019 delega esa enumeración antes,
la declaración de un fail-open de la puerta de cierre **aterriza en un archivo que nadie lee por
defecto**. El write-back no lo resuelve ordenando —«un orden vive en la cabeza de quien despacha»— sino
por propiedad: CA-14 hace **los dos órdenes seguros**.

**Segundo cruce, encontrado al escribirlo:** `CA-02.1` exigía la tabla de §13 «idéntica **byte a byte**»
y `CA-04` lo mismo para la plantilla. La remediación de SEC-030 **añade** a las dos sedes → los dos
criterios habrían declarado **incumplido un trabajo ajeno y correcto**. Es la forma prohibida **(c)**
—igualdad donde corresponde dirección— sobre un criterio escrito con esa sección delante. CA-02.1 pasa
a prohibir **restar**; CA-04 pasa a ser propiedad de **autoría**, no de inmovilidad.

**`SEC-035` — el propio REQ-021 estrechaba la red que hoy existe.** Las sondas viven dentro del archivo
de sección, así que lo que dejan vivo *es* un job de ese shell y el corredor lo alcanza; convertirlas en
**programas invocados** deja lo que quede vivo **reparentado y fuera de la red**. La vigilancia se mudaba
del **juez** al **instrumento** — el artefacto que se decide no proteger — y no estaba dicho. Además el
criterio decía «ningún proceso **que ella lanzara**» cuando el incidente medido fue un **descendiente**:
declaraba conforme el caso que lo origina. Reescrito por **descendencia en cualquier nivel**, con
acreditación **con un nieto** y el plazo de arranque partido del derivado, porque la circularidad estaba
ahí.

**`SEC-036` — separación de funciones, y señala a la coordinadora.** Fuera de `codigo_app.globs`,
`guard-codigo` deja escribir `tests/util/` a **cualquier** agente, incluida la sesión que **acredita,
decide y publica** por delegación. Y la calibración **viajaba dentro del artefacto que certifica**. La
expectativa pasa al **juez** (`run.sh`), se contrata **identidad de camino** entre calibración y
medición, y el sustituto se acredita **por mutación de un tercero**.

**Consecuencia de despacho asumida:** REQ-019 declara ahora `requirements/REQ-*.md` —**21 de 21 REQ
citan `AGENTS.md`**— y por tanto **va en serie** con toda comisión que escriba en `requirements/`.
La alternativa del auditor (acotar el criterio en vez del mapa) queda escrita como **decisión del
propietario**, sin aplicar, porque reduce el ahorro que justifica el REQ.

## [Interno] — 2026-09-07 · QA vuelta 1 de REQ-017: tres criterios fallan, y se corrige lo que esta bitácora afirmó
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**`QA: con-hallazgos`, vuelta 1 de 3. Queda UNA vuelta antes del tope de `AGENTS.md` §6**, que no se
reinicia con cada hallazgo nuevo.

**CORRECCIÓN — esta bitácora afirmó, dos entradas más abajo, que bajo UTF-8 `${l%$'\r'}` «no devuelve un
sufijo sino basura distinta en cada evaluación de la misma entrada».** Medido ahora con corpus de **106
entradas multibyte inválidas** y k=6 evaluaciones en el mismo proceso: eso era cierto del valor
**intermedio**, y el criterio contrata sobre el **estado publicado** — y ahí **la heredada sí repite**.
La clase divergente real es otra: **la heredada no es invariante al locale** (7 de 106), y el no
determinismo es un fenómeno **distinto** (0–2 de 106) que **no coincide** con ella. REQ-017 sigue
cerrando un fallo en abierto de v1.32.1; lo que estaba mal era **qué fallo**.

**Y por eso `CA-01` vuelve a fallar, por una razón nueva: el dominio quedó trazado por la propiedad
equivocada.** Al definirlo como «las entradas donde la heredada es determinista», la clase divergente
cae **dentro** de CA-01 —que exige 0 divergencias— y deja a **`CA-10` sin sujeto**: en 3 de 4 corridas,
**cero** entradas cayeron fuera, así que CA-10 diría SKIP y no llegaría a PASS nunca.

**`CA-08` (ii) ya no roza el techo: lo cruza.** 26 medidas, **2 rojas** (1,252× y 1,443× contra 1,250×),
y **1 de cada 4 vueltas del banco completo en el modo de la puerta requerida** salió roja con `load`
0,91 al arrancar — la carga no lo explica. El procedimiento intercalado que el write-back contrató
**no se implementó**. Consecuencia dicha sin rodeos: **el banco no es estable**, y es la puerta
requerida de `main`.

**`CA-10` no tiene ni un caso en el banco**, y QA revoca su clasificación: **es cambio DE FONDO y pide
ADR**. El precedente de la pared de los 60 s no transporta —aquella se declaró **medida** y se dio a
otro dueño, así que ningún criterio podía fallar por ella—; CA-10 **se contrata como criterio** y
**cambia el significado de `CA-01`**, que es donde el REQ define qué quiere decir «equivalencia» (§9).
Y lo decisivo: **la decisión nueva es justo la que salió mal**, tomada dentro de un write-back
clasificado *menor*, donde nadie tenía que justificar la elección de la propiedad.

**Los dos hallazgos de la vuelta 0 están cerrados de verdad, reproducidos**: el sello que siempre
permite da ahora `SKIP … terminó EN ROJO (rc=1; 14 FAIL de 40 casos)` donde antes daba dos PASS, y el
hijo muerto a los 0,6 s da `SKIP … murió por la señal 9 a los 0,70 s de un plazo de 37 s` donde antes
decía `DEMOSTRADO`. **Sin sobre-corrección**, medidas las dos direcciones: el positivo real sigue en
PASS y la heredada que termina limpia dentro del plazo sigue en FAIL.

Coste: 1 h 35 de reloj, ~175 k tokens declarados (219–242 k con la corrección de subestimación).

## [Interno] — 2026-09-07 · Primer despacho paralelo real: tres comisiones, y el diseño del paralelismo
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` ×2, `desarrollador`, coordinadora.

**Tres comisiones a la vez, y lo que lo hizo posible no fue la herramienta.** `tools/arnes-paralelo.sh`
habría dicho «colisiona» sobre cualquier par: **8 de los REQ abiertos declaran `CHANGELOG.md`** en
`Archivos:`. Se les retiró el libro mayor **y el commit**, y se les asignó un ámbito de archivos
exclusivo. Ahorro de la tanda: ~25 min sobre la serie.

**Write-back de los siete hallazgos de QA sobre REQ-017**, con el argumento que decide el REQ:
**`CA-01` no era exigente, era insatisfacible** — si la operación heredada devuelve basura distinta en
cada evaluación de la misma entrada, la igualdad byte a byte **no la cumple ni v1.32.1 consigo misma**.
Eso separa el estrechamiento de la coartada que `requirements/README.md` prohíbe. El dominio se define
**por propiedad medida en la corrida** (las entradas donde la heredada es determinista), no por lista
de locales ni de bytes. **CA-10** declara el fallo en abierto de v1.32.1 que este parche cierra, y
deliberadamente **no** afirma que cambie el veredicto de la puerta —QA midió que no cambia— ni contrata
el texto publicado fuera del dominio, porque se construye con la misma familia de operación que hace no
determinista a `arnes_norm_clave`. **CA-09 deja de acreditar magnitud alguna**: exige medición,
procedencia y **dispersión**, y contrata sólo la dirección, **pareada dentro de la misma corrida**.

**REQ-019 — adelgazar `AGENTS.md`**, con un criterio de no-pérdida mejor que el que pidió la
coordinadora: **el adelgazamiento es un MOVIMIENTO, no una reescritura** — todo bloque que sale aparece
**literalmente** en exactamente un destino declarado, cero sin localizar, de contrato. *No se puede
perder una regla que nadie borró*, y la reescritura es el mecanismo por el que se pierde; es además la
doctrina que el arnés ya se aplica en la rotación (*mueve; no resume*). Y el ahorro se mide como **peso
de gobierno de lectura obligatoria** con **dos vías a la vez** (≤ 0,60× **y** ≤ 2 documentos), porque
mover texto a un archivo igualmente obligatorio baja los bytes sin bajar el coste y repartirlo en muchos
**lo sube** — la familia exacta de la magnitud equivocada.

**`ADR-003` — la plantilla y la migración se quedan fuera de 1.33.0** (gate humano, aprobado por el
propietario el 2026-09-07). Motivo de mecanismo y no de tamaño: `arnes-upgrade` clasifica **por sección**
y **no tiene estado** para «la sección desapareció del destino» ⇒ `UNKNOWN` ⇒ **detiene la migración de
todos los proyectos**; y la delegación **crea archivos**, que esa skill tampoco sabe clasificar. Más el
argumento de coste: los ~9 000 tokens se pagan en los subagentes de **este** repositorio, así que
adelgazar la plantilla **no ahorra ni un token** de las comisiones de 1.34.0, que es para lo que se
adelantó la palanca. Divergencia acotada por dos invariantes comprobables, con dueño y vencimiento.

**Diseño del paralelismo escrito para 1.34.0** (`docs/PENDIENTES.md`, resumen en `docs/PLAN.md`), con
tres hallazgos que ninguna herramienta de archivos puede ver: la **colisión universal** del libro mayor;
**la máquina** como segunda dimensión de colisión —dos comisiones que miden se invalidan los números en
silencio, y la coordinadora lo hizo hoy con su propio despacho—; y que **dos agentes sobre el mismo
archivo en el mismo árbol no dan conflicto de fusión, dan escritura perdida**: git no protege de eso.
Más la regla completa del campo, en sus dos mitades: **declara exactamente el conjunto de escritura, ni
más ni menos** — de más fabrica colisiones falsas (barato e invisible), de menos fabrica `disjunto`
falsos (caro: escritura perdida).

## [Interno] — 2026-09-07 · QA de REQ-017: `con-hallazgos`, y se retira una cifra que publicamos como medida
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**Veredicto `QA: con-hallazgos`, vuelta 0 de 3.** Ocho de los nueve criterios PASS; banco `842 PASS ·
0 FAIL · 3 SKIP` en tres vueltas sin un caso flaky, y los tres SKIP verificados uno a uno —los dos de
CA-05 **sí miden al encenderlos** (PASS en 84,29 s), o sea que no son la clase de H-08—.

**Sólo bloquea uno, y es bueno: `QA-017-01` (`contrato`).** CA-01 promete que el comportamiento «no
cambia» para una línea cualquiera, y **hay contraejemplo reproducible**: bajo locale UTF-8,
`${l%$'\r'}` en bash 5.3.9 **no devuelve un sufijo sino basura distinta en cada evaluación de la misma
entrada**. La sentencia nueva es determinista y correcta ⇒ **REQ-017 cierra un fallo en abierto de
v1.32.1**, y eso hay que declararlo en el REQ como se declaró la pared de los 60 s. *(QA dice también
lo que no consiguió: no reprodujo una decisión distinta del guardián, porque la puerta recorre la
cabecera dos veces y el segundo recorrido lo cazaba.)*

**CORRECCIÓN — se retira la cifra «≈ 1,60 MB» publicada más abajo en esta misma bitácora
(`QA-017-05`).** La sonda de CA-09 **no repite**: seis corridas del mismo árbol dan 1,08 · 1,32 · 1,78 ·
2,64 · 2,65 · 3,98 MB. Las dos series que se creían discordantes —2,01 y 1,46— **no discrepan: son dos
extracciones de la misma distribución**. Causa: los tiempos base son **una sola muestra cada uno**
—contra la regla del mínimo de k que la propia sección enuncia—, y el exponente resultante va en el
**exponente** de la extrapolación. **La dirección del beneficio se sostiene 6 de 6; la magnitud, no.**
Dueño `SEC-030`. Lo cazó el endurecimiento que el analista había metido esa misma tarde —que cada cifra
nombre su corrida—: **se pagó a sí mismo en su primera validación.**

**Dos hallazgos que hacen mentir a la prueba, y por eso se arreglan ahora aunque sean `instrumento`:**
`QA-017-03` — CA-05 **concede PASS a un numerador que falló** (con los hooks sustituidos por un sello
que siempre permite, la sección sale en 14 FAIL y rc 1, el rc se descarta, el plazo cae a 16 s y las dos
mitades dan PASS, incluida la que se llama *«la comparación no se compra dejando de probar»*); y
`QA-017-04` — **`rc=137` no prueba vencimiento**: matar al hijo desde fuera a los 0,6 s de un plazo de
60 s devuelve 137 y el caso lo lee como demostrado; en un camino cuadrático el OOM kill es el modo de
muerte más probable. Sólo 124 prueba expiración.

**Escalado al auditor (`QA-017-07`):** `arnes_norm_clave`, **idéntica en los dos árboles**, devuelve una
clave **distinta en cada llamada con la misma entrada** bajo UTF-8 con un byte multibyte inválido al
principio de línea. Un lector no determinista dentro de un guardián. REQ-017 **reduce** la exposición y
no la introduce.

**Y lo que QA miró sin encontrar nada, que aquí cuenta como evidencia:** la equivalencia atacada de
cinco maneras —exhaustivo hasta longitud 3 sobre 21 símbolos con todos los metacaracteres de glob
(**9 724 entradas, 0 divergencias**), 40 000 aleatorias bajo dos locales × cinco combinaciones de
`shopt`, fronteras a escala, cadenas de 1–10 CR finales, los 255 bytes tras un CR—. La única familia
divergente es la de `QA-017-01`, **y ahí gana la implementación nueva**. Coste: 33 min de reloj,
~205 k tokens declarados (256–283 k con la corrección de subestimación).

## [Interno] — 2026-09-07 · La tarde del canal: nueve piezas de un proyecto consumidor, y una lección de clasificación
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Intercambio largo con un proyecto consumidor por el canal entre sesiones, cada lado **ejecutando** con
control propio. Todo el material va a **1.34.0** salvo una pieza, que entra en la ventana en curso.
Detalle completo en `docs/PENDIENTES.md`; aquí lo que decide algo:

- **La regla del literal, y entra YA en el REQ de la palanca de 1.33.0:** *una igualdad entre dos
  magnitudes que pueden encogerse juntas no es una cota; hace falta un literal, y el literal **es** el
  control.* La encontraron mutando su propio guardián: con el corpus vacío, `comparadas === corpus.length`
  es `0 === 0` y da verde. Verificado aquí que el banco la cumple —`CASOS_ESPERADOS=845` es un literal
  tecleado— y que ese número, que parecía deuda, **es la pieza que delata el borrado de una sección entera**.
- **Y por eso el `845` NO se automatiza.** Ellos ya lo habían hecho y midieron el precio: su piso lleva
  **seis días** congelado (+28 archivos, +749 pruebas de hueco) porque el trinquete sólo sube sobre corrida
  válida y su suite está en rojo. Un literal falla **por desidia** y se ve; un derivado falla **porque una
  precondición dejó de cumplirse** y no se ve.
- **La palanca «¿esta prueba mide algo?» pasa de dos casos a cuatro**, y gana la mitad que le faltaba: el
  declarado tiene que estar acotado contra algo que no se mueva.
- **«Acreditado por mutación» tiene que decir POR QUIÉN.** Dos corpus, misma dirección: allí, la mutación
  de un tercero encontró el doble que la del autor; aquí, ninguno de los cuatro fallos en abierto de
  1.32.1 lo encontró quien escribió el código.
- **El borde de la familia del caso J es una lista de caracteres, no una propiedad**, y su corpus tiene
  25 líneas hoy inertes **sólo por su primer carácter**.
- **La ceguera del autoalojamiento, medida:** los 17 REQ de aquí declaran los cinco campos; allí, dos se
  omiten en 47 de 47. Un arreglo de «campo ausente ⇒ denegar» diseñado contra el corpus propio habría
  dejado a ese proyecto sin poder cerrar ni un REQ. Con su matiz, que corrige una entrada previa: un
  corpus externo sólo prueba en la dimensión en que es **indisciplinado**.
- **Nuestra promesa falsa viaja en la plantilla:** `templates/AGENTS.md.tpl:309` promete que no se cierra
  sin `QA: aprobado`, y medido: con el campo **ausente**, la puerta **permite**. Es el único de los cuatro
  campos cuya ausencia calla.
- **Dos correcciones firmadas de la coordinadora** (dije que dos cosas no estaban en su informe y sí
  estaban) y **una suya** (`Seguridad: n/a` sí está en nuestro vocabulario, verificado en tres archivos:
  no tienen nada que migrar).

**La lección que ordena las nueve, y es suya:** *un dato puede estar medido, ser correcto, y estar
clasificado en la categoría equivocada* — el `845` como deuda, el reparto de hallazgos como «el bucle
funciona», su piso congelado como «el trinquete ya funciona». **Ninguna se descubre midiendo mejor.** Se
descubren cuando alguien de fuera pregunta por otra cosa. El canal de informes deja de ser higiene y pasa
a ser el único instrumento que tenemos contra el error de clasificación.

## [Interno] — 2026-09-07 · Caso J: el bisecado que lo explica, y dos formas medidas al revés
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

**Segundo informe de campo sobre el caso J, verificado ejecutando** `hooks/guard.sh` del plugin
instalado 1.32.1 contra un proyecto efímero, con control positivo en la misma tanda. Confirmado: la
clave decorada **fuera** de todo comentario sigue desbancando al veredicto vivo y cierra un `critico`
con `Seguridad: con-hallazgos` en la cabecera.

**Lo que el informe aporta y no teníamos: el bisecado.** Hasta 1.30.3 la clave se anclaba con un
literal a columna cero, así que `**Seguridad:** aprobado` **no era un campo**; J denegaba por eso y no
por ninguna virtud del rango de comentario. Con la tolerancia al énfasis de 1.31.0, I y J pasan a ser
**la misma mitad partida por la única característica que no comparten** — el rango—, que es
exactamente por qué el arreglo de 1.32.1 alcanzó a una y no a la otra.

**Y el argumento que decide el diseño:** las dos reglas que producen J —tolerar el énfasis, y que gane
la última aparición— **son correctas por separado**; el defecto es la **conjunción**. Por eso la salida
no puede ser una preferencia entre formas sino la pregunta de estado: *el mismo campo declarado dos
veces con valores distintos no se puede medir ⇒ deniega*.

**Dos correcciones medidas aquí, una en cada dirección:** la celda de tabla que el reportante predecía
como hueco **deniega** (el `|` inicial no se tolera), y en cambio **la indentación sí es hueco** —
`  Seguridad: aprobado` con dos espacios permite—, forma que no estaba en ninguna lista y que
importa porque **no es decoración**: descarta por sí sola la alternativa de «una clave decorada no
desbanca a una limpia».

**La mitad que faltaba:** si la puerta deniega por ambigüedad y el bloque derivado publica uno
cualquiera de los dos valores, vuelve la divergencia entre las dos mitades del lector que 1.32.1 cerró
en H-01. La marca de ambigüedad la emite el lector una vez y la consumen las dos.

Clase `contrato`, **ventana 1.34.0** (movida al partirse 1.33.0; además colisiona por archivo con
REQ-017, que tiene `hooks/lib.sh` tomado). Archivos: `docs/PENDIENTES.md`.

## [Interno] — 2026-09-07 · H-08: el CI dio verde sobre REQ-017 sin medir ninguno de sus criterios
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

**Medido en el PR #43 (borrador), ejecución `hooks-en-linux` de 51 s: `833 PASS, 0 FAIL, 12 SKIP`.**
**Once de esos doce SKIP son los criterios de REQ-017** —CA-01 (las dos formas), CA-03, CA-04 (las
dos), CA-05 (i) y (ii) y CA-08 (las cuatro)—, todos con el mismo motivo declarado: *«no hay línea
base: el tag v1.32.1 no está en este clon»*. Causa de una línea: `actions/checkout@v4` clona con
`fetch-depth: 1` y **sin tags**, así que los árboles congelados que esos criterios materializan no
existen ahí. La **puerta requerida de `main`** dio verde sobre el único REQ del PR sin ejecutar
ninguna de sus comprobaciones.

**Las sondas no fallaron: `CA-06` pasó**, que es exactamente el criterio de «sin línea base, SKIP con
motivo, nunca PASS». El defecto está una capa más arriba — **un SKIP honesto, agregado a un resultado
global, se lee como verde**. Confirma CA-05 desde el otro lado: una comprobación contra línea base
congelada no necesita **envejecer** para abrirse; basta con que el entorno no tenga el tag. Y es un
forzador medido para la palanca «¿esta prueba mide algo?», que ya estaba en 1.33.0: se pensó para
casos **vacíos** y esto es un caso **lleno que no se ejecuta**, con la misma propiedad detrás.

Clase `instrumento`, dueño `desarrollador`. El arreglo (`fetch-depth: 0`) va con el delta de REQ-017,
no antes: encarece la puerta requerida y esa decisión ya estaba escalada con CA-05. Archivos:
`docs/PENDIENTES.md`, `docs/ESTADO.md`.

## [Interno] — 2026-09-07 · 1.33.0 se parte: las palancas primero, el núcleo a 1.34.0
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

**Decisión del propietario.** La ventana 1.33.0 había crecido durante la ventana anterior hasta **nueve
trabajos** —tres palancas de coste, la cuarta, REQ-011, dos barridos por estado, el rigor comprobable,
el caso J y una pasada de conformidad con cinco piezas—, ~8–10 h de reloj de agente. Es la forma exacta
en que se descontroló el ciclo 3. Se parte: **1.33.0 = las cuatro palancas de coste** (REQ-017 en curso,
la puerta de «¿esta prueba mide algo?», `tests/util/` y el adelgazamiento de `AGENTS.md`), ≈3 h, que
caben en un ciclo semanal; **1.34.0 = el núcleo por estado** más lo que ya tenía, ≈6 h.

**El motivo no es el calendario: es la atribución.** Las palancas abaratan el núcleo, así que medirlas
**antes** de empezarlo es la única forma de saber cuánto abaratan de verdad; juntas, ahorro y gasto se
mezclan — el mismo error que la línea base envenenada por la sonda desbocada de 1.32.1.

**El adelgazamiento de `AGENTS.md` se adelanta desde 1.34.0** y cierra la pregunta que quedaba abierta
en la cola de `docs/ESTADO.md`: son ~9 k tokens de impuesto fijo en **cada** subagente —una comisión de
subida de versión gastó 28 500 tokens para ~3 000 de trabajo real—, y 1.34.0 es la ventana con más
comisiones: adelgazarlo después sería pagarlo entero primero.

**El paralelismo entra en 1.34.0, y la palanca 3 es lo que lo desbloquea.** Hoy casi nada se despacha en
paralelo porque `skills/arnes-upgrade/SKILL.md` colisionaba en **15 de 15** pares de comisiones. Retirada
esa colisión, `tools/arnes-paralelo.sh` puede declarar `disjunto` de verdad — condición **necesaria y no
suficiente** mientras **SEC-020** siga abierto, y sin tocar el orden de fases, que no se paraleliza en
ningún caso. Archivos: `docs/PLAN.md`, `docs/ESTADO.md`.

## [Interno] — 2026-09-07 · REQ-017 implementado: una sentencia, y la magnitud que no miente
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

**El arreglo es una sentencia.** `arnes_sin_cita` (`hooks/lib.sh`) abre ahora con
`case "$l" in *$'\r'?*)` en vez de `case "${l%$'\r'}" in *$'\r'*)`. La eliminación de sufijo **con
patrón** la resuelve bash probando cada posición —O(n) intentos de O(n)—, y preguntar «¿hay un CR con
al menos un carácter detrás?» es **la misma proposición**: el único CR que la eliminación podía retirar
es el final, y sólo si está al final. La guarda **no se movió**: sigue siendo la **primera sentencia del
único escáner**, que es la restricción anti-deriva que REQ-016 contrató — se abarata *cuándo* se paga,
no *dónde* vive. Medido: cociente de duplicación **3,95 → 1,90** (lineal); sección 32 **76,19 s →
9,60 s** (0,125×); banco completo **95,66 s → 45,14 s**; e inventario ordenado de 828 casos **idéntico
byte a byte**. Y las dos magnitudes de CA-08 juntas: **0 procesos añadidos** (5 = 5) **y** reloj
**0,998×** / **1,000×** en el camino de una cabecera normal — el arreglo no compró tiempo con un `fork`.

**Lo que sobrevive al arreglo.** `requirements/README.md` y su plantilla heredable ganan la **cuarta
forma prohibida** de criterio: **«(d) fijar la magnitud equivocada»**, con su caso medido —`CA-08` de
REQ-016 **se cumplía**, midiendo procesos correctamente, sobre una regresión de **10×** de reloj—, la
regla por propiedad (un criterio de coste declara **qué magnitud mide y por qué es ésa la que se
degrada**, y se escribe como **razón o propiedad estructural**, nunca como reloj absoluto), la tabla de
cómo se contrata cada pregunta, el **mínimo de k** como estadístico y su línea en la Definition of
Ready. `CA-08` de REQ-016 **no se reescribe**: está `completado` y se cumplió tal como estaba escrito.

**Banco:** dos secciones nuevas, `37-coste-del-escaner-1-escala` y `37-coste-del-escaner-2-la-seccion-caliente`
(17 casos; total **845**), que miden contra los árboles **v1.32.1** y **v1.32.0** materializados desde su
tag en la misma corrida, con **fail-before** en CA-03 y CA-04. Invariante nueva del corredor (CA-06):
**nada de una sección sobrevive a su sección** — al cerrarla se mira `jobs -pr`, se mata lo que quede y
la vuelta **aborta nombrando el archivo**; nació de la sonda que en 1.32.1 vivió 3 h 41 min y falseó una
línea base. **CA-09 medido, no movido:** la pared de los 60 s pasa de **≈ 0,94 MB** a **≈ 1,60 MB**;
sigue cuadrática por `arnes_norm_clave`, que es `SEC-030` y tiene dueño propio.

**Coste declarado, y va en rojo a propósito:** la sección 37/2 cuesta **~120 s** —76 de ellos son la
corrida heredada, que cuesta lo que costaba el defecto porque **es** el defecto corriendo—, así que el
banco completo pasa de 45 s a **~145 s**. CA-05 tal como está contratado hace la puerta requerida de
`main` **más lenta que la regresión que certifica**. Se implementa como está escrito y se escala la
decisión; el detalle y la alternativa, en `docs/qa/1.33.0.md`.

## [Interno] — 2026-09-07 · REQ-017: la primera palanca de coste de 1.33.0
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

Se abre la ventana **1.33.0** (gobernada por la instalación estable 1.32.1) con **REQ-017** en
`pendiente`, `Rigor: critico`, `Sensible a seguridad: sí`: `arnes_sin_cita` es **cuadrática** en la
longitud de línea por la eliminación de sufijo `${l%$'\r'}` (`hooks/lib.sh:1643`), que bash resuelve
probando cada posición — el banco pasa de 39 s a **92 s** y su ruta crítica de 7,6 s a **75,7 s**. Una
llamada normal **no** se resiente (0,1195 → 0,1188 s), y queda escrito para que nadie lo lea como una
regresión de usuario.

**La segunda mitad, que es la que importa:** `CA-08` de REQ-016 **se cumplía** —medía **procesos**, 4 = 4,
correctamente— mientras se degradaba el **reloj** 10×. Un criterio de coste que fija la magnitud
equivocada da verde sobre una regresión. REQ-017 contrata la corrección **y** el ojo: criterios de coste
como **cociente de duplicación** (el coste no crece más que linealmente) y como **razón contra una línea
base medida en la misma corrida**, nunca como reloj absoluto —un umbral en segundos lo falsea la carga de
la máquina, y esta ventana ya midió una sonda que sobrevivió 3 h 41 min a su comisión y envenenó una
línea base—. Causa: `H-07` (`instrumento`) de `docs/qa/1.32.1-hallazgos-vuelta-3.md` §5. `SEC-030` (la
pared de 60 s) queda **enlazado y fuera de alcance**: preexiste en los dos árboles y tiene dueño propio.

## [Cierre] — 2026-09-07 · Cierre documental de la ventana 1.32.1
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

`REQ-015` y `REQ-016` a `completado` **por la puerta**, con `Edit` y nunca por consola. `v1.32.1`
publicada, tag verificado contra los tres manifiestos, instalación estable actualizada con los hooks
**idénticos al tag**. Se registra lo que cruza a 1.33.0 con dueño y ventana: `SEC-020`, `SEC-030`,
`H-07`, `H-06` y el bloque derivado que publica un veredicto sobre una cabecera que la puerta se niega
a medir.

**La lección nueva, y apareció cuatro veces en una sola ventana:** *interrogar al mecanismo tiene una
vía nueva cada vez; interrogar a la propiedad no envejece.* Los cinco casos de banco vacíos, el barrido
de migración, el control de datos de cliente y el guardián del intérprete son el **mismo error de
forma** — preguntar por la **vía** cuando la propiedad es de **estado**. Es la columna vertebral de
1.33.0.

## [1.32.1] — 2026-09-07 · El parche que no parcheaba a la primera
> Origen: GitHub (commit de la ventana) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos`, `desarrollador`, `qa-tester` (Opus), `auditor-seguridad` · gobernado por la instalación estable **1.32.0**.

**Dos fallos en abierto en el mecanismo que gobierna a los demás proyectos.**

- **REQ-015 — `usuario/dinero`.** El temporal de **nombre fijo** de la continuidad destruía texto
  humano de `docs/ESTADO.md` con dos paradas simultáneas. El recurso compartido no era «el momento»:
  era el **inodo**, y un descriptor abierto mantiene esa ventana el tiempo que uno quiera. De ahí una
  reproducción **determinista** que sustituye a un caso que fallaba 1 de cada 25 veces.
- **REQ-016 — `contrato`.** Una **regresión bisecada**: 1.30.2 y 1.30.3 deniegan, **1.31.0 permite**,
  1.32.0 lo hereda. Un veredicto citado dentro de un comentario HTML de la cabecera cerraba un REQ
  `critico` **sin auditoría de seguridad aprobada**. Llegó por el informe de un proyecto consumidor.

**Lo que costó, y por qué se cuenta.** 15 comisiones, ~2,3 M de tokens medidos y **3 vueltas dev↔QA
agotadas**. El primer arreglo **no cerró el agujero**: el retorno de carro se descontaba **antes** de
escanear el rango, y `-\r->` se convierte en `-->`. Resultó tener **cuatro bocas** —el lector de
línea, la extracción del `tool_input`, la reconstrucción del `Edit` con el CR en disco y el mapa de
paralelismo—, y las cuatro se cerraron con una sola **pregunta cerrada**: *una línea de cabecera con
un CR que no es el que la termina no se puede medir, y una puerta que no puede medir no deja pasar.*

**Tres de los cuatro fallos en abierto de esta ventana los introdujo el propio parche**, y ninguno
salió de leer el código: los cuatro salieron de **medir la consecuencia**. QA rompió el arreglo del
desarrollador; el desarrollador se rompió a sí mismo midiendo; el auditor rompió lo que QA había
aprobado — dos veces.

**Añadido**
- Publicación concurrente sin colisión: temporal propio de cada proceso, **fail-closed** si no puede
  componer un nombre propio, y purga que retira sólo lo huérfano (REQ-015).
- El lector de cabecera tiene **noción de cita**: lo que vive dentro de un rango `<!-- … -->` no
  declara campo, con la misma regla en los **cuatro** lectores (REQ-016).
- **CA-12:** una cabecera con un CR interior no se puede medir → **DENY**, por medibilidad y no por
  veredicto. Con su fila en `AGENTS.md` §13 y en la plantilla heredable.
- El banco pasa de **683 a 828 casos**, en 41 secciones.

**Corregido**
- `arnes-paralelo.sh` ya no responde `disjunto` sobre un mapa citado dentro de un comentario.
- `arnes-lectura.sh` nombra la línea decorada que gobierna, sin cambiar el código de salida por eso.
- **Cinco casos del banco que no medían nada** y pasaban contra la versión con el agujero.
- El nombre de un proyecto consumidor, que estaba publicado en este archivo desde el PR #26.

**Residuales declarados, con dueño y ventana 1.33.0:** `H-07` (`arnes_sin_cita` es cuadrática sobre
líneas largas: el banco pasa de 39 s a 92 s; una llamada normal no se resiente, medido), `SEC-030` (la
pared de 60 s del hook se alcanza hacia 1,5 MB y `AGENTS.md` §13 no la enumera entre sus huecos), y el
bloque derivado publicando un veredicto que la puerta se niega a medir.

**Si corriste 1.31.0 o 1.32.0, audita tus REQ cerrados.** El parche cierra la puerta de aquí en
adelante; **no revisa lo que ya cerró**. El procedimiento está en `skills/arnes-upgrade/SKILL.md`
§ `Hacia 1.32.1`, y declara qué encuentra y qué **no** puede encontrar.

## [Interno] — 2026-09-07 · Write-back de SEC-024: el tapón, contratado (CA-12) — rama `cand/1.32.1`
> Origen: Interno (sin commit propio; entra en el commit de la ventana) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (REQ-016, `Rigor: critico`; origen: **hallazgo del auditor de seguridad** `docs/seguridad/registro-seguridad.md` § R-008, SEC-024, clase `contrato`).

**«CA-02 contrata el agujero; nada contrata el tapón.»** El auditor verificó que el código de SEC-024
cierra las dos caras del retorno de carro y aun así no firmó: el control vivía **sólo** en el código,
en 19 casos de banco y en el registro de seguridad, así que podía retirarse en la ventana siguiente
sin que ningún contrato lo notara — la deriva que `AGENTS.md` §9 prohíbe. Prosa de analista, cero
código, sin vuelta dev↔QA.

- **CA-12 (nuevo), por propiedad y no por sitio:** *una línea de la cabecera con un retorno de carro
  que no es el que la termina deja una cabecera que **no se puede medir**, y una puerta que no puede
  medir **no deja pasar** → DENY citando la línea*. Las dos caras —delimitador fabricado y clave
  fabricada— son **la misma** propiedad, marcadas como ejemplos no exhaustivos, con el sitio único de
  la lista de caracteres de control (`hooks/lib.sh`).
- **La denegación es por MEDIBILIDAD, no por veredicto, y eso es lo que se comprueba:**
  `Estado: comple\rtado` con todo en verde deniega **por la guarda**; resolverlo como **ausencia**
  incumple, porque la ausencia es lo que la puerta perdona.
- **Las tres fronteras dichas, para que nadie «arregle» esto rompiendo Windows:** el CR final es
  transporte (CRLF decide idéntico a LF), el cuerpo no se restringe y **reabrir** no se bloquea.
- **CA-04 acotada sin perder fuerza:** la tolerancia a la clave decorada fuera de los rangos sigue sin
  restringirse; se le añade la frontera de que opera sobre una cabecera **medible**.
- **Una fila nueva en la tabla de invariantes** de `AGENTS.md` §13 y **la misma** en
  `templates/AGENTS.md.tpl`: dejar una puerta nueva fuera de ese mapa es deriva. Sin ADR (describe lo
  construido; no cambia alcance ni decisión base).

## [Interno] — 2026-09-07 · Vuelta 2 del bucle dev↔QA de 1.32.1: la otra cara del CR, la que abre (rama `cand/1.32.1`)
> Origen: Interno (sin commit propio; entra en el commit de la ventana) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (REQ-016, `Rigor: critico`; origen: **hallazgos del auditor de seguridad** `docs/seguridad/registro-seguridad.md` § R-007, SEC-024 y SEC-025, vuelta 2 de 3).

**«No fabricar» tiene dos consecuencias opuestas, y la vuelta 1 sólo tenía caso para una.** Al dejar
de descontar el retorno de carro antes de escanear el rango, un `-\r->` deja de leerse como `-->` y el
rango queda **abierto** → deniega. Correcto. Pero para el **abre** la misma decisión se **invierte**:
un `<!\r--` deja de leerse como `<!--`, el rango **nunca se abre** y lo que el autor aparcó dentro del
comentario **gobierna**. Medido por el auditor sobre una cabecera base del corpus —`critico`, sin
ninguna declaración de `Seguridad:`—: añadirle un rango con el abre fabricado y un `Seguridad:
aprobado` dentro convertía un `deny` en `allow`. Con su control: la misma forma con `pendiente` dentro
denegaba, así que el `allow` venía **de la cita gobernando**. Y el sitio lo empeora igual que el
defecto original: un analizador de HTML trata `<!` seguido de algo que no sea `--` como *bogus
comment* y lo consume hasta el primer `>`, así que un renderizador puede **esconder** el bloque
mientras la puerta lo lee.

- **El remedio describe el ESTADO, no la vía** (sexta instancia de la misma lección): **una línea de
  la cabecera que contiene un CR que no es el que la termina deja una cabecera que no se puede medir
  → DENY**, citando la línea con el CR escrito `\r`. Cubre las dos caras y cualquier objetivo futuro
  del mismo carácter, porque no habla del objetivo sino del carácter.
- **De paso cierra la CLAVE fabricada**, que **no nace en esta ventana**: `Seg\ruridad: aprobado`
  cerraba un REQ `critico` desde **≤1.30.3** —`arnes_norm_clave` retira el CR después de la cita y
  fabrica la clave—, y los dos lectores coincidían, así que ningún criterio lo desmentía.
- **La guarda vive en el ESCÁNER, no en una boca.** Es la primera sentencia de `arnes_sin_cita`, el
  único escáner de cabecera del arnés, así que las cuatro bocas —lector de línea, `arnes_jq_str`, la
  reconstrucción del `Edit` con el CR en disco y `tools/arnes-paralelo.sh`— llegan a él con la línea
  cruda y ninguna puede alcanzarlo «ya limpia». El orden es **por construcción**, no por inspección.
- **No estrecha ninguna tolerancia y no toca el CRLF.** El CR que termina la línea sigue siendo
  transporte: un REQ guardado entero en CRLF cierra igual que en LF, con casos en las dos direcciones
  y el cruce que faltaba (CRLF **con** un comentario bien escrito en la cabecera). `Estado:
  comple\rtado` deja de leerse como estado terminal **por denegación, no por ausencia**, que es la
  dirección que el descarte de la vuelta 1 exigía.
- **Los informes dejan de mentir.** `tools/arnes-lectura.sh` decía «ningún valor anómalo», rc 0, sobre
  un documento que cerraba un `critico`: ahora lo nombra como anomalía y enseña la línea. Y
  `tools/arnes-paralelo.sh` respondía `disjunto` con rc 0 sobre una cabecera no medible: ahora
  **colisiona con motivo**, que es la dirección segura.
- **SEC-025 — una frase que prometía completitud y era falsa.** El barrido de migración busca `<!--`,
  así que no encuentra ni el delimitador de apertura fabricado ni la clave fabricada. **No se ensanchó
  el patrón**: la guía enuncia ahora la pregunta que no envejece —de **estado**, «cuáles de mis REQ en
  estado terminal NO cerrarían hoy»— **antes** de ofrecer ningún comando, y cada barrido por vía
  declara, junto al comando, que interroga una vía, qué vías conocidas no encuentra y que **no hallar
  nada no acredita ausencia de exposición**. La comprobación por estado va a **1.33.0** como
  `instrumento` y el texto lo dice.
- **Banco: 803 → 828 casos.** Sección 36 partida en **cinco** (la mitad 1 iba por 347 líneas y el
  límite es 400): la nueva trae los cuatro casos del auditor con su control, la clave fabricada, las
  dos bocas, la frontera bajo el primer `## `, reabrir, el CRLF en tres formas, los dos informes y un
  **diferencial `lib.sh` ↔ `campos-req.awk` de 80 cabeceras con CR por enumeración fija** (no semilla).
  Fail-before **contra el árbol de la vuelta 2**, no contra 1.32.0: **9 FAIL de 19**, y los 10 que
  pasan en los dos árboles son los controles. **0 forks añadidos** (4 = 4 procesos por llamada en el
  mismo camino de decisión) y el reloj del banco dentro del ruido (93,6 s contra 92,6–95,0 s).
- **Lo que NO se hizo, con su medida:** el fuzz ancho dentro del banco que pide **SEC-028** cuesta
  **45 s** para 2 700 cabeceras (+48 % sobre el banco), así que **no entra**; entra su rebanada del CR.
  SEC-028 sigue abierto y `instrumento` para 1.33.0. Fuera del banco se midieron **2 700 cabeceras con
  semilla fija y 0 divergencias**, más tres semillas de 900 y un control contra el árbol de la vuelta 2
  —también 0—, que es lo que prueba que la guarda **observa y no cambia lo que el escáner devuelve**.

Archivos: `hooks/lib.sh`, `hooks/guard-completado.sh`, `tools/arnes-lectura.sh`,
`tools/arnes-paralelo.sh`, `skills/arnes-upgrade/SKILL.md`, `tests/escenarios/hooks/run.sh`,
`tests/escenarios/hooks/README.md`, `tests/escenarios/hooks/secciones/36-*` (cinco archivos),
`docs/qa/1.32.1.md`.

## [Interno] — 2026-09-07 · Vuelta 1 del bucle dev↔QA de 1.32.1: el fail-open del CR, y cinco casos que no medían (rama `cand/1.32.1`)
> Origen: Interno (sin commit propio; entra en el commit de la ventana) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (REQ-016 y REQ-015, `Rigor: critico`; origen: **hallazgos de QA** `docs/qa/1.32.1-hallazgos.md`, vuelta 1 de 3).

**El parche de 1.32.1 no cerraba el fail-open que existía para cerrar, y QA lo midió.** Un **retorno
de carro suelto** en mitad de una línea **fabricaba** los delimitadores del comentario: los lectores
descontaban *todos* los CR **antes** de escanear el rango, así que `-\r->` llegaba al escaneo como
`-->` y `<!\r--` como `<!--`. Consecuencias medidas: un REQ `critico` **cerraba** con su
`Seguridad: pendiente` vigente y el veredicto autorizante **dentro** del comentario (`allow` también
contra 1.32.0: por esa vía el fail-open de 1.31.0 nunca se cerró), y un rango que **nunca** cierra
parecía cerrado, tragándose el `QA: pendiente` y cerrando por *ausencia* — esto último una
**regresión nueva** del propio parche, que 1.32.0 denegaba.

- **Se arreglan TRES bocas, no una.** El texto llega al lector por tres caminos y cada uno tenía su
  propio descuento global de CR: el lector de línea (`arnes_sin_cita`), la extracción del `tool_input`
  (`arnes_jq_str`, la vía `Write`) y la reconstrucción del documento resultante (`guard-completado.sh`,
  la vía `Edit` con el CR en disco). **La tercera no la había reportado nadie**: se encontró al
  arreglar la primera y ver que el ataque seguía dando `allow`.
- **La salida es una pregunta cerrada, no un patrón que ensanchar** (quinta instancia de la misma
  lección): el descuento del CR ocurre **después** del escaneo del rango, donde ya no hay delimitador
  que fabricar. Ninguna tolerancia cambia — el CRLF legítimo decide igual que el LF, con casos en las
  dos direcciones. En `arnes_jq*` el descuento no se retira (Windows entrega `jq` en modo texto) sino
  que se **estrecha** a lo que de verdad es transporte: el CRLF que termina cada línea y el CR final
  suelto que la sustitución de comandos deja colgando. Vive en `arnes_sin_cr_transporte`, **una** vez.
- **Las dos transcripciones, alineadas por el ORDEN.** `hooks/campos-req.awk` pierde su
  `sub(/\r$/,"")` de nivel de línea y gana un `gsub(/\r/,"")` justo donde bash lo hace. De paso se
  cierra una divergencia que **nadie había reportado** y venía de antes de esta ventana: un CR dentro
  de la **clave** (`Seg\ruridad:`) lo leía bash y no el awk. Cae del lado cerrado.
- **CA-11, nuevo: comentar una declaración la RETIRA.** La conducta existía y ningún criterio la
  decía. Su caso **compara** las dos formas —línea comentada y línea borrada— en vez de fijar qué
  campos perdona la ausencia: esa lista vive en un solo sitio, y esta ventana existe por una
  transcripción duplicada. Claves derivadas del lector, 15 parejas, y la excepción medida
  (`Seguridad:` en un REQ `critico` **deniega** igual que borrada). Fail-before real: **3 FAIL de 6**
  contra 1.32.0, donde la equivalencia no se cumplía.
- **Cinco casos del banco no medían nada** (`instrumento`, no afectaba al producto): la propiedad de
  CA-02 escribía el documento en disco **ya `completado`**, así que la puerta salía sin juzgar ninguna
  transición y las **62** bases eran todas `allow` — «ningún `deny` se volvió `allow`» era cierto **por
  vacío** en las 186 variantes; la paridad de los dos lectores comparaba **vacío contra vacío** (un
  `$BASHPID` evaluado dentro de un `$( )`); el caso del hueco afirmaba lo que una lectura vacía siempre
  da; y la guarda de CA-08 pasaba sobre una función que **no existe** en 1.32.0. El tell estaba a la
  vista en los cuatro: **pasaban contra los hooks con el fail-open**.
- **La guarda que faltaba, y ahora es criterio:** una propiedad «ningún `deny` se volvió `allow`»
  **aborta** si el número de bases que deniegan es **0**. La anterior miraba el *tamaño* de la cosecha,
  no si tenía dientes.
- **El banco:** **803 casos** (era 791) y la sección 36 en **cuatro** archivos por el límite de 400
  líneas que el propio banco se impone. Y **más barato que antes**: **39,1–42,4 s** contra 44,2 s, con 12
  casos más y la propiedad midiendo de verdad — porque sólo se varían las **42** cabeceras que
  deniegan, y una base que ya permite **no puede** violar la propiedad. Fail-before por sección contra
  1.32.0: 19/28, 2/4, 3/6 y 6/17. Pass-after: **802 PASS · 0 FAIL · 1 SKIP** en **5 vueltas
  completas** sin una intermitencia, autoprueba **73 PASS**, cuadre en verde.
- **Coste, sin subir:** **5** procesos por llamada en el mismo camino de decisión (1.32.0, sin el
  parche y con él) y **6** por parada en régimen. REQ-015 comprobado y sin tocar: fail-closed 5/5, los
  cinco puntos de publicación, y la carrera determinista 7 FAIL contra 1.32.0 · 23 PASS en 5 vueltas.

Detalle de las mediciones, con las **dos retractaciones** de la vuelta 1: `docs/qa/1.32.1.md`.

## [GitHub] — 2026-09-07 · REQ-016: la cabecera tiene noción de cita — un veredicto citado dentro de un comentario HTML ya no cierra un REQ (rama `cand/1.32.1`)
> Origen: GitHub (rama `cand/1.32.1`) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (REQ-016, `Rigor: critico`, origen: **informe de regresión de un proyecto consumidor**, clase `contrato`).

**El defecto, sin eufemismo.** Un REQ **`critico`** cuyo veredicto de seguridad vigente **no**
autorizaba el cierre **cerraba** si en su cabecera había un rango `<!-- … -->` con una línea que
empezara por la clave del campo y un valor autorizante — **incluso diciendo el propio comentario que
era histórico**. Vale para cualquier campo de la cabecera por el mismo camino: el veredicto de QA, la
clase de un hallazgo bloqueante, el nivel de rigor, la sensibilidad. Llegó **bisecado** por el
reportante ejecutando cuatro guardianes instalados contra el mismo payload: **1.30.2 y 1.30.3
deniegan, 1.31.0 permite, 1.32.0 lo hereda**.

- **Tres reglas correctas por separado, y el sitio lo empeora.** La tolerancia de énfasis en la
  **clave** (nacida en 1.31.0, y que cerró un fail-open real), que estos campos toman la **última**
  aparición de la cabecera, y que el lector **no tenía noción de cita**. Juntas: cualquier línea que
  **empiece** por la clave —viva donde viva— era el veredicto vigente. Y el lugar donde un proyecto
  disciplinado escribe «este veredicto es histórico» es precisamente un comentario HTML: **quien mejor
  documentaba la historia de sus veredictos se exponía más**.
- **El arreglo es una pregunta cerrada, no más tolerancia.** `arnes_sin_cita` (nueva, en
  `hooks/lib.sh`) retira los rangos `<!-- … -->` de la línea antes de normalizar la clave, y
  `arnes_campo_linea` es **la única puerta de entrada** de un lector de cabecera, para que ningún
  recorrido pueda quedarse con la mitad de la regla — que es exactamente cómo nació el defecto. El
  hueco del rango se sustituye por **un espacio, nunca por nada**: pegar los dos extremos fabricaría
  una clave que nadie escribió. Es la cuarta instancia de una lección propia (`AGENTS.md` §13,
  `ADR-002`, SEC-020): cuando un mecanismo interpreta texto humano libre, ensanchar la tolerancia no
  gana la clase; el rango, en cambio, está **delimitado**.
- **Un rango que abre y no cierra: DENY, y nunca allow por ausencia.** Con el rango abierto la cabecera
  no se puede **medir** —no se sabe qué veredictos se quedaron dentro— y una puerta que no puede medir
  no deja pasar. Y hubo que hacer explícito el caso en que el rango se traga **la propia línea del
  estado**: si no, se resolvía como *ausencia*, y la ausencia es justo lo que la puerta perdona. La
  denegación exige que **haya un intento de cierre**: denegar toda edición de un REQ con un comentario
  mal cerrado sería friccion constante, y la fricción termina con alguien apagando el guard.
- **Lo que NO se recortó, y es un criterio (CA-04).** La tolerancia de la clave decorada sigue
  gobernando **fuera** de los rangos. Exigir la clave a columna cero y sin decorar reabría por
  construcción el fail-open que esa tolerancia cerró. Lo que faltaba no era la tolerancia: era **acotar
  dónde se aplica**.
- **Un lector, dos bocas, y se comprueba.** `hooks/campos-req.awk` recibe la transcripción declarada de
  la misma regla, y el banco alimenta el **mismo documento** a los dos lectores y compara los seis
  campos ya normalizados por la misma cola. Se arrastró `tools/arnes-paralelo.sh` al lector único: leía
  el interior de un comentario como una declaración de `Archivos:`.
- **`tools/arnes-lectura.sh` nombra la línea que gobierna, y NO es una anomalía.** El residual que
  queda tras acotar: una línea decorada **fuera** de todo rango puede gobernar, y la produce el **corte
  de un párrafo**, no su contenido. Se hace visible en su propio bloque y **sin cambiar el código de
  salida**; sólo cuando existe **otra** declaración del mismo campo y manda la decorada es anomalía con
  salida ≠ 0. Meterlo entre las anomalías repetiría el caso medido de **28 de 42 anomalías falsas
  enterrando las 14 reales**: un informe que grita por lo inofensivo deja de leerse. Y el conjunto de
  campos ya **no se enumera** en el informe: se deriva del lector de `hooks/lib.sh`.
- **La invariante se ejerce sobre el corpus, no sobre un ejemplo.** «Insertar un rango en una cabecera
  no convierte ningún `deny` en `allow`»: **58 cabeceras** cosechadas por glob del directorio de
  secciones —el sitio único del corpus, con las claves derivadas de `lib.sh`— × 3 posiciones = **174
  variantes**. Las dos fronteras que la propiedad **no** cubre están escritas y tienen su caso:
  *comentar* una línea que ya existía es **retirar** una declaración, no añadir un rango; y un `## `
  dentro de un rango sigue terminando la cabecera, así que lo de detrás no es cabecera para nadie.
- **El banco:** dos secciones nuevas (`36-…-1-la-puerta`, `36-…-2-los-lectores`; partido porque su
  propia autoprueba no admite un archivo de sección de más de 400 líneas), **43 casos**, total
  **791**. Fail-before contra el árbol heredado: **20 FAIL de 43**, y ningún caso marcado «(era
  ALLOW)» pasa. Pass-after: **790 PASS · 0 FAIL · 1 SKIP** (rutas Windows, sin `cygpath`) y
  `autoprueba-corredor.sh` **73 PASS · 0 FAIL**. Coste del lector: **5 procesos por llamada antes y
  después** (medido con los binarios instrumentados en el `PATH`, misma decisión en los dos lados).
- **Los textos que hereda un proyecto.** `skills/arnes-upgrade/SKILL.md` §`Hacia 1.32.1` dice sin
  eufemismo que **pudo cerrarse un REQ `critico` sin auditoría aprobada**, trae el comando que barre
  las cabeceras con comentario y deriva la pertenencia de versiones **del historial del lector**, no de
  una lista a mano. Y `templates/AGENTS.md.tpl` (con `AGENTS.md` §13) incorpora la regla **«la
  invariante manda sobre cualquier preferencia de herramienta»**, con su motivo medido: una preferencia
  por la consola desactivó una puerta sin que nadie relacionara las dos cosas — y **quien configura una
  sesión no suele ser quien lee §13**.

## [GitHub] — 2026-09-07 · REQ-015: la publicación concurrente ya no pisa el texto de una persona (rama `cand/1.32.1`)
> Origen: GitHub (rama `cand/1.32.1`) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (REQ-015, `Rigor: critico`, origen **H-12** / **SEC-015**).

**El defecto, y su alcance real.** `hooks/estado-derivado.sh` y `hooks/rotar-artefactos.sh` publicaban
por un temporal cuyo nombre se derivaba **sólo de la ruta del destino** —cinco sitios—, así que dos
paradas de agente simultáneas escribían **el mismo archivo**. Tras el `mv` de una, el inodo que la otra
tenía abierto con `O_TRUNC` **era ya el destino**, y su escritura tardía caía sobre él desde el byte 0:
justo donde vive lo que escribió una persona. Medido: **1 pérdida en 25** vueltas completas del banco,
**0 en 92** dirigidas — clase **`usuario/dinero`**, el único hallazgo de esa clase que ha producido
este arnés.

- **La causa medida es UNA de las cinco, y se atribuyó antes de arreglar.** La pérdida se observó en la
  sección 28-2, que corre rotación **y** derivación con cuatro paradas a la vez, así que el culpable no
  era deducible: la hipótesis del analista era que podían ser los dos. No lo eran. El
  `MANIFIESTO_BASE` del banco **no declara `rotacion`**, así que en ese caso `arnes_rotar_artefactos`
  sale en `ARNES_ROT_ACTIVO=false` **antes de tocar ningún archivo** (verificado con `bash -x`: cero
  temporales del rotador en ese escenario). La causa medida es el temporal de
  **`hooks/estado-derivado.sh`**. Los cuatro del rotador tienen la misma forma y el mismo riesgo —el
  origen que recortan puede ser un REQ o `ESTADO.md`— y entran por CA-01/CA-07, no por atribución.
- **El arreglo: el nombre del temporal es del PROCESO, no sólo del destino.** `arnes_tmp_publicacion`
  (nuevo, en `hooks/lib.sh`) forma `<destino>.arnes.tmp.<BASHPID>` **en el directorio del destino** —las
  dos condiciones de CA-01, que se verifican juntas: acreditar la ubicación sin la colisión es el error
  medido de R-003—. Sin componente única **no se cae al nombre compartido**: no se escribe nada y se
  avisa. La componente es `BASHPID` y no `mktemp` **por coste** (CA-11): una variable que el intérprete
  ya tiene, no un fork en el camino más caliente del arnés. Medido: **mismos procesos por parada** que
  1.32.0, en la parada que rota (14 externos) y en la de régimen (6).
- **El reverso, pagado: `arnes_purga_tmp`.** Un nombre único convierte un archivo que se sobrescribía a
  sí mismo en una familia de nombres, así que un temporal que sobreviva a su dueño ya no lo retira la
  parada siguiente. Se retira, y **sólo el que no tiene dueño vivo** (`kill -0`, builtin): borrar el de
  un proceso que sigue publicando sería crear el problema que este REQ cierra. También retira el nombre
  **compartido** que dejaron las versiones ≤1.32.0.
- **La reproducción es determinista, y eso era el trabajo (CA-05).** El caso que encontró el defecto
  falla **1 de 25** vueltas, y una prueba intermitente no acredita un arreglo. El punto de
  sincronización no es el reloj: es **el descriptor de archivo**. El caso hace de otra parada, abre el
  temporal compartido con `exec 9> …` (el `printf > "$tmp"` del hook partido en su apertura y su
  escritura), deja correr la parada real **entera** y sólo después completa su escritura — que con
  nombre compartido cae sobre el destino ya publicado. Tres pasos en orden fijo, sin nada que
  temporizar: **falla en todas las vueltas contra 1.32.0 y pasa en todas con el arreglo**.
- **Y el caso de ENOSPC se reescribió por el mismo motivo, sin perder el end-to-end.** Ya no se puede
  plantar el enlace a `/dev/full` en una ruta que aún no se conoce, así que el hook se lanza **con su
  stdin en una FIFO**: queda bloqueado en lo primero que hace —leer la entrada— mientras el caso planta
  el enlace usando `$!`, que es exactamente su `BASHPID`. El caso mide ahora dos cosas y ninguna por
  casualidad: la rama ENOSPC y que el temporal que el hook usa de verdad es el de su propio proceso.
- **Banco: 6 casos nuevos** en `tests/escenarios/hooks/secciones/28-rotacion-seccion-2-el-estado.sh`
  (741 → **747 PASS, 0 FAIL, 1 SKIP** explicado, cuadre por archivo y total). Los siete casos tocados
  **fallan con los hooks de 1.32.0 y pasan con éstos**, verificado con `ARNES_HOOKS_DIR`. Inventario
  contra `v1.32.0`: **seis adiciones y nada más** — ninguna línea suprimida, modificada ni cambiada de
  veredicto. El caso «CA-64.2 cuatro paradas a la vez» se conserva porque mide cuatro procesos de
  verdad, y **deja de tener causa conocida de inestabilidad abierta** (CA-06).
- **La superficie heredada, corregida en sus dos mitades (CA-08/CA-09).** `AGENTS.md` §13 y
  `templates/AGENTS.md.tpl` afirmaban **sin condición** que la continuidad «no toca nada fuera de los
  marcadores»; ahora dicen qué garantiza la máquina y qué no —no hay serialización, gana la última, y
  un proceso muerto puede dejar un temporal hasta la parada siguiente—. Y en el mismo cambio,
  `skills/arnes-upgrade/SKILL.md` deja de declarar el defecto **abierto** en «Hacia 1.24.0» y gana
  **«Hacia 1.32.1»**: que un proyecto **pudo perder texto de su `docs/ESTADO.md`** si despachó agentes
  en paralelo, cómo recuperarlo de git, y qué versiones están afectadas — la pertenencia se **deriva**
  del historial de `hooks/estado-derivado.sh` (comprobado tag a tag: **1.23.0 a 1.32.0**), con
  1.30.3/1.31.0/1.32.0 como ejemplos **no exhaustivos**.
- **`tests/escenarios/hooks/README.md`**: el total de casos decía **735** y ya eran 742 antes de este
  trabajo; queda en **748**, que es lo que declaran los cuadres.
- **Fuera de alcance, y sin tocar:** `tools/`, `.github/`, `agents/`, `.arnes/config.json`, `docs/` y
  el bump de `.claude-plugin/` (va al final de la ventana). No se añadió ningún `flock`: CA-04 no exige
  serialización y el contenido del bloque es derivado.

## [GitHub] — 2026-09-07 · v1.32.0 publicada, y el agujero del intérprete medido en carne propia
> Origen: GitHub (PR #39, fusión `ca6047a`, tag `v1.32.0`) · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos`, `desarrollador`, `qa-tester` (Opus), `auditor-seguridad` y la coordinadora.

**Publicada.** Tag `v1.32.0` sobre `ca6047a`, verificado contra los tres manifiestos, e instalación
estable actualizada de 1.31.0 a 1.32.0. `hooks-en-linux` en verde en 21 s.

- **REQ-012 y REQ-014 pasan a `completado`** con QA y Seguridad `aprobado`, cola de aprobaciones vacía
  y quality gates en verde. **REQ-013 queda en `en-revisión`** y cruza a 1.33.0 con `SEC-020` abierto
  (`contrato`): siete fail-open en tres vueltas sobre el mismo archivo dicen que la respuesta es
  **restringir la gramática** del campo, no un octavo parche. La herramienta se publica declarada como
  no fiable en los cuatro documentos que la nombran, y nada automático la consume.
- **La cola de aprobación resuelta por delegación**: el propietario aprobó publicar el 2026-09-07,
  incluido el cambio de `.github/workflows/banco.yml`, sobre el que el auditor no puso objeción de
  seguridad en R-004 y lo confirmó en R-006.
- **El agujero del intérprete, ejecutado por la coordinadora y registrado** (`docs/PENDIENTES.md`). Al
  cerrar los dos REQ escribió el estado terminal con un heredoc de `python3`: **`guard-completado` no
  lo vio**, porque el detector lee el texto del comando y la ruta vivía dentro del script. Se revirtió
  y se repitió con `Edit`, que sí pasa por la puerta y aceptó — el cierre era legítimo, lo que faltó
  fue que alguien lo comprobara. `AGENTS.md` §13 ya declaraba esa clase como el mayor hueco que queda;
  hasta hoy estaba **argumentada y no medida**. Es el forzador que le faltaba a **REQ-011, la puerta
  posterior** (1.33.0). Agravante nombrado: una instrucción de sesión que prefería `Bash` a las
  herramientas de edición acabó desactivando una puerta sin que nadie relacionara las dos cosas.
- **`docs/ESTADO.md`**: el tablero refleja el cierre, los diez hallazgos que cruzan con dueño y
  ventana, y la lección del ciclo — cuando un mecanismo interpreta texto humano libre, ensanchar el
  patrón no gana la clase. Tercera vez: detector de escrituras por `Bash`, guarda estática del banco
  (`ADR-002`) y campo `Archivos:`.

## [Interno] — 2026-09-07 · SEC-022: el documento que ANUNCIA el campo `Archivos:` prometía un fail-closed sin hueco (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (SEC-022, `instrumento`, de `auditor-seguridad` R-006; precisiones de QA-216).

**Una frase en un solo archivo. No se toca una línea de código** ni ningún otro documento:
`tools/arnes-paralelo.sh`, `hooks/`, `tests/` y `.github/` quedan idénticos.

- **`skills/arnes-upgrade/SKILL.md` §«Hacia 1.32.0» (SEC-022, `instrumento`).** La sección que un
  proyecto lee **para decidir si actualiza** anunciaba el campo `Archivos:` y
  `tools/arnes-paralelo.sh` afirmando que «el fail-closed vive en la herramienta», y **no mencionaba
  SEC-020 en ninguna parte**: una promesa más fuerte que lo que la máquina cumple, justo en el
  documento que la anuncia. Es la **tercera** vez de esta clase en este archivo (SEC-015 y SEC-016,
  una frase cada una). Ahora el fail-closed se enuncia **con su excepción**: vale para el espacio del
  campo **salvo** el marcado de Markdown **por elemento**, donde el desenvoltorio arranca el par
  exterior y la herramienta responde `disjunto` con rc 0 sobre rutas que no existen (**SEC-020**,
  *del propio arnés* —el proyecto que lee esto no tiene ese identificador en su registro—,
  `contrato`, **abierto**, ventana 1.33.0); las rutas se declaran **desnudas** y un `disjunto` sobre
  un campo decorado no se toma por bueno.
- **Enunciado por propiedad, no por lista de dos (QA-216).** El límite se escribe como «marcado de
  Markdown **por elemento**» con tres ejemplos —`` `a.sh`, `b.sh` ``, `_a.sh_, _b.sh_` y
  `**a.sh**, **b.sh**`—, porque QA midió que `**` corrompe el mapa igual que los acentos graves y el
  subrayado: una enumeración de dos habría vuelto a ser un criterio más estrecho que el fallo. Y se
  dice lo que **sí** se lee bien, para no prohibir de más: envolver la línea **entera**
  (`` `a.sh, b.sh` ``) y decorar **un solo** elemento. Lo que falla es el marcado **repetido**.

**Puertas:** `bash -n` sobre los 10 `hooks/*.sh` y `tools/*.sh` → 0 errores; `jq -e` sobre
`hooks/hooks.json`, `.claude-plugin/plugin.json` y `.claude-plugin/marketplace.json` → válidos, los
tres manifiestos en `1.32.0`; banco completo **741 PASS · 0 FAIL · 1 SKIP** (el SKIP es el de rutas
con contrabarra, que sin `cygpath` sólo corre en Windows), `rc=0` y los dos cuadres —por archivo y
total— silenciosos.

## [Interno] — 2026-09-06 · La pata de herencia de SEC-014: el documento que heredan los proyectos describía una máquina que no existe, y el límite de SEC-020 escrito donde se escribe el campo (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (remediación **documental** de la pata 3 de SEC-014 y declaración del residual de SEC-020, hallazgos de `auditor-seguridad` §«Re-verificación de R-004»).

**Sólo documentación heredada. No se toca una línea de código:** `tools/arnes-paralelo.sh`,
`hooks/`, `tests/` y `.github/` quedan idénticos. Lo que se corrige es que el documento que gobierna
cómo se escribe el campo `Archivos:` —y que **heredan todos los proyectos** por `arnes-upgrade`—
afirmaba lo contrario de lo que la máquina hace.

- **`requirements/README.md` y `templates/requirements-README.md.tpl`: el párrafo invertido (SEC-014,
  pata 3, `contrato`).** Decía que «anotar elemento por elemento —`tools/x.sh (nuevo), hooks/lib.sh
  (modificado)`— **no es una forma admitida**» y que el REQ pasaba a `sin declarar`. Es **falso**:
  esa línea exacta es el primer caso del arreglo de SEC-014, la herramienta la **lee** y responde
  `colisiona` con el mapa completo, verificado en las cuatro posiciones del paréntesis. El párrafo
  describía la **variante propuesta** al despachar la comisión —«la regla vale sólo tras el último
  separador»— y que no se implementó, porque contradice la verificación **por conteo** que CA-03
  exige. Ahora dice lo construido: el paréntesis acompaña a **su** elemento, en cualquier posición;
  la coma **dentro** de un paréntesis **no separa** —con su reverso escrito: lo que va dentro no
  declara nada—; y lo que no se entiende sale `SIN DECLARAR` **con su motivo** y colisiona con todos,
  **nunca** `disjunto`. La dirección del error era la segura (el documento era más estrecho que el
  código, no más ancho), pero el riesgo real no era un falso `disjunto`: era que alguien «arreglara»
  el código para que cuadrara con la nota y **regresara SEC-014 entero**.
- **El límite que faltaba, dicho donde se escribe el campo (SEC-020, `contrato`, ABIERTO).** Párrafo
  nuevo: el marcado de Markdown **por elemento** —`` `a.sh`, `b.sh` `` o `_a.sh_, _b.sh_`— **no es
  fiable**, porque el desenvoltorio arranca el par **exterior**, que pertenece a dos elementos
  distintos, y la herramienta responde `disjunto`/rc 0 sobre un mapa de rutas que no existen. Se
  escribe como **recomendación operativa con su causa** —las rutas van **sin decoración**—, no como
  promesa de la máquina; envolver la línea **entera** sigue funcionando y por eso la tolerancia
  anterior se mantiene enunciada igual.
- **`AGENTS.md` y `templates/AGENTS.md.tpl`: `disjunto` es necesario y no suficiente.** La
  instrucción «sólo se despacha en paralelo sobre REQ que `tools/arnes-paralelo.sh` declare
  disjuntos» **no se retira** —sigue siendo obligatoria y sigue siendo la buena—: se **acota**.
  Mientras SEC-020 esté abierto, un `disjunto` sobre un campo **decorado** no autoriza nada; se
  limpia el campo y se vuelve a preguntar. Mandar confiar sin reservas en una herramienta con un
  fail-open abierto es la misma clase de afirmación más ancha que lo construido que `ADR-002`
  prohíbe.
- **`requirements/REQ-013.md`:** una fila de Historial con el antes → después de los dos textos y su
  causa. **Ninguna cabecera de REQ se toca**: SEC-020 sigue declarado abierto y cruza la ventana con
  el REQ, por decisión de la coordinadora —siete fail-open en tres vueltas sobre el mismo archivo
  dicen que el problema no son los siete casos, sino que el campo tolera **decoración libre**; la
  respuesta de fondo es **restringir la gramática** del campo, que es un cambio de contrato y va a
  1.33.0—.

**Espejo verificado:** el `diff` entre `requirements/README.md` y
`templates/requirements-README.md.tpl` sigue mostrando exactamente los mismos **tres** hunks que
antes del cambio (el título, el párrafo de adopción propio de este repositorio y el índice de REQ);
la sección del campo `Archivos:` queda **idéntica** en los dos archivos.

**Puertas:** `bash -n` sobre los 10 `hooks/*.sh` y `tools/*.sh` → 0 errores; `jq -e` sobre
`hooks/hooks.json`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` y
`.arnes/config.json` → válidos, los tres manifiestos en `1.32.0`; banco completo **741 PASS · 0
FAIL · 1 SKIP** (742 casos; el SKIP es el de rutas con contrabarra, que sin `cygpath` sólo corre en
Windows), `rc=0` y los dos cuadres —por archivo y total— silenciosos.

## [Interno] — 2026-09-06 · bump de versión a 1.32.0 en los tres manifiestos (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador`.

Cambio mecánico de tres valores, previo a la fusión y al tag `v1.32.0`. No toca comportamiento:
sube la versión declarada de `1.31.0` a `1.32.0` en `.claude-plugin/plugin.json`,
`.claude-plugin/marketplace.json` (metadata y entrada del plugin) y `arnes_version` de
`.arnes/config.json`. Los tres viven dentro de `codigo_app.globs` de este repositorio —el
manifiesto es la fuente de verdad ejecutable de las invariantes—, así que el bump es trabajo del
`desarrollador` y no de la coordinadora: coste aceptado y ya anotado en el propio manifiesto.

Con esto desaparece el desajuste que el bloque derivado de la parada venía señalando entre la
versión instalada del plugin y la del árbol candidato.

**Puertas:** `jq -e` sobre los tres manifiestos y sobre `hooks/hooks.json` → válidos; las dos
versiones de `.claude-plugin/` coinciden entre sí y con `arnes_version` (`1.32.0`); `bash -n` sobre
los 10 `hooks/*.sh` y `tools/*.sh` → 0 errores; banco completo **741 PASS · 0 FAIL · 1 SKIP** (el
SKIP es el caso de rutas con contrabarra, que sin `cygpath` sólo corre en Windows) con los dos
cuadres —por archivo y total— silenciosos y `rc=0`.

## [Interno] — 2026-09-06 · Auditoría R-004 de 1.32.0: el sexto fail-open (un paréntesis intermedio borraba medio mapa), la promesa de concurrencia que estaba medida falsa y dos frases que prometían de más (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (remediación de los hallazgos de `auditor-seguridad` §R-004).

**La forma del hallazgo, que es lo que se arregla:** una regla escrita para un **valor único**
aplicada a un campo de **lista**, y dos frases de documentación más anchas que la máquina que las
respalda. Lo primero borraba la mitad del mapa **en silencio** y respondía «adelante»; lo segundo le
promete a quien actualiza el arnés una garantía que está **medida falsa** — y en la versión que
existe justamente para despachar comisiones en paralelo, que es el escenario que dispara el fallo.

- **`tools/arnes-paralelo.sh`: el sexto fail-open, y el peor (SEC-014, `contrato`).** `Archivos:` es
  una **lista** y se le aplicaba la regla del paréntesis de un **veredicto**: si el valor acaba en
  `)`, corta en el **primer** `(`. Resultado medido: `tools/x.sh (nuevo), hooks/lib.sh (modificado)`
  se quedaba en `tools/x.sh`, todo lo demás desaparecía **antes** de validarse —sin motivo, sin bajar
  el recuento, sin cambiar el código de salida— y la herramienta contestaba `disjunto`/**rc 0** sobre
  un mapa que ella misma había truncado. **La asimetría iba hacia el lado que abre:** anotar *todos*
  los elementos —lo prolijo, y lo que la plantilla enseñaba— abría el mapa; dejar el último desnudo lo
  cerraba. Ahora la lista **se separa primero** —y el separador es la coma que **no** está dentro de
  un paréntesis, porque la evidencia lleva comas— y la **misma** función compartida se aplica **a cada
  elemento**: los dos archivos llegan al mapa y el par sale `colisiona`/rc 1 en **las dos
  direcciones**. Lo que no es un elemento tampoco se traga en silencio: una anotación suelta entre
  comas, o un paréntesis sin cerrar, salen `SIN DECLARAR` **con su motivo**.
- **La tolerancia deja de enseñarse sin su límite.** `requirements/README.md` y
  `templates/requirements-README.md.tpl` dicen ahora dónde vale el paréntesis de evidencia —acompaña
  a **un elemento**, entre paréntesis balanceados— y qué pasa con lo que no se entiende: se dice y
  colisiona. Una tolerancia enseñada sin su límite es una invitación a escribir la forma que abría.
- **`--json` podía emitir JSON inválido (SEC-018, `instrumento`).** El escape cubría `\` y `"` y no
  los caracteres de **control**: un tabulador en el motivo —o un tabulador vertical dentro de una
  ruta, que no es `[:blank:]` y por tanto pasa el filtro— producía una salida que `jq` **rechaza**, y
  en el segundo caso con **rc 0**. El modo JSON es justo el que consume una máquina. Se escapan, sólo
  cuando los hay y sin un proceso más.
- **`skills/arnes-upgrade`: la promesa de no-corrupción concurrente, corregida antes de publicar
  (SEC-015, `contrato`).** La nota le decía al usuario que las reescrituras concurrentes de
  `docs/ESTADO.md` son «idempotentes, no se corrompen». Está **medido falso**: el bloque derivado
  publica por un temporal de **nombre fijo** y QA perdió el texto **humano** del archivo **1 vez de
  25**. Ahora la nota separa lo que sí garantiza —bloque derivado, recalculado entero, sólo entre sus
  marcadores— de lo que **no**: dos paradas simultáneas no están serializadas, con el consejo
  (versionar el archivo o apagar el bloque mientras dure el paralelo) y el arreglo anunciado para
  **1.32.1**. El defecto vive en `hooks/` desde 1.30.3 y **no** se toca aquí: esta versión sube la
  **frecuencia** del escenario, así que lo que no puede viajar es la frase.
- **Y el «límite honesto» de la guarda estática llega a la superficie que leen los terceros
  (SEC-016, `instrumento`).** `ADR-002` estrechó la invariante 1 y el README del banco lo dice; la
  nota de `arnes-upgrade` —lo único de esto que un proyecto lee— la seguía enunciando en su forma
  ancha y prometía «las tres invariantes intactas». Ahora dice que la comprobación es **estática y
  sobre funciones**, que un juez por indirección se le escapa, y que es una **barandilla, no una
  jaula**.
- **Banco:** `secciones/35-arnes-paralelo-fail-open.sh` pasa de **19** a **26** casos (**742** en
  total). Los cinco nuevos fallan contra la herramienta auditada y los **dos controles** pasan antes y
  después; la simetría se prueba con `sim_check`, en los dos órdenes, por propiedad.
- **Quedan abiertos y con ventana ajena:** **SEC-017** (precedencia de un `Estado:` duplicado, 1.33.0)
  y **SEC-019** (los 54 casos que pasan con su hook a `exit 0`, 1.35.0).

**Puertas:** `bash -n` sobre los 10 `hooks/*.sh` y `tools/*.sh` y sobre los 40 archivos del banco (3 puntos de entrada + 37 secciones);
`jq -e` sobre `hooks/hooks.json`, `plugin.json` y `marketplace.json`; banco completo **741 PASS · 0
FAIL · 1 SKIP** —el SKIP es el caso de rutas con contrabarra, que sin `cygpath` sólo corre en
Windows— con cuadre por archivo y total; autoprueba del corredor **73 PASS · 0
FAIL**; `git diff v1.31.0 -- hooks/` **vacío**; `tools/arnes-paralelo.sh` sobre este repositorio no
declara `sin declarar` ningún REQ y deja el árbol idéntico.

## [Interno] — 2026-09-06 · Vuelta 3 (la última) del bucle dev↔QA de 1.32.0: los dos fail-open que quedaban, el puntero que mentía y la prueba escrita en una sola dirección (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (arreglo de los hallazgos de código de la vuelta 2).

**La forma del hallazgo, que es lo que se arregla:** un arreglo que funciona en un orden y falla en
el contrario, y una prueba escrita **sólo en el orden que pasa**. La vuelta 1 encontró el choque del
archivo que aún no existe contra el glob ajeno y lo perdía después, al construir la clave del par
suponiendo un orden de descubrimiento que la propia pasada de futuros rompe; y los dos casos que lo
vigilaban ejercitaban la mitad que ya funcionaba. Un guardián que prueba una sola dirección de una
relación simétrica acredita lo que ya andaba — es la cuarta vez en este ciclo.

- **`tools/arnes-paralelo.sh`, los dos fail-open de clase `contrato` (QA-202, QA-211).** La clave del
  par **se ordena al escribirla**: el par {a,b} es el mismo par se mire por donde se mire, y el
  archivo futuro colisiona con el glob y con su directorio **en las cuatro direcciones medidas**
  (antes: `colisiona`/rc 1 en una, `disjunto`/rc 0 en la contraria). Y un REQ del que no se extrae
  `Estado:` de la cabecera —campos debajo del primer `## `, sin `Estado:`, o archivo de 0 bytes—
  deja de caerse del análisis con un `continue` **mudo** en el modo sin argumentos: pasa por el sitio
  único que el criterio declara, se declara `SIN DECLARAR` con su motivo, colisiona con todos, sale
  ≠ 0 y **el recuento no baja en silencio**. La herramienta se contradecía consigo misma: el mismo
  archivo, pasado como argumento explícito, sí se evaluaba.
- **Y el residuo `instrumento` de la misma clase (QA-212).** La lista cerrada de marcadores de
  posición deja de ser la red: la red es la **propiedad** —un elemento que no existe, del que ningún
  ancestro existe y que no tiene forma de archivo no designa nada—, así que `n/d`, `s/d`, `n.a.`,
  `t.b.d.` y `pendiente.` caen sin alargar ninguna lista. La lista sobrevive sólo para dar un mensaje
  mejor, y por eso ahora sí es de verdad no exhaustiva.
- **El puntero de la invariante 1 deja de mentir, y la máquina lo vigila (H-01).** El README del banco
  enumeraba **seis** ayudantes «que ejecutan un hook» con la palabra **todos** delante —era falso:
  `corre`, `ver_corre` y `mide_hook` no estaban— y declaraba un sitio único distinto del que declaraba
  el criterio. Ahora el conjunto **no se enumera en ninguna parte**: se enuncia la propiedad («todo el
  que el corredor define al nivel superior antes del despacho»), se da la línea de `awk` que lo deriva,
  y la invariante dice **qué** obliga —dictar PASS/FAIL, no ejecutar— en vez de a quién. Tres casos
  nuevos impiden la reincidencia: ningún ayudante fantasma, **ninguna línea que reenumere** el
  conjunto, y la afirmación normativa comprobada sobre el corredor.
- **Dos agujeros de diagnóstico del corredor (`instrumento`, H-10, H-11).** `diag` garantiza el salto
  de línea final —con `sed`, un stderr sin `\n` pegaba la línea del caso siguiente y el cuadre perdía
  un caso acusando al número declarado—; el arreglo estaba hecho en dos secciones y no había llegado
  al ayudante compartido, que es donde vale para las 37. Y «guarda equivalente» deja de ser una lista
  de tres literales atada al nombre de una variable, que producía **ABORT sobre código correcto**:
  pasa a propiedad, con la distinción de mayúsculas **medida** y no estética (`[ -n "$FILTRO" ]` está
  en 31 ayudantes de sección y no es una guarda).
- **El arreglo del método, no del caso: `sim_check`.** La simetría se prueba **por propiedad** — el
  ayudante corre el par en los dos órdenes y exige que coincidan en veredicto y código de salida —,
  así que un caso nuevo cubre las dos direcciones sin que nadie tenga que acordarse. Revisión del
  resto: los **20** pares de las secciones 34 y 35, medidos en las dos direcciones, dan **0
  asimétricos** con la herramienta de esta vuelta y **2** con la anterior (exactamente los dos de
  futuros), lo que sitúa la dependencia del orden en el único camino que la tenía.
- **Pruebas, con fail-before medido en las dos direcciones.** Sección 35: **10 → 19** casos; contra la
  herramienta anterior fallan los **6** que acreditan arreglo y pasan los **3** controles positivos.
  Autoprueba: **64 → 73**; contra el corredor anterior fallan los de H-10 y H-11, y contra el README
  anterior el de la reenumeración (`linea 62 con 6 ayudantes`). Banco: **726 → 735** casos,
  `734 PASS, 0 FAIL, 1 SKIP`, cuadre por archivo y total en **735**. Inventario contra v1.31.0: **0**
  líneas suprimidas o modificadas, 52 añadidas, **todas** de las dos secciones de `arnes-paralelo`.
  `git diff v1.31.0 -- hooks/` **vacío** y `git status --short -- hooks/` sin entradas: el mecanismo
  sigue byte a byte el publicado.
- **Lo que NO se ha tocado, y por qué.** **H-03** (la evasión de la guarda estática con tres eslabones)
  cierra con **residual declarado**: ensanchar el reconocedor cubre formas, nunca la clase, igual que
  el detector de escrituras por `Bash`. **H-12** (la carrera del temporal de nombre fijo en
  `hooks/estado-derivado.sh`) es **preexistente**, vive en `hooks/` —que CA-22 prohíbe tocar aquí— y
  su decisión está con el propietario. **QA-205** (`~`, enlaces simbólicos, mayúsculas) sigue en deuda
  con dueño: ninguno cambia hoy el veredicto de ningún REQ real.

## [Interno] — 2026-09-06 · Vuelta 1 del bucle dev↔QA de 1.32.0: los cuatro fail-open de `arnes-paralelo` y la guarda del corredor que se evadía (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (arreglo de los hallazgos de código de la vuelta 1).

**La forma del hallazgo, que es lo que se arregla:** las dos herramientas nuevas de esta candidata
respondían **verde cuando no podían saberlo**. `tools/arnes-paralelo.sh` decía `disjunto` con rc 0
ante un REQ que no podía leer, ante un marcador de posición y ante el archivo que aún no existe; y
la guarda estática del corredor —la que impide que una sección dicte PASS/FAIL sobre un hook sin
guarda— se rodeaba escribiendo **dos funciones en vez de una**. Un control que se evade sin ocultar
nada no es un control.

- **`tools/arnes-paralelo.sh`, cuatro fail-open (`contrato`, QA-201 a QA-204).** Un REQ que no se
  puede leer entero —sin permiso o truncado por un byte NUL— **se declara y contamina el veredicto**
  en vez de desaparecer del análisis; el archivo que **todavía no existe** colisiona con el glob que
  lo alcanzará y con el directorio que lo contendrá; un **marcador de posición** (`TBD`, `todo`,
  `n/a`, `-`, `?`) deja de leerse como ruta futura, juzgado por propiedad y no por lista; y
  `Archivos:` duplicado resuelve con **el último**, igual que `arnes_campos_req`. De propina y de la
  misma clase: `--json` declaraba los archivos que un patrón casa hoy donde el texto declara el
  patrón, porque la cadena se partía sin desactivar el globbing.
- **La guarda estática del corredor sigue ahora la cadena de llamadas (`contrato`, H-03).** Las
  propiedades «ejecuta un hook» y «lleva guarda» se propagan por las llamadas dentro del archivo
  hasta punto fijo: da igual en cuántos trozos se parta el ayudante. Ningún ayudante del banco real
  queda señalado, así que **no se toca ninguna sección**.
- **Y tres agujeros de diagnóstico del propio banco (`instrumento`, H-04/H-05/H-06).** Nada en
  `secciones/` se queda fuera en silencio: un archivo que no casa `NN-<slug>.sh`, o un directorio que
  sí lo casa, **abortan nombrándose** en vez de ignorarse o de matar el cuadre con un `unbound
  variable`. Y `autoprueba-corredor.sh` —el único artefacto de la cadena sin la red que exige a todos
  los demás— declara su `AUTOPRUEBA_CASOS_ESPERADOS` y **se aplica el cuadre a sí misma**.
- **Pruebas, con fail-before medido.** 10 casos nuevos en
  `tests/escenarios/hooks/secciones/35-arnes-paralelo-fail-open.sh` (9 fallan contra la herramienta
  anterior; el décimo es el control positivo) y 13 en `autoprueba-corredor.sh` (9 fallan contra el
  corredor anterior). Banco: **716 → 726** casos, `725 PASS, 0 FAIL, 1 SKIP`; autoprueba: **51 → 64**,
  `0 FAIL`. La sección 34 se parte porque llegaba a 444 líneas y CA-18 fija el techo en 400.
- **El instrumento de verificación deja de ser ciego (H-08).** Con **todo indexado** (`git add -A`,
  sin commit), `git diff v1.31.0 -- hooks/` sigue **vacío** —el mecanismo no se ha tocado— y el paso
  de modos del CI, replicado literal, da **0 archivos malos**: puntos de entrada `100755` y secciones
  `100644`. Antes el control «pasaba» porque `git diff` no ve lo que no está rastreado.

## [GitHub] — 2026-09-06 · REQ-013: un mapa de archivos por REQ, para poder despachar dos comisiones a la vez (rama `cand/1.32.0`)
> Origen: GitHub (rama `cand/1.32.0`) · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos` (redacción del REQ) y `desarrollador` (esta implementación).

**La forma del hallazgo, que es el motivo del cambio:** el ciclo corrió **en serie** —tiempo de reloj
prácticamente igual a la suma del tiempo de agente, 0 comisiones solapadas en 25— y no porque una
regla lo prohibiera, sino porque **nadie podía decir por máquina qué dos comisiones no colisionan**.
Adivinar bien tres veces y mal la cuarta cuesta más que toda la serie que se ahorró.

- **La cabecera del REQ gana el campo `Archivos:`**: rutas o globs relativos a la raíz, separados por
  comas, o el literal `(ninguno)`. Documentado por **propiedad** —no por lista de globs válidos— en
  `requirements/README.md` y en `templates/requirements-README.md.tpl`, con su plantilla y su lugar en
  la Definition of Ready.
- **`tools/arnes-paralelo.sh` (nuevo, `100755`)** responde `disjunto` o `colisiona` **nombrando el
  archivo compartido**, para cada par de REQ, en texto o en `--json`. La intersección se resuelve
  **expandiendo los globs contra el árbol real**, no comparando cadenas: comparar cadenas declararía
  disjuntos `hooks/lib.sh` y `hooks/*.sh`, que es justo la forma de error que produce un conflicto de
  fusión. Un patrón que aún no casa con nada se conserva como ruta literal, porque un archivo que
  todavía no existe es exactamente donde dos comisiones chocan.
- **Una regla, un lector — y la regla es la normalización, no el mapeo.** El campo se lee con la
  normalización de `hooks/lib.sh` (recorte de la cabecera antes del primer `## `, clave decorada,
  desenvoltorio del marcado, paréntesis de evidencia). No hay ni un `grep '^Archivos:'` ni un
  `awk`/`sed` que reimplemente nada de eso. Y **`Archivos:` no entra en la lista de campos que leen
  las puertas**: un campo que no gobierna nada no vive en el lector que sí gobierna. **El diff de
  `hooks/` para este cambio es vacío**, y ésa es la comprobación.
- **No es una novena puerta, y es deliberado.** `guard-completado` y `guard-codigo` dan **exactamente**
  los mismos veredictos que en v1.31.0: un REQ sin el campo, o con el campo ilegible, cierra igual que
  siempre. El fail-closed vive en la **herramienta** —sin mapa no hay paralelismo, y colisiona con
  todos—, donde el coste de equivocarse es volver a la serie.
- **Y lo que la herramienta no responde, escrito en su propia salida:** evalúa **archivos**, nunca el
  **orden de fases**. `AGENTS.md` §6 y `templates/AGENTS.md.tpl` ganan la regla de despacho y las tres
  exclusiones **con su motivo**; las dos primeras —el auditor nunca antes ni a la vez que QA, QA nunca
  antes que el desarrollador— no se relajan en ningún caso. Sin esa línea, un `disjunto` se leería
  como permiso para producir una firma falsa.
- **El cuello, medido y no supuesto** (`docs/qa/1.32.0.md`): sobre el árbol de v1.31.0 colisionan
  **15 de 15** pares, y el archivo que los colisiona **todos** resultó ser
  `skills/arnes-upgrade/SKILL.md` (15/15), con `tests/escenarios/hooks/run.sh` en 10/15 y
  `hooks/lib.sh` en **1/15**. Se suponía que el cuello eran los dos monolitos: partir `hooks/lib.sh`
  no habría desbloqueado ni un par de este ciclo. Sin el número, la palanca siguiente se elige mal.
- **Coste, medido con los binarios instrumentados en el `PATH`:** 60 REQ y 200 archivos declarados en
  **127–245 ms** (techo 2 000 ms) y **1 proceso externo en total** —el `jq` del manifiesto— frente al
  techo de 2 por REQ leído. La herramienta **no** está registrada en `hooks.json`: añade **0 procesos**
  a la ruta de `Bash`, `Edit`, `Write` y la parada. El despacho ocurre una vez por ciclo, no una vez
  por comando.
- **Banco:** `tests/escenarios/hooks/secciones/34-arnes-paralelo.sh` (nuevo, **33** casos; total
  683 → **716**). Inventario ordenado antes y después: las **33** líneas nuevas y nada más — ningún
  caso cambió de veredicto y **ninguno** pasó de `deny` a `allow`. Contra los hooks de v1.31.0 la
  sección da **30 FAIL / 3 PASS**; los tres que pasan en las dos son los controles que deben pasar en
  ambas.
- **Cierre de una medición pendiente ajena:** CA-16 de REQ-014 quedó sin medir porque esta herramienta
  no existía. Medida ahora y anotada en su Historial y en `docs/qa/1.32.0.md`: dos comisiones de QA
  sobre secciones distintas dan `disjunto` en la candidata y `colisiona` por
  `tests/escenarios/hooks/run.sh` en v1.31.0.

## [GitHub] — 2026-09-06 · REQ-014: el banco en archivos por sección (rama `cand/1.32.0`)
> Origen: GitHub (rama `cand/1.32.0`) · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos` (redacción del REQ) y `desarrollador` (esta implementación).

**La forma del hallazgo, que es el motivo del cambio:** el banco —el artefacto por el que pasa toda la
validación del arnés— era **un solo archivo de 4.096 líneas con 33 secciones y 683 casos**. Dos
comisiones de QA no podían despacharse a la vez porque las dos habrían escrito en el mismo archivo
(en el ciclo 2 hubo **una** comisión para siete requerimientos), y cualquier comisión que tocara
cuarenta líneas tenía que leerlas todas. Un banco monolítico no es un problema de estilo: es un
cuello por el que pasa el 100 % de la validación y que sólo deja pasar a uno.

- `tests/escenarios/hooks/run.sh` pasa de banco a **corredor** (4.096 → 607 líneas): ayudantes
  compartidos, canario global, descubrimiento y los cuadres. Los casos viven ahora en
  `tests/escenarios/hooks/secciones/NN-<slug>.sh`, **35 archivos**, ninguno de más de 342 líneas.
- **Se descubren con un glob de bash**, en orden lexicográfico fijado con `LC_ALL=C` sólo durante la
  expansión y **sin arrancar `find`, `ls` ni `sort`**: el descubrimiento corre en cada vuelta y en
  Windows cada fork cuesta entre 1,2 y 6 s. Añadir o quitar una sección no toca ni una línea del
  corredor.
- **El cuadre gana el sujeto que le faltaba.** Cada archivo declara su `CASOS_ESPERADOS_SECCION` y el
  corredor exige las dos cosas: que cada sección cuadre con **su** número —el ABORT dice **cuál**
  archivo y cuántos casos de diferencia— y que la suma cuadre con `CASOS_ESPERADOS` (683, sin cambio).
  Un archivo sin su número declarado aborta con su nombre.
- **Canario de sección:** una sección que muere a mitad deja de ser indistinguible de una que pasó
  limpia. El subshell deja una marca al terminar el archivo; sin ella, ABORT con el nombre del archivo
  y su código de salida, y la vuelta sale ≠ 0.
- **Invariante 1 comprobada sobre el texto:** una función propia de una sección que ejecute un hook y
  dicte PASS/FAIL sin guarda contra la salida vacía aborta la vuelta antes de ejecutar nada, nombrando
  archivo y función. Delató a `tipo33`, cuyos casos de control esperaban silencio en `stderr` y
  habrían pasado en falso con el emisor mudo; se le puso la guarda.
- **Corrida parcial:** `run.sh secciones/07-*.sh` corre esa sección más el canario, suspende el cuadre
  total **diciéndolo** y sigue exigiendo el de la sección. Un selector que no casa con nada aborta en
  vez de degradar a filtro. El filtro por nombre de caso conserva su semántica de v1.31.0.
- `tests/escenarios/hooks/autoprueba-corredor.sh` (nuevo, 51 casos): certifica al corredor contra
  directorios de secciones sintéticos. Sus casos **no** entran en el inventario de 683, precisamente
  para que ese inventario se pueda comparar con el de la versión publicada anterior. Contra el
  corredor de v1.31.0 fallan 30 de ellos: sin ese par, los casos nuevos no prueban nada.
- `tests/escenarios/hooks/inventario.sh` (nuevo): inventario ordenado `veredicto · caso`, con los
  milisegundos normalizados. **El criterio central de este cambio no fue «el banco pasa»** —dos casos
  que intercambian PASS y FAIL dan el mismo total— sino el inventario **byte a byte idéntico** al de
  v1.31.0: 683 líneas, `diff` vacío, con tres corridas antes y tres después idénticas entre sí.
- `.github/workflows/banco.yml`: `bash -n` sobre `hooks/`, `tools/` y **todas** las secciones; el bit
  de ejecución comprobado en sus dos mitades (puntos de entrada `100755`, secciones `100644`, porque se
  hacen `source` y sueltas correrían cero casos en verde); y un paso nuevo para la autoprueba. El banco
  sigue corriéndose por el **mismo** punto de entrada que en local, nunca por una lista escrita en YAML.
- `tests/escenarios/hooks/README.md`: las tres invariantes actualizadas a la estructura nueva más una
  cuarta (una sección que muere se distingue de una que pasó limpia), cómo se añade una sección en tres
  líneas y por qué los modos de archivo son los que son.
- **Ni una línea de máquina:** `git diff v1.31.0 -- hooks/ tools/` **vacío**. Este cambio reorganiza
  **quien mide**, no lo medido — y si hubiera tocado un hook, la comparación del inventario no valdría
  nada.

## [GitHub] — 2026-09-06 · REQ-012: criterios por mecanismo, no por enumeración (rama `cand/1.32.0`)
> Origen: GitHub (rama `cand/1.32.0`) · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos` (redacción del REQ) y `desarrollador` (esta implementación).

**La forma del hallazgo, que es el motivo del cambio:** de los **20** hallazgos del ciclo 2, **7** no
fueron código defectuoso — fueron **criterios que decían algo falso sobre lo construido** (clase
`contrato`), y **uno** costó una vuelta entera del bucle (~50 min entre desarrollador, QA, control y
write-back). Las tres formas medidas: **enumerar** lo que el código reconoce (un criterio listaba tres
envoltorios de shell cuando el código toleraba siete), **fijar un número** que la medición desmiente
después (un máximo de 262 144 bytes que hubo que bajar a 131 072), y **exigir igualdad** donde
corresponde un techo («el mismo número de procesos que la versión anterior» declaró incumplida una
mejora de 1 fork a 0). No se arregla con más máquina: se arregla escribiendo la regla en vez de la lista.

- `requirements/README.md` (y su espejo `templates/requirements-README.md.tpl`): sección nueva
  **«Cómo se escribe un criterio que no se desmiente»** — las tres formas con su caso medido, la forma
  **mal** y la forma **bien**; la propiedad de pertenencia con puntero al sitio único y la marca
  `no exhaustivo`; el número declarado **operativo** o **de contrato** (y `de contrato` como
  fail-closed si no se declara); el coste como **techo con dirección admitida**; la corrección del
  criterio más estrecho que lo construido **y su reverso**, para que no se use como coartada para
  relajar criterios incómodos.
- `agents/analista-requerimientos.md`: tres casillas verificables nuevas en la **Definition of Ready** y
  un puntero a la sección, sin transcribir la regla por segunda vez.
- `agents/qa-tester.md`: un criterio mal formado es hallazgo de clase **`contrato`** contra el REQ
  **antes** de ejecutar la prueba, con su **forma** anotada en `docs/qa/<versión>.md`; el QA **no**
  reescribe el criterio.
- `agents/auditor-seguridad.md`: un control se describe **por propiedad, nunca por enumeración** —una
  lista de controles envejece hacia el lado que **abre**.
- `templates/AGENTS.md.tpl` §9: punto nuevo «criterio más estrecho que lo construido», que apunta a la
  sección y no la duplica.
- `skills/arnes-upgrade/SKILL.md`: sección `### Hacia 1.32.0` — qué llega, y que **no hay nada que
  migrar**: los REQ ya cerrados no se reabren ni se reescriben.
- `docs/qa/1.32.0.md` (nuevo): sección **«Coste del ciclo»** con la línea base del ciclo 2 escrita
  **antes** de medir nada, una única regla de conteo y el objetivo declarado como techo (hallazgos
  `contrato` de esas formas: no más de 3, línea base 7; vueltas del bucle causadas por ellos: 0, línea
  base 1), más el control anti-juego que impide bajar la métrica borrando criterios.
- **Ni una línea de máquina:** `git diff v1.31.0 -- hooks/ tools/` **vacío**; ningún campo nuevo en la
  cabecera del REQ, ninguna llave nueva en `.arnes/config.json` y ningún proceso añadido a ninguna ruta.
  La **forma** del hallazgo se anota sólo en el log de QA y nunca en el paréntesis de la clase, que es
  la entrada de `guard-completado`.

## [Interno] — 2026-09-06 · migración del andamiaje de este repositorio: 1.30.3 → 1.31.0
> Origen: Interno (migración de andamiaje, sin commit de versión) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (la parte del manifiesto) sobre el plan de `/arnes-upgrade` de la sesión coordinadora.

`arnes-upgrade` llevó este repositorio del andamiaje 1.30.3 al de 1.31.0. Plan y acreditación del
origen en `.arnes/migracion.md` (las 11 plantillas de `.arnes/plantillas-origen/` idénticas a
`v1.30.3:templates/`, sin `UNKNOWN` ni `CONFLICTO`).

- `AGENTS.md` §13 y `requirements/README.md`: cinco añadidos cada uno (coordinadora, ya aplicados).
  `PENDING_APPROVAL.md` ya traía su sección desde REQ-009.
- `.arnes/config.json`: bloques `veredictos` y `git` nuevos, y `rotacion._doc_artefactos` actualizado
  al texto de 1.31.0 (documenta la forma de sección: `glob` + `seccion`). Se copió el texto y el `_doc`
  de `templates/arnes-config.json.tpl` sin adaptaciones: los tres son idénticos a la plantilla.
- `.arnes/config.json`: `arnes_version` a `1.31.0` (Fase 5, al final y sólo tras verificar lo anterior;
  subirla antes haría creer a la ejecución siguiente que la migración está hecha).
- **Lo hizo el agente de código, no la coordinadora.** Desde 1.31.0 `.arnes/config.json` está dentro de
  `codigo_app.globs` de este repositorio (SEC-006 parte a, REQ-007 CA-53), así que la coordinadora ya no
  puede escribirlo. Es la consecuencia aceptada de esa decisión, y la Fase 5 va con ella.

**Lo que se dejó apagado a propósito, y por qué:**

- `veredictos.exigir_fecha` y `veredictos.caducan_con_codigo` en `false`. Los veredictos de este
  repositorio sí llevan fecha, pero encenderlas es una decisión de política: se toma en su propia
  ventana y con la medición delante, no dentro de una migración de andamiaje.
- `rotacion.activo` sigue en `false`. La rotación de la historia de un REQ no reconoce filas de tabla
  —medido: 0 entradas y 94 filas en los REQ de este repositorio—, así que encenderla hoy no rotaría
  nada. Queda en `docs/PENDIENTES.md` para 1.32.0 con su alcance.
- `limites` **no se declara**. Su propio `_doc` dice que es opcional, que el valor por defecto vive en
  el código y que se borre si no hace falta; ningún comando legítimo ha topado con el techo aquí.

**Lo único que nace encendido:** `git.activo: true` con la lista por defecto de la plantilla
(`clean -f`, `reset --hard`, `checkout .`, `restore .` y las cinco formas de `stash`). Este repositorio
la quiere porque aquí trabajan varios agentes en paralelo sobre el mismo árbol, que es exactamente el
escenario que la motiva. Verificado en vivo contra el guardián estable 1.31.0 (2fecae1): `git clean -fd`
se deniega citando `git.prohibidos: 'clean -f'` del manifiesto, y `git stash list` pasa.

Quality gates en verde tras el cambio: `bash -n` sobre los 9 `hooks/*.sh` y `tools/*.sh`, y `jq -e` sobre
`hooks/hooks.json`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` y `.arnes/config.json`.

## [Interno] — 2026-09-06 · el plan maestro hasta que el arnés esté terminado
> Origen: Interno · usuario: Juan · modelo de IA: Opus 5 · agente: sesión coordinadora.

- `docs/PLAN.md` (nuevo): qué entra en cada ventana de 1.32.0 a 1.36.0, qué cierra y **por qué va ahí
  y no antes**. La regla de orden que explica el reparto: lo que **compone** va primero — una palanca
  que abarata el ciclo se paga en todas las ventanas siguientes; un mecanismo que cierra un hueco se
  paga una vez.
- Con una definición explícita de **«terminado»**: ningún hallazgo `contrato` abierto, ninguna promesa
  más fuerte que lo que la máquina cumple, y un ciclo que cabe en un presupuesto declarado. Lo que
  quede después es backlog, no obra pendiente.
- `docs/PENDIENTES.md` gana el aviso de que sus rótulos de versión quedaron desfasados por la
  reordenación y de que manda el plan. La cola cruda sigue siendo válida; el número de versión no.

## [Interno] — 2026-09-06 · disciplina de coste, y lo que se decide NO construir
> Origen: Interno · usuario: Juan · modelo de IA: Opus 5 · agente: sesión coordinadora.

- `docs/gobernanza/autoalojamiento.md`: la disciplina de coste, obligatoria desde el ciclo 3. La
  fórmula que gobierna todo lo demás, medida sobre 3.384 turnos: **el coste de una comisión es
  turnos por contexto**. La más cara fue de 138 turnos y 12,48 USD; la más barata que hizo trabajo
  real, de 8 turnos y 0,06 USD.
- Consecuencias: el encargo declara presupuesto y el agente lo reporta; lo grande se lee tarde y en
  trozos; y la elección de modelo casi no mueve la aguja, porque el 87 % del gasto es caché.
- **Y una decisión de no construir:** el arnés no llevará un medidor de coste. Medirlo exige leer las
  transcripciones del anfitrión, cuyo formato no está documentado y puede cambiar; meterlo en el
  plugin haría que todos los proyectos heredaran esa dependencia. Se documenta el **método**, que es
  estable, y mide la coordinadora.

## [Interno] — 2026-09-06 · la ventana 1.32.0 se dedica al coste, y el resto se aplaza
> Origen: Interno · usuario: Juan · modelo de IA: Opus 5 · agentes: sesión coordinadora y `analista-requerimientos`.

- **REQ-012, REQ-013 y REQ-014** redactados para 1.32.0: criterios por mecanismo y no por enumeración,
  mapa de archivos para poder paralelizar, y el banco en archivos por sección. Cada uno con su forma de
  medirse contra la línea base del ciclo 2.
- **1.32.0 pasa a ser la ventana del coste y nada más.** Los bloques B y C de REQ-007 y la puerta
  posterior se mueven a 1.33.0. El motivo: las palancas de coste **componen** y lo demás no, así que
  primero se abarata el bucle y después se construye con él; al revés se paga el precio completo y se
  mejora cuando ya no sirve para ese trabajo. Lo que se retrasa exige ofuscación deliberada.
- **REQ-013 deja de tocar el lector de las puertas.** Su propio criterio declara que el campo nuevo no
  es puerta, y si ninguna puerta lo lee, el lector que gobierna no tiene por qué conocerlo. Reutiliza la
  normalización compartida y exige diff vacío. Con eso desaparecen dos conflictos que ya estaban escritos.
- **Y una decisión aplazada a propósito, que es la disciplina de coste aplicada a nosotros mismos:** el
  write-back de cómo conviven REQ-007 y REQ-011 en 1.33.0 queda escrito en `docs/PENDIENTES.md` con su
  razón, y se lleva al REQ cuando esa ventana se abra. Escribirlo hoy costaría una comisión de analista
  medida en cuatro dólares para un texto que nadie lee hasta entonces.

## [Interno] — 2026-09-06 · cuánto cuesta un ciclo, medido, y las tres palancas
> Origen: Interno · usuario: Juan · modelo de IA: Opus 5 · agente: sesión coordinadora.

- `docs/PENDIENTES.md`: la **línea base** del ciclo 2 —25 comisiones, ~5 h 23 de tiempo de agente,
  cuatro vueltas del bucle a unos 50 minutos cada una—, sin la cual «mejoramos» es una sensación.
- El diagnóstico con los hallazgos delante: **siete de veinte fueron que el criterio decía algo falso
  sobre lo construido**, no que el código fallara, y uno de ellos costó una vuelta entera.
- Queda dicho también **lo que no es el problema**, para no optimizar la parte equivocada: el orden
  QA→auditor no se puede paralelizar sin producir una firma falsa, y las corridas de control de la
  coordinadora suman seis minutos en todo el ciclo. El cuello son dos archivos monolíticos.
- Y el contexto que evita la conclusión equivocada: este repositorio se impone la **ceremonia máxima**
  a propósito. Las cinco horas son el techo de quien construye el mecanismo, no lo que paga quien lo usa.

## [Interno] — 2026-09-06 · cierre del ciclo 2 del autoalojamiento
> Origen: Interno (documentación de gobernanza) · usuario: Juan · modelo de IA: Opus 5 · agente: sesión coordinadora.

- `v1.31.0` publicada (tag sobre `main` 2fecae1, PR #33, `hooks-en-linux` 682/0/1) e instalación estable
  actualizada. Los siete REQ de la ventana pasan a `completado` con QA y Seguridad aprobados; REQ-007
  sigue `en-progreso` y cruza a 1.32.0.
- `docs/gobernanza/autoalojamiento.md`: fila del ciclo 2 como publicado, fila del ciclo 3 abierta, y lo
  que enseñó el ciclo — incluida una lección que sólo aparece al autoalojarse: **el cierre de un REQ lo
  juzga el guardián de la sesión, no la versión recién publicada**. Al cerrar con 1.30.3 gobernando, la
  puerta rechazó el campo `Hallazgos abiertos:` escrito en la forma ancha que 1.31.0 aprendió a leer. No
  es un fallo, es el principio funcionando; la consecuencia para cualquier proyecto es que ese campo se
  escribe en forma cerrada y la evidencia vive en el informe.
- `docs/PENDIENTES.md`: la deuda del ciclo 2, toda con criterio y dueño, y la migración de andamiaje que
  este repositorio tiene pendiente porque 1.31.0 **sí** cambió plantillas.

## [1.31.0] — 2026-09-05
> Origen: GitHub · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos` (REQ-002…009), `desarrollador` (implementación y banco), `qa-tester` y `auditor-seguridad` (pendientes en el ciclo 2 del autoalojamiento).

Siete mecanismos, todos nacidos de defectos **medidos en proyectos reales** y descritos aquí
en la forma del hallazgo: qué fallaba, por dónde, y qué cambia para un proyecto. Cuatro nacen
**apagados**; sólo uno viene encendido, y se dice por qué.

### Corregido — el acento no es parte del valor: `en-revision` y `en-revisión` son el mismo estado (REQ-010)
**Qué fallaba:** un proyecto que corre el arnés reportó que el informe marca como «valor que
ninguna puerta reconoce» un `Estado:` escrito **sin tilde**. Con decenas de requerimientos eso son
decenas de avisos falsos por documento, y un informe ruidoso no es sólo molesto: es la forma
conocida de que las anomalías reales se entierren. **Por dónde:** la normalización de campos
plegaba exactamente **una pareja de letras** —`Í`/`í`—, añadida en su día para que `Sensible a
seguridad: **Sí**` casara con `sí`. `en-revisión` lleva `ó`, que no estaba en esa pareja. Es la
cuarta aparición de la misma familia de defecto en este arnés: **el sujeto del control era más
estrecho que su población**. **Por qué no era sólo un aviso feo:** la misma normalización gobierna
la detección de la transición al estado terminal. En un proyecto cuyo `estados.completado` lleve
acento —lo declara cada proyecto: es mapeo, no mecanismo—, escribirlo sin tilde hacía que la puerta
**no viera la transición** y un requerimiento crítico cerrara sin veredicto de seguridad. Falla en
abierto y en silencio. **Qué cambia:** el arreglo no añade la letra que faltaba —eso repetiría el
defecto a la quinta— sino que declara la clase completa: se pliegan todas las vocales acentuadas y
con diéresis, en mayúscula y minúscula, en forma precompuesta **y descompuesta** (un archivo
guardado en macOS trae la tilde descompuesta y nada lo delata a la vista). **No** se pliega la `ñ`
—es otra letra, no una `n` con adorno; plegarla haría iguales `año` y `ano`— ni los separadores:
`en revision`, `enrevision` y `en-revisión-parcial` siguen siendo valores distintos. El plegado vive
**una sola vez**, en la misma función que ya normaliza caso y marcado, y lo usan por igual la
puerta, el informe y el bloque derivado. **Coste: cero procesos y cero forks** —sólo expansión de
parámetros, detrás de una guarda sobre el byte de cabecera, así que un valor ASCII no paga ni una
sustitución— y el veredicto es idéntico bajo `LC_ALL=C` y bajo un locale UTF-8, porque la tabla se
escribe con escapes de bytes y no depende de la colación del entorno. El informe sigue mostrando el
valor **crudo** tal como está en el archivo, con el normalizado al lado: quien lee el aviso tiene
que poder encontrar el texto en su editor.

### Corregido — la CLAVE del campo también se decora, y dejaba el campo vacío (REQ-007, bloque A)
**Qué fallaba:** el **valor** de un campo se leía con tolerancia desde 1.30.0 —`**completado**` es
`completado`— pero la **clave** se casaba contra el literal `^Clave:`. Así que `**Estado:**
completado`, `Estado:` seguido de tabulador, ` Estado:` con sangrado y las seis claves envueltas en
énfasis de Markdown **no se reconocían**. **Por qué es grave y no cosmético:** falla en abierto. Con
`**Hallazgos abiertos:** SEC-9 (usuario/dinero)` la clave no casaba, el campo quedaba **vacío** — y
un campo vacío significa «ningún hallazgo». El requerimiento cerraba con un hallazgo de clase
bloqueante declarado a la vista de cualquiera que leyera el documento. **Qué cambia:** la clave se
lee con la **misma regla** que el valor y en el mismo sitio —se retira el espacio en blanco de los
extremos y el énfasis de Markdown—, no con una lista de formas enumeradas: una lista se pudre y la
regla vale para las formas que nadie ha escrito todavía. Es la otra mitad de la misma línea que el
plegado de acentos, y por eso entran juntas: arreglar una sin la otra hace que el defecto reaparezca
en la mitad de al lado. **Lo que NO cambia: dónde vale un campo.** Los campos siguen valiendo sólo
en la cabecera, antes del primer `## `; la tolerancia es sobre **cómo** se escribe la clave, nunca
sobre **dónde**. Y leer de más cae siempre del lado que **cierra** la puerta: `**Rigor:** critico`
sobre un requerimiento no sensible se lee `critico` y exige auditoría.

### Corregido — un manifiesto roto apagaba el enforcement en silencio (SEC-005)
**Qué fallaba:** si `.arnes/config.json` **existía** pero no se podía leer —inválido, vacío, `null`
o un array—, la lectura del manifiesto no miraba su código de salida y **todo se permitía sin decir
nada**. Peor: la variable de la lectura conservaba su **valor anterior**, que era el análisis del
**input**, así que las variables del manifiesto se rellenaban con campos que controla quien llama —
el agente de código autorizado se quedaba valiendo `Bash`, el nombre de la herramienta, y la lista
de rutas protegidas, vacía. La identidad del agente autorizado la escribía el llamante. **Qué
cambia:** un manifiesto **ausente** sigue dejando los hooks inertes, que es una decisión legítima de
un proyecto que no usa el arnés; uno **presente y roto** avisa por stderr **siempre** y **deniega**
toda escritura que las puertas tendrían que juzgar —no se puede denegar «sólo en las rutas
protegidas» porque justo lo que no se puede leer es cuáles son—. Ningún dato del input atraviesa ya
esa frontera. Un `ls -la` sigue pasando: no escribe nada y bloquearlo no protegería ninguna
invariante, y por lo mismo **ni siquiera lee el manifiesto** — el aviso se emite siempre que el
manifiesto **se consulta**, que es siempre que hay algo que juzgar con él (el camino común de
`Bash` vuelve así a costar **1 proceso**, los mismos que v1.30.3; ver *Pruebas*).
**Y el remedio que el motivo recomienda ahora existe:** mientras el manifiesto esté roto, la
**única** escritura permitida es la del **propio `.arnes/config.json`**. Un proyecto que lo tenga
en `codigo_app.globs` —como éste— quedaba con la reparación denegada para todos los agentes por
`Edit`, por `Write` y por `Bash`: el mensaje ofrecía una salida que él mismo cerraba. Es el único
archivo cuya reparación devuelve la capacidad de medir y no depende de leerlo; cualquier otra ruta
sigue denegada, y con el manifiesto sano vuelve a estar protegido como cualquier otro.

### Corregido — lo que el manifiesto no dice bien cae del lado seguro, y ahora también lo dice
**Qué fallaba:** `"exigir_fecha": "true"` —la cadena, no el booleano— apagaba la exigencia de
fecha **sin una sola señal**, mientras que el techo de análisis de Bash sí avisaba ante el mismo
error de tipo. La asimetría es lo que sorprende: el proyecto cree que declaró algo y no declaró
nada. Y en el propio techo quedaba un hueco entre las dos ramas: `1e9` o `1.5` son números JSON
válidos que no son enteros de bytes aplicables, así que caían al valor por defecto **callando**.
**Qué cambia:** una sola regla para todas las claves que leen las puertas —`agentes.agente_codigo`,
`requirements_dir`, `estados.completado`, `pending_approval`, `limites.bash_max_analisis`,
`veredictos.*`, `git.*` y `codigo_app.globs`—: **lo que no tiene el tipo que esa clave espera cae al
valor por defecto del arnés y se avisa**, nombrando la clave y el valor recibido tal como venía. No
deniega —un tipo mal escrito no puede convertirse en un bloqueo— pero tampoco calla. Si lo que no
tiene el tipo esperado es el **contenedor** (`"veredictos": "x"`), el manifiesto entero sigue
declarándose ilegible: ése es el fail-closed de arriba y no cambia.

### Corregido — no se escribe a través de un enlace simbólico (SEC-004)
**Qué fallaba:** los dos guardianes clasifican por el **nombre** de la ruta, así que un enlace
colocado en una ruta libre que apuntara a código protegido o a un requerimiento recibía el veredicto
de su nombre y no el de lo que realmente toca. **Qué cambia:** si la ruta de un `Edit`/`Write`/
`MultiEdit` es un enlace simbólico dentro del proyecto, se deniega con ese motivo. **El destino no
se resuelve, y es deliberado:** resolverlo costaría un proceso en el camino de toda edición y
abriría una carrera entre la comprobación y la escritura —lo que el hook mide y lo que la
herramienta escribe dejarían de ser el mismo archivo—. El precio, dicho en voz alta: no se puede
escribir a través de un enlace ni siquiera cuando su destino es inocente, y eso alcanza también al
agente de código. La salida está a la vista: escribir sobre la ruta real.

### Añadido — un veredicto lleva fecha y caduca con el código (REQ-002, apagado)
**Qué fallaba:** cuatro requerimientos estaban a punto de cerrarse con un `QA: aprobado`
emitido contra código que había cambiado **después** de la firma, y otro llevaba un
`Seguridad: aprobado` a secas —sin ronda ni fecha—, que era justamente el único que nadie
sabía que estaba caduco. Un veredicto es una foto, y una foto sólo vale si el sujeto estaba
quieto. **Por dónde:** la convención de poner la evidencia al lado de la afirmación ya
existía; lo que faltaba era que la máquina pudiera **exigirla** y **usarla**.
**Qué cambia:** con `veredictos.exigir_fecha`, un `aprobado` sin fecha `AAAA-MM-DD` en su
paréntesis de evidencia no cierra; con `veredictos.caducan_con_codigo`, tampoco cierra un
veredicto anterior al último commit que tocó `codigo_app.globs`, ni con cambios sin comitear
en ese código. Si no se puede medir —sin git, sin repositorio, sin globs declarados o con un
git que no entiende `%cs`— **no se deja pasar**: una puerta que no puede medir no deja pasar.
Las dos claves vienen apagadas, así que un proyecto que no las active no nota ningún cambio.
Cuesta como mucho **dos** invocaciones de git por evaluación, y ninguna en el camino de Bash.
*Asimetrías declaradas:* el empate del mismo día no caduca (`%cs` tiene resolución de día) y
una fecha futura se acepta —esta puerta mide contra el código, no contra el reloj—.

### Añadido — un solo vocabulario, un solo lector, y un aviso al escribir (REQ-003)
**Qué fallaba, tres veces:** (1) entre `pendiente` («no he mirado») y `vetado` (freno formal
con remedio, dueño y umbral) no había forma de decir lo intermedio, que es el estado más común
de una auditoría real: cinco requerimientos de un proyecto ya escribían `con-hallazgos` porque
el vocabulario no les daba la palabra —cuando la gente escribe un valor que la herramienta no
tiene, la incompleta es la herramienta—. (2) Cuatro requerimientos llevaban **semanas** con un
`QA:` que la puerta no reconocía, y nadie lo supo hasta que un cierre falló. (3) El informe
`tools/arnes-lectura.sh` no aplicaba a `Estado:` la regla del paréntesis de evidencia que la
puerta aplica desde 1.26.0: **28 de 42 anomalías eran falsas**, y el ruido enterraba las 14
reales. **Qué cambia:** `Seguridad: con-hallazgos` es un valor válido (y, como todo valor
distinto de `aprobado`, **no cierra**); el vocabulario vive en **un solo sitio** compartido por
las puertas y el informe; escribir un veredicto fuera de él **avisa en el momento** con un
mensaje a la persona y **sin denegar** la edición —denegar una errata añadiría fricción
constante a algo inocuo, y esa fricción acaba con alguien apagando el guard—; y el informe lee
`Estado:` exactamente como lo lee la puerta.

### Añadido — rotar UNA sección: la historia se archiva, el contrato no (REQ-004, apagado)
**Qué crecía sin tope y quién lo pagaba:** en un proyecto real `requirements/` pesaba **3,73 MB
en 47 archivos**, uno solo de **244 KB**, y ese peso lo paga **cada agente** que abre el
requerimiento para leer dos criterios. La rotación que existía cortaba por secciones `## ` de
un artefacto entero, y en un requerimiento lo que crece es **una** sección: el resto es el
contrato. **Qué cambia:** un artefacto declarado con `glob` + `seccion` mueve las entradas
viejas de esa sección a `historial/<nombre>.md` y deja un puntero. **No resume, no reescribe y
no borra: mueve.** Y no toca **nada** fuera de la sección declarada —ni la cabecera con sus
veredictos ni los criterios—, lo cual aquí es una invariante de seguridad y no una comodidad:
el hook escribe en `requirements/` desde una parada, fuera de la vía que vigila la puerta de
cierre. Qué sección es «historia» lo declara el proyecto; el arnés no trae ninguna por defecto,
y el nombre se compara **exacto**, nunca por prefijo — y cuando el archivo casa el `glob` pero
**no** contiene la sección declarada, no se rota nada **y se dice**: un aviso por stderr que
nombra el archivo y la sección que no encontró, y una línea en el bloque derivado de
`docs/ESTADO.md`. Un artefacto declarado que no existe es un error de mapeo que hay que ver, no
un acierto silencioso: sin la señal, un proyecto que escribió mal el nombre cree que rota desde
hace meses. (Por eso la parada ahora **rota antes de derivar**: el bloque describe el disco
después de la rotación, no antes.)

### Añadido — ningún agente ejecuta git destructivo (REQ-005, **encendido**)
**Qué se perdió:** ~52 archivos de trabajo **sin comitear** en un incidente. La causa de fondo
no es el descuido de nadie: **el trabajo de un subagente no es atómico para git**. Mientras un
agente escribe, el árbol contiene estados intermedios que no son de nadie; otro agente limpia
«su» árbol y arrasa el del primero, y git no devuelve lo que nunca se comiteó. **Qué cambia:**
`hooks/guard-git.sh` deniega por `Bash` las formas destructivas de `clean -f`, `reset --hard`,
`checkout .`, `restore .` y `stash` a **todos** los agentes, incluida la sesión coordinadora:
es una regla del **comando**, no de la identidad. No alcanza a `stash list`, `stash show`,
`restore --staged`, `clean -n` ni a ningún git de lectura, y lo entrecomillado y el cuerpo
literal de un heredoc se descuentan antes de mirar —`git commit -m "no uses git clean"` no es
un `git clean`—. **La ortografía del flag no abre un hueco** (vuelta 1 de QA): `--force` y `-f`
son el mismo flag escrito de dos maneras y casan igual, en los dos sentidos —una regla escrita
`push --force` alcanza también `git push -f`—, con el valor pegado (`--force=x`) y respetando el
fin de opciones (`git clean -- --force` borra un archivo **llamado** `--force`, y sigue
permitido). Lo mismo con el nombre viejo de un subcomando: `git stash save` es `git stash push`.
La equivalencia vive en el **motor** y no en la lista, para que valga también para el
`git.prohibidos` propio de cada proyecto; sólo se reconocen las que son un hecho de git, porque
deducir la forma corta del nombre largo haría que `clean -d` denegara un `--dry-run`. **Es la única novedad de 1.31.0 activa por defecto**, porque es la única que
impide un daño irreversible; se apaga con `git.activo: false` o se sustituye con
`git.prohibidos`. Cobertura parcial dicha en voz alta: quedan fuera los scripts y los
intérpretes que ejecuten git por su cuenta. Es una barandilla, no una jaula.

### Corregido — construcciones ordinarias del shell atravesaban la puerta de git (SEC-009)
**Qué fallaba:** `git clean -fd` desnudo se denegaba, pero **envuelto en cualquier construcción
corriente del shell pasaba**: `if true; then git clean -fd; fi`, `{ git clean -fd; }`,
`for i in 1; do git clean -fd; done`, `sleep 0 & git clean -fd`, `nohup git clean -fd` y la orden
partida con una continuación de línea. Siete formas medidas, ninguna exótica: una limpieza
condicional se escribe **exactamente así**, de modo que el hueco no había que buscarlo, se pisaba
sin querer. **Por dónde:** la puerta juzga el **primer token de cada orden**, y la segmentación no
partía por `&` sencillo ni plegaba la continuación de línea; peor, el bucle que salta lo que no es
el comando —asignaciones de entorno, `sudo`, `env`— no conocía las **palabras reservadas del
shell**, así que un segmento que empezaba por `then`, por `do` o por `{` se descartaba entero, con
el `git` dentro. **Por qué importa más que en otras puertas:** es la única que nace **encendida**
en todos los proyectos, y lo que deja pasar es irreversible. **Qué cambia:** la continuación de
línea se pliega antes de partir, el `&` sencillo separa órdenes como ya hacían `&&`, `;` y `|`, y
el bucle de prefijos tolera las palabras reservadas (`then`, `else`, `elif`, `do`, `{`, `!`…) y los
envoltorios que preceden a un comando (`nohup`, `setsid`, `timeout`, `stdbuf`, `xargs`), con sus
opciones y su argumento cuando lo llevan. Todo eso ensancha **dónde mira** la puerta, nunca lo que
deniega: `echo git clean -f` y un `grep` de un texto que dice `then git clean -fd` siguen
permitidos, y están en el banco para que sigan estándolo. **Lo que sigue fuera, y se dice:** un
subcomando que llega por variable (`G=clean; git $G -f`) no se ve —el valor no está en el texto del
comando—, igual que los intérpretes y los scripts. **No es una regresión:** contra la versión
publicada estas formas ya pasaban, porque la puerta no existía.

### Corregido — un manifiesto ilegible apagaba la puerta de git, justo cuando todo lo demás se denegaba (SEC-010)
**Qué fallaba:** con `.arnes/config.json` presente pero ilegible —inválido, vacío, `null`, un array
o con la clave `git` del tipo equivocado—, las dos puertas de escritura denegaban con su aviso
mientras la puerta de git **permitía**. Y el aviso afirmaba, textualmente, que «toda escritura que
las puertas deban juzgar se deniega»: cierto de dos puertas de tres. **Por qué es grave:** en un
proyecto plantilla el manifiesto **no** está entre las rutas protegidas, así que la única puerta
encendida por defecto tenía un interruptor de apagado alcanzable en **una** escritura de cualquier
agente — y por accidente, con una coma de más. El estado en que ocurre es además aquel en el que
todo lo demás está bloqueado y el agente busca «dejar el árbol limpio». **Qué cambia:** se aplica
el principio rector —una puerta que no puede medir no deja pasar—. Con el manifiesto ilegible la
puerta de git cae a la **lista por defecto que vive en el código** y **deniega**, con un motivo que
dice que está en **modo degradado** y cuál es la salida: reparar el JSON, que es la única escritura
que la avería deja pasar. La lista por defecto pasa a declararse **una sola vez** y las dos vías
—manifiesto sano y modo degradado— leen la misma cadena: dos transcripciones de la misma regla se
desfasan. **El borde, declarado en voz alta:** un proyecto que tuviera la puerta apagada con
`git.activo: false` y se le rompa el manifiesto **pasará a denegar**. Es la dirección segura
—apagar es un acto explícito y un JSON roto no lo es— y la salida es reparar el manifiesto. Con el
manifiesto sano, `git.activo: false` sigue apagando la puerta exactamente como antes.

### Corregido — el archivo de continuidad no se pierde, ni con el manifiesto roto ni por un byte extraño (SEC-011)
**Qué fallaba:** tres cosas, todas en el mismo archivo y todas medidas. **(1)** Con el manifiesto
ilegible, la parada dejaba dos errores crudos de `jq` por stderr y **ningún bloque derivado**: la
observabilidad que el arnés promete —«la traza vive en archivos legibles»— se apagaba justo en el
estado degradado, que es cuando hace falta. Con el manifiesto **vacío** era peor: el hook moría con
`unbound variable` y la parada salía con error. **(2)** Un byte **NUL** en `docs/ESTADO.md` cortaba
la lectura ahí mismo y todo lo que venía detrás **se perdía** al reescribir. **(3)** Un
`docs/ESTADO.md` con contenido pero **sin permiso de lectura** se leía como vacío, y el bloque
sustituía al documento entero. Las dos últimas son la misma familia: **se reescribía a partir de
una lectura que había fallado**, y lo que se perdía era texto de una persona. **Qué cambia:** los
valores por defecto se fijan **antes** de leer nada, así que ninguna ruta deja una variable sin
definir; con el manifiesto ilegible el bloque **se deriva igual** —derivar no necesita el
manifiesto: sale del disco— con las rutas por defecto del código, y escribe una línea que dice
**«manifiesto ilegible: enforcement degradado»** con la salida. Y si lo que no se puede leer es el
**destino** —sin permiso, o con un NUL detrás del cual hay bytes que no se pueden traer—, **no se
escribe nada**: el archivo queda **byte a byte** como estaba y se avisa. Un bloque de continuidad
que no se escribe es un inconveniente; uno que borra el documento es una pérdida. Si la escritura
falla al publicar (disco lleno, carpeta sin permiso), el original sigue intacto, **no queda ningún
temporal huérfano** y se dice. **Y la reparación del manifiesto deja rastro:** la escritura de
`.arnes/config.json` permitida durante la avería emite un aviso **propio y distinguible** que
nombra el archivo, la herramienta y el tipo de agente que repara —una vez por llamada, no una por
guardián—, en vez de un stderr idéntico al de cualquier otra llamada. No se registra ningún
contenido.

### Corregido — las celdas del bloque derivado no caben en una tabla (REQ-006)
**Qué fallaba:** en un proyecto con 57 requerimientos, cuatro celdas de veredicto ocupaban el
**37 %** del bloque de continuidad, y la mayor —**1 296 caracteres sin un solo espacio**—
además **rompía la tabla**: una fila que no cabe deja de renderizarse como fila, así que el
bloque dejaba de servir para lo único que existe, que es contar en tres líneas dónde quedó
todo. **Qué cambia:** las tres celdas de texto libre (`QA`, `Seguridad`, `Hallazgos abiertos`)
salen recortadas a 40 caracteres con `…`, y una barra vertical dentro de un valor se neutraliza
para que no abra una columna nueva. **El recorte es de presentación**: pasa después del
normalizador y sólo al componer la fila, así que ni la puerta ni el informe ven nunca el valor
recortado —si llegara a la lectura, un `Hallazgos abiertos:` largo podría perder su clase
bloqueante por el camino—.

### Corregido — la cola de aprobaciones se contaba de dos maneras (REQ-009)
**Qué fallaba:** la misma cola, dos números. La puerta de cierre contaba **encabezados
`###`** bajo `## Pendientes`; el bloque derivado de `docs/ESTADO.md` contaba **viñetas**
(`- `, `* `, `1. `) en la misma sección. Una entrada real del formato que documenta el
propio `PENDING_APPROVAL.md` —un `###` con cuatro viñetas debajo— valía **1** para la
puerta y **4** para el bloque. Ninguno de los dos números miente por sí solo; lo que miente
es que haya dos, porque el número que se lee deja de ser el que bloquea. Además el conteo de
viñetas nunca recibió la corrección del **ejemplo comentado**, así que un `<!-- … -->` con un
ejemplo dentro sumaba. **Por dónde:** dos transcripciones de la misma regla, en dos archivos
—la misma familia que el vocabulario de veredictos de REQ-003—, y se desfasaron en silencio
hasta que alguien comparó los dos números.
**Qué cambia:** la regla vive **una** vez (`arnes_cola_pendientes`, `hooks/lib.sh`) y la usan
por igual la puerta, el bloque derivado y `tools/arnes-lectura.sh`, que ahora también informa
de la cola. Gana la regla de la puerta —la que decide y la que está documentada—: una entrada
es una línea `###` + espacio dentro de la sección que abre un `## ` cuyo texto empieza por
«Pendientes» y cierra el siguiente `## ` de cualquier nombre, descontando los comentarios
HTML. **Y la cola es una puerta:** si no se puede leer entera —un byte NUL que la trunca, un
archivo sin permiso— la puerta **deniega** con motivo propio en vez de contar 0 sobre un
archivo que nadie leyó, y el bloque derivado dice `sin datos` en vez de `0`. *Se paga en
negativo:* el conteo se hace con lecturas y expansión de parámetros, así que la puerta pierde
el `awk` que pagaba en cada cierre (medido: 1 → 0) y la parada no gana ninguno.
**Al actualizar:** el número de aprobaciones pendientes del bloque derivado puede **bajar**
sin que nadie haya resuelto nada. No hay nada que migrar: se regenera en la siguiente parada.

### Seguridad — cuatro huecos de la auditoría R-001, todos de la misma familia (REQ-007)
Todos **preexistentes** —medidos idénticos en 1.30.3 y en la versión anterior—, ninguno es
regresión, y todos son la misma clase: **un dato que controla quien llama decide cómo se
comporta el guardián**.

- **Una barra de más desactivaba las DOS puertas.** Un `Write` a `<raíz>//src//a.ts` o un
  `Edit` sobre `<raíz>//requirements//REQ-x.md` pasaban: la ruta relativa se calcula
  recortando el prefijo del proyecto **textualmente**, la ruta no empezaba por `<raíz>/`, el
  prefijo no se recortaba, ningún glob de código casaba y ninguna ruta caía dentro de
  `requirements/`. Era la evasión **más barata** medida en todo el arnés —un carácter, sin
  ninguna forma exótica— y alcanzaba a los dos guardianes a la vez. Ahora las barras repetidas
  se colapsan al normalizar la ruta, **antes** de recortar el prefijo y **sin ningún proceso**;
  la doble barra inicial de una ruta UNC de Windows se conserva.
- **Un byte de control desincronizaba la simulación del cierre.** Las piezas de un
  `Edit`/`MultiEdit` se trocean con un separador que viaja **dentro** del propio dato: con un
  byte de control metido en un `new_string`, el bucle leía como tripletas cosas que no lo eran
  y **el documento que el hook simula dejaba de ser el que la herramienta iba a escribir**. Las
  cuatro puertas del cierre —veredictos, cola, quality gates y clase del hallazgo— se saltaban
  a la vez, con un byte. Ahora un `tool_input` con bytes de control C0 —cualquiera salvo
  tabulador, salto de línea y retorno de carro, que el Markdown normal sí lleva— **no se juzga:
  se deniega**, en la misma llamada a `jq` y sin ningún proceso nuevo.
- **Un NUL dentro del documento truncaba la lectura del disco.** La forma barata de leer un
  archivo entero en bash usa el NUL como delimitador, así que un NUL en la primera línea dejaba
  el texto cortado ahí: los veredictos se leían de un documento incompleto —y un campo vacío no
  exige nada— y, de paso, la reconstrucción fallaba y la puerta caía a su vía más laxa. Bastaba
  una escritura previa en `requirements/`, que ninguna puerta restringe. Ahora la lectura
  **dice** cuándo no pudo leer el archivo entero, y una edición que menciona el estado terminal
  sobre un documento ilegible se deniega con motivo propio. Lo que decide sigue siendo la
  transición: una edición que no toca el estado no queda bloqueada por el byte.
- **El techo de análisis de Bash se podía subir sin tope desde el manifiesto.** El coste del
  análisis crece con el tamaño y un hook `PreToolUse` **muere a los 60 s permitiendo**: un
  `limites.bash_max_analisis` de `4294967296` reabría **por configuración** justo el fallo en
  abierto que el presupuesto de 1.30.3 cerró. Y `"999999"` **entrecomillado** —una cadena, no un
  número— se aceptaba como si lo fuera. Ahora el valor declarado tiene un **máximo operativo**,
  medido y no arbitrario: por encima se aplica el máximo y se avisa; un valor que no sea un
  número en el JSON cae al techo por defecto, también con aviso. Un valor **más bajo** que el
  defecto sigue sin bajar nada, y el motivo del deny sigue imprimiendo el techo vigente en bytes
  sin nombrar ninguna ruta.

**Pendiente de decisión humana, y por eso no aplicado:** el manifiesto que define la frontera
no está **dentro** de la frontera —quien no puede escribir el código de los guardianes sí puede
cambiar la regla que dice qué es ese código—. Es escalada de privilegios dentro del arnés y el
mecanismo para cerrarla ya existe; lo que falta es el **mapeo**, y cambiar el mapeo de este
repositorio exige aprobación del propietario. Queda escrito en `PENDING_APPROVAL.md` y el
pipeline se detiene ahí. **Ninguna plantilla hereda esos globs:** es mapeo de este repositorio,
no mecanismo, y el banco tiene un caso que se pone rojo si algún día aparecen ahí.

### Andamiaje que heredan los proyectos
- `templates/arnes-config.json.tpl`: bloques nuevos `veredictos` (apagado), `git` (encendido) y
  `limites` (**opcional**: el techo de análisis de Bash que 1.30.3 dejó sin documentar), y la
  forma de sección en `rotacion.artefactos`, todos con su `_doc`.
- `templates/requirements-README.md.tpl` y `templates/AGENTS.md.tpl`: `con-hallazgos`, la fecha
  del veredicto, el aviso sin bloqueo, la rotación de la historia y el recorte de celdas.
- `skills/arnes-upgrade/SKILL.md`: sección **Hacia 1.31.0** con qué preguntar antes de encender
  `veredictos.*`, qué avisar de `guard-git`, dos marcadores nuevos de versión y los tres avisos
  nuevos: la cuenta de la cola puede bajar sola, un REQ con la cabecera decorada empieza a ser
  juzgado, y `limites.bash_max_analisis` tiene ahora un máximo.
- `templates/PENDING_APPROVAL.md.tpl`: la regla de conteo de la cola, escrita **una vez**, y el
  aviso de que el bloque derivado y la puerta cuentan lo mismo.
- `templates/AGENTS.md.tpl`: el párrafo que acota la detección del estado terminal por `Bash`
  —lee el texto crudo del comando, así que partir la palabra entre expansiones la evade; la
  respuesta es la puerta posterior, no un patrón más largo—, para que ningún proyecto lea una
  promesa más fuerte de la que la máquina cumple.
- `ARCHITECTURE.md`: vista de sistema al día, con el guardián nuevo y el orden de `guard.sh`.

### Validación — dos vueltas del bucle dev↔QA, y lo que enseñaron

El `qa-tester` validó la ventana en dos vueltas y devolvió defectos que ninguna prueba del
desarrollador había visto. Merecen el detalle, porque son familias que se repiten:

- **La puerta nueva de git no veía las formas largas.** `git clean --force`, `git clean --force -d` y
  `git stash save` pasaban: el motor saltaba todo lo que empieza por dos guiones, y `save` es el alias
  antiguo de `push`. Se arregló canonicalizando **los dos lados** antes de comparar y poniendo el alias
  en el motor, no en la lista: un proyecto con lista propia habría perdido la equivalencia sin enterarse.
- **El coste del camino común se había duplicado**, de un proceso a dos por cada comando de shell, como
  efecto del arreglo del manifiesto roto. En Linux son milisegundos; donde un fork cuesta entre 1,2 y
  6 s, es otra magnitud. Ahora las escrituras se detectan antes, y el manifiesto sólo se lee si hay algo
  que juzgar.
- **Un punto muerto fabricado por el propio arnés:** al meter el manifiesto dentro de su propia
  frontera, repararlo quedaba denegado para todos. Con el manifiesto ilegible se permite escribir el
  propio manifiesto y nada más, sin filtrar por agente — porque quién es el agente de código se lee del
  archivo que no se puede leer.
- **Un caso del banco que decidía por reloj de pared**, con un umbral fijo en milisegundos: dos corridas
  de la misma línea base dieron 457 y 458. Un banco que es puerta requerida de `main` no puede tener
  casos que dependan de lo cargada que esté la máquina.
- **Y tres veredictos que pasaron de denegar a permitir sin estar declarados** (`git clean -- -f`,
  `git reset -- --hard`, `git restore -S .`). Los tres son correctos y ninguno destruye nada, medido en
  un repositorio desechable: lo que estaba mal era el criterio, que prometía casar «todos los tokens
  presentes». Se cierra reescribiendo el requerimiento, no el guardián.

De ahí salió además una regla que se queda: **un criterio de coste se escribe como techo, nunca como
igualdad.** Escrito como igualdad, una mejora se lee como fallo.

Y de la verificación del veto salió otra, más incómoda: **el QA reprodujo la pérdida de texto humano**
en la versión anterior de esta misma ventana —dos hashes distintos y la línea de la persona contada a
cero, no una sospecha— y comprobó el arreglo con nueve averías propias que nadie había pedido: espacio
en disco agotado de verdad, el destino como enlace simbólico, sólo lectura, finales de línea mixtos,
cuatro paradas concurrentes por diez rondas, y un límite de tamaño de archivo. Ninguna perdió un byte.
La regla que deja: **una comprobación que sólo mira si el bloque está nunca habría visto el archivo
vaciado** — lo que se verifica es el archivo entero, por hash, no la parte que a uno le interesa.

### Seguridad — un veto, y lo que enseñó levantarlo

El `auditor-seguridad` **vetó** la puerta de git y el veto se levantó arreglando, no declarando. Encontró
que construcciones ordinarias del shell la atravesaban (`if … then`, `{ … }`, `for … do`, `&`, `nohup`,
la continuación de línea) y que **un manifiesto ilegible la apagaba** mientras el aviso afirmaba que todo
se denegaba. Las dos cerradas y verificadas por él con sondas propias, no aceptadas del informe de QA.

Tres cosas que se quedan del episodio:

- **El radio se mide antes de decidir.** Antes de tocar nada se comprobó que el detector de escrituras
  **no** estaba afectado: sus ocho formas denegaban igual en la candidata y en las dos versiones
  publicadas. Eso convirtió un susto en un arreglo acotado a una sola puerta, y evitó tocar código
  compartido que hoy funciona.
- **Un límite se cierra con su criterio, nunca de rebote.** Al plegar la continuación de línea era fácil
  arrastrar el escape del guion y cerrar en silencio un hueco que tiene dueño y ventana. Se dejó fijado
  por dos casos vecinos, y el auditor lo verificó expresamente al levantar el veto.
- **Y la simetría, que es la parte que nadie vigila:** el código acabó cubriendo **más** de lo que el
  criterio prometía —siete envoltorios donde el requerimiento declaraba tres—, y denegaba una forma que
  el propio documento decía no ver. Un límite que desaparece sin decirlo es tanta deriva como una
  promesa incumplida, así que la regla quedó escrita en las dos direcciones: **cuando el código cubra más
  de lo que el criterio promete, se actualiza el criterio en el mismo cambio.**

En la tercera vuelta la puerta de git quedó aprobada, y el arreglo fue **del criterio, no del guardián**:
se verificó que el código cumple la regla reescrita en 24 comandos, con los cuatro bordes del fin de
opciones. El banco dejó de bailar —tres corridas de la línea base dan el mismo número, y las 625 líneas
de resultado son idénticas entre corridas, no sólo el total—. Y quedaron dos límites dichos en voz alta:
un token **entrecomillado** desaparece del análisis, así que `git clean "-f"` pasa donde `git clean -f`
no —es el mismo descuento de comillas compartido cuyo arreglo está asignado a la ventana siguiente, y la
versión publicada se comporta igual—, y **un margen de coste expresado como cociente castiga a la máquina
rápida**: el delta es constante, el cociente no. Los dos se corrigen en el requerimiento, sin tocar una
línea de código.

### Corregido — el instrumento: un caso del banco decidía por reloj de pared (QA-111)

**Qué fallaba:** el caso «heredoc CITADO de ~300 KB → allow y barato» comparaba el tiempo medido
contra un umbral fijo de 1 000 ms puesto justo encima de lo observado. QA lo vio dar **1 038 ms
(FAIL)** y **616 ms (PASS)** sobre **la misma** línea base sin cambiar nada — y por eso dos corridas
completas de v1.30.3 dieron 457 y 458. **Por qué importa más de lo que parece:** el banco es la
puerta **requerida** de `main`, y un rojo que la gente aprende a re-lanzar es un rojo que deja de
significar algo. **Qué cambia — el reparto, no un número más alto:** (1) el **veredicto**
(`deny`/`allow`) es discreto y estable, decide el caso y no se reintenta; (2) que el hook
**responda** se comprueba por el código de salida de `timeout`, no por una comparación de reloj, y
**siempre**, también donde se espera `allow` — que es justo donde un hook muerto pasaba por bueno
(QA-007); (3) el **tiempo** se conserva, porque el coste es la propiedad que estos casos vigilan,
pero contra un techo **holgado** (cuatro veces el presupuesto declarado, ajustable por
`ARNES_CRONO_HOLGURA`) y **con reintento**: sólo falla si la mejor de tres medidas se pasa. Un pico
de carga ajena no es una regresión; un algoritmo cuadrático se pasa por múltiplos, no por un 4 %.
Reintentar no cuesta nada en el camino feliz. **Eran diez los casos que decidían por reloj**: nueve
por el cronómetro compartido y uno suelto (`SEC-004 CA-50b`, el enlace roto), que llevaba su propio
umbral de 1 000 ms escrito a mano; los diez pasan al mismo criterio. Y lo que el caso quería
acreditar —que el heredoc citado se descuenta **entero** y no entra en el presupuesto de análisis—
se comprueba ahora **sin reloj**, por el motivo del `deny`: si los 300 KB hubieran entrado en el
presupuesto, la respuesta sería el rechazo **por tamaño**; que el motivo nombre la ruta prueba
además que el análisis corrió. El caso cronometrado se queda como **medición** del coste.

### Corregido — la rama hermana del aviso: una sección que sí existe pero no tiene entradas (QA-109)

**Qué fallaba:** desde la vuelta 1, una sección **declarada que no existe** en el documento avisa y
lo refleja el bloque derivado (CA-09). La rama de al lado seguía muda: una sección que **sí** existe
y **supera el umbral**, pero cuyo contenido no tiene ni una entrada reconocible, no rota nada y no
decía nada. **No es hipotético:** el `## Historial de cambios` de los REQ de este repositorio es una
**tabla**, y las filas de tabla son continuaciones (CA-07), no entradas — así que ArnesJuan
encendiendo su propia rotación no rotaría nada y no se enteraría. Es el mismo error de mapeo y el
mismo silencio que CA-09 declara inaceptable. **Qué cambia:** se emite el aviso por stderr y se
cuenta para el bloque derivado, exactamente como en la otra rama, con **texto distinto** en los dos
casos, porque la acción que pide cada uno es distinta: allí se corrige el nombre de la sección en el
manifiesto; aquí, el formato de la sección o la expectativa de rotarla. **Lo que no cambia:** no
rotar sigue siendo lo correcto —sin entradas no hay límite seguro donde cortar—, y sólo se avisa
**por encima del umbral**: por debajo no se toca nada por diseño (CA-06) y avisar sería ruido en
cada parada.

### Corregido — el instrumento, otra vez: la idempotencia del bloque derivado se decidía por el reloj (QA-119)

**Qué fallaba:** el caso «CA-09 idempotente» comparaba **byte a byte** las dos pasadas del bloque
derivado, y el bloque se encabeza con la fecha y la hora **al minuto**. Si las dos pasadas cruzaban
un cambio de minuto, el caso fallaba sin que nada estuviera roto: QA lo midió **1 de 9** corridas
completas, y dos corridas del **mismo** árbol dieron `483 · 185 · 1` y `482 · 186 · 1`. **Es la
misma familia que QA-111** —un caso del banco que decide por reloj de pared—, sólo que allí el
reloj entraba como umbral de tiempo y aquí como contenido de la salida. **Por qué importa:** el
banco es la puerta **requerida** de `main`; un rojo aleatorio bloquea una fusión legítima y, peor,
enseña a re-lanzar el CI hasta que salga verde, que es como una puerta deja de significar algo.
**Qué cambia — en el banco, no en el bloque:** la hora **se queda** en `docs/ESTADO.md`, porque es
para la persona que lo lee; lo que se corrige es la comparación, que ahora **neutraliza** la línea
de la marca —sustituye su valor por un testigo— en lugar de fijar el reloj. Fijar el reloj obligaría
a interponer un `date` falso en el `PATH` del hook: mediría una plataforma que no es la de
producción y taparía cualquier otro uso de la fecha que apareciera después. Y no se **borra** la
línea, se neutraliza: la comparación sigue exigiendo que la cabecera esté y en su sitio, y **su
formato lo mide un caso propio**, porque neutralizar sin medir aparte es dejar de probar. Se añade
además el **cruce de minuto forzado** —se falsea la marca de la pasada anterior en vez de esperar
60 s— con un canario: byte a byte tiene que seguir dando «distintos», o el caso estaría en verde
por no medir nada. **Repasado el resto del banco:** de **16** comparaciones byte a byte (11 con
`cmp`, 5 por `md5sum`), ésta era la **única** que comparaba contra una salida regenerada con marca
de tiempo; las otras 15 comparan un archivo que **no debe cambiar** contra su copia previa, donde
no hay fecha que generar. Los otros dos usos del reloj en el arnés —la marca `ARNES:ROTADO` de los
dos rotadores— no los compara nadie byte a byte.

### Corregido — un temporal huérfano cuando al hook lo matan a mitad de la escritura (QA-118)

**Qué fallaba:** `estado-derivado` publica `docs/ESTADO.md` escribiendo primero un temporal y
moviéndolo encima, y desde SEC-011 el fallo que **devuelve error** —carpeta sin permiso, disco
lleno— borra el temporal y avisa. Faltaba la tercera forma de fallar: que al proceso lo **maten**
mientras escribe. Con un límite de tamaño de archivo (`ulimit -f`, SIGXFSZ) el intérprete moría
dentro del `printf` y ningún `rm` posterior llegaba a correr: medido, el hook salía **153** y dejaba
un `ESTADO.md.arnes.tmp` a medias **en silencio**, al lado del único archivo que sobrevive a la
pérdida de contexto. El destino quedaba intacto —eso ya estaba bien—, pero un artefacto huérfano
sin explicación es basura que alguien tendrá que interpretar justo cuando ya no queda contexto.
**Qué cambia:** un `trap` sobre `EXIT INT TERM XFSZ` limpia el temporal en la salida y en las
señales que la interrumpen. Y al **atender** SIGXFSZ la señal deja de ser mortal: `printf` devuelve
error, el `&&` no llega al `mv` —el destino sigue intacto— y la avería sale por el mismo camino que
las otras dos, con aviso propio y código de salida **0**, que es lo que el hook de parada promete:
nunca bloquear una parada, nunca callar la avería. Medido antes y después con la misma avería:
`iguales-1-no-153` → `iguales-0-si-0`. **Fuera de alcance, declarado:** los dos rotadores escriben
sus temporales con el mismo patrón y comparten esta debilidad ante una señal; viene apagada por
defecto y nadie la ha medido, así que queda anotada, no arreglada de paso.

### Pruebas
Banco: **683 casos** (310 antes de esta versión; 480 al cerrar la implementación, 569 con los
casos que añadió QA, 606 tras la vuelta 1, 615 tras la vuelta 2, 680 tras las vueltas 3 y 4, y 683
con los tres de la vuelta 5), **682 PASS · 0 FAIL · 1 SKIP** sobre la candidata y el cuadre de
`CASOS_ESPERADOS` cerrado. Contra la instalación estable **v1.30.3**, el mismo banco da
**494 PASS · 188 FAIL · 1 SKIP**: son los casos nuevos de comportamiento —fail-before/pass-after—,
entre ellos el de QA-118, que contra la línea base da exactamente el síntoma reportado
(`iguales-1-no-153`). Esa cifra de línea base es **reproducible**, y ésa es la prueba de que QA-119
está cerrado: **cinco corridas seguidas** dieron `494 · 188 · 1` las cinco, donde antes del arreglo
dos corridas del mismo árbol daban `483 · 185 · 1` y `482 · 186 · 1`. Los dos casos que añade la
vuelta 5 para QA-119 pasan **también** contra la línea base: corrigen el instrumento, no el hook.
Coste medido con `awk` y `jq` instrumentados en el `PATH` (Linux/WSL2): el camino común de `Bash`
(`ls -la`, `npm run build` por `guard.sh`) gasta **1 `jq`**, los mismos que v1.30.3 —eran **2**
antes de la vuelta 1, porque leer el manifiesto se había puesto por delante del corte temprano—;
un comando que **sí** menciona `git` cuesta 2, que es la lectura del manifiesto que la puerta
nueva necesita para saber si está encendida; una edición fuera de las rutas protegidas **baja**
de 3 a 2, y el cierre de un REQ de 1 `awk` a 0. En reloj, `ls -la` por `guard.sh` sobre 200
invocaciones: **23,1 ms → 19,0 ms** por invocación (v1.30.3: 13,7 ms en la misma máquina; el
resto no son procesos, es el intérprete cargando un guardián más). El coste real en Windows/MSYS,
donde un fork cuesta entre 1,2 y 6 s, **queda por medir antes de publicar**.

## [Interno] — 2026-09-05 · migración del andamiaje de este repo 1.30.2 → 1.30.3 (`arnes-upgrade`)
> Origen: Interno · usuario: Juan · modelo de IA: Fable 5.1 (coordinadora) · skill `arnes-upgrade` del plugin 1.30.3.

- Origen 1.30.2 **CONFIRMADO** (`.arnes/plantillas-origen/` idéntica a `v1.30.2:templates/`); destino 1.30.3 (instalación 6c1b58a, la actual). Ninguna plantilla cambia entre ambas: **nada que aplicar**. Plan en `.arnes/migracion.md`.
- `.arnes/plantillas-origen/` completada con las 3 plantillas que faltaban (ADR, DELIVERY, guard.test.ts), copiadas de la versión destino.
- `arnes_version` 1.30.2 → 1.30.3 (Fase 5, tras verificar). Aviso «Hacia 1.30.3» aplicado: `tools/arnes-lectura.sh` no muestra ningún REQ `completado` con veredictos pendientes.
- Primer uso real de la skill sobre un proyecto ya inicializado tras publicar: sirve de verificación de instalación/actualización de 1.30.3.

## [Interno] — 2026-09-05 · registro del ciclo 1 del autoalojamiento
> Origen: Interno (documentación de gobernanza) · usuario: Juan · modelo de IA: Fable 5.1 (coordinadora) · agente: sesión coordinadora.

- `docs/gobernanza/autoalojamiento.md`: la fila del ciclo 1 pasa a **publicado** (v1.30.3 sobre 6c1b58a, PR #31) y se abre la fila del ciclo 2 (1.31.0, guardián v1.30.3). Sin efecto en la máquina ni en lo que heredan los proyectos.
- `requirements/REQ-001.md`: `Estado: completado` (CA-44 cumplido: tag verificado, instalación estable en 1.30.3, cola vacía, ambos veredictos aprobados). Cierre aceptado por el guardián v1.30.2.

## [1.30.3] — 2026-09-05
### Corregido — dos bypass de v1.30.2, encontrados por una revisión externa
Los dos se reprodujeron **contra la instalación estable que gobernaba la sesión**, no sobre el
papel, y los dos son de la misma familia: la puerta miraba el FRAGMENTO o el TEXTO, y no lo que
iba a quedar escrito ni lo que el shell iba a ejecutar de verdad.

- **FALLO EN ABIERTO: un `Edit` que sustituía sólo el VALOR cerraba un REQ con QA pendiente.**
  Con la cabecera en `Estado: en-revisión` / `QA: pendiente`, un `Edit` con
  `old_string: en-revisión` y `new_string: completado` devolvía **ALLOW**. Desde 1.30.2 el hook ya
  reconstruía el documento resultante, pero **además** exigía que el fragmento contuviera
  «Estado: completado» antes de correr las puertas; el fragmento `completado` no lleva esa palabra
  en ninguna parte y el hook salía por arriba. Y sustituir el valor es la forma **más natural** de
  cerrar un REQ a mano, así que el agujero estaba justo donde más se pisa. Ahora, cuando hay
  documento, la transición se determina **sólo con el documento**: hay transición si la cabecera en
  disco no decía el estado terminal y la resultante sí. El análisis del fragmento queda **sólo**
  como respaldo para un `Edit`/`MultiEdit` cuyo `old_string` no está en el archivo —la herramienta
  fallará entera y no escribirá nada—.
- **FALLO EN ABIERTO: una sustitución de comandos dentro de un heredoc SIN CITAR escribía código
  protegido sin que ninguna puerta la viera.** `cat <<EOF` / `$(echo x > src/generated.ts)` / `EOF`
  crea el archivo de verdad —bash expande el cuerpo—, pero el detector de escrituras descontaba
  **todo** el cuerpo del heredoc como texto desde 1.30.2. La corrección distingue lo que el shell
  distingue: con delimitador **citado o escapado** (`<<'EOF'`, `<<"EOF"`, `<<\EOF`) el cuerpo es
  literal y se descuenta entero, como hasta ahora; **sin citar**, se conservan y se analizan sólo
  las líneas con `$(` o con acentos graves, y el resto sigue siendo texto. Convertir el cuerpo
  entero en comandos habría devuelto el falso positivo de 1.29.1 —un resumen en heredoc con
  `cp README.md src/…` como texto—, así que no se hace. De paso, los paréntesis de la sustitución
  se retiran al tokenizar, para que el destino de `$(echo x > src/a.ts)` quede como un operando
  limpio y no como `src/a.ts)`, que no casaría con ningún glob. Todo con expansión de parámetros:
  **cero procesos nuevos** en un camino que recorre cada comando que ejecuta un agente.
  Queda escrito en el código lo que sigue fuera: una sustitución que abre en una línea y cierra en
  otra, y el resto de la cobertura parcial de Bash (`AGENTS.md` §13).

**Y un falso positivo del mismo camino, medido mientras se redactaba el requerimiento:** un `Write`
cuyo **cuerpo** citaba `Estado: completado (…)` dentro de un criterio era denegado, porque por esa
vía la transición se buscaba en todo el contenido en vez de en la cabecera. Un `Write` trae el
documento completo, así que ahora es su propio resultante y se juzga por su cabecera, igual que un
`Edit` reconstruido. Los **veredictos** de un `Write` se siguen leyendo con la precedencia estricta
de siempre (entrante sobre disco): quien borre la línea `QA:` no se libra del veredicto que hay en
disco.

Treinta y cuatro casos nuevos en el banco (230). Caso 1, sobre el documento resultante: el bypass y
su motivo, con `MultiEdit`, con `replace_all`, sobre un archivo CRLF, con la cola de aprobaciones
abierta y con una quality gate roja; el estado terminal tomado del manifiesto (`hecho`) y su
control; el respaldo por fragmento vivo (`Write`, `old_string` ausente); un REQ que no existe en
disco (sin traza de bash); y los controles que no pueden estorbar —todo en verde, la cabecera ya
cerrada, reabrir un REQ, y el `Write` que sólo cita el estado—. Caso 2, sobre el heredoc: la
sustitución, los acentos graves, `<<-` con sangría y un heredoc sin delimitador de cierre; y los
controles citado, escapado, entrecomillado, la expansión inocente, el texto literal, el
desarrollador autorizado, la here-string y la aritmética; más uno de rendimiento —10 000 líneas de
cuerpo por debajo de 5 s— porque este camino lo paga cada comando.

Cada caso de bypass trae su par **fail-before / pass-after**: falla contra los hooks de v1.30.2 y
pasa contra los de la candidata. Un caso que pasa antes del arreglo no prueba nada.

### Corregido — el primer arreglo del heredoc abría tres agujeros nuevos (vuelta 1 de QA)
La validación no aprobó: los dos bypass declarados estaban cerrados y medidos, pero **conservar la
LÍNEA ENTERA** del cuerpo que llevara una expansión metía en el análisis texto que bash nunca
ejecuta. Tres consecuencias, las dos primeras de la misma familia que este arreglo venía a cerrar:

- **FALLO EN ABIERTO: una comilla impar del cuerpo desarmaba el comando real.** El descuento de
  texto entrecomillado emparejaba comillas sobre **todo** el comando, y una comilla suelta de una
  línea conservada (`$(date) don't`) se emparejaba con la primera comilla del comando que iba
  **después** del cierre del heredoc, borrando lo que hubiera en medio: la redirección se evaporaba
  del texto analizado. `cat <<EOF` / `$(date) don't` / `EOF` / `echo x > src/robado.ts && echo 'listo'`
  daba **allow** —y el shell creaba el archivo—, con acentos graves igual, y también por la puerta
  del cierre de un REQ (`sed -i` sobre `requirements/`). La asimetría era exacta: dentro del cuerpo
  esas comillas son **texto** y no abren ni cierran nada, y el detector las leía como sintaxis.
- **FALLO EN ABIERTO POR AGOTAMIENTO DE TIEMPO.** El descuento reconstruía la cadena entera por
  cada par de comillas: coste **cuadrático** sobre el cuerpo conservado. Medido con líneas
  `$(date) 'x' "y"`: 500 líneas → 5,5 s; 1.000 → 40 s; 1.500 → sin respuesta en 65 s. Un hook
  `PreToolUse` muere a los 60 s y **un hook muerto no deniega**: el propio coste era un bypass.
- **Falso positivo devuelto:** al conservar la línea entera, `ver $(date) y luego cp README.md
  src/x.ts` se denegaba sin que nada copiara nada — el defecto de 1.29.1 por otra puerta.

**La corrección cambia la frontera.** Del cuerpo sin citar ya no se conserva la línea, sino **sólo
el interior de cada `$( … )` y de cada par de acentos graves**, que es exactamente lo que el shell
ejecuta; el resto de la línea vuelve a ser texto. Cada fragmento se **desentrecomilla por separado**
y se une a los demás con `;`, que el tokenizador ya trata como separador, así que ni una comilla ni
un operando de un fragmento pueden cruzar a otro ni al comando real: la asimetría desaparece por
construcción, no por un caso especial. Y el descuento de comillas dejó de reconstruir la cadena: se
consume el prefijo y se acumula en un buffer, con el texto acotado por fragmento. Resultado medido
en Linux/WSL2 con el mismo cuerpo: 500 líneas → 110 ms, 1.000 → 211 ms, 1.500 → 211 ms (antes,
>65 s), 5.000 → 511 ms. Coste **lineal**, y **cero procesos nuevos**: todo sigue siendo expansión de
parámetros. Dentro de una expansión las comillas siguen siendo sintaxis, como en el shell real.
Queda escrito en el código lo que sigue fuera de alcance: el escapado (`\$(`), el anidamiento, y una
sustitución multilínea, de la que se ve el comando que la abre pero no lo que siga debajo.

El banco pasa de 246 a **253 casos** (los siete nuevos, marcados `# DEV REQ-001 v2:`): el cruce de
comillas entre dos fragmentos del mismo cuerpo, el destino de un `cp` que no puede cruzar al
fragmento siguiente, el falso positivo con la mención textual **delante** de la expansión, el par
comillas-dentro-de-la-expansión con su control, la sustitución que abre en una línea y cierra en
otra, y el camino caro con el **triple** de cuerpo (5.000 líneas): un umbral que sólo se cumple en
el tamaño exacto que denunció el defecto no acredita que el coste dejó de ser cuadrático, sólo que
se movió el punto de ruptura. **253: 252 PASS · 0 FAIL · 1 SKIP** (el SKIP es de Windows) contra la
candidata, y **229 PASS · 23 FAIL · 1 SKIP** contra v1.30.2. Los casos de regresión de esta vuelta
pasan en **las dos** versiones —son conducta que no debía cambiar—; los de bypass siguen fallando
sólo contra v1.30.2.

> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos`
> (requerimiento), `desarrollador` (código, banco y bitácora) y `qa-tester` (validación, los tres
> hallazgos de esta vuelta y las correcciones del banco: reloj en milisegundos, emisor por STDIN y
> guarda de JSON vacío). `auditor-seguridad` (revisión de seguridad del árbol ya validado: `Seguridad: aprobado`, siete
> hallazgos preexistentes de clase `instrumento` derivados a REQ-007 y las limitaciones del detector
> escritas en `docs/seguridad/`). Coordinación: sesión principal (Fable 5.1); QA con Opus por
> decisión del propietario. Tres vueltas dev↔QA (tope de §6 alcanzado en la tercera, aprobada).

### Corregido — vuelta 2 de QA: el coste cuadrático no había desaparecido, había cambiado de eje
La validación volvió a no aprobar, y con razón. El descuento **por fragmento** de la vuelta 1 hizo
el coste lineal en el **número de líneas** del cuerpo (1.500 líneas: >65 s → 209 ms), pero **dentro
de una línea** los dos bucles nuevos seguían avanzando con `${r#*…}`, y cada avance **copia el resto
de la cadena**. Medido de punta a punta con una sola línea de cuerpo y N sustituciones `$(date)`
más una escritura real fuera del heredoc: N=2.000 → 1,3 s; **N=4.000 → 5,1 s, por encima del umbral
de 5 s que fija el propio requerimiento**; N=8.000 → 18,0 s; **N=16.000 (112 KB) → el hook no
responde en 60 s, muere, `guard.sh` recibe salida vacía y PERMITE** — y el shell crea el archivo.
Doblar la entrada cuadruplicaba el tiempo: cuadrático, medido, en el tamaño de una línea.

**El arreglo quita la copia por paso, no la reduce.** El texto se **parte una vez** —troceado por
`IFS`, que bash hace en C y en una pasada— y los trozos se vuelven a unir **una vez** con
`${a[*]}`: el descuento de comillas conserva los trozos pares (lo de fuera de comillas) y el
extractor de expansiones toma, de cada trozo, su prefijo hasta el primer `)`. Los prefijos son
disjuntos, así que el total es lineal. Nada más cambia de criterio: con un número impar de comillas
la última sigue sin cerrar nada y se conserva tal cual, y los fragmentos siguen sin poder cruzarse.
Medido con la misma entrada: N=4.000 5,1 s → **410 ms**; N=8.000 18,0 s → **814 ms**; N=16.000
sin respuesta → **212 ms**. **Cero procesos nuevos**: sigue siendo expansión de parámetros, `IFS` y
arrays. El camino común (un comando sin `<<`) mide lo mismo que antes y que en v1.30.2 —200
invocaciones: 23,7 s / 24,1 s / 23,9 s—, indistinguible. De regalo, la misma raíz arregla el camino
común cuando lleva muchas comillas, que era deuda anterior a este arreglo: 32 KB de comillas
10,5 s → **209 ms**; 64 KB 39,5 s → **313 ms**.

**Y un presupuesto de tamaño, porque un algoritmo lineal también tiene acantilado.** Basta una
entrada cien veces mayor para volver a los 60 s, y un hook muerto no deniega: el fallo en abierto
por agotamiento no se arregla siendo más rápido, se arregla **no aceptando lo que no se puede medir
a tiempo**. Por encima de **64 KiB de MATERIAL ANALIZADO** el hook no analiza y **deniega**
diciendo cómo salir (heredoc citado, archivo de script, o partir el comando). Lo que se mide es
exactamente: (a) los bytes de las líneas del cuerpo de un heredoc **sin citar** que llevan `$( )` o
acentos graves —lo único del cuerpo que el shell ejecuta— y (b) los bytes del texto del comando
fuera de los cuerpos. **No** se mide el tamaño del comando: un `cat > archivo <<'EOF'` de 300 KB con
el delimitador citado es la forma normal de escribir un archivo grande, su cuerpo se descuenta
entero sin analizarse y sigue en `allow` **y barato** (512 ms medidos), con caso de banco que lo
fija. El valor sale de medir el peor caso por byte: 64 KiB de cuerpo denso en `$( )` se resuelven
en **0,71 s**, frente al tope de 2 s que se fijó para el tamaño máximo admitido y a los 60 s en que
el hook muere; el doble ya cuesta 1,8 s. La denegación por tamaño **no** alcanza al agente de
código por la puerta de `guard-codigo` —a él ya se le permitía escribir—, y sí alcanza a todos por
`guard-completado`, porque la regla que ese guardián aplica también alcanza a todos. `.arnes/config.json`
puede **subir** el techo con `limites.bash_max_analisis`; no puede bajarlo, porque el defecto se
aplica sin leer el manifiesto y leerlo costaría un proceso en el camino que recorre **cada**
comando. **La clave es opcional y NO está en la plantilla del manifiesto**, a propósito: tocar una
plantilla convertiría esta versión en una migración de andamiaje para todos los proyectos, y este
parche debe quedar como «nada que migrar». El valor por defecto vive en el código; quien necesite
subirlo lo añade a mano a su `.arnes/config.json`, y la plantilla lo recogerá cuando una versión
futura toque el manifiesto por otro motivo. Queda documentada en la skill `arnes-upgrade`
(«Migraciones conocidas → Hacia 1.30.3»), junto con los cinco cambios de conducta de esta versión
y los de 1.30.1 y 1.30.2, que faltaban.

**Y un falso positivo menos:** `\$(…)` escapado en el cuerpo se denegaba aunque bash no ejecuta
nada. Se cuenta la barra invertida por **paridad**, que es la única lectura correcta —`\$(` no
ejecuta, `\\$(` sí—, con sus tres casos. Los acentos graves **no** reciben ese trato, a propósito
y por escrito: un acento escapado cambia la pareja de todos los demás y equivocarse ahí produce un
falso **negativo**; se prefiere el falso positivo.

El banco pasa de 271 a **288 casos** (17 nuevos, `# DEV REQ-001 v3:`): el eje de QA-007 en el tamaño
que antes mataba al hook, con su control; la frontera del presupuesto **al byte** (65.507 se analiza
y nombra la ruta, 65.508 deniega por tamaño y explica la salida); los 300 KB citados y los 300 KB
sin citar sin expansiones, con el control positivo que descarta que un `allow` sea un hook muerto;
4.000 líneas justo por debajo del techo, que exigen que el motivo **nombre la ruta** y así acreditan
análisis real y no atajo; el presupuesto por la puerta de `guard-completado`; la clave del manifiesto
en sus tres formas (subir, no poder bajar, y errata que no desactiva nada); y los tres del escapado.
**288: 287 PASS · 0 FAIL · 1 SKIP** contra la candidata (tres corridas idénticas), **249 · 38 · 1**
contra v1.30.2 y **282 · 5 · 1** contra el árbol de la vuelta 1 —ahí fallan el caso de QA-007 y
cuatro míos: el par fail-before/pass-after. Un defecto del banco encontrado de paso: `cronometra_bash`
estaba definida **dentro** de una sección, y cada sección corre en su propio subshell, así que al
usarla desde otra los casos no fallaban, **no se ejecutaban**; sólo el cuadre de `CASOS_ESPERADOS`
lo delató. Vive ya junto a `check` y `check_motivo`.

> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 · agentes: `desarrollador` (código,
> banco, plantilla y bitácora) y `qa-tester` (hallazgo QA-007 y las mediciones que lo acreditan).
> Validación y auditoría de seguridad pendientes: el REQ sigue `en-revisión`.

### Corregido — vuelta 3 de QA: el recorte que compró la linealidad cortaba en el `)` equivocado
La validación tampoco aprobó, y esta vez el hallazgo no era de reloj sino de **cobertura**. El
extractor de expansiones tomaba de cada trozo **el prefijo hasta el primer `)`**, sin mirar comillas
ni anidamiento, así que **todo lo que siguiera a ese `)` dentro de la misma sustitución desaparecía
del análisis — incluida la redirección**. Tres formas corrientes salían `allow`, y las tres **crean
el archivo en un shell real**:

```
$(cat "$(ls README.md)" > src/a.ts)    el ) de la sustitución INTERIOR trunca
$(echo "a)b" > src/a.ts)               el ) va dentro de comillas
$(echo "(hola)" > src/a.ts)            paréntesis literal entrecomillado
```

No es limitación heredada: **el árbol anterior al primer arreglo de esta misma versión las denegaba
las tres**, porque allí se conservaba la línea entera. Era una pérdida de cobertura introducida por
el propio trabajo, y el comentario del código afirmaba del anidamiento «es más cobertura, nunca
menos» — medido, era menos. Ese comentario también se corrige.

**El cierre de un fragmento se decide ahora por PROFUNDIDAD de paréntesis, no por el primer `)`,
contando sólo los paréntesis que no están entrecomillados.** Comillas y profundidad se resuelven en
la **misma pasada**, porque el orden contrario es imposible: para saber qué comillas descontar hace
falta saber dónde acaba el fragmento, y para saber dónde acaba hace falta haber descontado las
comillas. La línea se marca una vez con unas pocas sustituciones `${s//x/y}` —cada una una pasada de
bash en C— y se parte **una vez** en «átomos»: cada átomo es un carácter con significado (`\`, `$(`,
`(`, `)`, `"`, `'`) seguido del texto que va detrás. El recorrido toca cada átomo exactamente una
vez y el texto del fragmento se acumula en un **array** que se une al cerrar; nunca se concatenan
cadenas, que es copiar, y copiar dentro de un bucle fue justo lo que hizo cuadrática a la versión de
la vuelta 1. **Coste lineal, cero procesos nuevos**: sigue siendo `IFS`, expansión de parámetros y
arrays. Si la profundidad nunca vuelve a cero —una sustitución que no cierra en su línea— el
fragmento es el resto de la línea, que es la lectura fail-closed y la que ya se aplicaba.

**Las comillas sólo son sintaxis DENTRO de la sustitución, y eso no es un detalle de implementación:
es lo que hace bash.** En el cuerpo de un heredoc sin citar una comilla es texto —`don't $(cp
README.md src/a.ts)` ejecuta el `cp`—, mientras que dentro de `$( )` el shell reinterpreta como
comando. Por eso el estado de comillas nace vacío al abrir cada fragmento y muere al cerrarlo: no
cruza de un fragmento a otro ni contagia al texto de alrededor. Con una comilla **impar** —la que no
cierra nunca— se conserva lo que va detrás, tal cual: no se inventa un cierre que no hay, y lo que
no se puede descontar se analiza.

**La misma revisión destapó un `)` más que tampoco cerraba: el escapado.** La paridad de la barra
invertida sólo se aplicaba a `$(`, así que un `\)` —un paréntesis **literal**, que no cierra nada—
partía el fragmento antes de tiempo y se llevaba la redirección por delante. Verificado en un
sandbox real: `cat <<EOF` / `$(echo \) > src/x.ts)` / `EOF` **crea el archivo** y el hook decía
`allow`. Es la misma familia que el hallazgo, encontrada al escribir el arreglo, y se cierra en el
mismo sitio: la paridad vale ahora para **todos** los caracteres con significado, no sólo para `$(`.
Su control obligatorio —el mismo `)` **sin** barra, que sí cierra y deja lo de detrás como texto—
sigue en `allow`.

**Lo que no cambia, y hay caso para cada cosa:** el texto que sigue al cierre **real** sigue siendo
texto (`$(date) (texto) cp README.md src/x.ts` → `allow`), que es lo que impide «arreglarlo»
volviendo a analizar la línea entera y devolver el falso positivo de 1.29.1; los acentos graves
siguen leyéndose por **parejas** y sin interpretar el escapado, con su límite escrito; y `\$(` sigue
siendo texto.

Medido de punta a punta, con canario positivo y negativo antes de cada tanda y `timeout` duro
(Linux/WSL2): el peor caso **justo por debajo del presupuesto** —65.400 bytes con 21.800 `$()` más
una escritura real— tarda **2,1–2,2 s** y deniega, frente al umbral de 5 s y al techo de 60 s en que
el hook muere; una línea con 8.000 `$(date)` (56 KB) **1,0 s**; con 16.000 (112 KB) **218 ms**, por
presupuesto; 20.000 líneas de cuerpo (320 KB) **1,3 s**, por presupuesto; 4.000 líneas justo bajo el
techo **1,1 s** analizando y nombrando la ruta. El camino común —el que recorre cada comando de cada
agente— sigue **indistinguible**: 100 invocaciones seguidas, **95 ms/invocación en la candidata
frente a 90 ms en v1.30.2**, que es el arranque de bash y no el análisis; y con muchas comillas
(64 KB) la candidata deniega en 316 ms donde v1.30.2 no responde en 30 s y **permite**. La población
legítima no se toca: heredoc citado de 300 KB `allow` en 422 ms, sin citar y sin expansiones `allow`
en 424 ms, y el control con una escritura real detrás sigue en `deny` en 527 ms.

**Y el `deny` por tamaño ya dice cuánto.** Explicaba que el comando supera el presupuesto y daba
tres salidas, pero no el **número**, así que quien lo recibía tenía que adivinar por dónde partir.
Ahora el motivo dice el presupuesto **vigente** en bytes —el efectivo, no una constante escrita en
el mensaje: si el manifiesto lo sube con `limites.bash_max_analisis`, el mensaje sube con él— en las
dos puertas. El techo se vuelve a resolver en el guardián porque el detector corre dentro de una
sustitución de comandos, o sea en un subshell, y lo que memorice allí no vuelve; es un `jq` en el
camino de la **denegación**, que ya no es el camino común.

El banco pasa de 295 a **303 casos** (8 nuevos, `# DEV REQ-001 v4:`): las cuatro esquinas de la
regla de profundidad —anidada con la escritura en el interior, un `)` entre comillas **simples**,
paréntesis que nunca cierra con una escritura detrás, y el reverso obligatorio, `(texto)` tras el
cierre real como texto—, el `)` escapado con su control, y el motivo del `deny` por tamaño con el
número, en las dos puertas.
**303: 302 PASS · 0 FAIL · 1 SKIP** contra la candidata (tres corridas idénticas: dos en paralelo y
una secuencial) y **253 · 49 · 1** contra v1.30.2, las dos cuadrando con `CASOS_ESPERADOS`. Los tres
casos rojos del hallazgo y seis de los ocho nuevos **fallan** contra v1.30.2 y pasan contra la
candidata; los otros dos son controles positivos y pasan en las dos. Y los **únicos dos** casos con
`esperado=allow` que fallan contra v1.30.2 siguen siendo los dos cambios de conducta ya declarados:
ni uno más.

> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 · agentes: `desarrollador` (código,
> banco y bitácora) y `qa-tester` (hallazgos QA-015 y QA-016 y las mediciones que los acreditan).
> Validación y auditoría de seguridad pendientes: el REQ sigue `en-revisión`.
### Autoalojamiento — el arnés se instala sobre sí mismo
El repositorio queda inicializado con su propio andamiaje (`arnes-init`, plantillas de 1.30.2):
`AGENTS.md`, `CLAUDE.md`, `.arnes/config.json` (con `hooks/`, `tools/` y `.github/` como código
protegido), `requirements/`, `PENDING_APPROVAL.md`, `docs/ESTADO.md`, `ARCHITECTURE.md`,
`.arnes/plantillas-origen/` y el `pre-commit`. El procedimiento permanente está en
`docs/gobernanza/autoalojamiento.md`: **la versión estable N gobierna el desarrollo de N+1**.
Medido antes de editar: la instalación que corre los hooks es 1.30.2 (38b59fb), en
`~/.claude/plugins/cache/…/1.30.2`, byte a byte igual al tag y distinta del worktree; un `Write`
de la coordinadora sobre `hooks/` fue denegado por ella.

## [1.30.2] — 2026-09-05
### Corregido — tres fallos medidos por tres revisores distintos el mismo día
- **FALLO EN ABIERTO: un MultiEdit cerraba el REQ aprobando sólo la línea del historial.** La regla
  de 1.30.0 —los campos valen sólo en la cabecera— se aplicaba a los `new_string` **concatenados**, y
  el `## ` que separa cabecera de historia se quedaba en el disco: el fragmento del historial se leía
  como cabecera. Reproducido: `Estado: completado` + `Seguridad: aprobado (A-009)` sobre la línea
  histórica → **ALLOW** con la cabecera en `pendiente`. El hook **reconstruye ahora el documento
  resultante** aplicando cada edición al texto en disco —lo mismo que hará la herramienta— y lee la
  cabecera de ahí. Una sola regla para Edit, MultiEdit y `replace_all`; si un `old_string` no está en
  el archivo la herramienta fallará entera y no escribirá nada, y entonces se leen los fragmentos como
  antes. De paso, una línea de historia `Estado: completado (revertido)` ya no hace correr las puertas
  sobre un REQ cuya cabecera sigue en revisión. Descartada la alternativa de prohibir MultiEdit:
  castiga al que edita bien.
- **`tools/arnes-lectura.sh` siempre salía 0.** `avisa` se llamaba dentro de `$( … )` y el contador
  moría en el subshell: el informe decía *«Ningún valor anómalo»* con cuatro REQ fuera del vocabulario
  en un proyecto real. Un informe que siempre dice que todo está bien es peor que no tenerlo. El texto
  se acumula ahora con `printf -v` en el proceso padre. Además la comparación con el vocabulario era
  por prefijo (`|aprobad` casaba con `|aprobado`); es exacta.
- **Falso positivo: el cuerpo de un heredoc se leía como comando.** Un resumen en heredoc con la
  línea `cp README.md src/…` **como texto** era denegado. Reproducido con `cp`, con `>` y con `tee`
  dentro del cuerpo. El cuerpo se descuenta igual que lo entrecomillado, sin procesos y antes que las
  comillas (el delimitador puede ir entrecomillado). Sólo cuenta como heredoc `<<`/`<<-` seguido de una
  palabra: `<<<` es here-string y `1<<2` aritmética, y un delimitador que no fuera palabra tragaría el
  resto del comando —fallo abierto—.

Catorce casos nuevos en el banco (196): el bypass —también sobre un archivo CRLF— y sus dos controles; los tres cuerpos de heredoc y
cuatro controles positivos (un `cp` tras el cierre, la redirección en la propia línea del heredoc, una
here-string y la aritmética `$((1<<n))`); y tres del informe (sale 1 y nombra el valor, cuenta 1, control en 0).

## [1.30.1] — 2026-09-05
### Corregido — dos bordes que la optimización de 1.29.3 introdujo
Los encontró una revisión externa **comparando 1.29.2 con 1.29.3 archivo por archivo**, que es la
forma de encontrar lo que una mejora de rendimiento rompe sin que nada falle. De paso midió el
cambio en Linux: **747 ms → 44 ms** sobre ~3,5 MB, ~17×, con el mismo hash de salida una vez
retiradas hora y versión.

- **Un `.md` vacío desaparecía del conteo.** `awk` no emite nada para un archivo sin líneas, así
  que ya no contaba como *«archivo sin `Estado:`»* — 1.29.2 decía 1, 1.29.3 decía 0. Se cuenta antes
  de pasar a `awk`, como antes.
- **`umbral_bytes` medía caracteres.** Al sustituir `wc -c` por `${#texto}` la cuenta pasó a ser de
  caracteres: un UTF-8 de 4 032 bytes y 2 032 caracteres con umbral 3 000 rotaba antes y dejó de
  rotar. Yo lo había anotado como *«aceptable»*; el campo se llama `bytes` y tiene que medir bytes.
  `LC_ALL=C` sólo para la cuenta, y se restaura.

Un caso por borde. El patrón que el revisor nombra —cada ceguera real se vuelve regresión
permanente— es deliberado, y esta versión son dos más.

## [1.30.0] — 2026-09-05
### Corregido — FALLO EN ABIERTO: una línea de historia se leía como el veredicto
Los campos del REQ se leían en **todo** el archivo, y cuando un campo aparecía dos veces ganaba la
**última**. Un REQ que documenta su propia historia dentro del archivo —como los de 244 KB de un
proyecto real— tiene líneas de log a columna cero. Medido:

```
cabecera: Seguridad: pendiente · REQ crítico · intenta cerrar
  historia: Seguridad: aprobado (A-009, 2026-09-02)   ->  ALLOW   *** cierra con la cabecera en pendiente ***
  historia: Seguridad: aprobado                       ->  ALLOW
  historia: Seguridad: aprobado (A-009) — texto       ->  DENY    (por accidente: el texto detrás impedía normalizar)
  historia: - Seguridad: aprobado (A-009)             ->  DENY    (viñeta, no columna cero)
```

**Es la familia de `**sí**`:** la máquina lee algo distinto de lo que la cabecera declara. Y la forma
que se cuela es exactamente la que un historial usa —veredicto, referencia, fecha—.

**La regla que lo cierra es estructural, no un nombre de sección.** Los campos valen **sólo en la
cabecera: antes del primer `## `**. Es lo que la plantilla siempre dijo; ahora lo dice la máquina, en
los tres lectores a la vez —la puerta (`arnes_campos_req`), el bloque derivado (`campos-req.awk`) y
el informe (`arnes-lectura.sh`)— para que no se desfasen. Un fragmento de `Edit` sin `##` se sigue
leyendo entero. Y como consecuencia, **rotar la historia de un REQ es seguro por construcción**: nada
de lo que haya en una sección puede tocar lo que la máquina decide.

**El banco fijaba lo contrario hasta ayer.** 1.29.3 añadió *«campos a 200 líneas de la cabecera se
encuentran igual»* porque eso hacía el código. Se da la vuelta y se dice: certificar lo que el código
hace no es certificar lo que debe hacer.

### Al migrar
Corre `tools/arnes-lectura.sh` y mira dos cosas: REQ cuyos veredictos vivan **debajo** de un `##`
(hay que subirlos a la cabecera; hasta hoy se leían, desde hoy no), y REQ cuya historia tenga líneas
`Campo:` a columna cero (hasta hoy se leían como veredicto; desde hoy no, y conviene saber si alguno
cerró así).

## [1.29.3] — 2026-09-05
### Gobernanza — el CI es puerta de `main`
`proteger-main` exige desde hoy que `hooks-en-linux` esté verde y la rama al día. Aplicado con la
cuenta admin vía `gh auth switch` y verificado releyendo el ruleset. **Un PR rojo ya no se puede
fusionar.** No cambia el plugin; cambia quién decide si algo entra en `main`: el banco.

### Corregido — el bloque derivado costaba 92 segundos por parada en un proyecto real
**Medido en un proyecto real, con el control de plataforma hecho** (`bash -c true` = 2,4 s allí):
`stop.sh` **125 s por turno**, de los que **92 eran la continuidad** y 12,6 la rotación *sin nada
que rotar*. Reproducido aquí con un fixture del mismo tamaño —47 REQ, 3,7 MB, uno de 231 KB—:
**126 818 ms**.

**La causa:** el bloque recorría cada REQ **línea a línea en bash, dos veces** (una para
`Estado:`, otra dentro de `arnes_campos_req`). Con REQ de cinco líneas, como los del banco, eso son
microsegundos. Con 244 KB son decenas de miles de iteraciones por archivo, en cada parada, dos
veces por turno. **El banco no lo vio porque sus artefactos no tienen tamaño.** Es la tercera vez
que el banco certifica la corrección y no ve el coste; la lección es la misma que con el CRLF y con
el `if`: lo que no se ejecuta en condiciones reales, no se ve.

**El arreglo:** los seis campos de **todos** los REQ se extraen en **una sola pasada de `awk`**
(`hooks/campos-req.awk`) y bash normaliza 47 líneas cortas por **el mismo camino que la puerta**
—`arnes_campos_normaliza`, compartida con `arnes_campos_req`, para que dos normalizadores no se
desfasen—. Semántica conservada byte a byte: `Estado:` primera aparición, los demás última, como
hacían los bucles. Y la rotación deja de pagar un `wc -c` por artefacto.

| | antes | después |
|---|---|---|
| 47 REQ grandes, misma máquina cargada | 126 818 ms | **23 033 ms** |
| salida | `47 — completado 15 · en-revisión 32` | **idéntica** |

Lo que queda son **unos ocho procesos** —bash, `jq`, `awk`, `git`— en una plataforma donde cada uno
cuesta 1-4 s. Ése es el suelo, no el hook; se puede bajar a la mitad juntando llamadas, y queda
apuntado.

**El banco tiene ahora tamaño:** cuatro casos sobre un fixture de 3,7 MB, incluido un REQ con sus
veredictos a doscientas líneas de la cabecera, que se encuentran igual.

**Si apagaste la continuidad por coste, vuelve a encenderla y mide.** Y la observación de fondo que
esta medición deja sobre la mesa: **un REQ de 244 KB documenta su propia historia dentro del archivo**,
y eso lo paga cualquier agente que lo lea, no sólo el hook. El arreglo estructural es rotar la
historia del REQ como se rota el CHANGELOG. Queda diseñado, no construido.

## [1.29.2] — 2026-09-05
### Corregido — la contención de rutas era léxica; ahora es física
1.29.0 bloqueaba `..`, absolutas y `~`. Una revisión externa reprodujo en 1.29.1 que un **enlace
simbólico** `docs -> /externo` con `estado_derivado.archivo: docs/ESTADO.md` escribía fuera del
proyecto, y la rotación tocaba un archivo externo a través de un directorio enlazado. La cadena
parecía interna; el disco no. *«No pueden salir del proyecto»* era demasiado absoluto.

Ahora, además de la regla léxica, **el directorio destino se resuelve físicamente** con `pwd -P`
—POSIX, resuelve enlaces— y tiene que quedar dentro de la raíz también resuelta. Se comprueba el
directorio y no el archivo: el archivo puede no existir aún, y uno enlazado se escribe donde apunte
su directorio. Cuesta dos subshells, que se pagan sólo en una parada de agente.

**Los casos del banco que lo fijan salen `SKIP` en Windows** —sin modo desarrollador `ln -s` no
crea un enlace real— **y corren de verdad en el CI de Linux.** Es la primera vez que un caso existe
*porque* hay CI: sin él no habría dónde ejecutarlo.

### Pendiente del dueño del repo — el CI aún no es puerta de `main` *(resuelto el mismo día; ver 1.29.3)*
El ruleset `proteger-main` no exige `hooks-en-linux`; un PR rojo se puede fusionar. Editarlo exige
admin, y la cuenta que opera el arnés tiene `push` pero no `admin`: la API devuelve 404. El
procedimiento exacto y la regla en JSON están en `docs/gobernanza/ci-como-puerta.md`. Hasta
entonces el CI **informa pero no impide**, y está escrito así.

## [1.29.1] — 2026-09-05
### Corregido — el banco tenía un caso que desaparecía en Linux, y el CI lo cazó en su primer viaje
El primer run del banco fuera de Windows abortó con **«168 casos y se esperaban 169»**: el mismo
hueco que el revisor había medido como 161 de 162. El caso «ruta estilo Windows con backslashes»
va dentro de `if command -v cygpath`, y en Linux no hay `cygpath`: **el caso no fallaba,
desaparecía**, y un caso ausente se lee igual que uno que pasó. Es exactamente lo que el cuadre de
casos existe para cazar, y lo cazó en 6 segundos.

**El banco tiene ahora tres estados.** Un caso que no puede correr en esta plataforma imprime
`SKIP` con el motivo, y el cuadre suma `PASS + FAIL + SKIP`. Saltarse un caso por plataforma es
legítimo; que no se vea, no.

**Y el dato que este run dejó medido:** los mismos 169 casos tardan **24 minutos en Windows y 6
segundos en Linux**. Es el coste de crear procesos en esta plataforma, en una sola cifra. Sólo
cambia el banco: el plugin es el de 1.29.0.

## [1.29.0] — 2026-09-05
Cuatro hallazgos de una revisión externa que leyó el código de 1.28.0. Tres verificados y
corregidos; el cuarto es una decisión de política y queda abierto, dicho aquí.

### Corregido — en Unix NINGÚN hook se ejecutaba
`guard.sh` y `stop.sh` —los dos puntos de entrada que `hooks.json` invoca— estaban en el índice
como `100644`. En Linux o macOS, Claude Code intentaba ejecutarlos, recibía *Permission denied* y
**seguía adelante**: todo el enforcement apagado, en silencio. También `estado-derivado.sh`,
`rotar-artefactos.sh`, `tools/arnes-lectura.sh` y la plantilla del `pre-commit`, que al copiarse
sin bit deja de exigir el CHANGELOG.

**Nadie lo vio porque los tres que probamos el arnés estamos en Windows**, donde el bit no
existe. Lo encontró una revisión externa; lo fija un CI en `ubuntu-latest` que comprueba el modo
de cada punto de entrada como propiedad cerrada y corre el banco entero. Es la primera vez que
el arnés se ejecuta fuera de Windows.

### Corregido — `Rigor: ligero` saltaba las puertas, no sólo los veredictos
La plantilla promete que `ligero` corre *«analista + desarrollador + quality gates»*. El código
hacía `return 0` **antes** de la clase del hallazgo, de las aprobaciones humanas pendientes y de
las quality gates: un REQ `ligero` cerraba con el build en rojo y con una decisión humana sin
tomar. Deriva mía desde 1.19.0: la máquina hacía menos de lo que el papel decía.

Ahora `ligero` salta **exactamente** los veredictos de QA y seguridad. Las tres puertas corren
igual. Cuatro casos lo fijan, incluido el control positivo de que sigue saltando lo que debe.

### Corregido — una ruta del manifiesto podía salir del proyecto
`estado_derivado.archivo` y las `ruta` de la rotación se concatenaban a la raíz tal cual: con
`"archivo": "../fuera.md"` el hook de parada escribía **fuera del repositorio** en cada parada.
El manifiesto también lo puede escribir un agente, y `guard-codigo` no lo protege.

Regla cerrada, sin forks: relativa, sin `..` como segmento, sin `~`, sin barra invertida. Lo que
no sea una ruta POSIX relativa limpia no se escribe ni se toca, y el hook sale 0 igual.

### Abierto — un REQ nuevo sin `QA:` puede cerrarse, y es una decisión, no un olvido
La puerta exige `QA: aprobado` **si el campo existe**. Fue una elección de compatibilidad
—los REQ anteriores al campo no pueden quedar bloqueados— y tiene su caso de prueba. La revisión
señala, con razón, que un REQ **nuevo** escrito directamente como `Estado: completado` sin `QA:`
también pasa, y eso contradice la promesa.

No se cierra en esta versión porque **la máquina no puede distinguir un REQ viejo de uno nuevo
mirando el archivo**. El camino honesto es en dos pasos: `/arnes-upgrade` añade `QA: pendiente`
a los REQ que no lo tienen, y en la versión siguiente la puerta exige el campo. Hacerlo al revés
bloquearía todo REQ antiguo el día de instalar.

### Añadido — CI
`.github/workflows/banco.yml`: en cada push a `main` y en cada PR, comprueba el bit de ejecución
y corre los 169 casos en Linux. Si el total cuadra en Windows y no en Linux, hay un caso
dependiente de plataforma — y eso también hay que saberlo.

## [1.28.0] — 2026-09-05
### Corregido — FALLO EN ABIERTO: desde 1.25.0 una redirección por Bash rodeaba las dos puertas
**Medido en un proyecto real, con control positivo en la misma tanda:** un `Write` a `src/` denegó
—el plugin estaba cargado—, y `echo 'Estado: completado' > requirements/x.md` **pasó y creó el
archivo**. También `echo '// sonda' > src/x.ts`. Reportado como `SEC-184` reabierto.

**La causa es mía y es del diseño de 1.25.0.** Puse un handler con `if` por disparador para que un
`ls` no arrancara el guardián. `if` funciona —verificado en `2.1.260` y `2.1.261`, en plugin— **pero
sólo para prefijos de comando**. Una redirección **nunca casa**: Claude Code la separa del comando
antes de evaluar el patrón, como dice la doc de permisos al tratar el destino de `>` como escritura
aparte. `Bash(* >*)` y `Bash(*>*)` no dispararon en ninguna versión.

```
touch a.txt          ->  IF_TOUCH dispara
echo hola > b.txt    ->  TODOS dispara, ningún IF_REDIR
cp a.txt c.txt       ->  IF_CP dispara
```

**Lo reportaron dos proyectos por separado, y la atribución importa.** Uno concluyó que los diez
handlers fallaban; el otro midió que `cp` y `tee` denegaban y concluyó, textualmente, que
*«`Bash(* >*)` no se dispara nunca; los otros nueve empiezan por un token literal y funcionan»*.
La medición aquí confirmó el segundo diagnóstico letra por letra. No cambia el arreglo: la
redirección es la forma de escritura más común y puede ir en cualquier comando, así que **la única
puerta posible para Bash es la que ve todos**. Se restaura el catch-all. El coste vuelve al de 1.24.0
y se acepta.

**Mi prueba de integración tenía control positivo para que `if` existe, no para el patrón del que
dependía todo.** Sondeó `touch` y pasó. Ahora sondea la redirección y exige que **no** case; si un
día casa, sale con código 3 para revisar si Bash puede volver a ser selectivo. Y el banco, que en
1.25.0 **exigía** que todo handler de Bash llevara `if` —certificando la forma que dejaba la puerta
en abierto—, ahora exige lo contrario.

**La lección, que vale más que el defecto** y que la escribió quien lo encontró: *una optimización
que reduce cuándo se invoca un control puede apagarlo entero sin cambiar una línea de su lógica.*
El guardián era correcto; simplemente ya no se le llamaba.

`stop.sh` se queda: es independiente y correcto.

## [1.27.0] — 2026-09-04
### Corregido — la rotación no funcionaba en archivos CRLF, y además fugaba
**Medido en un proyecto real:** su `CHANGELOG.md` (sin CR) rotó perfecto — 1 421 795 → 36 650
bytes. Su registro de seguridad (12 857 CRLF) **creaba el archivo y no recortaba el origen**, en
silencio y con `exit 0`.

La causa, aislada por quien lo reportó: al cortar el bloque por el salto de línea, la sonda de
verificación se quedaba con el **CR pegado al final** — 92 bytes contra 91 — mientras `grep` en
Windows lee el archivo en modo texto y ya lo ha quitado de sus líneas. No podía casar nunca. **Es
la misma familia que el CR de `jq` que dejaba `guard-codigo` en abierto**, sólo que aquí viene del
propio archivo — y en Windows eso es la mayoría de los archivos. El banco no lo vio porque
escribía todos sus artefactos con LF.

**Y era peor que inoperante.** Al medirlo aquí apareció lo que el informe no llegó a ver: el
contenido quedaba en los **dos** sitios, así que cada parada lo volvía a añadir — 3, 6, 9 secciones
en tres pasadas. Una fuga sin tope, justo en la función cuyo propósito es frenar el crecimiento
sin tope.

Dos arreglos, y el segundo es el que importa para el futuro:
- La sonda pierde el CR final. Seguro en los dos casos: `-F` busca subcadena, así que casa igual
  con una línea que lo conserve.
- **La escritura pasa a ser todo o nada.** El destino se arma en un temporal y sólo se publica si
  la verificación pasa. Antes se añadía y *después* se verificaba, así que **cualquier** fallo de
  verificación —no sólo el del CR— dejaba el contenido duplicado.

### Documentado — el intérprete: por qué añadir `Bash(python*)` sería teatro
El mismo informe señaló que `python - <<EOF` no está entre los disparadores de 1.25.0. Cierto — y
medirlo dio algo más incómodo: **aunque estuviera, no serviría.**

```
python - <<EOF ... open("src/app.ts","w") ... EOF   ->  no detecta
node -e '...writeFileSync("src/app.ts")...'          ->  no detecta
echo x > src/app.ts                                  ->  src/app.ts   (control positivo)
```

El guardión arrancaría, miraría el comando y permitiría: la ruta vive **dentro** del script.
Añadir el disparador sería coste sin cobertura — y peor que el hueco, porque parecería cerrado.

El arreglo de verdad es **cambiar la pregunta**: en vez de adivinar *antes* si un comando escribe
—abierta, admite formas nuevas sin fin— preguntar *después* si cambiaron los archivos protegidos,
que es **cerrada**. No previene, detecta; pero el arnés ya se declara barandilla, y una que avisa
siempre vale más que una que previene a veces. Queda diseñado y nombrado en `hooks.json`, el
README y `AGENTS.md`; no construido.

## [1.26.0] — 2026-09-04
Tres correcciones medidas por un tercer proyecto. Ninguna toca archivos del proyecto.

### Corregido — el orden de rotación es del ARTEFACTO, no del proyecto
**Era mi error, y del mismo tipo que llevo el día evitando en otros sitios.** `rotacion.orden` era
un solo valor global, pero medido en un proyecto real el `CHANGELOG.md` crece **por arriba** y
`docs/seguridad/registro-seguridad.md` **por abajo**. Un orden único no puede servir a los dos, y
equivocarse archiva **lo más reciente** — justo lo que hay que tener a mano. Con dos bitácoras de
1,4 MB y 1,3 MB, la función quedaba inservible para una de ellas.

`artefactos` acepta ahora **cadena u objeto**, la misma convención que ya usan las
`quality_gates`: una cadena hereda los ajustes globales, un objeto declara los suyos
(`ruta`, `orden`, `umbral_bytes`, `conservar_secciones`). Los manifiestos que hoy declaran una
lista de nombres siguen funcionando igual.

### Corregido — `Estado:` no llevaba la regla del paréntesis
1.23.0 hizo que `aprobado (evidencia)` contara como `aprobado`, y no apliqué lo mismo a `Estado:`.
Medido: el bloque derivado decía **2 completados donde había 9** y metía 44 REQ en «otros».

**La puerta no estaba afectada** — busca el estado terminal en el texto crudo y lo caza igual, con
fecha o sin ella; está medido. Así que no era un fallo en abierto: era **un tablero que mentía**.
Serio igual, porque el proyecto que lo reportó tuvo que apagar la continuidad por eso.

### Añadido — la versión instalada se ve en cada parada
Un proyecto corrió **1.13.0 durante un mes** con 1.24.0 publicada, sin ninguna señal. El bloque
derivado imprime ahora la versión del plugin instalado y, si el proyecto declara otra en
`arnes_version`, avisa de **migración pendiente**.

**No consulta la red, a propósito.** Un hook que hace DNS puede colgar una parada, y estos hooks
tienen como primera invariante no bloquear nunca. Se enseña lo que es gratis — lo instalado contra
lo declarado. Comparar contra lo publicado es trabajo de `/arnes-upgrade`, que ya tiene red y ya
acredita la versión de origen.

## [1.25.0] — 2026-09-04
### Cambiado — un `ls` ya no arranca el guardián
Hasta ahora **cada** comando Bash —`git status`, `ls`, `grep`, `npm test`— arrancaba `guard.sh`, y
en esta plataforma arrancar el intérprete es la parte cara (~1,2 s medido, con el resto del
trabajo ya optimizado). La mayoría de esas llamadas terminaba en *«no escribe nada relevante →
permitir»*: se pagaba el proceso para no hacer nada.

Ahora el `hooks.json` del plugin declara **un handler por disparador**, cada uno con un `if` que
Claude Code evalúa **antes de crear el proceso**. `Bash(* >*)`, `Bash(tee *)`, `Bash(cp *)`,
`Bash(mv *)`, `Bash(install *)`, `Bash(sed -i*)`, `Bash(perl -i*)`, `Bash(dd *)`, `Bash(xargs *)`.
Un comando que no casa con ninguno **no arranca nada**.

**Verificado, no leído.** Plugin desechable con dos handlers —uno sin `if` como control positivo y
otro con `if: "Bash(touch *)"`—, sesión headless con `--plugin-dir`, un `ls` y un `touch`: el
control registró los dos; el `if` sólo el `touch`. Sin el control, «no hay registro para `ls`» habría
sido indistinguible de «el plugin no cargó». Queda como prueba de integración en
`tests/escenarios/integracion/plugin-if/`.

**Qué se pierde, dicho antes y no después.** El motor de `if` desenvuelve `timeout`, `nice`, `xargs`
sin flags y asignaciones de entorno; **no** desenvuelve `npx`, `docker exec`, `bash -c`, `xargs -n1`
ni `find -exec`. Nuestro detector escaneaba el texto entero y ahí veía algo más. La cobertura de
Bash siempre estuvo declarada parcial; ahora está **medida**, y el banco fija la lista de
disparadores para que ninguno desaparezca en silencio.

**Por qué no hay un «perfil estricto» como interruptor.** Un plugin envía un solo `hooks.json`, y un
interruptor por proyecto exigiría arrancar el proceso para leerlo — justo el coste que esto evita. Se
envía la forma que ahorra; quien quiera el catch-all anterior puede añadir en su `settings.json` un
hook `Bash` sin `if` hacia el mismo `guard.sh`.

`Edit`/`Write`/`MultiEdit` siguen pasando siempre por `guard.sh`: sus globs de código son
configuración **del proyecto**, y el filtro del plugin no puede conocerlos.

### Cambiado — `Stop` y `SubagentStop` en un solo proceso
Continuidad y rotación iban como dos hooks: dos intérpretes por cada parada de cada subagente, y
como la rotación viene apagada, el segundo arrancaba sólo para descubrir que no tenía nada que
hacer. `stop.sh` hace el preludio una vez y corre los dos como funciones — el mismo principio que
`guard.sh`. Los dos archivos siguen siendo ejecutables por su cuenta y el banco los invoca así. De
paso, ambos calculaban su directorio con dos forks; ahora con ninguno.

Sin migración de archivos del proyecto: basta actualizar el plugin.

## [1.24.0] — 2026-09-04
Tres correcciones, todas medidas por **dos proyectos distintos** validando 1.23.0 contra sus
archivos reales. Ninguna toca archivos del proyecto: migrar es sólo actualizar el plugin.

### Corregido — `**aprobado** (medido…)` no contaba y `aprobado (medido…)` sí
Al normalizar, el énfasis sólo se retira si envuelve el valor **entero** — y con el paréntesis
detrás no lo envolvía. Luego se quitaba el paréntesis y quedaba `**aprobado**`. Mismo valor, dos
escrituras, veredictos opuestos: la misma asimetría que `n/a` / `no aplica`. Ahora el veredicto
se desenvuelve **otra vez** tras quitar el paréntesis. La dirección era segura —la decorada era
la estricta—, pero una regla que depende de cómo se escribe el mismo valor no es una regla.

### Corregido — el bloque derivado contaba una nota como REQ
Decía 58 REQ donde había 57: contaba todo `.md` de `requirements/` salvo el README, incluida una
nota sin `Estado:`. **Un bloque que presume de derivar del disco no puede decir 58 donde el disco
dice 57.** Sin `Estado:` no es un REQ; se cuentan aparte y **se dice cuántos hay** — que un
archivo quede fuera por silencio es justo lo que el bloque existe para evitar.

### Cambiado — el bloque derivado lista sólo lo abierto
Con 58 REQ pesaba **10,4 KB**: un 25 % sobre un `ESTADO.md` de 40 KB que se lee al empezar
**cada** sesión. Es justo el presupuesto que la rotación existe para cuidar, y aquí se lo estaba
comiendo el arnés. El bloque responde *«dónde quedamos»*, y un REQ completado ya no es parte de
esa respuesta: la línea de conteo lo resume y la tabla lista sólo los abiertos.

### Documentado — la continuidad viene encendida y corre en cada parada de subagente
Dos revisores lo señalaron con la misma frase: *«que lo sepas antes, no después»*. `docs/ESTADO.md`
es territorio del integrador, y con agentes en paralelo varias reescrituras compiten. Es
idempotente y las reescrituras producen el mismo bloque, así que no se corrompe — pero el hook
escribe en un archivo que una persona mantiene, y eso se avisa al migrar. Se apaga con
`estado_derivado.activo: false`.

## [1.23.0] — 2026-09-04
### Corregido — el paréntesis es evidencia, y la evidencia no cambia el veredicto
**Medido en un proyecto real: 26 REQ paralizados.** Su convención es
`QA: aprobado (medido el 3/9, 42 pruebas)` —el veredicto con lo que lo sostiene al lado— y la
comparación exigía la palabra exacta. Veinte REQ no habrían podido cerrarse y diez ya cerrados
habrían sido denegados al volver a tocarlos.

La alternativa era quitar los paréntesis de 35 líneas de veredicto, o sea **borrar la evidencia
del encabezado del REQ** — que es media razón de ser de este arnés. Poner la medición al lado de
la afirmación es lo que permite cazar lo falso; un veredicto sin ella es una opinión.

**La ambigüedad era un error de diseño mío, y se quita en vez de arbitrarse.** 1.21.0 metía el
matiz **dentro** del paréntesis —`aprobado (preventiva)`—, así que el mismo signo significaba
«evidencia» en un caso y «matiz que invierte el veredicto» en el otro: cortar servía a uno y rompía
al otro. Pero **un matiz que cambia el veredicto ES OTRO VEREDICTO**, no un paréntesis: una
revisión hecha antes de que existiera el código y una aprobación del código son estados distintos
del mundo, y meter uno entre paréntesis del otro era confundirlos.

- `Seguridad: preventiva` pasa a ser **su propio valor** (antes `aprobado (preventiva)`). Sigue
  sin cerrar un REQ crítico y sigue desbloqueando el orden del ciclo. Costó casi nada cambiarlo:
  la sintaxis tenía un día y estaba declarada en cero REQ.
- Un paréntesis **final y balanceado** se retira antes de comparar. `aprobado (sin cerrar` no es
  un paréntesis, es texto — la misma lección que el énfasis pareado.

**Riesgo residual, dicho en voz alta:** `aprobado (con reservas)` cuenta como aprobado. Es una
violación de la convención —el matiz debe ser un veredicto— y no un agujero silencioso: está
escrito en la plantilla del REQ y en la ficha de los dos agentes que firman.

El cambio es **estrictamente más permisivo** en los campos de veredicto: nada que pasara antes
falla ahora.

### Corregido — la cola de aprobaciones acaba donde acaba su sección
El conteo sólo cerraba la sección ante una cabecera literal `## Resueltas`. Cualquier otra
—`## Notas`, `## Histórico`— la dejaba abierta y sus `###` se contaban como aprobaciones
pendientes, bloqueando cierres legítimos. Los proyectos lo esquivaban **ordenando el archivo**:
carga, no estilo.

Otra lista enumerada donde hacía falta una propiedad cerrada: la sección va de su cabecera a la
**siguiente del mismo nivel**, se llame como se llame.

### Documentado — el plugin no se actualiza solo
Medido: un proyecto corría **1.13.0 del 3 de agosto** con **1.21.0** publicada. Un mes de
correcciones —tres puertas que no existían incluidas— que nunca llegaron, sin ninguna señal.

Y es peor de lo que parece, porque **las correcciones que más importan son silenciosas por
definición**: cuando una puerta no se está cumpliendo, nada falla — simplemente no protege. El
README y `/arnes-upgrade` lo dicen ahora, y la Fase 1 avisa de comprobar que el plugin instalado
sea el actual antes de usarlo como destino.

## [1.22.0] — 2026-09-04
### Añadido — continuidad automática: el arnés deja escrito dónde quedó todo
El coste más caro de una sesión larga no es el tiempo: es **reconstruir dónde quedó todo cuando
el contexto se pierde**. Un hook `Stop` / `SubagentStop` reescribe ahora en `docs/ESTADO.md`,
entre marcadores, un bloque con el estado y los veredictos de cada REQ, la cola de aprobaciones,
la rama y si el árbol tiene cambios sin comitear.

**No se redacta: se deriva, y ésa es toda la diferencia.** Pedirle a un agente que resuma lo que
hizo no resuelve nada, porque un resumen escrito por el modelo miente justo cuando más falta
hace —cuando le queda poco contexto, que es cuando peor recuerda—. Aquí cada línea sale de leer
un archivo: si el bloque se equivoca, es que el disco dice eso.

Los veredictos aparecen **como los lee la máquina** —normalizados, sin mayúsculas ni tildes ni
marcado— y no como están escritos en el REQ. Es deliberado: un `Sensible a seguridad: **sí**`
sale en el bloque con su rigor efectivo `critico`, así que **el fallo que 1.21.0 arregló habría
sido visible** en este tablero.

**Las invariantes que trae por delante de su utilidad:**
- **Nunca bloquea la parada.** Un hook `Stop` que falla deja la sesión colgada, y una herramienta
  de continuidad que impide terminar es peor que no tenerla. Sale `0` pase lo que pase.
- **No toca lo que escribió una persona.** Sólo reescribe entre sus marcadores.
- **Idempotente.** Dos pasadas dan un solo bloque.
- **Inerte sin manifiesto**, como los demás hooks, y **no inventa la carpeta destino**: decidir la
  estructura de un proyecto no le toca al arnés.
- **Si `git` no puede responder, lo dice.** El árbol queda `desconocido`, no «limpio» ni «con
  cambios»: las dos serían afirmar un hecho que no se tiene. Es la misma regla que 1.21.0 aplicó
  a los valores que no se entienden.

Se apaga con `estado_derivado.activo: false`.

### Añadido — rotación de artefactos: una bitácora no puede crecer sin tope
Medido en un proyecto real: el `CHANGELOG.md` llegó a **1,17 MB**. A ~4 caracteres por token son
del orden de **300 000 tokens en un solo archivo**, y se pagan otra vez en cada sesión que lo
lea. No es un problema de disco: es presupuesto.

El hook `Stop` / `SubagentStop` **mueve** las secciones sobrantes a `<nombre>-archivo.md` y deja
un puntero.

**Mueve; no resume.** Un resumen aquí sería peor que el problema: convertiría la bitácora en *la
versión que el modelo recuerda de la bitácora*, y una bitácora que no es fiel no sirve para nada.

**Las invariantes, otra vez por delante de la utilidad:**
- **Apagada salvo que el proyecto la encienda.** Reestructurar un documento que escribió una
  persona no puede ser el comportamiento por defecto.
- **Nunca borra.** Añade al destino, **relee para comprobar que llegó**, y sólo entonces recorta
  el origen. Si la comprobación falla, el origen no se toca: mejor un archivo grande que uno
  perdido.
- **Corta sólo en encabezados `## `.** Sin límites seguros no hace nada; un corte a media sección
  parte una entrada en dos.
- **Qué mitad es «lo viejo» no se adivina, se declara** (`rotacion.orden`). Un CHANGELOG pone lo
  nuevo arriba; un registro cronológico lo añade al final. Adivinar mal archivaría lo más
  **reciente**, que es justo lo que hay que tener a mano.
- **Idempotente por construcción:** al terminar quedan exactamente `conservar_secciones`, así que
  la pasada siguiente no encuentra excedente. La primera versión restaba al revés y cada pasada
  volvía a rotar, vaciando el archivo a trozos; lo cazó la prueba de idempotencia.

Y un fallo que la prueba también cazó antes de existir el caso: la comprobación de que el texto
llegó al destino usaba `case`, pero un encabezado `## [1.20.0]` lleva **corchetes**, que en un
patrón de `case` son una clase de caracteres y no texto. Habría fallado siempre, y el recorte no
habría ocurrido nunca. Ahora se compara con `grep -F`.

### Corregido — el asterisco de nota al pie no es énfasis (regresión de 1.21.0)
1.21.0 retiraba **todo** `*` del valor, y eso convertía `Seguridad: aprobado*` en `aprobado`. Un
asterisco tras una firma no es adorno: es una **llamada a nota al pie**, y una nota al pie apunta
a una **salvedad** — lo contrario de una firma incondicional. Lo delataba una asimetría:
`aprobado, ver nota` denegó siempre (el texto sobra), pero `aprobado*` pasaba. El agujero era
exactamente la forma escueta.

**Es el mismo error de 1.21.0, girado.** El argumento —*el marcado no es parte del valor*— se
hizo sobre `Sensible a seguridad:`, donde `**sí**` sí es el mismo valor, y el cambio se aplicó a
los cinco campos. **El sujeto del arreglo era más estrecho que su población**, que es literalmente
la invariante que el propio arnés enuncia.

El arreglo conserva el argumento sin abrir puerta nueva: **el énfasis de Markdown es pareado por
definición**, así que sólo se retira cuando **envuelve el valor entero**. `**sí**` sí; `aprobado*`
no. Un asterisco suelto nunca envuelve nada.

### Corregido — sólo una negación explícita abre la puerta de seguridad
El conjunto negativo de 1.21.0 incluía `n/a` y `ninguna`. Pero eso es lo que alguien escribe
cuando **no ha clasificado**, no cuando ha decidido que un REQ no es sensible: esas dos entradas
le abrían un hueco a la regla de fallo cerrado **justo en el caso para el que se construyó**. Lo
delataba una asimetría: `n/a` abría la puerta y `no aplica`, que es la misma frase, la cerraba.

Alargar la lista para taparlo sería la lista enumerada que se pudre. Lo correcto es invertir de
qué lado va la generosidad: **el conjunto que ABRE la puerta debe ser mínimo e inequívoco**
—`no`, `n`, `false`— y el que la cierra puede ser generoso, porque equivocarse ahí no cuesta
nada. Ahora las dos formas coinciden, y ninguna abre.

### Corregido — `estado_derivado.activo: false` no apagaba nada
En `jq`, el operador `//` trata `false` **igual que ausente**: `.activo // true` devuelve `true`
cuando alguien escribió `false`, así que el interruptor estaba soldado en «encendido». Lo
encontró el caso de prueba, no una lectura del código.

Es la misma clase de defecto que el resto de esta versión: **una comprobación que no distingue
«ausente» de «explícitamente negativo».** Ahora sólo un `false` explícito apaga; el resto deja el
hook activo, que es el lado inocuo. Revisados los demás `//` del código: todos operan sobre
cadenas o arrays, donde `//` se comporta bien.

## [1.21.0] — 2026-09-04
### Corregido — `Sensible a seguridad: **sí**` no activaba la puerta de seguridad
**Fallo en abierto, medido en un proyecto real:** siete REQ declaraban ser sensibles y
**ninguno** casaba. El normalizador plegaba la tilde y bajaba a minúsculas, pero el marcado
de Markdown seguía ahí: `**sí**` llegaba como `**si**`, que no es `si`, así que el rigor
efectivo caía a `estandar` y `Seguridad: aprobado` **dejaba de exigirse**. La puerta no se
abría: nunca llegaba a existir. Seis eran negrita; el séptimo llevaba un comentario tras el
valor.

Uno de ellos gobernaba la subida de foto de perfil —Entra ID, token delegado, datos
personales— y lo único que impedía su cierre era que QA seguía en `con-hallazgos`. Estaba a
un campo de distancia.

**El arreglo va en dos mitades, y la segunda es la que importa.**

1. **El marcado no es parte del valor.** `arnes_norm_campo` retira `*`, `_` y las comillas
   invertidas. No es una lista de variantes del valor —esas se pudren—: es retirar sintaxis
   de Markdown, que es un conjunto cerrado y ajeno al dominio. El **paréntesis no se toca**
   ahí: cortarlo convertiría `Seguridad: aprobado (preventiva)` en una firma completa, y una
   auditoría preventiva cerraría un REQ crítico. Habría sido cambiar un fallo en abierto por
   otro.

2. **Tres estados, y el tercero cae del lado seguro.** `arnes_sens_efectiva` clasifica el
   campo en `sí` / `no` / **no se entiende**, y lo que no se entiende se trata como sensible.
   Una forma cerrada sólo funciona si algo obliga a producirla, y aquí el valor es Markdown
   libre tecleado por un agente: el sujeto del control es más estrecho que su población. La
   respuesta no es enumerar mejor, es que **la lista deje de ser peligrosa cuando esté
   incompleta**. Es la regla que `/arnes-upgrade` ya aplica a `UNKNOWN` —*una comprobación que
   no puede responder no dice «no sé», dice «sí»*— y que aquí faltaba. La denegación lo
   explica, porque un `deny` que no dice de dónde sale se lee como falso positivo y acaba con
   alguien apagando el guard.

**Campo ausente sigue significando «no».** Cambiarlo obligaría a auditar todo REQ anterior a
que el campo existiera.

### Corregido — el banco escribía siempre limpio, y por eso no lo veía
Veinticuatro fixtures, dos valores: `"sí"` y `"no"`. Es **el mismo diagnóstico que quedó
escrito en 1.16.0** sobre otro campo —*«el banco no lo veía porque escribía su propio archivo
limpio, nunca la plantilla»*— y reapareció porque entonces se arregló el **caso** y no el
**banco**. Ahora cada campo que se compara contra una forma cerrada tiene su fixture decorado
con sus controles negativos: trece casos, incluido el que fija que la firma preventiva
**decorada** tampoco cierra.

### Documentado — el intérprete es el siguiente agujero por tamaño
`node script.mjs` no lo ve ningún guardián: el detector lee el texto del comando y la ruta
vive **dentro** del script. No es una regresión —la cobertura de `Bash` siempre se declaró
parcial— pero ahora está medido y nombrado en vez de quedar bajo el genérico «scripts»: en
Windows, donde `sed -i` es incómodo, un intérprete es lo primero que alcanza cualquiera.

### Añadido — `/arnes-upgrade` acredita la versión de origen en vez de creérsela
`arnes_version` lo escribe quien migra y **ninguna puerta lo comprobaba**. Es la misma clase de
defecto que `Sensible a seguridad: **sí**`: un campo escrito a mano que nadie verifica acaba
mintiendo. Aquí miente en el peor sitio, porque de ese número sale la **base** del merge a tres
vías: si es falso, la base se recupera igual —sólo que la equivocada— y entonces cada `INTACTO`
y cada `MODIFICADO` se calculan contra un documento que el proyecto nunca tuvo. La migración no
falla: **acierta en el procedimiento y se equivoca en todo el resultado.**

*(Caso real: un proyecto declaraba `1.15.0` con el plugin instalado en `1.14.0` — una versión
que ni siquiera estaba presente.)*

La Fase 1 pasa a dar **tres resultados**: `CONFIRMADO` —las plantillas de origen guardadas son
idénticas a las del tag declarado—, `CORROBORADO` —no las hay, pero los marcadores concuerdan, y
se sigue **diciéndolo**: la base es reconstruida, no guardada— y `DESMENTIDO`, que es `UNKNOWN`
y para. Antes de nada, una contradicción barata: un origen **posterior** al plugin instalado es
imposible.

Los **marcadores** son rasgos que sólo pueden existir a partir de una versión. Sirven para
**desmentir**, que es barato y seguro; reconstruir el número exacto a partir de ellos sería
inferencia, que es justo lo que esta skill evita. Si desmienten lo declarado se **pregunta**, no
se sustituye por la que parezca.

### Añadido — `/arnes-upgrade` avisa del choque de vocabulario del rigor
Un proyecto con su propia escala —dos niveles, declarados en `Sensible a seguridad:`, con QA
siempre— no puede mapearla a la del plugin —tres niveles, declarados en `Rigor:`, donde
`ligero` **salta QA**— sin decidir. Queda como **CONFLICTO** con su tabla: se pregunta qué
trabajo puede prescindir de QA, y «ninguno» es una respuesta válida.

## [1.20.0] — 2026-09-04

> **Esta versión no llegó a publicarse por separado y NO tiene tag.** Su contenido entró en
> `main` dentro del mismo commit que 1.21.0 —el squash del PR #13 los fusionó—, así que ningún
> commit llegó nunca a declarar `1.20.0` en `plugin.json`. Se conserva como entrada porque
> describe un cuerpo de trabajo distinto y `/arnes-upgrade` lo necesita como **paso** de
> migración, pero ningún proyecto puede estar *en* 1.20.0. Etiquetarla apuntaría a un commit
> que dice `1.21.0`: una versión existe cuando `plugin.json` la declara.
### Cambiado — `/arnes-upgrade` pasa a ser un merge a tres vías, no una comparación
La primera versión comparaba el archivo del proyecto contra la plantilla nueva y preguntaba
ante cualquier diferencia. En un proyecto real **casi todo difiere**, así que serían ~20
preguntas por migración y el usuario acabaría aceptándolas sin leer — peor que no preguntar.

El modelo correcto son **tres** documentos: la plantilla de la versión de **origen** (base), el
archivo **del proyecto**, y la plantilla de **destino**. La base es lo que permite distinguir
*«esto lo escribió una persona»* de *«esto es andamiaje que nadie tocó»*.

**Cuatro estados** en vez de «igual o distinto»:

| Estado | Evidencia | Acción |
|---|---|---|
| `NUEVO` | No existía en la base | Añadir |
| `INTACTO` | Idéntico a la base | Actualizar |
| `MODIFICADO` | Existe y difiere de la base | Conflicto |
| `ELIMINADO` | Existía en la base y ya no está | Conflicto |

`ELIMINADO` es conflicto y **no** «volver a añadir»: una sección ausente pudo borrarse a
propósito, y reponerla revertiría una decisión humana en silencio.

**Tres resultados, nunca dos:** `SAFE` se aplica solo; `CONFLICTO` y **`UNKNOWN`** se detienen
igual. Nunca se convierte incertidumbre en decisión — una comprobación que no puede responder
no dice «no sé», dice «sí», y aquí eso significaría pisar trabajo de una persona.

**Protocolo verificable**, porque lo ejecuta un agente y no código determinista: inventario →
plan → aplicar sólo lo planeado → **verificar releyendo el disco** → registrar. La fase de
verificación es la que importa: *el acto de editar no es la prueba de que se editó bien*. Es la
misma regla de acreditar por contenido que el arnés aplica a todo lo demás.

**Reanudable, no atómica.** El plan vive en `.arnes/migracion.md` y al reanudar sólo hay dos
caminos válidos: continuar desde la primera operación no aplicada, o revertir con git. Nunca
«parece que algunas cosas ya están, sigo desde donde me parezca» — eso vuelve a inferir el
estado del contenido, que es lo que el plan existe para evitar.

**El respaldo lo da git**, no una copia hecha a mano: se exige el árbol limpio antes de empezar.

### Añadido — `arnes-init` guarda las plantillas de origen
En `.arnes/plantillas-origen/`, sin rellenar. Ocupa unos KB y es lo que hace posible el merge a
tres vías **sin depender de tener acceso al repositorio del plugin**. La migración las refresca
al terminar, para que la siguiente tenga base.

### Corregido — `v1.14.0` nunca se etiquetó
Sin ese tag, un proyecto inicializado en 1.14.0 no tenía base recuperable y la migración habría
caído en `UNKNOWN` para todo. Etiquetada retroactivamente; las seis versiones vivas
(`v1.14.0`…`v1.19.0`) están verificadas contra el `plugin.json` que declaran.

### Añadido — el ciclo se cumple: seguridad no firma lo que QA no ha validado
`AGENTS.md` §6 fija desarrollador → qa-tester → auditor-seguridad. La regla ya estaba escrita;
faltaba que se cumpliera: buscando paralelismo se emitió la firma de seguridad sobre árboles que
QA no había validado, y el argumento del propio auditor lo zanja — *«yo no miro seis de las
siete quality gates»*.

Corre en **cualquier** edición del REQ, no sólo al cerrarlo: el daño se hace al escribir el
veredicto. **Excepción nombrada:** la auditoría **preventiva** —sin código todavía— sí puede ir
por delante, y se declara como `Seguridad: aprobado (preventiva)` **al emitirla**, no al
invocarla.

La excepción **está escrita donde se lee**, no sólo en el mensaje del `deny`: `AGENTS.md` §6 y
§13, `requirements/README.md` y la ficha del `auditor-seguridad`. Una máquina que exige algo que
el `AGENTS.md` del proyecto no describe es exactamente la deriva que `/arnes-upgrade` existe para
evitar; por eso esta migración **no es cosmética**: sin ella el hook deniega y la salida no está
documentada en el proyecto.

### Corregido — el bloqueo mutuo que la regla del orden habría causado
La ficha del `qa-tester` metía **dos actos en una frase**: «marca `QA: aprobado` **y**
`Estado: completado`», condicionado a que ya existiera `Seguridad: aprobado`. Con la regla del
orden recién añadida eso cierra un ciclo: QA espera la firma de seguridad, y seguridad no puede
firmar hasta que QA apruebe. Un REQ sensible no habría avanzado nunca.

Los dos actos van separados: **el veredicto se emite en cuanto la validación pasa** —sin esperar
a nadie— y **el cierre sí espera** la auditoría. Un `aprobado (preventiva)` desbloquea el orden
pero **no cierra** un REQ crítico, y ahora hay caso de prueba que lo fija.

### Corregido — el `README` describía un agujero que ya estaba tapado
Decía que `guard-completado` «no mira `Bash` en absoluto» y que un `sed -i` podía cerrar un REQ
sin pasar por las puertas. Dejó de ser cierto en 1.16.0: sí mira `Bash`, y lo **deriva** a
`Edit`/`Write`. Documentación caducada en la dirección peligrosa —prometer menos protección de la
que hay también es deriva—.

### Corregido — el banco de pruebas dejaba de tragarse el `stderr`
`corre()` mandaba `stderr` a `/dev/null`, así que un aborto del canario sólo podía ofrecer tres
conjeturas —«¿CRLF? ¿jq? ¿permisos?»— y ninguna evidencia; es justo lo que el propio banco
prohíbe en `check_motivo`. Ahora se aparta a un archivo fijo reutilizado (cero forks extra) y
todo fallo lo enseña; el canario añade además la salida real, el `rc` de un segundo intento y los
permisos del hook.

### Corregido — los insumos de proyectos reales no podían publicarse por descuido
Los documentos que traen lecciones de un proyecto concreto llevan hallazgos de un cliente
—nombres, umbrales, arquitectura, huecos de seguridad— y este repositorio es **público**.
Estaban sin versionar, pero nada impedía que un `git add -A` distraído los subiera. Ahora
`mejoras-arnes-*.md` e `insumos/` están ignorados: el arnés se queda con la **forma** del
hallazgo y nunca con su instancia.

## [1.19.0] — 2026-09-04
### Añadido — nivel de rigor por REQ: no todo requerimiento paga lo mismo
El arnés aplicaba el máximo rigor a todo: un cambio de texto pasaba por los mismos cuatro
agentes que un cálculo de dinero. Medido en el proyecto de origen, un REQ cuesta del orden de
**1 M de tokens** y varias horas de reloj; para la mayoría eso es desproporcionado, y el arnés
no tenía forma de decirlo.

Cada REQ declara ahora `Rigor:` en su cabecera:

| Nivel | Qué corre | Cuándo |
|---|---|---|
| `ligero` | analista + desarrollador + quality gates | Sin lógica: textos, etiquetas, presentación |
| `estandar` | + QA | Lógica de negocio ordinaria |
| `critico` | + auditoría de seguridad | Dinero · datos personales · identidad o acceso · documento con efecto legal · cambio irreversible |

**El arnés trae el MECANISMO, nunca el MAPEO.** Los criterios son independientes del dominio a
propósito. Qué REQ de un proyecto concreto cae en cada nivel lo pregunta `arnes-init` y se
escribe en el `AGENTS.md` **de ese proyecto**: el plugin no sabe —ni debe— qué es una constancia
salarial.

**Compatibilidad total, y es deliberada.** Un REQ que no declara `Rigor:` se juzga **exactamente
como antes de que los niveles existieran**. Un proyecto que no migre no nota ningún cambio, y la
velocidad se gana con un acto explícito, nunca por sorpresa.

**Se puede subir, nunca bajar.** `Sensible a seguridad: sí` impone `critico` como **suelo**:
escribir `Rigor: ligero` ahí no baja nada. Un valor no reconocido se ignora y cae a la
derivación — nunca abre la puerta.

Distinguir el **suelo de seguridad** del **valor por defecto** es lo que hace que esto funcione:
tratarlos como lo mismo deja `ligero` inalcanzable, porque el defecto de un REQ no sensible ya
es `estandar` y anularía cualquier declaración menor.

**Gobierno:** lo fija el `analista-requerimientos`; el `auditor-seguridad` **puede subirlo** —y
subirlo sobre un REQ ya cerrado lo **reabre**— y nadie lo baja sin firma del dueño del sistema.

### Pruebas
68 → **77 casos**, 0 fallos. Los tres que más importan impiden que el nivel se convierta en una
puerta trasera: `ligero` sobre un REQ sensible, `estandar` sobre un REQ sensible, y un valor
inventado. Los tres deben **denegar**.
## [1.18.0] — 2026-09-04
### Añadido — `/arnes-upgrade`: los proyectos existentes también se ponen al día
Hasta ahora el arnés no tenía **ninguna ruta de migración**. `arnes-init` se niega a actuar si
el proyecto ya está inicializado, y no existía nada más.

El problema que eso creaba es estructural, no accidental: los hooks, los agentes y las skills
viven **en el plugin** y se actualizan solos, pero los ~10 archivos que `arnes-init` copió al
proyecto —`AGENTS.md`, `.arnes/config.json`, `requirements/README.md`…— **quedan congelados
para siempre**. Cada versión nueva del arnés garantizaba así una deriva: **la máquina empezaba
a exigir cosas que el `AGENTS.md` del proyecto no describe**, y los agentes, que leen esos
archivos, no se enteraban de las capacidades nuevas.

`/arnes-upgrade` cierra ese hueco, con tres reglas de diseño:

- **Aditivo y quirúrgico, nunca sobrescribe.** Un `AGENTS.md` está lleno de decisiones del
  proyecto —stack, módulos, gates—; copiar la plantilla encima las destruiría. Añade lo que
  falta y, si una sección existe pero con contenido distinto, **muestra la diferencia y
  pregunta** en vez de fusionar a ciegas.
- **`arnes_version` es el registro de la migración, y se actualiza AL FINAL.** Subirlo antes
  de aplicar los cambios haría que la siguiente ejecución creyera que ya está hecho, dejando
  el proyecto a medias sin que nadie lo note.
- **Los REQ existentes no se tocan.** Los campos nuevos son compatibles hacia atrás por
  diseño, y hay un caso de prueba que lo fija.

`arnes-init` remite ahora a esta skill cuando encuentra un proyecto ya inicializado con una
versión distinta a la instalada. Sin ese aviso, quien la ejecutara se quedaba sin camino.

## [1.17.0] — 2026-09-04
### Rendimiento — el coste no era `jq`, era bifurcar
Los hooks tardaban **~35 s por edición de archivo** en Windows. La causa no era la que
parecía. Medido en esa máquina:

```
$(echo hola)   subshell con un builtin    554 ms
dirname        binario externo            643 ms
${var//x/y}    expansión pura de bash       0 ms
```

Ejecutar el binario sólo suma ~80 ms sobre el `fork` que lo envuelve. En Windows no existe
`fork()` y la emulación MSYS lo resuelve copiando memoria a mano, así que **el gasto está en
bifurcar, no en los programas**. El código estaba escrito en el estilo normal de shell
—funciones que devuelven por stdout, tuberías para transformar texto—, que es gratis en Linux
y carísimo aquí.

| | Antes | Ahora |
|---|---|---|
| Una edición de archivo | ~35 s | **5,5 s** |
| Un comando de shell | ~30 s | **3,3 s** |
| Suite completa (68 casos) | — | 630 s |

Los cambios, todos en la misma dirección:

- **Un solo punto de entrada** (`hooks/guard.sh`): los dos guardianes hacían el mismo trabajo
  previo —arrancar, cargar la librería, leer stdin, interpretar el mismo JSON, leer el mismo
  manifiesto— cada uno en su proceso. Ahora el preludio se hace una vez y ambos corren como
  funciones en el mismo proceso, con el análisis **memorizado**.
- **Toda función que devuelve por stdout obliga a un `$( )` en cada llamada.** Los helpers del
  camino caliente pasan a **asignar a una variable**.
- **Lecturas de `jq` con here-string:** `< <(printf … | arnes_jq …)` eran **tres** bifurcaciones
  por lectura (sustitución de proceso, tubería y el `$( )` interno). Ahora una.
- **Texto manipulado en bash, no en procesos:** `printf|sed|head` para leer un campo del REQ
  costaba 5.116 ms por campo y se invocaba cinco veces; en bash son 326 ms. `printf|tr|tr`,
  `cat`, `dirname`, `cygpath` innecesario y los `sed` de la detección de escrituras por shell
  (esta última, **−94%**) salen del camino común.

**Lo que no cambia:** los dos guardianes siguen siendo **ejecutables por su cuenta** y el banco
los invoca así. Producción y pruebas ejecutan la misma función, no dos copias que puedan
desfasarse.

**El riesgo que hubo que cerrar al convertirlos en funciones:** decir «permito» con `exit 0`
mata el proceso y el segundo guardián nunca corre — fallo abierto y en silencio. Todo `exit`
del cuerpo pasó a `return`, y hay un caso de prueba (`deny`, o sea control positivo) que existe
sólo para cazar una reintroducción de ese error.

### Corregido — un REQ con `Sensible a seguridad: SÍ` se saltaba la auditoría
La normalización a minúsculas trabaja byte a byte y, sin locale definido, no toca la `Í`. El
valor quedaba como `sÍ`, **no casaba** con la lista `sí|si`, y el REQ cerraba **sin exigir
`Seguridad: aprobado`**.

Comprobado que el código anterior se comportaba igual: el defecto es previo, no lo introduce
esta versión. El normalizador pliega ahora la tilde y la comparación es contra **una forma
cerrada** (`si`) en vez de una lista de variantes — que es exactamente lo que el arnés predica
en su propio playbook: cuando la familia de formas de escribir algo es abierta, el control no
puede enumerarlas.

### Pruebas
57 → **68 casos**, 0 fallos. Los 11 nuevos cubren el punto de entrada real (`guard.sh`), que
antes no tenía ninguno: sin ellos el banco habría validado algo distinto de lo que se ejecuta.

## [1.16.0] — 2026-09-03
### Añadido — la clase del hallazgo decide si bloquea el cierre
Hasta ahora **cualquier** hallazgo abierto impedía cerrar un REQ. En la práctica eso mantiene
REQ de negocio abiertos durante semanas por defectos **del propio arnés**: un lector de umbral
que se evade, un guardián con un agujero. Atacar guardianes es valioso, pero **no puede ser
condición para cerrar una función de negocio**.

Y el tope de vueltas no acotaba nada, porque **se reiniciaba con cada hallazgo nuevo**: cada
arreglo cierra el hallazgo documentado y la vuelta siguiente encuentra una variante legítima
del mismo defecto, así que un REQ puede pasar semanas en `en-revisión` sin haber gastado nunca
tres vueltas del mismo hallazgo.

- **Campo `Hallazgos abiertos:`** en la plantilla de REQ, con la clase entre paréntesis:
  `SEC-121 (instrumento), SEC-144 (usuario/dinero)`.
- **Tres clases, sólo dos bloquean:** `usuario/dinero` (afecta lo que alguien ve, decide o
  cobra) y `contrato` (el REQ afirma algo falso sobre lo construido) **bloquean**;
  `instrumento` (el defecto está en el control o la prueba, no en el producto) **no bloquea**
  y va a deuda técnica con dueño.
- **Un hallazgo sin clase deniega.** Sin ella la puerta no puede saber si bloquea, y un «no sé»
  que deja pasar es un «sí» disfrazado. Una clase desconocida también deniega.
- **El tope se cuenta por REQ y no se reinicia** (`AGENTS.md` §6). Agotado, el REQ no se queda
  abierto: cierra con el residual declarado —dueño, forzador medido, vencimiento— o pasa a
  `bloqueado` y se escala.

Es la primera puerta del arnés que existe para **dejar pasar**. Las demás añaden formas de
bloquear; ésta quita una que sobraba.

### Corregido — cerrada la limitación conocida de 1.15.0: `guard-completado` ya mira `Bash`
1.15.0 dejó escrito el hueco: *«un `sed -i` sobre un archivo de `requirements/` puede dejar un
REQ en `completado` sin pasar por las puertas»*. Ahora `guard-completado` está también en el
matcher de `Bash`.

**No juzga: DERIVA.** Un comando que escribe en `requirements/` y menciona el estado terminal
se deniega pidiendo que la transición se haga con `Edit`/`Write`, que es donde el hook puede ver
el contenido resultante. Reimplementar veredictos, cola y quality gates para la shell sería una
segunda transcripción de la misma regla, y dos transcripciones se desfasan.

Hereda la **misma cobertura parcial** que `guard-codigo` —usa el mismo `arnes_bash_escrituras`—
y eso queda dicho en `AGENTS.md` §13; no es cobertura total y no se presenta como tal.

La detección del estado terminal sí es **deliberadamente ancha** —en cualquier parte del
comando, no `estado:` seguido del valor—. Lo obligó una prueba en rojo: la forma más natural de
cerrar un REQ por shell sustituye el **valor** y no escribe nunca la palabra «Estado».

### Corregido — un proyecto recién inicializado no podía cerrar ningún REQ
La plantilla de `PENDING_APPROVAL.md` traía su ejemplo de formato —comentado en HTML— bajo
`## Pendientes`. El conteo de `guard-completado` cuenta líneas `^###` y no sabe de comentarios,
así que devolvía **1 pendiente** con la cola vacía y denegaba todos los cierres. El banco no lo
veía porque escribía su propio archivo limpio, nunca la plantilla.

Arreglado por los **dos** lados —el `awk` ignora lo que está dentro de `<!-- -->` y la plantilla
saca el ejemplo de la sección—, porque corregir sólo el caso que falló lo reabre en el siguiente.

### Corregido — la versión del arnés se tecleaba a mano
`templates/arnes-config.json.tpl` pasa a `{{ARNES_VERSION}}` y `arnes-init` lo deriva de
`.claude-plugin/plugin.json`. El escritor es la corrida, no una persona.

### Rendimiento — los hooks gastaban ~20 procesos por invocación
Cada `arnes_jq` arranca `jq` **y** `tr`, y en Windows sobre almacenamiento sincronizado un
arranque cuesta ~0,5 s. Los campos se leen ahora **agrupados, una llamada por fuente**, y
colocados **después** de la salida temprana que puedan aprovechar.

| Hook | Antes | Ahora |
|---|---|---|
| `guard-codigo` | 6 | **2** |
| `guard-completado` | 9 | **4** |

El caso más frecuente mejora más de lo que dice la tabla: un comando de shell de sólo lectura
—la mayoría— sale con **una** llamada, antes de tocar el manifiesto. No cambia ninguna regla.

### Pruebas
41 → 54 casos, con filtro opcional (`run.sh bash`, `run.sh hallazgo`) porque una vuelta completa
cuesta minutos y un ciclo de verificación caro es lo que empuja a saltarse la suite.

Los casos nuevos incluyen el de compatibilidad que importa —**un REQ anterior al campo de
hallazgos no puede quedar bloqueado por él**— y **dos** `deny` distintos para el cierre por
shell: con uno solo el hueco seguía abierto, porque la forma con `sed` y la forma con heredoc
fallan por razones distintas.

## [1.15.0] — 2026-09-02
### Corregido — el guard denegaba justo al agente autorizado (prefijo del plugin)
`guard-codigo` comparaba `agent_type` en crudo contra `agentes.agente_codigo` del manifiesto.
Claude Code entrega el agente **con el prefijo del plugin que lo provee**
(`arnes-juan:desarrollador`), mientras que el manifiesto declara el nombre corto
(`desarrollador`): la igualdad no se cumplía nunca y el hook **rechazaba al único agente que
puede escribir código**. Costó dos entregas bloqueadas en SENDA, y el parche local (poner el
nombre con prefijo en `.arnes/config.json`) era frágil: se rompe si el plugin cambia de nombre
y obliga a cada proyecto a conocerlo.

La comparación ahora vive en `arnes_agente_coincide()` (`hooks/lib.sh`) y es **tolerante al
prefijo sin volverse permisiva**:
- Se compara el **nombre corto** (tras el último `:`), normalizado — minúsculas, sin espacios ni
  CR: es un campo que escribe una persona a mano.
- Si **ambos** lados traen prefijo, además deben coincidir. Un proyecto que necesite
  desambiguar declara `arnes-juan:desarrollador` y con eso rechaza a `otro-plugin:desarrollador`.
- Si el manifiesto **no** trae prefijo, cualquier proveedor con ese nombre corto casa: el
  manifiesto no dijo de qué plugin viene, y exigirlo reintroduce el bug que se corrige.
El motivo del deny sigue nombrando al agente de forma legible: `'qa-tester' (arnes-juan:qa-tester)`.

`guard-completado` no compara nombres de agente en ningún punto (revisado); no le aplica.

### Añadido — cobertura PARCIAL de `Bash` en `guard-codigo`
`hooks/hooks.json` sólo declaraba `Edit|Write|MultiEdit`, así que un `cat > archivo` nunca
disparaba el guard — y eso fue exactamente lo que hizo un agente al verse rechazado por el bug
de arriba. Ahora `Bash` tiene su propio matcher (sólo `guard-codigo`) y `arnes_bash_escrituras()`
detecta las escrituras **evidentes**: redirección `>`/`>>`, `tee`, `cp`, `mv`, `install`,
`sed -i`, `perl -i` y `dd of=`.

Es deliberadamente parcial y **sesgada al falso negativo**: descarta el texto entrecomillado
antes de analizar, exige intención de escritura *y* una ruta que case con `codigo_app.globs`, y
ante la duda permite. Quedan fuera a propósito los scripts, los formateadores que reescriben
archivos (`prettier --write`, `eslint --fix`), `patch`/`git apply` y todo programa que escriba
por su cuenta. El mensaje de denegación dice que la cobertura es parcial, para que un falso
positivo se reconozca al instante.

### Cambiado — la documentación ahora dice la verdad sobre el enforcement
`AGENTS.md.tpl` §5 prometía «esto lo cumple la máquina, no la buena voluntad». No es cierto y
prometer de más es peor que documentar el hueco: quien confía en una jaula deja de mirar.
- §5 y §13: **es una barandilla, no una jaula** — impide el desvío por descuido, no contiene a
  un agente decidido a rodearla. §13 lista ahora las herramientas cubiertas por invariante y los
  huecos conocidos (Bash parcial en `guard-codigo`; `guard-completado` no mira `Bash`, así que un
  `sed -i` sobre un REQ puede cerrarlo sin pasar por las puertas).
- §6 y §7: «Cumplido por máquina» → «Vigilado por máquina», con puntero al alcance real.
- `README.md` del plugin: sección *Limitación conocida* con el porqué (un hook no puede analizar
  shell arbitrario; perseguirlo da falsos positivos y un guard que estorba acaba desactivado —
  uno apagado protege menos que uno parcial).
- `arnes-config.json.tpl`: documenta que basta el nombre corto del agente, y sincroniza
  `arnes_version` (llevaba en 1.6.0).

### Añadido — licencia de uso propietaria (`LICENSE`)
El repositorio es público —necesario para `/plugin marketplace add`— pero el arnés no es open source, y hasta ahora el repo no lo decía. `LICENSE` fija el marco: permite descarga, instalación y uso interno, incluido trabajo comercial y para clientes; prohíbe redistribución, espejos o marketplaces alternativos, obras derivadas, integración en productos de terceros e ingeniería inversa. Declara explícitamente que configurar el arnés vía `AGENTS.md`/`CLAUDE.md` y plantillas es Uso Interno, no obra derivada — la separación maquinaria/estado del proyecto llevada al plano legal. Los forks se autorizan sólo para preparar contribuciones al repo original y toda contribución queda cedida a SysVEGA. Español vinculante, traducción al inglés informativa; ley aplicable Costa Rica.

### Añadido — pruebas de regresión
`tests/escenarios/hooks/run.sh` pasa de 16 a **44 casos**: identidad con prefijo (aceptado,
denegado para otro agente, coordinadora denegada, normalización, manifiesto calificado en ambos
sentidos), escrituras por `Bash` que deben denegarse, y una batería de **falsos positivos** que
deben permitirse (`cat`, `grep`, `sed -n`, `git commit -m` con la ruta en el mensaje, leer código
y escribir fuera). Contra el código anterior fallan 14 de los 28 nuevos; contra este, 0.

Dos defensas contra el verde falso de ayer, cuando todos los casos verdes eran casos `allow` que
también pasan con el hook muerto:
- **Canario**: si el `deny` canónico no deniega, la corrida aborta en lugar de dar verde.
- **`ARNES_HOOKS_DIR`**: permite correr el banco contra otra copia de los hooks, para comprobar
  que un caso nuevo falla con el código anterior.
## [1.14.0] — 2026-09-01
### Corregido — el enforcement no funcionaba en Windows (fallaba ABIERTO y en silencio)
Descubierto en el proyecto SENDA: los tres invariantes que el arnés dice cumplir «por
máquina» (§13) llevaban desde su introducción **sin bloquear nada** en Windows. La sesión
coordinadora podía editar `src/` sin que `guard-codigo` dijera una palabra, y ningún REQ
quedaba realmente protegido por `guard-completado`. `tests/escenarios/hooks/run.sh` pasaba
de 7/13 porque **todos** sus casos verdes eran casos `allow`, que también pasan cuando el
hook no llega a ejecutarse. Tres causas independientes, cada una suficiente por sí sola:

- **Shebang con CRLF.** `.gitattributes` traía `* text=auto`, así que al clonar el plugin en
  Windows los `.sh` quedaban con CRLF y el shebang pasaba a ser `#!/usr/bin/env bash\r`.
  `env` busca un binario llamado `bash\r`, no existe, el hook **no corre** y Claude Code lo
  interpreta como permitir. Ahora `*.sh text eol=lf` los blinda, igual que ya se hacía con
  `templates/githooks/pre-commit`.
- **Traducción de rutas de MSYS.** En Windows `jq` suele ser un binario nativo: bash ve la
  raíz del proyecto como `/tmp/x` mientras que `jq` devuelve el `file_path` como
  `C:/Users/.../x`. Al restar el prefijo, `rel` conservaba la ruta absoluta, ningún glob de
  `codigo_app` casaba y el `case` de `requirements/` tampoco. Nuevo `arnes_norm_path()`
  (`hooks/lib.sh`) canoniza ambas rutas antes de compararlas — vía `cygpath` cuando existe,
  identidad en Linux y macOS.
- **CRLF en el stdout de jq.** Cada glob leído del manifiesto llegaba como `src/*\r`, que no
  casa con nada. Nuevo `arnes_jq()` retira el CR; ambos guards lo usan en lugar de `jq`.

### Corregido — `quality_gates` sólo aceptaba una de las dos formas del manifiesto
`guard-completado` leía `.quality_gates[]` esperando cadenas sueltas, pero un manifiesto real
las declara como objetos `{nombre, comando}` (la plantilla `arnes-config.json.tpl` no fija la
forma). Con objetos, el hook hacía `eval` sobre JSON pretty-printed: nunca ejecutaba las gates
de verdad y denegaba con un mensaje incomprensible. Ahora acepta **ambas** formas.

### Añadido — pruebas de regresión
`tests/escenarios/hooks/run.sh` pasa de 13 a 16 casos: `quality_gates` como objetos en verde y
en rojo, y un `file_path` estilo Windows con backslashes. Contra el código anterior fallan
8 de 16; contra este, 0.

## [1.13.0] — 2026-06-26
### Añadido — mecanismo de playbooks de plataforma
Conocimiento reutilizable y caro de aprender (errores de runtime) para un stack/servicio
concreto, sin acoplar el flujo base del arnés a ningún cliente. Es **opt-in**: sólo aplica
si el proyecto lo declara en su `AGENTS.md`.
- **`playbooks/README.md`:** documenta el mecanismo (genérico, opt-in, vinculante cuando aplica).
- **`playbooks/power-apps-dataverse.md`:** primer playbook — convenciones de persistencia
  Power Apps Code App + Dataverse (no escribir `statecode`/`statuscode`, nombres de lookup en
  `@odata.bind`, fuente nativa vs conector, identidad en 2 pasos + checklist). Cada regla nació
  de un error de runtime real.
- **`templates/dataverse-lookups.guard.test.ts.tpl`:** plantilla del test guardián de lookups
  (cruza cada `@odata.bind` contra los esquemas generados). El test no puede viajar genérico
  porque depende de `.power/schemas/` del proyecto; el arnés ofrece el arranque y cada proyecto
  lo adapta.
### Cambiado
- `desarrollador`: lee los playbooks declarados antes de codificar y respeta sus convenciones.
- `qa-tester`: nuevo paso 9 — verifica cumplimiento de playbooks y sus tests guardián;
  el incumplimiento es hallazgo.
- `AGENTS.md.tpl` §2 Stack: nueva subsección *Playbooks de plataforma aplicables* para que
  cada proyecto declare los que usa.

## [1.12.0] — 2026-06-20
### Añadido — sistema anti-deriva (cierra el lazo requerimiento↔implementación)
Evita que los cambios forzados por hallazgos de QA/seguridad queden solo en el código o en un
log y el REQ termine describiendo algo distinto de lo construido. Tres capas:
- **Política (`AGENTS.md` §9):** nuevo caso **"Cambios por hallazgo"** — un hallazgo no se
  cierra hasta que el requerimiento lo refleje (criterio de aceptación nuevo si es de QA, o NFR
  nuevo/actualizado si es de seguridad), con causa enlazada y ADR si es de fondo. El write-back
  lo hace el `analista-requerimientos`.
- **Máquina (`guard-completado`):** veredictos en el REQ — campos `QA:` y `Seguridad:`. El hook
  **impide `completado`** sin `QA: aprobado`, y un REQ `Sensible a seguridad: sí` sin
  `Seguridad: aprobado`. Compatible con REQ antiguos (solo exige el campo si está presente).
- **Cierre (`/arnes-close` + `DELIVERY.md`):** verificación **"Trazabilidad y no-deriva"**
  bloqueante por cada REQ `completado` (criterios/NFRs reflejan lo construido; cada hallazgo
  traza a REQ/NFR/ADR o está `aceptado`).
### Cambiado
- Plantilla de REQ: campos `QA:` y `Seguridad:`; documentados en `requirements/README.md`.
- Agentes: `qa-tester` fija `QA:` y exige write-back de su hallazgo antes de aprobar;
  `auditor-seguridad` fija `Seguridad:` y no levanta el veto sin el NFR; `analista` es
  responsable del write-back e inicializa los veredictos.
- `AGENTS.md` §13: nueva fila de enforcement y nota del **techo honesto** (la máquina no
  verifica equivalencia semántica; la reconciliación final es la verificación de cierre).
- Escenario de hooks: +4 casos de veredictos QA/Seguridad.

## [1.11.0] — 2026-06-20
### Cambiado
- `auditor-seguridad`: reestructuración integral del agente (supersede y amplía el checklist
  de 1.7.0), agnóstica del stack y anclada a OWASP Top 10 Web / API / LLM:
  - **Principio agnóstico del stack:** audita principios; el mecanismo concreto (secretos,
    aislamiento en BD, identidad, defaults de cloud) se lee de `AGENTS.md`. Nombres de producto
    como ejemplos, no como único mecanismo válido.
  - **Disparador obligatorio por el flag `Sensible a seguridad:`** del analista (cadena
    analista → auditor → QA atada por máquina).
  - Checklist por áreas: **Identidad/acceso** (+ validación de JWT, BFLA, sesión con OAuth/OIDC),
    **Config/exposición** (defaults de BaaS/cloud, inventario de endpoints huérfanos, CORS,
    subdomain takeover), **Entrada/salida** (XSS, deserialización, **SSRF**+IMDSv2, open redirect,
    verificación de webhooks), **Criptografía**, **Lógica de negocio/concurrencia** (abuso de
    flujo, TOCTOU), **Resiliencia** (GraphQL), **Cadena de suministro** (slopsquatting,
    toolchain de IA/MCP), **LLM**, **Gobernanza**.
  - **Regresión de seguridad entre iteraciones:** compara contra el estado aprobado en
    `registro-seguridad.md` para cazar controles que la IA debilita silenciosamente.
### Coherencia
- Veto reflejado en la línea `Estado:` del REQ (corrige `estado:`/frontmatter de la propuesta),
  consistente con dev/QA/analista.

## [1.10.0] — 2026-06-20
### Cambiado
- `analista-requerimientos`: revisión integral con foco en **completar lo no dicho**:
  - **Postura de interrogación**: indagar comportamiento ante error, casos negativos, límites
    y supuestos implícitos, no solo transcribir lo que el usuario describe.
  - **Criterios de aceptación testeables** (concretos, observables, medibles) y **Gherkin con
    escenarios de error/borde**, no solo el camino feliz — es lo que el QA usa para falsar.
  - **NFR cuantificados** con número y unidad; sin umbral → `borrador`.
  - **Sensibilidad a seguridad marcada en el origen** (mismo disparador que el gate de QA).
  - **Conflictos** registrados explícitamente; el REQ no avanza hasta resolverlos.
  - **Definition of Ready** explícita; al cumplirse, el REQ pasa de `borrador` a `pendiente`.
### Añadido
- Plantilla de REQ (`requirements/README.md`): campo `Sensible a seguridad:` y sección
  `Preguntas abiertas / conflictos`, para que el flag de seguridad y los conflictos tengan
  un lugar máquina-legible.
### Coherencia
- Vocabulario de estados del analista alineado al canónico (incluye `pendiente`, que la
  propuesta omitía); `pendiente` queda definido como "cumple Definition of Ready, listo para dev".
- Estado nombrado como línea `Estado:`, consistente con `desarrollador` y `qa-tester`.

## [1.9.0] — 2026-06-20
### Cambiado
- `qa-tester`: revisión integral del agente con foco en **falsación** (no solo confirmar):
  - **Postura adversarial**: asumir el código roto y probar entradas vacías/nulas/malformadas,
    límites, concurrencia/idempotencia y el camino de error de cada dependencia externa.
  - **Cuestionar el REQ**: devolver al analista los criterios intesteables/vagos en vez de
    aprobar contra un REQ pobre.
  - **Flakiness**: un test no determinista no es evidencia; se reporta como flaky.
  - **Carga no concluyente**: una prueba de carga no representativa no cuenta como "cumple".
  - **Independencia**: QA solo edita tests/fixtures/guía de usuario, nunca el código de la app
    (reforzado por el hook `guard-codigo`).
  - **Visto bueno de seguridad determinista** para REQ que tocan auth/datos/secretos.
  - **Artefacto persistente de hallazgos** en `docs/qa/REQ-XXX.md` (no el chat).
  - Cierre de estado coherente con los gates: completa, salvo gate humano → `PENDING_APPROVAL.md`.
### Añadido
- Carpeta `docs/qa/` (hallazgos de QA por REQ) al andamiaje (`arnes-init`) y al mapa de `AGENTS.md`.
### Coherencia
- Estado del REQ nombrado como `Estado:` (línea), consistente con la plantilla y con el `desarrollador`.
- Manifiesto `.arnes/config.json`: se aclara que `codigo_app.globs` apunta a código de
  producción (tests fuera), para que QA pueda editar pruebas sin chocar con el hook `guard-codigo`.

## [1.8.0] — 2026-06-20
### Cambiado
- `desarrollador`: revisión integral del agente y **pasa a modelo Opus** (antes Sonnet).
  - **Robustez:** de "envuelve todo en `try/catch`" a manejo en un **boundary central** (sin
    catches vacíos); redacción de logs sin tokens/PII; idempotencia y condiciones de carrera.
  - **Mecanismo exacto de estado** del REQ (línea `Estado:` del archivo, no índices paralelos)
    y regla de **`bloqueado` ante ambigüedad/conflicto** en vez de adivinar.
  - **Jerarquía ante conflictos:** NFR de seguridad > alcance del REQ > convenciones de `AGENTS.md`.
  - Nuevas secciones **Calidad y eficiencia** (solución más simple, evitar N+1/O(n²), separar
    dominio/infra) y **Pruebas** (el dev escribe las pruebas automatizadas del REQ).
  - **Definition of Done** explícita; `description` con límites de rol (no QA ni auditoría).
  - `ARCHITECTURE.md` se actualiza solo cuando cambia la vista de sistema, no por cambios internos.
- `AGENTS.md.tpl`: §5 refleja `desarrollador` en **Opus**; §7 incorpora que las pruebas
  automatizadas son parte de cada REQ (las escribe el desarrollador).

## [1.7.0] — 2026-06-20
### Añadido
- `auditor-seguridad`: cinco categorías explícitas en el checklist, nombradas para que no se
  pasen por alto:
  - **Ciclo de vida de la sesión / caducidad:** expiración del lado del servidor por
    inactividad (idle) **y** por vida máxima absoluta; cookies `HttpOnly`/`Secure`/`SameSite`;
    rotación del id de sesión; sesiones de verificación de un solo uso.
  - **BOLA / autorización a nivel de objeto (IDOR):** verificar pertenencia del recurso al
    usuario/tenant en endpoints que reciben un id, no solo que haya sesión válida.
  - **RLS / aislamiento en la BD:** Row-Level Security como defensa en profundidad de BOLA
    (multi-tenant); cuidado con el pooling y con roles que evaden RLS.
  - **Mass assignment / over-posting:** exigir whitelist de campos escribibles; campos
    sensibles (rol, tenant, permisos) nunca asignables desde el body.
  - **Fuerza bruta y abuso de credenciales** (límites por IP y por cuenta, backoff/CAPTCHA,
    mensajes genéricos, MFA) y **Agotamiento de recursos / DoS** (límites de body/JSON,
    paginación con tope, descompresión, ReDoS, timeouts), desdoblando el antiguo
    "Resiliencia y abuso".

## [1.6.0] — 2026-06-20
### Añadido
- **Enforcement por runtime (hooks `PreToolUse` del plugin)** — bajan a mecanismo lo que antes
  era prosa en `AGENTS.md`:
  - `hooks/guard-codigo.sh` (**A1**): deniega editar el código de la app (`codigo_app.globs`)
    a quien no sea el agente `desarrollador`. Distingue coordinadora vs. subagente por el
    campo `agent_id` del input del hook.
  - `hooks/guard-completado.sh` (**A2/A3**): deniega marcar un REQ como `completado` si hay
    aprobaciones pendientes en `PENDING_APPROVAL.md` o si alguna quality gate falla.
  - `hooks/hooks.json` + `hooks/lib.sh`; el plugin auto-descubre `hooks/hooks.json`.
- **Manifiesto machine-readable** `templates/arnes-config.json.tpl` → `.arnes/config.json`:
  fuente de verdad ejecutable (agente de código, globs de app, quality gates, estados).
- `arnes-init`: emite y rellena `.arnes/config.json`; entrevista por los globs de app.
- `AGENTS.md.tpl`: nueva §13 "Enforcement por runtime" y notas 🔒 en §5/§6/§7.
- Escenario de regresión `tests/escenarios/hooks/run.sh` (prueba los hooks en aislamiento).

### Notas
- Los hooks son **inertes** sin `.arnes/config.json` (no estorban en repos ajenos al arnés) y
  requieren `jq`; sin él, el enforcement queda inactivo con aviso por stderr (no bloquea).
- El gate de aprobación se enforce como `PreToolUse` deny (no como `Stop` hook): un `Stop`
  con `block` haría *continuar* al modelo, no detenerlo para el humano.

## [1.5.0] — 2026-06-04
### Añadido
- `auditor-seguridad`: nuevas categorías en el checklist de auditoría:
  - **Ataques web a LLM** (inyección de prompts directa/indirecta, manejo inseguro de la salida, agencia excesiva, fuga de system prompt), alineado con OWASP Top 10 for LLM Applications.
  - **CSRF** (token anti-CSRF y/o SameSite en endpoints que cambian estado).
  - **Subida de archivos** (validación por magic bytes, límites, nombres saneados, almacenamiento fuera del webroot sin ejecución).
  - **XXE** (parsers con entidades externas y DTD deshabilitadas).
  - **Web cache deception** (rutas con datos sensibles no cacheables).
  - **CVE y versiones** (vulnerabilidades cruzadas contra la NVD del NIST, con CVE y versión corregida; versiones ancladas).

## [1.4.1] — 2026-06-01
- `qa-tester`: la escalada por límite de reintentos nombra el mecanismo explícito — `bloqueado` + registro en `docs/ESTADO.md` + escalada al humano vía `PENDING_APPROVAL.md` con parada del pipeline.

## [1.4.0] — 2026-06-01
### Añadido
- Política explícita de **cambios de requerimientos** (versionado y deriva) en `templates/AGENTS.md.tpl`.
- Bloque **Historial de cambios** en la plantilla de REQ (`templates/requirements-README.md.tpl`).
- `analista-requerimientos`: versiona el REQ, registra causa y enlaza ADR ante cambios/deriva.
- `qa-tester`: reporta deriva y devuelve el REQ en vez de aprobar contra uno desactualizado.
- ADR del plugin: `docs/decisions/ADR-001-politica-cambio-requerimientos.md`.

## [1.3.3] — 2026-06-01
- La sesión coordinadora delega los cambios de código en el `desarrollador` (sobre todo al depurar). `memory/` ignorado.

## [1.3.2] — 2026-06-01
- Robustez ante entradas no normalizadas (dev) + QA prueba variantes (capitalización/espacios/ausente/inválido).

## [1.3.1] — 2026-06-01
- QA verifica integridad de dependencias (lockfile sincronizado y deps coherentes).

## [1.3.0] — 2026-06-01
- Nueva skill `/arnes-panel` (panel HTML interactivo de estado, solo lectura).

## [1.2.0] — 2026-06-01
- Robustez (try/catch) en dev; defensa anti-inyección/abuso en auditor; NFR de rendimiento en QA. README sin referencias externas.

## [1.1.0] — 2026-06-01
- Estructura inicial: 4 agentes, skills `/arnes-init` y `/arnes-close`, plantillas, hook pre-commit y tests.
