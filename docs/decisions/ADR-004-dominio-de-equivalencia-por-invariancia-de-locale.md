# ADR-004 — El dominio de equivalencia de REQ-017 se traza por la invariancia de locale de la heredada, no por su determinismo
Fecha: 2026-09-07
Estado: aceptada

## Contexto

REQ-017 sustituye la guarda cuadrática del CR por una sentencia equivalente
(`case "${l%$CR}" in *$CR*)` → `case "$l" in *$CR?*)`). Su criterio de equivalencia, **CA-01**, decía
hasta el 2026-09-07: «Cuando se le pasa **una línea cualquiera**, Entonces la salida y el estado
coinciden **byte a byte** con los del árbol heredado v1.32.1».

**Ese criterio era insatisfacible, y eso está medido.** Bajo locale UTF-8 en bash 5.3.9, la
eliminación de sufijo con patrón de la heredada no se comporta byte a byte sobre secuencias
multibyte inválidas. El write-back de la **vuelta 0** de QA acotó entonces CA-01 al **dominio en que
la heredada es determinista** —k ≥ 3 evaluaciones de la misma entrada en el mismo proceso publican el
mismo estado— y contrató aparte, en **CA-10**, lo que ocurre fuera. Ese write-back se clasificó
**cambio menor**: sin ADR.

**La vuelta 1 midió que la propiedad elegida no separa las dos clases.** Corpus de 106 entradas con
secuencia multibyte inválida, k = 6 evaluaciones de la heredada en el mismo proceso, cuatro corridas
(`docs/qa/1.33.0.md`, QA-017-01):

| Corrida | Dentro del dominio | Fuera | **Dentro Y divergente de este árbol** |
|---|---|---|---|
| 1 | 104 | 2 | **6** |
| 2 · 3 · 4 | 106 · 106 · 106 | 0 · 0 · 0 | **7 · 7 · 7** |

CA-01 exige **0** divergencias dentro del dominio, así que **falla**. Y hay una segunda consecuencia,
peor porque es silenciosa: en **3 de 4** corridas **cero** entradas cayeron fuera, de modo que
**CA-10 se quedaba sin sujeto** y habría emitido SKIP para siempre. Un criterio que no puede pasar y
su hermano que no puede llegar a medir: el dominio no acotaba el universo por donde había que
partirlo.

**La causa, que es lo que hay que retener.** Lo que la vuelta 0 midió era cierto —`${l%$CR}` devuelve
un **valor intermedio** distinto en cada evaluación—, pero ese valor **no siempre llega al estado
publicado**: la rama que se toma suele ser la misma, y entonces la heredada **repite**. El criterio
se escribió sobre lo que se midió (el intermedio) y contrata sobre lo que se publica (el estado). La
cifra se publicó como medida en el `CHANGELOG.md` y ya está corregida allí. Es la misma familia que
esta ventana persigue entera: **una medición correcta de la magnitud que no es**
(`requirements/README.md` § «Cómo se escribe un criterio que no se desmiente», forma (d)), aplicada
esta vez al **conjunto** en vez de a la magnitud.

**Por qué esto es de fondo y no un cambio menor** —y la clasificación de la vuelta 0 queda
**revocada**—. El precedente en que se apoyó era la **pared de los 60 s**, y no transporta: aquélla se
declaró **medida** y se dio a **otro dueño** (`SEC-030`), así que no añadió ninguna obligación a este
REQ y ningún criterio suyo podía fallar por ella. **CA-10 se contrata como criterio**: es una puerta
que tiene que pasar para cerrar, añade trabajo en el banco y **cambia el significado de CA-01**, que
es donde este REQ define qué quiere decir «equivalencia» — exactamente lo que `AGENTS.md` §9 llama de
fondo. Encima del argumento formal hay uno medido: **la decisión nueva —dónde se traza la frontera—
es justo la que salió mal**, y salió mal en silencio, porque se tomó dentro de un write-back
clasificado menor donde nadie tenía que justificar la elección de la propiedad.

## Decisión

**1. La equivalencia de REQ-017 se afirma sobre un dominio, no sobre toda entrada.** Se mantiene la
decisión de la vuelta 0 en su forma: hay un dominio, se comprueba **en la corrida** y lo de fuera se
contrata aparte. Lo que cambia es **cuál** es el dominio.

**2. El dominio es donde la heredada coincide consigo misma bajo `LC_ALL=C`.** Una entrada está
**dentro** si la heredada v1.32.1 publica **un único y el mismo estado** (`ARNES_LINEA`,
`ARNES_CITA`, `ARNES_CR`, `ARNES_CR_LINEA`) en **todas** las evaluaciones de esa entrada dentro de la
misma corrida: k ≥ 3 bajo el **locale del entorno** y k ≥ 3 bajo **`LC_ALL=C`**. Eso exige dos cosas a
la vez —que **repita** (determinismo) y que **decida lo mismo en los dos locales** (invariancia de
locale)—, y basta que falle una para que la entrada quede **fuera**.

**3. El dominio se traza por una propiedad de la HEREDADA SOLA, nunca por la coincidencia de los dos
árboles.** Un dominio definido como «las entradas donde los dos árboles coinciden» convierte CA-01 en
un criterio que **no puede fallar**, y un criterio que no puede fallar no es una puerta. Esta regla es
parte de la decisión, no un comentario: es la que impide que el próximo write-back arregle un rojo
moviendo la frontera.

**4. Fuera del dominio se contrata la dirección contra un ORÁCULO, no la igualdad.** El oráculo es
**la heredada bajo `LC_ALL=C`**, y CA-10 exige que la decisión de este árbol coincida con él en los
dos locales. Si la heredada **tampoco repite bajo `LC_ALL=C`**, esa entrada **no es clasificable**: se
cuenta aparte y el caso emite SKIP con su motivo, nunca PASS (regla de CA-06).

### Por qué esa propiedad sí separa las dos clases

**Por construcción.** Sobre bytes, las dos sentencias hacen **la misma pregunta**: «¿hay un CR que no
sea el último byte?». Si el último byte es CR, `${l%$CR}` quita exactamente ése y lo que queda tiene
un CR ⟺ había otro CR antes; si el último byte no es CR, no se quita nada y hay un CR ⟺ ese CR va
seguido de algo. Bajo un locale byte a byte —`LC_ALL=C`— la heredada **es** esa pregunta, y este
árbol la implementa en **todos** los locales, porque no elimina sufijo con patrón. De ahí la
consecuencia: **los dos árboles divergen exactamente donde la heredada se aparta de su propia
semántica byte a byte**, y eso es, palabra por palabra, «la heredada no es invariante al locale».

**Medido, y por eso no es sólo un argumento.** Sobre las mismas 106 entradas y las mismas 4 corridas
(`docs/qa/1.33.0.md`, QA-017-01 y QA-017-08): la heredada incumple la **invariancia de locale** en
**7 de 106** —las 4 corridas— y el **determinismo** en **0–2**; los dos fenómenos **no coinciden**, y
el conjunto divergente es el primero. Este árbol: **0** violaciones de determinismo y **0** de
invariancia de locale de la decisión, 4/4.

**Las dos comprobaciones que esta decisión tenía que superar, y que superó:**

| Lo que había que comprobar | Con el dominio nuevo |
|---|---|
| **CA-01 puede dar 0** | Las 6–7 divergencias observadas son **todas** de la clase que ahora queda **fuera**. Dentro quedan ~97–99 de 106 y la divergencia esperada es **0** |
| **CA-10 tiene sujeto no vacío y estable** | Fuera quedan **no menos de 7** entradas en **4 de 4** corridas (las 7 violaciones de invariancia, más 0–2 de determinismo). Con el dominio anterior eran **0 en 3 de 4** |

**Y CA-01 sigue pudiendo fallar**, que es la otra mitad de la comprobación: si una entrada sobre la
que la heredada es invariante al locale divergiera de este árbol, el criterio la vería y sería un
defecto real del arreglo. El dominio no se dibujó alrededor del resultado; se dibujó alrededor de una
propiedad de la heredada que se mide sin mirar a este árbol, y **da la casualidad medida** de que
deja fuera las divergencias.

## Alternativas consideradas

- **A — Dejar CA-01 sobre «una línea cualquiera».** Por qué no: **insatisfacible y demostrado**. En
  las 7 entradas de la clase, «el estado de la heredada» **no designa un objeto único** —depende del
  locale—, así que una igualdad contra él no está definida hasta decir bajo qué locale. Ninguna
  implementación podía cumplirlo, y un criterio que ninguna implementación puede cumplir no es un
  techo exigente: es ruido que gasta vueltas del bucle.
- **B — Dominio por determinismo de la heredada (lo que hizo la vuelta 0).** Por qué no: **medido
  falso**, tabla de arriba. Es la alternativa que se probó, y su fallo es el motivo de que este ADR
  exista. Se conserva escrita porque el modo de fallo es reutilizable: se eligió la propiedad que
  explicaba el **síntoma que se había mirado** (el valor intermedio) en vez de la que separaba el
  **estado que el criterio contrata**.
- **C — Sin dominio: contratar la igualdad de todo el corpus contra la heredada bajo `LC_ALL=C`.**
  Por qué no del todo: es más simple y **se adopta en parte** —es exactamente el oráculo de CA-10
  (ii)—, pero no sirve como criterio único por dos motivos. (1) El **texto** publicado
  (`ARNES_LINEA`, `ARNES_CR_LINEA`) se construye con sustitución y eliminación con patrón, la misma
  familia que hace no determinista a `arnes_norm_clave` (QA-017-07): su valor bajo UTF-8 no se puede
  contratar contra nada, y por eso CA-10 contrata **la decisión** y no el texto. (2) Dejaría de decir
  nada sobre lo que cambia **en el entorno donde los hooks corren de verdad**, que es un locale
  UTF-8; la comparación con la heredada **tal como se ejecuta hoy** es la que responde «¿esto cambia
  lo que decide el arnés?», y ésa es la pregunta de la Historia del REQ.
- **D — Estrechar el corpus hasta que la clase desaparezca.** Por qué no: es **el verde que esta
  ventana persigue** y ya tiene hallazgo abierto (QA-017-02). Es además la forma que
  `requirements/README.md` § «Y el reverso, para que esto no sea una coartada» prohíbe por nombre:
  relajar el criterio para que el código encaje. Por eso CA-01 conserva la asimetría **FALLA** (el
  corpus perdió la clase) frente a **SKIP** (la máquina no tiene el defecto): un corpus estrechado es
  trabajo retirado y tiene que doler; una máquina sin el defecto es falta de sujeto y poner rojo ahí
  acaba con alguien apagando el caso.
- **E — Declarar la divergencia fuera de alcance, con otro dueño (precedente de `SEC-030`).** Por qué
  no: el precedente **no transporta**, y la razón la da el propio precedente. La pared de los 60 s se
  declaró **medida** y se cedió entera a otro REQ, de modo que ningún criterio de éste podía fallar
  por ella. Aquí lo que se cedería es **la definición de equivalencia de este REQ**, que es su
  contrato central. Un REQ no puede ceder a otro dueño la pregunta de si hace lo que dice hacer.
- **F — Contratar la igualdad dentro y no contratar nada fuera.** Por qué no: dejaría **sin puerta**
  la única clase en que este REQ **cambia el comportamiento** respecto de v1.32.1 — y ese cambio es
  un **beneficio** (cierra un fallo en abierto de la heredada). Un beneficio no contratado es una
  propiedad que nadie sabe que tiene y que la siguiente refactorización retira sin enterarse.

## Consecuencias

- (+) **CA-01 puede dar 0 y CA-10 tiene sujeto**, las dos cosas a la vez y con la partición medida en
  cada corrida. Es lo que el dominio anterior no conseguía en ninguna de sus dos mitades.
- (+) **El dominio es auto-anclado**: se calcula en la corrida a partir de una propiedad de la
  heredada, no de una lista congelada ni de un inventario registrado. No envejece hacia el lado que
  abre, que es la lección de `ADR-002`, de `SEC-025` y de CA-05 de este mismo REQ.
- (+) **REQ-017 declara que cambia el comportamiento** en esa clase, y en qué dirección: donde la
  heredada bajo UTF-8 publica `cr=0` sobre una línea **con** CR interior, este árbol publica `cr=1`,
  que es lo que la heredada misma decide bajo `LC_ALL=C`. Cierra un fallo en abierto de v1.32.1 en la
  función que CA-01 nombra.
- (−) **El diferencial se encarece**: hay que evaluar cada entrada k veces por árbol **y por locale**,
  y clasificarla en la corrida. **Mitigación:** el corpus es de decenas de entradas y las sondas ya
  viven en la sección de banco que el REQ declara; el coste medido de la sección entera es de
  segundos, frente a los 45 s del banco.
- (−) **En una máquina cuyo locale del entorno sea `C` o `POSIX`, el conjunto de fuera es vacío por
  construcción** y CA-10 no tiene sujeto. **Mitigación:** es un **SKIP citando el locale**, nunca un
  PASS, y ahora el motivo es nombrable de antemano en vez de aparecer como un misterio.
- (−) **El oráculo es una hipótesis sobre `LC_ALL=C`**: que ahí la eliminación de sufijo es byte a
  byte. **Mitigación:** no se supone, se **comprueba en la corrida** —si la heredada tampoco repite
  bajo `LC_ALL=C`, la entrada no es clasificable y el caso lo dice—; medido hoy, 0 de 106.
- (−) **Se gasta una vuelta del bucle dev↔QA** en una decisión de redacción, con un contador que **no
  se reinicia** (`AGENTS.md` §6). **Mitigación:** ninguna que sirva a posteriori; la que queda es la
  regla 3 de la Decisión, que obliga a justificar la elección de la propiedad la próxima vez.
- (Neutro, y se deja escrito) **Esta decisión no entró por `PENDING_APPROVAL.md`.** No es un gate
  humano de `AGENTS.md` §6 —no toca `main`, ni el ruleset, ni el CI, ni el manifiesto, ni `hooks/`—:
  es un write-back de requerimiento, que es trabajo del `analista-requerimientos`. Y ese archivo
  bloquea el cierre de **cualquier** REQ mientras tenga entradas.
- (Pendiente, con dueño) **La forma metodológica no se adopta en esta ventana.** «Acotar el universo
  por una propiedad que no separa la clase que el criterio quiere excluir» es candidata a **quinta
  forma prohibida** de `requirements/README.md`, con el caso medido de este ADR. No entra aquí porque
  CA-07 ya está adoptando la forma (d) en esta ventana y añadir otra cambiaría el alcance de REQ-017.
  Dueño: `analista-requerimientos`; candidata para 1.34.0, junto a la de CA-05.

## Nota de numeración

**`ADR-004` estaba reservado por REQ-021 y este archivo lo ocupó.** REQ-021 (`pendiente`, 1.33.0)
declara en su `Archivos:` un `docs/decisions/ADR-004-instrumentos-compartidos-en-tests-util.md` que
**todavía no existe** y lo cita en su Trazabilidad, sus `Notas` y su Historial. Este ADR se escribió
mirando el disco, donde el número estaba libre. La resolución es de la coordinadora y **no** la toma
esta comisión, que sólo podía escribir en `requirements/REQ-017.md` y en `docs/decisions/`: se
recomienda **renumerar el de REQ-021 a `ADR-005`** (seis referencias en un REQ que aún no se ha
empezado, ningún archivo que mover) frente a mover éste (un `git mv` más seis referencias en REQ-017 y
en este archivo). Queda escrito en los dos sitios —aquí y en `requirements/REQ-017.md` § «Preguntas
abiertas / conflictos»— porque un número duplicado en el registro de decisiones se descubre tarde y
por casualidad. **Causa:** el número de ADR no tiene asignador, y quien escribe uno nuevo consulta el
disco, no los REQ pendientes que lo han reservado.

## Enlaces

- `requirements/REQ-017.md` — CA-01 (dominio) y CA-10 (dirección fuera del dominio) son las dos
  mitades de esta decisión; el Historial de cambios lleva el antes → después.
- `docs/qa/1.33.0.md` § «Validación de QA — REQ-017, vuelta 1 de 3» — QA-017-01 (la medición que
  revoca el dominio anterior), QA-017-08 (CA-10 sin caso) y § «CA-10, ¿cambio menor o de fondo?», que
  es el origen de este ADR.
- `requirements/README.md` § «Cómo se escribe un criterio que no se desmiente» — forma (d) (la
  magnitud equivocada), de la que ésta es prima sobre el conjunto, y § «Y el reverso», que prohíbe la
  alternativa D.
- `AGENTS.md` §9 — la definición de cambio de fondo que revoca la clasificación de la vuelta 0.
- `ADR-002` y `SEC-025` — la familia «una comprobación congelada envejece hacia el lado que abre»,
  que es el motivo de que el dominio se calcule en la corrida.
