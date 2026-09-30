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

## Pendientes

### [2026-09-27, puesta al día 2026-09-29] (coordinadora) — Decisión de publicación de 1.35.0: SEC-115/SEC-118 y hueco C, pendientes; SEC-117 en reparación autorizada (ficha 3 resuelta); decisiones 4 y 5 resueltas

- **Contexto:** el 2026-09-29 el propietario autorizó implementar SEC-047 (mitad 1 de REQ-023) y preparar el candidato v1.35.0 (§ Resueltas, entrada de esa fecha, texto literal). **Esa autorización NO acepta el aplazamiento de SEC-115 ni del hueco C**: los dos siguen pendientes aquí, con sus fichas finales abajo. El antiguo asunto 3 (SEC-047 y la celda de §13) queda resuelto por esa autorización; los asuntos 1 y 2 de la redacción del 2026-09-28 se sustituyen por las fichas, sin perder nada de lo que decían.
- **Acción que impide (regla 2):** **publicar** 1.35.0 —tag, publicación, actualización de la instalación estable— hasta que el propietario decida las fichas 1, 2 y 4 y la decisión 7, y se complete la reparación de SEC-117 (ficha 3 y decisiones 4, 5 y 6 resueltas); y, mientras esta entrada esté aquí, **cerrar**: marcar **cualquier** REQ `completado` (`guard-completado`; deliberado). **No** impide **implementar** ni **probar** el candidato. **Parte afectada:** la publicación de 1.35.0 y el cierre de REQ-023 y REQ-031. **Evidencia:** la de cada ficha. **Qué lo resuelve:** la decisión del propietario sobre cada ficha.

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

**Ficha 4 — QA-023-07 (`instrumento`, severidad alta, PREEXISTENTE; NO aceptado; añadida el 2026-09-30, escalada por QA como urgencia de seguridad).** Una ruta con segmentos `..` que entra en `requirements/` o en el código protegido desde un directorio libre no la juzga ninguna puerta.
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

**Decisión 7 — O-11 (QA, 2026-09-30): la vía del archivo ilegible (NUL en disco, SEC-002) queda fuera de CA-13.** Con NUL en el disco, una edición no reconstruible que no escribe la palabra del estado terminal recibe permiso, y CA-13 (iv) lo excluye con la causa que da la tercera autorización («porque no encuentra literalmente el texto anterior»). Pero tu cuarta autorización reformula la propiedad **sin esa causa** («una edición sobre un REQ protegido que el hook no puede reconstruir no puede recibir permiso silencioso»).
- **Pregunta:** ¿la vía del archivo ilegible entra en la propiedad?
- **Opciones:**
  - **(A)** No: se queda como está, declarada en CA-13 (iv), con SEC-002 como sede. La **consecuencia** es un residuo estrecho: requiere un NUL ya escrito en el REQ.
  - **(B)** Sí: se repara en ciclo propio (denegar toda edición de un REQ ilegible), fuera de esta vuelta.
- **Recomendación de la coordinadora:** (B) como trabajo siguiente, fuera de esta vuelta, y declararlo mientras tanto. Es la misma clase de defecto, pero su causa, el disco ilegible, es distinta de la que reparó esta vuelta.
- **Valoración de seguridad** (R-045-A): **(B)**. La propiedad de la cuarta autorización lo alcanza de lleno. Tiene un productor natural conocido: PowerShell 5.1 escribiendo en UTF-16LE. El remedio es denegar todo `Edit`/`MultiEdit` de un REQ que no se puede leer entero, dejando `Write` como salida. Si se elige (A), la cláusula de §13 tiene que llevar escrita la excepción antes de publicar.
- **Qué sigue mientras tanto:** la determinación de seguridad.

**Registrado, no bloquea: QA-023-08** (`contrato`, baja, preexistente, contra REQ-007 CA-46 (b), que está `en-progreso`). El criterio dice que con NUL en disco decide «la transición», y la puerta decide si la edición menciona el estado terminal. Además, la nota de versionado del 2026-09-30 repitió «(b) sigue igual». Responsable: `analista-requerimientos` (write-back). No impide REQ-023, REQ-031 ni REQ-001, y REQ-007 ya no cerraba por otros hallazgos.

- **Recomendación de la coordinadora (propuesta, no decisión):**
  - **SEC-115 y C:** aplazarlos con esas fechas y publicar sus limitaciones en las notas de 1.35.0. SEC-115 tiene realismo bajo y un margen medido de más de 30× sobre los REQ reales; C no tiene reparación que quepa en esta versión sin ser otra versión.
  - **QA-023-02 / SEC-117:** es de severidad crítica y de realismo no bajo, pero preexistente y ajeno al alcance de 1.35.0. **El auditor (R-045 §3) recomienda lo mismo que la coordinadora:** publicarlo declarado y abrir su REQ de reparación de inmediato, como parche propio, con revisión el 2026-10-06. Motivo: el defecto ya está en 1.33.2 y en `v1.34.0`, que son las versiones instaladas, así que retener 1.35.0 no protege a nadie y deja vivo el bypass por variante que 1.35.0 cierra dentro de su frontera.
    - **Condiciones del auditor:** notas correctas y ficha 1 corregida (ya hecho aquí). Además, conviene ejecutar el lado del CLI en una sesión real antes de reparar.
    - **REQ-001:** el auditor recomienda añadir `SEC-117 (instrumento)` a su `Hallazgos abiertos:` sin tocar su `Estado:`. REQ-001 se reabriría por §9 cuando el REQ de reparación versione CA-10/CA-11. QA pide que tu decisión sobre esta ficha lo resuelva de forma expresa. **Registrarlas aquí no las convierte en riesgos aceptados.**
- **Espera:** decisión del propietario sobre las fichas 1 (SEC-115/SEC-118), 2 (C) y **4 (QA-023-07)**, y sobre la **decisión 7 (O-11)**. La reparación de SEC-117 tiene QA favorable y está en la determinación de seguridad. La ficha 3 y la decisión 5 se resolvieron en la tercera autorización del 2026-09-29. La decisión 4 está resuelta y su corrección se hizo (`e7562e7`), con QA-023-05 cerrado; la determinación de seguridad no se ha emitido porque QA no fue favorable. **Trabajo que sigue mientras tanto:** el candidato v1.35.0 —SEC-047 (mitad 1 de REQ-023) y la preparación de la versión—, autorizado el 2026-09-29; no depende de estas dos decisiones. **Cerrar REQ-023 y REQ-031 queda pendiente** mientras esta entrada esté aquí.

## Resueltas

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
