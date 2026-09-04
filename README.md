# ArnesJuan

Arnés genérico de agentes para desarrollo asistido por IA en Claude Code (portable a Codex,
Cursor y otras herramientas vía AGENTS.md + MCP).

## Qué incluye
- **4 agentes** (`agents/`): `analista-requerimientos`, `desarrollador` (dueño también de
  `ARCHITECTURE.md`), `qa-tester`, `auditor-seguridad`. Genéricos: el contexto del proyecto
  vive en `AGENTS.md`, no en los agentes.
- **Comandos** (`skills/`): `/arnes-init` (andamia un proyecto, idempotente),
  `/arnes-upgrade` (pone al día el andamiaje de un proyecto ya inicializado cuando el arnés
  sube de versión: aditivo, nunca sobrescribe), `/arnes-close` (genera el entregable
  `DELIVERY.md`) y `/arnes-panel` (panel HTML interactivo de estado del proyecto: solo
  lectura, se regenera; clic para ver el detalle).
- **Plantillas** (`templates/`): AGENTS.md (canónico) + CLAUDE.md (puntero) + CHANGELOG,
  ESTADO, PENDING_APPROVAL, ARCHITECTURE, DELIVERY, ADR, requirements y el hook pre-commit
  que exige changelog.
- **Tests del arnés** (`tests/`): escenarios para validar los agentes antes de versionar.

## Enforcement por runtime (hooks)
Las invariantes críticas no se quedan en el markdown: las vigila la máquina vía hooks
`PreToolUse` del plugin (`hooks/`), que leen el manifiesto `.arnes/config.json`:
- **Sólo el `desarrollador` edita el código de la app** (la coordinadora y demás subagentes
  reciben un rechazo en runtime, con el motivo).
- **Un REQ no pasa a `completado`** si hay aprobaciones pendientes en `PENDING_APPROVAL.md`, si
  alguna quality gate está en rojo, o si falta el veredicto de QA/seguridad.

Son **inertes** sin `.arnes/config.json` (no estorban en repos ajenos al arnés) y requieren `jq`.
El `pre-commit` de git sigue exigiendo el changelog en cada commit.

**El nombre del agente en el manifiesto va en corto** (`"agente_codigo": "desarrollador"`). En
runtime Claude Code entrega el agente con el prefijo del plugin que lo provee
(`arnes-juan:desarrollador`); el hook lo tolera. Declararlo con prefijo es opcional y vuelve la
comparación estricta con ese proveedor.

### Limitación conocida: la cobertura de `Bash` es parcial (y a propósito)
`guard-codigo` mira `Edit`/`Write`/`MultiEdit` y, en `Bash`, sólo las escrituras **evidentes**:
redirección `>`/`>>`, `tee`, `cp`, `mv`, `install`, `sed -i`, `perl -i` y `dd of=`. Quedan fuera
los scripts, los formateadores que reescriben archivos (`prettier --write`, `eslint --fix`),
`patch`/`git apply` y cualquier programa que escriba por su cuenta. `guard-completado` no mira
`Bash` en absoluto: un `sed -i` sobre un REQ puede cerrarlo sin pasar por las puertas.

**El porqué:** un hook no puede analizar shell arbitrario de forma fiable — redirecciones
indirectas, heredocs, variables, subshells, scripts que escriben por su cuenta. Perseguir la
cobertura total genera falsos positivos sobre comandos de lectura perfectamente legítimos
(`cat`, `grep`, `git diff`, un build que escupe su log), y un guard que estorba acaba
desactivado. Un guard apagado protege menos que uno parcial, así que el detector se sesga
explícitamente al **falso negativo**: si duda, permite.

Conclusión honesta, la misma que dice `AGENTS.md` §13: **es una barandilla, no una jaula.**
Impide que el modelo se desvíe por descuido; no contiene a un agente decidido a rodearla. Cuando
deniega por `Bash`, el mensaje dice que la cobertura es parcial, para que un falso positivo se
reconozca al instante.

## Qué hace el arnés
Coordina cuatro agentes especializados en un pipeline con el humano siempre al mando:
- **Quality gates por fase:** cada requerimiento recorre análisis → desarrollo → QA →
  seguridad. No avanza de fase sin cumplir los criterios, y el humano aprueba cada salto vía
  `PENDING_APPROVAL.md`.
- **Decisiones trazables (ADRs):** las decisiones de arquitectura se registran como ADRs en
  `docs/decisions/` (con su plantilla), para que siempre quede por qué se hizo cada cosa.
- **Control de costo:** presupuesto por tarea + límite de reintentos dev↔QA. Superado el
  límite, el requerimiento se bloquea y escala en vez de gastar indefinidamente.
- **Observabilidad en archivos:** todo queda en texto auditable — `CHANGELOG.md` (cada
  commit), `docs/seguridad/registro-seguridad.md` (hallazgos) y `docs/ESTADO.md` (estado).
- **Documentación viva:** cada agente es dueño de su documentación (técnica, de usuario, de
  seguridad) y la mantiene junto al código, reflejando el sistema real y no solo la intención.

## Músculo de runtime opcional (MCP)
El arnés funciona solo con markdown, sin dependencias externas. Si quieres capacidades de
runtime "duras" —un escáner real de CVEs, medición de tokens, etc.— se enchufan vía **MCP**
partiendo de `.mcp.json.example`. Son intercambiables (semgrep, bandit, el motor que
prefieras) y **opcionales**: el arnés no depende de ninguno para funcionar.

## Instalar (Claude Code)
```
/plugin marketplace add <tu-usuario>/ArnesJuan
/plugin install arnes-juan@arnes-juan
```
Luego, en un proyecto nuevo: `/arnes-init`. Al cerrar: `/arnes-close`.

Cuando el arnés suba de versión, en cada proyecto ya existente: `/arnes-upgrade`. Hace falta
porque los hooks y los agentes viven en el plugin y se actualizan solos, pero los archivos que
`/arnes-init` copió al proyecto —`AGENTS.md`, `.arnes/config.json`, `requirements/README.md`…—
se quedan como estaban. Sin ese paso, la máquina empieza a exigir cosas que el `AGENTS.md` del
proyecto no describe.

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
