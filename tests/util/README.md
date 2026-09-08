# `tests/util/` — los instrumentos de medida, una sola vez

Aquí viven las sondas que **todo el repositorio** usa para medir: el banco de escenarios, el
`qa-tester` cuando reproduce un coste y cualquier comisión que publique una cifra. Existen
porque en una sola ventana **tres comisiones reconstruyeron las mismas sondas y dos las
rompieron a la primera**, y porque las siete instancias medidas de ese periodo comparten una
forma: **el instrumento medía algo real y había dejado de responder al sujeto**. Un reloj que
cronometra un hook que no recibió entrada mide tiempo de verdad; el número es plausible, la
lógica es impecable, y no acredita nada.

| Instrumento | Qué mide | Qué clase de fallo cierra |
|---|---|---|
| `sonda-reloj.sh` | El coste temporal de un sujeto repetido: **mínimo de k, r series, dos sujetos intercalados, suelo** | La muestra única (1,08–3,98 MB en seis corridas del mismo árbol); la varianza **de procedimiento** al medir en bloque en vez de intercalado |
| `sonda-procesos.sh` | Cuántos procesos gasta una invocación, con envoltorios en el `PATH` | El envoltorio recursivo de `command -v` (3 h 41 min al 99,6 % de un núcleo, línea base envenenada); el `jq --arg` de 128 KB que dejaba el JSON vacío y la curva plana |
| `sonda-linea-base.sh` | Materializar el árbol de una **referencia de `git`** (tag, commit o rama) y **decir con motivo** cuando no puede | El árbol copiado sin `.git` (2,008× frente a 0,964×); `git show` sin bit de ejecución; once criterios en SKIP con la puerta requerida en verde |

## Las cinco propiedades, y por qué son propiedades y no estilo

1. **Se invocan; no se hacen `source`.** Son programas (`100755`, con shebang). Al correr en
   su propio proceso, `$BASHPID` deja de hacer falta, y el defecto que dos comisiones
   cometieron —`$BASHPID` dentro de `$( )`, que devuelve el PID del **subshell de la
   sustitución**— deja de ser **expresable**, no sólo de estar prohibido.
2. **Un registro por invocación, en una sola línea** de campos `clave=valor`, por la salida
   estándar y nada más. Todo diagnóstico va por la salida de error.
3. **Ninguna dicta veredicto.** No tocan los contadores del banco y no imprimen ninguna línea
   con la forma que el corredor usa para contar casos. Una sonda es **el brazo, no el juez**.
4. **Un solo parser, y no está aquí.** El registro lo lee un único ayudante:
   `sonda_lee`, definido al nivel superior de `tests/escenarios/hooks/run.sh` antes del
   despacho. **Este documento apunta a él en vez de transcribirlo**: dos transcripciones de
   la misma regla se desfasan.
   Ahí mismo viven el juez de CA-10 y, deliberadamente, **el factor esperado y la banda de la
   calibración**.
5. **Cada campo numérico se valida por separado**, y un campo obligatorio **ausente es un
   error con motivo, nunca un cero**. Concatenar campos antes de la guarda hace desaparecer un
   valor vacío dentro de los dígitos del vecino; y escribir la clase como `*[!0-9|]*` dentro
   de un `case` **no dispara nunca**, porque ahí la barra es el separador de alternativas
   (comprobado en bash 5.3). La ausencia que calla es la misma forma que el campo `QA:`
   ausente, que **permite** donde `QA: pendiente` deniega.

## La calibración: cada corrida acredita que el instrumento responde al sujeto

Cada instrumento se ejerce **una vez por corrida** con un **par de sujetos sintéticos**: uno
**sensible**, cuyo coste cambia por un factor conocido **por construcción** al duplicar un
parámetro, y uno **insensible**, cuyo coste no depende de ese parámetro. La sonda publica los
dos factores (`cal_a`, `cal_b`) y **no los compara con nada**.

- **Se contrasta el FACTOR, nunca un coste absoluto.** Una calibración de coste conocido
  —«esta entrada tarda 200 ms»— verifica que el reloj lee tiempo y **no** que la sonda esté
  midiendo el sujeto: las tres sondas mudas de la ventana 1.33.0 medían tiempo real, sólo que
  de otra cosa, y **las tres habrían pasado**.
- **La expectativa vive en el juez**, no aquí. Con la banda dentro del archivo cuestionado
  —y siendo legítimamente editable— ensancharla es **una línea en la misma edición** que
  altera la sonda: la calibración se autocertificaría.
- **El sujeto sensible tiene coste realmente lineal.** El apilado de cadenas en bash **no
  sirve**: es superlineal por el `realloc` y dio 2,048 y 2,566 en dos corridas del mismo
  sujeto. Si el factor **deriva** más de lo que la banda admite, **lo que se cambia es el
  sujeto, nunca la banda**.
- **El camino es el mismo.** La calibración es *una invocación más del mismo programa*, con
  el sujeto sintético en lugar del real. Por eso su coste se puede **contar** y compararlo con
  el de una medición es el único indicador medible de esa identidad.

## Publicar una cifra: lo que hay que llevar consigo

- Toda cifra escrita como **medida** —en un REQ, en `docs/qa/<versión>.md` o en el
  CHANGELOG— va acompañada del **registro que la sonda emitió**, copiado y **no redactado**.
- Ese registro **nombra la corrida** (`corrida=`, `invocacion=`, `arbol=`, `plataforma=`).
  Quien mida **fuera del banco** exporta `ARNES_CORRIDA` con un identificador propio; sin él,
  el registro dice `corrida=desconocido` y **no es publicable**, porque no hay calibración a
  la que atarlo.
- Quien mide fuera del banco **no tiene juez delante**: contrastar los dos factores contra la
  banda del corredor es parte de **publicar**, no de medir.
- **Una cifra derivada** —una diferencia, un cociente, una extrapolación, un agregado— sólo
  es publicable si **cada** entrada lleva su propio registro, la operación queda escrita
  **junto a la cifra** y ninguna entrada se tomó fuera de la disciplina del mínimo de k. Si
  alguna no cumple, se publica el **rango observado** con su número de corridas, y **nunca un
  valor**. El caso medido: «≈ 1,60 MB» publicado como medida y **retirado** — seis corridas
  del mismo árbol dieron 1,08–3,98 MB porque los tres tiempos base eran **una sola muestra**
  y el orden iba **en el exponente**.
- **Lo que estas sondas NO prometen:** ninguna puede saber si **otra comisión está midiendo**
  —no ve los procesos de otro árbol de trabajo ni de otra sesión—. Publican la evidencia con
  la que eso se detecta después (dispersión y carga), no la detección. La regla de despacho
  —dos comisiones que miden no van a la vez, aunque los archivos sean disjuntos— es de la
  coordinadora y **no la cumple ninguna máquina**.

## Cómo se invocan

```sh
# Reloj: r series de k repeticiones, publica el MÍNIMO (no hay vía para pedir la media).
tests/util/sonda-reloj.sh --k 20 --r 3 --prep 'source hooks/lib.sh' --sujeto 'arnes_sin_cita "$l"'
# …y con DOS sujetos, alternando las series a, b, a, b dentro de la misma invocación.
tests/util/sonda-reloj.sh --k 4 --r 6 --sujeto-a '…' --sujeto-b '…'
# Procesos: envoltorios en el PATH, resueltos con `type -P` antes de tocarlo.
tests/util/sonda-procesos.sh --sujeto "bash hooks/guard-completado.sh < entrada.json"
# Línea base: cualquier referencia que `git` resuelva a un árbol.
tests/util/sonda-linea-base.sh --ref v1.32.1 --destino /tmp/heredado --rutas 'hooks tools'
# La calibración de cada una, que el corredor toma una vez por corrida.
tests/util/sonda-reloj.sh --calibrar --k 1 --r 3 --n 200000
```

Los sujetos y la preparación se **evalúan dentro del proceso de la sonda**, así que todo
nombre propio suyo lleva prefijo (`SR_`, `SP_`, `SLB_`): un sujeto que use `i`, `l` o `s` no
pisa nada.

## Ajustes operativos (variables de entorno)

| Variable | Qué hace | Dirección |
|---|---|---|
| `ARNES_CORRIDA` | Identificador de corrida que ata la calibración con sus mediciones | obligatoria fuera del banco |
| `ARNES_ARBOL` | Árbol medido, para que el registro se pueda volver a visitar | informativa |
| `ARNES_SONDA_CAL_N` | Tamaño del sujeto sintético de la calibración de reloj | **se sube** en una máquina rápida, o la calibración dirá `suelo` |
| `ARNES_SONDA_DISP_UMBRAL` | Dispersión (máximo/mínimo, en milésimas) por encima de la cual la medida se marca como acompañada | **se baja** con la medición |
| `ARNES_SONDA_PLAZO` | Plazo de arranque, en segundos, de una invocación | **se baja** con la medición |

## Lo que estas sondas garantizan sobre lo que dejan detrás

- **No sobrevive ningún descendiente**, en el nivel que sea —hijo, nieto o más lejano—, y el
  registro publica `vivos=<n>` con lo que encontró y mató. La comprobación **no se apoya en
  `jobs`**, que sólo lista los jobs del shell que la ejecuta: se recorre la descendencia por
  `/proc`, con builtins y sin gastar un proceso.
- **Sus temporales se nombran desde su propio proceso**, privados y recién creados, **nunca
  con nombre fijo**, y se retiran en la misma salida **incluidos los caminos de error**. El
  corredor corre las secciones en paralelo: un directorio de envoltorios de nombre fijo es un
  temporal compartido aplicado a **ejecutables**.
- **El `PATH` instrumentado se acota a la invocación** y ningún componente suyo es vacío ni
  relativo: cualquiera de ellos pone el directorio de trabajo delante de los binarios reales.

**El plazo, con su límite dicho.** Toda invocación nace bajo un plazo declarado
(`ARNES_SONDA_PLAZO`, techo operativo) que se comprueba **entre unidades de trabajo** —cada
serie, cada archivo materializado, cada ejercicio— y **desde la primera repetición**; su
vencimiento es un resultado publicado (`estado=plazo-agotado`) con el número que sí se
obtuvo, nunca un SKIP mudo. Lo que **no** hace es interrumpir una unidad que se cuelga por
dentro: eso exigiría un vigilante en un proceso aparte, y un proceso aparte por invocación es
justo lo que el techo de coste de esta palanca no admite. Queda dicho aquí en vez de
prometido.
