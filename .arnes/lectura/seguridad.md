<!-- DERIVADO — no editar a mano: lo genera tools/arnes-lectura-rol.sh y se pisa en la siguiente generación. -->
<!-- Rol: seguridad -->
<!-- Fuentes: AGENTS.md 78476 B sha256 11782afbe89233c7d2b5333b731225036c42352c6eed3689cb5b3b14616701a0; requirements/README.md 78590 B sha256 7fa50448e2440b99bc87943991d9334d97e8801645a2bdee4f0d28233b97207a -->

[[A-00 · obliga: todos]]

> Archivo canónico de contexto y reglas del proyecto (estándar AGENTS.md, leído por
> Claude Code, Codex, Cursor y otros). Cualquier IA que abra el proyecto lo lee primero.
> Para Claude Code, `CLAUDE.md` **no** importa este archivo —importarlo lo cargaría entero en todo
> agente—: lleva la instrucción «lee AGENTS.md según tu rol, por sus marcas; la coordinadora lo lee
> entero al empezar», y cada agente lo lee por sus marcas, como sigue.
>
> **Lectura por destinatario.** Cada bloque empieza con una marca `[[<id> · obliga: <roles>]]` y
> llega hasta la marca siguiente. Los roles son `coordinadora`, `analista`, `desarrollador`, `qa`
> y `seguridad`; `todos` los nombra a los cinco. Cada agente lee al empezar los bloques cuya marca
> lo nombra o dice `todos` —su definición los lista, y la marca manda si la lista se queda atrás—,
> y la coordinadora los lee **todos**. **Ante la duda, se lee:** un bloque cuyo obligado no está
> claro lo leen todos. Un bloque marcado `explicativo` no obliga a nadie: se consulta cuando hace
> falta el porqué. La marca decide **quién lee**, nunca **qué rige**: ninguna regla deja de
> obligar a quien obliga por no estar en su lista. Para localizarlos: buscar `^\[\[` con número de
> línea y leer cada bloque desde su marca hasta la siguiente.

---

[[A-0 · obliga: todos]]

## 0. Ritual de inicio y cierre de sesión (leer primero)

**Al iniciar una sesión**, todo agente se orienta leyendo, en orden:
1. `AGENTS.md` (este archivo) — contexto y reglas.
2. `docs/ESTADO.md` — dónde quedamos y cuál es el próximo paso concreto.
3. `requirements/README.md` — qué está pendiente.

**Al cerrar trabajo**, el agente activo debe:
- Actualizar `docs/ESTADO.md` (fase, en progreso, próximo paso, bloqueos).
- Actualizar el `Estado:` de los REQ que cambiaron.
- Registrar en `CHANGELOG.md` (manual si no hay commit; obligatorio si hay commit).

[[A-1 · obliga: todos]]

## 1. Qué es este proyecto

Plugin de Claude Code: un arnés de cuatro agentes (analista, desarrollador, QA, auditor de seguridad) con enforcement por hooks (`PreToolUse`, `Stop`), quality gates, trazabilidad y continuidad derivada del disco. Lo usan proyectos reales; sus informes de defectos llegan por canal privado y este repositorio, que es público, describe el arnés y nunca los hallazgos de un cliente.

**Este repositorio se desarrolla a sí mismo (autoalojamiento controlado).** La versión estable instalada del plugin —la que corre los hooks de esta sesión— gobierna el desarrollo de la siguiente. La versión que se está modificando nunca es su propio guardián durante esa misma ejecución. El procedimiento completo vive en `docs/gobernanza/autoalojamiento.md`.

**Principio rector:** el arnés trae el mecanismo, nunca el mapeo; una puerta que no puede medir no deja pasar; y la versión N gobierna el desarrollo de N+1.

## 2. Stack

| Capa | Tecnología |
|------|-----------|
| Framework | Plugin de Claude Code (hooks, agentes, skills, plantillas) |
| Lenguaje | Bash (sin procesos donde se pueda: cada fork cuesta 1,2–6 s en Windows/MSYS), jq, awk; PowerShell sólo en pruebas de integración |
| Autenticación | n/a — no hay usuarios finales. `gh` con dos cuentas: `jvega-habitat` (push, sin admin) y `JJOVEGA` (dueño; rulesets) |
| Hosting | GitHub `JJOVEGA/ArnesJuan` (público) · marketplace del plugin (`.claude-plugin/marketplace.json`) |
| Repo | https://github.com/JJOVEGA/ArnesJuan |

### Playbooks de plataforma aplicables
<!-- Lista los playbooks de convenciones que aplican a este proyecto. Los agentes
     dev/qa/auditor DEBEN leerlos. Ej: `plugins/ArnesJuan/playbooks/power-apps-dataverse.md` -->
- (ninguno / listar)

## 3. Módulos / alcance

| Módulo | Qué es | Quién lo edita |
|---|---|---|
| `hooks/` | El mecanismo: `guard.sh` (PreToolUse: identidad, cierre), `stop.sh` (continuidad, rotación), `lib.sh` | **Sólo el `desarrollador`** (`codigo_app.globs`) |
| `tools/` | Informes que leen con el mismo lector que los hooks (`arnes-lectura.sh`) | **Sólo el `desarrollador`** |
| `.github/workflows/` | CI: bits de ejecución + banco completo en Linux; puerta requerida de `main` | **Sólo el `desarrollador`** |
| `tests/escenarios/hooks/run.sh` | El banco: 23+ secciones, casos deny/allow, canario, cuadre | `desarrollador` y `qa-tester` |
| `templates/`, `skills/`, `agents/`, `playbooks/` | Andamiaje que `arnes-init`/`arnes-upgrade` llevan a los proyectos | Cualquier agente; documentación técnica del `desarrollador` |
| `docs/` | Gobernanza, experimentos, pendientes, seguridad, QA | Coordinadora y agentes según su rebanada |
| `.claude-plugin/` | Versión del plugin y marketplace | `desarrollador` en el commit de versión |

## 4. Permisos

- Repositorio **público**: describe el arnés, nunca los hallazgos de un cliente. Los documentos `mejoras-arnes-*.md` e `insumos/` están en `.gitignore` y no se citan literalmente.
- `main` protegido por el ruleset `proteger-main`: **todo por PR**, sin push directo, con el check `hooks-en-linux` **requerido y estricto**.
- La fusión a `main`, el tag de versión y la publicación son decisiones **humanas**, **delegadas** a la coordinadora por el propietario (2026-09-05) cuando todo está en verde; cualquier rojo o hallazgo abierto las devuelve al humano (§6 y `docs/gobernanza/autoalojamiento.md`). La instalación estable se actualiza después de publicar y verificar.
- El manifiesto `.arnes/config.json` de este repo es el mapeo del arnés sobre sí mismo: `hooks/`, `tools/` y `.github/` son código protegido.

[[A-5.1 · obliga: todos]]

## 5. Equipo de agentes de IA

4 subagentes especializados (en `.claude/agents/`) + la sesión principal como **coordinadora**.
Los subagentes NO se invocan entre sí; la sesión principal orquesta el bucle y el humano
aprueba cada fase.

[[A-5.3 · obliga: todos]]

| Agente | Modelo | Responsabilidad |
|--------|--------|-----------------|
| `analista-requerimientos` | Sonnet | Levanta y documenta requerimientos en `requirements/` |
| `desarrollador` | Sonnet; Opus en `critico` | Codifica los requerimientos + documentación **técnica**, dueño de `ARCHITECTURE.md` (vista de sistema e integración) |
| `qa-tester` | Sonnet; Opus en `critico` | Prueba el trabajo del desarrollador, corre quality gates, escribe documentación de **usuario final** |
| `auditor-seguridad` | Opus | Revisa seguridad y gobernanza; mantiene `docs/seguridad/`; puede vetar |

Modelo asignado por dificultad y criticidad del rol; ajustable por proyecto.

> 🔒 **Modelo por rol (decisión del propietario, P-137-R, 2026-10-21).** Analista en Sonnet siempre;
> desarrollador y QA en Sonnet en `ligero` y `estandar` y en Opus en `critico`; seguridad en Opus.
> La cabecera `model:` de un agente declara un solo valor —el de defecto: Sonnet en analista,
> desarrollador y QA; Opus en seguridad—, así que quien despacha pasa `model` a la herramienta
> `Agent`, que tiene precedencia sobre la cabecera, y sube a Opus en `critico`. **En este
> repositorio todo REQ es `critico`** por la política de autoalojamiento (§6): desarrollador, QA y
> seguridad corren en Opus, y el analista en Sonnet. **Y no depende del rigor:** en este repositorio
> el desarrollador y QA se despachan siempre con `model: opus` explícito, sea cual sea el rigor y
> aunque el encargo no tenga REQ (P-137-T, 2026-10-21).

> Documentación distribuida (no hay 5º agente "documentador"): cada agente documenta su
> rebanada con el contexto vivo, y el `desarrollador` consolida la vista de arquitectura en
> `ARCHITECTURE.md`. Si el proyecto crece y la consolidación pesa, se puede añadir luego un
> agente `documentador` dedicado.

[[A-6.1 · obliga: todos]]

## 6. Orquestación, loops de error y gates humanos

**Flujo:** analista define REQ → desarrollador codifica → qa-tester valida → auditor-seguridad revisa → REQ `completado`.

> 🔒 **Política de autoalojamiento (sólo este repositorio; no se propaga a las plantillas).** Para el
> desarrollo de ArnesJuan, **todo REQ pasa por analista, desarrollador, QA y auditor de seguridad
> antes de llegar a la aprobación humana**, en ese orden. Todo REQ se declara por defecto
> `Rigor: critico` y `Sensible a seguridad: sí`, con `QA: pendiente` y `Seguridad: pendiente` al
> nacer: cualquier cambio puede alterar el mecanismo que controla a los demás proyectos. Una
> excepción editorial —una errata, un texto sin efecto en la máquina ni en lo que los proyectos
> heredan— sólo puede bajar ese nivel con **autorización expresa del propietario (Juan)**, nunca
> por reclasificación automática de un agente. El coordinador reúne la evidencia y, **con todo en verde** (CI sin FAIL, SKIP explicados,
> fail-before/pass-after, QA y auditor aprobados), **fusiona, etiqueta y publica por delegación
> permanente del propietario (2026-09-05)**; cualquier rojo o hallazgo abierto devuelve la decisión a Juan. Procedimiento completo en `docs/gobernanza/autoalojamiento.md`.

[[A-6.2 · obliga: todos]]

**La vía de cada cambio se elige por su EFECTO, no por su tamaño ni por la extensión del archivo.**
El flujo de arriba es el de una **capacidad nueva**. Una **reparación con diagnóstico y solución
claros** no necesita las cuatro fases, y hacerlas igual no añade protección: añade espera.

> **Esta vía sólo rige donde ESTE documento la declara, y describirla NO la declara.** Un agente
> del plugin no la ejerce por tenerla escrita en su definición, y **este texto no la autoriza por
> estar instalado**: instalar la política y aceptarla son **dos actos distintos**, y el segundo es
> **del propietario de este proyecto**. Lo que sigue lo escribe él, y sólo él:
>
> **Este proyecto todavía no ha declarado esa autorización.** Rige el procedimiento anterior: analista → desarrollador → QA → seguridad.
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

[[A-6.4 · obliga: coordinadora, desarrollador, qa, seguridad]]

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

[[A-6.6 · obliga: todos]]

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
   se llame como se llame, y **agotar vueltas nunca equivale a aprobar**
   (y tampoco se reinicia por cambiar de agente, de fase, de nombre o de REQ: regla 5, más abajo).

[[A-6.8 · obliga: coordinadora, qa, seguridad]]

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

[[A-6.10 · obliga: todos]]

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
Máximo **3** vueltas dev↔QA **por REQ**, y el contador **NO se reinicia con
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

[[A-6.11 · obliga: coordinadora, desarrollador, qa, seguridad]]

**No todo hallazgo bloquea.** Cada hallazgo abierto declara su clase en el campo
`Hallazgos abiertos:` del REQ — `usuario/dinero`, `contrato` o `instrumento` (tabla completa
en `requirements/README.md`). Sólo las dos primeras impiden cerrar. Un defecto **del propio
arnés** —un lector de umbral, un guardián, una prueba— es `instrumento` y va a deuda técnica
con dueño: atacar guardianes es valioso, pero **no puede ser condición para cerrar una
función de negocio**.

> 🔒 **Cumplido por máquina:** `guard-completado` lee `Hallazgos abiertos:` y deniega el
> cierre si alguno es `usuario/dinero` o `contrato` — y también si alguno **no declara clase**,
> porque entonces la puerta no puede saber si bloquea.

[[A-6.13 · obliga: coordinadora, desarrollador, qa, seguridad]]

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

[[A-6.15 · obliga: todos]]

**Nivel de rigor — cuánta ceremonia paga cada REQ.** No todo requerimiento merece el mismo
esfuerzo. Cada REQ declara `Rigor:` en su cabecera: `ligero` (analista + desarrollador +
quality gates), `estandar` (+ QA) o `critico` (+ auditoría de seguridad). Tabla completa en
`requirements/README.md`.

**Qué es crítico EN ESTE PROYECTO:**
- **Crítico:** todo cambio en `hooks/`, en `tools/` que compartan lector con los hooks, en `hooks.json`, en el banco que los certifica (`tests/`), en el workflow de CI o en el ruleset. Son el mecanismo que gobierna a otros proyectos: un fallo en abierto aquí es un fallo en abierto en todos ellos, y en silencio.
- **Estándar:** plantillas, skills, agentes, playbooks y documentación que los proyectos heredan por `arnes-upgrade`.
- **Ligero:** redacción sin efecto en la máquina ni en lo que los proyectos heredan (README, CHANGELOG, docs de gobernanza).
*(criterios genéricos que suelen aplicar: dinero · datos personales · identidad o acceso ·
documento con efecto legal · cambio irreversible de esquema o borrado. Sustitúyelos por los
ejemplos concretos de este dominio.)*

Lo fija el analista; el auditor **puede subirlo** y nadie lo baja sin su firma. `Sensible a
seguridad: sí` impone `critico` como **suelo**. Si se omite, se deriva del campo de
sensibilidad — exactamente como se juzgaba antes de que existieran los niveles.

> 🔒 **Cumplido por máquina:** `guard-completado` calcula el rigor efectivo y sólo exige
> `Seguridad: aprobado` en `critico`. Un `Rigor: ligero` escrito sobre un REQ sensible **no
> baja nada**: el suelo manda.

[[A-6.16 · obliga: todos]]

**Gates de aprobación humana** — las acciones siguientes esperan tu visto bueno y **no se
ejecutan** sin él. Son **aprobaciones humanas**, de la clase de acción «**aprobar**» (regla 2):
las concede una **persona** y **ningún hook las impone**. **Y es una lista de aprobaciones
humanas, no el inventario de lo que puede bloquear en este proyecto:** hay otros bloqueos —la
cola de `PENDING_APPROVAL.md`, el orden de fases, el veto de seguridad, el tope de vueltas
dev↔QA, un hallazgo con clase—, **ejemplos no exhaustivos**, y cada uno se declara con **su
acción concreta y la regla que la impide** (regla 2). Lo que no figure aquí **no queda por ello
autorizado ni desbloqueado**:
- fusionar cualquier PR a `main` (siempre humano, aunque el CI esté en verde);
- publicar una versión (tag `vX.Y.Z`) y actualizar la instalación estable del plugin;
- cambiar el ruleset, el workflow de CI o el manifiesto `.arnes/config.json` de este repo;
- cualquier cambio en `hooks/` (el mecanismo): se trata como crítico por definición.
(por defecto: cierre de cada fase, decisiones arquitecturales, y cambios que tocan datos/credenciales de producción).

[[A-6.17 · obliga: coordinadora, desarrollador, qa, seguridad]]

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

[[A-6.19 · obliga: todos]]

**Observabilidad (en archivos, no en infra):** la traza del proyecto vive en archivos legibles
— `CHANGELOG.md` (qué cambió, quién, qué modelo), `docs/seguridad/registro-seguridad.md`
(hallazgos) y `docs/ESTADO.md` (dónde vamos). Esa es la observabilidad por defecto; un backend
de trazas/métricas es opcional vía MCP.

[[A-7 · obliga: coordinadora, desarrollador, qa, seguridad]]

## 7. Quality Gates

Señales automáticas de verdad. El `qa-tester` las usa como fuente de verdad antes de aprobar:

- `for f in hooks/*.sh tools/*.sh; do bash -n "$f" || exit 1; done` — sintaxis de todo el mecanismo.
- `jq -e . hooks/hooks.json >/dev/null` — el registro de hooks es JSON válido.
- `jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null` — versión y marketplace válidos.
- **El banco completo (`tests/escenarios/hooks/run.sh`) corre en CI, no como gate del hook:** en Windows dura ~30 min y un hook `PreToolUse` muere a los 60 s, y un hook muerto no deniega. En Linux dura segundos y es la puerta requerida de `main` (`hooks-en-linux`). Antes de pedir la fusión, el banco tiene que estar en verde en CI y correrse entero al menos una vez en la plataforma del desarrollador.

(por defecto, para stack Node/TS: `npm run typecheck`, `npm run lint`, `npm run build`, `npm test`)

Un REQ no pasa a `completado` si alguna puerta falla.

Las **pruebas automatizadas** son parte de cada REQ: las escribe el `desarrollador` y el REQ
no pasa a `en-revisión` sin ellas. El tipo (unitarias/integración/e2e) y la cobertura mínima
se fijan por proyecto; si no se definieron, se usa el estándar del stack.

> 🔒 **Vigilado por máquina:** el hook `guard-completado` (plugin) corre las quality gates de
> `.arnes/config.json` justo antes de aceptar la transición de un REQ a `completado` y la
> **deniega** si alguna falla (alcance real en §13). Mantén la lista de gates idéntica aquí y
> en el manifiesto.

[[A-8 · obliga: todos]]

## 8. CHANGELOG — reglas

Cada entrada en `CHANGELOG.md` lleva: fecha, **Origen** (`GitHub` = commit / `Interno` = manual),
usuario, modelo de IA, agente(s) y detalle. Todo commit DEBE actualizar `CHANGELOG.md` en el
mismo commit (lo exige el hook `pre-commit`).

[[A-9 · obliga: todos]]

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
  **nunca deja este write-back sin dueño**. **En ESTE repositorio §6 NO la declara**, así que hoy
  el write-back es del `analista-requerimientos`. **Quien transcribe no decide**: si al
  escribirlo aparece una decisión de alcance o de significado, **para y la escala** — eso es un
  cambio DE FONDO y vuelve al analista. En todos los casos, el `qa-tester` y el `auditor-seguridad`
  no dan su veredicto `aprobado` (campos `QA:`/`Seguridad:` del REQ) hasta que existe.
- **REGLA DE ESTADO:** cuando un REQ ya `completado` cambia, vuelve a `en-progreso` o
  `en-revisión` y **re-recorre el ciclo** (dev ajusta → QA re-valida contra los criterios
  nuevos → seguridad revisa). Un cambio de requerimiento **reabre** el trabajo; no es solo
  editar texto.

[[A-10 · obliga: todos]]

## 10. Convenciones de trabajo

- Idioma de documentación y comunicación: **español**.
- No introducir abstracciones ni features fuera del alcance del REQ en curso.
- Secretos solo en variables de entorno; nunca en el código ni en el cliente.
- Al cerrar trabajo: actualizar el REQ, el CHANGELOG y, si aplica, un ADR en `docs/decisions/`.
- **ADRs (decisiones de arquitectura):** toda decisión técnica significativa se registra como
  un ADR usando la plantilla del arnés (`templates/ADR.md.tpl`). No se borran; si una decisión
  se revierte, se crea un ADR nuevo que supersede al anterior.

[[A-12 · obliga: todos]]

## 12. Mapa de carpetas

```
AGENTS.md              ← este archivo (canónico, cross-tool)
CLAUDE.md              ← no importa AGENTS.md: manda leerlo por marcas (Claude Code)
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

[[A-13.1 · obliga: coordinadora, desarrollador, qa, seguridad]]

## 13. Enforcement por runtime (hooks del plugin)

Las invariantes de este documento que no se quedan en la prosa las vigila la máquina, vía hooks
`PreToolUse` del plugin, que leen `.arnes/config.json`.

| Invariante | Sección | Hook | Herramientas cubiertas |
|------------|---------|------|------------------------|
| La coordinadora no edita código de la app (sólo el `desarrollador`) | §5 | `guard-codigo` | `Edit`/`Write`/`MultiEdit` + `Bash` (parcial) |
| No completar un REQ con aprobaciones pendientes | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| No completar un REQ con quality gates en rojo. **Lo que esta fila no cubre en 1.36.0, límites declarados, ni aceptados ni reparados** —ejemplos **no exhaustivos**—: una gate que **lee su entrada estándar** se come la lista de las gates siguientes, que no se ejecutan (SEC-133); y una **función importada** del entorno con el nombre de la orden de una gate hace pasar esa gate aunque esté en rojo (SEC-131 (a), que también declara la fila del entorno heredado). **Consecuencia:** en esas formas el cierre puede salir **sin decisión** con una gate en rojo —una posterior a la que lee la entrada, o la propia gate suplantada—, y salir sin decisión no deniega. Preexistentes, iguales en v1.35.0; su resolución es de 1.37 (fichas F-136-23 y F-136-21; norma única: REQ-007 CA-68, «Límites declarados de 1.36.0», del repositorio del arnés) | §7 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| No completar con un hallazgo `usuario/dinero` o `contrato` abierto —ni con uno **sin clase**, ni con una lista que la puerta **no puede interpretar**, ni con el campo **repetido** en la cabecera, ni con el campo **por encima de su techo** de tamaño, que se mide antes de normalizar—. **Aparte de la regla, sus límites:** en 1.36.0 la denegación de esta fila **llega al cliente** —el motivo viaja por la entrada estándar de `jq`, nunca como argumento, acotado a 16 384 bytes— y un juicio que no termina a tiempo deniega por el plazo propio del hook: SEC-118 y SEC-115 están **`mitigado`**, con sus residuales (cláusula 1, abajo). **Residual propio de esta fila, límite declarado y sin reparar:** con miles de líneas `Hallazgos abiertos:` repetidas en la cabecera **en disco**, el juicio crece más que linealmente y puede pasar de los 40 s o quedarse sin decisión (SEC-132 (b); medido en Linux/WSL2, una corrida por punto: 20 000 líneas cortas, `deny` a los 48,5 s; 20 000 de 66 caracteres, sin decisión a los 60 s). *(Hasta 1.35.0 esta fila declaraba SEC-115 y SEC-118 como limitaciones sin reparar, con lo medido entonces: la denegación por tamaño, hasta 255 371 bytes; y, con el motivo en un argumento cuyo límite es de bytes, con líneas ASCII de 60 caracteres o más 1 601 deniegan y 1 801 salen sin decisión, con ASCII cortas 2 501 y 3 000, y con multibyte salen sin decisión 1 601 con `ñ`, 1 001 con caracteres de 4 bytes y 2 501 cortas con `ñ`. Es historia de 1.35.0, no un límite de 1.36.0.)* (sintaxis, techo, repetición, sus límites y lo que la puerta no lee: `requirements/README.md` § «Clases de hallazgo») | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| El rigor se puede subir, nunca bajar: `Sensible a seguridad: sí` impone `critico` | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| No completar sin `QA: aprobado` (salvo `Rigor: ligero`), ni un REQ `critico` sin `Seguridad: aprobado` | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| La transición a `completado` no se hace por shell | §6 | `guard-completado` | `Bash` (parcial) |
| Seguridad no firma lo que QA no ha validado (salvo `Seguridad: preventiva`) | §6 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Los campos del REQ valen sólo en la cabecera: una línea igual dentro de una sección no es un veredicto | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Lo que vive dentro de un `<!-- … -->` de la cabecera **no declara campo**; un rango que abre y no cierra en la cabecera no la deja medir y no deja cerrar | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Una línea de la cabecera con un **retorno de carro que no es el que la termina** no se puede medir y no deja cerrar — se deniega por eso, citando la línea, aunque los veredictos estén en verde. El CR **final** es transporte (CRLF decide igual que LF), el cuerpo no se toca y **reabrir** no se bloquea | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Una cabecera **ambigua** no deja cerrar: una **clave de control** (`Estado`, `QA`, `Seguridad`, `Sensible a seguridad`, `Hallazgos abiertos`, `Rigor`) escrita de otra forma que la máquina no lee como esa clave —mayúsculas, un blanco de más, un carácter invisible, un marcador de lista—, o declarada **más de una vez aunque diga lo mismo**, se deniega citando las líneas, aunque los veredictos estén en verde (`Hallazgos abiertos` repetida con su forma exacta, cuando es la única ambigüedad, la decide la fila de los hallazgos, con los límites que esa fila declara); **reabrir** no se bloquea. Qué es una variante y dónde acaba la frontera de lo cubierto: `requirements/README.md` § «Veredictos de validación». Lo que queda fuera de esa frontera **no está protegido** y se sigue leyendo como ausencia —ejemplos **no exhaustivos**: un homóglifo, una letra cambiada, unos dos puntos que no son ASCII, una línea con carácter de estructura, una clave de más de 256 bytes (una **limitación**, no una zona protegida por ese límite)— | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Un `Edit`/`MultiEdit` de `requirements/` que la puerta **no puede reconstruir** se deniega (norma única: REQ-023 CA-13 del repositorio del arnés) | §9 | `guard-completado` | `Edit`/`MultiEdit` |
| Las puertas juzgan el **archivo** que la escritura alcanzaría, no la forma de su ruta: una ruta equivalente recibe el veredicto de la canónica, un destino que no se puede determinar **no pasa**, y un `Edit`/`MultiEdit` de un REQ que la puerta no puede leer entero se deniega (norma única: REQ-007 CA-47 y CA-45 del repositorio del arnés) | §5, §9 | `guard-codigo`, `guard-completado` | `Edit`/`Write`/`MultiEdit` + `Bash` (parcial) |
| Una **entrada del hook que no se puede leer no pasa**: todo lo que no sea exactamente un objeto JSON —ejemplos **no exhaustivos**: un JSON que no se interpreta, `null`, un número, la entrada vacía, dos objetos seguidos, una entrada estándar cerrada— recibe `deny` a todo agente, con un motivo que lo dice; y una puerta que no puede trocear la parte de la entrada que necesita para decidir, deniega (SEC-120, `mitigado` en 1.36.0). **Límite declarado:** sin `CLAUDE_PROJECT_DIR`, el hook es inerte si de la entrada no puede obtener el proyecto, y deniega si del `cwd` de la entrada obtiene uno con manifiesto; que el host fije siempre esa variable está observado, no verificado (norma única: REQ-007 CA-47, punto 20, del repositorio del arnés) | §5, §6, §9, §10 | `guard-codigo`, `guard-completado`, `guard-git` | las que `hooks.json` hace pasar por `guard.sh` |
| **Ninguna decisión depende de nada que el hook herede del entorno:** con un estado heredado —ejemplos **no exhaustivos**: el modo POSIX (`POSIXLY_CORRECT`, `SHELLOPTS` con `posix`, `bash --posix`), una función importada con el nombre de una orden que el hook usa, una variable `ARNES_*`— la llamada recibe la misma decisión que sin él (SEC-129, `mitigado` en 1.36.0). **Sus límites declarados, ni aceptados ni reparados** —ejemplos **no exhaustivos**—: lo que corre antes de que el hook pueda limpiar nada o no se neutraliza desde dentro (funciones importadas `.` y `[`, que pueden llegar a un `allow` explícito; `SHELLOPTS` con `errexit`, `noexec` u `onecmd`; `xtrace` hacia la salida estándar; `BASH_ENV`), una función con el nombre de la orden de una quality gate, que hace pasar una gate roja, un límite de descriptores heredado que hace fallar el preludio, y `PATH` (F-136-19, F-136-20 y SEC-131). Su resolución, la frontera de confianza del entorno del host, es de 1.37 (norma única: REQ-007 CA-68, parte (ii), y «Límites declarados de 1.36.0» del repositorio del arnés) | §5, §6, §9, §10 | `guard-codigo`, `guard-completado`, `guard-git` | `Edit`/`Write`/`MultiEdit` + `Bash` |
| Un veredicto lleva fecha y no es anterior al último cambio del código —si el proyecto lo pide (`veredictos.*`, apagado por defecto) | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |
| Ningún agente —tampoco la coordinadora— ejecuta git destructivo: `clean -f`, `reset --hard`, `checkout .`, `restore .`, `stash` (`git.prohibidos`) | §10 | `guard-git` | `Bash` |

**Cada fila de esta tabla enuncia la propiedad de su control. Lo que la limita se escribe aquí, una vez
y aparte, y ninguna fila se lee como garantía sin ello:**
1. **Un hook que no emite su decisión no deniega.** Las dos vías conocidas por las que eso ocurría están
   **`mitigado`** en 1.36.0 (revisión R-056 del repositorio del arnés), no reparadas sin residuo:
   - el hook que el cliente mata por tiempo (SEC-115): el hook lleva un **plazo propio de 30 s**, comprobado
     sin procesos entre unidades de trabajo para que su respuesta llegue en **no más de 40 s**, y al vencer
     deniega; los techos de tamaño deniegan antes de las operaciones que crecen más que linealmente; y una
     **trampa de salida** emite un `deny` fijo si el proceso termina sin un juicio concluido;
   - el que decide pero no llegaba a emitir la decisión, porque su motivo no cabía en un argumento de línea
     de órdenes (SEC-118): el motivo ya no viaja como argumento —va por la entrada estándar de `jq`— y se
     **acota a 16 384 bytes**.

   **Sus residuales, que siguen abiertos o declarados:**
   - las **quality gates** (SEC-132 (a)), **límite declarado de 1.36.0 y sin reparar:** el plazo propio no
     alcanza a las quality gates —se comprueba antes de la primera, y no entre una y la siguiente ni durante la
     que está en curso—, así que cuatro gates de 20 s, o una sola gate colgada, dejan el hook **sin decisión** a
     los 60 s (medido en Linux/WSL2), y el cierre se aplica. **1.36.0 no cambia ese caso:** el límite es el mismo
     que en 1.35.0, donde el hook moría sin denegar y el REQ quedaba `completado`; el `deny` fijo de la trampa sale
     después de que el cliente ya mató el hook. La reparación preparada en 1.36.0 se revirtió antes de publicar por los defectos que abría, uno
     de ellos un cierre con una gate en rojo; la resolución es de 1.37, con tres lecciones de diseño (ficha
     F-136-22 del repositorio del arnés);
   - **una sola operación que crece más que linealmente**, que el plazo no interrumpe: miles de líneas
     `Hallazgos abiertos:` repetidas en la cabecera **en disco** (SEC-132 (b)) y un REQ de varios MB con CRLF
     en disco (QA-007-09), límites declarados de 1.36.0;
   - el **entorno del host** que el hook hereda y no puede neutralizar desde dentro —ejemplos **no
     exhaustivos**: funciones importadas con ciertos nombres, opciones del intérprete, `BASH_ENV`, un límite
     de descriptores, `PATH`— (F-136-20 y SEC-131): límites declarados, y su resolución, la frontera de
     confianza del entorno, es de 1.37;
   - **Windows/MSYS y el host**, sin medir;
   - y si el cliente **mata** el proceso —con `kill -9`, o al agotar su tiempo mientras una sola operación no
     termina—, nada que el hook haga deniega (SEC-030).

   Afecta a todas las puertas. *(Hasta 1.35.0 esta cláusula declaraba SEC-115 y SEC-118 como «limitaciones
   conocidas y sin reparar».)*
2. **Las filas de `guard-completado` por `Edit`, `Write` y `MultiEdit` juzgan el documento resultante:**
   el de un `Write`, o el que la puerta reconstruye de un `Edit`/`MultiEdit`. Lo que no puede reconstruir
   —tampoco porque el REQ no se pueda leer entero— **no lo deja pasar: lo deniega** (REQ-023 CA-13 y
   REQ-007 CA-45 del repositorio del arnés). Antes de 1.35.0 esa vía se juzgaba por fragmento, y un cierre
   podía no pasar por ninguna puerta: es SEC-117, reproducido con comillas tipográficas en el CLI 2.1.285.
3. **Todas las filas deciden sobre el archivo que identifica REQ-007 CA-47 del repositorio del arnés, y esa
   identificación tiene fronteras declaradas sin promesa** —por ejemplo, un cambio del sistema de archivos
   entre la decisión del hook y la escritura—. La lista vive sólo en ese criterio. Antes de 1.35.0 las
   puertas decidían por la ruta escrita, y `..`, `./` o un directorio enlazado las evadían (SEC-119; por un
   directorio enlazado, reproducido en el CLI 2.1.285).

Lo medido de SEC-115 y SEC-118 en 1.35.0 queda, fechado, en la fila de los hallazgos y en
`requirements/README.md` § «Clases de hallazgo»; su estado en 1.36.0 y sus residuales, en REQ-007 CA-67 y
CA-68 del repositorio del arnés y en las notas de la versión 1.36.0. Los registros completos están en
`docs/seguridad/registro-seguridad.md` del repositorio del arnés.

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

[[A-13.2 · obliga: todos]]

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

**Qué archivos van siempre por `Edit`, haya o no una puerta (PR-137-1 y PR-137-2).** Se enuncia por
**propiedad**, no por lista de rutas: **todo archivo versionado del proyecto que un agente cambia a
mano se cambia con `Edit`/`Write`/`MultiEdit`, haya o no una puerta que lo mire.** Escribirlo por
consola —un intérprete (`python`, `node`…), `sed -i`, una redirección— exige declarar **por qué** en
el informe de la comisión. **Límite declarado:** es norma para quien lee y **ninguna puerta lo
comprueba**; PR-137-1 y PR-137-2 siguen clasificados `instrumento`, y su caso de prueba mecánico es de
1.37 · 3.

[[A-13.3 · obliga: coordinadora, desarrollador, qa, seguridad]]

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
  **Y ancha no es infalible, y está medido:** esa detección lee el **texto crudo del comando**, así
  que partir la palabra del estado terminal entre dos expansiones dentro de un heredoc sin citar la
  evade, y el archivo queda escrito. Ensanchar el patrón cubriría esa forma y no la clase —una
  variable, `printf`, `base64 -d` o un intérprete la reproducen—: es una pregunta abierta y no se
  gana. La respuesta es la **puerta posterior**, que deja de preguntar antes si un comando escribe y
  pregunta después si algo protegido cambió. Hasta que exista, esta vía es exactamente lo que dice
  ser: una barandilla contra el descuido, no contra la ofuscación deliberada.

**Otro que tampoco decide: la rotación.** Un artefacto de bitácora —`CHANGELOG.md`, el registro
de seguridad— crece sin tope, y todo lo que crece sin tope acaba entrando entero en la ventana
de contexto. Con `rotacion.activo: true`, al parar un agente el arnés **mueve** las secciones
sobrantes a `<nombre>-archivo.md` y deja un puntero. **Mueve; no resume** — un resumen
convertiría la bitácora en la versión que el modelo recuerda de ella. Viene apagada.
También puede archivar **una sección** de un documento —típicamente la historia de un REQ— a
`historial/<nombre>.md`, dejando **el resto intacto**: la cabecera con sus veredictos y los
criterios de aceptación no se tocan nunca, porque son el contrato. Qué sección es historia lo
declara este proyecto en `rotacion.artefactos` (`glob` + `seccion`); el arnés no trae ninguna por
defecto, y el nombre se compara **exacto**, nunca por prefijo.

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
[[R-00 · obliga: todos]]

**Lectura por destinatario:** este archivo se lee por bloques, con la misma marca y las mismas
reglas que `AGENTS.md`, bloque A-00 —cada agente lee los bloques que lo nombran o dicen `todos`, la
coordinadora los lee todos, y ante la duda se lee—.

Esta carpeta es el **contrato compartido**: la única fuente de verdad sobre qué hay que hacer y qué falta. Todos los agentes leen y actualizan estos archivos.

[[R-1 · obliga: todos]]

## Tipos
- **REQ-xxx** — Requerimiento funcional (una capacidad del sistema).
- **NFR-xxx** — Requerimiento no funcional (seguridad, rendimiento, límites).

## Estados
| Estado | Significado |
|--------|-------------|
| `borrador` | Redactado, pendiente de confirmación del usuario |
| `pendiente` | Confirmado, aún no iniciado |
| `en-progreso` | El desarrollador lo está codificando |
| `en-revisión` | Terminado, en validación de QA / seguridad |
| `completado` | Pasó todas las quality gates + QA + seguridad |
| `bloqueado` | Detenido por una dependencia o veto (indicar motivo) |

Un REQ solo pasa a `completado` cuando: criterios de aceptación cumplidos + quality gates en verde + visto bueno de seguridad.

[[R-2.1 · obliga: todos]]

## Veredictos de validación (campos del REQ)

**Los campos valen sólo en la cabecera: antes del primer `## `.** Una línea `Seguridad: aprobado` dentro
de `## Historial` o de cualquier otra sección **no es un veredicto** y la máquina no la lee. Medido: así
una línea de log cerraba un REQ crítico con la cabecera en `pendiente`. Si un REQ tiene sus campos
debajo de una sección, súbelos.
Cierran el lazo de hallazgos para que no haya deriva silenciosa:

**Un paréntesis final es evidencia, y la evidencia no cambia el veredicto.** Escribe
`QA: aprobado (medido el 3/9, 42 pruebas)` sin miedo: el hook compara `aprobado` y el paréntesis
queda en el REQ, que es donde sirve. Poner la evidencia al lado de la afirmación es media razón
de ser de este arnés.

> **Y por eso mismo, un matiz que cambia el veredicto NO va entre paréntesis: es otro veredicto.**
> Una auditoría preventiva se escribe `Seguridad: preventiva`, no `aprobado (preventiva)`. Si
> escribes `aprobado (con reservas)` contará como **aprobado**, porque el paréntesis significa
> una sola cosa.
- `QA:` — veredicto del `qa-tester`: `pendiente` | `aprobado` | `con-hallazgos`.
- `Seguridad:` — veredicto del `auditor-seguridad`: `n/a` | `pendiente` | `aprobado` |
  `con-hallazgos` | `preventiva` | `vetado` (al marcar el REQ `Sensible a seguridad: sí`,
  pásalo de `n/a` a `pendiente`).
  - `con-hallazgos` es **lo intermedio**: ni «no he mirado» (`pendiente`) ni el freno
    formal con remedio, dueño y umbral (`vetado`). Es el estado más común de una
    auditoría real, y **no cierra** un REQ crítico: como todo valor distinto de
    `aprobado`, sirve para decir la verdad, no para firmar.

[[R-2.2 · obliga: coordinadora, qa, seguridad]]

**Un valor fuera de estos vocabularios se avisa al escribirlo.** Si escribes un veredicto
que la máquina no reconoce, el arnés te lo dice en ese momento —sin denegar la edición— y
te enseña la lista de valores válidos. No es una regla nueva: es que antes un REQ podía
pasar semanas con un campo que ninguna puerta leía, y nadie se enteraba hasta que fallaba
el cierre.

**La fecha del veredicto también va en el paréntesis, con su ronda:**
`QA: aprobado (R-045, 2026-09-01)`. Un veredicto es una foto, y una foto sólo vale si el
sujeto estaba quieto: un `aprobado` sin fecha sobrevive a los cambios del código que
juzga. Si el proyecto enciende `veredictos.exigir_fecha` en `.arnes/config.json`, un
`aprobado` sin fecha `AAAA-MM-DD` no cierra; con `veredictos.caducan_con_codigo` tampoco
cierra un veredicto anterior al último commit que tocó el código de la app, ni con
cambios sin comitear en ese código. Las dos vienen **apagadas**.

**Tu historia puede archivarse; tus criterios no.** Si el proyecto lo activa, el arnés
mueve las entradas viejas de la sección de historia de este REQ a un archivo aparte y
deja un puntero. **Mueve, no resume, y no toca ni una línea del resto del documento** —ni
la cabecera con sus veredictos, ni los criterios de aceptación, que son el contrato.

**En el bloque derivado de `docs/ESTADO.md` los veredictos se muestran recortados a 40
caracteres** con un `…` al final. Es sólo presentación: la puerta lee el valor **entero**,
así que un `Hallazgos abiertos:` largo no pierde su clase por salir recortado en la
tabla.

**El orden importa:** `Seguridad: aprobado` no se escribe mientras `QA:` siga en `pendiente` o
`con-hallazgos` — el auditor no mira las quality gates, así que su firma sobre un árbol sin
validar acreditaría algo que no revisó. El hook lo impide **en cualquier edición del REQ**, no
sólo al cerrarlo, porque el daño se hace al escribir el veredicto. La única salida es la
auditoría **preventiva** —hecha antes de que exista el código—, que se declara al emitirla
como `Seguridad: preventiva` y **no** cubre el código posterior.

El hook `guard-completado` **impide** marcar `completado` sin `QA: aprobado`, y un REQ
`Sensible a seguridad: sí` sin `Seguridad: aprobado`. Llegar a "aprobado" exige que los
hallazgos estén resueltos **y reflejados en el REQ/NFR** (write-back, ver `AGENTS.md` §9).

[[R-2.3 · obliga: todos]]

**Cada clave de control se escribe una sola vez, y como la escribe la plantilla.** Las claves de
control son las seis cuya presencia o ausencia decide el cierre: `Estado`, `QA`, `Seguridad`,
`Sensible a seguridad`, `Hallazgos abiertos` y `Rigor` (lista cerrada; en el código del arnés vive una
sola vez). Si la cabecera escribe una de ellas **de otra forma** —una
*variante*— o la declara **más de una vez**, **aunque las dos líneas digan lo mismo**, la cabecera es
**ambigua** y la puerta **deniega el cierre** citando las líneas —las primeras, y cuántas más hay—, con
los caracteres invisibles escritos de forma legible; `tools/arnes-lectura.sh` las nombra todas. No lee la variante como la clave ni elige entre dos declaraciones, y ningún lector
cambia el valor que lee. **A qué ediciones alcanza esta regla:** a las que la puerta puede
reconstruir: un `Write`, o un `Edit`/`MultiEdit` reconstruible según REQ-023 CA-13 del repositorio del
arnés, que es la sede única de esa definición. **Una edición que la puerta no puede reconstruir no
queda fuera ni pasa:** la deniega esa otra regla antes de llegar a ésta. **Tampoco pasa un
`Edit`/`MultiEdit` de un REQ que la puerta no puede leer entero:** lo deniega REQ-007 CA-45 del mismo
repositorio, que dice también cómo se juzga un `Write` sobre él. **Cuándo deniega, dicho entero
para ese alcance:** cuando la cabecera que quedaría escrita es
ambigua, **alguna** de sus líneas `Estado` —la exacta, una repetida o una variante— dice el estado
terminal, y la línea `Estado` que gobierna en disco (la primera declaración exacta; si no hay ninguna,
nada lo decía) **no** lo decía. Nada más: reabrir o editar un REQ cuyo `Estado` que gobierna en disco ya
es el terminal no se bloquea por esto, ni una edición tras la cual ninguna línea `Estado` dice el
terminal. **Consecuencia:** si en disco el terminal está en una línea `Estado` que **no** es la que
gobierna —una variante, o una declaración exacta que no es la primera— y la que gobierna no lo dice o no
existe, se deniega toda edición **de ese alcance** que conserve esa línea mientras la cabecera siga
siendo ambigua, aunque no toque el estado; la que la retira, la corrige o deshace la ambigüedad no se
deniega por esto. Para `Hallazgos abiertos` repetida con su forma exacta decide su propia regla, con
los límites que esa regla declara («Clases de hallazgo», abajo).

[[R-2.4 · obliga: coordinadora, desarrollador, qa, seguridad]]

**Qué es una variante, por propiedad.** Una línea de la cabecera —antes del primer `## `, fuera de todo
`<!-- … -->`, con dos puntos ASCII (`:`)— cuya clave, tras la tolerancia de siempre (blancos de los
extremos, `*`, `_` y `` ` ``) y tras quitar **como mucho un** marcador de lista inicial (`-` o `+`
seguido de un blanco; o de 1 a 3 dígitos seguidos de `.` o `)` y de un blanco; los caracteres
invisibles que lo precedan no impiden reconocerlo), tiene **las mismas
letras ASCII**, sin distinguir mayúsculas, que una clave de control, y no es exactamente esa clave.
Para comparar —nunca para leer— se descartan los espacios, los caracteres de control y todo carácter no
ASCII. Ejemplos **no exhaustivos**: `HALLAZGOS ABIERTOS:`, `qa:`, `Hallazgos  abiertos:` (blanco doble),
la clave con un BOM, un espacio de anchura cero o un espacio duro delante o dentro, `- Rigor:` y
`1. QA:`. Una línea con exactamente la forma de una declaración (`- Estado: …`) se trata como tal.

**Lo que no es una declaración, y por tanto no es variante:** una línea cuya clave, tras el marcador,
contiene un signo ASCII visible que no es letra —`>`, comillas, paréntesis, corchetes, dígitos, `&`,
`/`, `.`, etc.— o una comilla tipográfica (`«` `»` `“` `”` `‘` `’` `„` `‹` `›`, lista cerrada): es una
cita, una mención o una referencia. Ejemplos **no exhaustivos**: `> Estado: completado`,
`«Estado»: …`, `(QA): …`, `Q&A: …`.

[[R-2.5 · obliga: todos]]

**Fuera, y sin promesa:** una letra cambiada por otra que se le parece (`Hallazgоs` con `о` cirílica,
letras de ancho completo); una letra ASCII de más, de menos o distinta (`Hallazgo abierto:`, `Rigr:`);
unos dos puntos que no son ASCII (`：`); las líneas con un signo visible de los de arriba, aunque lleven
además un carácter invisible; un espacio duro en lugar del blanco que sigue al guion o al número del
marcador (`-`+espacio duro+`Estado:`), que ya no forma marcador y deja el `-` como signo; y las claves de
**más de 256 bytes**. Todo eso se sigue leyendo como hasta ahora: como si la línea no declarara el campo, que
para ese campo es su **ausencia**. Las claves de más de 256 bytes son una **limitación**: se leen como
ausencia y ese límite **no las protege**. Esta regla mira la **clave**: el valor se lee como siempre.
**La edición que la puerta no puede reconstruir ya no está en esta lista.** Un `Edit`/`MultiEdit` cuyo
`old_string` sólo coincide tras la normalización que aplica la herramienta —comillas tipográficas,
`\uXXXX`— **se deniega**. La norma está en REQ-023 CA-13 del repositorio del arnés (ADR-015), que es la
vía de SEC-117. Para editar un REQ, copia el `old_string` literal del archivo.

[[R-3 · obliga: todos]]

## Nivel de rigor
Cuánta demostración se exige **por encima** de las quality gates, que son binarias y corren
siempre. Lo fija el analista en la cabecera del REQ.

| Nivel | Qué corre | Cuándo |
|---|---|---|
| `ligero` | analista + desarrollador + quality gates | Normal: fuera de los cinco ámbitos de la política (abajo) |

> `ligero` salta **sólo** los veredictos de QA y seguridad. La clase del hallazgo, las aprobaciones humanas
> pendientes y las quality gates corren igual que en cualquier otro nivel.
| `estandar` | + QA | Lógica de negocio ordinaria |
| `critico` | + auditoría de seguridad | Dinero · datos personales · identidad o acceso · documento con efecto legal · cambio irreversible (esquema, migración, borrado) |

**Qué REQ de ESTE proyecto cae en cada nivel se decide en `AGENTS.md`, no aquí.** Los
criterios de arriba son independientes del dominio a propósito: el arnés trae el mecanismo,
cada proyecto pone el mapeo con sus ejemplos concretos.

**La política de rigor (`rigor_politica` de `.arnes/config.json`) — sede única de cómo se aplica.**
- La aplica el analista **al crear** el REQ, escribiendo `Rigor:` y `Sensible a seguridad:`.
  **Ninguna puerta la lee**, y un REQ existente no se reclasifica.
- **Declarada** = los cinco ámbitos (`dinero`, `sesion`, `seguridad`, `datos`, `arnes`) con una
  lista de globs no vacía o `"ninguno"`. `[]`, un ámbito ausente, otro tipo, la clave ausente o un
  JSON ilegible = **sin declarar**, y entonces el proyecto **se comporta como antes de la
  política**: `ligero` sólo lo sin lógica (textos, etiquetas, presentación), lo demás `estandar`, y
  `critico` lo sensible o lo que declare `AGENTS.md` §6.
- Declarada, un REQ es **normal** sólo si su **efecto** no alcanza ningún ámbito: **dinero** (lo
  que cobra, abona, calcula o muestra como importe), **sesión** (identidad y autenticación del
  usuario final), **seguridad** (autorización, secretos, rutas protegidas, controles), **datos**
  (personales, esquema, migración, borrado) o **arnés** (lo que el arnés instala y gobierna a los
  agentes). Los globs son ayuda **necesaria y no suficiente**: que ninguno case no prueba nada.
  Normal → `Rigor: ligero`, `Sensible a seguridad: no`, `QA: pendiente`, `Seguridad: n/a`.
  Ámbito alcanzado → `Rigor: critico`, `QA: pendiente`, `Seguridad: pendiente`, y `Sensible a seguridad: sí` si toca sesión, seguridad o datos personales (si no, `no`: un ámbito alcanzado puede ser `critico` sin ser sensible, p. ej. dinero).
  **Ante la duda, completo.**
- La política sólo da `ligero` a lo que sin ella no sería `critico`, y no toca el suelo de abajo.
  **Todo cambio de la política que reduzca lo que alcanza un ámbito exige la firma del auditor**
  (ejemplos **no exhaustivos**: quitar o estrechar un glob, declarar `"ninguno"`). Vaciar un ámbito
  a `[]` lo deja sin declarar. Es norma para quien lee, sin comprobación mecánica;
  si el manifiesto no está en `codigo_app.globs`, cualquier agente puede editarlo.
  **Riesgo declarado (SEC-139): el ahorro del `ligero` descansa en el juicio del analista al
  clasificar.** Un REQ clasificado normal por error **cierra sin ninguna revisión de QA ni de
  seguridad**; el suelo de sensibilidad, «ante la duda, completo» y la facultad del auditor dependen
  de ese mismo juicio o de que alguien despache al auditor, y ninguna puerta lo detecta. La
  comprobación futura es la ficha F-137-18 (pieza b).
  *(En este repositorio no hay política: todo REQ del arnés es `critico` y sensible, `AGENTS.md` §6.)*

**Reglas de gobierno:**
- **Lo fija el analista.** El auditor **puede subirlo**; nadie lo baja sin su firma.
- **Se puede subir, nunca bajar.** Un REQ marcado `Sensible a seguridad: sí` tiene `critico`
  como **suelo**: escribir `Rigor: ligero` ahí no lo baja. Bajarlo de verdad exige cambiar la
  sensibilidad, que es un campo visible del analista.
- **Si se omite, se deriva:** sensible → `critico`, si no → `estandar`. Es exactamente el
  comportamiento anterior a que existieran los niveles, así que un proyecto que no declare
  nada no nota ningún cambio.
- El rigor efectivo combina el nivel declarado con el suelo de seguridad. Un matiz
  parentético **bien formado** —el que **cierra el paréntesis al final del valor**,
  como `critico (por suelo)`— conserva `estandar` y `critico`, sujeto a ese suelo.
  Para mantener la protección heredada, `ligero` con matiz deriva a `estandar` si el
  REQ no es sensible y a `critico` si lo es. `ligero` sin matiz conserva su
  comportamiento, sujeto al suelo de seguridad.
- **Un paréntesis que no cierra al final del valor no es un matiz: es un valor
  desconocido**, y cae en la derivación heredada del punto siguiente. `critico (por
  suelo` (sin cerrar), `critico (` y `critico (x) y` (con texto detrás del cierre) se
  juzgan **`estandar`** en un REQ no sensible, así que un `critico` escrito así **deja
  de exigir la firma de seguridad, y no avisa**. Es la única protección que esta forma
  puede perder: en `ligero` y en `estandar` la derivación heredada da lo mismo, y en un
  REQ sensible el suelo de `critico` lo impide. Escribe el matiz cerrado, o no lo
  escribas.
- Un valor realmente desconocido conserva la derivación heredada: sensible →
  `critico`; no sensible → `estandar`. No garantiza conservar el nivel que el autor
  pretendía escribir; usa uno de los tres niveles válidos.

[[R-4 · obliga: coordinadora, desarrollador, qa, seguridad]]

## Clases de hallazgo
Todo hallazgo abierto se declara en el campo `Hallazgos abiertos:` de la cabecera, con
su **clase entre paréntesis**: `SEC-121 (instrumento), SEC-144 (usuario/dinero)`.

**La sintaxis del campo es cerrada, y ésta es su sede única.** El valor es **una ausencia** —vacío,
`(ninguno)`, `n/a`, `-`: ejemplos no exhaustivos; la lista exacta la fija `guard-completado`— **o una
lista**: uno o más hallazgos separados **sólo por comas que estén fuera de todo paréntesis**. Cada
hallazgo es, exactamente y en este orden, `ID (clase)` o `ID (clase, evidencia)`:

- **ID**: letras ASCII, dígitos y `-`, sin blancos dentro (ejemplos no exhaustivos: `SEC-121`,
  `QA-030-03`, `H-07`).
- **clase**: lo primero dentro del paréntesis, hasta la primera coma o hasta el cierre; una de las
  tres de la tabla de abajo, sin distinguir mayúsculas ni blancos.
- **evidencia** (opcional): tras la clase y una coma, **dentro del mismo paréntesis**. Puede llevar
  comas, `;`, `·`, guiones y paréntesis anidados **equilibrados**, y **no declara nada**: un
  identificador o una clase escritos dentro de la evidencia no se leen.
- **Tras el `)` que cierra el hallazgo sólo cabe la coma que lo separa del siguiente, o el fin del
  campo.** Los blancos alrededor no cambian nada.

Todo lo que no casa con esa forma hace que la lista **no se pueda interpretar**, y entonces la puerta
**deniega el cierre** nombrando el fragmento que no entendió: no reescribe el campo, no lo repara y no
ignora la parte que no entiende. Ejemplos **no exhaustivos** —la regla es la de arriba—: un separador
que no es la coma (`;`, `·`, `/`, `y`), texto o una nota detrás del paréntesis, dos paréntesis en un
hallazgo, un paréntesis sin cerrar o uno sobrante, un elemento vacío (`,,` o una coma final), un
elemento sin ID, un ID con blancos dentro, con una tilde (`SÉC-1`) o con marcado (`` `SEC-1` ``), y una
ausencia mezclada con hallazgos. Lo que quieras anotar junto a un hallazgo va **dentro de su
paréntesis**, tras la clase y una coma: `QA-006 (instrumento, REQ-007)`, no
`QA-006 (instrumento) — REQ-007`. Un elemento **sin ningún paréntesis** (`SEC-4`,
`QA-006 [instrumento]`) es un hallazgo **sin clase** (abajo), y también deniega.

**Qué lee la puerta, y qué no.** La puerta juzga **el valor de la única línea de la cabecera** —antes
del primer `## `— cuya clave reconoce su lector como `Hallazgos abiertos` (también decorada,
`**Hallazgos abiertos:**`, o sangrada). **Si hay más de una, deniega** y las nombra: no elige la
primera ni la última y no las fusiona; se deja una sola línea con todos los hallazgos. **Aparte de esa
regla, sus límites.** En 1.36.0 esa denegación **llega al cliente**: el motivo cita los primeros 60
caracteres de cada línea repetida, viaja por la entrada estándar de `jq` y no como argumento, y se acota
a 16 384 bytes (SEC-118 del repositorio del arnés, **`mitigado`** en 1.36.0; Windows/MSYS y el host, sin
medir). **Su residual, límite declarado de 1.36.0 y sin reparar (SEC-132 (b) del mismo repositorio):**
con miles de líneas repetidas en la cabecera **en disco**, el juicio crece más que linealmente y puede
pasar del plazo del hook (40 s) o quedarse **sin decisión**. Medido a nivel de hook en Linux/WSL2, una
corrida por punto —cifras operativas: mediciones, no umbrales—: con líneas de 66 caracteres, 12 000
deniegan en 32,8 s y 20 000 salen sin decisión a los 60 s; con líneas cortas, 20 000 deniegan a los
48,5 s. Que el cliente trate como permitir un hook sin decisión es inferido. *(Medido en 1.35.0, y
historia de esa versión, no límite de 1.36.0: el motivo viajaba como un argumento de línea de órdenes,
cuyo límite es de **bytes**, y por encima el hook salía **sin decisión**; con líneas **ASCII** de 60
caracteres o más, 1 601 deniegan (motivo de 121 061 bytes) y 1 801 salían sin decisión; con líneas
**ASCII** cortas, 2 501 deniegan (111 961 bytes) y 3 000 salían sin decisión; con caracteres
**multibyte** en la parte citada, bajo `C.UTF-8`, salían sin decisión 1 601 líneas con `ñ`, 1 001 con
caracteres de 4 bytes y 2 501 cortas con `ñ`.)* Dentro de esa
línea, ningún hallazgo que bloquea queda sin leer por el sitio que ocupa en la lista ni por el
carácter que lo separa del anterior. **Lo que el lector no reconoce como esa línea no se lee.** Si es
una **variante** de la clave —`Hallazgos  abiertos:`, `HALLAZGOS ABIERTOS:`, la clave con un carácter
invisible; definición y frontera en «Veredictos de validación», arriba—, la puerta **deniega el cierre**
por cabecera ambigua, sin leer su valor. En lo demás no hay promesa; ejemplos **no exhaustivos**: una
continuación en la línea siguiente sin clave, un homóglifo (`Hallazgоs`) y lo que queda fuera de esa
frontera, lo que va dentro de un comentario HTML de la cabecera y una línea igual debajo del primer
`## `.

**Techo de tamaño: 16 384 bytes.** Si el valor —todo lo que va tras los dos puntos, incluido el
blanco que los sigue, contado en **bytes** y antes de normalizar— mide **más de 16 384 bytes**, la
puerta deniega el cierre sin interpretarlo y dice el tamaño medido: una puerta que no puede medir no
deja pasar. Con 16 384 bytes o menos decide la clase, como arriba. La evidencia larga va al registro
del hallazgo y en el paréntesis queda la referencia. **El techo se mide en el lector, antes de
normalizar el valor**: por encima, el valor no se normaliza, no se recorta y ningún lector lo toma por
«sin hallazgos» (el bloque derivado de `docs/ESTADO.md` lo muestra como `(no medido: N bytes, techo
16384)`). **En 1.36.0** (SEC-115 del repositorio del arnés, **`mitigado`**): el hook lleva un plazo
propio y techos de tamaño —un `Write` cuyo contenido pasa de unos 393 216 bytes se deniega antes de la
operación que crecía más que linealmente—, y un juicio que agota el plazo deniega, con la respuesta en
no más de 40 s, salvo sus residuales; la propiedad, esos residuales y sus límites declarados están en
REQ-007 CA-68 del mismo repositorio,
en `AGENTS.md` §13, cláusula 1, y en las notas de 1.36.0. *(Medido en 1.35.0, y historia de esa
versión:)* **Esa denegación se promete hasta lo medido, y no más allá**, porque el hook tiene que
decidir dentro del límite del cliente (60 s) y un hook muerto no deniega. Medido en Linux/WSL2, una
corrida por punto, hook entero, lista no exhaustiva: 60 006 bytes → deniega por tamaño en 0,21 s;
255 371 bytes → 0,31 s por `Edit` y `MultiEdit` y 1,6 s por `Write`. Por encima de 255 371 bytes **no
hay promesa**: por `Edit` sigue siendo lineal (2 000 000 bytes → 2,1 s), pero por `Write` el contenido
entrante pasa antes por otra operación del hook que crece más que linealmente (1 000 000 bytes →
28 s; 2 000 000 → 84 s, por encima de los 60 s del cliente). En Windows/MSYS no está medido y será más lento.
Ese residuo tiene dueño y vencimiento en el `docs/PENDIENTES.md` del repositorio del arnés. En 1.35.0
era una limitación aparte de la regla —SEC-115 del mismo repositorio, `mitigado` en 1.36.0 (arriba)— y
no formaba parte de lo que la regla promete.

| Clase | Qué es | Efecto en el cierre |
|---|---|---|
| `usuario/dinero` | Afecta lo que alguien ve, decide o cobra | **Bloquea.** Reabre el REQ |
| `contrato` | El requerimiento dice algo falso sobre lo construido | **Bloquea** hasta el write-back |
| `instrumento` | El control o la prueba tienen un defecto, sin efecto en el producto | **No bloquea.** Deuda técnica con dueño |

**Un hallazgo sin clase declarada no cuenta como hallazgo** — y la puerta deniega el
cierre hasta que se clasifique, porque no puede saber si bloquea.

Por qué existe la clase `instrumento`: un defecto del propio arnés —un lector de
umbral, un guardián— **no puede impedir cerrar una función de negocio**. Atacar
guardianes es valioso y tiene su propio ciclo; los hallazgos que produzca entran como
deuda con dueño, no reabren REQ de negocio.

[[R-6 · obliga: todos]]

## Cambios de requerimientos
Un REQ **no se reescribe encima**: se versiona. Todo cambio se anota en el **Historial de
cambios** del REQ (fecha · antes→después · causa · ADR si aplica). Los cambios de fondo
generan un **ADR**. Si un REQ `completado` cambia, vuelve a `en-progreso`/`en-revisión` y
**re-recorre el ciclo**. Política completa en `AGENTS.md`, sección "Cambios de requerimientos".

## Metodología
**1. Historia de usuario:** Como **[rol]**, quiero **[acción]**, para **[beneficio]**.
**2. Criterios de aceptación en Gherkin:** **Dado** [contexto] **Cuando** [acción] **Entonces** [resultado].
**3. Requisitos no funcionales** se documentan como NFR separados y se referencian desde los REQ.

[[R-8 · obliga: todos]]

## Plantilla
```markdown
# REQ-XXX — Título
Estado: borrador
Módulo: (...)
Archivos: (rutas o globs relativos a la raíz, separados por comas — o `(ninguno)`)
Prioridad: (alta / media / baja)
Sensible a seguridad: (sí / no)
QA: pendiente
Seguridad: n/a
Hallazgos abiertos: (ninguno)
Rigor: (ligero / estandar / critico — ver abajo; si se omite, se deriva)
NFR relacionados: (NFR-xxx, ...)

## Historia
Como [rol], quiero [acción], para [beneficio].

## Criterios de aceptación
- Dado ... Cuando ... Entonces ...

## Notas / alcance
(detalles, fuera de alcance, dependencias)

## Preguntas abiertas / conflictos
(preguntas sin resolver; conflictos con otros REQs identificando ambos y la contradicción. Mientras haya algo aquí, el REQ se queda en `borrador`.)

## Trazabilidad
Origen: (fuente identificable del pedido: archivo y commit, o mensaje y fecha — o el literal `fuente no disponible`; un resumen del agente no es fuente)
Tocado por: (agente / fecha)

### Correspondencia con el encargo
(se establece al crear el REQ. Una fila por **obligación verificable** del pedido —algo cuyo cumplimiento se decide
sí/no contra el REQ o lo construido—, no por frase: una frase con dos obligaciones da dos filas, y una de contexto o de
motivo no da ninguna. Cada fila lleva su cita; si el pedido no se conservó, `fuente no disponible` en su lugar: nunca
se reconstruyen las palabras del propietario. «Relación» toma **exactamente** uno de estos valores: `cubierta`,
`omitida`, `sustituida`, `excluida` o `añadida` (decisión de negocio no pedida); **éste es el sitio único de ese
vocabulario** y todo otro texto que lo nombre remite aquí. La tabla se actualiza **sólo cuando cambia el alcance**, en
la misma fila del Historial de cambios que registra ese cambio (`AGENTS.md` §9); una reparación que conserva el
contrato la reutiliza, sin tabla nueva ni comparación completa, y una que altera qué obligación cubre un criterio no
conserva el contrato: es cambio de alcance. Una **autorización citada** es una copia fiel y verificable de la
decisión del propietario, o su confirmación concreta, registrada en una sede **localizable por ruta en el
repositorio** (ejemplos **no exhaustivos**: una entrada de `PENDING_APPROVAL.md` §«Resueltas», una fila del
Historial de cambios con la cita, un archivo bajo `docs/`); no exige archivar conversaciones completas. **Una
referencia cuyo contenido no puede verificarse no cuenta como autorización** para una decisión nueva que requiere
al propietario: la fila sigue sin resolver, lo que dependa de ella no se implementa, y el trabajo independiente
autorizado continúa. Para un REQ existente ya aprobado cuyo pedido o conversación original no se conservó, ver la
definición del `analista-requerimientos`: esa ausencia no invalida sus aprobaciones ni lo devuelve a `borrador`.)
| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «...» (o `fuente no disponible`) | CA-xx | (uno de los cinco valores) | (ruta de la autorización verificable, o `→ Preguntas abiertas`) |

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| AAAA-MM-DD | (creación) | — | — |
```

