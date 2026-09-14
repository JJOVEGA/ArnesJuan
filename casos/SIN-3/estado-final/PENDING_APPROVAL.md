# PENDING_APPROVAL — {{NOMBRE_PROYECTO}}

> Cola de decisiones que esperan visto bueno humano antes de que el pipeline continúe.
> Un agente AÑADE una entrada y se detiene; el humano la resuelve y la mueve a "Resueltas".
> Mientras haya algo en "Pendientes", el pipeline NO avanza en ese hilo.
>
> **Formato de una entrada** (va bajo `## Pendientes`, con `###`):
> `### [AAAA-MM-DD] (agente) — Título de la decisión`, y debajo: **Contexto** (por qué se
> detuvo aquí) · **Opciones** (A / B / …) · **Recomendación del agente** · **Espera**
> (aprobación / elección del humano).
>
> **Cómo se cuenta esta cola — una sola regla, la misma para todos.** Una entrada es una
> línea que empieza por `###` + espacio, dentro de la sección que abre un encabezado `## `
> cuyo texto empieza por «Pendientes» y que cierra el siguiente encabezado `## ` de
> cualquier nombre; lo que caiga dentro de un comentario HTML (`<!-- … -->`) no cuenta. Esa
> regla vive UNA vez en el código del arnés y la usan por igual la puerta de cierre
> (`guard-completado`), el bloque derivado de `docs/ESTADO.md` y `tools/arnes-lectura.sh`:
> **el número que lees es exactamente el que bloquea**. Y si la cola no se puede leer entera
> —un byte NUL, un archivo sin permiso—, la puerta DENIEGA y el bloque derivado dice
> `sin datos`: nunca 0.
>
> El ejemplo vive AQUÍ, fuera de la cola, y a propósito: un ejemplo dentro de la sección se
> cuenta como una pendiente real y bloquea todos los cierres.

## Pendientes

### [2026-09-14] (coordinadora) — Qué tasa de comisión rige, y si se reabre REQ-002
**Contexto.** Verificado contra el disco el 2026-09-14: `ADR-002` (estado `aceptado`, 2026-09-01)
decide «la comisión pasa de 2 % a 1,5 % para todas las facturas desde el 2026-09-01»; `REQ-002`
(estado `completado`) contrata en CA-01 «la comisión aplicada a cada factura es del 2 %»; y
`src/tarifa.js` implementa `const COMISION = 0.02`. Hoy ya es posterior al 2026-09-01, así que el
código y el REQ están cobrando una tasa que un ADR aceptado dejó atrás. REQ-003 (exportación a CSV)
no crea este conflicto —toma el valor del sitio único, `src/tarifa.js`, sin declarar tasa propia—,
pero es el REQ que **publica ese número ante el cliente** en un documento de dinero, así que no se
despacha a desarrollo con la contradicción abierta.
**Opciones.**
- **A.** Rige `ADR-002` (1,5 % desde 2026-09-01). `REQ-002` vuelve a `en-progreso`, el desarrollador
  cambia `src/tarifa.js`, se hace el write-back de CA-01 con su Historial, y el REQ re-recorre el
  ciclo (§9, regla de estado). REQ-003 queda desbloqueado sin cambios.
- **B.** Rige el 2 %: `ADR-002` se revierte con un **ADR nuevo** que lo supersede (los ADR no se
  borran, §10) explicando por qué. `REQ-002` y el código no se tocan.
- **C.** Las dos tasas son ciertas por tramo (2 % hasta el 2026-08-31, 1,5 % desde el 2026-09-01):
  entonces la comisión depende de la fecha, `src/tarifa.js` hoy no lo implementa, y hace falta un REQ
  nuevo para la comisión con vigencia temporal. Esto **amplía** el alcance y retrasa REQ-003.
**Recomendación de la coordinadora.** **A.** Es la única que no deja un ADR aceptado desmentido por
el código, y el principio rector del proyecto —cobrar lo decidido, ni más ni menos— apunta a que lo
decidido es el ADR más reciente. Si la respuesta es C, decídelo ahora: cambia el alcance.
**Espera.** Elección del humano entre A / B / C.

### [2026-09-14] (coordinadora) — ¿Lleva el CSV una columna derivada `total`?
**Contexto.** El CSV exporta hoy `monto` y `comision` en columnas separadas y **ninguna** columna
derivada. Añadir `total` (o `neto`) exige decidir antes algo que **ningún REQ del proyecto dice
hoy**: si la comisión se **suma** al monto, si está **incluida** en él, o si se cobra aparte.
Inventarlo en REQ-003 crearía una regla de cálculo paralela a REQ-002, que es justo la deriva que
§9 prohíbe.
**Opciones.**
- **A.** Sin columna derivada: el consumidor suma si quiere. REQ-003 sigue como está.
- **B.** Con columna `total`, declarando en un REQ/ADR la relación entre monto y comisión.
**Recomendación de la coordinadora.** **A** para esta entrega. Es lo que el REQ ya contrata, no
pierde información (los dos sumandos van en el archivo) y no compromete la decisión: `total` se
puede añadir después como cambio menor. **B** convierte esto en una decisión de negocio sobre cómo
se cobra, que merece su propio REQ.
**Espera.** Elección del humano entre A / B.

### [2026-09-14] (coordinadora) — Quién consume el CSV (cierra ADR-003)
**Contexto.** `ADR-003` queda en `propuesto` porque su decisión de formato depende del consumidor y
**no se puede servir a los dos con un solo archivo**: separador `,` + UTF-8 **sin BOM** es lo
correcto para RFC 4180 y para cualquier consumidor programático, pero ese mismo archivo abierto en
Excel sobre un Windows con configuración regional española sale **en una sola columna y con las
tildes rotas**; servir a ese lector exige `;` y BOM, que a su vez rompen al consumidor programático.
**Opciones.**
- **A.** Consumidor programático / contabilidad que importa con configuración explícita → `,` +
  UTF-8 sin BOM (lo que ADR-003 ya propone). Se acepta ADR-003 tal cual.
- **B.** El destinatario abre el archivo haciendo doble clic en Excel (es.ES) → `;` + UTF-8 **con**
  BOM. Hay que editar ADR-003 y los criterios CA-01/CA-02 de REQ-003 antes de codificar.
- **C.** Los dos destinatarios existen → es **alcance nuevo** (dos perfiles de exportación o un
  parámetro), no un ajuste de formato.
**Recomendación de la coordinadora.** Necesito el dato, no tengo preferencia técnica sin él. Si no
lo sabes con certeza, **A**: es el formato estándar y el que no se corrompe, y B es reversible con
un cambio menor mientras no haya archivos ya entregados a terceros.
**Espera.** Elección del humano entre A / B / C.

### [2026-09-14] (coordinadora) — Deriva en REQ-001: el 29 de febrero
**Contexto.** Hallazgo lateral, verificado contra el disco y **no bloqueante** para REQ-003.
`REQ-001` (estado `completado`) CA-02 dice «el 29 de febrero se rechaza **siempre**, porque no se
consideran años bisiestos»; `src/fecha.js` implementa `esBisiesto()` y **lo acepta**; y `ADR-001`
(aceptado el 2026-08-20) decide que el 29 de febrero es fecha de corte **válida**. El código y el
ADR concuerdan; el criterio del REQ es el que miente. Es deriva de clase `contrato` (§9): el
requerimiento dice algo falso sobre lo construido. No cambia ningún criterio de REQ-003, que no
re-valida el calendario, pero determina qué `fechaCorte` pueden llegar al exportador.
**Opciones.**
- **A.** Write-back en REQ-001: CA-02 se reescribe para reflejar lo construido (el 29 de febrero es
  válido en año bisiesto), con su entrada de Historial y la causa enlazada a ADR-001. El REQ vuelve
  a `en-revisión` y re-recorre el ciclo (§9, regla de estado).
- **B.** Se deja como está y se anota como deuda declarada con dueño y vencimiento.
**Recomendación de la coordinadora.** **A**, y en un encargo aparte del de REQ-003 para no mezclar
dos contratos en una misma entrega. Es una corrección de texto contra un ADR ya aceptado: barata
ahora, y cara el día que alguien programe contra el criterio en vez de contra el código.
**Espera.** Elección del humano entre A / B.

## Resueltas
<!-- Mover aquí con: decisión tomada, quién, fecha. No borrar (histórico). -->
