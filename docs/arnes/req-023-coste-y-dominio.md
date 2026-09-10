# REQ-023 — evidencia medida: el dominio derivado y las tres vías de coste

> Escrito por el `desarrollador` el **2026-09-09** al implementar REQ-023. Existe porque
> `REQ-024`, la QA de este REQ y la auditoría van a necesitar estos números, y una cifra que
> sólo vive en una conversación de despacho se vuelve a derivar cada vez (regla del
> propietario). Cada bloque lleva **método**, **versión base** y **lo que NO acredita**.

- **Árbol medido:** `rel/registro-1.33.0` @ `4f647c7` + las escrituras de REQ-023 en
  `hooks/lib.sh`, `hooks/guard-completado.sh` y `tools/arnes-lectura.sh`.
- **Línea base:** tag **`v1.33.0`**, materializado con `git archive v1.33.0 hooks tools`.
  Verificado: `git diff v1.33.0 4f647c7 -- hooks tools` sólo toca `hooks/estado-derivado.sh`
  y `hooks/rotar-artefactos.sh` — **ni `lib.sh`, ni `guard-completado.sh`, ni
  `tools/arnes-lectura.sh`**, así que para el lector y la puerta el tag y `4f647c7` son el
  mismo árbol y las dos líneas base son intercambiables.
- **Plataforma:** `linux-gnu-x86_64-bash5.3`, `bash 5.3.9(1)`.
- **Instrumentos:** `tests/util/sonda-reloj.sh` y `tests/util/sonda-procesos.sh` (REQ-021),
  mínimo de k, r series, sujetos intercalados. Lo que la calibración de esas sondas **no**
  acredita está en `tests/util/README.md` (`QA-021-10`, `SEC-054`, abierto).

## 1. El DOMINIO derivado de CA-02: **5 de 6** campos, no 4

Método (el de `CA-02`, ejecutado contra `hooks/guard-completado.sh` real, `Write`, proyecto de
prueba con las quality gates en verde): por cada clave que el lector reconoce se compara el
veredicto con el campo declarado **en el valor que más restringe** contra el veredicto con el
campo **ausente**; el campo pertenece a la clase si el segundo **abre**.

| Campo | Valor más restrictivo | Declarado | Ausente | ¿En la clase? |
|---|---|---|---|---|
| `QA` | `pendiente` | deny | **allow** | **sí** |
| `Seguridad` | `pendiente` | deny | deny | no |
| `Sensible a seguridad` | `sí` | deny | **allow** | **sí** |
| `Hallazgos abiertos` | `SEC-999 (contrato)` | deny | **allow** | **sí** |
| `Rigor` | `critico` | deny | **allow** | **sí** |
| `Estado` | `completado` | deny | **allow** | **sí** |

**5 de 6.** `R-013 §2` midió **4 de 6**; el quinto es **`Estado`**, y no es una discrepancia
de medida: es la clave que el puntero falso de `CA-01` dejaba fuera (Historial de REQ-023,
2026-09-09). Su ausencia abre porque un `Estado` que no se lee es «aquí no hay transición», y
entonces la puerta no evalúa nada — el documento queda diciendo `completado` sin que ninguna
puerta lo haya medido. Es una cifra que **sube** con cada campo nuevo del lector y que
**REQ-024 existe para bajar**.

Y sobre los 5: con un BOM delante de la clave, `v1.33.0` responde **allow** en los cinco y el
árbol con la guarda responde **deny** en los cinco, con el motivo de **medibilidad** (no «el
campo falta»). Verificado uno a uno.

## 2. CA-09 (i) — procesos por evaluación: **0 añadidos**

`tests/util/sonda-procesos.sh --sujeto "bash <dir>/guard-completado.sh < entrada.json"`,
misma entrada (`Write` que cierra un REQ `critico` con todo en verde):

| Árbol | `estado` | `cuenta` (procesos del sujeto) |
|---|---|---|
| `4f647c7` + REQ-023 | ok | **5** |
| `v1.33.0` | ok | **5** |

**Delta = 0.** Y por construcción: la guarda son dos expansiones de parámetro, un `case` y
una llamada a `arnes_en_vocab`, todo builtins.

*Lo que no acredita:* que el sujeto sea la única ruta de evaluación. Mide la ruta `Write`.

## 3. CA-09 (iii) — cociente de duplicación, con su PAR de longitudes

Sujeto: una línea de cabecera de tipo **título** (clave larga y con bytes ajenos, que es el
camino **lento** de la guarda: el que limpia y compara). `--k 200 --r 3`, mínimo de k.
Par publicado: **1000 → 2000 bytes** (la longitud menor es la primera a la que el mínimo de k
supera el suelo de ruido de 50 ms).

| Función | 1000 B | 2000 B | cociente | techo |
|---|---:|---:|---:|---:|
| `arnes_norm_clave` (donde reside la guarda) | 279.118 µs | 585.567 µs | **2,098** | 2,2 |
| `arnes_campo_linea` (donde reside la publicación) | 311.837 µs | 639.336 µs | **2,050** | 2,2 |
| `arnes_norm_clave` en `v1.33.0` (sin guarda) | — | — | 2,047 | — |
| `arnes_campo_linea` en `v1.33.0` (sin guarda) | — | — | 2,111 | — |

La guarda **no cambia el orden de crecimiento**: el cociente con y sin ella es el mismo dentro
del ruido. Margen contra el techo: **0,10** y **0,15** — sigue siendo **estrecho**, como el
contrato ya declaraba.

### 3.1. La primera versión de esta guarda NO cumplía su propio techo, y el criterio la cazó

Es la parte que hay que llevarse: la limpieza es `${clave//[!alfabeto]/}`, y **en un locale
UTF-8 esa sustitución es superlineal**. Medido sobre el mismo sujeto, aislando el primitivo:

| Primitivo | 1000 B | 2000 B | 4000 B | 2/1 | 4/2 |
|---|---:|---:|---:|---:|---:|
| `${#s}` (suelo del instrumento) | 4.658 | 7.809 | 14.260 | 1,68 | 1,83 |
| `${s//[!alfa]/}` en `C.UTF-8` | 564.417 | 2.135.661 | 11.930.426 | **3,78** | **5,59** |
| `${s//[!alfa]/}` con `LC_ALL=C` | 33.344 | 59.681 | 120.052 | **1,79** | **2,01** |
| troceado de 64 con `LC_ALL=C` | 12.540 | 16.353 | 24.903 | 1,30 | 1,52 |

Con la versión UTF-8 el cociente de `arnes_norm_clave` salía **5,053** contra el techo de 2,2
y la razón por función **2,50–5,82**. Fijar `LC_ALL=C` **dentro** de la función de la guarda
—`_arnes_clave_oculta`, con `local`, para no mover ninguna tolerancia fuera— la deja lineal y
además **17× más barata en absoluto**. El troceado de 64 es aún más barato y **no se
adoptó**: la versión simple ya cumple con margen y una sola expansión se audita de un vistazo.

*Lo que no acredita:* nada sobre otros pares de longitudes. Medir en otro par es conforme y
obliga a publicarlo.

## 4. CA-09 (ii) — la ruta crítica: **1,002×** contra un techo de 1,25×

`tests/util/sonda-reloj.sh --k 4 --r 6` con los **dos sujetos intercalados en la misma
invocación** (`--sujeto-a` el árbol con la guarda, `--sujeto-b` el de `v1.33.0`), sobre la
evaluación entera de la puerta:

```
estado=ok k=4 r=6 disp=1122
min_a=320122  (4f647c7 + REQ-023)
min_b=319340  (v1.33.0)
razon=1002    -> 1,002x   (techo 1,25x)
```

Registro completo de la sonda: `docs/arnes/req-023-registro-ruta-critica.txt`.

### 4.1. Las tres premisas de la cota algebraica, comprobadas — y una que NO se cumple entera

El contrato deriva `razón_ruta ≤ r` con tres premisas escritas para comprobarse:

1. **Guarda contenida en la función medida** — **se cumple a medias, y se dice.** La
   *detección* está contenida en `arnes_norm_clave` (que llama a `_arnes_clave_oculta`), pero
   la *publicación* vive en `arnes_campo_linea` y añade **una comparación de enteros por línea
   de cabecera** fuera de la función medida, más una llamada a `arnes_en_vocab` por línea en
   `arnes_campos_req` (la pertenencia de CA-06). No es un **interruptor por llamador** —la
   función hace lo mismo para todos—, así que la cota no se rompe por reparto; pero deja de
   ser exacta. Por eso `(ii)` **se mide** y no se apoya sólo en la cota.
2. **`r` medido a longitudes de cabecera real** — sí: 1000 y 2000 bytes, y también a la
   longitud de una cabecera de REQ real dentro de la medición de la ruta crítica.
   `r` medido: **1,111–1,153** (la cata había obtenido ≈1,17).
3. **Ninguna llamada añadida al camino** — **no se cumple literalmente**: se añaden dos
   (`_arnes_clave_oculta` desde `arnes_norm_clave`, `arnes_en_vocab` desde `arnes_campos_req`).
   Las dos son builtins de bash sin proceso, y la medición de `(ii)` las incluye.

Con `r ≤ 1,153` la cota daría `razón_ruta ≤ 1,153 < 1,25`; la medición directa da **1,002×**.

*Lo que no acredita:* «la ruta crítica del banco» aquí es **la evaluación de la puerta**, no
el reloj de una corrida entera del banco. Esa segunda magnitud **no está medida**.

## 5. CA-04 — la equivalencia con la versión heredada: **0 divergencias**

Método: dos evaluadores que cargan `hooks/lib.sh` de cada árbol y vuelcan, para el **mismo**
corpus, lo que el lector resuelve.

- **Campo a campo:** cada línea de `tests/escenarios/hooks/secciones/*.sh` **y** de
  `requirements/*.md` — **23.707 líneas**, de las que **4.082 declaran campo** — pasada por
  `arnes_campo_linea`, volcando `ARNES_CLAVE`, `ARNES_VALOR` y `ARNES_CLAVE_DECORADA`.
  Resultado: **idéntico byte a byte** (`md5` coincidente) entre `4f647c7+REQ-023` y `v1.33.0`.
- **Decisión a decisión:** los **27** REQ de `requirements/` pasados por `arnes_campos_req` +
  `arnes_estado_cabecera`, volcando los cinco campos, el estado, el estado citado, el rango
  abierto, el CR interior, la sensibilidad efectiva, el rigor efectivo y `SENS_DUDOSA`.
  Resultado: **0 documentos difieren**.

**Anti-vacuidad de CA-04, medida** (suelo: no menos de uno de cada):

| Corpus | líneas con campo | clave no ASCII | valor no ASCII | clave decorada |
|---|---:|---:|---:|---:|
| secciones del banco + `requirements/` | 4.082 | 1.329 | 1.528 | 2.476 |
| **sólo** secciones del banco | 1.954 | **135** | **264** | **827** |

Los tres suelos se cumplen **con el corpus que ya existe**, así que **no hizo falta aportar
ningún fixture nuevo** por la vía conforme que CA-04 dejaba escrita.

## 6. CA-05 — invariancia al locale: idéntico

La misma entrada (`Write` con un BOM delante de `Sensible a seguridad:`) por
`hooks/guard-completado.sh` bajo `LC_ALL=C.UTF-8` y bajo `LC_ALL=C`: la salida JSON completa
—veredicto **y** motivo, incluida la representación en hexadecimal— es **idéntica**
(`md5 24cb1210d019f97009fa58cad8606d95` en las dos). Por construcción, además: la
clasificación y la representación ocurren con `LC_ALL=C` fijado con `local`, así que no hay
nada que decodificar y no hay rangos sujetos a colación.

## 7. Fail-before / pass-after, medido a mano contra `4f647c7`

`ARNES_HOOKS_DIR` no hace falta: se invoca directamente el `guard-completado.sh` de cada
árbol con la misma entrada y el mismo proyecto de prueba.

| Caso | `4f647c7` | con REQ-023 |
|---|---|---|
| **SEC-047 fila 1**: BOM + `Sensible a seguridad: sí`, `Rigor: ligero`, QA y Seguridad `pendiente` | **allow** | **deny** (medibilidad) |
| **SEC-047 fila 2**: U+200B + `Hallazgos abiertos: SEC-999 (contrato)` | **allow** | **deny** (medibilidad) |
| Control negativo: la misma cabecera **sin** el carácter | deny (motivo propio) | deny (**mismo** motivo) |
| Control positivo: todo en verde y sin carácter | allow | **allow** |
| Todo en verde **+** BOM en `QA:` | allow | **deny** (es medibilidad, no veredicto) |
| Invisible (`\xc3`) sobre la clave del **`Estado`** | allow | **deny** |
| `CA-11`: campo comentado **sin espacio** (`<!--Rigor: ligero-->`) | allow | **allow** (la guarda no dispara) |
| `Módulo:` y `Versión destino:` en la cabecera | allow | **allow** (la guarda calla) |

## 8. Lo que quedó SIN MEDIR, y ningún criterio de arriba lo cubre

- **El fail-before DENTRO del banco, materializando `hooks/` desde un tag** (`CA-08`): no
  implementado. Su precondición es el gate humano de **`SEC-048`**, que sigue **abierto**
  (`docs/seguridad/registro-seguridad.md:3689`). Los casos existen y pasan contra este árbol;
  el fail-before es el de la tabla de §7, **medido a mano y reproducible**, no automático.
- **El reloj de una corrida ENTERA del banco** con y sin la guarda (la otra lectura posible de
  `CA-09 (ii)`).
- **La vía del homóglifo** (`Е` cirílico): fuera de alcance por contrato, ventana 1.35.0.
- **El NUL y el UTF-16**: fuera de alcance por contrato, ventana 1.35.0. El silencio de esta
  guarda ante un NUL **no acredita** nada.
