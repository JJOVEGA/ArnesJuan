# Hotfix 1.36.2, fase 1: evidencia del desarrollador (REQ-033 CA-01 a CA-07)

- **Fecha:** 2026-10-16. **Máquina:** Linux/WSL2, bash 5.3.9.
- **Candidata:** árbol de trabajo de `hotfix/1.36.2` sobre `c470757`, **sin commit**: la coordinadora decide el commit.
  Su diff es `diff-candidata.patch` (sha256 empieza por `6e092bafe913b57d`).
- **Línea base:** hooks de `v1.36.1` (`e21baef`). `linea-base-diff-r.txt`: `git archive v1.36.1 hooks` y la caché
  instalada `~/.claude/plugins/cache/arnes-juan/arnes-juan/1.36.1/hooks` son idénticos (`diff -r`). En la sección 49,
  `mat49` los vuelve a materializar por SHA en cada corrida y comprueba contenido y modo de cada archivo.

## Archivos
| Archivo | Qué es |
|---|---|
| `banco-v1.36.1-hooks.txt` | el banco de `c470757` (sin la 49) con los hooks de v1.36.1 en el árbol: 2850 PASS, 0 FAIL, 12 SKIP (2862) |
| `banco-candidata.txt` | el banco completo con la 49, sobre la candidata: 2940 PASS, 0 FAIL, 12 SKIP (2952), rc 0 |
| `inventario-*.txt`, `inventario-diff.txt` | inventarios (`inventario.sh`) y su diferencia: los 90 casos nuevos de la 49 y la semilla al azar de REQ-023 CA-03 (sorteo, no identidad); ningún caso cambia de veredicto |
| `seccion-49.txt` | las líneas de la 49 en la corrida de la candidata: candidata y v1.36.1 en la MISMA corrida, por fila |
| `autoprueba-candidata.txt` | autoprueba del corredor: 117 PASS, 0 FAIL |
| `gates.txt` | las tres quality gates de `AGENTS.md` §7 |
| `sondas.sh`, `sondas.txt`, `sondas-ad-hoc.txt` | sondas fuera del banco: formas límite (se juzgan, no se ejecutan) |
| `49-manifiesto-y-origen-de-mv.sh` | copia de la sección nueva |

## Limitaciones que el banco no cubre (declaradas, no medidas como garantía)
Ver el informe de la fase 1 y la fila del Historial de REQ-033.
