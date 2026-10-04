# Prueba en el host: CLI dentro de WSL2, cabeza 5d810f0 (hooks idénticos a a51dc5b). Registro previo, escrito ANTES de ejecutar (2026-10-03)

**Pedido del propietario (2026-10-03):** «tres comandos desde Claude Code: un heredoc normal a docs/, una escritura partida con \ hacia docs/, y un echo x > src/algo desde la coordinadora para ver un deny real con su motivo. Anota la versión del CLI y qué viste.»

**Capa:** Claude Code **2.1.285**, `claude -p`, WSL2 (Linux 6.18), uid 1000. Es el **CLI dentro de WSL**, no el panel de la extensión de VS Code: eso no se ejerce aquí.
**Hooks:** sonda `plugin-sonda` (la de `sec119-r6`), que pasa la entrada sin cambios a `/home/juan/dev/ArnesJuan-v1.35/hooks/guard.sh` y registra entrada, salida y código. Con `--setting-sources project` no se carga el plugin 1.33.2 instalado. sha256 (16 hex) en `hooks-sha.txt`.
**Proyecto:** uno temporal por caso, con el manifiesto de `sec119-r6` (`codigo_app.globs` = `src/*`, `app/*`; agente de código `desarrollador`). La sesión principal llega sin `agent_type`, es decir, como coordinadora. Herramientas: sólo `Bash`.

| Caso | Comando que se pide ejecutar, una vez | Esperado (decisión del hook · disco) |
|---|---|---|
| h1-heredoc | `cat > docs/nota.md <<'EOF'` / `hola` / `EOF` | allow · `docs/nota.md` creado con «hola» |
| h2-continuacion | `echo x > \` / `docs/partida.md` (barra invertida y salto entre el operador y el destino) | allow (destino fuera del ámbito; CA-47 punto 19: sin deny por la mera continuación) · `docs/partida.md` creado con «x» |
| h3-src | `echo x > src/algo` | deny, con un motivo que cita `src/algo` como código de la app · `src/algo` no se crea |

**Qué se observa, por separado:** la entrada que recibe el hook (`logs/pre-*-in.json`, sobre todo `tool_input.command`), su decisión y su motivo (`pre-*-out.json`), lo que hace el host (`stream.jsonl`) y el disco (`arbol-despues.txt`).
**Fallo de instrumentación:** que el comando que llega al hook no sea el pedido (en h2, que no lleve la barra invertida seguida de un salto de línea), o que el modelo no lo ejecute. En ese caso el resultado no cuenta.
**Una ejecución por caso. Sin repeticiones** para buscar otro resultado.
**No se extiende a:** el panel de la extensión, Windows/MSYS, `MultiEdit`, otras versiones del CLI, otros agentes ni otras formas de LC/HC.
- Defecto del instrumento, corregido ANTES de ejecutar: el primer prompt-h1 quedó cortado por un delimitador de heredoc repetido al escribirlo; se reescribió. Ningún caso se había ejecutado.
