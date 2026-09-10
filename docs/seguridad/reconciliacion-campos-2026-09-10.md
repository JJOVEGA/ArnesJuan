# Reconciliación de `docs/seguridad/registro-seguridad.md` contra los campos `Hallazgos abiertos:` — 2026-09-10

> **Qué es.** El cruce, elemento por elemento, entre los hallazgos de clase **bloqueante**
> (`usuario/dinero` y `contrato`) de `docs/seguridad/registro-seguridad.md` y lo que declaran los
> campos `Hallazgos abiertos:` de `requirements/REQ-0*.md` — que es la única sede que
> `guard-completado` lee. Lo pidió la sesión coordinadora al medir **once** identificadores presentes
> en el registro y ausentes de todo campo. **La lista de once se reproduce exacta y su composición es
> incorrecta**: el método que la produjo lee el **estado de la cabecera** del hallazgo, y en este
> registro el estado vigente **no vive en la cabecera** — cambia en secciones posteriores. Aquí van
> las once filas pedidas, la corrección de la lista y el recuento firme.
>
> **Qué NO es.** No es una auditoría de ningún REQ y no acredita ningún árbol. **No se emite ningún
> veredicto `Seguridad:`** y **no se ha tocado ni un archivo de `requirements/`**: lo que dice la
> columna «recomendación» es una recomendación al `analista-requerimientos`, no una edición.
>
> **Autor:** `auditor-seguridad`. **Revisión asociada:** `R-028` del registro de seguridad.

---

## Versión base y método (suficiente para re-derivar sin preguntar)

**Versión base:** rama `rel/registro-1.33.0`, commit **`b55347e`**
(`b55347e289ce545f1856b677126c1a5d39f103a7`). Único archivo modificado en el árbol de trabajo al
medir: `docs/ESTADO.md` (no interviene). `requirements/` y `docs/seguridad/` están limpios respecto a
ese commit.

**Sede (a) — los campos.** Sólo cuenta la **primera** línea de cada archivo que empieza exactamente
por `Hallazgos abiertos:` (el campo vale sólo en la cabecera, `AGENTS.md` §13); las líneas iguales
dentro del cuerpo son texto de criterios y no declaran campo:

```sh
for f in requirements/REQ-0*.md; do
  n=$(grep -n '^Hallazgos abiertos:' "$f" | head -1 | cut -d: -f1)
  [ -n "$n" ] && { echo "== $f"; sed -n "${n}p" "$f"; }
done
```

La clase de cada entrada se lee del paréntesis que sigue al identificador
(`\b((?:SEC|QA|DEV|AN|H)-[0-9A-Za-z-]+)\s*\(([^),]*)`), y se cuenta bloqueante si ese texto contiene
`contrato` o `usuario/dinero`. Resultado sobre `b55347e`: **133** entradas en total, **23**
bloqueantes, **0** sin clase reconocible.

**Sede (b) — el registro.** Un hallazgo NO se lee por su cabecera. El estado vigente es **la última
declaración** que lo nombra, y este documento las escribe en tres formas distintas:

1. cabecera de apertura — `### SEC-0NN — \`contrato\` · **abierto** · …`;
2. sección de transición — `### SEC-0NN — Estado: \`abierto\` → **\`mitigado\`**…`;
3. prosa de una revisión posterior — p. ej. *«Y `SEC-050` pasa de `en-mitigación` a `mitigado`»*
   (`R-027` §2), que **no** lleva encabezado propio.

```sh
grep -nE '^#{2,4} .*SEC-[0-9]{3}' docs/seguridad/registro-seguridad.md   # aperturas y transiciones
grep -n  'SEC-0NN' docs/seguridad/registro-seguridad.md                  # y la última mención gana
```

**Por eso el método de cabecera sobre-cuenta.** Es exactamente el defecto que el propio registro
declara en el encabezado de su índice: *«la prosa de este registro no se puede contar»*
(`R-016` §2). La sede legítima para contar es ese **índice**, y su estado se corrige en `R-028` por
lo que se dice abajo.

**Cruce.** `comm -23 <(ids de la sede b, bloqueantes y no cerrados) <(ids de la sede a)`.

---

## 1. Las once filas pedidas

Clases: `A` = sigue abierto de verdad y debe declararse en un campo · `B` = ya no está abierto, se
corrige el estado en el registro · `C` = no pertenece a ningún REQ, su vía de bloqueo es
`PENDING_APPROVAL.md`.

| # | ID | Clase | Estado vigente en el registro (2026-09-10) | Veredicto | Evidencia y recomendación |
|---|---|---|---|---|---|
| 1 | `SEC-031` | `contrato` | **`en-mitigación`** — *no* `abierto`. Lo declara `R-016` §2 desde 2026-09-08; la cabecera (`:2714`) es el texto de apertura y no el estado | **B parcial** (no está `abierto`) **+ sigue BLOQUEANTE** | El write-back **existe** y es verificable leyendo `requirements/REQ-019.md`: Historial `:1801` (CA-14 nuevo, CA-02.2/2.3, CA-10 y la 2.ª pregunta del filtro «¿Acota?») y `:1809` (el campo pasó de cuatro ids a `SEC-033 (contrato)`). **No vuelve al campo:** su remediación *era* el write-back, y el residual es **mi verificación**, que viaja por el campo `Seguridad:` de `REQ-019` (`preventiva`, que declara no cubrir el código posterior) y no por `Hallazgos abiertos:`. **La puerta no está ciega para él:** `REQ-019` es `critico` y sin `Seguridad: aprobado` no cierra |
| 2 | `SEC-032` | `contrato` | **`en-mitigación`** (ídem, `:2757`) | **B parcial + BLOQUEANTE** | Ídem fila 1. Write-back en `REQ-019` Historial `:1802` (CA-12/CA-13/CA-03 y §«Las preguntas de trabajo»: se igualó el grano y las preguntas las redacta quien no hizo el reparto) |
| 3 | `SEC-034` | `contrato` | **`en-mitigación`** (ídem, `:2839`) | **B parcial + BLOQUEANTE** | Write-back **medido en el árbol**: `requirements/REQ-019.md:4` declara hoy `Archivos: … requirements/REQ-*.md …` **sin decoración de Markdown**, que es literalmente la remediación pedida (y respeta `SEC-020`). Historial `:1804` |
| 4 | `SEC-035` | `contrato` | **`en-mitigación`** (ídem, `:2865`) | **B parcial + BLOQUEANTE** | Write-back en `requirements/REQ-021.md` Historial `:2332` (CA-04 reescrito: **ningún descendiente** en ningún nivel, sin apoyarse en `jobs`, plazo de arranque declarado, acreditación **con un nieto**, y declarada la pérdida de cobertura de la mudanza) y `:2340` (retirada del campo). Residual = mi verificación del código, por `Seguridad:` de `REQ-021` |
| 5 | `SEC-036` | `contrato` | **`en-mitigación`** (ídem, `:2917`) | **B parcial + BLOQUEANTE** | Write-back en `REQ-021` Historial `:2333` (la expectativa vive en el **juez**, identidad de camino contratada) y `:2334` (forzador **observable** para el residual, con vencimiento en la pasada de conformidad de 1.34.0). Ídem residual |
| 6 | `SEC-050` | `contrato` | **`mitigado`** desde **hoy**, `R-027` §2 (`:8027`ss) — la cabecera `:4014` no se reescribió | **B** | Su residual **único y nombrado** era `SEC-082`, y `SEC-082` quedó `mitigado` en la misma revisión con las tres remediaciones medidas (código, write-back de `CA-11` cláusula por cláusula, y el forzador `40-ausencia-que-abre-4-…`). El puntero está unificado y las **seis** aplicaciones localizadas por ruta y línea |
| 7 | `SEC-052` | `contrato` | **`mitigado`** desde `R-015` (`:4429`) | **B** | Verificado punto por punto en `R-015` §1 (`:4411`). **Y la discrepancia que `R-016` §2 dejó anotada está RESUELTA:** el campo vigente de `REQ-023` ya **no** lo declara (su `Hallazgos abiertos:` son nueve `QA-023-*`, `SEC-078` y `SEC-080`, todos `instrumento`). Nada que hacer |
| 8 | `SEC-053` | `contrato` | **`mitigado`** desde `R-017` (`:5164`) | **B + C por naturaleza** | Nunca colgó de ningún REQ: su objeto era la frontera del criterio de publicación delegada, cuya sede es `docs/gobernanza/autoalojamiento.md` §«La frontera del recuento» (`:159`). **Y dos cosas que vivían dentro y NO murieron con él** siguen nombradas en `:5211`ss: la decisión de fondo (vive en `SEC-055`) y la obligación de **publicar el recuento** en cada tag |
| 9 | `SEC-054` | `contrato` | **`abierto`** al empezar esta reconciliación → **`mitigado`** en `R-028`, por verificación propia | **B, con evidencia de auditoría** | Las **tres** remediaciones existen **y estaban dentro del tag publicado** `v1.33.0` (`810128a`, 2026-09-08 20:31), comprobado con `git show v1.33.0:<ruta>`: (1) `ADR-005:46-70` lleva la **nota fechada** «el punto 4 queda NO ACREDITADO», aditiva y sin reescribir el ADR (`AGENTS.md` §10); (2) `tests/util/README.md:50-64` dice **qué** certifica la calibración y **qué no**, citando `SEC-054`; (3) el write-back existe como **criterio** en `requirements/REQ-021.md` CA-03 (a.2) y sus cinco condiciones (`:168-180`, `:260-275`): testigo **impredecible**, FAIL nombrado, «escrita para que una implementación tautológica la incumpla **EJECUTANDO**». **Lo que NO acredita este cierre:** que el código satisfaga ese criterio — no lo satisface, y eso vive en `QA-021-10`/`QA-021-11` (`contrato`, **abiertos**, declarados en el campo de `REQ-021`), que son de QA y **no toco** |
| 10 | `SEC-055` | `contrato` | **`abierto`** — sin cambio desde `R-016` (`:4947`) | **A + C (dos mitades, y no las fuerzo a una)** | **A, la mitad de write-back:** debe declararse en el campo de **`REQ-019`** como **`SEC-055 (contrato)`**, porque `AGENTS.md` está en el `Archivos:` de ese REQ (`requirements/REQ-019.md:4`) y es el REQ cuyo objeto es repartir ese documento — sede que la propia entrada ya fijó. **C, la mitad de fondo:** *retirar* la delegación en vez de acotarla es **decisión del propietario** y su sede es `PENDING_APPROVAL.md`, no un campo. **Sigue siendo verdadero hoy, medido:** `AGENTS.md:60` y `:120-121` prometen la delegación y **no** declaran que hoy no autoriza nada. **Y corrijo mi propio texto:** las dos frases **sí** citan `docs/gobernanza/autoalojamiento.md` (desde `6c1b58a`, v1.30.3), lo que mi entrada omitió al citar la ubicación; lo que **falta** es la cita de la **frontera** y su regla de recuento, y la declaración de que la delegación no autoriza. La precisión va en `R-028` §3 |
| 11 | `SEC-082` | `contrato` | **`mitigado`** desde **hoy**, `R-027` §2 (`:8027`) | **B** | Tres remediaciones medidas ejerciendo la puerta real: 10 pares comentado ≡ borrado con 6 discriminantes; 20 celdas de la excepción en `critico` (declarado y por suelo) sin un fallo; 5 de 5 claves mueven con la llave encendida y 4 de 5 en la base; no-regresión con 216 cabeceras y **DENY→ALLOW = 0**. **Ya retirado del campo** de `REQ-016` |

**Resumen de las once:** **0** de tipo A puro · **7** de tipo B (`SEC-050`, `SEC-052`, `SEC-053`,
`SEC-054`, `SEC-082` completas; `SEC-031`, `SEC-032`, `SEC-034`, `SEC-035`, `SEC-036` **parciales** —
no están `abierto`, pero **siguen bloqueando** como `en-mitigación`) · **1** mixta A+C (`SEC-055`).
Ninguna de las once necesita entrar en un campo salvo `SEC-055`.

---

## 2. Corrección de la lista: sobran cinco y faltan cuatro

**Sobran cinco**, porque su estado vigente ya no bloquea: `SEC-050`, `SEC-052`, `SEC-053` y
`SEC-082` estaban `mitigado` **antes** de la medición, y `SEC-054` lo queda con `R-028`.

**Faltan cuatro** hallazgos de clase bloqueante, no cerrados y ausentes de **todo** campo, que el
método de cabecera no vio:

| ID | Clase | Estado | Por qué el método no lo vio | Sede real |
|---|---|---|---|---|
| `SEC-023` | `contrato` | **`en-mitigación`** | Su cabecera (`:1661`) no lleva el estado en la forma buscada; el estado está en `R-008` (`:2496`) y en el índice | **C** — no cuelga de ningún REQ vivo (el fail-open de la cita corrió publicado en 1.31.0 y 1.32.0) |
| `SEC-029` | `contrato` | **`en-mitigación`** | Ídem (`:1933`, estado en `R-008`) | **C** — no atribuible a un REQ (accesos y nombres en el repositorio público) |
| `SEC-030` | `contrato` | **`abierto`** | Ídem (`:2418`) | **C** — no atribuible a un REQ; su remediación 1 aterriza en el reparto de `AGENTS.md` §13, que es `REQ-019` |
| `SEC-075` | `contrato` | **`abierto`** | Su encabezado es `#### \`SEC-075\` — **\`contrato\` · abierto …** (`:6631`): identificador **entre acentos graves** y estado **sin negrita propia**, así que ningún patrón de la forma `### SEC-0NN — \`contrato\` · **abierto**` lo alcanza | **C** — y **por decisión escrita en su propia entrada**: «*NO bloquea `REQ-027` y no va a su `Hallazgos abiertos:`*», «*SÍ debe resolverse antes de publicar `v1.34.0`*». Su vía de bloqueo es la **decisión del tag**, o sea `PENDING_APPROVAL.md` |

**`SEC-075` es el dato importante de esta sección, y no por su severidad.** Está en **ninguna de las
dos sedes**: ni en un campo (por decisión correcta) ni en el índice de hallazgos bloqueantes (por
omisión mía). La regla de **unión + fail-closed** de la frontera de publicación protege contra
«cerrado en el campo y abierto en la prosa» **sólo si cada hallazgo aparece en al menos una sede**.
`SEC-075` es el contraejemplo medido: un `contrato` **abierto** que ningún recuento derivado de la
frontera puede encontrar, y la dirección del error es la que **publica**. De ahí `SEC-085`, abajo.

---

## 3. Discrepancias entre sedes vigentes hoy (dirección segura, pero bloquean de verdad)

| ID | Registro | Campo | Efecto |
|---|---|---|---|
| `SEC-014` | **`mitigado`** desde `R-006` (`:1429`, trece afirmaciones medidas ejecutando) | **sigue declarado** en `requirements/REQ-013.md` como `SEC-014 (contrato)` | `REQ-013` está `en-revisión` y **no puede cerrar**: `guard-completado` deniega por un `contrato` que está cerrado. La discrepancia la encontró `R-016` §2 el 2026-09-08 y **sigue abierta dos ventanas después**. Retirarla es del `analista-requerimientos` |
| `SEC-083` | **`mitigado`** desde **hoy**, `R-027` §3 (`:8067`) | **sigue declarado** en `requirements/REQ-024.md` como `SEC-083 (contrato)` | `REQ-024` está `bloqueado` y **tampoco podría cerrar** con ese campo. **Es un defecto de mi propio cierre:** `R-027` §2 escribió explícitamente «se **retira** del campo de `REQ-016`» para `SEC-082` y §3 **no escribió la frase equivalente** para `SEC-083`. Subsanado en `R-028` §3 |

**Observación que no es mía y va sin clasificar:** el `Estado:` de `requirements/REQ-023.md` (línea
2, del 2026-09-09) sigue diciendo que **bloquea `QA-023-15` (`usuario/dinero`)**, y QA lo **retiró**
el 2026-09-09 (`docs/qa/1.34.0-req023-revalidacion-acotada-metodo.md:221`, §4), razón por la cual no
está en el campo. Texto de estado desfasado, de `analista-requerimientos`/coordinadora; **no lo
cuento** como bloqueante y **no abro hallazgo** por él.

**Y dos filas de mi índice estaban desfasadas en la dirección que sobre-cuenta:** `DEV-014-01` y
`DEV-014-02` figuran como `abierto` y su dueño (**QA**) las cerró el 2026-09-08 — consta en el propio
campo `QA:` de `requirements/REQ-014.md:8` («*DEV-014-01, DEV-014-02 y H-13 CERRADOS por QA tras
confirmar el write-back del commit `516e849`*») y ya no están en su `Hallazgos abiertos:`. **No las
cierro yo:** registro que su dueño lo hizo y dejo de publicarlas como abiertas.

---

## 4. Recuento firme de hallazgos bloqueantes sobre `b55347e`

Bajo la regla de la frontera (`docs/gobernanza/autoalojamiento.md` §«La frontera del recuento»):
**unión de las dos sedes**, y toda discrepancia **cuenta**.

| Concepto | Cifra |
|---|---|
| Clase `usuario/dinero` sin cerrar | **1** (`SEC-067`, `en-mitigación`) |
| Clase `contrato` sin cerrar | **30** |
| **Subtotal, hallazgos no cerrados en el registro** | **31** |
| **+ discrepancias** (`mitigado` en el registro y aún declarados en un campo) | **+2** (`SEC-014`, `SEC-083`) |
| **Recuento medido sobre `b55347e`, unión de las dos sedes** | **33** |
| **+ `SEC-085`**, abierto por la revisión que produce este artefacto (§5) | **+1** |
| **Recuento vigente a partir de `R-028`** | **34** |

**Las dos cifras se publican, no la más cómoda** (misma disciplina que `R-016` §3): el criterio se
mide sobre el commit que se etiqueta, y `R-028` **añade** un hallazgo bloqueante, así que toda
publicación posterior a esa revisión se mide contra **34**. `SEC-085` cuenta porque es `contrato`; la
regla del índice sólo excluye `instrumento`.

**La lista elemento por elemento, porque un recuento que no cuadra con la suya no es un recuento.**

- **De seguridad, `SEC-*` (24):** `SEC-020`, `SEC-023`, `SEC-029`, `SEC-030`, `SEC-031`, `SEC-032`,
  `SEC-033`, `SEC-034`, `SEC-035`, `SEC-036`, `SEC-038`, `SEC-039`, `SEC-040`, `SEC-041`, `SEC-042`,
  `SEC-043`, `SEC-044`, `SEC-045`, `SEC-055`, `SEC-067`, `SEC-072`, `SEC-073`, `SEC-075`, `SEC-084`.
- **De otros dueños, declarados en campos (7):** `QA-114`, `QA-116`, `QA-117` (`REQ-007`);
  `QA-017-31` (`REQ-017`); `QA-021-10`, `QA-021-11` (`REQ-021`); `QA-024-19` (`REQ-024`).
- **Discrepancias (2):** `SEC-014` (`REQ-013`), `SEC-083` (`REQ-024`).

Suma: 24 + 7 + 2 = **33**; con `SEC-085`, **34**.

**Reparto por sede, que es lo que decide si la puerta los ve:**

| Dónde vive | Cuántos | Cuáles |
|---|---|---|
| Declarados en un campo `Hallazgos abiertos:` — **la puerta los ve** | **21** | `SEC-020`, `SEC-033`, `SEC-038`…`SEC-045`, `SEC-067`, `SEC-072`, `SEC-073`, `SEC-084`, `QA-114`, `QA-116`, `QA-117`, `QA-017-31`, `QA-021-10`, `QA-021-11`, `QA-024-19` |
| Sólo en el registro, **por diseño** (write-back hecho; el residual es mi verificación y viaja por `Seguridad:`) | **5** | `SEC-031`, `SEC-032`, `SEC-034`, `SEC-035`, `SEC-036` |
| Sólo en el registro, **sin REQ atribuible** (sede real: la decisión de publicar → `PENDING_APPROVAL.md`) | **4** | `SEC-023`, `SEC-029`, `SEC-030`, `SEC-075` |
| Sólo en el registro y **debería estar en un campo** | **1** | `SEC-055` → `REQ-019` |
| Discrepancia (cerrado en el registro, vivo en el campo) | **2** | `SEC-014`, `SEC-083` |

21 + 5 + 4 + 1 + 2 = **33**.

**Contra las dos cifras que circulaban.** «17 según los campos» no se reproduce: la sede (a) da
**23** entradas bloqueantes sobre `b55347e` (lista completa en `R-028` §5 y arriba). «Hasta 23 según
el registro» sale de contar cabeceras, y por eso mezcla cuatro cerrados y omite cuatro abiertos. La
cifra que el propietario debe usar es **33** medida sobre `b55347e`, o **34** desde `R-028`, en los
dos casos con su lista.

**Re-verificación al entregar (mismo día, árbol de trabajo posterior a `b55347e`).** Mientras se
escribía esto, otra comisión modificó `requirements/REQ-017.md` (+10/−1) y `requirements/REQ-026.md`
(+137/−4). Comprobado: el campo `Hallazgos abiertos:` de `REQ-017` es **idéntico** al de `b55347e`, y
el de `REQ-026` **cambió de redacción sin cambiar su inventario bloqueante** (siguen `SEC-067`
`usuario/dinero`, `SEC-072` y `SEC-073` `contrato`). **La cifra no se mueve por esos dos cambios**,
pero se declara atribuida a `b55347e` y quien publique **re-mide**.

**Lo que esta cifra NO acredita.** No es una acreditación de publicación: el punto 4 de la frontera
obliga a re-medir sobre **el commit que se etiqueta**, y `b55347e` no es un tag. Quien vaya a
publicar **re-mide** con el método de arriba. Y bajo la frontera, cualquier recuento distinto de cero
devuelve la decisión al propietario: **34 devuelve exactamente igual que 33, que 31 o que 17**.

---

## 5. Hallazgo nuevo abierto por esta reconciliación

**`SEC-085`** — `contrato` · **abierto** · severidad **alta** · dueño `auditor-seguridad` (mío):
*el «Índice de hallazgos de clase bloqueante», que se declara «sitio único de la lista exhaustiva» y
que la frontera de publicación **cita** como tal, no es exhaustivo — y su omisión falla hacia el lado
que PUBLICA*. Entrada completa, con lo medido y la remediación, en `docs/seguridad/registro-seguridad.md`
`R-028` §4.

---

## 6. Recomendaciones, con su dueño (ninguna se aplica en este artefacto)

| # | Qué | Dueño | Sede |
|---|---|---|---|
| 1 | Declarar `SEC-055 (contrato)` en el campo `Hallazgos abiertos:` de `REQ-019` | `analista-requerimientos` | `requirements/REQ-019.md:9` |
| 2 | **Retirar** `SEC-014 (contrato)` del campo de `REQ-013` (`mitigado` desde `R-006`) | `analista-requerimientos` | `requirements/REQ-013.md` |
| 3 | **Retirar** `SEC-083 (contrato)` del campo de `REQ-024` (`mitigado` desde `R-027`) | `analista-requerimientos` | `requirements/REQ-024.md` |
| 4 | Enrutar la mitad de fondo de `SEC-055` —acotar o **retirar** la delegación de publicación— como decisión con firma | **propietario** (la coordinadora la encola) | `PENDING_APPROVAL.md` |
| 5 | Decidir `SEC-075` (entrada «Hacia 1.33.0» de `arnes-upgrade`, o la nota explícita) **antes** de publicar `v1.34.0` | `desarrollador` (la remediación), **propietario** (el tag) | `skills/arnes-upgrade/SKILL.md` · `PENDING_APPROVAL.md` |
| 6 | Corregir el `Estado:` de `REQ-023`, que sigue declarando bloqueante un `QA-023-15` retirado por QA | `analista-requerimientos` | `requirements/REQ-023.md:2` |
| 7 | Declarar como **NFR** la propiedad que cierra `SEC-085`: ningún hallazgo de clase bloqueante existe sin estar en al menos una de las dos sedes, y si su sede legítima no es un campo de REQ, entra en el índice **con su sede real declarada** | `analista-requerimientos` | `requirements/` (NFR) |
| 8 | Mover el índice a una sección `##` propia fuera de la secuencia de revisiones, con encabezado **idéntico** (remediación ya escrita de `SEC-056`, forzador disparado por esta revisión) | `auditor-seguridad` | `docs/seguridad/registro-seguridad.md` |
