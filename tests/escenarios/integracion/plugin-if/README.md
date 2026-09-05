# Prueba de integración: qué hace y qué NO hace `if` en hooks de plugin

**Qué demuestra:** que Claude Code evalúa el `if` de un handler de **plugin** antes de crear el
proceso —**sólo para prefijos de comando**— y que **una redirección nunca casa**: la separa del
comando antes de evaluar el patrón.

**Por qué existe la segunda parte, y por qué está escrita en grande.** La primera versión de esta
prueba sólo sondeaba `touch`, y pasó. Pero 1.25.0 dependía de `Bash(* >*)` para ver redirecciones,
y nadie lo sondeó. Medido en un proyecto real: `echo 'Estado: completado' > requirements/x` pasó
y creó el archivo. **Un control positivo para que `if` existe no era un control para el patrón del
que dependía todo.** Por eso desde 1.28.0 Bash lleva catch-all, y por eso esta prueba sondea la
redirección y exige que **no** case.

**Cómo se corre** (a mano, cuesta una llamada al modelo; cada vez que se toque `hooks/hooks.json`):

```powershell
tests/escenarios/integracion/plugin-if/run.ps1
```

| Resultado | Significa |
|---|---|
| `TODOS` registra los tres, `IF_TOUCH` sólo `touch`, `IF_REDIR*` nada | **PASS** — el catch-all de Bash es necesario |
| `IF_REDIR*` registra la redirección | **CAMBIO** (exit 3) — Claude Code ya ve `>`; revisar si Bash puede volver a ser selectivo |
| `IF_TOUCH` registra `ls` | **FAIL** — `if` se ignora |
| `TODOS` no registra nada | **ABORT** — el plugin no cargó |

Verificado el 2026-09-04 en `2.1.260` (sólo `touch`: PASS) y el 2026-09-05 en `2.1.261` con la
redirección: **`if` no la ve**. Ninguna versión la vio; el fallo era del patrón, no de Claude Code.
