# REQ-024 CA-07 (ii) — diagnóstico: dispersión del instrumento, con coste real por debajo del techo

> **Versión base:** worktree `/home/juan/dev/ArnesJuan-1.34-reparaciones`, rama
> `feat/1.34-reparaciones-astra`, commit `69fc96a`; línea base tag `v1.33.0`.
> **Método y repeticiones:** `00-metodo-y-plan.md` (escrito antes de medir, con su adenda).
> **Datos crudos, registro a registro:** `corridas/`. **Tablas derivadas:** `corridas/tablas.md`.
> **Re-derivar:** `bash docs/arnes/req-024-ca-07-ii-reparacion/medir.sh <fase> <n>`.

## Respuesta, en una línea

**Las dos cosas, y en esta proporción:** hay un coste real de **1,118×** (medido con precisión
suficiente para que la nula colapse a 0,984×–1,005×), que **cumple** el techo de 1,250× con
margen; y hay una **dispersión del instrumento de ±0,21** a los parámetros con los que el caso
decide, que es lo que lleva mediciones sueltas por encima del techo. **Los FAIL de CI eran del
instrumento, no del código**: no hay hallazgo contra el código de esta rama.

## La medición que lo decide: la DISTRIBUCIÓN NULA

Un cociente no se juzga contra una intuición. Se juzga contra lo que el mismo instrumento
produce cuando el cociente verdadero es **exactamente 1,000×**: el mismo árbol materializado dos
veces, en dos directorios distintos, medido con los mismos mandos.

**Sujeto FIEL al banco** (`fase3c`: `k=4 r=6`, 4 CPU + 6 vecinos, 25 repeticiones por condición):

| condición | verdad | mín | mediana | máx | ¿algún > 1,250×? |
|---|---|---|---|---|---|
| `AB` rama vs `v1.33.0` | desconocida | 0,995× | **1,165×** | **1,333×** | **2 de 25** |
| `AA` rama vs rama (NULA) | **1,000×** | 0,909× | 1,021× | **1,180×** | 0 de 25 |
| `BB` base vs base (NULA) | **1,000×** | 0,875× | 1,017× | **1,213×** | 0 de 25 |

Las dos nulas tienen **verdad 1,000× por construcción** y aun así recorren 0,875×–1,213×. Esa es
la resolución real del instrumento a `k=4 r=6` bajo contención: **±0,21**, contra un techo que
vive a +0,25 del 1,000×. **El techo está DENTRO del ruido del instrumento**, que es la definición
de una puerta que no puede medir.

Y no basta con la guarda de convergencia que ya existía en el criterio hermano: la repetición 21
de `fase3c-BB` da **razón 1,213× con los dos brazos convergidos a 1,176×** (< 1,250×). Convergir
es **necesario y no suficiente**: responde «¿se asentó cada serie?», no «¿resuelve este cociente
el factor que vigila?».

## El coste real, medido con resolución suficiente (`fase4`: `k=8 r=30`, 9 repeticiones)

| condición | verdad | mín | mediana | máx |
|---|---|---|---|---|
| `AB` rama vs `v1.33.0` | desconocida | 1,059× | **1,118×** | 1,129× |
| `AA` rama vs rama (NULA) | **1,000×** | 0,984× | 1,000× | 1,005× |

La nula **colapsa a ±0,01**, o sea que a `k=8 r=30` el instrumento sí resuelve; y sobre ese
instrumento el cociente verdadero es **1,118×**, con el máximo de nueve repeticiones en 1,129×,
**muy por debajo de 1,250×**. Hay coste real —**no** es cero—, y **cumple el criterio**.

## Que el FAIL no lo introdujo el delta de `#48`

Tres cosas, y ninguna es un razonamiento sobre el diff:

1. **Uno de los tres FAIL de CI (1,320×) es sobre `67b06fe`**, ancestro del destino y **anterior**
   al cambio de `hooks/lib.sh` de `#48`. El instrumento ya fallaba sin ese delta.
2. **`0caeac5` y `69fc96a` son código idéntico** y dieron 1,257× y 1,321×: una separación de
   0,064× sobre el mismo árbol, que es un cuarto del margen entero del techo.
3. **La nula lo reproduce sin ningún delta**: con el **mismo** árbol en los dos brazos, este banco
   de medida obtuvo 1,213× (`BB`) y 1,180× (`AA`). Un delta de código no puede explicar un
   cociente distinto de 1,000× cuando no hay delta.

## Réplica sobre el sujeto pesado (`fase1`/`fase1c`/`fase2`), conservada

Las fases 1, 1c y 2 midieron —por el defecto de método descrito en la adenda— un sujeto 2,8× más
pesado. **Se conservan y no se descartan**: dan la misma respuesta con otro sujeto. Nula `AA` en
reposo 0,936×–1,044×; nula `AA` bajo contención 0,915×–**1,237×** (con esa repetición convergida a
1,091×); cociente verdadero a `k=8 r=30` 1,071× con la nula en 0,979×–1,042×.

## Corridas descartadas, con su motivo

`corridas/descartadas-por-concurrencia/` — una primera vuelta de la fase 1 quedó con dos arneses
de medida corriendo a la vez. Se descarta porque **el sujeto no es el declarado**, no porque
incomode; se conserva entera y con su explicación.

## Lo que este diagnóstico NO dice

- **No dice que el coste real sea cero.** Es 1,118×, y si alguna vez subiera por encima de
  1,250× el criterio lo debe cazar — para eso la reparación conserva el techo y el FAIL.
- **No mide el runner de CI.** Esta máquina es WSL2 de 8 núcleos; el runner tiene 4 vCPU con
  `ARNES_JOBS=6`, y está medido que **no predicen lo mismo** (`docs/arnes/ci-1.34.0-no-discrimina/`).
  La contención de `fase3c` reproduce la **forma** (más procesos listos que CPU), no el runner.
  La evidencia de CI llega por la corrida de `hooks-en-linux`.
