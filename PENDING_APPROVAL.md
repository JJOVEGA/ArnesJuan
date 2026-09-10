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

### D2 · Los 20 hallazgos bloqueantes de siete REQ — resolver, declarar residual o aceptar

Tu regla del 2026-09-08 dice que **cualquiera devuelve el tag a ti**. Inventario medido el 2026-09-09:

| REQ | Ventana | Bloqueantes | Nota |
|---|---|---|---|
| `REQ-020` | 1.34.0 | **8** — `SEC-038`…`SEC-045` | el bulto |
| `REQ-007` | 1.31.0 | 3 — `QA-114`, `QA-116`, `QA-117` | deuda de ventana ya publicada |
| `REQ-026` | 1.34.0 | 3 — `SEC-067`, `SEC-072`, `SEC-073` | ver **D3** |
| `REQ-013` | 1.32.0 | 2 — `SEC-014`, `SEC-020` | deuda de ventana ya publicada |
| `REQ-021` | 1.34.0 | 2 — `QA-021-10`, `QA-021-11` | **3 vueltas agotadas, salida sin decidir** |
| `REQ-019` | 1.35.0 | 1 — `SEC-033` | aplazado; su salida tampoco está decidida |
| `REQ-023` | 1.34.0 | 1 — **`SEC-079`** (`contrato`) | ver **D5**. Tercer relevo del bloqueante: `QA-023-05` (`contrato`) y `QA-023-15` (`usuario/dinero`) están **cerrados**; el que bloquea ahora lo abrió la auditoría `R-024` |

Casi la mitad es **deuda de 1.31.0 y 1.32.0**, no trabajo de esta ventana. Esto no es trabajo
pendiente: es una decisión. Por cada uno hace falta **resolver**, **declarar residual** (dueño,
forzador medido y vencimiento) o **aceptar explícitamente**.

### D3 · `SEC-072` y `SEC-073` de `REQ-026` — **no se cierran por redacción ni por aceptación implícita**

Los dos son `contrato` y el informe de seguridad (`R-022`) los describe como «de redacción/legibilidad,
**no de código**». Esa descripción hace tentador cerrarlos reescribiendo un párrafo, y **por
instrucción expresa del propietario (2026-09-09) eso no se hace**: no se cierran por redacción ni por
aceptación implícita. Quedan a la espera de **tu firma** sobre qué son y qué se hace con ellos.
`SEC-067` (`usuario/dinero`) está `en-mitigación` con el código acreditado y **le falta el
write-back**; ése sí es trabajo, no decisión, y no lo mezclo aquí.

### D4 · Ventana **propuesta** 1.35.0 para la superlinealidad heredada

El write-back de `CA-09 (iii)` retiró del alcance de `REQ-023` la superlinealidad del camino
**heredado** de `arnes_norm_clave`/`arnes_campo_linea` —medida: la base `v1.33.0` paga mediana **2,492**
y **2,446** contra **2,295** y **2,237** de la candidata, así que **la guarda diluye el cociente en vez
de empeorarlo**— y le dio casa propia en «Fuera de alcance» como `instrumento`, con dueños y forzador.
El analista **propone** 1.35.0 y **no la fija**: las ventanas las decides tú. El arreglo está
**descrito y no aplicado** en `docs/qa/1.34.0-req023-vuelta3-metodo.md` §11.6, y es alcance nuevo sobre
código que `REQ-023` no introdujo.





### D6 · **CORREGIDA: mi diagnóstico de `k=1` era FALSO en su mecanismo, y el remedio es otro** — decidida bajo delegación

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

## Resueltas

### D5 · `SEC-079` — **RESUELTA el 2026-09-09: opción (a), y con un matiz del propietario que cambia el arreglo**

**Autorizado:** corregir `CA-10` y las dos filas heredadas para que **describan la cobertura real**,
manteniendo **fuera de esta ventana** la vía del homóglifo ya declarada.

**El matiz, que es lo que hace este arreglo distinto de un parche cosmético — literal del propietario:**
> «*La redacción debe nombrar explícitamente esa limitación y enlazar su evidencia en el registro.
> Añadir solamente «no exhaustiva» no basta si la promesa principal sigue siendo absoluta.*»

Es decir: **no se resuelve colgando una coletilla a una promesa absoluta.** La promesa **principal**
tiene que dejar de ser absoluta, la limitación tiene que estar **nombrada**, y su evidencia
**enlazada** al registro (`docs/seguridad/registro-seguridad.md`, `SEC-078`/`SEC-079`, revisión `R-024`).

**Condiciones que el propietario fija:**
- **`SEC-078` y `SEC-080` siguen abiertos**, con sus responsables. No los cierra esta autorización.
- **Esta autorización NO acepta riesgos nuevos y NO acredita el criterio de rendimiento** — `CA-09 (iii)`
  sigue **sin acreditar**, y eso no cambia aquí.
- **Cadena obligatoria:** `analista-requerimientos` → `desarrollador` → `qa-tester` → `auditor-seguridad`,
  con **revisión acotada al cambio** y **reutilizando la evidencia que siga siendo válida**.
- **`SEC-079` se cierra ÚNICAMENTE tras esa validación** — no al escribir el texto.
- **Coordinación con `REQ-024`:** las **pruebas de `CA-10` deben comprobar la redacción corregida**, así
  que ese tramo se entrega **en secuencia** y no antes de que el texto exista.
- **No se vuelve a pedir esta autorización.** Sólo se solicita otra decisión si aparece un **cambio
  material fuera de este alcance**.


### D1 · `REQ-023` — **RESUELTA el 2026-09-09: `Estado: bloqueado`, con extensión excepcional de alcance cerrado**

**Decisión del propietario, literal en lo que autoriza y en lo que no:** acepta dejar `REQ-023`
**bloqueado mientras se corrige**, y autoriza una **extensión excepcional limitada** a tres cosas:
completar **`CA-10`**, corregir la prueba de **`CA-09 (iii)`** *conforme al contrato vigente*, y
consolidar el write-back pendiente en un commit coherente. **Manda conservar el registro de las tres
vueltas agotadas.** Después: **QA revalida lo afectado**, se ejecuta el **CI requerido**, y **seguridad
revisa cuando corresponda**.

**Lo que NO autoriza, y queda escrito porque es lo que una prisa convertiría en atajo:**
1. **Cerrar con `QA-023-15` abierto.**
2. **Eliminar pruebas.**
3. **Relajar umbrales para obtener verde.**

Si aparece otro bloqueo, se entrega **la evidencia y la decisión concreta necesaria** — no una consulta
abierta.

**Sobre qué se decidió:** la recomendación de `qa-tester` en la vuelta 3 de 3, apoyada en tres motivos
que convergen — `QA-023-15` es `usuario/dinero` y §6 **no admite residual** sobre esa clase; la puerta
requerida y estricta de `main` está **roja** por `CA-09 (iii)` en el CI del PR #45 (**2,365× > 2,200×**,
dispersión **0,023×** contra margen **0,165×**: resolvió con holgura, **no fue ruido**); y el cierre de
`QA-023-05` colgaba de un write-back sin comitear, ya consolidado en `86389ac`.

**Registrado en** `requirements/REQ-023.md`: campo `Estado:` con la decisión y el alcance de la
extensión, y fila de Historial con las tres vueltas nombradas una por una. La extensión **no reabre ni
reinicia** el contador de vueltas.


### APLAZADA CON SU REQ (propietario, 2026-09-09) — `REQ-019 CA-07`: el techo viaja a 1.35.0 con su evidencia

**Sale de la cola porque el REQ salió de la ventana**, no porque se haya decidido. El propietario:
*«Decido aplazar `REQ-019` a 1.35.0 para reevaluarlo. Conservá lo trabajado; no lo marques completado
ni inviertas más en su reparto ahora.»*

**Por qué se mueve y no se deja viva:** una entrada en «Pendientes» hace que `guard-completado`
deniegue el cierre de **cualquier** REQ, y `REQ-023`, `REQ-024` y `REQ-027` van hacia el cierre en esta
ventana. Dejarla aquí bloquearía tres trabajos por una decisión que ya no pertenece a esta ventana.
**La pregunta no se resuelve: se traslada**, y toda su evidencia queda escrita abajo y en
`docs/arnes/req-019-techo-propuesto.md`. `SEC-033` (`contrato`) sigue abierto en `REQ-019`.

### [2026-09-08] (coordinadora) — [TRASLADADA A 1.35.0] `REQ-019 CA-07`: el techo `0,72×` es INSATISFACIBLE en bytes

**Contexto.** Firmaste `0,72×` sobre una medición hecha en **líneas**. F1 lo midió ahora en **bytes**
—la magnitud que de verdad se paga en cada comisión— y el suelo forzado no cabe:

| | base | techo `0,72×` | suelo medido | razón | exceso |
|---|---:|---:|---:|---:|---:|
| `AGENTS.md` | 33.827 | ≤ 24.355 | 27.730 | **0,820×** | +3.375 B |
| `requirements/README.md` | 40.767 | ≤ 29.352 | 32.682 | **0,802×** | +3.330 B |
| **total** | **74.594** | **≤ 53.707** | **60.412** | **0,810×** | **+6.705 B** |

El suelo es **cota inferior**: no cuenta los punteros que `CA-03` obliga a añadir (≈700 B + ≈400 B)
ni los resúmenes de `CA-10`. La derivación va término a término por sección en
`requirements/REQ-019.md` §«El suelo forzado MEDIDO EN BYTES», así que se puede auditar sin
re-medirla. El veredicto descansa en la tabla de §13, el `## Índice` del README y los contratos de
forma: suelo al 100 % en cualquier lectura.

**Y la línea base cambió en contra.** El README pasó de 31.192 B (commit `d266e8f`) a 40.767 B,
**+9.575 B**, y **7.570 de ellos (79 %) cayeron en suelo** — el contrato de forma del campo
`Archivos:` (+5.406 B, `CA-02.4.3`) y el `## Índice` (+2.164 B, fuera de alcance) — contra un techo
que sólo subió 6.894 B. Crecer no dio holgura: la quitó.

**Opciones.**
- **A — Re-firmar el techo** en ≥ **0,82×** (`AGENTS.md`), ≥ **0,81×** (README), ≥ **0,82×** total
  contando punteros. Es el precedente exacto de esta misma ventana: el `0,60×` original ya se
  re-firmó a `0,72×` cuando se midió su suelo.
- **B — Ampliar el alcance** para bajar el suelo: sacar de `AGENTS.md` lo que la predicción del
  propio REQ dice que **se queda** (§2, §3, §4, §12 y «qué es crítico» = 4.325 B). Deja
  `AGENTS.md` en 0,692×, con un margen de 1.010 B **que los punteros se comen**, y **el README no
  tiene equivalente**: no resuelve el total.
- **C — Cerrar `REQ-019` sin el ahorro contratado**, declarando el residual con dueño y vencimiento.

**Recomendación de la coordinadora: A.** Es la única que no relaja `CA-02`/`CA-14` ni traslada el
ahorro entre documentos, y el número sale de una medición reproducible. **No la aplico yo**: el techo
lo firmaste tú, y ajustarlo dentro de la comisión que lo incumple es justo lo que este proyecto
prohíbe por escrito.

**DIRECCIÓN DADA POR EL PROPIETARIO (2026-09-09), literal:** *«Para `REQ-019`, prefiero mantener el
alcance y ajustar el objetivo, pero antes presentá una propuesta concreta de techo que incluya los
punteros obligatorios. Usá el inventario existente para preparar el reparto y calcular su tamaño; no
abras otra investigación extensa. Expresá el resultado como **reducción de bytes de lectura
obligatoria**, no como ahorro real de tokens.»*

Es decir: **opción A**, con el alcance intacto —nada de la vía B, que exigía sacar de `AGENTS.md`
bloques que la predicción del propio REQ dice que se quedan—, y con el número **por presentar**, no
por firmar todavía. El techo propuesto tiene que incluir el coste de los punteros de `CA-03`, que la
medición de F1 dejó fuera declarándose **cota inferior**.

**Advertencia que debe ir con el encargo, porque «el inventario existente» no está donde parece:** las
dos enumeraciones de F1 (**106** y **164** elementos) se entregaron **por informe** y **no
sobreviven en disco** — sólo quedan sus discrepancias en `docs/PENDIENTES.md`. Lo que **sí** hay es la
tabla **por sección** de §«El suelo forzado MEDIDO EN BYTES», con `base` / `delegable` / `suelo` de
cada sección de los dos documentos, y ésa **sí** permite dimensionar el reparto sin re-enumerar. Se
usa ésa. **No se abre una enumeración nueva.**

#### LA PROPUESTA, YA CALCULADA (2026-09-09) — `docs/arnes/req-019-techo-propuesto.md`

Versión base leída: commit **`d6620ea`**, con `git show`, nunca el árbol vivo. Método dentro del
archivo, con un anexo de los **38 bloques delegados** (sección, bytes, gobierno/narrativo, nombre) y
la regla «todo bloque que no aparezca aquí es suelo», para que la clasificación sea reproducible sin
re-medirla.

| | base **(medido, `wc -c`)** | suelo | punteros | resultante **(PROYECCIÓN)** | **techo propuesto** |
|---|---:|---:|---:|---:|:---:|
| `AGENTS.md` | 33.827 | 27.730 | 3.497 | 31.227 | **≤ 0,93×** |
| `requirements/README.md` | 40.767 | 32.682 | 3.497 | 36.179 | **≤ 0,89×** |
| **total** | **74.594** | **60.412** | **6.994** | **67.406** | **≤ 0,91×** |

> **Qué está medido y qué es proyección, porque no es lo mismo y la columna no lo decía.** *Medido con
> `wc -c`:* las dos **bases**, y los **tres punteros reales** escritos para este cálculo (269 / 243 /
> 161 B, `docs/arnes/req-019-techo-propuesto.md:57-65`), de los que se usa el **peor caso**. *Derivado:*
> el **suelo**, que es la clasificación por sección de los bytes del documento actual —bytes medidos,
> con **juicio** encima sobre qué se queda—. **PROYECCIÓN:** las columnas `resultante` y `techo`.
> **31.227 y 36.179 son suma aritmética de suelo + punteros, NO `wc -c` sobre archivos candidatos**:
> esos archivos **no existen**, porque no se ha repartido nada. El número real sólo se puede medir
> **después** del reparto, y `CA-07` obliga a medirlo entonces.
>
> **El reparto de los 26 punteros es 13 + 13, y NO es una división por la mitad** — sale igual por
> coincidencia, con el grano de `CA-12` (una pregunta por bloque de gobierno, una por sección
> narrativa):
>
> | | bloques delegados | gobierno | narrativos | secciones que los agrupan | punteros |
> |---|---:|---:|---:|---:|---:|
> | `AGENTS.md` | 18 | 6 | 12 | **7** | 6+7 = **13** |
> | `requirements/README.md` | 20 | 9 | 11 | **4** | 9+4 = **13** |
>
> De ahí que los bytes coincidan (13 × 269 = 3.497 cada uno). Si el total se hubiera partido por dos
> sería un artefacto del cálculo; aquí es que los **conteos** coinciden.

**Reducción de bytes de lectura obligatoria: de 74.594 B a 67.406 B = −7.188 B por comisión
(−9,6 %)** — −2.600 B en `AGENTS.md`, −4.588 B en el README. **No se traduce a tokens ni se llama
ahorro de tokens.** En el extremo optimista (grano `CA-03`, puntero corto): 62.183 B, `≤ 0,84×`,
−12.411 B; la horquilla completa está en el archivo.

**Por qué `0,91×` y no el `≈0,82×` estimado en F1, que es lo que hay que decidir:** los **punteros de
`CA-03` se comen el 49 %** de lo que se libera —6.994 B añadidos contra 14.182 B delegados—, y en
`AGENTS.md` el **57 %**, porque su texto delegable está repartido en **siete** secciones y cada una
paga los suyos. La estimación previa contaba **11** punteros de ~150 B; el grano que manda es el de
**`CA-12`** —una pregunta por bloque que enuncia o acota gobierno, una por sección narrativa— que da
**26**, y el tamaño sale de **tres punteros reales escritos y medidos** (269 / 243 / 161 B), usando el
**peor caso**. `CA-10` no reserva nada: ningún resumen es obligatorio.

**UN DATO DE RENTABILIDAD QUE NO PIDE CAMBIAR EL ALCANCE, PERO QUE CONVIENE VER ANTES DE FIRMAR.** El
`## Índice` del README pesa **7.867 B**, está **fuera de alcance** y tiene **otro dueño**. Convertirlo
en bloque derivado **no reparte nada y no añade un solo puntero**, y retira **más** bytes de lectura
obligatoria (7.867 B) que el reparto completo de los dos documentos en el peor caso (**7.188 B**), que
cuesta **7–11 h** y mueve **38 bloques, 15 de ellos de gobierno**. Lo registra el propio desarrollador
y **no propone cambiar el alcance**, porque ya decidiste mantenerlo. Queda aquí como información para
tu firma, no como recomendación.

**Espera.** Tu firma sobre `≤ 0,93×` / `≤ 0,89×` / `≤ 0,91×`, por documento — o el número que
prefieras por encima del suelo medido. `REQ-019` sigue en `Estado: bloqueado` y **F2 no se despacha**
hasta entonces.

**Y una precondición que la firma no resuelve:** `CA-15` exige el **inventario por bloques** —«una fila
por elemento», anexado a `ADR-003`, sitio único, cardinalidad cuadrada, ejecutores de `CA-17`, doble
enumeración independiente— y **la tabla por sección NO lo sustituye**: agrega por sección, y una
invariante se pierde por **bloque**. Las dos enumeraciones de F1 (106 y 164) **no sobreviven en
disco**, así que ese inventario hay que rehacerlo antes de F2, con firma o sin ella.


### [2026-09-09] (auditor `R-022` · enrutado por la coordinadora) — `SEC-073`: `REQ-026` lleva CUATRO criterios contratados y sin implementar. ¿Cuál de las tres salidas?

**Contexto: el agujero que pediste comprobar existía, y ya está tapado por máquina.** La puerta lee el
**valor** `aprobado`; el alcance parcial vivía en el paréntesis, que `AGENTS.md` §13 define como
**matiz** —«un veredicto distinto es otro valor, no un paréntesis»—, y `Hallazgos abiertos:` **no
nombraba** los cuatro criterios. Con `SEC-067` en camino de cerrar y la cola vacía, nada legible por la
máquina habría impedido marcar `REQ-026` como `completado` con cuatro criterios sin implementar. Es
literalmente la **anti-deriva** que §13 declara que la máquina no puede verificar sola.

El auditor eligió la vía **(a)**: `SEC-073`, clase **`contrato`**, en `Hallazgos abiertos:`. **Ahora
bloquea por máquina y no por memoria.** Ninguna evidencia se retiró: lo acreditado por QA y por la
auditoría sigue en pie; lo que faltaba era que el alcance parcial fuera **visible para la puerta**.

**Los cuatro criterios sin implementar, y qué es cada uno:**
- **`CA-13`** — declarar `rotacion.artefactos` en el manifiesto. **Es encender la rotación**, y no lo
  autorizaste: le falta trabajo, no permiso.
- **`CA-14`** — la magnitud contratada es la **lectura real**, no el tamaño de la sección.
- **`CA-16`** — que ninguna decisión vigente quede sólo en el archivo.
- **`CA-17`** — qué REQ son candidatos, por sus dos condiciones y su break-even.

**Las tres salidas, y sólo una es mía.**
- **A — Implementarlos en esta ventana.** Son cuatro criterios; `CA-13` además necesita `SEC-072`
  cerrado antes (el auditor lo condiciona), y `CA-17` lleva un cálculo de break-even con cuatro costes.
  **Amplía el trabajo 3** de «el mecanismo» a «el mecanismo encendido y calibrado».
- **B — Reducir el alcance de `REQ-026` a lo entregado** (`CA-01`–`CA-12`, `CA-15`, `CA-18`) y llevar
  `CA-13`/`CA-14`/`CA-16`/`CA-17` a un REQ propio de 1.35.0. El mecanismo queda **probado y apagado**,
  que es exactamente su estado hoy. **Decisión de alcance: tuya.**
- **C — Cerrar con los cuatro declarados como residual**, con dueño, forzador medido y vencimiento.

**Recomendación de la coordinadora: B.** Motivo concreto, no de calendario: el mecanismo entregado
**está validado y no está encendido**, así que cerrar el REQ por lo entregado no deja nada a medias en
runtime; y `CA-13` —encenderlo— tiene por delante `SEC-072`, la publicación a medias, el poder
estadístico del 27–49 % de `(iv)` y la dimensión de `REQ-022` que el analista mandó a su sede. Meter
todo eso en esta ventana es el patrón que `docs/PLAN.md` culpa del descontrol del ciclo 3.

**Espera.** Tu elección entre A, B y C. **Nada más de la ventana depende de esto**: `REQ-023` y
`REQ-024` siguen su curso, y `REQ-019` espera su propia firma.

### [2026-09-09] (analista vía `ADR-008` · enrutado por la coordinadora) — `REQ-026`: la única decisión que hoy tiene sentido, y NO es firmar una excepción

**El ADR está escrito y su recomendación es que hoy no firmes ninguna garantía nueva.**
`docs/decisions/ADR-008-garantia-de-la-rotacion-de-seccion-frente-a-escrituras-concurrentes.md`,
`Estado: propuesta`, enlazado desde `CA-18 (i)`, `CA-05` y el Historial.

**Por qué la decisión se parte en dos: los dos residuos NO son la misma pregunta.**

| Residuo | Tiene arreglo por mecanismo | Qué se pierde |
|---|---|---|
| **Interrupción** — `mv` del destino bien, recorte falla ⇒ la parada siguiente re-archiva | **Sí**: idempotencia del re-archivado | 2 bloques, 3 filas **duplicadas**, `rc=0`, sin aviso |
| **Ventana de publicar** — escritura ajena entre la relectura y el fin | **No en este sustrato** | La escritura ajena **se pierde**, y si era una fila de historia, **la fila se pierde** |

Meter los dos en una sola firma **convertiría un problema con solución en una excepción
permanente**.

**Lo que se evaluó y salió NO, con su evidencia:** se preguntó si `3+5` —sacar la rotación del hook de
parada más idempotencia— cumple las dos promesas sin excepción. **No.** La `5` cierra la interrupción;
la `3` **no** cierra la ventana de publicar **por mecanismo** —el intervalo sigue ahí; el sustrato no
cambia porque cambie quién invoca—, sólo bajo la precondición «nadie más está editando», que **el arnés
no puede medir** y que **hoy es falsa por observación directa: dos `desarrollador` escribiendo a la vez
en este árbol**. La única vía B que cumple las dos por mecanismo es **no rotar `requirements/`**,
eliminando el caso.

**LA DECISIÓN QUE TE TOCA, y es una sola:** ¿se autoriza el trabajo de la **vía B sobre `CA-05`** en
esta ventana — contratar y verificar la **idempotencia del re-archivado**?

- **Sí** → `CA-05` vuelve a ser **absoluto por mecanismo**, sin excepción que aprobar. Cuesta un
  criterio nuevo (analista) más su implementación y caso determinista (dev), y **necesita tu permiso
  porque dijiste «no agregues más criterios por ahora»**. Dueño y vencimiento ya están escritos:
  `desarrollador`, antes de que se declare `CA-13`.
- **No / más tarde** → `CA-05` sigue con su promesa absoluta **incumplida** y `SEC-072` sigue abierto.
  No se rompe nada hoy: **la rotación está apagada.**

**`CA-18 (i)` no necesita nada tuyo hoy, y eso es deliberado.** Su vía A exige aceptar un riesgo cuya
magnitud **nadie ha medido**, así que medir el intervalo residual pasa a ser **precondición**, no
alternativa. Y esa medición **hoy no está disponible**: el instrumento de reloj se declaró **no
convergente** (el brazo de control se movió un 34 %) y depende de `REQ-021`, que está `bloqueado`. La
decisión queda **abierta y escrita**, no resuelta por silencio.

**Cuando ese número exista, la elección real será entre dos opuestos:** aceptar el residuo declarado, o
**renunciar a rotar `requirements/`** —los 409.699 B—. Hoy se decidiría sin el único dato que las
distingue.

**Variante examinada y no propuesta, para que no parezca inexplorada:** la «puerta posterior» de
`AGENTS.md` §13 **detectaría** la pérdida, no la evitaría, y el arnés no la tiene.

**Espera.** Tu sí/no al trabajo de la vía B sobre `CA-05`. Nada más de la ventana depende de esto.


### RESUELTA (propietario, 2026-09-09) — `REQ-027` entra en 1.34.0 como **quinto trabajo**, detrás de `REQ-019`

**Lo autorizado, literal:** *«Autorizo incorporar `REQ-027` como quinto trabajo de 1.34.0. Ejecutá su
implementación después de `REQ-019`, sobre la estructura resultante. Incluí plantilla, instalación y
migración de proyectos existentes, con sus verificaciones. Actualizá el plan y el estado para reflejar
esta decisión.»*

**Consecuencias registradas:**
- La ventana pasa de **cuatro** trabajos a **cinco**. `docs/PLAN.md` y `docs/ESTADO.md` actualizados.
- **Orden fijado: `REQ-027` va DESPUÉS de `REQ-019`, sobre la estructura resultante.** Resuelve la
  competencia por `AGENTS.md` que motivaba la pregunta: `REQ-019` mueve el texto de sitio y `REQ-027`
  inserta su bloque **en el resultado**, no en el original. Escribirlo antes habría significado
  escribir el bloque y luego moverlo.
- **`requirements/REQ-027.md:7` (`Versión destino: 1.34.0`) queda ratificado** — era una afirmación del
  analista y ahora es decisión del propietario. No hay que corregirlo.
- Alcance de la implementación, confirmado: **plantilla + instalación (`arnes-init`) + migración de
  proyectos existentes (`arnes-upgrade`), con sus verificaciones**. Es lo que ya contrata `CA-09` y
  `CA-10`, este último como **condición de entrega**, no como pendiente.
- **Dependencia que sigue viva y no la resuelve esta firma:** `REQ-019` está `bloqueado` esperando el
  techo, así que `REQ-027` hereda ese bloqueo por transitividad.


### RESUELTA (propietario, 2026-09-09) — `REQ-026`: se autoriza **sólo** `_doc_artefactos`, sin activar la rotación

**Lo autorizado, literal:** *«Autorizo la decisión 2 exclusivamente para actualizar `_doc_artefactos`
en los dos archivos indicados, sin activar la rotación.»*

**Alcance exacto, para que nadie lo estire:** editar el texto de `_doc_artefactos` en
`.arnes/config.json:48` y en `templates/arnes-config.json.tpl:53`, que sigue describiendo el
mecanismo **viejo** —que una entrada es sólo `- `, `* `, `### ` o `N. `— cuando el código ya reconoce
filas de tabla. **Fuera de esta autorización:** `rotacion.activo`, `rotacion.artefactos` y cualquier
otra clave. La rotación **sigue apagada**.

**Efecto:** cierra `QA-026-04` (`contrato`, reclasificado en `R-021`) y retira el vencimiento que
expiraba antes del tag `v1.34.0`. **No enciende nada.**

**`CA-13` (la opción B) NO queda autorizada, y no hacía falta decidirla:** le falta trabajo, no
permiso — `CA-18` implementado, su par discriminante en una parte 4 del banco, y la dimensión de
`REQ-022` (que `tools/arnes-paralelo.sh` no conoce a los escritores **no-comisión**) resuelta o
declarada como residual con dueño. Con `SEC-067` abierto, encenderla pondría al hook de parada a
reescribir contratos sin red: medido 3/3, un `Seguridad: aprobado` escrito durante la rotación
**volvió a `pendiente`**, con `rc=0` y stderr vacío.

### RESUELTA (propietario, 2026-09-08) — **se PUBLICA `v1.33.0`**: revierte el aplazamiento de ayer, con límite declarado

**Decisión posterior y explícita del propietario**, tomada con un dato que la primera no tenía: la puerta
requerida `hooks-en-linux` está **en verde sobre el commit exacto** (`7dc0699`: 875 PASS · 0 FAIL · 9
SKIP), así que **no hacía falta saltarse nada** — la opción B (autorización para publicar en rojo) quedó
sin objeto.

**Fusionado con `jvega-habitat`, que NO tiene admin, deliberadamente.** La cuenta `JJOVEGA` estaba
autorizada por el propietario y disponible (`admin=true`, verificado), y **no se usó**: fusionar con la
cuenta sin privilegios demuestra **por construcción** que el control se satisfizo de verdad. Merge
`810128a`; tag `v1.33.0` sobre él.

**El límite bajo el que se publicó, que es la parte que importa.** La evidencia de rendimiento es el
`0,125×` acreditado de `REQ-017 CA-05` (9,60 s frente a 76,19 s, 2026-09-07), **NO** el verde de
`CA-08 (ii)`. Ese caso mide **0,973×–1,364× sobre código idéntico** contra un techo de 1,25×: su verde y
su rojo son igual de poco informativos. **No se fusionó porque el semáforo se pusiera verde** —eso habría
sido elegir la corrida que conviene, el atajo que esta misma entrada nombró y descartó— sino porque la
sustancia está acreditada por otra vía y el banco entero pasa.

**Lo que NO se revierte:** arreglar la sonda sigue siendo el **primer trabajo de 1.34.0**, por delante de
`REQ-019`. Detalle y las tres formas conformes, en `docs/PENDIENTES.md`.

### RESUELTA (propietario, 2026-09-08) — **se APLAZA el tag `v1.33.0`; la sonda se arregla en 1.34.0 por DELANTE de `REQ-019`**

Opción **C** elegida. Descartadas: **(A)** arreglar la sonda ahora dentro de esta ventana —ciclo completo, ~4 comisiones— y **(B)** publicar con el rojo bajo autorización expresa. **No se ejerció (D)**: relanzar el CI hasta obtener un verde y fusionar en esa corrida, que con una sonda cuya dispersión cubre el techo no es esperar a que pase, sino elegir la corrida que da la respuesta que se quiere.

**El argumento del propietario, en una línea:** mientras el techo viva dentro del ruido, **el verde de esa puerta no acredita nada más que el rojo** — así que publicar hoy no compraría confianza, compraría una firma vacía. Registrado en `docs/PLAN.md` como enmienda al alcance de 1.34.0.

**Estado al resolver:** `cand/1.33.0` @ `651806c`, empujada, árbol limpio. PR **#43** en `DRAFT`, sin fusionar. `REQ-014` `completado` con los tres veredictos fechados el 2026-09-08 y **cero hallazgos `contrato`**. Bloqueantes `contrato` en el repositorio: **12**, ninguno en `REQ-014`.

### La puerta requerida de `main` está ROJA, y su rojo no es evidencia — decisión del propietario (2026-09-08)

**Qué detiene.** La fusión de `cand/1.33.0` a `main` y el tag `v1.33.0`. `REQ-014` está `completado`
con los tres veredictos fechados hoy y **cero hallazgos `contrato`**; la cola estaba en 0 antes de esta
entrada. Lo único que queda en rojo es el check requerido y estricto `hooks-en-linux`.

**El caso que falla.** `REQ-017 CA-08 (ii) una cabecera de 200 líneas: el reloj no sube más de 1,25× el
de v1.32.1`. Su salida dice literalmente *«esto es una regresión, no ruido»*.

**Y está medido que no lo es.** Cuatro corridas de CI **sobre código idéntico** —ningún commit desde
`b9afa01` toca `hooks/`, `tools/` ni `.github/`, verificado de forma independiente por el
`auditor-seguridad` en `R-019`:

| Corrida | Razón publicada | Convergencia | Veredicto |
|---|---:|---|---|
| 23:39 (`921dc74`) | **1,131×** | 1,012× / 1,142× | PASS |
| 23:53 (`516e849`) | **0,973×** | 1,185× / 1,138× | PASS |
| 00:00 (`d4e0033`) | **1,337×** | 1,025× / 1,232× | FAIL |
| 00:24 (`eff143b`) | **1,364×** | 1,002× / 1,249× | FAIL |

**El argumento que cierra la discusión: `0,973×` significa que este árbol salió MÁS RÁPIDO que
`v1.32.1`.** Una regresión real no puede ser más rápida. La dispersión de la sonda va de 0,97 a 1,36
—factor **1,40**— y el techo que vigila es **1,25**: **el techo vive dentro del ruido del instrumento**,
así que el caso no puede distinguir la regresión que dice medir de su propia varianza.

**CORRECCIÓN (coordinadora, 2026-09-08): el defecto NO es «el umbral está mal puesto».** Una primera
lectura concluyó eso; **es falso**. El umbral de convergencia y el techo son el mismo número **a
propósito**, y `REQ-017 CA-08` lo argumenta: *«no es un número nuevo: es el mismo, porque un instrumento
tiene que resolver al menos el factor que vigila»*. **El caso hace exactamente lo que su criterio
prescribe**, y su hermano también.

**Lo que las cuatro corridas muestran es peor:** `CA-08` ya había pagado esta lección —documenta el
recorrido 0,821–1,010 en aislamiento y la subida sistemática bajo `JOBS=6`— y prescribió **intercalar las
series** más la comprobación de convergencia. **Está todo implementado, y no basta.**

**El hueco:** la convergencia compara el segundo mínimo de **cada árbol** con su propio mínimo —mide si
cada **serie** se asentó—, mientras que el ruido de la **razón** viene de las condiciones **entre
brazos**. Dos series pueden converger cada una a 1,2× y su cociente oscilar 1,4×. Los datos lo enseñan:
**los dos rojos son justo aquellos en que un brazo converge al borde** (1,232× y 1,249× contra el límite
de 1,250×) mientras el otro converge holgado (1,025× y 1,002×); los dos verdes están equilibrados. A
1,249× el instrumento resuelve **exactamente** 1,25 y ni un poco mejor, y sobre esa resolución afirma un
1,364×.

**La clase:** `CA-08` dice «**al menos** el factor que vigila» y eligió el valor **más flojo** compatible
con ese argumento **sin medir si alcanzaba**. Es *un criterio derivado sin comprobar su factibilidad*, la
misma clase que ya se corrigió dos veces en esta ventana.

**Clase: `instrumento`** —es un defecto de una prueba del propio arnés, no del producto—, pero **bloquea
igual**, porque el ruleset `proteger-main` hace ese check **requerido y estricto**. Es el primer caso de
la ventana en que un `instrumento` detiene una publicación, y por eso no va a `docs/PENDIENTES.md` bajo
la regla de acumulación: la regla dice que un `instrumento` no impide **cerrar un REQ**, y aquí no está
impidiendo eso.

### Las opciones, con su coste, y la que NO se hace

**A) Arreglar la sonda.** Que la convergencia se exija **estrictamente más apretada** que el techo que
protege, o que el caso haga **SKIP con motivo** cuando su propia dispersión supere ese techo — que es
exactamente lo que ya hace su caso hermano. Es cambio en `tests/`, o sea `critico` por `AGENTS.md` §6:
ciclo completo analista → desarrollador → QA → auditor. **Estimado: 4 comisiones, ~1–2 h.**

**B) Publicar con el rojo, con autorización expresa y fechada del propietario.** El check es *requerido y
estricto*, así que sólo `JJOVEGA` —dueño de los rulesets— puede saltarlo; `jvega-habitat` no tiene admin.
Queda escrito que se publicó con la puerta en rojo y por qué.

**C) Aplazar 1.33.0.** La rama queda empujada y verificada; el tag espera a que la sonda se arregle en
1.34.0, detrás de `REQ-019`.

**D) Lo que NO se hace, y se nombra para que no aparezca como atajo:** volver a lanzar el CI hasta que
salga verde y fusionar en esa corrida. Con una sonda cuya dispersión cubre el techo, eso no es esperar a
que pase: es **elegir la corrida que da la respuesta que se quiere**. Tampoco `continue-on-error` ni
sacar el caso del CI — pondría la puerta en verde **apagando la señal**, que es el modo de fallo que
`AGENTS.md` §13 nombra y que `REQ-014 CA-18 (ii)` prohíbe por escrito.

**Recomendación de la coordinadora: (C), y (A) en 1.34.0 delante de `REQ-019`.** Motivo: el rojo no
acredita ningún defecto del producto, pero **el verde tampoco acreditaría nada** mientras el techo viva
dentro del ruido — así que publicar hoy no compra confianza, compra una firma vacía. Y (A) hecho antes de
que la sonda vuelva a decidir una publicación evita repetir esta conversación en 1.34.0.

**Estado del repositorio al escribir esto:** rama `cand/1.33.0` @ `eff143b`, empujada, árbol limpio.
PR **#43** en `DRAFT`. `REQ-014` `completado`. Bloqueantes `contrato` en el repositorio: **12**, en
`REQ-013` (2), `REQ-019` (1), `REQ-020` (8) y `REQ-023` (1) — ninguno en `REQ-014`.


### RESUELTA 2026-09-08 (propietario) — La auto-auditoría se congela: los hallazgos `instrumento` sobre el propio arnés dejan de abrir REQ y de entrar en la ventana en curso

- **Contexto, con los números que la motivan.** En un solo día: **9 hallazgos de seguridad abiertos**
  (`SEC-047`…`SEC-057`), **2 REQ nuevos** (`REQ-024`, `REQ-025`), **1 REQ cerrado** (`REQ-017`) y **2 que
  fueron hacia atrás** (`REQ-021` a `bloqueado`, `REQ-014` reabierto desde `completado`). Última versión
  publicada: **v1.32.1, hace más de un día**. El propietario lo nombró así: *«siento que cada corrida de
  QA y Seguridad traen un requerimiento nuevo, y me preocupa que estemos en círculos»*.

- **La causa, y no es que los agentes sean quisquillosos.** El arnés se audita a sí mismo, y la
  auto-auditoría **no tiene punto fijo**: el estándar que aplica —*«¿este criterio mide lo que dice
  medir?»*— **se aplica también al criterio que audita**. Siempre hay una capa más abajo. Y la
  consecuencia que importa: **esto es un plugin para otros proyectos y lleva más de un día sin entregarles
  nada**, mientras consume toda la capacidad en mirarse.

- **Qué sí fue círculo y qué no, porque la distinción decide el remedio.** Círculo: `REQ-021`, cuatro
  variantes de la **misma** tautología, cada arreglo destapando la siguiente — y el arnés lo paró solo,
  que es para lo que existe el tope de 3 vueltas. **No** círculo: `REQ-017` retiró una puerta no
  determinista que corría en producción; `CA-18` en verde desbloqueó la fusión; `SEC-053` descubrió que
  **`v1.31.0` se publicó fuera de delegación** sin que nadie lo supiera.

- **DECISIÓN — la regla, y su alcance exacto.** Un hallazgo de clase **`instrumento`** sobre los textos o
  los instrumentos del propio arnés:
  1. **se registra igual** en `docs/seguridad/registro-seguridad.md` — no se deja de mirar ni de anotar;
  2. **no abre un REQ nuevo** ni entra en la ventana en curso;
  3. **se acumula en un solo backlog** que se revisa **una vez por ventana**, al planificarla.

  **Lo que la regla NO toca, dicho para que no se estire:** los hallazgos `contrato` y `usuario/dinero`
  siguen bloqueando el cierre y siguen exigiendo write-back, exactamente como hoy. Esto no baja ningún
  rigor ni apaga ninguna puerta: sólo impide que un defecto **que ya está declarado como no bloqueante**
  genere trabajo de ventana.

- **Corrección de la coordinadora sobre su propia recomendación, hecha antes de aplicarla.** Al proponer
  esta regla afirmé que **«7 de los 9 hallazgos de hoy son `instrumento`»**. Es falso: medidos, son
  **4 `instrumento` y 5 `contrato`**. La regla, por tanto, **habría frenado menos de la mitad** de lo que
  se abrió hoy — es una palanca real pero **más pequeña de lo que la vendí**, y las cinco de clase
  `contrato` habrían entrado igual. Se aplica sabiendo eso.

- **Consecuencia operativa inmediata:** 1.33.0 se publica con lo que hay —`REQ-017` cerrado y la partición
  de `CA-18` en verde— y **no entra ningún hallazgo nuevo en esta ventana**. `REQ-019` sigue siendo el
  primer y único trabajo de 1.34.0, con la protección ya escrita en `docs/PLAN.md`.


### RESUELTA 2026-09-08 (propietario) — ratificación de `v1.31.0`, publicada de autoridad no acreditada

- **Contexto.** R-016 (`auditor-seguridad`) barrió los 40 tags publicados y encontró que `v1.31.0` se
  publicó por delegación con **tres `contrato` abiertos** —`QA-114`, `QA-116`, `QA-117`—, declarados en
  las dos sedes del tag, sin entrada en la cola de aprobaciones. No se había visto en R-015 porque ese
  barrido buscó prefijos `SEC-` y estos tres son `QA-`. `SEC-053` quedó en `en-mitigación` con esta
  ratificación como su **único residual pendiente**, vencimiento antes del tag de `v1.33.0`.
- **Decisión del propietario, 2026-09-08: ratificada.** Misma resolución que ya dio para `v1.32.1`. El
  auditor cierra el residual de `SEC-053` en su registro; la coordinadora no lo hace por sí misma —es la
  misma frontera que ya se aplicó al escribir la propia regla de escalada.


### RESUELTA 2026-09-08 (propietario) — La partición autorizada es IMPOSIBLE: se reabre REQ-014 y se re-deriva CA-18

- **Contexto.** Autorizaste partir las secciones sobre 400 líneas con **desarrollador + QA**, sin analista
  ni auditor, sobre dos premisas escritas: *«el cambio es **mecánico** —mismo contenido, mismos casos,
  menos líneas por archivo—»* y *«su acreditación **ya existe y es fuerte**: un inventario ordenado de
  caso y veredicto **idéntico byte a byte**»*. El desarrollador **paró antes de tocar `tests/`** y midió
  las dos. **Las dos son falsas.**

- **Premisa 1 falsa: no es mecánico, es aritméticamente imposible.** Tres invariantes se multiplican —
  cada sección corre en **su propio subshell y en paralelo** (`run.sh:1168`, invariante `CA-04`), así que
  todo archivo partido tiene que ser **autocontenido**; `CA-19` **prohíbe** que una sección haga `source`
  de otra; y `H-04` **aborta** ante cualquier archivo de `secciones/` que no case `NN-*.sh`, así que
  tampoco cabe un auxiliar. La maquinaria compartida **no se puede factorizar**. Mínimo autónomo medido,
  **antes de meter un solo caso**:

  | | preámbulo | maquinaria | bloque indivisible | mínimo |
  |---|---|---|---|---|
  | `37/1` | 26 | 122 | 312 | **460** |
  | `37/2` | 32 | 92 | 269 + 74 | **467** |

  **El límite de `CA-18` es 400. No hay ninguna partición conforme que lo cumpla.** Y la mejor posible
  deja `CA-18` **rojo igual**: `37/1`-A **564**, `37/2`-A **467**, más `38-sondas-compartidas.sh` **827**.
  Duplicar el clasificador para separar `CA-01` de `CA-10` da **516 y 511** —las dos siguen fuera— y
  además duplica cuatro evaluaciones y la clasificación, coste que `CA-08 (i)` presupuesta. Recortar
  comentarios tampoco basta: con el código puro, el archivo del clasificador sigue en **~410**.

  > **Esto es la clase de `DEV-021-05`, y conviene nombrarla:** un criterio **derivado sin comprobar su
  > factibilidad**. `CA-18` fijó 400 sin medir cuánto mide una sección autónoma mínima. Es el mismo
  > defecto que `CA-08 (iii)`, cuyo techo de `4×` contaba cuatro ejercicios como si costaran lo mismo y
  > hubo que **re-derivarlo término a término a 6×**. Y aplica la regla que salió de ahí: **un techo no
  > se compra deformando el sujeto**, y aquí el sujeto ya no se puede deformar más — el mínimo es
  > estructural, no de estilo.

- **Premisa 2 falsa: la acreditación en la que se apoyó tu firma ya no discrimina.** Medido con **dos
  corridas intactas del banco, sin tocar nada**: 884 casos las dos, **74.046 y 74.047 bytes**, y `cmp`
  **difiere en el byte 42.659, línea 548**. **20 de 884 líneas son volátiles** —µs, razones, PID, sellos
  epoch— en `REQ-017 CA-03/04/08/09` y `REQ-021 CA-02/03/04/08`. La causa está verificada en una línea:
  `tests/escenarios/hooks/inventario.sh:24` normaliza **sólo** `[0-9]+ms` → `Nms`, y estas cifras no son
  ms.

  **Consecuencia:** el `cmp` crudo que exige `REQ-014 CA-12` **ya no puede distinguir «la partición
  cambió algo» de «el reloj avanzó»**. Es decir, la acreditación que sustituía al analista y al auditor
  **no es aplicable en este árbol**. El desarrollador construyó un oráculo **normalizado** y lo validó
  —dos corridas intactas **sí** salen idénticas bajo él: 884 líneas, 72.108 bytes, `cmp` limpio—, así que
  la acreditación es **factible**; pero el criterio, tal como está escrito, no lo es.

  > Y la sospecha del desarrollador, que suena correcta: **es probablemente la causa real de que la
  > partición se ordenara «después de cerrar REQ-021»** — las secciones que hay que partir son justo las
  > que publican las cifras volátiles.

- **Lo que el desarrollador NO hizo, y estuvo bien:** no tocó `tests/`, no comiteó, no tocó el índice, y
  **no escribió `Estado: bloqueado` en ningún REQ**. `CA-18` es de **`REQ-014`, que está `completado` con
  `QA: aprobado` y `Seguridad: aprobado`**; reabrirlo es la **REGLA DE ESTADO** de §9 y una decisión de
  gobernanza, no un efecto colateral de una comisión. Gates en verde: las tres de §7, `bash -n` sobre las
  **45** secciones con **0 rotas**, banco **880 PASS · 0 FAIL · 4 SKIP · rc 0**, y `git diff HEAD --
  tests/` **vacío**.

- **Opciones.**
  - **A) Reabrir `REQ-014` para re-derivar `CA-18` y arreglar el oráculo del inventario, y partir
    después.** Absorbe las dos premisas falsas en un solo trabajo: el analista **re-deriva el límite
    término a término** —como se hizo con `CA-08 (iii)`— desde el mínimo autónomo **medido**, y lo escribe
    como **propiedad y no como número**; y `inventario.sh` normaliza los campos volátiles, con el oráculo
    que ya está construido y validado. Después la partición es posible y su acreditación vuelve a
    discriminar. **No toca el mecanismo del corredor.** Reabre un REQ `completado`, que es exactamente lo
    que §9 manda cuando un criterio cambia.
  - **B) Mover los ayudantes compartidos a `run.sh`.** La única salida que hace `CA-18` verde **sin**
    tocar el límite. Pero es **cambio de mecanismo** → `critico` con analista y auditor, y **cambia el
    conjunto que `autoprueba-corredor.sh` deriva y vigila en `H-01`**. Más riesgo por el mismo precio.
  - **C) No fusionar 1.33.0.** `CA-18` se queda rojo y la candidata entera espera a 1.34.0, junto con
    REQ-021. Deja sin publicar el trabajo de REQ-017, que retira una puerta **no determinista** que hoy
    está publicada en `v1.32.1`.

- **Recomendación de la coordinadora: A.** El número estaba mal derivado y el árbol lo demuestra con
  aritmética, no con opinión. Re-derivar un techo infactible **no es debilitar una puerta**: es lo que
  este REQ ya hizo una vez, con el número delante. Y B cambia el corredor para no tener que admitir que
  el 400 estaba mal.

- **Lo que NO recomiendo y digo por qué, para que no aparezca luego como atajo:** poner
  `continue-on-error` en el paso de la autoprueba, o sacar `CA-18` del CI. Haría verde la puerta
  requerida **apagando la señal**, que es exactamente el modo de fallo que `AGENTS.md` §13 describe —
  *«un guard apagado protege menos que uno parcial»*— y que el propio `CA-18` existe para evitar.

- **Espera.** Tu elección entre A, B y C. **Nota de honestidad sobre el calendario:** cualquiera de las
  tres deja `v1.33.0` **fuera de hoy**, porque A y B son ciclos de cuatro agentes (~2 h cada uno) y C no
  publica. La estimación de «≈1 h al tag» que la coordinadora venía dando **era falsa**, y lo era porque
  se apoyaba en que la partición era mecánica — la misma premisa que acaba de caer.

- **RESOLUCIÓN del propietario, 2026-09-08: opción A.** Se reabre `REQ-014` por la **REGLA DE ESTADO**
  de §9: el analista re-deriva `CA-18` **término a término** desde el mínimo autónomo medido y lo enuncia
  **por propiedad, no por número**, y `inventario.sh` pasa a normalizar **lo que es medida y no
  identidad** —la propiedad que su propio comentario ya declara y cuya extensión envejeció al nombrar una
  unidad—. Los dos criterios ganan **par discriminante**: un límite que nadie puede exceder y un oráculo
  que normaliza todo no miden nada. Después la partición es posible, incluida la de
  `38-sondas-compartidas.sh`, cuya firma el propietario ya dio hoy.

- **Corrección de la coordinadora a su propia estimación, hecha en el mismo día:** el «fuera de hoy» de
  arriba **también era pesimista**. Medido con las duraciones reales de las comisiones de esta sesión
  —analista 13–21 min, desarrollador 9–43 min, QA 45 min, auditor 8–20 min—, la reapertura completa sale
  a **≈2 h 45** y `v1.33.0` **sí cabe hoy**, con **≈3 h 45** si hay una vuelta dev↔QA. Se deja escrito
  porque las dos estimaciones del día —la de «≈1 h» y la de «fuera de hoy»— fallaron en direcciones
  opuestas y ninguna publicó el dato del que salían.

### RESUELTA 2026-09-08 (propietario) — REQ-021 sale de 1.33.0: se publica sin él y su código se queda

### RESUELTA 2026-09-08 (propietario) — REQ-021 sale de 1.33.0: se publica sin él y su código se queda

- **Contexto.** `AGENTS.md` §6: máximo **3 vueltas dev↔QA por REQ**, el contador **no se reinicia**, y
  agotado el tope el REQ **o cierra con residual declarado o pasa a `bloqueado` y se escala al humano**.
  La vuelta 3 está gastada y **el residual no está disponible**: `QA-021-10` es `contrato`, y
  `guard-completado` deniega el cierre con un `contrato` abierto. Sólo existiría si QA o el auditor lo
  **reclasificaran**, y QA se negó expresamente con la evidencia delante.

- **Lo que la vuelta 3 SÍ consiguió, para que la decisión no se tome sobre un fracaso que no lo es.** El
  mecanismo cambió de razonable a comprobable: el juez obtiene el testigo **antes** de invocar la sonda,
  a coste **cero procesos**. La mutación del forzador —no ejercer el binario ni una vez— **por fin
  FALLA** (`rc 1 · 74/3`) mientras la misma copia sin mutar **PASA** (`rc 0 · 77/0`). `CA-08 (iii)`
  **mejoró** en las dos magnitudes. Banco **880 PASS · 0 FAIL · 4 SKIP, rc 0**, cuadre 884 verificado por
  QA contra 45 literales. `CA-07` acreditado en sus tres puntos (**828 casos, 61.287 bytes, `cmp`
  idénticos** contra un worktree de `794fa4c`). Las tres gates de §7 en verde.

- **Por qué no basta, y es una sola frase que conviene leer despacio.** QA reprodujo el forzador y
  **cuatro mutaciones más, tres de las cuales no leen el sujeto, y las cuatro PASAN**. La causa:
  `SP_RESOLUCION=1`, `SP_CAL_MARGEN=4` y `SONDA_DISC_PROC_VECES=2` son **literales**, así que
  `testigo = parámetro / 2` se cumple **por construcción en toda máquina**. La condición 1 exige que el
  testigo **no coincida** con el parámetro —y no coincide, 2 ≠ 4— pero **«no coincidir no es no ser
  predecible»**: lo que hace que un contraste pueda fallar es que la sonda no pueda **saber** el testigo
  sin trabajar. **El forzador nombraba un ejemplar; la clase sobrevive.** Es la **cuarta** variante de la
  misma clase dentro del mismo REQ (`2N/N`, `N−1`, el rastro que la sonda escribe, y ahora el testigo
  derivable).

- **Y una cadena de acreditación que se rompe.** `CA-03 (d)` **falla** con la carga acreditada por su
  **efecto** (tarea de referencia: 262–282 ms en reposo → 402–508 ms con 4/12 → 675–1426 ms con 12/12):
  saturación **9 de 16 corridas** con FAIL, y **8 de 13 casos son `CA-03 (c)`**, no la mitad discordante.
  El `0 de 30 en cuatro regímenes` de la vuelta 2 **se retira**: su registro **no publica ni una
  evidencia de que sus cuatro regímenes existieran**, y un régimen declarado y no acreditado es un número
  que no puede salir mal. Con él se retira **el permiso que autorizaba bajar `r` a 3** («sólo mientras
  (d) siga en 0 de 30», `REQ-021.md:788`). Las dos ramas quedan cerradas: con `r=5`, `(ii)` da **1,2825×
  > 1,25×**; con `r=3`, cumple **sobre un permiso inexistente**. **`CA-08 (ii)` no queda acreditado.**

- **Lo que QA dejó nombrado y medido, que es lo que hace esta decisión barata en cualquier dirección:**
  las dos piezas que faltan cuestan **cero procesos** — el tamaño del discordante **sorteado por
  corrida**, y la terna **fuera de todo directorio que la sonda reciba**. Con ellas, el conjunto de
  mutaciones que pasan se reduce exactamente a «lee el sujeto», y la frontera que el REQ declara
  —«falsificación deliberada, no descuido»— pasa a ser **verdadera**. Hoy es una **salida**, porque
  clasifica por la intención del autor, que ningún control mide.

- **Opciones.**
  - **A) Publicar 1.33.0 sin REQ-021.** La ventana entrega **REQ-017** —que retira una puerta **no
    determinista** y baja el reloj del banco de 95,66 s a 45,14 s— más la **partición de las tres
    secciones**. REQ-021 pasa a **1.34.0** con las dos piezas ya nombradas. *Sub-decisión que va con
    esta opción y que no resuelvo yo:* **el código de la vuelta 3 ya está comiteado** (`2ce7804`) y el
    banco está verde con él. ¿Se queda en 1.33.0 —con sus hallazgos declarados y su REQ `bloqueado`— o se
    revierte? Se queda es lo que yo haría: el árbol con él es **mejor** que sin él y el banco lo
    certifica, pero publicar código de un REQ `bloqueado` es una decisión de gobernanza tuya.
  - **B) Autorizar una vuelta 4**, excediendo el tope de §6 por decisión expresa. QA nombró exactamente
    qué falta y cuesta cero procesos, así que el trabajo está bien especificado. **El argumento en
    contra está medido:** el tope existe *«porque cada arreglo cierra el hallazgo documentado y la vuelta
    siguiente encuentra una variante»*, y ésta sería la **cuarta variante de la misma clase**. Autorizar
    la vuelta 4 es apostar contra un patrón que este REQ ha exhibido tres veces.
  - **C) A, más reducir el alcance de REQ-021 en 1.34.0** a **sólo la sonda de procesos** —**0 FAIL en
    las 48 corridas** de QA, `cal_a=2,000`/`cal_b=1,000` exactos— sacando la de reloj, que es de donde
    salen `(c)`, `(d)` y **todo** el coste que dejó `CA-08 (ii)` sin acreditar. Es el mismo patrón que ya
    aplicaste una vez en este REQ: **reducir el sujeto en vez de debilitar el techo**. No unblokea nada
    hoy —`QA-021-10` vive en la sonda de procesos— pero hace el REQ de 1.34.0 mucho más pequeño.

- **Recomendación de la coordinadora: A, con el código quedándose, y la forma de C para 1.34.0.** El
  motivo no es de calendario: es que **B apuesta contra la única cosa que este REQ ha medido tres veces
  de sí mismo**. Y 1.33.0 no se va vacía — REQ-017 retira una puerta no determinista, que es exactamente
  el tipo de defecto que este arnés existe para no publicar.

- **Espera.** Tu elección entre A, B y C, y —si eliges A o C— si el código de la vuelta 3 se queda en
  1.33.0 o se revierte. **El pipeline está detenido**: mientras esta entrada esté aquí,
  `guard-completado` deniega marcar **cualquier** REQ como `completado`.

- **RESOLUCIÓN del propietario, 2026-09-08: opción A, y el código de la vuelta 3 SE QUEDA.** 1.33.0 se
  publica con **REQ-017** y la partición de secciones; **REQ-021 pasa a 1.34.0** con las dos piezas que
  QA nombró (tamaño del discordante sorteado por corrida, y la terna fuera de todo directorio que la
  sonda reciba), las dos a coste cero procesos. El código de `2ce7804` **no se revierte**: el árbol con
  él es medible mejor que sin él y el banco lo certifica (880/0/4, `rc 0`).

- **Dos cosas que esta resolución NO decide, y quedan nombradas para que nadie las resuelva por su
  cuenta:**
  1. **`Estado:` de REQ-021 se queda en `bloqueado`**, no vuelve a `pendiente`. El tope de vueltas
     **sigue agotado** y nada de esta decisión lo cambia; ponerlo en `pendiente` borraría ese hecho.
  2. **Si el contador de vueltas se reinicia al cambiar de ventana, NO está escrito en `AGENTS.md` §6.**
     La sección sólo dice que no se reinicia «con cada hallazgo nuevo». Es una pregunta abierta con
     efecto real —decide si 1.34.0 tiene tres vueltas o cero— y la resuelve el `analista-requerimientos`
     en el write-back, con **ADR** si es cambio de fondo. La coordinadora no la interpreta.

### RESUELTA 2026-09-08 (propietario, autorización expresa) — partir las dos secciones 37 paga desarrollador + QA, sin analista ni auditor

> **AMPLIACIÓN del propietario, 2026-09-08, misma firma extendida a `38-sondas-compartidas.sh`.** La
> vuelta 3 de REQ-021 hizo crecer esa sección de **722 a 827** líneas, así que `CA-18` la nombra junto a
> las dos 37 y **la fusión seguía bloqueada aunque las 37 se partieran**. La autorización original decía
> «las dos secciones 37» y excluía por escrito «ninguna otra edición de `tests/`»: **extenderla por
> analogía habría sido la reclasificación automática que §6 prohíbe**, así que se preguntó. Mismo trato y
> mismo motivo —el cambio es mecánico y su acreditación es el inventario ordenado de caso y veredicto
> **idéntico byte a byte**, criterio central de REQ-014— y **los mismos límites**: ninguna otra edición
> de `tests/`, ningún cambio de lógica, y ningún ajuste de `CASOS_ESPERADOS` (hoy **884**) ni de
> `CASOS_ESPERADOS_SECCION` más allá del reparto aritmético que la partición obliga.
>
> **Va en comisión aparte y en SERIE, no en paralelo:** las dos particiones escriben
> `tests/escenarios/hooks/run.sh`, `tests/escenarios/hooks/README.md` y `CHANGELOG.md`, así que
> `AGENTS.md` §6 punto 3 las hace colisionar por líneas, con independencia de que sean la misma fase.
>
> **Y una nota que la ampliación obliga a dejar escrita:** la sección 38 es la de **REQ-021**, que acaba
> de quedar `bloqueado`. Partirla **no toca su lógica** ni sus veredictos —es el mismo contenido en menos
> líneas por archivo— pero el REQ vuelve a 1.34.0 con sus secciones ya repartidas, y quien retome allí
> las dos piezas que QA nombró se las encontrará en archivos distintos de los que su Historial cita.

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
