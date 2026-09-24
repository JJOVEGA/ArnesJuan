# REQ-029 · fidelidad al encargo — registro de la entrega (2026-09-23; ciclo completo, REQ sin cerrar)

**Pedido del propietario:** implementar la propuesta `propuesta.md` (revisión 2, `d4e7a4f`) con tres precisiones (un solo veredicto de QA; sin bloqueo retroactivo; partir no concede autoridad sobre el alcance). Copia **íntegra y literal** del pedido: `PENDING_APPROVAL.md` §Resueltas de la rama `feat/fidelidad-encargo` (entrada del 2026-09-23), única copia; el REQ remite a ella.
**Cabeza revisada de `main`:** `cfb1106`. **Cabeza final de la rama:** `d413405` (13 commits). **Rama aislada:** `feat/fidelidad-encargo` (worktree `/home/juan/dev/ArnesJuan-fidelidad`), local, **sin push**.

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
| `9e4980c` | **QA R-2b**: `aprobado` ratificado sobre `02ce2f6` (el delta es sólo registro; CA-11.1 13 de 13); **contador dev↔QA registrado 3 de 3 AGOTADO** por las reglas escritas (una reparación que vuelve al mismo agente gasta vuelta) |
| `50c3b17` | **Seguridad R-042-A: `aprobado` sobre `9e4980c`**; SEC-107 y SEC-105 `mitigado`; SEC-106 (`instrumento`) abierto. Juicio del auditor: **el REQ no debe cerrarse** sin el CI en verde sobre la cabeza (CA-11.4) |
| `d413405` | Coordinadora: «RETOMAR AQUÍ — REQ-029» en `docs/ESTADO.md`; rama local, sin push |

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

## Intervención acotada a SEC-106 (excepción expresa del propietario al contador agotado, 2026-09-23) — SIN push
Fuente íntegra: `PENDING_APPROVAL.md` §Resueltas, primera entrada (`12b4bbb`). Contador dev↔QA **3 de 3 conservado**; esta intervención se registra como excepcional.
| Commit | Qué |
|---|---|
| `12b4bbb` | Coordinadora: autorización íntegra en la cola |
| `699dee3` | Analista: CA-03.4 (definición única de «autorización comprobada»: copia fiel y verificable en ruta localizable, o confirmación concreta registrada; una referencia inaccesible no autoriza una **decisión nueva**; un **REQ existente aprobado** conserva su situación), CA-08.5, CA-12 ocho casos, correspondencia 36 → 55 · Desarrollador: la definición vive en la plantilla del REQ y su gemela; QA, analista y regla 1 (+ gemela) remiten («citada y verificable») |
| `47a61ef` | **QA R-3 (vuelta excepcional): `con-hallazgos`** — la definición y las remisiones pasan; cierra el hueco para decisiones nuevas (caso 6); **QA-029-02 (`contrato`)**: la frase de `agents/qa-tester.md:38-40` cierra **de más** (no la limita a la decisión nueva; choca con CA-08.5 y con la regla del analista para un REQ existente aprobado); **QA-029-03 (`contrato`, independiente)**: `docs/ESTADO.md` recibió el «RETOMAR AQUÍ» de la coordinadora en `d413405` y no está en `Archivos:` (14 tocados, 13 declarados) |
| (cabeza) | **Seguridad R-042-B**: **SEC-106 → `en-mitigación`** (control en el contrato y en sede única; pasa a `mitigado` cuando QA-029-02 quede reparado acotando la frase a la decisión nueva, QA lo valide y seguridad lo reverifique); **`Seguridad: pendiente`** porque R-042-A (`9e4980c`) no cubre este delta, que toca sedes heredables, y QA está `con-hallazgos`; «residual» y la fecha 2026-10-23 eran **propuestas del auditor**, sin efecto retroactivo |

**Cabecera de REQ-029:** `Estado: en-progreso` · `QA: con-hallazgos (R-3)` · `Seguridad: pendiente (R-042-B)` · `Hallazgos abiertos: QA-029-02 (contrato), QA-029-03 (contrato), SEC-106 (instrumento)`. **Cabeza local por delante de la remota `d413405` (PR #53), sin push por instrucción.** CI: el FAIL del run 35924622453 sobre `d413405` se conserva; sin corrida sobre la cabeza local.
**Pendientes de decisión del propietario (no se encadenan reparaciones):** QA-029-02 (una frase del desarrollador acotada a «decisión nueva», más la misma forma en la definición del analista `:52-53`, que QA anotó) y QA-029-03 (añadir `docs/ESTADO.md` a `Archivos:` por el analista, o dejar de tocarlo en esta rama); después, QA valida y seguridad reverifica SEC-106. El contador está agotado: cualquiera de esas reparaciones exige una excepción suya, o el REQ cierra con residual declarado (sólo él) o pasa a `bloqueado`.

## Corrección conjunta QA-029-02 + QA-029-03 (excepción acotada del propietario, 2026-09-23) — SIN push
Fuente íntegra: `PENDING_APPROVAL.md` §Resueltas, primera entrada (`0d29d44`). Contador dev↔QA **3 de 3 conservado**.
| Commit | Qué |
|---|---|
| `afcc6a5` | Desarrollador: `agents/qa-tester.md:38-43` y `agents/analista-requerimientos.md:52-54` acotados a «decisión nueva que requiere aprobación del propietario»; un REQ existente con contrato y aprobaciones registrados conserva su situación declarando la limitación · Analista: `Archivos:` gana `docs/ESTADO.md` (14 rutas), `Origen:` remite a la entrada de la cola, Historial; CA-03.4/CA-08.5 sin cambio; correspondencia reutilizada (55). **CA-11.1 medido: 14 de 14, 0 fuera** |
| `41d2cec` | **QA R-4 (vuelta excepcional): `aprobado`**, QA-029-02 y QA-029-03 cerrados; las dos poblaciones distinguidas con las palabras del propietario; barrido sin frases sin acotar; casos 5-8 de CA-12 sobre el texto corregido |
| (cabeza) | **Seguridad R-042-C: `aprobado` sobre `41d2cec`; SEC-106 `mitigado`** (cumple la condición fijada en R-042-B); cobertura de la firma sobre `9e4980c..41d2cec` acotada al delta, reutilizando R-042 para lo que no cambió; observación sin hallazgo: `Tocado por:` no nombra la edición del desarrollador en `afcc6a5` |
**Cabecera:** `Estado: en-revisión` · `QA: aprobado (R-4)` · `Seguridad: aprobado (R-042-C)` · `Hallazgos abiertos: (ninguno)` · cola 0. **No se cierra:** CA-11.4 exige el CI en verde sobre la cabeza y no hay corrida (sin push); la conducta de los agentes y la medición en un REQ real no están observadas. Cabeza remota del PR #53: `d413405` con el FAIL del run 35924622453 conservado.

## Push autorizado y corrida única sobre `f7a6fdf` (2026-09-24)
Verificado antes del push: SHA completo `f7a6fdf422076cb43745f9713794bbc0e104d1f8`, árbol limpio, y los commits posteriores a las firmas (`41d2cec` de QA, `f7a6fdf` de seguridad) sólo registran resultados declarados (0 cambios en sede, gemelas, agentes, skills, plantilla o criterios). PR #53 actualizado (QA R-4, seguridad R-042-C, SEC-106 mitigado, limitaciones), en borrador. **CI run 36049345243: FAILURE** — 903 · 1 · 8 = 912; único FAIL `REQ-017 CA-08 (ii) una cabecera de 200 líneas` (1,339× > 1,25×, convergió); autoprueba no corrió. Diagnóstico: `ci-f7a6fdf/DIAGNOSTICO.md`. El run 35924622453 sobre `d413405` se conserva. **Sin relanzar, sin fusión.**
