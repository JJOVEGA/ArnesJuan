# Procedencia de instrucciones de las comisiones de REQ-030/REQ-031 (2026-09-28)

Método: la sesión coordinadora corre con cwd /home/juan/dev/ArnesJuan (rama rel/registro-1.33.0) y su system prompt carga CLAUDE.md -> @AGENTS.md de ese worktree. Cada subagente recibe el mismo bloque «Contents of <cwd>/AGENTS.md». Se cuenta en el transcript JSONL de cada comisión (tasks/<id>.output) la cadena de carga y una frase que sólo existe en cada versión: rel = «Reglas de trabajo de la sesión coordinadora» (§14); main = «elegir vía no lo toca» (§6).

| comisión | Contents of /home/juan/dev/ArnesJuan/AGENTS.md | frase sólo-rel | frase sólo-main | lecturas explícitas de ArnesJuan-req031/AGENTS.md |
|---|---|---|---|---|
| analista-REQ031 | 2 | 2 | 0 | 19 |
| desarrollador-REQ031 | 1 | 2 | 0 | 17 |
| qa-REQ031 | 1 | 2 | 1 | 4 |
| auditor-REQ031 | 1 | 2 | 0 | 0 |
| qa-REQ030 | 1 | 2 | 0 | 0 |
| auditor-REQ030 | 1 | 2 | 0 | 0 |

Versiones: rel/registro-1.33.0 AGENTS.md = 503 líneas (R-024: 1); main a7a60c2 = 807 líneas (R-024: 0). Divergencia: 123 commits sólo en rel, 101 sólo en main, base común 5e53f12.

Diff por sección (main -> rel): §5 0/0 · §6 +4/-352 · §7 0/0 · §13 +3/-2 (main: fila 'retorno de carro interior'; rel: celda ancha 'no puede medir' con BOM/ZWSP/R-024, y el marcador arnes:coordinacion) · §14 +51/0. Procedencia de la celda ancha y de R-024 en rel: commits 1154417 (SEC-079) y ef82d43 (R-024), 2026-09-09.
