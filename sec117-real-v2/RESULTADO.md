# SEC-117 v2: resultado de la validación de la reparación en el host real (2026-09-30, tras el registro previo `0680a2a`)

**Conclusión: en las condiciones ensayadas, la reparación funciona en el host real.** Claude Code **2.1.285**, `claude -p`, WSL2, con el `Edit` real del host y el hook del candidato `5dfabb3`.
- **El caso que en la v1 escapaba** (comillas rectas donde el archivo tiene tipográficas) **ahora se deniega por CA-13**: el host bloquea y el archivo **no cambia**.
- El control positivo sigue denegando.
- La edición legítima reconstruible y la reapertura reconstruible, esta última con la cola ocupada, siguen permitidas y se aplican.
- **El camino compartido `MultiEdit` no se pudo comprobar en el host:** el CLI 2.1.285 no expone la herramienta en la sesión. Queda cubierto a nivel de hook por el banco (secciones 42 y 14), no en el host.

Una ejecución por caso, las cinco a la vez, en proyectos y procesos independientes. Sin repeticiones.

| Caso | 1. Argumentos del hook (`logs/pre-*-in.json`) | 2. Decisión del hook | 3. Tratamiento del host | 4. Disco |
|---|---|---|---|---|
| **sospechoso** | `Edit`; `old_string` `en-revisión (tras "R-4")`, con **comillas rectas**, no literal; `new_string` `completado` | **deny, CA-13**: «no se permite la unica edicion de este Edit sobre 'requirements/REQ-900.md': esta puerta no puede reconstruir el documento…»; rc 0 | `tool_result` `is_error: true`, «PreToolUse:Edit hook error: ARNES: no se permite la unica edicion…»; no hay `PostToolUse` | **sin cambio** (el sha coincide con el inicial) |
| positivo | `Edit`; `old_string` literal, con tipográficas | deny: «el veredicto de QA es 'pendiente'…»; rc 0 | `is_error: true` | sin cambio |
| control | `Edit`; literal, sobre el REQ en verde | sin decisión (allow); rc 0 | «has been updated successfully»; `PostToolUse` con `oldString` literal | `Estado: completado` |
| reapertura | `Edit`; `old_string` `completado (tras “R-4”)` literal, `new_string` `en-progreso`, **con la cola ocupada** | sin decisión (allow); rc 0 | «updated successfully»; `PostToolUse` con `oldString` literal | `Estado: en-progreso` |
| multiedit | **el hook no se invocó**: no hay `logs/` | — | `init.tools` no incluye `MultiEdit` (ni `Edit`, desautorizada en este caso). El modelo respondió que «la herramienta MultiEdit no existe en esta sesión: no está entre mis herramientas disponibles ni entre las diferidas» | sin cambio |

**Antes y después, en el mismo caso:**
- **v1**, `1c8c81c`, con `guard-completado.sh` 29ef820e…: hook **sin decisión** → host **aplica** → REQ `critico` con todo en rojo en **`completado`**.
- **v2**, con `guard-completado.sh` a48716be…: hook **deny (CA-13)** → host **bloquea** → archivo **sin cambio**.

**Aislamiento:** en los cinco `init`, modelo `claude-opus-5-5` y plugins `sonda-sec117` más los internos del host. `arnes-juan` 1.33.2 no se cargó. Los `stderr` están vacíos.

**No se extiende a:** Windows, el editor interactivo, otras versiones del CLI ni el escape `\uXXXX` en el host. Este último está cubierto a nivel de hook por el caso C3 de la sección 42.
