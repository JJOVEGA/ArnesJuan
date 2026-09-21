# CI `hooks-en-linux` sobre `a1e4f72` — run 35665158708 (2026-09-21)

**Versión base:** cabeza final `a1e4f72` de `feat/req-025-coordinacion-entregas` = candidato validado `9f908d9` + seis commits de documentación (`409c312` QA R-3b · `6640e5a` cola/ESTADO · `a46ef50` decisión del propietario y write-back · `5c30281` QA R-4 · `51a4430` seguridad R-041 · `a1e4f72` ESTADO/CHANGELOG). `git diff --name-only origin/main..a1e4f72`: 0 archivos en `hooks/`, `tools/`, `tests/`, `.github/`.
**Método:** `gh run watch` + `gh run view --log` → `log-completo.txt`; resumen con `grep` → `resumen.txt`. Disparado por el push; no relanzado.

| Corrida | Cabeza | Banco | Autoprueba | Conclusión |
|---|---|---|---|---|
| 35646997951 | `9f908d9` | 903 · 0 · 9 = 912 | 106 · 0 | success |
| 35655684298 | `6640e5a` | 905 · 0 · 7 = 912 | 106 · 0 | success |
| **35665158708** | **`a1e4f72`** | **904 · 0 · 8 = 912** | **106 · 0** | **success** |

**Las variaciones PASS/SKIP entre las tres corridas (903/9 · 905/7 · 904/8) son las dos sondas de coste de REQ-017** (CA-09 «la pared de los 60 s»: SKIP · PASS · SKIP; CA-08 (ii) «cabecera de 200 líneas»: SKIP · PASS · PASS), sobre un mecanismo idéntico por hash en las tres. Es su dispersión ya medida (SEC-030): **no se usa como evidencia** en ningún sentido. Los otros siete SKIP son idénticos y motivados.

**Caso del FAIL local QA-025-05:** PASS en 3559 ms (3725 · 3331 · 3559 en las tres corridas; techo 4000). El FAIL local (3 de 3, 4128–4255 ms) se conserva como medido.

**Qué acredita:** la puerta requerida de `main` en verde sobre la cabeza exacta que propone el PR #52. **Qué no:** nada sobre las sondas; nada sobre S4; no cierra SEC-102 ni SEC-103.
