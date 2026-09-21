# Fuente exacta de la preferencia «edita por consola» — identificada, no aplicada, nada modificado (2026-09-21)

**Encargo del propietario:** «Identifica la fuente exacta de la preferencia de edición por consola, sin aplicarla ni modificar configuraciones dentro de este encargo.»

## Resultado
La preferencia **no viene de ningún archivo de este repositorio ni del usuario**. La emite **el propio Claude Code** como `system-reminder` cuando la sesión corre en el modo de permisos **`auto`**. El texto está compilado dentro del binario del cliente.

| Dónde se buscó | Resultado |
|---|---|
| `~/.claude/settings.json` | sin `permissions.defaultMode`, sin hooks, sin la frase (sólo `model`, `enabledPlugins`, marketplace, `theme`) |
| `~/.claude/settings.local.json`, `.claude/settings*.json` del proyecto y del worktree | no existen |
| `~/.claude/remote-settings.json` | `{}` |
| `~/.claude/policy-limits.json` | restricciones de remote control; nada sobre herramientas |
| `CLAUDE.md`, `AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.claude/rules`, memoria del proyecto, `.claude/` | la frase no aparece (`grep -rIl`) |
| Plugin `arnes-juan` (agentes, hooks, skills) | no contiene la frase |
| **Binario de Claude Code** | **2 coincidencias** de `While auto mode is active` en cada versión instalada: CLI `~/.local/share/claude/versions/{2.1.266,2.1.270,2.1.272}` y extensión de VS Code `~/.vscode-server/extensions/anthropic.claude-code-{2.1.270,2.1.272,2.1.274,2.1.278}/resources/native-binary/claude` |
| Modo de esta sesión | el transcript `23a8ee5a-….jsonl` registra `"permissionMode":"auto"` en 351 entradas; versión que corre: 2.1.274 (extensión de VS Code) |

## El texto, literal del binario (2.1.274, con las variables de nombre de herramienta sin resolver)
Variante **estricta** (`h`, la que recibimos): «Do your work through the ${Bash} tool wherever it can accomplish the job: read files with cat, head, or sed -n, search with grep and find, and make file changes with sed, heredocs, or short scripts, rather than using the dedicated ${Read}, ${Edit}, or ${Write} tools. Fall back to a dedicated tool only when ${Bash} genuinely cannot do the job.»
Variante **relajada** (`y`, si `bashFirstSteer === "relaxed"`): «You can do much of your work through the ${Bash} tool when it is the simpler route … The choice is yours: prefer ${Edit} or ${Write} when a shell edit would be fragile…»
Selección: `O = e.bypass ? "While bypass permissions mode is active:\n\n"+S : e.steerOnly ? "While auto mode is active:\n\n"+S : …`. Es decir: el encabezado «While auto mode is active» sale cuando el cliente está en modo `auto`; el cuerpo es la variante estricta salvo que el cliente lleve el ajuste `bashFirstSteer` en `relaxed` (no está en ningún `settings.json` de esta máquina; su origen es interno del cliente, no se investigó más porque excede el encargo).

## Por qué importa para el arnés
`AGENTS.md` §13 lo tiene escrito: las puertas `guard-codigo` y `guard-completado` están cableadas a `Edit`/`Write`/`MultiEdit` y sobre `Bash` la cobertura es parcial a propósito. Una sesión en modo `auto` recibe en **cada** llamada a `Bash` una instrucción que empuja a editar por consola, que es exactamente la vía menos vigilada. En esta sesión la coordinadora y los cuatro agentes la rechazaron y lo registraron; la instrucción llega igual a cualquier proyecto consumidor cuyo operador use ese modo.

## Qué NO se hizo
No se cambió ningún ajuste, ni el modo de permisos, ni el plugin. No se propone remedio aquí: es información para el propietario. Método: `grep -c -a` sobre los binarios y extracción con Python de ±2 KB alrededor de la coincidencia; `jq` sobre los JSON; `grep -o '"permissionMode"…'` sobre el transcript.
