# Sondas de la revisión R-030 — re-firma del parche v1.33.2 tras la corrección de `SEC-087`

**Versión base sobre la que se midió:** `hotfix/1.33.2-rigor` @ **`d82d6cd`**, árbol limpio
(`git status --porcelain` vacío).

**Las dos sondas son autojuzgadas y discriminantes.** Devuelven `rc 0` sobre `d82d6cd` y `rc 1`
sobre la **1.33.1 publicada** —el lector con el defecto vivo—, así que no pasan por vacío. El
control negativo va corrido y anotado abajo; una sonda que no puede fallar no es evidencia.

| Sonda | Qué propiedad comprueba | `d82d6cd` | 1.33.1 publicada |
|---|---|---|---|
| `caza-nivel-exento.sh` | la mitad **absoluta** del contrato: *ninguna forma que contenga `(` alcanza `ligero`*, el único nivel exento de `QA: aprobado` | **0** de 1148 lecturas · `rc 0` | **444** de 1148 · `rc 1` |
| `frontera-mal-formado.sh` | la **frontera** que el contrato nombra: la única protección que un paréntesis mal formado puede perder es un `critico` declarado en un REQ no efectivamente sensible | 10 celdas cambian, **0 fuera** de la frontera · `rc 0` | 20 cambian, **10 fuera** · `rc 1` |

**Uso** (el segundo argumento y el lector son opcionales; por defecto, este árbol):

    bash docs/seguridad/sondas-R-030/caza-nivel-exento.sh [lib.sh] [alfabeto]
    bash docs/seguridad/sondas-R-030/frontera-mal-formado.sh [lib.sh]

## Método

`caza-nivel-exento.sh` recorre `alfabeto-hostil.txt` —**287 formas** generadas por combinación de
6 escrituras de `ligero` (limpia, mayúsculas, capitalizada, con tilde, con blancos por delante y
por detrás) × 47 patrones de paréntesis hostiles: sin cerrar, sólo abriente, anidado, vacío,
doble, pegado, con texto detrás del cierre, invertido, decorado por fuera y por dentro (`**`,
`_`, `` ` ``), con TAB, con espacio de anchura cero, con acento, y con metacaracteres de shell
(`$`, `` ` ``, `|`, `;`, `#`, comillas, salto de línea)— por **4** estados de
`Sensible a seguridad:` (`si`, `no`, ausente, no reconocido). Se filtran las que llevan `(`:
**1148 lecturas**.

`frontera-mal-formado.sh` compara, para cada uno de los **3** niveles × **4** estados de
sensibilidad, el matiz **cerrado** `<nivel> (x)` contra **5** formas mal formadas del mismo
nivel, y marca como **fuera de la frontera** toda pérdida que no sea `critico` con sensibilidad
efectiva distinta de `si`. **60 pares.**

## Lo que estas sondas NO son

No son el banco ni una quality gate, y no sustituyen a ninguno: el banco
(`tests/escenarios/hooks/run.sh`) es de QA y de CI. Estas dos sólo sostienen las **dos
afirmaciones del contrato** que `R-030` tenía que verificar.

## Nota sobre la afirmación absoluta

`caza-nivel-exento.sh` la comprueba por **barrido**, pero la propiedad además se sigue **por
construcción** —el argumento, en dos casos, está en `registro-seguridad.md` § R-030 §2—. El
barrido no es lo que la sostiene: es lo que la habría desmentido si fuese falsa.
