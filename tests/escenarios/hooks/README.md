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
../../util/*.sh            los INSTRUMENTOS de medida, compartidos con todo el repositorio
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
ARNES_SONDA_CONTROLES=1 bash tests/escenarios/hooks/run.sh secciones/37-coste-del-escaner-7-*.sh
                                                         # los controles de medición de las sondas de coste
```
Requiere `jq`. Sale con código ≠ 0 si algún caso falla. **1787 casos** (el número exacto lo cuadran
`CASOS_ESPERADOS_SECCION` en cada archivo y `CASOS_ESPERADOS` al final de `run.sh`). La línea
`Resultado:` cuenta **aparte** los `SKIP` que son **INCONCLUSO** —una sonda de coste que no acreditó
nada en esa corrida— y los nombra debajo; el código de salida **no** depende de ellos
([más abajo](#las-sondas-de-coste-deciden-sobre-un-presupuesto-fijo-y-pueden-decir-inconcluso-desde-1350)).

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

## Por qué hay secciones numeradas en partes (`NN-<slug>-<k>-<tema>.sh`)
Las secciones 28, 33, 36, 37 y 38 viven repartidas en varios archivos. No es estilo: **REQ-014
CA-18** pone un techo a lo que una comisión tiene que abrir para tocar una sección, y el techo se
pone sobre el **excedente**, no sobre el total —`líneas(f) ≤ max(N, piso(f) × k)`, con `N` = 400 y
`k` = 1,25—. Cada archivo declara, junto a su `CASOS_ESPERADOS_SECCION`, su
`PISO_AUTONOMO_SECCION` **con la derivación término a término en la misma línea**
(`preámbulo + maquinaria compartida duplicada + bloque indivisible mayor`), y
`autoprueba-corredor.sh` comprueba que todos lo declaren, que los términos **sumen** el valor
declarado y que el piso **quepa** en el archivo.

**El piso no lo elige quien escribe la sección: lo imponen las invariantes 3 y 4 de aquí arriba.**
Cada sección corre en su propio subshell y en paralelo, ninguna hace `source` de otra, y en
`secciones/` no cabe un archivo auxiliar (el descubrimiento aborta ante lo que no case
`NN-<slug>.sh`). No hay tercera vía: **la maquinaria que dos partes comparten se duplica o se sube
al corredor**, y subirla es cambio de mecanismo. Por eso el materializador de la línea base viene
copiado en las cinco partes de la 37, los dos ayudantes de comparación de `28-…-2-el-estado.sh`
vienen copiados de `28-…-1-la-historia.sh`, y `num38` está en las tres partes de la 38: **once
renglones copiados cuestan menos que una puerta trasera entre secciones**.

**Al partir, los casos se reparten; no se crean ni se pierden.** Cada parte declara su propio
`CASOS_ESPERADOS_SECCION`, la suma no cambia y `CASOS_ESPERADOS` de `run.sh` tampoco. El corte va
**por tema** y en un punto **sin dependencias cruzadas** —ninguna parte usa un nombre, función o
variable, definido en otra—, y eso se verifica, no se afirma. La prueba de que la partición no
perdió nada es el **inventario** (regla 3 de «Cómo se escribe un caso que sirva»): idéntico byte a
byte antes y después. Si un archivo no cabe **ni partiéndolo** —porque su techo derivado ya es
menor que el piso de cualquier parte autónoma—, el defecto es del piso y **no se arregla subiendo
el techo ni inflando el piso para caber**: vuelve al analista.

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
   Desde 1.33.0 la misma pasada comprueba una segunda propiedad sobre el texto: **que ninguna
   sección reconstruya lo que un instrumento de `tests/util/` ya hace** — materializar un árbol
   desde una referencia de `git`, cronometrar repeticiones de un sujeto o contar procesos con
   envoltorios en el `PATH`—. Si lo hace, la vuelta **aborta nombrando el archivo y la función**:
   el materializador estaba **duplicado literalmente** en las secciones 37, y ahí es donde se
   perdía media línea base sin que nadie mirara cuánto. (Desde la partición de REQ-014 CA-18 son
   **cinco** copias, no dos: ver «Por qué hay secciones numeradas en partes», abajo.)
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
| Coste (37/2) | doblar la longitud de línea (70 000 → 140 000 bytes), **5 repeticiones** con k=20 | máx(cociente) ≤ **2,6** en ≥ 3 resueltas (lineal ≈ 2); FAIL si **todas** > 2,6; si no, **INCONCLUSO** |
| Coste (37/2) | el mismo cociente **contra v1.32.1**, en las **mismas** 5 repeticiones y con el mismo k | **calibración**: ≥ 3 resueltas y **todas** > 2,6, o el caso de arriba es **INCONCLUSO**, nunca FAIL del candidato |
| Coste (37/2) | el camino de campo contra el de v1.32.0 (140 000 bytes sin CR) | razón ≤ **2,0×** |
| Coste (37/2) | la sonda sin línea base, o bajo el suelo de 50 ms | **SKIP con motivo**, nunca PASS |
| Coste (37/3) | la pared de los 60 s, **pareada** con v1.32.1 en la misma corrida (2 pasadas por árbol) | este árbol **no menor**; rangos que **solapan** ⇒ SKIP |
| Coste (37/4) | la sección 32 aislada, **sólo con `ARNES_COSTE_RUTA_CRITICA=1`** | la heredada **no termina** en 4 × mín(este árbol) ⇒ reloj ≤ **0,25×** |
| Coste (37/4) | las 3 corridas cronometradas de este árbol, entre sí | **mismo inventario** caso→veredicto |
| Coste (37/4) | una corrida del numerador que termina **en rojo** (rc ≠ 0) o sin casos | **no cuenta como medición**: SKIP con motivo, nunca PASS |
| Coste (37/4) | la heredada muerta por **señal** (137), un `124` que el reloj no corrobora, o un `124` **sin un solo caso** | **SKIP con motivo**; sólo `124` **+ reloj ≥ plazo + casos** demuestra la cota |
| Coste (37/5) | una cabecera normal (6 líneas y 200 líneas) contra v1.32.1, **5 repeticiones** del par de **6 series intercaladas** por árbol | **0 procesos añadidos y** máx(reloj) ≤ **1,25×** en ≥ 3 resueltas; FAIL si **todas** > 1,25×; si no, **INCONCLUSO** |
| Coste (37/5) | una repetición cuya sonda **no converge** (2.º mínimo / mínimo > 1,25×) | **no resuelta**: no cuenta para PASS ni para FAIL; el juez que decide lo prueba con las siete entradas de siempre |
| Coste (37/6) | los **dos jueces** de las sondas de coste sobre **vectores fijos** (fronteras, 2 frente a 3 resueltas, calibración 2 frente a 3, mezclas, sin línea base, los 9 del ensayo, la corrida 5 del ensayo en CI) | cada vector con la salida que la regla prescribe, o **FAIL** nombrándolo |
| Coste (37/7) | controles **I** (idénticos), **W0** (envoltorio sin demora) y **WD** (demora fija), **sólo con `ARNES_SONDA_CONTROLES=1`** | I y W0 sin FAIL; WD **PASS si el juez dice FAIL**; apagados, **SKIP** con su última acreditación, nunca PASS |
| Coste (37/2) | control **C3**: la **misma** serie de calibración de **v1.32.1** que mide CA-03, juzgada como control del instrumento, **sólo con `ARNES_SONDA_CONTROLES=1`** | PASS si **todas** > 2,6× en ≥ 3 resueltas; **FAIL real** si todas ≤ 2,6× (avería demostrada); si no, **INCONCLUSO**, nunca PASS |
| Coste (37/5) | una sección sintética que deja un proceso vivo | el corredor la **acusa por su nombre** |
| Sondas (38/1) | `bash -n` y los modos de cada `tests/util/*.sh` | ejecutable **y** con shebang, o **aborta nombrándolo** |
| Sondas (38/1) | los registros de las **dos** sondas de `tests/util/` | **una** línea, y **ninguna** con la forma de un caso |
| Sondas (38/1) | un campo obligatorio ausente, vacío o no numérico | **error con motivo**, nunca un cero |
| Sondas (38/1) | un valor con **espacios** o **saltos de línea** (`--etiqueta`, `--ref`, un motivo con ruta) | **un** campo y **una** línea: no fabrica campos ni veredictos |
| Sondas (38/1) | una **clave repetida** o un valor con metacaracteres de glob | **ilegible ⇒ FAIL**, y el valor **no** se expande contra el `cwd` |
| Sondas (38/2) | la **calibración** de cada instrumento en esta corrida | sensible ≈ **2,000×**, insensible ≈ **1,000×**, y **distinguidos** o **FAIL** |
| Sondas (38/2) | el **tamaño** de cada mitad de la calibración | **derivado del suelo** en la propia corrida y **publicado**; un env sólo lo **sube** |
| Sondas (38/2) | la **mitad discordante**: la magnitud publicada contra un **testigo del juez** | coincide con el **testigo**, no con el **parámetro**, o **FAIL** |
| Sondas (38/2) | la misma sonda **sin la observación** (copia mutada, sin tocar el árbol) | la mitad discordante **FALLA**; sin la mutación, **pasa** |
| Sondas (38/2) | **calibrar** frente a **una medición** del mismo instrumento y con **los mismos mandos** | ≤ **6×** en reloj **y** en procesos; `procesos=no-aplica` ⇒ **SKIP**, nunca un `0,000×` |
| Sondas (38/3) | un sujeto que deja vivo un **NIETO** | la sonda lo **mata y publica `vivos=n`**; sin esa mitad, **sobrevive** |
| Sondas (38/3) | un sujeto que deja un descendiente **REPARENTADO** (doble fork) | también lo **ve y lo mata** (marca de entorno); sin ella, `vivos=0` **con él vivo** |
| Sondas (38/3) | el camino de **error** de la sonda de procesos | **0** directorios de envoltorios detrás |
| Sondas (38/3) | un `PATH` con componente vacío o relativo (`:x`, `x:`, `::`, `.`) | **se dice**, nunca un número |
| Sondas (38/3) | reloj **bajo instrumentación de procesos** | muestra **mixta**: no publicable |
| Sondas (38/3) | el ayudante de veredicto sobre 13 registros sintéticos | `estado≠ok` o `vivos>0` en medición ⇒ **SKIP**; vacío, ilegible, ambiguo, `vivos` ausente, emisor no declarado o sin su calibración ⇒ **FAIL** |
| Sondas (38/3) | `vivos>0` en una **calibración** frente a `vivos>0` en una **medición** | **FAIL** y **SKIP**: no es el mismo hecho |
| Coste (37/1 a 37/5) | el **materializador inline** de la línea base (`mat37`/`mat47`) | contenido **y modo del objeto del árbol**, `archivos=<n>` publicado, y `sin-linea-base` **con motivo** cuando no puede |
| Cabecera ambigua (41) | una **variante** de una clave de control (mayúsculas, blanco de más, BOM, U+200B, NBSP, `0xc3` suelto, `- `, `1. `, BOM y `- `) o una clave de control **repetida** —también con el mismo valor—, por `Edit` y por `Write` (filas R1–R18 de REQ-023 CA-08) | **deny** citando las líneas, con los bytes invisibles escapados |
| Cabecera ambigua (41) | las mismas filas contra **713ac68** (materializado por SHA con `mat41`) y contra la instalación estable **1.33.2** | **allow** en las dos (fail-before); sin un árbol, **SKIP** con el motivo |
| Cabecera ambigua (41) | cada fila R **sin** la variante o la repetición; y las filas A, S, U y F (ausencia legítima, prosa, cita, estructura `>`/`«»`/`()`/`[]`/`&`, reabrir, CRLF, fronteras declaradas) | **decide igual** en 713ac68 y en la candidata; U1 conserva el motivo de REQ-031 CA-A12 |
| Cabecera ambigua (41) | el **dominio de campos** derivado midiendo (presente deniega, ausente abre) y la clase descartada: C0/DEL, anchura cero, UTF-8 mal formado y una entrada **al azar** con su semilla | toda variante **deniega**; la clase cabe en la constante; anti-vacuidad contra 713ac68 |
| Cabecera ambigua (41) | el corpus del banco (por glob) y los REQ de `requirements/`, candidata frente a 713ac68; los cuatro lectores; C.UTF-8 frente a C | **mismos valores**; decisiones iguales salvo denegaciones por ambigüedad con variante o repetición **real**; veredicto y motivo **invariantes al locale** |
| Cabecera ambigua (41) | el código nuevo leído (sin procesos, sin rangos, bajo `LC_ALL=C`, la clave medida antes de tocarla) y las invocaciones de `arnes_norm_clave` y `arnes_norm_campo` contadas contra 713ac68 | **0** construcciones que crean procesos; **no más** recorridos; normalizaciones añadidas sólo en la cabecera ambigua |
| Cabecera ambigua (41) | `tools/arnes-lectura.sh` ante una variante, una repetición, una nota con `ESTADO:` y una decorada única | anomalía y salida **≠ 0** en las tres primeras; la decorada única **no** cambia el código de salida |
| Edición no reconstruible (42) | `Edit`/`MultiEdit` de `requirements/` que la puerta no puede reconstruir: comillas rectas donde el archivo las tiene tipográficas (el caso del host real), el escape de barra y `u` con cuatro hex, `replace_all`, `old_string` vacío sobre un archivo que existe, dos ediciones sobre un archivo que no existe, reapertura no literal y `requirements/README.md` (filas C1–C4 y C9–C12 de REQ-023 CA-13) | **deny** con el motivo de CA-13: qué edición, como mucho 80 bytes del `old_string` escapados, cómo hacer una edición verificable y ninguna otra herramienta |
| Edición no reconstruible (42) | las mismas filas contra **df550fa** (materializado por SHA con `mat42`) | **allow** (fail-before); sin el árbol, **SKIP** con el motivo |
| Edición no reconstruible (42) | la creación con `old_string` vacío, juzgada entera (C5 y C6); una edición literal (C7); la reapertura literal (C8); un archivo CRLF (C13) | la decisión de la puerta sobre el documento resultante; los controles **deciden igual** en df550fa |
| Edición no reconstruible (42) | la cita de un `old_string` de 4 000 bytes y los procesos contra df550fa (sonda de procesos) | 80 bytes escapados y un motivo de pocos cientos de bytes; **0** procesos añadidos |
| Identidad del destino (43) | rutas equivalentes a un REQ y a `src/a.ts`: `..`, `././`, `//`, relativa a otro `cwd`, `/tmp/..`, directorio enlazado dentro y fuera de la raíz, `requirements` que es un enlace, enlace en el último componente fuera de la raíz y por `Bash` (filas I1–I13 de REQ-007 CA-66) | **deny** por la puerta de cada fila, con su motivo; contra **9596e39** (materializado por SHA con `mat43`) **allow** (fail-before) o **deny** (control) |
| Identidad del destino (43) | lo legítimo fuera del ámbito, la creación y la reapertura por ruta equivalente (L1–L7, K1–K3, S1, S3) | **allow** por `guard.sh`, igual que en 9596e39; L5 y K2 **deny** en los dos |
| Identidad del destino (43) | destino no determinable: `..` sobre un directorio que no existe, un directorio en modo 000, un bucle de enlaces, una relativa sin `cwd` (D1–D4) | **deny** con el motivo de CA-47 punto 7 (causa y arreglo, ninguna herramienta); D2 **SKIP** como administrador |
| Identidad del destino (43) | REQ ilegible: NUL, UTF-16LE, sin permiso de lectura, un directorio en su ruta; `Edit` sin estado, con mención y N4; `Write` juzgado entero (R1–R7) | `Edit` **deny** con el motivo de CA-45 (ii); `Write` sin terminal **allow**, con terminal y QA pendiente **deny** |
| Identidad del destino (43) | los seis movimientos declarados de deny a allow (CA-66, punto 5): L8, R6 (c) y M1 (a), y las tres rutas que casaban con el ámbito sólo por su texto y designan un archivo de fuera —`Write <raíz>/src/../README.md`, `echo x > src/../README.md` y un `sed -i` con el estado terminal hacia `requirements/../docs/x.md`— | **allow** aquí y **deny** en 9596e39; su control opuesto, la ruta canónica protegida con la misma forma (I1 src, I2 req y `echo x > src/a.ts`), **deny** en los dos |
| Identidad del destino (43) | fuera de la tabla mínima: las dos lecturas que designan archivos distintos (V1), el enlace dentro de la raíz escrito con `..` (V2) y un destino no determinable por `Bash` en `guard-completado`, sin y con el estado terminal en el comando (V3, V4) | V1, V2 y V4 **deny** (allow en 9596e39); V3 **allow** en los dos |
| Identidad del destino (43) | una ruta de más de 4 096 caracteres; los procesos contra 9596e39 en I1, `/dev/stderr`, `ls -la` y un enlace resuelto (L3) | no determinable con una cita de 200 bytes; **0** procesos añadidos, **1** en L3 (el `readlink` de CA-49 (ii)) |
| Integridad de la entrada (44) | REQ-007 CA-47 punto 11 (QA-023-09): un salto de línea dentro de un campo de la entrada —el `cwd` (en medio, al final, con dos rutas, o un directorio real cuyo nombre lo lleva), el agente— por `Edit`, `MultiEdit`, `Write` y `Bash` (filas E1–E5 de CA-66) | **deny**, y el motivo cita la ruta que la entrada designa; contra **43b948a** (materializado por SHA con `mat44`) **allow** o deny **juzgando otra ruta** (fail-before); contra **9596e39**, la referencia de los movimientos |
| Integridad de la entrada (44) | lo legítimo con el MISMO `cwd` de varias líneas: el `desarrollador` escribiendo código, escrituras fuera del ámbito, el cierre de un REQ en verde, una edición literal, `ls -la` (G1, G2), y `echo x > src/a.ts` desde `docs/a␊b`, instancia de L8 (G3) | **allow**; G2 **deny** en 43b948a (el `cwd` desplazado no existía), G3 **deny** en 43b948a y 9596e39 |
| Integridad de la entrada (44) | CA-47 punto 12: un `file_path` con salto de línea —el que ya se denegaba (F1, con C10), el que la lectura entera habría permitido (F2: `app/*.ts`, un patrón exacto, una creación, el enlace de CA-49 (i)), con `..` detrás (F3) y fuera del ámbito o legítimo (F4, con C9)— | **deny** con el motivo de no determinable (la ruta lleva un salto de línea; corrígela sin saltos), a todo agente en `guard-completado` |
| Integridad de la entrada (44) | CA-47 punto 13: un `tool_name` con salto de línea (`Write␊`, `Bash␊`, `Edit␊`, y `Write␊` del `desarrollador`) (T1) | **deny**: no identifica ninguna herramienta; en 43b948a y 9596e39 `Write␊` y `Edit␊` **allow** y `Bash␊` **deny** |
| Integridad de la entrada (44) | los motivos de F y T, y `arnes_parse_input` campo a campo con un salto en cada uno (P1) | dicen su causa y no nombran ninguna herramienta como salida; los seis campos **intactos** (en 43b948a, desplazados) |
| Integridad de la entrada (44) | QA-023-13, el retorno de carro en el `cwd`: desde `<fuera>/d␍` —un enlace a la raíz, con `<fuera>/d` un directorio normal—, `echo x > src/a.ts` de la coordinadora, un `sed -i` y un `Edit` relativo que cierran un REQ en rojo; y el CR en medio (`e␍f`) y antes de un salto (`g␍␊h`) (R1–R5) | **deny**: el `cwd` con CR no ancla y el motivo lo dice; contra **cd6afa6** (fail-before) **allow** —anclaba en `<fuera>/d`—, salvo el CR en medio; contra **9596e39** **deny** |
| Integridad de la entrada (44) | con el mismo `cwd` con CR, lo que no depende de él —escrituras y cierres por ruta absoluta, `ls -la`, el `desarrollador` escribiendo código (RC1–RC6)—; la escritura relativa fuera del ámbito (RM1); y las mismas operaciones desde un `cwd` sin CR (RS1–RS3) | RC como siempre en los tres árboles; RM1 **deny** (de allow a deny, declarado); RS como cd6afa6, y RS3 (L8) **deny** en 9596e39 |
| Integridad de la entrada (44) | un `file_path` con CR —el enlace dentro de la raíz `docs/l␍`, un `Edit` que cierra `REQ-901.md␍` en rojo cuando `REQ-901.md` está en verde, una ruta fuera del ámbito y un `file_path` que sólo es un CR (RF1–RF4)— y un `tool_name` con CR —`Bash␍` con `ls` y un `file_path` en `src/`, `Edit␍` que cierra un REQ en rojo, `Write␍` del `desarrollador`, `Bash␍` con `echo x > src/a.ts` (RT1–RT4)— | **deny**, como los que llevan un salto; en cd6afa6 y 9596e39 **allow** (el CR final se recortaba y se juzgaba otra ruta u otra herramienta), salvo RT4, **deny** en los tres |
| Integridad de la entrada (44) | los motivos del CR, y `arnes_parse_input` con un CR final en el `tool_name`, el `cwd` y el `file_path` (P2) | dicen su causa y cómo corregirla, sin herramientas como salida; el CR se **cuenta** antes del transporte (en cd6afa6, recortado) |
| Integridad de la entrada (44) | SEC-120 (REQ-007 CA-47 punto 20), una entrada que `jq` no puede **leer**: V3 de R-045-A §4 —un `Edit` que cierra un REQ `critico` en rojo con una clave extra de 10001 niveles— de la coordinadora y del `desarrollador`, y la misma clave por `Write`, `MultiEdit` y `Bash`; y una entrada truncada (L1–L6), por `guard.sh` y por cada guardián que juzga la herramienta | **deny** a todo agente, y el motivo no interpola la clave anidada; contra **v1.35.0** (3956a6f, materializado por SHA con `mat44`) **allow** (fail-before). Hasta la reparación de SEC-120, la columna de la candidata sale **FAIL** |
| Integridad de la entrada (44) | SEC-120, unas ediciones de `MultiEdit` que no se pueden **trocear**: como cadena (V1), como número (V2), como objeto y como lista de cadenas —estas dos hacen fallar el troceo de `jq`— (T1–T4), por `guard.sh` y `guard-completado` | **deny** de la puerta que las necesita; en v1.35.0 **allow** (fail-before). Hasta la reparación, la columna de la candidata sale **FAIL** |
| Integridad de la entrada (44) | SEC-120, controles: la puerta de código no necesita las ediciones (K1–K3), V4 con 9000 niveles (K4), los modos inertes —sin `jq`, sin manifiesto— con V3 (I), y `arnes_parse_input` tras una lectura buena (P3) | deciden **igual** en la candidata y en v1.35.0: K1 y K3 **allow**, K2 y K4 **deny** por su regla; I **sin decisión** (sin `jq`, con su aviso); P3, ninguna variable conserva la lectura anterior (ya en v1.35.0, R-046) |
| Dependencia del proceso y CR del comando (45) | SEC-122, cara (a): un enlace corriente bajo `/dev/shm` hacia `requirements/` o `src/` —`Edit`, `Write`, `sed -i`, `echo >`, la edición no reconstruible— (S1–S6); y cara (b): un proyecto situado bajo `/dev/shm` —el enlace del último componente, el directorio enlazado y la existencia— (B1–B5) | **deny** donde designa un archivo protegido, como en cualquier otro sitio; contra **3bc7d3c** (fail-before) **allow**, y en la cara (b) **allow** lo que 9596e39 deniega; B3 y B5, lo legítimo que 3bc7d3c sobredenegaba, **allow**. Sólo en Linux; fuera, SKIP con motivo |
| Dependencia del proceso y CR del comando (45) | lo que depende del proceso que abre la ruta —`/proc/self/cwd` desde el `cwd` de la entrada o sin él, `/proc/self/root`, un enlace a `/proc/self/cwd`, `/dev/fd/9/a.ts`, un `Write` a `/dev/stderr`— (P1–P9) y lo legítimo bajo `/dev`: `/dev/null`, `/dev/stderr`, `/dev/stdout`, `/dev/fd/2`, `tee /dev/stderr` (N1–N6) | por `Bash`, el directorio de trabajo se resuelve desde el `cwd` de la entrada (P1 **deny**, P2 **allow**); lo que depende del proceso y no se puede determinar, **deny** con motivo; un descriptor del shell, **allow** sin excepción por nombre; por el host, un descriptor es **deny** (P9, de allow a deny, declarado) |
| Dependencia del proceso y CR del comando (45) | P-023-13-A: el CR final del comando y el que precede a un salto, por un enlace `docs/k␍` hacia `src/a.ts` y `docs/r␍` hacia un REQ en rojo (K1–K4); lo legítimo y los movimientos (K5–K8); el delimitador de heredoc con CR (H1–H6); y `guard-git` (G2–G3) | **deny** donde el shell escribe un archivo protegido (en 3bc7d3c y 9596e39, **allow**: el CR se perdía); K6 **allow** (de deny a allow, declarado: el shell escribe `app/a.ts␍`); el delimitador con CR **deny** con motivo |
| Dependencia del proceso y CR del comando (45) | pasada correctiva: un CR pegado a las palabras de una orden de git prohibida —`reset --hard␍` (G1), `stash␍`, `checkout .␍`, `checkout -- .␍`, `restore .␍`, `checkout HEAD .␍`, `clean␍ -f`— y sus controles (C1–C9); y un enlace dentro de un ámbito protegido que lleva a un descriptor —`src/log`, `requirements/log` → `/dev/stderr`— con sus controles (C10–C13) | **deny** con motivo —la orden se juzga también sin el CR, porque con `help.autocorrect` git la corrige y la ejecuta—; contra **9220c71** (fail-before) **allow**; `clean␍ -f` **deny** también donde 9596e39 permitía (de allow a deny, declarado); el enlace a un descriptor dentro del ámbito, **deny** como en 9596e39 |
| Dependencia del proceso y CR del comando (45) | QA-023-14: `arnes_parse_input` con el CR final y el que precede a un salto en el `tool_name`, el `file_path` y el `command` (Q1), y con un `jq` que añade un CR a cada línea —emulación del de Windows, no Windows— (Q2, Q3) | los valores llegan **enteros** sin recorrerlos para reponer nada (en 3bc7d3c, los pierde); con la emulación, iguales y sin ningún CR de más |

**Desde REQ-023 CA-13, un `Edit` de `requirements/` que la puerta no puede reconstruir se deniega antes
que cualquier otra puerta.** Por eso los casos que miden otra puerta de `guard-completado` usan
`emite_edit_lit`, que comprueba al emitir que el `old_string` está literal en el archivo —o que es una
creación— y, si no, deja el JSON vacío y el caso en FAIL en vez de pasar porque lo detuvo CA-13.
`emite_edit`, con su `old_string:"x"`, queda para `guard-codigo` y para los casos que miden esa
denegación.

**Desde REQ-007 CA-47 (ADR-016), las dos puertas juzgan la identidad del destino, no el texto de la
ruta**, y una ruta relativa se ancla en el `cwd` de la entrada. Los emisores compartidos fijan `cwd` en
la raíz, así que las rutas relativas de los casos existentes siguen designando lo mismo. La sección 43
trae su propio emisor porque sus filas necesitan un `cwd` distinto de la raíz, o ninguno. Y es una
prueba **a nivel de hook**: la validación en el host real (CA-66, punto 6) es de la coordinadora.
La sección 44 también trae su propio emisor: pone en el `cwd` y en el agente su texto LITERAL, saltos
de línea incluidos, porque lo que mide es que ningún contenido de un campo desplace a los demás. Su
bloque R (QA-023-13) mide el retorno de carro, que el transporte de jq retira del final de un campo y
que por eso se cuenta antes; su árbol de fail-before es cd6afa6, no 43b948a. Su bloque SEC-120 (1.36.0)
mide dos árboles por caso, la candidata y v1.35.0 —la línea base de REQ-007 CA-69, punto 1—, y no 9596e39.
La sección 45 (octava autorización) trae el mismo emisor y su árbol de fail-before es 3bc7d3c, salvo el bloque C (pasada correctiva), que lo cambia a 9220c71. Las filas
que dependen de `/dev/shm` o de `/proc` sólo se miden en Linux —donde se midió—; fuera salen SKIP con
motivo, y las que necesitan un enlace con un retorno de carro en el nombre, también si no se puede crear.

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
  resolver al menos el factor que vigila*). Si lo supera, **esa repetición no está resuelta** y no
  cuenta ni para PASS ni para FAIL (desde REQ-030; hasta entonces el caso entero decía SKIP con una
  sola lectura, y así se leen sus resultados anteriores).

La misma regla, con la forma que le toca, en la **pared de los 60 s**: dos pasadas por árbol
intercaladas y comparación **por rangos** — se afirma la dirección si el peor de este árbol supera
al mejor de v1.32.1, se niega si el mejor queda por debajo del peor, y **si los rangos se solapan
el caso se abstiene**. Con una sola pasada por árbol salía **rojo 1 de cada 6** sin que existiera
regresión: la dispersión de esa sonda es un factor ~3,7 sobre el mismo árbol y su arreglo es de
**SEC-030**, no de REQ-017. Lo que sí es de aquí es **declarar que no resuelve** en vez de firmar.

**La abstención no tapa una regresión real:** una regresión sube los dos mínimos del árbol nuevo por
igual y **no** separa su serie de sí misma; lo que separa una serie de sí misma es el vecino.

**La comparación contra la ruta crítica NO corre por defecto, y ese defecto está medido al revés
que el resto del banco.** Corriéndola en cada vuelta, la sección 37/4 cuesta ~120 s —~76 s de ellos
la corrida heredada, que cuesta lo que costaba el defecto porque **es** el defecto corriendo— y
deja el banco en **~145 s**: la puerta requerida de `main` más lenta que la regresión de 92 s que
REQ-017 arregla, y de forma **permanente**, porque su línea base es un tag congelado. Una razón
contra un tag es **acreditación de fail-before, no puerta permanente**: acreditada una vez, deja de
medir la evolución de este árbol y envejece hacia el lado que abre. La vigilancia permanente la da
**CA-03** —el cociente de duplicación, auto-anclado, sin tag y en milisegundos—, que es lo único
que habría visto H-07.

Por eso se enciende a mano con **`ARNES_COSTE_RUTA_CRITICA=1`** (por defecto **apagada**: 37/4 baja
de ~120 s a unos segundos encendiéndose sólo ella). Apagada, sus dos casos dicen **SKIP citando el
número acreditado y su fecha**, nunca PASS. Lo que corre **siempre** son las dos puertas de CA-05
probadas con entradas sintéticas —en el mismo archivo, porque separarlas dejaría la puerta sin
quien la ejerza— y, en `37/5`, las dos magnitudes de CA-08 con las otras dos mitades de CA-06.

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

Las tres decisiones viven en funciones **puras** (`caso47`, `valida47`, `veredicto47`) y por eso el
banco las prueba **siempre**, con entradas sintéticas y en milisegundos, aunque la comparación de
76 s esté apagada: una puerta que sólo se ejerce cuando alguien enciende una palanca es una puerta
de la que nadie sabe si cierra. Y con la de convergencia el argumento es aún más fuerte: en una
corrida sana la sonda **converge**, así que el camino que importa —la abstención— no se recorrería
nunca. Desde REQ-030 esa decisión es el juez del corredor `sonda_juez_razon`, y la prueba de
siempre de 37/5 lo ejerce a **él**, no a una función retirada.

### Las sondas de coste deciden sobre un presupuesto fijo y pueden decir INCONCLUSO (desde 1.35.0)

`ADR-012`, contrato en `requirements/REQ-030.md`. **CA-03** (el cociente de duplicación) y **CA-08 (ii)**
(el reloj contra v1.32.1 en 6 y en 200 líneas) decidían con **una lectura por corrida**, y sus techos
—2,6 y 1,25×— caen **dentro** de la dispersión del runner de CI sobre código idéntico. Los techos **no
se movieron**; cambió el procedimiento:

- **Presupuesto fijo.** Cada caso toma **5 repeticiones** —ni una más, ni una menos, y el número no se
  lee del entorno: es un literal del corredor—. Ninguna se descarta ni se repite por su resultado; la
  que no midió entra como **no resuelta** y cuenta en el denominador («de 5» en todo mensaje).
- **Evaluador por recorrido.** Con **menos de 3** repeticiones resueltas el caso no decide. Con 3 o
  más: **PASS** si **todas** quedan en el techo o por debajo (la igualdad cumple), **FAIL** si
  **todas** lo exceden —y el FAIL describe la medición, no afirma su causa—, y si el techo cae dentro
  del recorrido, **no decide**.
- **La calibración de CA-03 es precondición.** En cada repetición se mide también v1.32.1 con el mismo
  `k`; si ese lado no queda con ≥ 3 resueltas **todas por encima** del techo (exactamente el techo no
  resuelve), el instrumento no demostró ver el defecto y el caso **no decide**: nunca FAIL del
  candidato. El antiguo caso `REQ-017 CA-03 fail-before` (con `k = 1`) desaparece por eso, y su
  función de **detector de un instrumento que no ve el árbol cuadrático** la asume el control **C3**,
  en la misma 37/2 (abajo), que sólo corre con la palanca y da FAIL o no acredita según su regla: en el
  modo por defecto, un instrumento de CA-03 que no ve la cuadrática sale INCONCLUSO, no FAIL.
- **INCONCLUSO** es el nombre de «no decide». Se imprime `SKIP <nombre>  [INCONCLUSO] [<grupo>]
  <motivo y cifras>` —el nombre del caso es el mismo que en PASS y FAIL, para que `inventario.sh` los
  reconozca—; en el cuadre sigue siendo un SKIP. El **grupo** lo declara la propia línea:
  `[rendimiento]` en una medición real (CA-03, CA-08 (ii): **rendimiento no acreditado** en esa
  corrida) e `[instrumento]` en un control (C3 y los de 37/7: **instrumento no acreditado**). La línea
  `Resultado:` publica `(de ellos N INCONCLUSO: R rendimiento, I instrumento, X sin clasificar)` y
  debajo, grupo a grupo, `INCONCLUSO (rendimiento NO acreditado): R …`,
  `INCONCLUSO (instrumento NO acreditado): I …` e `INCONCLUSO (sin clasificar): X …`, cada uno con
  sus casos nombrados con `!`. Una línea con la marca y sin grupo reconocible sale «sin clasificar»:
  no se cuenta como rendimiento en silencio. El reconocimiento vive **sólo** en `run.sh` y cuenta una
  línea `SKIP` cuya evidencia **empieza** por la marca.
- **Dos clases de control del instrumento.** Las pruebas **sintéticas** del evaluador (37/6: vectores
  fijos, sin reloj, **siempre**) y las pruebas **de medición** (37/7: sujetos idénticos, envoltorio
  sin demora y envoltorio con demora fija, **a demanda** con `ARNES_SONDA_CONTROLES=1`, porque son 30
  invocaciones de la sonda de reloj). En los controles el FAIL **esperado** de la demora se comprueba
  como esperado —el caso es PASS si el juez dijo FAIL— y **no** deja el banco en rojo; un INCONCLUSO
  de la demora **no** acredita detección. Detectar una demora añadida es un control **de la prueba**,
  no su finalidad: no garantiza detectar una regresión del escáner, cuyo control sigue siendo la
  calibración contra v1.32.1.
- **C3, el control del instrumento de CA-03** (37/2, SEC-108, decisión D del propietario). **No
  mide nada aparte:** juzga con `sonda_juez_control_c3` (corredor) **la misma serie de calibración de
  v1.32.1** que CA-03 acaba de medir —el mismo `mide37`, la misma ruta de la línea base, 70 000 →
  140 000 bytes, `k = 20`, 5 repeticiones—. Hasta la vuelta 3 vivía en 37/7 con una copia del
  medidor, y una avería que vivía sólo en 37/2 (la ruta de la línea base cambiada) lo dejaba en PASS
  (QA-030-07). **Qué garantiza, por su efecto (SEC-110):** C3 no puede dar PASS —ni acreditar el
  instrumento— salvo que en esa corrida la calibración de v1.32.1 vea la cuadrática (≥ 3 resueltas y
  todas > 2,6×). Una avería que lo impida **sale FAIL o queda no acreditada**: FAIL sólo si se cumple
  la condición de fallo del control (≥ 3 resueltas y todas ≤ 2,6×); **inconcluso**, sin acreditar el
  instrumento y sin demostrar por sí solo una avería, si deja < 3 resueltas o resueltas a los dos lados
  del techo. No toda avería que impide el PASS sale FAIL (QA-030-10). **No cubre** lo que no pasa por la calibración —el brazo «este árbol» de CA-03, las sondas de
  CA-08 (ii)— ni la avería que altera la calibración **sin bajarla del techo**: una línea base que no es
  v1.32.1 pero cuyo cociente también supera 2,6× (SEC-048) da C3 PASS. No promete detectar toda avería
  posible. Tres resultados, que **no** se confunden entre sí:
  - **PASS — «el instrumento ve la cuadrática»:** ≥ 3 resueltas y **todas** > 2,6×. Acredita
    **únicamente** lo que el control mide —que en esa corrida la calibración vio la cuadrática—, con los
    límites de arriba; no que detecte cualquier regresión.
  - **FAIL — «avería demostrada»:** se cumple la condición de fallo del control, ≥ 3 resueltas y
    **todas** ≤ 2,6×. Es un FAIL **real**, no
    esperado: pone el banco en rojo con la palanca encendida. El `fail-before` retirado también ponía
    rojo, pero con otra regla —una sola lectura ≤ 2,6× (`k = 1`)—; C3 no da esos FAIL.
  - **INCONCLUSO — «el control no pudo acreditar el funcionamiento»:** el funcionamiento no quedó
    acreditado; ocurre con menos de 3 resueltas, resueltas a los dos lados del techo, o sin línea base. Marcado `[INCONCLUSO] [instrumento]` y
    contado en su grupo, **nunca PASS**, y **no** demuestra avería.
  - **Sin la palanca:** SKIP con motivo, sin marca, nunca PASS; la calibración sigue siendo la
    precondición silenciosa de CA-03 y una calibración insuficiente no aprueba el instrumento.

  Y ninguno es la **medición real inconclusa** de CA-03 en 37/2, que es **rendimiento** no
  acreditado del árbol candidato; un INCONCLUSO de C3 es **instrumento** no acreditado.

**Qué es mecánico y qué no — dicho sin atribuirle a nadie más de lo que hace.** *Mecánico*, en cada
corrida del banco: el evaluador, la marca y el recuento del resumen, y las pruebas sintéticas; y,
**sólo con la palanca**, los controles de medición: el PASS, FAIL o INCONCLUSO de cada caso —C3
incluido— y el código de salida del banco, que un FAIL de C3 pone en 1. *No mecánico*: la **regla de
aceptación** del instrumento en una entrega que toca la sonda —3 corridas fijas con la palanca;
I y W0 sin FAIL, WD detectado en las 3, y C3 **sin FAIL en ninguna y PASS en al menos una**
(REQ-030 CA-07 (e))— la aplican el `qa-tester` y el `auditor-seguridad`; el banco no cuenta corridas ni
la lee, y el workflow tampoco. Igual de no mecánico es decidir qué significa un
INCONCLUSO para una integración —si el PR es documental, cambia el mecanismo o cambia la propia
sonda (REQ-030 CA-08)—, que lo determina el `desarrollador`, lo verifica el `qa-tester` dentro de su
veredicto, lo revisa el `auditor-seguridad` y lo decide quien integra (CA-09). **El workflow
`.github/workflows/banco.yml` no comprueba la identidad del árbol ni lee los inconclusos**: corre el
banco y mira su código de salida, que con inconclusos y 0 FAIL es **0**. Un check verde, por tanto,
**puede contener una sonda de rendimiento no acreditada**; lo que la hace visible es la línea
`Resultado:` del log del job.

### Los instrumentos de `tests/util/`: la sonda mide, el corredor juzga (desde 1.33.0)

`ADR-005`. Las sondas de medida ya no se reconstruyen dentro de cada sección: viven una sola vez en
`tests/util/` y se **invocan** como programas. Eso **no** deroga la invariante 3 —«un ayudante
compartido va en el corredor»— porque separa dos cosas que iban juntas: los instrumentos **miden y
no juzgan** (no se hacen `source`, no viven en el espacio de nombres de la sección, y la derivación
por `awk` de arriba sigue siendo completa), y **quien juzga sigue viviendo en el corredor**. Lo que
se añadió allí es el **único** parser del registro, el juez de «una sonda que no pudo medir no se
convierte en PASS» y —deliberadamente— **el factor esperado y la banda de la calibración**: con la
banda dentro del archivo que se cuestiona, ensancharla es una línea de la misma edición.

**Cada corrida acredita que el instrumento responde al sujeto.** Antes del despacho, el corredor
ejerce **una calibración por instrumento** con un par de sujetos sintéticos —uno cuyo coste cambia
por un **factor conocido por construcción** al duplicar un parámetro, y uno que no depende de ese
parámetro— y contrasta los dos factores contra la banda. Si no se distinguen, **FAIL**: nunca SKIP
y nunca PASS. Y una medición cuya corrida **no** lleva calibración de su instrumento también es
FAIL, porque «no hay calibración» y «la calibración no distingue» dicen lo mismo: *no sé si estoy
midiendo el sujeto*. Se contrasta **el factor y nunca un coste absoluto**: las tres sondas mudas de
esta ventana medían tiempo real y habían dejado de responder al sujeto, así que **una calibración
por coste absoluto pasa en las tres**.

Sólo se calibra si alguna sección de la vuelta usa un instrumento, y eso se deriva de la misma
pasada de texto de la invariante 1: las vueltas **anidadas** —la sección 32 que 37/4 cronometra, los
directorios sintéticos de la autoprueba— no tocan `tests/util/` y no pagan la calibración. Coste
medido de la palanca (2026-09-07, bash 5.3.9, linux): **~3,4 s de reloj y 69 procesos por vuelta**,
una sola vez. Los detalles de uso, los campos del registro y los ajustes operativos están en
`tests/util/README.md`.

## Por qué importa
- La distinción coordinadora vs. subagente se apoya en el campo `agent_id` del input del hook
  (presente sólo dentro de un subagente). Verificado empíricamente contra `claude` CLI 2.1.183.
- `agent_type` llega **con el prefijo del plugin**: `arnes-juan:desarrollador`. Comparar en crudo
  contra el manifiesto denegaba al único agente autorizado (bug hallado en SENDA, 2026-09-02).
- La cobertura de `Bash` es **parcial a propósito**; los casos "allow" de esa sección son el
  contrato de que no hay falsos positivos sobre comandos de lectura (ver README del plugin).
