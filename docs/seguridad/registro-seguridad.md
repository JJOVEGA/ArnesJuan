# Registro de seguridad — ArnesJuan

> **Bitácora viva** del `auditor-seguridad`. Un registro por hallazgo, con severidad,
> estado de mitigación (`abierto` / `en-mitigación` / `mitigado` / `aceptado`), recomendación
> y REQ relacionado. **Los hallazgos cerrados no se borran: cambian de estado.**
> Al final, el **estado de seguridad aprobado de cada REQ**, que es contra lo que se compara
> la auditoría siguiente para detectar regresiones.

Clases de hallazgo (`requirements/README.md`): `usuario/dinero` y `contrato` **bloquean** el
cierre; `instrumento` —defecto del propio arnés— **no bloquea**, va a deuda técnica con dueño.

---

## Revisión R-001 — REQ-001, candidata 1.30.3 (2026-09-05)

**Alcance.** Los dos bypass de v1.30.2 y todo lo que el bucle dev↔QA de tres vueltas añadió:
`hooks/lib.sh`, `hooks/guard-codigo.sh`, `hooks/guard-completado.sh`,
`tests/escenarios/hooks/run.sh`, `skills/arnes-upgrade/SKILL.md`, `CHANGELOG.md` y
`requirements/`. Diff completo `origin/main..HEAD` más los cambios sin comitear.
Guardián de la sesión: instalación estable **v1.30.2**. Plataforma: Linux (WSL2).
Orden respetado: `QA: aprobado` firmado antes de esta auditoría (`AGENTS.md` §6).

**Método.** Sondas propias contra `hooks/guard.sh`, con **canario positivo y negativo antes de
cada tanda** —el hook permite con **salida vacía**, así que toda sonda evalúa
`[ -z "$out" ] && dec=allow` antes de interpretar nada—, `timeout 30` por invocación, y
`TIMEOUT` reportado aparte y **nunca** como `allow`. Cada sonda se corrió contra la candidata
**y** contra v1.30.2, para separar regresión de defecto heredado. Ninguna sonda se ejecutó
contra un entorno de terceros.

**Canario (medido al empezar).** Escritura en código protegido por la coordinadora → `deny` en
las dos versiones; la misma por `desarrollador` → `allow`; `ls -la` → `allow`; `Edit` que cierra
un REQ con `QA: pendiente` → `deny` en la candidata y **`allow` en v1.30.2** (el fail-before de
CA-01, reproducido por el auditor). La sonda distingue las cuatro cosas.

**Veredicto: `Seguridad: aprobado`.** No hay hallazgo de clase `usuario/dinero` ni `contrato`.
Los siete hallazgos técnicos de esta revisión son `instrumento`, están **medidos idénticos en
v1.30.2** —ninguno es regresión de este cambio— y su trabajo va a **REQ-007**.

---

## Hallazgos

### SEC-001 — Un byte de control `U+0001` en `new_string` / `content` desincroniza la puerta de cierre

- **Severidad:** alta · **Clase:** `instrumento` · **Estado:** `abierto` · **REQ:** REQ-001 (medido) → trabajo en **REQ-007**
- **Ubicación:** `hooks/guard-completado.sh:106-116` — las piezas del `tool_input` se empaquetan
  con `jq … | join("")` y se desempaquetan con `IFS=$'\001' read -r -d '' -a piezas`.
- **Descripción.** El separador es el byte `\001`, elegido porque «ningún Markdown lo lleva».
  Pero viaja **dentro del dato que controla quien llama**: si un `new_string` (o el `content` de
  un `Write`) contiene ese byte, el troceado produce campos de más y el bucle
  `for ((k = 1; k + 2 < np; k += 3))` lee como tripletas `(old, new, replace_all)` cosas que no
  lo son. El documento que el hook simula deja de ser el que la herramienta va a escribir.
- **Medido (2026-09-05).** REQ en disco con `Estado: en-revisión` / `QA: pendiente`:
  - `MultiEdit` honesto de dos ediciones que cierra el REQ → **deny** en candidata y en v1.30.2 (control).
  - El **mismo** `MultiEdit` con un `\001` insertado en el `new_string` de la primera edición →
    **allow** en candidata **y** en v1.30.2, mientras el documento resultante queda
    `Estado: completado` con `QA: pendiente`.
  - `Write` con el documento ya cerrado precedido de `nota` + `\001` → **allow** en las dos
    versiones, contra el **deny** del mismo `Write` sin el byte.
- **Riesgo.** Cierre de un REQ con la validación y la auditoría pendientes, con la cola de
  aprobaciones abierta y con un hallazgo `usuario/dinero` declarado: las cuatro puertas del
  cierre se saltan a la vez, con **un byte**.
- **Recomendación.** No usar un separador en banda. Pasar las piezas como **JSON** y leerlas una
  a una, o —si el coste de forks lo impide— **rechazar** el `tool_input` que contenga bytes de
  control C0 distintos de tabulador y salto de línea, denegando con motivo propio: un REQ
  legítimo no los lleva y la dirección segura es cerrar. Debe quedar como criterio en REQ-007
  antes de darse por cerrado (`AGENTS.md` §9).

### SEC-002 — Un byte NUL en el REQ ciega la puerta de cierre entera

- **Severidad:** alta · **Clase:** `instrumento` · **Estado:** `abierto` · **REQ:** REQ-001 (medido) → **REQ-007**
- **Ubicación:** `hooks/guard-completado.sh:118` — `IFS= read -r -d '' disk < "$fp"`.
- **Descripción.** El documento en disco se lee con NUL como delimitador, así que **un NUL en el
  archivo trunca `disk` ahí mismo**. Con `disk` truncado: (a) los veredictos se leen de un texto
  incompleto y salen **vacíos**, y un campo vacío no dispara ninguna exigencia; (b) el
  `old_string` deja de encontrarse, la reconstrucción se marca fallida y la puerta cae a la vía
  **más laxa**, la del fragmento, que sólo mira si el fragmento escribe literalmente
  `Estado: completado`.
- **Medido.** REQ con un NUL en la primera línea + `Edit` con `old_string: en-revisión` /
  `new_string: completado` → **allow** en candidata y en v1.30.2. El mismo REQ sin el NUL →
  **deny** en la candidata.
- **Riesgo.** Es la respuesta medida a «¿puede forzarse la reconstrucción a fallar para caer en
  la vía laxa?»: **sí**, y basta una escritura previa en `requirements/`, que ninguna puerta
  restringe.
- **Recomendación.** Leer el archivo con una forma que no se detenga en el NUL o —más simple y
  en la dirección segura— **denegar** cuando el REQ contenga un NUL, con motivo propio.
  Criterio en REQ-007.

### SEC-003 — Una barra duplicada en la ruta desactiva **las dos** puertas

- **Severidad:** alta · **Clase:** `instrumento` · **Estado:** `abierto` · **REQ:** REQ-001 (medido) → **REQ-007**
- **Ubicación:** `hooks/lib.sh:223-235` (`arnes_ruta_relativa`, recorte del prefijo con
  `p="${p#"$pp"/}"`) y `hooks/lib.sh:198-216` (`arnes_norm_path`, que normaliza barras
  invertidas y unidades de Windows pero **no colapsa las barras repetidas**).
- **Descripción.** El recorte del prefijo del proyecto es textual. Una ruta con una barra de más
  justo después de la raíz no empieza por `<raíz>/`, así que el prefijo no se recorta y la ruta
  relativa queda con una `/` inicial: ningún glob de `codigo_app.globs` casa y ninguna ruta cae
  dentro de `requirements/`.
- **Medido.** Con `codigo_app.globs: ["src/*"]` y la sesión coordinadora:
  - `Write` a `<raíz>/src/a.ts` → **deny**; a `<raíz>//src//a.ts` → **allow** (candidata y v1.30.2).
  - `Edit` que cierra un REQ en `<raíz>/requirements/REQ.md` → **deny**; en
    `<raíz>//requirements//REQ.md` → **allow** (candidata y v1.30.2).
  - Controles que **sí** se resuelven bien: `<raíz>/./src/../src/a.ts` → deny;
    `<raíz>/src/./a.ts` → deny; `src/a.ts` y `./src/a.ts` → deny.
- **Riesgo.** Es la evasión más barata de todas las medidas: **un carácter**, sin ninguna forma
  exótica. Alcanza al guardián de identidad y al de cierre a la vez.
- **Recomendación.** Colapsar las barras repetidas en `arnes_norm_path` —sin procesos, con
  expansión de parámetros— antes de recortar el prefijo. Criterio en REQ-007, con su control
  para que la forma UNC de Windows (`//servidor/recurso`) no se rompa.

### SEC-004 — Un enlace simbólico dentro del proyecto salta las dos puertas

- **Severidad:** media · **Clase:** `instrumento` · **Estado:** `abierto` · **REQ:** → **REQ-007**
- **Descripción.** Los guardianes juzgan la **ruta escrita**, no su destino real. Un enlace
  simbólico en una ruta no protegida que apunte a código protegido o a un REQ recibe el
  veredicto de la ruta del enlace.
- **Medido.** `docs/enlace.md` → `requirements/REQ-….md`; `Edit` sobre el enlace que cierra el
  REQ → **allow** en candidata y en v1.30.2.
- **Recomendación.** Resolver el enlace antes de clasificar —`arnes_dir_interno` ya existe para
  una pregunta parecida en las rutas del manifiesto— o declararlo como límite escrito. Lo que no
  puede quedar es sin decidir. Criterio en REQ-007.

### SEC-005 — Un manifiesto **inválido** deja el enforcement inactivo **en silencio**

- **Severidad:** media-alta · **Clase:** `instrumento` · **Estado:** `abierto` · **REQ:** → **REQ-007**
- **Ubicación:** `hooks/lib.sh:52-76` (`arnes_parse_manifest`) y `hooks/lib.sh:150-156`
  (`arnes_jq_file`, que devuelve el código de error de `jq` **y nadie lo mira**).
- **Descripción.** `AGENTS.md` §13 declara dos modos degradados: **sin `jq`** → inerte *con
  aviso*; **sin manifiesto** → inerte. No declara el tercero, que es el que ocurre de verdad
  cuando alguien rompe un JSON: **manifiesto presente pero inválido, vacío, `null` o de tipo
  equivocado** → todas las puertas permiten, sin ningún aviso del arnés. Y con JSON inválido
  `ARNES_JQ` conserva el valor de la lectura **anterior** (la del input del hook), así que las
  variables del manifiesto se rellenan con campos del input: medido,
  `ARNES_AGENTE_CODIGO=Bash`, `requirements_dir` vacío, `globs` vacío.
- **Medido.** Con el canario de escritura en código protegido por la coordinadora:
  manifiesto válido → **deny**; JSON inválido → **allow** (sólo el error crudo de `jq` en
  stderr); vacío → **allow** sin ningún mensaje; `null` → **allow** sin mensaje;
  array → **allow**. Idéntico en v1.30.2. Sin `jq` → inerte **con** el aviso declarado
  (correcto). Sin manifiesto → inerte (correcto, declarado).
- **Riesgo.** El enforcement de un proyecto entero se apaga con una coma de más, y la única
  señal es una línea de `jq` en stderr —o ninguna—. Un guardián que se apaga sin decirlo es peor
  que uno ausente: se sigue confiando en él.
- **Recomendación.** Comprobar el código de salida de `arnes_jq_file` / `arnes_jq_str` en
  `arnes_parse_manifest` y, si falla o el resultado no tiene la forma esperada, emitir
  `arnes_warn` **siempre** y —decisión de alcance del propietario— **denegar** en las rutas
  protegidas en vez de permitir. Criterio y NFR en REQ-007.

### SEC-006 — El manifiesto que define la frontera queda **fuera** de la frontera

- **Severidad:** media · **Clase:** `instrumento` · **Estado:** `abierto` · **REQ:** configuración de este repositorio → **REQ-007**
- **Ubicación:** `.arnes/config.json` de este repositorio,
  `codigo_app.globs: ["hooks/*", "tools/*", ".github/*"]`.
- **Descripción.** El manifiesto es la **fuente de verdad ejecutable** de las invariantes: quién
  es el agente de código, qué rutas protege, qué quality gates corren, cuál es el estado
  terminal y —desde 1.30.3— cuál es el techo de análisis de Bash. **No está en sus propios
  globs**, ni tampoco `.claude-plugin/plugin.json` ni `marketplace.json`. Cualquier agente puede
  editarlo, y con ello desactivar el enforcement del propio repositorio. El código lo reconoce
  por escrito en el comentario de `arnes_ruta_interna` («el manifiesto … también lo puede
  escribir un agente, y no está protegido por `guard-codigo`»); lo que falta es la consecuencia.
- **Vector concreto medido, encadenado con el presupuesto nuevo.** `limites.bash_max_analisis`
  **sólo puede subir** el techo, y sube **sin tope**: medido, con `4294967296` y con
  `99999999999999999999` un comando de 70 KB deja de denegarse por presupuesto y pasa a
  analizarse. Como el coste del análisis crece con el tamaño y un hook `PreToolUse` **muere a
  los 60 s permitiendo**, subir el techo desde el manifiesto reabre **por configuración** justo
  el fallo en abierto que CA-53 cerró. Controles que **sí** funcionan, medidos: valor `100` (más
  bajo que el defecto) → sigue denegando; `-5` → cae al defecto; `0` → cae al defecto.
  Tolerancia observada: un valor **numérico entre comillas** (`"999999"`) **sí** se acepta, pese
  a que CA-53 dice «un valor no numérico … cae al valor por defecto»; sólo sube el techo, así que
  no abre nada por sí solo, pero conviene decidirlo por escrito.
- **Riesgo.** Escalada de privilegios dentro del arnés: quien no puede escribir `hooks/` sí puede
  cambiar la regla que dice qué es `hooks/`. `AGENTS.md` §6 exige aprobación humana para cambiar
  el manifiesto, pero eso es **política, no enforcement**.
- **Recomendación.** Añadir `.arnes/config.json` y `.claude-plugin/*` a `codigo_app.globs` de
  **este** repositorio (es mapeo, no mecanismo: no se propaga a las plantillas), y acotar
  `limites.bash_max_analisis` con un **máximo** además del mínimo. Debe entrar como NFR por el
  `analista-requerimientos`.

### SEC-007 — El presupuesto fail-closed cubre Bash, **no** la reconstrucción del documento

- **Severidad:** media · **Clase:** `instrumento` · **Estado:** `abierto` · **REQ:** → **REQ-007**
- **Ubicación:** `hooks/guard-completado.sh:137-156` (bucle de reconstrucción) frente a
  `hooks/lib.sh:364` (`ARNES_BASH_MAX_ANALISIS`, que sólo se aplica en `arnes_bash_escrituras`).
- **Descripción.** CA-53 introdujo un techo fail-closed porque «una puerta que no puede medir no
  deja pasar» y porque un hook muerto no deniega. Ese techo vive **sólo** en el detector de Bash.
  La vía `Edit` / `MultiEdit` reconstruye el documento aplicando cada edición sobre una copia
  completa del texto: coste del orden de *ediciones × tamaño*, **sin techo**.
- **Medido**, REQ dentro de la población declarada (~300 KB), con la última edición cerrando el REQ:

  | Ediciones | Candidata | v1.30.2 |
  |---|---|---|
  | 101 | deny, 2,2 s | deny, 2,4 s |
  | 401 | deny, **8,0 s** | deny, 7,9 s |
  | 1.501 | deny, **25,7 s** | deny, 25,4 s |

  Y con un REQ de 3,1 MB (fuera de la población declarada) + 401 ediciones: **sin respuesta a los
  30 s**. Las cifras son **iguales en las dos versiones**: defecto heredado, no regresión de
  REQ-001, y por eso no bloquea.
- **Riesgo.** Por encima de los 60 s el hook muere, `guard.sh` no emite nada y **el resultado
  efectivo es permitir**: exactamente la familia de QA-007, en otro camino.
- **Recomendación.** Extender el principio de CA-53 a la reconstrucción: presupuesto sobre
  *tamaño del documento × número de ediciones*, con **deny sin reconstruir** por encima y motivo
  propio. NFR en REQ-007.

### SEC-008 — Identidad operativa nombrada en un repositorio público

- **Severidad:** informativa · **Clase:** `instrumento` · **Estado:** `abierto` (decisión del propietario)
- **Descripción.** `AGENTS.md` §2 y §4, añadidos en esta rama, nombran las dos cuentas de GitHub
  y su reparto de permisos. Es información del propietario sobre su propio repositorio y no hay
  ningún secreto; pero describe **qué cuenta puede cambiar el ruleset**, que es justo la que
  interesa a quien quisiera atacar la cadena. Se registra para que la publicación sea una
  decisión y no un descuido.
- **Recomendación.** Confirmar que es intencional. Si lo es, pasa a `aceptado` con esa nota. Si
  no, sustituir los nombres por los **roles** («cuenta de push sin administración» / «cuenta
  propietaria»), que es lo único que el documento necesita decir.

---

## Limitaciones conocidas del detector de escrituras por Bash

> Este bloque es el que `requirements/REQ-001.md` («Fuera de alcance») promete que quede
> **escrito en `docs/seguridad/`**. Mientras esta sección no existió, esa frase describía una
> obligación pendiente del `auditor-seguridad` y no un hecho; desde 2026-09-05 es un hecho.
> Todas las conductas de abajo están **medidas** en la candidata 1.30.3 **y** en v1.30.2, y
> ninguna es regresión de REQ-001. Son **límites declarados**, no defectos ocultos:
> `AGENTS.md` §13, «es una barandilla, no una jaula».

| # | Límite | Conducta medida | Origen |
|---|---|---|---|
| **LIM-01** | Una sustitución `$( … )` que **abre en una línea y cierra en otra** dentro de un heredoc sin citar. La profundidad de paréntesis se calcula **por línea**: lo que no cierra en su línea aporta sólo el resto de su línea | `deny` cuando la escritura cae en la misma línea (CA-54 (iii), fail-closed); **no se ve** cuando cae en una línea posterior | REQ-001 «Fuera de alcance» · REQ-007 |
| **LIM-02** | Los **acentos graves** no interpretan ni el anidamiento ni el escapado, y **emparejan cruzando líneas**. Consecuencia concreta: una valla de Markdown (tres acentos) dentro de un heredoc sin citar es, para bash, una sustitución real, y el detector no la ve | `allow` en las dos versiones | **QA-011** · REQ-007 |
| **LIM-03** | Un `<<PALABRA` escrito **dentro de una cadena entrecomillada del comando real** abre un heredoc **para el detector** y ciega todo lo que sigue | `allow` en las dos versiones | **QA-012** · REQ-007 |
| **LIM-04** | **Todo lo entrecomillado se descuenta antes de analizar**: un destino entre comillas (`echo x > "src/a.ts"`) y una sustitución entera dentro de comillas dobles (`echo "$(echo x > src/a.ts)"`) no se ven | `allow` en las dos versiones, re-medido por el auditor | **QA-006** · REQ-007 |
| **LIM-05** | **Intérpretes y programas que escriben por su cuenta**: `node x.mjs`, `python x.py`, scripts, formateadores (`prettier --write`, `eslint --fix`), `patch`, `git apply`. La ruta vive **dentro** del archivo y el detector sólo lee el texto del comando | fuera de cobertura por diseño | `AGENTS.md` §13 |
| **LIM-06** | **`eval` y `bash -c`**: la escritura viaja como cadena y se descuenta con el resto de lo entrecomillado. Confirmado como límite, no como defecto nuevo | `eval "echo x > src/a.ts"` → `allow`; `bash -c "echo x > src/a.ts"` → `allow`; en las **dos** versiones | `AGENTS.md` §13, re-medido 2026-09-05 |
| **LIM-07** | La cobertura de `Bash` es **parcial a propósito**. Lo cubierto: redirección `>` / `>>`, `tee`, `cp` / `mv` / `install`, `sed -i` / `perl -i`, `dd of=`. Perseguir shell arbitrario produce falsos positivos, y un guard apagado protege menos que uno parcial | — | `AGENTS.md` §13 |
| **LIM-08** | **El deny por presupuesto de `guard-completado` alcanza también al agente de código.** La regla de ese guardián —nadie cierra un REQ desde la shell— alcanza a todos, y sin análisis no se puede saber si el comando toca `requirements/`. En `guard-codigo`, en cambio, el `desarrollador` sigue en `allow` | verificado: comando de 70 KB por `desarrollador` → `allow` en `guard-codigo`, `deny` por presupuesto en `guard-completado` | CA-53 |
| **LIM-09** | Un comando **legítimo** por encima del presupuesto de 65.536 bytes se **deniega** aunque no escriba nada protegido. Es el precio del fail-closed, y se paga a sabiendas: la alternativa medida es que el hook muera a los 60 s y **permita** | `deny` con motivo propio, que **no nombra ninguna ruta** y sí imprime el techo vigente en bytes | CA-53 |

**Formas que se comprobaron y NO son huecos** (medidas por el auditor, para que no se vuelvan a
buscar): delimitadores de heredoc exóticos con comillas partidas, con variable, con barra
invertida interna y con inicial numérica → **deny** en las dos versiones (el detector falla
cerrado ante lo que no reconoce como palabra); ANSI-C quoting (`$'…'`) → `allow`, y es
**correcto**, porque bash tampoco sustituye ahí; sustitución dentro de un comentario `#` →
`deny` (sobredetección, dirección segura); `>( )` y `<( )` → `deny`; `printf … > ruta` →
`deny`; `agent_type` sin `agent_id` → `deny`; `agent_id` con `agent_type` vacío → `deny`;
`desarrollador2` → `deny`; prefijo del plugin (`arnes-juan:desarrollador`) → `allow`, tolerancia
declarada; `Edit` con `old_string` vacío → juzgado por el fragmento, `deny` si el fragmento
cierra; `MultiEdit` con ediciones que se solapan → el hook las aplica **en el mismo orden que la
herramienta** y coincide con ella (cerrar y reabrir en la misma llamada → `allow`, que es el
resultado real); ruta con salto de línea al final → `deny` en la candidata (v1.30.2 permitía:
mejora no declarada, dirección segura).

---

## Estado de seguridad aprobado por REQ

> Contra esta tabla se compara la auditoría siguiente. Si un control que aquí figura como
> presente y aprobado desaparece o queda más débil en una iteración posterior, **es hallazgo**,
> aunque el REQ «funcione» y aunque las quality gates pasen (regresión de seguridad entre
> iteraciones).

| REQ | Veredicto | Fecha | Versión | Controles que quedan acreditados |
|---|---|---|---|---|
| **REQ-001** | `aprobado` | 2026-09-05 | candidata 1.30.3 sobre `6cb348a` + cambios sin comitear | (1) La transición a estado terminal se juzga por la **cabecera del documento resultante**, nunca por el fragmento, en `Edit`, `MultiEdit`, `replace_all` y `Write`. (2) El fragmento queda **sólo** como respaldo cuando la reconstrucción es imposible. (3) El cuerpo de un heredoc **sin citar** se analiza en sus expansiones y acentos graves; **citado o escapado** se descuenta entero. (4) El fragmento de una sustitución se delimita por **profundidad de paréntesis** sobre el texto desentrecomillado, nunca en el primer paréntesis de cierre; si no cierra en su línea, se analiza el resto de la línea. (5) La **paridad** de barras invertidas decide si la sustitución está escapada; con dos barras **se deniega**. (6) **Presupuesto fail-closed** de 65.536 bytes sobre el texto analizable de Bash: por encima, **deny sin analizar**, con el techo vigente **en bytes** en el motivo y sin nombrar ninguna ruta. (7) El techo del manifiesto **sólo sube**; ausente, `0`, negativo o no numérico cae al valor del código. (8) `guard-completado` **deriva** a `Edit` / `Write` la transición intentada por shell. (9) Seguridad no firma sobre un árbol sin `QA: aprobado`, salvo `Seguridad: preventiva`. (10) Los campos valen **sólo** en la cabecera. |

### Verificaciones de gobernanza de R-001, con su resultado

Todas re-hechas por el auditor; ninguna tomada del informe de QA.

| Verificación | Resultado |
|---|---|
| **CA-36 — enumeración cerrada de `deny → allow`.** Banco completo (310 casos) contra la candidata y contra `ARNES_HOOKS_DIR=…/1.30.2/hooks` | **Cumple.** Candidata: 309 PASS / 0 FAIL / 1 SKIP. v1.30.2: 255 / 54 / 1. De los 54 FAIL, **exactamente 2** son `esperado=allow got=deny` —«Write que sólo CITA el estado en el cuerpo» (CA-51) y «Write sobre un REQ que EN DISCO ya estaba terminal» (CA-45)—, los **dos declarados**; 43 son `esperado=deny got=allow` (cobertura ganada, dirección segura) y 9 son comprobaciones de motivo o de tiempo. **Ningún `deny → allow` no declarado** |
| **El diff no debilita el mecanismo** | **Cumple.** `hooks/hooks.json`, `.github/workflows/` y `.githooks/pre-commit` **no aparecen** en el diff sin comitear ni se modifican respecto de lo declarado. Las quality gates del manifiesto no cambian. Los hooks sólo ganan condiciones |
| **Ruleset `proteger-main`** (CA-35, leído con `gh api`, no por anuncio) | **Cumple.** `enforcement: active` sobre `~DEFAULT_BRANCH`; reglas `deletion`, `non_fast_forward`, `pull_request` y `required_status_checks` con `strict_required_status_checks_policy: true` y `hooks-en-linux` como check requerido. **Nota:** `required_approving_review_count: 0` — el gate humano de fusión es política de `AGENTS.md`, no restricción de la plataforma (ver `gobernanza-datos.md` §6) |
| **Repositorio público: sin datos de cliente** | **Cumple.** Revisadas ~5.900 líneas añadidas (diff comiteado + sin comitear + `REQ-007`, `REQ-008` y `docs/qa/REQ-001.md`): ningún nombre de proyecto, identificador de REQ ajeno ni dato de terceros. Las menciones a «cliente» son la **regla** de no publicarlos |
| **Sin secretos en lo añadido** | **Cumple.** Ningún patrón de credencial. `.gitignore` cubre `.mcp.json`, `.claude/settings.local.json`, la memoria de trabajo, `insumos/` y `mejoras-arnes-*.md` |
| **Nada del autoalojamiento se filtra a lo que heredan los proyectos** | **Cumple.** De `templates/`, `agents/`, `playbooks/` y `skills/`, el diff toca **un solo archivo**: `skills/arnes-upgrade/SKILL.md`, y sólo con la **documentación de conducta** de 1.30.1, 1.30.2 y 1.30.3 —qué cambia de veredicto y qué hay que avisar—. Ni roles, ni globs, ni la política de autoalojamiento |
| **Modos degradados** (CA-41) | **Cumple en lo declarado, con el hueco de SEC-005.** Sin `jq` → inerte **con aviso**. Sin manifiesto → inerte. Manifiesto **inválido** → permite en silencio: no está declarado, y es SEC-005 |
| **Coste del camino común** (CA-39) | **Cumple.** `ls -la` → 124 ms; canario de deny → 132 ms; REQ de 348 KB con `Edit` de un solo valor → 337 ms |
| **Versión** | `.claude-plugin/plugin.json` y `marketplace.json` declaran **1.30.3**. **Anotación:** `.arnes/config.json` de este repo declara `arnes_version: "1.30.2"`, que es correcto **hoy** —el guardián de la sesión es la estable— y debe subir a 1.30.3 al actualizar la instalación estable (CA-44), no antes |

### Pendientes que esta firma NO cubre

Son de la coordinadora y del propietario: **CA-32** (el check `hooks-en-linux` en verde en el
PR), **CA-44** (publicación del tag `v1.30.3` y verificación de la instalación estable) y la
cola de `PENDING_APPROVAL.md`. La firma de seguridad acredita la revisión de seguridad, no el
CI ni la publicación.

### Obligación de write-back abierta

`AGENTS.md` §9: **SEC-001 a SEC-007 deben quedar como criterios o NFR en REQ-007** por el
`analista-requerimientos`, en el ciclo de ese REQ. Un hallazgo que vive sólo en este registro es
deriva. Ninguno bloquea el cierre de REQ-001: los siete son `instrumento` y están medidos
idénticos en v1.30.2, así que no son regresiones de este cambio (`AGENTS.md` §6).

---

## Revisión R-002 — ventana 1.31.0 (REQ-002…REQ-007, REQ-009, REQ-010) — 2026-09-06

**Alcance.** `git diff origin/main..HEAD` de `cand/1.31.0-mecanismos` (43 archivos): veredicto
fechado y caduco (apagado), vocabulario único con aviso, rotación de una sección, **`guard-git`
—la única puerta que nace encendida—**, celdas recortadas del bloque derivado, una sola función
para contar la cola, plegado de acentos y forma Unicode, clave del campo decorada, y la frontera
de este repositorio incluyéndose a sí misma. Guardián de la sesión y línea base de no-regresión:
instalación estable **1.30.3** (`6c1b58a`). Plataforma: Linux (WSL2).
Orden respetado: audito un árbol con `QA: aprobado` en los siete REQ que firmo (`AGENTS.md` §6).
**REQ-007 no se firma**: sigue parcial y `en-progreso`.

**Método.** Sondas propias contra `hooks/guard.sh` (el despachador real, no los guardianes
sueltos), con **canario positivo y negativo antes de cada tanda** —`git clean -fd` → DENY,
`ls -la` → ALLOW—, `timeout 30` por sonda y `[ -z "$out" ] && dec=allow` **antes** de parsear
nada, porque el hook permite con salida vacía. Todo git se probó **sólo a través del hook**, en
proyectos desechables bajo el scratchpad; **ninguna orden destructiva se ejecutó** contra este
worktree ni contra ningún entorno de terceros. Banco corrido por el auditor contra la candidata
**y** contra la línea base.

**Error de método propio, anotado para que no se repita:** la primera tanda de sondas de
identidad mandaba `agent_type` **sin** `agent_id` y el arnés la leyó como sesión coordinadora
—`desarrollador` salía DENY sobre su propio código—. Es la conducta declarada en LIM de R-001;
la tanda se repitió con los dos campos y las cifras de abajo son las de la repetición.

**Banco (cifras propias, no tomadas del informe de QA).**

| Corrida | PASS | FAIL | SKIP | Total |
|---|---|---|---|---|
| Candidata `79ff767` | **624** | **0** | 1 | 625 = `CASOS_ESPERADOS` ✔ |
| Línea base 1.30.3 (`ARNES_HOOKS_DIR`) | **468** | **156** | 1 | 625 ✔ |

Coinciden exactamente con las que entregó QA. De los 156 FAIL de la base, **79** son
`esperado=deny got=allow` (cobertura ganada, dirección segura), 76 son comprobaciones de motivo,
de texto o de tiempo, y **exactamente 1** es `esperado=allow got=deny`, es decir la única
transición **`deny → allow` respecto de la versión publicada**: `REQ-007 CA-40 QA-014 '(instrumento,
dueño REQ-007)': la clase es el primer elemento`. Está **declarada** en CA-40 con su control en
CA-41 y su fail-before en CA-42. **Ninguna otra relajación** en 625 casos.

**Veredicto: `Seguridad: con-hallazgos` en REQ-005; `aprobado` en REQ-002, 003, 004, 006, 009 y
010.** Los dos hallazgos que bloquean (SEC-009 y SEC-010) son de clase `contrato` y viven los dos
en `guard-git`. No son regresiones de 1.30.3 —allí la puerta no existía— pero **sí** son
afirmaciones falsas de un REQ sobre lo construido, y la puerta afectada es **la única que se
enciende sola en todos los proyectos que instalen 1.31.0**.

---

### SEC-009 — Construcciones ordinarias del shell atraviesan `guard-git`, la única puerta encendida por defecto

- **Severidad:** alta · **Clase:** `contrato` · **Estado:** `abierto` · **REQ:** REQ-005 (CA-06)
- **Dueño:** `desarrollador` (arreglo barato) + `analista-requerimientos` (declaración del límite)

**Medido** (a través de `guard.sh`, con los dos canarios en la misma tanda, e idéntico para la
sesión coordinadora y para el `desarrollador`):

```
if true; then git clean -fd; fi        ALLOW      git clean -fd            DENY  (canario)
{ git clean -fd; }                     ALLOW      cd sub && git clean -fd  DENY
for i in 1; do git clean -fd; done     ALLOW      sudo git clean -fd       DENY
sleep 0 & git clean -fd                ALLOW      git reset --hard         DENY
nohup git clean -fd                    ALLOW      git stash                DENY
git clean \<salto de línea>  -fd       ALLOW      ls -la                   ALLOW (canario)
G=clean; git $G -f                     ALLOW
```

**Causa** (`hooks/guard-git.sh`, `arnes_guard_git`): la segmentación sustituye por salto de línea
sólo `&&`, `||`, `|`, `;`, `$(`, acento grave, `(` y `)`; el bucle de prefijos sólo tolera
`*=*|sudo|command|exec|time|nice|env|builtin`; y la continuación de línea (`\` + salto) no se
pliega antes de partir. Consecuencia: en `if …; then git clean -fd; fi` el `;` sí parte, pero el
segmento resultante empieza por `then`, que no es `git` ni un prefijo tolerado, así que el
segmento se descarta entero. Con `&` sencillo ni siquiera se parte.

**Por qué es `contrato` y no `instrumento`.** No lo cubre ninguna de las cinco exclusiones que
REQ-005 declara: no es un subcomando fuera de la lista, no es el remoto, **no está entrecomillado
ni escapado** (CA-21.5), no es un script ni un intérprete, y el nombre `git` **sí aparece en el
texto del comando**. Lo que hay es un criterio que afirma lo contrario de lo medido: **CA-06** —«el
subcomando se reconoce **esté donde esté** dentro del comando»— es falso para siete formas
ordinarias. `requirements/README.md` define `instrumento` como «el control o la prueba tienen un
defecto, **sin efecto en el producto**»; aquí el producto **es** la puerta, y la afirmación falsa
es del REQ. Además, no son formas exóticas: `if [ … ]; then git clean -fd; fi` es exactamente como
se escribe una limpieza condicional.

**Recomendación** (cualquiera de las dos cierra el hallazgo; se recomiendan las dos):
1. **Código** — añadir al bucle de prefijos las palabras reservadas y envoltorios que preceden a un
   comando (`then`, `else`, `elif`, `do`, `{`, `!`, `nohup`, `timeout`, `stdbuf`, `xargs` si se
   quiere), tratar el `&` sencillo como separador y **plegar la continuación de línea** antes de
   partir. Cada forma entra con **su** caso en el banco y con su par fail-before contra `79ff767`.
2. **Contrato** — write-back del analista: acotar CA-06 a lo que sostiene y declarar en «Fuera de
   alcance» qué sintaxis del shell no se ve, con las formas medidas.

Mientras una de las dos no aterrice, **REQ-005 no puede cerrar**.

---

### SEC-010 — Un manifiesto ilegible apaga `guard-git` en la práctica, y el aviso que se emite afirma lo contrario

- **Severidad:** alta · **Clase:** `contrato` · **Estado:** `abierto` · **REQ:** REQ-005 (CA-17, CA-22)
- **Dueño:** `desarrollador` + `analista-requerimientos`

**Medido**, en proyectos desechables:

| Manifiesto | `git clean -fd` | Aviso |
|---|---|---|
| JSON roto (`{"agentes":{,}`) | **ALLOW** | sí, el de SEC-005 |
| vacío (0 bytes) | **ALLOW** | sí, el de SEC-005 |
| `[]` (array) | **ALLOW** | sí |
| `{"git":"si"}` (clave del tipo equivocado) | **ALLOW** | sí |
| `{"git":{"activo":true,"prohibidos":"clean -f"}}` (`prohibidos` cadena) | **DENY** | sí, nombra la clave — correcto |
| ausente | ALLOW | — (inerte declarado, CA-22) |
| sano | **DENY** | — (control) |

En `arnes_guard_git`, tras `arnes_parse_manifest` la condición es
`[ "${ARNES_GIT_ACTIVO:-}" = "true" ] || return 0`: con el manifiesto ilegible la variable queda
**vacía** —fail-closed correcto de SEC-005 en las variables— y la puerta **permite**. El aviso que
sí se emite dice, textualmente, *«mientras siga así, toda escritura que las puertas deban juzgar se
DENIEGA»*, y eso es cierto de `guard-codigo`/`guard-completado` y **falso** de `guard-git`.

**Composición que lo agrava** (medida): en un proyecto que use la **plantilla**,
`.arnes/config.json` **no** está en `codigo_app.globs`, así que **cualquier** agente puede
escribirlo. Secuencia completa, medida de punta a punta:

```
1) qa-tester: Write '{roto' -> .arnes/config.json      ALLOW
2) qa-tester: Bash 'git clean -fd'                     ALLOW   (con el manifiesto sano: DENY)
```

Es decir: la puerta que nace encendida tiene un interruptor de apagado alcanzable en **una**
escritura por cualquier agente, y el mismo estado de avería es el que la excepción de reparación
(REQ-007 CA-60) abre a todos. La vía deliberada la cubre «barandilla, no jaula»; **la accidental
no**: un proyecto con una coma de más queda, sin saberlo, con `git clean -fd` permitido justo
cuando toda escritura está denegada y el agente busca «dejar limpio».

**Por qué es `contrato`.** CA-17 declara que `git.activo` vale `true` por defecto y que ésta es «la
única novedad de 1.31.0 **encendida por defecto**»; CA-22 declara inerte **sólo** el caso «sin `jq`
o sin manifiesto». El estado «manifiesto ilegible» no está declarado en ningún criterio de REQ-005
y contradice el principio que el propio arnés escribe en el aviso: *una puerta que no puede medir
no deja pasar*.

**Recomendación:** que `guard-git` **falle cerrado** con su lista por defecto cuando el manifiesto
exista y no se pueda leer (el proyecto que quiera la puerta apagada lo declara con `git.activo:
false`, que es un acto explícito y sigue funcionando), **o** —si se prefiere no denegar en ese
estado— que el criterio lo declare por escrito y que el aviso de SEC-005 deje de afirmar una
cobertura que no tiene. La primera opción es la coherente con el resto del arnés.

---

### SEC-011 — La excepción de reparación del manifiesto no deja rastro, y la avería es invisible en el bloque derivado

- **Severidad:** media · **Clase:** `contrato` · **Estado:** `abierto` · **REQ:** REQ-007 (CA-60)
- **Dueño:** `analista-requerimientos` (criterio) + `desarrollador` (aviso y línea del bloque)
- **Es el pronunciamiento que REQ-007 CA-60 estaba esperando.**

**Medido.** Con `.arnes/config.json` ilegible, `Write` sobre ese archivo → **ALLOW** para
`qa-tester`, `auditor-seguridad` y `analista-requerimientos` por igual. El `stderr` de esas tres
llamadas es **idéntico** al de cualquier otra llamada durante la avería (el `jq: parse error` y el
aviso genérico de SEC-005): **nada** dice que se ha permitido excepcionalmente una escritura sobre
el archivo que declara las invariantes, ni quién la hizo. Y al parar el agente, `hooks/stop.sh`
sale 0 dejando `docs/ESTADO.md` **vacío** —sin bloque derivado— con dos `jq: parse error` crudos
por `stderr`: la observabilidad que `AGENTS.md` §13 declara («la traza vive en archivos legibles»)
se apaga justo en el estado degradado.

**Dictamen.** Los tres límites de CA-60 —un solo archivo, sólo si es la única escritura del
comando, sólo mientras el manifiesto sea ilegible— acotan bien el **radio**: verifiqué que
`printf "{}" > .arnes/config.json; echo x > docs/n.md` sigue en DENY y que con el manifiesto sano
el archivo vuelve a estar protegido. La alternativa (punto muerto) es peor, y no pido revertir la
excepción. Pero acotar el radio **no es dejar rastro**: hoy la reparación es indistinguible de no
haber pasado nada, y el estado en que ocurre es **también** el estado de SEC-010. **Los tres
límites son necesarios y no suficientes: el residual exige un control extra**, y ése es el rastro.

**Control que exijo como criterio/NFR de REQ-007** (los tres, baratos):
1. La ruta de excepción emite un `arnes_warn` **propio y distinguible** del genérico de SEC-005:
   que nombre el archivo, el `agent_type` que lo escribe y diga que es una reparación permitida
   excepcionalmente.
2. Mientras el manifiesto sea ilegible, el bloque derivado de `docs/ESTADO.md` escribe una línea
   que lo dice («manifiesto ilegible: enforcement degradado»), en vez de no escribirse.
3. El criterio declara, junto a los tres límites, **qué queda sin gobernar** durante la avería —hoy,
   `guard-git` (SEC-010)—, para que el residual esté escrito y no descubierto.

Con esos tres controles escritos e implementados, el residual de CA-60 es **aceptable** para mí.
Sin ellos, mi firma sobre CA-60 no existe: REQ-007 no se firma en esta ventana.

---

### SEC-012 — Dictamen sobre QA-113 (token entrecomillado en `guard-git`): se confirma la conducta y se **concurre** con la clase `instrumento`

- **Severidad:** media · **Clase:** `instrumento` (concurrente con QA) · **Estado:** `abierto`
- **REQ:** REQ-005 (CA-21.5) · **Dueño:** `desarrollador`, ventana **1.32.0** (REQ-007 Bloque C)

**Reproducido**, con los dos canarios: `git clean "-f"`, `git clean '-f'`, `git reset "--hard"`,
`git checkout "."`, `git "clean" -f` → **ALLOW**; `git clean -fd` → DENY.

**Dictamen, que se me pidió expresamente.** Sostengo `instrumento` y **no veto por este motivo**,
por cuatro razones medidas, no por deferencia:

1. **El write-back ya existe y es honesto.** CA-21.5 y «Fuera de alcance» de REQ-005 declaran hoy,
   por escrito, que un token entrecomillado o escapado no se ve, con las seis formas medidas y con
   la ventana y el dueño del arreglo. Un límite declarado no es un fallo en abierto: es un límite.
2. **No abre nada que estuviera cerrado.** Verificado: 1.30.3 publicada permite la vía equivalente
   en el detector de escrituras, y el banco entero da **una sola** transición `deny → allow`
   respecto de la publicada, que es CA-40 y está declarada. `guard-git` con comillas deja las cosas
   como estaban, no peor.
3. **El descuento es compartido a propósito** y su corrección está asignada al Bloque C de REQ-007
   (1.32.0). Duplicarlo aquí sería una segunda transcripción de la misma regla, que es justo lo que
   este arnés predica no hacer; y sin el descuento, `git commit -m "no uses git clean"` sería un
   `git clean`.
4. **La ergonomía del bypass importa, y aquí juega a favor.** Nadie escribe `git clean "-f"` por
   descuido: entrecomillar un flag es un acto deliberado, y la barandilla no pretende contener al
   que se empeña. SEC-009, en cambio, sí se escribe por descuido, y por eso **ese** sí bloquea.

**La diferencia entre los dos, dicha en una línea:** QA-113 es un hueco **declarado, heredado y
deliberado de rodear**; SEC-009 es un hueco **no declarado, nuevo en la única puerta encendida por
defecto y que se pisa sin querer**. La clase distinta no es una concesión: es la aplicación de la
misma tabla a dos hechos distintos.

**Nota de vigilancia para la próxima auditoría:** cuando el Bloque C aterrice en 1.32.0, estas
formas deben pasar a DENY y los casos del banco que hoy fijan su ALLOW deben cambiar de veredicto
**en voz alta**. Si aterriza el Bloque C y siguen en ALLOW, es regresión.

---

## Limitaciones conocidas — actualización de 1.31.0

> Las nueve de R-001 (LIM-01…LIM-09) **siguen vigentes tal cual**: ninguna se cerró en esta
> ventana y ninguna se agravó. Lo que 1.31.0 añade es una puerta nueva, y con ella sus propios
> límites.

| # | Límite | Conducta medida (2026-09-06, candidata `79ff767`) | Origen |
|---|---|---|---|
| **LIM-10** | **`guard-git` no ve un token entrecomillado o escapado** —flag o subcomando—, por el mismo descuento de comillas de LIM-04, que la puerta comparte a propósito | `git clean "-f"`, `git clean '-f'`, `git reset "--hard"`, `git checkout "."`, `git "clean" -f`, `git clean \-f` → **allow**; `git clean -fd "src"` (el **operando** entrecomillado) → **deny** | QA-113 · **SEC-012** · REQ-005 CA-21.5 → arreglo en REQ-007 Bloque C (1.32.0) |
| **LIM-11** | **`guard-git` sólo ve la primera palabra de cada segmento**, y sólo parte por `&&`, `\|\|`, `\|`, `;`, `$(`, acento grave y paréntesis. Una palabra reservada, una llave, un `&` sencillo, un envoltorio no listado o una continuación de línea esconden el comando entero | `if true; then git clean -fd; fi`, `{ git clean -fd; }`, `for i in 1; do …; done`, `sleep 0 & git clean -fd`, `nohup git clean -fd`, `git clean \`+salto+`-fd` → **allow** | **SEC-009** — **no declarado todavía**: es hallazgo abierto, no un límite aceptado |
| **LIM-12** | **Con el manifiesto presente pero ilegible, `guard-git` permite**, mientras el aviso de SEC-005 afirma que «toda escritura … se DENIEGA». En un proyecto plantilla el manifiesto no está protegido, así que la puerta encendida por defecto se apaga con una escritura | manifiesto roto/vacío/array/`git` del tipo equivocado → `git clean -fd` **allow** con aviso; `prohibidos` cadena → **deny** con aviso que nombra la clave | **SEC-010** — **no declarado todavía**: hallazgo abierto |
| **LIM-13** | **Un subcomando de git que destruye pero no está en `git.prohibidos` pasa**, y la lista por defecto no incluye el remoto ni `worktree` | `git worktree remove --force .`, `git push --force`, `git rm -rf .` → allow | REQ-005 «Fuera de alcance» — **límite declarado**, mapeo del proyecto (CA-19, CA-34) |
| **LIM-14** | **Una entrada de la cola de aprobaciones escrita con otra forma no cuenta y nadie avisa.** Sólo `### ` + espacio, dentro de `## Pendientes`, es una entrada | `- [ ] decidir algo` bajo `## Pendientes` → la puerta **permite** cerrar; `### …` → deniega. Igual que en 1.30.3 en la puerta (lo que cambia en 1.31.0 es que el bloque derivado deja de contar viñetas y dice el mismo número) | REQ-009 · `templates/PENDING_APPROVAL.md.tpl`, que lo declara — **límite declarado** |
| **LIM-15** | **El plegado de acentos hace que una errata acentuada valga como veredicto.** Es la contrapartida querida de REQ-010 y va en las dos direcciones | `Seguridad: aprobádo` se lee `aprobado`. Controles intactos: `aprobado*` conserva el asterisco, `en revision` y `revisión` siguen siendo anomalía; y el banco entero no produce **ninguna** transición `deny → allow` por esta causa | REQ-010 — **límite declarado**, contrapartida explícita del REQ |

**Formas que se comprobaron y NO son huecos** (medidas por el auditor en esta ventana, para que no
se vuelvan a buscar): la cola con un **NUL** y la cola **sin permiso de lectura** → **deny** con
motivo propio, nunca `allow` por 0; un REQ que es un **enlace simbólico** que sale del proyecto →
**deny**; `git.prohibidos` con el tipo equivocado → **deny** con aviso que nombra la clave;
`git.activo: "false"` (cadena) **no** apaga la puerta y avisa; quality gate en rojo → **deny**
antes de mirar veredictos (fail-closed); `Seguridad: con-hallazgos`, `preventiva`, `vetado` y
`pendiente` → **deny** del cierre en `critico` **y** en `ligero`; `Hallazgos abiertos:` con
`(contrato)` o **sin clase** → deny, con `(instrumento)` → allow.

---

## Estado de seguridad aprobado por REQ — ventana 1.31.0

| REQ | Veredicto | Fecha | Versión | Controles que quedan acreditados (contra esto se compara la próxima auditoría) |
|---|---|---|---|---|
| **REQ-002** | `aprobado` | 2026-09-06 | candidata 1.31.0 (`79ff767`) | (1) La exigencia de fecha y la caducidad **nacen apagadas**: sin las claves, la conducta es la de 1.30.3. (2) Con `exigir_fecha: true`, un `aprobado` sin fecha **no cierra**, y en `critico` se le exige a **las dos** firmas. (3) Un valor no booleano en `veredictos.exigir_fecha` **cae al defecto y avisa** (no apaga en silencio). (4) Sin repositorio git y con la caducidad encendida, **no deja pasar** |
| **REQ-003** | `aprobado` | 2026-09-06 | candidata 1.31.0 (`79ff767`) | (1) `Seguridad: con-hallazgos` es un valor **legible** y **no cierra** un REQ crítico —verificado por el auditor, junto con `preventiva`, `vetado` y `pendiente`, en `critico` y en `ligero`—. (2) El vocabulario vive **una vez** y lo comparten puerta e informe (prueba por mutación de QA). (3) Escribir un veredicto fuera del vocabulario **avisa** y no compite con la denegación |
| **REQ-004** | `aprobado` | 2026-09-06 | candidata 1.31.0 (`79ff767`) | (1) La rotación de sección **nace apagada**. (2) Nunca escribe fuera del proyecto: `archivo_dir: "../fuera"` y enlace simbólico que sale → **nada** fuera. (3) La **cabecera y sus veredictos no se alteran**, y el resto del documento queda byte a byte. (4) Destino sin permiso → origen intacto y **cero** temporales huérfanos. (5) Un mapeo que no casa **avisa** por sus dos ramas y lo dice el bloque derivado |
| **REQ-005** | **`con-hallazgos`** | 2026-09-06 | candidata 1.31.0 (`79ff767`) | Acreditado: (1) la puerta es del **comando**, no de la identidad —alcanza al `desarrollador` y a la coordinadora, verificado—; (2) `cd … &&`, `git -C`, `(…)`, `$(…)`, `\| tee`, `sudo`, `env` y las opciones globales no la esquivan; (3) las ortografías larga/corta y el alias `stash save` casan; (4) la lista es del proyecto y se apaga con un acto explícito. **NO acreditado:** SEC-009 (construcciones del shell) y SEC-010 (manifiesto ilegible). **Este veredicto no cierra el REQ** |
| **REQ-006** | `aprobado` | 2026-09-06 | candidata 1.31.0 (`79ff767`) | (1) El recorte es **sólo de presentación**: la puerta sigue leyendo el campo **entero** (un `Hallazgos abiertos:` largo con clase bloqueante sigue denegando). (2) `REQ`, `Estado` y `Rigor` no se recortan. (3) El bloque es idempotente byte a byte y no rompe la tabla |
| **REQ-009** | `aprobado` | 2026-09-06 | candidata 1.31.0 (`79ff767`) | (1) **Una sola regla** de conteo para la puerta, el bloque derivado y el informe: el número que se lee es el que bloquea. (2) Una cola **ilegible** o con un **NUL** → **deny**, nunca `0` (verificado por el auditor). (3) Sin archivo → 0 sin error. Límite declarado: LIM-14 |
| **REQ-010** | `aprobado` | 2026-09-06 | candidata 1.31.0 (`79ff767`) | (1) La normalización es **la misma** en los tres lectores y en `campos-req.awk` (39 cabeceras, 0 divergencias). (2) El plegado **no relaja ningún cierre**: en 625 casos del banco no hay ninguna transición `deny → allow` atribuible a él. (3) Los controles negativos (`en revision`, `enrevision`, `revisión`, `en-revisión-parcial`) siguen siendo anomalía y la `ñ` en NFD no se convierte en `n` |
| **REQ-007** | **no se firma** | — | — | Parcial, `en-progreso`; sus bloques B y C cruzan a 1.32.0. **SEC-011** queda abierto contra su CA-60. Lo verificado de él en esta ventana (SEC-003…SEC-007 implementados, frontera de este repositorio) queda anotado en las verificaciones de gobernanza, **no** como firma |

### Verificaciones de gobernanza de R-002, con su resultado

Todas re-hechas por el auditor; ninguna tomada del informe de QA.

| Verificación | Resultado |
|---|---|
| **El diff no relaja ninguna condición existente** | **Cumple.** `.github/workflows/`, `hooks/hooks.json` y `.githooks/` **no aparecen** en `git diff origin/main..HEAD`. Las `quality_gates` del manifiesto no cambian (el diff de `.arnes/config.json` toca sólo `arnes_version` y `codigo_app`). El ruleset no se toca desde el repositorio |
| **Las transiciones `deny → allow` son exactamente las declaradas** | **Cumple.** Banco de 625 casos contra la candidata y contra 1.30.3: **una sola** (`REQ-007 CA-40`), declarada en CA-40/CA-41 con su fail-before en CA-42. Las 79 restantes van en la dirección contraria (cobertura ganada). Las tres `deny → allow` que enumeró QA en `guard-git` son respecto de la implementación **intermedia** de esta ventana (`40312c6`), no de la publicada, y no aparecen aquí porque contra 1.30.3 la puerta no existía |
| **La frontera de este repositorio se incluye a sí misma y funciona** | **Cumple, medido.** `.arnes/config.json`, `.claude-plugin/plugin.json` y `.claude-plugin/marketplace.json`: **ALLOW sólo** para `desarrollador`; DENY para `qa-tester`, `analista-requerimientos`, `auditor-seguridad` y la sesión coordinadora. Controles: `hooks/guard-git.sh` sigue cerrado (allow sólo `desarrollador`); `templates/` y `tests/` siguen **abiertos** a todos |
| **…y NO se propaga a `templates/`** | **Cumple.** `templates/arnes-config.json.tpl` mantiene `"globs": [{{CODIGO_APP_GLOBS}}]`: el mapeo de este repositorio no viaja a ningún proyecto |
| **Efecto colateral aceptado del punto anterior** | **Confirmado.** `arnes_version` vive en `.arnes/config.json`, luego subirla es ahora trabajo del `desarrollador`. Hoy declara `1.30.3`, que es lo correcto **hoy** (el guardián de la sesión es la estable) y sube a `1.31.0` **después** de publicar y verificar la instalación, no antes. **Consecuencia de seguridad a vigilar:** el bump ya no lo puede hacer la coordinadora, así que si se olvida, el manifiesto miente sobre qué versión gobierna |
| **Nada del autoalojamiento se filtra a lo que heredan los proyectos** | **Cumple.** De `templates/`, `agents/`, `playbooks/` y `skills/`, el diff toca cinco archivos, todos con **mecanismo** genérico: el bloque `veredictos`, el bloque `git` (con su lista por defecto y cómo apagarla), `limites`, la rotación de sección, la regla de conteo de la cola y la documentación de conducta de 1.31.0 en `arnes-upgrade`. Ni roles, ni globs de este repositorio, ni la política de autoalojamiento. Los tres archivos nuevos de `.arnes/plantillas-origen/` son **copias idénticas** de `templates/` (andamiaje de `arnes-upgrade`), no material nuevo |
| **Repositorio público: sin nombres ni datos de proyectos cliente** | **Cumple.** Revisadas las ~6.600 líneas añadidas. Las únicas menciones a «cliente» son **la regla** de no publicarlos (y aparecen, correctamente, como criterio de aceptación del CHANGELOG en REQ-002/003/007). `dataverse-lookups.guard.test.ts.tpl` es una plantilla genérica con marcadores `{{…}}`, sin tabla, entorno ni identificador de nadie |
| **Sin secretos en lo añadido** | **Cumple.** Ningún patrón de credencial, clave privada ni token en el diff; las coincidencias de «token» son todas la palabra técnica del casado de git o la contabilidad de contexto. `.gitignore` sigue cubriendo `.mcp.json`, `.claude/settings.local.json`, `memory/`, `insumos/` y `mejoras-arnes-*.md` |
| **Cola de aprobaciones** | `PENDING_APPROVAL.md` sin entradas bajo `## Pendientes` (0, leído con la misma función que la puerta) |
| **Modos degradados** | **Cumple en dos de tres.** Sin `jq` y sin manifiesto → inerte, declarado. Manifiesto **ilegible** → las dos puertas de escritura deniegan (SEC-005 cerrado, verificado), pero `guard-git` **permite**: es SEC-010 |

### Pendientes que esta firma NO cubre

- **El coste y el banco completo en Windows/MSYS**, la plataforma del `desarrollador`. Todo lo de
  esta revisión es Linux/WSL2. `AGENTS.md` §7 lo exige antes de pedir la fusión; **no consta** que
  se haya hecho para esta candidata. Es condición del gate humano, no de mi veredicto.
- **CI en verde en el PR** (`hooks-en-linux`), la **fusión**, el **tag** y la actualización de la
  instalación estable: son de la coordinadora y del propietario.
- **REQ-007 entero**, y en particular CA-60: ver SEC-011.
- **Los bloques B y C de REQ-007** (1.32.0): no se auditaron y no se cuentan ni a favor ni en
  contra. Cuando el Bloque C aterrice, LIM-10 debe cerrarse **en voz alta** o es regresión.

### Obligación de write-back abierta (`AGENTS.md` §9)

**SEC-009, SEC-010 y SEC-011 no se cierran —ni se levanta el veto de REQ-005— hasta que el control
quede como criterio o NFR en el REQ (vía `analista-requerimientos`) *y* el código lo implemente.**
Un control que viva sólo en este registro es deriva. Sigue abierta, además, la obligación de R-001:
SEC-001…SEC-007 como criterios de REQ-007 (SEC-003…SEC-007 ya implementados en esta ventana;
SEC-001 y SEC-002 siguen asignados a 1.32.0).

---

## Revisión R-003 — levantamiento del veto de REQ-005, ventana 1.31.0 — 2026-09-06

**Alcance.** `git diff 79ff767..62d27c2` (19 archivos), es decir **sólo lo hecho desde mi veto**,
más una re-verificación de que el diff posterior no invalida las seis firmas de R-002. Guardián de
la sesión y línea base de no-regresión: instalación estable **1.30.3** (`6c1b58a`). Plataforma:
Linux (WSL2). Orden respetado: `QA: aprobado` en REQ-005 (vuelta 4 extra, autorizada por la
coordinadora con su razón y su límite escritos en el Historial del REQ) **antes** de esta firma.
**REQ-007 sigue sin firmarse**: `en-progreso` y parcial.

**Método.** Idéntico al de R-002 y por la misma razón: sondas propias contra `hooks/guard.sh` —el
despachador real—, con **canario positivo (`git clean -fd` → DENY) y negativo (`ls -la` → ALLOW) en
cada tanda**, `timeout 30` por sonda y `[ -z "$out" ] && dec=allow` **antes** de interpretar nada,
porque el hook permite con salida vacía. Todo git, en proyectos desechables bajo el scratchpad;
**ninguna orden destructiva se ejecutó** contra este worktree ni contra ningún entorno de terceros.
Los cuatro caminos del archivo del usuario se comprobaron **por hash**, no por «contiene la cadena»,
que es exactamente cómo ese fallo llegó hasta aquí.

**Error de método propio, anotado como el de R-002 para que no se repita.** Mi primera corrida del
banco contra la línea base dio **483/199/1** y no los 494/188/1 que reportaron el desarrollador y la
coordinadora. No era el instrumento: el banco resuelve el lector con `LECTURA="$HOOKS_DIR/../tools/
arnes-lectura.sh"`, y yo había extraído de `6c1b58a` **sólo** `hooks/`, así que once casos de
`tools/` fallaban con `rc=127`. Extraído también `tools/`, la corrida da **494 PASS / 188 FAIL / 1
SKIP**, idéntica a la de ellos. **Lección, que es del método y no del código:** `ARNES_HOOKS_DIR`
cambia los hooks pero **arrastra `tools/` por ruta relativa**, de modo que la cifra de la base sólo
es comparable si se apunta a un árbol **completo** de la versión base. Mis dos corridas previas
fueron idénticas entre sí (483/199/1 dos veces), así que el banco es determinista aquí; lo que
variaba era mi montaje.

**Banco (cifras propias, no tomadas del informe de QA).**

| Corrida | PASS | FAIL | SKIP | Total |
|---|---|---|---|---|
| Candidata `62d27c2` | **682** | **0** | 1 | 683 = `CASOS_ESPERADOS` ✔ |
| Línea base 1.30.3 (árbol completo) | **494** | **188** | 1 | 683 ✔ |
| (mi montaje incompleto, anulado) | 483 | 199 | 1 | 683 — ver «error de método» |

De los 188 FAIL de la base, **96** son `esperado=deny got=allow` (cobertura ganada, dirección
segura), el resto son comprobaciones de motivo, texto o tiempo, y **exactamente 1** es
`esperado=allow got=deny`: `REQ-007 CA-40 QA-014 '(instrumento, dueño REQ-007)': la clase es el
primer elemento`. Es **la única transición `deny → allow` respecto de la versión publicada** en 683
casos, está **declarada** en CA-40 con su control en CA-41 y su fail-before en CA-42, y es la misma
que medí en R-002. **Ninguna otra relajación.**

**VEREDICTO: `Seguridad: aprobado` en REQ-005 — el veto de R-002 queda LEVANTADO.** SEC-009,
SEC-010 y SEC-011 pasan a `mitigado`. Las seis firmas de R-002 (REQ-002, 003, 004, 006, 009, 010)
**se confirman**: el diff posterior no las invalida. **REQ-007 no se firma.**

---

### SEC-009 — `mitigado` (verificado por el auditor, no aceptado del informe de QA)

- **Estado:** `abierto` → **`mitigado`** · Clase `contrato` · REQ-005 CA-06, **CA-40**, **CA-41**
- **Arreglo:** `hooks/guard-git.sh` — se pliega la continuación de línea **antes** de segmentar, el
  `&` sencillo separa órdenes (después de `&&`), y el bucle de prefijos tolera siete envoltorios y
  veinte palabras reservadas.

**Medido por mí, a través de `guard.sh`, candidata `62d27c2` contra la vetada `79ff767`:**

| Forma | `79ff767` (vetada) | `62d27c2` |
|---|---|---|
| `if true; then git clean -fd; fi` | allow | **deny** |
| `if [ -d .git ]; then git reset --hard; fi` *(mía, no estaba en la lista)* | allow | **deny** |
| `{ git clean -fd; }` | allow | **deny** |
| `for i in 1; do git clean -fd; done` | allow | **deny** |
| `while read x; do git checkout .; done` *(mía)* | allow | **deny** |
| `sleep 0 & git clean -fd` | allow | **deny** |
| `nohup git clean -fd` | allow | **deny** |
| `timeout 30 git clean -fd` *(mía)* | allow | **deny** |
| `git clean \`+salto+`-fd` | allow | **deny** |
| `G=clean; git $G -f` | allow | allow — **límite, declarado en «Fuera de alcance»** |

Las nueve formas que medí en R-002 pasan a DENY, y tres formas más que **no** estaban en mi lista
y que un desarrollador escribe igual de fácil. El subcomando por **variable** sigue pasando y está
declarado por escrito: es límite, no hueco.

**Cero falsos positivos**, medidos en 17 comandos legítimos: `git status`, `git status --porcelain`,
`git log --oneline -5`, `git diff origin/main..HEAD`, `git add -A && git commit -m "no uses git
clean -fd aqui"`, `echo "git clean -fd"`, `grep -rn "git reset --hard" docs/`, **la propia quality
gate del proyecto** (`for f in hooks/*.sh; do bash -n "$f" || exit 1; done`), `jq -e .
hooks/hooks.json >/dev/null`, `ls -la 2>&1 | head` (el `&` de la redirección, que el nuevo
separador parte), `git commit -m "x" & wait`, `if git diff --quiet; then echo limpio; fi`,
`timeout 30 bash tests/run.sh`, `git stash list`, `gitk --all`, `github-cli auth status` y
`legit clean -f`. Ninguno se movió.

**Ningún límite declarado se cerró por accidente** — que es lo que yo mismo pedí vigilar en CA-41.
Verificado en las dos versiones, con los dos canarios en la tanda:

- **LIM-10 intacto:** `git clean "-f"`, `git clean '-f'`, `git reset "--hard"`, `git checkout "."`,
  `git "clean" -f` siguen en **ALLOW**; y el control `git clean -fd "src"` (operando entrecomillado)
  sigue en **DENY**.
- **La frontera de la barra invertida se sostiene, y era el riesgo real de este arreglo:**
  `git clean \-f` **sin salto de línea** sigue en **ALLOW** (LIM-10, dueño `desarrollador`, ventana
  1.32.0), mientras `git clean \`+salto+`-fd` pasa a **DENY**. Plegar la continuación de línea no
  arrastró al escape del guion. Cuando el Bloque C aterrice en 1.32.0, el primero debe pasar a DENY
  **en voz alta**.
- **LIM-13 intacto:** `git worktree remove --force .`, `git push --force` y `git rm -rf .` siguen en
  **ALLOW**: ampliar dónde se busca no amplió **qué** se deniega.

**Un límite declarado sí se cerró, y es QA-115 — lo confirmo con medición propia y concurro con el
QA.** `xargs git clean -fd` y `echo . | xargs git clean -fd` pasan de **allow** a **deny**, mientras
«Fuera de alcance» de REQ-005 declaraba `xargs` expresamente entre lo que la puerta **no** ve. Es la
simetría exacta de lo que yo pedí vigilar con LIM-10, sólo que en la otra dirección: **un límite que
desaparece sin decirlo es tan deriva como una promesa incumplida**. El write-back del analista está
escrito y es honesto —CA-40 enumera ahora los **siete** envoltorios y las **veinte** reservadas del
código, y CA-41(f) añade el control `xargs -n1 git status` → ALLOW—, así que **QA-115 se retira del
campo `Hallazgos abiertos:` de REQ-005**. La regla que el analista escribió para que no se repita
—«cuando el código cubra MÁS de lo que el criterio promete, se actualiza el criterio en el MISMO
cambio»— es la correcta y la respaldo.

---

### SEC-010 — `mitigado`

- **Estado:** `abierto` → **`mitigado`** · Clase `contrato` · REQ-005 **CA-42**, **CA-43**
- **Arreglo:** con `ARNES_MANIFEST_ROTO=1`, `guard-git` cae a `ARNES_GIT_PROHIBIDOS_DEFECTO` —la
  lista que vive **una sola vez** en `hooks/lib.sh` y que `jq` recibe por `--arg`, no una segunda
  transcripción— y deniega, añadiendo al motivo el texto de **MODO DEGRADADO** con su salida.

**Medido por mí, `git clean -fd` en proyectos desechables:**

| Manifiesto | `79ff767` | `62d27c2` | `git status` en la candidata |
|---|---|---|---|
| JSON roto (`{"agentes":{,}`) | allow | **deny** | allow |
| vacío (0 bytes) | allow | **deny** | allow |
| `[]` (array) | allow | **deny** | allow |
| `null` | allow | **deny** | allow |
| `42` (número) *(mío)* | allow | **deny** | allow |
| `"cadena"` *(mío)* | allow | **deny** | allow |
| `{"git":"si"}` (clave del tipo equivocado) | allow | **deny** | allow |
| `{"git":{...,"prohibidos":"clean -f"}}` | deny | **deny** | allow |
| **sano** (control) | deny | deny | allow |
| **`git.activo: false`** con manifiesto sano (control) | allow | **allow** | allow |
| **ausente** (control, CA-22) | allow | **allow** | allow |

Once estados, ocho de ellos ilegibles. **Inerte ≠ ilegible, verificado en los dos sentidos:** el
manifiesto **ausente** sigue permitiendo, y **sin `jq` en el `PATH`** con el manifiesto ilegible el
hook sale **0 con stdout vacío** y el aviso «jq no encontrado; enforcement inactivo» — sigue
**inerte**, que es lo que `AGENTS.md` §13 declara y lo que CA-22 promete. La avería no se convirtió
en una dependencia dura nueva.

**El modo degradado aplica la lista por defecto y no todo git**, verificado por los dos lados: con
el manifiesto roto, `git stash pop` → **deny** (está en la lista del código) y `git worktree remove
--force .` → **allow** (no lo está). Un modo degradado que denegara todo git dejaría al proyecto sin
poder ni consultar el estado, y no lo hace.

**El aviso de SEC-005 ya no afirma una cobertura que no tiene.** Antes decía «toda escritura que las
puertas deban juzgar se DENIEGA», cierto de las dos puertas de escritura y **falso** de `guard-git`;
ahora añade «y `guard-git` deniega el git destructivo de su LISTA POR DEFECTO». La afirmación y la
conducta coinciden.

**El borde queda declarado y lo respaldo:** un proyecto con `git.activo: false` al que se le rompa
el manifiesto **pasa a denegar**. Es la dirección segura y la única honesta —mientras el archivo sea
ilegible, el arnés no puede saber que ese proyecto quería la puerta apagada, porque la declaración
vive dentro de él—, y la salida es reparar el JSON, no un interruptor nuevo. Está escrito en CA-42 y
en la nota de `arnes-upgrade`.

---

### SEC-011 — `mitigado`, y con ello **retiro la objeción que dejaba a CA-60 sin mi firma**

- **Estado:** `abierto` → **`mitigado`** · Clase `contrato` · REQ-007 **CA-63** (CA-60)
- Los **tres** controles que exigí están implementados y **medidos por mí**:

1. **Aviso propio y distinguible.** Con el manifiesto ilegible, un `Write` de `qa-tester` sobre
   `.arnes/config.json` → ALLOW **y** por `stderr`: *«REPARACION DEL MANIFIESTO permitida
   excepcionalmente: '.arnes/config.json' se esta escribiendo (herramienta Write) por 'qa-tester'…»*.
   Nombra el archivo, la **herramienta** y el **`agent_type`**, y se emite **una vez por llamada**,
   no una por guardián (verificado: una sola línea con los tres guardianes en el mismo proceso). No
   registra ningún contenido, sólo tipo de agente y ruta relativa — correcto para un repositorio
   público.
2. **La avería es visible en el bloque derivado.** Con el manifiesto `null`, `docs/ESTADO.md` recibe
   la línea **«Manifiesto ilegible: enforcement degradado»** con la salida (`jq -e .
   .arnes/config.json`). Antes el bloque no se escribía y el archivo quedaba vacío.
3. **Lo que queda sin gobernar está enumerado**, en CA-63.3, con sus cuatro apartados y con la regla
   de mantenimiento que obliga a actualizar la lista en el mismo cambio que la modifique. Es lo que
   convierte un agujero en un límite conocido.

**El radio de la excepción sigue acotado** —lo re-medí, porque un arreglo que ensancha el aviso
podría haber ensanchado el permiso—: `Write` sobre `.arnes/config.json` → **allow**; `Write` sobre
`docs/n.md` → **deny**; `printf "{}" > .arnes/config.json; echo x > docs/n.md` → **deny**. Los tres
límites de CA-60 intactos.

**Con esto, mi objeción a CA-60 queda retirada: el residual es aceptable.** Que CA-60 tenga hoy mi
conformidad **no es la firma de REQ-007**, que sigue `pendiente` por lo demás.

---

### SEC-014 — Los cuatro caminos por los que el arnés destruía el archivo del usuario: verificados **cerrados**, por hash

- **Severidad:** alta · **Clase:** `contrato` · **Estado:** **`mitigado`** · **REQ:** REQ-007 CA-64
- **No lo pedí yo**: salió de la misma medición de R-002 (SEC-011) y el desarrollador y el QA lo
  persiguieron hasta el fondo. Lo registro aquí con número propio porque **es el hallazgo más grave
  de la ventana** y no puede vivir sólo como una viñeta de SEC-011: no es un aviso que falta, es
  **un archivo del usuario que se destruye**.

**Medido por mí, `docs/ESTADO.md` con texto humano, comparando hash antes/después:**

| Camino | `79ff767` (vetada) | `62d27c2` |
|---|---|---|
| manifiesto **vacío** | `rc=1`, el hook de parada **muere con error** | `rc=0`, escribe con la línea de degradado, humano intacto |
| manifiesto **`null`** | deriva **como si todo estuviera sano** (1104 B, sin decir nada) | escribe **diciendo que está degradado**, humano intacto (2 de 2 líneas) |
| `docs/ESTADO.md` con **NUL** | 71 B → 1058 B, **reescrito**: `sha 20a4553d…` → `b344d2ad…` | 71 B → 71 B, **`sha 20a4553d…` → `20a4553d…`: intacto byte a byte** |
| `docs/ESTADO.md` **sin permiso de lectura** | 149 B → 1036 B, texto humano **borrado** (0 de 2 líneas) | 149 B → 149 B, **2 de 2 líneas** |
| control: todo sano | escribe el bloque | escribe el bloque, humano intacto |

**El principio que lo cierra, y que vale más que los cuatro casos: lo que no se puede leer no se
reescribe.** Antes, una lectura fallida devolvía la cadena vacía y el hook componía el archivo a
partir de ella, de modo que **el fallo de lectura se convertía en un borrado**. Ahora cada camino de
lectura que falla emite su aviso y **retorna sin escribir**. La publicación va por **temporal y
renombrado**, con `trap … EXIT INT TERM XFSZ` que retira el temporal ante señal; verificado: **cero
temporales huérfanos** tras todas mis corridas. El temporal es `"$destino.arnes.tmp"`, **junto al
destino y dentro del proyecto** —no en un `/tmp` compartido—, así que no hay ventana de enlace
simbólico de terceros ni carrera entre usuarios. Correcto.

---

### Dictamen sobre QA-116 y QA-117: **valen como residual de 1.31.0. Ninguno debe entrar antes de publicar.**

Se me pidió expresamente decidir. Los dos son `contrato`, los dos viven en **REQ-007**, que **no
cierra en esta ventana**, y los dos los **reproduje yo mismo en las dos versiones**:

| Hallazgo | v1.30.3 **publicada** | candidata `62d27c2` |
|---|---|---|
| **QA-116** — `docs/ESTADO.md` en modo **444** con la carpeta escribible | `rc=0`, se escribe, **modo 444 → 644**, humano íntegro | **idéntico**: `rc=0`, 444 → 644, humano íntegro |
| **QA-117** — texto humano **posterior** a los marcadores | las 4 líneas sobreviven, las 2 de abajo **suben** encima del bloque; idempotente en la 2ª parada | **idéntico**: 4 de 4 líneas, mismo reordenamiento, idempotente |

**Cinco razones, medidas, para aceptarlos como residual:**

1. **Son heredados, no regresiones.** Se comportan **exactamente igual** en la versión publicada que
   gobierna hoy. Publicar 1.31.0 no empeora nada: lo que hoy le pasa a un proyecto le seguirá
   pasando igual, ni más ni menos.
2. **No pierden un solo byte del usuario.** Es la frontera que separa esto de SEC-014, que sí
   bloqueaba: allí el contenido humano **desaparecía**; aquí sobrevive entero y verificado por
   ausencia de cadena, no sólo por hash. Un archivo reordenado se lee; un archivo borrado, no.
3. **El contrato ya dice la verdad.** CA-64.1 y CA-64.2 declaran hoy, por escrito, la conducta
   **medida** —incluida la corrección de la lista de causas, donde «archivo sin permiso de
   escritura» era falso y se sustituye por `ENOSPC`—, y CA-64.1-bis y CA-64.2-bis **exigen** el
   arreglo con **dueño (`desarrollador`) y ventana (1.32.0)**. Un límite declarado con dueño y
   vencimiento no es un fallo en abierto: es un límite. Es el mismo criterio con el que concurrí con
   `instrumento` en SEC-012 y con el que **bloqueé** SEC-009 por no estar declarado.
4. **La elección del analista en QA-116 es la correcta y la respaldo.** De las dos salidas, escribir
   **conservando el modo** (B) es mejor que callarse (A): con la carpeta escribible, «el archivo no
   es escribible» no es una propiedad del sistema de archivos sino una apariencia, y construir un
   criterio sobre una apariencia es justo la clase de promesa falsa que esta ventana ha estado
   corrigiendo. Callarse, además, deja muda la continuidad sin que nadie lo haya pedido y **sin que
   el hook pueda bloquear la parada** para avisar.
5. **Arreglarlos ahora tocaría el camino que 1.31.0 acaba de rendir.** La publicación por temporal y
   renombrado se acaba de reescribir para cerrar SEC-014, con nueve averías medidas. Meter en la
   misma ventana la conservación del modo y la reconstrucción **posicional** del texto de fuera es
   pedir un cambio no medido sobre el código más delicado del arreglo, **después** de que QA firmara.
   El riesgo de esa prisa es mayor que el de un reordenamiento heredado que no pierde datos.

**Condición que sí exijo, y no es negociable:** los dos casos del banco que hoy fijan estas
conductas están **etiquetados como conducta declarada**, de modo que cuando 1.32.0 aterrice su
veredicto cambie **en voz alta**. Si llega 1.32.0 con CA-64.1-bis y CA-64.2-bis rendidos y esos
casos siguen verdes sin cambiar, es regresión y lo diré. Y **REQ-007 no puede cerrar** con ellos
abiertos: por eso los he escrito en su campo `Hallazgos abiertos:` con clase `contrato`, que es lo
que hace que la puerta lo impida.

---

### SEC-013 — La nota de `arnes-upgrade` no anuncia los cuatro envoltorios nuevos

- **Severidad:** baja · **Clase:** `instrumento` · **Estado:** `abierto` · **REQ:** REQ-005
- **Dueño:** `desarrollador` · **Ventana:** 1.32.0 · **No bloquea el cierre de REQ-005**

`skills/arnes-upgrade/SKILL.md` —lo que **heredan los proyectos** al actualizar— enumera las formas
que pasan a denegarse y cita `nohup git clean -fd`, pero **no** menciona `xargs`, `setsid`, `ionice`
ni `doas`. Medido: `xargs git clean -fd` → **DENY** en la candidata. Un proyecto con un
`… | xargs git clean -fd` en un guion recibirá una denegación que su nota de actualización no le
anunció.

**Por qué `instrumento` y no `contrato`:** el **contrato** (REQ-005 CA-40) sí lo declara completo y
correcto tras el write-back de QA-115; lo que falta es una línea en la documentación de migración.
La dirección es segura (`allow → deny`), la denegación es **ruidosa y trae su motivo** —el agente
sabe al instante qué pasó y cómo seguir—, y no hay pérdida de datos posible. Es un defecto del
instrumento de comunicación, no del producto. **Corrección:** añadir los cuatro nombres a la lista
de la nota, en el mismo sitio donde ya está `nohup`.

---

## Limitaciones conocidas — actualización de R-003

**LIM-11 y LIM-12 se CIERRAN**, y se cierran **en voz alta**, que es como pedí que se cerraran:

| # | Estado tras R-003 | Conducta medida (2026-09-06, candidata `62d27c2`) |
|---|---|---|
| **LIM-11** | **CERRADO** (era SEC-009) | Las nueve formas de R-002 más `while/do`, `if [ -d … ]` y `timeout 30 git` → **deny**. Queda **fuera y declarado**: el subcomando por **variable** (`G=clean; git $G -f`), `find -exec`, los scripts y los intérpretes |
| **LIM-12** | **CERRADO** (era SEC-010) | Once estados de manifiesto probados; los ocho ilegibles → **deny** con motivo de modo degradado y lista por defecto. **Ausente** y **sin `jq`** siguen inertes |
| **LIM-10** | **SIGUE ABIERTO**, sin cambios | `git clean "-f"`, `'-f'`, `git reset "--hard"`, `git checkout "."`, `git "clean" -f` y **`git clean \-f` sin salto** → **allow**; `git clean -fd "src"` → deny. Dueño `desarrollador`, ventana 1.32.0 (REQ-007 Bloque C). **Re-verificado: el arreglo de LIM-11 no lo cerró por accidente** |
| **LIM-13** | **SIGUE ABIERTO**, sin cambios | `git worktree remove --force .`, `git push --force`, `git rm -rf .` → allow. Mapeo del proyecto, no defecto |
| **LIM-14**, **LIM-15** | Sin cambios | Ver R-002 |
| **LIM-16** *(nueva)* | **El modo y la POSICIÓN del texto humano de `docs/ESTADO.md` todavía se alteran** | Modo **444 → 644** y el texto posterior a los marcadores **sube** encima del bloque en cada parada — **sin perder un byte** e idéntico en v1.30.3 publicada. QA-116/QA-117 · REQ-007 CA-64.1-bis y CA-64.2-bis · dueño `desarrollador`, ventana **1.32.0** |
| **LIM-17** *(nueva)* | **La nota de actualización que heredan los proyectos no anuncia los cuatro envoltorios nuevos** | `xargs git clean -fd` → deny sin estar en la nota. SEC-013, `instrumento`, ventana 1.32.0 |

> Las nueve de R-001 (LIM-01…LIM-09) siguen vigentes tal cual: ninguna se cerró en esta ventana y
> ninguna se agravó.

---

## Estado de seguridad aprobado por REQ — cierre de la ventana 1.31.0

| REQ | Veredicto | Fecha | Versión | Controles que quedan acreditados (contra esto se compara la próxima auditoría) |
|---|---|---|---|---|
| **REQ-005** | **`aprobado`** | 2026-09-06 | candidata 1.31.0 (`62d27c2`) | Lo de R-002 **más**: (1) la puerta ve el subcomando **detrás de las palabras reservadas, las llaves, el `&` sencillo, los siete envoltorios y la continuación de línea** — 12 formas medidas en DENY, cero falsos positivos en 17 comandos legítimos. (2) Con el manifiesto **ilegible** la puerta **NO se apaga**: cae a la lista por defecto del código y **deniega** con motivo de modo degradado (8 estados), mientras **ausente** y **sin `jq`** siguen **inertes**. (3) La lista por defecto vive **una sola vez** (`ARNES_GIT_PROHIBIDOS_DEFECTO`), no duplicada entre `jq` y bash. (4) **LIM-10 y LIM-13 no se movieron**: `git clean \-f` sin salto sigue en ALLOW, y ampliar dónde se busca no amplió qué se deniega |
| **REQ-002, 003, 004, 006, 009, 010** | `aprobado` (**confirmado**) | 2026-09-06 | candidata 1.31.0 (`62d27c2`) | Firmas de R-002 **re-verificadas contra el diff posterior**: `62d27c2` no toca `guard-codigo.sh`, `guard-completado.sh`, `campos-req.awk`, `hooks.json`, `.github/` ni las `quality_gates`; el banco entero da 682/0/1 y **la misma única** transición `deny → allow` que en R-002. Los controles acreditados en R-002 siguen en pie, uno por uno |
| **REQ-007** | **no se firma** | — | — | `en-progreso` y parcial; bloques B y C cruzan a 1.32.0. **SEC-011 queda `mitigado`** y con ello retiro mi objeción a **CA-60**, pero eso **no es la firma del REQ**. Quedan abiertos contra él **QA-114, QA-116 y QA-117**, los tres `contrato` |

### Verificaciones de gobernanza de R-003, con su resultado

Todas re-hechas por el auditor sobre el árbol final `62d27c2`; ninguna tomada del informe de QA.

| Verificación | Resultado |
|---|---|
| **Ninguna transición `deny → allow` no declarada contra la versión publicada** | **Cumple.** Banco de 683 casos contra 1.30.3 (árbol completo): **exactamente 1**, `REQ-007 CA-40`, declarada con su control y su fail-before. Las otras 96 van en la dirección contraria. Dos corridas idénticas |
| **Nada relajado en hooks, manifiesto, quality gates, workflow ni ruleset** | **Cumple.** `git diff 79ff767..62d27c2` **no toca** `.github/`, `hooks/hooks.json` ni `.githooks/`; en toda la ventana (`origin/main..62d27c2`) tampoco. Las `quality_gates` del manifiesto **no cambian**; `codigo_app.globs` sólo **se amplía** (`.arnes/config.json`, `.claude-plugin/*`). El ruleset no se toca desde el repositorio |
| **Repositorio público: sin nombres ni datos de proyectos cliente** | **Cumple.** Revisado todo lo añadido desde el veto: las únicas menciones a «cliente» son **la regla** de no publicarlos. Cero coincidencias de dominios, correos o identificadores |
| **Sin secretos en lo añadido** | **Cumple.** Ningún patrón de credencial, clave privada ni token; la única coincidencia es la línea de R-002 que dice justamente eso |
| **Nada del autoalojamiento filtrado a `templates/`, `agents/` o `playbooks/`** | **Cumple.** El diff desde el veto **no toca** ninguno de los tres. Lo único heredable que cambia es `skills/arnes-upgrade/SKILL.md`, y su contenido es **mecanismo genérico**: qué formas pasan a denegarse, qué pasa con el manifiesto roto y **el borde de `git.activo: false`**, declarado en voz alta. Ni roles, ni globs de este repositorio, ni la política de autoalojamiento. **Salvedad menor:** la lista de envoltorios de esa nota está incompleta — SEC-013 |
| **Cola de aprobaciones** | `PENDING_APPROVAL.md` sin entradas bajo `## Pendientes` (0, leído con `tools/arnes-lectura.sh`, la misma regla que la puerta) |
| **El campo `Hallazgos abiertos:` queda CIERTO y la puerta lo confirma** | **Cumple, medido.** Con los campos como los dejé, una sonda de cierre sobre **REQ-005** → **allow** (hallazgos sólo `instrumento`, QA y Seguridad aprobados, cola 0, gates verdes) y sobre **REQ-007** → **deny**. El lector no reporta **ninguna** anomalía en los 11 REQ |
| **Sin temporales huérfanos ni escrituras fuera del proyecto** | **Cumple.** Tras todas mis corridas del hook de parada, cero temporales. El temporal es `"$destino.arnes.tmp"`, junto al destino y dentro del proyecto |

### Reconciliación del campo `Hallazgos abiertos:` (hecha por el auditor en esta revisión)

| REQ | Antes | Después | Razón |
|---|---|---|---|
| **REQ-005** | QA-113, **QA-115**, **SEC-009**, **SEC-010** | QA-113, **SEC-013** | SEC-009 y SEC-010 **cerrados y verificados** en esta revisión. QA-115 **retirado**: su write-back está completo en CA-40 y CA-41(f). SEC-013 **añadido** (`instrumento`, no bloquea) |
| **REQ-007** | QA-114 | QA-114, **QA-116**, **QA-117** | Los dos **existían y no figuraban**. Son `contrato` y por tanto **impiden cerrar REQ-007**, que es lo correcto: su arreglo se rinde en 1.32.0 |

### Obligación de write-back (`AGENTS.md` §9): **cumplida para lo que firmo**

SEC-009 → CA-40/CA-41; SEC-010 → CA-42/CA-43; SEC-011 → CA-63; el fallo del archivo del usuario →
CA-64/CA-65; QA-115 → CA-40 corregido + CA-41(f); QA-116 → CA-64.2 y 2-bis; QA-117 → CA-64.1 y
1-bis. **Ningún control de esta revisión vive sólo en este registro.** Sigue abierta la obligación de
R-001 para SEC-001 y SEC-002 (1.32.0), y la nueva de **SEC-013**, que se cierra con una línea en la
nota de `arnes-upgrade`.

### Pendientes que esta firma NO cubre

- **El banco completo en Windows/MSYS**, la plataforma del `desarrollador`. Todo lo mío es
  Linux/WSL2. `AGENTS.md` §7 lo exige antes de pedir la fusión y **no me consta** que se haya hecho
  para esta candidata. Es condición del gate humano, no de mi veredicto — y lo repito de R-002
  porque **sigue sin constar**.
- **CI en verde en el PR** (`hooks-en-linux`), la **fusión**, el **tag** y la actualización de la
  instalación estable: de la coordinadora y del propietario.
- **El bump de `arnes_version` a 1.31.0** después de publicar. Hoy el manifiesto declara `1.30.3`,
  que es lo correcto hoy; si se olvida, el manifiesto miente sobre qué versión gobierna. Lo dejé
  anotado en R-002 y lo repito porque ahora sólo puede hacerlo el `desarrollador`.
- **REQ-007 entero**, **REQ-008** y **REQ-011**: no llevan mi firma.
- **Los bloques B y C de REQ-007** (1.32.0): no se auditaron. Cuando el Bloque C aterrice, **LIM-10
  debe cerrarse en voz alta o es regresión**; lo mismo para LIM-16 con CA-64.1-bis y CA-64.2-bis.
