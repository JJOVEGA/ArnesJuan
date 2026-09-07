# Sección 36 (1 de 5) del banco — 36-cabecera-comentario-html-1-la-puerta
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
#
# PARTIDA EN CUATRO PORQUE EL BANCO SE LO EXIGE A SI MISMO: ningún archivo de sección pasa
# de 400 líneas (`autoprueba-corredor.sh`, CA-18). Aquí va LA PUERTA —qué deniega y qué
# deja pasar—; en `36-…-2-los-lectores.sh`, lo que la MÁQUINA LEE (los dos lectores y la
# invariante sobre el corpus); en `36-…-3-comentar-retira.sh`, la equivalencia de CA-11; y
# en `36-…-4-el-informe-y-los-textos.sh`, lo que el informe dice, el coste y los textos que
# un proyecto hereda; y en `36-…-5-el-cr-que-no-termina.sh`, la guarda del CR interior
# (SEC-024). Las cinco mitades son independientes: ninguna hace `source` de otra ni depende
# del estado que deje. La 3 y la 4 nacieron en 1.32.1 al añadir CA-11 y las guardas de H-02
# (este archivo llegó a 345 líneas y el de los lectores a 459); la 5, en su vuelta 2.
CASOS_ESPERADOS_SECCION=28

# --- REQ-016: LA CABECERA TIENE NOCION DE CITA ---------------------------------------
# La regresion que esta seccion certifica, dicha sin adornos: un REQ `critico` cuyo
# veredicto de seguridad vigente NO autorizaba el cierre CERRABA si en su cabecera habia
# un rango `<!-- ... -->` con una linea que empezara por la clave del campo y un valor
# autorizante — incluso diciendo el propio comentario que era historico. Bisecada por un
# proyecto consumidor ejecutando cuatro guardianes instalados contra el mismo payload:
# 1.30.2 y 1.30.3 deniegan, 1.31.0 permite, 1.32.0 lo hereda.
#
# FAIL-BEFORE: los casos de esta seccion se corren contra los hooks heredados con
#   ARNES_HOOKS_DIR=/ruta/a/los/hooks/de/1.32.0 bash tests/escenarios/hooks/run.sh secciones/36-*.sh
# y los que llevan «(era ALLOW)» en el nombre TIENEN que fallar ahi. Un caso nuevo que
# pasa con los hooks viejos no esta probando lo que uno cree (README del banco).
#
# Y HAY UN SEGUNDO ARBOL DE REFERENCIA, porque un caso de regresion medido contra la
# version ANTERIOR a la regresion no falla — y entonces el caso miente igual que el que
# pasa contra los hooks viejos. Los casos que llevan «(regresion de 1.32.1)» nacen de una
# conducta que 1.32.0 ya decidia BIEN y que el primer parche de 1.32.1 rompio: su
# fail-before se mide contra el arbol de 1.32.1 SIN el arreglo del CR, no contra 1.32.0.
# Los dos marcadores son distintos a proposito y no se mezclan.
  seccion_nueva "Noción de cita (1/5): el interior de <!-- … --> no declara campo — la puerta (REQ-016):"

# El proyecto de esta seccion: estado terminal `completado`, como el manifiesto base.
mk36() { printf '%s\n' "$2" > "$PROJ/requirements/$1.md"; }
w36()  { emite_write "$PROJ/requirements/$1.md" "$2"; }

# ---------- CA-01 · EL FAIL-OPEN, y el motivo que NO depende del enfasis ----------
# El REQ es el mismo en los seis casos: `critico`, `Seguridad: con-hallazgos` vigente y una
# cita de un veredicto autorizante dentro de un comentario que dice que es historico. Lo
# unico que cambia es el CARACTER DE ENFASIS de la cita — y hasta 1.32.0 ese caracter
# decidia de que lado caia el fallo: cuando el par cruzaba los dos puntos el valor salia
# limpio y GOBERNABA (allow), y cuando el cierre quedaba al final el valor salia sucio y el
# REQ dejaba de poder cerrarse (deny por accidente del desenvoltorio, no por una
# comprobacion). Por eso el motivo se exige que cite el VEREDICTO VIGENTE en los seis.
mk36 REQ-960 '# REQ-960
Estado: en-revisión'
for cita36 in '**Seguridad:** aprobado' 'Seguridad: aprobado' '_Seguridad:_ aprobado' \
              '*Seguridad:* aprobado' '`Seguridad:` aprobado' '**Seguridad: aprobado**'; do
  check_motivo "REQ-016 CA-01 cita '$cita36' en un comentario -> deny por el veredicto VIGENTE (era ALLOW)" \
    'con-hallazgos' guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: con-hallazgos
Rigor: critico
<!-- historia de veredictos: lo de abajo NO es el vigente
$cita36 (A-001, 2026-09-01)
-->
")"
done
# LA CITA DE UNA SOLA LINEA NO ERA UNA SONDA, Y DECIRLO AHORRA UNA TARDE: cuando la clave
# NO encabeza la linea —porque delante va el `<!--`— el lector heredado ya no la leia, asi
# que esta forma DENEGABA antes del arreglo y sigue denegando despues. No demuestra el
# fallo ni su arreglo; esta aqui para que nadie la use como prueba de nada, y para fijar
# que el rango de una linea tambien se retira.
check_motivo "REQ-016 CA-01 la cita de una línea (la clave no encabeza) ya denegaba y sigue denegando" \
  'con-hallazgos' guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: con-hallazgos
Rigor: critico
<!-- **Seguridad:** aprobado (A-001, 2026-09-01) -->
")"
# CA-07 control (ii): EL REQ QUE SI PUEDE CERRARSE, CIERRA. Sin esto, los deny de arriba
# podrian estar denegando por cualquier otra cosa — y la cita seria un veto encubierto.
check "REQ-016 CA-07 control (ii): veredicto vigente autorizante + la MISMA cita -> allow" allow \
  guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Rigor: critico
<!-- historia de veredictos: lo de abajo YA no es el vigente
**Seguridad:** con-hallazgos (A-001, 2026-09-01)
-->
")"

# ---------- CA-01 · vale para los SEIS campos, no solo para el veredicto ----------
# Ejemplos NO EXHAUSTIVOS: el conjunto de campos de cabecera vive en el lector de
# `hooks/lib.sh`, que es su sitio unico.
check_motivo "REQ-016 CA-01 un '**QA:** aprobado' citado no desbanca a 'QA: pendiente' (era ALLOW)" \
  'QA' guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: no
QA: pendiente
Seguridad: n/a
<!--
**QA:** aprobado
-->
")"
check_motivo "REQ-016 CA-01 un '**Hallazgos abiertos:** (ninguno)' citado no borra el hallazgo (era ALLOW)" \
  'usuario/dinero|hallazgo' guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: no
QA: aprobado
Seguridad: n/a
Hallazgos abiertos: SEC-9 (usuario/dinero)
<!--
**Hallazgos abiertos:** (ninguno)
-->
")"
check "REQ-016 CA-01 un '**Sensible a seguridad:** no' citado no rebaja el suelo -> deny (era ALLOW)" deny \
  guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: pendiente
<!--
**Sensible a seguridad:** no
-->
")"
check "REQ-016 CA-01 un '**Rigor:** ligero' citado no baja la ceremonia -> deny (era ALLOW)" deny \
  guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: no
Rigor: critico
QA: aprobado
Seguridad: pendiente
<!--
**Rigor:** ligero
-->
")"
# Y la direccion que SI es conforme: un comentario puede hacer que un REQ DEJE de poder
# cerrarse. Aqui el rango se traga la unica linea que autorizaba, y el REQ no cierra.
check "REQ-016 CA-02 la dirección conforme: la cita se traga el 'Seguridad: aprobado' -> deny" deny \
  guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: sí
QA: aprobado
<!-- Seguridad: aprobado -->
Rigor: critico
")"

# ---------- CA-03 · UN RANGO QUE ABRE Y NO CIERRA: la puerta no puede medir ----------
# El interior de un rango no declara campo; si el rango no CIERRA, la cabecera deja de
# poder medirse y no se sabe cuantos veredictos se han quedado dentro. Ahi la regla es la
# de siempre —una puerta que no puede medir no deja pasar— y, sobre todo, NUNCA se permite
# por AUSENCIA del campo que el rango se trago, porque un campo vacio es justo lo que la
# puerta perdona por compatibilidad.
check_motivo "REQ-016 CA-03 rango sin cerrar tras los veredictos en verde -> deny citando el rango" \
  '<!--' guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: no
QA: aprobado
Seguridad: n/a
<!-- nota que alguien se dejo sin cerrar

## Historia
x
")"
check_motivo "REQ-016 CA-03 el rango sin cerrar se traga el 'QA: pendiente' -> deny, no allow por ausencia" \
  '<!--' guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: no
<!-- nota sin cerrar
QA: pendiente
Seguridad: n/a

## Historia
x
")"
check_motivo "REQ-016 CA-03 el rango sin cerrar se traga la línea del 'Estado:' -> deny igual" \
  '<!--' guard-completado.sh "$(w36 REQ-960 "# REQ-960
<!-- nota sin cerrar
Estado: completado
QA: pendiente

## Historia
x
")"
# El `-->` que vive DESPUES del primer `## ` no cierra nada: la cabecera acaba antes.
check_motivo "REQ-016 CA-03 un '-->' que vive tras el primer '## ' no cierra la cabecera -> deny" \
  '<!--' guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: no
QA: aprobado
Seguridad: n/a
<!-- nota

## Historia
-->
x
")"
# Control en la otra direccion: el MISMO rango, cerrado, y todo en verde -> cierra.
check "REQ-016 CA-03 control: el mismo rango CERRADO y todo en verde -> allow" allow \
  guard-completado.sh "$(w36 REQ-960 "# REQ-960
Estado: completado
Sensible a seguridad: no
QA: aprobado
Seguridad: n/a
<!-- nota que si se cierra -->

## Historia
x
")"
# Y la FRONTERA que este REQ no mueve: un `## ` dentro de un rango sigue TERMINANDO la
# cabecera (regla estructural anterior a esta version, seccion 14), asi que lo que venga
# detras ya no es cabecera para NADIE. El `Estado: completado` de abajo no cierra el REQ ni
# para la puerta ni para el informe ni para el bloque derivado: se permite la escritura
# porque no hay cierre que juzgar, no porque se le perdone uno.
mk36 REQ-961 '# REQ-961
Estado: en-revisión'
check "REQ-016 CA-03 frontera: un '## ' dentro del rango termina la cabecera -> no hay cierre que juzgar" allow \
  guard-completado.sh "$(w36 REQ-961 "# REQ-961
<!--
## nota
-->
Estado: completado
QA: pendiente
")"

# ---------- CA-02 · UN CARACTER DESCONTADO ANTES DE ESCANEAR *FABRICA* EL DELIMITADOR ----
# La clase, dicha una vez: retirar un caracter no puede destruir un delimitador, pero SI
# puede crearlo. Los tres lectores del arnes descontaban TODOS los retornos de carro antes
# de escanear el rango —el lector de linea, la extraccion del `tool_input` y la
# reconstruccion del documento del `Edit`—, asi que un `-\r->` suelto llegaba al escaneo
# como `-->` y un `<!\r--` como `<!--`. Consecuencia medida (H-01): un veredicto que vive
# DENTRO del comentario gobernaba, y un rango que para cualquier persona y cualquier
# renderizador NUNCA cierra parecia cerrado. Es la misma familia que el hueco del rango
# —que se sustituye por un espacio justo para no fabricar una clave— y CA-02 la nombra
# como ejemplo de lo que su invariante NO acota.
#
# El CR se descuenta AHORA despues del escaneo (y en el transporte, solo el que termina
# una linea), asi que la fabricacion desaparece por las tres vias. Una por caso: no es
# una forma, es una clase, y cada boca del hook es una boca distinta.
CR36=$'\r'
mk36 REQ-964 '# REQ-964
Estado: en-revisión
Sensible a seguridad: sí
QA: aprobado
Seguridad: pendiente
Rigor: critico'
check "REQ-016 CA-02 un CR suelto NO fabrica el '-->': el veredicto citado no gobierna -> deny (era ALLOW)" deny \
  guard-completado.sh "$(w36 REQ-964 "# REQ-964
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: pendiente
Rigor: critico
<!-- historia: lo de abajo NO es el vigente -${CR36}->
Seguridad: aprobado (A-001, 2026-09-01)
-->
")"
# La MISMA fabricacion por la otra boca: aqui el CR vive en DISCO y el `Edit` solo cambia
# el valor del estado, asi que quien tenia que descontarlo era la reconstruccion del
# documento resultante. Sin este caso el arreglo quedaba a medias y nadie lo veria: la via
# `Write` y la via `Edit` no comparten el paso que fabricaba.
mk36 REQ-965 "# REQ-965
Estado: en-revisión
Sensible a seguridad: sí
QA: aprobado
Seguridad: pendiente
Rigor: critico
<!-- historia: lo de abajo NO es el vigente -${CR36}->
Seguridad: aprobado (A-001, 2026-09-01)
-->"
check "REQ-016 CA-02 ...y tampoco por la vía del Edit, con el CR en disco -> deny (era ALLOW)" deny \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-965.md" 'Estado: en-revisión' 'Estado: completado')"
# CA-03 con el CR: el rango no cierra, se traga el `QA: pendiente`, y la AUSENCIA no se
# perdona. 1.32.0 ya lo denegaba —por casualidad, porque no tenia nocion de cita— y el
# primer parche de 1.32.1 lo abrio: de ahi el marcador distinto.
#
# EL MOTIVO CAMBIO EN LA SEGUNDA VUELTA DE 1.32.1, Y EL CAMBIO SE DECLARA AQUI. Este caso
# exigia que el motivo citara el rango (`<!--`); ahora la puerta lo deniega ANTES, por el
# CR que no termina la linea (SEC-024), que es la causa que la persona NO puede ver en su
# editor. El veredicto no se mueve —deny en las dos— y la propiedad que este caso
# defendia, «la ausencia del campo tragado no se perdona», la sigue midiendo su gemelo SIN
# CR de mas arriba (`el rango sin cerrar se traga el 'QA: pendiente'`), que es el que la
# prueba en limpio. Lo que este caso mide ahora es que cuando concurren las dos averias
# gana el motivo que nombra la invisible.
mk36 REQ-966 '# REQ-966
Estado: en-revisión'
check_motivo "REQ-016 CA-03 un '-\$CR->' no cierra el rango, y el motivo nombra el CR invisible -> deny (regresión de 1.32.1)" \
  'retorno de carro' guard-completado.sh "$(w36 REQ-966 "# REQ-966
Estado: completado
Sensible a seguridad: no
<!-- nota que NUNCA se cierra
QA: pendiente
-${CR36}->
Seguridad: n/a
")"
# EL CRLF LEGITIMO DECIDE IGUAL QUE EL LF, en las dos direcciones. Es la mitad que un
# arreglo del CR puede romper sin que nadie lo note: los proyectos en Windows guardan
# CRLF, y si el descuento se estrecha de mas la cabecera entera deja de leerse.
mk36crlf36() { printf '%s\r\n' "# $1" 'Estado: en-revisión' 'Sensible a seguridad: sí' \
  'QA: aprobado' "Seguridad: $2" 'Rigor: critico' > "$PROJ/requirements/$1.md"; }
crlf36() { printf '# %s\r\nEstado: completado\r\nSensible a seguridad: sí\r\nQA: aprobado\r\nSeguridad: %s\r\nRigor: critico\r\n' "$1" "$2"; }
mk36crlf36 REQ-967 pendiente
check "REQ-016 CA-04 un REQ guardado ENTERO en CRLF con el veredicto en rojo -> deny igual que en LF" deny \
  guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-967.md" "$(crlf36 REQ-967 pendiente)")"
mk36crlf36 REQ-968 aprobado
check "REQ-016 CA-04 ...y en CRLF con todo en verde cierra igual que en LF -> allow" allow \
  guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-968.md" "$(crlf36 REQ-968 aprobado)")"
# `--!>` es fin de comentario para un renderizador HTML y NO para el arnes, asi que el
# rango sigue ABIERTO para la puerta: cae del lado que cierra (CA-03) y ahi se queda. El
# caso existe para que el arreglo del CR no lo cambie de lado sin querer; alinear la
# lectura con el renderizador seria una decision de diseño, no un parche, y no esta en
# ningun criterio.
mk36 REQ-969 '# REQ-969
Estado: en-revisión'
check_motivo "REQ-016 CA-03 un '--!>' no cierra el rango para el arnés: sigue cayendo del lado que cierra" \
  '<!--' guard-completado.sh "$(w36 REQ-969 "# REQ-969
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: pendiente
Rigor: critico
<!-- historia --!>
Seguridad: aprobado (A-001, 2026-09-01)
")"

# ---------- CA-04 · LA TOLERANCIA DE CLAVE, FUERA DE LOS RANGOS, NO SE TOCA ----------
# La propuesta facil era exigir la clave a columna cero y sin decorar para que la linea
# CUENTE. Se descarto por construccion: esa tolerancia cerro un fail-open real —un estado
# terminal escrito en forma decorada que ninguna puerta veia—, y recortarla lo reabre. Lo
# que faltaba no era la tolerancia: era ACOTAR DONDE se aplica. Estos casos son la frontera
# escrita, para que nadie la recorte por el camino.
mk36 REQ-962 '# REQ-962
Estado: en-revisión'
check "REQ-016 CA-04 '**Estado:** completado' FUERA de todo rango sigue viéndose -> deny" deny \
  guard-completado.sh "$(w36 REQ-962 "# REQ-962
**Estado:** completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-016 CA-04 '  Seguridad: pendiente' sangrado, fuera de rango, sigue gobernando -> deny" deny \
  guard-completado.sh "$(w36 REQ-962 "# REQ-962
Estado: completado
Sensible a seguridad: sí
QA: aprobado
  Seguridad: pendiente
")"
check "REQ-016 CA-04 '**Seguridad:** aprobado' fuera de todo rango GOBIERNA y cierra -> allow" allow \
  guard-completado.sh "$(w36 REQ-962 "# REQ-962
Estado: completado
Sensible a seguridad: sí
**QA:** aprobado
**Seguridad:** aprobado
**Rigor:** critico
")"

