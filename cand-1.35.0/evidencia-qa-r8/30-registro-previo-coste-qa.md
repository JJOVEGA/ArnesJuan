# Registro previo de la medición de coste de QA — octava autorización (escrito 2026-10-02T13:12:03-06:00, ANTES de ejecutar)

- **Procedimiento:** el registrado por el desarrollador antes de medir, `f224feb` (`evidencia-dev-r8/00-registro-previo-coste.md`),
  **P1** (QA-023-14) y **P3** (camino común, informativo). P2 (CA-54) no se repite: no es objeto de esta comisión.
- **Sondas:** copias literales de `sonda-coste-r8.sh` y `coste-comun-r8.sh` (`e0f006d`), con dos únicos cambios: el
  directorio de trabajo (`/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8/coste`) y los árboles, que son los materializados por QA y verificados por oid
  (`00-arboles.txt`): candidato = worktree (`HEAD:hooks` a636553, lib.sh 31176f7f), `3bc7d3c` (edff8ac5), `cd6afa6` (b12ee3dd).
- **Tamaños:** los ya usados, sin cambio: Bloque 1 N ∈ {20 000, 50 000, 100 000} (fp, fp-sin-cr, tool, cwd); Bloque 2 fp con CR
  N ∈ {200 000, 300 000, 400 000, 600 000}; Bloque 3 Bash + tool_input.file_path N ∈ {100 000, 500 000} y control sin CR de 500 000.
- **Una corrida por celda**, por `guard.sh`, `timeout 120`, orden candidato, 3bc7d3c, cd6afa6. P3: mínimo de 5 corridas.
- **Lo que se afirma:** si el candidato crece o no más que linealmente frente a `cd6afa6` en esos tamaños, y si el camino común
  cambia. **No** acredita CA-54, SEC-115 ni Windows. **No se repite** para buscar una cifra; una corrida invalidada por el
  instrumento se conserva marcada y se repite una vez, diciendo por qué.
- **Condiciones:** Linux/WSL2; sin otras mediciones de QA en curso (el banco y las baterías ya terminaron); se anota loadavg.
