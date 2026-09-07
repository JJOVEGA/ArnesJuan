# CHANGELOG — ArnesJuan

> Bitácora de versiones del plugin. SemVer; cada versión tiene su tag `vX.Y.Z`.

## [GitHub] — 2026-09-07 · REQ-017, delta de CA-05: el plazo se deriva del numerador, y el CI vuelve a tener tags (H-08)
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

**Delta de implementación del write-back de CA-05, más el cierre de H-08 por ampliación de comisión
aprobada por el propietario (gate humano de `AGENTS.md` §6: el workflow de CI es decisión humana).**
El `Estado:` de REQ-017 **no se toca**: sigue `en-progreso` hasta que firmen QA y el auditor.

**1 · `ARNES_COSTE_RUTA_CRITICA` invierte su defecto: apagada salvo `=1`.** Corriéndola en cada
vuelta, la sección 37/2 costaba ~120 s —~76 s de ellos la corrida heredada, que cuesta lo que
costaba el defecto porque **es** el defecto corriendo— y dejaba el banco en ~145 s: **la puerta
requerida de `main` más lenta que la regresión de 92 s que REQ-017 arregla**, y de forma permanente,
porque su línea base es un tag congelado. Una razón contra un tag es **acreditación de fail-before,
no puerta permanente**. La vigilancia permanente la da CA-03, auto-anclada y en milisegundos.
Apagada, los dos casos dicen **SKIP citando el número acreditado y su fecha** (0,125× — 9,60 s
frente a 76,19 s), nunca PASS. 37/2 baja de ~120 s a **12,5 s**; encendida cuesta **76,1 s**.

**2 · El denominador ya no se mide: se acota, con un plazo DERIVADO del numerador.** La corrida
heredada se lanza bajo `timeout` de **4 × mín(este árbol)**, calculado en la misma corrida y
**después** del numerador (`⌈4 × u_este / 10⁶⌉` s, redondeo **hacia arriba** — abajo probaría una
desigualdad más floja que la contratada). Un plazo escrito a mano en segundos sería el **reloj
absoluto** que todo REQ-017 combate: lo falsea la máquina, el runner y `nice`. Derivado, la máquina
se cancela igual que en una razón. **El vencimiento es un PASS, nunca un SKIP:** si el plazo vence,
`heredada > 4 × este` y el cociente contratado (≤ 0,25×) queda **demostrado**, no estimado — un SKIP
ahí convertiría el hallazgo en silencio. Sin `--foreground`, `timeout` señala al **grupo de
procesos** entero, así que no queda una corrida de 76 s huérfana envenenando el reloj de la sección
siguiente (CA-06, el fallo de 3 h 41 min de 1.32.1).

**Fail-before / pass-after de la rama nueva, las dos medidas:** con este árbol la heredada **no**
termina en 36 s = 4 × 8,81 s → **PASS**; con `ARNES_HOOKS_DIR` := v1.32.1 —«este árbol» *es* el
enfermo— la heredada **termina** dentro de 285 s = 4 × 71,17 s → **FAIL**. La mitad (ii) pasa a ser
**auto-anclada**: las 3 corridas cronometradas dan el mismo inventario **entre sí** (40 casos); la
igualdad contra el árbol heredado la cierra CA-02 sobre el banco entero.

**3 · H-08 cerrado: `fetch-depth: 0` en el checkout del CI.** Sin tags, el árbol congelado que once
criterios materializan no existe en CI y todos salían SKIP: la puerta requerida dio verde en el PR
#43 sobre el único REQ del PR sin ejecutar ni una de sus comprobaciones. **Lo aprobado es la
combinación de 1 y 3**, y ése es el punto: recuperar los tags sin apagar 37/2 añadiría sus ~120 s a
la puerta requerida; apagar 37/2 sin recuperar los tags dejaría el resto en SKIP igual que hoy.

**El coste, medido y no estimado, porque era la condición de la aprobación:** banco **sin** tags
`833 PASS · 0 FAIL · 12 SKIP · 45,85 s` —que reproduce **exactamente** el resultado del PR #43— →
**con** tags y 37/2 apagada `842 PASS · 0 FAIL · 3 SKIP · 55,98 s`. **+10,1 s (+22 %) compran nueve
criterios que pasan de no medirse a medirse**, CA-03 incluida, que es la única auto-anclada.
Checkout: 0,202 s superficial y sin tags → 0,346 s completo (**+0,14 s**; `.git` 1,2 → 1,6 MB, 40
tags). Se eligió `fetch-depth: 0` y no `fetch-tags: true` porque éste mantiene la profundidad 1 y
deja la prueba colgando de las semánticas del clon superficial, cuyo modo de fallo **es H-08**:
medio funciona y se lee como verde.

**Sigue abierto**, y se dice: la tercera consecuencia de H-08 —un SKIP honesto agregado a un
resultado global se lee como verde— no la cierra esto. Que hoy en CI queden tres es una propiedad
del entorno, no del corredor. Es la palanca «¿esta prueba mide algo?» de 1.33.0.

Quality gates en verde: `bash -n` sobre `hooks/`, `tools/` y el banco entero; `jq -e` sobre
`hooks.json`, `plugin.json` y `marketplace.json`; banco `842 PASS · 0 FAIL · 3 SKIP` con el cuadre
de 845 casos cerrado; autoprueba del corredor `73 PASS · 0 FAIL`.

Archivos: `tests/escenarios/hooks/secciones/37-coste-del-escaner-2-la-seccion-caliente.sh`,
`tests/escenarios/hooks/README.md`, `.github/workflows/banco.yml`, `docs/PENDIENTES.md`,
`docs/qa/1.33.0.md`, `requirements/REQ-017.md`.

## [Interno] — 2026-09-07 · Caso J: el bisecado que lo explica, y dos formas medidas al revés
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

**Segundo informe de campo sobre el caso J, verificado ejecutando** `hooks/guard.sh` del plugin
instalado 1.32.1 contra un proyecto efímero, con control positivo en la misma tanda. Confirmado: la
clave decorada **fuera** de todo comentario sigue desbancando al veredicto vivo y cierra un `critico`
con `Seguridad: con-hallazgos` en la cabecera.

**Lo que el informe aporta y no teníamos: el bisecado.** Hasta 1.30.3 la clave se anclaba con un
literal a columna cero, así que `**Seguridad:** aprobado` **no era un campo**; J denegaba por eso y no
por ninguna virtud del rango de comentario. Con la tolerancia al énfasis de 1.31.0, I y J pasan a ser
**la misma mitad partida por la única característica que no comparten** — el rango—, que es
exactamente por qué el arreglo de 1.32.1 alcanzó a una y no a la otra.

**Y el argumento que decide el diseño:** las dos reglas que producen J —tolerar el énfasis, y que gane
la última aparición— **son correctas por separado**; el defecto es la **conjunción**. Por eso la salida
no puede ser una preferencia entre formas sino la pregunta de estado: *el mismo campo declarado dos
veces con valores distintos no se puede medir ⇒ deniega*.

**Dos correcciones medidas aquí, una en cada dirección:** la celda de tabla que el reportante predecía
como hueco **deniega** (el `|` inicial no se tolera), y en cambio **la indentación sí es hueco** —
`  Seguridad: aprobado` con dos espacios permite—, forma que no estaba en ninguna lista y que
importa porque **no es decoración**: descarta por sí sola la alternativa de «una clave decorada no
desbanca a una limpia».

**La mitad que faltaba:** si la puerta deniega por ambigüedad y el bloque derivado publica uno
cualquiera de los dos valores, vuelve la divergencia entre las dos mitades del lector que 1.32.1 cerró
en H-01. La marca de ambigüedad la emite el lector una vez y la consumen las dos.

Clase `contrato`, **ventana 1.34.0** (movida al partirse 1.33.0; además colisiona por archivo con
REQ-017, que tiene `hooks/lib.sh` tomado). Archivos: `docs/PENDIENTES.md`.

## [Interno] — 2026-09-07 · H-08: el CI dio verde sobre REQ-017 sin medir ninguno de sus criterios
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

**Medido en el PR #43 (borrador), ejecución `hooks-en-linux` de 51 s: `833 PASS, 0 FAIL, 12 SKIP`.**
**Once de esos doce SKIP son los criterios de REQ-017** —CA-01 (las dos formas), CA-03, CA-04 (las
dos), CA-05 (i) y (ii) y CA-08 (las cuatro)—, todos con el mismo motivo declarado: *«no hay línea
base: el tag v1.32.1 no está en este clon»*. Causa de una línea: `actions/checkout@v4` clona con
`fetch-depth: 1` y **sin tags**, así que los árboles congelados que esos criterios materializan no
existen ahí. La **puerta requerida de `main`** dio verde sobre el único REQ del PR sin ejecutar
ninguna de sus comprobaciones.

**Las sondas no fallaron: `CA-06` pasó**, que es exactamente el criterio de «sin línea base, SKIP con
motivo, nunca PASS». El defecto está una capa más arriba — **un SKIP honesto, agregado a un resultado
global, se lee como verde**. Confirma CA-05 desde el otro lado: una comprobación contra línea base
congelada no necesita **envejecer** para abrirse; basta con que el entorno no tenga el tag. Y es un
forzador medido para la palanca «¿esta prueba mide algo?», que ya estaba en 1.33.0: se pensó para
casos **vacíos** y esto es un caso **lleno que no se ejecuta**, con la misma propiedad detrás.

Clase `instrumento`, dueño `desarrollador`. El arreglo (`fetch-depth: 0`) va con el delta de REQ-017,
no antes: encarece la puerta requerida y esa decisión ya estaba escalada con CA-05. Archivos:
`docs/PENDIENTES.md`, `docs/ESTADO.md`.

## [Interno] — 2026-09-07 · 1.33.0 se parte: las palancas primero, el núcleo a 1.34.0
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

**Decisión del propietario.** La ventana 1.33.0 había crecido durante la ventana anterior hasta **nueve
trabajos** —tres palancas de coste, la cuarta, REQ-011, dos barridos por estado, el rigor comprobable,
el caso J y una pasada de conformidad con cinco piezas—, ~8–10 h de reloj de agente. Es la forma exacta
en que se descontroló el ciclo 3. Se parte: **1.33.0 = las cuatro palancas de coste** (REQ-017 en curso,
la puerta de «¿esta prueba mide algo?», `tests/util/` y el adelgazamiento de `AGENTS.md`), ≈3 h, que
caben en un ciclo semanal; **1.34.0 = el núcleo por estado** más lo que ya tenía, ≈6 h.

**El motivo no es el calendario: es la atribución.** Las palancas abaratan el núcleo, así que medirlas
**antes** de empezarlo es la única forma de saber cuánto abaratan de verdad; juntas, ahorro y gasto se
mezclan — el mismo error que la línea base envenenada por la sonda desbocada de 1.32.1.

**El adelgazamiento de `AGENTS.md` se adelanta desde 1.34.0** y cierra la pregunta que quedaba abierta
en la cola de `docs/ESTADO.md`: son ~9 k tokens de impuesto fijo en **cada** subagente —una comisión de
subida de versión gastó 28 500 tokens para ~3 000 de trabajo real—, y 1.34.0 es la ventana con más
comisiones: adelgazarlo después sería pagarlo entero primero.

**El paralelismo entra en 1.34.0, y la palanca 3 es lo que lo desbloquea.** Hoy casi nada se despacha en
paralelo porque `skills/arnes-upgrade/SKILL.md` colisionaba en **15 de 15** pares de comisiones. Retirada
esa colisión, `tools/arnes-paralelo.sh` puede declarar `disjunto` de verdad — condición **necesaria y no
suficiente** mientras **SEC-020** siga abierto, y sin tocar el orden de fases, que no se paraleliza en
ningún caso. Archivos: `docs/PLAN.md`, `docs/ESTADO.md`.

## [Interno] — 2026-09-07 · REQ-017 implementado: una sentencia, y la magnitud que no miente
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

**El arreglo es una sentencia.** `arnes_sin_cita` (`hooks/lib.sh`) abre ahora con
`case "$l" in *$'\r'?*)` en vez de `case "${l%$'\r'}" in *$'\r'*)`. La eliminación de sufijo **con
patrón** la resuelve bash probando cada posición —O(n) intentos de O(n)—, y preguntar «¿hay un CR con
al menos un carácter detrás?» es **la misma proposición**: el único CR que la eliminación podía retirar
es el final, y sólo si está al final. La guarda **no se movió**: sigue siendo la **primera sentencia del
único escáner**, que es la restricción anti-deriva que REQ-016 contrató — se abarata *cuándo* se paga,
no *dónde* vive. Medido: cociente de duplicación **3,95 → 1,90** (lineal); sección 32 **76,19 s →
9,60 s** (0,125×); banco completo **95,66 s → 45,14 s**; e inventario ordenado de 828 casos **idéntico
byte a byte**. Y las dos magnitudes de CA-08 juntas: **0 procesos añadidos** (5 = 5) **y** reloj
**0,998×** / **1,000×** en el camino de una cabecera normal — el arreglo no compró tiempo con un `fork`.

**Lo que sobrevive al arreglo.** `requirements/README.md` y su plantilla heredable ganan la **cuarta
forma prohibida** de criterio: **«(d) fijar la magnitud equivocada»**, con su caso medido —`CA-08` de
REQ-016 **se cumplía**, midiendo procesos correctamente, sobre una regresión de **10×** de reloj—, la
regla por propiedad (un criterio de coste declara **qué magnitud mide y por qué es ésa la que se
degrada**, y se escribe como **razón o propiedad estructural**, nunca como reloj absoluto), la tabla de
cómo se contrata cada pregunta, el **mínimo de k** como estadístico y su línea en la Definition of
Ready. `CA-08` de REQ-016 **no se reescribe**: está `completado` y se cumplió tal como estaba escrito.

**Banco:** dos secciones nuevas, `37-coste-del-escaner-1-escala` y `37-coste-del-escaner-2-la-seccion-caliente`
(17 casos; total **845**), que miden contra los árboles **v1.32.1** y **v1.32.0** materializados desde su
tag en la misma corrida, con **fail-before** en CA-03 y CA-04. Invariante nueva del corredor (CA-06):
**nada de una sección sobrevive a su sección** — al cerrarla se mira `jobs -pr`, se mata lo que quede y
la vuelta **aborta nombrando el archivo**; nació de la sonda que en 1.32.1 vivió 3 h 41 min y falseó una
línea base. **CA-09 medido, no movido:** la pared de los 60 s pasa de **≈ 0,94 MB** a **≈ 1,60 MB**;
sigue cuadrática por `arnes_norm_clave`, que es `SEC-030` y tiene dueño propio.

**Coste declarado, y va en rojo a propósito:** la sección 37/2 cuesta **~120 s** —76 de ellos son la
corrida heredada, que cuesta lo que costaba el defecto porque **es** el defecto corriendo—, así que el
banco completo pasa de 45 s a **~145 s**. CA-05 tal como está contratado hace la puerta requerida de
`main` **más lenta que la regresión que certifica**. Se implementa como está escrito y se escala la
decisión; el detalle y la alternativa, en `docs/qa/1.33.0.md`.

## [Interno] — 2026-09-07 · REQ-017: la primera palanca de coste de 1.33.0
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

Se abre la ventana **1.33.0** (gobernada por la instalación estable 1.32.1) con **REQ-017** en
`pendiente`, `Rigor: critico`, `Sensible a seguridad: sí`: `arnes_sin_cita` es **cuadrática** en la
longitud de línea por la eliminación de sufijo `${l%$'\r'}` (`hooks/lib.sh:1643`), que bash resuelve
probando cada posición — el banco pasa de 39 s a **92 s** y su ruta crítica de 7,6 s a **75,7 s**. Una
llamada normal **no** se resiente (0,1195 → 0,1188 s), y queda escrito para que nadie lo lea como una
regresión de usuario.

**La segunda mitad, que es la que importa:** `CA-08` de REQ-016 **se cumplía** —medía **procesos**, 4 = 4,
correctamente— mientras se degradaba el **reloj** 10×. Un criterio de coste que fija la magnitud
equivocada da verde sobre una regresión. REQ-017 contrata la corrección **y** el ojo: criterios de coste
como **cociente de duplicación** (el coste no crece más que linealmente) y como **razón contra una línea
base medida en la misma corrida**, nunca como reloj absoluto —un umbral en segundos lo falsea la carga de
la máquina, y esta ventana ya midió una sonda que sobrevivió 3 h 41 min a su comisión y envenenó una
línea base—. Causa: `H-07` (`instrumento`) de `docs/qa/1.32.1-hallazgos-vuelta-3.md` §5. `SEC-030` (la
pared de 60 s) queda **enlazado y fuera de alcance**: preexiste en los dos árboles y tiene dueño propio.

## [Cierre] — 2026-09-07 · Cierre documental de la ventana 1.32.1
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

`REQ-015` y `REQ-016` a `completado` **por la puerta**, con `Edit` y nunca por consola. `v1.32.1`
publicada, tag verificado contra los tres manifiestos, instalación estable actualizada con los hooks
**idénticos al tag**. Se registra lo que cruza a 1.33.0 con dueño y ventana: `SEC-020`, `SEC-030`,
`H-07`, `H-06` y el bloque derivado que publica un veredicto sobre una cabecera que la puerta se niega
a medir.

**La lección nueva, y apareció cuatro veces en una sola ventana:** *interrogar al mecanismo tiene una
vía nueva cada vez; interrogar a la propiedad no envejece.* Los cinco casos de banco vacíos, el barrido
de migración, el control de datos de cliente y el guardián del intérprete son el **mismo error de
forma** — preguntar por la **vía** cuando la propiedad es de **estado**. Es la columna vertebral de
1.33.0.

## [1.32.1] — 2026-09-07 · El parche que no parcheaba a la primera
> Origen: GitHub (commit de la ventana) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos`, `desarrollador`, `qa-tester` (Opus), `auditor-seguridad` · gobernado por la instalación estable **1.32.0**.

**Dos fallos en abierto en el mecanismo que gobierna a los demás proyectos.**

- **REQ-015 — `usuario/dinero`.** El temporal de **nombre fijo** de la continuidad destruía texto
  humano de `docs/ESTADO.md` con dos paradas simultáneas. El recurso compartido no era «el momento»:
  era el **inodo**, y un descriptor abierto mantiene esa ventana el tiempo que uno quiera. De ahí una
  reproducción **determinista** que sustituye a un caso que fallaba 1 de cada 25 veces.
- **REQ-016 — `contrato`.** Una **regresión bisecada**: 1.30.2 y 1.30.3 deniegan, **1.31.0 permite**,
  1.32.0 lo hereda. Un veredicto citado dentro de un comentario HTML de la cabecera cerraba un REQ
  `critico` **sin auditoría de seguridad aprobada**. Llegó por el informe de un proyecto consumidor.

**Lo que costó, y por qué se cuenta.** 15 comisiones, ~2,3 M de tokens medidos y **3 vueltas dev↔QA
agotadas**. El primer arreglo **no cerró el agujero**: el retorno de carro se descontaba **antes** de
escanear el rango, y `-\r->` se convierte en `-->`. Resultó tener **cuatro bocas** —el lector de
línea, la extracción del `tool_input`, la reconstrucción del `Edit` con el CR en disco y el mapa de
paralelismo—, y las cuatro se cerraron con una sola **pregunta cerrada**: *una línea de cabecera con
un CR que no es el que la termina no se puede medir, y una puerta que no puede medir no deja pasar.*

**Tres de los cuatro fallos en abierto de esta ventana los introdujo el propio parche**, y ninguno
salió de leer el código: los cuatro salieron de **medir la consecuencia**. QA rompió el arreglo del
desarrollador; el desarrollador se rompió a sí mismo midiendo; el auditor rompió lo que QA había
aprobado — dos veces.

**Añadido**
- Publicación concurrente sin colisión: temporal propio de cada proceso, **fail-closed** si no puede
  componer un nombre propio, y purga que retira sólo lo huérfano (REQ-015).
- El lector de cabecera tiene **noción de cita**: lo que vive dentro de un rango `<!-- … -->` no
  declara campo, con la misma regla en los **cuatro** lectores (REQ-016).
- **CA-12:** una cabecera con un CR interior no se puede medir → **DENY**, por medibilidad y no por
  veredicto. Con su fila en `AGENTS.md` §13 y en la plantilla heredable.
- El banco pasa de **683 a 828 casos**, en 41 secciones.

**Corregido**
- `arnes-paralelo.sh` ya no responde `disjunto` sobre un mapa citado dentro de un comentario.
- `arnes-lectura.sh` nombra la línea decorada que gobierna, sin cambiar el código de salida por eso.
- **Cinco casos del banco que no medían nada** y pasaban contra la versión con el agujero.
- El nombre de un proyecto consumidor, que estaba publicado en este archivo desde el PR #26.

**Residuales declarados, con dueño y ventana 1.33.0:** `H-07` (`arnes_sin_cita` es cuadrática sobre
líneas largas: el banco pasa de 39 s a 92 s; una llamada normal no se resiente, medido), `SEC-030` (la
pared de 60 s del hook se alcanza hacia 1,5 MB y `AGENTS.md` §13 no la enumera entre sus huecos), y el
bloque derivado publicando un veredicto que la puerta se niega a medir.

**Si corriste 1.31.0 o 1.32.0, audita tus REQ cerrados.** El parche cierra la puerta de aquí en
adelante; **no revisa lo que ya cerró**. El procedimiento está en `skills/arnes-upgrade/SKILL.md`
§ `Hacia 1.32.1`, y declara qué encuentra y qué **no** puede encontrar.

## [Interno] — 2026-09-07 · Write-back de SEC-024: el tapón, contratado (CA-12) — rama `cand/1.32.1`
> Origen: Interno (sin commit propio; entra en el commit de la ventana) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (REQ-016, `Rigor: critico`; origen: **hallazgo del auditor de seguridad** `docs/seguridad/registro-seguridad.md` § R-008, SEC-024, clase `contrato`).

**«CA-02 contrata el agujero; nada contrata el tapón.»** El auditor verificó que el código de SEC-024
cierra las dos caras del retorno de carro y aun así no firmó: el control vivía **sólo** en el código,
en 19 casos de banco y en el registro de seguridad, así que podía retirarse en la ventana siguiente
sin que ningún contrato lo notara — la deriva que `AGENTS.md` §9 prohíbe. Prosa de analista, cero
código, sin vuelta dev↔QA.

- **CA-12 (nuevo), por propiedad y no por sitio:** *una línea de la cabecera con un retorno de carro
  que no es el que la termina deja una cabecera que **no se puede medir**, y una puerta que no puede
  medir **no deja pasar** → DENY citando la línea*. Las dos caras —delimitador fabricado y clave
  fabricada— son **la misma** propiedad, marcadas como ejemplos no exhaustivos, con el sitio único de
  la lista de caracteres de control (`hooks/lib.sh`).
- **La denegación es por MEDIBILIDAD, no por veredicto, y eso es lo que se comprueba:**
  `Estado: comple\rtado` con todo en verde deniega **por la guarda**; resolverlo como **ausencia**
  incumple, porque la ausencia es lo que la puerta perdona.
- **Las tres fronteras dichas, para que nadie «arregle» esto rompiendo Windows:** el CR final es
  transporte (CRLF decide idéntico a LF), el cuerpo no se restringe y **reabrir** no se bloquea.
- **CA-04 acotada sin perder fuerza:** la tolerancia a la clave decorada fuera de los rangos sigue sin
  restringirse; se le añade la frontera de que opera sobre una cabecera **medible**.
- **Una fila nueva en la tabla de invariantes** de `AGENTS.md` §13 y **la misma** en
  `templates/AGENTS.md.tpl`: dejar una puerta nueva fuera de ese mapa es deriva. Sin ADR (describe lo
  construido; no cambia alcance ni decisión base).

## [Interno] — 2026-09-07 · Vuelta 2 del bucle dev↔QA de 1.32.1: la otra cara del CR, la que abre (rama `cand/1.32.1`)
> Origen: Interno (sin commit propio; entra en el commit de la ventana) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (REQ-016, `Rigor: critico`; origen: **hallazgos del auditor de seguridad** `docs/seguridad/registro-seguridad.md` § R-007, SEC-024 y SEC-025, vuelta 2 de 3).

**«No fabricar» tiene dos consecuencias opuestas, y la vuelta 1 sólo tenía caso para una.** Al dejar
de descontar el retorno de carro antes de escanear el rango, un `-\r->` deja de leerse como `-->` y el
rango queda **abierto** → deniega. Correcto. Pero para el **abre** la misma decisión se **invierte**:
un `<!\r--` deja de leerse como `<!--`, el rango **nunca se abre** y lo que el autor aparcó dentro del
comentario **gobierna**. Medido por el auditor sobre una cabecera base del corpus —`critico`, sin
ninguna declaración de `Seguridad:`—: añadirle un rango con el abre fabricado y un `Seguridad:
aprobado` dentro convertía un `deny` en `allow`. Con su control: la misma forma con `pendiente` dentro
denegaba, así que el `allow` venía **de la cita gobernando**. Y el sitio lo empeora igual que el
defecto original: un analizador de HTML trata `<!` seguido de algo que no sea `--` como *bogus
comment* y lo consume hasta el primer `>`, así que un renderizador puede **esconder** el bloque
mientras la puerta lo lee.

- **El remedio describe el ESTADO, no la vía** (sexta instancia de la misma lección): **una línea de
  la cabecera que contiene un CR que no es el que la termina deja una cabecera que no se puede medir
  → DENY**, citando la línea con el CR escrito `\r`. Cubre las dos caras y cualquier objetivo futuro
  del mismo carácter, porque no habla del objetivo sino del carácter.
- **De paso cierra la CLAVE fabricada**, que **no nace en esta ventana**: `Seg\ruridad: aprobado`
  cerraba un REQ `critico` desde **≤1.30.3** —`arnes_norm_clave` retira el CR después de la cita y
  fabrica la clave—, y los dos lectores coincidían, así que ningún criterio lo desmentía.
- **La guarda vive en el ESCÁNER, no en una boca.** Es la primera sentencia de `arnes_sin_cita`, el
  único escáner de cabecera del arnés, así que las cuatro bocas —lector de línea, `arnes_jq_str`, la
  reconstrucción del `Edit` con el CR en disco y `tools/arnes-paralelo.sh`— llegan a él con la línea
  cruda y ninguna puede alcanzarlo «ya limpia». El orden es **por construcción**, no por inspección.
- **No estrecha ninguna tolerancia y no toca el CRLF.** El CR que termina la línea sigue siendo
  transporte: un REQ guardado entero en CRLF cierra igual que en LF, con casos en las dos direcciones
  y el cruce que faltaba (CRLF **con** un comentario bien escrito en la cabecera). `Estado:
  comple\rtado` deja de leerse como estado terminal **por denegación, no por ausencia**, que es la
  dirección que el descarte de la vuelta 1 exigía.
- **Los informes dejan de mentir.** `tools/arnes-lectura.sh` decía «ningún valor anómalo», rc 0, sobre
  un documento que cerraba un `critico`: ahora lo nombra como anomalía y enseña la línea. Y
  `tools/arnes-paralelo.sh` respondía `disjunto` con rc 0 sobre una cabecera no medible: ahora
  **colisiona con motivo**, que es la dirección segura.
- **SEC-025 — una frase que prometía completitud y era falsa.** El barrido de migración busca `<!--`,
  así que no encuentra ni el delimitador de apertura fabricado ni la clave fabricada. **No se ensanchó
  el patrón**: la guía enuncia ahora la pregunta que no envejece —de **estado**, «cuáles de mis REQ en
  estado terminal NO cerrarían hoy»— **antes** de ofrecer ningún comando, y cada barrido por vía
  declara, junto al comando, que interroga una vía, qué vías conocidas no encuentra y que **no hallar
  nada no acredita ausencia de exposición**. La comprobación por estado va a **1.33.0** como
  `instrumento` y el texto lo dice.
- **Banco: 803 → 828 casos.** Sección 36 partida en **cinco** (la mitad 1 iba por 347 líneas y el
  límite es 400): la nueva trae los cuatro casos del auditor con su control, la clave fabricada, las
  dos bocas, la frontera bajo el primer `## `, reabrir, el CRLF en tres formas, los dos informes y un
  **diferencial `lib.sh` ↔ `campos-req.awk` de 80 cabeceras con CR por enumeración fija** (no semilla).
  Fail-before **contra el árbol de la vuelta 2**, no contra 1.32.0: **9 FAIL de 19**, y los 10 que
  pasan en los dos árboles son los controles. **0 forks añadidos** (4 = 4 procesos por llamada en el
  mismo camino de decisión) y el reloj del banco dentro del ruido (93,6 s contra 92,6–95,0 s).
- **Lo que NO se hizo, con su medida:** el fuzz ancho dentro del banco que pide **SEC-028** cuesta
  **45 s** para 2 700 cabeceras (+48 % sobre el banco), así que **no entra**; entra su rebanada del CR.
  SEC-028 sigue abierto y `instrumento` para 1.33.0. Fuera del banco se midieron **2 700 cabeceras con
  semilla fija y 0 divergencias**, más tres semillas de 900 y un control contra el árbol de la vuelta 2
  —también 0—, que es lo que prueba que la guarda **observa y no cambia lo que el escáner devuelve**.

Archivos: `hooks/lib.sh`, `hooks/guard-completado.sh`, `tools/arnes-lectura.sh`,
`tools/arnes-paralelo.sh`, `skills/arnes-upgrade/SKILL.md`, `tests/escenarios/hooks/run.sh`,
`tests/escenarios/hooks/README.md`, `tests/escenarios/hooks/secciones/36-*` (cinco archivos),
`docs/qa/1.32.1.md`.

## [Interno] — 2026-09-07 · Vuelta 1 del bucle dev↔QA de 1.32.1: el fail-open del CR, y cinco casos que no medían (rama `cand/1.32.1`)
> Origen: Interno (sin commit propio; entra en el commit de la ventana) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (REQ-016 y REQ-015, `Rigor: critico`; origen: **hallazgos de QA** `docs/qa/1.32.1-hallazgos.md`, vuelta 1 de 3).

**El parche de 1.32.1 no cerraba el fail-open que existía para cerrar, y QA lo midió.** Un **retorno
de carro suelto** en mitad de una línea **fabricaba** los delimitadores del comentario: los lectores
descontaban *todos* los CR **antes** de escanear el rango, así que `-\r->` llegaba al escaneo como
`-->` y `<!\r--` como `<!--`. Consecuencias medidas: un REQ `critico` **cerraba** con su
`Seguridad: pendiente` vigente y el veredicto autorizante **dentro** del comentario (`allow` también
contra 1.32.0: por esa vía el fail-open de 1.31.0 nunca se cerró), y un rango que **nunca** cierra
parecía cerrado, tragándose el `QA: pendiente` y cerrando por *ausencia* — esto último una
**regresión nueva** del propio parche, que 1.32.0 denegaba.

- **Se arreglan TRES bocas, no una.** El texto llega al lector por tres caminos y cada uno tenía su
  propio descuento global de CR: el lector de línea (`arnes_sin_cita`), la extracción del `tool_input`
  (`arnes_jq_str`, la vía `Write`) y la reconstrucción del documento resultante (`guard-completado.sh`,
  la vía `Edit` con el CR en disco). **La tercera no la había reportado nadie**: se encontró al
  arreglar la primera y ver que el ataque seguía dando `allow`.
- **La salida es una pregunta cerrada, no un patrón que ensanchar** (quinta instancia de la misma
  lección): el descuento del CR ocurre **después** del escaneo del rango, donde ya no hay delimitador
  que fabricar. Ninguna tolerancia cambia — el CRLF legítimo decide igual que el LF, con casos en las
  dos direcciones. En `arnes_jq*` el descuento no se retira (Windows entrega `jq` en modo texto) sino
  que se **estrecha** a lo que de verdad es transporte: el CRLF que termina cada línea y el CR final
  suelto que la sustitución de comandos deja colgando. Vive en `arnes_sin_cr_transporte`, **una** vez.
- **Las dos transcripciones, alineadas por el ORDEN.** `hooks/campos-req.awk` pierde su
  `sub(/\r$/,"")` de nivel de línea y gana un `gsub(/\r/,"")` justo donde bash lo hace. De paso se
  cierra una divergencia que **nadie había reportado** y venía de antes de esta ventana: un CR dentro
  de la **clave** (`Seg\ruridad:`) lo leía bash y no el awk. Cae del lado cerrado.
- **CA-11, nuevo: comentar una declaración la RETIRA.** La conducta existía y ningún criterio la
  decía. Su caso **compara** las dos formas —línea comentada y línea borrada— en vez de fijar qué
  campos perdona la ausencia: esa lista vive en un solo sitio, y esta ventana existe por una
  transcripción duplicada. Claves derivadas del lector, 15 parejas, y la excepción medida
  (`Seguridad:` en un REQ `critico` **deniega** igual que borrada). Fail-before real: **3 FAIL de 6**
  contra 1.32.0, donde la equivalencia no se cumplía.
- **Cinco casos del banco no medían nada** (`instrumento`, no afectaba al producto): la propiedad de
  CA-02 escribía el documento en disco **ya `completado`**, así que la puerta salía sin juzgar ninguna
  transición y las **62** bases eran todas `allow` — «ningún `deny` se volvió `allow`» era cierto **por
  vacío** en las 186 variantes; la paridad de los dos lectores comparaba **vacío contra vacío** (un
  `$BASHPID` evaluado dentro de un `$( )`); el caso del hueco afirmaba lo que una lectura vacía siempre
  da; y la guarda de CA-08 pasaba sobre una función que **no existe** en 1.32.0. El tell estaba a la
  vista en los cuatro: **pasaban contra los hooks con el fail-open**.
- **La guarda que faltaba, y ahora es criterio:** una propiedad «ningún `deny` se volvió `allow`»
  **aborta** si el número de bases que deniegan es **0**. La anterior miraba el *tamaño* de la cosecha,
  no si tenía dientes.
- **El banco:** **803 casos** (era 791) y la sección 36 en **cuatro** archivos por el límite de 400
  líneas que el propio banco se impone. Y **más barato que antes**: **39,1–42,4 s** contra 44,2 s, con 12
  casos más y la propiedad midiendo de verdad — porque sólo se varían las **42** cabeceras que
  deniegan, y una base que ya permite **no puede** violar la propiedad. Fail-before por sección contra
  1.32.0: 19/28, 2/4, 3/6 y 6/17. Pass-after: **802 PASS · 0 FAIL · 1 SKIP** en **5 vueltas
  completas** sin una intermitencia, autoprueba **73 PASS**, cuadre en verde.
- **Coste, sin subir:** **5** procesos por llamada en el mismo camino de decisión (1.32.0, sin el
  parche y con él) y **6** por parada en régimen. REQ-015 comprobado y sin tocar: fail-closed 5/5, los
  cinco puntos de publicación, y la carrera determinista 7 FAIL contra 1.32.0 · 23 PASS en 5 vueltas.

Detalle de las mediciones, con las **dos retractaciones** de la vuelta 1: `docs/qa/1.32.1.md`.

## [GitHub] — 2026-09-07 · REQ-016: la cabecera tiene noción de cita — un veredicto citado dentro de un comentario HTML ya no cierra un REQ (rama `cand/1.32.1`)
> Origen: GitHub (rama `cand/1.32.1`) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (REQ-016, `Rigor: critico`, origen: **informe de regresión de un proyecto consumidor**, clase `contrato`).

**El defecto, sin eufemismo.** Un REQ **`critico`** cuyo veredicto de seguridad vigente **no**
autorizaba el cierre **cerraba** si en su cabecera había un rango `<!-- … -->` con una línea que
empezara por la clave del campo y un valor autorizante — **incluso diciendo el propio comentario que
era histórico**. Vale para cualquier campo de la cabecera por el mismo camino: el veredicto de QA, la
clase de un hallazgo bloqueante, el nivel de rigor, la sensibilidad. Llegó **bisecado** por el
reportante ejecutando cuatro guardianes instalados contra el mismo payload: **1.30.2 y 1.30.3
deniegan, 1.31.0 permite, 1.32.0 lo hereda**.

- **Tres reglas correctas por separado, y el sitio lo empeora.** La tolerancia de énfasis en la
  **clave** (nacida en 1.31.0, y que cerró un fail-open real), que estos campos toman la **última**
  aparición de la cabecera, y que el lector **no tenía noción de cita**. Juntas: cualquier línea que
  **empiece** por la clave —viva donde viva— era el veredicto vigente. Y el lugar donde un proyecto
  disciplinado escribe «este veredicto es histórico» es precisamente un comentario HTML: **quien mejor
  documentaba la historia de sus veredictos se exponía más**.
- **El arreglo es una pregunta cerrada, no más tolerancia.** `arnes_sin_cita` (nueva, en
  `hooks/lib.sh`) retira los rangos `<!-- … -->` de la línea antes de normalizar la clave, y
  `arnes_campo_linea` es **la única puerta de entrada** de un lector de cabecera, para que ningún
  recorrido pueda quedarse con la mitad de la regla — que es exactamente cómo nació el defecto. El
  hueco del rango se sustituye por **un espacio, nunca por nada**: pegar los dos extremos fabricaría
  una clave que nadie escribió. Es la cuarta instancia de una lección propia (`AGENTS.md` §13,
  `ADR-002`, SEC-020): cuando un mecanismo interpreta texto humano libre, ensanchar la tolerancia no
  gana la clase; el rango, en cambio, está **delimitado**.
- **Un rango que abre y no cierra: DENY, y nunca allow por ausencia.** Con el rango abierto la cabecera
  no se puede **medir** —no se sabe qué veredictos se quedaron dentro— y una puerta que no puede medir
  no deja pasar. Y hubo que hacer explícito el caso en que el rango se traga **la propia línea del
  estado**: si no, se resolvía como *ausencia*, y la ausencia es justo lo que la puerta perdona. La
  denegación exige que **haya un intento de cierre**: denegar toda edición de un REQ con un comentario
  mal cerrado sería friccion constante, y la fricción termina con alguien apagando el guard.
- **Lo que NO se recortó, y es un criterio (CA-04).** La tolerancia de la clave decorada sigue
  gobernando **fuera** de los rangos. Exigir la clave a columna cero y sin decorar reabría por
  construcción el fail-open que esa tolerancia cerró. Lo que faltaba no era la tolerancia: era **acotar
  dónde se aplica**.
- **Un lector, dos bocas, y se comprueba.** `hooks/campos-req.awk` recibe la transcripción declarada de
  la misma regla, y el banco alimenta el **mismo documento** a los dos lectores y compara los seis
  campos ya normalizados por la misma cola. Se arrastró `tools/arnes-paralelo.sh` al lector único: leía
  el interior de un comentario como una declaración de `Archivos:`.
- **`tools/arnes-lectura.sh` nombra la línea que gobierna, y NO es una anomalía.** El residual que
  queda tras acotar: una línea decorada **fuera** de todo rango puede gobernar, y la produce el **corte
  de un párrafo**, no su contenido. Se hace visible en su propio bloque y **sin cambiar el código de
  salida**; sólo cuando existe **otra** declaración del mismo campo y manda la decorada es anomalía con
  salida ≠ 0. Meterlo entre las anomalías repetiría el caso medido de **28 de 42 anomalías falsas
  enterrando las 14 reales**: un informe que grita por lo inofensivo deja de leerse. Y el conjunto de
  campos ya **no se enumera** en el informe: se deriva del lector de `hooks/lib.sh`.
- **La invariante se ejerce sobre el corpus, no sobre un ejemplo.** «Insertar un rango en una cabecera
  no convierte ningún `deny` en `allow`»: **58 cabeceras** cosechadas por glob del directorio de
  secciones —el sitio único del corpus, con las claves derivadas de `lib.sh`— × 3 posiciones = **174
  variantes**. Las dos fronteras que la propiedad **no** cubre están escritas y tienen su caso:
  *comentar* una línea que ya existía es **retirar** una declaración, no añadir un rango; y un `## `
  dentro de un rango sigue terminando la cabecera, así que lo de detrás no es cabecera para nadie.
- **El banco:** dos secciones nuevas (`36-…-1-la-puerta`, `36-…-2-los-lectores`; partido porque su
  propia autoprueba no admite un archivo de sección de más de 400 líneas), **43 casos**, total
  **791**. Fail-before contra el árbol heredado: **20 FAIL de 43**, y ningún caso marcado «(era
  ALLOW)» pasa. Pass-after: **790 PASS · 0 FAIL · 1 SKIP** (rutas Windows, sin `cygpath`) y
  `autoprueba-corredor.sh` **73 PASS · 0 FAIL**. Coste del lector: **5 procesos por llamada antes y
  después** (medido con los binarios instrumentados en el `PATH`, misma decisión en los dos lados).
- **Los textos que hereda un proyecto.** `skills/arnes-upgrade/SKILL.md` §`Hacia 1.32.1` dice sin
  eufemismo que **pudo cerrarse un REQ `critico` sin auditoría aprobada**, trae el comando que barre
  las cabeceras con comentario y deriva la pertenencia de versiones **del historial del lector**, no de
  una lista a mano. Y `templates/AGENTS.md.tpl` (con `AGENTS.md` §13) incorpora la regla **«la
  invariante manda sobre cualquier preferencia de herramienta»**, con su motivo medido: una preferencia
  por la consola desactivó una puerta sin que nadie relacionara las dos cosas — y **quien configura una
  sesión no suele ser quien lee §13**.

## [GitHub] — 2026-09-07 · REQ-015: la publicación concurrente ya no pisa el texto de una persona (rama `cand/1.32.1`)
> Origen: GitHub (rama `cand/1.32.1`) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (REQ-015, `Rigor: critico`, origen **H-12** / **SEC-015**).

**El defecto, y su alcance real.** `hooks/estado-derivado.sh` y `hooks/rotar-artefactos.sh` publicaban
por un temporal cuyo nombre se derivaba **sólo de la ruta del destino** —cinco sitios—, así que dos
paradas de agente simultáneas escribían **el mismo archivo**. Tras el `mv` de una, el inodo que la otra
tenía abierto con `O_TRUNC` **era ya el destino**, y su escritura tardía caía sobre él desde el byte 0:
justo donde vive lo que escribió una persona. Medido: **1 pérdida en 25** vueltas completas del banco,
**0 en 92** dirigidas — clase **`usuario/dinero`**, el único hallazgo de esa clase que ha producido
este arnés.

- **La causa medida es UNA de las cinco, y se atribuyó antes de arreglar.** La pérdida se observó en la
  sección 28-2, que corre rotación **y** derivación con cuatro paradas a la vez, así que el culpable no
  era deducible: la hipótesis del analista era que podían ser los dos. No lo eran. El
  `MANIFIESTO_BASE` del banco **no declara `rotacion`**, así que en ese caso `arnes_rotar_artefactos`
  sale en `ARNES_ROT_ACTIVO=false` **antes de tocar ningún archivo** (verificado con `bash -x`: cero
  temporales del rotador en ese escenario). La causa medida es el temporal de
  **`hooks/estado-derivado.sh`**. Los cuatro del rotador tienen la misma forma y el mismo riesgo —el
  origen que recortan puede ser un REQ o `ESTADO.md`— y entran por CA-01/CA-07, no por atribución.
- **El arreglo: el nombre del temporal es del PROCESO, no sólo del destino.** `arnes_tmp_publicacion`
  (nuevo, en `hooks/lib.sh`) forma `<destino>.arnes.tmp.<BASHPID>` **en el directorio del destino** —las
  dos condiciones de CA-01, que se verifican juntas: acreditar la ubicación sin la colisión es el error
  medido de R-003—. Sin componente única **no se cae al nombre compartido**: no se escribe nada y se
  avisa. La componente es `BASHPID` y no `mktemp` **por coste** (CA-11): una variable que el intérprete
  ya tiene, no un fork en el camino más caliente del arnés. Medido: **mismos procesos por parada** que
  1.32.0, en la parada que rota (14 externos) y en la de régimen (6).
- **El reverso, pagado: `arnes_purga_tmp`.** Un nombre único convierte un archivo que se sobrescribía a
  sí mismo en una familia de nombres, así que un temporal que sobreviva a su dueño ya no lo retira la
  parada siguiente. Se retira, y **sólo el que no tiene dueño vivo** (`kill -0`, builtin): borrar el de
  un proceso que sigue publicando sería crear el problema que este REQ cierra. También retira el nombre
  **compartido** que dejaron las versiones ≤1.32.0.
- **La reproducción es determinista, y eso era el trabajo (CA-05).** El caso que encontró el defecto
  falla **1 de 25** vueltas, y una prueba intermitente no acredita un arreglo. El punto de
  sincronización no es el reloj: es **el descriptor de archivo**. El caso hace de otra parada, abre el
  temporal compartido con `exec 9> …` (el `printf > "$tmp"` del hook partido en su apertura y su
  escritura), deja correr la parada real **entera** y sólo después completa su escritura — que con
  nombre compartido cae sobre el destino ya publicado. Tres pasos en orden fijo, sin nada que
  temporizar: **falla en todas las vueltas contra 1.32.0 y pasa en todas con el arreglo**.
- **Y el caso de ENOSPC se reescribió por el mismo motivo, sin perder el end-to-end.** Ya no se puede
  plantar el enlace a `/dev/full` en una ruta que aún no se conoce, así que el hook se lanza **con su
  stdin en una FIFO**: queda bloqueado en lo primero que hace —leer la entrada— mientras el caso planta
  el enlace usando `$!`, que es exactamente su `BASHPID`. El caso mide ahora dos cosas y ninguna por
  casualidad: la rama ENOSPC y que el temporal que el hook usa de verdad es el de su propio proceso.
- **Banco: 6 casos nuevos** en `tests/escenarios/hooks/secciones/28-rotacion-seccion-2-el-estado.sh`
  (741 → **747 PASS, 0 FAIL, 1 SKIP** explicado, cuadre por archivo y total). Los siete casos tocados
  **fallan con los hooks de 1.32.0 y pasan con éstos**, verificado con `ARNES_HOOKS_DIR`. Inventario
  contra `v1.32.0`: **seis adiciones y nada más** — ninguna línea suprimida, modificada ni cambiada de
  veredicto. El caso «CA-64.2 cuatro paradas a la vez» se conserva porque mide cuatro procesos de
  verdad, y **deja de tener causa conocida de inestabilidad abierta** (CA-06).
- **La superficie heredada, corregida en sus dos mitades (CA-08/CA-09).** `AGENTS.md` §13 y
  `templates/AGENTS.md.tpl` afirmaban **sin condición** que la continuidad «no toca nada fuera de los
  marcadores»; ahora dicen qué garantiza la máquina y qué no —no hay serialización, gana la última, y
  un proceso muerto puede dejar un temporal hasta la parada siguiente—. Y en el mismo cambio,
  `skills/arnes-upgrade/SKILL.md` deja de declarar el defecto **abierto** en «Hacia 1.24.0» y gana
  **«Hacia 1.32.1»**: que un proyecto **pudo perder texto de su `docs/ESTADO.md`** si despachó agentes
  en paralelo, cómo recuperarlo de git, y qué versiones están afectadas — la pertenencia se **deriva**
  del historial de `hooks/estado-derivado.sh` (comprobado tag a tag: **1.23.0 a 1.32.0**), con
  1.30.3/1.31.0/1.32.0 como ejemplos **no exhaustivos**.
- **`tests/escenarios/hooks/README.md`**: el total de casos decía **735** y ya eran 742 antes de este
  trabajo; queda en **748**, que es lo que declaran los cuadres.
- **Fuera de alcance, y sin tocar:** `tools/`, `.github/`, `agents/`, `.arnes/config.json`, `docs/` y
  el bump de `.claude-plugin/` (va al final de la ventana). No se añadió ningún `flock`: CA-04 no exige
  serialización y el contenido del bloque es derivado.

## [GitHub] — 2026-09-07 · v1.32.0 publicada, y el agujero del intérprete medido en carne propia
> Origen: GitHub (PR #39, fusión `ca6047a`, tag `v1.32.0`) · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos`, `desarrollador`, `qa-tester` (Opus), `auditor-seguridad` y la coordinadora.

**Publicada.** Tag `v1.32.0` sobre `ca6047a`, verificado contra los tres manifiestos, e instalación
estable actualizada de 1.31.0 a 1.32.0. `hooks-en-linux` en verde en 21 s.

- **REQ-012 y REQ-014 pasan a `completado`** con QA y Seguridad `aprobado`, cola de aprobaciones vacía
  y quality gates en verde. **REQ-013 queda en `en-revisión`** y cruza a 1.33.0 con `SEC-020` abierto
  (`contrato`): siete fail-open en tres vueltas sobre el mismo archivo dicen que la respuesta es
  **restringir la gramática** del campo, no un octavo parche. La herramienta se publica declarada como
  no fiable en los cuatro documentos que la nombran, y nada automático la consume.
- **La cola de aprobación resuelta por delegación**: el propietario aprobó publicar el 2026-09-07,
  incluido el cambio de `.github/workflows/banco.yml`, sobre el que el auditor no puso objeción de
  seguridad en R-004 y lo confirmó en R-006.
- **El agujero del intérprete, ejecutado por la coordinadora y registrado** (`docs/PENDIENTES.md`). Al
  cerrar los dos REQ escribió el estado terminal con un heredoc de `python3`: **`guard-completado` no
  lo vio**, porque el detector lee el texto del comando y la ruta vivía dentro del script. Se revirtió
  y se repitió con `Edit`, que sí pasa por la puerta y aceptó — el cierre era legítimo, lo que faltó
  fue que alguien lo comprobara. `AGENTS.md` §13 ya declaraba esa clase como el mayor hueco que queda;
  hasta hoy estaba **argumentada y no medida**. Es el forzador que le faltaba a **REQ-011, la puerta
  posterior** (1.33.0). Agravante nombrado: una instrucción de sesión que prefería `Bash` a las
  herramientas de edición acabó desactivando una puerta sin que nadie relacionara las dos cosas.
- **`docs/ESTADO.md`**: el tablero refleja el cierre, los diez hallazgos que cruzan con dueño y
  ventana, y la lección del ciclo — cuando un mecanismo interpreta texto humano libre, ensanchar el
  patrón no gana la clase. Tercera vez: detector de escrituras por `Bash`, guarda estática del banco
  (`ADR-002`) y campo `Archivos:`.

## [Interno] — 2026-09-07 · SEC-022: el documento que ANUNCIA el campo `Archivos:` prometía un fail-closed sin hueco (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (SEC-022, `instrumento`, de `auditor-seguridad` R-006; precisiones de QA-216).

**Una frase en un solo archivo. No se toca una línea de código** ni ningún otro documento:
`tools/arnes-paralelo.sh`, `hooks/`, `tests/` y `.github/` quedan idénticos.

- **`skills/arnes-upgrade/SKILL.md` §«Hacia 1.32.0» (SEC-022, `instrumento`).** La sección que un
  proyecto lee **para decidir si actualiza** anunciaba el campo `Archivos:` y
  `tools/arnes-paralelo.sh` afirmando que «el fail-closed vive en la herramienta», y **no mencionaba
  SEC-020 en ninguna parte**: una promesa más fuerte que lo que la máquina cumple, justo en el
  documento que la anuncia. Es la **tercera** vez de esta clase en este archivo (SEC-015 y SEC-016,
  una frase cada una). Ahora el fail-closed se enuncia **con su excepción**: vale para el espacio del
  campo **salvo** el marcado de Markdown **por elemento**, donde el desenvoltorio arranca el par
  exterior y la herramienta responde `disjunto` con rc 0 sobre rutas que no existen (**SEC-020**,
  *del propio arnés* —el proyecto que lee esto no tiene ese identificador en su registro—,
  `contrato`, **abierto**, ventana 1.33.0); las rutas se declaran **desnudas** y un `disjunto` sobre
  un campo decorado no se toma por bueno.
- **Enunciado por propiedad, no por lista de dos (QA-216).** El límite se escribe como «marcado de
  Markdown **por elemento**» con tres ejemplos —`` `a.sh`, `b.sh` ``, `_a.sh_, _b.sh_` y
  `**a.sh**, **b.sh**`—, porque QA midió que `**` corrompe el mapa igual que los acentos graves y el
  subrayado: una enumeración de dos habría vuelto a ser un criterio más estrecho que el fallo. Y se
  dice lo que **sí** se lee bien, para no prohibir de más: envolver la línea **entera**
  (`` `a.sh, b.sh` ``) y decorar **un solo** elemento. Lo que falla es el marcado **repetido**.

**Puertas:** `bash -n` sobre los 10 `hooks/*.sh` y `tools/*.sh` → 0 errores; `jq -e` sobre
`hooks/hooks.json`, `.claude-plugin/plugin.json` y `.claude-plugin/marketplace.json` → válidos, los
tres manifiestos en `1.32.0`; banco completo **741 PASS · 0 FAIL · 1 SKIP** (el SKIP es el de rutas
con contrabarra, que sin `cygpath` sólo corre en Windows), `rc=0` y los dos cuadres —por archivo y
total— silenciosos.

## [Interno] — 2026-09-06 · La pata de herencia de SEC-014: el documento que heredan los proyectos describía una máquina que no existe, y el límite de SEC-020 escrito donde se escribe el campo (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (remediación **documental** de la pata 3 de SEC-014 y declaración del residual de SEC-020, hallazgos de `auditor-seguridad` §«Re-verificación de R-004»).

**Sólo documentación heredada. No se toca una línea de código:** `tools/arnes-paralelo.sh`,
`hooks/`, `tests/` y `.github/` quedan idénticos. Lo que se corrige es que el documento que gobierna
cómo se escribe el campo `Archivos:` —y que **heredan todos los proyectos** por `arnes-upgrade`—
afirmaba lo contrario de lo que la máquina hace.

- **`requirements/README.md` y `templates/requirements-README.md.tpl`: el párrafo invertido (SEC-014,
  pata 3, `contrato`).** Decía que «anotar elemento por elemento —`tools/x.sh (nuevo), hooks/lib.sh
  (modificado)`— **no es una forma admitida**» y que el REQ pasaba a `sin declarar`. Es **falso**:
  esa línea exacta es el primer caso del arreglo de SEC-014, la herramienta la **lee** y responde
  `colisiona` con el mapa completo, verificado en las cuatro posiciones del paréntesis. El párrafo
  describía la **variante propuesta** al despachar la comisión —«la regla vale sólo tras el último
  separador»— y que no se implementó, porque contradice la verificación **por conteo** que CA-03
  exige. Ahora dice lo construido: el paréntesis acompaña a **su** elemento, en cualquier posición;
  la coma **dentro** de un paréntesis **no separa** —con su reverso escrito: lo que va dentro no
  declara nada—; y lo que no se entiende sale `SIN DECLARAR` **con su motivo** y colisiona con todos,
  **nunca** `disjunto`. La dirección del error era la segura (el documento era más estrecho que el
  código, no más ancho), pero el riesgo real no era un falso `disjunto`: era que alguien «arreglara»
  el código para que cuadrara con la nota y **regresara SEC-014 entero**.
- **El límite que faltaba, dicho donde se escribe el campo (SEC-020, `contrato`, ABIERTO).** Párrafo
  nuevo: el marcado de Markdown **por elemento** —`` `a.sh`, `b.sh` `` o `_a.sh_, _b.sh_`— **no es
  fiable**, porque el desenvoltorio arranca el par **exterior**, que pertenece a dos elementos
  distintos, y la herramienta responde `disjunto`/rc 0 sobre un mapa de rutas que no existen. Se
  escribe como **recomendación operativa con su causa** —las rutas van **sin decoración**—, no como
  promesa de la máquina; envolver la línea **entera** sigue funcionando y por eso la tolerancia
  anterior se mantiene enunciada igual.
- **`AGENTS.md` y `templates/AGENTS.md.tpl`: `disjunto` es necesario y no suficiente.** La
  instrucción «sólo se despacha en paralelo sobre REQ que `tools/arnes-paralelo.sh` declare
  disjuntos» **no se retira** —sigue siendo obligatoria y sigue siendo la buena—: se **acota**.
  Mientras SEC-020 esté abierto, un `disjunto` sobre un campo **decorado** no autoriza nada; se
  limpia el campo y se vuelve a preguntar. Mandar confiar sin reservas en una herramienta con un
  fail-open abierto es la misma clase de afirmación más ancha que lo construido que `ADR-002`
  prohíbe.
- **`requirements/REQ-013.md`:** una fila de Historial con el antes → después de los dos textos y su
  causa. **Ninguna cabecera de REQ se toca**: SEC-020 sigue declarado abierto y cruza la ventana con
  el REQ, por decisión de la coordinadora —siete fail-open en tres vueltas sobre el mismo archivo
  dicen que el problema no son los siete casos, sino que el campo tolera **decoración libre**; la
  respuesta de fondo es **restringir la gramática** del campo, que es un cambio de contrato y va a
  1.33.0—.

**Espejo verificado:** el `diff` entre `requirements/README.md` y
`templates/requirements-README.md.tpl` sigue mostrando exactamente los mismos **tres** hunks que
antes del cambio (el título, el párrafo de adopción propio de este repositorio y el índice de REQ);
la sección del campo `Archivos:` queda **idéntica** en los dos archivos.

**Puertas:** `bash -n` sobre los 10 `hooks/*.sh` y `tools/*.sh` → 0 errores; `jq -e` sobre
`hooks/hooks.json`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` y
`.arnes/config.json` → válidos, los tres manifiestos en `1.32.0`; banco completo **741 PASS · 0
FAIL · 1 SKIP** (742 casos; el SKIP es el de rutas con contrabarra, que sin `cygpath` sólo corre en
Windows), `rc=0` y los dos cuadres —por archivo y total— silenciosos.

## [Interno] — 2026-09-06 · bump de versión a 1.32.0 en los tres manifiestos (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador`.

Cambio mecánico de tres valores, previo a la fusión y al tag `v1.32.0`. No toca comportamiento:
sube la versión declarada de `1.31.0` a `1.32.0` en `.claude-plugin/plugin.json`,
`.claude-plugin/marketplace.json` (metadata y entrada del plugin) y `arnes_version` de
`.arnes/config.json`. Los tres viven dentro de `codigo_app.globs` de este repositorio —el
manifiesto es la fuente de verdad ejecutable de las invariantes—, así que el bump es trabajo del
`desarrollador` y no de la coordinadora: coste aceptado y ya anotado en el propio manifiesto.

Con esto desaparece el desajuste que el bloque derivado de la parada venía señalando entre la
versión instalada del plugin y la del árbol candidato.

**Puertas:** `jq -e` sobre los tres manifiestos y sobre `hooks/hooks.json` → válidos; las dos
versiones de `.claude-plugin/` coinciden entre sí y con `arnes_version` (`1.32.0`); `bash -n` sobre
los 10 `hooks/*.sh` y `tools/*.sh` → 0 errores; banco completo **741 PASS · 0 FAIL · 1 SKIP** (el
SKIP es el caso de rutas con contrabarra, que sin `cygpath` sólo corre en Windows) con los dos
cuadres —por archivo y total— silenciosos y `rc=0`.

## [Interno] — 2026-09-06 · Auditoría R-004 de 1.32.0: el sexto fail-open (un paréntesis intermedio borraba medio mapa), la promesa de concurrencia que estaba medida falsa y dos frases que prometían de más (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (remediación de los hallazgos de `auditor-seguridad` §R-004).

**La forma del hallazgo, que es lo que se arregla:** una regla escrita para un **valor único**
aplicada a un campo de **lista**, y dos frases de documentación más anchas que la máquina que las
respalda. Lo primero borraba la mitad del mapa **en silencio** y respondía «adelante»; lo segundo le
promete a quien actualiza el arnés una garantía que está **medida falsa** — y en la versión que
existe justamente para despachar comisiones en paralelo, que es el escenario que dispara el fallo.

- **`tools/arnes-paralelo.sh`: el sexto fail-open, y el peor (SEC-014, `contrato`).** `Archivos:` es
  una **lista** y se le aplicaba la regla del paréntesis de un **veredicto**: si el valor acaba en
  `)`, corta en el **primer** `(`. Resultado medido: `tools/x.sh (nuevo), hooks/lib.sh (modificado)`
  se quedaba en `tools/x.sh`, todo lo demás desaparecía **antes** de validarse —sin motivo, sin bajar
  el recuento, sin cambiar el código de salida— y la herramienta contestaba `disjunto`/**rc 0** sobre
  un mapa que ella misma había truncado. **La asimetría iba hacia el lado que abre:** anotar *todos*
  los elementos —lo prolijo, y lo que la plantilla enseñaba— abría el mapa; dejar el último desnudo lo
  cerraba. Ahora la lista **se separa primero** —y el separador es la coma que **no** está dentro de
  un paréntesis, porque la evidencia lleva comas— y la **misma** función compartida se aplica **a cada
  elemento**: los dos archivos llegan al mapa y el par sale `colisiona`/rc 1 en **las dos
  direcciones**. Lo que no es un elemento tampoco se traga en silencio: una anotación suelta entre
  comas, o un paréntesis sin cerrar, salen `SIN DECLARAR` **con su motivo**.
- **La tolerancia deja de enseñarse sin su límite.** `requirements/README.md` y
  `templates/requirements-README.md.tpl` dicen ahora dónde vale el paréntesis de evidencia —acompaña
  a **un elemento**, entre paréntesis balanceados— y qué pasa con lo que no se entiende: se dice y
  colisiona. Una tolerancia enseñada sin su límite es una invitación a escribir la forma que abría.
- **`--json` podía emitir JSON inválido (SEC-018, `instrumento`).** El escape cubría `\` y `"` y no
  los caracteres de **control**: un tabulador en el motivo —o un tabulador vertical dentro de una
  ruta, que no es `[:blank:]` y por tanto pasa el filtro— producía una salida que `jq` **rechaza**, y
  en el segundo caso con **rc 0**. El modo JSON es justo el que consume una máquina. Se escapan, sólo
  cuando los hay y sin un proceso más.
- **`skills/arnes-upgrade`: la promesa de no-corrupción concurrente, corregida antes de publicar
  (SEC-015, `contrato`).** La nota le decía al usuario que las reescrituras concurrentes de
  `docs/ESTADO.md` son «idempotentes, no se corrompen». Está **medido falso**: el bloque derivado
  publica por un temporal de **nombre fijo** y QA perdió el texto **humano** del archivo **1 vez de
  25**. Ahora la nota separa lo que sí garantiza —bloque derivado, recalculado entero, sólo entre sus
  marcadores— de lo que **no**: dos paradas simultáneas no están serializadas, con el consejo
  (versionar el archivo o apagar el bloque mientras dure el paralelo) y el arreglo anunciado para
  **1.32.1**. El defecto vive en `hooks/` desde 1.30.3 y **no** se toca aquí: esta versión sube la
  **frecuencia** del escenario, así que lo que no puede viajar es la frase.
- **Y el «límite honesto» de la guarda estática llega a la superficie que leen los terceros
  (SEC-016, `instrumento`).** `ADR-002` estrechó la invariante 1 y el README del banco lo dice; la
  nota de `arnes-upgrade` —lo único de esto que un proyecto lee— la seguía enunciando en su forma
  ancha y prometía «las tres invariantes intactas». Ahora dice que la comprobación es **estática y
  sobre funciones**, que un juez por indirección se le escapa, y que es una **barandilla, no una
  jaula**.
- **Banco:** `secciones/35-arnes-paralelo-fail-open.sh` pasa de **19** a **26** casos (**742** en
  total). Los cinco nuevos fallan contra la herramienta auditada y los **dos controles** pasan antes y
  después; la simetría se prueba con `sim_check`, en los dos órdenes, por propiedad.
- **Quedan abiertos y con ventana ajena:** **SEC-017** (precedencia de un `Estado:` duplicado, 1.33.0)
  y **SEC-019** (los 54 casos que pasan con su hook a `exit 0`, 1.35.0).

**Puertas:** `bash -n` sobre los 10 `hooks/*.sh` y `tools/*.sh` y sobre los 40 archivos del banco (3 puntos de entrada + 37 secciones);
`jq -e` sobre `hooks/hooks.json`, `plugin.json` y `marketplace.json`; banco completo **741 PASS · 0
FAIL · 1 SKIP** —el SKIP es el caso de rutas con contrabarra, que sin `cygpath` sólo corre en
Windows— con cuadre por archivo y total; autoprueba del corredor **73 PASS · 0
FAIL**; `git diff v1.31.0 -- hooks/` **vacío**; `tools/arnes-paralelo.sh` sobre este repositorio no
declara `sin declarar` ningún REQ y deja el árbol idéntico.

## [Interno] — 2026-09-06 · Vuelta 3 (la última) del bucle dev↔QA de 1.32.0: los dos fail-open que quedaban, el puntero que mentía y la prueba escrita en una sola dirección (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (arreglo de los hallazgos de código de la vuelta 2).

**La forma del hallazgo, que es lo que se arregla:** un arreglo que funciona en un orden y falla en
el contrario, y una prueba escrita **sólo en el orden que pasa**. La vuelta 1 encontró el choque del
archivo que aún no existe contra el glob ajeno y lo perdía después, al construir la clave del par
suponiendo un orden de descubrimiento que la propia pasada de futuros rompe; y los dos casos que lo
vigilaban ejercitaban la mitad que ya funcionaba. Un guardián que prueba una sola dirección de una
relación simétrica acredita lo que ya andaba — es la cuarta vez en este ciclo.

- **`tools/arnes-paralelo.sh`, los dos fail-open de clase `contrato` (QA-202, QA-211).** La clave del
  par **se ordena al escribirla**: el par {a,b} es el mismo par se mire por donde se mire, y el
  archivo futuro colisiona con el glob y con su directorio **en las cuatro direcciones medidas**
  (antes: `colisiona`/rc 1 en una, `disjunto`/rc 0 en la contraria). Y un REQ del que no se extrae
  `Estado:` de la cabecera —campos debajo del primer `## `, sin `Estado:`, o archivo de 0 bytes—
  deja de caerse del análisis con un `continue` **mudo** en el modo sin argumentos: pasa por el sitio
  único que el criterio declara, se declara `SIN DECLARAR` con su motivo, colisiona con todos, sale
  ≠ 0 y **el recuento no baja en silencio**. La herramienta se contradecía consigo misma: el mismo
  archivo, pasado como argumento explícito, sí se evaluaba.
- **Y el residuo `instrumento` de la misma clase (QA-212).** La lista cerrada de marcadores de
  posición deja de ser la red: la red es la **propiedad** —un elemento que no existe, del que ningún
  ancestro existe y que no tiene forma de archivo no designa nada—, así que `n/d`, `s/d`, `n.a.`,
  `t.b.d.` y `pendiente.` caen sin alargar ninguna lista. La lista sobrevive sólo para dar un mensaje
  mejor, y por eso ahora sí es de verdad no exhaustiva.
- **El puntero de la invariante 1 deja de mentir, y la máquina lo vigila (H-01).** El README del banco
  enumeraba **seis** ayudantes «que ejecutan un hook» con la palabra **todos** delante —era falso:
  `corre`, `ver_corre` y `mide_hook` no estaban— y declaraba un sitio único distinto del que declaraba
  el criterio. Ahora el conjunto **no se enumera en ninguna parte**: se enuncia la propiedad («todo el
  que el corredor define al nivel superior antes del despacho»), se da la línea de `awk` que lo deriva,
  y la invariante dice **qué** obliga —dictar PASS/FAIL, no ejecutar— en vez de a quién. Tres casos
  nuevos impiden la reincidencia: ningún ayudante fantasma, **ninguna línea que reenumere** el
  conjunto, y la afirmación normativa comprobada sobre el corredor.
- **Dos agujeros de diagnóstico del corredor (`instrumento`, H-10, H-11).** `diag` garantiza el salto
  de línea final —con `sed`, un stderr sin `\n` pegaba la línea del caso siguiente y el cuadre perdía
  un caso acusando al número declarado—; el arreglo estaba hecho en dos secciones y no había llegado
  al ayudante compartido, que es donde vale para las 37. Y «guarda equivalente» deja de ser una lista
  de tres literales atada al nombre de una variable, que producía **ABORT sobre código correcto**:
  pasa a propiedad, con la distinción de mayúsculas **medida** y no estética (`[ -n "$FILTRO" ]` está
  en 31 ayudantes de sección y no es una guarda).
- **El arreglo del método, no del caso: `sim_check`.** La simetría se prueba **por propiedad** — el
  ayudante corre el par en los dos órdenes y exige que coincidan en veredicto y código de salida —,
  así que un caso nuevo cubre las dos direcciones sin que nadie tenga que acordarse. Revisión del
  resto: los **20** pares de las secciones 34 y 35, medidos en las dos direcciones, dan **0
  asimétricos** con la herramienta de esta vuelta y **2** con la anterior (exactamente los dos de
  futuros), lo que sitúa la dependencia del orden en el único camino que la tenía.
- **Pruebas, con fail-before medido en las dos direcciones.** Sección 35: **10 → 19** casos; contra la
  herramienta anterior fallan los **6** que acreditan arreglo y pasan los **3** controles positivos.
  Autoprueba: **64 → 73**; contra el corredor anterior fallan los de H-10 y H-11, y contra el README
  anterior el de la reenumeración (`linea 62 con 6 ayudantes`). Banco: **726 → 735** casos,
  `734 PASS, 0 FAIL, 1 SKIP`, cuadre por archivo y total en **735**. Inventario contra v1.31.0: **0**
  líneas suprimidas o modificadas, 52 añadidas, **todas** de las dos secciones de `arnes-paralelo`.
  `git diff v1.31.0 -- hooks/` **vacío** y `git status --short -- hooks/` sin entradas: el mecanismo
  sigue byte a byte el publicado.
- **Lo que NO se ha tocado, y por qué.** **H-03** (la evasión de la guarda estática con tres eslabones)
  cierra con **residual declarado**: ensanchar el reconocedor cubre formas, nunca la clase, igual que
  el detector de escrituras por `Bash`. **H-12** (la carrera del temporal de nombre fijo en
  `hooks/estado-derivado.sh`) es **preexistente**, vive en `hooks/` —que CA-22 prohíbe tocar aquí— y
  su decisión está con el propietario. **QA-205** (`~`, enlaces simbólicos, mayúsculas) sigue en deuda
  con dueño: ninguno cambia hoy el veredicto de ningún REQ real.

## [Interno] — 2026-09-06 · Vuelta 1 del bucle dev↔QA de 1.32.0: los cuatro fail-open de `arnes-paralelo` y la guarda del corredor que se evadía (rama `cand/1.32.0`, sin commit)
> Origen: Interno (árbol de `cand/1.32.0` sin comitear) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (arreglo de los hallazgos de código de la vuelta 1).

**La forma del hallazgo, que es lo que se arregla:** las dos herramientas nuevas de esta candidata
respondían **verde cuando no podían saberlo**. `tools/arnes-paralelo.sh` decía `disjunto` con rc 0
ante un REQ que no podía leer, ante un marcador de posición y ante el archivo que aún no existe; y
la guarda estática del corredor —la que impide que una sección dicte PASS/FAIL sobre un hook sin
guarda— se rodeaba escribiendo **dos funciones en vez de una**. Un control que se evade sin ocultar
nada no es un control.

- **`tools/arnes-paralelo.sh`, cuatro fail-open (`contrato`, QA-201 a QA-204).** Un REQ que no se
  puede leer entero —sin permiso o truncado por un byte NUL— **se declara y contamina el veredicto**
  en vez de desaparecer del análisis; el archivo que **todavía no existe** colisiona con el glob que
  lo alcanzará y con el directorio que lo contendrá; un **marcador de posición** (`TBD`, `todo`,
  `n/a`, `-`, `?`) deja de leerse como ruta futura, juzgado por propiedad y no por lista; y
  `Archivos:` duplicado resuelve con **el último**, igual que `arnes_campos_req`. De propina y de la
  misma clase: `--json` declaraba los archivos que un patrón casa hoy donde el texto declara el
  patrón, porque la cadena se partía sin desactivar el globbing.
- **La guarda estática del corredor sigue ahora la cadena de llamadas (`contrato`, H-03).** Las
  propiedades «ejecuta un hook» y «lleva guarda» se propagan por las llamadas dentro del archivo
  hasta punto fijo: da igual en cuántos trozos se parta el ayudante. Ningún ayudante del banco real
  queda señalado, así que **no se toca ninguna sección**.
- **Y tres agujeros de diagnóstico del propio banco (`instrumento`, H-04/H-05/H-06).** Nada en
  `secciones/` se queda fuera en silencio: un archivo que no casa `NN-<slug>.sh`, o un directorio que
  sí lo casa, **abortan nombrándose** en vez de ignorarse o de matar el cuadre con un `unbound
  variable`. Y `autoprueba-corredor.sh` —el único artefacto de la cadena sin la red que exige a todos
  los demás— declara su `AUTOPRUEBA_CASOS_ESPERADOS` y **se aplica el cuadre a sí misma**.
- **Pruebas, con fail-before medido.** 10 casos nuevos en
  `tests/escenarios/hooks/secciones/35-arnes-paralelo-fail-open.sh` (9 fallan contra la herramienta
  anterior; el décimo es el control positivo) y 13 en `autoprueba-corredor.sh` (9 fallan contra el
  corredor anterior). Banco: **716 → 726** casos, `725 PASS, 0 FAIL, 1 SKIP`; autoprueba: **51 → 64**,
  `0 FAIL`. La sección 34 se parte porque llegaba a 444 líneas y CA-18 fija el techo en 400.
- **El instrumento de verificación deja de ser ciego (H-08).** Con **todo indexado** (`git add -A`,
  sin commit), `git diff v1.31.0 -- hooks/` sigue **vacío** —el mecanismo no se ha tocado— y el paso
  de modos del CI, replicado literal, da **0 archivos malos**: puntos de entrada `100755` y secciones
  `100644`. Antes el control «pasaba» porque `git diff` no ve lo que no está rastreado.

## [GitHub] — 2026-09-06 · REQ-013: un mapa de archivos por REQ, para poder despachar dos comisiones a la vez (rama `cand/1.32.0`)
> Origen: GitHub (rama `cand/1.32.0`) · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos` (redacción del REQ) y `desarrollador` (esta implementación).

**La forma del hallazgo, que es el motivo del cambio:** el ciclo corrió **en serie** —tiempo de reloj
prácticamente igual a la suma del tiempo de agente, 0 comisiones solapadas en 25— y no porque una
regla lo prohibiera, sino porque **nadie podía decir por máquina qué dos comisiones no colisionan**.
Adivinar bien tres veces y mal la cuarta cuesta más que toda la serie que se ahorró.

- **La cabecera del REQ gana el campo `Archivos:`**: rutas o globs relativos a la raíz, separados por
  comas, o el literal `(ninguno)`. Documentado por **propiedad** —no por lista de globs válidos— en
  `requirements/README.md` y en `templates/requirements-README.md.tpl`, con su plantilla y su lugar en
  la Definition of Ready.
- **`tools/arnes-paralelo.sh` (nuevo, `100755`)** responde `disjunto` o `colisiona` **nombrando el
  archivo compartido**, para cada par de REQ, en texto o en `--json`. La intersección se resuelve
  **expandiendo los globs contra el árbol real**, no comparando cadenas: comparar cadenas declararía
  disjuntos `hooks/lib.sh` y `hooks/*.sh`, que es justo la forma de error que produce un conflicto de
  fusión. Un patrón que aún no casa con nada se conserva como ruta literal, porque un archivo que
  todavía no existe es exactamente donde dos comisiones chocan.
- **Una regla, un lector — y la regla es la normalización, no el mapeo.** El campo se lee con la
  normalización de `hooks/lib.sh` (recorte de la cabecera antes del primer `## `, clave decorada,
  desenvoltorio del marcado, paréntesis de evidencia). No hay ni un `grep '^Archivos:'` ni un
  `awk`/`sed` que reimplemente nada de eso. Y **`Archivos:` no entra en la lista de campos que leen
  las puertas**: un campo que no gobierna nada no vive en el lector que sí gobierna. **El diff de
  `hooks/` para este cambio es vacío**, y ésa es la comprobación.
- **No es una novena puerta, y es deliberado.** `guard-completado` y `guard-codigo` dan **exactamente**
  los mismos veredictos que en v1.31.0: un REQ sin el campo, o con el campo ilegible, cierra igual que
  siempre. El fail-closed vive en la **herramienta** —sin mapa no hay paralelismo, y colisiona con
  todos—, donde el coste de equivocarse es volver a la serie.
- **Y lo que la herramienta no responde, escrito en su propia salida:** evalúa **archivos**, nunca el
  **orden de fases**. `AGENTS.md` §6 y `templates/AGENTS.md.tpl` ganan la regla de despacho y las tres
  exclusiones **con su motivo**; las dos primeras —el auditor nunca antes ni a la vez que QA, QA nunca
  antes que el desarrollador— no se relajan en ningún caso. Sin esa línea, un `disjunto` se leería
  como permiso para producir una firma falsa.
- **El cuello, medido y no supuesto** (`docs/qa/1.32.0.md`): sobre el árbol de v1.31.0 colisionan
  **15 de 15** pares, y el archivo que los colisiona **todos** resultó ser
  `skills/arnes-upgrade/SKILL.md` (15/15), con `tests/escenarios/hooks/run.sh` en 10/15 y
  `hooks/lib.sh` en **1/15**. Se suponía que el cuello eran los dos monolitos: partir `hooks/lib.sh`
  no habría desbloqueado ni un par de este ciclo. Sin el número, la palanca siguiente se elige mal.
- **Coste, medido con los binarios instrumentados en el `PATH`:** 60 REQ y 200 archivos declarados en
  **127–245 ms** (techo 2 000 ms) y **1 proceso externo en total** —el `jq` del manifiesto— frente al
  techo de 2 por REQ leído. La herramienta **no** está registrada en `hooks.json`: añade **0 procesos**
  a la ruta de `Bash`, `Edit`, `Write` y la parada. El despacho ocurre una vez por ciclo, no una vez
  por comando.
- **Banco:** `tests/escenarios/hooks/secciones/34-arnes-paralelo.sh` (nuevo, **33** casos; total
  683 → **716**). Inventario ordenado antes y después: las **33** líneas nuevas y nada más — ningún
  caso cambió de veredicto y **ninguno** pasó de `deny` a `allow`. Contra los hooks de v1.31.0 la
  sección da **30 FAIL / 3 PASS**; los tres que pasan en las dos son los controles que deben pasar en
  ambas.
- **Cierre de una medición pendiente ajena:** CA-16 de REQ-014 quedó sin medir porque esta herramienta
  no existía. Medida ahora y anotada en su Historial y en `docs/qa/1.32.0.md`: dos comisiones de QA
  sobre secciones distintas dan `disjunto` en la candidata y `colisiona` por
  `tests/escenarios/hooks/run.sh` en v1.31.0.

## [GitHub] — 2026-09-06 · REQ-014: el banco en archivos por sección (rama `cand/1.32.0`)
> Origen: GitHub (rama `cand/1.32.0`) · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos` (redacción del REQ) y `desarrollador` (esta implementación).

**La forma del hallazgo, que es el motivo del cambio:** el banco —el artefacto por el que pasa toda la
validación del arnés— era **un solo archivo de 4.096 líneas con 33 secciones y 683 casos**. Dos
comisiones de QA no podían despacharse a la vez porque las dos habrían escrito en el mismo archivo
(en el ciclo 2 hubo **una** comisión para siete requerimientos), y cualquier comisión que tocara
cuarenta líneas tenía que leerlas todas. Un banco monolítico no es un problema de estilo: es un
cuello por el que pasa el 100 % de la validación y que sólo deja pasar a uno.

- `tests/escenarios/hooks/run.sh` pasa de banco a **corredor** (4.096 → 607 líneas): ayudantes
  compartidos, canario global, descubrimiento y los cuadres. Los casos viven ahora en
  `tests/escenarios/hooks/secciones/NN-<slug>.sh`, **35 archivos**, ninguno de más de 342 líneas.
- **Se descubren con un glob de bash**, en orden lexicográfico fijado con `LC_ALL=C` sólo durante la
  expansión y **sin arrancar `find`, `ls` ni `sort`**: el descubrimiento corre en cada vuelta y en
  Windows cada fork cuesta entre 1,2 y 6 s. Añadir o quitar una sección no toca ni una línea del
  corredor.
- **El cuadre gana el sujeto que le faltaba.** Cada archivo declara su `CASOS_ESPERADOS_SECCION` y el
  corredor exige las dos cosas: que cada sección cuadre con **su** número —el ABORT dice **cuál**
  archivo y cuántos casos de diferencia— y que la suma cuadre con `CASOS_ESPERADOS` (683, sin cambio).
  Un archivo sin su número declarado aborta con su nombre.
- **Canario de sección:** una sección que muere a mitad deja de ser indistinguible de una que pasó
  limpia. El subshell deja una marca al terminar el archivo; sin ella, ABORT con el nombre del archivo
  y su código de salida, y la vuelta sale ≠ 0.
- **Invariante 1 comprobada sobre el texto:** una función propia de una sección que ejecute un hook y
  dicte PASS/FAIL sin guarda contra la salida vacía aborta la vuelta antes de ejecutar nada, nombrando
  archivo y función. Delató a `tipo33`, cuyos casos de control esperaban silencio en `stderr` y
  habrían pasado en falso con el emisor mudo; se le puso la guarda.
- **Corrida parcial:** `run.sh secciones/07-*.sh` corre esa sección más el canario, suspende el cuadre
  total **diciéndolo** y sigue exigiendo el de la sección. Un selector que no casa con nada aborta en
  vez de degradar a filtro. El filtro por nombre de caso conserva su semántica de v1.31.0.
- `tests/escenarios/hooks/autoprueba-corredor.sh` (nuevo, 51 casos): certifica al corredor contra
  directorios de secciones sintéticos. Sus casos **no** entran en el inventario de 683, precisamente
  para que ese inventario se pueda comparar con el de la versión publicada anterior. Contra el
  corredor de v1.31.0 fallan 30 de ellos: sin ese par, los casos nuevos no prueban nada.
- `tests/escenarios/hooks/inventario.sh` (nuevo): inventario ordenado `veredicto · caso`, con los
  milisegundos normalizados. **El criterio central de este cambio no fue «el banco pasa»** —dos casos
  que intercambian PASS y FAIL dan el mismo total— sino el inventario **byte a byte idéntico** al de
  v1.31.0: 683 líneas, `diff` vacío, con tres corridas antes y tres después idénticas entre sí.
- `.github/workflows/banco.yml`: `bash -n` sobre `hooks/`, `tools/` y **todas** las secciones; el bit
  de ejecución comprobado en sus dos mitades (puntos de entrada `100755`, secciones `100644`, porque se
  hacen `source` y sueltas correrían cero casos en verde); y un paso nuevo para la autoprueba. El banco
  sigue corriéndose por el **mismo** punto de entrada que en local, nunca por una lista escrita en YAML.
- `tests/escenarios/hooks/README.md`: las tres invariantes actualizadas a la estructura nueva más una
  cuarta (una sección que muere se distingue de una que pasó limpia), cómo se añade una sección en tres
  líneas y por qué los modos de archivo son los que son.
- **Ni una línea de máquina:** `git diff v1.31.0 -- hooks/ tools/` **vacío**. Este cambio reorganiza
  **quien mide**, no lo medido — y si hubiera tocado un hook, la comparación del inventario no valdría
  nada.

## [GitHub] — 2026-09-06 · REQ-012: criterios por mecanismo, no por enumeración (rama `cand/1.32.0`)
> Origen: GitHub (rama `cand/1.32.0`) · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos` (redacción del REQ) y `desarrollador` (esta implementación).

**La forma del hallazgo, que es el motivo del cambio:** de los **20** hallazgos del ciclo 2, **7** no
fueron código defectuoso — fueron **criterios que decían algo falso sobre lo construido** (clase
`contrato`), y **uno** costó una vuelta entera del bucle (~50 min entre desarrollador, QA, control y
write-back). Las tres formas medidas: **enumerar** lo que el código reconoce (un criterio listaba tres
envoltorios de shell cuando el código toleraba siete), **fijar un número** que la medición desmiente
después (un máximo de 262 144 bytes que hubo que bajar a 131 072), y **exigir igualdad** donde
corresponde un techo («el mismo número de procesos que la versión anterior» declaró incumplida una
mejora de 1 fork a 0). No se arregla con más máquina: se arregla escribiendo la regla en vez de la lista.

- `requirements/README.md` (y su espejo `templates/requirements-README.md.tpl`): sección nueva
  **«Cómo se escribe un criterio que no se desmiente»** — las tres formas con su caso medido, la forma
  **mal** y la forma **bien**; la propiedad de pertenencia con puntero al sitio único y la marca
  `no exhaustivo`; el número declarado **operativo** o **de contrato** (y `de contrato` como
  fail-closed si no se declara); el coste como **techo con dirección admitida**; la corrección del
  criterio más estrecho que lo construido **y su reverso**, para que no se use como coartada para
  relajar criterios incómodos.
- `agents/analista-requerimientos.md`: tres casillas verificables nuevas en la **Definition of Ready** y
  un puntero a la sección, sin transcribir la regla por segunda vez.
- `agents/qa-tester.md`: un criterio mal formado es hallazgo de clase **`contrato`** contra el REQ
  **antes** de ejecutar la prueba, con su **forma** anotada en `docs/qa/<versión>.md`; el QA **no**
  reescribe el criterio.
- `agents/auditor-seguridad.md`: un control se describe **por propiedad, nunca por enumeración** —una
  lista de controles envejece hacia el lado que **abre**.
- `templates/AGENTS.md.tpl` §9: punto nuevo «criterio más estrecho que lo construido», que apunta a la
  sección y no la duplica.
- `skills/arnes-upgrade/SKILL.md`: sección `### Hacia 1.32.0` — qué llega, y que **no hay nada que
  migrar**: los REQ ya cerrados no se reabren ni se reescriben.
- `docs/qa/1.32.0.md` (nuevo): sección **«Coste del ciclo»** con la línea base del ciclo 2 escrita
  **antes** de medir nada, una única regla de conteo y el objetivo declarado como techo (hallazgos
  `contrato` de esas formas: no más de 3, línea base 7; vueltas del bucle causadas por ellos: 0, línea
  base 1), más el control anti-juego que impide bajar la métrica borrando criterios.
- **Ni una línea de máquina:** `git diff v1.31.0 -- hooks/ tools/` **vacío**; ningún campo nuevo en la
  cabecera del REQ, ninguna llave nueva en `.arnes/config.json` y ningún proceso añadido a ninguna ruta.
  La **forma** del hallazgo se anota sólo en el log de QA y nunca en el paréntesis de la clase, que es
  la entrada de `guard-completado`.

## [Interno] — 2026-09-06 · migración del andamiaje de este repositorio: 1.30.3 → 1.31.0
> Origen: Interno (migración de andamiaje, sin commit de versión) · usuario: Juan · modelo de IA: Opus 5 · agente: `desarrollador` (la parte del manifiesto) sobre el plan de `/arnes-upgrade` de la sesión coordinadora.

`arnes-upgrade` llevó este repositorio del andamiaje 1.30.3 al de 1.31.0. Plan y acreditación del
origen en `.arnes/migracion.md` (las 11 plantillas de `.arnes/plantillas-origen/` idénticas a
`v1.30.3:templates/`, sin `UNKNOWN` ni `CONFLICTO`).

- `AGENTS.md` §13 y `requirements/README.md`: cinco añadidos cada uno (coordinadora, ya aplicados).
  `PENDING_APPROVAL.md` ya traía su sección desde REQ-009.
- `.arnes/config.json`: bloques `veredictos` y `git` nuevos, y `rotacion._doc_artefactos` actualizado
  al texto de 1.31.0 (documenta la forma de sección: `glob` + `seccion`). Se copió el texto y el `_doc`
  de `templates/arnes-config.json.tpl` sin adaptaciones: los tres son idénticos a la plantilla.
- `.arnes/config.json`: `arnes_version` a `1.31.0` (Fase 5, al final y sólo tras verificar lo anterior;
  subirla antes haría creer a la ejecución siguiente que la migración está hecha).
- **Lo hizo el agente de código, no la coordinadora.** Desde 1.31.0 `.arnes/config.json` está dentro de
  `codigo_app.globs` de este repositorio (SEC-006 parte a, REQ-007 CA-53), así que la coordinadora ya no
  puede escribirlo. Es la consecuencia aceptada de esa decisión, y la Fase 5 va con ella.

**Lo que se dejó apagado a propósito, y por qué:**

- `veredictos.exigir_fecha` y `veredictos.caducan_con_codigo` en `false`. Los veredictos de este
  repositorio sí llevan fecha, pero encenderlas es una decisión de política: se toma en su propia
  ventana y con la medición delante, no dentro de una migración de andamiaje.
- `rotacion.activo` sigue en `false`. La rotación de la historia de un REQ no reconoce filas de tabla
  —medido: 0 entradas y 94 filas en los REQ de este repositorio—, así que encenderla hoy no rotaría
  nada. Queda en `docs/PENDIENTES.md` para 1.32.0 con su alcance.
- `limites` **no se declara**. Su propio `_doc` dice que es opcional, que el valor por defecto vive en
  el código y que se borre si no hace falta; ningún comando legítimo ha topado con el techo aquí.

**Lo único que nace encendido:** `git.activo: true` con la lista por defecto de la plantilla
(`clean -f`, `reset --hard`, `checkout .`, `restore .` y las cinco formas de `stash`). Este repositorio
la quiere porque aquí trabajan varios agentes en paralelo sobre el mismo árbol, que es exactamente el
escenario que la motiva. Verificado en vivo contra el guardián estable 1.31.0 (2fecae1): `git clean -fd`
se deniega citando `git.prohibidos: 'clean -f'` del manifiesto, y `git stash list` pasa.

Quality gates en verde tras el cambio: `bash -n` sobre los 9 `hooks/*.sh` y `tools/*.sh`, y `jq -e` sobre
`hooks/hooks.json`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` y `.arnes/config.json`.

## [Interno] — 2026-09-06 · el plan maestro hasta que el arnés esté terminado
> Origen: Interno · usuario: Juan · modelo de IA: Opus 5 · agente: sesión coordinadora.

- `docs/PLAN.md` (nuevo): qué entra en cada ventana de 1.32.0 a 1.36.0, qué cierra y **por qué va ahí
  y no antes**. La regla de orden que explica el reparto: lo que **compone** va primero — una palanca
  que abarata el ciclo se paga en todas las ventanas siguientes; un mecanismo que cierra un hueco se
  paga una vez.
- Con una definición explícita de **«terminado»**: ningún hallazgo `contrato` abierto, ninguna promesa
  más fuerte que lo que la máquina cumple, y un ciclo que cabe en un presupuesto declarado. Lo que
  quede después es backlog, no obra pendiente.
- `docs/PENDIENTES.md` gana el aviso de que sus rótulos de versión quedaron desfasados por la
  reordenación y de que manda el plan. La cola cruda sigue siendo válida; el número de versión no.

## [Interno] — 2026-09-06 · disciplina de coste, y lo que se decide NO construir
> Origen: Interno · usuario: Juan · modelo de IA: Opus 5 · agente: sesión coordinadora.

- `docs/gobernanza/autoalojamiento.md`: la disciplina de coste, obligatoria desde el ciclo 3. La
  fórmula que gobierna todo lo demás, medida sobre 3.384 turnos: **el coste de una comisión es
  turnos por contexto**. La más cara fue de 138 turnos y 12,48 USD; la más barata que hizo trabajo
  real, de 8 turnos y 0,06 USD.
- Consecuencias: el encargo declara presupuesto y el agente lo reporta; lo grande se lee tarde y en
  trozos; y la elección de modelo casi no mueve la aguja, porque el 87 % del gasto es caché.
- **Y una decisión de no construir:** el arnés no llevará un medidor de coste. Medirlo exige leer las
  transcripciones del anfitrión, cuyo formato no está documentado y puede cambiar; meterlo en el
  plugin haría que todos los proyectos heredaran esa dependencia. Se documenta el **método**, que es
  estable, y mide la coordinadora.

## [Interno] — 2026-09-06 · la ventana 1.32.0 se dedica al coste, y el resto se aplaza
> Origen: Interno · usuario: Juan · modelo de IA: Opus 5 · agentes: sesión coordinadora y `analista-requerimientos`.

- **REQ-012, REQ-013 y REQ-014** redactados para 1.32.0: criterios por mecanismo y no por enumeración,
  mapa de archivos para poder paralelizar, y el banco en archivos por sección. Cada uno con su forma de
  medirse contra la línea base del ciclo 2.
- **1.32.0 pasa a ser la ventana del coste y nada más.** Los bloques B y C de REQ-007 y la puerta
  posterior se mueven a 1.33.0. El motivo: las palancas de coste **componen** y lo demás no, así que
  primero se abarata el bucle y después se construye con él; al revés se paga el precio completo y se
  mejora cuando ya no sirve para ese trabajo. Lo que se retrasa exige ofuscación deliberada.
- **REQ-013 deja de tocar el lector de las puertas.** Su propio criterio declara que el campo nuevo no
  es puerta, y si ninguna puerta lo lee, el lector que gobierna no tiene por qué conocerlo. Reutiliza la
  normalización compartida y exige diff vacío. Con eso desaparecen dos conflictos que ya estaban escritos.
- **Y una decisión aplazada a propósito, que es la disciplina de coste aplicada a nosotros mismos:** el
  write-back de cómo conviven REQ-007 y REQ-011 en 1.33.0 queda escrito en `docs/PENDIENTES.md` con su
  razón, y se lleva al REQ cuando esa ventana se abra. Escribirlo hoy costaría una comisión de analista
  medida en cuatro dólares para un texto que nadie lee hasta entonces.

## [Interno] — 2026-09-06 · cuánto cuesta un ciclo, medido, y las tres palancas
> Origen: Interno · usuario: Juan · modelo de IA: Opus 5 · agente: sesión coordinadora.

- `docs/PENDIENTES.md`: la **línea base** del ciclo 2 —25 comisiones, ~5 h 23 de tiempo de agente,
  cuatro vueltas del bucle a unos 50 minutos cada una—, sin la cual «mejoramos» es una sensación.
- El diagnóstico con los hallazgos delante: **siete de veinte fueron que el criterio decía algo falso
  sobre lo construido**, no que el código fallara, y uno de ellos costó una vuelta entera.
- Queda dicho también **lo que no es el problema**, para no optimizar la parte equivocada: el orden
  QA→auditor no se puede paralelizar sin producir una firma falsa, y las corridas de control de la
  coordinadora suman seis minutos en todo el ciclo. El cuello son dos archivos monolíticos.
- Y el contexto que evita la conclusión equivocada: este repositorio se impone la **ceremonia máxima**
  a propósito. Las cinco horas son el techo de quien construye el mecanismo, no lo que paga quien lo usa.

## [Interno] — 2026-09-06 · cierre del ciclo 2 del autoalojamiento
> Origen: Interno (documentación de gobernanza) · usuario: Juan · modelo de IA: Opus 5 · agente: sesión coordinadora.

- `v1.31.0` publicada (tag sobre `main` 2fecae1, PR #33, `hooks-en-linux` 682/0/1) e instalación estable
  actualizada. Los siete REQ de la ventana pasan a `completado` con QA y Seguridad aprobados; REQ-007
  sigue `en-progreso` y cruza a 1.32.0.
- `docs/gobernanza/autoalojamiento.md`: fila del ciclo 2 como publicado, fila del ciclo 3 abierta, y lo
  que enseñó el ciclo — incluida una lección que sólo aparece al autoalojarse: **el cierre de un REQ lo
  juzga el guardián de la sesión, no la versión recién publicada**. Al cerrar con 1.30.3 gobernando, la
  puerta rechazó el campo `Hallazgos abiertos:` escrito en la forma ancha que 1.31.0 aprendió a leer. No
  es un fallo, es el principio funcionando; la consecuencia para cualquier proyecto es que ese campo se
  escribe en forma cerrada y la evidencia vive en el informe.
- `docs/PENDIENTES.md`: la deuda del ciclo 2, toda con criterio y dueño, y la migración de andamiaje que
  este repositorio tiene pendiente porque 1.31.0 **sí** cambió plantillas.

## [1.31.0] — 2026-09-05
> Origen: GitHub · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos` (REQ-002…009), `desarrollador` (implementación y banco), `qa-tester` y `auditor-seguridad` (pendientes en el ciclo 2 del autoalojamiento).

Siete mecanismos, todos nacidos de defectos **medidos en proyectos reales** y descritos aquí
en la forma del hallazgo: qué fallaba, por dónde, y qué cambia para un proyecto. Cuatro nacen
**apagados**; sólo uno viene encendido, y se dice por qué.

### Corregido — el acento no es parte del valor: `en-revision` y `en-revisión` son el mismo estado (REQ-010)
**Qué fallaba:** un proyecto que corre el arnés reportó que el informe marca como «valor que
ninguna puerta reconoce» un `Estado:` escrito **sin tilde**. Con decenas de requerimientos eso son
decenas de avisos falsos por documento, y un informe ruidoso no es sólo molesto: es la forma
conocida de que las anomalías reales se entierren. **Por dónde:** la normalización de campos
plegaba exactamente **una pareja de letras** —`Í`/`í`—, añadida en su día para que `Sensible a
seguridad: **Sí**` casara con `sí`. `en-revisión` lleva `ó`, que no estaba en esa pareja. Es la
cuarta aparición de la misma familia de defecto en este arnés: **el sujeto del control era más
estrecho que su población**. **Por qué no era sólo un aviso feo:** la misma normalización gobierna
la detección de la transición al estado terminal. En un proyecto cuyo `estados.completado` lleve
acento —lo declara cada proyecto: es mapeo, no mecanismo—, escribirlo sin tilde hacía que la puerta
**no viera la transición** y un requerimiento crítico cerrara sin veredicto de seguridad. Falla en
abierto y en silencio. **Qué cambia:** el arreglo no añade la letra que faltaba —eso repetiría el
defecto a la quinta— sino que declara la clase completa: se pliegan todas las vocales acentuadas y
con diéresis, en mayúscula y minúscula, en forma precompuesta **y descompuesta** (un archivo
guardado en macOS trae la tilde descompuesta y nada lo delata a la vista). **No** se pliega la `ñ`
—es otra letra, no una `n` con adorno; plegarla haría iguales `año` y `ano`— ni los separadores:
`en revision`, `enrevision` y `en-revisión-parcial` siguen siendo valores distintos. El plegado vive
**una sola vez**, en la misma función que ya normaliza caso y marcado, y lo usan por igual la
puerta, el informe y el bloque derivado. **Coste: cero procesos y cero forks** —sólo expansión de
parámetros, detrás de una guarda sobre el byte de cabecera, así que un valor ASCII no paga ni una
sustitución— y el veredicto es idéntico bajo `LC_ALL=C` y bajo un locale UTF-8, porque la tabla se
escribe con escapes de bytes y no depende de la colación del entorno. El informe sigue mostrando el
valor **crudo** tal como está en el archivo, con el normalizado al lado: quien lee el aviso tiene
que poder encontrar el texto en su editor.

### Corregido — la CLAVE del campo también se decora, y dejaba el campo vacío (REQ-007, bloque A)
**Qué fallaba:** el **valor** de un campo se leía con tolerancia desde 1.30.0 —`**completado**` es
`completado`— pero la **clave** se casaba contra el literal `^Clave:`. Así que `**Estado:**
completado`, `Estado:` seguido de tabulador, ` Estado:` con sangrado y las seis claves envueltas en
énfasis de Markdown **no se reconocían**. **Por qué es grave y no cosmético:** falla en abierto. Con
`**Hallazgos abiertos:** SEC-9 (usuario/dinero)` la clave no casaba, el campo quedaba **vacío** — y
un campo vacío significa «ningún hallazgo». El requerimiento cerraba con un hallazgo de clase
bloqueante declarado a la vista de cualquiera que leyera el documento. **Qué cambia:** la clave se
lee con la **misma regla** que el valor y en el mismo sitio —se retira el espacio en blanco de los
extremos y el énfasis de Markdown—, no con una lista de formas enumeradas: una lista se pudre y la
regla vale para las formas que nadie ha escrito todavía. Es la otra mitad de la misma línea que el
plegado de acentos, y por eso entran juntas: arreglar una sin la otra hace que el defecto reaparezca
en la mitad de al lado. **Lo que NO cambia: dónde vale un campo.** Los campos siguen valiendo sólo
en la cabecera, antes del primer `## `; la tolerancia es sobre **cómo** se escribe la clave, nunca
sobre **dónde**. Y leer de más cae siempre del lado que **cierra** la puerta: `**Rigor:** critico`
sobre un requerimiento no sensible se lee `critico` y exige auditoría.

### Corregido — un manifiesto roto apagaba el enforcement en silencio (SEC-005)
**Qué fallaba:** si `.arnes/config.json` **existía** pero no se podía leer —inválido, vacío, `null`
o un array—, la lectura del manifiesto no miraba su código de salida y **todo se permitía sin decir
nada**. Peor: la variable de la lectura conservaba su **valor anterior**, que era el análisis del
**input**, así que las variables del manifiesto se rellenaban con campos que controla quien llama —
el agente de código autorizado se quedaba valiendo `Bash`, el nombre de la herramienta, y la lista
de rutas protegidas, vacía. La identidad del agente autorizado la escribía el llamante. **Qué
cambia:** un manifiesto **ausente** sigue dejando los hooks inertes, que es una decisión legítima de
un proyecto que no usa el arnés; uno **presente y roto** avisa por stderr **siempre** y **deniega**
toda escritura que las puertas tendrían que juzgar —no se puede denegar «sólo en las rutas
protegidas» porque justo lo que no se puede leer es cuáles son—. Ningún dato del input atraviesa ya
esa frontera. Un `ls -la` sigue pasando: no escribe nada y bloquearlo no protegería ninguna
invariante, y por lo mismo **ni siquiera lee el manifiesto** — el aviso se emite siempre que el
manifiesto **se consulta**, que es siempre que hay algo que juzgar con él (el camino común de
`Bash` vuelve así a costar **1 proceso**, los mismos que v1.30.3; ver *Pruebas*).
**Y el remedio que el motivo recomienda ahora existe:** mientras el manifiesto esté roto, la
**única** escritura permitida es la del **propio `.arnes/config.json`**. Un proyecto que lo tenga
en `codigo_app.globs` —como éste— quedaba con la reparación denegada para todos los agentes por
`Edit`, por `Write` y por `Bash`: el mensaje ofrecía una salida que él mismo cerraba. Es el único
archivo cuya reparación devuelve la capacidad de medir y no depende de leerlo; cualquier otra ruta
sigue denegada, y con el manifiesto sano vuelve a estar protegido como cualquier otro.

### Corregido — lo que el manifiesto no dice bien cae del lado seguro, y ahora también lo dice
**Qué fallaba:** `"exigir_fecha": "true"` —la cadena, no el booleano— apagaba la exigencia de
fecha **sin una sola señal**, mientras que el techo de análisis de Bash sí avisaba ante el mismo
error de tipo. La asimetría es lo que sorprende: el proyecto cree que declaró algo y no declaró
nada. Y en el propio techo quedaba un hueco entre las dos ramas: `1e9` o `1.5` son números JSON
válidos que no son enteros de bytes aplicables, así que caían al valor por defecto **callando**.
**Qué cambia:** una sola regla para todas las claves que leen las puertas —`agentes.agente_codigo`,
`requirements_dir`, `estados.completado`, `pending_approval`, `limites.bash_max_analisis`,
`veredictos.*`, `git.*` y `codigo_app.globs`—: **lo que no tiene el tipo que esa clave espera cae al
valor por defecto del arnés y se avisa**, nombrando la clave y el valor recibido tal como venía. No
deniega —un tipo mal escrito no puede convertirse en un bloqueo— pero tampoco calla. Si lo que no
tiene el tipo esperado es el **contenedor** (`"veredictos": "x"`), el manifiesto entero sigue
declarándose ilegible: ése es el fail-closed de arriba y no cambia.

### Corregido — no se escribe a través de un enlace simbólico (SEC-004)
**Qué fallaba:** los dos guardianes clasifican por el **nombre** de la ruta, así que un enlace
colocado en una ruta libre que apuntara a código protegido o a un requerimiento recibía el veredicto
de su nombre y no el de lo que realmente toca. **Qué cambia:** si la ruta de un `Edit`/`Write`/
`MultiEdit` es un enlace simbólico dentro del proyecto, se deniega con ese motivo. **El destino no
se resuelve, y es deliberado:** resolverlo costaría un proceso en el camino de toda edición y
abriría una carrera entre la comprobación y la escritura —lo que el hook mide y lo que la
herramienta escribe dejarían de ser el mismo archivo—. El precio, dicho en voz alta: no se puede
escribir a través de un enlace ni siquiera cuando su destino es inocente, y eso alcanza también al
agente de código. La salida está a la vista: escribir sobre la ruta real.

### Añadido — un veredicto lleva fecha y caduca con el código (REQ-002, apagado)
**Qué fallaba:** cuatro requerimientos estaban a punto de cerrarse con un `QA: aprobado`
emitido contra código que había cambiado **después** de la firma, y otro llevaba un
`Seguridad: aprobado` a secas —sin ronda ni fecha—, que era justamente el único que nadie
sabía que estaba caduco. Un veredicto es una foto, y una foto sólo vale si el sujeto estaba
quieto. **Por dónde:** la convención de poner la evidencia al lado de la afirmación ya
existía; lo que faltaba era que la máquina pudiera **exigirla** y **usarla**.
**Qué cambia:** con `veredictos.exigir_fecha`, un `aprobado` sin fecha `AAAA-MM-DD` en su
paréntesis de evidencia no cierra; con `veredictos.caducan_con_codigo`, tampoco cierra un
veredicto anterior al último commit que tocó `codigo_app.globs`, ni con cambios sin comitear
en ese código. Si no se puede medir —sin git, sin repositorio, sin globs declarados o con un
git que no entiende `%cs`— **no se deja pasar**: una puerta que no puede medir no deja pasar.
Las dos claves vienen apagadas, así que un proyecto que no las active no nota ningún cambio.
Cuesta como mucho **dos** invocaciones de git por evaluación, y ninguna en el camino de Bash.
*Asimetrías declaradas:* el empate del mismo día no caduca (`%cs` tiene resolución de día) y
una fecha futura se acepta —esta puerta mide contra el código, no contra el reloj—.

### Añadido — un solo vocabulario, un solo lector, y un aviso al escribir (REQ-003)
**Qué fallaba, tres veces:** (1) entre `pendiente` («no he mirado») y `vetado` (freno formal
con remedio, dueño y umbral) no había forma de decir lo intermedio, que es el estado más común
de una auditoría real: cinco requerimientos de un proyecto ya escribían `con-hallazgos` porque
el vocabulario no les daba la palabra —cuando la gente escribe un valor que la herramienta no
tiene, la incompleta es la herramienta—. (2) Cuatro requerimientos llevaban **semanas** con un
`QA:` que la puerta no reconocía, y nadie lo supo hasta que un cierre falló. (3) El informe
`tools/arnes-lectura.sh` no aplicaba a `Estado:` la regla del paréntesis de evidencia que la
puerta aplica desde 1.26.0: **28 de 42 anomalías eran falsas**, y el ruido enterraba las 14
reales. **Qué cambia:** `Seguridad: con-hallazgos` es un valor válido (y, como todo valor
distinto de `aprobado`, **no cierra**); el vocabulario vive en **un solo sitio** compartido por
las puertas y el informe; escribir un veredicto fuera de él **avisa en el momento** con un
mensaje a la persona y **sin denegar** la edición —denegar una errata añadiría fricción
constante a algo inocuo, y esa fricción acaba con alguien apagando el guard—; y el informe lee
`Estado:` exactamente como lo lee la puerta.

### Añadido — rotar UNA sección: la historia se archiva, el contrato no (REQ-004, apagado)
**Qué crecía sin tope y quién lo pagaba:** en un proyecto real `requirements/` pesaba **3,73 MB
en 47 archivos**, uno solo de **244 KB**, y ese peso lo paga **cada agente** que abre el
requerimiento para leer dos criterios. La rotación que existía cortaba por secciones `## ` de
un artefacto entero, y en un requerimiento lo que crece es **una** sección: el resto es el
contrato. **Qué cambia:** un artefacto declarado con `glob` + `seccion` mueve las entradas
viejas de esa sección a `historial/<nombre>.md` y deja un puntero. **No resume, no reescribe y
no borra: mueve.** Y no toca **nada** fuera de la sección declarada —ni la cabecera con sus
veredictos ni los criterios—, lo cual aquí es una invariante de seguridad y no una comodidad:
el hook escribe en `requirements/` desde una parada, fuera de la vía que vigila la puerta de
cierre. Qué sección es «historia» lo declara el proyecto; el arnés no trae ninguna por defecto,
y el nombre se compara **exacto**, nunca por prefijo — y cuando el archivo casa el `glob` pero
**no** contiene la sección declarada, no se rota nada **y se dice**: un aviso por stderr que
nombra el archivo y la sección que no encontró, y una línea en el bloque derivado de
`docs/ESTADO.md`. Un artefacto declarado que no existe es un error de mapeo que hay que ver, no
un acierto silencioso: sin la señal, un proyecto que escribió mal el nombre cree que rota desde
hace meses. (Por eso la parada ahora **rota antes de derivar**: el bloque describe el disco
después de la rotación, no antes.)

### Añadido — ningún agente ejecuta git destructivo (REQ-005, **encendido**)
**Qué se perdió:** ~52 archivos de trabajo **sin comitear** en un incidente. La causa de fondo
no es el descuido de nadie: **el trabajo de un subagente no es atómico para git**. Mientras un
agente escribe, el árbol contiene estados intermedios que no son de nadie; otro agente limpia
«su» árbol y arrasa el del primero, y git no devuelve lo que nunca se comiteó. **Qué cambia:**
`hooks/guard-git.sh` deniega por `Bash` las formas destructivas de `clean -f`, `reset --hard`,
`checkout .`, `restore .` y `stash` a **todos** los agentes, incluida la sesión coordinadora:
es una regla del **comando**, no de la identidad. No alcanza a `stash list`, `stash show`,
`restore --staged`, `clean -n` ni a ningún git de lectura, y lo entrecomillado y el cuerpo
literal de un heredoc se descuentan antes de mirar —`git commit -m "no uses git clean"` no es
un `git clean`—. **La ortografía del flag no abre un hueco** (vuelta 1 de QA): `--force` y `-f`
son el mismo flag escrito de dos maneras y casan igual, en los dos sentidos —una regla escrita
`push --force` alcanza también `git push -f`—, con el valor pegado (`--force=x`) y respetando el
fin de opciones (`git clean -- --force` borra un archivo **llamado** `--force`, y sigue
permitido). Lo mismo con el nombre viejo de un subcomando: `git stash save` es `git stash push`.
La equivalencia vive en el **motor** y no en la lista, para que valga también para el
`git.prohibidos` propio de cada proyecto; sólo se reconocen las que son un hecho de git, porque
deducir la forma corta del nombre largo haría que `clean -d` denegara un `--dry-run`. **Es la única novedad de 1.31.0 activa por defecto**, porque es la única que
impide un daño irreversible; se apaga con `git.activo: false` o se sustituye con
`git.prohibidos`. Cobertura parcial dicha en voz alta: quedan fuera los scripts y los
intérpretes que ejecuten git por su cuenta. Es una barandilla, no una jaula.

### Corregido — construcciones ordinarias del shell atravesaban la puerta de git (SEC-009)
**Qué fallaba:** `git clean -fd` desnudo se denegaba, pero **envuelto en cualquier construcción
corriente del shell pasaba**: `if true; then git clean -fd; fi`, `{ git clean -fd; }`,
`for i in 1; do git clean -fd; done`, `sleep 0 & git clean -fd`, `nohup git clean -fd` y la orden
partida con una continuación de línea. Siete formas medidas, ninguna exótica: una limpieza
condicional se escribe **exactamente así**, de modo que el hueco no había que buscarlo, se pisaba
sin querer. **Por dónde:** la puerta juzga el **primer token de cada orden**, y la segmentación no
partía por `&` sencillo ni plegaba la continuación de línea; peor, el bucle que salta lo que no es
el comando —asignaciones de entorno, `sudo`, `env`— no conocía las **palabras reservadas del
shell**, así que un segmento que empezaba por `then`, por `do` o por `{` se descartaba entero, con
el `git` dentro. **Por qué importa más que en otras puertas:** es la única que nace **encendida**
en todos los proyectos, y lo que deja pasar es irreversible. **Qué cambia:** la continuación de
línea se pliega antes de partir, el `&` sencillo separa órdenes como ya hacían `&&`, `;` y `|`, y
el bucle de prefijos tolera las palabras reservadas (`then`, `else`, `elif`, `do`, `{`, `!`…) y los
envoltorios que preceden a un comando (`nohup`, `setsid`, `timeout`, `stdbuf`, `xargs`), con sus
opciones y su argumento cuando lo llevan. Todo eso ensancha **dónde mira** la puerta, nunca lo que
deniega: `echo git clean -f` y un `grep` de un texto que dice `then git clean -fd` siguen
permitidos, y están en el banco para que sigan estándolo. **Lo que sigue fuera, y se dice:** un
subcomando que llega por variable (`G=clean; git $G -f`) no se ve —el valor no está en el texto del
comando—, igual que los intérpretes y los scripts. **No es una regresión:** contra la versión
publicada estas formas ya pasaban, porque la puerta no existía.

### Corregido — un manifiesto ilegible apagaba la puerta de git, justo cuando todo lo demás se denegaba (SEC-010)
**Qué fallaba:** con `.arnes/config.json` presente pero ilegible —inválido, vacío, `null`, un array
o con la clave `git` del tipo equivocado—, las dos puertas de escritura denegaban con su aviso
mientras la puerta de git **permitía**. Y el aviso afirmaba, textualmente, que «toda escritura que
las puertas deban juzgar se deniega»: cierto de dos puertas de tres. **Por qué es grave:** en un
proyecto plantilla el manifiesto **no** está entre las rutas protegidas, así que la única puerta
encendida por defecto tenía un interruptor de apagado alcanzable en **una** escritura de cualquier
agente — y por accidente, con una coma de más. El estado en que ocurre es además aquel en el que
todo lo demás está bloqueado y el agente busca «dejar el árbol limpio». **Qué cambia:** se aplica
el principio rector —una puerta que no puede medir no deja pasar—. Con el manifiesto ilegible la
puerta de git cae a la **lista por defecto que vive en el código** y **deniega**, con un motivo que
dice que está en **modo degradado** y cuál es la salida: reparar el JSON, que es la única escritura
que la avería deja pasar. La lista por defecto pasa a declararse **una sola vez** y las dos vías
—manifiesto sano y modo degradado— leen la misma cadena: dos transcripciones de la misma regla se
desfasan. **El borde, declarado en voz alta:** un proyecto que tuviera la puerta apagada con
`git.activo: false` y se le rompa el manifiesto **pasará a denegar**. Es la dirección segura
—apagar es un acto explícito y un JSON roto no lo es— y la salida es reparar el manifiesto. Con el
manifiesto sano, `git.activo: false` sigue apagando la puerta exactamente como antes.

### Corregido — el archivo de continuidad no se pierde, ni con el manifiesto roto ni por un byte extraño (SEC-011)
**Qué fallaba:** tres cosas, todas en el mismo archivo y todas medidas. **(1)** Con el manifiesto
ilegible, la parada dejaba dos errores crudos de `jq` por stderr y **ningún bloque derivado**: la
observabilidad que el arnés promete —«la traza vive en archivos legibles»— se apagaba justo en el
estado degradado, que es cuando hace falta. Con el manifiesto **vacío** era peor: el hook moría con
`unbound variable` y la parada salía con error. **(2)** Un byte **NUL** en `docs/ESTADO.md` cortaba
la lectura ahí mismo y todo lo que venía detrás **se perdía** al reescribir. **(3)** Un
`docs/ESTADO.md` con contenido pero **sin permiso de lectura** se leía como vacío, y el bloque
sustituía al documento entero. Las dos últimas son la misma familia: **se reescribía a partir de
una lectura que había fallado**, y lo que se perdía era texto de una persona. **Qué cambia:** los
valores por defecto se fijan **antes** de leer nada, así que ninguna ruta deja una variable sin
definir; con el manifiesto ilegible el bloque **se deriva igual** —derivar no necesita el
manifiesto: sale del disco— con las rutas por defecto del código, y escribe una línea que dice
**«manifiesto ilegible: enforcement degradado»** con la salida. Y si lo que no se puede leer es el
**destino** —sin permiso, o con un NUL detrás del cual hay bytes que no se pueden traer—, **no se
escribe nada**: el archivo queda **byte a byte** como estaba y se avisa. Un bloque de continuidad
que no se escribe es un inconveniente; uno que borra el documento es una pérdida. Si la escritura
falla al publicar (disco lleno, carpeta sin permiso), el original sigue intacto, **no queda ningún
temporal huérfano** y se dice. **Y la reparación del manifiesto deja rastro:** la escritura de
`.arnes/config.json` permitida durante la avería emite un aviso **propio y distinguible** que
nombra el archivo, la herramienta y el tipo de agente que repara —una vez por llamada, no una por
guardián—, en vez de un stderr idéntico al de cualquier otra llamada. No se registra ningún
contenido.

### Corregido — las celdas del bloque derivado no caben en una tabla (REQ-006)
**Qué fallaba:** en un proyecto con 57 requerimientos, cuatro celdas de veredicto ocupaban el
**37 %** del bloque de continuidad, y la mayor —**1 296 caracteres sin un solo espacio**—
además **rompía la tabla**: una fila que no cabe deja de renderizarse como fila, así que el
bloque dejaba de servir para lo único que existe, que es contar en tres líneas dónde quedó
todo. **Qué cambia:** las tres celdas de texto libre (`QA`, `Seguridad`, `Hallazgos abiertos`)
salen recortadas a 40 caracteres con `…`, y una barra vertical dentro de un valor se neutraliza
para que no abra una columna nueva. **El recorte es de presentación**: pasa después del
normalizador y sólo al componer la fila, así que ni la puerta ni el informe ven nunca el valor
recortado —si llegara a la lectura, un `Hallazgos abiertos:` largo podría perder su clase
bloqueante por el camino—.

### Corregido — la cola de aprobaciones se contaba de dos maneras (REQ-009)
**Qué fallaba:** la misma cola, dos números. La puerta de cierre contaba **encabezados
`###`** bajo `## Pendientes`; el bloque derivado de `docs/ESTADO.md` contaba **viñetas**
(`- `, `* `, `1. `) en la misma sección. Una entrada real del formato que documenta el
propio `PENDING_APPROVAL.md` —un `###` con cuatro viñetas debajo— valía **1** para la
puerta y **4** para el bloque. Ninguno de los dos números miente por sí solo; lo que miente
es que haya dos, porque el número que se lee deja de ser el que bloquea. Además el conteo de
viñetas nunca recibió la corrección del **ejemplo comentado**, así que un `<!-- … -->` con un
ejemplo dentro sumaba. **Por dónde:** dos transcripciones de la misma regla, en dos archivos
—la misma familia que el vocabulario de veredictos de REQ-003—, y se desfasaron en silencio
hasta que alguien comparó los dos números.
**Qué cambia:** la regla vive **una** vez (`arnes_cola_pendientes`, `hooks/lib.sh`) y la usan
por igual la puerta, el bloque derivado y `tools/arnes-lectura.sh`, que ahora también informa
de la cola. Gana la regla de la puerta —la que decide y la que está documentada—: una entrada
es una línea `###` + espacio dentro de la sección que abre un `## ` cuyo texto empieza por
«Pendientes» y cierra el siguiente `## ` de cualquier nombre, descontando los comentarios
HTML. **Y la cola es una puerta:** si no se puede leer entera —un byte NUL que la trunca, un
archivo sin permiso— la puerta **deniega** con motivo propio en vez de contar 0 sobre un
archivo que nadie leyó, y el bloque derivado dice `sin datos` en vez de `0`. *Se paga en
negativo:* el conteo se hace con lecturas y expansión de parámetros, así que la puerta pierde
el `awk` que pagaba en cada cierre (medido: 1 → 0) y la parada no gana ninguno.
**Al actualizar:** el número de aprobaciones pendientes del bloque derivado puede **bajar**
sin que nadie haya resuelto nada. No hay nada que migrar: se regenera en la siguiente parada.

### Seguridad — cuatro huecos de la auditoría R-001, todos de la misma familia (REQ-007)
Todos **preexistentes** —medidos idénticos en 1.30.3 y en la versión anterior—, ninguno es
regresión, y todos son la misma clase: **un dato que controla quien llama decide cómo se
comporta el guardián**.

- **Una barra de más desactivaba las DOS puertas.** Un `Write` a `<raíz>//src//a.ts` o un
  `Edit` sobre `<raíz>//requirements//REQ-x.md` pasaban: la ruta relativa se calcula
  recortando el prefijo del proyecto **textualmente**, la ruta no empezaba por `<raíz>/`, el
  prefijo no se recortaba, ningún glob de código casaba y ninguna ruta caía dentro de
  `requirements/`. Era la evasión **más barata** medida en todo el arnés —un carácter, sin
  ninguna forma exótica— y alcanzaba a los dos guardianes a la vez. Ahora las barras repetidas
  se colapsan al normalizar la ruta, **antes** de recortar el prefijo y **sin ningún proceso**;
  la doble barra inicial de una ruta UNC de Windows se conserva.
- **Un byte de control desincronizaba la simulación del cierre.** Las piezas de un
  `Edit`/`MultiEdit` se trocean con un separador que viaja **dentro** del propio dato: con un
  byte de control metido en un `new_string`, el bucle leía como tripletas cosas que no lo eran
  y **el documento que el hook simula dejaba de ser el que la herramienta iba a escribir**. Las
  cuatro puertas del cierre —veredictos, cola, quality gates y clase del hallazgo— se saltaban
  a la vez, con un byte. Ahora un `tool_input` con bytes de control C0 —cualquiera salvo
  tabulador, salto de línea y retorno de carro, que el Markdown normal sí lleva— **no se juzga:
  se deniega**, en la misma llamada a `jq` y sin ningún proceso nuevo.
- **Un NUL dentro del documento truncaba la lectura del disco.** La forma barata de leer un
  archivo entero en bash usa el NUL como delimitador, así que un NUL en la primera línea dejaba
  el texto cortado ahí: los veredictos se leían de un documento incompleto —y un campo vacío no
  exige nada— y, de paso, la reconstrucción fallaba y la puerta caía a su vía más laxa. Bastaba
  una escritura previa en `requirements/`, que ninguna puerta restringe. Ahora la lectura
  **dice** cuándo no pudo leer el archivo entero, y una edición que menciona el estado terminal
  sobre un documento ilegible se deniega con motivo propio. Lo que decide sigue siendo la
  transición: una edición que no toca el estado no queda bloqueada por el byte.
- **El techo de análisis de Bash se podía subir sin tope desde el manifiesto.** El coste del
  análisis crece con el tamaño y un hook `PreToolUse` **muere a los 60 s permitiendo**: un
  `limites.bash_max_analisis` de `4294967296` reabría **por configuración** justo el fallo en
  abierto que el presupuesto de 1.30.3 cerró. Y `"999999"` **entrecomillado** —una cadena, no un
  número— se aceptaba como si lo fuera. Ahora el valor declarado tiene un **máximo operativo**,
  medido y no arbitrario: por encima se aplica el máximo y se avisa; un valor que no sea un
  número en el JSON cae al techo por defecto, también con aviso. Un valor **más bajo** que el
  defecto sigue sin bajar nada, y el motivo del deny sigue imprimiendo el techo vigente en bytes
  sin nombrar ninguna ruta.

**Pendiente de decisión humana, y por eso no aplicado:** el manifiesto que define la frontera
no está **dentro** de la frontera —quien no puede escribir el código de los guardianes sí puede
cambiar la regla que dice qué es ese código—. Es escalada de privilegios dentro del arnés y el
mecanismo para cerrarla ya existe; lo que falta es el **mapeo**, y cambiar el mapeo de este
repositorio exige aprobación del propietario. Queda escrito en `PENDING_APPROVAL.md` y el
pipeline se detiene ahí. **Ninguna plantilla hereda esos globs:** es mapeo de este repositorio,
no mecanismo, y el banco tiene un caso que se pone rojo si algún día aparecen ahí.

### Andamiaje que heredan los proyectos
- `templates/arnes-config.json.tpl`: bloques nuevos `veredictos` (apagado), `git` (encendido) y
  `limites` (**opcional**: el techo de análisis de Bash que 1.30.3 dejó sin documentar), y la
  forma de sección en `rotacion.artefactos`, todos con su `_doc`.
- `templates/requirements-README.md.tpl` y `templates/AGENTS.md.tpl`: `con-hallazgos`, la fecha
  del veredicto, el aviso sin bloqueo, la rotación de la historia y el recorte de celdas.
- `skills/arnes-upgrade/SKILL.md`: sección **Hacia 1.31.0** con qué preguntar antes de encender
  `veredictos.*`, qué avisar de `guard-git`, dos marcadores nuevos de versión y los tres avisos
  nuevos: la cuenta de la cola puede bajar sola, un REQ con la cabecera decorada empieza a ser
  juzgado, y `limites.bash_max_analisis` tiene ahora un máximo.
- `templates/PENDING_APPROVAL.md.tpl`: la regla de conteo de la cola, escrita **una vez**, y el
  aviso de que el bloque derivado y la puerta cuentan lo mismo.
- `templates/AGENTS.md.tpl`: el párrafo que acota la detección del estado terminal por `Bash`
  —lee el texto crudo del comando, así que partir la palabra entre expansiones la evade; la
  respuesta es la puerta posterior, no un patrón más largo—, para que ningún proyecto lea una
  promesa más fuerte de la que la máquina cumple.
- `ARCHITECTURE.md`: vista de sistema al día, con el guardián nuevo y el orden de `guard.sh`.

### Validación — dos vueltas del bucle dev↔QA, y lo que enseñaron

El `qa-tester` validó la ventana en dos vueltas y devolvió defectos que ninguna prueba del
desarrollador había visto. Merecen el detalle, porque son familias que se repiten:

- **La puerta nueva de git no veía las formas largas.** `git clean --force`, `git clean --force -d` y
  `git stash save` pasaban: el motor saltaba todo lo que empieza por dos guiones, y `save` es el alias
  antiguo de `push`. Se arregló canonicalizando **los dos lados** antes de comparar y poniendo el alias
  en el motor, no en la lista: un proyecto con lista propia habría perdido la equivalencia sin enterarse.
- **El coste del camino común se había duplicado**, de un proceso a dos por cada comando de shell, como
  efecto del arreglo del manifiesto roto. En Linux son milisegundos; donde un fork cuesta entre 1,2 y
  6 s, es otra magnitud. Ahora las escrituras se detectan antes, y el manifiesto sólo se lee si hay algo
  que juzgar.
- **Un punto muerto fabricado por el propio arnés:** al meter el manifiesto dentro de su propia
  frontera, repararlo quedaba denegado para todos. Con el manifiesto ilegible se permite escribir el
  propio manifiesto y nada más, sin filtrar por agente — porque quién es el agente de código se lee del
  archivo que no se puede leer.
- **Un caso del banco que decidía por reloj de pared**, con un umbral fijo en milisegundos: dos corridas
  de la misma línea base dieron 457 y 458. Un banco que es puerta requerida de `main` no puede tener
  casos que dependan de lo cargada que esté la máquina.
- **Y tres veredictos que pasaron de denegar a permitir sin estar declarados** (`git clean -- -f`,
  `git reset -- --hard`, `git restore -S .`). Los tres son correctos y ninguno destruye nada, medido en
  un repositorio desechable: lo que estaba mal era el criterio, que prometía casar «todos los tokens
  presentes». Se cierra reescribiendo el requerimiento, no el guardián.

De ahí salió además una regla que se queda: **un criterio de coste se escribe como techo, nunca como
igualdad.** Escrito como igualdad, una mejora se lee como fallo.

Y de la verificación del veto salió otra, más incómoda: **el QA reprodujo la pérdida de texto humano**
en la versión anterior de esta misma ventana —dos hashes distintos y la línea de la persona contada a
cero, no una sospecha— y comprobó el arreglo con nueve averías propias que nadie había pedido: espacio
en disco agotado de verdad, el destino como enlace simbólico, sólo lectura, finales de línea mixtos,
cuatro paradas concurrentes por diez rondas, y un límite de tamaño de archivo. Ninguna perdió un byte.
La regla que deja: **una comprobación que sólo mira si el bloque está nunca habría visto el archivo
vaciado** — lo que se verifica es el archivo entero, por hash, no la parte que a uno le interesa.

### Seguridad — un veto, y lo que enseñó levantarlo

El `auditor-seguridad` **vetó** la puerta de git y el veto se levantó arreglando, no declarando. Encontró
que construcciones ordinarias del shell la atravesaban (`if … then`, `{ … }`, `for … do`, `&`, `nohup`,
la continuación de línea) y que **un manifiesto ilegible la apagaba** mientras el aviso afirmaba que todo
se denegaba. Las dos cerradas y verificadas por él con sondas propias, no aceptadas del informe de QA.

Tres cosas que se quedan del episodio:

- **El radio se mide antes de decidir.** Antes de tocar nada se comprobó que el detector de escrituras
  **no** estaba afectado: sus ocho formas denegaban igual en la candidata y en las dos versiones
  publicadas. Eso convirtió un susto en un arreglo acotado a una sola puerta, y evitó tocar código
  compartido que hoy funciona.
- **Un límite se cierra con su criterio, nunca de rebote.** Al plegar la continuación de línea era fácil
  arrastrar el escape del guion y cerrar en silencio un hueco que tiene dueño y ventana. Se dejó fijado
  por dos casos vecinos, y el auditor lo verificó expresamente al levantar el veto.
- **Y la simetría, que es la parte que nadie vigila:** el código acabó cubriendo **más** de lo que el
  criterio prometía —siete envoltorios donde el requerimiento declaraba tres—, y denegaba una forma que
  el propio documento decía no ver. Un límite que desaparece sin decirlo es tanta deriva como una
  promesa incumplida, así que la regla quedó escrita en las dos direcciones: **cuando el código cubra más
  de lo que el criterio promete, se actualiza el criterio en el mismo cambio.**

En la tercera vuelta la puerta de git quedó aprobada, y el arreglo fue **del criterio, no del guardián**:
se verificó que el código cumple la regla reescrita en 24 comandos, con los cuatro bordes del fin de
opciones. El banco dejó de bailar —tres corridas de la línea base dan el mismo número, y las 625 líneas
de resultado son idénticas entre corridas, no sólo el total—. Y quedaron dos límites dichos en voz alta:
un token **entrecomillado** desaparece del análisis, así que `git clean "-f"` pasa donde `git clean -f`
no —es el mismo descuento de comillas compartido cuyo arreglo está asignado a la ventana siguiente, y la
versión publicada se comporta igual—, y **un margen de coste expresado como cociente castiga a la máquina
rápida**: el delta es constante, el cociente no. Los dos se corrigen en el requerimiento, sin tocar una
línea de código.

### Corregido — el instrumento: un caso del banco decidía por reloj de pared (QA-111)

**Qué fallaba:** el caso «heredoc CITADO de ~300 KB → allow y barato» comparaba el tiempo medido
contra un umbral fijo de 1 000 ms puesto justo encima de lo observado. QA lo vio dar **1 038 ms
(FAIL)** y **616 ms (PASS)** sobre **la misma** línea base sin cambiar nada — y por eso dos corridas
completas de v1.30.3 dieron 457 y 458. **Por qué importa más de lo que parece:** el banco es la
puerta **requerida** de `main`, y un rojo que la gente aprende a re-lanzar es un rojo que deja de
significar algo. **Qué cambia — el reparto, no un número más alto:** (1) el **veredicto**
(`deny`/`allow`) es discreto y estable, decide el caso y no se reintenta; (2) que el hook
**responda** se comprueba por el código de salida de `timeout`, no por una comparación de reloj, y
**siempre**, también donde se espera `allow` — que es justo donde un hook muerto pasaba por bueno
(QA-007); (3) el **tiempo** se conserva, porque el coste es la propiedad que estos casos vigilan,
pero contra un techo **holgado** (cuatro veces el presupuesto declarado, ajustable por
`ARNES_CRONO_HOLGURA`) y **con reintento**: sólo falla si la mejor de tres medidas se pasa. Un pico
de carga ajena no es una regresión; un algoritmo cuadrático se pasa por múltiplos, no por un 4 %.
Reintentar no cuesta nada en el camino feliz. **Eran diez los casos que decidían por reloj**: nueve
por el cronómetro compartido y uno suelto (`SEC-004 CA-50b`, el enlace roto), que llevaba su propio
umbral de 1 000 ms escrito a mano; los diez pasan al mismo criterio. Y lo que el caso quería
acreditar —que el heredoc citado se descuenta **entero** y no entra en el presupuesto de análisis—
se comprueba ahora **sin reloj**, por el motivo del `deny`: si los 300 KB hubieran entrado en el
presupuesto, la respuesta sería el rechazo **por tamaño**; que el motivo nombre la ruta prueba
además que el análisis corrió. El caso cronometrado se queda como **medición** del coste.

### Corregido — la rama hermana del aviso: una sección que sí existe pero no tiene entradas (QA-109)

**Qué fallaba:** desde la vuelta 1, una sección **declarada que no existe** en el documento avisa y
lo refleja el bloque derivado (CA-09). La rama de al lado seguía muda: una sección que **sí** existe
y **supera el umbral**, pero cuyo contenido no tiene ni una entrada reconocible, no rota nada y no
decía nada. **No es hipotético:** el `## Historial de cambios` de los REQ de este repositorio es una
**tabla**, y las filas de tabla son continuaciones (CA-07), no entradas — así que ArnesJuan
encendiendo su propia rotación no rotaría nada y no se enteraría. Es el mismo error de mapeo y el
mismo silencio que CA-09 declara inaceptable. **Qué cambia:** se emite el aviso por stderr y se
cuenta para el bloque derivado, exactamente como en la otra rama, con **texto distinto** en los dos
casos, porque la acción que pide cada uno es distinta: allí se corrige el nombre de la sección en el
manifiesto; aquí, el formato de la sección o la expectativa de rotarla. **Lo que no cambia:** no
rotar sigue siendo lo correcto —sin entradas no hay límite seguro donde cortar—, y sólo se avisa
**por encima del umbral**: por debajo no se toca nada por diseño (CA-06) y avisar sería ruido en
cada parada.

### Corregido — el instrumento, otra vez: la idempotencia del bloque derivado se decidía por el reloj (QA-119)

**Qué fallaba:** el caso «CA-09 idempotente» comparaba **byte a byte** las dos pasadas del bloque
derivado, y el bloque se encabeza con la fecha y la hora **al minuto**. Si las dos pasadas cruzaban
un cambio de minuto, el caso fallaba sin que nada estuviera roto: QA lo midió **1 de 9** corridas
completas, y dos corridas del **mismo** árbol dieron `483 · 185 · 1` y `482 · 186 · 1`. **Es la
misma familia que QA-111** —un caso del banco que decide por reloj de pared—, sólo que allí el
reloj entraba como umbral de tiempo y aquí como contenido de la salida. **Por qué importa:** el
banco es la puerta **requerida** de `main`; un rojo aleatorio bloquea una fusión legítima y, peor,
enseña a re-lanzar el CI hasta que salga verde, que es como una puerta deja de significar algo.
**Qué cambia — en el banco, no en el bloque:** la hora **se queda** en `docs/ESTADO.md`, porque es
para la persona que lo lee; lo que se corrige es la comparación, que ahora **neutraliza** la línea
de la marca —sustituye su valor por un testigo— en lugar de fijar el reloj. Fijar el reloj obligaría
a interponer un `date` falso en el `PATH` del hook: mediría una plataforma que no es la de
producción y taparía cualquier otro uso de la fecha que apareciera después. Y no se **borra** la
línea, se neutraliza: la comparación sigue exigiendo que la cabecera esté y en su sitio, y **su
formato lo mide un caso propio**, porque neutralizar sin medir aparte es dejar de probar. Se añade
además el **cruce de minuto forzado** —se falsea la marca de la pasada anterior en vez de esperar
60 s— con un canario: byte a byte tiene que seguir dando «distintos», o el caso estaría en verde
por no medir nada. **Repasado el resto del banco:** de **16** comparaciones byte a byte (11 con
`cmp`, 5 por `md5sum`), ésta era la **única** que comparaba contra una salida regenerada con marca
de tiempo; las otras 15 comparan un archivo que **no debe cambiar** contra su copia previa, donde
no hay fecha que generar. Los otros dos usos del reloj en el arnés —la marca `ARNES:ROTADO` de los
dos rotadores— no los compara nadie byte a byte.

### Corregido — un temporal huérfano cuando al hook lo matan a mitad de la escritura (QA-118)

**Qué fallaba:** `estado-derivado` publica `docs/ESTADO.md` escribiendo primero un temporal y
moviéndolo encima, y desde SEC-011 el fallo que **devuelve error** —carpeta sin permiso, disco
lleno— borra el temporal y avisa. Faltaba la tercera forma de fallar: que al proceso lo **maten**
mientras escribe. Con un límite de tamaño de archivo (`ulimit -f`, SIGXFSZ) el intérprete moría
dentro del `printf` y ningún `rm` posterior llegaba a correr: medido, el hook salía **153** y dejaba
un `ESTADO.md.arnes.tmp` a medias **en silencio**, al lado del único archivo que sobrevive a la
pérdida de contexto. El destino quedaba intacto —eso ya estaba bien—, pero un artefacto huérfano
sin explicación es basura que alguien tendrá que interpretar justo cuando ya no queda contexto.
**Qué cambia:** un `trap` sobre `EXIT INT TERM XFSZ` limpia el temporal en la salida y en las
señales que la interrumpen. Y al **atender** SIGXFSZ la señal deja de ser mortal: `printf` devuelve
error, el `&&` no llega al `mv` —el destino sigue intacto— y la avería sale por el mismo camino que
las otras dos, con aviso propio y código de salida **0**, que es lo que el hook de parada promete:
nunca bloquear una parada, nunca callar la avería. Medido antes y después con la misma avería:
`iguales-1-no-153` → `iguales-0-si-0`. **Fuera de alcance, declarado:** los dos rotadores escriben
sus temporales con el mismo patrón y comparten esta debilidad ante una señal; viene apagada por
defecto y nadie la ha medido, así que queda anotada, no arreglada de paso.

### Pruebas
Banco: **683 casos** (310 antes de esta versión; 480 al cerrar la implementación, 569 con los
casos que añadió QA, 606 tras la vuelta 1, 615 tras la vuelta 2, 680 tras las vueltas 3 y 4, y 683
con los tres de la vuelta 5), **682 PASS · 0 FAIL · 1 SKIP** sobre la candidata y el cuadre de
`CASOS_ESPERADOS` cerrado. Contra la instalación estable **v1.30.3**, el mismo banco da
**494 PASS · 188 FAIL · 1 SKIP**: son los casos nuevos de comportamiento —fail-before/pass-after—,
entre ellos el de QA-118, que contra la línea base da exactamente el síntoma reportado
(`iguales-1-no-153`). Esa cifra de línea base es **reproducible**, y ésa es la prueba de que QA-119
está cerrado: **cinco corridas seguidas** dieron `494 · 188 · 1` las cinco, donde antes del arreglo
dos corridas del mismo árbol daban `483 · 185 · 1` y `482 · 186 · 1`. Los dos casos que añade la
vuelta 5 para QA-119 pasan **también** contra la línea base: corrigen el instrumento, no el hook.
Coste medido con `awk` y `jq` instrumentados en el `PATH` (Linux/WSL2): el camino común de `Bash`
(`ls -la`, `npm run build` por `guard.sh`) gasta **1 `jq`**, los mismos que v1.30.3 —eran **2**
antes de la vuelta 1, porque leer el manifiesto se había puesto por delante del corte temprano—;
un comando que **sí** menciona `git` cuesta 2, que es la lectura del manifiesto que la puerta
nueva necesita para saber si está encendida; una edición fuera de las rutas protegidas **baja**
de 3 a 2, y el cierre de un REQ de 1 `awk` a 0. En reloj, `ls -la` por `guard.sh` sobre 200
invocaciones: **23,1 ms → 19,0 ms** por invocación (v1.30.3: 13,7 ms en la misma máquina; el
resto no son procesos, es el intérprete cargando un guardián más). El coste real en Windows/MSYS,
donde un fork cuesta entre 1,2 y 6 s, **queda por medir antes de publicar**.

## [Interno] — 2026-09-05 · migración del andamiaje de este repo 1.30.2 → 1.30.3 (`arnes-upgrade`)
> Origen: Interno · usuario: Juan · modelo de IA: Fable 5.1 (coordinadora) · skill `arnes-upgrade` del plugin 1.30.3.

- Origen 1.30.2 **CONFIRMADO** (`.arnes/plantillas-origen/` idéntica a `v1.30.2:templates/`); destino 1.30.3 (instalación 6c1b58a, la actual). Ninguna plantilla cambia entre ambas: **nada que aplicar**. Plan en `.arnes/migracion.md`.
- `.arnes/plantillas-origen/` completada con las 3 plantillas que faltaban (ADR, DELIVERY, guard.test.ts), copiadas de la versión destino.
- `arnes_version` 1.30.2 → 1.30.3 (Fase 5, tras verificar). Aviso «Hacia 1.30.3» aplicado: `tools/arnes-lectura.sh` no muestra ningún REQ `completado` con veredictos pendientes.
- Primer uso real de la skill sobre un proyecto ya inicializado tras publicar: sirve de verificación de instalación/actualización de 1.30.3.

## [Interno] — 2026-09-05 · registro del ciclo 1 del autoalojamiento
> Origen: Interno (documentación de gobernanza) · usuario: Juan · modelo de IA: Fable 5.1 (coordinadora) · agente: sesión coordinadora.

- `docs/gobernanza/autoalojamiento.md`: la fila del ciclo 1 pasa a **publicado** (v1.30.3 sobre 6c1b58a, PR #31) y se abre la fila del ciclo 2 (1.31.0, guardián v1.30.3). Sin efecto en la máquina ni en lo que heredan los proyectos.
- `requirements/REQ-001.md`: `Estado: completado` (CA-44 cumplido: tag verificado, instalación estable en 1.30.3, cola vacía, ambos veredictos aprobados). Cierre aceptado por el guardián v1.30.2.

## [1.30.3] — 2026-09-05
### Corregido — dos bypass de v1.30.2, encontrados por una revisión externa
Los dos se reprodujeron **contra la instalación estable que gobernaba la sesión**, no sobre el
papel, y los dos son de la misma familia: la puerta miraba el FRAGMENTO o el TEXTO, y no lo que
iba a quedar escrito ni lo que el shell iba a ejecutar de verdad.

- **FALLO EN ABIERTO: un `Edit` que sustituía sólo el VALOR cerraba un REQ con QA pendiente.**
  Con la cabecera en `Estado: en-revisión` / `QA: pendiente`, un `Edit` con
  `old_string: en-revisión` y `new_string: completado` devolvía **ALLOW**. Desde 1.30.2 el hook ya
  reconstruía el documento resultante, pero **además** exigía que el fragmento contuviera
  «Estado: completado» antes de correr las puertas; el fragmento `completado` no lleva esa palabra
  en ninguna parte y el hook salía por arriba. Y sustituir el valor es la forma **más natural** de
  cerrar un REQ a mano, así que el agujero estaba justo donde más se pisa. Ahora, cuando hay
  documento, la transición se determina **sólo con el documento**: hay transición si la cabecera en
  disco no decía el estado terminal y la resultante sí. El análisis del fragmento queda **sólo**
  como respaldo para un `Edit`/`MultiEdit` cuyo `old_string` no está en el archivo —la herramienta
  fallará entera y no escribirá nada—.
- **FALLO EN ABIERTO: una sustitución de comandos dentro de un heredoc SIN CITAR escribía código
  protegido sin que ninguna puerta la viera.** `cat <<EOF` / `$(echo x > src/generated.ts)` / `EOF`
  crea el archivo de verdad —bash expande el cuerpo—, pero el detector de escrituras descontaba
  **todo** el cuerpo del heredoc como texto desde 1.30.2. La corrección distingue lo que el shell
  distingue: con delimitador **citado o escapado** (`<<'EOF'`, `<<"EOF"`, `<<\EOF`) el cuerpo es
  literal y se descuenta entero, como hasta ahora; **sin citar**, se conservan y se analizan sólo
  las líneas con `$(` o con acentos graves, y el resto sigue siendo texto. Convertir el cuerpo
  entero en comandos habría devuelto el falso positivo de 1.29.1 —un resumen en heredoc con
  `cp README.md src/…` como texto—, así que no se hace. De paso, los paréntesis de la sustitución
  se retiran al tokenizar, para que el destino de `$(echo x > src/a.ts)` quede como un operando
  limpio y no como `src/a.ts)`, que no casaría con ningún glob. Todo con expansión de parámetros:
  **cero procesos nuevos** en un camino que recorre cada comando que ejecuta un agente.
  Queda escrito en el código lo que sigue fuera: una sustitución que abre en una línea y cierra en
  otra, y el resto de la cobertura parcial de Bash (`AGENTS.md` §13).

**Y un falso positivo del mismo camino, medido mientras se redactaba el requerimiento:** un `Write`
cuyo **cuerpo** citaba `Estado: completado (…)` dentro de un criterio era denegado, porque por esa
vía la transición se buscaba en todo el contenido en vez de en la cabecera. Un `Write` trae el
documento completo, así que ahora es su propio resultante y se juzga por su cabecera, igual que un
`Edit` reconstruido. Los **veredictos** de un `Write` se siguen leyendo con la precedencia estricta
de siempre (entrante sobre disco): quien borre la línea `QA:` no se libra del veredicto que hay en
disco.

Treinta y cuatro casos nuevos en el banco (230). Caso 1, sobre el documento resultante: el bypass y
su motivo, con `MultiEdit`, con `replace_all`, sobre un archivo CRLF, con la cola de aprobaciones
abierta y con una quality gate roja; el estado terminal tomado del manifiesto (`hecho`) y su
control; el respaldo por fragmento vivo (`Write`, `old_string` ausente); un REQ que no existe en
disco (sin traza de bash); y los controles que no pueden estorbar —todo en verde, la cabecera ya
cerrada, reabrir un REQ, y el `Write` que sólo cita el estado—. Caso 2, sobre el heredoc: la
sustitución, los acentos graves, `<<-` con sangría y un heredoc sin delimitador de cierre; y los
controles citado, escapado, entrecomillado, la expansión inocente, el texto literal, el
desarrollador autorizado, la here-string y la aritmética; más uno de rendimiento —10 000 líneas de
cuerpo por debajo de 5 s— porque este camino lo paga cada comando.

Cada caso de bypass trae su par **fail-before / pass-after**: falla contra los hooks de v1.30.2 y
pasa contra los de la candidata. Un caso que pasa antes del arreglo no prueba nada.

### Corregido — el primer arreglo del heredoc abría tres agujeros nuevos (vuelta 1 de QA)
La validación no aprobó: los dos bypass declarados estaban cerrados y medidos, pero **conservar la
LÍNEA ENTERA** del cuerpo que llevara una expansión metía en el análisis texto que bash nunca
ejecuta. Tres consecuencias, las dos primeras de la misma familia que este arreglo venía a cerrar:

- **FALLO EN ABIERTO: una comilla impar del cuerpo desarmaba el comando real.** El descuento de
  texto entrecomillado emparejaba comillas sobre **todo** el comando, y una comilla suelta de una
  línea conservada (`$(date) don't`) se emparejaba con la primera comilla del comando que iba
  **después** del cierre del heredoc, borrando lo que hubiera en medio: la redirección se evaporaba
  del texto analizado. `cat <<EOF` / `$(date) don't` / `EOF` / `echo x > src/robado.ts && echo 'listo'`
  daba **allow** —y el shell creaba el archivo—, con acentos graves igual, y también por la puerta
  del cierre de un REQ (`sed -i` sobre `requirements/`). La asimetría era exacta: dentro del cuerpo
  esas comillas son **texto** y no abren ni cierran nada, y el detector las leía como sintaxis.
- **FALLO EN ABIERTO POR AGOTAMIENTO DE TIEMPO.** El descuento reconstruía la cadena entera por
  cada par de comillas: coste **cuadrático** sobre el cuerpo conservado. Medido con líneas
  `$(date) 'x' "y"`: 500 líneas → 5,5 s; 1.000 → 40 s; 1.500 → sin respuesta en 65 s. Un hook
  `PreToolUse` muere a los 60 s y **un hook muerto no deniega**: el propio coste era un bypass.
- **Falso positivo devuelto:** al conservar la línea entera, `ver $(date) y luego cp README.md
  src/x.ts` se denegaba sin que nada copiara nada — el defecto de 1.29.1 por otra puerta.

**La corrección cambia la frontera.** Del cuerpo sin citar ya no se conserva la línea, sino **sólo
el interior de cada `$( … )` y de cada par de acentos graves**, que es exactamente lo que el shell
ejecuta; el resto de la línea vuelve a ser texto. Cada fragmento se **desentrecomilla por separado**
y se une a los demás con `;`, que el tokenizador ya trata como separador, así que ni una comilla ni
un operando de un fragmento pueden cruzar a otro ni al comando real: la asimetría desaparece por
construcción, no por un caso especial. Y el descuento de comillas dejó de reconstruir la cadena: se
consume el prefijo y se acumula en un buffer, con el texto acotado por fragmento. Resultado medido
en Linux/WSL2 con el mismo cuerpo: 500 líneas → 110 ms, 1.000 → 211 ms, 1.500 → 211 ms (antes,
>65 s), 5.000 → 511 ms. Coste **lineal**, y **cero procesos nuevos**: todo sigue siendo expansión de
parámetros. Dentro de una expansión las comillas siguen siendo sintaxis, como en el shell real.
Queda escrito en el código lo que sigue fuera de alcance: el escapado (`\$(`), el anidamiento, y una
sustitución multilínea, de la que se ve el comando que la abre pero no lo que siga debajo.

El banco pasa de 246 a **253 casos** (los siete nuevos, marcados `# DEV REQ-001 v2:`): el cruce de
comillas entre dos fragmentos del mismo cuerpo, el destino de un `cp` que no puede cruzar al
fragmento siguiente, el falso positivo con la mención textual **delante** de la expansión, el par
comillas-dentro-de-la-expansión con su control, la sustitución que abre en una línea y cierra en
otra, y el camino caro con el **triple** de cuerpo (5.000 líneas): un umbral que sólo se cumple en
el tamaño exacto que denunció el defecto no acredita que el coste dejó de ser cuadrático, sólo que
se movió el punto de ruptura. **253: 252 PASS · 0 FAIL · 1 SKIP** (el SKIP es de Windows) contra la
candidata, y **229 PASS · 23 FAIL · 1 SKIP** contra v1.30.2. Los casos de regresión de esta vuelta
pasan en **las dos** versiones —son conducta que no debía cambiar—; los de bypass siguen fallando
sólo contra v1.30.2.

> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 · agentes: `analista-requerimientos`
> (requerimiento), `desarrollador` (código, banco y bitácora) y `qa-tester` (validación, los tres
> hallazgos de esta vuelta y las correcciones del banco: reloj en milisegundos, emisor por STDIN y
> guarda de JSON vacío). `auditor-seguridad` (revisión de seguridad del árbol ya validado: `Seguridad: aprobado`, siete
> hallazgos preexistentes de clase `instrumento` derivados a REQ-007 y las limitaciones del detector
> escritas en `docs/seguridad/`). Coordinación: sesión principal (Fable 5.1); QA con Opus por
> decisión del propietario. Tres vueltas dev↔QA (tope de §6 alcanzado en la tercera, aprobada).

### Corregido — vuelta 2 de QA: el coste cuadrático no había desaparecido, había cambiado de eje
La validación volvió a no aprobar, y con razón. El descuento **por fragmento** de la vuelta 1 hizo
el coste lineal en el **número de líneas** del cuerpo (1.500 líneas: >65 s → 209 ms), pero **dentro
de una línea** los dos bucles nuevos seguían avanzando con `${r#*…}`, y cada avance **copia el resto
de la cadena**. Medido de punta a punta con una sola línea de cuerpo y N sustituciones `$(date)`
más una escritura real fuera del heredoc: N=2.000 → 1,3 s; **N=4.000 → 5,1 s, por encima del umbral
de 5 s que fija el propio requerimiento**; N=8.000 → 18,0 s; **N=16.000 (112 KB) → el hook no
responde en 60 s, muere, `guard.sh` recibe salida vacía y PERMITE** — y el shell crea el archivo.
Doblar la entrada cuadruplicaba el tiempo: cuadrático, medido, en el tamaño de una línea.

**El arreglo quita la copia por paso, no la reduce.** El texto se **parte una vez** —troceado por
`IFS`, que bash hace en C y en una pasada— y los trozos se vuelven a unir **una vez** con
`${a[*]}`: el descuento de comillas conserva los trozos pares (lo de fuera de comillas) y el
extractor de expansiones toma, de cada trozo, su prefijo hasta el primer `)`. Los prefijos son
disjuntos, así que el total es lineal. Nada más cambia de criterio: con un número impar de comillas
la última sigue sin cerrar nada y se conserva tal cual, y los fragmentos siguen sin poder cruzarse.
Medido con la misma entrada: N=4.000 5,1 s → **410 ms**; N=8.000 18,0 s → **814 ms**; N=16.000
sin respuesta → **212 ms**. **Cero procesos nuevos**: sigue siendo expansión de parámetros, `IFS` y
arrays. El camino común (un comando sin `<<`) mide lo mismo que antes y que en v1.30.2 —200
invocaciones: 23,7 s / 24,1 s / 23,9 s—, indistinguible. De regalo, la misma raíz arregla el camino
común cuando lleva muchas comillas, que era deuda anterior a este arreglo: 32 KB de comillas
10,5 s → **209 ms**; 64 KB 39,5 s → **313 ms**.

**Y un presupuesto de tamaño, porque un algoritmo lineal también tiene acantilado.** Basta una
entrada cien veces mayor para volver a los 60 s, y un hook muerto no deniega: el fallo en abierto
por agotamiento no se arregla siendo más rápido, se arregla **no aceptando lo que no se puede medir
a tiempo**. Por encima de **64 KiB de MATERIAL ANALIZADO** el hook no analiza y **deniega**
diciendo cómo salir (heredoc citado, archivo de script, o partir el comando). Lo que se mide es
exactamente: (a) los bytes de las líneas del cuerpo de un heredoc **sin citar** que llevan `$( )` o
acentos graves —lo único del cuerpo que el shell ejecuta— y (b) los bytes del texto del comando
fuera de los cuerpos. **No** se mide el tamaño del comando: un `cat > archivo <<'EOF'` de 300 KB con
el delimitador citado es la forma normal de escribir un archivo grande, su cuerpo se descuenta
entero sin analizarse y sigue en `allow` **y barato** (512 ms medidos), con caso de banco que lo
fija. El valor sale de medir el peor caso por byte: 64 KiB de cuerpo denso en `$( )` se resuelven
en **0,71 s**, frente al tope de 2 s que se fijó para el tamaño máximo admitido y a los 60 s en que
el hook muere; el doble ya cuesta 1,8 s. La denegación por tamaño **no** alcanza al agente de
código por la puerta de `guard-codigo` —a él ya se le permitía escribir—, y sí alcanza a todos por
`guard-completado`, porque la regla que ese guardián aplica también alcanza a todos. `.arnes/config.json`
puede **subir** el techo con `limites.bash_max_analisis`; no puede bajarlo, porque el defecto se
aplica sin leer el manifiesto y leerlo costaría un proceso en el camino que recorre **cada**
comando. **La clave es opcional y NO está en la plantilla del manifiesto**, a propósito: tocar una
plantilla convertiría esta versión en una migración de andamiaje para todos los proyectos, y este
parche debe quedar como «nada que migrar». El valor por defecto vive en el código; quien necesite
subirlo lo añade a mano a su `.arnes/config.json`, y la plantilla lo recogerá cuando una versión
futura toque el manifiesto por otro motivo. Queda documentada en la skill `arnes-upgrade`
(«Migraciones conocidas → Hacia 1.30.3»), junto con los cinco cambios de conducta de esta versión
y los de 1.30.1 y 1.30.2, que faltaban.

**Y un falso positivo menos:** `\$(…)` escapado en el cuerpo se denegaba aunque bash no ejecuta
nada. Se cuenta la barra invertida por **paridad**, que es la única lectura correcta —`\$(` no
ejecuta, `\\$(` sí—, con sus tres casos. Los acentos graves **no** reciben ese trato, a propósito
y por escrito: un acento escapado cambia la pareja de todos los demás y equivocarse ahí produce un
falso **negativo**; se prefiere el falso positivo.

El banco pasa de 271 a **288 casos** (17 nuevos, `# DEV REQ-001 v3:`): el eje de QA-007 en el tamaño
que antes mataba al hook, con su control; la frontera del presupuesto **al byte** (65.507 se analiza
y nombra la ruta, 65.508 deniega por tamaño y explica la salida); los 300 KB citados y los 300 KB
sin citar sin expansiones, con el control positivo que descarta que un `allow` sea un hook muerto;
4.000 líneas justo por debajo del techo, que exigen que el motivo **nombre la ruta** y así acreditan
análisis real y no atajo; el presupuesto por la puerta de `guard-completado`; la clave del manifiesto
en sus tres formas (subir, no poder bajar, y errata que no desactiva nada); y los tres del escapado.
**288: 287 PASS · 0 FAIL · 1 SKIP** contra la candidata (tres corridas idénticas), **249 · 38 · 1**
contra v1.30.2 y **282 · 5 · 1** contra el árbol de la vuelta 1 —ahí fallan el caso de QA-007 y
cuatro míos: el par fail-before/pass-after. Un defecto del banco encontrado de paso: `cronometra_bash`
estaba definida **dentro** de una sección, y cada sección corre en su propio subshell, así que al
usarla desde otra los casos no fallaban, **no se ejecutaban**; sólo el cuadre de `CASOS_ESPERADOS`
lo delató. Vive ya junto a `check` y `check_motivo`.

> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 · agentes: `desarrollador` (código,
> banco, plantilla y bitácora) y `qa-tester` (hallazgo QA-007 y las mediciones que lo acreditan).
> Validación y auditoría de seguridad pendientes: el REQ sigue `en-revisión`.

### Corregido — vuelta 3 de QA: el recorte que compró la linealidad cortaba en el `)` equivocado
La validación tampoco aprobó, y esta vez el hallazgo no era de reloj sino de **cobertura**. El
extractor de expansiones tomaba de cada trozo **el prefijo hasta el primer `)`**, sin mirar comillas
ni anidamiento, así que **todo lo que siguiera a ese `)` dentro de la misma sustitución desaparecía
del análisis — incluida la redirección**. Tres formas corrientes salían `allow`, y las tres **crean
el archivo en un shell real**:

```
$(cat "$(ls README.md)" > src/a.ts)    el ) de la sustitución INTERIOR trunca
$(echo "a)b" > src/a.ts)               el ) va dentro de comillas
$(echo "(hola)" > src/a.ts)            paréntesis literal entrecomillado
```

No es limitación heredada: **el árbol anterior al primer arreglo de esta misma versión las denegaba
las tres**, porque allí se conservaba la línea entera. Era una pérdida de cobertura introducida por
el propio trabajo, y el comentario del código afirmaba del anidamiento «es más cobertura, nunca
menos» — medido, era menos. Ese comentario también se corrige.

**El cierre de un fragmento se decide ahora por PROFUNDIDAD de paréntesis, no por el primer `)`,
contando sólo los paréntesis que no están entrecomillados.** Comillas y profundidad se resuelven en
la **misma pasada**, porque el orden contrario es imposible: para saber qué comillas descontar hace
falta saber dónde acaba el fragmento, y para saber dónde acaba hace falta haber descontado las
comillas. La línea se marca una vez con unas pocas sustituciones `${s//x/y}` —cada una una pasada de
bash en C— y se parte **una vez** en «átomos»: cada átomo es un carácter con significado (`\`, `$(`,
`(`, `)`, `"`, `'`) seguido del texto que va detrás. El recorrido toca cada átomo exactamente una
vez y el texto del fragmento se acumula en un **array** que se une al cerrar; nunca se concatenan
cadenas, que es copiar, y copiar dentro de un bucle fue justo lo que hizo cuadrática a la versión de
la vuelta 1. **Coste lineal, cero procesos nuevos**: sigue siendo `IFS`, expansión de parámetros y
arrays. Si la profundidad nunca vuelve a cero —una sustitución que no cierra en su línea— el
fragmento es el resto de la línea, que es la lectura fail-closed y la que ya se aplicaba.

**Las comillas sólo son sintaxis DENTRO de la sustitución, y eso no es un detalle de implementación:
es lo que hace bash.** En el cuerpo de un heredoc sin citar una comilla es texto —`don't $(cp
README.md src/a.ts)` ejecuta el `cp`—, mientras que dentro de `$( )` el shell reinterpreta como
comando. Por eso el estado de comillas nace vacío al abrir cada fragmento y muere al cerrarlo: no
cruza de un fragmento a otro ni contagia al texto de alrededor. Con una comilla **impar** —la que no
cierra nunca— se conserva lo que va detrás, tal cual: no se inventa un cierre que no hay, y lo que
no se puede descontar se analiza.

**La misma revisión destapó un `)` más que tampoco cerraba: el escapado.** La paridad de la barra
invertida sólo se aplicaba a `$(`, así que un `\)` —un paréntesis **literal**, que no cierra nada—
partía el fragmento antes de tiempo y se llevaba la redirección por delante. Verificado en un
sandbox real: `cat <<EOF` / `$(echo \) > src/x.ts)` / `EOF` **crea el archivo** y el hook decía
`allow`. Es la misma familia que el hallazgo, encontrada al escribir el arreglo, y se cierra en el
mismo sitio: la paridad vale ahora para **todos** los caracteres con significado, no sólo para `$(`.
Su control obligatorio —el mismo `)` **sin** barra, que sí cierra y deja lo de detrás como texto—
sigue en `allow`.

**Lo que no cambia, y hay caso para cada cosa:** el texto que sigue al cierre **real** sigue siendo
texto (`$(date) (texto) cp README.md src/x.ts` → `allow`), que es lo que impide «arreglarlo»
volviendo a analizar la línea entera y devolver el falso positivo de 1.29.1; los acentos graves
siguen leyéndose por **parejas** y sin interpretar el escapado, con su límite escrito; y `\$(` sigue
siendo texto.

Medido de punta a punta, con canario positivo y negativo antes de cada tanda y `timeout` duro
(Linux/WSL2): el peor caso **justo por debajo del presupuesto** —65.400 bytes con 21.800 `$()` más
una escritura real— tarda **2,1–2,2 s** y deniega, frente al umbral de 5 s y al techo de 60 s en que
el hook muere; una línea con 8.000 `$(date)` (56 KB) **1,0 s**; con 16.000 (112 KB) **218 ms**, por
presupuesto; 20.000 líneas de cuerpo (320 KB) **1,3 s**, por presupuesto; 4.000 líneas justo bajo el
techo **1,1 s** analizando y nombrando la ruta. El camino común —el que recorre cada comando de cada
agente— sigue **indistinguible**: 100 invocaciones seguidas, **95 ms/invocación en la candidata
frente a 90 ms en v1.30.2**, que es el arranque de bash y no el análisis; y con muchas comillas
(64 KB) la candidata deniega en 316 ms donde v1.30.2 no responde en 30 s y **permite**. La población
legítima no se toca: heredoc citado de 300 KB `allow` en 422 ms, sin citar y sin expansiones `allow`
en 424 ms, y el control con una escritura real detrás sigue en `deny` en 527 ms.

**Y el `deny` por tamaño ya dice cuánto.** Explicaba que el comando supera el presupuesto y daba
tres salidas, pero no el **número**, así que quien lo recibía tenía que adivinar por dónde partir.
Ahora el motivo dice el presupuesto **vigente** en bytes —el efectivo, no una constante escrita en
el mensaje: si el manifiesto lo sube con `limites.bash_max_analisis`, el mensaje sube con él— en las
dos puertas. El techo se vuelve a resolver en el guardián porque el detector corre dentro de una
sustitución de comandos, o sea en un subshell, y lo que memorice allí no vuelve; es un `jq` en el
camino de la **denegación**, que ya no es el camino común.

El banco pasa de 295 a **303 casos** (8 nuevos, `# DEV REQ-001 v4:`): las cuatro esquinas de la
regla de profundidad —anidada con la escritura en el interior, un `)` entre comillas **simples**,
paréntesis que nunca cierra con una escritura detrás, y el reverso obligatorio, `(texto)` tras el
cierre real como texto—, el `)` escapado con su control, y el motivo del `deny` por tamaño con el
número, en las dos puertas.
**303: 302 PASS · 0 FAIL · 1 SKIP** contra la candidata (tres corridas idénticas: dos en paralelo y
una secuencial) y **253 · 49 · 1** contra v1.30.2, las dos cuadrando con `CASOS_ESPERADOS`. Los tres
casos rojos del hallazgo y seis de los ocho nuevos **fallan** contra v1.30.2 y pasan contra la
candidata; los otros dos son controles positivos y pasan en las dos. Y los **únicos dos** casos con
`esperado=allow` que fallan contra v1.30.2 siguen siendo los dos cambios de conducta ya declarados:
ni uno más.

> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 · agentes: `desarrollador` (código,
> banco y bitácora) y `qa-tester` (hallazgos QA-015 y QA-016 y las mediciones que los acreditan).
> Validación y auditoría de seguridad pendientes: el REQ sigue `en-revisión`.
### Autoalojamiento — el arnés se instala sobre sí mismo
El repositorio queda inicializado con su propio andamiaje (`arnes-init`, plantillas de 1.30.2):
`AGENTS.md`, `CLAUDE.md`, `.arnes/config.json` (con `hooks/`, `tools/` y `.github/` como código
protegido), `requirements/`, `PENDING_APPROVAL.md`, `docs/ESTADO.md`, `ARCHITECTURE.md`,
`.arnes/plantillas-origen/` y el `pre-commit`. El procedimiento permanente está en
`docs/gobernanza/autoalojamiento.md`: **la versión estable N gobierna el desarrollo de N+1**.
Medido antes de editar: la instalación que corre los hooks es 1.30.2 (38b59fb), en
`~/.claude/plugins/cache/…/1.30.2`, byte a byte igual al tag y distinta del worktree; un `Write`
de la coordinadora sobre `hooks/` fue denegado por ella.

## [1.30.2] — 2026-09-05
### Corregido — tres fallos medidos por tres revisores distintos el mismo día
- **FALLO EN ABIERTO: un MultiEdit cerraba el REQ aprobando sólo la línea del historial.** La regla
  de 1.30.0 —los campos valen sólo en la cabecera— se aplicaba a los `new_string` **concatenados**, y
  el `## ` que separa cabecera de historia se quedaba en el disco: el fragmento del historial se leía
  como cabecera. Reproducido: `Estado: completado` + `Seguridad: aprobado (A-009)` sobre la línea
  histórica → **ALLOW** con la cabecera en `pendiente`. El hook **reconstruye ahora el documento
  resultante** aplicando cada edición al texto en disco —lo mismo que hará la herramienta— y lee la
  cabecera de ahí. Una sola regla para Edit, MultiEdit y `replace_all`; si un `old_string` no está en
  el archivo la herramienta fallará entera y no escribirá nada, y entonces se leen los fragmentos como
  antes. De paso, una línea de historia `Estado: completado (revertido)` ya no hace correr las puertas
  sobre un REQ cuya cabecera sigue en revisión. Descartada la alternativa de prohibir MultiEdit:
  castiga al que edita bien.
- **`tools/arnes-lectura.sh` siempre salía 0.** `avisa` se llamaba dentro de `$( … )` y el contador
  moría en el subshell: el informe decía *«Ningún valor anómalo»* con cuatro REQ fuera del vocabulario
  en un proyecto real. Un informe que siempre dice que todo está bien es peor que no tenerlo. El texto
  se acumula ahora con `printf -v` en el proceso padre. Además la comparación con el vocabulario era
  por prefijo (`|aprobad` casaba con `|aprobado`); es exacta.
- **Falso positivo: el cuerpo de un heredoc se leía como comando.** Un resumen en heredoc con la
  línea `cp README.md src/…` **como texto** era denegado. Reproducido con `cp`, con `>` y con `tee`
  dentro del cuerpo. El cuerpo se descuenta igual que lo entrecomillado, sin procesos y antes que las
  comillas (el delimitador puede ir entrecomillado). Sólo cuenta como heredoc `<<`/`<<-` seguido de una
  palabra: `<<<` es here-string y `1<<2` aritmética, y un delimitador que no fuera palabra tragaría el
  resto del comando —fallo abierto—.

Catorce casos nuevos en el banco (196): el bypass —también sobre un archivo CRLF— y sus dos controles; los tres cuerpos de heredoc y
cuatro controles positivos (un `cp` tras el cierre, la redirección en la propia línea del heredoc, una
here-string y la aritmética `$((1<<n))`); y tres del informe (sale 1 y nombra el valor, cuenta 1, control en 0).

## [1.30.1] — 2026-09-05
### Corregido — dos bordes que la optimización de 1.29.3 introdujo
Los encontró una revisión externa **comparando 1.29.2 con 1.29.3 archivo por archivo**, que es la
forma de encontrar lo que una mejora de rendimiento rompe sin que nada falle. De paso midió el
cambio en Linux: **747 ms → 44 ms** sobre ~3,5 MB, ~17×, con el mismo hash de salida una vez
retiradas hora y versión.

- **Un `.md` vacío desaparecía del conteo.** `awk` no emite nada para un archivo sin líneas, así
  que ya no contaba como *«archivo sin `Estado:`»* — 1.29.2 decía 1, 1.29.3 decía 0. Se cuenta antes
  de pasar a `awk`, como antes.
- **`umbral_bytes` medía caracteres.** Al sustituir `wc -c` por `${#texto}` la cuenta pasó a ser de
  caracteres: un UTF-8 de 4 032 bytes y 2 032 caracteres con umbral 3 000 rotaba antes y dejó de
  rotar. Yo lo había anotado como *«aceptable»*; el campo se llama `bytes` y tiene que medir bytes.
  `LC_ALL=C` sólo para la cuenta, y se restaura.

Un caso por borde. El patrón que el revisor nombra —cada ceguera real se vuelve regresión
permanente— es deliberado, y esta versión son dos más.

## [1.30.0] — 2026-09-05
### Corregido — FALLO EN ABIERTO: una línea de historia se leía como el veredicto
Los campos del REQ se leían en **todo** el archivo, y cuando un campo aparecía dos veces ganaba la
**última**. Un REQ que documenta su propia historia dentro del archivo —como los de 244 KB de un
proyecto real— tiene líneas de log a columna cero. Medido:

```
cabecera: Seguridad: pendiente · REQ crítico · intenta cerrar
  historia: Seguridad: aprobado (A-009, 2026-09-02)   ->  ALLOW   *** cierra con la cabecera en pendiente ***
  historia: Seguridad: aprobado                       ->  ALLOW
  historia: Seguridad: aprobado (A-009) — texto       ->  DENY    (por accidente: el texto detrás impedía normalizar)
  historia: - Seguridad: aprobado (A-009)             ->  DENY    (viñeta, no columna cero)
```

**Es la familia de `**sí**`:** la máquina lee algo distinto de lo que la cabecera declara. Y la forma
que se cuela es exactamente la que un historial usa —veredicto, referencia, fecha—.

**La regla que lo cierra es estructural, no un nombre de sección.** Los campos valen **sólo en la
cabecera: antes del primer `## `**. Es lo que la plantilla siempre dijo; ahora lo dice la máquina, en
los tres lectores a la vez —la puerta (`arnes_campos_req`), el bloque derivado (`campos-req.awk`) y
el informe (`arnes-lectura.sh`)— para que no se desfasen. Un fragmento de `Edit` sin `##` se sigue
leyendo entero. Y como consecuencia, **rotar la historia de un REQ es seguro por construcción**: nada
de lo que haya en una sección puede tocar lo que la máquina decide.

**El banco fijaba lo contrario hasta ayer.** 1.29.3 añadió *«campos a 200 líneas de la cabecera se
encuentran igual»* porque eso hacía el código. Se da la vuelta y se dice: certificar lo que el código
hace no es certificar lo que debe hacer.

### Al migrar
Corre `tools/arnes-lectura.sh` y mira dos cosas: REQ cuyos veredictos vivan **debajo** de un `##`
(hay que subirlos a la cabecera; hasta hoy se leían, desde hoy no), y REQ cuya historia tenga líneas
`Campo:` a columna cero (hasta hoy se leían como veredicto; desde hoy no, y conviene saber si alguno
cerró así).

## [1.29.3] — 2026-09-05
### Gobernanza — el CI es puerta de `main`
`proteger-main` exige desde hoy que `hooks-en-linux` esté verde y la rama al día. Aplicado con la
cuenta admin vía `gh auth switch` y verificado releyendo el ruleset. **Un PR rojo ya no se puede
fusionar.** No cambia el plugin; cambia quién decide si algo entra en `main`: el banco.

### Corregido — el bloque derivado costaba 92 segundos por parada en un proyecto real
**Medido en un proyecto real, con el control de plataforma hecho** (`bash -c true` = 2,4 s allí):
`stop.sh` **125 s por turno**, de los que **92 eran la continuidad** y 12,6 la rotación *sin nada
que rotar*. Reproducido aquí con un fixture del mismo tamaño —47 REQ, 3,7 MB, uno de 231 KB—:
**126 818 ms**.

**La causa:** el bloque recorría cada REQ **línea a línea en bash, dos veces** (una para
`Estado:`, otra dentro de `arnes_campos_req`). Con REQ de cinco líneas, como los del banco, eso son
microsegundos. Con 244 KB son decenas de miles de iteraciones por archivo, en cada parada, dos
veces por turno. **El banco no lo vio porque sus artefactos no tienen tamaño.** Es la tercera vez
que el banco certifica la corrección y no ve el coste; la lección es la misma que con el CRLF y con
el `if`: lo que no se ejecuta en condiciones reales, no se ve.

**El arreglo:** los seis campos de **todos** los REQ se extraen en **una sola pasada de `awk`**
(`hooks/campos-req.awk`) y bash normaliza 47 líneas cortas por **el mismo camino que la puerta**
—`arnes_campos_normaliza`, compartida con `arnes_campos_req`, para que dos normalizadores no se
desfasen—. Semántica conservada byte a byte: `Estado:` primera aparición, los demás última, como
hacían los bucles. Y la rotación deja de pagar un `wc -c` por artefacto.

| | antes | después |
|---|---|---|
| 47 REQ grandes, misma máquina cargada | 126 818 ms | **23 033 ms** |
| salida | `47 — completado 15 · en-revisión 32` | **idéntica** |

Lo que queda son **unos ocho procesos** —bash, `jq`, `awk`, `git`— en una plataforma donde cada uno
cuesta 1-4 s. Ése es el suelo, no el hook; se puede bajar a la mitad juntando llamadas, y queda
apuntado.

**El banco tiene ahora tamaño:** cuatro casos sobre un fixture de 3,7 MB, incluido un REQ con sus
veredictos a doscientas líneas de la cabecera, que se encuentran igual.

**Si apagaste la continuidad por coste, vuelve a encenderla y mide.** Y la observación de fondo que
esta medición deja sobre la mesa: **un REQ de 244 KB documenta su propia historia dentro del archivo**,
y eso lo paga cualquier agente que lo lea, no sólo el hook. El arreglo estructural es rotar la
historia del REQ como se rota el CHANGELOG. Queda diseñado, no construido.

## [1.29.2] — 2026-09-05
### Corregido — la contención de rutas era léxica; ahora es física
1.29.0 bloqueaba `..`, absolutas y `~`. Una revisión externa reprodujo en 1.29.1 que un **enlace
simbólico** `docs -> /externo` con `estado_derivado.archivo: docs/ESTADO.md` escribía fuera del
proyecto, y la rotación tocaba un archivo externo a través de un directorio enlazado. La cadena
parecía interna; el disco no. *«No pueden salir del proyecto»* era demasiado absoluto.

Ahora, además de la regla léxica, **el directorio destino se resuelve físicamente** con `pwd -P`
—POSIX, resuelve enlaces— y tiene que quedar dentro de la raíz también resuelta. Se comprueba el
directorio y no el archivo: el archivo puede no existir aún, y uno enlazado se escribe donde apunte
su directorio. Cuesta dos subshells, que se pagan sólo en una parada de agente.

**Los casos del banco que lo fijan salen `SKIP` en Windows** —sin modo desarrollador `ln -s` no
crea un enlace real— **y corren de verdad en el CI de Linux.** Es la primera vez que un caso existe
*porque* hay CI: sin él no habría dónde ejecutarlo.

### Pendiente del dueño del repo — el CI aún no es puerta de `main` *(resuelto el mismo día; ver 1.29.3)*
El ruleset `proteger-main` no exige `hooks-en-linux`; un PR rojo se puede fusionar. Editarlo exige
admin, y la cuenta que opera el arnés tiene `push` pero no `admin`: la API devuelve 404. El
procedimiento exacto y la regla en JSON están en `docs/gobernanza/ci-como-puerta.md`. Hasta
entonces el CI **informa pero no impide**, y está escrito así.

## [1.29.1] — 2026-09-05
### Corregido — el banco tenía un caso que desaparecía en Linux, y el CI lo cazó en su primer viaje
El primer run del banco fuera de Windows abortó con **«168 casos y se esperaban 169»**: el mismo
hueco que el revisor había medido como 161 de 162. El caso «ruta estilo Windows con backslashes»
va dentro de `if command -v cygpath`, y en Linux no hay `cygpath`: **el caso no fallaba,
desaparecía**, y un caso ausente se lee igual que uno que pasó. Es exactamente lo que el cuadre de
casos existe para cazar, y lo cazó en 6 segundos.

**El banco tiene ahora tres estados.** Un caso que no puede correr en esta plataforma imprime
`SKIP` con el motivo, y el cuadre suma `PASS + FAIL + SKIP`. Saltarse un caso por plataforma es
legítimo; que no se vea, no.

**Y el dato que este run dejó medido:** los mismos 169 casos tardan **24 minutos en Windows y 6
segundos en Linux**. Es el coste de crear procesos en esta plataforma, en una sola cifra. Sólo
cambia el banco: el plugin es el de 1.29.0.

## [1.29.0] — 2026-09-05
Cuatro hallazgos de una revisión externa que leyó el código de 1.28.0. Tres verificados y
corregidos; el cuarto es una decisión de política y queda abierto, dicho aquí.

### Corregido — en Unix NINGÚN hook se ejecutaba
`guard.sh` y `stop.sh` —los dos puntos de entrada que `hooks.json` invoca— estaban en el índice
como `100644`. En Linux o macOS, Claude Code intentaba ejecutarlos, recibía *Permission denied* y
**seguía adelante**: todo el enforcement apagado, en silencio. También `estado-derivado.sh`,
`rotar-artefactos.sh`, `tools/arnes-lectura.sh` y la plantilla del `pre-commit`, que al copiarse
sin bit deja de exigir el CHANGELOG.

**Nadie lo vio porque los tres que probamos el arnés estamos en Windows**, donde el bit no
existe. Lo encontró una revisión externa; lo fija un CI en `ubuntu-latest` que comprueba el modo
de cada punto de entrada como propiedad cerrada y corre el banco entero. Es la primera vez que
el arnés se ejecuta fuera de Windows.

### Corregido — `Rigor: ligero` saltaba las puertas, no sólo los veredictos
La plantilla promete que `ligero` corre *«analista + desarrollador + quality gates»*. El código
hacía `return 0` **antes** de la clase del hallazgo, de las aprobaciones humanas pendientes y de
las quality gates: un REQ `ligero` cerraba con el build en rojo y con una decisión humana sin
tomar. Deriva mía desde 1.19.0: la máquina hacía menos de lo que el papel decía.

Ahora `ligero` salta **exactamente** los veredictos de QA y seguridad. Las tres puertas corren
igual. Cuatro casos lo fijan, incluido el control positivo de que sigue saltando lo que debe.

### Corregido — una ruta del manifiesto podía salir del proyecto
`estado_derivado.archivo` y las `ruta` de la rotación se concatenaban a la raíz tal cual: con
`"archivo": "../fuera.md"` el hook de parada escribía **fuera del repositorio** en cada parada.
El manifiesto también lo puede escribir un agente, y `guard-codigo` no lo protege.

Regla cerrada, sin forks: relativa, sin `..` como segmento, sin `~`, sin barra invertida. Lo que
no sea una ruta POSIX relativa limpia no se escribe ni se toca, y el hook sale 0 igual.

### Abierto — un REQ nuevo sin `QA:` puede cerrarse, y es una decisión, no un olvido
La puerta exige `QA: aprobado` **si el campo existe**. Fue una elección de compatibilidad
—los REQ anteriores al campo no pueden quedar bloqueados— y tiene su caso de prueba. La revisión
señala, con razón, que un REQ **nuevo** escrito directamente como `Estado: completado` sin `QA:`
también pasa, y eso contradice la promesa.

No se cierra en esta versión porque **la máquina no puede distinguir un REQ viejo de uno nuevo
mirando el archivo**. El camino honesto es en dos pasos: `/arnes-upgrade` añade `QA: pendiente`
a los REQ que no lo tienen, y en la versión siguiente la puerta exige el campo. Hacerlo al revés
bloquearía todo REQ antiguo el día de instalar.

### Añadido — CI
`.github/workflows/banco.yml`: en cada push a `main` y en cada PR, comprueba el bit de ejecución
y corre los 169 casos en Linux. Si el total cuadra en Windows y no en Linux, hay un caso
dependiente de plataforma — y eso también hay que saberlo.

## [1.28.0] — 2026-09-05
### Corregido — FALLO EN ABIERTO: desde 1.25.0 una redirección por Bash rodeaba las dos puertas
**Medido en un proyecto real, con control positivo en la misma tanda:** un `Write` a `src/` denegó
—el plugin estaba cargado—, y `echo 'Estado: completado' > requirements/x.md` **pasó y creó el
archivo**. También `echo '// sonda' > src/x.ts`. Reportado como `SEC-184` reabierto.

**La causa es mía y es del diseño de 1.25.0.** Puse un handler con `if` por disparador para que un
`ls` no arrancara el guardián. `if` funciona —verificado en `2.1.260` y `2.1.261`, en plugin— **pero
sólo para prefijos de comando**. Una redirección **nunca casa**: Claude Code la separa del comando
antes de evaluar el patrón, como dice la doc de permisos al tratar el destino de `>` como escritura
aparte. `Bash(* >*)` y `Bash(*>*)` no dispararon en ninguna versión.

```
touch a.txt          ->  IF_TOUCH dispara
echo hola > b.txt    ->  TODOS dispara, ningún IF_REDIR
cp a.txt c.txt       ->  IF_CP dispara
```

**Lo reportaron dos proyectos por separado, y la atribución importa.** Uno concluyó que los diez
handlers fallaban; el otro midió que `cp` y `tee` denegaban y concluyó, textualmente, que
*«`Bash(* >*)` no se dispara nunca; los otros nueve empiezan por un token literal y funcionan»*.
La medición aquí confirmó el segundo diagnóstico letra por letra. No cambia el arreglo: la
redirección es la forma de escritura más común y puede ir en cualquier comando, así que **la única
puerta posible para Bash es la que ve todos**. Se restaura el catch-all. El coste vuelve al de 1.24.0
y se acepta.

**Mi prueba de integración tenía control positivo para que `if` existe, no para el patrón del que
dependía todo.** Sondeó `touch` y pasó. Ahora sondea la redirección y exige que **no** case; si un
día casa, sale con código 3 para revisar si Bash puede volver a ser selectivo. Y el banco, que en
1.25.0 **exigía** que todo handler de Bash llevara `if` —certificando la forma que dejaba la puerta
en abierto—, ahora exige lo contrario.

**La lección, que vale más que el defecto** y que la escribió quien lo encontró: *una optimización
que reduce cuándo se invoca un control puede apagarlo entero sin cambiar una línea de su lógica.*
El guardián era correcto; simplemente ya no se le llamaba.

`stop.sh` se queda: es independiente y correcto.

## [1.27.0] — 2026-09-04
### Corregido — la rotación no funcionaba en archivos CRLF, y además fugaba
**Medido en un proyecto real:** su `CHANGELOG.md` (sin CR) rotó perfecto — 1 421 795 → 36 650
bytes. Su registro de seguridad (12 857 CRLF) **creaba el archivo y no recortaba el origen**, en
silencio y con `exit 0`.

La causa, aislada por quien lo reportó: al cortar el bloque por el salto de línea, la sonda de
verificación se quedaba con el **CR pegado al final** — 92 bytes contra 91 — mientras `grep` en
Windows lee el archivo en modo texto y ya lo ha quitado de sus líneas. No podía casar nunca. **Es
la misma familia que el CR de `jq` que dejaba `guard-codigo` en abierto**, sólo que aquí viene del
propio archivo — y en Windows eso es la mayoría de los archivos. El banco no lo vio porque
escribía todos sus artefactos con LF.

**Y era peor que inoperante.** Al medirlo aquí apareció lo que el informe no llegó a ver: el
contenido quedaba en los **dos** sitios, así que cada parada lo volvía a añadir — 3, 6, 9 secciones
en tres pasadas. Una fuga sin tope, justo en la función cuyo propósito es frenar el crecimiento
sin tope.

Dos arreglos, y el segundo es el que importa para el futuro:
- La sonda pierde el CR final. Seguro en los dos casos: `-F` busca subcadena, así que casa igual
  con una línea que lo conserve.
- **La escritura pasa a ser todo o nada.** El destino se arma en un temporal y sólo se publica si
  la verificación pasa. Antes se añadía y *después* se verificaba, así que **cualquier** fallo de
  verificación —no sólo el del CR— dejaba el contenido duplicado.

### Documentado — el intérprete: por qué añadir `Bash(python*)` sería teatro
El mismo informe señaló que `python - <<EOF` no está entre los disparadores de 1.25.0. Cierto — y
medirlo dio algo más incómodo: **aunque estuviera, no serviría.**

```
python - <<EOF ... open("src/app.ts","w") ... EOF   ->  no detecta
node -e '...writeFileSync("src/app.ts")...'          ->  no detecta
echo x > src/app.ts                                  ->  src/app.ts   (control positivo)
```

El guardión arrancaría, miraría el comando y permitiría: la ruta vive **dentro** del script.
Añadir el disparador sería coste sin cobertura — y peor que el hueco, porque parecería cerrado.

El arreglo de verdad es **cambiar la pregunta**: en vez de adivinar *antes* si un comando escribe
—abierta, admite formas nuevas sin fin— preguntar *después* si cambiaron los archivos protegidos,
que es **cerrada**. No previene, detecta; pero el arnés ya se declara barandilla, y una que avisa
siempre vale más que una que previene a veces. Queda diseñado y nombrado en `hooks.json`, el
README y `AGENTS.md`; no construido.

## [1.26.0] — 2026-09-04
Tres correcciones medidas por un tercer proyecto. Ninguna toca archivos del proyecto.

### Corregido — el orden de rotación es del ARTEFACTO, no del proyecto
**Era mi error, y del mismo tipo que llevo el día evitando en otros sitios.** `rotacion.orden` era
un solo valor global, pero medido en un proyecto real el `CHANGELOG.md` crece **por arriba** y
`docs/seguridad/registro-seguridad.md` **por abajo**. Un orden único no puede servir a los dos, y
equivocarse archiva **lo más reciente** — justo lo que hay que tener a mano. Con dos bitácoras de
1,4 MB y 1,3 MB, la función quedaba inservible para una de ellas.

`artefactos` acepta ahora **cadena u objeto**, la misma convención que ya usan las
`quality_gates`: una cadena hereda los ajustes globales, un objeto declara los suyos
(`ruta`, `orden`, `umbral_bytes`, `conservar_secciones`). Los manifiestos que hoy declaran una
lista de nombres siguen funcionando igual.

### Corregido — `Estado:` no llevaba la regla del paréntesis
1.23.0 hizo que `aprobado (evidencia)` contara como `aprobado`, y no apliqué lo mismo a `Estado:`.
Medido: el bloque derivado decía **2 completados donde había 9** y metía 44 REQ en «otros».

**La puerta no estaba afectada** — busca el estado terminal en el texto crudo y lo caza igual, con
fecha o sin ella; está medido. Así que no era un fallo en abierto: era **un tablero que mentía**.
Serio igual, porque el proyecto que lo reportó tuvo que apagar la continuidad por eso.

### Añadido — la versión instalada se ve en cada parada
Un proyecto corrió **1.13.0 durante un mes** con 1.24.0 publicada, sin ninguna señal. El bloque
derivado imprime ahora la versión del plugin instalado y, si el proyecto declara otra en
`arnes_version`, avisa de **migración pendiente**.

**No consulta la red, a propósito.** Un hook que hace DNS puede colgar una parada, y estos hooks
tienen como primera invariante no bloquear nunca. Se enseña lo que es gratis — lo instalado contra
lo declarado. Comparar contra lo publicado es trabajo de `/arnes-upgrade`, que ya tiene red y ya
acredita la versión de origen.

## [1.25.0] — 2026-09-04
### Cambiado — un `ls` ya no arranca el guardián
Hasta ahora **cada** comando Bash —`git status`, `ls`, `grep`, `npm test`— arrancaba `guard.sh`, y
en esta plataforma arrancar el intérprete es la parte cara (~1,2 s medido, con el resto del
trabajo ya optimizado). La mayoría de esas llamadas terminaba en *«no escribe nada relevante →
permitir»*: se pagaba el proceso para no hacer nada.

Ahora el `hooks.json` del plugin declara **un handler por disparador**, cada uno con un `if` que
Claude Code evalúa **antes de crear el proceso**. `Bash(* >*)`, `Bash(tee *)`, `Bash(cp *)`,
`Bash(mv *)`, `Bash(install *)`, `Bash(sed -i*)`, `Bash(perl -i*)`, `Bash(dd *)`, `Bash(xargs *)`.
Un comando que no casa con ninguno **no arranca nada**.

**Verificado, no leído.** Plugin desechable con dos handlers —uno sin `if` como control positivo y
otro con `if: "Bash(touch *)"`—, sesión headless con `--plugin-dir`, un `ls` y un `touch`: el
control registró los dos; el `if` sólo el `touch`. Sin el control, «no hay registro para `ls`» habría
sido indistinguible de «el plugin no cargó». Queda como prueba de integración en
`tests/escenarios/integracion/plugin-if/`.

**Qué se pierde, dicho antes y no después.** El motor de `if` desenvuelve `timeout`, `nice`, `xargs`
sin flags y asignaciones de entorno; **no** desenvuelve `npx`, `docker exec`, `bash -c`, `xargs -n1`
ni `find -exec`. Nuestro detector escaneaba el texto entero y ahí veía algo más. La cobertura de
Bash siempre estuvo declarada parcial; ahora está **medida**, y el banco fija la lista de
disparadores para que ninguno desaparezca en silencio.

**Por qué no hay un «perfil estricto» como interruptor.** Un plugin envía un solo `hooks.json`, y un
interruptor por proyecto exigiría arrancar el proceso para leerlo — justo el coste que esto evita. Se
envía la forma que ahorra; quien quiera el catch-all anterior puede añadir en su `settings.json` un
hook `Bash` sin `if` hacia el mismo `guard.sh`.

`Edit`/`Write`/`MultiEdit` siguen pasando siempre por `guard.sh`: sus globs de código son
configuración **del proyecto**, y el filtro del plugin no puede conocerlos.

### Cambiado — `Stop` y `SubagentStop` en un solo proceso
Continuidad y rotación iban como dos hooks: dos intérpretes por cada parada de cada subagente, y
como la rotación viene apagada, el segundo arrancaba sólo para descubrir que no tenía nada que
hacer. `stop.sh` hace el preludio una vez y corre los dos como funciones — el mismo principio que
`guard.sh`. Los dos archivos siguen siendo ejecutables por su cuenta y el banco los invoca así. De
paso, ambos calculaban su directorio con dos forks; ahora con ninguno.

Sin migración de archivos del proyecto: basta actualizar el plugin.

## [1.24.0] — 2026-09-04
Tres correcciones, todas medidas por **dos proyectos distintos** validando 1.23.0 contra sus
archivos reales. Ninguna toca archivos del proyecto: migrar es sólo actualizar el plugin.

### Corregido — `**aprobado** (medido…)` no contaba y `aprobado (medido…)` sí
Al normalizar, el énfasis sólo se retira si envuelve el valor **entero** — y con el paréntesis
detrás no lo envolvía. Luego se quitaba el paréntesis y quedaba `**aprobado**`. Mismo valor, dos
escrituras, veredictos opuestos: la misma asimetría que `n/a` / `no aplica`. Ahora el veredicto
se desenvuelve **otra vez** tras quitar el paréntesis. La dirección era segura —la decorada era
la estricta—, pero una regla que depende de cómo se escribe el mismo valor no es una regla.

### Corregido — el bloque derivado contaba una nota como REQ
Decía 58 REQ donde había 57: contaba todo `.md` de `requirements/` salvo el README, incluida una
nota sin `Estado:`. **Un bloque que presume de derivar del disco no puede decir 58 donde el disco
dice 57.** Sin `Estado:` no es un REQ; se cuentan aparte y **se dice cuántos hay** — que un
archivo quede fuera por silencio es justo lo que el bloque existe para evitar.

### Cambiado — el bloque derivado lista sólo lo abierto
Con 58 REQ pesaba **10,4 KB**: un 25 % sobre un `ESTADO.md` de 40 KB que se lee al empezar
**cada** sesión. Es justo el presupuesto que la rotación existe para cuidar, y aquí se lo estaba
comiendo el arnés. El bloque responde *«dónde quedamos»*, y un REQ completado ya no es parte de
esa respuesta: la línea de conteo lo resume y la tabla lista sólo los abiertos.

### Documentado — la continuidad viene encendida y corre en cada parada de subagente
Dos revisores lo señalaron con la misma frase: *«que lo sepas antes, no después»*. `docs/ESTADO.md`
es territorio del integrador, y con agentes en paralelo varias reescrituras compiten. Es
idempotente y las reescrituras producen el mismo bloque, así que no se corrompe — pero el hook
escribe en un archivo que una persona mantiene, y eso se avisa al migrar. Se apaga con
`estado_derivado.activo: false`.

## [1.23.0] — 2026-09-04
### Corregido — el paréntesis es evidencia, y la evidencia no cambia el veredicto
**Medido en un proyecto real: 26 REQ paralizados.** Su convención es
`QA: aprobado (medido el 3/9, 42 pruebas)` —el veredicto con lo que lo sostiene al lado— y la
comparación exigía la palabra exacta. Veinte REQ no habrían podido cerrarse y diez ya cerrados
habrían sido denegados al volver a tocarlos.

La alternativa era quitar los paréntesis de 35 líneas de veredicto, o sea **borrar la evidencia
del encabezado del REQ** — que es media razón de ser de este arnés. Poner la medición al lado de
la afirmación es lo que permite cazar lo falso; un veredicto sin ella es una opinión.

**La ambigüedad era un error de diseño mío, y se quita en vez de arbitrarse.** 1.21.0 metía el
matiz **dentro** del paréntesis —`aprobado (preventiva)`—, así que el mismo signo significaba
«evidencia» en un caso y «matiz que invierte el veredicto» en el otro: cortar servía a uno y rompía
al otro. Pero **un matiz que cambia el veredicto ES OTRO VEREDICTO**, no un paréntesis: una
revisión hecha antes de que existiera el código y una aprobación del código son estados distintos
del mundo, y meter uno entre paréntesis del otro era confundirlos.

- `Seguridad: preventiva` pasa a ser **su propio valor** (antes `aprobado (preventiva)`). Sigue
  sin cerrar un REQ crítico y sigue desbloqueando el orden del ciclo. Costó casi nada cambiarlo:
  la sintaxis tenía un día y estaba declarada en cero REQ.
- Un paréntesis **final y balanceado** se retira antes de comparar. `aprobado (sin cerrar` no es
  un paréntesis, es texto — la misma lección que el énfasis pareado.

**Riesgo residual, dicho en voz alta:** `aprobado (con reservas)` cuenta como aprobado. Es una
violación de la convención —el matiz debe ser un veredicto— y no un agujero silencioso: está
escrito en la plantilla del REQ y en la ficha de los dos agentes que firman.

El cambio es **estrictamente más permisivo** en los campos de veredicto: nada que pasara antes
falla ahora.

### Corregido — la cola de aprobaciones acaba donde acaba su sección
El conteo sólo cerraba la sección ante una cabecera literal `## Resueltas`. Cualquier otra
—`## Notas`, `## Histórico`— la dejaba abierta y sus `###` se contaban como aprobaciones
pendientes, bloqueando cierres legítimos. Los proyectos lo esquivaban **ordenando el archivo**:
carga, no estilo.

Otra lista enumerada donde hacía falta una propiedad cerrada: la sección va de su cabecera a la
**siguiente del mismo nivel**, se llame como se llame.

### Documentado — el plugin no se actualiza solo
Medido: un proyecto corría **1.13.0 del 3 de agosto** con **1.21.0** publicada. Un mes de
correcciones —tres puertas que no existían incluidas— que nunca llegaron, sin ninguna señal.

Y es peor de lo que parece, porque **las correcciones que más importan son silenciosas por
definición**: cuando una puerta no se está cumpliendo, nada falla — simplemente no protege. El
README y `/arnes-upgrade` lo dicen ahora, y la Fase 1 avisa de comprobar que el plugin instalado
sea el actual antes de usarlo como destino.

## [1.22.0] — 2026-09-04
### Añadido — continuidad automática: el arnés deja escrito dónde quedó todo
El coste más caro de una sesión larga no es el tiempo: es **reconstruir dónde quedó todo cuando
el contexto se pierde**. Un hook `Stop` / `SubagentStop` reescribe ahora en `docs/ESTADO.md`,
entre marcadores, un bloque con el estado y los veredictos de cada REQ, la cola de aprobaciones,
la rama y si el árbol tiene cambios sin comitear.

**No se redacta: se deriva, y ésa es toda la diferencia.** Pedirle a un agente que resuma lo que
hizo no resuelve nada, porque un resumen escrito por el modelo miente justo cuando más falta
hace —cuando le queda poco contexto, que es cuando peor recuerda—. Aquí cada línea sale de leer
un archivo: si el bloque se equivoca, es que el disco dice eso.

Los veredictos aparecen **como los lee la máquina** —normalizados, sin mayúsculas ni tildes ni
marcado— y no como están escritos en el REQ. Es deliberado: un `Sensible a seguridad: **sí**`
sale en el bloque con su rigor efectivo `critico`, así que **el fallo que 1.21.0 arregló habría
sido visible** en este tablero.

**Las invariantes que trae por delante de su utilidad:**
- **Nunca bloquea la parada.** Un hook `Stop` que falla deja la sesión colgada, y una herramienta
  de continuidad que impide terminar es peor que no tenerla. Sale `0` pase lo que pase.
- **No toca lo que escribió una persona.** Sólo reescribe entre sus marcadores.
- **Idempotente.** Dos pasadas dan un solo bloque.
- **Inerte sin manifiesto**, como los demás hooks, y **no inventa la carpeta destino**: decidir la
  estructura de un proyecto no le toca al arnés.
- **Si `git` no puede responder, lo dice.** El árbol queda `desconocido`, no «limpio» ni «con
  cambios»: las dos serían afirmar un hecho que no se tiene. Es la misma regla que 1.21.0 aplicó
  a los valores que no se entienden.

Se apaga con `estado_derivado.activo: false`.

### Añadido — rotación de artefactos: una bitácora no puede crecer sin tope
Medido en un proyecto real: el `CHANGELOG.md` llegó a **1,17 MB**. A ~4 caracteres por token son
del orden de **300 000 tokens en un solo archivo**, y se pagan otra vez en cada sesión que lo
lea. No es un problema de disco: es presupuesto.

El hook `Stop` / `SubagentStop` **mueve** las secciones sobrantes a `<nombre>-archivo.md` y deja
un puntero.

**Mueve; no resume.** Un resumen aquí sería peor que el problema: convertiría la bitácora en *la
versión que el modelo recuerda de la bitácora*, y una bitácora que no es fiel no sirve para nada.

**Las invariantes, otra vez por delante de la utilidad:**
- **Apagada salvo que el proyecto la encienda.** Reestructurar un documento que escribió una
  persona no puede ser el comportamiento por defecto.
- **Nunca borra.** Añade al destino, **relee para comprobar que llegó**, y sólo entonces recorta
  el origen. Si la comprobación falla, el origen no se toca: mejor un archivo grande que uno
  perdido.
- **Corta sólo en encabezados `## `.** Sin límites seguros no hace nada; un corte a media sección
  parte una entrada en dos.
- **Qué mitad es «lo viejo» no se adivina, se declara** (`rotacion.orden`). Un CHANGELOG pone lo
  nuevo arriba; un registro cronológico lo añade al final. Adivinar mal archivaría lo más
  **reciente**, que es justo lo que hay que tener a mano.
- **Idempotente por construcción:** al terminar quedan exactamente `conservar_secciones`, así que
  la pasada siguiente no encuentra excedente. La primera versión restaba al revés y cada pasada
  volvía a rotar, vaciando el archivo a trozos; lo cazó la prueba de idempotencia.

Y un fallo que la prueba también cazó antes de existir el caso: la comprobación de que el texto
llegó al destino usaba `case`, pero un encabezado `## [1.20.0]` lleva **corchetes**, que en un
patrón de `case` son una clase de caracteres y no texto. Habría fallado siempre, y el recorte no
habría ocurrido nunca. Ahora se compara con `grep -F`.

### Corregido — el asterisco de nota al pie no es énfasis (regresión de 1.21.0)
1.21.0 retiraba **todo** `*` del valor, y eso convertía `Seguridad: aprobado*` en `aprobado`. Un
asterisco tras una firma no es adorno: es una **llamada a nota al pie**, y una nota al pie apunta
a una **salvedad** — lo contrario de una firma incondicional. Lo delataba una asimetría:
`aprobado, ver nota` denegó siempre (el texto sobra), pero `aprobado*` pasaba. El agujero era
exactamente la forma escueta.

**Es el mismo error de 1.21.0, girado.** El argumento —*el marcado no es parte del valor*— se
hizo sobre `Sensible a seguridad:`, donde `**sí**` sí es el mismo valor, y el cambio se aplicó a
los cinco campos. **El sujeto del arreglo era más estrecho que su población**, que es literalmente
la invariante que el propio arnés enuncia.

El arreglo conserva el argumento sin abrir puerta nueva: **el énfasis de Markdown es pareado por
definición**, así que sólo se retira cuando **envuelve el valor entero**. `**sí**` sí; `aprobado*`
no. Un asterisco suelto nunca envuelve nada.

### Corregido — sólo una negación explícita abre la puerta de seguridad
El conjunto negativo de 1.21.0 incluía `n/a` y `ninguna`. Pero eso es lo que alguien escribe
cuando **no ha clasificado**, no cuando ha decidido que un REQ no es sensible: esas dos entradas
le abrían un hueco a la regla de fallo cerrado **justo en el caso para el que se construyó**. Lo
delataba una asimetría: `n/a` abría la puerta y `no aplica`, que es la misma frase, la cerraba.

Alargar la lista para taparlo sería la lista enumerada que se pudre. Lo correcto es invertir de
qué lado va la generosidad: **el conjunto que ABRE la puerta debe ser mínimo e inequívoco**
—`no`, `n`, `false`— y el que la cierra puede ser generoso, porque equivocarse ahí no cuesta
nada. Ahora las dos formas coinciden, y ninguna abre.

### Corregido — `estado_derivado.activo: false` no apagaba nada
En `jq`, el operador `//` trata `false` **igual que ausente**: `.activo // true` devuelve `true`
cuando alguien escribió `false`, así que el interruptor estaba soldado en «encendido». Lo
encontró el caso de prueba, no una lectura del código.

Es la misma clase de defecto que el resto de esta versión: **una comprobación que no distingue
«ausente» de «explícitamente negativo».** Ahora sólo un `false` explícito apaga; el resto deja el
hook activo, que es el lado inocuo. Revisados los demás `//` del código: todos operan sobre
cadenas o arrays, donde `//` se comporta bien.

## [1.21.0] — 2026-09-04
### Corregido — `Sensible a seguridad: **sí**` no activaba la puerta de seguridad
**Fallo en abierto, medido en un proyecto real:** siete REQ declaraban ser sensibles y
**ninguno** casaba. El normalizador plegaba la tilde y bajaba a minúsculas, pero el marcado
de Markdown seguía ahí: `**sí**` llegaba como `**si**`, que no es `si`, así que el rigor
efectivo caía a `estandar` y `Seguridad: aprobado` **dejaba de exigirse**. La puerta no se
abría: nunca llegaba a existir. Seis eran negrita; el séptimo llevaba un comentario tras el
valor.

Uno de ellos gobernaba la subida de foto de perfil —Entra ID, token delegado, datos
personales— y lo único que impedía su cierre era que QA seguía en `con-hallazgos`. Estaba a
un campo de distancia.

**El arreglo va en dos mitades, y la segunda es la que importa.**

1. **El marcado no es parte del valor.** `arnes_norm_campo` retira `*`, `_` y las comillas
   invertidas. No es una lista de variantes del valor —esas se pudren—: es retirar sintaxis
   de Markdown, que es un conjunto cerrado y ajeno al dominio. El **paréntesis no se toca**
   ahí: cortarlo convertiría `Seguridad: aprobado (preventiva)` en una firma completa, y una
   auditoría preventiva cerraría un REQ crítico. Habría sido cambiar un fallo en abierto por
   otro.

2. **Tres estados, y el tercero cae del lado seguro.** `arnes_sens_efectiva` clasifica el
   campo en `sí` / `no` / **no se entiende**, y lo que no se entiende se trata como sensible.
   Una forma cerrada sólo funciona si algo obliga a producirla, y aquí el valor es Markdown
   libre tecleado por un agente: el sujeto del control es más estrecho que su población. La
   respuesta no es enumerar mejor, es que **la lista deje de ser peligrosa cuando esté
   incompleta**. Es la regla que `/arnes-upgrade` ya aplica a `UNKNOWN` —*una comprobación que
   no puede responder no dice «no sé», dice «sí»*— y que aquí faltaba. La denegación lo
   explica, porque un `deny` que no dice de dónde sale se lee como falso positivo y acaba con
   alguien apagando el guard.

**Campo ausente sigue significando «no».** Cambiarlo obligaría a auditar todo REQ anterior a
que el campo existiera.

### Corregido — el banco escribía siempre limpio, y por eso no lo veía
Veinticuatro fixtures, dos valores: `"sí"` y `"no"`. Es **el mismo diagnóstico que quedó
escrito en 1.16.0** sobre otro campo —*«el banco no lo veía porque escribía su propio archivo
limpio, nunca la plantilla»*— y reapareció porque entonces se arregló el **caso** y no el
**banco**. Ahora cada campo que se compara contra una forma cerrada tiene su fixture decorado
con sus controles negativos: trece casos, incluido el que fija que la firma preventiva
**decorada** tampoco cierra.

### Documentado — el intérprete es el siguiente agujero por tamaño
`node script.mjs` no lo ve ningún guardián: el detector lee el texto del comando y la ruta
vive **dentro** del script. No es una regresión —la cobertura de `Bash` siempre se declaró
parcial— pero ahora está medido y nombrado en vez de quedar bajo el genérico «scripts»: en
Windows, donde `sed -i` es incómodo, un intérprete es lo primero que alcanza cualquiera.

### Añadido — `/arnes-upgrade` acredita la versión de origen en vez de creérsela
`arnes_version` lo escribe quien migra y **ninguna puerta lo comprobaba**. Es la misma clase de
defecto que `Sensible a seguridad: **sí**`: un campo escrito a mano que nadie verifica acaba
mintiendo. Aquí miente en el peor sitio, porque de ese número sale la **base** del merge a tres
vías: si es falso, la base se recupera igual —sólo que la equivocada— y entonces cada `INTACTO`
y cada `MODIFICADO` se calculan contra un documento que el proyecto nunca tuvo. La migración no
falla: **acierta en el procedimiento y se equivoca en todo el resultado.**

*(Caso real: un proyecto declaraba `1.15.0` con el plugin instalado en `1.14.0` — una versión
que ni siquiera estaba presente.)*

La Fase 1 pasa a dar **tres resultados**: `CONFIRMADO` —las plantillas de origen guardadas son
idénticas a las del tag declarado—, `CORROBORADO` —no las hay, pero los marcadores concuerdan, y
se sigue **diciéndolo**: la base es reconstruida, no guardada— y `DESMENTIDO`, que es `UNKNOWN`
y para. Antes de nada, una contradicción barata: un origen **posterior** al plugin instalado es
imposible.

Los **marcadores** son rasgos que sólo pueden existir a partir de una versión. Sirven para
**desmentir**, que es barato y seguro; reconstruir el número exacto a partir de ellos sería
inferencia, que es justo lo que esta skill evita. Si desmienten lo declarado se **pregunta**, no
se sustituye por la que parezca.

### Añadido — `/arnes-upgrade` avisa del choque de vocabulario del rigor
Un proyecto con su propia escala —dos niveles, declarados en `Sensible a seguridad:`, con QA
siempre— no puede mapearla a la del plugin —tres niveles, declarados en `Rigor:`, donde
`ligero` **salta QA**— sin decidir. Queda como **CONFLICTO** con su tabla: se pregunta qué
trabajo puede prescindir de QA, y «ninguno» es una respuesta válida.

## [1.20.0] — 2026-09-04

> **Esta versión no llegó a publicarse por separado y NO tiene tag.** Su contenido entró en
> `main` dentro del mismo commit que 1.21.0 —el squash del PR #13 los fusionó—, así que ningún
> commit llegó nunca a declarar `1.20.0` en `plugin.json`. Se conserva como entrada porque
> describe un cuerpo de trabajo distinto y `/arnes-upgrade` lo necesita como **paso** de
> migración, pero ningún proyecto puede estar *en* 1.20.0. Etiquetarla apuntaría a un commit
> que dice `1.21.0`: una versión existe cuando `plugin.json` la declara.
### Cambiado — `/arnes-upgrade` pasa a ser un merge a tres vías, no una comparación
La primera versión comparaba el archivo del proyecto contra la plantilla nueva y preguntaba
ante cualquier diferencia. En un proyecto real **casi todo difiere**, así que serían ~20
preguntas por migración y el usuario acabaría aceptándolas sin leer — peor que no preguntar.

El modelo correcto son **tres** documentos: la plantilla de la versión de **origen** (base), el
archivo **del proyecto**, y la plantilla de **destino**. La base es lo que permite distinguir
*«esto lo escribió una persona»* de *«esto es andamiaje que nadie tocó»*.

**Cuatro estados** en vez de «igual o distinto»:

| Estado | Evidencia | Acción |
|---|---|---|
| `NUEVO` | No existía en la base | Añadir |
| `INTACTO` | Idéntico a la base | Actualizar |
| `MODIFICADO` | Existe y difiere de la base | Conflicto |
| `ELIMINADO` | Existía en la base y ya no está | Conflicto |

`ELIMINADO` es conflicto y **no** «volver a añadir»: una sección ausente pudo borrarse a
propósito, y reponerla revertiría una decisión humana en silencio.

**Tres resultados, nunca dos:** `SAFE` se aplica solo; `CONFLICTO` y **`UNKNOWN`** se detienen
igual. Nunca se convierte incertidumbre en decisión — una comprobación que no puede responder
no dice «no sé», dice «sí», y aquí eso significaría pisar trabajo de una persona.

**Protocolo verificable**, porque lo ejecuta un agente y no código determinista: inventario →
plan → aplicar sólo lo planeado → **verificar releyendo el disco** → registrar. La fase de
verificación es la que importa: *el acto de editar no es la prueba de que se editó bien*. Es la
misma regla de acreditar por contenido que el arnés aplica a todo lo demás.

**Reanudable, no atómica.** El plan vive en `.arnes/migracion.md` y al reanudar sólo hay dos
caminos válidos: continuar desde la primera operación no aplicada, o revertir con git. Nunca
«parece que algunas cosas ya están, sigo desde donde me parezca» — eso vuelve a inferir el
estado del contenido, que es lo que el plan existe para evitar.

**El respaldo lo da git**, no una copia hecha a mano: se exige el árbol limpio antes de empezar.

### Añadido — `arnes-init` guarda las plantillas de origen
En `.arnes/plantillas-origen/`, sin rellenar. Ocupa unos KB y es lo que hace posible el merge a
tres vías **sin depender de tener acceso al repositorio del plugin**. La migración las refresca
al terminar, para que la siguiente tenga base.

### Corregido — `v1.14.0` nunca se etiquetó
Sin ese tag, un proyecto inicializado en 1.14.0 no tenía base recuperable y la migración habría
caído en `UNKNOWN` para todo. Etiquetada retroactivamente; las seis versiones vivas
(`v1.14.0`…`v1.19.0`) están verificadas contra el `plugin.json` que declaran.

### Añadido — el ciclo se cumple: seguridad no firma lo que QA no ha validado
`AGENTS.md` §6 fija desarrollador → qa-tester → auditor-seguridad. La regla ya estaba escrita;
faltaba que se cumpliera: buscando paralelismo se emitió la firma de seguridad sobre árboles que
QA no había validado, y el argumento del propio auditor lo zanja — *«yo no miro seis de las
siete quality gates»*.

Corre en **cualquier** edición del REQ, no sólo al cerrarlo: el daño se hace al escribir el
veredicto. **Excepción nombrada:** la auditoría **preventiva** —sin código todavía— sí puede ir
por delante, y se declara como `Seguridad: aprobado (preventiva)` **al emitirla**, no al
invocarla.

La excepción **está escrita donde se lee**, no sólo en el mensaje del `deny`: `AGENTS.md` §6 y
§13, `requirements/README.md` y la ficha del `auditor-seguridad`. Una máquina que exige algo que
el `AGENTS.md` del proyecto no describe es exactamente la deriva que `/arnes-upgrade` existe para
evitar; por eso esta migración **no es cosmética**: sin ella el hook deniega y la salida no está
documentada en el proyecto.

### Corregido — el bloqueo mutuo que la regla del orden habría causado
La ficha del `qa-tester` metía **dos actos en una frase**: «marca `QA: aprobado` **y**
`Estado: completado`», condicionado a que ya existiera `Seguridad: aprobado`. Con la regla del
orden recién añadida eso cierra un ciclo: QA espera la firma de seguridad, y seguridad no puede
firmar hasta que QA apruebe. Un REQ sensible no habría avanzado nunca.

Los dos actos van separados: **el veredicto se emite en cuanto la validación pasa** —sin esperar
a nadie— y **el cierre sí espera** la auditoría. Un `aprobado (preventiva)` desbloquea el orden
pero **no cierra** un REQ crítico, y ahora hay caso de prueba que lo fija.

### Corregido — el `README` describía un agujero que ya estaba tapado
Decía que `guard-completado` «no mira `Bash` en absoluto» y que un `sed -i` podía cerrar un REQ
sin pasar por las puertas. Dejó de ser cierto en 1.16.0: sí mira `Bash`, y lo **deriva** a
`Edit`/`Write`. Documentación caducada en la dirección peligrosa —prometer menos protección de la
que hay también es deriva—.

### Corregido — el banco de pruebas dejaba de tragarse el `stderr`
`corre()` mandaba `stderr` a `/dev/null`, así que un aborto del canario sólo podía ofrecer tres
conjeturas —«¿CRLF? ¿jq? ¿permisos?»— y ninguna evidencia; es justo lo que el propio banco
prohíbe en `check_motivo`. Ahora se aparta a un archivo fijo reutilizado (cero forks extra) y
todo fallo lo enseña; el canario añade además la salida real, el `rc` de un segundo intento y los
permisos del hook.

### Corregido — los insumos de proyectos reales no podían publicarse por descuido
Los documentos que traen lecciones de un proyecto concreto llevan hallazgos de un cliente
—nombres, umbrales, arquitectura, huecos de seguridad— y este repositorio es **público**.
Estaban sin versionar, pero nada impedía que un `git add -A` distraído los subiera. Ahora
`mejoras-arnes-*.md` e `insumos/` están ignorados: el arnés se queda con la **forma** del
hallazgo y nunca con su instancia.

## [1.19.0] — 2026-09-04
### Añadido — nivel de rigor por REQ: no todo requerimiento paga lo mismo
El arnés aplicaba el máximo rigor a todo: un cambio de texto pasaba por los mismos cuatro
agentes que un cálculo de dinero. Medido en el proyecto de origen, un REQ cuesta del orden de
**1 M de tokens** y varias horas de reloj; para la mayoría eso es desproporcionado, y el arnés
no tenía forma de decirlo.

Cada REQ declara ahora `Rigor:` en su cabecera:

| Nivel | Qué corre | Cuándo |
|---|---|---|
| `ligero` | analista + desarrollador + quality gates | Sin lógica: textos, etiquetas, presentación |
| `estandar` | + QA | Lógica de negocio ordinaria |
| `critico` | + auditoría de seguridad | Dinero · datos personales · identidad o acceso · documento con efecto legal · cambio irreversible |

**El arnés trae el MECANISMO, nunca el MAPEO.** Los criterios son independientes del dominio a
propósito. Qué REQ de un proyecto concreto cae en cada nivel lo pregunta `arnes-init` y se
escribe en el `AGENTS.md` **de ese proyecto**: el plugin no sabe —ni debe— qué es una constancia
salarial.

**Compatibilidad total, y es deliberada.** Un REQ que no declara `Rigor:` se juzga **exactamente
como antes de que los niveles existieran**. Un proyecto que no migre no nota ningún cambio, y la
velocidad se gana con un acto explícito, nunca por sorpresa.

**Se puede subir, nunca bajar.** `Sensible a seguridad: sí` impone `critico` como **suelo**:
escribir `Rigor: ligero` ahí no baja nada. Un valor no reconocido se ignora y cae a la
derivación — nunca abre la puerta.

Distinguir el **suelo de seguridad** del **valor por defecto** es lo que hace que esto funcione:
tratarlos como lo mismo deja `ligero` inalcanzable, porque el defecto de un REQ no sensible ya
es `estandar` y anularía cualquier declaración menor.

**Gobierno:** lo fija el `analista-requerimientos`; el `auditor-seguridad` **puede subirlo** —y
subirlo sobre un REQ ya cerrado lo **reabre**— y nadie lo baja sin firma del dueño del sistema.

### Pruebas
68 → **77 casos**, 0 fallos. Los tres que más importan impiden que el nivel se convierta en una
puerta trasera: `ligero` sobre un REQ sensible, `estandar` sobre un REQ sensible, y un valor
inventado. Los tres deben **denegar**.
## [1.18.0] — 2026-09-04
### Añadido — `/arnes-upgrade`: los proyectos existentes también se ponen al día
Hasta ahora el arnés no tenía **ninguna ruta de migración**. `arnes-init` se niega a actuar si
el proyecto ya está inicializado, y no existía nada más.

El problema que eso creaba es estructural, no accidental: los hooks, los agentes y las skills
viven **en el plugin** y se actualizan solos, pero los ~10 archivos que `arnes-init` copió al
proyecto —`AGENTS.md`, `.arnes/config.json`, `requirements/README.md`…— **quedan congelados
para siempre**. Cada versión nueva del arnés garantizaba así una deriva: **la máquina empezaba
a exigir cosas que el `AGENTS.md` del proyecto no describe**, y los agentes, que leen esos
archivos, no se enteraban de las capacidades nuevas.

`/arnes-upgrade` cierra ese hueco, con tres reglas de diseño:

- **Aditivo y quirúrgico, nunca sobrescribe.** Un `AGENTS.md` está lleno de decisiones del
  proyecto —stack, módulos, gates—; copiar la plantilla encima las destruiría. Añade lo que
  falta y, si una sección existe pero con contenido distinto, **muestra la diferencia y
  pregunta** en vez de fusionar a ciegas.
- **`arnes_version` es el registro de la migración, y se actualiza AL FINAL.** Subirlo antes
  de aplicar los cambios haría que la siguiente ejecución creyera que ya está hecho, dejando
  el proyecto a medias sin que nadie lo note.
- **Los REQ existentes no se tocan.** Los campos nuevos son compatibles hacia atrás por
  diseño, y hay un caso de prueba que lo fija.

`arnes-init` remite ahora a esta skill cuando encuentra un proyecto ya inicializado con una
versión distinta a la instalada. Sin ese aviso, quien la ejecutara se quedaba sin camino.

## [1.17.0] — 2026-09-04
### Rendimiento — el coste no era `jq`, era bifurcar
Los hooks tardaban **~35 s por edición de archivo** en Windows. La causa no era la que
parecía. Medido en esa máquina:

```
$(echo hola)   subshell con un builtin    554 ms
dirname        binario externo            643 ms
${var//x/y}    expansión pura de bash       0 ms
```

Ejecutar el binario sólo suma ~80 ms sobre el `fork` que lo envuelve. En Windows no existe
`fork()` y la emulación MSYS lo resuelve copiando memoria a mano, así que **el gasto está en
bifurcar, no en los programas**. El código estaba escrito en el estilo normal de shell
—funciones que devuelven por stdout, tuberías para transformar texto—, que es gratis en Linux
y carísimo aquí.

| | Antes | Ahora |
|---|---|---|
| Una edición de archivo | ~35 s | **5,5 s** |
| Un comando de shell | ~30 s | **3,3 s** |
| Suite completa (68 casos) | — | 630 s |

Los cambios, todos en la misma dirección:

- **Un solo punto de entrada** (`hooks/guard.sh`): los dos guardianes hacían el mismo trabajo
  previo —arrancar, cargar la librería, leer stdin, interpretar el mismo JSON, leer el mismo
  manifiesto— cada uno en su proceso. Ahora el preludio se hace una vez y ambos corren como
  funciones en el mismo proceso, con el análisis **memorizado**.
- **Toda función que devuelve por stdout obliga a un `$( )` en cada llamada.** Los helpers del
  camino caliente pasan a **asignar a una variable**.
- **Lecturas de `jq` con here-string:** `< <(printf … | arnes_jq …)` eran **tres** bifurcaciones
  por lectura (sustitución de proceso, tubería y el `$( )` interno). Ahora una.
- **Texto manipulado en bash, no en procesos:** `printf|sed|head` para leer un campo del REQ
  costaba 5.116 ms por campo y se invocaba cinco veces; en bash son 326 ms. `printf|tr|tr`,
  `cat`, `dirname`, `cygpath` innecesario y los `sed` de la detección de escrituras por shell
  (esta última, **−94%**) salen del camino común.

**Lo que no cambia:** los dos guardianes siguen siendo **ejecutables por su cuenta** y el banco
los invoca así. Producción y pruebas ejecutan la misma función, no dos copias que puedan
desfasarse.

**El riesgo que hubo que cerrar al convertirlos en funciones:** decir «permito» con `exit 0`
mata el proceso y el segundo guardián nunca corre — fallo abierto y en silencio. Todo `exit`
del cuerpo pasó a `return`, y hay un caso de prueba (`deny`, o sea control positivo) que existe
sólo para cazar una reintroducción de ese error.

### Corregido — un REQ con `Sensible a seguridad: SÍ` se saltaba la auditoría
La normalización a minúsculas trabaja byte a byte y, sin locale definido, no toca la `Í`. El
valor quedaba como `sÍ`, **no casaba** con la lista `sí|si`, y el REQ cerraba **sin exigir
`Seguridad: aprobado`**.

Comprobado que el código anterior se comportaba igual: el defecto es previo, no lo introduce
esta versión. El normalizador pliega ahora la tilde y la comparación es contra **una forma
cerrada** (`si`) en vez de una lista de variantes — que es exactamente lo que el arnés predica
en su propio playbook: cuando la familia de formas de escribir algo es abierta, el control no
puede enumerarlas.

### Pruebas
57 → **68 casos**, 0 fallos. Los 11 nuevos cubren el punto de entrada real (`guard.sh`), que
antes no tenía ninguno: sin ellos el banco habría validado algo distinto de lo que se ejecuta.

## [1.16.0] — 2026-09-03
### Añadido — la clase del hallazgo decide si bloquea el cierre
Hasta ahora **cualquier** hallazgo abierto impedía cerrar un REQ. En la práctica eso mantiene
REQ de negocio abiertos durante semanas por defectos **del propio arnés**: un lector de umbral
que se evade, un guardián con un agujero. Atacar guardianes es valioso, pero **no puede ser
condición para cerrar una función de negocio**.

Y el tope de vueltas no acotaba nada, porque **se reiniciaba con cada hallazgo nuevo**: cada
arreglo cierra el hallazgo documentado y la vuelta siguiente encuentra una variante legítima
del mismo defecto, así que un REQ puede pasar semanas en `en-revisión` sin haber gastado nunca
tres vueltas del mismo hallazgo.

- **Campo `Hallazgos abiertos:`** en la plantilla de REQ, con la clase entre paréntesis:
  `SEC-121 (instrumento), SEC-144 (usuario/dinero)`.
- **Tres clases, sólo dos bloquean:** `usuario/dinero` (afecta lo que alguien ve, decide o
  cobra) y `contrato` (el REQ afirma algo falso sobre lo construido) **bloquean**;
  `instrumento` (el defecto está en el control o la prueba, no en el producto) **no bloquea**
  y va a deuda técnica con dueño.
- **Un hallazgo sin clase deniega.** Sin ella la puerta no puede saber si bloquea, y un «no sé»
  que deja pasar es un «sí» disfrazado. Una clase desconocida también deniega.
- **El tope se cuenta por REQ y no se reinicia** (`AGENTS.md` §6). Agotado, el REQ no se queda
  abierto: cierra con el residual declarado —dueño, forzador medido, vencimiento— o pasa a
  `bloqueado` y se escala.

Es la primera puerta del arnés que existe para **dejar pasar**. Las demás añaden formas de
bloquear; ésta quita una que sobraba.

### Corregido — cerrada la limitación conocida de 1.15.0: `guard-completado` ya mira `Bash`
1.15.0 dejó escrito el hueco: *«un `sed -i` sobre un archivo de `requirements/` puede dejar un
REQ en `completado` sin pasar por las puertas»*. Ahora `guard-completado` está también en el
matcher de `Bash`.

**No juzga: DERIVA.** Un comando que escribe en `requirements/` y menciona el estado terminal
se deniega pidiendo que la transición se haga con `Edit`/`Write`, que es donde el hook puede ver
el contenido resultante. Reimplementar veredictos, cola y quality gates para la shell sería una
segunda transcripción de la misma regla, y dos transcripciones se desfasan.

Hereda la **misma cobertura parcial** que `guard-codigo` —usa el mismo `arnes_bash_escrituras`—
y eso queda dicho en `AGENTS.md` §13; no es cobertura total y no se presenta como tal.

La detección del estado terminal sí es **deliberadamente ancha** —en cualquier parte del
comando, no `estado:` seguido del valor—. Lo obligó una prueba en rojo: la forma más natural de
cerrar un REQ por shell sustituye el **valor** y no escribe nunca la palabra «Estado».

### Corregido — un proyecto recién inicializado no podía cerrar ningún REQ
La plantilla de `PENDING_APPROVAL.md` traía su ejemplo de formato —comentado en HTML— bajo
`## Pendientes`. El conteo de `guard-completado` cuenta líneas `^###` y no sabe de comentarios,
así que devolvía **1 pendiente** con la cola vacía y denegaba todos los cierres. El banco no lo
veía porque escribía su propio archivo limpio, nunca la plantilla.

Arreglado por los **dos** lados —el `awk` ignora lo que está dentro de `<!-- -->` y la plantilla
saca el ejemplo de la sección—, porque corregir sólo el caso que falló lo reabre en el siguiente.

### Corregido — la versión del arnés se tecleaba a mano
`templates/arnes-config.json.tpl` pasa a `{{ARNES_VERSION}}` y `arnes-init` lo deriva de
`.claude-plugin/plugin.json`. El escritor es la corrida, no una persona.

### Rendimiento — los hooks gastaban ~20 procesos por invocación
Cada `arnes_jq` arranca `jq` **y** `tr`, y en Windows sobre almacenamiento sincronizado un
arranque cuesta ~0,5 s. Los campos se leen ahora **agrupados, una llamada por fuente**, y
colocados **después** de la salida temprana que puedan aprovechar.

| Hook | Antes | Ahora |
|---|---|---|
| `guard-codigo` | 6 | **2** |
| `guard-completado` | 9 | **4** |

El caso más frecuente mejora más de lo que dice la tabla: un comando de shell de sólo lectura
—la mayoría— sale con **una** llamada, antes de tocar el manifiesto. No cambia ninguna regla.

### Pruebas
41 → 54 casos, con filtro opcional (`run.sh bash`, `run.sh hallazgo`) porque una vuelta completa
cuesta minutos y un ciclo de verificación caro es lo que empuja a saltarse la suite.

Los casos nuevos incluyen el de compatibilidad que importa —**un REQ anterior al campo de
hallazgos no puede quedar bloqueado por él**— y **dos** `deny` distintos para el cierre por
shell: con uno solo el hueco seguía abierto, porque la forma con `sed` y la forma con heredoc
fallan por razones distintas.

## [1.15.0] — 2026-09-02
### Corregido — el guard denegaba justo al agente autorizado (prefijo del plugin)
`guard-codigo` comparaba `agent_type` en crudo contra `agentes.agente_codigo` del manifiesto.
Claude Code entrega el agente **con el prefijo del plugin que lo provee**
(`arnes-juan:desarrollador`), mientras que el manifiesto declara el nombre corto
(`desarrollador`): la igualdad no se cumplía nunca y el hook **rechazaba al único agente que
puede escribir código**. Costó dos entregas bloqueadas en SENDA, y el parche local (poner el
nombre con prefijo en `.arnes/config.json`) era frágil: se rompe si el plugin cambia de nombre
y obliga a cada proyecto a conocerlo.

La comparación ahora vive en `arnes_agente_coincide()` (`hooks/lib.sh`) y es **tolerante al
prefijo sin volverse permisiva**:
- Se compara el **nombre corto** (tras el último `:`), normalizado — minúsculas, sin espacios ni
  CR: es un campo que escribe una persona a mano.
- Si **ambos** lados traen prefijo, además deben coincidir. Un proyecto que necesite
  desambiguar declara `arnes-juan:desarrollador` y con eso rechaza a `otro-plugin:desarrollador`.
- Si el manifiesto **no** trae prefijo, cualquier proveedor con ese nombre corto casa: el
  manifiesto no dijo de qué plugin viene, y exigirlo reintroduce el bug que se corrige.
El motivo del deny sigue nombrando al agente de forma legible: `'qa-tester' (arnes-juan:qa-tester)`.

`guard-completado` no compara nombres de agente en ningún punto (revisado); no le aplica.

### Añadido — cobertura PARCIAL de `Bash` en `guard-codigo`
`hooks/hooks.json` sólo declaraba `Edit|Write|MultiEdit`, así que un `cat > archivo` nunca
disparaba el guard — y eso fue exactamente lo que hizo un agente al verse rechazado por el bug
de arriba. Ahora `Bash` tiene su propio matcher (sólo `guard-codigo`) y `arnes_bash_escrituras()`
detecta las escrituras **evidentes**: redirección `>`/`>>`, `tee`, `cp`, `mv`, `install`,
`sed -i`, `perl -i` y `dd of=`.

Es deliberadamente parcial y **sesgada al falso negativo**: descarta el texto entrecomillado
antes de analizar, exige intención de escritura *y* una ruta que case con `codigo_app.globs`, y
ante la duda permite. Quedan fuera a propósito los scripts, los formateadores que reescriben
archivos (`prettier --write`, `eslint --fix`), `patch`/`git apply` y todo programa que escriba
por su cuenta. El mensaje de denegación dice que la cobertura es parcial, para que un falso
positivo se reconozca al instante.

### Cambiado — la documentación ahora dice la verdad sobre el enforcement
`AGENTS.md.tpl` §5 prometía «esto lo cumple la máquina, no la buena voluntad». No es cierto y
prometer de más es peor que documentar el hueco: quien confía en una jaula deja de mirar.
- §5 y §13: **es una barandilla, no una jaula** — impide el desvío por descuido, no contiene a
  un agente decidido a rodearla. §13 lista ahora las herramientas cubiertas por invariante y los
  huecos conocidos (Bash parcial en `guard-codigo`; `guard-completado` no mira `Bash`, así que un
  `sed -i` sobre un REQ puede cerrarlo sin pasar por las puertas).
- §6 y §7: «Cumplido por máquina» → «Vigilado por máquina», con puntero al alcance real.
- `README.md` del plugin: sección *Limitación conocida* con el porqué (un hook no puede analizar
  shell arbitrario; perseguirlo da falsos positivos y un guard que estorba acaba desactivado —
  uno apagado protege menos que uno parcial).
- `arnes-config.json.tpl`: documenta que basta el nombre corto del agente, y sincroniza
  `arnes_version` (llevaba en 1.6.0).

### Añadido — licencia de uso propietaria (`LICENSE`)
El repositorio es público —necesario para `/plugin marketplace add`— pero el arnés no es open source, y hasta ahora el repo no lo decía. `LICENSE` fija el marco: permite descarga, instalación y uso interno, incluido trabajo comercial y para clientes; prohíbe redistribución, espejos o marketplaces alternativos, obras derivadas, integración en productos de terceros e ingeniería inversa. Declara explícitamente que configurar el arnés vía `AGENTS.md`/`CLAUDE.md` y plantillas es Uso Interno, no obra derivada — la separación maquinaria/estado del proyecto llevada al plano legal. Los forks se autorizan sólo para preparar contribuciones al repo original y toda contribución queda cedida a SysVEGA. Español vinculante, traducción al inglés informativa; ley aplicable Costa Rica.

### Añadido — pruebas de regresión
`tests/escenarios/hooks/run.sh` pasa de 16 a **44 casos**: identidad con prefijo (aceptado,
denegado para otro agente, coordinadora denegada, normalización, manifiesto calificado en ambos
sentidos), escrituras por `Bash` que deben denegarse, y una batería de **falsos positivos** que
deben permitirse (`cat`, `grep`, `sed -n`, `git commit -m` con la ruta en el mensaje, leer código
y escribir fuera). Contra el código anterior fallan 14 de los 28 nuevos; contra este, 0.

Dos defensas contra el verde falso de ayer, cuando todos los casos verdes eran casos `allow` que
también pasan con el hook muerto:
- **Canario**: si el `deny` canónico no deniega, la corrida aborta en lugar de dar verde.
- **`ARNES_HOOKS_DIR`**: permite correr el banco contra otra copia de los hooks, para comprobar
  que un caso nuevo falla con el código anterior.
## [1.14.0] — 2026-09-01
### Corregido — el enforcement no funcionaba en Windows (fallaba ABIERTO y en silencio)
Descubierto en el proyecto SENDA: los tres invariantes que el arnés dice cumplir «por
máquina» (§13) llevaban desde su introducción **sin bloquear nada** en Windows. La sesión
coordinadora podía editar `src/` sin que `guard-codigo` dijera una palabra, y ningún REQ
quedaba realmente protegido por `guard-completado`. `tests/escenarios/hooks/run.sh` pasaba
de 7/13 porque **todos** sus casos verdes eran casos `allow`, que también pasan cuando el
hook no llega a ejecutarse. Tres causas independientes, cada una suficiente por sí sola:

- **Shebang con CRLF.** `.gitattributes` traía `* text=auto`, así que al clonar el plugin en
  Windows los `.sh` quedaban con CRLF y el shebang pasaba a ser `#!/usr/bin/env bash\r`.
  `env` busca un binario llamado `bash\r`, no existe, el hook **no corre** y Claude Code lo
  interpreta como permitir. Ahora `*.sh text eol=lf` los blinda, igual que ya se hacía con
  `templates/githooks/pre-commit`.
- **Traducción de rutas de MSYS.** En Windows `jq` suele ser un binario nativo: bash ve la
  raíz del proyecto como `/tmp/x` mientras que `jq` devuelve el `file_path` como
  `C:/Users/.../x`. Al restar el prefijo, `rel` conservaba la ruta absoluta, ningún glob de
  `codigo_app` casaba y el `case` de `requirements/` tampoco. Nuevo `arnes_norm_path()`
  (`hooks/lib.sh`) canoniza ambas rutas antes de compararlas — vía `cygpath` cuando existe,
  identidad en Linux y macOS.
- **CRLF en el stdout de jq.** Cada glob leído del manifiesto llegaba como `src/*\r`, que no
  casa con nada. Nuevo `arnes_jq()` retira el CR; ambos guards lo usan en lugar de `jq`.

### Corregido — `quality_gates` sólo aceptaba una de las dos formas del manifiesto
`guard-completado` leía `.quality_gates[]` esperando cadenas sueltas, pero un manifiesto real
las declara como objetos `{nombre, comando}` (la plantilla `arnes-config.json.tpl` no fija la
forma). Con objetos, el hook hacía `eval` sobre JSON pretty-printed: nunca ejecutaba las gates
de verdad y denegaba con un mensaje incomprensible. Ahora acepta **ambas** formas.

### Añadido — pruebas de regresión
`tests/escenarios/hooks/run.sh` pasa de 13 a 16 casos: `quality_gates` como objetos en verde y
en rojo, y un `file_path` estilo Windows con backslashes. Contra el código anterior fallan
8 de 16; contra este, 0.

## [1.13.0] — 2026-06-26
### Añadido — mecanismo de playbooks de plataforma
Conocimiento reutilizable y caro de aprender (errores de runtime) para un stack/servicio
concreto, sin acoplar el flujo base del arnés a ningún cliente. Es **opt-in**: sólo aplica
si el proyecto lo declara en su `AGENTS.md`.
- **`playbooks/README.md`:** documenta el mecanismo (genérico, opt-in, vinculante cuando aplica).
- **`playbooks/power-apps-dataverse.md`:** primer playbook — convenciones de persistencia
  Power Apps Code App + Dataverse (no escribir `statecode`/`statuscode`, nombres de lookup en
  `@odata.bind`, fuente nativa vs conector, identidad en 2 pasos + checklist). Cada regla nació
  de un error de runtime real.
- **`templates/dataverse-lookups.guard.test.ts.tpl`:** plantilla del test guardián de lookups
  (cruza cada `@odata.bind` contra los esquemas generados). El test no puede viajar genérico
  porque depende de `.power/schemas/` del proyecto; el arnés ofrece el arranque y cada proyecto
  lo adapta.
### Cambiado
- `desarrollador`: lee los playbooks declarados antes de codificar y respeta sus convenciones.
- `qa-tester`: nuevo paso 9 — verifica cumplimiento de playbooks y sus tests guardián;
  el incumplimiento es hallazgo.
- `AGENTS.md.tpl` §2 Stack: nueva subsección *Playbooks de plataforma aplicables* para que
  cada proyecto declare los que usa.

## [1.12.0] — 2026-06-20
### Añadido — sistema anti-deriva (cierra el lazo requerimiento↔implementación)
Evita que los cambios forzados por hallazgos de QA/seguridad queden solo en el código o en un
log y el REQ termine describiendo algo distinto de lo construido. Tres capas:
- **Política (`AGENTS.md` §9):** nuevo caso **"Cambios por hallazgo"** — un hallazgo no se
  cierra hasta que el requerimiento lo refleje (criterio de aceptación nuevo si es de QA, o NFR
  nuevo/actualizado si es de seguridad), con causa enlazada y ADR si es de fondo. El write-back
  lo hace el `analista-requerimientos`.
- **Máquina (`guard-completado`):** veredictos en el REQ — campos `QA:` y `Seguridad:`. El hook
  **impide `completado`** sin `QA: aprobado`, y un REQ `Sensible a seguridad: sí` sin
  `Seguridad: aprobado`. Compatible con REQ antiguos (solo exige el campo si está presente).
- **Cierre (`/arnes-close` + `DELIVERY.md`):** verificación **"Trazabilidad y no-deriva"**
  bloqueante por cada REQ `completado` (criterios/NFRs reflejan lo construido; cada hallazgo
  traza a REQ/NFR/ADR o está `aceptado`).
### Cambiado
- Plantilla de REQ: campos `QA:` y `Seguridad:`; documentados en `requirements/README.md`.
- Agentes: `qa-tester` fija `QA:` y exige write-back de su hallazgo antes de aprobar;
  `auditor-seguridad` fija `Seguridad:` y no levanta el veto sin el NFR; `analista` es
  responsable del write-back e inicializa los veredictos.
- `AGENTS.md` §13: nueva fila de enforcement y nota del **techo honesto** (la máquina no
  verifica equivalencia semántica; la reconciliación final es la verificación de cierre).
- Escenario de hooks: +4 casos de veredictos QA/Seguridad.

## [1.11.0] — 2026-06-20
### Cambiado
- `auditor-seguridad`: reestructuración integral del agente (supersede y amplía el checklist
  de 1.7.0), agnóstica del stack y anclada a OWASP Top 10 Web / API / LLM:
  - **Principio agnóstico del stack:** audita principios; el mecanismo concreto (secretos,
    aislamiento en BD, identidad, defaults de cloud) se lee de `AGENTS.md`. Nombres de producto
    como ejemplos, no como único mecanismo válido.
  - **Disparador obligatorio por el flag `Sensible a seguridad:`** del analista (cadena
    analista → auditor → QA atada por máquina).
  - Checklist por áreas: **Identidad/acceso** (+ validación de JWT, BFLA, sesión con OAuth/OIDC),
    **Config/exposición** (defaults de BaaS/cloud, inventario de endpoints huérfanos, CORS,
    subdomain takeover), **Entrada/salida** (XSS, deserialización, **SSRF**+IMDSv2, open redirect,
    verificación de webhooks), **Criptografía**, **Lógica de negocio/concurrencia** (abuso de
    flujo, TOCTOU), **Resiliencia** (GraphQL), **Cadena de suministro** (slopsquatting,
    toolchain de IA/MCP), **LLM**, **Gobernanza**.
  - **Regresión de seguridad entre iteraciones:** compara contra el estado aprobado en
    `registro-seguridad.md` para cazar controles que la IA debilita silenciosamente.
### Coherencia
- Veto reflejado en la línea `Estado:` del REQ (corrige `estado:`/frontmatter de la propuesta),
  consistente con dev/QA/analista.

## [1.10.0] — 2026-06-20
### Cambiado
- `analista-requerimientos`: revisión integral con foco en **completar lo no dicho**:
  - **Postura de interrogación**: indagar comportamiento ante error, casos negativos, límites
    y supuestos implícitos, no solo transcribir lo que el usuario describe.
  - **Criterios de aceptación testeables** (concretos, observables, medibles) y **Gherkin con
    escenarios de error/borde**, no solo el camino feliz — es lo que el QA usa para falsar.
  - **NFR cuantificados** con número y unidad; sin umbral → `borrador`.
  - **Sensibilidad a seguridad marcada en el origen** (mismo disparador que el gate de QA).
  - **Conflictos** registrados explícitamente; el REQ no avanza hasta resolverlos.
  - **Definition of Ready** explícita; al cumplirse, el REQ pasa de `borrador` a `pendiente`.
### Añadido
- Plantilla de REQ (`requirements/README.md`): campo `Sensible a seguridad:` y sección
  `Preguntas abiertas / conflictos`, para que el flag de seguridad y los conflictos tengan
  un lugar máquina-legible.
### Coherencia
- Vocabulario de estados del analista alineado al canónico (incluye `pendiente`, que la
  propuesta omitía); `pendiente` queda definido como "cumple Definition of Ready, listo para dev".
- Estado nombrado como línea `Estado:`, consistente con `desarrollador` y `qa-tester`.

## [1.9.0] — 2026-06-20
### Cambiado
- `qa-tester`: revisión integral del agente con foco en **falsación** (no solo confirmar):
  - **Postura adversarial**: asumir el código roto y probar entradas vacías/nulas/malformadas,
    límites, concurrencia/idempotencia y el camino de error de cada dependencia externa.
  - **Cuestionar el REQ**: devolver al analista los criterios intesteables/vagos en vez de
    aprobar contra un REQ pobre.
  - **Flakiness**: un test no determinista no es evidencia; se reporta como flaky.
  - **Carga no concluyente**: una prueba de carga no representativa no cuenta como "cumple".
  - **Independencia**: QA solo edita tests/fixtures/guía de usuario, nunca el código de la app
    (reforzado por el hook `guard-codigo`).
  - **Visto bueno de seguridad determinista** para REQ que tocan auth/datos/secretos.
  - **Artefacto persistente de hallazgos** en `docs/qa/REQ-XXX.md` (no el chat).
  - Cierre de estado coherente con los gates: completa, salvo gate humano → `PENDING_APPROVAL.md`.
### Añadido
- Carpeta `docs/qa/` (hallazgos de QA por REQ) al andamiaje (`arnes-init`) y al mapa de `AGENTS.md`.
### Coherencia
- Estado del REQ nombrado como `Estado:` (línea), consistente con la plantilla y con el `desarrollador`.
- Manifiesto `.arnes/config.json`: se aclara que `codigo_app.globs` apunta a código de
  producción (tests fuera), para que QA pueda editar pruebas sin chocar con el hook `guard-codigo`.

## [1.8.0] — 2026-06-20
### Cambiado
- `desarrollador`: revisión integral del agente y **pasa a modelo Opus** (antes Sonnet).
  - **Robustez:** de "envuelve todo en `try/catch`" a manejo en un **boundary central** (sin
    catches vacíos); redacción de logs sin tokens/PII; idempotencia y condiciones de carrera.
  - **Mecanismo exacto de estado** del REQ (línea `Estado:` del archivo, no índices paralelos)
    y regla de **`bloqueado` ante ambigüedad/conflicto** en vez de adivinar.
  - **Jerarquía ante conflictos:** NFR de seguridad > alcance del REQ > convenciones de `AGENTS.md`.
  - Nuevas secciones **Calidad y eficiencia** (solución más simple, evitar N+1/O(n²), separar
    dominio/infra) y **Pruebas** (el dev escribe las pruebas automatizadas del REQ).
  - **Definition of Done** explícita; `description` con límites de rol (no QA ni auditoría).
  - `ARCHITECTURE.md` se actualiza solo cuando cambia la vista de sistema, no por cambios internos.
- `AGENTS.md.tpl`: §5 refleja `desarrollador` en **Opus**; §7 incorpora que las pruebas
  automatizadas son parte de cada REQ (las escribe el desarrollador).

## [1.7.0] — 2026-06-20
### Añadido
- `auditor-seguridad`: cinco categorías explícitas en el checklist, nombradas para que no se
  pasen por alto:
  - **Ciclo de vida de la sesión / caducidad:** expiración del lado del servidor por
    inactividad (idle) **y** por vida máxima absoluta; cookies `HttpOnly`/`Secure`/`SameSite`;
    rotación del id de sesión; sesiones de verificación de un solo uso.
  - **BOLA / autorización a nivel de objeto (IDOR):** verificar pertenencia del recurso al
    usuario/tenant en endpoints que reciben un id, no solo que haya sesión válida.
  - **RLS / aislamiento en la BD:** Row-Level Security como defensa en profundidad de BOLA
    (multi-tenant); cuidado con el pooling y con roles que evaden RLS.
  - **Mass assignment / over-posting:** exigir whitelist de campos escribibles; campos
    sensibles (rol, tenant, permisos) nunca asignables desde el body.
  - **Fuerza bruta y abuso de credenciales** (límites por IP y por cuenta, backoff/CAPTCHA,
    mensajes genéricos, MFA) y **Agotamiento de recursos / DoS** (límites de body/JSON,
    paginación con tope, descompresión, ReDoS, timeouts), desdoblando el antiguo
    "Resiliencia y abuso".

## [1.6.0] — 2026-06-20
### Añadido
- **Enforcement por runtime (hooks `PreToolUse` del plugin)** — bajan a mecanismo lo que antes
  era prosa en `AGENTS.md`:
  - `hooks/guard-codigo.sh` (**A1**): deniega editar el código de la app (`codigo_app.globs`)
    a quien no sea el agente `desarrollador`. Distingue coordinadora vs. subagente por el
    campo `agent_id` del input del hook.
  - `hooks/guard-completado.sh` (**A2/A3**): deniega marcar un REQ como `completado` si hay
    aprobaciones pendientes en `PENDING_APPROVAL.md` o si alguna quality gate falla.
  - `hooks/hooks.json` + `hooks/lib.sh`; el plugin auto-descubre `hooks/hooks.json`.
- **Manifiesto machine-readable** `templates/arnes-config.json.tpl` → `.arnes/config.json`:
  fuente de verdad ejecutable (agente de código, globs de app, quality gates, estados).
- `arnes-init`: emite y rellena `.arnes/config.json`; entrevista por los globs de app.
- `AGENTS.md.tpl`: nueva §13 "Enforcement por runtime" y notas 🔒 en §5/§6/§7.
- Escenario de regresión `tests/escenarios/hooks/run.sh` (prueba los hooks en aislamiento).

### Notas
- Los hooks son **inertes** sin `.arnes/config.json` (no estorban en repos ajenos al arnés) y
  requieren `jq`; sin él, el enforcement queda inactivo con aviso por stderr (no bloquea).
- El gate de aprobación se enforce como `PreToolUse` deny (no como `Stop` hook): un `Stop`
  con `block` haría *continuar* al modelo, no detenerlo para el humano.

## [1.5.0] — 2026-06-04
### Añadido
- `auditor-seguridad`: nuevas categorías en el checklist de auditoría:
  - **Ataques web a LLM** (inyección de prompts directa/indirecta, manejo inseguro de la salida, agencia excesiva, fuga de system prompt), alineado con OWASP Top 10 for LLM Applications.
  - **CSRF** (token anti-CSRF y/o SameSite en endpoints que cambian estado).
  - **Subida de archivos** (validación por magic bytes, límites, nombres saneados, almacenamiento fuera del webroot sin ejecución).
  - **XXE** (parsers con entidades externas y DTD deshabilitadas).
  - **Web cache deception** (rutas con datos sensibles no cacheables).
  - **CVE y versiones** (vulnerabilidades cruzadas contra la NVD del NIST, con CVE y versión corregida; versiones ancladas).

## [1.4.1] — 2026-06-01
- `qa-tester`: la escalada por límite de reintentos nombra el mecanismo explícito — `bloqueado` + registro en `docs/ESTADO.md` + escalada al humano vía `PENDING_APPROVAL.md` con parada del pipeline.

## [1.4.0] — 2026-06-01
### Añadido
- Política explícita de **cambios de requerimientos** (versionado y deriva) en `templates/AGENTS.md.tpl`.
- Bloque **Historial de cambios** en la plantilla de REQ (`templates/requirements-README.md.tpl`).
- `analista-requerimientos`: versiona el REQ, registra causa y enlaza ADR ante cambios/deriva.
- `qa-tester`: reporta deriva y devuelve el REQ en vez de aprobar contra uno desactualizado.
- ADR del plugin: `docs/decisions/ADR-001-politica-cambio-requerimientos.md`.

## [1.3.3] — 2026-06-01
- La sesión coordinadora delega los cambios de código en el `desarrollador` (sobre todo al depurar). `memory/` ignorado.

## [1.3.2] — 2026-06-01
- Robustez ante entradas no normalizadas (dev) + QA prueba variantes (capitalización/espacios/ausente/inválido).

## [1.3.1] — 2026-06-01
- QA verifica integridad de dependencias (lockfile sincronizado y deps coherentes).

## [1.3.0] — 2026-06-01
- Nueva skill `/arnes-panel` (panel HTML interactivo de estado, solo lectura).

## [1.2.0] — 2026-06-01
- Robustez (try/catch) en dev; defensa anti-inyección/abuso en auditor; NFR de rendimiento en QA. README sin referencias externas.

## [1.1.0] — 2026-06-01
- Estructura inicial: 4 agentes, skills `/arnes-init` y `/arnes-close`, plantillas, hook pre-commit y tests.
