# ADR-011 — El alcance de la dirección de la ausencia se enuncia POR ACTO, no por puerta
Fecha: 2026-09-10
Estado: propuesta (gate humano pendiente; el motivo **no** es el manifiesto — ver § Estado y gate)

> **El papel, que es lo estable.** Éste es el **«ADR del alcance de la dirección de la
> ausencia»** que `REQ-024` encarga en su § «El TERCER ADR», con dueño, contenido y gate ya
> especificados ahí. El **número** se estampó al crearlo: `docs/decisions/` tenía **diez**
> archivos (`ADR-001` … `ADR-010`, los dos últimos de este mismo REQ), verificado leyendo la
> carpeta el 2026-09-10, así que el primer libre era `ADR-011`. El número no tiene asignador;
> reservarlo por anticipado sería un absoluto sobre un conjunto que otro trabajo puede ampliar.
>
> **Este ADR NO supersede a `ADR-009`: extiende su alcance y lo deja vigente entero.** El
> «por qué» está en § Decisión 4 y en § Alternativas, porque es la mitad del valor de la
> decisión.

## Contexto

`ADR-009` decidió que **la ausencia de un campo de cabecera no se resuelve del lado que abre**, y
enunció su alcance sobre «**la puerta de cierre y el lector de campos**»
(`docs/decisions/ADR-009-…:13`). Es decir: sobre **un acto** —la transición al estado terminal— y
**un lector**.

Ahí estaba el hueco. `ADR-009` §Contexto acierta en lo esencial —«no es una vía: es un
**estado**»— y luego **enuncia la mitigación sobre una sede**. Un estado no lo consume una sede:
lo consume **cada acto** que lo lea. La guarda que impide que seguridad firme lo que QA no ha
validado (`hooks/guard-completado.sh:274`) corre en **cualquier** edición del REQ y decide
**antes** del cierre, así que la mitigación de `ADR-009` **no podía alcanzarla por
construcción** — no por un descuido de implementación, sino porque su alcance declarado nombraba
otra cosa.

**Medido, y la evidencia se cita y no se copia.** El `auditor-seguridad` lo midió en **`R-026` §5**
sobre `ce714c7`, con una `Edit` que escribe `Seguridad: aprobado` en un REQ `critico`: los **tres
controles** acotan el resultado —con `QA: pendiente` y con `QA: con-hallazgos` la guarda
**deniega** nombrando el cruce, con `QA: aprobado` **permite** correctamente—, y la sonda —la línea
`QA:` **ausente o comentada**— sale **ALLOW en los dos estados** de `campos.ausencia_exige`. Sitio
único de la clase, severidad, dueños, forzador y vencimiento:
`docs/seguridad/registro-seguridad.md` § **`SEC-083`**. Aquí no se transcriben: dos sedes de un
dato se desfasan, y se desfasan hacia el lado que abre.

Lo que esa medición demuestra no es un fail-open más: es **`SEC-047` sobreviviendo a su propia
mitigación**. Un proyecto que hace **todo** lo que `ADR-009` pide —incluida la llave encendida—
sigue expuesto por esta vía. Y lo que se pierde no es el cierre, que sigue bloqueado por otras
vías, sino la **condición de validez de la firma** (`AGENTS.md` §6), que es un acto **anterior** al
cierre.

**Y hay un segundo dato del mismo día, que fija la FORMA de este documento y no su fondo.** Otro
`analista-requerimientos` puso a `ADR-009` una **nota al pie fechada el 2026-09-10** que **precisa
dos frases** cuya magnitud declarada estaba medida falsa («todo REQ heredado … deja de cerrar»,
cuando dos campos **gobiernan** y dos **deniegan**), y dejó escrito por qué eligió una nota y no un
ADR nuevo: un ADR **no se reescribe encima**, y un segundo ADR **sobre la misma decisión** sería la
transcripción que este repositorio persigue. Ese precedente delimita exactamente lo que aquí **no**
sirve: precisar una magnitud es una nota; **cambiar el sujeto de la propiedad y crear una
obligación nueva es una decisión**, y `AGENTS.md` §9 le pone la forma de ADR.

*(Leído en `rel/registro-1.33.0`, base `73822fa`, el 2026-09-10; **sin ejecutar nada**. La medición
que funda este ADR es la del auditor en `R-026` §5.)*

## Decisión

1. **El sujeto de la propiedad de `ADR-009` deja de ser una puerta y pasa a ser un ACTO.** La
   ausencia de un campo del dominio del lector se resuelve por el **sitio único** —la tabla
   `ARNES_AUSENCIA` y `arnes_resuelve_ausencia` de `hooks/lib.sh`, decisión 1 de `ADR-009`— en
   **todo acto que `guard-completado` juzgue**, y **ningún acto la decide por su cuenta**. La
   transición al estado terminal deja de ser el alcance y pasa a ser **un** elemento del alcance.

2. **La lista de actos se DERIVA del código y no se enumera en ningún texto firmado.** El sitio del
   que se deriva son las **ramas de denegación** de `hooks/guard-completado.sh`. Cualquier ejemplo
   escrito en un documento —criterio, ADR, `AGENTS.md`— es **no exhaustivo** y se **marca** como
   tal. Enumerar sedes es lo que convierte una propiedad en una lista que envejece: la puerta
   siguiente nace fuera de la lista y el fail-open reaparece con otro nombre.

3. **La demostración lleva un suelo publicado de no menos de 2 actos ejercidos** (**operativo**,
   dirección hacia arriba). Motivo: ejercer **sólo el cierre** volvería a medir lo que `ADR-009` ya
   cerró, y un verde así es cierto por vacío. El suelo es **satisfacible hoy y por asimetría
   medida**: el cierre ya resuelve por el sitio único (`hooks/guard-completado.sh:433` para `QA:`,
   `:565` para `Hallazgos abiertos:`) y la guarda del orden (`:274`) **no**, así que los dos actos
   existen y **deciden distinto sobre el mismo estado**. La **forma contractual** del suelo —qué se
   publica en cada corrida, la dirección admitida y el aborto con SKIP en vez de PASS— vive en
   `REQ-024 CA-12` y **no se copia aquí**.

4. **Este ADR COMPLEMENTA a `ADR-009` extendiendo su alcance; no lo supersede ni lo precisa.** Las
   **tres** decisiones de `ADR-009` se sostienen enteras y ninguna se revierte: el sitio único sigue
   siendo `hooks/lib.sh`, la tabla de direcciones campo a campo sigue siendo correcta, y la
   activación por `campos.ausencia_exige` sigue en pie con su coste medido en 0 procesos. Lo que
   resultó estrecho fue **la frase que enunció sobre qué rige**, no lo que decidió. `ADR-009`
   permanece **vigente**, con su propio `Estado:` y su propio gate, y este documento es la sede
   única de la extensión.

5. **Lo que este ADR NO decide, dicho con su motivo y no por omisión:** cuál de las **dos salidas**
   que `REQ-024 CA-12` admite toma la guarda de `:274` —la que pregunta al sitio único y queda
   condicionada a la llave, o la independiente de la llave que deniega en sus dos estados—. Tres
   razones, y ninguna es comodidad:
   - **La propiedad de este ADR no depende de la elección.** Las dos salidas cumplen el enunciado
     por acto: ninguna resuelve la ausencia del lado que abre. Es la misma técnica con la que
     `REQ-024` dejó sus criterios verificables sin conocer lo que decidan sus ADR.
   - **Elegir exige una medición que esta comisión no tiene.** `REQ-024 CA-07 (i)` contrata **0
     procesos añadidos** en el camino de evaluación, y la elección toca ese camino. Decidirlo sin
     medir sería otra instancia de «criterio derivado sin comprobar su factibilidad», la clase que
     este REQ ya ha pagado seis veces según su propio Historial.
   - **La salida independiente de la llave arrastra un write-back en `CA-05`** que es del
     `analista-requerimientos` y que esta comisión tiene **expresamente fuera de alcance**.
     Tomarla aquí dejaría su obligación colgando, que es la deriva que este ADR existe para cerrar.

   **Dueño y momento:** `desarrollador` (redacción técnica) en la **fase 0** de la implementación,
   con el analista para el write-back si resulta la segunda. **Preferencia declarada como
   preferencia y no como decisión:** la salida condicionada a la llave es la coherente con la
   decisión 3 de `ADR-009` y no arrastra write-back; la otra es **admisible y más restrictiva**, y
   su precio ya está escrito en el criterio.

## Alternativas consideradas

- **Superseder `ADR-009`.** *Por qué no:* superseder es la forma que `AGENTS.md` §10 reserva para
  una decisión que **se revierte**, y aquí **ninguna** de las tres se revierte. Marcarlo superado
  retiraría de vigencia una tabla campo a campo que está medida y correcta, y obligaría a
  re-decidir —y a re-medir— cosas que ya lo están (los 0 procesos de la llave, las direcciones por
  campo). Peor aún: dejaría la impresión de que el defecto estaba **en la decisión**, cuando estaba
  en **la extensión que se le atribuyó**; la próxima mitigación volvería a enunciarse sobre una
  sede.
- **Una segunda nota al pie en `ADR-009`, como la del 2026-09-10.** *Por qué no:* aquella nota
  corrige la **magnitud** de dos frases sin tocar la decisión, y por eso una nota bastaba. Esto
  cambia el **sujeto** de la propiedad y crea una **obligación nueva** (derivar la lista de actos,
  suelo de 2 actos ejercidos). Una decisión escondida en el pie de otro documento no la encuentra
  quien busca decisiones: se busca en la lista de ADR. Y `AGENTS.md` §9 lo llama por su nombre —
  cambio de fondo, ADR nuevo.
- **Enunciar el alcance «por puerta», añadiendo la guarda del orden a la lista de puertas
  cubiertas.** *Por qué no:* es la enumeración de sedes, la misma familia que este repositorio ha
  perdido cinco veces según § Alternativas de `ADR-009` (`ADR-002`, `SEC-020`, `SEC-024`,
  `SEC-025`, `H-01`). Cerraría `SEC-083` y garantizaría el siguiente: cualquier rama de denegación
  futura nace fuera de la lista, y nadie lo notaría hasta que un auditor volviera a medirlo.
- **Enunciar por LECTOR: todo punto de entrada que lea un campo** (los siete que cargan
  `hooks/lib.sh`). *Por qué no:* los lectores que **no deciden** —`hooks/estado-derivado.sh`,
  `tools/arnes-lectura.sh`— ya quedan cubiertos por la decisión 1 de `ADR-009`, que es lo que les
  da el mismo valor que a la puerta; y ensanchar la **propiedad** hasta ellos la vuelve **no
  derivable**, porque no tienen ramas de denegación de las que derivar la lista. El **acto** es la
  unidad que decide; el lector es la unidad que mide. Confundirlas produce un enunciado más ancho y
  menos comprobable, que es exactamente la forma que `SEC-079` castigó.
- **Arreglar el `[ -n "$qa" ]` de `:274` y no decidir alcance ninguno.** *Por qué no:* cierra la
  **instancia** y deja el **sujeto** intacto, que es la secuencia que produjo `SEC-083` a partir de
  `SEC-047`. Y sin ADR, `REQ-024 CA-12` sería un criterio de fondo sin causa registrada, es decir la
  deriva de `AGENTS.md` §9 dentro del REQ que existe para cerrarla.

## Consecuencias

- (+) **El sujeto queda cerrado por propiedad y no por sede:** una rama de denegación nueva nace
  **dentro** del alcance, sin que nadie tenga que acordarse de añadirla a una lista.
- (+) **La mitigación de `ADR-009` recupera su alcance sin reabrir ninguna de sus tres
  decisiones,** y su nota al pie del 2026-09-10 sigue valiendo tal cual: precisa magnitudes, esto
  extiende extensión, y las dos cosas no se pisan.
- (+) **`REQ-024 CA-12` gana la causa registrada que `AGENTS.md` §9 le exige,** y el «por qué
  `ADR-009` no lo alcanzaba» pasa a tener una sede propia en vez de vivir sólo dentro de un
  criterio.
- (−) **La incómoda, y va dicha: enunciar por acto obliga a DERIVAR la lista de actos del código, y
  eso es más caro que nombrar una puerta.** Nombrar una puerta cuesta una frase; derivar una lista
  de actos cuesta un **extractor** sobre las ramas de denegación, que es **instrumento** —hay que
  escribirlo, mantenerlo y probarlo con fail-before— y que se rompe cuando el código cambia de
  **forma** aunque no cambie de conducta. El precedente está medido y en este mismo árbol:
  `tools/arnes-lectura.sh:69-72` deriva las claves del **texto** de los brazos `case` con `sed`, y
  el Historial de `REQ-024` (2026-09-09) ya declaró que cualquier reescritura de esa forma literal
  **rompe el informe**. Se paga a propósito: el coste es de un instrumento, y la alternativa barata
  es una lista que envejece hacia el lado que abre.
- (−) **La elección de salida queda abierta con dueño y momento** (§ Decisión 5), así que la fase 0
  de la implementación entra con una decisión pendiente y no con todas resueltas.
- (−) **`ADR-009` no lleva puntero a este ADR: quien lo abra solo no se enterará de que su alcance
  se extendió.** Lo digo y **no lo hago** —un ADR no se reescribe encima y ese archivo está fuera de
  esta comisión—. Vía de descubrimiento hoy: `REQ-024` § `CA-12` y § «El TERCER ADR», y
  `docs/seguridad/registro-seguridad.md` § `SEC-083`. Si el propietario quiere el puntero, la forma
  proporcionada ya está inventada en este repositorio: una **nota al pie fechada**, como la del
  2026-09-10, sin tocar decisión, alternativas ni consecuencias.
- (−) **Este ADR no cierra `SEC-083`.** Sus tres remediaciones siguen con sus dueños en el sitio
  único: la guarda (`desarrollador`), la fila de `AGENTS.md` §13 y su gemela de plantilla
  (`analista-requerimientos` + gate humano) y el caso de banco con fail-before. Un ADR decide; no
  remedia.
- (−) **El gate de este ADR no tiene entrada propia en `PENDING_APPROVAL.md`.** Lo digo y no lo
  hago: ese archivo está fuera de esta comisión. La cola tiene `D10` (informativa sobre `SEC-083`),
  `D7` (el texto de `AGENTS.md` de `CA-04`) y `D8` (el manifiesto cambiado antes de su gate), y
  **ninguna** es la decisión de este documento. Mientras no exista, el gate vive **sólo aquí**, y un
  gate que no está en la cola no lo mide ninguna puerta — que es la deriva de `AGENTS.md` §9
  aplicada a mi propio acto.

## Estado y gate — por qué `propuesta`, y por qué el motivo NO es el manifiesto

**Verificado, no supuesto: este ADR no toca `.arnes/config.json`.** Ninguna de las dos salidas de
`CA-12` añade llave al manifiesto: la condicionada usa la que **ya existe** en las dos sedes
(`campos.ausencia_exige`, en `false`, y cuyo propio gate está escalado como `D8`), y la
independiente de la llave **no lee el manifiesto**. Así que la razón por la que `ADR-009` y
`ADR-010` cargan su gate no aplica aquí, y no se copia por inercia.

Queda en **`propuesta`** por dos motivos propios:

1. **Una decisión sobre una decisión no puede estar más firme que su base.** `ADR-009` sigue en
   `Estado: propuesta` con su gate humano pendiente (`docs/decisions/ADR-009-…:3`). Aceptar la
   **extensión** de un alcance que ningún humano ha ratificado todavía sería firmar el segundo piso
   antes del primero.
2. **Habilita un cambio en superficie heredada con gate previo.** La conducta que este ADR fija es
   la que obliga a reescribir la fila de `AGENTS.md` §13 y **su gemela de
   `templates/AGENTS.md.tpl`**, que viaja a todo proyecto que instale el arnés; `AGENTS.md` §6 pone
   ese gate **antes** del acto, y el precedente inmediato es `D7`. El texto exacto de la fila —en
   sus dos versiones, según la salida— ya está escrito por el analista en `REQ-024` § «La fila de
   `AGENTS.md` §13 de `CA-12`», así que el gate no cuesta re-derivarlo.

**Lo que este estado NO significa:** que la remediación del código tenga que esperar. Es
independiente y su autoridad no sale de aquí — `D10` ya informó al propietario y la coordinadora
despacha las dos mitades bajo delegación. Lo que espera al humano es **el texto heredado**, no la
puerta.
