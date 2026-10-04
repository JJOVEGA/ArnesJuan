# ADR-017 — Una puerta que no puede leer su entrada, terminar de juzgarla a tiempo o emitir su decisión no deja pasar (SEC-120, SEC-115, SEC-118)
Fecha: 2026-10-03
Estado: aceptada (2026-10-03). El propietario resolvió P-136-B y P-136-C en su décima autorización (`PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-03, décima autorización)», «Decisiones del propietario»), literales:
- «P-136-B: criterio por propiedad: toda denegación decidida llega al cliente, entera o acotada, nunca perdida; el desarrollador elige la técnica; los avisos entran.»
- «P-136-C: techos de tamaño más plazo propio de 40 s, sin procesos.»

*(Antes: «propuesta. La decisión de base es del propietario (abajo). La forma de conseguirla depende de P-136-B y P-136-C, que siguen abiertas. Cuando las resuelva, este ADR pasa a `aceptada` con su resolución citada.»)*

## Contexto
**Lo que hoy está declarado.** `AGENTS.md` §13, cláusula 1 de «Lo que la limita», dice que un hook que no emite su decisión no deniega, y nombra dos limitaciones conocidas y sin reparar:
- el hook que el cliente mata por tiempo (SEC-115);
- el que decide pero no llega a emitir su decisión porque el motivo no cabe en un argumento de línea de órdenes (SEC-118).

`requirements/README.md` § «Clases de hallazgo» y REQ-031 (CA-A12, nota del 2026-09-29; CA-A15) prometen la denegación sólo hasta lo medido. SEC-120 está fuera de toda promesa: REQ-007 CA-47, punto 11, lo nombra como lo que no cubre.

**Lo medido** (`docs/seguridad/registro-seguridad.md`):
- **SEC-120** (§ R-045-A, §4). Si `jq` no puede leer o trocear la entrada del hook, la puerta no decide y deja pasar. Medido a nivel de hook con un `MultiEdit` malformado y con un `Edit` de cierre con 10 001 niveles de anidamiento. R-046 y R-047 lo vuelven a medir sin cambio de conducta. Vence el 2026-10-29.
- **SEC-115** (§ R-044-C, §2; § R-045-A, §5). Un hook que muere por tamaño deja pasar el cierre entero, y hay tres vías medidas:
  - un valor de cabecera de unos 255 KB: 73,6 s;
  - un `Write` de unos 2 MB: 80,2 s;
  - la búsqueda del `old_string` en la reconstrucción, que crece más que linealmente.

  REQ-031 CA-A16 observó en el cliente que un hook que agota su `timeout` deja pasar la herramienta.
- **SEC-118** (§ R-045, §4). `arnes_deny` pasa el motivo a `jq` como un argumento. Por encima del límite de bytes de un argumento, el hook sale sin decisión, aunque haya decidido denegar en menos de un segundo. Es determinista y no depende del reloj.

**Lo que decidió el propietario.** Sus decisiones de publicación de v1.35.0 (`PENDING_APPROVAL.md` § Resueltas, decisiones 2 y 3) declararon SEC-115, SEC-118 y SEC-120 como límites «no aceptados como definitivos». Fijaron su reparación en 1.36.0: «fail-closed» para SEC-115 y SEC-118, y para SEC-120 «fallo de jq al leer o trocear la entrada → deny». El pedido de apertura de 1.36.0 (2026-10-03, «Encargo 2») lo concreta así:
- «fail-closed cuando el hook agota tiempo o el motivo excede el tope: emitir decisión siempre»;
- «Comprobación de código de salida, sin procesos nuevos» para SEC-120;
- «Windows declarado no medido».

## Decisión
Se aplica el principio rector («una puerta que no puede medir no deja pasar») a tres cosas que hasta ahora quedaban fuera de él:
1. **La lectura de la entrada.** Si la entrada no se puede leer, el hook deniega. Si no se puede trocear la parte que una puerta necesita, deniega esa puerta (REQ-007 CA-47, punto 20).
2. **La emisión.** Toda denegación decidida se emite, sea cual sea el tamaño o la codificación de su motivo (CA-67). Por P-136-B: llega al cliente entera o acotada, nunca perdida; la técnica es del desarrollador; y los avisos que el hook decide emitir entran en la misma propiedad.
3. **El reloj.** Un hook que no puede terminar de juzgar antes del límite del cliente emite `deny` en vez de morir sin decisión (CA-68). Por P-136-C: techos de tamaño más un plazo propio del hook de 40 s, sin procesos.

Las tres van a todo agente cuando la decisión no se puede atribuir, y sin procesos añadidos en la lectura de la entrada.

**Lo que esta decisión no puede comprar, y se escribe con ella:**
- si el cliente mata el proceso, nada que el hook haga deniega (SEC-030): el hook sólo puede decidir antes;
- sin un proceso aparte, una sola operación que se bloquea por dentro no se interrumpe.

## Alternativas consideradas
- **Mantenerlos como límites declarados (estado de 1.35.0).** Rechazada por el propietario: «no aceptados como definitivos».
- **Para SEC-118: acotar el motivo en bytes, o sacarlo de la línea de órdenes.** Las dos cumplen la propiedad. Qué es «el tope» que se mide, y si los avisos entran, era P-136-B: resuelta por propiedad, con la técnica para el desarrollador y los avisos dentro (arriba, «Estado»).
- **Para SEC-115: sólo techos de tamaño antes de toda operación superlineal; esos techos más un plazo propio comprobado entre unidades de trabajo; o un vigilante en proceso aparte.** El vigilante cubre también la operación bloqueada, pero añade un proceso por invocación. En Windows/MSYS eso son 1,2–6 s por llamada (`AGENTS.md` §2), y choca con REQ-007 CA-59. La elección y el plazo eran de P-136-C: techos más plazo propio de 40 s, sin procesos; el vigilante en proceso aparte queda fuera (arriba, «Estado»).

## Consecuencias
- (+) Las tres vías por las que hoy una puerta del arnés deja pasar sin decidir pasan a denegar, hasta lo medido y con la frontera escrita. Se cierran así SEC-120, SEC-118 y, en la medida de P-136-C —techos de tamaño y plazo de 40 s, sin la operación que se bloquea por dentro—, SEC-115.
- (+) La cláusula 1 de `AGENTS.md` §13, la fila de los hallazgos y `requirements/README.md` § «Clases de hallazgo» dejan de listar SEC-115 y SEC-118 como limitaciones sin reparar. **Eso ocurre sólo cuando esté construido y validado, y sólo hasta lo medido** (REQ-007 CA-69, punto 5). Hasta entonces ninguna sede dice «reparado».
- (−) **Movimientos de `allow` (o «sin decisión») a `deny`, también sobre lo legítimo.** Un juicio legítimo que agote el plazo de 40 s de P-136-C se deniega a todo agente, también al `desarrollador`. Ocurre igual con un valor por encima de un techo de tamaño nuevo y con una entrada mal formada que hoy pasaba. Se declaran en REQ-007 CA-69, punto 3. Mitigación: el plazo y los techos son operativos y se bajan con la medición, y la salida está en el motivo.
- (−) **Puede mover lo que mide REQ-017 CA-09** (sección 37/3 del banco, la pared de los 60 s por `Write`). REQ-017 está `completado`: si el veredicto cambia, se escala antes de entregar (REQ-007 CA-68, `AGENTS.md` §9). Decisión del propietario (décima autorización): «CA-68 / REQ-017 CA-09: se evalúa al construir SEC-115; si afecta, §9.»
- (=) **Windows/MSYS, declarado no medido.** No se le atribuye cobertura. Si el motivo siguiera pasando por la línea de órdenes, el límite de `CreateProcess` podría bajar el umbral de SEC-118 (R-045 §4, inferido). Allí, además, la retirada del transporte es superlineal (R-047, observación de QA).
- (=) No supersede ningún ADR. Se apoya en el mismo principio que ADR-015 (una edición que la puerta no puede reconstruir se deniega) y que ADR-016 (un REQ que la puerta no puede leer entero no se edita).
