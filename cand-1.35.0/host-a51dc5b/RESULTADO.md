# Resultado: prueba en el host, CLI dentro de WSL2, cabeza 5d810f0 (2026-10-03)

Claude Code **2.1.285**, `claude -p`, WSL2. La sonda pasa la entrada sin cambios a `guard.sh` del worktree; hooks con sha256 sin cambios antes y después. Plugins cargados: `sonda-sec117` y los del host (`cc-plugin-*`); **`arnes-juan` 1.33.2 no se cargó**. Una sesión por caso, una ejecución, sin repeticiones. Sesión principal sin `agent_type` (coordinadora).

| Caso | Lo que recibió el hook | Decisión del hook | Host | Disco |
|---|---|---|---|---|
| h1-heredoc | el heredoc tal cual, con sus saltos de línea | allow (sin salida, rc 0) | ejecutó | `docs/nota.md` = «hola» |
| h2-continuacion | `echo x > \` + salto + `docs/partida.md` (barra y salto presentes) | allow (sin salida, rc 0) | ejecutó | `docs/partida.md` = «x» |
| h3-src | `echo x > src/algo` | **deny**: «ARNES: el comando escribe en 'src/algo', que es código de la app; sólo el agente 'desarrollador' puede hacerlo (intento de la sesión coordinadora)…» | bloqueó y mostró ese motivo al modelo | `src/algo` no existe |

Los tres, como se registraron antes. No hubo fallos de instrumentación en la ejecución (el defecto del prompt de h1 se corrigió antes).
**No ejercido:** el panel de la extensión de VS Code, Windows/MSYS, `MultiEdit`, otros agentes y las formas HC/LC que deniegan (estos tres casos son dos controles legítimos y una denegación de siempre).
