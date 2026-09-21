# ADR-008 — La coordinación se orienta a entregas: quién abre trabajo, y todo bloqueo con su alcance
Fecha: 2026-09-21
Estado: aceptada

## Contexto

El arnés vigila **al que ejecuta la comisión** —`guard-codigo`, `guard-completado`, el campo
`Archivos:`, el orden de fases—, y no tiene ninguna puerta de contenido sobre **quien orquesta**.
Sobre ese punto ciego se apoyaban dos defectos de texto que llevaban abiertos desde que existe §6,
y que no son de estilo: son **promesas absolutas cuyo mecanismo no las sostiene**.

1. **«Loop de error»** decía, sin condición: *«si QA o seguridad encuentran fallos, el REQ vuelve
   al desarrollador»*. Leído tal cual, **cualquier** hallazgo abre trabajo de desarrollo. El caso
   medido es la cadena de la **vía proporcional**: un hallazgo abre una reparación, la reparación
   abre una revisión, la revisión encuentra una variante del mismo defecto con el objeto cambiado,
   y el ciclo consume vueltas sin que nadie haya decidido nunca, por escrito, **si ese hallazgo
   pertenecía a la entrega en curso**. El propietario lo nombró el 2026-09-21: *«el objetivo
   inmediato del arnés es mantener el desarrollo orientado a entregas y evitar ciclos de revisión
   que amplían el trabajo sin decisión explícita»*.
2. **«Mecanismo de gate»** decía que el agente *«**detiene** el pipeline. No continúa hasta que el
   humano resuelve»*. Ningún mecanismo detiene el pipeline: lo único que la máquina hace es
   **denegar la transición de un REQ a `completado`** mientras `PENDING_APPROVAL.md` tenga
   entradas. La promesa escrita era **más ancha que su hook**, y el precio lo pagó el proyecto:
   una pregunta encolada de madrugada dejó parado trabajo que nada impedía. La misma promesa
   absoluta vivía, sin nombrar ninguna acción, en la **cabecera de `PENDING_APPROVAL.md`** —el
   texto que un agente lee justo **al encolar**— y en su plantilla.

La forma intermedia que se propuso al propietario, «la acción **aprobar/cerrar** queda bloqueada»,
**tampoco servía**: esa barra junta en un solo término dos cosas distintas —la **aprobación
humana** de §6, que conceden personas y ningún hook impone, y la **transición mecánica** que el
hook sí deniega—, de modo que quien la leyera no podía saber cuál de las dos estaba bloqueada.

## Decisión

Se reescriben **en su promesa completa** —no se les cuelga una excepción al final— los dos
párrafos normativos de `AGENTS.md` §6, y se añade en esa misma sección la **sede única** de las
**seis reglas** de coordinación orientada a entregas que el propietario autorizó el **2026-09-21**
(objetivo concreto en el encargo · todo bloqueo declara su alcance · un hallazgo no es por sí solo
un encargo nuevo · decisiones humanas temprano y con su forma · presupuesto del ciclo completo ·
avance observable). Las seis reglas viven **una vez**: los agentes, plantillas y skills **remiten**
a ellas y no copian su texto.

**Las dos decisiones del propietario, literales en lo esencial (2026-09-21).**

- **(a)** «Sustituye "aprobar/cerrar" por la **transición exacta que bloquea `guard-completado`:
  marcar un REQ como `completado`**. Distingue ese bloqueo mecánico de otras aprobaciones o
  restricciones normativas. Mantén permitido implementar y probar trabajo independiente,
  autorizado y suficientemente definido.»
- **(b)** «La coordinadora decide qué reparación encargar, **sin retirar ni neutralizar
  veredictos**. Si QA o seguridad consideran un hallazgo bloqueante de esta entrega y la
  coordinadora considera que es independiente, **deben resolver esa discrepancia o escalarla; no
  basta con cambiar su ubicación para permitir el cierre**. Una reparación del mismo defecto o
  entrega **conserva su contador**. No se reinicia ni se elude mediante un REQ nuevo.»

De **(a)** salieron, **en la redacción original de esta decisión**, el vocabulario **cerrado** de
clases de acción —`implementar · probar · aprobar ·
publicar`, donde «aprobar» nombra las aprobaciones humanas de §6 que ningún hook impone—, la regla
de que un bloqueo **mecánico** conserva su clase **y además nombra la transición exacta** que la
máquina deniega, y las **tres fronteras** de la cola: no impide implementar ni probar; no es
ninguna aprobación humana normativa y vaciarla no concede ninguna; no absorbe el orden de fases,
el veto ni el tope de vueltas. **Las dos primeras piezas de este párrafo —el vocabulario y la
regla del bloqueo mecánico— quedaron corregidas el 2026-09-21 por decisión del propietario:** la
adenda del final de esta sección **manda sobre ellas**, y este párrafo se conserva sin reescribir
como redacción original. Las tres fronteras siguen vigentes. De **(b)** salen la clasificación que la coordinadora hace sobre
cada hallazgo, la **discrepancia declarada** que se resuelve entre QA/seguridad y la coordinadora
o se **escala al propietario**, y el **contador que es del defecto o de la entrega** y no del
identificador bajo el que se despacha.

Contrato completo y criterios que lo miden: `requirements/REQ-025.md`, CA-09, CA-10, CA-14 y
CA-15.

### Adenda — corregido el 2026-09-21 por decisión del propietario: **cinco** clases de acción

**Esta adenda manda sobre el párrafo de arriba que derivaba de (a) un vocabulario de cuatro
clases.** Ese párrafo no se reescribe: queda como redacción original de la decisión, marcado como
corregido. **Causa:** el hallazgo `QA-025-02` (`contrato`, `docs/qa/REQ-025.md`, 2026-09-21) midió
que el vocabulario cerrado de cuatro clases **no tenía clase para el bloqueo que el arnés más
usa** —el de la cola de `PENDING_APPROVAL.md`—, y que por eso dos definiciones de agente recibían
una instrucción **inejecutable**.

**Decisión del propietario (2026-09-21), literal en lo esencial — opción B:** «Distinguir
**implementar, probar, aprobar, cerrar y publicar**. Aquí "cerrar" significa **marcar el REQ como
`completado`**. Son **categorías descriptivas, no controles nuevos**. Para cada bloqueo se nombra
**la acción concreta y la regla que la impide**. **No afirmes que una lista enumera todos los
bloqueos posibles.** El veto conserva su alcance según la regla que lo establece y **puede afectar
más de una acción**.»

**Qué cambia en la sede** (`AGENTS.md` §6, regla 2, «Gates de aprobación humana» y «Mecanismo de
gate»; y su gemela `templates/AGENTS.md.tpl`, más las dos cabeceras de `PENDING_APPROVAL`):

- El vocabulario pasa de cuatro a **cinco** clases: **implementar · probar · aprobar · cerrar ·
  publicar**, cada una glosada en la sede.
- **«aprobar»** vuelve a ser **sólo** la aprobación **humana** normativa de §6, que conceden
  personas y que ningún hook impone.
- **«cerrar»** es **marcar el REQ como `completado`**, y el bloqueo de la cola pasa a **esa**
  clase. Las condiciones que `guard-completado` aplica no se redeclaran: la sede las **cita**
  (§6 y §13).
- Desaparecen «un bloqueo mecánico **conserva su clase**» y «nombrar la transición **no añade una
  quinta clase**», que la opción B deja sin objeto.
- Desaparece del titular de «Gates de aprobación humana» la frase **«lo que no está en esta lista
  no se detiene por ellas»**: **ninguna lista enumera todos los bloqueos posibles**, y lo que una
  lista no menciona no queda por ello desbloqueado.
- **Un bloqueo puede afectar a más de una acción**, y el **veto** conserva el alcance que le da su
  propia regla — puede impedir a la vez **cerrar** y **publicar**.

**Qué NO cambia, y es lo que impide leer esto como una decisión nueva sobre el mecanismo:** las
cinco clases son **descriptivas**; no crean, no retiran y no modifican ninguna puerta, permiso,
aprobación ni condición de cierre. `hooks/`, `hooks.json` y `.arnes/config.json` quedan intactos,
y todas las consecuencias marcadas (=) más abajo siguen vigentes tal cual.

## Alternativas consideradas

- **Colgar una excepción al final de cada párrafo** («…salvo cuando el trabajo sea independiente»)
  — por qué no: deja la **promesa principal absoluta**, que es exactamente la forma de defecto que
  el propietario había rechazado antes; quien lee la primera frase y se detiene sale con la
  afirmación falsa intacta.
- **Escribir «aprobar/cerrar» como acción impedida por la cola** — por qué no: la rechazó el
  propietario con la precisión (a). Junta en una barra el bloqueo mecánico y la aprobación humana,
  así que un lector no puede saber cuál de los dos le aplica ni qué lo levanta.
- **Añadir un hook que decida qué hallazgo abre trabajo** — por qué no: es **semántica**, y
  ninguna puerta la ve; construirlo produciría el «verde sin haber medido» que este mismo REQ
  ataca. Estas seis reglas se declaran como **disciplina con dueño** y las acredita un tercero
  (REQ-025 CA-11), no una máquina.
- **Distribuir las reglas a cada definición de agente** — por qué no: dos transcripciones de la
  misma regla se desfasan en silencio, y ésta se desfasaría hacia el lado que **abre** trabajo.
  Los agentes llevan **referencias**, no copias.

## Consecuencias

- (+) **Un bloqueo deja de extenderse solo.** Quien lee una entrada de la cola sabe qué queda
  impedido —marcar un REQ como `completado`— y qué no, y la propia entrada declara qué trabajo
  sigue o que ninguno sigue.
- (+) **Quién abre trabajo queda escrito.** La coordinadora clasifica, y esa decisión es visible y
  reprochable en vez de implícita.
- (+) **El texto deja de prometer más que su mecanismo**, que es la propiedad que este repositorio
  exige a los demás.
- (=) **Lo que NO cambia:** ningún hook, `hooks.json` ni `.arnes/config.json`; el `Rigor:` y la
  sensibilidad de ningún REQ; las condiciones de cierre de `guard-completado`; el vocabulario de
  tres clases de `Hallazgos abiertos:`; el tope de **3** vueltas dev↔QA por REQ; y las facultades
  de `qa-tester` y `auditor-seguridad` —detectar, registrar, clasificar, bloquear y vetar—, que
  quedan íntegras.
- (−) **La clasificación de la coordinadora es un juicio sin puerta**, y su sujeto es quien
  redacta la evidencia. Mitigación: la acredita un tercero (REQ-025 CA-11 punto 3, ensayo S1…S4
  ejecutado y firmado por el `qa-tester`), y una **discrepancia** con QA o seguridad no la resuelve
  ella sola: se escala al propietario.
- (−) **Dos sedes gemelas que pueden desfasarse** (`AGENTS.md` y `templates/AGENTS.md.tpl`;
  `PENDING_APPROVAL.md` y su `.tpl`). Mitigación: el texto es **idéntico** salvo los marcadores de
  plantilla, y la comprobación es un `diff` de bloques, barata y repetible.
- (−) **Los proyectos instalados NO reciben nada por este ADR.** Su `AGENTS.md` queda **congelado**
  hasta que `arnes-upgrade` lo migre, y migrar es un acto del propietario de cada proyecto. La
  entrada «Hacia 1.35.0» de `skills/arnes-upgrade/SKILL.md` está **preparada**, no entregada.
