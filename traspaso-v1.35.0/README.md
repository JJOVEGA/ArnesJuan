# Traspaso para la sesión nueva de preparación de v1.35.0 (2026-09-29)

**Por qué hay traspaso.** El propietario exige que este encargo (propuesta de SEC-047, fichas de SEC-115 y del hueco C, alcance de v1.35.0) se ejecute en una sesión nueva iniciada desde un worktree basado en `main`, con el `AGENTS.md` de `main` realmente cargado. La sesión coordinadora vigente corre en `/home/juan/dev/ArnesJuan` (rama `rel/registro-1.33.0`) y carga ese `AGENTS.md` (503 líneas, con §14 y la celda ancha de §13); no puede descargarlo, así que detiene este encargo y lo traspasa.

## Ruta y comando de arranque
- **Worktree preparado:** `/home/juan/dev/ArnesJuan-v1.35` — rama `prep/v1.35.0`, cabeza `713ac68f67f3224c8ecaac80881a83b964603c62` = `origin/main` (árbol limpio, sin cambios). Comprobación al arrancar: `git rev-parse HEAD` y `git status --porcelain`; declarar cualquier diferencia con `713ac68`.
- **Comando:** `cd /home/juan/dev/ArnesJuan-v1.35 && claude` (sesión interactiva nueva; el plugin instalado 1.33.2 provee hooks y agentes como siempre).
- **Verificación de instrucciones, ya hecha desde este worktree con `claude -p --allowedTools ""` (sonda-v135.json):** la sesión nueva recibe `CLAUDE.md` → `@AGENTS.md` de este worktree: 807 líneas, 14 secciones (`## 0` a `## 13`), **sin** «## 14. Reglas de trabajo de la sesión coordinadora», **con** «vía proporcional» en §6. La sonda respondió «sí contiene R-024» citando el `git status`/commits recientes del contexto, no el `AGENTS.md` (que tiene 0 apariciones): repetir la comprobación al arrancar con `grep -c R-024 AGENTS.md` = 0. Regla para la sesión nueva: verificar por sí misma con el mismo método y no fiarse de esta nota.

## El encargo, tal como lo dictó el propietario (íntegro, sin recortes)
> El objetivo es preparar v1.35.0 con un alcance finito. REQ-031 ya está integrado; no reabras su reparación ni repitas sus revisiones.
>
> Autorizo preparar una propuesta concreta para SEC-047 y consolidar las decisiones de publicación. No autorizo todavía implementar esa reparación ni aceptar los riesgos pendientes.
>
> **1. Empezar con el contexto correcto**
>
> Este encargo debe ejecutarse en una sesión nueva, iniciada desde un worktree basado en main. La referencia conocida es `713ac68f67f3224c8ecaac80881a83b964603c62`; comprueba la cabeza actual y declara cualquier diferencia.
>
> Verifica qué CLAUDE.md y AGENTS.md recibe realmente la sesión. No basta con cambiar de directorio ni comparar una sección mientras sigue cargado el AGENTS.md de `rel/registro-1.33.0`.
>
> Si no puedes iniciar una sesión nueva, prepara un traspaso breve con ruta y comando de arranque y detén sólo este encargo. No modifiques configuraciones globales ni reconcilies la rama antigua.
>
> **2. SEC-047: propuesta acotada antes de implementar**
>
> Reutiliza las reproducciones y el inventario existentes. La propiedad buscada es que una variante de una clave de control no pueda convertirse silenciosamente en ausencia y reducir el rigor o esconder un hallazgo bloqueante.
>
> Presenta un diff sin aplicar que:
> - Delimite qué claves y variantes reconoce o rechaza.
> - Mantenga la coherencia entre los lectores del arnés.
> - Detecte contradicciones entre declaraciones equivalentes sin elegir silenciosamente la favorable.
> - Preserve las ausencias legítimas, la prosa que no es un campo y la reapertura de REQ.
> - Explique la compatibilidad con las cabeceras existentes.
>
> No propongas «normalizar todo Unicode» ni una lista ilimitada de caracteres. Define una frontera comprobable y declara qué queda fuera.
>
> Incluye los casos mínimos de aceptación y rechazo, las sedes afectadas y qué contrato habría que versionar. No ejecutes el banco completo ni abras el ciclo completo de agentes para preparar esta propuesta. No crees requisitos duplicados si el trabajo ya tiene sede.
>
> **3. Decisión consolidada de publicación**
>
> Prepara una ficha breve y separada para SEC-115 y el hueco C:
> - Consecuencia reproducida y entorno donde se comprobó.
> - Protección efectiva hoy y parte que depende de la disciplina del agente.
> - Alternativa de reparar antes de publicar.
> - Alternativa de aplazar, con responsable, fecha de revisión propuesta y condición que obligaría a revisarlo antes.
> - Limitaciones que deberán figurar en las notas y qué no podría prometer la versión.
>
> Las fechas y los aplazamientos son propuestas, no decisiones mías. No marques riesgos aceptados, no retires entradas de la cola y no abras su implementación.
>
> Una puerta posterior sigue siendo una propuesta de detección; no la presentes como prevención, recuperación ni mitigación disponible.
>
> **4. Alcance real de v1.35.0**
>
> Describe lo incluido por el diff entre v1.34.0 y main, reutilizando los registros existentes. Un REQ incompleto no queda fuera del paquete por su estado: distingue las partes construidas de las pendientes, especialmente REQ-025.
>
> La versión saldrá de main. Reconciliar `rel/registro-1.33.0` queda fuera y no es condición de publicación.
>
> **5. Entrega única y límites**
>
> Entrega:
> - Contexto y SHA comprobados.
> - Diff propuesto para SEC-047, alcance y estimación de esfuerzo.
> - Dos decisiones concretas sobre SEC-115 y C.
> - Alcance de la versión y condiciones pendientes para publicarla.
>
> Conserva la propuesta y su evidencia sin alterar código ni normas vigentes. Sin push, PR nuevo, fusión, cierre de requisitos, cambio de versión, tags ni publicación. Sin cambios de modelos, sondas, workflow, ruleset, rotación o consumidores.
>
> Al terminar, detente. La siguiente autorización será sobre este diff y estas decisiones; no propongas otra investigación general.

## Evidencia y sedes existentes que la sesión nueva debe reutilizar (rama `evidencia/prueba-despacho-2026-09-14`, sólo lectura)
- **SEC-047 (definición en `main`):** `docs/seguridad/registro-seguridad.md:3633` (`### SEC-047`), cláusula de subida en `:3683-3685` (su premisa no se cumple contra el §13 de `main`, R-044-D). Lector de claves: `hooks/lib.sh` (`arnes_norm_clave`, `arnes_campo_linea`, `arnes_campos_req`, `arnes_campos_normaliza`); lo comparten `guard-completado`, `tools/arnes-lectura.sh` y el bloque derivado de `docs/ESTADO.md`.
- **Reproducciones ya hechas (no repetir):** R-044 §7 y R-044-A §1 (allow por ausencia con `Hallazgos  abiertos:`, ZWSP/NBSP/BOM en la clave, `HALLAZGOS ABIERTOS:`, `- Hallazgos abiertos:`, `SENSIBLE A  SEGURIDAD: sí` con `Rigor: ligero`); QA-031-01 (`docs/qa/REQ-031.md` § Vuelta 2); **inventario CA-A17** de las 29 cabeceras con control positivo (`docs/qa/REQ-031.md` § Vuelta 3): 0 claves ignoradas, «sin exposición actual, no sin defecto»; `evaluacion-2026-09-27/` (método de reproducción con la puerta real); gramática vigente de `Hallazgos abiertos:` en `requirements/README.md` § «Clases de hallazgo» y ADR-013 (qué lee el lector y qué no).
- **SEC-115:** R-044-C §2 y `docs/PENDIENTES.md` (`QA: pendiente (…)` de ≈255 KB → 73,6 s; `Write` de 2 MB → 80 s por `arnes_sin_cr_transporte`; techo de `Hallazgos abiertos:` ya medido antes de normalizar). **CA-A16** (`req-031/ca-a16/`): en el CLI 2.1.272 un hook `PreToolUse` que agota su timeout sin decisión deja pasar el `Write`; control `deny` bloquea; no comprobado en el editor ni en Windows.
- **Hueco C:** `evaluacion-2026-09-27/C-escrituras-interprete.txt` (python/node/script escriben código protegido; `echo >`, `sed -i`, `dd`, heredoc y `Edit` deniegan; sin `PostToolUse`); `AGENTS.md` §13 (main) lo declara.
- **Alcance de v1.35.0:** merges en `main` desde `v1.34.0`: `cfb1106` (PR #52, REQ-025 entrega 1), `c4d92c0` (PR #55, REQ-030), `11c5df2` (PR #53, REQ-029), `a7a60c2` (PR #56, cierres REQ-029/030), `713ac68` (PR #58, REQ-031). Versión en `plugin.json`/`marketplace.json`: 1.34.0; instalada: 1.33.2. REQ-025 sigue `en-revisión` en `main` (entrega 1 construida; 1b y REQ-028 no iniciados: ver su cabecera y `docs/qa/REQ-025.md`). Cola: una entrada pendiente («Decisión de publicación de 1.35.0», puesta al día el 2026-09-28) que impide `completado`.
- **Decisiones ya registradas del propietario:** `PENDING_APPROVAL.md` § Resueltas (las entradas de REQ-030/031 de 2026-09-26 a 2026-09-28), en `main`.
