# Escenario — hooks de enforcement

Valida en **aislamiento** (sin Claude Code) los invariantes que el plugin baja a runtime.
`run.sh` arma un proyecto efímero con `.arnes/config.json`, alimenta JSON de `PreToolUse` a los
scripts reales de `hooks/` y verifica si deniegan o permiten.

## Correr
```
bash tests/escenarios/hooks/run.sh
```
Requiere `jq`. Sale con código ≠ 0 si algún caso falla. **44 casos.**

## Cómo se escribe un caso que sirva
Dos reglas nacidas de fallos reales:

1. **Un caso `allow` no prueba nada por sí solo.** También pasa cuando el hook ni siquiera llega
   a ejecutarse (shebang con CRLF, `jq` ausente, ruta mal normalizada). En 2026-09-01 el banco
   daba verde con el enforcement muerto en Windows. Por eso `run.sh` arranca con un **canario**:
   si el caso "coordinadora edita `src/` → deny" no deniega, aborta la corrida entera.
2. **Todo arreglo trae su caso `deny`**, y el caso se comprueba contra el código anterior:
   ```
   ARNES_HOOKS_DIR=/ruta/a/los/hooks/viejos bash tests/escenarios/hooks/run.sh
   ```
   Si un caso nuevo pasa con los hooks viejos, no está probando lo que crees.

## Casos cubiertos
| Hook | Caso | Esperado |
|------|------|----------|
| A1 `guard-codigo` | coordinadora (sin `agent_id`) edita código de app | **deny** |
| A1 | subagente `desarrollador` edita código de app | allow |
| A1 | subagente `qa-tester` edita código de app | **deny** |
| A1 | coordinadora edita un archivo fuera de los globs | allow |
| A3 `guard-completado` | REQ → `en-progreso` | allow |
| A2/A3 | REQ → `completado`, sin pendientes, gates ok | allow |
| Veredictos | `QA: pendiente`, o sensible con `Seguridad: pendiente` | **deny** |
| A2 | REQ → `completado` con aprobación pendiente | **deny** |
| A3 | REQ → `completado` con quality gate roja (cadena y objeto) | **deny** |
| Windows | `file_path` con backslashes y unidad `C:` | **deny** |
| Identidad | `agent_type` con prefijo del plugin (`arnes-juan:desarrollador`) | allow |
| Identidad | `agent_type` con prefijo de otro agente (`arnes-juan:qa-tester`) | **deny** |
| Identidad | el motivo del deny nombra al agente de forma legible | **deny** + texto |
| Identidad | `agent_type` con mayúsculas y espacios | allow |
| Identidad | coordinadora que se declara `desarrollador` (sin `agent_id`) | **deny** |
| Identidad | manifiesto con prefijo vs. `agent_type` sin prefijo (y viceversa) | allow |
| Identidad | manifiesto con prefijo + otro proveedor | **deny** |
| Bash | `>`, `>>`, `tee`, `sed -i`, `cp`/`mv` a ruta de código | **deny** |
| Bash | el motivo del deny admite que la cobertura es parcial | **deny** + texto |
| Bash | `cat`/`grep`/`sed -n`/`git commit -m` que sólo mencionan la ruta | allow |
| Bash | lee código y escribe fuera de los globs (`cp src/x /tmp/y`) | allow |
| — | sin `.arnes/config.json` el hook es inerte (Edit y Bash) | allow |

## Por qué importa
- La distinción coordinadora vs. subagente se apoya en el campo `agent_id` del input del hook
  (presente sólo dentro de un subagente). Verificado empíricamente contra `claude` CLI 2.1.183.
- `agent_type` llega **con el prefijo del plugin**: `arnes-juan:desarrollador`. Comparar en crudo
  contra el manifiesto denegaba al único agente autorizado (bug hallado en SENDA, 2026-09-02).
- La cobertura de `Bash` es **parcial a propósito**; los casos "allow" de esa sección son el
  contrato de que no hay falsos positivos sobre comandos de lectura (ver README del plugin).
