# Requerimientos — ArnesJuan

Esta carpeta es el **contrato compartido**: la única fuente de verdad sobre qué hay que hacer y qué falta. Todos los agentes leen y actualizan estos archivos.

## Tipos
- **REQ-xxx** — Requerimiento funcional (una capacidad del sistema).
- **NFR-xxx** — Requerimiento no funcional (seguridad, rendimiento, límites).

## Estados
| Estado | Significado |
|--------|-------------|
| `borrador` | Redactado, pendiente de confirmación del usuario |
| `pendiente` | Confirmado, aún no iniciado |
| `en-progreso` | El desarrollador lo está codificando |
| `en-revisión` | Terminado, en validación de QA / seguridad |
| `completado` | Pasó todas las quality gates + QA + seguridad |
| `bloqueado` | Detenido por una dependencia o veto (indicar motivo) |

Un REQ solo pasa a `completado` cuando: criterios de aceptación cumplidos + quality gates en verde + visto bueno de seguridad.

## Veredictos de validación (campos del REQ)

**Los campos valen sólo en la cabecera: antes del primer `## `.** Una línea `Seguridad: aprobado` dentro
de `## Historial` o de cualquier otra sección **no es un veredicto** y la máquina no la lee. Medido: así
una línea de log cerraba un REQ crítico con la cabecera en `pendiente`. Si un REQ tiene sus campos
debajo de una sección, súbelos.
Cierran el lazo de hallazgos para que no haya deriva silenciosa:

**Un paréntesis final es evidencia, y la evidencia no cambia el veredicto.** Escribe
`QA: aprobado (medido el 3/9, 42 pruebas)` sin miedo: el hook compara `aprobado` y el paréntesis
queda en el REQ, que es donde sirve. Poner la evidencia al lado de la afirmación es media razón
de ser de este arnés.

> **Y por eso mismo, un matiz que cambia el veredicto NO va entre paréntesis: es otro veredicto.**
> Una auditoría preventiva se escribe `Seguridad: preventiva`, no `aprobado (preventiva)`. Si
> escribes `aprobado (con reservas)` contará como **aprobado**, porque el paréntesis significa
> una sola cosa.
- `QA:` — veredicto del `qa-tester`: `pendiente` | `aprobado` | `con-hallazgos`.
- `Seguridad:` — veredicto del `auditor-seguridad`: `n/a` | `pendiente` | `aprobado` |
  `con-hallazgos` | `preventiva` | `vetado` (al marcar el REQ `Sensible a seguridad: sí`,
  pásalo de `n/a` a `pendiente`).
  - `con-hallazgos` es **lo intermedio**: ni «no he mirado» (`pendiente`) ni el freno
    formal con remedio, dueño y umbral (`vetado`). Es el estado más común de una
    auditoría real, y **no cierra** un REQ crítico: como todo valor distinto de
    `aprobado`, sirve para decir la verdad, no para firmar.

**Un valor fuera de estos vocabularios se avisa al escribirlo.** Si escribes un veredicto
que la máquina no reconoce, el arnés te lo dice en ese momento —sin denegar la edición— y
te enseña la lista de valores válidos. No es una regla nueva: es que antes un REQ podía
pasar semanas con un campo que ninguna puerta leía, y nadie se enteraba hasta que fallaba
el cierre.

**La fecha del veredicto también va en el paréntesis, con su ronda:**
`QA: aprobado (R-045, 2026-09-01)`. Un veredicto es una foto, y una foto sólo vale si el
sujeto estaba quieto: un `aprobado` sin fecha sobrevive a los cambios del código que
juzga. Si el proyecto enciende `veredictos.exigir_fecha` en `.arnes/config.json`, un
`aprobado` sin fecha `AAAA-MM-DD` no cierra; con `veredictos.caducan_con_codigo` tampoco
cierra un veredicto anterior al último commit que tocó el código de la app, ni con
cambios sin comitear en ese código. Las dos vienen **apagadas**.

**Tu historia puede archivarse; tus criterios no.** Si el proyecto lo activa, el arnés
mueve las entradas viejas de la sección de historia de este REQ a un archivo aparte y
deja un puntero. **Mueve, no resume, y no toca ni una línea del resto del documento** —ni
la cabecera con sus veredictos, ni los criterios de aceptación, que son el contrato.

**En el bloque derivado de `docs/ESTADO.md` los veredictos se muestran recortados a 40
caracteres** con un `…` al final. Es sólo presentación: la puerta lee el valor **entero**,
así que un `Hallazgos abiertos:` largo no pierde su clase por salir recortado en la
tabla.

**El orden importa:** `Seguridad: aprobado` no se escribe mientras `QA:` siga en `pendiente` o
`con-hallazgos` — el auditor no mira las quality gates, así que su firma sobre un árbol sin
validar acreditaría algo que no revisó. El hook lo impide **en cualquier edición del REQ**, no
sólo al cerrarlo, porque el daño se hace al escribir el veredicto. La única salida es la
auditoría **preventiva** —hecha antes de que exista el código—, que se declara al emitirla
como `Seguridad: preventiva` y **no** cubre el código posterior.

El hook `guard-completado` **impide** marcar `completado` sin `QA: aprobado`, y un REQ
`Sensible a seguridad: sí` sin `Seguridad: aprobado`. Llegar a "aprobado" exige que los
hallazgos estén resueltos **y reflejados en el REQ/NFR** (write-back, ver `AGENTS.md` §9).

**Cada clave de control se escribe una sola vez, y como la escribe la plantilla.** Las claves de
control son las seis cuya presencia o ausencia decide el cierre: `Estado`, `QA`, `Seguridad`,
`Sensible a seguridad`, `Hallazgos abiertos` y `Rigor` (lista cerrada; en el código del arnés vive una
sola vez). Si la cabecera escribe una de ellas **de otra forma** —una
*variante*— o la declara **más de una vez**, **aunque las dos líneas digan lo mismo**, la cabecera es
**ambigua** y la puerta **deniega el cierre** citando las líneas —las primeras, y cuántas más hay—, con
los caracteres invisibles escritos de forma legible; `tools/arnes-lectura.sh` las nombra todas. No lee la variante como la clave ni elige entre dos declaraciones, y ningún lector
cambia el valor que lee. **A qué ediciones alcanza esta regla:** a las que la puerta puede
reconstruir: un `Write`, o un `Edit`/`MultiEdit` reconstruible según REQ-023 CA-13 del repositorio del
arnés, que es la sede única de esa definición. **Una edición que la puerta no puede reconstruir no
queda fuera ni pasa:** la deniega esa otra regla antes de llegar a ésta. **Tampoco pasa un
`Edit`/`MultiEdit` de un REQ que la puerta no puede leer entero:** lo deniega REQ-007 CA-45 del mismo
repositorio, que dice también cómo se juzga un `Write` sobre él. **Cuándo deniega, dicho entero
para ese alcance:** cuando la cabecera que quedaría escrita es
ambigua, **alguna** de sus líneas `Estado` —la exacta, una repetida o una variante— dice el estado
terminal, y la línea `Estado` que gobierna en disco (la primera declaración exacta; si no hay ninguna,
nada lo decía) **no** lo decía. Nada más: reabrir o editar un REQ cuyo `Estado` que gobierna en disco ya
es el terminal no se bloquea por esto, ni una edición tras la cual ninguna línea `Estado` dice el
terminal. **Consecuencia:** si en disco el terminal está en una línea `Estado` que **no** es la que
gobierna —una variante, o una declaración exacta que no es la primera— y la que gobierna no lo dice o no
existe, se deniega toda edición **de ese alcance** que conserve esa línea mientras la cabecera siga
siendo ambigua, aunque no toque el estado; la que la retira, la corrige o deshace la ambigüedad no se
deniega por esto. Para `Hallazgos abiertos` repetida con su forma exacta decide su propia regla, con
su limitación SEC-118 («Clases de hallazgo», abajo).

**Qué es una variante, por propiedad.** Una línea de la cabecera —antes del primer `## `, fuera de todo
`<!-- … -->`, con dos puntos ASCII (`:`)— cuya clave, tras la tolerancia de siempre (blancos de los
extremos, `*`, `_` y `` ` ``) y tras quitar **como mucho un** marcador de lista inicial (`-` o `+`
seguido de un blanco; o de 1 a 3 dígitos seguidos de `.` o `)` y de un blanco; los caracteres
invisibles que lo precedan no impiden reconocerlo), tiene **las mismas
letras ASCII**, sin distinguir mayúsculas, que una clave de control, y no es exactamente esa clave.
Para comparar —nunca para leer— se descartan los espacios, los caracteres de control y todo carácter no
ASCII. Ejemplos **no exhaustivos**: `HALLAZGOS ABIERTOS:`, `qa:`, `Hallazgos  abiertos:` (blanco doble),
la clave con un BOM, un espacio de anchura cero o un espacio duro delante o dentro, `- Rigor:` y
`1. QA:`. Una línea con exactamente la forma de una declaración (`- Estado: …`) se trata como tal.

**Lo que no es una declaración, y por tanto no es variante:** una línea cuya clave, tras el marcador,
contiene un signo ASCII visible que no es letra —`>`, comillas, paréntesis, corchetes, dígitos, `&`,
`/`, `.`, etc.— o una comilla tipográfica (`«` `»` `“` `”` `‘` `’` `„` `‹` `›`, lista cerrada): es una
cita, una mención o una referencia. Ejemplos **no exhaustivos**: `> Estado: completado`,
`«Estado»: …`, `(QA): …`, `Q&A: …`.

**Fuera, y sin promesa:** una letra cambiada por otra que se le parece (`Hallazgоs` con `о` cirílica,
letras de ancho completo); una letra ASCII de más, de menos o distinta (`Hallazgo abierto:`, `Rigr:`);
unos dos puntos que no son ASCII (`：`); las líneas con un signo visible de los de arriba, aunque lleven
además un carácter invisible; un espacio duro en lugar del blanco que sigue al guion o al número del
marcador (`-`+espacio duro+`Estado:`), que ya no forma marcador y deja el `-` como signo; y las claves de
**más de 256 bytes**. Todo eso se sigue leyendo como hasta ahora: como si la línea no declarara el campo, que
para ese campo es su **ausencia**. Las claves de más de 256 bytes son una **limitación**: se leen como
ausencia y ese límite **no las protege**. Esta regla mira la **clave**: el valor se lee como siempre.
**La edición que la puerta no puede reconstruir ya no está en esta lista.** Un `Edit`/`MultiEdit` cuyo
`old_string` sólo coincide tras la normalización que aplica la herramienta —comillas tipográficas,
`\uXXXX`— **se deniega**. La norma está en REQ-023 CA-13 del repositorio del arnés (ADR-015), que es la
vía de SEC-117. Para editar un REQ, copia el `old_string` literal del archivo.

## Nivel de rigor
Cuánta demostración se exige **por encima** de las quality gates, que son binarias y corren
siempre. Lo fija el analista en la cabecera del REQ.

| Nivel | Qué corre | Cuándo |
|---|---|---|
| `ligero` | analista + desarrollador + quality gates | Sin lógica: textos, etiquetas, ajustes de presentación |

> `ligero` salta **sólo** los veredictos de QA y seguridad. La clase del hallazgo, las aprobaciones humanas
> pendientes y las quality gates corren igual que en cualquier otro nivel.
| `estandar` | + QA | Lógica de negocio ordinaria |
| `critico` | + auditoría de seguridad | Dinero · datos personales · identidad o acceso · documento con efecto legal · cambio irreversible (esquema, migración, borrado) |

**Qué REQ de ESTE proyecto cae en cada nivel se decide en `AGENTS.md`, no aquí.** Los
criterios de arriba son independientes del dominio a propósito: el arnés trae el mecanismo,
cada proyecto pone el mapeo con sus ejemplos concretos.

**Reglas de gobierno:**
- **Lo fija el analista.** El auditor **puede subirlo**; nadie lo baja sin su firma.
- **Se puede subir, nunca bajar.** Un REQ marcado `Sensible a seguridad: sí` tiene `critico`
  como **suelo**: escribir `Rigor: ligero` ahí no lo baja. Bajarlo de verdad exige cambiar la
  sensibilidad, que es un campo visible del analista.
- **Si se omite, se deriva:** sensible → `critico`, si no → `estandar`. Es exactamente el
  comportamiento anterior a que existieran los niveles, así que un proyecto que no declare
  nada no nota ningún cambio.
- El rigor efectivo combina el nivel declarado con el suelo de seguridad. Un matiz
  parentético **bien formado** —el que **cierra el paréntesis al final del valor**,
  como `critico (por suelo)`— conserva `estandar` y `critico`, sujeto a ese suelo.
  Para mantener la protección heredada, `ligero` con matiz deriva a `estandar` si el
  REQ no es sensible y a `critico` si lo es. `ligero` sin matiz conserva su
  comportamiento, sujeto al suelo de seguridad.
- **Un paréntesis que no cierra al final del valor no es un matiz: es un valor
  desconocido**, y cae en la derivación heredada del punto siguiente. `critico (por
  suelo` (sin cerrar), `critico (` y `critico (x) y` (con texto detrás del cierre) se
  juzgan **`estandar`** en un REQ no sensible, así que un `critico` escrito así **deja
  de exigir la firma de seguridad, y no avisa**. Es la única protección que esta forma
  puede perder: en `ligero` y en `estandar` la derivación heredada da lo mismo, y en un
  REQ sensible el suelo de `critico` lo impide. Escribe el matiz cerrado, o no lo
  escribas.
- Un valor realmente desconocido conserva la derivación heredada: sensible →
  `critico`; no sensible → `estandar`. No garantiza conservar el nivel que el autor
  pretendía escribir; usa uno de los tres niveles válidos.

## Clases de hallazgo
Todo hallazgo abierto se declara en el campo `Hallazgos abiertos:` de la cabecera, con
su **clase entre paréntesis**: `SEC-121 (instrumento), SEC-144 (usuario/dinero)`.

**La sintaxis del campo es cerrada, y ésta es su sede única.** El valor es **una ausencia** —vacío,
`(ninguno)`, `n/a`, `-`: ejemplos no exhaustivos; la lista exacta la fija `guard-completado`— **o una
lista**: uno o más hallazgos separados **sólo por comas que estén fuera de todo paréntesis**. Cada
hallazgo es, exactamente y en este orden, `ID (clase)` o `ID (clase, evidencia)`:

- **ID**: letras ASCII, dígitos y `-`, sin blancos dentro (ejemplos no exhaustivos: `SEC-121`,
  `QA-030-03`, `H-07`).
- **clase**: lo primero dentro del paréntesis, hasta la primera coma o hasta el cierre; una de las
  tres de la tabla de abajo, sin distinguir mayúsculas ni blancos.
- **evidencia** (opcional): tras la clase y una coma, **dentro del mismo paréntesis**. Puede llevar
  comas, `;`, `·`, guiones y paréntesis anidados **equilibrados**, y **no declara nada**: un
  identificador o una clase escritos dentro de la evidencia no se leen.
- **Tras el `)` que cierra el hallazgo sólo cabe la coma que lo separa del siguiente, o el fin del
  campo.** Los blancos alrededor no cambian nada.

Todo lo que no casa con esa forma hace que la lista **no se pueda interpretar**, y entonces la puerta
**deniega el cierre** nombrando el fragmento que no entendió: no reescribe el campo, no lo repara y no
ignora la parte que no entiende. Ejemplos **no exhaustivos** —la regla es la de arriba—: un separador
que no es la coma (`;`, `·`, `/`, `y`), texto o una nota detrás del paréntesis, dos paréntesis en un
hallazgo, un paréntesis sin cerrar o uno sobrante, un elemento vacío (`,,` o una coma final), un
elemento sin ID, un ID con blancos dentro, con una tilde (`SÉC-1`) o con marcado (`` `SEC-1` ``), y una
ausencia mezclada con hallazgos. Lo que quieras anotar junto a un hallazgo va **dentro de su
paréntesis**, tras la clase y una coma: `QA-006 (instrumento, REQ-007)`, no
`QA-006 (instrumento) — REQ-007`. Un elemento **sin ningún paréntesis** (`SEC-4`,
`QA-006 [instrumento]`) es un hallazgo **sin clase** (abajo), y también deniega.

**Qué lee la puerta, y qué no.** La puerta juzga **el valor de la única línea de la cabecera** —antes
del primer `## `— cuya clave reconoce su lector como `Hallazgos abiertos` (también decorada,
`**Hallazgos abiertos:**`, o sangrada). **Si hay más de una, deniega** y las nombra: no elige la
primera ni la última y no las fusiona; se deja una sola línea con todos los hallazgos. **Aparte de esa
regla, su limitación conocida y sin reparar (SEC-118 del repositorio del arnés):** el motivo cita los
primeros 60 caracteres de cada línea repetida y viaja como un argumento de línea de órdenes, cuyo
límite es de **bytes**; por encima, el hook sale **sin decisión** y no deniega. Medido a nivel de hook
en Linux/WSL2, una corrida por punto —cifras operativas: mediciones, no umbrales—: con líneas **ASCII**
de 60 caracteres o más, 1 601 deniegan (motivo de 121 061 bytes) y 1 801 salen sin decisión; con líneas
**ASCII** cortas, 2 501 deniegan (111 961 bytes) y 3 000 salen sin decisión; con caracteres
**multibyte** en la parte citada, bajo `C.UTF-8`, salen sin decisión 1 601 líneas con `ñ`, 1 001 con
caracteres de 4 bytes y 2 501 cortas con `ñ`. No hay cifra para otros caracteres, hosts ni tamaños; en
Windows/MSYS no está medido, y que el cliente trate como permitir un hook sin decisión es inferido.
Dentro de esa
línea, ningún hallazgo que bloquea queda sin leer por el sitio que ocupa en la lista ni por el
carácter que lo separa del anterior. **Lo que el lector no reconoce como esa línea no se lee.** Si es
una **variante** de la clave —`Hallazgos  abiertos:`, `HALLAZGOS ABIERTOS:`, la clave con un carácter
invisible; definición y frontera en «Veredictos de validación», arriba—, la puerta **deniega el cierre**
por cabecera ambigua, sin leer su valor. En lo demás no hay promesa; ejemplos **no exhaustivos**: una
continuación en la línea siguiente sin clave, un homóglifo (`Hallazgоs`) y lo que queda fuera de esa
frontera, lo que va dentro de un comentario HTML de la cabecera y una línea igual debajo del primer
`## `.

**Techo de tamaño: 16 384 bytes.** Si el valor —todo lo que va tras los dos puntos, incluido el
blanco que los sigue, contado en **bytes** y antes de normalizar— mide **más de 16 384 bytes**, la
puerta deniega el cierre sin interpretarlo y dice el tamaño medido: una puerta que no puede medir no
deja pasar. Con 16 384 bytes o menos decide la clase, como arriba. La evidencia larga va al registro
del hallazgo y en el paréntesis queda la referencia. **El techo se mide en el lector, antes de
normalizar el valor**: por encima, el valor no se normaliza, no se recorta y ningún lector lo toma por
«sin hallazgos» (el bloque derivado de `docs/ESTADO.md` lo muestra como `(no medido: N bytes, techo
16384)`). **Esa denegación se promete hasta lo medido, y no más allá**, porque el hook tiene que
decidir dentro del límite del cliente (60 s) y un hook muerto no deniega. Medido en Linux/WSL2, una
corrida por punto, hook entero, lista no exhaustiva: 60 006 bytes → deniega por tamaño en 0,21 s;
255 371 bytes → 0,31 s por `Edit` y `MultiEdit` y 1,6 s por `Write`. Por encima de 255 371 bytes **no
hay promesa**: por `Edit` sigue siendo lineal (2 000 000 bytes → 2,1 s), pero por `Write` el contenido
entrante pasa antes por otra operación del hook que crece más que linealmente (1 000 000 bytes →
28 s; 2 000 000 → 84 s, por encima de los 60 s del cliente). En Windows/MSYS no está medido y será más lento.
Ese residuo tiene dueño y vencimiento en el `docs/PENDIENTES.md` del repositorio del arnés. Es una
limitación aparte de la regla —SEC-115 del mismo repositorio— y no forma parte de lo que la regla
promete.

| Clase | Qué es | Efecto en el cierre |
|---|---|---|
| `usuario/dinero` | Afecta lo que alguien ve, decide o cobra | **Bloquea.** Reabre el REQ |
| `contrato` | El requerimiento dice algo falso sobre lo construido | **Bloquea** hasta el write-back |
| `instrumento` | El control o la prueba tienen un defecto, sin efecto en el producto | **No bloquea.** Deuda técnica con dueño |

**Un hallazgo sin clase declarada no cuenta como hallazgo** — y la puerta deniega el
cierre hasta que se clasifique, porque no puede saber si bloquea.

Por qué existe la clase `instrumento`: un defecto del propio arnés —un lector de
umbral, un guardián— **no puede impedir cerrar una función de negocio**. Atacar
guardianes es valioso y tiene su propio ciclo; los hallazgos que produzca entran como
deuda con dueño, no reabren REQ de negocio.

## El mapa de archivos: el campo `Archivos:`

Todo REQ **abierto** —`pendiente`, `en-progreso` o `en-revisión`— declara en su cabecera una línea
`Archivos:` con lo que su implementación va a tocar. Existe para una sola pregunta, y es una que se
puede responder por máquina: **¿qué dos comisiones se pueden despachar a la vez sin que se pisen?**

**La forma, enunciada por propiedad y no como lista de casos:** rutas o **globs** relativos a la
raíz del repositorio, separados por **comas**; o el valor literal `(ninguno)` si el REQ no toca
ningún archivo del árbol. Un patrón vale si lo expande la shell contra el árbol —no hay una lista
cerrada de globs admitidos—; una ruta **absoluta** queda fuera de la forma y se rechaza.

```
Archivos: hooks/lib.sh, tools/arnes-lectura.sh, templates/*.tpl
Archivos: (ninguno)
```

Se escribe con las **mismas tolerancias que los demás campos de la cabecera, y ni una más**
—`**Archivos:**`, sangría, tabuladores, el valor entre acentos graves, un paréntesis final de
evidencia—, porque lo lee **el mismo normalizador** que las puertas. Y, como todos, **vale sólo en
la cabecera**: una línea igual debajo del primer `## ` no declara nada.

> **El paréntesis de evidencia acompaña a SU elemento — y por eso la coma de dentro no separa.** Este
> campo es una **lista**, así que la normalización se aplica **elemento a elemento**: anotar elemento
> por elemento —`Archivos: tools/x.sh (nuevo), hooks/lib.sh (modificado)`— **sí es una forma
> admitida**, declara **dos** archivos y colisiona con quien declare cualquiera de los dos. La
> evidencia puede ir en la primera posición, en una intermedia, en la última o en todas, y sigue
> siendo evidencia: `Archivos: hooks/lib.sh, tools/arnes-lectura.sh (medido el 6/9)` declara dos
> archivos, no tres. Dentro de un paréntesis la **coma no separa** —la evidencia las lleva—, de modo
> que `hooks/lib.sh (medido el 6/9, 2 archivos), tools/x.sh` son **dos** elementos; el reverso de esa
> convención es que lo que escribas dentro del paréntesis **no declara nada**. Y lo que no se entiende
> —un paréntesis **sin cerrar**, una anotación **suelta** entre dos comas— no se descarta en silencio:
> la herramienta lo **dice con su motivo**, el REQ pasa a `SIN DECLARAR` y colisiona con todos, nunca
> `disjunto`. Se rechaza **en voz alta** a propósito: hasta 1.32.0 un paréntesis intermedio borraba
> **en silencio** todo lo que venía detrás y la respuesta era `disjunto` con rc 0 sobre medio mapa
> (SEC-014). Si quieres anotar de dónde sale cada ruta con más detalle del que cabe en un paréntesis,
> va en el cuerpo del REQ; la cabecera es lo que lee la máquina.

> **Y un límite operativo con causa abierta: escribe las rutas SIN decoración de Markdown.** Envolver
> **cada** elemento en acentos graves o subrayado —`` `hooks/lib.sh`, `tools/x.sh` `` o
> `_hooks/lib.sh_, _tools/x.sh_`— **no es fiable hoy**: el desenvoltorio arranca el par **exterior**,
> que pertenece a dos elementos distintos, los dos quedan con un marcador impar y la herramienta
> responde `disjunto` con rc 0 sobre un mapa de rutas que no existen (**SEC-020**, `contrato`,
> **abierto**, ventana 1.33.0). No es una promesa de la máquina en ninguna dirección —es un fallo
> declarado, no una regla—: mientras el hallazgo siga abierto, la ruta **desnuda** es la única forma
> medida como segura, y un `disjunto` sobre un campo decorado no se toma por bueno. Envolver la línea
> **entera** (`` `hooks/lib.sh, tools/x.sh` ``) sí se lee bien, y por eso la tolerancia del párrafo
> anterior sigue enunciada como está.

**Lo que NO se declara: los artefactos de gobierno de quien orquesta, porque ninguna comisión los
escribe.** La regla está **en vigor de facto desde el 2026-09-07** —desde el primer despacho paralelo
real— y se escribe aquí por decisión del propietario del **2026-09-08**. Se escribe porque una regla que
se aplica sin estar en el contrato **se reinterpreta cuando conviene**, que es la misma clase que
`SEC-053` (`contrato`, **abierto**, severidad alta: un criterio de publicación aplicado sin su frontera
escrita, y bajo el que ya se publicó una versión — `docs/seguridad/registro-seguridad.md:4470-4481`).

**La propiedad, con sus dos caras, que es la única forma de que decida el caso siguiente:** un artefacto
es **de gobierno** si su contenido es el **resumen de la orquestación** —lo que quien orquesta ya tiene
por haber orquestado— y **no** evidencia que sólo posee quien la produjo. La cara que **saca** del campo:
lo escribe quien orquesta, así que ninguna comisión lo toca y no entra en ningún conjunto de escritura.
La cara que lo **deja dentro**, y sin ella la propiedad no sirve para decidir nada: la **evidencia
primaria** —la reproducción, la cifra y las condiciones en que se tomó— sólo la tiene quien la midió, de
modo que el registro de hallazgos de QA y `docs/seguridad/registro-seguridad.md` **sí** son conjunto de
escritura de su comisión y **sí** se declaran; trasladarlos obligaría a una segunda transcripción del
mismo contenido y le arrancaría a cada cifra su condición. Ejemplos **no exhaustivos** de la primera
cara, ya decididos: `CHANGELOG.md`, `docs/ESTADO.md` —cuyo bloque entre marcadores **lo deriva el hook**
y cuyo texto de fuera es de la coordinadora— y `PENDING_APPROVAL.md`, que es la cola de decisiones
humanas. La **lista declarada** no existe todavía: llega con **REQ-022 CA-04** a `.arnes/config.json`
(ventana 1.34.0), y hasta entonces decide la propiedad.

**Quita el archivo del mapa, NO la obligación.** `AGENTS.md` §8 sigue exigiendo entrada de
`CHANGELOG.md` en **todo** commit, y el hook `pre-commit` sigue denegando el commit sin ella: lo que
cambia es **quién** la escribe —quien comitea, que es quien orquesta—, no si se escribe. Y por eso la
objeción que esta regla responde era **correcta** mientras la regla no existía: omitir el libro mayor
fabricaba un `disjunto` falso entre dos comisiones que iban a escribir las dos en él
(`requirements/REQ-019.md:1446-1450`). Lo que la vuelve falsa no es una convención de higiene, es que
ahora **ninguna** lo escribe.

> **El límite, y va fuerte porque es donde esto se tuerce:** un campo se acota **sólo** cuando la
> comisión de verdad no escribe ese archivo. **Acotarlo para ganar paralelismo corrompe el mapa**, y un
> `disjunto` sobre un mapa corrompido no autoriza nada — que es exactamente **SEC-020**, abierto. La
> regla existe para **dejar de declarar una colisión que no existe**, no para esconder una que sí. De ahí
> el fail-closed, que aquí no lo puede llevar ninguna máquina: mientras un caso no esté decidido, **se
> declara**. Los dos errores no cuestan igual —de más es un `colisiona` falso, que devuelve a la serie un
> trabajo que podía ir en paralelo; de menos es un `disjunto` falso, que son dos comisiones escribiendo
> el mismo archivo y una **escritura perdida** que git no señala—, así que la duda cae **siempre** hacia
> declarar. Casos que la propiedad **no** cierra hoy, dichos por su nombre para que nadie los retire
> leyendo lo de arriba: `docs/PENDIENTES.md` —donde REQ-017 escribe una medición **como producto**— y el
> índice de ventana `docs/qa/<versión>.md`, cuya escritura el write-back de REQ-017 del 2026-09-07 hizo
> contar **a propósito**. Los resuelve REQ-022 (CA-04 y CA-06-bis) en 1.34.0.

**Y la limpieza de los campos ya escritos no la hace la comisión que escribe esta regla.** Hoy **11**
archivos de `requirements/` declaran `CHANGELOG.md`: **6** abiertos (007, 008, 011, 013, 014, 019), **3**
`completado` (012, 015, 016) y **2** en `borrador` (023, 024). Cada uno de los **abiertos** lo retira
**cuando se le toque por otro motivo**, o en una comisión propia con su medición; los `completado` se
quedan **idénticos**, por el mismo motivo que «Alcance temporal» más abajo, y los `borrador` al salir a
`pendiente`. Retirarlo de once archivos desde aquí sería escribir en once archivos que esta comisión no
tiene en su ámbito. *(Cifras **operativas**, corrida del 2026-09-08 sobre `cand/1.33.0`, `Estado:` leído
REQ a REQ y **no** por el índice; dirección buscada: **hacia 0** en los abiertos. Se mueven solas al
abrirse o cerrarse un REQ — el encargo de esta comisión traía **8** y REQ-022 CA-05 midió **9, 5 de 8
abiertos** el 2026-09-07, y ninguna de las tres cifras estaba mal.)* Lo que esta regla compra está
medido en la misma corrida: `tools/arnes-paralelo.sh` responde `colisiona` en **67 de 67** pares del
proyecto y casi todo sale de cuatro archivos, de los cuales el libro mayor es **el único que se puede
retirar sin mentir sobre el alcance**.

**Lo que esta regla NO es:** la regla general del campo —que declara el conjunto de **escritura**, ni más
ni menos, con el coste de cada uno de los dos errores— es **REQ-022 CA-07** y se escribe en su ventana.
Aquí sólo se retira del mapa una clase de artefacto que ninguna comisión escribe.

**Quién lo lee:** `tools/arnes-paralelo.sh`. Interseca los conjuntos de dos REQ **expandiendo los
globs contra el árbol real** —no comparando cadenas— y responde `disjunto` o `colisiona` nombrando
el archivo compartido. Comparar cadenas declararía disjuntos `hooks/lib.sh` y `hooks/*.sh`, que es
justo la forma de error que produce un conflicto de fusión. Un patrón que todavía no casa con nada
se conserva como ruta literal: un archivo que aún no existe es exactamente donde dos comisiones
chocan.

**Fail-closed, y el fail-closed vive en la herramienta:** un REQ sin el campo, o con un valor que no
se puede interpretar, se declara `sin declarar`, **colisiona con todos** y el comando sale ≠ 0. Sin
mapa no hay paralelismo, y el modo por defecto —la serie— es el que ya se usaba.

> **No es una puerta.** Ningún hook lee este campo y su ausencia **no impide cerrar** ningún REQ: un
> dato de coordinación no puede bloquear la corrección de lo construido. Lo único que cuesta no
> declararlo es que ese REQ no se puede paralelizar. Vive en la **Definition of Ready** del analista
> —un REQ no se entrega como `pendiente` sin su mapa—, que es una revisión humana y no una
> comprobación de runtime.

**Y lo que la herramienta no responde:** evalúa **archivos**, nunca el **orden de fases**. Dos REQ
disjuntos no autorizan a correr el `auditor-seguridad` a la vez que el `qa-tester`. Esa regla es
aparte y vive en `AGENTS.md` §6.

## Cambios de requerimientos
Un REQ **no se reescribe encima**: se versiona. Todo cambio se anota en el **Historial de
cambios** del REQ (fecha · antes→después · causa · ADR si aplica). Los cambios de fondo
generan un **ADR**. Si un REQ `completado` cambia, vuelve a `en-progreso`/`en-revisión` y
**re-recorre el ciclo**. Política completa en `AGENTS.md`, sección "Cambios de requerimientos".

## Metodología
**1. Historia de usuario:** Como **[rol]**, quiero **[acción]**, para **[beneficio]**.
**2. Criterios de aceptación en Gherkin:** **Dado** [contexto] **Cuando** [acción] **Entonces** [resultado].
**3. Requisitos no funcionales** se documentan como NFR separados y se referencian desde los REQ.

## Cómo se escribe un criterio que no se desmiente

**Medido, no opinado:** en un ciclo de trabajo de este arnés, **7 de 20** hallazgos no fueron que
el código estuviera mal, sino que el **criterio decía algo falso sobre lo construido** —clase
`contrato`—. Uno costó una **vuelta entera del bucle** (~50 min entre desarrollador, QA, control y
write-back). Las tres primeras formas de abajo son exactamente las que se midieron en ese ciclo;
**la cuarta se midió después, en la ventana 1.32.1, y sobre un criterio escrito ya con esta
sección delante** — de ahí que no baste con escribir la **regla** que el código implementa en vez
de la **lista** de casos que se le ocurrieron a quien redactó ese día: hay que además estar
midiendo la magnitud que se degrada.

Las cuatro están **prohibidas por nombre**. Un criterio que caiga en cualquiera de ellas está **mal
formado**: el QA lo reporta como hallazgo de clase `contrato` contra el REQ **antes** de ejecutar
la prueba, y quien lo reescribe es el analista (write-back, `AGENTS.md` §9).

### (a) Enumerar lo que el código reconoce

**Caso medido.** Un criterio listaba **tres** envoltorios de shell; el código toleraba **siete**.
El resultado se contó como hallazgo —«el código cerró un límite en silencio»— cuando lo que había
pasado es que el criterio se quedó corto. Una lista escrita en un contrato envejece **hacia el
lado que abre**.

- **Mal:** «Entonces se deniegan las formas envueltas en `if`, en `for` y en `{ }`.»
- **Bien:** «Entonces se deniega **todo token que el segmentador trate como envoltorio**, según la
  lista única de `hooks/guard-git.sh` (el `case` de prefijos del segmentador, que es el sitio del
  caso medido); ejemplos **no exhaustivos**: `if`, `for`.»

**Regla.** Un criterio que se refiera a un conjunto de cosas cuya pertenencia decide el código
—**cualquier** conjunto, sin excepción por el tipo de cosa que sea; ejemplos **no exhaustivos**:
envoltorios, prefijos, estados— enuncia la **propiedad de pertenencia**, **cita el
único sitio** donde vive la lista exhaustiva y, si añade ejemplos, los marca literalmente como
**«no exhaustivo»**. Un criterio que enumere **dos o más** elementos concretos sin (i) la marca
`no exhaustivo` **o** (ii) el puntero al sitio único está mal formado.

### (b) Fijar un número que la medición desmiente después

**Caso medido.** Un máximo de **262 144** bytes que la medición obligó a bajar a **131 072**. El
número no era el contrato: la **existencia de un techo** lo era. Como el criterio no decía de qué
tipo era su número, bajarlo costó un hallazgo y una vuelta en vez de una línea de Historial.

- **Mal:** «Entonces el tope de reconstrucción es de 262 144 bytes.»
- **Bien:** «Entonces el tope de reconstrucción es de **no más de** 262 144 bytes (**operativo**:
  se **baja** con la medición).»

**Regla.** Todo criterio con un número declara **en el propio criterio** cuál de los dos es:

| Tipo del número | Qué significa | Cómo se cambia |
|---|---|---|
| **operativo** | Sólo su magnitud está en juego: nadie fuera del sistema elige su conducta por ese valor exacto (topes de reconstrucción, tamaños de buffer, tiempos límite internos). Se escribe con **dirección admitida**: «**no más de** N; se **baja** con la medición» | **Cambio menor:** entrada en el Historial del REQ con la cifra medida. **Sin** ADR y **sin** cambio de alcance |
| **de contrato** | Alguien de fuera elige su conducta por ese valor: un umbral que un proyecto declara en su manifiesto, un límite anunciado en una plantilla | **No** cambia sin **ADR** y sin **write-back** en las plantillas que lo anuncian |

**Un número sin esa declaración se trata como de contrato** (fail-closed): si no se sabe quién
depende de él, no se puede bajar en silencio.

### (c) Exigir igualdad donde corresponde un techo

**Caso medido.** «El **mismo** número de procesos que la versión anterior.» El código bajó de **1
fork a 0** y el criterio declaró **incumplida una mejora**. Ése es el que costó la vuelta entera
del bucle.

- **Mal:** «Entonces el hook gasta el **mismo** número de procesos que la versión anterior.»
- **Bien:** «Entonces el hook gasta **no más de** 0 procesos añadidos respecto a la línea base;
  **menos** es conforme y **no** es hallazgo.»

**Regla.** Todo criterio sobre **coste** —procesos, tiempo, bytes, lecturas— se enuncia como
**techo con la dirección admitida declarada**, y **nunca** como igualdad. Y un techo bien puesto
sobre la magnitud equivocada sigue sin ver nada: ésa es la forma (d), que viene justo debajo.

### (d) Fijar la magnitud equivocada

**Caso medido — y lo que importa es que el criterio SE CUMPLÍA.** `CA-08` de REQ-016 contrataba el
coste de la noción de cita en **procesos por llamada**: 4 = 4, medido correctamente, criterio en
verde. Mientras tanto el reloj de la ruta crítica del banco se multiplicaba por **diez** (7,6 s →
75,7 s) y el banco entero —que es la **puerta requerida de `main`**— pasaba de 39 s a 92 s. No hubo
ningún número mal puesto ni ninguna medición mal hecha: la magnitud era correcta, medible sin ruido
y **ortogonal a lo que se degradó**. La pregunta era la que no era. Un criterio de coste que fija
la magnitud equivocada **da verde sobre una regresión de 10×**, y lo hace con toda la autoridad de
una medición correcta — que es peor que no medir, porque además tranquiliza.

- **Mal:** «Entonces el hook gasta **no más de 0 procesos añadidos** respecto a la línea base.»
  (bien formado según (c), y ciego a un factor de diez en el reloj)
- **Bien:** «Entonces (i) **no más de 0 procesos añadidos** respecto a la línea base **y** (ii) el
  **mínimo** de reloj es de **no más de 1,25×** el de la línea base, medidas **las dos en la misma
  corrida** — el arreglo no vale si compra tiempo con un `fork`, y el `fork` no se ve en el reloj
  ni el reloj se ve en los procesos.»

**Regla.** Todo criterio de **coste** declara **qué magnitud mide y por qué es ésa la que se
degrada**; si el mecanismo puede degradarse por más de una vía, **contrata todas las vías en el
mismo criterio y en la misma corrida** —dos magnitudes en dos criterios distintos se cumplen por
separado mientras el sistema empeora—. Y se enuncia como **razón o propiedad estructural**, **nunca
como un reloj absoluto**: un número de segundos lo falsea la máquina, lo falsea el runner del CI y
lo falsea la carga. Donde haga falta un absoluto, va como **razón contra una línea base medida en
la misma corrida**, no como una cifra: un runner lento sube el numerador y el denominador.

**Cómo se contrata una magnitud que no miente:**

| Lo que se quiere saber | Cómo se contrata | Por qué no miente |
|---|---|---|
| ¿El coste crece más que linealmente? | **Cociente de duplicación**: doblar la entrada y comparar los dos costes. Lineal ≈ 2, cuadrático ≈ 4 | La velocidad de la máquina **se cancela algebraicamente**: está en el numerador y en el denominador |
| ¿Cuesta más que antes? | **Razón contra una línea base medida en la MISMA corrida** (un tag anterior, la implementación previa) | Un runner lento o cargado sube los dos términos; la razón no se mueve |
| ¿Cabe en un límite duro de fuera (un `timeout`, una cuota)? | Se **mide y se anota** el margen; **mover** el límite es otro REQ con su dueño | El límite no lo elige este sistema, así que el criterio no puede fijarlo: sólo puede medirlo |

**El estadístico es el MÍNIMO de k repeticiones, nunca la media**, y k se elige para que el mínimo
de cada serie supere el suelo por debajo del cual el reloj no distingue del ruido (en este arnés,
50 ms). La carga sólo puede **añadir** tiempo, así que el mínimo es la mejor estimación del coste
real y la media es una mezcla del coste y de los vecinos. Y **una sonda que no llega a ese suelo, o
que no encuentra su línea base, emite SKIP con el motivo y con el número que sí obtuvo — nunca
PASS**: un instrumento que ante la ausencia de datos responde «verde» es la misma familia de
defecto que la magnitud equivocada.

### Cuando el código cubre MÁS de lo que el criterio promete

El criterio se actualiza **en el mismo cambio que lo descubre** —con entrada en el Historial
(antes → después) y la causa—, y **no** se deja para un hallazgo posterior. Un criterio **más
laxo** que lo construido programa un debilitamiento silencioso; uno **más estrecho** convierte una
capacidad en un hallazgo `contrato`. El reverso general de esta regla —la deriva— vive en
`AGENTS.md` §9.

### Y el reverso, para que esto no sea una coartada

Cuando el código **no** cumple el criterio, **no se relaja el criterio para que encaje**: se abre
el hallazgo **contra el código**. La regla de arriba aplica **sólo** cuando el código cubre
**más**. Ampliar un criterio para tapar una carencia es exactamente lo que `AGENTS.md` §9 llama
**deriva**, y esta sección no puede convertirse en su coartada.

### Dónde se anota la forma del hallazgo

La **forma** (`enumeración` · `número` · `igualdad` · `magnitud` · `otra`) se anota **sólo** en el log de QA
(`docs/qa/<versión>.md`), y **nunca** dentro del paréntesis de la clase del campo `Hallazgos
abiertos:`. Ese paréntesis es lo que lee `guard-completado` para decidir si un hallazgo bloquea:
meterle una segunda dimensión cambiaría la entrada de la puerta por un motivo de contabilidad.

### La clase, el forzador y el vencimiento se CITAN con archivo y línea; no se declaran

**Regla.** Un REQ que mencione un hallazgo —propio o ajeno— **cita** su clase, su forzador y su
vencimiento con **archivo y línea** del sitio único donde viven (`docs/seguridad/registro-seguridad.md`
para los `SEC-xxx`; el registro de QA para los suyos), y **no** los transcribe como si el REQ los
declarara. Dos transcripciones de la misma regla se desfasan, y ésta se desfasa hacia el lado que
**abre**: un REQ que diga `instrumento` sobre un hallazgo que el registro tiene como `contrato` cambia
la entrada de `guard-completado` por un motivo de redacción. Si las dos no coinciden, la equivocada es
la del REQ.

**La excepción, que no es una grieta: el campo `Hallazgos abiertos:` SÍ declara la clase.** Es la
entrada de la puerta, y una cita no se puede leer por máquina (ver «Clases de hallazgo»). La regla rige
para la **prosa** del REQ —criterios, notas, alcance—: el campo es el único sitio del REQ donde la clase
se escribe como **valor**, y ese valor tiene que **coincidir** con el sitio único.

**Y la forma (a) en pequeño, con su caso medido:** una cláusula del auditor citada **sin su calificador**
—las tres condiciones eran «formas **no exhaustivas**… la propiedad es la que decide, no la lista»— se
lee en el REQ como una lista cerrada de tres, y envejece hacia el lado que abre
(`docs/seguridad/registro-seguridad.md:4444-4453`). Citar con el rango es lo que lo evita.

**De dónde sale, y es la regla aplicada a sí misma:** es la deuda **`R-015-01`**, cuya clase, dueño,
forzador y vencimiento viven en `docs/seguridad/registro-seguridad.md:4461-4468` y **no se transcriben
aquí**. Mismo alcance temporal que el resto de esta sección: rige hacia delante.

### Alcance temporal

La regla rige para todo criterio **escrito o modificado desde que esta sección se adopta**. Los
REQ en estado `completado` **no** se reabren ni se reescriben para conformarlos: reescribir
contratos cerrados por un motivo de redacción es editar el contrato por comodidad, y multiplica el
coste que esta sección existe para bajar.

La forma **(d)** se incorpora con **el mismo alcance temporal** que las tres anteriores: rige para
los criterios escritos o modificados desde la ventana en que se adopta, y no reabre ninguno de los
ya cerrados.

### En la Definition of Ready del analista

Un REQ no se entrega como `pendiente` si alguno de sus criterios habla de **coste** sin decir **qué
magnitud mide y por qué es ésa la que se degrada**, o si lo fija como un **reloj absoluto** en vez
de como una razón o una propiedad estructural. Es la línea que añade la forma (d), y se comprueba
en la misma revisión humana que el mapa de archivos: ninguna de las dos es una comprobación de
runtime.


**En este repositorio la sección se adopta en 1.32.0** (REQ-012): rige para los criterios que se
escriban o modifiquen desde esa ventana, y los ocho REQ ya `completado` quedan **idénticos**.
**La forma (d) se adopta en 1.33.0** (REQ-017), con el mismo alcance: `CA-08` de REQ-016 —el caso
medido que la origina— **no** se reescribe, porque REQ-016 está `completado` y se cumplió tal como
estaba escrito. Ése es justamente el punto.
**La regla de «se citan, no se declaran» se adopta el 2026-09-08**, con el mismo alcance y sin dueño de
REQ: es doctrina del proyecto, no un criterio de ninguno. Ningún REQ se reescribe para conformarlo.

## Plantilla
```markdown
# REQ-XXX — Título
Estado: borrador
Módulo: (...)
Archivos: (rutas o globs relativos a la raíz, separados por comas — o `(ninguno)`)
Prioridad: (alta / media / baja)
Sensible a seguridad: (sí / no)
QA: pendiente
Seguridad: n/a
Hallazgos abiertos: (ninguno)
Rigor: (ligero / estandar / critico — ver abajo; si se omite, se deriva)
NFR relacionados: (NFR-xxx, ...)

## Historia
Como [rol], quiero [acción], para [beneficio].

## Criterios de aceptación
- Dado ... Cuando ... Entonces ...

## Notas / alcance
(detalles, fuera de alcance, dependencias)

## Preguntas abiertas / conflictos
(preguntas sin resolver; conflictos con otros REQs identificando ambos y la contradicción. Mientras haya algo aquí, el REQ se queda en `borrador`.)

## Trazabilidad
Origen: (fuente identificable del pedido: archivo y commit, o mensaje y fecha — o el literal `fuente no disponible`; un resumen del agente no es fuente)
Tocado por: (agente / fecha)

### Correspondencia con el encargo
(se establece al crear el REQ. Una fila por **obligación verificable** del pedido —algo cuyo cumplimiento se decide
sí/no contra el REQ o lo construido—, no por frase: una frase con dos obligaciones da dos filas, y una de contexto o de
motivo no da ninguna. Cada fila lleva su cita; si el pedido no se conservó, `fuente no disponible` en su lugar: nunca
se reconstruyen las palabras del propietario. «Relación» toma **exactamente** uno de estos valores: `cubierta`,
`omitida`, `sustituida`, `excluida` o `añadida` (decisión de negocio no pedida); **éste es el sitio único de ese
vocabulario** y todo otro texto que lo nombre remite aquí. La tabla se actualiza **sólo cuando cambia el alcance**, en
la misma fila del Historial de cambios que registra ese cambio (`AGENTS.md` §9); una reparación que conserva el
contrato la reutiliza, sin tabla nueva ni comparación completa, y una que altera qué obligación cubre un criterio no
conserva el contrato: es cambio de alcance. Una **autorización citada** es una copia fiel y verificable de la
decisión del propietario, o su confirmación concreta, registrada en una sede **localizable por ruta en el
repositorio** (ejemplos **no exhaustivos**: una entrada de `PENDING_APPROVAL.md` §«Resueltas», una fila del
Historial de cambios con la cita, un archivo bajo `docs/`); no exige archivar conversaciones completas. **Una
referencia cuyo contenido no puede verificarse no cuenta como autorización** para una decisión nueva que requiere
al propietario: la fila sigue sin resolver, lo que dependa de ella no se implementa, y el trabajo independiente
autorizado continúa. Para un REQ existente ya aprobado cuyo pedido o conversación original no se conservó, ver la
definición del `analista-requerimientos`: esa ausencia no invalida sus aprobaciones ni lo devuelve a `borrador`.)
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «...» (o `fuente no disponible`) | CA-xx | (uno de los cinco valores) | (ruta de la autorización verificable, o `→ Preguntas abiertas`) |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| AAAA-MM-DD | (creación) | — | — |
```

## Índice

> **Este índice es una copia a mano de campos que viven en la cabecera de cada REQ, y por eso se
> desfasa solo.** Sólo mandan los campos del propio REQ; si una celda de aquí los contradice, la
> equivocada es la celda. Se ha desfasado tres veces en un solo día de trabajo, así que está previsto
> convertirlo en un bloque **derivado** entre marcadores, como el de `docs/ESTADO.md`, y dejar de
> mantenerlo a mano. Mientras tanto, **no cites este índice como fuente**: abre el REQ.

| ID | Título | Estado | Rigor | QA | Seguridad |
|---|---|---|---|---|---|
| [REQ-001](REQ-001.md) | Dos bypass del enforcement en v1.30.2: cierre sustituyendo sólo el valor, y sustitución de comandos en heredoc sin citar. **Reabierto el 2026-09-30** (§9): CA-10, CA-11 y CA-12 versionados por **ADR-015** (SEC-117); sus firmas anteriores cubren sólo el contrato anterior | `en-revisión` | critico | aprobado (2026-09-30, cd47f06) | aprobado (R-047, 57129fb) |
| [REQ-002](REQ-002.md) | Veredicto fechado y no caduco: una firma no vale sobre código que cambió después | `completado` | critico | aprobado | aprobado |
| [REQ-003](REQ-003.md) | Un solo lector y un solo vocabulario: `con-hallazgos` en Seguridad, aviso al escribir fuera del vocabulario, y el informe que lee como la puerta | `completado` | critico | aprobado | aprobado |
| [REQ-004](REQ-004.md) | Rotación de UNA sección del documento: la historia se archiva, el contrato no se toca | `completado` | critico | aprobado | aprobado |
| [REQ-005](REQ-005.md) | Git destructivo prohibido a los agentes: el trabajo de un subagente no es atómico para git | `completado` | critico | aprobado | aprobado |
| [REQ-006](REQ-006.md) | Celdas del bloque derivado recortadas: un veredicto de 1 296 caracteres no cabe en una tabla | `completado` | critico | aprobado | aprobado |
| [REQ-007](REQ-007.md) | Huecos preexistentes del lector de campos, del detector de Bash y de las dos puertas de runtime, medidos en la QA y en la auditoría de seguridad de REQ-001: clave decorada, cabecera fuera de alcance, destino entrecomillado, heredocs que ciegan el detector, la clase del hallazgo en forma cerrada, bytes de control en banda, la barra duplicada que desactiva las dos puertas, el manifiesto inválido que apaga el enforcement en silencio, el manifiesto fuera de su propia frontera y la reconstrucción sin techo. **Versionado el 2026-09-30:** CA-46 (c) por ADR-015, y por **ADR-016** (quinta autorización) CA-45 a CA-50, CA-60 y CA-66 nuevo —las puertas juzgan el **archivo** que la escritura alcanzaría y no la forma de su ruta, y un REQ que la puerta no puede leer entero no se edita (SEC-119, O-11)—, en 1.35.0; **P-119-A** (fronteras no nombradas por el propietario), sin bloquear la implementación, **resuelta el 2026-10-03 como límites declarados**: F2, F5 y F7, y SEC-123 con F3 corregida, abiertos y **no aceptados como riesgo**, sin versión de reparación fijada; el REQ ya no tiene preguntas abiertas. **Versionado el 2026-10-01** (sexta autorización): CA-47 gana la **integridad de la entrada** —cada campo se lee entero— y dos causas de «no determinable» (un `file_path` o un `tool_name` con salto de línea), CA-45 lo comprobado en el host, CA-54 la nota de su incumplimiento abierto (QA-023-10) y CA-66 sus casos. **Versionado el 2026-10-02** (séptima autorización, QA-023-13): el retorno de carro del `tool_name`, el `cwd` y el `file_path` se cuenta antes del transporte —un `cwd` con retorno de carro no ancla y la ruta relativa es no determinable; un `file_path` o un `tool_name` con retorno de carro, como con salto de línea—, el del texto de `Bash` queda declarado como límite sin proteger (**P-023-13-A**, resuelta después por la octava autorización) y CA-66 gana el bloque R. **Versionado el 2026-10-02** (octava autorización: SEC-122, QA-023-14, P-023-13-A): F3 corregida —ningún directorio, tampoco `/dev/` ni `/proc/`, queda fuera de la identidad del destino—; lo que depende del proceso que abre la ruta se detecta y, si no se puede determinar, no pasa; la entrada se lee cruda y el texto de `Bash` llega con sus retornos de carro; un heredoc con un retorno de carro en el delimitador se deniega; CA-66 gana la sección 45 y una clase de movimiento de `deny` a `allow` declarada; tras la pasada correctiva, `guard-git` juzga cada orden también sin sus retornos de carro y la ruta de un enlace a un descriptor se juzga por las tres vías (QA-023-16, QA-023-17 y **P-122-A**, resuelta por reparación). **Versionado el 2026-10-03** (novena autorización, fase 1, SEC-123): F3 y el punto 16 de CA-47 describen el límite de la detección de lo que depende del proceso con su umbral por propiedad, lo medido, lo inferido y su consecuencia —puede ser un permiso sobre un archivo protegido—, sin repararlo ni aceptarlo (en **P-119-A**, hoy resuelta como límite declarado, no aceptado como riesgo). **Versionado el 2026-10-03** (novena autorización, fase 2, SEC-124 y SEC-125; **construido en `10ac6c4` y `36a0d27`; validado por el propietario por vía manual (`docs/qa/REQ-023.md`, CI run 37163342218); sin firma del qa-tester ni del auditor-seguridad por impedimento del proveedor**): CA-47 gana el punto 18 —un heredoc cuyo cuerpo tiene una línea que es su delimitador seguido de un retorno de carro, con algo detrás, se deniega por su forma, a todo agente y con un motivo que nombra SEC-124: restricción concreta decidida por el propietario (opción B)— y el punto 19 —el destino tras una continuación de línea se juzga como el que escribe el shell, sin denegar por la mera continuación, salvo una excepción nombrada que decidió el propietario (P-LC10-A, opción A): la continuación al final de la línea que abre un heredoc se deniega por la forma, a todo agente, en las cuatro puertas, con un motivo que nombra SEC-125 y LC10—; CA-66 gana sus casos, movimientos (una clase nueva de `deny` a `allow`, la de SEC-125) y coste. **Versionado el 2026-10-03 en la apertura de 1.36.0** (pedido del propietario, «Encargo 2»; **sin construir**), en su orden de prioridad: la nota de **CA-54** fija cómo se acredita QA-023-10 —< 5 s en el máximo en Linux/WSL2 con las sondas existentes, la misma decisión que v1.35.0, ningún veredicto del banco cambiado (inventario caso a caso) y sin subir el umbral ni reducir la entrada—; **CA-47 punto 20** (SEC-120: una entrada que `jq` no puede leer o trocear deniega; ilegible es todo lo que no sea exactamente un objeto JSON; 0 procesos añadidos sobre el camino común —medido +0, y +1 en una entrada ilegible, el de emitir la decisión—; sin `CLAUDE_PROJECT_DIR` es inerte si no puede obtener el proyecto y deniega si del `cwd` de la entrada obtiene uno con manifiesto, límite declarado —decisiones del propietario del 2026-10-05, la última P-136-H—; la entrada estándar cerrada, pendiente hasta SEC-127 y no límite, P-136-I, QA-007-06); y el **Bloque L** —**CA-67** (SEC-118: toda denegación decidida se emite), **CA-68** (SEC-115: un hook que no termina a tiempo emite `deny`) y **CA-69** (evidencia común, línea base v1.35.0)—, con **ADR-017** (aceptada el 2026-10-03) y las decisiones del propietario **P-136-A a P-136-C** (décima autorización, 2026-10-03) y **P-136-D** (2026-10-05: CA-54 (c) aclarada, atajo de `guard-completado` con condición de equivalencia), resueltas en `PENDING_APPROVAL.md` § Resueltas. **P-136-F** (2026-10-05, opción C): el candidato de CA-54 es `82ceb63` (`dee5932` revertido en `74da4c5`); **QA-007-02 cerrado por reversión** (ficha F-136-5 de la recursión); CA-54 se cumple en sus 35 corridas y las formas de **QA-007-01** quedan fuera del criterio como **límite declarado**, con su clase `contrato` sin cambiar. **P-136-J y P-136-K** (2026-10-06): CA-47 punto 20 gana que, en `guard-codigo`, un `file_path` que no es texto no deja pasar a nadie, tampoco al agente de código (SEC-128, sin reparar), y que SEC-127 se acredita con LO1 a LO4 y LK de la sección 47 y la lectura del código, con la prueba en bash 5.0 o anterior en modo POSIX declarada no medida; O-52-3, ficha F-136-7. **Versionado el 2026-10-06** (paso 6, fase 0; P-136-L y el punto 4 del resumen del plan del propietario): **CA-68** gana la propiedad de **SEC-129** (texto de R-054 §5): sólo un juicio concluido deja sin decisión, y ninguna decisión depende del modo del intérprete heredado —`POSIXLY_CORRECT`, `SHELLOPTS`, `BASH_ENV` con `set -o posix`, `bash --posix`, ejemplos no exhaustivos—. Se mide con la matriz de R-054 y fail-before contra `78a2f33` y v1.35.0. QA-007-07 queda pendiente de **P-136-N**. CA-68 gana también dónde no puede caer un techo de tamaño, con parada si SEC-115 lo exige. **CA-69 punto 7** fija E1 a E3, la regla de «afecta» frente a REQ-017 CA-09 y la comprobación de SEC-130 por QA. ADR-017 lleva una nota posterior. **Sin construir** en la fase 0. **Paso 6, fase 2** (2026-10-06): CA-67 y CA-68 **construidos en `0efd3c2`, SIN VALIDAR por QA** —el motivo y los avisos van por la entrada estándar y se acotan a 16 384 bytes; plazo propio de 30 s, que responde en no más de 40; `hooks/entrada.sh` con R1 y la trampa de salida; R2—. CA-69, punto 7: E1 a E3 medidos, «no afecta». SEC-130 no queda cubierto por R2 (F-136-12). **P-136-O y P-136-N** (2026-10-06, resueltas por el propietario): los techos de tamaño quedan como **cambio de compatibilidad declarado** en CA-68 y CA-69, punto 3 —el `Write` de un REQ de más de 393 216 bytes y el `Edit` cuyo producto de búsqueda pasa de 2³² (sobre `REQ-007.md`, `old_string` de 7 000 bytes o más) pasan de «sin decisión» a `deny`; se parte la edición—, con nota posterior en ADR-017 y párrafo en la guía; CA-68 (ii) se amplía a **todo lo heredado del entorno**, con `ARNES_INPUT_LISTO` y `ARNES_MANIFEST_LISTO` (QA-007-07) y un caso de banco por variable; CA-69, punto 7, gana la observación de QA del FAIL de la sección 24 (hallazgo si lo reproduce; si no, INS-136-3). **QA del paso 6** (2026-10-06, write-back de estado sólo de lo que no depende de P-136-P): **QA-007-07 construido en `8e11f87` y validado por QA** —las dos marcas se vacían al cargar `lib.sh`; sección 47 95/0 con su fail-before—; **QA-023-10 cerrado por QA en su medición** (35 corridas sobre `82ceb63`, P-136-F); la sección 24 no reproduce el FAIL en 16 corridas, **INS-136-3**; SEC-130 no queda cubierto por R2, medido, y sigue F-136-12; punteros de `hooks/lib.sh` corregidos a `8e11f87`. CA-67 y CA-68 siguen rotulados SIN VALIDAR en su conjunto. **P-136-P** (2026-10-06, resuelta por el propietario): el FAIL de E2 de QA (1 en 6, 0,962×, E1 sin cambio) **no es «afecta»** —la regla sigue; QA-007-08 pasa a instrumento, **INS-136-4**; REQ-017 no se reabre; F-136-8 se amplía a CA-09—; CA-68 declara dos **límites** —**QA-007-09** (un REQ con CRLF en disco de 3,6 MB o más deja sin decisión el `Edit` que lo cierra; F-136-18) y **QA-007-11 (b)** (`noexec`, `onecmd` y `xtrace` heredados, no neutralizables desde el hook; F-136-19)—, ni aceptados ni reparados; **QA-007-10**, **QA-007-11 (a)** y **QA-007-12** quedan en la pasada correctiva —**construidos en `03cbf5e`; validados y cerrados por QA** en la re-verificación (2026-10-07, evidencia `6cf1ba0`); seguridad, pendiente—. **P-136-Q** (2026-10-07, resuelta por el propietario): la parte de `builtin` de **QA-007-13** (regresión de `03cbf5e`: sin decisión, o 60 s y rc 124 en cualquier llamada) queda en CA-68 (ii) con la técnica del propietario y un caso de banco (`ls -la` sin decisión en < 5 s, operativo), **construida en `39e6128` y validada y cerrada por QA** (`84fbf80`); CA-68 amplía sus **límites declarados** con **F-136-20** —funciones importadas `.` y `[` antes de `hooks/entrada.sh`, y `SHELLOPTS` con `errexit`; `BASH_ENV`, ya cubierto—, ni aceptados ni reparados. **P-136-R** (2026-10-07, resuelta por el propietario): **QA-007-14** (los builtins especiales que el hook usa, fuera de la lista estática; regresión de `39e6128`) queda en CA-68 (ii) en una **pasada, SIN VALIDAR**: la lista cubre los builtins que el hook usa, **regulares y especiales**, con un caso de banco (`return` y `break` exportadas, decisión en < 5 s, operativo); F-136-20 gana su punto (v), `BASH_FUNC_set%%` en los guardianes sueltos | `en-progreso` | critico | pendiente | pendiente |
| [REQ-008](REQ-008.md) | Informe de proyecto: avance medido, qué lo detiene y qué decide un humano, como evolución de `arnes-panel` y con el lector de la puerta | `pendiente` | critico | pendiente | pendiente |
| [REQ-009](REQ-009.md) | Una sola regla para contar la cola de aprobaciones: la puerta dice 1 y el bloque derivado dice 4 sobre la misma entrada | `completado` | critico | aprobado | aprobado |
| [REQ-010](REQ-010.md) | El acento no es parte del valor: `en-revision` y `en-revisión` son el mismo estado para la puerta, el informe y el bloque derivado | `completado` | critico | aprobado | aprobado |
| [REQ-011](REQ-011.md) | La puerta que pregunta DESPUÉS: el estado terminal reconstruido entre dos expansiones sale allow, y preguntar antes no cierra la clase | `pendiente` | critico | pendiente | pendiente |
| [REQ-012](REQ-012.md) | Criterios por mecanismo, no por enumeración: siete de veinte hallazgos del ciclo 2 fueron que el criterio decía algo falso sobre lo construido | `pendiente` | critico | pendiente | pendiente |
| [REQ-013](REQ-013.md) | Paralelizar por REQ con un mapa explícito de archivos: el ciclo 2 corrió en serie porque nadie podía decir qué dos comisiones no colisionan | `en-revisión` | critico | con-hallazgos | con-hallazgos |
| [REQ-014](REQ-014.md) | El banco en archivos por sección: un `run.sh` de 4 096 líneas impide que dos agentes de QA trabajen a la vez y obliga a leerlo entero en cada comisión. **REABIERTO el 2026-09-08** (§9): `CA-18` era insatisfacible y `CA-12` ya no discriminaba; los dos `aprobado` son del 2026-09-06 y quedan **invalidados** | `en-progreso` | critico | aprobado | aprobado |
| [REQ-015](REQ-015.md) | Publicación concurrente sin pérdida: el temporal de nombre fijo destruyó texto humano de `docs/ESTADO.md` con dos paradas a la vez | `completado` | critico | aprobado | aprobado |
| [REQ-016](REQ-016.md) | La cabecera tiene noción de cita: un veredicto citado dentro de un comentario HTML cerró un REQ crítico sin auditoría aprobada | `completado` | critico | aprobado | aprobado |
| [REQ-017](REQ-017.md) | El coste que ningún criterio miraba: la guarda del CR es cuadrática en la longitud de línea, y CA-08 dio verde midiendo procesos sobre una regresión de 10× de reloj | `completado` | critico | aprobado | aprobado |
| [REQ-018](REQ-018.md) | El canal por el que un proyecto reporta defectos DEL arnés: issues en el repo público con **gramática restringida** — sin campo donde quepa el nombre del proyecto, no hay decisión que tomar en caliente. **Ventana 1.34.0** | `borrador` | critico | pendiente | pendiente |
| [REQ-019](REQ-019.md) | Adelgazar los **dos** documentos de arranque —`AGENTS.md` y `requirements/README.md`— sin perder una sola invariante: se adelgaza **moviendo**, no reescribiendo, porque no se puede perder una regla que nadie borró. **Ventana 1.34.0, primer trabajo**; 9–11 comisiones en 7 fases | `pendiente` | critico | pendiente | preventiva |
| [REQ-020](REQ-020.md) | ¿Esta prueba mide algo? Cuatro formas de estar verde sin haber medido — el caso vacío, el que no se ejecuta, el que sólo fija lo que hoy falla y el universo encogido en silencio. **Ventana 1.34.0**: depende de las sondas de REQ-021 | `pendiente` | critico | pendiente | pendiente |
| [REQ-021](REQ-021.md) | `tests/util/` con las sondas de reloj y de procesos, escritas una vez: se reconstruyen en cada comisión y dos se rompieron a la primera, una dejando un proceso vivo 3 h 41 min. Alcance reducido el 2026-09-08 (la sonda de línea base queda fuera). **BLOQUEADO el 2026-09-08**: agotó las 3 vueltas dev↔QA sin cerrar `QA-021-10` (`contrato`), y el propietario lo movió a **1.34.0** | `bloqueado` | critico | con-hallazgos | preventiva |
| [REQ-022](REQ-022.md) | Despacho en paralelo: tres dimensiones de colisión y la herramienta sólo ve una. Bloque de apertura de **1.34.0** | `pendiente` | critico | pendiente | pendiente |
| [REQ-023](REQ-023.md) | Una clave de control escrita de otra forma, o declarada dos veces, no se convierte en ausencia: la **cabecera ambigua no deja cerrar** (mitad 1 de SEC-047). **Ventana 1.35.0**, autorizada por el propietario el 2026-09-29; versionado por **ADR-014** (frontera por esqueleto ASCII de la clave y estructura de la declaración; **cambio de compatibilidad**: una clave repetida deniega aunque diga lo mismo; claves de más de 256 bytes, **limitación** no protegida). Ya no depende de las sondas de REQ-021 ni del gate de SEC-048. Tope dev↔QA agotado (3 de 3); vuelta excepcional agrupada de la tercera y la cuarta autorización (2026-09-29 y 2026-09-30): QA-023-06 y **CA-13** (SEC-117, **ADR-015**); en la de la quinta (2026-09-30), **CA-13 (iv)** remite a REQ-007 CA-45 y CA-47 (**ADR-016**) | `en-revisión` | critico | aprobado | aprobado |
| [REQ-024](REQ-024.md) | La ausencia de un campo no se resuelve del lado que abre, y el mismo estado en el segundo lector: la cola que cuenta cero sobre lo que no pudo medir. **Ventana 1.34.0**: va después de REQ-023, con el que comparte nueve rutas | `borrador` | critico | pendiente | pendiente |
| [REQ-025](REQ-025.md) | El arnés vigila también a quien orquesta: la sesión coordinadora acredita, decide y publica, y ninguna puerta la mide. **Ventana 1.35.0**; línea base = 20 errores de coordinación catalogados. Tras la **partición del 2026-09-21** conserva **la entrega 1** —las **seis reglas** del propietario en `AGENTS.md` §6, su gemela, las dos sedes de `PENDING_APPROVAL`, la entrada de `arnes-upgrade` **preparada, no publicada** (publicada con v1.35.0 el 2026-10-03), las referencias en los agentes y el **ADR-008**— y, desde el mismo día, una **entrega 1b `pendiente` dentro del propio REQ** (CA-01, CA-02, las preguntas 1, 2 y 4 de CA-09 (B), la regla del `git add -A` y la primera mitad de CA-10), **sin ventana asignada**: **aprobar la entrega 1 no completa REQ-025**. Vuelta **1 de 3** consumida (QA `con-hallazgos`, R-1) | `en-progreso` | critico | con-hallazgos | pendiente |
| [REQ-028](REQ-028.md) | Las capacidades que REQ-025 difiere (**entregas 2+**): `tools/arnes-comprobar.sh` con par discriminante y denominador, su sección del banco, la **procedencia y la atribución** de la cifra que llega al `CHANGELOG.md`, las **columnas de instantes** del libro de comisiones y los umbrales de coste. Nace de la **partición de REQ-025** (2026-09-21) conservando los identificadores CA-03…CA-08, CA-12 y las mitades de CA-10, CA-11 y CA-13. `borrador` con **cuatro decisiones del propietario abiertas** (B-1…B-4) y **sin ventana asignada** | `borrador` | critico | pendiente | pendiente |
| [REQ-029](REQ-029.md) | Fidelidad al encargo: detectar omisiones, sustituciones y decisiones de negocio no autorizadas antes de implementar — fuente identificable del pedido, «Correspondencia con el encargo» en la plantilla, comprobación de resolución antes de despachar, **un solo veredicto de QA**, sin bloqueo retroactivo, y la partición que no concede autoridad sobre el alcance. **Ventana 1.35.0**; decisión del propietario del 2026-09-23 sobre la propuesta `d4e7a4f`; integrado en `main` por el PR #53 (`11c5df2`) y cerrado administrativamente el 2026-09-27 sin acreditar conducta ni ahorro | `completado` | critico | aprobado | aprobado |
| [REQ-030](REQ-030.md) | Las sondas de coste CA-03 y CA-08 (ii) de REQ-017 deciden sobre un **presupuesto fijo de 5 repeticiones** y dicen **INCONCLUSO** (rendimiento no acreditado, contado en el resumen) cuando no resuelven: los techos no se mueven. Versiona REQ-017 por **ADR-012**; autorizado por el propietario el 2026-09-26. **Ventana 1.35.0**; vuelta 4 y dos intervenciones documentales por excepción expresa del propietario (2026-09-26); integrado en `main` por el PR #55 (`c4d92c0`) y cerrado administrativamente el 2026-09-27 con QA-030-03, QA-030-05 y SEC-111 (`instrumento`) abiertos, sin acreditar rendimiento | `completado` | critico | aprobado (re-verificación documental, 0f7e668) | aprobado (R-043-B, 192d7b6) |
| [REQ-031](REQ-031.md) | Ningún hallazgo bloqueante se ignora por su posición ni por su separador: sintaxis **cerrada** de `Hallazgos abiertos:` en `guard-completado` (A), y el mapa `Archivos:` comprobado desde la Definition of Ready antes de pedir paralelismo (D). **Ventana 1.35.0**; pedido del propietario del 2026-09-27. **P-1 resuelta (opción B)**: tras el paréntesis de un hallazgo sólo la coma o el fin del campo; versiona REQ-007 CA-41 por **ADR-013**. Vuelta 2: clave repetida deniega (SEC-112, CA-A12; su limitación conocida, aparte, es SEC-118: nota del 2026-09-29), techo de 16 384 bytes —deniega por encima; su limitación, SEC-115, va aparte (nota del 2026-09-30)— y acceso de coste constante (CA-A13/A14). **Vuelta 3 de 3 (última)**, autorizada por el propietario el 2026-09-28: el techo se mide **antes** de normalizar (SEC-113 remedio B, CA-A15), reproducción aislada de un hook sin decisión (CA-A16) e inventario de claves ignoradas (CA-A17); la parte de §13 / R-024 nació de una **atribución equivocada**: esa celda es de `rel/registro-1.33.0` (`1154417`), no de `main` (Preguntas abiertas) | `en-revisión` | critico | aprobado (2026-09-30, cd47f06) | aprobado (R-047, 57129fb) |
