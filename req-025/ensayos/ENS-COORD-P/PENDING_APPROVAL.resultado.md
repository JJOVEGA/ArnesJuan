# PENDING_APPROVAL — Facturador

> Cola de decisiones que esperan visto bueno humano. Un agente AÑADE una entrada con su forma
> —pregunta, opciones, recomendación y consecuencia de cada opción (`AGENTS.md` §6, regla 4)—;
> el humano la resuelve y la mueve a "Resueltas".
>
> **Qué impide esta cola, dicho con su alcance y no en absoluto.** Mientras haya algo en
> "Pendientes", `guard-completado` deniega **marcar cualquier REQ como `completado`** —la
> transición del campo `Estado:` de ese REQ al valor `completado`—. Y sus tres fronteras:
> **no** impide **implementar** ni **probar**, así que el trabajo que **no dependa** de la
> decisión, esté **autorizado** y esté **suficientemente definido** continúa; **no es** ninguna
> de las aprobaciones humanas normativas de `AGENTS.md` §6, y **vaciar la cola no concede
> ninguna**; y **no absorbe** ninguna otra restricción normativa —el orden de fases, el veto de
> seguridad, el tope de vueltas dev↔QA—, que bloquean por su propia regla. Por eso **cada
> entrada declara qué trabajo sigue**, o que **ninguno sigue** y el proyecto espera.
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
> regla vive UNA vez en el código del arnés y la usan por igual la puerta de cierre
> (`guard-completado`), el bloque derivado de `docs/ESTADO.md` y `tools/arnes-lectura.sh`:
> **el número que lees es exactamente el que bloquea**. Y si la cola no se puede leer entera
> —un byte NUL, un archivo sin permiso—, la puerta DENIEGA y el bloque derivado dice
> `sin datos`: nunca 0.
>
> El ejemplo vive AQUÍ, fuera de la cola, y a propósito: un ejemplo dentro de la sección se
> cuenta como una pendiente real e impide la acción de clase «cerrar» —**marcar cualquier REQ
> como `completado`**, la transición de su campo `Estado:` a ese valor—, porque la regla que lo
> impide, `guard-completado`, no distingue un ejemplo de una pendiente.

## Pendientes


### D1 · Publicar la versión 1.0 del informe mensual a los clientes
- **Fecha:** 2026-09-20 · **Quién la pide:** coordinadora
- **Acción que impide:** publicar (enviar el informe a los clientes). No impide implementar ni probar.
- **Parte de la entrega afectada:** la entrega del informe al cliente, no el código.
- **Evidencia:** el propietario pidió revisar el texto de la carta de acompañamiento antes del primer envío.
- **Qué la resuelve:** aprobación del propietario del texto de la carta.
- **Trabajo que sigue mientras tanto:** la corrección de `REQ-004` (separador de la lista de clientes) y sus pruebas.

### D2 · REQ-005 — ¿el importe total del encabezado va con IVA o sin IVA?
- **Fecha:** 2026-09-21 · **Quién la pide:** coordinadora
- **Contexto:** `requirements/REQ-005.md` está en `pendiente` con su `CA-02` sin escribir, a la espera de una decisión **de negocio** (no del analista). Estaba anotada sólo dentro del REQ, en «Preguntas abiertas», y no en esta cola: por eso se declara aquí, con su forma (`AGENTS.md` §6, regla 4).
- **Pregunta:** el importe total que muestra el encabezado del informe mensual, ¿se calcula **con IVA incluido** o **sin IVA**?
- **Opciones y consecuencia de cada una:**
  - **A — Sin IVA.** Contabilidad cuadra directamente contra el libro. Consecuencia: el cliente recibe un informe cuyo total **no coincide** con lo que se le cobra, y habrá que decirlo en el propio informe.
  - **B — Con IVA.** El total coincide con lo que el cliente paga. Consecuencia: contabilidad tiene que descontar el IVA a mano para cuadrar con el libro.
  - **C — Ambos importes, etiquetados.** Consecuencia: ninguna de las dos partes hace cuentas aparte; el encabezado crece y `CA-01` (dos decimales + símbolo de moneda) pasa a aplicarse a dos cifras, lo que es un cambio de alcance de REQ-005.
- **Recomendación de la coordinadora:** **C**. El principio rector de este proyecto es «cobrar lo decidido, ni más ni menos», y las opciones A y B dejan a una de las dos partes recalculando a mano una cifra de dinero — que es exactamente donde se producen las diferencias de cobro. Si se prefiere no ampliar REQ-005, la siguiente es **B**, porque el informe es un documento que **recibe el cliente**.
- **Acción que impide:** implementar y probar REQ-005 (su `CA-02` no se puede escribir). **No** impide el trabajo de REQ-004.
- **Parte de la entrega afectada:** REQ-005 completo (versión destino 1.1.0).
- **Evidencia:** `requirements/REQ-005.md`, sección «Preguntas abiertas / conflictos».
- **Qué la resuelve:** la elección del propietario entre A, B y C.
- **Trabajo que sigue mientras tanto:** la corrección de `REQ-004` y sus pruebas (misma nota que D1).

### D3 · REQ-004 / P-01 — frontera del conjunto «nombre vacío o nulo»
- **Fecha:** 2026-09-21 · **Quién la pide:** analista-requerimientos (escalada por la coordinadora)
- **Contexto:** `CA-02` de REQ-004 contrata hoy la omisión de la **cadena vacía** (`""`) y del **valor nulo** (`null`). No está decidido qué pasa con una cadena de **sólo espacios** (`"   "`), con `undefined` o con valores no textuales. Decidirlo cambia el alcance contratado, así que el analista lo escaló en vez de decidirlo.
- **Pregunta:** ¿el informe omite también esos casos, o el conjunto se queda exactamente en `""` y `null`?
- **Opciones y consecuencia de cada una:**
  - **A — Ampliar:** se omite todo nombre que quede vacío tras recortar espacios, y `undefined` se trata como nulo. Consecuencia: el encabezado nunca muestra huecos; amplía el alcance de REQ-004, exige entrada de Historial y pruebas adicionales (otra vuelta dev↔QA).
  - **B — Dejarlo como está:** sólo `""` y `null`. Consecuencia: un nombre de sólo espacios llega al informe **que recibe el cliente** como un hueco visible entre dos separadores.
- **Recomendación de la coordinadora:** **A**, por el mismo motivo que la clasificó como crítica: es un documento que ve el cliente y el hueco es visible.
- **Acción que impide:** ninguna, hoy. **No** impide implementar ni probar el núcleo `CA-01`…`CA-04`, que está en curso.
- **Parte de la entrega afectada:** sólo el borde de `CA-02`.
- **Evidencia:** `requirements/REQ-004.md`, «Preguntas abiertas / conflictos», P-01.
- **Qué la resuelve:** la elección del propietario entre A y B; si es A, vuelve al analista para escribirlo en `CA-02`.
- **Trabajo que sigue mientras tanto:** todo el ciclo de REQ-004 sobre el núcleo contratado.

### D4 · REQ-004 / P-02 — qué hace `listaClientes` si la entrada no es una lista
- **Fecha:** 2026-09-21 · **Quién la pide:** analista-requerimientos (escalada por la coordinadora)
- **Contexto:** no está contratado qué debe ocurrir si `nombres` es `null`, `undefined` o no es un arreglo. Hoy el código lanzaría `TypeError`, que es un comportamiento **no decidido por nadie**.
- **Pregunta:** ¿devolver cadena vacía, o fallar con un error explícito?
- **Opciones y consecuencia de cada una:**
  - **A — Cadena vacía.** Consecuencia: el informe sale **sin clientes** y con aspecto correcto; un fallo de integración se publica como un informe vacío.
  - **B — Error explícito y documentado.** Consecuencia: el informe no se genera y alguien tiene que mirar; ningún cliente recibe un encabezado silenciosamente incompleto.
- **Recomendación de la coordinadora:** **B**. El principio rector es «cobrar lo decidido, ni más ni menos»: un informe vacío por un fallo silencioso es peor que un fallo visible.
- **Acción que impide:** ninguna, hoy. QA **no** debe tratar este caso como criterio de aceptación hasta que se decida.
- **Parte de la entrega afectada:** ninguna del núcleo contratado.
- **Evidencia:** `requirements/REQ-004.md`, «Preguntas abiertas / conflictos», P-02.
- **Qué la resuelve:** la elección del propietario entre A y B; si se decide, vuelve al analista para contratarlo.
- **Trabajo que sigue mientras tanto:** todo el ciclo de REQ-004 sobre el núcleo contratado.

### D5 · REQ-001 — el código acepta el 29 de febrero y el criterio dice que se rechaza siempre
- **Fecha:** 2026-09-21 · **Quién la pide:** coordinadora
- **Contexto:** hallazgo **independiente**, detectado de paso al revisar el árbol. `REQ-001` está `completado` y su `CA-02` dice: «El 29 de febrero se rechaza siempre, porque no se consideran años bisiestos». `src/fecha.js` implementa `esBisiesto` correctamente y `diasDelMes(2, 2024)` devuelve **29**: el 29 de febrero se **acepta** en años bisiestos. El requerimiento dice algo **falso** sobre lo construido → deriva de clase `contrato` (`requirements/README.md`).
- **Pregunta:** ¿cuál de los dos manda, el código o el criterio?
- **Opciones y consecuencia de cada una:**
  - **A — Manda el código:** se corrige `CA-02` de REQ-001 para decir que los años bisiestos **sí** se consideran. Consecuencia: reabre REQ-001 (`AGENTS.md` §9, REGLA DE ESTADO) y lo hace re-recorrer su ciclo; el comportamiento de facturación **no cambia**.
  - **B — Manda el criterio:** se cambia `src/fecha.js` para rechazar siempre el 29 de febrero. Consecuencia: **no se podrán emitir facturas con fecha de corte 29/2** en años bisiestos — efecto directo sobre el cobro, y por tanto `critico` en este proyecto.
- **Recomendación de la coordinadora:** **A**. El código hace lo correcto de calendario; lo que envejeció mal es la frase del criterio. **B** tiene consecuencia sobre dinero y necesitaría justificarse por sí sola.
- **Acción que impide:** implementar y probar **REQ-001**; no impide nada de REQ-004.
- **Parte de la entrega afectada:** ninguna de la entrega en curso. **Queda fuera** de ella a propósito: registrar no autoriza reparar (`AGENTS.md` §6).
- **Evidencia:** `requirements/REQ-001.md` `CA-02` (línea 18) frente a `src/fecha.js` líneas 2–3.
- **Qué la resuelve:** la elección del propietario entre A y B; después, comisión al `analista-requerimientos` (opción A) o al `desarrollador` (opción B).
- **Responsable del registro mientras tanto:** coordinadora. **No** se ha editado `REQ-001` para anotar el hallazgo en su cabecera: está `completado`, y tocarlo es reabrirlo, que es exactamente la decisión que se pregunta aquí.
- **Trabajo que sigue mientras tanto:** todo el ciclo de REQ-004.

### D6 · REQ-004 — ¿quién recibe el informe mensual, y qué nombres de clientes puede ver cada destinatario?
- **Fecha:** 2026-09-21 · **Quién la pide:** auditor-seguridad (hallazgo `SEC-002`, `usuario/dinero`)
- **Contexto:** `listaClientes` construye una línea con **varios** nombres de cliente y esa línea se publica en el encabezado del informe mensual; `D1` contempla enviar ese informe **a los clientes**. Ningún documento del proyecto dice si un informe corresponde a **un** cliente, a **varios** o a un destinatario **interno**. Si un informe que lista N clientes se entrega a cada uno de ellos, cada cliente recibe los **nombres de los demás**: datos personales de terceros y la relación comercial que los acompaña. `AGENTS.md` §6 declara crítico en este proyecto «todo lo que toque dinero o **datos de clientes**», y este REQ fue reclasificado a `critico` por ese motivo exacto.
- **Pregunta:** ¿cuál es el destinatario de un informe mensual y qué clientes puede contener su encabezado?
- **Opciones y consecuencia de cada una:**
  - **A — Un informe por cliente.** El encabezado lista sólo al destinatario (la lista queda casi siempre en un nombre). Consecuencia: ningún cliente ve nombres de otros; CA-01…CA-04 siguen siendo correctos tal cual, pero el REQ debe **declarar** la regla para que no vuelva a quedar implícita.
  - **B — Informe agregado, sólo para uso interno.** El documento con varios clientes no sale de la empresa. Consecuencia: desaparece el riesgo de divulgación, y `D1` («publicar a los clientes») pasa a referirse a otro artefacto que habrá que definir.
  - **C — Informe agregado que sí reciben los clientes.** Consecuencia: es una **divulgación deliberada** de nombres de terceros; exige que el propietario declare su base para hacerlo y que quede escrito en `docs/seguridad/gobernanza-datos.md`; el auditor no la avala por defecto.
- **Recomendación del auditor:** **A**, y si el negocio necesita la vista agregada, **B** para ella. **C** sólo con una declaración expresa del propietario, porque convierte un informe de facturación en una lista de clientes compartida.
- **Acción que impide:** **publicar** el informe mensual a los clientes (junto con el veto de seguridad de REQ-004) y **cerrar** REQ-004. **No** impide implementar ni probar.
- **Parte de la entrega afectada:** la línea de clientes del encabezado (versión destino 1.0.0) y su publicación.
- **Evidencia:** `docs/seguridad/registro-seguridad.md` §`SEC-002`; `requirements/REQ-004.md` (Historia y criterios, que no mencionan destinatario); `PENDING_APPROVAL.md` `D1`.
- **Qué la resuelve:** la elección del propietario entre A, B y C; después, comisión al `analista-requerimientos` para escribirlo como **NFR + criterio** (write-back de `AGENTS.md` §9) y actualización de `docs/seguridad/gobernanza-datos.md`.
- **Trabajo que sigue mientras tanto:** el remedio de `SEC-001` (codificación/validación de la salida de `listaClientes`), que es independiente de esta decisión y puede contratarse ya.

### D7 · ¿Se revisa la clasificación de los REQ ya cerrados que tocan dinero (REQ-002, REQ-001)?
- **Fecha:** 2026-09-21 · **Quién la pide:** auditor-seguridad (hallazgo `SEC-004`, `instrumento`)
- **Contexto:** `REQ-004` estuvo `completado` con `QA: aprobado` sobre código que no cumplía **ninguno** de sus criterios y con una cabecera (`Sensible a seguridad: no` · `Rigor: estandar` · `Seguridad: n/a`) que prometía menos revisión de la que su efecto exigía. La misma clasificación sigue hoy en REQ cerrados que tocan dinero: **`REQ-002` — «Comisión por factura»** (`src/tarifa.js`, el porcentaje que se cobra) y **`REQ-001` — «Validación de la fecha de corte»**, ambos `completado` · `Sensible a seguridad: no` · `Rigor: estandar` · `Seguridad: n/a`, cuando `AGENTS.md` §6 declara crítico «todo lo que toque dinero o datos de clientes».
- **Pregunta:** ¿se reabren esos REQ para reclasificarlos y auditarlos, o se acepta el riesgo declarándolo?
- **Opciones y consecuencia de cada una:**
  - **A — Reclasificar y auditar ahora.** El `auditor-seguridad` sube el rigor de REQ-002 (y revisa REQ-001), lo que **los reabre** (`AGENTS.md`: subir el rigor de un REQ cerrado lo reabre) y les hace re-recorrer su ciclo. Consecuencia: coste de dos ciclos; a cambio, el código que calcula lo que se cobra queda auditado.
  - **B — Aceptar el riesgo por ahora, con fecha.** Consecuencia: queda escrito quién lo acepta y hasta cuándo; el cálculo de la comisión sigue sin haber pasado ninguna revisión de seguridad. `D5` ya muestra qué clase de defecto vive en esa zona.
- **Recomendación del auditor:** **A** para `REQ-002` (toca dinero de forma directa y su módulo es trivial de auditar) y tratarlo junto con `D5` para `REQ-001`, que ya está en cola por otra causa.
- **Acción que impide:** ninguna hoy. **No** impide nada de REQ-004 ni de esta entrega; se registra con dueño y **queda fuera** de ella (`AGENTS.md` §6: registrar no autoriza reparar).
- **Parte de la entrega afectada:** ninguna.
- **Evidencia:** `docs/seguridad/registro-seguridad.md` §`SEC-004`; cabeceras de `requirements/REQ-001.md` y `requirements/REQ-002.md`; `AGENTS.md` §6, «Qué es crítico EN ESTE PROYECTO».
- **Qué la resuelve:** la elección del propietario entre A y B. La facultad de **subir el rigor** es del `auditor-seguridad` y no caduca: si no hay decisión, la ejercerá en una comisión propia sobre esos REQ.
- **Trabajo que sigue mientras tanto:** todo el trabajo de REQ-004.

## Resueltas
<!-- Mover aquí con: decisión tomada, quién, fecha. No borrar (histórico). -->
