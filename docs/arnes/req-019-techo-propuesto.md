# REQ-019 — Propuesta de techo para `CA-07`, con los punteros obligatorios dentro

> **Qué es este archivo.** Una **propuesta de número** para que el propietario firme o rechace, con su
> derivación completa. **No es un reparto**, no mueve ningún byte de los documentos en alcance y **no
> modifica ningún criterio**: el techo se escribe en `CA-07` cuando haya firma, no aquí.
> **Y no es la acreditación de no-pérdida** — ver §«Límite declarado» al final, que es la parte que no
> se puede confundir.

**Versión base de todas las cifras.** Commit **`d6620ea`** (`REQ-019 F1: el techo 0,72x medido EN
BYTES, y no se alcanza`), que es donde se introdujo la tabla por sección de §«El suelo forzado MEDIDO
EN BYTES»; los dos documentos en alcance son ahí **idénticos** a `496068c`, que es el commit base de la
rama de trabajo. Se leyó con `git show d6620ea:requirements/REQ-019.md`, **no** del árbol de trabajo:
otra comisión está escribiendo en paralelo y el disco vivo no es una línea base.

**Método, en una frase por cifra.** El **suelo** no se re-midió: sale tal cual de la tabla por sección
de ese commit. Los **punteros** se derivaron contando bloques delegados en esa misma tabla y midiendo
con `wc -c` **punteros reales escritos para este cálculo**, no estimados. El **techo** es el cociente
`resultante / base` redondeado hacia arriba. No se hizo ninguna medición de reloj.

---

## 1. El coste de los punteros, derivado

### 1.1 Cuántos punteros exige el mecanismo, y por qué no son ni 11 ni 38

`CA-03` se contrata **por archivo de destino** («no menos de 1 puntero», y el propio criterio dice que
eso es un **suelo**), y el puntero vive **en la sección de la que salió el contenido**. `CA-12` es lo
que fija el grano real: **una pregunta por cada bloque delegado que enuncie o acote gobierno**, y **una
por sección** delegada para los bloques **puramente narrativos** —una anécdota medida, un «por qué» que
no acota nada—, y cada pregunta se resuelve **dentro del documento del que salió el bloque** en no más
de un salto. De ahí tres conteos distintos, y sólo uno es el que hay que pagar:

| Conteo | `AGENTS.md` | README | total | Qué lo justifica |
|---|---:|---:|---:|---|
| Mínimo (`CA-03` por destino) | 7 | 4 | **11** | Un puntero por sección de origen, con un destino por sección |
| **Derivado de `CA-12`** | **13** | **13** | **26** | Una pregunta por bloque de gobierno delegado + una por sección narrativa |
| Un puntero por bloque delegado | 18 | 20 | **38** | **No lo exige nada**: `CA-12` (ii) agrupa los narrativos por sección |

El conteo que se usa es el **derivado de `CA-12` (26)**. El desglose sale de la tabla por sección:

- **`AGENTS.md` — 18 bloques delegados, 6 de gobierno + 12 narrativos en 7 secciones = 13 preguntas.**
  De gobierno: el autoalojamiento de §1, la casuística de `SEC-020` en §6, la casuística de cobertura
  de `Bash` de §13, la mecánica de la rotación, la de la continuidad y la nota del prefijo estricto del
  agente. Narrativos: preámbulo, §1, §5 (×4), §6 (×3), §7, §9, §13.
- **README — 20 bloques delegados, 9 de gobierno + 11 narrativos en 4 secciones = 13 preguntas.**
  De gobierno: el bloque de ejemplo del campo `Archivos:`, los **cuatro** pares Mal/Bien de las formas
  (a)–(d), el alcance temporal, el mismo alcance para la forma (d), la nota de adopción por versión y
  la plantilla del REQ. Narrativos: preámbulo, Veredictos, `Archivos:`, «Cómo se escribe un criterio».

*Los pares Mal/Bien y el bloque de ejemplo se cuentan como **gobierno** —no como anécdota— porque
enseñan la **forma admitida**; es la lectura que más punteros paga, y es la que se usa.*

### 1.2 Cuánto pesa un puntero conforme, medido

`CA-03` obliga a que el puntero **enuncie la pregunta que el archivo responde** y **no** sea genérico:
«más detalles» no cumple. Así que el tamaño no se supone. Se escribieron tres punteros reales y se
midieron con `wc -c`:

| Puntero escrito para este cálculo | bytes |
|---|---:|
| Cobertura de `Bash`: «¿ve el guardián una escritura hecha por `node script.mjs`?» + por qué ensancharlo produce falsos positivos | **269** |
| `Archivos:` decorado: «¿qué responde `tools/arnes-paralelo.sh`…?» + por qué un `disjunto` no autoriza | **243** |
| Modelo del `qa-tester`: por qué se fija con el parámetro `model` y no editando `agents/qa-tester.md` | **161** |

**Rango 161–269 B; se usa el peor caso, 269 B.** Los dos primeros son punteros de **gobierno** —los que
tienen que nombrar una pregunta concreta y por eso son largos— y son 15 de los 26.

**Coste de punteros: 26 × 269 B = 6 994 B** (`AGENTS.md` 3 497 B, README 3 497 B).

### 1.3 Lo que `CA-10` añade: nada, y va dicho

`CA-10` regula el texto **añadido** —punteros y resúmenes— pero **no obliga a ningún resumen**: una
sección cuyo cuerpo se delega entero cumple `CA-04` con su encabezado y `CA-03`/`CA-12` con su puntero.
Por eso el presupuesto de arriba **no reserva bytes de resumen**. Un reparto que decida resumir los
paga **de su propio margen** contra el techo, y cada frase de resumen tiene que señalar la frase de la
línea base cuya obligación reproduce.

---

## 2. Tamaño resultante y techo propuesto

| | base | suelo medido | punteros | **resultante** | razón | **techo propuesto** |
|---|---:|---:|---:|---:|---:|:---:|
| `AGENTS.md` | 33 827 | 27 730 | 3 497 | **31 227** | 0,923× | **≤ 0,93×** |
| `requirements/README.md` | 40 767 | 32 682 | 3 497 | **36 179** | 0,888× | **≤ 0,89×** |
| **total** | **74 594** | **60 412** | **6 994** | **67 406** | 0,904× | **≤ 0,91×** |

**Se escribe como techo, nunca como igualdad**, y es **operativo en la dirección de bajar**
(`REQ-012 CA-03`): medir **menos** es conforme y no es hallazgo; subirlo exige firma del propietario y
entrada de Historial, igual que hoy. Un reparto que concentre destinos y comparta un puntero entre
varias preguntas de la misma sección se acerca al extremo optimista de §4; el techo se propone sobre el
**peor caso** porque un techo que sólo se cumple en el mejor no es un techo.

---

## 3. El resultado como lo pidió el propietario: reducción de BYTES DE LECTURA OBLIGATORIA

**De 74 594 B se baja a 67 406 B: −7 188 B de lectura obligatoria por comisión** (−9,6 %), repartidos
en −2 600 B en `AGENTS.md` y −4 588 B en `requirements/README.md`.

**No se traduce a tokens y no se llama ahorro de tokens.** Bytes es la magnitud contratada en `CA-07`
porque es la que se puede medir sin tokenizador; la conversión no está medida en este proyecto y el
propietario la prohíbe expresamente en este entregable.

**Y el dato que hay que ver junto al anterior: los punteros se comen el 49 % de lo que sale.** Se
delegan 14 182 B de texto (6 097 en `AGENTS.md`, 8 085 en el README) y se añaden 6 994 B de punteros
obligatorios. En `AGENTS.md` la proporción es peor —3 497 B de punteros contra 6 097 B delegados, el
**57 %**—, porque su texto delegable está **repartido en siete secciones** y cada sección paga sus
propios punteros. Es la diferencia estructural con el README, donde lo delegable está concentrado.

---

## 4. Parada declarada: el resultante supera el `0,82×` estimado, y por qué

La medición de F1 declaró su suelo **cota inferior** y estimó los punteros en «≈700 B en `AGENTS.md`,
≈400 B en el README», con lo que anticipaba un techo satisfacible de **≈0,82×**. Con los punteros
**derivados** en vez de estimados el número es **≤0,91×** total. La diferencia no es un error de
aritmética: aquella estimación contaba punteros con el grano de **`CA-03`** (uno por destino, 11) y
tamaños de ~120–200 B, y el grano que manda es el de **`CA-12`** (uno por bloque de gobierno, 26) con
un peor caso medido de **269 B**. Los dos extremos, para que el propietario vea la horquilla:

| Escenario | punteros | resultante total | techo | reducción |
|---|---:|---:|:---:|---:|
| Optimista (grano `CA-03`, puntero corto de 161 B) | 11 | 62 183 | ≤ 0,84× | −12 411 B |
| **Peor caso (grano `CA-12`, puntero de 269 B)** | **26** | **67 406** | **≤ 0,91×** | **−7 188 B** |

**Y la información de rentabilidad, que es para decidir y no para resolver aquí:** el `## Índice` del
README pesa **7 867 B**, está **fuera de alcance de este REQ**, tiene otro dueño y su conversión en
bloque derivado entre marcadores **no necesita repartir nada ni añadir un solo puntero**. Es decir:
**un cambio mecánico fuera de este REQ retira más bytes de lectura obligatoria (≈7 800) que el reparto
completo de los DOS documentos en el peor caso (7 188)**, y el reparto cuesta 7–11 h, mueve 38 bloques
—15 de ellos de gobierno— y necesita antes el inventario de `CA-15`, que todavía no existe en disco.
Esto no propone cambiar el alcance: el propietario ya decidió mantenerlo. Lo que hace es dejar el
coste y la alternativa escritos al lado del número que se firma.

---

## 5. Límite declarado — esta tabla NO acredita la no-pérdida

**La tabla por sección de la que salen estas cifras no sustituye al inventario por bloques de
`CA-15`.** `CA-15` exige *«un inventario de invariantes … artefacto escrito, **una fila por elemento**,
anexado a `ADR-003` … que es su **sitio único**»*, con **una fila por elemento**, su **cardinalidad
medida**, su **campo de ejecutor** (`CA-17`) y **doble enumeración independiente** (`CA-15.2`). Nada de
eso existe hoy en disco: las dos enumeraciones de F1 (**106** y **164** elementos) se entregaron **por
informe** y **no sobreviven**.

Lo que esta tabla sirve para hacer es **dimensionar** el reparto y **proponer** un techo. Lo que **no**
puede hacer es acreditar que ninguna regla se perdió: agrega por sección, y una invariante se pierde
por **bloque**. Si alguien la toma por el inventario, el reparto se ejecutará **sin la red que `CA-15`
exige**, que es exactamente el modo de fallo que `CA-15.4` prohíbe por escrito —«se revisó con cuidado
y no falta nada» no es evidencia admisible—.

**Antes de F2 sigue haciendo falta, sin excepción:** el inventario cerrado y publicado, con
cardinalidad cuadrada y ejecutores resueltos, por **dos enumeraciones independientes** de las que **una
no puede ser de quien reparte**.

---

## 6. Qué quedó sin medir

- **`CA-07` (i) por encargo.** Todo lo de arriba es la magnitud **por documento** —`CA-07` (ii)—. El
  peso de lectura obligatoria **por encargo**, que incluye los archivos de destino que ese encargo
  obliga a leer **antes de su primera acción**, no se midió. Sospecha registrada y **no verificada**:
  «Cómo se escribe un criterio que no se desmiente» lo necesita **E-A** antes de actuar, así que su
  destino puede seguir siendo obligatorio para E-A y no bajarle (i) nada aunque baje (ii).
- **`CA-07` (iii)**, documentos obligatorios añadidos por encargo: no se midió; depende del reparto,
  que no existe.
- **El número de destinos y su reparto concreto.** El conteo de punteros supone **un destino por
  sección de origen** en el extremo optimista y **uno por pregunta** en el peor caso. El reparto real
  —que fija la tabla de decisión de `CA-13`— puede caer en cualquier punto de esa horquilla.
- **La brecha entre el suelo en líneas de F1 (≈0,70× / ≈0,66×) y el suelo en bytes (0,820× / 0,802×)**
  sigue sin reconciliar, y no se puede: las listas de F1 no están en disco.
- **Ninguna medición de reloj**, por acuerdo: otra comisión está cronometrando en paralelo.

---

## Anexo — los 38 bloques delegados, que es de donde sale el conteo de punteros

**Por qué está aquí y no en un archivo aparte.** La regla del propietario obliga a que toda evidencia
necesaria para un trabajo posterior **quede en disco** antes de entregar, y esta comisión sólo tiene
autorización para escribir **este** archivo. La tabla **por sección** (base / delegable / suelo) ya
está en `requirements/REQ-019.md` §«El suelo forzado MEDIDO EN BYTES» del commit `d6620ea`; lo que no
estaba en ninguna parte es **qué bloques** componen la columna «delegable», que es lo que fija el
conteo de `CA-12`. Con esta lista la clasificación entera es reconstruible: **todo bloque que no
aparezca aquí es suelo**.

**Método de la lista.** Recorrido de cada documento partiendo por líneas en blanco (el grano de bloque
de `CA-01`: párrafo, fila o viñeta), bytes con `LC_ALL=C` —bytes, no caracteres—, y clasificación con
el filtro de §«El criterio: qué se queda y qué se va» y su predicción registrada. «del.» son los bytes
que salen del bloque; cuando es menor que el bloque, lo que sale es su **casuística o su historia** y
el enunciado se queda (`CA-14`). «G» = enuncia o acota gobierno (`CA-12` i, pregunta propia);
«N» = narrativo (`CA-12` ii, agrupa por sección).

### `AGENTS.md` — 18 bloques, 6 097 B delegados, 13 preguntas

| Sección | del. | G/N | Bloque |
|---|---:|:---:|---|
| preámbulo | 230 | N | Nota de estándar cross-tool |
| §1 | 384 | N | Párrafo descriptivo del proyecto |
| §1 | 371 | **G** | Autoalojamiento (sede en `docs/gobernanza/autoalojamiento.md`) |
| §5 | 207 | N | Párrafo introductorio |
| §5 | 200 | N | Justificación del bloque «la coordinadora no edita código» |
| §5 | 77 | N | Nota de asignación de modelo |
| §5 | 400 | N | Justificación del candado QA-Opus («cómo se aplica, y por qué así») |
| §6 | 500 | N | Historia del candado de política de autoalojamiento |
| §6 | 250 | N | Historia medida del ciclo 2 en el despacho paralelo |
| §6 | 450 | **G** | Casuística de `SEC-020`: el marcado elemento por elemento |
| §6 | 328 | N | Observabilidad (descriptivo, con punteros) |
| §7 | 100 | N | Nota «(por defecto, para stack Node/TS)» |
| §9 | 200 | N | Justificación dentro de las cinco reglas de cambio |
| §13 | 200 | N | Historia medida de «la invariante manda sobre la preferencia» |
| §13 | 900 | **G** | Casuística de cobertura de `Bash`: las formas que el detector no ve |
| §13 | 450 | **G** | Mecánica de la rotación |
| §13 | 700 | **G** | Mecánica de la continuidad |
| §13 | 150 | **G** | Nota del prefijo estricto en `agentes.agente_codigo` |

### `requirements/README.md` — 20 bloques, 8 085 B delegados, 13 preguntas

| Sección | del. | G/N | Bloque |
|---|---:|:---:|---|
| preámbulo | 162 | N | Párrafo descriptivo |
| Veredictos | 200 | N | Justificación dentro del vocabulario de `QA:`/`Seguridad:` |
| `Archivos:` | 92 | **G** | Bloque de ejemplo del campo |
| `Archivos:` | 700 | N | Historia de `SEC-014` en el paréntesis de evidencia |
| `Archivos:` | 400 | N | Justificación de «la propiedad con sus dos caras» |
| Criterio | 725 | N | «Medido, no opinado» (anécdota de entrada) |
| Criterio (a) | 321 | N | Caso medido |
| Criterio (a) | 347 | **G** | Par Mal/Bien |
| Criterio (b) | 297 | N | Caso medido |
| Criterio (b) | 208 | **G** | Par Mal/Bien |
| Criterio (c) | 215 | N | Caso medido |
| Criterio (c) | 245 | **G** | Par Mal/Bien |
| Criterio (d) | 789 | N | Caso medido |
| Criterio (d) | 515 | **G** | Par Mal/Bien |
| Criterio | 390 | N | «La forma (a) en pequeño, con su caso medido» |
| Criterio | 290 | N | «De dónde sale» (historia) |
| Criterio | 332 | **G** | Alcance temporal de la regla |
| Criterio | 211 | **G** | El mismo alcance temporal para la forma (d) |
| Criterio | 649 | **G** | Nota de adopción por versión (1.32.0) |
| Plantilla | 997 | **G** | Bloque de la plantilla del REQ |

**Cuadre del conteo:** `AGENTS.md` 6 G + 12 N en 7 secciones = **13**; README 9 G + 11 N en 4 secciones
= **13**. Total **26** preguntas → 26 punteros × 269 B = **6 994 B**.
