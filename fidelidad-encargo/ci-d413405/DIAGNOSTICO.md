# CI `hooks-en-linux` sobre `d413405` (PR #53, borrador) — run 35924622453, intento 1 (2026-09-23): **failure**, 1 FAIL en una sonda de coste

**Autorización:** «ejecutar el CI requerido una vez». Corrida única, **no relanzada**; el resultado se conserva.
**Mecanismo:** `git diff --name-only cfb1106..d413405` → 0 archivos en `hooks/`, `tools/`, `tests/`, `.github/`; árboles idénticos por hash a `main`. El PR sólo toca documentación heredable y registros.
**Método:** `gh run view --log` → `log-completo.txt`; `grep` → `resumen.txt`.

**Resultado:** 903 PASS · **1 FAIL** · 8 SKIP = 912. La autoprueba del corredor **no corrió** (el paso del banco terminó en rojo; ver pasos en `resumen.txt`).

| Caso | Lectura | Veredicto |
|---|---|---|
| `REQ-017 CA-03 fail-before: sobre v1.32.1 el cociente da 2.443× y NO se pasa: la sonda no distingue el defecto que este REQ arregla` | 2,443× < techo 2,600× (la heredada debería exceder el techo para que la sonda demuestre que ve el defecto) | **FAIL** |
| `REQ-017 CA-03` directa (70000→140000 B, k=20) | 1,820× | PASS |
| `REQ-017 CA-08 (ii)` REQ de 6 líneas | 1,195× (convergió 1,008 / 1,154) | PASS |
| `REQ-017 CA-08 (ii)` cabecera de 200 líneas | no convergió (1,498 / 1,562) | SKIP |

**Interpretación separada del dato.** Es la **tercera sonda de coste distinta** de REQ-017 que decide en rojo sobre mecanismo idéntico a `main` en esta semana (CA-08 (ii) el 21-22; CA-03 directa el 22 en `main`; hoy CA-03 fail-before). Ninguna lectura desmiente a otra; se conservan todas. El FAIL de hoy no lo produjo el PR: el sujeto medido y el instrumento son los de `main`. La decisión sobre las sondas de coste sigue **separada y pendiente** del propietario; este run es un dato más para ella.

**Efecto:** `hooks-en-linux: FAILURE` en la cabeza del PR #53; la puerta requerida está en rojo y **no se relanza**. No impide nada de este encargo (no había fusión). **CA-11.4 de REQ-029** queda identificado: la corrida sobre la cabeza existe y **no está en verde**, así que el REQ no puede cerrarse por esa vía.
