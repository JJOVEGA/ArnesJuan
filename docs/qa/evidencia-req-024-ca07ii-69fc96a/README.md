# Evidencia de la QA acotada de `REQ-024 CA-07 (ii)` — 2026-09-11

**Versión base:** worktree `/home/juan/dev/ArnesJuan-1.34-reparaciones`, rama
`feat/1.34-reparaciones-astra`, commit **`69fc96a`** con los cambios del `desarrollador`
**sin comitear** (`tests/escenarios/hooks/run.sh`, `…/secciones/40-ausencia-que-abre-2-…sh`,
`…/secciones/40-ausencia-que-abre-7-…sh` nuevo, `docs/arnes/req-024-ca-07-ii-reparacion/`).
Línea base de las razones: tag **`v1.33.0`**. Host: WSL2, **12 núcleos** (el del desarrollador
declara 8 — las cifras de dispersión no son comparables una a una, y se dice).

**Herramienta:** ninguna del banco se modificó. `hooks/`, `tools/` y `tests/util/` quedan
**idénticos a `HEAD`** (`git diff --stat HEAD -- hooks tools tests/util` sale vacío), luego
`tests/util/sonda-reloj.sh` **no se tocó** — comprobado, no aceptado por declarado.

## Inventario, elemento por elemento

| archivo | qué es | cómo se re-deriva |
|---|---|---|
| `driver-qa.sh` | mide `KRAZ` pares intercalados con la **sonda real** y decide con las **funciones reales** `razon07`/`veredicto07` extraídas de la sección, sin reimplementarlas | `DIR_A=<árbol> DIR_B=<base> K07=<k> SER07=<r> KRAZ07=<n> bash driver-qa.sh` |
| `extracto-decisor-40-7.sh` | `num07`, `fmt07`, `razon07`, `veredicto07` extraídos **por rango de línea** de `secciones/40-ausencia-que-abre-7-el-reloj-de-la-ruta-critica.sh` (líneas 26, 138-139, 164-233) | `{ sed -n '26p' $SEC; sed -n '138,139p' $SEC; sed -n '164,233p' $SEC; }` |
| `extracto-helpers-run.sh` | `SONDA`, `sonda_num`, `sonda_es_util`, `sonda_lee` de `run.sh` (líneas 415-482) | `sed -n '415,482p' tests/escenarios/hooks/run.sh` |
| `fixture-fiel.sh` | reconstruye el **sujeto fiel**: el proyecto **vacío** al que apunta `CLAUDE_PROJECT_DIR` dentro del banco, más el JSON de entrada | `bash fixture-fiel.sh <dir>` |
| `falsacion-sintetica.sh` | batería de entradas límite contra las funciones reales (unanimidad, borde exacto del techo, cero repeticiones, no numérico, denominador 0, árbol más rápido) | `bash falsacion-sintetica.sh <dir con los dos extractos>` |
| `ktabla-rederivada-por-qa.txt` | la derivación de `KRAZ07=4` **re-hecha por QA** sobre las **12 condiciones × 25 razones = 300** del artefacto del desarrollador, con **su** `ktabla.awk` | `for f in fase1-*.txt fase1c-*.txt fase3-*.txt fase3c-*.txt; do awk -v ARCHIVO=$f -f ktabla.awk $f; done` |
| `corridas.txt` | **todas** mis corridas: 2 del banco entero limpio, 2 con regresión de ~1,35×, 5 con regresión de ~1,28×, la nula propia y la falsación sintética | ver más abajo |

## Cómo se inyectó la regresión (nunca en el árbol)

El árbol **no se tocó**. Se copió el worktree entero a un directorio de trabajo
(`cp -a`; el archivo `.git` del worktree apunta por ruta **absoluta**, así que `git -C` sigue
resolviendo `v1.33.0` desde la copia) y en la copia se insertó **una línea** tras el shebang de
`hooks/guard-completado.sh`:

```bash
for ((_qa=0;_qa<N;_qa++)); do :; done   # sólo quema reloj; no cambia ninguna decisión
```

`N=2600` ≈ **+2,3 ms** por invocación (razón verdadera ≈ **1,35×**) y `N=1500` ≈ **+1,3 ms**
(razón verdadera ≈ **1,28×**, que es **la magnitud de los rojos de CI**: 1,257×–1,338×).
Calibración del bucle, medida en este host: **0,875 µs/iteración**, arranque de `bash` 2,65 ms
(10 vueltas a `N=10000` = 11,4 ms/vuelta; a `N=50000` = 46,4 ms/vuelta).
Coste base de una invocación del sujeto fiel: **15,0 ms** (20 invocaciones en 0,301 s).
