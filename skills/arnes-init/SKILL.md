---
name: arnes-init
description: Inicializa un proyecto nuevo con el andamiaje del arnés (AGENTS.md, CLAUDE.md, CHANGELOG, ESTADO, requirements, docs, hook pre-commit). Idempotente: no vuelve a correr si ya está inicializado. Trabaja en español.
---

# arnes-init — arranque de proyecto

Inicializa el andamiaje del arnés en el proyecto actual. **Es idempotente**: revisa el
marcador antes de hacer nada.

## Procedimiento

1. **Verifica el marcador.** Si existe `.arnes-initialized` en la raíz del proyecto,
   informa que ya está inicializado y NO hagas nada más.

   **Y ofrece la salida:** compara `arnes_version` de `.arnes/config.json` con la versión
   del plugin instalado (`.claude-plugin/plugin.json`). Si difieren, dilo y remite a
   **`/arnes-upgrade`**, que es lo que pone al día el andamiaje sin sobrescribir nada. Sin
   ese aviso, quien ejecute esta skill en un proyecto existente se queda sin camino: los
   hooks ya se actualizaron solos y sus archivos no.

2. **Si no existe**, crea el andamiaje copiando desde `templates/` del plugin y rellenando
   los `{{PLACEHOLDERS}}`:
   - `AGENTS.md`  ← `templates/AGENTS.md.tpl`  (archivo canónico)
   - `CLAUDE.md`  ← `templates/CLAUDE.md.tpl`  (importa AGENTS.md)
   - `CHANGELOG.md` ← `templates/CHANGELOG.md.tpl`
   - `docs/ESTADO.md` ← `templates/ESTADO.md.tpl`
   - `PENDING_APPROVAL.md` ← `templates/PENDING_APPROVAL.md.tpl`
   - `ARCHITECTURE.md` ← `templates/ARCHITECTURE.md.tpl`
   - `requirements/README.md` ← `templates/requirements-README.md.tpl`
   - `.arnes/config.json` ← `templates/arnes-config.json.tpl` (manifiesto machine-readable que leen los hooks de enforcement del plugin; ver paso 3)
   - `.githooks/pre-commit` ← `templates/githooks/pre-commit` (recuerda `git config core.hooksPath .githooks`)
   - Carpetas vacías: `docs/decisions/`, `docs/seguridad/`, `docs/usuario/`, `docs/qa/`, `memory/`.
   - La plantilla de ADRs (`templates/ADR.md.tpl`) queda disponible para cuando se registre una decisión.
   - `.mcp.json.example` se deja como referencia; NO se activa salvo que el usuario quiera el músculo de runtime.

3. **Entrevista mínima para rellenar `AGENTS.md`** (una pregunta a la vez): nombre del
   proyecto, descripción, stack, módulos, modelo de permisos, comandos de quality gates,
   máximo de reintentos dev↔QA, qué decisiones requieren gate humano, y destinatario del
   entregable.

   **Pregunta también `{{CRITERIO_RIGOR_CRITICO}}`:** *«¿qué hace que un requerimiento sea
   crítico en este dominio?»*. El arnés trae los niveles (`ligero`/`estandar`/`critico`) y los
   criterios genéricos —dinero, datos personales, identidad, documento con efecto legal,
   cambio irreversible—, pero **qué REQ de este proyecto cae en cada uno lo decide el
   proyecto**. Pide ejemplos concretos: son los que el analista usará para clasificar.
   Si el proyecto entero es de bajo riesgo, dilo aquí: puede declararse `ligero` por defecto. Si el usuario prefiere, lanza al `analista-requerimientos` para esta parte.

   **Rellena también `.arnes/config.json`** (es lo que vuelve ejecutables las invariantes):
   - `codigo_app.globs`: rutas de código de la app que SÓLO el `desarrollador` puede editar
     (p. ej. `["src/*", "app/*"]`). Pregúntalas explícitamente; sin ellas la regla A1 no
     protege nada.
   - `quality_gates`: los MISMOS comandos que pusiste en `AGENTS.md §7` (deben coincidir).
   - `{{ARNES_VERSION}}`: **NO lo teclees.** Léelo de `.claude-plugin/plugin.json`
     del propio plugin (`jq -r .version`). Una versión escrita a mano se desfasa de
     la real en cuanto el arnés sube de versión, y entonces el manifiesto miente
     sobre contra qué enforcement se inicializó el proyecto.
   - El resto (`agentes`, `estados`, `requirements_dir`, `pending_approval`) viene con los
     valores por defecto del arnés; cámbialos sólo si el proyecto se desvía del estándar.
   - **Requisito:** los hooks usan `jq`. Si no está instalado, el enforcement queda inactivo
     (con aviso por stderr, no bloquea); avísale al usuario que lo instale para activarlo.

4. **Crea el marcador** `.arnes-initialized` con la fecha y la versión del arnés.

5. **Resumen:** lista lo creado y el próximo paso (normalmente: levantar el primer REQ con
   el `analista-requerimientos`).

## Reglas
- No sobrescribas archivos existentes sin avisar.
- No metas datos de un proyecto/cliente en las plantillas del plugin; el contenido específico
  va solo en los archivos del proyecto.
