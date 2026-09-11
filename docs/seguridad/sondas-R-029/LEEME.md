# Sondas de la revisión R-029 — parche v1.33.2 (`QA-P48-01`)

**Versión base sobre la que se midió:** `hotfix/1.33.2-rigor` @ **`17ec674`**, con
`git status --porcelain` **vacío** en `hooks/`, `tools/`, `.github/`, `.arnes/config.json` y
`.claude-plugin/` en el momento de medir.

**Lectores comparados** (los tres, en cada sonda):

| Etiqueta | Ruta | Qué es |
|---|---|---|
| 1.33.0 | `/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.0/hooks` | anterior al fallo |
| 1.33.1 | `/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.1/hooks` | **publicada, con el fail-open vivo** |
| 1.33.2 | `<este árbol>/hooks` | el parche |

**Plataforma:** Linux (WSL2), 12 núcleos, `loadavg` 0,78–1,41 durante las corridas. Esta máquina
**no** es el runner.

**Qué NO son estas sondas.** No son el banco ni una quality gate, y no sustituyen a ninguno: son
la reproducción de los dos hallazgos de `R-029` y del barrido de no-regresión. El banco y las
gates son de QA (`AGENTS.md` §6).

## `barrido-rigor.sh` — no-regresión y la propiedad del nivel exento

    bash docs/seguridad/sondas-R-029/barrido-rigor.sh

**Método.** 39 formas de `Rigor:` × 4 estados de `Sensible a seguridad:` (`si`, `no`, ausente, y
un valor no reconocido) = **156 combinaciones**, resueltas con `arnes_campos_normaliza` de cada
lector. Alfabeto **adversario** a propósito: paréntesis sin cerrar, sólo abriente, anidado,
vacío, doble, pegado a la clave, con texto detrás, decorado (`**`, `_`, `` ` ``), mayúsculas,
tilde, y separadores **invisibles** (TAB, NBSP, espacio de anchura cero, CR final).

**Qué debe salir.** Ni una línea `REGRESION` (ningún caso en que 1.33.2 dé un nivel **menor** que
1.33.0), y `ligero` marcado `*EXENTO-QA*` **sólo** en la forma **desnuda** con `Sensible: no`.

## `puerta-critico-mal-formado.sh` — la reproducción de `SEC-087` y `SEC-088`

    bash docs/seguridad/sondas-R-029/puerta-critico-mal-formado.sh

**Método.** Ejerce `guard-completado.sh` **de verdad** (no el lector) sobre un proyecto de prueba
desechable, con un REQ `Sensible a seguridad: no`, `QA: aprobado`, `Seguridad: pendiente`, y una
transición `Estado: en-revisión → completado` por `Edit`. Lo único que varía entre casos es el
valor de `Rigor:`.

**Qué debe salir hoy, y es el hallazgo.** `critico (por suelo)` → **deny** (correcto), pero
`critico (por suelo` (sin cerrar), `critico (`, `critico (x) y` y `criitco` → **ALLOW y sin
aviso** en las **tres** versiones: el REQ cierra sin veredicto de seguridad. Cuando `SEC-088`
quede mitigado, los cuatro últimos deben **avisar** (y seguir sin denegar, como hacen hoy `QA:` y
`Seguridad:` fuera de vocabulario). `SEC-087` es la promesa que hoy dice lo contrario de esta
tabla, y se cierra con **texto** en sus cuatro sedes, no cambiando esta conducta.
