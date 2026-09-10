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

---

## Revisión R-015 — verificación del write-back de **SEC-052** y **consecuencias de gobernanza de publicar 1.33.0** (no es auditoría de ningún REQ; no firma nada) — 2026-09-08

**Qué es y qué no, antes que el resultado.** Verifico **leyendo el árbol** el write-back que el
`analista-requerimientos` reporta sobre SEC-052 (`requirements/REQ-023.md`, comiteado en `36a70ed`), y
registro dos consecuencias que hoy viven sólo en el cuerpo de una revisión o en `docs/ESTADO.md`.
**No firmo nada:** no toco la línea `Seguridad:` de ningún REQ —REQ-023 sigue `borrador` con
`Seguridad: pendiente`; REQ-021 está `bloqueado` con `QA: con-hallazgos` y su
`Seguridad: preventiva (R-010)`, que **no cubre el código posterior**—, y **no audito REQ-021**: no me
corresponde hasta que QA apruebe (`AGENTS.md` §6). Lo único que escribo es este registro. Árbol:
`cand/1.33.0` @ `6e98a9c`, con `PENDING_APPROVAL.md`, `docs/ESTADO.md` y `requirements/REQ-021.md`
modificados sin comitear por otras comisiones vivas; **el mecanismo y el banco están limpios**
(`git status` sobre `hooks/ tools/ .github/ .arnes/ tests/`: vacío).

### 1. SEC-052 — verificado punto por punto contra el árbol, y **CIERRA**

**Método: leer el árbol y resolver cada cita, no la palabra de nadie.** Los cuatro puntos de la
remediación, con su sede y su veredicto:

| Remediación (R-014) | Dónde está hoy | Veredicto |
|---|---|---|
| **1.** Retirar la atribución en `:450-452` y `:566`; si el REQ quiere la cláusula, que **cite** este registro con su línea | Barrido del documento: `auditor dejó dicho`, `1.33.0 cerrara sin`, `bloquea el cierre de la ventana` y `escala a contrato si cierra 1.33.0` → **cero** ocurrencias en el cuerpo. La cláusula pasa a citarse en `requirements/REQ-023.md:625-634` contra `docs/seguridad/registro-seguridad.md:4303-4317`, y el forzador/vencimiento contra `:4229-4239` | **cumple** |
| **2.** Corregir la consecuencia de máquina: un `contrato` bloquea el **REQ que lo declara**, no «una ventana»; lo que devuelve la publicación al propietario es **gobernanza** | `requirements/REQ-023.md:636-640`, con `hooks/guard-completado.sh:486-527` para la puerta y `docs/gobernanza/autoalojamiento.md:148-155` para la gobernanza. **Las dos citas resuelven:** en `guard-completado.sh` el bloque que empieza en `hall="$ARNES_HALL"` lee el campo del REQ que se cierra y deniega en `usuario/dinero|contrato`; en `autoalojamiento.md` está el criterio de delegación | **cumple** |
| **3.** **Rederivar** el argumento 3 de «por qué SEC-051 no entra aquí», no sustituir la fecha | `requirements/REQ-023.md:820-833`. El párrafo **retira por escrito** el argumento de calendario («*los vencimientos reales… son el cierre de 1.34.0 los dos*», con `:4238` y `:4143`) y lo sustituye por un **hecho del árbol**: la remediación de SEC-051 ya está contratada en REQ-024 CA-08/CA-09 con su ADR, así que absorberla aquí escribiría **dos** contratos sobre la misma conducta | **cumple, y es el punto que más me importaba** |
| **4.** Regla de redacción —un REQ **cita** clase, forzador y vencimiento; no los declara— aplicada al documento, y subida al README **si el analista la ve general** | Aplicada: las citas a `SEC-020` (`:704`→`:1305`), `SEC-024` (`:848`→`:2570`), `SEC-048` (`:251`→`:3689`), `SEC-050` (`:653`/`:677`→`:4014`) y `SEC-051` (`:796`→`:4139-4145`) resuelven **todas** al ancla que nombran. La propuesta general para `requirements/README.md` queda declarada con dueño en `requirements/REQ-023.md:878` | **cumple** (la propuesta queda como deuda declarada, abajo) |

**Comprobado también que el rastro del error no se borró donde debe quedarse.** El texto retirado
sobrevive **sólo** en la fila del Historial que documenta el cambio
(`requirements/REQ-023.md:969`, con antes → después y la causa enlazada a SEC-052). Es lo correcto: un
write-back que borra la huella del defecto impide auditar la siguiente reaparición de la clase. Misma
práctica que este registro, que no se edita hacia atrás.

### SEC-052 — Estado: `abierto` → **`mitigado`**. La atribución se retiró, y la cláusula se cita con su línea

**El forzador que declaré era literal —«no firmo `Seguridad:` de REQ-023 mientras la atribución esté en
el documento»— y ya no se cumple su antecedente: la atribución no está.** Las tres remediaciones
vinculantes están hechas y verificadas leyendo, no aceptando el reporte. **Retirar `SEC-052` del campo
`Hallazgos abiertos:` de REQ-023 queda autorizado**; el write-back lo enruta la coordinadora, no yo, y
por el mismo motivo por el que el analista no se lo retiró a sí mismo: quien se beneficia de cerrar un
hallazgo no lo cierra.

**Lo que este cierre acredita y lo que no.** *Acredita:* que las dos frases falsas —la atribución y la
consecuencia de máquina— salieron del contrato, y que el argumento 3 fue rederivado sobre un hecho del
árbol en vez de sobre una fecha corregida. *No acredita:* nada sobre los criterios de REQ-023 como
contrato (eso es la auditoría de REQ-023, que no ha ocurrido y que irá **después** de QA), ni sobre el
código que aún no existe.

**Una observación declarada que NO abre hallazgo, y por qué no.** La cita de
`requirements/REQ-023.md:628-632` reproduce las tres condiciones de mi cláusula pero **omite el
calificador de la fuente**: en `:4303-4305` las dos últimas son «formas **no exhaustivas** … la
propiedad es la que decide, no la lista», y el resumen del REQ se lee como una lista de tres cerrada.
Es la forma **(a)** en pequeño, y envejece hacia el lado que abre. No abre hallazgo porque *(i)* la cita
con archivo y rango está **al lado** y este registro es el sitio único, *(ii)* vive en prosa de
«Notas / alcance» y **ningún criterio de aceptación ni ninguna puerta** se apoya en ella, y *(iii)*
corregirlo son dos palabras. **Qué lo convertiría en hallazgo:** que esa paráfrasis pase a un criterio
de aceptación, o que se cite sin el rango. Se corrige cuando el documento se toque por cualquier otra
causa.

**Deuda declarada que este cierre NO lleva consigo, con dueño y vencimiento.** La remediación 4 tenía
dos mitades: aplicar la regla al documento (**hecha**) y **subirla a doctrina** si es general. El
analista la ve general y la propone en `requirements/REQ-023.md:878`, pero no puede escribirla desde su
comisión. Queda así, y no retiene SEC-052 porque mi remediación 4 era condicional y de alcance
**general**, no del sujeto del hallazgo:

> **Deuda R-015-01 — la regla de redacción no está en doctrina.** *Qué falta:* en
> `requirements/README.md` § «Cómo se escribe un criterio que no se desmiente», la regla *un REQ **cita**
> la clase, el forzador y el vencimiento de un hallazgo con archivo y línea; no los **declara***.
> *Dueño:* `analista-requerimientos` (redacción), coordinadora (enrutado). *Forzador:* mientras no esté,
> la única defensa contra la clase es que el auditor trace la frase a mano, y eso costó una revisión
> entera. *Vencimiento:* **antes de que REQ-023 salga de `borrador`** —ése es el momento en que su texto
> pasa a ser contrato entregado a desarrollo—. *Clase si venciera:* `instrumento` (doctrina del arnés,
> sin efecto en el producto).

### 2. SEC-053 — la frontera del criterio de publicación delegada **no está escrita**, y ya se publicaron versiones bajo él

### SEC-053 — `contrato` · **abierto** · severidad **alta** · dueño **propietario** (la decisión y su firma)

**El criterio que autoriza a la coordinadora a fusionar, etiquetar y publicar sin preguntar habla de
«cualquier hallazgo abierto de clase `usuario/dinero` o `contrato`» y no dice ABIERTO DÓNDE — y bajo esa
ambigüedad ya se publicó**

- **Ubicación:** `docs/gobernanza/autoalojamiento.md:148-155` — «*…`QA: aprobado` y `Seguridad:
  aprobado` (o hallazgos abiertos sólo de clase `instrumento`, con dueño)… **Cualquier** `FAIL`, un
  `SKIP` sin explicar, **un hallazgo abierto de clase `usuario/dinero` o `contrato`**, o un veto del
  auditor devuelve la decisión al propietario*».
- **El defecto no es la ambigüedad en abstracto: es que el texto no permite decidir si se cumplió.** Y
  se mide sobre lo publicado, no se argumenta:

  | Tag | Fecha | `contrato` abierto en el registro **de ese tag** | Cómo se decidió publicar |
  |---|---|---|---|
  | `v1.32.0` (`ca6047a`) | 2026-09-07 | **sí** — `git show v1.32.0:docs/seguridad/registro-seguridad.md` trae `### SEC-020 — contrato · abierto` en su línea 1305 | `CHANGELOG.md:2688` deja constancia de **aprobación expresa del propietario** («*el propietario aprobó publicar el 2026-09-07*») y nombra a `SEC-020` como lo que cruza. Conforme bajo **cualquier** lectura: la decisión la tomó el propietario |
  | `v1.32.1` (`973448f`) | 2026-09-07 | **sí** — mismo blob, `SEC-020` sigue `contrato` · `abierto` | Entrada de cierre `CHANGELOG.md:2343-2350`, **agente: coordinadora**, sin entrada en la cola: `git log -- PENDING_APPROVAL.md` no registra nada entre `ca6047a` (v1.32.0) y ese cierre. Y la propia entrada **nombra `SEC-020`** entre lo que cruza a 1.33.0 |

  De donde sale el hecho incómodo: **`v1.32.1` se publicó con un hallazgo `contrato` abierto, nombrado en
  la misma entrada que anuncia la publicación, y sin que el criterio devolviera la decisión al
  propietario.** Es conforme bajo la lectura estrecha e **incumplimiento bajo la literal**. El texto, tal
  como está, no dice cuál rige.
- **Y son TRES lecturas, no dos — la que se aplicó en la práctica es la tercera, y no está escrita en
  ninguna parte.** *(a)* **Global**: cualquier `contrato` abierto del registro. Hoy hay **17**
  (`SEC-020`, `SEC-031`…`036`, `SEC-038`…`045`, `SEC-050`, `SEC-052`), así que la delegación llevaría
  muerta desde que se firmó y `v1.32.1` se habría publicado fuera de ella. *(b)* **Por ventana**: los
  hallazgos de la ventana que se publica. `SEC-020` **es** de la ventana 1.32.0 (nació en R-004 sobre
  REQ-013, que cruzó sin cerrar), así que ni esta lectura salva a `v1.32.0`. *(c)* **Por los REQ que la
  ventana CIERRA**: `SEC-020` cuelga de REQ-013, que no cerró, luego no cuenta. **Sólo la (c) hace
  conformes las dos publicaciones**, y la (c) no aparece en ningún documento del árbol: se dedujo de la
  práctica.
- **Riesgo, y no es el error de redacción.** Es **quién elige la lectura**. Sin frontera escrita, la
  escoge, en el momento de publicar, la parte que quiere publicar — y siempre habrá una lectura que
  concede el permiso. Es exactamente la forma que este registro ya lleva nombrada tres veces —*quien
  escribe el instrumento diseña el control que sabe pasar* (SEC-045), *una condición de escalada que
  sólo vive en el documento cuyo aplazamiento castiga es un argumento con la firma de otro* (SEC-052)—
  aquí aplicada al **permiso para publicar el mecanismo que gobierna a los demás proyectos**. Y el
  segundo riesgo es de precedente: cada publicación sin frontera escrita **crea práctica**, y la
  práctica sustituye en silencio al criterio firmado.
- **Por qué `contrato` y qué NO significa eso.** Es la clase de `SEC-050`: un **texto firmado describe
  un control con un alcance que no tiene** —bajo la lectura estrecha el criterio *promete más de lo que
  se aplica*, y bajo la literal *ya se incumplió*—, no una conducta defectuosa de la máquina. **Efecto de
  máquina: ninguno**, y lo digo aplicándome la distinción que SEC-052 me obligó a escribir:
  `guard-completado` sólo lee el campo `Hallazgos abiertos:` **del REQ que se cierra**
  (`hooks/guard-completado.sh:486-527`), y este hallazgo no cuelga de ningún REQ. **No es un veto** y no
  bloquea ninguna quality gate.
- **Y aquí está la prueba de que el criterio no se puede aplicar como está: no sé decir si ESTE hallazgo
  cuenta.** Bajo la lectura *(a)* cuenta y devuelve el tag de 1.33.0 al propietario; bajo *(b)* y *(c)*
  no cuenta, porque no cuelga de ningún REQ de la ventana. **Un criterio bajo el que un hallazgo no
  puede clasificarse como dentro o fuera es un criterio que no se puede medir**, y el principio rector
  de este proyecto ya dice qué hacer entonces: *una puerta que no puede medir no deja pasar*. Aplicado a
  la delegación, eso significa —y es lectura mía, no decisión— que **mientras la frontera no esté
  escrita, la coordinadora no puede acreditar que la delegación la cubre, así que la decisión es del
  propietario por defecto**. Es lo que la coordinadora ya hizo al parar (`docs/ESTADO.md`, «Bloqueos»),
  y esta entrada existe para que eso deje de depender de su prudencia.
- **NO lo resuelvo: es del propietario, y lo digo por escrito para no fabricar un forzador.** Ninguna de
  las dos salidas es mía:
  1. **Si la lectura correcta es la global**, entonces hay **publicaciones pasadas fuera de delegación**
     —`v1.32.1` medida arriba— y eso hay que **decirlo y ratificarlo a posteriori**, no descubrirlo en
     una auditoría futura. Y la delegación queda inoperante hasta que bajen los 17 `contrato`, lo que
     equivale a retirarla de hecho.
  2. **Si la correcta es la de ventana (o la de los REQ que cierran)**, entonces el texto **promete más
     de lo que se aplica** y se reescribe para decir lo que se hace, con la palabra «cualquier»
     acotada. Ésa es la clase de `SEC-050`, y el arreglo es el mismo: enunciar el alcance por
     **propiedad** —«hallazgo abierto **de los REQ que esta publicación cierra**», o la que el
     propietario decida— y citar el **sitio único** donde se cuenta.
- **Dueño:** **propietario** (la delegación es suya y su cambio lleva su firma: `AGENTS.md` §6 y
  `docs/gobernanza/autoalojamiento.md`). *Redacción y write-back:* coordinadora, o
  `analista-requerimientos` si la decisión pasa a ser un NFR.
- **Forzador:** *la primera publicación en la que se pretenda ejercer la delegación* —hoy, el tag
  `v1.33.0`—. Enunciado por propiedad y no por fecha a propósito: no lo dispara el calendario, lo
  dispara que alguien vaya a apoyarse en el criterio.
- **Vencimiento:** **antes de ese tag**. Es el primer momento en que la respuesta cambia lo que alguien
  está autorizado a hacer; después del tag la respuesta ya no es una decisión, es una justificación.
- **Escalada:** si se publica **por delegación** con la frontera sin escribir, este hallazgo **no sube de
  clase** —ya es la que bloquea— sino que **cambia de naturaleza**: deja de ser deuda de redacción y esa
  publicación se anota aquí como **de autoridad no acreditada**, con petición de **ratificación expresa**
  del propietario a posteriori. Un permiso que se ejerce sin poder demostrar que existía no se arregla
  hacia atrás; sólo se puede reconocer.
- **No reabro nada.** `v1.32.0` y `v1.32.1` están publicadas y no propongo revertir ni retirar nada: lo
  que pido es que la frontera se escriba y que, si la lectura global es la correcta, la publicación de
  `v1.32.1` quede **ratificada por escrito**. Ningún REQ `completado` depende de este criterio, que es de
  gobernanza y no de contrato de REQ.

### 3. SEC-054 — 1.33.0 publicaría una **acreditación firmada** que la medición desmiente, y **todo el delta de código sin firma de seguridad es de un REQ `bloqueado`**

**Primero la mitad buena, porque es la que decide que esto no sea un veto: el mecanismo que 1.33.0
publica es exactamente el que audité.** Medido por objeto de árbol, no por diff leído:

| Qué | Árbol firmado en R-012 (`b6e581b`) | `HEAD` (`6e98a9c`) | Veredicto |
|---|---|---|---|
| `hooks/` | `88c146536f21fa03d3c8fdad8063b645fb0162bc` | **el mismo objeto** | idéntico byte a byte |
| `hooks/ tools/ .github/ .arnes/` | — | `git diff --name-only b6e581b HEAD --` sobre las cuatro rutas: **vacío** | sin cambios |

Es decir: **no hay regresión de seguridad en la capa de enforcement** entre mi firma de REQ-017 y lo que
esta ventana publicaría, y la línea base de no-regresión de R-012 sigue vigente **sin re-auditar**.

**Y la mitad que hay que registrar. Lo único que cambió desde mi firma es el código de REQ-021**
(`git log b6e581b..HEAD -- tests/`: `1e3424f`, `87d2609`, `7180739`, `2ce7804`), es decir
`tests/util/sonda-reloj.sh`, `tests/util/sonda-procesos.sh`, `tests/util/README.md`,
`tests/escenarios/hooks/run.sh`, las dos secciones 37 y la 38 — **más `docs/decisions/ADR-005`**. REQ-021
está `bloqueado`, va a 1.34.0 por decisión del propietario, su código **se queda**, y su
`Seguridad: preventiva (R-010)` dice de sí misma que **no cubre el código posterior**. Nada de esto es
irregular por sí solo; lo que sí hay que declarar es lo que se publica con él.

### SEC-054 — `contrato` · **abierto** · severidad **alta** · dueño `desarrollador` y `analista-requerimientos` (los dos textos), coordinadora (la publicación)

**Un ADR `aceptada` y el README del instrumento afirman, en el árbol que se etiquetaría como `v1.33.0`,
que «cada corrida acredita que el instrumento responde al sujeto» — y QA midió que no**

- **Ubicación de la afirmación, en los tres sitios que se publican:**
  1. `docs/decisions/ADR-005-instrumentos-compartidos-en-tests-util.md:42` — «***4. Cada corrida acredita
     que el instrumento responde al sujeto: la calibración.***», en un ADR cuya cabecera dice
     `Estado: aceptada` (`:3`) y `REQ: REQ-021 · Versión: 1.33.0` (`:4`).
  2. `tests/util/README.md:50` — «*La calibración: cada corrida acredita que el instrumento responde al
     sujeto*», en el README del propio instrumento.
  3. `tests/escenarios/hooks/secciones/38-sondas-compartidas.sh` — la sección que **publica PASS** sobre
     esa acreditación en la puerta requerida de `main`.
- **Qué la desmiente, medido por QA y no por lectura mía:** `docs/qa/1.33.0.md:2448-2454` — «*la
  acreditación del propio banco certifica UNA aritmética, no la propiedad*»: el `STUB38` del fail-before
  es exactamente la única aritmética que falla, y **cuatro** mutaciones tautológicas pasan al juez real,
  **tres sin leer el sujeto**, porque el testigo es predecible por construcción en toda máquina
  (`SP_RESOLUCION=1`, `SP_CAL_MARGEN=4`, `SONDA_DISC_PROC_VECES=2` son literales, así que
  `testigo = parámetro / 2`; en el reloj la ventana de 625× hace que el discordante **no pueda** fallar).
  Estado del REQ que lo contrata: `bloqueado`, con `QA-021-10` y `QA-021-11` **abiertos** y de clase
  `contrato` (`requirements/REQ-021.md`, cabecera).
- **Por qué es un hallazgo MÍO y no un duplicado de `QA-021-10`.** `QA-021-10` bloquea **el cierre de
  REQ-021**, y funciona: el REQ no cierra. Lo que ninguna puerta ni ningún hallazgo cubre es que el
  **texto firmado se publique igual**: un ADR con `Estado: aceptada` y `Versión: 1.33.0`, y el README del
  instrumento, salen en el tag afirmando la propiedad. `guard-completado` no mira ADRs ni READMEs.
- **Riesgo, y es el de siempre en este repositorio, una vuelta más.** *(i)* **Una acreditación publicada
  que no acredita es peor que ninguna, porque sustituye a la pregunta**: `requirements/REQ-023.md` ya
  escribe sus criterios de coste apoyados en «*instrumentos en `tests/util/` cuando REQ-021 suelte*»
  (CA-09), así que la ventana siguiente medirá con un instrumento cuyo verde certifica una aritmética.
  *(ii)* Es literalmente la condición **3** de mi propia cláusula de escalada de SEC-047
  (`:4310-4313`) en otra superficie: *un texto firmado empieza a prometer la propiedad mientras el
  código no la tiene*. *(iii)* El plugin se distribuye con `source: "./"`
  (`.claude-plugin/marketplace.json`), así que los proyectos consumidores reciben el ADR y el README —no
  sólo este repositorio.
- **Agravante que NO clasifico yo y que cito para que no se pierda:** `QA-021-06` (`instrumento`, dueño
  `desarrollador`) mide que la calibración del reloj queda fuera de banda **5 de 30** veces —2 en
  reposo— y que «*cada una pone en rojo la puerta requerida*»; la vuelta 3 añade `CA-03 (d)` fallando en
  **9 de 16** corridas bajo saturación. Publicar eso hace **no determinista la única puerta automática
  de `main`**, y la consecuencia humana está medida y escrita en este mismo proyecto: *la fricción
  termina con alguien apagando el guard* (`AGENTS.md` §13). Un rojo que aparece al azar deja de leerse
  como señal. La clase `instrumento` es correcta por `AGENTS.md` §6 —es una prueba del propio arnés— y
  **no la disputo**; lo que registro es que su **consecuencia de gobernanza** al publicarse no estaba
  anotada en ningún sitio.
- **Remediación, y es barata a propósito: no exige revertir código ni retener el tag.** Basta que los
  textos digan lo que el árbol tiene:
  1. **`ADR-005`**: no se reescribe hacia atrás (`AGENTS.md` §10: los ADR no se borran). Se le añade una
     **nota fechada** que declare que su punto 4 **no está acreditado** en el árbol que se publica,
     citando `QA-021-10` y `docs/qa/1.33.0.md:2448-2454`; o se supersede con un ADR nuevo si la decisión
     de fondo cambia. *Dueño:* `desarrollador` (es documentación técnica suya); gate humano por ser una
     decisión firmada.
  2. **`tests/util/README.md:50`**: que diga **qué certifica** la calibración (una aritmética, sobre una
     entrada) y **qué no** (que el instrumento distinga), citando la medición. El README del instrumento
     es donde lo lee quien lo vaya a usar.
  3. **Write-back (`AGENTS.md` §9), y sin él no cierro:** la propiedad —*un instrumento compartido no
     publica una acreditación que su propia mutación tautológica no desmienta*— tiene que quedar como
     **criterio de REQ-021** (donde `QA-021-10` ya la empuja) y, si se quiere que valga para todo
     instrumento futuro, como **NFR**. Mientras viva sólo aquí y en `docs/qa/`, es deriva.
- **Efecto en el cierre y en la publicación, dicho con la distinción de SEC-052 aplicada a mí mismo.**
  `contrato`, así que si se declara en la cabecera de REQ-021 **bloquea el cierre de REQ-021** —donde
  `QA-021-10` ya bloquea— y **de nada más**: no toca REQ-017 (`completado`, `Seguridad: aprobado (R-012)`,
  y su código es idéntico al que firmé), no toca ninguna quality gate, y **no es un veto de la ventana**.
  Si esta clase devuelve o no al propietario la publicación de 1.33.0 **no lo decide este hallazgo**: lo
  decide el criterio de `docs/gobernanza/autoalojamiento.md:148-155`, cuya frontera es `SEC-053` y cuya
  respuesta es del propietario. **Lo digo así porque lo contrario sería fabricar un forzador**, que es
  precisamente lo que SEC-052 castiga.
- **Forzador:** el tag `v1.33.0` — a partir de él la afirmación está **firmada y distribuida**, y
  desmentirla cuesta un ADR nuevo en vez de una nota. *Vencimiento:* **antes de ese tag** para los
  puntos 1 y 2 (dos párrafos); el punto 3 (write-back), **antes del cierre de REQ-021** en 1.34.0.
- **No reabro nada, y esto sí conviene decirlo.** REQ-017 (`completado`) **no se reabre**: `hooks/`,
  `tools/`, `.github/` y `.arnes/` son el mismo objeto de árbol que firmé en R-012, así que no hay
  regresión que perseguir. Lo que se publica sin firma de seguridad es el código de REQ-021, que **no
  está `completado`** y por tanto no necesitaba la mía; lo que faltaba era decir que su acreditación no
  lo está.

### 4. Clases ajenas que ratifico, para que no las fije en solitario quien se beneficia

Lo hago porque la lección de SEC-052 es exactamente ésta: cuando un documento declara la clase del
hallazgo que le conviene no bloquear, alguien de fuera tiene que mirarla.

- **La vía del **NUL** y del archivo en **UTF-16** que `requirements/REQ-023.md` declara en «Fuera de
  alcance» como `instrumento`, dueño `desarrollador`, ventana 1.35.0 — nace en ese documento y no en
  este registro. **Concurro con `instrumento`**, y con motivo, no por cortesía: es un defecto de un
  guardián del propio arnés (`AGENTS.md` §6), bash descarta los NUL antes de que ninguna guarda los vea,
  y el REQ **declara por escrito** que ningún criterio suyo promete cubrir esa vía —«*el silencio de esta
  guarda ante un NUL no acredita nada*»—, así que no hay promesa falsa y no hay `contrato`. **Qué la
  subiría a `contrato`:** que cualquier texto firmado —`AGENTS.md` §13, la plantilla, la skill de
  migración o un criterio cerrado— empiece a prometer cobertura de la clase «cabecera no medible» **sin
  acotar** esa vía. Es la misma condición 3 de `:4310-4313`, y queda anotada aquí para que la clase no
  dependa de que el REQ siga existiendo con esa sección.
- **`QA-021-06`** (reloj flaky que enrojece la puerta requerida): **concurro con `instrumento`**; su
  consecuencia de gobernanza al publicarse queda anotada arriba, en `SEC-054`.
- **`QA-021-10` y `QA-021-11`** (`contrato`, de QA): **no los toco**. Están bien clasificados y su sede
  es el bucle dev↔QA de REQ-021, que no es mío hasta que QA apruebe.

### Rigor y estado de los REQ — R-015

**No subo ni bajo el rigor de ningún REQ.** REQ-021 y REQ-023 ya son `Rigor: critico` con `Sensible a
seguridad: sí`, que es su suelo: no hay nada que subir y nada se baja. **No firmo ningún REQ**: ninguna
línea `QA:` ni `Seguridad:` se toca en esta revisión.

**Estado de seguridad aprobado — línea base de no-regresión, sin cambios y ahora medida por objeto de
árbol.** Para REQ-017 y para toda la capa de enforcement sigue vigente la de **R-012**, y queda anclada
así: `hooks/` = `88c146536f21fa03d3c8fdad8063b645fb0162bc`, con `tools/`, `.github/` y `.arnes/` sin
diferencias respecto a `b6e581b`. Cualquier auditoría futura que encuentre otro objeto en `hooks/` sin
una firma nueva entre medias está mirando una regresión. Para lo anterior, R-009/R-008.

**Lo que esta revisión acredita y lo que NO.** *Acredita:* que el write-back de SEC-052 está hecho en sus
cuatro puntos, verificado resolviendo cada cita contra el árbol; que la frontera del criterio de
publicación delegada no está escrita y que `v1.32.1` se publicó con un `contrato` abierto nombrado en su
propia entrada de CHANGELOG; y que el mecanismo que 1.33.0 publicaría es idéntico al que firmé en R-012.
*No acredita:* ninguna quality gate (no las miro); **ningún REQ** —en particular ni REQ-021 ni REQ-023—;
ni los criterios de REQ-023 como contrato; ni el código de REQ-021, que se auditará en su turno, después
de QA.

---

## Revisión R-016 — la frontera del criterio de publicación delegada, **escrita**; barrido de los 40 tags; e índice contable de hallazgos bloqueantes — 2026-09-08

**Qué es y qué no.** No es la auditoría de ningún REQ y **no firma nada**: ninguna línea `QA:` ni
`Seguridad:` se toca. Es la ejecución de la decisión que el propietario tomó el 2026-09-08 sobre
`SEC-053` —eligió la lectura **global**—, más la medición que esa decisión obliga a publicar. Alcance:
`docs/gobernanza/autoalojamiento.md` (la frontera) y este registro (el índice, el barrido y los estados).

**Por qué la escribe el auditor y no la coordinadora.** Redactar la regla que gobierna el permiso de
publicación **de la coordinadora**, siendo la coordinadora, es la forma de `SEC-052` —un forzador con la
firma de otro— y de `SEC-053` —elegir la lectura mientras se publica—. Lo escribe quien levantó el
hallazgo, que además es el único que no puede usar la frontera para publicar nada. Queda dicho también
**dentro** del documento gobernado, que es donde lo leerá quien lo use.

**Método, y es repetible por un tercero.** Todo se mide sobre objetos de git, no sobre la sesión:
`git show <tag>:docs/seguridad/registro-seguridad.md`; el campo `Hallazgos abiertos:` de cada
`requirements/REQ-*.md` **de ese tag**; `git log -- PENDING_APPROVAL.md`; y la entrada de `CHANGELOG.md`
que anuncia cada publicación, **citada por su encabezado y no por su línea**, porque el CHANGELOG crece
por arriba y una cita por línea envejece en la primera entrada nueva (es la enmienda que R-015 pagó al
citar `CHANGELOG.md:2343-2350`, que hoy ya no resuelve ahí).

---

### 1. La frontera, escrita — y qué propiedad tiene

Está en `docs/gobernanza/autoalojamiento.md`, §«Aprobación humana delegada», subsección «La frontera del
recuento — lectura GLOBAL». Sus seis puntos, resumidos para poder auditarlos:

1. **Qué se cuenta:** todo hallazgo cuya **clase** sea `usuario/dinero` o `contrato`, del proyecto
   entero, cuelgue o no de un REQ; **el prefijo del identificador no dice nada de la clase** (ejemplos
   no exhaustivos: `SEC-`, `QA-`, `DEV-`, `AN-`, `H-`). Sitio único de la definición de clases:
   `requirements/README.md`.
2. **Qué es abierto:** el **complemento del cierre** — todo estado que no sea `mitigado` ni `aceptado`;
   y lo indeterminable cuenta como abierto.
3. **Dónde se lee:** unión de dos sedes —el índice de este registro (§2) y los campos `Hallazgos
   abiertos:` de `requirements/`—, **fail-closed en la discrepancia**, que además devuelve la decisión
   al propietario por sí sola.
4. **Sobre qué árbol:** el commit que se va a etiquetar, por `git show`.
5. **Cómo se acredita:** publicando el **recuento** con el tag. Sin recuento publicado, la publicación
   **no está acreditada**, aunque el recuento hubiera sido cero.
6. **Lo que no es:** una puerta. `guard-completado` sólo lee el campo del REQ que se cierra
   (`hooks/guard-completado.sh:484-527`) y ninguna herramienta enumera el conjunto.

**Las dos decisiones de forma que hacen que esto no envejezca hacia el lado que abre.** (a) El punto 1
se enuncia **por clase y no por origen**: la alternativa —«los hallazgos `SEC-` del registro»— es la que
ya falló, y falló **midiendo** (abajo). (b) El punto 2 se enuncia **por complemento**: enumerar los
estados que abren obliga a acordarse de ampliar la lista, y esa clase de olvido siempre cae del lado
que concede el permiso.

**Corrección a mi propia medición de R-015, y es exactamente la familia que audito en otros.** En
`SEC-053` publiqué «**17** `contrato` abiertos», enumerando `SEC-020`, `SEC-031`…`036`,
`SEC-038`…`045`, `SEC-050` y `SEC-052`. Ese 17 estaba **corto por construcción**, y el hueco tiene
forma precisa — **trece** hallazgos `contrato` fuera de la enumeración, por tres motivos distintos:

- **Siete por el prefijo:** `QA-114`, `QA-116`, `QA-117`, `DEV-014-01`, `DEV-014-02`, `QA-021-10`,
  `QA-021-11`. Son `contrato` y no llevan prefijo `SEC-`; el criterio cuenta **clase**, no autoría.
- **Cuatro por la sede:** `SEC-014`, `SEC-023`, `SEC-029`, `SEC-030`. Viven en entradas con encabezado
  `####`, o con el estado declarado en una línea `- **Estado:**` de una revisión posterior, así que no
  aparecen buscando encabezados `### SEC-…`.
- **Dos por autoexclusión:** `SEC-053` y `SEC-054`, los que esa misma revisión abría — y el motivo
  está escrito dentro de `SEC-053`: *«no sé decir si mi propio hallazgo cuenta»*. Ahora sí:
  **cuenta**.

17 + 13 = **30** sobre `b199e08`, y **31** contando `SEC-055`, que abre esta revisión. No corrijo la
entrada de R-015 (esta bitácora no se edita hacia atrás): queda enmendada aquí, y el número que rige
es el de §3. **Y lo que este error demuestra no es que midiera mal, sino por qué la frontera no podía
enunciarse por enumeración:** quien enumeró sabía que enumerar falla —lo lleva escrito varias veces en
este registro— y falló igual. Una regla que sólo funciona cuando el que la aplica se acuerda no es una
regla.

---

### 2. Índice de hallazgos de clase bloqueante — **sitio único de la lista exhaustiva**

> **Qué es.** La lista **exhaustiva** de los hallazgos de clase `usuario/dinero` y `contrato` de este
> proyecto, con su estado vigente. Es la sede que cita la frontera de publicación delegada, y existe por
> una razón operativa medida: **la prosa de este registro no se puede contar.** Sus entradas usan
> encabezados `###` y `####`, declaran la clase unas veces en el encabezado y otras en una línea
> `- **Clase:**`, y el estado cambia en entradas posteriores a la de apertura. Contar leyendo exige
> interpretar; interpretar es lo que el criterio no puede permitirse.
>
> **Qué NO es.** No sustituye a las entradas: la **evidencia, la remediación y el razonamiento** viven en
> ellas, y la fila sólo apunta. No indexa `instrumento` —la única clase que no bloquea—; un `instrumento`
> que se **promueva** a clase bloqueante entra en el índice en el momento de la promoción.
>
> **Quién lo mantiene y con qué disciplina.** El `auditor-seguridad`. Una fila no se borra nunca: cambia
> de estado. Cada revisión que abra, cierre o cambie de estado un hallazgo bloqueante actualiza el índice
> **en la misma revisión**; si no lo hace, la fila queda desalineada y la regla de unión + fail-closed de
> la frontera hace que la desalineación **bloquee**, que es la dirección correcta del error.
>
> **Estados:** `abierto` · `en-mitigación` · `mitigado` · `aceptado`. Bloquean todos menos los dos
> últimos.

| ID | Clase | Estado | Sede del hallazgo | Declarado en campo `Hallazgos abiertos:` de |
|---|---|---|---|---|
| `SEC-009` | contrato | `mitigado` | R-002 (`:344`) / cierre en R-003 (`:643`) | — (cerrado) |
| `SEC-010` | contrato | `mitigado` | R-002 (`:391`) / cierre en R-003 (`:705`) | — (cerrado) |
| `SEC-011` | contrato | `mitigado` | R-002 (`:443`) / cierre en R-003 (`:752`) | — (cerrado) |
| `SEC-014` | contrato | `mitigado` | R-003 (`:781`); pata 3 invertida en R-005 (`:1211`) y **cerrada en R-006** (`:1429`, trece afirmaciones medidas) | **discrepancia:** sigue declarado en `REQ-013` |
| `SEC-015` | contrato | `mitigado` | R-004 (`:1021`); remediación verificada en la firma de REQ-015 (CA-08, R-007/R-008) | — (cerrado) |
| `SEC-020` | contrato | **`abierto`** | R-004 (`:1305`) | `REQ-013` |
| `SEC-023` | contrato | **`en-mitigación`** | R-007 (`:1661`) | — (no cuelga de REQ vivo) |
| `SEC-024` | contrato | `mitigado` | R-007 (`:1698`), cierre en R-009 (`:2570`) | — (cerrado) |
| `SEC-025` | contrato | `mitigado` | R-007 (`:1782`), cierre en R-008 (`:2333`) | — (cerrado) |
| `SEC-029` | contrato | **`en-mitigación`** | R-007 (`:1933`), estado en R-008 (`:2496`) | — (no atribuible a REQ) |
| `SEC-030` | contrato | **`abierto`** | R-008 (`:2418`) | — (no atribuible a REQ) |
| `SEC-031` | contrato | **`en-mitigación`** | R-010 (`:2714`) | retirado del campo por write-back (REQ-019) |
| `SEC-032` | contrato | **`en-mitigación`** | R-010 (`:2757`) | retirado del campo por write-back (REQ-019) |
| `SEC-033` | contrato | **`abierto`** | R-010 (`:2795`) | `REQ-019` |
| `SEC-034` | contrato | **`en-mitigación`** | R-010 (`:2839`) | retirado del campo por write-back (REQ-019) |
| `SEC-035` | contrato | **`en-mitigación`** | R-010 (`:2865`) | retirado del campo por write-back (REQ-021) |
| `SEC-036` | contrato | **`en-mitigación`** | R-010 (`:2917`) | retirado del campo por write-back (REQ-021) |
| `SEC-038` | contrato | **`abierto`** | R-011 (`:3099`) | `REQ-020` |
| `SEC-039` | contrato | **`abierto`** | R-011 (`:3141`) | `REQ-020` |
| `SEC-040` | contrato | **`abierto`** | R-011 (`:3196`) | `REQ-020` |
| `SEC-041` | contrato | **`abierto`** | R-011 (`:3251`) | `REQ-020` |
| `SEC-042` | contrato | **`abierto`** | R-011 (`:3277`) | `REQ-020` |
| `SEC-043` | contrato | **`abierto`** | R-011 (`:3322`) | `REQ-020` |
| `SEC-044` | contrato | **`abierto`** | R-011 (`:3367`) | `REQ-020` |
| `SEC-045` | contrato | **`abierto`** | R-011 (`:3411`) | `REQ-020` |
| `SEC-050` | contrato | **`abierto`** | R-013 (`:4014`) | — (no cuelga de ningún REQ) |
| `SEC-052` | contrato | `mitigado` | R-014 (`:4319`), cierre en R-015 (`:4429`) | **discrepancia:** sigue declarado en `REQ-023` |
| `SEC-053` | contrato | `mitigado` | R-015 (`:4472`); estado en R-016 (`:4906`); **cierre en R-017** (`:5164`) | — (cerrado; nunca colgó de ningún REQ) |
| `SEC-054` | contrato | **`abierto`** | R-015 (`:4577`) | — (no cuelga de ningún REQ) |
| `SEC-055` | contrato | **`abierto`** | R-016 (`:4947`) | — (pendiente de enrutar a `REQ-019`) |
| `QA-114` | contrato | **`abierto`** | `docs/qa/` (dueño `analista-requerimientos`) | `REQ-007` |
| `QA-116` | contrato | **`abierto`** | `docs/qa/`, reproducido por el auditor en R-003 | `REQ-007` |
| `QA-117` | contrato | **`abierto`** | `docs/qa/`, reproducido por el auditor en R-003 | `REQ-007` |
| `DEV-014-01` | contrato | **`abierto`** | informe del `desarrollador`, REQ-014 | `REQ-014` |
| `DEV-014-02` | contrato | **`abierto`** | informe del `desarrollador`, REQ-014 | `REQ-014` |
| `QA-021-10` | contrato | **`abierto`** | `docs/qa/` de la ventana 1.33.0, vuelta 3 | `REQ-021` |
| `QA-021-11` | contrato | **`abierto`** | `docs/qa/` de la ventana 1.33.0, vuelta 3 | `REQ-021` |

**Las cinco filas `en-mitigación` de R-010 no son un maquillaje, y su motivo se dice entero.** `SEC-031`,
`SEC-032`, `SEC-034`, `SEC-035` y `SEC-036` salieron de los campos `Hallazgos abiertos:` de REQ-019 y
REQ-021 por un write-back que el `analista-requerimientos` declara hecho y verificado remediación por
remediación (`CHANGELOG.md`, entradas del 2026-09-08 de write-back de R-010). **Yo no lo he verificado**,
y mi norma es no aceptar el cierre del informe de otro: por eso no van a `mitigado`. Van a
`en-mitigación`, que es exactamente lo que sé —la remediación está en el árbol, sin verificar por mí—, y
que **sigue contando como bloqueante**. *Forzador:* la auditoría del código de REQ-019 y de REQ-021, que
en las dos preventivas (R-010) quedó comprometida bloque a bloque. *Vencimiento:* esas auditorías, en su
turno, después de QA. Antes de esa fecha, la fila que no puedo cerrar cuenta en contra, que es la
dirección correcta.

**Y las dos filas en discrepancia se quedan así a propósito, porque la discrepancia es el dato.**
`SEC-052` está `mitigado` (R-015, verificado punto por punto por mí) y el campo de `REQ-023` sigue
declarándolo; `SEC-014` está `mitigado` desde **R-006** —su pata 3 cerrada con trece afirmaciones medidas
ejecutando— y el campo de `REQ-013` sigue declarándolo. Bajo la regla de unión, **las dos cuentan**. Se
cierran cuando el `analista-requerimientos` retire `SEC-014 (contrato)` y `SEC-052 (contrato)` de esos
campos; el segundo write-back ya estaba identificado en R-015, **el primero lo encuentra esta revisión al
construir el índice** y llevaba dos ventanas sin verse. No los retiro yo: `requirements/` no es mío.

**Y ése es el argumento entero a favor del índice, en un caso real:** `SEC-014` estaba **cerrado** en la
prosa y **abierto** en el campo desde R-006, y nadie lo notó en dos ventanas porque para verlo había que
cruzar 4.700 líneas de bitácora contra 25 cabeceras. Una tabla lo enseña en una fila. Nótese además la
dirección del error: aquí la discrepancia sobra-cuenta, y por eso es tolerable; la peligrosa es la
contraria —cerrado en el campo y abierto en la prosa—, y contra ésa la regla de unión es lo único que
protege.

---

### 3. El recuento de hoy, publicado con la forma que la frontera obliga

**Commit medido:** `cand/1.33.0` @ `b199e08`. **Sedes leídas:** el índice de §2 y los campos
`Hallazgos abiertos:` de los 25 `requirements/REQ-*.md`.

| Concepto | Cifra |
|---|---|
| Hallazgos de clase `usuario/dinero` abiertos | **0** |
| Hallazgos de clase `contrato` abiertos, medidos sobre `b199e08` | **30** |
| **+ `SEC-055`**, abierto por esta misma revisión (§5) | **+1** |
| **Recuento vigente a partir de este commit** (unión de las dos sedes) | **31** |
| — de ellos, declarados en un campo `Hallazgos abiertos:` | 19 |
| — de ellos, sólo en el registro (no cuelgan de un REQ vivo) | 12 |
| — de ellos, `en-mitigación` por write-back pendiente de mi verificación | 5 |
| — de ellos, en discrepancia declarada entre las dos sedes | 2 (`SEC-014`, `SEC-052`) |
| Recuento **sin** los siete discutibles (los 5 anteriores + `SEC-014` + `SEC-052`) | **24** |

Los 19 declarados en campos, por REQ: `REQ-007` → `QA-114`, `QA-116`, `QA-117`; `REQ-013` → `SEC-014`,
`SEC-020`; `REQ-014` → `DEV-014-01`, `DEV-014-02`; `REQ-019` → `SEC-033`; `REQ-020` → `SEC-038`…`SEC-045`
(ocho); `REQ-021` → `QA-021-10`, `QA-021-11`; `REQ-023` → `SEC-052`. Los 12 sólo del registro:
`SEC-023`, `SEC-029`, `SEC-030`, `SEC-031`, `SEC-032`, `SEC-034`, `SEC-035`, `SEC-036`, `SEC-050`,
`SEC-053`, `SEC-054`, `SEC-055`. Suman 31, y las dos cifras cuadran a propósito: un recuento que no
cuadra con su propia lista no es un recuento.

**Y las dos cifras —30 y 31— se publican las dos, en lugar de la más cómoda.** El criterio se mide
sobre el commit que se etiqueta, y la revisión que escribe esto **añade** un hallazgo bloqueante: decir
sólo «30 sobre `b199e08`» sería exacto y engañoso, porque cualquier publicación posterior a este commit
se mide contra **31**. Es la misma disciplina que el punto 5 de la frontera pide a la coordinadora,
aplicada al auditor.

**Consecuencia, sin adorno: la delegación no autoriza nada hoy.** Bajo la lectura que el propietario
ratificó, con 31 hallazgos bloqueantes abiertos la coordinadora no puede acreditar que la delegación la
cubra, ni para `v1.33.0` ni para ninguna publicación mientras el recuento no sea cero. La consecuencia la
aceptó el propietario explícitamente al elegir la lectura: **la delegación queda retirada de hecho y cada
tag vuelve a él.**

**Y la condición de reactivación, con mi evaluación de si se va a cumplir.** Reactiva: recuento **cero**
en las dos sedes, sin discrepancias, sobre el commit a etiquetar, **publicado** con el tag. Evaluación:
**no va a ocurrir mientras este repositorio desarrolle su propio mecanismo**, y no es una opinión sobre
el equipo. Medido en la ventana 1.33.0: las revisiones de seguridad abrieron **19** hallazgos `contrato`
(`SEC-031`…`036`, `SEC-038`…`045`, `SEC-050`, `SEC-052`, `SEC-053`, `SEC-054` y `SEC-055`) y se
cerraron **6** (`SEC-031`, `032`, `034`, `035`, `036`, `052`); QA abrió dos más (`QA-021-10`,
`QA-021-11`). Tres a uno, en la ventana en la que se pretendía publicar. La clase
`contrato` es «un texto firmado describe un control con un alcance que no tiene», y este proyecto
**produce texto firmado sobre la máquina en cada ventana**: encontrarlos es el trabajo, no la avería. Una
delegación cuya condición de activación nunca se cumple **es mejor retirada que en pie** — en pie obliga
a explicar en cada publicación por qué no se ejerció. **Retirarla es decisión del propietario y no la
tomo**; queda escrita en el documento gobernado para que sea decisión y no olvido.

---

### 4. La frontera existe; lo que falta es una ratificación que no es mía

### SEC-053 — Estado: `abierto` → **`en-mitigación`**. La lectura está decidida y escrita; el residual es la ratificación de una segunda publicación

**Qué está cumplido, verificado contra el árbol y no contra el encargo:**

1. **La lectura está decidida** —global— y **escrita** en `docs/gobernanza/autoalojamiento.md`, §«La
   frontera del recuento», con los seis puntos de §1 de esta revisión.
2. **Está enunciada por propiedad, no por enumeración**, en sus dos ejes: la clase (no el prefijo del ID)
   y el complemento del cierre (no la lista de estados que abren). Cita el **sitio único** de la
   definición de clases (`requirements/README.md`) y el **sitio único** de la lista exhaustiva (el índice
   de §2), y marca sus ejemplos como no exhaustivos.
3. **La consecuencia está dicha sin suavizar**, en el mismo párrafo que concede la delegación: hoy no
   autoriza nada. Ésa era la mitad que convertía el hallazgo en la clase `SEC-050`.
4. **La condición de reactivación es medible** y está publicada, con la evaluación honesta de que no se
   va a cumplir.
5. **La escribió quien no se beneficia**, y el documento lo dice con su motivo.
6. **`v1.32.1` queda anotada como publicación de autoridad no acreditada y ratificada a posteriori** por
   el propietario, que era literalmente lo que mi propia cláusula de escalada mandaba hacer.

**Por qué NO pasa a `mitigado`, y es una sola cosa:** el barrido de §6 encontró una **segunda**
publicación en la misma situación —`v1.31.0`— que nadie había medido, y su ratificación es del
propietario. Mientras esa ratificación no exista por escrito, el hallazgo conserva la mitad que le da
sentido: *un permiso ejercido sin poder demostrar que existía no se arregla hacia atrás; sólo se puede
reconocer*, y aquí falta un reconocimiento.

- **Residual exacto, y sólo éste:** la ratificación expresa del propietario sobre `v1.31.0`.
- **Dueño del residual:** **propietario**. *Redacción del registro:* `auditor-seguridad`.
- **Forzador:** la primera publicación posterior a esta revisión —enunciado por propiedad y no por
  fecha—, porque es el momento en que alguien vuelve a apoyarse en el criterio y la pregunta «¿y las
  anteriores?» tiene que estar contestada.
- **Vencimiento:** antes del tag `v1.33.0`.
- **Escalada si se publica sin resolverlo:** el hallazgo **no sube de clase** —ya bloquea— pero la
  publicación nueva se anota igual que las dos del barrido, y entonces serán **tres**. Un patrón de tres
  deja de ser un descuido: pasa a ser la práctica sustituyendo al criterio firmado, que es el segundo
  riesgo que `SEC-053` nombró.
- **Lo que este cambio de estado NO significa:** no levanta ningún bloqueo. `SEC-053` sigue contando en
  el recuento de §3 y sigue siendo una de las 31 razones por las que `v1.33.0` no está cubierto.

---

### 5. Hallazgo nuevo: `AGENTS.md` sigue prometiendo la delegación que hoy no autoriza nada

### SEC-055 — `contrato` · **abierto** · severidad **media** · dueño `analista-requerimientos` (el write-back) y **propietario** (la decisión de fondo)

**`AGENTS.md` promete una delegación permanente que, bajo la lectura ratificada, hoy no autoriza nada —
y no cita la frontera ni su regla de recuento**

- **Ubicación, las dos:**
  - `AGENTS.md:60` (§4): «*La fusión a `main`, el tag de versión y la publicación son decisiones
    **humanas**, **delegadas** a la coordinadora por el propietario (2026-09-05) cuando todo está en
    verde; cualquier rojo o **hallazgo abierto** las devuelve al humano*».
  - `AGENTS.md:120` (§6): «*…**fusiona, etiqueta y publica por delegación permanente del propietario
    (2026-09-05)**; cualquier rojo o hallazgo abierto devuelve la decisión a Juan*».
- **El defecto, en una frase:** las dos frases describen una delegación **operativa** y arrastran la
  misma ambigüedad que `SEC-053` cerró en el documento de gobernanza —«hallazgo abierto», sin decir
  abierto dónde ni contra qué sede—. Quien lea `AGENTS.md` y no llegue a
  `docs/gobernanza/autoalojamiento.md` concluirá que la coordinadora puede publicar cuando el CI esté
  verde. **Medido hoy: no puede, y no podrá previsiblemente nunca.** Es la clase `SEC-050` exacta: un
  texto firmado describe un control con un alcance que no tiene.
- **Lo que acota la severidad, y se dice por delante para no inflarla:** **no viaja a las plantillas.**
  Medido — `grep -rn 'delegaci\|delegad' templates/*.tpl CLAUDE.md` no devuelve nada: ningún proyecto
  consumidor hereda esta promesa. El daño se queda en este repositorio y en quien lo lea. De ahí
  `media` y no `alta`.
- **Por qué `contrato` y no `instrumento`:** ningún comportamiento de la máquina está mal. Lo que está
  mal es lo que un documento firmado **afirma** sobre quién puede publicar el mecanismo que gobierna a
  los demás proyectos. Efecto de máquina: **ninguno**. No es veto y no bloquea ninguna quality gate.
- **Remediación, enunciada por propiedad y con sitio único:** cada frase de `AGENTS.md` que enuncie o
  acote la delegación de publicación **cita** la frontera de `docs/gobernanza/autoalojamiento.md`
  §«La frontera del recuento» y **no la transcribe** —dos transcripciones de la misma regla se
  desfasan, y ésta ya se desfasó una vez—, y declara que la delegación **está en pie y hoy no
  autoriza**, o queda retirada si el propietario así lo decide. No se enumeran aquí las frases: son las
  que el inventario de invariantes de `REQ-019` (`CA-15`) produzca sobre la propiedad «enuncia o acota
  el permiso de publicar».
- **NO se arregla en esta revisión, y el motivo es de coordinación, no de criterio:** `AGENTS.md` está
  dentro del `Archivos:` de **`REQ-019`** (`requirements/REQ-019.md:4`), que es precisamente el REQ que
  reparte ese documento; una edición ahora colisiona por archivo con una comisión viva. El write-back
  entra **por `REQ-019`**, que ya tiene sede declarada para esto.
- **Dueño:** `analista-requerimientos` (el write-back en `REQ-019`) y **propietario** (si la decisión es
  retirar la delegación en vez de acotarla).
- **Forzador:** cualquiera de los dos, el que llegue primero — la primera publicación posterior a esta
  revisión, o el reparto de `AGENTS.md` de `REQ-019`.
- **Vencimiento:** el cierre de `REQ-019`.
- **Escalada:** si `REQ-019` cierra sin tocar las dos frases, el hallazgo **no sube de clase** pero pasa
  a ser regresión de reparto: el REQ cuyo objeto es que `AGENTS.md` no prometa más de lo que la máquina
  cumple habría cerrado dejando en pie el ejemplo más caro de esa clase, en el propio documento que
  reparte.

**Nota de colisión que dejo dicha, porque me toca a mí y no la voy a callar.** Esta revisión escribe en
`docs/gobernanza/autoalojamiento.md`, que **también** está en el `Archivos:` de `REQ-019` (misma línea
`:4`). Es una decisión del propietario y está acotada a **una** sección, pero el efecto para el reparto
es real y conviene que el analista lo sepa antes de mover un byte: la sección «Aprobación humana
delegada» es ahora **la sede** de la frontera, así que el reparto de `AGENTS.md` §4 y §6 debe **apuntar
aquí**, nunca traer una copia. Que este documento sea el destino natural de esos bloques es, de hecho,
lo que `REQ-019` ya planeaba (`requirements/REQ-019.md:977`, `:996`).

---

### 6. Barrido de los 40 tags publicados — con denominador, porque un veredicto sin denominador no se puede desmentir

**Universo:** los **40** tags de este repositorio (`git tag --list`), sin excluir ninguno.
**Partición medida, no supuesta:**

| Grupo | Tags | Criterio de delegación en su árbol | Registro de seguridad en su árbol | `requirements/REQ-*.md` en su árbol |
|---|---|---|---|---|
| Anteriores al autoalojamiento | **36** (`v1.2.0` … `v1.30.2`) | **no existe** | **no existe** | **0 archivos** |
| Bajo el criterio | **4** (`v1.30.3`, `v1.31.0`, `v1.32.0`, `v1.32.1`) | sí, desde `v1.30.3` | sí | sí |

Los 36 quedan **fuera del alcance** y no por conveniencia: el bloque «Aprobación humana delegada» entra
en el árbol **con** `v1.30.3` (primer commit del documento: `6c1b58a`, el mismo que el tag), y antes no
existían ni el registro de hallazgos ni un solo REQ, así que **no existía la noción de clase de
hallazgo** contra la que medir. No hay nada que acreditar frente a una regla que no existía. **Lo que no
afirmo, para no prometer más de lo que medí:** quién decidió cada una de esas 36 publicaciones. No lo
comprobé, porque bajo ninguna lectura cambiaría el veredicto de las 4 que sí están en alcance.

**Los cuatro, uno por uno, con el mismo método:**

| Tag | Commit | `contrato`/`usuario/dinero` abiertos en su propio árbol | Cómo se decidió publicar | Veredicto |
|---|---|---|---|---|
| `v1.30.3` | `6c1b58a` | **0** en las dos sedes (registro sin ninguno; ningún campo de REQ con clase bloqueante) | «*[Interno] — 2026-09-05 · registro del ciclo 1 del autoalojamiento*», agente: sesión coordinadora | **conforme** — con recuento cero, la delegación cubre, decida quien decida |
| `v1.31.0` | `2fecae1` | **3** — `QA-114`, `QA-116`, `QA-117`, `contrato`, contra REQ-007, y **en las dos sedes**: el campo de `REQ-007` de ese tag los declara, y el registro de ese tag lo dice en dos sitios (líneas 900 y 922 del blob: «*Quedan abiertos contra él **QA-114, QA-116 y QA-117**, los tres `contrato`*») | «*[Interno] — 2026-09-06 · cierre del ciclo 2 del autoalojamiento*», **agente: sesión coordinadora**. `git log -- PENDING_APPROVAL.md` no registra ninguna entrada de publicación entre `6c1b58a` y ese cierre; la única entrada resuelta del archivo en ese árbol es la del 2026-09-05 sobre `codigo_app.globs`, ajena a la publicación | **de autoridad NO acreditada** |
| `v1.32.0` | `ca6047a` | **5 en campos** (`QA-114`, `QA-116`, `QA-117`, `SEC-014`, `SEC-020`) y `SEC-020` `contrato` · `abierto` en el registro (línea 1305 del blob) | **decisión expresa del propietario**, por escrito en la entrada resuelta de `PENDING_APPROVAL.md` de ese árbol: «*El propietario eligió **publicar 1.32.0** el 2026-09-07*» | **conforme, y no por delegación** — la decisión la tomó el propietario, así que es conforme bajo las tres lecturas |
| `v1.32.1` | `973448f` | **5 en campos** (los mismos) y `SEC-020` `contrato` · `abierto` en el registro (mismo blob, línea 1305) | «*[Cierre] — 2026-09-07 · Cierre documental de la ventana 1.32.1*», **agente: coordinadora**, y la propia entrada **nombra `SEC-020`** entre lo que cruza a 1.33.0. Sin entrada en la cola | **de autoridad NO acreditada** |

**Un matiz de las dos últimas filas, dicho para no inflar la cifra:** de los 5 identificadores
declarados en campos en `v1.32.0` y `v1.32.1`, `SEC-014` **ya estaba `mitigado`** en el registro de esos
mismos árboles (cerrado en R-006, dentro de la ventana 1.32.0), así que también entonces era una
discrepancia y no un hallazgo vivo. **No cambia nada:** `SEC-020` estaba `contrato` · `abierto` en las
dos sedes de los dos árboles y basta por sí solo. Lo anoto porque el veredicto tiene que sostenerse con
el hallazgo más fuerte, no con el recuento más alto.

**Denominador y resultado, en una línea:** **40 tags examinados · 4 en alcance · 2 conformes · 2 de
autoridad no acreditada** (`v1.31.0` y `v1.32.1`).

**Lo que este barrido añade a lo que ya se sabía, y por qué importa.** R-015 midió `v1.32.0` y `v1.32.1`
y encontró una. El barrido completo encuentra **dos**, y la segunda es **anterior**: `v1.31.0` se publicó
con tres `contrato` abiertos declarados en las dos sedes. No apareció antes por la misma razón por la que
mi recuento de R-015 salió corto: se buscaron hallazgos con prefijo `SEC-` en el registro, y los tres de
`v1.31.0` son `QA-`. **Es la misma clase que este registro lleva nombrada varias veces —enumerar en vez
de enunciar la propiedad—, y esta vez el que enumeró fui yo.** Que la haya cometido quien la persigue es
el argumento más fuerte a favor de que la frontera se enuncie por propiedad y de que exista un índice:
la disciplina personal ya se probó, y no basta.

**Ratificación, y el límite de lo que puedo escribir.**

- **`v1.32.1`: ratificada a posteriori por el propietario el 2026-09-08.** Queda anotada aquí como
  **publicación de autoridad no acreditada** —tal como mandaba la cláusula de escalada de `SEC-053`— y
  **ratificada**. No se revierte, no se retira y no se propone retirar nada: lo que se corrige es que
  quedara sin acreditar. Y queda **sin maquillar y sin llamarlo caso límite**: se publicó por delegación
  con un hallazgo `contrato` abierto **nombrado en la misma entrada que anuncia la publicación**, y bajo
  la lectura que el propietario acaba de ratificar el criterio decía que esa decisión era suya.
- **`v1.31.0`: anotada como publicación de autoridad no acreditada, ratificación PENDIENTE.** Es del
  propietario y **no la firmo en su nombre** — hacerlo sería exactamente `SEC-052`: cerrar con mi firma
  una decisión de otro. Es el residual de `SEC-053` (§4).
- **Lo que no hago con ninguna de las dos:** revertir, retirar o reabrir un REQ `completado`. Ninguno
  depende de este criterio: es de gobernanza, no contrato de REQ.

---

### 7. `v1.33.0` — **NO está cubierto por la delegación.** La respuesta, con las cifras delante

Se me pidió escribirlo con los números a la vista, y son éstos: **31** hallazgos de clase `contrato`
abiertos (30 medidos sobre `b199e08` más `SEC-055`, que abre esta revisión) y **0** de
`usuario/dinero`; **24** si se descuentan los siete discutibles; y entre ellos, **cuatro** que apuntan
a la publicación misma —`SEC-050` (`contrato`, abierto), `SEC-053` (`contrato`, `en-mitigación`, y su
residual **vence antes de este tag**), `SEC-054` (`contrato`, abierto, que es literalmente «1.33.0
publicaría una acreditación firmada que la medición desmiente») y `SEC-055` (`contrato`, abierto,
`AGENTS.md` prometiendo la delegación que hoy no autoriza)—.

**Veredicto: la fusión, el tag `v1.33.0` y la publicación son decisión del propietario.** La
coordinadora no puede acreditar que la delegación la cubra, y bajo la frontera escrita **la falta de
acreditación no es un empate: devuelve la decisión**. Con 31 bloqueantes no hay lectura que lo salve, y
ésa era la propiedad que la lectura global tenía que garantizar.

**Y lo digo también en la dirección incómoda para mí:** este veredicto no depende de que mis propios
hallazgos cuenten. Descontando los **12** que no cuelgan de ningún REQ —los cuatro de arriba incluidos,
y los cinco de write-back sin verificar—, quedan **19** declarados en campos `Hallazgos abiertos:` por
QA, por el desarrollador y por el analista, y el resultado es el mismo. La pregunta que en R-015 no supe
contestar —«*no sé decir si mi propio hallazgo cuenta*»— ahora tiene respuesta (**cuenta**), y además ya
no decide nada por sí sola.

---

### Rigor y estado de los REQ — R-016

**No subo ni bajo el rigor de ningún REQ**, y no firmo ninguno: ninguna línea `QA:` ni `Seguridad:` se
toca en esta revisión. Los REQ implicados (`REQ-019`, `REQ-021`, `REQ-023`) ya son `Rigor: critico` con
`Sensible a seguridad: sí`, que es su suelo.

**Estado de seguridad aprobado — línea base de no-regresión: sin cambios, y re-medida por objeto de
árbol.** Sigue vigente la de **R-012** para REQ-017 y para toda la capa de enforcement, anclada así:
`hooks/` = `88c146536f21fa03d3c8fdad8063b645fb0162bc` en `b199e08`, **el mismo objeto** que se firmó en
R-012, y `git diff b6e581b HEAD -- hooks/ tools/ .github/ .arnes/` **vacío**. Ninguna auditoría futura
debería encontrar otro objeto en `hooks/` sin una firma nueva entre medias. Para lo anterior, R-009/R-008.

**Lo que esta revisión acredita.** Que la frontera del criterio de publicación delegada está escrita,
por propiedad, con sitio único y con su consecuencia declarada; que el recuento es de **30** `contrato`
y **0** `usuario/dinero` sobre `b199e08`, y **31** contando el que abre esta revisión; que de los **40**
tags publicados, **4** caen bajo el criterio y **2** se publicaron sin autoridad acreditada; y que
`v1.33.0` **no está cubierto** por la delegación.

**Lo que NO acredita, dicho para que nadie lo estire.** Ninguna quality gate —no las miro, y por eso
firmo después de QA—. **Ningún REQ**: ni `REQ-019`, ni `REQ-020`, ni `REQ-021`, ni `REQ-023`. No acredita
el write-back de `SEC-031`, `032`, `034`, `035` y `036`, que es justamente por lo que quedan
`en-mitigación`. No acredita el código de la ventana 1.33.0, que se audita en su turno, después de QA. Y
no es una auditoría preventiva de nada: es la ejecución escrita de una decisión del propietario más su
medición.

---

## Revisión R-017 — cierre del residual de `SEC-053`: la ratificación de `v1.31.0` (no es auditoría de ningún REQ; no firma nada) — 2026-09-08

**Alcance.** Una sola cosa: el residual **único** que R-016 dejó vivo en `SEC-053` —la ratificación
expresa del propietario sobre `v1.31.0`—, más lo que su cierre cambia y, sobre todo, lo que **no**
cambia. **No audita ningún REQ, no mira ninguna quality gate y no toca ninguna línea `QA:` ni
`Seguridad:`.** Tampoco es preventiva: es el registro de una decisión ajena, verificada donde está
escrita.

**Árbol.** `HEAD` = `b7ed615` en `cand/1.33.0`, con **49** archivos modificados sin comitear: hay una
comisión viva del `desarrollador` sobre `tests/` (REQ-014 reabierto por resolución del propietario de
hoy). **No leo ni mido `tests/`**, nada de esta revisión depende de él, y mi única escritura es este
archivo.

### 1. La ratificación, verificada donde está escrita — y una salvedad mecánica que no me callo

**Lo que verifiqué, no lo que me contaron:**

- **La decisión existe, con fecha y autor.** `PENDING_APPROVAL.md`, sección `## Resueltas`, entrada
  «RESUELTA 2026-09-08 (propietario) — ratificación de `v1.31.0`, publicada de autoridad no
  acreditada». Dice **ratificada**, y remite expresamente a la misma resolución que el propietario ya
  dio para `v1.32.1`.
- **El hecho que ratifica sigue siendo el que medí, re-comprobado hoy y no de memoria.** `v1.31.0` =
  `2fecae1`. En **su propio árbol**: `git show v1.31.0:requirements/REQ-007.md` declara `QA-114`,
  `QA-116` y `QA-117` como `contrato` en la línea 9, y `git show
  v1.31.0:docs/seguridad/registro-seguridad.md` lo dice en dos sitios del blob (líneas 900 y 922). La
  ratificación no cae sobre un hecho reinterpretado a conveniencia entre R-016 y hoy.
- **La cola no queda con deuda nueva:** `## Pendientes` de `PENDING_APPROVAL.md` está **vacía**.

**Y la salvedad, que es mecánica y no retórica: la ratificación hoy NO existe en ningún commit.**
Medido: `git show HEAD:PENDING_APPROVAL.md` **no** contiene la entrada; vive sólo en el árbol de
trabajo (`git diff --stat PENDING_APPROVAL.md` → 12 líneas añadidas). El **punto 4** de la frontera
obliga a leer la acreditación **del árbol del commit que se etiqueta**, con `git show`, «nunca de la
memoria de la sesión ni del estado de la rama de trabajo». Consecuencia exacta, sin dramatizarla: la
ratificación es real y **la doy por buena hoy**, pero si el commit que se etiqueta como `v1.33.0` no la
lleva dentro, un tercero que repita la medición dentro de un año leerá el árbol y **no la encontrará** —
y entonces el cierre de esta fila descansa sobre algo que el árbol no dice. Con 49 archivos modificados
y una comisión viva, eso no es una hipótesis remota.

**Comprobación al tag, escrita para que no dependa de que alguien se acuerde.** Sobre el commit que se
vaya a etiquetar, y no sobre la rama:

```
git show <commit-del-tag>:PENDING_APPROVAL.md                        # debe contener la entrada de ratificación de v1.31.0
git show <commit-del-tag>:docs/seguridad/registro-seguridad.md       # debe contener esta entrada R-017 y la fila SEC-053 en `mitigado`
```

**Si esa comprobación falla, la fila vuelve a `en-mitigación`** y `v1.31.0` queda otra vez como
publicación de autoridad no acreditada **sin** ratificación. Lo dejo decidido por delante y no para
después: después del tag la respuesta ya no es una decisión, es una justificación.

### SEC-053 — Estado: `en-mitigación` → **`mitigado`**. El residual único se resolvió; la fila se cierra y deja de contar

**Sin maquillaje, y en el orden que importa:**

1. **Lo que se ratificó, dicho en su forma más cruda.** `v1.31.0` se publicó el 2026-09-06 por la
   **sesión coordinadora**, **por delegación**, con **tres** hallazgos de clase `contrato` abiertos
   —`QA-114`, `QA-116`, `QA-117`— **declarados en las dos sedes de su propio tag**, y sin entrada en la
   cola que devolviera la decisión al propietario. Bajo la lectura que el propietario ratificó
   —**global**—, esa decisión era **suya y no se le pidió**. La ratificación **no convierte aquello en
   conforme**: reconoce que se ejerció un permiso que no se podía acreditar. Es exactamente lo que mi
   cláusula de escalada mandaba —*un permiso que se ejerce sin poder demostrar que existía no se arregla
   hacia atrás; sólo se puede reconocer*— y es **todo** lo que puede hacer.
2. **No se revierte, no se retira y no se propone retirar nada.** `v1.31.0` sigue publicada, y ningún
   REQ `completado` depende de este criterio: es de gobernanza, no contrato de REQ.
3. **La cifra completa del barrido se queda escrita, para que el cierre no la borre.** De los **40** tags
   del repositorio, **4** caen bajo el criterio: **2 conformes** (`v1.30.3`, con recuento cero;
   `v1.32.0`, por decisión expresa del propietario) y **2 de autoridad no acreditada** (`v1.31.0` y
   `v1.32.1`). Las **dos** están ahora ratificadas a posteriori, con fecha 2026-09-08 y por el
   propietario. El denominador se queda: un veredicto sin denominador no se puede desmentir leyéndolo.

**Por qué `mitigado` y no un estado a medias.** El residual que R-016 declaró era **uno y sólo uno**
—«la ratificación expresa del propietario sobre `v1.31.0`»— y está resuelto. Los seis puntos de
cumplimiento que R-016 verificó contra el árbol siguen en pie: la frontera **escrita**, **por
propiedad** en sus dos ejes, con **sitio único** citado y no transcrito, con su consecuencia dicha sin
suavizar, con condición de reactivación **medible**, escrita por quien no se beneficia, y `v1.32.1`
ratificada. No queda ninguna pieza de `SEC-053` esperando a nadie.

**Lo que este cierre NO hace — y aquí es donde conviene leer despacio.**

- **No despeja `v1.33.0`.** El veredicto de R-016 §7 —«la fusión, el tag `v1.33.0` y la publicación son
  decisión del propietario»— **se mantiene íntegro**. Lo único que cambia es una cifra: el recuento
  vigente pasa de **31** a **30** hallazgos de clase `contrato` abiertos, y `usuario/dinero` sigue en
  **0**. Bajo la frontera, **cualquier** recuento distinto de cero devuelve la decisión: **30 devuelve
  exactamente igual que 31.** Respecto a `SEC-053` **en particular**, y esto sí lo afirmo sin reservas:
  **este hallazgo ya no es una de las razones por las que `v1.33.0` no está cubierto.** Era una de 31;
  quedan 30, y tres de ellas apuntan a la publicación misma.
- **El 30 es aritmética sobre la lectura de R-016, no una medición nueva.** Sale de restar **una** fila
  al recuento de R-016 (`b199e08`, unión de las dos sedes). **No he re-medido** las dos sedes sobre
  `b7ed615` ni sobre el árbol de trabajo, y no debo: el punto 4 obliga a medir sobre **el commit que se
  etiqueta**, que hoy no existe. Quien vaya a publicar **re-mide**; este número no le sirve de
  acreditación. **Lo que sí hice es cuadrarlo con su propia lista**, porque un recuento que no cuadra
  con la suya no es un recuento: el índice de §2 queda con **28** filas de estado bloqueante —todo
  estado que no sea `mitigado` ni `aceptado`— y la unión con las **2** discrepancias declaradas
  (`SEC-014` y `SEC-052`, `mitigado` en el índice y aún declarados en campos) da **30**.
- **De los cuatro que apuntaban a la publicación misma quedan tres, los tres abiertos:** `SEC-050`,
  `SEC-054` y `SEC-055`. **Ninguno lo resuelve esta ratificación**, y no por casualidad: `SEC-054` dice
  que 1.33.0 publicaría una **acreditación firmada que la medición desmiente**, y `SEC-055` que
  `AGENTS.md` sigue prometiendo una delegación que **hoy no autoriza nada**. Son defectos de **otros
  textos**, no del criterio de publicación que `SEC-053` corregía.
- **Dos cosas vivían dentro de `SEC-053` y NO mueren con él. Van nombradas para que nadie las dé por
  cerradas al ver la fila en `mitigado`:**
  1. **La decisión de fondo «se acota o se retira la delegación» no era de `SEC-053` y sigue
     pendiente.** R-016 §3 dejó escrito que la delegación **no autoriza nada hoy**, que su condición de
     reactivación previsiblemente **no se va a cumplir** mientras este repositorio desarrolle su propio
     mecanismo, y que **retirarla es decisión del propietario, no del auditor**. Esa decisión vive en
     **`SEC-055`** —dueño `analista-requerimientos` para el write-back y **propietario** si la salida es
     retirarla—, `abierto`, con vencimiento en el cierre de `REQ-019`. Cerrar `SEC-053` **no la
     responde**.
  2. **La obligación viva pasa a ser de escritura, tag a tag.** El **punto 5** de la frontera exige
     **publicar el recuento** —la cifra, la lista de identificadores si no es cero, y el commit sobre el
     que se leyeron las dos sedes— en la entrada de `CHANGELOG.md` que anuncia el tag, y **una
     publicación sin ese recuento publicado no está acreditada, aunque el recuento hubiera sido cero**.
     Eso no lo cierra ninguna ratificación: se cumple o se incumple en cada publicación.
- **Y las dos discrepancias entre sedes siguen ahí, y por sí solas devuelven la decisión** aunque el
  recuento llegara a cero: `SEC-014` y `SEC-052` están `mitigado` en el registro y **siguen declarados**
  en los campos `Hallazgos abiertos:` de `REQ-013` y `REQ-023`. El write-back es del
  `analista-requerimientos`; `requirements/` no es mío y no los retiro yo.

**Línea base de no-regresión que `SEC-053` deja al cerrar.** Debilitar cualquiera de estas cinco
propiedades es **regresión de este hallazgo** —no un hallazgo nuevo— y se mide contra esta entrada:

(a) el criterio de publicación delegada dice **abierto dónde**, y lo dice **por propiedad**: por
**clase** y no por prefijo del identificador, y por el **complemento del cierre** y no por lista de
estados que abren;
(b) existe **una** sede exhaustiva de los hallazgos de clase bloqueante, y el criterio la **cita** en
vez de transcribirla —dos transcripciones de la misma regla se desfasan, y ésta ya se desfasó una vez—;
(c) el recuento se lee del **árbol del commit que se etiqueta**, no de la rama de trabajo ni de la
memoria de la sesión;
(d) la acreditación se hace **publicando el recuento**, no afirmando el resultado;
(e) la **falta** de acreditación no es un empate: **devuelve** la decisión al propietario, y la
discrepancia entre sedes también.

Volver a escribir «cualquier hallazgo abierto» **sin decir dónde** —en
`docs/gobernanza/autoalojamiento.md`, en `AGENTS.md`, en `CLAUDE.md` o en cualquier plantilla que los
proyectos hereden— es la regresión exacta que esta entrada existe para detectar.

### 2. Hallazgo nuevo, `instrumento` y por tanto **NO bloqueante**: la sede exhaustiva vive dentro de una revisión fechada

### SEC-056 — `instrumento` · **abierto** · severidad **media** · dueño `auditor-seguridad` (mío)

**El «Índice de hallazgos de clase bloqueante» —la sede que la frontera cita como sitio único— está
físicamente dentro de la entrada de una revisión fechada, en una bitácora cuya regla es no editarse
hacia atrás**

- **Ubicación:** el índice es §2 de la entrada `## Revisión R-016 … 2026-09-08` de este archivo. La
  frontera lo cita **por su encabezado** —«el «Índice de hallazgos de clase bloqueante» de
  `docs/seguridad/registro-seguridad.md`»—, no por sección ni por línea, y eso es lo único que hace el
  defecto barato de arreglar.
- **El defecto, medido hoy sobre mí mismo.** Para cumplir la regla de mantenimiento del propio índice
  —«cada revisión que abra, cierre o cambie de estado un hallazgo bloqueante actualiza el índice **en la
  misma revisión**»—, **esta** revisión ha tenido que editar una fila **dentro** de la entrada de R-016,
  que es escritura hacia atrás en una bitácora que declara no hacerla. Las dos reglas no pueden
  cumplirse a la vez mientras el índice viva ahí: o la fila envejece, o la entrada fechada se retoca.
- **Dirección del error, y es lo que le quita severidad.** Si la fila envejece, la regla de **unión +
  fail-closed** de la frontera hace que la desalineación **bloquee**: se falla hacia el lado que **no**
  publica. Por eso es `instrumento` y no `contrato` —ningún texto firmado promete un alcance que no
  tiene— y por eso **no condiciona ningún cierre**. **Ninguna máquina lee esto**: la frontera no es una
  puerta (su punto 6).
- **Remediación propuesta, NO aplicada hoy:** mover el índice a una sección propia de nivel `##`
  **fuera** de la secuencia de revisiones, con el encabezado **idéntico** para que la cita de la
  frontera siga resolviendo, y dejar en R-016 un puntero. No lo hago en esta revisión por coordinación y
  no por criterio: mover la sede única de la lista exhaustiva el mismo día en que se cierra una fila, y
  con una comisión viva en el árbol, mete dos cambios dentro de la misma medición.
- **Forzador:** la primera revisión que tenga que cambiar **dos o más** filas del índice, o cualquier
  reestructuración de este archivo —incluida su rotación—. **Vencimiento:** ventana 1.34.0. Va a deuda
  técnica con dueño, como manda su clase.
- **Lo digo también para que no se lea como inflar la cifra el día que cierro una fila:** este hallazgo
  **no entra en el índice** ni en el recuento, porque `instrumento` es la única clase que no cuenta. El
  recuento de hoy sigue siendo **30 `contrato` · 0 `usuario/dinero`** sobre la lectura de R-016.

### Rigor y estado de los REQ — R-017

**No subo ni bajo el rigor de ningún REQ, y no firmo ninguno.** Ninguna línea `QA:` ni `Seguridad:` se
toca en esta revisión. No audita código, así que **no puede acreditar nada construido**: el orden de
`AGENTS.md` §6 queda intacto y la auditoría del código de la ventana 1.33.0 va **después de QA**, en su
turno.

**Estado de seguridad aprobado — línea base de no-regresión: sin cambios.** Sigue vigente la de
**R-012** para `REQ-017` y para toda la capa de enforcement, con el ancla que R-016 volvió a medir por
objeto de árbol (`hooks/` = `88c146536f21fa03d3c8fdad8063b645fb0162bc`). **No la re-mido hoy**, y lo
digo para que nadie lea aquí una re-confirmación: esta revisión no lee `hooks/`. Para lo anterior,
R-009/R-008.

**`docs/seguridad/gobernanza-datos.md`: sin cambios, y por qué.** Esta ratificación no altera
clasificación de datos, acceso, retención ni cumplimiento, y este repositorio no maneja usuarios finales
ni datos personales. Nada que actualizar allí.

**Lo que esta revisión acredita.** Una sola cosa: que el residual único de `SEC-053` está resuelto por
decisión escrita del propietario del 2026-09-08, verificada donde está escrita, y que la fila pasa a
`mitigado`. **Lo que NO acredita, dicho para que nadie lo estire:** ninguna quality gate —no las miro, y
por eso firmo después de QA—; **ningún REQ**; el código de 1.33.0; ni el write-back de `SEC-031`, `032`,
`034`, `035` y `036`, que por eso siguen `en-mitigación`. Y **no despeja `v1.33.0`**: la fusión, el tag
y la publicación siguen siendo decisión del propietario, con **30** `contrato` abiertos, **dos**
discrepancias entre sedes y **tres** hallazgos que apuntan a la publicación misma.

---

## Revisión R-018 — **consulta de gobernanza: ¿admite el ciclo restante de REQ-014 un rigor menor que `critico`?** (no es auditoría de ningún REQ; no firma nada) — 2026-09-08

**Qué se me preguntó.** Si la comisión que queda de **REQ-014** —partir los tres archivos que exceden
su techo, y validar— puede correr con menos ceremonia que `critico`, dado que lo ya implementado
(`9809fc2`) es aritmético y estructural, está especificado desde datos medidos y ya lo verificó
independientemente la coordinadora, y dado que hay presión de tiempo nombrada por el propietario.

**Alcance de lo que leí.** `requirements/REQ-014.md` (cabecera, CA-12, CA-14, CA-18, CA-31, Notas y
Historial), `requirements/README.md` §«Nivel de rigor», `AGENTS.md` §6 y §13, `.arnes/config.json`,
`hooks/lib.sh:1905-1961` (`arnes_rigor_efectivo`), `hooks/guard-completado.sh:227-430`,
`PENDING_APPROVAL.md`, `git blame` de la cabecera del REQ, y una corrida propia de
`tests/escenarios/hooks/autoprueba-corredor.sh` para leer la tabla que publica CA-18.
**No escribí en `requirements/REQ-014.md`** (había una comisión de analista viva sobre ese archivo).

### Veredicto: NO. El ciclo restante se mantiene en `critico`, con auditoría después de QA

**No bajo el rigor, y tampoco lo subo: ya está en el suelo que le corresponde.** Ninguna línea `QA:`
ni `Seguridad:` de ningún REQ se toca en esta revisión.

### El criterio con el que lo decido — tres preguntas, y la tercera es la que zanja

**(1) ¿El cambio altera lo que una puerta deja pasar?** Sí, y directamente. La máquina de CA-18 decide
qué archivos de `secciones/` aprueban la autoprueba, y la autoprueba corre dentro de `hooks-en-linux`,
que es la **puerta requerida de `main`**. El carve-out editorial de `AGENTS.md` §6 —el único camino
para bajar rigor sin mi firma— exige «sin efecto en la máquina ni en lo que los proyectos heredan».
Falla en la primera condición. `AGENTS.md` §6 además declara `critico` **por categoría** exactamente
esta superficie (`tests/`, el banco que certifica el mecanismo).

**(2) Si yo no miro, ¿queda alguna máquina que cace la clase de defecto?** No, y las tres razones están
medidas:

- `codigo_app.globs` es `["hooks/*", "tools/*", ".github/*", ".arnes/config.json", ".claude-plugin/*"]`.
  **`tests/` no está** (`SEC-045`, abierto): `guard-codigo` no deniega a nadie sobre este código.
- **La máquina de CA-18 declara por escrito que no decide el término que la partición vuelve
  portante.** Comprueba aritmética —(a) que todos declaren `PISO_AUTONOMO_SECCION`, (b) que los
  términos sumen, (c) que el piso quepa— y publica las líneas duplicadas «sin compararlas». El término
  **bloque indivisible mayor** es, en palabras del propio criterio y del propio código
  (`tests/escenarios/hooks/autoprueba-corredor.sh:82-92`), «una afirmación sobre la estructura» que
  «ninguna máquina de este banco decide», de modo que «un piso inflado afloja el techo sin que ninguna
  puerta grite». Contra eso el REQ nombra **dos defensas y dice que ninguna es una puerta**: la
  derivación escrita, *«que un lector puede falsificar término a término»*, y la regla de procedimiento.
  **Ese lector es esta auditoría.** Quitarla deja una sola defensa, que es una frase.
- `veredictos.exigir_fecha` y `veredictos.caducan_con_codigo` están los dos en **`false`** en
  `.arnes/config.json` de este repositorio: ninguna puerta compara un veredicto contra la fecha del
  código que dice acreditar (ver `SEC-057`, abajo).

**(3) ¿Qué compra realmente el rigor menor?** Casi nada, y esto es lo que decide.

- **Mecánicamente no compra nada.** `Sensible a seguridad: sí` impone `critico` como **suelo**
  (`hooks/lib.sh:1938-1949`): escribir `Rigor: estandar` en esa cabecera **no baja nada**, la puerta lo
  vuelve a subir. Para bajarlo de verdad hay que escribir `Sensible a seguridad: no`, y esa afirmación
  la desmiente el propio REQ en sus Notas: *«Por qué es sensible a seguridad. El banco es lo que
  acredita que las puertas de runtime deniegan lo que dicen denegar»*. Eso no es bajar rigor: es
  escribir algo falso en un campo para obtener su efecto.
- **Y lo que compraría es peor que ahorrar un paso: sería una firma falsa.** La cabecera de REQ-014
  **ya lleva escrito** `QA: aprobado` y `Seguridad: aprobado` (`git blame`: `ca6047a2`, 2026-09-07;
  emitidos según este registro el **2026-09-06** sobre la redacción **anterior** de CA-18 y CA-12). El
  analista los dejó a propósito y los declaró nulos **en el Historial**, apoyando el bloqueo en que
  `DEV-014-01` y `DEV-014-02` son `contrato`. Consecuencia: saltarse mi turno **no** produce «REQ-014
  cerrado sin firma de seguridad»; produce **REQ-014 cerrado llevando mi firma sobre código que no
  existía cuando la emití**. Y el único cerrojo que hoy lo impide es la clase de esos dos hallazgos,
  cuyo cierre o reclasificación CA-31 (c) pone en manos de **QA**: una acción de otro rol y la firma
  caduca pasa a ser la firma de cierre, sin que ninguna puerta objete.

### Sobre la vía `preventiva`: tampoco

`AGENTS.md` §6 la define como revisión hecha **antes de que exista el código**, declarada **al
emitirla**, *«nunca al invocarla: una excepción que se inventa cuando hace falta no es una excepción,
es una salida»*. El código existe y está comiteado (`9809fc2`: +297 en `autoprueba-corredor.sh`, +102
en `inventario.sh`, declaración de piso en las 45 secciones), y la partición añadirá más. Emitir
`preventiva` sobre este árbol sería usar la excepción nombrada como la salida que ella misma prohíbe.

### Aritmética verificada por mí, que es lo que sostiene el «no» sin apelar a la prudencia

Corrida propia de la autoprueba, tabla publicada por CA-18 (medición del 2026-09-08 sobre
`cand/1.33.0`; cifras **operativas**):

| archivo | líneas | piso | techo | gobierna | duplicadas |
|---|---|---|---|---|---|
| `37-coste-del-escaner-1-escala.sh` | 849 | 461 | **577** | `piso×k` | 150 |
| `37-coste-del-escaner-2-la-seccion-caliente.sh` | 679 | 468 | **585** | `piso×k` | 135 |
| `38-sondas-compartidas.sh` | 828 | 133 | **400** | `N` | 141 |

Resultado: **105 PASS / 1 FAIL**, y el FAIL es el negativo de CA-18 nombrando los tres archivos con su
tamaño y su techo. Reproduce lo que la coordinadora verificó.

**(a) La sorpresa de las tres piezas en `38` es real, y sale de la aritmética, no del criterio.** Su
piso es 133 (19 + 36 + 78) y por tanto su techo lo gobierna `N` = **400**. Dos mitades autónomas
duplican preámbulo + maquinaria (55 líneas): 828 + 55 ≈ 883 ⇒ **≈ 441 cada una**, las dos fuera. Con
tres: 828 + 110 ≈ 938 ⇒ **≈ 313 cada una**, conformes. **Confirmo el hallazgo del desarrollador de
forma independiente: dos archivos es infactible, tres es la primera partición conforme.**

**(b) Y hay un número que decide la partición de `37/1` y que NADIE ha medido — es el que va a llegar
a mi turno.** Partir `37/1` en dos duplica 149 líneas: 849 + 149 ≈ **998**. La mitad que se queda el
bloque indivisible de 312 tiene piso 461 y techo 577; con la mitad-A medida en **564**, la mitad-B
queda en **≈ 434**, y su techo es `max(400, piso_B×1,25)`: conforme **sólo si `piso_B ≥ 348`**, es
decir sólo si B contiene un bloque indivisible de **≈ 199 líneas o más**. Ese número **no está medido
en ninguna parte**, y la derivación de `k` = 1,25 del criterio cita **únicamente mitades A**
(`564/460`, `467/467`, `516/460`, `511/467`): **ninguna mitad B aparece en la derivación del literal
que las va a juzgar**. Hay salida conforme —partir `37/1` en **tres**, ≈ 285 por archivo además de la
mitad del bloque— pero también hay una salida barata y equivocada: **declarar `piso_B` alto para
caber**, que CA-18 califica por su nombre como **regresión** que devuelve el hallazgo a `contrato`, y
que las comprobaciones (a)(b)(c) de su máquina **dan por buena** si los términos suman. Es la misma
clase que `DEV-014-01` —un término derivado sin comprobar su factibilidad— un nivel más abajo, y bajo
presión de tiempo es exactamente el atajo disponible.

**(c) `37/2` sí cabe en dos:** 679 + 125 ≈ 804, con A = 467 (piso 468, techo 585) y B ≈ 337 ≤ 400.

### Alcance de la auditoría que haré en mi turno — nombrado ahora, para que no cueste tiempo de reloj

No voy a re-auditar REQ-014 entero. Lo que mi firma va a exigir, y que el `desarrollador` y el
`qa-tester` pueden preparar como evidencia desde ya:

1. **La verdad de cada `PISO_AUTONOMO_SECCION`** de todo archivo que la partición cree o toque,
   falsificada término a término contra el texto — es la defensa que la máquina declara no ser. Con
   `piso_B` de `37/1` medido y escrito.
2. **CA-12 / CA-13 bajo el oráculo**: cero líneas suprimidas o modificadas, toda adición atribuida
   nombrando su REQ, y los **tres** negativos (suprimido, renombrado, veredicto invertido) nombrando el
   cambio.
3. **No-regresión de controles** contra la línea base de **R-004/R-009**: el «límite honesto» de CA-06
   sigue escrito, el canario sigue **antes** del descubrimiento (CA-09), CA-22 (i) en sus **dos**
   mitades (`git diff v1.31.0 -- hooks/` vacío **y** `git status --short -- hooks/` vacío), y ni
   `continue-on-error` ni CA-18 fuera del CI (CA-18 (ii) lo prohíbe por nombre).
4. **Los dos veredictos re-emitidos con fecha posterior al 2026-09-08** y los **dos ADR** de CA-31 (d)
   existentes y enlazados.

### SEC-057 — `instrumento` · **abierto** · severidad **media** · dueño `desarrollador` (el manifiesto) y **propietario** (el gate de §6)

**Un REQ reabierto conserva sus veredictos viejos legibles-como-válidos: el arnés construyó la puerta
para exactamente esto y no la tiene encendida sobre sí mismo**

- **Ubicación.** `.arnes/config.json` → `veredictos.exigir_fecha: false`, `veredictos.caducan_con_codigo: false`,
  contra `requirements/REQ-014.md:8-9` (`QA: aprobado` / `Seguridad: aprobado`, sin fecha, emitidos el
  2026-09-06 sobre la redacción anterior de CA-18 y CA-12) y `requirements/REQ-014.md` CA-31 («los
  veredictos que cierren este REQ tienen que ser **posteriores al 2026-09-08**»).
- **Lo medido.** La `REGLA DE ESTADO` de `AGENTS.md` §9 devuelve el REQ a `en-progreso` y el analista
  declara los dos veredictos nulos **en el Historial**, correctamente y por la razón correcta (no
  reescribe el veredicto de otro rol). Pero la cabecera es lo que leen **la puerta** y **cualquier
  lector que no baje al Historial**, y ahí siguen diciendo `aprobado`. Con las dos claves en `false`,
  `guard-completado` acepta `Seguridad: aprobado` sin mirar ni su fecha ni el commit que tocó el
  código. La condición de CA-31 es **prosa que ninguna puerta lee**. Hoy el cierre lo impide **sólo**
  la clase `contrato` de `DEV-014-01`/`DEV-014-02`, cuya reclasificación CA-31 (c) asigna a **QA**:
  un cerrojo de un solo punto, en manos de otro rol, para una firma que es mía.
- **Riesgo.** Toda reapertura futura de este repositorio hereda la misma exposición: un REQ puede
  cerrar acreditado por una firma que nadie emitió sobre el árbol que cierra. Es la clase de regresión
  silenciosa que `AGENTS.md` §9 nombra, en el artefacto que la vigila.
- **Por qué `instrumento` y no `contrato`.** El defecto es del mapeo de este repositorio sobre sí
  mismo, no de un requerimiento que afirme algo falso sobre lo construido: `templates/` trae las claves
  apagadas por decisión documentada y deliberada, y ningún proyecto instalado nota nada. **No bloquea
  el cierre de REQ-014**, y lo digo explícitamente para que nadie lea aquí un blocker nuevo: la
  instancia concreta la resuelve el ciclo normal cuando QA y yo re-emitimos con fecha.
- **Remediación.** (1) Encender `veredictos.exigir_fecha` y `veredictos.caducan_con_codigo` en
  `.arnes/config.json`; el propio `_doc` de la clave advierte que antes hay que medir con
  `tools/arnes-lectura.sh` cuántos veredictos ya firmados llevan fecha, porque los que no la lleven no
  volverán a cerrar hasta re-validarse — esa medición es parte de la remediación, no un obstáculo a
  ella. (2) Es cambio del manifiesto: `codigo_app.globs` lo reserva al `desarrollador` y `AGENTS.md`
  §6 lo pone entre los **gates humanos**, así que va con entrada en `PENDING_APPROVAL.md` antes de
  tocarlo. (3) **Write-back (`analista-requerimientos`):** el control queda como criterio/NFR con la
  propiedad —«un veredicto `aprobado` no cierra si es anterior al último cambio del código que
  acredita»— citando `.arnes/config.json` como sitio único de la configuración; mientras viva sólo en
  el manifiesto y en este registro es deriva (`AGENTS.md` §9), y **no cierro este hallazgo** hasta que
  exista.

### Rigor y estado de los REQ — R-018

**No subo ni bajo el rigor de ningún REQ.** REQ-014 se queda en `critico`, que es además su **suelo**
por `Sensible a seguridad: sí`. **No firmo nada:** esta revisión no audita código, no mira quality
gates y no acredita nada construido; el orden de `AGENTS.md` §6 queda intacto y la auditoría del
código de REQ-014 va **después de QA**, en su turno, con el alcance de arriba.

**Estado de seguridad aprobado — línea base de no-regresión: sin cambios.** Sigue vigente la de
**R-004/R-005/R-009** para `REQ-014` (`aprobado`, 2026-09-06, candidata 1.32.0) **con la advertencia
de que esa línea base ya no cubre el árbol de 1.33.0**: es precisamente contra ella contra la que
compararé en mi turno. Para `REQ-017` y la capa de enforcement sigue la de **R-012**, con el ancla de
`hooks/` que R-016 re-midió; **no la re-mido hoy**.

**`docs/seguridad/gobernanza-datos.md`: sin cambios.** Esta consulta no altera clasificación de datos,
acceso, retención ni cumplimiento, y este repositorio no maneja usuarios finales ni datos personales.

---

## Revisión R-019 — **firma de REQ-014**: auditoría del código de la reapertura, **después** de QA, ventana 1.33.0 (`cand/1.33.0` @ `d4e0033`) — 2026-09-08

**Orden y legitimidad de la firma.** `QA: aprobado (2026-09-08)` está emitido sobre este árbol
(`requirements/REQ-014.md:8`, evidencia en `docs/qa/1.33.0.md:3042`), así que el orden de
`AGENTS.md` §6 está satisfecho y esta firma acredita lo que dice acreditar: la revisión de
seguridad, no las quality gates —que no son mías y no miré—.

### 0. Renumeración: había DOS `R-018` y DOS `SEC-057` distintos, y el REQ citaba un identificador ambiguo

La auditoría del 2026-09-08 se emitió en el worktree aislado `work/req014-codex` y numeró contra
la copia archivada de este registro, que no incluía la consulta de gobernanza que se escribió en
paralelo. Resultado medido antes de tocar nada (`grep -n '^## Revisión R-'` y
`grep -o 'SEC-[0-9]\{3\}' | sort -u`): última revisión **R-018**, último hallazgo **SEC-057**,
5 488 líneas. `SEC-999` no es hallazgo: es el control negativo del banco.

| Worktree | Aquí | Sujeto |
|---|---|---|
| `R-018` | **`R-019`** | esta revisión |
| `SEC-057` | **`SEC-058`** | el piso autodeclarado sin cota superior |
| `SEC-058` | **`SEC-059`** | el «≈424» que no se derivaba de sus términos |
| `SEC-059` | **`SEC-060`** | el «42 de 45» que sobrevive dentro de la máquina |
| `SEC-060` | **≡ `SEC-057` ya existente** | *no recibe número nuevo*: es **el mismo hallazgo** que el `SEC-057` de este registro (veredictos viejos legibles-como-válidos, con las dos claves de `veredictos.*` apagadas). Dos identificadores para un hallazgo son la misma ambigüedad que esta sección viene a cerrar |
| `SEC-061` | **`SEC-061`** | el hueco de `R-005` (`mitigado`) |
| — | **`SEC-062`**, **`SEC-063`** | nuevos de esta revisión |

**Por qué importaba y no era cosmético:** `requirements/REQ-014.md:10` declaraba `SEC-057
(instrumento)` en el campo que gobierna el cierre. `guard-completado` lee la **clase** y pasa; un
humano no podía saber a cuál de los dos hallazgos se refería. Corregido en esta revisión.

### 1. Rigor: no se repite lo ya medido

La excepción de rigor de `docs/gobernanza/autoalojamiento.md` §«Excepción medida» **no aplica**
—falla 2 de 3 condiciones, medido en **R-018** §1— y `REQ-014` se queda en **`critico`**, que es
además su **suelo** por `Sensible a seguridad: sí`. **No subo ni bajo el rigor de ningún REQ:**
aquí no hay nada que subir, ya está en el techo.

### 2. CA-18 re-derivado sobre los **50** archivos, por mí y no por lectura del write-back

Replicado con un recorrido propio sobre `tests/escenarios/hooks/secciones/*.sh`, sin ejecutar el
banco y sin escribir en el árbol. Resultados, que **coinciden dígito a dígito** con lo que declara
`requirements/REQ-014.md:106`:

| Magnitud | Medido |
|---|---|
| Archivos de sección | **50** |
| Gobernados por `N` = 400 | **48** |
| Gobernados por `piso × k` | **2** |
| Que exceden su techo | **0** |
| Declaraciones cuyos términos **suman** el piso | **50 de 50** |
| Declaraciones con `nterm ≥ 3` (no ILEGIBLE) | **50 de 50** |
| `piso > líneas` | **0** |

Los dos gobernados por `piso × k` son `37-coste-del-escaner-1-el-dominio.sh` (577 líneas, piso 470,
techo 588) y `37-coste-del-escaner-4-la-ruta-critica.sh` (468, piso 463, techo 579).

**`k` sigue valiendo 1,25 después de la partición, y lo comprobé porque CA-18 obliga a re-derivarlo
cuando cambia la mejor partición medida.** El mayor cociente `líneas/piso` entre los archivos que
gobierna el piso es **577/470 = 1,2277**, que redondeado al siguiente múltiplo de 0,05 da **1,25**:
**`k` no cambia**. *(Observación para el `analista-requerimientos`, y no es hallazgo: el texto de
`REQ-014.md:96` sigue citando `565/461 = 1,2256`, que es el cociente **previo** a la partición. El
resultado es el mismo y la cifra está marcada como medición fechada, pero CA-18 pide la
re-derivación «en la misma edición que cambia ese término» y esa entrada de Historial no está. Una
línea la cierra.)*

### 3. El techo **no** se compró inflando el piso — que es lo que `SEC-058` obliga a comprobar a mano

`SEC-058` mide que el techo de un archivo depende de un número que ese mismo archivo declara sobre
sí mismo, sin cota superior de máquina. Su remediación 1 es un **control de procedimiento**: el
verde de CA-18 no acredita que un archivo quepa, y la derivación la verifica **quien no la
escribió**. Lo ejerzo aquí, sobre los únicos dos archivos cuyo techo depende del piso:

- `37-coste-del-escaner-1-el-dominio.sh`: piso **470** (38 + 120 + 312). Su antecesor
  `37-coste-del-escaner-1-escala.sh` declaraba **461** (27 + 122 + 312) en `9809fc2`. El término que
  sube es el **preámbulo** (27 → 38), que es exactamente lo que CA-18 (ii) predice al partir. **Y la
  conformidad no depende de la subida:** con el piso **viejo** el techo sería 577 y el archivo mide
  **577** ⇒ conforme igual. El techo no está comprado.
- `37-coste-del-escaner-4-la-ruta-critica.sh`: piso **463**, **por debajo** del 468 de su antecesor.
  Un piso que **baja** no compra nada.

Ningún otro de los 50 tiene el techo gobernado por su piso, así que en ninguno más puede la
declaración comprar conformidad. **La remediación 1 de `SEC-058` queda ejercida para esta
partición**; la propiedad de máquina (remediación 3) sigue abierta y con vencimiento en 1.34.0.

### 4. La vía por la que esta partición podía haber roto el aislamiento: medida, y está limpia

Partir una sección en tres crea la ocasión de que las partes se pasen estado, que es lo que **CA-19**
prohíbe («ninguno hace `source` de otro archivo de sección, **ni depende del estado que otro
deje**»). Es la mitad de CA-19 que la autoprueba **no** mide —comprueba `source`, no el estado—, así
que se comprueba leyendo. Medido:

- **Ninguna** sección hace `source` ni `.` de otra (`grep` sobre los 50 archivos: cero).
- `38-sondas-compartidas-2-la-calibracion.sh:29-32` y `-3-la-descendencia.sh:24-25` **leen**
  `$RAIZ/cal-reloj`, `cal-procesos`, `testigo-reloj` y `testigo-procesos`. **Los produce el
  corredor**, no otra sección: `tests/escenarios/hooks/run.sh:1138-1141`; y **ninguna** sección los
  escribe (`grep '> *"\?\$RAIZ/\(cal-\|testigo-\)' secciones/*.sh` sale vacío). Es dependencia **del
  corredor hacia abajo**, que es la única que CA-19 admite. **No hay violación.**
- Temporales: los seis archivos nuevos derivan sus rutas de `$RAIZ/...-$BASHPID`. La partición
  **duplicó** plantillas entre archivos que corren **en paralelo** —`her37-321-$BASHPID` vive ahora
  en `37-…-1-el-dominio.sh:155` y en `37-…-3-la-pared.sh:135`—, y lo único que impide la colisión es
  el sufijo por proceso. **Correcto hoy y no es hallazgo**, pero queda escrito porque es la clase que
  ya costó texto humano en 1.32.0 (temporal de nombre fijo, REQ-015): *toda plantilla de temporal
  duplicada entre secciones tiene que conservar su sufijo por proceso*, y ninguna puerta lo mide.
- Barrido de los seis archivos nuevos: sin `eval` sobre entrada no confiable, sin red
  (`curl`/`wget`/`nc`/`ssh`), sin escrituras fuera de `$RAIZ`, sin `rm -rf` sobre ruta no derivada
  del temporal de la corrida.

### 5. Regresión de enforcement — con una **corrección a `R-018` §4**

`R-018` §4 afirmó que `hooks/`, `tools/`, `.github/` y `.arnes/config.json` no cambiaban. Sobre el
árbol de hoy (`9809fc2` → `d4e0033`) eso es cierto para los tres primeros —**cero** archivos— y
**falso para el cuarto**: `.arnes/config.json` **sí** cambió. Leído el diff completo, el cambio es
**una línea**, `arnes_version` `1.32.1` → `1.33.0` (commit `d01aea1`, junto con `plugin.json` y
`marketplace.json`, los tres coherentes en `1.33.0`). **Ninguna clave de política se toca**:
`agentes`, `codigo_app.globs`, `quality_gates`, `veredictos`, `git.prohibidos` y `rotacion` quedan
idénticas. No hay debilitamiento de ningún control acreditado en `R-001`…`R-018`.

**Anclas.** `hooks/` no cambia desde `9809fc2` (cero archivos). Respecto de **v1.31.0** sí difiere —5
archivos, +489 líneas— y **ninguna** de esas líneas es de `REQ-014`: vienen de `973448f` (1.32.1,
REQ-015) y `ed56f9a` (REQ-017). La sustancia de CA-22 —«este REQ no toca el mecanismo»— **se
cumple**; lo que no se cumple es su forma literal, y eso es `SEC-062`.

**Barrido de secretos** sobre las 3 603 líneas añadidas del delta: **cero** patrones de credencial,
clave privada o token. Ningún archivo de secretos rastreado.

### 6. Hallazgos

#### SEC-058 — **El techo de CA-18 lo decide el sujeto: `piso` autodeclarado sin cota superior** · `instrumento` · severidad **alta** · **abierto** *(era `SEC-057` en el worktree)*

Texto íntegro, demostración sobre el código real y remediación en tres puntos: se conserva tal como
se emitió, y **no se relaja**. Ubicación:
`tests/escenarios/hooks/autoprueba-corredor.sh:93-160` (`ca18_deriva()`) y las **50** —ya no 45—
líneas `PISO_AUTONOMO_SECCION=` de `tests/escenarios/hooks/secciones/`; contrato en
`requirements/REQ-014.md` CA-18 §«Cómo se obtiene `piso(f)`» y §«Límite honesto».

**Estado tras esta revisión:**
- **Remediación 1 (control de procedimiento): EJERCIDA** para la partición de `b9afa01` — §3 de esta
  revisión, por quien no escribió la derivación. La conformidad de los 50 archivos **no** está
  comprada. Esto no cierra el hallazgo: lo cierra sólo para **esta** partición, y la próxima vuelve a
  necesitar la verificación a mano hasta que exista la remediación 3.
- **Remediación 2 (write-back del «Límite honesto»): NO HECHA**, y el analista la declara fuera de
  alcance por escrito en `requirements/REQ-014.md:546`, junto con `H-15`, que pide lo mismo. El
  criterio sigue nombrando **un** término no verificable cuando son **tres**, y describe la
  exposición como «afloja el techo» cuando lo medido es *existe un valor declarable que hace conforme
  a cualquier archivo con las cuatro comprobaciones en verde*. **Vencimiento incumplido:** decía
  «antes de que la partición se dé por acreditada», y la partición ya está acreditada. Se re-fija en
  **la próxima edición de CA-18, sea cual sea su causa**.
- **Remediación 3 (propiedad de máquina): abierta**, vencimiento **1.34.0**, dueño `desarrollador`.

**Por qué no bloquea, dicho explícitamente para que nadie lo lea como un sello.** Es `instrumento`
por la letra de `AGENTS.md` §6 y entra en la regla de acumulación del propietario del 2026-09-08. Mi
firma de abajo **no** dice que CA-18 sea inatacable: dice que **este** árbol no la atacó, y eso lo
medí.

#### SEC-059 — **El «≈424» de la sección 38 no se derivaba de sus términos** · `contrato` · severidad media · **MITIGADO (2026-09-08)** *(era `SEC-058` en el worktree)*

**Verificado sobre el árbol, no sobre el texto del write-back.** La declaración previa a la
partición, `9809fc2:tests/escenarios/hooks/secciones/38-sondas-compartidas.sh:18`, dice
`PISO_AUTONOMO_SECCION=133  # 19 preámbulo + 36 maquinaria compartida duplicada + 78 bloque
indivisible mayor` ⇒ coste de duplicación por archivo extra `19 + 36 = **55**`, dos mitades
`828 + 55 = 883` ⇒ la mayor **≥ 442**. El analista corrigió la cifra a **≈442** con esa derivación
escrita y dejó dicho que la conclusión no dependía de ella (`requirements/REQ-014.md:104`, Historial
`:543`). **Y el árbol real la confirma por el otro lado:** la partición en tres da 198 + 327 + 351 =
**876** líneas, máximo **351 < 400** ⇒ cabe; y el crecimiento real por duplicación fue **48 líneas en
total**, con lo que dos mitades habrían dado (828 + 48)/2 = **438 > 400** ⇒ tampoco cabían. La
predicción era **conservadora** y la conclusión se sostiene por las dos vías. **Cerrado.**

#### SEC-060 — **«42 de 45» sobrevive dentro de la máquina** · `instrumento` · severidad baja · **abierto, y hoy MÁS desmentido** *(era `SEC-059` en el worktree)*

`tests/escenarios/hooks/autoprueba-corredor.sh:558` sigue diciendo «(42 de 45 el 2026-09-08)». El
archivo **no se tocó** entre `9809fc2` y `d4e0033`, así que el comentario ha sobrevivido a la
partición y ahora está desmentido **dos veces**: el reparto real es **48 de 50**, medido en §2 por la
propia función que vive tres líneas más abajo. El vencimiento era «cierre de 1.33.0» y se está
consumiendo. **Dueño:** `desarrollador`. **Remediación:** sustituir la cifra por la propiedad —el
reparto lo publica `ca18_deriva()` en cada corrida— o fecharla como medición. Se corrige en la
próxima comisión que abra ese archivo; no bloquea.

#### SEC-057 (existente) — **veredictos viejos legibles-como-válidos** · `instrumento` · **abierto**, con la instancia de `REQ-014` **resuelta**

El `SEC-060` del worktree es **el mismo hallazgo** y se refunde aquí en vez de recibir número nuevo.
Estado tras esta revisión:

- **La instancia concreta está resuelta.** `QA:` se re-emitió **fechado** el 2026-09-08 sobre el árbol
  nuevo (`requirements/REQ-014.md:8`) y `Seguridad:` se re-emite **fechado** en esta revisión. Ya no
  queda ningún veredicto de 1.32.0 acreditando el árbol de 1.33.0, que era lo que hacía `contrato` a
  la mitad del hallazgo. **Esa mitad se cierra.**
- **El mecanismo sigue apagado y el hallazgo sigue abierto.** `.arnes/config.json` →
  `veredictos.exigir_fecha: false`, `veredictos.caducan_con_codigo: false`. Encenderlo es cambio del
  manifiesto ⇒ `codigo_app.globs` + gate humano de `AGENTS.md` §6, y está **aplazado a 1.34.0 por
  decisión del propietario**, registrada en `docs/PENDIENTES.md`. **El aplazamiento me parece
  aceptable y digo por qué:** la coordinadora midió que encenderlo hoy no bloquearía ningún cierre
  pendiente —20 de 25 `aprobado` en cabecera llevan fecha; de los 5 sin ella, 4 están en REQ
  `completado` que no vuelven a transicionar—, así que el coste del aplazamiento es una **ventana** de
  exposición conocida y acotada, no una exposición indefinida. Con esa medición sobre la mesa,
  aplazarlo a la ventana siguiente es una decisión informada del propietario y no la contradigo.
- **Y no firmo sobre un control que viva sólo en el registro.** Para **este** REQ el control existe
  como criterio: `requirements/REQ-014.md:136` (CA-31) exige que los veredictos que lo cierren sean
  **posteriores al 2026-09-08**, y los dos lo son. Lo que falta es el control **general**, que es la
  remediación 3 de este hallazgo (write-back del `analista-requerimientos`) y sigue pendiente con el
  encendido de 1.34.0.

#### SEC-061 — **hueco de `R-005` en la numeración de este registro** · `instrumento` · severidad baja · **mitigado**

Sin cambios: `R-005` ≡ la sección «Re-verificación de R-004 …» de la línea 1190. La regla para
adelante —toda revisión abre con su número— se aplica en esta misma sección (`R-019`) y es también lo
que habría evitado la colisión de §0.

#### SEC-062 — **CA-22 fija su línea base en un tag congelado, y la ventana ya pasó por encima: su prueba literal sale ROJA sobre un árbol correcto** · `instrumento` · severidad **media** · **abierto** *(nuevo)*

**Ubicación.** `requirements/REQ-014.md:122` (CA-22, mitad **(i)**); misma clase en `:132` (CA-29,
que fija el literal `1.32.0`) y en la mitad **(ii)** de CA-22 para el ritual de versión.

**Lo medido.** CA-22 (i) exige que «`git diff v1.31.0 -- hooks/` es **vacío** **y** `git status
--short -- hooks/` no muestra ninguna entrada». Sobre `d4e0033`: `git status` sale **vacío** ✔, pero
el diff contra `v1.31.0` da **5 archivos y +489 líneas** (`campos-req.awk`, `estado-derivado.sh`,
`guard-completado.sh`, `lib.sh`, `rotar-artefactos.sh`). **Ninguna es de `REQ-014`**: vienen de
`973448f` (1.32.1 / REQ-015) y `ed56f9a` (REQ-017). Añádase que `.claude-plugin/*` y
`.arnes/config.json` cambiaron en `d01aea1` **sin nombrar REQ alguno**, porque son el **ritual de
versión** y no pertenecen a ningún REQ — forma que CA-22 (ii) («cada cambio queda atribuido
**nombrando el REQ que lo trae**») no contempla; y que CA-29 exige leer `1.32.0` donde el árbol dice
`1.33.0`.

**Riesgo, y su dirección.** Falla hacia el lado que **cierra**, no hacia el que abre: produce un
**rojo sobre código correcto**. Es exactamente la clase que este mismo REQ nombra como dañina en
CA-18 (i) —«la clase de rojo que ya produjo **H-11** y la que enseña a desactivar el control»— y la
que `AGENTS.md` §13 resume en «un guard apagado protege menos que uno parcial». Un auditor futuro que
re-corra CA-22 al pie de la letra concluirá que el mecanismo se tocó, y el modo de fallo probable no
es que lo investigue: es que descuente el criterio.

**Y es media, no baja, por un motivo concreto:** la mitad **(ii)** de CA-22 **ya recibió esta misma
corrección** por `H-09` —el texto lo explica: exigir el diff vacío «le atribuía a este REQ una
propiedad del **árbol entero** de una ventana que comparte con REQ-012 y REQ-013»—. Se arregló la
mitad de `tools/` y se dejó intacta la de `hooks/`, que el propio criterio llama «lo que este control
de verdad protege». El defecto ya estaba diagnosticado y se corrigió sólo donde se había manifestado.

**Remediación (dueño `analista-requerimientos`), por propiedad y no por lista.** CA-22 (i) adopta la
misma forma que ya tiene (ii): lo exigido no es un diff vacío contra un tag congelado, sino que
**ningún cambio bajo `hooks/` sea atribuible a este REQ**, con la atribución citada al **único sitio**
donde vive —el campo `Archivos:` de cada REQ— y admitiendo explícitamente el **ritual de versión**
como origen sin REQ. CA-29, cuyo sujeto es un commit pasado, se marca como **medición fechada** para
que un cierre no la lea como prueba viva. **No bloquea** el cierre de `REQ-014`: la **sustancia** del
control está verificada en §5 de esta revisión por la vía correcta, y lo que falla es el instrumento.

#### SEC-063 — **`.gitignore` no cubre `.env*`** · `instrumento` · severidad **baja** · **abierto** *(nuevo)*

**Ubicación:** `.gitignore` (cubre `.mcp.json`, `.claude/settings.local.json`, `memory/`, `insumos/`,
`mejoras-arnes-*.md`, `node_modules/`, `.arnes-initialized`; **no** `.env*`).

**Lo medido:** ningún archivo `.env` ni de credenciales está rastreado hoy (`git ls-files`: cero), y
este repositorio no tiene runtime de aplicación ni usuarios finales, así que **la exposición actual es
nula**. Se registra porque el repositorio es **público** y el modo de fallo es un `git add -A`
distraído durante una prueba local —el mismo que el propio `.gitignore` advierte en su cabecera para
otros artefactos—. **Remediación:** una línea, `.env*` (con la negación de `.env.example` si se
quiere versionar un ejemplo). **Dueño:** `desarrollador`. **Vencimiento:** cualquier comisión que abra
`.gitignore`; no bloquea nada.

### 7. Lo que esta revisión NO miró — tabulado como NO MIRADO, nunca como PASA

| No mirado | Por qué |
|---|---|
| **Quality gates y ejecución del banco** | No son mías (`AGENTS.md` §6). No ejecuté `run.sh` ni la autoprueba: el positivo `106 PASS · 0 FAIL` y los seis negativos son de QA (`docs/qa/1.33.0.md:2780`, `:2812`) y los **cito**, no los re-mido |
| **El oráculo de CA-12 en `inventario.sh`** | Su propiedad, sus tres negativos y la dirección de su error siguen sin auditarse por mí más allá de comprobar que el archivo no cambió desde `9809fc2`. Lo validó QA |
| **La identidad byte a byte de los inventarios 45 ↔ 50** | Es medición de QA (884 líneas, cero suprimidas/modificadas). No la repliqué |
| **Los criterios de `REQ-014` fuera de CA-18, CA-19, CA-22, CA-29 y CA-31** | Fuera del alcance de esta comisión |
| **`CHANGELOG.md`, `docs/PENDIENTES.md`, `docs/ESTADO.md` y los demás REQ** | Excluidos por la comisión para acotar coste de contexto. Lo que necesité de `PENDIENTES.md` (el aplazamiento de `veredictos.*` a 1.34.0) lo tomo **de la comisión**, no de lectura propia, y queda dicho aquí que no lo verifiqué en su archivo |
| **La cola de aprobaciones y los tags** | Sí comprobados, y son lo único que miré fuera del alcance: `PENDING_APPROVAL.md` tiene **0** entradas bajo `## Pendientes` y `v1.32.0` existe (CA-31); `v1.33.0` **no** existe todavía, que es lo correcto antes de publicar |

### 8. Estado de seguridad aprobado por REQ — línea base de no-regresión, actualizada en R-019

| REQ | Veredicto | Fecha | Alcance acreditado | Nota |
|---|---|---|---|---|
| **REQ-014** (reapertura 1.33.0) | **`aprobado`** | 2026-09-08 | `cand/1.33.0` @ `d4e0033` — partición `b9afa01`, bump `d01aea1`, write-back `516e849`, confirmación de QA `d4e0033` | **Qué acredita:** que CA-18 se re-deriva correctamente sobre los 50 archivos (§2), que la conformidad **no** se compró inflando ningún piso (§3), que la partición **no** creó dependencia entre secciones y CA-19 se cumple en sus **dos** mitades (§4), y que el mecanismo (`hooks/`, `tools/`, `.github/`) no cambió, con la corrección de que `.arnes/config.json` sí lo hizo y **sólo** en su literal de versión (§5). **Qué NO acredita:** las quality gates ni la ejecución del banco (§7). **Residual declarado:** `SEC-058` (`instrumento`, alta) sigue abierto — el techo de CA-18 es atacable por el sujeto; medí que **este** árbol no lo atacó, no que sea inatacable |
| **REQ-014** (1.32.0) | `aprobado` | 2026-09-06 | `R-004`/`R-005`/`R-009` | **No se retira:** cubre el árbol de entonces. Deja de ser la línea base vigente: la sustituye la fila de arriba |
| **REQ-017** y capa de enforcement | `aprobado` | 2026-09-07 | `R-012`, ancla re-medida en `R-016` | Sigue vigente. En esta revisión re-anclada por el otro lado: `hooks/` no cambia desde `9809fc2` |

**Rigor:** `REQ-014` se queda en **`critico`**. No subo ni bajo ninguno.

**Hallazgos que esta revisión deja abiertos en `REQ-014`:** `SEC-057` (`instrumento`), `SEC-058`
(`instrumento`), `SEC-060` (`instrumento`), `SEC-062` (`instrumento`). **Cerrado:** `SEC-059`
(`contrato`) → `mitigado`. **Ninguno de mis hallazgos es ya de clase `contrato`.** Los anteriores del
REQ —`H-03`, `H-07`, `H-12`, `SEC-019`, `H-14`, `H-15`, `H-16`— **no se tocan, no se cierran y no se
reclasifican**: no son míos. `SEC-061` y `SEC-063` no son de `REQ-014` y no entran en su campo.

**Numeración vigente tras esta revisión:** última revisión **R-019**; último hallazgo **SEC-063**;
próximos libres **R-020** y **SEC-064**.

**`docs/seguridad/gobernanza-datos.md`: sin cambios.** Esta revisión no altera clasificación de datos,
acceso, retención ni cumplimiento; este repositorio sigue sin manejar usuarios finales ni datos
personales, y el único apunte de higiene (`SEC-063`) es preventivo.

---

## Revisión R-020 — **firma de REQ-017**: auditoría del código de la reapertura de `CA-08 (ii)`, **después** de QA, ventana 1.34.0 (`rel/registro-1.33.0` @ `ef94cb5`, código en `538c266`) — 2026-09-08

**Orden y legitimidad de la firma.** `QA: aprobado (2026-09-08 … sobre 538c266)` está emitido sobre
este árbol (`requirements/REQ-017.md:7`, evidencia en `docs/qa/1.34.0.md`), así que el orden de
`AGENTS.md` §6 se cumple y esta firma acredita lo que dice acreditar: la revisión de seguridad del
código de esta reapertura, **no** las quality gates ni la ejecución del banco, que no son mías.

**Por qué esta revisión existe y no bastaba la anterior.** `requirements/REQ-017.md:8` llevaba
`Seguridad: aprobado (R-012, 2026-09-07)`, emitida sobre el árbol de 1.33.0 y **anterior** a
`19b1822` y `538c266`. `.arnes/config.json` tiene `veredictos.caducan_con_codigo: false` y
`exigir_fecha: false` (verificado con `jq`), de modo que `guard-completado` **habría aceptado**
cerrar `REQ-017` con una firma que no auditó este trabajo. La máquina no lo impide; lo impide
re-firmar. Ésta es esa re-firma, y **sustituye** a la de `R-012` como veredicto vigente del REQ (la
de `R-012` no se retira: cubre el árbol de entonces).

### 1. Alcance: qué es y qué no es este cambio

`git diff 19b1822^..HEAD --stat` sobre los tres commits del rango (`19b1822`, `097c50b` de REQ-026,
`538c266`) toca `CHANGELOG.md`, `docs/ESTADO.md`, `docs/PENDIENTES.md`, `docs/qa/1.34.0.md`,
`requirements/REQ-017.md`, `requirements/REQ-026.md`, `tests/escenarios/hooks/README.md`,
`tests/escenarios/hooks/run.sh` y `tests/escenarios/hooks/secciones/37-coste-del-escaner-5-el-camino-normal.sh`.

**Comprobado por mí y no por lectura del encargo:**
`git diff 19b1822^..HEAD --stat -- hooks/ tools/ .github/ .arnes/ templates/ skills/ agents/ .claude-plugin/`
sale **vacío**. El mecanismo que gobierna a los demás proyectos **no cambia**, el manifiesto no
cambia, y **nada de lo que `arnes-upgrade` hereda** cambia. La superficie de esta auditoría es el
**banco**: una guarda de un caso de prueba que decide en la puerta requerida de `main`.

`git status --porcelain` deja un solo archivo sin comitear (`docs/ESTADO.md`), que no es código.

### 2. Regresión de seguridad contra la línea base de `R-019` — ningún control retirado ni debilitado

Comparado contra el estado aprobado en `R-019` §8 y contra `19b1822^`:

| Control | Antes | Después | Veredicto |
|---|---|---|---|
| Techo de `CA-08 (ii)` | `TECHO47=1250` | `TECHO47=1250` | **intacto**, verificado con `git show 19b1822^:…` contra `HEAD` |
| Series por árbol | `SER47=6` | `SER47=6` | intacto |
| Repeticiones del sujeto por serie | `K47=4` | `K47=4` | intacto |
| Convergencia por brazo | `ce>techo \|\| ch>techo` → SKIP | `CONV47=max(ce,ch); CONV47>techo` → SKIP | equivalente, **mismo umbral y mismo SKIP** |
| Contenido del SKIP de no-convergencia | tres cifras | tres cifras | **restaurado** en `538c266` (era la regresión `QA-017-16`) |
| Techo de coste de la guarda | no existía | `0,750×` declarado como techo, dirección **bajar** | añadido, no relajado |
| `hooks/`, `tools/`, `.github/`, `.arnes/config.json` | — | sin cambios | **intacto** |

**No hay ningún control que estuviera presente y aprobado y hoy no esté.** El único número que se
movió al alza es `PISO_AUTONOMO_SECCION` (411 → 448) y su techo derivado de `REQ-014 CA-18`
(514 → 560); no es un control de seguridad que se relaje, y su gobernanza va abajo en `SEC-058`.

### 3. La pregunta que gobierna esta auditoría: ¿puede la guarda nueva emitir PASS o SKIP donde tocaba FAIL?

**Hacia PASS: no, y lo verifiqué sobre la regla, no sobre la prosa.** `veredicto08_47` emite PASS
sólo si `máx(r) ≤ techo` (`37/5:312-318`). Una regresión real presente en cualquiera de las
repeticiones sube `máx(r)` por encima del techo, y a partir de ahí el único camino es FAIL o SKIP.
No existe promedio, mayoría ni «la mejor de k» que pudiera ahogar una repetición roja.

**Hacia SKIP: sí, y es lo contratado — con un residual que nadie había escrito.** Con unanimidad, una
regresión real que no sea unánime produce **SKIP**, y un SKIP no bloquea. `CA-08` lo acepta por
diseño y acota su alcance: el criterio existe para la clase de **10× de reloj**, que sí sale unánime.
Lo que **no** está escrito en ninguna parte es qué pasa si esa abstención se vuelve el estado
estable. Va como **`SEC-064`**.

**Verificación independiente de la inalcanzabilidad que QA declara en `QA-017-18` y `QA-017-19`.** No
la tomé de su informe; la medí sobre el árbol, y por la vía que su informe no examina —el
**separador de campos**, porque el llamador pasa las repeticiones **sin comillas** (`37/5:347`):

1. **El bucle de recolección empuja siempre `KRAZ47` palabras** (`37/5:208-224`): mide, o mete el
   testigo `:::`, que **no es la cadena vacía** y por tanto sobrevive a la división en palabras. No
   hay camino por el que lleguen menos de `k` repeticiones.
2. **`IFS` no se reasigna nunca de forma global** en el banco: `grep -rn "IFS=" tests/` da
   **únicamente** usos con ámbito de comando (`IFS= read`, `IFS='|' read`). Si alguna sección dejara
   `IFS` con `:`, la división partiría cada registro en cuatro palabras de un solo número, cada una
   parsearía como `ue=ue2=uh=uh2` y **daría razón 1,000× — un PASS fabricado**. Hoy no ocurre; queda
   escrito porque es el forzador que nadie había nombrado.
3. **`sonda_lee` NO valida `min_a`/`min2_a`/`min_b`/`min2_b`** (`run.sh:461-480` valida `us`,
   `procesos` y `vivos`, no éstos), así que la contención está entera en `razon08_47`: cuatro trozos
   numéricos, `> 0`, y suelo de 50 ms. Un valor con `:` o vacío rompe alguna de las tres y va a
   **SKIP**, nunca a PASS. Lo comprobé caso por caso sobre las formas que el productor puede emitir.

**Conclusión:** `QA-017-18` y `QA-017-19` **son inalcanzables desde el llamador de hoy** y su clase
`instrumento` es correcta. **No cambio su clase y no bloqueo por ellos.**

**Y un matiz que sube el coste de arreglar `QA-017-18`, medido aquí y no en el informe de QA:** la
autoprueba de la propia guarda (`37/5:359-365`) invoca `veredicto08_47 … si <UNA repetición>` siete
veces y **espera PASS en la primera**. Es decir que el banco no sólo deja sin exigir la llegada de
las `k`: **depende** de que no se exija. La remediación «que la función se niegue a firmar con menos
de `k`» no es una línea — obliga a separar la regla por registro de la regla de unanimidad, o a dar
a la autoprueba una vía declarada. Queda anotado contra `QA-017-18`, cuyo dueño es el
`desarrollador`; no abro identificador propio.

### 4. Hallazgos

#### SEC-064 — **La abstención de `CA-08 (ii)` no tiene cota: la mitad de reloj de la puerta requerida puede dejar de decidir indefinidamente, en verde** · `instrumento` · severidad **alta** · **abierto** *(nuevo)*

**Ubicación.** `tests/escenarios/hooks/secciones/37-coste-del-escaner-5-el-camino-normal.sh:312-318`
(la regla de emisión) y `requirements/REQ-017.md` `CA-08 (ii)` §«La resolución se comprueba sobre la
RAZÓN»; agregación en `tests/escenarios/hooks/run.sh:1309-1315` y en `.github/workflows/banco.yml`.

**Qué medí.** La regla nueva emite **SKIP** en cuanto el techo cae dentro del recorrido de las `k`
razones, y el SKIP **no cuenta como fallo**: el cuadre suma `PASS + FAIL + SKIP` —así que abstenerse
tampoco rompe el total— y el `rc` es 0 salvo que haya `FAIL` o `PROBLEMAS` de estructura
(`run.sh:1333`), **ninguno de los cuales lo mueve un SKIP**. Sobre las **cinco** corridas de `hooks-en-linux` con código idéntico que el propio REQ
cita, la razón recorre **0,973–1,364** (factor **1,40**) contra un techo de **1,25**. Con ese ruido,
el estado estable de una regresión real situada **entre ~1,25× y ~1,40×** es **SKIP corrida tras
corrida**: ni PASS (hay repeticiones por encima) ni FAIL (no todas lo están). **Nada cuenta las
abstenciones consecutivas**, ni el banco, ni el workflow, ni el criterio. La puerta requerida seguiría
verde con su mitad de reloj apagada, y el apagado no se anuncia.

**Por qué es hallazgo y no el residual ya aceptado.** El proyecto **ya tiene nombrada esta clase**:
`H-08` (`docs/PENDIENTES.md:789`) la escribió como «*un SKIP honesto, agregado a un resultado global,
se lee como verde*», y `.github/workflows/banco.yml:29-33` la conserva escrita. `H-08` se cerró
arreglando **su instancia** (`fetch-depth: 0`), no la clase. Y el propio `REQ-017` ya pagó esta
factura una vez en otro criterio: el Historial del 2026-09-07 registra que `CA-05` implementado al
pie de la letra convertía su único PASS en **«SKIP permanente»**, y eso se trató entonces como
**defecto**, no como abstención legítima. La guarda de `538c266` reintroduce la clase **por diseño**,
que es peor que por accidente: no hay error que arreglar, hay una cota que nadie escribió.

**Lo que este hallazgo NO dice.** No dice que la unanimidad esté mal —es la respuesta correcta a un
instrumento que no resuelve—, ni que el techo `≤ 1,25×` deba moverse (sigue `operativo`, dirección
**bajar**), ni que la guarda tape la clase de **10×** para la que el criterio existe: no la tapa.

**Remediación (por propiedad, no por enumeración).** *Toda abstención de un criterio que corra en la
puerta requerida declara su cota*: un número de corridas consecutivas tras el cual la abstención deja
de ser un veredicto y pasa a ser un **hallazgo con dueño**, y una señal que lo publique sin depender
de que alguien lea la salida. Dónde vive la cota y cómo se publica lo decide el write-back; este
registro no fija la cifra. **Dueño:** `analista-requerimientos` (la cláusula en `CA-06` o en
`CA-08 (ii)`, que es su sede única) y `desarrollador` (la señal). **Forzador:** la primera corrida de
`hooks-en-linux` en que `CA-08 (ii)` emita SKIP —medido: la dispersión que lo produce ya se observó
5 de 5 veces—. **Vencimiento:** el cierre de `SEC-030` (que es de quien es la dispersión de la sonda)
o la ventana **1.35.0**, lo que llegue antes.

**Por qué no bloquea.** Es `instrumento` por la letra de `AGENTS.md` §6 —el defecto está en una
prueba del propio arnés, no en lo que un usuario ve o cobra— y entra en la regla de acumulación del
propietario del 2026-09-08: se registra, no abre REQ y no entra en esta ventana.

#### SEC-065 — **La exposición de `SEC-058` se registró por segunda vez, más floja y sin vencimiento, en `docs/PENDIENTES.md`** · `instrumento` · severidad **media** · **abierto** *(nuevo)*

**Ubicación.** `docs/PENDIENTES.md` § «El tercer término del piso de `REQ-014 CA-18` no lo verifica
ninguna máquina (QA, 2026-09-08)» frente a `docs/seguridad/registro-seguridad.md:5618` (`SEC-058`).

**Qué medí.** Son **el mismo hallazgo**: que el techo de tamaño de un archivo de sección lo decide un
número que el propio archivo declara y que ninguna máquina puede contrastar. `SEC-058` lo tiene como
`instrumento`, severidad **alta**, **abierto**, dueño `desarrollador`, con **remediación 3
(propiedad de máquina) vencida en 1.34.0** — esta ventana. La entrada nueva de `PENDIENTES` no lo
cita, no le pone vencimiento y añade «**No urge**». Dos registros de un hallazgo divergen siempre, y
divergen hacia el lado que abre: el que la gente lee es el que dice que no urge.

**Remediación.** La entrada de `PENDIENTES` **cita** `SEC-058` y hereda su severidad, su dueño y su
vencimiento, o se retira en favor del registro —`requirements/README.md` §«La clase, el forzador y el
vencimiento se CITAN con archivo y línea» ya lo exige para los REQ; aquí se aplica al mismo texto en
otro documento—. **Dueño:** `qa-tester` (la entrada) y `auditor-seguridad` (la referencia cruzada,
que ejerzo abajo). **Forzador:** la primera vez que alguien planifique la ventana leyendo
`PENDIENTES` y no este registro. **Vencimiento:** el cierre de 1.34.0.

#### SEC-066 — **El README del banco quedó en 886 casos cuando el total es 887** · `instrumento` · severidad **baja** · **abierto** *(nuevo)*

**Ubicación.** `tests/escenarios/hooks/README.md:33` («**886 casos**») frente a
`tests/escenarios/hooks/run.sh:1303` (`CASOS_ESPERADOS=887`) y la corrida verificada
(882 PASS · 0 FAIL · 5 SKIP = **887**).

**Qué medí.** `19b1822` dejó los dos números **coherentes** en 886. `538c266` subió
`CASOS_ESPERADOS` a 887 y **no tocó el README**. Es la clase de `SEC-060` —una cifra que sobrevive a
la medición que la desmiente— reaparecida dentro del mismo rango de commits que la produjo, y en el
archivo que un recién llegado lee primero. No afecta a ninguna puerta: el cuadre lo hace
`CASOS_ESPERADOS`, no el README. **Dueño:** `desarrollador`. **Remediación:** que el README deje de
publicar la cifra y remita a `CASOS_ESPERADOS` —la fuente única, que ya nombra—, o que se actualice
en el mismo commit que la mueva. **Forzador:** el próximo caso que se añada. **Vencimiento:** la
ventana 1.35.0.

#### SEC-058 — actualización: **sigue `abierto`**, con instancia nueva ejercida y remediación 3 **venciendo en esta ventana**

No cambia de clase ni de severidad. Se le añade lo medido en esta revisión:

- **Instancia nueva, y es exactamente la que el hallazgo describe.** `PISO_AUTONOMO_SECCION` pasó de
  **411 a 448** —y con él el techo de **514 a 560**— en la **misma comisión que entregaba el código**
  que engordó el bloque. Las cuatro comprobaciones de `ca18_deriva()` (legibilidad, suma,
  `piso ≤ líneas`, `líneas ≤ techo`) habrían pasado igual con el tercer término inflado.
- **Remediación 1 (control de procedimiento): EJERCIDA otra vez**, ahora por el `qa-tester`
  (`docs/qa/1.34.0.md` § «El piso de `REQ-014 CA-18` pasó de 411 a 448»), con fronteras medidas
  (123-449 = 327), crecimiento igual a lo añadido (+37) e indivisibilidad demostrada con un mutante.
  **Lo comprobé yo por el lado que decide si compró margen:** el archivo queda en **504 líneas** y ya
  cabía bajo el techo **anterior** de 514. El movimiento **no compró conformidad**. Como en `R-019`,
  esto cierra **esta** instancia, no el hallazgo.
- **La formulación de QA es más precisa que la mía y se adopta:** el término no verificable es el
  **tercero** —el tamaño del bloque indivisible—, y basta escribirlo de más para que la suma cuadre
  sola. Con eso, la remediación 3 tiene forma barata y verificable, que dejo propuesta: **que la
  derivación declare las FRONTERAS del bloque y no sólo su tamaño** (`inicio-fin`), de modo que la
  máquina compruebe `fin − inicio + 1 == término` y que las dos fronteras existan en el archivo. Un
  número inventado deja de cuadrar contra el archivo que lo declara.
- **Remediación 3: vence al cerrar 1.34.0** y **no está hecha**. No bloquea (es `instrumento`), pero
  un vencimiento que pasa se re-fija **por escrito** —como ya ocurrió con la remediación 2— y no en
  silencio. Es decisión de planificación, no mía.

### 5. `SEC-047`, `SEC-048` y `SEC-049` — ninguno lo introduce ni lo agrava este cambio, y uno tiene consecuencia de publicación

Los tres siguen **abiertos** e **`instrumento`**, con la clase, el dueño y el forzador que les puso
`R-012`, ratificados en `R-014`. Comprobado contra este rango de commits:

- **Ninguno se agrava.** Los tres viven en el lector de cabecera, en el ruleset/workflow y en el texto
  de `CA-10`; el rango **no toca** `hooks/`, `.github/` ni `AGENTS.md`.
- **`SEC-047`, condición de escalada 3 — NO disparada por este rango.** `git diff … | grep` sobre las
  formas que prometerían la **propiedad** en vez del carácter («retorno de carro», «carácter no
  representable», «no representable») **no encuentra ninguna línea añadida**. Ningún texto firmado
  empezó a prometer más de lo que el código guarda.
- **`SEC-047`, condición 1 — pendiente y con consecuencia directa sobre el tag.** Dice: *«1.34.0
  cierra sin ella»*. **Cerrar `REQ-017` no es cerrar 1.34.0**, así que esta firma no la dispara y el
  REQ puede cerrar con `SEC-047` en `instrumento`. Pero **publicar 1.34.0 sin la remediación la sube
  a `contrato`**, y con un `contrato` abierto la fusión y el tag vuelven al propietario
  (`AGENTS.md` §6). No lo remedio aquí —es de `REQ-023`/`REQ-024`—; lo dejo escrito para que la
  decisión no se tome sin verlo.
- **`SEC-047`, condición 2 — NO MEDIDA por mí.** No barrí las cabeceras del árbol ni de la historia
  buscando un carácter no representable. Se declara como **no mirado**, nunca como «no ocurre».

### 6. Repositorio público — sin fuga

Barrido del rango completo (`git diff 19b1822^..HEAD`) buscando nombres de cliente, dominios,
correos, rutas de `insumos/` y referencias a `mejoras-arnes-*`: **nada**. Los únicos aciertos son
fragmentos de código (`for rep in "$@"`) y cabeceras de *hunk*. Lo añadido describe el arnés y su
propio banco; ningún hallazgo de cliente aparece descrito ni citado.

### 7. Lo que esta revisión NO miró — tabulado como NO MIRADO, nunca como PASA

| No mirado | Por qué |
|---|---|
| **Quality gates y ejecución del banco** | No son mías (`AGENTS.md` §6). **No ejecuté `run.sh` ni la autoprueba.** El `882 PASS · 0 FAIL · 5 SKIP · rc 0` lo cito de QA y de la coordinadora; no lo re-medí |
| **La derivación de `k = 4`** | 56 repeticiones, 30+ min. Excluida por el encargo y ya registrada sin verificar (`QA-017-20`). Audité que el **criterio de selección** es el correcto —la peor ventana alcanza el recorrido de la muestra— y que `k` está declarado `operativo` con dirección **subir**; **no** que 4 baste en el runner real |
| **El techo de coste `0,750×` y el `+28,0 s`** | Excluido por el encargo; acreditado por el `desarrollador` y **no verificado por nadie** (`QA-017-21`). Sólo comprobé que está escrito como **techo** con dirección **bajar** y que no se movió en el rango |
| **El comportamiento en el CI real** | Todo lo mirado es lectura de código y de evidencia local. Si `k = 4` resuelve en `hooks-en-linux` sigue **SIN MEDIR**, y `SEC-064` existe justamente porque el modo de fallo de que no resuelva es silencioso |
| **Los otros nueve criterios de `REQ-017`** | El rango no toca `hooks/`. Su acreditación sigue siendo la de `R-012`, que **no se retira** |
| **`SEC-047` condición 2** | Barrido de cabeceras no ejecutado (§5) |
| **`REQ-026` (`097c50b`), que cae dentro del rango de commits** | No es mi REQ. No lo audité y esta firma **no lo cubre** |
| **La cola de aprobaciones y los tags** | Comprobado como contexto de cierre, no como alcance: `PENDING_APPROVAL.md` sigue siendo el gate y no lo evalúo aquí |

### 8. Estado de seguridad aprobado por REQ — línea base de no-regresión, actualizada en R-020

| REQ | Veredicto | Fecha | Alcance acreditado | Nota |
|---|---|---|---|---|
| **REQ-017** (reapertura 1.34.0) | **`aprobado`** | 2026-09-08 | `rel/registro-1.33.0` @ `ef94cb5`; código en `19b1822` + `538c266` | **Qué acredita:** que el rango **no toca** el mecanismo (`hooks/`, `tools/`, `.github/`, `.arnes/`) ni nada heredable (§1); que ningún control aprobado se retiró ni se debilitó y que `TECHO47=1250` está intacto (§2); que la guarda nueva **no puede emitir PASS donde tocaba FAIL** y que `QA-017-18`/`QA-017-19` son **inalcanzables** desde el llamador de hoy, verificado por mí incluida la vía del separador de campos (§3); y que no hay fuga en repositorio público (§6). **Qué NO acredita:** quality gates, ejecución del banco, la derivación de `k`, el techo de coste ni el comportamiento en el CI real (§7). **Residuales declarados:** `SEC-064` (`instrumento`, alta) — la abstención no tiene cota; `SEC-047` (`instrumento`) sigue abierto y **escala a `contrato` si 1.34.0 se publica sin su remediación** |
| **REQ-017** (1.33.0) | `aprobado` | 2026-09-07 | `R-012`, re-anclado en `R-016` y `R-019` | **No se retira:** cubre el árbol de entonces. **Deja de ser la línea base vigente**: la sustituye la fila de arriba |
| **REQ-014** (reapertura 1.33.0) | `aprobado` | 2026-09-08 | `R-019`, `cand/1.33.0` @ `d4e0033` | Sin cambios en esta revisión. Su residual `SEC-058` **sí** se actualiza (§4) |

**Rigor:** `REQ-017` se queda en **`critico`**, que es además su suelo por `Sensible a seguridad: sí`.
**No subo ni bajo el rigor de ningún REQ**; aquí no hay nada que subir, ya está en el techo.

**Hallazgos que esta revisión deja abiertos en `REQ-017`:** `SEC-047`, `SEC-048`, `SEC-049`
(preexistentes, `instrumento`) y `SEC-064`, `SEC-065`, `SEC-066` (nuevos, `instrumento`). **Ninguno
de mis hallazgos es de clase `contrato`, y por tanto ninguno bloquea el cierre.** Los de QA
(`QA-017-07` … `QA-017-22`) **no se tocan, no se cierran y no se reclasifican**: no son míos, y
verifiqué la inalcanzabilidad de dos de ellos sin cambiarles la clase.

**Numeración vigente tras esta revisión:** última revisión **R-020**; último hallazgo **SEC-066**;
próximos libres **R-021** y **SEC-067**.

**`docs/seguridad/gobernanza-datos.md`: sin cambios.** Esta revisión no altera clasificación de datos,
acceso, retención ni cumplimiento: el rango no introduce datos, ni credenciales, ni superficie de red,
y este repositorio sigue sin manejar usuarios finales ni datos personales.

---

## Revisión R-021 — **auditoría de REQ-026**: el rotador que ya escribe dentro de `requirements/`, **después** de QA, ventana 1.34.0 (`rel/registro-1.33.0` @ `464e0ba`, rango `2a91c82^..464e0ba`) — 2026-09-09

**Veredicto: `con-hallazgos`.** No es un veto: el mecanismo entregado está **apagado** y no puede
disparar hoy. Es un `con-hallazgos` porque queda **un hallazgo `usuario/dinero` abierto** (SEC-067) y
porque su control no existe todavía ni en el código ni en ningún criterio, así que firmar `aprobado`
sería exactamente la deriva que `AGENTS.md` §9 prohíbe: dejar el control viviendo en un registro.

**Turno correcto:** `QA: aprobado (2026-09-09)` está firmado sobre este mismo árbol; audito después.

### 1. Por qué esta auditoría cambia de naturaleza, dicho una vez

Hasta `2a91c82` el rotador **no podía** tocar un REQ: su reconocedor era una lista de prefijos y las
historias son tablas, así que daba cero entradas y salía. Ese blindaje era **accidental** y ya no
existe. Desde este rango, el hook de parada es un **escritor de `requirements/`**, y lo que hay ahí
es el contrato que gobierna a todos los proyectos que instalan el arnés.

### 2. La pregunta 1 del encargo: el fail-closed de `arnes_rot_es_separadora` — **se sostiene, y el argumento que lo sostiene NO es el que está escrito**

Verifiqué el argumento de clase de QA (`docs/qa/1.34.0.md:843-851`): «*acepta exactamente el conjunto
de caracteres que GFM admite en una fila delimitadora … luego no existe fila que GFM lea como
separadora y el hook lea como dato*».

**La conclusión la confirmo. El argumento, no: nombra el mecanismo equivocado como portante.**

- `arnes_rot_es_separadora` (`hooks/rotar-artefactos.sh:238-244`) sólo se consulta sobre líneas que ya
  pasaron `case "$rec" in '|'*)`, y `rec` recorta **sólo el espacio final** (`:365`): la comparación
  es a **columna cero y con barra inicial**.
- GFM admite dos formas de fila delimitadora que **nunca llegan** a ese predicado: **sin barra
  inicial** (`:---|:---` — la barra de los extremos es opcional en GFM) y **indentada hasta tres
  espacios**. Sobre esas dos, el conjunto de caracteres no decide nada porque el predicado no se
  ejecuta.
- Lo que de verdad cierra la clase es **otro** mecanismo, el que añadió `931218b`: `hueco`/`hueco2`
  (`:400-404` y `:456-461`) — *cualquier* línea que no sea fila a columna cero, apareciendo **entre
  dos filas de datos**, invalida la estructura. Y se compone con un hecho de GFM: una segunda tabla
  **exige** una línea en blanco o una interrupción de bloque, y esa línea es precisamente lo que
  dispara `hueco2`.

**Medido por mí** (sondas en `/tmp`, ningún REQ real, rotación no encendida):

| Forma probada (ninguna en las doce de QA) | Resultado |
|---|---|
| 2ª tabla **sin barra inicial** en cabecera y separadora, **en medio** de las filas | **fail-closed** + aviso |
| 2ª tabla sin barra inicial **tras la última fila**, `orden: nuevo-al-final` | rota; la línea viaja con la entrada **conservada**; multiconjunto exacto |
| lo mismo con `orden` **distinto de** `nuevo-al-final` (se archiva la cola) | rota; el bloque del destino queda **legible como tabla**; multiconjunto exacto |
| fila de datos hecha **sólo** de guiones y barras (`\| - \| - \|`) | falso positivo del predicado → **fail-closed** (lado seguro) |
| barrido del **corpus real**: filas de `## Historial de cambios` que el predicado tomaría por separadora | **cero** en los 26 archivos |

Conclusión: **no encontré séptima forma, y la dirección peligrosa está cerrada por construcción.** El
residual que QA declara (segunda tabla tras la última fila) lo reproduje en tres configuraciones y es
**inocuo**, como QA dice. Lo que queda es SEC-068: el argumento escrito licenciaría retirar
`hueco2`, que es justo la guarda que cierra la clase.

### 3. La pregunta 3 del encargo: la concurrencia — **NO la cubre el temporal propio del proceso, y sí puede dejar un contrato mutilado**

Respuesta directa: **el temporal por proceso de `REQ-015` cubre la escritura desgarrada, no la
actualización perdida.** Son dos modos de fallo distintos y sólo el primero está cerrado. Detalle y
medición en **SEC-067**.

### 4. Hallazgos

#### SEC-067 — **La rotación reescribe el documento ENTERO desde una lectura previa, sin comprobar si cambió: una firma que caiga en esa ventana se pierde en silencio** · `usuario/dinero` · severidad **alta** · **abierto**

**Dónde.** `hooks/rotar-artefactos.sh:297` (la lectura) y `:596-598` (la publicación). Entre las dos
no hay ninguna comprobación de concurrencia: ni relectura, ni comparación de mtime, ni bloqueo. El
paso 7 hace `printf '%s' "$salida" > "$tmp_orig" && mv -f "$tmp_orig" "$f"` con un `salida` derivado
de lo que se leyó al principio.

**Medido, 3 de 3 intentos, sonda en `/tmp` sobre un REQ de prueba de 4.000 filas:** con la rotación
en vuelo se escribió `Seguridad: aprobado (2026-09-09, R-021)` sobre la cabecera; al terminar la
rotación el disco decía otra vez `Seguridad: pendiente`. **Ventana medida: 355–361 ms.** `rc = 0`,
**stderr vacío**, y **ninguna línea en el bloque derivado**: el arnés no tiene ni un canal por el que
se sepa que ocurrió. La rotación no *altera* la cabecera: la **republica como la leyó**, y el efecto
observable es que un veredicto —o un veto, o un criterio nuevo— **retrocede**.

**Segunda consecuencia del mismo origen, modelada** (entrelazado reproducido de forma determinista:
B leyó el origen antes del recorte de A y el destino después de la publicación de A): el bloque
archivado **se duplica**. De 5 filas originales quedaron 2 en el documento y **6** en el archivo,
**3 repetidas**. `CA-05` promete «cero filas perdidas, cero duplicadas … sin ninguna repetida» **sin
declarar ninguna condición**.

**Y una invariante del propio archivo que es falsa.** `hooks/rotar-artefactos.sh:34-36` afirma: «*si
dos paradas rotan el mismo artefacto, una de las dos no encontrara nada que mover, y eso es
conforme*». Sólo es cierto si la segunda **lee después** del recorte de la primera. Con simultaneidad
real ambas leen el mismo estado y la segunda sí encuentra qué mover.

**Alcance honesto — no es un incidente vivo.** No puede ocurrir hoy: `rotacion.activo` es `false`,
`rotacion.artefactos` está vacío, y encenderlo es `CA-13`, **gate humano** de `AGENTS.md` §6. Lo que
este rango cambia es que el blindaje accidental desapareció. **Es latente, no explotado.**

**Consecuencia de gobernanza que no se puede resolver con disciplina.** Encendida la rotación, el
escritor de `requirements/` es el **hook de parada**, que no figura en el campo `Archivos:` de ningún
REQ. `tools/arnes-paralelo.sh` responde sobre **comisiones**, así que un `disjunto` seguirá siendo
verdadero y **seguirá siendo insuficiente**: hay un tercer escritor que el mapa no ve. `REQ-026`
acertó a medias al declarar `requirements/REQ-*.md` en su propio `Archivos:` — eso protege a la
comisión que lo desarrolla, no a cada sesión futura en la que un agente pare mientras otro edita un
REQ.

**Remediación (write-back OBLIGATORIO antes de `CA-13`; `AGENTS.md` §9).**
1. **Criterio nuevo** en `REQ-026`, enunciado por **propiedad** y no por enumeración de
   entrelazados: *si el documento cambió en disco entre la lectura y la publicación, no se publica,
   no se toca nada y se avisa por las cuatro sedes de `CA-08 (v)`*; y *el archivado es idempotente:
   dos rotaciones del mismo estado no dejan una fila repetida en el destino*.
2. **Control en el código** (`desarrollador`): comprobar inmediatamente antes del `mv` que `$f` sigue
   siendo lo que se leyó, y abortar si no; y hacer el bloque del destino idempotente o serializar por
   bloqueo. La dirección es la de todo el archivo: **preferir no rotar a publicar una reversión**.
3. **Declarar en `CA-05`** que su promesa es sobre **una** parada, en vez de dejarla incondicional.
4. **`CA-13` no se declara** —ni en este repositorio ni en la plantilla— mientras 1 y 2 no existan.

*Dueño:* `analista-requerimientos` (los criterios) y `desarrollador` (el control).
*Forzador:* el commit que declare `rotacion.activo: true` sobre `requirements/` (`CA-13`).
*Vencimiento:* **antes** de ese commit. Mientras no exista, `REQ-026` no puede cerrar.

#### SEC-068 — **El argumento que cierra la clase nombra el mecanismo equivocado como portante** · `instrumento` · severidad media · **abierto**

Detalle en §2. El argumento de `docs/qa/1.34.0.md:843-851` es correcto en su conclusión y falso en su
razón: el conjunto de caracteres no puede cerrar nada sobre las dos formas de fila delimitadora que
GFM admite y que el predicado **nunca ve** (sin barra inicial; indentada). Quien lea ese argumento
concluirá que `arnes_rot_es_separadora` es lo que sostiene el fail-closed y podrá **retirar
`hueco2`** —añadido en `931218b`, y que es lo que de verdad lo sostiene— sin creer que quita nada.

*Remediación:* reescribir el argumento donde vive, citando `hueco`/`hueco2` como la guarda portante y
el hecho de GFM que la completa (una segunda tabla exige línea en blanco o interrupción de bloque), y
declarando que el predicado sólo decide sobre filas a columna cero con barra inicial.
*Dueño:* `qa-tester`. *Vencimiento:* el cierre de 1.34.0.

#### SEC-069 — **El canal único de `CA-08 (v)` está condicionado a otra clave del manifiesto** · `instrumento` · severidad media · **abierto**

`CA-08 (v)` exige que las cuatro ramas de «no se rota» dejen constancia «por un canal que **sobrevive
a la sesión**», y lo nombra: una línea en el bloque derivado de `docs/ESTADO.md`. **Medido por mí:**
con `estado_derivado.activo: false` en el manifiesto **no se escribe ninguna de las cuatro líneas** y
sólo queda el `stderr` — que es exactamente el canal que el propio criterio declara insuficiente.
Sin declarar la clave el canal funciona (viene encendido), y verifiqué además que el aviso **se
re-deriva en cada parada** mientras la causa persista, que es la semántica correcta y desmiente mi
sospecha inicial de que la parada siguiente lo borraba.

Es la misma forma que el analista rechazó con razón en `QA-026-06`: un canal condicionado. Aquí la
condición no es un suceso sino una clave que elige el proyecto, y por eso es `instrumento` y no
bloquea; pero un proyecto puede encender la rotación y tener el bloque derivado apagado, y entonces
los cuatro fail-closed son invisibles.

*Remediación:* o `CA-08 (v)` declara la dependencia, o la rotación de sección **no corre** cuando su
única sede superviviente está apagada. *Dueño:* `analista-requerimientos` y `desarrollador`.

#### SEC-070 — **El tercer sitio de la familia `SEC-002`/`R-001`: `tools/arnes-lectura.sh` lee con la forma cruda y no lo dice** · `instrumento` · severidad baja · **abierto**

Barrido de `hooks/` y `tools/` (pregunta 2 del encargo). `arnes_lee_archivo` nació en `SEC-002`/`R-001`
y hasta `ade924e` tenía **un** llamador (`hooks/guard-completado.sh:150`); el rotador era el segundo y
nadie lo notó en varias versiones. **Hay un tercero:** `tools/arnes-lectura.sh:120` hace
`texto=''; IFS= read -r -d '' texto < "$f"` **sin mirar el código de retorno**.

**Distinción que cambia la severidad: no escribe.** No puede mutilar nada. Lo que puede es
**informar** sobre una lectura truncada sin decir que lo es: con un NUL en la cabecera, el informe
enseña los campos que sobrevivieron al corte y la puerta —que sí es fail-closed— lee otra cosa. Sus
propios comentarios (`:105-114`) afirman que los campos «salen del MISMO lector que la puerta», y en
la lectura del archivo completo eso **no** es cierto.

*Remediación:* usar `arnes_lee_archivo` y, si devuelve «no medible», nombrar el archivo como **no
medido** en vez de informar campos. *Dueño:* `desarrollador`. *No entra en esta ventana* (regla de
acumulación del propietario, 2026-09-08); va a `docs/PENDIENTES.md`.

#### SEC-071 — **`hooks/estado-derivado.sh` es una segunda transcripción de `arnes_lee_archivo`** · `instrumento` · severidad baja · **abierto**

`hooks/estado-derivado.sh:294` reimplementa la regla del NUL en línea, **correctamente hoy** (avisa y
no escribe; comprobado también el caso «contenido en disco, lectura vacía» y el `[ ! -r ]` previo), y
además **escribe** el destino. No es un fallo en abierto: es la segunda transcripción de una regla que
`AGENTS.md` §13 y `hooks/lib.sh:1130-1140` declaran que debe ser **una**, en el punto donde ese
desfase costaría texto humano.

*Remediación:* llamar a `arnes_lee_archivo`. *Dueño:* `desarrollador`. Fuera de ventana.

#### QA-026-04 — **corrijo la clase: `instrumento` → `contrato`** (pregunta 4 del encargo)

QA dejó `QA-026-04` como `instrumento` con forzador `CA-13`. **Corrijo las dos cosas.**

`_doc_artefactos` describe el mecanismo viejo en `.arnes/config.json:48` **y en
`templates/arnes-config.json.tpl:53`**: «*mueve sus entradas viejas —líneas que empiezan por `- `,
`* `, `### ` o `N. `, con sus continuaciones—*». El código ya mueve **filas de tabla**.

Por qué `contrato` y no `instrumento`: `requirements/README.md:316` define un valor **de contrato**
como aquel por el que «*alguien de fuera elige su conducta*: … un límite anunciado en una plantilla».
Esto es exactamente eso, y **envejece hacia el lado que abre**: la plantilla **subestima** lo que la
máquina va a tocar. Un proyecto que la lea concluirá que su sección en forma de tabla es inerte
—cierto hasta 1.33.0— declarará la rotación creyéndolo, y encontrará **sus tablas reescritas**. La
frase no describe mal un instrumento: promete a un tercero que la máquina no toca algo que sí toca.

Y el forzador **no** es `CA-13`: la frase ya es falsa hoy, con independencia de que este repositorio
encienda la rotación, porque el rotador corregido y la plantilla obsoleta **viajan juntos** a los
proyectos por `arnes-upgrade`. *Forzador real:* la **publicación de 1.34.0**. *Vencimiento:* antes de
ese tag. *Dueño:* `desarrollador` (los dos archivos), **tras el gate humano de §6** — que es donde
`REQ-026` ya dijo que quedaba, y ahora con la clase que corresponde.

### 5. Regresión de seguridad contra la línea base de `R-020` — ningún control retirado ni debilitado

El rango toca **dos** archivos de `hooks/` (`rotar-artefactos.sh`, `estado-derivado.sh`) y **ninguna**
puerta: no toca `guard-completado.sh`, `guard-codigo.sh`, `guard-git.sh`, `lib.sh`, `hooks.json`,
`.arnes/config.json`, `templates/` ni `.github/`. Verificado sobre el `--stat` del rango.

- **Se refuerza** un control aprobado: la lectura del rotador pasa de la forma cruda a
  `arnes_lee_archivo` en sus **dos** funciones (`:92` y `:297`), con fail-closed y aviso.
- **Se refuerza** la validación de estructura: cubre la sección entera, no sólo el preámbulo.
- **Se refuerza** la visibilidad: las cuatro ramas de «no se rota» publican en el bloque derivado.
- **Contención de rutas intacta:** `arnes_ruta_interna` sobre `archivo_dir` (léxica) más
  `arnes_dir_interno` sobre el directorio resuelto (física, contra enlaces simbólicos), `:534-539`.
  **Medido por mí:** con `archivo_dir` en `../../fuera`, en `/tmp/fuera-absoluto` y con barra
  invertida (`requirements\historial`) **no se rota, no se crea nada y no se escribe fuera del
  proyecto**; con el valor legítimo rota. Cuatro formas, control positivo incluido.
- **Temporales:** los cuatro puntos de publicación usan `arnes_tmp_publicacion` (componente propia
  del proceso, `REQ-015 CA-01`). Verificado en `:159-162` y `:551-554`.
- **Orden en `stop.sh`:** la rotación corre **antes** del bloque derivado y en el **mismo** shell
  (`:36-37`, ambos por `source`), que es la condición para que los contadores de `CA-08 (v)`
  lleguen vivos. Si alguna de las dos cosas cambiara, el canal quedaría muerto **en silencio**.

### 6. `SEC-047`, `SEC-048`, `SEC-049`, `SEC-058`, `SEC-064` — ninguno lo introduce ni lo agrava este rango

- **`SEC-047`** (`instrumento`, crítica) — **sigue en pie**, sin cambio de clase por este rango, y su
  vencimiento sigue siendo el **cierre de 1.34.0**. No lo re-barrí (§7).
- **`SEC-048`** (ruleset/workflow) — el rango no toca `.github/` ni el ruleset.
- **`SEC-049`** — sin relación con el rango.
- **`SEC-058`** (el piso autodeclarado sin cota) — **tocado de lado y no agravado**:
  `28-rotacion-seccion-3-la-tabla.sh` declara `PISO_AUTONOMO_SECCION=94` y queda en **400 de 400**
  líneas, el techo exacto de `REQ-014 CA-18`. Es la forma que `SEC-058` describe (el sujeto declara
  el número del que depende su propio techo), pero aquí no compró conformidad: el archivo está **en**
  el techo, no por debajo gracias al piso. **Si mi revisión pidiera un caso más, exijo partir la
  sección en una parte 4** y **no** subir el techo.
- **`SEC-064`** (la abstención sin cota) — sin relación con el rango.

### 7. Lo que esta revisión NO miró — tabulado como NO MIRADO, nunca como PASA

| No mirado | Por qué |
|---|---|
| **Quality gates y el banco** | No son mías (`AGENTS.md` §6). **No ejecuté `run.sh` ni una sola vez.** El `912 PASS · 0 FAIL · 4 SKIP · rc 0` (total 916) lo **cito** de la coordinadora, que lo reprodujo dos veces sobre `464e0ba`; no lo re-medí |
| **La campaña de `CA-15`** (techo `≤ 0,140 s`) | Excluida por el encargo. **No la re-medí.** Sólo comprobé que está declarada **operativa** con dirección **bajar** y que el rango no la mueve. Sigue en pie lo que su propio registro admite: no se traslada al *runner* de `hooks-en-linux` |
| **La rotación en ejecución sobre REQ reales** | **No la encendí, ni para probar.** Todo lo medido va sobre copias en `/tmp`. Con la rotación encendida sobre `requirements/` no hay **ninguna** medición, ni mía ni de nadie |
| **`CA-13`, `CA-14`, `CA-16`, `CA-17`** | Sin implementar por diseño; excluidos por el encargo y **no** contados como fallo |
| **`SEC-047` condición 2** | Barrido de cabeceras no ejecutado |
| **La concurrencia REAL de dos paradas simultáneas** | Lo que medí en carrera real es la **actualización perdida** (3/3). La **duplicación del bloque** la reproduje por un **modelo determinista del entrelazado**, no por una carrera: queda declarada como modelo, no como medición de carrera |
| **Otros REQ** | No amplié. Lo que vi fuera va a `docs/PENDIENTES.md` en una línea (SEC-070, SEC-071) |

### 8. Repositorio público — sin fuga

Barrido del rango entero contra los patrones de material de cliente (`mejoras-arnes*`, `insumos/`,
nombre del proyecto cliente, rutas de otro repositorio): **cero coincidencias**. Los defectos citados
son del propio arnés y están descritos por su mecanismo.

### 9. Rigor

`REQ-026` se queda en **`critico`**, que además es su suelo por `Sensible a seguridad: sí`. **No hay
nada que subir: ya está en el techo, y no bajo el rigor de nada.**

### 10. Estado de seguridad aprobado por REQ — línea base de no-regresión, actualizada en R-021

| REQ | Veredicto | Fecha | Alcance acreditado | Nota |
|---|---|---|---|---|
| **REQ-026** | **`con-hallazgos`** | 2026-09-09 | `rel/registro-1.33.0` @ `464e0ba`, rango `2a91c82^..464e0ba` | **Qué acredita:** que el fail-closed del reconocedor de tablas **se sostiene** y la dirección peligrosa (una separadora de GFM leída como dato) está cerrada **por construcción**, verificado por mí con cinco formas que no estaban en las doce de QA y con un barrido del corpus real (§2); que la contención de rutas del destino, los temporales por proceso y el orden de `stop.sh` están intactos (§5); que ningún control aprobado se retiró y **tres** se refuerzan (§5); y que no hay fuga en repositorio público (§8). **Qué NO acredita:** quality gates, banco, la campaña de `CA-15`, el comportamiento con la rotación encendida, ni `CA-13`/`CA-14`/`CA-16`/`CA-17` (§7). **Bloqueante abierto:** `SEC-067` (`usuario/dinero`) — la rotación republica el documento desde una lectura previa sin comprobar concurrencia. **Residuales:** `SEC-068`, `SEC-069`, `SEC-070`, `SEC-071` (`instrumento`) y `QA-026-04`, **reclasificado a `contrato`** |
| **REQ-017** (reapertura 1.34.0) | `aprobado` | 2026-09-08 | `R-020` | Sin cambios en esta revisión |
| **REQ-014** (reapertura 1.33.0) | `aprobado` | 2026-09-08 | `R-019` | Sin cambios en esta revisión |

**Numeración vigente tras esta revisión:** última revisión **R-021**; último hallazgo **SEC-071**;
próximos libres **R-022** y **SEC-072**.

**`docs/seguridad/gobernanza-datos.md`: sin cambios.** El rango no altera clasificación de datos,
acceso, retención ni cumplimiento: no introduce datos, ni credenciales, ni superficie de red, y este
repositorio sigue sin manejar usuarios finales ni datos personales. Lo que sí cambia —y queda dicho
en §1— es **qué** puede escribir el arnés: el hook de parada pasa a poder reescribir documentos de
`requirements/`, que son el contrato. Es gobernanza de **integridad**, no de datos personales, y su
control es `SEC-067`.

---

## Revisión R-022 — **REQ-026, vuelta 2**: el testigo de vigencia de `CA-18`, **después** de QA, ventana 1.34.0 (`rel/registro-1.33.0` @ `4f51293`, rango `464e0ba..4f51293`) — 2026-09-09

**Veredicto: `con-hallazgos`.** El código está bien y lo acredito. Lo que bloquea ya **no es
código**: son dos defectos de **contrato** —una promesa escrita en absoluto y un alcance parcial que
la máquina lee como completo—, y los dos se arreglan con write-back del analista.

### 1. `SEC-067` — el testigo **cierra la clase en todo lo que el shell puede observar**, y pasa a `en-mitigación`, no a `mitigado`

**Qué acredito del mecanismo** (`hooks/rotar-artefactos.sh:6b`, `:630-693`), leído línea a línea:

- **Relectura y comparación byte a byte de los DOS archivos** —documento y archivo de historia—
  en el último instante antes de la primera publicación. La comprobación del destino no es adorno:
  `tmp_dest` se armó sobre lo que el destino decía al leerlo, y publicar encima de una lectura
  caducada **de él** borra un bloque ya archivado.
- **La duda decide hacia no rotar** (`CA-18 (ii)`): si `arnes_lee_archivo` no puede leer para
  comprobar, no se publica y se avisa. Verificado en las **cuatro** salidas de la rama.
- **La reconstrucción del testigo es exacta y no está normalizada de más.** `texto_ini="$texto"` +
  `fin_nl` repone el único salto que la normalización quita, y la comparación **no** es
  «normalizado contra normalizado» — eso habría hecho comparar iguales dos documentos que difieren
  en el salto final, y devolver ese byte al estado viejo **también es una actualización perdida**.
  Este detalle es el que separa un guardián de un guardián que aprueba lo que debía rechazar.
- **Los temporales se retiran en todas las salidas nuevas** (`rm -f "$tmp_dest" "$tmp_orig"`),
  incluidas las que antes sólo borraban uno.
- **No hay cerrojos, y sostengo el argumento.** `(i)` incluye «*una persona*», y un cerrojo sólo
  obliga a quien lo toma: habría dado garantía sobre las rotaciones y **ninguna** sobre el caso que
  medí. Y un cerrojo huérfano deja un documento que **no vuelve a rotar nunca**, con la decisión de
  «cuándo está rancio» que es adivinar. La relectura no obliga a nadie, no espera a nadie
  (`(v)(b)`) y su coste es leer un archivo que se va a reescribir. **Decisión correcta.**
- **La invariante falsa de `:34-36` está corregida y nombra su medición.** Era deriva y ya no lo es.
- **Canal propio** (`hooks/estado-derivado.sh`, quinta rama) con texto que distingue «no roté» de
  «roté y me comí tu cambio», que es exactamente la confusión con la que se midió `SEC-067`.

**El residuo, y mi lectura de él.** La comprobación va en el último instante, así que queda la
**ventana de publicar** —`mv` del destino, concatenación, `printf`, `mv` del origen—: de
microsegundos a pocos milisegundos, frente a los 355–361 ms que medí. **Es la misma clase, no otra.**
Y **no se puede cerrar aquí**: POSIX no ofrece un «renombra-si-no-ha-cambiado» atómico, y las dos
alternativas que lo cerrarían —un cerrojo obligatorio para todo escritor, o sacar la rotación del
hook de parada— cuestan más de lo que valen o no dan la propiedad. Reducir la ventana **cuatro o
cinco órdenes de magnitud** no es cerrar la clase; es lo máximo que este mecanismo puede dar, y me
vale.

**Y una segunda frontera que encontré yo, no declarada en ninguna parte** (modelo determinista, no
carrera): **la publicación a medias**. Si el `mv` del destino sale bien y el paso 7 falla —ENOSPC,
permisos—, queda «bloque archivado, origen sin recortar», y `printf … > "$tmp_orig" && mv` **no
tiene rama de error**. La parada siguiente vuelve a archivar las mismas filas y el testigo **no
puede verlo**: sus dos lecturas son frescas y coherentes. Medido: destino con **2 bloques y 3 filas
duplicadas**, `rc = 0`, **sin aviso**. La dirección es la que el archivo declara desde siempre
(«se prefiere un archivo grande a un archivo perdido») y la acepto; lo que no acepto es que
`CA-05` prometa «cero duplicadas … sin ninguna repetida» **sin condición**. Va a `SEC-072`.

**Por qué `en-mitigación` y no `mitigado`.** La remediación de **código** está completa y
acreditada. La de **contrato** no existe todavía, y mi propia regla —`AGENTS.md` §9— dice que un
hallazgo no se cierra mientras su control viva sólo en el código. Aquí el control vive en el
código y el criterio que lo describe **es falso**. `SEC-067` **se mantiene en `Hallazgos abiertos:`
como `usuario/dinero`** y pasa a `mitigado` cuando `SEC-072` esté resuelto — ni un día antes, y me
lo aplico a mí igual que se lo aplicaría a otro.

*Condición exacta de cierre:* que la tolerancia de la ventana de publicar viva **dentro** de
`CA-18 (i)` y que la excepción de la publicación a medias esté declarada en `CA-05`. Nada más.

### 2. `SEC-072` — **`contrato` · abierto · severidad media** — dos promesas escritas en absoluto cuya excepción vive fuera del criterio

**Confirmo el defecto que QA levantó y reclasifico su mitad.** `QA-026-10` punto 2 está clasificado
`instrumento` y **no lo es**: `requirements/README.md` define `contrato` como que el REQ **dice algo
falso sobre lo construido**, y `CA-18 (i)` dice *«entonces **no publica**: el documento conserva
**byte a byte** el contenido de esa escritura ajena»* y *«**ninguna** publicación puede derivarse de
una lectura que ya no describe el disco»* — en absoluto, sin tolerancia. En el residuo de la ventana
de publicar **una publicación sí puede derivarse de una lectura caducada**. Leído al pie de la letra,
como QA dice, `(i)` no se cumple. **La clase se deriva del defecto, no de la conveniencia**, y
etiquetarlo `instrumento` no lo hace dejar de bloquear: bloquea.

**Y una segunda instancia del mismo patrón, medida por mí** (§1): `CA-05` promete «cero filas
perdidas, cero duplicadas … sin ninguna repetida» sin declarar que la promesa no sobrevive a una
publicación a medias.

Son el **mismo** defecto de redacción visto dos veces, y es el que `requirements/README.md`
§«Cómo se escribe un criterio que no se desmiente» nombra: una promesa que **envejece hacia el lado
que abre**. Aquí es peor que envejecer: nace falsa, y su excepción vive en «Notas / alcance», que es
justo lo que nadie lee cuando cita un criterio.

**Remediación (write-back, `analista-requerimientos`).** La tolerancia **dentro** de `(i)`, enunciada
por propiedad y con su magnitud: *no se publica sobre una lectura caducada **salvo** una escritura
ajena que caiga en la ventana de publicación misma —dos `mv` y un `printf`—, que no se puede cerrar
en shell porque POSIX no ofrece renombrado condicional atómico*; y la excepción de la publicación a
medias declarada en `CA-05`. *Vencimiento:* antes de cerrar `REQ-026`. **Bloquea.**

### 3. `SEC-073` — **`contrato` · abierto · severidad alta** — la máquina lee una aprobación PARCIAL como aprobación COMPLETA

Encargo del propietario, y **confirmo el agujero**. `requirements/REQ-026.md:8` declara
`QA: aprobado (… alcance CA-01..CA-12, CA-15 y CA-18 — CA-13/14/16/17 sin implementar …)`.

- La puerta lee el **valor**, `aprobado`. El alcance vive en el **paréntesis**, que `AGENTS.md` §13
  define como **matiz**: *«un veredicto distinto es otro valor, no un paréntesis»*.
- `Hallazgos abiertos:` **no nombra** `CA-13`, `CA-14`, `CA-16` ni `CA-17`. Verificado.
- Consecuencia: vaciada la cola y cerrado lo demás, **nada legible por la máquina** impediría un
  `Estado: completado` con **cuatro criterios contratados y sin implementar**. Es exactamente el
  techo honesto que `AGENTS.md` §13 declara —la máquina no verifica la semántica— y la respuesta
  del arnés a ese techo es el write-back, que aquí falta.

**Elijo la vía (a) del propietario y digo por qué.** La (b) exige vocabulario nuevo y es doctrina, no
mía. La (c) es alcance del propietario y **no la invento**. La (a) —un hallazgo `contrato` que
declara los cuatro criterios— es la única que **no depende de que alguien se acuerde**: queda en el
campo que la puerta lee y deniega el cierre. Es este hallazgo, y por eso está en
`Hallazgos abiertos:`.

**Remediación, y son alternativas, no una lista de tareas.** *(1)* implementar los cuatro; *o (2)*
el propietario reduce formalmente el alcance de `REQ-026` —partiéndolo o moviéndolos a otro REQ—,
con lo que dejan de estar contratados aquí; *o (3)* `Hallazgos abiertos:` los lleva declarados
hasta que ocurra (1) o (2), que es el estado en que los dejo hoy. **Ninguna evidencia se retira:**
lo acreditado por QA y por mí sobre `CA-01..CA-12`, `CA-15` y `CA-18` sigue en pie; lo que faltaba
era que el alcance parcial fuera **visible para la puerta**. *Dueño:* `analista-requerimientos`
(el campo) y **propietario** (la decisión de alcance). **Bloquea.**

### 4. `QA-026-10`: las dos mitades **no** tienen la misma clase, y las separo

| Mitad | Clase | Motivo |
|---|---|---|
| **`(i)` necesita su tolerancia dentro** | **`contrato`** — reclasificada, vive en `SEC-072` | El criterio, leído al pie de la letra, **no se cumple**. Promesa incumplida ⇒ bloquea |
| **`(iv)` ya no está «modelado, no medido»** | **`instrumento`**, sostenido | Es **actualización de un hecho**, no promesa incumplida: el criterio declara un **estado de evidencia** y lo declara **peor** de lo que es. El código no falla; el registro va por detrás, y en la dirección conservadora. No bloquea |

Con una nota para el analista, porque hoy el documento **se contradice consigo mismo**: `CA-18 (iv)`
dice «modelado, no medido» y «Notas / alcance» dice «se midió», con frecuencias. Un REQ que se
desmiente en dos páginas cuesta lo mismo que uno equivocado la primera vez que alguien lo cita.

### 5. La abstención sobre el coste: **la acredito**, y digo qué deja sin resolver

Auditado el razonamiento, no la medición (no la re-medí).

- **Medir no era opcional y el desarrollador encontró su propia regresión**, en la única línea que
  **no** era camino de fallo: guardar el testigo al leer copiaba el documento entero **por archivo y
  por parada**, también donde no se iba a rotar. `140.583` contra `128.742 µs`, **+11.841 µs
  (+9,2 %)**, **por encima** del techo de `CA-15`. Reconstruirlo en el punto de publicación lo deja
  en **cero** fuera del camino de rotación. Que un guardián se midiera a sí mismo y se delatara es
  lo contrario de lo que suele pasar, y lo hago constar.
- **La abstención es la dirección conservadora, y la aritmética lo sostiene.** El brazo de control
  —**código viejo, sin cambios**— se movió un **34 %** y midió **por encima de su propio techo**
  (93.110–141.277 µs). Con el instrumento en ese estado, una comparación absoluta **condenaría
  también al código que era conforme**, y re-derivar sólo podía **subir** el techo: la única
  dirección que `CA-15` no admite sin medición válida. Falta la condición **(ii)** del propio
  criterio —máquina en reposo, una sola comisión viva, sin el banco corriendo—. **No re-derivar era
  lo correcto.**
- **Lo que la abstención deja sin resolver, y hay que decirlo:** la conformidad del código de hoy
  con el techo de `CA-15` **no está establecida**. Los `+3.261` y `+5.659 µs` sugieren que sigue por
  debajo de 140.000, pero salen del mismo instrumento que se declaró no convergente, así que **no
  los tomo por medida**. Es `QA-026-11` (`instrumento`), y estoy de acuerdo con esa clase: el techo
  es cifra **operativa** con dirección **bajar**, y su derivación original tampoco se hizo en el
  *runner* de la puerta requerida. **No bloquea, y no se da por verificado.**

### 6. Estado de los `SEC-*` que traía de `R-021`

- **`SEC-068`** (`instrumento`) — **sigue abierto, sin remediar.** Barrí `docs/qa/1.34.0.md`: no
  aparece `hueco2` ni la distinción de las filas delimitadoras **sin barra inicial** o
  **indentadas**. El argumento de clase sigue nombrando el conjunto de caracteres como portante, y
  seguiría licenciando retirar la guarda que de verdad cierra la clase. *Dueño:* `qa-tester`.
- **`SEC-069`** (`instrumento`) — **NO se cierra: `CA-18 (vii)` lo mitiga en parte, y lo medí.** El
  paso `4b` está **después** de contar entradas y de `[ -n "$viejo" ]`, así que sólo protege el
  camino que **iba a rotar**. Las otras tres ramas de «no se rota» —**ambigua**, **sin entradas
  reconocibles** y **no medible**— retornan **antes** de `4b`. Medido con
  `estado_derivado.activo: false`: la rama **ambigua** y la de **sin entradas** avisan por stderr,
  **no** se escribe bloque derivado (`0`) y **no** salta el guardián de constancia; con el canal
  encendido, `1` línea cada una. Es decir: con el canal apagado, **una sección mal formada sigue
  produciendo un fail-closed invisible**, que es literalmente el daño que `SEC-069` describe.
  El criterio `(vii)` se cumple **literalmente** —con el canal apagado la rotación nunca rota—; lo
  que no se cumple es su **motivo**. *Remediación:* o la comprobación de constancia se decide justo
  después del umbral, **antes** de las tres ramas, de modo que con el canal apagado el artefacto se
  salte entero con un solo aviso; o `CA-08 (v)` declara que con el canal apagado esas tres ramas no
  tienen canal duradero. *Dueño:* `analista-requerimientos` y `desarrollador`. **No bloquea**, y
  **baja de severidad media a baja**: el camino que reescribe contratos ya está cubierto.
- **`SEC-070`** y **`SEC-071`** (`instrumento`) — **sin cambios**, fuera de ventana, ya en
  `docs/PENDIENTES.md`. El rango no los toca ni los agrava; `arnes_lee_archivo` gana **cuatro**
  llamadores nuevos en el rotador, lo que refuerza la familia sin cerrar los dos sitios pendientes.
- **`SEC-058`** (`instrumento`, alta) — **NO se agrava, y de hecho la parte 4 aplica su propia
  remediación.** `PISO_AUTONOMO_SECCION=104` viene con la derivación **término a término y con las
  fronteras** (`19` = 1-19, `57` = 20-76, `28` = 78-105; suma y fronteras cuadran, comprobado por
  mí), que es exactamente lo que `SEC-058` propuso como remediación barata. Sigue abierto lo que ya
  estaba: **ninguna máquina verifica el valor** —`autoprueba-corredor.sh:542` sólo comprueba que el
  piso **exista**, no que sea cierto— y el tercer término sigue siendo un juicio. Y el piso **no
  compra conformidad** aquí: el archivo tiene **184** líneas contra un techo de 400. Instancia
  nueva del patrón, sí; agravamiento, no.
- **`SEC-047`** (`instrumento`, crítica) — **vencimiento vivo y confirmado: el cierre de 1.34.0.**
  No lo re-barrí y **no audité `REQ-023` ni `REQ-024`** (contratos cerrados, cero código), como se
  me indicó. Sólo hago constar que sus remediaciones están despachables, lo que no es lo mismo que
  cumplidas.

### 7. Regresión de seguridad contra la línea base de `R-021` — ningún control retirado ni debilitado

El rango toca `hooks/rotar-artefactos.sh`, `hooks/estado-derivado.sh`, la parte 4 del banco,
`run.sh`, y `.arnes/config.json` + `templates/arnes-config.json.tpl` **sólo** en la frase de
`_doc_artefactos` (cierre de `QA-026-04`, autorizado por el propietario). **Ninguna puerta cambia**:
ni `guard-completado`, ni `guard-codigo`, ni `guard-git`, ni `lib.sh`, ni `hooks.json`, ni
`.github/`.

- **Se refuerza** el fail-closed: cinco ramas de «no se rota» donde había cuatro, todas con salida 0.
- **Se refuerza** el uso del lector fiable: el destino pasa de `cat` a `arnes_lee_archivo` —`cat`
  copiaba «feliz media lectura», y eso era un `SEC-002` latente en el destino que nadie había
  nombrado, ni yo en `R-021`. **Lo hago constar como mejora que no pedí.**
- **Se refuerza** la limpieza de temporales en las salidas de error.
- **Intacto:** la contención léxica y física del destino, el nombre de temporal por proceso en los
  cuatro puntos de publicación, y el orden `rotación → bloque derivado` en el mismo shell de
  `stop.sh`, que es la condición para que los cinco contadores lleguen vivos.
- **Verificado que el acoplamiento nuevo no abre nada:** `ARNES_ROT_CONSTANCIA` se inicializa a
  `true` **antes** del bucle y sólo baja con un `false` **explícito** en el manifiesto; ausente o
  `null` = encendido, que es el lado que no cambia la conducta de un proyecto que no declara nada, y
  el lado que **no** impide rotar. Un manifiesto ilegible sigue retornando sin rotar.
- **`QA-026-04` cerrado, y verifico la clase que le puse en `R-021`:** la frase corregida está en los
  **dos** archivos, incluida la plantilla que heredan todos los proyectos, que es lo que hacía
  `contrato` al hallazgo. **Correctamente cerrado.**

### 8. Repositorio público — sin fuga

Barrido del rango contra los patrones de material de cliente: **cero coincidencias**.

### 9. Rigor

`REQ-026` sigue **`critico`**, que es además su suelo por `Sensible a seguridad: sí`. **No subo ni
bajo el rigor de nada.**

### 10. Lo que esta revisión NO miró — tabulado como NO MIRADO, nunca como PASA

| No mirado | Por qué |
|---|---|
| **El banco** | **No lo ejecuté.** Cito `920 PASS · 0 FAIL · 4 SKIP · rc 0` (total 924) de la coordinadora, verificado dos veces por ella sobre `43bfd47`. **Yo no lo verifiqué**, y el árbol que audito es `4f51293`, dos commits después — ninguno toca `hooks/` ni `tests/`, pero la cifra es de `43bfd47` |
| **La carrera de `CA-18`, la intermitencia de `(iv)` y el coste** | Excluidos por el encargo. **No los re-medí.** Audité el razonamiento y su registro. Las cifras de 295–312 ms, 2/20 y 3/15, 0/20, y las cuatro del coste son **citadas**, no verificadas por mí |
| **La conformidad con el techo de `CA-15` del código de hoy** | **Sin establecer**, por abstención acreditada (§5). No es un pase |
| **El poder estadístico de `(iv)`** (27–49 %, `QA-026-09`) | No re-calculado. Acepto la clase `instrumento` y hago constar que un `0/20` con ese poder **no demuestra ausencia** |
| **La rotación en ejecución sobre REQ reales** | **No la encendí.** Confirmado antes de empezar: `activo: false`, `artefactos: []`, y `requirements/historial/` **no existe**. Todo lo medido va sobre copias en `/tmp` |
| **`CA-13`, `CA-14`, `CA-16`, `CA-17`** | Sin implementar. No los audité — y ése es justamente el objeto de `SEC-073` |
| **`REQ-023` y `REQ-024`** | Excluidos: contratos cerrados, cero código |
| **`SEC-047` condición 2** | Barrido de cabeceras no ejecutado |
| **La ventana de publicar** | Su residuo está **razonado y acotado**, no **medido**: no intenté provocar una escritura dentro de ella, y un caso de reloj ahí sería intermitente (`SEC-030`). La frontera de la **publicación a medias** sí la medí, pero por **modelo determinista**, no por carrera |

### 11. Estado de seguridad aprobado por REQ — línea base de no-regresión, actualizada en R-022

| REQ | Veredicto | Fecha | Alcance acreditado | Nota |
|---|---|---|---|---|
| **REQ-026** (vuelta 2) | **`con-hallazgos`** | 2026-09-09 | `rel/registro-1.33.0` @ `4f51293`, rango `464e0ba..4f51293` | **Qué acredita:** que el testigo de vigencia de `CA-18` está **bien construido** —relectura y comparación byte a byte de los dos archivos, reconstrucción exacta con `fin_nl`, duda hacia no rotar, limpieza de temporales, canal propio— y que **cierra la clase de la actualización perdida en todo lo que el shell puede observar** (§1); que la elección de **no usar cerrojos** es correcta y la sostengo; que la **abstención** sobre el coste es la dirección conservadora (§5); que ningún control se retiró y **cuatro** se refuerzan, con el acoplamiento nuevo fail-safe hacia «encendido» (§7); que `QA-026-04` está **correctamente cerrado** en los dos archivos; y que no hay fuga (§8). **Qué NO acredita:** el banco, la carrera, la intermitencia, el coste, la conformidad con el techo de `CA-15`, y `CA-13`/`CA-14`/`CA-16`/`CA-17` (§10). **Bloqueantes abiertos:** `SEC-072` y `SEC-073`, los dos `contrato` y **ninguno de código**. **`SEC-067` pasa a `en-mitigación`** con su condición de cierre escrita. **Residuales:** `SEC-068`, `SEC-069` (baja a baja), `SEC-070`, `SEC-071`, y `QA-026-11` |
| **REQ-026** (vuelta 1) | `con-hallazgos` | 2026-09-09 | `R-021`, `464e0ba` | **No se retira:** cubre el árbol de entonces. Deja de ser la línea base vigente |
| **REQ-017** (reapertura 1.34.0) | `aprobado` | 2026-09-08 | `R-020` | Sin cambios |
| **REQ-014** (reapertura 1.33.0) | `aprobado` | 2026-09-08 | `R-019` | Sin cambios |

**Estado de mis hallazgos tras R-022:** `SEC-067` **`en-mitigación`** (código acreditado, falta el
write-back de `SEC-072`); `SEC-068` **abierto**; `SEC-069` **abierto**, severidad media → **baja**;
`SEC-070`, `SEC-071` **abiertos**, fuera de ventana; `SEC-072`, `SEC-073` **abiertos** y **bloquean**.

**Numeración vigente tras esta revisión:** última revisión **R-022**; último hallazgo **SEC-073**;
próximos libres **R-023** y **SEC-074**.

**`docs/seguridad/gobernanza-datos.md`: sin cambios.** El rango no altera clasificación de datos,
acceso, retención ni cumplimiento. Lo que sí mejora es la **integridad** del único activo que este
repositorio expone a escritura automática —los contratos de `requirements/`—, y su control es el
testigo de `CA-18`, acreditado aquí.

---

## Revisión R-023 — **REQ-027, primera auditoría**: las reglas de la coordinadora en la sede canónica, **después** de QA, ventana 1.34.0 (`rel/registro-1.33.0` @ `81d260d`, delta real `6dd3f8a` + `cd5dc0c`) — 2026-09-09

**Veredicto: `aprobado`.** No hay código de aplicación aquí: el entregable es **texto de
gobernanza** y **una tabla de decisión** que un agente ejecuta. Audité la tabla como se audita un
guardián —¿qué hace en la duda?— y **es fail-closed**. Los cuatro hallazgos que abro son
`instrumento` salvo uno, y el `contrato` **no es de este REQ**: pertenece a la publicación de
1.33.0 y lo digo explícitamente para que nadie lo aparque en la cabecera equivocada ni lo
reclasifique para desbloquear.

**Corrección de la numeración con la que me despacharon.** El encargo fijaba `SEC-075` como primer
libre porque leyó `SEC-074` como hallazgo. `SEC-074` aparece **una sola vez** en este archivo
(`:6555`), y es la línea «próximos libres» de `R-022`, no un hallazgo. El último **usado** es
`SEC-073` (`:6396`). Numero desde **`SEC-074`**. Es la regla **C** del bloque que este REQ entrega,
aplicada al encargo que lo audita: la medición venía dada y era comprobable, así que se comprobó.

**Corrección de la base del delta.** El encargo pedía re-afirmar que `hooks/`, `tools/`, `.github/`
y `.arnes/config.json` **no cambian** en `973448f..HEAD`. **Cambian, y mucho** —ese rango es la
ventana 1.33.0+1.34.0 entera: `hooks/lib.sh` +245, `hooks/rotar-artefactos.sh` +419,
`tools/arnes-lectura.sh` +41, `.arnes/config.json` ±4, más 39 secciones del banco—. Lo que sí es
cierto, y es lo que importa, va en §5: el delta **de este REQ** son dos commits y **no tocan nada
del mecanismo**.

### 1. Frente 1 — el fail-open de la migración: **la conducta resultante es fail-closed**, y lo acredito

`QA-027-03` está cerrado por QA sobre la **cuenta** (menciones → marcadores). Mi pregunta era otra:
**¿a dónde va la duda?** Auditada la tabla de `skills/arnes-upgrade/SKILL.md:757-762` con su
entorno (`:738-809`):

| Propiedad auditada | Resultado |
|---|---|
| **`UNKNOWN` es terminal, y no sólo local** | **Acreditado.** `SKILL.md:144`: «**Si hay algún `UNKNOWN`, no se aplica nada**». No es un `UNKNOWN` que degrada a saltarse una sección: aborta el plan completo. Un `UNKNOWN` que para y pregunta protege; éste para |
| **La fila de descarte está escrita por PROPIEDAD, no por enumeración** | **Acreditado.** «**cualquier otra cuenta** (2/1, 1/0, 0/1, o el cierre antes de la apertura)» — la propiedad manda y los ejemplos van entre paréntesis. Por eso `2/2`, `3/1` y cualquier par futuro caen en `UNKNOWN` sin que nadie tenga que añadir una fila. Es exactamente el estándar de `requirements/README.md` §«Cómo se escribe un criterio que no se desmiente», cumplido |
| **¿Existe un camino a «no tocar nada y no avisar» con el bloque AUSENTE?** | **No.** El único terminal silencioso es `INTACTO`, que exige `1/1` **y** contenido idéntico al bloque de la plantilla destino (3 702 B). Un archivo sin el bloque no puede tener 3 702 B idénticos entre sus marcadores. **La entrega no se puede evaporar por esta vía** |
| **La normalización del `\r` final, ¿ensancha `INTACTO` de más?** | **No.** Sólo absorbe diferencias que son *puramente* `\r` finales; no hay texto propio de un proyecto que quepa ahí. Y el `cmp` de idempotencia sigue **byte a byte sin normalizar** (`SKILL.md:770-772`), que es donde ensanchar sí habría dolido |
| **Los dos residuos de prosa** | Los dos son terminales y dejan el archivo intacto: cita del marcador entero en un proyecto migrado → `2/2` → `UNKNOWN`; en uno sin migrar → `1/1` distinto → `MODIFICADO` → conflicto. Medidos por QA (§R4) y **coincido en aceptarlos**: la alternativa es distinguir un marcador real de uno citado, o sea interpretar contexto Markdown, que es la clase de detección que produce falsos positivos y acaba con alguien apagando el guardián |

**Conclusión del frente 1:** la conducta es fail-closed en todas las cuentas, y la única dirección
que abría —una cuenta que mandaba a «ya está» sin que el bloque estuviera— es la que `cd5dc0c`
cerró. Lo que queda es `SEC-074`, que es de **coherencia del texto**, no de dirección del fallo.

#### `SEC-074` — **`instrumento` · abierto · severidad baja** — la guarda del `## 14.` vive FUERA de la tabla que se declara «la» decisión

**Ubicación:** `skills/arnes-upgrade/SKILL.md:746-751` (la guarda) contra `:754-762` (la tabla).

**Qué pasa.** La entrada dice «Se decide con la **cuenta** de los marcadores del `AGENTS.md` del
proyecto» y a continuación pone la tabla de cuatro estados. Pero **hay una segunda regla sobre la
misma entrada**, tres bullets antes: si el proyecto ya tiene una sección `## 14.` propia, el número
está tomado → `UNKNOWN`, parar y preguntar. Para el par de cuentas `0/0` con un `## 14.` ajeno, la
**tabla** dice `NUEVO` → *append*, y la **prosa** dice `UNKNOWN` → parar. Dos reglas sobre la misma
entrada, y la operativa —la que se presenta como el procedimiento de decisión— es la permisiva.

**Riesgo, y por qué es bajo hoy y no mañana.** Hoy es bajo: la guarda está en la misma entrada y
**las dos transcripciones independientes la incluyeron** (`docs/qa/REQ-027.md` §R0 declara «2 cuentas
+ guarda de `## 14.` + comparación con `\r` final quitado»), así que nadie la ha leído de menos.
Sube en el momento en que esta entrada se convierta en **script** —y `CA-10` deja pendiente
exactamente esa vía—, porque quien implemente «la tabla» implementará la tabla. El daño no es
perder las reglas: es un `## 14.` duplicado en el documento canónico del proyecto, que rompe **en
silencio** las referencias `§N` que la propia entrada nombra como el motivo de no renumerar.

**Remediación (write-back de una fila, no de un párrafo):** llevar la guarda **dentro** de la
tabla, como precondición de la fila `0/0` —«`0/0` **y** ningún `## 14.` propio | `NUEVO` | añadir al
final»— y una fila `0/0` **con** `## 14.` propio → `UNKNOWN`. Dueño **`desarrollador`**. **No
bloquea** este REQ: no cambia la dirección del fallo en ninguna cuenta ya cubierta y es un texto
del propio arnés (regla de acumulación del propietario, 2026-09-08).

### 2. Frente 1, segunda mitad — **sí queda otra vía de no-entrega silenciosa, y no es de este REQ**

#### `SEC-075` — **`contrato` · abierto · severidad media** — no existe entrada «Hacia 1.33.0», y la ausencia es indistinguible de «no hacía falta»

**Ubicación:** `skills/arnes-upgrade/SKILL.md` — `### Hacia 1.32.1` (`:617`) salta directo a
`### Hacia 1.34.0` (`:738`). Cero apariciones de una entrada 1.33.0.

**Medido, no supuesto.** `v1.33.0` **es un tag existente** y **es la versión del plugin instalado**
(`.claude-plugin/plugin.json` → `1.33.0`). Y esa versión **sí cambió andamiaje que los proyectos
heredan**: `git diff --stat v1.32.1..v1.33.0 -- templates/ agents/ skills/ playbooks/` →
`templates/requirements-README.md.tpl | 64 ++ / 6 --`, y lo añadido es doctrina, no cosmética
(«Fijar la magnitud equivocada», «techo con la dirección admitida declarada, y **nunca** como
igualdad», «el estadístico es el **MÍNIMO** de k repeticiones, nunca la media», una sección nueva
«En la Definition of Ready del analista»).

**Consecuencia:** un proyecto que migre de 1.32.1 a 1.33.0 —la migración que **hoy** correría
cualquiera, porque 1.33.0 es la publicada— **no recibe nada de eso, y nadie se lo dice**. Y el
archivo establece la convención contraria explícitamente: «*(1.17.0 y 1.18.0 no requieren
migración: sólo tocaron el plugin.)*». Con esa convención en pie, un hueco sin nota **no se lee como
hueco**: se lee como «no hacía falta».

**Subo la clase, y digo contra quién.** QA lo vio y lo encoló en `docs/PENDIENTES.md:2309` como
`instrumento`, fuera de alcance. **Discrepo de la clase, no del alcance.** Aplico el forzador que el
propietario usó el 2026-09-08 para reclasificar `QA-027-03`: *un fail-open que hace que un proyecto
nunca reciba lo contratado, sin aviso, no daña un control que mide el producto — **derrota la
entrega***. Aquí lo evaporado es doctrina de gobernanza sobre cómo se escriben los criterios de
coste, entregada por contrato a proyectos instalados. La cláusula de `AGENTS.md` §6 que manda a
`instrumento` habla de **guardianes, lectores y pruebas**; `arnes-upgrade` no mide nada: **es el
canal de entrega**. Y el repositorio ya tiene la demostración **medida** de que estos marcadores
mueren sin que nadie lo note: `docs/PENDIENTES.md:152` (`D-5`, «cero apariciones, no puede
dispararse nunca»).

**Alcance del bloqueo, escrito para que no se pueda malinterpretar en ninguna de las dos
direcciones:**
- **NO bloquea `REQ-027`** y **no va a su `Hallazgos abiertos:`**. No falsea ningún criterio suyo:
  su entrada `Hacia 1.34.0` existe, es correcta y es fail-closed. Bloquear este REQ por la omisión
  de otra versión sería tomarlo como rehén, contra la regla **B.4** («corregir sin ampliar») del
  bloque que él mismo entrega.
- **SÍ debe resolverse antes de publicar `v1.34.0`**, porque ese tag hace de 1.33.0 una versión
  intermedia que ya nadie volverá a mirar, y el hueco queda enterrado. La decisión del tag es del
  propietario (lectura global del 2026-09-08) y **no** de esta firma; esto es insumo para ella.

**Remediación:** o una entrada `### Hacia 1.33.0` con la migración real de
`templates/requirements-README.md.tpl`, o —si se juzga que no la necesita— **la nota explícita**, con
la forma que el propio archivo ya usa para 1.17.0/1.18.0. Lo que no vale es el silencio, porque el
silencio ya significa otra cosa en este archivo. Dueño **`desarrollador`**.

### 3. Frente 2 — el residual de `CA-10`: **aceptable para cerrar**, y las dos grietas que registro sin vetar

**Decisión: el residual es aceptable.** Lo que se cierra declara que la **invocación real de
`/arnes-upgrade` nunca se ejecutó**, que lo acreditado es la **conducta transcrita** (dos
transcripciones independientes, `desarrollador` y QA, con los patrones extraídos del **texto
literal** de la skill), y que la vía real queda **pendiente** con dueño `coordinadora`, vencimiento
«antes de que un proyecto real migre a 1.34.0» y puntero a `docs/qa/REQ-027.md` §D3.

**Por qué lo acepto, en tres pasos:**
1. **`CA-10` contrata una conducta, y la conducta se comprobó.** El criterio dice él mismo que «la
   idempotencia es la **conducta** de buscarlo antes de insertar, y **es lo que se comprueba**». Dos
   transcripciones independientes coincidieron. Lo acreditado es lo contratado.
2. **La imposibilidad está probada, no alegada.** `skills/arnes-upgrade/` tiene un solo `SKILL.md`,
   `.claude-plugin/plugin.json` no declara `commands`, no existe `commands/`. **Ningún script puede
   acreditar la vía real**; hace falta una sesión. Exigir en esta firma algo que el árbol no permite
   producir sería pedir una firma falsa, no más seguridad.
3. **El write-back ya hizo lo que un veto habría exigido.** `QA-027-07` era exactamente esto —deriva
   por omisión— y se cerró llevando el pendiente **al contrato** (`requirements/REQ-027.md:176-187`),
   no a un log. La cláusula se inserta **antes** del párrafo que fija la condición de entrega, y ese
   párrafo llega intacto y sigue siendo la última palabra de `CA-10`. Verificado.

**Lo que NO acredita esta aprobación, dicho aquí para que no se pueda citar de más:** que
`/arnes-upgrade` funcione. Cuando esa corrida exista, **se audita en su turno**; esta firma no la
cubre.

#### `SEC-076` — **`instrumento` · abierto · severidad media** — el pendiente de `CA-10` sobrevive sólo donde nadie va a mirar

Dos mitades, y las dos son sobre **dónde vive** el pendiente, no sobre si está declarado:

**(a) No está en la cola que el repositorio lee antes de actuar.** `grep 'REQ-027'
docs/PENDIENTES.md` → **2 apariciones**, y ninguna es ésta (son el hueco de 1.33.0 y el de
`:717-718`). El pendiente vive en `CA-10` de un REQ que va a pasar a `completado`, en
`docs/qa/REQ-027.md` §D3 y en el `CHANGELOG.md`. **Ninguno de los tres es la cola.** Un vencimiento
—«antes de que un proyecto real migre a 1.34.0»— que **ningún observador puede disparar** necesita
estar donde se mira, y un REQ cerrado no se relee.

**(b) El mecanismo de re-derivación está en `/tmp`, y `/tmp` es volátil por definición.**
`docs/qa/REQ-027.md:681` cita el constructor como `/tmp/construir-maqueta-req027.sh` y **sólo cita la
ruta**: comprobado, el archivo existe (2 701 B, 09:21 de hoy) y **su contenido no está en ninguna
parte del repositorio** (`grep -rn 'construir-maqueta-req027' docs/ requirements/` → una sola línea,
la de la cita). Es la regla **B.7 / `CA-11`** que **este REQ entrega**, incumplida sobre su propio
pendiente, y por la **propiedad** que `CA-11` enuncia, no por su enumeración: «entra toda evidencia
cuya ausencia obligaría a re-medirla o re-enumerarla para cumplir algo ya escrito —un criterio, un
REQ abierto, **una fase pendiente**—». La corrida de la vía real es esa fase pendiente. Un reinicio
y la maqueta se rehace desde cero.

**Remediación:** (a) una línea en `docs/PENDIENTES.md` con dueño, vencimiento y puntero a §D3 —dueño
`coordinadora`—; (b) el **contenido** del constructor dentro de `docs/qa/REQ-027.md` (o en el
repositorio), con su versión base `4f647c7`, que ya está declarada —dueño `qa-tester`—.

**Por qué `instrumento` y no `contrato`:** el pendiente **sí está declarado en el contrato**, que es
lo que `AGENTS.md` §9 exige y lo que `QA-027-07` cerró; esto hace la ejecución más cara y más
olvidable, no la borra del contrato. **Recomiendo hacer (b) antes de la fusión humana**, porque
cuesta un `cat` hoy y una comisión dentro de un mes.

#### `SEC-077` — **`instrumento` · abierto · severidad baja** — rutas de `/tmp` con nombre fijo en el fragmento de verificación que los proyectos copian

**Ubicación:** `skills/arnes-upgrade/SKILL.md:781`, `:785`, `:787` (`/tmp/agents-antes.md`,
`/tmp/agents-tras-1a-corrida.md`) y la misma forma preexistente en `:635-636`
(`/tmp/estado-antes.md`).

**Dos riesgos, los dos conocidos en esta casa.** (i) Es **la misma clase que este repositorio ya
pagó**: hasta 1.32.0 el temporal del hook de continuidad tenía **nombre fijo** y por ahí se perdió
texto humano **1 de 25** vueltas del banco (`AGENTS.md` §13, `REQ-015`). Aquí el efecto no es
perder el `AGENTS.md` del proyecto —el fragmento sólo **lee** el destino— sino un **veredicto de
idempotencia falso**: dos migraciones concurrentes comparten el archivo «antes», y el `cmp` puede
declarar idempotente lo que no lo es, o lo contrario. (ii) Es un nombre **predecible en un
directorio compartido y escribible por todos**: en una máquina multiusuario o un runner compartido,
un `cp` sobre un `/tmp/agents-antes.md` pre-creado como enlace simbólico escribe donde apunte el
enlace. Clásico, barato de cerrar.

**Remediación:** `mktemp` (o un sufijo con el PID) en los tres sitios, que es lo que `hooks/` ya hace
desde 1.32.1. Dueño **`desarrollador`**. **No bloquea:** el fragmento es guía de verificación, no el
publicador, y el arreglo es de una línea por sitio.

### 4. Frente 3 — `CA-07`: la cobertura declarada es **honesta**, y lo verifiqué en los dos sentidos

Auditado el texto del bloque desde el disco (`AGENTS.md:492-502`):

| Propiedad | Resultado |
|---|---|
| Cada herramienta con **vía y estado** | **PASA.** Claude Code `verificada`; Codex `no verificada`; Cursor `no verificada` |
| La única `verificada` **lo está de verdad** | **PASA, y lo comprobé yo**: `CLAUDE.md:6` y `templates/CLAUDE.md.tpl:6` contienen `@AGENTS.md`. Un estado `verificada` falso habría sido el hallazgo grave de este frente, y no lo es |
| Codex se declara con su **motivo** | **PASA.** «Vía: la que declara el estándar `AGENTS.md`; esa frase es una **afirmación del repositorio, no una comprobación**». Es la distinción correcta: el archivo diciendo de sí mismo que Codex lo lee no es evidencia de que Codex lo lea |
| Límite (a) escrito | **PASA.** «una herramienta cuya vía no está verificada **no cuenta como cubierta** —esta sección **no promete cobertura de todo coordinador**—» |
| Límite (b) escrito | **PASA.** «un proyecto ya instalado tiene su `AGENTS.md` **congelado**: hasta que `arnes-upgrade` migre este bloque, sus coordinadoras **no tienen estas reglas**» |
| **Barrido activo de sobreafirmación** | **PASA.** Leído el bloque entero buscando la frase que promete de más: no hay ninguna que insinúe cobertura universal, ni que presente una vía no comprobada como cubierta, ni que dé por hecho que los proyectos instalados ya tienen las reglas. El límite (b) se repite además en la propia skill (`:807-809`) |

**Y un refuerzo que merece constar, porque es el riesgo que el propio REQ nombra como su motivo de
`critico`.** La regla **B.5** del bloque —«cerrar cuando la evidencia alcance»— es la que el REQ
teme leída como permiso para cerrar antes (`requirements/REQ-027.md:310-312`). El texto entregado
cierra esa puerta **explícitamente**: `AGENTS.md:471-473` añade «**no es permiso para cerrar con
menos de lo que el criterio pide**», cláusula que **no** está en la lista del REQ (`:240-241`). El
bloque es más seguro que su propia especificación, y en la dirección correcta. No es hallazgo:
`CA-02` contrata los **títulos** y el REQ declara que «el texto final vive en el bloque».

### 5. Frentes 4 y 5 — doble sede idéntica, y el mecanismo intacto

**`CA-01` — las dos copias no han divergido. Verificado por identidad, no por parecido:**

| Comprobación | Resultado |
|---|---|
| `diff` de los dos tramos | **vacío** |
| `md5sum` | **idéntico** en los dos: `89cea66e4cea6575026252566350f18c` |
| `wc -c` | **3 702 B** los dos — cuadra con la distinción de `CA-05` (3 702 el bloque / 3 703 lo que añade al archivo) |
| Marcadores | **exactamente 1** de apertura y **1** de cierre en cada archivo (`AGENTS.md:453,503`; `templates/AGENTS.md.tpl:420,470`) |
| `{{…}}` **dentro** del bloque de la plantilla | **0** — `CA-09` no puede entregar un marcador literal en la sede canónica |
| `{{…}}` del **resto** de la plantilla | **15**, intactos |
| `CA-06`, renumeración | **Ninguna.** `grep -oE '^## [0-9]+\.' AGENTS.md \| sort \| uniq -d` → **vacío**; 15 títulos (§0–§14), el bloque entra como sección propia al final |

**El mecanismo NO se toca — re-afirmado sobre la base correcta.** El delta de este REQ son
`6dd3f8a` y `cd5dc0c`. `git show --name-only 6dd3f8a cd5dc0c` filtrado por
`hooks/|tools/|.github/|.arnes/|tests/` → **cero archivos**. Los seis tocados son `AGENTS.md`,
`templates/AGENTS.md.tpl`, `skills/arnes-upgrade/SKILL.md`, `requirements/REQ-027.md`,
`docs/qa/REQ-027.md` y `CHANGELOG.md`. **Ningún hook lee este bloque, ninguna clave nueva en
`.arnes/config.json`, ninguna puerta lo comprueba** — y la skill lo dice de sí misma (`:806-807`),
que es la forma honesta de entregar una regla sin enforcement.

### 6. Regresión de seguridad — **ningún control retirado ni debilitado**

Primera auditoría de `REQ-027`: **cero apariciones** previas en este archivo, confirmado. No hay
`R-0xx` anterior contra la que comparar, así que la comparación va contra los controles **vigentes**
que este delta podría haber tocado:

- **Ningún control retirado.** El delta es **+174 / −0** en los tres archivos de producto. Nada se
  borró.
- **Un control reforzado:** `cd5dc0c` no sólo cambió menciones por marcadores; añadió **la cuenta
  del cierre**, que las filas `1/0`, `0/1` y `2/1` de la tabla siempre necesitaron y **ningún
  comando calculaba**. Con las dos cuentas, incluso la forma vieja del patrón deja de fallar en
  abierto. El mérito es del `desarrollador` y QA lo acreditó; lo hago constar porque una auditoría
  que sólo anota lo que empeora no mide la dirección del cambio.
- **`SEC-047`, `SEC-048`, `SEC-049`, `SEC-058`, `SEC-064`, `SEC-067`, `SEC-072`, `SEC-073`:** este
  rango **no los introduce ni los agrava**. No toca `hooks/`, `tools/` ni `tests/`, que es donde
  viven todos.
- **Fuga de material de cliente:** barrido del delta contra los patrones de material de cliente y
  de secretos —**cero coincidencias**. El repositorio es público y el delta es doctrina de
  coordinación; no hay credencial, ruta interna ni dato de cliente. Lo único citado son rutas de
  `/tmp` de este propio repositorio (`SEC-077`).

### 7. Rigor

`REQ-027` sigue **`critico`**, que es además su suelo por `Sensible a seguridad: sí`. **No subo ni
bajo el rigor de nada.** Comprobado que la sensibilidad es la correcta: no toca autenticación,
autorización, datos personales ni secretos, pero gobierna **el documento canónico que leen los
agentes de todos los proyectos que instalan el arnés**, y una regla mal redactada ahí debilita el
criterio de cierre en todos ellos y en silencio — la propiedad de fallo en abierto que `AGENTS.md`
§6 usa para llamar crítico a algo.

### 8. Lo que esta revisión NO miró — tabulado como NO MIRADO, nunca como PASA

| No mirado | Por qué |
|---|---|
| **El banco** | **No lo ejecuté.** Y no lo cito de nadie: QA declara expresamente que **no suscribe** ninguna de las dos cifras en circulación (`961/0/4` y `960/0/5`) y que `skills/` **no está en el banco**. Así que sobre este delta el banco **no acredita nada** en ninguna dirección, y no lo presento como verde |
| **La vía real de `/arnes-upgrade`** | **Imposible desde aquí** y es el objeto de §3. Ningún script la acredita; hace falta una sesión. Lo acreditado es la conducta transcrita |
| **Codex y Cursor** | Siguen `no verificada`. **No las verifiqué** —está fuera de este REQ por `CA-07`—, y la consecuencia es la que el bloque ya declara: el objetivo se entrega, verificado, para **una** de las tres herramientas |
| **`CA-03` y `CA-04`** | Siguen **sin mecanismo**: son reglas para quien coordina y ninguna puerta las mide. Auditado el **texto**, no su cumplimiento futuro. `REQ-025` es la puerta candidata y no entra aquí |
| **`CA-08`** | **Incompleto por construcción**, su señal (c) pendiente con dueño `coordinadora`. No lo audité y **no lo doy por bueno**; su consecuencia contratada sigue vigente: **no se declara que las reglas sirven** |
| **El desglose por tramos de `CA-05`** | **No lo re-medí.** Verifiqué sólo las dos magnitudes que sostienen `CA-01`/`CA-05` (3 702 y la identidad de las copias). Las cifras de `1 037` / `807` / `1 844` / `49,8 %` son de QA (`§R2`), **citadas** |
| **`docs/PENDIENTES.md`, `docs/PLAN.md`, `docs/ESTADO.md`, `CHANGELOG.md`, otros REQ** | **No leídos** (excluidos por coste). Sobre `PENDIENTES.md` sólo corrí `grep` dirigido, cuyo resultado está citado en `SEC-075` y `SEC-076`; de `CHANGELOG.md` no leí nada y sus contenidos los cito **de QA**, no verificados por mí |
| **Si 1.33.0 requería además otras migraciones** | **No lo determiné.** Medí `templates/`, `agents/`, `skills/` y `playbooks/` entre `v1.32.1` y `v1.33.0`, que basta para que `SEC-075` exista; **no** enumeré qué migración concreta hace falta. Eso es del dueño del hallazgo |

### 9. Estado de seguridad aprobado por REQ — línea base de no-regresión, actualizada en R-023

| REQ | Veredicto | Fecha | Alcance acreditado | Nota |
|---|---|---|---|---|
| **REQ-027** (1.ª auditoría) | **`aprobado`** | 2026-09-09 | `rel/registro-1.33.0` @ `81d260d`; delta real `6dd3f8a` + `cd5dc0c` (+174 / −0) | **Qué acredita:** que la tabla de decisión de la migración es **fail-closed** en todas las cuentas, con `UNKNOWN` **globalmente** terminal (`SKILL.md:144`) y la fila de descarte escrita **por propiedad** (§1); que **no existe camino a «no tocar y no avisar» con el bloque ausente** (§1); que `CA-07` es **honesta** y que su único estado `verificada` **lo está de verdad**, con los dos límites escritos y sin sobreafirmación de cobertura (§4); que las **dos sedes son idénticas** por `md5` y `diff`, con un solo par de marcadores, 3 702 B, sin `{{…}}` dentro y **sin renumerar** ninguna sección (§5); que el **mecanismo no se toca** (§5); que **ningún control se retiró** y uno se **reforzó** —la cuenta del cierre— (§6); y que **no hay fuga** de material de cliente (§6). **Qué NO acredita:** el banco, la **vía real de `/arnes-upgrade`**, Codex/Cursor, `CA-03`/`CA-04` (sin mecanismo), `CA-08` (incompleto) y el desglose de `CA-05` (§8). **Bloqueantes abiertos de este REQ: ninguno.** **Residuales:** `SEC-074`, `SEC-076`, `SEC-077` (los tres `instrumento`) y `QA-027-08` (`instrumento`, de QA). **`SEC-075` es `contrato` y NO es de este REQ**: es de la publicación de 1.33.0, no va a su `Hallazgos abiertos:` y **no lo bloquea** |
| **REQ-026** (vuelta 2) | `con-hallazgos` | 2026-09-09 | `R-022`, `4f51293` | Sin cambios. `SEC-072` y `SEC-073` siguen abiertos y **siguen bloqueando** ese REQ |
| **REQ-017** (reapertura 1.34.0) | `aprobado` | 2026-09-08 | `R-020` | Sin cambios |
| **REQ-014** (reapertura 1.33.0) | `aprobado` | 2026-09-08 | `R-019` | Sin cambios |

**Estado de mis hallazgos tras R-023:** `SEC-074` **abierto** (`instrumento`, baja, dueño
`desarrollador`); `SEC-075` **abierto** (`contrato`, media, dueño `desarrollador`, **contra la
publicación de 1.34.0, no contra REQ-027**); `SEC-076` **abierto** (`instrumento`, media, dueños
`coordinadora` y `qa-tester`); `SEC-077` **abierto** (`instrumento`, baja, dueño `desarrollador`).
Sin cambios en `SEC-067`..`SEC-073`.

**Numeración vigente tras esta revisión:** última revisión **R-023**; último hallazgo **SEC-077**;
próximos libres **R-024** y **SEC-078**.

**`docs/seguridad/gobernanza-datos.md`: sin cambios.** Este delta no altera clasificación de datos,
acceso, retención ni cumplimiento: no hay datos personales, credenciales ni activos nuevos. Lo que
cambia es **gobernanza de proceso** —cómo se despachan y cierran las comisiones—, cuya sede es
`AGENTS.md`, no el documento de datos. La única propiedad de seguridad con la que este REQ se
relaciona es la **integridad de la entrega a proyectos instalados**, y su control es la tabla de
decisión de `arnes-upgrade`, acreditada fail-closed en §1 con la excepción de `SEC-075`.

---

## Revisión R-024 — **REQ-023, primera auditoría**: la guarda de medibilidad de la cabecera, **después** de QA, ventana 1.34.0 (`rel/registro-1.33.0` @ `390a0a2`; rango del encargo `5305de9..390a0a2` **más** el delta de código `43bfd47..390a0a2`, ver §0) — 2026-09-09

**Veredicto: `con-hallazgos`.** La guarda **está bien construida** y cierra en el código la mitad 1
de `SEC-047` que venía a cerrar: la ejercí yo, con la puerta real, y **no encontré ninguna vía por
la que abra lo que vino a cerrar** (§1). Lo que abro es **uno de clase `contrato`**, y no está en el
código: está en **el texto que todos los proyectos heredan**. La fila nueva de `AGENTS.md` §13 —y su
gemela de `templates/AGENTS.md.tpl`— afirma **sin condición** una propiedad que la máquina **no**
tiene, y lo afirma con una lista **cerrada** de tres fronteras que **no** incluye la vía que este
mismo REQ declara abierta en «Fuera de alcance». Es exactamente el **forzador** que ese apartado se
escribió a sí mismo, y por eso el hallazgo es `contrato` y **bloquea**: no por lo que el código hace,
sino por lo que el contrato promete que hace.

`REQ-023` sigue **`Estado: bloqueado`** por decisión del propietario, y **mi firma no lo desbloquea
ni pretende hacerlo**: acredita la revisión de seguridad sobre este árbol.

### 0. Corrección del alcance con el que me despacharon — **el código de este REQ NO estaba en el rango**

El encargo fijaba `5305de9..390a0a2`. Medido: ese rango **no contiene ni una línea de `hooks/` ni de
`tools/`**.

```
git diff --stat 5305de9..390a0a2 -- hooks/ tools/ .github/ .arnes/ .claude-plugin/   # vacío
```

La guarda que `CA-01`–`CA-09` contratan vive en `e406202` y `29b06eb` —el segundo es el commit
rotulado «WIP REQ-023 **SIN ACREDITAR**»—, los dos **anteriores** al rango. Y `Seguridad:` decía
`pendiente`, así que **nadie había auditado ese código nunca**. Auditar sólo el rango del encargo
habría producido una firma sobre el REQ cuya evidencia no incluía su mecanismo: exactamente la
«firma parcial que se lee como sello» que `AGENTS.md` §6 nombra. **Amplié el alcance al delta real
del REQ**, que es el único cambio de mecanismo entre `43bfd47` y `390a0a2`:

| Archivo | + | − |
|---|---:|---:|
| `hooks/lib.sh` | 286 | 4 |
| `hooks/guard-completado.sh` | 33 | 0 |
| `tools/arnes-lectura.sh` | 30 | 11 |

Es la regla **C** de `AGENTS.md` §14 aplicada al encargo que me despacha: el rango venía dado y era
comprobable leyendo el disco, así que se comprobó.

### 1. La guarda: qué acredito **ejecutándola**, y las cuatro preguntas de un guardián

Ejercí `hooks/guard-completado.sh` con su entrada JSON real sobre un proyecto de prueba con el
manifiesto base (evidencia y método: mis dos sondas, reproducibles en tres minutos con el patrón de
`ver_corre`/`emite_write` de `tests/escenarios/hooks/run.sh:118-122` y `:340`).

| Propiedad auditada | Resultado |
|---|---|
| **¿Puede la guarda abrir algo que antes cerraba?** | **No.** El delta es **aditivo en decisiones**: dos ramas `arnes_deny` nuevas y ninguna condición de `deny` existente relajada. Las **cuatro** únicas líneas borradas de `lib.sh` son sustituciones equivalentes: los dos literales `'Estado'` de `arnes_estado_cabecera` pasan a `"$ARNES_CLAVE_ESTADO"` **entre comillas** (patrón literal, no glob), y `arnes_campo_linea` explicita el `|| return 1` que antes heredaba del último comando |
| **¿Adónde va la duda?** | **Al lado que cierra.** El motivo lo dice y el código lo hace: no deniega por «el campo falta» —eso sería un `allow` con otro nombre— sino por **no medible**, y publica además el estado que esa misma línea declaraba (`ARNES_OCULTA_ESTADO`), sin lo cual un invisible sobre `Estado:` se habría resuelto como «aquí no hay transición» |
| **La asimetría con la guarda del CR: ¿es un hueco?** | **No, y la verifiqué porque parecía uno.** La rama del CR **no** admite `est_antes` como eximente («preguntarle al defecto si hay defecto»); la de `ARNES_OCULTA` **sí**. La diferencia está justificada por construcción: el CR **lo retira el normalizador** (`local l="${1//$'\r'/}"`), así que puede **fabricar** un `Estado: completado` válido; lo que esta guarda detecta **no se retira nunca**, así que sólo puede **destruir** una clave, jamás fabricarla. Comprobado sobre el mapa real: ningún miembro de la clase produce una clave del lector |
| **El mapa `sin-blancos → clave`, ¿es ambiguo?** | **No, por construcción.** Medido: `\|QA\|QA\|Seguridad\|Seguridad\|Sensibleaseguridad\|Sensible a seguridad\|Hallazgosabiertos\|Hallazgos abiertos\|Rigor\|Rigor\|Estado\|Estado\|`. Lo que se busca nunca lleva blancos, y toda clave sin blancos es idéntica a su forma sin blancos, así que el primer `\|x\|` es siempre el campo izquierdo de un par. Vale igual para cualquier clave futura |
| **Inyección en la salida del hook** | **Cerrada.** El motivo interpola `ARNES_OCULTA_REPR` —construido con **whitelist** de alfabeto, todo lo demás a `\xNN`— y `ARNES_OCULTA_CLAVE`, que es la clave **canónica de la constante**, no la del documento. Y `arnes_deny` emite con `jq -cn --arg` (`hooks/lib.sh:190-194`), que escapa: la barra invertida de `\xNN` **no** rompe el JSON. Verificado: `jq` parsea las respuestas de mis sondas |
| **`ARNES_CLAVES` como punto único, ¿se puede apagar desde fuera?** | **No.** `hooks/lib.sh:1703-1709` son asignaciones **incondicionales** (no `${VAR:-…}`), así que el entorno no puede vaciarlas. Si pudiera, vaciarla habría apagado a la vez la guarda **y** los cinco brazos de `arnes_campos_req`, que desde este REQ pasan por `arnes_en_vocab "$ARNES_CLAVE" "$ARNES_CLAVES" \|\| continue`: el fallo habría sido **en abierto y total**. Lo miré por eso, y no está |
| **El alfabeto derivado, ¿puede romper la expresión de corchete?** | **No hoy, y la vía está cerrada para el futuro.** Medido: `ALFA=[QASeguridansbl HzotRE]` — 21 caracteres, sin `-`, sin `]` y sin `^`. `_arnes_deriva_alfabeto` los coloca donde son literales aunque una clave futura los traiga, que es lo que impide que la expresión rota **calle** en vez de denegar |
| **Coste en la ruta caliente de la puerta** | **Cero procesos añadidos** (sólo expansión de parámetros y `printf -v`), y `LC_ALL=C` **local** a las dos funciones: la comparación es de bytes, así que el veredicto no depende de `LC_CTYPE` — que era el único eje por el que este cambio podía **denegar en el CI de Linux y permitir en Windows/MSYS**, un fallo en abierto **por entorno** e invisible en la puerta requerida |
| **El informe como control compensatorio (`CA-07`)** | **Acreditado en su punto crítico.** `tools/arnes-lectura.sh` emite la anomalía **antes** del descarte «este archivo no tiene `Estado:`, no es un REQ», que es justamente donde se escondía el caso peor: con el carácter sobre la clave del estado, el informe salía `rc=0` sobre el documento más peligroso que hay |
| **Falsos positivos sobre el corpus real** | **Cero.** Corrí `tools/arnes-lectura.sh .` sobre los **27** REQ de este árbol: `rc=0`, «Ningún valor anómalo». `Módulo:`, `Versión destino:`, `Archivos:`, `Prioridad:` y los títulos **no** disparan nada. Importa porque una guarda que roza lo legítimo produce fricción constante, y la fricción termina con alguien apagando el guard |

**Y un control que este REQ REFUERZA, y lo hago constar porque una auditoría que sólo anota lo que
empeora no mide la dirección del cambio:** `arnes_estado_cabecera` era el **único** sitio donde vivía
la clave del estado terminal, tecleada como literal. Ahora deriva de la constante, así que la clave
que **decide el cierre** queda cubierta por la guarda desde el mismo sitio que las otras cinco. Ése
era el hueco que `CA-01` documenta como medido (un puntero que mandaba a «`arnes_campo_linea` y sus
llamadores» dejaba `Estado` fuera), y está cerrado.

### 2. La vía que el código NO cierra, medida por mí, y el puntero que no resolvía

#### SEC-078 — **La sustitución de una letra de la clave por un homóglifo reproduce `SEC-047` completo: cierra un REQ `critico` con `QA: pendiente` y `Seguridad: pendiente`** · `instrumento` · severidad **alta** · **abierto** *(nuevo)*

**Ubicación.** `hooks/lib.sh:1834-1852` (`_arnes_clave_oculta`, la reconstrucción) y la declaración
de frontera de `requirements/REQ-023.md` § «Fuera de alcance» § «La SUSTITUCIÓN de un carácter de la
clave por un HOMÓGLIFO».

**Qué medí, ejecutando la puerta real sobre `390a0a2`.** No es lectura: son veredictos de
`hooks/guard-completado.sh` con su JSON de entrada.

| Cabecera juzgada (el resto del documento, idéntico) | Veredicto |
|---|---|
| `Estado: completado` · **`Sensible a seguridad: sí`** · `QA: pendiente` · `Seguridad: pendiente` | **DENY** (control: la puerta funciona) |
| `Estado: completado` · **BOM** + `Sensible a seguridad: sí` · `QA: pendiente` · `Seguridad: pendiente` · `Rigor: ligero` | **DENY** (`SEC-047` fila 1, cerrada) |
| `Estado: completado` · **`Sensible а seguridad: sí`** (`а` = U+0430, cirílica) · `QA: pendiente` · `Seguridad: pendiente` · `Rigor: ligero` | **ALLOW** ← `SEC-047` fila 1 **reproducida entera** |
| `Estado: completado` · `Sensible a seguridad: sí` · **`Qа: pendiente`** (U+0430) · `Seguridad: aprobado` | **ALLOW** |
| `Estado: completado` · **`Hallazgоs abiertos: SEC-999 (contrato)`** (`о` = U+043E) · `QA: aprobado` · `Rigor: estandar` | **ALLOW** (con el control limpio: **DENY**) |
| **`Еstado: completado`** (`Е` = U+0415) · `Sensible a seguridad: sí` · `QA: pendiente` · `Seguridad: pendiente` | **ALLOW** |
| `Estado: completado` · `Sensible a seguridad: sí` · **`Segurid а d`** | **DENY** (la ausencia del veredicto de seguridad se resuelve del lado que cierra en `critico`) |
| **Control positivo de que la guarda no es una lista de invisibles:** `QA-: pendiente` (guion ASCII, perfectamente visible) | **DENY** |

**El mecanismo, y por qué el código de este REQ no puede verlo.** La guarda retira de la clave lo
ajeno al alfabeto, retira los blancos y pregunta si lo que queda **es** una clave. `Sensible а
seguridad` → retirado lo ajeno → `Sensible  seguridad` → sin blancos → `Sensibleseguridad`, que **no
es** ninguna clave: falta la `a` que el homóglifo sustituyó, y **retirar lo ajeno no repone lo
sustituido**. La guarda **calla**, la línea se resuelve como **ausencia** del campo, y la ausencia
es justo lo que la puerta perdona. Tres de los cuatro campos que `R-013 §2` midió como «su ausencia
ABRE» quedan alcanzables por esta vía.

**Por qué NO lo subo de clase, dicho explícitamente para que nadie lo lea como una omisión.**
`REQ-023` lo declara **fuera de alcance con su reparto completo** —dueños `desarrollador` y
`analista-requerimientos`, ventana **propuesta 1.35.0** que decide el propietario, clase
`instrumento`, forzador escrito— y el motivo es sólido y está medido: reponer *qué* letra exige
elegir entre candidatos, es decir una de las tres salidas que el REQ ya prohibió o encareció
(estrechar el alfabeto, una tabla de homóglifos, o el recorrido cuadrático). **Un reparto declarado
no se reabre porque el auditor vuelva a medir lo mismo.** Mantengo la clase de la familia:
`SEC-047`, del que esto es la mitad no cerrada, también es `instrumento`.

**Y sin embargo este hallazgo tiene que EXISTIR con su número, que es la razón de abrirlo.**
`skills/arnes-upgrade/SKILL.md` § «Hacia 1.34.0» dice de esta vía, en la guía que **todos los
proyectos heredan**, que «es **clase abierta con dueño en el registro**», y fija como **sitio único**
donde viven las vías conocidas este archivo, nombrando `SEC-047`, `SEC-024` y `SEC-025`. Medido antes
de escribir esta entrada:

```
grep -c 'homógl\|homoglifo' docs/seguridad/registro-seguridad.md   # 0
```

**El puntero no resolvía.** Un consumidor que siguiera la única referencia que la guía le da para
separar «ruido legítimo» de «exposición real» no habría encontrado esta vía aquí, y habría concluido
que no es una vía conocida — sobre el caso que su propio barrido **sí** nombra. Con esta entrada la
afirmación de la skill pasa a ser **cierta**, y ésa es la mitad de la remediación que es **mía** y
que ejecuto en el mismo acto de auditar. **Estado del defecto de puntero: `mitigado` por esta
entrada.** El defecto de fondo —la vía— sigue **abierto** con el reparto de arriba.

**Remediación (por propiedad, no por enumeración).** *Ninguna referencia a las vías conocidas de esta
clase se cita fuera de este archivo sin que la vía exista aquí con su número.* Es la misma regla que
`REQ-023 CA-01` aplica a las claves y `CA-02` al dominio de campos, aplicada al **registro**: un
«sitio único» que no contiene lo que se le atribuye es peor que no tener sitio único, porque produce
una lectura tranquilizadora. **Dueño:** `auditor-seguridad` (esta entrada, hecha) y
`desarrollador` + `analista-requerimientos` (la vía, según el reparto de `REQ-023`). **Forzador:** el
de `REQ-023` § «Fuera de alcance», que §3 declara **disparado**. **Vencimiento:** la ventana **1.35.0**
que el propietario decida para la vía, o antes si `SEC-079` la adelanta.

### 3. El hallazgo que BLOQUEA, y no está en el código

#### SEC-079 — **La superficie HEREDADA promete la clase por ESTADO y sin condición, con una lista CERRADA de tres fronteras que no incluye la vía abierta: `CA-10` contrata esa lista, así que el defecto es del criterio** · `contrato` · severidad **alta** · **`mitigado` el 2026-09-09 en R-025** *(abierto en R-024)* — **ya NO bloquea `REQ-023`**

> **Estado `mitigado` (R-025, 2026-09-09).** Las **tres** piezas de la remediación de abajo están
> hechas y **medidas ejecutando la puerta**, no leyendo: `CA-10` ganó la cláusula (dos pases de
> write-back), las **dos** sedes llevan la fila acotada y son **byte a byte idénticas**
> (`md5 3ead3bd3…`, 2 545 B), y el apartado de `skills/arnes-upgrade/SKILL.md` —cuarta sede, que
> este hallazgo no había nombrado— quedó con la misma forma. La entrada **no se borra** y el texto
> de abajo **se conserva íntegro**: la fila que cita como falsa es la de `390a0a2` y sigue siendo
> el **control negativo** con el que se comprueba la conforme. Detalle y mediciones en **R-025**.

**Ubicación.** `AGENTS.md` §13, la fila reescrita por `CA-10`; **la misma fila** en
`templates/AGENTS.md.tpl` §13 (la que reciben los proyectos **nuevos**); y la **letra de
`requirements/REQ-023.md` `CA-10`**, que es lo que las obliga a estar así.

**Qué dice la fila, literalmente, y qué está medido falso.** Dos frases de la fila nueva:

> «Una línea de la cabecera que la máquina **no puede medir** no deja cerrar — la propiedad es el
> **estado**, no el carácter […] Se **deniega** […] y **nunca** se permite por **ausencia** del campo
> que ese carácter borró.»

> «Tres fronteras: el CR/LF **final** es transporte […], el **cuerpo** del REQ no se restringe y
> **reabrir** no se bloquea.»

La primera es una promesa **universal y sin condición**. La segunda **cierra** el conjunto de
excepciones en **tres**. Y la propia fila incluye en su clase, con sus palabras, «un blanco de más
**o puesto en el sitio de otro**» — es decir: **un carácter puesto en el sitio de otro pertenece a la
clase que la fila promete cubrir**. Un homóglifo es exactamente eso. Medido en §2: la máquina
**permite**, y permite **por ausencia del campo que ese carácter borró**. La frase «nunca se permite
por ausencia» es **falsa como está escrita**, y la lista de tres fronteras hace que un lector
concluya lo contrario de lo cierto: que la única vía abierta que queda no existe.

**Y el defecto NO es del `desarrollador` que escribió la fila: es de la letra de `CA-10`.** `CA-10`
exige que la invariante quede escrita «por propiedad […] y **con las tres fronteras conformes**», y
**no** exige nombrar las vías que siguen abiertas. Esa exigencia sólo se le pide al apartado de la
skill —«el **nombre** de las vías conocidas que ese comando no encuentra (sitio único:
`docs/seguridad/registro-seguridad.md`)»—, y **la skill la cumple**: nombra el homóglifo y dice que
«**ninguna** versión lo deniega —tampoco 1.34.0—». Es decir: la guía de migración **es honesta** y el
documento canónico **no lo es**, sobre la misma clase y en la misma ventana. La fila está conforme
con su criterio; **el criterio es el que se queda corto**, y por eso la clase es `contrato` y el
write-back es del `analista-requerimientos` antes que del `desarrollador`.

**Es la forma (a) de `requirements/README.md`, aplicada a las EXCEPCIONES en vez de a los casos, y
por eso pasó tres filtros.** Enumerar «se deniegan estas tres formas» envejece hacia el lado que
abre; enumerar «excepto estas tres fronteras» envejece **hacia el lado que tranquiliza**, que es peor
de detectar porque el texto suena a propiedad. La fila **sí** enuncia la propiedad; lo que falta es
que la lista de fronteras se declare **no exhaustiva** y **cite el sitio único** donde vive la
exhaustiva. Y el propio REQ tenía esto previsto: **`CA-12 (iii)`** prohíbe que «ningún artefacto que
este REQ escriba —criterio, sección del banco o **texto heredado de `CA-10`**— afirme ni sugiera que
la clase quede **cerrada**». La fila es literalmente ese artefacto.

**Y el FORZADOR ya estaba escrito por este REQ, contra sí mismo — dispararlo es lo que hace que
bloquee.** `REQ-023` § «Fuera de alcance», sobre el homóglifo: *«Forzador: que algún texto de este REQ
o de la **superficie heredada** afirme **sin condición** que la guarda cubre la clase del carácter que
no se ve, mientras esta vía siga abierta.»* Es la condición exacta que la fila cumple. **El REQ
predijo su propio modo de fallo y el fallo ocurrió**; no estoy inventando un criterio nuevo, estoy
constatando que se disparó el que el documento ya tenía. De ahí que la salida sea **una de dos, y la
elige el propietario**: (a) la fila y `CA-10` ganan la condición —barata, una cláusula—, o (b) la
vía del homóglifo entra en esta ventana —caro, y con las tres salidas ya medidas como malas—.

**Por qué es `contrato` y no `instrumento`, dicho contra el argumento fácil.** No es un defecto de
una prueba del arnés: es el **documento canónico** que `arnes-upgrade` lleva a cada proyecto
instalado y que `arnes-init` escribe en cada proyecto nuevo, y su lector es **una persona o una
coordinadora que decide en función de él** si su cierre está protegido y si tiene que auditar sus REQ
cerrados. Un requerimiento que dice algo falso sobre lo construido es `contrato` por la letra de
`requirements/README.md`, y **bloquea hasta el write-back**. Nada de esto se apoya en interpretación:
la frase es universal, la medición la contradice, y el forzador que la convierte en bloqueante lo
escribió el propio REQ.

**Remediación, en tres piezas y en este orden.**
1. **`analista-requerimientos` — `CA-10`:** que la exigencia sobre la superficie heredada pida, además
   de la propiedad, (i) que la lista de fronteras se marque **«no exhaustiva»** y (ii) que **cite el
   sitio único** donde vive la exhaustiva (`docs/seguridad/registro-seguridad.md`), con la misma letra
   que `CA-10` ya le pide al apartado de la skill. Es simetría entre dos mitades del mismo criterio,
   no alcance nuevo.
2. **`desarrollador` — la fila**, en `AGENTS.md` §13 **y** en `templates/AGENTS.md.tpl`, las dos, que
   hoy son idénticas y tienen que seguir siéndolo.
3. **`qa-tester`** re-valida esas dos cláusulas y **luego** yo firmo. No al revés.

**Lo que este hallazgo NO dice.** No dice que la guarda esté mal —§1 la acredita—, ni que la vía del
homóglifo tenga que cerrarse en esta ventana —§2 mantiene su reparto—, ni que la skill esté mal —es
la pieza honesta del entregable—. Dice **una** cosa: el texto que los proyectos heredan promete más
de lo que la máquina hace, y su forzador estaba escrito.

### 4. La abstención, y la mitad que `SEC-064` no cubre

#### SEC-080 — **Un umbral de la puerta requerida cuyo veredicto lo decide el RUIDO DE LA MÁQUINA, y cuya abstención se reporta con el mismo `rc` que un verde: `CA-09 (iii)` sólo puede afirmarse midiendo lo contrario de lo que vigila** · `instrumento` · severidad **media** · **abierto** *(nuevo)*

**Ubicación.** `requirements/REQ-023.md` `CA-09 (iii)` (la cláusula del margen) y su caso en
`tests/escenarios/hooks/secciones/39-caracter-invisible-4-el-coste.sh`; agregación en
`tests/escenarios/hooks/run.sh` y `.github/workflows/banco.yml`. **Extiende `SEC-064`, no lo
duplica.**

**Qué observé, sobre las cifras que QA publicó y verificando su aritmética, no re-midiendo.** El
techo de (iii) es **1,000×** y el criterio prohíbe afirmarlo si la dispersión de la serie emparejada
es mayor que el margen, siendo **margen = 1,000 − mediana**. La consecuencia es estructural y la
declara `QA-023-17` (`instrumento`, dueño `analista-requerimientos`): **el resultado ideal —que la
guarda no añada nada, relación 1,000— es exactamente el punto de margen cero**, así que cuanto más
conforme sea el código, más imposible es afirmar el criterio. Y el estadístico de dispersión es el
**rango**, monótono no decreciente en el número de tomas: **«más tomas» no puede ayudar nunca**. Un
PASS sólo es alcanzable si la mediana cae **muy por debajo** de 1,000, es decir midiendo que la
candidata es sustancialmente **más rápida** que la base — que no es la propiedad contratada. **Un
control que sólo puede afirmarse cuando mide otra cosa es un control apagado con apariencia de
control.**

**La lectura de seguridad que la clase `instrumento` de `QA-023-17` no lleva, y es la razón de que
esto tenga número aquí.** (iii) es el **único** control que vigilaría una regresión de **orden de
crecimiento** en la ruta caliente de la puerta. Y un escáner cuadrático en un `PreToolUse` no es
lentitud: `AGENTS.md` §13 lo tiene medido —«en Windows dura ~30 min y un hook `PreToolUse` muere a
los 60 s, **y un hook muerto no deniega**»—, o sea que la regresión que (iii) existe para cazar
tiene como modo de fallo un **fail-open por temporizador**, silencioso y en la plataforma donde
viven los proyectos consumidores. El propio código lo documenta habiéndolo pagado: la primera
versión de esta guarda medía **3,78 y 5,59** de cociente de duplicación en locale UTF-8 y **17×** de
coste absoluto, y fue `(iii)` quien la cazó. Hoy ese cazador no puede volver a afirmar nada.

**Y la mitad que `SEC-064` no cubre, que es la clase nueva.** `SEC-064` contrata que «toda abstención
de un criterio que corra en la puerta requerida declara su **cota**» —un número de corridas
consecutivas tras el cual la abstención pasa a hallazgo—. Eso no cierra esto, por dos razones
medidas en esta misma sesión:

- **Una cota contada «por corridas» no significa nada cuando el veredicto depende de QUÉ MÁQUINA
  corrió.** Medido y anotado por la coordinadora: **nueve corridas «0 FAIL» entre tres personas eran
  ABSTENCIONES, no verdes**, y el rojo real sólo apareció en el CI, cuya máquina es **17× más
  limpia**. El mismo criterio, sobre el mismo código, **abstiene en una máquina y decide en otra** —y
  la dirección no está garantizada como conservadora: un runner menos ruidoso reduce la dispersión y
  puede hacer que **afirme** lo que localmente no se puede afirmar. Cotas por máquina no se pueden
  sumar.
- **La abstención sale con el mismo `rc` y en el mismo total que un verde.** El cuadre suma
  `PASS + FAIL + SKIP` y el `rc` es 0 salvo `FAIL`, así que **abstenerse no mueve ninguna señal**.
  La lección que la coordinadora ya escribió —«una diferencia de una unidad en el recuento se explica
  leyendo la **lista** de SKIP, nunca el total»— es la confesión de que hoy la única forma de
  distinguir «pasó» de «no midió nada» es que una persona lea la lista. Ésa es la propiedad de
  `AGENTS.md` §1 invertida: **una puerta que no puede medir está dejando pasar**, y aquí la puerta es
  el banco sobre sí mismo.

**`CA-09 (iii)` es la SEGUNDA instancia medida de `SEC-064`, y la peor de las dos.** La de `CA-08
(ii)` abstiene por ruido y podría converger algún día. Ésta abstiene **por construcción**: su cota,
cualquiera que se le ponga, queda excedida **desde la primera corrida y para siempre**. Anoto por eso
que `SEC-064` gana un **segundo forzador** y sigue **abierto**; no reescribo su bloque.

**Remediación (por propiedad).** *Un criterio que abstiene declara (i) su cota, (ii) **de qué máquina
es** la medición que la produjo, y (iii) una señal que no comparta código de salida con un verde.* Y
para (iii) en particular, la salida barata está a la vista y no la propongo como mía: el techo se
enuncia contra una **línea base medida en la misma corrida y en la misma máquina** —que es lo que la
propia (iii) ya hace con la relación emparejada— y lo que falta es que el **margen** no se derive de
la distancia a un absoluto que el resultado ideal anula. **Dueño:** `analista-requerimientos` (la
cláusula, en `CA-09` y en la doctrina de `requirements/README.md`, que es su sede única) y
`desarrollador` (la señal en `run.sh` y en el workflow). **Forzador:** la primera corrida de
`hooks-en-linux` en que un criterio del banco abstenga y su resultado global salga verde — medido: ya
ocurrió en la corrida de `808f9ca`, con **9 SKIP**. **Vencimiento:** el cierre de `SEC-064`, o la
ventana **1.35.0**, lo que llegue antes. **Por qué no bloquea:** es un defecto de una prueba del
propio arnés, `instrumento` por la letra de `AGENTS.md` §6, y no cambia lo que ningún usuario ve ni
decide hoy — la guarda medida es **lineal** (1,79 y 2,01) y conforme.

### 5. Regresión de seguridad entre iteraciones — **ningún control retirado, y uno reforzado**

Comparado contra el estado aprobado que registra §9 de `R-023` y las líneas base anteriores:

| Control aprobado antes | Estado hoy |
|---|---|
| La ausencia de un veredicto se perdona por compatibilidad (`REQ-016 CA-11`) | **Intacto.** `CA-11` de este REQ lo declara y el código no lo toca |
| El interior de un `<!-- … -->` de la cabecera no declara campo; el rango abierto deniega | **Intacto.** La rama del rango sigue arriba y antes de la nueva |
| Un CR que no termina la línea deniega, sin admitir `est_antes` como eximente | **Intacto**, y su asimetría con la rama nueva queda **justificada** (§1) |
| Un campo legítimamente comentado **sin espacio** no dispara nada (`CA-11`) | **Intacto por construcción**: la guarda publica en `arnes_campo_linea`, **después** de retirar la cita, y no en la llamada cruda de `arnes_estado_cabecera` |
| Precedencia heredada: `Estado` toma la primera aparición, los otros cinco la última | **Intacta**, y declarada en el código como lo que la comparación campo a campo de `CA-04` caza |
| El informe deriva el conjunto de campos y no lo teclea | **Reforzado.** Pasa de derivarlo con `sed` **del texto** de `lib.sh` —que se rompe con la primera mudanza del código— a leer la constante. `CA-06` había avisado de que retirar los brazos rompería el informe; **se re-apuntó**, así que no hay deriva |
| La clave del estado terminal, cubierta por la guarda | **Reforzado** (§1, último párrafo) |

**Delta de decisiones: +2 `deny`, −0.** Nada se relajó y nada se borró.

### 6. Fuga en repositorio público

Barrido del rango del encargo y del delta de código contra patrones de secretos
(`ghp_`, `github_pat_`, `AKIA`, `-----BEGIN`, `Bearer`, `api[_-]key`, `password`, `token=`,
`client_secret`) y de material de cliente (`insumos/`, `mejoras-arnes-*`, `reporte-arnes-*`):
**cero coincidencias**. Los correos y cuentas que aparecen en `docs/ESTADO.md` y `CHANGELOG.md`
(`jvega@habitat.org`, `juan.vega@sysvega.cr`, `jvega-habitat`, `JJOVEGA`) son del **propietario** y
**ya están publicados** en los metadatos de autoría de cada commit de este repositorio público: no
hay exposición nueva. **Observación sin hallazgo:** `.gitignore` no cubre `.env*` y el arnés no
entrega plantilla de `.gitignore`; aquí no hay secretos que proteger (`AGENTS.md` §2:
«Autenticación n/a»), es **anterior a este rango** y no lo abro para no ampliar el encargo — queda
dicho para quien decida el alcance de la próxima ventana.

### 7. Rigor — **no lo subo ni lo bajo, y compruebo que no hace falta**

`REQ-023` es **`critico`** y `Sensible a seguridad: sí`, que es además su **suelo**. Es el nivel
correcto y por el motivo correcto: gobierna la puerta de cierre de **todos** los proyectos que
instalan el arnés, y su modo de fallo es **en abierto y en silencio**. Nada que subir.

### 8. Lo que esta revisión NO miró — tabulado como NO MIRADO, nunca como PASA

| No mirado | Por qué |
|---|---|
| **El banco y las quality gates** | **No son mías** (`AGENTS.md` §6) y **no ejecuté `run.sh` ni la autoprueba**. El `957 PASS · 0 FAIL · 9 SKIP` (cuadre 966) sobre `808f9ca` y las gates en verde los **cito** de QA y de la coordinadora; no los re-medí. Y el árbol que audito es `390a0a2`, **dos commits después** del que el CI midió — ninguno de los dos toca `hooks/`, `tools/`, `.github/` ni `tests/`, comprobado por mí, pero la cifra es de `808f9ca` |
| **`CA-09 (iii)`: la conformidad del código con su techo** | **Sin establecer, y no es un pase.** El criterio abstiene en los dos sujetos y §4 explica que **no puede** dejar de abstener. Lo que sí verifiqué es que la guarda es **lineal** (1,79 y 2,01 con `LC_ALL=C`), cifra del `desarrollador` que **no re-medí** |
| **`CA-09 (i)` y `(ii)`** | **No los medí.** Que la guarda no gasta procesos lo **leí** en el código (sólo expansión de parámetros y `printf -v`); no lo instrumenté |
| **`CA-08`: el fail-before dentro del banco** | **Sigue sin acreditarse en su letra** por precondición ajena —el gate humano de `SEC-048`, **abierto**—, y el propio criterio lo declara. Reproducible a mano y así se midió; **yo no lo reproduje** |
| **`CA-02`, `CA-03`, `CA-04`, `CA-05` en el banco** | **No ejecuté sus casos.** Lo que acredito de `CA-04` es **mi** corrida del informe sobre los 27 REQ reales (cero falsos positivos) y lo de `CA-05` es la **construcción** (`LC_ALL=C` local, comparación de bytes), no la corrida del par de locales |
| **La vía del NUL y el archivo en UTF-16** | Fuera de alcance declarado del REQ, con dueño y ventana. **No la ejercí**, y el silencio de la guarda ante un NUL **no acredita** nada |
| **El invisible delante del `## ` que termina la cabecera** | `QA-023-03`, medido por QA en las **dos** versiones. **No lo re-medí**; queda nombrado en «Fuera de alcance», que es lo que `CA-12 (iii)` exige |
| **`CHANGELOG.md`, `docs/PLAN.md`, los informes de QA** | **No leídos** (excluidos por coste). Los cinco documentos de `docs/qa/` del rango los cito de su cabecera, no de su contenido |
| **`REQ-024`, `REQ-026`, `REQ-027`** | Fuera de este encargo. No los miré y **no firmo nada de ellos** |

### 9. Estado de seguridad aprobado por REQ — línea base de no-regresión, actualizada en R-024

| REQ | Veredicto | Fecha | Alcance acreditado | Nota |
|---|---|---|---|---|
| **REQ-023** (1.ª auditoría) | **`con-hallazgos`** | 2026-09-09 | `rel/registro-1.33.0` @ `390a0a2`; rango del encargo `5305de9..390a0a2` **más** el delta de código `43bfd47..390a0a2` en `hooks/lib.sh`, `hooks/guard-completado.sh` y `tools/arnes-lectura.sh` (+349 / −15), que **el encargo no incluía** (§0) | **Qué acredita:** que la guarda de medibilidad **no abre nada** que antes cerrara y que su delta es **aditivo en decisiones** (+2 `deny`, −0); que la duda va **al lado que cierra** y que la clase **no puede fabricar** una clave del lector, lo que justifica su asimetría con la guarda del CR; que el mapa de claves es **inambiguo por construcción**; que no hay **inyección** en la salida del hook (`jq --arg`) ni **fail-open por entorno** (`LC_ALL=C` local, bytes); que la constante única **no es sobreescribible** desde el entorno; que el informe emite la anomalía **antes** del descarte «no es un REQ», cerrando el caso peor de `CA-07`; **cero falsos positivos** sobre los 27 REQ reales, medido por mí; y que **ningún control aprobado se retiró** y **dos se refuerzan** (§1, §5). **Qué NO acredita:** el banco, las quality gates, `CA-09 (i)`/`(ii)`/`(iii)`, el fail-before de `CA-08`, los casos de `CA-02`/`CA-03`/`CA-05`, la vía del NUL/UTF-16 y `QA-023-03` (§8). **Bloqueante abierto: `SEC-079`** (`contrato`) — la superficie heredada promete sin condición y `CA-10` la obliga a ello. **Residuales:** `SEC-078` (`instrumento`, alta, la vía del homóglifo con su reparto ya declarado) y `SEC-080` (`instrumento`, media) |
| **REQ-027** (1.ª auditoría) | `aprobado` | 2026-09-09 | `R-023`, `81d260d` | Sin cambios |
| **REQ-026** (vuelta 2) | `con-hallazgos` | 2026-09-09 | `R-022`, `4f51293` | Sin cambios. `SEC-072` y `SEC-073` siguen abiertos y **siguen bloqueando** ese REQ |
| **REQ-017** (reapertura 1.34.0) | `aprobado` | 2026-09-08 | `R-020` | Sin cambios |
| **REQ-014** (reapertura 1.33.0) | `aprobado` | 2026-09-08 | `R-019` | Sin cambios |

**Estado de mis hallazgos tras R-024.** `SEC-078` **abierto** (`instrumento`, alta; la vía, dueños
`desarrollador` y `analista-requerimientos`; su mitad de **puntero** queda `mitigado` por esta misma
entrada). `SEC-079` **abierto** (`contrato`, alta, dueños `analista-requerimientos` y
`desarrollador`; **bloquea `REQ-023`**). `SEC-080` **abierto** (`instrumento`, media, dueños
`analista-requerimientos` y `desarrollador`). **`SEC-047` mitad 1: `en-mitigación`** — el código está
escrito y lo acredito en §1, y **no lo cierro** porque su superficie heredada aún promete de más
(`SEC-079`) y porque su mitad 2 es `REQ-024`; su vencimiento sigue siendo **el cierre de 1.34.0**.
**`SEC-064` sigue abierto** y gana un **segundo forzador** medido (§4). Sin cambios en `SEC-048`,
`SEC-049`, `SEC-050`, `SEC-051`, `SEC-058`, `SEC-067`..`SEC-077`.

**Numeración vigente tras esta revisión:** última revisión **R-024**; último hallazgo **SEC-080**;
próximos libres **R-025** y **SEC-081**.

**`docs/seguridad/gobernanza-datos.md`: sin cambios.** Este delta no altera clasificación de datos,
acceso, retención ni cumplimiento: no hay datos personales, credenciales ni activos nuevos. La única
propiedad de seguridad en juego es la **integridad de la puerta de cierre** y su **honestidad hacia
los proyectos instalados**, cuyas sedes son `hooks/` y `AGENTS.md`, no el documento de datos.

---

## Revisión R-025 — **REQ-023, 2.ª auditoría ACOTADA a `SEC-079`**: la fila heredada deja de prometer de más, medido ejecutando la puerta (`rel/registro-1.33.0` @ `fcbb7b1`; rango **`390a0a2..fcbb7b1` restringido por RUTA**, ver §0) — 2026-09-09

**Veredicto: `aprobado`, y acotado a lo que dice acreditar.** `SEC-079` queda **`mitigado`** y
**retirado** de `Hallazgos abiertos:` de `REQ-023`. Lo que firmo es **una** cosa: que el texto que
los proyectos heredan **ya no promete más cobertura de la que la máquina tiene**, y que **cada
afirmación de hecho de esa fila es verdadera medida contra el árbol con el que viaja**. No firmo el
mecanismo de este árbol (§0), no firmo `REQ-024`, y **mi firma no desbloquea `REQ-023`**, que sigue
`Estado: bloqueado` por decisión del propietario.

**Y la pregunta que no era «¿está mejor redactada?».** `SEC-079` decía que la fila **prometía de
más**. Eso no se cierra leyendo el texto nuevo: se cierra **ejerciendo la puerta** con entradas
propias y comprobando que de cada oración se derive lo que la máquina hace. Es lo que hice en
`R-024` y es lo único que vale aquí. Las **8** oraciones de la celda están barridas en §2 y las
**17** entradas ejecutadas en §1.

### 0. El rango que me dieron NO era el correcto, y el error es el CONTRARIO al de R-024

El encargo proponía **`1154417..fcbb7b1`**, «pero compruébalo tú». Medido, y no vale:

```
git log --oneline 1154417..fcbb7b1        # NO contiene 1154417
git show --stat 1154417 -- AGENTS.md templates/AGENTS.md.tpl requirements/REQ-023.md
#   AGENTS.md | 2 +-   templates/AGENTS.md.tpl | 2 +-   requirements/REQ-023.md | 141 ++++-
```

`A..B` **excluye** `A`. Y `1154417` es precisamente el commit donde la fila se reescribió **por
primera vez** y donde `CA-10` recibió las **141 líneas** del primer write-back: es decir, el rango
propuesto **deja fuera la mayor parte de la remediación que se me pide acreditar**. En `R-024` el
rango del encargo excluía el **código** que había que auditar; aquí excluye **el texto**. Misma
lección, otra dirección: **el rango se mide, no se acepta**.

**Rango que audito, y por qué lleva una restricción de RUTA.** Todo lo posterior a lo que `R-024`
acreditó, es decir **`390a0a2..fcbb7b1`** (8 commits), **restringido a las sedes de `SEC-079`**:
`AGENTS.md`, `templates/AGENTS.md.tpl`, `skills/arnes-upgrade/SKILL.md`, `requirements/REQ-023.md`
(`CA-10` + Historial) y este registro.

La restricción **no es comodidad, es honestidad, y va aquí porque sin ella la firma diría de más**:
ese mismo rango contiene **+270 / −22 en el mecanismo** —`hooks/lib.sh` +192, `hooks/guard-completado.sh`
+42, `hooks/estado-derivado.sh` +11, `tools/arnes-lectura.sh` +47, todo en `119e853`, «REQ-024
implementado (9 de 11)»— más una **llave nueva de manifiesto** (`campos.ausencia_exige`, en
`.arnes/config.json` y en `templates/arnes-config.json.tpl`) y **dos secciones nuevas de banco**
(`40-ausencia-que-abre-*`). El encargo excluye `REQ-024` expresamente y **no lo he auditado**. Un
rango declarado sólo por commits habría hecho pasar ese delta por revisado.

**Lo único que sí comprobé de ese delta, porque es mi deber de no-regresión y no una auditoría de
`REQ-024`:** que **no debilitó ningún control que `R-024` había acreditado** (§3), y que la llave
nueva nace **apagada** (`"ausencia_exige": false`) en las dos sedes, es decir del lado que **no
cambia nada**. Que su lectura sea correcta —incluido el defecto declarado de la cadena `"true"`
cayendo a ALLOW— es de la auditoría de `REQ-024`, **no de esta**.

### 1. La fila, ejercida: 17 entradas contra la puerta REAL de este árbol

No es lectura. Es `hooks/guard-completado.sh` de `fcbb7b1` con su JSON de entrada, proyecto de
prueba con `quality_gates: ["true"]` y cola vacía, `Write` sobre un REQ cuyo estado en disco no era
el terminal. El resto del documento, idéntico entre filas.

| Cabecera juzgada | Veredicto | Qué oración de la fila lo afirma |
|---|---|---|
| `Sensible a seguridad: sí` · `QA: pendiente` · `Rigor: ligero` | **DENY** (por veredicto) | control: la puerta funciona y el arnés discrimina |
| **BOM** + `Sensible a seguridad: sí` · `Rigor: ligero` | **DENY**, con `\xef\xbb\xbf` en el motivo | or. 2 y or. 4 |
| **ZWSP** (`\xe2\x80\x8b`) dentro de la clave | **DENY** | or. 4 |
| **`\xc3`** suelto (multibyte partido) | **DENY** | or. 4 |
| **NBSP** dentro de la palabra (`Sensible\xc2\xa0a seguridad`) | **DENY**, con `\xc2\xa0` en el motivo | or. 3 y or. 5 |
| **blanco BORRADO** (`Sensibleaseguridad`) | **DENY** | or. 3 y or. 5 |
| **blanco de MÁS** (`Sensible a  seguridad`) | **DENY**, con `\x20\x20` en el motivo | or. 4, literal |
| `QA-:` con **guion ASCII visible** | **DENY** | or. 5: la clase **no** es una lista de invisibles |
| **BOM** + los **dos veredictos en `aprobado`** y `Rigor: critico` | **DENY** | or. 2: «**aunque los veredictos estén en verde**» |
| **homóglifo `а` U+0430** en la «a» aislada · `Rigor: ligero` | **ALLOW** | **or. 6**, literal |
| **homóglifo `е` U+0435** dentro de `Sеnsible` | **ALLOW** | **or. 6**: es la propiedad, no el ejemplo |
| **`Еstado`** con `Е` U+0415 (el ejemplo literal de or. 6) | **ALLOW** | **or. 6**, literal |
| toda la cabecera en **CRLF**, veredictos rojos | **DENY** (por veredicto) | or. 7, frontera 1 |
| toda la cabecera en **CRLF**, veredictos verdes | **ALLOW** | or. 7, frontera 1: «CRLF decide **igual** que LF» |
| **ZWSP en el CUERPO**, veredictos verdes | **ALLOW** | or. 7, frontera 2 |
| `Estado: en-progreso` + **BOM** en la cabecera | **ALLOW** | or. 7, frontera 3: reabrir no se bloquea |
| `Módulo:` y `Versión destino:` (no-ASCII **legítimo**) | **ALLOW** | cero falsos positivos |

**Y el par que decide si «permite POR AUSENCIA» es verdad, que es la afirmación más fuerte de la
celda.** Dos documentos **idénticos byte a byte salvo los dos bytes del homóglifo**:

| Cabecera | Veredicto | Motivo |
|---|---|---|
| `Sensible a seguridad: sí` · `QA: aprobado` · `Seguridad: pendiente` · **`Rigor: ligero`** | **DENY** | «su **rigor efectivo es `critico`** y el veredicto de seguridad es `pendiente`» |
| `Sensible а seguridad: sí` (U+0430) · `QA: aprobado` · `Seguridad: pendiente` · **`Rigor: ligero`** | **ALLOW** | — |
| `Sensible а seguridad: sí` (U+0430) · `QA: aprobado` · `Seguridad: pendiente` · **`Rigor: critico`** | **DENY** | control: el ALLOW de arriba **viene del suelo que desapareció**, no de una guarda rota |

La denegación que desaparece es **exactamente** la que producía el campo borrado, y vuelve a
aparecer en cuanto el rigor se declara a mano. Es `SEC-047` **fila 1 reproducida entera**, y es lo
que la or. 6 **publica en la propia celda**. La afirmación «**permite, y permite por ausencia**» no
es una concesión retórica: está **medida**.

**«Ninguna versión lo deniega, tampoco 1.34.0» — verificado tag a tag, con control en cada uno.**
`v1.31.0`, `v1.32.1`, `v1.33.0` (la publicada, la que **gobierna** esta ventana) y este árbol
—candidata de 1.34.0—: **ALLOW** las cuatro sobre el homóglifo, **DENY** las cuatro sobre el
control latino. La única afirmación **universal** que queda en la fila es ésta, y apunta al lado
que **no tranquiliza**.

### 2. El barrido de las 8 oraciones, hecho por mí y con la 1 AISLADA

`CA-10 (iii)` dice que **basta una** oración que prometa denegación o no-permisividad **sin su
condición** para incumplir, y que la **titular** se juzga **leída sola**. Enumeradas, no resumidas:

| # | Qué afirma | ¿Promete? | ¿Lleva su condición? | Verdad medida |
|---|---|---|---|---|
| **1** | titular: «no deja cerrar **dentro de lo que la guarda alcanza (acotado en esta misma celda; hay vías medidas que hoy PERMITEN)**» | sí, **acotada** | **sí, DENTRO, y juzgada aislada** | **cumple** |
| 2 | «se deniega citando esa línea […] aunque los veredictos estén en verde» | sí | sí, por el sujeto que **or. 1/3** condicionan («**esa** línea») | medida (fila 9 de §1) |
| 3 | la acotación **por propiedad**, con sus **dos** ramas | sí | **sí, es la condición** | medida (ramas DENY y «calla») |
| 4 | instancias: BOM, ZWSP, C0, multibyte partido, blanco de más o en el sitio de otro | no promete: enumera | n/a, y **declara** que son instancias | las 5 medidas DENY |
| 5 | «la clase **no** se cierra con una lista de caracteres» + el fragmento | no promete cobertura | sí | medida (`QA-:` ASCII → DENY) |
| **6** | **la vía abierta, nombrada dentro de la fila, como ejemplo NO exhaustivo con puntero** | afirma que **PERMITE** | n/a | **medida en 3 formas + 4 versiones** |
| 7 | tres fronteras, **lista «no exhaustiva»** + puntero al sitio único | descriptiva | sí | las 3 medidas |
| 8 | cita el sitio único con los **dos** números (`R-024`, `SEC-078`, `SEC-079`) | no promete | n/a | el puntero **resuelve** |

**Ninguna de las 8 promete sin condición. La 1 leída sola es verdadera.** Y no es una tautología
vacía: la parte que carga el sentido es la **no** tautológica —«hay vías medidas que hoy
**PERMITEN**»—, que es la información cuya ausencia era el defecto, puesta en **la única línea que
lee quien escanea la columna «Invariante»**.

**Mi propio control negativo, contra la fila de `390a0a2` (la que yo declaré falsa).** No me apoyo
en el de QA: la extraje y la medí. **`md5 721abd511c9aea56ce91663c6de01608`, 1 274 B** la fila entera (1 216 B su columna «Invariante»), **5** oraciones, e **incumple por
cuatro sitios independientes** — (a) titular «*no deja cerrar —*», sin condición; (b) «y **nunca**
se permite por **ausencia** del campo que ese carácter borró», **universal y medida falsa**;
(c) «**Tres fronteras:**», lista **cerrada**, sin marca y sin puntero; (d) **cero** menciones de la
vía abierta. La fila de hoy corrige **los cuatro**, y mi comprobación **separa** los dos textos. Una
lectura que no distinguiera esas dos filas no estaría ejerciendo nada.

**Y el delta es ADITIVO: nada se arregló BORRANDO la oración incómoda.** La promesa universal de (b)
**no se suprimió**: se **movió dentro de la condición** de la or. 3, donde es verdadera —«*si lo que
queda es una clave del lector leída también sin sus blancos* la línea no se puede medir, se deniega
y **no** se permite por ausencia»—. 5 oraciones → 8; 1 216 B → 2 545 B; **cero** oraciones retiradas.
Es lo que `CA-10` punto 1 exige literalmente («**o lleva esa condición o no se escribe**») y lo
contrario de lo que habría hecho un arreglo cosmético.

### 3. Las tres sedes, y la CUARTA que este hallazgo no había nombrado

| Comprobación | Medida |
|---|---|
| `AGENTS.md:349` ≡ `templates/AGENTS.md.tpl:314` | **byte a byte**: `md5 3ead3bd328da6b857271b0137c0209eb`, **2 545 B**, `cmp` sin diferencias |
| Una sola fila de esta clase por sede | **1** y **1** |
| Fragmento del mecanismo (la **prótasis**, 165 B, `md5 596a237fce04f0fdb2d7e442b5e91f44`) | **2 + 2 + 1** apariciones (`AGENTS.md`, `.tpl`, `SKILL.md`), **ninguna** con letra distinta |
| Restos de la redacción vieja del mecanismo («repuesto un blanco», «colapsad», «sitio de la retirada») | **0** en las tres sedes |
| La promesa universal vieja, **viva**, en cualquier superficie heredada | **0**. Sus 10 apariciones restantes son **citas** del defecto: este registro, los métodos de QA, el `CHANGELOG` y el Historial/criterio del propio REQ |
| `agents/`, `templates/` (resto), `README.md`, `tools/arnes-lectura.sh`, `ADR-009` | **ninguno** promete la clase cerrada |

**La cuarta sede, dicha porque `SEC-079` no la había localizado.** Mi entrada nombraba tres
ubicaciones y **elogiaba** la skill por honesta. Era cierto sobre la vía abierta y **falso sobre el
mecanismo**: `skills/arnes-upgrade/SKILL.md` llevaba también la promesa absoluta y la descripción
vieja, en **el artefacto que migra a los proyectos instalados**. La detectó la coordinadora, la
enrutó y está corregida con la misma forma (`SKILL.md:820-833`): acotación explícita —«**dentro de
lo que la guarda alcanza, que no es toda la clase: la vía del homóglifo de arriba PERMITE, y permite
por ausencia**»—, el fragmento idéntico, las fronteras marcadas «no exhaustiva» y el puntero al
sitio único con los dos números. **Lección para mí, y va escrita:** localicé el hallazgo por las
sedes que `CA-10` nombra en vez de **derivar** las sedes del texto. Es la forma (a) cometida por el
auditor, sobre sus propias ubicaciones.

**No-regresión, MEDIDA y no leída.** Es la comprobación que `AGENTS.md` §13 me pide entre
iteraciones, y aquí importaba de verdad porque el rango trae **+270 / −22 de mecanismo** sin
auditar. Las **10** entradas del banco de §1 corridas contra `hooks/` de `390a0a2` —lo que `R-024`
acreditó— y contra `fcbb7b1`: **veredicto idéntico en las 10**, ninguna denegación perdida, ninguna
permisividad nueva. Y `tools/arnes-lectura.sh` sobre los **27 REQ reales** de este repositorio:
**«Ningún valor anómalo»**, es decir los **cero falsos positivos** de `R-024` **siguen en cero**.

**Un hecho que conviene tener medido, y que NO ensancha `SEC-078`.** El informe
`tools/arnes-lectura.sh` —el lector **proactivo**, el que una coordinadora corre para preguntarse si
su cierre está protegido— señala el NBSP y **no** señala el homóglifo: publica ese REQ como normal,
con `rigor efectivo: ligero`. Es la **misma** ubicación de `SEC-078` (`_arnes_clave_oculta`, un solo
lector con dos consumidores), no una sede nueva, y el reparto de `SEC-078` **no se toca**. Se anota
porque el silencio del informe es la mitad menos visible de esa vía.

### 4. Lo que se me pidió mirar con dureza: ¿es la asimetría una COARTADA?

`CA-01` sigue exigiendo **DENY** sobre toda la clase, y la vía del homóglifo **la incumple**. El
analista acotó **la fila** y **no `CA-01`**. La pregunta es si eso es honestidad o coartada, y **no
se responde con la intención de quien lo escribió: se responde por sus consecuencias**.

Lo juzgo **honesto**, y éstas son las cuatro condiciones que lo sostienen, las cuatro
**verificables**:

1. **`CA-01` no se relajó en ninguna dirección** — su texto es idéntico y sigue pidiendo DENY sobre
   toda la clase. Relajar la exigencia para que encaje el código es lo que `requirements/README.md`
   § «Y el reverso» prohíbe, y **no ocurrió**.
2. **El incumplimiento está declarado, con dueño, clase y ventana**, en cuatro sitios que no se
   contradicen: `CA-11` («cualquier otra vía sigue **incumpliendo `CA-01`**»), `CA-12 (iii)`,
   § «Fuera de alcance» y **`SEC-078`** en este registro.
3. **La fila PUBLICA que la vía permite** — y en su **titular**. Es la diferencia decisiva: una
   coartada esconde la excepción donde el lector no la busca; aquí está en la primera línea de la
   columna que se escanea, y en la 6 con el nombre de la vía.
4. **Las dos clases de texto son distintas y la asimetría está escrita DENTRO de `CA-10`**, no
   descubierta a posteriori: un criterio dice **cómo se quiere el mundo**, una fila de §13 describe
   **lo que la máquina hace hoy** para que alguien decida si tiene que auditar sus REQ cerrados. Una
   fila §13 que describiera la exigencia como satisfecha sería falsa; un `CA-01` rebajado sería la
   coartada. Se corrigió el primero.

**Donde sí sería coartada, y es el punto exacto que hay que vigilar:** que la titular volviera a
prometer sin condición, o que `CA-01` se «armonizara» con la cobertura real. Lo primero **ya ocurrió
una vez** (`QA-023-18`, sobre `1154417`) y es la razón de que `CA-10` exija ahora la subordinada
**dentro** de la titular y su juicio **aislado**. La condición que QA puso está **cumplida y medida**
(§2). **Coincido con QA: honesto, no coartada.**

### 5. Hallazgo nuevo

#### SEC-081 — **La doctrina general prohíbe enumerar los CASOS y no nombra la dirección simétrica —enumerar las EXCEPCIONES—, que es la que envejece hacia el lado que TRANQUILIZA: la lección de `SEC-079` sobrevive hoy sólo en `CA-10`, que muere con su REQ** · `instrumento` · severidad **media** · **abierto** *(nuevo)*

**Ubicación.** `requirements/README.md` § «Cómo se escribe un criterio que no se desmiente», forma
**(a)**, la lista de ejemplos de su **Regla**.

**Qué está bien y por qué aun así hay defecto.** La Regla de (a) está enunciada **por propiedad** y
dice «**cualquier** conjunto, sin excepción por el tipo de cosa que sea», así que **cubre** la lista
de fronteras: `SEC-079` no es una laguna de la doctrina, es un **fallo de detección** de la
doctrina. Pero sus tres ejemplos marcados —«envoltorios, prefijos, estados»— son todos de la
dirección **que abre**, y el caso y el «Mal/Bien» también. `SEC-079` pasó **tres filtros**
—analista, desarrollador y una coordinadora que verificó con un `grep`— porque la forma «excepto
estas tres fronteras» **suena a propiedad** y su texto **tranquiliza**, que es más difícil de ver que
un texto que se queda corto. Mi propia entrada de `SEC-079` diagnostica exactamente eso, y **hoy ese
diagnóstico vive sólo aquí y en `CA-10`** — un criterio de un REQ concreto, no la doctrina.

**Por qué es `instrumento` y no `contrato`, dicho contra el argumento fácil.** Ningún texto dice
nada **falso**: la Regla es verdadera y sus ejemplos van marcados «no exhaustivos». Lo que tiene
defecto es **el control** —la lista con la que QA juzga un criterio **antes** de probarlo—, sin
efecto en el producto. No bloquea, y **no** se me ocurre reclasificarlo para forzar un cierre ajeno.

**Y por qué NO va al `Hallazgos abiertos:` de `REQ-023`:** su sede está **fuera** del `Archivos:` de
ese REQ y su remediación no cabe en él. Queda **aquí**, que es el sitio único, y su **enrutado a un
REQ es de la coordinadora**. Anotarlo en un REQ cuyo dueño no puede tocar el archivo lo dejaría sin
dueño real.

**Remediación (por propiedad, no por enumeración).** Que la Regla de (a) declare que la propiedad
alcanza **las dos direcciones** —el conjunto que el código **reconoce** y el conjunto que
**excluye**: fronteras, excepciones, casos perdonados— y que sus ejemplos marcados incluyan al menos
una de la segunda. Una sola frase. **Dueño:** `analista-requerimientos`. **Forzador:** el próximo
criterio o fila heredada que enumere fronteras o excepciones sin la marca «no exhaustiva» y sin el
puntero al sitio único — y hay uno **ya en cola**: `REQ-024 CA-04`, sobre la fila del **rigor** de
`AGENTS.md` §6/§13, misma tabla y misma forma. **Vencimiento propuesto:** **1.35.0**, y **lo decide
el propietario**, no este documento.

### 6. Lo que esta firma acredita, y lo que NO

| Acredita |
|---|
| Que **ninguna de las 8 oraciones** de la fila heredada promete denegación o no-permisividad **sin su condición**, con la **titular juzgada aislada** — barrido enumerativo propio (§2) |
| Que **cada afirmación de hecho** de esa fila es **verdadera medida contra `fcbb7b1`**: 17 entradas ejecutadas contra la puerta real, incluidas las **tres** ramas del homóglifo y las **tres** fronteras (§1) |
| Que «**permite, y permite por ausencia**» está medido con un **par A/B de dos bytes de diferencia** y su control de rigor (§1) |
| Que «**ninguna versión lo deniega, tampoco 1.34.0**» es cierto en `v1.31.0`, `v1.32.1`, `v1.33.0` y este árbol, **con control en cada uno** (§1) |
| Que las **dos sedes** son **byte a byte idénticas** y el fragmento del mecanismo es literalmente el mismo en sus **2+2+1** apariciones, con **0** restos de la redacción vieja y **0** promesas absolutas vivas en superficie heredada (§3) |
| Que la **cuarta sede** —la skill, el canal de entrega a los proyectos instalados— quedó con la misma forma (§3) |
| Que el arreglo es **aditivo**: la promesa universal se **condicionó**, no se borró; 5 → 8 oraciones, **cero** retiradas (§2) |
| Que **ningún control acreditado en `R-024` se debilitó** pese a las +270 / −22 líneas de mecanismo del rango: 10 fixtures, veredicto **idéntico** en `390a0a2` y `fcbb7b1`, y los **cero falsos positivos** sobre los 27 REQ reales **siguen en cero** (§3) |
| Que la asimetría fila / `CA-01` es **honesta**, por sus cuatro condiciones verificables, y no una coartada (§4) |

| NO acredita — y cada renglón está aquí porque alguien podría leerlo de más |
|---|
| **El delta de mecanismo del rango.** `hooks/lib.sh` +192, `guard-completado.sh` +42, `estado-derivado.sh` +11, `tools/arnes-lectura.sh` +47 (`119e853`, `REQ-024` 9 de 11) — **no auditados**. Mi comprobación fue de **no-regresión sobre 10 fixtures**, que es una cota inferior, **no** una auditoría |
| **La llave nueva `campos.ausencia_exige`.** Sólo verifiqué que nace **apagada** en las dos sedes. Su lectura, sus tipos y el defecto declarado de la cadena `"true"` → ALLOW son de la auditoría de `REQ-024` |
| **`REQ-024` entero**, y sus `CA-04` / `CA-06` sin acreditar |
| **`CA-09 (iii)`**: sigue **SIN acreditar**; no lo re-medí (`SEC-080`) |
| **El banco y las quality gates**: no los ejecuté. Cito de QA el banco local 988/0/8 y el CI `hooks-en-linux` PASS sobre `b5a29d9`, **no sobre `fcbb7b1`** |
| **Que la clase del carácter invisible esté cerrada. NO lo está.** La vía del homóglifo **permite hoy**, en todas las versiones y en la candidata, y así lo publica la propia fila. `SEC-078` sigue **abierto** |
| **El mensaje de la propia puerta.** `guard-completado.sh:363` y `:392` conservan «**NUNCA** permite por AUSENCIA del campo que ese caracter borro». Es la **misma** frase universal, y su ubicación queda **fuera** de las sedes de `SEC-079`, así que **mi cierre no la cubre**. Está declarada y con dueño: **`QA-023-21`** (`instrumento`). **Mantengo esa clase**, y no por cortesía: la frase sólo se muestra **al denegar**, donde es localmente cierta, y **jamás** llega a la persona en el caso expuesto —ahí la puerta calla—; su lector no es quien decide si auditar. Es materialmente más débil que la fila de §13, pero **es la misma frase** y quien la lea de más se equivocará igual |
| **`SEC-078` y `SEC-080`**: los dejo **abiertos** por decisión del propietario. No los toqué |
| **El `Estado:` de `REQ-023`**: sigue `bloqueado` y **mi firma no lo desbloquea** |

### 7. Estado de seguridad aprobado por REQ — línea base de no-regresión, actualizada en R-025

| REQ | Veredicto | Fecha | Alcance acreditado | Nota |
|---|---|---|---|---|
| **REQ-023** (2.ª auditoría, **acotada a `SEC-079`**) | **`aprobado`** | 2026-09-09 | `rel/registro-1.33.0` @ `fcbb7b1`; rango **`390a0a2..fcbb7b1` restringido por RUTA** a `AGENTS.md`, `templates/AGENTS.md.tpl`, `skills/arnes-upgrade/SKILL.md`, `requirements/REQ-023.md` y este registro (§0) | **Acredita** la mitad de **texto**: 8 oraciones barridas con la titular aislada, 17 entradas ejecutadas contra la puerta real, par A/B del «permite por ausencia», 4 versiones para «ninguna lo deniega», sedes byte a byte, fragmento 2+2+1, arreglo aditivo, cero regresión sobre las 10 fixtures de `R-024` y la asimetría juzgada honesta (§1–§4, §6). **NO acredita** el delta de mecanismo del rango (+270 / −22, `REQ-024`), la llave nueva, `REQ-024`, `CA-09 (iii)`, el banco ni las quality gates (§6). **Bloqueantes abiertos míos: ninguno.** **Residuales:** `SEC-078` (`instrumento`, alta), `SEC-080` (`instrumento`, media), `SEC-081` (`instrumento`, media) y `QA-023-21` (`instrumento`, de QA) |
| **REQ-027** (1.ª auditoría) | `aprobado` | 2026-09-09 | `R-023`, `81d260d` | Sin cambios |
| **REQ-026** (vuelta 2) | `con-hallazgos` | 2026-09-09 | `R-022`, `4f51293` | Sin cambios. `SEC-072` y `SEC-073` siguen abiertos y **siguen bloqueando** ese REQ |
| **REQ-017** (reapertura 1.34.0) | `aprobado` | 2026-09-08 | `R-020` | Sin cambios |
| **REQ-014** (reapertura 1.33.0) | `aprobado` | 2026-09-08 | `R-019` | Sin cambios |

**Estado de mis hallazgos tras R-025.** **`SEC-079` `mitigado`** (`contrato`, alta; las tres piezas
de su remediación hechas y medidas, más la cuarta sede que la entrada no había nombrado; **retirado
de `Hallazgos abiertos:` de `REQ-023`**). `SEC-081` **abierto** (`instrumento`, media, dueño
`analista-requerimientos`). `SEC-078` **abierto** sin cambios (`instrumento`, alta; su silencio en
el informe queda **medido** en §3 y su reparto **no se toca**). `SEC-080` **abierto** sin cambios
(`instrumento`, media). **`SEC-047` mitad 1 sigue `en-mitigación`**: el código está acreditado desde
`R-024` y **su superficie heredada ya no promete de más**, pero su **mitad 2 es `REQ-024`**, que no
he auditado; vencimiento sin cambio, **el cierre de 1.34.0**. Sin cambios en `SEC-048`, `SEC-049`,
`SEC-050`, `SEC-051`, `SEC-058`, `SEC-064`, `SEC-067`..`SEC-077`.

**Numeración vigente tras esta revisión:** última revisión **R-025**; último hallazgo **SEC-081**;
próximos libres **R-026** y **SEC-082**.

**Rigor de `REQ-023`: sin cambios, `critico`.** No hay nada que subir: `Sensible a seguridad: sí` ya
impone ese suelo y el REQ lo declara.

**`docs/seguridad/gobernanza-datos.md`: sin cambios.** Este delta es **texto** —una fila de
`AGENTS.md` §13, su gemela de plantilla y un apartado de skill—: no altera clasificación de datos,
acceso, retención ni cumplimiento, y no introduce datos personales, credenciales ni activos nuevos.
La propiedad de seguridad en juego sigue siendo la **honestidad de la puerta de cierre hacia los
proyectos instalados**, cuyas sedes son `hooks/`, `AGENTS.md` y `skills/arnes-upgrade/`, no el
documento de datos.

---

## Revisión R-026 — **REQ-016, re-recorrido del ciclo (3.ª obligación de `REQ-024 CA-03 (ii)`)**: el puntero nuevo de `CA-11`, ejercido por mutación, **después** de QA (`rel/registro-1.33.0` @ `ce714c7`; rango **derivado**, ver §0) — 2026-09-10

**Veredicto: `con-hallazgos`. NO firmo `aprobado`, y no es un veto.** La **conducta** que `CA-11`
contrata es cierta y la acredito medida (§2, §3, §4). Lo que no puedo firmar es su **texto**: una
frase del criterio que hoy se re-recorre —«qué hace la máquina cuando un campo no llega a
declararse **lo decide un solo sitio**»— es **falsa para `Seguridad:`**, que es precisamente el
campo de mi propia firma, y lo probé **por mutación con control positivo** (§3). `AGENTS.md` §9 no
me deja dar `aprobado` mientras el write-back no exista, y `con-hallazgos` **cierra la puerta por
máquina** sin necesidad de `Estado: bloqueado` (§6). `QA-016-02` **se cierra** (`mitigado`): la
exposición que nombraba —cierre en ALLOW sobre una firma vencida— **ya no existe**, y lo verifiqué
en la puerta con su propio control (§6).

**Y aparece un fail-open que no estaba en ningún papel** (§5, `SEC-083`): la invariante «**seguridad
no firma lo que QA no ha validado**» —`AGENTS.md` §13, cumplida por máquina— **falla en abierto
cuando la línea `QA:` no llega a declararse**, y `campos.ausencia_exige` **no la cierra en ninguno
de sus dos estados**. Es la familia de `SEC-047` **sobreviviendo a su propia mitigación**, en la
guarda que protege mi firma.

### 0. El rango: no me lo dieron, lo derivé — y el hecho que lo produce

El encargo me dio el **hecho** y no el rango, después de dármelo mal dos veces (`R-024` corto por
delante, `R-025` corto por detrás). El hecho: `REQ-016` está `en-progreso` desde el 2026-09-10 por
`AGENTS.md` §9 porque su `CA-11` se reescribió, y sus dos `aprobado` del 2026-09-07 cubren un
`CA-11` distinto. Derivación, comando a comando:

```
git log --oneline --reverse -S'ARNES_AUSENCIA' -- hooks/lib.sh   # -> 119e853 (nace el sitio único)
git log --oneline --reverse -S'ausencia_exige' -- .arnes/config.json hooks/lib.sh   # -> 119e853
git log --oneline -S'tabla de la dirección de la ausencia' -- requirements/REQ-016.md  # -> 9d007ca
git log --oneline 119e853^..ce714c7 -- hooks/lib.sh hooks/guard-completado.sh .arnes/config.json
git diff --stat a57eecc..ce714c7 -- hooks/ tools/ .arnes/config.json   # -> VACÍO
```

**El rango que audito, y por qué es ése:**

| Mitad | Rango | Motivo |
|---|---|---|
| **Texto** | `9d007ca` (reescritura de `CA-11`) + `ce714c7` (veredicto de QA) | Es el forzador de §9: lo que cambió es **lo que el criterio contrata**, no prosa |
| **Código** | **`119e853^..ce714c7` restringido por RUTA** a `hooks/lib.sh`, `hooks/guard-completado.sh` y `.arnes/config.json` — **2** commits (`119e853`, `5c71694`), **261** líneas cambiadas, **55** de ellas sobre la superficie de la ausencia | `CA-11` nombra hoy una superficie que **no existía** cuando firmé `R-009`: `ARNES_AUSENCIA`, `arnes_ausencia`, `arnes_resuelve_ausencia` y la llave, **todas nacidas en `119e853`**. Una auditoría del texto nuevo contra el código viejo no mide nada |

**Ni corto por delante ni largo por detrás, y lo digo con el número:** el delta total de
`v1.32.1..ce714c7` en `hooks/` + el manifiesto es de **1023 líneas insertadas** (escáner de CR,
rotador, bloque derivado). **No lo re-audito**: se acreditó en `R-019`…`R-025` por sus propios REQ.
Lo que hago con él es **no-regresión** sobre las propiedades que la lógica nueva de la ausencia
podría haber desplazado (§4), que es una **cota inferior y no una auditoría**.

**El orden de firmas está intacto, y no de palabra:** `git diff --stat a57eecc..ce714c7` sobre
`hooks/`, `tools/` y `.arnes/config.json` sale **vacío**, así que el árbol de **código** que audito
es **byte a byte** el que QA validó. Mi turno es después del suyo (`AGENTS.md` §6) y lo es de hecho,
no sólo de calendario.

### 1. Método: el puntero no se lee, se ejerce

`SEC-050` se cazó porque alguien **siguió** un puntero en vez de leerlo. Repito la técnica y no la
lectura de QA:

- **Fixture aislado** en el scratchpad de la sesión (proyecto propio con `requirements/`,
  `PENDING_APPROVAL.md` vacío a propósito y `quality_gates: ["true"]`, para que lo único que decida
  sea la cabecera), y **copia** de `hooks/` y `tools/` de `ce714c7`. **No toqué `hooks/` del
  repositorio** —no soy el `desarrollador`— ni el manifiesto del repositorio.
- **La llave se enciende SÓLO en el manifiesto del fixture**, nunca en el del repositorio, y no
  presupongo `D8`. Cada medición dice en qué estado de la llave se tomó.
- **Payload real de la puerta:** `PreToolUse`/`Edit` con `old_string: en-revisión` →
  `new_string: completado` sobre el REQ del fixture, ejecutando `guard-completado.sh` de verdad.
- **Mutación del sitio único** sobre la copia, **verificada leyendo `ARNES_AUSENCIA`** antes de cada
  tanda (tres de mis cinco primeras mutaciones **no aplicaron** por un choque de delimitador en
  `sed`, y lo vi porque leo la tabla resultante en vez de suponerla: una mutación que no muta
  produce un verde que no mide).
- **Control positivo en cada tanda.** Mi primera sonda dio «ALLOW» por un `$0` mal resuelto que
  impedía escribir el fixture: el ALLOW silencioso es indistinguible del ALLOW real. Desde ahí toda
  sonda distingue `ALLOW`, `DENY` y `SONDA-ROTA`, y ninguna tabla de abajo tiene un lado sin control.

### 2. `CA-11`, la equivalencia: comentado ≡ borrado, en los DOS estados de la llave

Cabecera discriminante por campo (el resto de los campos en el valor con el que la retirada de
**éste** es lo único que mueve el veredicto), llave en los dos estados:

| Campo retirado | Llave | presente (restrictivo) | borrado | comentado | ¿C ≡ B? |
|---|---|---|---|---|---|
| `QA:` | apagada | DENY | ALLOW | ALLOW | **sí** |
| `QA:` | encendida | DENY | DENY | DENY | **sí** |
| `Seguridad:` | apagada | DENY | **DENY** | **DENY** | **sí** |
| `Seguridad:` | encendida | DENY | DENY | DENY | **sí** |
| `Sensible a seguridad:` | apagada | DENY | ALLOW | ALLOW | **sí** |
| `Sensible a seguridad:` | encendida | DENY | DENY | DENY | **sí** |
| `Hallazgos abiertos:` | apagada | DENY | ALLOW | ALLOW | **sí** |
| `Hallazgos abiertos:` | encendida | DENY | DENY | DENY | **sí** |
| `Rigor:` | apagada | DENY | ALLOW | ALLOW | **sí** |
| `Rigor:` | encendida | DENY | DENY | DENY | **sí** |

**10 pares, 0 divergencias.** Con eso queda acreditado lo que `CA-11` contrata —que **la vía** de la
desaparición no cambie la decisión— y queda acreditado **en los dos estados**, que es la parte que
el criterio añadió el 2026-09-10.

**La excepción de `Seguridad:` en `critico`, también por SUELO y no sólo por `Rigor:` declarado:**
con `Sensible a seguridad: sí` y `Rigor: ligero` escrito, comentar o borrar `Seguridad:` da **DENY**
en los dos estados de la llave, y el control con `Seguridad: aprobado` **cierra**. La excepción no
depende de que el REQ declare `critico` a mano.

### 3. El puntero nuevo, ejercido: **5 de 6 campos llevan a donde dicen; `Seguridad:` no** — `SEC-082`

`CA-11` remite hoy, por propiedad, a «la tabla de la dirección de la ausencia de `hooks/lib.sh` —la
constante que la declara y la función que la consulta—», y afirma dos cosas sobre ella: que **ahí
vive la lista exhaustiva** y que **ahí se decide**.

**La primera es cierta, y es una mejora real sobre el puntero viejo.** Derivando el dominio del
propio lector (`ARNES_CLAVES`, sin escribir ninguna clave a mano), las **6** claves declaran
dirección en el sitio: `QA|deniega`, `Seguridad|deniega`, `Sensible a seguridad|gobierna:si`,
`Hallazgos abiertos|deniega`, `Rigor|gobierna:critico`, `Estado|n/a`. El puntero **viejo**
(`hooks/guard-completado.sh`) contenía **2**. El write-back corrige un puntero falso medido.

**La segunda es falsa para un campo, y es el mío.** Mutando la dirección declarada y midiendo el
veredicto de la puerta (campo ausente, llave encendida):

| Campo ausente | Dirección declarada | Mutada a | Base | Mutante | ¿decide la tabla? |
|---|---|---|---|---|---|
| `QA:` | `deniega` | `gobierna:aprobado` | DENY | **ALLOW** | **sí** (control positivo) |
| `Sensible a seguridad:` | `gobierna:si` | `gobierna:no` | DENY | **ALLOW** | **sí** |
| `Hallazgos abiertos:` | `deniega` | `gobierna:(ninguno)` | DENY | **ALLOW** | **sí** |
| `Rigor:` | `gobierna:critico` | `gobierna:ligero` | DENY | **ALLOW** | **sí** |
| **`Seguridad:`** | **`deniega`** | **`gobierna:aprobado`** | **DENY** | **DENY** | **NO** |

Cuatro de cuatro controles positivos mueven el veredicto: la técnica **discrimina**. `Seguridad:`
no se mueve. Quien decide es el `[ "$seg" != "aprobado" ]` del `case critico` de
`hooks/guard-completado.sh`, que **no consulta la tabla**; `grep -n 'arnes_resuelve_ausencia "'`
sobre `hooks/` da **cuatro** llamadas y **ninguna** para `ARNES_CLAVE_SEG`.

**Y la declaración es INCONDICIONAL mientras la conducta es CONDICIONAL al rigor.** Medido, con la
llave **encendida**: `Rigor: ligero` y `Rigor: estandar` sin línea `Seguridad:` → **ALLOW**, igual
que con `Seguridad: pendiente`. Es decir: la tabla promete un `deniega` que **por debajo de
`critico` no ocurre**.

**Ubicación de las dos superficies que se desmienten:**
1. `hooks/lib.sh`, el comentario del propio sitio: «**EL UNICO SITIO QUE DECIDE.** Los tres lectores
   … pasan por aqui y **por ningun otro sitio**». Falso para `Seguridad:`. **Es código que todo
   proyecto instalado hereda.** Es lo que QA abrió como **`QA-024-12`**, contra `REQ-024`.
2. `requirements/REQ-016.md` `CA-11`, párrafo «El sitio único, nombrado por PROPIEDAD…»: «qué hace
   la máquina cuando un campo no llega a declararse … **lo decide un solo sitio**». Falso para
   `Seguridad:`. **Esta superficie es nueva: la creó el write-back del 2026-09-10 y QA no la abrió
   contra `REQ-016`.**

**Clase: `contrato`, y por eso SUBO la de `QA-024-12`.** QA lo clasificó `instrumento` con un
argumento que comparto en los hechos —la conducta de hoy es correcta y el engaño va del lado
**conservador**— y que **no decide la clase**. La clase no mide el daño: mide si el texto firmado es
**falso sobre lo construido**, que es literalmente la definición que `REQ-016` §«La clase del
defecto» usó para no llamarse `instrumento` a sí mismo, y la que `SEC-050` y `QA-024-13` ya
aplicaron en esta ventana. Un comentario que afirma **exclusividad falsa** sobre el sitio que
gobierna la ausencia es, en superficie de **código heredado**, la misma forma que `SEC-079` en
superficie heredada de `AGENTS.md`. Y no es teórico: **quien siga `CA-11` al pie de la letra para
responder «¿qué pasa si falta `Seguridad:`?» leerá `deniega` sin condición y concluirá que la puerta
es más estricta de lo que es** — que es, palabra por palabra, el mecanismo por el que `SEC-050` dejó
a un auditor concluyendo «no falta nada» sobre los dos campos peligrosos.

**Lo que NO es, dicho para que nadie lo lea de más:** no es un fail-open. No existe hoy ninguna
cabecera en la que esta falsedad haga que la puerta permita algo que su valor declarado habría
cerrado (§4), y `ADR-009:181` **describe la conducta con exactitud** —«su veredicto se lee **sólo**
cuando el rigor efectivo es `critico`»—, igual que el `_doc` del manifiesto. La falsedad está en el
**sitio al que el criterio manda**, no en la decisión.

### 4. La condición nueva de `CA-11`: encender la llave **no abre nada** — 243 casos, 0

`CA-11` ya no promete el perdón sin condición: vale «**mientras `campos.ausencia_exige` esté
apagada**». La propiedad que a mí me importa no es que el perdón exista, es que **activar la
exigencia no abra ninguna puerta**. Barrido cartesiano de los 5 campos de veredicto × {ausente,
valor restrictivo, valor permisivo} = **243** cabeceras, cada una evaluada con la llave apagada y
encendida:

| Transición | Casos | Lectura |
|---|---|---|
| DENY (apagada) → **ALLOW** (encendida) | **0** | **La llave no abre nada** |
| ALLOW (apagada) → DENY (encendida) | **66** | Dirección conforme: cierra lo que estaba abierto |
| DENY → DENY | 163 | — |
| ALLOW → ALLOW | 14 | — |
| Sondas rotas | **0** | El barrido midió las 486 invocaciones |

Los 14 ALLOW/ALLOW y los 66 son el control de que el barrido **discrimina en los dos sentidos**: no
es un instrumento que diga siempre lo mismo.

**No-regresión contra la línea base de `R-009`, en lo que la lógica nueva podía desplazar.** Lo que
más me preocupaba: que un `deny` por **medibilidad** se resolviera ahora como **ausencia**, que es
justo lo que la puerta perdona. Medido en los dos estados de la llave:

| Sonda | Llave apagada | Llave encendida |
|---|---|---|
| Rango `<!--` **sin cerrar** en la cabecera (`CA-03`) | DENY **citando el rango** | DENY citando el rango |
| `Seg`+CR+`uridad: aprobado`, todo lo demás en verde (`CA-12`) | DENY **por el CR**, no por ausencia | ídem |
| `Hall`+CR+`azgos abiertos: (ninguno)`, todo en verde (`CA-12`) | DENY por el CR | ídem |

Ninguna de las tres se resuelve como ausencia. La línea base de `R-009` se sostiene en las
propiedades que este delta podía tocar.

### 5. Lo que encontré y no estaba en ningún papel — `SEC-083`

La invariante de `AGENTS.md` §13 «**Seguridad no firma lo que QA no ha validado** (salvo
`Seguridad: preventiva`)» la cumple `hooks/guard-completado.sh:274`, y su condición es
`[ "$seg" = "aprobado" ] && [ -n "$qa" ] && [ "$qa" != "aprobado" ]`. Ese `[ -n "$qa" ]` **es** una
decisión sobre la ausencia, tomada **fuera del sitio único** —que para `QA:` declara `deniega`—, en
una guarda que **no es la puerta de cierre** y a la que por tanto `ADR-009` **no llega**: su alcance
declarado es «la puerta de cierre y el lector de campos».

Medido (`Edit` que escribe `Seguridad: pendiente` → `Seguridad: aprobado` sobre un REQ `critico`):

| Línea `QA:` en el disco | Llave apagada | Llave encendida |
|---|---|---|
| `QA: pendiente` (control) | **DENY**, nombrando el cruce | **DENY** |
| `QA: con-hallazgos` (control) | **DENY**, nombrando el cruce | **DENY** |
| `QA: aprobado` (control) | ALLOW (correcto) | ALLOW |
| **ausente / comentada** (sonda) | **ALLOW** | **ALLOW** |

**Comentar o borrar una línea retira la invariante que protege el orden de las firmas, y la llave de
`ADR-009` no lo cierra en ninguno de sus dos estados.** Los tres controles acotan el resultado: la
guarda **sí** muerde cuando el campo está, así que el ALLOW no es un instrumento que no mide.

**Por qué esto sí es grave, en una frase:** es la única invariante de §13 que `ADR-009` no cubrió, y
es la que decide si **mi propia firma** puede emitirse sobre un árbol sin validar — exactamente la
falta que `AGENTS.md` §6 llama «convertir una revisión parcial en un sello de calidad que nadie
emitió». Y el estado cruzado **persiste**: la guarda sólo juzga la edición que **toca**
`Seguridad:`, así que reponer `QA: pendiente` después no dispara nada.

**Lo que NO afirmo:** el cierre del REQ sigue bloqueado por otras vías en la mayoría de las
composiciones, y con la llave **encendida** la ausencia de `QA:` deniega **en el cierre**. El
agujero es de la **guarda de orden**, que corre en **cualquier** edición, no del cierre.

### 6. Los cuatro hallazgos que me pidieron valorar, y qué hago con cada uno

| Hallazgo | Clase de QA | Mi decisión | Motivo en una línea |
|---|---|---|---|
| **`QA-016-02`** (`contrato`, alta) | bloqueante de `REQ-016` | **`mitigado`, y lo retiro del campo** | La exposición que nombraba —cierre en ALLOW sobre una firma del 2026-09-07 emitida sobre otro `CA-11`— **ya no existe**: la firma vencida está sustituida y la puerta deniega. Verificado, no supuesto (abajo) |
| **`QA-024-12`** (`instrumento`, media) | no bloqueante | **SUBO a `contrato`** | Confirmado por mi propia mutación (§3). Un comentario que afirma exclusividad falsa sobre el sitio que gobierna la ausencia es texto **falso sobre lo construido** en superficie **heredada**: `contrato`, como `SEC-050` y `SEC-079` |
| **`QA-016-01`** (`instrumento`, media) | no bloqueante | **MANTENGO `instrumento`** | El defecto está en una **prueba**, y `AGENTS.md` §6 asigna `instrumento` a «un lector de umbral, un guardián, **una prueba**». Subirla haría de un defecto de control una condición para cerrar, que es lo que §6 prohíbe. **Pero le pongo forzador**: es el caso que debía notar este desfase y no lo notó, así que queda **atado a `SEC-082`** como su remediación (3) |
| **`H-07`** (`instrumento`) | no bloqueante | sin cambios, no lo toqué | Fuera del rango de §0 |

**`QA-016-02` cerrado con su remedio verificado en la puerta**, con el control que hace concluyente
cada lado (fixture aislado, cola **vacía a propósito**, llave apagada):

| Fixture | `Seguridad:` | `Hallazgos abiertos:` | Veredicto |
|---|---|---|---|
| **A** — como dejo `REQ-016` | `con-hallazgos` | `H-07 (i), QA-016-01 (i), SEC-082 (contrato)` | **DENY** por el veredicto de seguridad |
| **B** — si alguien escribiera `aprobado` sin el write-back | `aprobado` | ídem | **DENY**, nombrando `sec-082` |
| **C** — control: `aprobado` y **sin** mi hallazgo | `aprobado` | `H-07 (i), QA-016-01 (i)` | **ALLOW** ← reproduce el fail-open que QA midió |
| **D** — control: `con-hallazgos` y sin bloqueantes | `con-hallazgos` | `H-07 (i), QA-016-01 (i)` | **DENY** |

**Dos motivos independientes**, y el C es la razón por la que no basta con uno: si un día el
veredicto pasa a `aprobado` sin que el write-back exista, `SEC-082` sigue reteniendo el cierre. Eso
es exactamente la lección de `QA-016-02` —«la cola es transitoria y la firma vencida no»— aplicada a
mi propio acto: **no dejo el campo sin nada bloqueante**.

### 7. Lo que acredita esta firma, y lo que NO

| Acredita — medido en este árbol y con control |
|---|
| `CA-11`, **la equivalencia**: comentado ≡ borrado, **10 pares, 0 divergencias**, en los **dos** estados de la llave (§2) |
| `CA-11`, **la excepción**: `Seguridad:` ausente **no** se perdona con rigor efectivo `critico`, también cuando el `critico` viene del **suelo** de sensibilidad y el REQ declara `ligero` (§2) |
| `CA-11`, **la lista exhaustiva**: las **6** claves del lector declaran dirección en el sitio único, derivado de `ARNES_CLAVES` y no de una lista escrita por mí (§3) |
| `CA-11`, **la condición nueva**: encender `campos.ausencia_exige` **no convierte ningún DENY en ALLOW** — **0 de 243**, con 66 en la dirección conforme y 0 sondas rotas (§4) |
| **No-regresión** de la línea base de `R-009` en lo que este delta podía desplazar: el rango sin cerrar y el CR interior siguen denegando **por su propio motivo** y **nunca** se resuelven como ausencia (§4) |
| Que el árbol de **código** que audito es **byte a byte** el que QA validó (§0) |

| NO acredita — cada renglón porque alguien podría leerlo de más |
|---|
| **El texto de `CA-11`.** Es el objeto del re-recorrido y es lo que **no** firmo: su frase del «único sitio que decide» es falsa para `Seguridad:` (`SEC-082`, §3) |
| **`REQ-024` entero, y `CA-01`/`CA-02`/`CA-03`.** Hay un `analista-requerimientos` vivo en ese archivo; no lo audito ni lo toco. Mi medición de la tabla **no** acredita sus criterios |
| **Que el banco tenga forzador para la propiedad de §3.** No lo tiene, y es `QA-016-01`: hoy **nada** notaría que el sitio único deje de decidir para un campo. No lo arreglo ni lo mido más allá de constatarlo |
| **El resto del delta de `hooks/` desde `R-009`** (1023 líneas: escáner de CR, rotador, bloque derivado). Mi §4 es **no-regresión sobre sondas propias**, una cota inferior, **no** una auditoría |
| **El banco y las quality gates.** No los ejecuté: cito de QA **1017 PASS · 0 FAIL · 7 SKIP** (cuadre 1024) y el CI **PASS** sobre `a57eecc`, y `hooks/` no cambió entre `a57eecc` y `ce714c7` (§0) |
| **`REQ-017`, `REQ-023`, `REQ-026`, `REQ-027`.** Fuera del encargo; no los toqué |
| **Que `REQ-016` pueda cerrarse.** No puede, y por **tres** vías: la cola de **7** entradas, mi `con-hallazgos` y `SEC-082`. **No cambié su `Estado:`** |
| **El `D8` ni ningún encendido de la llave en el repositorio.** La llave se encendió **sólo** en el manifiesto del fixture, y cada medición dice en qué estado se tomó |

### SEC-082 — `contrato` · **abierto** · severidad **alta** · dueño `desarrollador` (el código y su comentario) y `analista-requerimientos` (el write-back de `CA-11`)

**El sitio único DECLARA la dirección de `Seguridad:` y no la DECIDE: la tabla dice `deniega` sin condición, la conducta real es condicional al rigor, y los dos textos que mandan a ese sitio afirman exclusividad — probado por mutación con control positivo**

- **Ubicación del mecanismo:** `hooks/lib.sh` § «EL SITIO UNICO DE LA DIRECCION DE LA AUSENCIA»
  (`ARNES_AUSENCIA`, entrada `Seguridad|deniega`) y el comentario de `arnes_resuelve_ausencia`
  («EL UNICO SITIO QUE DECIDE … por ningun otro sitio»); quien decide de verdad es el
  `[ "$seg" != "aprobado" ]` del `case critico` de `hooks/guard-completado.sh`.
- **Ubicación de los textos que se desmienten:** (1) ese comentario de `hooks/lib.sh` —**código que
  los proyectos heredan**—, que es `QA-024-12`, contra `REQ-024`; (2) `requirements/REQ-016.md`
  `CA-11`, párrafo «El sitio único, nombrado por PROPIEDAD…», **superficie nueva creada por el
  write-back del 2026-09-10**, contra `REQ-016`.
- **Medido** (R-026 §3, `ce714c7`, fixture aislado, llave encendida sólo en él): mutar
  `Seguridad|deniega` → `gobierna:aprobado` **no mueve** el veredicto (DENY → DENY); la **misma**
  mutación sobre `QA`, `Sensible a seguridad`, `Hallazgos abiertos` y `Rigor` mueve **4 de 4**
  (DENY → ALLOW), así que la técnica discrimina. Y con la llave encendida, `Rigor: ligero` o
  `estandar` **sin** línea `Seguridad:` → **ALLOW**, luego el `deniega` incondicional de la tabla
  **no ocurre** por debajo de `critico`.
- **No es un fail-open, y por eso la severidad es alta y no crítica.** La conducta real es correcta
  y está descrita con exactitud en `ADR-009:181` y en el `_doc` del manifiesto. El daño es de
  **puntero**: quien siga `CA-11` para responder «¿qué pasa si falta `Seguridad:`?» leerá `deniega`
  sin condición. Es el mecanismo exacto de `SEC-050`.
- **Por qué `contrato` y no `instrumento` —y subo la clase de `QA-024-12`.** No es una prueba ni un
  control: es la **declaración del mecanismo** y un **criterio firmado**, y los dos son falsos sobre
  lo construido para uno de los seis campos: el del veredicto de seguridad. La clase no mide el
  daño; mide la falsedad del texto (`requirements/README.md`; misma aplicación que `SEC-050`,
  `SEC-079` y `QA-024-13`). Que el engaño sea **conservador** cambia la severidad, no la clase.
- **Remediación.**
  1. **El código o su comentario** (`desarrollador`, elige **una**, no las dos): (a) enrutar
     `Seguridad:` por `arnes_resuelve_ausencia` y declarar su dirección **condicionada al rigor**;
     o (b) dejar la conducta y **acotar el comentario** para que no prometa por `Seguridad:` — con
     la acotación **junto a la promesa**, no en otro párrafo (`SEC-031`).
  2. **El write-back de `CA-11`** (`analista-requerimientos`): la frase del «único sitio que
     decide» tiene que decir su **alcance real**. Enunciada por propiedad: *la dirección declarada
     de cada campo vive en un solo sitio; el campo cuyo veredicto sólo se lee en `critico` la
     declara ahí y la aplica la puerta en ese nivel*. **Sin write-back no levanto el
     `con-hallazgos`**: un control que vive sólo en el código o en este registro es deriva
     (`AGENTS.md` §9).
  3. **El forzador, que hoy no existe** (`desarrollador`): un caso que derive el sitio de `CA-11`
     y compruebe que la tabla **decide** —no sólo que declara—, por mutación y con control
     positivo. Es `QA-016-01`, que **mantengo `instrumento`** y ato aquí: mientras no exista,
     mover el sitio otra vez no lo notaría nadie, que es lo que `REQ-024 CA-02` declara de
     contrato.
- **Bloquea `REQ-016`.** Entra en su `Hallazgos abiertos:` con clase `contrato`, así que
  `guard-completado` retiene el cierre **por máquina** aunque el veredicto pase a `aprobado`
  (verificado, §6 fixture B). *Vencimiento:* el cierre de **1.34.0**, el mismo que `SEC-047` y
  `SEC-050`.
- **Y en `REQ-024` no lo escribo yo.** La mitad (1) es `QA-024-12`, que vive en el campo de
  `REQ-024`; hay un `analista-requerimientos` trabajando ese archivo y **no lo toco**. Queda para
  la coordinadora: la **subida de clase a `contrato`** debe llegar a ese campo. `REQ-024` ya está
  retenido por `QA-024-13` y `QA-024-14`, así que la subida **no cambia su estado**; lo que cambia
  es que la deuda deja de estar clasificada como no bloqueante.

---

### SEC-083 — `contrato` · **abierto** · severidad **alta** · dueño `desarrollador` (la guarda) y `analista-requerimientos` (la fila de §13 y el criterio)

**La invariante «seguridad no firma lo que QA no ha validado» falla EN ABIERTO cuando la línea `QA:` no llega a declararse — y `campos.ausencia_exige` no la cierra en ninguno de sus dos estados**

- **Ubicación:** `hooks/guard-completado.sh:274`,
  `[ "$seg" = "aprobado" ] && [ -n "$qa" ] && [ "$qa" != "aprobado" ]`. Ese `[ -n "$qa" ]` decide
  sobre la **ausencia** fuera del sitio único, que para `QA:` declara `deniega`.
- **Ubicación de los textos que prometen sin condición:** `AGENTS.md` §13, fila «Seguridad no firma
  lo que QA no ha validado (salvo `Seguridad: preventiva`)»; la misma fila en
  `templates/AGENTS.md.tpl` —**superficie heredada**—; `AGENTS.md` §6 («**El orden no es una
  sugerencia: es la condición de validez de la firma**»); y el propio comentario de la guarda.
- **Medido** (R-026 §5, `ce714c7`, `Edit` que escribe `Seguridad: aprobado` sobre un REQ `critico`):
  con `QA: pendiente` o `QA: con-hallazgos` → **DENY** nombrando el cruce; con la línea `QA:`
  **ausente o comentada** → **ALLOW**, y **ALLOW igual con la llave encendida**. Control con
  `QA: aprobado` → ALLOW correcto. Los tres controles acotan el ALLOW: la guarda muerde cuando el
  campo está.
- **Por qué no lo cierra `ADR-009`:** su alcance declarado es «la puerta de cierre y el lector de
  campos», y esta guarda corre en **cualquier** edición del REQ, no en el cierre. Es `SEC-047`
  **sobreviviendo a su propia mitigación**: un proyecto que hace todo lo que `ADR-009` pide sigue
  expuesto por esta vía.
- **Riesgo, y no es de papel.** La firma de seguridad es el sello que `AGENTS.md` §6 protege
  precisamente porque el auditor **no mira las quality gates**. Comentar una línea permite emitirla
  sobre un árbol que QA no validó, y el estado cruzado **persiste**: la guarda sólo juzga la edición
  que **toca** `Seguridad:`, así que reponer `QA: pendiente` después no dispara nada. Que el
  **cierre** siga bloqueado por otras vías no repara la invariante: lo que se pierde es la
  **condición de validez de la firma**, que es un acto anterior al cierre.
- **Remediación.**
  1. **La guarda** (`desarrollador`): resolver la ausencia de `QA:` por el sitio único también aquí
     —`arnes_resuelve_ausencia`— o, si se decide que esta guarda no dependa de la llave, tratar la
     ausencia como **no validado** y denegar nombrando el campo. La dirección conforme es la de
     `ADR-009`: **la ausencia no se resuelve del lado que abre**.
  2. **El texto** (`analista-requerimientos` + gate humano, es `AGENTS.md`): mientras (1) no exista,
     la fila de §13 y su gemela de plantilla tienen que decir su **alcance real** — la invariante
     rige **sobre los REQ que declaran el campo**. Ninguna frase más ancha que lo que el código hace
     (`ADR-002`, `SEC-079`).
  3. **Un caso de banco** con fail-before, en los dos estados de la llave y con los tres controles
     de arriba.
- **Clase `contrato`, y qué REQ.** El texto firmado promete sin condición algo que la máquina no
  sostiene, en superficie que los proyectos heredan: misma forma que `SEC-079`. **No lo cuelgo de
  `REQ-016`**: no es lo que `CA-11` contrata y colgarlo ahí sería bloquear un REQ por un defecto
  ajeno a su criterio. Su sede natural es la semántica de la ausencia (`REQ-024`/`ADR-009`), **cuyo
  archivo no toco**. *Escalado a la coordinadora, y lo digo con el riesgo dentro:* mientras esto
  viva **sólo en este registro** y en ningún campo `Hallazgos abiertos:`, **ninguna puerta lo mide**
  — que es la deriva de `AGENTS.md` §9. *Vencimiento propuesto:* el cierre de **1.34.0**.

---

### SEC-050 — Estado: `abierto` → **`en-mitigación`**. El puntero se unificó y se corrigió; el residual es un campo de seis, y es `SEC-082`

La remediación **(1)** de `SEC-050` ofrecía dos salidas —nombrar las dos funciones, o «**unificarla
en un sitio, que es mejor y es lo que el criterio ya prometía**»—. `REQ-024`/`ADR-009` tomaron la
mejor: `ARNES_AUSENCIA` en `hooks/lib.sh`, y el write-back del 2026-09-10 movió `CA-11` a apuntar
ahí **por propiedad**. Medido por mí (§3): las **6** claves del lector declaran dirección en ese
sitio, frente a las **2** que contenía el puntero viejo, y `Rigor:` está incluido. Los cuatro campos
que `SEC-050` decía descritos de menos están hoy los cuatro en el sitio y en el criterio.

**Por eso baja a `en-mitigación` y no se cierra.** Residual único y nombrado: para `Seguridad:` el
sitio **declara y no decide**, y los dos textos que mandan ahí afirman exclusividad — **`SEC-082`**,
`contrato`, dueño `desarrollador` + `analista-requerimientos`, vencimiento el cierre de 1.34.0. Y
**no se cumplió la condición de agravamiento** que escribí en `R-013` («si `REQ-024` se escribe sin
cubrir los cuatro campos y el puntero, reabro `REQ-016` y esto pasa a bloquear»): los cubrió. La
reapertura de `REQ-016` la produjo `AGENTS.md` §9 por el write-back, no este hallazgo.

La remediación **(2)** (mía, la corrección del texto de `SEC-047`) y la **(3)** (la fila del rigor de
`AGENTS.md` §6/§13) **siguen abiertas** y no las toco en esta revisión: están fuera del rango de §0.

---

### 8. Estado de seguridad aprobado por REQ — línea base de no-regresión, actualizada en R-026

| REQ | Veredicto | Fecha | Alcance acreditado | Nota |
|---|---|---|---|---|
| **REQ-016** (re-recorrido de `CA-11`, 3.ª obligación de `REQ-024 CA-03 (ii)`) | **`con-hallazgos`** | 2026-09-10 | `rel/registro-1.33.0` @ `ce714c7`; rango **derivado**: texto `9d007ca` + `ce714c7`, código **`119e853^..ce714c7` restringido por RUTA** a `hooks/lib.sh`, `hooks/guard-completado.sh`, `.arnes/config.json` (§0) | **Acredita la CONDUCTA de `CA-11`**: equivalencia comentado ≡ borrado **10/10** en los dos estados de la llave; la excepción de `Seguridad:` en `critico`, también por **suelo**; las **6** claves declarando dirección en el sitio único, derivadas de `ARNES_CLAVES`; encender la llave **no abre nada, 0 de 243**; no-regresión de `R-009` en el rango sin cerrar y el CR interior. **NO acredita el TEXTO de `CA-11`** (`SEC-082`), ni `REQ-024`, ni el forzador del banco (`QA-016-01`), ni el resto del delta de `hooks/`, ni el banco/gates. **Bloqueantes abiertos míos: `SEC-082`.** **Residuales:** `SEC-083` (`contrato`, alta, **sin sede en ningún REQ** — escalado), `QA-016-01` y `H-07` (`instrumento`) |
| **REQ-023** (2.ª auditoría, acotada) | `aprobado` | 2026-09-09 | `R-025`, `fcbb7b1` | Sin cambios. Sigue `Estado: bloqueado` por decisión del propietario |
| **REQ-027** (1.ª auditoría) | `aprobado` | 2026-09-09 | `R-023`, `81d260d` | Sin cambios |
| **REQ-026** (vuelta 2) | `con-hallazgos` | 2026-09-09 | `R-022`, `4f51293` | Sin cambios. `SEC-072` y `SEC-073` siguen abiertos y siguen bloqueando |
| **REQ-017** (reapertura 1.34.0) | `aprobado` | 2026-09-08 | `R-020` | Sin cambios |
| **REQ-014** (reapertura 1.33.0) | `aprobado` | 2026-09-08 | `R-019` | Sin cambios |

**Regresiones a vigilar en `REQ-016` a partir de aquí** (además de las de `R-009`, que siguen
vigentes): que la equivalencia comentado ≡ borrado deje de valer en **alguno** de los dos estados de
la llave; que alguna clave del lector deje de declarar dirección en el sitio único; que encender
`campos.ausencia_exige` convierta **algún** DENY en ALLOW; que un `deny` por **medibilidad** (rango
sin cerrar, CR interior) pase a resolverse como **ausencia**; y que el `[ -n "$qa" ]` de la guarda de
orden se **replique** en otra guarda en vez de retirarse.

**Estado de mis hallazgos tras R-026.** **`SEC-082`** y **`SEC-083`** **abiertos** (`contrato`,
alta). **`SEC-050` `abierto` → `en-mitigación`** (residual único: `SEC-082`). **`QA-024-12`: clase
subida de `instrumento` a `contrato`** por mí; su asiento en el campo de `REQ-024` lo escribe quien
tenga ese archivo, no yo. **`QA-016-02` `mitigado`** y retirado del campo de `REQ-016`, con su
remedio verificado en la puerta y su control C reproduciendo el ALLOW que lo justificaba.
**`QA-016-01` sigue `instrumento`** por decisión mía y razonada, atado a `SEC-082` como su
remediación (3). **`SEC-047` sigue `en-mitigación`**; su mitad 2 es `REQ-024`, que no audito, y
`SEC-083` demuestra que su clase **sobrevive** a la mitigación en la guarda de orden. Sin cambios en
`SEC-048`, `SEC-049`, `SEC-051`, `SEC-078`, `SEC-080`, `SEC-081`.

**Numeración vigente tras esta revisión:** última revisión **R-026**; último hallazgo **SEC-083**;
próximos libres **R-027** y **SEC-084**.

**Rigor de `REQ-016`: sin cambios, `critico`.** No hay nada que subir: `Sensible a seguridad: sí` ya
impone ese suelo y el REQ lo declara. **Y no lo baja nadie**: los dos hallazgos de esta revisión
tocan la puerta que decide el acceso al cierre de todos los proyectos instalados.

**`docs/seguridad/gobernanza-datos.md`: sin cambios.** Este delta no altera clasificación de datos,
acceso, retención ni cumplimiento, y no introduce datos personales, credenciales ni activos nuevos.
La propiedad en juego sigue siendo la **honestidad de la puerta de cierre y del orden de las firmas**
hacia los proyectos instalados, cuyas sedes son `hooks/`, `AGENTS.md` y `requirements/`.

**Método, para que se re-derive sin preguntarme.** Fixture aislado en el scratchpad de la sesión
(proyecto con `requirements/`, `PENDING_APPROVAL.md` **vacío**, `quality_gates: ["true"]`) y **copia**
de `hooks/`+`tools/` de `ce714c7`; payload `PreToolUse`/`Edit` `en-revisión`→`completado` con
`CLAUDE_PROJECT_DIR` apuntando al fixture —**sin apuntarlo, el guardián resuelve el proyecto real y
permite todo**, que es la trampa que `REQ-016` ya dejó escrita—; `campos.ausencia_exige` conmutada
**sólo** en el manifiesto del fixture; mutaciones aplicadas a la **copia** de `hooks/lib.sh` y
**verificadas leyendo `ARNES_AUSENCIA`** antes de cada tanda; clasificación de salida en `ALLOW`
(silencio y rc 0), `DENY` (`"permissionDecision":"deny"`, con y sin espacio) y **`SONDA-ROTA`**.

---

## Revisión R-027 — REQ-016, cierre de `SEC-082` y del `SEC-083` que abrí en R-026 (2026-09-10)

### 0. Alcance y RANGO DERIVADO POR MÍ — el encargo me dio los hechos, no el rango

Cuarta vez que se me da el hecho en vez del rango, y va derivado y dicho, como en `R-026`.

**Los hechos que recibí:** mi `R-026` fue sobre `ce714c7` con `Seguridad: con-hallazgos` y `SEC-082`
abierto; el arreglo de `SEC-082` —salida **(a)**: enrutar `Seguridad:` por `arnes_resuelve_ausencia`
con la dirección **condicionada al rigor**— aterrizó en `00b8cb4`; su write-back en `CA-11`, en
`de84b4a`; y `QA: aprobado` se firmó sobre `7e19537`.

**El rango que de ahí sale, en dos mitades:**

- **CÓDIGO = `ce714c7..aece716` restringido por RUTA a los cinco globs de `codigo_app`**
  (`hooks/*`, `tools/*`, `.github/*`, `.arnes/config.json`, `.claude-plugin/*`).
  Medido por mí: **122 inserciones / 9 borrados**, en **dos archivos**
  —`hooks/guard-completado.sh` 113/7 y `hooks/lib.sh` 9/2— y de **dos commits**: `00b8cb4` y
  `8b06cd6`. **Y el delta de `lib.sh` es SÓLO comentario**, verificado por mí y no citado
  (`git diff … -- hooks/lib.sh | grep -E '^[+-]'` sin las líneas de comentario y blancos sale
  **vacío**), luego **toda la conducta nueva vive en la puerta**.
- **TEXTO = `de84b4a`** (el write-back de `CA-11`, que es la remediación (2) de `SEC-082` y el objeto
  de mi veto) **+ `aece716`** (donde aterriza el `QA: aprobado` de esta vuelta).

**Por qué el rango arranca en `ce714c7` y no en `a57eecc`, que es la base de QA:** `git diff --stat`
sobre los cinco globs sale **vacío** entre `a57eecc` y `ce714c7`, y **vacío** entre `7e19537` y
`aece716`. Así que **mi rango de código y el de QA son el mismo árbol de código**, medido por los dos
extremos, y el 122/9 coincide exactamente. Lo digo porque es la razón por la que este rango es válido
y no una preferencia.

**ORDEN DE FIRMAS: intacto y medido por mí, no aceptado por cortesía.** `git diff --stat
7e19537..aece716` sobre los cinco globs sale **vacío**, y `git status --porcelain` sobre esos mismos
cinco globs sale **vacío**. El árbol de código que audito es **byte a byte** el que QA validó. Y esta
comprobación es exactamente la que la máquina **no** hace: `guard-completado.sh` compara **el valor**
del campo `QA:`, nunca si esa aprobación **cubre este árbol** — la coordinadora detuvo una vuelta
anterior por eso, y tiene razón en que el hook no lo habría detenido. Queda en el §5 como lo que es:
un hueco de la puerta que protege mi firma, no una anécdota de proceso.

**Fuera de alcance, y no por comodidad:** `REQ-024` (`bloqueado`, `D14`), `REQ-017`, `REQ-023`
(`bloqueado`, su `CA-11` en `D13`), `REQ-026`; el resto del delta de `hooks/` desde `v1.32.1`
(acreditado en `R-019`..`R-026`); el banco y las quality gates, que **no ejecuté** — no son mías y
mi veredicto no las acredita; y `QA-016-04`, **escalado como `D16`**, que no audito (sí digo abajo
dónde mi revisión toca su superficie).

### 1. Método — harness PROPIO, la puerta REAL, y control positivo antes de creer nada

No corrí el banco ni reusé el harness de QA: escribí el mío
(`<scratchpad>/r027/arnes.sh`, ~90 líneas) y ejercí `hooks/guard-completado.sh` sobre fixtures
aislados, con **dos actos** separados:

- **CIERRE** — `Edit` que sustituye `en-revisión` por `completado`, sin escribir `Seguridad:`.
- **FIRMA** — `Edit` que escribe la línea del veredicto de seguridad, **sin** transición de estado.

Separarlos es la mitad del método: son **dos guardas distintas** y confundirlas mide una con el
nombre de la otra. Cada tanda dice **en qué estado estaba la llave** (`campos.ausencia_exige`), que
se conmutó **sólo en el manifiesto del fixture** — **no encendí nada en el repositorio** y no
presupuse `D8`. Control de sanidad antes de todo: `todo verde` → ALLOW, `Seguridad: pendiente` en
`critico` → DENY. Las mutaciones se verificaron **por su efecto en la tabla derivada** (cargando la
biblioteca mutada y preguntando la dirección), **nunca por el `rc` del `sed`** — que es el error que
cometí en `R-026`, donde tres de cinco mutaciones no aplicaron por un choque de delimitador.

### 2. `SEC-082` — la declaración es HOY verdadera, cláusula por cláusula, y la conducta NO se movió

Mi veto tenía una condición escrita: *«sin el write-back de esta frase no levanto el
`con-hallazgos`»*. El write-back existe (`de84b4a`) y lo leí **contra el código**, no contra sí mismo.

| Cláusula de `CA-11` (tras el write-back) | Medición propia | Veredicto |
|---|---|---|
| La equivalencia **comentado ≡ borrado**, en los dos estados de la llave | **10 pares · 0 divergencias · 6 discriminantes** (pares en que la retirada MUEVE la decisión, así que no pasan por vacío) | **cierta** |
| La excepción: la ausencia de `Seguridad:` **no** se perdona en rigor efectivo `critico`, también por **suelo** | **20 celdas · 0 fallos**: `critico` declarado, `critico` por suelo con `Rigor: ligero` **y** con `Rigor: estandar`, por las dos vías (ausente y comentada), en los dos estados de la llave → **DENY** las 12; `estandar` y `ligero` reales → **ALLOW** las 8 | **cierta** |
| «Con la exigencia **activada** mutar esa entrada **mueve** el veredicto, igual que las otras cuatro» | Llave **encendida**: **5 de 5 claves mueven** (DENY→ALLOW) hoy. Llave **apagada**: **0 de 5 mueven** | **cierta** |
| «…y ya no es código muerto» — el estado que dejó de existir | La **misma** mutación sobre `ce714c7`: `Seguridad` **NO mueve**; las otras cuatro **mueven 4 de 4**. Hoy **5 de 5**. Es decir: **4/5 en la base, 5/5 hoy** | **cierta** |
| «Con la exigencia **apagada** la tabla **no llega a consultarse**… y lo que deniega es la exigencia del **VEREDICTO**, con un motivo que habla del veredicto y **no** de la declaración» | Llave apagada: 0/5 mutaciones mueven, y el motivo del `critico` sin el campo **no nombra** el campo y **sí** dice `el veredicto de seguridad es 'ausente'`. Llave encendida: **nombra** el campo y ya no habla del veredicto | **cierta** |
| «La consulta vive **DENTRO** del brazo `critico`» | Verificado ejecutando, no por analogía: con la llave encendida, `estandar`/`ligero` sin la línea siguen en **ALLOW** y `critico` —declarado o por suelo— en **DENY** | **cierta** |
| La cláusula estructural: dónde vive la **aplicación** de cada campo | Verificada **por ruta y línea** en el árbol de hoy: `guard-completado.sh:509` (`QA`), `:546` (`Seguridad`), `:671` (`Hallazgos abiertos`); `lib.sh:1534` (`Sensible a seguridad`) y `:2384` (`Rigor`) | **cierta** |
| Los punteros de la cita de medición | `CHANGELOG.md:448` § «`SEC-083` cerrado en código…» **existe**; `tests/escenarios/hooks/secciones/40-ausencia-que-abre-4-el-veredicto-de-seguridad.sh` **existe** y publica la medición en cada corrida | **ciertos** |

**Y la NO-REGRESIÓN de lo que acredité en `R-026`, que es la otra mitad de mi ángulo.** Producto
cartesiano propio de **216 cabeceras** (`QA` × `Seguridad` × `Sensible a seguridad` × `Rigor` ×
`Hallazgos abiertos`, cada uno en presente-verde / presente-malo / ausente), acto de **CIERRE**,
comparando llave apagada contra encendida: **DENY→ALLOW = 0**, ALLOW→DENY = 89 (dirección conforme),
DENY/DENY = 108, **ALLOW/ALLOW = 19** — el último dato va porque sin él «0 conversiones» sería cierto
por sondas muertas.

**Y la consecuencia nueva que la salida (a) crea, dicha y verificada, no descubierta después:** al
enrutar `Seguridad:` por la tabla, esa entrada **pasa a poder abrir** una puerta que antes estaba
cerrada en duro por el `[ "$seg" != "aprobado" ]`. Es el precio declarado de (a). **Está guardada:**
el caso (3) de `40/4` exige `DENY-nombra` sobre el árbol **sin mutar**, así que un cambio permanente
de esa entrada a `gobierna:aprobado` **hace fallar el banco** — no queda como fail-open silencioso.
Lo verifiqué leyendo el caso, no suponiéndolo.

**Estado: `SEC-082` `abierto` → `mitigado`.** Sus tres remediaciones existen: **(1)** el código, salida
(a), medido arriba; **(2)** el write-back de `CA-11`, cierto cláusula por cláusula; **(3)** el
forzador, que **no existía** cuando lo escribí y hoy es `40-ausencia-que-abre-4-…` con mutación,
control positivo y verificación por efecto. Se **retira** del campo `Hallazgos abiertos:` de
`REQ-016`. *No se borra este hallazgo: cambia de estado.*

**Y `SEC-050` pasa de `en-mitigación` a `mitigado`**, porque su residual **único y nombrado** era
`SEC-082`. El puntero está unificado, los seis campos declaran dirección en el sitio único y las
**seis** aplicaciones están localizadas por ruta y línea.

### 3. `SEC-083` — se cierra, y su cierre NO depende de la fila sin transcribir. Al contrario

El `qa-tester` hizo bien en no retirarlo —retirar un hallazgo de seguridad es acto del auditor— y
mejor aún en decir **por qué** hacía falta releerlo: su remediación **(2)** estaba escrita *«mientras
(1) no exista»*, y **(1) ya existe** (`00b8cb4`).

**(1), la guarda, verificada con mi harness — 12 celdas del acto de FIRMAR, 0 fallos:**

| `QA:` en disco | llave apagada | llave encendida |
|---|---|---|
| `aprobado` | **ALLOW** (control positivo: la guarda no deniega siempre) | **ALLOW** |
| `pendiente` | DENY | DENY |
| `con-hallazgos` | DENY | DENY |
| **ausente** | **DENY** ← era ALLOW en `R-026` | **DENY** |
| **comentada** (`aprobado`) | **DENY** | **DENY** |
| **comentada** (`pendiente`) | **DENY** | **DENY** |

Y las dos intenciones legítimas **siguen pasando**: `Seguridad: preventiva` sobre un `QA:` ausente →
**ALLOW**; y la edición que **no toca** el campo, con los veredictos ya **cruzados en disco** →
**ALLOW** (lo sirve el `grep` de dentro, no el estado de `QA:`). **Y el lado `QA:` está cerrado por
propiedad y no por vía:** medí **7 formas** de que ese campo no llegue a aprobar —`pendiente`,
`_QA_:`, `**QA**:`, `qa:` en minúscula, `QA :` con blanco, comentada, y ausente— y las **7 dan DENY**.

**La pregunta del encargo: ¿se puede cerrar con la fila de `AGENTS.md` §13 sin transcribir?** Sí, y
el motivo es más fuerte que «se puede»: **esa fila, tal como `REQ-024` la prescribe hoy
(`requirements/REQ-024.md:889`), NO debe transcribirse, porque el código la dejó FALSA.** El texto
prescrito dice que si la línea `QA:` no llega a declararse *«esta guarda **no deniega**… la ausencia
se resuelve del lado que abre. Medido y **abierto**»*. El `desarrollador` tomó la **salida (b)** de
`CA-12` —denegar en los **dos** estados de la llave—, así que hoy **sí deniega**: transcribir esa fila
metería en la superficie heredada una promesa **al revés**, un fail-open anunciado que ya no existe.
La fila que corresponde a la salida (b) es **más simple** que la prescrita, y por eso el cierre de
`SEC-083` **no cuelga de ella**: lo que la fila tenía que declarar era el **alcance real** de una
guarda que perdonaba, y la guarda dejó de perdonar.

**Y el write-back que `AGENTS.md` §9 me exige antes de cerrar sí existe, y no es esa fila:** el
control vive como **criterio** en `REQ-024 CA-12` (escrito en `73822fa`, **antes** del arreglo), que
contrata exactamente la conducta medida arriba — la ausencia resuelta por el sitio único y nunca por
una comprobación local. No es deriva: no vive sólo en el código ni sólo en este registro.

**Estado: `SEC-083` `abierto` → `mitigado`**, por su **causa medida** (el `[ -n "$qa" ]`). *Residual,
y no es suyo:* `CA-12 (ii)` sigue **sin implementar** —su gate es `D11`/`D12`, **sin firmar**— y la
fila de §13 sigue siendo **más ancha** que la máquina, pero **por otra causa que la que `SEC-083`
midió**: la de `SEC-084`, abajo. Re-asiento el residual ahí en vez de dejar `SEC-083` abierto por un
defecto que no nombró, que sería mover la portería.

### 4. `SEC-084` — `contrato` · **abierto** · severidad **alta** · dueño `desarrollador` (el disparador) y `analista-requerimientos` (la fila y el criterio)

**La guarda que protege el orden de las firmas reconoce el campo por CADENA LITERAL, así que toda forma de la clave que el LECTOR acepta y el disparador no reconoce emite la firma sin que ninguna guarda la juzgue — y esa forma GOBIERNA el cierre. Medido en cuatro árboles, incluido el plugin PUBLICADO**

- **Ubicación:** `hooks/guard-completado.sh`, el `grep -q 'Seguridad:' <<< "$nuevo"` que decide si el
  bloque del orden **se entra**. Es un mecanismo **anterior** a toda resolución de ausencia, así que
  ni `REQ-024 CA-01` ni `CA-12` lo alcanzan, y `campos.ausencia_exige` no lo cierra en **ninguno** de
  sus dos estados.
- **La propiedad, no la lista.** El disparador reconoce **una cadena**; el lector de cabecera
  reconoce una **clave decorada** (`REQ-016 CA-04`, tolerancia deliberada y contratada). Los dos
  conjuntos **no coinciden**, y el hallazgo es toda la diferencia entre ellos: **cualquier** forma
  que el lector acepte y el disparador no reconozca. Ejemplos **no exhaustivos** y medidos:
  `_Seguridad_: aprobado` y `**Seguridad**: aprobado` —el par de énfasis cruza los dos puntos, el
  desenvoltorio lo limpia y el valor **gobierna**—. La lista exhaustiva de formas que el lector
  acepta vive en **un solo sitio**, el lector de `hooks/lib.sh` (`arnes_norm_clave` y el bucle de
  cabecera); la de formas que el disparador reconoce es **una sola cadena**, y ahí está el defecto.
- **Medido, con la cadena completa y su control positivo en la misma corrida** (harness propio, acto
  de FIRMAR sobre un REQ `critico` con `QA: pendiente`, y después acto de CIERRE):

  | forma escrita | firma sobre `QA: pendiente` | cierre posterior | ¿el disparador la ve? |
  |---|---|---|---|
  | `Seguridad: aprobado` (control) | **DENY** | ALLOW | sí |
  | `_Seguridad_: aprobado` | **ALLOW** | **ALLOW** | **no** |
  | `**Seguridad**: aprobado` | **ALLOW** | **ALLOW** | **no** |

  Idéntico en los **dos** estados de la llave. Y **no hay aviso**: la salida del hook es **vacía**,
  `rc=0` — ni `deny` ni `systemMessage`. El control de que el aviso funciona cuando el disparador sí
  ve la clave está en la misma corrida (`Seguridad: aprobado-ish` → `systemMessage` con el
  vocabulario).
- **Por qué es un fail-open y no una molestia, y es la diferencia con `QA-024-19`.** El campo
  **gobierna**: un `critico` cuyo único veredicto de seguridad está escrito así **CIERRA** (medido).
  La secuencia completa no necesita malicia: el auditor firma decorado sobre un árbol que QA no
  validó → nadie deniega y nadie avisa → QA repone después su `aprobado` (edición que no toca
  `Seguridad:`, y que **correctamente** no se juzga) → el REQ **cierra**. El estado final es
  **indistinguible** del correcto. Lo que se pierde es lo que `AGENTS.md` §6 llama **la condición de
  validez de la firma**, y se pierde **en silencio**.
- **Preexistente, y en producción.** La misma cadena da el mismo resultado en **`v1.32.1`**,
  **`v1.33.0` (el plugin PUBLICADO)**, `ce714c7` y `aece716`, con el control limpio en **DENY** en
  los cuatro. **No lo introdujo este arreglo**, y por eso no reabre nada de lo que audito; y está
  **vivo en lo que los proyectos ya tienen instalado**, que es lo que sube la severidad.
- **Exposición viva en este repositorio: ninguna, y lo medí.** Barrido de las cabeceras de los 27
  `requirements/REQ-*.md` buscando `Seguridad:`/`QA:` con la clave decorada: **0 ocurrencias**. La
  exposición es **latente**, no actual — y eso es lo único que la separa de `crítica`.
- **Por qué `contrato` y no `instrumento`.** El defecto está en un guardián, sí, pero la clase **no
  mide dónde está el defecto: mide si el texto firmado es falso sobre lo construido**
  (`requirements/README.md`). La fila de `AGENTS.md` §13 —«Seguridad no firma lo que QA no ha
  validado»— y `AGENTS.md` §6 —«el orden … es la condición de validez de la firma»— prometen **sin
  condición** algo que la máquina **no sostiene**, en superficie que los proyectos **heredan** por
  `arnes-upgrade` (`templates/AGENTS.md.tpl` lleva la gemela). Misma aplicación que `SEC-079`,
  `SEC-050` y `SEC-082`. Y aquí el engaño **no** va del lado conservador: va del lado que **abre**.
- **Remediación.**
  1. **El disparador** (`desarrollador`): decidir si el acto se entra **por el lector**, no por una
     cadena — preguntar si el contenido entrante **declara** el campo `Seguridad:` con el **mismo
     lector de cabecera** que después lo lee, para que el conjunto que dispara la guarda y el
     conjunto que gobierna el cierre sean **el mismo por construcción** y no dos listas que se
     desfasan. Ensanchar el `grep` con las formas de hoy **no** gana la clase: es la lección de
     `ADR-002` y `SEC-020`, y esta es su enésima instancia.
  2. **El texto** (`analista-requerimientos` + gate humano, es `AGENTS.md`): la fila de §13 y su
     gemela de plantilla declaran su **alcance real**, y la oración titular tiene que ser verdadera
     **leída sola** (`REQ-023 CA-10`). Esto **sustituye** al texto prescrito en
     `requirements/REQ-024.md:889`, que la salida (b) dejó falso (§3). **Y el criterio que lo cierra
     —`REQ-024 CA-12`— hay que releerlo:** su `Entonces` prohíbe resolver la ausencia fuera del sitio
     único, y **este defecto no es una resolución de ausencia**: es el **acto que no se reconoce**.
     `CA-12` no lo cubre y no basta ensancharlo de palabra.
  3. **Un caso de banco** con **fail-before** (falla contra `v1.33.0` y contra `aece716`), la cadena
     completa —firma decorada + cierre posterior— y los tres controles: la forma limpia **deniega**,
     el lado `QA:` sigue en 7/7 DENY, y la ausencia de aviso se mide como **ausencia de
     `systemMessage`**, no como `rc`.
  4. **La verificación que la puerta no hace, nombrada aquí porque este hallazgo la vuelve
     material** (`desarrollador`, **de contrato**): `guard-completado.sh` compara **el valor** del
     campo `QA:` y nunca si esa aprobación **cubre el árbol** que se firma. La llave que lo cerraría
     —`veredictos.caducan_con_codigo`— nace **apagada**, y `QA-016-03` midió que **no habría cazado
     este caso** (veredicto y código del mismo día, comparación estrictamente anterior con
     resolución de día). Sin ella, **el orden de firmas lo sostiene una persona leyendo fechas**, y
     esta vuelta lo demuestra: la coordinadora detuvo un despacho por eso y el hook no lo habría
     detenido.
- **Asiento, y no lo escribo yo.** **No lo cuelgo de `REQ-016`**: no es lo que `CA-11` contrata, y
  `CA-04` —que sí es de este REQ— **exige** que la forma decorada gobierne, cosa que hace; el defecto
  está en la otra guarda. Su sede natural es la del orden de las firmas, `REQ-024 CA-12`/`ADR-011`,
  **cuyo archivo no toco** (`bloqueado`, `D14`) y que ya carga `SEC-083`, así que el asiento **no
  cambia su estado**. *Escalado a la coordinadora, con el riesgo dentro:* mientras viva **sólo en
  este registro** y en ningún campo `Hallazgos abiertos:`, **ninguna puerta lo mide** — que es la
  deriva de `AGENTS.md` §9. *Vencimiento propuesto:* el cierre de **1.34.0**, con el añadido de que
  la parte del **plugin publicado** merece decisión del propietario aparte: hay proyectos corriendo
  `v1.33.0` con esto abierto.

### 5. `QA-024-19` — SUBO la clase de `instrumento` a `contrato`, y el motivo es una premisa medida falsa

El `qa-tester` preguntó bien y razonó bien con lo que tenía. Su clase se apoya en una frase explícita:
*«el **cierre sigue fail-closed**»*, y de ahí «lo que se pierde es el guardián del orden y el aviso».
**Esa premisa es cierta para la forma que midió y falsa para la clase que el defecto tiene.** Con la
clave en **minúscula** el lector tampoco la lee, el campo queda **ausente** y el cierre **deniega** —
fail-closed, como dijo. Con la clave **decorada** el lector **sí** la lee, el campo **gobierna** y el
cierre **ALLOW** (§4). Misma causa raíz —el disparador por cadena literal—, dirección del daño
**opuesta**.

Así que subo la clase por la regla de siempre: **la clase no mide el daño, mide la falsedad del texto
sobre lo construido**, y aquí el texto que se desmiente está en `AGENTS.md` §6/§13 y en la plantilla
que los proyectos heredan. Misma aplicación que hice con `QA-024-12` en `R-026`.

`QA-024-19` queda como el **sub-caso fail-closed** de `SEC-084`, que es el hallazgo por propiedad;
mantengo su dueño (`desarrollador`) y su remediación se subsume en la **(1)** de `SEC-084` — cerrar
las dos con un `grep` más ancho es exactamente lo que la remediación (1) dice que no funciona.
**Su asiento está en el campo `Hallazgos abiertos:` de `REQ-024`, que no toco:** la subida de clase la
escribe quien tenga ese archivo. Y aunque `REQ-024` ya está retenido por otros hallazgos, esto
**cambia algo real**: la deuda deja de estar clasificada como no bloqueante.

### 6. Una observación sobre el titular de `CA-11`, declarada como JUICIO y no como medición

El titular de `CA-11` dice: *«…un campo ausente se perdona **MIENTRAS** la exigencia no esté
activada, **salvo `Seguridad:`** en un REQ de rigor efectivo `critico`»*. **Leído aislado** —y el
arnés aplica esa lectura a los titulares, `REQ-023 CA-10`, citado dentro de `REQ-024 CA-12`— le
falta una excepción: desde `00b8cb4`, con la llave **apagada**, la ausencia de `QA:` **tampoco** se
perdona en el acto de **FIRMAR** (medido, §3). La lista de excepciones es una **enumeración** y
tiene una menos que la máquina.

**Y lo dejo como observación y no como hallazgo, con el motivo dicho:** el cuerpo de `CA-11` nombra
**«la puerta de cierre»** cuatro veces como su sujeto, así que dentro de su alcance el enunciado es
verdadero, y lo que le falta pertenece a **otro acto** que `CA-11` no contrata. **Es un juicio, no
una medición**, y por eso va escrito: si el `analista-requerimientos` o el propietario lo leen del
otro modo, la corrección es de **una línea** —nombrar el acto en el titular, o enunciar la excepción
por **propiedad** en vez de por lista— y no reabre nada de la conducta. *Dueño:*
`analista-requerimientos`. *Ventana:* el mismo write-back de `SEC-084` (2), que ya toca esta familia
de frases. **No bloquea, y no la convierto en hallazgo para no ganar una cuarta vuelta de texto sobre
un criterio cuya conducta pasa** — que es precisamente el bucle que `AGENTS.md` §6 describe cuando
dice que el contador de vueltas no se reinicia con cada variante.

### 7. Qué acredita este veredicto y qué NO

| **ACREDITA** |
|---|
| La **conducta** de `CA-11` sobre el acto de **CIERRE**: equivalencia comentado ≡ borrado **10 pares / 0 divergencias / 6 discriminantes**; la excepción del `critico` **20 celdas / 0 fallos**, incluido el `critico` por **suelo** con `Rigor: ligero` y con `estandar`; y que por debajo de `critico` **no** deniega, en los dos estados de la llave |
| Que la **declaración** de `CA-11` es hoy **verdadera cláusula por cláusula** (tabla del §2), incluida la cita de medición corregida: la entrada de `Seguridad:` **era** código muerto y **ya no lo es** —**4/5** en `ce714c7`, **5/5** hoy, mutación verificada por su **efecto**— |
| Que la **conducta no se degradó** al enrutarla: **0 de 216** conversiones DENY→ALLOW al encender la llave, con 19 ALLOW/ALLOW que impiden leerlo como cierto por vacío |
| Que la remediación **(1)** de `SEC-083` está en el código y es **completa por el lado `QA:`**: 12 celdas del acto de firmar, **7 de 7** formas de que `QA:` no apruebe dan DENY, y las dos intenciones legítimas siguen pasando |
| Que el árbol de código que audité es **byte a byte** el que QA validó (`7e19537..aece716` vacío en los cinco globs, `git status` vacío en los cinco globs) |

| **NO ACREDITA** |
|---|
| **La invariante del orden de las firmas**, que es la que protege **mi propia firma**: está **abierta** por `SEC-084` y **no** la cubre esta revisión. Un `aprobado` mío **no** significa que esa guarda sea infranqueable |
| El **banco** ni las **quality gates**: **no los ejecuté**. Cito de QA 1056/0/8 y 1057/0/7 con cuadre 1064, y no los hago míos |
| `REQ-024` (`bloqueado`), `REQ-017`, `REQ-023`, `REQ-026`; ni `CA-12` de `REQ-024`, cuyo **(ii)** sigue sin implementar |
| **`QA-016-04`**, escalado como `D16`. **Mi revisión SÍ toca su superficie y lo digo:** las 20 celdas del §2 y las 216 del cartesiano incluyen cabeceras **sin** `Rigor:` y con `Rigor:` reconocido, y ninguna ejerce un `Rigor:` **no reconocido** —`critico (por suelo)`—, que es la vía que ese hallazgo mide. Mi «0 de 216 abren» **no** dice nada sobre ella; y si esa vía cae abierta a `estandar`, el brazo `critico` que acabo de acreditar **no se ejecuta**, así que el suelo de mi propia excepción depende de un hallazgo que no audito. Es una dependencia real y va nombrada, no descubierta después |
| Ningún **coste** ni rendimiento: los techos son de otros REQ |
| El **cierre** de `REQ-016`: **no cambié su `Estado:`** ni podría — la cola tiene **14** entradas |

### 8. Estado de seguridad aprobado por REQ — línea base de no-regresión, actualizada en R-027

| REQ | Veredicto | Fecha | Alcance acreditado | Nota |
|---|---|---|---|---|
| **REQ-016** (re-recorrido de `CA-11` tras el arreglo de `SEC-082`) | **`aprobado`** | 2026-09-10 | `rel/registro-1.33.0` @ `aece716`; rango **derivado por mí**: código **`ce714c7..aece716` restringido por RUTA** a los cinco globs de `codigo_app` (122/9, dos archivos, dos commits, `lib.sh` **sólo comentario**) + texto `de84b4a` + `aece716` (§0) | **Acredita** la conducta y la **declaración** de `CA-11` (tabla §2), la no-regresión **0/216**, y la mitad `QA:` de `SEC-083` (**7/7**). **NO acredita** la invariante del **orden de las firmas** (`SEC-084`, abierto), ni el banco/gates, ni `REQ-024`/`017`/`023`/`026`, ni la vía de `QA-016-04`. **Bloqueantes míos abiertos en este REQ: ninguno** — `SEC-082` cerrado y retirado del campo. **Residuales:** `SEC-084` (`contrato`, alta, **sin sede en ningún REQ** — escalado), `QA-016-01` y `H-07` (`instrumento`) |
| **REQ-023** (2.ª auditoría, acotada) | `aprobado` | 2026-09-09 | `R-025`, `fcbb7b1` | Sin cambios. Sigue `Estado: bloqueado` por decisión del propietario |
| **REQ-027** (1.ª auditoría) | `aprobado` | 2026-09-09 | `R-023`, `81d260d` | Sin cambios |
| **REQ-026** (vuelta 2) | `con-hallazgos` | 2026-09-09 | `R-022`, `4f51293` | Sin cambios. `SEC-072` y `SEC-073` siguen abiertos y siguen bloqueando |
| **REQ-017** (reapertura 1.34.0) | `aprobado` | 2026-09-08 | `R-020` | Sin cambios |
| **REQ-014** (reapertura 1.33.0) | `aprobado` | 2026-09-08 | `R-019` | Sin cambios |

**Regresiones a vigilar en `REQ-016` a partir de aquí** (además de las de `R-009` y `R-026`, que
siguen vigentes): que la entrada `Seguridad|deniega` del sitio único **cambie de valor** —hoy lo caza
el caso (3) de `40/4`, y si ese caso se relaja el fail-open vuelve **abierto**—; que la consulta al
sitio único **salga** del brazo `critico`, porque eso movería el ALLOW de `estandar`; que el conjunto
de formas que **disparan** la guarda del orden y el conjunto de formas que el **lector** acepta
vuelvan a divergir tras arreglar `SEC-084`; y que el `[ -n "$qa" ]` retirado **reaparezca** en
cualquier guarda.

**Estado de mis hallazgos tras R-027.** **`SEC-082` `abierto` → `mitigado`** (tres remediaciones
verificadas; retirado del campo de `REQ-016`). **`SEC-083` `abierto` → `mitigado`** por su causa
medida, con el residual **re-asentado** en `SEC-084` y no dejado colgando de él. **`SEC-050`
`en-mitigación` → `mitigado`**: su residual único era `SEC-082`. **`SEC-084` `abierto`**
(`contrato`, **alta**), **sin sede en ningún REQ** — escalado, y vivo en el plugin **publicado**.
**`QA-024-19`: clase subida de `instrumento` a `contrato`** por mí; su asiento en el campo de
`REQ-024` lo escribe quien tenga ese archivo, no yo. **`QA-016-01` sigue `instrumento`** y su
remediación **parece cumplida** —el forzador existe, `40/4`— pero **retirarlo es acto del
`qa-tester`**, no mío: el mismo reparto que él respetó conmigo. **`SEC-047` sigue `en-mitigación`**:
`SEC-084` demuestra que su clase **sobrevive dos veces** a su propia mitigación. Sin cambios en
`SEC-048`, `SEC-049`, `SEC-051`, `SEC-078`, `SEC-080`, `SEC-081`.

**Numeración vigente tras esta revisión:** última revisión **R-027**; último hallazgo **SEC-084**;
próximos libres **R-028** y **SEC-085**.

**Rigor de `REQ-016`: sin cambios, `critico`.** `Sensible a seguridad: sí` ya impone ese suelo y el
REQ lo declara. **Y no lo baja nadie.**
