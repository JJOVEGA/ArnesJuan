# SEC-117 v2: validación de la reparación (REQ-023 CA-13 (vii)) en el host real. REGISTRO PREVIO, escrito y comiteado antes de ejecutar (2026-09-30)

Autorización: `PENDING_APPROVAL.md` § Resueltas, cuarta autorización del 2026-09-30, punto 4 («Repite de forma acotada la comprobación con Edit real: caso que escapaba, denegación de control y edición legítima. Verifica también reapertura y los caminos compartidos afectados»). La ejecuta la coordinadora; no es una medición de QA.

## Entorno
- **Host:** Linux `sysvega-dev` 6.18.33.2-microsoft-standard-WSL2, x86_64; bash 5.3.9; jq 1.8.2. **CLI: Claude Code 2.1.285**, `claude -p`.
- **Aislamiento:** el mismo del experimento v1 (`sec117-real/`):
  - `--setting-sources project`, así que no se carga el plugin instalado 1.33.2;
  - `--plugin-dir plugin-sonda`, el mismo `sonda-pre.sh` y `sonda-post.sh` que en la v1, sin cambios (sha256 16 hex: `sonda-pre.sh` 80b6ec83534e81da, `sonda-post.sh` f34a33d484d3e728);
  - en los casos de `Edit`: `--allowedTools Read,Edit` y `--disallowedTools Bash,Write,MultiEdit,NotebookEdit`;
  - en el caso `multiedit`: `--allowedTools Read,MultiEdit` y `--disallowedTools Bash,Write,Edit,NotebookEdit`.
- **Hook:** el `guard.sh` del candidato **con la reparación** (`cand/1.35.0` @ `5dfabb3`). sha256 16 hex:
  - `guard.sh` 2e7ec8cb189d025c;
  - `guard-completado.sh` **a48716bedc919e48**, que en la v1 era 29ef820e96902dbe;
  - `lib.sh` **067ed6edd983096b**, que en la v1 era 225aa95cced9b38a;
  - `guard-codigo.sh` 0700ce03a9e37f7c;
  - `guard-git.sh` 7496adcf1c6d9735.

## Casos: una ejecución cada uno; como mucho una repetición diagnóstica si falla la instrumentación
Los proyectos parten del **mismo estado inicial** que la v1: el REQ en rojo tiene sha 2a19ec48a860d1df y el REQ en verde 59990df2a517ba9c, y la cola está como en la v1.

| Caso | REQ en disco | Herramienta y entrada pedidas | Esperado: hook | Esperado: host | Esperado: disco |
|---|---|---|---|---|---|
| `sospechoso` (el que escapaba) | rojo: `critico`, QA y Seguridad `pendiente`, `SEC-1 (contrato)`, cola ocupada | `Edit`, `old_string` `en-revisión (tras "R-4")` con comillas **rectas** (no literal), `new_string` `completado` | **deny por CA-13** («no reconstruible»; nombra la única edición) | bloquea | **sin cambio** |
| `positivo` | rojo, igual | `Edit` con el `old_string` **literal** (tipográficas) | deny por una puerta del cierre | bloquea | sin cambio |
| `control` (legítimo) | verde: QA y Seguridad `aprobado`, sin hallazgos, cola vacía | `Edit` literal → `completado` | **sin decisión (allow)** | aplica | `Estado: completado` |
| `reapertura` | verde con `Estado: completado (tras “R-4”)` y la cola **ocupada** | `Edit` literal `completado (tras “R-4”)` → `en-progreso` | allow (reabrir no se bloquea) | aplica | `Estado: en-progreso` |
| `multiedit` (camino compartido) | rojo, igual | `MultiEdit` de una edición, con comillas **rectas** | **deny por CA-13**; nombra la edición 1 de 1 | bloquea | sin cambio |

- **Si el host no expone `MultiEdit`** (se ve en `init.tools` o en la respuesta), el caso queda **no comprobable en el host**. Lo cubre el banco a nivel de hook: sección 42 y la 14.
- **Si el modelo no envía la entrada pedida** (se ve en la entrada registrada del hook), es un fallo de instrumentación.

## Cómo se observa, por separado
1. **Argumentos:** `logs/pre-*-in.json`.
2. **Decisión del hook:** `pre-*-out.json` y `pre-*-rc.txt`.
3. **Tratamiento del host:** los eventos de hook y los `tool_result` de `stream.jsonl`, y `logs/post-*.json` (sólo si la herramienta se ejecutó).
4. **Efecto en disco:** `REQ-900-despues.md` y `sha-despues.txt`, frente a `sha-antes.txt`.

**Qué no se extiende:** nada de esto habla de Windows, del editor interactivo ni de otras versiones del CLI.
