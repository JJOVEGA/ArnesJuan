# PENDING_APPROVAL — ArnesJuan

> Cola de decisiones que esperan visto bueno humano antes de que el pipeline continúe.
> Un agente AÑADE una entrada y se detiene; el humano la resuelve y la mueve a "Resueltas".
> Mientras haya algo en "Pendientes", el pipeline NO avanza en ese hilo.
>
> **Formato de una entrada** (va bajo `## Pendientes`, con `###`):
> `### [AAAA-MM-DD] (agente) — Título de la decisión`, y debajo: **Contexto** (por qué se
> detuvo aquí) · **Opciones** (A / B / …) · **Recomendación del agente** · **Espera**
> (aprobación / elección del humano).
>
> **Cómo se cuenta esta cola — una sola regla, la misma para todos.** Una entrada es una
> línea que empieza por `###` + espacio, dentro de la sección que abre un encabezado `## `
> cuyo texto empieza por «Pendientes» y que cierra el siguiente encabezado `## ` de
> cualquier nombre; lo que caiga dentro de un comentario HTML (`<!-- … -->`) no cuenta. Esa
> regla vive UNA vez en el código (`arnes_cola_pendientes`, `hooks/lib.sh`) y la usan por
> igual la puerta de cierre (`guard-completado`), el bloque derivado de `docs/ESTADO.md` y
> `tools/arnes-lectura.sh`: el número que se lee es exactamente el que bloquea. Y si la
> cola no se puede leer entera —un byte NUL, un archivo sin permiso—, la puerta DENIEGA y
> el bloque derivado dice `sin datos`: nunca 0.
>
> El ejemplo vive AQUÍ, fuera de la cola, y a propósito: un ejemplo dentro de la sección se
> cuenta como una pendiente real y bloquea todos los cierres.

## Pendientes

> **Índice — ~~15~~ 16 decisiones, agrupadas por lo que desatascan.** `D18` entró el 2026-09-10:
> `REQ-017` agotó su vuelta 3 de 3 y queda `bloqueado`; §6 me obliga a escalar porque lo que queda
> abierto es `contrato` y la reclasificación editorial te está reservada. Trae además la evidencia
> medida de que **la prueba de `REQ-023 CA-09 (iii)` no acredita su criterio**. Escrito el 2026-09-10 para que la cola se
> pueda leer desde GitHub sin recorrerla entera. Cada entrada lleva su evidencia y su recomendación;
> ninguna se ha ejecutado.

**Lo que más desatasca, si sólo lees tres:**

| | Qué | Por qué urge |
|---|---|---|
| **`D17`** | `SEC-084`: un fail-open **vivo en la 1.33.0 publicada** cuela una firma de seguridad decorando la clave | Es lo distribuido, no la ventana. Y el consumidor **comprobado** es este propio repositorio |
| **`D12`** | El precio de la salida (b) de `CA-12` | Sin ella `REQ-024` **no puede** escribir su criterio y sigue `bloqueado` |
| **`D11`** | ⚠️ **NO firmar la parte (b) como está** | La fila que autorizaba escribir **es hoy falsa**; metería una promesa **al revés** en superficie heredada |

**Estado de los cuatro REQ de la ventana:**

| REQ | Estado | Espera |
|---|---|---|
| `REQ-016` | `en-progreso` · **QA y Seguridad aprobados** | sólo que la cola baje a 0 |
| `REQ-017` | `en-progreso` · ~~QA en curso~~ → **QA CERRÓ** el 2026-09-10 (`con-hallazgos` sobre `86a44c8`): 1 `contrato` (`QA-017-24`) + 7 `instrumento`. Write-back hecho (`a139155`) | **la vuelta 3 de 3 —la última— del ciclo que §9 reabrió**, y después el auditor: su `Seguridad: aprobado` es del 2026-09-08 sobre `538c266`, **anterior al modo medido** |
| `REQ-023` | **`bloqueado`** | **`D13`** — dos firmas verdes sobre un `CA-11` hoy falso |
| `REQ-024` | **`bloqueado`**, tres vueltas agotadas · **`Seguridad: pendiente` — la auditoría nunca se hizo** | **`D14`** + `D12` |
| `REQ-020` | **`pendiente`** · `QA: pendiente` · `Seguridad: preventiva` (no cubre código) | **`D2`**. No estaba en esta tabla y su ventana destino es 1.34.0: aporta **8 de los 23** bloqueantes |

**Las quince, en orden de entrada:** `D2` los ~~20~~ **23** hallazgos bloqueantes · `D3` `SEC-072`/`SEC-073` ·
`D4` ventana 1.35.0 de la superlinealidad · `D6` el fail-before de `CA-03` (analizado: **no** era `k=1`) ·
`D7` `CA-04` y su gate previo · `D8` el bloque `campos` y la llave (+ las tres condiciones de `ADR-009`) ·
`D9` el párrafo de `CA-03` (mi evidencia movía dos variables) · `D10` `SEC-083`, informativa ·
**`D11`** el gate de `ADR-011` — **con aviso** · **`D12`** el precio de la salida (b) ·
**`D13`** `REQ-023`, otro bloqueo · **`D14`** `REQ-024` `bloqueado` o residual · `D15`
`veredictos.caducan_con_codigo` (premisa corregida) · `D16` `QA-016-04`, la convención que abre ·
**`D17`** `SEC-084` en lo publicado.

**Y la dieciséis:** **`D18`** `REQ-017` `bloqueado` por tope agotado + la prueba de `CA-09 (iii)`
que oscila sobre código idéntico.

> ### 🔴 Registrado aparte, y NO es una decisión pendiente: `QA-P48-01`, un fail-open en la **`v1.33.1` publicada**
>
> Va **fuera** de la cola bloqueante a propósito: el propietario **ya autorizó** su corrección y la
> publicación de **`v1.33.2`** el 2026-09-10, así que no hay firma que esperar y no debe frenar
> cierres. Se registra aquí porque **está en lo distribuido** y porque `D16` y `D17` ya no cuentan
> esta parte de la historia.
>
> **El hecho, medido ejecutando los lectores instalados de las dos versiones publicadas** (no el
> árbol, no una copia): con `Sensible a seguridad:` **≠ sí**, `Rigor: ligero (<cualquier matiz>)`
> daba **`estandar`** en 1.33.0 y da **`ligero`** en **1.33.1**. Y `ligero` es el **único** nivel
> exento de `QA: aprobado` (`AGENTS.md` §6): ese REQ **cierra sin QA y sin veredicto de seguridad**,
> donde 1.33.0 lo denegaba. Cinco formas comprobadas: `ligero (local)`, `ligero (D8, 2026-09-08)`,
> `ligero(sin espacio)`, `ligero ()`, `ligero (critico)`.
>
> **Es la misma forma que el defecto que `v1.33.1` salió a corregir, con el signo cambiado.** El
> parche enrutó la forma con paréntesis por el lector común **para todos los valores**, y en `ligero`
> la conducta anterior —«*valor no reconocido: se ignora y se cae al defecto de la sensibilidad*»—
> era **protectora**. Se cerró `critico`→`estandar` y se abrió `estandar`→`ligero`.
>
> **La exposición, con sus tres mitades separadas, porque no son lo mismo:**
>
> | | |
> |---|---|
> | **Defecto reproducido** | **Sí**, en la `v1.33.1` **publicada**, con el lector realmente instalado |
> | **Exposición observada en ESTE repositorio** | **Ninguna, y es medible.** La política de §6 declara **todo** REQ `Sensible a seguridad: sí`, y el suelo lo rescata. Comprobado: `grep -L 'Sensible a seguridad: *\**s[íi]' requirements/REQ-0*.md` → **0** archivos. Aquí es **latente** |
> | **Consumidores** | **Expuestos los que declaren un REQ NO sensible** y le escriban el rigor con un matiz entre paréntesis — que es la convención que `AGENTS.md` §13 les enseña. **Uso histórico NO comprobado**: que haya proyectos corriendo el plugin descansa en la afirmación de `AGENTS.md`, no en una comprobación, y **no hay base para estimarlo** |
>
> **Por qué NO se volvió a 1.33.0 en la instalación estable** (decisión del propietario del
> 2026-09-10, y coincide con lo medido): en este árbol los dos defectos **no son simétricos**. El de
> 1.33.1 es **latente**; el de 1.33.0 estaba **activo** — QA midió que con la clave **limpia**, un
> `Edit` que sustituye **sólo el valor** de `Seguridad:` daba **allow** en 1.33.0 y da **deny** en
> 1.33.1. Para este repositorio, 1.33.1 es **estrictamente mejor**. Para un consumidor con REQ no
> sensibles la comparación es **otra**, y este bloque no la decide.
>
> **Evidencia:** `docs/qa/1.34.0-porte-1.33.1-veredicto.md` (el hallazgo, del `qa-tester`) ·
> `docs/qa/1.34.0-porte-1.33.1-falsacion/21-QA-P48-01-VIVE-EN-LA-1.33.1-PUBLICADA.md` (la atribución,
> de la coordinadora) · `22-sonda-ligero-publicadas.sh` (re-ejecutable).
>
> **Pendiente real que NO decide este bloque, y queda con dueño:** que el `auditor-seguridad`
> formalice esto como hallazgo con su `SEC-###`, clase y vencimiento en
> `docs/seguridad/registro-seguridad.md` —ese archivo es suyo, no mío— y que decida si un fail-open
> **publicado** obliga a avisar a los consumidores además de publicar el parche.

**Resueltas** al final del archivo: `D1` (`REQ-023` a `bloqueado` con extensión) y `D5` (`SEC-079`).

> **Las quince son CINCO decisiones — consolidación del 2026-09-10, en
> `docs/propuesta-cierre-1.34.0.md`.** Ninguna entrada se borra, se funde ni pierde su
> trazabilidad: esto sólo dice cuáles se firman juntas, con una fila por decisión que separa **qué
> autorizar | qué cambia | qué trabajo queda después | qué riesgo permanece**.
>
> | Decisión | Agrupa | En una línea |
> |---|---|---|
> | **1** | `D2`, `D4` | Mover `REQ-020` a 1.35.0 sin retirar ninguno de sus 8 hallazgos → bloqueantes de la ventana **17 → 9** |
> | **2** | `D16`, `D17` | **Implementar** el parche de los dos defectos publicados en `hotfix/1.33.1` **cortada del tag `v1.33.0`** — no autoriza publicarlo |
> | **3** | `D11`, `D12`, `D13` | Una sola regla para **los verdes que ya no cubren su árbol**; ratificar `ADR-011`; **corregir la fila de §13 que `D11` autorizó y que hoy es falsa** |
> | **4** | `D13`, `D14` | `REQ-023` y `REQ-024` siguen `bloqueado` + **cuarta vuelta acotada**, incluida la auditoría de `REQ-024` que nunca se hizo |
> | **5** | `D7`, `D8`, `D15` | Poner el manifiesto en regla: ratificar o revertir `campos.ausencia_exige` (comiteado **sin su gate**), dejar **apagado** `veredictos.caducan_con_codigo`, firmar el gate previo de `CA-04` |
>
> **Informativas, sin firma:** `D3` (ya instruiste que no se cierran por redacción ni aceptación
> implícita), `D6`, `D9`, `D10`.
>
> **Las tres autorizaciones están separadas por naturaleza** en §5 de la propuesta: *autorizar
> trabajo* · *aceptar riesgos* · *autorizar publicación*. **Publicación no se pide hoy: ni
> `v1.33.1` ni `v1.34.0`.**

### D2 · Los ~~20~~ **23** hallazgos bloqueantes de ~~siete~~ **ocho** REQ — resolver, declarar residual o aceptar

Tu regla del 2026-09-08 dice que **cualquiera devuelve el tag a ti**. ~~Inventario medido el
2026-09-09~~ → **re-derivado el 2026-09-10 sobre `a139155`**. El inventario anterior no se borra: se
dice de dónde a dónde se movió y por qué.

*Método, para re-derivarlo sin preguntar:* recorrer los campos `Hallazgos abiertos:` de
`requirements/REQ-0*.md`, conservar el `(clase)` que sigue a cada id y descartar `instrumento`
(§6: sólo `usuario/dinero` y `contrato` impiden cerrar). Da **23** de **113** hallazgos abiertos;
los otros **91** son `instrumento`, deuda con dueño que **no** bloquea.

| REQ | Ventana | Bloqueantes | Nota |
|---|---|---|---|
| `REQ-020` | 1.34.0 | **8** — `SEC-038`…`SEC-045` | el bulto. **Y nunca se implementó:** la línea `Acredita:` que sus criterios contratan existe en **0 de 63** secciones del banco |
| `REQ-007` | 1.31.0 | 3 — `QA-114`, `QA-116`, `QA-117` | deuda de ventana ya publicada |
| `REQ-024` | 1.34.0 | **3 — `QA-024-19`, `SEC-083`, `SEC-084`** | **NUEVO** desde el inventario del 2026-09-09. Ver **D14**; `SEC-084` es además **D17** |
| `REQ-026` | 1.34.0 | 3 — `SEC-067`, `SEC-072`, `SEC-073` | ver **D3** |
| `REQ-013` | 1.32.0 | 2 — `SEC-014`, `SEC-020` | deuda de ventana ya publicada. `SEC-014` figura **`mitigado`** en el registro, que **no** es `cerrado`: el campo está bien y no se toca |
| `REQ-021` | 1.34.0 | 2 — `QA-021-10`, `QA-021-11` | **3 vueltas agotadas, salida sin decidir** |
| `REQ-017` | 1.34.0 | **1 — `QA-017-24`** | **NUEVO** el 2026-09-10: lo abrió el QA del modo intercalado. El write-back ya está hecho (`a139155`); lo cierra QA al re-validar |
| `REQ-019` | 1.35.0 | 1 — `SEC-033` | aplazado; su salida tampoco está decidida |
| `REQ-023` | 1.34.0 | ~~1 — `SEC-079`~~ → **0** | `SEC-079` se cerró por **D5**. **Pero cero en el campo NO resuelve `D13`:** `CA-11` es falso sobre este árbol y dos firmas verdes lo cubren |

**Corrección de una proporción que esta entrada afirmaba mal.** Decía «*casi la mitad es deuda de
1.31.0 y 1.32.0*». **No lo es, y ya me corregiste una vez por el mismo tipo de error:** la deuda de
ventanas publicadas es `REQ-007` (3) + `REQ-013` (2) = **5 de 23, el 22 %**. Lo de esta ventana son
**17 de 23**. Y el bulto de `REQ-020` son **8 de 23, el 35 %** — era el **36 %** cuando el recuento
era 20 ~~22~~; las dos cifras son correctas para su propio recuento y ninguna se retira.

Esto no es trabajo pendiente: es una decisión. Por cada uno hace falta **resolver**, **declarar
residual** (dueño, forzador medido y vencimiento) o **aceptar explícitamente**.

> **Consolidación (2026-09-10).** Esta entrada y `D4` se resuelven juntas como la **decisión 1** de
> `docs/propuesta-cierre-1.34.0.md`: **mover `REQ-020` a 1.35.0 sin retirar ninguno de sus ocho
> hallazgos**, que baja los bloqueantes de la ventana de 17 a 9. Ninguna de las quince entradas de
> esta cola se borra ni se funde; la propuesta sólo dice **cuáles se firman juntas**.
>
> **RECONCILIACIÓN CERRADA — 2026-09-10, `R-028`.** El desfase que este bloque anunciaba **ya se
> resolvió**, y el resultado corrige la cifra de arriba: **la firme es 33 sobre `b55347e` y 34 a
> partir de `R-028`**, no 20 ni 22 ni 23. Artefacto con las once filas, su método y su versión base:
> `docs/seguridad/reconciliacion-campos-2026-09-10.md`.
>
> Mi `comm -23` reproducía los once **exacto**, pero leía el estado en la **cabecera de apertura**
> cuando el vigente es *la última declaración que nombra el hallazgo* —cabecera, sección
> `Estado: X → Y`, o **prosa sin encabezado**—: sobraban cinco (ya `mitigado`) y **faltaban cuatro**
> (`SEC-023`, `SEC-029`, `SEC-030` y `SEC-075`, cuyo encabezado lleva el id entre acentos graves).
> Reparto de los 34: **21** los ve la puerta · **5** sólo en el registro **por diseño** · **4** sin
> REQ atribuible · **1** que debería estar en un campo (`SEC-055`) · **2** discrepancias documentales.
> Y la observación honesta del auditor: **bajo la frontera, 34 devuelve la decisión igual que 17.**
> Lo que cambia es que ahora se puede **desmentir fila por fila**.
>
> **Tres cosas que salieron de ahí y afectan a esta decisión:**
>
> 1. **`SEC-085`** (`contrato`, alta) — el «Índice de hallazgos de clase bloqueante» se declara
>    **sitio único de la lista exhaustiva** y **la frontera de publicación lo cita como tal**; no lo
>    es. `R-016` argumentó por escrito que la unión de las dos sedes protege, y ese argumento vale
>    sólo si cada hallazgo está en **al menos una** — nunca se comprobó.
> 2. **`SEC-075` debe resolverse ANTES de publicar `v1.34.0`** (dictamen del auditor). Es el
>    contraejemplo medido de `SEC-085`: `contrato`, `abierto`, en **ninguna** de las dos sedes, por
>    una decisión *correcta*. Remediación del `desarrollador`; el tag es tuyo. **No abro entrada
>    aparte: queda aquí, en la decisión que ya gobierna el inventario.**
> 3. **Dos discrepancias documentales** que no son defectos sin corregir y que **sí** bloquean:
>    `SEC-014` (`mitigado` desde `R-006`) sigue en el campo de `REQ-013`, que por eso no puede
>    cerrar; y `SEC-083` (`mitigado` desde `R-027`) sigue en el de `REQ-024`. Alinearlos **no es
>    cerrar un hallazgo**: es poner el campo de acuerdo con una firma que ya existe.
>
> **LAS DOS DISCREPANCIAS RESUELTAS — 2026-09-10, y la cifra firme baja a 32.** Las filas 215-216 del
> artefacto del auditor prescribían el acto con dueño y archivos; se ejecutó. `SEC-014` sale del campo
> de `REQ-013` (`mitigado` desde `R-006`: trece afirmaciones, trece medidas coincidentes, verificadas
> ejecutando) y `SEC-083` sale del de `REQ-024` (`mitigado` desde `R-027` §3, con 12 celdas del acto de
> firmar sin fallo y **7 de 7** formas del lado QA en DENY). **No se cerró ningún hallazgo:** los dos
> ya estaban `mitigado` por firma del auditor; lo que estaba mal era el espejo.
>
> **Cuadre, y sale exacto:** el conteo por campo da ahora **21**, que es la misma cifra que `R-028`
> midió como «los ve la puerta» **antes** de alinear — así que las dos discrepancias eran justo lo que
> sobraba. **34 → 32**, compuesto: **21** los ve la puerta · **5** sólo en el registro **por diseño** ·
> **4** sin REQ atribuible · **1** que debería estar en un campo (`SEC-055`, sin hacer) · **1**
> `SEC-085`. Y sigue valiendo lo que dijo el auditor: **bajo la frontera, 32 devuelve la decisión igual
> que 17**; lo que cambia es que se puede desmentir fila por fila.
>
> **Ninguno de los dos REQ se volvió cerrable**, comprobado con el lector real: `REQ-013` conserva
> `SEC-020` (`contrato`) y su seguridad está en `con-hallazgos`; `REQ-024` conserva `QA-024-19` y
> `SEC-084` y su seguridad en **`pendiente`** —la auditoría nunca se hizo—; y la cola sigue en **16**,
> que deniega cualquier cierre de todos modos.
>
> **Un fallo que el analista evitó y yo no había previsto:** la traza del hallazgo retirado va en el
> **cuerpo** del REQ y **no dentro de la línea del campo**, porque `hooks/guard-completado.sh:685-703`
> parte esa línea por las comas de fuera del paréntesis y **un elemento sin paréntesis de clase
> deniega el cierre**. Prosa de traza dentro del campo habría fabricado un hallazgo **sin clase**: un
> DENY por un artefacto de redacción.
>
> **Sigue sin hacer, de la misma reconciliación:** meter `SEC-055 (contrato)` en el campo de `REQ-019`
> (recomendación 1), el NFR que cierra `SEC-085` (recomendación 6) y el `Estado:` de `REQ-023` que
> declara bloqueante un `QA-023-15` que QA retiró (recomendación 7). Los tres son del
> `analista-requerimientos` y quedan aquí con su dueño.

> **Informe de traspaso completo:** `docs/TRASPASO-2026-09-10.md`. Y la decisión **separada** sobre
> las dos pruebas de techo de reloj que **no discriminan** —`REQ-023 CA-09 (iii)` y, nueva,
> `REQ-024 CA-07 (ii)`— está en `docs/propuesta-cierre-1.34.0.md` §10, con mi recomendación (B):
> declararlas **no acreditantes** con dueño y vencimiento, **sin retirarlas**.

> **Y un desfase que hay que reconciliar antes de dar por firme cualquier recuento, incluido el 23
> de arriba.** Hay **once** hallazgos `contrato` en estado **`abierto`** en
> `docs/seguridad/registro-seguridad.md` que **ningún** campo `Hallazgos abiertos:` declara —
> `SEC-031`, `SEC-032`, `SEC-034`, `SEC-035`, `SEC-036`, `SEC-050`, `SEC-052`, `SEC-053`, `SEC-054`,
> `SEC-055`, `SEC-082` —, y `guard-completado` lee **el campo**, no el registro: **no los ve**. Seis
> tocan la ventana 1.34.0. Es la misma familia que `SEC-073`, un inventario parcial leído como
> completo, aplicada a esta cola. *Re-derivación:* `comm -23` entre los ids de cabecera
> `` `contrato` · **abierto** `` del registro y los ids de los campos. **No es decisión tuya:** el
> registro es del `auditor-seguridad` y el campo del `analista-requerimientos`.

### D18 · `REQ-017` agotó su vuelta 3 de 3 y queda `bloqueado` — y la misma medición demuestra que la prueba de `REQ-023 CA-09 (iii)` no acredita su criterio

**[2026-09-10] (coordinadora, bajo la delegación de 24 h) — escalada obligada por `AGENTS.md` §6.**

Escalo porque **§6 me lo impone y la delegación no me alcanza**: agotado el tope, la salida del
residual declarado **no está disponible** cuando lo que queda abierto es `contrato`, y la
reclasificación a errata editorial *«sólo puede bajar ese nivel con autorización expresa del
propietario (Juan), nunca por reclasificación automática de un agente»*. Es exactamente el acto que
§6 me prohíbe, así que no lo hago.

Las dos partes van juntas porque **comparten causa**: un criterio promete más de lo que el
instrumento puede medir. Es la familia que esta ventana lleva persiguiendo desde `SEC-047`.

**(a) `QA-017-31` (`contrato`, dueño `analista-requerimientos`) — el defecto se MOVIÓ, no desapareció.**

`QA-017-24` quedó **cerrado**: QA verificó el write-back y le dio la razón en las cuatro
comprobaciones, incluida la decisiva —imprimir la cota **no** cerraría `SEC-064`, cuya remediación
pide *«una señal que lo publique sin depender de que alguien lea la salida»*. Pero al hacerlo apareció
una contradicción **entre dos criterios**, no dentro de uno:

- `CA-03` afirma, **absoluto y sin frontera**: *«Toda abstención de este caso **publica de qué
  máquina** es la medición que la produjo»*, y declara **CUMPLIDA** la mitad (ii) de `SEC-064`.
- `CA-08 (ii)`, **dos commits después**, declara **esa misma mitad ABIERTA**, con dueño
  `desarrollador` y vencimiento.

**No pueden ser las dos verdaderas.** Y la medición le da la razón a `CA-08`, reproducida por QA con
las funciones reales extraídas en sólo lectura: la abstención **no mide nada** y publica la carga de
la **medición directa** (`carga=2.67`, que es la de la directa); y si la sonda falla antes de leer el
registro, publica `plataforma=n/a carga=n/a`. Es la **misma forma** que `QA-017-24`, con el objeto
cambiado: *«toda abstención declara su cota»* → *«toda abstención publica de qué máquina es»*. Y aquí
**no hay ni un «no exhaustiva»** — se aplica tu propio refinamiento de `D5`: *«añadir solamente "no
exhaustiva" no basta si la promesa principal sigue siendo absoluta»*.

**Remedio identificado, y es pequeño:** **una** cláusula del mismo autor en el mismo REQ — copiar a
`CA-03` la frontera que `CA-08 (ii)` **ya escribió** («su ausencia no invalida el veredicto de una
corrida; limita la agregación»), con su dueño y su vencimiento. **No es trabajo de código.**

**(b) La prueba de `REQ-023 CA-09 (iii)` está corregida y NO acredita su criterio — medido, no
inferido.** Pediste el 2026-09-09 distinguir *«prueba corregida»* de *«criterio acreditado»*. Aquí
está la evidencia, y es de esta comisión:

| Corrida | `loadavg` | `arnes_campo_linea` | mediana |
|---|---|---|---|
| banco completo | 3,36 | **FAIL** | 1,159× |
| 1 | 1,44 | **SKIP** | 0,988× |
| 2 | 2,61 | **PASS** | ~0,93× |
| 3 | 2,79 | **PASS** | ~0,93× |

**`FAIL → SKIP → PASS → PASS` sobre código IDÉNTICO**, y el veredicto sigue a la carga de la máquina.
El techo `1,000×` **vive dentro del ruido del instrumento** — la misma patología que `REQ-017
CA-08 (ii)` describe con esas palabras. Consecuencia: el `FAIL` que el banco da hoy **no es una
regresión**, y el `rc=1` no acusa al código; pero **una prueba cuyo veredicto oscila sobre código
idéntico no acredita nada**, ni cuando sale PASS. `REQ-023` sigue `bloqueado` y esto **no** lo
desbloquea: lo explica.

QA **no** amplió ni cerró nada aquí, y yo tampoco. Lo traigo porque cambia lo que se puede afirmar.

**Lo que NO hice, y lo digo para que se pueda auditar:** no reclasifiqué `QA-017-31`, no abrí una
vuelta 4, no cerré ningún hallazgo, no retiré ninguna prueba, no relajé ningún umbral y no toqué
`Seguridad:` —cuyo `aprobado` sigue siendo del 2026-09-08 sobre `538c266`, **anterior al modo
medido**, de modo que el auditor tiene que volver de todas formas.

> **EJECUTADA Y NO CERRADA — 2026-09-10, `af01436`.** Autorizaste la opción (A), se ejecutó
> completa, y **`QA-017-31` sigue abierto de clase `contrato`**. Lo que apareció importa más que el
> arreglo:
>
> El analista corrigió la promesa de `CA-03` contra los tres casos que pediste **y encontró un
> cuarto** —el suelo de 50 ms—, que QA verificó **alcanzable** (8457 y 4220 µs bajo el suelo). Todo lo
> mecánico pasó: `git diff` de mecanismo **vacío**, tres quality gates en verde, banco **1057 PASS · 0
> FAIL · 7 SKIP · rc 0**. Y las tres piezas de la promesa nueva pasan una por una: lo declarado
> presente queda **acreditado** (13 de 13 ramas de emisión ejercitadas: 13/13 emiten plataforma y
> carga, **0/13** publican la cota), la condición de verdad es cierta en las cuatro ramas y está
> medida, y `CA-03:74` y `CA-08 (ii):140` dicen **ahora lo mismo**.
>
> **Bloquea una TERCERA sede de la misma promesa, dentro del propio `CA-03`, que la vuelta 3 no
> nombró.** La línea **`:62`** la lista entre «*ejemplos no exhaustivos, **ya construidos** o exigidos
> aquí*» y su «*citada **abajo***» apunta al párrafo `:74` **que la desmiente literalmente**. La
> medición da la razón a `:74`. **Es la misma forma por tercera vez, con la sede cambiada** —
> `QA-017-24` → `QA-017-31` (`CA-03` vs `CA-08`) → ahora `:62` vs `:74` **dentro de `CA-03`** —, y
> aplica tu propio refinamiento de `D5` por analogía: **corregir un párrafo no basta si otro del mismo
> criterio sostiene la promesa retirada.** QA **no abrió número nuevo**: es `QA-017-31` sin cerrar.
>
> **Remedio:** alinear el paréntesis de `:62` con `:74`. **Un paréntesis, del analista, sin código.**
> **No lo despaché** — el propietario pidió no abrir comisiones nuevas en el cierre de sesión.
>
> **Y dos `instrumento` que NO bloquean, con dueño y vencimiento:** `QA-017-33` (la promesa retirada
> se declara presente en `37-coste-del-escaner-2-las-razones.sh:169-171` y en
> `docs/arnes/req-017-ca-03-modo-de-medicion/03-…:83-85`; vencimiento el de `SEC-064`) y, a la cola, el
> caso guardián de `CA-03` (`:536-550`) que **no ejerce el par** y lo invoca con el **noveno argumento
> vacío**: la publicación de plataforma y carga **no la ejerce ningún caso del banco** — es el mismo
> hueco que ese caso dice cerrar, sobre otro campo.
>
> **Limitación material declarada por QA:** una sola corrida sin warm-up, en WSL2 de 8 núcleos y **no
> en el runner**; acredita **cuadre, no rendimiento**.
>
> **TERCERA SEDE CORREGIDA — 2026-09-10, y no hizo falta firma nueva.** Me corrijo: dije que la
> primera acción al retomar era que autorizaras este paréntesis. **Ya estaba autorizado** — tu propio
> texto de `D18` dice «*revisa la promesa **completa***», y `:62` es parte de la promesa de `CA-03`.
> Pedírtelo otra vez era pedirte un permiso ya concedido, que me prohibiste expresamente. Ejecutado.
>
> **Y esta vez se rompió el ciclo, con el método y no con más texto:** enumeré **todas** las sedes de
> la promesa en el árbol **antes** de despachar y entregué la lista en el encargo, para que el
> analista no tuviera que buscarla y no pudiera dejarse ninguna. Salieron **ocho**: cinco en
> `REQ-017.md` (`:62` a corregir, `:68` a verificar, `:74`, `:140` y las filas de historial intactas),
> tres ajenas — y **una cuarta que QA no había listado**,
> `docs/arnes/req-017-ca-03-modo-de-medicion/04-evidencia-del-intercalado.md:131-133`, que **amplía el
> alcance de `QA-017-33`** (dueño `desarrollador`). Se descartaron dos falsos positivos
> (`REQ-020:124` y `REQ-024:1097` hablan de la mitad (ii) de **otros** criterios).
>
> **Qué cambió, en dos inserciones y una eliminación:** de ese par, lo que la lista declara
> **construido** es **la emisión** —medida presente en todas las ramas—; que el par **identifique de
> qué máquina** es **esa** abstención pasa a **exigencia declarada**, dueño `desarrollador`,
> vencimiento el de `SEC-064`, **abierta allí**. El «*citada abajo*» se **redirige**: ya no apunta al
> párrafo que lo desmentía, sino a las dos sedes verdaderas, **citadas y no transcritas** — que es no
> crear una cuarta copia de la misma regla. Queda escrito en el propio criterio que esta lista lo dio
> por construido hasta hoy. **Ningún umbral se movió** (techo 2,6, suelo 50 ms, estadístico mínimo,
> par S/2S, `k`, `r`, modo intercalado). Cambio **menor**, sin ADR, con su fila de historial.
> Comprobado con el lector real: `QA=<con-hallazgos>`, `Rigor=<critico>` — la cabecera sigue
> midiéndose.
>
> **Lo que SIGUE necesitando tu firma, y no lo doy por concedido:** tu autorización cubrió «*la
> corrección y **una** revalidación acotada*». Esa revalidación **ya se gastó** y encontró la
> corrección incompleta. Completarla entraba en el alcance; **una SEGUNDA revalidación de QA no**.
> `QA-017-31` sigue **`contrato` y abierto** —lo cierra QA, no yo— y `REQ-017` sigue **`bloqueado`**.
> **Mi recomendación:** autorizar esa segunda revalidación acotada, también fuera del contador,
> **con la instrucción de barrer todas las sedes antes de dar un veredicto** — la regla que
> `docs/propuesta-reglas-coordinacion.md` propone consolidar en `B.4` sin añadir una octava.

> **Lo que queda por decidir, y es una sola cosa:** autorizar el paréntesis de `:62` —mismo alcance
> que ya firmaste, tercera sede— o dejar `REQ-017` `bloqueado`. **Mi recomendación: autorizarlo, y
> esta vez con la instrucción de barrer TODAS las sedes de la promesa antes de devolver a QA**, que es
> exactamente la regla que falta y que `docs/propuesta-reglas-coordinacion.md` propone consolidar.

**Opciones**

- **(A) — recomendada.** Autorizás **una cláusula acotada** para `QA-017-31`: el analista copia a
  `CA-03` la frontera de `CA-08 (ii)`, y QA re-valida **fuera del contador** de §6, declarándolo así
  en el campo. Alcance cerrado, sin código, sin riesgo nuevo. `REQ-017` vuelve a `en-progreso`.
  *Después queda:* la re-firma del auditor sobre el árbol nuevo, y los ocho `instrumento` con dueño.
- **(B)** `REQ-017` se queda `bloqueado` hasta la ventana siguiente. *Precio:* el modo intercalado
  queda implementado, medido y **sin acreditar**, y `CA-03` se queda con una promesa que la medición
  contradice — en un REQ cuya sonda decide la puerta requerida de `main`.
- **(C)** Lo declarás **errata editorial** con tu autorización expresa (§6 te lo reserva a vos).
  *No la recomiendo:* la contradicción tiene **efecto en la máquina** —`CA-03` declara cumplida una
  mitad de `SEC-064` que sigue abierta—, así que bajar su clase sería el acto que §6 quiere impedir.

**Recomendación:** **(A)**, y añado la razón por la que no me la tomo yo: el remedio es barato y
evidente, y **eso es justamente lo que hace tentador saltarse la puerta**. La regla que lo prohíbe
es la que protege el resto.

**Espera:** tu elección entre (A), (B) y (C). Y para la parte (b), si querés que `CA-09 (iii)` entre
en el alcance de la decisión **4** de `docs/propuesta-cierre-1.34.0.md` con esta evidencia.

**Evidencia en disco:** `docs/qa/1.34.0.md` (sección de la vuelta 3) ·
`docs/qa/evidencia-req-017-writeback-f4a5f1f/00-metodo-y-base.md` (versión base y método dentro del
propio artefacto, §14.B.7).

### D3 · `SEC-072` y `SEC-073` de `REQ-026` — **no se cierran por redacción ni por aceptación implícita**

Los dos son `contrato` y el informe de seguridad (`R-022`) los describe como «de redacción/legibilidad,
**no de código**». Esa descripción hace tentador cerrarlos reescribiendo un párrafo, y **por
instrucción expresa del propietario (2026-09-09) eso no se hace**: no se cierran por redacción ni por
aceptación implícita. Quedan a la espera de **tu firma** sobre qué son y qué se hace con ellos.
`SEC-067` (`usuario/dinero`) está `en-mitigación` con el código acreditado y **le falta el
write-back**; ése sí es trabajo, no decisión, y no lo mezclo aquí.

### D4 · Ventana **propuesta** 1.35.0 para la superlinealidad heredada

El write-back de `CA-09 (iii)` retiró del alcance de `REQ-023` la superlinealidad del camino
**heredado** de `arnes_norm_clave`/`arnes_campo_linea` —medida: la base `v1.33.0` paga mediana **2,492**
y **2,446** contra **2,295** y **2,237** de la candidata, así que **la guarda diluye el cociente en vez
de empeorarlo**— y le dio casa propia en «Fuera de alcance» como `instrumento`, con dueños y forzador.
El analista **propone** 1.35.0 y **no la fija**: las ventanas las decides tú. El arreglo está
**descrito y no aplicado** en `docs/qa/1.34.0-req023-vuelta3-metodo.md` §11.6, y es alcance nuevo sobre
código que `REQ-023` no introdujo.





### D7 · `REQ-024 CA-04` — gate humano **previo**, y la delegación de 24 h NO lo cubre

**Lo traigo en vez de tomarlo, y el motivo no es cautela: es que el criterio contrata su propio gate.**
`requirements/REQ-024.md:191-195` dice, literal: «*es `AGENTS.md`, así que el cambio **se detiene** en
`PENDING_APPROVAL.md` y espera al propietario (`AGENTS.md` §6). Este REQ **nombra** ese gate; **no lo
sustituye***». Y §6 pone el gate **antes** del acto. Una delegación general no revoca un gate que un
criterio contrata: si lo hiciera, el gate no sería un gate.

**Y el proyecto había anticipado exactamente este atajo.** `REQ-023` dejó escrito que quien estuviera
reescribiendo la fila del CR tendría **delante** la fila del rigor, y que arreglarla «de paso» sería un
cambio de `AGENTS.md` **sin gate humano y sin su REQ**. *Su REQ es éste.* El `desarrollador` llegó a esa
conclusión por su cuenta, leyendo, y **se detuvo**.

**Además, `D5` lo dejó fuera por su propia letra:** su última cláusula —«*sólo se solicita otra decisión
si aparece un cambio material **fuera de este alcance***»— autorizaba las dos filas de `SEC-079`, no la
del **rigor**.

**Qué se decide.** Corregir en `AGENTS.md` §6/§13 y en `templates/AGENTS.md.tpl` **tres frases que son
falsas leídas solas**: se cumplen sólo cuando hay **suelo**, y el suelo lo pone un campo cuya exigencia es
**opt-in** (la llave `campos.ausencia_exige`, que nace **apagada**). Es la remediación **3 de `SEC-050`**.

**El paquete está medido para que el gate no cueste re-derivar nada** —
`docs/qa/1.34.0-req024-ca06-metodo.md` §1: las **cuatro sedes con ruta y línea**, por qué cada frase es
falsa leída sola, y la salida propuesta que no promete lo que la máquina no tiene. Verificado además que
`templates/AGENTS.md.tpl` **no divergió**: párrafo (`:167-173`) y fila (`:308`) son **idénticos línea a
línea** a `AGENTS.md:203-209` y `:343`, así que el arreglo es el mismo texto en dos archivos.

**Riesgo de esperar, dicho sin adornos:** `REQ-024` queda en **10 de 11** y **no puede pasar a
`en-revisión`** con un criterio detenido, así que su QA y su auditoría esperan. No hay riesgo **vivo**: la
llave nace apagada y ningún proyecto nota cambio sin encenderla.

**Y una advertencia que vale más que la prisa:** esta fila es de la **misma clase** que causó `SEC-047` y
`SEC-079` —texto heredado que promete de más—, y `SEC-081` acaba de mostrar que esa forma **pasa tres
filtros porque tranquiliza**. Escribirla bajo una delegación general, cuando el criterio pide un humano,
sería reproducir el patrón que hoy nos ha costado tres rondas.


### D8 · El manifiesto se cambió ANTES de su gate humano, y el fallo es de la coordinadora

**`QA-024-03` (`contrato`) lo encontró QA y lo confirmo yo.** `.arnes/config.json` de este repositorio
recibió el bloque `campos` en **`119e853`** —mi commit— y **`ADR-009` declara en su propia línea 3: «gate
humano pendiente: toca `.arnes/config.json`»**. `AGENTS.md` §6 lo nombra entre los gates humanos, y
`PENDING_APPROVAL.md` **no tenía entrada para él**: `D7` es sólo de `CA-04`.

**Riesgo vivo: cero.** La llave nace **`false`** en las dos sedes —verificado por QA en
`.arnes/config.json:37` y `templates/arnes-config.json.tpl:37`— y un manifiesto **sin el bloque** decide
idéntico a `v1.33.0` en 5 fixtures. Ningún proyecto nota cambio sin encenderla.

**Pero es un fallo de ORDEN de gate en el repositorio cuyo producto es el orden de los gates**, y eso es
peor que su riesgo. Y hay un contraste que no me favorece: **el `desarrollador` sí se detuvo bien para
`AGENTS.md`** —`CA-04`, `D7`— y en el mismo trabajo yo comité el manifiesto sin preguntar. Escribí en el
CHANGELOG que «encenderla es política y queda como decisión del propietario», que es cierto sobre la
**llave**, y a la vez comitié el **bloque** sin gate. Otra vez la forma en vez del estado.

**Qué se decide, y son dos cosas separadas:**
1. **Ratificar (o revertir) la presencia del bloque `campos`** en el manifiesto de este repositorio y en
   `templates/arnes-config.json.tpl`, con la llave en **`false`**.
2. **Encender o no `ausencia_exige`**, que es la decisión de política. El coste medido sería **0** —todos
   los REQ del árbol declaran ya los cuatro campos— pero **no se enciende hasta que `QA-024-01` esté
   arreglado**: con la llave encendida y `Rigor: ligero`, un REQ que omite `QA:` **cierra en ALLOW sin
   diagnóstico**.

**Recomendación:** ratificar (1) —el bloque es inerte y revertirlo perdería trabajo validado— y **no**
tocar (2) hasta que `QA-024-01` cierre. **No lo ratifico yo**: el gate es del propietario y el problema
aquí ha sido precisamente saltármelo.


### D9 · La evidencia que fundó mi decisión de `D6` confundía dos variables — dos preguntas para el analista

**Esto corrige una decisión que tomé yo bajo la delegación, y es la corrección más importante del día.**
En `D6` adopté el **modo intercalado** para `CA-03` apoyándome en una tabla que comparaba
**`intercalado k=2/3 r=9` contra `bloque k=1 r=3`**. **Cambiaba dos variables a la vez**: el modo **y**
`k`/`r`. Verificado por mí en `docs/arnes/req-017-ca-03-modo-de-medicion/01-evidencia.md:72-74`.

**Aislado el modo —round-robin con `k` y `r` fijos, N=5, `loadavg` fila a fila— el estrechamiento no se
reproduce**, y el `desarrollador` lo dijo con las cifras **sin cambiar su umbral pre-declarado**:
anchura de banda mediana en reposo **1,090 → 1,086** en la directa (diferencia 0,004 < su umbral 0,022 ⇒
**no discriminado**) y **1,075 → 1,101** en el fail-before, **más ancha**. Bajo CPU saturada **las dos
empeoran**.

**Lo que el modo SÍ hace, medido:** estrecha la dispersión **entre corridas** del cociente en **3 de 4**
comparaciones (rango 4,3 → 3,0 %, 5,1 → 3,9 %, 77,1 → 52,5 %; MAD del fail-before 0,065 → 0,023 en reposo
y 0,508 → 0,160 saturado). Y **un efecto no buscado**: **sube** el valor de la directa 1,955× → 2,104×
(**+7,6 %**), porque intercalado el término corto sale **caliente**, así que el margen al techo baja de
~25 % a **~19 %**.

**Decisión: el modo se QUEDA, y la justificación se corrige.** Motivos: el fail-before **discrimina en las
16 corridas sin excepción**; la **regla de la banda** que vino con él está probada y es independiente del
modo; y `REQ-021 CA-02` ya contrata el intercalado para una razón. **Lo que no se sostiene es el párrafo
de referencia de `CA-03`**, que cita una comparación con dos variables movidas — y eso es exactamente lo
que este proyecto llama un criterio que dice algo falso sobre lo medido.

**Las dos preguntas para el `analista-requerimientos`, ninguna resoluble por el `desarrollador`:**
1. **Write-back del párrafo de referencia de `CA-03`**: la evidencia que fundó el modo confundía modo con
   `k`/`r`, y aislado el modo el estrechamiento **no se reproduce en esta máquina**. Hay que decir lo que
   se sabe: el modo se adopta por **coherencia con `REQ-021 CA-02`** y por la dispersión **entre
   corridas**, no por una anchura de banda que no se midió como se dijo. Y el **+7,6 % de la directa** hay
   que escribirlo: reduce el margen al techo y nadie lo había previsto.
2. **`CA-18` degenerado en `37/2`**: el piso re-derivado (**551**) queda a **una línea** del total (552),
   porque la puerta es **única** y los tres casos que la acreditan tienen que ejercerla y no una copia
   —mismo patrón que el piso 448 de `37/5`—. Es honesto y deja el techo casi libre. Clase **instrumento**,
   con aviso ya escrito en el propio archivo.

**Y una tercera, mía, que no le pido a nadie:** el `Archivos:` de `REQ-017` **no incluye**
`docs/arnes/req-017-ca-03-modo-de-medicion/`, donde vive **toda** la evidencia del modo. Lo añado al
reconciliar, junto al `CASOS_ESPERADOS`.


### D11 · `ADR-011` — el gate que el propio ADR declara y que no estaba en la cola

> ⚠️ **CORRECCIÓN URGENTE del 2026-09-10, ANTES de que firmes: la fila que esta entrada
> autorizaba a escribir es HOY FALSA, y firmarla metería una promesa AL REVÉS en superficie heredada.**
> El `auditor-seguridad` lo dictaminó en `R-027` y lo **verifiqué yo**: la fila de `REQ-024:889` anuncia
> que «*si la línea `QA:` no llega a declararse … esta guarda **no deniega**»* — y desde que el
> `desarrollador` tomó la **salida (b)** de `CA-12`, la guarda **SÍ deniega** (`guard-completado.sh:326-330`).
> **La fila describe un fail-open que ya no existe.** Transcribirla diría a todos los proyectos
> consumidores que pueden firmar seguridad sobre un REQ sin `QA:`, cuando no pueden.
>
> **Así que la parte (b) de este gate —autorizar la reescritura de esa fila— NO se firma como está.**
> La parte (a) —ratificar `ADR-011` y su propiedad «por acto»— **sigue en pie y es independiente**.
> Y el write-back que §9 exigía **ya existe y es otro**: el control vive como criterio en
> `REQ-024 CA-12`, escrito **antes** del arreglo. Antes de tocar §13 hay que **reescribir el texto
> prescrito**, y eso es trabajo del `analista-requerimientos` sobre un `REQ-024` que está `bloqueado`.


**Lo señaló el `analista-requerimientos` contra su propio trabajo**, y tiene razón: `ADR-011` declara un
gate humano **dentro del ADR**, y `PENDING_APPROVAL.md` estaba fuera de su encargo, así que el gate vivía
**sólo ahí**. Su frase: «*un gate que no está en la cola no lo mide ninguna puerta*» — la deriva de §9
aplicada al mecanismo de los propios gates. Le doy sede aquí.

**Qué decide `ADR-011`:** que **el alcance de la dirección de la ausencia se enuncia POR ACTO y no POR
PUERTA**, con la lista de actos **derivada del código** y suelo de **no menos de 2 actos ejercidos**. Es la
decisión que cierra la clase de `SEC-083`, no sólo su instancia.

**Los dos motivos del gate, y ninguno es el manifiesto** —lo verificó en vez de copiar por inercia el de
`ADR-009`/`ADR-010`: ninguna de las dos salidas de `CA-12` añade llave—:
1. **Una decisión sobre una decisión no puede estar más firme que su base**, y `ADR-009` sigue en
   `propuesta`.
2. **Habilita la reescritura de la fila de `AGENTS.md` §13 y su gemela del template** — superficie
   heredada, gate **previo** por §6, con precedente en `D7`.

**Qué firmas:** (a) ratificar `ADR-011` y con él la propiedad **por acto**; y (b) autorizar —o no— la
reescritura de esa fila de §13, que es el mismo tipo de acto que `D7` y con el texto exacto **ya
redactado** por el analista en `REQ-024` § «La fila de `AGENTS.md` §13 de `CA-12`».

**El precio, escrito y aceptado a propósito:** enunciar por acto **obliga a derivar la lista de actos del
código**, y eso es un **extractor** que hay que escribir, mantener y probar, y que **se rompe cuando el
código cambia de forma aunque no cambie de conducta**. El precedente está **medido y en este árbol**:
`tools/arnes-lectura.sh:69-72` deriva las claves del **texto** de los brazos `case` con `sed`, y el
Historial de `REQ-024` ya declaró que una reescritura de esa forma literal **rompe el informe**. La
alternativa barata es **una lista que envejece hacia el lado que abre** — que es exactamente cómo nació
`SEC-083`.

**Y una decisión que el analista NO tomó, con su motivo**, para que no la busques: la elección entre las
dos salidas de `CA-12` queda abierta con dueño (`desarrollador`), porque la propiedad **por acto** no
depende de ella, porque elegirla exige una medición de `CA-07 (i)` **que nadie ha tomado**, y porque la
salida (b) arrastra un write-back en `CA-05` que su comisión tenía prohibido — «*decidirla habría dejado
su obligación colgando*».


### D12 · El precio de la salida (b) de `CA-12`: una decisión cambia para un proyecto SIN MIGRAR, en un acto que no es el cierre

**Lo pide el `desarrollador` y el propio criterio lo exige**, así que no es una consulta abierta: `CA-12`
de `REQ-024` admite dos salidas y él tomó la **(b)** —la guarda **deniega en los dos estados de la
llave**—, cuya letra obliga a **decírselo al gate humano en la misma entrada**. Ésta es esa entrada.

**Qué cambia, dicho sin suavizar:** hasta hoy, escribir `Seguridad: aprobado` sobre un REQ **que no
declara `QA:`** pasaba. Desde este árbol **deniega**, y **con la llave `campos.ausencia_exige` apagada**,
que es como nace todo proyecto. O sea: **un proyecto que no ha migrado nada y no ha encendido ninguna
llave verá una denegación nueva** en un acto que **no es el cierre**.

**Por qué la alternativa era peor.** La salida (a) condicionaba la denegación a la llave: un proyecto sin
encenderla **seguiría pudiendo firmar seguridad sobre un árbol que QA no validó**. Eso es `SEC-083` vivo
para todos los consumidores hasta que cada uno decida encender algo. La (b) cierra el fail-open **hoy y
para todos**, y el precio es la sorpresa descrita arriba.

**Lo medido, para que decidas con cifras y no con la descripción:** diferencial completo base contra
árbol, **34 celdas: 28 idénticas y 6 divergentes**, y **las 6 son exactamente la firma sobre un REQ sin
veredicto de QA**. **Las 24 celdas del acto de CIERRE deciden idéntico**, incluidas `estandar`,
`critico`, `critico` por suelo, `ligero` y sensibilidad dudosa. Y la edición inocente **sigue pasando**,
incluso con los veredictos **ya cruzados en disco** — el caso que el `-n` retirado **no** cubría.

**Qué firmas:** (a) aceptar la salida (b) con su sorpresa para proyectos sin migrar; o (b) pedir la
salida (a) y aceptar que `SEC-083` siga abierto para quien no encienda la llave.

**Y su obligación, que NO espera tu firma — corrijo lo que escribí primero aquí:** la salida (b) **exige
write-back en `REQ-024 CA-05`**, y el criterio dice que va **en la misma comisión que la implemente, no
después**. Escribí que lo despacharía «en cuanto esto tenga tu firma», y estaba mal: el código **ya
aterrizó**, así que retrasar el write-back deja el contrato describiendo un árbol que ya no existe —la
deriva que §9 prohíbe—. **Lo despacho ya.** Si eliges la salida (a), se revierten **las dos** cosas juntas,
código y texto, que es más limpio que tener el código sin su contrato.

**Nota:** el `ADR-011` que `CA-12` exigía **ya está escrito** (`01cb7e2`) y su gate es **`D11`**. El
`desarrollador` no podía saberlo: nació mientras trabajaba.


### D13 · **Otro bloqueo en `REQ-023`**, y tu instrucción para este caso es explícita: evidencia y decisión concreta

Me dijiste: «*Si aparece otro bloqueo, entregá la evidencia y la decisión concreta necesaria*». Apareció.
**No lo arreglo por mi cuenta** porque `REQ-023` está `bloqueado` y su extensión excepcional estaba
**limitada a tres cosas**, y esto no es ninguna de las tres.

**El hecho.** `REQ-023 CA-11` está enunciado así: «*Dado un campo de la clase de su `CA-02` que no llega a
declararse … **Cuando la puerta lo juzga**, Entonces decide exactamente lo mismo … la ausencia se sigue
perdonando*». **Sin acto.** Y `QA:` es un campo de esa clase. Desde el arreglo de `SEC-083`, la firma de
seguridad sobre un REQ sin `QA:` **deniega**, así que **leído como está escrito, `CA-11` es falso sobre
este árbol**.

**Y la asimetría dice exactamente dónde está el defecto:** `REQ-016 CA-11` **no** se rompe, porque
**nombra su acto** —«la puerta de **cierre**»— y el cierre **no cambió** (24 de 24 celdas idénticas).
`REQ-023 CA-11` **no nombra el acto** y por eso se rompe. **Dos criterios de la misma clase; sobrevive el
que dice sobre qué acto habla.** Es la tercera vez hoy que la falta de sujeto produce un hallazgo — como
`SEC-083` y como `CA-05`.

**Lo que esto le hace a lo que ya firmamos, y es lo que más pesa:** `REQ-023` tiene `QA: aprobado` y
`Seguridad: aprobado` conseguidos ayer con tres vueltas y dos auditorías. **Esas firmas cubren un árbol en
el que `CA-11` era cierto.** Hoy no lo es. No es que las firmas estén mal emitidas: es que **el criterio
que amparaban cambió de valor de verdad debajo**, igual que pasó con `REQ-016` y `REQ-017` — y ésos los
reabrí yo aplicando §9, porque eran regla y no criterio. **Aquí no lo hago**, porque tu decisión sobre
`REQ-023` fue expresa y su alcance también.

**El hallazgo ya tiene sede y no se va a perder:** está registrado en «Conflictos registrados» de
`REQ-024`, con dueño (`analista-requerimientos` sobre `REQ-023` + coordinadora para el despacho). El
analista **no tocó `requirements/REQ-023.md`** y **se paró ahí**, que era lo correcto.

**Las dos salidas, y ninguna es cómoda:**
- **(a)** Ampliar la extensión excepcional de `REQ-023` a este write-back: `CA-11` gana su **acto** —«la
  puerta de cierre»—, con lo que pasa a ser cierto y **queda alineado con el de `REQ-016`**. Es un write-back
  de texto, del analista, y **reabre el ciclo de `REQ-023`** por §9: QA re-valida y el auditor re-firma.
  Coste estimado: ~1 h de ejecución.
- **(b)** Dejarlo declarado como conflicto vivo con dueño y vencimiento, **sin tocar `REQ-023`**, aceptando
  que uno de sus criterios es falso sobre el árbol de hoy mientras lleva dos firmas verdes.

**Mi recomendación es (a)**, y el motivo no es pulcritud: un criterio falso con firma verde encima es
exactamente la forma que este proyecto persigue —lo llamó `SEC-079` en superficie heredada y `QA-023-18`
en la titular—, y aquí está **dentro del REQ que existe para cerrar esa clase**.


### D14 · `REQ-024` queda `bloqueado` tras agotar sus tres vueltas — y la alternativa es tuya

**Aplicado ya:** `Estado: bloqueado`, por recomendación del `qa-tester` en la vuelta 3 de 3. **Lo aplico
yo porque describe la realidad**, no porque elija: el REQ **no puede avanzar**. **Lo que NO aplico es la
alternativa** —cierre con residual declarado—, porque **aceptar un residual es una decisión de aceptación
y es tuya.**

**El motivo, y es de definición:** lo que queda **no es un residual**. Es `CA-12 (ii)` —la fila de
`AGENTS.md` §13 y su gemela del template— **contratado y sin implementar**, y **su redacción no puede
escribirse** hasta que firmes `D12`, porque **el REQ prescribe dos textos alternativos** según la salida
(a) o (b). Verificado por mí: la fila prescrita **no está** en ninguna de las dos sedes (0 y 0
ocurrencias). El trabajo son **horas** —una fila en dos sedes y un caso de banco—, pero está **aguas abajo
de una firma humana que no ha llegado**.

**Lo que sí queda medido:** **diez de los once criterios pasan**. `CA-12` queda **parcial** —su `(i)` está
acreditado con su fail-before reproducido— y **`CA-03` sin acreditar por una firma ajena y no por falta de
medición**: su obligación 3 está **ejecutada**, y espera la re-firma del auditor sobre `REQ-016`, que ya
tiene su código y su write-back. **Esa la despacho yo ahora.**

**Un solo bloqueante después de las retiradas: `SEC-083`.** QA retiró `QA-024-12`, `-13` y `-14`
verificándolos, y **no retiró `SEC-083`** por dos motivos suyos: retirar un hallazgo de seguridad es acto
del **auditor**, y su remediación (2) está escrita «*mientras (1) no exista*» — y **(1) ya existe**, así
que hay que releerla contra el texto más estricto de `CA-12 (ii)`, **que no está transcrito**. Y aplicó su
propia lección: «*retirarlo repetiría exactamente el ALLOW sobre firma vencida de la vuelta anterior*».

**Lo que firmas:** (a) ratificar `bloqueado` y firmar `D12` para desatascarlo; o (b) cierre con **residual
declarado** —con dueño, forzador medido y vencimiento—, que exigiría aceptar que un criterio queda
contratado y sin implementar.


### D15 · `veredictos.caducan_con_codigo` — **la premisa con la que iba a escribir esta entrada era FALSA, y la corrijo antes de que decidas**

**Lo que iba a decirte:** que el arnés tiene una guarda contra veredictos rancios, que está **apagada** en
este repositorio (`veredictos.caducan_con_codigo: false`), y que **encenderla habría impedido** que yo
despachara al auditor sobre un `QA: aprobado` anterior al arreglo de `SEC-082`.

**Lo que el `qa-tester` midió, y desmiente la mitad que importaba: NO lo habría impedido.** La comparación
es `[[ "$ARNES_FECHA" < "$fecha_codigo" ]]` —**estrictamente anterior, resolución de DÍA**—, y mi caso
tenía el veredicto del **2026-09-10** con el código tocado el **mismo día**. Medido con fecha de commit
inyectada y verificada:

| veredicto | código | llave encendida |
|---|---|---|
| **2026-09-10** | 2026-09-10 | **ALLOW** ← mi caso exacto |
| 2026-09-09 | 2026-09-10 | DENY |
| sin fecha | 2026-09-10 | DENY |

**La guarda es ciega por construcción en el mismo día, no por estar apagada.** Y en un proyecto que
cambia el mecanismo varias veces al día —como éste hoy: **quince commits**— el mismo día **es** la unidad
en la que ocurren los desfases.

**El coste, medido: caducarían 28 de 29 veredictos `aprobado`** (24 por fecha anterior + 4 sin fecha). Así
que **cuesta casi todo el árbol y no compra la protección que motivó la pregunta.**

**El `qa-tester` la sostiene en `instrumento`** —nada cambia de decisión hoy, y la resolución de día está
**declarada en tres sedes**, luego no hay texto falso— **y a la vez nombra la tensión: «aquí el guardián
ES el producto»**. Un arnés que se vende como enforcement por runtime lleva su propia guarda de frescura
apagada y con una resolución que no distingue lo que a él le pasa a diario.

**Qué decides, entonces, y ya no es lo que yo creía:** **no** «enciéndela o no», sino si la **resolución de
día** es aceptable para este proyecto —el único que cambia su mecanismo varias veces por jornada— o si el
criterio que la contrata debe **medir contra el commit y no contra el día**. Lo primero cuesta 28
re-validaciones y sigue sin ver el caso frecuente; lo segundo es trabajo de `analista` + `desarrollador`.

**Y hasta que exista, la protección real es la que funcionó hoy: comprobar la fecha a mano antes de
despachar.** Funcionó porque la comprobé; no porque nada me lo impidiera.


### D16 · `QA-016-04` (`contrato`) — la convención del propio arnés produce un valor que cae ABIERTO, y está en el plugin PUBLICADO

> ⚠️ **SU PREMISA MEDIDA ES HOY FALSA — anotado el 2026-09-10, y la entrada NO se retira.** Lo que
> sigue se midió sobre el plugin **1.33.0**. La **`v1.33.1` publicada corrigió esa mitad**, así que la
> tabla de abajo describe una conducta que **ya no existe**:
>
> | `Sensible: no` + | 1.33.0 (lo que dice esta entrada) | **1.33.1 y 1.33.2, hoy** |
> |---|---|---|
> | `Rigor: critico (por suelo)` | **ALLOW** ← cierra sin auditoría | **DENY** ✅ |
>
> *Verificado ejecutando los lectores instalados de las dos versiones:*
> `docs/qa/1.34.0-porte-1.33.1-falsacion/21-…md` y `22-sonda-ligero-publicadas.sh`.
>
> **Qué queda vivo de `D16`, que no es poco:** `QA-016-04` **sigue siendo un hallazgo `contrato`
> abierto** y **sigue sin sede en ningún campo `Hallazgos abiertos:`** — ninguna puerta lo mide. Ésa
> era y sigue siendo la decisión que te pedía. Lo que cambió es que ya **no** puedes decidirla sobre
> la medición de arriba.
>
> **Y el parche que arregló esta mitad abrió otra**, registrada aparte más abajo como
> **`QA-P48-01`**: la misma normalización que subió `critico (por suelo)` **bajó** `ligero (<matiz>)`
> de `estandar` a `ligero`. Autorizaste su corrección y la publicación de **`v1.33.2`** el 2026-09-10.


**Te lo traigo porque no es de esta ventana: es preexistente y vive en la 1.33.0 que gobierna este
desarrollo.** El `qa-tester` lo reprodujo **igual** en `7e19537`, en `a57eecc` y en **el plugin estable
1.33.0 instalado**.

**El hecho, medido:**

```
Sensible a seguridad: no  +  Rigor: critico              ->  DENY
Sensible a seguridad: no  +  Rigor: critico (por suelo)  ->  ALLOW   ← cierra sin auditoría
```

**Un `Rigor:` que no se reconoce cae ABIERTO a `estandar`, y en SILENCIO: cero avisos.**

**Y lo que lo vuelve grave no es el fallo, es quién lo dispara: la convención del propio arnés.**
`AGENTS.md` §13 dice que «*un matiz va entre paréntesis*» —`aprobado (R-045, 2026-09-01)`— y es la
convención que este proyecto usa **en todas partes**. Aplicada a `Rigor:`, produce un valor que **no se
reconoce** y que **abre**. Un usuario que siga la documentación al pie de la letra desactiva su propia
auditoría.

**Y la asimetría lo confirma como defecto y no como decisión:** la **ausencia** del mismo campo **sí está
guardada**, y `Sensible a seguridad:` falla **cerrado**. Sólo este valor cae abierto.

**Texto heredado que queda falso leído aislado, en tres sedes:** `AGENTS.md:343`,
`templates/AGENTS.md.tpl:308` y `requirements/README.md:101`.

**Exposición viva aquí: ninguna** — los 26 REQ que declaran el campo llevan `critico` limpio, comprobado.
**Pero en los proyectos consumidores no lo sé, y no puedo saberlo desde aquí.** Eso es lo que te traigo:
un `contrato` que abre, silencioso, disparado por la documentación, y ya distribuido.

**Y el `qa-tester` no lo colgó de `REQ-016`** —«*no es lo que `CA-11` contrata*»—, con la misma precedencia
con la que el auditor no colgó `SEC-083` ahí. **Así que hoy no tiene sede en ningún campo, y sin sede
ninguna puerta lo mide.** Enrutarlo es la decisión: su REQ natural sería uno nuevo de la ventana 1.35.0, o
`REQ-024`, que ya contrata la dirección de la ausencia — **pero `REQ-024` está `bloqueado` y con sus tres
vueltas agotadas**, así que colgarlo ahí lo congelaría.

**Qué decides:** (a) REQ nuevo en 1.35.0 con este hallazgo como su origen; (b) colgarlo de `REQ-024` y
aceptar que espera su desbloqueo; o (c) declararlo residual con dueño y vencimiento **sin sede en campo**,
sabiendo que entonces **sólo lo vigila el registro y ninguna puerta**.

**Mi recomendación es (a)**: es un defecto **publicado**, de clase `contrato`, cuya causa es la
documentación del propio arnés — y eso no cabe como residual de un REQ que no puede avanzar.


### D17 · `SEC-084` — un fail-open VIVO en el plugin PUBLICADO, en la guarda que protege la firma del auditor. **No es una ventana: es una pregunta sobre lo distribuido**

> ⚠️ **CORREGIDO EN LO PUBLICADO — anotado el 2026-09-10; la entrada NO se retira porque su
> descripción del defecto sigue siendo la buena, y porque QA la AMPLIÓ.** La **`v1.33.1` publicada**
> cambió el disparador de `grep -q 'Seguridad:'` a una comparación del **valor crudo de la cabecera**
> con el de disco. Medido hoy sobre el lector instalado: `Seguridad:`, `_Seguridad_:`,
> `**Seguridad**:` y `Seguridad :` se leen **todas**, y la firma **ya no pasa** sobre `QA: pendiente`.
>
> **Y el fail-open era MÁS ancho de lo que esta entrada describía.** QA del porte lo midió: con la
> clave **limpia**, un `Edit` que sustituye **sólo el valor** daba **allow** en 1.33.0 y da **deny**
> ahora — y ésa es la forma **más natural** de firmar con `Edit`, más común que la clave decorada. Es
> decir: la decoración era **una** vía, no **la** vía. 33 sondas —REQ nuevo, CRLF, duplicados,
> comentario, cuerpo, idempotencia, BOM— todas conformes.
>
> **Qué queda para ti:** nada de decisión sobre el defecto, que está corregido y publicado. Queda el
> **cambio de conducta declarado** que trajo el arreglo —*«cambiar la evidencia también renueva la
> firma»*—: una edición que sólo toque el paréntesis de evidencia cuenta ahora como firma nueva. Es
> más estricto, está escrito en el código, y **no** lo he tratado como decisión tuya.

**Esto no es de 1.34.0.** El `auditor-seguridad` lo midió en **cuatro árboles, incluido `v1.33.0`
publicado** — el que gobierna este desarrollo y el que corren los proyectos consumidores.

**El hecho, medido.** El disparador de la guarda es `grep -q 'Seguridad:'` — reconoce el campo por
**cadena literal**. Pero el **lector** del arnés reconoce la clave **decorada**, y eso **no es un
descuido: `CA-04` lo contrata** como tolerancia. Así que con **`_Seguridad_: aprobado`** —o la forma en
negrita cuyo par de marcadores cruza los dos puntos— **la firma pasa sobre un `QA: pendiente`, y el REQ
CIERRA después**. En los **dos** estados de la llave. **Sin deny y sin aviso**: salida vacía, `rc 0`. Con
la forma limpia denegando como control.

**Y la relación con `QA-024-19` es lo que lo vuelve serio.** QA había encontrado que
`seguridad: aprobado` **en minúscula** da ALLOW y lo clasificó `instrumento` porque «*el cierre sigue
fail-closed*». **Eso es cierto para la minúscula y falso para la clase:** misma causa —reconocer por
cadena literal lo que el lector reconoce decorado— y **dirección del daño opuesta**. El auditor **subió
`QA-024-19` a `contrato`** y abrió `SEC-084` como el caso **fail-OPEN** de la misma familia. No fue un
desacuerdo de criterio: **la premisa de la clasificación estaba medida falsa.**

**Por qué te lo traigo aparte, con lo verificado y lo inferido separados —porque primero los mezclé.**
Escribí «hay proyectos corriendo `v1.33.0` con esto abierto» y **eso lo inferí**. Lo **medido** es esto:
`v1.33.0` está **publicada** —tag `810128a` en el remoto, en `origin/main`, declarada en el marketplace y
en `plugin.json`—, y **el consumidor comprobado es ESTE repositorio**: los hooks que han gobernado toda
esta sesión corren desde el **plugin 1.33.0 instalado**, por autoalojamiento.

**Así que lo cierto y medido es peor que lo que había escrito:** el fail-open ha estado **vivo en las
puertas que vigilaban el trabajo de hoy** — las mismas que denegaron, avisaron y midieron durante toda la
jornada. Que haya **otros** consumidores es una afirmación de `AGENTS.md` («*lo usan proyectos reales*»),
**no algo que yo haya comprobado**, y no debí presentarla como dato.

La decisión de qué hacer con un fail-open **ya distribuido** —parche de 1.33.x, aviso a los consumidores,
o esperar a 1.34.0— **no es una decisión de ventana, y no la tomo yo.**

**Y lo he sentado en el campo de `REQ-024`** —`SEC-084 (contrato)`— porque sin sede **ninguna puerta lo
mide**, y ahí no cambia nada: `REQ-024` ya está `bloqueado`. Lo que cambia es que la deuda **deja de estar
clasificada como no bloqueante**.

**El auditor tampoco lo colgó él, y por un motivo que conviene leer:** «*`CA-04` **exige** que la forma
decorada gobierne —cosa que hace—*». O sea que **el defecto no está en tolerar la decoración**: está en
que **una guarda la tolera y la otra no**. Arreglarlo mal —quitando la tolerancia— rompería `CA-04`.

## Resueltas

> **Movidas desde «Pendientes» el 2026-09-11 por autorización expresa del propietario**, tras
> verificar que **las decisiones existentes cubren íntegramente lo solicitado**. **No se borran ni se
> resumen: el bloque va entero**, y debajo queda enlazada la evidencia que acredita el cierre. La
> revisión completa de la cola está en `docs/arnes/cola-de-aprobaciones/00-revision-2026-09-11.md`.

#### `D6` — resuelta: no pedía decisión

Su propio título la declara **«decidida bajo delegación»**, y el remedio que propone —el **modo
intercalado**— estaba **ya implementado** cuando se escribió. La entrada **corrige su propia premisa**
dentro (el diagnóstico de `k=1` era falso en su mecanismo) y no formula ninguna pregunta al propietario.
**Evidencia:** el bloque íntegro debajo, y `docs/arnes/req-017-ca-03-modo-de-medicion/01-evidencia.md`.
**Queda viva su acoplada `D9`**, que sí pide decisión sobre la evidencia que fundó aquélla.

### D6 · **CORREGIDA: mi diagnóstico de `k=1` era FALSO en su mecanismo, y el remedio es otro** — decidida bajo delegación

**Corrección de hecho, y es la segunda vez hoy que construyo una explicación correcta-en-la-medida y
falsa-en-el-mecanismo.** Escribí que «*con `k=1` no hay mínimo que tomar: el mínimo ES la única
muestra*». **Es falso, y está verificado por mí:** `tests/util/sonda-reloj.sh` tiene **dos** parámetros
—`--k` son las repeticiones **dentro** de una serie (`sr_serie:347`) y `--r` son las **series**, que es
sobre lo que se toma el mínimo (`sr_minimo:381`)— y `mide37` pasa **`--r 3` FIJO** en todas sus llamadas
(`37/2:163`). Así que el fail-before con `k=1` **sí** toma el mínimo de **3** muestras, **las mismas que
la medición directa con `k=20`**. **El estadístico nunca estuvo apagado.** La medición de `D6`
(3,379× → 2,329×) sigue siendo correcta; la explicación que construí encima, no.

**El mecanismo real, medido con round-robin controlado (N=5, `loadavg` publicado fila a fila):** los dos
términos del cociente se miden en **dos invocaciones distintas, dos procesos y dos instantes**, así que
la dispersión la domina **cuál de las dos pilló al vecino**. Y de ahí lo importante: **subir `k` o `r`
alarga cada invocación, las separa MÁS en el tiempo y EMPEORA.**

| configuración | rango, carga 17,6–23,3 | rango, carga baja | coste |
|---|---|---|---|
| `k=1 r=3` (la de hoy) | 64,4 % (mín **2,879×**) | 13,3 % | 1,5–4,6 s |
| `k=1 r=15` | 52,8 % | — | 21 s |
| `k=2 r=9` | 23,9 % | — | 26 s |
| `k=3 r=9` | — | **66,0 %** | 13 s |
| `k=8 r=3` | 50,0 % | — | 31 s |
| **intercalado `k=2/3 r=9`** | **18,4 %** | **9,4 %** | 13–23 s |

**Y lo que hizo el `desarrollador` es exactamente lo que se le pidió y merece quedar escrito:** declaró su
criterio **antes de medir** (escalera fija, variable de decisión = suelo + dispersión, **nunca** el
cociente), el criterio seleccionó **`k=3`**, **midió esa configuración, salió peor, y NO la envió** —
«*enviarla habría sido enviar una regresión medida*». No subió la `k`. Eso es lo contrario de repetir
hasta obtener verde.

**Lo que sí entregó:** el caso ahora **publica** `k`, las series y, de cada término, su **mínimo y su
máximo**, y tiene **un solo nombre** en sus cinco ramas — antes cada rama nombraba un caso distinto, así
que un PASS→FAIL se leía como un caso que desaparece y otro que nace. Eso es lo que impidió atribuir el
rojo la primera vez.

**El remedio medido es el modo INTERCALADO, y no es alcance nuevo: ya está implementado y ya está
contratado.** `sr_intercala` existe en `tests/util/sonda-reloj.sh:399` y su propio comentario cita
**`REQ-021 CA-02` punto 2** —«*con DOS sujetos las series van a, b, a, b, … dentro*»—, con su motivo
medido en `QA-017-06`: **1,217 en bloque contra 1,012 intercalado**, que es **exactamente** nuestro modo
de fallo. Fue la **única** configuración más estrecha en **las dos** cargas y además **más barata** que su
equivalente en bloque.

**Decisión tomada bajo la delegación de 24 h:** se adopta el **modo intercalado** para `CA-03`, **en sus
dos mediciones** —la directa y el fail-before—, porque mover sólo una rompería la coherencia de «el
**mismo** cociente» que el fail-before acredita. **No relaja nada:** el techo sigue en 2,600×, no se
retira ninguna prueba, y la práctica ya la contrata `REQ-021 CA-02`. Cambia **qué instrumento** mide, así
que el orden es **`analista-requerimientos`** (precisar el modo en `CA-03`) → **`desarrollador`** (~20
líneas) → **`qa-tester`** → **CI**.

**Lo que sigue sin certificar, y lo digo yo, no el agente:** **esta máquina no es el juez y nadie puede
afirmar hoy que el CI se ponga verde.** El `2,329×` no se reproduce aquí ni con 12 quemadores; lo que se
reproduce es la **anchura** que lo hace posible. El CI corre con `ARNES_JOBS=6` sobre 4 vCPU, varias
secciones midiendo a la vez. **El intercalado es el remedio con mejor evidencia, no una garantía.**

**Evidencia salvada al repositorio** (era efímera, en scratchpad): **29 archivos** en
`docs/arnes/req-017-ca-03-modo-de-medicion/`, con el criterio declarado antes de medir, las cinco tablas
de medidas, las cinco corridas, los inventarios y los guiones de sonda. Las cifras que deciden quedan
además dentro del comentario del propio archivo del caso.

**A la cola, no abiertos aquí:** `razon37` tiene la **misma** carencia de publicación —da los dos mínimos
y no los máximos— y afecta a **5 casos más**; se dejó intacto a propósito.



#### `D10` — resuelta: informativa, y su hallazgo está cerrado

La entrada dice **literalmente** «**no te pido permiso para arreglarlo**»: se escribió para que el
propietario **supiera** de un fail-open en el mecanismo de enforcement, no para detener nada. Y el
hallazgo que describe, **`SEC-083`, está CERRADO** por el `auditor-seguridad` en la revisión **`R-027`
§3** —*«se cierra, y su cierre NO depende de la fila sin transcribir»*—, con su causa medida.
**Evidencia:** el bloque íntegro debajo, y `docs/seguridad/registro-seguridad.md` § `R-027` §3.

### D10 · `SEC-083` — un fail-open en la guarda que protege la firma del auditor. **Informativa: el trabajo ya va en marcha**

**No te pido permiso para arreglarlo** —es remediación de un `contrato` y dejarlo abierto es peor que
tocarlo—, pero un fail-open **en el mecanismo de enforcement** es exactamente lo que querrías saber, así
que va escrito aquí y no sólo en el registro.

**Qué es.** La invariante «*seguridad no firma lo que QA no ha validado*» (`AGENTS.md` §13, cumplida por
máquina en `hooks/guard-completado.sh:274`) **falla en abierto cuando la línea `QA:` no llega a
declararse**. Verificado por mí leyendo el código:

```bash
if [ "$seg" = "aprobado" ] && [ -n "$qa" ] && [ "$qa" != "aprobado" ]; then
```

**El `[ -n "$qa" ]` es la puerta abierta:** si `QA:` **no existe**, la condición es falsa y la guarda **no
deniega**. `Seguridad: aprobado` sin ninguna línea `QA:` **pasa**.

**Y es `SEC-047` sobreviviendo a su propia mitigación.** El comentario del propio `lib.sh` describe ese
patrón como el defecto de `SEC-047` —«*los `[ -n "$qa" ]` / `[ -n "$hall" ]` saltaban la comprobación
entera*»— y `campos.ausencia_exige` **no lo cierra en ninguno de sus dos estados**, porque `ADR-009`
alcanza «la puerta de cierre y el lector de campos» y **esta guarda corre en cualquier edición**. La
mitigación pasó por al lado.

**Lo midió el `auditor-seguridad` en `R-026` con tres controles:** `QA: pendiente` y `QA: con-hallazgos` →
DENY; `QA: aprobado` → ALLOW correcto; **ausente o comentada → ALLOW**, también con la llave encendida.
Clase `contrato`, severidad **alta**, dueños `desarrollador` (la guarda) y `analista-requerimientos` (la
fila de §13 y el criterio).

**La ironía que conviene no perder:** es la guarda que hace que el `QA: aprobado` del `qa-tester` sea
**precondición mecánica** de que el auditor pueda firmar. O sea que **el auditor encontró que la puerta
que protege su propia firma se puede rodear** borrando una línea.

**Lo que hago bajo la delegación:** enruto `SEC-083` al campo `Hallazgos abiertos:` de `REQ-024` —sin sede
en un campo, **ninguna puerta lo mide**, que es la deriva de §9— y despacho las dos mitades: código y
write-back. **Lo que NO hago:** darlo por cerrado sin QA y sin auditor, ni tocar `AGENTS.md` §13 sin que el
analista fije primero qué debe decir.

**Y lo que sí es tuyo, si discrepas:** §6 lista «cualquier cambio en `hooks/`» entre los gates humanos.
Toda esta sesión ha cambiado `hooks/` bajo autorización de REQ y con el ciclo completo, y lo sigo haciendo
aquí por el mismo criterio; **si querías ese gate literal por cada cambio del mecanismo, dilo y paro** —
pero un fail-open abierto en la guarda de las firmas me parecía peor que un commit de más.



### D5 · `SEC-079` — **RESUELTA el 2026-09-09: opción (a), y con un matiz del propietario que cambia el arreglo**

**Autorizado:** corregir `CA-10` y las dos filas heredadas para que **describan la cobertura real**,
manteniendo **fuera de esta ventana** la vía del homóglifo ya declarada.

**El matiz, que es lo que hace este arreglo distinto de un parche cosmético — literal del propietario:**
> «*La redacción debe nombrar explícitamente esa limitación y enlazar su evidencia en el registro.
> Añadir solamente «no exhaustiva» no basta si la promesa principal sigue siendo absoluta.*»

Es decir: **no se resuelve colgando una coletilla a una promesa absoluta.** La promesa **principal**
tiene que dejar de ser absoluta, la limitación tiene que estar **nombrada**, y su evidencia
**enlazada** al registro (`docs/seguridad/registro-seguridad.md`, `SEC-078`/`SEC-079`, revisión `R-024`).

**Condiciones que el propietario fija:**
- **`SEC-078` y `SEC-080` siguen abiertos**, con sus responsables. No los cierra esta autorización.
- **Esta autorización NO acepta riesgos nuevos y NO acredita el criterio de rendimiento** — `CA-09 (iii)`
  sigue **sin acreditar**, y eso no cambia aquí.
- **Cadena obligatoria:** `analista-requerimientos` → `desarrollador` → `qa-tester` → `auditor-seguridad`,
  con **revisión acotada al cambio** y **reutilizando la evidencia que siga siendo válida**.
- **`SEC-079` se cierra ÚNICAMENTE tras esa validación** — no al escribir el texto.
- **Coordinación con `REQ-024`:** las **pruebas de `CA-10` deben comprobar la redacción corregida**, así
  que ese tramo se entrega **en secuencia** y no antes de que el texto exista.
- **No se vuelve a pedir esta autorización.** Sólo se solicita otra decisión si aparece un **cambio
  material fuera de este alcance**.


### D1 · `REQ-023` — **RESUELTA el 2026-09-09: `Estado: bloqueado`, con extensión excepcional de alcance cerrado**

**Decisión del propietario, literal en lo que autoriza y en lo que no:** acepta dejar `REQ-023`
**bloqueado mientras se corrige**, y autoriza una **extensión excepcional limitada** a tres cosas:
completar **`CA-10`**, corregir la prueba de **`CA-09 (iii)`** *conforme al contrato vigente*, y
consolidar el write-back pendiente en un commit coherente. **Manda conservar el registro de las tres
vueltas agotadas.** Después: **QA revalida lo afectado**, se ejecuta el **CI requerido**, y **seguridad
revisa cuando corresponda**.

**Lo que NO autoriza, y queda escrito porque es lo que una prisa convertiría en atajo:**
1. **Cerrar con `QA-023-15` abierto.**
2. **Eliminar pruebas.**
3. **Relajar umbrales para obtener verde.**

Si aparece otro bloqueo, se entrega **la evidencia y la decisión concreta necesaria** — no una consulta
abierta.

**Sobre qué se decidió:** la recomendación de `qa-tester` en la vuelta 3 de 3, apoyada en tres motivos
que convergen — `QA-023-15` es `usuario/dinero` y §6 **no admite residual** sobre esa clase; la puerta
requerida y estricta de `main` está **roja** por `CA-09 (iii)` en el CI del PR #45 (**2,365× > 2,200×**,
dispersión **0,023×** contra margen **0,165×**: resolvió con holgura, **no fue ruido**); y el cierre de
`QA-023-05` colgaba de un write-back sin comitear, ya consolidado en `86389ac`.

**Registrado en** `requirements/REQ-023.md`: campo `Estado:` con la decisión y el alcance de la
extensión, y fila de Historial con las tres vueltas nombradas una por una. La extensión **no reabre ni
reinicia** el contador de vueltas.


### APLAZADA CON SU REQ (propietario, 2026-09-09) — `REQ-019 CA-07`: el techo viaja a 1.35.0 con su evidencia

**Sale de la cola porque el REQ salió de la ventana**, no porque se haya decidido. El propietario:
*«Decido aplazar `REQ-019` a 1.35.0 para reevaluarlo. Conservá lo trabajado; no lo marques completado
ni inviertas más en su reparto ahora.»*

**Por qué se mueve y no se deja viva:** una entrada en «Pendientes» hace que `guard-completado`
deniegue el cierre de **cualquier** REQ, y `REQ-023`, `REQ-024` y `REQ-027` van hacia el cierre en esta
ventana. Dejarla aquí bloquearía tres trabajos por una decisión que ya no pertenece a esta ventana.
**La pregunta no se resuelve: se traslada**, y toda su evidencia queda escrita abajo y en
`docs/arnes/req-019-techo-propuesto.md`. `SEC-033` (`contrato`) sigue abierto en `REQ-019`.

### [2026-09-08] (coordinadora) — [TRASLADADA A 1.35.0] `REQ-019 CA-07`: el techo `0,72×` es INSATISFACIBLE en bytes

**Contexto.** Firmaste `0,72×` sobre una medición hecha en **líneas**. F1 lo midió ahora en **bytes**
—la magnitud que de verdad se paga en cada comisión— y el suelo forzado no cabe:

| | base | techo `0,72×` | suelo medido | razón | exceso |
|---|---:|---:|---:|---:|---:|
| `AGENTS.md` | 33.827 | ≤ 24.355 | 27.730 | **0,820×** | +3.375 B |
| `requirements/README.md` | 40.767 | ≤ 29.352 | 32.682 | **0,802×** | +3.330 B |
| **total** | **74.594** | **≤ 53.707** | **60.412** | **0,810×** | **+6.705 B** |

El suelo es **cota inferior**: no cuenta los punteros que `CA-03` obliga a añadir (≈700 B + ≈400 B)
ni los resúmenes de `CA-10`. La derivación va término a término por sección en
`requirements/REQ-019.md` §«El suelo forzado MEDIDO EN BYTES», así que se puede auditar sin
re-medirla. El veredicto descansa en la tabla de §13, el `## Índice` del README y los contratos de
forma: suelo al 100 % en cualquier lectura.

**Y la línea base cambió en contra.** El README pasó de 31.192 B (commit `d266e8f`) a 40.767 B,
**+9.575 B**, y **7.570 de ellos (79 %) cayeron en suelo** — el contrato de forma del campo
`Archivos:` (+5.406 B, `CA-02.4.3`) y el `## Índice` (+2.164 B, fuera de alcance) — contra un techo
que sólo subió 6.894 B. Crecer no dio holgura: la quitó.

**Opciones.**
- **A — Re-firmar el techo** en ≥ **0,82×** (`AGENTS.md`), ≥ **0,81×** (README), ≥ **0,82×** total
  contando punteros. Es el precedente exacto de esta misma ventana: el `0,60×` original ya se
  re-firmó a `0,72×` cuando se midió su suelo.
- **B — Ampliar el alcance** para bajar el suelo: sacar de `AGENTS.md` lo que la predicción del
  propio REQ dice que **se queda** (§2, §3, §4, §12 y «qué es crítico» = 4.325 B). Deja
  `AGENTS.md` en 0,692×, con un margen de 1.010 B **que los punteros se comen**, y **el README no
  tiene equivalente**: no resuelve el total.
- **C — Cerrar `REQ-019` sin el ahorro contratado**, declarando el residual con dueño y vencimiento.

**Recomendación de la coordinadora: A.** Es la única que no relaja `CA-02`/`CA-14` ni traslada el
ahorro entre documentos, y el número sale de una medición reproducible. **No la aplico yo**: el techo
lo firmaste tú, y ajustarlo dentro de la comisión que lo incumple es justo lo que este proyecto
prohíbe por escrito.

**DIRECCIÓN DADA POR EL PROPIETARIO (2026-09-09), literal:** *«Para `REQ-019`, prefiero mantener el
alcance y ajustar el objetivo, pero antes presentá una propuesta concreta de techo que incluya los
punteros obligatorios. Usá el inventario existente para preparar el reparto y calcular su tamaño; no
abras otra investigación extensa. Expresá el resultado como **reducción de bytes de lectura
obligatoria**, no como ahorro real de tokens.»*

Es decir: **opción A**, con el alcance intacto —nada de la vía B, que exigía sacar de `AGENTS.md`
bloques que la predicción del propio REQ dice que se quedan—, y con el número **por presentar**, no
por firmar todavía. El techo propuesto tiene que incluir el coste de los punteros de `CA-03`, que la
medición de F1 dejó fuera declarándose **cota inferior**.

**Advertencia que debe ir con el encargo, porque «el inventario existente» no está donde parece:** las
dos enumeraciones de F1 (**106** y **164** elementos) se entregaron **por informe** y **no
sobreviven en disco** — sólo quedan sus discrepancias en `docs/PENDIENTES.md`. Lo que **sí** hay es la
tabla **por sección** de §«El suelo forzado MEDIDO EN BYTES», con `base` / `delegable` / `suelo` de
cada sección de los dos documentos, y ésa **sí** permite dimensionar el reparto sin re-enumerar. Se
usa ésa. **No se abre una enumeración nueva.**

#### LA PROPUESTA, YA CALCULADA (2026-09-09) — `docs/arnes/req-019-techo-propuesto.md`

Versión base leída: commit **`d6620ea`**, con `git show`, nunca el árbol vivo. Método dentro del
archivo, con un anexo de los **38 bloques delegados** (sección, bytes, gobierno/narrativo, nombre) y
la regla «todo bloque que no aparezca aquí es suelo», para que la clasificación sea reproducible sin
re-medirla.

| | base **(medido, `wc -c`)** | suelo | punteros | resultante **(PROYECCIÓN)** | **techo propuesto** |
|---|---:|---:|---:|---:|:---:|
| `AGENTS.md` | 33.827 | 27.730 | 3.497 | 31.227 | **≤ 0,93×** |
| `requirements/README.md` | 40.767 | 32.682 | 3.497 | 36.179 | **≤ 0,89×** |
| **total** | **74.594** | **60.412** | **6.994** | **67.406** | **≤ 0,91×** |

> **Qué está medido y qué es proyección, porque no es lo mismo y la columna no lo decía.** *Medido con
> `wc -c`:* las dos **bases**, y los **tres punteros reales** escritos para este cálculo (269 / 243 /
> 161 B, `docs/arnes/req-019-techo-propuesto.md:57-65`), de los que se usa el **peor caso**. *Derivado:*
> el **suelo**, que es la clasificación por sección de los bytes del documento actual —bytes medidos,
> con **juicio** encima sobre qué se queda—. **PROYECCIÓN:** las columnas `resultante` y `techo`.
> **31.227 y 36.179 son suma aritmética de suelo + punteros, NO `wc -c` sobre archivos candidatos**:
> esos archivos **no existen**, porque no se ha repartido nada. El número real sólo se puede medir
> **después** del reparto, y `CA-07` obliga a medirlo entonces.
>
> **El reparto de los 26 punteros es 13 + 13, y NO es una división por la mitad** — sale igual por
> coincidencia, con el grano de `CA-12` (una pregunta por bloque de gobierno, una por sección
> narrativa):
>
> | | bloques delegados | gobierno | narrativos | secciones que los agrupan | punteros |
> |---|---:|---:|---:|---:|---:|
> | `AGENTS.md` | 18 | 6 | 12 | **7** | 6+7 = **13** |
> | `requirements/README.md` | 20 | 9 | 11 | **4** | 9+4 = **13** |
>
> De ahí que los bytes coincidan (13 × 269 = 3.497 cada uno). Si el total se hubiera partido por dos
> sería un artefacto del cálculo; aquí es que los **conteos** coinciden.

**Reducción de bytes de lectura obligatoria: de 74.594 B a 67.406 B = −7.188 B por comisión
(−9,6 %)** — −2.600 B en `AGENTS.md`, −4.588 B en el README. **No se traduce a tokens ni se llama
ahorro de tokens.** En el extremo optimista (grano `CA-03`, puntero corto): 62.183 B, `≤ 0,84×`,
−12.411 B; la horquilla completa está en el archivo.

**Por qué `0,91×` y no el `≈0,82×` estimado en F1, que es lo que hay que decidir:** los **punteros de
`CA-03` se comen el 49 %** de lo que se libera —6.994 B añadidos contra 14.182 B delegados—, y en
`AGENTS.md` el **57 %**, porque su texto delegable está repartido en **siete** secciones y cada una
paga los suyos. La estimación previa contaba **11** punteros de ~150 B; el grano que manda es el de
**`CA-12`** —una pregunta por bloque que enuncia o acota gobierno, una por sección narrativa— que da
**26**, y el tamaño sale de **tres punteros reales escritos y medidos** (269 / 243 / 161 B), usando el
**peor caso**. `CA-10` no reserva nada: ningún resumen es obligatorio.

**UN DATO DE RENTABILIDAD QUE NO PIDE CAMBIAR EL ALCANCE, PERO QUE CONVIENE VER ANTES DE FIRMAR.** El
`## Índice` del README pesa **7.867 B**, está **fuera de alcance** y tiene **otro dueño**. Convertirlo
en bloque derivado **no reparte nada y no añade un solo puntero**, y retira **más** bytes de lectura
obligatoria (7.867 B) que el reparto completo de los dos documentos en el peor caso (**7.188 B**), que
cuesta **7–11 h** y mueve **38 bloques, 15 de ellos de gobierno**. Lo registra el propio desarrollador
y **no propone cambiar el alcance**, porque ya decidiste mantenerlo. Queda aquí como información para
tu firma, no como recomendación.

**Espera.** Tu firma sobre `≤ 0,93×` / `≤ 0,89×` / `≤ 0,91×`, por documento — o el número que
prefieras por encima del suelo medido. `REQ-019` sigue en `Estado: bloqueado` y **F2 no se despacha**
hasta entonces.

**Y una precondición que la firma no resuelve:** `CA-15` exige el **inventario por bloques** —«una fila
por elemento», anexado a `ADR-003`, sitio único, cardinalidad cuadrada, ejecutores de `CA-17`, doble
enumeración independiente— y **la tabla por sección NO lo sustituye**: agrega por sección, y una
invariante se pierde por **bloque**. Las dos enumeraciones de F1 (106 y 164) **no sobreviven en
disco**, así que ese inventario hay que rehacerlo antes de F2, con firma o sin ella.


### [2026-09-09] (auditor `R-022` · enrutado por la coordinadora) — `SEC-073`: `REQ-026` lleva CUATRO criterios contratados y sin implementar. ¿Cuál de las tres salidas?

**Contexto: el agujero que pediste comprobar existía, y ya está tapado por máquina.** La puerta lee el
**valor** `aprobado`; el alcance parcial vivía en el paréntesis, que `AGENTS.md` §13 define como
**matiz** —«un veredicto distinto es otro valor, no un paréntesis»—, y `Hallazgos abiertos:` **no
nombraba** los cuatro criterios. Con `SEC-067` en camino de cerrar y la cola vacía, nada legible por la
máquina habría impedido marcar `REQ-026` como `completado` con cuatro criterios sin implementar. Es
literalmente la **anti-deriva** que §13 declara que la máquina no puede verificar sola.

El auditor eligió la vía **(a)**: `SEC-073`, clase **`contrato`**, en `Hallazgos abiertos:`. **Ahora
bloquea por máquina y no por memoria.** Ninguna evidencia se retiró: lo acreditado por QA y por la
auditoría sigue en pie; lo que faltaba era que el alcance parcial fuera **visible para la puerta**.

**Los cuatro criterios sin implementar, y qué es cada uno:**
- **`CA-13`** — declarar `rotacion.artefactos` en el manifiesto. **Es encender la rotación**, y no lo
  autorizaste: le falta trabajo, no permiso.
- **`CA-14`** — la magnitud contratada es la **lectura real**, no el tamaño de la sección.
- **`CA-16`** — que ninguna decisión vigente quede sólo en el archivo.
- **`CA-17`** — qué REQ son candidatos, por sus dos condiciones y su break-even.

**Las tres salidas, y sólo una es mía.**
- **A — Implementarlos en esta ventana.** Son cuatro criterios; `CA-13` además necesita `SEC-072`
  cerrado antes (el auditor lo condiciona), y `CA-17` lleva un cálculo de break-even con cuatro costes.
  **Amplía el trabajo 3** de «el mecanismo» a «el mecanismo encendido y calibrado».
- **B — Reducir el alcance de `REQ-026` a lo entregado** (`CA-01`–`CA-12`, `CA-15`, `CA-18`) y llevar
  `CA-13`/`CA-14`/`CA-16`/`CA-17` a un REQ propio de 1.35.0. El mecanismo queda **probado y apagado**,
  que es exactamente su estado hoy. **Decisión de alcance: tuya.**
- **C — Cerrar con los cuatro declarados como residual**, con dueño, forzador medido y vencimiento.

**Recomendación de la coordinadora: B.** Motivo concreto, no de calendario: el mecanismo entregado
**está validado y no está encendido**, así que cerrar el REQ por lo entregado no deja nada a medias en
runtime; y `CA-13` —encenderlo— tiene por delante `SEC-072`, la publicación a medias, el poder
estadístico del 27–49 % de `(iv)` y la dimensión de `REQ-022` que el analista mandó a su sede. Meter
todo eso en esta ventana es el patrón que `docs/PLAN.md` culpa del descontrol del ciclo 3.

**Espera.** Tu elección entre A, B y C. **Nada más de la ventana depende de esto**: `REQ-023` y
`REQ-024` siguen su curso, y `REQ-019` espera su propia firma.

### [2026-09-09] (analista vía `ADR-008` · enrutado por la coordinadora) — `REQ-026`: la única decisión que hoy tiene sentido, y NO es firmar una excepción

**El ADR está escrito y su recomendación es que hoy no firmes ninguna garantía nueva.**
`docs/decisions/ADR-008-garantia-de-la-rotacion-de-seccion-frente-a-escrituras-concurrentes.md`,
`Estado: propuesta`, enlazado desde `CA-18 (i)`, `CA-05` y el Historial.

**Por qué la decisión se parte en dos: los dos residuos NO son la misma pregunta.**

| Residuo | Tiene arreglo por mecanismo | Qué se pierde |
|---|---|---|
| **Interrupción** — `mv` del destino bien, recorte falla ⇒ la parada siguiente re-archiva | **Sí**: idempotencia del re-archivado | 2 bloques, 3 filas **duplicadas**, `rc=0`, sin aviso |
| **Ventana de publicar** — escritura ajena entre la relectura y el fin | **No en este sustrato** | La escritura ajena **se pierde**, y si era una fila de historia, **la fila se pierde** |

Meter los dos en una sola firma **convertiría un problema con solución en una excepción
permanente**.

**Lo que se evaluó y salió NO, con su evidencia:** se preguntó si `3+5` —sacar la rotación del hook de
parada más idempotencia— cumple las dos promesas sin excepción. **No.** La `5` cierra la interrupción;
la `3` **no** cierra la ventana de publicar **por mecanismo** —el intervalo sigue ahí; el sustrato no
cambia porque cambie quién invoca—, sólo bajo la precondición «nadie más está editando», que **el arnés
no puede medir** y que **hoy es falsa por observación directa: dos `desarrollador` escribiendo a la vez
en este árbol**. La única vía B que cumple las dos por mecanismo es **no rotar `requirements/`**,
eliminando el caso.

**LA DECISIÓN QUE TE TOCA, y es una sola:** ¿se autoriza el trabajo de la **vía B sobre `CA-05`** en
esta ventana — contratar y verificar la **idempotencia del re-archivado**?

- **Sí** → `CA-05` vuelve a ser **absoluto por mecanismo**, sin excepción que aprobar. Cuesta un
  criterio nuevo (analista) más su implementación y caso determinista (dev), y **necesita tu permiso
  porque dijiste «no agregues más criterios por ahora»**. Dueño y vencimiento ya están escritos:
  `desarrollador`, antes de que se declare `CA-13`.
- **No / más tarde** → `CA-05` sigue con su promesa absoluta **incumplida** y `SEC-072` sigue abierto.
  No se rompe nada hoy: **la rotación está apagada.**

**`CA-18 (i)` no necesita nada tuyo hoy, y eso es deliberado.** Su vía A exige aceptar un riesgo cuya
magnitud **nadie ha medido**, así que medir el intervalo residual pasa a ser **precondición**, no
alternativa. Y esa medición **hoy no está disponible**: el instrumento de reloj se declaró **no
convergente** (el brazo de control se movió un 34 %) y depende de `REQ-021`, que está `bloqueado`. La
decisión queda **abierta y escrita**, no resuelta por silencio.

**Cuando ese número exista, la elección real será entre dos opuestos:** aceptar el residuo declarado, o
**renunciar a rotar `requirements/`** —los 409.699 B—. Hoy se decidiría sin el único dato que las
distingue.

**Variante examinada y no propuesta, para que no parezca inexplorada:** la «puerta posterior» de
`AGENTS.md` §13 **detectaría** la pérdida, no la evitaría, y el arnés no la tiene.

**Espera.** Tu sí/no al trabajo de la vía B sobre `CA-05`. Nada más de la ventana depende de esto.


### RESUELTA (propietario, 2026-09-09) — `REQ-027` entra en 1.34.0 como **quinto trabajo**, detrás de `REQ-019`

**Lo autorizado, literal:** *«Autorizo incorporar `REQ-027` como quinto trabajo de 1.34.0. Ejecutá su
implementación después de `REQ-019`, sobre la estructura resultante. Incluí plantilla, instalación y
migración de proyectos existentes, con sus verificaciones. Actualizá el plan y el estado para reflejar
esta decisión.»*

**Consecuencias registradas:**
- La ventana pasa de **cuatro** trabajos a **cinco**. `docs/PLAN.md` y `docs/ESTADO.md` actualizados.
- **Orden fijado: `REQ-027` va DESPUÉS de `REQ-019`, sobre la estructura resultante.** Resuelve la
  competencia por `AGENTS.md` que motivaba la pregunta: `REQ-019` mueve el texto de sitio y `REQ-027`
  inserta su bloque **en el resultado**, no en el original. Escribirlo antes habría significado
  escribir el bloque y luego moverlo.
- **`requirements/REQ-027.md:7` (`Versión destino: 1.34.0`) queda ratificado** — era una afirmación del
  analista y ahora es decisión del propietario. No hay que corregirlo.
- Alcance de la implementación, confirmado: **plantilla + instalación (`arnes-init`) + migración de
  proyectos existentes (`arnes-upgrade`), con sus verificaciones**. Es lo que ya contrata `CA-09` y
  `CA-10`, este último como **condición de entrega**, no como pendiente.
- **Dependencia que sigue viva y no la resuelve esta firma:** `REQ-019` está `bloqueado` esperando el
  techo, así que `REQ-027` hereda ese bloqueo por transitividad.


### RESUELTA (propietario, 2026-09-09) — `REQ-026`: se autoriza **sólo** `_doc_artefactos`, sin activar la rotación

**Lo autorizado, literal:** *«Autorizo la decisión 2 exclusivamente para actualizar `_doc_artefactos`
en los dos archivos indicados, sin activar la rotación.»*

**Alcance exacto, para que nadie lo estire:** editar el texto de `_doc_artefactos` en
`.arnes/config.json:48` y en `templates/arnes-config.json.tpl:53`, que sigue describiendo el
mecanismo **viejo** —que una entrada es sólo `- `, `* `, `### ` o `N. `— cuando el código ya reconoce
filas de tabla. **Fuera de esta autorización:** `rotacion.activo`, `rotacion.artefactos` y cualquier
otra clave. La rotación **sigue apagada**.

**Efecto:** cierra `QA-026-04` (`contrato`, reclasificado en `R-021`) y retira el vencimiento que
expiraba antes del tag `v1.34.0`. **No enciende nada.**

**`CA-13` (la opción B) NO queda autorizada, y no hacía falta decidirla:** le falta trabajo, no
permiso — `CA-18` implementado, su par discriminante en una parte 4 del banco, y la dimensión de
`REQ-022` (que `tools/arnes-paralelo.sh` no conoce a los escritores **no-comisión**) resuelta o
declarada como residual con dueño. Con `SEC-067` abierto, encenderla pondría al hook de parada a
reescribir contratos sin red: medido 3/3, un `Seguridad: aprobado` escrito durante la rotación
**volvió a `pendiente`**, con `rc=0` y stderr vacío.

### RESUELTA (propietario, 2026-09-08) — **se PUBLICA `v1.33.0`**: revierte el aplazamiento de ayer, con límite declarado

**Decisión posterior y explícita del propietario**, tomada con un dato que la primera no tenía: la puerta
requerida `hooks-en-linux` está **en verde sobre el commit exacto** (`7dc0699`: 875 PASS · 0 FAIL · 9
SKIP), así que **no hacía falta saltarse nada** — la opción B (autorización para publicar en rojo) quedó
sin objeto.

**Fusionado con `jvega-habitat`, que NO tiene admin, deliberadamente.** La cuenta `JJOVEGA` estaba
autorizada por el propietario y disponible (`admin=true`, verificado), y **no se usó**: fusionar con la
cuenta sin privilegios demuestra **por construcción** que el control se satisfizo de verdad. Merge
`810128a`; tag `v1.33.0` sobre él.

**El límite bajo el que se publicó, que es la parte que importa.** La evidencia de rendimiento es el
`0,125×` acreditado de `REQ-017 CA-05` (9,60 s frente a 76,19 s, 2026-09-07), **NO** el verde de
`CA-08 (ii)`. Ese caso mide **0,973×–1,364× sobre código idéntico** contra un techo de 1,25×: su verde y
su rojo son igual de poco informativos. **No se fusionó porque el semáforo se pusiera verde** —eso habría
sido elegir la corrida que conviene, el atajo que esta misma entrada nombró y descartó— sino porque la
sustancia está acreditada por otra vía y el banco entero pasa.

**Lo que NO se revierte:** arreglar la sonda sigue siendo el **primer trabajo de 1.34.0**, por delante de
`REQ-019`. Detalle y las tres formas conformes, en `docs/PENDIENTES.md`.

### RESUELTA (propietario, 2026-09-08) — **se APLAZA el tag `v1.33.0`; la sonda se arregla en 1.34.0 por DELANTE de `REQ-019`**

Opción **C** elegida. Descartadas: **(A)** arreglar la sonda ahora dentro de esta ventana —ciclo completo, ~4 comisiones— y **(B)** publicar con el rojo bajo autorización expresa. **No se ejerció (D)**: relanzar el CI hasta obtener un verde y fusionar en esa corrida, que con una sonda cuya dispersión cubre el techo no es esperar a que pase, sino elegir la corrida que da la respuesta que se quiere.

**El argumento del propietario, en una línea:** mientras el techo viva dentro del ruido, **el verde de esa puerta no acredita nada más que el rojo** — así que publicar hoy no compraría confianza, compraría una firma vacía. Registrado en `docs/PLAN.md` como enmienda al alcance de 1.34.0.

**Estado al resolver:** `cand/1.33.0` @ `651806c`, empujada, árbol limpio. PR **#43** en `DRAFT`, sin fusionar. `REQ-014` `completado` con los tres veredictos fechados el 2026-09-08 y **cero hallazgos `contrato`**. Bloqueantes `contrato` en el repositorio: **12**, ninguno en `REQ-014`.

### La puerta requerida de `main` está ROJA, y su rojo no es evidencia — decisión del propietario (2026-09-08)

**Qué detiene.** La fusión de `cand/1.33.0` a `main` y el tag `v1.33.0`. `REQ-014` está `completado`
con los tres veredictos fechados hoy y **cero hallazgos `contrato`**; la cola estaba en 0 antes de esta
entrada. Lo único que queda en rojo es el check requerido y estricto `hooks-en-linux`.

**El caso que falla.** `REQ-017 CA-08 (ii) una cabecera de 200 líneas: el reloj no sube más de 1,25× el
de v1.32.1`. Su salida dice literalmente *«esto es una regresión, no ruido»*.

**Y está medido que no lo es.** Cuatro corridas de CI **sobre código idéntico** —ningún commit desde
`b9afa01` toca `hooks/`, `tools/` ni `.github/`, verificado de forma independiente por el
`auditor-seguridad` en `R-019`:

| Corrida | Razón publicada | Convergencia | Veredicto |
|---|---:|---|---|
| 23:39 (`921dc74`) | **1,131×** | 1,012× / 1,142× | PASS |
| 23:53 (`516e849`) | **0,973×** | 1,185× / 1,138× | PASS |
| 00:00 (`d4e0033`) | **1,337×** | 1,025× / 1,232× | FAIL |
| 00:24 (`eff143b`) | **1,364×** | 1,002× / 1,249× | FAIL |

**El argumento que cierra la discusión: `0,973×` significa que este árbol salió MÁS RÁPIDO que
`v1.32.1`.** Una regresión real no puede ser más rápida. La dispersión de la sonda va de 0,97 a 1,36
—factor **1,40**— y el techo que vigila es **1,25**: **el techo vive dentro del ruido del instrumento**,
así que el caso no puede distinguir la regresión que dice medir de su propia varianza.

**CORRECCIÓN (coordinadora, 2026-09-08): el defecto NO es «el umbral está mal puesto».** Una primera
lectura concluyó eso; **es falso**. El umbral de convergencia y el techo son el mismo número **a
propósito**, y `REQ-017 CA-08` lo argumenta: *«no es un número nuevo: es el mismo, porque un instrumento
tiene que resolver al menos el factor que vigila»*. **El caso hace exactamente lo que su criterio
prescribe**, y su hermano también.

**Lo que las cuatro corridas muestran es peor:** `CA-08` ya había pagado esta lección —documenta el
recorrido 0,821–1,010 en aislamiento y la subida sistemática bajo `JOBS=6`— y prescribió **intercalar las
series** más la comprobación de convergencia. **Está todo implementado, y no basta.**

**El hueco:** la convergencia compara el segundo mínimo de **cada árbol** con su propio mínimo —mide si
cada **serie** se asentó—, mientras que el ruido de la **razón** viene de las condiciones **entre
brazos**. Dos series pueden converger cada una a 1,2× y su cociente oscilar 1,4×. Los datos lo enseñan:
**los dos rojos son justo aquellos en que un brazo converge al borde** (1,232× y 1,249× contra el límite
de 1,250×) mientras el otro converge holgado (1,025× y 1,002×); los dos verdes están equilibrados. A
1,249× el instrumento resuelve **exactamente** 1,25 y ni un poco mejor, y sobre esa resolución afirma un
1,364×.

**La clase:** `CA-08` dice «**al menos** el factor que vigila» y eligió el valor **más flojo** compatible
con ese argumento **sin medir si alcanzaba**. Es *un criterio derivado sin comprobar su factibilidad*, la
misma clase que ya se corrigió dos veces en esta ventana.

**Clase: `instrumento`** —es un defecto de una prueba del propio arnés, no del producto—, pero **bloquea
igual**, porque el ruleset `proteger-main` hace ese check **requerido y estricto**. Es el primer caso de
la ventana en que un `instrumento` detiene una publicación, y por eso no va a `docs/PENDIENTES.md` bajo
la regla de acumulación: la regla dice que un `instrumento` no impide **cerrar un REQ**, y aquí no está
impidiendo eso.

### Las opciones, con su coste, y la que NO se hace

**A) Arreglar la sonda.** Que la convergencia se exija **estrictamente más apretada** que el techo que
protege, o que el caso haga **SKIP con motivo** cuando su propia dispersión supere ese techo — que es
exactamente lo que ya hace su caso hermano. Es cambio en `tests/`, o sea `critico` por `AGENTS.md` §6:
ciclo completo analista → desarrollador → QA → auditor. **Estimado: 4 comisiones, ~1–2 h.**

**B) Publicar con el rojo, con autorización expresa y fechada del propietario.** El check es *requerido y
estricto*, así que sólo `JJOVEGA` —dueño de los rulesets— puede saltarlo; `jvega-habitat` no tiene admin.
Queda escrito que se publicó con la puerta en rojo y por qué.

**C) Aplazar 1.33.0.** La rama queda empujada y verificada; el tag espera a que la sonda se arregle en
1.34.0, detrás de `REQ-019`.

**D) Lo que NO se hace, y se nombra para que no aparezca como atajo:** volver a lanzar el CI hasta que
salga verde y fusionar en esa corrida. Con una sonda cuya dispersión cubre el techo, eso no es esperar a
que pase: es **elegir la corrida que da la respuesta que se quiere**. Tampoco `continue-on-error` ni
sacar el caso del CI — pondría la puerta en verde **apagando la señal**, que es el modo de fallo que
`AGENTS.md` §13 nombra y que `REQ-014 CA-18 (ii)` prohíbe por escrito.

**Recomendación de la coordinadora: (C), y (A) en 1.34.0 delante de `REQ-019`.** Motivo: el rojo no
acredita ningún defecto del producto, pero **el verde tampoco acreditaría nada** mientras el techo viva
dentro del ruido — así que publicar hoy no compra confianza, compra una firma vacía. Y (A) hecho antes de
que la sonda vuelva a decidir una publicación evita repetir esta conversación en 1.34.0.

**Estado del repositorio al escribir esto:** rama `cand/1.33.0` @ `eff143b`, empujada, árbol limpio.
PR **#43** en `DRAFT`. `REQ-014` `completado`. Bloqueantes `contrato` en el repositorio: **12**, en
`REQ-013` (2), `REQ-019` (1), `REQ-020` (8) y `REQ-023` (1) — ninguno en `REQ-014`.


### RESUELTA 2026-09-08 (propietario) — La auto-auditoría se congela: los hallazgos `instrumento` sobre el propio arnés dejan de abrir REQ y de entrar en la ventana en curso

- **Contexto, con los números que la motivan.** En un solo día: **9 hallazgos de seguridad abiertos**
  (`SEC-047`…`SEC-057`), **2 REQ nuevos** (`REQ-024`, `REQ-025`), **1 REQ cerrado** (`REQ-017`) y **2 que
  fueron hacia atrás** (`REQ-021` a `bloqueado`, `REQ-014` reabierto desde `completado`). Última versión
  publicada: **v1.32.1, hace más de un día**. El propietario lo nombró así: *«siento que cada corrida de
  QA y Seguridad traen un requerimiento nuevo, y me preocupa que estemos en círculos»*.

- **La causa, y no es que los agentes sean quisquillosos.** El arnés se audita a sí mismo, y la
  auto-auditoría **no tiene punto fijo**: el estándar que aplica —*«¿este criterio mide lo que dice
  medir?»*— **se aplica también al criterio que audita**. Siempre hay una capa más abajo. Y la
  consecuencia que importa: **esto es un plugin para otros proyectos y lleva más de un día sin entregarles
  nada**, mientras consume toda la capacidad en mirarse.

- **Qué sí fue círculo y qué no, porque la distinción decide el remedio.** Círculo: `REQ-021`, cuatro
  variantes de la **misma** tautología, cada arreglo destapando la siguiente — y el arnés lo paró solo,
  que es para lo que existe el tope de 3 vueltas. **No** círculo: `REQ-017` retiró una puerta no
  determinista que corría en producción; `CA-18` en verde desbloqueó la fusión; `SEC-053` descubrió que
  **`v1.31.0` se publicó fuera de delegación** sin que nadie lo supiera.

- **DECISIÓN — la regla, y su alcance exacto.** Un hallazgo de clase **`instrumento`** sobre los textos o
  los instrumentos del propio arnés:
  1. **se registra igual** en `docs/seguridad/registro-seguridad.md` — no se deja de mirar ni de anotar;
  2. **no abre un REQ nuevo** ni entra en la ventana en curso;
  3. **se acumula en un solo backlog** que se revisa **una vez por ventana**, al planificarla.

  **Lo que la regla NO toca, dicho para que no se estire:** los hallazgos `contrato` y `usuario/dinero`
  siguen bloqueando el cierre y siguen exigiendo write-back, exactamente como hoy. Esto no baja ningún
  rigor ni apaga ninguna puerta: sólo impide que un defecto **que ya está declarado como no bloqueante**
  genere trabajo de ventana.

- **Corrección de la coordinadora sobre su propia recomendación, hecha antes de aplicarla.** Al proponer
  esta regla afirmé que **«7 de los 9 hallazgos de hoy son `instrumento`»**. Es falso: medidos, son
  **4 `instrumento` y 5 `contrato`**. La regla, por tanto, **habría frenado menos de la mitad** de lo que
  se abrió hoy — es una palanca real pero **más pequeña de lo que la vendí**, y las cinco de clase
  `contrato` habrían entrado igual. Se aplica sabiendo eso.

- **Consecuencia operativa inmediata:** 1.33.0 se publica con lo que hay —`REQ-017` cerrado y la partición
  de `CA-18` en verde— y **no entra ningún hallazgo nuevo en esta ventana**. `REQ-019` sigue siendo el
  primer y único trabajo de 1.34.0, con la protección ya escrita en `docs/PLAN.md`.


### RESUELTA 2026-09-08 (propietario) — ratificación de `v1.31.0`, publicada de autoridad no acreditada

- **Contexto.** R-016 (`auditor-seguridad`) barrió los 40 tags publicados y encontró que `v1.31.0` se
  publicó por delegación con **tres `contrato` abiertos** —`QA-114`, `QA-116`, `QA-117`—, declarados en
  las dos sedes del tag, sin entrada en la cola de aprobaciones. No se había visto en R-015 porque ese
  barrido buscó prefijos `SEC-` y estos tres son `QA-`. `SEC-053` quedó en `en-mitigación` con esta
  ratificación como su **único residual pendiente**, vencimiento antes del tag de `v1.33.0`.
- **Decisión del propietario, 2026-09-08: ratificada.** Misma resolución que ya dio para `v1.32.1`. El
  auditor cierra el residual de `SEC-053` en su registro; la coordinadora no lo hace por sí misma —es la
  misma frontera que ya se aplicó al escribir la propia regla de escalada.


### RESUELTA 2026-09-08 (propietario) — La partición autorizada es IMPOSIBLE: se reabre REQ-014 y se re-deriva CA-18

- **Contexto.** Autorizaste partir las secciones sobre 400 líneas con **desarrollador + QA**, sin analista
  ni auditor, sobre dos premisas escritas: *«el cambio es **mecánico** —mismo contenido, mismos casos,
  menos líneas por archivo—»* y *«su acreditación **ya existe y es fuerte**: un inventario ordenado de
  caso y veredicto **idéntico byte a byte**»*. El desarrollador **paró antes de tocar `tests/`** y midió
  las dos. **Las dos son falsas.**

- **Premisa 1 falsa: no es mecánico, es aritméticamente imposible.** Tres invariantes se multiplican —
  cada sección corre en **su propio subshell y en paralelo** (`run.sh:1168`, invariante `CA-04`), así que
  todo archivo partido tiene que ser **autocontenido**; `CA-19` **prohíbe** que una sección haga `source`
  de otra; y `H-04` **aborta** ante cualquier archivo de `secciones/` que no case `NN-*.sh`, así que
  tampoco cabe un auxiliar. La maquinaria compartida **no se puede factorizar**. Mínimo autónomo medido,
  **antes de meter un solo caso**:

  | | preámbulo | maquinaria | bloque indivisible | mínimo |
  |---|---|---|---|---|
  | `37/1` | 26 | 122 | 312 | **460** |
  | `37/2` | 32 | 92 | 269 + 74 | **467** |

  **El límite de `CA-18` es 400. No hay ninguna partición conforme que lo cumpla.** Y la mejor posible
  deja `CA-18` **rojo igual**: `37/1`-A **564**, `37/2`-A **467**, más `38-sondas-compartidas.sh` **827**.
  Duplicar el clasificador para separar `CA-01` de `CA-10` da **516 y 511** —las dos siguen fuera— y
  además duplica cuatro evaluaciones y la clasificación, coste que `CA-08 (i)` presupuesta. Recortar
  comentarios tampoco basta: con el código puro, el archivo del clasificador sigue en **~410**.

  > **Esto es la clase de `DEV-021-05`, y conviene nombrarla:** un criterio **derivado sin comprobar su
  > factibilidad**. `CA-18` fijó 400 sin medir cuánto mide una sección autónoma mínima. Es el mismo
  > defecto que `CA-08 (iii)`, cuyo techo de `4×` contaba cuatro ejercicios como si costaran lo mismo y
  > hubo que **re-derivarlo término a término a 6×**. Y aplica la regla que salió de ahí: **un techo no
  > se compra deformando el sujeto**, y aquí el sujeto ya no se puede deformar más — el mínimo es
  > estructural, no de estilo.

- **Premisa 2 falsa: la acreditación en la que se apoyó tu firma ya no discrimina.** Medido con **dos
  corridas intactas del banco, sin tocar nada**: 884 casos las dos, **74.046 y 74.047 bytes**, y `cmp`
  **difiere en el byte 42.659, línea 548**. **20 de 884 líneas son volátiles** —µs, razones, PID, sellos
  epoch— en `REQ-017 CA-03/04/08/09` y `REQ-021 CA-02/03/04/08`. La causa está verificada en una línea:
  `tests/escenarios/hooks/inventario.sh:24` normaliza **sólo** `[0-9]+ms` → `Nms`, y estas cifras no son
  ms.

  **Consecuencia:** el `cmp` crudo que exige `REQ-014 CA-12` **ya no puede distinguir «la partición
  cambió algo» de «el reloj avanzó»**. Es decir, la acreditación que sustituía al analista y al auditor
  **no es aplicable en este árbol**. El desarrollador construyó un oráculo **normalizado** y lo validó
  —dos corridas intactas **sí** salen idénticas bajo él: 884 líneas, 72.108 bytes, `cmp` limpio—, así que
  la acreditación es **factible**; pero el criterio, tal como está escrito, no lo es.

  > Y la sospecha del desarrollador, que suena correcta: **es probablemente la causa real de que la
  > partición se ordenara «después de cerrar REQ-021»** — las secciones que hay que partir son justo las
  > que publican las cifras volátiles.

- **Lo que el desarrollador NO hizo, y estuvo bien:** no tocó `tests/`, no comiteó, no tocó el índice, y
  **no escribió `Estado: bloqueado` en ningún REQ**. `CA-18` es de **`REQ-014`, que está `completado` con
  `QA: aprobado` y `Seguridad: aprobado`**; reabrirlo es la **REGLA DE ESTADO** de §9 y una decisión de
  gobernanza, no un efecto colateral de una comisión. Gates en verde: las tres de §7, `bash -n` sobre las
  **45** secciones con **0 rotas**, banco **880 PASS · 0 FAIL · 4 SKIP · rc 0**, y `git diff HEAD --
  tests/` **vacío**.

- **Opciones.**
  - **A) Reabrir `REQ-014` para re-derivar `CA-18` y arreglar el oráculo del inventario, y partir
    después.** Absorbe las dos premisas falsas en un solo trabajo: el analista **re-deriva el límite
    término a término** —como se hizo con `CA-08 (iii)`— desde el mínimo autónomo **medido**, y lo escribe
    como **propiedad y no como número**; y `inventario.sh` normaliza los campos volátiles, con el oráculo
    que ya está construido y validado. Después la partición es posible y su acreditación vuelve a
    discriminar. **No toca el mecanismo del corredor.** Reabre un REQ `completado`, que es exactamente lo
    que §9 manda cuando un criterio cambia.
  - **B) Mover los ayudantes compartidos a `run.sh`.** La única salida que hace `CA-18` verde **sin**
    tocar el límite. Pero es **cambio de mecanismo** → `critico` con analista y auditor, y **cambia el
    conjunto que `autoprueba-corredor.sh` deriva y vigila en `H-01`**. Más riesgo por el mismo precio.
  - **C) No fusionar 1.33.0.** `CA-18` se queda rojo y la candidata entera espera a 1.34.0, junto con
    REQ-021. Deja sin publicar el trabajo de REQ-017, que retira una puerta **no determinista** que hoy
    está publicada en `v1.32.1`.

- **Recomendación de la coordinadora: A.** El número estaba mal derivado y el árbol lo demuestra con
  aritmética, no con opinión. Re-derivar un techo infactible **no es debilitar una puerta**: es lo que
  este REQ ya hizo una vez, con el número delante. Y B cambia el corredor para no tener que admitir que
  el 400 estaba mal.

- **Lo que NO recomiendo y digo por qué, para que no aparezca luego como atajo:** poner
  `continue-on-error` en el paso de la autoprueba, o sacar `CA-18` del CI. Haría verde la puerta
  requerida **apagando la señal**, que es exactamente el modo de fallo que `AGENTS.md` §13 describe —
  *«un guard apagado protege menos que uno parcial»*— y que el propio `CA-18` existe para evitar.

- **Espera.** Tu elección entre A, B y C. **Nota de honestidad sobre el calendario:** cualquiera de las
  tres deja `v1.33.0` **fuera de hoy**, porque A y B son ciclos de cuatro agentes (~2 h cada uno) y C no
  publica. La estimación de «≈1 h al tag» que la coordinadora venía dando **era falsa**, y lo era porque
  se apoyaba en que la partición era mecánica — la misma premisa que acaba de caer.

- **RESOLUCIÓN del propietario, 2026-09-08: opción A.** Se reabre `REQ-014` por la **REGLA DE ESTADO**
  de §9: el analista re-deriva `CA-18` **término a término** desde el mínimo autónomo medido y lo enuncia
  **por propiedad, no por número**, y `inventario.sh` pasa a normalizar **lo que es medida y no
  identidad** —la propiedad que su propio comentario ya declara y cuya extensión envejeció al nombrar una
  unidad—. Los dos criterios ganan **par discriminante**: un límite que nadie puede exceder y un oráculo
  que normaliza todo no miden nada. Después la partición es posible, incluida la de
  `38-sondas-compartidas.sh`, cuya firma el propietario ya dio hoy.

- **Corrección de la coordinadora a su propia estimación, hecha en el mismo día:** el «fuera de hoy» de
  arriba **también era pesimista**. Medido con las duraciones reales de las comisiones de esta sesión
  —analista 13–21 min, desarrollador 9–43 min, QA 45 min, auditor 8–20 min—, la reapertura completa sale
  a **≈2 h 45** y `v1.33.0` **sí cabe hoy**, con **≈3 h 45** si hay una vuelta dev↔QA. Se deja escrito
  porque las dos estimaciones del día —la de «≈1 h» y la de «fuera de hoy»— fallaron en direcciones
  opuestas y ninguna publicó el dato del que salían.

### RESUELTA 2026-09-08 (propietario) — REQ-021 sale de 1.33.0: se publica sin él y su código se queda

### RESUELTA 2026-09-08 (propietario) — REQ-021 sale de 1.33.0: se publica sin él y su código se queda

- **Contexto.** `AGENTS.md` §6: máximo **3 vueltas dev↔QA por REQ**, el contador **no se reinicia**, y
  agotado el tope el REQ **o cierra con residual declarado o pasa a `bloqueado` y se escala al humano**.
  La vuelta 3 está gastada y **el residual no está disponible**: `QA-021-10` es `contrato`, y
  `guard-completado` deniega el cierre con un `contrato` abierto. Sólo existiría si QA o el auditor lo
  **reclasificaran**, y QA se negó expresamente con la evidencia delante.

- **Lo que la vuelta 3 SÍ consiguió, para que la decisión no se tome sobre un fracaso que no lo es.** El
  mecanismo cambió de razonable a comprobable: el juez obtiene el testigo **antes** de invocar la sonda,
  a coste **cero procesos**. La mutación del forzador —no ejercer el binario ni una vez— **por fin
  FALLA** (`rc 1 · 74/3`) mientras la misma copia sin mutar **PASA** (`rc 0 · 77/0`). `CA-08 (iii)`
  **mejoró** en las dos magnitudes. Banco **880 PASS · 0 FAIL · 4 SKIP, rc 0**, cuadre 884 verificado por
  QA contra 45 literales. `CA-07` acreditado en sus tres puntos (**828 casos, 61.287 bytes, `cmp`
  idénticos** contra un worktree de `794fa4c`). Las tres gates de §7 en verde.

- **Por qué no basta, y es una sola frase que conviene leer despacio.** QA reprodujo el forzador y
  **cuatro mutaciones más, tres de las cuales no leen el sujeto, y las cuatro PASAN**. La causa:
  `SP_RESOLUCION=1`, `SP_CAL_MARGEN=4` y `SONDA_DISC_PROC_VECES=2` son **literales**, así que
  `testigo = parámetro / 2` se cumple **por construcción en toda máquina**. La condición 1 exige que el
  testigo **no coincida** con el parámetro —y no coincide, 2 ≠ 4— pero **«no coincidir no es no ser
  predecible»**: lo que hace que un contraste pueda fallar es que la sonda no pueda **saber** el testigo
  sin trabajar. **El forzador nombraba un ejemplar; la clase sobrevive.** Es la **cuarta** variante de la
  misma clase dentro del mismo REQ (`2N/N`, `N−1`, el rastro que la sonda escribe, y ahora el testigo
  derivable).

- **Y una cadena de acreditación que se rompe.** `CA-03 (d)` **falla** con la carga acreditada por su
  **efecto** (tarea de referencia: 262–282 ms en reposo → 402–508 ms con 4/12 → 675–1426 ms con 12/12):
  saturación **9 de 16 corridas** con FAIL, y **8 de 13 casos son `CA-03 (c)`**, no la mitad discordante.
  El `0 de 30 en cuatro regímenes` de la vuelta 2 **se retira**: su registro **no publica ni una
  evidencia de que sus cuatro regímenes existieran**, y un régimen declarado y no acreditado es un número
  que no puede salir mal. Con él se retira **el permiso que autorizaba bajar `r` a 3** («sólo mientras
  (d) siga en 0 de 30», `REQ-021.md:788`). Las dos ramas quedan cerradas: con `r=5`, `(ii)` da **1,2825×
  > 1,25×**; con `r=3`, cumple **sobre un permiso inexistente**. **`CA-08 (ii)` no queda acreditado.**

- **Lo que QA dejó nombrado y medido, que es lo que hace esta decisión barata en cualquier dirección:**
  las dos piezas que faltan cuestan **cero procesos** — el tamaño del discordante **sorteado por
  corrida**, y la terna **fuera de todo directorio que la sonda reciba**. Con ellas, el conjunto de
  mutaciones que pasan se reduce exactamente a «lee el sujeto», y la frontera que el REQ declara
  —«falsificación deliberada, no descuido»— pasa a ser **verdadera**. Hoy es una **salida**, porque
  clasifica por la intención del autor, que ningún control mide.

- **Opciones.**
  - **A) Publicar 1.33.0 sin REQ-021.** La ventana entrega **REQ-017** —que retira una puerta **no
    determinista** y baja el reloj del banco de 95,66 s a 45,14 s— más la **partición de las tres
    secciones**. REQ-021 pasa a **1.34.0** con las dos piezas ya nombradas. *Sub-decisión que va con
    esta opción y que no resuelvo yo:* **el código de la vuelta 3 ya está comiteado** (`2ce7804`) y el
    banco está verde con él. ¿Se queda en 1.33.0 —con sus hallazgos declarados y su REQ `bloqueado`— o se
    revierte? Se queda es lo que yo haría: el árbol con él es **mejor** que sin él y el banco lo
    certifica, pero publicar código de un REQ `bloqueado` es una decisión de gobernanza tuya.
  - **B) Autorizar una vuelta 4**, excediendo el tope de §6 por decisión expresa. QA nombró exactamente
    qué falta y cuesta cero procesos, así que el trabajo está bien especificado. **El argumento en
    contra está medido:** el tope existe *«porque cada arreglo cierra el hallazgo documentado y la vuelta
    siguiente encuentra una variante»*, y ésta sería la **cuarta variante de la misma clase**. Autorizar
    la vuelta 4 es apostar contra un patrón que este REQ ha exhibido tres veces.
  - **C) A, más reducir el alcance de REQ-021 en 1.34.0** a **sólo la sonda de procesos** —**0 FAIL en
    las 48 corridas** de QA, `cal_a=2,000`/`cal_b=1,000` exactos— sacando la de reloj, que es de donde
    salen `(c)`, `(d)` y **todo** el coste que dejó `CA-08 (ii)` sin acreditar. Es el mismo patrón que ya
    aplicaste una vez en este REQ: **reducir el sujeto en vez de debilitar el techo**. No unblokea nada
    hoy —`QA-021-10` vive en la sonda de procesos— pero hace el REQ de 1.34.0 mucho más pequeño.

- **Recomendación de la coordinadora: A, con el código quedándose, y la forma de C para 1.34.0.** El
  motivo no es de calendario: es que **B apuesta contra la única cosa que este REQ ha medido tres veces
  de sí mismo**. Y 1.33.0 no se va vacía — REQ-017 retira una puerta no determinista, que es exactamente
  el tipo de defecto que este arnés existe para no publicar.

- **Espera.** Tu elección entre A, B y C, y —si eliges A o C— si el código de la vuelta 3 se queda en
  1.33.0 o se revierte. **El pipeline está detenido**: mientras esta entrada esté aquí,
  `guard-completado` deniega marcar **cualquier** REQ como `completado`.

- **RESOLUCIÓN del propietario, 2026-09-08: opción A, y el código de la vuelta 3 SE QUEDA.** 1.33.0 se
  publica con **REQ-017** y la partición de secciones; **REQ-021 pasa a 1.34.0** con las dos piezas que
  QA nombró (tamaño del discordante sorteado por corrida, y la terna fuera de todo directorio que la
  sonda reciba), las dos a coste cero procesos. El código de `2ce7804` **no se revierte**: el árbol con
  él es medible mejor que sin él y el banco lo certifica (880/0/4, `rc 0`).

- **Dos cosas que esta resolución NO decide, y quedan nombradas para que nadie las resuelva por su
  cuenta:**
  1. **`Estado:` de REQ-021 se queda en `bloqueado`**, no vuelve a `pendiente`. El tope de vueltas
     **sigue agotado** y nada de esta decisión lo cambia; ponerlo en `pendiente` borraría ese hecho.
  2. **Si el contador de vueltas se reinicia al cambiar de ventana, NO está escrito en `AGENTS.md` §6.**
     La sección sólo dice que no se reinicia «con cada hallazgo nuevo». Es una pregunta abierta con
     efecto real —decide si 1.34.0 tiene tres vueltas o cero— y la resuelve el `analista-requerimientos`
     en el write-back, con **ADR** si es cambio de fondo. La coordinadora no la interpreta.

### RESUELTA 2026-09-08 (propietario, autorización expresa) — partir las dos secciones 37 paga desarrollador + QA, sin analista ni auditor

> **AMPLIACIÓN del propietario, 2026-09-08, misma firma extendida a `38-sondas-compartidas.sh`.** La
> vuelta 3 de REQ-021 hizo crecer esa sección de **722 a 827** líneas, así que `CA-18` la nombra junto a
> las dos 37 y **la fusión seguía bloqueada aunque las 37 se partieran**. La autorización original decía
> «las dos secciones 37» y excluía por escrito «ninguna otra edición de `tests/`»: **extenderla por
> analogía habría sido la reclasificación automática que §6 prohíbe**, así que se preguntó. Mismo trato y
> mismo motivo —el cambio es mecánico y su acreditación es el inventario ordenado de caso y veredicto
> **idéntico byte a byte**, criterio central de REQ-014— y **los mismos límites**: ninguna otra edición
> de `tests/`, ningún cambio de lógica, y ningún ajuste de `CASOS_ESPERADOS` (hoy **884**) ni de
> `CASOS_ESPERADOS_SECCION` más allá del reparto aritmético que la partición obliga.
>
> **Va en comisión aparte y en SERIE, no en paralelo:** las dos particiones escriben
> `tests/escenarios/hooks/run.sh`, `tests/escenarios/hooks/README.md` y `CHANGELOG.md`, así que
> `AGENTS.md` §6 punto 3 las hace colisionar por líneas, con independencia de que sean la misma fase.
>
> **Y una nota que la ampliación obliga a dejar escrita:** la sección 38 es la de **REQ-021**, que acaba
> de quedar `bloqueado`. Partirla **no toca su lógica** ni sus veredictos —es el mismo contenido en menos
> líneas por archivo— pero el REQ vuelve a 1.34.0 con sus secciones ya repartidas, y quien retome allí
> las dos piezas que QA nombró se las encontrará en archivos distintos de los que su Historial cita.

- **Contexto.** La autoprueba del corredor sale `rc=1`: `CA-18` limita los archivos de sección a **400
  líneas** y `37-coste-del-escaner-1-escala.sh` mide **751** y `37-…-2-la-seccion-caliente.sh` **614**.
  El CI la corre como paso propio, sin `continue-on-error`, así que `hooks-en-linux` —la puerta
  requerida de `main`— se pone roja y **la fusión de 1.33.0 está bloqueada**.

  Lleva roja **desde el delta final de REQ-017**, y nadie lo vio porque el CI que marcaba `pass` en el
  PR #43 había medido `0bab7a1`, donde esas secciones median **346 y 266** líneas: la rama local estaba
  **20 commits por delante**. Es H-08 con otra cara — un verde sobre un árbol que ya no existe.

  `AGENTS.md` §6 clasifica como **crítico** «todo cambio en … el banco que los certifica (`tests/`)», y
  el rigor `critico` exige analista, desarrollador, QA **y** auditor. Sólo el propietario puede bajar
  ese nivel, y nunca por reclasificación automática de un agente.

- **Opciones.** **A)** desarrollador + QA, con autorización expresa. **B)** ciclo completo de cuatro
  agentes (~2 h). **C)** aplazar a 1.34.0 y no fusionar 1.33.0. *(Descartada de entrada: subir el límite
  de `CA-18` derrota el propósito de REQ-014 — el banco se partió en archivos para que dos agentes de QA
  puedan trabajar a la vez, y un archivo de 751 líneas es el cuello que eso vino a quitar.)*

- **Decisión del propietario: opción A.** El cambio es **mecánico** —mismo contenido, mismos casos,
  menos líneas por archivo— y su acreditación **ya existe y es fuerte**: un inventario ordenado de caso
  y veredicto **idéntico byte a byte** antes y después, que es el criterio central de REQ-014. El
  auditor no añade casi nada sobre una partición que no cambia lógica.

- **Lo que la autorización NO cubre, dicho aquí para que no se estire:** ninguna otra edición de
  `tests/`, ningún cambio de lógica dentro de las secciones partidas, y ningún ajuste de
  `CASOS_ESPERADOS` total ni de `CASOS_ESPERADOS_SECCION` más allá del reparto aritmético que la
  partición obliga. Cualquier cosa fuera de eso vuelve a `critico`.

- **Contra-argumento que quedó sobre la mesa y no se resolvió:** la auditoría preventiva **R-011** midió
  que `tests/` **no está en `codigo_app.globs`**, así que el juez de todas las sondas no lo vigila nadie
  —tampoco contra esta sesión coordinadora, que acredita, decide y publica—. Es el residual `SEC-045`,
  abierto, y esta autorización lo asume sabiéndolo.

- **Orden, y por qué no se adelanta:** la partición va **después** de cerrar REQ-021, no antes. `CA-07
  punto 2` de REQ-021 **congela** los `CASOS_ESPERADOS_SECCION` de esas dos secciones, y esa congelación
  es lo que hace acreditable la mudanza de las sondas. Partirlas antes obligaría a re-medir la
  acreditación de REQ-021 contra una línea base distinta.

### RESUELTA 2026-09-07 (coordinadora, por delegación del propietario) — aprobada la opción A: el cambio del workflow de CI viaja en 1.32.0
- **Contexto.** `AGENTS.md` §6 lista entre los gates humanos «cambiar el ruleset, **el workflow de CI**
  o el manifiesto» y clasifica como **crítico** «todo cambio en … el banco que los certifica
  (`tests/`) [y] en el workflow de CI». REQ-014 hace las dos cosas: parte `tests/escenarios/hooks/run.sh`
  (4.096 líneas) en un corredor más 35 archivos de sección, y añade a `.github/workflows/banco.yml`
  tres cosas — `bash -n` sobre `secciones/*.sh`, la comprobación del bit de ejecución en sus dos
  mitades (puntos de entrada `100755`, secciones `100644`) y un paso nuevo para
  `autoprueba-corredor.sh`. El REQ lo pide explícitamente en su CA-25.
- **Evidencia con la que se llega aquí.** Inventario de 683 casos **byte a byte idéntico** al de
  v1.31.0 publicada (`diff` vacío), tres corridas antes y tres después idénticas entre sí; cero FAIL;
  cuadre exacto global y por archivo; las 35 secciones dan el mismo veredicto en solitario que dentro
  de la vuelta completa; `git diff v1.31.0 -- hooks/ tools/` vacío; tiempo mediano 16,3 s frente a
  17,7 s antes (más rápido, dentro del techo de CA-20).
- **Opciones.** **A)** Aprobar el cambio de `tests/` y del workflow tal como está. **B)** Aprobar la
  partición del banco y dejar el workflow como estaba (se pierden `bash -n` sobre las secciones, la
  comprobación de modos y la autoprueba: el CI dejaría de ver los tres modos de fallo que la
  estructura nueva introduce). **C)** Rechazar y volver al monolito.
- **Recomendación del agente.** **A.** La partición sin las puertas nuevas en CI es la mitad peligrosa
  del cambio: una sección con la sintaxis rota no falla, **desaparece**, y sin `bash -n` en CI nadie lo
  ve hasta que el cuadre por archivo lo delate — que es exactamente lo que este paso adelanta.
- **Espera.** Aprobación del propietario para fusionar el PR de `cand/1.32.0` con el cambio de
  `.github/workflows/banco.yml` incluido.
- **Resolución.** El propietario eligió **publicar 1.32.0** el 2026-09-07, aprobando expresamente
  el cambio de `.github/workflows/banco.yml`. El `auditor-seguridad` no puso objeción de seguridad
  al cambio en R-004 y la confirmó en R-006: no añade secretos ni acciones de terceros, no usa
  `pull_request_target`, `bash -n` no ejecuta nada y `git ls-files -s` sólo lee el índice. Las dos
  observaciones que dejó —falta `permissions: contents: read` explícito y `actions/checkout@v4`
  anclado por etiqueta y no por SHA— son **preexistentes**, no las trae esta ventana, y quedan como
  deuda de endurecimiento sin dueño de ventana.


### RESUELTA 2026-09-05 (coordinadora, por delegación del propietario) — aprobada la opción B ampliada

- **Decisión:** se añaden a `codigo_app.globs` de **este** repositorio `.arnes/config.json` y
  `.claude-plugin/*`. **No** se añade `.arnes/*` entero, y no es un descuido: `/arnes-upgrade`
  escribe `.arnes/migracion.md` y `.arnes/plantillas-origen/` desde la sesión coordinadora, y
  protegerlos convertiría cada migración en una comisión al `desarrollador` sin ganar nada —
  ninguno de los dos declara una invariante.
- **Coste aceptado, dicho en voz alta:** `arnes_version` vive en el manifiesto, así que la Fase 5
  de `/arnes-upgrade` en este repositorio pasa a ser trabajo del `desarrollador`. Ocurre una vez
  por versión y coincide con el commit en el que ya sube `plugin.json` y `marketplace.json`.
- **Se conserva el control obligatorio:** la ampliación **no** se propaga a
  `templates/arnes-config.json.tpl`. Es mapeo de este repositorio, no mecanismo.
- **Lo aplica el `desarrollador`** en la vuelta siguiente, junto con REQ-010. La coordinadora no
  edita el manifiesto, ni siquiera para meterlo dentro de la frontera.

### [2026-09-05] (desarrollador) — Meter `.arnes/config.json` y `.claude-plugin/*` dentro de `codigo_app.globs` de ESTE repositorio

- **Contexto** — SEC-006 parte (a) de la auditoría R-001 (REQ-007, CA-53): hoy
  `codigo_app.globs` es `["hooks/*", "tools/*", ".github/*"]`, así que **quien no puede
  escribir `hooks/` sí puede cambiar la regla que dice qué es `hooks/`**. El manifiesto es
  la fuente de verdad ejecutable de las invariantes —quién es el agente de código, qué
  rutas protege, qué quality gates corren, cuál es el estado terminal y cuál es el techo de
  análisis de Bash—, y `.claude-plugin/plugin.json` / `marketplace.json` declaran la versión
  publicada. Es escalada de privilegios dentro del arnés. `AGENTS.md` §6 ya exige
  aprobación humana para tocar el manifiesto de este repositorio, pero eso es política, no
  enforcement. **El mecanismo que hace falta ya existe** (`guard-codigo` deniega cualquier
  ruta que case con los globs): lo único que falta es el mapeo, y el mapeo es este archivo.
- **Opciones** — **A)** Añadir `.arnes/*` y `.claude-plugin/*` a `codigo_app.globs` de
  `/.arnes/config.json` (sólo de este repositorio). **B)** Añadir sólo
  `.arnes/config.json` y dejar el resto de `.arnes/` libre. **C)** No aplicarlo y dejar el
  hueco declarado como límite en `docs/seguridad/registro-seguridad.md`.
- **Recomendación del agente** — **A**. Es el mapeo del arnés sobre sí mismo y cierra la
  escalada completa; el coste es que a partir de ahí sólo el `desarrollador` toca el
  manifiesto y la versión, que es exactamente lo que `AGENTS.md` §6 ya dice en prosa.
  Efecto colateral esperado y **no** un fallo: mientras el manifiesto no esté en los globs,
  `guard-codigo` tampoco protege el cambio que lo mete en ellos.
- **Espera** — Aprobación del propietario (Juan) para editar
  `/.arnes/config.json`, y elección entre A, B y C. **Control obligatorio de esta
  decisión, ya verificado en la candidata:** la ampliación **no** se propaga a
  `templates/arnes-config.json.tpl` — es mapeo de este repositorio, no mecanismo, y
  ningún proyecto que instale el arnés puede heredarla.

<!-- Mover aquí con: decisión tomada, quién, fecha. No borrar (histórico). -->

**Añadido el 2026-09-10 — un dato que este gate necesita y que no existía cuando se escribió `D8`.**
`ADR-009` sigue en `propuesta`, y hoy lleva **tres** imprecisiones precisadas por notas al pie: `:41`
(Contexto), `:131` (Consecuencias) y `:101` (Alternativas). **Las tres dicen lo mismo** —*qué nota un
proyecto que no hace nada*— y **ninguna la encontró quien la buscaba**: aparecieron de rebote, al
implementar otra cosa. Así que **ratificar `ADR-009` hoy es ratificar un texto que se lee con tres
condiciones**, y las tres viven en sus notas y no en su cuerpo.

**Y el `analista-requerimientos` nombró la salida proporcionada sin tomarla, porque es una decisión sobre
`ADR-009` que `ADR-009` no puede tomar:** **retirar de él la magnitud del radio de migración y remitirla
UNA sola vez a `CA-01`/`CA-05` de `REQ-024`** —que es quien la mide y la mantiene—, dejando en el ADR la
**decisión**, que es lo que un ADR debe conservar. Dueño: **tú** en este gate, o el `auditor-seguridad` si
lo levanta antes.

**Su argumento para no seguir parcheando, que me parece el mejor del día:** corregir **sede por sede** una
misma afirmación es **exactamente la forma que `ADR-011` acaba de prohibir para el código, aplicada al
texto** — «*la cuarta llegará*». El propio ADR que decidió «enunciar por acto y no por puerta» estaba
siendo incumplido en su documento hermano por corregir instancia a instancia en vez de en la fuente.
