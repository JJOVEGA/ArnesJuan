# ADR-003 — Adelgazar `AGENTS.md` sin tocar la plantilla: la migración no tiene estado para una sección que desaparece
Fecha: 2026-09-07
Estado: aceptada

## Contexto

`AGENTS.md` pesa ~9 000 tokens y entra en el contexto de **cada** subagente en **cada** comisión. Es
el mayor coste **fijo** del arnés: no crece con el proyecto, se paga entero en cada arranque. Medido:
una comisión de subida de versión gastó **28 500 tokens para ~3 000 de trabajo real**. Por eso el
adelgazamiento se adelantó desde 1.35.0 a **1.33.0** como cuarta palanca de coste (decisión del
propietario, 2026-09-07): 1.34.0 es la ventana con más comisiones, y adelgazar después sería pagar el
impuesto entero primero.

El plan escrito decía adelgazar **`AGENTS.md` y su plantilla** (`docs/PENDIENTES.md` §1.35.0, punto
2). Al levantar REQ-019 apareció que esas dos mitades **no cuestan lo mismo, ni de lejos**, y que la
segunda no es una edición de texto sino un cambio del mecanismo que migra a **todos** los proyectos:

`skills/arnes-upgrade/SKILL.md` hace un merge a tres vías **clasificando por sección**, con cuatro
estados: `NUEVO`, `INTACTO`, `MODIFICADO`, `ELIMINADO`. Ninguno describe *«la sección existía en la
base y el destino ya no la tiene»* — `ELIMINADO` es el caso contrario, la sección que **el proyecto**
borró. Un estado que no se puede determinar es `UNKNOWN`, y la propia skill lo declara **tan terminal
como `CONFLICTO`**: la migración se detiene y pregunta.

De ahí el hecho que decide: **adelgazar la plantilla moviendo o partiendo secciones detendría la
migración de todos los proyectos**, no la de uno. A eso se suma que delegar prosa a archivos nuevos
obliga a ampliar la lista de copia de `skills/arnes-init/SKILL.md` y a enseñar a `arnes-upgrade` a
clasificar un **archivo gestionado nuevo** —hoy clasifica secciones, no archivos—; y que
`skills/arnes-upgrade/SKILL.md` es exactamente el archivo que colisionaba en **15 de 15** pares de
comisiones y que otra palanca de esta misma ventana está retirando del camino.

Y el argumento de coste, que es el que ordena las dos mitades: **los ~9 000 tokens se pagan en los
subagentes de este repositorio.** El `AGENTS.md` de un proyecto consumidor no entra en el contexto de
ningún agente de aquí, así que **adelgazar la plantilla no ahorra ni un token de las comisiones de
1.34.0** — que es justo para lo que se adelantó la palanca. La mitad cara es la que no rinde en la
ventana que motivó el adelanto.

## Decisión

**1.33.0 adelgaza sólo el `AGENTS.md` de este repositorio. `templates/AGENTS.md.tpl`, `arnes-init` y
`arnes-upgrade` no se tocan; el adelgazamiento de la plantilla y su migración son un REQ propio de
1.34.0**, la ventana de «lo que los proyectos leen». Aprobado por el propietario el **2026-09-07**,
con el motivo de mecanismo delante: el motivo decisivo **no es el tamaño de la edición**, es que
`arnes-upgrade` no tiene estado para una sección que desaparece del destino, eso cae en `UNKNOWN`, y
`UNKNOWN` detiene la migración de todos los proyectos.

El adelgazamiento se hace además por **partición sin pérdida**: todo bloque que sale de `AGENTS.md`
aterriza **literalmente** en un destino de `docs/`, y un resumen nunca sustituye a un bloque (CA-01 y
CA-10 de REQ-019). Es la misma doctrina que el arnés ya se aplica en la rotación —**mueve; no
resume**—: no se puede perder una invariante que nadie borró, y reescribir es precisamente el
mecanismo por el que se pierde.

**Se acepta a sabiendas una divergencia**: durante la ventana, el `AGENTS.md` de este repositorio y
`templates/AGENTS.md.tpl` dejan de tener el mismo cuerpo. Eso apaga la verificación que hoy se hace
por `diff`, así que la divergencia **no queda suelta**: va acotada por dos invariantes comprobables
del propio REQ.

| Invariante | Qué garantiza | Cómo se comprueba |
|---|---|---|
| **CA-04 — el esqueleto no cambia** | La lista **ordenada** de encabezados `## ` es idéntica antes y después, en los dos documentos: ninguna sección se elimina, añade, renombra, renumera ni parte. Sólo cambia el **cuerpo** | Extraer las dos listas y compararlas byte a byte |
| **CA-05 — el espejo sigue medible** | Todo bloque delegado aparece **literalmente** en `templates/AGENTS.md.tpl`, o lleva la marca literal `sin espejo en la plantilla` (los bloques específicos de este repositorio, que en la plantilla son `{{PLACEHOLDER}}` o no existen) | Búsqueda literal (`grep -F`) bloque a bloque. Bloques sin espejo **y** sin marca: no más de 0 |

Las dos juntas dan la propiedad que hace barata la mitad de 1.34.0: con el esqueleto intacto, la
correspondencia §N ↔ §N sigue siendo unívoca y el trabajo pendiente es un **cambio de cuerpo**
mecánico, no una reestructuración. Y con el espejo medible, si alguien cambia una regla en una sede y
no en la otra, **la comprobación lo dice** en vez de que el desfase madure en silencio.

**Dueño y vencimiento del residual:** `desarrollador`, cierre de **1.34.0**. Forzador medido:
cualquier cambio de regla que toque un bloque delegado — CA-05 lo detectará el día que ocurra.

## Alternativas consideradas

- **A — Adelgazar los dos en 1.33.0, moviendo o partiendo secciones también en la plantilla.** Por qué
  no: es la opción que produce `UNKNOWN` en `arnes-upgrade` y **detiene la migración de todos los
  proyectos**, no de uno. Arreglarlo exige un quinto estado de clasificación, tocar `arnes-init` y
  `arnes-upgrade` y escribir la nota de migración — criterios de aceptación nuevos **sobre el
  mecanismo que migra a todos**, no un ajuste de texto. Y devolvería a la serie las comisiones que la
  palanca de la nota de migración acaba de liberar, porque `skills/arnes-upgrade/SKILL.md` es el
  colisionador 15/15. Cabe en 1.34.0; no cabe en una ventana que se partió el 2026-09-07 justo para
  que entrara en un ciclo.
- **B — No adelgazar nada hasta poder hacer las dos mitades juntas (esperar a 1.34.0).** Por qué no:
  paga el impuesto de ~9 000 tokens por subagente **durante toda la ventana con más comisiones**, que
  es exactamente lo que el adelanto venía a evitar. El coste de esperar es cierto y medido; el de
  partir es una divergencia acotada y con vencimiento.
- **C — Adelgazar los dos, pero sin mover ninguna sección: sólo vaciar cuerpos dejando el puntero.**
  Por qué no del todo: es *casi* la decisión tomada —y de ahí sale CA-04—, pero aplicada también a la
  plantilla seguiría necesitando **archivos nuevos** en el conjunto gestionado, que `arnes-upgrade` no
  sabe clasificar y `arnes-init` no copia. El problema no era sólo mover secciones: era que la
  delegación **crea archivos**, y ese es el trozo que pertenece a 1.34.0.
- **D — Adelgazar sólo la plantilla y dejar este repositorio como está.** Por qué no: invierte el
  argumento de coste. Los 28 500 tokens medidos se gastaron aquí; adelgazar allí no baja ni un token
  de las comisiones de 1.34.0.

## Consecuencias

- (+) El impuesto fijo baja **en la ventana que lo paga**. REQ-019 lo contrata como razón y no como
  cifra: peso de **lectura obligatoria de gobierno** ≤ 0,60× la línea base **y** ≤ 2 documentos, las
  dos vías en la misma corrida (CA-07). Se mide el peso obligatorio y no los bytes del archivo porque
  delegar a un archivo igualmente obligatorio bajaría los bytes **sin bajar el coste**.
- (+) La migración de los proyectos **no se toca**, así que no hay ningún proyecto que pueda quedarse
  a medias por esta ventana. La mitad que sí los afecta se planifica con la palanca ya medida.
- (+) 1.34.0 hereda un trabajo **mecánico y acotado** en vez de uno de diseño: cortar los mismos
  bloques, apuntar a los mismos destinos, con el esqueleto ya garantizado idéntico.
- (−) **Los dos documentos divergen en cuerpo durante una ventana**, y el `diff` deja de servir como
  verificación del espejo. **Mitigación:** CA-05 lo sustituye por una búsqueda literal bloque a
  bloque, que además señala **cuál** bloque se desfasó; y el vencimiento es duro (cierre de 1.34.0,
  dueño `desarrollador`).
- (−) Un cambio de regla que ocurra durante la ventana hay que escribirlo **en dos sedes con formas
  distintas** —el archivo delegado aquí, el cuerpo íntegro en la plantilla—, que es el trabajo que hoy
  ya existe pero que hasta ahora se podía comprobar de un vistazo. **Mitigación:** la misma CA-05, que
  convierte «acordarse» en «se comprueba».
- (−) Se reduce el alcance de un punto del plan aprobado (`docs/PENDIENTES.md` §1.35.0, punto 2, «y su
  plantilla»). **Mitigación:** la reducción está aprobada por el propietario en la fecha de este ADR y
  el resto no se cancela, se reprograma con dueño y ventana.
- (Neutro, y se deja escrito) Esta decisión **no** entró por `PENDING_APPROVAL.md`. Ese archivo hace
  que `guard-completado` deniegue el cierre de **cualquier** REQ mientras tenga entradas, y su
  mecanismo (`AGENTS.md` §6) es para decisiones **pendientes**; ésta se planteó y se resolvió en el
  acto. Escribirla allí habría bloqueado el cierre de REQ-017, que está a dos comisiones, por un
  trámite sobre algo ya decidido. Su sede es este ADR.

## Enlaces

- REQ-019 — `requirements/REQ-019.md` (criterios CA-01 a CA-13; CA-04 y CA-05 son las dos invariantes
  de arriba).
- `docs/PLAN.md` §1.33.0 (tabla de palancas de coste) y §1.34.0 (la fila «adelantado a 1.33.0»).
- `docs/PENDIENTES.md` §1.35.0, punto 2 — el punto del plan cuyo alcance se parte.
- `skills/arnes-upgrade/SKILL.md` — el modelo de merge a tres vías, sus cuatro estados y la regla de
  que `UNKNOWN` es terminal. Es la fuente del motivo decisivo.
