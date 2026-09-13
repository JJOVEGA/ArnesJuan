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

**≈ 23 300 tokens por comisión × 33 = ≈ 770 000 tokens = 12 % del total**, sólo en releer los mismos dos
documentos. *(Clase: **derivado** — la conversión bytes→tokens es aproximada; el recuento de comisiones y
el tamaño son medidos.)*

**Es la palanca más barata de todas y ya tiene REQ escrito: `REQ-019`, aplazado a 1.35.0.**

### 1.2 · Comisiones que podrían haberse evitado

**Una, medida y con nombre: la reparación de `SEC-084`.** Se despachó para arreglar un defecto que
**`v1.33.1` ya había cerrado y `#48` portado**. Lo paró el propietario exigiendo reproducir sobre la
cabeza actual antes de reparar. **Coste evitado: una comisión de desarrollador (~28 min, ~200 k
tokens).** La lección quedó como regla y ya se aplica.

**Y una clase entera, no una instancia: las vueltas 5 a 10.** Cada una corrigió **una capa** del mismo
criterio y destapó la siguiente — pertenencia → consecuencia → condición → derivación vacía. **No fueron
errores de ejecución**: cada vuelta encontró un defecto real. Lo que falló es que **el criterio se
escribió antes de que nadie ejerciera lo que describía**.

### 1.3 · Revisiones que repiten evidencia vigente

**Poca, y es lo que mejor funcionó.** Desde que los encargos declaran qué reutilizar, QA dejó de repetir
las 56 celdas del disparador, las 41 formas y las 72 de no-regresión, y lo dijo en cada veredicto. **Ese
mecanismo ya está y no hay que inventarlo.**

### 1.4 · Contradicciones entre copias de una misma regla — **la causa dominante**

Es **la familia que más trabajo consumió**, y aparece medida en todas sus formas:

- La tabla de `D12` **perdió la condición** «existía en la base» al especializar la tabla general → un
  proyecto no podía migrar nunca.
- `AGENTS.md` §13 y su gemela de plantilla prometían sin condición **en cuatro filas distintas**.
- `CA-12 (ii)` citado como contrato de **ocho casos** que no son suyos.
- `Archivos:` enumeraba **tres de siete** secciones.
- `QA-026-10` y `SEC-067` con la clase separada por raya: **el lector no la reconoce**.

**El patrón único: una copia que pierde una condición del original, o una lista que envejece hacia el
lado que abre.**

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

**Y una tercera, que es la que esta sesión demuestra:** *un criterio no se escribe antes de ejercer lo que
describe*. Seis vueltas de este ciclo fueron texto que nadie había ejercido.

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
