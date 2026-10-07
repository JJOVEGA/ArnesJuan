# PENDING_APPROVAL — ArnesJuan

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
> regla vive UNA vez en el código (`arnes_cola_pendientes`, `hooks/lib.sh`) y la usan por
> igual la puerta de cierre (`guard-completado`), el bloque derivado de `docs/ESTADO.md` y
> `tools/arnes-lectura.sh`: el número que se lee es exactamente el que bloquea. Y si la
> cola no se puede leer entera —un byte NUL, un archivo sin permiso—, la puerta DENIEGA y
> el bloque derivado dice `sin datos`: nunca 0.
>
> El ejemplo vive AQUÍ, fuera de la cola, y a propósito: un ejemplo dentro de la sección se
> cuenta como una pendiente real e impide la acción de clase «cerrar» —**marcar cualquier REQ
> como `completado`**, la transición de su campo `Estado:` a ese valor—, porque la regla que lo
> impide, `guard-completado`, no distingue un ejemplo de una pendiente.
>
> **Autorizaciones por fases.** Una autorización del propietario se escribe con la plantilla
> `templates/autorizacion.md` —sus cuatro bloques: plan autorizado, lo que decide la coordinadora
> sola, cuándo parar y preguntar, y qué hacer si la sesión se corta— y se registra literal en
> "Resueltas", citada con `> `: un encabezado `## ` sin citar cerraría la sección en la que cae. En
> este proyecto la llevan todas desde la décima autorización del propietario (2026-10-03, en
> "Resueltas").

## Pendientes


### [2026-10-07] (coordinadora) — P-136-U: la pasada de SEC-132 (a) (`cd63066`) introduce QA-007-15 (`contrato`, media): una gate roja puede escribir «0» en el canal del veredicto y **el REQ se cierra**; más QA-007-16 (stderr retenido) y QA-007-17 (corte superlineal). ¿Se revierte a `c5bf6d4` o se intenta otra pasada?

**Contexto.** Re-verificación acotada de QA sobre `cd63066` (`docs/qa/REQ-007.md`, «SEC-132 (a): re-verificación acotada»; evidencia `cand-1.36.0/sec115-118/qa5/`, `26f6131`). **Conforme:** los cuatro casos de P-136-T pasan (cuatro gates de 20 s y una colgada → `deny` a los 30,2 s; 0 huérfanos; dos cierres a la vez no se interfieren); frontera 29 s pasa / 31 s se corta; fail-before de la gate colgada acreditado en `c5bf6d4` y v1.35.0 (sin decisión a los 60 s; en v1.35.0 el REQ queda cerrado); banco 2306/1/13 (INS-136-1); inventario sin movimientos; +0 procesos; E1 igual; versión 1.36.0 con `jq -e .` rc 0.

**Los tres hallazgos, todos introducidos por `cd63066`:**
- **QA-007-15 (`contrato`, media) — fail-open en la puerta de cierre.** El veredicto de la gate se lee de la tubería que la propia gate hereda (`guard-completado.sh:964`). Una gate roja con `echo 0 >&3; false`, o con `trap "echo 0" EXIT; false`, sale **sin decisión y el REQ queda `completado`**; `c5bf6d4` y v1.35.0 deniegan. Y una gate verde con `exec true`, o con su propia trampa `EXIT`, recibe `deny` con un motivo falso («falló la quality gate»). Son movimientos en las dos direcciones que CA-69 p. 3 no declara.
- **QA-007-16 (`contrato`, baja; efecto en el cliente sin medir):** lo que sobrevive a una gate (también a una que pasa, con un bucle en segundo plano) mantiene abierto el **stderr** del hook después de que decide: en `c5bf6d4` cierra a los 108 ms, en el candidato sólo cerró al matar los procesos a los 75 s. Si el cliente espera a que cierre stderr, el `deny` no llega.
- **QA-007-17 (`contrato`, baja):** `arnes_corta_gate` crece más que linealmente con el ancho del árbol (el tope 4096 limita las vueltas, no la cola): 9 000 descendientes → `deny` a los 50,9 s; 14 000 → sin decisión a los 60 s.

**Opciones.**
- **(A) Revertir el código de `cd63066`** (vuelta a `c5bf6d4`, que tiene QA favorable y R-056 sin veto), conservar la versión `b43d7ea`, y **SEC-132 (a) queda como límite declarado**, junto con (b), en F-136-22 para 1.37, con las tres lecciones de diseño escritas: el canal del veredicto no puede ser escribible por la gate (subshell anidado con el descriptor cerrado); el corte tiene que ser lineal (grupo de procesos, no recorrido del árbol); y la salida de la gate no puede retener el stderr del hook. QA-007-15/16/17 se cierran por reversión. **Consecuencia:** 1.36.0 publica SEC-115 mitigado en sus tres vías medidas y declara la de las gates (preexistente: v1.35.0 también moría a los 60 s, y además **cerraba el REQ** sin decisión, que es peor que lo que publica el candidato). Coste: la reversión del desarrollador (minutos) y una comprobación de QA de que `hooks/` = `c5bf6d4`.
- **(B) Otra pasada acotada** (sería la sexta vuelta del paso 6), con las tres correcciones a la vez y re-verificación completa de QA y seguridad. **Consecuencia:** ≥ 1,5–2 h; el mecanismo necesita diseño (es exactamente el caso de «una mejora se propone antes de implementarse»), y cada pasada de esta serie ha abierto algo nuevo al atacar lo anterior.
- **(C) Publicar con QA-007-15 declarado:** no es una opción: es un fail-open en la puerta de cierre introducido por la ventana.

**Recomendación de la coordinadora: (A).** Un fail-open en `guard-completado` es el defecto más caro que este arnés puede tener, y lo introdujo la pasada. La vía de las gates era preexistente y en v1.35.0 era peor; declararla con sus lecciones es honesto y cabe en las notas. La sexta vuelta sobre el mismo paso contradice «calidad proporcional: sin cadena interminable».

**Decisión propuesta, lista para adoptar:** «P-136-U: (A). Se revierte el código de `cd63066` (hooks y banco vuelven a `c5bf6d4`; se conservan el registro, la versión `b43d7ea` y la evidencia como historia); QA comprueba que `hooks/` es byte a byte `c5bf6d4`. SEC-132 (a) queda como límite declarado con (b) en F-136-22, para 1.37, con las tres lecciones de diseño escritas y la nota de que v1.35.0 cerraba el REQ sin decisión en ese caso. QA-007-15, 16 y 17 se cierran por reversión. El analista lo escribe en CA-68, CA-69 p. 3, `AGENTS.md` §13 y la guía. Nada más entra; contadores sin reiniciar.»

**Qué trabajo sigue mientras no se decida:** nada del cierre que dependa del código. El borrador de notas espera.

**Espera:** elección del propietario.


## Resueltas

### RESUELTA (propietario, 2026-10-07) — **P-136-T: (B)** — la gate en curso se acota al tiempo que queda del plazo; cambio de compatibilidad declarado; caso de banco con las dos formas

**Texto del propietario, literal** (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisión propuesta, lista para adoptar: «P-136-T: (B). El plazo se comprueba entre gates y la gate en curso se acota al tiempo que queda del plazo: un cierre cuyas gates agotan el plazo se deniega por plazo con motivo propio, antes de los 40 s, incluida una gate colgada. Cambio de compatibilidad declarado: una gate que no termine dentro del plazo se interrumpe y el cierre se deniega. El caso de banco cubre las dos formas: cuatro gates de 20 s y una gate colgada. Nada más entra.»

**Lo que añade la coordinadora:** el desarrollador añade la forma «gate colgada» al caso de banco dentro de su tope; el analista cierra la pregunta abierta de REQ-007 y escribe la propiedad y el cambio de compatibilidad en CA-68, CA-69 p. 3, `AGENTS.md` §13 (ya autorizado) y la guía. La cola queda vacía.

### RESUELTA (propietario, 2026-10-07; entrada de arriba) — [2026-10-07] (coordinadora) — P-136-T: SEC-132 (a) — ¿«plazo comprobado entre gates» (literal de P-136-S) o «la gate en curso se acota al tiempo que queda del plazo» (lo que el código construye)? Cambia el límite declarado y el alcance del cambio de compatibilidad

**Contexto.** P-136-S (1) (A) dice «plazo comprobado entre gates». El encargo de la coordinadora al desarrollador añadió «y, si cabe sin procesos, acota la gate en curso al tiempo que quede del plazo»: eso fue ampliar la letra del propietario, y aquí se corrige. El analista, al escribir CA-68, lo vio y lo dejó como pregunta abierta en REQ-007 («SEC-132 (a): la gate en curso y el techo de 40 s»), sin recomendación.
- **(A) Literal: el plazo se comprueba entre gates.** No interrumpe la gate en curso. Con cuatro gates de 20 s, el `deny` llega hacia los 40 s, **justo en el techo** de respuesta; una sola gate que cuelgue deja al hook **sin decisión** a los 60 s (queda como límite declarado: «el plazo no alcanza a una gate en curso»). Cambio de compatibilidad: sólo los cierres cuyas gates **en conjunto** pasen del plazo.
- **(B) La gate en curso se acota al tiempo que queda del plazo** (lo que el código sin comitear hace: espera con `read -t` y corta con `kill`). Garantiza la decisión antes de los 40 s en todos los casos, incluida una gate colgada. Cambio de compatibilidad mayor: **una sola gate legítima de más de ~30 s**, que en `c5bf6d4` y en v1.35.0 pasa, pasa a `deny` por plazo (en el cliente, de todos modos, un hook de más de 60 s muere sin decisión).
- **Coste:** (B) ya está construido y es lo que QA mediría; (A) exige quitar la interrupción.

**Recomendación de la coordinadora: (B).** La promesa del paso 6 es «el hook siempre emite decisión», y una gate colgada es el caso que (A) no cubre. El plazo propio de 30 s ya es la cifra que decidiste en P-136-C; que las gates lo respeten en conjunto es coherente con ella. El precio es declarar que una gate de más de ~30 s no cabe, y hoy tampoco cabía: la mataba el cliente a los 60 s sin decir nada.

**Decisión propuesta, lista para adoptar:** «P-136-T: (B). El plazo se comprueba entre gates y la gate en curso se acota al tiempo que queda del plazo: un cierre cuyas gates agotan el plazo se deniega por plazo con motivo propio, antes de los 40 s, incluida una gate colgada. Cambio de compatibilidad declarado: una gate que no termine dentro del plazo se interrumpe y el cierre se deniega (en v1.35.0 el cliente mataba el hook a los 60 s sin decisión). El caso de banco cubre las dos formas: cuatro gates de 20 s y una gate colgada. Nada más entra.»

**Qué trabajo sigue mientras no se decida:** el desarrollador termina y comitea su pasada y la versión; QA **espera** a esta decisión para saber qué propiedad valida. El write-back de `AGENTS.md` §13 sigue, con la frase de SEC-132 (a) marcada «sin validar».

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-07) — **P-136-S: (1) (A), (2) (A) y (3)** — adoptada la decisión propuesta, literal; autoriza el write-back de `AGENTS.md` §13, la versión 1.36.0 en los dos archivos de distribución y el push de la candidata

**Texto del propietario, literal** (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisión propuesta, lista para adoptar: «P-136-S: (1) (A): se repara SEC-132 (a) en una pasada acotada con tope de una hora (plazo comprobado entre gates, caso de banco con gates lentas, cambio de compatibilidad declarado, re-verificación acotada de QA y determinación corta de seguridad); SEC-132 (b) límite declarado, ficha 1.37. (2) (A): SEC-131 límite declarado, ficha F-136-21 con F-136-20. (3) autorizo el write-back de AGENTS.md §13 y su plantilla por el analista, la subida de versión a 1.36.0 en los dos archivos de distribución (arnes_version se conserva en 1.33.0), y el push de la candidata al terminar; el PR sale de borrador cuando el CI esté en verde. Fusión, tag y publicación los decido yo con las notas finales delante. Nada más entra; contadores sin reiniciar.»

**Lo que añade la coordinadora:** en paralelo sobre archivos disjuntos, el `desarrollador` repara SEC-132 (a) con tope de una hora y sube la versión en `.claude-plugin/plugin.json` y `marketplace.json` (archivos protegidos), y el `analista-requerimientos` escribe los límites en CA-68, `AGENTS.md` §13 y `templates/AGENTS.md.tpl`. Fichas F-136-21 (SEC-131, con F-136-20) y F-136-22 (SEC-132 (b)) en `docs/PENDIENTES.md`. Después: re-verificación acotada de QA, determinación corta de seguridad, notas finales, push, CI y PR fuera de borrador. La cola queda vacía.

### RESUELTA (propietario, 2026-10-07; entrada de arriba) — [2026-10-07] (coordinadora) — P-136-S: con el paso 6 validado (QA favorable, R-056 sin veto), seguridad abrió SEC-132 (`contrato`, media) y SEC-131 (`contrato`, baja), los dos preexistentes; y el cierre (paso 7) necesita tres autorizaciones tuyas. ¿Qué entra antes de publicar 1.36.0?

**Contexto.** R-056 (`docs/seguridad/registro-seguridad.md`; evidencia `cand-1.36.0/sec115-118/seg-R056/`, `4bd3464`) sobre `c5bf6d4`: en 3 162 combinaciones de entorno más la matriz POSIX, ningún `deny` pasa a `allow` ni a «sin decisión»; todos los movimientos van hacia `deny` y están declarados. **SEC-115, SEC-118 y SEC-129 → `mitigado` en el candidato.** SEC-130 → `instrumento`, F-136-12 (texto corregido). Un control del proveedor detuvo una sonda del auditor (O-56-2); sin reintentar.

**(1) SEC-132 — `contrato`, media, preexistente: el plazo propio no alcanza dos recorridos.**
- **(a) Las quality gates en serie:** el plazo se comprueba **antes** del bucle (`guard-completado.sh:946`), no dentro. Cuatro gates de 20 s → sin decisión a los 60 s. **Alcanzable con una configuración normal** del manifiesto. La reparación es comprobar el plazo entre gates (una línea) y denegar si se agota; es un cambio de compatibilidad (un proyecto con gates lentas verá `deny` por plazo donde antes veía «sin decisión»).
- **(b) `Hallazgos abiertos:` repetida en la cabecera en disco** crece más que linealmente (`lib.sh:3376`, situado por lectura): 20 000 líneas cortas → `deny` a los 48,5 s; 20 000 de 66 caracteres → sin decisión. Un techo sobre el disco de > 660 KB no lo cubriría.
- **Opciones:** **(A)** reparar **(a)** ahora, en una pasada acotada y con tope (una línea, un caso de banco con gates lentas simuladas, re-verificación acotada; cambio de compatibilidad declarado), y **(b)** como límite declarado con ficha para 1.37; **(B)** los dos como límites declarados, ficha para 1.37; **(C)** reparar los dos (b exige otro techo o una normalización lineal: no cabe sin diseño).
- **Recomendación: (A).** (a) contradice la promesa central del paso 6 («el hook siempre emite decisión») con una configuración que cualquier proyecto puede tener; (b) exige diseño.

**(2) SEC-131 — `contrato`, baja, preexistente: estado heredado sin neutralizar ni declarar.** (i) una función importada con el nombre de la orden de una gate hace pasar una gate roja (`guard-completado.sh:953`, el único `eval` del hook); (ii) `ulimit -n` 4 o 5 → el preludio falla y se lee como inerte; (iii) `PATH` (y `#!/usr/bin/env bash` lo resuelve antes de la primera línea). El auditor recomienda para 1.37 declarar la **frontera de confianza del entorno del host** por propiedad y resolver F-136-20 con una **lista blanca** del entorno en `hooks.json`, no con una lista negra.
- **Opciones:** **(A)** límite declarado ahora, ficha F-136-21 para 1.37 junto con F-136-20 (misma frontera); **(B)** reparar (ii) ahora (que el fallo del preludio deniegue en vez de leerse inerte) y declarar (i) y (iii).
- **Recomendación: (A).** Es la misma frontera que ya declaraste en F-136-20; partirla en reparaciones sueltas no la cierra.

**(3) Autorizaciones del cierre (paso 7) que el plan reserva a ti:**
- **(a) `AGENTS.md` §13 y `templates/AGENTS.md.tpl`:** las filas que declaran SEC-115 y SEC-118 como limitaciones tienen que decir lo que hoy es cierto (`mitigado`, con los residuales de R-056). El plan dice «No AGENTS.md», así que necesita tu autorización expresa; lo escribe el analista.
- **(b) La subida de versión** a 1.36.0 en `.claude-plugin/plugin.json` y `marketplace.json` (archivos protegidos: el desarrollador), y `arnes_version` de `.arnes/config.json` **se conserva** en 1.33.0 como en 1.35.0 (es la migración del proyecto), salvo que digas otra cosa.
- **(c) Push** de la candidata para que el PR #60 tenga CI sobre la cabeza final, y después el PR fuera de borrador. Fusionar, etiquetar y publicar siguen siendo tuyos.

**Decisión propuesta, lista para adoptar:** «P-136-S: (1) (A): se repara SEC-132 (a) en una pasada acotada con tope de una hora (plazo comprobado entre gates, caso de banco con gates lentas, cambio de compatibilidad declarado, re-verificación acotada de QA y determinación corta de seguridad); SEC-132 (b) límite declarado, ficha 1.37. (2) (A): SEC-131 límite declarado, ficha F-136-21 con F-136-20 (frontera de confianza del entorno; lista blanca en `hooks.json` en 1.37). (3) autorizo el write-back de `AGENTS.md` §13 y su plantilla por el analista, la subida de versión a 1.36.0 en los dos archivos de distribución (`arnes_version` se conserva en 1.33.0), y el push de la candidata al terminar; el PR sale de borrador cuando el CI esté en verde. Fusión, tag y publicación los decido yo con las notas finales delante. Nada más entra; contadores sin reiniciar.»

**Qué trabajo sigue mientras no se decida:** el commit validado del paso 6 (hecho con esta entrada), el write-back de estado del analista (SEC-115/118/129 `mitigado`; F-136-20 (i) corregida con el `allow` explícito), las notas finales y la guía en lo que no depende de (1) y (3). Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-07) — **P-136-R: (A)** — adoptada la decisión propuesta, literal

**Texto del propietario, literal** (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisión propuesta, lista para adoptar: «P-136-R: (A). La lista estática cubre los builtins que el hook usa, regulares y especiales (return, exit, break, continue, set, shift, :), retirados en modo POSIX; caso de banco con return y break exportadas, decisión en < 5 s; re-verificación acotada de QA. BASH_FUNC_set%% en guardianes sueltos → F-136-20. Nada más entra; contadores sin reiniciar.»

**Lo que añade la coordinadora:** la línea la añade el `desarrollador` (sigue dentro del tope de P-136-Q: 18 minutos usados de 60); F-136-20 gana el `set` suplantado en guardianes sueltos; el analista corrige en CA-68 (ii) la letra «regulares» → «regulares y especiales». La cola queda vacía.

### RESUELTA (propietario, 2026-10-07; entrada de arriba) — [2026-10-07] (coordinadora) — P-136-R: QA-007-14 (`contrato`, baja): la lista estática de `entrada.sh` no retira los builtins **especiales** que el hook usa (`return`, `exit`, `break`, `continue`, `set`, `shift`, `:`); tras `set +o posix` vuelven a ser suplantables. Una línea lo repara. ¿Entra o es límite?

**Contexto.** Re-verificación acotada de QA sobre `39e6128` (`docs/qa/REQ-007.md`, «Paso 6: re-verificación de la pasada acotada de P-136-Q»; evidencia `cand-1.36.0/sec115-118/qa3/`, `84fbf80`). **QA-007-13 cerrado:** `builtin` da 0 diferencias en 567 combinaciones; `ls -la` sin decisión en 110 ms y `Write` con `deny` en 111 ms donde `03cbf5e` moría a los 60 s; sin dependencia de `/proc/self/environ`; matriz POSIX, bloque P, QA-007-10/12, T1–T3 y E1 sin cambio; banco 2301/0/13; inventario 2038/0/12; +0 procesos.

**QA-007-14.** P-136-Q dice «`unset -f` de una LISTA ESTÁTICA … (builtins **regulares** que el hook usa + externos que invoca)». El desarrollador siguió esa letra. Los builtins **especiales** (`return`, `exit`, `break`, `continue`, `set`, `shift`, `:`) quedaron fuera: el modo POSIX los protege sólo hasta el `set +o posix` del final del preludio, y después una función importada con ese nombre vuelve a suplantarlos. Medido por `guard.sh`:
- `BASH_FUNC_return%%`: `Write` a `src/a.ts`, `Bash` que escribe en `src/`, `git reset --hard` y completar un REQ salen **sin decisión** (rc 139);
- `BASH_FUNC_break%%`: el hook **no termina** (cortado a 10 s) y `git reset --hard` sale sin decisión;
- `BASH_FUNC_exit%%`: la decisión sale con rc 1, 2 o 139; `continue` con `exit 0`: sin decisión en `Bash`.
- Con esos 7 nombres difieren **156 de 315** combinaciones; en `03cbf5e` difieren 6 (las preexistentes de `set` en guardianes sueltos); en **v1.35.0, 200**. Es regresión frente a `03cbf5e` y mejora frente a lo publicado.
- **Reparación medida por QA fuera del hook (`qa3/14-`):** en modo POSIX, `unset -f return exit break continue set shift :` retira esas funciones; sin procesos. Una línea en la lista estática.
- **Resto preexistente:** `BASH_FUNC_set%%` en los guardianes ejecutados sueltos: ejecutan `set -uo pipefail` **antes** de cargar `entrada.sh` (`guard-codigo.sh:19`, `guard-git.sh:32`, `guard-completado.sh:18`); fuera del camino de producción (`hooks.json` sólo lanza `guard.sh`). F-136-20 no lo nombra.

**Opciones.**
- **(A) Completar la lista estática con los builtins especiales que el hook usa** (una línea; sigue siendo la técnica de P-136-Q, con la letra corregida: «builtins que el hook usa, regulares y especiales»), un caso de banco con `return` y `break` exportadas, y re-verificación acotada de QA. `BASH_FUNC_set%%` en guardianes sueltos → F-136-20 (preexistente; fuera del camino de producción). **Consecuencia:** ≈ 30–40 minutos; el candidato queda mejor que `03cbf5e` en todo lo medido.
- **(B) Límite declarado** (F-136-20 ampliada): una función importada con el nombre de un builtin especial deja al hook sin decisión o colgado. **Consecuencia:** se publica una regresión frente a `03cbf5e` (aunque mejora frente a v1.35.0), y CA-68 (ii) queda contradicho por su propio ejemplo.
- **(C) Volver a `03cbf5e`** (la limpieza por `/proc/self/environ`, que sí retiraba todo): recupera el cuelgue de 60 s con `builtin` suplantado. No.

**Recomendación de la coordinadora: (A).** Es la misma reparación que ya autorizaste, con la palabra «regulares» corregida: la lista tiene que cubrir los builtins que el hook usa, sean regulares o especiales. El coste es una línea y una re-verificación corta.

**Decisión propuesta, lista para adoptar:** «P-136-R: (A). La lista estática cubre los builtins que el hook usa, regulares y especiales (`return`, `exit`, `break`, `continue`, `set`, `shift`, `:`), retirados en modo POSIX; caso de banco con `return` y `break` exportadas, decisión en < 5 s; re-verificación acotada de QA. `BASH_FUNC_set%%` en guardianes sueltos → F-136-20. Nada más entra; contadores sin reiniciar.»

**Qué trabajo sigue mientras no se decida:** nada del paso 6 (seguridad espera a QA favorable).

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-07) — **P-136-Q: (A), con tope de una hora y acotada a QA-007-13**; lista estática de `unset -f`; caso de banco con `builtin` y `read` exportadas y decisión en < 5 s; F-136-20 como límite declarado

**Texto del propietario, literal** (mensaje del 2026-10-07 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-Q: (A), con tope de una hora y acotada a QA-007-13:
> - entrada.sh arranca con POSIXLY_CORRECT=y; `unset -f` de una LISTA ESTÁTICA
>   escrita en el archivo (builtins regulares que el hook usa + externos que
>   invoca), sin descubrir nombres con declare/compgen/read; bucle sin
>   órdenes suplantables o con tope; `set +o posix` al terminar el preludio.
> - Caso de banco: funciones `builtin` y `read` exportadas (la de `builtin`
>   devolviendo 0), orden inocua, decisión emitida en < 5 s.
> - Límites declarados (F-136-20, 1.37): `.`/`[` antes de entrada.sh,
>   errexit, y BASH_ENV si no está ya cubierto; resolución desde hooks.json.
> - Re-verificación de QA acotada; si no cabe en pocas líneas, (B). Nada más
>   entra; contadores sin reiniciar.
> PR-136-4 registrada; va con PR-136-1 a 3.

**Lo que añade la coordinadora:** la pasada la hace el `desarrollador` con tope de una hora de reloj; la re-verificación de QA se acota al bloque nuevo, a la regresión y a una regresión corta del preludio. F-136-20 en `docs/PENDIENTES.md`. La cola queda vacía.

### RESUELTA (propietario, 2026-10-07; entrada de arriba) — [2026-10-06] (coordinadora) — P-136-Q: QA-007-13 (`contrato`, baja): una función importada del entorno llamada `builtin` deja al hook sin decisión, y si devuelve 0 **toda llamada muere a los 60 s** (regresión de la pasada correctiva). No quedan pasadas en el plan. ¿Una pasada acotada más, o límite declarado?

**Contexto.** Re-verificación de QA de `03cbf5e` (`docs/qa/REQ-007.md`, «Paso 6: re-verificación de la pasada correctiva»; evidencia `cand-1.36.0/sec115-118/qa2/`, `6cf1ba0`). **Conforme:** QA-007-10, QA-007-11 (a) y QA-007-12 **cerrados** (393 casos con bytes no UTF-8 sin fallo; 38 930 combinaciones de variables sin diferencias; 7 272 con `localvar_inherit`); T1–T3 y la matriz POSIX en `deny`; E1 igual; inventario sólo con INS-136-2 y 2 (c); banco 2299/0/13; autoprueba 117/0; gates rc 0; +0 procesos. QA-007-08 reclasificado a `instrumento` (INS-136-4).

**QA-007-13.** CA-68 (ii) promete «la misma decisión que sin ese estado» para cualquier estado heredado, y cita las funciones importadas como ejemplo. Atacando la limpieza de `entrada.sh` con funciones importadas que llevan el nombre de 21 órdenes que usa el preludio (567 combinaciones por árbol):
- **`builtin` — REGRESIÓN de `03cbf5e`:** la limpieza protege sus órdenes con `builtin`, que **no** es un builtin especial y una función puede suplantarlo. Con `BASH_FUNC_builtin%%` exportada, todo lo que debería denegarse sale sin decisión; si esa función devuelve 0, el bucle `while IFS= builtin read …` sobre `/proc/self/environ` no avanza y **cualquier llamada tarda 60 100 ms y sale con rc 124**, incluso `ls -la` (107 ms en `8e11f87` y v1.35.0).
- **`.` y `[` — preexistentes:** `guard.sh` los ejecuta antes de cargar `entrada.sh`, así que ninguna limpieza interna llega a tiempo (sólo la orden de `hooks.json` podría).
- **`SHELLOPTS=errexit` — preexistente, falla hacia el lado cerrado:** deniega todo, también lo legítimo.
- **Dato medido por QA fuera del hook:** con `POSIXLY_CORRECT=y` activo, las funciones no pueden suplantar a los builtins **especiales** (`unset`, `set`, `.`, `eval`, `export`…), sin crear procesos; `builtin`, `shopt`, `printf`, `read` y `[` **no** son especiales.
- **Vector:** exige un entorno que exporte una función con ese nombre al proceso de Claude Code; quien puede hacerlo ya podía exportar `BASH_FUNC_jq%%` en v1.35.0 (sin decisión). Severidad baja según QA; la consecuencia nueva es la **disponibilidad** (60 s por llamada).

**Opciones.**
- **(A) Una pasada más, acotada y con tope**, que excede el plan: en `entrada.sh`, antes de cualquier otra orden, `POSIXLY_CORRECT=y` para que los builtins especiales no puedan ser suplantados, retirar con `unset -f` (especial) las funciones homónimas de todas las órdenes que la limpieza va a usar (`builtin`, `shopt`, `printf`, `read`, `[`…), y sólo después la limpieza actual y `set +o posix`; sin bucle que dependa de órdenes suplantables (o con tope de iteraciones). Caso de banco por `builtin` (sin decisión y la variante que cuelga, con `timeout`). `.` y `[` en `guard.sh` antes de `entrada.sh` → **límite declarado** (F-136-20: la frontera es la orden de `hooks.json`, 1.37). `errexit` → límite declarado del lado cerrado. Re-verificación de QA acotada al bloque nuevo y a la regresión. **Consecuencia:** ≈ 1 h más; el candidato no publica un cuelgue de 60 s nuevo. Si la reparación no cabe en unas pocas líneas, se para y se vuelve a (B).
- **(B) Límite declarado**, sin más pasadas: una función importada con el nombre de una orden del preludio (`builtin`, `.`, `[`) deja al hook sin decisión o colgado 60 s; ficha F-136-20 para 1.37 (`hooks.json`). **Consecuencia:** se publica una regresión de disponibilidad introducida en esta ventana, declarada; el contrato CA-68 (ii) tendría que acotar «funciones importadas» para no contradecirse.
- **(C) Revertir la parte de QA-007-11 (a)** (la limpieza de funciones importadas) y declararla límite, conservando QA-007-10 y QA-007-12. **Consecuencia:** vuelve `BASH_FUNC_jq%%` → sin decisión (que ya tenía v1.35.0) y desaparece el cuelgue; también es un cambio de código que QA tiene que volver a mirar, así que no ahorra la re-verificación.

**Recomendación de la coordinadora: (A), con tope de una hora.** Un cuelgue de 60 s por llamada es la clase de defecto que el paso 6 existe para eliminar («el hook siempre emite decisión»), y lo introdujo esta ventana; publicarlo como límite declarado contradice la promesa que estamos a punto de firmar. La técnica ya está medida por QA fuera del hook y es de pocas líneas. Si no cabe en el tope, (B).

**Decisión propuesta, lista para adoptar:** «P-136-Q: (A), con tope: una pasada acotada a QA-007-13 (`POSIXLY_CORRECT=y` al arrancar, `unset -f` de las homónimas de las órdenes del preludio, bucle sin órdenes suplantables o con tope, `set +o posix` después), con caso de banco y re-verificación de QA acotada; `.`/`[` antes de `entrada.sh` y `errexit` como límites declarados (F-136-20). Si no cabe en pocas líneas, (B). Nada más entra. Los contadores no se reinician.»

**Qué trabajo sigue mientras no se decida:** nada del paso 6 (seguridad espera a QA favorable). El borrador de las notas y la ficha F-136-20 se preparan.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-06) — **P-136-P: (1) (A) y (2) (A)** — adoptada la decisión propuesta, literal

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisión propuesta, lista para adoptar: «P-136-P: (1) (A): QA-007-08 es INS-136-4; F-136-8 se amplía a CA-09; REQ-017 no se reabre. (2) (A): la pasada correctiva repara QA-007-10, QA-007-12 y QA-007-11 (a); QA-007-11 (b) y QA-007-09 quedan como límites declarados con ficha para 1.37. Nada más entra.»

**Lo que añade la coordinadora:** INS-136-4, la ampliación de F-136-8, y las fichas F-136-18 (QA-007-09) y F-136-19 (QA-007-11 (b)) en `docs/PENDIENTES.md`. En paralelo y sobre archivos disjuntos: el desarrollador hace la **única pasada correctiva** del paso 6 (`hooks/`, banco, `docs/arnes/`) y el analista escribe los límites declarados y el cierre de QA-007-08 como instrumento (`requirements/`, guía). Después, QA re-verifica; seguridad (fase 4); commit validado; paso 7. La cola queda vacía.

### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-06] (coordinadora) — P-136-P: QA del paso 6 CON HALLAZGOS; (1) E2 dio 1 FAIL en 6 corridas de REQ-017 CA-09 (regla «afecta» → §9, decisión tuya); (2) alcance de la única pasada correctiva ante cinco hallazgos `contrato` más (QA-007-09 a QA-007-12)

**Contexto.** `docs/qa/REQ-007.md`, «Paso 6: validación de SEC-115, SEC-118, SEC-129 y QA-007-07»; evidencia `cand-1.36.0/sec115-118/qa/`, commit `e19b708`; código `8e11f87`. **Conforme:** sección 47 95/0 con fail-before (`78a2f33` y v1.35.0 36/59); SEC-118 con UTF-8 válido (motivos de 16 382–16 384 bytes; los avisos de 140 KB se emiten); SEC-115: T1–T3 en `deny` en 0,4–2,6 s, T2b en 0,2–0,4 s (v1.35.0: 32–38 s), el plazo actúa en una llamada real (REQ de 3 MB → `deny` a los 36,3 s); E1 sin cambio; E3 PASS; techos: fronteras reproducidas, nada cambia fuera de `requirements/`; matriz POSIX en `deny`; QA-007-07 reparado; R2 deniega `exit` inesperado y códigos no declarados; banco 2292/0/13; autoprueba 117/0; gates rc 0; +0 procesos; **INS-136-3** (la sección 24 no se reproduce en 15 corridas + inventario). **Cerrados por QA:** QA-007-07 y **QA-023-10** (en su medición, 35 corridas sobre `82ceb63`). **SEC-130: confirmado que R2 no lo cubre** (`ulimit -n 3` → cierre por `sed` sin decisión); sigue F-136-12.

**(1) QA-007-08 — E2 «afecta».** CA-69 p. 7 dice: un FAIL en E2 → parar y presentar con §9. El candidato dio **4 PASS, 1 SKIP por solape y 1 FAIL (corrida 4, 0,962×)**; v1.35.0, 5 PASS y 1 por solape. E1 (las tres entradas de la sonda a nivel de hook) **no muestra ningún cambio** de decisión ni de duración, así que la causa que la ficha preparada presuponía (un techo o el plazo) no aparece. La cifra 0,962× es **por debajo de 1**: el candidato salió más rápido que la referencia en esa corrida, no más lento. REQ-017 está `completado`.
- **(A) Registrarlo como instrumento (INS-136-4)** y ampliar F-136-8 a CA-09: la sonda 37/3 también decide sobre una banda que el ruido del anfitrión cruza (INS-136-1 y 2 ya lo documentan para CA-03 y CA-08 (ii)); E1 es la medida directa y no cambia. **Consecuencia:** REQ-017 no se reabre; la revisión del instrumento queda en 1.37 con F-136-8. Sin código.
- **(B) Reabrir REQ-017 por §9** (vuelve a `en-revisión` y re-recorre el ciclo). **Consecuencia:** un ciclo completo sobre un REQ cerrado, por una corrida de 6 con el candidato más rápido.
- **(C) Repetir E2 en anfitrión sano** (≥ 6 corridas, carga < 0,5 registrada), sin repetir hasta el verde: si vuelve a dar FAIL en la misma dirección, (A); si da FAIL con el candidato más lento, (B). **Consecuencia:** 20–30 minutos.

**(2) Los cinco hallazgos `contrato` y la única pasada correctiva del plan:**

| Id | Qué | Preexistente | Cabe en la pasada sin cambiar alcance |
|---|---|---|---|
| **QA-007-10** | `ARNES_CWD_VISTO` heredada del entorno cambia la decisión (barrido de 32 810 combinaciones; sólo ésa) | sí | **Sí:** es la propiedad (ii) de P-136-N; vaciarla al cargar y un caso |
| **QA-007-12** | con bytes no UTF-8 venidos del disco, el motivo emitido llega a 48 781 bytes (se acota antes de que `jq` sustituya cada byte por U+FFFD); la decisión se emite | no (lo introduce la fase 2) | **Sí:** acotar después de sanear; CA-67 lo exige |
| **QA-007-11 (a)** | estado del intérprete heredado: `FUNCNEST=1/2`, `BASH_COMPAT` 31–42, `compat*`, `keyword`, funciones importadas (`BASH_FUNC_jq%%`) dejan sin decisión o rompen el JSON | sí | **Sí:** neutralizables en `hooks/entrada.sh` (propiedad (ii)) |
| **QA-007-11 (b)** | `SHELLOPTS=noexec` u `onecmd`, y `xtrace` con `BASH_XTRACEFD=1`: no se pueden neutralizar desde dentro del hook; piden actuar en `hooks.json` o declarar la frontera | sí | **No:** decisión de alcance |
| **QA-007-09** | un `Edit` pequeño que cierra un REQ con **CRLF en disco** de ≥ 3,6 MB sale sin decisión a los 60 s (`guard-completado.sh:604`, superlineal y sin techo: el techo mide la entrada, no el disco); v1.35.0 falla desde 3 MB | sí | **No:** un techo sobre el documento en disco es otro cambio de compatibilidad (y `REQ-007.md` tiene 660 KB) |

- **(A) La pasada repara QA-007-10, QA-007-12 y QA-007-11 (a).** QA-007-11 (b) y QA-007-09 quedan como **límites declarados** con ficha para 1.37 (la frontera de `hooks.json`, y un techo sobre el disco o una normalización lineal del CRLF, propuestos antes de hacerse). **Consecuencia:** una pasada acotada y una re-verificación; 1.36.0 publica dos límites más, declarados en las notas, los dos preexistentes y peores en v1.35.0.
- **(B) La pasada repara también QA-007-09** con un techo sobre el tamaño del documento en disco para la vía CRLF (cifra por fijar, por encima de 660 KB). **Consecuencia:** otro movimiento `allow` → `deny` que el contrato tiene que declarar; alarga la pasada.
- **(C) Sin pasada:** todo como límite declarado. **Consecuencia:** se publica con QA-007-12 (introducido por esta ventana) y QA-007-10 abiertos.

**Recomendación de la coordinadora: (1) = (A); (2) = (A).**

**Decisión propuesta, lista para adoptar:** «P-136-P: (1) (A): QA-007-08 es INS-136-4; F-136-8 se amplía a CA-09; REQ-017 no se reabre. (2) (A): la pasada correctiva repara QA-007-10, QA-007-12 y QA-007-11 (a); QA-007-11 (b) y QA-007-09 quedan como límites declarados con ficha para 1.37. Nada más entra.»

**Qué trabajo sigue mientras no se decida:** el write-back de estado del analista (QA-007-07 construido en `8e11f87`; punteros de `lib.sh`; QA-023-10 cerrado), que no depende de esto. La pasada y seguridad esperan.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-06) — **P-136-O: (1) (A) y (2) (A); P-136-N: (A)** — adoptada la decisión propuesta por la coordinadora, literal

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisión propuesta, lista para adoptar: «P-136-O: (1) (A) y (2) (A). P-136-N: (A).»

**Texto adoptado** (el de la coordinadora en las fichas P-136-O y P-136-N, que el propietario hace suyo con esa respuesta):
- **P-136-O (1) (A):** los techos de tamaño (`ARNES_PIEZAS_MAX_BYTES` = 393 216 y `ARNES_EDIT_MAX_BUSQUEDA` = 2³²) quedan como **cambio de compatibilidad declarado**; el analista lo escribe en CA-68, CA-69 p. 3, la guía y las notas (consecuencia: un REQ de más de 393 216 bytes no se escribe entero de una vez, y un `Edit` con `old_string` de más de ~6,5 KB sobre un documento de ese tamaño se deniega: se parte la edición). **Ficha para adelgazar `REQ-007.md`** a `historial/` en 1.37.
- **P-136-O (2) (A):** QA observa el FAIL de la sección 24 en su propio inventario y en varias corridas de la sección en reposo; si lo reproduce, es hallazgo; si no, INS-136-3.
- **P-136-N (A):** QA-007-07 entra en el paso 6 con SEC-129, bajo la propiedad de CA-68 enunciada sobre el entorno heredado: ninguna decisión del hook depende de nada que herede del entorno (modo del intérprete, variables `ARNES_*`; `BASH_ENV` queda como ficha F-136-9). Caso de banco para cada variable. Nada más entra.

**Lo que añade la coordinadora:** en paralelo y sobre archivos disjuntos, el desarrollador repara QA-007-07 (`hooks/lib.sh`, banco, `docs/arnes/`) y el analista escribe el movimiento de los techos y la propiedad ampliada (`requirements/`, guía). Después QA (fase 3), seguridad (fase 4), commit validado y paso 7. La cola queda vacía.

### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-06] (coordinadora) — P-136-N: QA-007-07 (`contrato`, baja, preexistente): variables `ARNES_*_LISTO` heredadas del entorno dejan a las puertas sin decidir. ¿Entra en el paso 6 junto a SEC-129, o va a 1.37?

**Contexto.** Hallazgo nuevo de QA en el paso 5 (F-136-11 en `docs/PENDIENTES.md`). No lo introduce el paso 5: v1.35.0 se comporta igual. Es la misma familia que SEC-129 (`POSIXLY_CORRECT`): un estado heredado del entorno apaga las puertas sin ruido. La reparación es inicializar dos variables al cargar `lib.sh` (una línea; sin procesos). La propiedad que R-054 propone para CA-68 lo cubre si se enuncia sobre «el entorno heredado» y no sólo sobre «el modo del intérprete».

**Opciones.**
- **(A) Entra en el paso 6 (SEC-115/118), junto a SEC-129,** como parte de la misma propiedad: «ninguna decisión depende de nada heredado del entorno». El analista lo escribe en CA-68 con SEC-129; el desarrollador lo repara en la misma fase; QA y seguridad lo cubren con un caso de banco. **Consecuencia:** coste marginal (una línea y un caso); el paso 6 crece en una variable de la misma clase que ya trata.
- **(B) Ficha para 1.37.** **Consecuencia:** 1.36.0 se publica con un `contrato` abierto que una variable de entorno puede explotar, declarado en las notas; REQ-007 sigue sin poder cerrarse por él.

**Recomendación de la coordinadora: (A).** Sirve a «calidad proporcional» sin dañar «autonomía útil»: no abre ningún ciclo nuevo, va dentro del que ya existe para la misma clase de defecto.

**Decisión propuesta, lista para adoptar:** «P-136-N: (A). QA-007-07 entra en el paso 6 con SEC-129, bajo la propiedad de CA-68 enunciada sobre el entorno heredado: ninguna decisión del hook depende de nada que herede del entorno (modo del intérprete, variables `ARNES_*`, `BASH_ENV` queda como ficha F-136-9). Caso de banco para cada variable. Nada más entra.»

**Qué trabajo sigue mientras no se decida:** todo lo del paso 5 (write-back de QA-007-06, su cierre por QA, la determinación de seguridad y el commit validado), que no depende de esto. La apertura del paso 6 espera a esta decisión sólo en su alcance; su plan se redacta con las dos variantes.

**Espera:** elección del propietario.


### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-06] (coordinadora) — P-136-O: la fase 2 del paso 6 (`0efd3c2`) cumple el contrato, pero (1) sus techos de tamaño deniegan dos llamadas legítimas sobre `REQ-007.md` (660 KB) que v1.35.0 dejaba pasar, y (2) un FAIL no reproducido en el inventario, en un caso que ejecuta código del delta

**Contexto.** `docs/arnes/v1.36.0-sec115-118-fase2.md`; evidencia `cand-1.36.0/sec115-118/`, commit `65092c8`. **Conforme:** sección 47 93/0 (D y A con motivos de ≤ 16 384 bytes; T1–T3 en `deny` en 0,4–4,3 s; las 40 filas POSIX en `deny`); tope del motivo medido en 273 casos ASCII y multibyte; E1 sin cambio, E2 12/12 PASS, E3 PASS; inventario 2 (a) sólo con 2 (c), INS-136-2 y un nombre de caso que depende del PID; banco 2290/0/13; autoprueba 117/0; gates rc 0; +0 procesos. Técnica: el motivo va a `jq` por la entrada estándar y se acota a 16 384 bytes; plazo propio a 30 s (responde en ≤ 40); techos `ARNES_PIEZAS_MAX_BYTES` = 393 216 y `ARNES_EDIT_MAX_BUSQUEDA` = 2³²; `hooks/entrada.sh` nuevo con `unset POSIXLY_CORRECT; set +o posix` y una trampa de salida que emite `deny` fijo si el proceso termina sin juicio; R2 para códigos no declarados y puertas abandonadas. **SEC-130 no queda cubierto por R2** (su 0 es respuesta válida de su vocabulario): sigue como F-136-12, para 1.37.

**(1) Las llamadas legítimas que pasan a `deny`** (`65-`), todas sobre `REQ-007.md`, 660 431 bytes:

| Llamada | v1.35.0 | candidato |
|---|---|---|
| `Write` del archivo entero | sin decisión (allow), 11,5 s | `deny` por el techo de piezas (393 216 B) |
| `Edit` con `old_string` de 3 000–6 400 B | sin decisión | sin decisión |
| `Edit` con `old_string` de 7 000 o 12 000 B | sin decisión | `deny` por el presupuesto de búsqueda |

`REQ-021.md` (296 976 B) y `REQ-023.md` siguen igual. Subir el techo de piezas costaría margen: un `Write` de 786 428 B tarda 15,7–18,4 s solo, y bajo carga roza los 40 s. Optimizar la normalización de transporte sería una mejora que se propone antes de hacerse y movería el perfil de la sonda 37/3. **Es un movimiento `allow` → `deny` que CA-69 p. 3 no declara:** cambio de contrato, del propietario.

**Opciones para (1).**
- **(A) Aceptar los techos como cambio de compatibilidad declarado,** con el write-back del analista en CA-68 y CA-69 p. 3 (el movimiento, sus dos cifras y la consecuencia: un REQ de más de 393 216 bytes no se escribe entero de una vez, y un `Edit` con `old_string` de más de ~6,5 KB sobre un documento de ese tamaño se deniega; se parte la edición), notas y guía. **Y una ficha para adelgazar `REQ-007.md`** (su historia a `historial/` con la rotación por sección que el arnés ya trae, `rotacion.artefactos`), porque 660 KB es el síntoma. **Consecuencia:** cero código; el margen de tiempo se conserva; en este repositorio los agentes editan REQ-007 con `Edit` de fragmentos pequeños, así que el trabajo diario no cambia.
- **(B) Subir `ARNES_PIEZAS_MAX_BYTES` por encima de `REQ-007.md`** (p. ej. 1 MiB) y el presupuesto de búsqueda en proporción. **Consecuencia:** el `Write` de 660 KB vuelve a pasar, pero cuesta 15–18 s en reposo y bajo carga puede vencer el plazo de 30 s y salir `deny` igualmente, ahora por tiempo; T2a (2 MB) sigue en `deny`.
- **(C) Optimizar la normalización de transporte** (la operación superlineal) en una intervención propia, propuesta antes de hacerse. **Consecuencia:** otra intervención con su ciclo; mueve el perfil de la sonda 37/3 (E1–E3 otra vez).

**(2) El FAIL del inventario.** En la primera de tres corridas del banco de v1.35.0 con los hooks del candidato (`50-`–`52-`): sección 24, `arnes-lectura: …el contador no dice 1`. **No se reprodujo** en la sección 24 aislada (3 veces), en la segunda corrida, en la final ni en los tres bancos del worktree. El caso ejecuta `tools/arnes-lectura.sh`, que comparte `lib.sh` con los hooks: **ejecuta código del delta**, así que por P-136-E es parada. Un FAIL no se desmiente repitiendo.

**Opciones para (2).**
- **(A) Observación independiente de QA:** QA corre su propio inventario (lo hace de todos modos en la fase 3) y la sección 24 varias veces, con el anfitrión en reposo y anotando la carga. Si lo reproduce, es hallazgo contra el delta; si no, se registra como instrumento (INS-136-3) con las nueve corridas limpias y la única roja. **Consecuencia:** sin coste extra; la decisión queda medida por alguien que no escribió el código.
- **(B) Que el desarrollador investigue la causa ahora** (¿el plazo propio o la trampa de salida afectan a `tools/`?), antes de QA. **Consecuencia:** de 30 a 60 minutos; puede no encontrar nada en un fallo que no se reproduce.

**Recomendación de la coordinadora: (1) = (A) y (2) = (A).**

**Decisión propuesta, lista para adoptar:** «P-136-O: (1) (A): los techos quedan como cambio de compatibilidad declarado; el analista lo escribe en CA-68, CA-69 p. 3, la guía y las notas; ficha para adelgazar `REQ-007.md` a `historial/` en 1.37. (2) (A): QA observa el FAIL de la sección 24 en su propio inventario y en varias corridas de la sección en reposo; si lo reproduce, es hallazgo; si no, INS-136-3. Nada más entra.»

**Qué trabajo sigue mientras no se decida:** el write-back del analista de lo que no depende de (1) (R1/R2, plazo, tope del motivo, el estado de SEC-130) y el registro de las fichas; QA (fase 3) espera a (1), porque valida contra el contrato. **Agrupada con P-136-N** (QA-007-07), que sigue pendiente.

**Espera:** elección del propietario.

### RESUELTA (coordinadora, por delegación expresa del propietario del 2026-10-06) — **Plan autorizado: paso 6 de 1.36.0, SEC-115 y SEC-118 (CA-67, CA-68, CA-69; ADR-017), con la reparación de SEC-129 (`POSIXLY_CORRECT`)**

**Fuente de la delegación:** «Encadena sin parar: … commit validado, y abre SEC-115/118» (P-136-J/K/L, 2026-10-06) y el «Resumen del plan vigente» del propietario (punto 4). La condición previa está evaluada (`docs/arnes/v1.36.0-sec115-118-ca68-vs-req017.md`: leyendo, no afecta; se mide E1–E3). Los bloques se calcan de la décima autorización.

**Contrato que rige** (REQ-007): **CA-67** (SEC-118: toda denegación decidida llega al cliente, entera o acotada, nunca perdida; el desarrollador elige la técnica; los avisos entran — P-136-B), **CA-68** (SEC-115: techos de tamaño más un plazo propio de no más de 40 s, sin procesos, medido a nivel de hook con la emisión incluida — P-136-C), **CA-69**, **ADR-017**. **Propiedad que CA-68 gana para SEC-129** (R-054; la escribe el analista en la fase 0): el hook sólo sale sin decisión cuando ha terminado un juicio que concluye que la llamada no toca nada protegido; cualquier otro final emite `deny` con motivo propio, a todo agente; y ninguna decisión depende del modo del intérprete heredado del entorno. **Si P-136-N = (A)**, la propiedad se enuncia sobre todo lo heredado del entorno e incluye `ARNES_INPUT_LISTO` y `ARNES_MANIFEST_LISTO` (QA-007-07); **si (B)**, QA-007-07 va a 1.37.

**Restricción para los techos de tamaño:** ninguno puede caer sobre las entradas de la sonda 37/3 de REQ-017 CA-09 (un techo sobre `content` de `Write` queda por encima de los 296 976 bytes de `REQ-021.md`; ninguno por línea de cabecera en el camino común). Lo medido como «sin decisión» en 1.35.0 (1 801 y 3 000 líneas ASCII; 1 601 con `ñ`; 1 001 de 4 bytes; 2 501 cortas con `ñ`; ≈ 140 KB de R-045 §4) tiene que dar `deny`.

> ## Plan autorizado (se ejecuta entero; cada fase termina en commit local y la siguiente empieza sin pedir permiso)
> Fase 0 — analista: write-back de CA-67/CA-68/CA-69 con la propiedad de SEC-129 (y QA-007-07 según P-136-N), la restricción de los techos y E1–E3 como medida; nota posterior fechada en ADR-017 si cambia su alcance; `Archivos:` con la sección prevista.
> Fase 1 — desarrollador: casos de banco con fail-before sobre `78a2f33` y v1.35.0: SEC-118 (los puntos medidos, ASCII y multibyte, más los avisos), SEC-115 (T1–T3 con `timeout 60` y el plazo propio), SEC-129 (la matriz de `seg-posix/02-matriz.sh` por las tres puertas de `Bash`) y E1. Sin reparar.
> Fase 2 — desarrollador: reparación con 0 procesos añadidos en el camino común: emisión siempre (motivo acotado o fuera de la línea de órdenes), plazo propio ≤ 40 s sin procesos, techos de tamaño donde la restricción lo permite, R1 (salir del modo POSIX al arrancar, sin procesos) y R2 (código del analizador no declarado, o puerta abandonada a mitad → `deny`). Entrega: casos en verde, E2 (sección 37/3 ≥ 6 veces) y E3 (la línea de CA-09 en los inventarios), inventario CA-69 2 con `ARNES_SEMILLA_41=23062`, banco, autoprueba, gates, procesos, y el tope del motivo medido en bytes con ASCII y multibyte (Windows: declarado no medido).
> Fase 3 — QA (Opus): repite y ataca; comprueba si R2 cubre SEC-130 por construcción (F-136-12). Una pasada correctiva como máximo, y su re-verificación.
> Fase 4 — seguridad, sólo con QA favorable: reclasifica SEC-115, SEC-118 y SEC-129 (y SEC-130 si R2 lo cubre). Write-back del analista si hay deriva. Commit validado.
>
> ## Lo que decide la coordinadora sola
> Lo mismo que en los planes de SEC-120 y del paso 5. Presupuesto orientativo: desarrollador 400–700 k, QA 300–450 k, seguridad 150–250 k, analista 150–250 k.
>
> ## Cuándo paras y me preguntas (solo esto)
> Lo mismo que en el plan de SEC-120, con la regla afinada de P-136-E, más: **E1, E2 o E3 dan «afecta»** → parar y presentar con §9 (ficha ya redactada en la evaluación); **el plazo de 40 s no se puede cumplir sin procesos**; **el tope del motivo no se puede medir**.
>
> ## Si la sesión se corta
> Se continúa desde la última fase comiteada, sin pedir la autorización.
>
> ## Límites
> Nada fuera de SEC-115, SEC-118 y SEC-129 (QA-007-07 sólo si P-136-N = (A); SEC-130 sólo como comprobación de QA). No `AGENTS.md` ni contadores. No push, versión, PR, fusión ni tag.

### RESUELTA (propietario, 2026-10-06) — **PR #60 en borrador** de `cand/1.36.0` hacia `main` («SI hazlo» a la decisión propuesta del 2026-10-06); y despacho en paralelo de dos comisiones que no tocan los archivos de QA

**Texto del propietario, literal:** «SI hazlo» (a la propuesta: «Abre un PR en borrador de `cand/1.36.0` hacia `main`, titulado "Candidato 1.36.0 (borrador)", con la descripción remitiendo a `docs/PLAN.md` § 1.36.0 y a las notas pendientes. No es decisión de fusión ni de publicación; sirve para que cada push tenga su corrida de CI. Fusionar, etiquetar y publicar siguen siendo míos.»). Y, acto seguido: «Si podemos trabajar con varios agentes hazlo».

**Lo que añade la coordinadora, rotulado como suyo:**
- **PR #60** (https://github.com/JJOVEGA/ArnesJuan/pull/60), borrador, sobre la cabeza remota `f1ffac3`. El CI corre sobre cada push de la rama; el push sigue siendo del propietario.
- **Paralelo, con los archivos declarados disjuntos por instrucción** (`tools/arnes-paralelo.sh` no puede declararlo: es el mismo REQ-007), y sin violar el orden de fases, porque ninguna de las dos acredita el código del paso 5:
  1. QA del paso 5 (en curso): `docs/qa/REQ-007.md`, la cabecera de REQ-007 y `cand-1.36.0/sec127/qa/`;
  2. `auditor-seguridad`, revisión corta de `POSIXLY_CORRECT` (P-136-L): sólo `docs/seguridad/registro-seguridad.md` (R-054) y `cand-1.36.0/sec127/seg-posix/`; **no toca REQ-007**; la reclasificación de SEC-127 y SEC-128 va después, con QA terminado;
  3. `analista-requerimientos`, condición previa del paso 6: evaluación de CA-68 frente a REQ-017 CA-09, sólo en `docs/arnes/v1.36.0-sec115-118-ca68-vs-req017.md`; **no toca ningún REQ**.

### RESUELTA (propietario, 2026-10-06, sobre `df0b4f0`) — **Resumen del plan vigente de 1.36.0, fichas de 1.37.0 y 1.38.0, y objetivo rector del arnés** (la fuente sigue siendo `docs/PLAN.md`, la cola y ESTADO)

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Plan vigente, para la coordinadora (resumen del propietario; la fuente es
> docs/PLAN.md, la cola y ESTADO; si algo difiere, mandan ellos).
>
> ## 1.36.0 — en curso. Alcance cerrado: nada más entra; lo nuevo va a ficha.
> 1. CA-54 / QA-023-10 — CERRADO en 82ceb63. QA-007-01 límite declarado;
>    recursión medida por seguridad hasta 2040 niveles. La 2b sale a 1.37.
> 2. SEC-120 — CERRADO (reparado, QA favorable, seguridad, commit).
>    QA-007-05 corregido en texto; QA-007-06 residual, reparado en el paso 5.
> 3. Paso 5 — SEC-127 + QA-007-06 + SEC-128 — EN CURSO:
>    - código hecho (a59917d, 78a2f33), sin validar;
>    - P-136-M en medición dirigida (REQ-017 CA-08 (ii) con anfitrión en
>      reposo sobre v1.35.0 → 82ceb63 → 413c6bd → a59917d → 78a2f33); si hay
>      escalón, pasada correctiva del paso 5 (sin gastar) sobre ese commit;
>      si no, instrumento y ficha para REQ-017;
>    - después: QA del paso 5 entero → revisión corta de POSIXLY_CORRECT
>      (P-136-L) → seguridad (reclasifica SEC-127) → commit validado.
>    - bash 5.0/POSIX: no medido, declarado (P-136-K).
> 4. SEC-115/118 — CA-67, CA-68, CA-69; ADR-017. El hook siempre emite
>    decisión; plazo propio 40 s; tope del motivo; los avisos entran
>    (P-136-B/C). Incluye la reparación de POSIXLY_CORRECT (P-136-L). ANTES
>    de construir: evaluar CA-68 frente a REQ-017 CA-09; si afecta, parar y
>    presentarlo al propietario con §9.
> 5. Cierre — notas [1.36.0], límites declarados, decisiones de riesgo,
>    limpieza de propuesta-v1.35.0/ a docs/historia o evidencia, PR fuera de
>    borrador, CI verde; fusión, tag y publicación: propietario.
> Pendiente del propietario: ninguno salvo lo que CA-68 produzca y publicar.
>
> ## Reglas de ejecución (plantilla templates/autorizacion.md)
> - Cada fase termina en commit local; la siguiente empieza sin pedir permiso.
> - Decide sola: texto, trazabilidad, banco sin cambio de veredicto, la
>   pasada correctiva prevista, orden y presupuesto de despachos, registrar
>   defectos sin repararlos.
> - Para y pregunta sólo por: cambio de contrato o alcance; aceptar/aplazar
>   riesgo; más pasadas que la prevista; un caso que EJECUTA HOOKS cambia de
>   veredicto (los de calibración de sonda se registran y se sigue); un
>   control del proveedor detiene algo (registra, no reintenta, sigue con lo
>   independiente); publicar/fusionar/etiquetar/cerrar REQ.
> - Si la sesión se corta: lee ESTADO y la cola y continúa; la autorización
>   ya está dada.
> - hooks/ sólo lo edita el desarrollador. Push de la candidata: recordar al
>   propietario al final de cada fase (ficha para que lo haga el agente en
>   1.37).
>
> ## 1.37.0 (fichas registradas; no se construyen ahora)
> a) Plan de desarrollo (docs/PLAN.md como fuente; la coordinadora continúa
>    sola salvo gates; línea derivada en ESTADO).
> b) Post-condición de filesystem (foto antes / comparación después /
>    reversión; hueco C pasa de límite a detección).
> c) Adelgazamiento: roles, gates y tabla §13 a .arnes/config.json; AGENTS.md
>    a la mitad; historia a docs/; rigor proporcional como regla por
>    defecto; analista en modelo más barato y /compact entre fases.
> d) Spike «ArnesJuan como mod»: guard-git como mod medido contra el banco.
> e) 2b de CA-54 (QA-007-01, recursión), push de candidata por el agente,
>    límite declarado de mods (un mod de usuario puede aprobar lo que las
>    puertas niegan; mitigación allowManagedModsOnly).
>
> ## 1.38.0
> f) Frontmatter YAML en los REQ. g) Veredictos con hash de árbol, comando y
> rc, comprobados por guard-completado. h) Sección adversarial permanente del
> banco (t3/t4/t5/t5b/t9 por referencia; entornos desde archivos). i) runs/
> por corrida (observabilidad).
>
> ## Medición de esta prueba de modelo
> Al cerrar SEC-115/118: decisiones escaladas, paradas no previstas, tokens
> por rol, comparado con CA-54 y SEC-120.

**Y su objetivo, literal, en el mismo mensaje:** «Mi objetivo principal es que este arnés nos ayude a construir aplicaciones más rápido, con menos coste y sin perder el control de: Fidelidad al encargo: que los agentes no cambien requisitos o alcance sin tu autorización. Un plan de desarrollo: saber qué hacer primero, qué depende de qué y cuándo una entrega está terminada. Autonomía útil: continuar el trabajo autorizado sin detenerse por cada ajuste menor. Calidad y seguridad proporcionales: detectar errores sin convertir cada corrección en una cadena interminable. Medición real: conocer tiempo, tokens y coste hasta una entrega aprobada; no presumir ahorro sin evidencia.»

**Lo que añade la coordinadora, rotulado como suyo:**
- **Lo que no estaba en `docs/PLAN.md` y ahora está:** la condición previa del paso 6 (evaluar CA-68 frente a REQ-017 CA-09 **antes** de construir; si afecta, parar y presentarlo con §9); el detalle del paso 7 (notas, límites, decisiones de riesgo, limpieza de `propuesta-v1.35.0/`, PR fuera de borrador, CI verde); las fichas a–e de 1.37.0 y f–i de 1.38.0; y el objetivo rector, al principio.
- **P-136-M ya está medido** (sin escalón; INS-136-2, F-136-8), así que el punto 3 del resumen va por «después».
- **El PR:** el paso 7 dice «PR fuera de borrador», lo que presupone un PR en borrador antes. Abrirlo sigue siendo decisión del propietario (propuesta hecha el 2026-10-06, pendiente de «adopto»).
- La cola sigue vacía.

### RESUELTA (propietario, 2026-10-06, sobre la cabeza `098896c`) — **La coordinadora pasa al modelo Fable 5.1 como prueba acotada** (lo que queda del paso 5 y SEC-115/118); los subagentes conservan su modelo; el plan no cambia

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`, tras `/model fable`):

> Cambio de modelo de la coordinadora a Fable, decidido por el propietario,
> como prueba acotada durante lo que queda del paso 5 y SEC-115/118. Los
> subagentes mantienen su modelo. Nada del plan cambia: continúa desde donde
> está (P-136-M en medición dirigida) con la autorización vigente, la
> plantilla y ESTADO; no vuelvas a pedir lo ya autorizado.
>
> Registra el cambio en la cola y en ESTADO con la fecha y la cabeza. Al
> cerrar SEC-115/118, entrega una comparación con CA-54 y SEC-120 en tres
> cifras: decisiones escaladas al propietario, paradas no previstas por el
> plan, y tokens totales por rol (coordinadora aparte). Sin valoración; sólo
> las cifras, para que el propietario decida si el cambio se queda.
>
> Reglas que no cambian con el modelo: hooks/ sólo lo toca el desarrollador;
> un control del proveedor que detenga algo se registra y no se reintenta;
> publicar, fusionar y etiquetar son del propietario. Y recuérdale el push
> de la candidata al final de cada fase comiteada.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Cabeza al cambiar:** `098896c` (P-136-M resuelta; medición dirigida en curso). Las entradas del CHANGELOG escritas por la coordinadora desde aquí llevan «modelo de IA: Fable 5.1»; las de los subagentes, el suyo.
- **Cifras de referencia para la comparación**, tomadas de las entradas del CHANGELOG de cada intervención (la coordinadora aparte):
  - **CA-54 (intervención 1):** decisiones escaladas al propietario: 7 (P-136-A a P-136-G); paradas no previstas por el plan: 4 (inventario distinto por la semilla, atajo frente a CA-54 (c), 5 213 ms sin el atajo, QA-007-02 en la re-verificación); tokens: desarrollador ≈ 682 k, QA ≈ 494 k, analista ≈ 954 k, seguridad ≈ 252 k.
  - **SEC-120 (pasos 1–4):** decisiones escaladas: 3 (los tres puntos de la fase 2, en una sola entrada) + P-136-H + P-136-I = 5; paradas no previstas: 1 (la pausa por falta de créditos; las dos vueltas de hallazgos de QA estaban previstas por el plan como pasada correctiva); tokens: desarrollador ≈ 204 k + 90 k + 75 k ≈ 369 k, QA ≈ 203 k + 208 k ≈ 411 k, analista ≈ 132 k + 104 k ≈ 236 k, seguridad ≈ 192 k.
  - **Paso 5 (SEC-127, QA-007-06, SEC-128) y SEC-115/118:** se cuentan desde aquí, y las cifras se entregan al cerrar SEC-115/118, sin valoración.
- **Push:** el propietario ordenó el push el 2026-10-06 (`f1ffac3`) y confirmó que el push anterior de `0ed5d61` (08:17 CR) lo hizo él mismo: no hay hallazgo de proceso. El PR en borrador sigue pendiente de su «adopto».
- **Forma de las fichas desde aquí (petición del propietario, 2026-10-06):** cada ficha lleva, además de la forma de la regla 4, un bloque «Decisión propuesta, lista para adoptar», redactado como la escribiría el propietario, para que responda «adopto» o la corrija. La decisión sigue siendo suya y se registra literal con su respuesta.

### RESUELTA (propietario, 2026-10-06) — **P-136-M: (A)**, medición dirigida de REQ-017 CA-08 (ii) con el anfitrión en reposo sobre cinco commits

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-M: (A). Medición dirigida de REQ-017 CA-08 (ii) con el anfitrión en
> reposo (carga < 0,5 antes de empezar, registrada), en este orden:
> v1.35.0 → 82ceb63 → 413c6bd → a59917d → 78a2f33. Mismo método, mismas 5
> mediciones por commit, sin repetir para buscar verde.
> - Si aparece un escalón: la pasada correctiva del paso 5 va a ese commit,
>   con la propiedad «el ratio vuelve al de v1.35.0», sin tocar el umbral
>   de 1,25×.
> - Si no hay escalón (los cinco oscilan igual alrededor del techo): se
>   registra como instrumento con las cinco cifras, y sigue. En ese caso,
>   ficha para REQ-017: un techo de 1,25× con el ratio en 1,20–1,30 en
>   reposo es demasiado fino para acreditar nada; se revisa en 1.37, no
>   ahora.
> Después: QA del paso 5 entero, seguridad, commit validado, SEC-115/118.

**Lo que añade la coordinadora:** la medición la hace el `desarrollador` de SEC-128, sin tocar código. La cola queda vacía.

### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-06] (coordinadora) — P-136-M: en el inventario de SEC-128, REQ-017 CA-08 (ii) («un REQ real de 6 líneas», de reloj, ejecuta hooks) pasa de INCONCLUSO a FAIL: «mín(r) 1,251× > techo 1,250×» en 5 de 5. ¿Ruido de anfitrión o regresión de coste?

**Contexto.** SEC-128 (`78a2f33`; evidencia `f641380`, `cand-1.36.0/sec127/`, archivos 90- a c1-; registro `docs/arnes/v1.36.0-sec127-fase2.md`, «SEC-128»).
- **Conforme:**
  - el cambio es una sola condición en `guard-codigo.sh`;
  - bloque E de la sección 47: 44/0, con fail-before 41/3 sobre `a59917d`;
  - K5 con su fail-before;
  - banco del worktree 2198/0/12; autoprueba 117/0; gates rc 0;
  - camino común: los mismos procesos que en `a59917d`.
- **La parada:** el banco de v1.35.0 con los hooks del candidato da 2038/**1**/11. REQ-017 CA-08 (ii) «6 líneas» era INCONCLUSO en `22-` y en la corrida anterior (`61-`), y ahora es FAIL en 5 de 5, justo encima del techo. Carga del anfitrión ≈ 1,4–2,0. El `Edit` de ese caso no entra en la rama de SEC-128, pero sí pasa por SEC-120, QA-007-06 y CA-54.
- **Por qué no se resuelve solo:** P-136-E define la parada como un caso que ejecuta hooks y pasa entre PASS y FAIL, y éste ejecuta hooks. Un FAIL no se desmiente repitiendo la corrida. Y 5 de 5 encima del techo no es el patrón de ruido que daba INCONCLUSO.

**Pregunta.** ¿Cómo se trata?

**Opciones.**
- **(A) Medirlo de forma dirigida antes de QA:** el ratio de CA-08 (ii) con el anfitrión en reposo sobre `v1.35.0`, `82ceb63`, `413c6bd`, `a59917d` y `78a2f33`, con las mismas r, para localizar si hay un escalón y en qué commit. Si hay regresión atribuible, es un hallazgo y se usa la pasada correctiva del paso 5, que sigue sin gastar. Si no hay escalón, es INS de reloj y se sigue. **Consecuencia:** de 30 a 60 minutos; la decisión queda medida.
- **(B) Que QA lo observe en su propio inventario,** con el anfitrión en reposo, como observación independiente. Si vuelve a dar FAIL, es un hallazgo. **Consecuencia:** más barato, pero no localiza el commit.
- **(C) Registrarlo como instrumento** (reloj bajo carga) y seguir. **Consecuencia:** sin coste, pero se arriesga a publicar una regresión de coste en la vía `Edit`.

**Recomendación de la coordinadora: (A).** Es la única que distingue el ruido de una regresión, y el escalón, si existe, dice qué reparar.

**Qué trabajo sigue mientras no se decida:** ninguno del plan, porque QA del paso 5 depende de esto. Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-06) — **P-136-J (A, acotada), P-136-K (A) y P-136-L (A)**; se encadena sin parar hasta abrir SEC-115/118

**Texto del propietario, literal** (mensaje del 2026-10-06 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-J: (A), acotada: la reparación es únicamente que un file_path que no
> es texto no deje pasar a nadie (fail-closed), con su caso de banco. Nada
> más entra en esta fase 2 corta. Si al abrirla aparece algo más, ficha.
>
> P-136-K: (A). SEC-127 se acredita con los casos de la sección 47 y la
> lectura del código; la prueba en bash 5.0 en modo POSIX queda declarada
> como no medida en CA-47 y en las notas. O-52-3 pasa a ficha de seguridad.
>
> P-136-L: (A). Revisión corta de seguridad ahora, para fijar qué apaga
> exactamente POSIXLY_CORRECT=1 y desde cuándo (también en v1.35.0: no es
> regresión); la reparación va dentro de SEC-115/118, que ya trata «el hook
> siempre emite decisión».
>
> Encadena sin parar: SEC-128, QA del paso 5 entero, revisión corta de
> POSIXLY_CORRECT, seguridad de SEC-127, commit validado, y abre SEC-115/118.

**Lo que añade la coordinadora:**
- **Orden en serie** (todo es REQ-007):
  1. el analista escribe J y K en el contrato (CA-47) y añade la ficha O-52-3;
  2. el desarrollador repara SEC-128;
  3. QA del paso 5 entero;
  4. una sola comisión de `auditor-seguridad`: la revisión corta de `POSIXLY_CORRECT` y la seguridad de SEC-127, SEC-128 y QA-007-06;
  5. commit validado;
  6. apertura de SEC-115/118 con su plan, que incluye la reparación de `POSIXLY_CORRECT`.
- **«Las notas»** de K: las notas `[1.36.0]` no existen todavía. El texto va a la entrada «Hacia 1.36.0» de la guía, como se hizo con QA-007-01, para copiarlo después a las notas.
- La cola queda vacía.

### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-J: SEC-128 (`contrato`, baja; R-053). `guard-codigo` deja pasar al agente de código con un `file_path` que no es texto, antes de aplicar la regla del enlace (SEC-004). ¿Se repara dentro de SEC-127, se repara aparte o se declara?

**Contexto.** R-053 (`docs/seguridad/registro-seguridad.md`), sobre `413c6bd`. **Determinación: con hallazgos, sin veto. SEC-120 queda `mitigado` en el candidato.**
- **SEC-128:** `hooks/guard-codigo.sh:37-42` devuelve permiso al agente de código cuando `file_path` no es texto, y lo hace **antes** de `arnes_deny_enlace` (`:67`), cuya regla (SEC-004) alcanza a todo agente.
  - Medido: el agente de código, con `file_path: 5` y un enlace `<raíz>/5 -> src/a.ts`. v1.35.0 y `82ceb63` deniegan; el candidato, con `guard-codigo` invocado solo, **sale sin decisión**. Es un movimiento que CA-69 p. 3 prohíbe.
  - **Por `guard.sh`, que es la vía real, no tiene efecto:** `guard-completado` deniega en los tres árboles.
  - La fila **K5** del banco (`44-…:366`) da esa conducta por conforme con un rótulo falso («la puerta de código no juzga el destino del desarrollador»).
- **Alcance (§6, regla 2):** impide **cerrar** REQ-007. Mientras siga abierto, **publicar** vuelve al propietario; el auditor no lo veta. No impide implementar, probar, el commit validado de SEC-120 ni SEC-127.

**Pregunta.** ¿Cómo se repara SEC-128?

**Opciones.**
- **(A) Dentro de SEC-127**, que es una intervención corta, con su ciclo completo y antes de publicar. `guard-codigo` deniega también al agente de código cuando el campo no es texto (remediación (a) de R-053); K5 pasa a `deny` y se añade un caso con enlace. Write-back del analista. **Consecuencia:** el mismo patrón que QA-007-06; añade poco a SEC-127. Toca `guard-codigo.sh` y el banco, y no `lib.sh`.
- **(B) Una intervención propia** después de SEC-127. **Consecuencia:** otro ciclo completo antes de publicar.
- **(C) Declarar el movimiento** como límite (por `guard.sh` no tiene efecto). **Consecuencia:** cero código, pero CA-69 p. 3 deja de cumplirse para esa forma y K5 sigue con un rótulo falso.

**Recomendación de la coordinadora: (A).**

**Qué trabajo sigue mientras no se decida:** el commit validado de SEC-120 (hecho) y la fase 1 de SEC-127 (casos de banco del locale y de QA-007-06, con su fail-before), que no dependen de esta decisión. La reparación de SEC-127 (fase 2) espera a la decisión, para no gastar dos pasadas sobre el banco. Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario.


### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-K: el caso 2 de SEC-127 tal como lo pidió el propietario («cierre TERMINÉ/terminé en `LC_ALL=C` simulado, que pasó de `deny` a `allow`») no es construible como fail-before. ¿Con qué se acredita SEC-127?

**Contexto.** Fase 1 del paso 5 (`ab52c9b`; `docs/arnes/v1.36.0-sec127-fase1.md` §3; evidencia `cand-1.36.0/sec127/`, commit `79f3908`).
- Con `LC_ALL=C` en el **entorno**, el cierre `TERMINÉ`/`terminé` sale sin decisión **también en v1.35.0**: es O-52-3 (R-052 §5), anterior al candidato y no registrado como hallazgo. La simulación de R-052 (`seg-R052/94-`) no aísla el mecanismo de SEC-127 (que la asignación del atajo persista en bash ≤ 5.0 en modo POSIX): mide el locale del entorno.
- Exigir `deny` ahí sería un movimiento de «sin decisión» a `deny` que CA-69 p. 3 no admite para CA-54. Además, la reparación autorizada (`local LC_ALL=C` o guardar y restaurar) devuelve el locale de partida, que en esa simulación es C: el caso no podría ponerse en verde.
- **Lo que sí está construido:** LO1–LO4 (el locale leído después del atajo, en modo normal y POSIX) y LK (el cierre fiel, en UTF-8), los dos en verde hoy. **No son fail-before** en bash 5.3.9. **No hay bash ≤ 5.0 en el anfitrión;** la descarga de `ftp.gnu.org` agotó el tiempo y no se reintentó.

**Opciones.**
- **(A)** Aceptar LO y LK como los casos de SEC-127, con el fail-before real pendiente de un bash ≤ 5.0 (se registra como no medido). La reparación sin subshell sigue tal cual. **Consecuencia:** SEC-127 se repara por construcción y se verifica por lectura y con los casos de bash 5.3; la acreditación con bash 5.0 queda declarada como laguna.
- **(B)** Contratar O-52-3: que el cierre con estado no ASCII se deniegue sea cual sea el locale del proceso. **Consecuencia:** es un cambio de contrato del analista, con un movimiento nuevo declarado y otra reparación (por ejemplo, comparar la clave sin depender de `grep -i`). Alarga el paso 5.
- **(C)** Conseguir un bash 5.0 (contenedor o compilación local) para medir el fail-before real antes de reparar. **Consecuencia:** coste de montarlo y una dependencia de red.

**Recomendación de la coordinadora: (A),** con O-52-3 como ficha para que el auditor lo clasifique. Es lo que la reparación sin subshell ya garantiza, y no amplía el paso 5.

**Qué trabajo sigue mientras no se decida:** la fase 2 (la reparación de SEC-127 sin subshell y de QA-007-06), que no depende de esto. QA (fase 3) sí espera. **Agrupada con P-136-J y P-136-L.**

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-06; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-L: con `POSIXLY_CORRECT=1` en el entorno, la vía `Bash` NO decide en ninguno de los dos árboles (v1.35.0 tampoco). Es un fallo en abierto preexistente y sin clasificar. ¿Qué se hace?

**Contexto.** Hallazgo lateral del desarrollador en la fase 1 de SEC-127 (`cand-1.36.0/sec127/09-`): con `POSIXLY_CORRECT=1`, ni `echo x > src/a.ts`, ni `sed -i …completado`, ni `git reset --hard` reciben decisión. `Write` sí deniega. Ocurre en v1.35.0 y en el candidato, así que **no es movimiento**. Ningún agente de seguridad lo ha revisado. Si el entorno de Claude Code llevara esa variable, las puertas de `Bash` quedarían apagadas en todos los proyectos. En bash 5.3 deja además a SEC-127 sin movimiento (R-052 §4 decía que eso lo cerraría por medición).

**Opciones.**
- **(A) Revisión corta del `auditor-seguridad` ahora:** registra el hallazgo (SEC-129), lo clasifica, mide el alcance desde el host y propone la remediación. La reparación se decide después. **Consecuencia:** de 20 a 40 minutos; no toca código.
- **(B) Meterlo en SEC-115/118 (paso 6)**, que ya trata de que el hook decida siempre. **Consecuencia:** se registra ahora como ficha y se repara allí, antes de publicar.
- **(C) Ficha para 1.37.** **Consecuencia:** 1.36.0 se publicaría con ese fallo en abierto, sin declarar.

**Recomendación de la coordinadora: (A) y después (B).** Un posible apagado de las puertas de `Bash` por una variable de entorno merece clasificarse ya, y su arreglo encaja en el paso 6.

**Qué trabajo sigue mientras no se decida:** la fase 2 de SEC-127. **Agrupada con P-136-J y P-136-K.**

**Espera:** elección del propietario.

### RESUELTA (coordinadora, por delegación expresa del propietario del 2026-10-05) — **Plan autorizado: paso 5 de 1.36.0, SEC-127 más QA-007-06**

**Fuente de la delegación:** «Continúa sin pararte: write-back de QA-007-05, seguridad de SEC-120, commit validado, SEC-127» (P-136-H/I, literal en esta sección). Las condiciones son las de P-136-G y P-136-I, sin cambios. Los bloques se calcan del plan de SEC-120.

> ## Plan autorizado (se ejecuta entero; cada fase termina en commit local y la siguiente empieza sin pedir permiso)
> Fase 1 — desarrollador: casos de banco, con su fail-before sobre el candidato (`413c6bd`) y v1.35.0:
> (i) SEC-127: el locale del proceso leído DESPUÉS del atajo de `guard-completado`, y el cierre de un REQ con estado no ASCII (TERMINÉ/terminé) en `LC_ALL=C` simulado;
> (ii) QA-007-06: `read` de la entrada falla con error, por cualquier causa (ejemplos no exhaustivos: entrada estándar cerrada, entrada que es un directorio), con un caso por cada causa medida.
> Sin reparar.
> Fase 2 — desarrollador: reparación SIN subshell (`local LC_ALL=C` o guardar y restaurar, a su elección) y `read` fallido → entrada ilegible → `deny`, con 0 procesos añadidos en el camino común. La versión de bash no se declara como límite. Entrega: casos en verde, inventario CA-69 2 con la semilla fijada, banco, autoprueba y gates.
> Fase 3 — QA (Opus): repite y ataca. Cierra QA-007-05 (texto corregido por P-136-H) y QA-007-06 si procede. Una pasada correctiva como máximo, y su re-verificación.
> Fase 4 — seguridad, sólo con QA favorable: reclasifica SEC-127 al cerrarlo. Write-back del analista si hay deriva. Commit validado.
>
> ## Lo que decide la coordinadora sola
> Lo mismo que en el plan de SEC-120.
>
> ## Cuándo paras y me preguntas (solo esto)
> Lo mismo que en el plan de SEC-120, con la regla de parada afinada de P-136-E.
>
> ## Si la sesión se corta
> Se continúa desde la última fase comiteada, sin pedir la autorización.
>
> ## Límites
> Nada fuera de SEC-127 y QA-007-06 (SEC-128 está en P-136-J); nada de SEC-115/118. No `AGENTS.md` ni contadores. No push, versión, PR, fusión ni tag.

### RESUELTA (propietario, 2026-10-05) — **P-136-H: (A)** (el texto del límite del punto 20, sin código) y **P-136-I: (B)** (SEC-120 se cierra con QA-007-06 como residual declarado, que se repara en SEC-127); el plan de SEC-127 gana QA-007-06; se sigue sin parar

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-H: (A). El texto del límite del punto 20 queda: «sin
> CLAUDE_PROJECT_DIR, el hook es inerte si no puede obtener el proyecto;
> si del cwd de la entrada obtiene uno con manifiesto, deniega». Es la
> conducta más segura y no toca código.
>
> P-136-I: (B). SEC-120 se cierra con QA-007-06 como residual declarado
> (entrada estándar cerrada: los guardianes abortan sin decidir; ninguna
> decisión cambia frente a v1.35.0; no provocable desde el host en lo
> observado). Se repara dentro de SEC-127, que toca el mismo archivo, lleva
> su ciclo completo y va antes de publicar. El punto 20 conserva la promesa
> «deny por cualquier causa» con QA-007-06 anotado como pendiente hasta
> SEC-127, no como límite.
>
> Ficha de SEC-127: su plan incluye QA-007-06 (entrada estándar cerrada →
> deny) junto con el locale, con un caso de banco para cada uno.
>
> Continúa sin pararte: write-back de QA-007-05, seguridad de SEC-120,
> commit validado, SEC-127.

**Lo que añade la coordinadora:** el write-back es del analista. QA-007-05 se cierra cuando QA lo compruebe, en el QA de SEC-127; hasta entonces sigue en `Hallazgos abiertos:` con su clase. `docs/PLAN.md`, paso 5, gana QA-007-06. La cola queda vacía.

### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-H: QA-007-05 (`contrato`, baja). Sin `CLAUDE_PROJECT_DIR`, el candidato deniega algunas entradas malformadas en lugar de quedar «inerte como en v1.35.0». ¿Se corrige el texto del límite o el código?

**Contexto.** QA de SEC-120, fase 3 (`docs/qa/REQ-007.md`, «SEC-120: validación (fase 3)»; evidencia `cand-1.36.0/sec120/qa/`, commit `7a967e2`), sobre `aba1c9b`.
- **Lo que dice hoy el límite declarado de CA-47 p. 20** (decisión 3 del propietario): sin `CLAUDE_PROJECT_DIR`, el hook sigue inerte, como en v1.35.0, porque denegar ahí rompería proyectos que no usan el arnés.
- **Lo medido:** sin `CLAUDE_PROJECT_DIR`, un objeto seguido de basura y un `tool_input` numérico sí reciben `deny` en el candidato (v1.35.0 no decidía). `arnes_project_dir` toma el `cwd` del primer valor. **El error es del lado seguro:** sólo deniega dentro de proyectos que usan el arnés (los que tienen manifiesto en ese `cwd`), así que la razón del propietario («rompería proyectos que no usan el arnés») no se ve afectada.

**Pregunta.** ¿Qué se alinea con qué?

**Opciones.**
- **(A) Corregir el texto (write-back del analista):** sin `CLAUDE_PROJECT_DIR`, si no se puede obtener el proyecto de la entrada, el hook es inerte, como en v1.35.0; si se obtiene un `cwd` con manifiesto, deniega. **Consecuencia:** se conserva la conducta más segura, sin código y sin gastar pasada; cambia la redacción de tu decisión 3, no su razón.
- **(B) Corregir el código** para que sea inerte en todos los casos sin `CLAUDE_PROJECT_DIR`. **Consecuencia:** menos seguro, sin ninguna ventaja; consumiría la pasada correctiva o haría falta otra.

**Recomendación de la coordinadora: (A).**

**Qué trabajo sigue mientras no se decida:** la pasada correctiva única de SEC-120 para QA-007-03 y QA-007-04, que es código independiente de este punto, y su re-verificación por QA. Seguridad (paso 3) espera a esta decisión y a esa re-verificación. Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario.


### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-I: QA-007-06 (`contrato`, baja, introducido por la pasada correctiva de SEC-120). Con la entrada estándar cerrada, los guardianes abortan sin decisión. No quedan pasadas: ¿cómo se cierra SEC-120?

**Contexto.** Re-verificación de QA de la pasada correctiva única (`413c6bd`; `docs/qa/REQ-007.md`, «SEC-120: re-verificación de la pasada correctiva»; evidencia `qa2/`, commit `6d71b19`).
- **Conforme:**
  - QA-007-03 y QA-007-04, reparados y cerrados;
  - 456 filas de ataque sin ningún movimiento de `deny` a `allow`, y 34 movimientos de «sin decisión» a `deny`, todos en las formas reparadas;
  - sin falsos positivos;
  - los hooks que no son guardianes, idénticos a v1.35.0;
  - inventario 2 (a) sólo con un INCONCLUSO de reloj (2 (c));
  - banco 2153/0/13, autoprueba 117/0, gates rc 0;
  - +0 procesos en el camino común.
- **QA-007-06:** `bash guard.sh <&-` → `lib.sh: line 37: ARNES_INPUT: unbound variable`, rc 1 y sin decisión, en los cuatro guardianes. v1.35.0 y `aba1c9b` salían con rc 0, también sin decisión, así que **ninguna decisión cambia**. No es alcanzable desde el host en lo observado.
  - **Causa:** `read` falla y no asigna; con `guardian` el preludio ya no sale antes, y `set -u` corta.
  - **Por qué es `contrato`:** el punto 20 promete `deny` cuando la entrada no se puede leer «por cualquier causa».
- **Presupuesto:** la única pasada correctiva del plan de SEC-120 está gastada (§6: agotado el tope, se cierra con el residual declarado o se escala).

**Pregunta.** ¿Cómo se trata QA-007-06?

**Opciones.**
- **(A) Una pasada más, sólo para QA-007-06**, más su re-verificación por QA. La reparación es de una línea: inicializar la variable o tratar el fallo de `read` como entrada ilegible. **Consecuencia:** de 30 a 60 minutos; excede el plan.
- **(B) Cerrar SEC-120 con QA-007-06 como residual declarado** y repararlo dentro de SEC-127 (paso 5), que es una intervención corta sobre `hooks/lib.sh` con desarrollador, QA y seguridad, y que va antes de publicar. **Consecuencia:** no se abre ningún ciclo nuevo y se repara antes de la publicación; SEC-120 pasa a seguridad con este residual escrito.
- **(C) Declararlo límite permanente** (entrada estándar cerrada → sin decisión, como en v1.35.0), con write-back del analista en el punto 20. **Consecuencia:** cero código, pero el punto 20 deja de prometer «por cualquier causa».

**Recomendación de la coordinadora: (B).** Ninguna decisión cambia, no se alcanza desde el host, y SEC-127 ya toca el mismo archivo con su propio ciclo completo antes de publicar.

**Qué trabajo sigue mientras no se decida:** ninguno del plan. La seguridad de SEC-120 (paso 3) espera a esta decisión y a P-136-H, porque QA no es favorable sin una de ellas. Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario. **Agrupada con P-136-H**, que está arriba.

### RESUELTA (propietario, 2026-10-05, posterior a `d2880c1`) — **Ajuste de alcance de 1.36.0**: SEC-127 se repara sola, entre SEC-120 y SEC-115/118; la 2b de CA-54 sale a 1.37 como ficha; orden final de 1.36.0 en siete pasos; nada más entra

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Ajuste de alcance (decisión del propietario; sustituye d2880c1 en la
> ubicación de SEC-127):
> - SEC-127 se repara SOLO, como intervención corta, con las mismas cuatro
>   condiciones ya registradas. Va después del commit validado de SEC-120 y
>   antes de SEC-115/118.
> - La 2b de CA-54 sale de 1.36.0 y pasa a 1.37 como ficha. CA-54 queda
>   cerrado con QA-007-01 como límite declarado y la medición de seguridad
>   sobre la recursión (hasta 2040 niveles) como evidencia.
> - Orden final de 1.36.0: 1) write-back SEC-120, 2) QA, 3) seguridad,
>   4) commit validado, 5) SEC-127, 6) SEC-115/118, 7) cierre y publicación.
>   Nada más entra; lo nuevo se registra como ficha.
> Registra el ajuste en la cola, en docs/PLAN.md y en ESTADO, y confírmame el
> orden.

**Lo que añade la coordinadora, rotulado como suyo:** sustituye la ubicación de SEC-127 de P-136-G, que la ponía dentro de la 2b. Sus cuatro condiciones siguen tal cual. Va en `docs/PLAN.md` § 1.36.0 (la 2b pasa a una fila «sale a 1.37») y en ESTADO. Las fichas F-136-5 (recursión) y la de M0/MD quedan con destino 1.37 en `docs/PENDIENTES.md`. La cola sigue vacía.

### RESUELTA (propietario, 2026-10-05) — **P-136-G (SEC-127): opción (A), dentro de la 2b de CA-54** (o sola antes de publicar si la 2b se retrasa); sin subshell; QA con caso de banco del locale tras el atajo y del cierre TERMINÉ/terminé; seguridad reclasifica al cerrar; la premisa de versión de bash NO se declara como límite

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-G (SEC-127): opción (A), en la intervención 2b de CA-54, que ya toca
> ese código. Si la 2b se retrasa más allá de la publicación de 1.36.0, (A) va
> sola antes de publicar.
>
> Condiciones:
> 1. La asignación de locale del atajo no puede persistir en ningún bash. Se
>    hace SIN subshell (un subshell es un proceso, y el camino común sigue en
>    0 procesos añadidos): con `local LC_ALL=C` dentro de la función que lo
>    necesita, o guardando y restaurando el valor explícitamente. El
>    desarrollador elige entre esas dos.
> 2. QA lo verifica con un caso de banco que lea el locale del proceso DESPUÉS
>    del atajo y con el cierre de un REQ con estado no ASCII (TERMINÉ /
>    terminé) en LC_ALL=C simulado, que es el que pasó de deny a allow.
> 3. Seguridad reclasifica SEC-127 al cerrarlo. Hasta entonces la publicación
>    de 1.36.0 queda en mi mano, como ya está.
> 4. La premisa "bash 5.1+ o sin modo POSIX" NO se declara como límite: se
>    repara, y punto. Que CA-47 no dependa de la versión de bash.

**Lo que añade la coordinadora, rotulado como suyo:** se escribe en `docs/PLAN.md` § 1.36.0, fila 2b. Cuando se abra la 2b, su plan (`templates/autorizacion.md`) incluye estas condiciones tal cual. La cola queda vacía.

### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-G: SEC-127 (`contrato`, baja; R-052). Con bash 5.0 o anterior en modo POSIX, el atajo de `guard-completado` podría dejar el recorrido de destinos en locale C y un cierre con estado no ASCII pasaría. ¿Se repara, se declara la premisa como límite o se mide?

**Contexto.** Fase 4 de la décima autorización, R-052 (`docs/seguridad/registro-seguridad.md`), sobre el código de `82ceb63`. **Determinación: con hallazgos, sin veto.**
- **Conforme:**
  - el atajo equivale a la regla, con la muestra del auditor (200 ejecuciones) y las 3 600 de QA;
  - el análisis compartido no reutiliza nada de otra entrada;
  - no hay recursión: hasta 2 040 niveles, `deny` y rc 0 con pilas de 8 192, 1 024 y 256 KiB;
  - QA-007-01 encaja como límite: decisión idéntica, y el delta **reduce** la exposición a SEC-115.
- **SEC-127:**
  - el atajo pone `LC_ALL=C` delante de una llamada a función en el proceso que juzga;
  - en bash 5.1 o posterior esa asignación se restaura (medido en 5.3.9, con y sin modo POSIX);
  - en **bash 5.0 o anterior en modo POSIX** persiste (NEWS de bash-5.1, punto «o»). El recorrido de destinos correría entonces en locale C, donde GNU `grep -i` no casa `TERMINÉ` con `terminé`, mientras el lector pasa el valor a minúsculas: ese cierre pasaría.
  - **No reproducido:** sólo hay bash 5.3.9 en este anfitrión. Se simuló con el entorno en `LC_ALL=C` (`deny` → `allow`; `seg-R052/94-`).
  - v1.35.0 no tenía esa forma.
- **Alcance (§6, regla 2):**
  - impide **cerrar** REQ-007 (clase `contrato`);
  - **publicar** 1.36.0 no puede hacerse por delegación mientras siga abierto: vuelve al propietario. El auditor no lo veta;
  - no impide implementar, probar ni SEC-120.

**Pregunta.** ¿Qué se hace con SEC-127?

**Opciones.**
- **(A) Repararlo** en una intervención acotada:
  - el `desarrollador` hace que la asignación de locale no pueda persistir en ningún bash (por ejemplo, en un subshell o con `local`, sin procesos añadidos en el camino común);
  - QA la verifica, con un caso de banco que fije el locale del proceso tras el atajo;
  - seguridad la cierra.
  - **Consecuencia:** coste pequeño, de una intervención corta; puede ir junto a la 2b o antes de publicar.
- **(B) Declarar la premisa como límite:** el hook requiere bash 5.1 o posterior, o no arrancar en modo POSIX. El analista la escribe en el contrato y en la guía.
  - **Consecuencia:** cero código; un consumidor con bash 5.0 en modo POSIX quedaría expuesto. El hallazgo sigue `contrato` hasta que el auditor lo reclasifique.
- **(C) Medirlo primero** en un bash 5.0 en modo POSIX (contenedor o compilación local). Si v1.35.0 tampoco deniega en ese modo, el hallazgo se cierra.
  - **Consecuencia:** coste de montar ese bash; la medición decide entre (A) y el cierre.

**Recomendación de la coordinadora: (A), dentro de la intervención 2b,** que ya toca este código. Es la reparación barata y elimina la dependencia de la versión de bash. Si la 2b se retrasa más allá de la publicación, (A) va sola antes de publicar.

**Qué trabajo sigue mientras no se decida:** **SEC-120 (intervención 2), que no depende de esta decisión**, ya está autorizada por delegación y vence el 2026-10-29. Esta entrada impide marcar cualquier REQ como `completado`.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-05, posterior a `0c31cdd`) — **SEC-120: los tres puntos abiertos de la fase 2** («0 procesos añadidos» rige sobre el camino común; ilegible = todo lo que no sea exactamente un objeto JSON; sin `CLAUDE_PROJECT_DIR` sigue inerte, como límite declarado); **orden al volver los créditos, sin pedir autorización**: QA, seguridad, commit validado, 2b de CA-54, SEC-115/118

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisiones del propietario, SEC-120:
>
> 1. Procesos. "0 procesos añadidos" rige sobre el CAMINO COMÚN: toda entrada
>    legible cuesta lo mismo que en v1.35.0. En una entrada ilegible el hook
>    antes no decidía y ahora emite deny: el jq que emite esa decisión es el
>    coste de decidir, no un proceso añadido al análisis. CA-47 punto 20 lo
>    dice así, con las dos cifras medidas (normal: +0; ilegible: +1). No es
>    incumplimiento de contrato.
> 2. Qué es ilegible. Confirmo la lectura del desarrollador: todo lo que no sea
>    exactamente un objeto JSON (null, número, vacío, dos objetos seguidos).
>    Fail-closed; es el principio del arnés.
> 3. Sin CLAUDE_PROJECT_DIR el hook sigue inerte, como en v1.35.0: denegar ahí
>    rompería proyectos que no usan el arnés. Se declara como límite en el
>    punto 20.
>
> Al volver los créditos: QA en comisión nueva, seguridad con QA favorable,
> commit validado, 2b de CA-54, SEC-115/118. Sin pedirme autorización.
>
> Sobre P-136-G (SEC-127): no sé qué es; pégame su texto y te doy la decisión.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Write-back:** los puntos 1 a 3 cambian el texto de REQ-007 CA-47 punto 20, y en este repositorio el write-back es del `analista-requerimientos` (`AGENTS.md` §9: §6 no declara la vía proporcional). Va **antes** de la fase 3, porque QA no firma `aprobado` sin el write-back (§9). No es una fase nueva: es la dependencia que el plan de SEC-120 ya prevé («write-back del analista sólo si hay deriva»).
- **La 2b y la intervención 3** se abren, cuando les toque, con su plan en la forma de `templates/autorizacion.md`, redactado por la coordinadora por esta delegación y calcado de la décima.
- **P-136-G** sigue en § Pendientes. Su texto se le entrega al propietario en la respuesta de esta sesión.
- **Pausa:** sin créditos de uso no se despacha a nadie.

### RESUELTA (coordinadora, por delegación expresa del propietario del 2026-10-05) — **Plan autorizado: intervención 2 de 1.36.0, SEC-120 sola** (REQ-007 CA-47 punto 20; vence el 2026-10-29)

**Fuente de la delegación:** decisión del propietario del 2026-10-05, posterior a `39e68bb`, punto 3 (literal en esta sección): «Cuando conecte: recuento de QA (10 de 30), fase 4 sobre 82ceb63, commit validado, y apertura de SEC-120 sin pedirme la autorización». También P-136-F, punto 7: «Al cerrar CA-54, abre SEC-120 sola, como dice el plan de versión». La forma es la de `templates/autorizacion.md`. **Los bloques los redacta la coordinadora calcando la décima autorización:** no añaden facultades ni quitan ninguna parada que la décima tenía.

**Propiedad (contrato vigente, REQ-007 CA-47 punto 20; no se cambia):** si `jq` no puede leer la entrada, el hook deniega a todo agente. Si no puede trocear la parte de `tool_input` que una puerta necesita, deniega esa puerta. Ninguna variable conserva el valor de una lectura anterior. Los modos inertes (sin `jq` o sin manifiesto) siguen como están. Se cumple con la comprobación del código de salida, **sin procesos nuevos**. Medida: casos de banco en la sección 44 a nivel de hook en Linux/WSL2, con los vectores V1–V4 de R-045-A §4 y fail-before contra el código del candidato (`82ceb63`) y contra v1.35.0.

> ## Plan autorizado (se ejecuta entero; cada fase termina en commit local y la siguiente empieza sin pedir permiso)
> Fase 1 — desarrollador: casos de banco de CA-47 punto 20 en la sección 44 (vectores V1–V4 de R-045-A §4), con fail-before medido sobre el código de `82ceb63` y sobre v1.35.0. Sin reparar todavía.
> Fase 2 — desarrollador: reparación por comprobación del código de salida de `jq`, con 0 procesos añadidos (`sonda-procesos.sh` más recuento exacto). Entrega: casos en verde, inventario CA-69 2 frente a `22-` con la semilla de la sección 41 fijada (sólo admite los movimientos de `allow` o «sin decisión» a `deny` que declara CA-69 3 para el punto 20, y los casos de CA-69 2 (c) e INS-136-1), banco completo, autoprueba y gates.
> Fase 3 — QA (Opus): repite los casos, el fail-before, el inventario, el banco y la autoprueba, e intenta romper la reparación. Una pasada correctiva como máximo, dentro del contador, y su re-verificación.
> Fase 4 — seguridad, sólo con QA favorable. Write-back del analista sólo si hay deriva. Commit del trabajo validado.
>
> ## Lo que decide la coordinadora sola
> Texto, trazabilidad, CHANGELOG, ESTADO e índices; ajustes del banco que no cambian ningún veredicto ni contrato; la pasada correctiva prevista; el orden y el presupuesto de cada despacho dentro del propuesto (calibrado con la intervención 1: desarrollador 300–500 k, QA 250–400 k, seguridad 150–250 k); registrar defectos nuevos sin repararlos.
>
> ## Cuándo paras y me preguntas (solo esto)
> - un cambio de contrato o de alcance;
> - aceptar o aplazar un riesgo;
> - más pasadas que la prevista;
> - un veredicto del banco que cambia: un caso que ejecuta hooks o lee archivos del delta y pasa entre PASS y FAIL, fuera de los movimientos que declara CA-69 3. Un caso de calibración de sonda que cambia se registra y se sigue;
> - **el fail-before no falla** sobre `82ceb63` ni sobre v1.35.0 (sería una pregunta de contrato: R-046 dice que `arnes_parse_input` ya vacía sus campos);
> - un control del proveedor detiene algo (se registra y se sigue con lo independiente);
> - publicar, fusionar, etiquetar o cerrar un REQ.
>
> ## Si la sesión se corta
> La siguiente lee este plan en la cola y en ESTADO, y continúa desde la última fase comiteada. No vuelve a pedir la autorización: ya está dada.
>
> ## Límites
> Nada fuera de SEC-120 en esta intervención: ni SEC-127 (P-136-G), ni la 2b, ni SEC-115/118; se registran. No `AGENTS.md` ni contadores. No push, versión, PR, fusión ni tag.

**Lo que añade la coordinadora:** la base es el código del candidato (`hooks/` = `82ceb63`). P-136-G (SEC-127) sigue pendiente en la cola y no depende de este plan.

### RESUELTA (propietario, 2026-10-05, posterior a `39e68bb`) — **M0 y MD como límite declarado «sin cifra sobre 82ceb63»; QA-007-01 sigue como `contrato`; impedimento de red del anfitrión; al conectar, se sigue sin pedir autorización hasta abrir SEC-120**

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> Decisiones del propietario:
> 1. M0 y MD: límite declarado «sin cifra sobre 82ceb63»; se miden en la
>    intervención 2b, en anfitrión sano, antes de cualquier optimización.
> 2. QA-007-01 mantiene la clase `contrato` hasta que QA decida; REQ-007 no se
>    cerraba en esta intervención.
> 3. El impedimento de red (Zscaler 403) se registra como del anfitrión, no
>    del proveedor ni del arnés. Cuando conecte: recuento de QA (10 de 30),
>    fase 4 sobre 82ceb63, commit validado, y apertura de SEC-120 sin pedirme
>    la autorización.

**Lo que añade la coordinadora, rotulado como suyo:** el punto 1 se escribe en `docs/PLAN.md` § 1.36.0, fila 2b. El punto 3 queda en ESTADO como el orden de reanudación. La cola sigue vacía.

### RESUELTA (propietario, 2026-10-05) — **P-136-F: opción (C)**: el candidato de CA-54 es `82ceb63` (se revierte `dee5932`); QA-007-02 cerrado por reversión con ficha de la recursión; QA-007-01 como límite declarado; fase 4 sobre `82ceb63`; segunda pasada como intervención 2b después de SEC-120

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-F: opción (C), así:
>
> 1. El candidato de CA-54 es 82ceb63. Revierte el código de dee5932 (git
>    revert, conservando el registro de la pasada y de QA-007-02 como historia).
>    Comprueba que tras el revert hooks/ es byte a byte igual a 82ceb63.
> 2. QA-007-02 queda CERRADO POR REVERSIÓN en el candidato, y abre una ficha
>    de 1.36.0 (instrumento, alta): «la lectura léxica de rutas es recursiva
>    por segmento y sin tope». Antes de cualquier intervención que la toque,
>    el banco recibe primero el caso de destinos profundos (≈1500 niveles,
>    < 3 KB) con fail-before, y la propiedad es: toda ruta por debajo del
>    límite de entrada recibe una decisión; ninguna mata al hook.
> 3. QA-007-01 queda como LÍMITE DECLARADO del candidato: CA-54 se cumple en
>    su medición (las 35 corridas), y las formas que QA añadió (sus casos M/N,
>    un proyecto sin globs de código, el desarrollador con primer destino en
>    código) quedan fuera del criterio y escritas en las notas. La medición
>    en anfitrión degradado se registra como tal, no se repite.
> 4. El bloqueo del proveedor sobre QA (locales GB18030/BIG5, leído como rm
>    sin haberlo) se registra; no se reintenta. El ataque de equivalencia
>    sobre 82ceb63 vale el que ya se hizo; el que faltaba era sobre dee5932,
>    que ya no existe.
> 5. Fase 4: seguridad sobre 82ceb63 con el veredicto de QA «con hallazgos:
>    QA-007-01 declarado como límite». Commit validado.
> 6. Segunda pasada de CA-54 (cubrir QA-007-01 y la recursión): intervención
>    nueva, DESPUÉS de SEC-120, que tiene fecha. Se registra en el plan de
>    versión como intervención 2b.
> 7. Al cerrar CA-54, abre SEC-120 sola, como dice el plan de versión.
>
> Presupuesto: registra el gasto real (dev 673k, QA 425k, analista 750k) frente
> al propuesto; es dato para calibrar el siguiente, no un reproche.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Alcance de la reversión, comprobado:** `git diff --stat 82ceb63 dee5932^ -- hooks tools tests` está vacío. Entre `82ceb63` y la pasada sólo hubo registro, así que revertir el código de `dee5932` devuelve `hooks/` a `82ceb63`. `dee5932` toca `hooks/guard-codigo.sh`, `hooks/guard-completado.sh` y `hooks/lib.sh`, más `docs/arnes/v1.36.0-ca54-fase2.md` y `CHANGELOG.md`, que se conservan como historia. La reversión la hace el `desarrollador`, porque `hooks/` está protegido.
- **«El plan de versión» no existía como documento.** La sección `## 1.36.0` de `docs/PLAN.md` era una planificación antigua («el working set explícito»). La coordinadora escribe allí, fechado, el plan vigente de 1.36.0 según las decisiones del propietario (2026-10-03 y esta): intervención 1 CA-54, intervención 2 SEC-120 sola, intervención 2b la segunda pasada de CA-54, intervención 3 SEC-115/SEC-118. Lo antiguo queda debajo como historia.
- **Qué trabajo sigue:** la reversión (desarrollador); el write-back del analista (QA-007-02 cerrado por reversión, QA-007-01 como límite declarado en CA-54, la ficha de la recursión); la seguridad sobre `82ceb63`; el commit validado; y abrir SEC-120 con su autorización en la forma de `templates/autorizacion.md`. La cola queda vacía.

### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-F: la pasada correctiva única introdujo un fallo en abierto (QA-007-02, `contrato`, alta) y no cerró QA-007-01; el plan está parado. ¿Se revierte la pasada, se autoriza otra o ambas cosas?

**Contexto.** Re-verificación de QA (Opus) sobre `dee5932` (cabeza validada `787d04d`; registro en `docs/qa/REQ-007.md`, «Re-verificación de la pasada correctiva (QA-007-01)»; evidencia `cand-1.36.0/ca54/qa/`, commit `a6f5b32`).
- **QA-007-02 (`contrato`, alta, NUEVO, lo introduce la pasada):**
  - un destino de `Bash` con `..` y unos 1 500 niveles (≈ 3 KB, por debajo de `ARNES_ID_MAX`) hace que el hook muera por **SIGSEGV** (rc 139, sin decisión): `_arnes_lectura_lexica` recurre por segmento, sin tope;
  - con ese destino delante, la coordinadora escribe en `src/a.ts` y un REQ se cierra por `sed -i`. **v1.35.0 y `82ceb63` lo deniegan;**
  - umbral entre 1 400 y 1 500 niveles con `ulimit -s` de 8 MiB;
  - el banco no tiene ningún caso con destinos profundos. Reproducción mínima en `qa/segv/70-` a `74-`.
  - **Exposición:** ninguna fuera de este worktree. El código está sólo en commits locales de `cand/1.36.0`, sin push, y la instalación estable es 1.35.0.
- **QA-007-01 (`contrato`, media) sigue abierto,** aunque **el anfitrión se degradó durante la medición** desde las 14:26: v1.35.0 tardó hasta 4 veces más que por la mañana y el testigo de bash puro osciló entre 190 y 1 341 ms. QA registró los FAIL con su carga y no los repitió.
  - Con esa degradación, 9 de 35 corridas de «Medida» llegan a 5 s, y 38 de 45 en M, N y MR.
  - **Dos formas que la pasada no ataca por construcción:** M0 (proyecto sin globs de código) y MD (el desarrollador con su primer destino en código).
- **Conforme:**
  - 0 procesos añadidos;
  - inventario con sólo dos líneas de CA-69 2 (c); ningún caso que ejecute hooks cambia entre PASS y FAIL;
  - banco 2037/0/13; autoprueba 117/0; gates rc 0.
- **Control del proveedor:** detuvo a QA al construir los locales GB18030 y BIG5. Lo marcó como un `bash -c` que ejecuta `rm`, y el comando no contenía ningún `rm`. **No se reintentó.** Por eso queda **sin ejecutar el ataque de equivalencia sobre `dee5932`** (preparado en `qa/eq/eq3.sh`).
- **La fase 4 (seguridad) no se despachó:** no hay QA favorable.
- **Presupuesto del plan:** la única pasada correctiva está gastada (AGENTS.md §6, regla 5; el contador no se reinicia).

**Pregunta.** ¿Qué se hace con el candidato y con CA-54?

**Opciones.**
- **(A) Revertir la pasada correctiva y volver al código de `82ceb63`, que no tiene QA-007-02.** QA-007-01 queda abierto con alcance, como límite declarado: las 35 corridas de «Medida» cumplen, M y N no. La fase 4 se hace sobre `82ceb63`.
  - **Consecuencia:** es lo más seguro y lo más barato. La reversión la hace el `desarrollador` (`hooks/` está protegido) y QA comprueba que el árbol queda igual a `82ceb63`. CA-54 queda acreditado sólo para el instrumento, no para la propiedad.
- **(B) Autorizar una segunda pasada correctiva.** Se excede el plan y el contador sigue sin reiniciarse.
  - Repararía QA-007-02 por propiedad: ningún destino por debajo de `ARNES_ID_MAX` puede dejar el hook sin decisión, y se añade un caso de banco con destinos profundos, con su fail-before contra `dee5932`. También cubriría M0 y MD.
  - Después, QA re-verifica **en un anfitrión sano**, incluido el ataque de equivalencia, sin GB18030/BIG5 si el proveedor vuelve a bloquear su construcción.
  - **Consecuencia:** coste estimado de 200 a 400 k tokens para el desarrollador y de 250 a 300 k para QA. Puede volver a quedar corta.
- **(C) (A) ahora y (B) después, como intervención nueva:** el candidato queda seguro hoy, y la segunda pasada parte de `82ceb63` con su propia autorización y su plan.

**Recomendación de la coordinadora: (C).** QA-007-02 es un fallo en abierto de alta severidad, y el árbol del candidato no debe quedarse con él mientras se decide lo demás. Revertir cuesta poco y devuelve el candidato a un código cuyas decisiones están verificadas: 6 148 ejecuciones idénticas a v1.35.0. La segunda pasada merece su propio plan, con el caso de banco de destinos profundos por delante y una medición en un anfitrión sano.

**Qué trabajo sigue mientras no se decida.** **Ninguno del plan.** Fuera del plan no se abre nada. Esta entrada impide marcar cualquier REQ como `completado` (ninguno se iba a cerrar).

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-05) — **P-136-E: opción (A)**; los tres casos de calibración son hallazgo `instrumento`, no atribuible al cambio; regla de parada afinada («un veredicto del banco que cambia» = un caso que ejecuta hooks o lee archivos del delta); ficha nueva de REQ-021

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-E: opción (A). Los tres casos (REQ-021 CA-03, CA-10 y CA-10.2) se
> registran como hallazgo `instrumento`, no atribuible al cambio, con la prueba
> estática (la calibración no ejecuta hooks) y la corroboración: ayer fallaron
> los mismos tres en WSL con el banco entero y pasaron solos en la sección 38
> (docs/qa/REQ-023.md, validación manual), y en el CI dos corridas rojas en dos
> sondas de reloj distintas y la tercera verde.
>
> Afino la regla de parada de esta autorización, y que la plantilla lo recoja:
> «un veredicto del banco que cambia» = un caso que ejecuta hooks o lee archivos
> del delta. Un caso de calibración de sonda que cambia se registra y se sigue.
>
> Ficha nueva, para después (REQ-021, instrumento): una calibración de
> sonda-reloj fuera de banda sale FAIL; según la propia filosofía del banco
> debería abstenerse (SKIP o INCONCLUSO con motivo), como ya hace la sonda que
> no converge. No se repara en esta intervención.
>
> Continúa: commits del desarrollador, banco, autoprueba y gates; verificación
> de QA con su propio inventario; fase 4 con QA favorable. No me preguntes
> hasta QA, salvo por un cambio de veredicto en un caso que sí ejecuta hooks.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Registro:** hallazgo `instrumento` **INS-136-1** y ficha **F-136-4** (REQ-021) en `docs/PENDIENTES.md`; la regla afinada, en el bloque «Cuándo paras» de `templates/autorizacion.md` (como guía para cualquier autorización) y en su ejemplo (como precisión fechada de la décima). La décima autorización se lee, desde hoy, con esta regla de parada.
- **Qué trabajo sigue:** el plan. Primero el desarrollador comitea y corre el banco, la autoprueba y las gates; después QA re-verifica con su propio inventario; después la fase 4, con QA favorable. La cola queda vacía.

### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-05] (coordinadora) — P-136-E: la pasada correctiva de QA-007-01 cumple los tiempos, pero el inventario cambia en 3 casos de calibración del reloj (PASS → FAIL) que no ejecutan los hooks; ¿cómo se trata?

**Contexto.** Décima autorización, pasada correctiva 1 de 1, sobre `488cd8e`, con el código **sin comitear** (copia: `cand-1.36.0/ca54/50-pasada-correctiva-sin-commit.patch`, sha256 `d9d62a06…`, en el árbol de evidencia, sin commit allí).
- **Tiempos, medidos por el desarrollador:**
  - 35 de 35 corridas de S1/S2 por debajo de 5 s (máx. 4 011 ms);
  - 45 de 45 corridas de los casos M, N y MR de QA por debajo de 5 s (máx. 4 713 ms);
  - decisiones idénticas a v1.35.0 y 0 procesos añadidos.
- **Inventario con `ARNES_SEMILLA_41=23062`** frente a `22-` (`42-diff-inventarios.txt`; el banco dio 2036/3/11):
  - **3 casos PASS → FAIL:** REQ-021 CA-03 «calibración de `sonda-reloj.sh`» (`a=2487`, banda [1600, 2400]), REQ-021 CA-10 (el juez) y REQ-021 CA-10.2. Los dos últimos heredan esa calibración;
  - 1 caso de CA-69 2 (c) (REQ-017 CA-08 (ii), 6 líneas: INCONCLUSO → PASS), que no acredita.
- **Comprobado por la coordinadora leyendo el disco, sin ejecutar nada:**
  - la calibración la hace `tests/util/sonda-reloj.sh --calibrar` sobre un sujeto propio de bash, y la juzga `sonda_juzga_calibracion` (`run.sh` l. 1105);
  - `grep` de `HOOKS_DIR`, `guard.sh` y `lib.sh` en `sonda-reloj.sh` y `sonda-procesos.sh` no devuelve nada: **esa calibración no ejecuta los hooks**, así que el cambio de código no puede alterarla;
  - el propio `sonda-reloj.sh` documenta calibraciones fuera de banda con la máquina en reposo (l. ~67).
- **No se repitió nada:** ni la corrida, ni el banco del worktree, ni la autoprueba. Repetir hasta el verde no desmiente un FAIL.

**Pregunta.** La regla de parada «un veredicto del banco que cambia» se disparó en casos que no dependen del código cambiado. ¿Cómo se cierra la pasada?

**Opciones.**
- **(A) Declararlos `instrumento`, no atribuibles al cambio, con la prueba estática de arriba, y seguir.** El desarrollador comitea y corre el banco del worktree, la autoprueba y las gates. Después, **QA re-verifica con su propio inventario**, una observación independiente y no una repetición del desarrollador. Si QA ve un cambio de veredicto en un caso que **sí** ejecuta hooks, se para.
  - **Consecuencia:** queda registrado un hallazgo `instrumento` (la calibración del reloj es sensible a la carga), con dueño, sin reparar en esta intervención. El inventario del desarrollador no acredita «idéntico»; lo acredita el de QA.
- **(B) Una sola repetición del inventario, declarada antes de correrla, con el resultado aceptado sea cual sea.** Si los 3 casos vuelven a PASS, se sigue como en (A). Si siguen en FAIL, se vuelve a parar.
  - **Consecuencia:** unos 3 minutos de banco. Se parece a repetir buscando el verde, aunque el resultado esté comprometido de antemano.
- **(C) Caracterizar el instrumento:** correr la sección 38 contra los hooks de **v1.35.0**, N veces y con una carga parecida, para medir cuántas veces falla la calibración sin el cambio. Después, (A).
  - **Consecuencia:** es la evidencia más fuerte de que no es regresión. Cuesta de 30 a 60 minutos de banco y una comisión corta.

**Recomendación de la coordinadora: (A).** La prueba estática es concluyente para estos tres casos: un instrumento que no ejecuta los hooks no puede cambiar porque los hooks cambien. La re-verificación de QA, que ya está en el plan, vuelve a observar el inventario entero sin que nadie elija la corrida.

**Qué trabajo sigue mientras no se decida.** **Ninguno del plan.** La pasada correctiva, la re-verificación de QA y la fase 4 dependen de esta decisión. Esta entrada impide marcar cualquier REQ como `completado` (ninguno se iba a cerrar).

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-05) — **P-136-D: opción (A) con condición de equivalencia**; semilla de la sección 41 fijada; fichas de instrumento; el plan de la décima autorización continúa desde la fase 2

**Texto del propietario, literal** (mensaje del 2026-10-05 a la sesión coordinadora del worktree `ArnesJuan-v1.36`):

> P-136-D: opción (A), con una condición de equivalencia que es parte de la
> decisión, no una sugerencia:
>
> 1. El atajo de guard-completado puede omitir el RECORRIDO DE DESTINOS cuando
>    el comando entero no menciona el estado terminal. No puede omitir el
>    análisis del comando ni ninguna denegación por forma que guard-completado
>    emite sin mirar destinos: presupuesto (ARNES_RC_EXCESO), CR del
>    delimitador (ARNES_RC_CR), SEC-124 (ARNES_RC_CUERPO_CR) y LC10
>    (ARNES_RC_LC10). Esas salen antes del atajo, exactamente como en v1.35.0.
> 2. Prueba: inventario del banco caso a caso idéntico al de referencia
>    (2050 líneas, f35c9c04…), con la semilla de la sección 41 fijada. Si
>    difiere en una sola línea, el atajo está mal colocado y se corrige; no se
>    cambia el veredicto.
> 3. Contrato: el analista aclara CA-54 (c) así: «comprobar primero una
>    condición necesaria de una regla, leyendo la entrada entera, no es
>    analizar menos, siempre que ninguna denegación que no dependa de esa
>    condición deje de emitirse». Ni más ni menos.
> 4. QA ataca la equivalencia: las filas HC5a, HC9.6 y LC10.1–LC10.9 por
>    guard-completado explícitamente, los locales en_US y tr_TR, y un comando
>    que mencione el estado terminal con destino fuera de requirements/.
> 5. Presupuesto: acepto el exceso del desarrollador (586k) como registrado;
>    la pasada correctiva de esta intervención sigue siendo una.
>
> Defectos registrados: la semilla de la sección 41 se fija ahora (ajuste del
> banco sin cambio de veredicto: lo decides tú). sonda-procesos y la columna
> vacía de S2 quedan como fichas. Las dos ediciones de hooks/ por consola:
> registrarlo como hallazgo de proceso (instrumento), sin reparar en esta
> intervención.
>
> Continúa el plan desde la fase 2 con lo de arriba; no me preguntes hasta QA.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Semilla de la sección 41 (decisión que el propietario delega en la coordinadora):** se fija **en la invocación** de las comparaciones de inventario (`ARNES_SEMILLA_41` igual a la semilla que registra la referencia, `23062` en `22-inventario-v1.35.0.txt`), y la precisión se escribe en CA-69 2 (a). **El banco no cambia:** fijar el valor por defecto dentro de la sección 41 quitaría el sorteo de entradas, que es lo que ese caso ejerce, y eso sí cambiaría lo que mide.
- **Orden:** primero el analista, con la aclaración de (c), la precisión de CA-69 2 (a) y las fichas; después el desarrollador, que cierra la fase 2. Van en serie porque son el mismo REQ.
- **Qué trabajo sigue:** el plan, fase 2. La cola queda vacía.

### RESUELTA (propietario, 2026-10-05; entrada de arriba) — [2026-10-03] (coordinadora) — P-136-D: CA-54 sin el atajo de `guard-completado` deja 1 de 35 corridas en 5 213 ms; ¿se readmite el atajo aclarando CA-54 (c), se sigue optimizando o se acepta?

**Contexto.** Décima autorización, fase 2 (CA-54), sobre `4b4f239` con el código **sin comitear** en el worktree. Las copias del parche están en el árbol de evidencia, `cand-1.36.0/ca54/`: `50-candidato-fase2-sin-atajo-sin-commit.patch`, y la variante con atajo en `con-atajo-retirado/`.
- **Con el atajo:** 0 de 35 corridas ≥ 5 000 ms. El peor caso es 3 811 ms (S1 C).
- **Sin el atajo:** 34 de 35. **S1 B, tercera corrida: 5 213 ms**; el resto de S1 está entre 3,8 y 4,3 s.
- **En las dos variantes:**
  - las decisiones, los rc, y los `bytes=` y `destinos=` son iguales a v1.35.0 en las 35 corridas;
  - stdout, rc y stderr son idénticos byte a byte en 10 de 10 entradas;
  - 0 procesos añadidos con `sonda-procesos.sh`, y uno menos en S1 con el recuento exacto complementario.
- **Qué es el atajo:** la regla de `guard-completado` por `Bash` deniega sólo si un destino cae en `requirements/` **y** el estado terminal aparece en el comando. El atajo comprueba primero la segunda condición, sobre el **comando entero** y sin proceso, y si es falsa no recorre los destinos: la regla no podría denegar. Los destinos los sigue juzgando `guard-codigo` enteros.
- **Por qué se retiró:** CA-54 (c) prohíbe «analizar menos de la entrada» y nombra «omitir destinos» como ejemplo no exhaustivo. La coordinadora no valida sobre una lectura discutible del texto.
- **Medido por el desarrollador con el atajo:** 102 000 pares por locale contra `grep` real, 0 violaciones. Sin medir: los locales `en_US` y `tr_TR`, que no están instalados.
- **No se repitieron corridas buscando verde.** Un FAIL no se desmiente repitiendo.

**Pregunta.** ¿Cómo se cumple CA-54?

**Opciones.**
- **(A) Readmitir el atajo, aclarando CA-54 (c).** El `analista-requerimientos` versiona (c) con una nota: no es «analizar menos» evaluar primero una condición necesaria de una regla, **sobre la entrada entera**, cuando prueba que la decisión no puede cambiar. Sí sigue prohibido no juzgar destinos en la puerta que los juzga (`guard-codigo`).
  - **Consecuencia:** margen de ≈ 1,2 s sobre el umbral. QA ataca expresamente la equivalencia (locales, mayúsculas no ASCII, el estado mencionado de formas que `grep` encuentra). Es un cambio de contrato menor con Historial, y sigue el plan sin más optimización.
- **(B) Sin el atajo; el desarrollador optimiza más**, dentro de (c) y con 0 procesos.
  - **Consecuencia:** no se sabe si cabe. Coste estimado de 150 a 300 k tokens más. Si no cabe, se vuelve a esta pregunta.
- **(C) Sin el atajo y aceptar 34 de 35 con alcance**, como en 1.35.0.
  - **Consecuencia:** CA-54 no se cumple. Sería aceptar un riesgo y cambiar el criterio («cada una de las 35»), y QA-023-10 sigue abierto.

**Recomendación de la coordinadora: (A).** El atajo no deja ninguna parte de la entrada sin leer: lee todo el comando para decidir que la regla no puede denegar, y la puerta que juzga los destinos los sigue juzgando todos. Es la única opción con margen medido. La equivalencia ya tiene evidencia diferencial, y QA tiene que intentar romperla, empezando por los locales no medidos.

**Qué trabajo sigue mientras no se decida.** **Ninguno del plan:** las fases 2 a 4 dependen de esta decisión. Fuera del plan no se abre nada. Esta entrada impide marcar cualquier REQ como `completado` (ninguno se iba a cerrar en esta intervención).

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-03, décima autorización) — **Fichas P-136-A/B/C resueltas; plantilla de autorización; PLAN AUTORIZADO VIGENTE «décima autorización», CA-54 en fases 0 a 4**

**Texto del propietario, literal** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.36`, tras reiniciar con 1.35.0):

> `JJOVEGA/ArnesJuan`, worktree `/home/juan/dev/ArnesJuan-v1.36`, rama
> `cand/1.36.0`, cabeza reportada `4b4138f`, hooks 1.35.0 ya vigentes tras el
> reinicio. Décima autorización: fichas, plantilla de autorización y primera
> intervención de CA-54.
>
> ## Decisiones del propietario (registrar literales; cierran las fichas)
> - P-136-A: 0 procesos añadidos.
> - P-136-B: criterio por propiedad: toda denegación decidida llega al cliente,
>   entera o acotada, nunca perdida; el desarrollador elige la técnica; los
>   avisos entran.
> - P-136-C: techos de tamaño más plazo propio de 40 s, sin procesos.
> - CA-68 / REQ-017 CA-09: se evalúa al construir SEC-115; si afecta, §9.
> - Las paradas entre fases de un plan autorizado son un defecto de proceso.
>   Desde esta autorización, toda autorización lleva los cuatro bloques de
>   abajo, la plantilla se guarda en templates/autorizacion.md (referida desde
>   la guía y la cola), y ESTADO lleva en su bloque manual «Plan autorizado
>   vigente: <id>, fase N de M, siguiente acción: …» mientras haya uno. El
>   campo derivado queda como ficha de 1.36.0.
>
> ## Plan autorizado (se ejecuta entero; cada fase termina en commit local y
> ## la siguiente empieza sin pedir permiso)
> Fase 0 — analista: plantilla templates/autorizacion.md con los cuatro
>   bloques y esta autorización como ejemplo; ficha del campo derivado;
>   enlaces; filas de REQ-001 y REQ-031 del índice al día; registro de las
>   decisiones. Línea de plan vigente en ESTADO.
> Fase 1 — desarrollador: restaura las dos sondas de CA-54 sin cambiar su
>   medición (solo la ruta de la biblioteca), registra el diff; toma la línea
>   base sobre v1.35.0 (las 35 corridas); inventario.sh del banco con los hooks
>   de v1.35.0 como referencia caso a caso. Sin optimizar todavía.
> Fase 2 — desarrollador: optimiza arnes_bash_sin_texto y lo que haga falta
>   para < 5 s con 131072 bytes en Linux/WSL2, con 0 procesos añadidos, sin
>   cambiar umbral, máximo ni medición. Entrega: las 35 corridas, inventario
>   idéntico caso a caso al de la fase 1, banco completo y autoprueba.
> Fase 3 — QA (Opus): repite las 35 corridas, compara inventarios, banco y
>   autoprueba, intenta romper la optimización. Una pasada correctiva como
>   máximo, dentro del contador, y su re-verificación.
> Fase 4 — seguridad, solo con QA favorable. Write-back del analista solo si
>   hay deriva. Commit del trabajo validado.
>
> ## Lo que decide la coordinadora sola
> Texto, trazabilidad, CHANGELOG, ESTADO, índices; ajustes del banco que no
> cambian ningún veredicto ni contrato; la pasada correctiva prevista; orden
> y presupuesto de cada despacho dentro del propuesto (~300–400k dev, 250–300k
> QA, 150–200k seguridad); registrar defectos nuevos sin repararlos.
>
> ## Cuándo paras y me preguntas (solo esto)
> Cambio de contrato o de alcance; aceptar o aplazar un riesgo; más pasadas
> que la prevista; un veredicto del banco que cambia (inventario distinto);
> un control del proveedor detiene algo (registra, sigue con lo
> independiente); publicar, fusionar, etiquetar, cerrar un REQ.
>
> ## Si la sesión se corta
> La siguiente lee este plan en la cola y en ESTADO y continúa desde la última
> fase comiteada. No vuelve a pedir la autorización: ya está dada.
>
> ## Límites
> No SEC-120, SEC-115/118 ni nada fuera de CA-54 en esta intervención (se
> registran). No AGENTS.md ni contadores. No push, versión, PR, fusión ni tag.
>
> ## Entrega
> Cabeza final por fase; línea base y resultado de las 35 corridas; inventario
> caso a caso (idéntico o diferencias); veredictos de QA y seguridad con su
> alcance; pendientes exactos.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Hooks 1.35.0 vigentes, comprobado tras el reinicio:** una sonda inofensiva con la forma LC10 (`cat` de un heredoc cuya línea de apertura acaba en continuación) la denegó `guard-git` con el motivo «ARNES (SEC-125, LC10)», que sólo existe desde 1.35.0. `installed_plugins.json`: 1.35.0 en los alcances `user` y `project`.
- **`/arnes-upgrade` no hace falta en este repositorio:** el contenido que migran «Hacia 1.34.0» y «Hacia 1.35.0» ya está en `AGENTS.md`, `PENDING_APPROVAL.md` y `requirements/README.md`, que se desarrollaron aquí. Sólo difiere `arnes_version` (`1.33.0`), que se conserva por decisión del propietario (`5d810f0`). Correrlo tocaría `AGENTS.md`, excluido por esta autorización.
- **Las tres fichas pasan debajo** sin cambiar su texto. **Qué trabajo sigue:** el plan de arriba, fase 0.

### RESUELTA (propietario, 2026-10-03, décima autorización; entrada de arriba) — [2026-10-03] (analista-requerimientos) — P-136-A: CA-54, ¿puede la optimización gastar procesos que v1.35.0 no gasta al analizar un comando grande?

**Contexto.** El pedido fija el reloj de CA-54: menos de 5 s en el máximo declarado, en Linux/WSL2, sin cambiar veredictos, sin subir el umbral ni reducir la entrada. `requirements/README.md`, forma (d), exige que un criterio de coste contrate **todas** las vías por las que el coste se degrada. Si no, un arreglo que compra reloj con un proceso da verde en Linux.

Hay dos caminos:
- **El camino común** (un comando sin escrituras) ya lo gobierna REQ-007 CA-59, con línea base en v1.35.0: no cambia.
- **El camino de un comando grande**, que es el que se optimiza, no tiene techo de procesos.

En Windows/MSYS cada proceso cuesta de 1,2 a 6 s (`AGENTS.md` §2). Allí CA-54 ya mide de 20,4 a 28,9 s en el máximo (`sec-ca54-win/RESULTADO.md`), sin promesa en esta ventana.

**Pregunta.** Al analizar un comando grande, ¿la optimización puede lanzar más procesos que v1.35.0?

**Opciones.**
- **(A) No: 0 procesos añadidos frente a v1.35.0**, medido con `tests/util/sonda-procesos.sh` sobre las entradas de las sondas de CA-54. Menos es conforme.
  *Consecuencia:* la optimización tiene que hacerse dentro del proceso que ya existe. Se cierra la vía de comprar reloj con un proceso, que en Windows sumaría segundos. Puede costar más llegar a menos de 5 s.
- **(B) Sí, con techo: hasta N procesos añadidos y sólo por encima de un tamaño de comando.** N y el tamaño se declaran y se miden en Linux. El camino común sigue en CA-59.
  *Consecuencia:* el desarrollador tiene más técnicas a su alcance. En Windows, cada proceso añadido suma de 1,2 a 6 s en esos comandos, y esta ventana no lo mide.
- **(C) No contratar procesos en CA-54; sólo el reloj.**
  *Consecuencia:* CA-54 queda fuera de la forma (d), y se declara. Un arreglo que compre reloj con procesos pasa en Linux y empeora Windows sin que ningún criterio lo vea.

**Recomendación del agente: (A).** Es la regla del stack («sin procesos donde se pueda») y la única que no traslada el coste a la plataforma que no se mide.

**Qué trabajo sigue mientras no se decida.** Siguen implementar y medir una optimización que **no añade procesos**: es conforme con las tres opciones. Depende de esta decisión cualquier técnica que añada procesos.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-03, décima autorización; entrada de arriba) — [2026-10-03] (analista-requerimientos) — P-136-B: CA-67 (SEC-118), ¿qué es «el tope» que se mide, y entran los avisos?

**Contexto.** El pedido dice: «fail-closed cuando … el motivo excede el tope: emitir decisión siempre; medir el tope en bytes y ASCII/multibyte en Linux».

Hoy, el motivo de una denegación viaja a `jq` como un argumento de línea de órdenes. Por encima del límite de bytes de un argumento, el hook sale sin decisión, y eso equivale a permitir. Lo medido en 1.35.0 está en `requirements/README.md` § «Clases de hallazgo» y en `docs/seguridad/registro-seguridad.md` § R-045, §4.

La remediación registrada admite dos técnicas: acotar el motivo en bytes, o sacarlo de la línea de órdenes. Con la primera hay un número que es «el tope». Con la segunda no hay tope del motivo. El pedido no dice cuál de las dos lecturas es la suya.

Además, la remediación nombra `arnes_emitir_avisos`: los avisos que no acompañan a una decisión. El pedido habla de «decisión».

**Preguntas.** (1) ¿Qué es «el tope»? (2) ¿Entran los avisos?

**Opciones para (1).**
- **(A) Un límite en bytes que el arnés pone al motivo.**
  Se declara la cifra. Se mide con contenido ASCII, de 2 y de 4 bytes, en el tope y por encima. El motivo emitido no pasa del tope, conserva la causa, dice que se acortó y no parte un carácter.
  *Consecuencia:* el desarrollador queda obligado a acotar. La cifra pasa a ser contrato operativo.
- **(B) No se acota el motivo: sale de la línea de órdenes.**
  «El tope» es el límite de argumento medido en 1.35.0. Se mide que la decisión sale por encima de él, en ASCII y multibyte.
  *Consecuencia:* el desarrollador queda obligado a no usar la línea de órdenes para el motivo. No hay cifra nueva.
- **(C) Las dos valen; el criterio va por propiedad.**
  La decisión se emite siempre. Si el desarrollador acota, rige además (A). En cualquier caso se mide en los puntos de 1.35.0, ASCII y multibyte. Es lo que hoy está escrito en REQ-007 CA-67.
  *Consecuencia:* la técnica es del desarrollador. La medida cubre las dos lecturas.

**Opciones para (2).**
- **(i) Entran.** El aviso que el hook decide emitir también sale.
  *Consecuencia:* se cierra todo lo que nombra la remediación de SEC-118, con un poco más de alcance que el pedido.
- **(ii) No entran en 1.36.0.** Quedan declarados.
  *Consecuencia:* el alcance es el del pedido. SEC-118 podría no cerrarse entero: eso lo decide el auditor.

**Recomendación del agente: (C) para (1) y (i) para (2).** (C) no elige una técnica en nombre del desarrollador y satisface las dos lecturas del pedido. (i) evita que SEC-118 quede abierto por una parte que cuesta lo mismo reparar.

**Qué trabajo sigue mientras no se decida.** Siguen implementar y probar que **toda denegación se emite** (CA-67, propiedad) y los casos de los puntos medidos en 1.35.0: valen igual con cualquier opción. Dependen de esta decisión la cifra del tope, si la hay, y los avisos.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-03, décima autorización; entrada de arriba) — [2026-10-03] (analista-requerimientos) — P-136-C: CA-68 (SEC-115), ¿con qué mecanismo y con qué plazo se emite la decisión cuando el hook agota el tiempo?

**Contexto.** El pedido dice: «fail-closed cuando el hook agota tiempo … emitir decisión siempre».

Si el cliente mata el hook, nada que el hook haga deniega (SEC-030; REQ-031 CA-A16 lo observó en el cliente). Así que el hook sólo puede **decidir antes**.

La remediación registrada (`docs/seguridad/registro-seguridad.md` § R-044-C, §2) es poner techos de tamaño antes de toda operación que crezca más que linealmente. Eso cubre las vías **identificadas**, y no un tiempo cualquiera. «Siempre» pide algo más, y hay tres formas de acercarse, con fronteras distintas.

**Pregunta.** ¿Qué mecanismo se contrata, y si hay plazo, cuál?

**Opciones.**
- **(A) Sólo techos de tamaño.** Cada techo se declara en bytes y se mide con contenido ASCII y multibyte en el techo y un byte por encima. La promesa llega hasta lo medido.
  *Consecuencia:* no hay reloj. «Siempre» queda acotado a las operaciones cubiertas, y una vía no identificada puede seguir muriendo sin decisión. Un valor legítimo por encima de un techo se deniega.
- **(B) Techos de (A) más un plazo propio del hook.** El plazo se comprueba entre unidades de trabajo, sin procesos, y al vencer el hook emite `deny` con motivo. Es operativo y se baja con la medición; el agente propone **no más de 40 s a nivel de hook, en Linux/WSL2**.
  *Consecuencia:* cubre también las vías no identificadas, salvo una sola operación que se bloquee por dentro. Un juicio legítimo que pase del plazo se deniega a todo agente, también al `desarrollador`. En Windows los juicios tardan varias veces más (CA-54 allí: de 20,4 a 28,9 s) y esta ventana no lo mide. Puede cambiar lo que mide REQ-017 CA-09 (sección 37/3, la pared de los 60 s): si cambia, se escala antes de entregar.
- **(C) Techos de (A) más un vigilante en proceso aparte, que deniega al vencer el plazo.**
  *Consecuencia:* cubre incluso la operación bloqueada. A cambio, añade un proceso a cada llamada, también a un `ls`, y en Windows eso son de 1,2 a 6 s por llamada. Choca con REQ-007 CA-59 (procesos del camino común), que habría que versionar.

**Recomendación del agente: (B), con el plazo en 40 s.** Deja al menos 20 s para emitir la decisión aun con un proceso lento: el `jq` de la emisión, que en Windows cuesta de 1,2 a 6 s. Además, queda por encima del juicio legítimo más lento medido: 28,9 s, CA-54 en Windows sobre `3bc7d3c`. Y no añade procesos.

**Qué trabajo sigue mientras no se decida.** Siguen implementar y probar los **techos de tamaño** para las vías medidas, T1 a T3 de CA-68, y reproducir cada vía en v1.35.0 (fail-before): son comunes a las tres opciones. Dependen de esta decisión el plazo, su valor y el vigilante.

**Espera:** elección del propietario.

### RESUELTA (propietario, 2026-10-03) — **Alcance de 1.36.0 y apertura de la ventana**: CA-54 / QA-023-10, SEC-120 y SEC-115/SEC-118, en ese orden; contrato del analista por propiedad y medida; sin implementación

**Texto del propietario, literal** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.36`, «Encargo 2»; registrado aquí para que la «Correspondencia con el encargo» de REQ-007 pueda citarlo por su sede):

> ## Encargo 2 — Apertura de v1.36.0 (coordinadora + analista; sin código)
> Alcance decidido por el propietario, en este orden de prioridad:
> 1. CA-54 / QA-023-10: el análisis de Bash en el máximo declarado (131072
>    bytes) termina en menos de 5 s en Linux/WSL2, sin cambiar ningún veredicto
>    del banco (2050 casos) y sin subir el umbral ni reducir la entrada. Es
>    optimización de rendimiento; se mide con el banco y las sondas existentes.
> 2. SEC-120 (vence 2026-10-29): fallo de jq al leer o trocear la entrada →
>    deny en las herramientas que las puertas juzgan. Comprobación de código de
>    salida, sin procesos nuevos.
> 3. SEC-115 y SEC-118: fail-closed cuando el hook agota tiempo o el motivo
>    excede el tope: emitir decisión siempre; medir el tope en bytes y ASCII/
>    multibyte en Linux; Windows declarado no medido.
> Fuera de alcance: hueco C, P-119-A (F2/F5/F7), SEC-123 mecanismo.
>
> El analista redacta el contrato de 1.36.0 POR PROPIEDAD Y MEDIDA: qué debe
> cumplirse y cómo se mide, reutilizando el banco y las sondas que ya existen.
> No enumera formas de comando ni variantes; cita los casos existentes por su
> identificador. Un REQ nuevo solo si AGENTS.md §9 lo exige para CA-54; si no,
> versionado de los criterios vigentes. Deja listas las decisiones que
> necesite del propietario como fichas en la cola, no las toma.
> Commit local con CHANGELOG. Sin push.
>
> ## Lo que NO haces en esta sesión
> No despaches al desarrollador, QA ni seguridad: esta sesión abre, no
> implementa. La implementación de CA-54 la autorizo aparte, sobre el contrato
> que entregues. No toques hooks/, tools/ ni tests/. No AGENTS.md. No push,
> versión, PR, fusión ni tag.

**Lo que añade la coordinadora, rotulado como suyo:** el contrato está en `requirements/REQ-007.md` (nota de CA-54 del 2026-10-03, CA-47 punto 20, bloque L con CA-67 a CA-69) y en ADR-017 (`propuesta`). Las decisiones que necesita están en § Pendientes (P-136-A, P-136-B y P-136-C). **Esta entrada no autoriza implementar:** la implementación de CA-54 la autoriza el propietario aparte.

### RESUELTA (propietario, 2026-10-03) — **Publicación de v1.35.0 ejecutada**: `main` `3956a6f`, tag `v1.35.0`, PR #59, CI final run 37169938675 (success) sobre `c0f8493`

**Datos del propietario** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.36`, «Encargo 1»): publicada el 2026-10-03; `main` `3956a6f`; tag `v1.35.0`; PR #59; CI final run 37169938675 (success) sobre `c0f8493`. Plugin instalado: 1.35.0.

**Lectura del propietario, literal** (mismo mensaje):

> El impedimento del proveedor de la novena autorización fue sobre el contenido del despacho de SEC-124/125 y la lectura de su diff, no sobre los roles. Los encargos de 1.36.0 se redactan por propiedad y medida.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Discrepancia detectada después (2026-10-03, durante el encargo 2):** en este host (WSL2), `~/.claude/plugins/installed_plugins.json` registra `arnes-juan` **1.33.2** (`10eac80`, `lastUpdated` 2026-09-11), tanto con alcance `user` como con alcance `project`, y el bloque derivado de `docs/ESTADO.md` dice lo mismo. El «Plugin instalado: 1.35.0» de arriba es el dato del mensaje del propietario y no coincide con este host. La actualización de la instalación estable (punto 5 de «Lo que el propietario hace a mano») **no estaba comprobada aquí**. **Hecha después, por petición expresa del propietario (2026-10-03):** 1.35.0 instalada en los alcances `user` y `project` (`gitCommitSha` `3956a6f`), con `hooks/` idéntico al tag; rige desde el próximo reinicio.
- **Comprobado con `git` y `gh` (2026-10-03):** `git tag --points-at 3956a6f` da `v1.35.0`; `3956a6f` es la fusión de `713ac68` y `c0f8493`; el PR #59 está `MERGED` con `mergeCommit` `3956a6f` y `headRefOid` `c0f8493`; el run `37169938675` (`banco`) está `completed`/`success` con `headSha` `c0f8493`.
- **Cierra** lo que quedaba de «Lo que el propietario hace a mano para publicar» en el bloque de 1.35.0 de `docs/ESTADO.md`, puntos 3 a 5 (push, CI, PR, fusión, tag e instalación estable). El punto 1 (`arnes_version`) se resolvió de otro modo: se conserva en `1.33.0` por decisión del propietario (`5d810f0`).
- **No había entrada pendiente que mover:** la cola ya estaba vacía. Esta entrada sólo deja escrito el cierre. **No** autoriza cerrar ningún REQ, y no cambia veredictos, contratos ni contadores.
- **Qué trabajo sigue:** la apertura de 1.36.0 (contrato del analista), autorizada en el mismo mensaje. La implementación de CA-54 la autoriza el propietario aparte.

### RESUELTA (propietario, 2026-10-03, posterior a `8522e4f`) — **Cierre de v1.35.0, tramo 3**: P-119-A resuelta como límites declarados; los motivos de los SKIP remiten al log del CI; la nota histórica de «ocho» no se toca; SEC-126 corregido por el propietario; versión 1.35.0

**Texto del propietario, literal** (mensaje del 2026-10-03, sección «Decisiones del propietario (registrar literales)»):

> 1. P-119-A en REQ-007 pasa de «Preguntas abiertas» a resuelta como limites
>    declarados (decision 5 de publicacion); F2, F5 y F7 siguen abiertos y no
>    aceptados como riesgo. Indice coherente.
> 2. Los motivos de los SKIP no se copian a las notas: viven en el log del CI y
>    en docs/qa/REQ-023.md; las notas remiten alli.
> 3. La nota historica del CHANGELOG con «ocho» no se toca; si hace falta, una
>    aclaracion entre parentesis en la nota nueva.
> 4. SEC-126: corregido por el propietario en hooks/lib.sh (edicion ya en el
>    arbol). Pasa a «reparado» en el registro (solo registro, sin firma) y en
>    las notas. La coordinadora verifica que el diff de hooks/ es SOLO ese
>    comentario: `git diff --stat hooks/` debe mostrar un archivo y
>    `git diff hooks/ | grep '^[-+][^-+#]'` no debe mostrar nada (solo lineas
>    de comentario). Si muestra algo mas, para y avisa.
> 5. Version: arnes_version 1.35.0 en .arnes/config.json; version 1.35.0 en
>    .claude-plugin/plugin.json y marketplace.json. Como esos archivos estan
>    protegidos, los edita el propietario si guard-codigo lo deniega; la
>    coordinadora indica los tres cambios exactos (archivo, clave, valor).

**Lo que añade la coordinadora, rotulado como suyo:**
- **Base:** `8522e4f`, más la edición del propietario en `hooks/lib.sh` sin comitear.
- **Decisión 4, verificada el 2026-10-03:**
  - `git diff --stat hooks/` muestra un archivo, `hooks/lib.sh`, con 4 inserciones y 2 borrados;
  - `git diff hooks/ | grep '^[-+][^-+#]'` no muestra nada (rc 1): sólo hay líneas de comentario;
  - las tres gates de §7 dan rc 0.
- **Decisión 5:**
  - `.claude-plugin/plugin.json` (`version`) y `.claude-plugin/marketplace.json` (`metadata.version` y `plugins[0].version`) **ya están en `1.35.0`**;
  - **sólo falta** `.arnes/config.json`, clave `arnes_version`: `"1.33.0"` → `"1.35.0"`, l. 3. Está en `codigo_app.globs` y lo edita el propietario. La coordinadora no lo intenta.

### RESUELTA (propietario, 2026-10-03, posterior a `52a1d39`) — **Decisiones de publicación de v1.35.0**: CA-54 aceptado con alcance; SEC-115/118, SEC-120, hueco C, P-119-A (F2, F5, F7) y SEC-123 como límites declarados; SEC-126 si es sólo comentario; SKIP/INCONCLUSO no acreditan; «siete» → «ocho»; firmas de QA y seguridad de la fase 2 ausentes y declaradas. Resuelve las fichas 1 y 2, la decisión 9b, P-119-A y SEC-120 de la entrada que estaba pendiente (debajo)

**Texto del propietario, literal** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.35`, sección «Decisiones del propietario para la publicación de v1.35.0»):

> 1. CA-54 / QA-023-10 (decisión 9b) — ACEPTADO CON ALCANCE para v1.35.0. El
>    análisis de Bash tarda 9,0–9,2 s en el máximo declarado (131072 bytes)
>    frente al criterio de < 5 s; igual que 43b948a. No se sube el umbral ni se
>    reduce la entrada. Consecuencia declarada: un comando de ese tamaño se
>    juzga, pero tarda; no es un fallo abierto. Reparación: v1.36.0, foco
>    principal.
> 2. SEC-115 y SEC-118 — LÍMITES DECLARADOS en v1.35.0, no aceptados como
>    definitivos: un hook que agota tiempo o un motivo demasiado grande pueden
>    no emitir decisión; se declaran en notas y guía con sus condiciones
>    medidas. Reparación (fail-closed): v1.36.0.
> 3. SEC-120 — LÍMITE DECLARADO en v1.35.0; reparar en v1.36.0 antes de su
>    vencimiento (2026-10-29): fallo de jq al leer o trocear la entrada → deny.
> 4. Hueco C — LÍMITE DECLARADO del análisis estático: escrituras mediante
>    intérpretes o scripts no se detectan. Permanece abierto; su detección se
>    evalúa por propiedad en una versión posterior, sin fecha.
> 5. P-119-A (F2, F5, F7) y SEC-123 — LÍMITES DECLARADOS, con F3 corregido
>    (R-048). Permanecen abiertos y no aceptados como riesgo.
> 6. SEC-126 — se corrige en este tramo si es sólo el comentario de
>    hooks/lib.sh con la cifra antigua (edición de texto en un comentario, sin
>    cambio de comportamiento); si requiere más, v1.36.0.
> 7. Ningún SKIP ni INCONCLUSO del banco acredita lo que mide; se publican con
>    su motivo.
> 8. Autorizo la corrección de una palabra: «siete clases de casos, y sólo
>    ésas» → «ocho clases» en las notas [1.35.0] y en la guía, para que
>    coincida con la enumeración que sigue.
> 9. Firmas de QA y seguridad del delta de la fase 2: ausentes por impedimento
>    del proveedor; así se publica, declarado en notas y guía. El impedimento
>    fue sobre el contenido del despacho de SEC-124/125 y la lectura de su diff,
>    no sobre los roles.

**Lo que añade la coordinadora, rotulado como suyo:**
- **Base:** `cand/1.35.0` en `52a1d39`.
- **La cola queda vacía.** Estas decisiones resuelven lo último que seguía abierto en la entrada pendiente (fichas 1 y 2, 9b, P-119-A y SEC-120; lo demás ya estaba resuelto), así que esa entrada pasa a § Resueltas, debajo, sin cambiar su texto. Con la cola vacía, `guard-completado` deja de denegar el cierre de REQ **por la cola**. Las demás puertas siguen igual, y cerrar requisitos no está autorizado.
- **SEC-126 (decisión 6):** es sólo el comentario de `hooks/lib.sh`, l. 704. **La coordinadora no lo edita:** `hooks/*` está en `codigo_app.globs` y `guard-codigo` deniega esa edición a quien no es el `desarrollador`. `AGENTS.md` §6 manda ese arreglo al `desarrollador` («la fila 1 no levanta el control de edición»), y este tramo no lo despacha. No se intentó ningún rodeo. Queda para el propietario (edición manual) o para v1.36.0.
- **Contratos, `QA:`/`Seguridad:` y contadores:** sin cambios. «Aceptado con alcance» y «límite declarado» se escriben en las notas y la guía, no en los criterios.

### RESUELTA (propietario, 2026-10-03, decisiones de publicación de v1.35.0; entrada de arriba) — [2026-09-27, puesta al día 2026-10-03] (coordinadora) — Decisión de publicación de 1.35.0: SEC-115/SEC-118, hueco C, P-119-A, SEC-120 y **9b (QA-023-10)** pendientes y no aceptados; **decisión 11 resuelta (opción B), SEC-125 «reparar antes de publicar» y SEC-123 «corregir F3» decididos el 2026-10-03, con la ejecución pendiente de autorización**; fichas 3 y 4 y decisiones 4 a 10 resueltas

- **Contexto:** el 2026-09-29 el propietario autorizó implementar SEC-047 (mitad 1 de REQ-023) y preparar el candidato v1.35.0 (§ Resueltas, entrada de esa fecha, texto literal). **Esa autorización NO acepta el aplazamiento de SEC-115 ni del hueco C**: los dos siguen pendientes aquí, con sus fichas finales abajo. El antiguo asunto 3 (SEC-047 y la celda de §13) queda resuelto por esa autorización; los asuntos 1 y 2 de la redacción del 2026-09-28 se sustituyen por las fichas, sin perder nada de lo que decían.
- **Acción que impide (regla 2):** **publicar** 1.35.0 —tag, publicación, actualización de la instalación estable— hasta que el propietario decida las fichas 1 y 2, P-119-A y la decisión 9b, y se complete la reparación de SEC-119 y O-11 (fichas 3 y 4 y decisiones 4 a 8 resueltas); y, mientras esta entrada esté aquí, **cerrar**: marcar **cualquier** REQ `completado` (`guard-completado`; deliberado). **No** impide **implementar** ni **probar** el candidato. **Parte afectada:** la publicación de 1.35.0 y el cierre de REQ-023 y REQ-031. **Evidencia:** la de cada ficha. **Qué lo resuelve:** la decisión del propietario sobre cada ficha. *(Puesta al día 2026-10-03: la reparación de SEC-119 y O-11 está hecha y con seguridad conforme (R-047). Para **publicar** faltan ahora, además de las fichas 1 y 2, P-119-A y 9b: la ejecución, la validación y la revisión de SEC-124 (B) y SEC-125 y la corrección de F3 (SEC-123), decididas el 2026-10-03 y sin autorización de ejecución; la decisión sobre SEC-120; y una corrida de CI sobre la cabeza final.)*

**Ficha 1 — SEC-115 y SEC-118 (`instrumento`, abiertos, NO aceptados): un hook que no emite decisión —por tiempo (SEC-115) o por el tamaño de su propio motivo (SEC-118)— deja pasar el cierre entero.** *(SEC-118 añadido y fórmula de la limitación corregida el 2026-09-29, por R-045 §6.)*
- **Consecuencia reproducida.** R-044-C sobre `cdcad5d` (2026-09-28, WSL2/Linux): `QA: pendiente (…)` con ≈ 255 KB de evidencia → deny en **73,6 s**; `Write` de 2 025 113 bytes → **80,2 s** (1 012 650 bytes → 20,5 s). CA-A16 (Claude Code CLI 2.1.272, `claude -p`, WSL2, un intento más un control `deny`, 2026-09-28): un hook que agota su timeout sin decidir **deja pasar la herramienta**. El REQ se cerraría con QA y seguridad pendientes: dejan de correr **todas** las puertas del cierre. **No comprobado** en la sesión interactiva del editor ni en Windows.
- **Segunda vía, SEC-118** (R-045, 2026-09-29, severidad media, preexistente: medido igual en el candidato y en `713ac68`). `arnes_deny` pasa el motivo como un argumento de `jq`, y por encima de ~128 KiB el hook sale **sin decisión**. Que el cliente lo trate como permitir es **inferido**, no observado en el host (ver abajo). Medido a nivel de hook:
  - `QA:` de ≈ 140 KB sin paréntesis final → **sin decisión en 0,5 s**, e igual con `Seguridad:`, con `Sensible a seguridad:` y con una línea de 140 KB que lleva un CR interior;
  - REQ-031 CA-A12 con líneas **ASCII** de 60 caracteres o más: 1 601 repeticiones de `Hallazgos abiertos:` deniegan y 1 801 salen **sin decisión**. **El límite es de bytes:** con caracteres multibyte en los primeros 60 caracteres el umbral baja. QA midió el 2026-09-29, igual en `e7562e7` y en `713ac68`, que salen sin decisión 1 601 líneas con `ñ`, 1 001 con caracteres de 4 bytes y 2 501 cortas con `ñ` (QA-023-06).

  Sin medir en Windows, donde el umbral podría bajar a unas 32 KiB. El motivo de REQ-023 tiene tope (20 líneas) y no está afectado.
  - **Qué es observado y qué no, en SEC-118** (segunda autorización, punto 4; sin ensayos nuevos):
    - **Observado directamente**, a nivel de hook, con la entrada JSON `PreToolUse` real alimentada a `guard.sh` en la candidata y en `713ac68` (R-045 §4): el hook termina **sin emitir decisión** en los casos citados, y el control con el mismo valor entre paréntesis (motivo de 314 bytes) deniega. Los recuentos de CA-A12 los midió el auditor (1 601 deniega, 1 801 permite) y los de 3 000 repeticiones, el desarrollador y QA.
    - **Inferido, no observado:**
      - que el host trate como permitir un hook que termina sin decisión en este caso concreto. Se apoya en el contrato de hooks y en CA-A16, que se observó en el CLI 2.1.272 por *timeout* y no por esta causa;
      - el mecanismo exacto («Argument list too long» de `jq` con `MAX_ARG_STRLEN`), leído del código y del error;
      - el umbral en Windows;
      - los candidatos sin medir de R-045 §4.
    - **Ningún caso de SEC-118 se ha ejecutado en el host real.**
- **Protección efectiva hoy:** techo de 16 384 bytes para `Hallazgos abiertos:`, medido antes de normalizar (255 371 bytes → deny en 0,31 s por `Edit`); presupuesto de reconstrucción del `Edit`; el REQ real más grande (296 976 bytes) tarda 1,71 s por `Write`; la línea de control más larga de las 29 cabeceras mide 1 926 bytes.
- **Qué depende de la disciplina del agente:** no escribir evidencia de cientos de KB en `QA:`, `Seguridad:`, `Rigor:`, `Sensible a seguridad:` ni `Estado:`, ni un REQ de MB por `Write`. Sólo `Hallazgos abiertos:` tiene regla escrita (`requirements/README.md`).
- **Alternativa — reparar antes de publicar:** para SEC-115, la propiedad «ninguna operación que crezca más que linealmente corre antes de una comprobación de tamaño que deniegue»: techo por campo de control antes de `arnes_norm_campo`, y techo del `content` de `Write` antes de `arnes_sin_cr_transporte`. Para SEC-118, un solo sitio: que el motivo no viaje como argumento de `jq` (por la entrada estándar, o acotado en bytes). Exige un REQ nuevo (hoy no tienen sede de remediación) y la vía completa. Retrasa el tag lo que dure ese ciclo.
- **Alternativa — aplazar (propuesta, no decisión):** responsable propuesto `desarrollador` (mecanismo) y `analista-requerimientos` (REQ), para los dos; **fecha de revisión propuesta: 2026-10-29**; revisión **anticipada** si ocurre cualquiera de estas: un informe de un hook que sale sin decisión; una medición en Windows del umbral de SEC-118; una comisión que toque `arnes_deny`; una línea de control de más de 16 KB en este repositorio o en un informe de consumidor; un informe de consumidor de un hook muerto por tiempo; una medición en el editor o en Windows de que un timeout también deja pasar; o una comisión que toque `arnes_norm_campo`, `arnes_sin_cr_transporte` o los presupuestos de los hooks (el forzador ya escrito en R-044-C).
- **Limitación para las notas si se publica sin reparar:** la puerta de cierre decide sólo si el hook alcanza a medir **y a emitir su decisión**. Un hook que agota el límite del cliente (60 s; comprobado en el CLI 2.1.272) no deniega, y lo agotan, medido, un veredicto de ≈ 255 KB o un `Write` de ≈ 2 MB (SEC-115). Tampoco deniega un hook cuyo motivo pasa de ~128 KiB **en bytes** (SEC-118): un veredicto de ≈ 140 KB sin paréntesis, o líneas repetidas de `Hallazgos abiertos:` en número suficiente (unas 1 800 si son ASCII, y menos con caracteres multibyte). **La versión no puede prometer** que ningún REQ se cierre sin QA ni seguridad en absoluto, ni que una clave repetida deniegue sin límite: sólo «si el hook alcanza a medir y a emitir su decisión».

**Ficha 2 — hueco C (escrituras por intérprete o script), NO aceptado como aplazado.**
- **Consecuencia reproducida.** 2026-09-27, `guard-codigo` de `a7a60c2` (sin cambios desde `v1.34.0` ni en el candidato), proyecto temporal en WSL2: desde la sesión coordinadora, `python3 -c "open('src/app.ts','w')…"`, `node -e "…writeFileSync…"` y `bash escribe.sh` → **allow**, y el archivo queda escrito (`src/app.ts = py`); `echo >`, `sed -i`, `dd of=` y `Edit` → deny. No hay `PostToolUse`: ninguna detección posterior. `docs/PENDIENTES.md` registra además tres instancias en un proyecto real el 2026-09-07.
- **Protección efectiva hoy:** `Edit`/`Write`/`MultiEdit` sobre `codigo_app.globs` fuera del `desarrollador`, y las escrituras evidentes por `Bash` (`>`, `>>`, `tee`, `cp`, `mv`, `install`, `sed -i`, `perl -i`, `dd of=`).
- **Qué depende de la disciplina del agente:** que ninguno use un intérprete, un script, un formateador o `patch`/`git apply` para escribir código protegido (`AGENTS.md` §5 y §13, que ya lo declaran).
- **Alternativas — reparar antes de publicar:** (A1) ampliar el detector a `python -c`/`node -e` cuando el texto del comando nombra una ruta protegida: impediría las dos formas en línea medidas, **no** `bash script.sh` ni una ruta construida dentro del programa; crítico, vía completa, riesgo de falsos positivos (§13). (A2) REQ-011, la «puerta posterior» (`pendiente`, destino 1.33.0 vencido): **sólo una propuesta de detección** posterior; **no** es prevención, ni recuperación, ni mitigación disponible (no está implementada), y su tamaño es el de una versión propia.
- **Alternativa — aplazar (propuesta, no decisión):** responsable propuesto `desarrollador` (`guard-codigo`) y `analista-requerimientos` (ventana de REQ-011); **fecha de revisión propuesta: 2026-10-15** — antes que SEC-115 porque C está **observado** en un proyecto real y SEC-115 no; revisión **anticipada** si ocurre cualquiera de estas: una nueva instancia observada, en este repositorio o en un consumidor, de código protegido escrito por intérprete o script desde un agente distinto del `desarrollador`; o una comisión que toque `guard-codigo` o el detector de escrituras compartido.
- **Limitación para las notas si se publica sin reparar:** `guard-codigo` no ve escrituras hechas por intérpretes o scripts (`python`, `node`, `bash script.sh`), formateadores que reescriben archivos, `patch` ni `git apply`, y no hay detección posterior. **La versión no puede prometer** que sólo el `desarrollador` modifique código protegido: promete que las herramientas de edición y las escrituras evidentes por shell lo deniegan.

**Ficha 3 — RESUELTA por el propietario el 2026-09-29 (tercera autorización): SEC-117 se REPARA antes de publicar; no se acepta aplazarlo.** *Texto original de la ficha, conservado:* QA-023-02 (`instrumento`, severidad crítica, preexistente; NO aceptado; añadida el 2026-09-29 al escalarla QA). Un `Edit` que el hook no encuentra literal y la herramienta sí, y que sustituye **sólo el valor** del estado, cierra un REQ sin ninguna puerta.
- **Consecuencia reproducida.**
  - **Lado del hook, ejecutado** por QA (2026-09-29, `docs/qa/REQ-023.md` § QA-023-02, evidencia `frontera-g-edit-normaliza.txt`). Sobre un REQ `critico` con `QA: pendiente`, `Seguridad: pendiente` y `SEC-1 (contrato)` abierto:
    - `Edit` con `old_string` = `en-revisi\u00f3n` (barra invertida literal) y `new_string` = `completado` → **ALLOW** en el candidato `ace43c2`, en `713ac68`, en `v1.34.0` (`cc8972c`, medido en la vuelta 2 de QA) y en 1.33.2;
    - `MultiEdit` con la misma edición → ALLOW;
    - comillas rectas donde el archivo las tiene tipográficas → ALLOW;
    - con una entrada bajo `## Pendientes` → ALLOW.
  - **Lado de la herramienta:** QA leyó en el binario del CLI 2.1.284 que el `Edit` normaliza ‘ ’ “ ” y desescapa `\uXXXX`.
  - **REPRODUCIDO EN EL HOST REAL el 2026-09-29** (segunda autorización, punto 3). Registro previo comiteado antes de ejecutar (`6c947ef`); resultado en `sec117-real/RESULTADO.md`, rama local de evidencia, `1c8c81c`. Claude Code **2.1.285**, `claude -p`, WSL2, `Edit` real del host, `guard.sh` del candidato sin cambios; el plugin 1.33.2 instalado no se cargó. Una ejecución por caso:
    - **control positivo:** `old_string` literal → deny, el host bloquea y el archivo no cambia;
    - **caso sospechoso:** comillas rectas donde el archivo tiene tipográficas → el hook sale sin decisión, el host aplica el `Edit` (su `tool_response.oldString` muestra las tipográficas del archivo: normalizó) y el REQ queda **`Estado: completado` con QA y seguridad pendientes, un `contrato` abierto y la cola ocupada**;
    - **control legítimo:** se permite y se aplica.

    **No ensayado en el host:** el escape `\uXXXX`, `MultiEdit`, el editor interactivo, Windows y otras versiones del CLI.
  - **Propuesta mínima de reparación, no aplicada:** fallar cerrado en la vía de fragmentos. Cuando la puerta no puede reconstruir el documento de un REQ, deniega si la edición puede dejar el estado terminal (la «regla ancha» de la vía de `Bash`). No imitar la normalización del host. Sede: `hooks/guard-completado.sh`, con un REQ nuevo y la versión de REQ-001 CA-10/CA-11.
- **Protección efectiva hoy:** ninguna mecánica en esa vía. La rama de fragmentos sólo sigue si el `new_string` contiene «estado: completado». Con la línea `Estado:` completa en el fragmento, juzga veredictos, clase, cola y quality gates (caso G3), pero **no** la regla de la cabecera ambigua de REQ-023: por esa vía la fila crítica de SEC-047 cierra aunque el agente escriba la línea entera (caso B6 de QA, vuelta 3, corregido el 2026-09-29).
- **Qué depende de la disciplina del agente:** cerrar escribiendo la línea `Estado:` entera y con un `old_string` literal.
- **No es regresión:** existe en `v1.33.2` y en `v1.34.0`. Publicar 1.35.0 no lo introduce ni lo agrava, y tampoco lo cierra.
- **Alternativa — reparar antes de publicar:** un REQ nuevo (hoy no tiene sede; la premisa falsa de que «la herramienta falla y no escribe nada» vive también en REQ-001 CA-10/CA-11, `completado`) y la vía completa. Por ejemplo, que la reconstrucción del hook emule la búsqueda de la herramienta, o que deniegue cuando no pueda reconstruir y el fragmento pueda dejar el estado terminal. Retrasa el tag lo que dure ese ciclo.
- **Alternativa — aplazar (propuesta, no decisión):**
  - **Responsables propuestos:** `desarrollador` (mecanismo), `analista-requerimientos` (REQ, y qué hacer con REQ-001) y `auditor-seguridad` (registro y alcance).
  - **Fecha de revisión propuesta: 2026-10-06**, la más temprana de las tres por su severidad.
  - **Revisión anticipada** si ocurre cualquiera de estas: se observa un cierre por esa vía; cambia el respaldo del `Edit` del CLI; o una comisión toca la reconstrucción del `Edit` en `guard-completado`.
- **Limitación para las notas si se publica sin reparar:** la puerta de cierre no juzga un cierre hecho con un `Edit` o `MultiEdit` cuyo `old_string` sólo coincide tras la normalización de la herramienta y cuyo `new_string` no contiene la línea `Estado:`. **La versión no puede prometer** que ningún cierre por `Edit` se salte las puertas.

**Decisión 4 — RESUELTA por el propietario el 2026-09-29 (segunda autorización, § Resueltas): opción (A), corrección documental excepcional fuera del contador, que sigue agotado.** *Texto original de la decisión, conservado:* REQ-023 `bloqueado`: tope de vueltas dev↔QA agotado (3 de 3) con un hallazgo `contrato` de SÓLO TEXTO abierto (QA-023-05). Añadida el 2026-09-29.
- **Qué ocurrió.** QA validó la conducta de CA-01…CA-12 en las tres vueltas sin un solo FAIL. El código ejecutable es el mismo desde `ad793ab`. Sobre `c4cc32c`: banco completo 1137 PASS · 0 FAIL · 12 SKIP, con 1 INCONCLUSO de REQ-017 CA-08 (ii) que se conserva; 37 de 37 decisiones coinciden con la propiedad escrita.
  - Las vueltas 2 y 3 fueron sólo de texto: cerraron QA-023-01, QA-023-03 y QA-023-04.
  - En la vuelta 3 el barrido encontró **QA-023-05**. `requirements/README.md` y su plantilla (líneas 89–98, sede heredada de la frontera) dicen «Cuándo deniega, dicho entero» y «se deniega toda edición…», pero no excluyen la vía (g): la del `Edit`/`MultiEdit` con `old_string` no literal que la herramienta aplica. Por esa vía la puerta permite (B2, B3, B4, B6), igual en `713ac68`, 1.33.2 y `v1.34.0`: es QA-023-02, preexistente.
  - «Toda edición», sin acotar, aparece también en `SKILL.md`, ADR-014 y las notas, que sí declaran (g) en el mismo apartado.
- **Acción que impide (regla 2):** **cerrar** REQ-023: `guard-completado` deniega con un `contrato` abierto, y QA no puede firmar `aprobado` sin el write-back (§9). Por consecuencia impide también **publicar** con ese texto heredado falso. **Parte afectada:** sólo esas sedes de texto; ni el código ni la conducta. **Evidencia:** `docs/qa/REQ-023.md` § «Vuelta 3 de 3» (§3 y §5). **Qué lo resuelve:** el write-back de texto y una reverificación de texto por QA, que ya no caben en el contador.
- **Opciones** («Loop de error»):
  - **(A) Autorizar una corrección documental fuera del contador,** acotada a QA-023-05 y a las condiciones de texto de R-045 §6, como la del 2026-09-28 con REQ-031.
    - **Qué se toca en REQ-023:** el analista acota el «Cuándo deniega» del README y de la plantilla a las ediciones que la puerta reconstruye (`Write`, o `Edit`/`MultiEdit` con `old_string` literal), añade la vía (g) a «Fuera, y sin promesa» remitiendo a QA-023-02 / SEC-117, y acota «toda edición» en `SKILL.md`, ADR-014 y las notas.
    - **Qué se toca por R-045 §6:** declarar SEC-118 en las notas; corregir la fórmula «si el hook alcanza a medir» por «si alcanza a medir y a emitir su decisión» en el cambio de compatibilidad 1 de las notas y en la entrada de REQ-031 de la guía; y citar SEC-117 en la guía. El barrido se hace por propiedad, con esta advertencia: la promesa de que la clave repetida deniega sin límite también está en texto de **REQ-031** ya publicado en `main`, en `AGENTS.md` §13 y su plantilla y en el README («Si hay más de una, deniega»), y SEC-118 la desmiente a partir de unas 1 700 repeticiones.
    - QA reverifica sólo ese texto, y seguridad lo confirma de forma documental.
    - **Qué no cambia:** ningún código y ninguna conducta.
    - **Consecuencia:** una comisión corta de cada uno; después, la firma de seguridad sobre el árbol resultante.
  - **(B) Cerrar con el residual declarado:** **no es posible**. El residual es `contrato` y la puerta no deja cerrar con uno abierto; rebajar su clase sería mover el hallazgo de sitio, y eso lo prohíbe §6.
  - **(C) Mantener REQ-023 `bloqueado` y publicar 1.35.0 sin él,** retirando su código y sus textos del candidato. **Consecuencia:** SEC-047 mitad 1 no se publica, se rehace el candidato y se vuelve a validar.
- **Recomendación de la coordinadora:** (A). El defecto es de texto, la conducta está validada tres veces sin fallos, y la corrección tiene alcance cerrado. Recibido (A), el trabajo sigue sin más autorizaciones.
- **Trabajo que sigue mientras tanto** (no depende de esta decisión):
  - la revisión de seguridad del código del candidato: es una revisión, **no** una firma `Seguridad: aprobado`, que exige `QA: aprobado`;
  - el registro formal de QA-023-02 y del fail-open del motivo de CA-A12;
  - el push, el PR en borrador y el CI.

**Decisión 5 — RESUELTA por el propietario el 2026-09-29 (tercera autorización): se corrige QA-023-06 conservando las cifras medidas con sus condiciones, incluida la restricción ASCII, y separando la propiedad del control de las limitaciones SEC-115/118.** Es una forma propia del propietario, distinta de las opciones (A) y (B). *Texto original de la decisión, conservado:* QA-023-06 (`contrato`, sólo texto), abierto por la revisión de QA del delta documental. Añadida el 2026-09-29.
- **Qué ocurrió.** La intervención excepcional autorizada cerró QA-023-05. QA confirmó ciertos, contra la evidencia en crudo:
  - SEC-117 reproducido en la 2.1.285;
  - la separación de SEC-118 entre observado, inferido y no medido;
  - el fail-before local frente a los 18 SKIP del CI;
  - las tres condiciones de la cláusula nueva de §13.

  Pero **el mismo delta publicó cifras de SEC-118 como frontera medida** («1 601 líneas de 60 caracteres o más deniegan», «2 501 cortas deniegan», «umbral ≈ 1 700 / 2 900») cuando **sólo están medidas con líneas ASCII**, y el límite es de bytes. Con multibyte salen sin decisión 1 601, 1 001 y 2 501 líneas (QA, con la puerta real, igual en `e7562e7` y `713ac68`).
  - **Sedes:** README y plantilla, `AGENTS.md` §13 y su gemela, REQ-031 CA-A12 (nota de versionado) y su Historial, REQ-023, ADR-013, ADR-014, la guía y las notas.
  - **El origen es de la coordinadora:** su encargo pidió al analista escribir la propiedad «con lo medido».
- **Acción que impide (regla 2):** **cerrar** REQ-023 y **REQ-031**, que tienen ahora `QA: con-hallazgos` con QA-023-06. La cola ya lo impedía. Impide también **publicar**, porque el texto heredado afirmaría algo falso. **Parte afectada:** sólo cifras de texto; ni código ni conducta. **Evidencia:** `docs/qa/REQ-023.md` § «Intervención documental excepcional», §5. **Qué lo resuelve:** una reescritura de esas cifras y la revisión de QA sobre el texto. La autorización de una sola intervención ya está consumida.
- **Opciones:**
  - **(A) Autorizar una segunda corrección documental fuera del contador, acotada a QA-023-06,** con la forma que menos riesgo de repetición tiene. Las sedes heredadas se quedan con la **propiedad sin cifras** («deniega si el hook alcanza a medir y a emitir su decisión; el límite es de bytes y lo medido está en el registro»), y las cifras viven **sólo** en R-045, con «medido con líneas ASCII».
    - **Flujo:** analista, después QA sobre el texto, después la determinación de seguridad.
    - **Consecuencia:** dos o tres comisiones cortas, sin código.
  - **(B) Lo mismo, conservando cifras en las sedes** con la precisión de bytes y la salvedad ASCII. **Consecuencia:** más sedes que mantener en sincronía con el registro, y más superficie para el mismo tipo de defecto.
  - **(C) Publicar con QA-023-06 abierto:** **no es posible**. Es `contrato`: la puerta no deja cerrar con uno abierto, y el texto heredado afirmaría algo falso.
- **Recomendación de la coordinadora:** (A). Una cifra repetida en diez sedes se desfasa en cuanto cambia una medición, y eso es lo que acaba de pasar.
- **Observaciones de QA sin identificador, que no bloquean** (detalle en la misma adenda, §5):
  - **O-1:** la condición 2 de la cláusula de §13, leída literalmente, vacía la fila de `Bash`; promete de menos.
  - **O-2:** con la línea `Estado:` entera pero decorada (`**Estado:** completado`), con punto final o entre comillas invertidas, la vía (g) pasa sin puertas. Es más ancho que lo que dice la cláusula.
  - **O-3:** a nivel de hook, un `Edit` con `old_string` vacío que crea un REQ con `**Estado:** completado` sale allow, y el mismo documento por `Write` deniega. Es superficie de SEC-117 no medida en el host; debe registrarla el auditor.
  - **O-4:** la cláusula remite las cifras al registro, pero la fila de hallazgos lleva cifras.
  - **O-5:** la guía no manda migrar la cláusula nueva de §13, así que un proyecto que actualice no la recibe.
  - **O-6:** la frase del README sobre `MultiEdit` promete de menos.

  Si se autoriza (A), O-1, O-2, O-4, O-5 y O-6 son del mismo tipo (el texto de §13, del README y de la guía) y conviene que entren en la misma corrección, **sólo si el propietario lo autoriza expresamente**. O-2 y O-3 son superficie de SEC-117 y van a su registro, no a esta corrección.

**Decisión 6 — RESUELTA por el propietario el 2026-09-30 (cuarta autorización): opción (A).** *Texto original, conservado:* P-SEC117: la reparación de SEC-117 que exige la propiedad choca con criterios vigentes de REQ-001 (`completado`) y REQ-007. Añadida el 2026-09-29, durante la vuelta excepcional de la tercera autorización.
- **Pregunta.** ¿Autorizas que la reparación de SEC-117, dentro de esta misma vuelta excepcional, haga cuatro cosas?
  1. Versionar **REQ-001 CA-10, CA-11 y CA-12** y **REQ-007 CA-46 (c)**. Con eso **REQ-001 se reabre** (§9) y queda `en-revisión` en el candidato, sin cerrarse.
  2. Adaptar los casos del banco que fabrican un `old_string` no literal sobre `requirements/`.
  3. Extender la revisión de QA y seguridad de la vuelta a esos dos REQ.
  4. Lo que implica la condición «no reconstruible → deny».
- **Por qué hace falta.** La propiedad que fijaste —«esa incertidumbre no puede convertirse en permiso silencioso»— obliga a denegar el `Edit`/`MultiEdit` sobre `requirements/` que el hook no puede reconstruir. Pero:
  - **REQ-001 CA-11 contrata literalmente lo contrario:** ALLOW para `old_string` inexistente y `new_string` = `completado`, «la herramienta fallará entera». Es la premisa que el experimento real desmintió (SEC-117).
  - CA-10 («el fallback sigue vivo») y CA-12 (un `Edit` sobre una ruta inexistente «cae al fragmento y no bloquea») van en el mismo sentido, y también REQ-007 CA-46 (c) («no elimina el fallback»).
  - **El banco:** 111 llamadas a `emite_edit`, que fabrica `old_string:"x"`, en 20 secciones; unas 49 esperan allow y 55 deny, contadas por la coordinadora con `grep`. Las que apuntan a `requirements/` dejarían de medir las puertas que miden hoy, porque la regla nueva deniega antes, y habría que convertirlas en ediciones literales.
  - La tercera autorización nombra sólo REQ-023 y REQ-031 como alcance de la revisión de QA.
- **Opciones:**
  - **(A) Sí, cumplir la propiedad.**
    - **Contrato:** el analista versiona REQ-001 CA-10, CA-11 y CA-12 y REQ-007 CA-46 (c), con un ADR de fondo (SEC-117 supersede la premisa), y escribe el criterio nuevo en REQ-023 (su borrador de CA-13 está en REQ-023, «Preguntas abiertas», P-SEC117).
    - **Código y banco:** el desarrollador implementa y convierte los casos afectados.
    - **Revisión:** QA y seguridad revisan también REQ-001 y REQ-007.
    - **Consecuencia:** es una vuelta mayor, con más riesgo de no cerrarla en su único intento, y REQ-001 queda reabierto en el candidato.
  - **(B) Regla ancha sólo sobre el fragmento no reconstruible:** denegar si la edición menciona el estado terminal. **No cumple la propiedad.** El analista lo deriva leyendo, sin medirlo: un valor escrito con `\uXXXX` que el host desescapa, o retirar la línea `Estado` que gobierna para que gobierne otra terminal, siguen dando permiso silencioso. Además exige igual versionar CA-11.
  - **(C) No reparar ahora:** ya lo rechazaste.
- **Recomendación de la coordinadora:** (A), con el alcance escrito arriba y nada más. Es la única opción que cumple la propiedad. REQ-001 queda reabierto y **no** se cierra, porque cerrar requisitos no está autorizado.
- **Acción que impide (regla 2):** **implementar** la reparación de SEC-117, porque su contrato no se puede escribir sin decidir esto. **Parte afectada:** SEC-117 y todo lo que depende de ella: la frontera (g), la condición 3 de la cláusula de §13, la fila nueva de §13, los comentarios de código de esa vía, la validación en el host, QA y seguridad. **Evidencia:** REQ-023, «Preguntas abiertas», P-SEC117; REQ-001 CA-10, CA-11 y CA-12; REQ-007 CA-46 (c); el recuento del banco. **Qué lo resuelve:** tu elección.
- **Qué sigue mientras tanto:**
  - La **corrección de texto de QA-023-06** ya está hecha por el analista, sin validar, en commit local. La vuelta agrupada no se parte, así que el desarrollador, QA y seguridad esperan a esta decisión.
  - La coordinadora decide por su cuenta, sin necesitarte, que el principio «una frase condicional no acredita protección» se aplique también a REQ-031 CA-A13 (el techo) en la misma pasada del analista. Es una sede de REQ-031 afectada por el mismo principio y está dentro de la autorización.

**Ficha 4 — RESUELTA por el propietario el 2026-09-30 (quinta autorización): SEC-119 se REPARA en esta frontera.** *Texto original, conservado:* QA-023-07 (`instrumento`, severidad alta, PREEXISTENTE; NO aceptado; añadida el 2026-09-30, escalada por QA como urgencia de seguridad). Una ruta con segmentos `..` que entra en `requirements/` o en el código protegido desde un directorio libre no la juzga ninguna puerta.
- **Consecuencia medida a nivel de hook, no en el host** (QA, 2026-09-30, igual en el candidato `cd47f06`, en `df550fa` y en 1.33.2; `docs/qa/REQ-023.md`, adenda de la vuelta excepcional, §10):
  - un `Edit` que cierra un REQ `critico` con QA pendiente, a través de una ruta con `..`, sale **allow**, sea literal o no literal;
  - un `Write` de la coordinadora a `<raíz>/docs/../src/a.ts` sale **allow** en `guard-codigo`.
- **Causa:** `arnes_ruta_relativa` y `arnes_norm_path` no resuelven los segmentos `..`.
- **Protección efectiva hoy:** ninguna mecánica en esa vía. **Depende de la disciplina:** que ningún agente construya rutas con `..`.
- **No es regresión:** 1.35.0 no lo introduce ni lo agrava; tampoco lo cierra.
- **Qué impide:** nada de REQ-023 por su clase. Puede impedir **publicar**, si el propietario lo decide.
- **Alternativas:**
  - **reparar antes de publicar**, con una reparación en ciclo propio, que la autorización vigente no abre automáticamente;
  - **aplazar**, con responsable propuesto `desarrollador` (lector de rutas) y `analista-requerimientos` (contrato), revisión propuesta el 2026-10-07 y revisión anticipada ante cualquier observación de una escritura por ruta con `..` en este repositorio o en un consumidor.
- **Valoración de seguridad** (R-045-A, 2026-09-30):
  - registrado como **SEC-119** (`instrumento`, alta), ampliado por propiedad: las puertas deciden por la **ruta escrita**, no por la canónica. A nivel de hook, en tres árboles, `docs/../requirements/`, `././requirements/` y un directorio enlazado evaden `guard-completado`, y lo mismo pasa con `guard-codigo` para `src/`;
  - remedio de sede única: canonicalizar la ruta y usar `test -ef` en `arnes_ruta_relativa`, sin procesos nuevos;
  - **recomienda reparar antes de publicar**, porque tiene el mismo efecto que SEC-117, un bypass total y silencioso, y alcanza además a `guard-codigo`;
  - en contra: no está ensayado en el host, no hay exposición accidental observada, y retener 1.35.0 deja a los consumidores sin SEC-117 ni SEC-047;
  - si se aplaza, la cláusula de §13 y las notas deben declarar SEC-119 como limitación de todas las filas.
- **Recomendación de la coordinadora:** coincide con el auditor en que es la misma clase de efecto que SEC-117, y tú ya fijaste no publicar con un bypass total aplazado. Recomiendo **reparar antes de publicar**, con una autorización expresa, porque la vuelta vigente no lo cubre.

**Decisión 7 — RESUELTA por el propietario el 2026-09-30 (quinta autorización): O-11 se corrige dentro de esta misma frontera.** *Texto original, conservado:* O-11 (QA, 2026-09-30): la vía del archivo ilegible (NUL en disco, SEC-002) queda fuera de CA-13. Con NUL en el disco, una edición no reconstruible que no escribe la palabra del estado terminal recibe permiso, y CA-13 (iv) lo excluye con la causa que da la tercera autorización («porque no encuentra literalmente el texto anterior»). Pero tu cuarta autorización reformula la propiedad **sin esa causa** («una edición sobre un REQ protegido que el hook no puede reconstruir no puede recibir permiso silencioso»).
- **Pregunta:** ¿la vía del archivo ilegible entra en la propiedad?
- **Opciones:**
  - **(A)** No: se queda como está, declarada en CA-13 (iv), con SEC-002 como sede. La **consecuencia** es un residuo estrecho: requiere un NUL ya escrito en el REQ.
  - **(B)** Sí: se repara en ciclo propio (denegar toda edición de un REQ ilegible), fuera de esta vuelta.
- **Recomendación de la coordinadora:** (B) como trabajo siguiente, fuera de esta vuelta, y declararlo mientras tanto. Es la misma clase de defecto, pero su causa, el disco ilegible, es distinta de la que reparó esta vuelta.
- **Valoración de seguridad** (R-045-A): **(B)**. La propiedad de la cuarta autorización lo alcanza de lleno. Tiene un productor natural conocido: PowerShell 5.1 escribiendo en UTF-16LE. El remedio es denegar todo `Edit`/`MultiEdit` de un REQ que no se puede leer entero, dejando `Write` como salida. Si se elige (A), la cláusula de §13 tiene que llevar escrita la excepción antes de publicar.
- **Qué sigue mientras tanto:** la determinación de seguridad.

**Decisión 8 — RESUELTA por el propietario el 2026-10-01 (sexta autorización, § Resueltas): opción (A), con la condición de parada de QA-023-10 escrita por él.** *Texto original, conservado:* la vuelta excepcional de la quinta autorización termina con QA NO favorable. ¿Cómo sigue la reparación de SEC-119 y O-11?
- **Qué ocurrió.** QA revisó el delta `104ffd1..43b948a` (`docs/qa/REQ-023.md` § «Vuelta excepcional de la quinta autorización»).
  - **Conforme:** CA-45, CA-46 (b), (d) y (e), CA-47 a CA-50, la nota de CA-58, CA-60 y CA-66 puntos 1 a 5, 7 y 8, con el fail-before re-derivado contra `9596e39` y 1.33.2. Banco completo 1322 PASS · 0 FAIL · 12 SKIP, cuadre 1334; autoprueba 117/0; gates rc 0. QA-023-07 y QA-023-08 quedan **cerrados**.
  - **Tres hallazgos nuevos, los tres `contrato` en REQ-007:**
    - **QA-023-09 (alta a nivel de hook; regresión de `104ffd1`).** `arnes_parse_input` lee varios campos de una sola salida de `jq`, uno por línea, y el delta añadió el `cwd` delante de la ruta. Un `cwd` con salto de línea desplaza los campos, y las dos puertas juzgan otra ruta. Medido por inyección, por la ruta canónica: el cierre de un REQ `critico` con QA pendiente, la edición no reconstruible de SEC-117 y un `Write` de la coordinadora a código protegido salen **allow**, donde `9596e39` y 1.33.2 deniegan. Es un movimiento de deny a allow que CA-24 y CA-66 punto 5 no declaran. En REQ-023 QA lo registra como `instrumento`, porque la promesa que falla tiene su sede en REQ-007 CA-47.
    - **QA-023-10 (media).** CA-54 exige menos de 5 s en el máximo de análisis de `Bash` (131 072 bytes). El candidato tarda de 9,5 a 12,1 s, en quince corridas: concluyente en WSL2. `9596e39` tardaba de 2,9 a 6,9 s y ya lo superaba en una de las tres formas. En el valor por defecto (65 536 bytes) el candidato también lo supera. No hay fallo en abierto medido: queda un margen de unas cinco veces hasta los 60 s.
    - **QA-023-11 (media).** La validación en el host no ejecutaba ni declaraba R5 ni el `cwd` tras un `cd` (CA-45 y CA-66 punto 6).
- **Lo que hizo después la coordinadora.** Es validación ya autorizada (quinta autorización, punto 5), no una reparación. Ejecutó en el host real los dos casos que faltaban, con registro previo `f209d06` y resultado `7a3cb6e` (rama local de evidencia, `sec119-v3b/`). CLI 2.1.285, una ejecución por caso:
  - el `cwd` que recibe el hook **sigue** a un `cd` hecho en una llamada anterior de `Bash`;
  - **QA-023-09 se manifiesta en el host.** Con un directorio cuyo nombre lleva un salto de línea, el `cwd` llega literal al hook. El hook no juzgó la ruta canónica que pidió la herramienta: juzgó un fragmento del `cwd`. Denegó **sólo** porque, con el nombre ensayado, ese destino desplazado no se podía determinar, y CA-47 hace que lo no determinable no pase. No se ensayó un nombre con el que sí se pueda determinar, así que **un permiso desde el host no está observado ni descartado**. El control sin salto de línea se juzgó por su ruta real;
  - **R5 no llega al hook:** el `Read` previo falla con `EACCES` y no hay `Edit` que juzgar. CA-45 frente a un archivo sin permiso de lectura sigue verificado sólo a nivel de hook. Para ese caso, QA-023-11 pide que el analista lo declare como límite.
- **Acción que impide (regla 2):**
  - **publicar** 1.35.0. En la ficha 4 decidiste no publicar con un rodeo total aplazado, y QA-023-09 rodea las dos puertas por completo; 1.33.2 y `v1.34.0` no tienen ese rodeo;
  - **cerrar** REQ-007, que suma tres `contrato` (ya no cerraba por QA-114, QA-116 y QA-117);
  - la **determinación de seguridad** de esta vuelta: el auditor no firma sobre un árbol sin QA favorable (§6).

  Por su clase, **no** impide cerrar REQ-023, REQ-031 ni REQ-001: QA mantiene su `QA: aprobado` sobre el código final, sin cubrir QA-023-09. Cerrarlos lo impide ya la cola.
  - **Parte afectada:** las dos puertas, ante cualquier entrada cuyo `cwd` lleve un salto de línea (QA-023-09); el análisis de `Bash` en su máximo y en su defecto (QA-023-10); el texto de CA-45 y CA-66 (QA-023-11).
  - **Evidencia:** `docs/qa/REQ-023.md` §9, con sus anexos `11-cwd-salto-de-linea.txt` y `30-ca54-coste.txt` (rama local de evidencia, `cand-1.35.0/evidencia-qa-sec119/`, `66de607`), y `sec119-v3b/RESULTADO.md` (`7a3cb6e`).
  - **Qué lo resuelve:** tu decisión. La quinta autorización dice que una vuelta que termina con un bloqueo no abre otra automáticamente.
- **Opciones:**
  - **(A) Otra vuelta excepcional, acotada a los tres hallazgos y sin reiniciar contadores** (el de REQ-023 sigue en 3 de 3).
    - **Desarrollador, QA-023-09:** se corrige en el código, sin cambio de contrato. Ningún salto de línea en el `cwd` puede desplazar un campo; la técnica la elige él. Lleva fail-before contra `43b948a` y control opuesto.
    - **Desarrollador, QA-023-10:** optimizar la identificación por destino.
    - **Analista:** declara R5 como límite en CA-45 y en el punto 6 de CA-66 (QA-023-11).
    - **Después:** QA, y seguridad con QA favorable.
    - **Consecuencia:** una vuelta más. QA-023-09 es un delta pequeño y localizado en un solo sitio; QA-023-10 es la parte con resultado incierto.
  - **(B) Retirar del candidato la reparación de SEC-119 y O-11** (el código de los hooks vuelve a `9596e39` más SEC-117) y publicar con SEC-119 y O-11 declarados como limitación.
    - **Consecuencia:** contradice tu decisión de la ficha 4. Además, vuelven a quedar abiertos los vectores alcanzables desde el host que la v3 mostró cerrados: el directorio enlazado por `Edit`, `..` por `Bash` y el REQ en UTF-16. Se nombra sólo porque es la alternativa a reparar.
  - **(C) Esperar:** ni reparar ahora ni publicar.
    - **Consecuencia:** 1.35.0 queda retenida, y SEC-047 y SEC-117 no llegan a los consumidores.
- **Recomendación de la coordinadora:** **(A)**, con una condición de parada para QA-023-10. Si la optimización no deja el máximo por debajo de 5 s, el desarrollador para y la cifra vuelve a ti. La regla de CA-54 permite bajar el máximo sin ADR, pero el candidato tampoco cumple en el valor por defecto. Bajar de ahí cambia lo que se deniega por presupuesto en todos los proyectos, y eso no es una medición: es una decisión. QA-023-09 es una regresión de este mismo delta, tiene causa localizada y no cambia el contrato; la v3b muestra que se manifiesta en el host.
- **Relación con P-119-A**, la pregunta abierta de REQ-007 sobre las fronteras F2, F3, F5 y F7, que también espera tu respuesta.
  - Aceptar F7 declarada **no** cubre QA-023-09. F7 deja fuera lo que el host haga con la ruta, y que el `cwd` sea el directorio del comando. QA-023-09, en cambio, es una puerta que lee mal un campo que sí recibe, y CA-24 prohíbe ese movimiento sin excepción.
  - La v3b además ya midió parte de F7: el `cwd` sigue al `cd`.
- **Trabajo que sigue mientras tanto:** ninguno de implementación ni de revisión. Esta vuelta queda registrada en el candidato con un commit local, y la evidencia en la rama local de evidencia. **El push de `cand/1.35.0` y el CI sobre la cabeza actual no se han hecho:** `origin` y el PR #59 siguen en `9596e39`. No hacen falta para decidir.

**Decisión 9 — 9a RESUELTA por el propietario el 2026-10-02 (séptima autorización, § Resueltas): se repara QA-023-13, y puede denegarse un `cwd` que contenga CR. 9b SIGUE PENDIENTE y NO está autorizada: «medir en Windows no sustituye el criterio vigente de menos de 5 segundos ni equivale a aceptar que un timeout deje pasar la operación». En esta vuelta se prepara su decisión.** *Texto original, conservado:* la vuelta de la sexta autorización termina con QA NO favorable por un hallazgo nuevo, QA-023-13; y QA-023-10 sigue abierto tras su parada. ¿Cómo sigue el candidato?
- **Qué ocurrió.** La vuelta se hizo entera: desarrollador, analista, host y QA con Opus (`docs/qa/REQ-023.md` § «Vuelta excepcional de la sexta autorización»; evidencia en la rama local de evidencia, `0d3d0c9`).
  - **QA-023-09, cerrado.** La entrada del hook se lee campo a campo y entera (`cd6afa6`). Un `file_path` o un `tool_name` con LF es no determinable (CA-47 puntos 12 y 13). En el host real, con un `cwd` con salto de línea, las dos puertas juzgan la ruta pedida y el control legítimo pasa (`sec119-r6/`, `3eb279d`).
  - **QA-023-11, cerrado.** CA-45 incorpora la v3b: el `cwd` sigue al `cd`, y R5 queda como límite de la comprobación en el host.
  - **QA-023-10, abierto.** La optimización no alcanzó los 5 s (6,5–9,5 s en 131 072), se detuvo como mandaste y salió del candidato. Queda conservada como parche en la evidencia (`3b947a1`). El árbol final cuesta lo mismo que `43b948a`: 8,6–10,3 s según el desarrollador y 9,0–9,2 s según QA, frente a 2,9–7,2 s de `9596e39`. QA verificó que la parada fue fiel.
  - **QA-023-13, nuevo** (`contrato` en REQ-007, `instrumento` en REQ-023). `arnes_sin_cr_transporte` recorta el CR final de cada campo, porque el `jq` de Windows termina las líneas en CRLF. Un CR que forma parte del nombre del `cwd` desaparece, y la puerta ancla las rutas relativas de `Bash` en otro directorio que el shell.
    - **Medido a nivel de hook en la cabeza actual** (`evidencia-qa-r6/27-repro-CR-cwd.txt`): desde un directorio cuyo nombre termina en CR y enlaza a la raíz, el shell escribe en `<raíz>/src/a.ts`. Pero `echo x > src/a.ts` de la coordinadora y un `sed -i` que cierra un REQ en rojo salen **allow**, donde `9596e39` y 1.33.2 deniegan.
    - **De dónde viene:** nace con el anclaje en el `cwd` que introdujo la reparación de SEC-119 (`104ffd1`). No es del delta de esta vuelta.
    - **Qué exige:** un directorio con ese nombre, enlazado a la zona protegida, y un `cd` a él. Es ofuscación deliberada, no descuido. Alcanzable desde el host: sin medir.
    - **Qué desmiente:** CA-47 punto 11 («anclado en el `cwd` entero») y CA-66 punto 5 («ninguno nuevo de deny a allow»).
- **Acción que impide (regla 2):**
  - la **determinación de seguridad** del delta de SEC-119/O-11: el auditor no firma sin QA favorable (§6), y no ha firmado nada desde R-045-A (`8745b3f`);
  - **publicar** 1.35.0: QA-023-13 es un rodeo frente a lo publicado, y en las fichas 3 y 4 decidiste no publicar con un rodeo total aplazado;
  - **cerrar** REQ-007.

  **No** impide cerrar REQ-023, REQ-031 ni REQ-001 por clase (`QA: aprobado` sobre `9c53232`), pero lo impide ya la cola.
  - **Parte afectada:** las rutas relativas de `Bash`, en las dos puertas, cuando el `cwd` termina en CR (QA-023-13); y el coste del análisis de `Bash` (QA-023-10).
  - **Evidencia:** la citada arriba.
  - **Qué lo resuelve:** tu decisión. La sexta autorización no abre otra vuelta automáticamente.
- **9a — QA-023-13. Opciones:**
  - **(A) Reparar fallando cerrado, en una vuelta excepcional acotada, sin reiniciar contadores.** El analista añade en CA-47 la causa, como hizo con el punto 12: un `cwd` cuyo texto contiene un CR no ancla una relativa, que pasa a ser no determinable. Otra técnica que preserve el CR del contenido la elige el desarrollador, si existe sin procesos nuevos. Después, desarrollador, QA y seguridad.
    - **Consecuencia:** una vuelta más, de delta pequeño. Una escritura relativa por `Bash` desde un directorio con CR en el nombre se deniega, y eso en la práctica no existe.
  - **(B) Aceptar la frontera del CR y declararla.** El analista la escribe en CA-47 y la añade como séptimo movimiento de deny a allow en CA-66 punto 5. Después, QA del texto y seguridad.
    - **Consecuencia:** 1.35.0 publicaría un rodeo frente a 1.33.2 que exige ofuscación deliberada. Es coherente con «barandilla, no jaula» (§13), pero no con la línea que mantuviste en SEC-117 y SEC-119.
- **9b — QA-023-10. Opciones:**
  - **(A) Publicar con CA-54 incumplido, como residual declarado.** Dueños: `desarrollador` y `analista-requerimientos`. Vencimiento: la versión siguiente. Forzador: un hook de `Bash` muerto por tiempo, o una medición en Windows. Las notas ya lo declaran.
    - **Consecuencia:** el análisis de `Bash` en el máximo tarda unos 9 s en WSL2, frente a 3–7 s en 1.33.2. No hay fallo en abierto medido: hay más de cuatro veces de margen hasta los 60 s. **Pero en Windows/MSYS no está medido**, y allí cada sentencia de bash cuesta más. Si el factor pasara de unas seis veces, el hook moriría por tiempo y dejaría pasar, que es la clase de SEC-115.
  - **(B) Incorporar la optimización conservada** (6,5–9,5 s) y decidir el diseño del trabajo por destino.
    - **Consecuencia:** sigue sin cumplir los 5 s. Reintroduce un refactor de las funciones de identidad de SEC-119, con otra vuelta de QA y de seguridad.
  - **(C) Bajar el máximo, y el defecto, por la regla de CA-54** hasta que cumpla.
    - **Consecuencia:** cambia, en todos los proyectos, qué comandos de `Bash` se deniegan por presupuesto. Bajar el defecto no es una medición: es una decisión.
- **Recomendación de la coordinadora:**
  - **9a (A).** El defecto es de identidad, la misma clase que reparaste en SEC-119, y fallar cerrado cuesta un delta pequeño.
  - **9b (A),** con una condición antes de publicar: medir el caso del máximo en Windows/MSYS. Si se acerca a los 60 s, la decisión vuelve a ti con esa cifra.
  - Las dos caben en una sola vuelta excepcional.
- **Junto a esta decisión siguen pendientes:** la ficha 1 (SEC-115/SEC-118), la ficha 2 (C) y P-119-A. Ninguna está aceptada. Aceptar F7 no cubre QA-023-09 ni QA-023-13.
- **Trabajo que sigue mientras tanto:** ninguno de implementación ni de revisión. La coordinadora sólo completa lo que la sexta autorización ya cubre: push, CI sobre la cabeza final y actualización del PR #59 en borrador.

**Decisión 9b, preparada el 2026-10-02 (séptima autorización, punto 4): QA-023-10, separando tres cosas. NO autorizada. Ningún residual aceptado.**
1. **El incumplimiento de latencia medido.** CA-54 exige menos de 5 s en el máximo de análisis de `Bash` (131 072 bytes). El candidato no cumple en ninguna de las dos plataformas medidas:

   | Plataforma | Candidato | `9596e39` | Fuente |
   |---|---|---|---|
   | WSL2 (Linux) | 8,6–10,3 s (desarrollador) y 9,0–9,2 s (QA) | 2,9–7,2 s | `evidencia-dev-r6/38-`, `evidencia-qa-r6/25-` |
   | Windows/MSYS | **20,4–28,9 s**, en las 15 corridas | — (ver punto 2) | `sec-ca54-win/`, `c51c5c7` |

   En WSL2, la base ya incumplía en una de las tres formas. **El incumplimiento está medido y es concluyente en las dos plataformas.**
2. **El riesgo de agotar el tiempo límite y terminar sin decisión.** Es otra cosa, y es la clase de SEC-115 (ficha 1, no aceptada).
   - **En WSL2:** ninguna corrida se acerca a los 60 s, ni en el candidato ni en la base.
   - **En Windows/MSYS, en esta máquina y con una ejecución:** el candidato no llegó al límite (máximo 28,9 s, unas 2,1 veces de margen). **`9596e39` llegó al límite en las 15 corridas del caso máximo**, y un hook cortado así termina sin decisión.
   - **Lectura:** en estas condiciones, el candidato está más lejos del límite que la base. La base equivale a lo publicado en esta vía, aunque 1.33.2 no se midió en Windows. Eso **no** demuestra que el riesgo no exista: un equipo más lento o más cargado podría llegar al límite, y un margen de 2,1 veces no es una garantía. Tampoco convierte la latencia en aceptable.
3. **Las plataformas y condiciones realmente comprobadas.**
   - **WSL2:** Linux 6.18, bash 5.3.9 y jq 1.8.2, en varias corridas de la sonda de QA, de desarrollador y de QA.
   - **Windows:** 10.0.26200, PortableGit con bash 5.3.15, MSYS 3.6.9 y jq 1.8.2 nativo, con el hook invocado directamente, archivos en NTFS, una ejecución en una máquina y registro previo (`5510675`).
   - **No comprobado:** el cliente de Claude Code ejecutándose en Windows, otras máquinas, otras versiones de MSYS o Git Bash, Cygwin, y Windows bajo carga.
   - **Nada de esto valida Windows.**
- **Opciones** (sustituyen a las de 9b de arriba, que se conservan como historia):
  - **(A) Aceptar QA-023-10 como residual declarado de 1.35.0**: CA-54 incumplido, con la latencia de la tabla en las notas. Necesita que tú fijes el dueño, el forzador y el vencimiento. REQ-007 no se cierra.
    - **Consecuencia:** el análisis de `Bash` es más lento que en `9596e39` en Linux (2–3 veces). En Windows, en esta máquina, el candidato termina con decisión donde la base agotaba el tiempo. El riesgo de la ficha 1 sigue sin aceptar y aparte.
  - **(B) Retener la publicación hasta cumplir CA-54.**
    - **Consecuencia:** hace falta otra vuelta de diseño. La optimización conservada no bastaba ni en WSL2 (6,5–9,5 s), y en Windows la distancia es de 4 a 6 veces. Es trabajo del tamaño de una versión propia, y mientras tanto los proyectos siguen con la versión publicada.
  - **(C) Cambiar el contrato de CA-54**, por ejemplo bajando el máximo y el defecto o declarando la cifra por plataforma. **Es decisión exclusivamente tuya:** tu autorización me prohíbe reducir el máximo o subir umbrales.
    - **Consecuencia:** cambia, en todos los proyectos, qué comandos se deniegan por presupuesto.
- **Recomendación de la coordinadora:** **(A)**, si tú fijas sus condiciones.
  - **Por qué:** el incumplimiento es real, pero retener 1.35.0 por él dejaría a los proyectos con una base que, en esta medición de Windows, sí agotaba el tiempo en el caso máximo.
  - **Lo que (A) no hace:** no acepta que un timeout deje pasar la operación. Ese riesgo sigue en la ficha 1, sin aceptar.

**Decisión 10 — RESUELTA por el propietario el 2026-10-02 (octava autorización, § Resueltas): se reparan las dos caras de SEC-122, junto con QA-023-14 y P-023-13-A, en una intervención agrupada.** *Texto original, conservado:* SEC-122, registrado por seguridad en R-046.
- **Qué es:** una exclusión de ciertas rutas de sistema en la identificación del destino deja sin aplicar parte de CA-47 y CA-49 en casos concretos.
  - Una cara es **preexistente**.
  - La otra es una **regresión frente a 1.33.2, introducida por `104ffd1`** (la reparación de SEC-119, quinta autorización), y sólo afecta a proyectos situados bajo esas rutas.
  - No la introduce la séptima autorización.
  - Detalle y evidencia: `docs/seguridad/registro-seguridad.md` § R-046 y `cand-1.35.0/evidencia-seg-r7/` (`d7da950`).
- **Acción que impide (regla 2):**
  - **publicar**, a juicio del auditor, mientras no decidas;
  - **cerrar** REQ-007 (es `contrato`).
  - **Evidencia:** R-046.
  - **Qué lo resuelve:** tu decisión.
- **Opciones:**
  - **(A) Una vuelta acotada** que repare SEC-122 por la propiedad que fija R-046, con QA-023-14 dentro. **Lo recomiendan el auditor y la coordinadora.**
    - **Consecuencia:** otra vuelta corta: analista, desarrollador, QA y seguridad.
  - **(B) Declararlo como séptimo movimiento** y corregir F3, CA-49, CA-66 y las notas.
    - **Consecuencia:** 1.35.0 publicaría una regresión frente a 1.33.2, contra la línea que mantuviste en QA-023-09 y QA-023-13.
  - **(C) Retener la publicación** sin reparar.
- **Además:** P-119-A no puede presentarse con el texto actual de F3 hasta que el analista lo corrija (R-046).

**P-023-13-A — RESUELTA por el propietario el 2026-10-02 (octava autorización): se corrige el transporte del CR en el texto de los comandos de `Bash`, denegando explícitamente si no se puede preservar su significado.** *Texto original, conservado:* abierta por el analista el 2026-10-02; = QA-023-15, `instrumento`, preexistente en los cuatro árboles. El texto del comando de `Bash` sigue perdiendo un CR en el transporte, y eso queda fuera de esta reparación, porque excluiste reescribir el analizador de `Bash`. Está declarado en CA-47 punto 11 como límite conocido, no protegido y **no aceptado**.
- **Opciones:**
  - **(A) Declararlo fuera de la promesa de 1.35.0.**
  - **(B) Repararlo** en una vuelta propia.
  - **(C) Llevarlo con P-119-A.**
- **Recomendación del analista:** (A), sin que eso acepte nada.
- **Recomendación de la coordinadora:** decidirlo junto con la decisión 10. Si eliges una vuelta para SEC-122, que ésta valore si cabe dentro sin reescribir el analizador.

**QA-023-14** (`instrumento`, introducido por `3bc7d3c`; R-046 coincide): va con la **ficha 1**, como regresión de coste del candidato. Si se abre la vuelta de la decisión 10, se repara en ella.

**Decisión 11 — RESUELTA por el propietario el 2026-10-03 (§ Resueltas, entrada de esa fecha, texto literal): opción (B), con denegación por motivo explícito, sin eliminar caracteres ni juzgar un comando distinto, y aceptando la restricción de uso legítimo descrita en R-047 §3. La ejecución NO está autorizada todavía.** *Texto original, conservado:* **Decisión 11 — PENDIENTE (añadida el 2026-10-02): SEC-124, registrado por seguridad en R-047 sobre el delta de la octava autorización.**
- **Qué es:** un movimiento de deny a allow introducido por `9220c71` y no declarado. Está en el tratamiento del CR en un heredoc.
  - Medido como seguro por efecto en bash de Linux.
  - Descansa en una premisa no escrita sobre el shell.
  - Deja falsa la frase «siete clases, y sólo ésas» de CA-66 punto 5, de la nota de CA-24, de las notas `[1.35.0]` y de la guía.
  - Detalle: R-047 en `docs/seguridad/registro-seguridad.md`; evidencia en `cand-1.35.0/evidencia-seg-r8/` (`8837d3f`, `af2eddd`).
- **Acción que impide (regla 2):**
  - **publicar** con las notas actuales;
  - el **push y la corrida de CI** de esta intervención: la octava autorización los condiciona a que seguridad sea favorable para el delta;
  - **cerrar** REQ-007, que ya no cerraba.
  - **El presupuesto de la octava autorización está agotado:** se gastaron la implementación, QA, la pasada correctiva y su re-verificación.
- **Opciones:**
  - **(A) Write-back documental,** sin tocar código. Declara la clase por su propiedad y la premisa del shell, y después pasa por QA de texto y la determinación de seguridad. **Lo recomienda el auditor.**
  - **(B) Volver a denegar ese caso en código,** en una vuelta corta: desarrollador, QA y seguridad.
  - **(C) Retener la publicación.**
- **Recomendación de la coordinadora:** **(B).**
  - La premisa sobre el shell no está medida en Windows/MSYS, que es una plataforma donde se usa el arnés.
  - Volver al veredicto publicado cierra la clase sin depender de esa premisa.
  - Si prefieres no tocar código, (A) es coherente con la propiedad, siempre que la premisa quede escrita.

**Junto a esta decisión, registrados en R-047 (`instrumento`, no impiden por sí solos):**
- **SEC-123:** un límite ya declarado en F3 y en el punto 16 de CA-47, que está mal cuantificado y no dice que su consecuencia es un permiso. Es preexistente (1.33.2 también lo permite), y desde el host sólo se alcanza inyectando. P-119-A no puede presentarse sin corregir esos datos.
  - **Decidido por el propietario el 2026-10-03 (§ Resueltas):** corregir la descripción de F3, separando lo medido de lo inferido y declarando la consecuencia. **No** acepta el riesgo, **no** da por reparado el mecanismo y **no** resuelve P-119-A. Ejecución pendiente de autorización.
- **SEC-125:** preexistente y fuera del delta: una forma de escritura por `Bash` que el detector de escrituras no reconoce. No está declarada como límite.
  - **Opciones:** declararla en las notas (el mínimo que recomienda el auditor), o repararla en su propio vehículo.
  - **Decidido por el propietario el 2026-10-03 (§ Resueltas):** **reparar antes de publicar**; «una continuación de línea no demuestra por sí sola intención de evadir controles». Ejecución pendiente de autorización; el plan propone hacerlo en la misma comisión que SEC-124.

**Registrado, cerrado el 2026-09-30: QA-023-08** (`contrato`, baja, preexistente, contra REQ-007 CA-46 (b)). Lo cerró QA en la vuelta de la quinta autorización (`docs/qa/REQ-023.md` §9): CA-46 (b) está versionado y la puerta deniega todo `Edit`/`MultiEdit` sobre un REQ ilegible. *Texto original:* el criterio decía que con NUL en disco decide «la transición», y la puerta decidía si la edición menciona el estado terminal. Responsable: `analista-requerimientos` (write-back).

- **Recomendación de la coordinadora (propuesta, no decisión):**
  - **SEC-115 y C:** aplazarlos con esas fechas y publicar sus limitaciones en las notas de 1.35.0. SEC-115 tiene realismo bajo y un margen medido de más de 30× sobre los REQ reales; C no tiene reparación que quepa en esta versión sin ser otra versión.
  - **QA-023-02 / SEC-117:** es de severidad crítica y de realismo no bajo, pero preexistente y ajeno al alcance de 1.35.0. **El auditor (R-045 §3) recomienda lo mismo que la coordinadora:** publicarlo declarado y abrir su REQ de reparación de inmediato, como parche propio, con revisión el 2026-10-06. Motivo: el defecto ya está en 1.33.2 y en `v1.34.0`, que son las versiones instaladas, así que retener 1.35.0 no protege a nadie y deja vivo el bypass por variante que 1.35.0 cierra dentro de su frontera.
    - **Condiciones del auditor:** notas correctas y ficha 1 corregida (ya hecho aquí). Además, conviene ejecutar el lado del CLI en una sesión real antes de reparar.
    - **REQ-001:** el auditor recomienda añadir `SEC-117 (instrumento)` a su `Hallazgos abiertos:` sin tocar su `Estado:`. REQ-001 se reabriría por §9 cuando el REQ de reparación versione CA-10/CA-11. QA pide que tu decisión sobre esta ficha lo resuelva de forma expresa. **Registrarlas aquí no las convierte en riesgos aceptados.**
- **Espera (puesta al día 2026-10-03; manda sobre el párrafo histórico de debajo):**
  - **Estado:** `cand/1.35.0` local en `c0c8be2`, **sin push**; `origin` y el PR #59 (borrador) en `45368ce`, con CI `37032468437` en verde **sólo para `45368ce`**. La intervención de la octava autorización **terminó**: implementación, QA, pasada correctiva, re-verificación y seguridad R-047. **Su presupuesto está agotado** y su push y su CI siguen sin hacer, condicionados a una determinación de seguridad favorable al delta que SEC-124 impidió.
  - **Decidido el 2026-10-03 (§ Resueltas):** decisión 11 = (B); SEC-125 = reparar antes de publicar; SEC-123 = corregir la descripción de F3. **Ninguna de las tres autoriza ejecutar.**
  - **Pendiente del propietario, sin aceptar:** la **autorización de ejecución** de esas tres (plan en `propuesta-v1.35.0/plan-implementacion.md`); la **decisión 9b** (QA-023-10, CA-54); las **fichas 1** (SEC-115/SEC-118) y **2** (C); **P-119-A** (F2, F5, F7 y el límite de F3); **SEC-120** (vence el 2026-10-29).
  - **Trabajo que sigue mientras tanto:** ninguno de implementación ni de revisión. **Cerrar cualquier REQ** sigue impedido mientras esta entrada esté aquí.
- **Espera (texto anterior, conservado como historia):** decisión del propietario sobre las fichas 1 (SEC-115/SEC-118) y 2 (C), sobre **P-119-A** (REQ-007, «Preguntas abiertas») y sobre la **decisión 9b** (QA-023-10). La ficha 4 y la decisión 7 se resolvieron en la quinta autorización (2026-09-30). La decisión 8 (sexta autorización, 2026-10-01) cerró QA-023-09 y QA-023-11, y su vuelta terminó con QA no favorable por QA-023-13. La 9a (séptima autorización, 2026-10-02) abrió la vuelta que lo repara, en curso. La reparación de SEC-117 tiene QA favorable y seguridad aprobada (R-045-A, 2026-09-30), y SEC-117 quedó `mitigado`. La ficha 3 y la decisión 5 se resolvieron en la tercera autorización del 2026-09-29. La decisión 4 está resuelta y su corrección se hizo (`e7562e7`), con QA-023-05 cerrado. **Trabajo que sigue mientras tanto:** la vuelta de la séptima autorización (QA-023-13 y la preparación de la decisión 9b), que no depende de las fichas 1 y 2 ni de P-119-A. **Cerrar cualquier REQ queda pendiente** mientras esta entrada esté aquí.

### RESUELTA (propietario, 2026-10-03, novena autorización) — **Intervención excepcional en dos fases: fase 1 SEC-123 (corrección documental de F3), fase 2 SEC-124 (B) y SEC-125 (código, contrato y pruebas)**; analista → desarrollador → QA → seguridad con QA favorable; como máximo una pasada correctiva y su re-verificación; sin reiniciar contadores ni crear otro REQ; commits locales de trabajo validado; sin push

**Texto del propietario, literal e íntegro** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.35`, posterior al commit `fff53f4`):

> Continuemos con la reparación defensiva de `JJOVEGA/ArnesJuan`, candidato v1.35.0.
>
> ## Base y comprobación inicial
> Worktree `/home/juan/dev/ArnesJuan-v1.35`, rama `cand/1.35.0`, cabeza local
> reportada `fff53f4` sobre `c0c8be2`. Antes de cualquier cambio: `git status`,
> `git log -1`, confirma cabeza y rama, y conserva intactos los archivos sin
> seguimiento de `propuesta-v1.35.0/` (README.md, SEC-047.diff, evidencia/).
> No los añadas al índice.
>
> Instrucciones normativas: CLAUDE.md → AGENTS.md de ESTE worktree. No uses
> `rel/registro-1.33.0` como normativa.
>
> Lee antes de despachar: PENDING_APPROVAL.md (decisiones del 3 de octubre),
> docs/ESTADO.md (bloque vigente), propuesta-v1.35.0/TRASPASO.md y
> plan-implementacion.md, docs/seguridad/registro-seguridad.md R-047 §2, §3 y §4,
> requirements/REQ-007.md (CA-47 p.17, CA-66 p.5), ADR-016, notas [1.35.0] y los
> criterios afectados de REQ-001, REQ-023 y REQ-031.
>
> ## Decisiones del propietario ya registradas (no reabrir)
> - SEC-124: opción B. Denegación explícita del caso delimitado en R-047 §3.
>   No se eliminan caracteres en silencio, no se modifica el comando, no se
>   juzga ningún otro comando. Se acepta sólo la restricción concreta del uso
>   legítimo allí descrito.
> - SEC-125: reparar antes de publicar. Una continuación de línea por sí sola
>   no demuestra intención de evadir.
> - SEC-123: corregir la descripción de F3. El riesgo NO está aceptado y el
>   mecanismo NO está reparado.
>
> ## Autorización: novena intervención, excepcional
> Analista → desarrollador → QA → seguridad si QA es favorable. Como máximo una
> pasada correctiva y su re-verificación. Regístrala como excepción en la sede
> que exige el repositorio, sin reiniciar contadores ni crear otro REQ.
>
> El analista fija el comportamiento esperado y los criterios de aceptación; el
> desarrollador elige la técnica. No se exige diseño exhaustivo previo, pero cada
> cambio debe tener un resultado verificable. Resuelve sin consultarme los ajustes
> ordinarios de código, pruebas, contrato y trazabilidad dentro del alcance.
> Reutiliza firmas y evidencia vigentes; revisa sólo lo afectado y sus
> dependencias.
>
> ## Alcance en dos fases secuenciales, con commit local por fase validada
>
> ### Fase 1 — SEC-123 (documental, independiente)
> Corregir la descripción de F3 en REQ-007, ADR-016 y las notas [1.35.0]:
> - separar lo medido de lo inferido; lo medido son cuatro componentes de subida
>   desde una raíz de proyecto a cinco o más niveles de profundidad; permiso
>   indebido y efecto en disco medidos en hook y shell, no ejercidos en el host;
> - declarar la consecuencia operativa;
> - mantener F3 dentro de P-119-A como pendiente; ninguna redacción puede leerse
>   como "reparado", "mitigado" ni "riesgo aceptado".
> Verificación: revisión de QA documental y seguridad sobre coherencia entre las
> tres sedes. Commit local al validar. Esta fase se ejecuta completa antes de
> empezar la fase 2 y no depende de ella.
>
> ### Fase 2 — SEC-124 y SEC-125 (código, contrato y pruebas)
> Orden propuesto: SEC-124 y después SEC-125, porque SEC-125 debe preservar las
> reglas de comillas, CR y heredocs que SEC-124 toca. Si el desarrollador
> justifica invertirlo, que lo registre; en cualquier orden, la segunda
> reparación corre la regresión de la primera.
>
> Propiedades SEC-124 (sede: analizador de heredocs en hooks/lib.sh; sección 45
> del banco; REQ-007 CA-47 p.17 y CA-66 p.5; notas y referencias afectadas):
> - P1. El caso delimitado en R-047 §3 recibe DENY con motivo explícito que
>   identifica SEC-124.
> - P2. El texto del comando no se altera, sanea ni reescribe en ningún camino.
> - P3. Ningún otro caso de la sección 45 ni del banco cambia de decisión.
> - P4. El contrato describe la denegación como restricción concreta de ese caso,
>   no como regla general sobre heredocs ni CR.
> - P5. Windows: no medido para este delta. Declararlo; no afirmar cobertura.
>
> Propiedades SEC-125 (sede: reconocimiento de destinos de escritura; evidencia
> en R-047 §4; precedente en guard-git sólo como referencia a comprobar):
> - P6. Un destino de escritura que sería denegado sin la continuación de línea
>   descrita en R-047 §4 se deniega también con ella.
> - P7. El significado del comando se preserva: no se elimina la continuación
>   si eso cambia la semántica; no hay DENY por la mera presencia de una
>   continuación.
> - P8. Se preservan las reglas vigentes de comillas, CR y heredocs: regresión
>   obligatoria de los casos SEC-047, SEC-119 y SEC-122 y de la sección 45.
> - P9. No se copia la lógica de guard-git sin comprobar P7 y P8; si se reutiliza,
>   registrar qué se comprobó.
> - P10. Cobertura declarada por capa: hook directo, shell aparte, CLI real si
>   está disponible, extensión no. Sin medición del host, decirlo.
>
> ## Manejo del contenido técnico sensible
> - Los agentes referencian R-047 §3 y §4 por sección. No reproducen ni
>   reescriben las condiciones de explotación en documentos nuevos.
> - Los casos de prueba se construyen reutilizando la evidencia existente
>   (rama evidencia/prueba-despacho-2026-09-14, cand-1.35.0/evidencia-seg-r8/,
>   baterías t2–t5) por copia o referencia. No se redactan catálogos nuevos de
>   variantes.
> - Si un control del proveedor detiene una acción: no reintentar por vía
>   indirecta, no delegar ese contenido, no cambiar de modelo ni de
>   configuración. Registrar el impedimento en el bloque manual de
>   docs/ESTADO.md y continuar con el siguiente elemento independiente de la
>   lista: fase 1 completa; dentro de la fase 2, la reparación no bloqueada y
>   sus pruebas; regresiones y banco sobre lo que sí cambió. No declarar
>   reparado nada cuya validación quedó pendiente.
>
> ## Validación
> Por reparación: pruebas aisladas del caso, controles legítimos (lo que debe
> seguir permitido) y regresiones afectadas. Sobre la cabeza final: banco
> completo y gates exigidos. Conservar todo FAIL con su cabeza y entorno; un
> SKIP o INCONCLUSO no acredita. Distinguir hook directo, shell aparte, CLI
> real y extensión.
>
> ## Límites
> Fuera de alcance y sin aceptar: CA-54 / QA-023-10, SEC-115, SEC-118, hueco C,
> SEC-120, F2/F5/F7 de P-119-A, coste de normalización en Windows, integración
> VS Code. No subir umbrales ni reducir límites de entrada. No cambiar contrato
> para acomodar un resultado. Defectos nuevos independientes: registrar sin
> encadenar reparaciones. Nada en AGENTS.md.
> Autorizo commits locales de trabajo validado. No autorizo push, CI remoto,
> fusión, cierre de requisitos, tags, publicación ni cambios en SENDA, Adelantos
> o demo-conciliador.
>
> ## Entrega
> Un único resumen: cabeza final; cambios por fase con archivos; evidencia de
> funcionamiento por capa; cobertura de QA y seguridad con firmas y su delta;
> impedimentos registrados; pendientes concretos. Si el presupuesto o un control
> impiden terminar, conserva el trabajo validado y di exactamente qué quedó
> incompleto y por qué.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Base comprobada antes de editar (2026-10-03):** `cand/1.35.0` en `fff53f4`. En el árbol: `M docs/ESTADO.md` (la línea del impedimento anterior y el bloque derivado) y, sin seguimiento, `propuesta-v1.35.0/README.md`, `SEC-047.diff` y `evidencia/`, que no se añaden al índice.
- **Contadores:** no se reinicia ninguno y no se crea ningún REQ. El de REQ-023 sigue agotado (3 de 3). Todo el trabajo es de REQ-007.
- **Orden, en serie:**
  - **Fase 1:** analista (F3) → QA documental (Opus, §5) → seguridad documental → commit local.
  - **Fase 2:** analista (contrato) → desarrollador → QA (Opus) → como mucho una pasada correctiva y su re-verificación → seguridad con QA favorable → commit local.
- **Precisión que la coordinadora pasa al analista:** el resumen de la fase 1 («cuatro componentes de subida desde una raíz de proyecto a cinco o más niveles») no coincide palabra por palabra con R-047 §2. R-047 midió con la raíz a siete niveles, con permiso a cuatro, cinco y seis subidas, y declara que la exigencia de una raíz a cinco o más niveles se sigue de su análisis. Como el propio encargo pide separar lo medido de lo inferido, el analista escribe lo que R-047 midió y lo registra como precisión en la «Correspondencia con el encargo», sin cambiar el pedido.
- **Resuelve:** la autorización de ejecución pendiente de las decisiones del 2026-10-03. **Siguen pendientes y sin aceptar:** CA-54 (9b), SEC-115/118 (ficha 1), C (ficha 2), F2/F5/F7 (P-119-A) y SEC-120.
- **Aclaración del propietario, 2026-10-03, durante la fase 1** (pregunta de la coordinadora y respuesta elegida, literales). La revisión documental de QA de la fase 1 salió con hallazgos (QA-023-18, `contrato`, baja; `docs/qa/REQ-023.md`). Pregunta: «QA-023-18 (contrato, baja; F3 presenta como medida una generalización inferida) exige una pasada correctiva en la fase 1. Tu autorización dice «como máximo una pasada correctiva y su re-verificación». ¿Cómo se cuenta?». **Respuesta: «Una por fase (Recomendado)»**, cuya descripción decía: «La gasto ahora en QA-023-18 (analista corrige, QA re-verifica, seguridad documental, commit de la fase 1) y la fase 2 conserva su propia pasada». **Contador:** la fase 1 gasta su única pasada correctiva en QA-023-18, y la fase 2 conserva la suya.
- **Decisiones del propietario, 2026-10-03, durante la fase 2, sobre el contrato del analista** (preguntas de la coordinadora y respuestas elegidas, literales; contrato en REQ-007 CA-47 puntos 18 y 19 y CA-66, versionado de la fase 2):
  - Pregunta: «SEC-124 (B): para cumplir P1, P2 y «no se juzga ningún otro comando», el analista fija la denegación POR LA FORMA del caso de R-047 §3, a todo agente (también el desarrollador) y aunque lo que sigue sea inocuo (HC5, HC6). Lo publicado sólo denegaba cuando lo que seguía era una escritura protegida, así que esto deniega algo más que lo publicado. ¿Lo aceptas?». **Respuesta: «Sí, por la forma (Recomendado)»**.
  - Pregunta: «SEC-125: preservar el significado (P7) hace que un caso que lo publicado denegaba sólo porque el trozo previo a la continuación casaba con el ámbito pase a permitirse, porque el destino real, una vez unido, está fuera (LC8). Es un movimiento deny→allow nuevo, seguro por efecto. ¿Lo aceptas?». **Respuesta: «Sí, declarado (Recomendado)»**.
  - **Efecto:** la frontera de SEC-124 (por la forma y a todo agente) y la clase LC8 de SEC-125 (deny→allow declarado) quedan confirmadas por el propietario. Ya no son sólo una precisión del analista.
- **Autorización del propietario, 2026-10-03, posterior a `c4ad408` (literal, la tarea del mensaje):**

  > ## Tarea única — completar el contrato con el caso (b)
  > Autorizo al analista a escribir UN caso en CA-66: la continuación de línea al
  > final de la línea que abre un heredoc. Debe fijar el comportamiento esperado
  > en las cuatro puertas, coherente con los puntos 18 y 19 de CA-47 y con la
  > decisión registrada sobre SEC-124 (denegar por la forma, a todo agente). Sin
  > cambiar ningún otro caso HC/LC ni ningún otro criterio. Actualiza sólo las
  > sedes que ese caso obliga a tocar (ADR-016, notas e índice si procede).
  >
  > Después, QA mide ese caso sobre el código vigente sin modificarlo: hook
  > directo y shell aparte, con cabeza, entorno y capa. Si contradice el
  > contrato, se registra como hallazgo sin reparar ni ajustar el contrato.
  >
  > Commit local al terminar, marcado SIN VALIDAR, con trazabilidad en ESTADO y
  > docs/qa/REQ-023.md. El caso (a), pliegue de guard-git ante barra escapada,
  > queda registrado como no medido y fuera de esta versión.

  **Lo que no hace, según el mismo mensaje:** no se despacha al desarrollador, no se implementan SEC-124 ni SEC-125, y no se tocan SEC-126, los no aceptados, `AGENTS.md` ni los contadores.
- **Decisiones del propietario, 2026-10-03, posteriores a `598792c` (literales):**

  > 1. P-LC10-A: opción A. La forma de LC10 (continuación de línea al final de la
  >    línea que abre un heredoc) se deniega por la forma, a todo agente, en las
  >    cuatro puertas, igual que SEC-124. Acepto que eso restrinja un uso legítimo
  >    raro. No se emula la unión de líneas del shell (B rechazada); no se deja
  >    QA-023-23 abierto en esta forma (C rechazada).
  > 2. QA-023-23: se registra en `Hallazgos abiertos:` de REQ-007 y en el registro
  >    de seguridad como hallazgo preexistente de clase instrumento. La forma de
  >    LC10 lo cierra; cualquier otra forma que lo exhiba sigue abierta y sin
  >    aceptar.

  **Tarea del mismo mensaje (literal):** «El analista ajusta el punto 19 de CA-47 y LC10 en CA-66 para reflejar A: denegación por la forma, a todo agente, con motivo que identifique SEC-125 y LC10, en guard-codigo, guard-completado, guard.sh y guard-git. El caso que hoy es "falso positivo" (la línea siguiente cierra el heredoc) queda cubierto por la misma denegación; declararlo. Sin tocar HC1–HC9 ni LC1–LC9 salvo referencias cruzadas. Actualiza ADR-016, notas, guía e índice sólo en lo que esta decisión obliga. Registra QA-023-23 donde indica la decisión 2, con su estado y la referencia a la medición de docs/qa/REQ-023.md. QA revisa la coherencia del contrato ajustado (documental; no hace falta volver a medir: la medición sobre c4ad408 sigue vigente como fail-before). Commit local al terminar, SIN VALIDAR, con trazabilidad en ESTADO.»

  **Lo que añade la coordinadora, rotulado como suyo:** cada sede tiene su dueño según `AGENTS.md` §5. El analista escribe el contrato. QA anota su propio hallazgo QA-023-23 en `Hallazgos abiertos:` de REQ-007, como en las vueltas anteriores. El `auditor-seguridad`, que mantiene `docs/seguridad/`, lo anota en el registro de seguridad: sólo el registro, sin revisión ni firma.
- **Decisiones del propietario, 2026-10-03, posteriores a `3158bf9` (literales; registradas sin despachar a ningún agente):**

  > 1. QA-023-25: precedencia de REQ-001 CA-53. Un comando que supera el
  >    presupuesto se deniega sin analizar con el motivo de CA-53; el motivo
  >    SEC-125/LC10 sólo aplica a denegaciones producidas por el análisis. El
  >    texto del punto 19 y de LC10 se ajusta en ese sentido.
  > 2. QA-023-24: corregir el punto 5 de CA-66 y las notas para reflejar que la
  >    forma ya se denegaba hoy cuando la escritura o la orden de git están en
  >    la propia línea, no sólo en LC10.8.
  > 3. Ambas correcciones de texto las aplica el propietario en el tramo de
  >    implementación manual, junto con el código. La única pasada correctiva de
  >    la fase 2 se reserva para el código. QA verifica texto y código juntos.
  > 4. La precisión declarada sobre guard-codigo y guard-git en LC10 se mantiene
  >    tal como está.

  **Lo que añade la coordinadora, rotulado como suyo:**
  - **Quién edita:** con la decisión 3, las correcciones de texto de REQ-007 (puntos 19 y LC10, punto 5 de CA-66) y de las notas las hace el propietario, no el `analista-requerimientos`. Es una excepción expresa a quién transcribe por §9.
  - **La pasada correctiva de la fase 2** queda sin gastar y reservada para el código.
  - **QA-023-24 y QA-023-25** siguen abiertos hasta que QA verifique el texto y el código juntos. Siguen fuera de `Hallazgos abiertos:`, como el precedente de QA-023-18.
  - **Nada cambia hoy** en REQ-007 ni en el código.
- **Decisión del propietario, 2026-10-03, posterior a `093e81e` (literal, la parte de la decisión):**

  > Autorizo un despacho al desarrollador para implementar SEC-124 y SEC-125
  > sobre el contrato ya comiteado. Es una autorización nueva sobre un estado
  > distinto al del impedimento anterior: el contrato está completo en el
  > repositorio y las decisiones P-LC10-A, QA-023-24 y QA-023-25 están
  > registradas. Si un control del proveedor detiene este despacho, se registra
  > en ESTADO y la implementación vuelve a manual, sin reintentos ni
  > reformulaciones.

  **Lo que hace la coordinadora, rotulado como suyo: el despacho NO se ejecuta.**
  - El control del proveedor ya detuvo antes este mismo despacho al `desarrollador` para implementar SEC-124 y SEC-125, y la instrucción que acompaña a ese bloqueo prohíbe volver a producirlo, también reformulado.
  - Un despacho nuevo con el mismo objetivo lo sería, aunque sólo remita a las sedes. Una autorización del propietario no levanta esa restricción.
  - Por la propia regla de esta decisión («sin reintentos ni reformulaciones»), **la implementación sigue siendo manual**.
  - No se despachó a nadie, y no cambian el código, REQ-007 ni los contadores. La pasada correctiva de la fase 2 sigue sin gastar.

- **Decisión del propietario, 2026-10-03, posterior a `92ec1fa` (literal; registrada por el propietario):**

  > 1. Validación del delta de la fase 2 por vía manual. Un control del proveedor
  >    detuvo al qa-tester al leer el diff de hooks/; no se reintenta ni se
  >    reformula. La validación la ejecuto yo con el protocolo de QA de CA-66
  >    fase 2 (gates, sección 46, regresiones, fail-before, banco, autoprueba y
  >    shell aparte), con una segunda medición de un revisor externo (Fable,
  >    Claude en claude.ai) sobre un clon, y con el CI remoto sobre la misma
  >    cabeza (run 37163342218: success). Registro en docs/qa/REQ-023.md.
  > 2. Sin firma del qa-tester ni del auditor-seguridad, y así se declara.
  >    QA: y Seguridad: de REQ-007 siguen pendiente. SEC-124 y SEC-125 se
  >    declaran reparados en su alcance; QA-023-23 cerrado en la forma de LC10 y
  >    abierto en cualquier otra; QA-023-24 y QA-023-25 cerrados por esta
  >    validación.
  > 3. El impedimento del proveedor de la novena autorización fue sobre el
  >    contenido del despacho de SEC-124/125 y sobre la lectura de su diff; no
  >    sobre los roles. Los encargos siguientes se redactan por propiedad y
  >    medida.
  > 4. La pasada correctiva de la fase 2 no se gastó.

  **Encargo del propietario, 2026-10-03, posterior a `ddd1241` (literal, la parte del despacho):**

  > ## Despacho: analista-requerimientos (sólo texto)
  > Write-back de estado en REQ-007, ADR-016, notas [1.35.0] del CHANGELOG, guía
  > (skills/arnes-upgrade/SKILL.md) e índice (requirements/README.md):
  > - Puntos 18 y 19 de CA-47 y CA-66 fase 2: de «pendiente de implementación y
  >   de validación» a «construido en 10ac6c4 y 36a0d27; validado por el
  >   propietario por vía manual (docs/qa/REQ-023.md, CI run 37163342218); sin
  >   firma del qa-tester ni del auditor-seguridad por impedimento del
  >   proveedor». Ni más ni menos que eso: no «aprobado», no «validado por QA».
  > - Hallazgos abiertos de REQ-007: SEC-124 y SEC-125 pasan a «reparado en su
  >   alcance (validación manual del propietario)»; QA-023-23 «cerrado en la
  >   forma de LC10; abierto en cualquier otra»; QA-023-24 y QA-023-25 cerrados
  >   por esa validación. QA: y Seguridad: de REQ-007 siguen `pendiente`.
  > - Registro de seguridad: entrada de sólo registro (R-050) que remite a la
  >   validación manual, sin firma del auditor.
  > - Las frases «Hasta que esté construido y validado, el candidato deja pasar
  >   esa forma» de las notas pasan a describir el estado construido.
  > Nada de nuevos hallazgos ni cambios de contrato. Commit local con CHANGELOG.

  **Lo que añade la coordinadora, rotulado como suyo:** por esta instrucción expresa del propietario, la entrada R-050 la escribe el `analista-requerimientos`, aunque `docs/seguridad/` es sede del `auditor-seguridad` (`AGENTS.md` §5). La entrada es **sólo de registro** y no lleva firma. Lo mismo vale para el cambio de estado de SEC-124 y SEC-125 en `Hallazgos abiertos:`.

### RESUELTA (propietario, 2026-10-03) — **Decisión 11 (SEC-124): opción B; SEC-125: reparar antes de publicar; SEC-123: corregir la descripción de F3**; autoriza sólo una actualización documental de continuidad y plan; **no autoriza implementación ni despachos**

**Texto del propietario, literal e íntegro** (mensaje del 2026-10-03 a la sesión coordinadora del worktree `ArnesJuan-v1.35`; es la fuente de estas decisiones, por declaración del propio mensaje):

> Autorizo una única actualización documental para dejar coherente la continuidad de v1.35.0 y preparar la siguiente ejecución. No autoriza modificar código ni despachar todavía al desarrollador, QA o seguridad.
>
> **Base**
>
> Trabaja en `/home/juan/dev/ArnesJuan-v1.35`, rama `cand/1.35.0`, cabeza reportada `c0c8be2`. El PR #59 y el remoto siguen en `45368ce`; su CI no acredita la cabeza local.
>
> Conserva los cambios preexistentes. No cambies de rama ni uses instrucciones de otro worktree.
>
> **1. Registra estas decisiones; este mensaje es su fuente**
>
> Yo, Juan Vega, el 2026-10-03, confirmo:
>
> - **SEC-124: opción B.** Restaurar la denegación mediante un motivo explícito para el caso descrito en R-047 §3, sin eliminar silenciosamente caracteres ni juzgar un comando distinto. Acepto la restricción concreta de uso legítimo descrita en ese informe.
> - **SEC-125: reparar antes de publicar.** Una continuación de línea no demuestra por sí sola intención de evadir controles.
> - **SEC-123: corregir la descripción de F3**, separando lo medido de lo inferido y declarando la consecuencia. No acepto el riesgo ni doy por reparado el mecanismo.
>
> Conserva una copia literal de estas decisiones en la sede vigente de `PENDING_APPROVAL.md`, identificando este mensaje y su fecha. Referénciala desde el plan, sin reconstruir mensajes anteriores.
>
> Resuelve únicamente las preguntas que estas elecciones contestan. La ejecución, los demás riesgos y la publicación siguen pendientes.
>
> **2. Corrige la continuidad**
>
> Actualiza las partes manuales de `docs/ESTADO.md` y el cierre «Espera» de la cola:
>
> - cabeza local y remota;
> - intervención terminada y presupuesto agotado;
> - decisiones ya tomadas;
> - siguiente paso real.
>
> Elimina las contradicciones entre bloques vigentes conservando el historial como historial. No edites manualmente el bloque derivado ni borres cambios ajenos.
>
> **3. Completa el plan al nivel necesario para encargar el trabajo**
>
> En `propuesta-v1.35.0/plan-implementacion.md`:
>
> - Sustituye el diseño técnico obligatorio por las propiedades que deben cumplirse, las restricciones y las dependencias. La técnica de implementación corresponde al desarrollador.
> - Completa la validación prevista con resultados esperados, controles legítimos y referencias a los casos existentes de R-047. No hace falta copiar reproducciones ejecutables.
> - Incluye ambas reparaciones en una misma comisión propuesta del desarrollador y la corrección documental de F3.
> - Define los archivos y contratos afectados, la evidencia reutilizable, las condiciones de salida y la condición de parada.
> - Propón el presupuesto de comisiones y pasadas correctivas sin reiniciar contadores.
> - Distingue la comprobación pendiente en el CLI dentro de WSL de la integración con la extensión de VS Code.
>
> Conserva las propuestas históricas de SEC-047 del 29 de septiembre. Identifica su fecha y carácter histórico desde el plan; no las mezcles con el alcance actual ni las reescribas.
>
> Si el documento queda completo para decidir la ejecución, cambia su aviso a **«Plan propuesto completo; implementación pendiente de autorización»**. Si falta una parte esencial, conserva el aviso de incompleto y nombra el impedimento.
>
> **4. Límites**
>
> No aceptes CA-54, SEC-115/118, el hueco C, SEC-120 ni las fronteras restantes de P-119-A. No cambies criterios normativos, estados de requisitos, veredictos ni contadores en esta intervención.
>
> Reutiliza la evidencia existente: sin pruebas, mediciones, auditorías generales ni nuevas comisiones. Si las reglas vigentes exigen un rol específico para alguna edición, identifica esa dependencia sin asumir sus facultades.
>
> La pausa de seguridad de la sesión anterior sigue siendo un impedimento registrado. No intentes reproducir contenido bloqueado ni sortear controles. Completa sólo las partes permitidas y declara cualquier limitación restante.
>
> **Entrega**
>
> Un resumen breve con:
> - documentos actualizados;
> - decisiones registradas y fuente;
> - orden de implementación;
> - presupuesto propuesto;
> - autorización concreta que faltaría para ejecutar.
>
> Sin commits, push, CI, fusión, cierre de requisitos, tags, publicación ni cambios en consumidores. No habilites conectores: no son necesarios para este encargo.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Base comprobada antes de editar (2026-10-03):** worktree `/home/juan/dev/ArnesJuan-v1.35`, rama `cand/1.35.0` en `c0c8be2`, 8 commits por delante de `origin/cand/1.35.0`. `origin` y el PR #59 (borrador) están en `45368ce`, comprobado con `git ls-remote` y `gh pr view`; su CI `37032468437` es de `45368ce` y **no acredita `c0c8be2`**. En el árbol, sólo lo preexistente: `M docs/ESTADO.md` y `?? propuesta-v1.35.0/`. Instrucciones: el `AGENTS.md` de este worktree.
- **Qué resuelve, y sólo eso:**
  - **Decisión 11 (SEC-124):** opción (B). Se elige entre las opciones de la entrada pendiente; R-047 §3 recomendaba (A) y objetaba a (B) que «juzgaría una estructura distinta de la que ejecuta el shell». La forma que fija el propietario —denegación con **motivo explícito**, **sin** eliminar caracteres **ni** juzgar un comando distinto— es la que responde a esa objeción, y el plan la escribe como propiedad.
  - **SEC-125:** de las dos opciones de R-047 §4 (declarar en las notas, o reparar en su propio vehículo), **reparar antes de publicar**. Meter la reparación en la misma comisión que SEC-124 es una **propuesta** del plan, pedida en el punto 3 de este mensaje, no una autorización.
  - **SEC-123:** corregir la descripción de F3 (CA-47 F3 y punto 16, adenda de ADR-016, notas, descripción de P-119-A). **No** acepta el riesgo, **no** da por reparado el mecanismo y **no** resuelve P-119-A, que sigue pendiente (F2, F5, F7 y el límite de F3).
- **Qué NO resuelve:** la ejecución (ninguna comisión autorizada; el presupuesto de la octava autorización está agotado), CA-54 (9b), SEC-115/118 (ficha 1), el hueco C (ficha 2), P-119-A, SEC-120 y la publicación. **Ningún residual queda aceptado.**
- **Qué no cambia esta entrada:** ningún criterio, estado, veredicto, campo `Hallazgos abiertos:` ni contador. SEC-123, SEC-124 y SEC-125 siguen `abierto` en REQ-007 hasta que se reparen o corrijan y se verifiquen. El de REQ-023 sigue agotado (3 de 3).
- **Dependencias de rol para ejecutarlo:** el contrato y el write-back (§9) son del `analista-requerimientos`, porque §6 de este `AGENTS.md` no declara la vía proporcional; el código de `hooks/` es sólo del `desarrollador`; después QA (Opus, §5) y seguridad con QA favorable. Plan: `propuesta-v1.35.0/plan-implementacion.md`.

### RESUELTA (propietario, 2026-10-02, octava autorización) — **Reparación agrupada de SEC-122 (ambas caras), QA-023-14, P-023-13-A / QA-023-15 y la corrección de F3**; intervención excepcional agrupada sin reiniciar contadores, con una pasada correctiva dentro del alcance; texto de plataformas autorizado

**Texto del propietario, literal e íntegro** (mensaje del 2026-10-02 a la sesión coordinadora del worktree `ArnesJuan-v1.35`):

> Autorizo la reparación agrupada de **SEC-122, ambas caras; QA-023-14; P-023-13-A / QA-023-15; y la corrección contractual de F3 directamente relacionada**.
>
> El objetivo es preparar v1.35.0 para publicar, cerrando estos problemas de identificación de rutas y transporte de entradas, sin abrir una reparación general del arnés.
>
> **1. Base y conservación**
>
> Trabaja en `cand/1.35.0`, partiendo de la cabeza reportada `45368ce`, PR #59. Comprueba la cabeza real y las instrucciones del worktree antes de modificar.
>
> Conserva los cambios preexistentes de `docs/ESTADO.md`, `propuesta-v1.35.0/`, las evidencias y todas las corridas anteriores. No recuperes la optimización descartada de CA-54.
>
> **2. Reparación autorizada**
>
> - **SEC-122:** elimina la exclusión indiscriminada de `/dev/` y `/proc/`. Los destinos resolubles por nombres deben pasar por la identificación y las reglas de protección correspondientes, conservando las comprobaciones de existencia y enlaces. Una identidad dependiente del proceso que no pueda determinarse de forma fiable no recibe permiso por esa incertidumbre. Conserva los usos legítimos previstos de `/dev/null` y `/dev/stderr` sin convertir sus nombres en una excepción general.
> - **QA-023-14:** elimina la sustitución superlineal introducida en `_arnes_repone_cr`. Puedes usar la detección en la lectura con `jq` propuesta, conservando íntegros los valores y las decisiones de protección. No sustituyas este coste por otra pasada superlineal.
> - **P-023-13-A:** corrige el transporte del CR en el texto de comandos Bash. Si el análisis no puede preservar su significado, deniega explícitamente; nunca lo elimines silenciosamente para juzgar un comando distinto. No reescribas el analizador general de Bash.
> - **Contrato:** el analista actualiza F3, CA-49, CA-66 punto 5 y las sedes directamente afectadas. F3 no debe desactivar las reglas de existencia, enlaces ni protección de destinos resolubles. Conserva el historial y declara los cambios de compatibilidad.
>
> **3. Autonomía y presupuesto**
>
> Autorizo una intervención excepcional agrupada, registrada sin reiniciar contadores: implementación, revisión de QA y, si aparecen defectos dentro de este mismo alcance, una pasada correctiva con su re-verificación de QA.
>
> No me pidas otra autorización por cada ajuste de código, fixture o texto directamente necesario para cumplir estas propiedades. Las decisiones técnicas ordinarias quedan delegadas dentro de este alcance.
>
> Después, seguridad revisa el delta cuando QA sea favorable. No abras más vueltas automáticamente ni incluyas defectos independientes. Si se agota este presupuesto, entrega el impedimento concreto y conserva el trabajo.
>
> **4. Validación proporcional**
>
> Reutiliza la evidencia vigente. Comprueba:
>
> - Las dos caras de SEC-122, con las dos puertas y controles legítimos.
> - El caso de CR en comandos Bash y la conservación de las reparaciones de LF/CR ya acreditadas.
> - Los casos relacionados de SEC-117 y SEC-119 que puedan verse afectados.
> - El coste de QA-023-14 con los tamaños ya usados, bajo un procedimiento fijado antes y sin repetir hasta obtener una cifra favorable.
> - Las secciones 41 a 44 y un banco completo sobre el código candidato final. Repite sólo lo necesario para verificar una corrección concreta o cumplir un gate vigente.
>
> Distingue decisión del hook, efecto en disco y comportamiento del host. No atribuyas al host lo que sólo se inyectó al hook.
>
> Mi entorno es VS Code con WSL. Conserva separadas las pruebas del CLI dentro de WSL y las de la extensión. Esta intervención no incluye una campaña nueva de plataformas ni instalar entornos. Si un control de seguridad impide una prueba, registra la limitación sin intentar rodearlo.
>
> **5. Plataformas y alcance de las conclusiones**
>
> Autorizo registrar el texto de plataformas propuesto, limitado a los casos realmente ejecutados:
>
> - Hook en Linux/WSL2.
> - CLI 2.1.285 en WSL2 mediante `claude -p`.
> - Hook en Windows/MSYS, en una máquina.
> - Sin comprobación de la extensión de VS Code, del CLI en Windows ni de otros clientes.
>
> Esto describe dónde se ejecutaron los casos; no acredita toda la plataforma ni todos sus comportamientos.
>
> La reparación agrupada tampoco garantiza por sí sola que el candidato quede publicable. CA-54, SEC-115/118, el hueco C y las fronteras restantes conservan sus decisiones pendientes.
>
> **6. Decisiones que siguen sin autorizarse**
>
> Esta autorización no acepta:
>
> - El incumplimiento de los 5 segundos de CA-54.
> - SEC-115 ni SEC-118.
> - El hueco C de escrituras mediante intérpretes.
> - F2, F5 ni F7 de P-119-A.
> - SEC-120 ni otros defectos independientes.
>
> No subas umbrales, no reduzcas límites de entrada y no conviertas un timeout sin decisión en un riesgo aceptado. La reparación de QA-023-14 no acredita por sí sola el cumplimiento de CA-54.
>
> **7. Entrega y PR**
>
> Autorizo los commits de esta intervención. Cuando QA y seguridad sean favorables para el delta autorizado, actualiza el PR #59 mediante push sin force y observa una sola corrida de CI sobre la cabeza final. Conserva el resultado; no relances para buscar verde.
>
> Entrega un único resumen con:
>
> - Cabeza final y alcance real del cambio.
> - Resultado antes/después de los tres problemas.
> - Mediciones de coste y sus límites.
> - Cobertura exacta de QA, seguridad y host.
> - Una lista consolidada de decisiones pendientes para publicar, sin duplicados.
>
> Si un hallazgo ajeno al alcance impide alguna firma, explica esa dependencia sin repararlo ni ocultarlo. Las firmas del delta no deben presentarse como aprobación completa del candidato si quedan impedimentos.
>
> No cierres requisitos, fusiones, crees tags, publiques ni actualices instalaciones o consumidores. No toques los PR #54, #57 ni #45.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Base comprobada antes de editar (2026-10-02):** `cand/1.35.0` local = `origin` = PR #59 = `45368ce`, en borrador. En el árbol, sólo los cambios preexistentes: `docs/ESTADO.md` y `propuesta-v1.35.0/`.
- **Contadores:** el de REQ-023 sigue agotado (3 de 3); no se reinicia ninguno y no se crea ningún REQ.
- **Orden, en serie (todo es REQ-007):** desarrollador → analista → QA (Opus, §5), con como mucho una pasada correctiva y su re-verificación → seguridad con QA favorable → push y una sola corrida de CI.
- **Resuelve:** la decisión 10 (SEC-122) y P-023-13-A, en reparación. **Siguen pendientes y sin aceptar:** CA-54 (9b), SEC-115/118 (ficha 1), C (ficha 2), F2/F5/F7 (P-119-A) y SEC-120.

### RESUELTA (propietario, 2026-10-02, séptima autorización) — **Decisión 9a: se repara QA-023-13** en una vuelta excepcional acotada, sin reiniciar contadores; **9b NO autorizada todavía** (QA-023-10: se prepara su decisión, con una comprobación acotada en Windows/MSYS si está disponible)

**Texto del propietario, literal e íntegro** (mensaje del 2026-10-02 a la sesión coordinadora del worktree `ArnesJuan-v1.35`):

> Continuamos con el objetivo de preparar una versión publicable del arnés, sin ampliar esta intervención a otras reparaciones.
>
> **Autorizo la decisión 9a y una vuelta excepcional acotada**, sin reiniciar contadores. **No autorizo todavía 9b**: medir en Windows no sustituye el criterio vigente de menos de 5 segundos ni equivale a aceptar que un timeout deje pasar la operación.
>
> ### 1. Base y conservación
>
> Trabaja en `cand/1.35.0`, partiendo de la cabeza reportada `452098e`. Comprueba la cabeza real, el estado del PR #59 y las instrucciones del worktree antes de modificar.
>
> Conserva los cambios preexistentes de `docs/ESTADO.md`, `propuesta-v1.35.0/`, las evidencias y todas las corridas anteriores. No recuperes la optimización descartada de QA-023-10.
>
> ### 2. Reparar QA-023-13
>
> Corrige el tratamiento del `cwd` con retorno de carro antes de que cualquier lectura o normalización pueda recortarlo.
>
> La propiedad exigida es: **las puertas deben juzgar la ruta real de la operación o denegar explícitamente cuando no puedan determinarla; nunca juzgar otra ruta por haber modificado silenciosamente el directorio recibido.**
>
> Autorizo denegar un `cwd` que contenga CR con un motivo preciso. Conserva el tratamiento ya validado de LF y las denegaciones de `file_path` y nombre de herramienta que quedaron registradas en la vuelta anterior.
>
> Revisa los puntos de lectura y transporte de estos campos directamente relacionados con el defecto. No conviertas esto en una reescritura general del analizador de Bash.
>
> ### 3. Validación acotada
>
> Reutiliza la evidencia y los casos existentes. Comprueba:
>
> - El caso de QA-023-13 antes y después, tanto para `guard-completado` como para `guard-codigo`.
> - Que siguen conformes los casos de LF de QA-023-09 y las reparaciones de SEC-117 y SEC-119 afectadas por este cambio.
> - Una operación legítima, verificando la decisión y el archivo resultante.
> - El caso CR en el host real, si el host permite construirlo. Si no, registra el impedimento y distingue expresamente la prueba directa del hook de la prueba del host.
>
> No repitas hasta obtener verde ni amplíes plataformas o matrices sin una necesidad concreta de esta reparación.
>
> ### 4. QA-023-10: preparar la decisión, sin cambiar el contrato
>
> No abras otra optimización en esta vuelta. Conserva el hallazgo y el criterio de menos de 5 segundos.
>
> Prepara una decisión breve con la evidencia existente que separe:
>
> 1. El incumplimiento de latencia medido.
> 2. El riesgo de agotar el timeout y terminar sin decisión.
> 3. Las plataformas y condiciones realmente comprobadas.
>
> Si Windows/MSYS está disponible, autorizo una comprobación acotada del caso máximo con procedimiento fijado antes de ejecutarla y todas las ejecuciones conservadas. Si no está disponible, declara esa ausencia; no instales otro entorno ni presentes Windows como validado.
>
> No reduzcas el máximo admitido, no subas umbrales y no aceptes residuales por mí. Una medición inferior a 60 segundos no satisface por sí sola CA-54.
>
> ### 5. Revisión y condición de parada
>
> El analista actualiza únicamente las sedes afectadas. El desarrollador repara y QA revisa el delta, conservando la cobertura anterior que siga siendo válida.
>
> Si QA es favorable para la reparación, despacha seguridad conforme a las reglas vigentes. Si QA-023-10 impide ese veredicto, entrega primero su decisión concreta: no lo ocultes, no lo conviertas en aprobado y no repitas el ciclo de implementación por ese motivo.
>
> No abras otra vuelta excepcional automáticamente. Si aparece un impedimento nuevo, identifica su causa, si lo introduce este cambio y qué decisión concreta requiere.
>
> ### 6. Entrega
>
> Autorizo commits locales de esta intervención. Actualiza el PR #59 mediante push sin force y observa una sola corrida sobre la cabeza final únicamente si la reparación obtiene las revisiones favorables requeridas. Conserva cualquier resultado sin relanzarlo.
>
> Entrega un resumen con:
>
> - Cabeza final y archivos modificados.
> - QA-023-13 antes/después y cobertura real del host.
> - Cobertura exacta de QA y seguridad.
> - Decisión pendiente sobre QA-023-10.
> - Impedimentos restantes para publicar, sin mezclarlos con lo ya resuelto.
>
> Esta autorización no acepta SEC-115, SEC-118, el hueco C ni P-119-A; tampoco autoriza fusionar, cerrar requisitos, crear tags, publicar o actualizar SENDA, Adelantos u otros consumidores.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Base comprobada antes de editar (2026-10-02):** `cand/1.35.0` local = `origin/cand/1.35.0` = PR #59 = `452098e`, en borrador. En el árbol, sólo los cambios preexistentes: `docs/ESTADO.md` y `propuesta-v1.35.0/`.
- **Windows/MSYS está disponible y no se instala nada:** PortableGit en el perfil de Windows (`bash` 5.3.15, MSYS 3.6.9), `jq` 1.8.2 y `timeout`, accesibles desde WSL por interoperabilidad.
- **Contadores:** el de REQ-023 sigue **agotado (3 de 3)**. Ésta es la cuarta vuelta excepcional autorizada sobre esta entrega, y no reinicia nada. No se crea ningún REQ.
- **Orden de la vuelta, en serie** porque todo es de REQ-007:
  1. desarrollador;
  2. host del caso CR y comprobación en Windows/MSYS, las dos de la coordinadora y con registro previo;
  3. analista;
  4. QA (Opus, §5);
  5. seguridad, sólo si QA es favorable para la reparación.

  Push y una sola corrida de CI, sólo si las revisiones salen favorables.

### RESUELTA (propietario, 2026-10-01, sexta autorización) — **Decisión 8: opción A.** Vuelta excepcional agrupada para QA-023-09 (integridad de la entrada), QA-023-10 (coste de `Bash`, REQ-007 CA-54) y QA-023-11 (cobertura real en CA-45), sin reiniciar contadores y sin retirar la reparación de SEC-119/O-11

**Texto del propietario, literal e íntegro** (mensaje del 2026-10-01 a la sesión coordinadora del worktree `ArnesJuan-v1.35`):

> Autorizo la opción A de la decisión 8: una vuelta excepcional agrupada para QA-023-09, QA-023-10 y QA-023-11. Conserva los contadores y registra esta excepción sin reiniciarlos.
>
> Objetivo: eliminar la regresión introducida por SEC-119/O-11, cumplir el coste contratado y completar la declaración de cobertura. No retirar la reparación ni abrir mejoras independientes.
>
> 1. Base y contexto
>
> Trabaja en `cand/1.35.0`. La cabeza local reportada es `8f4dda7`; el PR #59 sigue en `9596e39`. Verifica ambas y el árbol de trabajo antes de editar.
>
> Conserva los cambios preexistentes de `docs/ESTADO.md`, `propuesta-v1.35.0/` y la evidencia. No los descartes ni los incluyas indiscriminadamente. Utiliza las instrucciones del worktree correcto.
>
> 2. QA-023-09: integridad de la entrada
>
> Corrige la extracción de los datos para que un salto de línea dentro de `cwd` no desplace campos ni cambie la ruta que juzgan las puertas.
>
> La solución debe preservar los límites entre campos del formato de entrada; no basta con prohibir el nombre ensayado o sustituir caracteres silenciosamente.
>
> Añade pruebas que fallen con la reparación defectuosa y pasen después. Comprueba ambas puertas, la ruta realmente juzgada y el efecto en disco. Incluye un control legítimo.
>
> Reutiliza el caso del host real. No presentes su denegación anterior por ruta irresoluble como protección acreditada ni extiendas las conclusiones a hosts no ensayados.
>
> 3. QA-023-10: coste de Bash
>
> Autoriza esta instrucción la optimización interna necesaria para cumplir REQ-007 CA-54, conservando:
> - Techo de menos de 5 segundos.
> - Valor por defecto y máximo admitido.
> - Cobertura de seguridad y decisiones del control.
>
> No subas el techo, reduzcas límites admitidos, omitas comprobaciones ni cambies el procedimiento de medición para obtener un PASS.
>
> Antes de medir, identifica el procedimiento y los casos exigidos por el contrato, reutilizando la evidencia existente. Registra todas las ejecuciones y compara el mismo trabajo antes y después.
>
> Si la optimización no consigue cumplir dentro de esta vuelta, detén esa reparación y presenta las cifras y el impedimento concreto. No sigas ensayando hasta obtener una lectura favorable. Continúa y conserva la validación independiente de QA-023-09 y QA-023-11.
>
> 4. QA-023-11: cobertura real
>
> El analista incorpora en CA-45 la evidencia ya obtenida:
> - El cwd recibido por el hook sigue al cd observado.
> - El caso de archivo ilegible falló antes de llegar al hook.
>
> Declara ese segundo caso como límite de la comprobación en el host. No lo conviertas en prueba de denegación del hook ni repitas el experimento sin una pregunta nueva imprescindible.
>
> 5. Ciclo completo de esta vuelta
>
> Agrupa la reparación del desarrollador, el write-back del analista y las pruebas dirigidas. QA revisa los tres puntos y las regresiones de los caminos afectados, reutilizando evidencia intacta.
>
> Si QA es favorable, despacha seguridad sobre el delta. Si no lo es, conserva los resultados parciales y entrega el bloqueo exacto; no abras otra vuelta automáticamente ni apruebes por agotamiento.
>
> Los ajustes internos necesarios para resolver estos tres hallazgos están autorizados. Sólo exige otra decisión un cambio de alcance, contrato o cobertura que exceda expresamente estos límites.
>
> 6. PR y resultado
>
> Autorizo commits, push sin force y actualización del PR #59 en borrador. Obtén el CI requerido sobre la cabeza final de esta entrega. Conserva todas las corridas, sin relanzar buscando verde.
>
> Entrega un único resumen:
> - Estado de cada hallazgo.
> - Antes/después de la ruta juzgada y del coste.
> - Evidencia de host frente a pruebas directas del hook.
> - Firmas y cobertura, SHA y CI.
> - Impedimentos de publicación que permanezcan.
>
> Ficha 1 (SEC-115/SEC-118), ficha 2 (hueco C) y P-119-A siguen pendientes y sin aceptación. No uses una aceptación de F7 para cubrir QA-023-09.
>
> Sin fusión, cierre automático de requisitos, tag, publicación, cambios de modelos, workflow, ruleset ni consumidores. El resultado esperado es esta vuelta terminada y una decisión concreta sobre el candidato, no otra propuesta preliminar.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Base comprobada antes de editar (2026-10-01):** `cand/1.35.0` local = `8f4dda7`; `origin/cand/1.35.0` = PR #59 = `9596e39`, en borrador y ancestro de `8f4dda7`, así que el push no necesita force. En el árbol, sólo los cambios preexistentes: `docs/ESTADO.md` y `propuesta-v1.35.0/`.
- **Contadores:** el de REQ-023 sigue **agotado (3 de 3)**. Ésta es la tercera vuelta excepcional autorizada sobre esta entrega, después de la tercera/cuarta y de la quinta autorización. No reinicia ningún contador y no se crea otro REQ.
- **Orden de la vuelta, en serie** porque las tres partes son de REQ-007 y comparten archivos: desarrollador (QA-023-09 y QA-023-10, con su parada) → validación en el host del caso reutilizado (coordinadora, con registro previo) → analista (write-back) → QA (lanzado con Opus, §5) → seguridad, sólo si QA es favorable.
- **Siguen pendientes y sin aceptación:** ficha 1 (SEC-115/SEC-118), ficha 2 (C) y P-119-A. Una aceptación de F7 no cubre QA-023-09.

### RESUELTA (propietario, 2026-09-30, quinta autorización) — **Reparación acotada de la identificación y lectura de archivos protegidos: SEC-119 y O-11** (SEC-120 sólo si comparte la causa); nueva vuelta excepcional agrupada, sin reiniciar contadores; resuelve la ficha 4 (reparar) y la decisión 7 (se corrige dentro de esta frontera)

**Texto del propietario, literal e íntegro** (mensaje del 2026-09-30 a la sesión coordinadora del worktree `ArnesJuan-v1.35`). Un primer envío del mismo mensaje llegó cortado y el propietario lo reenvió completo; se transcribe el completo.

> Autorizo una reparación acotada de la identificación y lectura de archivos protegidos: SEC-119 y su relación con O-11. El objetivo es terminar esta frontera de seguridad, conservando la reparación de SEC-117 y evitando otra revisión general.
>
> 1. Base y contexto
>
> Parte de `cand/1.35.0`, cabeza conocida `9596e39fca6c8eda6506ee1b26f4bdbd71918313`, PR #59. Verifica el estado y utiliza las instrucciones del worktree correcto. Conserva cambios ajenos y toda la evidencia anterior.
>
> SEC-117 está mitigado dentro de lo ensayado. No reabras su investigación; comprueba únicamente las regresiones que pueda introducir este cambio.
>
> 2. SEC-119: identificar el archivo protegido
>
> Propiedad exigida: las rutas equivalentes que apuntan al mismo archivo protegido no pueden recibir permisos distintos por su escritura.
>
> Reutiliza las reproducciones existentes de `..`, `././` y directorios enlazados. Distingue:
> - Lo que recibe realmente el hook desde el host.
> - Lo que sólo se ha inyectado directamente al hook.
> - La ruta utilizada finalmente por la herramienta.
>
> Implementa una resolución de rutas coherente para `guard-completado` y `guard-codigo`, conforme a sus contratos. No basta con borrar segmentos del texto: considera el directorio de trabajo y los enlaces simbólicos.
>
> Preserva las operaciones legítimas fuera del ámbito protegido. Contempla archivos nuevos mediante su directorio padre existente, sin confundir «todavía no existe» con «no se pudo determinar el destino».
>
> No prometas resolver carreras de enlaces o cambios concurrentes si no existe un mecanismo que lo garantice; declara esa frontera.
>
> 3. O-11: lectura fallida
>
> Autorizo corregir el tratamiento del archivo ilegible dentro de esta misma frontera.
>
> Distingue archivo inexistente, archivo existente pero ilegible y error al resolver la ruta. Para una operación dentro del ámbito protegido, no poder leer o reconstruir lo necesario para juzgarla no puede convertirse en permiso silencioso.
>
> No supongas que, porque el hook no puede leer, la herramienta tampoco podrá escribir. Comprueba esa relación donde sea reproducible; si no lo es, declara el límite.
>
> El mensaje debe indicar la causa y cómo corregirla, sin recomendar otra herramienta para eludir la puerta.
>
> 4. SEC-120 y contratos afectados
>
> Lee primero la ficha existente de SEC-120 y resume causa, consecuencia y evidencia. Inclúyelo en esta reparación sólo si comparte directamente la causa de identificación o lectura del archivo. Si es independiente, consérvalo pendiente y no abras su reparación.
>
> Autorizo al analista a versionar los criterios existentes directamente afectados, con ADR si corresponde, y a reabrir los requisitos que lo exijan. No conserves una expectativa de allow basada en una premisa desmentida. Registra el cambio de compatibilidad y no cierres requisitos automáticamente.
>
> No crees otro REQ para eludir contadores. Antes de despachar, deja identificados los criterios, archivos y pruebas afectados, sin volver a pedirme autorización por las dependencias indispensables de esta frontera.
>
> 5. Validación y presupuesto
>
> Autorizo una nueva vuelta excepcional agrupada: analista para el contrato, desarrollador, QA y seguridad. Registra la excepción sin reiniciar los contadores anteriores.
>
> Prueba al menos:
> - Ruta canónica y rutas equivalentes hacia el mismo archivo protegido.
> - Enlace de directorio que conduce a un destino protegido.
> - Operación legítima fuera del ámbito protegido.
> - Creación legítima de un archivo nuevo.
> - Archivo ilegible y error de resolución.
> - Edición literal, rechazo de la edición no reconstruible de SEC-117 y reapertura legítima.
>
> Comprueba en el host real los casos alcanzables mediante sus herramientas, con control de denegación y verificación del archivo final. Separa esas pruebas de las realizadas sólo a nivel de hook. No atribuyas cobertura a Windows, MultiEdit u otros hosts no ejercidos.
>
> Adapta los fixtures afectados para que cada prueba siga llegando al control que pretende medir. No cambies expectativas indiscriminadamente a deny ni retires casos para obtener verde.
>
> QA revisa el delta y sus regresiones; seguridad después de QA favorable. Reutiliza evidencia intacta. Si esta vuelta termina con un bloqueo, entrega el impedimento preciso y no abras otra automáticamente.
>
> 6. Entrega y límites
>
> Autorizo commits, push sin force y actualización del PR #59 en borrador. Ejecuta las comprobaciones exigidas y observa el CI sobre la cabeza final. Conserva todas las corridas y no relances buscando verde.
>
> Actualiza notas, guía y comentarios únicamente para describir fielmente esta reparación, su compatibilidad y sus límites.
>
> Entrega un único resultado: antes/después, cobertura real por host, determinación de SEC-119/O-11/SEC-120, contratos afectados, firmas, SHA, CI y decisiones pendientes de publicación.
>
> SEC-115, SEC-118 y el hueco C siguen sin aceptación. No abras trabajo independiente sobre ellos, modelos, sondas, workflow, ruleset o consumidores.
>
> Sin fusión, cierres automáticos, tag ni publicación. El resultado buscado es esta frontera reparada y un candidato concreto; no otra propuesta preliminar ni una campaña nueva de mejoras.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Cabeza de partida comprobada:** `9596e39fca6c8eda6506ee1b26f4bdbd71918313` = `origin/cand/1.35.0` = PR #59, en borrador.
- **Contadores:** el de REQ-023 sigue **agotado (3 de 3)**. Ésta es una segunda vuelta excepcional, autorizada, que no reinicia ningún contador. No se crea otro REQ.
- **Siguen abiertos y sin aceptar:** SEC-115, SEC-118 y C.

### RESUELTA (propietario, 2026-09-30, cuarta autorización) — **Decisión 6 (P-SEC117): opción A.** Se amplía el alcance para corregir los contratos (REQ-001 CA-10, CA-11 y CA-12, y REQ-007 CA-46 (c), con ADR) y las pruebas que dependen de la premisa desmentida por la reproducción real de SEC-117; se reabre REQ-001 según §9; QA y seguridad cubren también REQ-001 y REQ-007; todo dentro de la misma vuelta excepcional agrupada

**Texto del propietario, literal e íntegro** (mensaje del 2026-09-30 a la sesión coordinadora del worktree `ArnesJuan-v1.35`):

> Autorizo la opción A de la decisión 6. Amplío expresamente el alcance para corregir los contratos y las pruebas que dependen de la premisa desmentida por la reproducción real de SEC-117.
>
> 1. Contrato
>
> El analista versiona REQ-001 CA-10, CA-11 y CA-12, y REQ-007 CA-46(c), con el ADR correspondiente y trazabilidad al experimento real. Completa el criterio de SEC-117 en REQ-023 sin duplicar la norma en varias sedes.
>
> Autorizo reabrir REQ-001 según §9. No lo cierres automáticamente al terminar ni atribuyas sus firmas anteriores al contrato modificado.
>
> La propiedad se mantiene: una edición sobre un REQ protegido que el hook no puede reconstruir no puede recibir permiso silencioso. No adoptes la opción B ni vuelvas a confiar únicamente en que new_string mencione el estado terminal.
>
> 2. Implementación y banco
>
> El desarrollador implementa la denegación acotada al supuesto anterior, con un mensaje que permita realizar una edición verificable. Preserva las operaciones legítimas reconstruibles y la reapertura.
>
> Autorizo adaptar las llamadas del banco afectadas por old_string ficticios:
> - Las que prueban otras puertas deben usar ediciones literales válidas, para seguir llegando al control que pretenden medir.
> - Las que prueban reconstrucción fallida deben conservar esa condición y comprobar la nueva denegación.
> - No cambies masivamente expectativas a deny: una prueba que pasa porque la detuvo otra puerta no acredita su propósito original.
> - No retires casos para obtener verde; justifica cualquier sustitución y conserva su cobertura.
>
> Usa el inventario de llamadas existente. No amplíes esta tarea a una limpieza general del banco.
>
> 3. Revisión agrupada
>
> Amplío la revisión de QA y seguridad a los criterios y caminos afectados de REQ-001 y REQ-007, además de REQ-023 y REQ-031. Reutiliza la evidencia de las partes intactas; no repitas la revisión completa de cada requisito.
>
> Esta ampliación forma parte de la vuelta excepcional agrupada ya autorizada: no reinicia contadores ni concede vueltas ilimitadas. Registra la ampliación y continúa el trabajo pendiente sin separar artificialmente nuevas rondas.
>
> Incluye en la misma entrega QA-023-06, la precisión de REQ-031 CA-A13 y los comentarios incorrectos ya autorizados. Mantén separadas la propiedad del control y las limitaciones SEC-115/118.
>
> 4. Validación y entrega
>
> Repite de forma acotada la comprobación con Edit real: caso que escapaba, denegación de control y edición legítima. Verifica también reapertura y los caminos compartidos afectados. Distingue argumentos, decisión y efecto en disco.
>
> Después de QA favorable, seguridad determina su aprobación y cobertura. Autorizo commits, push sin force y actualización del PR #59, con CI sobre la cabeza final. Conserva los resultados y no relances buscando verde.
>
> Si la vuelta termina con un bloqueo, entrega el hallazgo exacto y el delta pendiente; no apruebes por agotamiento ni abras otra reparación automáticamente.
>
> SEC-115, SEC-118 y el hueco C continúan abiertos y sin aceptación. Sin fusión, cierres automáticos, tag, publicación ni cambios en consumidores.
>
> El resultado esperado es la reparación completa de SEC-117 con sus contratos y pruebas coherentes, no otra propuesta previa. Continúa con esta autorización sin volver a solicitar aprobación por las dependencias enumeradas aquí.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Cabeza de partida:** `0e5df92`, local y sin push; el PR #59 está en `df550fa`.
- **ADR-015 está libre** en todas las ramas: será el ADR que supersede la premisa «un `Edit` cuyo `old_string` no está literal falla y no escribe nada».
- **Contadores:** el de REQ-023 sigue **agotado (3 de 3)** y no se reinicia. Esta ampliación es parte de la vuelta excepcional de la tercera autorización, no una vuelta nueva. REQ-001 se reabre por §9 sin contador nuevo, y sus firmas anteriores quedan acotadas al contrato anterior.
- **Siguen abiertos y sin aceptar:** SEC-115, SEC-118 y C.

### RESUELTA (propietario, 2026-09-29, tercera autorización) — **Reparación agrupada del candidato del PR #59: SEC-117, QA-023-06 y los comentarios de código que describen mal ese comportamiento**; vuelta excepcional agrupada desarrollador → QA → seguridad, más el write-back indispensable del analista, sin reiniciar el contador; **no se acepta publicar con SEC-117 aplazado**; resuelve la ficha 3 (reparar) y la decisión 5

**Texto del propietario, literal e íntegro** (mensaje del 2026-09-29 a la sesión coordinadora del worktree `ArnesJuan-v1.35`; llegó completo):

> Autorizo una reparación agrupada del candidato del PR #59: SEC-117, QA-023-06 y los comentarios que describen incorrectamente ese comportamiento. No acepto publicar con SEC-117 aplazado.
>
> Parte de `cand/1.35.0`, cabeza conocida `df550fa2e8e7ae7906b39ede8711143d2488936b`. Verifica el estado y trabaja con las instrucciones del worktree correcto, preservando cambios ajenos.
>
> 1. Reparar SEC-117
>
> La reproducción real ya permite implementar; no prepares otra investigación general.
>
> Propiedad exigida: cuando el hook no puede reconstruir una edición de un REQ protegido porque no encuentra literalmente el texto anterior, esa incertidumbre no puede convertirse en permiso silencioso.
>
> Define la condición de denegación de forma comprobable. No vuelvas a depender sólo de encontrar «estado: completado» en `new_string` ni intentes imitar toda la normalización del host.
>
> La denegación debe explicar cómo realizar una edición verificable. Conserva las ediciones legítimas y la reapertura cuando el hook pueda reconstruirlas. No autorices otra herramienta como atajo para eludir el control.
>
> Revisa los caminos que comparten esa reconstrucción, incluido MultiEdit si corresponde, sin ampliar el encargo a todas las herramientas o formas de escritura.
>
> 2. Corregir QA-023-06 y comentarios afectados
>
> Autorizo corregir las sedes de REQ-023 y REQ-031 afectadas:
> - Expresa correctamente que el límite relevante es de bytes.
> - Conserva las cifras medidas en la evidencia junto con sus condiciones, incluida la restricción ASCII.
> - No extrapoles resultados a caracteres, hosts o tamaños no probados.
> - Separa la propiedad del control de las limitaciones SEC-115/118; una frase condicional no acredita protección.
>
> Autorizo modificar los comentarios de código señalados cuando describan incorrectamente el comportamiento, además de la documentación correspondiente. No es autorización para otras refactorizaciones.
>
> Las seis observaciones menores quedan fuera, salvo que una sea inseparable de estas correcciones; en ese caso explica la dependencia y limita el cambio.
>
> 3. Presupuesto y gobernanza
>
> Autorizo expresamente una vuelta excepcional agrupada de desarrollador → QA → seguridad para esta reparación, más el write-back contractual indispensable del analista. Conserva el contador agotado y registra la excepción sin reiniciarlo ni crear otro REQ para eludirlo.
>
> Reutiliza las firmas y evidencias que sigan siendo aplicables. QA revisa el delta y sus efectos sobre REQ-023 y REQ-031; seguridad emite su determinación después de QA favorable.
>
> Si esta vuelta termina con un hallazgo bloqueante, entrega el impedimento exacto y lo pendiente. No abras otra vuelta ni apruebes por agotamiento.
>
> 4. Validación
>
> Reutiliza el experimento real de SEC-117 y sus precondiciones. En un proyecto temporal aislado verifica:
> - El caso de comillas que antes escapaba ahora queda bloqueado y el archivo no cambia.
> - El control positivo de denegación sigue bloqueando.
> - Una edición legítima reconstruible sigue funcionando.
> - La reapertura reconstruible sigue permitida.
> - Los caminos afectados por el cambio tienen pruebas de regresión.
>
> Distingue argumentos recibidos, decisión del hook, tratamiento del host y efecto en disco. No presentes una emulación como ejecución real ni extiendas la conclusión a Windows o al editor sin evidencia.
>
> Ejecuta las comprobaciones necesarias del candidato. Conserva todas las corridas; un resultado posterior no borra uno anterior.
>
> 5. PR y entrega final
>
> Autorizo commits, push sin force y actualización del PR #59 en borrador. Obtén el CI requerido sobre la cabeza final y no lo relances buscando verde.
>
> Verifica que la copia íntegra de este encargo quede conservada en la sede de autorización. No reconstruyas el mensaje anterior que llegó cortado: este texto define el alcance autorizado ahora.
>
> Entrega un único resumen:
> - SEC-117 antes/después, con evidencia real.
> - QA-023-06 y comentarios corregidos.
> - Compatibilidad y límites.
> - Firmas y cobertura sobre el candidato.
> - SHA, CI y decisiones de publicación todavía pendientes.
>
> SEC-115, SEC-118 y el hueco C siguen abiertos y sin aceptación mía. Sin nuevas reparaciones de esos asuntos, modelos, sondas, workflow, ruleset o consumidores.
>
> No fusiones, no cierres requisitos, no crees tags ni publiques. El objetivo es dejar esta reparación terminada y un candidato concreto para decidir la salida.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Cabeza de partida comprobada:** `df550fa2e8e7ae7906b39ede8711143d2488936b` = `origin/cand/1.35.0`.
- **Sede de la reparación de SEC-117:** REQ-023. Hoy su frontera (g) lo declara fuera; el write-back del analista lo pasa dentro. **No se crea otro REQ**, como ordena el punto 3.
- **Contador de REQ-023:** sigue **agotado (3 de 3)**. Ésta es una vuelta **excepcional** autorizada, no la cuarta vuelta del contador, y no lo reinicia.
- **Entregas anteriores:** la autorización del 2026-09-29 que llegó truncada no se reconstruye; este texto define el alcance.
- **Siguen abiertos y sin aceptar:** SEC-115, SEC-118 y el hueco C.

### RESUELTA (propietario, 2026-09-29, segunda autorización) — **Candidato del PR #59: corrección documental excepcional fuera del contador (QA-023-05 y R-045 §6, con las promesas de REQ-031 afectadas) y reproducción real y aislada de SEC-117**; resuelve la decisión 4 con la opción (A); SEC-115, SEC-118, C y SEC-117 **NO** aceptados

**Texto del propietario, literal e íntegro TAL COMO LLEGÓ** (mensaje del 2026-09-29 a la sesión coordinadora del worktree `ArnesJuan-v1.35`). **El mensaje llegó truncado:** termina en «Registra con precisión la cobertura de QA y», sin punto final. La coordinadora no reconstruye lo que falta; aplica lo que está completo y lo declara en su entrega.

> Autorizo un encargo acotado sobre el candidato del PR #59: corregir las promesas documentales pendientes y comprobar SEC-117 en una sesión real. El objetivo es obtener evidencia suficiente para decidir la publicación, sin ampliar otra vez la reparación.
>
> 1. Base y contexto
>
> Parte de `cand/1.35.0`, cabeza conocida `45c2e5c5ce90c5eae15e817d65522f3ee6b788cd`. Comprueba el estado antes de actuar y conserva cambios ajenos, la propuesta original y el bloque derivado de ESTADO.
>
> Trabaja con las instrucciones del worktree correcto, sin heredar como normativa las de `rel/registro-1.33.0`.
>
> 2. Corrección documental excepcional
>
> Autorizo una intervención documental fuera del contador agotado, registrada expresamente y sin reiniciarlo.
>
> Agrupa QA-023-05 y las correcciones de texto señaladas por R-045, incluidas las promesas de REQ-031 afectadas. Describe la propiedad realmente comprobada y sus límites; no conviertas una denegación condicionada en garantía universal.
>
> El analista actualiza las sedes contractuales correspondientes; QA revisa el delta documental y seguridad emite su determinación después de QA favorable. Reutiliza las pruebas y revisiones cuyo contenido no cambió. No repitas el banco completo por rutina ni modifiques código para resolver este apartado.
>
> La corrección documental no acepta SEC-115, SEC-118, C ni SEC-117 como riesgos de publicación.
>
> 3. SEC-117: reproducción real y aislada
>
> Autorizo un experimento acotado en un proyecto temporal, sin datos reales ni archivos de consumidores.
>
> Antes de ejecutarlo, registra:
> - Versión y host del CLI, plugin y hook utilizados.
> - Entrada exacta del caso derivado de la evidencia existente.
> - Precondiciones que deberían impedir el cierre.
> - Resultado esperado y cómo observarás el efecto.
>
> Presupuesto: un caso positivo de denegación, el caso sospechoso y un control legítimo permitido. Una ejecución por caso. Si falla la instrumentación, admite una sola repetición diagnóstica, conservando y explicando el intento anterior.
>
> Observa por separado:
> - Argumentos que recibe el hook.
> - Decisión emitida y tratamiento por el entorno.
> - Resultado de la herramienta y contenido final del archivo.
>
> Utiliza la herramienta Edit real del host comprobado. Una emulación, un script que edite el archivo o una lectura del binario no sustituyen esta prueba. No desactives las puertas para conseguir el resultado.
>
> Si no puedes ejecutar la prueba real, informa de la limitación; no la presentes como reproducida. Si el control de denegación no funciona, el ensayo no permite atribuir el resultado a SEC-117.
>
> No repares SEC-117 dentro de este encargo. Si se confirma, entrega causa acotada, superficie afectada y propuesta mínima de reparación. Si no se reproduce, limita la conclusión a las condiciones ensayadas.
>
> 4. Precisiones con evidencia existente
>
> Sin nuevos ensayos adicionales:
> - Separa en SEC-118 lo observado directamente de lo inferido o emulado.
> - Identifica qué archivos se escribieron con Python, por qué rol y bajo qué permisos. No des por resuelto el asunto sólo porque la cabecera de REQ-023 no cambió; tampoco declares infracción por el nombre de la herramienta.
> - Contrasta los cambios de compatibilidad con la política de versiones del repositorio. Presenta una recomendación fundada sobre 1.35.0; no cambies nuevamente la versión por tu cuenta.
> - Mantén diferenciados los fail-before locales y los SKIP de CI.
>
> 5. Registro y CI
>
> Autorizo commits de la corrección documental, push sin force y actualización del PR #59. Si cambia la cabeza, observa el CI requerido sobre la cabeza resultante una vez; no relances buscando verde.
>
> Conserva la evidencia del experimento por separado, sin incorporar binarios ni volcados de terceros. Registra con precisión la cobertura de QA y

**Lo que la coordinadora añade, rotulado como suyo:**
- **Intervención documental excepcional:** fuera del contador dev↔QA de REQ-023, que **sigue agotado (3 de 3) y no se reinicia**. Es una comisión de analista, una de QA sobre el delta documental y una determinación de seguridad **después** de un QA favorable. Sin código.
- **Cabeza de partida comprobada:** `45c2e5c5ce90c5eae15e817d65522f3ee6b788cd` = `origin/cand/1.35.0`. CLI del host: **2.1.285**; QA leyó el binario de la 2.1.284.
- **El experimento de SEC-117** lo ejecuta la coordinadora, con registro previo en la rama local de evidencia antes de correrlo. No es una medición de QA, como no lo fue CA-A16.

### RESUELTA (propietario, 2026-09-29) — **SEC-047 (mitad 1 de REQ-023) y candidato v1.35.0**: implementación y preparación autorizadas, sin publicación; SEC-115 y hueco C **NO** aceptados

**Texto del propietario, literal e íntegro** (mensaje del 2026-09-29 a la sesión coordinadora del worktree `ArnesJuan-v1.35`):

> Autorizo avanzar con SEC-047 y preparar el candidato v1.35.0. Completa este encargo de punta a punta dentro del alcance siguiente, sin pedir nuevamente autorización para cada paso ya incluido.
>
> 1. Contexto y base
>
> Trabaja en `/home/juan/dev/ArnesJuan-v1.35`, desde la sesión nueva con las instrucciones de ese worktree. Comprueba rama, SHA y estado antes de editar.
>
> Usa `origin/main` como referencia, no la rama local main desfasada. Conserva el cambio preexistente de `docs/ESTADO.md` y la propuesta sin seguimiento; no los descartes ni los incluyas indiscriminadamente en commits.
>
> Lee `propuesta-v1.35.0/README.md` y `propuesta-v1.35.0/SEC-047.diff`. Conserva la propuesta original como antecedente.
>
> 2. Implementar SEC-047
>
> Autorizo implementar la mitad 1 de REQ-023 y versionar los criterios y sedes afectados. REQ-024 queda fuera.
>
> Acepto expresamente que una clave de control repetida deniegue el cierre aunque sus valores coincidan. Registra este cambio de compatibilidad.
>
> La corrección debe:
> - Impedir que las variantes cubiertas se conviertan silenciosamente en ausencia y reduzcan el rigor u oculten un bloqueante.
> - Respetar la estructura de una declaración: extraer letras ASCII no debe convertir una cita, ejemplo o explicación en campo de control.
> - Mantener coherencia entre lectores, ausencias legítimas y reapertura de REQ.
> - Evitar elegir silenciosamente entre declaraciones contradictorias.
> - Conservar las fronteras de cobertura propuestas y declararlas sin prometer reconocimiento universal.
>
> Las claves de más de 256 bytes que queden fuera siguen siendo una limitación; no las presentes como protegidas por ese límite. No amplíes este encargo para resolver todo Unicode ni SEC-115.
>
> 3. Validar y preparar la entrega
>
> Recorre el ciclo correspondiente al cambio de hooks, reutilizando las reproducciones y el inventario existentes. Agrupa los hallazgos de cada revisión antes de reparar; no reinicies contadores ni repitas revisiones sin un delta o riesgo concreto.
>
> Verifica casos legítimos, variantes, duplicados, prosa, reapertura, CRLF y las fronteras relevantes. Ejecuta el banco completo y las comprobaciones exigidas sobre el candidato; no presentes el ±1 % del ensayo preliminar como rendimiento acreditado.
>
> Autorizo rama de trabajo, commits, push sin force y PR en borrador. Conserva los resultados de CI; no relances buscando verde.
>
> Si se agota el presupuesto vigente con un bloqueo real, entrega el impedimento exacto y lo pendiente. No apruebes por agotamiento.
>
> 4. Preparar v1.35.0
>
> Con la reparación validada, prepara el cambio de versión en los manifiestos correspondientes, las notas y la guía de actualización necesaria. Autorizo esos cambios como preparación del candidato, no su publicación.
>
> Describe el contenido realmente incluido desde v1.34.0. REQ-025 aporta sólo su entrega 1; no cierres el requisito completo ni incorpores trabajo de la rama antigua.
>
> Las notas deben explicar los cambios de compatibilidad y conservar los resultados históricos, los inconclusos y las limitaciones. No transformes un CI verde en acreditación de rendimiento, conducta o ahorro.
>
> Obtén el CI requerido sobre la cabeza final del candidato y deja identificada la cobertura de las firmas.
>
> 5. Riesgos pendientes
>
> Este encargo NO acepta el aplazamiento de SEC-115 ni del hueco C. Conserva sus decisiones pendientes y prepara sus fichas finales con consecuencia, protección efectiva, responsable propuesto, fecha de revisión y condición de revisión anticipada.
>
> Reutiliza la fecha propuesta de SEC-115, 2026-10-29. Para C propone una fecha concreta. Ninguna propuesta cuenta como aceptación mía.
>
> No repares esos dos asuntos dentro de SEC-047 ni detengas el trabajo independiente autorizado únicamente porque esperan mi decisión. Si una regla impide un cierre, deja ese cierre pendiente y continúa lo permitido.
>
> 6. Límites y resultado final
>
> Sin fusión, tag, publicación ni actualización de instalaciones o consumidores. PR #54 y #57 intactos. Sin reconciliar `rel/registro-1.33.0`, cambiar modelos, sondas, umbrales, workflow o ruleset.
>
> Entrega una sola propuesta de salida: reparación y compatibilidad verificadas, SHA y PR del candidato, firmas y CI, contenido de v1.35.0 y decisiones exactas que falten para publicarla.
>
> No propongas otra investigación general. El resultado buscado es un candidato concreto que yo pueda revisar y decidir.

**Lo que la coordinadora añade, rotulado como suyo:**
- **Antecedente citado por la autorización** («Lee `propuesta-v1.35.0/README.md` y `propuesta-v1.35.0/SEC-047.diff`»): la propuesta se conserva sin seguimiento en el worktree, intacta, y su copia literal queda versionada en `docs/arnes/v1.35.0-propuesta-sec-047.md`, `docs/arnes/v1.35.0-propuesta-sec-047.diff` y `docs/arnes/v1.35.0-propuesta-sec-047-humo.txt` para poder citarla con commit. Sus cifras de coste (±1 %) son de un **ensayo preliminar** y **no** acreditan rendimiento.
- **El encargo anterior** del que nace la propuesta está íntegro en `traspaso-v1.35.0/README.md`, rama `evidencia/prueba-despacho-2026-09-14`, commit `94e2d3b`.
- **Cambio de compatibilidad aceptado expresamente:** una clave de control repetida deniega el cierre **aunque sus valores coincidan**.
- **Contador:** REQ-023 no ha gastado ninguna vuelta dev↔QA (sólo trabajo de analista y una cata); el tope es 3 y no se reinicia.
- **Rama del candidato:** `cand/1.35.0`, desde `origin/main` = `713ac68`. La rama local `main` (`cf2009e`) está desfasada y no se usa.
- **El asunto 3** de la entrada pendiente de publicación (SEC-047/§13) queda resuelto por esta autorización; **SEC-115 y C siguen pendientes** en esa entrada, con sus fichas finales.

### RESUELTA (propietario, 2026-09-28) — **REQ-031: comprobación acotada de procedencia de instrucciones y referencias**; intervención documental excepcional sin reiniciar el contador

**Texto del propietario, literal e íntegro:**

> Autorizo una comprobación acotada de la procedencia de instrucciones y referencias de REQ-031. El objetivo es determinar si el uso de AGENTS.md de otra rama afectó la entrega y dejar el PR #58 listo para una decisión de integración. No abrir otra revisión general del arnés.
>
> Base de la comprobación: cabeza `19c5ca762ec039958572c537a74a909c6caf0207` del PR #58, con CI verde. Verifica que sigue siendo la cabeza antes de actuar.
>
> **1. Establecer el contexto correcto**
>
> Identifica el directorio de trabajo, rama y archivos de instrucciones que cargó la sesión y cada comisión relevante. Distingue lo demostrado por registros de lo inferido.
>
> Para esta comprobación utiliza las instrucciones del worktree de REQ-031. Cambiar de directorio no demuestra que una sesión haya descargado instrucciones heredadas: si hace falta una sesión nueva para conseguir un contexto limpio, úsala con un encargo acotado y fuente explícita.
>
> No modifiques ni reconcilies `rel/registro-1.33.0`, no cambies la rama de una sesión que siga trabajando y no toques cambios ajenos.
>
> **2. Determinar el efecto de la mezcla de instrucciones**
>
> Compara sólo las instrucciones que pudieron afectar:
> - Alcance de A y D.
> - Permisos y separación de roles.
> - Presupuesto de vueltas.
> - Validación, firmas y conclusiones sobre SEC-047, SEC-078 y R-024.
>
> Indica qué diferencia influyó realmente y qué parte de la entrega afecta. No invalidez toda la evidencia por su procedencia ni la declares válida únicamente porque el código no cambió.
>
> **3. Corregir referencias del candidato**
>
> Autorizo una intervención documental excepcional, sin reiniciar el contador 3 de 3, para corregir referencias inexistentes o atribuidas a la rama equivocada en los archivos de esta entrega.
>
> Si una referencia sólo existe en otra rama, cita explícitamente su procedencia y commit cuando sea necesaria como antecedente; no la presentes como sede vigente en main. No inventes identificadores ni importes aquella rama para hacer resoluble una cita.
>
> La celda de §13 ausente de main no debe añadirse para luego corregirla. Registra que esa parte del encargo nació de una atribución equivocada.
>
> Reutiliza las aprobaciones existentes donde su evidencia siga siendo aplicable. QA y seguridad deben revisar únicamente las conclusiones o textos afectados por esta comprobación. No les atribuyas una ratificación que no hayan emitido.
>
> Si aparece una necesidad de cambiar código, criterios, permisos o alcance, entrega el delta concreto pendiente y detén sólo esa reparación; esta autorización no incluye implementarla.
>
> **4. Separar los riesgos de publicación**
>
> Conserva abiertos y sin aceptación mía:
> - C: escrituras por intérpretes que el detector no reconoce.
> - SEC-115: entradas que agotan el hook y permiten continuar sin decisión, observado en el CLI.
>
> Corrige cualquier texto de esta entrega que presente una futura comprobación posterior como prevención ya disponible. Detectar un cambio después no demuestra que se impidió ni que se deshicieron sus efectos.
>
> No diseñes ni implementes ahora una puerta posterior, límites globales o una nueva arquitectura. No conviertas estos pendientes en riesgos aceptados por registrarlos en CHANGELOG.
>
> **5. Entrega y límites**
>
> Autorizo commits documentales, push sin force y actualización del PR #58. Si cambia la cabeza, observa el CI requerido correspondiente, conserva su resultado y no relances buscando verde.
>
> Si no hace falta cambiar el candidato, conserva su SHA y registra la comprobación en la evidencia y un comentario del PR.
>
> Entrega un único resumen breve:
> - Instrucciones ajenas que influyeron y efecto concreto.
> - Referencias corregidas.
> - Evidencia y aprobaciones reutilizadas, con su alcance.
> - SHA y CI aplicables.
> - Si recomiendas integrar #58 y, por separado, qué decisiones siguen pendientes para publicar.
>
> No fusiones, no cierres REQ-031, no publiques versión ni tag. No toques modelos, PR #54/#57, consumidores, sondas, umbrales, workflow ni ruleset. No abras otra campaña de mejoras.

**Lo que la coordinadora añade, rotulado como suyo:** cabeza verificada `19c5ca7` (remoto idéntico, árbol limpio). Demostrado por registros (transcripts de las seis comisiones de REQ-030/031): todas cargaron «Contents of /home/juan/dev/ArnesJuan/AGENTS.md» (worktree de la sesión, rama `rel/registro-1.33.0`, 503 líneas, con §14 y la celda R-024), no el `AGENTS.md` de `main`/este worktree (807 líneas). Diferencias por sección: §5 y §7 idénticas; §13 difiere en dos filas (main: sólo CR; rel: celda ancha con BOM/R-024) y en el marcador de coordinación; §6 difiere mucho (main trae la política de «vía proporcional», 480 líneas frente a 132); §14 sólo en rel. Ambas fijan «Máximo 3 vueltas dev↔QA» y la regla de `arnes-paralelo.sh`.

### RESUELTA (propietario, 2026-09-28) — **REQ-031, vuelta 3 de 3: reparación agrupada** — SEC-113 remedio B (límite antes de normalizar, en `lib.sh`), celda de §13 / R-024 (SEC-047) y registro de evidencia (cuadre 920 → 978; PENDIENTES)

**Texto del propietario, literal e íntegro:**

> Autorizo usar la vuelta 3 de 3 de REQ-031 para una reparación agrupada y acotada. Trabaja sobre la rama del PR #58, partiendo de `373563f42605d1840d76d629c127110bd6e28e4b`, verificando primero su estado y preservando cambios ajenos.
>
> Objetivo: resolver SEC-113 y corregir las afirmaciones documentales señaladas, conservando la reparación A y el recorrido D. No ampliar esta entrega a una revisión general del arnés.
>
> **1. SEC-113: comprobar el tamaño antes de normalizar**
>
> Autorizo el remedio B, incluido el cambio necesario en `lib.sh`: aplicar el límite antes de la operación costosa, sin alterar el umbral autorizado ni truncar contenido para hacerlo pasar.
>
> Mantén las entradas legítimas dentro del límite y la reapertura de REQ. Verifica las fronteras del límite, la entrada de 255 371 bytes ya medida y los caminos del parser afectados.
>
> Comprueba por separado:
> - La respuesta y duración del hook.
> - La decisión que recibe el entorno.
> - Si el archivo protegido queda modificado.
>
> Si puedes reproducir de forma aislada cómo trata el entorno la terminación del hook sin decisión, hazlo con presupuesto acotado. Si no puedes, declara esa parte no comprobada: un código de salida por sí solo no demuestra que la escritura quedó bloqueada.
>
> Reutiliza las pruebas anteriores de A y D; amplía únicamente lo necesario por el cambio compartido en `lib.sh`.
>
> **2. SEC-047: coherencia documental y exposición**
>
> Autorizo corregir la celda de §13 que promete una cobertura que no existe y retirar o sustituir la referencia a R-024 tras comprobar su procedencia. Actualiza las sedes espejo aplicables sin duplicar la explicación.
>
> Conserva SEC-047 y QA-031-01 abiertos si el mecanismo sigue permitiendo el caso. No presentes la corrección documental como reparación del control ni como aceptación mía del riesgo.
>
> Haz un inventario de sólo lectura de las cabeceras actuales del propio arnés para comprobar si hay claves que el lector ignora y que puedan reducir el rigor o evitar una comprobación. Distingue ausencia de exposición actual de ausencia del defecto.
>
> No modifiques consumidores, no normalices cabeceras automáticamente y no implementes ahora una nueva política de reconocimiento de claves.
>
> **3. Corregir el registro de evidencia**
>
> Aclara el cuadre del banco contra la base real `a7a60c2`: el reporte anterior indicó 912 → 978, pero REQ-030 había dejado 920 casos. Identifica añadidos y retirados y corrige el resumen según el diff; no ajustes el recuento esperado para ocultar una discrepancia.
>
> Actualiza la referencia de `docs/PENDIENTES.md` que todavía presenta como extrapolación el caso ya medido de 255 371 bytes. Conserva la procedencia y el resultado histórico.
>
> **4. Validación y entrega**
>
> Agrupa estas reparaciones en la última vuelta disponible, con write-back del analista donde corresponda, QA sobre el delta y sus efectos, y seguridad después de QA favorable. No reinicies contadores ni abras otra vuelta automáticamente.
>
> Autorizo commits, push sin force y actualización del PR #58 en borrador. Ejecuta el CI requerido sobre la cabeza final; conserva todas las corridas y no relances buscando verde. Comprueba qué contenido cubren las firmas y qué cambios posteriores son sólo registros.
>
> Si se agota la vuelta con un bloqueo, entrega el impedimento exacto y el delta pendiente; no apruebes por agotamiento.
>
> **5. Límites**
>
> El hueco C de escrituras por intérpretes sigue separado y no aceptado como aplazado. No implementes la puerta posterior en este encargo. Presenta su decisión pendiente antes de publicar, sin convertir su documentación en una aceptación.
>
> Sin cambios de modelos, sondas de coste, umbrales, workflow, ruleset, rotación ni consumidores. Sin fusionar #58, #57 o #54, cerrar REQ-031, crear tags ni publicar versiones.
>
> Entrega un único resumen breve: antes/después de SEC-113, exposición encontrada de SEC-047, cuadre del banco, firmas, SHA, CI y decisiones concretas que falten para publicar. No añadas otro programa de mejoras.

**Lo que la coordinadora añade, rotulado como suyo:** el asunto 1 de la entrada pendiente «Decisión de publicación de 1.35.0» (remedio B) queda decidido por esta autorización; los asuntos 2 (hueco C) y 3 (§13/SEC-047 en lo que exceda la corrección documental autorizada) siguen pendientes. Corrección del registro: el cuadre real es **920 → 978** (+58 casos, todos en la sección 08: 7 → 65; la sección 32 conserva 40 y cambia la expectativa de REQ-717); el «912 → 978» del informe anterior era un error de la coordinadora (912 era el cuadre anterior a REQ-030). Cabeza de partida verificada: `373563f`, árbol limpio, remoto idéntico.

### RESUELTA (propietario, 2026-09-27) — **REQ-031, decisión P-1: opción B** (tras el paréntesis de un hallazgo sólo el separador de la gramática o el fin del campo; texto adicional deniega); versionar REQ-007 CA-41 y REQ-717 pasa a deny

**Pregunta del analista (P-1):** REQ-007 CA-41 (`requirements/REQ-007.md:101`) exige aceptar texto detrás del paréntesis (`QA-006 (instrumento) — REQ-007`), certificado por el caso REQ-717 de `tests/escenarios/hooks/secciones/32-huecos-auditoria-r001.sh`; la propiedad de REQ-031 lo trata como no interpretable. Opciones: (a) aceptar texto sin paréntesis detrás (deja pasar `SEC-A (instrumento) · SEC-B`); (b) denegar y versionar REQ-007 CA-41.

**Texto del propietario, literal e íntegro:**

> Autorizo la opción B de P-1: después del paréntesis completo de un hallazgo sólo se admite el separador definido por la gramática o el final del campo. El texto adicional no interpretable deniega el cierre con un motivo claro; no se descarta silenciosamente.
>
> Autorizo versionar REQ-007 CA-41 y cambiar REQ-717 de allow a deny. Conserva el historial y declara que una forma antes aceptada deja de serlo. No clasifiques el cambio como menor únicamente por su tamaño; aplica la regla contractual vigente para determinar si necesita ADR.
>
> El mensaje debe indicar cómo conservar la evidencia: dentro del paréntesis del hallazgo, respetando la sintaxis admitida. No borres información ni normalices automáticamente hallazgos ambiguos.
>
> Incluye como mínimo estos casos:
> - `QA-006 (instrumento) — REQ-007`: deniega.
> - `SEC-A (instrumento) · SEC-B`: deniega; no ignora el segundo identificador.
> - La forma equivalente admitida con la evidencia dentro del paréntesis: permite si no existe otro bloqueo.
> - Evidencia con comas y paréntesis internos: no debe confundirse con otro hallazgo.
> - Reapertura: sigue permitida.
>
> Haz una comprobación acotada de compatibilidad en los REQ del propio arnés para identificar usos de la forma retirada. Si aparecen, informa cuáles; no modifiques consumidores ni reescribas registros históricos.
>
> Para D, queda conforme que la herramienta la ejecute quien solicita el paralelismo: el analista declara las rutas y quien despacha comprueba la disjunción antes de hacerlo. No amplíes permisos del analista.
>
> Registra esta decisión y continúa el desarrollo, QA, seguridad, push, PR en borrador y CI ya autorizados. No necesitas otra confirmación para despachar al desarrollador. Conserva el presupuesto de vueltas y agrupa las reparaciones de cada revisión.
>
> La estimación de tiempo queda como estimación, no como permiso para ampliar el alcance. Sin fusión, publicación ni cambios en consumidores.

### RESUELTA (propietario, 2026-09-27, decisión registrada íntegra ANTES de despachar) — **REQ-031: entrega acotada para la próxima versión — reparar el cierre indebido por separadores en `Hallazgos abiertos:` (A) y completar la preparación del paralelismo (D)**

**Por qué está aquí:** es la fuente íntegra del encargo (fidelidad al encargo, REQ-029). Nació como mensaje del propietario a la sesión coordinadora tras la evaluación acotada del 2026-09-27 (rama de evidencia `evidencia/prueba-despacho-2026-09-14`, `evaluacion-2026-09-27/`, commit `37ab81e`).

**Texto del propietario, literal e íntegro:**

> Autorizo una entrega acotada para preparar la próxima versión del arnés: reparar el cierre indebido por separadores y completar la preparación del paralelismo. El objetivo es resolver estos dos puntos, sin abrir una revisión general.
>
> Trabaja en una rama aislada desde main, identificando su SHA y conservando los cambios ajenos.
>
> **1. Reparar A: hallazgos bloqueantes ignorados**
>
> Usa la reproducción de `evaluacion-2026-09-27/` como evidencia inicial.
>
> La propiedad exigida es: ningún hallazgo bloqueante puede quedar ignorado por su posición o por el separador utilizado. Una lista ambigua o no interpretable debe denegar el cierre con un motivo útil; nunca se toma sólo la primera clase descartando lo demás.
>
> Define la sintaxis admitida conforme al contrato existente. No uses «cualquier separador» como especificación ni amplíes la tolerancia sin límites. Conserva las formas legítimas y distingue separadores de la prosa dentro de la evidencia.
>
> Incluye pruebas de:
> - Coma, punto y coma y `·`, con hallazgo bloqueante primero y después.
> - Hallazgos exclusivamente de instrumento y ausencia legítima de hallazgos.
> - Comas y paréntesis dentro de la evidencia.
> - Contenido adicional o mal formado que antes podía quedar ignorado.
> - Reapertura de un REQ, que no debe quedar impedida por una regla de cierre.
>
> Comprueba la denegación y el efecto sobre el archivo, junto con controles legítimos. Reutiliza el banco existente.
>
> **2. Completar D: preparación del paralelismo**
>
> La herramienta ya deniega cuando falta `Archivos:`; conserva ese comportamiento.
>
> Añade a la preparación del REQ la comprobación explícita de que el campo existe, contiene las rutas del alcance y puede interpretarlo la herramienta antes de solicitar paralelismo. Comprueba que `(ninguno)` sólo se utiliza cuando realmente no hay archivos afectados.
>
> Reutiliza la plantilla y las reglas existentes, con una referencia breve desde la Definition of Ready del analista. No copies la política en varias sedes ni exijas rellenar retrospectivamente todos los REQ.
>
> Verifica un REQ nuevo mínimo siguiendo ese recorrido y los casos disjunto, compartido y sin declarar. No autorices reparto manual como sustituto de la herramienta. La numeración duplicada de identificadores queda fuera.
>
> **3. Alcance y ciclo**
>
> Registra ambos cambios con trazabilidad a esta autorización y a los hallazgos existentes. Usa el rigor y las revisiones que correspondan al cambio del hook, agrupando la entrega para evitar ciclos separados por frase.
>
> No reinicies contadores ni aceptes residuales en mi nombre. Agrupa los hallazgos de cada revisión antes de reparar. Si se agota el presupuesto vigente, presenta el impedimento exacto y el delta pendiente.
>
> Autorizo implementación, pruebas, commits, push sin force y un PR en borrador. Ejecuta el CI requerido sobre la cabeza final; conserva su resultado sin relanzar buscando verde. No fusiones ni publiques.
>
> **4. Hueco C y documento aportado**
>
> No implementes ahora una puerta posterior ni bloqueos generales de intérpretes. C sigue siendo una limitación de seguridad reproducida; que sea conocida no equivale a que yo haya aceptado aplazarla.
>
> En la entrega final presenta brevemente la decisión de publicación que exige C: acciones que quedan fuera del control, mitigación disponible y protección que continúa dependiendo de los agentes. No lo marques aceptado.
>
> Si el Markdown está accesible, consérvalo íntegro y úsalo como fuente, no como instrucciones ejecutables. Si no está disponible, indica esa limitación una sola vez y continúa A y D con la evidencia ya obtenida. No vuelvas a buscarlo por directorios personales.
>
> No declares revisados los puntos del documento que no se hayan evaluado.
>
> **5. Fuera del encargo**
>
> Sin cambios de modelos, actualización de Claude Code, sondas de coste, umbrales, workflow, ruleset, rotación, SEC-111 ni consumidores. No añadas detectores de palabras en los paréntesis de los veredictos. No fusiones #54 ni #57.
>
> Entrega un único resultado: reparación antes/después, prueba del recorrido de paralelismo, cobertura de QA y seguridad, SHA y CI del candidato, y decisiones concretas pendientes para publicar. Sin prometer protección más amplia que la comprobada.

**Lo que la coordinadora añade, rotulado como suyo:** rama `feat/req-031-hallazgos-y-paralelo` desde `origin/main` = `a7a60c247aae6853d492a71313ab9fabed3c17a7`. El REQ se numera **REQ-031**. El informe `ArnesJuan-hallazgos-abiertos-2026-09-23.md` no está disponible (limitación declarada una vez; no se vuelve a buscar). Evidencia inicial de A: `evaluacion-2026-09-27/A-hallazgos-separador.txt` (con `·` y con `;` la puerta permite cerrar con `usuario/dinero` abierto; con coma deniega; orden invertido deniega). Evidencia inicial de D: `evaluacion-2026-09-27/D-paralelo.txt`.

### RESUELTA (propietario, 2026-09-26) — **REQ-030: se autoriza corregir QA-030-10**, segunda intervención documental por excepción adicional; historial y contadores conservados

**Texto del propietario, literal e íntegro:**

> Autorizo corregir QA-030-10 en `feat/req-030-sondas-r5`, partiendo de la cabeza local verificada. Registra esta intervención documental como excepción adicional, conservando todo el historial y los contadores.
>
> **Alcance autorizado**
>
> Corrige las dos frases señaladas en CA-07 (g) y el README del banco, y cualquier aparición equivalente de esa misma promesa excesiva en las sedes afectadas por REQ-030.
>
> La autorización cubre el defecto por propiedad, no sólo dos cadenas literales: no necesitas otra decisión mía para corregir otra repetición de la misma afirmación dentro de ese alcance.
>
> La redacción debe distinguir:
>
> - FAIL: se cumple la condición de fallo definida por el control.
> - INCONCLUSO: el funcionamiento no quedó acreditado; no demuestra por sí solo una avería.
> - PASS: acredita únicamente lo que el control mide, con los límites ya declarados.
>
> Usa la formulación acotada de ADR-012 —«sale FAIL o queda no acreditada»— donde corresponda, conservando sus condiciones. No prometas detectar toda avería ni amplíes la cobertura atribuida a C3.
>
> **Ejecución y revisión**
>
> Agrupa las correcciones en un único write-back del analista. Haz un barrido de coherencia de la misma promesa en las sedes vigentes; conserva los textos históricos como historia, sin reescribir veredictos anteriores.
>
> QA verifica el delta documental y determina QA-030-10. Sólo después de QA favorable, seguridad revisa el texto y determina SEC-110 y SEC-109. Cada veredicto debe identificar su cabeza y alcance.
>
> No repitas ensayos ni revisiones del código que no cambió. Esta intervención no demuestra mejoras de rendimiento, fiabilidad o frecuencia de resultados concluyentes.
>
> **Pendiente separado**
>
> La regla para resolver una acreditación de rendimiento pendiente de un cambio del mecanismo sigue sin definirse. No la inventes, no la des por resuelta y no conviertas una corrida favorable en resolución automática.
>
> En la entrega, explica concretamente qué acciones impide ese vacío: cierre de qué clase de REQ, integración o publicación, citando la regla aplicable. Distingue los impedimentos actuales de las limitaciones para trabajos futuros.
>
> **Límites**
>
> Sin código, mediciones nuevas, cambios de umbral, workflow, ruleset, otras sondas, consumidores, REQ-029 o PR #53. Sin nuevas familias de identificadores, formularios ni obligaciones ajenas a esta corrección.
>
> Puedes realizar los commits locales necesarios con los controles activos. Sin push, CI remoto, fusión, publicación ni cambio de versión.
>
> Entrega un único resultado breve: cabeza final, sedes corregidas, veredictos y cobertura, estado de los hallazgos y lista consolidada de impedimentos restantes. Si aparece un defecto distinto, regístralo sin encadenar su reparación. No cierres REQ-029.

**Lo que la coordinadora añade, rotulado como suyo:** sexta intervención sobre el REQ (tres vueltas, vuelta 4 por excepción, dos intervenciones documentales por excepción); nada se reinicia. Sin código, sin ensayos. Cabeza local verificada de partida: `db70d31` (código = `ccdc7e4`).

**La entrada tal como estaba, conservada:**

#### [2026-09-26] (coordinadora) — REQ-030 `bloqueado` tras la intervención documental: QA-030-10 (`contrato`, dos frases) deja SEC-110 sin cerrar; ¿se autoriza corregir esas dos sedes?

- **Contexto:** la intervención documental por excepción corrigió SEC-110 en siete sedes e incorporó SEC-109(b) fiel en sus cinco puntos (QA lo contrastó literalmente). Pero en dos sedes —`requirements/REQ-030.md` CA-07 (g) («**Qué avería detecta:** toda la que impida eso… sale FAIL si…») y `tests/escenarios/hooks/README.md` («Detecta toda avería que lo impida: sale FAIL si…»)— la promesa principal sigue siendo absoluta con la condición colgando detrás: una avería que impide el PASS dejando resueltas a ambos lados del techo o < 3 resueltas **no** se detecta, queda INCONCLUSO «no demuestra avería» (medido: `v4-fb-mezcla.log`). Es la misma forma que SEC-110 y la decisión D prohíben, y es el defecto de barrido incompleto de la promesa. **QA-030-10 (`contrato`)**, dueño `analista-requerimientos`; corrección sólo de texto: alinear las dos frases con la de ADR-012 («toda avería que lo impida sale FAIL **o queda no acreditada**»). QA no pasó a seguridad (instrucción: sólo tras QA favorable). SEC-110 y SEC-109 siguen como los dejó R-043-A. Contadores y excepciones conservados: tres vueltas, vuelta 4 por excepción, intervención documental por excepción.
- **Acción que impide (regla 2):** cerrar REQ-030. No impide presentar la entrega ni preparar el PR; no afecta a REQ-029/PR #53.
- **Opciones:** **A** — autorizar la corrección de las dos frases (analista), re-verificación documental de QA y determinación del auditor sobre SEC-110/SEC-109 (sin código, sin ensayos), registrada como segunda intervención documental por excepción. **B** — dejar REQ-030 `bloqueado`.
- **Recomendación de la coordinadora:** A. La causa es mía y del analista (barrido incompleto de la promesa, pese a la regla de barrer por propiedad); no se presenta como avance.
- **Espera:** decisión del propietario. **Trabajo que sigue mientras tanto:** ninguno de REQ-030.

*(histórica; resuelta arriba)*

### RESUELTA (propietario, 2026-09-26) — **REQ-030: intervención documental acotada para SEC-110 y decisión sobre SEC-109(b)**, excepción expresa al presupuesto agotado; contadores y excepciones anteriores conservados

**Texto del propietario, literal e íntegro:**

> Autorizo una intervención documental acotada para SEC-110 y la decisión de SEC-109(b) en `feat/req-030-sondas-r5`. Es una excepción expresa al presupuesto agotado para este write-back y su revisión; conserva todas las vueltas y excepciones anteriores, sin reiniciar contadores ni declarar que la intervención no cuenta.
>
> El objetivo sigue siendo terminar esta dependencia de REQ-029. No abras otra investigación ni reparación de código.
>
> **SEC-110**
>
> El analista corrige las cuatro sedes que prometen más cobertura de la demostrada, usando la propiedad verdadera identificada por el auditor. Deben distinguir qué avería detecta C3, qué no cubre y bajo qué condiciones queda inconcluso.
>
> Conserva los resultados medidos y sus límites. No cambies el código, los umbrales, el presupuesto de mediciones ni la regla de validación para acomodarlos a la redacción.
>
> **Decisión sobre SEC-109(b)**
>
> 1. Un inconcluso heredado de `main` no impide por sí solo integrar un PR documental que no altere el sujeto ni el instrumento medidos. Deben comprobarse los dos SHA y el conjunto de rutas correspondiente, y citarse el pendiente por identificador. Esto no elimina otros requisitos de integración ni convierte el inconcluso en PASS.
>
> 2. En un REQ que cambia el mecanismo, si la acreditación de rendimiento es un criterio exigido, su ausencia impide dar ese criterio por satisfecho y cerrar el REQ. No autorizo convertirla en deuda no bloqueante mediante la etiqueta `instrumento`, trasladarla para cerrar "por otra vía" ni exceptuarla por inferencia.
>
> 3. Registra el pendiente en la sede existente del REQ afectado, con dueño —su desarrollador— y revisión de QA y seguridad según corresponda. Si se referencia desde `docs/PENDIENTES.md`, usa un puntero: no crees una segunda versión del pendiente.
>
> 4. No acepto "una corrida posterior en PASS" como resolución automática. La acreditación debe seguir un procedimiento y presupuesto fijados antes de medir, conservar todas las ejecuciones y considerar el conjunto de resultados. No elijas una corrida favorable ni borres resultados adversos.
>
> 5. Puedes fijar 1.35.0 como hito de revisión del pendiente. Llegar a ese hito obliga a revisarlo; no lo resuelve ni autoriza el cierre automáticamente.
>
> Usa el procedimiento vigente donde sea suficiente. Si falta una regla concreta para acreditar el conjunto de resultados, identifica ese hueco y su consecuencia; no inventes otro diseño de medición dentro de este write-back.
>
> **Revisión**
>
> Agrupa el write-back en una sola intervención. QA verifica la coherencia con esta decisión y, después de QA favorable, seguridad determina el estado de SEC-110 y SEC-109. Las firmas deben indicar la cabeza y el alcance revisados.
>
> No repitas ensayos: esta autorización es documental. Conserva como limitaciones las 10 de 16 calibraciones inconclusas, el PASS cercano al techo y el carácter no medido de la estimación de rechazo. No presentes la corrección textual como mejora de fiabilidad o rendimiento.
>
> **Límites y entrega**
>
> Sin cambios en código, workflow, ruleset, otras sondas, consumidores, REQ-029 o el PR #53. El delta de workflow sigue sin aplicar.
>
> Puedes realizar commits locales con los controles activos. Sin push, CI remoto, fusión, publicación ni cambio de versión.
>
> Entrega un único resultado breve: cabeza local, textos corregidos, estados determinados por QA y seguridad, cobertura de las firmas y cualquier impedimento restante. No encadenes reparaciones adicionales ni cierres REQ-029.

**Lo que la coordinadora añade, rotulado como suyo:** se registra como **«intervención documental por excepción expresa (2026-09-26)»**, quinta intervención sobre el REQ tras las tres vueltas y la vuelta 4 por excepción; nada se reinicia ni se declara «no contado». Sin código, sin ensayos.

**Las dos entradas tal como estaban, conservadas:**

#### [2026-09-26] (coordinadora) — REQ-030: SEC-110 (`contrato`, sólo texto) impide cerrar; ¿se autoriza el write-back textual fuera del contador?

- **Contexto:** tras la vuelta 4 (excepción, opción D), `QA: aprobado` sobre `ccdc7e4` y `Seguridad: con-hallazgos` (R-043-A sobre `44f9d58`): **SEC-108 `mitigado`** (C3 en 37/2 juzga la misma calibración que decide CA-03; la avería reproducida pasó de C3 PASS a C3 FAIL), QA-030-07 y QA-030-09 cerrados. El auditor abrió **SEC-110** (`contrato`, severidad baja): la cobertura de C3 está escrita más ancha de lo que es en cuatro sedes de texto —`requirements/REQ-030.md`:270 («un instrumento averiado no puede producir PASS»; lo contradice CA-07 (g), que admite que una avería del brazo «este árbol» salga PASS) y :327-328, `ADR-012`:114 y `tests/escenarios/hooks/README.md`:452 («cubre toda avería que altere lo que mide la calibración»; una avería que la altere sin bajarla del techo da PASS, p. ej. una línea base que no es v1.32.1 pero supera 2,600×, vía SEC-048)—. Es la forma que el propietario prohibió («no prometas cobertura de toda avería posible»). Los mensajes que imprime el programa son correctos. La propiedad verdadera está redactada por el auditor en R-043-A §4. **No hay código ni medición que cambiar**; la regla de aceptación de CA-07 (e) no cambia.
- **Acción que impide (regla 2):** cerrar REQ-030 (hallazgo `contrato` abierto). No impide presentar la entrega ni preparar el PR.
- **Opciones:**
  - **A — Autorizar el write-back textual** (analista, cuatro sedes, con la propiedad de R-043-A §4) y su re-verificación por el auditor (R-043-B) y por QA sobre el texto (sin corridas nuevas: el código no cambia). No es una vuelta dev↔QA (no hay desarrollador); se registra como write-back autorizado fuera del contador, igual que SEC-102 en REQ-025.
  - **B — Dejar SEC-110 abierto** y REQ-030 sin cerrar hasta otra ventana.
- **Recomendación de la coordinadora:** A. La instrucción vigente («si aparece otro impedimento, informa sin encadenar su reparación») es la razón de que no se haya hecho ya.
- **Espera:** decisión del propietario. **Trabajo que sigue mientras tanto:** ninguno de REQ-030.

#### [2026-09-26] (analista-requerimientos) — SEC-109(b): dónde vive la «acreditación pendiente» de REQ-030 CA-08 (ii), y si un inconcluso heredado de `main` impide acogerse a la clase (i)

> **Nota del analista (2026-09-26), no del propietario: esta propuesta NO es texto vigente.** El
> propietario la resolvió arriba con otra redacción. Su «texto propuesto» —el pendiente en `Hallazgos
> abiertos:` como `instrumento` y su traslado a `docs/PENDIENTES.md` si el REQ se cerraba por otra vía—
> y su forzador «una corrida sobre la cabeza integrada o posterior con el caso en PASS» quedan
> **rechazados** por los puntos 2 a 4 de su decisión. Lo vigente está en `requirements/REQ-030.md`
> CA-08 (i) y (ii). La entrada se conserva sólo como historia.

- **Contexto:** SEC-109 (`instrumento`, R-043, `docs/seguridad/registro-seguridad.md`:7443-7462). REQ-030
  CA-08 (ii) dice que, si un PR cambia el mecanismo (`hooks/`, `tools/`) y sale con un INCONCLUSO de
  CA-03 o CA-08 (ii), la acreditación de rendimiento queda **pendiente** y no se da por satisfecha. Pero
  no dice **dónde** se registra ese pendiente, **quién** lo sigue, **qué** lo resuelve ni **cuándo**
  vence. Queda abierta esta secuencia: un PR de mecanismo con una regresión real que sale INCONCLUSO se
  integra con el check verde; desde entonces `main` da INCONCLUSO; y cada PR documental siguiente se
  integra por (i) declarando «no acreditado sobre esta cabeza». Ningún paso es falso, y la regresión
  queda **sin acreditar indefinidamente**. La mitad (a) de SEC-109, las tres formas en que una regresión
  real sale INCONCLUSO, ya está escrita en REQ-030 CA-08. Esta mitad **no** se incorporó: impone
  obligaciones nuevas y cambia qué PR puede integrar, y el propietario pidió presentarla como decisión
  pendiente.
- **Texto propuesto para REQ-030 CA-08 (ii)**, a añadir tras «…no tenga esos casos en PASS»:
  > La acreditación pendiente tiene **sede**: el REQ que cambia el mecanismo la lleva en su campo
  > `Hallazgos abiertos:` como `instrumento` mientras dure —p. ej., `PERF-<REQ>-01 (instrumento)`—, y si
  > ese REQ se cierra por otra vía autorizada, pasa a `docs/PENDIENTES.md` con los mismos datos. **Dueño:**
  > el `desarrollador` de ese REQ. **Forzador:** una corrida sobre la cabeza integrada o posterior con el
  > caso en PASS, o el siguiente cambio de clase (iii), que obliga a validar el instrumento. **Vencimiento:**
  > la ventana de versión abierta (hoy 1.35.0). Resolverlo exige esa corrida en PASS; ni la ausencia de FAIL
  > ni la integración lo resuelven.
- **Pregunta: ¿un inconcluso heredado de `main` impide acogerse a la clase (i) mientras haya un
  pendiente abierto?**
  - **Opción 1 (recomendada): no lo impide, pero obliga a citarlo.** Un PR documental puede acogerse a
    (i) con un INCONCLUSO del mismo caso; su declaración en el PR tiene que **citar por identificador** el
    pendiente abierto, y no puede presentarse como acreditación de rendimiento.
    - *Consecuencia para la integración:* los PR documentales siguen integrándose; el pendiente sigue
      visible en cada PR y no desaparece, porque tiene sede, dueño y vencimiento.
    - *Riesgo:* la regresión puede seguir viva hasta el vencimiento.
  - **Opción 2: lo impide.** Mientras exista un pendiente abierto sobre CA-03 o CA-08 (ii), ningún PR
    puede acogerse a (i) por un INCONCLUSO de ese caso.
    - *Consecuencia para la integración:* todo PR, también los documentales, queda bloqueado hasta que
      alguien obtenga el PASS o el propietario decida.
    - *Ventaja:* fuerza la acreditación enseguida.
    - *Coste:* con la frecuencia medida de calibración no resuelta (7 de 12 en local), puede bloquear
      trabajo que no toca nada medido.
  - **Sin ninguna regla (lo que hay hoy):** la secuencia de arriba no tiene forzador. La visibilidad (la
    línea `Resultado:`) existe; el seguimiento, no.
- **Responsable de aplicarlo si se aprueba:** el `analista-requerimientos` hace el write-back en REQ-030
  CA-08 (ii) y, si la opción cambia qué PR puede integrar, en CA-08 (i). El `desarrollador` de cada REQ de
  mecanismo futuro lleva el pendiente. QA y el auditor lo verifican al validar ese REQ.
- **Acción afectada:**
  - *Integrar:* qué PR puede integrarse con un INCONCLUSO de CA-03/CA-08 (ii). La opción 2 lo restringe;
    la opción 1 sólo añade una cita.
  - *Cerrar:* un REQ de mecanismo con el pendiente abierto como `instrumento` **puede** cerrarse, porque
    `guard-completado` no bloquea `instrumento`. Si el propietario quiere que no cierre, la clase tendría
    que ser `contrato`, y esa es otra decisión.
  - *Esta entrada, mientras siga en `## Pendientes`:* `guard-completado` deniega marcar **cualquier**
    REQ como `completado`, incluido REQ-030. Es deliberado.
- **Recomendación del analista:** opción 1 con el texto propuesto, que da seguimiento sin bloquear
  trabajo que no toca lo medido.
- **Trabajo que sigue mientras tanto:** la vuelta 4 de REQ-030 (SEC-108, QA-030-07 y QA-030-09) no
  depende de esta decisión y continúa.
- **Espera:** decisión del propietario.

*(históricas; resueltas arriba)*

### RESUELTA (propietario, 2026-09-26) — **REQ-030: opción D para QA-030-07/SEC-108**, una vuelta adicional por excepción, acotada a SEC-108, QA-030-07 y QA-030-09; contador 3 de 3 conservado

**Texto del propietario, literal e íntegro:**

> Elijo la opción D. Autorizo una vuelta adicional por excepción, acotada a SEC-108, QA-030-07 y QA-030-09, en `feat/req-030-sondas-r5`. Conserva las tres vueltas consumidas y registra esta autorización sin reiniciar contadores.
>
> El objetivo sigue siendo terminar la dependencia de medición que espera REQ-029, sin ampliar REQ-030.
>
> **Corrección autorizada**
>
> - Mueve el control a 37/2 y aplica el juez de C3 a la calibración que CA-03 ya ejecuta, utilizando el mismo medidor, ruta y tamaños. Retira la copia redundante de 37/7 y actualiza referencias, contrato, recuentos y autoprueba que dependan de esa retirada.
> - Esta decisión sustituye expresamente mi indicación anterior de ubicar C3 en 37/7. No autoriza levantar la restricción de compartir código entre secciones.
> - Corrige QA-030-09: el resumen debe distinguir instrumento no acreditado de rendimiento no acreditado, conservando el detalle de cada caso.
> - Mantén R=5, los umbrales y la distinción entre avería demostrada y resultado inconcluso. No transformes una calibración insuficiente en aprobación del instrumento.
>
> **Validación decisiva**
>
> Reutiliza la avería que QA reprodujo: modifica la ruta de la línea base en una copia de prueba de 37/2 y verifica que el instrumento roto ya no puede darse por acreditado por un control independiente que siga pasando.
>
> Comprueba también el recorrido normal y las distinciones existentes. Conserva todos los resultados y declara qué consecuencia es mecánica y cuál deben aplicar QA y seguridad. No prometas cobertura de toda avería posible.
>
> Fija el presupuesto antes de medir; no repitas hasta obtener verde ni abras una batería general nueva. Ejecuta las verificaciones exigidas sobre la cabeza corregida y reutiliza la evidencia que siga siendo válida.
>
> **Revisión**
>
> Desarrollador → QA del delta → seguridad sólo después de QA favorable. Cada rol determina los hallazgos y veredictos que le corresponden. No aceptes residuales en mi nombre ni apruebes por agotamiento.
>
> Para SEC-109(b), presenta la decisión pendiente de forma concreta: texto propuesto, responsable, acción afectada y consecuencia para la integración. No la incorpores como si ya estuviera autorizada ni la declares resuelta.
>
> **Límites**
>
> Conserva como limitación las 7 de 12 calibraciones locales sin resolver. Esta reparación no demuestra que esa frecuencia mejore.
>
> Sin tocar CA-09, la sección 25, otros fallos, hooks, workflow, ruleset, consumidores, REQ-029 o el PR #53. Sin ajuste de continuidad.
>
> Puedes realizar commits locales con los controles activos. Sin push, CI remoto, fusión, publicación, cambio de versión ni cierre de REQ-029.
>
> Entrega un único resultado: cabeza local, delta, reproducción antes/después, comprobaciones, veredictos y su cobertura, estado de los tres hallazgos y decisión pendiente de SEC-109(b). Si aparece otro impedimento, informa sin encadenar su reparación.

**Lo que la coordinadora añade, rotulado como suyo:** esta vuelta se registra como **«vuelta 4, por excepción expresa del propietario (2026-09-26)»**; las tres vueltas consumidas se conservan en el Historial y el contador no se reinicia. La decisión pendiente de SEC-109(b) se presentará como entrada nueva bajo `## Pendientes`, con texto propuesto, responsable, acción afectada y consecuencia, sin incorporarla al REQ.

**La entrada tal como estaba, conservada:**

#### [2026-09-26] (coordinadora) — REQ-030 `bloqueado`: tope de 3 vueltas dev↔QA agotado con QA-030-07 y QA-030-09 (`contrato`) abiertos; SEC-108 sigue abierto

- **Contexto:** vuelta 3 de 3 (opción A del propietario) sobre `7b96dcc`. La regla de CA-07 (e) **se cumplió** en las 3 corridas fijadas (I/W0 sin FAIL, WD PASS 3/3 en las dos entradas, C3 PASS 3/3 con mínimos 3,611× · 3,396× · 3,221×) y el fail-before de C3 **se cumplió** (reloj constante → FAIL «avería demostrada»; bajo el suelo → INCONCLUSO; mezcla → INCONCLUSO; los tres distintos). Pero QA reprodujo que **C3 comprueba una COPIA del instrumento** (`mat57`/`mide57`, copias de `mat37`/`mide37` de 37/2, decisión del desarrollador para no compartir código entre secciones, CA-19/H-04 de REQ-014): una avería que vive sólo en 37/2 (QA cambió la ruta de la línea base en 37/2:228-229) deja **C3 en PASS** y CA-03 en INCONCLUSO indistinguible de QA-030-05 → la regla de CA-07 (e) **acreditaría** un cambio de clase (iii) con el instrumento de CA-03 roto. Es exactamente lo que el propietario pidió que no pasara («debe comprobar que una avería del instrumento impide acreditar un cambio de la propia sonda»). **QA-030-07 (`contrato`).** Además **QA-030-09 (`contrato`)**: la línea `INCONCLUSO: N — rendimiento NO acreditado…` del resumen (`run.sh`:1549) rotula igual un C3 INCONCLUSO (instrumento no acreditado) que una medición real inconclusa; la línea del caso sí distingue. QA no pasó a seguridad (instrucción: «sólo después de QA favorable»). **SEC-108 sigue abierto** (`contrato`); SEC-109 parcialmente escrito (las tres formas), su mitad de obligaciones nuevas sigue abierta por decisión del propietario.
- **Acción que impide (regla 2):** cerrar REQ-030 y, con ello, la dependencia que REQ-029 necesita para una integración defendible. **No** impide nada de REQ-029/PR #53 por sí mismo (siguen como estaban). Contador **3 de 3 agotado**: cualquier vuelta más es excepción expresa del propietario.
- **Opciones (las tres primeras las enumeró QA sin elegir; la cuarta es de la coordinadora):**
  - **A — C3 invoca el medidor y la materialización de 37/2:** cubre el instrumento real, pero exige compartir código entre secciones (mudanza AN-021-01 de REQ-021 o excepción a CA-19/H-04 de REQ-014). Levantar un límite escrito para que quepa: señal de alcance mal elegido.
  - **B — Guarda byte a byte entre las copias de 37/7 y sus originales de 37/2** (normalizando las etiquetas `c3-`): convierte AN-021-01 en comprobado, pero **no cubre** lo que vive fuera de las funciones copiadas (el bucle de 37/2, la ruta `HER37`, tamaños y k que pasa: la avería reproducida por QA está ahí). No cierra QA-030-07 entero.
  - **C — Acotar por write-back lo que C3 promete** («avería de lo compartido») y declarar el resto residual con dueño: es aceptar un residual; **documentar no es remediar**; sólo el propietario.
  - **D — Mover el control a 37/2, aplicando el juez de C3 a la calibración que CA-03 ya mide** (la serie de v1.32.1, k=20, R=5, con el mismo `mide37`, misma ruta, mismos tamaños y k): con la palanca, «todas ≤ 2,600× → FAIL avería demostrada», mezcla o < 3 → INCONCLUSO «instrumento no acreditado», resuelta → PASS; sin palanca, la calibración sigue siendo precondición silenciosa de CA-03 como hoy. Es el fail-before retirado, con la regla de R=5 y los tres resultados, **en su sitio original**. Cubre el instrumento que decide, no comparte nada entre secciones, retira la copia de AN-021-01 y ahorra los 166–193 s de C3 con la palanca (la medición ya se hace). Se aparta de la letra «añade a 37/7» de la decisión A, no de su fin. Exige **una vuelta más** (desarrollador + QA + seguridad) por excepción expresa; QA-030-09 (una línea de `run.sh` + autoprueba) cabe en la misma.
- **Recomendación de la coordinadora:** **D**, con QA-030-09 agrupado, como excepción única y declarada al contador. Si el propietario no concede la excepción: REQ-030 queda `bloqueado` con SEC-108, QA-030-07 y QA-030-09 abiertos, y la integración de REQ-029 sigue sin esta dependencia.
- **Espera:** decisión del propietario. **Trabajo que sigue mientras tanto:** ninguno de REQ-030. *(histórica; resuelta arriba)*

### RESUELTA (propietario, 2026-09-26) — **REQ-030: opción A para SEC-108**, intervención conjunta y acotada en la vuelta 3 de 3

**Texto del propietario, literal e íntegro:**

> Elijo la opción A para SEC-108. Autorizo una intervención conjunta y acotada en `feat/req-030-sondas-r5`, usando la vuelta 3 de 3 disponible. Conserva el historial y los contadores; no los reinicies.
>
> El objetivo sigue siendo terminar esta dependencia para integrar REQ-029. No amplíes REQ-030 a otras sondas.
>
> **Reparación autorizada**
>
> Añade a 37/7 el control de medición de CA-03 necesario para cerrar SEC-108. Debe comprobar que una avería del instrumento impide acreditar un cambio de la propia sonda.
>
> Distingue expresamente:
> - Una medición real inconclusa.
> - Un control que demuestra una avería.
> - Un control que no pudo acreditar el funcionamiento del instrumento.
>
> No conviertas esos tres resultados en una misma abstención que permita aprobar el instrumento. Un control inconcluso no acredita su funcionamiento. Declara qué consecuencia aplica mecánicamente y cuál deben aplicar QA y seguridad.
>
> Fija antes de ejecutarlo el presupuesto y los resultados esperados. Reutiliza los controles y la evidencia existentes; no ajustes parámetros después de ver los resultados ni repitas hasta obtener verde.
>
> **Agrupa en esta misma vuelta**
>
> - El write-back contractual y documental necesario para SEC-108.
> - SEC-109: primero lee y explica brevemente su contenido. Si es únicamente el write-back asociado a esta reparación, inclúyelo; si requiere otra decisión o cambio de comportamiento, déjalo fuera y señálalo.
> - La actualización de la fila desfasada de REQ-030 en `requirements/README.md`, conforme a los veredictos realmente emitidos.
>
> No hace falta detenerte por la explicación de SEC-109 si encaja en ese alcance.
>
> **Validación**
>
> QA revisa el delta y sus controles; sólo después de QA favorable pasa a seguridad para determinar el estado de SEC-108 y la cobertura de su firma. No apruebes por agotamiento ni aceptes residuales en mi nombre.
>
> Reutiliza las comprobaciones válidas y ejecuta las necesarias sobre la cabeza corregida. Mantén separados el veredicto de QA y el resultado del banco completo.
>
> Conserva los FAIL de la sección 25 y los resultados inconclusos de calibración. No los atribuyas al entorno sin evidencia ni investigues sus causas en este encargo. Que la calibración no resolviera en 4 de 7 corridas sigue siendo una limitación de utilidad del procedimiento.
>
> **Límites**
>
> Sin cambios en umbrales, hooks, otras sondas, workflow o ruleset. El delta del resumen del workflow sigue preparado, sin aplicar.
>
> Sin tocar REQ-029, el PR #53, consumidores ni el ajuste de continuidad. Sin nuevas investigaciones o reparaciones colaterales.
>
> Puedes hacer commits locales con los controles activos. No hagas push ni ejecutes CI remoto todavía.
>
> **Entrega única**
>
> Cabeza local, cambios, resultado de cada control y su consecuencia, veredictos con su cobertura, estado de SEC-108 y SEC-109, y pendientes concretos. Si queda un impedimento al agotar esta vuelta, informa sin abrir otra.
>
> Sin fusión, publicación, cambio de versión ni cierre de REQ-029. No prometas que esta reparación resuelve CA-09 o el reloj de la sección 25.

**La entrada tal como estaba, conservada:**

#### [2026-09-26] (coordinadora) — REQ-030: SEC-108 (`contrato`) y QA-030-05 — qué detector mecánico conserva CA-03 cuando su instrumento se rompe, y cómo se acredita la clase (iii) si la calibración no resuelve en local

- **Contexto:** REQ-030 recorrió el ciclo completo sobre la rama local `feat/req-030-sondas-r5` (sin push): analista → desarrollador → `QA: aprobado` (vuelta 2 de 3, `322bc7c`) → `Seguridad: con-hallazgos` (R-043, `3c9b7e6`). El auditor abrió **SEC-108** (`contrato`, impide cerrar): al sustituir el caso *fail-before* de CA-03 (k=1, en `main`) por la calibración k=20 dentro del propio caso —tal como se ensayó—, **desapareció el único detector mecánico de un instrumento de CA-03 roto**: antes daba FAIL; ahora un instrumento ciego deja CA-03 en INCONCLUSO indefinidamente con el check verde, y una entrega de clase (iii) que lo rompa cumple la letra de CA-08 (iii) (CA-06 valida sólo el juez; CA-07 sólo la sonda de CA-08 (ii)). Esta entrega **no** está afectada (calibraciones resueltas medidas: CI 5/5, local 3/7). Y está ligado a **QA-030-05** (`instrumento`): en local la calibración no resolvió en 4 de 7 corridas completas, siempre por la repetición #1 de v1.32.1 (2,10–2,55× contra 2,600); en CI resolvió 5/5 con mínimos 2,699–2,809×. **SEC-109** (`instrumento`): la «acreditación pendiente» de CA-08 (ii) no tiene sede, dueño, forzador ni vencimiento, y no está declarado cuándo una regresión real sale INCONCLUSO donde la base daba FAIL. El contador dev↔QA está en **2 de 3**: queda una vuelta.
- **Acción que impide (regla 2):** **cerrar** REQ-030 (`Seguridad: con-hallazgos` + hallazgo `contrato`). **No** impide presentar la entrega ni preparar el PR; **no** afecta a REQ-029 ni al PR #53. Punto 3 del propietario («conserva los controles de regresión necesarios») es la regla que SEC-108 invoca.
- **Opciones:**
  - **A — Control de medición para CA-03 en 37/7 (a demanda, clase (iii)):** un séptimo control «la calibración de CA-03 resuelve» (v1.32.1 con k=20 supera 2,600× en ≥ 3 de 5 repeticiones): PASS si resuelve, FAIL si no. Regla de aceptación **fijada de antemano** por el analista para la validación (iii): 3 corridas fijas, todas registradas, ninguna descartada; propuesta: resuelve en **al menos 1 de 3** (un instrumento ciego no resuelve nunca; uno sano puede no resolver por ruido, QA-030-05). Tensión declarada: una regla «≥ 1 de 3» se parece a «repetir hasta verde»; lo que la distingue es el presupuesto fijo previo, que todas cuentan y que la propiedad es asimétrica (detectar lo que un instrumento ciego no puede). **Consume la vuelta 3 de 3** (desarrollador + QA + auditor). Consecuencia si QA encuentra algo más: `bloqueado` y escalado.
  - **B — Restaurar el caso fail-before en cada corrida del banco** (k=1 como en `main`, o k=20): recupera el detector mecánico en la puerta requerida, pero reintroduce el rojo por ruido que este REQ retira (2,443× medido en CI `d413405`). Contrario al objetivo del encargo.
  - **C — Aceptar SEC-108 como residual declarado** (dueño, forzador = el próximo cambio de clase (iii), vencimiento 1.35.0) y hacer el write-back de SEC-109 (sede, dueño, forzador, vencimiento de la «acreditación pendiente» y las tres formas en que una regresión sale INCONCLUSO). Sólo el propietario puede bajar un `contrato`; el auditor re-verificaría (R-043-A) sin gastar vuelta dev↔QA. Deja el banco sin detector mecánico de un instrumento de CA-03 roto hasta 1.35.0.
- **Sobre QA-030-05, en cualquier opción:** no se ajusta el techo ni k. Queda registrado con dueño (`desarrollador`, hipótesis de calentamiento de la repetición #1 **no medida**) y forzador (el primer INCONCLUSO de CA-03 en CI); investigar la causa es trabajo nuevo y no se abre sin autorización.
- **Recomendación de la coordinadora:** **A**, con el write-back de SEC-109 en la misma vuelta (analista), porque es lo que el punto 3 del propietario pide literalmente y porque C convierte el hallazgo en documentación. Si el propietario prefiere no gastar la última vuelta, C con vencimiento 1.35.0.
- **Espera:** elección del propietario entre A, B y C, y confirmación de la regla de aceptación de A si la elige. **Trabajo que sigue mientras tanto:** ninguno de REQ-030. *(histórica; resuelta arriba)*

### RESUELTA (propietario, 2026-09-26, decisión tomada fuera de la cola y registrada aquí íntegra ANTES de despachar) — **REQ-030: se AUTORIZA implementar de forma acotada el procedimiento ensayado para CA-03 y CA-08 (ii) de REQ-017, con la decisión sobre inconclusos**

**Por qué está aquí:** es la fuente íntegra y literal del encargo (`AGENTS.md` §14 y regla de fidelidad: el pedido del propietario viaja entero, nunca resumido por la coordinadora). Nació como mensaje del propietario a la sesión coordinadora tras el informe de las cinco corridas del ensayo en CI (`evidencia/prueba-despacho-2026-09-14` → `sondas-coste/ensayo-ci/resultados.md`, commit `d5ddc01`). Se copia sin cortes.

**Texto del propietario, literal e íntegro:**

> Autorizo implementar de forma acotada el procedimiento ensayado para CA-03 y CA-08 (ii) de REQ-017. Terminamos la fase experimental: reutiliza la evidencia local y las cinco corridas de CI, sin ampliar la muestra.
>
> El objetivo sigue siendo permitir una integración defendible de REQ-029 y mejorar la fiabilidad de estas dos sondas. No estamos rehaciendo todo el banco.
>
> **Decisión sobre resultados inconclusos**
>
> - Los umbrales permanecen intactos.
> - Un inconcluso significa rendimiento no acreditado; debe quedar visible en el resumen, no sólo en el log detallado.
> - Puede permitir integrar un cambio que no altere el sujeto medido ni el procedimiento de medición, con esa identidad comprobada y la limitación declarada. Esto no elimina ningún FAIL ni sustituye los demás requisitos de integración.
> - Si el cambio afecta al rendimiento medido, un inconcluso deja pendiente su acreditación y no permite darla por satisfecha.
> - Un cambio al propio instrumento, como esta entrega, requiere validar el instrumento; no puede acogerse a la excepción por "hooks idénticos".
> - No se obtiene acreditación seleccionando una corrida favorable entre otras adversas.
>
> La detección de la demora artificial es un control de la prueba, no su finalidad ni garantía de detectar cualquier regresión.
>
> **Implementación autorizada**
>
> 1. Trabaja desde `main` verificada, en una rama nueva y separada de los PR #53 y #54.
> 2. Abre el REQ acotado correspondiente y versiona los criterios afectados de REQ-017 mediante el ADR necesario, conservando su historia y los resultados anteriores.
> 3. Incorpora el presupuesto fijo de repeticiones, el evaluador y la calibración de CA-03 conforme al procedimiento ensayado. Conserva los controles de regresión necesarios, distinguiendo pruebas sintéticas del evaluador y pruebas de medición.
> 4. Los FAIL esperados de los controles deben comprobarse como resultados esperados; no deben dejar deliberadamente rojo el banco de producción.
> 5. Define quién determina si un cambio afecta al sujeto o al instrumento, qué evidencia utiliza y quién verifica esa determinación. Reutiliza el análisis de alcance y las revisiones existentes, sin crear otro agente ni una aprobación general adicional.
> 6. Declara qué parte de esta disciplina es mecánica y cuál depende de QA y seguridad. No atribuyas al workflow una protección que no implementa.
>
> **Validación**
>
> Realiza el ciclo exigido por las reglas vigentes, acotado al cambio. Reutiliza la evidencia experimental y ejecuta las verificaciones necesarias sobre la implementación final, sin repetir la investigación.
>
> Comprueba especialmente las fronteras, repeticiones no resueltas, calibración insuficiente y resultados mezclados. Mide el tiempo de la parte adoptable durante la validación normal; no abras otro experimento sólo para medirlo.
>
> No ajustes parámetros o umbrales para obtener verde. Conserva contadores y agrupa reparaciones dentro del alcance.
>
> **Fuera de alcance**
>
> CA-09 permanece intacto y con sus resultados conservados. Puede seguir bloqueando una integración; no prometas que esta entrega garantiza desbloquear el PR #53.
>
> No modifiques hooks, rulesets, consumidores, REQ-029 ni el ajuste de continuidad. El PR #54 es evidencia experimental y no se fusiona.
>
> Si la aplicación de esta decisión necesita cambiar el workflow, prepara ese delta concreto para mi aprobación antes de aplicarlo. No sustituyas esa necesidad por una afirmación documental de control automático.
>
> Puedes hacer commits locales con los controles activos. Sin push ni CI remoto todavía.
>
> **Entrega**
>
> Presenta la cabeza local, cambios, contrato actualizado, veredictos y su cobertura, resultados de validación, duración medida y limitaciones pendientes. Explica exactamente qué ocurrirá con un inconcluso en un PR documental, en un cambio del mecanismo y en un cambio de la propia sonda.
>
> Sin cerrar REQ-029, fusionar, publicar ni cambiar la versión. No encadenes otras reparaciones.

**Lo que la coordinadora añade, rotulado como suyo (no es texto del propietario):** rama `feat/req-030-sondas-r5` creada desde `origin/main` = `cfb1106` (el `main` local estaba en `cf2009e`, desfasado; no se usó). El REQ acotado se numera **REQ-030** (REQ-029 vive en el PR #53 y no está en `main`). Evidencia reutilizable, por ruta en la rama `evidencia/prueba-despacho-2026-09-14`: `sondas-coste/propuesta.md`, `sondas-coste/propuesta-sondas-REQ-017.patch`, `sondas-coste/ensayo-local/{preregistro.md,resultados.md,juez-sintetico.sh,37-coste-del-escaner-9-ensayo-controles.sh}`, `sondas-coste/ensayo-ci/{preregistro.md,resultados.md,contenido-del-experimento.diff}`.

### RESUELTA (propietario, 2026-09-23, decisión tomada fuera de la cola y registrada aquí íntegra) — **REQ-029 / QA-029-02 y QA-029-03: corrección conjunta, excepción acotada al contador agotado**

**Por qué está aquí:** procedencia de una decisión fuera del artefacto que autoriza (REQ-029 remite). Única copia literal.

> Autorizo corregir juntos QA-029-02 y QA-029-03 en `feat/fidelidad-encargo`, partiendo de la cabeza local verificada. Esta es una excepción acotada al contador agotado de REQ-029: registra la autorización y conserva todas las vueltas consumidas, sin reiniciarlas.
>
> **Correcciones autorizadas**
>
> 1. **QA-029-02:** acota la frase de QA y la referencia del analista a decisiones nuevas que requieren aprobación del propietario. Una autorización inaccesible no acredita esas decisiones. Un REQ existente con contrato y aprobaciones registrados conserva su situación aunque falte la conversación original, declarando la limitación. No cambies esta distinción ni añadas nuevos requisitos de aprobación.
>
> 2. **QA-029-03:** el analista añade `docs/ESTADO.md` al campo `Archivos:` y registra el write-back correspondiente. Comprueba que el campo cubre las rutas realmente modificadas dentro del alcance contratado. Dejar de editar ESTADO no subsana las modificaciones ya realizadas.
>
> Agrupa ambas correcciones en una sola intervención. Reutiliza el contrato, la correspondencia y la evidencia existentes; actualiza únicamente lo afectado, sin rehacer la tabla completa ni transcribir nuevamente mis instrucciones.
>
> **Validación y cierre de esta intervención**
>
> * QA revisa el delta y determina el estado de los dos hallazgos. Comprueba especialmente que la redacción distingue decisiones nuevas pendientes de autorización y contratos existentes aprobados.
> * Sólo después de QA favorable, seguridad revisa el control corregido y determina el estado de SEC-106 y la cobertura de su firma.
> * Ejecuta las comprobaciones locales exigidas y reutiliza la evidencia válida. No repitas la demo ni abras ensayos generales.
> * No aceptes residuales en mi nombre ni apruebes por agotamiento. Si aparece otro impedimento, informa de su acción afectada y su evidencia sin encadenar reparaciones.
>
> **Límites**
>
> Puedes hacer commits locales con los controles activos. Sin push, nuevas corridas de CI, cambios en sondas, umbrales, mecanismos, versión o consumidores. El FAIL del run 35924622453 se conserva.
>
> No trabajes en Adelantos. Tampoco incorpores todavía el ajuste de continuidad: queda para el siguiente encargo, contrastándolo primero con REQ-025, sin añadir otra capa de reglas.
>
> Entrega un único resultado breve: cabeza local, correcciones, comprobaciones, veredictos con su cobertura y pendientes concretos. Distingue revisión del texto de conducta observada. Sin cerrar REQ-029, fusionar ni publicar.

### RESUELTA (propietario, 2026-09-23, decisión tomada fuera de la cola y registrada aquí íntegra) — **REQ-029 / SEC-106: intervención adicional acotada, excepción expresa al contador agotado**

**Por qué está aquí:** procedencia de una decisión fuera del artefacto que autoriza (REQ-029 remite). Es la **única copia literal**.

> Autorizo una intervención adicional, acotada exclusivamente a SEC-106 en `feat/fidelidad-encargo`, PR #53. Es una excepción expresa al contador agotado de REQ-029: conserva las vueltas consumidas y registra esta autorización; no reinicies contadores.
>
> **Decisión de fondo**
>
> No acepto como autorización comprobada una referencia cuyo contenido no puede verificarse. Distingue estos dos casos:
>
> * **REQ existente con contrato y aprobaciones registrados:** la ausencia de su conversación original no invalida esas aprobaciones ni lo devuelve automáticamente a borrador. Conserva la limitación de trazabilidad.
> * **Decisión nueva que requiere al propietario:** citar una autorización inaccesible no acredita que exista ni qué alcance tiene. Aporta una copia fiel y verificable de la decisión o solicita mi confirmación concreta. Hasta resolverlo no se implementa lo dependiente; el trabajo independiente autorizado continúa conforme a las reglas vigentes.
>
> No exijas archivar conversaciones completas, no crees otra firma de QA ni conviertas decisiones técnicas ordinarias en aprobaciones humanas.
>
> **Trabajo autorizado**
>
> 1. Verifica la cabeza vigente del PR y el texto exacto que origina SEC-106.
> 2. Aplica la corrección mínima en su sede normativa y ajusta sólo las referencias, gemelas, contrato y registro necesarios para evitar contradicciones. Reutiliza los roles existentes y las revisiones exigidas, acotadas a este delta.
> 3. Corrige la presentación de SEC-106: el residual y la fecha 2026-10-23 eran propuestas del auditor, no decisiones mías. Conserva el historial y registra esta decisión sin atribuirle efecto retroactivo.
> 4. Comprueba estos casos:
>
>    * REQ previamente aprobado sin conversación original: conserva su situación.
>    * Cambio nuevo con autorización citada pero inaccesible: no se da por autorizado.
>    * Copia verificable o confirmación explícita: permite resolver la decisión dentro de su alcance.
>    * Trabajo independiente y decisión técnica ordinaria: no quedan bloqueados por esa carencia.
> 5. QA y seguridad determinan el resultado y el estado del hallazgo. Distingue comprobación del texto de conducta observada; no repitas la demo ni abras ensayos generales.
>
> **CI y límites**
>
> El FAIL del run `35924622453` sobre `d413405` se conserva. Esta autorización no permite relanzarlo, cambiar sondas, umbrales, tests, workflows ni rulesets.
>
> Puedes realizar commits locales con los controles activos. No hagas push todavía: así separamos la reparación de SEC-106 de la decisión sobre las sondas y evitamos disparar otra corrida sin autorización.
>
> No atiendas paralelismo, otros hallazgos, reparaciones de consumidores ni mejoras colaterales. Si aparece otro impedimento, identifícalo sin encadenar su reparación.
>
> Entrega un único resultado: cabeza local, diff acotado, comprobaciones, veredictos y su cobertura, estado determinado de SEC-106 y pendientes. Sin cerrar REQ-029, fusionar, publicar ni cambiar la versión.

### RESUELTA (propietario, 2026-09-23, decisión tomada fuera de la cola y registrada aquí) — **REQ-029, fidelidad al encargo: autorizada la implementación de la propuesta `fidelidad-encargo/` (`d4e7a4f`) con tres precisiones**

**Por qué está aquí:** la decisión nació en respuesta a la propuesta de la coordinadora, no como entrada pendiente; **esta entrada es su única copia literal** (`requirements/REQ-029.md` §Trazabilidad remite aquí desde el write-back de QA-029-01; corregido por SEC-105), y esta cola es la sede donde la procedencia de una decisión vive **fuera** del artefacto que autoriza (misma figura que SEC-104).

**Texto del propietario, ÍNTEGRO y literal (mensaje del 2026-09-23 a la coordinadora; esta copia sustituye a una anterior «en lo esencial» que cortaba pasajes sin marca — hallazgo QA-029-01):**

> Autorizo implementar la propuesta de fidelidad del encargo preparada en `fidelidad-encargo/`, commit `d4e7a4f`, incorporando estas tres precisiones en la misma entrega. No prepares otra ronda de propuestas.
>
> 1. **Un solo veredicto de QA.** No crees dos firmas, campos ni estados de aprobación. En la evidencia del veredicto vigente, QA indica si contrastó el REQ con la fuente, encontró diferencias o no pudo comprobarlo. La conformidad del código con el REQ no acredita por sí sola fidelidad al pedido ni permite cerrar con decisiones de alcance pendientes.
>
> 2. **Sin bloqueo retroactivo por conversaciones ausentes.** La falta del pedido original no devuelve automáticamente a `borrador` un REQ existente con contrato y decisiones aprobados. Conserva esas aprobaciones y declara la limitación de trazabilidad. Pregunta únicamente por decisiones realmente pendientes o contradicciones detectadas. En encargos nuevos, conserva la fuente desde el inicio; no reconstruyas palabras del propietario.
>
> 3. **Partir un REQ no concede autoridad sobre el alcance.** El analista puede preparar y registrar la partición conforme a las reglas vigentes. Si implica excluir, sustituir o diferir alcance comprometido, necesita la decisión correspondiente del propietario. No uses una partición para esquivar preguntas pendientes o reiniciar contadores.
>
> **Objetivo de esta entrega**
>
> Detectar omisiones, sustituciones y decisiones de negocio no autorizadas antes de implementar. Reutiliza la correspondencia en reparaciones sin cambio contractual; no exijas una tabla nueva ni una revisión completa para cada corrección.
>
> **Ejecución autorizada**
>
> * Verifica la cabeza vigente de `main` y trabaja en una rama aislada, respetando los cambios ajenos.
> * Abre el REQ acotado necesario y realiza el ciclo exigido por las reglas actuales: analista, desarrollador, QA y seguridad cuando corresponda.
> * Incluye el write-back de REQ-025 y la entrada de migración necesarios para mantener las sedes coherentes, sin reabrir sus otras entregas.
> * Conserva una sede normativa con referencias; no copies la regla completa en cada rol.
> * Agrupa las reparaciones de esta entrega y conserva sus contadores. No abras trabajos adicionales por observaciones independientes.
>
> **Validación**
>
> Comprueba gemelas y referencias, ejecuta las verificaciones locales exigidas y verifica que se distinguen estos casos:
>
> * Encargo nuevo con una obligación omitida o sustituida sin autorización.
> * REQ existente aprobado cuya conversación original no está disponible.
> * Reparación que conserva el contrato y reutiliza la correspondencia.
> * Decisión técnica ordinaria que puede avanzar sin aprobación humana adicional.
>
> Usa ejemplos acotados para verificar esas distinciones, sin repetir la demo completa. Distingue revisión del texto de conducta observada: no presentes una lectura del diff como prueba de que los agentes lo cumplirán.
>
> No inventes un encargo para medir ahorro. El coste y la utilidad en un REQ real quedan pendientes de observación si no hay uno disponible y autorizado. No afirmes reducción de tokens, tiempo o dinero.
>
> **Fuera de alcance**
>
> Reparaciones de la demo, REQ-019, otras entregas de REQ-025, sondas de coste, cambios en hooks, herramientas, permisos o umbrales. No cambies la versión ni actualices consumidores.
>
> Puedes hacer los commits locales necesarios con los controles activos. Sin push, fusión ni publicación; cualquier validación de CI pendiente debe quedar identificada.
>
> Entrega un único resultado con la cabeza revisada, cambios realizados, veredictos y su alcance, comprobaciones efectuadas, crecimiento neto del texto obligatorio y pendientes concretos. No declares acreditado lo que todavía no se haya observado.

**Ejecución:** REQ-029 creado por el analista (`1e3ac6f`), con la fila de write-back en REQ-025; implementación, QA y seguridad por el ciclo de autoalojamiento en la rama local `feat/fidelidad-encargo`.

### RESUELTA (propietario, 2026-09-21, decisión tomada fuera de la cola y registrada aquí a posteriori) — **REQ-025 entrega 1: write-back excepcional de SEC-102 y confirmaciones del residual**

**Por qué está aquí:** estas dos decisiones no nacieron como entrada pendiente —el propietario las tomó en respuesta al informe de la coordinadora— y su única copia literal vivía dentro de `requirements/REQ-025.md`, el documento que autorizan (SEC-104, `instrumento`, registro de seguridad R-041-A). La cola es la sede donde la procedencia de una decisión vive **fuera** del artefacto al que da permiso; por eso se pegan aquí literales. **Registrarlas no las convierte en aprobación de nada más.**

**Texto del propietario, literal:** «Autorizo excepcionalmente el write-back de SEC-102: incorporar las dos rutas omitidas en Archivos: y registrar la corrección en el Historial. No reinicies contadores ni abras otras reparaciones. Después, seguridad reverifica ese hallazgo y emite el estado correspondiente sobre la cabeza corregida. Reutiliza la evidencia vigente para lo que no cambie. Confirmo el 2026-10-21 como fecha de revisión del residual. Acepto que la coordinadora señale el primer caso aplicable; QA conserva la responsabilidad de verificarlo. S4 sigue "no observado". No presentes REQ-028 como dependencia para cerrar REQ-025 salvo que el contrato la establezca: haber separado trabajo no crea por sí solo esa dependencia. La entrega 1b sí permanece pendiente. Conserva SEC-103 separado y sin aceptación. Identifica la fuente exacta de la preferencia de edición por consola, sin aplicarla ni modificar configuraciones dentro de este encargo. Actualiza el PR y verifica el CI sobre la cabeza resultante. Sin nuevos ensayos, sin iniciar otras entregas, sin fusionar ni publicar.»

**Ejecución:** write-back del analista en `1932492`; reverificación de seguridad `R-041-A` sobre esa cabeza → SEC-102 `mitigado`, `Seguridad: aprobado`. Fuente de la preferencia identificada (rama de evidencia, `req-025/preferencia-consola-fuente.md`), nada modificado.

### RESUELTA (propietario, 2026-09-21) — **REQ-025 entrega 1: se ACEPTA la laguna de evidencia de QA-025-08 (opción B)**, con residual y sin sustituir ninguna firma

**Texto del propietario, literal:** «Acepto la laguna de evidencia de QA-025-08 para la entrega 1. Conserva S4 como "no observado"; no lo conviertas en satisfecho ni borres el hallazgo. Registra el residual con dueño y fecha de revisión. En el primer caso real aplicable se comprobará si la coordinadora conserva el bloqueo de QA. Si no aparece antes de la fecha, se revisa la aceptación; no se da por acreditado. Pide a QA que determine el veredicto correspondiente con esta aceptación y, si permite avanzar según las reglas vigentes, continúa con seguridad acotada. Mi aceptación no sustituye ninguna firma. OBS-H queda separado y expresamente pendiente: lo observado cuestiona una protección declarada y no queda aceptado por esta decisión. No abras su reparación ahora. Entrega el resultado con el CI de la cabeza actual. Sin nuevos ensayos, sin iniciar 1b ni REQ-028, sin fusión ni publicación.»

**Qué cambia y qué no:** QA-025-08 pasa a **residual aceptado** en `requirements/REQ-025.md` (CA-11 punto 3), con S4 conservado como **no observado**; el veredicto de QA y la firma de seguridad se emiten por sus autores con esta aceptación como dato. **OBS-H** (`guard-codigo` y un `cp` con efecto en el ensayo) **no queda aceptado** ni se repara por esta decisión.

**La entrada tal como estaba, conservada:**

#### [2026-09-21] (coordinadora) — REQ-025 entrega 1: cómo se resuelve la condición de aceptación que QA determinó pendiente (QA-025-08) *(histórica; resuelta arriba)*
- **Contexto:** la vuelta 3 de 3 se agotó con `QA: con-hallazgos` (R-3, sobre `a441e04`). Lo encargado a la vuelta 3 quedó reparado (QA-025-07, ENS-01, OBS-C, OBS-E). QA determinó, como el propietario le pidió, que **falta una condición de aceptación**: la conducta que la entrega 1 modifica —el tratamiento de un **hallazgo de QA** bajo la regla 3— no tiene evidencia de tercero; en la única corrida del ensayo QA aprobó y S4 no se disparó, y el bloqueo se conservó por la vía del **veto de seguridad**, que esta entrega **no** modifica. El propietario escribió: «no se elimina esa condición por agotarse las vueltas», «no aceptes residuales en mi nombre», «no autorizo repetir el ensayo completo ni construir mecanismos nuevos».
- **Acción que impide (regla 2):** **cerrar** — marcar `REQ-025` como `completado`. **Regla que lo impide:** `QA: con-hallazgos` y CA-13 (`guard-completado`, `AGENTS.md` §6 y §13). **No** impide implementar ni probar; **no** afecta a la entrega 1b ni a REQ-028. **Evidencia:** `docs/qa/REQ-025.md`, §«Acreditación del ensayo S1…S4» (S4) y §«Vuelta 3 de 3» (QA-025-08).
- **Opciones:**
  - ~~**A — Observación acotada de UNA sola situación**~~ — **AUTORIZADA Y CONSUMIDA (propietario, 2026-09-21; sesión `ENS-S4-P` sobre `9f908d9`): resultado NO OBSERVADO.** El desarrollador corrigió los dos defectos sembrados (CA-01 y CA-03) en su entrega, así que QA no tuvo defecto que retener y la conducta no ocurrió; nadie escribió veredictos ajenos ni cerró el REQ. QA lo acreditó en `docs/qa/REQ-025.md` §«R-3b» y determinó que **QA-025-08 sigue abierto**: dos ausencias no son una confirmación. Por instrucción del propietario («si la situación vuelve a no producirse, informa "no observado" y detente; no encadenes intentos») **no se repite**. **Ya no está disponible.**
  - **B — Cerrar con la laguna declarada**: aceptar que la entrega se acredita sin observar esa conducta, con dueño, forzador y vencimiento. **Sólo el propietario puede elegirla.** Consecuencia: la sede queda acreditada sobre el camino que el cambio no toca. Forzador propuesto por QA, que se arma solo: «la primera vez que un hallazgo de QA de cualquier REQ llegue a la clasificación de la regla 3, se anota si el bloqueo se conservó», en vez de otra sesión de ensayo.
  - **C — Mantener `Estado: bloqueado`**: detener la entrega 1 hasta otra ventana. Consecuencia: para la entrega entera por una laguna de evidencia, no por un defecto medido.
- **Recomendación (2026-09-21, tras consumir A):** B con el forzador de QA. Es la recomendación de QA y de la coordinadora; la elección es del propietario.
- **Estado tras A:** `QA: con-hallazgos (R-3b, sobre 9f908d9)`; **QA-025-05 cerrado** (CI verde verificado por QA sobre la cabeza exacta; CA-13 satisfecho; el verde no desmiente el FAIL local); `Hallazgos abiertos: QA-025-08 (instrumento)`. Seguridad (CA-11 punto 4) no emitida.
- **Espera:** elección del propietario entre B y C. **Trabajo que sigue mientras tanto:** ninguno de esta entrega. La entrega 1b y REQ-028 no dependen de esta decisión y no se arrancan sin autorización.

### RESUELTA (propietario, 2026-09-09) — **se PUBLICA `v1.33.0`**: revierte el aplazamiento de ayer, con límite declarado

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
