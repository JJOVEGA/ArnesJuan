# ESTADO — ArnesJuan

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparece un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.

> Nota de aislamiento — 2026-09-10: existe un candidato local separado, basado en
> `v1.33.0`, para corregir el rigor con matiz y la detección de firmas de Seguridad.
> No es una publicación ni sustituye este tablero. Su estado y sus límites están en
> `docs/estabilizacion/`.

## ⏸ RETOMAR AQUÍ — REQ-029 fidelidad al encargo: entrega implementada y firmada, SIN cerrar (2026-09-23)

**Este bloque manda en esta rama (`feat/fidelidad-encargo`, local, sin push); el de REQ-025 de abajo es histórico de `main`.**
Pedido íntegro del propietario: `PENDING_APPROVAL.md` §Resueltas (2026-09-23), única copia; REQ-029 §Trazabilidad remite a ella.
**Ciclo completo por la vía negativa:** analista (`1e3ac6f`, `d1c65ac`) → desarrollador (`0739d57`) → QA R-1 `con-hallazgos` (`9f8b311`, QA-029-01
`contrato`: la correspondencia del propio REQ no coincidía con la fuente porque la coordinadora transcribió el pedido con cortes sin marca)
→ fuente íntegra en la cola (`c0dd622`) → write-back (`efa1c5c`) → QA R-2 `aprobado` (`1117204`) → seguridad R-042 `con-hallazgos`
(`ec7b2fe`, SEC-107 `contrato`: registro de seguridad fuera de `Archivos:`) → write-back (`02ce2f6`) → QA R-2b ratifica sobre `02ce2f6` y
registra el **contador dev↔QA 3 de 3 AGOTADO** (`9e4980c`) → **seguridad R-042-A `aprobado` sobre `9e4980c`**; SEC-107 y SEC-105 mitigados.
**Cabecera:** `Estado: en-revisión` · `QA: aprobado (R-2/R-2b)` · `Seguridad: aprobado (R-042-A)` · `Hallazgos abiertos: SEC-106 (instrumento)` · cola 0.
**No se cierra, y la puerta ya no lo impediría:** CA-11.4 exige el CI `hooks-en-linux` en verde sobre la cabeza que se cierre y **no hay corrida**
(sin push, por instrucción). Cerrar y empujar son decisiones del propietario. Tampoco están acreditadas —y cerrar no las acreditaría— la
**conducta de los agentes** (QA validó texto y ejemplos inventados) ni la **medición en un REQ real** (CA-14, pendiente y sin dueño).
**Crecimiento medido** (`cfb1106` → cabeza): texto obligatorio de arranque `CLAUDE.md` + `AGENTS.md` **+1 428 B (+2,2 %)**; gemelas idénticas
en sus secciones espejo; **0** archivos de mecanismo; gates §7 en verde; banco local 908 · 0 · 4 (QA R-1). **Abiertos con dueño, sin trabajo:**
SEC-106 (`instrumento`, coordinadora; revisión propuesta 2026-10-23), OBS-029-A (nota en REQ-029). Evidencia: rama de evidencia,
`fidelidad-encargo/README.md`. Fuera de alcance y sin tocar: la demo, REQ-019, otras entregas de REQ-025, sondas, hooks, versión, consumidores.

## ⏸ RETOMAR AQUÍ — REQ-025 entrega 1 (coordinación orientada a entregas), 2026-09-21

**Este bloque SUSTITUYE a los de más abajo, que quedan como históricos.** Rama `feat/req-025-coordinacion-entregas`
(desde `main` = `v1.34.0`). **Estado: `bloqueado` con alcance** —acción impedida **cerrar** (marcar REQ-025 como
`completado`); implementar y probar no—, tras agotar las 3 vueltas con `QA: con-hallazgos` (R-3): lo encargado a
las tres vueltas está reparado (8 de 9 hallazgos de QA cerrados); queda **QA-025-08** (`instrumento`): la conducta
de la coordinadora ante un **hallazgo de QA** no fue observada en el ensayo S1…S4 (S4 no se disparó; el bloqueo se
conservó por el veto de seguridad, vía que esta entrega no modifica). **La opción A (observación acotada sólo de S4)
fue autorizada y consumida el 2026-09-21** (`ENS-S4-P` sobre `9f908d9`): **NO OBSERVADO** por la rama benigna —el
desarrollador corrigió los dos defectos sembrados y QA no tuvo nada que retener—; QA lo acreditó (R-3b) y mantiene
QA-025-08 abierto: dos ausencias no confirman. **No se repite** (instrucción del propietario). **QA-025-05 cerrado**
por QA con el CI verde verificado sobre la cabeza exacta (903 · 0 · 9; CA-13 satisfecho; el verde no desmiente el FAIL
local). **Decisión del propietario (2026-09-21): opción B, laguna aceptada** con condiciones literales (S4 se conserva
«no observado», el hallazgo no se borra, residual con dueño y fecha de revisión, «mi aceptación no sustituye ninguna
firma»); registrada en `PENDING_APPROVAL.md` §Resueltas (cola 1→0) y en REQ-025 CA-11 punto 3 (residual: dueño
`qa-tester`, forzador = primer hallazgo de QA de cualquier REQ que llegue a la regla 3, fecha de revisión propuesta
**2026-10-21**, modificable por el propietario; si no aparece el caso, se revisa la aceptación). `Estado:`
`bloqueado` → `en-revisión`. **QA R-4 (`5c30281`): `aprobado`** sobre la entrega construida, no sobre la conducta de S4;
QA-025-08 sigue en la cabecera (`instrumento`, residual aceptado). **Seguridad R-041 (`51a4430`): `con-hallazgos`, no
veto**: CA-11 punto 4 satisfecho, delta normativo dentro del límite del propietario, orden de firmas correcto;
**SEC-102** (`contrato`, dueño analista): el `Archivos:` de REQ-025 omite `requirements/README.md` y
`requirements/REQ-028.md`, escritos por comisiones de este REQ, y frente a REQ-020 la intersección declarada queda vacía;
remedio de una línea (añadir las dos rutas con fila de Historial), **autorizado excepcionalmente por el propietario el
2026-09-21** («no reinicies contadores ni abras otras reparaciones»), **aplicado por el analista en `1932492`** y
**reverificado por seguridad: `R-041-A` → SEC-102 `mitigado`, `Seguridad: aprobado` sobre `1932492`** (reutiliza la
acreditación del delta normativo de R-041, que no cambió). **Las tres firmas están: QA aprobado, seguridad aprobado,
cola 0, sólo `instrumento` abierto (QA-025-08, SEC-103, SEC-104).** ⚠️ **Advertencia del auditor, y es la regla para
quien retome:** con eso `guard-completado` **ya no impide** marcar REQ-025 como `completado`, y **cerrarlo sería
incorrecto**: la entrega 1b sigue `pendiente` dentro del REQ (CA-15 punto 9) y ninguna puerta comprueba esa cláusula.
**No se cierra REQ-025.** SEC-104 (`instrumento`, dueño coordinadora): las decisiones del propietario posteriores a la
opción B sólo estaban citadas dentro del REQ; ya pegadas literales en `PENDING_APPROVAL.md` §Resueltas (cierre del
hallazgo: del auditor). Antes del write-back, SEC-102 no impedía nada operativo: REQ-025 no puede llegar a `completado` mientras quede la **entrega 1b**
(CA-15 punto 9). **REQ-028 no se presenta como dependencia de cierre**: haber separado trabajo no la crea
(propietario, 2026-09-21); el punto 9 lo enumera junto a la 1b y queda para el analista informar si ese texto la
establece. **Confirmado por el propietario:** fecha de revisión del residual **2026-10-21**; la coordinadora señala el
primer caso aplicable y **QA conserva la responsabilidad de verificarlo** (resuelve OBS-I); S4 sigue «no observado».
**Fuente de la preferencia «edita por consola» identificada, nada modificado:** la emite el propio Claude Code como
`system-reminder` en modo de permisos `auto` (texto compilado en el binario, 2.1.274 de la extensión de VS Code; sin
rastro en `settings`, `CLAUDE.md`, memoria ni plugin). Detalle en la rama de evidencia,
`req-025/preferencia-consola-fuente.md`. **SEC-103** = OBS-H, `instrumento`, abierto, no aceptado, sin
reparación autorizada; sube a `contrato` si la reproducción muestra que `guard-codigo` permite. **OBS-I** (QA): el
write-back añade que la coordinadora señale el caso, obligación que el propietario no escribió; a confirmar por él junto
con la fecha 2026-10-21. Sin ensayos nuevos. **Observación independiente nueva,
OBS-H** (`instrumento`, dueño coordinadora, en `docs/qa/REQ-025.md`): en el ensayo un `cp` por `Bash` del
`qa-tester` hacia `src/*` tuvo efecto pese a que §13 lista `cp` como cubierto por `guard-codigo`; **no reproducido
en la cabeza actual**, no se abre contra REQ-025 ni se repara sin decisión; siguiente paso: reproducción acotada
como caso de banco cuando el propietario lo autorice.
**Hecho:** contrato partido (REQ-025 entrega 1 / entrega 1b trazada / REQ-028 diferido); seis reglas en `AGENTS.md`
§6 y gemela; cinco clases de acción (`cerrar` = marcar `completado`); cabeceras de la cola; entrada «Hacia 1.35.0»
(preparada, no publicada); referencias en tres agentes con la cláusula de proyecto sin migrar; ADR-008 con adenda;
ensayo acreditado por QA (CA-11 punto 3 satisfecho en el acto, S4 ante hallazgo de QA **no observado**, veto
**observado**, regla 6 incumplida y corregida). **Pendiente:** la decisión B/C del propietario; CA-11 punto 4
(seguridad no firma con QA `con-hallazgos`); OBS-D, OBS-G (margen del 93 % del techo en CI, dueño desarrollador),
OBS-H (**separada y expresamente pendiente, no aceptada** por la decisión del 2026-09-21; no se abre su reparación) y la
cola 1→7 del ensayo (material de la entrega 1b). Entrega 1b y REQ-028 **no se arrancan** sin autorización. Sedes: `requirements/REQ-025.md`, `docs/qa/REQ-025.md`, `docs/decisions/ADR-008-…`,
rama de evidencia `req-025/`. Sin fusión ni publicación.

---

## Fase actual
Fase 0 — autoalojamiento. **v1.32.1 publicada.** Ventana **1.33.0 abierta**, gobernada por 1.32.1.
Rama `cand/1.33.0`, PR **#43** en borrador.

**Alcance vigente, fijado por el propietario el 2026-09-08 (segunda decisión del mismo día): REQ-017 +
REQ-021 + la partición de las tres secciones sobre 400 líneas.** `REQ-019`, `REQ-020`, `REQ-023`,
`REQ-024` y `REQ-025` van a **1.34.0**, y REQ-019 es su primer trabajo.

**Esta ventana se movió cuatro veces en dos días, y conviene tenerlo escrito.** Nació el 2026-09-07 con
`REQ-017 + REQ-019 + REQ-021`; el 2026-09-08 entró **REQ-023** —el carácter invisible— y salió
**REQ-019** al pasar su estimación de ~2 h a **7–11 h en cuatro fases**; y ese mismo día **salió también
REQ-023**, cuando su coste se midió *después* de meterlo: cuatro comisiones en serie tras REQ-021, sin
paralelismo, con dos precondiciones ajenas. Es exactamente el mecanismo con que `docs/PLAN.md` explica
el descontrol del ciclo 3.

> **Aplazar REQ-023 no incumple ningún vencimiento**, y esto hubo que comprobarlo porque el REQ decía lo
> contrario: el vencimiento de `SEC-047` es el cierre de **1.34.0** (`registro-seguridad.md:3684`), así
> que meterlo en 1.33.0 había sido un **adelanto**. La cláusula que afirmaba lo contrario —«sube a
> `contrato` si 1.33.0 cierra sin él», atribuida al auditor— **no existía**: es `SEC-052`, y el auditor
> la trazó a un solo commit, el del propio REQ-023.

> **Y lo que esta ventana NO entrega: la reducción de tokens.** REQ-017 abarató el **reloj** del banco
> (95,66 s → 45,14 s), y esperar al banco es gratis en tokens. REQ-021 ahorra ~150 k por ventana **cuando
> exista**. La palanca de tokens es **REQ-019**, y está en 1.34.0.

## En progreso
**REQ-021 — `pendiente`, `QA: con-hallazgos`. VUELTA 3 DE 3, con el desarrollador trabajando. Es la
última.**

> **Y ya no hay salida de residual.** El write-back del 2026-09-08 declaró `QA-021-10` en
> `Hallazgos abiertos:` como **`contrato`**, así que `guard-completado` **deniega** el cierre mientras
> siga abierto. Después de esta vuelta hay exactamente dos finales: la vuelta trae código **y**
> acreditación ejercida por quien no escribió la sonda → cierra; o el REQ pasa a `bloqueado` y se escala
> al propietario. Un residual sólo sería viable si QA o el auditor **reclasifican** el hallazgo, y eso no
> es de la coordinadora.
>
> **El delta está medido y es más barato que la vuelta 2:** cinco archivos, ~115 líneas, y la sonda de
> procesos **pierde** código (fuera `sp_cal_disc`, `SP_DISC_VECES`, `--rastro`, el campo `disc_veces=`).
> La anterioridad del testigo **cuesta cero procesos**: es un cambio de orden. Y el fail-before sale
> gratis, porque las dos sondas de hoy **abortan con sólo mover el orden**.
>
> **La propiedad nueva de `(a.3)` tiene cinco condiciones**, y la tercera es la que carga el peso:
> **el juez obtiene el testigo ANTES de invocar la sonda** — *lo que no existe antes de que el sujeto
> corra, pudo haberlo producido el sujeto*. Las otras cuatro: tamaño del sujeto en un rango que el
> parámetro no puede alcanzar por construcción; el **valor** lo produce el juez, nunca un artefacto que
> la sonda pueda escribir; el sujeto discordante lo fija el juez y la sonda no lo declara; y el umbral no
> se lee del registro del juzgado (hoy la sonda de reloj podía **comprarse su propia abstención**).
>
> **`(a.4)` nombra la lección estructural:** *quien escribe el instrumento diseña el control que sabe
> pasar* — con las tres instancias medidas del mismo día y su consecuencia de sedes: la **forma** del
> camino la fija el criterio (analista), el **valor** lo obtiene el juez, la **acreditación** la ejerce
> quien no escribió la sonda.
>
> **Límite declarado, para no repetir la afirmación de eficacia que QA desmintió:** `(a.3)` cierra que el
> testigo *salga* de la sonda; **no** cierra una sonda que **lea el sujeto que el juez le entrega** y
> publique su cuenta sin ejercerlo — eso es falsificación deliberada, no descuido, y su respuesta es la
> barandilla (§13) más la custodia y el tercero.

**Lo que la vuelta 1 de QA encontró y motivó todo esto:**

> **`QA-021-10` (`contrato`, alta) — la tautología sobrevivió a la reducción de alcance.** En
> `tests/util/sonda-procesos.sh` **el testigo lo escribe la propia sonda**, que es lo que `CA-03 (a.3)`
> prohíbe por nombre: el juez sólo crea el archivo vacío y cuenta, pero el **valor** lo pone la sonda.
> Con `disc_obs = cal_n−1` y el testigo saliendo de las mismas marcas, **`3 = 3` se cumple por
> construcción, haga la sonda algo o nada**. Es el `2N/N = 2000` de `QA-021-01` con otra aritmética:
> `N−1`. QA construyó una copia que **no invoca `grep` ni una vez** y calcula las cinco magnitudes por
> aritmética, y el juez real dijo **PASS**.
>
> **La clase de `QA-021-01` salió del árbol con la sonda retirada y sobrevive en el instrumento que se
> quedó.** La mutación del desarrollador era la **estrecha** —publicar el parámetro—, y ésa sí la caza.
>
> El arreglo: el testigo tiene que obtenerlo **el juez, por un camino que la sonda no pueda alimentar**.
> Write-back del analista primero (el REQ afirma dos cosas falsas sobre lo construido), luego código.

**Conteo de vueltas dev↔QA: 3 de 3, la última en curso, y el contador NO se reinicia.** La vuelta 1
cuenta aunque quedara interrumpida, porque **produjo un bloqueante que obliga a volver al
desarrollador** — que es lo que define una vuelta, no cuántos criterios se alcanzaron a validar.

**Lo que QA NO llegó a mirar, y está tabulado como NO MIRADO —nunca como PASA—:** la banda de `(d)` bajo
carga provocada, `(ii)` y `(d)` con `r=3`, la honestidad de `(i.1)`, `QA-021-04`/`05`, `DEV-021-08`, el
cuadre de `CA-07`, el banco desde un worktree, y el hueco (b). La reanudación empieza por ahí.

**Lo conseguido y medido en la vuelta 2** (árbol `87d2609`, máquina en reposo, una sola comisión viva,
oráculo `/proc/stat:processes` con builtins):

| | Vuelta 0 (QA) | Vuelta 2 |
|---|---|---|
| `CA-03 (d)` calibraciones fuera de banda | **5 de 30**, 2 en reposo | **0 de 30** en cuatro regímenes |
| `CA-08 (ii)` razón de reloj | no ejercida | **1,1734×** contra techo 1,25× |
| `CA-08 (i.2)` sonda de reloj | — | **−4** procesos, idéntico 6/6 |
| `CA-08 (i.2)` sonda de procesos | — | **−30/−31** procesos |
| `CA-07 (1)` inventario | — | **828 casos / 61.287 B idénticos byte a byte** |
| Banco | 870/0/3 | **876 PASS · 0 FAIL · 4 SKIP**, cuadre 880 |

**Alcance reducido por decisión del propietario:** `sonda-linea-base.sh` **sale**; sólo se mudan la de
reloj y la de procesos. Era la causa de los tres problemas más duros a la vez —la calibración
tautológica, los 21 procesos que hicieron insatisfacible `CA-08 (i)` y el `+6` con los internos de
`git`—, y es la cláusula que el propio contrato tenía **pre-decidida**.

**Tres cosas de método que valen más que las cifras:**

1. **El desarrollador se desmintió a sí mismo.** Declaró `r` 3→5 como la palanca contra la fragilidad y
   la medición lo negó: con `r=3` la tasa es la misma **0/30**. Lo que la arregló fue el **tamaño
   derivado del suelo** (1,4× → 4×) y el **intercalado del par**, que además tapaba una falta de
   **identidad de camino**. Devolvió `r` a 3 y corrigió el `README` donde él mismo había escrito lo
   contrario. Y resultó decisivo: `(ii)` **no cabía** con `r=5`.
2. **`(i.1)` queda NO CONCLUYENTE, con rango y sin afirmar el signo.** El oráculo observa **31–78 forks
   ajenos** en ventanas de 25 s —amplitud 47— y el delta es **+4 a +22**. Y la nota que vale por sí sola:
   la amplitud **pareada** (18) es menor que la del suelo suelto (47), lo que indica que el pareado
   cancela deriva ambiental, **pero atenuar no es medir**.
3. **La calibración es todo el exceso de `(ii)`.** Sin ella la corrida sale **≈0,98–1,00×**: la mudanza
   en sí es neutra en reloj, y lo que cuesta es capacidad **que ninguna línea base tiene**.

## PAUSADA 2026-09-08 ~14:35 CST — presupuesto de tokens del usuario, no de decisión

**Árbol limpio en `9809fc2`, empujado.** Nada en vuelo, ningún agente vivo, `PENDING_APPROVAL.md` en 0.

**Lo próximo, en orden:**
1. **Analista** — Historial de `REQ-014` documentando la comisión del desarrollador (máquina de `CA-18` +
   oráculo de `CA-12`): corregir el desfase de piso (461/468, no 460/467; `k` sigue conforme) y anotar
   que `38-sondas-compartidas.sh` necesita **tres** archivos, no dos.
2. **Auditor** — retomar la evaluación de si `REQ-014` admite rigor menor que `critico`. Quedó
   **interrumpida sin veredicto** (parada por presupuesto, no por decisión): había encontrado «dos
   hallazgos concretos» y estaba verificando «la aritmética del techo autodeclarado y la numeración del
   registro» cuando se detuvo. Empezar de cero, no asumir ningún resultado previo.
3. **Desarrollador** — partir los tres archivos (autorización ya extendida a la 38).
4. **QA** de `REQ-014` completo.
5. **Auditor** de `REQ-014` (si el veredicto del punto 2 dice que aplica el ciclo completo).
6. Los dos ADR pendientes (re-derivación de `CA-18`; mandato de `ADR-005`).
7. Versión, PR, CI en verde, tag, instalación estable.

**El tag es del propietario, no por delegación** (R-016, R-017): 30 `contrato` abiertos, dos
discrepancias entre sedes, tres hallazgos apuntando a la publicación misma (`SEC-050`, `SEC-054`,
`SEC-055`). Nada de esto lo resuelve el trabajo pendiente arriba.

**Y la protección ya escrita para la próxima ventana:** `docs/PLAN.md` §1.34.0 — `REQ-019` es el
primer trabajo y **el único** hasta que cierre, sin excepción salvo lo que bloquee la publicación
misma. Lleva **dos** salidas de ventana y cero líneas de código tocadas.

## Próximo paso concreto
1. **REQ-021 vuelta 3 de 3: desarrollador** *(corriendo)* → **QA vuelta 3** → auditor → cerrar REQ-021.
2. **Partir las tres secciones que pasan de 400 líneas** (`848 / 678 / 722`). `CA-18` es el **único FAIL
   de la autoprueba** y **bloquea la fusión**, porque `hooks-en-linux` es la puerta requerida. Lleva roja
   desde el delta final de REQ-017 y el CI nunca lo había medido: el verde del PR era sobre un árbol de
   **346 y 266** líneas. Autorizado con **desarrollador + QA** por firma expresa del propietario
   (`PENDING_APPROVAL.md`, resuelta del 2026-09-08); va **después** de cerrar REQ-021, porque `CA-07.2`
   congela los `CASOS_ESPERADOS_SECCION` de las 37.
3. Versión, PR, CI, **tag `v1.33.0`** e instalación estable — con el gate de abajo.

*(REQ-023 ya no está en esta lista: salió de la ventana el 2026-09-08.)*

## Bloqueos
- **La fusión está bloqueada por `CA-18`** (punto 2 de arriba). No es un bloqueo de decisión: está
  autorizado y sólo falta hacerlo. Verificado en CI el 2026-09-08 a las 17:59: es el **único** rojo del
  árbol — `Autoprueba: 72 PASS, 1 FAIL`, y el FAIL nombra los tres archivos (`848 / 678 / 722`).
- **El tag vuelve al propietario, y NO por REQ-021.** `docs/gobernanza/autoalojamiento.md:148-155`:
  «**Cualquier** … hallazgo abierto de clase `usuario/dinero` o `contrato` … devuelve la decisión al
  propietario». **Corregido tras R-015:** los `contrato` abiertos ajenos a esta ventana son `SEC-050`
  (de REQ-016) y **`SEC-053`**; `SEC-052` pasó a **`mitigado`**; y **`SEC-054` SÍ es de esta ventana** y
  trata precisamente de lo que este tag publicaría. Ninguno bloquea una puerta de máquina —bloquean el
  REQ que los declara— pero por gobernanza la coordinadora **no fusiona ni etiqueta por delegación**:
  presenta la evidencia y para.
- **`SEC-053` (`contrato`, dueño PROPIETARIO) — el permiso para publicar no tiene frontera escrita, y hay
  una publicación pasada que lo prueba.** Medido en R-015: **`v1.32.1` se publicó por delegación con un
  `contrato` abierto** —`git show v1.32.1:…registro-seguridad.md` trae `SEC-020 · contrato · abierto`, y
  la entrada que anuncia la publicación **lo nombra**—, sin entrada en la cola. Son **tres** lecturas
  posibles y la única que hace conformes las publicaciones pasadas **no aparece en ningún documento**. La
  prueba de que no se puede aplicar como está la dio el auditor sobre sí mismo: *«no sé decir si mi
  propio hallazgo cuenta»*. Y la forma: **sin frontera escrita, la lectura se elige en el momento de
  publicar la parte que se quiere publicar, y siempre hay una que concede el permiso.**
- **`SEC-054` (`contrato`, alta) — 1.33.0 publicaría tres textos firmados que la medición desmiente:**
  `ADR-005:42` («cada corrida acredita que el instrumento responde al sujeto», con `Estado: aceptada`),
  `tests/util/README.md:50`, y la sección 38 publicando **PASS** sobre eso **en la puerta requerida**. El
  plugin se distribuye con `source: "./"`, así que **el ADR y el README llegan a los consumidores**.
  Remediación **barata y sin revertir código**: nota fechada en ADR-005 declarando su punto 4 no
  acreditado (**gate humano**: los ADR no se reescriben) más una línea en el README. Mitad buena, medida
  por objeto de árbol: **`hooks/` en HEAD es el mismo objeto (`88c1465…`) que firmó R-012** y no hay
  diferencia en `hooks/ tools/ .github/ .arnes/`, así que **no hay regresión de enforcement**.
- Ninguno de presupuesto.

## Pendientes (cola)
- [ ] **Enrutar el hueco (b), medido dos veces:** `37/1` y `37/2` **no llaman a `sonda_usable` ni una
      vez**, así que publican razones con la procedencia de la calibración **desmentida en la misma
      corrida** — con la sonda mutada la sección 38 sale roja y ellas dan PASS. Es superficie de REQ-017 y
      convertir sus PASS en FAIL no cabe sin decisión del propietario.
- [ ] **`REQ-017 CA-03` es flaky y REQ-017 está `completado`:** `1 de 8` corridas no alcanza a demostrar
      su fail-before (la de la máquina cargada). §9 dice que un REQ `completado` que cambia re-recorre el
      ciclo; hay que decidir si esto es hallazgo o reapertura.
- [ ] **Dos preguntas de REQ-025 para el propietario, aplazadas a propósito hasta cerrar 1.33.0:** si
      `CA-08` entra en CI, y si `requirements/` entra en `codigo_app.globs` —hoy **no está**, así que la
      sesión coordinadora **puede escribir `QA: aprobado`** y ninguna puerta lo impide.
- [x] **`SEC-050` y `SEC-051`** (R-013) — **enrutados el 2026-09-08, los dos a 1.34.0.** `SEC-050` va al
      write-back de **REQ-023** (`CA-02`/`CA-03`) más la reparación del puntero de REQ-016 en
      **REQ-024**. `SEC-051` va **entero a REQ-024** (`CA-08`/`CA-09`), y **no** a REQ-023, por un motivo
      que salió de leer el código y que ningún documento decía: `hooks/lib.sh:1577-1583` declara **por
      escrito** la frontera con `arnes_cola_pendientes` y deja escrito el precio de cruzarla — unificar
      la noción de cita cambia el **conteo** de la cola, que es un cambio de **veredicto** de la puerta,
      que es un cambio del contrato de **REQ-009** (`completado`) **sin ADR**. Corrección a la
      estimación que estaba aquí escrita: **no era «un arreglo de dos líneas»** — la remediación de
      R-013 pide una transcripción compartida, conducta nueva cuadrada en **tres** lectores y casos
      fail-before/pass-after en un archivo que REQ-023 **no** declara en `Archivos:`.
- [ ] **`SEC-052`** (R-014, `contrato`, dueño `analista-requerimientos`) — write-back **hecho** el
      2026-09-08 y declarado en `Hallazgos abiertos:` de REQ-023; **falta que el auditor lo verifique y
      lo cierre**. Bloquea el `completado` de REQ-023 y de nada más.
- [ ] **El `_doc` del manifiesto es documentación que ninguna migración toca** (reportado por un
      proyecto consumidor). `arnes-upgrade` clasifica **secciones de Markdown** y un valor JSON no es una
      sección, así que los diez `_doc` de la plantilla derivan para siempre. Análisis en
      `docs/PENDIENTES.md`.
- [ ] Decisión editorial del propietario: nombres de proyectos consumidores en el árbol público y las dos
      cuentas de GitHub nombradas en `AGENTS.md` (`SEC-008`, informativo; la salida propuesta es
      sustituir nombres por roles).
- [ ] **1.35.0 — working set explícito**: análisis y reglas de diseño en `docs/PENDIENTES.md`. El
      adelgazamiento de los documentos de arranque ya salió de aquí: es REQ-019, en 1.34.0.
- [ ] Windows/MSYS: el coste allí no está medido, y es donde un `fork` cuesta entre 1,2 y 6 s.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-21 13:46

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `feat/req-025-coordinacion-entregas` @ `bb50ecd` — CON CAMBIOS SIN COMITEAR
**Arnés:** plugin instalado `1.34.0` · el proyecto declara `1.33.0` — **migración pendiente** (`/arnes-upgrade`)
**Aprobaciones pendientes:** 1
**REQ:** 26 — completado 13 · en-revisión 1 · en-progreso 1 · bloqueado 2 · otros 9
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 13 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-007 | en-progreso | pendiente | pendiente | critico | qa-114(contrato,dueñoanalista-requerimie… |
| REQ-008 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-011 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-013 | en-revision | con-hallazgos | con-hallazgos | critico | sec-014(contrato),sec-020(contrato),qa-2… |
| REQ-018 | borrador | pendiente | pendiente | critico | (ninguno) |
| REQ-019 | pendiente | pendiente | preventiva | critico | sec-033(contrato) |
| REQ-020 | pendiente | pendiente | preventiva | critico | sec-038(contrato),sec-039(contrato),sec-… |
| REQ-021 | bloqueado | con-hallazgos | preventiva | critico | dev-021-05(instrumento,dueñoanalista-req… |
| REQ-022 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-023 | borrador | pendiente | pendiente | critico | sec-052(contrato) |
| REQ-024 | borrador | pendiente | pendiente | critico | (ninguno) |
| REQ-025 | bloqueado | con-hallazgos | pendiente | critico | qa-025-05(instrumento),qa-025-08(instrum… |
| REQ-028 | borrador | pendiente | pendiente | critico | (ninguno) |

<!-- ARNES:DERIVADO fin -->
