# AGENTS.md — {{NOMBRE_PROYECTO}}

> Archivo canónico de contexto y reglas del proyecto (estándar AGENTS.md, leído por
> Claude Code, Codex, Cursor y otros). Cualquier IA que abra el proyecto lo lee primero.
> Para Claude Code, `CLAUDE.md` importa este archivo.

---

## 0. Ritual de inicio y cierre de sesión (leer primero)

**Al iniciar una sesión**, todo agente se orienta leyendo, en orden:
1. `AGENTS.md` (este archivo) — contexto y reglas.
2. `docs/ESTADO.md` — dónde quedamos y cuál es el próximo paso concreto.
3. `requirements/README.md` — qué está pendiente.

**Al cerrar trabajo**, el agente activo debe:
- Actualizar `docs/ESTADO.md` (fase, en progreso, próximo paso, bloqueos).
- Actualizar el `Estado:` de los REQ que cambiaron.
- Registrar en `CHANGELOG.md` (manual si no hay commit; obligatorio si hay commit).

## 1. Qué es este proyecto

{{DESCRIPCION_PROYECTO}}

**Principio rector:** {{PRINCIPIO_RECTOR}}

## 2. Stack

| Capa | Tecnología |
|------|-----------|
| Framework | {{FRAMEWORK}} |
| Lenguaje | {{LENGUAJE}} |
| Autenticación | {{AUTENTICACION}} |
| Hosting | {{HOSTING}} |
| Repo | {{REPO_URL}} |

### Playbooks de plataforma aplicables
<!-- Lista los playbooks de convenciones que aplican a este proyecto. Los agentes
     dev/qa/auditor DEBEN leerlos. Ej: `plugins/ArnesJuan/playbooks/power-apps-dataverse.md` -->
- (ninguno / listar)

## 3. Módulos / alcance

{{TABLA_MODULOS}}

## 4. Permisos

{{MODELO_PERMISOS}}

## 5. Equipo de agentes de IA

4 subagentes especializados (en `.claude/agents/`) + la sesión principal como **coordinadora**.
Los subagentes NO se invocan entre sí; la sesión principal orquesta el bucle y el humano
aprueba cada fase.

> **La sesión coordinadora no edita el código de la app en directo.** Todo cambio de código
> —incluida la **depuración de errores**— se delega en el `desarrollador`; luego `qa-tester`
> valida y `auditor-seguridad` revisa si aplica. La coordinadora orquesta, mantiene el
> pipeline y los quality gates, y pide la aprobación humana; no parchea a mano. Es justo al
> depurar cuando aparece la tentación de "arreglar rápido" saltándose el arnés: no se hace.
>
> 🔒 **La máquina te lo recuerda; no te lo impide del todo.** El hook `guard-codigo` (plugin)
> deniega en runtime cualquier `Edit/Write/MultiEdit` sobre `codigo_app.globs` (de
> `.arnes/config.json`) que no venga del agente `desarrollador`, y también las escrituras
> **evidentes** por `Bash` (redirección `>`/`>>`, `tee`, `cp`/`mv`, `sed -i`, `dd`). La
> coordinadora y los demás subagentes reciben un rechazo con motivo. Es una **barandilla, no
> una jaula**: impide el desvío por descuido, no contiene a quien se empeñe en rodearla
> (alcance y límites reales en §13). Para cambiar qué cuenta como "código de la app", edita
> el manifiesto.

| Agente | Modelo | Responsabilidad |
|--------|--------|-----------------|
| `analista-requerimientos` | Opus | Levanta y documenta requerimientos en `requirements/` |
| `desarrollador` | Opus | Codifica los requerimientos + documentación **técnica**, dueño de `ARCHITECTURE.md` (vista de sistema e integración) |
| `qa-tester` | Sonnet | Prueba el trabajo del desarrollador, corre quality gates, escribe documentación de **usuario final** |
| `auditor-seguridad` | Opus | Revisa seguridad y gobernanza; mantiene `docs/seguridad/`; puede vetar |

Modelo asignado por dificultad y criticidad del rol; ajustable por proyecto.

> Documentación distribuida (no hay 5º agente "documentador"): cada agente documenta su
> rebanada con el contexto vivo, y el `desarrollador` consolida la vista de arquitectura en
> `ARCHITECTURE.md`. Si el proyecto crece y la consolidación pesa, se puede añadir luego un
> agente `documentador` dedicado.

## 6. Orquestación, loops de error y gates humanos

**Flujo:** analista define REQ → desarrollador codifica → qa-tester valida → auditor-seguridad revisa → REQ `completado`.

**La vía de cada cambio se elige por su EFECTO, no por su tamaño ni por la extensión del archivo.**
El flujo de arriba es el de una **capacidad nueva**. Una **reparación con diagnóstico y solución
claros** no necesita las cuatro fases, y hacerlas igual no añade protección: añade espera.

> **Esta vía sólo rige donde ESTE documento la declara, y describirla NO la declara.** Un agente
> del plugin no la ejerce por tenerla escrita en su definición, y **este texto no la autoriza por
> estar instalado**: instalar la política y aceptarla son **dos actos distintos**, y el segundo es
> **del propietario de este proyecto**. Lo que sigue lo escribe él, y sólo él:
>
> {{DECLARACION_VIA_PROPORCIONAL}}
>
> **Mientras esa línea no sea la declaración expresa, rige el procedimiento anterior** —analista →
> desarrollador → QA → seguridad— y **ningún agente puede omitir al analista**. La tabla de abajo
> describe las vías; **describirlas no las autoriza**, y su presencia no es evidencia de nada.

| Naturaleza del cambio | Vía |
|---|---|
| Documentación informativa, índices y erratas **sin cambio de obligaciones** | la coordinadora, con las comprobaciones pertinentes |
| **Reparación con causa, alcance y contrato claros** | desarrollador → QA. **Sin comisión de analista** — sólo si el propietario del proyecto lo **declaró expresamente** (la declaración afirmativa de arriba; **esta fila no es esa declaración ni la sustituye**) y el cambio **no** cae también en la fila 3 |
| Cambio cuyo efecto alcanza **un criterio de `critico` de este proyecto** (§6, «Qué es crítico EN ESTE PROYECTO») **o una protección del arnés** — ejemplos **declaradamente no exhaustivos**: hooks, protecciones, firmas, permisos, instalación, migración, publicación | desarrollador → QA → **seguridad**. El analista interviene **sólo** si queda una decisión de diseño o de contrato **pendiente** |
| **Capacidad nueva** o **cambio de contrato** | analista → desarrollador → QA → seguridad |

**Si un cambio casa con más de una fila, manda la MÁS RESTRICTIVA.** La tabla no se para en la
primera fila que encaje: la reparación de un bug de cobro tiene causa y contrato claros —fila 2— y
además toca dinero —fila 3—, y la vía que se aplica es la de la **fila 3**.

**Qué es «contrato claro», y qué pasa cuando no lo es.** «Contrato claro» no es sólo que el
criterio ya esté decidido: incluye que **`Rigor:`, `Sensible a seguridad:` y las revisiones que el
REQ exige sean coherentes con el EFECTO de la reparación**. Una reparación que toca dinero sobre un
REQ `Rigor: estandar` · `Sensible a seguridad: no` · `Seguridad: n/a` **no tiene el contrato claro**,
por decidido que esté su criterio: la cabecera promete menos revisión que la que el efecto exige.
Cuando el trabajo revela una clasificación **insuficiente o contradictoria**, la coordinadora
**solicita al `analista-requerimientos` únicamente esa decisión y su actualización documental**
—qué rigor, qué sensibilidad, qué revisiones— **antes de continuar**. **No se repite el análisis
completo y no se otorgan facultades nuevas a ningún otro rol:** ni el desarrollador ni QA corrigen
esos campos por su cuenta, y el auditor conserva la suya de subir el rigor, como siempre. Resuelta
la clasificación, la vía se aplica tal cual: una reparación ordinaria **correctamente clasificada**
sigue siendo desarrollador → QA sin analista, y una que **exige seguridad** sigue siendo
desarrollador → QA → seguridad.

**Cómo se comprueba la autorización, y hacia dónde falla.** Antes de omitir la comisión de analista
—y sólo para eso— se lee el `AGENTS.md` **del proyecto en el que se está trabajando**: ni la
definición del agente, ni este archivo recordado de otro proyecto. La pregunta es por **propiedad**:
*¿el propietario de este proyecto declaró expresamente que lo autoriza?* **Una sola forma responde
que sí, y es un acto suyo: la declaración afirmativa** —la frase «**autoriza la vía proporcional de
reparación**» dicha de este proyecto—. **Nada más es evidencia, y esto importa porque es el error
que se cometió:** ni la **tabla de vías** con su fila «Sin comisión de analista», ni la descripción
de la vía, ni este mismo párrafo. Todo eso **se instala con el andamiaje** y no lo decidió nadie
aquí; tomarlo por consentimiento es **deducir el permiso del texto que lo describe**.
**Cualquier otro desenlace conserva el procedimiento anterior y se despacha al analista**: que no
esté declarada, que sólo esté descrita, que el archivo no se pueda leer, que la respuesta no sea
clara, o que otra parte del mismo documento exija el analista para ese cambio **sin resolver
expresamente** la contradicción.
**La ausencia de la declaración no habilita nada**, y ésa es la dirección del fallo que importa: el
agente trae la **capacidad**, el documento da el **permiso**.

**La disciplina de la declaración — SEDE NORMATIVA. Se escribe aquí una vez y todo lo demás
remite:** `arnes-init` al instalar, `arnes-upgrade` al migrar, y cualquier agente al comprobar.
Nadie vuelve a redactar esta regla por su cuenta — **redactarla dos veces fue exactamente el fallo
que la trajo**.

1. **Sólo autoriza una decisión afirmativa explícita del propietario, tomada como acto completo.**
   Vale **la oración entera afirmando que este proyecto lo autoriza**, no que la frase aparezca en
   algún sitio del archivo.
2. **No son autorización, aunque contengan la frase entera:** una **negación**, una **postergación**
   («aún no…»), una **pregunta** o **decisión pendiente**, un **ejemplo**, una **cita**, la
   descripción de la vía, la tabla, este mismo apartado, y una **declaración afirmativa comentada**
   —un comentario sigue siendo texto, y una declaración apagada no es una declaración—.
3. **Quien comprueba no se queda en la coincidencia de cadena:** lee la **oración completa y su
   función**. Encontrar las palabras no es encontrar una decisión. **Una coincidencia parcial no
   vale**, y ante la duda **no se autoriza**: se despacha al analista.
4. **La unidad es la ORACIÓN, nunca la línea.** Nada de esto depende de dónde caiga un salto de
   línea, un reflujo del párrafo o un margen: una oración partida en dos líneas sigue siendo una
   oración, y dos oraciones en una línea siguen siendo dos.
5. **Las dos líneas, y no se inventa una tercera.** Para autorizar: `> **Este proyecto autoriza la
   vía proporcional de reparación** descrita en esta sección. — Declarado por <propietario>,
   <fecha>.` Para **no** autorizar, que es el valor por defecto: `> **Este proyecto todavía no ha
   declarado esa autorización.** Rige el procedimiento anterior: analista → desarrollador → QA →
   seguridad.` La negativa está redactada **a propósito** sin contener la frase afirmativa; pero
   **aunque alguien la escribiera conteniéndola** —«este proyecto **no** autoriza…»— seguiría **sin
   autorizar**, por el punto 2. La regla **no depende de la redacción que se elija**.

> **Límite declarado, y es de esta regla, no de una versión.** Esto es una **norma para quien lee**:
> **no hay comprobación mecánica** que la haga cumplir — ningún hook, ninguna prueba y ningún `grep`
> distinguen una negación de una afirmación. Un `grep` de la frase **encuentra también los casos del
> punto 2**, empezando por este mismo apartado. Quien quiera verificación automática tiene que
> construirla, y **hoy no existe**. Y no es una precaución teórica: se midieron redacciones
> **negativas** que un lector automático resolvía como afirmativas, y por eso la comprobación es de
> quien lee y no de un patrón.

**La fila 1 no levanta el control de edición de un archivo protegido.** Elegir vía decide **quién
revisa**, nunca **quién puede escribir**. Una errata sin cambio de obligaciones la corrige la
coordinadora **salvo que viva dentro de una ruta que `codigo_app.globs` (`.arnes/config.json`)
declare código de la app**: ahí `guard-codigo` **deniega la edición, y hace bien** — la puerta mira
la **ruta**, no si el cambio es documental. Ese arreglo va por el **`desarrollador`**, por la vía que
le corresponda según su efecto. Esto **no** es una excepción a la tabla: es el recordatorio de que la
tabla no autoriza saltarse un control de edición.

**La regla que impide que esta tabla se convierta en una salida: se clasifica por el EFECTO.** Una
regla de autorización escrita en Markdown es gobernanza sensible; una prueba que decide si una
protección funciona tampoco es una simple edición documental. La coordinadora clasifica y **registra
una justificación breve**; **no se abre una comisión sólo para clasificar**, y se escala únicamente
una ambigüedad concreta que pueda **reducir una protección**.

**En la vía de reparación, el desarrollador entrega el arreglo y su documentación EN LA MISMA
ENTREGA** —incluido el write-back de §9—, y **QA verifica el cambio y sus dependencias**,
reutilizando la evidencia vigente cuando se demuestre que lo posterior no la invalida, y
**registrando esa comprobación**.

**Elegir vía NUNCA elimina una revisión de seguridad que las reglas vigentes de este proyecto
exijan, y la lista de ejemplos de la fila 3 no puede limitar esa obligación.** Va enunciada por
**propiedad**: interviene seguridad cuando el **efecto** del cambio alcance algo que este
proyecto declare crítico (§6) o una protección del arnés, **o** cuando las reglas vigentes de rigor y
sensibilidad la exijan —rigor efectivo `critico`, por declaración o por el suelo que impone
`Sensible a seguridad: sí`—. **Basta una de las dos condiciones; no se exige que coincidan.** Los
ejemplos de la fila 3 son **declaradamente no exhaustivos** y no acotan la propiedad: el día que
aparezca un efecto que no esté entre ellos, la obligación sigue en pie. **Y esta obligación no
depende de la comprobación de autorización de arriba:** un proyecto que no autorice la vía tiene
**más** pasos, nunca menos.

**`guard-completado` no decide a quién se despacha, y aquí no se usa como criterio.** Es una puerta
de **cierre**: si se deja que ella lo resuelva, el trabajo llega hasta el final y **sólo entonces**
se descubre que faltaba seguridad — el bucle tardío que esta vía existe para evitar. Y §13 la
declara **inerte** sin `jq` o sin `.arnes/config.json`, de modo que en ese proyecto no calcularía
nada. La regla de despacho es la del párrafo anterior y se sostiene sola.

**Y las cuatro cosas que esta vía NO cambia, porque su ausencia sería la ambigüedad peligrosa:**

1. **El write-back de §9 sigue siendo obligatorio.** Lo que cambia es **quién puede transcribirlo**
   —el desarrollador, cuando no queda decisión de diseño ni de contrato pendiente—, **no si hay que
   hacerlo.** Un hallazgo resuelto sólo en el código o en un log **sigue siendo deriva**, y QA y
   seguridad siguen sin firmar `aprobado` antes de que el requerimiento lo refleje.
2. **El rigor no se rebaja, y elegir vía no lo toca.** El `Rigor:` y el `Sensible a seguridad:`
   **declarados en el REQ siguen vigentes tal cual**: clasificar un cambio en una vía **no**
   reclasifica el REQ. Subirlo o bajarlo **sigue su procedimiento de siempre, y esta tabla no es un
   atajo a él**: lo fija el `analista-requerimientos`, el `auditor-seguridad` **puede subirlo**,
   **nadie lo baja sin su firma**, y `Sensible a seguridad: sí` impone `critico` como **suelo**.
   Ninguna vía puede usarse para evitar un control.
   **Y si la reparación necesita un REQ NUEVO** —el único caso en que esos campos no existen aún—,
   **es el `analista-requerimientos`, y no el `desarrollador` ni el `auditor-seguridad`, quien
   define el contrato inicial, el `Rigor:` y el `Sensible a seguridad:`**, por esas mismas reglas:
   así el disparador del `auditor-seguridad`, que depende del flag, **nunca nace sin sujeto**.
   **«Hace falta un REQ nuevo» es, por sí solo, motivo de parada del `desarrollador`**: que tenga
   permiso de escritura sobre `requirements/` no lo convierte en dueño del contrato. Hecho eso,
   **se aplica la vía que corresponda SIN una segunda comisión de análisis**, salvo que aparezca una
   decisión nueva — si hiciera falta analizar dos veces, la vía no habría retirado nada. Para los REQ
   **que ya existen** no cambia nada: conservan sus clasificaciones, como dice la primera frase de
   este punto.
3. **No se omiten pruebas necesarias.** Durante el desarrollo, pruebas **enfocadas**; el banco
   completo sobre el **candidato final** y tras cualquier cambio que invalide esa evidencia. Los
   controles obligatorios de integración y publicación **se mantienen todos**.
4. **Los contadores no se reinician.** Una reparación que vuelve al mismo agente **gasta vuelta**,
   se llame como se llame, y **agotar vueltas nunca equivale a aprobar**.

**Antes de despachar una comisión que OMITE una fase, la coordinadora lo comprueba POR ESCRITO.**
Es ella quien decide el despacho, así que es ella quien comprueba el permiso. La comprobación se
suma a las que ya hace antes de cualquier encargo —qué resultado exacto debe entregar, qué queda
fuera, cuándo detenerse— y va escrita **en el propio encargo**, diciendo **qué archivo leyó y qué
resolvió**:

1. **Si el encargo omite la comisión de analista de esta vía, ¿el `AGENTS.md` DE ESTE PROYECTO la
   autoriza expresamente?** **Tenerlo escrito en la definición de un agente no lo concede, y
   tenerlo instalado en este `AGENTS.md` tampoco** — la tabla de vías y la descripción de arriba
   **llegan con el andamiaje**, así que encontrarlas no responde nada: lo único que responde es la
   **declaración afirmativa del propietario del proyecto**. Sin ella —o con el archivo ilegible, o
   con la vía sólo descrita, o con otra parte del mismo documento exigiendo el analista sin
   resolver la contradicción— **se despacha al analista**, que es el procedimiento anterior.
2. **Y si la omite por «contrato claro», ¿lo es en el sentido de esta sección** —`Rigor:`,
   `Sensible a seguridad:` y revisiones exigidas coherentes con el EFECTO—? Si no lo es, la
   dependencia que se resuelve primero es **esa decisión del analista, y sólo esa**; no se amplía
   el encargo.

**Las obligaciones de seguridad no dependen de esta comprobación:** ninguna respuesta aquí retira
una revisión que las reglas vigentes del proyecto exijan, y un proyecto que no autorice la vía
tiene **más** pasos, nunca menos.

**Tres límites de la comprobación de autorización, escritos aquí porque NO están medidos.**

1. **Un agente que el plugin no entrega no recibe la comprobación.** Si este proyecto tiene su
   propia copia de una definición de agente en `.claude/agents/`, esa copia lleva el texto que
   alguien escribió ahí y **ninguna instrucción del plugin puede gobernar un archivo que el plugin
   no entrega**. En ese caso la comprobación queda sólo en manos de la coordinadora, que sí la lee
   del apartado anterior de esta misma sección — y si la coordinadora tampoco la tiene, porque **un
   proyecto ya instalado tiene su `AGENTS.md` congelado hasta que `arnes-upgrade` migre este
   bloque**, no la hace nadie.
2. **No está demostrada la compatibilidad con definiciones de agente anteriores.** Que la
   comprobación falle hacia el procedimiento anterior es su **diseño**, no una medición sobre
   agentes viejos: nadie la ha ejercido con ellos.
3. **No se afirma que cueste cero.** Que §0 obligue a leer `AGENTS.md` **no demuestra** que un
   agente lea esta sección con la profundidad que la comprobación exige. Ese coste no se ha medido.

**El orden no es una sugerencia: es la condición de validez de la firma.** El
`auditor-seguridad` no firma `Seguridad: aprobado` sobre un árbol que el `qa-tester` no ha
validado, porque **no mira las quality gates**: su veredicto acredita la revisión de seguridad,
no que el código funcione. Firmar antes convierte una revisión parcial en un sello de calidad
que nadie emitió. Buscar paralelismo aquí no ahorra tiempo: produce una firma falsa.

> **Excepción nombrada — la auditoría preventiva.** Una revisión de seguridad hecha **antes de
> que exista el código** —sobre el diseño, el modelo de amenaza o el REQ mismo— sí puede ir por
> delante, porque no acredita nada construido. Se declara **al emitirla**, escribiendo
> `Seguridad: preventiva` en el REQ; nunca al invocarla: una excepción que se inventa
> cuando hace falta no es una excepción, es una salida. Esa firma **no** cubre el código
> posterior: cuando el código exista, la auditoría se repite en su turno.

**Despacho en paralelo: sólo lo que la máquina declara disjunto, nunca por intuición.** La
coordinadora **sólo** despacha comisiones en paralelo sobre REQ que `tools/arnes-paralelo.sh`
declare **disjuntos** por su campo `Archivos:` (forma y fail-closed en `requirements/README.md`), y
**nunca** por intuición. Un despacho paralelo sin esa comprobación es lo que produce **conflictos de
fusión y trabajo perdido**. Y el modo de fallo no es que falte paralelismo: es que se despache «a
ojo» y salga bien tres veces, porque a la cuarta el conflicto cuesta más que toda la serie que se
ahorró.

> **Necesaria y no suficiente: un `disjunto` no se toma por bueno sobre un campo decorado.** La
> instrucción de arriba no se relaja —preguntar sigue siendo obligatorio—, pero mientras el hallazgo
> **SEC-020** del propio arnés siga abierto (`contrato`, ventana 1.33.0) la herramienta puede
> responder `disjunto` con rc 0 sobre un mapa corrompido: cuando el campo `Archivos:` lleva el marcado
> de Markdown **elemento por elemento** —`` `a.sh`, `b.sh` `` o `_a.sh_, _b.sh_`— el desenvoltorio
> arranca un par de marcadores que pertenece a **dos elementos distintos** y sustituye las rutas
> declaradas por otras que no existen. De ahí las dos consecuencias operativas: las rutas del campo se
> declaran **sin decoración** (`requirements/README.md`), y un `disjunto` sobre un campo decorado no
> autoriza nada — se limpia el campo y se vuelve a preguntar. Una herramienta con un fail-open abierto
> da condición **necesaria**, no suficiente.

**Lo que NO se paraleliza, con su motivo — no es una lista suelta:**
1. **El `auditor-seguridad` nunca antes ni a la vez que el `qa-tester` sobre el mismo REQ**, porque
   su firma acreditaría un árbol sin validar: convierte una revisión parcial en un sello de calidad
   que nadie emitió. Única salida, y declarada al emitirla: `Seguridad: preventiva`.
2. **El `qa-tester` nunca antes que el `desarrollador` sobre el mismo REQ**, porque validaría un
   árbol que todavía no contiene aquello que dice validar.
3. **Dos comisiones que tocan el mismo archivo**, aunque sean de fases distintas: un conflicto de
   fusión no sabe de fases, sabe de líneas.

Las dos primeras son de **orden de fases** y no se relajan **en ningún caso**: son la condición de
validez de la firma, no una preferencia de calendario. `tools/arnes-paralelo.sh` **no las
comprueba** —responde sobre archivos, y lo dice en su propia salida—, así que un `disjunto` nunca es
permiso para saltárselas.

**Loop de error.** Empieza por lo que **NO** cambia, porque es lo que se perdería leyendo el
resto de prisa: el `qa-tester` y el `auditor-seguridad` **detectan, registran con su clase y
bloquean** lo que encuentren, y la seguridad puede **vetar** en cualquier momento; **ninguna
clasificación de la coordinadora retira, degrada ni pospone un veredicto suyo** — un
`con-hallazgos` sigue escrito y sigue impidiendo lo que impide, y sólo lo cambia quien lo firmó,
sobre lo que haya vuelto a revisar. Hecho eso: el REQ **vuelve al desarrollador cuando la
coordinadora clasifica el hallazgo como defecto que impide cumplir o entregar con seguridad el
alcance acordado**; una **dependencia necesaria para continuar** abre **sólo lo que depende de
ella**, sin ampliar el encargo; y una **mejora o defecto independiente** se **registra con
responsable** en su sede y **queda fuera** de la entrega — **registrar no autoriza reparar**, y
hacerlo «ya que estamos» es ampliación de alcance y se anota como tal.
**Y si QA o seguridad consideran que un hallazgo bloquea esta entrega y la coordinadora lo
considera independiente, eso es una discrepancia declarada y no una clasificación firme:** se
**resuelve entre ellos** con la evidencia a la vista, o se **escala al propietario** con la forma
de la regla 4; mientras no esté resuelta o escalada, la entrega **no se cierra**. Y la salida
barata queda prohibida por su nombre: **mover el hallazgo de sitio no lo resuelve** —ni sacarlo
del `Hallazgos abiertos:` del REQ, ni reasignarlo a otro REQ, a otra entrega o a otra ventana, ni
pasarlo de una sede a otra—. **La ubicación no es un veredicto.**
Máximo **{{MAX_REINTENTOS}}** vueltas dev↔QA **por REQ**, y el contador **NO se reinicia con
cada hallazgo nuevo**. Esto es deliberado: un tope por hallazgo no acota nada, porque cada
arreglo cierra el hallazgo documentado y la vuelta siguiente encuentra una variante. Un REQ
puede pasar semanas en `en-revisión` sin haber gastado nunca tres vueltas del mismo hallazgo.
**Y el contador es del defecto o de la entrega, no del envoltorio bajo el que se despacha:** una
reparación **del mismo defecto o de la misma entrega** **conserva su contador**, y tampoco se
reinicia por cambio de rol, de fase o de nombre de la comisión —tramo, ajuste, revisión acotada,
seguimiento— **ni abriendo un REQ nuevo**. Abrir un REQ **para** reiniciarlo es incumplimiento de
esta sección. *(El reverso, para que no se lea de más: partir un REQ por **alcance** no elude
ningún contador, porque no viaja ninguna reparación en curso.)*

Agotado el tope, el REQ **no se queda abierto**: o cierra con el residual **declarado**
(dueño, forzador medido y vencimiento) o pasa a `bloqueado` y se escala al humano. La
seguridad puede **vetar** en cualquier momento.

**No todo hallazgo bloquea.** Cada hallazgo abierto declara su clase en el campo
`Hallazgos abiertos:` del REQ — `usuario/dinero`, `contrato` o `instrumento` (tabla completa
en `requirements/README.md`). Sólo las dos primeras impiden cerrar. Un defecto **del propio
arnés** —un lector de umbral, un guardián, una prueba— es `instrumento` y va a deuda técnica
con dueño: atacar guardianes es valioso, pero **no puede ser condición para cerrar una
función de negocio**.

> 🔒 **Cumplido por máquina:** `guard-completado` lee `Hallazgos abiertos:` y deniega el
> cierre si alguno es `usuario/dinero` o `contrato` — y también si alguno **no declara clase**,
> porque entonces la puerta no puede saber si bloquea.

**La coordinación se orienta a entregas — seis reglas, y ésta es su sede única.** Son
obligaciones de la **sesión coordinadora**, no de los subagentes. Se verifican leyendo el
encargo, la **bitácora de comisiones** que el proyecto lleve —y si no lleva ninguna, la entrada
del `CHANGELOG.md` de esa comisión— y el REQ, y **ninguna puerta las comprueba**: son disciplina
declarada con dueño, y el dueño es la coordinadora. Su contrato completo vive en el
requerimiento del arnés que las introdujo —el que nombra la entrada del `CHANGELOG` del plugin
que las publicó—, que es donde se discuten y se cambian.
**Aquí viven una sola vez:** ningún agente, plantilla, skill ni documento copia su texto —
remiten a este bloque, porque dos transcripciones de la misma regla se desfasan, y ésta se
desfasaría hacia el lado que **abre**.

1. **Objetivo concreto, declarado en el propio encargo.** Todo encargo dice
   por escrito **qué resultado debe quedar construido y comprobado**, **qué criterios de
   aceptación le aplican** citados por su identificador, y **qué queda fuera** y **cuándo debe
   detenerse**. Documentar o revisar **es** avance cuando sirve a esa entrega y no la sustituye:
   un encargo cuyo único resultado sea texto se despacha **sólo** si ese texto **es** el resultado
   contratado.
2. **Todo bloqueo declara su alcance.** Venga de un hallazgo, de un veto, de la cola de
   aprobaciones o de una dependencia, declara **(i) qué acción impide** —nombrando **la acción
   concreta y la regla que la impide**, y clasificándola con las **cinco clases de acción** cuya
   sede única es esta regla—, **(ii) qué parte de la entrega afecta**, **(iii) qué evidencia lo
   sostiene**, citada de modo que se pueda volver a ella **sin preguntar** —archivo y línea,
   identificador del hallazgo, o la corrida con su fecha—, y **(iv) qué lo resuelve**.
   **Qué son las cinco clases y qué NO son: categorías descriptivas, no controles nuevos.**
   Nombran la acción que un bloqueo **ya existente** impide, y **no crean, no retiran y no
   modifican** ninguna puerta, permiso, aprobación ni condición de cierre: escribir una clase no
   bloquea nada por sí mismo, y no escribirla no levanta nada.
   - **implementar** — escribir o cambiar el artefacto contratado.
   - **probar** — ejecutar la validación sobre lo construido.
   - **aprobar** — **sólo** la **aprobación humana** normativa de «Gates de aprobación humana»,
     más abajo: la conceden **personas** y **ningún hook la impone**.
   - **cerrar** — **marcar el REQ como `completado`**: la transición de su campo `Estado:` al
     valor `completado`. Es la acción que `guard-completado` deniega mientras
     `PENDING_APPROVAL.md` tenga entradas bajo `## Pendientes`, y también con un hallazgo
     `usuario/dinero` o `contrato` abierto o **sin clase**, con una quality gate en rojo o con una
     firma que falte. **Esas condiciones no se redeclaran aquí:** viven en esta misma sección y en
     §13, y esta regla sólo las **cita** para poder nombrar la acción.
   - **publicar** — poner la versión en manos de alguien: el tag, la publicación y la
     actualización de la instalación estable.
   Añadir, quitar o redefinir una clase es **cambio de contrato**, no interpretación.
   **Ninguna lista de bloqueos concretos enumera todos los bloqueos posibles** —tampoco las de
   esta sección—, y lo que una lista **no** menciona **no queda por ello autorizado ni
   desbloqueado**: lo que se contrata es la **forma** —acción concreta, regla que la impide, parte
   afectada, evidencia y resolución—, no el inventario; los ejemplos son **no exhaustivos** y lo
   dicen. **Un bloqueo puede afectar a más de una acción**, y entonces las **nombra todas**: en
   particular **el veto de seguridad conserva su alcance según la regla que lo establece** —«Loop
   de error», más arriba— y puede impedir a la vez **cerrar** y **publicar**; este vocabulario lo
   **describe**, no lo acota ni lo reduce a una clase, y quien decide su extensión es su propia
   regla y quien lo firma. Un bloqueo **no se extiende solo** a trabajo independiente y **no se
   rodea** con otro REQ, una reclasificación ni un cambio de herramienta.
3. **Un hallazgo no es, por sí solo, un encargo nuevo.** **Lo primero es lo que
   NO cambia:** el `qa-tester` y el `auditor-seguridad` conservan íntegra su capacidad de
   **detectar, registrar, clasificar y bloquear**, el **veto** de seguridad sigue disponible en
   cualquier momento, y **ninguna clasificación retira, degrada ni pospone un veredicto**. Lo que
   la coordinadora decide es **qué reparación se encarga y dentro de qué entrega**: los tres
   términos de esa clasificación, la **discrepancia** que se resuelve o se escala, y el
   **contador que es del defecto o de la entrega**, están escritos en «Loop de error», más arriba,
   y **no se transcriben aquí**. Una **urgencia de seguridad no se aplaza por esta regla: se
   escala** con su efecto concreto —qué puede ocurrir, sobre qué, y qué acción impide— por la vía
   de la regla 4; «independiente» no es un sitio donde guardar una urgencia. **Y son dos ejes que
   no se renombran uno en términos del otro:** la clase del campo `Hallazgos abiertos:`
   (`usuario/dinero`, `contrato`, `instrumento`; sede única `requirements/README.md`) decide si un
   hallazgo **bloquea el cierre** de su REQ y la lee `guard-completado`; esta clasificación decide
   **si se abre trabajo ahora y dentro de qué entrega**.
4. **Las decisiones humanas se presentan temprano y con su forma.**
   Cuando una decisión del propietario **impida continuar**, se presenta **en ese momento** —no al
   cierre de la jornada— con **(i) pregunta comprensible, (ii) opciones, (iii) recomendación y
   (iv) consecuencia de cada opción**, y **agrupada** con las decisiones ya conocidas que sigan
   pendientes. Mientras la decisión no llegue se avanza **únicamente** en trabajo que cumpla las
   tres condiciones a la vez: **no depende** de ella, está **autorizado** y está **suficientemente
   definido** en el sentido de la regla 1. **Caso medido:** una pregunta encolada **de
   madrugada** dejó parado trabajo que nada impedía. Qué impide exactamente la cola, y qué no,
   está en «Mecanismo de gate», más abajo.
5. **El presupuesto es del ciclo completo, no del agente.** La misma entrega se
   sigue **a través de todos los roles**, y **cambiar de agente, de fase o de nombre no reinicia
   ningún límite**. Los contadores existentes **se conservan tal cual** —el primero, el tope de
   vueltas dev↔QA **por REQ** que fija «Loop de error», que se **cita** y **no se redeclara
   aquí**—. **Agotado el presupuesto no se aprueba por agotamiento ni se abre otra vuelta
   automáticamente:** se presenta el impedimento con la forma de la regla 2 y **las alternativas
   concretas**, que son las dos que «Loop de error» ya nombra —cerrar con el residual declarado, o
   `bloqueado` y escalar—.
6. **Avance observable después de cada comisión.** Su entrada en la **bitácora de comisiones**
   que el proyecto lleve —en la celda de notas; y si el proyecto no lleva ninguna, la entrada del
   `CHANGELOG.md` de esa comisión— dice, en **una línea**, **qué resultado se obtuvo** y **qué
   dependencia falta**; y si la comisión siguiente **no acerca directamente la entrega**, esa
   misma línea dice **por qué es necesaria**. Para esto **no** se abre ninguna columna, tablero ni
   medidor nuevo: se anota con lo que la bitácora ya tenga. Queda prohibido por su nombre
   **fabricar cambios visibles, maquetas o tareas nuevas para aparentar progreso**: un artefacto
   que ni es la entrega ni la acerca **no es avance**, y anotarlo como si lo fuera es publicar una
   **cifra sin procedencia** —una cifra dada por medida sin que se pueda volver a su corrida—
   aplicada al trabajo en vez de al número. Esa clase de defecto está definida, con sus
   instancias, en el requerimiento del arnés que introdujo estas reglas y en la sede donde el
   proyecto registre sus defectos de coordinación; aquí se **cita**, no se redefine.

**Nivel de rigor — cuánta ceremonia paga cada REQ.** No todo requerimiento merece el mismo
esfuerzo. Cada REQ declara `Rigor:` en su cabecera: `ligero` (analista + desarrollador +
quality gates), `estandar` (+ QA) o `critico` (+ auditoría de seguridad). Tabla completa en
`requirements/README.md`.

**Qué es crítico EN ESTE PROYECTO:**
{{CRITERIO_RIGOR_CRITICO}}
*(criterios genéricos que suelen aplicar: dinero · datos personales · identidad o acceso ·
documento con efecto legal · cambio irreversible de esquema o borrado. Sustitúyelos por los
ejemplos concretos de este dominio.)*

Lo fija el analista; el auditor **puede subirlo** y nadie lo baja sin su firma. `Sensible a
seguridad: sí` impone `critico` como **suelo**. Si se omite, se deriva del campo de
sensibilidad — exactamente como se juzgaba antes de que existieran los niveles.

> 🔒 **Cumplido por máquina:** `guard-completado` calcula el rigor efectivo y sólo exige
> `Seguridad: aprobado` en `critico`. Un `Rigor: ligero` escrito sobre un REQ sensible **no
> baja nada**: el suelo manda.

**Gates de aprobación humana** — las acciones siguientes esperan tu visto bueno y **no se
ejecutan** sin él. Son **aprobaciones humanas**, de la clase de acción «**aprobar**» (regla 2):
las concede una **persona** y **ningún hook las impone**. **Y es una lista de aprobaciones
humanas, no el inventario de lo que puede bloquear en este proyecto:** hay otros bloqueos —la
cola de `PENDING_APPROVAL.md`, el orden de fases, el veto de seguridad, el tope de vueltas
dev↔QA, un hallazgo con clase—, **ejemplos no exhaustivos**, y cada uno se declara con **su
acción concreta y la regla que la impide** (regla 2). Lo que no figure aquí **no queda por ello
autorizado ni desbloqueado**:
{{GATES_HUMANOS}}
(por defecto: cierre de cada fase, decisiones arquitecturales, y cambios que tocan datos/credenciales de producción).

**Mecanismo de gate:** cuando una acción requiere aprobación, el agente escribe la decisión
pendiente en `PENDING_APPROVAL.md` con la forma de la regla 4 —pregunta, opciones, recomendación
y consecuencia de cada opción—, agrupada con las que sigan pendientes. **Y lo que esa entrada
detiene va dicho con su alcance, no en absoluto:** mientras la cola tenga entradas bajo
`## Pendientes` queda impedida la acción de clase «**cerrar**» —**marcar un REQ como
`completado`**, la transición de su campo `Estado:` a ese valor—, y para **cualquier** REQ del
proyecto; **la regla que lo impide** es `guard-completado` (esta sección y §13), que este
mecanismo **no** cambia. Y sus **tres fronteras**, porque un bloqueo sin alcance se extiende
solo: **(i)** **no** impide **implementar** ni **probar**, y el trabajo que **no dependa** de la
decisión, esté **autorizado** y esté **suficientemente definido** (regla 1) **sigue permitido**;
**(ii)** **no es** ninguna de las aprobaciones humanas normativas de «Gates de aprobación
humana», más arriba —**ésas son de la clase «aprobar»**, las conceden personas, ningún hook las
impone, y **vaciar la cola no concede ninguna**—; y
**(iii)** **no absorbe** ninguna otra restricción normativa —el orden de fases, el veto de
seguridad, el tope de vueltas dev↔QA, **ejemplos no exhaustivos**—, que bloquean por su propia
regla, **declaran su propio alcance** y **no** se levantan
resolviendo la cola. Por eso la propia entrada declara **qué trabajo sigue**, o que **ninguno
sigue**, y en ese segundo caso el proyecto **espera** — que es distinto de fabricar trabajo
(regla 6). Así el bloqueo queda visible, por escrito y **con su alcance**.

> 🔒 **Vigilado por máquina:** mientras `PENDING_APPROVAL.md` tenga entradas en "## Pendientes",
> el hook `guard-completado` (plugin) deniega marcar cualquier REQ como `completado`. El avance
> no depende de que el modelo "recuerde" detenerse — con el alcance real descrito en §13.

**Gates por fase (patrón tipo SPARC):** cada fase del roadmap tiene una puerta explícita —
no se entra a la fase siguiente hasta cumplir el criterio de terminado de la actual + tu visto
bueno. Las fases no se solapan en silencio.

**Control de costo:** modelo por dificultad (arriba) + el límite de reintentos + el criterio de
terminado (evita trabajo de más). Presupuesto del proyecto: {{PRESUPUESTO}}. El músculo de
medición de tokens en runtime es opcional vía MCP (ver `.mcp.json.example`); el arnés no
depende de él.

**Observabilidad (en archivos, no en infra):** la traza del proyecto vive en archivos legibles
— `CHANGELOG.md` (qué cambió, quién, qué modelo), `docs/seguridad/registro-seguridad.md`
(hallazgos) y `docs/ESTADO.md` (dónde vamos). Esa es la observabilidad por defecto; un backend
de trazas/métricas es opcional vía MCP.

## 7. Quality Gates

Señales automáticas de verdad. El `qa-tester` las usa como fuente de verdad antes de aprobar:

{{QUALITY_GATES}}

(por defecto, para stack Node/TS: `npm run typecheck`, `npm run lint`, `npm run build`, `npm test`)

Un REQ no pasa a `completado` si alguna puerta falla.

Las **pruebas automatizadas** son parte de cada REQ: las escribe el `desarrollador` y el REQ
no pasa a `en-revisión` sin ellas. El tipo (unitarias/integración/e2e) y la cobertura mínima
se fijan por proyecto; si no se definieron, se usa el estándar del stack.

> 🔒 **Vigilado por máquina:** el hook `guard-completado` (plugin) corre las quality gates de
> `.arnes/config.json` justo antes de aceptar la transición de un REQ a `completado` y la
> **deniega** si alguna falla (alcance real en §13). Mantén la lista de gates idéntica aquí y
> en el manifiesto.

## 8. CHANGELOG — reglas

Cada entrada en `CHANGELOG.md` lleva: fecha, **Origen** (`GitHub` = commit / `Interno` = manual),
usuario, modelo de IA, agente(s) y detalle. Todo commit DEBE actualizar `CHANGELOG.md` en el
mismo commit (lo exige el hook `pre-commit`).

## 9. Cambios de requerimientos (versionado y deriva)

**PRINCIPIO:** un requerimiento NO se reescribe encima. Se **versiona** dejando rastro del
antes, el después y, sobre todo, el **PORQUÉ** (enlazado a su causa: `SEC-xxx`, un NFR, un
cambio de legislación, una limitación detectada en pruebas, un parche de dependencia, etc.).

- **Cambio MENOR** (ajusta un criterio o un detalle): edita el REQ y registra en su
  **Historial de cambios**: fecha, qué cambió (antes → después) y la causa. Añade entrada en
  `CHANGELOG.md`.
- **Cambio DE FONDO** (cambia el alcance, la decisión base o el significado del REQ): crea un
  **ADR nuevo** (contexto, qué cambió y por qué, decisión, consecuencias); el REQ se actualiza
  y **enlaza** a ese ADR. Mismo patrón que un `ADR-005` que supersede al `ADR-003`.
- **DERIVA** (el código terminó distinto de lo que dice el REQ): **no se deja en silencio**. Se
  actualiza el REQ para reflejar la realidad implementada, con su trazabilidad y causa; si el
  desvío fue de fondo, además un ADR.
- **CRITERIO MÁS ESTRECHO QUE LO CONSTRUIDO** (el código cubre **más** de lo que el criterio
  promete: tolera siete formas y el criterio nombra tres): es la otra cara de la deriva y se
  corrige **en el mismo cambio que lo descubre**, con su entrada de Historial (antes → después) y
  la causa — no se deja para un hallazgo posterior. Cómo se redacta para que no vuelva a pasar
  —propiedad en vez de lista, número declarado, coste como techo— está en `requirements/README.md`
  §«Cómo se escribe un criterio que no se desmiente», que es su **único** sitio. Ojo al reverso:
  ampliar un criterio que el código **no** cumple, para que encaje, es deriva, no corrección.
- **CAMBIOS POR HALLAZGO** (un hallazgo de QA o de seguridad obliga a cambiar comportamiento o a
  añadir un control): es la deriva más común en este arnés, porque los agentes hallan cosas por
  diseño. El hallazgo **no se cierra** hasta que el requerimiento lo refleje — un **criterio de
  aceptación** nuevo (hallazgo de QA) o un **NFR** nuevo/actualizado (hallazgo de seguridad) —,
  con la causa enlazada al hallazgo y un ADR si es de fondo. Un hallazgo resuelto solo en el
  código o en un log (`docs/qa/…`, `registro-seguridad.md`) es deriva. **Quién lo transcribe depende
  de la vía (§6):** el `analista-requerimientos` cuando queda una decisión de requisitos o de diseño,
  y el **`desarrollador`, en la misma entrega que el arreglo**, cuando no queda ninguna, sólo hay
  que reflejar en el requerimiento lo que ya estaba contratado **y este documento declara la vía
  proporcional (§6)**. **Si §6 no la declara, el write-back es del `analista-requerimientos`**, como
  antes de que la vía existiera: la ausencia de la declaración conserva el procedimiento anterior y
  **nunca deja este write-back sin dueño**. **Quien transcribe no decide**: si al
  escribirlo aparece una decisión de alcance o de significado, **para y la escala** — eso es un
  cambio DE FONDO y vuelve al analista. En todos los casos, el `qa-tester` y el `auditor-seguridad`
  no dan su veredicto `aprobado` (campos `QA:`/`Seguridad:` del REQ) hasta que existe.
- **REGLA DE ESTADO:** cuando un REQ ya `completado` cambia, vuelve a `en-progreso` o
  `en-revisión` y **re-recorre el ciclo** (dev ajusta → QA re-valida contra los criterios
  nuevos → seguridad revisa). Un cambio de requerimiento **reabre** el trabajo; no es solo
  editar texto.

## 10. Convenciones de trabajo

- Idioma de documentación y comunicación: **español**.
- No introducir abstracciones ni features fuera del alcance del REQ en curso.
- Secretos solo en variables de entorno; nunca en el código ni en el cliente.
- Al cerrar trabajo: actualizar el REQ, el CHANGELOG y, si aplica, un ADR en `docs/decisions/`.
- **ADRs (decisiones de arquitectura):** toda decisión técnica significativa se registra como
  un ADR usando la plantilla del arnés (`templates/ADR.md.tpl`). No se borran; si una decisión
  se revierte, se crea un ADR nuevo que supersede al anterior.

## 11. Entrega

El proyecto no se considera cerrado hasta generar `DELIVERY.md` (artefacto de cierre:
resumen ejecutivo, changelog consolidado, estado de docs, módulos entregados, handoff)
y obtener la aprobación del destinatario.

## 12. Mapa de carpetas

```
AGENTS.md              ← este archivo (canónico, cross-tool)
CLAUDE.md              ← importa AGENTS.md (Claude Code)
CHANGELOG.md           ← bitácora de cambios
requirements/          ← requerimientos (el contrato)
docs/
  ESTADO.md            ← tablero de continuidad
  PLAN.md              ← plan maestro
  decisions/           ← ADRs
  seguridad/           ← gobernanza-datos.md + registro-seguridad.md
  usuario/             ← documentación de usuario final
  qa/                  ← hallazgos de QA por REQ (artefacto persistente)
DELIVERY.md            ← artefacto de cierre (al entregar)
.arnes/config.json     ← manifiesto machine-readable (lo leen los hooks de enforcement)
.claude/agents/        ← definiciones de los 4 agentes (del plugin)
memory/                ← memoria/preferencias (no versionar secretos)
```

## 13. Enforcement por runtime (hooks del plugin)

Las invariantes de este documento que no se quedan en la prosa las vigila la máquina, vía hooks
`PreToolUse` del plugin, que leen `.arnes/config.json`.

| Invariante | Sección | Hook | Herramientas cubiertas |
|------------|---------|------|------------------------|
| La coordinadora no edita código de la app (sólo el `desarrollador`) | §5 | `guard-codigo` | `Edit`/`Write`/`MultiEdit` + `Bash` (parcial) |
| No completar un REQ con aprobaciones pendientes | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| No completar un REQ con quality gates en rojo | §7 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| No completar con un hallazgo `usuario/dinero` o `contrato` abierto —ni con uno **sin clase** | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| El rigor se puede subir, nunca bajar: `Sensible a seguridad: sí` impone `critico` | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| No completar sin `QA: aprobado` (salvo `Rigor: ligero`), ni un REQ `critico` sin `Seguridad: aprobado` | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| La transición a `completado` no se hace por shell | §6 | `guard-completado` | `Bash` (parcial) |
| Seguridad no firma lo que QA no ha validado (salvo `Seguridad: preventiva`) | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Los campos del REQ valen sólo en la cabecera: una línea igual dentro de una sección no es un veredicto | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Lo que vive dentro de un `<!-- … -->` de la cabecera **no declara campo**; un rango que abre y no cierra en la cabecera no la deja medir y no deja cerrar | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Una línea de la cabecera con un **retorno de carro que no es el que la termina** no se puede medir y no deja cerrar — se deniega por eso, citando la línea, aunque los veredictos estén en verde. El CR **final** es transporte (CRLF decide igual que LF), el cuerpo no se toca y **reabrir** no se bloquea | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Un veredicto lleva fecha y no es anterior al último cambio del código —si el proyecto lo pide (`veredictos.*`, apagado por defecto) | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Ningún agente —tampoco la coordinadora— ejecuta git destructivo: `clean -f`, `reset --hard`, `checkout .`, `restore .`, `stash` (`git.prohibidos`) | §10 | `guard-git` | `Bash` |

**Un hook que avisa sin decidir.** Al escribir `QA:` o `Seguridad:` con un valor fuera del
vocabulario (`pendiente` \| `aprobado` \| `con-hallazgos`; y en seguridad además `n/a`,
`preventiva`, `vetado`), el arnés lo dice **en ese momento** con un mensaje a la persona y
**no deniega** la edición: ese REQ no podrá cerrarse y, sin el aviso, nadie lo sabría hasta
el cierre. Un matiz va entre paréntesis (`aprobado (R-045, 2026-09-01)`); un veredicto
distinto es **otro valor**, no un paréntesis. Es la única vía documentada para avisar sin
bloquear: `ask` detendría la llamada.

**Las celdas de veredicto del bloque derivado salen recortadas a 40 caracteres.** Es
presentación: la puerta y `tools/arnes-lectura.sh` leen el valor entero. Un bloque de
continuidad en el que cuatro veredictos largos ocupan un tercio —y rompen la tabla— deja
de servir para lo único que existe.

**La invariante manda sobre cualquier preferencia de herramienta.** Si una preferencia de sesión
—una instrucción de estilo, una costumbre, un ajuste de configuración— empuja a hacer por la
**consola** lo que las herramientas de edición hacen, esa preferencia **cede**: las puertas de
este documento están cableadas a `Edit`/`Write`/`MultiEdit`, y sobre `Bash` la cobertura es
**parcial a propósito** (arriba). Preferir la consola no es una opinión sobre estilo: **apaga
una puerta**. Y nace medido —una preferencia por la consola desactivó un guardián sin que nadie
relacionara las dos cosas—, así que va escrito aquí y no en la cabeza de nadie:
**quien configura una sesión no suele ser quien lee esta sección**. Regla operativa: para tocar un
archivo que alguna invariante protege se usan las herramientas de edición; si hace falta la
consola, se dice **por qué** y se asume que ninguna puerta lo va a medir.

**Es una barandilla, no una jaula.** El hook impide que el modelo **se desvíe por descuido**;
no contiene a un agente decidido a rodearlo. Concretamente:

- **Todo comando Bash pasa por el guardián, aunque sea un `ls`.** 1.25.0 intentó filtrar con `if` para
  ahorrar el proceso, y `if` no ve redirecciones: `echo x > archivo` rodeó las dos puertas hasta 1.27.0.
  Una puerta lenta protege; una que no se invoca, no. El coste se acepta.
- **`Bash` sólo está cubierto en parte, y las dos puertas comparten esa cobertura.** Ambos
  guardianes usan el mismo detector de escrituras (redirección `>`/`>>`, `tee`, `cp`, `mv`,
  `install`, `sed -i`, `perl -i`, `dd of=`). Quedan fuera, **a propósito**, los scripts, **los
  intérpretes** —`node script.mjs`, `python x.py`: la ruta vive dentro del archivo y el
  detector sólo lee el texto del comando; es el agujero más grande de los que quedan—, los
  heredocs indirectos, los formateadores que reescriben archivos (`prettier --write`,
  `eslint --fix`), `patch`/`git apply` y cualquier programa que escriba por su cuenta. Un hook
  no puede analizar shell arbitrario de forma fiable, y perseguirlo produce falsos positivos
  que acaban con alguien desactivando el guard: un guard apagado protege menos que uno parcial.
- **`guard-completado` sí mira `Bash`, pero no lo juzga: lo DERIVA.** Un comando que escribe en
  `requirements/` y menciona el estado terminal se deniega pidiendo que la transición se haga
  con `Edit`/`Write`, que es donde el hook puede ver el contenido resultante y evaluar
  veredictos, cola y quality gates. Reimplementar esas puertas para la shell sería una segunda
  transcripción de la misma regla, y dos transcripciones se desfasan.
  Dentro de esa vía la detección del estado terminal es **deliberadamente ancha** —lo busca en
  cualquier parte del comando, no como `estado:` seguido del valor—, porque la forma más natural
  de cerrar un REQ por shell sustituye el **valor** y no escribe nunca la palabra «Estado».
  **Y ancha no es infalible.** Esa detección lee el **texto crudo del comando**, así que la palabra
  del estado terminal puede escribirse partida entre expansiones —dentro de un heredoc sin citar—
  y la comprobación no la ve; el archivo queda escrito. Ensanchar el patrón cubriría esa forma
  concreta y **no la clase**: una variable, un `printf`, un `base64 -d` o un intérprete la
  reproducen. La respuesta no es un patrón más largo sino una **puerta posterior**, que deja de
  preguntar antes si un comando escribe y pregunta después si algo protegido cambió. Hasta que
  exista, esta vía es exactamente lo que dice ser: una **barandilla contra el descuido**, no contra
  la ofuscación deliberada. Escríbelo así en tu propio `AGENTS.md`: una promesa más fuerte que la
  que la máquina cumple es peor que ninguna, porque se confía en ella.

**Otro que tampoco decide: la rotación.** Un artefacto de bitácora —`CHANGELOG.md`, el registro
de seguridad— crece sin tope, y todo lo que crece sin tope acaba entrando entero en la ventana
de contexto. Con `rotacion.activo: true`, al parar un agente el arnés **mueve** las secciones
sobrantes a `<nombre>-archivo.md` y deja un puntero. **Mueve; no resume** — un resumen
convertiría la bitácora en la versión que el modelo recuerda de ella. Viene apagada.
También puede archivar **una sección** de un documento —típicamente la historia de un
REQ— a `historial/<nombre>.md`, dejando **el resto intacto**: la cabecera con sus
veredictos y los criterios de aceptación no se tocan nunca, porque son el contrato. Qué
sección es historia lo declara este proyecto en `rotacion.artefactos` (`glob` +
`seccion`); el arnés no trae ninguna por defecto.

**Un hook que no decide nada: la continuidad.** Al parar un agente (`Stop` / `SubagentStop`),
el arnés reescribe en `docs/ESTADO.md`, entre marcadores, un bloque **derivado** del disco:
estado y veredictos de cada REQ, cola de aprobaciones, rama y limpieza del árbol. No permite ni
impide nada — existe porque **un resumen redactado por el modelo miente justo cuando más falta
hace**, que es cuando le queda poco contexto. Por eso no se redacta: se deriva, y cada línea
sale de leer un archivo. Nunca bloquea la parada y se apaga con
`estado_derivado.activo: false`. **Y sobre el texto que hay fuera de los marcadores, las dos
mitades — porque una se afirmó sin condición y estaba medida falsa.** *Sí:* fuera de los
marcadores no se modifica nada; si eso no se puede **leer** no se escribe nada y se avisa; y
cada parada publica por un temporal **propio de su proceso** y lo mueve encima, así que dos
paradas simultáneas no comparten archivo (hasta 1.32.0 el temporal tenía **nombre fijo** y por
ahí se perdió texto humano **1 de 25** vueltas del banco; cerrado en 1.32.1, REQ-015). *No:*
no hay **serialización ni orden** — con dos paradas a la vez gana la última que publica, y es
conforme porque el bloque es derivado del mismo disco; y si al proceso lo **matan** sin darle
salida, su temporal puede sobrevivir hasta la parada siguiente, que lo retira.

La consecuencia práctica: el enforcement por runtime es la última red, no la primera. La regla
sigue siendo la de §5, y saltársela por otra vía es un incumplimiento aunque ningún hook grite.

**Anti-deriva — el techo honesto:** la máquina puede impedir que un REQ se cierre con la
validación/auditoría pendientes (campos `QA:`/`Seguridad:`), pero **no** puede verificar que el
requerimiento describa *semánticamente* lo construido. Esa reconciliación es responsabilidad del
write-back (§9) y se verifica al cierre: `/arnes-close` comprueba la **trazabilidad y no-deriva**
de cada REQ `completado` antes de generar `DELIVERY.md`.

Si `.arnes/config.json` no existe, los hooks son **inertes** (no estorban). Requieren `jq`;
sin él, el enforcement queda inactivo con aviso (no bloquea). El changelog sigue cubierto por
el hook `pre-commit` de git (§8).

**Nombre del agente en el manifiesto:** basta el nombre corto (`desarrollador`). El hook tolera
el prefijo del plugin que Claude Code añade en runtime (`arnes-juan:desarrollador`), así que no
hay que escribirlo. Escribirlo es opcional y hace la comparación **estricta**: `agentes.agente_codigo`
con prefijo sólo acepta a ese proveedor, útil si conviven dos plugins con un agente homónimo.
