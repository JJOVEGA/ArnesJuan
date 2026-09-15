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

## CON-4 — resultado observado (`f141511`, bwrap endurecido, prompt sin roles ni pistas)
**Fase 1 — la pregunta bajo prueba.** La coordinadora aplicó §14 A (5) —cita del `AGENTS.md` del proyecto,
línea 95 «autoriza la vía proporcional» y fila 102 «Sin comisión de analista»—, clasificó reparación con
contrato claro y despachó **`desarrollador → qa-tester`, sin analista**. El desarrollador corrigió `src/formato.js`
(«, » → «; »), añadió `test/formato.test.js` y actualizó la documentación del REQ (Historial; **CA-01 sin tocar**:
el defecto era del código, no del criterio). QA confirmó por escrito: *«Cabecera sin tocar los campos que
debían quedar igual: `Rigor: estandar`, `Sensible a seguridad: no`, `Seguridad: n/a` — confirmados sin cambio»*.
**→ Coincide con el resultado esperado escrito antes de ejecutar, punto por punto.**

**Fase 2 — fuera de la pregunta, y hay que verla.** QA, «intentando romper la implementación», abrió tres hallazgos:
H1 (`nombres` nulo → `TypeError`) y H2 (elementos no-string incrustados), ambos clasificados **`usuario/dinero`**
por tratarse del encabezado del informe de facturación; y H3 (`contrato`: CA-02 no define «vacío»). Como exigían
**decisiones de requisitos**, la coordinadora despachó al analista (§9 «quien transcribe no decide», fila 4), que
reescribió CA-02, añadió CA-03/CA-04 y ADR-003, **y subió `Rigor: estandar → critico`** por «dinero **o datos de
clientes**». A partir de ahí la vía pasó a fila 3: `desarrollador → qa-tester (aprobado) → auditor-seguridad`, que
cerró con `Seguridad: con-hallazgos` (SEC-001/002 `usuario/dinero`, SEC-003 `instrumento`). Total: **6 despachos,
20 turnos, 35 min 54 s, 9,45 USD reportados** por corregir un carácter de separador.

**Lectura.** (1) **El cambio de `f141511` conserva la vía corta donde corresponde**: es evidencia de este caso, no
garantía universal. (2) La escalada posterior **no la causa `f141511`**: la producen (a) QA clasificando fallos de
robustez de una función de presentación como `usuario/dinero`, y (b) el criterio crítico de este proyecto de ensayo
—«todo lo que toque dinero **o datos de clientes**»—, bajo el que casi cualquier cosa de una app de facturación es
crítica. Es el mismo patrón que en CON-1c («la fecha de corte toca dinero»). Es un dato sobre el **coste del proceso
por tarea**, que es el objetivo declarado, y se registra sin proponer nada.

**Veredicto de este caso:** favorable a `f141511` en lo preguntado. `f141511` sigue **no adoptado, no publicado**.

---

## Estado final de la validación autorizada (2026-09-14, noche) — candidato `rel/via-proporcional` @ `4a38fcf` local / `2b56cb4` remoto
- **QA (validación final):** **PENDIENTE** — el CI del PR #50 está en rojo por `REQ-024 CA-06` (`instrumento`, preexistente desde `c65ce65`); bloquea como **puerta**, no como hallazgo. `I-2` resuelto; `I-1` reclasificado a `instrumento`, abierto; `I-3` nuevo `instrumento`.
- **Seguridad (`R-035`):** estados determinados **sin firma** — `SEC-093/094/095/097` mitigados, `SEC-096` en-mitigación; **`SEC-098` `contrato` nuevo, bloquea** (la migración concede la autorización sin que el proyecto la decida). Firma condicionada a que QA resuelva; re-auditará sobre el árbol validado.
- **CI:** banco completo 1273·1·16, cuadre 1290; diagnóstico completo en `ci-pr50/DIAGNOSTICO.md` (1 FAIL preexistente, 16 SKIP con causa, 1 error de ejecución del banco no contado por el corredor, sección 33, preexistente).
- **Bloqueos del candidato:** (1) puerta requerida en rojo (`CA-06`); (2) `SEC-098`. **Sin repararse**, por instrucción del propietario. Publicación sin autorizar.

## Segunda ronda de la validación autorizada (2026-09-14, noche) — `d913575` (+ informes → `c169a4f`, R-036 local)
- **Reparados por el desarrollador:** `SEC-098` (instalación ≠ aceptación: placeholder `{{DECLARACION_VIA_PROPORCIONAL}}`, sólo un «sí» del propietario en `arnes-init` escribe la afirmativa; el merge no escribe autorización) y `CA-06` (alcance del reconocedor por propiedad, caso discriminante permanente, frase protectora intacta; `40/3` 27 = 27).
- **QA:** **favorable con reserva, levanta el PENDIENTE.** `I-1` **cerrado por el producto** (una sola evidencia de autorización; tabla, descripción y párrafo excluidos por nombre). Nuevos `instrumento`: `I-5` (el reconocedor nuevo suelta seis formas que el viejo cazaba; `ver40` enumeración sin marca) e `I-6` (`run.sh '40-*'` es filtro de nombre y da «52 PASS» sin ejecutar `CA-06`: un silencio, no un verde).
- **Seguridad (`R-036`):** sin firma. `SEC-098` **en-mitigación** por construcción; **`SEC-099` `contrato` nuevo, BLOQUEA**: la migración dice «en tus palabras» y cuatro de cinco redacciones negativas naturales se leen como sí; `SEC-100` `instrumento`. Falta para la firma: sólo `SEC-099`.
- **CI:** **no relanzado**: reparar `SEC-099` cambiaría la cabeza. El remoto sigue en `2b56cb4`.
- **Bloqueo vigente del candidato:** `SEC-099`. Sin repararse, por instrucción del propietario. Publicación sin autorizar.

## Tercera ronda (2026-09-14/15) — `6212e87` (+ informes → `a82db68`, empujado; PR #50)
- **`SEC-099`/`SEC-100` reparados** (una sede normativa en §6; «en tus palabras» retirado; promesa «ni buscándola» retirada).
- **Ensayos con agentes reales sobre `6212e87`:** `CON-AFIRM` → `desarrollador → qa-tester` sin analista ✔; `SIN-CONS` → analista primero ✔ (sesión muerta a los 24 min por `401 OAuth access token has been revoked`, entorno).
- **QA: FAVORABLE.** `I-5` valorado: **siete** formas, todas promesas que debían seguir bloqueadas; debilitamiento de instrumento, efecto presente nulo.
- **Seguridad `R-037`: `Seguridad: aprobado`** acotado. `SEC-093/094/095/097/098/099/100` mitigados; `SEC-096` en-mitigación; `SEC-101` nuevo `instrumento`. Corrige `R-036` en un eje.
- **CI (`a82db68`): 1275 · 1 · 15, cuadre 1291.** `CA-06` en verde con identificadores. **Nuevo FAIL: `REQ-017 CA-09`** (sonda de coste, SKIP en la corrida anterior; no atribuible al delta). Diagnóstico en `ci-pr50-a82db68/`.
- **Bloqueo vigente:** la puerta requerida sigue en rojo (`CA-09`). Sin repararse ni relanzarse. Sin fusión ni publicación.

## Cuarta ronda (2026-09-15) — reparación acotada de `I-5` → `eea46ad` (+ informes → local, sin empujar)
- **`I-5` RESUELTO** (QA): propiedad en los dos ejes; 7/7 regresiones muerden con fail-before medido; `v2` (fuera de las siete) también muerde; controles positivos intactos; falso positivo original no vuelve. **Fail-open del medidor** (`sin` de gawk → «0 0» enmascarado) encontrado por el desarrollador, reproducido por QA, corrección completa.
- **Seguridad `R-038`:** cobertura recuperada contra sus tres clases; #4 y #6 ejercidas fuera del banco; protecciones heredadas byte a byte iguales; **`Seguridad: aprobado` extendida a `eea46ad`**.
- **`I-7` nuevo, `instrumento`, abierto:** `\.` perdido en `awk -v` → cualquier número de 3+ dígitos casa (una fecha hace morder); anterioridad dentro de palabras. Efecto hoy nulo; **rojo latente de superficie ancha**; el auditor: su coste esperado es «el próximo estrechamiento». **Sin reparar**, por instrucción.
- **CI: no relanzado.** Remoto en `a82db68` (1275 · 1 · 15, `FAIL` `REQ-017 CA-09`, sonda de coste no atribuible al delta). Cuadre esperado 1292 sin verificar. **La decisión sobre ese gate es del propietario, aparte.**
- **Abiertos, no bloqueantes:** `I-3`, `I-6`, `I-7`, `R-1`, `SEC-096`, `SEC-101`, observación de `N-4`, `mv` sección 33. Sin fusión ni publicación.

## Quinta ronda (2026-09-15) — reparación acotada de `I-7` → `9dac46f` (+ informes → `f6912ea`, empujado; PR #50; **una** corrida de CI autorizada)
- **`I-7` RESUELTO** (QA, favorable sin defecto nuevo): patrones por `ENVIRON` (avisos `escape sequence` 12 → 0), anterioridad con borde no alfabético sin extensiones; las seis entradas falsas de `eea46ad` pasan; `1.33.0`, `v1.32.1`, `1.33`, `v2` y las 7/7 regresiones siguen mordiendo; portabilidad gawk/mawk y locale `C`/`C.UTF-8` **confirmadas por QA** (locale del runner no leído). Mayúsculas al borde escapan **y ya escapaban**: no es regresión.
- **Seguridad `R-039`: `Seguridad: aprobado` extendida a `9dac46f`**; `ENVIRON` no añade superficie (construido: la asignación-prefijo gana a la variable heredada); sin fail-open nuevo. **`SEC-102` nuevo, `instrumento`, abierto, no bloquea:** el borde derecho pierde «anteriormente», «previamente», «con anterioridad» (la figura de `I-5` con otro objeto; causa aislada al borde derecho, que no compra ningún falso positivo medido). Tercer estrechamiento silencioso del reconocedor. **Sin reparar**, por instrucción («no atiendas otros pendientes»).
- **CI (`f6912ea`): banco 1280 · 0 · 13, cuadre 1293 exacto**; los cuatro casos de `CA-06` (incl. I-5 e I-7) ejecutados y PASS; `REQ-017 CA-09` **PASS** (1,563×; el FAIL 0,976× de `a82db68` se conserva y **no queda desmentido**: misma sonda, mismo mecanismo, dos resultados). **Puerta requerida ROJA por otro paso: la autoprueba del corredor, `REQ-014 CA-18`** — `40/3` mide **554 líneas** con techo 400 (piso 78 → gobierna N). **Introducido por la cadena I-5 (477) / I-7 (554)**; la autoprueba nunca había corrido en el PR (paso `skipped` tras el rojo del banco) y nadie la corrió en local. Vía prevista por el criterio: **partir la sección**, no subir N. Diagnóstico en `ci-pr50-f6912ea/`.
- **Decisiones pendientes del propietario, aparte:** (1) autorizar la partición de `40/3` (desarrollador → QA → seguridad; `tests/` es `critico`); (2) `SEC-102`; (3) el gate `REQ-017 CA-09` como sonda variable. **Abiertos, no bloqueantes:** `I-3`, `I-6`, `R-1`, `SEC-096`, `SEC-101`, `SEC-102`, observación de `N-4`, `mv` sección 33. Sin fusión ni publicación.
