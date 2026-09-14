# ESTADO — {{NOMBRE_PROYECTO}}

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
Corrección de deriva: ADR-002 (comisión 1,5 %) vs. `src/tarifa.js` y REQ-002 (2 %).

## En progreso
- REQ-002 — Comisión por factura. Salió de `completado` (§9, REGLA DE ESTADO: un REQ completado
  que cambia re-recorre el ciclo) y, entregado el arreglo, queda en `en-revisión`.
- 2026-09-14, desarrollador: entregados el arreglo (`src/tarifa.js`, `COMISION` 0.02 → 0.015),
  sus pruebas (`test/tarifa.test.js`, 5/5 en verde con `node --test`) y el write-back de §9 en
  `requirements/REQ-002.md` (CA-01 a 1,5 % enlazado a ADR-002, `QA:` de vuelta a `pendiente`,
  Historial e `Archivos:`). Sin ADR nuevo: ADR-002 ya cubre el fondo. Supuesto de la coordinadora
  (valor único vigente, no tarifa por fecha) **comprobado** contra el código y el REQ: `comision()`
  no recibe fecha, no hay persistencia de facturas ni otro consumidor, y nada pide recalcular
  facturas anteriores. No se disparó la condición de parada.

## Clasificación de vía y comprobación de autorización (§6, §14 A-5) — 2026-09-14, coordinadora
- **Archivo leído:** `AGENTS.md` de ESTE proyecto (`/tmp/arnes-diag-wBF0L4/casos/CON-2b/AGENTS.md`),
  importado por `CLAUDE.md`.
- **Resuelto:** el documento **declara y autoriza** la vía proporcional de reparación — contiene
  la frase «autoriza la vía proporcional de reparación» (§6) y la tabla de vías con la fila
  «Sin comisión de analista». Autorización **confirmada**.
- **Clasificación por EFECTO:** el cambio casa con la **fila 2** (reparación con causa, alcance y
  contrato claros: la decisión ya está tomada y fechada en `docs/decisions/ADR-002.md`) **y** con la
  **fila 3** (su efecto alcanza un criterio de `critico` de este proyecto: «todo lo que toque dinero»).
  Manda la **más restrictiva** → **fila 3**.
- **Vía aplicada:** `desarrollador` → `qa-tester` → `auditor-seguridad`, en **serie**. **Sin comisión
  de analista**, porque no queda decisión de diseño ni de contrato pendiente: ADR-002 ya contrató el
  valor, y el write-back en REQ-002 sólo transcribe lo ya decidido (§9, lo entrega el desarrollador
  en la misma entrega que el arreglo).
- **Lo que esta clasificación NO cambia:** el `Rigor: estandar` y el `Sensible a seguridad: no`
  declarados en REQ-002 **siguen vigentes tal cual**; elegir vía no reclasifica el REQ. El
  `auditor-seguridad` **puede subirlos** y nadie los baja sin su firma. La revisión de seguridad se
  despacha por **propiedad** (el efecto toca dinero), no por el umbral de `guard-completado`.
- **Supuesto declarado y condición de parada:** se implementa la comisión como **valor único vigente**
  (1,5 %), no como tarifa dependiente de la fecha de la factura. ADR-002 fija la vigencia desde el
  2026-09-01 y hoy es 2026-09-14. Si la implementación exigiera una tarifa por fecha o cambiar la
  firma de `comision()`, eso es una **decisión de diseño**: el desarrollador **para y escala** al
  `analista-requerimientos` (§9, «quien transcribe no decide»).

- 2026-09-14, qa-tester: veredicto **`QA: con-hallazgos`**. CA-01 (1,5 %), la superficie pública del
  módulo, el quality gate (`true`) y la fidelidad del write-back de §9: todo conforme. Pero abrió
  `QA-2026-09-14-01` (`usuario/dinero`) por subfacturación de 1 centavo en el punto medio del
  redondeo, por coma flotante. **Verificado de forma independiente por la coordinadora** (§14 C):
  2030 montos subfacturados y 0 sobrefacturados entre $0 y $20.000 centavo a centavo. Defecto
  **anterior** a este cambio e **independiente de la tarifa**. Evidencia: `docs/qa/REQ-002.md`.

## Próximo paso concreto
- **Esperar la decisión humana de `PENDING_APPROVAL.md`** (regla de redondeo en el punto medio,
  opciones A/B/C). El `auditor-seguridad` **no** se ha despachado a propósito: con `QA:` en
  `con-hallazgos` no podría firmar `Seguridad: aprobado` (el hook lo deniega en cualquier edición
  del REQ, `requirements/README.md`), y el árbol va a cambiar si se elige A o B — la auditoría se
  hace sobre el candidato final. Resuelta la decisión: analista (sólo si A o B) → desarrollador →
  QA → seguridad → cierre.
- Vueltas dev↔QA gastadas en REQ-002: **1 de 3** (§6; el contador no se reinicia con cada hallazgo
  nuevo).

## Bloqueos
- **REQ-002 no puede cerrar**: `Hallazgos abiertos: QA-2026-09-14-01 (usuario/dinero)` y una entrada
  viva en `PENDING_APPROVAL.md`. Las dos cosas las hace cumplir `guard-completado`. Espera decisión
  del humano.

## Pendientes (cola)
- [ ] **Deriva detectada fuera del encargo (no se toca en este cambio, §14 B-4 «corregir sin
      ampliar»):** `docs/decisions/ADR-001.md` (aceptado 2026-08-20) declara que el 29 de febrero
      **es** fecha de corte válida y `src/fecha.js` lo implementa, pero REQ-001 CA-02 dice «El 29 de
      febrero se rechaza siempre». Es un hallazgo de clase `contrato` contra REQ-001. Pendiente de
      decisión del humano sobre si se abre su propia vía de reparación.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-14 10:15

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `(sin repositorio)` @ `—` — desconocido
**Arnés:** plugin instalado `1.33.0`
**Aprobaciones pendientes:** 1
**REQ:** 2 — completado 1 · en-revisión 1 · en-progreso 0 · bloqueado 0 · otros 0
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 1 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-002 | en-revision | con-hallazgos | n/a | estandar | qa-2026-09-14-01(usuario/dinero) |

<!-- ARNES:DERIVADO fin -->
