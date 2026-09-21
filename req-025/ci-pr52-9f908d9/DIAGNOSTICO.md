# CI — PR #52 (borrador, hacia `main`), `hooks-en-linux`, cabeza `9f908d9`
Run 35646997951 · https://github.com/JJOVEGA/ArnesJuan/actions/runs/35646997951 · 2026-09-21T19:47Z · **success**. Única corrida sobre esta cabeza, autorizada por el propietario como evidencia de CA-13.
Método: `gh run view --log` completo → `hooks-en-linux-log.txt` (1404 líneas); pasos → `run.json`.
- Nueve pasos `success`. Banco **903 PASS · 0 FAIL · 9 SKIP = 912** (`CASOS_ESPERADOS` de `v1.33.2`/`v1.34.0`, sin cambio: el delta no toca `tests/`). Autoprueba **106 · 0**.
- El caso del FAIL local de QA-025-05: `DEV v3: heredoc CITADO de ~300 KB -> allow y barato (allow en 3725ms; presupuesto 1000ms, techo holgado 4000ms)` → **PASS aquí**. Localmente dio 4231/4255/4128 ms (3 de 3, QA). **Diferencia de plataforma; el FAIL local se conserva y no queda cerrado por esta corrida** (decisión del propietario).
- 9 SKIP: Windows sin `cygpath`; `REQ-017 CA-10` ×3; `REQ-017 CA-09` (pared de los 60 s: solapamiento); `REQ-017 CA-05` ×2; `REQ-017 CA-08 (ii)` cabecera de 200 líneas (no convergió); `REQ-021 CA-08 (iii)`. Todas sondas de coste/locale/Windows con motivo.
- 1 error de ejecución: `mv: cannot stat …/.arnes/c2` (sección 33, preexistente, sin efecto).
- Check `hooks-en-linux` = SUCCESS. CA-13 tiene su evidencia sobre esta cabeza; la entrega sigue bloqueada por QA-025-08.
