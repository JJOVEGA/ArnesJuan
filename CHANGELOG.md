# CHANGELOG — ArnesJuan

> Bitácora de versiones del plugin. SemVer; cada versión tiene su tag `vX.Y.Z`.

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
