# Evidencia de QA — REQ-017 `CA-03`, modo intercalado · base `86a44c8`

**Base medida:** `rel/registro-1.33.0` @ **`86a44c8`**. Árbol de trabajo con **un solo**
archivo modificado, `docs/ESTADO.md`, y su diferencia es **sólo** el bloque
`ARNES:DERIVADO` que reescribe el hook de continuidad (fecha, commit, cola 14→15).
No toca `hooks/`, `tools/`, `tests/` ni `requirements/`, así que **no altera nada de lo
medido aquí**; se comprobó con `git diff docs/ESTADO.md` antes de empezar.

**Máquina:** Linux 6.18 (WSL2), **12 núcleos**, bash 5.3, `plataforma=linux-gnu-x86_64-bash5.3`.
**No es el runner del CI** (4 vCPU, `ARNES_JOBS=6`): la limitación es material y se declara.

## Qué hay en cada archivo

| archivo | qué es | cómo se obtuvo |
|---|---|---|
| `banco-completo-jobs6.txt` | banco entero, la puerta requerida | `ARNES_JOBS=6 bash tests/escenarios/hooks/run.sh` · `loadavg` antes/después y marcas de tiempo UTC dentro del propio archivo |
| `5-corridas-aisladas.txt` | 5 corridas de `37/2` con máquina en reposo | `bash tests/escenarios/hooks/run.sh secciones/37-coste-del-escaner-2-las-razones.sh`, 5 veces, con `loadavg` previo **fila a fila** |
| `3-corridas-cpu-saturada.txt` | 3 corridas con **12 quemadores en 12 núcleos** | igual, con `for i in $(seq 12); do (while :; do :; done) & done` y 20 s de calentamiento antes de la primera |
| `ataque-banda.sh` + `ataque-banda-salida.txt` | falsación de `banda37` con **oráculo independiente de QA** | las funciones `num37`/`mil37`/`banda37`/`razon37` se extraen **literalmente** del archivo de sección con `sed -n '/^banda37() {/,/^}$/p'` y se comprueba que el cuerpo es **idéntico** (`md5sum` del rango: `36c50b30` para `banda37`, `a2ae4c0a` para `razon37`) antes de creer un solo resultado |
| `mutar.sh` | arnés de mutación | copia `37/2` a un `git worktree add --detach 86a44c8`, aplica un `sed`, **comprueba con `cmp` que la mutación tomó efecto y con `bash -n` que compila**, y corre la sección. El worktree se retira al terminar |

## Estadístico
**Mediana y MAD, nunca el rango** (el rango es monótono no decreciente en el número de
muestras). `n = 5` en reposo, `n = 3` saturado. Cada cifra va con su `loadavg`.

## Cifras derivadas de `5-corridas-aisladas.txt` (n = 5, reposo, carga 0,39–0,86)

| magnitud | mediana | MAD |
|---|---|---|
| `hi` de la directa — **el extremo que DECIDE** | **2,106×** | 0,004 |
| `lo` de la directa | 2,002× | 0,033 |
| cociente de la directa | 2,062× | 0,008 |
| `lo` del fail-before — **el que decide ahí** | 3,709× | 0,029 |
| anchura `hi/lo` de la directa | 1,050 | 0,016 |

**Margen al techo 2,600×**, según con qué se mida:
con el **cociente** mediano, **20,7 %**; con el **`hi`** mediano —que es lo que decide desde
el write-back de la banda— **19,0 %**; con el `hi` observado en el **banco entero**
(2,453×), **5,7 %**; y bajo CPU saturada el `hi` llegó a **2,716×**, que **cruzó** el techo
y produjo la abstención.
