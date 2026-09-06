# Gobernanza de datos — ArnesJuan

> Documento del `auditor-seguridad`. Política de clasificación, acceso, retención y
> cumplimiento. Se actualiza cuando cambia el alcance o los datos que el repositorio maneja.
> Última revisión: 2026-09-05 (auditoría de REQ-001, candidata 1.30.3).

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
| **Privado — de cliente** | Informes de defectos del arnés que llegan **desde proyectos reales**: nombres de proyecto, identificadores de sus REQ, rutas, extractos de su código o de sus datos | **Fuera** del repositorio: canal privado; `mejoras-arnes-*.md` e `insumos/` están en `.gitignore` | **Nunca** entra al repositorio, ni citado literalmente. Se traduce a una **clase de defecto** genérica y esa clase, ya anónima, es lo que se convierte en REQ |
| **Local de máquina** | `.mcp.json` real, `.claude/settings.local.json`, `memory/` | Disco de la máquina | En `.gitignore`. No se versiona |
| **Identidad operativa** | Dos cuentas de GitHub: una con permiso de push sin administración y otra propietaria (rulesets, publicación) | GitHub | Sin secretos en el repositorio. La autenticación la gestiona `gh`; ningún token vive en el árbol |

## 3. Regla del canal privado (es la regla que más importa aquí)

Un proyecto que usa el arnés encuentra un defecto **del arnés**. Ese informe llega por canal
privado y contiene contexto del cliente. **La traducción a este repositorio conserva el
defecto y descarta el contexto**: se escribe la forma del fallo (qué se rodeaba y por dónde),
nunca el proyecto, el REQ ajeno, la ruta ajena ni el dato ajeno.

Verificación en cada auditoría: `git diff origin/main..HEAD | grep '^+'` sobre lo añadido,
buscando nombres de organización, de proyecto o de personas. Hecho en la auditoría de
REQ-001 (2026-09-05): **sin hallazgos** de datos de cliente en las ~5.900 líneas añadidas.

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
- Dentro del árbol, el mapeo de quién edita qué vive en `.arnes/config.json`
  (`codigo_app.globs`) y lo aplica `guard-codigo`. Ver el hallazgo **SEC-006** del registro:
  el manifiesto que define esa frontera **no está él mismo dentro de la frontera**.

## 7. Cumplimiento

No aplica ningún régimen de datos personales (no se tratan). El compromiso de cumplimiento de
este repositorio es con su propio contrato: `AGENTS.md` §4 (repositorio público, nunca
hallazgos de un cliente) y §6 (gates humanos). Su incumplimiento se trata como hallazgo de
seguridad, no como incidencia editorial.
