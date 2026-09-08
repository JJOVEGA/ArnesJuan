# ADR-005 — Los instrumentos de medida viven una sola vez, en `tests/util/`: la sonda mide, el corredor juzga
Fecha: 2026-09-07
Estado: aceptada
REQ: REQ-021 · Versión: 1.33.0

## Contexto

En una sola ventana (1.32.1 → 1.33.0), **tres comisiones reconstruyeron las mismas sondas de
medida y dos las rompieron a la primera**. El coste directo es ≈ 150 k tokens por ventana de pura
reconstrucción; el indirecto es el caro, porque es silencioso y sale en verde. Las siete instancias
medidas no son siete descuidos distintos: **en todas, el instrumento medía algo real y había dejado
de responder al sujeto**.

| Instancia medida | Qué costó |
|---|---|
| `$BASHPID` dentro de `$( )` | Dos comisiones distintas. Cada corrida escribía su salida en otro archivo y el inventario leía uno vacío |
| `command -v` sobre un binario sombreado por una función de shell → envoltorio recursivo | Un proceso vivo **3 h 41 min** al 99,6 % de un núcleo, que envenenó la línea base de la comisión siguiente: **92,6 s donde había 39 s**, y la conclusión «dentro del ruido» con lógica interna perfecta |
| Un árbol copiado **sin `.git`** para medir | La copia hacía la mitad del trabajo y la razón salió **2,008×** donde el trabajo entero da **0,964×**. Lo delató el **recuento de SKIP**, no el número |
| Una guarda `case "$rc|$ut|…" in *[!0-9|]*)` | **No dispara nunca**: dentro de un `case`, `|` es el separador de alternativas |
| Una sonda que muestrea **una sola vez por punto** | Seis corridas del mismo árbol: 1,08 · 1,32 · 1,78 · 2,64 · 2,65 · 3,98 MB. Una magnitud publicada y **retirada** |
| `jq --arg` con más de 128 KB | El hook no recibía entrada, respondía en 0,1 s y **la curva de coste salía plana y perfecta** |
| `git show` no preserva el bit de ejecución | El canario no arrancaba: «sin casos», un SKIP correcto **por un motivo que no era el suyo** |

Un reloj que cronometra un hook que no recibió entrada mide tiempo de verdad: el número es
plausible, la lógica es impecable, y no acredita nada.

## Decisión

**1. Se crea una sede única para los instrumentos de medida: `tests/util/`.** Tres programas —
`sonda-reloj.sh`, `sonda-procesos.sh` y `sonda-linea-base.sh`—, uno por cada clase de fallo que
ya ocurrió, no por dividir «medir» en tres partes bonitas.

**2. La doctrina: LA SONDA MIDE, EL CORREDOR JUZGA.** Las sondas emiten **un registro de una línea**
`clave=valor` y **no dictan veredicto**. Quien juzga es un ayudante del corredor del banco.

**3. Son PROGRAMAS que se invocan, no ayudantes que se hacen `source`.** Corriendo en su propio
proceso, `$BASHPID` deja de hacer falta y el defecto que dos comisiones cometieron deja de ser
**expresable**, no sólo de estar prohibido. Además una comisión que mide **fuera del banco** puede
invocarlos tal cual, que es donde ocurrió el caso de las 3 h 41 min y donde ningún ayudante del
corredor llega.

**4. Cada corrida acredita que el instrumento responde al sujeto: la calibración.** Un par de
sujetos sintéticos —uno **sensible**, cuyo coste cambia por un factor conocido **por construcción**
al duplicar un parámetro, y uno **insensible**— y **el factor, nunca un coste absoluto**.

**5. La expectativa vive en el JUEZ, no en la sonda.**

**6. `tests/util/` NO entra en `codigo_app.globs`**, y el sustituto es la calibración.

**7. La herencia por plantillas se aplaza a 1.34.0**: los proyectos **no** heredan `tests/util/` en
1.33.0.

## Por qué la doctrina NO deroga la invariante 3 del banco

El README del banco dice, con motivo medido, que **«un ayudante compartido va en el corredor, y
punto»**: una función definida dentro de una sección no existe para las demás, y al usarla los casos
**no fallaban, es que no se ejecutaban**. Un lector futuro que encuentre las dos frases —«los
instrumentos viven en `tests/util/`» y «un ayudante compartido va en el corredor»— necesita saber
por qué no se contradicen. No se contradicen porque separan dos cosas que hasta ahora iban juntas:

- **`tests/util/` son INSTRUMENTOS: miden y no juzgan.** Se **invocan** como programas, así que no
  son «ayudantes compartidos» en el sentido de la invariante 3: no se hacen `source`, no viven en el
  espacio de nombres de la sección, y el `awk` con que el README deriva la lista de ayudantes del
  corredor **sigue siendo correcto y completo**.
- **`run.sh` sigue siendo la sede única de quien JUZGA.** El ayudante que lee el registro y emite
  PASS/FAIL/SKIP se añade **ahí**, junto a los demás, y queda sujeto a la invariante 1 (guarda antes
  de juzgar) como cualquier otro.

Y la frontera se cobra **dos peajes**, que se pagan en criterios y no se callan: al invocarse como
programas, las sondas **salen de la red del corredor** (`jobs -pr` no ve lo que quedó reparentado ni
los hijos de un programa invocado) y **salen de su juez** cuando se las usa fuera del banco. Lo
primero lo paga la propiedad **por descendencia**; lo segundo, la obligación de contrastar los dos
factores contra la banda del corredor **antes de publicar**.

## El grano de la calibración: una por INSTRUMENTO y por CORRIDA

El contrato decía las dos cosas a la vez —«cuando se invoca cualquier instrumento» y «en cada
corrida que la use»— y la diferencia es de **un orden de magnitud** en coste. Se decide **por
corrida**, y los tres motivos van en este orden porque el precio es el último:

1. **Lo que la calibración acredita es una propiedad del INSTRUMENTO, no de la invocación.** Las
   tres sondas mudas de la ventana dejaron de responder al sujeto en **todas** sus invocaciones: son
   defectos del archivo, y el archivo no cambia entre dos invocaciones de la misma corrida.
2. **El sustituto de no proteger `tests/util/` no pierde nada**, y su propia formulación ya era por
   corrida: una alteración vive en el archivo **toda** la corrida, y una calibración por corrida la
   ve igual que veinte.
3. **El precio, que aquí es consecuencia y no motivo.** Por invocación, la calibración de
   `sonda-linea-base.sh` cuesta **~21 procesos cada vez**; por corrida, una sola vez. En Linux son
   milisegundos; en la plataforma del `desarrollador` un `fork` no es gratis. Y **una calibración
   cara es una calibración que alguien apaga**, que dejaría a `tests/util/` sin sustituto ninguno.

Medido en la implementación (2026-09-07, bash 5.3.9, linux, oráculo `/proc/stat:processes`): la
calibración por corrida cuesta **69 procesos** en total —`reloj` 1, `procesos` 25, `linea-base` 43—
y **~3,4 s de reloj**, de los que 3,2 s son la del reloj.

El grano abre un fail-open que hay que cerrar por separado: **reutilizar la calibración de ayer**.
Lo cierra el **identificador de corrida**, que la calibración y las mediciones comparten y que toda
cifra publicada cita.

## Un criterio de coste declara QUIÉN COMPRA cada proceso

Doctrina reutilizable fuera de este REQ, y nace de una contradicción medida. El techo de
no-regresión de esta palanca se fijó en «**0 procesos añadidos por medición, calibración
incluida**» antes de que existiera una línea de código; después, una auditoría preventiva endureció
la calibración —par sensible/insensible con **identidad de camino**— y ese endurecimiento, que es
correcto, **obliga a cuatro materializaciones por el camino de la medición**: 21 procesos contra un
presupuesto **total** de 18. Nadie escribió un número absurdo: **dos criterios razonables por
separado dejaron de poder cumplirse a la vez**.

La regla que queda escrita:

> Un techo de no-regresión **no puede prohibir pagar por una propiedad que el mismo contrato obliga
> a comprar**. Lo comprado se declara **con el criterio que lo compra**, uno por uno, y **un proceso
> añadido sin criterio que lo compre incumple**. Sin esa exigencia, «comprado» se convierte en la
> coartada por la que entra cualquier `fork`.

Corolario del segundo orden, también medido: **un criterio de coste que mete en el numerador un
artefacto que la línea base no tiene** —«la corrida de 37/1 + 37/2 **+ la sección nueva**»— vuelve
el techo insatisfacible salvo que «lo comprado» absorba la sección entera, y entonces el techo deja
de medir. Lo que hay que contratar es la **no-regresión de lo que existía**, y aparte el coste del
artefacto nuevo.

## (iii) es el único indicador MEDIBLE de la identidad de camino

La identidad de camino —«la calibración recorre el mismo camino que la medición, sustituyendo
únicamente el sujeto»— sólo se sostenía **por inspección**. Con el grano por corrida la calibración
es **una invocación más del mismo programa**, así que su coste se puede **contar**: una calibración
que cuesta bastante más que unas pocas mediciones **no está recorriendo el camino de la medición**.

Y hay una consecuencia de forma que decide un número, así que va aquí: **los cuatro ejercicios que
la calibración contrata no cuestan lo mismo**. El sensible al doble cuesta el doble **por
construcción**, así que con los cuatro ejercicios iguales la calibración vale `1+2+1+1 = 5`
mediciones y el techo contratado es **4×**. Se resuelve **en la forma del sujeto, no en el techo**:
el insensible se dimensiona a **un cuarto** del sensible base, y el coste estructural baja a
`1+2+¼+¼ = 3,5` mediciones. Medido: **reloj 3,30× · procesos 2,88× · línea base 2,13×**.

## Consecuencias

**A favor**
- Una sola sede para los instrumentos: se dejan de reconstruir, y el defecto de reconstrucción se
  deja de repetir.
- Tres clases de prueba-que-miente pasan de «hay que acordarse» a «está por construcción»: el
  mínimo de k, la línea base entera y la muerte de la descendencia.
- Toda cifra publicada como medida lleva **con qué corrida** se tomó y en qué condiciones.
- La mudanza **abarata** el banco: medido **−56 procesos** en la corrida de `37/1` + `37/2` + la
  sección nueva, calibración excluida.

**En contra, dicho por su nombre**
- El banco paga **~3,4 s más de reloj por vuelta** en la calibración. Es el coste permanente de la
  palanca y está acotado por el grano (una por corrida) y por (iii).
- Al ser programas, las sondas **salen de la red del corredor**: lo que quede vivo es hijo del
  proceso de la sonda y, al morir ella, queda reparentado y fuera de `jobs -pr`. La vigilancia se
  traslada del **juez** al **instrumento**, que es justo el artefacto que este ADR decide **no**
  proteger. Lo sustituye la propiedad por descendencia, acreditada **con un nieto**.
- El plazo de las invocaciones se comprueba **entre unidades de trabajo**, no dentro de una: acotar
  una unidad que se cuelga por dentro exige un vigilante en un proceso aparte, y un proceso por
  invocación es exactamente lo que el techo de coste de esta palanca no admite. Queda declarado en
  `tests/util/README.md` en vez de prometido.

## Residual declarado

**No proteger `tests/util/` bajo `codigo_app.globs`.** Fuera de los globs, cualquier agente —incluida
la sesión coordinadora, que es la misma que reúne la evidencia de «todo en verde» y que fusiona,
etiqueta y publica— puede escribir el instrumento. No es una sospecha sobre nadie: es el motivo por
el que el sustituto tiene que ser **verificable por un tercero** y no la palabra del instrumento.

- **Dueño:** `auditor-seguridad`.
- **Las tres condiciones sin las que el sustituto no sostiene:** (1) la expectativa vive en el juez;
  (2) identidad de camino; (3) el sustituto se acredita **por mutación de un tercero**.
- **Forzador observable:** en la pasada de conformidad de **1.34.0** se **altera** una sonda y se
  exige que la calibración **no dé verde**. Si la mutación pasa **inadvertida**, el sustituto queda
  **desmentido** y la decisión vuelve a la mesa con el número delante.
- **Vencimiento:** cierre de la pasada de conformidad de 1.34.0.

## Alternativas consideradas

| Alternativa | Por qué no |
|---|---|
| Un `tests/util/` de **funciones compartidas por `source`** | Contradice la invariante 3 del banco y rompe la derivación por `awk` que su README declara como sitio único; y `$BASHPID` seguiría siendo expresable |
| Dejar cada sonda **dentro** de su sección | Es el estado que produjo las siete instancias medidas: tres reconstrucciones y dos roturas en una ventana |
| Añadir `tests/util/` a `codigo_app.globs` | Se lo quitaría al `qa-tester`, que las rompe **por oficio** (la mutación de un tercero encontró el doble que la del autor); y cambiar el manifiesto es **gate humano**, cuya cola **bloquea el cierre de cualquier REQ** mientras tenga entradas |
| Calibrar por **coste absoluto** en vez de por **factor** | Pasa en las tres sondas mudas de la ventana: las tres medían tiempo real y habían dejado de responder al sujeto |
| Calibrar **una sola vez** y acreditarlo | Es acreditación de fail-before, no puerta: envejece hacia el lado que abre |
| Una cuarta sonda para el **orden de crecimiento** | No es un instrumento distinto: son **dos medidas del reloj divididas**. Crearía una segunda sede del mínimo de k, que es el defecto que esto viene a cerrar |
| **Un vigilante por invocación** para el plazo | Un proceso por invocación por las tres sondas rompe el techo de coste de la palanca; y una comprobación cara es la que alguien acaba apagando |
