# ADR-008 — Qué garantía se contrata para la rotación de sección frente a escrituras concurrentes
Fecha: 2026-09-09
Estado: propuesta

> **Nada de este documento enciende nada.** La rotación sigue **apagada**
> (`.arnes/config.json` → `rotacion.activo: false`, `artefactos: []`) y encenderla es
> `CA-13` de `REQ-026`, que es **otro gate** de aprobación humana con su propia entrada en la
> cola (`SEC-073`). Este ADR decide **qué se promete**, no cuándo se activa.
>
> **`SEC-072` (clase `contrato`) NO se cierra sólo firmando una excepción.** Tiene **dos vías**,
> presentadas aquí en paralelo: **A**, cambiar la garantía (necesita firma y acepta riesgo); **B**,
> corregir el mecanismo y verificarlo (necesita trabajo y no acepta riesgo). Mientras no se tome
> una de las dos, la garantía contratada en `REQ-026` sigue siendo la **absoluta**, el mecanismo
> entregado **no la cumple** en los dos intervalos de abajo, y eso es un hallazgo abierto, no una
> tolerancia.

## Contexto

`REQ-026` contrató dos promesas **en absoluto**:

- **`CA-18 (i)`**: *ninguna publicación puede derivarse de una lectura que ya no describe el
  disco.*
- **`CA-05`**: **cero filas perdidas, cero filas duplicadas** sobre la unión de documento y
  archivo de historia.

El mecanismo entregado —un **testigo de vigencia por relectura** del documento y del archivo de
historia inmediatamente antes de publicar, **sin cerrojos**— **no cumple ninguna de las dos**, y
falla en **dos intervalos distintos que no se deben mezclar**.

### Qué se prometía · qué se garantiza · qué riesgo residual habría que aceptar

| | `CA-18 (i)` | `CA-05` |
|---|---|---|
| **Se prometía** | Ninguna publicación derivada de una lectura caducada | Cero filas perdidas y cero duplicadas |
| **Se garantiza** | Detección de **toda** escritura anterior a la relectura, y no publicación en ese caso: el documento conserva la escritura ajena byte a byte, con aviso por stderr y línea en el bloque derivado | Que el archivado y el recorte publican por temporal propio del proceso, y que el testigo detecta un cambio anterior a la relectura en el documento **y** en el archivo de historia |
| **Riesgo residual** | **(1) Ventana de publicación:** una escritura que caiga entre la relectura y el fin de la publicación **se pierde**. Si esa escritura era una fila de historia, **la fila se pierde**. **Duración del intervalo: SIN MEDIR** | **(2) Publicación interrumpida:** hecho el `mv` del destino y no el recorte del origen, la parada siguiente **re-archiva**: **2 bloques, 3 filas duplicadas, `rc=0` y sin aviso** |

**Los dos residuos son distintos y fallan en direcciones distintas.** En **(2)** —y **sólo** en
(2)— el fallo es hacia el **duplicado**: el destino ya tiene el bloque y el origen sigue entero,
así que **no se pierde ninguna fila**; lo respalda el **modelo determinista de la auditoría**. En
**(1)** la pérdida **sí es posible** y no hay nada que la conserve. *«Ninguna fila se pierde»
no es una garantía general de este mecanismo* — afirmarlo así fue un error de redacción que este
ADR corrige, y que también se acotó en `CA-05`.

### La evidencia, y sólo la que ya existe

- **Intervalo del cálculo, medido dos veces** —es el que el testigo **cierra**—: **295–312 ms**
  (medición del desarrollador) y **355–361 ms** (medición de la auditoría). Sobre él, el fallo
  original se reprodujo **3/3** —un `Seguridad: aprobado` escrito durante la rotación volvía a
  `pendiente`, `rc=0`, sin aviso— y con el testigo dio **3/3 conformes**.
- **Dos rotaciones concurrentes:** duplicado reproducido **2/20** y **3/15** contra el código
  anterior; **0/20** con el testigo. Reproducido por QA.
- **Publicación interrumpida:** modelo determinista de la auditoría — el paso de recorte **no
  tiene rama de error**, y el testigo **no puede verlo**, porque sus dos lecturas son frescas y
  coherentes entre sí.
- **El intervalo residual (1) está SIN MEDIR.** La auditoría lo declara *razonado y acotado, no
  medido*. Lo medido es el intervalo que **sustituye**, no el que queda. Aquí no se usa ninguna
  cifra suya —ni un orden de magnitud— como argumento, ni el argumento de que sea «lo máximo
  posible»: eso es una valoración, no evidencia.
- **Motivo técnico de (1), sin valoración:** POSIX no ofrece renombrado condicional atómico, así
  que el intervalo entre comprobar y publicar no se elimina en shell. Eso describe el
  **sustrato**; no autoriza nada.

## Las dos vías de cierre de `SEC-072`

**No son «una principal y una nota»: son dos salidas completas, con costes de naturaleza
distinta.**

| | **Vía A — cambiar la garantía** | **Vía B — corregir el mecanismo y verificarlo** |
|---|---|---|
| Qué hace | Escribe la tolerancia en los criterios y la firma | Hace que la promesa absoluta **se cumpla**, sin excepción que aprobar |
| Qué necesita | **Firma** del propietario | **Trabajo** (y su verificación en el banco) |
| Qué cuesta | **Riesgo**: deja modos de fallo silenciosos | **Trabajo**, y en dos de sus formas, **beneficio** |
| Alternativas | **1**, con **6** como **precondición** | **3**, **5** y **4** |
| Firma de garantía | Imprescindible | **Ninguna**: no hay excepción que aprobar |

**¿Satisface `3+5` las dos promesas absolutas, sin excepción alguna?** La pregunta importa porque,
si la respuesta fuera sí, la vía B no necesitaría ninguna firma y eso cambiaría la decisión
entera. **La respuesta honesta es: `5` sí cierra (2); `3` NO cierra (1) por mecanismo, sólo por
convención.**

- **`5` cierra (2) del todo.** El re-archivado idempotente elimina el duplicado en el único caso
  que lo produce, y es verificable con un caso determinista —el mismo modelo con el que la
  auditoría lo encontró—. Tras `5`, **`CA-05` vuelve a ser absoluto** y no necesita firma.
- **`3` no cierra (1).** Sacar la rotación del hook de parada quita **al escritor concurrente
  más probable**, pero el intervalo de publicación **sigue existiendo**: el sustrato no cambia
  porque cambie quién invoca. Que «nadie más esté editando» es una **precondición operativa que
  el arnés no puede medir** —y hoy es falsa por observación directa: en esta misma ventana hay
  **dos `desarrollador` vivos** escribiendo archivos a la vez—. Contratar `CA-18 (i)` en absoluto
  sobre esa base sería exactamente la clase de promesa que este proyecto ya encontró falsa tres
  veces en esta comisión: *una puerta que no puede medir no garantiza*.
- **`4` sí cumple las dos promesas por mecanismo**, porque **elimina el caso**: si ningún hook
  reescribe un contrato, no hay lectura caducada ni re-archivado. Su precio es el motivo entero
  del REQ.

**Conclusión del análisis:** `3+5` **no** satisface las dos promesas sin excepción. Las
combinaciones que sí las satisfacen son **`4`** (elimina el caso) y **`4+5`** si además se quiere
la rotación sana para `CHANGELOG.md`. Y `1+5` deja **un solo** residuo declarado —(1)— en vez de
dos.

### Cuánto trabajo cuesta cada pieza de la vía B

Estimado en **piezas**, no en tiempo: esta comisión **no puede estimar duración** y lo declara.

- **`5` (idempotencia):** un criterio nuevo en `REQ-026` con su par discriminante, un cambio en el
  paso de publicación de `arnes_rotar_seccion` y un caso determinista en la parte 4 del banco.
  Es la pieza **más pequeña** de las tres y la única con arreglo conocido.
- **`3` (sacar del hook):** una herramienta nueva en `tools/`, retirar la invocación del hook de
  parada, y la documentación que los proyectos heredan (`skills/`, plantillas). **No estimable**
  por esta comisión; además pierde la automaticidad, y `CA-14` contrata que el ahorro se mide
  sobre la **lectura real**: una rotación que nadie ejecuta ahorra **0**.
- **`4` (no rotar `requirements/`):** el trabajo es **casi nulo en código** —el artefacto nunca se
  declaró—, pero renuncia a los **409.699 B** de historia de REQ, el 23 % de `requirements/`.

## Decisión

*(pendiente de la firma del propietario — este documento es la propuesta concreta que pidió)*

**Se propone partir la decisión, porque los dos residuos no son la misma pregunta:**

1. **`CA-05` → vía B con la pieza `5`, ya y sin firma de garantía.** Se contrata la
   **idempotencia del re-archivado**; `CA-05` recupera su forma **absoluta** y se retira la
   frontera propuesta. No hay excepción que aprobar: es trabajo, y su dueño y vencimiento ya
   están escritos (`desarrollador`, antes de que se declare `CA-13`).
2. **`CA-18 (i)` → no se firma nada hoy: primero `6`.** La alternativa **6** (medir el intervalo
   residual) pasa a ser **precondición de la vía A**: no se pide aceptar un riesgo cuya magnitud
   **nadie ha medido**. Hoy esa medición **no está disponible** —la propia medición de coste de
   `CA-15` se declaró no medible en esta ventana porque la sonda no converge (`REQ-021`)—, así
   que la decisión sobre `CA-18 (i)` **queda abierta y declarada**, no resuelta por silencio.
3. **Cuando el residual (1) esté medido, la elección real es `1` o `4`** —vía A con la excepción
   acotada, o vía B eliminando el caso—. **No `3`**: promete por convención lo que no puede medir.

**Recomendación, con su motivo:** ir por la **vía B en todo lo que la vía B puede cerrar** —eso es
`5`, hoy— y **no gastar la firma del propietario en un riesgo sin medir**. Motivo: de los dos
residuos, uno tiene arreglo por mecanismo y el otro no tiene ninguno en este sustrato; mezclarlos
en una sola firma convertiría un problema con solución en una excepción permanente. Y entre las
dos salidas finales para (1), la información que falta —la duración del intervalo— es
**pequeña de obtener y decisiva para elegir**: renunciar a los 409.699 B (alternativa `4`) o
aceptar el riesgo (alternativa `1`) son decisiones opuestas que hoy se tomarían **sin el único
dato que las distingue**.

## Alternativas consideradas

- **1 — Aceptar la garantía más débil** (escribir la tolerancia en los criterios). **Vía A.**
  *Garantiza:* detección de toda escritura anterior a la relectura (3/3 contra 3/3).
  *No garantiza:* la escritura en el intervalo de publicación —**pérdida posible**, duración
  **sin medir**—; ni, sin `5`, la publicación interrumpida. *Consecuencia:* modos de fallo
  **silenciosos**. — **No hoy:** sólo con `6` hecha, y entonces sólo para (1).
- **2 — Cerrojo obligatorio para todo escritor.** *Garantiza:* la propiedad **sólo si todo
  escritor lo toma**, y `CA-18 (i)` incluye expresamente «una persona», cuyo editor no lo toma.
  *Consecuencia:* **no da la propiedad que dice dar**, y añade un fallo peor —un cerrojo huérfano
  deja un documento que **no vuelve a rotar nunca**, y decidir cuándo está rancio es adivinar—.
  **Descartada:** no es vía A ni vía B; cambia un fallo declarado por una garantía falsa.
- **3 — Sacar la rotación del hook de parada.** **Vía B, incompleta.** *Garantiza:* quita al
  escritor concurrente más probable. *No garantiza:* el intervalo de publicación sigue ahí; la
  premisa «nadie más edita» es una precondición que **el arnés no puede medir**, y hoy es falsa
  por observación. *Consecuencia:* pierde la automaticidad, y `CA-14` mide el ahorro sobre la
  lectura real. — **Descartada como vía de cierre de (1).**
- **4 — No rotar `requirements/` en absoluto.** **Vía B, completa.** *Garantiza:* las dos promesas,
  **por eliminación del caso**: ningún hook reescribe un contrato. *Consecuencia:* renuncia a los
  **409.699 B**. — **Viva y sobre la mesa** como la alternativa real a `1` cuando (1) esté medido.
- **5 — Idempotencia del re-archivado.** **Vía B, completa para (2).** *Garantiza:* cierra (2) y
  devuelve `CA-05` a su forma absoluta, con caso determinista. *No garantiza:* nada sobre (1).
  *Consecuencia:* hay que contratarlo. — **Recomendada, ya.**
- **6 — Medir el intervalo residual.** *Garantiza:* nada por sí sola; convierte un número
  desconocido en conocido. *Consecuencia:* aplaza, y cuesta una medición en máquina en reposo que
  **hoy no está disponible** (`REQ-021`). — **Reclasificada: precondición de la vía A**, no
  alternativa.
- **Variante examinada y no propuesta — la «puerta posterior».** `AGENTS.md` §13 la nombra como
  respuesta a otra clase: dejar de preguntar **antes** si algo va a cambiar y preguntar
  **después** si algo protegido cambió. Aplicada aquí **detectaría** una pérdida en (1), no la
  **evitaría** —cuando se detecta, ya ocurrió—, y el arnés no tiene esa puerta. Se nombra para
  que no parezca inexplorada; **no se propone**.

## Consecuencias

- (+) Con `5`, **`CA-05` vuelve a ser absoluto** y queda **una sola** excepción posible en todo
  `REQ-026`: la de (1), que sigue **sin firmar**.
- (+) Ninguna firma se gasta en un riesgo **sin medir**, y la decisión sobre (1) queda **abierta y
  escrita** en vez de resuelta por omisión.
- (+) En **(2)**, y **sólo** en (2), la dirección del fallo es hacia el **duplicado**: no se pierde
  ninguna fila (modelo determinista de la auditoría).
- (−) Mientras (1) no se resuelva, `SEC-072` **sigue abierto** y `REQ-026` **no cierra**.
  *Mitigación:* está declarado con las dos vías y su precondición; no hay ambigüedad sobre qué
  falta.
- (−) En **(1)** la **pérdida es posible** y su duración es **desconocida**. *Mitigación:* la
  rotación sigue apagada, así que hoy es **latente**; y `6` es la deuda que la hace decidible.
- (−) `5` es trabajo nuevo que hay que contratar (criterio + par discriminante + caso).
  *Mitigación:* dueño y vencimiento ya escritos en `CA-05`, **antes de declarar `CA-13`**.
- (0) Si la firma prefiere resolver hoy sin medir, las dos salidas coherentes son **`1+5`**
  —aceptar (1) declarado— o **`4`** —renunciar a rotar `requirements/`—. Lo que **no** es
  coherente es dejar el REQ como está: una promesa absoluta que el código no cumple.

## Trazabilidad

- `requirements/REQ-026.md` — `CA-18 (i)` (propuesta de tolerancia) y `CA-05` (propuesta de
  frontera), las dos rotuladas «NO ES CONTRATO VIGENTE» y enlazadas a este ADR.
- `SEC-072` (`R-022`), clase `contrato` — cierra por la vía A (firma) **o** por la vía B
  (corregir y verificar).
- `SEC-067` (`R-021`), clase `usuario/dinero` — el fallo que originó `CA-18`.
- `SEC-073` — alcance de `CA-13`/`CA-14`/`CA-16`/`CA-17`, gate del propietario.
- `REQ-015` — cierra la escritura **desgarrada**; **no** cubre la **actualización perdida**, que
  es la clase de este ADR.
- `REQ-021` — la sonda que no converge, y por eso `6` hoy no se puede ejecutar en condiciones.
- `REQ-012 CA-06` — no se relaja un criterio que el código no cumple: por eso esto es un ADR y no
  una fila de Historial.
