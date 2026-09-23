# REQ-029 · fidelidad al encargo — registro de la entrega (2026-09-23; en curso hasta la firma de seguridad)

**Pedido del propietario:** implementar la propuesta `propuesta.md` (revisión 2, `d4e7a4f`) con tres precisiones (un solo veredicto de QA; sin bloqueo retroactivo; partir no concede autoridad sobre el alcance). Copia **íntegra y literal** del pedido: `PENDING_APPROVAL.md` §Resueltas de la rama `feat/fidelidad-encargo` (entrada del 2026-09-23), única copia; el REQ remite a ella.
**Cabeza revisada de `main`:** `cfb1106`. **Rama aislada:** `feat/fidelidad-encargo` (worktree `/home/juan/dev/ArnesJuan-fidelidad`), local, **sin push**.

## Ciclo (vía negativa del autoalojamiento: analista → desarrollador → QA → seguridad)
| Commit | Qué |
|---|---|
| `1e3ac6f` | Analista: REQ-029 (`pendiente`, 14 criterios, correspondencia con el encargo rellenada) + fila de Historial en REQ-025 (la regla 1 gana un párrafo por REQ-029; las firmas R-4/R-041-A no lo cubren) + índice |
| `6860226` | Coordinadora: decisión del propietario en `PENDING_APPROVAL.md` §Resueltas (figura SEC-104) |
| `0739d57` | Desarrollador: párrafo en la regla 1 de §6 y gemela; `Origen:` identificable y «Correspondencia con el encargo» en la plantilla del REQ y gemela; analista (fuente, correspondencia, partición sin autoridad de alcance, sede única de la no retroactividad, DoR); QA (un solo veredicto con evidencia de contraste); «Hacia 1.35.0» en `arnes-upgrade`; `Estado: en-revisión` |
| `d1c65ac` | Analista (antes de QA): `Archivos:` + `PENDING_APPROVAL.md`; CA-02 mide sólo las secciones espejo |
| `9f8b311` | **QA R-1 (vuelta 1 de 3): `con-hallazgos`** — los 14 criterios pasan en el texto; **QA-029-01 (`contrato`)**: la correspondencia del propio REQ no coincidía con su fuente porque la coordinadora transcribió el pedido «literal en lo esencial» con cortes sin marca; banco local 908 · 0 · 4; cuatro ejemplos acotados en `docs/qa/REQ-029.md` |
| `c0dd622` | Coordinadora: fuente íntegra del pedido en la cola |
| `efa1c5c` | Analista: write-back de QA-029-01 (`Origen:` remite a la cola; correspondencia 23 → 36 filas: 34 `cubierta`, 2 `sustituida`, 0 omitida/excluida/añadida; CA-11.4 gana «cualquier validación de CI pendiente debe quedar identificada») |
| `1117204` | **QA R-2 (vuelta 2 de 3): `aprobado`**, QA-029-01 cerrado; contrastó el REQ con la fuente íntegra sin diferencias no autorizadas |
| `ec7b2fe` | **Seguridad R-042: `con-hallazgos`, sin veto** — delta normativo y gobernanza conformes; SEC-107 (`contrato`: el registro de seguridad no estaba en `Archivos:`), SEC-105 y SEC-106 (`instrumento`) |
| `02ce2f6` | Analista: write-back SEC-107 (13 rutas) y SEC-105 (`Tocado por:`); coordinadora: línea de la cola. **CA-11.1 medido: 13 de 13, 0 fuera** |
| (pendiente) | QA R-2b acotado sobre `02ce2f6`; seguridad R-042-A |

## Crecimiento neto del texto (medido `cfb1106` → `02ce2f6`, `wc -c`)
| Archivo | Neto |
|---|---:|
| **`CLAUDE.md` + `AGENTS.md` (obligatorio de arranque)** | **+1 428 B = +2,2 %** (63 619 → 65 047) |
| `templates/AGENTS.md.tpl` | +1 428 |
| `requirements/README.md` (+ índice) / `templates/requirements-README.md.tpl` | +2 084 / +1 549 |
| `agents/analista-requerimientos.md` / `agents/qa-tester.md` | +2 946 / +1 682 |
| `skills/arnes-upgrade/SKILL.md` | +2 455 |
Mecanismo (`hooks/`, `tools/`, `tests/`, `.github/`, `.arnes/`, `.claude-plugin/`): **0 archivos**. Gates §7 en verde.

## Lo que la entrega hizo visible en su primer uso
La propia regla midió a la coordinadora: la transcripción «literal en lo esencial» del pedido recortó pasajes sin marca y QA lo detectó **contrastando con la fuente** (13 filas ausentes, 2 relaciones mal asignadas, 1 atribución errónea). Es un dato de este REQ; **no** es la medición «en el primer REQ real», que sigue pendiente y sin dueño.

## Qué no acredita
Conducta de los agentes (revisión de texto y ejemplos inventados); CI `hooks-en-linux` (sin corrida por falta de push, identificado con la cabeza); publicación; consumidores (nada llega hasta publicar y migrar); reducción de tokens, tiempo o dinero.
