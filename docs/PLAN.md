# PLAN — el camino del arnés hasta que esté terminado

> **Qué es esto.** El plan maestro por versiones: qué entra en cada ventana, qué cierra y por qué va ahí
> y no antes. La cola cruda vive en `docs/PENDIENTES.md`; el contrato, en `requirements/`. Este archivo
> es el que responde «¿cuánto falta y en qué orden?».
>
> **Regla de orden, y es la que explica casi todo el reparto:** lo que **compone** va primero. Una
> palanca que abarata el ciclo se paga en todas las ventanas siguientes; un mecanismo que cierra un
> hueco se paga una vez. Por eso el coste va antes que las puertas, aunque las puertas suenen más
> urgentes.

## Qué significa «terminado»

El arnés estará terminado cuando se cumplan las tres a la vez:

1. **Ningún hallazgo abierto de clase `contrato`.** Hoy quedan tres, todos con dueño y ventana.
2. **Todo lo que la máquina promete, lo cumple.** Ninguna afirmación de `AGENTS.md` o de las plantillas
   describe una garantía más fuerte que la que el código sostiene.
3. **Un ciclo de versión cabe en un presupuesto declarado.** Hoy cuesta ~253 USD; el objetivo es la
   mitad, y es lo que la ventana 1.32.0 va a medir.

Lo que quede después es **backlog**, no obra pendiente: mejoras de clase `instrumento` que se hacen
cuando estorban, no antes.

---

## 1.32.0 — la ventana del coste

**Qué entra:** REQ-012, REQ-013 y REQ-014. Nada más, y la reserva es deliberada.

| REQ | Qué hace | Por qué aquí |
|---|---|---|
| **REQ-012** | Criterios por **mecanismo**, no por enumeración: se prohíben las tres formas medidas —enumerar lo que el código reconoce, fijar un número que la medición desmiente, y exigir igualdad donde va un techo— | Es la palanca que más rinde. Siete de los veinte hallazgos del ciclo 2 fueron que el criterio decía algo falso, y uno costó una vuelta entera. Y ataca el 54 % del peso de un REQ, que son sus criterios |
| **REQ-013** | Campo `Archivos:` legible por máquina y `tools/arnes-paralelo.sh`, que dice qué comisiones son disjuntas | Hoy el ciclo corre casi todo en serie: cero comisiones solapadas, y el reloj del ciclo iguala la suma del tiempo de agente |
| **REQ-014** | El banco en archivos por sección, con el cuadre exacto por archivo | Mientras el banco sea un solo archivo, dos agentes de QA no pueden trabajar a la vez. Es el cuello que impide aprovechar REQ-013 |

**Qué cierra:** la línea base de coste queda con algo contra qué compararse. **Qué mide:** hallazgos de
clase `contrato` por ciclo (base 7), vueltas causadas por ellos (base 1), comisiones solapadas (base 0),
cociente reloj/tiempo de agente (base ~1,0) y agentes de QA simultáneos (base 1).

**Riesgo declarado:** REQ-014 toca `tests/`, que es crítico por definición. Su criterio central no es
«el banco pasa» sino un inventario ordenado de caso y veredicto **idéntico byte a byte** antes y después.

---

## 1.33.0 — preguntas de estado, no preguntas de vía

> **Reescrita el 2026-09-07, al cerrar la ventana 1.32.1, y aprobada por el propietario.** Antes esta
> ventana era una lista de huecos. Dejó de serlo cuando el parche 1.32.1 produjo, sin buscarlo,
> **cuatro instancias del mismo defecto de forma** en cuatro sitios con cuatro dueños distintos.

### El tema, porque una ventana con tema cuesta menos que un cajón

| Dónde apareció | Preguntaba por la **vía** | La pregunta que no envejece, por **estado** |
|---|---|---|
| Los 5 casos de banco vacíos (H-02) | «¿el documento tiene un rango?» | «¿la puerta llegó a juzgar una transición?» |
| El barrido de migración (SEC-025) | «¿hay un `<!--`?» | «¿cuáles de mis REQ en estado terminal **no cerrarían hoy**?» |
| El control de datos de cliente (SEC-029) | `git diff origin/main..HEAD` | «¿qué hay **en el árbol**?» |
| El guardián del intérprete (REQ-011) | «¿este comando va a escribir?» | «¿cambió algo protegido?» |

**Interrogar al mecanismo tiene una vía nueva cada vez; interrogar a la propiedad no envejece.** Es la
misma familia que las **cinco** derrotas de «ensanchar el patrón», y por eso la salida es la misma:
pregunta cerrada o gramática restringida. Las cuatro comparten mecanismo y comparten pruebas: juntas
cuestan bastante menos que por separado, y ese es el motivo de agruparlas, no la estética.

### Orden: las palancas de coste van PRIMERO, antes que ningún REQ

Decisión del propietario, 2026-09-07. Esta ventana va a tener muchas comisiones, y las tres palancas
están **medidas** en 1.32.1:

| Palanca | Medido | Lo que devuelve |
|---|---|---|
| Partir la sección caliente del banco | Ver la corrección de abajo: la ruta crítica es **`32-huecos-auditoria-r001`**, no `36-2` | El banco lo corre **cada** comisión que mide, decenas de veces |
| `tests/util/` con las tres sondas | Tres comisiones las reconstruyeron en esta ventana, **dos mal la primera vez** (`$BASHPID` dentro de `$( )`; `command -v` sobre un binario sombreado) | ~150 k tokens por ventana, y dos clases de prueba-que-miente |
| La nota de migración **una vez al cerrar** | `skills/arnes-upgrade/SKILL.md` colisionaba en 15 de 15 pares | Paralelismo real entre comisiones |

**Y el dato que ordena todo lo demás:** las comisiones que **miden** corren a 6 200–7 500 tokens por
minuto de reloj; las que **piensan** (análisis y write-back), a 12 000–17 000. No miden más despacio:
**esperan al banco**. Una comisión que lo corre ~20 veces se pasa 13 de sus 39 minutos mirándolo correr.

> **Corrección de la coordinadora (2026-09-07, al cerrar la ventana). El «31,3 s de 39 en la sección
> 36-2» que esta tabla traía era una medición MAL MUESTREADA, y la escribí como si fuera un dato.**
> Medí cinco secciones **elegidas a ojo** y la ruta crítica no estaba entre ellas. Con las 41 medidas,
> con la máquina limpia y sabiendo que **el corredor ya paraleliza secciones** (`&` + `wait -n`, de ahí
> el ~200 % de CPU), el reparto real es:
>
> | Sección | Reloj |
> |---|---|
> | **`32-huecos-auditoria-r001.sh`** | **75,7 s** ← la ruta crítica |
> | `36-2-los-lectores` | 26,6 s |
> | `25-presupuesto-de-analisis` | 16,7 s |
> | Las otras 38 juntas | ~40 s |
>
> Con paralelismo, el banco entero ≈ la sección más lenta, así que **partir la 36-2 no habría movido el
> reloj**: la palanca es la 32. Y hay una segunda mitad, medida aparte y anotada como hallazgo de coste:
> la 32 pasó de **7,6 s con los hooks de 1.32.0 a 75,7 s con los de 1.32.1** — 10×, introducido por este
> parche, acotado a los casos con **caracteres de control** y **sin efecto en una llamada normal**
> (0,166 → 0,171 s por llamada, medido).
>
> **Las dos lecciones, y la segunda es la que duele.** Primera: un muestreo no es una medición, y
> presentarlo como tal contamina un plan entero. Segunda: **CA-08 se cumplía.** Ese criterio mide
> **procesos** por llamada —4 = 4, correcto— y lo que se degradó fue **tiempo**. Un criterio de coste
> que fija la magnitud equivocada da verde sobre una regresión de 10×. La pasada de conformidad tiene
> que ensanchar CA-08 a **reloj**, no sólo a forks.

### El núcleo

| Trabajo | Qué cierra | Clase |
|---|---|---|
| **REQ-011 — la puerta posterior** | Deja de preguntar **antes** si un comando escribe y pregunta **después** si algo protegido cambió. Tiene ya **dos forzadores medidos**: el cierre por heredoc de `python3` y una preferencia de sesión por la consola que reapareció **tres veces** en 1.32.1, después de escribirse la regla | `contrato` |
| **SEC-025 — el barrido por estado** | «De mis REQ en estado terminal, ¿cuáles no cerrarían hoy?». Cubre la cita, el delimitador fabricado, la clave fabricada y las vías que nadie ha descubierto, porque no describe ninguna. Barato: `arnes_campos_req "$disco" ""` | `instrumento` |
| **SEC-029 — el barrido de base** | Un control **diferencial** no puede encontrar, por construcción, lo que ya está en la base. NFR de gobernanza de datos sobre el árbol completo | `contrato` |
| **La puerta de «¿esta prueba mide algo?»** | **Adelantada desde 1.34.0.** Un caso nuevo tiene que **fallar** contra los hooks de la versión anterior. Habría cazado los cinco casos vacíos el día que nacieron — y sin ellos no hay vuelta 1, que costó **685 000 tokens y 1 h 35** | `instrumento` |
| **REQ-007 bloques B y C, y CA-64.1-bis/2-bis** | Lo que ya estaba planificado: la cabecera que se sale de alcance, el destino entrecomillado, el texto humano que sube y el archivo en sólo lectura. Con esto **cierra REQ-007** | — |

### La pasada de conformidad, que ahora recoge cinco cosas y por eso sale barata

1. Las **tres promesas incondicionales más anchas que el código**: `ADR-002`, la visibilidad que el
   informe no da, y el «el hook impide cerrar sin `QA: aprobado`» que es falso cuando el campo no se
   declara.
2. **SEC-020** — la gramática de `Archivos:` y el desenvoltorio por elemento.
3. **SEC-028** — que la enumeración de los descuentos de CR sea **por construcción y no por
   inspección**, y el fuzz diferencial con semillas fijas **dentro** del banco (hoy la medición más
   fuerte sobre esa clase es de QA y el CI no la puede repetir).
4. **H-06** — la nota al margen que desactiva el bloqueo de la cola de aprobaciones. **Sigue sin
   dueño**; le corresponde `desarrollador`.
5. **La vía de fuga del modelo de clases, encontrada por el analista el 2026-09-07:** se puede volver
   **bloqueante** un hallazgo `instrumento` escribiéndolo dentro de un criterio de aceptación, **sin
   firmar la reclasificación**. `AGENTS.md` §6 dice que el defecto de un control no puede ser condición
   para cerrar la función que vigila; un criterio que exige el control consigue justo eso por la puerta
   de atrás. Hay que nombrarlo donde vive la tabla de clases.

### Lo que se saca de esta ventana, a propósito

**El canal de informes y las plantillas de issue van a 1.34.0.** Es valioso y no es urgente, y meterlo
aquí es exactamente cómo se descontroló el ciclo 3. La decisión de accesos ya está tomada y medida
(SEC-026/SEC-027): los informes entran como issues en el repositorio **público**, con una **gramática
restringida** en la plantilla en vez de muros de permisos — un repositorio de cuenta personal no tiene
roles granulares, así que la privacidad se resuelve por la **forma** del formulario y no por el rol.

---

## 1.33.0 — detalle heredado de la planificación anterior

**Qué entra:** lo que cierra huecos del mecanismo. Todo toca `hooks/`, así que es una ventana coherente
y va en serie por colisión de archivo.

| Trabajo | Qué cierra |
|---|---|
| **REQ-007 bloques B y C** | La cabecera que se sale de alcance con un `## ` de más, y el destino **entrecomillado** que hoy desarma el detector (`git clean "-f"` pasa). Con esto **cierra REQ-007**, que hoy cruza dos ventanas |
| **REQ-007 CA-64.1-bis y 2-bis** | El texto humano de `docs/ESTADO.md` que **sube** por encima del bloque en cada parada, y el archivo en sólo lectura que se reescribe cambiando su modo. Heredados, sin pérdida de bytes |
| **REQ-011 — la puerta posterior** | Deja de preguntar **antes** si un comando escribe —pregunta abierta que no se gana— y pregunta **después** si algo protegido cambió. Es la respuesta de fondo a la palabra del estado terminal partida en expansiones |
| **Dos avisos heredables** | Que la migración diga que **hay que reiniciar la sesión** —hoy no lo dice en ninguna parte, y un proyecto que actualiza cree estar protegido por puertas que aún no corren—, y que la nota de `guard-git` enumere los siete envoltorios que ahora se toleran |

**Convivencia de REQ-007 y REQ-011, decidida el 2026-09-06:** van en la misma ventana, REQ-007 primero.
Su evidencia es distinguible **por construcción**: uno decide en `PreToolUse` y el otro reporta en
`PostToolUse`, así que un veredicto que cambie sólo puede venir del primero. Colisionan por archivo, no
por semántica, y por eso van en serie.

**Palanca propuesta por el analista al cerrar 1.32.0, y aceptada: pasada de conformación anticipada.**
Antes de abrir la ventana, una **única** comisión del analista pasa la regla de REQ-012 sobre REQ-007 y
REQ-011, que son del ciclo 2 y traen su propio stock de números sin declarar. Paga la migración en una
comisión en vez de descubrirla como hallazgos y una vuelta del bucle. Respeta el «0 comisiones nuevas
**por REQ**» que CA-21 declara de contrato, porque es una pasada única y no un paso del pipeline.

**Predicción registrada para medir contra ella:** 2 a 4 hallazgos de forma (a)/(b)/(c), `número`
predominante otra vez, y 0 o 1 vueltas del bucle. El objetivo de ≤ 3 es alcanzable y no está asegurado.

---

## 1.34.0 — lo que los proyectos leen

**Qué entra:** todo lo que cambia qué documentos entran en el contexto de un agente y qué se ve de un
proyecto sin abrir diez archivos.

| Trabajo | Qué cierra |
|---|---|
| **REQ-008 — informe de proyecto** | Lo que pidió el propietario: resumen de cada REQ, NFR, hallazgo y decisión, con **porcentaje de avance**, **qué lo detiene**, decisiones humanas pendientes y recomendaciones; en HTML, siguiendo la guía de marca del proyecto si existe. Evolución de `arnes-panel`, con la cuenta hecha por `tools/arnes-avance.sh` y no por el modelo |
| **Índice de `requirements/` derivado** | Sus columnas se desfasaron **cuatro veces en dos días**. Pasa a bloque derivado entre marcadores, con el mismo lector que usan la puerta y el informe. Misma función, escrita una vez |
| **Rotación que reconoce filas de tabla** | Hoy la rotación de la historia de un REQ **no rota nada** en este repositorio: 0 entradas reconocidas y 94 filas de tabla. Es su caso de uso principal y no funciona |
| **`AGENTS.md` adelgazado**, aquí y en la plantilla | Se conserva lo que **gobierna** y el resto se delega a archivos que se leen bajo demanda. Lo lee todo agente al arrancar |

**Alcance añadido por el propietario el 2026-09-06 — el coste entra en el informe.** El informe de
REQ-008 lleva además **qué costó** el proyecto: tokens por REQ, por fase y en total; tiempo de agente,
reloj del ciclo y su cociente; y una comparación con lo que le habría llevado a una persona. Diseño
acordado, para que el analista lo escriba como criterios cuando se abra la ventana:

1. **Tres clases de número, nunca mezcladas y siempre etiquetadas: `medido`, `derivado`, `estimado`.**
   Un informe que mezcla los tres deja de ser creíble entero, no sólo en la fila dudosa.
2. **La fuente es el libro de comisiones** (`docs/qa/<versión>.md`), que se anota **al volver cada
   comisión** porque el dato no se puede reconstruir después. El informe lo lee con el mismo lector que
   las puertas; no lo recalcula ni lo estima.
3. **El coste de la coordinadora se declara aparte y no se omite.** Medido en el ciclo 2 fue el **39 %**
   del gasto. Un informe que sólo suma comisiones se equivoca en un tercio largo y hacia abajo.
4. **Tres relojes distintos, con nombres distintos:** tiempo de agente (suma de comisiones), reloj del
   ciclo (de abrir la rama a publicar) y su **cociente**, que es la única medida honesta de cuánto
   paralelismo hubo de verdad.
5. **La comparación con una persona se expresa como rango con su base escrita**, nunca como un múltiplo
   suelto. La base son unidades que el lector puede comprobar —líneas de shell, casos de banco,
   criterios, documentos— y la suposición se escribe al lado («persona que ya conoce el código, sin
   interrupciones»), porque es la suposición que siempre infla el resultado.
6. **La cifra que decide no es el coste, es el coste por resultado:** por REQ cerrado y por hallazgo
   atrapado antes de publicar. 253 USD por veinte defectos encontrados antes de que salieran es una
   frase distinta de 253 USD a secas.
7. **Una sección de lo que el número NO incluye:** la ceremonia máxima que este repositorio se impone a
   propósito, el tiempo de revisión del humano y las vueltas fallidas.

**Segundo uso declarado por el propietario el 2026-09-06: justificar el licenciamiento.** El informe
tiene dos lectores, no uno. El primero gobierna el proyecto; el segundo aprueba un presupuesto y llega
con escepticismo. Reglas de diseño para el segundo, y son distintas:

- **El caso NO se construye sobre este repositorio.** ArnesJuan se impone la ceremonia máxima a
  propósito —todo REQ `critico` y sensible, los cuatro agentes— y por eso es el ejemplo **más caro por
  unidad entregada** que existe. Presentarlo como muestra hunde el caso. El caso se construye sobre el
  proyecto consumidor, que corre en `estandar` o `ligero` y entrega valor de negocio.
- **La tarifa es un dato de entrada, no una afirmación del informe.** El informe **no** declara cuánto
  cuesta una hora de desarrollo: la recibe y la usa. Así la cifra resultante es de la organización, no
  del modelo, y no hay nada que discutirle a quien la lee.
- **Tres escenarios, no un número:** conservador, central y optimista, cada uno con su base escrita. Un
  múltiplo suelto («fue 12 veces más rápido») no sobrevive a la primera pregunta; un rango con método sí.
- **El coste se declara completo o el caso se cae.** Licencia **más** gasto de modelo **más** tiempo de
  revisión del humano. El primer movimiento de un escéptico es «os habéis dejado el consumo fuera».
- **La evidencia más fuerte disponible es la propia historia del proyecto consumidor**: el mismo
  desarrollador, el mismo código, antes y después de instalar el arnés. No supone tarifas ni
  productividades ajenas — es su `git log`.
- **El caso de una segunda cuenta es OTRO argumento y no se mezcla:** no es eficiencia, es
  **concurrencia**. Dos cuentas no hacen un proyecto más rápido; permiten que dos avancen a la vez. Se
  sostiene con la cola de trabajo que hoy no se hace, no con el ahorro por hora.

---

## 1.35.0 — el banco en el que se puede creer

**Qué entra:** la puerta que pregunta si las pruebas **miden** algo, por cribado y mutación.

Es la ventana con más valor demostrado por la experiencia de este repositorio, y la razón está en la
bitácora: un caso pasaba con el JSON vacío; otro decidía por reloj de pared; una sección entera
desaparecía en silencio y sólo el cuadre lo delató; y un criterio de rendimiento medía el camino barato
mientras el caro no respondía. **Cuatro veces una prueba en verde no probaba nada.** Un banco que
certifica el mecanismo que gobierna a otros proyectos tiene que poder demostrar que sus casos fallan
cuando deben.

---

## 1.36.0 — el working set explícito

**Qué entra:** archivar los REQ cerrados a `requirements/archive/`, con índice **derivado** y un
resolutor de identificadores, sin subcarpetas por año y sin que `archivado` sea un estado.

**Va al final a propósito, y con la medición delante:** archivar **no ahorra tokens**. Medido, el coste
de una comisión es turnos por contexto, y un archivo que nadie lee no consume contexto. Lo que compra es
**higiene de navegación** —menos ruido en las búsquedas y menos lecturas equivocadas— y eso vale, pero
menos que todo lo anterior. Las reglas de diseño ya están escritas en `docs/PENDIENTES.md`.

---

## Backlog sin versión

Se hacen cuando estorben, no antes. Ninguno es `contrato`.

- **Capa 0 opcional**: `PostToolUse` sobre `Write`/`Edit` que corra las reglas del proyecto y devuelva el
  hallazgo en el acto.
- **El encargo contra las herramientas del agente**: aviso cuando el prompt pide ejecutar y el agente
  destino no tiene con qué.
- **Reparto de identificadores** con reserva atómica.
- **Sonda del guardián automática** y aviso cuando la sesión no está gobernada. Pasó dos veces.
- **Los dos rotadores y su temporal ante una señal**, la misma familia que se cerró en el hook de parada.
- **El falso positivo de la regla del orden**: reportado desde un proyecto real, **no reproducido**. No
  se redacta REQ hasta tenerlo: un criterio escrito sobre un defecto que no se ha visto describe lo que
  imaginamos.
- **Decisión editorial del propietario**: los nombres de proyectos consumidores y de las dos cuentas de
  GitHub en un repositorio público.
