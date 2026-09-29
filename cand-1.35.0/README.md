# Evidencia del candidato 1.35.0 (rama `cand/1.35.0`, PR #59 en borrador) — 2026-09-29

Salidas íntegras de las comisiones que construyeron y validaron el candidato. Se copiaron desde el scratchpad de la sesión coordinadora, que es efímero. Los registros que valen como contrato están en el candidato:
- `requirements/REQ-023.md`
- `docs/qa/REQ-023.md`
- `docs/seguridad/registro-seguridad.md` § R-045
- `PENDING_APPROVAL.md`
- las entradas de `CHANGELOG.md` del 2026-09-29

Esta carpeta es su respaldo en bruto. No es una sede normativa.

## Contenido

| Carpeta | Comisión | Cabeza |
|---|---|---|
| `evidencia-dev-v1/` | desarrollador, implementación de REQ-023: banco completo, sección 41, fail-before contra `713ac68` y 1.33.2, inventario, observaciones de reloj y de procesos | `ce60bae` + árbol de trabajo → `ad793ab` |
| `evidencia-version/` | desarrollador, preparación de 1.35.0: gates, versión, autoprueba, secciones lectoras y logs de CI de `main` releídos | `78e3d2f` + árbol de trabajo → `ace43c2` |
| `evidencia-qa-v1/` | QA, vuelta 1 de 3: banco completo, casos propios, fail-before re-derivado, frontera (g) y QA-023-02 | `ace43c2` |
| `evidencia-dev-v2/`, `evidencia-dev-v3/` | desarrollador, comentarios de las vueltas 2 y 3: prueba de «sólo comentarios» por parser, con control positivo | `0fd3879` → `eeb627d`; `ed497a2` → `c4cc32c` |
| `evidencia-qa-v2/`, `evidencia-qa-v3/` | QA, vueltas 2 y 3: banco completo, barridos por propiedad y matriz de la propiedad (37/37) | `eeb627d`; `c4cc32c` |
| `verif-v3/` | coordinadora: comprobación previa del texto de la vuelta 3 contra la puerta real (10/10). No es medición de QA | `ed497a2` + árbol de trabajo |
| `evidencia-seg/` | auditor, revisión R-045: sondas por `guard.sh` y SEC-117/SEC-118 | `31d2a21` |
| `qa/` | guiones de QA | — |
| `humo.sh`, `humo.txt` | ensayo preliminar de la propuesta del 2026-09-29, sobre una copia fuera del árbol. **No acredita nada** | `713ac68` + diff propuesto |
| `ci-historico-main.md` | CI de `main` desde `v1.34.0`, releído con `gh run view --log` | — |
| `ci-cand-45c2e5c/` | CI del candidato sobre la cabeza del PR #59 | `45c2e5c` |
| `autorizacion-2026-09-29.txt` | copia de trabajo del texto del propietario. La copia de registro es `PENDING_APPROVAL.md` § Resueltas | — |

**Excluido a propósito:** `qa/cc-strings.txt` (54 MB). Es un volcado de cadenas del binario del CLI de Claude Code 2.1.284 que QA usó para leer la normalización del `Edit` (QA-023-01 y QA-023-02). Es contenido de terceros y no se versiona. Se reproduce extrayendo las cadenas del binario instalado.

**Lo que ninguna de estas salidas acredita:** rendimiento. Las cifras de reloj son observación. Tampoco acreditan la conducta del CLI en una sesión real: el lado de la herramienta de QA-023-02 está leído y emulado, no ejecutado.
