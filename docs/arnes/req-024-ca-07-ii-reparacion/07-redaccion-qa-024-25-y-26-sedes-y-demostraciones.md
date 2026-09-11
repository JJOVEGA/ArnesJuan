# `QA-024-25` y `QA-024-26` en el PROGRAMA: sedes corregidas y demostración de invariancia

**Comisión:** extensión excepcional y acotada de la **vuelta 4 de `REQ-024`**, autorizada por el
propietario el **2026-09-11**. El contador **no se reinicia ni se renombra**: sigue siendo la
vuelta 4.

**Alcance:** retirar la **atribución absoluta** («es regresión, no ruido» / «así que no lo puso ahí
el vecino») de **los mensajes que el programa imprime**, y reetiquetar el **suelo de detección**
como dato diagnóstico. **Sólo redacción**: ni una rama de decisión, ni un umbral, ni un `rc`.

## Versión base y método

| | |
|---|---|
| **Worktree** | `/home/juan/dev/ArnesJuan-1.34-reparaciones` |
| **Rama** | `feat/1.34-reparaciones-astra` |
| **Cabeza (base de todas las medidas)** | **`f612b84`** |
| **Máquina** | WSL2, `linux-gnu-x86_64-bash5.3`, 12 núcleos, carga 0,55–1,28 |
| **Sujeto `+3700`** | copia de `hooks/` en scratchpad con `for ((_qa=0;_qa<3700;_qa++)); do :; done` tras el shebang de `guard-completado.sh` (receta de `QA-024-21`). **`hooks/` del repo NO se tocó** — verificado: `git diff --name-only -- hooks/` devuelve vacío |
| **Invocación** | `ARNES_HOOKS_DIR=<copia> ARNES_SECCIONES_DIR=<dir> bash tests/escenarios/hooks/run.sh` |

El «antes» **no** se obtuvo con `git stash` —`guard-git` lo denegó, y con razón: el árbol tiene
trabajo sin comitear del analista—. Se materializó `git show HEAD:<sección>` en un **directorio
hermano** de `secciones/` (misma profundidad, para que `REPO07="${SEC_DIR%/}/../../../.."` siga
resolviendo a la raíz), se midió, y se borró.

## Las sedes: barrido por propiedad, no por lista

Criterio del barrido: **toda cadena, mensaje o comentario en `tests/` que afirme la causa** de un
`mín(r) > techo` (atribuirlo al código y descartar el vecino/ruido), más el **rótulo** del suelo.

| # | Sede | Qué era | Estado |
|---|---|---|---|
| 1 | `secciones/40-…-7-…sh` · mensaje `FAIL` de `REQ-024 CA-07 (ii)` | «es regresión, no ruido» | **corregida** |
| 2 | `secciones/37-…-5-…sh` · mensaje `FAIL` de `REQ-017 CA-08 (ii)` | «es regresión, no ruido» | **corregida** |
| 3 | `secciones/40-…-7-…sh` · comentario del decisor | «excedido en TODAS, así que no lo puso ahí el vecino» | **corregida** |
| 4 | `secciones/37-…-5-…sh` · comentario del decisor | ídem (transcripción hermana, **no estaba en el encargo**) | **corregida** |
| 5 | `secciones/40-…-7-…sh` · rótulo `suelo de detección` en `LISTA07` | leíble como umbral (`QA-024-26`) | **reetiquetada** |
| 6 | `secciones/40-…-7-…sh` · comentario de `FACTOR07` | calibración `1,28×` sin declarar que quedó sustituida | **corregida** |
| 7 | `secciones/40-…-7-…sh` · demostración 3/4 | «la magnitud de los rojos REALES de CI», leíble como «esos rojos eran regresiones» | **precisada en comentario** (el nombre del caso no se tocó: es su identidad en el inventario) |
| 8 | `escenarios/hooks/README.md` · «lo que separa una serie de sí misma es el vecino» | premisa de la que se derivaba la atribución; **no estaba en el encargo** | **corregida con el recíproco explícito** |

**Fuera de `tests/`, y NO tocado por no ser de esta comisión** (se reporta, no se corrige):

- **`requirements/REQ-017.md:118`** — el contrato de `REQ-017 CA-08 (ii)` sigue diciendo
  «**FAIL** si `mín(r) > techo` —excedido en **todas**, así que no lo puso ahí el vecino—».
  **Esa frase queda desfasada** por `QA-024-25`. Es **otro REQ** y el write-back lo decide el
  propietario. La deriva es de la **justificación** del contrato, **no** de su regla ni de lo que
  el mensaje publica: la regla `mín(r) > techo → FAIL` se cumple igual, y las tres cosas que el
  contrato exige publicar —las k razones, el recorrido y el techo— se siguen publicando íntegras.
- `docs/qa/…`, `CHANGELOG.md` y los apartados `02`/`05` de esta misma carpeta **citan** el texto
  viejo como **evidencia de lo que decía**. Es correcto que se queden: son el registro del hallazgo.
- `requirements/REQ-024.md` ya lleva el write-back hecho **por el analista en paralelo** (`:402`,
  `:1557`).

## El texto nuevo (`40/7`), tal como el programa lo imprimió en la corrida `+3700`

```
  FAIL  REQ-024 CA-07 (ii) el reloj de la ruta crítica no pasa de 1,25× la línea base  mín(r)
  1.339× > techo en TODAS las repeticiones: LA MEDICIÓN EXCEDE EL TECHO Y NO SE ACREDITA
  CUMPLIMIENTO. Esto NO afirma que haya regresión del CÓDIGO ni descarta el RUIDO: la unanimidad
  acota la dispersión DENTRO de esta corrida y NO la de ENTRE corridas, y está MEDIDO que la
  segunda es un orden de magnitud mayor que el recorrido que esta misma línea publica (QA-024-25:
  12 corridas del MISMO árbol CONFORME, razón verdadera 1,177×, recorrieron 1,095×–1,490× y dieron
  7 PASS y 5 FAIL sin cambiar un byte). Un FALSO RECHAZO sobre un candidato CONFORME es por tanto
  una limitación ABIERTA de este instrumento, y esta redacción NO la resuelve. Bloquea igual —una
  puerta que no puede acreditar no deja pasar— y el techo es OPERATIVO y no se sube: lo que baja es
  el coste del lector — 4 razones: 1.384× 1.339× 1.386× 1.397× · recorrido 1.043× · techo 1.250× ·
  suelo estimado 1.303× (DIAGNÓSTICO de esta corrida: no es umbral y no gobierna ninguna rama;
  derivado del recorrido intra-corrida, subestima si la dispersión que manda es la de entre
  corridas) · peor convergencia 1.030× · k=8 r=30 · máquina linux-gnu-x86_64-bash5.3 · carga 1.19
  · jobs 6
```

Cumple las tres condiciones del propietario: **describe fielmente** («la medición excede el techo;
no se acredita cumplimiento»), **bloquea**, y **no afirma** haber demostrado una regresión del
código ni haber descartado el ruido. Y dice, donde se lee, que el **falso rechazo sobre un
candidato conforme sigue siendo una limitación abierta** que esta redacción no resuelve.

## `QA-024-26`: el suelo se reetiqueta y NO pasa a gobernar

El hallazgo era que el suelo se publica y **no gobierna ninguna rama**. Sigue siendo así **a
propósito** — el propietario pidió describirlo como dato diagnóstico, **no** convertirlo en garantía
ni añadir lógica para justificar el nombre. Verificado leyendo el código: `suelo` aparece
exactamente en **dos** sitios ejecutables —donde se calcula (`local suelo="$FMT07"`) y donde se
interpola (`LISTA07=…`)— y en **ninguna** condición de `razon07`, `resuelve07`, `cierre07` ni
`veredicto07`. El rótulo pasa de `suelo de detección` a `suelo estimado … (DIAGNÓSTICO de esta
corrida: no es umbral y no gobierna ninguna rama; derivado del recorrido intra-corrida, subestima
si la dispersión que manda es la de entre corridas)`.

## La calibración de `1,28×` queda declarada como sustituida

Escrito en el propio comentario de `FACTOR07`: el forzador `+1500` con que `QA-024-21` calibró ese
`1,28×` vale, medido, una razón verdadera de **`1,177×`** —**bajo** el techo de `1,250×`—, así que
no era el caso límite que se creyó; el caso realmente por encima del techo es **`+3700`**. `1,280`
se conserva como **magnitud sintética de entrada** del par discriminante (es un dato de una
demostración, no un umbral) y **su valor no se toca**, porque moverlo cambiaría una decisión. Y
queda dicho que **no es una constante universal** ni «la magnitud» de una regresión detectable: eso
depende del host, la carga y el momento, y la dispersión entre corridas de un árbol conforme
(`1,095×–1,490×`) **se solapa** con él.

## Demostración de que la decisión y los `rc` NO cambian

Cinco pruebas independientes. **Ninguna supone: todas se ejecutaron.**

### (1) Diff estructural — el código es idéntico

Quitando líneas de comentario y sustituyendo el contenido de cada cadena `"…"` por `"S"`, el diff
de ambos archivos contra `HEAD` es **vacío salvo la línea `PISO_AUTONOMO_SECCION`** (contabilidad
de `REQ-014 CA-18`, no una decisión del criterio). Es decir: **ni una condición, umbral, operación
aritmética, contador ni `rc` cambió.**

### (2) Constantes — literalmente las mismas

`TECHO07=1250`, `FACTOR07=1280`, `KRAZ07=4`, `K07=8`, `SER07=30`, `INTENTOS07=3`; `TECHO47=1250`,
`FACTOR47=2000`, `KRAZ47=4`, `K47=4`, `SER47=6`. Diff **vacío** (sólo se desplazó el número de
línea de `INTENTOS07`).

### (3) Líneas de condición y de contador — byte a byte

**72** líneas en `40/7` y **86** en `37/5` que contienen `if`/`elif`/`case`/`while`/`return`/`exit`
o `PASS=$…`/`FAIL=$…`/`RES07=`: diff **vacío** en ambos.

### (4) Rejilla ejecutable sobre el decisor real

Se extrajeron `resuelve07`/`cierre07` de las dos versiones y se ejecutaron sobre **11** entradas —
incluidos los bordes exactos del techo y las cuatro formas de inconclusión—. **Decisión y cierre
idénticos en las 11.** El borde manda igual:

| entrada | `RES07` | `cierre07(1)` | `cierre07(3)` |
|---|---|---|---|
| `1.250×` (borde exacto) | `pass` | emitir | emitir |
| `1.251×` | `fail` | emitir | emitir |
| `1.249×` | `pass` | emitir | emitir |
| unánime `1.300×` | `fail` | emitir | emitir |
| mezcla `1.000×`/`1.300×` | `inconcluso` | **reintentar** | **sin-acreditar** |
| no converge · bajo suelo · falta un número | `inconcluso` | reintentar | sin-acreditar |

Techo de `1,250×`, unanimidad y límites de intentos: **intactos**.

### (5) `rc` de extremo a extremo — lo que de verdad bloquea

| sujeto | versión | corridas | veredicto del caso real | `rc` |
|---|---|---|---|---|
| `+3700` | **antes** (`f612b84`) | 3 | `FAIL` 3/3 | **1** 3/3 |
| `+3700` | **después** | 3 | `FAIL` 3/3 | **1** 3/3 |
| conforme (sin inyección) | **antes** | 2 | `PASS` 2/2 | **0** 2/2 |
| conforme (sin inyección) | **después** | 2 | `PASS` 2/2 | **0** 2/2 |

**Ningún resultado antes bloqueante pasó a verde.** Un `FAIL` sigue saliendo con `rc 1`.

### Banco completo y puertas

| | antes | después |
|---|---|---|
| Banco completo | 1087 PASS, **0 FAIL**, 8 SKIP, `rc 0` | 1086 PASS, **0 FAIL**, 9 SKIP, `rc 0` |
| `autoprueba-corredor.sh` | — | **106 PASS, 0 FAIL** (incluye las 7 comprobaciones de `CA-18`) |
| `bash -n` de `hooks/`, `tools/` y todo el banco | — | OK |
| `jq -e` de `hooks.json`, `plugin.json`, `marketplace.json` | — | OK |

**Los 12 casos de los dos archivos tocados conservaron su veredicto** (`REQ-024 CA-07 (ii)` ×6 y
`REQ-017 CA-08 (ii)` ×6, con el mismo `PASS`/`SKIP` que antes).

**La diferencia de 1 PASS → 1 SKIP se conserva como evidencia y NO se atribuye a esta comisión sin
prueba** (la variabilidad no se desmiente repitiendo hasta el verde). El caso que basculó es
**`REQ-017 CA-03 el escáner no crece más que linealmente: doblar la línea no cuadruplica`**, que
vive en **`secciones/37-coste-del-escaner-2-las-razones.sh`** — archivo con **0 cambios** en esta
comisión (`git diff --name-only` vacío para él). Es una sonda de reloj que se **abstiene** cuando su
banda no resuelve; la misma corrida movió además semillas y tamaños de corpus de `REQ-023 CA-03` y
`CA-04`, que son sorteos por corrida. Dirección del cambio: `PASS → SKIP` (abstención), **no** a
verde. `FAIL` siguió en **0** y `rc` en **0** en las dos corridas.

## Contabilidad de `REQ-014 CA-18` actualizada

Las líneas añadidas caen **dentro del bloque indivisible** de cada archivo, así que el tercer
término y el total se re-derivaron en vez de dejarlos falsos:

| archivo | piso antes | piso después | líneas | techo `max(400, piso×1,25)` |
|---|---|---|---|---|
| `40-…-7-…sh` | 449 (`23+73+353`) | **485** (`23+73+389`) | 485 | 606 |
| `37-…-5-…sh` | 448 (`21+100+327`) | **467** (`21+100+346`) | 523 | 583 |

Verificado por la autoprueba: los términos **suman** el valor declarado, el piso **cabe** en el
archivo y **ningún** archivo excede su techo.

## Lo que esta comisión NO hizo

Techo de `1,250×`, unanimidad, límites de intentos y códigos de salida: **intactos**. No se añadió
ni un caso, ni una condición, ni una rama. No se tocó `requirements/`, `hooks/`, `tools/`,
`.github/`, `.arnes/`, `.claude-plugin/` ni `docs/qa/`. No se investigó cómo eliminar la
variabilidad (excluido expresamente). **No se comiteó.**

Y lo que **sigue abierto**, dicho aquí y en el propio mensaje: el **falso rechazo sobre un candidato
conforme** es una limitación del instrumento que **esta corrección de redacción no resuelve**.
Documentar un residuo no es remediarlo.
