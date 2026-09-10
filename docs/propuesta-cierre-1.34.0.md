# Propuesta de cierre de 1.34.0 y evaluación de un parche 1.33.1

> **Versión base de toda cifra de este documento:** rama `rel/registro-1.33.0`, HEAD `7db3cfc`,
> 2026-09-10. `plugin.json` = `1.33.0`; el tag `v1.33.0` **existe** (`git tag --list 'v1.3*'`).
> PR #45: **borrador**, 90 commits.
> **Actualizado por TERCERA vez (2026-09-10, `af01436`) — y la cifra que publiqué dos veces no era
> firme.** La reconciliación del auditor (`R-028`,
> `docs/seguridad/reconciliacion-campos-2026-09-10.md`) da **33 bloqueantes sobre `b55347e` y 34 a
> partir de `R-028`**, no 17 ni 23. Mi `comm -23` reproducía los once **exacto**, pero leía el estado
> en la **cabecera de apertura** cuando el estado vigente es *la última declaración que nombra el
> hallazgo* —cabecera, sección `Estado: X → Y`, o **prosa sin encabezado**—: sobraban cinco y
> **faltaban cuatro**. Reparto de los 34: **21** los ve la puerta · **5** sólo en el registro **por
> diseño** · **4** sin REQ atribuible · **1** que debería estar en un campo · **2** discrepancias. Y
> la observación honesta del auditor: **bajo la frontera, 34 devuelve la decisión igual que 17**; lo
> que cambia es que ahora se puede **desmentir fila por fila**.
> **Actualizado por segunda vez (vuelta 3 de 3 de `REQ-017`, 2026-09-10, `f4a5f1f`):** `QA-017-24`
> quedó **cerrado** y en su lugar entró **`QA-017-31`** (`contrato`) — el mismo defecto **movido**, no
> desaparecido. El total sigue en **23**. `REQ-017` pasó a **`bloqueado`** por la salida de §6 y está
> escalado como **`D18`**; la cola subió a **16**. Y la misma comisión midió que **la prueba de
> `REQ-023 CA-09 (iii)` no acredita su criterio**: `FAIL → SKIP → PASS → PASS` sobre código idéntico,
> con el techo `1,000×` dentro del ruido del instrumento.
> **Actualizado tras el cierre de la comisión de QA de `REQ-017` (2026-09-10, sobre `86a44c8`):**
> el veredicto es `con-hallazgos` y aporta **un bloqueante nuevo**, `QA-017-24`. El recuento pasó de
> 22 a **23**. La entrada anterior (22) no se borra: queda aquí dicho de dónde a dónde se movió.
> **Método:** cada cifra se re-deriva con el comando que la acompaña. Ninguna medición nueva se
> tomó para este documento; no se abrió comisión de análisis.
> **Naturaleza:** propuesta de la coordinadora. No autoriza trabajo, ni acepta riesgo, ni publica.

---

## 0. Las tres cifras que gobiernan la decisión, y cómo se re-derivan

| Cifra | Valor | Cómo se re-deriva |
|---|---|---|
| Hallazgos abiertos declarados en los campos `Hallazgos abiertos:` de todos los REQ | **113** | recorrer `requirements/REQ-0*.md`, extraer el campo, `grep -oE '(SEC\|QA)-[0-9]+(-[0-9]+)*'`, `sort -u`, `wc -l` |
| De ésos, **bloqueantes** (`usuario/dinero` + `contrato`) | **23** (22 `contrato` + 1 `usuario/dinero`) — era 22 antes del veredicto de `REQ-017` | igual, pero conservando el `(clase)` que sigue a cada id y descartando `instrumento` |
| De ésos, `instrumento` — deuda, **no** bloquean el cierre (`AGENTS.md` §6) | **91** | idem, filtrando `instrumento` |

**Los 23, enumerados** (sin retirar ninguno):

| REQ | Ventana destino | Bloqueantes | n |
|---|---|---|---|
| `REQ-007` | 1.31.0 | `QA-114`, `QA-116`, `QA-117` | 3 |
| `REQ-013` | 1.32.0 | `SEC-014`, `SEC-020` | 2 |
| `REQ-017` | **1.34.0** | ~~`QA-017-24`~~ (CERRADO en la vuelta 3) → **`QA-017-31`** | 1 |
| `REQ-019` | 1.35.0 (aplazado) | `SEC-033` | 1 |
| `REQ-020` | **1.34.0** | `SEC-038`, `SEC-039`, `SEC-040`, `SEC-041`, `SEC-042`, `SEC-043`, `SEC-044`, `SEC-045` | **8** |
| `REQ-021` | **1.34.0** | `QA-021-10`, `QA-021-11` | 2 |
| `REQ-024` | **1.34.0** | `QA-024-19`, `SEC-083`, `SEC-084` | 3 |
| `REQ-026` | **1.34.0** | `SEC-067` (`usuario/dinero`), `SEC-072`, `SEC-073` | 3 |

Los **ocho de `REQ-020`** son el **35 %** de 23 (8 ÷ 23 = 0,348) — eran el **36 %** de 22
(8 ÷ 22 = 0,364), y esa cifra sigue siendo la correcta para el recuento con el que se enunció.
**17 de los 23** están en la ventana 1.34.0; **6** arrastran de ventanas ya publicadas (1.31.0,
1.32.0) o posteriores (1.35.0).

### 0.b Un desfase medido que hay que reconciliar antes de dar por firme cualquier recuento

`guard-completado` lee **el campo del REQ**, no el registro de seguridad. Hay **once** hallazgos
`contrato` en estado **`abierto`** en `docs/seguridad/registro-seguridad.md` que **ningún** campo
`Hallazgos abiertos:` declara — la puerta no los puede ver:

`SEC-031`, `SEC-032`, `SEC-034` (→ `REQ-019`, 1.35.0) · `SEC-035`, `SEC-036`, `SEC-054`
(→ `REQ-021`, **1.34.0**) · `SEC-050`, `SEC-082` (→ `REQ-016`) · `SEC-052` (→ `REQ-023`,
**1.34.0**) · `SEC-053`, `SEC-055` (sin REQ en su cabecera).

*Re-derivación:* `comm -23` entre los ids de cabecera `` `contrato` · **abierto** `` del registro y
los ids de los campos de REQ.

**Seis** de esos once tocan la ventana 1.34.0. Es la **misma familia** que `SEC-073`: *la máquina
lee como completo un inventario que es parcial*, esta vez aplicada a la cola misma. **No lo
resuelvo yo:** el registro es del `auditor-seguridad` y el campo del `analista-requerimientos`.
Consecuencia honesta: **el recuento de bloqueantes de 1.34.0 es 16 según los campos y hasta 22
según el registro**, y no hay base para elegir uno sin esa reconciliación.

---

## 1. Los 23 no son 23 arreglos: siete causas

Cada hallazgo se asigna a **exactamente una** causa; ninguno se retira. La suma es 23.

| # | Causa | Hallazgos | n | Vector de arreglo |
|---|---|---|---|---|
| **C1** | **El criterio contrata un mecanismo o una lista donde debe enunciar una propiedad.** «Hace falta un literal, y el literal *es* el control» nombra una implementación admisible, no la propiedad; se puede satisfacer sin proteger y se puede incumplir protegiendo. | `SEC-038`, `SEC-040`, `SEC-044`, `QA-021-10` | 4 | Re-enunciar **por propiedad**, con la doctrina que `ADR-011` ya fija («por acto, no por puerta»). Un solo write-back cubre los cuatro. |
| **C2** | **La promesa se escribe absoluta y su excepción vive fuera del criterio.** El texto heredado queda **más fuerte que la verdad**. | `SEC-041`, `SEC-072`, `SEC-033`, `QA-116`, `QA-117`, **`QA-017-24`** | 6 | Hacer **condicional la promesa principal** en su propia sede, con control negativo falsable. Añadir «no exhaustiva» **no basta** si la promesa principal sigue absoluta. |
| **C3** | **El grano del contrato no es el grano del control** (pasadas vs. líneas). | `SEC-043` | 1 | Corregir la magnitud del criterio. |
| **C4** | **El control se calibra o se juzga con la cifra del artefacto que vigila.** Un techo calibrado con el número que su propio ABORT imprime no acota nada. | `SEC-039`, `QA-114` | 2 | Externalizar el término de calibración; margen que discrimine. |
| **C5** | **La misma regla transcrita en dos sedes, y ya divergen → fail-open del lector.** Dos transcripciones se desfasan; el desfase se lee como conformidad. | `SEC-042`, `SEC-020`, `SEC-014`, `SEC-083`, `SEC-084` | 5 | **Una sola sede de lectura**, y las demás la llaman. Es el vector que ya cerró `SEC-083` en código. |
| **C6** | **El mapa declara menos de lo que los criterios obligan / falta custodia.** `tests/` no está en `codigo_app.globs`: quien escribe el control, quien lo acredita y quien publica pueden ser el mismo actor. | `SEC-034`→(1.35.0), `SEC-045` | 1 (+1 fuera de ventana) | `SEC-045` es **gobernanza, no código**: su remedio es una decisión del propietario sobre custodia, no un parche. |
| **C7** | **Una aprobación o un inventario PARCIAL se lee como COMPLETO; o el write-back falta.** | `SEC-073`, `SEC-067`, `QA-024-19`, `QA-021-11` | 4 | Fail-closed en el lector (`SEC-073`) + write-back (`SEC-067`, `QA-021-11`). |

`QA-017-24` entra en **C2** con su forma más pura, y por eso importa: `CA-03` **se contradice a sí
mismo** —un párrafo manda declarar la cota en toda abstención, y el párrafo que enumera lo publicado
no la incluye—, así que **cuál de las dos lecturas vale decide si hay que tocar código o sólo texto**.
Es el mismo defecto que D5 nombró: *añadir un matiz no basta si la promesa principal sigue absoluta*.

**Conclusión operativa:** 23 hallazgos ⇒ **7 vectores de arreglo**, de los cuales **C1, C2 y C5
concentran 15** (65 %). C5 y C7 son código; C1, C2, C3, C4 son contrato (write-back del analista);
C6 es una decisión de gobernanza del propietario.

---

## 2. El parche 1.33.1 — los dos defectos que están en lo PUBLICADO

Ambos viven en `hooks/guard-completado.sh`. Los dos son de la causa **C5**.

### 2.a Las tres cosas que hay que separar, y que no son la misma

| | `QA-016-04` (D16) | `SEC-084` (D17) |
|---|---|---|
| **Defecto reproducido** | **Sí.** Un `Rigor:` no reconocido —p. ej. `critico (por suelo)`, forma que la **propia convención de `AGENTS.md` §13** autoriza («un matiz va entre paréntesis»)— cae **ABIERTO** a `estandar` **en silencio**: ni deniega ni avisa. Reproducido en cuatro árboles, **incluida la copia instalada de `v1.33.0`**. | **Sí.** `_Seguridad_: aprobado` (decorado) cuela una firma por delante de `QA: pendiente` en los dos estados clave, **sin deny y sin aviso**. Reproducido en cuatro árboles, **incluida la copia instalada de `v1.33.0`**. La causa: el disparador es `grep -q 'Seguridad:'` —**literal**—, mientras `CA-04` **exige** tolerar la decoración. Una guarda la tolera, la otra no. |
| **Exposición observada** | **Un** consumidor verificado: **este repositorio**, cuyos hooks corren la instalación estable 1.33.0. Nada más está comprobado. | Igual: **este repositorio**, y sólo él. |
| **Uso histórico no comprobado** | Que otros proyectos corran 1.33.0 descansa en **la afirmación de `AGENTS.md`** («lo usan proyectos reales»), **no** en una comprobación. **No hay base** para estimar cuántas firmas se emitieron bajo el defecto, ni si alguna lo aprovechó. No se afirma que haya ocurrido; tampoco que no. | Idem. Además: un `Rigor` degradado a `estandar` **deja de exigir `Seguridad: aprobado`**, así que el efecto de `QA-016-04` y el de `SEC-084` **se componen**: uno retira la exigencia de firma, el otro cuela la firma. Que esa composición se haya materializado **no está comprobado**. |

### 2.b Cambio mínimo propuesto

| | Cambio mínimo | Por qué es mínimo |
|---|---|---|
| `SEC-084` | Enrutar el **disparador** por el mismo lector de campo decorado que ya usa el resto de la guarda, en lugar del `grep -q 'Seguridad:'` literal. | Es exactamente el vector C5: **no** añade una segunda transcripción, retira una. El lector ya existe y ya está probado. |
| `QA-016-04` | Hacer **fail-closed** el rigor no reconocido: un valor fuera del vocabulario **no cae a `estandar`** — deniega citando la línea, o cae a `critico`. | Coherente con la doctrina del repositorio («una puerta que no puede medir no deja pasar») y con el suelo de §6, que ya dice que el rigor se sube y no se baja. |

**¿Se pueden corregir juntos?** **Sí**, y conviene: misma sede, misma causa (C5), un solo gate de
`hooks/`, un solo CI, un solo tag.

**¿Sin arrastrar la rama de 1.34.0?** **Sí, pero sólo si se corta del tag.** `rel/registro-1.33.0`
lleva **90 commits** de trabajo de 1.34.0 sin acreditar (incluido `29b06eb`, comiteado
explícitamente «*para mover de máquina, no por estar validado*»). El parche debe salir de una rama
**`hotfix/1.33.1` cortada de `v1.33.0`**, no de la rama actual. Cortarlo de la rama actual publicaría
1.34.0 entera bajo la etiqueta de un parche.

### 2.c Pruebas necesarias

1. **Fail-before / pass-after por defecto, por separado** — cuatro corridas, no dos.
2. **Un caso por cada forma que la convención autoriza**: `Rigor: critico (por suelo)`,
   `_Seguridad_: aprobado`, y el par sin decorar como control.
3. **El control negativo del fail-closed**: un rigor no reconocido debe **denegar**; si el caso pasa
   con el arreglo *y* sin él, no discrimina y no vale.
4. **Cuadre del banco**: los casos nuevos suben `CASOS_ESPERADOS` (hoy **1024**); la corrida debe
   cuadrar, y el `SKIP` se compara **por lista, nunca por total**.
5. **El banco completo en CI (`hooks-en-linux`)**, que es la puerta requerida de `main`.

### 2.d Coste

Implementación y pruebas: **acotado y pequeño** (una sede, dos ramas de código, ~6 casos nuevos).
El resto del coste **no es de implementación**: gate humano de `hooks/` (§4), PR, CI, fusión, tag,
publicación y actualización de la instalación estable. **No estimo horas de reloj:** las cifras de
duración de este repositorio están medidas en máquinas distintas y con dispersión no acotada, y no
hay base para una estimación honesta.

---

## 3. Lo que falta realmente para 1.34.0

| REQ | Estado medido | Implementación | QA | Seguridad | Migración / cierre |
|---|---|---|---|---|---|
| `REQ-017` | **`bloqueado`** (2026-09-10, salida de §6: **vuelta 3 de 3 agotada** con un `contrato` abierto) · escalado como **`D18`** | hecha; ningún código cambió entre `86a44c8` y `f4a5f1f` —verificado vacío en `hooks/ tools/ tests/ .github/ .arnes/ templates/ .claude-plugin/` | **3 vueltas gastadas.** `QA-017-24` **cerrado**; entra **`QA-017-31`** (`contrato`): `CA-03` afirma en absoluto que toda abstención publica su máquina y declara **cumplida** una mitad de `SEC-064` que `CA-08 (ii)` declara **abierta**. La medición da la razón a `CA-08`. Remedio: **una** cláusula, sin código | **el auditor tiene que volver de todas formas**: su `aprobado` es del 2026-09-08 sobre `538c266` | `D18` opción (A): cláusula acotada + re-validación **fuera del contador** de §6 |
| `REQ-020` | **`pendiente`** · `QA: pendiente` · `Seguridad: preventiva` (no cubre código) | **NO IMPLEMENTADO.** La línea `Acredita:` que sus criterios contratan existe en **0 de 63** secciones (`grep -lE 'Acredita:' tests/escenarios/hooks/secciones/*.sh \| wc -l`) | todo | auditoría real (la `preventiva` **no** cubre el código posterior) | 8 bloqueantes = **36 %** de los 22 |
| `REQ-021` | `bloqueado` · QA `con-hallazgos` **vuelta 3 de 3 AGOTADA** · `Seguridad: preventiva` | correcciones de `QA-021-10/-11` | re-validación | auditoría real | + `SEC-035`, `SEC-036`, `SEC-054` abiertos en el registro y **no** en su campo (§0.b) |
| `REQ-023` | `bloqueado` · `QA: aprobado` · `Seguridad: aprobado` · **cero bloqueantes en el campo** | — | **`CA-09 (iii)` NO está acreditado, y ahora está medido:** su prueba da `FAIL → SKIP → PASS → PASS` sobre **código idéntico**, siguiendo la carga de la máquina, con el techo `1,000×` **dentro del ruido del instrumento**. El `FAIL` del banco **no es regresión**; y una prueba que oscila **no acredita nada, ni cuando sale PASS**. Ver `D18` (b) | — | **El cero del campo NO resuelve `D13`:** `CA-11` es **falso** sobre este árbol y **dos firmas verdes lo cubren**. Un campo vacío no acredita un criterio que dejó de ser cierto. Además `SEC-052` está abierto en el registro y no en su campo. |
| `REQ-024` | `bloqueado` · QA `con-hallazgos` **vuelta 3 de 3 AGOTADA** · **`Seguridad: pendiente`** | `QA-024-19`, `SEC-083` (write-back), `SEC-084`; la fila prescrita en `:889` es **falsa**; `CA-03` fila 3 dice `EJECUTADA, NO ACREDITADA` | re-validación acotada | **la auditoría nunca se hizo** | write-back de `CA-12` en la **misma** comisión (no espera la firma) |
| `REQ-026` | `en-revisión` · `QA: aprobado` **con alcance** · `Seguridad: con-hallazgos` | ver desglose abajo. **`SEC-067` tiene ya su write-back** (`NFR-026-01`, 2026-09-10) y **sigue abierto**: es `usuario/dinero` y su cierre no depende de texto | re-validación de lo que se corrija | R-022 dejó hallazgos; el cierre de `SEC-067` **lo decide el auditor** y pasa por `SEC-072` | **No cierra sin la decisión 6.** `ADR-008` está en `propuesta` |
| `REQ-027` | `completado` | — | — | — | — |

### 3.b `REQ-026`, sin resumirlo como «redacción» — son tres cosas distintas

1. **Garantías incumplidas (la máquina hace algo distinto de lo prometido):**
   - `SEC-073` · `contrato` · **alta** — *«la máquina lee una aprobación **PARCIAL** como aprobación
     **COMPLETA**»*. Es un defecto de lectura, no de texto.
   - `SEC-067` · **`usuario/dinero`** · alta · **`en-mitigación`** — *«la rotación reescribe el
     documento **ENTERO** desde una lectura previa, sin comprobar si cambió: una firma que caiga en
     esa ventana **se pierde en silencio**»*. El **código está acreditado**; falta el **write-back**.
2. **Criterios sin implementar** (declarados fuera de ventana en el propio campo `QA:`):
   **`CA-13`, `CA-14`, `CA-16`, `CA-17`**. No son texto pendiente: son criterios contratados y no
   construidos. `CA-13` (la declaración en el manifiesto) es además el que *enciende la rotación*.
> **Y el hallazgo del 2026-09-10 que reordena el resto:** el write-back de `SEC-067` está hecho
> (`NFR-026-01`, con el residual declarado y sus tres campos, y con la lectura no medida del auditor
> —«de microsegundos a pocos milisegundos»— **atribuida, marcada como no medida y sin fundar ningún
> umbral**). Pero **`SEC-067` no puede cerrarse por ningún write-back**: su condición exacta de
> cierre pasa por `SEC-072`. La consecuencia práctica es que el punto 3 de abajo **no es el último
> de la lista: es la puerta de los tres**.

3. **Contrato mal enunciado —y esto tampoco es «redacción»:** `SEC-072` · `contrato` · media —
   *«dos promesas escritas en absoluto cuya excepción vive fuera del criterio»*. Lo que queda escrito
   es **más fuerte que la verdad**; se hereda así a cada proyecto.

---

## 4. La cola consolidada: dieciséis entradas, **seis** decisiones

Ninguna entrada se borra ni se funde en el archivo: `PENDING_APPROVAL.md` conserva D2–D17 con su
texto y su trazabilidad. Esta sección dice **cuáles se resuelven juntas**.

**Informativas — no necesitan firma.** `D6` (mi diagnóstico de `k=1` era falso en su mecanismo; ya
corregido y decidido bajo delegación) · `D9` (dos preguntas al analista: es trabajo, no decisión) ·
`D10` (`SEC-083`: el trabajo ya fue).

> **Corrección de esta misma sección, el 2026-09-10: `D3` NO es informativa, y clasificarla así fue
> un error mío.** Lo escribí como «ya instruiste que no se cierran por redacción — queda como trabajo
> autorizado». Tu instrucción es una **prohibición**, no una resolución: dice cómo **no** se cierran,
> no qué se hace con ellos. Y el write-back de `SEC-067` acaba de demostrar que está en la **ruta
> crítica** de la versión. Es la **decisión 6**.

**Ya resueltas.** `D1` y `D5` están en `## Resueltas`. `D5` opción (a) se aplicó con tu
refinamiento —«*añadir solamente «no exhaustiva» no basta si la promesa principal sigue siendo
absoluta*»— convertido en un control negativo falsable dentro de `CA-10`.

### Las seis que sí requieren tu firma

| # | Qué recomiendo autorizar | Qué cambia | Trabajo que queda después | Riesgo o incumplimiento que **permanece** |
|---|---|---|---|---|
| **1**<br>*(agrupa `D2`, `D4`)* | **Mover `REQ-020` a la ventana 1.35.0**, sin retirar ninguno de sus 8 hallazgos y dejando escrito que se mueve por **segunda** vez (1.33.0 → 1.34.0 → 1.35.0). | Los bloqueantes de la ventana 1.34.0 caen de **17 a 9**. `REQ-020` conserva `Estado: pendiente` y sus 8 `contrato` abiertos. **No se retira ni se reclasifica ningún hallazgo.** | Implementar `Acredita:` en las **63** secciones, QA completo, y **auditoría real** — la `Seguridad: preventiva` (R-011) **no cubre** el código posterior. Todo en 1.35.0. | 1.34.0 se publica **sin el control que decide si las pruebas miden**. `Acredita:` sigue en **0/63**, y `SEC-045` sigue abierto: quien escribe el control, quien lo acredita y quien publica **pueden ser el mismo actor**, porque `tests/` no está en `codigo_app.globs`. |
| **2**<br>*(agrupa `D16`, `D17`)* | **Implementar** el parche de los dos defectos publicados en una rama `hotfix/1.33.1` **cortada del tag `v1.33.0`**, con las cinco pruebas de §2.c. **Esto no autoriza publicarlo:** el tag es una segunda firma. | Los dos fail-open dejan de estar en el árbol de trabajo del parche: el que cuela una firma del auditor por delante de `QA: pendiente`, y el que degrada un `Rigor:` no reconocido a `estandar` en silencio. | Gate humano de `hooks/` (§4), PR, CI `hooks-en-linux`, fusión, tag `v1.33.1`, publicación, actualizar la instalación estable, y **portar el mismo arreglo a 1.34.0**. | **No hay base** para saber si el defecto se usó históricamente, y el parche **no lo averigua**. Y el fail-closed del rigor **cambia conducta heredada**: un proyecto instalado que escriba `critico (por suelo)` —forma que `AGENTS.md` §13 **autoriza**— pasará a ver una denegación donde hoy pasa. Es la forma de `D12`, aplicada a lo ya distribuido. |
| **3**<br>*(agrupa `D11`, `D12`, `D13` y el `Seguridad:` de `REQ-017`)* | **Una sola regla para los verdes que ya no cubren su árbol:** un `aprobado` cuyo criterio cambió, o cuyo árbol cambió, **se declara sustituido en su propio campo** (no se borra), y el REQ no cierra hasta re-firmar. Con ello: ratificar **`ADR-011`** (parte (a) de `D11`), **corregir la fila de §13 que `D11` autorizó y que hoy es FALSA** —anuncia un fail-open que la salida (b) retiró—, y aceptar el precio de la salida (b) de `CA-12` que `D12` describe. | Dos contradicciones silenciosas se vuelven visibles: `REQ-023` (`CA-11` es falso sobre este árbol y **dos firmas verdes lo cubren**) y `REQ-017` (`Seguridad: aprobado` del **2026-09-08 sobre `538c266`**, un árbol anterior al modo que se acaba de medir). | Re-firmar `REQ-017` (auditor, **después** del write-back de `QA-017-24`); resolver `CA-11` de `REQ-023`; corregir la fila de §13; `ADR-011` pasa de `propuesta` a aceptada. | Un proyecto que **no ha migrado nada** verá una denegación nueva en un acto que **no es el cierre** (`D12`). Y mientras `ADR-011` siga `propuesta`, la doctrina que sostiene C1 no tiene gate. |
| **4**<br>*(agrupa `D13`, `D14`)* | **`REQ-023` y `REQ-024` siguen `bloqueado`** —no cierran con residual— y autorizas una **cuarta vuelta ACOTADA**, sólo para: write-back de `CA-11`, `QA-024-19`, `SEC-083`, `SEC-084` y **la auditoría de `REQ-024` que nunca se hizo** (`Seguridad: pendiente`). El rastro de las tres vueltas se conserva. | El trabajo se desbloquea **sin fingir** que el tope de §6 no se agotó. | QA acotado a lo corregido; auditoría completa de `REQ-024`; write-back del analista. | **Se pasa del tope de tres vueltas de §6 por decisión expresa tuya.** Queda escrito como excepción nombrada y fechada, no como reinterpretación de la regla — que es la única forma en que §6 admite pasarlo. |
| **6**<br>*(agrupa `D3`, `SEC-067` y el gate de `ADR-008`)* | **Decidir la excepción de las garantías absolutas de `REQ-026`**: firmar la vía **A** de `ADR-008` —que hoy está en `propuesta`— o encargar la vía **B** (código, dueño `desarrollador`). Lo que **no** es una opción es cerrarlos por redacción, y eso ya lo instruiste. | Desbloquea lo único que impide cerrar `REQ-026`. **`SEC-067` es `usuario/dinero` y BLOQUEA**, y su *condición exacta de cierre* —literal del registro, `:6367-6368`— es que la tolerancia de la ventana de publicar viva **dentro** de `CA-18 (i)` y la excepción de la publicación a medias esté declarada en `CA-05`: «**Nada más**». Eso **es** el write-back de `SEC-072`. | Vía A: el write-back del analista y la re-validación de QA. Vía B: código del `desarrollador` + QA + auditoría, y es la cadena larga. | **Ningún write-back que un analista pueda escribir cierra `SEC-067`** — quedó demostrado y escrito en `NFR-026-01 (6)`. Y **la precondición de la vía A es hoy inalcanzable**: exige medir el intervalo residual, con el instrumento **no convergente**, `REQ-021` **`bloqueado`** y la investigación **prohibida** por tu propia acotación de alcance. Si no firmás ni encargás la vía B, **`REQ-026` no cierra en 1.34.0**, y no por falta de trabajo. |
| **5**<br>*(agrupa `D7`, `D8`, `D15`)* | **Poner el manifiesto en regla:** ratificar **o** revertir `campos.ausencia_exige: false`, que **comiteé en `119e853` sin su gate** —el fallo es mío y `ADR-009:3` declara ese gate pendiente—; dejar **apagado** `veredictos.caducan_con_codigo`; y firmar el gate **previo** de `REQ-024 CA-04`, que la delegación de 24 h **no** cubre. | El manifiesto deja de tener un cambio sin gate. `REQ-024 CA-04` puede avanzar. | Si revierte: el `desarrollador` lo cambia y el banco se re-corre entero. Si ratifica: se anota el gate a posteriori con su fecha. | **`veredictos.caducan_con_codigo` debe seguir apagado, y el motivo es medido:** la comparación es a **resolución de día**, así que es **ciega el mismo día**, y **28 de 29** veredictos vigentes expirarían al encenderla. Si se ratifica `ausencia_exige`, queda el **precedente** de un manifiesto cambiado antes de su gate. |

### Lo que **no** es una decisión tuya, y por eso no está en la tabla

- **La reconciliación de §0.b** (once `contrato` abiertos en el registro que ningún campo declara).
  Es trabajo del `auditor-seguridad` (el registro) y del `analista-requerimientos` (el campo).
- **El write-back de `QA-017-24`** — pero **con una salvedad que sí puede volver a ti**: `CA-03` se
  contradice, y **cuál de sus dos lecturas vale decide si hay que tocar código o sólo texto**. Si el
  analista concluye que vale la lectura que obliga a publicar la cota, el arreglo es de **código** y
  entra en el coste de 1.34.0.
- **Actualizar `docs/PLAN.md` y el PR #45** con la evidencia vigente: coordinación.

---

## 5. Las autorizaciones que pido, separadas por naturaleza

**A. Autorizar trabajo** (no acepta riesgo ni publica nada):
0. **`D18`, opción (A)** — la cláusula acotada de `QA-017-31` y su re-validación **fuera del
   contador** de §6. `REQ-017` está **`bloqueado`** hasta que la firmes; §6 me prohíbe expresamente
   reclasificarla como errata editorial, y por eso no lo hice.
1. Decisión **1** — mover `REQ-020` a 1.35.0.
2. Decisión **2**, sólo la parte de **implementar** el parche en `hotfix/1.33.1`.
3. Decisión **4** — la cuarta vuelta acotada de `REQ-023`/`REQ-024` + la auditoría de `REQ-024`.
4. Decisión **3** — la regla del verde sustituido, y `ADR-011`.
5. Decisión **6** — la vía A o la vía B de `ADR-008`. **Es la única de las seis sin la cual una
   ventana entera no cierra**, y no por falta de trabajo.
6. ~~El write-back de `QA-017-24`~~ **HECHO** (`a139155`, `f4a5f1f`) y el de `SEC-067` **HECHO**
   (`NFR-026-01`); la reconciliación de §0.b está **en curso** con el auditor.

**B. Aceptar riesgos** (cada uno queda escrito con dueño y forzador):
1. 1.34.0 se publica **sin** `REQ-020`: sin acreditación por sección y sin custodia de `tests/`
   (`SEC-045`).
2. El precio de `D12`: una denegación nueva para un proyecto sin migrar, en un acto que no es el
   cierre.
3. El fail-closed del rigor **cambia conducta heredada** en proyectos instalados (§2.b).
4. Pasar del tope de tres vueltas de §6 en `REQ-023` y `REQ-024`, como excepción nombrada — y, con
   `D18`, también en `REQ-017`.
5. **Que la precondición de la vía A de `ADR-008` es hoy inalcanzable** y que firmarla significa
   aceptar la excepción **sin** el intervalo residual medido. Es una aceptación de riesgo real, no
   un trámite: el instrumento no converge, `REQ-021` está `bloqueado` y medirlo está fuera del
   alcance que autorizaste.

**C. Autorizar publicación** — **no la pido hoy, ninguna de las dos:**
1. Tag `v1.33.1` y actualización de la instalación estable. Se pide **después** de CI verde.
2. Tag `v1.34.0`. Se pide cuando los bloqueantes de la ventana estén resueltos o con residual
   firmado.

### Estimaciones

**No doy horas de reloj, y el motivo está medido:** las cifras de duración de este repositorio se
tomaron en máquinas distintas con dispersión no acotada —QA acaba de reportar que **esta máquina no
es el runner** (12 núcleos contra 4 vCPU) y que **no reprodujo el `2,329×` del CI**—, así que
cualquier número de horas sería una hipótesis presentada como compromiso (§14.B.2). Lo que **sí**
puedo acotar, y es lo que gobierna el coste:

| Trabajo | Unidad medida | Base |
|---|---|---|
| Parche 1.33.1 | **1** sede (`hooks/guard-completado.sh`), **2** ramas de código, **~6** casos nuevos de banco | §2.b, §2.c |
| `REQ-020` completo | **63** secciones a instrumentar (`Acredita:` hoy en 0), **8** hallazgos, QA completo + auditoría real | `ls secciones/*.sh` = 63 |
| `REQ-024` | **3** bloqueantes + **1** auditoría que nunca se hizo + write-back de `CA-12` | cabecera del REQ |
| `REQ-026` | **2** garantías incumplidas + **4** criterios sin implementar (`CA-13/14/16/17`) + **1** re-enunciado | campo `QA:` del REQ |
| `REQ-017` | **1** bloqueante (`QA-017-24`) + **7** `instrumento` + **1** re-firma del auditor | `docs/qa/1.34.0.md` |
| Reconciliación §0.b | **11** hallazgos a reconciliar entre dos documentos | `comm -23` |

**Trabajo posterior a tu firma, que no se ve en la tabla:** cada decisión de arriba arrastra QA
acotado + auditoría cuando toca `hooks/` + CI + gate humano. Ninguna termina en la firma.

---

## 6. Orden recomendado

1. **`REQ-017`: QA CERRADO** (2026-09-10, `con-hallazgos` sobre `86a44c8`). Sigue el **write-back de
   `QA-017-24`** por el analista, que además debe resolver **cuál de las dos lecturas de `CA-03`
   vale** — de eso depende que el arreglo sea de código o de texto. El auditor **después**, no antes.
2. **Reconciliar registro ↔ campos** (§0.b) — sin esto ningún recuento de cierre es firme. Es
   trabajo del auditor y del analista, **no** una decisión tuya.
3. **Decidir la ventana de `REQ-020`** (decisión **1** abajo). Es la palanca de mayor efecto: mueve
   36 % de los bloqueantes sin retirar un solo hallazgo.
4. **El parche `1.33.1`** desde `v1.33.0` (decisión **2**), en paralelo real: rama distinta, sede
   distinta, no toca nada de 1.34.0.
5. **`REQ-024`**: correcciones → QA acotado → **la auditoría que nunca se hizo**.
6. **`REQ-026`**: reordenado el 2026-09-10 con lo medido. `SEC-067` **ya tiene su write-back**; lo
   que manda ahora es la **decisión 6** (`SEC-072` / `ADR-008`), porque de ella cuelga el cierre de
   `SEC-067`. Después `SEC-073` (código). **Sin la decisión 6, este REQ no cierra**, y ningún trabajo
   adicional lo cambia.
7. **`REQ-021`** y **`REQ-023`/`D13`** — dependen de la decisión **3**.
8. **Cierre de versión**: CI verde, `SKIP` explicados por lista, fusión, tag, publicación.

---

## 7. Candidato a hallazgo, encontrado el 2026-09-10 y NO abierto

`hooks/rotar-artefactos.sh:651` conserva en un comentario la cifra **no medida** —*«la medida era de
355-361 ms y lo que queda es de microsegundos»*— que ya fue **retirada del REQ** por instrucción del
propietario del 2026-09-09, precisamente por no estar medida. Sigue viva en el código.

Lo dejo aquí y **no lo abrí**, por tres razones: es archivo del `desarrollador`; abrir hallazgos es de
QA o del auditor, no de la coordinadora; y §14.B.4 dice **corregir sin ampliar**. Clase probable:
`instrumento` (deriva de documentación), que **no** bloquearía. Queda en disco para que la comisión
que toque ese archivo no tenga que volver a encontrarlo.

*Verificado:* `sed -n '651p' hooks/rotar-artefactos.sh` sobre `b55347e`.

---

## 8. La rotación se aplaza — qué se aplaza, qué se publica y qué queda vivo

Instrucción del propietario: mantener la rotación **apagada** y preparar su aplazamiento explícito,
**sin** encargar otro párrafo ni otro NFR para intentar cerrar `SEC-067`. Nada de esta sección cambia
garantías, cierra hallazgos, retira código ni publica.

### 8.a Qué parte de `REQ-026` se aplazaría

**Los cuatro criterios que ya están declarados sin implementar**, en su propio campo `QA:`
(*«alcance CA-01..CA-12, CA-15 y CA-18 — CA-13/14/16/17 sin implementar, fuera de ventana»*):
**`CA-13`, `CA-14`, `CA-16`, `CA-17`**.

`CA-13` es el que importa: es **la declaración en el manifiesto**, es decir **lo que enciende la
rotación**. Aplazarlo y dejar `rotacion.activo: false` con `artefactos: []` son la misma decisión
vista desde dos sitios.

### 8.b Qué código se publica en 1.34.0, y en qué estado

| Artefacto | Tamaño | Estado al publicar |
|---|---|---|
| `hooks/rotar-artefactos.sh` | **788 líneas** | se publica; el manifiesto lo lee (`rotacion.activo`, `hooks/rotar-artefactos.sh:739`) y llega **con `activo: false`** |
| `hooks/estado-derivado.sh` | **446 líneas** | se publica **activo** (`estado_derivado.activo: true`) — es el bloque de continuidad, no la rotación |
| Banco: `21-rotacion-de-artefactos.sh`, `28-rotacion-seccion-1..4` | 5 secciones | se publican y corren en CI |

**Precisión de estado, porque no es lo mismo:** que el mecanismo llegue **inerte** con `activo: false`
está **implementado** —la clave se lee, y el banco tiene secciones para ello—; que llegue inerte
**está acreditado por el banco en la forma exacta en que se publica** es algo que **no he verificado
yo** y no lo afirmo: lo diría QA. Aquí sólo digo lo que leí en el manifiesto y en el código.

### 8.c Qué riesgos siguen presentes

1. **El riesgo de `SEC-067` no desaparece: se vuelve condicional al interruptor.** La ventana de
   publicar existe **cuando la rotación corre**. Con `activo: false` no corre, así que en este
   repositorio —único consumidor verificado— el defecto queda **latente**. Pero el **código se
   publica**, y `CA-13` —el criterio que contrata cómo se enciende— **es justo el que se aplaza**:
   un proyecto que ponga `activo: true` obtiene la ventana **sin ningún criterio que contrate su
   salvaguarda**. Ése es el riesgo que se acepta al aplazar, y no es el mismo que aceptar el residual.
2. **`SEC-072` y `SEC-073` siguen abiertos** y son `contrato`. `SEC-073` es de **código** (la máquina
   lee una aprobación **parcial** como **completa**), no de texto.
3. **`SEC-067` no se cierra por texto, y eso ya está demostrado y escrito** (`NFR-026-01 (6)`): su
   *condición exacta de cierre* pasa por `SEC-072`. La vía A de `ADR-008` exige medir el intervalo
   residual y **su precondición es hoy inalcanzable**; la vía B es código del `desarrollador`.

### 8.d Qué hallazgos permanecen abiertos si se aplaza

| ID | Clase | Efecto |
|---|---|---|
| `SEC-067` | **`usuario/dinero`** | **bloquea el cierre de `REQ-026`**. `en-mitigación`, write-back hecho |
| `SEC-072` | `contrato` | bloquea. Es la **puerta** del cierre de `SEC-067` |
| `SEC-073` | `contrato` | bloquea. **Código**, no redacción |
| `QA-026-03`, `-07` … `-11`, `SEC-068`…`SEC-071` | `instrumento` | deuda con dueño; **no** bloquean |

**Consecuencia que hay que decir sin adornos:** aplazar `CA-13/14/16/17` **no desbloquea `REQ-026`**.
Los tres bloqueantes siguen ahí. El aplazamiento acota el **trabajo**, no los **hallazgos**.

---

## 9. El paquete de las guardas: `REQ-023`, `REQ-024`, `D16` y `SEC-084`

### 9.a Correcciones del mecanismo (código, dueño `desarrollador`)

| Qué | Sede | Estado |
|---|---|---|
| `SEC-084` — el disparador `grep -q 'Seguridad:'` es **literal** y `CA-04` **exige** tolerar la decoración | `hooks/guard-completado.sh` | pendiente. Arreglo: **enrutar por el lector que ya existe** (retira una transcripción, no añade otra) |
| `QA-016-04` — `Rigor:` **no** tolera el paréntesis que `QA:`/`Seguridad:` sí toleran | `hooks/lib.sh:2394-2400` | pendiente. Arreglo: **tolerar el paréntesis**, no denegar (ver 9.b) |
| `QA-024-19` | `REQ-024` | pendiente |
| `SEC-083` — fail-open en la guarda que protege la firma del auditor | `hooks/guard-completado.sh` | **cerrado en código**; `mitigado` desde `R-027`. Su campo está desfasado (9.d) |

### 9.b Cambios de conducta que necesitan tu autorización

Ésta es la casilla donde la distinción cambia el diseño del arreglo:

1. **`QA-016-04` — el arreglo «obvio» era el equivocado, y está medido.** Yo propuse **fail-closed**:
   un rigor no reconocido deniega. Eso **cambia conducta heredada** — un proyecto que hoy escribe
   `critico (por suelo)`, forma que **§13 le enseña**, pasaría a ver una denegación donde hoy cierra.
   El arreglo correcto es **tolerar el paréntesis** como ya hacen los otros dos campos: corrige la
   asimetría, **no** cambia la conducta de ningún proyecto conforme, y sólo afecta a valores
   genuinamente basura. **Con ese arreglo, esta casilla queda vacía para `QA-016-04`** y no necesita
   tu firma más allá del gate de `hooks/`.
2. **`SEC-084` sí cambia conducta, y es el cambio que se quiere.** Un proyecto que hoy cierra con
   `_Seguridad_: aprobado` sobre `QA: pendiente` **dejará de poder**. Es **restitución** del contrato
   de §6, no una regla nueva — pero es un `deny` que antes no existía, y por eso va aquí.
3. **El precio de la salida (b) de `CA-12`** (`D12`): un proyecto que no ha migrado nada ve una
   denegación nueva **en un acto que no es el cierre**.

### 9.c Actualizaciones de contratos y plantillas — y son más de las que yo decía

Medido con `grep -rl` sobre `AGENTS.md`, `templates/`, `requirements/README.md`, `skills/` y `hooks/`:
el vocabulario de `Rigor:` está transcrito en **9 archivos** y el de `Seguridad:` en **7**, e
**incluyen lo que los proyectos heredan**: `templates/AGENTS.md.tpl`,
`templates/requirements-README.md.tpl`, `templates/arnes-config.json.tpl` y
`skills/arnes-upgrade/SKILL.md`.

Yo había dicho «una sede». Era cierto **del código** y falso **del contrato**. Añadir a la lista:

- **La fila de §13 que `D11` autorizó escribir y que hoy es FALSA** — anuncia un fail-open que la
  salida (b) retiró.
- **El NFR que cierra `SEC-085`** (dueño `analista-requerimientos`): *ningún hallazgo bloqueante
  existe sin estar en al menos una sede; si su sede legítima no es un campo, entra en el índice con
  su sede real declarada*. El auditor **no da `SEC-085` por cerrado sin él**.

### 9.d QA y auditoría que faltan

| Qué falta | Dueño | Nota |
|---|---|---|
| **La auditoría de `REQ-024`** | `auditor-seguridad` | `Seguridad: pendiente`: **nunca se hizo**. Espera tu firma (decisión 4) |
| Re-validación de `REQ-024` tras sus correcciones | `qa-tester` | tope agotado; necesita la decisión 4 |
| `REQ-023` / `D13` | — | `CA-11` falso bajo dos firmas verdes |
| Re-auditoría de `REQ-017` | `auditor-seguridad` | su `aprobado` es del 2026-09-08 sobre `538c266` |
| **Dos campos desfasados que bloquean de verdad** | `analista-requerimientos` | `SEC-014` (`mitigado` desde `R-006`) sigue en `REQ-013`, que por eso **no puede cerrar**; `SEC-083` (`mitigado` desde `R-027`) sigue en `REQ-024`. **No es cerrar un hallazgo: es alinear el campo con una firma que ya existe.** En cola serial: `REQ-013`/`REQ-024` **colisionan** con `REQ-017` según `tools/arnes-paralelo.sh` |

### 9.e ¿Conviene un 1.33.1 antes de 1.34.0? — y no doy por hecho el commit único

**Compartir causa no obliga a compartir vehículo.** Los dos son de la causa C5, y ahí se acaba el
parecido:

| | `SEC-084` | `QA-016-04` |
|---|---|---|
| **Exposición** | **no depende** del suelo de sensibilidad | **exige** un REQ **no** marcado `Sensible a seguridad: sí` |
| En este repositorio (único consumidor verificado) | expuesto | **0 REQ no sensibles** (`grep -L`) → **latente** |
| Naturaleza del arreglo | **restituye** un contrato | **corrige una asimetría** del lector |
| Radio de conducta | un `deny` nuevo, querido | ninguno, con el arreglo de 9.b |
| Evidencia | `docs/arnes/d16-alcance-real/` | ídem |

**Recomendación, con su condición:** un **1.33.1 con `SEC-084` solo** es defendible y pequeño;
`QA-016-04` puede viajar en 1.34.0 sin coste. Y lo que **decide** es un dato nuevo: el auditor
dictaminó que **`SEC-075` debe resolverse antes de publicar `v1.34.0`**. Si 1.34.0 se aleja, un
1.33.1 para `SEC-084` **gana** valor; si 1.34.0 estuviera a la vuelta, no valdría dos tags, dos CI y
dos gates. **Como hoy 1.34.0 está lejos —cuatro REQ con el tope agotado y `SEC-075` por delante—,
recomiendo el 1.33.1 con `SEC-084` solo.**

Meterlos juntos tiene además un coste que no se ve: un problema en la mitad **sin exposición
verificada** bloquearía la mitad **expuesta**.

---

## 10. La prueba de `REQ-023 CA-09 (iii)` — decisión separada, y corrijo cómo la presenté

**Me corrijo primero.** Escribí que *«el `FAIL` del banco no es una regresión»*. **Eso no se sigue de
la evidencia**, y el propietario lo señaló: *«la variabilidad no demuestra por sí sola que un FAIL sea
falso»*. Lo que la medición demuestra es que **la prueba no discrimina**, y una prueba que no
discrimina **no acredita nada en ninguna de sus dos direcciones**: ni el PASS ni el FAIL. Tomar la
oscilación como prueba de que el FAIL era espurio es quedarse con la mitad cómoda de la misma
evidencia.

**La evidencia se conserva** en `docs/qa/evidencia-req-017-writeback-f4a5f1f/` (`FAIL → SKIP → PASS →
PASS` sobre código idéntico, `loadavg` 3,36 / 1,44 / 2,61 / 2,79, techo `1,000×` dentro del ruido) y
**no se ha re-corrido buscando verde**.

**La decisión que hace falta, y es sólo tuya** — tres opciones, con lo que cada una deja abierto:

| | Qué se hace | Qué queda |
|---|---|---|
| **(A)** | Reparar la prueba: el techo no puede vivir dentro del ruido del instrumento | Es la patología que `REQ-017 CA-08 (ii)` ya describe, y **medir mejor depende de `REQ-021`, que está `bloqueado`** |
| **(B)** | Declararla **no acreditante** con dueño, forzador y vencimiento, sin retirarla | `CA-09 (iii)` queda sin acreditar y `REQ-023` no cierra por ese criterio |
| **(C)** | Aceptar el `rc=1` del banco como conocido y documentado | **No lo recomiendo:** el banco es la **puerta requerida** de `main`; un `rc=1` tolerado por costumbre desactiva la puerta para todo lo demás |

**Recomiendo (B)** — es lo único que no afirma nada que no esté medido, y no toca la puerta requerida.
