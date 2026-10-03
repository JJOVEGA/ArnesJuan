# Traspaso del candidato v1.35.0 — 2026-10-03

> **Para quién:** la persona que revise y redacte las secciones técnicas pendientes del plan.
> **Qué es:** un índice de estado y de fuentes. Contiene sólo referencias y explicaciones de
> alcance: ninguna reproducción, ningún diseño y ningún texto normativo nuevo.
> **El plan sigue incompleto y no autoriza implementación** (`plan-implementacion.md`, aviso de
> cabecera).

## 1. Estado comprobado (lectura local, 2026-10-03, sin consultas de red)

| Dato | Valor |
|---|---|
| Worktree | `/home/juan/dev/ArnesJuan-v1.35` |
| Rama | `cand/1.35.0` |
| Cabeza local | `c0c8be2`, 8 commits por delante de la referencia remota, **sin push** |
| Referencia remota disponible (`origin/cand/1.35.0`) | `45368ce` |
| PR #59 | borrador, en `45368ce`. **Último dato de red: 2026-10-03, en esta misma sesión** (`gh pr view`, `git ls-remote`); no se ha vuelto a consultar |
| CI | `37032468437`, en verde **para `45368ce`**; no acredita `c0c8be2` |
| Rama de evidencia | `evidencia/prueba-despacho-2026-09-14` en `af2eddd`, local, activa en el worktree `/home/juan/dev/ArnesJuan-evidencia` |
| Instrucciones | `CLAUDE.md` → `AGENTS.md` de este worktree. §6 **no** declara la vía proporcional: rige analista → desarrollador → QA → seguridad |

**Intervención terminada:** la octava autorización (2026-10-02), con el código en `9220c71` y la
pasada correctiva en `befc17a`. **Su presupuesto está agotado.** El push y la corrida de CI que
autorizaba no se hicieron, porque SEC-124 impidió una determinación de seguridad favorable al
delta.

## 2. Decisiones registradas

**Sede:** `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-03)», con el
texto literal del propietario.

- **SEC-124:** opción B.
- **SEC-125:** reparar antes de publicar.
- **SEC-123:** corregir la descripción de F3, sin aceptar el riesgo.

**Ninguna autoriza ejecutar.** Mantienen vigentes las tres elecciones; no cambian criterios,
estados, veredictos, `Hallazgos abiertos:` ni contadores. Los tres hallazgos siguen `abierto` en
REQ-007, y el contador de REQ-023 sigue agotado (3 de 3).

Decisiones anteriores del candidato, de la primera a la octava autorización: la misma sección, en
orden cronológico inverso.

## 3. Trabajo de continuidad y lo que queda sin seguimiento

Los cinco primeros archivos de la tabla se conservan en **un commit local del 2026-10-03, sin
push**, autorizado por el propietario ese día. Es historial local y **no** una copia remota. En el
§1, la cabeza `c0c8be2` es la de antes de ese commit.

| Archivo | Contenido | Origen |
|---|---|---|
| `docs/ESTADO.md` | Bloque manual vigente (2026-10-03), bloques de historia y bloque derivado (lo reescribe el hook) | Sesiones anteriores y la actualización del 2026-10-03 |
| `PENDING_APPROVAL.md` | Entrada resuelta del 2026-10-03 y puesta al día de la entrada pendiente (decisión 11, SEC-123, SEC-125, «Espera») | 2026-10-03 |
| `CHANGELOG.md` | Entrada `[Interno]` del 2026-10-03 de este traspaso | 2026-10-03 |
| `propuesta-v1.35.0/plan-implementacion.md` | Plan **incompleto** | 2026-10-03 |
| `propuesta-v1.35.0/TRASPASO.md` | Este documento | 2026-10-03 |
| `propuesta-v1.35.0/README.md`, `SEC-047.diff`, `evidencia/` | **Histórico:** propuesta de SEC-047 del **2026-09-29** sobre `713ac68`. No forma parte del alcance actual | 2026-09-29 |

**Identidad de la propuesta histórica.** Las fechas de los archivos **no** prueban que su contenido
no haya cambiado, y calcular un hash hoy no demuestra cómo estaban antes. Lo único que se puede
afirmar sale de compararlos con una referencia previa comiteada. El 2026-10-03 se hizo esa
comparación (`git hash-object` del archivo, buscado con `git log --all --find-object`):

| Archivo (sin seguimiento) | Referencia previa con el mismo objeto | Resultado |
|---|---|---|
| `README.md` | `856d97d` (2026-09-29, `cand/1.35.0`): `docs/arnes/v1.35.0-propuesta-sec-047.md` | contenido idéntico a esa copia |
| `SEC-047.diff` | `856d97d`: `docs/arnes/v1.35.0-propuesta-sec-047.diff` | contenido idéntico a esa copia |
| `evidencia/humo.txt` | `856d97d`: `docs/arnes/v1.35.0-propuesta-sec-047-humo.txt` | contenido idéntico a esa copia |
| `evidencia/humo.sh` | `e1df4b1` (2026-09-29, rama de evidencia): `cand-1.35.0/humo.sh` | contenido idéntico a esa copia |
| `evidencia/control-positivo-inventario.md` | ninguna | **no verificado** |

`propuesta-v1.35.0/` no está entera bajo seguimiento. El commit del 2026-10-03 sólo incluye
`plan-implementacion.md` y este `TRASPASO.md`, así que el resto de la carpeta, los cinco archivos
históricos, sigue sin seguimiento: si se borra el worktree, se pierde. Comitearlo es una decisión
humana.

## 4. Fuentes que debe consultar la persona revisora

**Hallazgos y su alcance** — `docs/seguridad/registro-seguridad.md`, «Revisión R-047»:
- §2 SEC-123: el límite de F3, qué está medido y qué inferido, y el write-back exigido;
- §3 SEC-124: qué movimiento introduce, qué texto contradice y las opciones (A) y (B) con la objeción del auditor a (B);
- §4 SEC-125: el alcance del defecto, sus controles y el precedente que cita;
- §1: lo reparado en la octava autorización, en particular la fila QA-023-15 / P-023-13-A, que es la denegación explícita ya existente más próxima a SEC-124;
- §5 y §6: la no-regresión y los movimientos frente a lo publicado;
- §7: firmas y cobertura;
- §8: impedimentos;
- §9: estado de cada hallazgo.

SEC-120: la misma fuente, «Adenda a R-045 (R-045-A)», §4.

**Contrato** — `requirements/REQ-007.md`:
- CA-24 (nota de movimientos);
- CA-47 (F3, puntos 11, 16 y 17);
- CA-49;
- CA-54 (coste; QA-023-10);
- CA-66 (puntos 5 y 7);
- «Preguntas abiertas / conflictos», P-119-A.

Además, `docs/decisions/ADR-016-identidad-del-destino-y-archivo-ilegible.md` (su adenda) y, para
las notas, la sección `[1.35.0]` de `CHANGELOG.md` y «Hacia 1.35.0» en `skills/arnes-upgrade/SKILL.md`.
Si SEC-125 no se reparase, `AGENTS.md` §13 y `templates/AGENTS.md.tpl` tendrían que declararlo,
y eso exige una decisión del propietario.

**Validación de QA** — `docs/qa/REQ-023.md`, «Vuelta excepcional de la octava autorización»:
- §1 a §11 sobre `c877246`;
- §12, la re-verificación sobre `5669a2c`.

**Evidencia** — rama `evidencia/prueba-despacho-2026-09-14` (`af2eddd`), en `cand-1.35.0/`:
- `evidencia-seg-r8/` (R-047; los casos `t1` a `t10` que cita, por su identificador);
- `evidencia-qa-r8/` y `evidencia-qa-r8b/`;
- `evidencia-dev-r8/` y `evidencia-dev-r8b/`;
- r6 y r7 como antecedentes.

Fuera de `cand-1.35.0/`:
- `sec-ca54-win/`: CA-54 en Windows/MSYS;
- `sec117-real*/` y `sec119-*/`: validaciones anteriores en el host.

**Banco** — `tests/escenarios/hooks/secciones/41-…` a `45-dependencia-del-proceso-y-cr-del-comando.sh`.

**Sedes de código que nombra R-047**, sólo como referencia, porque el código es del `desarrollador`:
- en `hooks/lib.sh`, el análisis del texto de `Bash` y el detector de escrituras compartido;
- `hooks/guard-git.sh`, como precedente citado en §4.

## 5. Cobertura de QA y seguridad

**Firmas del delta:**
- QA favorable para el delta de la octava autorización (§12 del informe de QA).
- Seguridad R-047 conforme con lo reparado, a nivel de hook en Linux/WSL2.
- REQ-023, REQ-031 y REQ-001: `QA: aprobado` y `Seguridad: aprobado` sobre el código de `befc17a`, en `en-revisión` y sin cerrar.
- REQ-007: `en-progreso`, con QA y seguridad `pendiente` (R-047 §7).

**No es la aprobación del candidato.** Por el punto 7 de la octava autorización y por R-047 §7,
las firmas del delta no se presentan como aprobación completa mientras quedan impedimentos (§7 de
este traspaso).

**Lo que no está acreditado (R-047 §7):**
- banco y CI sobre la cabeza final;
- el delta de la octava autorización ejercido desde el host;
- Windows/MSYS, salvo una emulación del transporte;
- `MultiEdit` en el host;
- otras versiones del CLI;
- CA-54, SEC-115, SEC-118, SEC-120, el hueco C y P-119-A.

**Plataformas, separadas:**
- **Hook en Linux/WSL2:** medido.
- **CLI 2.1.285 dentro de WSL2 con `claude -p`:** validaciones de rondas anteriores (`sec117-real*`, `sec119-v3`, `v3b`, `r6`), con el hook de entonces.
- **Extensión de VS Code:** **sin ninguna prueba**. Las del CLI no la acreditan.

## 6. Plan: qué falta y qué debe resolver la revisión humana

**Incompletas:** §3 (diseño) y §7 (validación técnica) de `plan-implementacion.md`. Las demás
secciones existen como propuesta: orden de trabajo, correcciones documentales, archivos,
comprobación en VS Code, condiciones de salida y presupuesto.

**Impedimento:** un control de seguridad del proveedor interrumpió su redacción en la sesión
anterior y otra vez el 2026-10-03. No se reintentó, no se delegó y no se cambiaron modelos,
configuración ni permisos.

**Preguntas que la revisión humana debe contestar** para que el plan pueda encargarse (regla 1 de
`AGENTS.md` §6: resultado comprobable, criterios, qué queda fuera y cuándo detenerse):

1. **SEC-124 (B):**
   - qué alcance tiene la denegación —puertas, agentes y destinos— y qué dice su motivo explícito;
   - cuál es exactamente la restricción de uso legítimo aceptada (R-047 §3 y §6);
   - su relación con la denegación ya existente de P-023-13-A (R-047 §1);
   - si la premisa del shell que R-047 §3 señala como no escrita entra en este alcance o se queda como pregunta aparte.
2. **SEC-125:**
   - qué propiedad debe cumplir el detector;
   - qué usos legítimos deben seguir pasando;
   - si el precedente de §4 sirve o no para las otras puertas, sin darlo por hecho.
3. **Sede del contrato:** criterio en REQ-007 o REQ nuevo. El contrato lo define el `analista-requerimientos`, y que haga falta un REQ nuevo es motivo de parada del `desarrollador` (`AGENTS.md` §6, «Y las cuatro cosas que esta vía NO cambia», punto 2).
4. **Validación (§7):**
   - resultados esperados por identificador de caso de R-047, con sus controles legítimos;
   - qué árboles se usan como referencia del fail-before;
   - la no-regresión de las secciones 41 a 45;
   - que el coste no empeore, sin que eso acredite CA-54.
5. **Condición de parada y presupuesto:** confirmar o corregir la propuesta del plan (§9), que es una propuesta sin compromiso.

**F3 (SEC-123):** el plan (§4) trae una propuesta de texto. El texto normativo lo escribe el
`analista-requerimientos` en sus sedes (R-047 §2, «Write-back exigido»).

## 7. Decisiones de publicación todavía pendientes (ninguna aceptada)

- **Ejecución** de SEC-124 (B), SEC-125 y la corrección de F3: falta §3 y §7, y después una autorización de ejecución.
- **9b:** CA-54 / QA-023-10 (`PENDING_APPROVAL.md`, «Decisión 9b, preparada»).
- **Ficha 1:** SEC-115 y SEC-118.
- **Ficha 2:** el hueco C.
- **P-119-A:** F2, F5, F7 y el límite de F3.
- **SEC-120:** vence el 2026-10-29.
- **CI** sobre la cabeza final.
- **Comprobación en VS Code:** el CLI dentro de WSL y, por separado, la extensión (plan, §6).
- **Fusión, tag y publicación:** delegadas en la coordinadora **sólo** con todo en verde (`AGENTS.md` §4 y §6). Cualquier rojo o hallazgo abierto devuelve la decisión al propietario.

## 8. Siguiente paso humano

Que una persona revise las fuentes del §4 y redacte, o decida no redactar, §3 y §7 de
`plan-implementacion.md`, contestando las preguntas del §6. Hasta entonces el plan sigue
incompleto, no se despacha a ningún agente y no se abre ninguna vuelta.
