# Evidencia — prueba funcional de la vía proporcional (2026-09-14)

**Rama de evidencia, huérfana, separada del candidato.** No contiene el candidato: el plugin
probado es `rel/via-proporcional @ b3efa23`, cargado desde una copia `git archive b3efa23` con
`--plugin-dir`. Ningún credencial ni archivo global de autenticación: los listados `antes/despues.tsv`
están filtrados (`credential|token|auth|keychain|.key`) y las salidas se escanearon sin coincidencias.

## Qué hay
- `diagnostico-carga/` — la sesión mínima que acreditó la carga exclusiva del candidato (`init` con un
  solo plugin, `path=…/plugin-b3efa23`, `1 enabled, 0 disabled`).
- `sonda-escrituras/` — la sonda previa: escritura dentro del cwd creada, fuera **denegada por permisos**.
- `proyectos-base/` — los dos proyectos temporales tal como arrancó cada caso (CON = plantilla del
  candidato, declara la vía; SIN = plantilla de `f387b1c`, no la declara). Manifiesto real → hooks activos.
- `casos/<caso>/` — `prompt.txt` (sólo la tarea; sin nombrar agentes ni la regla), `salida.jsonl`
  (stream-json completo), `rc.txt`, `fin.txt`, `diff-vs-base.patch`, `estado-final/`.
- `casos/analisis.txt`, `casos/atribucion.txt` — despachos y write-back atribuidos por `parent_tool_use_id`.

## Flags de cada sesión
Ver `casos/flags.txt`: `--plugin-dir … --setting-sources project,local --strict-mcp-config
--tools Read,Edit,Write,Glob,Grep,Agent --permission-mode acceptEdits --max-budget-usd 8
--output-format stream-json --verbose`. Seis sesiones en paralelo, cada una sobre copia fresca de su base.

## Resultado (esperado según la política acordada · observado)
| Caso | Esperado | Observado | |
|---|---|---|---|
| CON-1 ordinaria | dev → QA sin analista; write-back del dev | `desarrollador → qa-tester`; write-back por el desarrollador | ✔ |
| CON-2 dinero, REQ estandar | dev → QA → seguridad | `desarrollador → qa-tester`; seguridad **no entró** (QA no aprobó); REQ quedó `estandar`/`Sensible: no`/`Seguridad: n/a`: **nadie subió el rigor** | parcial — `I-2`/`SEC-094` en la cabecera |
| CON-3 REQ nuevo | analista primero | `analista → desarrollador → qa-tester`; REQ-003 `critico`/`sí`/`Seguridad: pendiente` | ✔ |
| SIN-1 ordinaria | analista hace el write-back | `analista → qa-tester`; write-back por el analista | ✔ |
| SIN-2 dinero | procedimiento anterior | `analista → desarrollador → qa-tester`; **el analista subió el rigor a `critico`**; `bloqueado` + PENDING | ✔ (contraste con CON-2) |
| SIN-3 REQ nuevo | analista primero | `analista`; REQ-003 `borrador`, `critico`/`sí`; gate humano | ✔ |

## Limitaciones — leer antes de usar esto
1. **Sin `Bash`, QA no pudo ejecutar pruebas** (CON-1, CON-2, CON-3, SIN-2 lo declaran: «sin herramienta
   Bash»). Es un artefacto de la restricción del arnés de prueba, no de la política; detuvo la cadena
   antes del auditor en CON-2 y CON-3. Esos veredictos de QA **no acreditan ni desacreditan** la vía.
2. La coordinadora es la sesión `-p` con las instrucciones del proyecto temporal, **no** una coordinadora
   consumidora real. Los agentes **sí** son los del candidato (carga acreditada).
3. `Bash`: 0 intentos en las seis sesiones. Denegaciones reales de hooks sobre `Edit`/`Write`: 0. Los
   recuentos anteriores que decían lo contrario eran un detector casando texto de `Read`.
4. Única escritura fuera de un proyecto: el scratchpad por sesión del CLI (`/tmp/claude-1000/…/scratchpad/`).
5. Efectos en `~/.claude`: `.claude.json` reescrito por sesión (backups), `file-history/`, transcripciones,
   `known_marketplaces.json` (`lastUpdated`), `policy-limits.json`, `remote-settings.json`. Intactos: los seis
   worktrees, el candidato, `enabledPlugins` y el caché del estable.

## Coste
6 sesiones · 21,38 USD · 84 min 59 s de agente · 25 min de pared (14:44:43Z → 15:09:54Z).
