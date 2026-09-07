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

## 1.33.0 — las puertas que faltan

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
