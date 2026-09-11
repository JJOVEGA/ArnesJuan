# REQ-024 CA-07 (ii) — la reparación, sus cuatro demostraciones y la acreditación

> Diagnóstico que la justifica: `01-diagnostico.md`. Datos crudos: `corridas/`.
> Salidas íntegras de las demostraciones: `demostraciones/`.

## El ajuste, y por qué es el mínimo

El caso decidía con **una** invocación de la sonda y `min_a/min_b` contra el techo. Le faltaba el
tercer estado. El ajuste es **una guarda de dispersión sobre la magnitud que el criterio juzga**,
que es la **razón**:

1. `KRAZ07 = 4` repeticiones del par intercalado entero, **cada una con su razón**.
2. Por repetición, la guarda de **convergencia** ya existente en el criterio hermano
   (`segundo mínimo / mínimo` de cada brazo contra el mismo 1,250×), que si se supera **abstiene
   citando la razón que sí obtuvo**.
3. Encima, la resolución **sobre la razón**: `PASS` si máx(r) ≤ techo en TODAS, `FAIL` si mín(r) >
   techo en TODAS, `SKIP` en cuanto el techo cae **dentro** del recorrido — con el motivo, las k
   razones, el recorrido, el techo, la peor convergencia y **la vía de acreditación**.

**Es mínimo en tres sentidos, y los tres son comprobables:**

- **No se construyó instrumento nuevo.** `razon07`/`veredicto07` están **portadas** de
  `REQ-017 CA-08 (ii)` (`tests/escenarios/hooks/secciones/37-coste-del-escaner-5-el-camino-normal.sh`,
  `razon08_47`/`veredicto08_47`), donde la guarda ya estaba escrita y probada. No se factoriza
  porque cada sección corre en su propio subshell (CA-04, CA-19, H-04) — la misma razón por la
  que `mat37`/`mat47`/`mat40` son copias.
- **`tests/util/sonda-reloj.sh` NO se tocó.** Ya publicaba `min2_a` y `min2_b`, que es lo único
  que la guarda necesitaba del instrumento.
- **No se tocó ningún otro criterio de reloj**, ni el techo, ni `.github/`, ni `hooks/`, ni el
  sujeto: `K07=4` y `SER07=6` son los mandos con los que el caso ya medía.

## Archivos tocados

| archivo | qué |
|---|---|
| `tests/escenarios/hooks/secciones/40-ausencia-que-abre-7-el-reloj-de-la-ruta-critica.sh` | **nuevo**: el caso reparado y sus cuatro demostraciones (5 casos) |
| `tests/escenarios/hooks/secciones/40-ausencia-que-abre-2-migracion-y-punteros.sh` | pierde `CA-07 (ii)` (9 → 8 casos) y queda en 376 de 400 líneas. `(i)`, `(iii)` y `(iv)` **no se tocan** |
| `tests/escenarios/hooks/run.sh` | `CASOS_ESPERADOS` 1090 → 1094, con su derivación escrita |
| `docs/arnes/req-024-ca-07-ii-reparacion/` | este artefacto |

**Va en una parte 7 y no en la 2** porque la 2 estaba en 400 de 400 líneas: `REQ-014 CA-18` manda
partir, no alargar ni inflar el piso. `40/7` declara `piso = 329 = sus líneas` y su techo lo
gobierna `piso × k` — misma forma que `37/2` (552 líneas, piso 551), y por el mismo motivo: el
bloque es **indivisible**, porque las demostraciones tienen que ejercer **la** función que decide
y no una copia suya.

## Las cuatro demostraciones — EJECUTADAS, no argumentadas

Dos van **dentro del banco** (corren en cada vuelta, con entradas sintéticas deterministas, sin
coste de reloj para la puerta) y dos van **extremo a extremo sobre el árbol real**.

### 1 · Control sin regresión conocida → `PASS`

`demostraciones/d1-control-acreditacion.txt`, y además el par discriminante POSITIVO del banco.

```
PASS  REQ-024 CA-07 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base
      máx(r) 1.139× <= techo en las 4 razones: 1.127× 1.139× 1.121× 1.124×
      · recorrido 1.016× · techo 1.250× · peor convergencia 1.021× · k=8 r=30
```

Y en la vuelta del **banco completo**, a los parámetros de la puerta:

```
PASS  ... máx(r) 1.146× <= techo en las 4 razones: 1.145× 1.146× 1.076× 1.088×
      · recorrido 1.065× · techo 1.250× · peor convergencia 1.051× · k=4 r=6
```

### 2 · Regresión deliberada y conocida, **en una copia** → `FAIL`, no `SKIP`

El árbol **no se toca**: se copia `hooks/` a un temporal y se inyecta en `guard-completado.sh`
un bucle aritmético que sólo quema reloj y no cambia ninguna decisión; se corre con
`ARNES_HOOKS_DIR` apuntando a la copia.

- **Regresión modesta (~1,7×), a los parámetros DE LA PUERTA (`k=4 r=6`) y bajo contención** —
  `demostraciones/d2b-regresion-modesta-puerta.txt`:

```
FAIL  ... mín(r) 1.741× > techo en TODAS: es regresión, no ruido — el techo es OPERATIVO y no se
      sube, lo que baja es el coste del lector — 4 razones: 1.741× 1.752× 1.908× 1.829×
      · recorrido 1.095× · techo 1.250× · peor convergencia 1.082× · k=4 r=6
```

- **Regresión grande (5,4×), en modo acreditación** — `demostraciones/d2-regresion-real-en-copia.txt`:
  `FAIL` con `mín(r) 5.362×`.

Es la demostración que importa: **la abstención no se traga una regresión real**, y no la traga
ni siquiera cuando el ruido está presente.

### 3 · Condiciones de medición insuficientes → `SKIP`, y **nunca** `PASS`

Sin regresión ninguna, a los parámetros de la puerta y bajo contención
(`demostraciones/d3-dispersion-puerta.txt`):

```
SKIP  ... el techo cae DENTRO del recorrido observado [1.039×, 1.306×]: el instrumento no
      distingue el factor que vigila, y una medición inconclusa NO es una aprobación. Vía de
      acreditación: repetir con ARNES_COSTE_RUTA_CRITICA=1 (r=30, k=8) o en un host menos
      cargado — nunca subir el techo — 4 razones: 1.306× 1.112× 1.039× 1.117×
      · recorrido 1.256× · techo 1.250× · peor convergencia 1.178× · k=4 r=6
```

**Ésta es exactamente la corrida que antes producía un FAIL falso**: una repetición en 1,306×
sobre un árbol cuyo cociente verdadero es 1,118×, con los dos brazos **convergidos** (1,178×), o
sea invisible para la guarda de convergencia sola. El caso ahora se abstiene y **dice de qué**.

Y el **par discriminante NEGATIVO** del banco lo cierra desactivando la guarda sobre la **misma**
entrada: `con la guarda: SKIP · sin ella: PASS PASS FAIL PASS`. El rojo lo quita la guarda, no la
entrada.

### 4 · Evidencia en el entorno del CI — pendiente de una corrida de `hooks-en-linux`

Esta máquina es WSL2 de 8 núcleos; el runner tiene 4 vCPU con `ARNES_JOBS=6`, y está medido que
**no predicen lo mismo** (`docs/arnes/ci-1.34.0-no-discrimina/`). **Qué esperar en la corrida de CI:**

1. **El cuadre:** `Resultado: … 1094` casos. Si sale otro número, falta o sobra un caso.
2. **Las cuatro demostraciones en `PASS`, siempre** — son deterministas y no dependen del host:
   «la sonda que no converge se ABSTIENE (7 sondas → PASS FAIL SKIP SKIP SKIP SKIP SKIP)», «el
   SKIP cita las TRES cifras», «par discriminante NEGATIVO» y «par discriminante POSITIVO».
   **Un FAIL en cualquiera de ellas es un defecto de la guarda, no del host.**
3. **El caso real, `PASS` o `SKIP`, nunca `FAIL`** salvo regresión verdadera. Lo esperado es
   `PASS` con `máx(r)` entre ~1,10× y ~1,20×; si el runner va cargado, `SKIP` citando el
   recorrido. **Lo que ya no debe volver a pasar es un `FAIL` con las cuatro razones repartidas a
   los dos lados del techo** — ése era el defecto.
4. **Rojo de la puerta sólo si** `FAIL` en alguna demostración, o `FAIL` del caso real con las
   **cuatro** razones por encima de 1,250× (que sería regresión de verdad y hallazgo contra el
   código).

## La acreditación: un SKIP no cierra el criterio

**Camino declarado y ya ejecutado:** `ARNES_COSTE_RUTA_CRITICA=1` sube `r` de 6 a 30 y `k` de 4 a
8 —30× el coste— sobre los mismos sujetos. Es el patrón que `REQ-017 CA-05` ya usa en este banco:
no apaga la señal, deja de decidir cada PR con ella. Sin la palanca, el caso **sigue en la puerta
requerida con el techo intacto**.

```bash
ARNES_COSTE_RUTA_CRITICA=1 bash tests/escenarios/hooks/run.sh \
  40-ausencia-que-abre-7-el-reloj-de-la-ruta-critica.sh
```

**Resultado de la corrida de acreditación (2026-09-11, `69fc96a` contra `v1.33.0`): `PASS`, máx(r)
1,139× ≤ 1,250×, recorrido 1,016×.** Y el respaldo independiente de `fase4`: mediana **1,118×**,
nueve repeticiones en 1,059×–1,129×, con la nula colapsada a 0,984×–1,005×.

**El criterio queda acreditado en una dirección: se cumple.** No se acumula ningún SKIP.

## Lo que la reparación cuesta en la puerta requerida

Medido el 2026-09-11, sección `40/7` sola, mínimo de 3 vueltas: **3,95 s** con `KRAZ07=1` (que es
lo que el caso hacía antes) y **5,82 s** con `KRAZ07=4`. La guarda añade **1,87 s = 0,473×** de lo
que el caso costaba.

**Lo que NO está medido, dicho aquí y no omitido:** el delta sobre el banco **entero**. Las dos
vueltas completas cronometradas (69,6 s y 70,7 s) llevan **las dos** la guarda puesta, así que su
diferencia es varianza entre vueltas y **no** el coste del cambio; citarla como «antes → después»
sería una atribución falsa. La cota que sí se puede afirmar es la de arriba: el cambio añade
**1,87 s a una sección** que corre en paralelo con otras 64, luego el efecto sobre el tiempo de
pared del banco está **acotado por 1,87 s** (2,7 % de 69,6 s) y en la práctica es menor, porque el
corredor reparte con `ARNES_JOBS`. Medirlo de verdad exigiría cronometrar el banco sobre el árbol
sin el cambio, y eso no se hizo.

## Quality gates, en verde

| puerta | resultado |
|---|---|
| `bash -n` de `hooks/*.sh` y `tools/*.sh` | ok |
| `jq -e .` de `hooks.json`, `plugin.json`, `marketplace.json` | ok |
| `tests/escenarios/hooks/run.sh` (banco entero) | **1088 PASS · 0 FAIL · 6 SKIP = 1094**, rc 0, 70,7 s |
| `tests/escenarios/hooks/autoprueba-corredor.sh` | **106 PASS · 0 FAIL** |

## Entrada de `CHANGELOG.md` lista para pegar (NO se escribió: la comisión reserva el commit)

```markdown
### [2026-09-11] — REQ-024 CA-07 (ii): el instrumento tenía dos estados donde hacen falta tres
- **Origen:** GitHub · **Usuario:** juan.vega@sysvega.cr · **Modelo IA:** Claude Opus 5
- **Agente(s):** `desarrollador`
- **Detalle:** el caso decidía con UNA invocación de la sonda y sin guarda de dispersión, así que
  una medición que no resuelve el factor que vigila salía como FAIL —cinco rojos de CI, uno de
  ellos sobre un ancestro del destino y dos sobre código idéntico—. Medida la distribución NULA
  (el mismo árbol en los dos brazos, verdad 1,000× por construcción) el instrumento recorre
  0,875×–1,213× a los mandos del caso, con una repetición convergida en 1,213×: el techo vive
  DENTRO del ruido. El cociente VERDADERO es 1,118× (k=8 r=30, nula colapsada a 0,984×–1,005×):
  hay coste real y CUMPLE el techo. Se porta la guarda de `REQ-017 CA-08 (ii)` —4 repeticiones
  del par, convergencia por brazo y resolución sobre la razón— a una sección `40/7` nueva, con
  las cuatro demostraciones ejecutadas y la acreditación tras `ARNES_COSTE_RUTA_CRITICA=1`.
  El techo 1,250× queda INTACTO, el caso sigue en la puerta requerida y no hay `continue-on-error`.
  Evidencia: `docs/arnes/req-024-ca-07-ii-reparacion/`. Banco: 1094 casos, 0 FAIL.
```
