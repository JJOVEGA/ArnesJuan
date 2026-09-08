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

---

## Revisión R-004 — ventana 1.32.0 (REQ-012, REQ-013, REQ-014) — 2026-09-06

**Alcance.** `cand/1.32.0` completa: la regla de redacción de criterios y lo que de ella heredan los
proyectos (REQ-012), el campo `Archivos:` y `tools/arnes-paralelo.sh` (REQ-013), la partición del
banco en 37 archivos de sección más el cambio de `.github/workflows/banco.yml` (REQ-014), y
`ADR-002`. Línea base de no-regresión: **v1.31.0 publicada**. Plataforma: Linux (WSL2).
Orden respetado: audito un árbol con `QA: aprobado` en los tres REQ (`AGENTS.md` §6).

**Método.** No repito la validación funcional de QA. Verifico (a) la superficie de promesas —qué
afirma lo que los proyectos heredan frente a lo que la máquina hace—, (b) el fail-closed de la
herramienta nueva por sondas propias sobre proyectos efímeros del scratchpad, (c) la no-regresión
del mecanismo. `git diff v1.31.0 -- hooks/` = **0 líneas**, confirmado por mí; `tools/` sólo suma
`arnes-paralelo.sh`. Barrido de secretos sobre todo el diff de la ventana: **cero coincidencias**.
Ninguna sonda escribió fuera del scratchpad.

### Hallazgos

#### SEC-014 — `contrato` · **abierto** · REQ-013 · severidad alta · dueño `desarrollador`

**El sexto fail-open de `tools/arnes-paralelo.sh`: un paréntesis intermedio borra el resto del mapa
y la herramienta responde `disjunto` con rc 0.**

`Archivos:` es un valor de **lista**, y se le aplica `arnes_veredicto` (`tools/arnes-paralelo.sh:334`),
que es una regla de **valor único**: si el valor termina en `)`, trunca en el **primer** `(`
(`hooks/lib.sh:1339`, `v="${v%%(*}"`). Todo elemento posterior desaparece **antes** de llegar a
`norm_ruta`, sin motivo, sin bajar el recuento y sin cambiar el código de salida.

Medido (proyecto efímero, `hooks/lib.sh` y `tools/x.sh` reales en el árbol):

| `Archivos:` de REQ-A | REQ-B | Mapa que la herramienta usa | Respuesta | Verdad |
|---|---|---|---|---|
| `tools/x.sh (nuevo), hooks/lib.sh (modificado)` | `hooks/lib.sh` | `tools/x.sh` | `disjunto` · **rc 0** | colisiona |
| `docs/a.md (nuevo), hooks/lib.sh, hooks/guard.sh, tools/x.sh (CI)` | `hooks/lib.sh` | `docs/a.md` | `disjunto` · **rc 0** | colisiona |
| `requirements/README.md (campo Archivos en la cabecera), tools/x.sh (nuevo), hooks/lib.sh (reutilizado)` | `hooks/lib.sh` | `requirements/README.md` | `disjunto` · **rc 0** | colisiona |
| `tools/x.sh (nuevo), hooks/lib.sh` *(sin anotar el último)* | `hooks/lib.sh` | — | `SIN DECLARAR` · rc 1 | **fail-closed, correcto** |
| `hooks/lib.sh, tools/x.sh (medido 6/9)` *(paréntesis final)* | `hooks/lib.sh` | los dos | `colisiona` · rc 1 | **correcto** |

**La asimetría es lo grave y va en la dirección insegura:** anotar *todos* los elementos —lo prolijo—
abre; anotar sólo algunos y dejar el último desnudo cierra. La tercera fila es el `Módulo:` de
**REQ-013 escrito con la sintaxis de `Archivos:`**: la casa ya anota así el campo hermano, y
`templates/requirements-README.md.tpl` enseña «un paréntesis final de evidencia» como tolerancia sin
advertir que uno intermedio destruye la cola. No es una forma exótica: es la primera que se escribirá.

**Criterios que desmiente**, los tres enunciados **por propiedad** y a propósito:
- **CA-13** — «Dado **cualquier** modo en que la herramienta **no pudo medir** …**sin excepción por el
  tipo de impedimento que sea**… lo **dice** con el motivo concreto, sale con código **≠ 0** y **no**
  afirma que ningún par sea disjunto». Aquí no lo dice, sale 0 y afirma `disjunto`.
- **CA-11 (ii)** — «toda forma que no sea una ruta relativa a la raíz se **rechaza con mensaje propio**
  y el REQ pasa a `sin declarar`». `hooks/lib.sh (modificado)` lleva blancos —forma que la propia
  herramienta rechaza cuando le llega— y no se rechaza: se borra.
- **CA-04** — «un valor que no se puede interpretar → `sin declarar`, colisiona con todos, rc ≠ 0».

Por eso es **`contrato`** y no `instrumento`, y no por analogía: es la definición literal del cuadro
de clases —el requerimiento dice algo falso sobre lo construido—. Se distingue de **QA-205**
(`instrumento`), donde CA-11 **dejaba fuera** las tres formas por enumerar; aquí el criterio las
**incluye** por propiedad. Y se distingue por su alcance: QA-205 no cambia el veredicto de ningún REQ
real porque nadie escribe `~` ni enlaces simbólicos; SEC-014 se dispara con la sintaxis que la
plantilla enseña.

**El banco comparte la ceguera:** `secciones/34-arnes-paralelo.sh:136` prueba **sólo** la forma segura
(paréntesis final). Ningún caso cubre la anotación por elemento.

**Remediación (las tres, o el hallazgo no cierra — `AGENTS.md` §9):**
1. **Código.** Ningún elemento declarado puede desaparecer en silencio. La regla del paréntesis, sobre
   un campo de lista, se aplica **después del último separador** y nunca trunca elementos; todo lo que
   quede entre comas pasa por `norm_ruta` y lo que no se entienda manda el REQ a `SIN DECLARAR`.
2. **Criterio.** CA-03 exige «exactamente la misma normalización… la misma función» y es lo que produjo
   el defecto: la regla de veredicto único aplicada a una lista. La tensión CA-03 vs CA-11/CA-13 la
   resuelve el `analista-requerimientos` por escrito (write-back), no el código en silencio.
3. **Herencia.** `templates/requirements-README.md.tpl` §«El mapa de archivos» enseña la tolerancia del
   paréntesis; tiene que decir dónde vale y dónde no. Y el banco gana el caso de la forma que abre.

#### SEC-015 — `contrato` · **abierto** · alcance de la publicación (no de un REQ) · severidad alta · dueño `desarrollador`

**El arnés promete a los proyectos que las reescrituras concurrentes de `docs/ESTADO.md` «no se
corrompen», y está medido que sí.**

`skills/arnes-upgrade/SKILL.md:252`, texto que el agente **le dice al usuario** al actualizar:
«Con agentes en paralelo hay reescrituras concurrentes: **idempotentes, no se corrompen**, pero es un
archivo que él mantiene.» Falso: `hooks/estado-derivado.sh:237` publica por un temporal de **nombre
fijo** (`"$destino.arnes.tmp"`) y con dos paradas simultáneas los dos procesos escriben el mismo
archivo antes del `mv`. QA lo midió: pérdida del texto **humano** de `ESTADO.md` **1 vez de 25**.

**No es regresión de esta ventana** —`git diff v1.31.0 -- hooks/` vacío; el defecto vive en 1.30.3 y
1.31.0 publicadas— y por eso **no bloquea ningún REQ**. Lo que sí es de esta ventana: **REQ-013 existe
para que se despachen comisiones en paralelo**, es decir, esta versión **sube la frecuencia** del
escenario que dispara el defecto mientras el documento que la acompaña afirma que ese escenario es
seguro.

**Autocrítica de este registro:** R-003 miró ese mismo temporal —«el temporal es `"$destino.arnes.tmp"`,
junto al destino y dentro del proyecto»— y lo dio por bueno. Comprobó la **ubicación** y no la
**colisión**. Queda anotado para que la próxima revisión de un `mv` atómico pregunte por el nombre.

**Remediación.** (1) La frase se corrige **antes de publicar 1.32.0**: es una línea, en un archivo que
no es `hooks/`, y publicar `ADR-002` —cuyo asunto es exactamente que una promesa no puede ser más
ancha que la máquina— junto a esta frase es contradictorio. (2) El defecto de código va a **REQ-015 /
1.32.1** como decidió el propietario: temporal de nombre único por proceso más publicación por
`rename`, con `AGENTS.md` §13 y `templates/AGENTS.md.tpl` diciendo qué garantiza y qué no.

#### SEC-016 — `instrumento` · **abierto** · REQ-014 · severidad media-baja · dueño `desarrollador`

**El «límite honesto» de `ADR-002` llegó al criterio y al README del banco, pero no a la superficie
que leen los terceros.**

`ADR-002` estrecha CA-06: la guarda estática es **barandilla y no jaula**. `tests/escenarios/hooks/README.md:100`
lo dice («es una barandilla, no una jaula»). `skills/arnes-upgrade/SKILL.md` —lo único de esto que un
proyecto lee— enuncia la invariante 1 en su forma **ancha**: «El corredor comprueba sobre el texto de
cada archivo que ninguna sección define su propio juez sin guarda», sin límite; y **CA-28** le promete
a quien copie el patrón «las **tres invariantes intactas**».

Reach limitado —ningún proyecto hereda el banco, y la nota es para quien **copie** el patrón—, por eso
`instrumento` y **no bloquea**. Pero es, una carpeta más allá, la misma deriva que `ADR-002` corrige.
**Remediación:** una frase en esa nota. Recomiendo que viaje **en 1.32.0**, con SEC-015, en el mismo
archivo y por la misma causa.

#### SEC-017 — `instrumento` · **abierto** · REQ-013 · severidad baja · dueño `desarrollador`

**Un `Estado:` duplicado cuyo primer valor sea el terminal saca al REQ de la población, sin una
palabra.** `arnes_estado_cabecera` (`hooks/lib.sh:1587`) **retorna en la primera** aparición;
`lee_campo_archivos` (`tools/arnes-paralelo.sh:106`) hace ganar a la **última**, y su propio comentario
declara que dos lectores del mismo campo con precedencias distintas es lo que CA-03 prohíbe. Medido:
`Estado: completado` seguido de `Estado: en-progreso` → «**1 REQ evaluados**», `disjunto`, **rc 0**.
Es la clase de QA-211 por otra puerta. Agravante menor: los REQ saltados por terminales **no se nombran
en la salida**, así que la caída del recuento no es visible.

#### SEC-018 — `instrumento` · **abierto** · REQ-013 · severidad baja · dueño `desarrollador`

**`--json` puede emitir JSON inválido.** `jstr` (`tools/arnes-paralelo.sh:447`) escapa `\` y `"` y **no**
los caracteres de control. Su comentario afirma «sólo `\` y `"` pueden aparecer en una ruta ya
validada», cierto para los patrones declarados y **no** para los motivos ni para las rutas que salen de
expandir contra el árbol. Medido: `Archivos: /tmp/a<TAB>b.sh` → salida que `jq` rechaza («Invalid
string: control characters… must be escaped»). En lo medido rc = 1, así que **no** es fail-open hoy;
lo abro porque el modo JSON es el que consume una máquina y un consumidor que no falle cerrado
convierte esto en uno.

#### SEC-019 — `instrumento` · **abierto** · sin dueño hasta ahora · severidad media

**54 casos del banco (de 735) pasan en verde con el hook al que apuntan reducido a `exit 0`.** Medido
por QA en las vueltas 1 y 2 y registrado **dentro** del párrafo del residual de H-03
(`requirements/REQ-014.md:150`), donde queda como dato de apoyo de otro hallazgo. Es exposición
**preexistente** (`git diff v1.31.0 -- hooks/` vacío) y CA-13 de REQ-014 le prohíbe tocarla, lo cual es
el acotamiento correcto de ese REQ — pero el 7,3 % del banco que no distingue «el mecanismo funciona»
de «el mecanismo no está» **no tiene dueño ni ventana propios**, y el banco es la puerta requerida de
`main` para todos los proyectos que dependen de este plugin. Lo abro para que salga del párrafo ajeno
y reciba dueño y ventana.

### Observaciones sin hallazgo

- **CI (`.github/workflows/banco.yml`).** Sin `permissions:` explícito en el workflow; con
  `on: pull_request` un PR de fork ya corre con token de sólo lectura, pero un `permissions: contents: read`
  al nivel del job lo haría verdadero también para los PR internos. Y `actions/checkout@v4` está anclado
  por **etiqueta**, no por SHA. Las dos son **preexistentes** y no las trae esta ventana.
- **Herencia, `templates/requirements-README.md.tpl`.** El ejemplo «Bien» cita `hooks/guard-git.sh`,
  una ruta del plugin que el árbol de un proyecto consumidor no contiene. Es ilustrativo y sigue la
  convención ya existente de citar `tools/arnes-lectura.sh`; no lo abro, pero es el borde de CA-31.
- **`requirements/README.md`.** La tabla índice sigue declarando REQ-012/013/014 como `pendiente` con
  QA y Seguridad `pendiente`, cuando están `en-revisión` con `QA: aprobado`. Documentación del propio
  repositorio, no heredable.

### Verificaciones de gobernanza de R-004, con su resultado

| Verificación | Resultado |
|---|---|
| **No-regresión del mecanismo** | **Cumple.** `git diff v1.31.0 -- hooks/` = 0 líneas (verificado por mí). `tools/` sólo añade `arnes-paralelo.sh`; `hooks/hooks.json` no lo registra: **0 procesos** añadidos a `Bash`, `Edit`, `Write` ni a la parada |
| **Nada del autoalojamiento filtrado a lo que heredan los proyectos** | **Cumple.** El diff de `agents/` (los tres) y de `templates/AGENTS.md.tpl` y `templates/requirements-README.md.tpl` no introduce **ni un** rol, glob, versión, rigor por defecto, nombre de proyecto consumidor ni cuenta de GitHub de este repositorio. `{{MAX_REINTENTOS}}` se conserva como marcador. La medición «7 de 20 hallazgos» va anonimizada («un ciclo de este arnés») |
| **Ninguna afirmación nueva promete más de lo que la máquina cumple** | **NO cumple del todo.** Tres desvíos: **SEC-014** (la tolerancia del paréntesis, enseñada sin su límite, abre el mapa), **SEC-015** (la promesa de no-corrupción concurrente) y **SEC-016** (la invariante 1 sin su límite honesto). El resto es honesto y lo dice: «es una regla de redacción; la puerta no la comprueba», «su ausencia no bloquea nada», «evalúa archivos y no el orden de fases» |
| **La herramienta no despacha, no es puerta y no escribe** | **Cumple.** Sin `eval`, sin sustitución de comandos, sin redirección a archivo; no invoca agentes ni toca `PENDING_APPROVAL.md` ni ningún REQ. El árbol queda idéntico tras ejecutarla. Sin inyección desde el contenido de un REQ: los patrones se expanden con globbing, nunca se evalúan |
| **La advertencia del orden de fases sale siempre** | **Cumple.** En texto y en JSON, también cuando el veredicto es `colisiona` |
| **Cambio del workflow de CI** | **Seguro.** No añade secretos, ni acciones de terceros, ni `pull_request_target`. `bash -n` no ejecuta; `git ls-files -s` lee el índice. El paso nuevo ejecuta código del propio PR, que el paso preexistente del banco ya ejecutaba: **no abre una clase nueva**. Las dos aserciones nuevas cuadran hoy sobre el árbol (5/5 puntos de entrada `100755`, 37/37 secciones `100644`, `bash -n` en verde) |
| **Repositorio público: sin datos de cliente ni secretos** | **Cumple.** Barrido de credenciales sobre todo el diff de la ventana: cero. `.gitignore` sigue cubriendo `mejoras-arnes-*.md` e `insumos/` |
| **Cola de aprobaciones** | **1** entrada bajo `## Pendientes` (el gate humano del workflow de CI). Correcto: ningún REQ puede pasar a `completado` hoy |
| **Rigor** | Los tres ya son `critico` con `Sensible a seguridad: sí`. **Nada que subir** |

### Dictamen sobre `ADR-002` y el residual de H-03: **se acepta el estrechamiento**

No lo veto, y el argumento no es de conveniencia:

1. **No se debilitó ninguna máquina; se estrechó una promesa hasta hacerla cierta.** La guarda ganó el
   cierre transitivo sobre la cadena de llamadas y su control positivo. Lo que se recortó es la frase.
   Un criterio que promete un guardián que nadie tiene es **más** peligroso que uno que declara su
   límite: alguien lo lee y deja de mirar.
2. **La oración que de verdad protege sigue intacta y verificada por mutación en todos los archivos:**
   JSON vacío es FAIL. Lo que se estrecha es la **segunda** capa.
3. **Es la misma pregunta que `AGENTS.md` §13 ya declaró no ganada** para el detector de escrituras por
   `Bash`, y este repositorio no puede tenerla de las dos maneras. Ensanchar el patrón compraría dos
   **formas** fingiendo comprar la **clase** —una variable, `eval`, una llamada indirecta la
   reproducen— y ya produjo falsos positivos sobre código correcto; un guardián que grita sobre código
   bueno acaba apagado, y uno apagado protege menos que uno parcial.
4. **El residual cumple `AGENTS.md` §6 punto por punto:** forzador **medido** (dos evasiones
   reproducidas, no conjeturadas), dueño **REQ-011**, vencimiento **cierre de 1.33.0** y cláusula de
   no-renovación silenciosa.
5. **El modelo de amenaza está acotado:** sólo alcanza a quien escriba una sección del banco con
   ofuscación deliberada, y quien escribe secciones del banco es este equipo. No hay actor externo en
   esa ruta, ni dinero, ni datos personales; ningún proyecto hereda el banco.

**Suscribo también la reclasificación de H-03 a `instrumento`**, con la **condición que el propio QA
escribió**: es `instrumento` *porque* CA-06 describe hoy su alcance real. **Esa condición no la vigila
ninguna máquina**, así que la registro abajo como estado aprobado: si en una ventana futura el
«límite honesto» de CA-06 desaparece o la promesa se ensancha sin ensanchar la máquina, es
**regresión** y H-03 vuelve a `contrato` sin discusión.

**Lo que el estrechamiento no cubre y queda dicho:** SEC-016 —la promesa ancha sobrevive en la nota
de `arnes-upgrade`— y SEC-019 —los 54 casos—.

### Estado de seguridad aprobado por REQ — ventana 1.32.0

| REQ | Veredicto | Fecha | Versión | Controles acreditados (contra esto se compara la próxima auditoría) |
|---|---|---|---|---|
| **REQ-012** | **`aprobado`** | 2026-09-06 | candidata 1.32.0 (`cand/1.32.0`) | (1) La regla de redacción **no toca la máquina**: ninguno de los 11 elementos de su `Archivos:` vive bajo `hooks/`, `tools/`, `tests/`, `.github/` ni `.arnes/`; 0 procesos añadidos; ninguna llave nueva del manifiesto. (2) Lo que heredan los proyectos —`templates/requirements-README.md.tpl`, `templates/AGENTS.md.tpl`, los tres `agents/*.md`— entra **sin nada del autoalojamiento**: ni roles, ni globs, ni versiones, ni rigor por defecto, ni nombres de proyectos o cuentas. (3) Declara su propio límite en voz alta («es una regla de redacción; la puerta no la comprueba»). (4) `agents/auditor-seguridad.md` gana la obligación de describir **todo control por propiedad**, incluidos los NFR de write-back y los hallazgos de este registro |
| **REQ-013** | **`con-hallazgos`** | 2026-09-06 | candidata 1.32.0 (`cand/1.32.0`) | **No firmo.** **SEC-014** (`contrato`) queda abierto: la herramienta responde `disjunto`/rc 0 sobre un mapa que truncó en silencio, desmintiendo CA-04, CA-11(ii) y CA-13. Sí quedan acreditados y son línea base de no-regresión: (1) el fail-closed por **modo degradado** (sin `jq`, sin manifiesto, sin REQ, REQ ilegible, `Estado:` ausente, marcador de posición) sale por `no_medido`/rc 2 o `SIN DECLARAR`/rc 1, nunca por `disjunto`; (2) la clave del par se **ordena al escribirla**, sin asimetrías; (3) la herramienta **no es puerta**, no despacha, no escribe y no añade procesos; (4) la **advertencia del orden de fases sale siempre**. Si alguno de estos cuatro se debilita en una ventana futura, es regresión |
| **REQ-014** | **`aprobado`** | 2026-09-06 | candidata 1.32.0 (`cand/1.32.0`) | (1) La partición **no pierde poder de medida**: 0 líneas suprimidas o de veredicto cambiado en el inventario frente a v1.31.0, cuadre por archivo **y** total, marca de fin de sección para que una sección muerta no se confunda con una limpia. (2) La invariante «JSON vacío es FAIL» se verifica **por mutación en todos** los archivos, sin cifra en el criterio. (3) La guarda estática propaga «ejecuta un hook» y «lleva guarda» por la **cadena de llamadas** hasta punto fijo, con control positivo y sin falsos positivos. (4) **CA-06 declara su límite honesto** — y esa declaración **es** la condición de que H-03 sea `instrumento`: borrarla o ensanchar la promesa sin ensanchar la máquina es **regresión**. (5) El workflow de CI **endurece**: `bash -n` sobre las 37 secciones y modos en el índice en sus dos mitades (`100755` puntos de entrada, `100644` secciones). Deudas declaradas: **SEC-016**, **SEC-019** |

### Obligación de write-back (`AGENTS.md` §9)

- **SEC-014** no se cierra —ni levanto el `con-hallazgos` de REQ-013— hasta que estén **las tres**
  cosas: el código deja de descartar elementos, el criterio dice cómo se aplica la regla del
  paréntesis a un campo de **lista** (lo escribe el `analista-requerimientos`; hay tensión real entre
  CA-03 y CA-11/CA-13 y la resuelve él, no el código en silencio) y la plantilla heredada deja de
  enseñar la tolerancia sin su límite. Un arreglo que viva sólo en el código es deriva.
- **SEC-015** exige, además del arreglo de código en REQ-015, que `AGENTS.md` §13 y
  `templates/AGENTS.md.tpl` digan qué garantiza la escritura concurrente del bloque derivado y qué no.
- **SEC-016**, **SEC-017**, **SEC-018** y **SEC-019**: deuda `instrumento` con dueño `desarrollador`;
  ventana propuesta **1.33.0**, salvo SEC-016, que recomiendo en 1.32.0 con SEC-015.

### Pendientes que esta firma NO cubre

- **El banco completo en Windows/MSYS**, plataforma del `desarrollador`. Todo lo mío es Linux/WSL2, y
  `AGENTS.md` §7 lo exige antes de pedir la fusión. Es la **tercera** revisión seguida en que no me
  consta. Importa más en esta ventana: **QA-205 (mayúsculas) sube a `contrato`** sobre un sistema de
  archivos que no distinga mayúsculas, y ahí vive el `desarrollador`.
- **CI en verde en el PR** (`hooks-en-linux`), la fusión, el tag `v1.32.0`, la publicación y la
  actualización de la instalación estable: de la coordinadora y del propietario.
- **El bump de `arnes_version` y de los dos manifiestos a `1.32.0`**: hoy declaran `1.31.0`, que es lo
  correcto hoy. Si se olvida, el manifiesto miente sobre qué versión gobierna.
- **REQ-007, REQ-008 y REQ-011**: no llevan mi firma en esta revisión.
- **La eficacia real del despacho en paralelo** (CA-24 de REQ-013: cero conflictos sobre pares
  declarados `disjunto`) sólo se puede medir **usando** la herramienta durante un ciclo. Con SEC-014
  abierto, esa medición no debe empezar.

---

## Re-verificación de R-004 — cierre de hallazgos, candidata 1.32.0 (`cand/1.32.0`) — 2026-09-06

**Mandato distinto del de R-004: se verifica CIERRE, no se vuelve a auditar.** Se comprueban los
hallazgos que R-004 dejó abiertos, con la evidencia de cada uno; lo que aparezca de clase
`usuario/dinero` o `contrato` se reporta, y lo `instrumento` va a deuda de la ventana siguiente sin
gastar presupuesto buscando más. Todo lo medido aquí es Linux/WSL2, sobre proyectos efímeros en el
scratchpad; ninguna sonda escribió en el árbol del repositorio.

### Hallazgo por hallazgo

| Hallazgo | Clase | Estado tras la re-verificación |
|---|---|---|
| **SEC-014** | `contrato` | **EN MITIGACIÓN — no cierra.** Patas 1 (código) y 2 (criterio) **cerradas y medidas**; la pata 3 (**herencia**) está escrita pero **dice lo contrario de lo que hace la máquina** — ver abajo |
| **SEC-015** | `contrato` | **MITIGADO.** La frase de `skills/arnes-upgrade/SKILL.md` dice ahora la verdad, en dos mitades («Sí» / «No»), y no promete de menos |
| **SEC-016** | `instrumento` | **MITIGADO.** El límite honesto llegó a `skills/arnes-upgrade/SKILL.md`, en el mismo párrafo de la invariante 1 |
| **SEC-017** | `instrumento` | **ABIERTO**, registrado en `requirements/REQ-013.md` (cabecera + historial) con clase y dueño `desarrollador`. **Sin ventana escrita** — ver pendientes |
| **SEC-018** | `instrumento` | **MITIGADO.** `--json` sobrevive a `\t`, `\x01`, `\x1f`, `\x7f`, `\` y `"`: `jq -e .` acepta las seis salidas |
| **SEC-019** | `instrumento` | **ABIERTO**, con bloque propio en `requirements/REQ-014.md:187`, dueño `desarrollador`, ventana **1.35.0** y vencimiento medible. Correctamente registrado |
| **SEC-020** *(nuevo)* | `contrato` | **ABIERTO.** Séptimo fail-open de `tools/arnes-paralelo.sh`: el marcado por elemento corrompe el mapa y responde `disjunto`/rc 0 |
| **SEC-021** *(nuevo)* | `instrumento` | **ABIERTO.** Un archivo real cuyo nombre acabe en `)` se reescribe a otra ruta, en silencio |

### SEC-014 — patas 1 y 2 cerradas, pata 3 invertida

**Lo que sí está cerrado, medido en las ocho formas que el arreglo tenía que cubrir** (REQ-A contra
REQ-B, con `hooks/lib.sh`, `tools/x.sh` y `docs/a.md` reales en el árbol del proyecto efímero):

| Forma de `Archivos:` en REQ-A | Antes (R-004) | Ahora |
|---|---|---|
| `tools/x.sh (nuevo), hooks/lib.sh` — paréntesis en la **primera** | `disjunto` · rc 0 | **`colisiona hooks/lib.sh` · rc 1**, mapa completo |
| `docs/a.md, hooks/lib.sh (modificado), tools/x.sh` — **intermedia** | `disjunto` · rc 0 | **`colisiona`** · rc 1, los tres elementos en el mapa |
| `hooks/lib.sh, tools/x.sh (medido 6/9)` — **última** | correcto | correcto, sin regresión |
| `docs/a.md (nuevo), hooks/lib.sh (mod), tools/x.sh (CI)` — **todas** | `disjunto` · rc 0 | **`colisiona`** · rc 1, los tres elementos |
| `hooks/lib.sh (medido el 6/9, 2 archivos), tools/x.sh` — **coma dentro** del paréntesis | — | **`colisiona`** en las dos direcciones; la coma de la evidencia no parte la lista |
| `hooks/lib.sh (mod, tools/x.sh` — paréntesis **sin cerrar** | — | **`SIN DECLARAR` con motivo propio** · colisiona con todos |
| `hooks/lib.sh, (medido 6/9)` — anotación **suelta** entre comas | — | **`SIN DECLARAR` con motivo propio** · colisiona con todos |
| `docs/nota (v2).md` — **archivo real** con paréntesis en el nombre | — | **`SIN DECLARAR` con motivo propio** · efecto lateral declarado en el código, dirección segura |

El banco recoge la propiedad, no sólo el caso: `secciones/35-arnes-paralelo-fail-open.sh:337` mide el
veredicto en **las dos direcciones** y `:344` mira el **mapa** —los dos elementos, en orden, y nada
más en la línea—, que es lo que impide acertar por el camino equivocado declarando el REQ ilegible.

**La pata 3 no cierra, y no por omisión: por inversión.** `requirements/README.md:151` y
`templates/requirements-README.md.tpl:151` —el archivo que **heredan todos los proyectos**— dicen
hoy:

> «**Anotar elemento por elemento —`tools/x.sh (nuevo), hooks/lib.sh (modificado)`— no es una forma
> admitida:** un elemento con paréntesis no es una ruta, la herramienta lo **dice con su motivo** y el
> REQ pasa a `sin declarar`, que colisiona con todos.»

Es **falso sobre lo construido**: esa línea exacta es la primera fila de la tabla de arriba y la
herramienta la **lee**, declarando los dos archivos. La nota describe la variante que este registro
propuso al despachar la comisión —«la regla vale sólo tras el último separador»—, no el CA-03 que el
analista escribió y que el código implementa. Mi condición de cierre de R-004 era «la plantilla
heredada deja de enseñar la tolerancia sin su límite»: hay un límite escrito, pero es el de otra
máquina. Dirección del error: la documentación es **más estrecha** que el código, así que no produce
un `disjunto` falso; lo que produce es que el documento que gobierna cómo se escribe el campo mienta
sobre la máquina, en la ventana cuyo tema es `ADR-002` —ninguna afirmación más ancha que lo
construido—, y que quien «arregle» el código para que cuadre con la nota **regrese SEC-014 entero**.

**Remediación (write-back del `analista-requerimientos`, `AGENTS.md` §9):** el párrafo de
`requirements/README.md` y de `templates/requirements-README.md.tpl` dice lo que CA-03 exige —la
evidencia es **de cada elemento**, en cualquier posición; la coma **dentro** de un paréntesis no
separa; una anotación **suelta** entre comas y un paréntesis **sin cerrar** salen `sin declarar` con
su motivo— y declara el residual del párrafo siguiente. Mientras la nota diga lo contrario, SEC-014
sigue **abierto** y REQ-013 no lleva mi firma.

### Juicio sobre el grano «por elemento» — de acuerdo, y con las dos superficies que abre dichas

**Estoy de acuerdo con la decisión del `desarrollador`, y la precedencia que aplicó es la correcta.**
Mi instrucción al despachar era un **mecanismo**; CA-03, reescrito por el analista, es el
**contrato** — y la remediación 2 de SEC-014 pedía exactamente eso: que la tensión CA-03 vs
CA-11/CA-13 la resolviera el analista por escrito y no el código en silencio. Implementar el criterio
y **declararlo** es cumplir la regla, no saltársela. En el fondo también tiene razón: mi variante
habría **rechazado** la forma prolija —la que la plantilla enseñaba— convirtiéndola en un
`sin declarar` permanente, y no satisface la verificación **por conteo** que CA-03 exige, porque un
rechazo no evalúa elementos: los deja de evaluar.

**Y sí abre dos superficies que la mía no abría. Las dos, medidas:**

1. **La coma deja de ser un separador incondicional.** Para no partir `(medido el 6/9, 2 archivos)`
   hay ahora una profundidad de paréntesis (`tools/arnes-paralelo.sh:381`). Consecuencia medida:
   `Archivos: docs/a.md (nota, hooks/lib.sh)` declara **sólo** `docs/a.md` y responde `disjunto`/rc 0
   frente a un REQ que declare `hooks/lib.sh`. Con mi variante esa cadena se habría partido por esa
   coma y la cola `hooks/lib.sh)` habría caído en `sin declarar` — **fail-closed**. Aquí no es un
   fallo: es la convención —lo que va dentro del paréntesis es **evidencia**, no declaración— y la
   dirección la fija esa convención, no la máquina. **Residual aceptado**, con una condición: la
   convención tiene que estar **escrita donde se escribe el campo**, y hoy ese párrafo dice otra cosa
   (pata 3 de SEC-014). Sin esa frase, el residual no está aceptado: está escondido.
2. **La regla del paréntesis se aplica en todas las posiciones, no sólo en la última.** Lo que antes
   sólo podía pasarle al último elemento le puede pasar ahora a cualquiera. En la forma segura eso es
   justo lo que se quería; en el borde produce SEC-021.

**Lo que NO es culpa del grano por elemento:** el fail-open que abro abajo (SEC-020) vive en el
`arnes_desenvuelve` **del valor entero** (`tools/arnes-paralelo.sh:329`), que es anterior a la
separación y que CA-03 no autoriza en ese punto — mi variante lo habría tenido igual.

### La propiedad declarada, puesta a prueba: la entrada que la viola

CA-03 declara «**ningún elemento declarado desaparece nunca en silencio**» y la verifica **por
conteo**. La entrada que la viola pasa el conteo:

```
REQ-A ->  Archivos: `hooks/lib.sh`, `tools/x.sh`      (acentos graves POR ELEMENTO)
REQ-B ->  Archivos: hooks/lib.sh
Respuesta: disjunto · rc 0        Verdad: colisionan en hooks/lib.sh
Mapa que la herramienta usó:  «hooks/lib.sh`»   «`tools/x.sh»
```

El **conteo cuadra** —dos elementos declarados, dos evaluados— y aun así **los dos archivos
declarados desaparecen del mapa**, sustituidos por dos fantasmas que no existen ni casan con nada, sin
motivo y sin bajar el recuento. La lección para el criterio: la verificación por conteo es
**necesaria y no suficiente**; la propiedad que hay que medir es que **ningún archivo declarado
desaparece**, y eso sólo lo ve la comprobación del **mapa** (la de `:344`), que hoy no cubre el
marcado.

### SEC-020 — `contrato` · **abierto** · REQ-013 · severidad alta · dueño `desarrollador`

**Séptimo fail-open de `tools/arnes-paralelo.sh`: el marcado de Markdown escrito POR ELEMENTO
corrompe todas las rutas del mapa y la herramienta responde `disjunto` con rc 0.**

`tools/arnes-paralelo.sh:329` aplica `arnes_desenvuelve` al **valor entero antes de separar la
lista**. Cuando el valor empieza y acaba con el mismo marcador —que es lo que pasa siempre que el
marcado se pone **elemento por elemento**— esa pasada arranca el par **exterior**, que pertenece a
dos elementos distintos, y deja a los de dentro con un marcador impar. El desenvoltorio **por
elemento** de `norm_ruta:153` ya no puede repararlo (el marcador quedó sin pareja) y `norm_ruta` lo
acepta como **ruta futura literal**: tiene extensión, así que pasa la propiedad de «no designa nada».

Medido, con `hooks/lib.sh`, `tools/x.sh` y `docs/a.md` reales en el árbol:

| `Archivos:` de REQ-A | REQ-B | Mapa usado | Respuesta | Verdad |
|---|---|---|---|---|
| `` `hooks/lib.sh`, `tools/x.sh` `` | `hooks/lib.sh` | ``hooks/lib.sh` `` · `` `tools/x.sh `` | **`disjunto` · rc 0** | colisiona |
| `_hooks/lib.sh_, _tools/x.sh_` | `hooks/lib.sh` | `hooks/lib.sh_` · `_tools/x.sh` | **`disjunto` · rc 0** | colisiona |
| `` `docs/a.md`, `hooks/lib.sh`, `tools/x.sh` `` | `tools/x.sh` | `docs/a.md`` · `hooks/lib.sh` · `` `tools/x.sh `` | **`disjunto` · rc 0** | colisiona |
| `` `docs/a.md`, `hooks/lib.sh`, `tools/x.sh` `` | `hooks/lib.sh` | igual que arriba | `colisiona` · rc 1 | correcto **por casualidad**: el elemento del **medio** conserva su par |
| `**hooks/lib.sh**, **tools/x.sh**` | `hooks/lib.sh` | `hooks/lib.sh**` · `**tools/x.sh` | `colisiona` · rc 1 | correcto **por accidente**: `*` es un carácter de glob y la expansión contra el árbol vuelve a casar |
| `` `hooks/lib.sh`, tools/x.sh `` — marcado **sólo en el primero** | `hooks/lib.sh` | los dos, limpios | `colisiona` · rc 1 | correcto |

Los dos aciertos son casualidad de la forma, no de la regla: `*` y `**` se salvan porque son globs, y
el elemento intermedio se salva porque el par que se arranca es el exterior. Los acentos graves y el
subrayado —que **no** son caracteres de glob— abren.

**Criterios que desmiente** —los mismos tres de SEC-014, por eso es la misma clase y no `instrumento`:
- **CA-03** — fija el **orden obligado**: (1) recorte de cabecera y desenvoltura de **la clave** sobre
  el texto del campo, (2) **separación de la lista**, (3) la normalización de **valor** —blancos y
  marcado— **a cada elemento**. La pasada de `:329` desenvuelve el **valor** en el paso (1), que es
  justo donde el criterio no la pone, y es la que corrompe.
- **CA-11 (ii)** — «toda forma que no sea una ruta relativa a la raíz se **rechaza con mensaje
  propio** y el REQ pasa a `sin declarar`». ``hooks/lib.sh` `` con un acento grave impar no es una
  ruta y no se rechaza: se acepta como literal futuro.
- **CA-13** — la herramienta **no pudo medir** y no lo dice, sale 0 y afirma `disjunto`.

**Y la forma no es exótica:** `requirements/README.md` admite «el valor entre acentos graves» como
tolerancia, CA-03 manda aplicar el desenvoltorio **por elemento**, y este repositorio escribe cada
ruta entre acentos graves en todas sus prosas. Escribir `` Archivos: `a.sh`, `b.sh` `` es al menos tan
natural como envolver la línea entera. **El banco comparte la ceguera** de nuevo, y por el mismo
sitio: `secciones/34-arnes-paralelo.sh:128` prueba el acento grave **sólo en el primer elemento** —la
única colocación que no dispara el defecto—.

**Remediación (las dos, o el hallazgo no cierra):**
1. **Código, enunciado por propiedad y no por caso:** después de la normalización, **un elemento que
   conserve un marcador de marcado impar no es una ruta** y sale con su motivo, exactamente como ya
   hace el paréntesis en `norm_ruta:171`. Ensanchar el desenvoltorio para que «entienda» el marcado
   por elemento sin fallar cerrado compraría formas, no la clase. Si se prefiere, la alternativa
   equivalente es no desenvolver el **valor** antes de separar (CA-03 no lo pide ahí) y fallar cerrado
   sobre el marcador impar que quede; hay que conservar el caso de la lista envuelta **entera**
   (`` `a.sh, b.sh` ``), que hoy funciona.
2. **Banco:** los casos que faltan son las colocaciones que abren —acento grave y subrayado en
   **todos** los elementos, y en el **primero y el último** de tres—, medidos sobre el **mapa** y en
   las dos direcciones, no sólo sobre el veredicto.

### SEC-021 — `instrumento` · **abierto** · REQ-013 · severidad baja · dueño `desarrollador`

**Un archivo real cuyo nombre acabe en `)` se reescribe a otra ruta, en silencio.** La regla del
paréntesis se aplica ahora a cada elemento, así que `Archivos: docs/x (1)` —con `docs/x (1)` existiendo
de verdad— declara `docs/x`. El elemento no desaparece (el conteo cuadra) pero **el archivo declarado
sí**: se sustituye por una ruta que no existe. Medido: contra `docs/*` sale `colisiona`, que es la
dirección segura, y por eso es `instrumento` y no bloquea. Su hermano cerrado va en la dirección
correcta: `docs/nota (v2).md` —paréntesis que no está al final— sale `SIN DECLARAR` **con motivo**.
La asimetría entre los dos es lo que conviene arreglar cuando se toque SEC-020, y el arreglo es el
mismo: lo que tras la regla siga sin designar el archivo declarado se **dice**.

### Estado de seguridad aprobado por REQ — re-verificación de la ventana 1.32.0

| REQ | Veredicto | Fecha | Versión | Motivo / controles acreditados |
|---|---|---|---|---|
| **REQ-012** | **`aprobado`** | 2026-09-06 | candidata 1.32.0 (`cand/1.32.0`) | Se **confirma** el `aprobado` de R-004: ninguno de sus controles acreditados se ha debilitado, y nada de lo re-verificado aquí toca sus criterios. El párrafo falso de `requirements/README.md:151` es entrega de **REQ-013** (CA-31), no suya |
| **REQ-013** | **`con-hallazgos`** | 2026-09-06 | candidata 1.32.0 (`cand/1.32.0`) | **No firmo, por dos causas independientes.** **SEC-014** sigue abierto por su pata de **herencia**: el documento que heredan los proyectos afirma que la herramienta **rechaza** la anotación por elemento y la herramienta la **lee**. **SEC-020** (`contrato`, nuevo): el marcado por elemento produce `disjunto`/rc 0 sobre un mapa corrompido, desmintiendo CA-03, CA-11 (ii) y CA-13. **Sí quedan acreditados y son línea base de no-regresión**, además de los cuatro de R-004: (5) la separación de la lista respeta la **coma dentro de la evidencia**; (6) la anotación **suelta** y el paréntesis **sin cerrar** salen `SIN DECLARAR` **con motivo propio**, nunca en silencio; (7) `--json` es JSON válido con caracteres de control (SEC-018) |
| **REQ-014** | **`aprobado`** | 2026-09-06 | candidata 1.32.0 (`cand/1.32.0`) | Se **confirma** el `aprobado` de R-004 y se **cierra SEC-016**: `skills/arnes-upgrade/SKILL.md` enuncia ahora la invariante 1 con su límite —«la comprobación es **estática y sobre funciones**… una **barandilla contra el descuido, no una jaula**»— y remite a `ADR-002`; la promesa a quien copie el patrón deja de ser más ancha que la máquina. Los cinco controles acreditados en R-004 siguen intactos. Deuda declarada que **no** bloquea: **SEC-019** (dueño `desarrollador`, ventana 1.35.0, vencimiento medible) |

### Comprobación de SEC-015, con su texto

`skills/arnes-upgrade/SKILL.md:254-266` sustituye «idempotentes, no se corrompen» por dos mitades
nombradas. **Es cierta, y no promete de menos:** el «**Sí**» sigue acreditando lo que la máquina
hace —bloque derivado, se recalcula entero del disco, sólo entre marcadores, `mv` sobre el destino
para que una parada **aislada** no deje el archivo a medias—, y el «**No**» declara el defecto con su
medida (**1 de 25** paradas simultáneas perdió el texto humano), su causa (**temporal de nombre
fijo**), la mitigación mientras tanto (versionar `docs/ESTADO.md` o apagar el bloque durante el
paralelo) y la ventana del arreglo (**REQ-015 / 1.32.1**). Es exactamente el tipo de frase que
`ADR-002` pide: ni una palabra más ancha que la máquina, ni una más estrecha.

### Pendientes que esta re-verificación NO cubre

- **QA no ha validado el árbol actual.** El `QA: aprobado` de la vuelta 3 se emitió sobre un banco de
  **735** casos (`docs/qa/1.32.0-hallazgos-req012-013.md:1157`); el arreglo posterior de SEC-014 y
  SEC-018 lo dejó en **742** y cambió `tools/arnes-paralelo.sh`, `requirements/README.md` y
  `templates/requirements-README.md.tpl`. Aunque SEC-014 y SEC-020 no existieran, **mi firma sobre
  REQ-013 sería inválida por orden** (`AGENTS.md` §6): acreditaría un árbol que la puerta de calidad
  no ha visto. El delta necesita un pase de QA. Dato, no veredicto: el banco corre hoy en verde en
  Linux —`741 PASS, 0 FAIL, 1 SKIP`, rc 0—, lo cual no sustituye ese pase.
- **SEC-017 no tiene ventana escrita.** Clase y dueño (`desarrollador`) sí constan en
  `requirements/REQ-013.md`; la ventana que R-004 propuso (**1.33.0**) no aparece en ningún artefacto.
  Una deuda sin ventana es una deuda sin vencimiento.
- **`Hallazgos abiertos:` de los REQ, al día:** REQ-013 aún declara `SEC-018 (instrumento)`, que aquí
  queda **mitigado**, y le faltan `SEC-020 (contrato)` y `SEC-021 (instrumento)`; REQ-014 aún declara
  `SEC-016 (instrumento)`, también **mitigado**. Lo escribe el `analista-requerimientos`; yo no toco
  `requirements/`.
- **El banco completo en Windows/MSYS**, plataforma del `desarrollador`: sigue sin constarme. Es la
  **cuarta** revisión seguida. Con QA-205 subiendo a `contrato` sobre un sistema de archivos que no
  distinga mayúsculas, importa más en esta ventana que en las anteriores.
- **CI (`.github/workflows/banco.yml`) — se confirma el dictamen de R-004.** El cambio no ha variado
  desde entonces y **endurece**: `bash -n` sobre `hooks/`, `tools/` y las 37 secciones (una sección
  con sintaxis rota no falla, **desaparece**), y el bit de ejecución comprobado en sus **dos**
  mitades (`100755` los puntos de entrada, `100644` las secciones, para que nadie corra una sección
  suelta sin ayudantes ni canario y la vea verde). **No hay objeción de seguridad a ese cambio.** Las
  dos observaciones de R-004 siguen siendo **preexistentes** y **no las trae esta ventana**: no hay
  `permissions:` explícito en el workflow (un `contents: read` a nivel de job lo haría verdadero
  también para los PR internos) y `actions/checkout@v4` está anclado por **etiqueta**, no por SHA.
  Ninguna de las dos bloquea la aprobación por delegación.

## Revisión R-006 — cierre de la pata 3 de SEC-014 y firma final de la ventana 1.32.0 (`cand/1.32.0`) — 2026-09-06

**Alcance declarado, y por qué es estrecho:** verificación de **cierre**, no auditoría nueva. Se
comprueba (1) que el párrafo heredado del campo `Archivos:` dice **lo que la máquina hace**,
ejecutando; (2) que el párrafo del límite no promete nada en ninguna dirección; (3) que lo que cruza
la ventana está registrado con **clase, dueño y ventana**; y (4) que ningún control acreditado en
R-004/R-005 se ha debilitado. Lo que esta revisión **no** rehace: el análisis de código de
`tools/arnes-paralelo.sh` (R-004, R-005), el banco caso a caso y las quality gates, que son de QA.

### Pata 3 de SEC-014 — **CERRADA**, verificada ejecutando

La condición que R-005 dejó escrita era: «la plantilla deja de enseñar la tolerancia sin su límite».
`requirements/README.md:151-163` y `templates/requirements-README.md.tpl:151-163` son ahora **dos**
bloques, y los dos archivos son **byte a byte idénticos** en ese tramo (`diff` vacío en 140-170): lo
que se lee aquí es exactamente lo que hereda un proyecto.

**Bloque 1 — cada afirmación, contrastada contra la herramienta** (proyecto de prueba con
`hooks/lib.sh`, `hooks/guard.sh`, `tools/x.sh` y `tools/arnes-lectura.sh` reales; `--json`):

| Afirmación del párrafo | Sonda | Resultado medido |
|---|---|---|
| Anotar elemento por elemento **sí es admitida**, declara **dos** archivos | `tools/x.sh (nuevo), hooks/lib.sh (modificado)` | `archivos:["tools/x.sh","hooks/lib.sh"]` |
| …y **colisiona con quien declare cualquiera de los dos** | vs `hooks/lib.sh` · vs `tools/x.sh` | `colisiona`/rc 1 en **ambos**; vs `hooks/guard.sh` `disjunto`/rc 0 |
| La evidencia vale en la **primera**, una **intermedia**, la **última** o **todas** | las cuatro colocaciones, con 2 y 3 elementos | conteo evaluado = conteo declarado en las **cuatro** |
| `hooks/lib.sh, tools/arnes-lectura.sh (medido el 6/9)` declara **dos**, no tres | idem | `["hooks/lib.sh","tools/arnes-lectura.sh"]` |
| Dentro de un paréntesis **la coma no separa** | `hooks/lib.sh (medido el 6/9, 2 archivos), tools/x.sh` | **2** elementos, `disjunto` correcto |
| Lo que va **dentro** del paréntesis **no declara nada** | `hooks/lib.sh (junto a tools/arnes-lectura.sh, ver nota), tools/x.sh` vs `tools/arnes-lectura.sh` | `disjunto`: la ruta de dentro **no** entra al mapa |
| Un paréntesis **sin cerrar** se **dice con su motivo** → `SIN DECLARAR` | `hooks/lib.sh (x, tools/x.sh` | `declarado:false` + motivo nombrando el paréntesis; `colisiona`/rc 1 |
| Una anotación **suelta** entre dos comas, igual | `hooks/lib.sh, (medido el 6/9), tools/x.sh` | `declarado:false` + motivo propio; `colisiona`/rc 1 |
| `SIN DECLARAR` **colisiona con todos**, nunca `disjunto` | tres REQ, uno sin campo | salida literal `SIN DECLARAR … (colisiona con todos)`, 2 pares `colisiona`, rc 1 |
| El campo vale **sólo en la cabecera** | `Archivos:` debajo del primer `## ` | no se lee: `no declara el campo` + colisiona |
| Envolver la **línea entera** sí se lee bien | `` `hooks/lib.sh, tools/x.sh` `` | dos rutas correctas; colisión real detectada nombrando `tools/x.sh` |
| Ruta **absoluta** fuera de la forma | `/home/…/hooks/lib.sh` | rechazada con motivo; `colisiona`/rc 1 |
| `(ninguno)` es **declaración**, no omisión | `(ninguno)` vs `hooks/lib.sh` | `declarado:true`, `archivos:[]`, `disjunto`/rc 0 |

**Trece afirmaciones, trece medidas coincidentes. El bloque 1 dice la verdad.** Y dice la que
importaba: la nota anterior afirmaba que la anotación por elemento «no es una forma admitida», de
modo que el riesgo no era un falso `disjunto` sino que alguien «arreglara» el código para cuadrar con
la nota y **regresara SEC-014 entero**. Ese riesgo queda retirado.

**Bloque 2 — no promete en ninguna dirección, y es un fallo declarado.** Dice «**no es fiable
hoy**», nombra la causa (el desenvoltorio arranca el par **exterior**, que pertenece a dos elementos
distintos), nombra el hallazgo (**SEC-020**, `contrato`, **abierto**, ventana **1.33.0**), escribe
literalmente «**no es una promesa de la máquina en ninguna dirección —es un fallo declarado, no una
regla**» y da la conducta: ruta **desnuda**, y un `disjunto` sobre campo decorado **no se toma por
bueno**. Reproducido: `` `hooks/lib.sh`, `tools/x.sh` `` → mapa `["hooks/lib.sh`","`tools/x.sh"]`,
`disjunto`/rc 0 **contra un REQ que declara `hooks/lib.sh`**; idéntico con `_a_, _b_`. La descripción
del bloque 2 coincide con lo medido, ni una palabra más ancha ni más estrecha.

**Consecuencia de no-regresión, y es la condición de que la nota sea honesta:** el bloque 1 enuncia
«lo que no se entiende … **nunca** `disjunto`» como propiedad, y bajo SEC-020 esa propiedad tiene
**una** excepción — la que el bloque 2 declara **a continuación**. Los dos bloques son honestos
**juntos**; separarlos, mover el bloque 2 a otro documento o borrarlo cuando SEC-020 se cierre **sin**
que el código lo cierre **regresa la pata 3**. Queda anotado como remediación 3 de SEC-020.

### Respuesta a la pregunta de la instrucción heredada: **acotar basta; suspender empeoraría**

`AGENTS.md:136-153` y `templates/AGENTS.md.tpl:102-119` son idénticos en ese tramo y conservan la
instrucción («**sólo** despacha en paralelo lo que la herramienta declare disjunto») más el límite
(«necesaria y no suficiente»). **Me basta**, por tres razones medidas y no por criterio:

1. **Suspenderla devolvería el despacho a la intuición, que no tiene fail-closed ninguno.** El
   fail-open de SEC-020 es **una forma** del campo; el resto del espacio —sin campo, valor ilegible,
   marcador de posición, `Estado:` ausente, REQ ilegible, paréntesis roto, ruta absoluta— sigue
   saliendo `SIN DECLARAR`/rc 1 o `no_medido`/rc 2, verificado arriba y en R-004. Cambiar «pregunta
   siempre, y desconfía de un campo decorado» por «no preguntes» retira la parte que funciona.
2. **La segunda condición es inspeccionable, no un juicio.** «El campo no lleva marcado por
   elemento» se mira; no hay que estimar nada. Un límite que exige criterio sí habría que suspenderlo.
3. **El coste de equivocarse es un conflicto de fusión, no una firma falsa.** Verificado: **nada
   automático la consume** —0 referencias en `hooks/hooks.json`, ningún otro invocador en el árbol—,
   no es puerta, no despacha y no escribe; y las dos reglas cuyo incumplimiento **sí** produce una
   firma falsa (orden de fases) están escritas como **no relajables en ningún caso** y no dependen de
   la herramienta, que además lo dice en su propia salida.

**Lo que sí exige el acotamiento, y es su condición de validez:** vive **adyacente** a la
instrucción, en los dos documentos. Retirar el aviso dejando la instrucción es la asimetría que
convierte una barandilla en una promesa.

### Lo que cruza la ventana: clase, dueño y ventana

| Hallazgo | Clase | Dueño | Ventana | Dónde consta |
|---|---|---|---|---|
| **SEC-020** | `contrato` · abierto | `desarrollador` | **1.33.0** | `AGENTS.md:146`, `templates/AGENTS.md.tpl:112`, `requirements/README.md:168`, `templates/requirements-README.md.tpl:168`, `CHANGELOG.md:26`, y §SEC-020 de este registro |
| **SEC-021** | `instrumento` · abierto | `desarrollador` | **1.33.0**, con SEC-020 (se fija aquí) | §SEC-021 de este registro; **no consta en ningún otro artefacto** |
| **SEC-017** | `instrumento` · abierto | `desarrollador` | **1.33.0** | **ventana ya escrita**: `CHANGELOG.md:125`; clase y dueño en `requirements/REQ-013.md:10` y §SEC-017 |
| **SEC-019** | `instrumento` · abierto | `desarrollador` | **1.35.0** | `requirements/REQ-014.md:187` + `CHANGELOG.md:126` |

- **SEC-017: el aviso de R-005 queda RESUELTO.** Ya tiene ventana escrita (`CHANGELOG.md:125`,
  «1.33.0»). Era la única deuda sin vencimiento y deja de serlo.
- **SEC-021: le fijo la ventana aquí, porque faltaba.** Su bloque decía «conviene arreglarlo cuando se
  toque SEC-020» y eso es una dependencia, no un vencimiento: **1.33.0**, con SEC-020 y por el mismo
  arreglo (lo que tras aplicar la regla del paréntesis siga sin designar el archivo declarado **se
  dice**). Sigue siendo `instrumento` y en dirección segura (`colisiona`).
- **SEC-020 está registrado en cinco artefactos, incluidos los dos heredados; SEC-021, sólo aquí.**
  Para un `instrumento` de severidad baja lo acepto, pero lo dejo dicho.
- **Write-back pendiente (`AGENTS.md` §9), y no lo escribo yo:** `requirements/REQ-013.md:10` declara
  `SEC-014 (contrato), SEC-017, SEC-018` y **le faltan `SEC-020 (contrato)` y `SEC-021
  (instrumento)`**; además sigue declarando `SEC-018`, que quedó **mitigado**, y `REQ-014.md:10`
  declara `SEC-016`, también **mitigado**. `CHANGELOG.md:41` afirma «SEC-020 sigue declarado abierto»
  y en la cabecera del REQ **no está declarado**. No abre nada —la puerta ya deniega el cierre por
  `SEC-014 (contrato)`— pero es deriva y es la causa por la que REQ-013 no lleva firma.

### Remediación 3 de SEC-020 (nueva, documental)

Cuando el código cierre SEC-020, la nota heredada se toca **en este orden y no en el contrario**:
primero el código deja de responder `disjunto` sobre un marcador impar, y sólo entonces desaparece el
bloque 2. Borrar el bloque 2 antes es regresar la pata 3 con el signo invertido —esta vez hacia el
lado que **abre**—.

### SEC-022 — `instrumento` · **abierto** · REQ-013 · severidad media · dueño `desarrollador` · ventana **1.32.0 (una frase) o 1.33.0**

**La nota de `arnes-upgrade` —la única superficie que un proyecto lee para saber qué cambia— presenta
la herramienta nueva como fail-closed y NO menciona su fail-open abierto.**
`skills/arnes-upgrade/SKILL.md:536-546` anuncia el campo `Archivos:` y afirma en 544 «**El
fail-closed vive en la herramienta**, donde el coste de equivocarse es volver a la serie», sin una
palabra sobre SEC-020: `grep` de `SEC-020`, `decorado`, `sin decoración` y `acentos graves` en ese
archivo no devuelve **nada** del tramo. `requirements/README.md` y `AGENTS.md` sí llevan el límite y
también se heredan, así que la información existe —pero en la superficie que se lee **al decidir
actualizar** la promesa es más ancha que la máquina.

**Es la tercera vez en esta misma ventana y en el mismo archivo:** SEC-015 (la no-corrupción
concurrente) y SEC-016 (el límite de la guarda estática) eran esta clase exacta y se corrigieron
**antes de publicar**, con una frase cada una. Por eso la clase: `instrumento` —igual que SEC-016, y
por el mismo motivo: la consecuencia es un conflicto de fusión en el trabajo del propio proyecto, no
pérdida de datos, ni una puerta evadida, ni una firma falsa—; y por eso la severidad **media** y no
baja: la reincidencia dice que la superficie se actualiza con lo que la ventana **añade** y no con lo
que la ventana **debe** al usuario.

**Remediación (una frase, sin código y sin pase de QA nuevo):** en el punto de `SKILL.md` que dice
que el fail-closed vive en la herramienta, añadir el límite con su causa y su ventana —el marcado de
Markdown **por elemento** en el campo produce `disjunto`/rc 0 sobre un mapa corrompido (**SEC-020**,
abierto, 1.33.0); las rutas se escriben **sin decoración** y un `disjunto` sobre campo decorado no
autoriza nada—. **No bloquea la publicación** (`instrumento`), y lo recomiendo **antes del tag** por
el precedente de sus dos hermanas.

### No-regresión, medida hoy sobre `cand/1.32.0`

- **`git diff --exit-code v1.31.0 -- hooks/` → rc 0: el mecanismo que gobierna a los demás proyectos
  es byte a byte el publicado.** Es el hecho más importante de esta firma: esta ventana no cambia
  **ningún** veredicto de `guard-codigo` ni de `guard-completado`. Confirma CA-02-bis.
- **Banco completo: `741 PASS · 0 FAIL · 1 SKIP`, rc 0** (el SKIP es el caso de contrabarras, de otra
  plataforma), en dos corridas; y deja el árbol **idéntico** (`git status` sin cambios no previstos).
  Coincide con lo declarado en `CHANGELOG.md`. Los cinco casos `paralelo/SEC-014` —incluida la
  anotación suelta y la coma dentro de la evidencia, en los dos órdenes— salen PASS.
- **Autoprueba del corredor: `73 PASS · 0 FAIL`.**
- **Quality gates del manifiesto:** `bash -n` en verde sobre los 10 `hooks/*.sh` y `tools/*.sh`;
  `jq -e` en verde sobre `hooks/hooks.json`, `plugin.json` (versión **1.32.0**) y `marketplace.json`.
- **CI (`.github/workflows/banco.yml`):** conserva el endurecimiento acreditado en R-004/R-005
  —`bash -n` sobre `hooks/`, `tools/` y el banco entero, y el bit de ejecución en sus **dos** mitades
  (`100755` los tres puntos de entrada, `100644` las secciones)—. Verificado además que los tres
  puntos de entrada están hoy en `100755`.
- **Documentación heredada, sin supresiones:** `git diff HEAD --stat` sobre `AGENTS.md`,
  `requirements/README.md`, `templates/` y `agents/` da **430 inserciones y 0 supresiones**. Ni una
  línea de la línea base publicada se retiró: no hay regresión de herencia. El añadido a
  `agents/auditor-seguridad.md` (un control se describe **por propiedad**, nunca por enumeración)
  **endurece** mi propio mandato y no lo relaja.
- **Controles de R-004/R-005 que sigo acreditando intactos:** el fail-closed por modo degradado
  (`no_medido`/rc 2 y `SIN DECLARAR`/rc 1, nunca `disjunto`), la clave del par ordenada al escribirla,
  «no es puerta / no despacha / no escribe», la advertencia del orden de fases **siempre** en la
  salida, la coma dentro de la evidencia, el motivo propio de la anotación suelta y del paréntesis sin
  cerrar, y `--json` válido con caracteres de control. Debilitar cualquiera es regresión.

### Estado de seguridad aprobado por REQ — firma final de la ventana 1.32.0

| REQ | Veredicto | Fecha | Versión | Motivo / controles acreditados |
|---|---|---|---|---|
| **REQ-012** | **`aprobado`** | 2026-09-06 | candidata 1.32.0 (`cand/1.32.0`) | Tercera confirmación (R-004, R-005, R-006). Su sección de `requirements/README.md` se hereda **idéntica** en `templates/requirements-README.md.tpl` (el único diff del archivo son el marcador de nombre, el índice de REQ y el párrafo de adopción, que son propios de este repo); `0 supresiones` en toda la documentación heredada; los tres agentes que la aplican reciben cambios **aditivos**. Los dos bloques reescritos del campo `Archivos:` son entrega de **REQ-013** (CA-31) y **cumplen** su regla: enuncian la propiedad primero y marcan los ejemplos como ilustración. **Hallazgos abiertos: (ninguno).** |
| **REQ-013** | **`con-hallazgos`** | 2026-09-06 | candidata 1.32.0 (`cand/1.32.0`) | **No firmo, y no es por la pata 3: ésa queda CERRADA** (trece afirmaciones verificadas ejecutando; ver arriba). No firmo por **SEC-020** (`contrato`, abierto): el marcado por elemento produce `disjunto`/rc 0 sobre un mapa corrompido, desmintiendo CA-03, CA-11 (ii) y CA-13 — la clase `contrato` la fija el propio criterio, no mi preferencia, y el arreglo de fondo (restringir la gramática del campo) es de **1.33.0** por decisión de la coordinadora, que comparto: siete fail-open en tres vueltas sobre el mismo archivo dicen que la clase no se gana ensanchando. Se añade **SEC-022** (`instrumento`, la nota de `arnes-upgrade` sin el límite) y **SEC-021** recibe ventana. Deriva pendiente de write-back: la cabecera no declara SEC-020 ni SEC-021. **Acreditado y línea base de no-regresión:** los siete controles de R-004/R-005 más la honestidad **conjunta** de los dos bloques heredados. |
| **REQ-014** | **`aprobado`** | 2026-09-06 | candidata 1.32.0 (`cand/1.32.0`) | Tercera confirmación, con medida propia **hoy**: banco `741/0/1` rc 0 con cuadre, autoprueba `73/0`, `bash -n` sobre los 40 archivos del banco, bits de ejecución correctos y el endurecimiento del CI intacto. El delta que R-005 no cubría (`735 → 742` casos) vive en `secciones/34-arnes-paralelo.sh` y `35-arnes-paralelo-fail-open.sh`, **archivos declarados por REQ-013**, no en la partición ni en el corredor que este REQ entrega: su entregable no ha cambiado desde el `QA: aprobado`. Deudas declaradas que **no** bloquean: **SEC-019** (1.35.0) y `H-03`/`H-07`/`H-12` (`instrumento`); su cabecera aún declara `SEC-016`, ya **mitigado** (dirección inocua). **CA-06 sigue declarando su límite honesto: borrarlo o ensanchar la promesa sin ensanchar la máquina es regresión.** |

### ¿Veto la publicación de 1.32.0? — **NO**, y con las condiciones dichas

**No veto.** El razonamiento, en el orden en que pesa:

1. **`hooks/` es byte a byte v1.31.0.** Lo que gobierna a los demás proyectos no cambia. Un fallo en
   abierto aquí sería un fallo en abierto en todos ellos y en silencio: no lo hay.
2. **El fail-open abierto no tiene consumidor automático.** 0 referencias en `hooks/hooks.json`,
   ningún invocador en el árbol, no es puerta y no escribe. Su coste máximo es un conflicto de fusión
   en el trabajo del propio repositorio. No toca dinero, ni datos personales, ni identidad, ni acceso,
   ni produce una firma falsa: las dos reglas de orden de fases no dependen de la herramienta.
3. **Se publica declarada como no fiable donde se escribe el campo y donde se manda usarla**, en los
   cuatro archivos (dos del repo y sus dos plantillas, verificado idéntico), con clase, dueño y
   ventana. Un fallo declarado con vencimiento no es un fallo oculto.
4. **REQ-013 no cierra**, así que la clase `contrato` no se salta ninguna puerta: `guard-completado`
   seguiría denegando su cierre, y con razón.
5. **El resto de la ventana está verificado y en verde**, con medida propia de hoy.

**Y dos cosas que no son un veto pero condicionan la publicación, y no las decido yo:**

- **La decisión ya es de Juan, por la regla del propio proyecto.** `AGENTS.md` §4/§6 delega la
  fusión, el tag y la publicación en la coordinadora **«cuando todo está en verde»**, y añade que
  «cualquier rojo o **hallazgo abierto** las devuelve al humano». **SEC-020 está abierto y es
  `contrato`.** Mi no-veto retira el obstáculo de seguridad; **no** convierte este estado en el
  «todo en verde» que habilita la delegación.
- **`PENDING_APPROVAL.md` tiene una pendiente viva** (REQ-014 toca `tests/` y el workflow de CI, gate
  humano explícito de §6). Mientras esté ahí, `guard-completado` deniega marcar **cualquier** REQ como
  `completado`: REQ-012 y REQ-014 no pueden cerrar sin que un humano la resuelva. Es el mecanismo
  funcionando, no un hallazgo.

**Condiciones bajo las que mi no-veto sigue valiendo** —si alguna cambia, no las cubre—: (i) `git
diff v1.31.0 -- hooks/` sigue vacío en el commit que se etiquete; (ii) los dos bloques del campo
`Archivos:` viajan **juntos** y el aviso de `AGENTS.md` viaja **adyacente** a la instrucción, en el
repo **y** en las dos plantillas; (iii) `tools/arnes-paralelo.sh` no adquiere ningún consumidor
automático mientras SEC-020 esté abierto. **Recomendación, no condición:** que la frase de SEC-022
viaje antes del tag, como viajaron las de SEC-015 y SEC-016.

---

## Revisión R-007 — ventana 1.32.1 (REQ-015, REQ-016) — 2026-09-07

**Alcance.** El parche 1.32.1: la carrera de publicación del hook de continuidad (REQ-015) y la
noción de cita del lector de cabecera (REQ-016), sobre el árbol que el `qa-tester` aprobó en su
vuelta 2. Archivos revisados: `hooks/lib.sh`, `hooks/guard-completado.sh`, `hooks/campos-req.awk`,
`hooks/estado-derivado.sh`, `hooks/rotar-artefactos.sh`, `tools/arnes-paralelo.sh`,
`tools/arnes-lectura.sh`, la sección 36 del banco (cuatro archivos), `skills/arnes-upgrade/SKILL.md`,
`AGENTS.md` §13 y `templates/AGENTS.md.tpl`. **Más** un cambio de accesos hecho hoy fuera del código
y el residual del ruleset. Guardián de la sesión: instalación estable 1.32.0. Plataforma: Linux (WSL2).

**Orden de firmas: respetado.** `QA: aprobado (vuelta 2, 2026-09-07)` en los dos REQ **antes** de
esta auditoría (`AGENTS.md` §6). Ninguna auditoría preventiva declarada en esta ventana; ningún REQ
cerrado antes de tiempo. Los dos siguen en `en-revisión`.

**Método.** Sondas propias contra `hooks/guard-completado.sh` sobre un fixture aislado del
directorio temporal de la sesión, con `CLAUDE_PROJECT_DIR` apuntado al fixture —el error que el
propio REQ-016 documenta— y con la regla de que **la ausencia de decisión es `allow`** y así se
imprime. Cada sonda se corrió contra los hooks de **v1.30.3, v1.31.0, v1.32.0** (extraídos con
`git archive`) **y** contra el árbol de hoy, para separar regresión de defecto heredado. Ninguna
sonda se ejecutó contra un entorno de terceros. **No se repitieron** las mediciones ya publicadas
por QA (banco 802/0/1 en tres vueltas, fail-before por sección, fuzz diferencial 2 700/0, procesos
por llamada): se dan por buenas, con una excepción declarada — la revisión de las **tres decisiones
que el parche cambia** sobre cabeceras con CR sembrado (vuelta 2 §3.3), que se resolvió **leyendo**
y no midiendo la consecuencia. Ahí está SEC-024.

**Veredicto: REQ-015 `aprobado`; REQ-016 `con-hallazgos` — no firmo REQ-016.** Motivo en una línea:
el parche cierra la fabricación del **cierre** del rango (`-\r->`) y deja **abierta, y en la
dirección que abre**, la del **abre** (`<!\r--`), con lo que un `deny` de la puerta se convierte en
`allow` sobre una cabecera base del corpus — **incumplimiento exacto de la letra de CA-02**, medido
hoy (SEC-024). No es un veto: hay remedio acotado, dueño y una vuelta disponible de las tres.

---

### SEC-023 — El fail-open de la cita corrió **publicado** dos versiones: 1.31.0 y 1.32.0 cerraron REQ `critico` sin auditoría aprobada

- **Severidad:** alta · **Clase:** `contrato` · **Estado:** `en-mitigación` · **REQ:** REQ-016
- **Ventana de exposición:** **1.31.0 y 1.32.0, ambas inclusive.** La pertenencia **no es una lista
  escrita a mano**: es toda versión publicada que tolera el énfasis de Markdown en la **clave** del
  campo (`arnes_norm_clave`) y **no** tiene noción de cita (`arnes_sin_cita`) — las dos condiciones a
  la vez, la primera sin la segunda. El sitio único donde vive esa derivación, con su comando tag a
  tag, es `skills/arnes-upgrade/SKILL.md` §`Hacia 1.32.1`. Ejemplos **no exhaustivos** a hoy: 1.31.0,
  1.32.0. Las anteriores no leían la clave decorada; 1.30.2 y 1.30.3 **deniegan** (bisección del
  reportante, reproducida por mí).
- **Mecanismo.** Tres reglas correctas por separado —tolerancia de énfasis en la clave, «gana la
  última aparición», y un lector sin noción de cita— hacían que **cualquier** línea de la cabecera
  que empezara por la clave de un campo se convirtiera en el valor vigente, **incluida** la que vive
  dentro de un `<!-- … -->` que dice literalmente ser histórica. Vale para cualquier campo por el
  mismo camino: el veredicto de QA, la clase de un hallazgo bloqueante, el rigor, la sensibilidad.
- **Lo que este parche NO deshace, y es lo que pesa:** cierra la puerta **de aquí en adelante**. **No
  revisa lo que ya cerró.** Un proyecto que corrió 1.31.0 o 1.32.0 puede tener REQ en estado terminal
  cuyo cierre nadie firmó, y el arnés no lo sabe ni lo puede saber por sí solo: el estado terminal no
  guarda quién lo autorizó.
- **Qué tiene que hacer un proyecto que corrió esas versiones.** La instrucción operativa **no se
  duplica aquí a propósito** —dos transcripciones de la misma regla se desfasan, y esta ventana existe
  por una de ellas—: vive en `skills/arnes-upgrade/SKILL.md` §`Hacia 1.32.1`, viñeta «**Y AUDITA TUS
  REQ CERRADOS**», con su barrido `awk`, la comprobación tag a tag y la instrucción de **reabrir** el
  REQ (`AGENTS.md` §9) en vez de borrar el comentario.
- **Dictamen sobre la suficiencia de esa instrucción: suficiente en el QUÉ, insuficiente en el
  BARRIDO.** Dice sin eufemismo lo que pudo pasar, obliga a rehacer la revisión y no a maquillar el
  texto, y deriva las versiones del historial del lector en vez de enumerarlas. Lo que no es
  suficiente es el **comando**, y no por el patrón: por la **pregunta**. Ver SEC-025.
- **Estado de mitigación.** `en-mitigación`, no `mitigado`: el código cierra la vía en 1.32.1 (medido
  por mí: el mismo documento con `<!--` bien escrito → **deny**, contra **allow** en 1.30.3, 1.31.0 y
  1.32.0), pero la **auditoría retroactiva** de cada proyecto consumidor es acción humana que este
  repositorio no puede acreditar. Pasa a `mitigado` cuando el barrido de SEC-025 exista y la
  instrucción lo lleve; su ejecución en cada proyecto es de ese proyecto.
- **Dueño:** `desarrollador` (el barrido y el código) · cada proyecto consumidor (su propia auditoría).

---

### SEC-024 — Un CR suelto en la cabecera decide del lado que **ABRE**: el `<!\r--` no reconocido deja gobernar el veredicto citado, y `Seg\ruridad:` fabrica la clave

- **Severidad:** alta · **Clase:** `contrato` · **Estado:** `abierto` · **REQ:** REQ-016 (**bloquea
  su cierre**) · **Ventana:** 1.32.1
- **Ubicación:** `hooks/lib.sh` — `arnes_sin_cita` (el rango se escanea crudo, correcto) junto con
  `arnes_norm_clave:1620` (`local l="${1//$'\r'/}"`, que descuenta **todos** los CR y también los de
  la **clave**), y el bucle de cabecera de `arnes_campos_req`, que acepta la línea sin preguntar si
  se pudo medir.
- **La clase, dicha por propiedad y no por forma.** El autor de un REQ y el lector del arnés pueden
  **discrepar sobre dónde empieza o acaba un rango de comentario**, y toda discrepancia tiene que
  caer del lado que **DENIEGA**. Hoy cae de los dos lados: para `<!-- nota --!>` cae del lado que
  cierra —declarado conforme, con su caso en el banco— y para `<!\r--` cae del lado que **abre**. El
  vector es el **CR suelto**, el único carácter de control C0 que el arnés no deniega (los demás sí),
  y lo es sólo por el transporte CRLF de Windows.
- **Medido hoy (2026-09-07), fixture aislado, `Write`, cuatro árboles.** Base tomada de la forma del
  corpus del banco: `critico`, `QA: aprobado`, **sin ninguna declaración de `Seguridad:`** → la base
  **DENIEGA** con motivo propio («su rigor efectivo es 'critico' y el veredicto de seguridad es
  'ausente'», la excepción que CA-11 nombra). Se le **añade** un rango cuyo interior declara
  `Seguridad: aprobado`, un campo que **no estaba** en la base:

  | Variante añadida a la misma base | Decisión hoy |
  |---|---|
  | (nada: la base desnuda) | **deny** |
  | `<!--` / `Seguridad: aprobado (A-001, 2026-09-01)` / `-->` | **deny** ← el arreglo funcionando |
  | `<!` + CR + `--` / `Seguridad: aprobado (A-001, 2026-09-01)` / `-->` | **ALLOW** |

  Y en la forma con `Seguridad: pendiente` vigente en la base, el mismo `<!\r--`: **allow** en
  1.30.3, 1.31.0, 1.32.0 **y hoy**; el lector de hoy publica `SEG=<aprobado>` y `CITA_ABIERTA=0`.
- **Por qué es incumplimiento exacto de CA-02, y no una lectura amplia.** CA-02 dice: dada cualquier
  cabecera del corpus, cuando se le añade un rango **cuyo interior no contiene ninguna declaración de
  campo que ya estuviera en esa cabecera**, entonces **no existe** ningún caso en que un `deny` se
  convierta en `allow`. El antecedente se satisface **literalmente** (la base no declara `Seguridad:`)
  y el consecuente es falso. La propia acotación de CA-02 lo anticipa como lo que **sigue
  incumpliendo** —«un delimitador de comentario que el lector **fabrique** a partir de un carácter que
  descuenta antes de escanear el rango»— y el Historial de REQ-016 lo blinda: «la acotación **no**
  cubre el CR interior de H-01, que sigue siendo incumplimiento de CA-02 y CA-03 y **se arregla en el
  código, no en el criterio**». Se arregló **una mitad**: `-\r->` (el cierre) ya no se fabrica y
  el rango queda abierto → deny, correcto. Para `<!\r--` (el abre), **no fabricar** significa que el
  rango **nunca se abre**, y entonces lo que el autor aparcó dentro del comentario **gobierna**. El
  mismo parche cerró una dirección e **invirtió** la otra en fallo abierto.
- **La segunda cara del mismo vector, medida y con el mismo remedio: la clave fabricada.** Sobre una
  base `critico` con `Seguridad: pendiente` vigente, la línea `Seg` + CR + `uridad: aprobado` cierra
  el REQ: `arnes_norm_clave` retira el CR **después** de la cita y **fabrica la clave**. Bisecado:
  **allow** en 1.30.3, 1.31.0, 1.32.0 y hoy — **no** lo introdujo este parche. Los dos lectores
  coinciden (`hooks/campos-req.awk` fabrica igual), así que **CA-01 se cumple** y esta cara no
  desmiente ningún criterio; se registra aquí porque **el remedio es el mismo** y porque el barrido de
  SEC-025 tampoco la encuentra. Y `tools/arnes-lectura.sh` dice sobre ese documento «Ningún valor
  anómalo: la máquina lee los 2 REQ como están escritos», `rc=0`: la afirmación es **falsa** —el
  discriminante `ARNES_CLAVE_DECORADA` se deriva de `crudo="${l%%:*}"`, capturado **después** del
  descuento del CR, así que la reparación que la normalización tuvo que hacer es invisible a la propia
  función que existe para nombrarla.
- **Riesgo.** Un REQ `critico` cierra sin auditoría de seguridad aprobada, por dos vías, en la versión
  que se está publicando. Es exactamente el fallo que esta ventana existe para cerrar, y el sitio lo
  empeora igual que en SEC-023: quien documenta la historia de sus veredictos en un comentario se
  expone más.
- **Remediación recomendada — una pregunta cerrada, no un patrón que ensanchar.** La forma que cubre
  la **clase** y no las dos formas medidas: **una línea de la cabecera que contenga un CR que no sea
  el que la termina deja una cabecera que no se puede medir, y una puerta que no puede medir no deja
  pasar** → DENY citando la línea. Es el principio que CA-03 ya adoptó para el rango sin cerrar,
  aplicado al carácter. Propiedades que la hacen preferible a cualquier alternativa examinada:
  1. **Cierra las dos caras con un solo control** (el abre no reconocido y la clave fabricada), y
     cualquier objetivo futuro del mismo carácter, porque no habla del objetivo sino del carácter.
  2. **No estrecha ninguna tolerancia** y por tanto **no reabre** el camino que el `desarrollador`
     midió y evitó: `Estado: comple\rtado` deja de leerse como estado terminal, sí, pero **no** por
     ausencia de estado — la cabecera se deniega antes. La dirección sigue siendo la que cierra, que
     es la única condición que ese descarte exigía.
  3. **No toca la tolerancia al CRLF**, porque el CR que **termina** la línea queda expresamente
     fuera: el CRLF completo lo normaliza `arnes_sin_cr_transporte` en el entrante y el disco lo
     entrega como CR final. Las dos filas «REQ entero en CRLF» del banco no se mueven.
  4. **Es coherente con lo que el arnés ya hace:** los bytes de control C0 distintos de tab, LF y CR
     **se deniegan, no se limpian**. Esto sólo retira la excepción del CR allí donde no es transporte.
  La decisión de diseño y el código son del `desarrollador`; **no escribo código**. Si elige otra
  salida, la condición que **no** negocio es la propiedad: ninguna discrepancia autor↔lector sobre los
  delimitadores puede caer del lado que abre, y la comprobación tiene que estar en el banco **con su
  fail-before** contra el árbol de hoy (no contra 1.32.0, que denegaba estas formas por otro motivo).
- **Write-back exigido antes de levantar esto (`AGENTS.md` §9, y mi propia regla):** el control no
  vive sólo en el código ni sólo en este registro. Va a **criterio** de REQ-016 —extensión de CA-03 o
  un CA nuevo— enunciado **por propiedad**, con el sitio único donde vive la lista exhaustiva de
  caracteres y los ejemplos marcados **no exhaustivos**. Dueño del write-back:
  `analista-requerimientos`.
- **Dueño:** `desarrollador` (código y banco) · `analista-requerimientos` (write-back).

---

### SEC-025 — El barrido de la auditoría retroactiva afirma completitud, y hay dos contraejemplos medidos: pregunta por el **mecanismo** cuando la pregunta de **estado** es completa y gratis

- **Severidad:** media · **Clase:** `contrato` · **Estado:** `abierto` · **REQ:** REQ-016 (CA-09)
  · **Ventana:** 1.32.1 para la frase; 1.33.0 para el barrido por estado
- **Ubicación:** `skills/arnes-upgrade/SKILL.md` §`Hacia 1.32.1`, viñeta «Qué revisar, y con qué
  comando» — el comentario de la primera línea del barrido: «los REQ cuya CABECERA abre un comentario:
  **son los únicos que pudieron verse afectados**».
- **Descripción.** La frase es una **promesa de completitud** y es falsa. El barrido busca `<!--` en
  la cabecera, así que **no encuentra** (i) una cabecera cuyo único delimitador sea un `<!\r--`
  fabricado —la observación que el `desarrollador` dejó sin dictaminar, y que SEC-024 convierte en
  algo peor que un hueco del barrido: en un fallo abierto vivo—, ni (ii) la **clave fabricada** de
  SEC-024, que no necesita comentario ninguno y cierra un `critico` desde 1.30.3. Un proyecto que
  corra el barrido, no vea nada y concluya «no me afectó» habrá llegado a una conclusión que el
  comando no sostiene, y el cierre sin firma se queda sin firmar para siempre.
- **Por qué es `contrato` y no un defecto de forma.** Es superficie que los proyectos **heredan** por
  `arnes-upgrade`, y es una frase **más ancha que lo que la máquina hace**: la regla de `ADR-002`, y
  exactamente la misma clase que SEC-015 cerró en esta misma ventana por REQ-015 CA-08 (una promesa
  incondicional de `AGENTS.md` §13 sobre lo que la continuidad no toca). La superficie heredada no
  tiene un régimen más laxo que un criterio: es la que actúa en proyectos que nadie de aquí audita.
- **Y el defecto de fondo no es el patrón: es la pregunta.** Ensanchar el patrón aquí pierde —cuatro
  derrotas medidas en este repositorio— porque el barrido interroga al **mecanismo** («¿hay un
  comentario?») y el mecanismo tiene una vía nueva cada vez. La pregunta que **no envejece** es de
  **estado**: *«de mis REQ en estado terminal, ¿cuáles NO cerrarían hoy, leídos con el lector de esta
  versión?»*. Eso cubre la cita, el delimitador fabricado, la clave fabricada, el veredicto que en
  versiones más viejas vivía dentro de `## Historial de cambios` y **cualquier vía que nadie ha
  descubierto todavía**, porque no describe la vía: describe la discrepancia entre «está cerrado» y
  «hoy no cerraría». Y es barata: el lector ya existe, y `arnes_campos_req "$disco" ""` da el juicio
  sobre el documento tal como está en el disco.
- **Remediación, en dos mitades con dueños distintos:**
  1. **Ahora, en esta ventana, y es lo que bloquea:** la frase de completitud se corrige a la **forma
     que no envejece** —enunciar la **propiedad** («los REQ en estado terminal cuyo veredicto vigente
     no autorizaría hoy el cierre»), citar el barrido de `<!--` como **ejemplo no exhaustivo** de una
     vía, y **nombrar** las dos vías conocidas que el comando no encuentra—. Y la propiedad va a
     **CA-09**, no sólo al skill: hoy CA-09 acota «qué revisar» a la vía del comentario, así que el
     skill cumple el criterio y el criterio es lo que se quedó corto. Dueño: `analista-requerimientos`
     (CA-09) y `desarrollador` (la frase). Es una cláusula en cada sitio.
  2. **1.33.0, y no bloquea:** el barrido **por estado** como modo de `tools/arnes-lectura.sh` —«REQ
     en estado terminal que hoy no cerrarían»—, que es el control de verdad. Clase de esa mitad:
     `instrumento`. Dueño: `desarrollador`. Va junto a SEC-020/SEC-021 y REQ-011, donde ya vive el
     trabajo sobre lectores y campos.
- **Nota de coste, para que la primera mitad no se lea como cara:** la sección 36-4 del banco certifica
  el texto del skill con `mira36` (grep sobre el archivo). Añadir la propiedad son una fila más y un
  `CASOS_ESPERADOS` que sube. No hay que reescribir ninguna medición.

---

### SEC-026 — Accesos del repositorio público: retirado un colaborador con `write`, y el canal privado de informes pasa a tener repositorio propio

- **Severidad:** n/a (es una **corrección**, no un hallazgo) · **Clase:** n/a · **Estado:**
  `mitigado` · **REQ:** — · **Fecha:** 2026-09-07
- **Qué cambió, y por qué importa.** `JJOVEGA/ArnesJuan` es **público** y desde él se distribuye el
  plugin (`.claude-plugin/marketplace.json`): un colaborador con `write` sobre este repositorio puede
  modificar el mecanismo que gobierna a **todos** los proyectos que lo instalan. El permiso de
  escritura aquí no es acceso a un repositorio: es acceso a las puertas de terceros.
  - `jvega-consisa` tenía **write** y se le **retiró el acceso** por completo.
  - Se retiró la invitación **caducada** de una tercera cuenta.
  - Se creó `JJOVEGA/ArnesJuan-informes`, **privado**, con issues y sin colaboradores más que el
    dueño, para los informes que sí llevan datos de cliente.
- **Verificado por mí hoy con `gh`** (cuenta activa `jvega-habitat`, sin admin):
  `repos/JJOVEGA/ArnesJuan/collaborators` → **exactamente dos**, `JJOVEGA` (`admin=true`) y
  `jvega-habitat` (`admin=false, push=true`); `repos/JJOVEGA/ArnesJuan` → `visibility=public`.
  **Lo que NO pude verificar y por eso lo digo:** las **invitaciones** exigen admin (`403`), y
  `ArnesJuan-informes` responde `404` a esta cuenta — consistente con «privado y sin colaboradores
  más que el dueño», pero **no** es prueba de ello. Esas dos las acredita la coordinadora con la
  cuenta propietaria; yo acredito lo que leí.
- **Valoración: es la corrección correcta y va en la dirección buena.** El principio de mínimo
  privilegio sobre el repositorio que distribuye el plugin, y la separación del canal privado en un
  repositorio **privado con issues** en vez de en archivos `.gitignore` en el árbol público —que es un
  `git add -A` distraído de distancia, como el propio `.gitignore` advierte—.
- **Y una consecuencia que hay que escribir, no descubrir:** el repositorio de informes es **privado
  y por tanto fuera de la clase «Público»** de `docs/seguridad/gobernanza-datos.md` §2. La regla del
  canal privado (§3) **no cambia**: lo que cruza de ahí a este repositorio sigue siendo la **forma**
  del defecto y nunca su instancia. Un repositorio privado del mismo propietario facilita el traslado
  literal, que es exactamente lo que la regla prohíbe. Anotado en §2 y §3 de `gobernanza-datos.md`.

---

### SEC-027 — El ruleset `proteger-main` exige el check pero **cero revisiones aprobadas**: quien tiene `write` abre y fusiona su propio cambio del plugin

- **Severidad:** media · **Clase:** `instrumento` · **Estado:** `aceptado` (residual declarado, con
  condiciones) · **REQ:** — · **Dueño:** propietario (`JJOVEGA`); es el único que puede cambiar un
  ruleset
- **Medido hoy (2026-09-07), leyendo el ruleset con `gh`** (`rulesets/22245314`, `enforcement:
  active`, `target: branch`, `include: ~DEFAULT_BRANCH`):

  | Regla | Estado |
  |---|---|
  | `deletion`, `non_fast_forward` | activas — no se borra `main` ni se reescribe |
  | `pull_request` | activa — **todo por PR**, pero `required_approving_review_count: **0**`, `require_last_push_approval: false`, `require_code_owner_review: false` |
  | `required_status_checks` | `hooks-en-linux` **requerido y estricto** (`strict_required_status_checks_policy: true`) |
  | `require_extra_approval_for_unattributed_changes` | `true` — cubre commits sin autoría atribuible, **no** este caso |

  Y el ejercicio real, medido y **más ancho de lo que se reportó**: los PR **#37, #38, #39 y #40**
  fueron abiertos y fusionados por `jvega-habitat`, con **0 revisiones** cada uno. El push directo a
  `main` sí se rechaza. Conclusión: hoy la convención de que la fusión es humana la sostienen **el
  hábito y la delegación del propietario**, no la plataforma.
- **Dictamen — residual `aceptado`, y NO exijo el control. Con tres condiciones que lo sostienen, y si
  alguna cae, no lo cubro.** El razonamiento, en el orden en que pesa:
  1. **La delegación es una decisión del dueño del sistema, escrita y fechada** (`AGENTS.md` §4/§6,
     2026-09-05), y **no** es «cero control»: está condicionada a *«todo en verde»* y **cualquier rojo
     o hallazgo abierto devuelve la decisión al humano**. Un residual gobernado por una regla escrita
     con su condición de invalidez no es lo mismo que un residual sin gobierno.
  2. **La asimetría es real y va contra el control.** Exigir una revisión aprobada cerraría el riesgo
     **y** metería un aprobador humano en la vía que hoy funciona por delegación — con **dos** cuentas
     en total, una de ellas el propio propietario: la única revisión posible la firmaría `JJOVEGA`,
     que es quien ya decide. El control no añadiría un par de ojos: añadiría un turno. Y un control
     que estorba sin añadir independencia es el perfil del control que alguien acaba desactivando, que
     es peor que no tenerlo.
  3. **La puerta que de verdad protege el mecanismo está activa y es estricta.** Ningún cambio de
     `hooks/` llega a `main` sin que el banco pase en Linux. Eso es lo que impide un fallo en abierto
     silencioso en los proyectos que instalan el plugin; una revisión aprobada no lo impediría mejor.
  4. **Y el privilegio acaba de reducirse** (SEC-026): la superficie de «quien tiene write» pasó de
     tres cuentas a dos.
- **Condiciones bajo las que este `aceptado` vale** —si alguna cambia, hay que volver a mirarlo, y
  entonces mi recomendación sería exigir la revisión:
  (i) **el número de cuentas con `write` no crece**: en cuanto haya una tercera, «me fusiono a mí
  mismo» deja de ser el propietario o su delegado y el control empieza a comprar independencia real;
  (ii) el check `hooks-en-linux` sigue **requerido y estricto**, y las reglas `deletion` /
  `non_fast_forward` siguen activas;
  (iii) la condición de la delegación se **respeta**: con un hallazgo `contrato` abierto, la fusión y
  el tag vuelven a Juan. **Hoy eso aplica:** SEC-020 sigue abierto y `contrato`, SEC-024 y SEC-025
  nacen abiertos y `contrato`, y `docs/PENDIENTES.md` lleva el cierre por heredoc de `python3` como
  `contrato`. **La publicación de 1.32.1 no está en el supuesto «todo en verde» y por tanto no está
  delegada.**
- **Por qué `instrumento` y no `contrato`.** No hay ningún texto del proyecto que prometa que la
  plataforma exige revisión: `gobernanza-datos.md` §6 ya lo declara al revés («el gate humano de
  fusión y publicación es **política declarada**, no una restricción de la plataforma»), y esta entrada
  lo mide. Un residual **declarado, medido y con vencimiento condicional** no es un fallo oculto. Si
  algún día un documento heredado dice que la plataforma lo exige, esa frase será `contrato` — y esta
  entrada es la que la desmentiría.

---

### SEC-028 — La propiedad «ningún carácter se descuenta antes de escanear el rango» se sostiene por **inspección** y ninguna guarda la mide

- **Severidad:** media · **Clase:** `instrumento` (**no bloquea el cierre**) · **Estado:** `abierto`
  · **REQ:** — · **Dueño:** `desarrollador` · **Ventana:** 1.33.0
- **Ubicación:** `hooks/lib.sh` (`arnes_sin_cita`), `hooks/campos-req.awk` (`sincita()`) y los ocho
  puntos que descuentan CR; la guarda estructural existente vive en
  `tests/escenarios/hooks/secciones/36-cabecera-comentario-html-4-el-informe-y-los-textos.sh:75-82` y
  comprueba **coste**, no orden.
- **Descripción y remediación:** el análisis completo, con la enumeración revisada punto por punto y
  las dos mitades del remedio, está en la sección «Sobre el fallo en abierto cerrado por las cuatro
  bocas» de esta revisión R-007, más abajo. En una línea: la propiedad es correcta hoy y **envejece
  con el siguiente `grep` que alguien no haga**; hacen falta (i) una comprobación cerrada sobre el
  cuerpo de las dos funciones y (ii) el **fuzz diferencial con semillas fijas dentro del banco**, que
  es la mitad que mide la propiedad y no la forma. La (ii) importa más: la (i) sola no vería una boca
  nueva.

---

### SEC-029 — `CHANGELOG.md` nombra a un proyecto consumidor en el repositorio **público**, y la verificación de §3 no podía encontrarlo porque es **diferencial**

- **Severidad:** alta · **Clase:** `contrato` · **Estado:** `abierto` · **REQ:** — (no atribuible a
  REQ-015 ni a REQ-016; **no** va a su campo `Hallazgos abiertos:`) · **Dueño:** `desarrollador`
  (la corrección) y `analista-requerimientos` (el NFR del barrido de base)
- **Ubicación:** `CHANGELOG.md:1615` — `**Medido en <nombre del proyecto>, con el control de
  plataforma hecho**`, dentro de la entrada «el bloque derivado costaba 92 segundos por parada en un
  proyecto real». Junto al nombre viajan métricas de forma de ese proyecto (número de REQ, tamaño
  total del corpus, tamaño del REQ mayor, segundos por turno y la lentitud de su plataforma).
- **Descripción.** `AGENTS.md` §4 y `gobernanza-datos.md` §3 son explícitos: este repositorio es
  **público**, «describe el arnés, nunca los hallazgos de un cliente», y la traducción «conserva el
  defecto y descarta el contexto» — **nunca el proyecto**. Aquí el contexto se conservó. Y
  `gobernanza-datos.md` §7 dice cómo se trata: «su incumplimiento se trata como **hallazgo de
  seguridad**, no como incidencia editorial». Lo trato así.
- **Medido hoy (2026-09-07).** Aparición **única** en todo el árbol versionado (`git grep -il`
  excluyendo `insumos/`). Introducida por el commit **`73f9452`** (PR **#26**, bump 1.29.3) y presente
  en **`origin/main`** y en cuatro ramas remotas más: está **publicada**. **No** entró en esta ventana:
  `git diff HEAD -- CHANGELOG.md | grep '^+.*<nombre>'` sale vacío. Y comprobado en la misma pasada,
  sin hallazgos: ningún patrón de credencial (`ghp_`, `github_pat_`, `AKIA…`, `-----BEGIN`,
  `api_key=`, `token=`, `password=`) en lo añadido por esta ventana; `insumos/` y `reporte-arnes-*`
  **no** entraron al índice; no existe ningún `.env` en el árbol.
- **La causa raíz no es el descuido: es la forma del control.** `gobernanza-datos.md` §3 define su
  verificación como `git diff origin/main..HEAD | grep '^+'` — **diferencial**. Una verificación
  diferencial **no puede encontrar, por construcción, lo que ya está en la base**, y la auditoría de
  REQ-001 (2026-09-05) reportó «sin hallazgos» **con razón**: este nombre entró antes de su ventana y
  nunca estuvo en su alcance. Es el mismo defecto de forma que SEC-025 en otro sitio: un control que
  pregunta por el **cambio** cuando la propiedad que hay que sostener es de **estado**.
- **Remediación, en dos mitades:**
  1. **La instancia, ahora, y es condición de mi no-veto:** sustituir el nombre por la forma que la
     **propia cabecera de esa entrada ya usa** («en un proyecto real»), y revisar en el mismo paso las
     métricas adyacentes: el número de REQ, el tamaño del corpus y el del REQ mayor son **huella** del
     proyecto y no hacen falta para entender el defecto — lo que la entrada necesita es el
     **fixture reproducido aquí**, que ya está y es la cifra que vale. `CHANGELOG.md` está declarado
     en el campo `Archivos:` de **los dos** REQ de esta ventana, así que la corrección cae dentro del
     commit que ya se va a hacer: **no** necesita REQ nuevo.
  2. **El control, con NFR, y no bloquea esta ventana:** §3 gana un **barrido de base** —una pasada
     sobre **todo** el árbol versionado, no sobre el diff— que se corre una vez y luego queda como
     puerta; el diferencial se conserva como lo que es, la comprobación **incremental**. El barrido se
     enuncia **por propiedad** («ninguna ruta versionada nombra un proyecto consumidor, una
     organización ni una persona ajena»), y la lista de nombres a buscar vive en **un solo sitio** y
     **fuera** del repositorio público —en `insumos/`, que está en `.gitignore`—, porque una lista de
     nombres de cliente publicada para poder buscarlos sería el mismo fallo con más pasos. Dueño del
     NFR: `analista-requerimientos`; ventana 1.33.0.
- **Lo que NO recomiendo, y va escrito para que nadie lo intente por celo:** **no se reescribe el
  historial público.** El nombre vive en `origin/main` y en cuatro ramas remotas; un `filter-repo`
  rompería toda clonación existente, chocaría con las reglas `non_fast_forward` del ruleset y no
  retiraría las copias ya distribuidas. El remedio proporcionado es **corregir el presente, declarar
  el residual y cerrar la vía**. El residual queda dicho aquí: **el nombre permanece en el historial
  de un repositorio público, y eso no se deshace.** Si el proyecto afectado tiene que ser informado,
  ésa es una decisión del propietario y no mía.
- **Estado.** `abierto`. Pasa a `en-mitigación` cuando la mitad 1 esté en el árbol, y a `mitigado`
  cuando el barrido de base exista como NFR y se haya corrido entero una vez.

---

### Dictamen de gobernanza de la ventana — las cinco preguntas

1. **El orden de firmas se respetó.** `QA: aprobado (vuelta 2, 2026-09-07)` en los dos REQ antes de
   esta auditoría; ninguna `Seguridad: preventiva` declarada; los dos REQ siguen en `en-revisión` y
   ninguno se cerró antes de tiempo. La cola de `PENDING_APPROVAL.md` está en 0 entradas, verificado.
2. **La clasificación de los seis hallazgos de la vuelta 1: la comparto, con una corrección de
   coherencia sobre H-05 y una reserva sobre H-06.**
   - **H-01, H-03, H-04 → `contrato`:** correcto y por el criterio, no por la severidad. Los tres son
     «el criterio afirma algo falso sobre lo construido», que es la definición.
   - **H-02.a–d → `instrumento`:** correcto. Son casos del banco que no medían; el producto se
     sostenía. Es el uso legítimo de la clase.
   - **H-05 → `contrato`: coincido, y resuelvo la incoherencia que QA misma señaló** entre su §0.1
     («ajeno a esta ventana, no se escribe en estos dos REQ») y su §7.1. **No es ajeno.** El campo
     `Archivos:` **de estos dos REQ** era falso, lo escribió esta ventana, y `tools/arnes-paralelo.sh`
     respondía `disjunto` con rc 0 sobre un par que colisiona — y ese `disjunto` es la **única**
     autorización para despachar en paralelo (`AGENTS.md` §6). Un mapa falso con éxito aparente sobre
     el propio trabajo de la ventana es `contrato` de la ventana, y se arregló dentro de ella, que es
     lo que ocurrió. La incoherencia era de **redacción**, no de decisión.
   - **H-06 → `contrato`, ajeno a la ventana: coincido en el tratamiento y no en la comodidad.** El
     tratamiento es correcto y tiene precedente: nace ≤1.30.x, es **idéntico** en 1.32.0 y 1.32.1
     (QA lo midió en los dos árboles), no lo introdujo ni lo empeoró este parche, y bloquear una
     ventana por un defecto que no introdujo es lo que este arnés llama cerrar de rebote. Va con
     dueño y ventana propios y **no** al campo `Hallazgos abiertos:` de estos dos REQ. **Lo que no
     acepto es que siga sin dueño:** una nota al margen que desactiva en silencio el bloqueo de la
     cola de aprobaciones (§6) es una puerta que se apaga sin que nadie lo vea, y la divergencia es
     entre la prosa de `PENDING_APPROVAL.md` y el código. Le corresponde dueño (`desarrollador`) y
     ventana (1.33.0, junto a REQ-011 y SEC-020/021).
   - **Y el mismo tratamiento, por el mismo razonamiento, aplico a la segunda cara de SEC-024** (la
     clave fabricada, `allow` desde 1.30.3): ajena a la ventana, dueño y ventana propios, **no** al
     campo `Hallazgos abiertos:` de estos dos REQ. Lo que **sí** bloquea es la cara del `<!\r--`,
     porque desmiente la letra de CA-02 sobre el árbol de hoy.
3. **El write-back NO amnistió nada. Verificado, y es lo que se me pidió confirmar.** CA-02 de
   REQ-016 acota su invariante al rango que **añade** y no al que **envuelve**, y lo hace nombrando
   tres veces lo que **sigue incumpliendo**: «la acotación es de esa clase y **sólo** de esa»;
   «cualquier otra vía por la que un `deny` se vuelva `allow` sigue **incumpliendo** este criterio y
   **no se acota para que encaje**»; y el ejemplo no exhaustivo del **delimitador fabricado**. El
   Historial lo blinda con la cláusula anti-coartada: el CR interior de H-01 «sigue siendo
   incumplimiento de CA-02 y CA-03 y **se arregla en el código, no en el criterio**». La conducta
   aceptada subió a **criterio** (CA-11) en vez de quedarse en un párrafo del Historial, y con su
   excepción medida dentro (`Seguridad:` ausente **no** se perdona en `critico`). Es un write-back
   honesto. **Y la prueba más dura de que lo es:** la cláusula que el analista escribió para que
   nadie usara la acotación como coartada es, literalmente, la que me deja fundar SEC-024. Un
   write-back que amnistía no le da munición al auditor siguiente.
4. **El cierre de 1.32.0 por un heredoc de `python3`: el registro es suficiente, y añado una cosa.**
   `docs/PENDIENTES.md` lo tiene con fecha, mecanismo, clase `contrato`, dueño (REQ-011, la puerta
   posterior, ventana 1.33.0), el forzador medido que le faltaba a ese REQ, y el agravante nombrado
   (la instrucción de sesión que prefería `Bash`). No pedí absolución y no la doy: no hace falta,
   porque **el cierre en sí era legítimo** —se revirtió, se repitió con `Edit` y la puerta lo aceptó
   con los veredictos en su sitio—; lo que falló fue que nadie lo comprobó, y eso es lo que está
   registrado. **Lo que falta es una consecuencia, no una línea más de relato:** mientras ese
   `contrato` esté abierto, la condición *«todo en verde»* de la delegación del propietario **no se
   cumple**, así que la fusión y el tag de esta ventana **no están delegados**. Eso pertenece a la
   decisión de publicación (SEC-027, condición iii) y no a `PENDIENTES.md`.
5. **La instrucción de sesión que empuja a editar por consola: la regla escrita NO basta, y esta
   ventana es la prueba.** La regla de CA-10 —«la invariante manda sobre cualquier preferencia de
   herramienta», con su motivo, en `AGENTS.md` §13 y en `templates/AGENTS.md.tpl`— es necesaria y hay
   que conservarla: convierte en escrito lo que estaba «en la cabeza de nadie». Pero es **una regla
   dirigida a quien lee, y el problema es de quien no lee**: el propio texto lo dice —«quien configura
   una sesión no suele ser quien lee esta sección»—, y por tanto **se dirige exactamente a la persona
   equivocada**. La evidencia está dentro de esta misma ventana: la instrucción reapareció **hoy**, en
   tres comisiones (coordinadora, desarrollador y esta), después de escribirse la regla. Las tres la
   declaramos y no la seguimos para archivos protegidos — es decir, la regla funcionó **tres veces por
   disciplina de tres agentes**, que es precisamente la forma de cumplimiento que este arnés existe
   para no necesitar.
   **Dictamen: pide un control, y el control ya está especificado y con dueño — es REQ-011, la puerta
   posterior.** No hace falta inventar nada: una puerta que deja de preguntar *antes* si un comando va
   a escribir y pregunta *después* si algo protegido cambió es indiferente a la herramienta y por
   tanto a la preferencia. Es la misma respuesta que `docs/PENDIENTES.md` da al heredoc de `python3`,
   y eso **no es coincidencia: son dos forzadores medidos de la misma clase**, uno por descuido de
   herramienta y otro por preferencia de configuración. **No abro hallazgo nuevo**: sería un tercer
   nombre para el mismo trabajo ya dotado. Lo que sí dejo escrito es la **prioridad**: REQ-011 tiene
   ahora dos forzadores medidos con fecha, y ninguna regla de prosa los habría evitado.
   **Y un matiz que no quiero que se pierda:** la regla de CA-10 **no** es un sustituto fallido, es la
   mitad honesta — declara el límite mientras la puerta no existe, que es lo que `ADR-002` manda hacer
   con toda barandilla parcial. Lo que no se puede es tratarla como cierre.

---

### Sobre el fallo en abierto cerrado por las cuatro bocas — lo que se me pidió dictaminar

**La enumeración de los ocho descuentos de CR es por INSPECCIÓN, no por construcción.** La revisé y
es correcta hoy: `arnes_sin_cita` no descuenta nada; `arnes_sin_cr_transporte` y la reconstrucción del
`Edit` en `guard-completado.sh` sustituyen CRLF por **un salto de línea** —y el escaneo es **por
línea**, así que no pueden pegar dos caracteres para fabricar un delimitador—; el CR final suelto no
tiene nada a su derecha con lo que pegarse; `campos-req.awk` hace su `gsub` **después** de `sincita()`;
`arnes_norm_clave` y `arnes_norm_campo` corren después de la cita; `arnes_cola_pendientes` recorta cola.
Correcta, y **envejece con el siguiente `grep` que alguien no haga**: nada en el árbol impide que un
descuento futuro se ponga en el lado equivocado, y la prueba de que ese riesgo no es teórico es que
**la tercera boca no la reportó nadie** —se encontró al arreglar la primera y ver que el caso seguía
en `allow`—.

Y las guardas que hay no cubren esa propiedad: la única guarda **estructural** sobre `arnes_sin_cita`
(sección 36-4) comprueba que la función **existe** y que **no invoca un binario externo** —es la
guarda de **coste** de CA-08—, no que nada se descuente antes del escaneo. Las tres bocas están
cubiertas **por conducta**, con un caso cada una, y el par con CR interior del corpus de paridad cubre
la divergencia entre los dos lectores. Eso es cobertura de las **formas medidas**, no de la clase. El
fuzz diferencial de 2 700 cabeceras que da 0 divergencias **es de QA y no está en el banco**, así que
la medición más fuerte que existe sobre esta clase no la puede repetir el CI.

**Hallazgo, y no bloquea:** falta una guarda estructural que impida que un descuento futuro se ponga
antes del escaneo. Queda como **SEC-028**, clase **`instrumento`**, dueño `desarrollador`, ventana
**1.33.0**. Las dos mitades, y la segunda importa más que la primera: (i) sobre el **cuerpo** de
`arnes_sin_cita` y de `sincita()`, que ninguna de las dos retire ningún carácter antes de escanear
—pregunta cerrada sobre dos funciones, coste nulo—; (ii) el **fuzz diferencial con semillas fijas**
(lib vs awk, CR sembrado en cualquier posición) **dentro del banco**, que es la única mitad que mide la
propiedad y no la forma. La (i) sola sería otra enumeración: no vería una boca nueva.

**La decisión de diseño: de acuerdo, y cierra la clase mejor que la alternativa — pero no la cierra
entera, y ahí está SEC-024.** Descontar **después** del escaneo y estrechar el descuento de transporte
a CRLF→LF más el CR final es la salida correcta: es una **pregunta cerrada** (el rango está
delimitado), no toca **ninguna** tolerancia y por tanto no reabre nada, y el descarte de la
alternativa está bien razonado —recortar sólo el CR final en `arnes_sin_cita` obligaba a estrechar
`arnes_norm_clave` y eso abría un camino nuevo, `Estado: comple\rtado` dejando de leerse como estado
terminal—. Suscribo ese descarte. **Lo que el razonamiento no cubrió** es que «no fabricar» tiene
**dos consecuencias opuestas** según qué delimitador esté en juego: para el **cierre** (`-\r->`) no
fabricar deja el rango **abierto** y eso deniega, correcto; para el **abre** (`<!\r--`) no fabricar
deja el rango **sin abrir**, y entonces lo que el autor puso dentro **gobierna**. La clase se cerró en
la dirección en que se midió y se invirtió en la otra. Por eso el remedio de SEC-024 no es tocar el
descuento otra vez —eso volvería a mover una tolerancia— sino **negarse a medir una cabecera con un CR
que no sea el que la termina**.

---

### Estado de seguridad aprobado por REQ — ventana 1.32.1 (línea base de no-regresión)

| REQ | Veredicto | Fecha | Versión | Motivo / controles acreditados |
|---|---|---|---|---|
| **REQ-015** | **`aprobado`** | 2026-09-07 | candidata 1.32.1 | Ningún hallazgo de esta revisión toca su entregable. **Controles acreditados, y debilitarlos es regresión:** (a) el temporal de publicación incorpora una componente **propia del proceso** y sigue **en el directorio del destino**, en los **cinco** puntos de publicación de `hooks/estado-derivado.sh` y `hooks/rotar-artefactos.sh` (`arnes_tmp_publicacion`), con **fail-closed** si la componente única no se obtiene: no se cae al nombre compartido; (b) la purga retira los temporales **sin dueño vivo** y **conserva** el del proceso vivo y los archivos ajenos; (c) el destino queda **byte a byte** en todo camino de fallo, incluida la muerte por señal (QA: 0 de 40 destinos rotos con `SIGKILL`); (d) **no** se introdujo `flock` ni serialización, y CA-04 declara que no se exige — un candado sería un modo de fallo nuevo sobre contenido derivado; (e) CA-08 corrigió la promesa **incondicional** de `AGENTS.md` §13 y de `templates/AGENTS.md.tpl` a **dos mitades nombradas**: **volver a afirmarla sin condición es regresión de herencia** (es SEC-015). **Hallazgos abiertos: (ninguno).** **Alcance de esta firma:** el árbol que QA validó. Si el remedio de SEC-024 modifica `hooks/lib.sh` —archivo que este REQ declara—, re-confirmo con una relectura dirigida a `arnes_tmp_publicacion`/`arnes_purga_tmp`, no con una auditoría nueva. |
| **REQ-016** | **`con-hallazgos`** | 2026-09-07 | candidata 1.32.1 | **No firmo.** **SEC-024** (`contrato`, abierto) desmiente la **letra** de CA-02 sobre el árbol de hoy: base del corpus que **deniega** → añadido un rango cuyo interior declara un campo que **no estaba** → **`allow`**, por un `<!\r--` que el lector —correctamente— **no** reconoce como abre, con lo que el veredicto aparcado dentro del comentario **gobierna**. La clase la fija el propio criterio y su cláusula anti-coartada, no mi preferencia. **SEC-025** (`contrato`, abierto) suma la frase de completitud del barrido heredado. **Lo que SÍ queda acreditado y es línea base de no-regresión:** el rango de comentario no declara campo en los **dos** lectores y en `tools/arnes-paralelo.sh` (cuarta superficie de decisión, cuyo `disjunto` es la única autorización de paralelismo); un rango que **abre y no cierra** deniega **citando el rango** y nunca permite por **ausencia** del campo que se tragó (CA-03); la tolerancia de clave decorada **fuera** de los rangos **no se recortó** (CA-04 — recortarla reabriría un fail-open real y es la razón por la que la propuesta (b) se descartó: **restringirla es regresión**); comentar una declaración **equivale a borrarla** y la ausencia de `Seguridad:` **no** se perdona en rigor efectivo `critico` (CA-11); el CRLF completo decide **igual que el LF** en las dos direcciones; y el coste no subió (5 procesos por llamada, una sola pasada de `awk`). **Hallazgos abiertos que le corresponden:** `SEC-024 (contrato)`, `SEC-025 (contrato)`. |

**No van al campo `Hallazgos abiertos:` de estos dos REQ, y queda dicho por qué:** `H-06`
(`contrato`, ajeno, ≤1.30.x, idéntico en los dos árboles), la **segunda cara de SEC-024** (la clave
fabricada, `allow` desde 1.30.3), **SEC-028** (`instrumento`) y **SEC-029** (`contrato`, pero **no
atribuible** a ninguno de los dos: entró en 1.29.3 y no lo produjo ni lo empeoró ninguna de estas dos
comisiones). Los cuatro van con dueño y ventana propios.

### ¿Veto? — **NO veto la ventana; NO firmo REQ-016; y la publicación no está delegada**

**No hay veto.** Un veto es el freno formal para un fallo sin remedio en proceso, y aquí el remedio
está especificado, es acotado (una comprobación cerrada más un caso de banco con fail-before, y dos
cláusulas de prosa), tiene dueño y queda **una vuelta de las tres**. El mecanismo ordinario —`REQ-016`
no cierra sin `Seguridad: aprobado`, y `guard-completado` lo exige por ser `critico`— hace el trabajo
sin necesidad de bloquear el REQ.

**Lo que sí digo con todas las letras:** **1.32.1 no se puede publicar como el parche que cierra el
fail-open de la cita**, porque sobre el árbol de hoy la puerta sigue cerrando un REQ `critico` sin
auditoría aprobada por dos vías medidas. Publicarla así repetiría, en la versión que remedia un fallo
en abierto, la clase de afirmación que la produjo. Y la decisión **no es mía ni de la coordinadora**:
con SEC-020, SEC-024, SEC-025 y el `contrato` de `docs/PENDIENTES.md` abiertos, la condición *«todo en
verde»* de la delegación del propietario (`AGENTS.md` §4/§6) **no se cumple**, así que la fusión, el
tag y la publicación vuelven a Juan.

**Condición de mi no-veto — una, y es la de SEC-029:** que el nombre del proyecto consumidor salga de
`CHANGELOG.md:1615` **en el mismo commit** de esta ventana, junto con las métricas que son huella de
ese proyecto. `CHANGELOG.md` ya está declarado en el campo `Archivos:` de los dos REQ, así que no
cuesta una comisión ni un REQ nuevo. **Si se publica 1.32.1 sin eso, mi no-veto no lo cubre:** es la
regla que `AGENTS.md` §4 pone por delante de todas las demás en este repositorio, y llevar un tag
nuevo sobre un árbol que la incumple es publicarla otra vez a sabiendas.

**Rigor: no subo ninguno.** Los dos REQ ya son `critico` y `Sensible a seguridad: sí`, que es el
suelo. Nada que bajar, y nada que subir.

---

## Revisión R-008 — firma de la ventana 1.32.1: verificación de cierre de SEC-024 y SEC-025 (REQ-015, REQ-016) — 2026-09-07

**Alcance — comisión acotada, no auditoría nueva.** Verificar el cierre de los dos hallazgos que
abrí en R-007, dictaminar la clase de la regresión de coste que la coordinadora trajo (`H-07`), y
firmar. No se reabre nada de lo que R-007 ya dio por bueno. Archivos leídos: `hooks/lib.sh`,
`hooks/guard-completado.sh`, `hooks/campos-req.awk`, `skills/arnes-upgrade/SKILL.md`,
`requirements/REQ-016.md`, `AGENTS.md` §13, `templates/AGENTS.md.tpl`, `CHANGELOG.md`,
`docs/PENDIENTES.md` y el informe de QA de la vuelta 3.

**Orden de firmas: respetado.** `QA: aprobado (vuelta 3, 2026-09-07)` en los dos REQ **antes** de
esta revisión (`AGENTS.md` §6). Los dos siguen en `en-revisión`. Ninguna auditoría preventiva.

**Método.** Sondas propias contra `hooks/guard-completado.sh` sobre un fixture aislado del
directorio temporal de la sesión, con `CLAUDE_PROJECT_DIR` apuntado al fixture y con la regla de que
**la ausencia de decisión es `allow`**. El árbol de la vuelta 2 se reconstruyó desde los mismos
blobs colgantes que identificó QA (`088bdd0d` para `lib.sh`, `a7abd97f` para `guard-completado.sh`),
verificados por contenido: **ninguno de los dos tiene `ARNES_CR_INTERIOR`**. **No se repitieron** las
mediciones publicadas por QA (banco 827/0/1, fuzz de 250 con `deny→allow = 0`, las cuatro bocas,
CA-09 por números de línea): se dan por buenas. Lo que sí se midió aquí de nuevo, y se dice por qué:
(a) las cinco sondas de SEC-024, porque son **mías** y su reproducción es lo que se me pidió firmar;
(b) la afirmación **estructural** del orden, por enumeración cerrada de los descuentos de CR y no por
lectura del comentario que la afirma; (c) el coste sobre documentos de **líneas normales**, porque
QA sólo midió la línea única gigante y la conclusión cambia (SEC-030).

**Veredicto: REQ-015 `aprobado`; REQ-016 `con-hallazgos` — no firmo REQ-016.** Motivo en una línea:
el código de SEC-024 está cerrado y medido, pero **el control no existe en ningún contrato** —
ningún criterio de REQ-016, ninguna fila de `AGENTS.md` §13, ninguna de `templates/AGENTS.md.tpl`
nombran el CR—, y ésa es exactamente la condición de write-back que **SEC-024 dejó escrita por
adelantado en R-007** y que `AGENTS.md` §9 llama deriva. No es veto: el remedio es prosa de analista,
no cuesta código ni gasta una vuelta dev↔QA.

---

### SEC-024 — Estado: `abierto` → **`en-mitigación`**. El código cierra las dos caras; **el write-back no existe**

#### Lo que SÍ está cerrado, medido por mí hoy sobre el árbol en revisión

Fixture aislado, `Write`, base del corpus del banco (`critico`, `QA: aprobado`, **ninguna**
declaración de `Seguridad:`, que deniega por motivo propio):

| # | Sonda | R-007 (v2) | **hoy** |
|---|---|---|---|
| 1 | la base desnuda | deny *(ausente)* | **deny** *(ausente)* |
| 2 | + rango **bien escrito** citando `Seguridad: aprobado` | deny *(ausente)* | **deny** *(ausente)* |
| 3 | + el **abre fabricado** `<!`+CR+`--` citando `aprobado` | **ALLOW** | **deny** *(por el CR)* |
| 4 | control: el mismo `<!`+CR+`--` citando `pendiente` | deny *(pendiente)* | **deny** *(por el CR)* |
| 5 | la **clave fabricada** `Seg`+CR+`uridad: aprobado` | **ALLOW** | **deny** *(por el CR)* |
| 6 | REQ entero en **CRLF**, comentario bien escrito, todo verde | allow | **allow** |
| 7 | control LF de la 6 | allow | **allow** |
| 8 | CR en el **cuerpo** (tras `## `), todo verde | — | **allow** |
| 9 | **reabrir** con CR interior (`Estado: en-progreso`) | — | **allow** |

Las dos filas que exigí mover —**3** y **5**— se movieron. El motivo cita la línea con el CR escrito
`\r`. CRLF y LF deciden idéntico; la guarda no invade el cuerpo y no bloquea la salida.

#### La afirmación estructural, que es lo que en R-007 objeté: **verificada, y por enumeración cerrada**

En R-007 dictaminé que la propiedad «ningún carácter se descuenta antes de escanear el rango» se
sostenía **por inspección** y envejecía con el siguiente `grep` que alguien no hiciera (SEC-028). La
comprobé de la única forma que no repite ese defecto — enumerando **todos** los descuentos de CR del
mecanismo y situando cada uno respecto del escáner:

| Descuento | Función | Posición respecto al escáner |
|---|---|---|
| `lib.sh:255` | `arnes_sin_cr_transporte` (CRLF→LF + CR final) | **antes**, pero **no puede fabricar**: sustituye por salto de línea y el escaneo es por línea |
| `lib.sh:501` | `arnes_norm_ident` | no toca cabecera (identidad de agente) |
| `lib.sh:1158` | `arnes_cola_pendientes` | no toca cabecera (cola de aprobaciones) |
| `lib.sh:1384` | `arnes_norm_campo` | **después** (aguas abajo de `arnes_campo_linea`) |
| `lib.sh:1643/1646` | **la guarda**, en `arnes_sin_cita` | **primera sentencia** de la función |
| `lib.sh:1677` | `arnes_norm_clave` | **después**: vía `arnes_campo_linea` (1671) y, en `arnes_estado_cabecera`, tras el `arnes_sin_cita` de la línea 1852 |
| `campos-req.awk:63` | `gsub(/\r/,"")` | **después** de `sincita($0)` (línea 62) |

Y no hay un segundo escáner de cabecera: los **dos** bucles que recorren cabecera en bash
(`arnes_campos_req:1818` y `arnes_estado_cabecera:1852`) pasan cada línea cruda por
`arnes_sin_cita`, y `arnes_campo_linea` es la única puerta de entrada. **El orden queda por
construcción**, como afirma el desarrollador. Suscribo la afirmación: era mi objeción de fondo y
está contestada. (SEC-028 **no se cierra por esto**: sigue faltando la guarda que impida que un
descuento **futuro** se ponga en el lado equivocado; queda como estaba, `instrumento`, 1.33.0.)

#### Lo que NO está cerrado, y es lo que me impide firmar: **el control no está en ningún contrato**

Medido hoy sobre el árbol en revisión:

```
requirements/REQ-016.md      criterios CA-01..CA-11  -> ninguna mención del CR
AGENTS.md §13                tabla de invariantes    -> ninguna fila del CR
templates/AGENTS.md.tpl      tabla de invariantes    -> ninguna fila del CR
requirements/README.md                               -> ninguna mención
```

El control vive **sólo** en el código, en 19 casos de banco y en este registro. Eso es literalmente
lo que mi propia remediación de SEC-024 prohibió por adelantado en R-007: «*el control no vive sólo
en el código ni sólo en este registro. Va a **criterio** de REQ-016 —extensión de CA-03 o un CA
nuevo— enunciado **por propiedad**, con el sitio único donde vive la lista exhaustiva de caracteres y
los ejemplos marcados **no exhaustivos**. Dueño del write-back: `analista-requerimientos`*». El
analista hizo el write-back de **SEC-025** (CA-09) y no el de **SEC-024**.

**Y no es formalismo — el hueco es exacto y se puede nombrar: CA-02 contrata el agujero; nada
contrata el tapón.**

1. **CA-02 prohíbe que un rango añadido convierta un `deny` en `allow`** —y su cláusula
   anti-coartada nombra el delimitador fabricado—. Eso contrata el **fallo**. No contrata la
   **respuesta elegida**: la puerta podría cumplir CA-02 reconociendo `<!\r--` como abre (salida que
   el desarrollador descartó **con razón**, porque vuelve a fabricar). El control que sí se
   construyó —«una cabecera que no se puede medir no deja pasar», aplicada al carácter— no lo exige
   ningún criterio.
2. **La segunda cara no la cubre CA-02 en absoluto.** `Seg`+CR+`uridad: aprobado` no lleva rango
   ninguno; en R-007 dejé escrito que **no desmentía ningún criterio** (CA-01 se cumple: los dos
   lectores fabrican igual). Hoy la puerta la **deniega**. Es un cambio de conducta de la puerta que
   **ningún criterio describe**, en ninguna dirección.
3. **Y estrecha CA-04 en un punto, sin decirlo.** Medido: `Estado: comple`+CR+`tado` **con todos los
   veredictos en verde** ahora **deniega**. Es la dirección correcta y lo suscribo — pero es
   fricción nueva sobre documentos que ningún contrato declara malformados.

**Las tres consecuencias, y la primera es la que pesa:**
- **Un control que ningún criterio contrata se puede retirar en la ventana siguiente y nada lo
  notará** salvo 19 casos de banco cuya justificación vive en un comentario. Es exactamente la clase
  de regresión silenciosa que este arnés existe para cazar y que mi propio mandato me obliga a
  perseguir entre iteraciones.
- **Un proyecto hereda una puerta que le denegará el cierre por un carácter invisible y no hereda
  ninguna frase que lo diga.** La fila de §13 habla del rango sin cerrar; del CR, nada. Y `AGENTS.md`
  §13 advierte, con la medición delante, que «la fricción termina con alguien apagando el guard».
- **Es la misma clase que yo mismo bloqueé hace una vuelta.** SEC-025 fue `contrato` y bloqueó por
  una frase de un skill. Firmar hoy sería exigirle más rigor a la prosa de una guía que al
  requerimiento, en la misma ventana y con una vuelta de diferencia.

**Remediación — es prosa, no código, y no gasta una vuelta dev↔QA:**
1. **Un criterio nuevo en REQ-016** (CA-12, o extensión de CA-03), enunciado **por propiedad**:
   *una línea de la cabecera que contenga un retorno de carro que no sea el que la termina deja una
   cabecera que no se puede medir, y una puerta que no puede medir no deja pasar → DENY citando la
   línea*; con el **sitio único** donde vive la lista exhaustiva de caracteres de control y su
   tratamiento (`hooks/lib.sh`), y los ejemplos marcados **no exhaustivos** (el **abre fabricado**,
   la **clave fabricada**). Debe declarar además las dos fronteras medidas y conformes: el CR que
   **termina** la línea es transporte y no cuenta (CRLF decide igual que LF), y la guarda **no**
   bloquea reabrir un REQ. Dueño: `analista-requerimientos`.
2. **Una fila en la tabla de `AGENTS.md` §13 y la misma en `templates/AGENTS.md.tpl`** — los dos
   archivos ya están declarados en el campo `Archivos:` de REQ-016, así que no cuesta un REQ nuevo.
3. **Nada más.** El código está construido y medido; el banco lo certifica con fail-before. No pido
   ni una línea de código.

**Por qué esto NO gasta la cuarta vuelta, que es la pregunta que la coordinadora tiene que
resolver:** el tope de `AGENTS.md` §6 es de **vueltas dev↔QA**. Aquí no interviene el desarrollador
—no hay código que cambiar— y la validación de QA contra el criterio nuevo es la **relectura** de
mediciones que ya publicó (19 casos de la sección 36-5, las cinco sondas, el fuzz de 250). Es una
comisión de analista.

**Y por qué el residual declarado NO es aplicable a esto** (sí lo es a `H-07`, más abajo): un
residual **declara un defecto que se acepta**. Lo que falta aquí no es un defecto que aceptar, es
**el documento que dice qué se construyó**. Aceptar deriva como residual es aceptar que el contrato
no describe la máquina — lo único que `AGENTS.md` §9 no permite acordar. Si la coordinadora juzga
que sí gasta vuelta, la salida correcta no es el residual: es `Estado: bloqueado` y subirlo al
propietario.

- **Severidad:** alta (por lo que cubre) · **Clase:** `contrato` · **Estado:** **`en-mitigación`**
  (código cerrado y medido; write-back abierto) · **REQ:** REQ-016 (**sigue bloqueando su cierre**)
  · **Dueño:** `analista-requerimientos`.

#### Residual de SEC-024, nuevo y medido: el **bloque derivado** sigue publicando el veredicto fabricado

La guarda vive en la puerta. La transcripción `hooks/campos-req.awk`, que alimenta el bloque
derivado de `docs/ESTADO.md`, **no la tiene** —a propósito: sólo observa, para que los dos lectores
sigan devolviendo lo mismo byte a byte (CA-01)—. Medido hoy sobre las dos cabeceras no medibles:

```
REQ-971 (Seg\ruridad: aprobado)   -> completado aprobado aprobado sí critico
REQ-972 (<!\r-- ... aprobado -->) -> completado aprobado aprobado sí critico
```

Es decir: el bloque de continuidad que la coordinadora y el humano leen para decidir «todo en verde»
muestra `Seguridad: aprobado` sobre una cabecera que la puerta **se niega a medir**. No es un
fallo en abierto de la puerta —el cierre se deniega— y **no desmiente ningún criterio** (CA-01 exige
que los dos lectores coincidan, y coinciden). Se registra porque el bloque derivado existe
precisamente para no mentir cuando más falta hace, y aquí muestra un veredicto que nadie emitió y que
la máquina no honra. `tools/arnes-lectura.sh` **sí** lo nombra (`<cabecera no medible>`, `rc=1`,
medido por QA), así que la superficie que se consulta a propósito está honesta.

- **Clase:** `instrumento` (**no bloquea**) · **Dueño:** `desarrollador` · **Ventana:** 1.33.0, junto
  a la comprobación por estado de SEC-025, que es el mismo trabajo.

---

### SEC-025 — Estado: `abierto` → **`mitigado`** en su mitad bloqueante

Verificado sobre `skills/arnes-upgrade/SKILL.md` §`Hacia 1.32.1` tal como está hoy:

- **La frase de completitud que dictaminé ya no existe.** Barrido propio de once patrones
  (`los únicos`, `el único`, `son todos`, `exhaustiv`, `basta con`, `garantiza`, `cubre todas`,
  `no hay más`, `todos los que`, `completo`, `suficiente`) sobre las 129 líneas del apartado: las
  únicas coincidencias son **«no exhaustivos»** (dos veces), que es lo contrario de una promesa, y
  un «aparece completo» que habla del bloque derivado de REQ-015 y no de ningún barrido.
- **La propiedad se enuncia por ESTADO y antes de los barridos:** «*cuáles de tus REQ en estado
  terminal NO cerrarían hoy, leídos con el lector de esta versión*», con la razón de por qué no
  envejece («no describe ninguna vía»), y con la frase que exigí: **«Ningún comando de este apartado
  la responde todavía»**, su ventana (1.33.0) y el procedimiento manual entretanto.
- **Las tres declaraciones acompañan al comando, en el mismo sitio:** que interroga **una vía y no la
  propiedad**; el **nombre** de las dos vías que el `awk` no encuentra (abre fabricado y clave
  fabricada, cada una con su porqué); y, literal, **«no hallar nada NO acredita ausencia de
  exposición»**. Con sitio único (`registro-seguridad.md`, SEC-024 y SEC-025) y marca **no
  exhaustivos**. Y cierra con «*Si el `awk` no saca nada, no has terminado: vuelve a la pregunta de
  estado*», que es la conducta que el criterio compraba.

Lo que sustituye a la frase **no promete lo que no puede dar**: eso era lo que había que dictaminar
y queda dictaminado. La **mitad 2** (el barrido por estado como modo de `tools/arnes-lectura.sh`)
sigue **abierta**, `instrumento`, dueño `desarrollador`, ventana 1.33.0 — como se declaró.

**Observación sin clase, para el próximo write-back de CA-09.** El apartado ofrece un comando
(`git log --oneline -- docs/ESTADO.md`, línea 634) **antes** de la propiedad (línea 677), y CA-09 (i)
dice «antes de ofrecer **ningún** comando». Coincido con QA en no abrirlo: ese comando es de la
migración de **REQ-015**, la propiedad precede a **todo barrido por vía** —que es la conducta que el
criterio compra—, y la lectura hiperliteral haría CA-09 (ii) insatisfacible. Es un criterio más
estricto que la realidad, no más ancho: **envejece hacia el lado que cierra**, y por eso no es
hallazgo. Al próximo toque de CA-09, acótese la palabra: «antes de ofrecer ningún **barrido por
vía**».

---

### `H-07` — la regresión de coste: **mi clase es `instrumento`**, y con una razón más fuerte que la de QA

Se me pidió dictaminar sin deferencia a la coordinadora ni a QA, y en particular contestar a esto:
*¿un umbral de agotamiento que baja un 36 % sobre una puerta cuya muerte es un fallo en abierto es
`instrumento` o `contrato`?* La respuesta corta: **el hallazgo tal como está descrito es
`instrumento` y no bloquea; y la pregunta destapa otra cosa, que sí es `contrato` y que no es de
estos dos REQ — va como SEC-030.**

**Lo que medí yo, porque QA sólo midió una línea única gigante y la conclusión cambia.** Un `Write`
de un REQ con cabecera normal de seis líneas, `## Notas` cerrándola y un cuerpo de líneas ordinarias
de 79 caracteres, contra el árbol de la vuelta 2 y el de hoy (máquina descargada, `load` 0,30; dos
repeticiones en los dos tamaños grandes):

| Tamaño del REQ | vuelta 2 | **hoy** |
|---:|---:|---:|
| 64 KB | 0,20 s | 0,34 s |
| 231 KB | 1,33 s | 1,26 s |
| 512 KB | 6,49 · 6,30 s | 6,27 · 7,33 s |
| 1 024 KB | 26,02 · 26,45 s | 27,68 · 28,05 s |

**Sobre documentos ordinarios el parche no añade nada** (0–6 %, dentro del ruido en tres de los
cuatro tamaños). El régimen que el parche multiplica por ~3 es **sólo** el de la línea única de
cientos de kilobytes, que sí es patológica. Eso **refuerza** la clase `instrumento`, y por una razón
que no es la de QA («callar no es mentir») sino una medición: lo único que la vuelta 3 degrada es el
reloj del **banco** —un instrumento— y un régimen de entrada que ningún documento real produce.

**Y por qué no es `contrato`, dicho contra la letra:**
- Ningún criterio de REQ-015 ni de REQ-016 fija techo de reloj; CA-08 declara su magnitud
  (**procesos**, con el matiz **operativo**) y se cumple.
- La puerta **sigue decidiendo lo mismo** en todo el rango medido: 40 PASS en los tres árboles de la
  sección 32, y mis nueve sondas deciden idéntico. Ninguna decisión cambia; cambia el reloj.
- Bloquear REQ-016 por esto convertiría el defecto de coste de un **control** en condición para
  cerrar la función entregada — que es exactamente lo que la clase `instrumento` existe para impedir
  (`requirements/README.md`).

**Residual declarado: aplicable, y lo acepto tal como QA lo redactó**, con el vencimiento afinado.

| | |
|---|---|
| **Hallazgo** | `H-07 (instrumento)` — `arnes_sin_cita` es cuadrática en la longitud de línea por `${l%$'\r'}` |
| **Dueño** | `desarrollador` |
| **Ventana** | 1.33.0 |
| **Forzador medido, y ya está armado** | el banco completo pasa de **60 s**: hoy **92,1 s** en Linux descargado, contra ~40 s en la vuelta 2. No es una promesa: es un número que ya está por encima del único umbral de reloj que este proyecto nombra |
| **Vencimiento** | el cierre de 1.33.0. Si 1.33.0 se publica sin el arreglo, sube a decisión humana con el número delante |

**Lo que sí se pierde y no se tapa:** el banco es la puerta requerida de `main` y su reloj se ha
multiplicado por ~2,3. Lo paga cada PR de este repositorio hasta que se arregle.

---

### SEC-030 — El **agotamiento del temporizador** es un fallo en abierto que ningún documento declara, y el coste de la puerta es cuadrático en el tamaño del documento que juzga — alcanzable con contenido **ordinario**

- **Severidad:** alta · **Clase:** `contrato` · **Estado:** `abierto` · **REQ:** — (**no atribuible**
  a REQ-015 ni a REQ-016; **no** va a su campo `Hallazgos abiertos:` y **no bloquea esta ventana**)
  · **Dueño:** `analista-requerimientos` (el NFR y la prosa) y `desarrollador` (el coste)
  · **Ventana:** 1.33.0
- **Ubicación:** `AGENTS.md` §13 (la tabla de invariantes y la enumeración de lo que el guardián
  **no** cubre), `templates/AGENTS.md.tpl` (la misma tabla), `requirements/README.md`; y el coste, en
  el camino de decisión de `hooks/guard-completado.sh`.
- **La afirmación y el hecho.** `AGENTS.md` §13 promete, sin condición, que `guard-completado`
  **deniega** el cierre cuando los veredictos no lo autorizan, y enumera con cuidado lo que **no**
  cubre —intérpretes, heredocs indirectos, formateadores, `patch`/`git apply`—. `AGENTS.md` §7 dice,
  en otro sitio y con otro propósito, que «un hook `PreToolUse` muere a los 60 s, **y un hook muerto
  no deniega**». Las dos frases juntas describen un fallo en abierto que **ninguna de las dos
  declara como tal**, y que **no está en la enumeración de huecos** de §13. Una enumeración de lo que
  un control no cubre envejece **hacia el lado que abre** en cuanto aparece un hueco que no está en
  ella: es la misma forma de SEC-015 y SEC-025, y por eso la clase es la misma.
- **Y no es teórico, que es lo que esta revisión aporta.** Medido hoy (tabla de `H-07`): un REQ de
  **líneas ordinarias** cuesta **26–28 s** a 1 MB y **6–7 s** a 512 KB, con crecimiento cuadrático en
  el tamaño **total** del documento — **idéntico en la vuelta 2 y hoy**, así que el defecto
  **preexiste a esta ventana y no lo produjo**. La pared de 60 s se alcanza hacia **~1,5 MB de un
  documento perfectamente normal**. La calificación de «entrada patológica» vale para la línea única
  de un megabyte; **no** vale para esto. Y el tamaño no es hipotético: este mismo repositorio
  documenta un proyecto real con un REQ de **231 KB** en un corpus de 3,7 MB, y la rotación —que es
  el mecanismo que existe para que los artefactos no crezcan sin tope— **viene apagada por defecto**.
- **Riesgo.** Por encima de la pared, la puerta no deniega **y tampoco dice que no pudo medir**: es
  el fallo silencioso, en la dirección que abre, de la única puerta que impide cerrar un REQ
  `critico` sin auditoría. Es la misma propiedad que esta ventana acaba de aplicar al **carácter**
  («una puerta que no puede medir no deja pasar»), sin aplicar al **reloj**.
- **Remediación, en dos mitades, y la primera es la que sostiene:**
  1. **Declararlo.** El hueco entra en la enumeración de §13 y en `templates/AGENTS.md.tpl` con su
     número medido y su fecha, enunciado por propiedad: *por encima de cierto tamaño de documento la
     puerta no llega a decidir y el runtime la mata; un guardián muerto no deniega*. Es la frase que
     hoy falta y que un proyecto necesita para no confiar en lo que no tiene.
  2. **Acotar el coste.** El camino de decisión no debe ser cuadrático en el tamaño del documento.
     La forma la decide el `desarrollador`; **no escribo código**. Y se deja dicho lo que no se puede
     arreglar por esa vía: si el runtime mata el proceso, **nada que el hook haga puede denegar**, así
     que la mitigación real es mantener el coste lejos de la pared y **declarar el límite** — no
     prometer una puerta que se apaga sola.
- **Por qué no bloquea esta ventana.** No es atribuible: medido en los dos árboles, idéntico. Mismo
  criterio que apliqué a SEC-029 en R-007 —`contrato`, pero fuera del campo `Hallazgos abiertos:` de
  unos REQ que no lo produjeron ni lo empeoraron—. Empeorar un régimen patológico en ×3 (lo que sí
  hizo esta ventana) es `H-07`, y es `instrumento`.

---

### La escritura por consola sobre archivo protegido: **cuarto forzador, y no cambia mi dictamen**

El `desarrollador` declaró haber cambiado `CASOS_ESPERADOS` de `tests/escenarios/hooks/run.sh` una
vez con `python3` desde `Bash`, y haber enrutado por `Edit` todas las posteriores. Es el **agujero
del intérprete** que `AGENTS.md` §13 documenta como hueco conocido y **declarado a propósito**, y la
declaración voluntaria es la conducta correcta: la barandilla avisa del descuido, no contiene a quien
se empeña, y quien la rodea lo dice.

**Dictamen: se suma como cuarto forzador medido de REQ-011 (la puerta posterior) y nada más.** No
cambia lo que dictaminé en R-007 —«pide un control, y ya está dotado»—: la clase tiene dueño, ventana
y REQ propio. Lo que sí anoto, porque es lo que un cuarto caso añade sobre el tercero: los cuatro han
salido de agentes que **declararon** el desvío, así que la serie mide la frecuencia del descuido, no
la del intento de rodeo, y **no acredita nada sobre el segundo**. Un control que sólo ve lo que le
cuentan no puede usar su propia cuenta como prueba de cobertura. La puerta posterior sigue siendo la
respuesta, y sigue en 1.33.0.

---

### SEC-029 — **condición de mi no-veto: cumplida**

Verificado hoy: `CHANGELOG.md:1675` dice ahora «**Medido en un proyecto real, con el control de
plataforma hecho**», y el nombre del proyecto consumidor **no aparece** en ninguna ruta versionada.
Las métricas que quedan van explícitamente atribuidas al **fixture reproducido aquí** («Reproducido
aquí con un fixture del mismo tamaño —47 REQ, 3,7 MB, uno de 231 KB—»), que es la cifra que en R-007
dije que valía: **son el defecto, no la huella**. Residual aceptado y dicho: la **forma** del corpus
sobrevive por transitividad («del mismo tamaño»); un tamaño sin nombre no es atribuible a nadie, así
que se acepta.

Barrido de la ventana, en la misma pasada y sin hallazgos: ningún patrón de credencial (`ghp_`,
`github_pat_`, `AKIA…`, `-----BEGIN`, `api_key=`, `token=`, `password=`) en lo añadido;
`insumos/`, `reporte-arnes-*` y `.env` **no** están en el índice.

**Estado de SEC-029:** `abierto` → **`en-mitigación`**. La decisión del propietario (historial y tags
como están, con el residual declarado; `docs/PENDIENTES.md`) es suya y la registro sin objeción: es
proporcionada y es la que yo mismo recomendé. Pasa a `mitigado` cuando el **barrido de base** exista
como NFR de `gobernanza-datos.md` §3 y se haya corrido entero una vez (1.33.0; dueño del NFR:
`auditor-seguridad`).

---

### No-regresión contra la línea base de R-007 — medida, no leída

La vuelta 3 tocó `hooks/lib.sh`, archivo que **REQ-015 declara**. En R-007 me comprometí a
re-confirmar con una relectura dirigida. Se hizo mejor que eso, por diferencia mecánica contra el
árbol de la vuelta 2:

- **`hooks/lib.sh` — el parche es puramente aditivo.** De 1 881 a 1 888 líneas; el `diff` sólo
  registra **tres** líneas modificadas, y las tres son el comentario de firma de `arnes_sin_cita`, su
  reinicio de estado y un comentario de cierre. **Nada se eliminó.** `arnes_tmp_publicacion` y
  `arnes_purga_tmp` están byte a byte como los firmé: componente propia del proceso (`BASHPID`),
  **fail-closed** si no se obtiene (`return 1` sin caer al nombre compartido), purga antes de
  publicar. Ningún `flock` introducido (CA-04 de REQ-015: sigue sin exigirse).
- **`hooks/guard-completado.sh` — también aditivo**: una declaración `local` extendida y tres bloques
  añadidos. Nada retirado.
- **Los controles de REQ-016 que declaré línea base siguen en pie, comprobados por conducta:**
  CA-03 (rango que abre y no cierra → deny citando el rango), **CA-04 (la tolerancia de clave
  decorada NO se recortó**: `**Seguridad:** pendiente` → deny, `**Seguridad:** aprobado` → allow, con
  `**Estado:**` decorado también), CA-11 (`Seguridad: pendiente` comentada en `critico` → deny), y
  CRLF idéntico a LF en las dos direcciones.

**Ninguna regresión.**

---

### Estado de seguridad aprobado por REQ — ventana 1.32.1 (línea base de no-regresión, sustituye a la de R-007)

| REQ | Veredicto | Fecha | Versión | Motivo / controles acreditados |
|---|---|---|---|---|
| **REQ-015** | **`aprobado`** | 2026-09-07 | candidata 1.32.1 | Se mantiene la firma de R-007, **re-confirmada por diferencia mecánica** contra el árbol de la vuelta 2: el parche de la vuelta 3 sobre `hooks/lib.sh` es puramente aditivo y no toca `arnes_tmp_publicacion` ni `arnes_purga_tmp`. **Controles acreditados, y debilitarlos es regresión:** (a) temporal de publicación con componente **propia del proceso** en los puntos de publicación de `estado-derivado.sh` y `rotar-artefactos.sh`, **fail-closed** si no se obtiene; (b) la purga retira los temporales **sin dueño vivo** y conserva el del proceso vivo y los ajenos; (c) el destino queda **byte a byte** en todo camino de fallo; (d) **no** hay `flock` ni serialización, y CA-04 declara que no se exige; (e) CA-08 corrigió la promesa **incondicional** de `AGENTS.md` §13 y de `templates/AGENTS.md.tpl` a **dos mitades nombradas** — volver a afirmarla sin condición es regresión de herencia (SEC-015). **Hallazgos abiertos: (ninguno).** |
| **REQ-016** | **`con-hallazgos`** | 2026-09-07 | candidata 1.32.1 | **No firmo.** El código de **SEC-024** está cerrado y medido en las dos caras y en las cuatro bocas —lo verifiqué—, pero **el control no existe en ningún contrato**: ni criterio en REQ-016, ni fila en `AGENTS.md` §13, ni en `templates/AGENTS.md.tpl`. Es la deriva que `AGENTS.md` §9 nombra y la condición de write-back que SEC-024 dejó escrita **por adelantado** en R-007. CA-02 contrata el agujero; **nada contrata el tapón**, y la segunda cara (la clave fabricada) no la cubre CA-02 en absoluto. **SEC-025** queda **cerrada** en su mitad bloqueante. **Lo que SÍ queda acreditado y es línea base de no-regresión:** el interior de un rango no declara campo en los **dos** lectores y en `tools/arnes-paralelo.sh`; un rango que abre y no cierra deniega **citando el rango** y nunca permite por **ausencia** (CA-03); **una cabecera con un CR que no la termina no se puede medir y no deja pasar**, en las cuatro bocas, con el orden garantizado **por construcción** (la guarda es la primera sentencia del único escáner, verificado por enumeración cerrada de los siete descuentos de CR del mecanismo); la tolerancia de clave decorada **fuera** de los rangos **no se recortó** (CA-04: recortarla reabriría un fail-open real); comentar una declaración **equivale a borrarla** y la ausencia de `Seguridad:` **no** se perdona en rigor efectivo `critico` (CA-11); CRLF decide **igual** que LF; el cuerpo y la reapertura **no** se bloquean. **Hallazgos abiertos que le corresponden:** `SEC-024 (contrato)` —sólo el write-back— y `H-07 (instrumento)`. |

**No van al campo `Hallazgos abiertos:` de estos dos REQ, y queda dicho por qué:** `H-06`
(`contrato`, ajeno, ≤1.30.x), **SEC-028** (`instrumento`), **SEC-029** (`contrato`, no atribuible;
decisión del propietario tomada), **SEC-030** (`contrato`, **no atribuible**: medido idéntico en los
dos árboles) y el **residual del bloque derivado** de SEC-024 (`instrumento`). Los cinco con dueño y
ventana propios.

### ¿Veto? — **NO. No firmo REQ-016, y falta una comisión de analista, no una vuelta de desarrollo**

**No hay veto.** Un veto es el freno formal para un fallo sin remedio en proceso. Aquí el código está
construido, medido y certificado con fail-before; lo que falta es **un criterio y dos filas de
tabla**, con dueño (`analista-requerimientos`), sin código y sin CI. El mecanismo ordinario
—`guard-completado` no deja cerrar un `critico` sin `Seguridad: aprobado`— hace el trabajo sin
bloquear nada.

**Sobre la publicación, y no ha cambiado desde R-007 salvo por dos hallazgos menos.** La delegación
del propietario (`AGENTS.md` §4/§6) se activa **con todo en verde**. Siguen abiertos SEC-020
(`contrato`), el `contrato` de `docs/PENDIENTES.md` sobre el agujero del intérprete, el write-back de
SEC-024 y ahora SEC-030. **La fusión, el tag y la publicación siguen siendo decisión de Juan**, no
mía ni de la coordinadora. Lo digo igual que en R-007 y por el mismo motivo, no por inercia: dos de
los cuatro que nombré entonces están cerrados, y los que quedan no los cierra esta ventana.

**Rigor: no subo ninguno.** Los dos REQ ya son `critico` y `Sensible a seguridad: sí`, que es el
suelo. Nada que subir y nada que bajar. **Ningún REQ cerrado se reabre por esta revisión.**

---

## Revisión R-009 — la firma de REQ-016: verificación del write-back de SEC-024 — 2026-09-07

**Alcance declarado, y es lo único que miré.** Comisión de firma, no de auditoría. Verifiqué tres
textos y nada más: `CA-12` nuevo y la frontera de `CA-04` en `requirements/REQ-016.md`, y las dos
filas de invariante en `AGENTS.md` §13 y `templates/AGENTS.md.tpl`. **No** re-medí SEC-024 ni
SEC-025 —su cierre en el código quedó verificado en R-008 y el write-back no toca código: lo
confirmé por diferencia, el parche del analista es puramente aditivo sobre el REQ y una fila en cada
uno de los dos documentos—. No re-litigo SEC-030, `H-07` ni el residual del bloque derivado.

### SEC-024 — Estado: `en-mitigación` → **`mitigado`**. El tapón está contratado

Lo que en R-008 nombré exacto —«**CA-02 contrata el agujero; nada contrata el tapón**»— ya no es
cierto. Verificado punto por punto:

| Lo que exigí en R-008 | Dónde está hoy | Veredicto |
|---|---|---|
| La propiedad enunciada: CR interior → cabecera no medible → **DENY citando la línea** | `REQ-016` CA-12, párrafo 1 | **cumple** |
| **Por propiedad, no por sitio**: no nombra la función del escáner | CA-12: «*no sobre en qué función del lector vive la guarda: reescribir el escáner no lo cambia*» — no aparece `arnes_sin_cita` | **cumple** |
| Las **dos caras** como **una** propiedad, ejemplos **no exhaustivos** | CA-12: delimitador fabricado (`<!`+CR+`--`, `-`+CR+`->`) y clave fabricada (`Seg`+CR+`uridad:`), marcados «no exhaustivos» | **cumple** |
| **Sitio único** de la lista exhaustiva | CA-12: «*viven en un solo sitio: `hooks/lib.sh`*» | **cumple** |
| DENY **por medibilidad y no por veredicto**, y que resolverlo como **ausencia** incumpla | CA-12: `Estado: comple`+CR+`tado` con todo en verde **deniega igual**; «*denegar alegando que el estado no es terminal, o que el campo falta, **también incumple***» | **cumple**, y es la mitad que más me importaba: sin ella, la puerta podría cumplir el criterio por el motivo equivocado y perder la guarda sin que nadie lo midiera |
| Lo que **no** restringe: CR final = transporte, CRLF ≡ LF, cuerpo intacto, reabrir no se bloquea | CA-12, (i)(ii)(iii), con la anti-coartada «*la acotación es de esa clase y sólo de esa*» | **cumple** |
| `CA-04`: la tolerancia de clave decorada **no se recorta** | El texto anterior de CA-04 **no se tocó** (diff: adición pura); la frontera se añade como **acotación de dónde empieza a aplicarse** —«*opera sobre una cabecera MEDIBLE*»— con la anti-coartada de siempre | **cumple** |
| Una fila en `AGENTS.md` §13 y **la misma** en `templates/AGENTS.md.tpl` | `AGENTS.md:349` y `templates/AGENTS.md.tpl:314`, **idénticas byte a byte** (comprobado por `diff`), insertadas **bajo** la fila del rango sin cerrar y apuntando a `guard-completado` | **cumple** |

Lo que hacía a SEC-024 clase `contrato` era su consecuencia, no su forma: *un control que ningún
criterio contrata se puede retirar en la ventana siguiente y sólo lo notarán 19 casos de banco cuya
justificación vive en un comentario*. Hoy el control está en el contrato del REQ, en la tabla de
invariantes del proyecto y en la plantilla que heredan los proyectos por `arnes-upgrade`. Retirarlo
desmiente un criterio y dos documentos.

- **Severidad:** alta (por lo que cubre) · **Clase:** `contrato` · **Estado:** **`mitigado`** ·
  **REQ:** REQ-016 (**deja de bloquear su cierre**) · **Dueño:** `analista-requerimientos` (cumplido).

### La frontera que el analista añadió sin que se la pidieran: **conforme, y no me ata las manos**

CA-12 declara que habla de la **puerta de cierre** y que el bloque derivado publicando el veredicto
fabricado es el residual `instrumento` de SEC-024 (dueño `desarrollador`, ventana 1.33.0), **no
contratado ahí**. Es correcta, y por una razón que va más allá de la comodidad:

1. **Su razón técnica se sostiene.** CA-01 exige que **todos** los lectores devuelvan lo mismo. Sin
   esta frontera, CA-12 leído junto a CA-01 importaría la guarda a la transcripción `awk` —y con
   ella al bloque derivado—, que es exactamente lo que en R-008 acepté **no** hacer en 1.32.1. Un
   criterio que contradice un residual vivo es un criterio que se incumple **a sabiendas**, y eso
   erosiona más que la deuda que pretendía cubrir.
2. **No es una coartada, porque señala dónde vive la deuda.** La frontera cita el registro, la clase,
   el dueño y la ventana. Una acotación que nombra su vencimiento no silencia: reenvía.
3. **No me ata en 1.33.0.** Que CA-12 no contrate el bloque derivado no **autoriza** su conducta: la
   deja fuera de *este* contrato. Cuando 1.33.0 cierre el residual, el control se contrata en el REQ
   que **posee** el bloque derivado, no ensanchando CA-12 — que es además la única forma correcta,
   porque un criterio de la puerta de cierre no debe crecer para cubrir un informe.

**Y la dejo con una condición escrita, para que la frontera no sobreviva a su motivo:** vale mientras
el residual siga **abierto, con dueño y con ventana**. Si 1.33.0 cierra sin la guarda en el bloque
derivado, esta frontera deja de ser una acotación y pasa a ser el sitio donde el control desapareció;
lo revisaré en la firma de esa ventana.

### El residual del bloque derivado: **mantengo `instrumento`**, y digo por qué no lo subo

El analista observa —con razón de fondo— que soy **más blando** de lo que él habría sido: ese bloque
es la superficie sobre la que la coordinadora y el humano deciden «todo en verde» antes de fusionar,
y ahí aparece `Seguridad: aprobado` sobre una cabecera que la máquina se **niega** a medir. No abre
la puerta de cierre, pero puede abrir **la decisión humana que va justo detrás**. La observación es
buena y no la despacho: es exactamente el daño de SEC-024 —una firma que nadie emitió— desplazado un
paso, hacia una autorización **delegada** (propietario, 2026-09-05) cuya condición es literalmente
«todo en verde».

**Mantengo `instrumento`, por tres razones medidas, no por preferencia:**

1. **Existe una superficie de evidencia honesta, y está medida.** `tools/arnes-lectura.sh` **sí**
   nombra la cabecera no medible (`cabecera no medible`, con la línea y el CR representado como
   `\r`, `rc=1`; medido por QA y registrado en R-008). El defecto no es «no hay forma de saberlo»;
   es «una de las dos superficies calla». Eso es un instrumento incompleto, no un fail-open.
2. **La clase no es una escala de gravedad: es una regla de bloqueo.** Subirlo a `contrato`
   detendría el cierre de REQ-016 —y con él la ventana 1.32.1— por un defecto que vive en
   `hooks/estado-derivado.sh` y cuyo remedio pertenece a otro REQ. `AGENTS.md` §6 lo dice sin
   ambigüedad: un defecto **del propio arnés** va a deuda con dueño y **no puede ser condición para
   cerrar** lo que no lo causó.
3. **Tiene dueño y vencimiento, y ahora también un forzador.** Ventana 1.33.0, dueño
   `desarrollador`, junto al trabajo de SEC-025.

**Lo que sí cambio, porque la observación lo merece — no queda en «mantengo y ya»:**

- **Condición operativa mientras el residual esté abierto:** la evidencia de «todo en verde» del
  §6 se lee de `tools/arnes-lectura.sh`, **no** del bloque derivado de `docs/ESTADO.md`, que para
  veredictos es informativo y no acredita. Se lo paso al `analista-requerimientos` para que quede
  contratado donde vive esa decisión —el REQ de 1.33.0 que posea el bloque derivado, o
  `docs/gobernanza/autoalojamiento.md`—. **No** lo exijo para firmar REQ-016: REQ-016 no posee ese
  control, y exigir aquí un control ajeno es la deriva simétrica de la que acabo de cerrar.
- **Vencimiento con consecuencia declarada:** si el residual llega a la firma de **1.33.0** sin la
  guarda en el bloque derivado, **sube a `contrato`** por la vía que el analista nombra —la decisión
  delegada— y bloqueará. Queda escrito aquí para que la subida no dependa de que alguien se acuerde.

### Observación al analista (no es hallazgo, no bloquea)

El campo `Archivos:` de REQ-016 lista las secciones de banco 1 a 4 del caso 36 y **no** la quinta
(`tests/escenarios/hooks/secciones/36-cabecera-comentario-html-5-el-cr-que-no-termina.sh`), que
existe en el árbol. Es el mapa que alimenta la comprobación de disjunción de
`tools/arnes-paralelo.sh`; un archivo que el mapa no declara no entra en esa comparación. No lo
introdujo este write-back —viene del trabajo de código— y no afecta a mi firma; lo anoto para que se
corrija cuando el analista toque el REQ, no como condición.

### Estado de seguridad aprobado por REQ — ventana 1.32.1 (línea base de no-regresión, sustituye a la de R-008)

| REQ | Estado de seguridad | Fecha | Árbol | Controles acreditados (debilitarlos es regresión) |
|---|---|---|---|---|
| **REQ-015** | **`aprobado`** | 2026-09-07 | candidata 1.32.1 | Sin cambios respecto a R-008: el write-back no toca código. Se mantiene íntegra la línea base de R-008 (temporal de publicación propio del proceso y fail-closed; purga que conserva el del proceso vivo y los ajenos; destino byte a byte en todo camino de fallo; **no** hay `flock` ni serialización y CA-04 lo declara; la promesa de `AGENTS.md` §13 y de la plantilla en **dos mitades nombradas**). **Hallazgos abiertos: (ninguno).** |
| **REQ-016** | **`aprobado`** | 2026-09-07 | candidata 1.32.1 | **Firmo.** Se mantiene todo lo acreditado en R-008 —el interior de un rango no declara campo en los dos lectores y en `arnes-paralelo.sh`; el rango sin cerrar deniega **citando el rango** y nunca permite por **ausencia** (CA-03); la cabecera con CR interior no se puede medir y **no deja pasar**, en las cuatro bocas, con el orden garantizado por construcción; la tolerancia de clave decorada **fuera** de los rangos **no se recortó** (CA-04); comentar equivale a borrar y la ausencia de `Seguridad:` no se perdona en rigor efectivo `critico` (CA-11); CRLF decide igual que LF; cuerpo y reapertura no se bloquean— **y se añade lo que faltaba: el control está contratado**. **Línea base nueva y explícita:** (a) **CA-12** contrata la propiedad de medibilidad, **por propiedad y no por sitio**, con las dos caras como una sola, sitio único de la lista exhaustiva en `hooks/lib.sh` y DENY **por medibilidad y no por veredicto** —resolver el caso como **ausencia** incumple—; (b) **CA-04** conserva íntegra la tolerancia y sólo acota **dónde empieza**; (c) la invariante existe **idéntica** en `AGENTS.md` §13 y en `templates/AGENTS.md.tpl`, así que los proyectos la heredan por `arnes-upgrade`: **borrar cualquiera de las dos filas, o desacoplarlas, es regresión de herencia** (misma clase que SEC-015). **Hallazgos abiertos que le corresponden:** `H-07 (instrumento)` y el residual del bloque derivado (`instrumento`, dueño `desarrollador`, ventana 1.33.0). **Alcance de esta firma:** el árbol que QA aprobó en la vuelta 3 más este write-back documental. Cualquier cambio posterior en `hooks/` reabre la revisión. |

### ¿Veto? — **NO. Firmo REQ-016, y la ventana queda sin hallazgo bloqueante**

SEC-024 pasa a `mitigado`; SEC-025 quedó `mitigado` en su mitad bloqueante en R-008. **No queda
ningún hallazgo de clase `usuario/dinero` ni `contrato` abierto** sobre REQ-015 ni REQ-016. Lo que
sigue abierto es `instrumento` con dueño y ventana: `H-07`, el residual del bloque derivado y
SEC-030 (agotamiento del temporizador, ventana declarada).

**Sobre la publicación, y ya sin la salvedad de R-008.** El motivo por el que en R-007 y R-008 dije
que la publicación no estaba delegada era que había hallazgos abiertos que bloqueaban. Ya no los
hay. La delegación permanente del propietario (2026-09-05) opera **con todo en verde**: CI sin FAIL,
SKIP explicados, fail-before/pass-after, QA y auditor aprobados. Los dos veredictos de seguridad
están puestos; comprobar el resto es de la coordinadora, no mío. **Con una condición que sí es mía y
se deriva de esta misma revisión:** la comprobación de «todo en verde» se hace sobre
`tools/arnes-lectura.sh`, no sobre el bloque derivado de `docs/ESTADO.md`, mientras el residual siga
abierto.

---

## Revisión R-010 — auditoría **PREVENTIVA** de REQ-019 y REQ-021, ventana 1.33.0 (`cand/1.33.0`) — 2026-09-07

**Qué es y qué no es.** Es la excepción nombrada de `AGENTS.md` §6: una revisión hecha **antes de que
exista el código**, sobre el diseño y sobre el REQ mismo. Se declara al emitirla —`Seguridad:
preventiva` en los dos REQ— y **no acredita nada construido**. Cuando el código exista, la auditoría
se repite en su turno, después del `qa-tester`. Los dos REQ están `pendiente`, con `QA: pendiente`, y
no hay una línea escrita de ninguno de los dos: `docs/arnes/` no existe y `tests/util/` tampoco.

**Alcance leído:** `requirements/REQ-019.md`, `requirements/REQ-021.md`,
`docs/decisions/ADR-003-adelgazar-agents-md-sin-tocar-la-plantilla.md`, `AGENTS.md`,
`requirements/README.md`, `.arnes/config.json`, `tests/escenarios/hooks/README.md` (invariantes del
banco), el bucle de despacho y la red de limpieza de `tests/escenarios/hooks/run.sh:590-613`, y la
sonda de procesos que hoy vive en
`tests/escenarios/hooks/secciones/37-coste-del-escaner-2-la-seccion-caliente.sh:353-386`.
**Nada ejecutado:** el banco no se corrió, por instrucción de la coordinadora — hay una comisión de QA
midiendo REQ-017 y una corrida ajena le falsea las cifras. Es la misma regla que REQ-021 CA-06 declara
y que el incidente de las 3 h 41 min midió.

**Método.** Lectura de contrato, no de código: se busca la propiedad que cada criterio **no** asegura
y el enunciado que resulta **más fuerte que la verdad**. Dos medidas de apoyo, ambas sobre el árbol
actual y sin ejecutar nada del banco: `diff templates/AGENTS.md.tpl AGENTS.md` da hoy **40 líneas que
sólo existen en la plantilla** y **73 que sólo existen en `AGENTS.md`** (entrada de SEC-033), y
`grep -l 'AGENTS\.md' requirements/REQ-*.md` da **21 de 21** REQ (entrada de SEC-034).

---

### SEC-031 — `contrato` · **abierto** · REQ-019 · severidad alta · dueño `analista-requerimientos`

**La acotación de una promesa puede delegarse mientras la promesa se queda, y entonces lo que queda escrito es MÁS FUERTE que la verdad**

- **Ubicación:** `requirements/REQ-019.md` — CA-02 punto 3 y §«El criterio: qué se queda y qué se va»
  (el filtro de tres preguntas), leídos contra CA-10.
- **La pregunta que contesta:** *¿hay alguna forma de perder una obligación sin borrar texto?* Sí, y
  ésta es la principal: **no se pierde la obligación, se pierde su límite.**
- **Descripción.** El filtro de tres preguntas tiene **dos cajones**: lo que *manda* se queda; lo que
  *explica o justifica* se va. Una **acotación** —«la cobertura sobre `Bash` es parcial a propósito»,
  «un hook muerto no deniega», «es una barandilla, no una jaula»— no cabe en ninguno de los dos: no
  ordena nada, así que falla la pregunta 1 y **se delega por construcción**. Y CA-02 punto 3 lo
  bendice explícitamente: para cada fila de §13 basta que «el texto que describe su **alcance real**»
  exista en `AGENTS.md` **o** en un destino alcanzable por puntero. La tabla de §13 se conserva byte a
  byte (CA-02.1) — y la tabla es una lista de **promesas de cobertura**. Separar la promesa de su
  acotación deja al lector que no salta con un modelo del sistema **más protegido de lo que está**.
- **Por qué esto es seguridad y no estilo.** Es la forma de defecto que este registro ya midió cuatro
  veces —**SEC-015**, **SEC-023**, **SEC-025** y **SEC-030**—: *una enumeración de lo que un control
  no cubre envejece hacia el lado que abre*. Aquí no envejece: se **muda de sede** en un solo cambio.
  CA-10 es asimétrico y por eso no lo ve — prohíbe **añadir** una obligación y no dice nada de
  **restar una acotación**, que es la dirección peligrosa.
- **Consecuencia operativa inmediata, en esta misma ventana.** **SEC-030** está `abierto` con ventana
  **1.33.0** y su remediación 1 es literal: *«el hueco entra en la enumeración de §13 y en
  `templates/AGENTS.md.tpl` con su número medido»*. Si REQ-019 delega esa enumeración antes, la
  declaración de un **fail-open de la puerta de cierre** aterriza en un archivo que nadie lee por
  defecto. Los dos trabajos van en el mismo mes y ninguno de los dos lo dice.
- **Remediación (write-back, `analista-requerimientos`).**
  1. **Criterio nuevo, por propiedad y no por lista:** *toda unidad de texto que **acote** una promesa
    que permanece en `AGENTS.md` —cobertura parcial, hueco declarado, límite de plazo, «no lo
    comprueba ninguna máquina»— deja **en la misma sede que la promesa** el enunciado de la acotación
    **por propiedad**, con el puntero al sitio único donde vive el detalle exhaustivo y la marca «no
    exhaustivo»; sólo la casuística se delega.* La forma ya está escrita en `requirements/README.md`
    §(a) y no hay que inventarla; cuesta una frase por promesa, no bytes.
  2. **Tercer cajón en el filtro:** además de «¿manda?» y «¿explica?», *¿acota?* — y una acotación
     nunca se separa de lo que acota.
  3. **CA-10 simétrico:** el número de **acotaciones que dejan de acompañar a su promesa** es no más
     de 0, con la misma verificación por señalamiento que ya usa para las obligaciones nuevas.
  4. **Orden con SEC-030:** o la declaración del agotamiento del temporizador entra **antes** del
     reparto, o el reparto la trata como acotación bajo la regla 1. Se acuerda al despachar, no
     después.

---

### SEC-032 — `contrato` · **abierto** · REQ-019 · severidad alta · dueño `analista-requerimientos`

**La no-pérdida se contrata por BLOQUE y la alcanzabilidad por SECCIÓN: en esa diferencia de grano cabe un bloque que sobrevive literalmente y deja de ser leído**

- **Ubicación:** `requirements/REQ-019.md` — CA-01 (grano: «todo párrafo, fila de tabla o viñeta»),
  CA-03 (grano: «cada archivo de destino … existe **al menos un** puntero»), CA-12 (grano: «una
  [pregunta] por **sección delegada**»), CA-13 (quién escribe ese conjunto).
- **Descripción.** CA-01 es una partición **por bloque** y es fuerte: cero bloques sin localizar, de
  contrato, comparación byte a byte con `grep -F`. Las dos garantías de que el bloque **se sigue
  leyendo** operan un grano por encima: **un** puntero por archivo de destino y **una** pregunta por
  sección delegada. Un archivo de destino que recoja doce bloques de tres secciones cumple CA-03 con
  un puntero y CA-12 con tres preguntas; los otros nueve bloques están **dentro del archivo** y
  **fuera de todo lo que se comprueba**. La propiedad que el REQ quiere —«no se puede perder una
  invariante que no se ha borrado»— se sostiene sobre los bytes; la que hace falta —«no se puede
  volver inalcanzable»— se comprueba sobre secciones.
- **Y el universo lo declara quien hace el reparto.** El conjunto de preguntas de trabajo se escribe
  «al hacer el reparto, en la tabla de decisión de CA-13», es decir: **el mismo agente que decide qué
  sale escribe la prueba de que lo que salió se encuentra**. Un examinando que redacta su examen. Es
  exactamente la cuarta forma que REQ-020 nombra —*el universo encogido en silencio*—, y aquí no hace
  falta mala fe: basta no imaginar la pregunta que un bloque contesta, que es la razón por la que ese
  bloque parecía prescindible.
- **Riesgo.** Un bloque de gobierno vivo, verbatim, en un archivo que ningún puntero anuncia y ninguna
  pregunta interroga. CA-01 lo declara conforme, CA-03 lo declara conforme y CA-12 nunca lo mira.
- **Remediación (write-back, `analista-requerimientos`).**
  1. **Igualar el grano en el subconjunto que importa:** todo bloque delegado que **enuncie o acote**
     una obligación, prohibición, umbral, condición de cierre o cobertura —la propiedad, no una
     lista— lleva **su propia** entrada en la tabla de CA-13 **con su pregunta de trabajo**, y CA-12
     se ejerce sobre **ese** conjunto, no sobre «una por sección». Los bloques puramente narrativos
     (una anécdota medida, un «por qué») siguen con el grano de sección.
  2. **Terceros ojos, que es lo que cierra el universo encogido:** las preguntas de trabajo las
     redacta **quien no hizo el reparto**. Precedente medido y ya citado en el propio REQ-021: la
     mutación de un tercero encontró **el doble** que la del autor (REQ-020 CA-08). Es gratis aquí,
     porque el revisor ya existe.
  3. Y en cuanto exista el reparto, **el conjunto de preguntas se cita, no se transcribe**: sitio
     único en la tabla de CA-13.

---

### SEC-033 — `contrato` · **abierto** · REQ-019 · severidad media · dueño `analista-requerimientos` (el criterio) y `desarrollador` (el residual de ADR-003)

**El espejo contratado NO cubre el modo de fallo que importa: cubre un subconjunto, en una sola dirección, y una sola vez**

- **Ubicación:** `requirements/REQ-019.md` CA-05; `docs/decisions/ADR-003-…md` §Decisión (tabla de
  invariantes) y §Consecuencias («CA-05 lo detectará el día que ocurra»).
- **La pregunta que contesta:** *¿el sustituto cubre una regla cambiada en una sede y no en la otra?*
  **No, en las tres dimensiones que tiene esa pregunta.**
  1. **Subconjunto.** CA-05 se enuncia sobre «cada bloque **delegado** por CA-01». Los bloques que
     **se quedan** en `AGENTS.md` —la tabla entera de §13, el flujo de §6, las cinco reglas de §9—
     salen del espejo. El `diff` de hoy los cubría. Un cambio de regla es **más probable** en lo que
     se queda, porque es lo que se lee.
  2. **Dirección.** `grep -F` es unidireccional: comprueba *delegado → plantilla*. `diff` es
     simétrico. Un cambio hecho **sólo en la plantilla** —que es lo que heredan **todos** los
     proyectos— queda invisible. No es hipotético: hoy hay **40 líneas que existen sólo en la
     plantilla**. Y esta dirección ya tiene doctrina firmada en este registro: R-009 dictaminó que
     «borrar cualquiera de las dos filas, **o desacoplarlas**, es regresión de herencia» (familia
     SEC-015). CA-05 sólo ata un extremo de la cuerda.
  3. **Momento.** CA-05 es una comprobación **de la revisión de este cambio**; REQ-019 deja fuera de
     alcance, con su motivo, cualquier guardián permanente. Así que «si alguien cambia una regla en
     una sede y no en la otra, esta comprobación lo dice» es **falso tal como está escrito**: no hay
     nadie que la vuelva a ejecutar. Es, literalmente, la lección que este proyecto midió esta misma
     semana y anotó en `docs/ESTADO.md`: *una comprobación contra línea base congelada es
     acreditación de fail-before, no puerta permanente* (CA-05 de REQ-017, y H-08 desde el otro
     lado). REQ-021 CA-08 sí la aplicó —distingue acreditación única de puerta auto-anclada—;
     REQ-019 no.
- **Riesgo.** Una divergencia aceptada cuyo control declarado no la vigila. El daño no es de esta
  ventana: es que 1.34.0 empiece a adelgazar la plantilla **creyendo** que el espejo está medido.
- **Remediación (write-back).**
  1. **Reformular CA-05 sobre el documento entero y en las dos direcciones:** todo bloque de
     `AGENTS.md` **y de sus destinos** aparece en la plantilla o lleva la marca `sin espejo en la
     plantilla`, **y** todo bloque de la plantilla aparece en `AGENTS.md` o en un destino, o lleva la
     marca simétrica. Es el mismo bucle `grep -F`, con la lista de entrada al revés; no cuesta un
     criterio nuevo, cuesta una frase.
  2. **Decir de qué tipo es la comprobación**, con las palabras que este proyecto ya usa:
     **acreditación única**, no puerta. Y declarar el **forzador observable** que la vuelve a
     disparar —*toda comisión que edite `AGENTS.md`, un destino o la plantilla durante la
     divergencia la re-ejerce*— con su dueño. Un residual cuyo disparador es «que alguien se
     acuerde» no vence: se olvida.
  3. Corregir en ADR-003 la frase «CA-05 lo detectará el día que ocurra», que hoy afirma una
     detección continua que el mecanismo no tiene.

---

### SEC-034 — `contrato` · **abierto** · REQ-019 · severidad media · dueño `analista-requerimientos`

**El mapa de archivos declara menos de lo que los criterios obligan a escribir: CA-06 y CA-09 escriben en REQ ajenos y `Archivos:` no los declara**

- **Ubicación:** `requirements/REQ-019.md` línea 4 (`Archivos:`) contra CA-06 y CA-09.
- **Descripción.** CA-06 obliga, cuando una cita queda falsa, a **versionar el REQ que la contrata en
  el mismo cambio** con entrada de Historial; CA-09 dice que la única salida legítima es exactamente
  ésa. Eso es escribir en `requirements/REQ-0XX.md`. El campo `Archivos:` declara **sólo**
  `requirements/REQ-019.md`. Medido en el árbol: **21 de 21** REQ citan `AGENTS.md`, así que el
  universo de CA-06 es *todos*.
- **Riesgo.** `tools/arnes-paralelo.sh` responderá **`disjunto`** entre REQ-019 y una comisión sobre
  un REQ que REQ-019 va a editar. Es la clase de fail-open que este registro ya tiene abierta dos
  veces —**SEC-014** (el paréntesis intermedio que borraba medio mapa en silencio) y **SEC-020** (el
  campo decorado)—, sólo que aquí el mapa no se lee mal: **está incompleto en origen**. Y el daño es
  el que `AGENTS.md` §6 nombra: conflicto de fusión y trabajo perdido. Añádase que un REQ
  `completado` editado por CA-06 **se reabre** (`AGENTS.md` §9), lo que puede alcanzar a REQ que
  nadie esperaba tocar.
- **Remediación.** Declarar en `Archivos:` el alcance real —`requirements/REQ-*.md`— **sin
  decoración de Markdown** (SEC-020 sigue abierto). Y aceptar la consecuencia honesta, que es la
  correcta: **REQ-019 colisiona con casi todo y va en serie**. Un `disjunto` barato sobre un mapa
  corto es peor que un `colisiona` caro sobre uno cierto. Si se quiere acotar, se acota el
  **criterio** (p. ej. CA-09 endurecido: ningún bloque citado se mueve en esta ventana, y entonces
  CA-06 no escribe en ningún REQ ajeno), no el mapa.

---

### SEC-035 — `contrato` · **abierto** · REQ-021 · severidad alta · dueño `analista-requerimientos`

**«Ninguna sonda sobrevive a su invocación» está enunciada sobre los hijos DIRECTOS, y se apoya en una red del corredor que no ve lo que el incidente medido hizo — y que al mudar las sondas deja de verlas**

- **Ubicación:** `requirements/REQ-021.md` CA-04 (puntos 1 y 2, y su párrafo de acreditación), leído
  contra `tests/escenarios/hooks/run.sh:596-602` y la invariante 5 de
  `tests/escenarios/hooks/README.md`.
- **Tres defectos, y el tercero es el que importa.**
  1. **Grado de parentesco.** CA-04.1 dice «no queda vivo **ningún proceso que ella lanzara**». El
     caso medido —un envoltorio de `grep` que se resolvía a sí mismo— no era un proceso que la sonda
     lanzara: era un **descendiente** creado por el sujeto instrumentado, recursivamente. Un
     criterio sobre hijos directos declara conforme exactamente el incidente que lo origina.
  2. **La red que se cita como precedente no sostiene el peso.** CA-04 se presenta como «la propiedad
     que el corredor ya vigila para las secciones (invariante 5), llevada a donde el corredor no
     llega». Lo que el corredor hace es `jobs -pr` **dentro del subshell de la sección**
     (`run.sh:598`): eso lista los **jobs de ese shell**, no los nietos ni los hijos de un programa
     invocado. La afirmación es más fuerte que el mecanismo.
  3. **Y la mudanza estrecha la cobertura, que es una regresión de control introducida por este
     mismo REQ.** Hoy las sondas viven **dentro** del archivo de sección: lo que dejan en segundo
     plano **es** un job de ese subshell y `jobs -pr` lo alcanza. CA-01.1 las convierte en
     **programas invocados**; a partir de ahí, lo que quede vivo es hijo del **proceso de la sonda**,
     y cuando la sonda muere queda reparentado y **fuera** de `jobs -pr`. La red pasa del **juez**
     (el corredor, con su cuadre por archivo y total) al **instrumento**, que es justo el artefacto
     que este REQ decide **no** proteger. Ninguna de las dos cosas está dicha en el REQ.
  4. **El plazo es circular donde hizo falta.** CA-04.2 exige un plazo «derivado de la propia
     medición» y prohíbe el absoluto. Correcto como doctrina de **techos**, pero un vigilante no
     puede derivar su plazo de una medición que **todavía no ha terminado**: en la **primera**
     repetición no hay mínimo, y la primera repetición es exactamente donde el envoltorio recursivo
     colgó. Sin plazo de arranque, el caso medido vuelve a caber.
- **Riesgo.** Un proceso desbocado sobrevive a la corrida, come un núcleo y **envenena la línea base
  de la comisión siguiente**, que concluirá «dentro del ruido» con lógica interna impecable. Está
  medido: 3 h 41 min al 99,6 %, 92,6 s donde había 39 s. Y las cifras que envenena son las que
  gobiernan la **puerta requerida de `main`**.
- **Remediación (write-back, `analista-requerimientos`).**
  1. **Enunciar la propiedad por parentesco completo:** *al terminar la sonda no sobrevive **ningún
     descendiente suyo**, lo lance quien lo lance y en el nivel que sea*. Y decir que la comprobación
     **no puede apoyarse en `jobs`**, que sólo ve los hijos directos del shell que la ejecuta. El
     mecanismo lo elige el `desarrollador` —grupo de procesos o sesión propia y muerte del grupo es
     lo habitual—; **yo no escribo código**.
  2. **Acreditar con un nieto, no con un hijo.** El par fail-before/pass-after de CA-04 se ejerce
     sobre un sujeto que deja vivo un **descendiente de segundo nivel**; con un hijo directo lo pasa
     una implementación ingenua.
  3. **Plazo de arranque declarado:** todo subproceso nace bajo plazo desde la **primera**
     repetición; el de arranque no puede derivarse de lo que aún no se ha medido, así que se declara
     su origen y es un techo **operativo** (se baja con la medición). Y su vencimiento es un
     **resultado publicado** (`estado=plazo-agotado`, con el número que sí obtuvo), nunca un SKIP
     mudo ni un PASS — la misma regla que CA-10 ya impone al resto de los estados.
  4. **Decir en el REQ que la red del corredor deja de cubrir a las sondas al mudarlas**, y qué la
     sustituye. Una mudanza que estrecha un control sin declararlo es deriva (`AGENTS.md` §9).

---

### SEC-036 — `contrato` · **abierto** · REQ-021 · severidad alta · dueño `analista-requerimientos`

**Acepto NO proteger `tests/util/`; NO acepto el sustituto tal como está contratado: la calibración viaja dentro del artefacto que certifica, la juzga la propia sonda, y nada ata su camino al de la medición**

- **Ubicación:** `requirements/REQ-021.md` §«La decisión que se toma aquí y no se deja abierta»
  (punto 3 y el residual, con dueño `auditor-seguridad`) contra CA-03 y CA-01 punto 3.
- **Lo que acepto, y por qué.** La decisión de **no** meter `tests/util/` en `codigo_app.globs` es
  correcta y sus dos motivos se sostienen: (a) protegerlas se las quitaría al `qa-tester`, que las
  rompe **por oficio** —y el precedente de la mutación de un tercero encontrando el doble está
  medido—; (b) tocar `.arnes/config.json` abre **gate humano** y una entrada en
  `PENDING_APPROVAL.md` **deniega el cierre de cualquier REQ**, incluido REQ-017. Bloquear trabajo
  ajeno por custodiar un instrumento es peor negocio que acreditar la medida. **Concurro con la
  dirección: acreditar > custodiar.**
- **Lo que no acepto: el supuesto que el sustituto necesita y no tiene.** «Una sonda alterada —por
  quien sea— no da verde» sólo es cierto si la calibración **no se puede alterar en el mismo
  movimiento que la sonda**. Cuatro grietas, todas de contrato:
  1. **Autocertificación.** CA-03 dice que cada sonda «**trae consigo**» su caso de calibración: la
     expectativa —el factor conocido y su **banda declarada**— vive en el mismo archivo que se
     cuestiona. Editar los dos es una sola edición. La banda es además **operativa** («se estrecha
     con la medición») y el REQ no le da sede única: ensancharla es una línea y no la mide nadie.
  2. **Contradicción interna con CA-01.3.** CA-03 hace que «la calibración **FALLA** … nombrando el
     instrumento y los dos factores», mientras CA-01.3 prohíbe que una sonda dicte veredicto —«el
     brazo, no el juez»— y CA-10 pone el veredicto en el ayudante de `run.sh`. Tal como están
     escritos, los dos criterios no se pueden cumplir a la vez.
  3. **No hay identidad de camino.** Nada obliga a que la calibración recorra **el mismo código** que
     la medición con sólo el sujeto sustituido. Una sonda con un camino especial para el par
     sintético calibra en verde y miente sobre el sujeto real — que es, con precisión, la propiedad
     que el REQ dice cerrar («dejó de responder al sujeto») y la forma «el caso que no se ejecuta»
     de REQ-020, un nivel más arriba.
  4. **El forzador del residual es inobservable.** Está escrito como «una sonda cuya calibración
     resulte insuficiente para detectar una alteración deliberada». Eso sólo se sabe cuando ya pasó y
     alguien lo notó; un residual cuyo disparador es el daño que debía evitar **no vence nunca**.
- **Y una consecuencia de separación de funciones que el REQ no nombra.** Fuera de
  `codigo_app.globs`, `guard-codigo` permite escribir `tests/util/` a **cualquier** agente, incluida
  la **sesión coordinadora**. Es la misma sesión que reúne la evidencia de «todo en verde» y que
  **fusiona, etiqueta y publica por delegación permanente** del propietario (2026-09-05). Quien
  acredita, quien decide y quien puede editar el instrumento son el mismo actor, sin ninguna puerta
  en medio. No es una acusación: es la razón por la que el sustituto tiene que ser **verificable por
  un tercero**, y no la palabra del instrumento.
- **Remediación (write-back, `analista-requerimientos`), y con ella acepto el residual.**
  1. **La expectativa de la calibración vive en el JUEZ, no en la sonda:** el factor esperado y su
     banda se declaran en el ayudante de veredicto de `run.sh` (sitio único, ya contratado por CA-01
     punto 4 y CA-10); la sonda publica **los dos factores obtenidos** como campos de su registro y
     no juzga. Cierra a la vez la autocertificación y la contradicción con CA-01.3, y **no cuesta un
     criterio nuevo**: cuesta mover una frase de CA-03 a CA-10.
  2. **Identidad de camino, contratada:** la calibración se ejerce **por el mismo camino de código
     que la medición**, sustituyendo únicamente el sujeto; una sonda con un camino propio para
     calibrar incumple.
  3. **Forzador observable para el residual, con vencimiento:** en la pasada de conformidad de
     **1.34.0** se acredita el sustituto **por mutación de un tercero** —se altera una sonda y se
     exige que la calibración **no dé verde**—, usando el aparato que REQ-020 construye y que el
     orden recomendado (`REQ-017 → REQ-021 → REQ-020`) ya deja disponible. Si la mutación pasa
     inadvertida, el sustituto queda desmentido y la decisión de no proteger `tests/util/` vuelve a
     la mesa **con el número delante**.
- **Residual: lo asumo como dueño (`auditor-seguridad`)** con esas tres condiciones escritas, y no
  antes de que estén en el REQ. Un residual que sólo vive en este registro es deriva (`AGENTS.md`
  §9).

---

### SEC-037 — `instrumento` · **abierto** · REQ-021 · severidad media · dueño `desarrollador` · ventana 1.33.0 (con la implementación)

**Propiedades de seguridad de la medición que hoy están en el código y en ningún criterio: la mudanza las puede perder sin cambiar un solo veredicto**

- **Ubicación:** la sonda que hoy vive en
  `tests/escenarios/hooks/secciones/37-coste-del-escaner-2-la-seccion-caliente.sh:353-386`, contra
  `requirements/REQ-021.md` CA-07 (la mudanza) y CA-04.
- **Por qué es un hallazgo y no una nota.** CA-07 garantiza la mudanza por **veredicto** y por
  **recuento**: ningún caso cambia de resultado, el inventario cuadra. Una reescritura que conserve
  los veredictos puede **soltar por el camino** propiedades que hoy existen y que ningún caso
  interroga. Es la clase de regresión silenciosa que esta bitácora tiene por mandato buscar: un
  control presente hoy que desaparece en una refactorización verde.
- **Las cinco propiedades, y todas están hoy en el código.** *(La lista es de lo medido en este
  archivo; el sitio único de la conducta será `tests/util/`.)*
  1. **El reloj se mide SIN la instrumentación.** El código lo dice con todas las letras («un
     envoltorio por proceso mide el envoltorio») y separa la pasada instrumentada de las series de
     reloj. Si la sonda unificada toma las dos cosas en la misma invocación, **el reloj mide los
     envoltorios** y CA-08 (ii) queda contratando una razón contaminada. Debe ser criterio: *una
     serie de reloj no se toma bajo instrumentación, y el registro declara si la muestra lo estuvo;
     una muestra mixta no es publicable.*
  2. **El directorio de envoltorios es un temporal por proceso** (`.bin47-$$`). El corredor **corre
     las secciones en paralelo** (`run.sh:607-612`): un directorio de envoltorios con **nombre fijo**
     es la clase medida de REQ-015 —el temporal compartido— aplicada esta vez a **ejecutables**, con
     una sonda ejecutando el envoltorio de otra a mitad de medición. CA-04.4 habla de «temporales»;
     debe nombrar **el directorio de envoltorios** explícitamente, y exigirlo privado y recién
     creado.
  3. **La ruta real va congelada en el envoltorio generado** (`exec <ruta-absoluta> "$@"`), resuelta
     con `type -P` **antes** de tocar el `PATH`. La comprobación de «ninguna ruta cae dentro del
     propio envoltorio» debe hacerse **sobre la ruta que queda escrita en el envoltorio**, no sólo
     sobre la resolución previa: un envoltorio que re-resuelve por `PATH` en tiempo de llamada
     reproduce el incidente de 1.32.1 tal cual.
  4. **El `PATH` construido se acota a la invocación instrumentada** y no se exporta más allá; y no
     debe contener **componentes vacíos ni relativos** (`::`, `:` final, `.`), que ponen el
     directorio de trabajo delante de los binarios reales.
  5. **La retirada del directorio también en los caminos de error.** Hoy las salidas
     `ENVOLTORIO-RECURSIVO` (rc 9) y el fallo de `chmod` (rc 1) **dejan el directorio detrás**. CA-04.4
     («se retiran en la misma salida») lo corrige, pero su acreditación debe ejercer un **camino de
     error**, no sólo el feliz.
- **No bloquea** (clase `instrumento`, `AGENTS.md` §6): son propiedades del instrumento, con dueño y
  ventana. Se anotan aquí para que la mudanza las herede a propósito y no por suerte.

---

### Lo que esta revisión NO puede decir — la mitad honesta de una preventiva

- **Nada sobre el código de REQ-019 ni de REQ-021: no existe.** `docs/arnes/` y `tests/util/` no
  están en el árbol. Esta firma no acredita ninguna implementación.
- **Nada sobre el reparto de bloques de REQ-019**, que es donde vive el riesgo real de perder una
  invariante. La tabla de decisión de CA-13 no existe todavía; cuando exista, la auditoría del código
  la revisará **bloque a bloque** contra SEC-031 y SEC-032. La predicción registrada en el REQ es una
  intención, no un reparto.
- **Nada sobre si los punteros resuelven ni sobre si el ahorro de CA-07 se cumple:** son mediciones
  sobre un árbol que no existe, y esta comisión **no ejecutó nada** (QA está midiendo REQ-017).
- **Nada sobre la implementación de las sondas:** si la calibración recorre el mismo camino que la
  medición, si el grupo de procesos se mata entero, si el envoltorio congela la ruta — todo eso se
  audita **leyendo el código**, en el turno que corresponde, después del `qa-tester`.
- **Nada sobre REQ-017 ni sobre la invariante 5 tal como la está construyendo.** Lo que SEC-035 dice
  del alcance de `jobs -pr` **también afecta** a cómo se lee esa invariante, pero REQ-017 está en
  medio de su validación y **no es mi turno**: queda como observación para su auditoría, no como
  hallazgo contra él, y no he tocado su REQ ni el log de QA.
- **Nada sobre coste real.** Los ~9 000 tokens y los ~150 k por ventana son medidas del analista que
  no he reproducido.

---

### ¿Veto? — **NO. Dos veredictos `preventiva`, y ninguno autoriza a cerrar**

No hay veto: ninguno de los dos REQ está construido, así que no hay nada que vetar. Los siete
hallazgos son de **contrato** salvo SEC-037 (`instrumento`), y los seis de contrato **bloquean el
cierre** hasta el write-back del `analista-requerimientos`. Eso es lo correcto y es barato: los dos
REQ están `pendiente`, así que cada corrección cuesta una edición de criterio y no una vuelta del
bucle. **Ninguno de los seis pide construir nada nuevo**: cinco piden enunciar por propiedad lo que ya
se quería decir, y uno (SEC-034) pide declarar el mapa entero.

**Rigor:** los dos REQ ya están en `critico` con `Sensible a seguridad: sí`. No hay nada que subir, y
nada se baja.

### Estado de seguridad aprobado por REQ — R-010 (línea base de no-regresión, ventana 1.33.0)

| REQ | Estado de seguridad | Fecha | Árbol | Controles acreditados / qué vigilar en la auditoría del código |
|---|---|---|---|---|
| **REQ-019** | **`preventiva`** (no es `aprobado`; no cierra) | 2026-09-07 | `cand/1.33.0` @ `1792152`, **sin código** | Se acredita **el diseño**, con cuatro huecos abiertos. Propiedades que la auditoría del código verificará bloque a bloque: (a) toda **acotación** de una promesa que se queda acompaña a su promesa, por propiedad y con sitio único (SEC-031); (b) todo bloque delegado que enuncie o acote gobierno tiene **su propia** entrada y pregunta en la tabla de CA-13, redactadas por quien no hizo el reparto (SEC-032); (c) el espejo se comprueba **en las dos direcciones y sobre el documento entero**, declarado como acreditación única con forzador observable (SEC-033); (d) `Archivos:` declara `requirements/REQ-*.md` (SEC-034); (e) CA-11 se mantiene: **ningún** destino se importa desde `CLAUDE.md` — importarlos devolvería el coste entero de forma invisible; (f) la **tabla de §13 byte a byte** y la primera frase de cada bloque `🔒` siguen en `AGENTS.md` (CA-02) — debilitarlo es regresión. |
| **REQ-021** | **`preventiva`** (no es `aprobado`; no cierra) | 2026-09-07 | `cand/1.33.0` @ `1792152`, **sin código** | Se acredita **el diseño**, con tres huecos abiertos. Propiedades que la auditoría del código verificará: (a) **ningún descendiente** sobrevive a la sonda, sin apoyarse en `jobs`, acreditado con un **nieto** y con plazo desde la primera repetición (SEC-035); (b) la expectativa de calibración vive en el **juez** y la calibración recorre el **mismo camino** que la medición (SEC-036); (c) las cinco propiedades de medición del §SEC-037 sobreviven a la mudanza; (d) **la decisión de no proteger `tests/util/` bajo `codigo_app.globs` queda acreditada como decisión mía**, con el sustituto condicionado a la mutación de un tercero en 1.34.0 — revertirla o dejarla sin ese forzador es regresión; (e) CA-01.3 y CA-10 se mantienen: una sonda **no dicta veredicto** y un registro vacío es **FAIL**, nunca SKIP. |

**Alcance de las dos firmas.** Cubren el texto de los dos REQ y de ADR-003 tal como están hoy. **No
cubren el código posterior.** Cuando exista, la auditoría se repite **después del `qa-tester`**, como
manda `AGENTS.md` §6.

---

## Revisión R-011 — auditoría **PREVENTIVA** de REQ-020, ventana 1.33.0 (`cand/1.33.0`) — 2026-09-07

**Qué es y qué no es.** Excepción nombrada de `AGENTS.md` §6: revisión hecha **antes de que exista el
código**, sobre el diseño y el REQ. Se declara al emitirla —`Seguridad: preventiva`— y **no acredita
nada construido**. REQ-020 está `pendiente`, `QA: pendiente`, y no hay una línea escrita: ni
`SKIP_ADMITIDOS_SECCION`, ni la línea `Acredita:`, ni el inventario de casos sin medir existen en el
árbol. Cuando el código exista, la auditoría se repite **después del `qa-tester`**.

**Por qué esta preventiva no es de relleno.** REQ-020 no es un diseño en el vacío: la mitad de sus
criterios hace **afirmaciones verificables sobre el árbol de hoy** («el cuadre por sección se sigue
exigiendo», «la expresión vive única en dos sitios», «una sola pasada de lectura»). Esas se auditan
leyendo, ahora, sin código nuevo. Cinco de los nueve hallazgos salen de ahí.

**Alcance leído:** `requirements/REQ-020.md`, `requirements/README.md` §«Cómo se escribe un criterio
que no se desmiente», `docs/PENDIENTES.md:977-1318` (los cuatro casos, la regla del literal, el
trinquete congelado, quién muta), `docs/ESTADO.md`, `AGENTS.md` §§5-7 y 13, `.arnes/config.json`,
`.github/workflows/banco.yml`, `tests/escenarios/hooks/run.sh` (entero),
`tests/escenarios/hooks/inventario.sh`, `tests/escenarios/hooks/autoprueba-corredor.sh` (selección y
cuadre), las 44 secciones (por `grep`, para contar ramas SKIP y declaraciones), y mi propia R-010.

**Nada ejecutado del banco.** Hay tres comisiones más corriendo y una de ellas mide; una corrida ajena
les falsea las cifras (regla de REQ-021 CA-06, incidente de 3 h 41 min). Las dos cifras que publico son
**recuentos estáticos sobre el texto**, sin reloj: no perturban ni se perturban, y se reproducen con el
comando que va junto a cada una.

**Método.** Lectura de contrato: buscar la propiedad que cada criterio **no** asegura, y el enunciado
que resulta **más fuerte que la verdad**. Y una pasada específica, porque es lo que la comisión pedía:
*¿por qué vía se consigue una acreditación que no corresponde?* — se encontraron cuatro, y sólo dos las
cubre el REQ.

---

### SEC-038 — `contrato` · **abierto** · REQ-020 · severidad alta · dueño `analista-requerimientos`

**El literal está protegido en su ASIGNACIÓN, no en su USO: el control es una conjunción de tres términos y CA-04 contrata uno**

- **Ubicación:** `requirements/REQ-020.md` CA-04 (i) y su párrafo «Cómo es testable», contra
  `tests/escenarios/hooks/run.sh:712` (la asignación) y `run.sh:716-723` (el uso).
- **La pregunta que contesta:** *¿alguien puede «arreglar» la regla del literal derivándola sin que
  ningún criterio proteste?* **Sí, por tres vías, y ninguna toca la asignación.**
- **Descripción.** El control que sostiene el cuadre total no es el literal: es la **conjunción**
  (a) el término es un literal tecleado, (b) **ése** es el operando de la comparación, y (c) **la rama
  de la comparación se ejecuta**. CA-04 contrata (a) y su caso lo comprueba «sobre el **texto** del
  corredor que la asignación del total es un literal decimal». (b) y (c) quedan fuera:
  1. **Cambiar el otro operando.** `CASOS_ESPERADOS=852` se queda intacto —CA-04 en verde— y la
     comparación pasa a hacerse contra la **suma de los `CASOS_ESPERADOS_SECCION`**. Es una igualdad
     entre dos magnitudes que **encogen juntas**: borrar un archivo de sección deja de verse, que es
     exactamente lo que CA-04 (ii) dice que el literal es «lo único que delata».
  2. **Añadir una rama derivada** y dejar el literal como código muerto. Mismo efecto, mismo verde.
  3. **Ensanchar la condición de suspensión.** Hoy es `if [ -n "$FILTRO" ] || [ "$PARCIAL" = si ]`
     (`run.sh:716`). Añadir un tercer término —una variable de entorno, una condición de plataforma—
     apaga el cuadre total **sin tocar el literal ni la comparación**. Ningún criterio de REQ-020 mira
     esa condición: CA-03 gobierna los tres estados, pero el código no los materializa como estados,
     sino como un `if` dentro del cuadre.
- **Riesgo.** El control declarado «lo único que delata» un archivo de sección borrado se puede apagar
  con un cambio que pasa todos los criterios del REQ que existe para protegerlo. Y quien lo haga no
  tiene por qué saberlo: la vía 1 es la «mejora» natural de alguien que lee «hay dos números que
  mantener a mano».
- **Remediación (write-back, `analista-requerimientos`).**
  1. **Enunciar el control como la conjunción**, no como el literal: *el cuadre total exige que el
     término esperado sea un literal tecleado, que **sea ése** el operando de la comparación, y que la
     comparación **se ejecute** en toda corrida que acredita.* La lista de condiciones que la suspenden
     es **exhaustiva y vive en un solo sitio**, y son exactamente los estados de CA-03 — ninguna más.
  2. **Testable sin ejecutar el banco:** el caso comprueba sobre el texto (a) la asignación literal,
     (b) que la comparación usa esa variable, y (c) que la condición de suspensión no tiene más
     términos que los declarados. Es el mismo `grep` estructural que ya usa `autoprueba-corredor.sh`.
  3. **Un testigo fuera de `tests/`:** el corredor **publica el total esperado en su salida**
     (p. ej. `Casos esperados: 852 (literal)`), con el mismo argumento de contrato que la línea
     `Acredita:`. La salida del banco se compara vuelta a vuelta contra la versión publicada anterior
     (REQ-014 CA-12), así que un cambio del literal **se ve fuera del archivo que lo contiene**. No
     entra en el inventario: `inventario.sh` sólo recoge `^  (PASS|FAIL|SKIP)  `.

---

### SEC-039 — `contrato` · **abierto** · REQ-020 · severidad alta · dueño `analista-requerimientos`

**El techo de casos sin medir se calibra con el número que su propio ABORT imprime, y en la sección donde ocurrió H-08 ese número es 11 de 11 casos**

- **Ubicación:** `requirements/REQ-020.md` CA-02 (el techo, su mensaje de aborto y su párrafo
  «operativo»), contra `tests/escenarios/hooks/secciones/37-coste-del-escaner-2-la-seccion-caliente.sh`
  y `…-1-escala.sh`.
- **Medido sobre el texto** (`grep -c 'SKIP'` y `grep -n 'CASOS_ESPERADOS_SECCION'`, sin ejecutar
  nada):

  | Sección | Casos declarados | Ramas que pueden emitir SKIP |
  |---|---|---|
  | `37-…-2-la-seccion-caliente.sh` | **11** | **26** |
  | `37-…-1-escala.sh` | **13** | **29** |

  Los **once** SKIP de H-08 salieron de ahí. Es decir: **la sección donde ocurrió el incidente puede
  quedarse entera sin medir**, y el techo que la cubriría es `11`.
- **Descripción, y son dos defectos que se refuerzan.**
  1. **CA-02 no dice CÓMO se elige el techo.** El flujo natural es: el banco aborta, el mensaje
     imprime «el número obtenido» —CA-02 lo exige explícitamente—, y ese número se pega en la sección.
     Si el aborto ocurrió en el árbol roto, el techo queda calibrado **sobre la corrida que no midió**,
     y `SKIP_ADMITIDOS_SECCION=11` declara **conforme** exactamente el incidente que originó el REQ. El
     mensaje de remediación entrega el valor que apaga el control.
  2. **Un solo escalar cubre dos clases de caso sin medir que no se parecen en nada:** el
     **estructural** («esta plataforma no crea enlaces simbólicos», «no hay `/dev/full`») —estable,
     contable por adelantado, techo pequeño y fijo— y el **contingente** («la sonda no convergió»,
     «serie por debajo del suelo», «no hay línea base») —dependiente de la carga y del clon, sin cota
     natural—. Un escalar único hay que fijarlo al peor caso del **contingente**, y H-08 es de esa
     clase. Además contradice una decisión que este proyecto **ya tomó** para REQ-017 y que está en
     `docs/ESTADO.md`: *el vencimiento del plazo es un resultado positivo, **nunca** un SKIP*.
  3. **La dirección que abre no tiene firma.** CA-02 declara el valor «operativo: se **baja** con la
     medición; **menos** es conforme», y dice que bajarlo es entrada de Historial. **No dice nada de
     subirlo**, que es la única dirección peligrosa; y el número no vive en el REQ sino en un archivo
     de `tests/`, donde ninguna entrada de Historial lo alcanza y ningún guardián lo mira (SEC-045).
     Tampoco hay **cota global**: 44 techos pequeños suman un techo grande que nadie ve.
- **Riesgo.** El control contra «el caso lleno que no se ejecuta» admite, tal como está contratado,
  reproducir su propia instancia medida. Y se degrada por la vía barata: subir un número en un archivo
  sin custodia, con el valor sugerido por el propio mensaje de error.
- **Remediación (write-back, `analista-requerimientos`).**
  1. **El techo se calibra sólo sobre una corrida que ACREDITA** (`Acredita: sí`, CA-03), y la sección
     **registra en su propia declaración de qué corrida salió** (fecha y contexto), igual que CA-09
     (iii) exige para su razón. Un techo calibrado sobre una corrida que no acreditó no vale.
  2. **El mensaje del aborto NO ofrece el número como remedio.** Nombra los casos y dice qué hacer:
     *o el caso vuelve a medir, o la sección declara el techo **con la corrida que lo justifica***.
  3. **Separar las dos clases por propiedad** —«la plataforma no puede» frente a «el instrumento no
     pudo esta vez»—: la primera admite techo declarado; la segunda es **resultado publicado con su
     número** (`plazo-agotado`, `sin-convergencia`), nunca un SKIP mudo, que es la regla que REQ-017 ya
     adoptó. Enunciado por propiedad y con el sitio único donde vive la clasificación; ejemplos **no
     exhaustivos**.
  4. **Subir un techo no es cambio menor:** lleva la corrida que lo justifica y **la firma de un rol
     distinto del que lo sube**. Y se declara una **cota global** de casos sin medir para la vuelta que
     acredita, con la misma naturaleza operativa (se baja con la medición).

---

### SEC-040 — `contrato` · **abierto** · REQ-020 · severidad alta · dueño `analista-requerimientos`

**La acreditación cubre que el universo no se encoja, pero NO que el sujeto sea éste — y el caso 1 del propio REQ es una sustitución de sujeto**

- **Ubicación:** `requirements/REQ-020.md` CA-03 (los tres estados y su párrafo «Qué cuenta como
  entrada que estrecha»), contra `run.sh:21` (`ARNES_HOOKS_DIR`), `run.sh:56` (`jq`), `run.sh:452`
  (`ARNES_SOLO_DESCUBRIR`), `run.sh:485-487` (el cálculo de `PARCIAL`) y
  `autoprueba-corredor.sh:19` (`ARNES_CORREDOR`).
- **Las cuatro vías por las que hoy se obtiene una acreditación que no corresponde. Dos las cubre
  CA-03; dos no.**

  | Vía | Qué pasa | ¿La cubre CA-03? |
  |---|---|---|
  | Selector de secciones / directorio alterno | `PARCIAL=si` → hoy suspende, con CA-03 **ABORT o declaración** | **Sí** |
  | Filtro de caso | `FILTRO` → hoy suspende, con CA-03 **ABORT o declaración** | **Sí** (pero ver SEC-041) |
  | **`ARNES_HOOKS_DIR` a otro árbol de hooks** | Los **852** casos corren, `PARCIAL=no`, `FILTRO` vacío → **`Acredita: sí`**, y lo que se certificó fueron **otros hooks** | **No** |
  | **`jq` ausente** | `run.sh:56` → `echo "SKIP: jq no instalado"; exit 0` — **cero casos, rc 0**, sin `Resultado:` y sin inventario | **No** |

- **Por qué la tercera es la que importa.** La instancia medida que el propio REQ pone al **caso 1**
  es literalmente ésta: *«Los cinco casos de banco de 1.32.1 (H-02): pasaban **contra los hooks de
  1.32.0**, la versión con el fail-open»*. El REQ nombra el incidente y luego contrata una
  acreditación que **no lo modela**: CA-03 razona sobre *«el universo de una tanda puede encogerse»*,
  y aquí el universo está entero — lo que cambió es **sobre qué se ejerció**. `ARNES_HOOKS_DIR` es
  legítimo y necesario (es como se hace el fail-before), así que no se prohíbe: se **declara en la
  acreditación**.
- **Y la cuarta falsifica un «siempre» del REQ desde dentro del mismo archivo.** CA-01 contrata que el
  inventario se imprima **siempre, también cuando el número es cero**, con el argumento —correcto— de
  que un inventario que desaparece es indistinguible de uno no implementado. `run.sh:56` sale **0 sin
  imprimir nada**. Es la forma «el caso lleno que no se ejecuta» aplicada al banco entero, y hoy no la
  ve nadie: en CI el paso de `jq` la tapa, pero un fallo de `apt-get` la destapa.
- **Y el sitio único citado no contiene la lista.** CA-03 dice que la lista exhaustiva de entradas que
  estrechan vive «**única**, en el bloque de selección de `run.sh`». Ese bloque empieza en
  `run.sh:458`. `ARNES_SOLO_DESCUBRIR` (línea 452, **sale 0 tras ejecutar cero casos**) y
  `ARNES_HOOKS_DIR` (línea 21) están **fuera**. Un puntero a un sitio único que no es exhaustivo es la
  forma (a) de `requirements/README.md` con la marca puesta en el sitio equivocado.
- **Riesgo.** Una corrida que dice `Acredita: sí` sobre un mecanismo que no es el de este árbol, o una
  corrida de cero casos con rc 0. El daño llega cuando la línea `Acredita:` tenga consumidor
  automático (candidato a 1.34.0, el propio REQ lo dice): la puerta leerá `sí` y no habrá segunda
  lectura.
- **Remediación (write-back, `analista-requerimientos`).**
  1. **Ampliar la propiedad de CA-03 a las dos dimensiones:** *toda entrada de invocación que pueda
     **reducir el conjunto de casos ejecutados** respecto de la vuelta completa **o cambiar el sujeto
     sobre el que se ejercen**.* Ejemplos **no exhaustivos**: selector de secciones, filtro de caso,
     directorio de secciones alterno, **directorio de hooks alterno**, **corredor alterno**.
  2. **La línea `Acredita:` nombra el sujeto resuelto** (directorio de hooks, directorio de secciones,
     corredor), no sólo el recuento. Es la única forma de que una salida pegada como evidencia diga
     contra qué se ejerció; y es el mismo argumento con el que el REQ ya hace que la línea viaje con
     la salida.
  3. **Mover la lista exhaustiva a un sitio que la contenga**, o mover al bloque de selección las
     entradas que hoy quedan fuera. El puntero y el código tienen que coincidir.
  4. **Ninguna salida del corredor es rc 0 con cero casos.** Una dependencia ausente es `ABORT`, ≠ 0,
     con su motivo — la misma dirección fail-closed que CA-02 aplica a un techo ilegible.

---

### SEC-041 — `contrato` · **abierto** · REQ-020 · severidad media · dueño `analista-requerimientos`

**«El cuadre de cada sección se sigue exigiendo» es falso con filtro, y como igualdad no es implementable: la fila promete una protección que la vuelta filtrada no tiene**

- **Ubicación:** `requirements/REQ-020.md` CA-03, fila «Estrechada y declarada», y §«Notas / alcance»
  (*«El de cada sección se sigue exigiendo, así que la protección no desaparece»*), contra
  `run.sh:696-706`.
- **Descripción.** El código dice `if [ -z "$FILTRO" ]` antes del cuadre por archivo, con su motivo
  escrito y correcto: con filtro la sección corre **menos** casos de los que declara, así que la
  igualdad no puede exigirse. Consecuencia: una vuelta **con filtro** no tiene **ningún** cuadre — ni
  total (`run.sh:716`) ni por sección. CA-03 mete en **una sola fila** los dos mecanismos de
  estrechamiento, y la frase es cierta para el selector de secciones y **falsa para el filtro**. La
  frase de `Notas / alcance` la generaliza a las dos.
- **Por qué es seguridad y no redacción.** Es la familia SEC-031: el lector se queda con un modelo del
  sistema **más protegido de lo que está**, y la mitad que sobra es justo la que se usa a diario. Y no
  se arregla implementando: la igualdad por sección **no puede** exigirse bajo filtro; un criterio que
  la promete sólo se puede cumplir relajándolo después, que es deriva (`AGENTS.md` §9), o
  reinterpretándolo en la implementación, que es peor.
- **Remediación (write-back).** Partir la fila en los dos mecanismos y decir de cada uno **qué queda
  vivo**: con selector de secciones, el cuadre por archivo se exige entero; con filtro, la igualdad
  por archivo **no aplica** y lo que se exige es lo que sí sea exigible —como mínimo, que ninguna
  sección seleccionada ejecute **cero** casos, y que el recuento por sección se imprima—. Y corregir la
  frase de `Notas / alcance`, que hoy afirma sin condición.

---

### SEC-042 — `contrato` · **abierto** · REQ-020 · severidad media · dueño `analista-requerimientos`

**«La expresión vive, única, en el awk y en el sed» son dos sitios con dos expresiones DISTINTAS, ya divergentes hoy — y el motivo que CA-01 manda imprimir no lo declara hoy ningún caso**

- **Ubicación:** `requirements/REQ-020.md` CA-01 (tercer párrafo) y CA-10, contra `run.sh:635-637`
  (`/^  PASS /`, `/^  FAIL /`, `/^  SKIP /` — **un** espacio) e `inventario.sh:24`
  (`^  (PASS|FAIL|SKIP)  (.*)$` — **dos** espacios).
- **Demostrado, sobre un archivo de dos líneas y sin tocar el banco:**

  ```
  printf '  SKIP un-espacio caso\n  SKIP  dos-espacios caso\n' > p.txt
  awk '/^  SKIP / {c++} END{print c}' p.txt        -> 2
  bash tests/escenarios/hooks/inventario.sh p.txt  -> 1  (sólo la de dos espacios)
  ```

- **Descripción, y las tres consecuencias.**
  1. **«Única» no puede describir dos sitios.** El enunciado se contradice a sí mismo, y los dos
     sitios **no coinciden**: el conjunto del `awk` contiene estrictamente al del `sed`.
  2. **La divergencia tiene una dirección peligrosa y es la que CA-10 no ve.** Una línea con **un**
     espacio **cuenta** para el recuento (rompe el cuadre por archivo y el total) y **no entra** en el
     inventario — así que la comparación byte a byte de CA-10 sigue **verde** mientras el cuadre se
     rompe. Hoy es latente: **ninguna** de las 44 secciones emite la forma de un espacio (verificado
     por `grep`). Latente no es inexistente: CA-01 obliga a imprimir líneas nuevas cerca de esos
     prefijos, que es justo cuando esto deja de ser latente.
  3. **El «motivo que ese caso declaró» no existe como dato.** `run.sh` **no tiene ayudante `skip`**:
     las 9 secciones que emiten SKIP lo hacen con `echo` a mano y el motivo va **dentro de la misma
     cadena que forma la identidad del caso en el inventario**, en al menos tres formas distintas
     (`nombre  (motivo)`, `nombre: motivo`, `nombre  motivo largo`). Extraer el motivo por análisis del
     texto es la forma (a); normalizar las cadenas **cambia el inventario** y choca de frente con
     CA-10, que lo exige idéntico **byte a byte**.
- **Riesgo.** Un cuadre que se rompe mientras la comprobación que debería verlo sigue en verde; y un
  criterio (CA-01) cuya implementación natural incumple otro (CA-10) del mismo REQ.
- **Remediación (write-back).**
  1. **Decir la verdad sobre los dos sitios:** hay **dos** lectores con **dos** expresiones, el del
     recuento es más ancho que el del inventario, y la propiedad que se contrata es *ninguna línea que
     el REQ añada casa **ninguna de las dos***. O se unifican —y entonces `inventario.sh` **entra en
     `Archivos:`**, que hoy lo declara sólo-lectura; es la clase de SEC-034, mapa incompleto en origen
     y `disjunto` falso—, o se citan las dos como el par que son.
  2. **Contratar el CANAL por el que un caso declara su motivo**, separado de la línea de veredicto:
     una línea propia con prefijo que **ninguno de los dos lectores** reconoce, emitida por un ayudante
     **único** del corredor. Así el motivo es dato y no prosa, el inventario no se mueve y CA-10 se
     cumple sin negociar.

---

### SEC-043 — `contrato` · **abierto** · REQ-020 · severidad media · dueño `analista-requerimientos`

**CA-09 (ii) fija la magnitud equivocada —«pasadas», no «líneas»— y la pasada única cuesta 22,18× lo que hoy se lee; el fixture sintético es ciego a eso por construcción**

- **Ubicación:** `requirements/REQ-020.md` CA-09 (ii) y (iii), contra `lee_casos_declarados`
  (`run.sh:643-658`) y CA-02 («la ausencia del campo ES el valor»).
- **Medido sobre el texto, sin reloj** (recuento estático; se reproduce recorriendo
  `secciones/*.sh` y comparando `wc -l` con la línea del primer `^CASOS_ESPERADOS_SECCION=`):

  | | Líneas |
  |---|---|
  | Total de las 44 secciones | **7 518** |
  | Leídas hoy (el `while read` **retorna en la primera coincidencia**) | **339** |
  | **Razón si hay que llegar a EOF** | **22,18×** |

- **Descripción.** CA-09 (ii) contrata «**no más de 0 pasadas de lectura añadidas** … el techo y el
  número de casos se leen en **una sola** pasada». Se cumple —una pasada— mientras el coste real se
  multiplica por 22 en la magnitud que de verdad se paga: **líneas leídas en un bucle `read` de bash**,
  el lector más caro que hay. Y lo fuerza el propio diseño: como CA-02 hace que **la ausencia sea el
  valor**, una sección que (correctamente) **no** declara techo sólo puede saberlo **llegando al final
  del archivo**. El defecto fail-closed que CA-02 acierta en elegir es exactamente lo que impide el
  corte temprano.
- **Y la tercera vía de CA-09 tampoco lo ve.** La mitad (iii) mide el reloj sobre «un directorio
  sintético de secciones **triviales**»: secciones triviales son cortas, así que leerlas hasta EOF no
  cuesta nada. El fixture **no contiene la propiedad que se degrada**. Es la forma (d) una capa más
  arriba —no en la magnitud, en el material sobre el que se mide—, y es la misma lección que el propio
  CA-09 invoca para justificar sus tres mitades.
- **Lo que NO afirmo.** No he medido el impacto en reloj, ni podía: hay una comisión midiendo y una
  corrida ajena le envenena la línea base. **7 200 líneas de más en un `while read` de bash son
  probablemente milisegundos en Linux y no lo son en Windows/MSYS**, donde este proyecto tiene el coste
  sin medir (`docs/ESTADO.md`). La razón 22,18× es cierta sobre la magnitud; su traducción a segundos
  **no está medida** y le corresponde a quien implemente, en la misma corrida y con el mínimo de k.
- **Remediación (write-back).**
  1. **Cambiar la magnitud de (ii)** a **líneas (o bytes) leídos** sobre `secciones/`, no «pasadas»,
     con su techo y su dirección admitida. Una pasada más larga es coste añadido aunque el recuento de
     pasadas no se mueva.
  2. **Medir la mitad de lectura sobre `secciones/` real**, no sobre el directorio sintético; el
     sintético sigue valiendo para el reloj del corredor, que es otra cosa.
  3. **Si se quiere conservar el corte temprano**, contratarlo por propiedad: *las dos declaraciones
     viven en un bloque de cabecera acotado de la sección y la lectura termina al salir de él*, con el
     sitio único donde ese bloque se define. Es un cambio de forma en 44 archivos y hay que decirlo por
     delante, no descubrirlo al medir.

---

### SEC-044 — `contrato` · **abierto** · REQ-020 · severidad media · dueño `analista-requerimientos`

**La regla del literal nombra un MECANISMO donde debe enunciar una PROPIEDAD, y por eso se puede satisfacer sin proteger nada y se puede incumplir protegiendo**

- **Ubicación:** `requirements/REQ-020.md` CA-07 (la quinta forma prohibida) y CA-04 (iii), contra
  `requirements/README.md` § (a) —la regla de enunciar por propiedad y no por lista— y § (b) —tipo del
  número—.
- **Descripción.** La forma se contrata como *«hace falta un **literal**, y el literal **es** el
  control»*. «Literal» es **una** implementación admisible, no la propiedad. La propiedad es: *un
  término **independiente del artefacto vigilado en el momento de la corrida**, cuya modificación sea
  **visible en la revisión del cambio**.* Escrita como está, falla en las dos direcciones:
  - **Satisface sin proteger:** un literal tecleado contra el que **nadie compara** —o cuya rama de
    comparación está suspendida— cumple la regla al pie de la letra y no vigila nada. Es SEC-038.
  - **Incumple protegiendo:** un término que no es un literal en el archivo pero **sí** es independiente
    del artefacto —un número publicado en la salida de la versión anterior y comparado, un valor en un
    archivo que la corrida no produce— queda declarado infractor por una regla que existe para
    protegerlo.
  Y es la ironía que hay que decir en voz alta: **CA-07 es el criterio que adopta una forma prohibida
  nueva, y está escrito en la forma prohibida (a)** —nombrar el mecanismo en vez de la propiedad—, que
  es la primera de las cuatro ya adoptadas.
- **Sobre la mitad del derivado (CA-04 iii): es doctrina correcta, y hoy es una promesa sin puerta.**
  El enunciado —*si algún día se deriva, el mismo cambio contrata el caso «precondición no cumplida» y
  ese caso es **ruidoso***— es exactamente la lección del trinquete congelado seis días, y hay que
  conservarlo. Pero su único cumplimiento efectivo es **un caso dentro de
  `autoprueba-corredor.sh`** —el que comprueba que la asignación es literal—, en un archivo de
  `tests/` sin custodia (SEC-045), cuyo propio contador `AUTOPRUEBA_CASOS_ESPERADOS=73` vive **en el
  mismo archivo** y lo mueve **la misma mano en el mismo commit**. Quien derive el literal borra el
  caso que lo prohíbe y baja el 73 a 72: dos ediciones en un archivo, cero señales fuera. La cláusula
  no es de relleno —fija la doctrina y hace visible la intención—, pero **no es una puerta**, y el REQ
  la presenta como si lo fuera.
- **Remediación (write-back).**
  1. **Reescribir la forma (e) por propiedad**, con el literal como **instancia más barata** y marcado
     «no exhaustivo», y nombrando que el control es la **conjunción** de SEC-038 y no el término
     suelto. Va igual en `requirements/README.md` y en `templates/requirements-README.md.tpl`, con el
     mismo alcance temporal que las cuatro adoptadas.
  2. **Declarar qué es CA-04 (iii):** doctrina con **forzador observable** —*toda comisión que edite la
     asignación del total, su comparación o su condición de suspensión la re-ejerce*— y no una puerta
     permanente. Un residual cuyo disparador es «que alguien se acuerde» no vence (misma corrección
     que SEC-033).
  3. Y el testigo externo de SEC-038 (3) es lo que convierte la doctrina en señal: publicado en la
     salida, el número cambia **fuera** del archivo que lo contiene.

---

### SEC-045 — `contrato` · **abierto** · REQ-020 · severidad alta · dueño `analista-requerimientos` (el criterio) y `auditor-seguridad` (el residual)

**REQ-020 es el control que decide si las pruebas miden, y vive entero fuera de toda custodia: quien lo escribe, quien lo acredita y quien publica pueden ser el mismo actor — y «mutación de un tercero» importa evidencia de un entorno con independencia real**

- **Ubicación:** `requirements/REQ-020.md` CA-08 (i) y (ii), contra `.arnes/config.json`
  (`codigo_app.globs`), `AGENTS.md` §3, §4 y §6, y `docs/PENDIENTES.md:1249-1268`.
- **Lo medido, y es la respuesta a la pregunta de gobernanza que abrió esta comisión.**
  `codigo_app.globs` es `["hooks/*", "tools/*", ".github/*", ".arnes/config.json",
  ".claude-plugin/*"]`. **`tests/` no está.** Todo lo que REQ-020 construye —el literal, la línea
  `Acredita:`, los techos de SKIP, el inventario de lo no medido, la autoprueba que los certifica—
  aterriza en `tests/escenarios/hooks/`, donde `guard-codigo` **no deniega a nadie**: cualquier
  subagente y **la sesión coordinadora** pueden escribirlo. Y esa misma sesión es la que reúne la
  evidencia de «todo en verde» y la que **fusiona, etiqueta y publica por delegación permanente** del
  propietario (2026-09-05). `AGENTS.md` §6 llama a `tests/` **crítico** en prosa; ninguna máquina lo
  respalda, y tampoco hay gate humano (§6 lo pone sobre el ruleset, el workflow y el manifiesto, **no**
  sobre el banco).
  **Es la estructura de SEC-036 una capa más arriba y con más palanca:** allí el artefacto sin custodia
  era **una sonda**; aquí es **el juez de todas las sondas**.
- **Y el sustituto que el REQ propone —la mutación de un tercero— importa su evidencia de un sitio que
  no se parece a éste.** El dato es bueno y está medido: allí la mutación de un tercero encontró **el
  doble** que la del autor, y **2 de 4** sobrevivían. Pero ese «tercero» era **otro proyecto y otra
  persona**. Aquí los roles son **sombreros de la misma sesión**: mismo modelo, mismo disco, mismo
  despachante, y el `qa-tester` lee el mismo `AGENTS.md` y el mismo REQ que el `desarrollador`. La
  segunda evidencia que el REQ cita —*ninguno de los cuatro fallos en abierto de 1.32.1 lo encontró
  quien escribió el código*— **sí** es de esta casa y **sí** sostiene que el bucle de roles aporta algo;
  pero es evidencia sobre **el bucle**, no sobre **la mutación**, y no es evidencia de independencia
  epistémica. CA-08 (ii) contrata «un rol **distinto** del que escribió el código», que es lo único
  comprobable, y **presenta** esa exigencia con el respaldo del «doble», que mide otra cosa.
- **Riesgo.** El control que certifica que todos los demás controles miden se acredita a sí mismo, con
  un procedimiento cuya fuerza se apoya en una propiedad —independencia— que aquí no está contratada ni
  es verificable. Si falla en abierto, **todas** las puertas que certifica quedan sin certificar y no
  hay segunda lectura.
- **Remediación (write-back), y con ella acepto el residual.**
  1. **Decirlo en el REQ.** Una frase: *`tests/` está fuera de `codigo_app.globs`; el mecanismo de
     REQ-020 lo puede escribir cualquier agente, incluida la sesión coordinadora, que además acredita
     y publica.* Lo que no está escrito no se puede vigilar, y hoy no está en ninguna parte.
  2. **Contratar qué HACE tercero a un tercero**, ya que la independencia no se puede garantizar: (a)
     no haber escrito ni revisado el mecanismo bajo mutación en esta ventana; (b) **el conjunto de
     mutaciones se deriva del CRITERIO, no del código** —se redacta leyendo qué propiedad promete el
     CA y dónde tendría que morder, antes de leer la implementación—, que es lo que impide «romper
     donde el autor ya miró»; (c) se publica en `docs/qa/1.33.0.md` la mutación, quién la ejerció, y
     **qué caso pasó de PASS a FAIL**; (d) las supervivientes no se cierran (el REQ ya lo dice, y es lo
     que lo convierte en control).
  3. **Declarar el alcance honesto de CA-08:** dentro de una sola sesión esto es un control
     **procedimental**, no una garantía de independencia; su valor medido es el del bucle de roles, no
     el del «doble» del proyecto ajeno. Separar las dos citas en el texto del criterio.
  4. **NO meter `tests/` en `codigo_app.globs` en esta ventana**, y por el mismo motivo que acepté en
     SEC-036: tocar `.arnes/config.json` abre gate humano, y una entrada en `PENDING_APPROVAL.md`
     **deniega el cierre de cualquier REQ**, incluido REQ-017. Bloquear la ventana entera por custodiar
     el instrumento es peor negocio que acreditarlo. **Concurro con acreditar > custodiar**, con el
     mismo forzador observable: en la pasada de conformidad de **1.34.0** se ejerce una mutación de
     tercero **contra el propio mecanismo de REQ-020** —se altera el literal, o el operando, o la
     condición de suspensión— y se exige que la autoprueba **no dé verde**. Si pasa inadvertida, la
     decisión de no custodiar `tests/` vuelve a la mesa **con el número delante**.
- **Residual: lo asumo como dueño (`auditor-seguridad`)**, con las cuatro condiciones escritas en el
  REQ y no antes. Un residual que sólo vive en este registro es deriva (`AGENTS.md` §9).

---

### SEC-046 — `instrumento` · **abierto** · REQ-020 · severidad media · dueño `desarrollador` · ventana 1.33.0 (con la implementación)

**La declaración de estrechamiento se pone una vez en un perfil y silencia para siempre, y la salida no distingue una declaración TECLEADA de una HEREDADA**

- **Ubicación:** `requirements/REQ-020.md` CA-03, borde (b) y §«Y por qué no cría lobos».
- **Descripción.** El REQ ya reconoce la mitad —*«una variable exportada en la sesión puede volver
  silenciosa una vuelta parcial»*— y lo que afirma es cierto: no puede fabricar acreditación. Pero el
  único diente **nuevo** de CA-03 es el ABORT, y ese diente se retira **permanentemente** con una línea
  en un perfil de shell, sin dejar rastro. El argumento del REQ —«dispara exactamente una vez sobre
  cada estrechamiento no declarado»— supone que la declaración se **teclea cada vez**; si es una
  variable de entorno, se teclea **una** vez en la vida.
- **Por qué no bloquea.** No hace falso ningún enunciado del REQ y no afecta al producto: es una
  propiedad del control nuevo. `instrumento`, con dueño y ventana.
- **Remediación (para quien implemente).** La línea `Acredita: no` dice **de dónde vino la
  declaración**: argumento de la invocación o entorno heredado. Es información sobre **cómo se invocó el
  proceso**, que es el criterio del propio CA-03, y cuesta un campo. Una declaración heredada del
  entorno en la salida es exactamente el tell que un revisor necesita para no aceptarla como evidencia.

---

### Lo que esta revisión NO puede decir — la mitad honesta de una preventiva

- **Nada sobre el código de REQ-020: no existe.** No hay `SKIP_ADMITIDOS_SECCION` en ninguna sección,
  no hay línea `Acredita:`, no hay inventario de casos sin medir, no hay ayudante `skip` en el
  corredor. Esta firma **no acredita ninguna implementación**.
- **Nada sobre si el ABORT de CA-03 se dispara donde debe**, ni sobre si la clasificación se hace de
  verdad **antes de ejecutar nada**: hoy `PARCIAL` se calcula en `run.sh:485-487`, después del
  descubrimiento y de la comprobación de huérfanos, y si eso basta para «antes de ejecutar nada» es una
  pregunta sobre código que aún no está escrito.
- **Nada sobre el coste en RELOJ de SEC-043.** La razón 22,18× es un recuento de líneas sobre el texto.
  Su traducción a segundos —y sobre todo en Windows/MSYS, donde este proyecto no ha medido— **no está
  hecha**, y no podía hacerse: hay una comisión midiendo.
- **Nada sobre si CA-05 se puede cumplir sin abrir la vía que prohíbe.** Ejercer el cuadre **total** con
  entradas sintéticas exige que el total esperado sea gobernable desde fuera de la corrida real; la
  salida limpia es extraer la decisión a una función pura (precedente REQ-017) — pero **una prueba de
  la decisión no prueba el cableado**, que es SEC-038. Si esa vía es suficiente se sabrá **leyendo la
  implementación**, no antes.
- **Nada sobre los otros REQ de la ventana.** Hay tres comisiones corriendo; no he tocado REQ-017,
  REQ-018, REQ-021, REQ-022, `docs/qa/`, `tests/` ni `hooks/`. Lo que SEC-043 dice de
  `lee_casos_declarados` **roza** el delta pendiente de REQ-017, y queda como observación para su
  auditoría, **no** como hallazgo contra él: no es mi turno.
- **Nada ejecutado del banco**, ni una corrida, ni un reloj.

---

### ¿Veto? — **NO. `Seguridad: preventiva`, y no autoriza a cerrar**

No hay veto: no hay nada construido que vetar. Ocho hallazgos de **contrato** —que **bloquean el
cierre** hasta el write-back del `analista-requerimientos`— y uno de `instrumento`, que no bloquea.
Es barato y es el momento correcto: el REQ está `pendiente`, así que cada corrección cuesta **una
edición de criterio** y no una vuelta del bucle. **Ninguno de los ocho pide construir nada nuevo:**
siete piden enunciar por propiedad lo que ya se quería decir o corregir una afirmación sobre el árbol
de hoy que la lectura desmiente, y uno (SEC-045) pide declarar una condición de gobernanza que existe y
no está escrita.

**Rigor:** ya está en `critico` con `Sensible a seguridad: sí`. **No hay nada que subir** —es el techo—
y nada se baja. Y conviene decir por qué el techo está bien puesto aunque el REQ no toque dinero ni
datos personales: **es un control sobre los controles**; si falla en abierto, todas las puertas que
certifica quedan sin certificar y en silencio, que es la definición de `critico` de este proyecto.

**Lo que NO firmo, dicho aparte porque es la pregunta que abrió la comisión.** No firmo que exista
vigilancia sobre REQ-020. **No la hay**: el artefacto está fuera de `codigo_app.globs`, el sustituto es
la mutación de un tercero, y ese tercero es hoy **otro sombrero de la misma sesión**. Eso es SEC-045, y
lo asumo como residual con forzador observable en 1.34.0 — no lo declaro resuelto.

### Estado de seguridad aprobado por REQ — R-011 (línea base de no-regresión, ventana 1.33.0)

| REQ | Estado de seguridad | Fecha | Árbol | Controles acreditados / qué vigilar en la auditoría del código |
|---|---|---|---|---|
| **REQ-020** | **`preventiva`** (no es `aprobado`; no cierra) | 2026-09-07 | `cand/1.33.0` @ `93cff10`, **sin código** | Se acredita **el diseño**, con ocho huecos de contrato abiertos. Propiedades que la auditoría del código verificará: (a) el cuadre total es la **conjunción** término-literal ∧ operando ∧ rama ejecutada, y la lista de condiciones que lo suspenden es exhaustiva, única y coincide con los tres estados de CA-03 (SEC-038); (b) el techo de casos sin medir se calibra **sólo sobre corrida que acredita**, registra qué corrida lo justificó, separa la clase estructural de la contingente y **subirlo lleva firma ajena** (SEC-039); (c) la acreditación nombra **el sujeto** —directorio de hooks, de secciones, corredor— y ninguna salida del corredor es **rc 0 con cero casos** (SEC-040); (d) lo que sobrevive a una vuelta **con filtro** se dice sin generalizar desde el selector de secciones (SEC-041); (e) el motivo de un caso sin medir es **dato por canal propio**, no prosa dentro de la identidad del caso, y el inventario de CA-10 no se mueve (SEC-042); (f) la magnitud de coste de lectura es **líneas**, medida sobre `secciones/` real y no sobre el fixture trivial (SEC-043); (g) la forma (e) de `requirements/README.md` se enuncia **por propiedad** —término independiente del artefacto en el momento de la corrida— con el literal como instancia no exhaustiva (SEC-044); (h) **queda escrito** que `tests/` está fuera de `codigo_app.globs` y que la mutación de un tercero es, dentro de una sesión, un control **procedimental**; el residual es mío con forzador en 1.34.0 (SEC-045). **Regresiones a vigilar:** `CASOS_ESPERADOS` dejando de ser el operando de la comparación; un cuarto término en la condición de suspensión del cuadre total; `SKIP_ADMITIDOS_SECCION` subiendo sin corrida que lo justifique; y `AUTOPRUEBA_CASOS_ESPERADOS` bajando en el mismo commit que borra el caso del literal. |

**Alcance de esta firma.** Cubre el texto de REQ-020 tal como está hoy y las afirmaciones que hace
sobre el árbol actual. **No cubre el código posterior.** Cuando exista, la auditoría se repite
**después del `qa-tester`**, como manda `AGENTS.md` §6.

---

## Revisión R-012 — firma de **REQ-017** (auditoría del código, **después** de QA), ventana 1.33.0 (`cand/1.33.0` @ `b6e581b`) — 2026-09-07

**Turno correcto, y por eso esta firma vale.** `QA: aprobado (2026-09-07)` estaba escrito antes de que
yo empezara, los 10 criterios pasan y QA verificó que el árbol de código no se movió entre la vuelta 2
y este commit. Esta **no** es una preventiva: hay código y lo audito. Mi firma acredita **la revisión
de seguridad**, no las quality gates — que no miro (`AGENTS.md` §6).

**Medí a solas.** Fui la única comisión corriendo, así que las sondas de reloj de otros no me
falsearon nada ni yo a nadie. Aun así **ninguna cifra mía es de reloj**: son recuentos y comparaciones
de decisión, que no dependen de la carga.

**Alcance leído:** `requirements/REQ-017.md` entero, `docs/decisions/ADR-004-…`, `docs/qa/1.33.0.md`
(vueltas 0, 1 y 2), `hooks/lib.sh` (el escáner, la boca única y `arnes_norm_clave`),
`hooks/guard-completado.sh` (las ramas de CR, de veredictos y de clase de hallazgo),
`hooks/campos-req.awk`, `tools/arnes-lectura.sh`, `tools/arnes-paralelo.sh`,
`.github/workflows/banco.yml`, las dos secciones 37 del banco, `.arnes/config.json`, y mis R-010 y
R-011.

**Método: ejecutar, no leer.** Este REQ nombra en su propio texto la clase «una afirmación sobre cómo
se comporta el mecanismo, escrita sin ejecutarla», y la cuenta **tres veces dentro de sí mismo**. No
iba a aportar la cuarta: todo lo que afirmo abajo lo corrí contra el árbol, y lo que no pude medir lo
digo.

---

### Lo que verifiqué y **sostiene**

**1. La equivalencia de la sentencia, atacada por donde QA no atacó: contra la verdad de BYTES, no
contra la heredada.** QA comparó los dos árboles entre sí. Yo comparé el árbol nuevo contra el
**oráculo de bytes** —«¿hay un CR que no sea el último byte?»—, que es la propiedad que `AGENTS.md`
§13 contrata. Es la pregunta que importa para seguridad: da igual que los dos árboles coincidan si los
dos se apartan del contrato.

| Sonda | Entradas | Divergencias `nueva` vs oráculo de bytes |
|---|---|---|
| Adversarias a mano (CR final, CR + byte inválido, `?` contra byte inválido, `\xe2\x82` truncado) | 15 | **0** |
| Fuzz aleatorio, alfabeto denso en CR y multibyte inválido, locale del entorno | 20 000 | **0** |
| El mismo corpus bajo `LC_ALL=C` (invariancia de locale de **este** árbol) | 20 000 | **0** |
| Fuzz dirigido con metacaracteres de glob (`\`, `[`, `]`, `*`, `?`), 2 semillas | 120 000 | **0** |

La duda concreta que traía —que `?` en `*$CR?*` es **un carácter** y no un byte, y que bajo UTF-8
pudiera **no casar** contra un byte multibyte inválido, dejando `cr=0` donde la verdad es `cr=1`— está
**medida y no ocurre** en bash 5.3.9 con `C.UTF-8`: `?` casa el byte inválido. Ésa era la única vía por
la que este cambio podía **abrir** una puerta, y no está.

**2. La dirección de las divergencias con la heredada, incluida la que nadie había buscado.** Busqué
explícitamente el sentido peligroso (heredada deniega → este árbol permite) y **existe**: sobre
`e2 5c 0d` (1 de 60 000). Pero es la heredada la que está equivocada — el único CR de esa línea es el
**final**, que el contrato llama transporte —, así que este árbol acierta y la heredada producía un
**falso positivo**. De 17 divergencias observadas, 16 son «la heredada abría» y 1 «la heredada cerraba
de más». En las dos, **este árbol coincide con el oráculo**. Consecuencia que conviene retener: v1.32.1
tenía una **puerta no determinista** que podía denegar un REQ válido al azar, y este REQ la retira.

**3. La afirmación de CA-10 que más me interesaba falsar, y no pude.** El REQ dice: «*no afirma que el
veredicto de la puerta cambie en esa clase. Está medido que no cambia*». Construí la cabecera diseñada
para maximizarlo —120 líneas de relleno multibyte inválido antes de la línea envenenada, para que el
proceso llegue a ella con el asignador sucio, que es la condición en que la heredada falla— y corrí
`guard-completado` **120 veces por árbol**: **0 deny / 120 allow en los dos**. El veredicto de la
puerta no cambia. La afirmación del REQ **sobrevive a un intento serio de tumbarla**.

**4. Sin regresión contra el estado aprobado en R-009 (REQ-016).** La guarda sigue siendo la **primera
sentencia** del **único** escáner (verificado sobre el texto de la función, no sobre el comentario que
lo dice); las cuatro bocas siguen entrando por `arnes_campo_linea` (`arnes-lectura.sh:139`,
`arnes-paralelo.sh:116`); la guarda no se duplicó en `campos-req.awk`; y la denegación por CR interior
sigue **citando la línea** (reproducido: `Nota: hola\rmundo` deniega en los dos árboles con el mismo
motivo). El cambio es **observacional** —sólo escribe `ARNES_CR` y `ARNES_CR_LINEA`, no toca
`ARNES_LINEA`—, así que ningún lector aguas abajo puede cambiar de opinión: ésa es la propiedad que
contiene el radio de este cambio, y es la razón técnica por la que una sola línea es auditable.

**5. El delta de producto es el que se dice.** Contra `v1.32.1`, `hooks/` y `tools/` cambian en
**una línea de código** (verificado por `git diff --stat` y filtrando comentarios). No hay nada más
que auditar en el producto.

**6. `fetch-depth: 0` no materializa nada sensible.** Barrí **toda** la historia (128 commits): sin
claves ni tokens (patrones AWS/GitHub/PEM/Slack/OpenAI), **ningún** archivo de `insumos/`,
`mejoras-arnes-*` ni `reporte-arnes-*` estuvo jamás versionado, y **ningún** archivo fue borrado nunca
de la historia. La preocupación estándar del clon completo —el secreto retirado que el clon superficial
escondía— **no aplica aquí**, y ahora está medido en vez de supuesto.

**7. Ningún REQ, presente o pasado, lleva un carácter invisible en su cabecera** (BOM, U+200B–U+200F,
U+2060, UTF-8 inválido, CR interior): barrido sobre el árbol y sobre toda la historia de
`requirements/`. Importa por SEC-047: la vulnerabilidad es **latente**, no un incidente vivo, y **no
hay que reabrir ningún cierre**.

---

### SEC-047 — `instrumento` · **abierto** · severidad **crítica** · dueño `analista-requerimientos` (el criterio) y `desarrollador` (la guarda)

**Un carácter que no se ve y que el normalizador no retira borra un campo de la cabecera, y para dos campos la ausencia ABRE la puerta**

- **Ubicación:** `hooks/lib.sh:1689` (`arnes_norm_clave`, que **este REQ no toca**) y
  `hooks/guard-completado.sh:486-489` (`case "$hall" in ''|ninguno|…) hall='' ;;` — la ausencia se
  resuelve como «no hay hallazgos»).
- **Preexistente y ajeno a REQ-017:** medido **idéntico** en `v1.30.3`, `v1.31.0`, `v1.32.0`, `v1.32.1`
  y este árbol. Este REQ no lo introduce, no lo agrava y no podía verlo ningún criterio suyo.
- **Medido (ejecutado contra `guard-completado.sh` real, proyecto de prueba, todo lo demás en verde):**

  | Cabecera | Veredicto de la puerta |
  |---|---|
  | `Hallazgos abiertos: SEC-999 (contrato)` intacta | **DENY** (correcto) |
  | la misma con `0xc3` delante | **ALLOW** |
  | la misma con **BOM** (`EF BB BF`) delante | **ALLOW** |
  | la misma con **U+200B** (anchura cero) delante | **ALLOW** |
  | `Sensible a seguridad: sí` con **BOM** delante + `Rigor: ligero`, con **`QA: pendiente` y `Seguridad: pendiente`** | **ALLOW** |
  | la misma **sin** BOM | **DENY** (correcto) |

- **Riesgo, dicho sin adorno.** La última fila cierra a `completado` un REQ que **nadie validó y nadie
  auditó**, porque un carácter invisible retira el suelo de rigor que `Sensible a seguridad: sí` impone
  y deja gobernar a `Rigor: ligero`. La penúltima retira un hallazgo `contrato` que bloqueaba. Es el
  **bypass completo de la capa de enforcement**, con un carácter que **ningún revisor humano puede ver
  en el diff**, y no hace falta malicia: un BOM lo añade PowerShell al redirigir, y este proyecto
  desarrolla en Windows/MSYS. Es exactamente la forma que `AGENTS.md` §13 ya documenta —«una preferencia
  por la consola desactivó un guardián sin que nadie relacionara las dos cosas»—, una vuelta más.
- **Por qué el arnés no lo ve, y es la parte reutilizable.** La guarda del CR es correcta y está bien
  construida —propiedad, no sitio; primera sentencia; escáner único (R-009)—, pero su **extensión está
  mal trazada**: nombra **el CR**. La propiedad verdadera es más ancha: *una línea de cabecera que lleva
  un carácter que **no se representa** y que la normalización **no retira** no se puede medir, y una
  puerta que no puede medir no deja pasar*. Es la misma lección que este repositorio lleva escrita cinco
  veces —perseguir el objetivo en vez del estado— aplicada al carácter en vez de al delimitador. Y
  encaja en la doctrina de `requirements/README.md`: el control está descrito **por enumeración de un
  carácter** cuando debía estarlo **por propiedad**.
- **Remediación (write-back, `analista-requerimientos`; implementación, `desarrollador`).**
  1. **Enunciar la propiedad, no el carácter**, extendiendo la guarda que ya existe y **en el mismo
     sitio** (primera sentencia del escáner único, para no reabrir la clase de las cuatro bocas): la
     cabecera no se puede medir si una de sus líneas lleva un carácter no representable o de anchura
     cero que la normalización no retira. La lista exhaustiva vive **en un solo sitio** —la función— y
     los ejemplos del criterio se marcan **no exhaustivos** (BOM/U+FEFF, U+200B–U+200F, U+2060, C0
     distintos de tab/LF/CR, UTF-8 mal formado).
  2. **Y la mitad que no es del lector:** que la **ausencia** de `Hallazgos abiertos:` y de `Sensible a
     seguridad:` deje de resolverse en la dirección que abre. Hoy `hall=''` se lee «no hay hallazgos»;
     debería distinguirse «declarado vacío» de «no declarado», con la misma doctrina que ya rige el
     rango de cita: *nunca permitir por AUSENCIA del campo que algo se tragó*
     (`hooks/lib.sh:1571-1575`). **Las dos mitades hacen falta**: la (1) sin la (2) deja abierta
     cualquier otra vía futura de hacer desaparecer una línea.
- **No bloquea REQ-017** —`AGENTS.md` §6: un defecto de un guardián del propio arnés es `instrumento` y
  no puede ser condición para cerrar otro REQ— **pero no es deuda de las baratas.** *Forzador:* es el
  primer trabajo de 1.34.0, por delante del núcleo por estado. *Vencimiento:* el cierre de 1.34.0. Si
  1.34.0 cierra sin esto, vuelve a la mesa **subido a `contrato`**, porque entonces `AGENTS.md` §13
  estaría describiendo una guarda que el árbol no tiene en la extensión que la sección promete.

---

### SEC-048 — `instrumento` · **abierto** · severidad alta · dueño **propietario** (el ruleset) y `desarrollador` (el workflow)

**`fetch-depth: 0` convierte un SKIP inerte en EJECUCIÓN: la puerta requerida de `main` ahora ejecuta código identificado por referencias MUTABLES, y ninguna aparece en ningún diff revisado**

- **Ubicación:** `.github/workflows/banco.yml:23-43` (el `fetch-depth: 0` que **este REQ introduce**),
  contra `tests/escenarios/hooks/secciones/37-…-1-escala.sh:36-52,377-378,445-446` y
  `…-2-la-seccion-caliente.sh:39-55,252-253`.
- **Lo que cambió, y es exactamente la pregunta que la comisión me hizo.** Las secciones 37
  **materializan** `hooks/` y `tools/` desde los tags `v1.32.1` y `v1.32.0` (`git ls-tree` + `git show`)
  y después los **ejecutan**: `bash "$EVA37" "$HER37/hooks/lib.sh" …` los carga, y
  `ARNES_HOOKS_DIR="$HER47/hooks" … bash "$BANCO47"` corre el banco **con los hooks del tag**. Sin tags
  —el estado anterior— esos casos salían **SKIP** y no se ejecutaba nada. Con `fetch-depth: 0`
  **se ejecutan**. El hallazgo H-08 era real y la corrección es correcta; lo que no se declaró es que la
  corrección **enciende una ruta de ejecución** en la puerta requerida.
- **Medido:** el repositorio tiene **un solo ruleset**, `proteger-main`, con `"target": "branch"`
  (`gh api repos/JJOVEGA/ArnesJuan/rulesets`). **No hay ruleset de tags.** Los tags son, por tanto,
  creables y **reescribibles con force-push** por cualquiera con permiso de push —`jvega-habitat` lo
  tiene—, sin pasar por PR ni por revisión.
- **La propiedad, que es una y tiene dos instancias (no una lista):** *la puerta requerida ejecuta
  código identificado por una referencia que puede cambiar sin dejar rastro en ningún diff.* Instancias
  **no exhaustivas** de hoy: los tags `v1.32.1`/`v1.32.0` del propio repositorio, y `actions/checkout@v4`
  (tag mayor móvil, no fijado por SHA).
- **Riesgo.** Mover un tag **no aparece en el diff de ningún PR**, y la puerta requerida es justamente
  la evidencia sobre la que el humano decide fusionar. Es código no revisado dentro de la ruta de
  confianza. El actor necesita permiso de push, sí — pero un cambio en `tests/` se **ve** en el PR y un
  tag movido **no**, y esa asimetría es todo el hallazgo. Es la estructura de SEC-045 (`tests/` sin
  custodia) una capa más afuera: allí el juez de las sondas no lo vigila nadie; aquí **el árbol contra
  el que se mide** tampoco.
- **No medido, y se dice:** los permisos por defecto del `GITHUB_TOKEN` del repositorio (`gh api …
  /actions/permissions/workflow` → **403**, hace falta admin). El workflow **no declara** bloque
  `permissions:`, así que hereda el defecto del repositorio, que no pude leer. Sin ese dato **no puedo
  acotar el radio** de una ejecución hostil en el runner, y por eso no lo acoto.
- **Remediación, por coste creciente.**
  1. **Ruleset de tags** que prohíba actualizar y borrar `v*` (ajuste de repositorio del **propietario**,
     minutos, **no necesita REQ ni ventana**). Cierra la instancia principal.
  2. **Declarar `permissions:` explícito** en `banco.yml` con el mínimo (`contents: read`): acota el
     radio aunque se ejecute algo hostil, y no depende de (1).
  3. Fijar `actions/checkout` por SHA. Menor: es acción oficial de GitHub.
- **No bloquea REQ-017**, y por el mismo motivo que acepté en SEC-045: (1) es un **gate humano**
  (`AGENTS.md` §6, «cambiar el ruleset») y una entrada en `PENDING_APPROVAL.md` **denegaría el cierre de
  cualquier REQ, incluido éste**; bloquear la ventana por custodiar el instrumento es peor negocio que
  declararlo. *Forzador:* la pasada de conformidad de **1.34.0**. *Vencimiento:* el cierre de 1.34.0.
  Aplico aquí la misma regla que a mí mismo en R-011; usar una distinta para un hallazgo que encontré yo
  sería elegir la vara según quién sostiene el espejo.

---

### SEC-049 — `instrumento` · **abierto** · severidad baja · dueño `analista-requerimientos`

**CA-10 declara la divergencia en un solo sentido, y está medida en los dos**

- **Ubicación:** `requirements/REQ-017.md`, CA-10 § «Qué queda cerrado con esto».
- **Descripción.** El criterio declara el sentido que **cierra** («la heredada publica `cr=0` sobre una
  línea que sí lleva un CR interior») y lo presenta, con razón, como beneficio no buscado. No declara
  que la divergencia es **bidireccional**: existe la clase en que la heredada **denegaba** y este árbol
  **permite** —`e2 5c 0d`, 1 de 60 000 en mi fuzz dirigido—, correctamente, porque ahí el único CR es el
  de transporte y la heredada producía un falso positivo.
- **Riesgo.** Bajo, y es de **coste futuro**: quien mida el otro sentido en una ventana posterior lo
  leerá como un fallo en abierto introducido por REQ-017, gastará una vuelta en descartarlo, o
  «arreglará» la relajación reintroduciendo el falso positivo de la heredada. Es el reverso exacto del
  argumento que el propio REQ usa para declarar el primer sentido: *un beneficio no declarado es una
  propiedad que nadie sabe que tiene y que la próxima refactorización retira sin enterarse.*
- **Remediación.** Una frase en CA-10: la divergencia es bidireccional, en los dos sentidos este árbol
  coincide con el oráculo de bytes, y en el sentido que relaja la heredada tenía un **falso positivo**
  (una puerta no determinista que podía denegar un documento válido). *Vencimiento:* el próximo
  write-back que toque REQ-017 o el cierre de 1.33.0, lo que ocurra antes.

---

### La pregunta de gobernanza de R-011, contestada para **este** cierre

**Sí cambia algo, y no cambia la decisión.** REQ-017 **entrega** dos secciones de banco y toca el
corredor, así que por primera vez el artefacto sin custodia de SEC-045 —`tests/`, fuera de
`codigo_app.globs`, escribible por cualquier agente **incluida la sesión que acredita, decide y
publica**— no es una hipótesis de diseño: es código entregado dentro de la firma que estoy dando.

Y ya tiene **instancia medida**: **QA-017-11**. `CA-01` guarda con cuidado las dos formas de quedarse
sin entradas **de fuera** y **no guarda `dentro = 0`**; QA lo demostró truncando la evaluación de la
heredada — el dominio cae de 312 a 10 entradas y el caso **sigue en verde**. Es decir: el juez de las
sondas de este REQ **puede dar verde sobre un universo colapsado**, exactamente el riesgo que SEC-045
describe, en el artefacto que SEC-045 dice que nadie custodia.

**Aun así no cambio la disposición, y por tres razones que no son de comodidad:** (a) la partición se
**publica en el mensaje del caso**, así que un colapso se ve **leyendo** —lo que falta es que lo vea la
máquina—; (b) el dominio real medido es 97–99 de 106 en 4 de 4 corridas, así que hoy no oculta ningún
defecto; y (c) el remedio —meter `tests/` en `codigo_app.globs`— toca `.arnes/config.json`, que es
**gate humano**, y su entrada en `PENDING_APPROVAL.md` **denegaría este mismo cierre**. Sigue valiendo
**acreditar > custodiar**, con el forzador de SEC-045 intacto en 1.34.0, y ahora con **un número
delante** en vez de un argumento: si la mutación de tercero de 1.34.0 no caza QA-017-11, la decisión de
no custodiar `tests/` vuelve a la mesa.

---

### Rigor

**`critico`, y se queda.** `Sensible a seguridad: sí` lo impone como suelo y no hay nada que subir.
**Nada se baja.** No reabro ningún REQ cerrado: el barrido de invisibles sobre toda la historia de
`requirements/` salió limpio, así que SEC-047 no contamina ningún cierre pasado.

### Estado de seguridad aprobado por REQ — R-012 (línea base de no-regresión)

| REQ | Estado de seguridad | Fecha | Árbol | Controles acreditados / regresiones a vigilar |
|---|---|---|---|---|
| **REQ-017** | **`aprobado`** | 2026-09-07 | `cand/1.33.0` @ `b6e581b` (con mi edición de cabecera encima) | **Acreditado:** (a) `case "$l" in *$CR?*)` coincide con el **oráculo de bytes** en 160 015 entradas propias, 0 divergencias, bajo el locale del entorno y bajo `LC_ALL=C`; (b) `?` **sí** casa un byte multibyte inválido en bash 5.3.9/`C.UTF-8`, que era la única vía de fallo en abierto de este cambio; (c) el veredicto de `guard-completado` **no cambia** en la clase divergente (120 invocaciones por árbol, cabecera diseñada para maximizarlo, 0 deny en los dos); (d) las invariantes de REQ-016 intactas —guarda como primera sentencia del escáner único, cuatro bocas por `arnes_campo_linea`, sin duplicar en `campos-req.awk`—; (e) el cambio es **observacional** (no toca `ARNES_LINEA`), así que ningún lector aguas abajo puede cambiar de opinión; (f) delta de producto = **una línea**; (g) la historia completa que `fetch-depth: 0` materializa **no contiene** secretos ni material de cliente, nunca los contuvo y nada se borró jamás. **Regresiones a vigilar:** que la guarda deje de ser la primera sentencia o se mude a una de las cuatro bocas; que el escáner pase de **observar** a **modificar** `ARNES_LINEA`; que aparezca una segunda transcripción de la guarda del CR fuera de `arnes_sin_cita`; que `*$CR?*` se «optimice» a una forma que dependa del locale; y que alguna sección del banco deje de materializar la línea base y pase a un inventario congelado. |

**Lo que esta firma acredita y lo que NO — dicho aparte porque es la mitad que se olvida.**
*Acredita:* que revisé la seguridad del código de este REQ y que la sentencia que lo justifica hace lo
que dice, medido contra el contrato y no contra su gemela. *No acredita:* las **quality gates** —no las
miro, y por eso firmo después de QA—; el **valor** de la pared de los 60 s (`SEC-030`); el
comportamiento de `arnes_norm_clave`, que este REQ no toca y que arrastra **QA-017-07** y ahora
**SEC-047**; ni que `tests/` esté custodiado (**SEC-045**, residual mío, abierto).

---

## Revisión R-013 — **investigación del guardián publicado** (no es auditoría de ningún REQ): la cuarta vía de bypass del enforcement, medida — 2026-09-08

**Esto no firma nada, y el motivo importa más que la aclaración.** No es la auditoría de REQ-021 ni de
REQ-023: es una investigación sobre el guardián **publicado**, que es terreno propio de
`docs/seguridad/`. No he tocado la línea `Seguridad:` de ningún requerimiento, ni ningún REQ, ni
`AGENTS.md`, ni `PENDING_APPROVAL.md`. REQ-021 está en `con-hallazgos` con la vuelta 1 pendiente y mi
firma sobre un árbol que el `qa-tester` no ha validado no valdría nada (`AGENTS.md` §6). Los fixtures
vivieron **fuera del árbol del repositorio**.

**Origen: una pregunta abierta del analista, dejada abierta con disciplina.** REQ-023 §«Preguntas
abiertas» punto 2 dice que la instancia alcanzable de la mitad (2) de SEC-047 está **derivada leyendo**
`arnes_rigor_efectivo`, `arnes_sens_efectiva` y la rama `if [ "$rigor" != "ligero" ]`, y **no corrida**,
para no falsear las sondas de reloj de la comisión de QA. Fue lo correcto. Y lo que se le debía no era
una segunda lectura: era la ejecución.

**Método: ejecutar, no leer.** Todo lo de abajo se corrió contra el **entrypoint real** (`hooks/guard.sh`)
con un `PreToolUse` JSON idéntico al que emite Claude Code, sobre un proyecto de prueba con manifiesto
propio. **Ninguna cifra es de reloj:** todas son decisiones (`deny`/`allow`) y recuentos, así que no
dependen de la carga ni de qué otra comisión estuviera corriendo.

**Los dos árboles, porque no es lo mismo un agujero en lo publicado que uno en la candidata.** Medí
contra la **instalada 1.32.1** —la que corre los hooks de esta sesión y gobierna el desarrollo de la
siguiente (`docs/gobernanza/autoalojamiento.md`)— y contra el **árbol de trabajo** `cand/1.33.0` @
`675d298`. `guard-completado.sh`, `campos-req.awk`, `guard.sh` y `hooks.json` son **idénticos byte a
byte**; `lib.sh` difiere en **una** línea (la guarda del CR de REQ-017, `case "$l" in *$'\r'?*`). Las
**23 filas** del banco dieron **el mismo veredicto en los dos árboles, sin una sola divergencia**. Así
que todo lo que sigue vale igual para lo **publicado** y para la **candidata**, y no hay nada que
atribuir a 1.33.0.

**Calibración, antes de creerme un solo `allow`.** Un banco que sólo sabe denegar no mide nada. Con el
mismo fixture y el mismo emisor: REQ con todo aprobado → **ALLOW**; el mismo con `QA: pendiente` →
**DENY**. Las dos direcciones se alcanzan.

---

### 1. La hipótesis del analista: **CONFIRMADA**

Corrida sobre la instalada **1.32.1** y reproducida idéntica en `cand/1.33.0`. `Estado:` pasa de
`en-revisión` (disco) a `completado` (contenido entrante); cola de aprobaciones vacía y quality gates
en verde en todas las filas, para que lo único que se mida sea la cabecera.

| # | Cabecera (lo demás en verde) | Veredicto |
|---|---|---|
| 1 | `Sensible a seguridad: sí` + `Rigor: ligero` + `QA: pendiente` + `Seguridad: pendiente` — **control negativo** | **DENY** (correcto: el suelo impone `critico`) |
| 2 | la misma con **`<!-- Sensible a seguridad: sí -->`** | **ALLOW** ← **la hipótesis** |
| 3 | la misma con esa línea **borrada** — control de equivalencia | **ALLOW** (idéntico a #2) |
| 4 | `Rigor: critico` + `QA: aprobado` + `Seguridad: pendiente`, **sin** `Sensible` — control negativo | **DENY** (correcto) |
| 5 | la misma con **`<!-- Rigor: critico -->`** | **ALLOW** ← **variante nueva** |
| 6 | `Rigor: estandar` + `QA: pendiente` + `Seguridad: aprobado` — control negativo | **DENY** (correcto: orden del ciclo) |
| 7 | la misma con **`<!-- QA: pendiente -->`** | **ALLOW** ← **variante nueva** |
| 8 | `Sensible a seguridad: sí` + `QA: aprobado` + **`<!-- Seguridad: pendiente -->`** — **control positivo** | **DENY** (correcto: REQ-016 CA-11, la excepción) |
| 9 | `Hallazgos abiertos: SEC-999 (contrato)` visible — control negativo | **DENY** (correcto) |
| 10 | la misma **`<!-- Hallazgos abiertos: SEC-999 (contrato) -->`** | **ALLOW** |
| 11 | rango que **abre y no cierra** en la cabecera — control positivo | **DENY** (correcto: REQ-016) |

**La fila 2 cierra a `completado` un REQ con `QA: pendiente` y `Seguridad: pendiente` escritos a la
vista, y con su campo de sensibilidad diciendo `sí` en el propio documento.** Es el bypass completo de
la capa de enforcement, con **silencio total**: ni `deny`, ni `systemMessage`, ni aviso de vocabulario
—los dos veredictos están *dentro* del vocabulario, y `Sensible a seguridad:` no se comprueba contra
ninguno—.

**Formas equivalentes que también abren** (no exhaustivas; la propiedad está en §2): el comentario
**multilínea cerrado** que se traga tres campos de golpe; y **comentar sólo la clave**,
`<!--Sensible a seguridad:--> sí`, que deja un `sí` huérfano que no declara nada.

**Y las que NO abren, que es lo que delimita la clase:** un comentario **antes** de la clave en la
misma línea (`<!-- nota --> Sensible a seguridad: sí`) **cuenta** —el rango se sustituye por un espacio
y el resto de la línea sobrevive, como REQ-016 diseñó—; y una segunda ocurrencia comentada **no**
derroca a la declaración visible. El lector de cabecera tiene noción de **rango** y la aplica bien.

**Alcance del bypass, medido, para no exagerarlo.** El `Rigor: ligero` que se obtiene comentando **no**
salta: la clase del hallazgo (fila 9 sigue denegando con `Rigor: ligero`), las **quality gates**
(`false` → DENY), ni la **cola de aprobaciones humanas** (1 pendiente → DENY). El comentario de
`hooks/guard-completado.sh:377` describe con exactitud lo que hace. *Nota de método: mi primera sonda
de la cola dio un falso `ALLOW` porque escribí las entradas como `- [ ]` y la cola cuenta encabezados
`### `. La sonda medía otra cosa; se corrigió y el resultado se invirtió. Queda escrito porque es la
clase de error que este registro lleva nombrada.*

---

### 2. La clase, en una frase que se puede contratar

> **Un campo de la cabecera cuya AUSENCIA la puerta resuelve del lado que ABRE queda satisfecho
> haciendo desaparecer su línea, por cualquier vía —un carácter invisible, un rango de comentario, un
> borrado—; y la vía no cambia el veredicto, porque la puerta no mide la vía, mide la ausencia.**

Escrita así se contrata, y de ella se derivan las dos consecuencias operativas que la enumeración
oculta: **(a)** cerrar la vía del carácter (REQ-023) no cierra la clase, porque el comentario y el
borrado siguen abiertos; y **(b)** la lista de campos con esa propiedad tiene que vivir en **un solo
sitio** y ser exhaustiva ahí, con los ejemplos marcados **no exhaustivos**
(`requirements/README.md` §«Cómo se escribe un criterio que no se desmiente»).

**Hoy la propiedad se cumple en cuatro de los seis campos que el lector reconoce**, y ésta es la tabla
que ningún documento tiene:

| Campo de cabecera | Qué hace la AUSENCIA | Dirección |
|---|---|---|
| `Sensible a seguridad:` | `arnes_sens_efectiva` → `no` → **no hay suelo de rigor** (`lib.sh:1467`, `arnes_rigor_efectivo`) | **ABRE** |
| `QA:` | perdonada por compatibilidad (`guard-completado.sh:380`, `[ -n "$qa" ] && …`) | **ABRE** |
| `Hallazgos abiertos:` | se resuelve como «no hay hallazgos» (`guard-completado.sh:487-490`) | **ABRE** |
| `Rigor:` | cae al defecto derivado; con `Sensible` ausente, **`critico` → `estandar`**, que ya no exige `Seguridad: aprobado` | **ABRE** |
| `Seguridad:` | en rigor efectivo `critico`, `'' != aprobado` → deniega | **cierra** (la única) |
| `Estado:` | sin estado terminal no hay intento de cierre que juzgar | n/a |

---

### 3. ¿Hallazgo nuevo o la misma cara de REQ-024? — **las dos cosas, y la frontera es medible**

**La hipótesis en sí NO es un defecto nuevo, y el analista tenía razón.** La fila 2 es **REQ-016 CA-11
funcionando como se contrató** —«Comentar una declaración la RETIRA, y un campo ausente se perdona
salvo `Seguridad:` en un REQ de rigor efectivo `critico`»— más la **decisión** de que la ausencia se
perdone, firmada por mí en **R-009**. Mi fila 3 lo prueba en la dirección que importa: comentar y
borrar deciden **exactamente lo mismo**, que es la equivalencia que CA-11 pone como criterio. Un
defecto y una decisión, no dos defectos. **No abro un SEC para la fila 2.**

**Lo que SÍ es nuevo son tres cosas que la medición sacó y que ningún documento dice** — y van juntas
en **SEC-050**, porque son la misma falta de escritura:

1. **La superficie son cuatro campos, y todos los textos que la describen nombran dos.** La
   remediación (2) de **SEC-047** —la escribí yo— dice «la ausencia de `Hallazgos abiertos:` y de
   `Sensible a seguridad:`». Los ejemplos de **CA-11** dicen «`QA:`, `Hallazgos abiertos:`». Ninguno
   de los dos menciona **`Rigor:`**, y las filas 4/5 lo miden. Es exactamente la forma que mi propio
   encargo prohíbe: **un control descrito por enumeración envejece hacia el lado que abre**. Me lo
   aplico: **mi SEC-047 (2) está mal escrita**, y arreglarla es parte de esto.
2. **El puntero de «un solo sitio» de CA-11 es falso para el campo que más pesa.** CA-11 dice: «Qué
   campos perdona la ausencia lo decide **un solo sitio**, `hooks/guard-completado.sh`, y ahí vive la
   lista exhaustiva». Pero la regla que produce la fila 2 **no está ahí**: está en
   `hooks/lib.sh` (`arnes_sens_efectiva:1464-1467` y `arnes_rigor_efectivo:1915-1932`). Quien siga el
   puntero de CA-11 para enumerar la superficie **no encontrará `Sensible a seguridad:`** y concluirá
   que el suelo de rigor está a salvo. Un criterio que cita el sitio equivocado es peor que uno que no
   cita ninguno: promete una comprobación que no se puede hacer.
3. **La fila 5 desmiente una promesa que `AGENTS.md` hace sin condición.** §6: «*Bajarlo no es tuyo, ni
   de nadie sin firma del dueño del sistema. Un nivel que cualquiera puede rebajar deja de significar
   algo*»; §13 lista la invariante como cumplida por máquina. Medido: en un REQ que declara
   `Rigor: critico` y **no** declara `Sensible a seguridad:`, comentar —o borrar— esa única línea baja
   el rigor efectivo a `estandar` y **retira la exigencia de auditoría**, sin firma de nadie
   (**DENY** → **ALLOW**, filas 4 y 5). En **este** repositorio la política declara todo REQ
   `Sensible a seguridad: sí`, así que el suelo normalmente tapa el hueco; pero el plugin **se
   instala en otros proyectos**, y ahí un REQ `critico` por dinero, por identidad o por cambio
   irreversible —los criterios genéricos que `AGENTS.md` §6 lista— puede perfectamente no declarar
   sensibilidad. Para esos proyectos, una línea comentada retira la auditoría. **La promesa se cumple
   por la política de un consumidor, no por el mecanismo que se le entrega.**

---

### 4. Un hallazgo distinto, que apareció midiendo esto: **SEC-051**

Buscando la clase en el resto del enforcement encontré que **el lector de la cola de aprobaciones
humanas tiene la misma familia de defecto, pero con una forma peor**: no honra el rango, se come la
**línea entera**, y por eso **no hace falta comentar nada**. Va abajo con su propio id porque su
mecanismo, su dueño y su remediación son otros.

---

### 5. Barrido del historial: **latente, y no hay cierres que reabrir**

Mismo método que usé para SEC-047, con control positivo del barrido (inyecté un campo comentado en un
blob real y el barrido lo encontró; sin él, cero).

- **REQ:** recogí **todos** los blobs de `requirements/*.md` alcanzables desde **todas** las
  referencias (`git rev-list --all` → 136 commits → **133 blobs únicos**, 24 rutas) y busqué comentarios
  HTML **en la cabecera** (antes del primer `## `). **Cero.** Cross-check independiente por
  `git log --all -p`: las **únicas** apariciones de `<!-- Sensible a seguridad: sí -->` en toda la
  historia son la **prosa del propio analista** documentando la hipótesis en REQ-023 —cuerpo del
  documento, no cabecera—. Y cross-check de rutas: nunca hubo REQ fuera de `requirements/`.
- **Cola de aprobaciones:** los **4** blobs que `PENDING_APPROVAL.md` ha tenido en la historia
  (verificado por dos vías: `ls-tree` sobre todos los commits y `rev-list --objects`), pasados por
  `arnes_cola_pendientes` y contra un contador independiente: **cuadran los cuatro**, y en los cuatro
  la sección `## Pendientes` estaba vacía. Ninguna entrada llevó jamás comentario ni `-->`.
- **Árbol de hoy:** ningún REQ lleva comentario en cabecera; `PENDING_APPROVAL.md` cuenta **0** y es
  correcto (sus cuatro entradas están bajo `## Resueltas`).

**Conclusión: las dos vulnerabilidades son latentes. Nunca se han ejercido, ni por descuido ni de otro
modo, y ningún cierre pasado queda contaminado.** No reabro ningún REQ por esto.

---

### 6. Efecto sobre lo que ya estaba abierto

**SEC-047 — sube el forzador de su mitad (2), y se corrige su redacción.** El analista escribió que si
la instancia se confirmaba, el forzador de REQ-024 subiría de «decisión defendible» a «bypass
alcanzable con una edición visible, no una vía futura». **Se confirmó.** Y añado el argumento que la
medición permite y la lectura no: la mitad (1) —el carácter invisible, REQ-023— tenía una historia de
mitigación implícita («hace falta un BOM, y lo mete PowerShell al redirigir»); **la vía del comentario
no necesita nada de eso**. Es una edición de una línea que cualquier agente puede escribir con
`Edit`, que **aparece en el diff**, y que un revisor humano lee como *«el REQ declara que es
sensible»* mientras la máquina lee *«no declara nada»*. Que sea visible **no** la hace inocua: la hace
**plausible**, que en un pipeline de agentes es peor. Un BOM en un diff es una anomalía; un campo
comentado en un diff parece higiene.

**Estado de SEC-047:** sigue **`abierto`**, sigue `instrumento` (defecto de un guardián del propio
arnés, `AGENTS.md` §6), sigue **severidad crítica**. Su mitad (1) tiene contrato en REQ-023; su mitad
(2) sigue **sin archivo** hasta que exista REQ-024, y ahora con forzador subido.

**SEC-045 y la decisión de custodia del propietario (`tests/util/*` dentro de `codigo_app.globs`,
`tests/` entero no, ventana 1.34.0) — no cambian, y el motivo es una distinción que conviene dejar
escrita.** SEC-051 vive donde vive porque al banco **le falta un caso**
(`tests/escenarios/hooks/secciones/31-cola-una-sola-regla.sh` cubre el comentario **multilínea** de
REQ-009 CA-07 y ninguna de las tres formas que miden ABIERTO). **Custodia y completitud son
ortogonales:** un guardián sobre `secciones/` habría impedido *debilitar* un caso, y no habría
*escrito* el que nunca existió. Así que esto **no** es una instancia de SEC-045 y **no** mueve su
ventana; y de paso es evidencia **a favor** del alcance estrecho que el propietario eligió, no en
contra. Mi residual de SEC-045 se queda como está: **abierto, mío, forzador en 1.34.0**. Lo que sí
añade es una instancia más al argumento de fondo del que SEC-045 es una cara: **el banco es el
artefacto que sostiene todas las afirmaciones de este arnés, y su cobertura no la mide nadie**.

**SEC-030 (la pared de los 60 s) y SEC-020 (el desenvoltorio de `Archivos:`)** no se tocan: nada de lo
medido aquí los roza.

---

### SEC-050 — `contrato` · **abierto** · severidad **alta** · dueño `analista-requerimientos` (los criterios) y `auditor-seguridad` (la corrección de SEC-047)

**La superficie de «la ausencia ABRE» son cuatro campos; los tres textos que la describen nombran dos, señalan el archivo equivocado, y uno de los cuatro baja el rigor que `AGENTS.md` promete que no se puede bajar sin firma**

- **Ubicación de los textos que se desmienten:** `requirements/REQ-016.md:142-153` (CA-11: los ejemplos
  y el puntero «un solo sitio, `hooks/guard-completado.sh`»); `docs/seguridad/registro-seguridad.md`,
  remediación (2) de **SEC-047** (mía); `AGENTS.md` §6 («Nivel de rigor», el párrafo de bajar) y §13
  (fila «El rigor se puede subir, nunca bajar»).
- **Ubicación del mecanismo, que es el punto:** la lista NO está en un solo sitio. `QA:` y
  `Hallazgos abiertos:` se perdonan en `hooks/guard-completado.sh:380` y `:487-490`; pero
  `Sensible a seguridad:` y `Rigor:` se resuelven en `hooks/lib.sh:1464-1467`
  (`arnes_sens_efectiva`) y `hooks/lib.sh:1915-1932` (`arnes_rigor_efectivo`). **Dos sitios, y el
  criterio nombra uno.**
- **Medido** (instalada 1.32.1 y `cand/1.33.0`, veredicto idéntico; tabla completa en §1 de R-013):
  `Rigor: critico` + `QA: aprobado` + `Seguridad: pendiente`, sin `Sensible` → **DENY**; la misma con
  `<!-- Rigor: critico -->` → **ALLOW**. Y `Rigor: estandar` + `QA: pendiente` → **DENY**; con
  `<!-- QA: pendiente -->` → **ALLOW**.
- **Preexistente:** ni REQ-017 ni REQ-023 lo introducen; es la superficie que CA-11 contrató en 1.32.1
  descrita con menos alcance del que tiene.
- **Riesgo.** No es que la máquina haga algo distinto de lo que decidimos —eso es la decisión de
  CA-11/R-009, y es defendible—: es que **el papel promete una superficie más pequeña que la real**, y
  con un puntero que lleva al archivo donde el campo crítico no aparece. Quien audite la clase
  siguiendo el contrato **concluirá que el suelo de rigor está a salvo**, y no lo está. Además la fila
  5 contradice una promesa de `AGENTS.md` §6 hecha **sin condición**, que en los proyectos consumidores
  —donde un REQ puede ser `critico` sin declarar sensibilidad— es un retiro de la auditoría por una
  línea comentada.
- **Remediación (write-back, `analista-requerimientos`; la corrección de SEC-047, mía).**
  1. **Reescribir CA-11 por propiedad y con el puntero correcto:** enunciar que la ausencia se perdona
     en **todo campo salvo los que la lista exhaustiva declare**, decir que esa lista vive hoy en
     **dos** funciones nombradas (`guard-completado.sh` para los veredictos y el hallazgo, `lib.sh`
     `arnes_sens_efectiva`/`arnes_rigor_efectivo` para el suelo y el nivel) — o **unificarla en un
     sitio**, que es mejor y es lo que el criterio ya prometía—, y marcar los ejemplos **no
     exhaustivos**. Cualquier campo nuevo que se añada al lector debe declarar su dirección de
     ausencia **en ese sitio**.
  2. **Corregir la remediación (2) de SEC-047** para que diga la propiedad en vez de los dos campos:
     *ninguna ausencia de campo de cabecera se resuelve del lado que abre; la lista de campos y su
     dirección viven en un solo sitio*. Lo hago yo, y queda hecho en cuanto REQ-024 exista, para no
     desfasar el registro del contrato.
  3. **La fila del rigor de `AGENTS.md` §13 tiene que decir su alcance real,** o el mecanismo tiene que
     alcanzar lo que promete: hoy la máquina sólo sostiene «no bajar» **cuando hay suelo**, es decir
     cuando `Sensible a seguridad: sí` está declarado y **se lee**. Sin suelo, un `Rigor:` declarado es
     retirable. Las dos salidas valen; lo que no vale es la frase sin condición.
- **No bloquea ningún REQ en curso.** Es `contrato` sobre **REQ-016**, ya `completado` con
  `Seguridad: aprobado (R-009, 2026-09-07)`. **Y aquí está la decisión que me toca y la digo entera:
  NO reabro REQ-016 hoy.** Motivo: la conducta de la máquina es la que CA-11 contrató y la que firmé —
  la equivalencia comentar/borrar y la excepción de `Seguridad:` en `critico` se sostienen las dos,
  medidas—; lo que falla es el **alcance de la descripción**, y su reparación natural es el REQ que ya
  está enrutado para la semántica de la ausencia. *Forzador:* entra en **REQ-024** como parte de su
  contrato, no después. *Vencimiento:* el cierre de **1.34.0**, el mismo que SEC-047. Si REQ-024 se
  escribe sin cubrir los cuatro campos y el puntero, **reabro REQ-016** y esto pasa a bloquear,
  porque entonces habría dos textos firmados describiendo una superficie que la lectura desmiente.

---

### SEC-051 — `instrumento` · **abierto** · severidad **alta** · dueño `desarrollador` (el lector) y `analista-requerimientos` (el criterio)

**El lector de la cola de aprobaciones descarta la LÍNEA COMPLETA que contiene `<!--` o `-->` en cualquier posición: una aprobación humana pendiente, visible y sin comentar, desaparece de la puerta y de los tres informes — y un rango sin cerrar se traga las siguientes sin que nada avise**

- **Ubicación:** `hooks/lib.sh:1161-1162`, en `arnes_cola_pendientes`:
  ```
  case "$linea" in *'<!--'*) enc=1 ;; esac
  case "$linea" in *'-->'*)  enc=0; continue ;; esac
  ```
  El `continue` de la segunda rama es **incondicional**: cualquier línea que contenga `-->` se
  descarta, esté abierto un rango o no. Y la primera abre el rango con la línea entera dentro.
  **Idéntico en la instalada 1.32.1 y en `cand/1.33.0`.**
- **Medido** (proyecto de prueba, REQ con todo aprobado, `## Pendientes` con la entrada indicada):

  | Entrada bajo `## Pendientes` | `arnes_cola_pendientes` | Puerta | `arnes-lectura.sh` | Bloque derivado de `ESTADO.md` |
  |---|---|---|---|---|
  | `### Fusionar el PR a main` — control | **1** | **DENY** | 1 | 1 |
  | `### Fusionar el PR a main <!-- pedido a Juan el 8/9 -->` | **0** | **ALLOW** | 0 | 0 |
  | `### <!-- urgente --> Fusionar el PR a main` | **0** | **ALLOW** | 0 | 0 |
  | `### Migrar A --> B` — **sin comentario ninguno** | **0** | **ALLOW** | 0 | 0 |
  | `### Nota <!-- abro y no cierro` + **2 entradas reales detrás** | **0**, `rc=0` | **ALLOW** | 0 | **0** |
  | 3 entradas, la 2.ª con comentario | 2 | DENY | — | — |

- **Riesgo, y por qué lo pongo en `alta` aunque sea `instrumento`.** Esto derrota el **gate humano** de
  `AGENTS.md` §6 —«el pipeline se detiene y espera tu visto bueno»—, que es el único de los cuatro que
  no depende de ningún agente. Y a diferencia de todo lo demás de R-013, **no hace falta ningún acto
  deliberado**: `### Fusionar el PR a main <!-- pedido a Juan el 8/9 -->` es **exactamente** el estilo
  de anotación de este proyecto, y `### Migrar A --> B` es un título ordinario que no contiene comentario
  alguno. Se pierde la aprobación **escribiéndola bien**. Es, otra vez, la lección que este registro
  lleva escrita: *el lugar donde un proyecto disciplinado anota es precisamente lo que confunde a la
  máquina, así que quien mejor documenta se expone más* (SEC-023, REQ-016).
- **Y el agravante que lo separa de un miscontaje cualquiera: los tres canales de observabilidad
  coinciden en el número equivocado.** La puerta, `tools/arnes-lectura.sh` («*cola de aprobaciones: 0
  pendiente(s) — no bloquea el cierre*», y además «*Ningún valor anómalo*») y el bloque derivado de
  `docs/ESTADO.md` («**Aprobaciones pendientes:** 0») dicen **0** sobre un archivo con dos aprobaciones
  visibles. La propiedad de **una sola regla** de REQ-009 se cumple **perfectamente** y propaga el
  error a los tres sitios: **consistencia no es corrección**, y aquí no queda ningún canal donde una
  persona pueda notarlo. Ésa es la diferencia con SEC-050, y es la que le da la severidad.
- **Contradice, en la última fila, la doctrina que REQ-009 escribió para este mismo lector.** El
  Bloque C de REQ-009 dice que si la cola **no se puede contar** la puerta no deja pasar (CA-15) y el
  bloque derivado dice `sin datos`, **nunca `0`** (CA-16). Un rango abierto en `## Pendientes` es
  exactamente «no se puede contar»: no se sabe dónde acaba, se traga las entradas siguientes e incluso
  los encabezados de sección posteriores. El lector devuelve **`rc=0` y `ARNES_COLA=0`**, es decir
  **afirma haber medido**. Y la asimetría con el otro lector es la prueba de que es un defecto y no una
  decisión: en la **cabecera de un REQ**, un rango sin cerrar **DENIEGA** con motivo propio
  (`ARNES_CITA_ABIERTA`, medido en la fila 11 de §1); en la **cola**, el mismo rango sin cerrar cuenta
  cero en silencio. **Dos transcripciones de «noción de cita» que deciden al contrario**, y la buena es
  la del REQ.
- **Lo que sí está contratado, para no acusar de más:** REQ-009 **CA-07** cubre el **ejemplo
  multilínea completamente comentado** bajo `## Pendientes` → 0, y eso es correcto y deseable (es la
  plantilla del arnés). El banco lo prueba en
  `tests/escenarios/hooks/secciones/31-cola-una-sola-regla.sh:57-69`. **Ninguna** de las cuatro formas
  que abren tiene caso en el banco, y CA-07 está escrito **por enumeración de un caso** —«un ejemplo
  `### [AAAA-MM-DD] (agente) — Título` **dentro** de un comentario»— en vez de por propiedad. La misma
  falta de forma que SEC-050.
- **Remediación.**
  1. **El lector honra el RANGO, no la línea** (`desarrollador`), con la misma regla que ya existe y
     funciona en la cabecera (`hooks/lib.sh`, `arnes_sin_cita`): sustituir el rango cerrado por **un
     espacio** y **seguir juzgando el resto de la línea**, de modo que
     `### Fusionar el PR <!-- nota -->` cuente **1** y `### Migrar A --> B` cuente **1**. Lo ideal es
     que los dos lectores compartan **una** transcripción: dos se desfasan, y estas dos ya lo hicieron.
  2. **Un rango sin cerrar en la cola es «no medible», no cero** (`desarrollador`): `rc=1`, la puerta
     **DENIEGA** con motivo propio y el bloque derivado dice **`sin datos`** — exactamente la conducta
     que CA-15/CA-16 ya contrataron para el byte NUL, extendida a su clase.
  3. **Criterios por propiedad** (`analista-requerimientos`): enunciar que *una entrada de la cola
     cuenta si su encabezado `### ` sobrevive a la eliminación de los rangos de comentario cerrados*, y
     que *una cola con un rango abierto no se puede medir*; con los casos de la tabla de arriba como
     ejemplos **no exhaustivos**, y con la conducta de CA-07 preservada como control de no-regresión.
  4. **Casos en el banco** (`desarrollador`), en `31-cola-una-sola-regla.sh`, con la comparación
     fail-before/pass-after contra la instalada, y **cuadrando los tres lectores** (puerta, informe,
     bloque derivado) en cada uno.
- **No bloquea ningún REQ en curso** —`instrumento`, `AGENTS.md` §6—, y esta vez el argumento estándar
  se sostiene sin esfuerzo: es un defecto del propio arnés, latente, que ningún REQ vivo introduce ni
  toca. **Pero es de las caras, no de las baratas.** *Forzador:* va con REQ-024 o antes, en **1.34.0**,
  y no después de él: la mitad (2) de SEC-047 y esto son la misma clase vista en dos lectores, y
  arreglar uno solo deja escrita la asimetría. *Vencimiento:* cierre de **1.34.0**. Si 1.34.0 cierra sin
  esto, sube a **`contrato`**, porque entonces REQ-009 CA-15/CA-16 estarían describiendo una conducta
  que el árbol no tiene.

---

### Rigor y estado de los REQ — R-013

**No subo ni bajo el rigor de ningún REQ, y no firmo ninguno.** Esta revisión no juzga un
requerimiento: mide el guardián publicado. Los REQ vivos siguen exactamente como estaban
(`REQ-021: con-hallazgos`, vuelta 1 pendiente; `REQ-023: borrador`), y sus líneas `QA:` y `Seguridad:`
no las he tocado.

**Deudas de write-back que esta revisión crea, y de quién son** (`AGENTS.md` §9 — un hallazgo que sólo
vive en este registro es deriva):

| Qué | Dueño | Dónde |
|---|---|---|
| El resultado de la medición, al Historial de REQ-023 (su pregunta abierta 2 queda **resuelta: confirmada**) | `analista-requerimientos` | `requirements/REQ-023.md` |
| SEC-050: CA-11 reescrito por propiedad, con el puntero real (dos funciones) y `Rigor:` incluido | `analista-requerimientos` | REQ-024 (y REQ-016 si hay que reabrirlo) |
| SEC-050: el alcance real de la fila del rigor de `AGENTS.md` §6/§13 | `analista-requerimientos` + gate humano (es `AGENTS.md`) | `AGENTS.md`, `templates/AGENTS.md.tpl` |
| SEC-050: corregir la remediación (2) de SEC-047 para que diga la propiedad y no dos campos | **`auditor-seguridad`** (mía) | este registro |
| SEC-051: los criterios por propiedad de la cola | `analista-requerimientos` | REQ-024 o REQ propio |
| SEC-051: el lector y los casos del banco | `desarrollador` | `hooks/lib.sh`, `31-cola-una-sola-regla.sh` |

**Lo que esta investigación acredita y lo que NO.** *Acredita:* que la hipótesis del analista es
**cierta y está ejecutada**, en la instalada **1.32.1** y en `cand/1.33.0`, con control positivo y
negativo en cada tanda; que la clase es la de §2 y su superficie son cuatro campos; que las dos
vulnerabilidades son **latentes** en toda la historia del repositorio; y que existe un segundo defecto
independiente en el lector de la cola. *No acredita:* ninguna quality gate (no las miro); ningún REQ;
ni que las **cinco versiones publicadas** anteriores a 1.32.1 se comporten igual — medí las dos que
gobiernan hoy, y la conducta que las explica (el perdón de la ausencia) es anterior a los niveles de
rigor, así que **es de esperar** que estén afectadas, pero *esperar* no es *medir* y aquí no lo he
medido.

---

## Revisión R-014 — **consulta de trazabilidad sobre SEC-047** (no es auditoría de ningún REQ; no firma nada) — 2026-09-08

**Qué se preguntó.** `requirements/REQ-023.md` me atribuye **dos veces** una cláusula de escalada que
la coordinadora no encuentra en este registro: que la mitad (1) de **SEC-047** sube a `contrato` si la
ventana **1.33.0** cierra sin ella (`requirements/REQ-023.md:451` y `:566`).

**Esto no firma nada, y hay que decirlo antes que el resultado.** No he tocado la línea `Seguridad:`
de ningún REQ —REQ-023 sigue `borrador` con `Seguridad: pendiente`, REQ-021 en su vuelta de QA—, ni
`AGENTS.md`, ni `PENDING_APPROVAL.md`, ni ningún archivo de `requirements/`. Lo único que escribo es
este registro, que es mío.

### 1. La cláusula NO existe en este registro, y nunca existió

**Método: barridos y historia, no recuerdo.**

1. **Único condicional de escalada de SEC-047 en este registro:** `docs/seguridad/registro-seguridad.md:3682-3685`
   — «*Forzador:* es el primer trabajo de 1.34.0 … *Vencimiento:* el cierre de 1.34.0. Si **1.34.0**
   cierra sin esto, vuelve a la mesa **subido a `contrato`**». Dice **1.34.0**, no 1.33.0.
2. **Nunca dijo otra cosa.** `git log --all -S` sobre esa frase devuelve **un solo** commit,
   `bbe3209` (R-012, 2026-09-07), y en **ese blob** la línea ya decía 1.34.0. No hay una versión
   anterior que REQ-023 pudiera estar citando de buena fe.
3. **Dónde nace la frase que me la atribuye:** `git log --all -S "SEC-047 sube a"` y
   `-S "el auditor dejó dicho"` devuelven, cada uno, **un único** commit: `721cb71` («REQ-023
   (borrador)», 2026-09-08, `analista-requerimientos`). La cláusula aparece por primera vez **en el
   documento que se beneficia de ella**, no en el mío.
4. **Ningún otro artefacto la contiene.** Barrido de `cierra sin|cerrara sin|cierre sin` en todos los
   `*.md` del árbol: las escaladas condicionales que existen son la de SEC-047 (**1.34.0**, línea
   3684), la de SEC-051 (**1.34.0**, línea 4143) y la del residual del bloque derivado (1.33.0, línea
   2614 — otro hallazgo). `SEC-047` fuera de `*.md`: **cero**. En mensajes de commit: los tres que ya
   se conocen (`bbe3209`, `721cb71`, `8333464`), ninguno con esa condición.
5. **Y REQ-023 se desmiente a sí mismo 20 líneas antes:** `requirements/REQ-023.md:431` — «*el
   vencimiento que SEC-047 se fijó a sí mismo es el cierre de **1.34.0***». Ésa es la lectura correcta
   de este registro; la de `:451` y `:566` no.

**Veredicto: el tercero de los tres resultados posibles. No emití esa cláusula** — ni en R-012, donde
nació SEC-047, ni en R-013, que es la única revisión posterior que lo toca y que se limitó a subir el
forzador de su **mitad (2)** dejando dicho, literal, que «*sigue `abierto`, sigue `instrumento` …
sigue severidad crítica*» (línea 3993). No hay hueco en el barrido de la coordinadora: no hay nada que
encontrar.

**Y la estructura importa tanto como el hecho.** Una condición de escalada que sólo vive en el
documento cuyo aplazamiento castiga **no es un forzador: es un argumento con la firma de otro**. Es la
misma forma que este registro ya lleva nombrada dos veces —quien escribe el instrumento diseña el
control que sabe pasar (SEC-045)—, aquí aplicada al calendario en vez de a la prueba. No le atribuyo
intención al analista: la frase parece la contracción de un hecho real (**el propietario metió REQ-023
en 1.33.0**, `CHANGELOG.md:816`) con una consecuencia que nadie declaró (que salirse de 1.33.0 cambie
la clase). Pero una contracción así, dentro de un contrato, se convierte en cita **firmada** en la
ventana siguiente.

### 2. Forzador y vencimiento REALES de la mitad (1) de SEC-047, tal como los sostengo hoy

| Qué | Valor vigente | Dónde está escrito |
|---|---|---|
| Clase | **`instrumento`** (defecto de un guardián del propio arnés, `AGENTS.md` §6) | líneas 3633 y 3993 |
| Severidad | **crítica** (no es lo mismo que bloqueante: la clase decide el bloqueo, la severidad no) | 3633, 3993 |
| Estado | **abierto** | 3993 |
| Dueños | `analista-requerimientos` (el criterio) y `desarrollador` (la guarda) | 3633 |
| **Forzador** | **el primer trabajo de 1.34.0, por delante del núcleo por estado** | 3683-3684 |
| **Vencimiento** | **el cierre de 1.34.0** | 3684 |
| **Escalada** | sube a `contrato` **si 1.34.0 cierra sin ella** — y por eso: entonces `AGENTS.md` §13 describiría una guarda que el árbol no tiene en la extensión que promete | 3684-3685 |

**Que REQ-023 esté en 1.33.0 es una decisión del propietario del 2026-09-08** (`CHANGELOG.md:816`,
`docs/PLAN.md:94-99`, `docs/ESTADO.md:12-16`), tomada **adelantando** el trabajo respecto a mi
vencimiento. Adelantar por decisión de quien manda no crea un vencimiento nuevo, y desandar el
adelanto no incumple ninguno.

### 3. La pregunta operativa: si REQ-023 se aplaza a 1.34.0, ¿cambia la clase, bloquea 1.33.0, o nada?

**Respuesta a la clase, que es lo que `guard-completado` mira: sigue `instrumento`. Aplazar no la
cambia.** Y desgloso los tres sentidos de «bloquear», porque se confunden y sólo uno lo mide la
máquina:

- **(a) Puerta de cierre de un REQ (máquina): no bloquea nada, ni hoy ni si se aplaza.**
  `hooks/guard-completado.sh:486-527` lee **el campo `Hallazgos abiertos:` del REQ que se está
  cerrando**, no un barrido del proyecto. SEC-047 está declarado en **un solo** campo de cabecera de
  todo el árbol —`requirements/REQ-017.md:9`, como `instrumento`— y REQ-017 ya está `completado`. Aun
  si SEC-047 fuera `contrato` mañana, no habría ninguna transición que denegar en 1.33.0: sólo
  impediría **volver a cerrar** REQ-017 si algo lo reabriera. Por eso la frase de `REQ-023:451` —«un
  hallazgo `contrato` abierto **bloquea el cierre de la ventana**»— dice también algo falso **sobre lo
  construido**: la puerta bloquea el cierre de **un REQ que lo declara**, no de una ventana.
- **(b) Publicación delegada (gobernanza, no máquina): la decisión ya no es automática, y no por
  SEC-047.** `docs/gobernanza/autoalojamiento.md:148-155` exige, para que la coordinadora fusione,
  etiquete y publique sin preguntar, que los hallazgos abiertos sean «*sólo de clase `instrumento`,
  con dueño*». Con SEC-047 en `instrumento` eso se cumple. Lo que **no** se cumple es otra cosa que
  nace de R-013 y es independiente de REQ-023: **SEC-050 está abierto y es `contrato`**. Aplico la
  lectura acotada a la ventana (si el criterio se leyera global, la delegación estaría muerta desde
  hace dos ventanas por SEC-014/SEC-020/SEC-033/SEC-038…045), y con esa lectura SEC-050 —hallazgo
  sobre REQ-016, publicado en 1.32.1, enrutado a 1.34.0— **no es de esta ventana**; lo dejo dicho
  porque la frontera de ese criterio no está escrita y la decisión de publicar es del propietario,
  no mía.
- **(c) Lo que 1.33.0 publica: aplazar REQ-023 no empeora la promesa publicada, y está medido.**
  El argumento de subir la clase por «publicar una promesa falsa una ventana más» supone que cerrar
  REQ-023 la haría verdadera. **R-013 §2 mide que no** (línea 3890): «*cerrar la vía del carácter
  (REQ-023) no cierra la clase, porque el comentario y el borrado siguen abiertos*». Las filas de
  `AGENTS.md` §6/§13 que hoy son falsas siguen siéndolo con REQ-023 dentro —eso es SEC-050, `contrato`,
  1.34.0— y son falsas **desde `v1.30.3`**, en cinco versiones publicadas, de forma **latente** (ningún
  REQ de toda la historia llevó jamás un carácter invisible en cabecera: líneas 3626-3629). Y en la
  dirección contraria: si REQ-023 se aplaza, la fila del CR de `AGENTS.md` §13 **no** se reescribe
  (CA-10 es suya) y sigue nombrando el CR, que es exactamente lo que el árbol tiene. Aplazar deja §13
  **igual de honesta**, no menos.

**Lo que sí cambiaría si se aplaza, y no es de clase sino de concentración:** 1.34.0 quedaría con
SEC-047 (1) y (2), las tres remediaciones de SEC-050, SEC-051, SEC-045 y SEC-048 **todos con
vencimiento en su cierre**. Eso no bloquea nada hoy y no lo convierto en veto; lo pongo por escrito
porque una ventana con siete vencimientos simultáneos es la forma en que un vencimiento deja de
significar algo, y quien decide es el propietario.

**Efecto colateral en la letra de REQ-023 que el analista tiene que rehacer, no sólo borrar.** El
argumento **3** de «por qué SEC-051 no entra aquí» (`REQ-023:564-569`) se apoya en que los dos
vencimientos son de ventanas distintas. Con los reales —**1.34.0 los dos**— ese argumento no tiene
fuerza: no hay vencimiento holgado que importar dentro de uno que no puede resbalar. Los otros dos
(son tres cosas de naturaleza distinta; el coste marginal no es de dos líneas) se sostienen solos y
bastan. Quien haga el write-back debe **rederivar o retirar** el 3, no sustituir «1.33.0» por
«1.34.0», que lo dejaría diciendo lo contrario de lo que argumenta.

### 4. La cláusula de escalada, reescrita por PROPIEDAD (enmienda a R-012, y la bitácora no se edita hacia atrás)

Mi cláusula de R-012 está atada a **una fecha**, y una escalada atada a una sola fecha es una
enumeración con los mismos años que cualquier otra: envejece hacia el lado que abre en cuanto pasa
algo que no es el calendario. La reescribo por propiedad. **Ésta es la vigente**; la de la línea 3684
queda superada por ella y **no la reescribo en su sitio**, porque esta bitácora no se edita hacia
atrás (misma práctica que R-013 §6).

> **La mitad (1) de SEC-047 sube a `contrato` cuando ocurra cualquiera de estas tres, y la primera que
> ocurra manda** (formas **no exhaustivas** de las dos últimas; la propiedad es la que decide, no la
> lista):
> 1. **1.34.0 cierra sin ella** (la de R-012, intacta).
> 2. **Deja de ser latente:** se mide un carácter no representable en la cabecera de cualquier REQ de
>    cualquier árbol o de la historia, o un cierre que pasó por esa vía. Entonces no es deuda de
>    instrumento: es un cierre contaminado.
> 3. **Un texto firmado empieza a prometer la PROPIEDAD y no el carácter** mientras el código siga
>    guardando sólo el CR —en `AGENTS.md` §6/§13, en `templates/AGENTS.md.tpl`, en la skill de
>    migración o en un criterio de aceptación cerrado—. Es la razón que ya daba la cláusula de R-012,
>    liberada de la fecha: lo que la dispara es **la promesa**, no el almanaque.
>
> **Y lo que NO la sube, dicho para que no vuelva a inventarse:** en qué ventana decida el propietario
> hacer el trabajo. Adelantar el arreglo no crea vencimiento y desandar el adelanto no incumple
> ninguno.

### SEC-052 — `contrato` · **abierto** · severidad **media** · dueño `analista-requerimientos`

**REQ-023 cita, dos veces y como hecho externo, una cláusula de escalada que el auditor nunca emitió — y la consecuencia de máquina que le atribuye tampoco existe**

- **Ubicación:** `requirements/REQ-023.md:450-452` («*Si **1.33.0 cerrara sin él**, el auditor dejó
  dicho que **SEC-047 sube a `contrato`** … y un hallazgo `contrato` abierto **bloquea el cierre** de
  la ventana*») y `:566` («*La mitad (1) de `SEC-047` escala a `contrato` si cierra **1.33.0** sin
  ella*»).
- **Qué es falso, y son dos cosas distintas.** *(i)* La **atribución**: la cláusula no existe en este
  registro ni existió nunca (§1 de esta revisión, con la historia). *(ii)* La **consecuencia de
  máquina**: `guard-completado` no bloquea «el cierre de una ventana»; bloquea la transición de **un
  REQ cuyo propio campo `Hallazgos abiertos:` declara** el hallazgo (`hooks/guard-completado.sh:486-527`),
  y SEC-047 sólo está declarado en la cabecera de REQ-017, ya `completado`. Por *(ii)* la clase es
  `contrato` y no `instrumento`: el REQ dice algo falso **sobre lo construido**
  (`requirements/README.md:116`), igual que SEC-050, cuyo defecto es también de **alcance de la
  descripción** y no de conducta.
- **Riesgo, y no es el error en sí.** Es que la frase **fabrica un forzador**. Si REQ-023 cerrara
  llevándola, la atribución quedaría **firmada** y la ventana siguiente la leería como una decisión de
  seguridad; cualquier discusión sobre aplazar el REQ tendría enfrente un bloqueo inventado con la
  firma del auditor, que es precisamente la asimetría que ningún documento debería poder darse a sí
  mismo. Y en la dirección contraria es igual de caro: quien descubra que la cláusula no existe puede
  concluir que **ninguna** de las condiciones de este registro es fiable.
- **Remediación (write-back, `analista-requerimientos`).**
  1. **Retirar la atribución** en `:450-452` y `:566`. El forzador y el vencimiento reales son los de
     la tabla de §2, y la cláusula vigente es la de §4 de esta revisión; si REQ-023 quiere citarla,
     que cite **este registro con su línea**, no un recuerdo.
  2. **Corregir la consecuencia de máquina** allí donde se afirme: un hallazgo `contrato` bloquea el
     cierre del **REQ que lo declara en su cabecera**; lo que devuelve al propietario la publicación de
     una ventana es el criterio de `docs/gobernanza/autoalojamiento.md:148-155`, que es **gobernanza y
     no puerta**.
  3. **Rederivar o retirar el argumento 3** de «por qué SEC-051 no entra aquí» (motivo en §3 de esta
     revisión). Sustituir la fecha sin tocar el argumento lo deja diciendo lo contrario.
  4. **Y una regla de redacción que sale de aquí, para el README de requerimientos si el analista la
     ve general:** un REQ no declara la clase, el forzador ni el vencimiento de un hallazgo de
     seguridad; los **cita** con archivo y línea. Un contrato que reescribe de memoria la condición que
     lo obliga acaba escribiéndose la que le conviene, y nadie lo nota porque suena a cita.
- **Efecto en el cierre.** `contrato`, así que **bloquea el cierre de REQ-023** hasta el write-back
  (`requirements/README.md:116`) — y sólo el de REQ-023: no toca REQ-017 ni REQ-021, no toca ninguna
  quality gate y no es motivo de veto de la ventana. *Forzador:* **no firmo `Seguridad:` de REQ-023
  mientras la atribución esté en el documento**; es la aplicación literal de `AGENTS.md` §9 con los
  papeles invertidos —aquí no falta el write-back de un hallazgo, sobra una cláusula que nadie emitió—.
  *Vencimiento:* **antes del cierre de REQ-023, en la ventana en que ocurra**; si REQ-023 se aplaza, el
  hallazgo se aplaza con él, porque su daño se materializa al firmar. *Coste:* dos frases y un
  párrafo rederivado.
- **No reabro nada.** REQ-023 está en `borrador` y ningún REQ `completado` cita la cláusula: barrido de
  `SEC-047` en todos los `*.md` (§1, punto 4). No hay cierre contaminado.

### 5. Deuda propia que esta revisión descarga: la remediación (2) de SEC-047, dicha por propiedad

R-013 dejó anotada como **mía** la corrección de mi propia remediación (2), que estaba escrita **por
enumeración de dos campos** cuando la superficie medida son cuatro (tabla de líneas 3893-3902). La
escribo aquí por propiedad, y con esto esa fila de la tabla de deudas de R-013 queda **descargada**:

> **Remediación (2) de SEC-047, vigente.** *Ningún campo de cabecera cuya **ausencia** el lector
> resuelva del lado que **abre** puede seguir resolviéndose así: la puerta debe distinguir «declarado
> vacío» de «no declarado», y ante «no declarado» no permitir —la misma doctrina que ya rige el rango
> de cita (`hooks/lib.sh:1571-1575`)*. **Qué campos tienen hoy esa propiedad se DERIVA del lector, no
> se lista en el criterio**, y la lista exhaustiva vive en **un solo sitio**, que hoy son **dos
> funciones y hay que decirlo así**: `hooks/guard-completado.sh` (`QA:`, `Hallazgos abiertos:`) y
> `hooks/lib.sh` (`arnes_sens_efectiva`, `arnes_rigor_efectivo`: `Sensible a seguridad:` y `Rigor:`) —
> unificarlas es parte de la remediación de SEC-050. Ejemplos **no exhaustivos** de la superficie
> medida el 2026-09-08: `Sensible a seguridad:`, `QA:`, `Hallazgos abiertos:`, `Rigor:`.

### Rigor y estado de los REQ — R-014

**No subo ni bajo el rigor de ningún REQ, y no firmo ninguno.** REQ-023 ya es `Rigor: critico` con
`Sensible a seguridad: sí`, que es su suelo; no hay nada que subir y nada se baja. No hay líneas
`QA:` ni `Seguridad:` tocadas por esta revisión, y **ningún estado de seguridad aprobado cambia**: la
línea base de no-regresión sigue siendo la de R-012 para REQ-017 y la de R-009/R-008 para lo anterior.

**Lo que esta revisión acredita y lo que NO.** *Acredita:* que la cláusula de escalada atribuida al
auditor no existe en este registro y nunca existió, medido por barrido del árbol y por historia de
git; que el forzador y el vencimiento vigentes de la mitad (1) de SEC-047 son los de la tabla de §2; y
que la clase de SEC-047 **no** depende de en qué ventana se haga el trabajo. *No acredita:* ninguna
quality gate (no las miro); ningún REQ, en particular **ni REQ-023 ni REQ-021**; ni el código de
1.33.0, que se auditará en su turno, después de QA.
