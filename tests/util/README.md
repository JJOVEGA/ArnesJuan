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

**Aquí hay DOS instrumentos, y el tercero no está por un motivo medido.** Materializar el árbol de
una referencia de `git` —la **línea base**— se queda **inline** en las dos secciones 37 del banco
(`mat37` y `mat47`), por decisión del propietario del 2026-09-08: su calibración era **tautológica**
—el factor salía del **parámetro** que se le entregaba, así que `2N/N = 2000` por aritmética, hiciera
la sonda algo o nada, y una copia que no materializaba nada dio **PASS**— y su mudanza costaba **21
procesos de calibración por corrida**. Las propiedades que la gobiernan siguen contratadas (contenido
**y modo del objeto** del árbol, número de archivos publicado, `sin-linea-base` con motivo), y lo que
la reducción deja descubierto está declarado con dueño y ventana en `requirements/REQ-021.md`
(**AN-021-01**): sin instrumento compartido, sin calibración, y con la lógica **duplicada** en las dos
secciones. Quien la mude algún día paga **primero** aplicarle la mitad discordante de abajo.

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
- **Y un factor exacto en todas las corridas NO es evidencia de un sujeto bueno: puede ser la
  firma de una TAUTOLOGÍA.** La procedencia del factor **no se lee en el registro** —la sonda
  honesta y la que calcula sin medir publican el mismo número—, así que la calibración ejerce
  además una **mitad discordante**: una entrada cuya **magnitud observada** es distinta del
  parámetro con que se invoca la sonda, y que el **juez** contrasta contra un **testigo que él
  mismo obtiene** (`disc_param`, `disc_obs` y, en el reloj, `disc_estado`).
- **Y el testigo NO lo aporta la sonda por ningún canal, lo cual costó una vuelta entera de
  medirlo (`QA-021-10`).** La primera versión de esta mitad decía lo de arriba y **no bastaba**:
  el juez creaba un archivo de rastro vacío y contaba sus líneas, pero **las escribía la sonda**,
  y el tamaño del sujeto discordante lo decidía y publicaba ella (`disc_veces = cal_n − 1`,
  `disc_vueltas = cal_n / 50`). Los dos términos del contraste salían del **mismo parámetro**:
  `3 = 3` se cumple por construcción, y una copia que **no invocaba `grep` ni una vez** obtuvo
  **PASS** del juez real. *Crear el recipiente no es obtener el testigo: el testigo es el
  **valor**.* Desde el 2026-09-08 el reparto es éste, y **cada pieza tiene su aborto nombrado**:
  - **el sujeto lo construye el juez** y llega como snippet (`--disc-sujeto`, **obligatorio** en
    `--calibrar`); la sonda no lo dimensiona y **no lo declara** en su registro;
  - **el valor del testigo lo produce el juez** —el número de invocaciones que él metió en el
    snippet; en el reloj, el mínimo de tres pasadas con **su** cronómetro—;
  - **y lo tiene ANTES de invocar la sonda**, que es la forma en que esa independencia se
    **comprueba** en vez de razonarse: el juez publica las dos marcas de reloj y el caso
    **aborta** si la de obtención no es anterior a la de invocación. Cuesta cero procesos: es
    un cambio de orden.
  El caso **aborta** —no pasa, nunca— si el testigo coincide con el parámetro, si el juez no
  acredita la anterioridad, si el registro declara el tamaño del sujeto discordante o si el
  umbral con que se decide sale del registro **del instrumento juzgado**. Dos instrumentos que
  se apartan de la verdad a la vez coinciden y no dicen nada, y eso vale con más fuerza cuando
  el «segundo instrumento» **es la sonda otra vez** por otro canal de salida.
- **Lo que esto NO cierra, dicho aquí porque afirmar lo contrario ya salió caro.** Una sonda que
  **lea el snippet** que el juez le entrega y publique su cuenta **sin ejercerlo** sigue pasando
  —medido—: eso ya no es un descuido sino **falsificación deliberada**, y su respuesta no es un
  criterio más, sino la custodia de `tests/util/*` y la mutación **de un tercero**.
- **El TAMAÑO de cada mitad se deriva del suelo medido en la propia corrida**, al mínimo que lo
  supere por el margen declarado, y se **publica** (`cal_n`, `cal_margen`, `cal_ns_vuelta`). Una
  variable de entorno sólo puede **subirlo**. Medido lo que costaba el absoluto: con un tamaño
  fijo el ejercicio insensible quedaba a **1,4× del suelo**, el ruido del planificador dominaba
  y **5 de 30** calibraciones caían fuera de banda —2 con la máquina en reposo—, cada una
  invalidando toda medición de reloj de la corrida y enrojeciendo la puerta requerida de `main`.
  Y en una máquina bastante más rápida el mismo absoluto habría dicho `suelo`: *una puerta
  requerida cuyo verde depende de la velocidad de la máquina es la que alguien acaba apagando.*
- **Si la calibración resulta frágil, la salida está escrita y ordenada** (REQ-021 CA-03 (d)):
  (1) subir `r` —el techo de coste compara numerador y denominador con los **mismos mandos**,
  así que es invariante a `r` y sólo cuesta reloj—; (2) subir el margen sobre el suelo;
  (3) cambiar el sujeto por uno cuyo factor sea exacto por conteo. **Ensanchar la banda o
  encoger el sujeto no son opciones**: las dos están prohibidas por nombre.
  *Y lo medido el 2026-09-08, porque el orden de la escalera no dice cuál de las tres es la que
  muerde: subir `r` de 3 a 5 **no movió la tasa** —0 de 30 en cuatro regímenes en los dos
  casos— y sí encareció el reloj lo bastante para incumplir el techo de coste. La que arregló
  la fragilidad fue la **(2) por la vía de (c)**: el tamaño derivado del suelo, que sacó al
  ejercicio insensible de 1,4× a 4× el suelo, más el intercalado del par. `r` volvió a 3.*

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
# La calibración de cada una, que el corredor toma una vez por corrida. NO se le pasa el
# tamaño de las mitades: lo DERIVA del suelo medido en la corrida (CA-03 c). El sujeto
# DISCORDANTE, en cambio, es OBLIGATORIO y lo construye quien va a juzgar: de él sale el
# testigo, y una sonda que se lo dimensionara a sí misma volvería a poner los dos términos
# del contraste en la misma fuente. Sin `--disc-sujeto` la calibración falla con motivo.
tests/util/sonda-reloj.sh    --calibrar --k 1 --r 5 \
  --disc-sujeto 'for ((V = 0; V < 900; V++)); do :; done'   # bajo el suelo, cronometrado ANTES
tests/util/sonda-procesos.sh --calibrar \
  --disc-sujeto 'grep -q x /dev/null || :'                  # el testigo es cuántas metió el juez
```

Los sujetos y la preparación se **evalúan dentro del proceso de la sonda**, así que todo
nombre propio suyo lleva prefijo (`SR_`, `SP_`): un sujeto que use `i`, `l` o `s` no pisa nada.

**Dos campos que no son lo que parecen.** `procesos=no-aplica` en el reloj **no es un cero**:
contar los procesos del sujeto exigiría instrumentarlo, y una muestra mixta —reloj y conteo en la
misma pasada— no es publicable; contarlos con el oráculo de forks del núcleo metería ruido ajeno en
un campo publicado. Y `vivos=<n>` es **obligatorio en estos dos instrumentos** y no en el
materializador inline de la línea base, que no puede observarlo: el campo se enuncia sobre **el
emisor**, no sobre el formato — exigírselo a quien no puede observarlo sería un FAIL garantizado.

## Ajustes operativos (variables de entorno)

| Variable | Qué hace | Dirección |
|---|---|---|
| `ARNES_CORRIDA` | Identificador de corrida que ata la calibración con sus mediciones | obligatoria fuera del banco |
| `ARNES_ARBOL` | Árbol medido, para que el registro se pueda volver a visitar | informativa |
| `ARNES_SONDA_CAL_N` | Suelo del tamaño del sujeto sintético de la calibración | **sólo SUBE** el tamaño derivado; un valor menor se **ignora** y se dice por la salida de error |
| `ARNES_SONDA_CAL_MARGEN` | Cuántas veces el suelo tiene que superar cada mitad de la calibración | **sólo sube** de 4; bajarlo es lo que compró un techo con la discriminación del instrumento |
| `ARNES_SONDA_CAL_R` | Series del mínimo con que el corredor calibra (`r`) | **se sube** con la medición. No es la palanca contra la fragilidad, y está medido: con `r=3` y con `r=5` la tasa de falsos rojos es la misma —**0 de 30 en cuatro regímenes**— mientras `r=5` dejaba el reloj de la corrida en **1,2825×** contra un techo de 1,25×. Lo que arregló la fragilidad fue el **tamaño derivado del suelo** y el **intercalado**; `r` sólo cuesta reloj |
| `ARNES_SONDA_DISP_UMBRAL` | Dispersión (máximo/mínimo, en milésimas) por encima de la cual la medida se marca como acompañada | **se baja** con la medición |
| `ARNES_SONDA_PLAZO` | Plazo de arranque, en segundos, de una invocación | **se baja** con la medición |

## Lo que estas sondas garantizan sobre lo que dejan detrás

- **No sobrevive ningún descendiente**, en el nivel que sea —hijo, nieto, más lejano **o
  reparentado**—, y el registro publica `vivos=<n>` con lo que encontró y mató. La comprobación
  **no se apoya en `jobs`**, que sólo lista los jobs del shell que la ejecuta, y usa **dos**
  recorridos porque uno solo no basta: la cadena de `/proc/<pid>/task/<tid>/children` hasta
  punto fijo —exacta y barata mientras la cadena esté intacta— **más** una **marca de entorno**
  única por invocación entre los procesos que no existían al arrancar. La marca es lo que ve al
  **reparentado**: en cuanto un padre intermedio muere, el descendiente pasa a init y sale de la
  cadena. Medido en tres formas —`( ( sleep & ) & )`, `setsid`, doble fork clásico—, las tres
  publicaban `vivos=0` con el superviviente vivo, y era la **tercera** instancia de «un cero
  plausible con la descendencia viva» en el mismo criterio. El entorno sobrevive a la
  reparentación **y** al cambio de sesión; el grupo de procesos sólo habría cazado dos de las
  tres. Los dos recorridos son builtins: no gastan un proceso.
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
