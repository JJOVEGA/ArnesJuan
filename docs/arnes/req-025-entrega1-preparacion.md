> **HISTÓRICO — superado por el commit `5162126` (2026-09-21); se conserva como registro.** El
> parche que este documento prepara **no se aplicó**: las precisiones (a) y (b) del propietario lo
> dejaron desfasado y la entrega 1 se escribió directamente sobre los archivos. Léase como
> evidencia de cómo se construyó y se comprobó el diff, no como el estado del árbol.

# REQ-025 entrega 1 — preparación del diff mínimo como parche sin aplicar

> Artefacto de evidencia del `desarrollador`, escrito el **2026-09-21**.
> Acompaña a `docs/arnes/req-025-entrega1.patch`. Su razón de ser: el cambio de la entrega 1
> está **construido y comprobado** pero **no aplicado**, porque dos de sus hunks cambian texto
> normativo vigente y esa decisión es del propietario (conflictos (a) y (b) de
> `requirements/REQ-025.md`, §«Preguntas abiertas / conflictos», bloque A).

## 1. Versión base y método

| Qué | Valor |
|---|---|
| Rama | `feat/req-025-coordinacion-entregas` |
| Cabeza al empezar | `a3338a3` (desde `main` = `v1.34.0`), árbol limpio |
| Base del parche | el **commit de preparación** de esta rama = `a3338a3` + el parche + esta nota + la entrada de `CHANGELOG.md` de la preparación |
| Dónde se construyó | una **copia** del árbol en el directorio de trabajo de la sesión (`git archive a3338a3` → repo git independiente); **nunca** sobre los archivos reales |
| Cómo se generó | `git diff` en esa copia, con un preámbulo de comentario delante (`git apply` ignora todo lo anterior a la primera línea `diff --git`) |

**Por qué la base no es `a3338a3` a secas.** El parche incluye la entrada de `CHANGELOG.md` del
commit futuro, y el commit de preparación escribe **su propia** entrada encima, en el mismo sitio
del archivo. Se midió: los **seis documentos normativos** aplican limpiamente también sobre un
`a3338a3` prístino (`git apply --check --exclude=CHANGELOG.md` → rc 0); el **único** hunk que
necesita la base nueva es el de `CHANGELOG.md` (sobre `a3338a3` prístino da
`error: patch failed: CHANGELOG.md:2`, rc 1). Las dos corridas están abajo.

## 2. Qué contiene el parche

`git apply --stat` (en el worktree real, antes y después del commit de preparación):

```
 AGENTS.md                     |   83 ++++++++++++++++++++++++++++++++++++++++-
 CHANGELOG.md                  |   50 +++++++++++++++++++++++++
 agents/auditor-seguridad.md   |    8 ++--
 agents/desarrollador.md       |    2 -
 agents/qa-tester.md           |   12 ++++--
 skills/arnes-upgrade/SKILL.md |   69 ++++++++++++++++++++++++++++++++++
 templates/AGENTS.md.tpl       |   83 ++++++++++++++++++++++++++++++++++++++++-
 7 files changed, 293 insertions(+), 14 deletions(-)
```

**Cero** rutas en `hooks/`, `tools/`, `tests/`, `.arnes/`, `.github/` y `.claude-plugin/`
(comprobado filtrando la salida de `git apply --numstat`). `.arnes/plantillas-origen/AGENTS.md.tpl`
**no se toca**: es la base de fusión de `arnes-upgrade` (CA-15 punto 6).

## 3. Los dos hunks que dependen de una decisión del propietario

Se identifican por su cabecera `@@`, y pueden aprobarse o excluirse **por separado**:

| Conflicto | Archivo | Hunk | Qué reescribe |
|---|---|---|---|
| **(b)** | `AGENTS.md` | `@@ -357,7 +357,14 @@` | «Loop de error» |
| **(b)** | `templates/AGENTS.md.tpl` | `@@ -323,7 +323,14 @@` | «Loop de error» (gemela) |
| **(a)** | `AGENTS.md` | `@@ -407,8 +478,14 @@` | «Mecanismo de gate» |
| **(a)** | `templates/AGENTS.md.tpl` | `@@ -368,8 +439,14 @@` | «Mecanismo de gate» (gemela) |

Los demás hunks son **libres** (no cambian texto vigente, sólo añaden):
`AGENTS.md @@ -378,6 +385,70 @@` y `templates/AGENTS.md.tpl @@ -344,6 +351,70 @@` (el bloque de
las seis reglas), `skills/arnes-upgrade/SKILL.md @@ -867,6 +867,75 @@` (entrada «Hacia 1.35.0»),
los tres archivos de `agents/`, y `CHANGELOG.md`.

**Si se excluye (a) o (b), hay que ajustar además** la entrada de `CHANGELOG.md` del parche, la
entrada «Hacia 1.35.0» y las referencias de `agents/qa-tester.md`, que los describen como
aplicados. Excluir un hunk `[DECISIÓN]` y dejar el resto produce la contradicción entre dos sedes
que **CA-15 punto 1** prohíbe.

## 4. Comprobaciones ejecutadas

Todas sobre la **copia con el parche aplicado**, salvo las de `git apply`, que son sobre el
worktree real. Corrida del **2026-09-21**.

| # | Comprobación | Comando | Resultado |
|---|---|---|---|
| 1 | Sintaxis del mecanismo | `for f in hooks/*.sh tools/*.sh; do bash -n "$f" \|\| exit 1; done` | **OK**, 10 archivos |
| 2 | Registro de hooks | `jq -e . hooks/hooks.json` | **OK** |
| 3 | Versión y marketplace | `jq -e . .claude-plugin/plugin.json && jq -e . .claude-plugin/marketplace.json` | **OK** |
| 4 | Secciones del banco que leen `AGENTS.md`, `templates/`, `agents/` o `skills/` | `bash run.sh 'secciones/04-*' '…/10-*' '…/11-*' '…/31-*' '…/32-*' '…/33-*' '…/34-*' '…/36-*' '…/40-*'` | **308 PASS · 0 FAIL · 1 SKIP** (14 de 51 secciones) |
| 5 | Gemelas byte a byte | `diff` del bloque nuevo y de los dos párrafos entre `AGENTS.md` y `templates/AGENTS.md.tpl` | **vacío** en los tres |
| 6 | El parche aplica | `git apply --check docs/arnes/req-025-entrega1.patch` (worktree real) | **rc 0** |
| 7 | Alcance del parche | `git apply --numstat … \| grep -E '^(hooks/\|tools/\|tests/\|\.arnes/\|\.github/\|\.claude-plugin/)'` | **0 rutas** |
| 8 | Aplicabilidad sobre `a3338a3` prístino, sin `CHANGELOG.md` | `git apply --check --exclude=CHANGELOG.md …` | **rc 0** |
| 9 | Idem **con** `CHANGELOG.md` | `git apply --check …` | **rc 1**, `patch failed: CHANGELOG.md:2` (esperado, §1) |

**Cómo se eligieron las secciones del punto 4** (método, para poder re-derivarlo): unión de
`grep -l -E "AGENTS\.md"` y `grep -l -E "\.tpl|SKILL\.md|agents/|templates/|arnes-upgrade"` sobre
`tests/escenarios/hooks/secciones/*.sh`. Devuelve `04`, `10`, `11`, `31`, `32`, `33`, `34`,
`36-…-4`, `36-…-5` y `40`. **No existe ninguna sección `46-*`** en este árbol (hay 51 secciones y
la última decena empieza y termina en `40-estabilizacion-firmas-y-rigor.sh`).

**El único SKIP, con su motivo en su línea:** «ruta estilo Windows con backslashes -> deny
(sin cygpath: caso solo de Windows)». Es de plataforma y no lo introduce este cambio.

**Lo que estas comprobaciones NO acreditan:** el **banco completo** en CI —la puerta requerida de
`main`—, que no se corrió aquí; la autoprueba del corredor, innecesaria porque `tests/` no se toca;
y **nada** sobre proyectos consumidores, que no reciben nada hasta publicar y migrar.

## 5. Barrido por propiedad — qué queda, y por qué no contradice

Propiedad buscada (CA-15 punto 2): *toda frase que afirme que un hallazgo devuelve trabajo por sí
solo, o que una decisión pendiente detiene todo el trabajo sin nombrar la acción que impide*.
Corpus: `AGENTS.md`, `templates/AGENTS.md.tpl`, `agents/`, `skills/`. Coincidencias que **quedan**,
todas revisadas una a una. **Los números de línea de esta tabla son los del árbol CON el parche
aplicado** (difieren de los del árbol actual sólo en `AGENTS.md:635`,
`templates/AGENTS.md.tpl:599` y `skills/arnes-upgrade/SKILL.md:897`):

| Sede | Por qué NO contradice |
|---|---|
| `AGENTS.md:473` y `templates/AGENTS.md.tpl:437` — «Gates de aprobación humana — el pipeline se detiene y espera tu visto bueno **antes de:**» | La lista que sigue **nombra las acciones**: fusionar, publicar, cambiar el ruleset/CI/manifiesto, tocar `hooks/`. El alcance está declarado |
| `AGENTS.md:60` y `:121` | Hablan de **quién decide** fusionar, etiquetar y publicar cuando hay un rojo; la acción está nombrada. Además son texto de autoalojamiento, que no viaja a la plantilla |
| `agents/qa-tester.md:43`, `:50` | «Devolver» un **write-back** deficiente o una clasificación incoherente: es la facultad de **no firmar**, que CA-14 punto 1 conserva expresamente. No abre trabajo por sí sola, y `:50` ya enruta por la coordinadora |
| `agents/auditor-seguridad.md:65`, `agents/desarrollador.md:67` | Otro sentido de «devolver» (una consulta devuelve filas, un boundary devuelve un error) |
| `skills/arnes-upgrade/SKILL.md:785`, `:801`, `:897` | «Devuelve al analista **sólo esa decisión**» (que es la regla 3, término (b)) y «el estado que devuelva el merge». Otro sentido |
| `skills/arnes-close/SKILL.md:38` | «No des el proyecto por cerrado hasta el visto bueno»: nombra la acción (**cerrar**) |
| `AGENTS.md:635`, `templates/AGENTS.md.tpl:599` | «`ask` detendría la llamada»: describe un modo de hook, no una regla de trabajo |
| `templates/requirements-README.md.tpl:17` | Define el estado `bloqueado` en una tabla de vocabulario; no promete alcance |

### Lo que el barrido SÍ encontró y este parche NO corrige — decisión pendiente

**`templates/PENDING_APPROVAL.md.tpl:3-5`** (y su copia viva en este repo,
`PENDING_APPROVAL.md:3-5`) dicen:

```
> Cola de decisiones que esperan visto bueno humano antes de que el pipeline continúe.
> Un agente AÑADE una entrada y se detiene; el humano la resuelve y la mueve a "Resueltas".
> Mientras haya algo en "Pendientes", el pipeline NO avanza en ese hilo.
```

Las dos primeras líneas tienen **la misma propiedad** que el párrafo (a): afirman que la cola
detiene el trabajo **sin nombrar la acción que impide**. La tercera acota («en ese hilo») pero
tampoco la nombra. **No se tocan aquí** porque el encargo enumera cinco piezas y ese archivo no es
ninguna de ellas, y ampliar el alcance por iniciativa propia es justo lo que la regla 3 prohíbe.
Se deja **registrado con responsable** —coordinadora, para decisión del propietario— y con su
efecto concreto: si el parche se aplica sin corregirlo, la entrega 1 sale con **dos sedes más**
diciendo lo que la sede nueva contradice, que es el defecto que CA-15 punto 2 viene a atacar.
Corregirlo son tres líneas y cae **dentro** del alcance que CA-15 punto 5 permite (`templates/`).

## 6. Frases de los agentes tocadas (antes → después, resumen)

Detalle exacto en el parche. Ninguna retira una facultad; todas remiten a `AGENTS.md` §6.

| Sede | Antes (núcleo) | Después (núcleo) |
|---|---|---|
| `agents/qa-tester.md:86` | «escribe la decisión en `PENDING_APPROVAL.md` y **detén el pipeline** hasta el visto bueno humano» | escribe con la forma de la regla 4 y **detén lo que esa entrada impide, nombrándolo**: `aprobar/cerrar`; implementar y probar no se detienen; «tú no pierdes nada» |
| `agents/qa-tester.md:87` | «registra … **y devuelve al `desarrollador`**» | registrar sigue siendo tuyo; **abre** trabajo la clasificación de la coordinadora (regla 3); «tu `con-hallazgos` bloquea igual y ninguna clasificación lo retira» |
| `agents/qa-tester.md:109-111` | «no se reinicia con cada hallazgo nuevo» | + «**ni por cambio de rol, de fase o de nombre de la comisión**» (regla 5) |
| `agents/qa-tester.md:121` | «**detén el pipeline** hasta que resuelva» | escala con la forma de la regla 4 **declarando qué acción impide** (regla 2): `aprobar/cerrar`; el trabajo independiente continúa |
| `agents/auditor-seguridad.md:24` | «Indica el motivo y la corrección requerida» | + **declara el alcance del veto** (regla 2), y «declararlo no lo debilita» |
| `agents/auditor-seguridad.md:37` | «`Estado: bloqueado` con motivo» | «con motivo **y con su alcance**» (regla 2) |
| `agents/auditor-seguridad.md:136` | (sin regla de urgencia) | **una urgencia se ESCALA** por la regla 4, con su **efecto concreto**; «independiente» no es donde guardarla |
| `agents/auditor-seguridad.md:139` | «Reportas hallazgos y correcciones **para que el `desarrollador` las aplique**» | qué se repara ahora **lo clasifica la coordinadora** (regla 3), y eso **no retira, degrada ni pospone** tu veredicto |
| `agents/desarrollador.md:52` | «`Estado: bloqueado` con una nota de qué falta» | `Estado: bloqueado` con la **forma de bloqueo con alcance** (regla 2), y «detente **en eso**» |

`agents/analista-requerimientos.md` **no se toca**: el barrido no encontró en él ninguna frase con
la propiedad buscada.

## 7. Limitaciones que este artefacto no tapa

1. **Las referencias de los agentes apuntan a `AGENTS.md` §6 del proyecto que los use.** En un
   proyecto que todavía no haya migrado, esa referencia apunta a un §6 que **no** contiene las seis
   reglas. Es inherente al diseño de CA-15 punto 4 —los agentes los provee el plugin y llegan al
   actualizarlo, mientras el `AGENTS.md` del proyecto está congelado hasta `arnes-upgrade`— y la
   entrada «Hacia 1.35.0» lo dice. **No** está resuelto por este parche.
2. **La entrada de `CHANGELOG.md` del parche lleva el marcador «FECHA DE APLICACIÓN»** en su
   título, en vez de una fecha. Es deliberado: la fecha real es la del commit que aplique el
   parche, y no se inventa.
3. **Nada aquí acredita el ensayo de CA-11 punto 3** ni ninguna de las cinco condiciones de
   acreditación: las firma quien no despacha.
4. **La consola se usó para una sola cosa** —generar el cuerpo del parche con `git diff` y
   concatenarlo tras el preámbulo—, porque es salida de máquina y transcribirla a mano la
   corrompería. `docs/arnes/` no está en `codigo_app.globs`. Todo lo demás se editó con las
   herramientas de edición, como manda `AGENTS.md` §13.
