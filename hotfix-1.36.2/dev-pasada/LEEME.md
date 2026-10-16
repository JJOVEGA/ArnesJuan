# Hotfix 1.36.2, pasada correctiva única (QA-033-01): evidencia del desarrollador

- **Fecha:** 2026-10-16, Linux/WSL2. **Base:** `hotfix/1.36.2` en `56bccba` (CA-06 reescrito por el analista), árbol de
  trabajo **sin commit**; `hooks/` sin cambios frente a `56bccba`. Cambio: sólo `tests/` (`diff-pasada.patch`).
- **Qué cambia:** los casos de procesos y reloj de la sección 49 juzgan **cada rama de la tabla de coste de CA-06
  contra su techo declarado**, sin omitir ninguna (5 ramas × 2 casos). Bajo el suelo de 50 ms: SKIP con la cifra.
- **Banco completo:** 2948 PASS, 0 FAIL, 12 SKIP (2960, cuadra), rc 0. **Autoprueba:** 117/0. **Gates §7:** verdes.
- **Inventario frente a v1.36.1** (`inventario-v1.36.1.txt` es el de `dev-fase1`): sólo los 98 casos de la 49 y la
  semilla al azar de REQ-023 CA-03.
