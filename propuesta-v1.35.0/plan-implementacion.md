> **Documento incompleto: no autoriza implementación.** (2026-10-03) Un control de seguridad interrumpió la redacción de las secciones de diseño y de validación técnica (§3 y §7). Este documento organiza el resto del trabajo, pero no es un plan ejecutable mientras esas secciones sigan vacías.
>
> **Impedimento, puesto al día el 2026-10-03:** en la actualización documental autorizada ese día, un control de seguridad del proveedor volvió a detener la redacción de este plan. §3 y §7 siguen sin completar. No se intentó reproducir el contenido bloqueado ni rodear el control.
>
> **Decisiones del propietario que este plan desarrolla:** `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-03)». Allí está el texto literal: SEC-124 opción B, SEC-125 reparar antes de publicar y SEC-123 corregir la descripción de F3. **No autorizan ejecutar.**
>
> **Material histórico, fuera de este alcance:** `README.md`, `SEC-047.diff` y `evidencia/` de esta carpeta son la propuesta de SEC-047 del **2026-09-29**, sobre la base `713ac68`. No forman parte de este plan y no se editaron el 2026-10-03. **Identidad de contenido:** se verificó comparando su objeto git con copias comiteadas el 2026-09-29, y alcanza a cuatro de los cinco archivos. El quinto, `evidencia/control-positivo-inventario.md`, **no se verificó**, porque no hay referencia previa. Detalle en `TRASPASO.md` §3.

# Plan de implementación — v1.35.0: SEC-124 (opción B), reparación de SEC-125 y corrección documental de SEC-123

> **Base comprobada por lectura el 2026-10-03:**
> - `cand/1.35.0` en local está en `c0c8be2`;
> - `origin/cand/1.35.0` y el PR #59 están en `45368ce`;
> - en el árbol sólo hay cambios preexistentes: `docs/ESTADO.md` y `propuesta-v1.35.0/`.
>
> Este plan no garantiza que no aparezcan hallazgos nuevos. Las cifras de tiempo son **estimaciones**, salvo donde se cita una duración medida.

## 1. Resultado y alcance

**Dentro:**
- **SEC-124, opción B (decisión del propietario).** Se deniega explícitamente, con motivo claro, el caso de heredoc con retorno de carro descrito en R-047 §3. No se borra el CR ni se interpreta un comando distinto. El propietario acepta que ese caso deje de pasar.
- **SEC-125, reparar antes de publicar** (R-047 §4). Una continuación de línea es legítima y no indica por sí sola ninguna intención de evadir.
- **SEC-123, corrección documental de F3** (§4). No acepta el riesgo ni da por reparado el mecanismo.

**Fuera, con sus decisiones pendientes:**
- CA-54 (QA-023-10), SEC-115/118, el hueco C y SEC-120;
- F2, F5 y F7 de P-119-A;
- cerrar en código el límite de SEC-123.

## 2. Orden de trabajo y dependencias

0. **Requisito previo, sin resolver:** completar §3 (diseño) y §7 (validación técnica). Sin ellas no se puede redactar el contrato ni el encargo al desarrollador con la regla 1 de AGENTS.md §6 (objetivo construido y comprobado, criterios, qué queda fuera, cuándo detenerse).
1. **Analista:** escribe en REQ-007 la propiedad de las dos reparaciones, los movimientos de veredicto que se esperan (con SEC-124 B, un allow→deny declarado; con SEC-125, allow→deny sobre lo que hoy se escapa) y la corrección de F3 (§4). Es el único paso que puede empezar antes del código, porque fija el contrato.
2. **Desarrollador:** las dos reparaciones en una sola comisión. Las dos están en la misma zona: el análisis del texto de los comandos de `Bash`. Llevan pruebas en el banco con fail-before contra `befc17a`.
3. **Analista, si hace falta:** el write-back de las decisiones de implementación (§9 de AGENTS.md).
4. **QA (Opus, §5):** el delta, las regresiones de las secciones 41 a 45, un banco completo y los controles legítimos. Como mucho, una pasada correctiva con su re-verificación.
5. **Seguridad:** el delta, con QA favorable.
6. **Coordinadora:** push sin force y una sola corrida de CI, si las revisiones son favorables.
7. **Propietario:** la comprobación en VS Code con WSL (§5).

**Lo que puede agruparse:** las dos reparaciones (mismo analizador y mismo ciclo) y el write-back de F3 en la comisión del analista.

**Lo que no puede ir en paralelo:** QA antes del desarrollador, y seguridad antes o a la vez que QA (AGENTS.md §6).

## 3. Diseño técnico — **BLOQUEADO, sin completar**

No se pudo redactar. Debía resolver cómo tratar conjuntamente continuaciones de línea, retorno de carro, comillas y heredocs conservando el significado del comando, y evaluar el precedente de `guard-git` (que pliega la continuación desde SEC-009) sin dar por hecho que sirva para las otras puertas.

**Fuentes que existen:** R-047 §3 y §4 (`docs/seguridad/registro-seguridad.md`) y REQ-007 CA-47, puntos 11 y 17.

**Qué deja pendiente:** el contrato del analista (paso 1, en lo que toca al diseño), el encargo del desarrollador (paso 2) y los criterios de QA (paso 4).

## 4. Correcciones documentales pendientes

- **F3 de CA-47 (SEC-123).** Texto propuesto, no trasladado a ninguna sede normativa:

  > *F3 — Enlaces duros y montajes, y un límite de la detección de lo que depende del proceso: cuando una ruta pasa por el directorio de trabajo del proceso y después sale de la entrada de `/proc` del propio hook, el hook deja de reconocerla como dependiente del proceso y la juzga por el archivo al que llega él, que puede no ser el que abre quien escribe. La consecuencia puede ser un permiso sobre un archivo protegido. Medido a nivel de hook; no ejercido en el host.*

  - **Las dos magnitudes van por separado:**
    - el **umbral de componentes de ruta** medido es de cuatro niveles de subida (el texto vigente dice cinco);
    - la **profundidad de la raíz del proyecto** con la que se observó el permiso es de cinco o más niveles (R-047 §2, medido con la raíz a siete).
  - **Medido:** las dos magnitudes, el permiso y el efecto en disco, a nivel de hook.
  - **Inferido:** que desde el host sólo se alcanza inyectando la entrada o con un directorio de trabajo anómalo.
  - **No comprobado:** el host, la extensión de VS Code y Windows.
  - **Sedes:** CA-47 (F3 y punto 16), la adenda de ADR-016, las notas `[1.35.0]` y la descripción de P-119-A.
- **CA-24, CA-66 puntos 5 y 7, notas `[1.35.0]` y guía:** quitar del conjunto de movimientos la clase de SEC-124 cuando la opción B esté construida.
- **AGENTS.md §13 y su plantilla:** si SEC-125 se repara, no hace falta declararlo como límite. Si no se completara antes de publicar, habría que declararlo, y eso exige una decisión del propietario.

## 5. Archivos y contratos afectados

| Sede | Por qué |
|---|---|
| `hooks/lib.sh` (análisis del texto de `Bash`: `arnes_bash_sin_texto` y `arnes_bash_escrituras`) | SEC-124 B y SEC-125 |
| `hooks/guard-codigo.sh` y `hooks/guard-completado.sh` | Sólo si el motivo de denegación nuevo lo exige |
| `hooks/guard-git.sh` | Sólo como referencia del precedente (§3); su cambio queda fuera salvo dependencia demostrada |
| `tests/escenarios/hooks/secciones/45-…` o una sección nueva, más `run.sh` y el README del banco | Casos y recuentos |
| `requirements/REQ-007.md` | CA-47 (F3, puntos 11, 16 y 17), nota de CA-24, CA-66, Historial |
| `docs/decisions/ADR-016-…` | Adenda |
| `skills/arnes-upgrade/SKILL.md` y la sección `[1.35.0]` de `CHANGELOG.md` | Guía y notas |

**Compatibilidad que cambia:** dos movimientos de allow a deny que hay que declarar: el caso de heredoc de SEC-124 y la forma de SEC-125.

**Cobertura reutilizable:**
- las secciones 41 a 45 y sus fail-before;
- las baterías de QA r7, r8 y r8b;
- las de seguridad R-046 y R-047;
- la medición de coste de QA-023-14.

## 6. Comprobación pendiente en VS Code con WSL

- **Lo que ya existe:** pruebas a nivel de hook en Linux/WSL2, y del CLI 2.1.285 dentro de WSL2 con `claude -p`. **Ninguna acredita la extensión.**
- **CLI en el terminal de VS Code (WSL):** repetir unos pocos casos ya registrados (un control de denegación, un control legítimo y uno de los reparados), observando lo que recibe el hook, su decisión y el disco.
- **Panel de la extensión:** los mismos casos desde una sesión de la extensión, comprobando además la versión del CLI que usa, si expone `MultiEdit` y cómo muestra el motivo de la denegación.
- **Requiere al propietario:** abrir la sesión de la extensión y aprobar los pasos. No está preparado ni ejecutado. Los casos deben registrarse antes de ejecutarlos, como en las validaciones anteriores.

## 7. Validación técnica — **BLOQUEADA, sin completar**

No se pudo redactar la lista de casos específicos de las dos reparaciones.

**Lo que sí se puede fijar sin ese contenido:**
- las secciones 41 a 45 conservan su resultado;
- un banco completo sobre el código final;
- la autoprueba;
- las quality gates de AGENTS.md §7;
- ningún movimiento de deny a allow nuevo frente a `9596e39` y 1.33.2;
- controles legítimos: continuaciones de línea normales y heredocs normales siguen pasando.

## 8. Condiciones de salida

**Conforme:**
- §3 y §7 completas;
- contrato escrito;
- las dos reparaciones con QA favorable y seguridad favorable sobre el delta;
- ningún movimiento de deny a allow sin declarar;
- banco y gates en verde;
- una corrida de CI en verde sobre la cabeza final;
- F3 corregida en sus sedes.

**Impediría continuar:**
- que §3 y §7 sigan bloqueadas;
- un hallazgo nuevo de clase `contrato` o `usuario/dinero` introducido por el cambio;
- agotar el presupuesto de §9.

**Seguiría pendiente antes de publicar, aunque esto salga conforme:**
- CA-54;
- SEC-115/118;
- el hueco C;
- P-119-A (F2, F5, F7 y el límite de F3);
- SEC-120 (vence el 2026-10-29);
- la comprobación en VS Code con WSL (§6).

## 9. Presupuesto propuesto

Sin reiniciar contadores; el de REQ-023 sigue agotado (3 de 3).

| Comisión | Número | Referencia medida en esta sesión |
|---|---|---|
| Analista (contrato + F3) | 1 | Comisiones de write-back: 5–30 min de reloj, 0,4–0,65 M tokens |
| Desarrollador | 1 | Comisiones de hooks: 13–64 min, 0,34–0,69 M tokens |
| QA (Opus) | 1, + 1 re-verificación si hay pasada correctiva | 16–49 min, 0,09–0,45 M tokens |
| Pasada correctiva | Como mucho 1 | — |
| Seguridad | 1 | 23–30 min, 0,32–0,39 M tokens |
| CI | 1 corrida | ≈ 3 min (`36945180340`: 2 min 50 s) |
| Propietario | VS Code con WSL | Sin estimar |

- **Total estimado:** entre 2 y 4 horas de reloj si no aparecen hallazgos. Es una **estimación**, no una medida.
- **Origen de las cifras de la tabla:** las duraciones y los tokens que dio el arnés para las comisiones de esta sesión.
