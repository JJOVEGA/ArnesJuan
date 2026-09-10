# Coste de reloj por comisión — medido en la sesión del 2026-09-10

**Versión base:** rama `rel/registro-1.33.0`, commits `b369094`…`b99cfbb`, 2026-09-10.
**Método:** duración de reloj que el propio orquestador reporta al terminar cada subagente
(`duration_ms`), sobre esta máquina (WSL2, 8 núcleos). **No es una estimación: es lo que tardaron.**
Estadístico: **mediana y MAD**, no rango — el rango es monotónicamente no decreciente y crece con la
muestra, así que no compara.

## Lo medido, comisión por comisión

| # | Rol | Encargo | Duración |
|---|---|---|---|
| 1 | `qa-tester` | modo intercalado de `REQ-017` (`86a44c8`) | **27,5 min** |
| 2 | `analista` | write-back `QA-017-24` | **8,6 min** |
| 3 | `analista` | cota de `CA-08 (ii)` | **5,3 min** |
| 4 | `qa-tester` | vuelta 3 de 3 de `REQ-017` | **22,2 min** |
| 5 | `analista` | `SEC-067` → `NFR-026-01` | **7,5 min** |
| 6 | `auditor-seguridad` | reconciliación `R-028` | **18,3 min** |
| 7 | `analista` | corrección de `QA-017-31` | **7,1 min** |
| 8 | `qa-tester` | revalidación de `CA-03` fuera del contador | **16,7 min** |
| 9 | `analista` | tercera sede, `CA-03:62` | **3,2 min** |
| 10 | `analista` | dos campos desfasados (`SEC-014`, `SEC-083`) | **6,3 min** |
| 11 | `analista` | dos estados desfasados (`SEC-055`, `REQ-023`) | **9,6 min** |

## Estadísticos por rol

| Rol | n | Mediana | MAD | Nota |
|---|---|---|---|---|
| `analista-requerimientos` | **7** | **7,1 min** | **1,5 min** | la muestra más sólida |
| `qa-tester` | **3** | **22,2 min** | **5,4 min** | n pequeño |
| `auditor-seguridad` | **1** | 18,3 min | — | **n = 1: no hay dispersión, y no se presenta como típico** |
| `desarrollador` | **0** | — | — | **NO SE MIDIÓ NINGUNA en esta sesión: no hay base** |

## Las cuatro limitaciones, y ninguna es menor

1. **`desarrollador` no tiene ni una medición.** Es el rol de las correcciones de código que quedan
   (`SEC-073`, `SEC-084`, `QA-024-19`, `SEC-075`), así que la parte más incierta del trabajo restante
   es justo la que no se puede acotar con esto.
2. **Esta máquina no es el runner** (WSL2 de 8 núcleos contra 4 vCPU con `ARNES_JOBS=6`), así que
   estas cifras **no** predicen el CI. Y el CI de esta rama **no discrimina** en los criterios de
   reloj (`docs/arnes/ci-1.34.0-no-discrimina/`).
3. **Es tiempo de EJECUCIÓN de agente, no de calendario.** No incluye la espera por firmas humanas,
   que **no tiene base ninguna** aquí.
4. **`AGENTS.md` §6 fuerza la serie, y está medido:** `tools/arnes-paralelo.sh` declaró que
   `REQ-017`, `REQ-013` y `REQ-024` **colisionan** por `tests/escenarios/hooks/run.sh` y
   `hooks/lib.sh`. Así que estas duraciones **se suman**, no se solapan.

## Cómo se re-deriva

Las once cifras salen de los informes de terminación de subagente de la sesión
`23a8ee5a-8587-4923-8f15-1fc9bf03aaf2`. Para una sesión nueva se re-mide igual: anotar `duration_ms`
al cerrar cada comisión y recalcular mediana y MAD por rol. **Con `n < 5` en un rol, decirlo.**
