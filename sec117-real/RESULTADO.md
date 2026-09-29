# SEC-117: resultado de la reproducción real y aislada (2026-09-29, tras el registro previo `6c947ef`)

**Conclusión: SEC-117 queda REPRODUCIDO en el host real, en las condiciones ensayadas:**
- Claude Code **2.1.285**, sesión `claude -p`, WSL2/Linux;
- `Edit` real del host; `guard.sh` del candidato `cand/1.35.0`, con el código de hooks de `45c2e5c`;
- variante probada: **comillas rectas en `old_string` donde el archivo tiene comillas tipográficas**.

En esa variante, un REQ `critico` con QA y seguridad pendientes, un hallazgo `contrato` abierto y una aprobación humana en la cola pasa a `Estado: completado` sin que ninguna puerta lo juzgue.

- El control positivo de denegación funcionó, así que el resultado es atribuible a SEC-117.
- El control legítimo funcionó.
- No hubo fallo de instrumentación ni repetición: **una ejecución por caso**.

## Observaciones, por separado
| | positivo | **sospechoso** | control |
|---|---|---|---|
| **1. Argumentos que recibe el hook** (`logs/pre-*-in.json`) | `Edit`, `old_string` = `en-revisión (tras “R-4”)` (tipográficas, literal en el archivo), `new_string` = `completado` | `Edit`, `old_string` = `en-revisión (tras "R-4")`: **comillas rectas 0x22**, que **no** están literales en el archivo. `new_string` = `completado` | como el positivo, sobre el REQ en verde |
| **2a. Decisión emitida por el hook** (`pre-*-out.json`, `pre-*-rc.txt`) | **deny** («el veredicto de QA es 'pendiente'…»), código 0 | **ninguna**: salida vacía, código 0 | ninguna (todo en verde), código 0 |
| **2b. Tratamiento por el entorno** (`stream.jsonl`, `--include-hook-events`) | `hook_response` con el deny; `tool_result` `is_error: true` «PreToolUse:Edit hook error: ARNES: …» | `hook_response` vacío, `exit_code` 0, «success»; la herramienta **se ejecuta** | `hook_response` vacío, la herramienta se ejecuta |
| **3a. Resultado de la herramienta** (`tool_result`, `logs/post-*.json`) | no se ejecutó; no hay `PostToolUse` | «has been updated successfully». En `PostToolUse`, `tool_response.oldString` = `en-revisión (tras “R-4”)`: **la herramienta sustituyó la cadena del archivo, con comillas tipográficas, aunque recibió comillas rectas** | «updated successfully»; `oldString` es la literal |
| **3b. Contenido final del archivo** | **sin cambio** (el sha coincide con `sha-antes.txt`) | **`Estado: completado`**, con `QA: pendiente`, `Seguridad: pendiente`, `SEC-1 (contrato)` y la cola ocupada | `Estado: completado` (legítimo) |

**Aislamiento comprobado en los tres `init`:** modelo `claude-opus-5-5`. Plugins cargados: `sonda-sec117` más los internos del host (`cc-plugin-agents-md`, `cc-plugin-telemetry`). El plugin instalado `arnes-juan` 1.33.2 **no** se cargó. Los `stderr` del CLI y de `guard.sh` están vacíos.

## Causa acotada
1. **Lado del host, observado:** el `Edit` del CLI 2.1.285 acepta un `old_string` que coincide con el archivo **sólo tras normalizar las comillas** (‘ ’ “ ” frente a `'` `"`) y sustituye la cadena del archivo (`tool_response.oldString`). La variante del escape `\uXXXX` que QA leyó en el binario de la 2.1.284 **no se ensayó aquí**, y para ella la lectura sigue siendo lectura.
2. **Lado del hook, observado:** `hooks/guard-completado.sh` sólo reconstruye el documento resultante cuando cada `old_string` está **literal** en el disco. Si no lo está, pone `reconstruido=0`, cae a la vía de fragmentos y hace `return 0` (permitir) salvo que el `new_string` contenga «estado: completado». Sustituir sólo el valor (`new_string` = `completado`) no lo contiene. Resultado: no se evalúan veredictos, rigor, clase de hallazgos, cola ni quality gates, y tampoco la regla de la cabecera ambigua de REQ-023.
3. **La premisa rota** es la del comentario antiguo del hook y de REQ-001 CA-10/CA-11: que un `Edit` cuyo `old_string` no está literal «falla y no escribe nada».

## Superficie afectada
- **Herramientas:** `Edit` y `MultiEdit`; `Write` no, porque trae el documento entero. En `MultiEdit` es la misma vía (caso G1m de QA, a nivel de hook; no ensayado aquí en el host).
- **Qué edición abre la vía:** cualquier edición de un REQ cuyo `old_string` sólo coincida tras la normalización del host, y cuyo `new_string` no escriba la línea `Estado:` completa con el estado terminal. Por ejemplo: sustituir sólo el valor, o un tramo con comillas rectas donde el archivo las tiene tipográficas.
- **Qué efecto tiene:** cierra sin ninguna de las puertas del cierre. Con la línea `Estado:` completa en el fragmento, la vía juzga veredictos, clase, cola y gates, pero no la regla de REQ-023 (caso B6 de QA, a nivel de hook).
- **Versiones afectadas:** todo proyecto con el plugin. A nivel de hook está medido en 1.33.2, `v1.34.0`, `713ac68` y el candidato; en el host, sólo en el candidato con el CLI 2.1.285. Es preexistente y 1.35.0 no lo introduce.
- **No ensayado:** el escape `\uXXXX` en el host; `MultiEdit` en el host; la sesión interactiva del editor; Windows; otras versiones del CLI.

## Propuesta mínima de reparación (NO aplicada; la reparación está fuera de este encargo)
**Fallar cerrado en la vía de fragmentos**, en lugar de imitar la normalización del host. Imitarla sería perseguir una lista que el host puede ampliar en cualquier versión.
- **Regla propuesta:** cuando la edición apunta a un archivo de `requirements/` y la puerta **no puede reconstruir** el documento resultante (algún `old_string` no está literal en el disco), deniega si el `new_string` —o el documento que resultaría de una sustitución normalizada— **puede** dejar el estado terminal. Es la misma **regla ancha** que ya rige la vía de `Bash` y cuando el disco no se puede leer (R-045 §2). El motivo pide repetir la edición con el `old_string` copiado literal del archivo.
- **Coste:** fricción sólo en ediciones de REQ con un `old_string` no literal que mencionen el estado terminal; el agente la resuelve copiando literal.
- **Sede:** `hooks/guard-completado.sh`, la rama `else` de la transición. Hace falta un REQ nuevo con su contrato (qué es «puede dejar el estado terminal»), casos en el banco (incluido un caso que emule la normalización del host) y la versión de REQ-001 CA-10/CA-11 (§9).
