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
Requiere `jq`. Sale con código ≠ 0 si algún caso falla. **735 casos** (el número exacto lo cuadran
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
Cuatro reglas que el banco se aplica **a sí mismo**. No son estilo: cada una nació de una vuelta
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

## Por qué importa
- La distinción coordinadora vs. subagente se apoya en el campo `agent_id` del input del hook
  (presente sólo dentro de un subagente). Verificado empíricamente contra `claude` CLI 2.1.183.
- `agent_type` llega **con el prefijo del plugin**: `arnes-juan:desarrollador`. Comparar en crudo
  contra el manifiesto denegaba al único agente autorizado (bug hallado en SENDA, 2026-09-02).
- La cobertura de `Bash` es **parcial a propósito**; los casos "allow" de esa sección son el
  contrato de que no hay falsos positivos sobre comandos de lectura (ver README del plugin).
