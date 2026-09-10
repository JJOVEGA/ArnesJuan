# REQ-024 · comisión del `desarrollador` — método, evidencia y techo de lo acreditado

**Versión base:** `ef82d43` (rama `rel/registro-1.33.0`), árbol limpio al empezar.
**Fecha:** 2026-09-09 · **Agente:** `desarrollador` (Opus, política de autoalojamiento).
**Máquina:** WSL2 Linux 6.18.33.2, `bash` 5.3.9, `jq` 1.8.2, GNU awk 5.3.2.
**Línea base heredada:** tag `v1.33.0` (la misma que usó REQ-023 en esta ventana).

Este archivo existe porque, sin él, QA, la auditoría y el write-back del analista tendrían que
**re-medir** para cumplir algo ya escrito (`AGENTS.md` §14.B.7). No es un informe: es el método
suficiente para re-derivar cada cifra sin preguntar.

---

## 0. Lo primero que se pidió: ¿pueden cumplirse los 11 criterios A LA VEZ?

Respuesta corta: **9 sí, 1 resuelve a su segunda salida contratada (y ésa NO es código), y 2 no
se pueden tocar en esta comisión por reserva de archivos.** Ninguna contradicción entre criterios
del propio REQ-024; la única tensión real es entre `CA-02` y `CA-03 (i)`, y **el REQ ya la
contrató** dejando dos salidas.

### 0.1 La tensión medida: `CA-02` (sitio único) contra `CA-03 (i)` (el puntero de REQ-016)

`CA-03 (i)` sólo se cumple si el **sitio único** de `CA-02` es el archivo que `REQ-016 CA-11`
nombra literalmente: `hooks/guard-completado.sh` («Qué campos perdona la ausencia lo decide **un
solo sitio**, `hooks/guard-completado.sh`, y ahí vive la lista exhaustiva»,
`requirements/REQ-016.md:152-153`).

`CA-02` exige además, por su propia nota de factibilidad, que la tabla sea **el sitio del que los
dos sitios de bash derivan** la dirección. Y aquí está el dato que decide, **medido leyendo el
árbol en `ef82d43`**: `hooks/lib.sh` lo cargan **siete** puntos de entrada y sólo **uno** de ellos
es `guard-completado.sh`.

```
grep -l '\. "\$DIR/lib\.sh"\|\. "\$DIR/\.\./hooks/lib\.sh"' hooks/*.sh tools/*.sh
```

| Punto de entrada | ¿carga `guard-completado.sh`? | ¿resuelve ausencia de campos? |
|---|---|---|
| `hooks/guard-completado.sh` | — (es él) | **sí** (la puerta) |
| `hooks/estado-derivado.sh` | no | sí (`arnes_campos_normaliza`) |
| `tools/arnes-lectura.sh` | no | sí (rigor efectivo del informe) |
| `tools/arnes-paralelo.sh` | no | no (sólo `Archivos:`) |
| `hooks/guard-codigo.sh` | no | no |
| `hooks/guard-git.sh` | no | no |
| `hooks/rotar-artefactos.sh` | no | no |

Una tabla que viviera en `hooks/guard-completado.sh` **no la vería** ninguno de los otros seis. En
los tres lectores que sí resuelven ausencia, la dirección caería a la conducta heredada mientras la
puerta aplicaría la nueva: el informe diría `estandar` donde la puerta dice `critico`. Eso es
exactamente la divergencia entre lectores que este repositorio persigue —y lo que
`CA-11 (ii)` vigila—.

**Conclusión, y no se resuelve eligiendo una lectura:** el sitio único tiene que ser
`hooks/lib.sh`, luego `CA-03` resuelve por su salida **(ii)** — «el sitio único es **otro**, y
entonces **REQ-016 vuelve a `en-progreso`**, su CA-11 se reescribe con el puntero real y el ciclo
se re-recorre». Esa salida **está contratada** y **no es trabajo de código**: `requirements/REQ-016.md`
no está en el `Archivos:` de REQ-024 a propósito, y el propio REQ ordena «**se para**, el REQ
afectado vuelve a `en-progreso`, el write-back va en un REQ propio … **No se hace “de paso”**».
Es, además, la remediación 1 de `SEC-050`, que ya estaba abierta con esta misma pregunta: no es un
hallazgo nuevo, es su respuesta.

Lo que esta comisión **sí** hace de `CA-03`: escribir su **control discriminante** en el banco —el
que enumera la lista siguiendo el puntero al pie de la letra y **nombra** los campos de la clase que
ese archivo no contiene, con su denominador—. El control mide la salida (ii) en vez de afirmarla.

### 0.2 Los dos criterios que la reserva de archivos deja fuera de esta comisión

| Criterio | Superficie que exige | Estado |
|---|---|---|
| `CA-04` — la fila del rigor deja de prometer sin condición | `AGENTS.md` §6/§13 **y** `templates/AGENTS.md.tpl` | **RESERVADOS**: comprometidos en el arreglo de `SEC-079` (dos comisiones vivas). Además el propio criterio declara **gate humano** en `PENDING_APPROVAL.md`, que esta comisión tampoco escribe |
| `CA-06` — la nota de migración | `skills/arnes-upgrade/SKILL.md` | **RESERVADO**, misma superficie heredada |

No se tocan, no se simulan y **no se acreditan**. No se escribe su caso de banco: un caso que mide
un texto que va a cambiar en la hora siguiente se escribiría dos veces, y un caso que abstiene no
acredita nada.

### 0.3 Los nueve que sí, y por qué cada uno es satisfacible junto a los demás

| Criterio | Satisfacible | Con qué, y contra qué otro criterio podría chocar |
|---|---|---|
| `CA-01` | sí | Dominio **M** derivado de `ARNES_CLAVES` (sitio único de REQ-023 CA-06), clase **N** derivada ejecutando las dos versiones. No choca con nada |
| `CA-02` | sí | Tabla `ARNES_AUSENCIA` en `hooks/lib.sh`, **derivada** de las constantes `ARNES_CLAVE_*`; los dos sitios de bash preguntan a `arnes_resuelve_ausencia`, que es el único que decide. Choca con `CA-03 (i)` → §0.1 |
| `CA-03` | sí, por **(ii)** | Ver §0.1. El control discriminante sí entra |
| `CA-05` | sí | Comparación de las dos versiones sobre el corpus de `requirements/` **con la llave apagada**. **Refuerza** a `CA-01` en vez de chocar: `CA-01` se enuncia sobre un proyecto activado y `CA-05` sobre uno que no |
| `CA-07 (i)` | sí, **cota verificada** | La llave de activación viaja **dentro de la llamada a `jq` que ya existe** en cada punto de entrada (`hooks/lib.sh:71`, `tools/arnes-lectura.sh:39`). **0 procesos añadidos**. La colisión que el REQ temía —«una llave de manifiesto cuesta un `jq`»— no se materializa porque el manifiesto **ya se lee entero en una sola invocación** y esa invocación corre **antes** de leer los campos (`hooks/guard-completado.sh:64` frente a `:230`) |
| `CA-07 (ii)` | sí, a medir | El sobrecoste queda contenido en `arnes_resuelve_ausencia` y en el lector de la cola |
| `CA-07 (iii)(iv)` | sí, **por construcción** | El lector de la cola sigue siendo **una pasada** y **no** se añade ningún recorrido de rango carácter a carácter: `CA-10` decide **mantener** el grano de línea, así que la forma cuadrática que el REQ señalaba no se introduce |
| `CA-08` | sí | La condición de salida ya existe en `arnes_cola_pendientes`; sólo no se alcanzaba |
| `CA-09` | sí | El `continue` de la rama de cierre pasa a consultar `enc`. Preserva `REQ-009 CA-07` y el conteo de la anotación cerrada en su línea (`CA-09 ii`, `CA-10`) |
| `CA-10` | sí | ADR que **mantiene** la frontera + caso de banco que mide la divergencia entre los dos lectores sobre la forma medida |
| `CA-11` | sí | (i) 0 transcripciones nuevas de la noción de comentario de la cola; (ii) ningún valor de campo se mueve; (iii) ningún artefacto afirma que la clase queda cerrada |

**Y una simultaneidad que el REQ marcó como «la trampa de esta comisión» y aquí queda cerrada:**
`CA-07 (iv)` + `CA-10` + `CA-11 (i)` sólo se cumplen a la vez si el arreglo de la cola **no**
llama a `arnes_sin_cita` (grano de rango) y **no** introduce indexación carácter a carácter. La
salida elegida es la tercera que el REQ describe, y en su forma más barata: **no hace falta ningún
recorrido de rango nuevo** —los dos defectos (`CA-08`, `CA-09`) se arreglan con el estado que el
bucle de una pasada ya lleva—.

---

## 1. Decisiones de arquitectura (fase 0), con su número estampado al crearlas

`ADR-006`, `ADR-007` y `ADR-008` estaban **ocupados** (`ADR-008` por REQ-026, verificado leyendo
`docs/decisions/` el 2026-09-09). Los dos ADR de este REQ toman el primer número libre:

| Papel | Archivo |
|---|---|
| **ADR de la dirección de la ausencia** | `docs/decisions/ADR-009-la-ausencia-de-un-campo-no-se-resuelve-del-lado-que-abre.md` |
| **ADR del grano de la cola** | `docs/decisions/ADR-010-el-grano-de-linea-de-la-cola-de-aprobaciones.md` |

---

## 2. Qué NO acredita esta comisión

1. **`CA-04` y `CA-06`**: sin tocar, sin caso y sin acreditar (§0.2).
2. **`CA-03`**: se acredita el **control** que mide la salida (ii); **no** se acredita que el
   puntero de REQ-016 haya quedado cierto. No lo está, y arreglarlo es del `analista-requerimientos`.
3. **El caso de banco de `REQ-023 CA-10`** (deuda enrutada): **no escrito**, por instrucción
   expresa de la coordinadora — su redacción de referencia está siendo reescrita ahora mismo por el
   arreglo de `SEC-079`, y un caso escrito contra un texto que va a cambiar se escribe dos veces.
4. **Ningún SKIP cuenta como criterio cumplido.** Las cifras de coste son de **esta** máquina y de
   **este** día; el juez de un umbral es el CI.

---

## 3. Qué se implementó, archivo por archivo

| Archivo | Qué cambia | Criterio |
|---|---|---|
| `hooks/lib.sh` | `ARNES_AUSENCIA` (tabla derivada de `ARNES_CLAVE_*`), `arnes_ausencia`, `arnes_resuelve_ausencia`; `arnes_sens_efectiva` y `arnes_rigor_efectivo` pasan a **preguntar** en vez de decidir; `arnes_cola_pendientes` deja de contar un cierre huérfano y devuelve «no lo sé» con la línea de apertura; la llave viaja en la lectura de manifiesto que ya existía | CA-01, CA-02, CA-07 (i), CA-08, CA-09, CA-10 |
| `hooks/guard-completado.sh` | El `[ -n "$qa" ]` y el `hall` vacío pasan por el sitio único; motivo propio para el rango abierto de la cola (con su línea); motivo que **nombra el campo ausente** cuando el rigor llegó a `critico` por gobierno | CA-01, CA-02, CA-08 (i) |
| `tools/arnes-lectura.sh` | Mide la cola **antes** de afirmar nada; con la cola no medible **no** imprime «Ningún valor anómalo» y **sale ≠ 0**; lee la llave en su `jq` | CA-08 (iii), CA-02, CA-11 (ii) |
| `hooks/estado-derivado.sh` | **Desviación declarada**: un renglón para leer la llave en su `jq` | CA-07 (i), CA-11 (ii) |
| `.arnes/config.json`, `templates/arnes-config.json.tpl` | Bloque `campos` con `ausencia_exige: false` y su `_doc` (cómo se activa, qué cuesta, cómo medirlo **antes**) | ADR-009 |
| `tests/…/31-cola-una-sola-regla.sh` | 25 → **39** casos: bloque B entero | CA-08, CA-09, CA-10, CA-11 (i) |
| `tests/…/40-ausencia-que-abre-1-la-clase-derivada.sh` | **7** casos: M, N, clase vacía, sitio único por mutación, discriminante que nombra la clave | CA-01, CA-02 |
| `tests/…/40-ausencia-que-abre-2-migracion-y-punteros.sh` | **9** casos: puntero, radio de migración, las cuatro vías del coste, los cuatro lectores | CA-03, CA-05, CA-07, CA-11 (ii) |
| `tests/…/39-…-4-el-coste.sh` | Deuda enrutada: `REGHER94` se asigna (los SKIP publicaban un paréntesis vacío) | `instrumento`, preexistente |
| `tests/…/run.sh`, `tests/…/README.md` | Cuadre total 966 → **996**, con el reparto y su motivo | — |
| `docs/decisions/ADR-009…`, `ADR-010…` | Fase 0: la dirección de la ausencia y el grano de la cola | CA-01, CA-02, CA-10 |

## 4. `fail-before` / `pass-after`, por corrida entera y con el método

**Método** (reusa `docs/qa/1.34.0-req023-vuelta3-metodo.md` §0; sin `git stash`, `reset --hard`,
`clean -f`, `checkout .` ni `restore .`):

```
mkdir -p <tmp>/hb && git archive v1.33.0 hooks tools .claude-plugin | tar -x -C <tmp>/hb
ARNES_HOOKS_DIR=<tmp>/hb/hooks bash tests/escenarios/hooks/run.sh \
  secciones/31-cola-una-sola-regla.sh \
  secciones/40-ausencia-que-abre-1-la-clase-derivada.sh \
  secciones/40-ausencia-que-abre-2-migracion-y-punteros.sh     # fail-before
bash tests/escenarios/hooks/run.sh <las mismas tres>                                # pass-after
```

| | **fail-before** (hooks `v1.33.0`) | **pass-after** (este árbol) |
|---|---|---|
| las tres secciones | **44 PASS · 9 FAIL · 2 SKIP** | **55 PASS · 0 FAIL · 0 SKIP** |
| `CA-01` dominio M | **SKIP**: «M = 0 claves, no hay nada que medir» | **PASS**: M = 6, 1 `n/a`, 5 medidas, N = 4 |
| `CA-01` clase vacía | **SKIP** (no se pudo medir el dominio) | **PASS**: 0 de 5 abren |
| `CA-01` discriminante | **FAIL** (no hay contra qué discriminar) | **PASS**: `v1.33.0` abre en 4 de 5 |
| `CA-02` los dos sitios deniegan | **FAIL** (`ALLOW\|ALLOW`) | **PASS** (`DENY\|DENY`) |
| `CA-02` clave nueva sin dirección | **FAIL** (no la nombra) | **PASS** (nombra «Campo nuevo») |
| `CA-08` (i) motivo con la línea | **FAIL** (motivo vacío: ALLOW) | **PASS** («línea 2») |
| `CA-08` los tres canales | **FAIL** (`0\|0\|0`) | **PASS** (`sin datos` ×3) |
| `CA-08` (iii) el informe | **FAIL** (`rc=0`, y afirma «Ningún valor anómalo») | **PASS** (`rc=1`, no lo afirma) |
| `CA-09` la puerta cuenta 1 | **FAIL** (motivo vacío: ALLOW) | **PASS** |
| `CA-09` los tres lectores | **FAIL** (`0\|0\|0`) | **PASS** (`1\|1\|1`) |

**Los que NO tienen par `fail-before`, y se dice por qué en vez de disimularlo.** `CA-05`,
`CA-07` y `CA-11 (ii)` pasan en las **dos** corridas, y es **correcto por la forma del
criterio**: los tres contratan que **nada cambia** (compatibilidad, coste, valores), así que un
`fail-before` sería un criterio que se contradice. Su discriminante es otro y está dentro del
caso: el **denominador publicado** (`CA-05`: 31 REQ juzgados, 4 con omisión — con 0 abstiene) y
la **comparación contra la línea base en la misma corrida** (`CA-07 (i)`/`(ii)`, `CA-11 (ii)`).
`CA-03` sí cambia entre corridas —nombra **4 de 4** contra `v1.33.0` y **2 de 4** contra este
árbol, que es el número que `SEC-050` midió—, pero su verde **no acredita CA-03**: lo dice el
propio mensaje.

## 5. Cifras del banco entero y de la autoprueba (esta máquina, 2026-09-09)

```
bash tests/escenarios/hooks/run.sh            -> 988 PASS · 1 FAIL · 7 SKIP   (cuadre 996)
bash tests/escenarios/hooks/autoprueba-corredor.sh -> 106 PASS · 0 FAIL
for f in hooks/*.sh tools/*.sh; do bash -n "$f"; done   -> verde
jq -e . hooks/hooks.json .claude-plugin/plugin.json .claude-plugin/marketplace.json -> verde
```

**El único FAIL, con su nombre y su clase.** `REQ-023 CA-12 2 de 7 formas de la cola cambiaron
de conteo o de rc`. **No es un defecto de este REQ: es el conflicto que REQ-024 predijo
literalmente.** Su caso vive en
`tests/escenarios/hooks/secciones/39-caracter-invisible-3-los-lectores-y-el-coste.sh:284-297` y
compara el árbol **actual** contra `v1.33.0`, o sea implementa la afirmación **abierta** «la cola
nunca cambia su conteo», mientras su propio comentario (`:230-233`) y la redacción vigente de
`REQ-023 CA-12 (ii)` contratan una no-regresión **anclada a esa versión**. Las **2** formas que
cambian son exactamente las dos que ese comentario nombra:

| Forma del corpus | `v1.33.0` | este árbol | Criterio que lo cambia |
|---|---|---|---|
| `<!-- rango que abre y no cierra` + entrada | `0`, `rc=0` | vacío, `rc=1` | `REQ-024 CA-08` |
| `### Migrar A --> B` | `0`, `rc=0` | `1`, `rc=0` | `REQ-024 CA-09` |
| las otras **5** (incluidos `### Real <!-- nota -->` y el ejemplo comentado de la plantilla) | — | **idénticas** | `CA-09 (i)`/`(ii)`, `CA-10` |

Clase: **`contrato`, contra REQ-023**. Dueño: `analista-requerimientos` (write-back) y el
`qa-tester` de REQ-023 al verificar `CA-12 (ii)`. **No se resuelve desde aquí:** REQ-023 está
`bloqueado`, su caso lleva la firma de QA sobre ese árbol, y elegir una de las dos lecturas
—anclada u abierta— sería decidir por mi cuenta una pregunta de contrato ajena.

**Los 7 SKIP, con su lista y no con su total** (el recuento oscila con la carga; la lista no):

1. `ruta estilo Windows con backslashes -> deny` — sin `cygpath`: caso sólo de Windows.
2. `REQ-017 CA-05 (i)` — palanca apagada (`ARNES_COSTE_RUTA_CRITICA`).
3. `REQ-017 CA-05 (ii)` — la misma palanca.
4. `REQ-017 CA-08 (ii)` — el techo cae dentro del recorrido observado.
5. `REQ-021 CA-08 (iii)` — la mitad en procesos no es medible en ese instrumento.
6. `REQ-023 CA-09 (iii)` sobre `arnes_norm_clave` — dispersión ≥ margen.
7. `REQ-023 CA-09 (iii)` sobre `arnes_campo_linea` — dispersión ≥ margen.

**Ninguno de los 30 casos nuevos abstuvo** en ninguna de las dos vueltas completas.

## 6. Las cifras de coste, con su par y su estadístico

Todas **operativas** y de esta máquina; el juez de un umbral es el CI.

| Medida | Techo | Medido | Cómo |
|---|---|---|---|
| `CA-07 (i)` procesos por evaluación de la puerta | +0 | **2** contra **2** de `v1.33.0` | `tests/util/sonda-procesos.sh`, los dos árboles en la misma corrida |
| `CA-07 (i)` procesos por parada | +0 | **5** contra **5** | ídem, sobre `estado-derivado.sh` |
| `CA-07 (ii)` reloj de la ruta crítica | ≤ 1,25× | **1,077×** (87 435 µs / 81 115 µs) | `sonda-reloj.sh --k 4 --r 6`, sujetos **intercalados** |
| `CA-07 (iii)` doblar el nº de entradas | ≤ 2,2× | **mediana 1,860×**, MAD 0,010, margen 0,340 | par **400 → 800** entradas, `k=8`, 5 tomas |
| `CA-07 (iv)` doblar la longitud de línea | ≤ 2,2× | **mediana 1,994×**, MAD 0,022, margen 0,206 | par **1000 → 2000** bytes, 20 entradas fijas, `k=8`, 5 tomas |

**El estadístico se eligió a propósito y no es el rango.** La dispersión se mide con la **MAD**
sobre 5 tomas de la relación, no con el rango: el rango es monótono no decreciente, así que «más
tomas» no puede estrecharlo nunca y la vía conforme para llegar a afirmar el techo quedaría
cerrada por construcción — que es exactamente lo que dejó `CA-09 (iii)` de REQ-023 abstenido en
esta máquina. Con MAD, la salida ante una abstención existe: más tomas, `k` mayor o un host menos
cargado.

**Y `k = 8` no es un número redondo, está calibrado y se dice cómo.** Con `k = 3` el término
corto de (iv) quedó por debajo del suelo de 50 ms y el caso **abstuvo 0 de 5 tomas**; con `k = 4`
quedaba en el filo (46–84 ms según la carga), o sea que el veredicto lo decidía el host. Se subió
`k` —que es la vía conforme— y no el techo.

**Una anomalía medida que conviene no perder, porque decide qué par es honesto.** El coste del
lector de la cola **no es monótono** en la longitud de línea en esta máquina: 500 → 13,0 ms,
1000 → 21,7 ms, 2000 → 34,7 ms, **4000 → 20,2 ms**, 8000 → 52,5 ms (mínimo de 3 series de 3, tres
repeticiones). El punto de 4000 es reproduciblemente **más rápido** que el de 2000, así que el par
2000 → 4000 da un cociente de **0,46×** que pasaría el techo **sin medir nada**. Por eso el par
contratado es **1000 → 2000**, que está en la región monótona, y por eso el par **se publica con
el cociente**.

## 7. Ceilings y cuadres, para que la próxima comisión no lo descubra

| Archivo | líneas | piso | techo | gobierna |
|---|---|---|---|---|
| `31-cola-una-sola-regla.sh` | 352 | 76 | 400 | `N` |
| `40-ausencia-que-abre-1-la-clase-derivada.sh` | 320 | 200 | 400 | `N` |
| `40-ausencia-que-abre-2-migracion-y-punteros.sh` | **400** | 194 | **400** | `N` |
| `39-caracter-invisible-4-el-coste.sh` | 394 | 330 | 413 | `piso×k` |

`40/2` está **en su techo exacto**: una línea más y la autoprueba aborta. Está avisado en el
preámbulo del propio archivo. Quien añada un caso ahí **parte** la sección; no sube el techo ni
infla el piso para caber (`REQ-014 CA-18` y el README del banco).
