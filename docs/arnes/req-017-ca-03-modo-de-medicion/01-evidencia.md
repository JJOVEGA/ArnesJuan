# Evidencia — fail-before de REQ-017 CA-03
Versión base: rama `rel/registro-1.33.0`, HEAD `5305de9` (el árbol de trabajo tiene WIP de
otras dos comisiones; NADA de lo medido aquí lo toca: el sujeto es el tag **v1.32.1**).
Sujeto: `git show v1.32.1:hooks/lib.sh` materializado en `her321/hooks/lib.sh` (110 767 B).
Máquina: WSL2, 12 núcleos, bash 5.3, `plataforma=linux-gnu-x86_64-bash5.3`.
Método: `probe.sh` replica LITERALMENTE la invocación de `mide37` (mismo `--prep`, mismo
`--sujeto`); `probe-int.sh` la misma carga con los dos sujetos INTERCALADOS en una sola
invocación (`--sujeto-a`/`--sujeto-b`). Cociente = min(2S)/min(S), en milésimas, igual que
la sección. Datos crudos: `medidas-idle.tsv`, `medidas-idle2.tsv`, `medidas-carga.tsv`,
`medidas-rr.tsv`.

## Corrección de hecho al diagnóstico de PENDING_APPROVAL.md D6 §2
D6 afirma: «Con `k=1` no hay mínimo que tomar: el "mínimo de la serie" ES la única muestra».
**Eso es falso, medido.** En `tests/util/sonda-reloj.sh` son DOS parámetros:
- `--k` = repeticiones del sujeto DENTRO de una serie (`sr_serie`, `:350`);
- `--r` = número de SERIES, y el estadístico publicado (`min`) es el mínimo SOBRE LAS r
  SERIES (`sr_minimo`, `:381-394`).

`mide37` pasa `--r 3` FIJO (`37/2:158`) en TODAS sus llamadas. Luego el fail-before con
`--k 1` sí toma un mínimo: el de **3** muestras — el mismo número de muestras que la
medición directa con `--k 20`. El estadístico NO estaba desactivado; lo que hay es un
número de muestras (3) que nunca se eligió por ningún criterio: es el DEFECTO de la sonda.
La medición de D6 (3,379× → 2,329×) es correcta; la explicación construida encima, no.

## Lo medido: subir `--k` NO mejora la reproducibilidad, la EMPEORA
Idle, N=5 por configuración (`medidas-idle.tsv`, `medidas-idle2.tsv`):

| `--k` | `--r` | coc min | coc max | spread | min de la serie corta |
|---|---|---|---|---|---|
| 1  | 3 | 3,441 | 5,015 | 45,7 % | 101 ms |
| 2  | 3 | 3,258 | 4,638 | 42,4 % | 211 ms |
| 3  | 3 | 3,302 | 4,214 | 27,6 % | 252 ms |
| 5  | 3 | 3,117 | 3,824 | 22,7 % | 403 ms |
| 8  | 3 | 3,674 | 4,035 |  9,8 % | 622 ms |
| 12 | 3 | 3,340 | 4,028 | 20,6 % | 1 148 ms |
| 20 | 3 | 3,278 | 3,980 | 21,4 % | 1 579 ms |

No es monótono: el 9,8 % de `k=8` no se sostiene (k=12 y k=20, con series 2× y 2,5× más
largas, vuelven al 21 %).

Bajo carga (12 quemadores en 12 núcleos), N=5 (`medidas-carga.tsv`):

| `--k` | `--r` | coc min | coc max | spread |
|---|---|---|---|---|
| 1  | 3  | 3,591 | 4,836 | 34,7 % |
| 1  | 15 | 3,293 | 4,184 | **27,1 %** |
| 8  | 3  | 3,266 | 5,207 | 59,4 % |
| 8  | 9  | 3,106 | 4,944 | 59,2 % |
| 20 | 3  | 3,104 | 5,514 | **77,6 %** |

Dirección clara y con mecanismo: una serie más larga tiene más probabilidad de contener una
preempción, y con sólo 3 series el mínimo no puede rescatarla. El lever del estadístico
«mínimo» es el NÚMERO DE MUESTRAS (`--r`), no la longitud de cada una (`--k`).
LIMITACIÓN de esta tabla: la carga (`carga=1,5 → 24`) subió a lo largo del lote, así que
`k=1 r=3` midió en el entorno más benigno. Se rehace intercalado y con carga en meseta
(`medidas-rr.tsv`) para que ninguna configuración vea un entorno privilegiado.

## Lo que NO se pudo reproducir
Ninguna de las 55 mediciones de este informe bajó de **3,104×** (techo 2,600×). El
**2,329×** del CI no se reproduce en esta máquina ni bajo carga: el runner del CI corre el
banco con `ARNES_JOBS=6` (`run.sh:70`) sobre `ubuntu-latest`, es decir 6 secciones a la vez
—varias de ellas midiendo— sobre 4 vCPU. Esa vecindad no la tengo.

## La tanda que decide: round-robin CONTROLADO, con `loadavg` fila a fila
`medidas-rr.tsv`. Las cinco configuraciones se intercalan **dentro de la misma ronda**, con
la carga ya en meseta (12 quemadores propios + el banco de otra comisión), de modo que
ninguna ve un entorno privilegiado. `carga` es el `loadavg` que **la propia sonda** publica
en cada invocación; rango de la tanda: **17,6 – 23,3**. N=5 por configuración.

| configuración | coc min | coc max | RANGO | coste medio | `carga` |
|---|---|---|---|---|---|
| bloque `k=1 r=3` (**la de hoy**) | **2,879** | 4,733 | **64,4 %** | 4,6 s | 17,6–23,3 |
| bloque `k=1 r=15` | 2,833 | 4,329 | 52,8 % | 21,1 s | 19,1–23,3 |
| bloque `k=2 r=9` | 3,650 | 4,524 | **23,9 %** | 26,1 s | 17,9–23,2 |
| bloque `k=8 r=3` | 3,625 | 5,437 | 50,0 % | 31,3 s | 21,0–22,6 |
| intercalado `k=2 r=9` | **3,961** | 4,688 | **18,4 %** | 23,0 s | 21,1–22,9 |

Tres lecturas, y la primera es la importante:
1. **La configuración de hoy es la PEOR de las cinco** (rango 64,4 %) y es la única que se
   acercó al techo: **2,879×** contra 2,600×, un margen del 11 %. Es el mismo mecanismo que
   el 2,329× del CI, reproducido aquí — bajo carga 21, no bajo carga de CI.
2. **Subir sólo `k` no basta y subir sólo `r` tampoco:** `k=8 r=3` da 50,0 % y `k=1 r=15`
   da 52,8 %. Lo que baja el rango a 23,9 % es **las dos cosas a la vez** — y con mecanismo:
   `k` sube el suelo de la serie corta (de ~180 ms a ~400 ms, así que una preempción pesa
   proporcionalmente menos) y `r` triplica las muestras sobre las que se toma el mínimo.
3. **Lo mejor medido es el modo INTERCALADO** (18,4 % y además más BARATO que su equivalente
   en bloque, 23,0 s contra 26,1 s: una invocación en vez de dos). Es lo que `REQ-021 CA-02
   punto 2` ya contrata para una razón, con su motivo medido (QA-017-06: 1,217 en bloque
   contra 1,012 intercalado). **No se aplica aquí** — ver «lo que NO hago y por qué».

## Cómo se elige `k` con el criterio declarado, y por qué NO es `k=2`
El criterio (A) declarado antes de medir pide `min` de cada serie ≥ 250 000 µs (5× el suelo).
Se juzga contra el mínimo **más bajo** observado, no contra el más alto: un mínimo más bajo
es la medición más limpia —la carga sólo puede subirlo—, así que es la cota que manda.

| `k` | mínimo más bajo observado de la serie corta | ¿(A)? |
|---|---|---|
| 1 | 101 ms (2,0× el suelo) | no |
| 2 | 211 ms (4,2× el suelo) | **no** |
| 3 | 252 ms (5,0× el suelo) | **sí** |
| 5 | 403 ms | sí (y ya cuesta el doble) |

Luego la escalera se detiene en **`k=3`**, no en `k=2`, aunque `k=2` fuera lo medido en el
round-robin. Se honra la declaración: es lo único que distingue elegir por criterio de
elegir por resultado. `r` se fija en **9** por (B) y por el presupuesto de coste.

## Limitaciones materiales, dichas enteras
1. **Las tablas «idle» NO registraron `loadavg`** (`medidas-idle.tsv`, `medidas-idle2.tsv`):
   la columna no existía cuando se tomaron. Las dos sondas suelta de justo antes dieron
   `carga=1,14` y `1,96`, y durante esa ventana pudo estar corriendo el banco de otra
   comisión. **No se descartan** —su dirección la corrobora la tanda con carga publicada—
   pero no valen como cifra atribuible. Las tablas con `carga` son `medidas-carga.tsv`,
   `medidas-rr.tsv` y `medidas-rr2.tsv`.
2. **Esta máquina no es el juez.** El CI corre el banco con `ARNES_JOBS=6` (`run.sh:70`)
   sobre `ubuntu-latest`, y la coordinadora lo midió ~17× más limpio que esta máquina hoy.
   Ninguna de mis 70 mediciones bajó de 2,833×: el **2,329×** del CI **no se reproduce
   aquí**. Lo que sí se reproduce es la **anchura** que lo hace posible.
3. El primer lote bajo carga (`medidas-carga.tsv`) tiene la carga subiendo de 1,5 a 24 a lo
   largo del lote, así que sus configuraciones no son comparables entre sí. Por eso existe
   el round-robin, y por eso el round-robin es el que decide.

## La tanda que INVIERTE el remedio prescrito: `medidas-rr2.tsv`
Segundo round-robin, **sin quemadores propios** (carga real de la máquina, que bajó al
terminar el banco de la otra comisión). `carga` fila a fila, rango **3,42 – 7,11**. N=5.

| configuración | coc min | coc max | RANGO | coste medio | `carga` |
|---|---|---|---|---|---|
| bloque `k=1 r=3` (**la de hoy**) | 3,974 | 4,503 | **13,3 %** | 1,5 s | 3,42–7,11 |
| bloque `k=3 r=9` (la que elige el criterio (A)) | 3,357 | 5,572 | **66,0 %** | 13,4 s | 3,42–6,70 |
| intercalado `k=3 r=9` | 3,905 | 4,272 | **9,4 %** | 13,3 s | 3,58–6,24 |

**Esto invierte el remedio prescrito.** Con la máquina tranquila, la configuración de hoy es
la MEJOR de las tres en bloque (13,3 %) y la que el criterio (A) selecciona es la PEOR
(66,0 %), por una sola ronda —la 2— en la que el NUMERADOR se infló (min₂ 1,27 s contra
0,92–1,10 s en las otras cuatro). Y es la misma clase de suceso que en la otra tanda infló
el denominador: en bloque, **cuál de las dos invocaciones pilla al vecino es una moneda**.

Cruzando las dos tandas, la única configuración que es la más estrecha en LAS DOS cargas es
el **modo intercalado**: 18,4 % con carga 21 y 9,4 % con carga 5. Es también la más barata
por muestra (una invocación en vez de dos).

## Conclusión de la medición
1. **`k=1` no es el defecto**, y subirla no es el remedio: no hay dirección estable en `k`
   ni en `r`, porque la dispersión no la produce el número de muestras sino el hecho de que
   los dos términos se midan en **dos invocaciones separadas en el tiempo**. Alargarlas —que
   es lo que hacen `k` y `r`— las separa más.
2. Por eso **NO se cambia la configuración de la medición**: enviar `k=3 r=9` habría sido
   enviar una regresión medida (66,0 % contra 13,3 %) por 12 s más de CI.
3. Lo que sí se arregla es lo que impidió atribuir el rojo: el caso **publica ahora** `k`,
   las series y, de cada término, su mínimo **y su máximo**; y tiene **un solo nombre** en
   sus cinco ramas.
4. El remedio medido es el **modo intercalado**, y no se aplica porque cambia el
   INSTRUMENTO: el fail-before dejaría de acreditar «el mismo cociente» que la medición
   directa. Mover las DOS mediciones a intercalado es decisión del analista/coordinador.

## Verificación del cambio: sección 37/2 AISLADA, 5 corridas
`bash tests/escenarios/hooks/run.sh secciones/37-coste-del-escaner-2-las-razones.sh`
(**no** el banco entero: otra comisión tiene el árbol a medio editar y se mediría su WIP).
`loadavg` antes de cada corrida: 1,44 · 1,61 · 1,54 · 1,46 · 1,39. `rc=0` las cinco, 5 PASS
y 0 FAIL en las cinco, cuadre de la sección cerrado.

| corrida | cociente | k | series | 70 000 B min/max (µs) | 140 000 B min/max (µs) |
|---|---|---|---|---|---|
| 1 | 4,140× | 1 | 3 | 91 567 / 101 286 | 379 090 / 428 564 |
| 2 | 3,958× | 1 | 3 | 77 916 / 85 589  | 308 402 / 322 939 |
| 3 | 3,819× | 1 | 3 | 79 614 / 87 258  | 304 094 / 316 459 |
| 4 | 3,987× | 1 | 3 | 77 526 / 87 269  | 309 123 / 346 907 |
| 5 | 4,150× | 1 | 3 | 76 752 / 79 290  | 318 555 / 406 425 |

Rango del cociente **8,7 %** (3,819–4,150) con `loadavg` 1,4–1,6, contra un techo de 2,600×:
margen mínimo **47 %**. Y la medición directa de CA-03 en las mismas cinco: 1,949 · 1,910 ·
2,072 · 1,930 · 1,822 (techo 2,600×).

## Control de ANTI-VACUIDAD: el caso sigue discriminando
El **mismo par de sondas con k=1** contra el árbol **SANO** (`hooks/lib.sh` de este árbol),
3 corridas: 70 000 B min = 4 354 / 4 429 / 4 519 µs y 140 000 B min = 10 097 / 8 809 / 8 655 µs.
Dos veces separa: (a) las series **no cruzan** el suelo de 50 ms, así que el caso diría
**SKIP y nunca PASS**; y (b) aun cruzándolo, el cociente sería **2,319 / 1,989 / 1,915×**,
por **debajo** del techo 2,600×, es decir **FAIL**. El árbol enfermo cuesta ~20-35× por
llamada y su cociente es ~4. El caso no es vacuo.

## Delta del inventario (`inventario.sh`), declarado
Las 5 corridas dan un inventario **idéntico byte a byte** entre sí: el oráculo normaliza a
`N` también las cifras nuevas (`k=N series=N · NB min=Nµs max=Nµs`). Y el caso cambia de
**nombre**, a propósito y en una sola dirección: antes PASS y FAIL llevaban el número
DENTRO del nombre y **cada rama nombraba un caso distinto**, así que un PASS que se volvía
FAIL se leía como un caso que desaparece y otro que nace — exactamente lo que CA-02 existe
para detectar. Ahora las cinco ramas comparten el nombre que ya usaban los dos SKIP:
`REQ-017 CA-03 fail-before: la sonda distingue el árbol cuadrático`.

## 6.ª corrida, tras el último retoque del comentario
`loadavg` 1,4. `rc=0`, 5 PASS / 0 FAIL. Fail-before **3,889×**, `k=1 series=3`,
70 000 B min/max 78 937 / 79 989 µs, 140 000 B min/max 307 041 / 349 662 µs.
Las **seis** corridas del caso: 4,140 · 3,958 · 3,819 · 3,987 · 4,150 · 3,889 →
rango **8,7 %**, todas PASS, margen mínimo sobre el techo 2,600× del **47 %**.

## Lo que NO se hace, y por qué (para que no se lea como olvido)
1. **No se cambia ningún umbral.** El techo sigue en 2,600× y el suelo en 50 ms.
2. **No se retira ni se hace opcional ningún caso.** Los 5 casos de la sección siguen
   corriendo siempre; `CASOS_ESPERADOS_SECCION` sigue en 5.
3. **No se toca `hooks/`, `tools/`, `run.sh`, la sonda, `.arnes/` ni ninguna plantilla.**
4. **No se edita `requirements/REQ-017.md`.** Ningún criterio cambia: CA-03 constriñe `k`
   sólo por el suelo, y `k=1` **cumple** ese suelo (77-392 ms, entre 1,5× y 7,8× los 50 ms),
   así que no hay incumplimiento que reflejar ni contrato que mover. Lo que cambia es la
   EVIDENCIA que el caso publica y su NOMBRE, que CA-03 no menciona. Y el REQ está
   `completado`: escribirle una fila del Historial sin reabrirlo sería la edición silenciosa
   que §9 prohíbe, y reabrirlo no es decisión de esta comisión.
5. **No se toca `razon37`**, así que la medición directa de CA-03 y los cuatro casos de
   CA-04 quedan byte a byte con el comportamiento de hoy. Su mensaje tiene la MISMA carencia
   (publica los dos mínimos, no los máximos); arreglarlo cambiaría cinco casos más y queda
   fuera del alcance de esta comisión.

## Rutas de la evidencia CRUDA (efímeras: hay que copiarlas si se quieren conservar)
`00-criterio-k-declarado-antes-de-medir.md` · `01-evidencia.md` · `02-diseno-del-arreglo.md`
`medidas-idle.tsv` (sin `carga`) · `medidas-idle2.tsv` (sin `carga`) · `medidas-carga.tsv`
`medidas-rr.tsv` · `medidas-rr2.tsv` · `corrida37-1..5.txt` · `inv37-1..5.txt`
`salida-ramas.txt` · `probe.sh` · `probe-int.sh` · `escalera.sh` · `bajo-carga.sh`
`round-robin.sh` · `round-robin2.sh`
Todas bajo `/tmp/claude-1000/-home-juan-dev-ArnesJuan/23a8ee5a-8587-4923-8f15-1fc9bf03aaf2/scratchpad/`.
