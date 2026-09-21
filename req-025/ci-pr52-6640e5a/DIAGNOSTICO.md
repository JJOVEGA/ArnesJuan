# CI `hooks-en-linux` sobre `6640e5a` — run 35655684298 (2026-09-21, 21:11–21:12Z)

**Versión base:** cabeza `6640e5a` de `feat/req-025-coordinacion-entregas` = candidato validado `9f908d9` + dos commits de documentación (`409c312` QA R-3b; `6640e5a` cola/ESTADO). `git diff --stat 9f908d9..6640e5a` no toca `hooks/`, `tools/`, `tests/`, `.github/`, `AGENTS.md`, `templates/`, `agents/` ni `skills/`.
**Método:** `gh run view 35655684298 --log` → `log-completo.txt`; líneas de resumen y SKIP extraídas con `grep` (`resumen.txt`, `sondas-de-coste.txt`). Disparado por el push del 21:10Z, no relanzado.

| Corrida | Cabeza | Banco | Autoprueba | Conclusión |
|---|---|---|---|---|
| 35646997951 | `9f908d9` | 903 PASS · 0 FAIL · 9 SKIP = 912 | 106 · 0 | success |
| 35655684298 | `6640e5a` | **905 PASS · 0 FAIL · 7 SKIP = 912** | 106 · 0 | success |

**La diferencia 903/9 → 905/7 son las dos sondas de coste de REQ-017 (CA-09 «la pared de los 60 s» y CA-08 (ii) «cabecera de 200 líneas»), que en `9f908d9` se abstuvieron (SKIP: rangos solapados / sin convergencia) y aquí dieron PASS.** Es la dispersión ya medida de esas sondas (SEC-030; su verde y su rojo son igual de poco informativos): **no se usa como evidencia de nada** y no cambia ninguna conclusión de la entrega. Los otros siete SKIP son idénticos entre las dos corridas y cada uno lleva su motivo (Windows sin cygpath, CA-10 (i)-(iii) por 36 entradas no clasificables, CA-05 (i)-(ii) acreditadas en REQ-017, REQ-021 CA-08 (iii) procesos no medibles).

**Caso del FAIL local QA-025-05** (`DEV v3: heredoc CITADO de ~300 KB`): PASS en **3331 ms** (techo 4000; 3725 ms en la corrida anterior). Evidencia de esta corrida; el FAIL local (3 de 3, 4128–4255 ms) sigue conservado como medido.

**Qué acredita:** que la puerta requerida de `main` está en verde sobre la cabeza exacta que el PR #52 propone. **Qué no:** nada sobre las sondas de coste; nada sobre la conducta de S4; no cierra ni reabre ningún hallazgo.
