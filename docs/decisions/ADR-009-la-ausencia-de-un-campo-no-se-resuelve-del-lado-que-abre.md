# ADR-009 — La ausencia de un campo de cabecera no se resuelve del lado que abre
Fecha: 2026-09-09
Estado: propuesta (gate humano pendiente: toca `.arnes/config.json` y la superficie heredada)

> **El papel, que es lo estable.** Éste es el **«ADR de la dirección de la ausencia»** que
> `REQ-024` encarga. El **número** se estampó al crearlo: `ADR-006`, `ADR-007` y `ADR-008` ya
> estaban ocupados (los dos primeros por REQ-014, el tercero por REQ-026), verificado leyendo
> `docs/decisions/` el 2026-09-09. El número no tiene asignador, así que reservarlo por
> anticipado sería un absoluto sobre un conjunto que otro trabajo puede ampliar.

## Contexto

La puerta de cierre (`hooks/guard-completado.sh`) y el lector de campos (`hooks/lib.sh`)
resolvían la **ausencia** de un campo de cabecera **del lado que abre**. No es una vía: es un
**estado**. La puerta no mide *cómo* desapareció la línea —comentada, borrada o nunca escrita—,
mide que **no está**; y para cuatro de los seis campos que el lector reconoce, «no está»
equivalía a «no exige nada».

**Medido, y por dos caminos independientes.** El auditor lo midió ejecutando el entrypoint real
en la instalada `1.32.1` y en `cand/1.33.0` (`SEC-047` mitad 2, `R-013` §1 y §2, 11 filas): un
REQ `critico` con `QA: pendiente` y `Seguridad: pendiente` **cerraba** comentando una línea. Esta
comisión lo re-derivó leyendo el código y luego **ejecutando** el par de fixtures campo a campo:
la clase es de **4 de 6** —`QA`, `Sensible a seguridad`, `Hallazgos abiertos`, `Rigor`—;
`Seguridad` **cierra** y `Estado` es el sujeto de la transición.

Y el forzador que el auditor subió, que conviene conservar textual porque es la mitad del valor
de la medición: **«Un BOM en un diff es una anomalía; un campo comentado en un diff parece
higiene.»** La vía del comentario no necesita ni un carácter invisible: es una edición de una
línea que cualquier agente escribe con `Edit`, que **aparece** en el diff, y que un revisor
humano lee como *«el REQ declara que es sensible»* mientras la máquina lee *«no declara nada»*.

Dos cosas más del contexto, porque acotan la decisión:

- **La decisión vivía en DOS sitios.** `hooks/guard-completado.sh` decidía la dirección de los
  veredictos y de la clase del hallazgo (`[ -n "$qa" ]`, `[ -n "$hall" ]`);
  `hooks/lib.sh` la decidía para el suelo de sensibilidad (`arnes_sens_efectiva`) y para el
  nivel de rigor (`arnes_rigor_efectivo`). Dos transcripciones de la misma noción se desfasan, y
  **ya lo habían hecho**: el puntero de `REQ-016 CA-11` cita **un** archivo como lista
  exhaustiva y **2 de los 4** campos de la clase no están ahí (`SEC-050`).
- **El radio de migración es el precio real.** Si la ausencia dejara de perdonarse por defecto,
  **todo** REQ heredado de **todo** proyecto instalado que no declare uno de esos cuatro campos
  dejaría de cerrar el día de la actualización. La fricción termina con alguien apagando el
  guard (`AGENTS.md` §13), y un guard apagado protege menos que uno parcial.

## Decisión

**Tres decisiones, y las tres son de este ADR.**

1. **La dirección de la ausencia se declara en UN solo sitio, y ese sitio es `hooks/lib.sh`:**
   la tabla `ARNES_AUSENCIA`, **derivada** de las constantes `ARNES_CLAVE_*` que `REQ-023 CA-06`
   creó. Los dos despachos (`arnes_campos_req`, `arnes_estado_cabecera`) siguen enrutando cada
   clave a su variable, pero ya **no deciden**: preguntan a `arnes_resuelve_ausencia`, que es el
   único que decide.

2. **Qué dirección corresponde a cada campo**, campo a campo y con su motivo:

   | Campo | Dirección | Por qué ésa |
   |---|---|---|
   | `Sensible a seguridad` | **`gobierna: si`** | Existe un valor que más restringe y aplicarlo no inventa nada que nadie haya firmado: conserva el **suelo** de rigor en vez de retirarlo |
   | `Rigor` | **`gobierna: critico`** | Igual: el nivel más alto de ceremonia es un valor legítimo, no una firma |
   | `QA` | **`deniega`**, nombrando el campo | «Gobernar» un veredicto sería **fabricar una firma que nadie emitió**, que es peor que no tenerla |
   | `Seguridad` | **`deniega`** | Ya lo hacía (`hooks/guard-completado.sh` compara sin `-n`); la tabla lo **declara** para que el sitio único sea exhaustivo |
   | `Hallazgos abiertos` | **`deniega`**, nombrando el campo | `(ninguno)` es una declaración —alguien miró—; que la línea no exista es que nadie la escribió. Inventar «ninguno» abre; inventar un hallazgo bloqueante fabricaría lo contrario |
   | `Estado` | **`n/a`** | Es el **sujeto** de la transición, no una exigencia que su ausencia pueda activar: sin él no hay cierre que juzgar |

   La tercera salida —**abrir**— es la de hasta 1.33.0 y es la que esta tabla existe para no
   tener.

3. **La exigencia se activa por una llave de manifiesto, `campos.ausencia_exige` (booleana, y
   nace APAGADA), y esa llave viaja DENTRO de la lectura del manifiesto que cada punto de entrada
   ya hacía.** No cuesta **ni un proceso** en el camino de evaluación.

   Esto último no es un detalle de implementación: `REQ-024 CA-07 (i)` contrata **0 procesos
   añadidos**, y el propio REQ escribió que una llave de manifiesto «cuesta un proceso `jq`»
   y que ahí podía haber una colisión insalvable con su propio diseño. **La colisión no se
   materializa, y está verificado:** `arnes_parse_manifest` lee el manifiesto entero en **una
   sola** invocación de `jq` (`hooks/lib.sh:71`) y esa invocación corre **antes** de leer los
   campos (`hooks/guard-completado.sh:64` frente a `:230`). Añadir la llave a ese programa de
   `jq` —y al de `hooks/estado-derivado.sh` y al de `tools/arnes-lectura.sh`— es 0 forks. Medido
   ejecutando: la evaluación de la puerta gasta **2** procesos y la línea base `v1.33.0` gasta
   **2**; la parada gasta **5** y la línea base **5**.

## Alternativas consideradas

- **El sitio único en `hooks/guard-completado.sh`, que es lo que haría cierto el puntero de
  `REQ-016 CA-11` sin tocar REQ-016.** *Por qué no, y es la única razón que hacía falta:*
  `hooks/lib.sh` lo cargan **siete** puntos de entrada y sólo uno es la puerta. Los otros seis
  —entre ellos `hooks/estado-derivado.sh` y `tools/arnes-lectura.sh`, que **sí** resuelven la
  ausencia al derivar el rigor efectivo— **no** cargan `guard-completado.sh`. Una tabla ahí sería
  invisible para ellos: el informe diría `estandar` donde la puerta dice `critico`, que es
  exactamente el desfase entre lectores que este repositorio persigue y que `CA-11 (ii)` vigila.
  **Consecuencia asumida:** `REQ-024 CA-03` resuelve por su salida **(ii)** —el sitio único es
  otro, `REQ-016` vuelve a `en-progreso` y su `CA-11` se reescribe con el puntero real—. Es la
  remediación 1 de `SEC-050`, y es trabajo del `analista-requerimientos`, no de código.
- **Hacer que un campo COMENTADO no equivalga a uno BORRADO, y denegar sólo sobre el comentado.**
  Rompe un contrato firmado y medido por el lado peor: `REQ-016 CA-11` pone la **equivalencia**
  como criterio, y romperla deja el **borrado** abierto, que es la vía más fácil de todas.
  Además persigue la **vía** y no el **estado**: enumerar vías es lo que este repositorio ha
  perdido **cinco** veces (`ADR-002`, `SEC-020`, `SEC-024`, `SEC-025`, `H-01`).
- **Que la exigencia sea el DEFECTO en 1.34.0.** Lo prohíbe `REQ-024 CA-05`, que contrata que en
  esta versión un proyecto que no activa nada decide **idéntico**, REQ a REQ y decisión a
  decisión. Que pase a ser el defecto es un cambio de versión posterior, nombrado en «Fuera de
  alcance» de REQ-024 con dueño, ventana (1.35.0) y forzador.
- **Exigir sólo sobre los REQ que ya declaren algún campo de la clase.** No cierra la clase: un
  REQ que no declara **ninguno** sigue abierto, y ése es exactamente el estado que `SEC-047`
  explota.
- **`gobierna` para los cuatro campos de la clase.** Para un veredicto, «el valor que más
  restringe» sería `pendiente` o `con-hallazgos`, y aplicarlo produciría una denegación con un
  motivo que **miente** —diría que QA encontró algo cuando nadie miró—. Denegar nombrando el
  campo que falta dice la verdad y lleva a la misma puerta cerrada.

## Consecuencias

- (+) **Cierra la clase entera con un solo cambio para quien la active:** el comentario, el
  borrado y el carácter invisible (`REQ-023`) dejan de abrir por la misma vía, y también las que
  nadie ha descubierto todavía — incluida la clave con **otra capitalización** (`QA-023-09`),
  que se resolvía como ausencia y queda cerrada **por construcción**, sin reconocer ninguna
  capitalización y sin ninguna tabla que envejezca.
- (+) **El número de transcripciones BAJA:** la dirección se declaraba en dos sitios y ahora en
  uno. Un campo nuevo que llegue al lector sin declarar su dirección **hace fallar el banco
  nombrando esa clave** (`REQ-024 CA-02`).
- (+) **Un fail-closed que no es silencioso:** cuando el rigor llega a `critico` porque un campo
  ausente se resolvió con el valor que más restringe, el motivo **lo dice y nombra el campo**.
  «Entra pero no ve nada, sin explicación» es un bug de diagnóstico, no una puerta.
- (−) **Un proyecto que NO active la llave sigue expuesto a la clase entera.** No se maquilla:
  es la consecuencia directa de `CA-05` y `CA-11 (iii)`, y queda **nombrada** en «Fuera de
  alcance» de REQ-024 con dueño (`analista-requerimientos` para el texto; cada proyecto
  consumidor para la decisión de activar), ventana **1.35.0** y forzador (el primer proyecto que
  reporte un cierre sin auditoría por esa vía).
- (−) **Activar tiene un coste de migración que se paga de golpe.** Todo REQ heredado que omita
  uno de los cuatro campos deja de cerrar hasta declararlo. Mitigación: la llave nace apagada, el
  `_doc` del manifiesto manda **medir antes** con `tools/arnes-lectura.sh` y preguntar por
  **estado** —«cuáles de mis REQ en estado terminal no cerrarían hoy»—, y el informe que
  **anticipa** ese coste queda fuera de alcance con dueño y ventana.
- (−) **`REQ-016` queda con un puntero falso hasta que el analista lo reescriba.** Está medido y
  publicado en cada corrida del banco (`REQ-024 CA-03`, 2 de 4 campos), y el caso dice
  expresamente que **no acredita** que el write-back se haya hecho.
- (−) **Desviación declarada:** `hooks/estado-derivado.sh` no estaba en el `Archivos:` de
  REQ-024 y esta comisión le añadió **un renglón** (leer la llave en la llamada a `jq` que ya
  hacía), porque publica el **rigor efectivo** en su tabla y sin la llave el tablero diría
  `estandar` donde la puerta dice `critico`. Va al Historial de REQ-024 como desviación.

---

## Nota al pie · 2026-09-10 (`analista-requerimientos`) — dos frases de este ADR precisadas, no reescritas

**Por qué una nota y no una edición, ni un ADR nuevo.** Un ADR **no se reescribe encima**
(`AGENTS.md` §9): su valor es decir qué se decidió **y con qué se decidió**, así que corregir el
texto original borraría la única prueba de con qué información se decidió. Y un **segundo ADR sobre
la misma decisión** sería exactamente la transcripción que este repositorio persigue: dos sedes de
una regla se desfasan, y se desfasan hacia el lado que abre. Tampoco es **superficie heredada**, y está
comprobado leyendo: `arnes-init` crea `docs/decisions/` como **carpeta vacía**
(`skills/arnes-init/SKILL.md:33`) y lo que viaja es `templates/ADR.md.tpl`, no los ADR concretos de este
repositorio — así que la imprecisión **no llega a ningún proyecto consumidor**. La forma
proporcionada es ésta: **la decisión, las alternativas y las consecuencias quedan intactas**, y la
nota dice qué hay que leer con condición. La decisión de esta forma es del `analista-requerimientos`
y va escrita con su motivo para que no parezca la salida cómoda.

**Qué se precisa, y las dos frases se citan enteras.**

1. **§ Contexto, viñeta «El radio de migración es el precio real»** (la segunda de las dos que
   cierran esa sección): «*Si la ausencia dejara de perdonarse por defecto, **todo** REQ
   heredado de **todo** proyecto instalado que no declare uno de esos cuatro campos **dejaría de
   cerrar** el día de la actualización.*» Es un **condicional sobre una alternativa que este ADR
   NO adopta** —«que la exigencia sea el DEFECTO en 1.34.0» está descartada en § Alternativas
   porque `REQ-024 CA-05` lo prohíbe—, así que no gobierna nada de lo construido. Pero su
   consecuente es **el mismo que está medido falso**: de los cuatro campos, dos **gobiernan** (y un
   REQ que sólo omita ésos **sigue cerrando**) y dos **deniegan**. Lectura correcta: *dejaría de
   cerrar **el REQ al que le falte uno de los dos campos que deniegan**; a quien le falte sólo uno
   de los que gobiernan, se le aplicaría el valor más restrictivo y cerraría o no según ese valor*.
2. **§ Consecuencias, viñeta «Activar tiene un coste de migración que se paga de golpe»:** «*Activar tiene un coste de migración que se paga de
   golpe. **Todo** REQ heredado que omita uno de los cuatro campos **deja de cerrar** hasta
   declararlo.*» Ésta **sí** habla de la decisión adoptada —encender la llave—, y es la misma
   imprecisión en su forma fuerte. Lectura correcta, con la medición al lado
   (`docs/qa/1.34.0.md` § `QA-024-01`; tabla campo a campo en `requirements/REQ-024.md` § `CA-01`):

   | campo ausente, llave encendida | qué pasa |
   |---|---|
   | `QA:` · `Hallazgos abiertos:` | **DENY** nombrando el campo: **ahí sí** deja de cerrar hasta declararlo |
   | `Sensible a seguridad:` · `Rigor:` | **GOBIERNAN** con el valor que más restringe (`sí`, `critico`): el REQ deja de cerrar **sólo si ese valor lo para** |
   | `Seguridad:` | **DENY**, pero su veredicto se lee **sólo** cuando el rigor efectivo es `critico`; por debajo, su ausencia no para el cierre — igual que tampoco lo para su valor |

   Medido y decisivo: un REQ que omite `Sensible a seguridad:` y `Rigor:` pero ya lleva
   `QA: aprobado`, `Seguridad: aprobado` y `Hallazgos abiertos: (ninguno)` **CIERRA**, con rigor
   efectivo `critico`.

**Qué NO cambia esta nota, dicho para que no se lea de más.** Las **tres decisiones** de § Decisión
se sostienen enteras, incluida la tabla de direcciones campo a campo, que es **correcta**: dice
`gobierna` y `deniega` donde corresponde y nunca dijo que las cinco pararan el cierre. El coste de
migración **existe** y sigue siendo el motivo de que la llave nazca **apagada**; lo que se corrige es
su **magnitud declarada**, que era «todos» y es «los que deniegan». La consecuencia práctica para
quien vaya a encender la llave **no se relaja**: se mide antes con `tools/arnes-lectura.sh` y se
pregunta **por estado** —«cuáles de mis REQ en estado terminal no cerrarían hoy»—, que es la única
respuesta que no depende de que ninguna lista esté completa.

**Trazabilidad.** Causa: **`QA-024-01`** —clase, severidad y dueños **citados** y no declarados aquí:
`docs/qa/1.34.0.md:3175` y `:3416`—, reportado por el `desarrollador` sobre este ADR
**sin editarlo**. El write-back del criterio está en `requirements/REQ-024.md` § `CA-01` y en su
Historial (fila del 2026-09-10); las dos sedes del `_doc` del manifiesto ya llevan las dos ramas.
**El `Estado: propuesta` de la cabecera y su gate humano pendiente NO los toca esta nota**: siguen
como estaban, y el gate del manifiesto está escalado como **`D8`** (`PENDING_APPROVAL.md:169`).

---

## Nota al pie · 2026-09-10 (`analista-requerimientos`) — la PROMESA SIN ACTO de § Alternativas, y el puntero a `ADR-011`

**Por qué una SEGUNDA nota y no una ampliación de la primera, ni una edición, ni un ADR nuevo.** Un ADR
**no se reescribe encima** (`AGENTS.md` §9), y la nota anterior —de otro analista, **fechada** y con su
propia trazabilidad (`QA-024-01`)— tiene el mismo estatuto: su valor es decir qué se sabía **ese día** y
con qué se corrigió. Ampliarla con un punto 3 obligaría además a reescribir su **título**, que lleva una
cuenta («**dos** frases … precisadas»): un número sobre una magnitud que **sube**, es decir la forma que
el write-back de `QA-024-13` acaba de castigar en `REQ-024`; envejecería otra vez a la corrección
siguiente. **Y no es un ADR nuevo** porque aquí **no se decide nada**: el sujeto —«el alcance se enuncia
**por acto y no por puerta**»— ya lo decidió **`ADR-011`**, que **complementa** a este documento sin
superarlo; un segundo ADR sobre la misma decisión sería la transcripción que este repositorio persigue.
**Tampoco es inocua**, y por eso no se declara así: es exactamente la forma que produjo `SEC-083`. Lo que
**sí** acota su alcance —comprobado leyendo, y ya escrito en la nota anterior— es que `arnes-init` crea
`docs/decisions/` **vacía** (`skills/arnes-init/SKILL.md:33`): este ADR **no es superficie heredada** y la
imprecisión **no llega a ningún proyecto consumidor**.

**Qué se precisa, y la frase se cita entera.** § Alternativas, viñeta «**Que la exigencia sea el DEFECTO
en 1.34.0**»: «*Lo prohíbe `REQ-024 CA-05`, que contrata que en esta versión un proyecto que no activa
nada decide **idéntico**, REQ a REQ y decisión a decisión.*»

- **Lo que sigue en pie:** la alternativa está **bien descartada** y por el motivo correcto — `CA-05`
  prohíbe que la exigencia pase a ser el **defecto** en esta versión, y eso no ha cambiado.
- **Lo que es falso leído solo:** la garantía **citada**. `CA-05` ya **no** contrata equivalencia sobre
  «la puerta», sino **sobre el acto de CIERRE**, y **nombra dentro del criterio** el acto que **sí**
  diverge para un proyecto **sin migrar y sin encender nada**: la escritura de `Seguridad: aprobado`
  sobre un REQ que **no declara `QA:`** pasa de **ALLOW** a **DENY**, en los **dos** estados de la llave.
- **Y por qué es la misma familia y no una coincidencia:** lo que diverge **son resoluciones de la
  ausencia de `QA:`** —el estado del que trata este ADR—, sólo que en un acto que **no es el cierre**.
  Una garantía enunciada sobre «la puerta» abarca más actos de los que la medición sostiene.
- **Lectura correcta:** *lo prohíbe `CA-05`, que contrata —de contrato— que en esta versión, **en el acto
  de cierre**, un proyecto que no activa nada decide idéntico; sobre los demás actos que
  `guard-completado` juzga, `CA-05` **no** promete equivalencia y exige que **cada divergencia** vaya
  declarada en el propio criterio (`ADR-011`).*

**Las cifras se citan y no se transcriben** (medición fechada, **no** umbral de nada): las **24** celdas
del acto de cierre deciden **idéntico** y las **6** divergentes del diferencial completo son exactamente
la firma sobre un REQ sin veredicto de QA. Sedes: informe del `desarrollador` en `CHANGELOG.md`
§ «`SEC-083` cerrado en código…» y § «`CA-06 (v)`: un caso DERIVADO en vez de literal…»,
`PENDING_APPROVAL.md` § **`D12`**, y `docs/seguridad/registro-seguridad.md` § **`SEC-083`** con `R-026`
§5, donde siguen viviendo clase, severidad, dueños, forzador y vencimiento.

**El puntero que faltaba, y aquí se pone.** `ADR-011` dejó **declarado como consecuencia (−)** que este
documento no lo enlaza y que «quien lo abra solo no se enterará de que su alcance se extendió», nombrando
como forma proporcionada **una nota al pie fechada**. Ésta lo es: **el alcance de este ADR —«la puerta de
cierre y el lector de campos» (§ Contexto)— quedó EXTENDIDO por
`docs/decisions/ADR-011-el-alcance-de-la-ausencia-se-enuncia-por-acto-no-por-puerta.md`**, que enuncia la
propiedad **por acto**, deriva la lista de actos de las ramas de denegación del código y **no revierte
ninguna** de las tres decisiones de aquí. `ADR-011` **no se toca** por esta nota.

**Qué NO cambia esta nota, dicho para que no se lea de más.** Las **tres decisiones** de § Decisión se
sostienen enteras —el sitio único en `hooks/lib.sh`, la tabla de direcciones campo a campo y la
activación por `campos.ausencia_exige`, que sigue naciendo **apagada**—; la nota anterior sigue valiendo
tal cual; el `Estado: propuesta` de la cabecera y su gate humano **siguen como estaban**; y no se cierra
ningún hallazgo ni se firma ningún veredicto.

**Y una señal que este ADR no puede leer sobre sí mismo, así que va escrita para su gate.** Con ésta son
**tres** las frases de este documento precisadas en el mismo día, y las tres dicen lo mismo: **qué nota un
proyecto que no hace nada** (`:41` en § Contexto, `:131` en § Consecuencias, `:101` en § Alternativas).
Ninguna la encontró quien las buscaba: salieron de comisiones que medían otra cosa. Tres sedes de una
misma afirmación corregidas **sede por sede** es la forma que este repositorio ha perdido cinco veces y
que `ADR-011` acaba de prohibir **para el código** —enumerar sedes en vez de enunciar la propiedad—, así
que la nota al pie **basta para esta corrección y no debería usarse una cuarta vez sobre esta misma
afirmación**. La salida proporcionada, que **no se toma aquí porque es una decisión sobre este ADR y no
puede tomarla este ADR**: retirar de este documento la **magnitud** del radio de migración y remitirla
**una sola vez** al sitio que la mide y la mantiene —`REQ-024` `CA-01` y `CA-05`—, dejando aquí la
decisión, que es lo que un ADR debe conservar. Dueño: el **propietario** en el gate de este ADR, o el
`auditor-seguridad` si lo levanta antes. Y el dato que ese gate necesita saber: este documento sigue en
`propuesta`, de modo que ratificarlo hoy es ratificar un texto que **se lee con tres condiciones**, y las
tres están en sus notas.

**Trazabilidad.** Causa: el **informe del `desarrollador` de `REQ-024 CA-06 (v)`** del 2026-09-10
(`CHANGELOG.md` § «`CA-06 (v)`: un caso DERIVADO en vez de literal…», § «Fuera de alcance, hecho y
declarado»), que encontró esta sede con un caso **derivado** —«toda promesa de equivalencia lleva el acto
DENTRO de la promesa»—, la reportó **sin editarla por dueño** y remitió a la doctrina ya decidida; método
y denominadores en `docs/qa/1.34.0-req024-ca06v-metodo.md`. Doctrina aplicada: **`ADR-011`** (el sujeto
por acto) y **`REQ-023 CA-10`** (una oración titular se juzga **leída sola**). Write-back gemelo del mismo
día en la otra sede: `requirements/REQ-024.md` § «Conflictos registrados» y las dos filas de su Historial.
*(Escrito **leyendo** este ADR, `ADR-011`, `requirements/REQ-024.md` § `CA-05`/§ `CA-06`/§ «Conflictos
registrados» y `CHANGELOG.md` en `rel/registro-1.33.0`, base `8b06cd6`; **sin ejecutar nada** — las cifras
son las del `desarrollador` y esta nota no las re-deriva.)*
