<!-- DERIVADO — no editar a mano: lo genera tools/arnes-lectura-rol.sh y se pisa en la siguiente generación. -->
<!-- Rol: analista -->
<!-- Fuentes: AGENTS.md 78657 B sha256 3e94203d19e112c67fe3c2f444b3396d0aa710165e0fc55f9999fab96ec3f89e; requirements/README.md 79087 B sha256 b741c400a5f4f3b779f7bd039160d1658bd80e0e67c040b26d1fddb0bf69c1ab -->

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

[[A-6.19 · obliga: todos]]

**Observabilidad (en archivos, no en infra):** la traza del proyecto vive en archivos legibles
— `CHANGELOG.md` (qué cambió, quién, qué modelo), `docs/seguridad/registro-seguridad.md`
(hallazgos) y `docs/ESTADO.md` (dónde vamos). Esa es la observabilidad por defecto; un backend
de trazas/métricas es opcional vía MCP.

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

[[R-5.1 · obliga: analista, coordinadora]]

## El mapa de archivos: el campo `Archivos:`

Todo REQ **abierto** —`pendiente`, `en-progreso` o `en-revisión`— declara en su cabecera una línea
`Archivos:` con lo que su implementación va a tocar. Existe para una sola pregunta, y es una que se
puede responder por máquina: **¿qué dos comisiones se pueden despachar a la vez sin que se pisen?**

**La forma, enunciada por propiedad y no como lista de casos:** rutas o **globs** relativos a la
raíz del repositorio, separados por **comas**; o el valor literal `(ninguno)` si el REQ no toca
ningún archivo del árbol. Un patrón vale si lo expande la shell contra el árbol —no hay una lista
cerrada de globs admitidos—; una ruta **absoluta** queda fuera de la forma y se rechaza.

```
Archivos: hooks/lib.sh, tools/arnes-lectura.sh, templates/*.tpl
Archivos: (ninguno)
```

Se escribe con las **mismas tolerancias que los demás campos de la cabecera, y ni una más**
—`**Archivos:**`, sangría, tabuladores, el valor entre acentos graves, un paréntesis final de
evidencia—, porque lo lee **el mismo normalizador** que las puertas. Y, como todos, **vale sólo en
la cabecera**: una línea igual debajo del primer `## ` no declara nada.

> **El paréntesis de evidencia acompaña a SU elemento — y por eso la coma de dentro no separa.** Este
> campo es una **lista**, así que la normalización se aplica **elemento a elemento**: anotar elemento
> por elemento —`Archivos: tools/x.sh (nuevo), hooks/lib.sh (modificado)`— **sí es una forma
> admitida**, declara **dos** archivos y colisiona con quien declare cualquiera de los dos. La
> evidencia puede ir en la primera posición, en una intermedia, en la última o en todas, y sigue
> siendo evidencia: `Archivos: hooks/lib.sh, tools/arnes-lectura.sh (medido el 6/9)` declara dos
> archivos, no tres. Dentro de un paréntesis la **coma no separa** —la evidencia las lleva—, de modo
> que `hooks/lib.sh (medido el 6/9, 2 archivos), tools/x.sh` son **dos** elementos; el reverso de esa
> convención es que lo que escribas dentro del paréntesis **no declara nada**. Y lo que no se entiende
> —un paréntesis **sin cerrar**, una anotación **suelta** entre dos comas— no se descarta en silencio:
> la herramienta lo **dice con su motivo**, el REQ pasa a `SIN DECLARAR` y colisiona con todos, nunca
> `disjunto`. Se rechaza **en voz alta** a propósito: hasta 1.32.0 un paréntesis intermedio borraba
> **en silencio** todo lo que venía detrás y la respuesta era `disjunto` con rc 0 sobre medio mapa
> (SEC-014). Si quieres anotar de dónde sale cada ruta con más detalle del que cabe en un paréntesis,
> va en el cuerpo del REQ; la cabecera es lo que lee la máquina.

> **Y un límite operativo con causa abierta: escribe las rutas SIN decoración de Markdown.** Envolver
> **cada** elemento en acentos graves o subrayado —`` `hooks/lib.sh`, `tools/x.sh` `` o
> `_hooks/lib.sh_, _tools/x.sh_`— **no es fiable hoy**: el desenvoltorio arranca el par **exterior**,
> que pertenece a dos elementos distintos, los dos quedan con un marcador impar y la herramienta
> responde `disjunto` con rc 0 sobre un mapa de rutas que no existen (**SEC-020**, `contrato`,
> **abierto**, ventana 1.33.0). No es una promesa de la máquina en ninguna dirección —es un fallo
> declarado, no una regla—: mientras el hallazgo siga abierto, la ruta **desnuda** es la única forma
> medida como segura, y un `disjunto` sobre un campo decorado no se toma por bueno. Envolver la línea
> **entera** (`` `hooks/lib.sh, tools/x.sh` ``) sí se lee bien, y por eso la tolerancia del párrafo
> anterior sigue enunciada como está.

**Lo que NO se declara: los artefactos de gobierno de quien orquesta, porque ninguna comisión los
escribe.** La regla está **en vigor de facto desde el 2026-09-07** —desde el primer despacho paralelo
real— y se escribe aquí por decisión del propietario del **2026-09-08**. Se escribe porque una regla que
se aplica sin estar en el contrato **se reinterpreta cuando conviene**, que es la misma clase que
`SEC-053` (`contrato`, **abierto**, severidad alta: un criterio de publicación aplicado sin su frontera
escrita, y bajo el que ya se publicó una versión — `docs/seguridad/registro-seguridad.md:4470-4481`).

**La propiedad, con sus dos caras, que es la única forma de que decida el caso siguiente:** un artefacto
es **de gobierno** si su contenido es el **resumen de la orquestación** —lo que quien orquesta ya tiene
por haber orquestado— y **no** evidencia que sólo posee quien la produjo. La cara que **saca** del campo:
lo escribe quien orquesta, así que ninguna comisión lo toca y no entra en ningún conjunto de escritura.
La cara que lo **deja dentro**, y sin ella la propiedad no sirve para decidir nada: la **evidencia
primaria** —la reproducción, la cifra y las condiciones en que se tomó— sólo la tiene quien la midió, de
modo que el registro de hallazgos de QA y `docs/seguridad/registro-seguridad.md` **sí** son conjunto de
escritura de su comisión y **sí** se declaran; trasladarlos obligaría a una segunda transcripción del
mismo contenido y le arrancaría a cada cifra su condición. Ejemplos **no exhaustivos** de la primera
cara, ya decididos: `CHANGELOG.md`, `docs/ESTADO.md` —cuyo bloque entre marcadores **lo deriva el hook**
y cuyo texto de fuera es de la coordinadora— y `PENDING_APPROVAL.md`, que es la cola de decisiones
humanas. La **lista declarada** no existe todavía: llega con **REQ-022 CA-04** a `.arnes/config.json`
(ventana 1.34.0), y hasta entonces decide la propiedad.

**Quita el archivo del mapa, NO la obligación.** `AGENTS.md` §8 sigue exigiendo entrada de
`CHANGELOG.md` en **todo** commit, y el hook `pre-commit` sigue denegando el commit sin ella: lo que
cambia es **quién** la escribe —quien comitea, que es quien orquesta—, no si se escribe. Y por eso la
objeción que esta regla responde era **correcta** mientras la regla no existía: omitir el libro mayor
fabricaba un `disjunto` falso entre dos comisiones que iban a escribir las dos en él
(`requirements/REQ-019.md:1446-1450`). Lo que la vuelve falsa no es una convención de higiene, es que
ahora **ninguna** lo escribe.

> **El límite, y va fuerte porque es donde esto se tuerce:** un campo se acota **sólo** cuando la
> comisión de verdad no escribe ese archivo. **Acotarlo para ganar paralelismo corrompe el mapa**, y un
> `disjunto` sobre un mapa corrompido no autoriza nada — que es exactamente **SEC-020**, abierto. La
> regla existe para **dejar de declarar una colisión que no existe**, no para esconder una que sí. De ahí
> el fail-closed, que aquí no lo puede llevar ninguna máquina: mientras un caso no esté decidido, **se
> declara**. Los dos errores no cuestan igual —de más es un `colisiona` falso, que devuelve a la serie un
> trabajo que podía ir en paralelo; de menos es un `disjunto` falso, que son dos comisiones escribiendo
> el mismo archivo y una **escritura perdida** que git no señala—, así que la duda cae **siempre** hacia
> declarar. Casos que la propiedad **no** cierra hoy, dichos por su nombre para que nadie los retire
> leyendo lo de arriba: `docs/PENDIENTES.md` —donde REQ-017 escribe una medición **como producto**— y el
> índice de ventana `docs/qa/<versión>.md`, cuya escritura el write-back de REQ-017 del 2026-09-07 hizo
> contar **a propósito**. Los resuelve REQ-022 (CA-04 y CA-06-bis) en 1.34.0.

**Y la limpieza de los campos ya escritos no la hace la comisión que escribe esta regla.** Hoy **11**
archivos de `requirements/` declaran `CHANGELOG.md`: **6** abiertos (007, 008, 011, 013, 014, 019), **3**
`completado` (012, 015, 016) y **2** en `borrador` (023, 024). Cada uno de los **abiertos** lo retira
**cuando se le toque por otro motivo**, o en una comisión propia con su medición; los `completado` se
quedan **idénticos**, por el mismo motivo que «Alcance temporal» más abajo, y los `borrador` al salir a
`pendiente`. Retirarlo de once archivos desde aquí sería escribir en once archivos que esta comisión no
tiene en su ámbito. *(Cifras **operativas**, corrida del 2026-09-08 sobre `cand/1.33.0`, `Estado:` leído
REQ a REQ y **no** por el índice; dirección buscada: **hacia 0** en los abiertos. Se mueven solas al
abrirse o cerrarse un REQ — el encargo de esta comisión traía **8** y REQ-022 CA-05 midió **9, 5 de 8
abiertos** el 2026-09-07, y ninguna de las tres cifras estaba mal.)* Lo que esta regla compra está
medido en la misma corrida: `tools/arnes-paralelo.sh` responde `colisiona` en **67 de 67** pares del
proyecto y casi todo sale de cuatro archivos, de los cuales el libro mayor es **el único que se puede
retirar sin mentir sobre el alcance**.

**Lo que esta regla NO es:** la regla general del campo —que declara el conjunto de **escritura**, ni más
ni menos, con el coste de cada uno de los dos errores— es **REQ-022 CA-07** y se escribe en su ventana.
Aquí sólo se retira del mapa una clase de artefacto que ninguna comisión escribe.

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

[[R-7 · obliga: analista, coordinadora, desarrollador, qa]]

## Cómo se escribe un criterio que no se desmiente

*(De dónde salen estas cuatro formas: `docs/explicacion/casos-medidos.md` § «Por qué existe la
sección».)*

Las cuatro están **prohibidas por nombre**. Un criterio que caiga en cualquiera de ellas está **mal
formado**: el QA lo reporta como hallazgo de clase `contrato` contra el REQ **antes** de ejecutar
la prueba, y quien lo reescribe es el analista (write-back, `AGENTS.md` §9).

### (a) Enumerar lo que el código reconoce

*(Caso medido: `docs/explicacion/casos-medidos.md` § «(a) Enumerar lo que el código reconoce».)*

- **Mal:** «Entonces se deniegan las formas envueltas en `if`, en `for` y en `{ }`.»
- **Bien:** «Entonces se deniega **todo token que el segmentador trate como envoltorio**, según la
  lista única de `hooks/guard-git.sh` (el `case` de prefijos del segmentador, que es el sitio del
  caso medido); ejemplos **no exhaustivos**: `if`, `for`.»

**Regla.** Un criterio que se refiera a un conjunto de cosas cuya pertenencia decide el código
—**cualquier** conjunto, sin excepción por el tipo de cosa que sea; ejemplos **no exhaustivos**:
envoltorios, prefijos, estados— enuncia la **propiedad de pertenencia**, **cita el
único sitio** donde vive la lista exhaustiva y, si añade ejemplos, los marca literalmente como
**«no exhaustivo»**. Un criterio que enumere **dos o más** elementos concretos sin (i) la marca
`no exhaustivo` **o** (ii) el puntero al sitio único está mal formado.

### (b) Fijar un número que la medición desmiente después

*(Caso medido: `docs/explicacion/casos-medidos.md` § «(b) Fijar un número que la medición desmiente
después».)*

- **Mal:** «Entonces el tope de reconstrucción es de 262 144 bytes.»
- **Bien:** «Entonces el tope de reconstrucción es de **no más de** 262 144 bytes (**operativo**:
  se **baja** con la medición).»

**Regla.** Todo criterio con un número declara **en el propio criterio** cuál de los dos es:

| Tipo del número | Qué significa | Cómo se cambia |
|---|---|---|
| **operativo** | Sólo su magnitud está en juego: nadie fuera del sistema elige su conducta por ese valor exacto (topes de reconstrucción, tamaños de buffer, tiempos límite internos). Se escribe con **dirección admitida**: «**no más de** N; se **baja** con la medición» | **Cambio menor:** entrada en el Historial del REQ con la cifra medida. **Sin** ADR y **sin** cambio de alcance |
| **de contrato** | Alguien de fuera elige su conducta por ese valor: un umbral que un proyecto declara en su manifiesto, un límite anunciado en una plantilla | **No** cambia sin **ADR** y sin **write-back** en las plantillas que lo anuncian |

**Un número sin esa declaración se trata como de contrato** (fail-closed): si no se sabe quién
depende de él, no se puede bajar en silencio.

### (c) Exigir igualdad donde corresponde un techo

*(Caso medido: `docs/explicacion/casos-medidos.md` § «(c) Exigir igualdad donde corresponde un
techo».)*

- **Mal:** «Entonces el hook gasta el **mismo** número de procesos que la versión anterior.»
- **Bien:** «Entonces el hook gasta **no más de** 0 procesos añadidos respecto a la línea base;
  **menos** es conforme y **no** es hallazgo.»

**Regla.** Todo criterio sobre **coste** —procesos, tiempo, bytes, lecturas— se enuncia como
**techo con la dirección admitida declarada**, y **nunca** como igualdad. Y un techo bien puesto
sobre la magnitud equivocada sigue sin ver nada: ésa es la forma (d), que viene justo debajo.

### (d) Fijar la magnitud equivocada

*(Caso medido: `docs/explicacion/casos-medidos.md` § «(d) Fijar la magnitud equivocada»; cita REQ-016
CA-08.)*

- **Mal:** «Entonces el hook gasta **no más de 0 procesos añadidos** respecto a la línea base.»
  (bien formado según (c), y ciego a un factor de diez en el reloj)
- **Bien:** «Entonces (i) **no más de 0 procesos añadidos** respecto a la línea base **y** (ii) el
  **mínimo** de reloj es de **no más de 1,25×** el de la línea base, medidas **las dos en la misma
  corrida** — el arreglo no vale si compra tiempo con un `fork`, y el `fork` no se ve en el reloj
  ni el reloj se ve en los procesos.»

**Regla.** Todo criterio de **coste** declara **qué magnitud mide y por qué es ésa la que se
degrada**; si el mecanismo puede degradarse por más de una vía, **contrata todas las vías en el
mismo criterio y en la misma corrida** —dos magnitudes en dos criterios distintos se cumplen por
separado mientras el sistema empeora—. Y se enuncia como **razón o propiedad estructural**, **nunca
como un reloj absoluto**: un número de segundos lo falsea la máquina, lo falsea el runner del CI y
lo falsea la carga. Donde haga falta un absoluto, va como **razón contra una línea base medida en
la misma corrida**, no como una cifra: un runner lento sube el numerador y el denominador.

**Cómo se contrata una magnitud que no miente:**

| Lo que se quiere saber | Cómo se contrata | Por qué no miente |
|---|---|---|
| ¿El coste crece más que linealmente? | **Cociente de duplicación**: doblar la entrada y comparar los dos costes. Lineal ≈ 2, cuadrático ≈ 4 | La velocidad de la máquina **se cancela algebraicamente**: está en el numerador y en el denominador |
| ¿Cuesta más que antes? | **Razón contra una línea base medida en la MISMA corrida** (un tag anterior, la implementación previa) | Un runner lento o cargado sube los dos términos; la razón no se mueve |
| ¿Cabe en un límite duro de fuera (un `timeout`, una cuota)? | Se **mide y se anota** el margen; **mover** el límite es otro REQ con su dueño | El límite no lo elige este sistema, así que el criterio no puede fijarlo: sólo puede medirlo |

**El estadístico es el MÍNIMO de k repeticiones, nunca la media**, y k se elige para que el mínimo
de cada serie supere el suelo por debajo del cual el reloj no distingue del ruido (en este arnés,
50 ms). La carga sólo puede **añadir** tiempo, así que el mínimo es la mejor estimación del coste
real y la media es una mezcla del coste y de los vecinos. Y **una sonda que no llega a ese suelo, o
que no encuentra su línea base, emite SKIP con el motivo y con el número que sí obtuvo — nunca
PASS**: un instrumento que ante la ausencia de datos responde «verde» es la misma familia de
defecto que la magnitud equivocada.

### Cuando el código cubre MÁS de lo que el criterio promete

El criterio se actualiza **en el mismo cambio que lo descubre** —con entrada en el Historial
(antes → después) y la causa—, y **no** se deja para un hallazgo posterior. Un criterio **más
laxo** que lo construido programa un debilitamiento silencioso; uno **más estrecho** convierte una
capacidad en un hallazgo `contrato`. El reverso general de esta regla —la deriva— vive en
`AGENTS.md` §9.

### Y el reverso, para que esto no sea una coartada

Cuando el código **no** cumple el criterio, **no se relaja el criterio para que encaje**: se abre
el hallazgo **contra el código**. La regla de arriba aplica **sólo** cuando el código cubre
**más**. Ampliar un criterio para tapar una carencia es exactamente lo que `AGENTS.md` §9 llama
**deriva**, y esta sección no puede convertirse en su coartada.

### Dónde se anota la forma del hallazgo

La **forma** (`enumeración` · `número` · `igualdad` · `magnitud` · `otra`) se anota **sólo** en el log de QA
(`docs/qa/<versión>.md`), y **nunca** dentro del paréntesis de la clase del campo `Hallazgos
abiertos:`. Ese paréntesis es lo que lee `guard-completado` para decidir si un hallazgo bloquea:
meterle una segunda dimensión cambiaría la entrada de la puerta por un motivo de contabilidad.

### La clase, el forzador y el vencimiento se CITAN con archivo y línea; no se declaran

**Regla.** Un REQ que mencione un hallazgo —propio o ajeno— **cita** su clase, su forzador y su
vencimiento con **archivo y línea** del sitio único donde viven (`docs/seguridad/registro-seguridad.md`
para los `SEC-xxx`; el registro de QA para los suyos), y **no** los transcribe como si el REQ los
declarara. Dos transcripciones de la misma regla se desfasan, y ésta se desfasa hacia el lado que
**abre**: un REQ que diga `instrumento` sobre un hallazgo que el registro tiene como `contrato` cambia
la entrada de `guard-completado` por un motivo de redacción. Si las dos no coinciden, la equivocada es
la del REQ.

**La excepción, que no es una grieta: el campo `Hallazgos abiertos:` SÍ declara la clase.** Es la
entrada de la puerta, y una cita no se puede leer por máquina (ver «Clases de hallazgo»). La regla rige
para la **prosa** del REQ —criterios, notas, alcance—: el campo es el único sitio del REQ donde la clase
se escribe como **valor**, y ese valor tiene que **coincidir** con el sitio único.

**Y la forma (a) en pequeño, con su caso medido:** una cláusula del auditor citada **sin su calificador**
—las tres condiciones eran «formas **no exhaustivas**… la propiedad es la que decide, no la lista»— se
lee en el REQ como una lista cerrada de tres, y envejece hacia el lado que abre
(`docs/seguridad/registro-seguridad.md:4444-4453`). Citar con el rango es lo que lo evita.

**De dónde sale, y es la regla aplicada a sí misma:** es la deuda **`R-015-01`**, cuya clase, dueño,
forzador y vencimiento viven en `docs/seguridad/registro-seguridad.md:4461-4468` y **no se transcriben
aquí**. Mismo alcance temporal que el resto de esta sección: rige hacia delante.

### Alcance temporal

La regla rige para todo criterio **escrito o modificado desde que esta sección se adopta**. Los
REQ en estado `completado` **no** se reabren ni se reescriben para conformarlos: reescribir
contratos cerrados por un motivo de redacción es editar el contrato por comodidad, y multiplica el
coste que esta sección existe para bajar.

La forma **(d)** se incorpora con **el mismo alcance temporal** que las tres anteriores: rige para
los criterios escritos o modificados desde la ventana en que se adopta, y no reabre ninguno de los
ya cerrados.

### En la Definition of Ready del analista

Un REQ no se entrega como `pendiente` si alguno de sus criterios habla de **coste** sin decir **qué
magnitud mide y por qué es ésa la que se degrada**, o si lo fija como un **reloj absoluto** en vez
de como una razón o una propiedad estructural. Es la línea que añade la forma (d), y se comprueba
en la misma revisión humana que el mapa de archivos: ninguna de las dos es una comprobación de
runtime.


**En este repositorio la sección se adopta en 1.32.0** (REQ-012): rige para los criterios que se
escriban o modifiquen desde esa ventana, y los ocho REQ ya `completado` quedan **idénticos**.
**La forma (d) se adopta en 1.33.0** (REQ-017), con el mismo alcance: `CA-08` de REQ-016 —el caso
medido que la origina— **no** se reescribe, porque REQ-016 está `completado` y se cumplió tal como
estaba escrito. Ése es justamente el punto.
**La regla de «se citan, no se declaran» se adopta el 2026-09-08**, con el mismo alcance y sin dueño de
REQ: es doctrina del proyecto, no un criterio de ninguno. Ningún REQ se reescribe para conformarlo.

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

[[R-10 · obliga: analista, coordinadora]]

## Índice

> **Este índice es una copia a mano de campos que viven en la cabecera de cada REQ, y por eso se
> desfasa solo.** Sólo mandan los campos del propio REQ; si una celda de aquí los contradice, la
> equivocada es la celda. Se ha desfasado tres veces en un solo día de trabajo, así que está previsto
> convertirlo en un bloque **derivado** entre marcadores, como el de `docs/ESTADO.md`, y dejar de
> mantenerlo a mano. Mientras tanto, **no cites este índice como fuente**: abre el REQ.

| ID | Título | Estado | Rigor | QA | Seguridad |
|---|---|---|---|---|---|
| [REQ-001](REQ-001.md) | Dos bypass del enforcement en v1.30.2: cierre sustituyendo sólo el valor, y sustitución de comandos en heredoc sin citar. **Reabierto el 2026-09-30** (§9): CA-10, CA-11 y CA-12 versionados por **ADR-015** (SEC-117); sus firmas anteriores cubren sólo el contrato anterior | `en-revisión` | critico | aprobado (2026-09-30, cd47f06) | aprobado (R-047, 57129fb) |
| [REQ-002](REQ-002.md) | Veredicto fechado y no caduco: una firma no vale sobre código que cambió después | `completado` | critico | aprobado | aprobado |
| [REQ-003](REQ-003.md) | Un solo lector y un solo vocabulario: `con-hallazgos` en Seguridad, aviso al escribir fuera del vocabulario, y el informe que lee como la puerta | `completado` | critico | aprobado | aprobado |
| [REQ-004](REQ-004.md) | Rotación de UNA sección del documento: la historia se archiva, el contrato no se toca | `completado` | critico | aprobado | aprobado |
| [REQ-005](REQ-005.md) | Git destructivo prohibido a los agentes: el trabajo de un subagente no es atómico para git | `completado` | critico | aprobado | aprobado |
| [REQ-006](REQ-006.md) | Celdas del bloque derivado recortadas: un veredicto de 1 296 caracteres no cabe en una tabla | `completado` | critico | aprobado | aprobado |
| [REQ-007](REQ-007.md) | Huecos preexistentes del lector de campos, del detector de Bash y de las dos puertas de runtime, medidos en la QA y en la auditoría de seguridad de REQ-001: clave decorada, cabecera fuera de alcance, destino entrecomillado, heredocs que ciegan el detector, la clase del hallazgo en forma cerrada, bytes de control en banda, la barra duplicada que desactiva las dos puertas, el manifiesto inválido que apaga el enforcement en silencio, el manifiesto fuera de su propia frontera y la reconstrucción sin techo. **Versionado el 2026-09-30:** CA-46 (c) por ADR-015, y por **ADR-016** (quinta autorización) CA-45 a CA-50, CA-60 y CA-66 nuevo —las puertas juzgan el **archivo** que la escritura alcanzaría y no la forma de su ruta, y un REQ que la puerta no puede leer entero no se edita (SEC-119, O-11)—, en 1.35.0; **P-119-A** (fronteras no nombradas por el propietario), sin bloquear la implementación, **resuelta el 2026-10-03 como límites declarados**: F2, F5 y F7, y SEC-123 con F3 corregida, abiertos y **no aceptados como riesgo**, sin versión de reparación fijada; el REQ ya no tiene preguntas abiertas. **Versionado el 2026-10-01** (sexta autorización): CA-47 gana la **integridad de la entrada** —cada campo se lee entero— y dos causas de «no determinable» (un `file_path` o un `tool_name` con salto de línea), CA-45 lo comprobado en el host, CA-54 la nota de su incumplimiento abierto (QA-023-10) y CA-66 sus casos. **Versionado el 2026-10-02** (séptima autorización, QA-023-13): el retorno de carro del `tool_name`, el `cwd` y el `file_path` se cuenta antes del transporte —un `cwd` con retorno de carro no ancla y la ruta relativa es no determinable; un `file_path` o un `tool_name` con retorno de carro, como con salto de línea—, el del texto de `Bash` queda declarado como límite sin proteger (**P-023-13-A**, resuelta después por la octava autorización) y CA-66 gana el bloque R. **Versionado el 2026-10-02** (octava autorización: SEC-122, QA-023-14, P-023-13-A): F3 corregida —ningún directorio, tampoco `/dev/` ni `/proc/`, queda fuera de la identidad del destino—; lo que depende del proceso que abre la ruta se detecta y, si no se puede determinar, no pasa; la entrada se lee cruda y el texto de `Bash` llega con sus retornos de carro; un heredoc con un retorno de carro en el delimitador se deniega; CA-66 gana la sección 45 y una clase de movimiento de `deny` a `allow` declarada; tras la pasada correctiva, `guard-git` juzga cada orden también sin sus retornos de carro y la ruta de un enlace a un descriptor se juzga por las tres vías (QA-023-16, QA-023-17 y **P-122-A**, resuelta por reparación). **Versionado el 2026-10-03** (novena autorización, fase 1, SEC-123): F3 y el punto 16 de CA-47 describen el límite de la detección de lo que depende del proceso con su umbral por propiedad, lo medido, lo inferido y su consecuencia —puede ser un permiso sobre un archivo protegido—, sin repararlo ni aceptarlo (en **P-119-A**, hoy resuelta como límite declarado, no aceptado como riesgo). **Versionado el 2026-10-03** (novena autorización, fase 2, SEC-124 y SEC-125; **construido en `10ac6c4` y `36a0d27`; validado por el propietario por vía manual (`docs/qa/REQ-023.md`, CI run 37163342218); sin firma del qa-tester ni del auditor-seguridad por impedimento del proveedor**): CA-47 gana el punto 18 —un heredoc cuyo cuerpo tiene una línea que es su delimitador seguido de un retorno de carro, con algo detrás, se deniega por su forma, a todo agente y con un motivo que nombra SEC-124: restricción concreta decidida por el propietario (opción B)— y el punto 19 —el destino tras una continuación de línea se juzga como el que escribe el shell, sin denegar por la mera continuación, salvo una excepción nombrada que decidió el propietario (P-LC10-A, opción A): la continuación al final de la línea que abre un heredoc se deniega por la forma, a todo agente, en las cuatro puertas, con un motivo que nombra SEC-125 y LC10—; CA-66 gana sus casos, movimientos (una clase nueva de `deny` a `allow`, la de SEC-125) y coste. **Versionado el 2026-10-03 en la apertura de 1.36.0** (pedido del propietario, «Encargo 2»; **sin construir**), en su orden de prioridad: la nota de **CA-54** fija cómo se acredita QA-023-10 —< 5 s en el máximo en Linux/WSL2 con las sondas existentes, la misma decisión que v1.35.0, ningún veredicto del banco cambiado (inventario caso a caso) y sin subir el umbral ni reducir la entrada—; **CA-47 punto 20** (SEC-120: una entrada que `jq` no puede leer o trocear deniega; ilegible es todo lo que no sea exactamente un objeto JSON; 0 procesos añadidos sobre el camino común —medido +0, y +1 en una entrada ilegible, el de emitir la decisión—; sin `CLAUDE_PROJECT_DIR` es inerte si no puede obtener el proyecto y deniega si del `cwd` de la entrada obtiene uno con manifiesto, límite declarado —decisiones del propietario del 2026-10-05, la última P-136-H—; la entrada estándar cerrada, pendiente hasta SEC-127 y no límite, P-136-I, QA-007-06); y el **Bloque L** —**CA-67** (SEC-118: toda denegación decidida se emite), **CA-68** (SEC-115: un hook que no termina a tiempo emite `deny`) y **CA-69** (evidencia común, línea base v1.35.0)—, con **ADR-017** (aceptada el 2026-10-03) y las decisiones del propietario **P-136-A a P-136-C** (décima autorización, 2026-10-03) y **P-136-D** (2026-10-05: CA-54 (c) aclarada, atajo de `guard-completado` con condición de equivalencia), resueltas en `PENDING_APPROVAL.md` § Resueltas. **P-136-F** (2026-10-05, opción C): el candidato de CA-54 es `82ceb63` (`dee5932` revertido en `74da4c5`); **QA-007-02 cerrado por reversión** (ficha F-136-5 de la recursión); CA-54 se cumple en sus 35 corridas y las formas de **QA-007-01** quedan fuera del criterio como **límite declarado**, con su clase `contrato` sin cambiar. **P-136-J y P-136-K** (2026-10-06): CA-47 punto 20 gana que, en `guard-codigo`, un `file_path` que no es texto no deja pasar a nadie, tampoco al agente de código (SEC-128, sin reparar), y que SEC-127 se acredita con LO1 a LO4 y LK de la sección 47 y la lectura del código, con la prueba en bash 5.0 o anterior en modo POSIX declarada no medida; O-52-3, ficha F-136-7. **Versionado el 2026-10-06** (paso 6, fase 0; P-136-L y el punto 4 del resumen del plan del propietario): **CA-68** gana la propiedad de **SEC-129** (texto de R-054 §5): sólo un juicio concluido deja sin decisión, y ninguna decisión depende del modo del intérprete heredado —`POSIXLY_CORRECT`, `SHELLOPTS`, `BASH_ENV` con `set -o posix`, `bash --posix`, ejemplos no exhaustivos—. Se mide con la matriz de R-054 y fail-before contra `78a2f33` y v1.35.0. QA-007-07 queda pendiente de **P-136-N**. CA-68 gana también dónde no puede caer un techo de tamaño, con parada si SEC-115 lo exige. **CA-69 punto 7** fija E1 a E3, la regla de «afecta» frente a REQ-017 CA-09 y la comprobación de SEC-130 por QA. ADR-017 lleva una nota posterior. **Sin construir** en la fase 0. **Paso 6, fase 2** (2026-10-06): CA-67 y CA-68 **construidos en `0efd3c2`, SIN VALIDAR por QA** —el motivo y los avisos van por la entrada estándar y se acotan a 16 384 bytes; plazo propio de 30 s, que responde en no más de 40; `hooks/entrada.sh` con R1 y la trampa de salida; R2—. CA-69, punto 7: E1 a E3 medidos, «no afecta». SEC-130 no queda cubierto por R2 (F-136-12). **P-136-O y P-136-N** (2026-10-06, resueltas por el propietario): los techos de tamaño quedan como **cambio de compatibilidad declarado** en CA-68 y CA-69, punto 3 —el `Write` de un REQ de más de 393 216 bytes y el `Edit` cuyo producto de búsqueda pasa de 2³² (sobre `REQ-007.md`, `old_string` de 7 000 bytes o más) pasan de «sin decisión» a `deny`; se parte la edición—, con nota posterior en ADR-017 y párrafo en la guía; CA-68 (ii) se amplía a **todo lo heredado del entorno**, con `ARNES_INPUT_LISTO` y `ARNES_MANIFEST_LISTO` (QA-007-07) y un caso de banco por variable; CA-69, punto 7, gana la observación de QA del FAIL de la sección 24 (hallazgo si lo reproduce; si no, INS-136-3). **QA del paso 6** (2026-10-06, write-back de estado sólo de lo que no depende de P-136-P): **QA-007-07 construido en `8e11f87` y validado por QA** —las dos marcas se vacían al cargar `lib.sh`; sección 47 95/0 con su fail-before—; **QA-023-10 cerrado por QA en su medición** (35 corridas sobre `82ceb63`, P-136-F); la sección 24 no reproduce el FAIL en 16 corridas, **INS-136-3**; SEC-130 no queda cubierto por R2, medido, y sigue F-136-12; punteros de `hooks/lib.sh` corregidos a `8e11f87`. **P-136-P** (2026-10-06, resuelta por el propietario): el FAIL de E2 de QA (1 en 6, 0,962×, E1 sin cambio) **no es «afecta»** —la regla sigue; QA-007-08 pasa a instrumento, **INS-136-4**; REQ-017 no se reabre; F-136-8 se amplía a CA-09—; CA-68 declara dos **límites** —**QA-007-09** (un REQ con CRLF en disco de 3,6 MB o más deja sin decisión el `Edit` que lo cierra; F-136-18) y **QA-007-11 (b)** (`noexec`, `onecmd` y `xtrace` heredados, no neutralizables desde el hook; F-136-19)—, ni aceptados ni reparados; **QA-007-10**, **QA-007-11 (a)** y **QA-007-12** quedan en la pasada correctiva —**construidos en `03cbf5e`; validados y cerrados por QA** en la re-verificación (2026-10-07, evidencia `6cf1ba0`); seguridad, pendiente—. **P-136-Q** (2026-10-07, resuelta por el propietario): la parte de `builtin` de **QA-007-13** (regresión de `03cbf5e`: sin decisión, o 60 s y rc 124 en cualquier llamada) queda en CA-68 (ii) con la técnica del propietario y un caso de banco (`ls -la` sin decisión en < 5 s, operativo), **construida en `39e6128` y validada y cerrada por QA** (`84fbf80`); CA-68 amplía sus **límites declarados** con **F-136-20** —funciones importadas `.` y `[` antes de `hooks/entrada.sh`, y `SHELLOPTS` con `errexit`; `BASH_ENV`, ya cubierto—, ni aceptados ni reparados. **P-136-R** (2026-10-07, resuelta por el propietario): **QA-007-14** (los builtins especiales que el hook usa, fuera de la lista estática; regresión de `39e6128`) queda en CA-68 (ii): la lista cubre los builtins que el hook usa, **regulares y especiales**, con un caso de banco (`return` y `break` exportadas, decisión en < 5 s, operativo), **construida en `c5bf6d4` y validada y cerrada por QA** (`c4afbde`); F-136-20 gana su punto (v), `BASH_FUNC_set%%` en los guardianes sueltos. **Tras R-056** (2026-10-07, write-back de estado sólo de lo que no depende de P-136-S): CA-67, CA-68 y CA-69 punto 7 **construidos en `c5bf6d4`, validados por QA** (`c4afbde`, favorable para el código del paso 6); R-056 conforme sin veto: **SEC-115, SEC-118 y SEC-129 `mitigado` en el candidato**, con sus residuales (QA-007-09, SEC-132, Windows y el host sin medir; F-136-9/19/20 y SEC-131); F-136-20 (i) corregida —con una función `[` que imprime un `allow`, `allow` explícito—; O-56-3 como «no acredita» de CA-67; SEC-130 con su texto final (`instrumento`, F-136-12, no alcanzable desde fuera); la firma de seguridad del REQ no procede todavía. **P-136-S** (2026-10-07, resuelta por el propietario): **SEC-132 (a)** —el plazo comprobado entre quality gates y, por **P-136-T (B)**, la gate en curso acotada e interrumpida— se reparó en una pasada acotada (`cd63066`) que **P-136-U (A)** (2026-10-07) **revirtió** por QA-007-15 (una gate roja podía cerrar el REQ), QA-007-16 y QA-007-17: SEC-132 (a) queda en CA-68 como **límite declarado** de 1.36.0 (cuatro gates de 20 s o una gate colgada, sin decisión a los 60 s y el cierre se aplica, igual que en v1.35.0: 1.36.0 no cambia ese caso, SEC-134), con tres lecciones de diseño y ficha F-136-22 para 1.37; CA-69, punto 3, **retira** su movimiento; la pregunta abierta resuelta por P-136-T, anotada como superada; CA-68 amplía sus **límites declarados** con **SEC-131** (F-136-21: función con el nombre de la orden de una gate, `ulimit -n` 4–5, `PATH`) y **SEC-132 (b)** (F-136-22: líneas `Hallazgos abiertos:` repetidas en disco), ni aceptados ni reparados; write-back autorizado de `AGENTS.md` §13 y su plantilla —SEC-115 y SEC-118 `mitigado` con sus residuales, filas de CA-68 (ii) y SEC-120— y de `requirements/README.md` y su plantilla. **QA-007-18** (2026-10-07, write-back): en CA-47 p. 20, V4 es control **sólo con un `jq` que lea 9 000 niveles** (1.8.2 sí; 1.7.1, el del CI, no: lee hasta 254); si no, V4 es ilegible, el hook deniega por eso y el banco lo registra como SKIP con motivo que exige ese `deny`; con jq 1.7.x el fail-open de SEC-120 en v1.35.0 se alcanza desde 255 niveles; CA-69 p. 2 anota que ninguno de los 34 SKIP del CI acredita. **P-136-V** (2026-10-07, resuelta por el propietario): **SEC-133** —una quality gate que lee su entrada estándar se come la lista de las gates siguientes, y el cierre puede salir sin decisión con una gate posterior en rojo; preexistente, igual en v1.35.0— queda en CA-68 como **límite declarado** de 1.36.0, ni aceptado ni reparado, con ficha F-136-23 para 1.37 (lecciones L4 y L5 de R-057); la fila «No completar un REQ con quality gates en rojo» de `AGENTS.md` §13 y su plantilla, acotada a lo que no cubre (SEC-133 y SEC-131 (a)) y su consecuencia. Desde 2026-10-12 (F-136-17), su historia anterior a v1.36.0 vive verbatim en `docs/historia/REQ-007/`, con un puntero por bloque; los criterios y sus notas vigentes siguen en el REQ | `en-progreso` | critico | pendiente | pendiente |
| [REQ-008](REQ-008.md) | Informe de proyecto: avance medido, qué lo detiene y qué decide un humano, como evolución de `arnes-panel` y con el lector de la puerta | `pendiente` | critico | pendiente | pendiente |
| [REQ-009](REQ-009.md) | Una sola regla para contar la cola de aprobaciones: la puerta dice 1 y el bloque derivado dice 4 sobre la misma entrada | `completado` | critico | aprobado | aprobado |
| [REQ-010](REQ-010.md) | El acento no es parte del valor: `en-revision` y `en-revisión` son el mismo estado para la puerta, el informe y el bloque derivado | `completado` | critico | aprobado | aprobado |
| [REQ-011](REQ-011.md) | La puerta que pregunta DESPUÉS: el estado terminal reconstruido entre dos expansiones sale allow, y preguntar antes no cierra la clase | `pendiente` | critico | pendiente | pendiente |
| [REQ-012](REQ-012.md) | Criterios por mecanismo, no por enumeración: siete de veinte hallazgos del ciclo 2 fueron que el criterio decía algo falso sobre lo construido | `pendiente` | critico | pendiente | pendiente |
| [REQ-013](REQ-013.md) | Paralelizar por REQ con un mapa explícito de archivos: el ciclo 2 corrió en serie porque nadie podía decir qué dos comisiones no colisionan | `en-revisión` | critico | con-hallazgos | con-hallazgos |
| [REQ-014](REQ-014.md) | El banco en archivos por sección: un `run.sh` de 4 096 líneas impide que dos agentes de QA trabajen a la vez y obliga a leerlo entero en cada comisión. **REABIERTO el 2026-09-08** (§9): `CA-18` era insatisfacible y `CA-12` ya no discriminaba; los dos `aprobado` son del 2026-09-06 y quedan **invalidados** | `en-progreso` | critico | aprobado | aprobado |
| [REQ-015](REQ-015.md) | Publicación concurrente sin pérdida: el temporal de nombre fijo destruyó texto humano de `docs/ESTADO.md` con dos paradas a la vez | `completado` | critico | aprobado | aprobado |
| [REQ-016](REQ-016.md) | La cabecera tiene noción de cita: un veredicto citado dentro de un comentario HTML cerró un REQ crítico sin auditoría aprobada | `completado` | critico | aprobado | aprobado |
| [REQ-017](REQ-017.md) | El coste que ningún criterio miraba: la guarda del CR es cuadrática en la longitud de línea, y CA-08 dio verde midiendo procesos sobre una regresión de 10× de reloj | `completado` | critico | aprobado | aprobado |
| [REQ-018](REQ-018.md) | El canal por el que un proyecto reporta defectos DEL arnés: issues en el repo público con **gramática restringida** — sin campo donde quepa el nombre del proyecto, no hay decisión que tomar en caliente. **Ventana 1.34.0** | `borrador` | critico | pendiente | pendiente |
| [REQ-019](REQ-019.md) | Adelgazar los **dos** documentos de arranque —`AGENTS.md` y `requirements/README.md`— sin perder una sola invariante: se adelgaza **moviendo**, no reescribiendo, porque no se puede perder una regla que nadie borró. **Ventana 1.34.0, primer trabajo**; 9–11 comisiones en 7 fases | `pendiente` | critico | pendiente | preventiva |
| [REQ-020](REQ-020.md) | ¿Esta prueba mide algo? Cuatro formas de estar verde sin haber medido — el caso vacío, el que no se ejecuta, el que sólo fija lo que hoy falla y el universo encogido en silencio. **Ventana 1.34.0**: depende de las sondas de REQ-021 | `pendiente` | critico | pendiente | pendiente |
| [REQ-021](REQ-021.md) | `tests/util/` con las sondas de reloj y de procesos, escritas una vez: se reconstruyen en cada comisión y dos se rompieron a la primera, una dejando un proceso vivo 3 h 41 min. Alcance reducido el 2026-09-08 (la sonda de línea base queda fuera). **BLOQUEADO el 2026-09-08**: agotó las 3 vueltas dev↔QA sin cerrar `QA-021-10` (`contrato`), y el propietario lo movió a **1.34.0** | `bloqueado` | critico | con-hallazgos | preventiva |
| [REQ-022](REQ-022.md) | Despacho en paralelo: tres dimensiones de colisión y la herramienta sólo ve una. Bloque de apertura de **1.34.0** | `pendiente` | critico | pendiente | pendiente |
| [REQ-023](REQ-023.md) | Una clave de control escrita de otra forma, o declarada dos veces, no se convierte en ausencia: la **cabecera ambigua no deja cerrar** (mitad 1 de SEC-047). **Ventana 1.35.0**, autorizada por el propietario el 2026-09-29; versionado por **ADR-014** (frontera por esqueleto ASCII de la clave y estructura de la declaración; **cambio de compatibilidad**: una clave repetida deniega aunque diga lo mismo; claves de más de 256 bytes, **limitación** no protegida). Ya no depende de las sondas de REQ-021 ni del gate de SEC-048. Tope dev↔QA agotado (3 de 3); vuelta excepcional agrupada de la tercera y la cuarta autorización (2026-09-29 y 2026-09-30): QA-023-06 y **CA-13** (SEC-117, **ADR-015**); en la de la quinta (2026-09-30), **CA-13 (iv)** remite a REQ-007 CA-45 y CA-47 (**ADR-016**) | `en-revisión` | critico | aprobado | aprobado |
| [REQ-024](REQ-024.md) | La ausencia de un campo no se resuelve del lado que abre, y el mismo estado en el segundo lector: la cola que cuenta cero sobre lo que no pudo medir. **Ventana 1.34.0**: va después de REQ-023, con el que comparte nueve rutas | `borrador` | critico | pendiente | pendiente |
| [REQ-025](REQ-025.md) | El arnés vigila también a quien orquesta: la sesión coordinadora acredita, decide y publica, y ninguna puerta la mide. **Ventana 1.35.0**; línea base = 20 errores de coordinación catalogados. Tras la **partición del 2026-09-21** conserva **la entrega 1** —las **seis reglas** del propietario en `AGENTS.md` §6, su gemela, las dos sedes de `PENDING_APPROVAL`, la entrada de `arnes-upgrade` **preparada, no publicada** (publicada con v1.35.0 el 2026-10-03), las referencias en los agentes y el **ADR-008**— y, desde el mismo día, una **entrega 1b `pendiente` dentro del propio REQ** (CA-01, CA-02, las preguntas 1, 2 y 4 de CA-09 (B), la regla del `git add -A` y la primera mitad de CA-10), **sin ventana asignada**: **aprobar la entrega 1 no completa REQ-025**. Vuelta **1 de 3** consumida (QA `con-hallazgos`, R-1) | `en-progreso` | critico | con-hallazgos | pendiente |
| [REQ-028](REQ-028.md) | Las capacidades que REQ-025 difiere (**entregas 2+**): `tools/arnes-comprobar.sh` con par discriminante y denominador, su sección del banco, la **procedencia y la atribución** de la cifra que llega al `CHANGELOG.md`, las **columnas de instantes** del libro de comisiones y los umbrales de coste. Nace de la **partición de REQ-025** (2026-09-21) conservando los identificadores CA-03…CA-08, CA-12 y las mitades de CA-10, CA-11 y CA-13. `borrador` con **cuatro decisiones del propietario abiertas** (B-1…B-4) y **sin ventana asignada** | `borrador` | critico | pendiente | pendiente |
| [REQ-029](REQ-029.md) | Fidelidad al encargo: detectar omisiones, sustituciones y decisiones de negocio no autorizadas antes de implementar — fuente identificable del pedido, «Correspondencia con el encargo» en la plantilla, comprobación de resolución antes de despachar, **un solo veredicto de QA**, sin bloqueo retroactivo, y la partición que no concede autoridad sobre el alcance. **Ventana 1.35.0**; decisión del propietario del 2026-09-23 sobre la propuesta `d4e7a4f`; integrado en `main` por el PR #53 (`11c5df2`) y cerrado administrativamente el 2026-09-27 sin acreditar conducta ni ahorro | `completado` | critico | aprobado | aprobado |
| [REQ-030](REQ-030.md) | Las sondas de coste CA-03 y CA-08 (ii) de REQ-017 deciden sobre un **presupuesto fijo de 5 repeticiones** y dicen **INCONCLUSO** (rendimiento no acreditado, contado en el resumen) cuando no resuelven: los techos no se mueven. Versiona REQ-017 por **ADR-012**; autorizado por el propietario el 2026-09-26. **Ventana 1.35.0**; vuelta 4 y dos intervenciones documentales por excepción expresa del propietario (2026-09-26); integrado en `main` por el PR #55 (`c4d92c0`) y cerrado administrativamente el 2026-09-27 con QA-030-03, QA-030-05 y SEC-111 (`instrumento`) abiertos, sin acreditar rendimiento | `completado` | critico | aprobado (re-verificación documental, 0f7e668) | aprobado (R-043-B, 192d7b6) |
| [REQ-031](REQ-031.md) | Ningún hallazgo bloqueante se ignora por su posición ni por su separador: sintaxis **cerrada** de `Hallazgos abiertos:` en `guard-completado` (A), y el mapa `Archivos:` comprobado desde la Definition of Ready antes de pedir paralelismo (D). **Ventana 1.35.0**; pedido del propietario del 2026-09-27. **P-1 resuelta (opción B)**: tras el paréntesis de un hallazgo sólo la coma o el fin del campo; versiona REQ-007 CA-41 por **ADR-013**. Vuelta 2: clave repetida deniega (SEC-112, CA-A12; su limitación conocida, aparte, es SEC-118: nota del 2026-09-29), techo de 16 384 bytes —deniega por encima; su limitación, SEC-115, va aparte (nota del 2026-09-30)— y acceso de coste constante (CA-A13/A14). **Vuelta 3 de 3 (última)**, autorizada por el propietario el 2026-09-28: el techo se mide **antes** de normalizar (SEC-113 remedio B, CA-A15), reproducción aislada de un hook sin decisión (CA-A16) e inventario de claves ignoradas (CA-A17); la parte de §13 / R-024 nació de una **atribución equivocada**: esa celda es de `rel/registro-1.33.0` (`1154417`), no de `main` (Preguntas abiertas) | `en-revisión` | critico | aprobado (2026-09-30, cd47f06) | aprobado (R-047, 57129fb) |
| [REQ-032](REQ-032.md) | **Hotfix 1.36.1 (F-137-10):** un destino de `cp`, `mv` o `install` que existe y es archivo se juzga como archivo (desde 1.35.0 se denegaba a quien no es el agente de código). Fail-before contra v1.36.0, controles que no se mueven y una sola clase de movimiento de `deny` a `allow` (M-032). Autorizado por el propietario el 2026-10-13; contrato cerrado el 2026-10-14 con **P-032-1 (A)** (un directorio se juzga como `directorio/`, como hoy) y **P-032-2 (A)** («archivo» = archivo regular tras la identidad de CA-47; un enlace a uno cuenta como ese archivo). **Write-back de QA-032-01 el 2026-10-15** (P-032-3 (A)): **CA-15**; F-137-14 (preexistente, a 1.36.2) declarado como límite. **Write-back de QA-032-02 el mismo día** (P-032-4 (B) y P-032-5 (C)): CA-15 como **lista de lo que se acepta** —la forma `destino/` sólo deja de juzgarse si el **comando entero** es una sola invocación literal de `cp`/`mv`/`install`, sin caracteres de shell, con opciones de una lista cerrada (`-t`, `-T` y `--` fuera) y sobre un destino de **un solo enlace**; si no, la decisión de v1.36.0—; restricciones declaradas (G1, `cp -T`, formas encadenadas, prefijos); **vuelta 2 de 3, la última**: si no cierra QA-032-01, 1.36.1 no se publica. **La vuelta 2 los cerró** (QA aprobado; R-059 sin veto). **Fase 4 (write-back de R-059 y P-032-6):** SEC-135 (`contrato`, alta) se repara en 1.36.2; SEC-136 (`contrato`, media), en 1.36.2 el origen de `mv` y `.arnes/config.json`, y en 1.37 `rm`/`unlink`/`git rm`; V7 `instrumento` respecto de este REQ; borrador de notas en `docs/arnes/notas-1.36.1-borrador.md` | `completado` | critico | aprobado | aprobado |
| [REQ-033](REQ-033.md) | **Hotfix 1.36.2 mínimo:** borrar, mover o vaciar `.arnes/config.json` **por las formas llanas de `Bash` o un `Write` sin contenido** se deniega a todo agente, y el origen de `mv` se juzga como escritura. SEC-135 a SEC-138 declarados en las notas, a 1.37. Una pasada correctiva. Autorizado el 2026-10-16 (P-137-J) | `completado` | critico | aprobado | aprobado |
| [REQ-034](REQ-034.md) | **1.37 · 1, rigor proporcional por defecto:** lo normal va por el flujo ligero y el completo queda para dinero, sesión, seguridad, datos y el propio arnés; política en `.arnes/config.json` del proyecto, aplicada por el analista al nacer el REQ; la puerta no cambia. Autorizado el 2026-10-16 (P-137-L). Decisiones de flujo ligero, defecto sin mapeo y «sesión» resueltas (P-137-M, 2026-10-16). **Completado** el 2026-10-21 (excepción única de P-137-Q, sólo borrado) | `completado` | critico | aprobado | aprobado |
| [REQ-035](REQ-035.md) | **1.37 · 2, modelo por rol y sondas de reloj:** una sonda de coste que pasa su techo da INCONCLUSO; plazos, procesos y veredictos siguen en FAIL (inventario en `docs/arnes/v1.37.0-inventario-sondas-reloj.md`); regla de modelo por rol en `AGENTS.md` §5, plantilla y las cuatro definiciones. Autorizado el 2026-10-21 (P-137-R). **Completado** el 2026-10-21 | `completado` | critico | aprobado | aprobado |
| [REQ-036](REQ-036.md) | **1.37 · 4a, adelgazar lo que lee el analista:** de ≈ 138 KB a < 70 KB, con la conducta de PC-034-1 4/4; lo explicativo a `docs/explicacion/` con punteros; `arnes-upgrade` con diff previo; regla de `Edit` (PR-137-1/2) y F-137-19. Autorizado el 2026-10-21 (P-137-W). Q-036-1 resuelta (P-137-X (D)): lectura por destinatario, hasta 75 KB con 4/4. P-137-Y (A), 2026-10-26: `CLAUDE.md` sin import de `AGENTS.md` (CA-16), hook `SessionStart` (CA-17), CA-02 con `claude -p` aislado; toca `hooks/`. P-137-Z (A), 2026-10-26: lectura por rol generada y comprobada byte a byte (CA-18), hueco de `Seguridad:` en ámbito alcanzado (CA-19), CA-02 medida en USD por corrida con tope (última pasada de 4a). P-137-AA (A), 2026-10-26: CA-01 cumplido con lo medido declarado, CA-20 (techo de regresión de B5). **QA (2026-10-26, `d722aed`): `con-hallazgos`**; write-back del 2026-10-26: CA-18 con «Fuente sin marcas» (el generador no genera y borra, las definiciones leen entera una fuente sin marcas, `arnes-upgrade` no retira el import ni los `_doc` mientras su destino no exista), fallos por cualquier causa con límites declarados, techo de procesos por orden, lectura entera del archivo por rol. **En progreso** | `en-progreso` | critico | con-hallazgos | pendiente |
