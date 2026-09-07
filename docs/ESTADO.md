# ESTADO — ArnesJuan

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparece un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.

## Fase actual
Fase 0 — autoalojamiento. **v1.32.1 publicada** (tag verificado contra los tres manifiestos, instalación
estable actualizada, hooks idénticos al tag). REQ-015 y REQ-016 `completado` por la puerta. La sesión
que abra 1.33.0 la gobernará **1.32.1** — pero sólo si se reinicia antes.

## En progreso
**Nada en curso.** Dieciséis comisiones, ~2,3 M de tokens medidos, **tres vueltas dev↔QA agotadas**, y
el banco de 683 a **828 casos** en 41 secciones.

**Lo que de verdad pasó en esta ventana, porque no es lo que dice el título:** el parche **no parcheaba
a la primera**. Se cerraron **cuatro** fallos en abierto y **tres los introdujo el propio arreglo**. El
retorno de carro se descontaba **antes** de escanear el rango, y `-\r->` se convierte en `-->`; tenía
**cuatro bocas** —el lector de línea, la extracción del `tool_input`, la reconstrucción del `Edit` con
el CR en disco, y el mapa de paralelismo—. Se cerraron con una sola pregunta cerrada: *una línea de
cabecera con un CR que no es el que la termina no se puede medir, y una puerta que no puede medir no
deja pasar* (CA-12).

**Y ninguno de los cuatro se encontró leyendo código.** QA rompió el arreglo del desarrollador; el
desarrollador se rompió a sí mismo midiendo; el auditor rompió **dos veces** lo que QA ya había
aprobado — la segunda sin tocar el código, viendo que *«CA-02 contrata el agujero; nada contrata el
tapón»*. Los cuatro salieron de **medir la consecuencia** en vez de creerse el diff.

**Lo que cruza a 1.33.0, con dueño y ventana:**

| Hallazgo | Clase | Qué es |
|---|---|---|
| **SEC-020** | `contrato` | El marcado por elemento corrompe el mapa de `arnes-paralelo.sh`: `disjunto` con rc 0. La respuesta es **restringir la gramática**, no un octavo parche |
| **SEC-030** | `contrato` | La pared de 60 s del hook se alcanza hacia **1,5 MB de un documento normal**, y `AGENTS.md` §13 no la enumera entre los huecos conocidos. Preexistente en los dos árboles |
| **H-07** | `instrumento` | `arnes_sin_cita` es **cuadrática** sobre líneas largas: el banco pasa de 39 s a 92 s. Una llamada normal **no** se resiente (0,166 → 0,171 s). Arreglo de **una sentencia** |
| El bloque derivado | `instrumento` | Publica `Seguridad: aprobado` sobre una cabecera que la puerta se **niega a medir**. Sube a `contrato` y **bloquea** si llega a la firma de 1.33.0 sin guarda |
| H-06 | `contrato` | Una nota al margen en `PENDING_APPROVAL.md` desactiva el bloqueo de la cola. **Sigue sin dueño**; le corresponde `desarrollador` |
| SEC-017, SEC-021, SEC-028, QA-205, QA-213..216 | `instrumento` | Deuda con dueño, ventana 1.33.0 |

**La lección del ciclo, y ya van cinco:** cuando un mecanismo interpreta texto humano libre, ensanchar
el patrón no gana la clase. La salida es **restringir la gramática** o **preguntar después**.

**Y la lección nueva, que apareció cuatro veces en una sola ventana:** *interrogar al mecanismo tiene
una vía nueva cada vez; interrogar a la propiedad no envejece.* Los cinco casos de banco vacíos, el
barrido de migración, el control de datos de cliente y el guardián del intérprete son **el mismo error
de forma**: preguntar por la **vía** cuando la propiedad es de **estado**. Es la columna vertebral de
1.33.0.

## Próximo paso concreto
1. **Reiniciar la sesión.** Los hooks se cargan al arrancar el proceso: hasta que se reinicie sigue
   gobernando 1.32.0, que es la versión con el agujero que este parche cierra.
2. **Avisar a los proyectos que corrieron 1.31.0 o 1.32.0**: pudieron cerrar un REQ `critico` sin
   auditoría aprobada. El procedimiento está en `skills/arnes-upgrade/SKILL.md` § `Hacia 1.32.1`, y
   declara **qué encuentra y qué no puede encontrar**.
3. **Abrir 1.33.0 por las palancas de coste, no por los REQ** (decisión del propietario): la puerta de
   «¿esta prueba mide algo?», el punto caliente del banco —que es `32-huecos-auditoria-r001`, 75,7 s de
   los 92, **no** el que la coordinadora dijo primero— y `tests/util/` con las sondas compartidas.
4. Núcleo de 1.33.0: REQ-011 (la puerta posterior), el barrido por estado de SEC-025, el barrido de base
   de SEC-029, y el **rigor comprobable por máquina** contra las rutas realmente tocadas.

## Bloqueos
- Ninguno. La fusión, el tag y la publicación se ejecutaron por delegación con todo en verde. El auditor
  sostuvo en R-007 y R-008 que la decisión volvía al propietario; en R-009 declaró que **la salvedad
  decae**. La discrepancia queda escrita en `docs/PENDIENTES.md`, decisión 4.

## Pendientes (cola)
- [ ] Decisión editorial del propietario: nombres de proyectos consumidores en el árbol público, y las
      dos cuentas de GitHub nombradas en `AGENTS.md` (hallazgo informativo SEC-008; la salida propuesta
      es sustituir nombres por roles).
- [ ] **1.35.0 — working set explícito**: análisis y reglas de diseño en `docs/PENDIENTES.md`. Sigue
      abierta la pregunta de si adelantar sólo el adelgazamiento de `AGENTS.md`, que es el mayor coste
      fijo de contexto y no depende de ninguna medición.
- [ ] Windows/MSYS: el coste allí no está medido, y es donde un `fork` cuesta entre 1,2 y 6 s.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-07 12:45

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `cand/1.32.1` @ `06b6340` — CON CAMBIOS SIN COMITEAR
**Arnés:** plugin instalado `1.32.0` · el proyecto declara `1.32.1` — **migración pendiente** (`/arnes-upgrade`)
**Aprobaciones pendientes:** 0
**REQ:** 16 — completado 10 · en-revisión 3 · en-progreso 1 · bloqueado 0 · otros 2
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 10 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-007 | en-progreso | pendiente | pendiente | critico | qa-114(contrato,dueñoanalista-requerimie… |
| REQ-008 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-011 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-013 | en-revision | con-hallazgos | con-hallazgos | critico | sec-014(contrato),sec-020(contrato),qa-2… |
| REQ-015 | en-revision | aprobado | aprobado | critico | (ninguno) |
| REQ-016 | en-revision | aprobado | aprobado | critico | h-07(instrumento) |

<!-- ARNES:DERIVADO fin -->
