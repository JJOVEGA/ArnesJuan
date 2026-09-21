# QA — REQ-004 (lista de clientes en el encabezado del informe)

Fecha: 2026-09-21 · Vuelta: 1 de 3 (dev↔QA, contador del REQ) · Vía: analista → desarrollador → QA → seguridad (`AGENTS.md` §6 de este proyecto no declara la vía proporcional).

## Quality gate — `node --test`

```
✔ CA-01 — une los nombres con «; », en el orden recibido y sin separador inicial ni final (1.25ms)
✔ CA-01 — conserva el orden de entrada tal cual (no ordena ni deduplica) (0.17ms)
✔ CA-02 — omite la cadena vacía y el valor nulo sin dejar separador ni hueco (0.10ms)
✔ CA-02 — el resultado es idéntico al que produce CA-01 sobre la lista sin los omitidos (0.12ms)
✔ CA-03 — una lista vacía produce la cadena vacía (0.20ms)
✔ CA-03 — una lista en la que todos los elementos se omiten por CA-02 produce la cadena vacía (0.11ms)
✔ CA-04 — un solo nombre se devuelve sin ningún separador (1.38ms)
✔ CA-04 — si tras aplicar CA-02 queda exactamente un nombre, se devuelve sin separador (0.25ms)
tests 8, pass 8, fail 0, cancelled 0, skipped 0, todo 0
```

**Verde, 8/8.** Corrida única sobre el árbol en `en-revisión`, sin cambios sin comitear en `src/formato.js` posteriores a la entrega del desarrollador.

## Revisión de forma de los criterios (previa a probar — `requirements/README.md` §«Cómo se escribe un criterio que no se desmiente»)

- **CA-01**: sin enumeración de conjuntos, sin número, sin coste/igualdad. Bien formado.
- **CA-02**: enumera dos valores (`""`, `null`) pero los marca explícitamente **«ejemplos no exhaustivos»** y apunta a la frontera escalada en P-01 (`PENDING_APPROVAL.md` D3). Cumple la forma (a): marca + puntero. Este ajuste ya lo hizo el `analista-requerimientos` al reabrir el REQ (ver Historial, fila del 2026-09-21 sobre CA-02); no es un hallazgo nuevo.
- **CA-03 / CA-04**: derivados de CA-01+CA-02, sin números ni conjuntos. Bien formados.

Conclusión: **ningún criterio cae en las formas prohibidas (a)-(d).** No se abre hallazgo `contrato` por forma.

## Veredicto por criterio

| CA | Descripción | Veredicto | Evidencia |
|---|---|---|---|
| CA-01 | Separador «; », orden de entrada, sin separador inicial/final | **Pasa** | `test/formato.test.js` líneas 11-18; prueba de ruptura manual (ver abajo) |
| CA-02 | Omite `""` y `null` sin hueco ni separador suelto | **Pasa** | `test/formato.test.js` líneas 20-30; prueba de ruptura manual |
| CA-03 | Lista vacía o todo omitido → `""` | **Pasa** | `test/formato.test.js` líneas 32-38 |
| CA-04 | Un solo nombre → sin separador | **Pasa** | `test/formato.test.js` líneas 40-46 |

## Correspondencia prueba ↔ criterio (nadie mide otra cosa)

Revisadas las 8 pruebas una por una contra el CA que citan en su título:
- Las dos de CA-01 comprueban exactamente unión con «; » y preservación de orden (sin ordenar/deduplicar) — coinciden con el texto del criterio.
- Las dos de CA-02 comprueban omisión sin hueco (con el ejemplo verificable del REQ) y la propiedad «idéntico a CA-01 sobre la lista sin omitidos», incluyendo omitidos en posición **inicial y final** (`['', 'Ana', null, 'Luis', '', 'Marta', null]`), que es justo donde vivía el defecto original (separador colgante). Coinciden.
- Las dos de CA-03 cubren lista vacía y «todos omitidos» por separado, como pide el criterio («o»). Coinciden.
- Las dos de CA-04 cubren un nombre único de entrada y un nombre único tras omitir. Coinciden.

No se encontró ninguna prueba verde que mida algo distinto de lo que su título afirma.

## Casos de ruptura (más allá de las pruebas del desarrollador)

Ejecutados a mano contra `src/formato.js` (sin editar código):

```
["", "Ana"]                          -> "Ana"                 OK (omitido al inicio)
["Ana", ""]                          -> "Ana"                 OK (omitido al final)
[null]                               -> ""                    OK
[""]                                 -> ""                    OK
["Ana", "Ana", "Luis"]               -> "Ana; Ana; Luis"       OK (no deduplica, correcto por alcance)
["Luis", "Ana"]                      -> "Luis; Ana"            OK (no ordena, correcto por alcance)
[]                                   -> ""                    OK
["", "", ""]                         -> ""                    OK
["Ana", null, null, "Luis"]          -> "Ana; Luis"            OK (dos omitidos consecutivos, sin doble hueco)
[null, "Ana", ""]                    -> "Ana"                 OK (omitidos en ambos extremos)
```

Ningún caso rompe CA-01…CA-04. El patrón exacto del defecto original — separador colgante por omisión en el extremo — no reaparece.

**Idempotencia:** `listaClientes` es una función pura sin I/O ni estado compartido; se invocó repetidamente con la misma entrada (incluida en la prueba CA-02 de igualdad) y devuelve siempre el mismo resultado. No aplica condición de carrera: no hay concurrencia posible en este módulo.

## Bordes no contratados (P-01, P-02) — verificados, no fijados como criterio

Confirmado que el comportamiento de hecho coincide con lo que el desarrollador reportó y con lo que `PENDING_APPROVAL.md` (D3, D4) tiene escalado, sin convertirlo en hallazgo ni en prueba que lo fije:

```
listaClientes(["Ana", "   ", "Luis"])   -> "Ana;    ; Luis"   (espacio no se omite — P-01)
listaClientes(["Ana", undefined, "Luis"]) -> "Ana; ; Luis"    (undefined no se omite — P-01)
listaClientes(["Ana", 42, "Luis"])      -> "Ana; 42; Luis"    (coerción de no-textual — P-01)
listaClientes(null)                     -> TypeError: Cannot read properties of null (reading 'filter')
listaClientes("Ana")                    -> TypeError: nombres.filter is not a function
```

No se registra hallazgo por esto: son bordes explícitamente escalados y fuera del alcance exigible mientras no se decidan (D3, D4). Se deja constancia de que la medición no cambió respecto a lo reportado por el desarrollador.

## NFR — rendimiento

`AGENTS.md` de este proyecto no declara umbral de usuarios concurrentes ni de latencia objetivo, y `listaClientes` es una función pura, sincrónica, sin I/O, de coste `O(n)` sobre el tamaño de la lista de clientes de una factura (decenas de elementos, no miles). No hay componente de carga real que probar aquí. **Pendiente de acordar con el humano** sólo si el propietario considera que este módulo necesita un umbral explícito; no se marca como hallazgo porque no hay indicio de que aplique.

## Hallazgos

### QA-004-01 — RESUELTO
- **Clase:** `usuario/dinero` (como estaba declarado).
- **Verificación:** el separador es «; » exacto (CA-01) y los elementos vacíos/nulos se omiten sin dejar hueco ni separador suelto, incluidas las posiciones inicial y final (CA-02), confirmado por `test/formato.test.js` (8/8 verde) y por los casos de ruptura manuales de esta sesión.
- **Resuelto por:** el arreglo del `desarrollador` en `src/formato.js` (filtra antes de unir) + `test/formato.test.js`.
- **Write-back:** ya existe en `requirements/REQ-004.md` — el `analista-requerimientos` precisó CA-01 y CA-02 en Gherkin y añadió CA-03/CA-04 al reabrir el REQ (ver su Historial de cambios, filas del 2026-09-21), y describen exactamente lo construido. Se cierra el hallazgo en la cabecera del REQ.

## Hallazgos nuevos

Ninguno. No se encontró ningún defecto `usuario/dinero`, `contrato` ni `instrumento` dentro del alcance contratado (CA-01…CA-04). Los bordes P-01/P-02 permanecen como preguntas escaladas, sin novedad.

## Veredicto

**QA: aprobado (2026-09-21).** Las cuatro quality gates funcionales (CA-01…CA-04) pasan, la quality gate automatizada (`node --test`) está en verde, las pruebas corresponden a lo que afirman medir, y el hallazgo `QA-004-01` queda resuelto y con su write-back ya reflejado en el REQ.

**No implica `Estado: completado`.** `Rigor: critico` exige además `Seguridad: aprobado` del `auditor-seguridad`, que sigue `pendiente`, y `PENDING_APPROVAL.md` tiene entradas abiertas (D1…D5) que de todos modos impiden la acción de **cerrar** cualquier REQ del proyecto. Este veredicto no espera a seguridad: sólo lo hace el cierre.
