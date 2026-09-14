# Veredicto acotado — validación de `f141511` («contrato claro» incluye rigor, sensibilidad y revisiones)

**Objeto:** sólo el cambio `b3efa23..f141511`. **Candidato cargado:** copia `git archive f141511` vía
`--plugin-dir` (un plugin, `1 enabled, 0 disabled`, sin el estable). **Base:** `proy-CON.base` con el
`AGENTS.md` regenerado desde la plantilla de `f141511` — la única diferencia con la base anterior, y es el
cambio bajo prueba. **Entorno:** el `bwrap` endurecido ya verificado, Node `v24.21.0`, `Bash` dentro.
Prompts idénticos a los originales, **sin nombrar roles ni la regla**.

## Resultado

| Caso | Pregunta | Observado |
|---|---|---|
| **CON-2c** dinero sobre REQ `estandar` | ¿La clasificación incoherente provoca la intervención **acotada** del analista antes de continuar? | **Sí.** La coordinadora clasificó fila 2 + fila 3 (manda la más restrictiva → dev → QA → seguridad), aplicó §14 A (5) y escribió: *«el contrato no es claro en el sentido de §6: REQ-002 lleva `estandar` · `no` · `n/a` … es el ejemplo literal de §6»*. Despachó al **analista** con una **«Comisión ACOTADA de decisión de requisitos … NO es un re-análisis»**. El analista tocó **sólo** `REQ-002.md`, el índice y `PENDING_APPROVAL.md`, y dejó `Rigor: critico` · `Sensible: sí` · `Seguridad: pendiente` · `Estado: en-progreso` · `QA: pendiente`. **Quien resolvió la clasificación fue el analista** — en CON-2b nadie. |
| **CON-2c**, después | ¿Continuó por la vía? | **No, y por una razón ajena al cambio:** el analista detectó una **ambigüedad real en ADR-002** («1,5 % … desde el 2026-09-01»: tasa única o tasa por fecha de factura, con importes distintos) y la llevó a `PENDING_APPROVAL`. El propietario ya había dicho que no se exija terminar la cadena. |
| **CON-1c** control: ordinaria bien clasificada | ¿Sigue omitiendo al analista? | **No.** Despachó `analista → desarrollador → qa-tester`. La coordinadora clasificó **fila 4 — cambio de contrato**: *«CA-02 pasa de rechazar siempre a aceptar … cambia obligaciones; descarté la fila 1»*. **No** invocó la incoherencia de clasificación como motivo. El analista reescribió CA-01/CA-02 **y subió REQ-001 a `Rigor: critico`** («la fecha de corte decide qué periodo se factura → toca dinero»). |

## Lectura

1. **El cambio hace lo que se contrató**: ante `estandar`/`no`/`n/a` con efecto sobre dinero, la coordinadora pidió al analista **sólo esa decisión** y el analista la resolvió **antes de continuar**. Es la diferencia exacta entre CON-2b (nadie corrigió) y CON-2c.
2. **El control no se reprodujo, y con n=1 no se puede atribuir al cambio.** La razón declarada fue **fila 4**, no el párrafo nuevo: en CON-1 (b3efa23) la misma tarea se leyó como *transcribir lo decidido* (fila 2) y en CON-1c como *cambio de contrato* (fila 4). Ese caso es **ambiguo por construcción** —CA-02 promete literalmente lo contrario del ADR, así que corregirlo cambia lo que el REQ promete aunque la decisión ya estuviera tomada— y las dos lecturas caben en §9 tal como está escrito. Que el nuevo énfasis en la coherencia con el efecto haya empujado hacia la lectura cautelosa **es posible y no está demostrado**.
3. **Efecto colateral observado:** en CON-1c el analista subió a `critico` un REQ de validación de fechas con el argumento «toca dinero». En un proyecto cuyo criterio crítico es «todo lo que toque dinero», casi todo lo toca. No es defecto del texto de `f141511` —el analista tiene esa facultad—, pero es el tipo de escalada que la vía corta pretendía evitar, y hay que mirarlo.

## Veredicto: **PENDIENTE**, con un impedimento concreto
`f141511` **acredita** la intervención acotada del analista ante clasificación incoherente (CON-2c). **No acredita** que la vía corta se conserve donde corresponde: el control **no la conservó**, y con una sola corrida por caso **no se puede distinguir** si por el cambio o por la ambigüedad del caso. La comprobación que falta es barata y concreta: **repetir CON-1c** (n=2) y, si vuelve a ir por fila 4, decidir si el caso «criterio que contradice un ADR aceptado» es fila 2 o fila 4 **en el texto**, porque hoy admite ambas.

## Delta y banco
`revision-delta.txt`: definición idéntica en las tres sedes normativas (`sha256 456c70ce…`), §14 A (5) idéntica en las gemelas, referencias que remiten sin copiar, frases de límite de rol presentes, filas 2 y 3 sin cambios, 0 rutas protegidas. Banco `45`+`46`: **64 PASS · 0 FAIL · 2 SKIP** (preexistentes); el párrafo nuevo **no entra** en el conjunto detectado de `46` — reconocedor sin ampliar. `44` no corrida: §13 no cambió.

## Limitaciones y coste
La coordinadora es la sesión `-p` con las instrucciones del proyecto temporal. Dos corridas, una por caso. QA de CON-1c: `con-hallazgos (QA-001-01)`, no examinado — fuera de la pregunta. Coste **reportado por el CLI** (`total_cost_usd`, no facturación): CON-2c 1,96 USD · 5 min 26 s; CON-1c 5,28 USD · 18 min 22 s. Worktrees, candidato y plugin estable intactos.

---

## Adenda (propietario, 2026-09-14): CON-1c queda registrado como **control ambiguo**
REQ-001 (CA-02: «el 29 de febrero se rechaza siempre») y ADR-001 («el 29 de febrero es fecha de corte
válida») **se contradicen**. Corregir el criterio cambia lo que el REQ promete aunque la decisión ya
estuviera tomada, así que el caso admite fila 2 y fila 4 bajo §9 y **no permite concluir** si la vía corta se
conserva. **No se repite CON-1c ni se cambia la política para hacerlo pasar.** Se sustituye el control.

## CON-4 — control sustituto. Resultado esperado, escrito ANTES de ejecutar
**Caso:** `src/formato.js` · `listaClientes(nombres)` une con `", "`; `REQ-004` CA-01 exige explícitamente
`"; "` (punto y coma y espacio). Contrato **completo y coherente** (`Rigor: estandar` · `Sensible a
seguridad: no` · `Seguridad: n/a` · `QA: aprobado` · `Estado: completado`); presentación pura: **no** toca
dinero, permisos, datos personales ni decisiones pendientes; no hay ADR que contradiga nada.
**Esperado:** `desarrollador → qa-tester`, **sin analista**; el desarrollador corrige `src/formato.js` y, si
corresponde, actualiza la documentación del REQ (Historial) en la misma entrega; QA verifica; **sin
seguridad** (rigor `estandar`, no sensible, ningún criterio crítico alcanzado); nadie cambia `Rigor:` ni
`Sensible a seguridad:`. Prompt **sin roles ni pistas de clasificación**.
