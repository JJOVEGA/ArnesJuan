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

| Agente | Modelo | Responsabilidad |
|--------|--------|-----------------|
| `analista-requerimientos` | Opus | Levanta y documenta requerimientos en `requirements/` |
| `desarrollador` | Sonnet | Codifica los requerimientos + documentación **técnica**, dueño de `ARCHITECTURE.md` (vista de sistema e integración) |
| `qa-tester` | Sonnet | Prueba el trabajo del desarrollador, corre quality gates, escribe documentación de **usuario final** |
| `auditor-seguridad` | Opus | Revisa seguridad y gobernanza; mantiene `docs/seguridad/`; puede vetar |

Modelo asignado por dificultad: Opus en razonamiento profundo, Sonnet en volumen e iteración.

> Documentación distribuida (no hay 5º agente "documentador"): cada agente documenta su
> rebanada con el contexto vivo, y el `desarrollador` consolida la vista de arquitectura en
> `ARCHITECTURE.md`. Si el proyecto crece y la consolidación pesa, se puede añadir luego un
> agente `documentador` dedicado.

## 6. Orquestación, loops de error y gates humanos

**Flujo:** analista define REQ → desarrollador codifica → qa-tester valida → auditor-seguridad revisa → REQ `completado`.

**Loop de error:** si QA o seguridad encuentran fallos, el REQ vuelve al desarrollador.
Máximo **{{MAX_REINTENTOS}}** vueltas dev↔QA por REQ; superado ese límite, el REQ pasa a
`bloqueado` y se escala al humano. La seguridad puede **vetar** en cualquier momento.

**Gates de aprobación humana** — el pipeline se detiene y espera tu visto bueno antes de:
{{GATES_HUMANOS}}
(por defecto: cierre de cada fase, decisiones arquitecturales, y cambios que tocan datos/credenciales de producción).

**Mecanismo de gate:** cuando una acción requiere aprobación, el agente escribe la decisión
pendiente en `PENDING_APPROVAL.md` y **detiene** el pipeline. No continúa hasta que el humano
resuelve (aprueba/rechaza) y limpia esa entrada. Así el bloqueo queda visible y por escrito.

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
DELIVERY.md            ← artefacto de cierre (al entregar)
.claude/agents/        ← definiciones de los 4 agentes (del plugin)
memory/                ← memoria/preferencias (no versionar secretos)
```
