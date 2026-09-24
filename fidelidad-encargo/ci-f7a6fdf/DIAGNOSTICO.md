# CI `hooks-en-linux` sobre `f7a6fdf422076cb43745f9713794bbc0e104d1f8` (PR #53, borrador) — run 36049345243, intento 1 (2026-09-24): **failure**, 1 FAIL en una sonda de coste

**Autorización:** «ejecutar una sola corrida del CI requerido sobre esa cabeza». Corrida única, **no relanzada**; se conserva.
**Corrida anterior conservada:** run 35924622453 sobre `d413405`, FAILURE por `REQ-017 CA-03 fail-before` (2,443× < 2,6×). Esta corrida corresponde a la cabeza reparada y **no sustituye ni desmiente** aquélla.
**Mecanismo:** `hooks/`, `tools/`, `tests/` y `.github/` idénticos por hash entre `f7a6fdf` y `origin/main` (`git rev-parse <cabeza>:<dir>`). El PR toca 14 archivos de contrato, sedes heredables y registros.
**Método:** `gh run watch` + `gh run view --log` → `log-completo.txt`; `grep` → `resumen.txt`.

**Resultado:** 903 PASS · **1 FAIL** · 8 SKIP = 912. Autoprueba del corredor **no corrió** (paso saltado tras el rojo del banco).

| Caso | Lectura | Veredicto |
|---|---|---|
| `REQ-017 CA-08 (ii) una cabecera de 200 líneas: el reloj no sube más de 1,25× el de v1.32.1` | **1,339× > 1,250×** (0,1947 s/llamada frente a 0,1454 s); la sonda **convergió** (1,016 / 1,191) | **FAIL** |
| `REQ-017 CA-08 (ii) un REQ real de 6 líneas` | no convergió (1,057 / 1,268) | SKIP |
| `REQ-017 CA-03 fail-before` (el FAIL de la corrida anterior) | 4,961× > 2,6×: se pasa | PASS |
| `REQ-017 CA-03` directa | 1,753× (techo 2,6×) | PASS |

**Qué dice el dato y qué no.** El caso que falla es otro distinto del de la corrida anterior, y el que falló entonces hoy pasa. El FAIL es una lectura verdadera del instrumento sobre esta cabeza y **no se atribuye al entorno**: lo único que consta es que el sujeto medido y el instrumento son, byte a byte, los de `main`, y que el mismo caso ha dado sobre código idéntico lecturas entre 0,973× y 1,364× en corridas anteriores (registradas en `docs/PENDIENTES.md` y en la rama de evidencia). Ninguna lectura desmiente a otra; todas se conservan. **La decisión sobre las sondas de coste sigue separada y pendiente del propietario.**

**Efecto:** `hooks-en-linux: FAILURE` sobre la cabeza del PR #53; no se relanza ni se repara. CA-11.4 de REQ-029 sigue sin cumplirse: no hay corrida en verde sobre la cabeza. Sin fusión.
