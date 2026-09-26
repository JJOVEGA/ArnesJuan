# Comprobación acotada en CI del procedimiento propuesto para las sondas — RESULTADOS (2026-09-26)

**Autorización:** «una comprobación experimental en CI, separada del PR #53, con un máximo de cinco ejecuciones» (propietario, 2026-09-25). **Preregistro:** `preregistro.md` (commit `7494a28` de esta rama de evidencia, anterior a la primera ejecución). **Rama de ensayo:** `ensayo/sondas-r5`, **PR #54 en borrador** (https://github.com/JJOVEGA/ArnesJuan/pull/54), **nunca se fusiona**. **Base:** `main` = `cfb1106`. **Contenido del experimento:** `contenido-del-experimento.diff` sobre `83f1e9c42f39b7971d4ff5297571d56b2012a517`.

**Método de cada cifra de este archivo:** `analizar-ci.sh` limpia el prefijo de los logs de CI (`corridas/run-N.txt`, descargados con `gh run view --log`) a `limpias/corrida-0N.txt` y corre `../ensayo-local/analizar-ensayo.py`; su salida íntegra está en `analisis-ci.txt`. Las duraciones salen de `jobs[0].startedAt/completedAt` de `gh run view --json` (`corridas/run-N.meta`). El veredicto «vigente derivado» se lee **a mano** de la repetición #1 en el mensaje del juez (la instrumentación `ENSAYO dato CA-08 … reg=` imprimió `[vacio]` por el mismo defecto que en el ensayo local; se declara y no se corrigió durante el ensayo). Los hashes `tests_tree` son `git rev-parse <sha>:tests`.

## 1. Las cinco ejecuciones (todas iniciadas dentro del presupuesto; ninguna relanzada ni sustituida)

| # | SHA | run | enlace | job (UTC) | duración job | banco (917 esperados) | `tests/` |
|---|---|---|---|---|---|---|---|
| 1 | `83f1e9c42f39b7971d4ff5297571d56b2012a517` | 36208353755 | https://github.com/JJOVEGA/ArnesJuan/actions/runs/36208353755 | 01:25:12–01:28:56 | 224 s | 908 PASS · 2 FAIL · 7 SKIP | `599db51` |
| 2 | `88ffb777671ce3a00fe872a12b81c8c37ccf2df2` | 36208614557 | https://github.com/JJOVEGA/ArnesJuan/actions/runs/36208614557 | 01:29:53–01:32:56 | 183 s | 908 PASS · 2 FAIL · 7 SKIP | `599db51` |
| 3 | `36303f27ce1e9dd2dd25249718238e894d6b9dde` | 36208814796 | https://github.com/JJOVEGA/ArnesJuan/actions/runs/36208814796 | 01:33:35–01:37:20 | 225 s | 905 PASS · 3 FAIL · 9 SKIP | `599db51` |
| 4 | `b327e7e4c2ce43e04a14ca59f321834ddaf4f587` | 36209059735 | https://github.com/JJOVEGA/ArnesJuan/actions/runs/36209059735 | 01:37:39–01:40:43 | 184 s | 906 PASS · 2 FAIL · 9 SKIP | `599db51` |
| 5 | `43404066857f0b5ba022def61e6b837725491f6d` | 36209243032 | https://github.com/JJOVEGA/ArnesJuan/actions/runs/36209243032 | 01:40:59–01:43:18 | 139 s | 907 PASS · 2 FAIL · 8 SKIP | `599db51` |

Las cinco: conclusión `failure` **a propósito** (los 2 FAIL de cada corrida son el control WD, que debe fallar; el tercer FAIL de la corrida 3 se explica en §5). Pared total: 01:25:10Z (creación del run 1) → 01:43:18Z (fin del job 5) = **18 min 8 s** de los 60 autorizados. Cuadre: 917 casos en las cinco.

### Desviaciones del preregistro (registradas en `corridas/incidencias.txt`)
1. **Los commits de las corridas 2–5 no son vacíos.** El hook `pre-commit` del repositorio rechazó `git commit --allow-empty` («este commit no actualiza CHANGELOG.md»); no se saltó el hook. Cada una de esas cuatro corridas se disparó con un commit que añade **una línea de comentario a `CHANGELOG.md`** (`ejecutar-ensayo-ci-2a5.sh`). Por eso los árboles completos **no** son idénticos; lo que se compara por hash es el árbol de `tests/`, idéntico en las cinco (`599db519503a2378ca97c90775a810a5c9d6c60f`). `hooks/` y `tools/` tampoco cambian (sólo `CHANGELOG.md` difiere entre cabezas).
2. **Corrida 5:** el vigilante local falló por «TLS handshake timeout» (red, lado local) mientras el run seguía en curso; se releyó **el mismo run** al completarse y se descargó su log. No es una corrida nueva.
3. Nombre de archivos: `corridas/run-N.txt` en vez de `run-<id>-<sha>.txt`; el id y el SHA están en `run-N.meta`.

## 2. Procedimiento propuesto (R=5, juez por recorrido) — veredicto por caso y corrida

| caso | 1 | 2 | 3 | 4 | 5 | recuento |
|---|---|---|---|---|---|---|
| CA-03 directa (k=20, techo 2,600×) | PASS máx 2.589 | PASS máx 2.367 | PASS máx 2.147 | PASS máx 2.533 | **SKIP [INCONCLUSO]** recorrido [1.980, 2.693] | 4 PASS · 1 INC · **0 FAIL** |
| CA-03 calibración v1.32.1 (k=20) | resuelta [2.701, 4.126] | [2.709, 3.919] | [2.809, 4.268] | [2.731, 3.915] | [2.699, 3.919] | **5/5 resuelta**, mín > 2,600 en las cinco |
| CA-08 (ii) 6 líneas (techo 1,250×) | PASS máx 1.166 (3/5 res.) | PASS máx 1.090 (4/5) | PASS máx 0.886 (3/5) | PASS máx 1.105 (5/5) | PASS máx 1.085 (3/5) | **5 PASS** |
| CA-08 (ii) 200 líneas | PASS máx 1.107 (5/5) | PASS 1.059 (5/5) | PASS 1.063 (5/5) | PASS 1.040 (5/5) | PASS 1.051 (5/5) | **5 PASS** |
| control I 6l (idénticos, verdad 1,0) | PASS máx 1.043 (5/5) | PASS máx 1.250 (4/5; = techo, cumple) | **SKIP [INC]** sólo 2/5 resueltas | **SKIP [INC]** recorrido [0.935, 1.291] | PASS máx 0.980 (3/5) | 3 PASS · 2 INC · **0 FAIL** |
| control W0 6l (envoltorio, demora 0) | PASS 1.184 (3/5) | PASS 1.216 (5/5) | **SKIP [INC]** recorrido [1.047, 1.522] | PASS 1.132 (4/5) | PASS 1.192 (3/5) | 4 PASS · 1 INC · **0 FAIL** |
| control WD 6l (+40 ms/llamada, debe FAIL) | FAIL mín 2.107 | FAIL 2.768 | FAIL 2.287 | FAIL 2.489 | FAIL 2.876 | **5/5 FAIL** |
| control I 200l | PASS 1.016 (5/5) | PASS 1.011 | PASS 1.005 | PASS 1.001 | PASS 1.018 | **5 PASS** |
| control W0 200l | PASS 1.018 (5/5) | PASS 1.029 | PASS 1.020 | PASS 1.018 | PASS 1.022 | **5 PASS** |
| control WD 200l (+100 ms, debe FAIL) | FAIL mín 2.286 | FAIL 2.540 | FAIL 2.294 | FAIL 2.534 | FAIL 3.194 | **5/5 FAIL** |

Lectura contra las reglas preregistradas:
- **0 FAIL en I y W0** (20 juicios) y **0 FAIL en los casos reales** (15 juicios): ningún falso aviso.
- **WD FAIL 10 de 10** (5 por entrada): la capacidad de detección de una demora añadida queda acreditada en las cinco corridas.
- **Calibración de CA-03 resuelta 5/5.**
- **Inconclusos: 4 de 35 juicios no-WD** — 1 en un caso real (CA-03, corrida 5) y 3 en controles de la entrada de 6 líneas (I: corridas 3 y 4; W0: corrida 3). Ninguno en la entrada de 200 líneas. Ningún caso real llega al umbral «≥ 3 de 5 inconclusos» de evidencia insuficiente.

## 3. Procedimiento vigente, derivado de la repetición #1 sobre los mismos datos

Regla de `main`: una sola medición; CA-08 (ii) exige convergencia por brazo (2ºmín/mín ≤ 1,25) y, si converge, razón contra el techo; CA-03 directa: cociente contra 2,600×.

| caso | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| CA-03 directa | PASS 2.589 | PASS 2.367 | PASS 2.110 | PASS 2.533 | **FAIL 2.693** |
| CA-08 (ii) 6l | SKIP (no converge 1.487/1.087) | PASS 1.083 | SKIP (no converge 1.773/1.209) | PASS 0.746 | PASS 1.085 |
| CA-08 (ii) 200l | PASS 1.107 | PASS 0.941 | PASS 0.956 | PASS 1.008 | PASS 0.911 |
| control I 6l | PASS 0.924 | PASS 0.935 | SKIP (no converge) | PASS 0.935 | SKIP (no converge) |
| control W0 6l | PASS 0.971 | PASS 1.216 | no derivable (el mensaje por recorrido no dice qué repetición es la 1.522) | SKIP (no converge 1.285/1.353) | PASS 1.039 |
| control WD (ambas) | FAIL cuando #1 resuelve; en la corrida 1 (6l) una de las cinco no resolvió y el mensaje no dice cuál | | | | |

**La variación que originó el problema SÍ apareció, con mecanismo idéntico en las cinco corridas:** CA-03 directa leyó **2.693× en la corrida 5** (> 2,600) frente a 2.110–2.589 en las otras cuatro, y una repetición **convergida** de sujetos idénticos leyó **1.291×** (I 6l, corrida 4) y otra de envoltorio nulo **1.522×** (W0 6l, corrida 3), ambas > 1,250. Sobre esos mismos datos: **el vigente habría puesto el check en rojo en la corrida 5 por CA-03** (mismo árbol que pasó 4 veces); **el propuesto se abstuvo** ([INCONCLUSO]) y no falló en ninguna. En CA-08 (ii) los dos procedimientos coinciden en 5/5 PASS del caso de 200 líneas; en el de 6 líneas el vigente se abstiene 2 veces (no converge) y el propuesto pasa 5 veces.

## 4. Coste

| | job `hooks-en-linux` |
|---|---|
| `main` `cfb1106` (run 35742539672, 2026-09-22) | 50 s |
| PR #53 `d413405` (35924622453) / `f7a6fdf` (36049345243) | 51 s / 50 s |
| ensayo, 5 corridas | 139 · 183 · 184 · 224 · 225 s (mín 139, máx 225) |

El sobrecoste observado es **+89 a +175 s por corrida**, pero **no es separable**: incluye la sección de controles 37/9 (6 casos × 5 repeticiones, que **no** se adoptaría), la calibración de CA-03 con k=20 (el vigente usa k=1) y la propia R=5 de las sondas reales. El coste de la parte adoptable **no se midió aparte** y no se afirma.

## 5. Observaciones fuera del alcance del experimento (se registran; no abren trabajo)

- **REQ-017 CA-09** (sonda vigente de la pared de 60 s, no tocada por el experimento) sobre mecanismo idéntico en las cinco corridas: PASS en 1, 2 y 5; **FAIL en la corrida 3**; **SKIP en la 4**. Es el mismo fenómeno de dispersión del runner sobre otra sonda de coste, medido con el instrumento vigente. Mensajes íntegros:
  - corrida 3: `FAIL  REQ-017 CA-09 la pared de los 60 s de este árbol NO es menor que la de v1.32.1, pareado en la misma corrida  el MEJOR de este árbol vale 0.965× el PEOR de v1.32.1: la pared BAJÓ en todos los emparejamientos, que es lo contrario de lo único que CA-09 contrata`
  - corrida 4: `SKIP  REQ-017 CA-09 la pared de los 60 s de este árbol NO es menor que la de v1.32.1, pareado en la misma corrida  los rangos de las dos pasadas SE SOLAPAN (este 0.837×–1.660× de v1.32.1): la sonda no distingue la dirección de su propio ruido, y su dispersión (~3,7 sobre el mismo árbol) es de SEC-030, no de este REQ`
- Los SKIP restantes de cada corrida (CA-05 (i)/(ii), CA-10 (i)/(ii)/(iii), REQ-021 CA-08 (iii), «ruta estilo Windows») son los mismos que en `main` y no cambian entre corridas.
- La instrumentación `ENSAYO dato CA-08 … reg=[vacio]`: defecto conocido del ensayo local (`${var##* }`), presente aquí; no afecta a ningún veredicto (los jueces no la leen).

## 6. Conclusión (una de las tres preregistradas)

**Evidencia favorable para proponer adopción.** Se cumplen las cinco condiciones preregistradas: 0 FAIL en I/W0, 0 FAIL en casos reales, WD FAIL 5 de 5 por entrada, calibración resuelta 5/5, inconclusos reportados (4/35). Y, a diferencia del ensayo local, **la variación que motivó el problema sí apareció** (2.693× en CA-03; 1.291× y 1.522× en repeticiones convergidas de sujetos idénticos), y el procedimiento propuesto se abstuvo donde el vigente habría fallado.

**Límites que la conclusión arrastra, sin suavizar:**
1. **n = 5** corridas, un solo día, un solo runner; la tasa de abstención (4/35, 1/15 en casos reales) es una observación, no un parámetro.
2. **Un [INCONCLUSO] se imprime como SKIP y no pone el check en rojo.** Con el procedimiento adoptado, un CI verde puede contener una sonda de coste que **no acreditó nada** esa corrida. Es la decisión pendiente que el propietario ya señaló: qué hace el check con un inconcluso (tolerarlo declarado, bloquear, o exigir acreditación en otra sede antes de fusionar).
3. **El sobrecoste adoptable no está medido** (§4).
4. La dispersión también alcanza a **CA-09** (§5), que el procedimiento propuesto **no cubre**; adoptar R=5 sólo en CA-03 y CA-08 (ii) deja a CA-09 con el instrumento vigente.
5. Nada de esto acredita que los FAIL históricos del PR #53 fueran ruido; se conservan.

**Esta evidencia permite recomendar una adopción; no autoriza implementarla** (regla preregistrada y del propietario). Adoptarla es un cambio de `tests/` y del contrato de REQ-017 (CA-03, CA-08 (ii)): REQ propio, `Rigor: critico`, ciclo completo analista → desarrollador → QA → seguridad.
