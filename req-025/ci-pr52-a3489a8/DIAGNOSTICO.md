# CI `hooks-en-linux` sobre `a3489a8` — run 35668137505 (2026-09-21): **FAILURE**, 1 FAIL en la sonda de coste

**Versión base:** cabeza `a3489a8` de `feat/req-025-coordinacion-entregas` (PR #52) = candidato validado `9f908d9` + nueve commits de documentación. `git diff --name-only origin/main..a3489a8`: **0** archivos en `hooks/`, `tools/`, `tests/`, `.github/`. Árboles del mecanismo **idénticos por hash** en `9f908d9`, `6640e5a`, `a1e4f72`, `a3489a8` y `origin/main` (`hooks=a6810ac6`, `tools=87edb9b4`, `tests=b4cbb114`; `git rev-parse <cabeza>:<dir>`).
**Método:** `gh run watch` + `gh run view --log` → `log-completo.txt`; `grep` → `resumen.txt`. Disparado por el push; **no relanzado**, y no se relanza para buscar verde.

| Corrida | Cabeza | Banco | Autoprueba | Conclusión |
|---|---|---|---|---|
| 35646997951 | `9f908d9` | 903 · 0 · 9 = 912 | 106 · 0 | success |
| 35655684298 | `6640e5a` | 905 · 0 · 7 = 912 | 106 · 0 | success |
| 35665158708 | `a1e4f72` | 904 · 0 · 8 = 912 | 106 · 0 | success |
| **35668137505** | **`a3489a8`** | **903 · 1 · 8 = 912** | 106 · 0 | **failure** |

**El único FAIL:** `REQ-017 CA-08 (ii) un REQ real de 6 líneas: el reloj no sube más de 1,25× el de v1.32.1` → `1.273× > 1.250× (0.0907 s/llamada frente a 0.0712 s), y la sonda SÍ convergió (1.021×/1.193×): esto es una regresión, no ruido`.

**El mismo caso en las cuatro corridas, sobre mecanismo idéntico por hash:**

| Cabeza | Razón medida | Convergencia | Resultado |
|---|---:|---|---|
| `9f908d9` | 0,940× | 1,015× / 1,044× | PASS |
| `6640e5a` | 1,059× | 1,119× / 1,103× | PASS |
| `a1e4f72` | 1,088× | 1,012× / 1,042× | PASS |
| `a3489a8` | **1,273×** | 1,021× / 1,193× | **FAIL** |

**Interpretación, separada del dato.** El dato es el FAIL y su cifra; se conserva tal cual. La sonda de coste de REQ-017 CA-08 (ii) tiene medida su dispersión sobre código idéntico (0,973×–1,364× frente a un techo de 1,25×; `PENDING_APPROVAL.md` §Resueltas 2026-09-08/09, `docs/PENDIENTES.md`), y el propietario tiene decidido que su verde y su rojo no acreditan nada por sí solos, que la sonda **no se toca** en esta ventana y que el CI **no se relanza** para buscar verde. Que el mecanismo sea idéntico por hash en las cuatro cabezas es evidencia de que la variación no la produjo ningún cambio de código de esta rama; **no** desmiente el FAIL: la variabilidad se conserva como evidencia y la decisión se presenta aparte. El mensaje del caso («esto es una regresión, no ruido») es la afirmación de la sonda sobre su propia convergencia; sobre mecanismo idéntico, esa afirmación queda registrada, no se acepta ni se rechaza aquí.

**Efecto:** la puerta requerida `hooks-en-linux` está **en rojo** sobre la cabeza del PR #52. No había fusión prevista ni autorizada, así que no impide nada del encargo; **impide** que la cabeza actual se presente como «CI verde». Cualquier corrida nueva la decide el propietario.

**Qué acredita:** 903 PASS · 0 FAIL fuera de la sonda; autoprueba 106 · 0; el caso del FAIL local QA-025-05 en 3429 ms. **Qué no:** nada sobre la sonda en ningún sentido; no reabre ni cierra ningún hallazgo de REQ-025.
