# PLAN — el camino del arnés hasta que esté terminado

> **Qué es esto.** El plan maestro por versiones: qué entra en cada ventana, qué cierra y por qué va ahí
> y no antes. La cola cruda vive en `docs/PENDIENTES.md`; el contrato, en `requirements/`. Este archivo
> es el que responde «¿cuánto falta y en qué orden?».
>
> **Regla de orden, y es la que explica casi todo el reparto:** lo que **compone** va primero. Una
> palanca que abarata el ciclo se paga en todas las ventanas siguientes; un mecanismo que cierra un
> hueco se paga una vez. Por eso el coste va antes que las puertas, aunque las puertas suenen más
> urgentes.

## Qué significa «terminado»

El arnés estará terminado cuando se cumplan las tres a la vez:

1. **Ningún hallazgo abierto de clase `contrato`.** Hoy quedan tres, todos con dueño y ventana.
2. **Todo lo que la máquina promete, lo cumple.** Ninguna afirmación de `AGENTS.md` o de las plantillas
   describe una garantía más fuerte que la que el código sostiene.
3. **Un ciclo de versión cabe en un presupuesto declarado.** Hoy cuesta ~253 USD; el objetivo es la
   mitad, y es lo que la ventana 1.32.0 va a medir.

Lo que quede después es **backlog**, no obra pendiente: mejoras de clase `instrumento` que se hacen
cuando estorban, no antes.

---

## 1.32.0 — la ventana del coste

**Qué entra:** REQ-012, REQ-013 y REQ-014. Nada más, y la reserva es deliberada.

| REQ | Qué hace | Por qué aquí |
|---|---|---|
| **REQ-012** | Criterios por **mecanismo**, no por enumeración: se prohíben las tres formas medidas —enumerar lo que el código reconoce, fijar un número que la medición desmiente, y exigir igualdad donde va un techo— | Es la palanca que más rinde. Siete de los veinte hallazgos del ciclo 2 fueron que el criterio decía algo falso, y uno costó una vuelta entera. Y ataca el 54 % del peso de un REQ, que son sus criterios |
| **REQ-013** | Campo `Archivos:` legible por máquina y `tools/arnes-paralelo.sh`, que dice qué comisiones son disjuntas | Hoy el ciclo corre casi todo en serie: cero comisiones solapadas, y el reloj del ciclo iguala la suma del tiempo de agente |
| **REQ-014** | El banco en archivos por sección, con el cuadre exacto por archivo | Mientras el banco sea un solo archivo, dos agentes de QA no pueden trabajar a la vez. Es el cuello que impide aprovechar REQ-013 |

**Qué cierra:** la línea base de coste queda con algo contra qué compararse. **Qué mide:** hallazgos de
clase `contrato` por ciclo (base 7), vueltas causadas por ellos (base 1), comisiones solapadas (base 0),
cociente reloj/tiempo de agente (base ~1,0) y agentes de QA simultáneos (base 1).

**Riesgo declarado:** REQ-014 toca `tests/`, que es crítico por definición. Su criterio central no es
«el banco pasa» sino un inventario ordenado de caso y veredicto **idéntico byte a byte** antes y después.

---

## 1.33.0 — preguntas de estado, no preguntas de vía

> **Reescrita el 2026-09-07, al cerrar la ventana 1.32.1, y aprobada por el propietario.** Antes esta
> ventana era una lista de huecos. Dejó de serlo cuando el parche 1.32.1 produjo, sin buscarlo,
> **cuatro instancias del mismo defecto de forma** en cuatro sitios con cuatro dueños distintos.

### El tema, porque una ventana con tema cuesta menos que un cajón

| Dónde apareció | Preguntaba por la **vía** | La pregunta que no envejece, por **estado** |
|---|---|---|
| Los 5 casos de banco vacíos (H-02) | «¿el documento tiene un rango?» | «¿la puerta llegó a juzgar una transición?» |
| El barrido de migración (SEC-025) | «¿hay un `<!--`?» | «¿cuáles de mis REQ en estado terminal **no cerrarían hoy**?» |
| El control de datos de cliente (SEC-029) | `git diff origin/main..HEAD` | «¿qué hay **en el árbol**?» |
| El guardián del intérprete (REQ-011) | «¿este comando va a escribir?» | «¿cambió algo protegido?» |

**Interrogar al mecanismo tiene una vía nueva cada vez; interrogar a la propiedad no envejece.** Es la
misma familia que las **cinco** derrotas de «ensanchar el patrón», y por eso la salida es la misma:
pregunta cerrada o gramática restringida. Las cuatro comparten mecanismo y comparten pruebas: juntas
cuestan bastante menos que por separado, y ese es el motivo de agruparlas, no la estética.

### Alcance: esta ventana son SÓLO las palancas de coste

> **Partida el 2026-09-07 por decisión del propietario, y el motivo es el propio historial.** 1.33.0
> empezó siendo «la skill de migración y las plantillas» y a media ventana tenía nueve trabajos: tres
> palancas de coste, la cuarta, REQ-011, dos barridos, el rigor comprobable, el caso J y una pasada de
> conformidad con cinco cosas dentro. **Creció durante la ventana anterior, que es exactamente cómo se
> descontroló el ciclo 3.** Medido: los nueve juntos salen a ~8–10 h de reloj de agente, y una ventana
> que no cabe en un ciclo se corta a mitad de una comisión.
>
> | Ventana | Contenido | Reloj de agente |
> |---|---|---|
> | **1.33.0** | Las cuatro palancas de coste (abajo). REQ-017 en curso | **~3 h** |
> | **1.34.0** | El núcleo por estado, la pasada de conformidad y el canal de informes | ~6 h |
>
> **Se gana algo más que tiempo, y es el motivo real de este orden:** las palancas abaratan el núcleo,
> así que medirlas **antes** de empezarlo es la única forma de saber cuánto abaratan de verdad. Si van
> juntas, el ahorro queda mezclado con el gasto y no se puede atribuir — que es el error que se cometió
> el 2026-09-07 con la línea base envenenada por la sonda desbocada.

Esta ventana va a tener muchas comisiones, y las tres primeras palancas están **medidas** en 1.32.1:

| Palanca | Medido | Lo que devuelve |
|---|---|---|
| Partir la sección caliente del banco | Ver la corrección de abajo: la ruta crítica es **`32-huecos-auditoria-r001`**, no `36-2` | El banco lo corre **cada** comisión que mide, decenas de veces |
| `tests/util/` con las tres sondas | Tres comisiones las reconstruyeron en esta ventana, **dos mal la primera vez** (`$BASHPID` dentro de `$( )`; `command -v` sobre un binario sombreado) | ~150 k tokens por ventana, y dos clases de prueba-que-miente |
| La nota de migración **una vez al cerrar** | `skills/arnes-upgrade/SKILL.md` colisionaba en 15 de 15 pares | Paralelismo real entre comisiones |
| **Adelgazar `AGENTS.md`** (cuarta, propuesta por la coordinadora) | ~9 k tokens de impuesto fijo en **cada** subagente; una comisión de subida de versión gastó 28 500 tokens para ~3 000 de trabajo real | El impuesto lo paga cada comisión de 1.34.0, que son muchas |

> **Alcance vigente de 1.33.0, fijado por el propietario el 2026-09-08 (segunda decisión del mismo
> día): REQ-017 + REQ-021, más la partición de las tres secciones sobre 400 líneas (`DEV-021-07`).
> `REQ-019`, `REQ-020`, `REQ-023`, `REQ-024` y `REQ-025` van a 1.34.0, y REQ-019 es su primer trabajo.**
>
> ## ALCANCE VIGENTE DE 1.34.0 — CUATRO trabajos, reordenado el 2026-09-09
> *(estados re-derivados del disco el **2026-09-10**, actualizados sobre `af01436` al cerrar la
> sesión — **el punto de continuidad vigente es `docs/ESTADO.md` §«★★ RETOMAR AQUÍ»** y el informe de
> traspaso es `docs/TRASPASO-2026-09-10.md`. Cifra firme de bloqueantes: **34** (`R-028`), no 23.
> **`SEC-075` debe resolverse ANTES de publicar `v1.34.0`.** Es coordinación: ninguna
> decisión del propietario se cambia, y el texto anterior se conserva tachado. `REQ-020`, cuya
> ventana destino es 1.34.0 y que aporta **8 de los 23** bloqueantes, **no figura en esta tabla**:
> su ventana es la decisión 1 de `docs/propuesta-cierre-1.34.0.md`.)*
>
> **Decisión del propietario (2026-09-09), literal:** *«Decido aplazar `REQ-019` a 1.35.0 para
> reevaluarlo. Conservá lo trabajado; no lo marques completado ni inviertas más en su reparto ahora.
> Para 1.34.0, priorizá las correcciones pendientes de `REQ-026` y la remediación de `REQ-023`/`024`.
> Mantené `REQ-027` en la ventana e implementalo sobre la estructura actual.»*
>
> | # | Trabajo | Estado |
> |---|---|---|
> | **1** | La sonda de `REQ-017 CA-08` | ~~CERRADO (`completado`, `496068c`)~~ → **REABIERTO** el 2026-09-09 por §9 REGLA DE ESTADO (write-back de `CA-03`). Hoy `en-progreso`; **`QA: con-hallazgos`** (2026-09-10, `86a44c8`): 1 `contrato` (`QA-017-24`) + 7 `instrumento`. El `Seguridad: aprobado` vigente es del 2026-09-08 sobre `538c266` — **anterior al modo medido**. **2026-09-10: `bloqueado`** por la salida de §6 (vuelta 3 de 3 agotada, `QA-017-31` `contrato`), escalado como `D18`; el propietario **autorizó** la corrección y una revalidación **fuera del contador**, ambas ejecutadas |
> | **2** | `REQ-026` — correcciones pendientes | `en-revisión`. Bloquean **`SEC-067`** (`usuario/dinero`, `en-mitigación`: código acreditado, **falta write-back**), `SEC-072` y `SEC-073`. Y **`CA-13`, `CA-14`, `CA-16`, `CA-17` siguen SIN IMPLEMENTAR** (declarado en su propio campo `QA:`) — no es redacción pendiente |
> | **3** | `REQ-023` + `REQ-024` — remediación de `SEC-047` | ~~`REQ-023` en implementación~~ → **los dos `bloqueado`**, cada uno tras **agotar las tres vueltas** de §6. `REQ-023`: cero bloqueantes en el campo, **pero `CA-11` es falso sobre este árbol bajo dos firmas verdes** (`D13`). `REQ-024`: `QA-024-19`, `SEC-083`, `SEC-084`, y **`Seguridad: pendiente` — la auditoría nunca se hizo** |
> | **4** | `REQ-027` — reglas de coordinadora, **sobre la estructura actual** | **`completado`** (`95764db`, 2026-09-09). QA y Seguridad `aprobado`. Quedan 4 `instrumento` abiertos (`QA-027-08`, `SEC-074`, `SEC-076`, `SEC-077`), que **no** bloquean |
> | — | ~~`REQ-019` — adelgazar los documentos de arranque~~ | **APLAZADO a 1.35.0.** Lo trabajado se conserva |
>
> **Por qué `REQ-027` ya NO va detrás de `REQ-019`, y la coordinadora se corrige:** recomendó ponerlo
> detrás por **retrabajo** —`REQ-019` movería texto de `AGENTS.md` y `REQ-027` inserta un bloque en él—.
> Comprobado el 2026-09-09, **no existe dependencia técnica y el propio REQ contrata lo contrario**:
> `requirements/REQ-027.md:258` dice *«Preferencia: que este REQ entre **antes**, porque añade 2 600 B»*,
> y su `CA-05` existe para **dar a `REQ-019` un número contra el que medir**. Con `REQ-019` aplazado, la
> colisión desaparece y la preferencia del contrato manda.
>
> **Lo que el aplazamiento de `REQ-019` deja escrito, para que 1.35.0 no reempiece:** el techo `0,72×`
> es **insatisfacible en bytes** (suelo medido `0,810×`); la propuesta con punteros incluidos está en
> `docs/arnes/req-019-techo-propuesto.md` (**≤ 0,91×**, **−7.188 B** de lectura obligatoria, etiquetada
> como **proyección**); las dos enumeraciones de F1 **no sobreviven en disco**, así que `CA-15` exige
> rehacer el inventario por bloques; y el `## Índice` del README **pesa 7.867 B y está fuera de
> alcance**, retirando más bytes que el reparto completo. `SEC-033` sigue abierto (`contrato`).
>
> ## ALCANCE ANTERIOR (histórico) — CINCO trabajos: cuatro fijados el 2026-09-08 y el quinto el 2026-09-09
>
> «Aplica tu recomendación» (2026-09-08). La recomendación era **tres**; la medición la corrigió a
> **cuatro**, y la corrección va escrita porque es el tipo de error que este plan existe para no repetir.
>
> **Y el 2026-09-09 el propietario añadió el quinto**, con su orden fijado: *«Autorizo incorporar
> `REQ-027` como quinto trabajo de 1.34.0. Ejecutá su implementación **después de `REQ-019`, sobre la
> estructura resultante**. Incluí plantilla, instalación y migración de proyectos existentes, con sus
> verificaciones.»* La coordinadora había recomendado **1.35.0**; el propietario decidió **1.34.0 con
> orden explícito**, que resuelve el motivo de la recomendación —la competencia por `AGENTS.md`— sin
> aplazar el trabajo. Queda escrito porque una recomendación desatendida con motivo es información, no
> ruido.
>
> | # | Trabajo | Por qué NO se puede cortar |
> |---|---|---|
> | **1** | **La sonda de `REQ-017 CA-08`** | Decide la **puerta requerida** de `main` con un instrumento cuyo ruido (0,973×–1,364×) **cubre su techo** (1,25×). Mientras siga así, toda publicación se firma sobre una señal que no distingue |
> | **2** | **`REQ-019` — adelgazar los dos documentos de arranque** | El **87 %** de los bytes del ritual se leen en **cada comisión**. Es la palanca de tokens, y 1.34.0 es la ventana con más comisiones |
> | **3** | **Archivar las bitácoras** (`rotacion` + `veredictos.*` del manifiesto) | `CHANGELOG.md` 467 KB + `registro-seguridad.md` 458 KB ≈ **240 k tokens** de ventana potencial. Medido: un auditor que cargó uno entero consumió **2,56 M** de lectura de caché. **Necesita REQ: no existe** |
> | **4** | **`REQ-023` + `REQ-024` — la remediación de `SEC-047`** | **No es elegible.** `SEC-047` es de severidad **crítica** y su vencimiento —**el cierre de 1.34.0**— está escrito en `docs/seguridad/registro-seguridad.md:3684`, **por el auditor y en su sede**. Cerrar 1.34.0 sin esto sube `SEC-047` y `SEC-051` a **`contrato`** |
> | **5** | **`REQ-027` — las reglas de coordinadora, con plantilla, instalación y migración** | Entra el **2026-09-09** por decisión del propietario, y **después de `REQ-019`, sobre la estructura resultante**. El orden no es preferencia: `REQ-019` **mueve de sitio** buena parte de `AGENTS.md` y `REQ-027` **inserta un bloque nuevo** en ese mismo archivo; al revés habría que escribirlo y luego moverlo. Alcance confirmado: plantilla + `arnes-init` + `arnes-upgrade` **con sus verificaciones** (`CA-09` y `CA-10`, éste como **condición de entrega**). **Crear el REQ no instala nada**: hoy hay 11 criterios contratados y cero implementado |
>
> **Por qué el 4 entra aunque yo recomendara tres.** La recomendación inicial contaba coste y olvidó un
> **plazo con dueño**. La diferencia con `SEC-052` —el forzador que resultó ser «un argumento con la firma
> de otro»— es exactamente la sede: aquel vivía sólo en el REQ cuyo aplazamiento castigaba; **éste está en
> el registro de seguridad, firmado por quien podía firmarlo.** Un forzador en su sede no se negocia
> midiendo coste.
>
> **Los DOS «primeros trabajos», y cómo se resuelve.** `SEC-047` se declara «primer trabajo de 1.34.0, por
> delante del núcleo por estado» (`:3684`) y la enmienda del propietario declara primero **la sonda**. No
> hay conflicto real: el vencimiento de `SEC-047` es **el cierre** de la ventana, no su apertura, y se
> cumple en cualquier orden **dentro** de ella. **La sonda va primera** porque es la única que bloquea
> *publicar*, y lo demás de esta ventana se publica a través de ella.
>
> ### CORRECCIÓN DEL ORDEN (2026-09-08): el propietario prioriza **bajar el coste**
>
> «Me interesa dar prioridad a bajar el costo del Arnés, para que la cuenta me rinda más.» El orden
> anterior ponía **la sonda primero** porque bloquea *publicar*. Pero bloquea **al final**; las palancas
> de tokens abaratan **todo lo que pasa en medio**. Es la regla de orden del encabezado de este plan —
> *lo que compone va primero*— aplicada correctamente.
>
> **El impuesto de arranque, medido el 2026-09-08 y mayor de lo que se venía citando:**
> `AGENTS.md` 33.827 B + `requirements/README.md` 40.020 B + `CLAUDE.md` 408 B = **74.255 B ≈ 18.500
> tokens, en CADA comisión** (se citaba ~9 k, que era sólo `AGENTS.md`).
>
> **Y el 72 % vive en SEIS secciones**, medido sección a sección:
>
> | Documento | Sección | Bytes |
> |---|---|---:|
> | `requirements/README.md` | Cómo se escribe un criterio que no se desmiente | **12.609** |
> | `AGENTS.md` | §13 Enforcement por runtime | **10.363** |
> | `requirements/README.md` | El mapa de archivos: el campo `Archivos:` | **10.247** |
> | `AGENTS.md` | §6 Orquestación, loops y gates | **9.796** |
> | `requirements/README.md` | **`## Índice`** | **7.025** |
> | `AGENTS.md` | §5 Equipo de agentes | 2.977 |
> | | **suma** | **53.017 B ≈ 13.300 tokens/comisión** |
>
> ### PERO: el techo de `REQ-019` es INALCANZABLE, y esto para la ventana
>
> La enumeración F1 lo midió por **dos vías ciegas independientes** y las dos coinciden: el **suelo
> forzado** —lo que no se puede quitar sin perder una invariante— es **≈0,70×** en `AGENTS.md` y
> **≈0,66×** en el README, **≈0,68× total**, contra el **≤0,60×** que `CA-07` contrata. **El techo no se
> alcanza**, y el propio REQ predecía el problema **sólo en el README**. En bytes será peor que en
> líneas: las dos poblaciones de líneas más largas —la tabla de §13 y el `## Índice`— **son suelo al
> 100 %**. Su línea base además está desfasada (declara el README en 433 líneas; tiene **522**).
>
> **Renegociar ese techo es firma del propietario**, y hasta que exista, despachar `REQ-019` es pagar
> cuatro comisiones para chocar contra un número imposible. Más `D-3`, `D-5` y `D-9`: tres defectos en
> sus **propios criterios**, que se arreglan **antes** de repartir nada.
>
> ### La consecuencia sobre el ahorro real, dicha sin adornos
>
> Con suelo 0,68×, `REQ-019` recorta como mucho **~32 %** del impuesto: **≈5.900 tokens por comisión**,
> no los ~7.400 que sugería el techo escrito. Sigue pagándose en menos de una ventana, pero **no es la
> palanca que parecía**.
>
> **Y la palanca mayor del día no fue ninguna versión del plugin: fue el ENCARGO.** Seis comisiones del
> 2026-09-08/09 con el mismo modelo: **229 k → 154 k → 107 k → 64 k → 46 k → 58 k**. Lo único que cambió
> fue cerrar la lista de lectura —rangos de línea en vez de archivos, cifras entregadas ya medidas, y
> prohibiciones explícitas—. **Un factor 5, gratis y ya aplicado.** Ninguna de las palancas contratadas
> se le acerca, y conviene tenerlo escrito antes de invertir cuatro comisiones en recortar un 32 %.
>
> ### Lo que SALE de 1.34.0, con su destino
>
> `REQ-020` (las pruebas que no miden) · `REQ-022` (el despacho en paralelo) · `REQ-025` (la puerta sobre
> la coordinadora) · `REQ-018` (el canal de informes) · `REQ-008` (el informe con gráficos) · `REQ-011`
> (la puerta que pregunta después) → **1.35.0**. `REQ-021` sigue **`bloqueado`** y no se retoma hasta que
> el propietario decida su salida.
>
> **El criterio del corte, para que no se relaje solo:** entra lo que **devuelve dinero** (2 y 3), lo que
> **devuelve una señal fiable** (1) y lo que **tiene plazo con dueño** (4). Todo lo demás son mejoras que
> se pagan mejor **después** de abaratar el ciclo, no antes. Es la misma regla de orden del encabezado de
> este plan: **lo que compone va primero.**
>
> **Y el motivo de cortar, medido y no intuido:** 1.33.0 empezó siendo «la skill de migración» y a media
> ventana tenía **nueve trabajos**. Diez trabajos no caben en una ventana, y una ventana que no cabe **se
> corta a mitad de una comisión** — que es como se descontroló el ciclo 3.

> **ENMIENDA DEL 2026-09-08, REVERTIDA EN PARTE EL 2026-09-08.** El propietario aplazó el tag y luego
> **decidió publicar**: `v1.33.0` está publicada (merge `810128a`, puerta requerida en verde y fusión con
> cuenta **sin admin**), con su límite declarado — la evidencia de rendimiento es el `0,125×` de `CA-05`,
> **no** el verde de `CA-08 (ii)`. **Lo que NO se revierte: el primer trabajo de 1.34.0 sigue siendo la
> SONDA DE `REQ-017 CA-08`, por delante de `REQ-019`** — y con más motivo, porque ese caso ya está
> decidiendo cada PR sin poder distinguir.**
> Motivo, y es una medición, no una preferencia: el caso
> `REQ-017 CA-08 (ii) una cabecera de 200 líneas` falla el check **requerido y estricto**
> `hooks-en-linux` afirmando «esto es una regresión, no ruido», y **cuatro corridas sobre código
> idéntico** —ningún commit desde `b9afa01` toca `hooks/`, `tools/` ni `.github/`, verificado por
> `R-019`— publicaron **1,131× · 0,973× · 1,337× · 1,364×**. El **0,973×** dice que este árbol salió
> **más rápido** que `v1.32.1`, y una regresión real no puede ser más rápida: la dispersión (factor
> **1,40**) **cubre el techo (1,25)**.
>
> **CORREGIDO el 2026-09-08, antes de que nadie trabajara sobre lo anterior.** Una primera lectura
> concluyó que el defecto era que el umbral de convergencia y el techo fueran el mismo número. **Es
> falso: lo son a propósito**, y `CA-08` lo argumenta — *«no es un número nuevo: es el mismo, porque un
> instrumento tiene que resolver al menos el factor que vigila»*. **El caso hace lo que su criterio
> prescribe.** Lo que las cuatro corridas muestran es peor: **el remedio que `CA-08` ya prescribió
> —intercalar las series y comprobar convergencia— está IMPLEMENTADO y no basta.**
>
> **Dónde está el hueco:** la convergencia compara el segundo mínimo de **cada árbol** con su propio
> mínimo, o sea mide si **cada serie** se asentó; el ruido de la **razón** viene de las condiciones
> **entre brazos**. Dos series pueden converger cada una a 1,2× y su cociente oscilar 1,4×. Y los datos
> lo enseñan: **los dos rojos son justo aquellos en que un brazo converge al borde** —1,232× y 1,249×
> contra el límite de 1,250×—, mientras los dos verdes tienen convergencias equilibradas.
>
> **La clase, nombrada:** `CA-08` dice «**al menos** el factor que vigila» y eligió el valor **más flojo**
> compatible con ese argumento **sin medir si alcanzaba**. Es *un criterio derivado sin comprobar su
> factibilidad* — la misma clase que el techo de 400 líneas de `REQ-014 CA-18` y que el techo de 4× de
> `REQ-021 CA-08 (iii)` re-derivado a 6×.
>
> **Por qué va DELANTE de `REQ-019` y no detrás:** mientras el techo viva dentro del ruido, **el verde de
> esa puerta no acredita nada más que el rojo**. Toda publicación posterior —1.34.0 incluida— se firmaría
> sobre una señal que no distingue. Arreglarla antes evita repetir esta conversación en cada ventana.
> Detalle completo y las opciones descartadas, en la entrada resuelta de `PENDING_APPROVAL.md`.
>
> **REQ-023 salió el mismo día que entró, y el motivo es que su coste se midió después de meterlo.** El
> analista lo evaluó y no cabía donde estaba: **cuatro comisiones en serie** tras REQ-021 —cata del
> desarrollador para decidir `CA-03` frente a `CA-04`, implementación cuyo bulto es el banco, QA con
> **una vuelta dev↔QA por diseño** (`CA-03` está escrito para que una implementación por lista falle) y
> auditoría por `Rigor: critico`—, sin paralelismo posible y con dos precondiciones ajenas
> (`CA-09 (iii)` espera a que REQ-021 suelte `tests/util/`; `CA-08` depende del tag). Y aplazarlo **no
> incumple nada**: el vencimiento de `SEC-047` es el cierre de **1.34.0** (`registro-seguridad.md:3684`),
> así que meterlo aquí había sido un **adelanto**, y desandar un adelanto no incumple un vencimiento.
>
> **El argumento con el que se justificó tenerlo aquí era falso, y conviene que quede escrito porque lo
> escribió la coordinadora.** Se dijo que publicar sin él «publica una ventana más una promesa falsa en
> `AGENTS.md` §6/§13». `R-013 §2` ya había **medido** que cerrar la vía del carácter **no cierra la
> clase** —el comentario y el borrado siguen abiertos, y son `SEC-050` y `SEC-047 (2)`, los dos de
> 1.34.0—; que las filas son falsas **desde `v1.30.3`**, en cinco versiones, de forma **latente**; y que
> aplazar deja §13 **igual de honesta**, porque la fila del CR la reescribe `CA-10`, que es de REQ-023.
> Una consecuencia inventada para sostener una prioridad es la misma forma que `SEC-052`.
>
> **Y el historial de este alcance vale más que el alcance, porque es el registro de una ventana que se
> movió cuatro veces en dos días.** Se fijó el 2026-09-07 en `REQ-017 + REQ-019 + REQ-021` con `REQ-020`
> fuera. El 2026-09-08 entró **REQ-023** —el carácter invisible, un bypass completo del enforcement
> presente en las cinco versiones publicadas, medido por `R-012`— y salió **REQ-019**, cuando su
> estimación pasó de ~2 h a **7–11 h en cuatro fases**: no cabe en una comisión, obliga a una comisión de
> analista previa por `CA-15`, y su `CA-16` **detiene la ventana** durante dos de sus fases. Sacarlo no
> pierde su ahorro: el argumento para tenerlo aquí era que *1.34.0 es la ventana con más comisiones*, y
> eso se cumple igual siendo **el primer trabajo de 1.34.0**.
>
> **Lo que esta ventana NO entrega, dicho por su nombre: la reducción de tokens.** REQ-017 abarató el
> **reloj** del banco (95,66 s → 45,14 s) y esperar al banco es gratis en tokens; REQ-021 ahorra
> ~150 k por ventana pero sólo cuando exista; **la palanca de tokens es REQ-019, y se fue a 1.34.0.**
> Medido el 2026-09-08 y corrigiendo la cifra de la tabla de arriba: el impuesto de arranque **no son
> ~9 k sino ≈17 000–20 000 tokens** por subagente, porque §0 obliga a **tres** documentos y
> `requirements/README.md` pesa el **42 %** —bytes y palabras medidos con `wc`; la conversión a tokens es
> **estimación**—. Y su parte movible es menor de lo que parece: **el suelo inamovible del README es el
> 54 % de las líneas y ≈58–64 % de los bytes**, así que el ahorro real por movimiento son **≈11–13 kB**,
> y el bloque más caro —el `## Índice`, 19 % del archivo— **no lo baja REQ-019**, porque es una copia a
> mano de lo que `tools/arnes-lectura.sh` ya deriva: eso es un mecanismo, con otro dueño.
>
> Con los cuatro, la ventana salía a **~5–6 h** frente a las ~3 h con que se partió esa misma mañana —
> REQ-021 solo son ~2 h y ~650 k tokens—. Y el corte no es sólo presupuestario: **REQ-020 depende de
> REQ-021**, porque su criterio de coste pide exactamente las sondas que REQ-021 construye (series
> intercaladas, mínimo de k, procesos por sección). El orden natural es **021 → 020**, y hacerlo al
> revés obliga a escribir las sondas dos veces. **REQ-021 era el peor candidato a aplazarse** por su
> propio argumento: paga ~150 k por ventana más dos clases de prueba-que-miente, y 1.34.0 es la que más
> comisiones tiene.


> **Y la palanca 3 es la que hace útil lo que viene después: el paralelismo.** Hoy no se puede
> despachar en paralelo casi nada, y no por prudencia — `skills/arnes-upgrade/SKILL.md` colisionaba en
> **15 de 15** pares de comisiones porque cada una escribía ahí su nota de migración. Retirada esa
> colisión, el campo `Archivos:` de dos REQ puede salir **disjunto** de verdad. Con dos condiciones que
> no se relajan: el paralelismo se autoriza sólo con `tools/arnes-paralelo.sh`, **nunca por intuición**
> (§6), y mientras **SEC-020** siga abierto ese `disjunto` es condición **necesaria y no suficiente** —
> sobre un campo decorado responde que sí con el mapa corrompido. Por eso SEC-020 está en la pasada de
> conformidad de 1.34.0: es lo que convierte el permiso en fiable. Y el orden de fases (QA nunca antes
> que el desarrollador, seguridad nunca antes que QA) no se paraleliza en ningún caso.

**Y el dato que ordena todo lo demás:** las comisiones que **miden** corren a 6 200–7 500 tokens por
minuto de reloj; las que **piensan** (análisis y write-back), a 12 000–17 000. No miden más despacio:
**esperan al banco**. Una comisión que lo corre ~20 veces se pasa 13 de sus 39 minutos mirándolo correr.

> **Corrección de la coordinadora (2026-09-07, al cerrar la ventana). El «31,3 s de 39 en la sección
> 36-2» que esta tabla traía era una medición MAL MUESTREADA, y la escribí como si fuera un dato.**
> Medí cinco secciones **elegidas a ojo** y la ruta crítica no estaba entre ellas. Con las 41 medidas,
> con la máquina limpia y sabiendo que **el corredor ya paraleliza secciones** (`&` + `wait -n`, de ahí
> el ~200 % de CPU), el reparto real es:
>
> | Sección | Reloj |
> |---|---|
> | **`32-huecos-auditoria-r001.sh`** | **75,7 s** ← la ruta crítica |
> | `36-2-los-lectores` | 26,6 s |
> | `25-presupuesto-de-analisis` | 16,7 s |
> | Las otras 38 juntas | ~40 s |
>
> Con paralelismo, el banco entero ≈ la sección más lenta, así que **partir la 36-2 no habría movido el
> reloj**: la palanca es la 32. Y hay una segunda mitad, medida aparte y anotada como hallazgo de coste:
> la 32 pasó de **7,6 s con los hooks de 1.32.0 a 75,7 s con los de 1.32.1** — 10×, introducido por este
> parche, acotado a los casos con **caracteres de control** y **sin efecto en una llamada normal**
> (0,166 → 0,171 s por llamada, medido).
>
> **Las dos lecciones, y la segunda es la que duele.** Primera: un muestreo no es una medición, y
> presentarlo como tal contamina un plan entero. Segunda: **CA-08 se cumplía.** Ese criterio mide
> **procesos** por llamada —4 = 4, correcto— y lo que se degradó fue **tiempo**. Un criterio de coste
> que fija la magnitud equivocada da verde sobre una regresión de 10×. La pasada de conformidad tiene
> que ensanchar CA-08 a **reloj**, no sólo a forks.

### El núcleo — MOVIDO A 1.34.0 (propietario, 2026-09-07)

Se queda escrito aquí porque el **tema** de arriba es suyo: la tabla estado-vs-vía explica por qué
estas cinco piezas se agrupan y por qué juntas cuestan menos que por separado. Lo que cambia es
**cuándo**: ninguna de ellas se despacha en 1.33.0.

| Trabajo | Qué cierra | Clase |
|---|---|---|
| **REQ-011 — la puerta posterior** | Deja de preguntar **antes** si un comando escribe y pregunta **después** si algo protegido cambió. Tiene ya **dos forzadores medidos**: el cierre por heredoc de `python3` y una preferencia de sesión por la consola que reapareció **tres veces** en 1.32.1, después de escribirse la regla | `contrato` |
| **SEC-025 — el barrido por estado** | «De mis REQ en estado terminal, ¿cuáles no cerrarían hoy?». Cubre la cita, el delimitador fabricado, la clave fabricada y las vías que nadie ha descubierto, porque no describe ninguna. Barato: `arnes_campos_req "$disco" ""` | `instrumento` |
| **SEC-029 — el barrido de base** | Un control **diferencial** no puede encontrar, por construcción, lo que ya está en la base. NFR de gobernanza de datos sobre el árbol completo | `contrato` |
| **La puerta de «¿esta prueba mide algo?»** | **Adelantada desde 1.34.0.** Un caso nuevo tiene que **fallar** contra los hooks de la versión anterior. Habría cazado los cinco casos vacíos el día que nacieron — y sin ellos no hay vuelta 1, que costó **685 000 tokens y 1 h 35** | `instrumento` |
| **REQ-007 bloques B y C, y CA-64.1-bis/2-bis** | Lo que ya estaba planificado: la cabecera que se sale de alcance, el destino entrecomillado, el texto humano que sube y el archivo en sólo lectura. Con esto **cierra REQ-007** | — |

### La pasada de conformidad — también a 1.34.0; recoge cinco cosas y por eso sale barata

1. Las **tres promesas incondicionales más anchas que el código**: `ADR-002`, la visibilidad que el
   informe no da, y el «el hook impide cerrar sin `QA: aprobado`» que es falso cuando el campo no se
   declara.
2. **SEC-020** — la gramática de `Archivos:` y el desenvoltorio por elemento.
3. **SEC-028** — que la enumeración de los descuentos de CR sea **por construcción y no por
   inspección**, y el fuzz diferencial con semillas fijas **dentro** del banco (hoy la medición más
   fuerte sobre esa clase es de QA y el CI no la puede repetir).
4. **H-06** — la nota al margen que desactiva el bloqueo de la cola de aprobaciones. **Sigue sin
   dueño**; le corresponde `desarrollador`.
5. **La vía de fuga del modelo de clases, encontrada por el analista el 2026-09-07:** se puede volver
   **bloqueante** un hallazgo `instrumento` escribiéndolo dentro de un criterio de aceptación, **sin
   firmar la reclasificación**. `AGENTS.md` §6 dice que el defecto de un control no puede ser condición
   para cerrar la función que vigila; un criterio que exige el control consigue justo eso por la puerta
   de atrás. Hay que nombrarlo donde vive la tabla de clases.

### Lo que se saca de esta ventana, a propósito

**El canal de informes y las plantillas de issue van a 1.34.0.** Es valioso y no es urgente, y meterlo
aquí es exactamente cómo se descontroló el ciclo 3. La decisión de accesos ya está tomada y medida
(SEC-026/SEC-027): los informes entran como issues en el repositorio **público**, con una **gramática
restringida** en la plantilla en vez de muros de permisos — un repositorio de cuenta personal no tiene
roles granulares, así que la privacidad se resuelve por la **forma** del formulario y no por el rol.

---

## 1.33.0 — detalle heredado de la planificación anterior

**Qué entra:** lo que cierra huecos del mecanismo. Todo toca `hooks/`, así que es una ventana coherente
y va en serie por colisión de archivo.

| Trabajo | Qué cierra |
|---|---|
| **REQ-007 bloques B y C** | La cabecera que se sale de alcance con un `## ` de más, y el destino **entrecomillado** que hoy desarma el detector (`git clean "-f"` pasa). Con esto **cierra REQ-007**, que hoy cruza dos ventanas |
| **REQ-007 CA-64.1-bis y 2-bis** | El texto humano de `docs/ESTADO.md` que **sube** por encima del bloque en cada parada, y el archivo en sólo lectura que se reescribe cambiando su modo. Heredados, sin pérdida de bytes |
| **REQ-011 — la puerta posterior** | Deja de preguntar **antes** si un comando escribe —pregunta abierta que no se gana— y pregunta **después** si algo protegido cambió. Es la respuesta de fondo a la palabra del estado terminal partida en expansiones |
| **Dos avisos heredables** | Que la migración diga que **hay que reiniciar la sesión** —hoy no lo dice en ninguna parte, y un proyecto que actualiza cree estar protegido por puertas que aún no corren—, y que la nota de `guard-git` enumere los siete envoltorios que ahora se toleran |

**Convivencia de REQ-007 y REQ-011, decidida el 2026-09-06:** van en la misma ventana, REQ-007 primero.
Su evidencia es distinguible **por construcción**: uno decide en `PreToolUse` y el otro reporta en
`PostToolUse`, así que un veredicto que cambie sólo puede venir del primero. Colisionan por archivo, no
por semántica, y por eso van en serie.

**Palanca propuesta por el analista al cerrar 1.32.0, y aceptada: pasada de conformación anticipada.**
Antes de abrir la ventana, una **única** comisión del analista pasa la regla de REQ-012 sobre REQ-007 y
REQ-011, que son del ciclo 2 y traen su propio stock de números sin declarar. Paga la migración en una
comisión en vez de descubrirla como hallazgos y una vuelta del bucle. Respeta el «0 comisiones nuevas
**por REQ**» que CA-21 declara de contrato, porque es una pasada única y no un paso del pipeline.

**Predicción registrada para medir contra ella:** 2 a 4 hallazgos de forma (a)/(b)/(c), `número`
predominante otra vez, y 0 o 1 vueltas del bucle. El objetivo de ≤ 3 es alcanzable y no está asegurado.

---

## 1.34.0 — lo que los proyectos leen, **más el núcleo por estado**

> ### `REQ-019` va PRIMERO, sin excepción — decisión del propietario, 2026-09-08
>
> **`REQ-019` —adelgazar `AGENTS.md` y `requirements/README.md`, la única de las cuatro palancas de
> coste que reduce TOKENS y no reloj— lleva sacado de la ventana en curso DOS VECES** (06-07 y 08-09):
> primero de 1.33.0 por su propia estimación (~2h → 7-11h), y su ejecución en código **no avanzó ni una
> línea en toda la sesión del 08-09** pese a estar planificada como «primer trabajo de 1.34.0» desde el
> primer día. En su lugar, esa sesión gastó ~30 comisiones en cerrar REQ-017, agotar y bloquear REQ-021,
> reabrir REQ-014, y cazar cuatro hallazgos de gobernanza (`SEC-052`→`055`) sobre la propia delegación de
> publicación — trabajo real y necesario, pero **no** el que reduce coste.
>
> **Por eso esta vez la protección se escribe, no se supone:** 1.34.0 **empieza** con `REQ-019` y **nada
> más** entra en la ventana hasta que cierre — ni el bloque de paralelismo de abajo, ni el núcleo por
> estado, ni un hallazgo nuevo que aparezca a mitad de camino, salvo que bloquee la publicación misma
> (la clase de `SEC-05x` de hoy). Un hallazgo que no bloquea se **anota y se enruta**, exactamente como
> `REQ-019` CA-10 ya contrata para su propio trabajo — no se atiende dentro. Si algo obliga a romper esta
> regla, se escribe aquí el motivo, con la misma disciplina que esta nota documenta el porqué de hoy.

> ### Bloque de apertura: **el paralelismo**, antes que el núcleo (encargo del propietario, 2026-09-07)
>
> Mismo argumento que puso las palancas primero en 1.33.0: **el paralelismo abarata la ventana grande,
> así que hacerlo antes es la única forma de cobrarlo** — y ésta es la que más comisiones tiene.
> Diseño completo, con lo medido el día del primer despacho paralelo real, en `docs/PENDIENTES.md`
> § «Trabajar con agentes en paralelo». Cinco piezas, de más barata a más cara:
>
> | | Pieza | Qué desbloquea |
> |---|---|---|
> | 1 | El **libro mayor es de la coordinadora**: ninguna comisión escribe `CHANGELOG.md` ni comitea, y esos artefactos salen de `Archivos:` | Quita la colisión universal — **8 de los REQ abiertos declaran `CHANGELOG.md`**, así que la herramienta dice «colisiona» sobre **cualquier** par |
> | 2 | **Ámbito asignado** en el despacho; `arnes-paralelo.sh` pasa a **segunda opinión** que puede desmentir, no a autorización | Asignar falla visible (la comisión desobedece y se ve en el diff); comprobar falla en abierto (campo incompleto o decorado, **SEC-020**) |
> | 3 | **`Mide: sí/no`** en la cabecera: **dos comisiones que miden no se despachan a la vez** | La segunda dimensión de colisión — **la máquina**, que ninguna herramienta de archivos puede ver, y cuyo fallo es silencioso: cifras mal, sin conflicto ni error |
> | 4 | **Puerta posterior de ámbito**: al cerrar una comisión, *¿cambió algo fuera de su ámbito?* | La **escritura perdida** — dos agentes sobre el mismo archivo en el mismo árbol **no dan conflicto de fusión, dan pérdida silenciosa**; git no protege de esto |
> | 5 | **SEC-020** + la convención de artefactos de gobierno en `Archivos:` | Que la segunda opinión valga algo |
>
> **La pieza 1 se adelanta a 1.33.0**, y sólo como redacción: ya está **en vigor de facto** desde el
> despacho del 2026-09-07, y una práctica en vigor sin escribir es deuda desde el primer día.
>
> **Lo que no cambia:** el orden de fases no se paraleliza nunca — no es calendario, es la condición de
> validez de la firma.

> **Recibe el núcleo de 1.33.0 (propietario, 2026-09-07):** REQ-011, SEC-025, SEC-029, la puerta de
> «¿esta prueba mide algo?», REQ-007 B/C, la pasada de conformidad con sus cinco piezas y el canal de
> informes. Su justificación y su tema —estado, no vía— viven arriba, en 1.33.0, y no se repiten aquí.
> Es una ventana grande: **se planifica con las palancas ya medidas**, no antes.

**Qué entra además:** todo lo que cambia qué documentos entran en el contexto de un agente y qué se ve
de un proyecto sin abrir diez archivos.

| Trabajo | Qué cierra |
|---|---|
| **REQ-008 — informe de proyecto** | Lo que pidió el propietario: resumen de cada REQ, NFR, hallazgo y decisión, con **porcentaje de avance**, **qué lo detiene**, decisiones humanas pendientes y recomendaciones; en HTML, siguiendo la guía de marca del proyecto si existe. Evolución de `arnes-panel`, con la cuenta hecha por `tools/arnes-avance.sh` y no por el modelo |
| **Índice de `requirements/` derivado** | Sus columnas se desfasaron **cuatro veces en dos días**. Pasa a bloque derivado entre marcadores, con el mismo lector que usan la puerta y el informe. Misma función, escrita una vez |
| **Rotación que reconoce filas de tabla** | Hoy la rotación de la historia de un REQ **no rota nada** en este repositorio: 0 entradas reconocidas y 94 filas de tabla. Es su caso de uso principal y no funciona |
| **`AGENTS.md` + `requirements/README.md` adelgazados — `REQ-019`** | **Sale de 1.33.0 el 2026-09-08**, cuando su estimación pasó de ~2h a **7–11h en 7 fases** — no cabe en una comisión. Es el impuesto de arranque real (**≈17-20 k tokens por subagente**, no ~9 k) y 1.34.0 es precisamente la ventana con más comisiones: adelgazarlo después es pagarlo entero primero |

**Alcance añadido por el propietario el 2026-09-06 — el coste entra en el informe.** El informe de
REQ-008 lleva además **qué costó** el proyecto: tokens por REQ, por fase y en total; tiempo de agente,
reloj del ciclo y su cociente; y una comparación con lo que le habría llevado a una persona. Diseño
acordado, para que el analista lo escriba como criterios cuando se abra la ventana:

1. **Tres clases de número, nunca mezcladas y siempre etiquetadas: `medido`, `derivado`, `estimado`.**
   Un informe que mezcla los tres deja de ser creíble entero, no sólo en la fila dudosa.
2. **La fuente es el libro de comisiones** (`docs/qa/<versión>.md`), que se anota **al volver cada
   comisión** porque el dato no se puede reconstruir después. El informe lo lee con el mismo lector que
   las puertas; no lo recalcula ni lo estima.
3. **El coste de la coordinadora se declara aparte y no se omite.** Medido en el ciclo 2 fue el **39 %**
   del gasto. Un informe que sólo suma comisiones se equivoca en un tercio largo y hacia abajo.
4. **Tres relojes distintos, con nombres distintos:** tiempo de agente (suma de comisiones), reloj del
   ciclo (de abrir la rama a publicar) y su **cociente**, que es la única medida honesta de cuánto
   paralelismo hubo de verdad.
5. **La comparación con una persona se expresa como rango con su base escrita**, nunca como un múltiplo
   suelto. La base son unidades que el lector puede comprobar —líneas de shell, casos de banco,
   criterios, documentos— y la suposición se escribe al lado («persona que ya conoce el código, sin
   interrupciones»), porque es la suposición que siempre infla el resultado.
6. **La cifra que decide no es el coste, es el coste por resultado:** por REQ cerrado y por hallazgo
   atrapado antes de publicar. 253 USD por veinte defectos encontrados antes de que salieran es una
   frase distinta de 253 USD a secas.
7. **Una sección de lo que el número NO incluye:** la ceremonia máxima que este repositorio se impone a
   propósito, el tiempo de revisión del humano y las vueltas fallidas.

**Segundo uso declarado por el propietario el 2026-09-06: justificar el licenciamiento.** El informe
tiene dos lectores, no uno. El primero gobierna el proyecto; el segundo aprueba un presupuesto y llega
con escepticismo. Reglas de diseño para el segundo, y son distintas:

- **El caso NO se construye sobre este repositorio.** ArnesJuan se impone la ceremonia máxima a
  propósito —todo REQ `critico` y sensible, los cuatro agentes— y por eso es el ejemplo **más caro por
  unidad entregada** que existe. Presentarlo como muestra hunde el caso. El caso se construye sobre el
  proyecto consumidor, que corre en `estandar` o `ligero` y entrega valor de negocio.
- **La tarifa es un dato de entrada, no una afirmación del informe.** El informe **no** declara cuánto
  cuesta una hora de desarrollo: la recibe y la usa. Así la cifra resultante es de la organización, no
  del modelo, y no hay nada que discutirle a quien la lee.
- **Tres escenarios, no un número:** conservador, central y optimista, cada uno con su base escrita. Un
  múltiplo suelto («fue 12 veces más rápido») no sobrevive a la primera pregunta; un rango con método sí.
- **El coste se declara completo o el caso se cae.** Licencia **más** gasto de modelo **más** tiempo de
  revisión del humano. El primer movimiento de un escéptico es «os habéis dejado el consumo fuera».
- **La evidencia más fuerte disponible es la propia historia del proyecto consumidor**: el mismo
  desarrollador, el mismo código, antes y después de instalar el arnés. No supone tarifas ni
  productividades ajenas — es su `git log`.
- **El caso de una segunda cuenta es OTRO argumento y no se mezcla:** no es eficiencia, es
  **concurrencia**. Dos cuentas no hacen un proyecto más rápido; permiten que dos avancen a la vez. Se
  sostiene con la cola de trabajo que hoy no se hace, no con el ahorro por hora.

---

## 1.35.0 — el banco en el que se puede creer

**Qué entra:** el **runner de mutación** y el **cribado automático** de aserciones sobre los 847 casos.

> **Ajuste del 2026-09-07, para que esta ventana y `REQ-020` no digan lo mismo.** La *puerta* que
> pregunta si una prueba mide algo es **REQ-020**, y va en **1.34.0**. Lo que queda aquí es lo que ese
> REQ dejó fuera **a propósito**: la herramienta de mutación —con sus invariantes de árbol limpio y una
> mutación cada vez— y el cribado automático. En REQ-020 la mutación entra como **procedimiento
> acreditado y registrado por un tercero**, no como herramienta; construir la herramienta allí habría
> sido la quinta palanca y repetía el ciclo 3 con otro nombre.
>
> Y la regla que esta ventana hereda de la tarde del 2026-09-07: **«acreditado por mutación» tiene que
> decir POR QUIÉN.** Dos corpus, misma dirección — el autor rompe donde sabe que importa; sólo un
> tercero rompe donde no ha mirado.

Es la ventana con más valor demostrado por la experiencia de este repositorio, y la razón está en la
bitácora: un caso pasaba con el JSON vacío; otro decidía por reloj de pared; una sección entera
desaparecía en silencio y sólo el cuadre lo delató; y un criterio de rendimiento medía el camino barato
mientras el caro no respondía. **Cuatro veces una prueba en verde no probaba nada.** Un banco que
certifica el mecanismo que gobierna a otros proyectos tiene que poder demostrar que sus casos fallan
cuando deben.

---

## 1.36.0 — el working set explícito

**Qué entra:** archivar los REQ cerrados a `requirements/archive/`, con índice **derivado** y un
resolutor de identificadores, sin subcarpetas por año y sin que `archivado` sea un estado.

**Va al final a propósito, y con la medición delante:** archivar **no ahorra tokens**. Medido, el coste
de una comisión es turnos por contexto, y un archivo que nadie lee no consume contexto. Lo que compra es
**higiene de navegación** —menos ruido en las búsquedas y menos lecturas equivocadas— y eso vale, pero
menos que todo lo anterior. Las reglas de diseño ya están escritas en `docs/PENDIENTES.md`.

---

## Backlog sin versión

Se hacen cuando estorben, no antes. Ninguno es `contrato`.

- **Capa 0 opcional**: `PostToolUse` sobre `Write`/`Edit` que corra las reglas del proyecto y devuelva el
  hallazgo en el acto.
- **El encargo contra las herramientas del agente**: aviso cuando el prompt pide ejecutar y el agente
  destino no tiene con qué.
- **Reparto de identificadores** con reserva atómica.
- **Sonda del guardián automática** y aviso cuando la sesión no está gobernada. Pasó dos veces.
- **Los dos rotadores y su temporal ante una señal**, la misma familia que se cerró en el hook de parada.
- **El falso positivo de la regla del orden**: reportado desde un proyecto real, **no reproducido**. No
  se redacta REQ hasta tenerlo: un criterio escrito sobre un defecto que no se ha visto describe lo que
  imaginamos.
- **Decisión editorial del propietario**: los nombres de proyectos consumidores y de las dos cuentas de
  GitHub en un repositorio público.
