# CI en `main` tras la fusión del PR #52 — run 35742539672, head `cfb1106` (2026-09-22): **failure**, 2 FAIL en sondas de coste

**Qué corrida es.** El workflow `banco` corre también en `push` a `main`; la fusión del PR #52 (merge `cfb11062`, árbol idéntico a `a3489a8`) la disparó. **No es una puerta**: el ruleset gobierna los PR, y este run no bloquea nada por sí mismo. Es evidencia de esta corrida.
**Mecanismo:** idéntico por hash al de `a3489a8`, a `origin/main` antes de la fusión (`cc8972c` = `v1.34.0`) y a las cinco corridas del PR #52 (`hooks=a6810ac6…`, `tools=87edb9b4…`, `tests=b4cbb114…`).
**Método:** `gh run view --log` → `log-completo.txt`; `grep` → `resumen.txt`. No relanzado.

**Resultado:** 903 PASS · **2 FAIL** · 7 SKIP = 912. La autoprueba del corredor **no llegó a correr** (el paso del banco terminó en rojo antes; ver pasos en `resumen.txt`).

| Caso | Lectura | Veredicto | Historial reciente del mismo caso sobre mecanismo idéntico |
|---|---|---|---|
| `REQ-017 CA-03` el escáner no crece más que linealmente (70000→140000 bytes, k=20) | cociente 2,747× > techo 2,600× | **FAIL** | PASS en las seis corridas anteriores del PR #52 (dos intentos incluidos) |
| `REQ-017 CA-08 (ii)` cabecera de 200 líneas | 1,255× > 1,250×, convergió (1,067 / 1,194) | **FAIL** | 0,973 · 1,131 · 1,337F · 1,364F (1.33.0) · 1,027 · 1,047 · 1,106 · SKIP×5 |
| `REQ-017 CA-08 (ii)` REQ real de 6 líneas | 0,910× | PASS | 0,940 · 0,958 · 1,059 · 1,088 · 1,258F · 1,273F · SKIP×2 |

**Interpretación separada del dato.** Los dos FAIL son sondas de coste de REQ-017 sobre un mecanismo que no ha cambiado desde `v1.34.0`; el caso de 200 líneas excede el techo por 0,005 y el de linealidad por 0,147 sobre su propio techo 2,6. Ninguna de las dos lecturas se desmiente por las anteriores ni las desmiente: se conservan todas. **Lo que sí añade esta corrida:** la sonda de linealidad CA-03, que no había fallado en ninguna corrida registrada de este PR, también dio rojo en el runner compartido. La decisión sobre las sondas de coste ya está separada por el propietario; esta corrida es un dato más para ella, no una razón para actuar por cuenta propia.

**Efecto:** `main` = `cfb1106` muestra el último run en rojo. No afecta al PR #52 (fusionado) ni a ninguna puerta; afectará a cualquier PR futuro sólo en la medida en que su propia corrida reproduzca la dispersión. Sin acción tomada.
