# ArnesJuan

Arnés genérico de agentes para desarrollo asistido por IA en Claude Code (portable a Codex,
Cursor y otras herramientas vía AGENTS.md + MCP).

## Qué incluye
- **4 agentes** (`agents/`): `analista-requerimientos`, `desarrollador` (dueño también de
  `ARCHITECTURE.md`), `qa-tester`, `auditor-seguridad`. Genéricos: el contexto del proyecto
  vive en `AGENTS.md`, no en los agentes.
- **Comandos** (`skills/`): `/arnes-init` (andamia un proyecto, idempotente) y `/arnes-close`
  (genera el entregable `DELIVERY.md`).
- **Plantillas** (`templates/`): AGENTS.md (canónico) + CLAUDE.md (puntero) + CHANGELOG,
  ESTADO, PENDING_APPROVAL, ARCHITECTURE, DELIVERY, ADR, requirements y el hook pre-commit
  que exige changelog.
- **Tests del arnés** (`tests/`): escenarios para validar los agentes antes de versionar.

## Qué se incorporó de Ruflo (y qué no)
Decisión: copiar lo valioso para tener independencia, no depender de instalar Ruflo.
- **Copiado como nativo:** la plantilla y convención de **ADRs** (de `ruflo-adr`) y el patrón
  de **gates por fase** (de `ruflo-sparc`), ambos en `AGENTS.md` + `templates/`.
- **Convenciones que ya cubre el arnés:** control de costo = presupuesto + límite de
  reintentos; observabilidad = logs en archivos (CHANGELOG + registro-seguridad + ESTADO);
  documentación = propiedad repartida entre los agentes.
- **Músculo de runtime (NO copiable a markdown):** el escáner de CVEs y el medidor de tokens
  de Ruflo son motores TypeScript. Quedan como *opcional* vía `.mcp.json.example` — se
  enchufan si quieres, sin que el arnés dependa de ellos ni de Ruflo.

## Instalar (Claude Code)
```
/plugin marketplace add <tu-usuario>/ArnesJuan
/plugin install arnes-juan@arnes-juan
```
Luego, en un proyecto nuevo: `/arnes-init`. Al cerrar: `/arnes-close`.

## Las dos capas
- **Maquinaria** (este plugin): agentes, comandos, plantillas. Viaja entre proyectos/clientes.
- **Estado del proyecto** (AGENTS.md, CHANGELOG, ESTADO, PENDING_APPROVAL, ARCHITECTURE, docs,
  requirements): se queda en cada repo. Cero datos de cliente en el plugin.

## Flujo
analista define REQ → desarrollador codifica → qa-tester valida → auditor-seguridad revisa
→ REQ `completado`. La sesión principal coordina; el humano aprueba cada fase (vía
`PENDING_APPROVAL.md`). Máximo de reintentos dev↔QA configurable; superado, el REQ se bloquea
y escala.

## Versionado
SemVer con tags. Mejoras siempre aquí (una sola fuente de verdad); los proyectos actualizan
cuando quieren. Correr `tests/` antes de cada versión.
