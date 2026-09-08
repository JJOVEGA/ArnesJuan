# Escenario — hooks de enforcement

Valida en **aislamiento** (sin Claude Code) los invariantes que el plugin baja a runtime.
El banco arma un proyecto efímero con `.arnes/config.json`, alimenta JSON de `PreToolUse` a los
scripts reales de `hooks/` y verifica si deniegan o permiten.

## Cómo está partido (desde 1.32.0)
```
run.sh                     el CORREDOR: ayudantes compartidos, canario global, despacho y cuadres
secciones/NN-<slug>.sh     los CASOS: una sección por archivo, descubiertas por el corredor
autoprueba-corredor.sh     lo que certifica al corredor (aparte de los casos del banco);
                           declara su propio `AUTOPRUEBA_CASOS_ESPERADOS` y se aplica el cuadre
inventario.sh              inventario ordenado de una salida, para comparar vuelta contra vuelta
```
Hasta 1.31.0 todo esto era **un solo archivo de 4.096 líneas**. Dos comisiones de QA no podían
trabajar a la vez —las dos escribían en `run.sh`— y tocar cuarenta líneas obligaba a leerlas
todas. El corredor **descubre** los archivos con un glob de bash, en orden lexicográfico y sin
arrancar ni un proceso: añadir o quitar una sección no toca ni una línea de `run.sh`.

**Modos de archivo, y por qué.** `run.sh`, `autoprueba-corredor.sh` e `inventario.sh` son
`100755`: se invocan. Los archivos de `secciones/` son `100644`: se hacen `source` desde el
corredor y **no se corren sueltos** — sueltos no tendrían ni ayudantes ni canario, correrían
cero casos y saldrían verdes. El CI comprueba las dos mitades.

## Correr
```
bash tests/escenarios/hooks/run.sh                       # el banco entero
bash tests/escenarios/hooks/run.sh secciones/07-*.sh     # sólo esa sección, más el canario
bash tests/escenarios/hooks/run.sh bash                  # sólo los casos cuyo nombre contenga "bash"
bash tests/escenarios/hooks/autoprueba-corredor.sh       # la autoprueba del corredor
```
Requiere `jq`. Sale con código ≠ 0 si algún caso falla. **828 casos** (el número exacto lo cuadran
`CASOS_ESPERADOS_SECCION` en cada archivo y `CASOS_ESPERADOS` al final de `run.sh`).

En vuelta parcial —con un selector de archivos o con filtro de nombre— el cuadre **total** queda
suspendido **diciéndolo en la salida**, y el cuadre **de cada sección** se sigue exigiendo. Un
selector que no casa con ningún archivo **aborta**: una vuelta que corre cero casos y sale verde
es exactamente el fallo que este banco existe para no tener.

## Nada en `secciones/` se queda fuera en silencio
El corredor **aborta** —antes de ejecutar nada— si en `secciones/` hay una entrada que esta vuelta
no iba a ejecutar: un archivo que no casa `NN-<slug>.sh` (un `40-sin-extension`, un
`zz-huerfana.sh`) o una entrada que sí casa pero no es un archivo regular legible (un directorio
llamado `43-dir.sh`, que además mataba el cuadre bajo `set -u` sin dejar ni `ABORT:` ni línea
`Resultado:`). El respaldo era el cuadre total, y en vuelta parcial el cuadre total está
suspendido por diseño: ahí no había red ninguna. Los archivos ocultos (`.algo`) quedan fuera a
propósito — son temporales de editor, no secciones.

## Cómo se añade una sección
Tres líneas, y ninguna en `run.sh`:
1. Crear `secciones/NN-<slug>.sh` (modo `100644`, sin bit de ejecución, sin shebang: se hace `source`).
2. Declarar dentro `CASOS_ESPERADOS_SECCION=<n>` y escribir los casos.
3. Sumar esos `<n>` a `CASOS_ESPERADOS` al final de `run.sh`.

## Los ayudantes compartidos
Una sección no define ayudantes propios cuando ya hay uno compartido. **El sitio único donde vive
el conjunto es el corredor**: compartido es, por definición, **todo el que `run.sh` define al nivel
superior antes del despacho** —que es lo que lo hace visible dentro del `source` de cada sección—,
y **este README no lo enumera a propósito**. La lista se saca del corredor, no de aquí:

```
awk 'index($0, "source \"${SECCIONES[") { exit }
     /^[A-Za-z_][A-Za-z_0-9]*\(\)[ \t]*\{/ { n = $0; sub(/\(\).*/, "", n); print n }' run.sh
```

**Por qué no hay lista.** La había: seis nombres escritos a mano dentro de la invariante 1, con la
palabra «todos» delante. Ya era falsa el mismo día en que se escribió —`corre`, `ver_corre` y
`mide_hook` ejecutan un hook y no estaban— y el REQ apuntaba aquí como sitio único mientras este
README apuntaba al corredor: dos sitios y ninguno cierto (QA 1.32.0, H-01). Un conjunto que la
máquina puede derivar en una línea no se transcribe a prosa; la transcripción envejece y la
derivación no. `autoprueba-corredor.sh` lo vigila: falla si este README nombra un ayudante que el
corredor no define, y falla si alguien vuelve a escribir aquí la lista cerrada.

**Ejecutar un hook y dictar veredicto no es lo mismo, y sólo lo segundo obliga.** Un ayudante puede
ejecutar el hook y devolver su respuesta sin juzgarla —es el brazo, no el juez— y ésos no llevan
guarda ni les hace falta. La obligación de la invariante 1 cae sobre **el que dicta PASS/FAIL**.
Qué ayudante hace cada cosa se lee en el corredor, que es donde está escrito.

## Invariantes del banco
Cinco reglas que el banco se aplica **a sí mismo**. No son estilo: cada una nació de una vuelta
en verde que no medía lo que decía medir.

1. **Un JSON vacío es un FAIL, nunca un `allow`.** Si el emisor de un caso se queda mudo —`jq`
   reventando por el tamaño del argumento fue exactamente eso—, el hook no recibe entrada, no
   deniega, y el caso pasa en falso. Por eso **todo ayudante que dicte PASS/FAIL sobre la respuesta
   de un hook** pasa por `json_no_vacio` —o por una **guarda equivalente**: una comprobación de
   vacío (`-z`/`-n`) sobre la variable **local** que guarda lo que se va a juzgar; el nombre de esa
   variable da igual, la **minúscula** no (`[ -n "$FILTRO" ]` es el filtro de nombre de caso, no una
   guarda, y admitirlo abriría el control en 31 sitios)— antes de juzgar nada. Ese conjunto **no se
   enumera aquí ni en ningún otro sitio**: se lee del corredor (arriba). Un ayudante nuevo que no lo
   haga está introduciendo verdes falsos: es la misma lección del canario, un nivel más abajo.
   Desde 1.32.0 el corredor lo comprueba sobre el TEXTO de cada archivo de sección antes de
   ejecutar nada: una función propia de una sección que ejecute un hook y dicte PASS/FAIL sin
   guarda **aborta la vuelta**, nombrando el archivo y la función. La comprobación sigue la
   CADENA DE LLAMADAS dentro del archivo, no el cuerpo suelto: partir el ayudante en dos —una
   función que ejecuta el hook y otra que dicta el veredicto— era la evasión que QA midió en la
   vuelta 1 de 1.32.0 (`1 PASS, 0 FAIL`, rc 0, con un caso de entrada vacía en verde), y las dos
   propiedades —«ejecuta un hook» y «lleva guarda»— se propagan hasta punto fijo, así que da
   igual en cuántos trozos se parta. Sigue cubriendo funciones y no código suelto al nivel del
   archivo: es una barandilla, no una jaula.
2. **El cuadre es por archivo Y total.** Un caso que desaparece produce cero líneas, que es
   exactamente lo que produce un caso que pasó limpio. Cada archivo de sección declara su
   `CASOS_ESPERADOS_SECCION` y el corredor exige las dos cosas: que cada sección cuadre con
   **su** número —y el ABORT dice **cuál** archivo y cuántos casos de diferencia, que antes había
   que buscar en 4.096 líneas— y que la suma cuadre con `CASOS_ESPERADOS`. Un archivo **sin** su
   número declarado aborta con su nombre. Quien añade o quita un caso actualiza los dos números,
   y quien escribe un contador que puede quedarse vacío (un `grep -c` sobre un archivo que quizá
   no existe) lo blinda: un `$(( 60 + ))` mata el subshell y **se lleva la sección entera** sin
   decir nada — que es justo lo que este cuadre existe para impedir.
3. **Cada sección corre en su propio subshell; los ayudantes viven al nivel superior.** Una
   función definida dentro de un archivo de sección no existe para los demás: al usarla en otra
   sección los casos no fallaban, es que **no se ejecutaban**. Ahora la frontera es un archivo, y
   por eso pesa más: un ayudante compartido va en el corredor, y punto. Y cada sección arranca de
   un proyecto efímero recién hecho, para que ninguna dependa de que otra limpie detrás.
   Corolario medido al partir el banco: el corredor no puede llamar `i` a su índice de bucle —seis
   secciones usan `i` como contador propio y lo pisan—; lo que el corredor necesita **después** del
   `source` lleva prefijo `ARNES_`.
4. **Una sección que muere se distingue de una sección que pasó limpia.** Las dos producen cero
   líneas. Al terminar el archivo entero, el subshell deja una marca; si no está, el corredor
   **aborta nombrando el archivo y su código de salida**, y la vuelta sale ≠ 0. Nunca se cuenta
   como sección de cero casos. Y ningún archivo de sección hace `source` de otro ni depende del
   estado que otro deje: la única dependencia admitida es del corredor hacia abajo. Un banco
   partido cuyos archivos se llaman entre sí es el mismo monolito con más archivos.
5. **Nada de una sección sobrevive a su sección** (desde 1.33.0, REQ-017 CA-06). Al cerrar cada
   sección el corredor mira `jobs -pr`: si quedó algún proceso vivo lo **mata**, lo anota y
   **aborta la vuelta nombrando el archivo**. Nació medido: en 1.32.1 una sonda de QA —un
   envoltorio de `grep` construido con `command -v` sobre un binario **sombreado por una función
   de shell**, que por eso se resolvía a sí mismo— vivió **3 h 41 min** después de su comisión
   comiéndose un núcleo entero, y **falseó la línea base de otra medición**, que concluyó «dentro
   del ruido» con toda lógica interna. El corolario para quien escriba una sonda: las rutas de los
   binarios se resuelven **con `type -P` y ANTES de tocar el `PATH`** —`command -v` ve funciones de
   shell, `type -P` no— y se comprueba que ninguna caiga dentro del propio envoltorio.

## Cómo se escribe un caso que sirva
Tres reglas nacidas de fallos reales:

1. **Un caso `allow` no prueba nada por sí solo.** También pasa cuando el hook ni siquiera llega
   a ejecutarse (shebang con CRLF, `jq` ausente, ruta mal normalizada). En 2026-09-01 el banco
   daba verde con el enforcement muerto en Windows. Por eso `run.sh` arranca con un **canario**:
   si el caso "coordinadora edita `src/` → deny" no deniega, aborta la corrida entera.
2. **Todo arreglo trae su caso `deny`**, y el caso se comprueba contra el código anterior:
   ```
   ARNES_HOOKS_DIR=/ruta/a/los/hooks/viejos bash tests/escenarios/hooks/run.sh
   ```
   Si un caso nuevo pasa con los hooks viejos, no está probando lo que crees. La ruta de los
   hooks bajo prueba es **independiente** de cómo esté partido el banco: el corredor nuevo se
   puede apuntar a una instalación estable anterior sin más.
3. **Al reorganizar el banco se compara el INVENTARIO, no el total.** Dos casos que intercambian
   PASS y FAIL dan el mismo total: es la forma en que un refactor pierde cobertura en silencio.
   ```
   bash tests/escenarios/hooks/run.sh > /tmp/despues.txt
   bash tests/escenarios/hooks/inventario.sh /tmp/antes.txt   > /tmp/inv-antes.txt
   bash tests/escenarios/hooks/inventario.sh /tmp/despues.txt > /tmp/inv-despues.txt
   diff /tmp/inv-antes.txt /tmp/inv-despues.txt
   ```
   Vacío, o el trabajo no está hecho.

## Casos cubiertos
| Hook | Caso | Esperado |
|------|------|----------|
| A1 `guard-codigo` | coordinadora (sin `agent_id`) edita código de app | **deny** |
| A1 | subagente `desarrollador` edita código de app | allow |
| A1 | subagente `qa-tester` edita código de app | **deny** |
| A1 | coordinadora edita un archivo fuera de los globs | allow |
| A3 `guard-completado` | REQ → `en-progreso` | allow |
| A2/A3 | REQ → `completado`, sin pendientes, gates ok | allow |
| Veredictos | `QA: pendiente`, o sensible con `Seguridad: pendiente` | **deny** |
| A2 | REQ → `completado` con aprobación pendiente | **deny** |
| A3 | REQ → `completado` con quality gate roja (cadena y objeto) | **deny** |
| Windows | `file_path` con backslashes y unidad `C:` | **deny** |
| Identidad | `agent_type` con prefijo del plugin (`arnes-juan:desarrollador`) | allow |
| Identidad | `agent_type` con prefijo de otro agente (`arnes-juan:qa-tester`) | **deny** |
| Identidad | el motivo del deny nombra al agente de forma legible | **deny** + texto |
| Identidad | `agent_type` con mayúsculas y espacios | allow |
| Identidad | coordinadora que se declara `desarrollador` (sin `agent_id`) | **deny** |
| Identidad | manifiesto con prefijo vs. `agent_type` sin prefijo (y viceversa) | allow |
| Identidad | manifiesto con prefijo + otro proveedor | **deny** |
| Bash | `>`, `>>`, `tee`, `sed -i`, `cp`/`mv` a ruta de código | **deny** |
| Bash | el motivo del deny admite que la cobertura es parcial | **deny** + texto |
| Bash | `cat`/`grep`/`sed -n`/`git commit -m` que sólo mencionan la ruta | allow |
| Bash | lee código y escribe fuera de los globs (`cp src/x /tmp/y`) | allow |
| — | sin `.arnes/config.json` el hook es inerte (Edit y Bash) | allow |
| `arnes-paralelo` | dos REQ con globs que alcanzan el mismo archivo | **colisiona** + lo nombra |
| `arnes-paralelo` | un REQ sin `Archivos:`, con ruta absoluta o valor ilegible | `sin declarar` + rc ≠ 0 |
| `arnes-paralelo` | sin `jq`, sin manifiesto o sin REQ | lo dice + rc 2, nunca «disjunto» |
| `arnes-paralelo` | el campo nuevo NO cambia ningún veredicto de `guard-completado` | allow |
| `arnes-paralelo` | un archivo aún por crear, contra el glob o el directorio que lo alcanza | **colisiona** en los **dos** órdenes |
| `arnes-paralelo` | un REQ del que no se puede leer el `Estado:` de la cabecera | `sin declarar` + rc ≠ 0 |
| Cita | un veredicto autorizante citado dentro de un `<!-- … -->` de la cabecera | **deny** por el vigente |
| Cita | el mismo, con las seis formas de énfasis en la clave | **deny**, mismo motivo |
| Cita | un rango que abre y no cierra dentro de la cabecera | **deny** + cita el rango |
| Cita | el rango sin cerrar se traga el campo que faltaba | **deny**, nunca allow por ausencia |
| Cita | el veredicto vigente SÍ autoriza y la cabecera trae la misma cita | allow |
| Cita | clave decorada o sangrada FUERA de todo rango | sigue gobernando |
| Cita | insertar un rango en cualquier cabecera del corpus del banco | ningún `deny` → `allow` |
| Cita | los dos lectores (`lib.sh` y `campos-req.awk`) sobre el mismo documento | valores idénticos |
| `arnes-lectura` | la línea decorada que gobierna un campo | se nombra, rc **0** |
| `arnes-lectura` | dos declaraciones del mismo campo y gobierna la decorada | anomalía + rc ≠ 0 |
| Coste (37/1) | el escáner **dentro del dominio de equivalencia**, línea a línea y en secuencia | estado **idéntico byte a byte** a v1.32.1 |
| Coste (37/1) | el corpus (320 entradas, semilla fija): fronteras nombradas **y** la clase de byte inválido | si el corpus la **pierde**, **FAIL** |
| Coste (37/1) | **fuera** del dominio: la decisión de este árbol, k=6 por locale | determinista **e invariante al locale** |
| Coste (37/1) | **fuera** del dominio: esa decisión contra el **oráculo** (la heredada bajo `LC_ALL=C`) | **coincide**; sin esto (i) la cumpliría una constante |
| Coste (37/1) | **fuera** del dominio: lo que la heredada incumple bajo el locale del entorno | se **registra** (fail-before) y **no falla** por ello |
| Coste (37/1) | doblar la longitud de línea (70 000 → 140 000 bytes) | cociente ≤ **2,6** (lineal ≈ 2) |
| Coste (37/1) | el mismo cociente **contra v1.32.1** | > 2,6 — la sonda distingue el defecto |
| Coste (37/1) | el camino de campo contra el de v1.32.0 (140 000 bytes sin CR) | razón ≤ **2,0×** |
| Coste (37/1) | la sonda sin línea base, o bajo el suelo de 50 ms | **SKIP con motivo**, nunca PASS |
| Coste (37/1) | la pared de los 60 s, **pareada** con v1.32.1 en la misma corrida (2 pasadas por árbol) | este árbol **no menor**; rangos que **solapan** ⇒ SKIP |
| Coste (37/2) | la sección 32 aislada, **sólo con `ARNES_COSTE_RUTA_CRITICA=1`** | la heredada **no termina** en 4 × mín(este árbol) ⇒ reloj ≤ **0,25×** |
| Coste (37/2) | las 3 corridas cronometradas de este árbol, entre sí | **mismo inventario** caso→veredicto |
| Coste (37/2) | una corrida del numerador que termina **en rojo** (rc ≠ 0) o sin casos | **no cuenta como medición**: SKIP con motivo, nunca PASS |
| Coste (37/2) | la heredada muerta por **señal** (137), un `124` que el reloj no corrobora, o un `124` **sin un solo caso** | **SKIP con motivo**; sólo `124` **+ reloj ≥ plazo + casos** demuestra la cota |
| Coste (37/2) | una cabecera normal (6 líneas y 200 líneas) contra v1.32.1, **6 series intercaladas** por árbol | **0 procesos añadidos y** reloj ≤ **1,25×** |
| Coste (37/2) | la misma sonda cuando **no converge** (2.º mínimo / mínimo > 1,25×) | **SKIP**, nunca PASS y nunca FAIL |
| Coste (37/2) | una sección sintética que deja un proceso vivo | el corredor la **acusa por su nombre** |

**Los casos de coste no llevan relojes absolutos, y eso es deliberado.** Un umbral en segundos lo
falsea la máquina, el runner del CI y la carga. Los de arriba son **cocientes de duplicación**
—donde la velocidad de la máquina se cancela algebraicamente— o **razones contra una línea base
materializada desde su tag en la misma corrida**; el estadístico es el **mínimo** de k
repeticiones, nunca la media, porque la carga sólo puede **añadir** tiempo. La metodología completa
—y el caso medido que la obligó— está en `requirements/README.md`, forma **(d)**: «fijar la
magnitud equivocada».

### La equivalencia se afirma sobre un DOMINIO, y la partición se mide en cada corrida

`ADR-004`. Bajo un locale UTF-8, la eliminación de sufijo **con patrón** de v1.32.1
(`${l%$'\r'}`) no se comporta byte a byte sobre secuencias multibyte inválidas: ahí «el estado de
la heredada» **no designa un objeto único** —depende del locale—, y una igualdad contra él no está
definida hasta decir bajo cuál. Por eso 37/1 **clasifica** cada entrada del corpus en la propia
corrida, con una sola pasada que alimenta a los dos criterios:

| Clase | Cómo se decide (con la **heredada sola**, k = 6 por locale) | Qué se contrata |
|---|---|---|
| **dentro** | publica **un único y el mismo estado** en las k del locale del entorno **y** en las k de `LC_ALL=C` | **igualdad byte a byte** de los cuatro valores |
| **fuera** | falla el determinismo **o** la invariancia de locale | **la dirección** contra el oráculo, sólo la decisión |
| **no clasificable** | tampoco publica una decisión única bajo `LC_ALL=C` | nada: un oráculo que no repite no es un oráculo ⇒ **SKIP** |

Tres cosas que no son detalles de implementación:

1. **La partición se calcula sin haber mirado este árbol.** Las dos evaluaciones de la heredada van
   primero en el archivo, y sólo después las de este árbol. Un dominio definido como «donde los dos
   árboles coinciden» haría un criterio que **no puede fallar**.
2. **El oráculo es `LC_ALL=C`**, y no por comodidad: ahí la heredada **es** la pregunta byte a byte,
   así que es el único sitio donde existe un valor «correcto» contra el que medir. Este árbol la
   implementa en **todos** los locales, luego los dos divergen **exactamente** donde la heredada se
   aparta de su propia semántica.
3. **La asimetría FALLA / SKIP es deliberada.** Si el **corpus** pierde la clase de byte inválido,
   los cinco casos del dominio **FALLAN** —y eso se comprueba sobre el corpus, sin depender de la
   máquina—; si es la **máquina** la que no tiene el defecto (otra versión de bash, o un locale del
   entorno que ya sea `C`/`POSIX`, donde el conjunto de fuera es vacío **por construcción**), dicen
   **SKIP citando bash, locale y los recuentos**, nunca PASS. Un corpus estrechado es trabajo
   retirado y tiene que doler; una máquina sin el defecto es falta de sujeto, y poner rojo ahí acaba
   con alguien apagando el caso.

Medido aquí (bash 5.3.9, `C.UTF-8`, corpus de 320 entradas): **dentro 312 · fuera 8 · no
clasificables 0**, con **0** divergencias dentro, **0** violaciones de este árbol fuera, y la
heredada incumpliendo la invariancia de locale en **7 de 8** y el determinismo en **0–1**.

### Una sonda declara su RESOLUCIÓN antes de juzgar, o se abstiene

Vale para las dos sondas comparativas de esta sección, y nace de un rojo medido, no de una
precaución. **CA-08 (ii)** corre en la **puerta requerida de `main`**: con las series en **bloque**
(este entero, luego el heredado entero) cada árbol ve vecinos distintos, y la contención que el
propio banco fabrica con `JOBS=6` se cuela entera en la razón — **1 de cada 4** vueltas completas
salía roja con `load` 0,91 al arrancar, sobre un estimando que en aislamiento vale ≈ 1,0. Por eso:

- las series se **intercalan** (a, b, a, b, …), **6 por árbol**, estadístico el **mínimo**;
- y en la misma corrida se comprueba que ese mínimo **convergió**: `2.º mínimo / mínimo` de **cada**
  árbol contra **el propio techo** (1,25× — no es un número nuevo: *un instrumento tiene que
  resolver al menos el factor que vigila*). Si lo supera, **SKIP citando las dos convergencias y la
  razón que sí obtuvo**, nunca PASS y **nunca FAIL**.

La misma regla, con la forma que le toca, en la **pared de los 60 s**: dos pasadas por árbol
intercaladas y comparación **por rangos** — se afirma la dirección si el peor de este árbol supera
al mejor de v1.32.1, se niega si el mejor queda por debajo del peor, y **si los rangos se solapan
el caso se abstiene**. Con una sola pasada por árbol salía **rojo 1 de cada 6** sin que existiera
regresión: la dispersión de esa sonda es un factor ~3,7 sobre el mismo árbol y su arreglo es de
**SEC-030**, no de REQ-017. Lo que sí es de aquí es **declarar que no resuelve** en vez de firmar.

**La abstención no tapa una regresión real:** una regresión sube los dos mínimos del árbol nuevo por
igual y **no** separa su serie de sí misma; lo que separa una serie de sí misma es el vecino.

**La comparación contra la ruta crítica NO corre por defecto, y ese defecto está medido al revés
que el resto del banco.** Corriéndola en cada vuelta, la sección 37/2 cuesta ~120 s —~76 s de ellos
la corrida heredada, que cuesta lo que costaba el defecto porque **es** el defecto corriendo— y
deja el banco en **~145 s**: la puerta requerida de `main` más lenta que la regresión de 92 s que
REQ-017 arregla, y de forma **permanente**, porque su línea base es un tag congelado. Una razón
contra un tag es **acreditación de fail-before, no puerta permanente**: acreditada una vez, deja de
medir la evolución de este árbol y envejece hacia el lado que abre. La vigilancia permanente la da
**CA-03** —el cociente de duplicación, auto-anclado, sin tag y en milisegundos—, que es lo único
que habría visto H-07.

Por eso se enciende a mano con **`ARNES_COSTE_RUTA_CRITICA=1`** (por defecto **apagada**: 37/2 baja
de ~120 s a ~14 s, y a ~76 s encendida). Apagada, sus dos casos dicen **SKIP citando el número
acreditado y su fecha**, nunca PASS. El resto de 37/2 —CA-08 y las dos mitades de CA-06— corre
siempre.

**Y el denominador no se mide: se acota, con un plazo derivado del numerador.** La corrida heredada
se lanza bajo `timeout` de **4 × mín(este árbol)**, calculado en esa misma corrida y **después** del
numerador — un plazo escrito en segundos a mano sería el reloj absoluto que estos criterios
combaten. Si el plazo **vence**, heredada > 4 × este y el cociente es ≤ 0,25×: la desigualdad queda
**demostrada**, no estimada, y lo único que se deja de conocer es el *valor* de la razón, que el
criterio no pide. **El vencimiento es un PASS**, nunca un SKIP: un SKIP ahí convertiría el hallazgo
en silencio. Si la heredada **termina** dentro del plazo, el caso **FALLA**.

**Pero antes de leer un veredicto hay que saber si esa corrida midió, y eso son dos preguntas que
la vuelta 0 no hacía** (QA-017-03 y QA-017-04, cerrados en la vuelta 1):

1. **El numerador tiene que terminar en verde.** Una corrida que acaba **en rojo** no midió lo que
   cuesta correr la sección: midió lo que cuesta fallarla, y falla **antes**, así que mide **menos**
   — y un numerador más pequeño produce un plazo más corto, que la heredada rebasa con más
   facilidad. Medido: con los hooks sustituidos por un sello que siempre permite, la sección 32 sale
   en **14 FAIL, rc 1 y 3,79 s** en vez de ~9,6 s, el plazo cae a 16 s y las **dos** mitades daban
   PASS — incluida la que se llama «la comparación no se compra dejando de probar». Ahora las dos
   dicen **SKIP con el motivo y el recuento**. La señal es el `rc` del corredor, que sale 0 sólo con
   0 FAIL, el cuadre por archivo cerrado y sin procesos vivos.
2. **Sólo `124` prueba que el plazo venció, y el reloj tiene que corroborarlo.** El `137` es
   «murió por SIGKILL», y eso lo produce igual el OOM killer, un `kill` de fuera o el `-k` del
   propio `timeout`; matando al hijo desde fuera a los **0,6 s de un plazo de 60 s** el rc es 137 y
   el caso lo leía como «≤ 0,250× — DEMOSTRADO». La corrida heredada **es** el camino cuadrático, el
   que más memoria pide, así que el OOM kill es su modo de muerte más probable en un runner
   apretado. El PASS exige ahora **dos instrumentos de acuerdo**: `timeout` diciendo 124 y el reloj
   de pared ≥ plazo. Cualquier otra muerte es **SKIP con motivo** — no un FAIL: que la heredada
   muriera no prueba que sea rápida.
3. **Y el plazo agotado sólo acota si esa corrida produjo algún caso** (QA-017-09). El arreglo de la
   vuelta 1 preguntó «¿esta corrida midió?» **sólo al numerador**; sobre el denominador bastaba con
   `rc = 124` y el reloj. Una heredada que **se cuelga sin imprimir un caso** —o cuyo archivo de
   salida ni siquiera existe— agota el plazo y publicaba «≤ 0,250× — **DEMOSTRADO**». Hay precedente
   en esta misma ventana: el árbol heredado extraído **sin bit de ejecución** no arrancaba el
   corredor hijo; allí *terminaba* y caía en SKIP, pero un **bloqueo** —un hook esperando en
   `stdin`, un cerrojo, un `read` sin `</dev/null`— lo convierte en vencimiento. **Una corrida que
   no midió no es una corrida lenta**, igual que una corrida rota no es una corrida rápida.

Las tres decisiones viven en funciones **puras** (`caso47`, `valida47`, `veredicto47`,
`veredicto08_47`) y por eso el banco las prueba **siempre**, con entradas sintéticas y en
milisegundos, aunque la comparación de 76 s esté apagada: una puerta que sólo se ejerce cuando
alguien enciende una palanca es una puerta de la que nadie sabe si cierra. Y con la de convergencia
el argumento es aún más fuerte: en una corrida sana la sonda **converge**, así que el camino que
importa —la abstención— no se recorrería nunca.

## Por qué importa
- La distinción coordinadora vs. subagente se apoya en el campo `agent_id` del input del hook
  (presente sólo dentro de un subagente). Verificado empíricamente contra `claude` CLI 2.1.183.
- `agent_type` llega **con el prefijo del plugin**: `arnes-juan:desarrollador`. Comparar en crudo
  contra el manifiesto denegaba al único agente autorizado (bug hallado en SENDA, 2026-09-02).
- La cobertura de `Bash` es **parcial a propósito**; los casos "allow" de esa sección son el
  contrato de que no hay falsos positivos sobre comandos de lectura (ver README del plugin).
