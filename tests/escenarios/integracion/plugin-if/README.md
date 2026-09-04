# Prueba de integración: `if` en hooks de plugin

**Qué demuestra:** que Claude Code evalúa el campo `if` de un handler declarado en el
`hooks.json` de un **plugin** antes de crear el proceso. Todo el ahorro de 1.25.0 —que un
`ls` no arranque `guard.sh`— depende de esto, y **la documentación no lo confirma para
plugins**: lo confirma esta prueba.

**Por qué no está en el banco:** cuesta una llamada al modelo. Se corre **a mano**, cada vez
que se toque `hooks/hooks.json`:

```powershell
tests/escenarios/integracion/plugin-if/run.ps1
```

**Cómo está diseñada, y por qué así:** dos handlers sobre Bash. `TODOS`, sin `if`, es el
**control positivo** — si no registra nada, el plugin no cargó y cualquier otro resultado es
un verde falso. `CON_IF` lleva `if: "Bash(touch *)"`. Se ejecutan `ls` y `touch`:

| Resultado | Significa |
|---|---|
| `TODOS` registra ambos, `CON_IF` sólo `touch` | **PASS** — `if` funciona |
| `CON_IF` registra también `ls` | **FAIL** — `if` se ignora en plugins |
| `TODOS` no registra nada | **ABORT** — el plugin no cargó; la prueba no vale |

Verificada por primera vez el 2026-09-04 en Claude Code `2.1.260`: PASS.
