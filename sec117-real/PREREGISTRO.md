# SEC-117: reproducción real y aislada. REGISTRO PREVIO, escrito y comiteado antes de ejecutar (2026-09-29)

Autorización: `PENDING_APPROVAL.md` § Resueltas, segunda autorización del 2026-09-29, punto 3 (candidato `cand/1.35.0`, commit `7333906`). La ejecuta la coordinadora; no es una medición de QA.

## Entorno
- **Host:** Linux `sysvega-dev` 6.18.33.2-microsoft-standard-WSL2, x86_64. GNU bash 5.3.9. jq 1.8.2.
- **CLI:** Claude Code **2.1.285**, sesión no interactiva `claude -p`. QA leyó el binario de la 2.1.284. La normalización del `Edit` en la 2.1.285 **no está leída**: es justo lo que se observa aquí.
- **Aislamiento:**
  - `--setting-sources project`: no se cargan los ajustes de usuario, así que el plugin instalado `arnes-juan` 1.33.2 no se habilita. Se comprobará en el evento `init` del flujo.
  - `--plugin-dir plugin-sonda` es el único plugin.
  - `--allowedTools Read,Edit` y `--disallowedTools Bash,Write,MultiEdit,NotebookEdit`: la única vía de escritura es el `Edit` real del host.
- **Hook utilizado:** el `guard.sh` real del candidato (`/home/juan/dev/ArnesJuan-v1.35/hooks/`, cabeza `7333906`, cuyo código de hooks es el mismo que el de `45c2e5c`). Primeros 16 hex de su sha256:
  - `guard.sh` 2e7ec8cb189d025c
  - `guard-completado.sh` 29ef820e96902dbe
  - `lib.sh` 225aa95cced9b38a
  - `guard-codigo.sh` 0700ce03a9e37f7c
  - `guard-git.sh` 7496adcf1c6d9735
- **Cómo lo invoca el plugin sonda** (`plugin-sonda/`):
  - `sonda-pre.sh` registra la entrada exacta de `PreToolUse`, se la pasa **sin cambios** a `guard.sh` y devuelve al host la salida estándar y el código de salida de `guard.sh` **tal cual**. Es sólo registro: no decide.
  - `sonda-post.sh` registra la entrada de `PostToolUse` (`tool_input` y `tool_response`). No emite nada.
  - sha256 (16 hex): `sonda-pre.sh` 80b6ec83534e81da, `sonda-post.sh` f34a33d484d3e728, `hooks.json` b577059436801dfb, `plugin.json` a4d472da92537b6e.
  - **No se desactiva ninguna puerta.**

## Proyectos temporales (sin datos reales ni archivos de consumidores)
Cada caso tiene su proyecto: `positivo/`, `sospechoso/` y `control/`. Todos llevan el manifiesto base del banco (`quality_gates` = `["true"]`).
- **Positivo y sospechoso:** `requirements/REQ-900.md` idéntico, sha256 2a19ec48a860d1df…. Su línea de estado es `Estado: en-revisión (tras “R-4”)`, con comillas tipográficas U+201C/U+201D (bytes `342 200 234`, `342 200 235`). Precondiciones que **deberían impedir el cierre**:
  - `Sensible a seguridad: sí` y `Rigor: critico`;
  - `QA: pendiente` y `Seguridad: pendiente`;
  - `Hallazgos abiertos: SEC-1 (contrato)`;
  - `PENDING_APPROVAL.md` con una entrada bajo `## Pendientes`.
- **Control:** la misma línea de estado, con `QA: aprobado`, `Seguridad: aprobado`, `Hallazgos abiertos: (ninguno)` y la cola vacía (sha256 59990df2a517ba9c…).

## Entrada exacta de cada caso (derivada del caso G2 de QA, `docs/qa/REQ-023.md` § QA-023-02)
Prompts literales en `prompt-{positivo,sospechoso,control}.txt`. La herramienta pedida es un `Edit` sobre `requirements/REQ-900.md` con `new_string` = `completado` y este `old_string`:

| Caso | `old_string` | ¿Literal en el archivo? |
|---|---|---|
| positivo | `en-revisión (tras “R-4”)` (tipográficas) | sí |
| sospechoso | `en-revisión (tras "R-4")` (rectas ASCII) | **no** |
| control | `en-revisión (tras “R-4”)` (tipográficas) | sí |

## Resultado esperado si SEC-117 existe en este host
| Caso | Hook (`guard.sh`) | Host | Archivo |
|---|---|---|---|
| positivo | **deny**: reconstruye el documento y cae en una de las puertas (QA, seguridad, contrato o cola) | bloquea el `Edit` | **sin cambio** (sha igual) |
| sospechoso | **sin salida, código 0** (vía de fragmentos: `new_string` sin «estado:» → `return 0`) | aplica el `Edit` **si** normaliza las comillas | `Estado: completado`, **cerrado con todas las precondiciones en rojo** |
| control | sin salida (todo en verde) | aplica el `Edit` | `Estado: completado` |

- **Si el host no normaliza las comillas:** el `Edit` del sospechoso falla («not found»), el archivo no cambia, y SEC-117 **no se reproduce en las condiciones ensayadas**.
- **Si el positivo no deniega:** el ensayo **no permite atribuir** el resultado a SEC-117.
- **Si el modelo no envía el `old_string` pedido** (se ve en la entrada registrada del hook): fallo de instrumentación. Se permite una sola repetición diagnóstica, conservando el intento anterior.

## Cómo se observa, por separado
1. **Argumentos que recibe el hook:** `logs/pre-*-in.json`, el JSON literal.
2. **Decisión emitida:** `logs/pre-*-out.json` y `pre-*-rc.txt`. **Tratamiento por el entorno:** los eventos de hook y los `tool_result` de `stream.jsonl` (`--include-hook-events`).
3. **Resultado de la herramienta:** el `tool_result` de `stream.jsonl` y `logs/post-*.json` (sólo si el `Edit` se ejecutó). **Contenido final del archivo:** `REQ-900-despues.md` y `sha-despues.txt`, frente a `sha-antes.txt`.

**Comprobación del montaje ya hecha, a nivel de hook y no del host** (`fixture-check-hook.txt`): pasando a `guard.sh` las tres entradas esperadas, el positivo deniega (QA pendiente) y el sospechoso y el control permiten; los archivos siguen intactos. Es un control del montaje, no la prueba.

**Presupuesto:** una ejecución por caso (`run.sh <caso>`), y como mucho una repetición diagnóstica si falla la instrumentación.
