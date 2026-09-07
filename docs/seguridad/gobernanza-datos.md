# Gobernanza de datos — ArnesJuan

> Documento del `auditor-seguridad`. Política de clasificación, acceso, retención y
> cumplimiento. Se actualiza cuando cambia el alcance o los datos que el repositorio maneja.
> Última revisión: **2026-09-07** (R-007, ventana 1.32.1: cambio de accesos y canal privado
> con repositorio propio — SEC-026 y SEC-027). Revisión anterior: 2026-09-05 (REQ-001, 1.30.3).

## 1. Qué es este repositorio, a efectos de datos

ArnesJuan es un **plugin de Claude Code**: hooks de enforcement, agentes, plantillas y skills.
**No tiene usuarios finales, ni base de datos, ni backend, ni sesiones, ni autenticación
propia.** No procesa datos personales de terceros, no maneja dinero y no expone ningún
endpoint. La superficie de ataque real no es una aplicación web: es el **mecanismo que
gobierna a otros proyectos**, y por eso el activo a proteger es la **integridad de las
puertas** (`hooks/`), no la confidencialidad de unos datos.

Consecuencia práctica: de la línea base habitual (OWASP Web / API / LLM) sólo aplican de
verdad las clases de **integridad del control de acceso** (quién puede escribir qué),
**inyección** (texto de un comando interpretado como comando), **fallo abierto por
agotamiento de recursos** y **cadena de suministro**. Lo demás se declara **no aplicable por
ausencia de superficie**, no por descuido.

## 2. Clasificación de los datos que sí existen

| Clase | Qué es | Dónde vive | Regla |
|---|---|---|---|
| **Público** | Código del plugin, `AGENTS.md`, `requirements/`, `docs/`, `CHANGELOG.md`, informes de QA y de seguridad **de este repositorio** | Repositorio público `JJOVEGA/ArnesJuan` | Se publica. Redactado en español y sin datos de terceros |
| **Privado — de cliente** | Informes de defectos del arnés que llegan **desde proyectos reales**: nombres de proyecto, identificadores de sus REQ, rutas, extractos de su código o de sus datos | **Fuera** de este repositorio: canal privado; `mejoras-arnes-*.md`, `reporte-arnes-*.md` e `insumos/` están en `.gitignore`. **Desde el 2026-09-07** tienen sitio propio: `JJOVEGA/ArnesJuan-informes`, **privado**, con issues y sin colaboradores más que el dueño (SEC-026) | **Nunca** entra a **este** repositorio, ni citado literalmente. Se traduce a una **clase de defecto** genérica y esa clase, ya anónima, es lo que se convierte en REQ. **Que ahora haya un repositorio privado del mismo propietario NO relaja esta regla: la facilita de romper** — el traslado literal está a un copiar y pegar, y es exactamente lo que §3 prohíbe |
| **Local de máquina** | `.mcp.json` real, `.claude/settings.local.json`, `memory/` | Disco de la máquina | En `.gitignore`. No se versiona |
| **Identidad operativa** | **Dos** cuentas de GitHub con acceso al repositorio público: `jvega-habitat` (push, sin administración) y `JJOVEGA` (propietaria: rulesets, publicación). Verificado con `gh` el 2026-09-07 | GitHub | Sin secretos en el repositorio. La autenticación la gestiona `gh`; ningún token vive en el árbol. **Mínimo privilegio, y aquí no es una frase:** `write` sobre este repositorio es acceso al **mecanismo que gobierna a todos los proyectos que instalan el plugin**, no a un repositorio. El 2026-09-07 se retiró el `write` de `jvega-consisa` y una invitación caducada (SEC-026) |

## 3. Regla del canal privado (es la regla que más importa aquí)

Un proyecto que usa el arnés encuentra un defecto **del arnés**. Ese informe llega por canal
privado y contiene contexto del cliente. **La traducción a este repositorio conserva el
defecto y descarta el contexto**: se escribe la forma del fallo (qué se rodeaba y por dónde),
nunca el proyecto, el REQ ajeno, la ruta ajena ni el dato ajeno.

Verificación en cada auditoría, **en dos mitades, porque una sola no puede sostener la regla**:

1. **Incremental:** `git diff origin/main..HEAD | grep '^+'` sobre lo añadido, buscando nombres de
   organización, de proyecto o de personas. Hecho en la auditoría de REQ-001 (2026-09-05): **sin
   hallazgos** en las ~5.900 líneas añadidas. Repetido en R-007 (2026-09-07) sobre lo añadido por la
   ventana 1.32.1: **sin hallazgos**, y tampoco patrones de credencial, ni `insumos/` o
   `reporte-arnes-*` en el índice.
2. **De base, y es la mitad que faltaba:** una pasada sobre **todo** el árbol versionado. Un control
   **diferencial no puede encontrar, por construcción, lo que ya está en la base** — y no es
   hipotético: en R-007 el barrido de base encontró **`CHANGELOG.md:1615` nombrando a un proyecto
   consumidor**, publicado desde el commit `73f9452` (PR #26) y por tanto **fuera del alcance de
   todas** las verificaciones incrementales anteriores, que reportaron «sin hallazgos» con razón. Es
   **SEC-029**. La propiedad que hay que sostener es de **estado** («ninguna ruta versionada nombra un
   proyecto consumidor, una organización ni una persona ajena»), no de cambio. La lista de nombres a
   buscar vive en **un solo sitio y FUERA de este repositorio** (`insumos/`, en `.gitignore`): una
   lista de nombres de cliente publicada para poder buscarlos sería el mismo fallo con más pasos.

**Y el residual que no se deshace:** lo que ya se publicó en el historial de un repositorio público
**no se retira reescribiendo el historial** —rompe toda clonación, choca con `non_fast_forward` y no
recupera las copias distribuidas—. Se corrige el presente, se declara el residual y se cierra la vía
(SEC-029).

## 4. Secretos

- No hay secretos de aplicación. `.gitignore` cubre `.mcp.json`, `.claude/settings.local.json`
  y la memoria de trabajo.
- Verificado en la auditoría de REQ-001: **ningún** patrón de credencial (`ghp_`,
  `github_pat_`, `AKIA…`, `-----BEGIN`, `api_key=`, `token=`, `password=`) en lo añadido.
- Los hooks **no escriben secretos ni PII en ningún log**: sus salidas son motivos de
  denegación con rutas relativas del proyecto y nombres de agente.

## 5. Retención

- `CHANGELOG.md` y `docs/seguridad/registro-seguridad.md` son **bitácoras vivas**: no se borra
  nada, se cambia el **estado** de la entrada. La rotación del arnés (`rotacion.activo`) puede
  **mover** secciones a un archivo hermano; **nunca resume ni borra**. Hoy está apagada en este
  repositorio.
- Los informes de QA (`docs/qa/`) y los REQ son permanentes y versionados: la trazabilidad de
  por qué una puerta es como es vale más que el ahorro de espacio.

## 6. Acceso

- `main` protegido por el ruleset `proteger-main`: todo por PR, sin push directo, sin borrado,
  sin fast-forward, con el check `hooks-en-linux` **requerido y estricto**. Verificado leyendo
  el ruleset el 2026-09-05.
- El ruleset **no** exige revisores aprobadores (`required_approving_review_count: 0`). El gate
  humano de fusión y publicación es **política declarada** en `AGENTS.md` §4 y §6 —delegada al
  coordinador por el propietario el 2026-09-05—, no una restricción de la plataforma. Queda
  dicho aquí para que nadie lo confunda con enforcement.
- **Medido el 2026-09-07 (SEC-027), y el residual queda `aceptado` con condiciones.** Leído el
  ruleset con `gh`: `pull_request` activa (todo por PR) pero con
  `required_approving_review_count: 0`, `require_last_push_approval: false` y
  `require_code_owner_review: false`; `deletion` y `non_fast_forward` activas; el check
  `hooks-en-linux` **requerido y estricto**. Ejercicio real: los PR **#37, #38, #39 y #40** fueron
  abiertos y fusionados por la misma cuenta sin admin, con **0 revisiones**; el push directo a `main`
  sí se rechaza. Es decir: **una cuenta con `write` puede abrir y fusionar su propio cambio del
  plugin** en cuanto el banco pase en Linux. **No se exige el control**, por la asimetría razonada en
  SEC-027 —con dos cuentas, la única revisión posible la firmaría quien ya decide, así que compraría
  un turno y no independencia—, y **las tres condiciones que sostienen ese `aceptado`** viven en esa
  entrada; la primera es que **el número de cuentas con `write` no crezca**.
- Dentro del árbol, el mapeo de quién edita qué vive en `.arnes/config.json`
  (`codigo_app.globs`) y lo aplica `guard-codigo`.
- **Actualizado el 2026-09-06 (candidata 1.31.0, SEC-006 parte a).** El manifiesto ya está
  **dentro** de su propia frontera: `codigo_app.globs` de este repositorio incluye
  `.arnes/config.json` y `.claude-plugin/*`, de modo que sólo el `desarrollador` puede cambiar
  la regla que dice qué es código protegido. Verificado por sonda el 2026-09-06: ALLOW sólo
  para `desarrollador`; DENY para los otros tres agentes y para la sesión coordinadora. Es
  **mapeo de este repositorio** y no se propaga a `templates/`. Dos consecuencias, escritas
  para que no sorprendan: (a) subir `arnes_version` pasa a ser trabajo del agente de código;
  (b) mientras el manifiesto sea **ilegible**, la excepción de reparación (REQ-007 CA-60) abre
  ese archivo a **cualquier** agente — acotado a *ese* archivo y a comandos que no escriban en
  ningún otro sitio, y desde 1.31.0 **con rastro**: el arnés emite un aviso propio que nombra la
  herramienta y el `agent_type` que la ejerce (SEC-011, **mitigado**; verificado en R-003).
- **Estado degradado del enforcement.** Con el manifiesto presente pero ilegible, las dos puertas
  de escritura deniegan (fail-closed, SEC-005) y, **desde 1.31.0**, `guard-git` también: cae a la
  **lista por defecto del código** y deniega el git destructivo diciendo que está en modo
  degradado (SEC-010, **mitigado**; verificado en R-003 sobre once estados ilegibles). El borde
  se declara: un proyecto con `git.activo: false` al que se le rompa el manifiesto **pasa a
  denegar**, porque esa declaración vive dentro del archivo que no se puede leer. Aun así,
  «manifiesto roto» sigue siendo una **incidencia de seguridad** que se repara de inmediato y no
  una molestia de tooling: mientras dure, el mapeo del proyecto no se aplica y cualquier agente
  puede reescribir el manifiesto (lista completa de lo que queda sin gobernar en REQ-007 CA-63.3).
- **Lo que el estado degradado NO protege, y hay que saberlo.** `docs/ESTADO.md` y demás archivos
  del usuario quedaron a salvo en 1.31.0 (nada que no se pueda leer se reescribe), pero el modo
  del archivo y la posición del texto humano **fuera** de los marcadores todavía se alteran
  (QA-116 y QA-117, heredados de v1.30.3, arreglo exigido en REQ-007 CA-64.1-bis y CA-64.2-bis,
  ventana 1.32.0).

- **Los instrumentos de medida quedan FUERA del código protegido, y es una decisión, no un olvido
  (R-010, 2026-09-07, prospectiva — REQ-021 aún no está construido).** `codigo_app.globs` deja
  `tests/` fuera a propósito, para que el `qa-tester` pueda romper las pruebas por oficio. Con
  `tests/util/` eso alcanza a **los instrumentos que producen los números que gobiernan la puerta
  requerida de `main`**, y `guard-codigo` permite escribirlos a **cualquier** agente, incluida la
  sesión coordinadora — que es además quien reúne la evidencia de «todo en verde» y quien fusiona,
  etiqueta y publica por delegación permanente (2026-09-05). **Se acepta**, con el mismo criterio
  que SEC-027: la alternativa —meterlo en el manifiesto— abre un gate humano cuya cola **deniega el
  cierre de cualquier REQ** mientras exista, y bloquear trabajo ajeno para custodiar un instrumento
  es peor negocio que **acreditar la medida**. El sustituto es la calibración de sensibilidad en
  cada corrida (REQ-021 CA-03). **Condición que sostiene ese `aceptado`, y sin la cual decae:** el
  sustituto se acredita **por mutación de un tercero** en la pasada de conformidad de 1.34.0 —se
  altera una sonda y se exige que la calibración no dé verde—, y la expectativa de la calibración
  vive en el **juez** (`run.sh`), no dentro de la sonda que certifica. Detalle y remediación en
  **SEC-036**; dueño del residual: `auditor-seguridad`.

## 7. Cumplimiento

No aplica ningún régimen de datos personales (no se tratan). El compromiso de cumplimiento de
este repositorio es con su propio contrato: `AGENTS.md` §4 (repositorio público, nunca
hallazgos de un cliente) y §6 (gates humanos). Su incumplimiento se trata como hallazgo de
seguridad, no como incidencia editorial.
