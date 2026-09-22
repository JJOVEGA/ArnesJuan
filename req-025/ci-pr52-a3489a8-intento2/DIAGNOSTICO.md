# CI `hooks-en-linux` sobre `a3489a8` — run 35668137505, **intento 2** (2026-09-22): SUCCESS con la sonda en SKIP

**Autorización:** el propietario autorizó **una única** repetición del CI requerido sobre la cabeza exacta `a3489a8` («sustituye, sólo para esa corrida, mi instrucción anterior de no relanzar»). Se ejecutó con `gh run rerun 35668137505` sobre el mismo run, **sin commit nuevo, sin cambio de archivos, pruebas, umbrales, workflow ni ruleset**. Cabeza confirmada antes: PR #52 head = remoto = `a3489a8`.
**Intento 1 conservado:** `attempts/1` sigue registrado en GitHub con `conclusion=failure` sobre `a3489a8` (903 · 1 · 8; FAIL en `REQ-017 CA-08 (ii) un REQ real de 6 líneas`, 1,273×). Su diagnóstico: `../ci-pr52-a3489a8/DIAGNOSTICO.md`. **Este verde no lo desmiente, no demuestra que fuera ruido ni acredita estabilidad.**
**Método:** `gh run watch` + `gh run view --log` → `log-completo.txt`; `grep` → `resumen.txt`.

| Intento | Banco | Autoprueba | Conclusión | Caso `CA-08 (ii)` 6 líneas | Caso `CA-08 (ii)` 200 líneas |
|---|---|---|---|---|---|
| 1 | 903 · 1 · 8 = 912 | 106 · 0 | failure | **FAIL** 1,273× (convergencia 1,021 / 1,193) | SKIP (no convergió: 1,297 / 1,075) |
| **2** | **903 · 0 · 9 = 912** | 106 · 0 | **success** | **SKIP** (no convergió: 1,340 / 1,395) | SKIP (no convergió: 1,336 / 1,529) |

**Lo que el intento 2 dice y lo que no.** El check requerido está en verde porque el caso de reloj **se abstuvo**: la sonda no convergió en ninguno de los dos brazos y, por contrato (CA-06 y CA-08), un instrumento que no resuelve dice SKIP y nunca PASS ni FAIL. Por tanto **el criterio de rendimiento CA-08 (ii) sigue sin acreditarse sobre esta cabeza**: en el intento 1 la lectura excedió el techo; en el intento 2 no hubo lectura. Ninguno de los dos intentos ha producido un PASS del criterio. El resto del banco (903 PASS) y la autoprueba (106 · 0) son idénticos entre intentos.

**Los siete SKIP restantes** son los mismos de todas las corridas anteriores, cada uno con su motivo (Windows sin cygpath; CA-10 (i)-(iii) por entradas no clasificables; CA-05 (i)-(ii) acreditadas en REQ-017; REQ-021 CA-08 (iii) procesos no medibles). El caso del FAIL local QA-025-05 dio PASS en 1814 ms.

**Efecto sobre el PR #52:** `mergeStateStatus` pasa de `BLOCKED` a `CLEAN`; `hooks-en-linux: SUCCESS`. Es evidencia de **esta corrida**. No autoriza fusionar: la fusión sigue siendo decisión del propietario, y el criterio de rendimiento queda **no acreditado, con la abstención registrada**.
