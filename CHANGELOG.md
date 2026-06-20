# CHANGELOG — ArnesJuan

> Bitácora de versiones del plugin. SemVer; cada versión tiene su tag `vX.Y.Z`.

## [1.7.0] — 2026-06-20
### Añadido
- `auditor-seguridad`: cinco categorías explícitas en el checklist, nombradas para que no se
  pasen por alto:
  - **Ciclo de vida de la sesión / caducidad:** expiración del lado del servidor por
    inactividad (idle) **y** por vida máxima absoluta; cookies `HttpOnly`/`Secure`/`SameSite`;
    rotación del id de sesión; sesiones de verificación de un solo uso.
  - **BOLA / autorización a nivel de objeto (IDOR):** verificar pertenencia del recurso al
    usuario/tenant en endpoints que reciben un id, no solo que haya sesión válida.
  - **RLS / aislamiento en la BD:** Row-Level Security como defensa en profundidad de BOLA
    (multi-tenant); cuidado con el pooling y con roles que evaden RLS.
  - **Mass assignment / over-posting:** exigir whitelist de campos escribibles; campos
    sensibles (rol, tenant, permisos) nunca asignables desde el body.
  - **Fuerza bruta y abuso de credenciales** (límites por IP y por cuenta, backoff/CAPTCHA,
    mensajes genéricos, MFA) y **Agotamiento de recursos / DoS** (límites de body/JSON,
    paginación con tope, descompresión, ReDoS, timeouts), desdoblando el antiguo
    "Resiliencia y abuso".

## [1.6.0] — 2026-06-20
### Añadido
- **Enforcement por runtime (hooks `PreToolUse` del plugin)** — bajan a mecanismo lo que antes
  era prosa en `AGENTS.md`:
  - `hooks/guard-codigo.sh` (**A1**): deniega editar el código de la app (`codigo_app.globs`)
    a quien no sea el agente `desarrollador`. Distingue coordinadora vs. subagente por el
    campo `agent_id` del input del hook.
  - `hooks/guard-completado.sh` (**A2/A3**): deniega marcar un REQ como `completado` si hay
    aprobaciones pendientes en `PENDING_APPROVAL.md` o si alguna quality gate falla.
  - `hooks/hooks.json` + `hooks/lib.sh`; el plugin auto-descubre `hooks/hooks.json`.
- **Manifiesto machine-readable** `templates/arnes-config.json.tpl` → `.arnes/config.json`:
  fuente de verdad ejecutable (agente de código, globs de app, quality gates, estados).
- `arnes-init`: emite y rellena `.arnes/config.json`; entrevista por los globs de app.
- `AGENTS.md.tpl`: nueva §13 "Enforcement por runtime" y notas 🔒 en §5/§6/§7.
- Escenario de regresión `tests/escenarios/hooks/run.sh` (prueba los hooks en aislamiento).

### Notas
- Los hooks son **inertes** sin `.arnes/config.json` (no estorban en repos ajenos al arnés) y
  requieren `jq`; sin él, el enforcement queda inactivo con aviso por stderr (no bloquea).
- El gate de aprobación se enforce como `PreToolUse` deny (no como `Stop` hook): un `Stop`
  con `block` haría *continuar* al modelo, no detenerlo para el humano.

## [1.5.0] — 2026-06-04
### Añadido
- `auditor-seguridad`: nuevas categorías en el checklist de auditoría:
  - **Ataques web a LLM** (inyección de prompts directa/indirecta, manejo inseguro de la salida, agencia excesiva, fuga de system prompt), alineado con OWASP Top 10 for LLM Applications.
  - **CSRF** (token anti-CSRF y/o SameSite en endpoints que cambian estado).
  - **Subida de archivos** (validación por magic bytes, límites, nombres saneados, almacenamiento fuera del webroot sin ejecución).
  - **XXE** (parsers con entidades externas y DTD deshabilitadas).
  - **Web cache deception** (rutas con datos sensibles no cacheables).
  - **CVE y versiones** (vulnerabilidades cruzadas contra la NVD del NIST, con CVE y versión corregida; versiones ancladas).

## [1.4.1] — 2026-06-01
- `qa-tester`: la escalada por límite de reintentos nombra el mecanismo explícito — `bloqueado` + registro en `docs/ESTADO.md` + escalada al humano vía `PENDING_APPROVAL.md` con parada del pipeline.

## [1.4.0] — 2026-06-01
### Añadido
- Política explícita de **cambios de requerimientos** (versionado y deriva) en `templates/AGENTS.md.tpl`.
- Bloque **Historial de cambios** en la plantilla de REQ (`templates/requirements-README.md.tpl`).
- `analista-requerimientos`: versiona el REQ, registra causa y enlaza ADR ante cambios/deriva.
- `qa-tester`: reporta deriva y devuelve el REQ en vez de aprobar contra uno desactualizado.
- ADR del plugin: `docs/decisions/ADR-001-politica-cambio-requerimientos.md`.

## [1.3.3] — 2026-06-01
- La sesión coordinadora delega los cambios de código en el `desarrollador` (sobre todo al depurar). `memory/` ignorado.

## [1.3.2] — 2026-06-01
- Robustez ante entradas no normalizadas (dev) + QA prueba variantes (capitalización/espacios/ausente/inválido).

## [1.3.1] — 2026-06-01
- QA verifica integridad de dependencias (lockfile sincronizado y deps coherentes).

## [1.3.0] — 2026-06-01
- Nueva skill `/arnes-panel` (panel HTML interactivo de estado, solo lectura).

## [1.2.0] — 2026-06-01
- Robustez (try/catch) en dev; defensa anti-inyección/abuso en auditor; NFR de rendimiento en QA. README sin referencias externas.

## [1.1.0] — 2026-06-01
- Estructura inicial: 4 agentes, skills `/arnes-init` y `/arnes-close`, plantillas, hook pre-commit y tests.
