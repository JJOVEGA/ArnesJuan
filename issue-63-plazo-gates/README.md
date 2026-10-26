# Issue #63: el plazo propio de `guard-completado` y las quality gates lentas

**Fecha:** 2026-10-26. **Máquina:** Linux/WSL2. **CLI:** Claude Code 2.1.289. **Quién:** la coordinadora (Opus), por invocación directa de `hooks/guard.sh` y con `claude -p` sobre un plugin de prueba.

## 1. El cierre con una gate lenta (`repro.sh`)

El caso es un proyecto mínimo, sin datos de ningún consumidor:
- un manifiesto con una sola quality gate;
- un REQ con todo en orden para cerrar (`QA: aprobado`, `Seguridad: n/a`, `Rigor: estandar`, sin hallazgos), con `## Pendientes` vacía;
- un `Edit` de `Estado: en-revisión` a `Estado: completado` hecho por `qa-tester`.

| Árbol | Gate | Tiempo | Decisión |
|---|---|---|---|
| 1.36.2 | `true` | 0,1 s | sin decisión (deja pasar) — control |
| 1.36.2 | `false` | 0,2 s | deny por la gate — control |
| candidato `d722aed` | `false` | 0,2 s | deny por la gate — control |
| 1.36.2 | `sleep 25` | 25,2 s | sin decisión (deja pasar) |
| **1.36.0** | `sleep 35` | 35,2 s | **deny por el plazo propio** |
| **1.36.1** | `sleep 35` | 35,2 s | **deny por el plazo propio** |
| **1.36.2** | `sleep 35` | 35,2 s | **deny por el plazo propio** |
| **candidato `d722aed`** | `sleep 35` | 35,2 s | **deny por el plazo propio** |

El defecto **existe desde 1.36.0**: no lo introdujo 1.36.2. La comprobación del plazo que va detrás de las gates
cuenta el tiempo que ellas mismas consumieron.

## 2. Cuándo mata el cliente un hook `PreToolUse` (`hook-75s.sh`, `hook-620s.sh`)

El plugin de prueba registra un `PreToolUse` sobre `Bash` sin `timeout` explícito, igual que `hooks.json` del arnés.
El hook duerme N segundos y luego emite `deny`.

| Hook | Arranque | Fin del hook | Fin de la sesión | Resultado |
|---|---|---|---|---|
| 75 s | 4 s | 79 s | 82 s | **no lo mató**: el `deny` se aplicó y `x.txt` no se creó |
| 620 s | 6 s | **nunca** (no escribió su marca de fin) | 611 s | **lo mató a ≈ 600 s**. La llamada no recibió su `deny` y siguió al chequeo de permisos ordinario, que la paró por otra razón (no había permiso para la redirección) |

**Conclusión medida, una corrida por punto:**
- en 2.1.289 el cliente mata el hook a **≈ 600 s**, no a los 60 s que dan por hechos `AGENTS.md` §13, `hooks/lib.sh`, `hooks/guard-completado.sh` y el motivo de la denegación;
- un hook muerto **no deniega**: la llamada continúa sin su decisión (SEC-030).

## 3. Lo que esto no mide
- Windows/MSYS.
- Otras versiones del CLI.
- Un `guard.sh` real con gates de más de 600 s; sólo se midió el plugin de prueba.
- Qué versión de los hooks corría en el cierre de un consumidor que pasó el 2026-10-21. Por debajo de 1.36.0 no había plazo propio, y unas gates de menos de 600 s se habrían juzgado y emitido su decisión.

Coste: dos corridas de `claude -p` (0,048 y 0,050 USD).
