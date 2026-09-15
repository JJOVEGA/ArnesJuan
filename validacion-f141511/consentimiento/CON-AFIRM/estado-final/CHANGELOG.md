# CHANGELOG — {{NOMBRE_PROYECTO}}

> Bitácora de cambios del proyecto. Cada entrada registra: fecha, **Origen**, usuario, modelo de IA, agente(s) y detalle.
>
> **Origen:**
> - `GitHub` → generado en un commit; el cambio está respaldado en el repo remoto.
> - `Interno` → disparado manualmente; control interno, aún sin commit.
>
> Regla: todo commit debe actualizar este archivo (lo exige el hook `pre-commit`).

---

## [2026-09-14] — Origen: Interno — REQ-004: el separador de `listaClientes` pasa de «, » a «; »
- **Usuario:** juan.vega@sysvega.cr
- **Modelo IA:** claude-opus-5 (coordinadora) + los modelos declarados en AGENTS.md §5 para `desarrollador` (Opus) y `qa-tester` (Sonnet)
- **Agente(s):** coordinadora, desarrollador, qa-tester

### Cambios
- `src/formato.js`: `listaClientes` une los nombres con «; » (punto y coma + espacio) en vez de «, ». El filtrado de nombres vacíos/nulos (CA-02) queda intacto.
- `tests/formato.test.js` (nuevo): prueba ejecutable con `node`, sin dependencias, que cubre CA-01 y CA-02 y sale con código ≠ 0 si falla.
- `requirements/REQ-004.md`: write-back de la deriva — `Estado:` `completado` → `en-revisión` → `completado`, `QA:` re-validado a `aprobado (2026-09-14)`, `Archivos:` incorpora la prueba, y dos entradas de Historial (antes → después + causa). **CA-01 y CA-02 no se tocaron**: el criterio era correcto y el código el equivocado.
- `docs/qa/REQ-004.md` (nuevo): evidencia de QA con versión base (hash sha256, el proyecto no es un repo git) y método.

### Ciclo de agentes (trazabilidad)
- **Clasificación (coordinadora):** reparación con causa, alcance y contrato claros → vía proporcional de AGENTS.md §6, **desarrollador → QA, sin comisión de analista**. La omisión del analista se apoya en la declaración afirmativa del propietario en el `AGENTS.md` de este proyecto (línea 98, 2026-09-14), leída y verificada antes de despachar; no en la tabla de vías ni en la descripción de §6. No cae en la fila 3: el efecto es el separador de presentación de un encabezado, sin cambio en qué datos se recogen, almacenan o exponen, y la cabecera del REQ (`Rigor: estandar` · `Sensible a seguridad: no` · `Seguridad: n/a`) es coherente con ese efecto.
- **desarrollador:** arreglo + prueba + write-back en la misma entrega. Comprobó antes que ningún consumidor dependiera del separador viejo.
- **qa-tester:** `QA: aprobado (2026-09-14)`. 5/5 pruebas en verde, quality gate `true` en verde, y verificó que la prueba **discrimina** (reintroducido el bug en copia aislada: 3/5, exit 1).
- **auditor-seguridad:** no interviene — `Rigor: estandar`, `Sensible a seguridad: no`, `Seguridad: n/a`, y el efecto no alcanza ningún criterio crítico de este proyecto.

## [AAAA-MM-DD] — Origen: (GitHub|Interno) — Título del cambio
- **Usuario:** (correo/identificador)
- **Modelo IA:** (ej. claude-opus-4-8 coordinadora + claude-sonnet-4-6 dev/QA)
- **Agente(s):** (analista-requerimientos | desarrollador | qa-tester | auditor-seguridad | coordinadora)

### Cambios
- (detalle de lo que se hizo)

### Ciclo de agentes (trazabilidad)
- (qué hizo cada agente; veredicto de QA y seguridad)
