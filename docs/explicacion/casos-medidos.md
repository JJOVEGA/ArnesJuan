# Casos medidos de «Cómo se escribe un criterio que no se desmiente»

Explicativo e histórico: de dónde salen las cuatro formas que `requirements/README.md` § «Cómo se escribe un
criterio que no se desmiente» prohíbe por nombre. Salieron de allí **literales**, línea a línea, en REQ-036
(CA-03, CA-12; inventario en `docs/explicacion/INVENTARIO-4a.md`). **Las reglas siguen allí**; aquí sólo queda
el porqué. Cada forma conserva en el README su puntero a la sección de este archivo que le corresponde.

## Por qué existe la sección

**Medido, no opinado:** en un ciclo de trabajo de este arnés, **7 de 20** hallazgos no fueron que
el código estuviera mal, sino que el **criterio decía algo falso sobre lo construido** —clase
`contrato`—. Uno costó una **vuelta entera del bucle** (~50 min entre desarrollador, QA, control y
write-back). Las tres primeras formas de abajo son exactamente las que se midieron en ese ciclo;
**la cuarta se midió después, en la ventana 1.32.1, y sobre un criterio escrito ya con esta
sección delante** — de ahí que no baste con escribir la **regla** que el código implementa en vez
de la **lista** de casos que se le ocurrieron a quien redactó ese día: hay que además estar
midiendo la magnitud que se degrada.

## (a) Enumerar lo que el código reconoce

**Caso medido.** Un criterio listaba **tres** envoltorios de shell; el código toleraba **siete**.
El resultado se contó como hallazgo —«el código cerró un límite en silencio»— cuando lo que había
pasado es que el criterio se quedó corto. Una lista escrita en un contrato envejece **hacia el
lado que abre**.

## (b) Fijar un número que la medición desmiente después

**Caso medido.** Un máximo de **262 144** bytes que la medición obligó a bajar a **131 072**. El
número no era el contrato: la **existencia de un techo** lo era. Como el criterio no decía de qué
tipo era su número, bajarlo costó un hallazgo y una vuelta en vez de una línea de Historial.

## (c) Exigir igualdad donde corresponde un techo

**Caso medido.** «El **mismo** número de procesos que la versión anterior.» El código bajó de **1
fork a 0** y el criterio declaró **incumplida una mejora**. Ése es el que costó la vuelta entera
del bucle.

## (d) Fijar la magnitud equivocada

**Caso medido — y lo que importa es que el criterio SE CUMPLÍA.** `CA-08` de REQ-016 contrataba el
coste de la noción de cita en **procesos por llamada**: 4 = 4, medido correctamente, criterio en
verde. Mientras tanto el reloj de la ruta crítica del banco se multiplicaba por **diez** (7,6 s →
75,7 s) y el banco entero —que es la **puerta requerida de `main`**— pasaba de 39 s a 92 s. No hubo
ningún número mal puesto ni ninguna medición mal hecha: la magnitud era correcta, medible sin ruido
y **ortogonal a lo que se degradó**. La pregunta era la que no era. Un criterio de coste que fija
la magnitud equivocada **da verde sobre una regresión de 10×**, y lo hace con toda la autoridad de
una medición correcta — que es peor que no medir, porque además tranquiliza.
