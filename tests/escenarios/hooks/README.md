# Escenario — hooks de enforcement

Valida en **aislamiento** (sin Claude Code) los tres invariantes que el plugin baja a runtime.
`run.sh` arma un proyecto efímero con `.arnes/config.json`, alimenta JSON de `PreToolUse` a los
scripts reales de `hooks/` y verifica si deniegan o permiten.

## Correr
```
bash tests/escenarios/hooks/run.sh
```
Requiere `jq`. Sale con código ≠ 0 si algún caso falla.

## Casos cubiertos
| Hook | Caso | Esperado |
|------|------|----------|
| A1 `guard-codigo` | coordinadora (sin `agent_id`) edita código de app | **deny** |
| A1 | subagente `desarrollador` edita código de app | allow |
| A1 | subagente `qa-tester` edita código de app | **deny** |
| A1 | coordinadora edita un archivo fuera de los globs | allow |
| A3 `guard-completado` | REQ → `en-progreso` | allow |
| A2/A3 | REQ → `completado`, sin pendientes, gates ok | allow |
| A2 | REQ → `completado` con aprobación pendiente | **deny** |
| A3 | REQ → `completado` con quality gate roja | **deny** |
| — | sin `.arnes/config.json` el hook es inerte | allow |

## Por qué importa
La distinción coordinadora vs. subagente se apoya en el campo `agent_id` del input del hook
(presente sólo dentro de un subagente). Verificado empíricamente contra `claude` CLI 2.1.183.
