# CHANGELOG — ArnesJuan

> Bitácora de versiones del plugin. SemVer; cada versión tiene su tag `vX.Y.Z`.

## [GitHub] — 2026-09-08 · `SEC-054` remediado: el ADR y el README dejan de afirmar lo que la medición desmiente — y aparece un TERCER sitio
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus). Autorización expresa del propietario, 2026-09-08.

### La nota de `ADR-005`, añadida y no sustituida

Bloque de cita **inmediatamente después del punto 4**, sin borrar ni editar una palabra del original y
sin tocar `Estado:` — porque **un ADR no se reescribe** (`AGENTS.md` §10) y lo decidido el 2026-09-07 y
lo medido después tienen que poder leerse **juntos**.

Lo que dice, y la formulación es lo que vale:

> **Qué acredita hoy el verde:** que el control **falla sobre la entrada nombrada en el forzador** —una
> aritmética concreta, **un ejemplar**—; **no** la propiedad «el instrumento responde al sujeto», porque
> el testigo es **predecible sin ejercer nada**. Mientras testigo y parámetro sean constantes del mismo
> sistema en **razón fija**, **toda magnitud alcanzable sin hacer el trabajo pasa**, en toda máquina y
> toda corrida. El par «mutada FALLA · sin mutar PASA» prueba que el control **falla sobre una entrada**,
> no que **distinga**.

Y una consecuencia que el desarrollador derivó y que corrige el propio hallazgo: **el residual no se
puede clasificar por la intención del autor, porque el conjunto que pasa es estrictamente mayor que
«lee el sujeto» — así que incluye el descuido.** La frontera «falsificación deliberada» sólo se vuelve
verdadera **después** de las dos piezas de coste cero.

### Cuatro afirmaciones más, corregidas en `tests/util/README.md`

1. **El `0 de 30 en cuatro regímenes`, en DOS sitios** —la nota de la escalera de `CA-03 (d)` y la fila
   de `ARNES_SONDA_CAL_R`—, sostenía «subir `r` de 3 a 5 no movió la tasa». QA lo retiró. Ahora dice que
   **hoy no hay medición que sostenga esa frase** y publica la que sí existe: **0/16 · 1/16 · 9/16**, con
   **8 de 13 casos en (c)** y `sonda-procesos.sh` **sin un solo FAIL en 48 corridas**. De `r=5` queda
   medido **sólo el coste** (1,2825× contra techo 1,25×), y por eso `r` está en 3.
2. «La palanca que arregló la fragilidad fue (c)» — desmentida **en su generalidad**: la mejora está
   medida **en reposo**; fuera del reposo persiste y no queda acreditada como resuelta.
3. «Lo que esto NO cierra» decía que sólo pasa la sonda que **lee** el snippet. Reescrito por propiedad:
   pasa **toda** sonda cuya magnitud publicada sea **alcanzable sin ejercer el sujeto**.
4. **La anterioridad del testigo** decía que comprueba «esa independencia». Ahora acredita lo que
   acredita: que la sonda no pudo **alimentar** el testigo, **no** que no pueda **predecirlo**.

### El tercer sitio, encontrado y NO tocado

**`tests/escenarios/hooks/README.md:378`** lleva la misma afirmación **sin matizar, literal y en
negrita**. `SEC-054` nombra **dos** sitios y hay **tres**, y el tercero también se distribuye con
`source: "./"`. El desarrollador tenía ese directorio vedado y **no lo tocó**: queda enrutado a la
comisión de partición de REQ-014, que sí lo declara en su huella, y el auditor tiene que ampliar el
alcance de `SEC-054`.

`requirements/REQ-021.md:130` —el título de `CA-03`— lleva la misma frase, y es del write-back del
analista en 1.34.0.

### Y una disciplina que conviene registrar

**No corrió el banco completo, a propósito:** *«hay cuatro comisiones vivas y la regla de despacho dice
que dos que miden no van a la vez»*. Comprobó en su lugar lo que sí podía sin medir —el caso `CA-01.4`
replicado con su propio `awk`, **1** línea apuntando a `sonda_lee` y **0** transcripciones del parser— y
las tres gates de §7. Y dejó **intactas** las cifras de coste del ADR que no pudo re-medir, diciéndolo:
*«no las re-medí y el informe de QA no las desmiente»*.

## [GitHub] — 2026-09-08 · REQ-014 reabierto: el techo se re-deriva comprobando su factibilidad ANTES de escribirlo, que es el paso que faltó
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Reapertura por la **REGLA DE ESTADO** de §9, decidida por el propietario. `Estado: completado` →
**`en-progreso`** — y no `en-revisión`, con el motivo escrito: ese estado significa «terminado, en
validación» y hoy es falso, porque queda código por escribir. Vuelve al desarrollador, no a QA.

`QA:` y `Seguridad:` sin tocar pero **declarados invalidados** en el Historial: se emitieron el
2026-09-06 sobre la redacción anterior de `CA-18` y `CA-12`. Y el dato que hace la nota no decorativa:
`DEV-014-01` y `DEV-014-02` son **`contrato`**, así que `guard-completado` **deniega** el cierre mientras
lo sigan siendo. **Ningún `aprobado` viejo puede cerrar este REQ.**

### El límite, enunciado como fórmula y no como número nuevo

```
líneas(f)  ≤  max( N , piso(f) × k )
```

- **`piso(f)`** = el mínimo autónomo, **la parte que ninguna partición baja** —partir produce *dos*
  pisos, no medio—. Se declara por archivo en `PISO_AUTONOMO_SECCION` **con su derivación término a
  término**, tres comprobaciones de máquina, y un **límite honesto** en la forma de `CA-06`: el término
  «bloque indivisible mayor» es una afirmación sobre la estructura que **ninguna máquina decide**, e
  inflarlo para caber es **regresión** que devuelve el hallazgo a `contrato`.
- **`N` = 400 no cambia.** Mismo número, mismo tipo operativo, misma dirección. Cambia **a qué se
  aplica**: gobierna los **42 de 45** archivos cuyo piso cabe por debajo.
- **`k` = 1,25**, literal **con su derivación escrita**: `564/460`, `467/467`, `516/460`, `511/467` → el
  mayor, redondeado al siguiente múltiplo de 0,05. Con obligación de **re-derivarse en la misma edición
  que cambie cualquiera de sus términos**.

**Y el paso que faltó la vez anterior, hecho esta vez:** comprobó la factibilidad **antes** de escribir.
Con **sólo** la razón, un archivo de 12 líneas con piso ~5 tendría techo 6,25 y **~42 archivos hoy
conformes saldrían rojos**. De ahí el `max(…)`. El defecto original era exactamente ése —fijar 400 sin
medir cuánto mide una sección autónoma mínima— y repetirlo con otra cifra habría sido la misma clase.

**Dos puntos que faltaban:** **(ii)** qué hacer cuando **ni partiendo cabe** —vuelve al analista, y las
dos únicas salidas llevan gate—, porque su ausencia produjo el interbloqueo real de hoy: **puerta
requerida roja sin ninguna acción conforme disponible**, con `continue-on-error` y sacar `CA-18` del CI
**prohibidos por nombre**. Y **(iii) par discriminante**, con el negativo nombrando **archivo, tamaño y
techo** y exigiendo que el positivo exista.

**Dato nuevo que refuerza el argumento:** `37/1` tiene 13 casos declarados → **65,2 líneas por caso**,
frente a **4,1** en `07-bash-falsos-positivos.sh`. Un factor **16×**: «líneas por caso» tampoco era la
magnitud.

### `CA-12` — el oráculo por propiedad

«Todo campo que sea **MEDIDA o SORTEO** y no **IDENTIDAD**», sitio único en `inventario.sh` sin
transcribir la lista, con la mitad que **no** se normaliza dicha aparte, y el negativo exigiendo **tres
inyecciones necesarias** (suprimido, renombrado, veredicto invertido) — porque un oráculo que normalizara
todo saldría idéntico siempre y no distinguiría nada.

### Dos defectos que el analista encontró por su cuenta, y el primero es el mejor del día

**`CA-14` estaba desmentido por la misma medición** (tres corridas intactas no eran idénticas) **y su
remedio literal era peor que el defecto**: «se estabiliza antes de particionar» habría ordenado **borrar
del banco las 20 líneas de medición que REQ-017 y REQ-021 existen para publicar**. Ahora corre bajo el
oráculo de `CA-12` y «inestable» se define como *en su identidad o su veredicto*, **no en su medida**.

**`CA-31` habría quedado cierto sobre un árbol que ya cambió**: todas sus condiciones se cumplen con
1.32.0 publicada y ninguna miraba el trabajo de la reapertura. Gana cuatro condiciones y la exigencia de
veredictos posteriores al 2026-09-08.

### Y una conjetura fechada, no un hallazgo

El orden «la partición va después de cerrar REQ-021» probablemente protegía **un oráculo que ya no
discriminaba**, no la congelación de `CA-07 punto 2` — las secciones a partir son justo las que publican
las cifras volátiles. Además ese orden es hoy **inoperante**: con REQ-021 `bloqueado` y en 1.34.0,
«después de cerrarlo» sería nunca.

**Coste: 5 comisiones, con riesgo real de 7.** Vueltas dev↔QA disponibles: **0 de 3 consumidas**.

## [GitHub] — 2026-09-08 · REQ-021: el REQ deja de afirmar lo que la medición desmiente, y las cifras retiradas quedan marcadas como retiradas
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Write-back de la vuelta 3. `Estado: bloqueado` y `Versión destino: 1.34.0` sin tocar; `QA:` y
`Seguridad:` tampoco.

### El criterio que fallaba, corregido donde vivía

`CA-03 (a.3)` condición 1 se parte en **(1.a) no coincidencia** y **(1.b) impredecibilidad** —
*«**no coincidir no es no ser predecible**»*—, con las dos piezas de coste cero: tamaño **sorteado por
corrida** y terna **fuera de todo directorio que la sonda reciba**. La condición 2 se extiende a «ni
**LEER** el canal». El título pasa a «no pueda ALIMENTAR **ni PREDECIR**».

**Y el forzador de `QA-021-10` deja de enumerar**, que era su defecto de forma: pasa de «la mutación
tautológica medida» —un ejemplar— a un **conjunto de mutaciones por vía de predicción** (no menos de 3,
**operativo**, ejemplos no exhaustivos con sede en el fail-before), en **dos corridas consecutivas con
sorteos distintos**, ejercido por quien no escribió la sonda. La lección, medida tres veces en este
REQ: **acreditar el ejemplar no acredita la clase.**

La frontera de «falsificación deliberada» queda reescrita como **lo que era, una salida** —clasifica por
la intención del autor, que ningún control mide— y sólo se vuelve verdadera con (1.b) y (2). Y se añade
la **vigencia** de los «hoy» de las condiciones 2–5: describen el árbol previo; en `2ce7804` están
implementadas y **aun así no distingue**.

### Las cifras retiradas quedan marcadas como retiradas

`CA-08 (ii)` queda **NO ACREDITADO** con las dos ramas cerradas, y **se borra de su palanca (1) la
cláusula «bajar `r` sólo mientras (d) siga en 0 de 30»** — `r` vuelve a la lista de (d). `CA-03 (d)`
publica el estado real (**0/16 · 1/16 · 9 de 16**), retira el «0 de 30», y declara que **todo rojo sin
regresión cuenta**: antes decía «fuera de banda», que era **la forma (d) dentro del criterio escrito
para cerrarla**. `(iii)` se publica como **rango** (2,568–4,382×, techo 6× cumplido).

Y lo que más vale para quien lea esto en un año: el `0/30` de la vuelta 2, el `1,1734× → CUMPLE` y el
`2,245×` quedan anotados como **RETIRADAS en sus propias filas del Historial**, para que el REQ no siga
publicando cifras retiradas como si fueran medidas.

### `CA-06` punto 6 — cómo se acredita un régimen

**Por su efecto**: magnitud de referencia medida **dentro** del régimen, con rango, muestras y **el
mecanismo de la carga escrito**. Nace de que el «0 de 30 en cuatro regímenes» de la vuelta 2 no publicó
ni una evidencia de que sus cuatro regímenes existieran, y su generador **no está escrito en ninguna
parte**, así que no se puede reproducir. Y `CA-03 (c)` gana la regla que faltaba: **un FAIL de (c) sin
regresión cuenta como falso rojo para (d)**.

### Dos criterios nuevos, y uno que deliberadamente NO se toca

`CA-10` **punto 3**: la puerta se atraviesa en **todo camino** que consuma un registro de sonda,
comprobado **sobre el texto**, con aborto nombrando el archivo (`QA-021-12`). **`CA-11`**: el FILTRO
selecciona **qué casos corren**, no cambia el veredicto de los que corren (`QA-021-13`).

**`QA-021-05` no cambia criterio, a propósito:** `CA-04` punto 1 ya está bien escrito y **ya ofrece dos
mecanismos más fuertes que el elegido** — ampliarlo sería taparlo. Es la distinción entre un criterio
débil y una implementación débil, y aquí es la segunda.

### `Hallazgos abiertos:` — 14 entradas, y una diligencia que conviene copiar

Entran `QA-021-11 (contrato)`, `QA-021-12` y `QA-021-13`; se actualizan `QA-021-05`, `06` y `10` con lo
medido. **Todas con la clase primera dentro de su paréntesis, y el balanceo verificado entrada por
entrada** — porque el parser de `hooks/guard-completado.sh` parte por comas a **profundidad 0** y toma la
clase hasta la primera coma interna. Un paréntesis mal cerrado ahí no da error: **cambia la clase que la
puerta lee**.

### Dos cosas declaradas y no escritas, por estar fuera de la huella

- **ADR para `P-02`** —si el contador de vueltas se reinicia al cambiar de ventana—: es **cambio de
  fondo**, porque cambia el significado de un límite de `AGENTS.md` §6 que los proyectos heredan por
  `templates/AGENTS.md.tpl`, y **aquí sí hay a qué suceder**. Decisión del propietario. Juicio del
  analista, sin cerrarlo: la opción «reinicio sólo si el propietario cambia el alcance, con el gasto
  anterior anotado» es la más fiel al motivo del tope; **«se reinicia al cambiar de ventana» convertiría
  el aplazamiento en un mecanismo de reinicio, que es justo lo que el tope existe para impedir.**
- **Write-back candidato a REQ-023**: su `CA-03` usa **el mismo patrón** «redactado para que una lista de
  prohibidos falle la prueba», y la lección de este REQ es que eso acredita el ejemplar y no la clase.
  Conviene que llegue **antes** de que REQ-023 se implemente.

## [GitHub] — 2026-09-08 · REQ-019: el trinquete protegía el NÚMERO y no la propiedad, medido en las dos direcciones. Nace CA-17
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Comisión previa que `CA-15` exige antes de repartir. **DoR: sí**, con el índice como único pendiente
—y es de la coordinadora, no devuelve el REQ a `borrador`—.

### El riesgo que se le planteó era real, y el propio inventario no lo distinguía

Se le pidió comprobar si `CA-15` separa «texto que describe una invariante **cumplida por máquina**» de
«texto explicativo», porque si no lo hace **el trinquete cuenta líneas y no protege nada**. Lo midió, y
falla en **las dos** direcciones:

- El carácter `🔒` marca **7** bloques de `AGENTS.md` y **2 de los 7 no los cumple ninguna máquina**: son
  decisiones del propietario (el modelo con que corre el QA; la política de autoalojamiento).
- Y al revés: **§13 describe conducta de máquina en bloques que no están en la tabla ni llevan `🔒`** —el
  aviso que no deniega ante un veredicto fuera de vocabulario, el recorte de celdas a 40 caracteres, la
  rotación que mueve y no resume, el bloque de continuidad, «sin manifiesto los hooks son inertes»—.
  Entraban en el inventario sólo como **promesa genérica**, **indistinguibles** de «secretos sólo en
  variables de entorno» de §10, que no cumple nadie.

### `CA-17` — cada fila del inventario declara **su ejecutor**

Ruta del archivo del mecanismo con su función, fila o cadena literal; o la marca literal
`ninguna máquina`. Cinco cosas lo hacen algo más que una columna: **(1)** el ejecutor se determina por
**búsqueda literal sobre el mecanismo** —sitio único: `codigo_app.globs` más `skills/*/SKILL.md`— y
**nunca por la decoración del documento**, que es un campo escrito por una persona y que ninguna puerta
verifica (la clase de `arnes_version` y de `Rigor:`); **(2) fail-closed**: un ejecutor declarado tiene
que resolver, y uno **fabricado es peor que `ninguna máquina`**, porque afirma que el árbol hace algo que
no hace **dentro del artefacto que acredita la no-pérdida**; **(3) trinquete asimétrico**: retirar un
elemento **con** ejecutor exige además **citar el código que dejó de cumplirlo**; **(4)** la discrepancia
**se anota y se enruta, no se arregla** — lo que compra `CA-17` no es la corrección, es que **deje de ser
invisible**; **(5)** declarado **acreditación única, no puerta permanente**, con su acotación entera,
que es lo que `SEC-033` reprochaba no decir.

### El reparto en fases, y por qué «cuatro fases» era un número falso

Son **siete**, y la estimación anterior omitía **tres comisiones estructuralmente necesarias**: `F3-bis`
(`CA-13` obliga a que las preguntas de trabajo las escriba **quien no repartió**, así que no caben en la
comisión que reparte), `F5` (QA) y `F6` (auditoría, obligatoria por §6 y donde el registro cierra
`SEC-033`). Total honesto: **9–11 comisiones y ≈8,5–14 h**, con lo añadido marcado como **estimación**
desde las medianas medidas del ciclo 2. Cada fase declara precondición, entregable con su sede, agente,
solitario, **qué detiene la ventana** y **puerta de salida**. Y una cláusula **«la ventana no crece»**:
lo que el reparto descubra se anota y se enruta, no se arregla dentro; una fase que no cabe **se parte**,
no se amplía la comisión en curso.

### Dos defectos de criterio que habrían llegado a QA como `contrato`

- **`CA-03`** tenía el único número del conjunto **sin declarar su tipo**. Ahora es `no menos de 1`,
  **operativo**, con dirección de subir.
- **`CA-04`** exigía igualdad de esqueletos **sin sujeto**: leída como inmovilidad del archivo,
  **declaraba incumplido un trabajo ajeno y correcto** — la familia de la forma **(c)**, ya corregida en
  `CA-02.1` y para las plantillas, pero no para el esqueleto del propio documento.

**Y se aplicó la regla a sí mismo:** había escrito «se validan **diecisiete** criterios» en dos sitios —
una cardinalidad que el criterio siguiente desmiente. Sustituida por «el conjunto entero de criterios de
este REQ (sitio único: este archivo)».

### `SEC-033` cierra dentro de este REQ, en `F4`

Lo cierran `CA-05` puntos 5 y 6 (cero afirmaciones de detección continua, cero rangos cerrados de
criterios sobrevivientes en `ADR-003`, los dos **de contrato**). Falta una edición de `ADR-003`, dueño
`desarrollador`, y el auditor cierra la entrada del registro en `F6`. **Con una restricción sobre el
arreglo:** `ADR-003` tiene que corregirse **por propiedad** —«cada documento en alcance y su plantilla,
en las dos direcciones»—; corregido nombrando `AGENTS.md.tpl`, el hallazgo cierra y **vuelve a abrirse**
con el segundo documento.

## [GitHub] — 2026-09-08 · R-015: SEC-052 cierra, y el permiso para publicar por delegación no tiene frontera escrita — con una publicación pasada que lo prueba
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `auditor-seguridad` (Opus).

### `SEC-052` → `mitigado`, verificado resolviendo cada cita y no aceptando el reporte

Barrido de las cuatro formas de la atribución retirada (`auditor dejó dicho`, `1.33.0 cerrara sin`,
`bloquea el cierre de la ventana`, `escala a contrato si cierra 1.33.0`): **cero** en el cuerpo. La
cláusula ahora se **cita** contra `registro-seguridad.md:4303-4317` y las dos citas resuelven exactas. La
consecuencia de máquina está corregida y comprobada **en el código**: el bloque de
`guard-completado.sh:486-527` lee el campo del REQ **que se cierra**. Y el punto que más importaba —el
argumento 3— está **rederivado, no corregido de fecha**: retira por escrito el argumento de calendario y
lo sustituye por un hecho del árbol. **Write-back pendiente de enrutar:** retirar `SEC-052 (contrato)` de
`Hallazgos abiertos:` de REQ-023.

### `SEC-053` — `contrato`, alta, dueño **propietario**: son TRES lecturas, y la que se aplicó no está escrita

El criterio de publicación delegada (`docs/gobernanza/autoalojamiento.md:148-155`) dice *«**cualquier** …
hallazgo abierto de clase `usuario/dinero` o `contrato` … devuelve la decisión al propietario»* y **no
declara sobre qué conjunto**. Medido, y sale peor de lo planteado:

- **`v1.32.1` (`973448f`) se publicó por delegación con un `contrato` abierto.**
  `git show v1.32.1:docs/seguridad/registro-seguridad.md` trae `### SEC-020 — contrato · abierto` en su
  línea 1305, y la entrada que anuncia la publicación (`CHANGELOG.md:2343-2350`, **agente:
  coordinadora**) **nombra a SEC-020** entre lo que cruza. Sin entrada en la cola.
- `v1.32.0` sí tuvo aprobación expresa (`CHANGELOG.md:2688`), así que es conforme — pero **no por
  delegación**.
- Lectura **(a) global**: 17 `contrato` abiertos hoy → la delegación estaría muerta desde que se firmó.
  **(b) por ventana**: **tampoco salva a v1.32.0**, porque SEC-020 *es* de la ventana 1.32.0.
  **(c) por los REQ que la ventana cierra**: sólo ésta hace conformes las dos publicaciones, y **no
  aparece en ningún documento**.

**La prueba de que no se puede aplicar como está, y la dio el auditor sobre sí mismo:** *«no sé decir si
mi propio hallazgo cuenta»* — bajo (a) devuelve el tag al propietario, bajo (b) y (c) no, porque no
cuelga de ningún REQ.

> **Y la forma reutilizable, que es lo peor:** sin frontera escrita, **la lectura se elige en el momento
> de publicar la parte que se quiere publicar, y siempre hay una que concede el permiso.** Es `SEC-045` y
> `SEC-052` aplicados al **permiso para publicar el mecanismo que gobierna a los demás proyectos**.

*Forzador:* la primera publicación en que se pretenda ejercer la delegación. *Vencimiento:* antes de ese
tag. *Escalada:* si se publica por delegación con la frontera sin escribir, esa publicación se anota como
**de autoridad no acreditada** y se pide ratificación expresa a posteriori.

### `SEC-054` — `contrato`, alta: 1.33.0 publicaría tres textos firmados que la medición desmiente

Primero la mitad buena, medida **por objeto de árbol**: **`hooks/` en `HEAD` es el mismo objeto
(`88c1465…`) que se firmó en R-012**, y `hooks/ tools/ .github/ .arnes/` no tienen **ninguna** diferencia
con `b6e581b`. No hay regresión en la capa de enforcement y la línea base de R-012 sigue vigente sin
re-auditar.

Lo que hay que declarar: **todo el delta de código desde esa firma es de REQ-021**, y con él se
publicarían tres textos que afirman lo que QA midió falso —

- `docs/decisions/ADR-005-…md:42` — «**Cada corrida acredita que el instrumento responde al sujeto**», en
  un ADR con `Estado: aceptada` y `Versión: 1.33.0`;
- `tests/util/README.md:50` — la misma afirmación;
- `secciones/38-sondas-compartidas.sh` — publica **PASS** sobre esa acreditación **en la puerta requerida
  de `main`**.

Contra `docs/qa/1.33.0.md:2448-2454`: *«la acreditación del propio banco certifica UNA aritmética, no la
propiedad»*. **No es duplicado de `QA-021-10`**: ése bloquea el cierre de REQ-021 y funciona; lo que nada
cubre es que **el texto firmado se publique igual** — `guard-completado` no mira ADRs ni READMEs. Y el
plugin se distribuye con `source: "./"`, **así que el ADR y el README llegan a los consumidores**. Es
literalmente la **condición 3** de la cláusula de escalada de SEC-047, en otra superficie.

**Remediación barata y sin revertir código:** nota fechada en ADR-005 declarando su punto 4 **no
acreditado** —los ADR no se reescriben, así que es **gate humano**— más una línea en
`tests/util/README.md:50` diciendo qué certifica y qué no.

**Agravante que el auditor cita y NO reclasifica:** `QA-021-06` mide 5/30 calibraciones fuera de banda —2
en reposo— y la vuelta 3 añade `CA-03 (d)` en **9 de 16** bajo saturación. Publicar eso hace **no
determinista la única puerta automática de `main`**, y la consecuencia humana está medida en `AGENTS.md`
§13: *la fricción termina con alguien apagando el guard*.

### Y el auditor se negó a fabricar un forzador, que es la parte que más vale

Preguntado si esto debe detener la publicación: **no hay veto de seguridad.** La clase `contrato` de
SEC-053 y SEC-054 gobierna el cierre de **un REQ que las declare**, no la publicación de una ventana.
Que el tag vuelva al propietario **no lo decide su hallazgo** — lo decide el criterio de
`autoalojamiento.md:148-155`, cuya frontera es precisamente SEC-053. En sus palabras: *«afirmar lo
contrario sería fabricar un forzador, que es lo que SEC-052 castiga»*.

## [GitHub] — 2026-09-08 · REQ-021 a `bloqueado`: el tope de 3 vueltas se agota y la clase sobrevive a su cuarta variante. Escalado al propietario
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (**Opus**, por decisión del propietario).

**`AGENTS.md` §6 aplicado tal como está escrito:** agotado el tope de **3 vueltas dev↔QA por REQ** —el
contador no se reinicia—, el REQ **o cierra con residual declarado o pasa a `bloqueado` y se escala al
humano**. El residual **no está disponible**: `QA-021-10` es `contrato` y `guard-completado` deniega el
cierre; sólo existiría si QA o el auditor lo **reclasificaran**, y QA se negó con la evidencia delante.
Decisión en `PENDING_APPROVAL.md`, **pipeline detenido**.

### La frase que cierra el REQ, y vale para cualquier control de este tipo

QA reprodujo el forzador **y cuatro mutaciones más, tres de las cuales no leen el sujeto, y las cuatro
PASAN**. La causa es aritmética: `SP_RESOLUCION=1`, `SP_CAL_MARGEN=4` y `SONDA_DISC_PROC_VECES=2` son
**literales**, así que `testigo = parámetro / 2` se cumple **por construcción en toda máquina**. La
condición 1 de `(a.3)` exige que el testigo **no coincida** con el parámetro —y no coincide, 2 ≠ 4—
pero:

> **«No coincidir no es no ser predecible.»** Lo que hace que un contraste pueda fallar es que la sonda
> no pueda **saber** el testigo sin trabajar.

**El forzador nombraba un ejemplar; la clase sobrevive.** Es la **cuarta** variante dentro del mismo
REQ: `2N/N = 2000`, luego `N−1`, luego el rastro que el juez crea y la sonda escribe, y ahora un testigo
**independiente en su origen pero derivable en su valor**. Cada vuelta cerró la instancia documentada y
la siguiente encontró una variante — que es, literalmente, el motivo por el que §6 pone un tope que no
se reinicia.

### Lo que la vuelta 3 sí consiguió, porque no fue un fracaso

El mecanismo pasó de **razonable a comprobable**: el juez obtiene el testigo **antes** de invocar la
sonda —*lo que no existe antes de que el sujeto corra, pudo haberlo producido el sujeto*— a coste **cero
procesos**, porque es un cambio de orden. La mutación del forzador **por fin FALLA** (`rc 1 · 74/3`)
mientras la misma copia sin mutar **PASA** (`rc 0 · 77/0`). `CA-08 (iii)` **mejoró** en las dos
magnitudes (procesos 3,714× → **3,571×**; reloj 2,921× → **2,245×**, techo 6×). Banco **880 PASS · 0
FAIL · 4 SKIP, rc 0**, cuadre **884 = 884 = suma de 45 literales** verificado por QA. `CA-07` acreditado
en sus tres puntos contra un worktree de `794fa4c`: **828 casos, 61.287 bytes, `cmp` idénticos**.

### La cadena de acreditación que se rompe, y cómo se acredita una carga

**`CA-03 (d)` falla**, con los regímenes acreditados **por su efecto** —una tarea de referencia medida:
262–282 ms en reposo → 402–508 ms con 4 de 12 núcleos → 675–1426 ms con 12 de 12—. Saturación: **9 de 16
corridas** con FAIL, y **8 de 13 casos son `CA-03 (c)`** (el sensible base mide 145.720 µs y no llega a
los 150.000 que (c) exige), **no** la mitad discordante. `sonda-procesos.sh`: **0 FAIL en 48 corridas**.

**El `0 de 30 en cuatro regímenes` de la vuelta 2 se retira**, y el motivo es de forma: su registro **no
publica ni una evidencia de que sus cuatro regímenes existieran**. Un régimen declarado y no acreditado
es un número que no puede salir mal — la misma clase que el REQ perseguía en sus sondas, esta vez en su
propia acreditación. Con él se retira **el permiso que autorizaba bajar `r` a 3** («sólo mientras (d)
siga en 0 de 30», `REQ-021.md:788`), y las dos ramas quedan cerradas: con `r=5`, `CA-08 (ii)` da
**1,2825× > 1,25×**; con `r=3`, **cumple sobre un permiso inexistente**. **`CA-08 (ii)` no queda
acreditado**, y salir de ahí es decisión de alcance del propietario.

### Hallazgos

| | Clase | Estado |
|---|---|---|
| `QA-021-10` el testigo derivable | **`contrato`** | **NO CIERRA** — analista (forma), desarrollador (valor), auditor (tercero) |
| `QA-021-11` cifras publicadas que la medición desmiente, y la cadena que autorizaban | **`contrato`** | **nuevo** — analista + desarrollador + **propietario** |
| `QA-021-12` `37/1` y `37/2` tienen **0 llamadas** a `sonda_usable` e invocan las sondas 2 y 5 veces | `instrumento` alta | **nuevo** — desarrollador |
| `QA-021-13` `run.sh 'REQ-017'` da un **FAIL falso**; preexistente en `794fa4c` | `instrumento` baja | **nuevo** — desarrollador |
| `QA-021-05` la sonda publica `vivos=0` y el `sleep 45` **sobrevivió** (QA lo mató) | `instrumento` alta | NO CIERRA |
| `QA-021-06` acreditación «0 de 30» retirada | `instrumento` alta | NO CIERRA |

**Y lo que hace la decisión barata en cualquier dirección:** QA nombró las dos piezas que faltan y las
dos cuestan **cero procesos** — el tamaño del discordante **sorteado por corrida**, y la terna **fuera
de todo directorio que la sonda reciba**. Con ellas, el conjunto de mutaciones que pasan se reduce
exactamente a «lee el sujeto», y la frontera que el REQ declara —«falsificación deliberada, no
descuido»— pasa a ser **verdadera**. Hoy es una **salida**, porque clasifica por la **intención del
autor**, que ningún control mide.

## [GitHub] — 2026-09-08 · REQ-023 a 1.34.0 sin ADR: la cata desmintió la palanca y encontró un criterio que le habría dado PASS a una guarda cuadrática
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `desarrollador` (cata de viabilidad, sólo lectura) y `analista-requerimientos` (write-back), ambos Opus.

### La cata: sólo lectura, nada escrito en el árbol, y ahorra dos vueltas dev↔QA

**Veredicto: `CA-03` y `CA-04` son satisfacibles a la vez, con el lector que existe, y sin ADR** — pero
no con la palanca que se había estrechado, y sólo bajo una lectura de `CA-03` que el criterio no fijaba.

**Premisa confirmada y más ancha de lo que decía:** el segmento de clave del corpus tiene **10 puntos de
código no ASCII**, no sólo `Módulo:`/`Versión destino:` — también los `—`, `«»`, `¿` de las **líneas de
título**, que llevan `:` y por tanto son «clave» para el lector.

**Conclusión desmentida midiendo.** «Conjunto positivo sobre el alfabeto de la clave con escapes de
bytes» tiene tres formas implementables sin procesos y **las tres mueren**:

| Forma | Cómo muere, medido |
|---|---|
| Por **bytes** | `U+00AD` —de la familia **(ii) declarada**— entra, porque sus bytes se comparten con la `«` y la `í`. Y **diverge por locale**: `ZWSP` y `BOM` admiten bajo `C.UTF-8` y deniegan bajo `LC_ALL=C`, que es `CA-05` — y el fail-open cae del lado del locale que tienen el CI y MSYS |
| Por **secuencias con sustracción** | **El veredicto depende del ORDEN de la tabla**, y para cada orden existe un malformado que admite. Es `H-01` aplicado al alfabeto: retirar no destruye un delimitador, lo **crea**. Iterar a punto fijo lo empeora |
| Conjunto positivo **correcto** | **Cuadrático**: cociente 3,65 contra un techo de 2,2; 315,7 µs frente a 23,1 de la base, **×13,7** |

**El mecanismo que sí pasa no enumera caracteres: enumera lo que ya estaba enumerado, que son las
CLAVES.** *Retirado de la clave todo lo ajeno al alfabeto de las claves que el lector reconoce, ¿lo que
queda **es** una de esas claves?* Dos expansiones y un `case`: **0 procesos** (el subshell más barato de
esta máquina cuesta 675 µs; una guarda de 17,7 µs no puede esconder un fork), **0 falsos positivos en
356 líneas** de cabecera, y veredicto **idéntico** bajo `LC_ALL=C` y `C.UTF-8` por razón estructural —el
corchete contiene sólo bytes ASCII, así que no hay rangos ni clases sujetas a colación—. Denegó las tres
familias completas y las **seis** entradas reservadas imprimibles (`Ω`, CJK, emoji, `U+FE0F`, tag,
`U+2028`); calló sobre `Módulo:`, `Versión destino:`, los títulos decorados y las cinco tolerancias de
`CA-04`.

### Los dos defectos de criterio, que valen más que el mecanismo

**1. `CA-09 (iii)` medía el sujeto equivocado — le habría dado PASS a una guarda cuadrática.** El
criterio anclaba el cociente de duplicación en `arnes_sin_cita`, pero la guarda **no puede vivir ahí**:
necesita el segmento de clave, y partirlo por `:` dentro sería una segunda transcripción de la regla de
clave. Medido: `arnes_sin_cita` marca **1,06 con y sin guarda** —porque la guarda no está ahí— mientras
el candidato cuadrático marca **2,63–3,65 en `arnes_norm_clave`, donde nadie mira**. Corregido a
**propiedad**: el sujeto es *el escáner en el que la guarda resida, determinado por el código y no por
este texto*. Margen sin maquillar: la guarda buena marca **2,05 contra 2,2**, estrecho, y sólo cumple
porque se miden funciones distintas.

**2. La guarda habría denegado un campo legítimamente COMENTADO, y el veredicto dependía de un
espacio.** `arnes_campo_linea` **no es la única boca**: `arnes_estado_cabecera` llama a
`arnes_norm_clave` directamente en `:1880` y `:1891`, y la primera le pasa la línea **cruda, pre-cita, a
propósito**. Medido contra el lector real: `<!--Estado: completado -->` **dispara**;
`<!-- Estado: completado -->` calla. Viola `CA-11` y `CA-04`. Y **las dos salidas tienen precio**, ahora
declarado en el REQ: publicar desde `arnes_campo_linea` deja el campo `Estado` sin guarda en su propio
lector; publicar desde `arnes_norm_clave` exige un interruptor por llamador y rompe la invariante
«primera sentencia del único escáner» de REQ-016.

### Y dos correcciones que el analista encontró fuera del encargo

- **`CA-06` afirmaba algo medido falso**: «todas las bocas siguen entrando por el lector único
  `arnes_campo_linea`». Retirado.
- **El conjunto de claves vive en CUATRO sitios, no en tres**: también en `hooks/campos-req.awk:75-80`.
  Escribir «se usa en las tres» habría sido **la forma (a) dentro del criterio que la prohíbe**. `CA-06`
  enuncia ahora la propiedad, cita los cuatro, y declara que unificar el awk **no** se exige aquí.

### Estado del REQ

`Versión destino: 1.34.0`, `Hallazgos abiertos: SEC-052 (contrato)` —declarado, no cerrado: lo verifica
el auditor—. `CA-03` gana el universo y el procedimiento (**R1, inserción**); el homóglifo (**R2**) y el
sorteo sobre la clase (**R3**, nombrada como *la forma (d)* de REQ-021) van a «Fuera de alcance» con su
motivo medido. `CA-12 (ii)` anclado a su corpus y su versión, con el conflicto de REQ-024 CA-08/CA-09
registrado como resuelto. Añadida la sección **«El techo honesto de la cata»**: ruta crítica del banco,
corpus de fixtures de `CA-04` y `guard-completado.sh` declarados **no medidos**.

**Coste revisado: cinco o seis comisiones, no cuatro** — y no por «más criterios»: `CA-06` se partió en
una decisión de diseño con radio que va **antes** de escribir la guarda, y la constante única de claves
más el `CA-09 (iii)` corregido convierten la sonda de duplicación en trabajo real.

### `requirements/README.md` — el índice, que es una copia a mano

Añadidas las filas de **REQ-023** y **REQ-024** (faltaban las dos; la de REQ-023 era el único punto de
DoR que quedaba). Y corregida la de **REQ-021**, que decía `QA: pendiente` cuando la cabecera dice
`con-hallazgos`, y describía «las tres sondas» después de que el alcance se redujera a dos. **Es la
tercera vez en dos días que estas celdas se desfasan**, y el arreglo real no es corregirlas: es REQ-019,
que las convierte en bloque derivado entre marcadores leído por el mismo lector que la puerta.

## [GitHub] — 2026-09-08 · REQ-021 vuelta 3 de 3: el testigo sale del juez por un camino que la sonda no puede alimentar, y la anterioridad lo hace comprobable
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador` (Opus).

Tercera y última vuelta dev↔QA de `REQ-021`, contra `QA-021-10` (`contrato`): **la misma forma por
cuarta vez —el testigo salía de la sonda que se juzgaba— y esta vez el arreglo es de reparto, no de
aritmética.** El sujeto discordante lo **construye el juez** y llega a la sonda como snippet
(`--disc-sujeto`, obligatorio en `--calibrar`); el **valor** del testigo lo pone el juez; y lo tiene
**antes** de invocar, con las dos marcas de reloj publicadas para que la anterioridad se **compruebe**
en vez de razonarse. Cuesta cero procesos: es un cambio de orden.

- **`tests/util/sonda-procesos.sh`**: fuera `sp_cal_disc`, `SP_DISC_VECES`, `--rastro` y el campo
  `disc_veces=`; el discordante pasa de 3 invocaciones (`cal_n − 1`, que decidía la sonda) a **2** del
  juez, por el **camino único** que ejerce el sujeto.
- **`tests/util/sonda-reloj.sh`**: fuera `SR_DISC_VUELTAS` (`cal_n / 50`) y el campo `disc_vueltas=`,
  que el juez **leía** para construir su propio testigo.
- **`run.sh`**: el juez deriva, cronometra y publica las ternas **antes** de la primera invocación;
  `SONDA_SUELO_US` pasa al juez (quien es juzgado no aporta la vara) y `sonda_discordante` gana
  **cinco abortos nombrados**.
- **Sección 38**: el fail-before se re-ancla a la **definición** de la función que ejerce el sujeto y
  no a un literal de su cuerpo, y entran **4 casos** (28 → 32; `CASOS_ESPERADOS` 880 → **884**).

**Acreditación, con el par dentro de la corrida y contra el juez real sin tocarlo:** la copia con la
observación quitada —la mutación que QA midió **pasando**— da `FAIL` nombrando la condición y los
números (`disc_obs=4 · testigo=2 · parámetro=4`) y la misma copia sin mutar, `rc 0`. Banco
**880 PASS · 0 FAIL · 4 SKIP, rc 0**, cuadre 884; `CA-08 (iii)` **3,571×** en procesos (de 3,714×) y
**2,245×** en reloj (de 2,921×), techo 6×; autoprueba 72/1 con `CA-18` como único rojo.

**Y dos afirmaciones desmentidas midiendo, la segunda contra el trabajo de esta propia comisión:**
la sospecha que QA dejó sin medir sobre la banda del reloj es **cierta** —un `disc_obs` **calculado**
(3998 µs) pasa contra un testigo de 639 µs, porque la banda es una ventana de 625×—; y **`CA-03 (d)`
no es 0 de 30 fuera del reposo**: 0/16 en reposo, **6/16** con 4 de 12 núcleos ocupados y **13/16** en
saturación, con el árbol anterior dando **7/16** y **17/16** bajo la misma carga. No es regresión: es
el mismo instrumento, y el modo dominante es `CA-03 (c)` —`cal_n` derivado de un sondeo de 2 ms—, no
la mitad discordante. `sonda-procesos.sh` sale exacto en las 32 corridas del muestreo en que se
registró su valor, y sin un solo FAIL suyo en las 48. **`QA-021-10` no se cierra
aquí**: la acreditación que lo cierra la ejerce quien no escribió la sonda.

## [GitHub] — 2026-09-08 · REQ-024 (borrador): la ausencia que abre, en el segundo lector; y un conflicto con REQ-023 que hay que anclar antes de implementarlo
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos` (Opus).

Existe porque tres hallazgos sin archivo comparten **una** propiedad: la mitad (2) de **SEC-047** (el
campo comentado, con forzador subido en R-013 a «bypass alcanzable con una edición visible»), las tres
partes de **SEC-051** y la reparación del puntero de **REQ-016 CA-11**. `Versión destino: 1.34.0`,
`Rigor: critico`, `Estado: borrador`.

**Se queda en `borrador` a propósito: ocho preguntas abiertas, cuatro de fondo**, y las cuatro cuelgan
de dos ADR que el propio REQ declara como entregables —cómo se **activa** la exigencia (fija el radio de
migración entero), qué **dirección** de ausencia corresponde a cada campo, **dónde** vive el sitio único
(decide si REQ-016 se reabre) y si ADR-007 cruza la frontera de grano de línea de la cola—. Ninguna se
cierra desde la mesa del analista: son gates humanos.

**Coste estimado: 9 comisiones en el camino feliz, 11–13 realista**, todas en serie (comparten
`hooks/lib.sh` y nueve archivos con REQ-023). Dos precondiciones duras: no arranca hasta que REQ-023
cierre, y `CA-07` no se puede medir hasta que existan las sondas de REQ-021.

### Los dos conflictos con REQ-023, y el segundo hay que anclarlo ya

1. **REQ-023 `CA-11` vs REQ-024 `CA-01`.** CA-11 contrata que la ausencia «se sigue perdonando
   exactamente como antes». CA-01 cambia esa conducta. Compatibles **si y sólo si** ADR-006 elige
   **activación explícita**; si la exigencia fuese el defecto, REQ-023 CA-11 pasaría a describir una
   conducta que el árbol no tiene — hallazgo `contrato` y, si ya estuviera cerrado, reapertura.
2. **REQ-023 `CA-12 (ii)` vs REQ-024 `CA-08`/`CA-09`.** CA-12 (ii) contrata que `arnes_cola_pendientes`
   cuenta y devuelve **exactamente lo mismo**; CA-08 y CA-09 **cambian** el conteo y el `rc` para dos
   formas. No hay contradicción **si** ese criterio queda anclado a **su** corpus y **su** versión — y
   hoy no la hay, porque R-013 midió que ninguna de las formas que abren tiene caso en el banco de
   1.33.0. **Sí** la hay si se implementa como no-regresión **abierta** («la cola nunca cambia su
   conteo»): entonces la implementación de REQ-024 romperá una prueba de REQ-023. Se ancla en el
   write-back de REQ-023, no en 1.34.0.

### `docs/PLAN.md` — cuarta modificación del alcance de 1.33.0 en dos días

Registrada con su motivo: REQ-023 salió el mismo día que entró porque su coste se midió **después** de
meterlo. Y queda escrito que el argumento con el que la coordinadora justificó tenerlo dentro era
**falso y ya estaba medido falso** (R-013 §2): aplazarlo deja `AGENTS.md` §13 igual de honesta. Una
consecuencia inventada para sostener una prioridad es la misma forma que `SEC-052`.

## [GitHub] — 2026-09-08 · Una condición de escalada que sólo existía en el REQ al que beneficiaba: SEC-052, y REQ-023 sale de 1.33.0 por decisión del propietario
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` (write-back de REQ-023) y `auditor-seguridad` (R-014, Opus).

### Lo que decidió el propietario

Con el coste de REQ-023 ya medido —**cuatro comisiones en serie** tras REQ-021: cata del desarrollador,
implementación, QA con una vuelta dev↔QA **por diseño** y auditoría—, el propietario decidió que
**1.33.0 se publica sin REQ-023**, que pasa a **1.34.0**. No es un incumplimiento de ningún
vencimiento: el de SEC-047 es el cierre de **1.34.0**, así que meterlo en 1.33.0 había sido un
**adelanto**, y desandar un adelanto no incumple nada.

### `SEC-052` — `contrato`, media: el REQ citaba al auditor una cláusula que el auditor no emitió

`requirements/REQ-023.md:450-452` y `:566` afirmaban que el auditor había dejado dicho que **SEC-047
sube a `contrato` si 1.33.0 cierra sin REQ-023**. No existe. El auditor lo trazó con
`git log --all -S`: la frase aparece en **un solo commit**, `721cb71` —el borrador de REQ-023 mismo—, y
el blob de R-012 donde nació SEC-047 ya decía **1.34.0**. Su registro nunca dijo otra cosa, y el propio
REQ-023 se desmiente en su línea 431.

**Son dos cosas falsas, no una,** y por la segunda la clase es `contrato` y no `instrumento`: *(i)* la
atribución, y *(ii)* la consecuencia de máquina —«un `contrato` abierto bloquea el cierre de la
ventana»—. `guard-completado` lee el campo `Hallazgos abiertos:` **del REQ que se cierra**, no un
barrido del proyecto: bloquea el REQ que lo declara, y lo que devuelve la publicación al propietario es
la gobernanza (`docs/gobernanza/autoalojamiento.md`), no la puerta.

**La forma, que es lo reutilizable:** una condición de escalada que sólo vive en el documento cuyo
aplazamiento castiga **no es un forzador, es un argumento con la firma de otro**. Es la misma familia
que ya se había medido tres veces en REQ-021 —quien escribe el instrumento diseña el control que sabe
pasar—, aquí aplicada a un forzador en vez de a una sonda.

**Enmienda del auditor para no dejar la escalada colgada de una fecha** (R-014 §4): la mitad (1) de
SEC-047 sube a `contrato` en la primera de tres — que 1.34.0 cierre sin ella; que **deje de ser
latente** (se mida el carácter en la cabecera de algún REQ, de cualquier árbol o de la historia); o que
**un texto firmado empiece a prometer la propiedad y no el carácter** mientras el código guarde sólo el
CR. Formas no exhaustivas, manda la propiedad. Y explícito: **la ventana en que el propietario decida
hacer el trabajo no la sube.**

### Y una afirmación de la coordinadora que la medición desmiente

Al presentar la decisión se dijo que publicar sin REQ-023 «publica una ventana más una promesa falsa en
`AGENTS.md` §6 y §13». **R-013 §2 ya había medido que no:** cerrar la vía del carácter **no cierra la
clase**, porque el comentario y el borrado siguen abiertos; las filas son falsas **desde `v1.30.3`**, en
cinco versiones, de forma **latente** (ningún REQ de toda la historia llevó un carácter invisible en
cabecera). Y en sentido contrario: si se aplaza, la fila del CR de §13 **no** se reescribe —CA-10 es de
REQ-023— y sigue nombrando el CR, que es exactamente lo que el árbol tiene. **Aplazar deja §13 igual de
honesta.** La decisión no cambia; el motivo con que se presentó estaba inflado.

### Write-back de REQ-023 (`analista-requerimientos`)

- **`SEC-051` va aparte, a REQ-024**, y no por tamaño: `hooks/lib.sh:1577-1583` declara **por escrito**
  la frontera con `arnes_cola_pendientes` y deja escrito el precio de cruzarla — unificar la noción de
  cita cambia el **conteo** de la cola, que es un cambio de **veredicto** de la puerta, que es un cambio
  del contrato de REQ-009 (`completado`) **sin ADR**. Verificado leyendo el código.
- **`CA-12` nuevo, y es lo más valioso de la comisión:** la noción de cita de la cabecera gana **no más
  de 0** transcripciones; `arnes_cola_pendientes` cuenta y devuelve **exactamente igual** antes y
  después; y ningún artefacto del REQ afirma que la clase quede cerrada. Existe porque la deriva es
  **previsible**: quien implemente REQ-023 estará editando esa misma función en la misma ventana con
  SEC-051 sugiriéndole unificar, y hacerlo «de paso» es cambio de alcance sin ADR.
- **Seis enumeraciones corregidas.** El REQ llevaba **cinco** listas de dos campos y un «un solo sitio»
  seguido de dos sitios. La propiedad de CA-02 se **deriva midiendo** —campo de cabecera cuya ausencia
  la puerta resuelve del lado que abre— y el recuento va al Historial, nunca al criterio.
- **La frontera de CA-11 estaba medida falsa** y se habría desmentido sola el día que QA la probara:
  decía «¿el documento lo declara **en letra**?», y bajo esa letra `<!-- Sensible a seguridad: sí -->`
  declara en letra. Reescrita por propiedad: *¿la retirada la decide una regla contratada del lector, o
  no la decide nadie?*

### Deuda del auditor descargada en la misma revisión

La remediación (2) de SEC-047 estaba escrita **por enumeración de dos campos** cuando la superficie
medida son cuatro. Queda reescrita **por propiedad** (R-014 §5). `docs/seguridad/gobernanza-datos.md` no
cambia y **ningún estado de seguridad aprobado se mueve**: la línea base de no-regresión de REQ-017
sigue siendo R-012.

## [GitHub] — 2026-09-08 · QA vuelta 1 de REQ-021: la tautología sobrevivió a la reducción de alcance, y esta vez el testigo lo escribe la sonda
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**Vuelta interrumpida por reinicio de la máquina, y cerrada en limpio: `QA:` sin tocar, registro
encabezado como parcial, y lo no mirado tabulado como NO MIRADO — nunca como PASA.** Pero alcanzó a
hacer el experimento que se le pidió primero, y encontró la pieza que decide la vuelta.

### `QA-021-10` — `contrato`, alta: la mutación tautológica que el juez APRUEBA

En `tests/util/sonda-procesos.sh` **el testigo lo escribe la propia sonda**, que es lo que `CA-03 (a.3)`
prohíbe **por nombre**:

```bash
for ((sp_i = 0; sp_i < SP_DISC_VECES; sp_i++)); do
  grep -q x /dev/null || :
  [ -n "$SP_RASTRO" ] && printf 'x\n' >> "$SP_RASTRO"
done
```

El juez **crea el archivo vacío y cuenta**, pero el **valor** lo pone la sonda. Con `disc_obs = cal_n−1`
y el testigo saliendo de las mismas marcas, **`3 = 3` se cumple por construcción, haga la sonda algo o
nada**. Es el `2N/N = 2000` de `QA-021-01` con otra aritmética: **`N−1`**.

QA construyó una copia que **no invoca `grep` ni una vez**, no cuenta ningún proceso y calcula las cinco
magnitudes por aritmética. El juez real, sin tocarlo:
`PASS … (disc_param=4 · disc_obs=3 · testigo del juez=3)`.

**La mutación del desarrollador era la estrecha** —`SP_DISC_OBS="$SP_DISC_PARAM"`, publicar el
parámetro—, y ésa sí la caza. **La clase de `QA-021-01` salió del árbol con la sonda retirada y sobrevive
en el instrumento que se quedó.** Es la lección de método del día en su forma más limpia: *quien escribe
el instrumento muta lo que se imagina*, y por eso la acreditación por mutación tiene que decir **por
quién**.

Es `contrato` y no `instrumento` porque **el REQ afirma dos cosas falsas sobre lo construido**: que el
testigo lo obtiene el juez **sin** la sonda, y que una implementación tautológica **incumple** `(a.2)`.
QA **no reescribió el criterio** — el write-back es del analista.

**Y una abstención que merece registro:** construyó también la mutación de `sonda-reloj.sh` y **no la
ejecutó**, así que dejó su sospecha sobre la banda de 625× anotada **como no medida y por tanto no como
hallazgo**.

**Confirmado de paso:** `QA-021-09` cerrado de verdad —los 4 SKIP salen uno a uno con motivo propio y
«ninguna causa común»—, y con él `QA-021-07`: donde salía `0,000×` ahora sale `procesos=no-aplica` con
motivo. Quality gates §7 **3 de 3**, banco **876/0/4 rc 0**, y **`CA-18` confirmado como único FAIL** de
la autoprueba.

**Validez declarada:** midió sobre `7180739` y el HEAD avanzó a `61063d0` a mitad de comisión;
comprobó que `git diff --stat 7180739..HEAD -- tests/ hooks/ tools/ requirements/REQ-021.md` sale
**vacío**, así que las cifras valen, y lo dejó escrito en el registro en vez de callarlo.

**Conteo de vueltas: 2 de 3 gastadas.** La coordinadora cuenta esta vuelta **aunque quedara
interrumpida**, porque produjo un **bloqueante que obliga a volver al desarrollador** — que es lo que
define una vuelta dev↔QA, no cuántos criterios se alcanzaron a validar.

## [Interno] — 2026-09-08 · Sincronizados `PLAN.md` y `ESTADO.md`, que llevaban dos ventanas de retraso — y la cifra del impuesto de arranque se corrige
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

**Deriva de calendario, corregida.** Los dos tableros situaban `REQ-019` en 1.33.0 y describían la
ventana como «las cuatro palancas de coste», cuando su alcance vigente es **REQ-017 + REQ-021 +
REQ-023**. Lo detectó la comisión de REQ-019 al cerrar su Definition of Ready: era el único punto que no
podía cerrar ella, porque esos dos archivos no están en su `Archivos:`.

**Y el historial del alcance queda escrito, porque vale más que el alcance:** esta ventana **creció tres
veces en un día** —nació con `REQ-017 + REQ-019 + REQ-021`, entró `REQ-023` y salió `REQ-019`—, que es
exactamente el mecanismo con el que este mismo plan explica el descontrol del ciclo 3. Sacar REQ-019 no
pierde su ahorro: el argumento para tenerlo aquí era que *1.34.0 es la ventana con más comisiones*, y eso
se cumple igual siendo **su primer trabajo**.

**Se dice por su nombre lo que la ventana NO entrega: la reducción de tokens.** REQ-017 abarató el
**reloj** del banco y esperar al banco es **gratis en tokens**; REQ-021 ahorra ~150 k por ventana **cuando
exista**; la palanca de tokens es REQ-019 y está en 1.34.0.

**Corrección de una cifra del propio plan.** La tabla de palancas atribuye **~9 k tokens** de impuesto
fijo a `AGENTS.md`. Medido el 2026-09-08: **§0 obliga a tres documentos** y el arranque son **≈17 000–20 000
tokens** —`AGENTS.md` 33 827 B, `requirements/README.md` 31 192 B, `docs/ESTADO.md` 9 707 B; bytes y
palabras **medidos con `wc`**, la conversión a tokens **estimada**—. `requirements/README.md` pesa el
**42 %** y ningún REQ lo tocaba.

**Y la ampliación es menor de lo que la coordinadora anunció**, con dos correcciones suyas registradas: el
**suelo inamovible del README es el 54 % de las líneas y ≈58–64 % de los bytes**, así que el ahorro real
por movimiento son **≈11–13 kB (36–42 %)** y no el doblado que anunció; y **el bloque más caro no lo baja
REQ-019** — el `## Índice`, **19 %** del archivo, es una **copia a mano** de lo que
`tools/arnes-lectura.sh` ya deriva, así que es un **mecanismo** con otro dueño.

**La cola de pendientes se rehace con lo que apareció hoy y no tenía sede:** el hueco (b) por enrutar
(`37/1` y `37/2` no llaman a `sonda_usable`), `REQ-017 CA-03` flaky sobre un REQ ya `completado`, las dos
preguntas de REQ-025 aplazadas a propósito hasta cerrar la ventana, `SEC-050`/`SEC-051` sin ventana, y el
`_doc` del manifiesto que ninguna migración toca. **El bloqueo se nombra:** la fusión está bloqueada por
`CA-18`, y no es un bloqueo de decisión —está autorizado— sino de trabajo por hacer.

## [GitHub] — 2026-09-08 · REQ-021 vuelta 2, medición: `CA-03 (d)` en 0 de 30, y el desarrollador desmiente su propia palanca
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

Máquina en reposo, **una sola comisión viva**, `arbol=87d2609`, bash 5.3.9, 12 núcleos, linux, 2026-09-08.
Oráculo `/proc/stat:processes` leído sólo con builtins.

**`CA-03 (d)`: 0 de 30 fuera de banda**, en cuatro regímenes (reposo · primera invocación en frío · 4 de
12 núcleos al 100 % · 12 de 12 al 100 %). `cal_a` **1,781–2,215**, `cal_b` **0,930–1,154** con la banda
del juez **sin tocar**. Contra el **5/30** que QA midió antes de esta vuelta, con 2 de ellos en reposo.
`sonda-procesos.sh`: **0/30**, `cal_a=2,000` y `cal_b=1,000` **exactos en las 30**, y
`disc_obs = testigo = 3 ≠ disc_param = 4` en las 30.

**Y el desarrollador se desmiente a sí mismo, que es lo que hay que retener.** En la mitad de código
declaró `r` 3→5 como la palanca de `(d)`. **La medición lo niega:** con `r=3` la tasa es la misma **0/30**
en los cuatro regímenes. Lo que arregló la fragilidad fue el **tamaño derivado del suelo** —el insensible
de **1,4× a 4×**— y el **intercalado del par**, que además tapaba una falta de **identidad de camino** (la
calibración recorría `sr_minimo` mientras la medición de una razón recorre `sr_intercala`). Devolvió `r` a
**3** y **corrigió `tests/util/README.md`**, donde él mismo había escrito que `r` era «la palanca gratis
contra la fragilidad».

Y resultó decisivo: **`CA-08 (ii)` NO cabía con `r=5`** —**1,2825×** contra el techo de 1,25×— y **el techo
no se tocó**. Se aplicó la salida pre-decidida bajando `r`, **con `(d)` medido en 0/30 ANTES de bajarlo**,
que es su condición literal: **1,1734×**, cumple.

**El desglose que el criterio obligó a escribir antes de tocar nada dice algo que nadie había medido:** la
calibración sola cuesta **5,635–6,049 s** con `r=5` y **2,103–3,462 s** con `r=3`, así que **la corrida sin
calibración sale ≈0,98–1,00×**. *La mudanza en sí es neutra en reloj; todo el exceso es la calibración*, que
es capacidad que ninguna línea base tiene. Con una nota de método: **al coste de la calibración no le aplica
el mínimo de k**, porque su sujeto se **dimensiona por corrida** — el mínimo elegiría el sujeto más pequeño,
no la muestra menos ruidosa. Se publica rango.

**`(i.1)` — NO CONCLUYENTE, con rango, y sin afirmar el signo.** Resolución del oráculo **sobre la ventana
que mide**: en reposo y ventanas de 25 s observa **31–78 forks ajenos** (6 lecturas, **amplitud 47**); el
delta pareado sobre 7 pares es **+4 a +22**. `|delta| < 47` ⇒ **rango observado**, no concluyente, **y no se
afirma el signo** — la disciplina que costó retirar el `−56`. Y una observación que vale por sí sola: la
amplitud de las diferencias **pareadas** (18) es menor que la del suelo suelto (47), lo que indica que el
pareado cancela deriva ambiental, **pero atenuar no es medir**, así que no mejora el veredicto.

**`(i.2)` — cumple, con causa nombrada.** Sujeto idéntico **acreditado** (`cuenta=7` en los dos lados).
`sonda-reloj.sh` **7 → 3 (−4)**, idéntico en 6/6; `sonda-procesos.sh` **51–52 → 21 (−30/−31)**. La causa: la
línea base gastaba **un fork por binario** resolviendo con `type -P` dentro de `$( )` y **un `chmod` por
envoltorio**; el instrumento redirige el builtin y hace **un solo `chmod` para el lote**. El del reloj queda
bajo la amplitud del suelo, **así que lo sostiene la constancia 6/6 y el conteo estructural, no el oráculo**,
y se dice así.

**`(iii)` — cumple donde es medible**, techo 6×: reloj **2,921×** (5 corridas: 2,652–2,921×) y su mitad en
procesos **SKIP citando el motivo**, nunca el `0,000×` de un contador que nunca se incrementaba; procesos
**1,674×** y **3,714×** estable.

**`CA-07`, los tres puntos, con el recorte ACREDITADO en vez de afirmado.** (1) inventario idéntico byte a
byte, **828 casos / 61.287 bytes**, `cmp` sin diferencia — y `880−828 = 52`, `852−828 = 24`, **exactamente**
los casos que esas secciones producen. (2) **4 corridas de cada árbol**: 24 casos en cada una de las 8, los
24 deterministas, **0 cambian de veredicto, 0 desaparecen**, y la lista de excluidos —**derivada, no
afirmada**— sale **vacía**; con la precisión de que el caso de la pared dio **9 PASS / 2 SKIP en 11**, así
que su no-determinismo es real y medido y simplemente no se manifestó en el experimento pareado (`SEC-030`).
(3) `CASOS_ESPERADOS` **852 → 880 = +28 exactos**, y los de 37/1 y 37/2 **sin cambio** (13 y 11 en los dos
árboles).

### Un defecto que su propia mitad de código introdujo, y que cazó su propia medición

El materializador inline comprobaba `[ -d "$REPO/.git" ]`, y en un **`git worktree`** —y en un submódulo—
`.git` es un **archivo**. Con `-d`, las dos secciones 37 decían `sin-linea-base` y **se abstenían enteras**
dentro de un worktree mientras `git` resolvía el tag perfectamente: **«la copia haciendo la mitad del
trabajo», el caso exacto que `CA-05` existe para cerrar**, reintroducido por la guarda. Pasa a `-e`. Y el
código anterior a la mudanza **no tenía** esa guarda: la trajo la sonda que sale del alcance. Correr el banco
desde un worktree es lo normal cuando trabajan dos comisiones.

### Lo que NO cumple, dicho por él

**`(i.1)` no queda demostrada como valor** —el oráculo no resuelve la magnitud sobre su ventana, y recuperar
resolución exige acotar el conteo al subárbol de procesos, que no existe hoy—; **la banda de `(d)` tiene poca
holgura** (`cal_b=1,154` a **3,8 %** del techo con `r=5`, `cal_a=2,336` a **2,7 %** con `r=3`): *0/30 no es
0/300*; **la mitad en procesos de `(iii)` para el reloj no se mide**, y es un hueco porque `(iii)` es «el
único indicador medible de la identidad de camino»; el **`Archivos:` sigue declarando
`tests/util/sonda-linea-base.sh`**, que ya no existe —no lo tocó porque cambiar la frontera altera el mapa de
colisiones y es del analista, y declarar un archivo inexistente es **conservador** para el despacho, no
fail-open—; y **`CA-18` sigue rojo** (848 / 678 / 722).

**El hueco (b) medido una vez más, gratis:** con la sonda de reloj mutada, `rc=1` con 5 FAIL en la 38
mientras **las dos 37 publicaban `CA-03 fail-before 3,878×` y `CA-04 8,718×` como PASS** con la procedencia
de la calibración **desmentida en la misma corrida**.

**`REQ-017 CA-03` flaky, con tasa:** `3,878 / 3,791 / 2,508 / 3,316 / 3,890 / 3,901 / 3,916 / 4,057` contra
techo 2,600× — **1 de 8 no alcanza a demostrar**, y es la de la máquina cargada. REQ-017 está `completado`.

**Estado: banco `rc=0 · 876 PASS · 0 FAIL · 4 SKIP`**, cuadre 880 y por archivo OK, los 4 SKIP recapitulados
con su motivo. Autoprueba **72 PASS · 1 FAIL** (`CA-18`). Las tres gates de §7 verdes. Worktrees retirados,
`git worktree prune` hecho, **índice vacío** («lección aprendida», dice él). Write-back al Historial del REQ:
**una sola entrada, con las cifras, su corrida y su ventana de resolución**.

**Coste: ~503 k de contexto en total** (≈98 k en esta mitad).

## [GitHub] — 2026-09-08 · REQ-021 vuelta 2, mitad de código: la mitad discordante caza la tautología ejecutando, y la coordinadora comitea un borrado que no puso
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

**Comisión partida a propósito: código ahora, medición después.** Ninguna de las 30 calibraciones de
`CA-03 (d)` ni ninguna de las cuatro vías de `CA-08` se corrió — había otra comisión midiendo. Los
números de abajo son **verificación funcional**, no magnitudes publicables, y ninguno va al Historial.

### La mitad discordante, con fail-before/pass-after EJECUTADO

Es la pieza que decide la vuelta. Mutación sobre una copia (`ARNES_UTIL_DIR`), sin tocar el árbol: se le
**quita la observación** a la sonda de reloj. Los dos registros, **con el par en banda en los dos casos**
—que es exactamente la firma de la tautología—:

```
SIN MUTAR  cal_a=1956 cal_b=995   disc_param=185614 disc_obs=4150    disc_estado=suelo
MUTADA     cal_a=1919 cal_b=1010  disc_param=181159 disc_obs=181159  disc_estado=ok
```

Veredicto del juez real — **fail-before:** *«'reloj' publica `disc_estado=ok` sobre un sujeto que el juez
cronometró en 7077µs, por debajo del suelo de 50000µs: **quien no mide no puede saber que está bajo el
suelo**»*. **pass-after:** `PASS (disc_param=175361 · disc_obs=4267 · testigo del juez=7348)`. Y por
`CA-03` punto 5, con la sonda mutada la **corrida entera** sale `rc=1` con **5 FAIL**.

**Dos caminos distintos a propósito:** la magnitud publicada sale del registro de envoltorios y el
testigo lo **cuenta el juez** sobre un archivo que él crea vacío — contarlo sobre el mismo registro
haría que testigo y magnitud tuvieran **el mismo origen**, que es lo que `(a.3)` prohíbe. Y la
**anti-vacuidad se materializa como FAIL nombrado**, no como `ABORT:` del corredor: *un guardián que
tumba la vuelta por una condición de vacuidad* es la lección de `CA-07.4`, aprendida hace dos horas.

**No hay dos criterios contradiciéndose.** Rehecha la cuenta de `(iii)`: `1+2+1+1 = 5` más el discordante
—que por diseño cuesta **menos de una unidad**— **≤ 6**. Medido: reloj **2,7–3,3×**, procesos **3,7×**
contra 6. Cabe sin deformar nada, que es lo que la vuelta pasada se compró indebidamente.

**Las tres palancas de `(d)` usadas y declaradas, ninguna prohibida:** series **intercaladas** en la
calibración —y ahí apareció que **no había identidad de camino**: la calibración recorría `sr_minimo`
mientras la medición de una razón recorre `sr_intercala`, y es donde estaba la varianza (1,217 en bloque
vs 1,012 intercalado)—; `r` de 3 a 5, la palanca gratis; y margen sobre el suelo de **1,4× a 4×**,
derivado en la corrida. Con un efecto lateral medido: el sondeo va primero, así que **calienta** — el
`cal_a=1,093` que QA vio en frío era la primera serie pagando páginas dentro del numerador. **La banda no
se ensanchó y el sujeto no se encogió.**

Más: `QA-021-04` (parser sin word-splitting **ni glob**, clave repetida → ilegible), `QA-021-05` (barrido
por **marca de entorno**, que sobrevive a la reparentación **y** al cambio de sesión — verificado en las
tres formas, `vivos=1` y **0 supervivientes**, donde el grupo sólo cazaría dos), `QA-021-07`
(`procesos=no-aplica` en vez de contar con el oráculo del núcleo: `QA-021-03` ya obligó a retirar una
cifra por meter ruido de sistema en un campo publicado), `vivos` en el juez con sus tres ramas, y
`sonda_emisor_conocido()` fail-closed.

### Un hueco contrato↔código que NO resolvió, y bien hecho

**`37/1` y `37/2` no llaman a `sonda_usable` ni una vez** (`grep -c` → 0 y 0; en la 38, 14). Publican
razones leyendo el registro con `sonda_lee` directo. **Medido:** con la sonda de reloj mutada, la 38 sale
roja pero **`37/1` y `37/2` publican sus razones como PASS** con la procedencia de la calibración
**desmentida en la misma corrida**. `CA-03` punto 5 dice que esa medición **no es publicable**. Es la
misma clase que `QA-021-02`, un consumidor más arriba.

**No lo tocó**, y el motivo es el correcto: no está en sus diez puntos, cablearlo convierte PASS en FAIL
en casos de REQ-017 —superficie ajena— y *es exactamente la decisión unilateral que quemó la vuelta
pasada*. Queda para enrutar.

**Y una carrera del banco que sí arregló, porque era suya:** el caso `CA-04.4` contaba sobre el temporal
**compartido** que `37/2` usa con la misma sonda, así que veía directorios de **otra invocación viva** y
salía rojo sin que nada estuviera roto. *Es la clase de REQ-015 entrando por el lector.*

**`REQ-017 CA-03` fail-before es flaky, y no es suyo:** cuatro corridas del mismo árbol dan `3,878 ·
3,791 · 2,508 · 3,316` contra un techo de `2,600×` — **con la máquina cargada falla**. Misma clase que
`QA-021-06`, otro criterio y otro dueño. Verificó que su cambio no puede causarlo (modos idénticos).

### `CA-18` empeora, y ahora son tres archivos

| | antes | ahora | límite |
|---|---|---|---|
| `37-…-1-escala.sh` | 751 | **841** | 400 |
| `37-…-2-la-seccion-caliente.sh` | 614 | **674** | 400 |
| `38-sondas-compartidas.sh` | 400 | **722** | 400 |

Deshacer la mudanza devuelve líneas a las 37, y la 38 recibe el doble de casos. **No puede partir la 38**
porque un `39-*.sh` está fuera de su `Archivos:`.

**Banco: `rc=0 · 875 PASS · 0 FAIL · 5 SKIP`**, cuadre `880 = CASOS_ESPERADOS` y cuadre por archivo OK.
`CASOS_ESPERADOS` **873 → 880** y el de la 38 **21 → 28**, los dos **a mano**; los de las 37 **no
cambian**, como `CA-07.2` exige. Los cinco SKIP con su motivo en su línea. Autoprueba **72 PASS · 1
FAIL**, y ese FAIL es `CA-18`.

### Error de la coordinadora: comiteó un borrado que no puso

El commit `64e88c8` —el de **REQ-019**— contiene el borrado de `tests/util/sonda-linea-base.sh`, que está
declarado en el `Archivos:` de **REQ-021** y no en el de REQ-019. **No fue la comisión de REQ-019: fue la
coordinadora.** El `git rm` del `desarrollador` dejó el borrado **preparado en el índice**, y el commit
posterior lo arrastró.

**La lección, y es una clase nueva:** *nombrar rutas en `git add` **no acota** lo que el commit contiene.*
El índice es **estado compartido**, y una comisión viva puede dejar cosas preparadas ahí. La regla que la
coordinadora adoptó hoy —«con comisiones vivas, rutas nombradas, nunca `-A`»— **se cumplió y no bastó**.
Lo que hace falta es `git commit -- <rutas>` o **mirar el índice antes de comitear**. Va a `REQ-025`.

*(Coincidió con lo que la comisión de REQ-021 pedía, así que no se perdió trabajo de nadie — por suerte,
no por diseño.)*

**Coste:** ~405 k de contexto, **de los cuales ~84 k son leer `REQ-021.md` entero**. Es un dato para
REQ-019: el documento que contrata el ahorro cuesta 84 k por comisión que lo lea.

## [GitHub] — 2026-09-08 · REQ-025 (borrador): el arnés vigila también a quien orquesta — el par discriminante y el denominador publicado
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

REQ nuevo, ventana **1.34.0**, `Rigor: critico`, por decisión del propietario tras catalogar **20
errores de la sesión coordinadora** en una jornada. La coordinadora —que orquesta, **acredita, decide y
publica**— es el único actor sobre el que no apunta ninguna puerta de contenido.

**`CA-04`, el criterio central: el par discriminante con inventario auto-anclado.** Cada pregunta que la
herramienta declara tiene en el banco un caso positivo *y* uno negativo; el negativo se obtiene
**mutando el fixture positivo en la única propiedad que la comprobación dice vigilar**, y **tiene que
nombrar el defecto inyectado** — `rc≠0` no basta, porque una comprobación que **siempre** falla también
«pasaría» un negativo que sólo mire el `rc`.

Ataca **la propiedad, no las cinco instancias**: lo que las une no es el descuido, es que **ninguna se
probó con el caso malo**, y una comprobación que sólo se prueba con el caso bueno **no distingue**.
Enumerarlas habría sido el defecto atacándose a sí mismo. Y es **auto-anclado**: el inventario de pares
se **deriva del sitio único** donde la herramienta enumera sus preguntas, así que **añadir una
comprobación sin par rompe el banco nombrando la que falta** — aplicando la lección de `CA-05` de
REQ-017, que una comprobación contra línea base congelada mide una vez y luego envejece **hacia el lado
que abre**. **La cardinalidad no se fija**: los 20 y los 5 van como **operativos**, con corrida,
dirección hacia abajo y la frase de que **menos no acredita nada**.

**`CA-05`, y es la línea más barata del REQ: se publica el denominador.** El caso medido —«8» donde eran
**5 de 8**— es un veredicto **sin población**, y *un veredicto sin denominador no se puede desmentir
leyéndolo*. La misma línea habría delatado los **7 falsos positivos** de la comprobación de ids. **Una
línea, dos de las cinco instancias muertas.**

**El reparto máquina / acreditable / disciplina va DENTRO del REQ (`CA-01`), con lo que cada nivel NO
promete.** Máquina: par discriminante, denominador, marca de procedencia — **propiedades léxicas o de
inventario**, y por eso una puerta puede decidirlas. Acreditable: que la afirmación sea **cierta**, por
un tercero que repite o muta, nunca por quien la escribió. Disciplina declarada: la lista previa al
despacho y el juicio de qué comprobación hace falta, con dueño.

`CA-01` dice **literalmente** que **ninguna puerta de este REQ detecta «esta cifra no la mediste»** —es
semántica, y §13 ya declara ese techo—; lo que sí se detecta es la **ausencia** de procedencia, que es
otra cosa. Y la consecuencia incómoda queda escrita y no disfrazada de puerta: la comprobación posterior
de `CA-08` es **de máquina pero su ejecución es ritual** — *si nadie la corre, no protege*.

**El libro de comisiones sirve, pero no como está, y se midió antes de diseñar.** Hoy registra
**duración sin instante**, y una duración **no permite calcular solape**. Peor: el **único** solape
registrado de todo el corpus vive como **prosa libre en una celda de Notas**, así que depende de que
alguien se acuerde. `CA-10` añade **instante de inicio y de fin**, con lo que «¿algo mide ahora mismo?»
pasa de memoria a **aritmética** — y cubre de paso «¿hay comisiones vivas?», la que faltaba antes del
`git add -A`. Con la lección de la premisa falsa dentro: *un encargo que afirma el estado del árbol lo
**deriva**, no lo recuerda.*

**`CA-11` contrata que la acreditación NO sea de la coordinadora**, con cuatro condiciones que ninguna
puede satisfacer ella: QA verifica los pares **mutando él** el sujeto con sus propios fixtures
—re-ejecutar los del desarrollador no acredita—; la comprobación de `CA-08` la corre **quien no escribió
la entrada**; y el auditor revisa **expresamente** si alguna de las tres quedó satisfecha por una
afirmación suya. **Residual declarado:** el libro que `CA-10` usa **lo escribe la coordinadora**;
mitigación por **cotejo** contra artefactos ajenos, y lo que queda fuera —una entrada completa y falsa—
es semántica, con dueño `auditor-seguridad` y vencimiento al cierre de 1.34.0.

**Un agujero medido y NO absorbido, que va como pregunta abierta:** `requirements/` **no está en
`codigo_app.globs`**, así que `guard-codigo` no cubre esos archivos y **la sesión coordinadora puede
escribir `QA: aprobado` en un REQ** sin que ninguna puerta lo impida (y `veredictos.exigir_fecha` está en
`false`, así que no hay fecha que cotejar). Es la concentración en su forma más pura, y `CA-11` sólo la
cubre **por procedimiento**. No se absorbió porque **un mecanismo nuevo en un hook es gate humano**.

**`Archivos:` con dos decisiones dichas por su nombre:** `run.sh` va dentro **aunque las secciones se
descubran por glob**, porque `CASOS_ESPERADOS=873` es un literal de `run.sh:1173` y omitirlo habría
fabricado un **`disjunto` falso**; y `docs/arnes/*.md` va declarado **de más a propósito**, porque no se
sabe aún dónde aterrizan §6 y §8 tras el reparto de REQ-019 — *bajo incertidumbre se elige el error
barato (colisión falsa) sobre el caro*. Colisiona con REQ-019, REQ-021 y REQ-022; escribir `AGENTS.md` lo
manda **en solitario**, y va **después** de los tres.

**Estimación: 5–8 h.** Y el grueso **no es el script**: es **el par negativo por pregunta**, que es
exactamente lo que las cinco sondas de la línea base se ahorraron.

## [GitHub] — 2026-09-08 · REQ-019 se amplía al README y pasa a 1.34.0 — y la premisa de la coordinadora era falsa: ninguna máquina del arnés lee ese documento
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Dos decisiones del propietario:** `Versión destino: 1.34.0` **como primer trabajo de la ventana** —el
campo **no existía**, y era un defecto en sí: la palanca que justificó partir la ventana no declaraba en
qué ventana estaba— y **ampliación de alcance a `requirements/README.md`**.

### Corrección: la coordinadora afirmó que las puertas leen el README. Es falso, y está medido

`tools/arnes-paralelo.sh:288` y `tools/arnes-lectura.sh:119` lo **saltan explícitamente**
(`case "$base" in README.md|readme.md) continue ;;`), y las dos apariciones en
`hooks/guard-completado.sh` (líneas 519 y 524) están **dentro de cadenas de mensaje**. Las puertas no
leen ese documento: **implementan** el mismo contrato en su código y en `.arnes/config.json`. El README
es la **segunda transcripción**, la legible.

**La premisa era falsa en la letra y verdadera en la consecuencia, y la diferencia importa.** Perder
texto allí **no apaga ninguna puerta**; rompe dos cosas que **no salen en el banco**: (1) **el camino de
remedio** —`guard-completado` deniega y manda a una sección concreta; si el contenido se fue, la
denegación pierde su remedio—; y (2) **el marcador de versión** de `skills/arnes-upgrade/SKILL.md`
(líneas 119-125), que usa **tres frases y nombres de sección del README** para **desmentir** la versión
de origen: su ausencia no da error, da **DESMENTIDO → UNKNOWN → la migración para**.

**Y el hallazgo útil: esos dos acoplamientos cuestan ≈0 bytes extra**, porque caen **dentro** del suelo
que el contrato de forma ya obliga a conservar. El acoplamiento con la máquina no encarece el reparto —
**convierte un error de juicio en un fallo silencioso**. Por eso va contratado (`CA-02.4`, `CA-15.iii`) y
no dejado en la predicción.

### El suelo cae encima del techo, y no se tocó ningún umbral

Suelo inamovible: **≈233 de 433 líneas (54 %)**, y en bytes **≈58–64 %** —las filas del Índice pesan muy
por encima de la media—. **`CA-07 (ii)` pide ≤ 60 %: el suelo estimado cae encima del techo.** El
analista **no escribió ningún techo nuevo**: se aplicó `CA-15` a sí misma —*cardinalidad medida, nunca
fijada*— y dejó la medición previa obligatoria de §CA-14 con la salida por firma del propietario ya
cableada. **Ahorro real por movimiento: ≈11 000–13 000 B (36–42 %)** — no el doblado que la coordinadora
anunció.

**Y el bloque más caro queda fuera con su motivo:** el `## Índice` son ≈6 000 B, el **19 %** del archivo,
y es **una copia a mano de lo que `tools/arnes-lectura.sh` ya deriva** —el propio documento lo dice—. Eso
no es un movimiento, es un **mecanismo**: otro dueño y toca `codigo_app.globs`. *El 19 % más caro del
documento no lo baja este REQ, y quien lo baje no necesita repartir nada.*

### La forma (a) aplicada al propio REQ, y corregida

Se **de-nombraron doce criterios**: donde decían `AGENTS.md` ahora dicen «cada documento en alcance», con
§«Documentos en alcance» como **sede única del conjunto**. Ésa es la corrección de fondo: **el REQ tenía
criterios que enumeraban su propio sujeto**, y por eso ampliar el alcance obligó a reescribir doce.

Extensiones reales, no cosméticas: **`CA-02.4`** (sub-universo del README por propiedad, con tres sitios
únicos: anclas citadas por mensajes, marcadores de versión de la skill, y contrato de forma de los
campos); **`CA-04`** —la extracción de encabezados **ignora los bloques vallados**, porque la plantilla
del REQ vive dentro de un fence con líneas `## ` y un `^## ` ingenuo devuelve **siete encabezados
fantasma**, declarando siete secciones eliminadas sobre un reparto correcto—; **`CA-11`** de una vía a
**tres**, y la nueva es la probable: *el arreglo natural cuando un analista «ya no encuentra las reglas»
es añadir el archivo delegado a `agents/analista-requerimientos.md`; no rompe ningún puntero, cumple
`CA-01` y `CA-03`, y **anula `CA-07` sin dejar rastro***; **`CA-15`** gana el universo (iii) con el
argumento de por qué aquí es más necesario —el README **no tiene** `🔒` ni tabla de §13, así que `CA-15`
no es un cinturón sobre `CA-02`: **es la única enumeración que existe**—.

### `CA-16` estaba escrito por ARCHIVO, y su justificación era falsa para el segundo sujeto

El `Entonces` era por propiedad, pero **el `Dado` nombraba `AGENTS.md`** y su justificación entera
también. Al reformularlo apareció que la premisa *«casi ninguna comisión lo escribe»* es cierta de
`AGENTS.md` y **falsa del README**: su `## Índice` lo actualiza **cada** comisión de analista. Se corrigió
en vez de borrarse — para el README la herramienta **sí** ve buena parte del riesgo; lo que sigue sin ver
son las comisiones de `desarrollador`, `qa-tester` y `auditor-seguridad`, que leen el documento entero y
**no lo declaran nunca**. *Un criterio cuya justificación es falsa para uno de sus dos sujetos es clase
`contrato` aunque su `Entonces` sea correcto.*

### `ADR-006`, decidido con el test que el propio REQ ya tenía escrito

El REQ dice que `CA-15` y `CA-16` no abren ADR «porque ninguno cambia el alcance ni la decisión base».
**Éste cambia el alcance**: un documento → dos, una plantilla divergente → dos. Cambio **DE FONDO** →
**`ADR-006`**, que **extiende y no supersede** a `ADR-003`, cuyos cuatro motivos se comprobaron **uno por
uno** contra el segundo documento y **aguantan todos**. Registra lo que `ADR-003` no podía pesar: el
**quinto motivo de migración** (adelgazar la plantilla del README obliga a **re-derivar y re-fechar** los
marcadores de `arnes-upgrade`); que en el par del README **la divergencia se crea entera en vez de
ampliarse** —los **18 encabezados coinciden uno a uno y en los mismos números de línea hasta la 350**,
desfase total **6 líneas** frente a **113** en `AGENTS.md`—; y que el 19 % del Índice queda fuera a
propósito.

**Estimación nueva: 7–11 h, cuatro fases, ≥5 comisiones.** Con tres notas de orquestación: las dos
enumeraciones de F1 **pueden ir en paralelo y salen mejor así** (`CA-15.2` exige no verse) pero **cada una
escribe su propio artefacto** o se pierde una por escritura perdida; F2 y F3 son **un solo cambio** para
`CA-05` y `CA-07`; y **F1 no necesita solitario**, que es lo que permite descubrir un techo insatisfacible
**sin haber parado a nadie**.

**`Archivos:` nuevo** con `+ requirements/README.md` y `docs/qa/1.33.0.md` → `docs/qa/1.34.0.md` —
retirado a propósito: el REQ ya no escribe en esa ventana y dejarlo pondría en serie, **sin motivo**, a
REQ-020 y al resto de 1.33.0.

## [GitHub] — 2026-09-08 · R-013: confirmado el bypass del campo comentado, y aparece uno peor — se pierde el gate humano escribiendo BIEN la aprobación
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `auditor-seguridad`.

**Investigación del guardián publicado, no auditoría de ningún REQ.** No se firmó nada. Medido
ejecutando el entrypoint real (`hooks/guard.sh`) con JSON de `PreToolUse`, control positivo y negativo en
cada tanda, fixtures fuera del repositorio. **23 filas con veredicto idéntico en la instalada 1.32.1 y en
la candidata** —`guard-completado.sh`, `campos-req.awk`, `guard.sh` y `hooks.json` byte a byte iguales;
`lib.sh` difiere en **una** línea—: **nada que atribuir a 1.33.0**.

**Confirmada la hipótesis que el analista de REQ-023 dejó sin ejecutar:** un `<!-- Sensible a seguridad:
sí -->` junto a `Rigor: ligero` **cierra a `completado` un REQ con `QA: pendiente` y `Seguridad:
pendiente` escritos a la vista**, en silencio total — ni deny, ni `systemMessage`, ni aviso de
vocabulario. Dos variantes nuevas: `<!-- Rigor: critico -->` y `<!-- QA: pendiente -->`.

**Pero la hipótesis en sí NO es defecto nuevo**, y el auditor lo probó con un control de equivalencia
—comentar y borrar dan el **mismo** ALLOW—: es `REQ-016 CA-11` funcionando como se contrató, más la
decisión que él firmó en `R-009`. **No abrió `SEC` para ella.** Alcance, sin exagerarlo: ese `ligero` no
salta la clase del hallazgo, ni las quality gates, ni la cola.

**La clase, contratable:** *un campo de la cabecera cuya **ausencia** la puerta resuelve del lado que
**abre** queda satisfecho haciendo desaparecer su línea, **por cualquier vía** —carácter invisible, rango
de comentario, borrado—; la vía no cambia el veredicto, porque la puerta no mide la vía, mide la
ausencia.* Se cumple en **cuatro** de los seis campos; la única que cierra es `Seguridad:` en `critico`.

### `SEC-050` — `contrato`, alta

Tres cosas que **ningún documento dice**: (1) la superficie son **cuatro** campos y los tres textos que
la describen nombran **dos** —incluida **la propia remediación de `SEC-047` del auditor**, que se aplica
a sí mismo la prohibición de enumerar—; (2) **el puntero «un solo sitio» de `CA-11` es falso para el
campo que más pesa**: manda a `guard-completado.sh` y la regla del suelo de rigor vive en `hooks/lib.sh`,
así que quien audite siguiendo el contrato concluirá que el suelo está a salvo; (3) la variante `<!--
Rigor: critico -->` **desmiente una promesa sin condición** de §6/§13 — aquí lo tapa la política de
autoalojamiento, **en los proyectos consumidores no**.

### `SEC-051` — `instrumento`, alta, independiente, y peor

`arnes_cola_pendientes` (`hooks/lib.sh:1161-1162`) descarta la **línea completa** que contenga `<!--` o
`-->` **en cualquier posición**, con un `continue` **incondicional**:

| Entrada bajo `## Pendientes` | cola | Puerta |
|---|---|---|
| `### Fusionar el PR a main` — control | **1** | **DENY** |
| `### Fusionar el PR a main <!-- pedido a Juan el 8/9 -->` | **0** | **ALLOW** |
| `### Migrar A --> B` — **sin comentario ninguno** | **0** | **ALLOW** |
| `<!-- Nota` sin cerrar + 2 entradas reales detrás | **0**, `rc=0` | **ALLOW** |

**Se pierde el gate humano sin acto deliberado: escribiendo BIEN la aprobación.** Y los **tres** canales
de observabilidad coinciden en el número equivocado —`arnes-lectura.sh` añade «*Ningún valor anómalo*»—:
la propiedad de «una sola regla» de `REQ-009` **se cumple y propaga el error**. *Consistencia no es
corrección.* La asimetría que prueba que es defecto y no decisión: **en la cabecera un rango sin cerrar
DENIEGA; en la cola cuenta cero en silencio.**

**Latente:** barridos **133 blobs únicos** de `requirements/*.md` (136 commits, 24 rutas) y los **4** de
`PENDING_APPROVAL.md`, con control positivo del barrido: **cero comentarios en cabecera**, ningún cierre
pasado contaminado.

**`SEC-045` y la custodia no cambian, y el motivo es bueno:** `SEC-051` existe porque al banco le **falta
un caso**, y **custodia y completitud son ortogonales** — un guardián sobre `secciones/` habría impedido
*debilitar* un caso, no *escribir* el que nunca existió. Es evidencia **a favor** del alcance estrecho
que eligió el propietario.

**Inventario verificado `SEC-001`…`SEC-051`, monótono y sin huecos.**

## [GitHub] — 2026-09-08 · Write-back de R-010 en REQ-019: el criterio de inventario de invariantes NO existía, y el universo lo cerraba quien se beneficiaba de dejarlo corto
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Cierran `SEC-031`, `SEC-032` y `SEC-034`**, verificados remediación por remediación contra el texto del
REQ. **`SEC-033` NO cierra**, y el motivo está medido y no supuesto: su remediación 3 es una edición de
`ADR-003`, cuyo dueño es el `desarrollador`, y ese archivo conserva hoy la formulación de **una sola
dirección** (línea 60), el «**CA-05 lo detectará el día que ocurra**» (línea 68) y el rango cerrado
«criterios **CA-01 a CA-13**» (línea 122). Mientras el ADR diga eso, la mitad de la ubicación del
hallazgo sigue diciendo algo falso. `Hallazgos abiertos:` pasa de cuatro a **`SEC-033 (contrato)`**.

### `CA-15` — el criterio de inventario de invariantes no existía, y el hueco tenía forma precisa

`CA-01` **inventariaba texto, no invariantes**. `CA-02` sí enumera, pero **su universo son dos
marcadores** (las filas de §13 y los bloques `🔒`), así que una obligación en prosa fuera de ellos —el
tope de vueltas de §6, «secretos sólo en variables de entorno» de §10, las reglas del CHANGELOG de §8—
**no pertenecía a ningún conjunto enumerado**. Y la tabla de `CA-13` tiene una fila por bloque
**retirado**, así que una invariante que **se queda** no aparece nunca en ella.

La propiedad entera se sostenía sobre los señalamientos de `CA-14` en **un universo que nadie cerraba
antes del reparto** — y lo cerraba, **mientras repartía**, el agente al que le abarataba dejarlo corto.
Es `SEC-032` aplicado a la propiedad entera: `CA-13` puso terceros ojos en las **preguntas**, no en el
**universo**.

`CA-15` contrata: inventario **cerrado y publicado antes de mover un byte**, sitio único anexo a
`ADR-003`, universo **por propiedad**, **no menos de 2 enumeraciones independientes y sin verse**
—una puede ser de quien reparte, la otra no—, universo por **unión** con reconciliación escrita, **un
señalamiento por elemento** (`no más de 0 sin señalar`, de contrato), **trinquete** (crece libre;
decrecer exige Historial y visto bueno del enumerador independiente), y borde que **no aprueba** si no se
puede producir o cuadrar. **Cardinalidad medida, nunca fijada** — fijarla habría sido la forma (b).

Con dos cosas escritas por lo aprendido hoy: el universo **se re-deriva en la misma edición** que cambie
`CA-14`, `CA-01` o `CA-02`; y **se declara la clase de la comprobación** —acreditación única, no puerta—
porque no declararla es literalmente el defecto que `SEC-033` acaba de medir en `CA-05`.

### `CA-16` — el riesgo del sustrato de lectura no estaba contratado

El REQ sólo contrataba serie respecto de quien **escribe** `AGENTS.md`, que es lo que
`tools/arnes-paralelo.sh` mide. **El riesgo es de quien LEE.** Ahora: cero comisiones ajenas solapadas
durante el reparto (de contrato), acreditado por el libro de comisiones de `docs/qa/1.33.0.md`, con borde
que no aprueba si el libro no registra la ventana. **Escrito como propiedad y no como instrucción de
despacho**, por la misma razón que el REQ ya usa con `SEC-030`: *un orden vive en la cabeza de quien
despacha*.

Más: **`CA-05` punto 6** — la corrección contratada del rango «CA-01 a CA-13» **no es actualizarlo**, es
**retirarlo** y citar el REQ como sitio único: mata la clase, no la instancia. Y en `CA-14`, el
**suelo forzado se mide antes de repartir**: si ya excede el techo de `0,60×`, es insatisfacible por
construcción y se sabe a coste de **una medición**, no de una vuelta sobre el reparto entero. *(El
`0,60×` de `CA-07` no se derivó del suelo que `CA-02` obliga a conservar — la misma trampa que hoy costó
dos vueltas en REQ-021. No se tocó: subirlo exige firma del propietario.)*

**Sin ADR nuevo, con motivo:** ni `CA-15` ni `CA-16` cambian el alcance ni la decisión base de `ADR-003`.
**Y sin NFR nuevo**, también con motivo: los cuatro hallazgos son defectos de **formulación de criterio**,
no umbrales de sistema, y el único NFR cuantificable ya vive en `CA-07` — inventar uno habría creado una
**segunda sede del mismo umbral**.

**Una cifra que el analista se NEGÓ a escribir:** el «cinco veces» que la coordinadora le pasó en el
encargo. No pudo verificarlo, y las cuatro citas del registro (`SEC-015`, `023`, `025`, `030`) son de
**otra clase** —la acotación que envejece, no la acreditación por lectura—. `CA-15` enuncia la propiedad
**sin número**. Es la tercera cifra sin respaldo que un agente devuelve a la coordinadora hoy.

### Y la observación que más incomoda

**El REQ que existe para retirar el impuesto fijo es hoy uno de los documentos más caros del
repositorio.** La entrada obligatoria del desarrollador antes de su primera acción: `AGENTS.md` (~9 k,
medido) + REQ-019 —que **acaba de crecer un ~26 %** y ronda 14–16 k— + `requirements/README.md` (~7 k) +
`ADR-003` (~4 k) ≈ **33–36 k sólo para arrancar**, y los paga enteros.

**Estimación nueva: 500 k – 900 k tokens y 3–5 h de reloj, y NO cabe en una sola comisión** con fidelidad
verbatim —agotar el contexto a mitad del reparto deja `AGENTS.md` inconsistente, y lo lee todo el mundo—.
Reparto propuesto en cinco fases, con tres avisos: **`CA-15` obliga a una comisión de analista NUEVA
antes del desarrollador** (el precio de la independencia del universo, dicho en vez de disimulado);
**`CA-16` detiene la ventana durante dos de las fases**, y ese reloj entra íntegro en la ruta crítica; y
**`CA-06` tiene una tensión de rol** —el write-back de REQ ajenos es trabajo de analista por §5/§9, no de
desarrollador— cuyo endurecimiento es **decisión del propietario**, porque reduce lo delegable y con ello
el ahorro.

## [GitHub] — 2026-09-08 · REQ-021 reduce alcance: sale `sonda-linea-base.sh`, y lo que la reducción deja descubierto se escribe sin endulzar
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Decisión del propietario:** `sonda-linea-base.sh` **sale del alcance**; sólo se mudan a `tests/util/`
la sonda de reloj y la de procesos. **Es la cláusula que el contrato ya tenía pre-decidida** —*«si (i.1)
o (ii) no caben, no se sube el techo, se reduce el alcance»*—, así que ejercerla es **cumplir** el
contrato, no cambiarlo. Y esa sonda era la causa de los tres problemas más duros **a la vez**: la
calibración tautológica de `QA-021-01`, los 21 procesos que hicieron insatisfacible `CA-08 (i)` y el `+6`
de `(i.2)` con los internos de `git`.

**Sin ADR nuevo, y con la condición que lo desmentiría escrita**, para que no sea coartada reutilizable:
*si `ADR-005` ya existiera, esto sería ADR nuevo, sin discusión.* Los tres motivos: no hay a qué suceder
—un ADR que supersede a un archivo que nadie ha escrito es contabilidad, no registro—; las dos
decisiones base no cambian; y la salida estaba escrita **antes** de medir. `ADR-005` amplía mandato con
`(i)`…`(l)`, incluido **lo que la reducción deja descubierto**, porque *un ADR que registra una reducción
sin su residual documenta un alivio, no una decisión*.

**Reparto de criterios, y dos que se salvaron por poco:**

- **`CA-05` se queda**, gobernando la versión inline, con el sujeto reescrito: «el **materializador de
  línea base**, **donde viva**». **El criterio se enuncia sobre la función, no sobre un archivo**, así
  que la reducción no lo deroga. Hereda formato y parser único; **no** hereda `CA-03` ni `CA-09`. Y
  resuelve `DEV-021-08` dentro: el bit pasa a ser **el modo del objeto en el árbol**.
- **`CA-08 (0)` se queda y se refuerza**, dicho por su nombre **porque era lo más fácil de perder**:
  exige una **propiedad del resultado**, no un instrumento. **`H-08` sigue cerrado en el criterio.**
- **`CA-07` punto 4: la materialización SALE del guardián de segunda sede.** Sin eso, la reducción deja
  el banco **abortando la vuelta entera** sobre `mat37`/`mat47` —medido: hoy los **acusa** como control
  positivo—. *Un guardián que acusa la única sede que hay es la forma (a) al revés.*
- **`CA-10` punto 2** corregido: `vivos` obligatorio **en el registro de un instrumento de
  `tests/util/`**, enunciado sobre **el emisor** y no sobre el formato — exigir un campo a quien no puede
  observarlo es un **FAIL garantizado**, la clase de criterio insatisfacible que este REQ ya pagó dos
  veces.
- **`CA-03` entera, sin una coma menos**, aplicada a las dos sondas: **la tautología es una clase, no un
  defecto de esa sonda**. Con la observación de por qué era estructuralmente posible justo ahí: en las
  dos que quedan la magnitud observada **ya es una medición**; la que sale era la única cuyo número **es
  un recuento de cosas que el llamante eligió**.

### `AN-021-01` — lo que la reducción deja descubierto, sin endulzar

`instrumento`, dueños `desarrollador` + `analista-requerimientos`, ventana **1.34.0**. Cuatro cosas:
(1) el materializador queda **sin calibración de ninguna clase** —mejora porque una tautología es un
verde falso, empeora porque **nada acredita que responda al sujeto**—; (2) `mat37` y `mat47` siguen
siendo **dos copias literales** y la duplicación era **uno de los forzadores del REQ**; (3) la clase
«línea base a medias» queda sin instrumento compartido, así que parte del forzador de ~150 k/ventana
**no se cierra**; (4) **si algún día se muda, vuelve con su tautología intacta**, y quien la mude paga
primero ese write-back.

### `QA-021-01` cierra, y el efecto real se dice sin adornos

Cierra porque su segundo motivo desapareció —el propietario decidió **custodiar**— y porque **la
instancia concreta sale del árbol con la sonda**. Pero: *el campo queda sin ningún hallazgo bloqueante
por clase, y **la puerta sigue cerrada igual** — `QA: con-hallazgos` y `Seguridad: preventiva` sobre un
`Rigor: critico` la cierran. Cerrarlo no adelanta nada; sólo deja de mentir sobre por qué está cerrada.*
También cierra **`DEV-021-08`**.

**Residual: de tres instrumentos a dos, y MÁS motivado.** Vence **antes de `completado`**, ahora con dos
razones: un forzador ya ejercido y fallado no se vuelve a aplazar, y **hasta 1.34.0 no hay custodio**, así
que en esta ventana el sustituto **es la única capa**. Queda escrito lo medido a favor —el `qa-tester`
mutó los dos que quedan y el juez cazó las dos; el instrumento que reventó el sustituto **es exactamente
el que se va**— y por qué **no** descarga el residual: *dos mutaciones que aciertan no acreditan la
propiedad*, que es la forma (a) a nuestro favor, y es cuando más tienta darla por buena.

**Estimación nueva: ≈150–250 k tokens y 1,5–2,5 h** (antes 250–400 k / 2–3 h), y **entra en una vuelta**.
El riesgo está en dos sitios, los dos nombrados, y con una buena noticia de método: **la escalera de
salida de `CA-03 (d)` está escrita y ordenada** —subir `r` → subir el margen sobre el suelo → cambiar el
sujeto → sacarla de la puerta—, y **las tres primeras el desarrollador las aplica sin pasar por el
analista**, así que `(d)` fallando **no cuesta una vuelta**. `r` es la palanca gratis: **`(iii)` es
invariante a `r`**.

## [GitHub] — 2026-09-08 · Write-back de la QA de REQ-021: el techo estaba mal derivado y el desarrollador compró el encaje deformando el sujeto
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**`CA-03` gana la propiedad que faltaba, y con su mordida.** (a.1) **procedencia observada**: cada
entrada del factor es una magnitud que la sonda **observa después de ejercer el sujeto**, y **un factor
que se pueda calcular sin ejercer el sujeto INCUMPLE**. (a.2) la **mitad discordante**, que es lo que lo
hace exigible: la procedencia **no se lee en el registro** —la sonda honesta y la tautológica publican el
mismo número—, así que la calibración ejerce una entrada cuya magnitud observada **difiere del
parámetro** y que el juez conoce **sin la sonda**, y contrasta la **magnitud publicada** contra un
**testigo propio**. (a.3) anti-vacuidad: aborta si el testigo coincide con el parámetro o si **lo produce
la propia sonda**, y la copia sin mutar tiene que pasar donde la mutada falla.

**La tensión `CA-03` ↔ `CA-08 (iii)` se rompió por el techo, y la causa raíz es peor que el síntoma.** El
`4` decía derivarse de «lo que CA-03 contrata — cuatro ejercicios del sujeto», contando cuatro ejercicios
**iguales** cuando uno cuesta **el doble por construcción**: la suma del mismo contrato es `1+2+1+1 = 5`,
y con la mitad discordante **6**. **El desarrollador hizo esa cuenta, vio que `5 > 4`, y en vez de
escalar la contradicción compró el encaje deformando el sujeto** —insensible a `N/4` ≈ 72 ms, **1,4× el
suelo**, donde domina el planificador—. De ahí los 5 de 30 fuera de banda.

`(iii)` pasa de **4× a 6×** con la suma **término a término** escrita, y dos reglas nuevas: *un techo
derivado de otro criterio se **re-deriva en la misma edición** que cambia ese criterio* —misma clase que
`DEV-021-05`, que pasa a tener **dos** instancias medidas— y *el techo **no se compra deformando el
sujeto***.

Más: **`CA-03 (c)`** deriva el tamaño de cada mitad **del suelo medido en la corrida** y un env sólo
puede **subirlo** —lo que cierra también el «máquina más rápida → `suelo` → banco rojo»—; y **`CA-03
(d)`** exige **0** veredictos fuera de banda en **≥ 30** corridas y ≥ 2 regímenes, con el motivo dentro
del criterio: *5 de cada 30 no es estricto, es inservible, porque el primer rojo espurio enseña a
re-correr el CI*. **No se ensanchó la banda** ni se sacó la calibración de la corrida, y la salida
pre-decidida queda ordenada, con un hallazgo útil de paso: **`(iii)` es invariante a `r`**, porque
numerador y denominador llevan los mismos mandos.

### El residual: la frase no se borra, se marca DESMENTIDA

«Una sonda alterada no da verde» queda **citada y marcada `DESMENTIDA EJECUTANDO el 2026-09-08`** con su
evidencia, en tres sitios del REQ. **Residual nuevo**, porque un forzador ya ejercido y fallado no se
vuelve a aplazar: re-acreditación **sobre los tres instrumentos**, por mutación **de quien no escribió
la sonda**, con **vencimiento antes de que el REQ pase a `completado`**. Y la lección estructural: *quien
escribe el instrumento muta lo que se imagina* — el autor acreditó **1 de 3** y tituló «demostrado en vez
de prometido»; el tercero rompió otro **a la primera**.

**Corregido además un párrafo que habría nacido falso:** el REQ mandaba a `ADR-005` registrar «la
decisión de no proteger con su sustituto». Escrito así, **el ADR nacería afirmando un argumento medido
falso**. `ADR-005` amplía mandato con el desmentido, la procedencia observada, que una acreditación del
autor sobre 1 de 3 instrumentos no acredita el mecanismo, y el techo que se re-deriva.

### Decisión del propietario, y coincide con la recomendación del analista

**`tests/util/*` entra en `codigo_app.globs`; `tests/` entero, NO.** El motivo que lo desbloquea no
estaba en R-012: **la mutación de un tercero no necesita escribir la ruta protegida** —QA la hizo sobre
una **copia fuera del árbol**, y `guard-codigo` deniega ediciones del glob, no copias—, y las
**secciones** que escribe el `qa-tester` quedan fuera del glob. Así que custodiar los instrumentos **no
le quita oficio al QA**, que era la objeción. Lo que **no** se hace, y queda nombrado sin recomendar:
custodiar **el examen** exigiría alcanzar `run.sh`, y eso sí se lo quitaría. Ventana **1.34.0**: la cola
humana decide **cuándo**, no **si**.

Y una consecuencia honesta que estaba prometida y era falsa: sacar la expectativa al juez **no crea un
custodio**, porque `run.sh` tampoco está en `codigo_app.globs`. Sube el coste del descuido; nada más.

### Qué cierra

`QA-021-02`, `QA-021-03` y `DEV-021-11` **cerrados** — este último porque `CA-07.2` pasa de **igualdad** a
**techo con dirección** (`SKIP → PASS` es conforme **por nombre**), con identidad sólo sobre casos
**deterministas** y el conjunto de excluidos **derivado de ≥4 corridas y publicado**. `DEV-021-10`
**cerrado por absorción** en `QA-021-06`.

**`QA-021-01` sigue ABIERTO y sigue `contrato`, a propósito.** La mitad del analista está hecha, pero
cerrarlo dejaría pasar el REQ apoyado en un criterio **que nadie ha implementado** y con la decisión de
gobernanza vigente **por silencio**. Fail-closed deliberado: `guard-completado` deniega el cierre, y eso
es lo correcto.

## [GitHub] — 2026-09-08 · QA de REQ-021: `con-hallazgos`, y DOS cifras que esta bitácora publicó como medidas se RETIRAN
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**Veredicto `QA: con-hallazgos`, vuelta 0 de 3.** Nueve hallazgos nuevos, **tres `contrato`**. Tres
criterios FALLAN (`CA-01`, `CA-04`, `CA-06`, `CA-10`), uno es **FLAKY** (`CA-03`) y `CA-08` sale **no
concluyente** en tres de sus cuatro mitades. Banco **870/0/3, rc 0, 49,5 s**; las tres quality gates de
§7 en verde.

### Retractación 1 — «los factores salieron EXACTOS» era la firma de una tautología, no de un sujeto bueno

La entrada de esta bitácora del 2026-09-07 sobre la implementación de REQ-021 dice que en la sonda de
procesos y la de línea base «los factores salieron **exactos** (2,000 y 1,000) en todas las corridas», y
lo presenta como evidencia de un sujeto de calibración **bueno**. **Es lo contrario, y está medido**
(`QA-021-01`, `contrato`):

Una `sonda-linea-base.sh` **mutada, que no materializa ni verifica nada**, publica `cal_a=2000
cal_b=1000` y **el juez real dice `PASS`**, con el mismo texto que la original. El factor sale de
`SLB_ARCHIVOS_EJ`, que en la mitad sensible **es el parámetro**: `2N/N = 2000` **por aritmética**, haga
la sonda algo o nada. **Un número que no puede salir mal no está midiendo nada**, y una exactitud
perfecta en un instrumento sujeto a ruido debió leerse como sospecha, no como calidad.

**Y lo que eso desmiente no es un criterio, es una decisión de gobernanza.** El sustituto con el que se
justificó **no poner `tests/` en `codigo_app.globs`** —«acreditar la medida en vez de custodiar el
instrumento», `ADR-005`, residual `SEC-045` del auditor— descansa en que *una sonda alterada no da
verde*. Se ejerció su forzador **antes de su vencimiento** y **no aguantó**.

### Retractación 2 — el `−56` de CA-08 (i.1) no es una medición: cabe dentro del ruido

La misma entrada publica **«(i.1) −56 procesos añadidos»** con su operación al lado. `QA-021-03`
(`contrato`) mide que **el suelo del oráculo se calibró mal**: se declaró **0 forks (12/12)** tomando dos
lecturas **seguidas** de `/proc/stat`, y se aplicó a ventanas de **~50 s**, donde el suelo en reposo es
**184 · 225 · 246 · 247** forks. Con una amplitud de ruido de ~63, un delta de 56 **no se distingue de
cero**: por `CA-06.5` corresponde **rango observado**, nunca un valor.

**La calibración del oráculo midió la magnitud correcta sobre la ventana equivocada.** Es la forma (d), y
van tres hoy.

### Los otros hallazgos

- **`QA-021-02` (`contrato`)** — `CA-04` habla del «`vivos=<n>` publicado **que el juez lee por CA-10**»,
  y `sonda_usable` **no lo lee**. Su único lector es el caso dedicado de la sección 38.
- **`QA-021-04`** (alta) — la puerta de `CA-10` se evade por espacio, por **expansión de glob desde el
  `cwd`** y por clave repetida.
- **`QA-021-05`** (alta) — un descendiente **reparentado** sobrevive con `vivos=0 estado=ok`. Tres formas,
  una con `ppid=850`.
- **`QA-021-06`** (alta) — **`CA-03` es flaky**: `cal_a` **1,093–2,444** y `cal_b` **0,757–1,385** en 30
  corridas, **5 fuera de banda y 2 de ellas en reposo**. Y cada fallo **pone en rojo la puerta requerida
  de `main`** — verificado end-to-end: 3 FAIL, rc 1. **No se ensanchó la banda**: por `CA-03 (a)` vuelve
  como «se cambia el sujeto». Causa de fondo: el insensible se fijó a `N/4` **para caber en `CA-08
  (iii)`** — dos criterios del mismo REQ en tensión.
- **`QA-021-07`** (media) — **`SR_PROCS` nunca se incrementa**, así que el `procesos=` de la sonda de
  reloj es siempre 0: **121 forks reales** contra `procesos=0`. Y `CA-08 (iii)` en procesos es **0/0
  presentado como `0.000×`**.
- **`QA-021-08`**, **`QA-021-09`** (bajas).

### Dos reclasificaciones de los hallazgos del desarrollador

- **`DEV-021-11` pasa de `instrumento` a `contrato`.** `CA-07.2` dice «ningún caso **cambia de
  veredicto**» **sin condición**, y uno cambió (medido: `37/1` pasó de `12 PASS·1 SKIP` a `13 PASS·0
  SKIP`). Un criterio insatisfacible por construcción es exactamente la forma por la que
  `DEV-021-01`…`04` fueron `contrato`. Y además describe sólo `PASS→SKIP` cuando lo ocurrido fue
  `SKIP→PASS`.
- **`DEV-021-10`**: clase correcta, **magnitud subestimada** y dueño equivocado. Lo absorbe `QA-021-06`.

`DEV-021-05`, `07`, `08` y `09` **bien clasificados**, y el `09` **confirmado ejecutando**: con
`ARNES_SONDA_PLAZO=2`, un `--sujeto 'sleep 30'` deja la sonda viva a los 12 s.

### Lo que sí quedó acreditado

`CA-07.1`: **828 líneas idénticas byte a byte** contra un **worktree** de `794fa4c`, `diff` vacío.
`CA-02`, `CA-05` y `CA-09` **pasan**. Los **3 SKIP** del banco son **todos por diseño** y ninguno por
avería: uno de plataforma (`cygpath`/Windows) y dos de `REQ-017 CA-05` con la palanca
`ARNES_COSTE_RUTA_CRITICA` apagada, con el motivo en la propia línea. **`DEV-021-07` es el único rojo**
(`grep -c '^ABORT'` = 0 en las dos corridas).

**Dato incómodo:** la sección 38 mide **exactamente 400 líneas**, justo en el límite de `CA-18`.

**Y una advertencia del propio QA sobre el método de la coordinadora:** el árbol se movió a mitad de su
comisión (`3511929` → `721cb71`, el borrador de REQ-023). Comprobó que ese commit sólo toca `CHANGELOG.md`
y `requirements/REQ-023.md` y que esa comisión **no mide**, así que sus números siguen válidos — **pero
si hubiera medido, se habrían invalidado en silencio**. Es la segunda dimensión de la colisión de
despacho (la máquina) y esta vez salió gratis por suerte, no por diseño.

**Coste:** ~190 k tokens.

## [GitHub] — 2026-09-08 · REQ-023 (borrador): el carácter invisible, enunciado por ESTADO y con un criterio redactado para que una lista de prohibidos lo incumpla
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**REQ nuevo para `SEC-047`**, por decisión del propietario de meterlo en 1.33.0. `Rigor: critico`,
`Sensible a seguridad: sí`, `Estado: borrador`.

**El criterio central se enuncia por estado, no por carácter.** `CA-01`: *si la cabecera declara un
campo en letra y el lector no lo resuelve como ese campo, la cabecera no se puede medir → DENY citando
la línea y el carácter en forma imprimible, y nunca allow por ausencia del campo que ese carácter
borró.* Con `CA-02` encima: la denegación es **por medibilidad y no por veredicto** —un REQ con todo en
verde deniega igual— y **resolverlo como ausencia incumple**, porque la ausencia es justo lo que la
puerta perdona.

**Y la pieza que impide que esto sea la sexta derrota de «ensanchar la lista» es `CA-03`:** el banco
ejerce tres familias declaradas **más una entrada reservada extraída al azar en cada corrida** del
complemento, publicada con su semilla. Está redactado **explícitamente para que una implementación por
lista de prohibidos lo incumpla**. Así la propiedad «envejece hacia el lado que cierra» queda contratada
de forma **observable**, sin dictar el código.

**Dos criterios que `SEC-047` no pedía, con motivo medido cada uno:**

- **`CA-05`, invariancia de locale.** La vía obvia para un conjunto positivo (`[:print:]`, `[A-Za-z]`)
  está **sujeta a colación**, y `hooks/lib.sh` ya explica por qué sus tablas se escriben con escapes de
  bytes. Una clasificación dependiente de `LC_CTYPE` **deniega en el CI de Linux y permite en
  Windows/MSYS** — que es justo de donde sale el BOM. Fail-open por entorno, invisible en la puerta
  requerida.
- **`CA-09 (iii)`, cociente de duplicación ≤ 2,2.** La forma natural de «comprobar cada carácter» en
  bash es un bucle con `${l:i:1}`, **cuadrático por construcción**: exactamente la regresión de 10× que
  REQ-017 acaba de pagar y que el `CA-08` de REQ-016 no vio **por medir la magnitud equivocada**. Las
  tres vías —forks, reloj y orden de crecimiento— van en **un solo criterio y una sola corrida**.

**`CA-04` es la mitad que decide si el arreglo sirve:** equivalencia campo a campo sobre el corpus del
banco *y* las cabeceras reales del árbol, con **anti-vacuidad** (aborta si el corpus no trae una cabecera
no-ASCII y una con clave decorada). Sin ella, un conjunto admitido estrecho convierte la guarda en una
prohibición de escribir en español.

### «La ausencia abre» va a REQ-024, y la coordinadora se equivocaba

La coordinadora lo leyó como «dos hallazgos en uno». **Son un defecto y una decisión**, y el analista lo
desmintió con la evidencia: que un campo ausente se perdone fue decidido **a propósito**
(`arnes_sens_efectiva`: «AUSENTE sigue siendo no, y eso no se toca»), está **contratado en REQ-016
CA-11** y **firmado en R-009**. Cambiarlo exige **ADR** y nota de migración, porque si la ausencia deja
de perdonarse, **todo REQ heredado de todo proyecto consumidor** que no declare el campo deja de cerrar.

Y la frontera entre las dos es **verificable, no cómoda**: lo que §13 promete —y el BOM falsifica— son
la fila del suelo de rigor y la de hallazgos, y **las dos hablan de un documento que declara el campo**.
Con BOM el documento lo declara y la puerta no lo impone: la fila es **falsa**. Sin el campo no hay `sí`
que imponga nada y la fila **no promete nada**. Cerrar REQ-023 restituye la verdad de las dos.

**Pregunta abierta con medición pendiente, no afirmación:** leyendo `arnes_rigor_efectivo` +
`arnes_sens_efectiva` + la rama `if [ "$rigor" != "ligero" ]`, un `<!-- Sensible a seguridad: sí -->`
junto a `Rigor: ligero` **parece** cerrar hoy con QA y Seguridad pendientes —comentar equivale a borrar
(REQ-016 CA-11, medido), sin `sí` no hay suelo, y `ligero` salta los dos veredictos—. **No se ejecutó, a
propósito**, para no falsear las sondas de reloj de la comisión de QA viva. Si se confirma, sube el
forzador de REQ-024; el reparto no depende de ello.

**`Archivos:` declarado de verdad y sin maquillar:** colisiona con REQ-021 (`run.sh`, el `README.md` del
banco), REQ-017 (+`hooks/lib.sh`), REQ-007 (+`guard-completado.sh`, `arnes-lectura.sh`), REQ-020 (su
glob `secciones/*.sh` cubre las tres secciones nuevas) y con casi todo vía `AGENTS.md`. **Implementación
en serie.** Dos omisiones deliberadas con motivo: los artefactos de gobierno, por REQ-016 H-05 —si se
declaran, cualquier par colisiona por una bitácora—; y `hooks/campos-req.awk`, porque `CA-06` exige que
la guarda sea **observacional** y no debería necesitar ni una línea allí: **si hay que tocarlo, es la
señal de que dejó de serlo**, y va como desviación declarada, no como cambio silencioso del campo.

**Estimación del analista:** ~250–350 k de desarrollo, **≈600–700 k con QA y auditor**, y predice **dónde
muere la primera vuelta**: `CA-04` o `CA-09 (iii)`, porque la implementación intuitiva falla una de las
dos **por construcción**. Los dos criterios existen para cazarlas antes de `main`.

## [GitHub] — 2026-09-08 · REQ-021: cuando la misma cifra se desmiente dos veces, lo que sobra es el número — el total ilustrado sale de CA-08
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Write-back de `DEV-021-06`, el único `contrato` que impedía cerrar REQ-021.** `CA-08 (i.2)` ilustraba
los procesos comprados con «hoy: 2»; medidos **6** (`sonda-linea-base.sh` 17 → 23), desglosados en **+1**
por CA-01.1 y **+5** por CA-05.1 — **1** del `git hash-object --stdin-paths` del lote y **~4 que ese
`git` gasta por dentro**. Corrida `ca08-1788843906`, árbol `794fa4c`.

**Y la decisión: el paréntesis se va.** El criterio pasa a acotar **las invocaciones compradas** —una de
la sonda por CA-01.1, una sola de `git hash-object` por lote por CA-05.1— y declara explícitamente que
**no** acota los procesos que cada invocación gasta por dentro. Tres motivos, y el segundo es el que
manda:

1. Es la forma **(b)** que REQ-012 proscribió, y **este mismo criterio la ha pagado dos veces en un
   día**: el `0` de `DEV-021-01` y el `2` de `DEV-021-06`.
2. **El número no es del sistema.** Cuatro de los seis son internos de `git`: no los elige el REQ ni
   quien lo implementa, y no se pueden bajar sin quitarle a CA-05.1 lo que verifica. Un total ilustrado
   quedaría desmentido **sin que nadie hubiera tocado el código** — y por eso tampoco resolvía nada
   fijar la versión de `git`: sería un contrato que caduca con un `apt upgrade` ajeno.
3. Era una **segunda transcripción** de una cifra cuya sede ya existía (el Historial), que es lo que
   **CA-01 punto 4** prohíbe por nombre. Y se desfasó exactamente como ese punto anuncia.

**Lo que NO se relajó:** el techo de 0 añadidos, la obligación de declarar el comprador de cada proceso
y el incumplimiento del proceso sin comprador siguen literales. Lo que sustituye al total es **más**
exigible: contar invocaciones es verificable y estable donde un total no lo era. Y la mordida
anti-cheque-en-blanco se conserva porque el conjunto de criterios compradores sigue **cerrado** — sin
marca de «no exhaustivo», porque si se abriera, «comprado» volvería a ser la coartada.

**Barrido de coherencia, extendido a propósito.** El mismo criterio llevaba otras cuatro cifras del
**prototipo** que la misma corrida desmiente; fijar sólo el `2` habría dejado `(i.2)` diciendo `+2` tres
líneas más abajo. Salen del **texto de criterio** las de `(i.1)` y `(iii)`, sustituidas por la propiedad
más el puntero; las de la prosa quedan **marcadas como del prototipo** y no se borran, porque son el
registro de por qué el número se re-derivó. Ningún techo, alcance ni dirección admitida se movió.

**`ADR-005` gana el punto (d) de su mandato:** *un criterio de coste acota las invocaciones que compra,
no los procesos internos de un programa de terceros.* Doctrina reutilizable, y por eso va al ADR y no al
criterio.

**`Hallazgos abiertos:` queda con seis, todos `instrumento`** — `DEV-021-05` … `DEV-021-11` menos el 06.
Ninguno bloquea. Y **`CA-07 punto 2 no se relajó** para hacerle sitio a `DEV-021-07`: esa congelación es
lo que hace acreditable la mudanza, y queda escrito en el REQ.

**Una observación abierta, no legislada:** el `+5` depende de los internos del `git` de esa corrida, y el
registro de condiciones (`bash=`, `nucleos=`, `carga=`, `arbol=`, `oraculo=`) **no captura la versión de
`git`**, así que esa cifra del Historial no es del todo reproducible en el sentido de CA-06.3. No se tocó
CA-06 —su conjunto exhaustivo de campos vive en el parser de `run.sh` y añadir uno sería alcance nuevo—;
queda como candidato para el desarrollador al implementar el parser.

## [GitHub] — 2026-09-07 · REQ-021 implementado: `tests/util/` con las tres sondas, el banco a 873 casos, y el nieto que cazó un `vivos=0` con la descendencia viva
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

**`tests/util/`**: `sonda-reloj.sh`, `sonda-procesos.sh`, `sonda-linea-base.sh` y su `README.md`.
Programas `100755` con un registro `clave=valor` de una línea por invocación, diagnóstico por stderr y
**ningún veredicto** — el juicio vive en `run.sh`, en sede única: un solo parser (`sonda_lee`), una sola
banda (`sonda_banda`), la puerta de CA-10 (`sonda_usable`) y la calibración **una vez por instrumento y
por corrida** antes del despacho. Sección nueva `38-sondas-compartidas.sh` con 21 casos;
`CASOS_ESPERADOS` **852 → 873**, los dos literales a mano. `PARED37` **se queda a propósito**: es
`SEC-030`, fuera del alcance declarado.

**Banco: `869–870 PASS · 0 FAIL · 3–4 SKIP` sobre 873, rc 0, ~51 s.** Las tres quality gates de §7 en
verde.

### El sujeto lineal que faltaba, y por qué el anterior no servía

CA-03 (a) exige un sujeto sensible de coste **realmente lineal**, y el candidato de la comisión anterior
—apilado de cadenas en bash— es **superlineal** (factores 2,048 y 2,566 donde el contrato pide 2). El
sustituto es un **bucle aritmético puro**, `for ((i=0;i<N;i++)); do :; done`: no reserva memoria, no hay
`realloc`, y duplicar N duplica el coste **por construcción**.

| | `cal_a` (esperado 2,000) | `cal_b` (esperado 1,000) |
|---|---|---|
| Máquina en reposo, 8 corridas | 1,916 – 2,065 | 0,924 – 1,009 |
| Con carga ajena, 8 corridas | 1,663 – 2,362 | 0,779 – 1,058 |

Banda en el juez: `a ∈ [1,600 · 2,400]`, `b ∈ [0,800 · 1,200]`, **33 % de separación**. **No se ensanchó
nada para acomodar deriva**: el sujeto no deriva. `procesos` y `linea-base` dan 2,000 y 1,000 **exactos**.

**Y el `4` de (iii) no cabía con la forma obvia del sujeto — se resolvió en el sujeto, no en el techo.**
Los cuatro ejercicios no cuestan lo mismo (el sensible al doble cuesta el doble por construcción →
`1+2+1+1 = 5`). Dimensionando el insensible a **un cuarto** del sensible base: `1+2+¼+¼ = 3,5`. El techo
no se tocó.

### CA-08 sobre la corrida real

Corrida `ca08-1788843906`, árbol `794fa4c`, oráculo `/proc/stat:processes` (suelo **0/12**, factor
**2,000** exacto, tasa de fondo 3,20–3,36 forks/s en tres ventanas de 25 s). **(0) acreditado:** la línea
base se materializó con la propia `sonda-linea-base.sh` (`archivos=67`, `estado=ok`) y **contiene `37/1`
y `37/2`**.

- **(i.1) −56 procesos añadidos**, calibración excluida: `(2092 − 69) − 2079`, mínimos de **6 series
  intercaladas**. **No gasta ni uno de los comprados.**
- **(i.2)** reloj **−4**, procesos **−31**, línea base **+6** — con su comprador: +1 por CA-01.1 (se
  invoca) y +5 por CA-05.1 (`git hash-object --stdin-paths` del lote: 1 de `git` y ~4 que `git` gasta por
  dentro).
- **(ii) 1,165×** (`26 032 011 / 22 350 191 µs`), techo 1,250×; convergencia 1,006×/1,004×.
- **(iii)** reloj 1,666× · 0,312× · 1,431×; procesos 0,000× · 2,875× · 2,133×; techo 4,000×.

### Dos defectos que la propia mudanza cometió, y el caso que los cazó

- **`$BASHPID` dentro de `$( )`, otra vez** — el mismo error que este REQ existe para no repetir. El
  archivo se escribió `…-3881596.json` y se leyó `…-3882892.json`: `cuenta=0`, FAIL.
- **`/proc/<pid>/task/<tid>/children` no termina en salto de línea**, así que `read … || continue`
  descartaba la lista **siempre** y la sonda publicaba `vivos=0` **con la descendencia viva**. Lo delató
  el caso del **nieto**; **con un hijo directo habría dado verde.** Es la justificación medida de por qué
  CA-04.1 exige acreditar por descendencia y no por hijo.

### `SEC-037` cerrado

Las cinco propiedades sobreviven a la mudanza **y cada una tiene un caso del banco que la interroga**:
CA-02.5 (`estado=mixta`, `instrumentada=si`, sin número), CA-04.3 (`type -P`, sin `command -v`, y la
comprobación **sobre la ruta escrita en el envoltorio generado**), CA-04.4 (camino de error real
`sin-sujeto` y **0** directorios detrás), CA-04.5 (las cuatro formas `:x`, `x:`, `::`, `.` →
`path-inseguro`) y la propiedad por descendencia con nieto, con su fail-before.

### Seis hallazgos nuevos. Uno `contrato`, y uno que BLOQUEA LA FUSIÓN

- **`DEV-021-06` (`contrato`)** — (i.2) ilustra **2** procesos comprados; medido **+6**. La **regla** se
  cumple (cada uno con su comprador nombrado); el **paréntesis** del criterio, escrito sobre un
  prototipo, es falso. Write-back del **número**, no de la regla. **Impide cerrar REQ-021.**
- **`DEV-021-07` (`instrumento`) — la autoprueba del corredor sale `rc=1` y el CI la corre como paso
  propio, sin `continue-on-error`.** `CA-18` exige que ningún archivo de sección pase de **400 líneas** y
  las dos secciones 37 miden **751 y 614**. **No bloquea el cierre —es `instrumento`— pero bloquea la
  fusión**, porque `hooks-en-linux` es la puerta requerida de `main`.

  **Y lleva roja desde el delta final de REQ-017, que es lo que hay que retener.** El CI que marca
  `pass` en el PR #43 midió `0bab7a1`, donde esas secciones median **346 y 266** líneas; local está **20
  commits por delante**. Es **H-08 con otra cara: un verde sobre un árbol que ya no existe.** REQ-017
  cerró por encima de esta roja, y no fue indebido —`CA-18` es `instrumento` y §6 no lo hace
  bloqueante—, pero la ventana no puede fusionar sin partir esas dos secciones. La mudanza de REQ-021
  **mejora y no arregla** (761→751, 646→614), y no se arregla aquí porque **CA-07.2 congela sus
  `CASOS_ESPERADOS_SECCION`**.
- **`DEV-021-08`** — CA-05.1 deja ejecutable **todo** `*.sh` materializado; al materializar `tests/`, la
  copia rompe la CA-27 del propio banco.
- **`DEV-021-09`** — el plazo de CA-04.2 se comprueba **entre** unidades de trabajo, no **dentro** de
  una. Acotar una unidad colgada exige un vigilante en proceso aparte, y eso es justo lo que (i.2) no
  admite: en bash no hay forma de esperar con plazo sin gastar un `fork`. **Declarado** en
  `tests/util/README.md`, no prometido.
- **`DEV-021-10`** — el margen superior de `cal_a` es del **1,6 %** bajo carga ajena (peor observado
  2,362 contra 2,400). **Falla hacia FAIL, no hacia verde.**
- **`DEV-021-11`** — CA-07.2 pide «ninguno pasa de PASS a SKIP» y el caso de la pared **se abstiene por
  diseño**: 4 corridas dieron `SKIP·PASS·PASS·PASS` en la línea base y `PASS×4` en el nuevo.
  Preexistente, dueño `SEC-030`.

**Coste:** ≈430 k tokens y ~3 h de reloj — 3 corridas completas del banco, 12 de `37/*` intercaladas
para (i.1) y (ii), 8 del corredor para la banda y 4+4 para DEV-021-11.

## [GitHub] — 2026-09-07 · REQ-021: el desarrollador midió antes de construir, CA-08 resultó insatisfacible, y la renegociación conservó el techo cambiando el grano
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `desarrollador` (medición), `analista-requerimientos` (renegociación).

**La comisión de desarrollo se despachó con una instrucción: medir `CA-08 (i)` antes de escribir una
línea, y si no cabe, parar. No cabía. Paró.** No implementó nada, el árbol quedó intacto y todo su
aparato de medida vive fuera del repositorio. Coste: ~135 k tokens y 15 minutos **para no construir** —
contra una vuelta de desarrollo y una de QA, con un contador de tres que **no se reinicia**.

**La medida, contra un oráculo y no contra la sonda gemela.** El contador de forks del kernel
(`/proc/stat`, campo `processes`), leído sólo con builtins — leerlo no gasta un fork, así que no se mide
a sí mismo. Calibrado antes de usarlo: suelo de ruido **0 forks** (12/12), sujeto sensible `n=10 → 10` y
`n=20 → 20` (**factor 2,000 exacto**), insensible `0/0`. Corridas **C1** y **C2** nombradas y
reproducibles.

| Medición (una invocación) | Línea base | Sonda, calibración incluida | Añadidos |
|---|---|---|---|
| reloj | 6 | 4 (C1) · 5 (C2) | **−2 / −1** |
| procesos | 45 (C1) · 46 (C2) | 43 | **−2 / −3** |
| **línea base** | **18** | **41** | **+23** |

Aislando la calibración: `sonda-linea-base.sh` **con** calibrar = 41, **sin** = 20 ⇒ **la calibración
sola cuesta 21, contra un presupuesto total de 18**. Aunque la medición nueva costara cero, ya no cabe.
Y no es de implementación: la calibración son cuatro materializaciones por el mismo camino, que es lo
que **CA-03.4 exige**; abaratarlas obliga a quitar pasos del camino, que es lo que CA-03.4 prohíbe.

### La renegociación: se conserva el techo, cambian el grano y el alcance

La propiedad que el `0` protegía —**mudar las sondas no encarece la puerta requerida de `main`**— sigue
en pie y **ahora está medida**. Lo que no se sostenía era el grano:

- **El `0` se conserva**, en el grano en el que la puerta paga: **la corrida**. Medido **−2 en C1 y C2**.
- **La calibración sale de (i)**: es capacidad nueva, ninguna línea base la tiene, y cargarla a la
  cuenta de la no-regresión es lo que hacía el criterio insatisfacible. La acotan el grano de CA-03 y (iii).
- **Lo comprado se declara con su comprador.** (i.2) admite `0 + los procesos que compre un criterio de
  este REQ`, **cada uno nombrado con el criterio que lo compra** (hoy 2, por CA-01.1 y CA-05.1). *Un
  proceso añadido sin criterio que lo compre incumple* — sin esa cláusula, «comprado» sería la coartada.
- **(iii) cambia de denominador, no de holgura:** de `0,25× el reloj de la medición` a **`no más de 4×
  una medición del mismo instrumento, en reloj y en procesos`**. **El 4 se deriva de lo que CA-03
  contrata** —par sensible/insensible × dos tamaños = cuatro ejercicios—, no de lo que cuesta. Medido
  **1,05×**. Y un efecto lateral que vale por sí solo: **(iii) pasa a ser el único indicador medible de
  CA-03.4**, la identidad de camino, que hasta hoy se sostenía por inspección.
- **(0) nuevo:** la línea base se acredita **antes** de medir y, si no contiene `37/1`/`37/2`, no hay
  número — `sin-linea-base` + SKIP, **nunca verde**. Es **H-08 cerrada en el criterio**.
- **La salida está pre-decidida:** si (i.1) o (ii) no caben sobre la corrida real, **no se sube el techo
  — se reduce el alcance**, con residual declarado.

**Cuatro hallazgos `contrato` cerrados por write-back**, los cuatro encontrados **antes del código**:
`DEV-021-01` (el techo insatisfacible), `DEV-021-02` (la línea base nombrada no contiene lo que se mide:
el commit base `cf2009e` no tiene las secciones 37, que las creó REQ-017 dentro de esta misma rama),
`DEV-021-03` (CA-05 pedía un **tag** y CA-08 un **commit**; ahora admite cualquier referencia que `git`
resuelva) y `DEV-021-04` (CA-03 no fijaba si la calibración es por invocación o por corrida — decidido
**por instrumento y por corrida**, con el identificador de corrida atando calibración y mediciones).

### `DEV-021-05` — una auditoría preventiva puede producir un criterio insatisfacible, y §6 no lo advierte

`instrumento`, dueño `analista-requerimientos`, ventana 1.34.0. **No fue un descuido**, y la mecánica
está precisada: (1) la redacción fijó el `0` **sin código y sin medición**; (2) **R-010 endureció CA-03
—la identidad de camino— sin volver a mirar el techo que ese endurecimiento encarecía**. Dos criterios
razonables por separado, **imposibles a la vez**.

Es la segunda de las tres formas que **REQ-012** proscribió —«fijar un número que la medición
desmiente»—, y la auditoría preventiva es exactamente la condición en la que se cuela: `AGENTS.md` §6 la
presenta como puro adelanto y no dice que **endurecer un criterio puede volver insatisfacible a otro que
nadie vuelve a mirar**. Su sede son `AGENTS.md` §6 y `requirements/README.md`, ninguna en el `Archivos:`
del analista; el enrutado queda con la coordinadora.

**Sin ADR:** `ADR-005` **todavía no existe** («a redactar con la implementación»), así que «sucesor» no
tiene objeto, y no cambia alcance ni decisión base. Lo que cambia es su **mandato**, que se amplía con el
grano y su coste medido, la doctrina de quién compra cada proceso, y que (iii) mide la identidad de camino.

**Dos riesgos vivos, de diseño y no de contrato:** CA-03 (a) exige un **sujeto sensible de coste
realmente lineal**, y el candidato medido —apilado de cadenas en bash— **no sirve** (factores 2,048 y
2,566 donde debería haber 2); en procesos salió exacto. Y **(ii) es el único número de CA-08 sin
medición detrás** (1,25×, nunca ejercido porque su línea base no existía): queda `operativo`.

**Coste permanente declarado:** **21 procesos por corrida**, una sola vez, por la calibración de
`sonda-linea-base.sh`.

## [GitHub] — 2026-09-07 · REQ-021: el write-back estaba hecho en los criterios y no en la cabecera, y la obligación heredada de REQ-017 necesitaba un quinto punto para haber cazado su propio caso
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Write-back de los hallazgos preventivos de R-010 en `requirements/REQ-021.md`, cambio MENOR.** Se
despachó antes que el código a propósito: `SEC-035` y `SEC-036` son `contrato`, y `guard-completado`
deniega el cierre de un REQ con un `contrato` abierto. Para eso existe la auditoría **preventiva**
(`AGENTS.md` §6) — para que sus hallazgos sean contrato **antes** de construir, no después.

**Lo que el analista encontró antes de escribir nada:** el write-back **ya estaba hecho a nivel de
criterio**. REQ-021 nació después de R-010 y su propio autor lo incorporó (CA-03, CA-04, CA-06.4,
CA-10 y el residual con forzador observable). Verificadas una por una las **cuatro** remediaciones de
`SEC-035` y las **tres** de `SEC-036` contra el registro: están todas. **Lo que faltaba era el campo de
la cabecera**, que es lo único que la máquina lee. Un contrato correcto con el campo sin actualizar
habría bloqueado el cierre sin que nadie supiera por qué.

`Hallazgos abiertos:` queda en `SEC-037 (instrumento, dueño desarrollador, se cierra con la
implementación, R-010)`. `SEC-035` y `SEC-036` cerrados por write-back; sus entradas en
`docs/seguridad/registro-seguridad.md` siguen diciendo `abierto` y **cerrarlas es del
`auditor-seguridad`** —ese archivo no está en el `Archivos:` de REQ-021—, anotado en la Trazabilidad
para que no se pierda.

**La obligación heredada de REQ-017, y por qué necesitaba un punto que no existía.** REQ-017 cerró con
la regla de que toda cifra publicada nombre su corrida, y REQ-021 construye **las tres sondas que
producen esas cifras** para todo el arnés: si no está aquí, no está en ningún sitio. El analista amplió
CA-06.3 (la corrida se nombra con invocación, árbol y plataforma, y `desconocido` nunca se omite) y
añadió **CA-06.5**: una cifra **derivada** —diferencia, cociente, extrapolación, agregado— sólo es
publicable si **cada entrada** lleva su registro, la operación queda escrita junto a la cifra y ninguna
entrada se tomó fuera de la disciplina de CA-02; si alguna no cumple, se publica **rango observado** y
nunca un valor.

El motivo de que el punto 5 no fuera opcional es el que importa: **los puntos 1 a 4 no habrían visto el
caso de REQ-017**. La última medida podía llevar su registro impecable — la cifra publicada («≈1,60 MB»)
no era esa medida, era una extrapolación cuyas entradas eran muestras únicas. Es la forma (d) —medir
correctamente la magnitud equivocada— **desplazada un paso río abajo**.

**Y una magnitud sin nombrar en CA-08 (iii):** decía `0,25×` a secas, y con (i) midiendo procesos y (ii)
midiendo reloj admitía **dos lecturas que dan verde por separado**. Ahora dice «el coste **de reloj** de
calibrar … no más de 0,25× el **de reloj** de la medición». Ningún número se mueve.

**Sin ADR: es MENOR.** `SEC-035` y `SEC-036` cambian **cómo** se contrata el sustituto, no **qué** se
decide — la decisión base sigue siendo «acreditar la medida en vez de custodiar el instrumento», que
`ADR-005` ya registra con su condicionamiento.

**Una pregunta abierta que el desarrollador tiene que resolver midiendo, antes de construir:** CA-08 (i)
exige «no más de 0 procesos añadidos … calibración incluida», y la calibración corre dos sujetos
sintéticos en cada corrida. Si no cabe, es un hallazgo `contrato` **contra el criterio**, y el número se
renegocia con el analista — **nunca dentro de la comisión que lo incumple**.

## [GitHub] — 2026-09-07 · REQ-017 `completado`: la auditoría firma atacando el contrato y no la gemela, y encuentra que un carácter invisible apaga el enforcement entero
> Origen: GitHub (commit) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `auditor-seguridad` (R-012), coordinadora (cierre).

**REQ-017 pasa a `completado`.** Primera palanca de coste de 1.33.0 cerrada, con el ciclo entero
recorrido: analista → desarrollador → QA (tres vueltas, las diez CA en verde) → auditor. La puerta
`guard-completado` midió la transición y la permitió: `SEG=<aprobado>`, `RIGOR=<critico>`, cola de
aprobaciones 0, quality gates en verde, y los siete hallazgos abiertos del campo son `instrumento`.

**`Seguridad: aprobado (R-012, 2026-09-07)`.** El método del auditor es lo que vale la pena registrar:
comparó el árbol nuevo contra un **oráculo de bytes**, no contra la sentencia heredada — *da igual que
los dos árboles coincidan si los dos se apartan del contrato*. **160 015 entradas propias, 0
divergencias**, bajo el locale del entorno y bajo `LC_ALL=C`. La duda concreta que traía era que el
`?` de `*$CR?*` es un **carácter y no un byte**, y que bajo UTF-8 pudiera no casar contra un byte
multibyte inválido dejando `cr=0` donde la verdad es `cr=1`. Medido: **sí casa**. No está.

**Un hallazgo que nadie buscaba, en la dirección contraria a la temida.** Fuera del dominio de
equivalencia de `ADR-004` hay 17 divergencias, y **16 son «la heredada abría de más»**. Es decir que
v1.32.1 tiene una **puerta no determinista** que puede denegar un REQ válido al azar, y este REQ la
retira. La afirmación de CA-10 sobrevivió a 120 invocaciones por árbol con la cabecera diseñada para
maximizar el efecto: 0 deny en los dos.

### Tres hallazgos nuevos, los tres `instrumento`, ninguno introducido por este cambio

- **`SEC-047` · severidad crítica · latente.** Un **carácter invisible borra un campo de la cabecera**,
  y para dos campos la **ausencia abre**. Ejecutado contra el `guard-completado` real: un **BOM**
  delante de `Sensible a seguridad: sí`, con `Rigor: ligero`, cierra a `completado` un REQ con `QA:
  pendiente` y `Seguridad: pendiente`; sin el BOM, deniega. Un `0xc3` o un U+200B delante de
  `Hallazgos abiertos:` retira un hallazgo `contrato` que bloqueaba. Es el **bypass completo del
  enforcement con un carácter que ningún revisor ve en el diff**, y no hace falta malicia: PowerShell
  añade BOM al redirigir y los proyectos consumidores trabajan en Windows.

  **Presente e idéntico en v1.30.3, v1.31.0, v1.32.0, v1.32.1 y este árbol** — REQ-017 no lo
  introduce, no lo agrava y ningún criterio suyo podía verlo. **Latente:** barrido todo el historial
  de `requirements/`, ningún REQ llevó jamás un carácter invisible, así que no hay cierres
  contaminados ni nada que reabrir.

  **La causa es reutilizable y es la tercera aparición de la misma familia.** La guarda del CR está
  **bien construida** —propiedad y no sitio, primera sentencia del único escáner, contratada en
  REQ-016 CA-12 y firmada en R-009— pero su **extensión está mal trazada**: nombra *el CR* cuando la
  propiedad es «un carácter que no se representa y que la normalización no retira». Descripción **por
  enumeración** donde tocaba **por propiedad**, que es el defecto exacto que REQ-012 prohibió en los
  criterios, reaparecido en el código que esos criterios gobiernan. Ensanchar la enumeración pierde
  igual: es la sexta derrota de esa vía. **Decisión del propietario (2026-09-07): entra como REQ
  propio en 1.33.0**, por delante de la recomendación del auditor de ponerlo primero en 1.34.0.

- **`SEC-048` · severidad alta.** `fetch-depth: 0` (H-08) sí abre algo, y **no** lo que se teme por
  defecto: barridos los 128 commits, la historia completa no contiene secretos ni material de cliente,
  nunca los contuvo y nada se borró jamás. Lo que abre es que las secciones 37 **materializan y
  ejecutan** `hooks/` y `tools/` desde los tags — antes salían SKIP. Y el repositorio tiene **un solo
  ruleset, `proteger-main`, con `target: branch`**: **no hay ruleset de tags**. La puerta requerida de
  `main` ejecuta código identificado por **referencias mutables**, y **mover un tag no aparece en el
  diff de ningún PR**. Esa asimetría es todo el hallazgo. Se cierra con un ajuste de repositorio del
  propietario (prohibir actualizar y borrar `v*`), sin REQ ni ventana.

- **`SEC-049` · severidad baja.** CA-10 declara la divergencia en **un solo sentido**; es
  bidireccional.

**No medido, y declarado como tal en vez de supuesto:** `banco.yml` no lleva bloque `permissions:`, y
el auditor recibió `403` al pedir los permisos por defecto del `GITHUB_TOKEN` (hace falta admin), así
que **no acota el radio** de una ejecución hostil en el runner.

### Corregida una colisión de identificador antes de cerrar

R-011 terminaba en `SEC-046` y R-012 arrancó un número por debajo: durante unos minutos hubo **dos
hallazgos distintos numerados `SEC-046`**, y la ambigüedad ya estaba escrita en el campo `Hallazgos
abiertos:` de REQ-017, que **lee la máquina**. Renumerados los tres de R-012 a `SEC-047`/`SEC-048`/
`SEC-049`, con las sustituciones acotadas al tramo de R-012 para no tocar ningún id ajeno; `SEC-046`
(R-011, REQ-020) queda intacto.

**Y la comprobación que la coordinadora dio para verificarlo estaba mal escrita, con la misma forma que
el hallazgo que acababa de leer.** Pedía que no hubiera **encabezados `SEC-` repetidos**, y eso marca
en falso los siete hallazgos que reaparecen para **cambiar de estado** (`SEC-024 — abierto →
en-mitigación → mitigado`), que es el registro funcionando como debe. Enumeración otra vez donde tocaba
propiedad. La que discrimina cuenta sólo las líneas donde el id **declara** un hallazgo (id + clase +
estado) y sale vacía; el inventario va de `SEC-001` a `SEC-049`, monótono y sin huecos.

## [Interno] — 2026-09-07 · REQ-017: write-back del mapa de archivos tras H-08, y CA-04 corregida antes de despachar QA (medía una función que no existe en su línea base)
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Write-back de deriva (`AGENTS.md` §9), cambio MENOR.** El delta de implementación de REQ-017
(`cand/1.33.0`, `bf8ca8f`) tocó tres archivos que el campo `Archivos:` del REQ no declaraba, con
ampliación de comisión **aprobada por el propietario** (gate humano de §6: el workflow de CI es
decisión suya). El `desarrollador` no lo corrigió porque su comisión le acotaba la intervención en el
REQ al `Historial de cambios`, y el mapa es de la **Definition of Ready** del analista; lo dejó
anotado en la fila de H-08 para que el write-back no dependiera de que alguien leyera su informe.

**Añadidos al campo:** `.github/workflows/banco.yml` (el `fetch-depth: 0` que cierra H-08),
`docs/PENDIENTES.md` (donde vive el hallazgo con su dueño) y `docs/qa/1.33.0.md` (el registro de la
ventana). Las rutas van **sin decoración de Markdown**: mientras **SEC-020** siga abierto, un campo
decorado elemento por elemento hace que `tools/arnes-paralelo.sh` responda `disjunto` con rc 0 sobre
rutas que no existen.

**Y la regla de exclusión que este REQ declaraba se estrecha**: `docs/qa/<versión>.md` deja de contar
como «artefacto de gobierno que toda comisión toca». No es universal —es por ventana— ni es un
apéndice: es donde se escribe la evidencia medida que CA-04, CA-05 y CA-09 acreditan. El motivo de
fondo es que la intersección se calcula **sobre lo declarado**: un archivo que REQ-007, REQ-008 y
REQ-011 declaran y REQ-017 no salía `disjunto` **en falso** — fail-open, el modo de fallo exacto que
el campo existe para evitar.

**Consecuencia operativa, dicha por delante:** con `banco.yml` dentro del mapa, **todo REQ que declare
`.github/`, `.github/workflows/` o ese archivo colisiona con REQ-017**, porque la herramienta expande
un directorio a todo lo que cuelga de él. Afecta a REQ-014 (que ya colisionaba por
`tests/escenarios/hooks/`) y al canal de informes previsto para 1.34.0, que sólo saldrá disjunto si
declara sus rutas de `.github/` una por una en vez del directorio.

**Y en el mismo write-back, tres correcciones inline en CA-04 y CA-09, ANTES de despachar QA.** El
motivo no es la pulcritud: es **gastar una de las tres vueltas dev↔QA en un hallazgo de redacción que
cuesta cuatro líneas**, con un contador que **no se reinicia** (`AGENTS.md` §6). Es la vuelta más cara
y más evitable del ciclo, y `requirements/README.md` manda al QA reportar un criterio mal formado
**antes** de ejecutar la prueba.

1. **CA-04, el procedimiento — el criterio apuntaba al vacío.** Decía «se mide `arnes_sin_cita` de
   este árbol **y la del tag v1.32.0**», y `arnes_sin_cita` **no existe** en v1.32.0: la noción de
   cita nace en 1.32.1. La mitad derecha de la razón no designaba nada. Ahora se mide **la boca que
   lee una línea de cabecera** —`arnes_campo_linea` hoy contra `arnes_norm_clave` sola en v1.32.0—,
   con el puntero al sitio único (`hooks/lib.sh`) y con el porqué: lo contratado es el coste de
   **leer una línea de cabecera**, trabajo de la **capa entera** y no de una función con un nombre
   concreto. De las dos lecturas se contrata la **estricta** (1,27× capa contra capa, frente al
   0,21× de comparar sólo el escáner). **El techo ≤ 2,0× no se toca.**
2. **CA-04, referencia:** «hoy es **49×**» → **7,9×** del árbol enfermo medido **en Linux**, más el
   **1,27×** de este árbol; el 49× queda declarado fechado en otra plataforma y no reproducible.
3. **CA-09, referencia y procedencia:** heredada ≈ 0,99 → **≈ 0,94 MB**; v1.32.0 **≈ 1,56 MB
   retirado** (no medible en ese rango en Linux, orden ~1); cada cifra pasa a llevar **la corrida de
   la que sale**, y se **declara** la divergencia abierta —orden 2,01 y 2,00 en la corrida de Linux
   del 2026-09-07 frente a un **1,46** posterior sobre un camino que se sabe cuadrático—. No se
   resuelve aquí: es de **SEC-030** y de QA. CA-09 sigue exigiendo la **medición**, no un valor.

**Clasificación: MENOR, las cuatro.** Ningún techo contratado se mueve, el alcance no cambia y no hay
ADR. La corrección de CA-04 se examinó expresamente por si era **de fondo** —lo habría sido si
cambiara el significado del criterio— y no lo es: la magnitud contratada sigue siendo la misma y la
sustitución cae del lado **estricto**, así que no puede ser una relajación disfrazada
(`requirements/README.md` § «Y el reverso, para que esto no sea una coartada»).

**No se toca nada más:** `Estado:` sigue `en-progreso`, los otros siete criterios quedan **idénticos**
y no hay ADR — el mapa es un dato de coordinación, no una decisión de arquitectura, y corregirlo no
reabre el trabajo ni firma ningún veredicto. QA y auditoría siguen `pendiente`.

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

## [Interno] — 2026-09-07 · REQ-017: `QA: aprobado`, y la coordinadora se salta su propia regla de paralelismo
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**`QA: aprobado`.** Los **diez** criterios pasan; `QA-017-12` y `QA-017-14` cerrados. Quedan cuatro
residuales `instrumento` con dueño: `QA-017-07` (escalado al auditor), `-11`, `-13` y `-15`.

**Y lo hizo sin medir nada, por una comprobación que lo hace innecesario:** `git diff --stat` entre los
dos commits **sobre `hooks/`, `tools/`, `tests/` y `.github/` sale vacío** — el árbol de código es byte a
byte el que validó en la vuelta 2. Verificó además **mecánicamente** que ningún criterio cambió: la
sección de criterios ocupa las **mismas líneas 20–91** en las dos versiones y difiere en **una sola**, y
las diez líneas que llevan el `Dado/Cuando/Entonces` y los techos son **idénticas incluso en su número
de línea**.

**`QA-017-15` (`instrumento`): cuarta instancia de la clase, en el párrafo que la nombra.** El
write-back escribió «con la palanca encendida **no está medido**» — y **sí lo estaba**, en tres sitios
del registro que la propia frase cita. Con una variante: las tres anteriores se escribieron sin ejecutar
**el mecanismo**; ésta, sin leer **el registro de evidencia citado en la misma frase**. Y una segunda
mitad: una frase compone «9 de 9» de una corrida con los márgenes de **otra** — cada mitad cierta, **la
frase describe una corrida que no existió**.

**⚠️ Y un fallo de la coordinadora que encontró QA:** el commit `7335586` **arrastró 192 líneas del
registro de QA** que se estaban escribiendo en ese momento, bajo un mensaje que no las menciona. Causa:
un **`git add -A` con cuatro comisiones vivas**. El contenido sobrevivió; lo falso es **el mensaje del
commit**. Regla nueva y barata: **mientras haya comisiones vivas se comitean rutas nombradas, nunca
`-A`** — *quien comitea es una comisión más, y la única que puede tocar todos los ámbitos a la vez*.
Segunda observación suya, también de la coordinadora: **se le dijo que el árbol estaba limpio y no lo
estaba**; no contaminó la firma, pero la premisa del encargo era falsa.

## [Interno] — 2026-09-07 · REQ-022 sale de borrador: el registro de QA ya muerde más que el libro mayor
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Medición nueva que cambia la prioridad: `7 de los 8 REQ abiertos declaran el mismo `docs/qa/1.33.0.md`
⇒ los 21 pares que forman esos siete colisionan por UN SOLO archivo.** La pregunta no era «antes de que
muerda»: **ya muerde, y más fuerte que la colisión del libro mayor** (5 de 8). *(21 **pares**; no
confundir con los «21 de 21 **REQ**» de R-010.)*

**Decisión: un archivo de registro de QA por REQ.** Y el corte del argumento cae exacto: **la analogía
del libro mayor aguanta para el índice y se rompe para la evidencia.** La entrada del CHANGELOG es
*resumen de orquestación* —que la coordinadora ya tiene—; el registro de QA es **evidencia primaria que
sólo posee quien la midió**, y centralizarla exigiría una **segunda transcripción** —el modo de fallo
que el propio REQ prohíbe un piso más abajo— arrancándole a cada cifra su condición. Por eso
`docs/qa/<versión>.md` **sí** se queda, pero como **índice de ventana**.

**Y no estrena convención: reconcilia una deriva.** `templates/AGENTS.md.tpl` §12 y `agents/qa-tester.md`
**ya dicen «por REQ»**, y `docs/qa/REQ-001.md` la sigue — es **la práctica** la que derivó. Ese mismo
archivo de agente lleva **las dos convenciones vivas** en dos líneas distintas: **tercera vez** que este
repositorio mide ese patrón. Consecuencia útil: `arnes-upgrade` **no lleva migración**.

**Un `disjunto` falso YA EJECUTADO, encontrado al medir:** REQ-017 **no declara** `requirements/REQ-017.md`
y su write-back del 2026-09-07 **escribió en él**.

⚠️ **Y la consecuencia que hay que decidir: mover el registro de QA REABRE `REQ-012`, que está
`completado` y `critico`.** Su `CA-09` nombra literalmente `docs/qa/<versión>.md` como sitio donde el QA
anota la forma; al moverlo, ese criterio **dice algo falso** y §9 obliga a devolverlo a revisión. **No
cabe la exención de «alcance temporal»**: ésa exime de reescribir contratos cerrados para conformarlos a
una regla de formas, y aquí **cambia el árbol que el criterio describe**. El write-back es de **una
ruta**; el ciclo que reabre es **completo**. Segundo gate: el REQ escribe `.arnes/config.json`, que §6
reserva al propietario — a la cola **antes** de implementar, no al cerrar.

**La cuarta dimensión entra, pero NO como dimensión.** Va como bloque propio, y el motivo es fino: las
tres de la regla principal son propiedades de un **par** de comisiones y se comprueban comparando dos
declaraciones; la de la comisión interrumpida es de **una sola** y no se comprueba comparando nada.
Llamarla cuarta haría que **un veredicto de despacho pareciera responder por algo por lo que no
responde** — que es el error de origen de la herramienta que este REQ corrige.

**El par REQ-019/REQ-022 queda escrito como el único del corpus donde saltan las tres dimensiones a la
vez**, con la lectura que importa: **si SEC-034 no se hubiera levantado, ese par habría salido
`disjunto` con rc 0** y las dos comisiones habrían leído **dos versiones de la misma regla**.

## [Interno] — 2026-09-07 · Preventiva R-011 sobre REQ-020: el juez de todas las sondas no lo vigila nadie
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `auditor-seguridad`.

**`Seguridad: preventiva` con nueve hallazgos, ocho `contrato`. Cinco salen de leer el árbol de hoy**,
no de especular: la mitad de los criterios de REQ-020 hace **afirmaciones verificables sobre el código
actual**, y varias son falsas.

**`SEC-038` — el literal está protegido en su ASIGNACIÓN, no en su USO.** El control es una conjunción
de tres términos —*(término literal) ∧ (es ése el operando) ∧ (la rama se ejecuta)*— y `CA-04` contrata
**el primero**. Tres vías de «arreglarlo» derivándolo sin tocar la asignación, y la tercera es la fina:
**ensanchar la condición de suspensión** del cuadre total apaga el control sin tocar ni el literal ni la
comparación, y **ningún criterio mira esa condición**.

**`SEC-039` — el techo de SKIP se puede subir para tapar, y el propio mensaje de error entrega el
valor.** Recuento estático: la sección `37-…-2` declara **11 casos** y tiene **26 ramas que pueden emitir
SKIP**; la `37-…-1`, 13 y 29. ⇒ **la sección donde ocurrió H-08 puede quedarse entera sin medir**, y el
techo que la cubriría es **11**. Con `SKIP_ADMITIDOS_SECCION=11`, **H-08 reproduce y `CA-02` lo declara
conforme**. Y el flujo natural lleva ahí: el banco aborta, el criterio obliga a imprimir «el número
obtenido», y ese número se pega en la sección. Además **nadie firma subirlo**: el criterio declara cómo
se **baja** y no dice nada de la única dirección que abre.

**`SEC-040` — la acreditación cubre que el universo no encoja, NO que el sujeto sea éste.** Con
`ARNES_HOOKS_DIR` apuntando a otro árbol corren los 852 casos, `PARCIAL=no`, y sale **`Acredita: sí`
sobre otros hooks**. Y lo que lo hace grave: **la instancia que el propio REQ pone al caso 1 es
exactamente ésa** —«pasaban contra los hooks de 1.32.0, la versión con el fail-open»—. El REQ nombra el
incidente y contrata una acreditación que no lo modela. Segunda vía: **`jq` ausente** → `exit 0` con
**cero casos y sin imprimir nada**, falsificando el «siempre» que `CA-01` contrata desde el mismo archivo.

**`SEC-043` — un hallazgo de coste que nadie pidió:** la pasada única de clasificación tendría que leer
**7 518 líneas** donde hoy se leen **339** (la función retorna en la primera coincidencia): **22,18×** en
la magnitud que se paga. Y **la mitad que debía verlo es ciega por construcción**: mide el reloj sobre
un directorio de secciones **triviales**, y leer secciones triviales hasta el final no cuesta nada — la
forma (d) una capa más arriba, **no en la magnitud sino en el material**.

**`SEC-045`, y contesta la pregunta que le hice: ¿quién vigila al vigilante? Nadie, y está medido.**
`codigo_app.globs` **no incluye `tests/`**. Todo lo que REQ-020 construye —el literal, los techos, el
inventario, la autoprueba que los certifica— aterriza donde `guard-codigo` **no deniega a nadie**:
cualquier subagente y **la sesión coordinadora**, que es la misma que reúne la evidencia de «todo en
verde» y **fusiona, etiqueta y publica por delegación**. `AGENTS.md` §6 llama a `tests/` **crítico en
prosa** y ninguna máquina lo respalda; tampoco hay gate humano. **Es la estructura de SEC-036 una capa
más arriba y con más palanca: allí el artefacto sin custodia era una sonda; aquí es el juez de todas las
sondas.** A la pregunta exacta —*¿qué impide que ese «tercero» sea la misma sesión con otro sombrero?*—:
**nada, y hoy es lo que ocurre.**

Concurre con **acreditar > custodiar** y **no** mete `tests/` en el manifiesto en esta ventana, por el
mismo motivo que aceptó en SEC-036: tocar el manifiesto abre gate humano y una entrada en la cola
**deniega el cierre de cualquier REQ**, incluido REQ-017. Asume el residual con forzador observable —en
la pasada de conformidad de 1.34.0 se muta el propio mecanismo de REQ-020 y se exige que la autoprueba
**no dé verde**— y vencimiento.

**Y una nota de método suya, que es la tercera instancia del mismo conflicto hoy:** la comisión llegó
con la preferencia de sesión de «edita por `Bash`» activa y **no la siguió** para la cabecera del REQ,
citando §13 — *editar la cabecera de un REQ por consola apaga una puerta*. Es literalmente el caso que
§13 documenta: **«quien configura una sesión no suele ser quien lee esta sección»**.

## [Interno] — 2026-09-07 · REQ-018, el canal de informes: la privacidad por la forma, y lo que la forma NO puede hacer
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**La regla que gobierna todos los campos está escrita como propiedad, no como lista:** *el dominio de
respuesta natural de un campo no contiene ningún identificador del proyecto que reporta*. Versiones,
desplegables, conteos y una cabecera ficticia cumplen; **«cuéntame tu caso» está prohibido por nombre**,
porque es el campo por el que el nombre del proyecto entra **sin que nadie decida ponerlo** — distinto
de teclearlo a propósito. Con `blank_issues_enabled: false`, sin lo cual la gramática no restringe nada.

**Y el REQ se niega a fingir lo que no puede medir.** No existe propiedad comprobable de «el canal no
filtra», y un criterio que lo afirmara estaría **midiendo la forma del formulario y llamándolo otra
cosa** — la forma (d) aplicada a la seguridad, que *tranquiliza más que no medir*. Lo verificable es más
estrecho y verdadero: **no hay ningún sitio donde el dato quepa sin que alguien lo teclee a propósito**.
El resto es irreductiblemente humano y se gobierna **por respuesta**, no por prevención.

**Cuatro decisiones con su motivo, y las cuatro nacen de errores medidos esta semana:**
- **La cabecera mínima se pide como esqueleto pre-rellenado que se EDITA**, no como hueco: convierte
  una tarea de **composición** en una de **transcripción**. No impide pegar; **hace que pegar cueste
  más que editar**, y eso es todo lo que una forma puede hacer.
- **Toda opción cerrada lleva «no lo sé»**: un desplegable sin salida **fabrica** una respuesta, y lo
  que fabrica es un **error de clasificación** — justo la clase que ninguna puerta detecta y contra la
  que este canal es el único instrumento. Un formulario sin escape envenenaría aquello para lo que existe.
- **Vía de escape declarada**: si el informe no se puede escribir sin nombrar el proyecto, **no se abre
  issue**. *Cerrar una puerta sin abrir otra no reduce la filtración: la concentra.*
- **Un campo para conteos sobre el corpus ajeno**: la aportación más valiosa recibida hasta hoy fue un
  conteo sobre 47 REQ ajenos que **desmintió una conclusión nuestra bien medida sobre 17 propios**, y un
  conteo no lleva ningún dato de cliente. Es la **única mitigación conocida de la ceguera del
  autoalojamiento**.

**Hallazgo que el propio REQ destapa: una issue no es una ruta versionada.** El barrido de base de
`docs/seguridad/gobernanza-datos.md` §3 sostiene que «ninguna ruta versionada nombra un proyecto
consumidor»; abrir este canal crea una superficie de datos que ese control **no puede ver por
construcción** — **exactamente la forma de SEC-029**, un año después y en otro sitio.

**Y el error opuesto, que nadie estaba mirando:** una gramática tan estrecha que **ningún informe real
cabe** es perfectamente segura e **inútil**. Se contrata la reconstrucción de los informes ya recibidos;
el que no quepa es hallazgo `contrato` **contra la gramática**.

**Nota de método del analista, que es de la casa:** descartó publicar el número de informes de campo del
corpus porque su recuento dio 6 coincidencias **con 2 falsos positivos** y omitía aportaciones reales —
*publicarlo habría sido publicar como medido un número cuyo método acababa de fallar delante de quien lo
ejecutó*.

Queda en `borrador`: **tal como está contratado NO es disjunto** —escribe `hooks/lib.sh`,
`hooks/estado-derivado.sh` y `AGENTS.md`, así que iría en solitario y declara `Mide: sí`—, con dos
palancas escritas para partirlo si se quiere el primer `disjunto` real.

## [Interno] — 2026-09-07 · El residual descrito al reves, y la clase que ya va tres veces en el mismo REQ
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**`QA-017-12` cerrado: «ruidoso» → silencioso.** El acoplamiento de `CA-05` se declaraba fallando
*«ruidoso — el único PASS desaparece del banco en la primera corrida»*, y está medido que **en el modo
por defecto la rotura no se nota**: veredictos idénticos, `rc 0`, y las dos únicas líneas que difieren
son cifras que cambian en toda corrida. **Se sigue del propio criterio:** sin la palanca, el caso de (i)
ya es SKIP por «no se pide», así que la guarda (c) **no se ejercita** y **no hay PASS que desaparecer**.

**Y la consecuencia que hace que valiera la pena escribirlo: hubo que cambiar el forzador.** El anterior
—«quien cambie la disposición repunta la sonda»— **funcionaba sólo porque el fallo era ruidoso**. Siendo
silencioso, REQ-014 y REQ-021 cambiarían la disposición, correrían el banco, **lo verían verde** y
cerrarían: el residual **sobrevive a su propio vencimiento** y reaparece meses después, la primera vez
que alguien encienda la palanca para acreditar algo. Ahora es **obligación** —esa comisión corre CA-05
una vez con la palanca encendida— y el vencimiento queda **condicionado a que esa corrida conste en su
evidencia**: *«sin ella el residual no vence: sólo cambia de dueño sin que nadie lo haya mirado»*.
Precedente de esta misma ventana: **SEC-036** obligó a lo mismo — *un residual cuyo disparador es el
daño que debía evitar no vence nunca*.

**El analista se negó además a repetir el error por cuarta vez:** QA midió **el modo por defecto**, así
que «recuento 0 → SKIP con la palanca encendida» queda marcado **esperado, no medido**.

**La clase, escrita con nombre — va TRES veces en este mismo REQ:** *una afirmación sobre cómo se
comporta el mecanismo, escrita sin ejecutarla.* `CA-04` apuntando a una función inexistente en el tag;
la guarda (c) nombrando una señal constante-cero; y «ruidoso» medido silencioso. **Y lo que la separa de
las cuatro formas prohibidas de `CA-07`: aquéllas se ven leyendo el criterio, y ésta no** — la única
manera de verla es **correr contra el árbol lo que el criterio afirma**. Coste medido por tardanza,
dentro del propio REQ: cuatro líneas → un write-back → un hallazgo `contrato` que **bloquea el cierre**.
Propuesta para 1.34.0 como **línea de la Definition of Ready**, no como quinta forma prohibida.

**`CA-09`, márgenes corregidos:** `1,25–3,40×` → **`1,154×–2,523×`**, con la consecuencia que el número
obliga a escribir: la distancia al 1,0 —donde la sonda produce FAIL sobre razón verdadera— es **~0,15×,
no ~0,25×**. *Un colchón declarado de más es cómo un residual aceptado se vuelve un rojo sorpresa.*

## [Interno] — 2026-09-07 · QA vuelta 2: los diez criterios pasan, y lo que bloquea es una frase
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**`QA: con-hallazgos`, vuelta 2 de 3 — pero los diez criterios PASAN.** Lo único que impide `aprobado`
es un hallazgo `contrato` **sobre una frase**. Cerrados: QA-017-01, -02, -05, -06, -08, -09 y -10.

**Lo que verificó en vez de asumir:**
- **CA-08: 38 medidas, 38 PASS**, razones **0,890–1,139×** contra techo 1,250. La abstención por
  convergencia se activó **0 de 38** (máximo observado 1,227×) — no es un SKIP disfrazado. Y lo
  decisivo: **inyectó una regresión real** (un `fork` por línea) y el caso dio **FAIL en las cuatro
  mitades**, con el mensaje «*y la sonda SÍ convergió: esto es una regresión, no ruido*».
- **El dominio, falsado por su cuenta con 3 300 entradas propias** —2 000 aleatorias de cinco semillas
  y 1 300 adversariales sistemáticas—: **0 divergencias dentro del dominio**.
- **Construyó el fail-before de extremo a extremo** de la rama «no clasificables» que el desarrollador
  había declarado que no tenía. Deja de ser residual.

**`QA-017-12` (`contrato`, bloquea): la justificación del residual del acoplamiento es falsa.** CA-05
afirma que romper la disposición del corredor falla «**ruidoso** — el único PASS de (i) desaparece del
banco en la primera corrida». Medido: **en el modo por defecto no cambia nada** — los veredictos son
idénticos y `rc 0`; no hay PASS que desaparecer, porque ya es SKIP por «no se pide». Se cierra con
write-back sobre **esa frase**, sin código y sin re-medición.

**`QA-017-13` (`instrumento`): el banco no es puerta estable bajo carga, y la culpa no es de REQ-017.**
Salió rojo **2 de 12** veces, siempre por el **mismo caso ajeno** —`25-presupuesto-de-analisis.sh`—
que contrata **un reloj absoluto** de 4 000 ms: 4 333 ms bajo `JOBS=6`, y **aislado 12 de 12 verde**,
con este árbol si acaso **más barato** que v1.32.1. Es contención, no regresión, y es **la forma (d)
que `CA-07` acaba de prohibir**, viva en otro archivo.

**`QA-017-11` (`instrumento`): `CA-01` da PASS sobre un dominio vacío o colapsado.** Hay guarda para
`fuera = 0` y para `no clasificables ≠ 0`, **no para `dentro = 0`**. Con la evaluación de la heredada
truncada el dominio cae de **312 a 10** y sigue verde. No muerde hoy (312/320 en 14 de 14).

**Y una corrección al desarrollador que vale la pena conservar:** declaró márgenes de CA-09 de
«1,25–3,40×» y la medición da **1,154×–2,523×**. El suelo real está **por debajo** del declarado —
*un colchón declarado de más es cómo un residual aceptado se vuelve un rojo sorpresa*.

Coste: 1 h 10 de reloj, ~240 k declarados (300–331 k con la corrección), ~35 min de máquina midiendo.

## [Interno] — 2026-09-07 · CA-05: la guarda pasa de inerte a discriminadora, y por qué eso NO es relajarla
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**Write-back de deriva sobre `CA-05` (c).** La guarda exigía que la corrida heredada «produjera al menos
un caso — su salida existe y no está vacía», y en este corredor **la salida no existe hasta que todas
las secciones terminan**: una corrida matada por `timeout` deja 0 bytes **siempre**. Ahora contrata el
**recuento de casos que dejó escritos mientras corría** —la sonda le fija la raíz de ese trabajo antes
de lanzarla—, con las fuentes marcadas **no exhaustivas** y con puntero al sitio único, *porque lo que
se contrata es el recuento, no dónde se lee*. El `1` se declara **de contrato**: es la definición de
«esta corrida midió», no una magnitud ajustable. Referencias medidas: **37** casos matada a los 12 s,
**0** si no arranca.

**MENOR, y el argumento es el que impide leerlo como una relajación:** *la versión anterior no era
estricta, era **inerte** — nunca podía dar PASS. Sustituir un always-SKIP por un discriminador real
(0 vs 37) **aumenta** la capacidad de fallar, no la reduce.* La propiedad contratada no cambia
—«un plazo agotado por una corrida que no arrancó no acota nada»—; cambia el observable.

**Y el origen del error, que es reutilizable:** el hallazgo de QA proponía el remedio como «que la
heredada haya producido al menos un caso **o** que su salida exista y no esté vacía», y el write-back
de la vuelta 1 **tomó la glosa por la señal**, sin comprobar que en este corredor la salida no existe
hasta el final.

**Dos residuales con dueño y vencimiento**, ninguno bloquea: el **acoplamiento** entre la guarda y la
disposición en disco del corredor —falla **cerrado y ruidoso**, dueño `desarrollador`, forzador el
primero de REQ-014 o REQ-021 que entre— y la **resolución de la sonda de CA-09** con dos árboles
idénticos (SKIP/FAIL/PASS en tres corridas), que **no muerde hoy** porque el banco compara contra el tag
congelado con márgenes 1,25–3,40×; dueño **SEC-030**.

## [Interno] — 2026-09-07 · REQ-017 vuelta final implementada: CA-08 deja de ser flaky, y CA-05 nombra una señal que no existe
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `desarrollador`.

**El síntoma que veníamos a matar, medido antes y después.** Reproducido en HEAD: **1 de 6** vueltas del
banco completo en rojo, con `1,255×` contra el techo `1,250×`. Con el procedimiento nuevo —**6 series
intercaladas** en vez de 3 en bloque, más la **cláusula de convergencia**— **0 rojas de 9**, y el margen
al techo pasa de **0,3 %** a **10,4 %**. La abstención por convergencia **no se activó ni una vez** en 18
medidas reales: el caso **sigue midiendo**, no se ha convertido en un SKIP permanente. Y salió gratis:
6 series × k=4 son **las mismas llamadas al hook** que 3 × 8.

**El dominio nuevo, ejercido:** corpus de **320 entradas, 281 con UTF-8 inválido**; clasificación en una
sola pasada que evalúa la **heredada antes** que este árbol; medido **dentro 312 · fuera 8 · no
clasificables 0**, con la heredada incumpliendo **invariancia en 7 de 8** y determinismo en 0–1. Estable
en 9 corridas. Casos del banco **847 → 852**, con los tres literales actualizados a mano.

**DESVIACIÓN DECLARADA, y es la que importa: la guarda (c) de `CA-05` es insatisfacible tal como está
escrita.** `run.sh` **no imprime ni un byte** hasta que todas sus secciones terminan, así que la corrida
heredada matada por `timeout` deja **0 bytes siempre**, trabaje o no. Implementada al pie de la letra
convierte el único PASS de CA-05 (i) en **SKIP permanente** — verificado encendiendo la palanca. **Es la
misma clase que `ADR-004` acaba de diagnosticar en CA-01: una comprobación correcta sobre la señal
equivocada.** Se implementó la **intención** con la señal que sí discrimina —contar los casos escritos
*mientras* corría—: matada a los 12 s deja **37 casos**; una que no arranca deja **0**. **Pendiente de
write-back del analista**, porque el criterio nombra una señal que no existe.

**Aviso para la vuelta 2 de QA:** el patrón de exclusión de CA-02 (`REQ-017 CA-0`) **ya no basta** —los
tres casos de CA-10 dan FAIL contra v1.32.1 **por diseño**, que es su fail-before—; con `REQ-017 CA-`
cierra, y el inventario vuelve a dar **828 casos idénticos, md5 `31400a13e34f`**, el mismo de la vuelta 1.

Coste: 1 h 09 de reloj, ~340 k tokens **medidos del contador** (no estimados), ~30 min de máquina midiendo.

## [Interno] — 2026-09-07 · REQ-017: el dominio se traza por invariancia de locale, y ADR-004
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `analista-requerimientos`.

**El dominio de `CA-01` pasa de «donde la heredada es determinista» a «donde publica el mismo estado
bajo el locale del entorno Y bajo `LC_ALL=C`»** — determinismo **e** invariancia de locale. Y el
argumento es **de construcción**, no un ajuste hasta que el rojo desapareció: bajo `LC_ALL=C` la
heredada **es** la pregunta byte a byte («¿hay un CR que no sea el último byte?»), y este árbol la
implementa en **todos** los locales porque no elimina sufijo con patrón ⇒ **los dos árboles divergen
exactamente donde la heredada se aparta de su propia semántica**. El determinismo nunca fue esa
propiedad: era un síntoma del valor **intermedio**, y el criterio contrata sobre el **publicado**.

| | Dominio anterior | Dominio nuevo |
|---|---|---|
| Dentro y divergente (`CA-01` exige 0) | **6–7 de 106**, 4 de 4 → FALLA | **0** |
| Sujeto de `CA-10` (entradas fuera) | **0 en 3 de 4** → SKIP perpetuo | **≥ 7 en 4 de 4** |

**Y con la regla anti-coartada dentro del criterio:** el dominio se traza por una propiedad de la
**heredada sola**, clasificando **sin haber evaluado este árbol**. Un dominio definido como «donde los
dos coinciden» haría un criterio **incapaz de fallar**.

**`CA-08` (ii): lectura (a) —la varianza es del procedimiento— con un argumento que no era el de la
carga.** El estimando y el estimador **se contradicen**: en aislamiento la misma razón da
**0,821–1,010**, y un coste real **no puede ser negativo**; un recorrido de 0,821–1,443 sobre el mismo
estimando es **ruido del instrumento**. Y contra subir el techo: ponerlo por encima del ruido (≥ 1,5×)
**dejaría de ver la regresión de 10× para la que el criterio existe** — fijar el umbral por encima de
la resolución del instrumento. El techo **≤ 1,25× queda intacto**, con **cláusula de convergencia**
nueva: si `segundo mínimo / mínimo` de un árbol supera el propio techo —*un instrumento tiene que
resolver al menos el factor que vigila*— la sonda emite **SKIP citando sus dos razones**, nunca PASS ni
FAIL. No tapa una regresión real: **una regresión sube los dos mínimos del mismo árbol por igual; lo
que separa una serie de sí misma es el vecino.**

**`ADR-004`** registra el dominio como cambio **DE FONDO**, aceptando el dictamen de QA: la
clasificación «menor» de la vuelta 0 queda **revocada** — cambia el significado de `CA-01`, que es donde
el REQ define «equivalencia», y **la decisión nueva era justo la que salió mal**, tomada dentro de un
write-back donde nadie tenía que justificar la elección de la propiedad.

**Choque de numeración, resuelto y con su causa dicha:** REQ-021 tenía **reservado** `ADR-004` para un
archivo **que no existe**; el analista tomó el número **mirando el disco**. Se renumera el de REQ-021 a
`ADR-005` —`pendiente`, sin archivo que mover, referencias de texto— por la coordinadora, sin comisión.
**Causa raíz: el número de ADR no tiene asignador**, y «reparto de identificadores con reserva atómica»
llevaba en el backlog sin versión desde antes: acaba de cobrarse su **primera colisión real**.

## [Interno] — 2026-09-07 · Auditoría preventiva R-010 y su write-back: seis `contrato` antes de escribir código
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `auditor-seguridad`, `analista-requerimientos`.

**`Seguridad: preventiva (R-010)` en REQ-019 y REQ-021** —la excepción nombrada de §6, declarada al
emitirla y **sin cubrir el código posterior**—. Seis hallazgos `contrato` y uno `instrumento`, **todos
antes de que exista una línea**: con los dos REQ en `pendiente`, cada uno cuesta **una edición de
criterio y no una vuelta del bucle**.

**`SEC-031` — se puede perder el LÍMITE de una obligación sin borrar una letra.** El filtro de REQ-019
tiene dos cajones —lo que *manda* se queda, lo que *explica* se va— y una **acotación** («la cobertura
sobre `Bash` es parcial a propósito», «un hook muerto no deniega», «es una barandilla, no una jaula»)
**no ordena nada**, así que se delega **por construcción**. La tabla de §13, conservada byte a byte, es
**una lista de promesas de cobertura**: separada de su acotación, **lo escrito queda más fuerte que la
verdad**. El criterio de no-pérdida era asimétrico —prohibía **añadir** una obligación y no decía nada
de **restar** un límite—. Cerrado con `CA-14` nuevo: *una acotación no se separa de la promesa que
acota*; se delega la casuística, nunca el enunciado.

**Y el cruce de calendario que nadie había hecho:** `SEC-030` está abierto en esta misma ventana y su
remediación exige **añadir** el hueco del temporizador a §13. Si REQ-019 delega esa enumeración antes,
la declaración de un fail-open de la puerta de cierre **aterriza en un archivo que nadie lee por
defecto**. El write-back no lo resuelve ordenando —«un orden vive en la cabeza de quien despacha»— sino
por propiedad: CA-14 hace **los dos órdenes seguros**.

**Segundo cruce, encontrado al escribirlo:** `CA-02.1` exigía la tabla de §13 «idéntica **byte a byte**»
y `CA-04` lo mismo para la plantilla. La remediación de SEC-030 **añade** a las dos sedes → los dos
criterios habrían declarado **incumplido un trabajo ajeno y correcto**. Es la forma prohibida **(c)**
—igualdad donde corresponde dirección— sobre un criterio escrito con esa sección delante. CA-02.1 pasa
a prohibir **restar**; CA-04 pasa a ser propiedad de **autoría**, no de inmovilidad.

**`SEC-035` — el propio REQ-021 estrechaba la red que hoy existe.** Las sondas viven dentro del archivo
de sección, así que lo que dejan vivo *es* un job de ese shell y el corredor lo alcanza; convertirlas en
**programas invocados** deja lo que quede vivo **reparentado y fuera de la red**. La vigilancia se mudaba
del **juez** al **instrumento** — el artefacto que se decide no proteger — y no estaba dicho. Además el
criterio decía «ningún proceso **que ella lanzara**» cuando el incidente medido fue un **descendiente**:
declaraba conforme el caso que lo origina. Reescrito por **descendencia en cualquier nivel**, con
acreditación **con un nieto** y el plazo de arranque partido del derivado, porque la circularidad estaba
ahí.

**`SEC-036` — separación de funciones, y señala a la coordinadora.** Fuera de `codigo_app.globs`,
`guard-codigo` deja escribir `tests/util/` a **cualquier** agente, incluida la sesión que **acredita,
decide y publica** por delegación. Y la calibración **viajaba dentro del artefacto que certifica**. La
expectativa pasa al **juez** (`run.sh`), se contrata **identidad de camino** entre calibración y
medición, y el sustituto se acredita **por mutación de un tercero**.

**Consecuencia de despacho asumida:** REQ-019 declara ahora `requirements/REQ-*.md` —**21 de 21 REQ
citan `AGENTS.md`**— y por tanto **va en serie** con toda comisión que escriba en `requirements/`.
La alternativa del auditor (acotar el criterio en vez del mapa) queda escrita como **decisión del
propietario**, sin aplicar, porque reduce el ahorro que justifica el REQ.

## [Interno] — 2026-09-07 · QA vuelta 1 de REQ-017: tres criterios fallan, y se corrige lo que esta bitácora afirmó
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**`QA: con-hallazgos`, vuelta 1 de 3. Queda UNA vuelta antes del tope de `AGENTS.md` §6**, que no se
reinicia con cada hallazgo nuevo.

**CORRECCIÓN — esta bitácora afirmó, dos entradas más abajo, que bajo UTF-8 `${l%$'\r'}` «no devuelve un
sufijo sino basura distinta en cada evaluación de la misma entrada».** Medido ahora con corpus de **106
entradas multibyte inválidas** y k=6 evaluaciones en el mismo proceso: eso era cierto del valor
**intermedio**, y el criterio contrata sobre el **estado publicado** — y ahí **la heredada sí repite**.
La clase divergente real es otra: **la heredada no es invariante al locale** (7 de 106), y el no
determinismo es un fenómeno **distinto** (0–2 de 106) que **no coincide** con ella. REQ-017 sigue
cerrando un fallo en abierto de v1.32.1; lo que estaba mal era **qué fallo**.

**Y por eso `CA-01` vuelve a fallar, por una razón nueva: el dominio quedó trazado por la propiedad
equivocada.** Al definirlo como «las entradas donde la heredada es determinista», la clase divergente
cae **dentro** de CA-01 —que exige 0 divergencias— y deja a **`CA-10` sin sujeto**: en 3 de 4 corridas,
**cero** entradas cayeron fuera, así que CA-10 diría SKIP y no llegaría a PASS nunca.

**`CA-08` (ii) ya no roza el techo: lo cruza.** 26 medidas, **2 rojas** (1,252× y 1,443× contra 1,250×),
y **1 de cada 4 vueltas del banco completo en el modo de la puerta requerida** salió roja con `load`
0,91 al arrancar — la carga no lo explica. El procedimiento intercalado que el write-back contrató
**no se implementó**. Consecuencia dicha sin rodeos: **el banco no es estable**, y es la puerta
requerida de `main`.

**`CA-10` no tiene ni un caso en el banco**, y QA revoca su clasificación: **es cambio DE FONDO y pide
ADR**. El precedente de la pared de los 60 s no transporta —aquella se declaró **medida** y se dio a
otro dueño, así que ningún criterio podía fallar por ella—; CA-10 **se contrata como criterio** y
**cambia el significado de `CA-01`**, que es donde el REQ define qué quiere decir «equivalencia» (§9).
Y lo decisivo: **la decisión nueva es justo la que salió mal**, tomada dentro de un write-back
clasificado *menor*, donde nadie tenía que justificar la elección de la propiedad.

**Los dos hallazgos de la vuelta 0 están cerrados de verdad, reproducidos**: el sello que siempre
permite da ahora `SKIP … terminó EN ROJO (rc=1; 14 FAIL de 40 casos)` donde antes daba dos PASS, y el
hijo muerto a los 0,6 s da `SKIP … murió por la señal 9 a los 0,70 s de un plazo de 37 s` donde antes
decía `DEMOSTRADO`. **Sin sobre-corrección**, medidas las dos direcciones: el positivo real sigue en
PASS y la heredada que termina limpia dentro del plazo sigue en FAIL.

Coste: 1 h 35 de reloj, ~175 k tokens declarados (219–242 k con la corrección de subestimación).

## [Interno] — 2026-09-07 · Primer despacho paralelo real: tres comisiones, y el diseño del paralelismo
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agentes: `analista-requerimientos` ×2, `desarrollador`, coordinadora.

**Tres comisiones a la vez, y lo que lo hizo posible no fue la herramienta.** `tools/arnes-paralelo.sh`
habría dicho «colisiona» sobre cualquier par: **8 de los REQ abiertos declaran `CHANGELOG.md`** en
`Archivos:`. Se les retiró el libro mayor **y el commit**, y se les asignó un ámbito de archivos
exclusivo. Ahorro de la tanda: ~25 min sobre la serie.

**Write-back de los siete hallazgos de QA sobre REQ-017**, con el argumento que decide el REQ:
**`CA-01` no era exigente, era insatisfacible** — si la operación heredada devuelve basura distinta en
cada evaluación de la misma entrada, la igualdad byte a byte **no la cumple ni v1.32.1 consigo misma**.
Eso separa el estrechamiento de la coartada que `requirements/README.md` prohíbe. El dominio se define
**por propiedad medida en la corrida** (las entradas donde la heredada es determinista), no por lista
de locales ni de bytes. **CA-10** declara el fallo en abierto de v1.32.1 que este parche cierra, y
deliberadamente **no** afirma que cambie el veredicto de la puerta —QA midió que no cambia— ni contrata
el texto publicado fuera del dominio, porque se construye con la misma familia de operación que hace no
determinista a `arnes_norm_clave`. **CA-09 deja de acreditar magnitud alguna**: exige medición,
procedencia y **dispersión**, y contrata sólo la dirección, **pareada dentro de la misma corrida**.

**REQ-019 — adelgazar `AGENTS.md`**, con un criterio de no-pérdida mejor que el que pidió la
coordinadora: **el adelgazamiento es un MOVIMIENTO, no una reescritura** — todo bloque que sale aparece
**literalmente** en exactamente un destino declarado, cero sin localizar, de contrato. *No se puede
perder una regla que nadie borró*, y la reescritura es el mecanismo por el que se pierde; es además la
doctrina que el arnés ya se aplica en la rotación (*mueve; no resume*). Y el ahorro se mide como **peso
de gobierno de lectura obligatoria** con **dos vías a la vez** (≤ 0,60× **y** ≤ 2 documentos), porque
mover texto a un archivo igualmente obligatorio baja los bytes sin bajar el coste y repartirlo en muchos
**lo sube** — la familia exacta de la magnitud equivocada.

**`ADR-003` — la plantilla y la migración se quedan fuera de 1.33.0** (gate humano, aprobado por el
propietario el 2026-09-07). Motivo de mecanismo y no de tamaño: `arnes-upgrade` clasifica **por sección**
y **no tiene estado** para «la sección desapareció del destino» ⇒ `UNKNOWN` ⇒ **detiene la migración de
todos los proyectos**; y la delegación **crea archivos**, que esa skill tampoco sabe clasificar. Más el
argumento de coste: los ~9 000 tokens se pagan en los subagentes de **este** repositorio, así que
adelgazar la plantilla **no ahorra ni un token** de las comisiones de 1.34.0, que es para lo que se
adelantó la palanca. Divergencia acotada por dos invariantes comprobables, con dueño y vencimiento.

**Diseño del paralelismo escrito para 1.34.0** (`docs/PENDIENTES.md`, resumen en `docs/PLAN.md`), con
tres hallazgos que ninguna herramienta de archivos puede ver: la **colisión universal** del libro mayor;
**la máquina** como segunda dimensión de colisión —dos comisiones que miden se invalidan los números en
silencio, y la coordinadora lo hizo hoy con su propio despacho—; y que **dos agentes sobre el mismo
archivo en el mismo árbol no dan conflicto de fusión, dan escritura perdida**: git no protege de eso.
Más la regla completa del campo, en sus dos mitades: **declara exactamente el conjunto de escritura, ni
más ni menos** — de más fabrica colisiones falsas (barato e invisible), de menos fabrica `disjunto`
falsos (caro: escritura perdida).

## [Interno] — 2026-09-07 · QA de REQ-017: `con-hallazgos`, y se retira una cifra que publicamos como medida
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: `qa-tester` (Opus).

**Veredicto `QA: con-hallazgos`, vuelta 0 de 3.** Ocho de los nueve criterios PASS; banco `842 PASS ·
0 FAIL · 3 SKIP` en tres vueltas sin un caso flaky, y los tres SKIP verificados uno a uno —los dos de
CA-05 **sí miden al encenderlos** (PASS en 84,29 s), o sea que no son la clase de H-08—.

**Sólo bloquea uno, y es bueno: `QA-017-01` (`contrato`).** CA-01 promete que el comportamiento «no
cambia» para una línea cualquiera, y **hay contraejemplo reproducible**: bajo locale UTF-8,
`${l%$'\r'}` en bash 5.3.9 **no devuelve un sufijo sino basura distinta en cada evaluación de la misma
entrada**. La sentencia nueva es determinista y correcta ⇒ **REQ-017 cierra un fallo en abierto de
v1.32.1**, y eso hay que declararlo en el REQ como se declaró la pared de los 60 s. *(QA dice también
lo que no consiguió: no reprodujo una decisión distinta del guardián, porque la puerta recorre la
cabecera dos veces y el segundo recorrido lo cazaba.)*

**CORRECCIÓN — se retira la cifra «≈ 1,60 MB» publicada más abajo en esta misma bitácora
(`QA-017-05`).** La sonda de CA-09 **no repite**: seis corridas del mismo árbol dan 1,08 · 1,32 · 1,78 ·
2,64 · 2,65 · 3,98 MB. Las dos series que se creían discordantes —2,01 y 1,46— **no discrepan: son dos
extracciones de la misma distribución**. Causa: los tiempos base son **una sola muestra cada uno**
—contra la regla del mínimo de k que la propia sección enuncia—, y el exponente resultante va en el
**exponente** de la extrapolación. **La dirección del beneficio se sostiene 6 de 6; la magnitud, no.**
Dueño `SEC-030`. Lo cazó el endurecimiento que el analista había metido esa misma tarde —que cada cifra
nombre su corrida—: **se pagó a sí mismo en su primera validación.**

**Dos hallazgos que hacen mentir a la prueba, y por eso se arreglan ahora aunque sean `instrumento`:**
`QA-017-03` — CA-05 **concede PASS a un numerador que falló** (con los hooks sustituidos por un sello
que siempre permite, la sección sale en 14 FAIL y rc 1, el rc se descarta, el plazo cae a 16 s y las dos
mitades dan PASS, incluida la que se llama *«la comparación no se compra dejando de probar»*); y
`QA-017-04` — **`rc=137` no prueba vencimiento**: matar al hijo desde fuera a los 0,6 s de un plazo de
60 s devuelve 137 y el caso lo lee como demostrado; en un camino cuadrático el OOM kill es el modo de
muerte más probable. Sólo 124 prueba expiración.

**Escalado al auditor (`QA-017-07`):** `arnes_norm_clave`, **idéntica en los dos árboles**, devuelve una
clave **distinta en cada llamada con la misma entrada** bajo UTF-8 con un byte multibyte inválido al
principio de línea. Un lector no determinista dentro de un guardián. REQ-017 **reduce** la exposición y
no la introduce.

**Y lo que QA miró sin encontrar nada, que aquí cuenta como evidencia:** la equivalencia atacada de
cinco maneras —exhaustivo hasta longitud 3 sobre 21 símbolos con todos los metacaracteres de glob
(**9 724 entradas, 0 divergencias**), 40 000 aleatorias bajo dos locales × cinco combinaciones de
`shopt`, fronteras a escala, cadenas de 1–10 CR finales, los 255 bytes tras un CR—. La única familia
divergente es la de `QA-017-01`, **y ahí gana la implementación nueva**. Coste: 33 min de reloj,
~205 k tokens declarados (256–283 k con la corrección de subestimación).

## [Interno] — 2026-09-07 · La tarde del canal: nueve piezas de un proyecto consumidor, y una lección de clasificación
> Origen: Interno (manual) · usuario: Juan · modelo de IA: Opus 5 (1M context) · agente: coordinadora.

Intercambio largo con un proyecto consumidor por el canal entre sesiones, cada lado **ejecutando** con
control propio. Todo el material va a **1.34.0** salvo una pieza, que entra en la ventana en curso.
Detalle completo en `docs/PENDIENTES.md`; aquí lo que decide algo:

- **La regla del literal, y entra YA en el REQ de la palanca de 1.33.0:** *una igualdad entre dos
  magnitudes que pueden encogerse juntas no es una cota; hace falta un literal, y el literal **es** el
  control.* La encontraron mutando su propio guardián: con el corpus vacío, `comparadas === corpus.length`
  es `0 === 0` y da verde. Verificado aquí que el banco la cumple —`CASOS_ESPERADOS=845` es un literal
  tecleado— y que ese número, que parecía deuda, **es la pieza que delata el borrado de una sección entera**.
- **Y por eso el `845` NO se automatiza.** Ellos ya lo habían hecho y midieron el precio: su piso lleva
  **seis días** congelado (+28 archivos, +749 pruebas de hueco) porque el trinquete sólo sube sobre corrida
  válida y su suite está en rojo. Un literal falla **por desidia** y se ve; un derivado falla **porque una
  precondición dejó de cumplirse** y no se ve.
- **La palanca «¿esta prueba mide algo?» pasa de dos casos a cuatro**, y gana la mitad que le faltaba: el
  declarado tiene que estar acotado contra algo que no se mueva.
- **«Acreditado por mutación» tiene que decir POR QUIÉN.** Dos corpus, misma dirección: allí, la mutación
  de un tercero encontró el doble que la del autor; aquí, ninguno de los cuatro fallos en abierto de
  1.32.1 lo encontró quien escribió el código.
- **El borde de la familia del caso J es una lista de caracteres, no una propiedad**, y su corpus tiene
  25 líneas hoy inertes **sólo por su primer carácter**.
- **La ceguera del autoalojamiento, medida:** los 17 REQ de aquí declaran los cinco campos; allí, dos se
  omiten en 47 de 47. Un arreglo de «campo ausente ⇒ denegar» diseñado contra el corpus propio habría
  dejado a ese proyecto sin poder cerrar ni un REQ. Con su matiz, que corrige una entrada previa: un
  corpus externo sólo prueba en la dimensión en que es **indisciplinado**.
- **Nuestra promesa falsa viaja en la plantilla:** `templates/AGENTS.md.tpl:309` promete que no se cierra
  sin `QA: aprobado`, y medido: con el campo **ausente**, la puerta **permite**. Es el único de los cuatro
  campos cuya ausencia calla.
- **Dos correcciones firmadas de la coordinadora** (dije que dos cosas no estaban en su informe y sí
  estaban) y **una suya** (`Seguridad: n/a` sí está en nuestro vocabulario, verificado en tres archivos:
  no tienen nada que migrar).

**La lección que ordena las nueve, y es suya:** *un dato puede estar medido, ser correcto, y estar
clasificado en la categoría equivocada* — el `845` como deuda, el reparto de hallazgos como «el bucle
funciona», su piso congelado como «el trinquete ya funciona». **Ninguna se descubre midiendo mejor.** Se
descubren cuando alguien de fuera pregunta por otra cosa. El canal de informes deja de ser higiene y pasa
a ser el único instrumento que tenemos contra el error de clasificación.

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
