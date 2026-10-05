# cand-1.36.0/ca54 — fase 1 de la décima autorización (CA-54): sondas restauradas, línea base y referencia

Registro técnico con la lectura completa: `docs/arnes/v1.36.0-ca54-fase1.md` en el worktree `ArnesJuan-v1.36`
(rama `cand/1.36.0`, cabeza `cdcf649` al medir). Contrato: REQ-007, nota de CA-54 del 2026-10-03.
Sin optimizar nada: el «candidato» de esta fase son los hooks de `cdcf649`, idénticos a `v1.35.0`
(`git diff v1.35.0 cdcf649 -- hooks tests tools` vacío).

| Archivo | Qué es |
|---|---|
| `00-diff-sondas-frente-a-originales.txt` | `diff -u` de las cuatro piezas restauradas frente a las de `cand-1.35.0/`, registrado **antes** de medir. Sólo rutas: la línea `source` y, en la biblioteca, `Q`, `CAND`, `BASE` y `T43`. |
| `s1/` | S1 = `cand-1.35.0/evidencia-qa-sec119/sonda-ca54-qa.sh` + su `qa-lib.sh`. `trabajo/` es su carpeta `Q` (proyectos y entradas que genera). |
| `s2/` | S2 = `cand-1.35.0/evidencia-dev-r6/sonda-ca54/sonda-r6-extra.sh` + su `qa-lib.sh`. `trabajo/` es su carpeta `Q`. |
| `arboles/v1.35.0/hooks/` | `git archive v1.35.0 hooks`, verificado archivo por archivo por oid (10/10) contra el tag. Árbol `BASE` de S1 y S2, y `T43` de S2. |
| `10-s1-reloj.txt` | S1, salida tal cual. Columna `9596e39` = v1.35.0; columna `candidato` = `/home/juan/dev/ArnesJuan-v1.36/hooks`. |
| `11-s2-reloj.txt` | S2, salida tal cual. `BASE` y `T43` apuntan a la misma ruta de v1.35.0, así que la sonda asigna las dos a la columna `9596e39` (10 corridas por línea) y la columna `43b948a` sale vacía. |
| `procesos-ca54.sh` / `12-procesos.txt` | Conteo con `tests/util/sonda-procesos.sh` (invocado, sin cambios) sobre las 10 entradas de S1 y S2, con los dos árboles, después del reloj y en la misma sesión. El conteo del sujeto es `cuenta=`; `procesos=` suma además los 3 de la propia sonda. |
| `20-INVALIDA-banco-con-hooks-sin-tools-hermano.txt` | Primera corrida del banco, **inválida por invocación**: `ARNES_HOOKS_DIR` apuntaba a `arboles/v1.35.0/hooks`, que no tiene `tools/` hermano, y el banco busca `$HOOKS_DIR/../tools/` (`run.sh` línea 461): 99 FAIL con rc 127 / informe vacío. Se conserva; no es referencia. |
| `21-banco-v1.35.0-con-hooks-v1.35.0.txt` | Banco de `v1.35.0` tal cual, desde el worktree `/home/juan/dev/ArnesJuan-v1.35.0-base` (detached en `3956a6f`, limpio), con `ARNES_HOOKS_DIR` en sus propios `hooks/`: 2038 PASS, 0 FAIL, 12 SKIP (1 INCONCLUSO), rc 0. |
| `22-inventario-v1.35.0.txt` | `inventario.sh` sobre `21-…`: 2050 líneas, 194 504 bytes, sha256 `f35c9c04f348148a608ba821bdd744c827fc48d9a5b8c433edf7569ea527c436`. **Referencia caso a caso de CA-69 punto 2 (a).** |

## Fase 2 (2026-10-03 a 2026-10-05) — registro técnico: `docs/arnes/v1.36.0-ca54-fase2.md` del worktree

| Archivo | Qué es |
|---|---|
| `fase2-mide.sh` | Lanza S1, S2 y `procesos-ca54.sh` en la misma sesión, con la carga y los sha256 de las sondas y de `hooks/lib.sh` en la cabecera. |
| `30-s1-reloj.txt`, `31-s2-reloj.txt` | **Medición final** (código con el atajo readmitido por P-136-D; `lib.sh` `d43d374b…`): 35/35 del candidato < 5 000 ms, máximo 3 711 ms; decisiones y rc de v1.35.0. |
| `32-procesos.txt` | Medida del contrato (`sonda-procesos.sh`), misma sesión: `cuenta=` igual en los dos árboles (2/3/4). |
| `35-procesos-pidns.txt` + `forks-pidns.sh` | Complementaria y exacta (espacio de PID propio): candidato −1 en S1, = en S2. |
| `34-salidas-identicas.txt` + `salidas-identicas.sh` | stdout+rc+stderr de los dos árboles, byte a byte, en las 10 entradas: idénticos. |
| `40-…`, `41-inventario-candidato.txt`, `42-diff-inventarios.txt` | Banco de v1.35.0 con los hooks del candidato y `ARNES_SEMILLA_41=23062`: 2050 líneas, sha256 `f35c9c04…` = `22-`; diff vacío. |
| `43-*` | Sección 41 sola con la semilla de la referencia, en los dos árboles (diagnóstico de la parada del 2026-10-03). |
| `44-banco-worktree.txt`, `45-autoprueba.txt`, `46-gates.txt` | Banco del worktree 2038/0/12 (2050), autoprueba 117/0, gates rc 0. |
| `con-atajo-retirado/` | Primera medición con el atajo (2026-10-03; 0/35 ≥ 5 s, máx. 3 811 ms), su inventario con la semilla al azar (1 línea distinta), `33-forks-nucleo.txt` (contador del núcleo: ruidoso, no acredita) y el parche de entonces. |
| `sin-atajo-parada/` | Medición sin el atajo (2026-10-03): S1 B 5 213 ms → parada y P-136-D; procesos y salidas de esa sesión; parche. |
| `diferencial/` | Arneses de comparación diferencial y su `RESUMEN.txt` (apoyo al desarrollo, no evidencia del contrato). |
