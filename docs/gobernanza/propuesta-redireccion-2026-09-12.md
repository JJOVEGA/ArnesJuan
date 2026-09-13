# Propuesta de redirección del arnés — 2026-09-12

> **Qué es esto.** Una **propuesta revisable**, autorizada por el propietario el 2026-09-12 al cambiar la
> prioridad del proyecto: *«ArnesJuan debe facilitar entregas seguras y oportunas en proyectos
> consumidores. **Su propio proceso no puede absorber el beneficio de trabajar con IA.**»*
>
> **No desactiva ningún control, no distribuye nada y no declara lista 1.34.0.** Es una sola síntesis de
> la coordinadora: no se abrió un ciclo de cuatro agentes para escribirla.

---

## 1. Qué está consumiendo el trabajo — medido, no estimado

**Fuente:** `docs/arnes/coste-de-comision/00-metodo-y-base.md`, anotado al cerrar cada comisión. **No se
construyó ningún medidor nuevo para esta revisión.**

> **Alcance de estas cifras, y no se extrapolan.** Cubren **las 33 comisiones registradas** entre el
> **2026-09-10 y el 2026-09-12**, de **este repositorio**, que se impone la ceremonia máxima a propósito.
> **No describen un proyecto consumidor, ni el proyecto completo, ni ningún periodo anterior.** Las
> comisiones de sesiones previas **no están registradas** y por tanto **no están aquí**.

| Medida | Valor | Clase |
|---|---|---|
| Comisiones registradas | **33** | medido |
| Tiempo de agente | **11,5 h** | medido |
| Tokens | **6 336 179** | medido |
| Concentradas en **`REQ-024` y su instrumental** | **29 comisiones · 10,7 h · 5,77 M tokens = 91 %** | medido |
| Vueltas `dev↔QA` de `REQ-024` | **10**, sobre un tope de **3** | medido |
| Vueltas `analista↔QA` | **5**, sobre un presupuesto de **2** | medido |
| Hallazgos abiertos en `REQ-024` | **28**, de ellos **5 `contrato`** | medido |
| Cola de aprobaciones | **14** — y **ningún REQ puede cerrar** mientras tenga entradas | medido |
| Casos de banco · secciones | **1290 · 73** | medido |

### 1.1 · Lecturas repetidas y tamaño del contexto

`AGENTS.md` + `requirements/README.md` = **93 328 bytes**, que **cada comisión lee al arrancar**.

**≈ 23 300 tokens por comisión × 33 ≈ 770 000 tokens ≈ 12 % del total**, sólo en releer los mismos dos
documentos.

**Clase: `estimado`, no `derivado`.** Lo **medido** es el tamaño en bytes (93 328) y el número de
comisiones (33). **Lo demás es estimación**: la conversión bytes→tokens usa una razón aproximada, y
**no existe medición de tokens por comisión desglosada por concepto** que sostenga que esos tokens se
gastaron en esa lectura. Los 6,34 M totales **no están desglosados**. Para convertirlo en `medido`
haría falta instrumentar el desglose — y **eso es exactamente el medidor nuevo que este encargo no
autoriza construir**.

**Es la palanca más barata de todas y ya tiene REQ escrito: `REQ-019`, aplazado a 1.35.0.**

### 1.2 · Dónde se concentró el retrabajo — **sin llamarlo evitable**

**Una, medida y con nombre: la reparación de `SEC-084`.** Se despachó para arreglar un defecto que
**`v1.33.1` ya había cerrado y `#48` portado**. Lo paró el propietario exigiendo reproducir sobre la
cabeza actual antes de reparar. **Coste evitado: una comisión de desarrollador (~28 min, ~200 k
tokens).** La lección quedó como regla y ya se aplica.

**Y una secuencia que NO llamo evitable, porque no lo fue.** Las vueltas 5 a 10 corrigieron una capa
cada una y destaparon la siguiente —pertenencia → consecuencia → condición → derivación vacía—, y
**cada una encontró un defecto real y medido**. Llamarlas «evitables» confundiría *que hubo retrabajo*
con *que el trabajo sobraba*, y esa lectura lleva a recortar revisiones en vez de a corregir el orden.

**Lo que sí se puede afirmar, y es más útil:** en todas ellas se **afirmó sobre conducta ya existente
sin ejercerla**. Ése es el orden que hay que corregir, no el número de vueltas.

### 1.3 · Revisiones que repiten evidencia vigente

**Poca, y es lo que mejor funcionó.** Desde que los encargos declaran qué reutilizar, QA dejó de repetir
las 56 celdas del disparador, las 41 formas y las 72 de no-regresión, y lo dijo en cada veredicto. **Ese
mecanismo ya está y no hay que inventarlo.**

### 1.4 · Contradicciones entre copias de una misma regla — **la más frecuente de las medidas**

Es **la familia que más trabajo consumió**, y aparece medida en todas sus formas:

- La tabla de `D12` **perdió la condición** «existía en la base» al especializar la tabla general → un
  proyecto no podía migrar nunca.
- `AGENTS.md` §13 y su gemela de plantilla prometían sin condición **en cuatro filas distintas**.
- `CA-12 (ii)` citado como contrato de **ocho casos** que no son suyos.
- `Archivos:` enumeraba **tres de siete** secciones.
- `QA-026-10` y `SEC-067` con la clase separada por raya: **el lector no la reconoce**.

**El patrón que comparten: una copia que pierde una condición del original, o una lista que envejece
hacia el lado que abre.**

**No lo declaro causa única.** Es **la familia que más veces apareció en las comisiones registradas**;
otras —el criterio escrito sobre conducta no ejercida (§1.2), el instrumento que no discrimina
(§1.6)— son distintas y no se reducen a ella.

### 1.5 · Aprobaciones que bloquean trabajo independiente

**La cola de 14 impide cerrar cualquier REQ**, incluidos los que no tienen nada que ver con la decisión
pendiente. **`REQ-003`** es el caso extremo: está `completado` y **no podría volver a cerrarse** si se
reabriera, por una razón **ajena a su contenido**.

### 1.6 · Instrumentos cuyo mantenimiento supera su utilidad demostrable

**Uno, y está medido: el criterio de reloj `REQ-024 CA-07 (ii)`.** Consumió **tres comisiones** y produjo
**tres `FAIL` sobre código idéntico**. Hoy declara su propio suelo de detección (`1,302×`) **por encima
del techo que vigila** (`1,250×`): **no puede cazar lo que dice cazar.** Sigue en la puerta requerida por
decisión del propietario —bloquear por incertidumbre— y eso es correcto; pero **su coste por defecto
atrapado es el más alto del banco**.

### 1.7 · Lo que NO se puede separar hoy, y se dice

- **Coste de runtime:** el CI corrió **~12 veces** en esta rama a ~2 min. **No hay registro estructurado**
  de su coste; el dato existe en GitHub y **no se ha recogido**. → **no registrado**.
- **Tiempo humano:** supervisión, revisión y decisiones del propietario. **No registrado en ninguna
  parte**, y es exactamente lo que `REQ-008 CA-90` contrata para el futuro. → **no registrado**.
- **Consumo de IA:** los 6,34 M tokens son **medidos**, pero **no hay fuente de facturación declarada**,
  así que **no se convierten a dinero** — es la regla que `CA-88` acaba de contratar.

---

## 2. Política proporcional para consumidores

**Cuatro vías, elegidas por el efecto real del cambio y no por la categoría del archivo.**

| Vía | Cuándo | Quién interviene | Qué NO cambia |
|---|---|---|---|
| **A · Informativa** | Cambio de texto o presentación **sin efecto en lógica, permisos ni datos** | Quien lo hace + **la comprobación pertinente** | Las quality gates corren igual |
| **B · Reparación acotada** | Cambio funcional con **causa, alcance y decisión claros** | `desarrollador` + **QA enfocada al delta** | El analista **no** es trámite para transcribir una reparación clara |
| **C · Sensible** | **Dinero · permisos · identidad · datos sensibles · migraciones · pérdida de información** | `desarrollador` → **QA** → **seguridad** | **Sin excepciones.** Es el suelo |
| **D · Analista** | **Ambigüedad real o decisión de producto** | `+ analista-requerimientos` | Se añade **a** la vía que corresponda, no la sustituye |

**Las dos reglas que impiden que esto sea una rebaja:**

1. **Las pruebas necesarias no desaparecen por reducir agentes.** Menos firmas, **no menos evidencia**.
2. **El rigor no se baja para eludir una protección.** Si un cambio toca la vía C, paga la vía C — aunque
   «sólo sea una línea».

**Y una tercera, corregida por el propietario el 2026-09-12 porque mi primera formulación era falsa por
exceso** —yo escribí «un criterio no se escribe antes de ejercer lo que describe», y eso habría
prohibido especificar—:

> **Una funcionalidad nueva se especifica ANTES de implementarse. Una afirmación sobre comportamiento
> EXISTENTE debe contrastarse ANTES de presentarse como hecho.**

Son **dos reglas distintas**. Especificar por adelantado es el orden normal del trabajo; lo que falló en
este ciclo fue lo otro. Y la forma extrema del fallo quedó medida: **el texto que documentaba la
reparación de la derivación vacía cometía la misma forma de defecto que la reparación corrige**.

---

## 3. Reducir las fuentes de retrabajo

**Para cada regla, cuatro cosas distintas** — y el error medido es confundirlas:

| | Qué es | Dónde vive |
|---|---|---|
| **La conducta** | Lo que debe protegerse | El código |
| **La sede normativa** | Dónde se contrata, **una sola vez** | El criterio del REQ |
| **La prueba** | Lo que demuestra la conducta | El banco |
| **La referencia** | Documentos que **sólo apuntan** | `AGENTS.md`, plantillas, skills |

**Transcripciones que propongo eliminar** —cada una fue fuente medida de retrabajo hoy—:

- La **tabla especializada** de `D12` en la skill, que perdió una condición de la general. **Debe
  remitir, no copiar.**
- Las **cuatro filas** de `AGENTS.md` §13 que describen conductas del hook. **Una referencia a la sede
  normativa y la conducta medida en el banco** — no la conducta transcrita.
- Las **listas de vías** en criterios, sustituidas por propiedad. *(Ya aplicado en `CA-13`, `CA-14`,
  `CA-18 (i)` y `Archivos:`.)*

**Y dos límites explícitos:**

- **No se sustituye revisión humana de significado por analizadores generales de texto.** La sección `46`
  es el ejemplo: resolvió **la derivación vacía** dentro del conjunto ya reconocido, y **no** ensanchó el
  reconocedor. Ése es el patrón a repetir.
- **Una errata o una referencia desfasada NO dispara una revisión completa.** Se corrige donde está, se
  anota, y **no reabre el producto**. La documentación **falsa** sí se corrige — pero la escala de la
  respuesta la fija **el efecto**, no la clase del archivo.

---

## 3-bis · Las dos sedes sin acreditar: revisión documentada en vez de análisis de prosa

**El propietario no autoriza declarar satisfecho `CA-14` con dos sedes sin acreditar**, y **pausó** las
ampliaciones del instrumento. Esta es la salida que propongo, y **no es rebajar el criterio**.

### El problema, medido

Dos sedes de `AGENTS.md` §13 —**«Anti-deriva: el techo honesto»** y **la fila del orden de las
firmas**— **no producen ninguna celda** emparejable: el derivador **no reconoce su forma**, así que no
se puede leer en qué niveles ni en qué estado de la llave caen. **`46/7` examina cero oraciones en
ellas**, y su `PASS` es cierto por vacío.

**La salida por instrumento sería ensanchar el reconocedor hasta entender esas formas.** Es justamente
lo que este proyecto ha perdido **cinco veces**: ensanchar el patrón cubre la instancia y no la clase.
Y el propietario lo prohibió expresamente: **no sustituir revisión humana de significado por
analizadores generales de texto**.

### Qué obligación cambia, exactamente

| | Hoy | Propuesto |
|---|---|---|
| **`CA-14 (ii)`** para sedes que el derivador reconoce | Emparejamiento **automático** texto↔hook, ≥12 celdas | **Sin cambio** |
| **`CA-14 (ii)`** para sedes que **no** reconoce | Se declaran **mudas y sin acreditar** — y ahí se queda | **Revisión documentada**: una persona lee la sede, escribe **qué afirma en términos de clave, eje y niveles**, y esa lectura se **contrasta contra la conducta medida**, dejando la evidencia con fecha y árbol |
| **La conducta del hook** | Medida por el banco | **Sin cambio — y esto es lo que no se negocia** |

**La obligación que cambia es quién traduce la prosa a una afirmación comprobable**: hoy el derivador,
y donde no llega, **una persona que firma su lectura**. **La obligación que NO cambia es que la
afirmación se contraste contra el hook real.**

### Qué evidencia sigue siendo necesaria

- **Las pruebas ejecutables del comportamiento se conservan enteras.** El banco sigue midiendo las 24
  celdas con el hook real; ninguna se retira.
- **La revisión documentada deja evidencia con fecha y árbol**, y **caduca si la sede cambia** — igual
  que un veredicto.
- **La sede sigue apareciendo en el denominador como no emparejada automáticamente.** No desaparece del
  recuento: cambia de «muda» a «acreditada por revisión», y **quien lea el informe ve cuál es cuál**.
- **`46/11` sigue emitiendo su `SKIP`** mientras no exista esa revisión. **No se convierte en `PASS`
  por decreto.**

**Lo que esto NO resuelve, y va dicho:** una revisión humana **no escala** y **no se re-ejecuta en cada
PR**. Es la decisión consciente de pagar revisión en dos sedes en vez de construir un analizador que
este proyecto ya ha demostrado que no converge.

---

## 3-ter · `D14` — la decisión, con alternativas y consecuencias

**Qué se decide:** si `REQ-024` cierra con **residual declarado** o sigue **`bloqueado`**.

**Estado medido hoy:** `Estado: bloqueado` · `QA: con-hallazgos` · `Seguridad: pendiente` · **28
hallazgos abiertos, 5 de clase `contrato`** (`SEC-084`, `QA-024-38`, `QA-024-39`, `QA-024-40`,
`QA-024-42`).

| | Qué pasa | Consecuencia |
|---|---|---|
| **(A) Mantener `bloqueado`** | El REQ no cierra en 1.34.0. Sus hallazgos siguen **abiertos y visibles** | 1.34.0 sale **sin `REQ-024`**. **Nada se pierde**: el trabajo está hecho y verificado en lo que QA acreditó |
| **(B) Cerrar con residual declarado** | Exige aceptar que **cinco `contrato`** quedan abiertos con dueño, forzador y vencimiento | **No lo recomiendo, y el motivo es de definición:** lo que queda **no es un residual**. `SEC-084` y `QA-024-38/40` son **trabajo hecho pendiente de verificar**; `QA-024-39` es **una decisión tuya**; `QA-024-42` es **una frase falsa por corregir**. Declararlos residuales diría que se acepta un riesgo donde hay una **cola de verificación** |
| **(C) Mover `REQ-024` a 1.35.0** | La ventana cambia; **los hallazgos no** | Es la vía que este proyecto ya usó con `REQ-019` y `REQ-008`. **Mueve el trabajo, no la deuda** |

**Recomendación: (A) ahora, y (C) como decisión de ventana cuando cierres 1.34.0.** Son compatibles:
mantener `bloqueado` describe la realidad **hoy**; mover la ventana es **planificación**, y ninguna de
las dos cierra nada por conveniencia.

### El alcance mínimo entregable de 1.34.0

**Lo que puede terminarse con lo que ya está hecho y verificado**, sin `REQ-024`:

| | Estado |
|---|---|
| El porte de la estabilización 1.33.1 y `SEC-090` | **Integrado** en `e53de46`, con QA, seguridad y CI |
| La reparación de `SEC-084`/`QA-024-19` (el disparador) | **Hecha y acreditada por QA** (56 celdas, 0 `DENY→ALLOW`) |
| La tabla heredada de `AGENTS.md` y la migración | **Hechas**, con 55+27 casos y gemelas idénticas |
| La reparación de `QA-024-41` | **Hecha**, seis verificaciones PASS |
| La reparación de la derivación vacía | **Hecha y acreditada por QA** en la vuelta 10 |
| `REQ-027` | **`completado`** |

**Lo que falta para poder entregar eso:** la rectificación de `QA-024-42` (en curso), **seguridad sobre
el conjunto**, **CI en verde** — y **la cola de 14**, que hoy impide cerrar cualquier REQ.

**Lo que NO entra:** `REQ-024`, `REQ-026`, `REQ-017`, `REQ-023` — cada uno con su decisión pendiente, y
**todos con sus compromisos abiertos y visibles**.

---

## 4. Alcance, vueltas y aprobaciones

### 4.1 · Entregas pequeñas con condición de terminado

**Lo que hoy no hay y se paga:** `REQ-024` lleva **28 hallazgos abiertos** y **10 vueltas**, porque **cada
hallazgo ajeno encontrado durante el trabajo amplió la entrega**.

**Propuesta:** un hallazgo ajeno **se registra aparte y no aumenta el alcance**. La entrega termina
cuando cumple **su** condición, con lo demás visible y abierto.

### 4.2 · Vueltas

**El historial se conserva íntegro** — `dev↔QA` en 10, `analista↔QA` en 5, con sus excepciones citadas.

**Para trabajos nuevos, el presupuesto cambia de función**: no es un tope que se sortea con excepciones,
es **la señal de que la tarea no converge y hay que replantearla**. Agotado el presupuesto, la salida por
defecto es **parar y replantear el trabajo**, no pedir una vuelta más.

### 4.3 · Aprobaciones

**La cola global no se cambia todavía**, como pediste. Lo que propongo **estudiar**:

Que una aprobación **bloquee el acto y el trabajo al que pertenece**, no todo el proyecto. Hoy `D4` —una
ventana de rendimiento— impide cerrar `REQ-026`, con el que no tiene relación.

**Cómo se conservaría lo que sí afecta a todo:** una entrada declara su **alcance** —`acto`, `REQ` o
`proyecto`—, y las de alcance `proyecto` **siguen bloqueando todo**. `D2` (los hallazgos bloqueantes) y
`D8` (el manifiesto) son de esa clase; `D4` y `D13` no. **Sin ese campo, la única lectura segura es la
actual**, y por eso no se toca hasta decidirlo.

---

## 5. El backlog, clasificado por efecto

**No por el nombre del hallazgo ni por su cercanía al código.**

### A · Necesario para evitar daño concreto a consumidores

| | Efecto |
|---|---|
| **`QA-024-41`** (reparado, sin verificar) | Un proyecto instalado antes de 1.31.0 **no podía migrar nunca**, con bloques ya aplicados y nada que resolver |
| **`SEC-084` / `QA-024-19`** (reparado, sin verificar) | La guarda que protege la firma del auditor **no veía** formas de la clave que el lector sí acepta |
| **`SEC-072`** (abierto) | **Pérdida de una escritura ajena** en la ventana de publicar. Ventana **sin medir** |
| **`QA-016-04`** (abierto) | `contrato` **sin sede en ningún campo** — ninguna puerta lo mide |

### B · Necesario para entregar o actualizar con garantías

`CA-12 (ii)` y la transcripción de `SEC-084` **hechas**, pendientes de verificar · `SEC-073` (cuatro
criterios sin implementar, **ya legibles por la máquina**) · `D15`, que es la cuarta parte de `SEC-084`.

### C · Simplificación con beneficio comprobable

**`REQ-019`** — el **12 % de los tokens** medido arriba · **la cola por alcance** (§4.3) · **retirar las
transcripciones** de §3.

### D · Mejora aplazable del instrumento

`REQ-024 CA-07 (ii)` y su falso rechazo · `QA-024-22/23/29/30/31/36/37` · `SEC-091`/`SEC-092` · la
automatización del cotejo general-contra-especializada · **las dos sedes sin emparejar** de `CA-14`.

---

## 6. Qué conviene terminar de 1.34.0 y qué aplazar

**Terminar** — está hecho y sólo falta verificarlo: el delta de la vuelta 10 (QA en curso), la seguridad
del conjunto y el CI. **Es trabajo de horas, no de días.**

**Aplazar, con decisión tuya:**

- **`REQ-024` no cierra en esta ventana.** Le faltan `QA-024-39` (decisión sobre `REQ-003`), `CA-03`
  (firma ajena) y `D14`. **Proponer moverlo no equivale a cerrarlo**: sus 28 hallazgos siguen abiertos y
  visibles.
- **`REQ-026`** depende de `D3`, ya decidido, pero su implementación es trabajo nuevo.
- **`REQ-017`** y **`REQ-023`** siguen `bloqueado` esperando `D18` y `D13`.

**Los compromisos no cumplidos se conservan abiertos y visibles.** Nada se cierra por conveniencia.

---

## 7. El primer cambio pequeño, para poder evaluar

**Propuesta: aplicar la vía B a una reparación acotada real, y medirla contra las de hoy.**

No `REQ-019` —es grande— ni nada sensible. Una reparación con causa, alcance y decisión claros:
`desarrollador` + **QA enfocada al delta**, **sin analista** y **sin seguridad**, con las quality gates
y el banco corriendo igual.

**Qué se compara**, contra las 33 comisiones registradas: **tiempo de entrega**, **intervenciones
humanas**, **consumo**, y **defectos relevantes descubiertos después de aprobar**.

**Y lo que no se promete:** ningún porcentaje de mejora antes de medirlo. El historial de esta sesión es
**referencia, no prueba causal de ahorro** — los proyectos son distintos y este repositorio se impone la
ceremonia máxima a propósito.

**La prueba en un consumidor requiere autorización específica**, y no se pide con esta propuesta.

---

## 8. Archivos y mecanismos que habría que cambiar

**Ninguno se cambia con esta propuesta.** Lista exacta, para que la decisión sea sobre algo concreto:

| Archivo / mecanismo | Qué cambiaría |
|---|---|
| `docs/gobernanza/autoalojamiento.md` | La política proporcional pasa a ser **la del arnés**, no sólo del autoalojamiento |
| `AGENTS.md` §6 y §13 + `templates/AGENTS.md.tpl` | Las cuatro vías; **retirar las transcripciones** de conducta y dejar referencias. **Gate humano** |
| `templates/AGENTS.md.tpl` | Lo que reciben **proyectos nuevos** |
| `skills/arnes-upgrade/SKILL.md` | La migración para **proyectos existentes**, **preservando personalizaciones** — el mecanismo **ya existe y está probado** en las secciones `45`, incluido el caso de base anterior al bloque |
| `PENDING_APPROVAL.md` | El campo de **alcance** por entrada (§4.3). **No se toca hasta decidirlo** |
| `.arnes/config.json` y su plantilla | Sólo si la vía se declara por manifiesto. **Gate humano** |

**Plan de adopción:** proyectos nuevos por plantilla; existentes por `arnes-upgrade`, que ya **conserva
el contenido ante conflicto, no declara migrado lo que no aplicó y no sube `arnes_version` con un
conflicto abierto** — verificado en esta rama con `INTACTO / CONFLICTO / UNKNOWN` y con base anterior al
bloque.

---

## 9. Lo que esta propuesta NO hace

No desactiva controles · no distribuye nada · no migra Adelantos · no publica 1.34.0 · no cierra ningún
hallazgo · no reinicia ningún contador · no acepta ningún residual · y **no declara ningún ahorro**.
