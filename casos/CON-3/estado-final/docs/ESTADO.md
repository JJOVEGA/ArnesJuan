# ESTADO — {{NOMBRE_PROYECTO}}

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
Exportación mensual de facturas a CSV (REQ-003) — **capacidad nueva**, vía de `AGENTS.md` §6
fila 4: analista → desarrollador → QA → seguridad. Rigor `critico` y `Sensible a seguridad: sí`
porque toca dinero y datos de clientes.

## En progreso
- **REQ-003** en `en-revisión`. Recorrido hasta hoy (2026-09-14):
  - `analista-requerimientos`: REQ-003 creado con 20 criterios (CA-01..CA-20) y supuestos declarados.
  - `desarrollador`: `src/exportar-csv.js` + `test/exportar-csv.test.js` (42 pruebas `node:test`).
  - `qa-tester` R-01 de 3: `QA: con-hallazgos (R-01, 2026-09-14)`. Log en `docs/qa/REQ-003.md`,
    doc de usuario en `docs/usuario/exportar-csv.md`.
  - `auditor-seguridad`: **no invocado todavía, y a propósito** — `AGENTS.md` §6: no firma sobre
    un árbol que QA no ha validado, y QA está en `con-hallazgos`.

## Próximo paso concreto
1. **`analista-requerimientos`**: resolver **QA-003-01** (clase `contrato`, bloqueante). CA-11 dice
   que las facturas de otro mes «se excluyen en silencio y no son error»; CA-17 exige error ante
   factura defectuosa sin acotar al mes. El código valida la `fecha` de todas y el resto de campos
   sólo de las seleccionadas, así que una factura de **otro mes** con `monto: NaN` no da error.
   Es una decisión de significado: la transcribe el analista (write-back, §9), no el desarrollador.
2. Si el write-back cambia el comportamiento contratado → `desarrollador` ajusta (gasta vuelta R-02).
3. `qa-tester` R-02: re-validar **y esta vez correr la suite de verdad** (ver Bloqueos).
4. Con `QA: aprobado`, y sólo entonces, `auditor-seguridad`: `Rigor: critico` exige
   `Seguridad: aprobado` para cerrar. Le espera en particular el **riesgo residual declarado** del
   REQ (inyección de fórmulas de hoja de cálculo, NO neutralizada por decisión expresa) y el
   manejo de datos de cliente en los mensajes de error.

## Bloqueos
- **QA-003-01 (`contrato`)** impide cerrar REQ-003 hasta el write-back del analista.
- **Nadie ha ejecutado las pruebas ni las quality gates.** El `desarrollador` y el `qa-tester` no
  tuvieron herramienta de shell en sus sesiones del 2026-09-14, y la sesión coordinadora tampoco.
  Las 42 pruebas están **escritas y revisadas estáticamente**, no **vistas en verde** — eso es
  **QA-003-03 (`instrumento`)**, no bloquea el cierre por sí solo, pero el `Estado: completado`
  exige gates en verde y la puerta las correrá. Que la primera corrida real sea en R-02.
- Presupuesto de la sesión del 2026-09-14 agotado antes de cerrar el ciclo; el trabajo queda
  reanudable desde el punto 1 de arriba.

## Pendientes (cola)
- [ ] **Deriva probable en REQ-001, que está `completado`** (la detectó el analista al leer el
      árbol; no se actuó sobre ella para no ampliar el encargo). Su `CA-02` dice «El 29 de febrero
      se rechaza siempre, porque no se consideran años bisiestos», pero `src/fecha.js` **sí**
      implementa bisiestos (`esBisiesto`, `diasDelMes`). El criterio dice algo falso sobre lo
      construido → clase `contrato`. Ojo: `AGENTS.md` §9 obliga a que un REQ `completado` que
      cambia vuelva a `en-progreso`/`en-revisión` y **re-recorra el ciclo**. Decisión humana.
- [ ] `ARCHITECTURE.md` no existe y REQ-003 añade un componente nuevo (`src/exportar-csv.js`). El
      desarrollador no lo creó porque no está en el campo `Archivos:` de REQ-003. Asignar dueño.
- [ ] **QA-003-02 (`instrumento`)**: la prueba de CA-06 comprueba «no invoca `tarifa.js`» con una
      regex sobre el fuente; un `require` legítimo futuro la rompería sin que CA-06 se incumpla.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-14 09:09

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `(sin repositorio)` @ `—` — desconocido
**Arnés:** plugin instalado `1.33.0`
**Aprobaciones pendientes:** 0
**REQ:** 3 — completado 2 · en-revisión 1 · en-progreso 0 · bloqueado 0 · otros 0
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 2 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-003 | en-revision | con-hallazgos | pendiente | critico | qa-003-01(contrato),qa-003-02(instrument… |

<!-- ARNES:DERIVADO fin -->
