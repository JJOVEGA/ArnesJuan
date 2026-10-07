# ESTADO — ArnesJuan

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparece un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.

> Nota de aislamiento — 2026-09-10: existe un candidato local separado, basado en
> `v1.33.0`, para corregir el rigor con matiz y la detección de firmas de Seguridad.
> No es una publicación ni sustituye este tablero. Su estado y sus límites están en
> `docs/estabilizacion/`.

## ⏸ RETOMAR AQUÍ — ventana 1.36.0 abierta; 1.35.0 publicada (2026-10-03)

**Este bloque es el único vigente en la rama `cand/1.36.0`** (worktree `/home/juan/dev/ArnesJuan-v1.36`). Todo lo que está debajo es historia.

> **Modelo de la coordinadora: Fable 5.1 desde el 2026-10-06, cabeza `098896c`** (prueba acotada decidida por el propietario; los subagentes conservan su modelo; el plan no cambia; al cerrar SEC-115/118 se entrega la comparación en tres cifras con CA-54 y SEC-120). **`cand/1.36.0` sigue sin push: el push es del propietario.**
>
> **Plan autorizado vigente: paso 6 de 1.36.0, SEC-115 y SEC-118 con SEC-129 (por delegación del propietario del 2026-10-06), fase 2 hecha en `0efd3c2` (evidencia `65092c8`; SIN VALIDAR: sección 47 93/0, E1–E3 sin «afecta», inventario sólo con 2 (c)/INS, banco 2290/0/13, +0 procesos; `hooks/entrada.sh` nuevo; SEC-130 no cubierto por R2 → sigue F-136-12). **P-136-O (1) (A), (2) (A) y P-136-N (A), adoptadas por el propietario (2026-10-06).** Hecho: QA-007-07 reparado (`8e11f87`; sección 47 95/0; SIN VALIDAR) y el write-back del analista (`833d561`). Adelantado del paso 7: `propuesta-v1.35.0/` a `docs/historia/` (`1d1cf07`) y el borrador de las notas (`4fced9f`). **QA del paso 6 (fase 3) hecho: con hallazgos; P-136-P resuelta (1) (A) y (2) (A) por el propietario (2026-10-06).** Hechos: la **única pasada correctiva** (`03cbf5e`, evidencia `1adeffc`; SIN VALIDAR: 7 casos del bloque P en verde con fail-before en `8e11f87`; sección 47 102/0; E1 sin cambio; +0 procesos) y el write-back del analista (`d965583`). **Re-verificación de QA hecha: CON HALLAZGOS → PARADO por P-136-Q.** QA-007-10/11 (a)/12 cerrados; QA-007-08 → INS-136-4; **QA-007-13** (`contrato`, baja): una función importada llamada `builtin` deja sin decisión y, si devuelve 0, **cuelga toda llamada 60 s** (regresión de `03cbf5e`); `.`/`[`/`errexit` preexistentes. **P-136-Q = (A)** hecha por el desarrollador en 18 minutos (`39e6128`, evidencia `b255dd2`; SIN VALIDAR): `entrada.sh` en modo POSIX al arrancar, `unset -f` de una lista estática, sin bucle sobre `/proc/self/environ`; con `builtin` y `read` suplantadas, 110 ms donde `03cbf5e` moría a los 60 s; sección 47 104/0; banco 2301/2/11 (los 2 FAIL son INS-136-1/2); E1 igual; +0 procesos. **Re-verificación acotada de QA hecha: QA-007-13 cerrado; CON HALLAZGOS por QA-007-14** (`contrato`, baja: la lista estática no retira los builtins especiales `return`/`exit`/`break`/`continue`/`set`/`shift`/`:`; con `BASH_FUNC_return%%` sin decisión, con `break` no termina; 156/315 frente a 6 en `03cbf5e` y 200 en v1.35.0). **P-136-R = (A)** hecha (`c5bf6d4`, evidencia `70a2083`; 36 min usados del tope; SIN VALIDAR): `unset -f return exit break continue set shift : eval trap unset exec .` en modo POSIX; con `return` y `break` suplantadas, 111 ms y decisión correcta; sección 47 106/0; banco 2302/0/14; +0 procesos; E1 igual. **En curso: re-verificación acotada de QA (Opus, comisión nueva).** Después: seguridad (fase 4), commit validado, paso 7.** Plan literal en `PENDING_APPROVAL.md` § Resueltas. **Paso 5 cerrado como intervención** (commit validado; R-055 sin veto; SEC-127 y SEC-128 `mitigado`; SEC-130 → F-136-12). **P-136-N pendiente del propietario** (QA-007-07: paso 6 o 1.37); el plan del paso 6 tiene las dos variantes. **Si la sesión se corta, se continúa desde la última fase comiteada sin pedir la autorización.**
>
> **Intervención 1 (CA-54), cerrada en la décima autorización:** candidato `82ceb63` (`hooks/` igual tras el revert `74da4c5`). QA: «con hallazgos: QA-007-01 declarado como límite» (`docs/qa/REQ-007.md`; recuento corregido a 10 de 30). Seguridad: R-052, con hallazgos y sin veto, **SEC-127** (`contrato`, baja) → **P-136-G pendiente del propietario**. La 2b va después de SEC-120 (`docs/PLAN.md` § 1.36.0).

- **1.35.0 publicada el 2026-10-03:** `main` en `3956a6f` (fusión del PR #59), tag `v1.35.0` sobre esa fusión, CI final run `37169938675` (success) sobre `c0f8493`. Plugin instalado según el propietario: **1.35.0**. **Pero en este host (WSL2), `installed_plugins.json` registra 1.33.2** (`10eac80`, `lastUpdated` 2026-09-11), y el bloque derivado dice lo mismo. Las puertas que gobiernan esta sesión son las de 1.33.2. **Actualizada después, por petición expresa del propietario (2026-10-03):** `claude plugin marketplace update arnes-juan` + `claude plugin update arnes-juan@arnes-juan` (alcances `user` y `project`) → **1.35.0**, `gitCommitSha` `3956a6f`; cada archivo de `hooks/` comparado con `git show v1.35.0:` es idéntico. **Rige desde el próximo reinicio de Claude Code:** esta sesión sigue con los hooks de 1.33.2 ya cargados. Registro: `PENDING_APPROVAL.md` § Resueltas, «Publicación de v1.35.0 ejecutada», y la línea «PUBLICADA» de las notas `[1.35.0]`.
- **Cabeza de partida:** `cand/1.36.0` desde `origin/main` = `3956a6f`. Sin push.
- **`arnes_version`** de `.arnes/config.json` sigue en `1.33.0` por decisión del propietario (`5d810f0`): es la migración del proyecto y la escribe `/arnes-upgrade`.
- **Lectura del propietario, literal (2026-10-03):** «El impedimento del proveedor de la novena autorización fue sobre el contenido del despacho de SEC-124/125 y la lectura de su diff, no sobre los roles. Los encargos de 1.36.0 se redactan por propiedad y medida.»
- **Alcance de 1.36.0, decidido por el propietario el 2026-10-03, en este orden de prioridad:**
  1. **CA-54 / QA-023-10:** el análisis de `Bash` en el máximo declarado (131 072 bytes) termina en menos de 5 s en Linux/WSL2, sin cambiar ningún veredicto del banco (2050 casos) y sin subir el umbral ni reducir la entrada. Es optimización de rendimiento; se mide con el banco y las sondas existentes.
  2. **SEC-120** (vence el 2026-10-29): un fallo de `jq` al leer o trocear la entrada da deny en las herramientas que las puertas juzgan. Comprobación de código de salida, sin procesos nuevos.
  3. **SEC-115 y SEC-118:** fail-closed cuando el hook agota tiempo o el motivo excede el tope; emitir decisión siempre; medir el tope en bytes, ASCII y multibyte, en Linux; Windows declarado no medido.
  - **Fuera de alcance:** el hueco C, P-119-A (F2, F5, F7) y el mecanismo de SEC-123.
- **Esta sesión abre y no implementa.** No se despacha al desarrollador, a QA ni a seguridad. La implementación de CA-54 la autoriza el propietario aparte, sobre el contrato.
- **Contrato de 1.36.0 escrito por el `analista-requerimientos` (2026-10-03), SIN VALIDAR** (ni QA ni seguridad lo han revisado; la coordinadora no juzga su contenido):
  - **CA-54 / QA-023-10:** nota de CA-54 del 2026-10-03 en REQ-007. Versionado, no REQ nuevo: la propiedad y los números no cambian, y un REQ nuevo reiniciaría el contador. Medida: las dos sondas de CA-54 del árbol de evidencia, más el inventario caso a caso del banco de v1.35.0 contra los hooks de v1.35.0 y del candidato.
  - **SEC-120:** REQ-007 CA-47 punto 20, medido en la sección 44 con fail-before contra v1.35.0 y 0 procesos añadidos.
  - **SEC-118 y SEC-115:** REQ-007 CA-67 y CA-68, con CA-69 como evidencia común, y **ADR-017** (`propuesta`, cambio de fondo).
- **Fichas en la cola (3), del propietario:** P-136-A (procesos en CA-54), P-136-B (qué es «el tope» de SEC-118 y si entran los avisos) y P-136-C (mecanismo y plazo de SEC-115). **Mientras estén en Pendientes, `guard-completado` impide marcar cualquier REQ como `completado`.** No impiden implementar ni probar lo que no dependa de ellas; cada ficha dice qué sigue.
- **Avisos del analista, sin resolver:**
  - SEC-118 y SEC-120 están en `Hallazgos abiertos:` de REQ-023, y SEC-115 en el de REQ-031, no en el de REQ-007. Moverlos lo decide el auditor;
  - las sondas de CA-54 viven en el árbol de evidencia y cargan una biblioteca de un `/tmp` que ya no existe;
  - el índice está desfasado en las filas de REQ-001 y REQ-031;
  - CA-68 puede afectar a REQ-017 CA-09, y REQ-017 está `completado`;
  - el fail-before de SEC-120 se vuelve a medir en v1.35.0.
- **Próximo paso:** que el propietario resuelva las fichas y autorice, aparte, la implementación de CA-54.
- **REQ y firmas:** sin cambios respecto al cierre de 1.35.0. REQ-023, REQ-031 y REQ-001 en `en-revisión` con QA y seguridad aprobados; REQ-007 en `en-progreso` con `QA:` y `Seguridad:` en `pendiente`. Ningún REQ cerrado. El contador dev↔QA de REQ-023 sigue en 3 de 3.

## Historia — candidato 1.35.0: notas finales escritas, SEC-126 corregido y P-119-A resuelta como límites declarados; falta lo manual del propietario: `arnes_version`, push, PR, CI, fusión y tag (2026-10-03)

*(Historia desde el 2026-10-03: 1.35.0 está publicada y lo sustituye el bloque de 1.36.0, arriba. El texto siguiente no se reescribe.)*

**Este bloque es el único vigente en la rama `cand/1.35.0`** (worktree `/home/juan/dev/ArnesJuan-v1.35`). Todo lo que está debajo es historia.

- **Cabezas (comprobadas el 2026-10-03):**
  - `cand/1.35.0` local **por delante de `244c4f1`** (contrato de la fase 2, SIN VALIDAR), con un commit de trazabilidad encima, y **sin push**. Antes: `3f96e6b` (fase 1), `fff53f4` (traspaso) y `c0c8be2` (R-047);
  - `origin/cand/1.35.0` y el PR #59 (borrador) en `45368ce`, según la última consulta de red del 2026-10-03. Su CI `37032468437` está en verde **para `45368ce`** y no acredita la cabeza local;
  - evidencia en la rama local `evidencia/prueba-despacho-2026-09-14`, en `af2eddd` (`cand-1.35.0/evidencia-seg-r8/`, de R-047).
- **Intervención terminada: la octava autorización** (2026-10-02).
  - Hecho: SEC-122 (las dos caras), QA-023-14 y P-023-13-A en `9220c71`, con la pasada correctiva `befc17a`. QA favorable sobre `5669a2c` (re-verificación en `57129fb`). Seguridad R-047 sobre `57129fb`: lo reparado es conforme, a nivel de hook en Linux/WSL2.
  - R-047 abrió SEC-123 (`instrumento`), SEC-124 (`contrato`, introducido por `9220c71`) y SEC-125 (`instrumento`, preexistente).
  - **Su presupuesto está agotado.** El push y la corrida de CI que autorizaba no se hicieron, porque los condicionaba a una determinación de seguridad favorable al delta, y SEC-124 lo impidió.
- **Decidido por el propietario el 2026-10-03** (`PENDING_APPROVAL.md` § Resueltas, entrada de esa fecha, texto literal):
  - SEC-124: opción (B), denegación con motivo explícito;
  - SEC-125: reparar antes de publicar;
  - SEC-123: corregir la descripción de F3.

  **No autoriza ejecutar.** No cambia criterios, estados, veredictos ni contadores (el de REQ-023 sigue en 3 de 3).
- **Pendiente del propietario, sin aceptar:**
  - la implementación manual de SEC-124 y SEC-125 (abajo, en «Fase 2»); la autorización de ejecución ya la dio la novena;
  - 9b (QA-023-10, CA-54);
  - fichas 1 (SEC-115/SEC-118) y 2 (C);
  - P-119-A (F2, F5, F7 y el límite de F3);
  - SEC-120 (vence el 2026-10-29).
- **Firmas vigentes:** REQ-023, REQ-031 y REQ-001 tienen QA y seguridad aprobados sobre el código de `befc17a`, en `en-revisión` y **sin cerrar**. REQ-007 está en `en-progreso`, con QA y seguridad pendientes.
- **Plan:** `propuesta-v1.35.0/plan-implementacion.md` sigue **incompleto y no autoriza implementación**. Le faltan §3 (propiedades de diseño) y §7 (validación). El 2026-10-03, durante la actualización documental autorizada, un control de seguridad del proveedor volvió a interrumpir esa redacción; es la segunda vez, tras la sesión anterior. No se intentó reproducir ni rodear. El resto de `propuesta-v1.35.0/` (README, `SEC-047.diff` y `evidencia/`) es la propuesta **histórica** de SEC-047 del 2026-09-29.
- **Traspaso (2026-10-03): `propuesta-v1.35.0/TRASPASO.md`.** Reúne el estado, las decisiones, el trabajo sin comitear, las fuentes por sección, la cobertura, las preguntas para la revisión humana de §3 y §7 y las decisiones de publicación pendientes. **Se retoma desde ahí.**
- **Novena autorización (2026-10-03, en curso; registrada literal en `PENDING_APPROVAL.md` § Resueltas, con una pasada correctiva por fase):**
  - **Fase 1, SEC-123 (F3):** validada, con QA favorable tras su única pasada (QA-023-18 cerrado) y seguridad R-048 favorable; queda en un commit local. SEC-123 sigue `abierto` y sin aceptar. Nuevo SEC-126 (`instrumento`, comentario de código), sin encadenar ninguna reparación.
  - **Fase 2, SEC-124 (B) y SEC-125: DETENIDA por un control del proveedor (2026-10-03).**
    - **Hecho y comiteado en local SIN VALIDAR (tarea 1 del encargo del 2026-10-03, posterior a `3f96e6b`):** el contrato del analista (REQ-007 CA-47 puntos 18 y 19, CA-66 versionado de la fase 2, ADR-016, notas `[1.35.0]`, guía e índice). Las dos decisiones del propietario sobre ese contrato (SEC-124 por la forma y a todo agente; LC8 deny→allow declarado) están registradas en `PENDING_APPROVAL.md`.
    - **Impedimento:** un control de seguridad del proveedor detuvo el despacho al `desarrollador`. **No se implementó nada:** código y banco sin cambios.
    - **Lo que no se hizo para rodearlo:** no se reintentó, no se partió el encargo para mandar una parte sola, no se delegó y no se cambió de modelo ni de configuración.
    - **Lo que queda sin hacer:** el código y las pruebas de SEC-124 y SEC-125, su QA, su seguridad y su commit. SEC-124 y SEC-125 siguen `abierto`. La pasada correctiva de la fase 2 no se ha usado.
    - **Mediciones de QA de las dos lecturas del analista** (`docs/qa/REQ-023.md`, «Novena autorización, fase 2: mediciones…»; cabeza `244c4f1`, hooks iguales a `befc17a`; Linux/WSL2, bash 5.3.9, jq 1.8.2; hook directo y shell aparte; sin host). No hay hallazgos.
      - **(a)** Medida en parte: LC7 da allow, conforme con el contrato, y el shell no une. Ningún caso escrito discrimina el pliegue de `guard-git`, así que esa parte queda **no medida**.
      - **(b)** **No escrita en el contrato; no medida.**
    - **Caso (b) añadido al contrato (2026-10-03, posterior a `c4ad408`; SIN VALIDAR):**
      - **LC10** en CA-66: la continuación al final de la línea que abre un heredoc. LC10 sólo fija lo que ya exige el punto 19; el resto de la forma queda pendiente en **P-LC10-A** (REQ-007, «Preguntas abiertas»).
      - **Opciones de P-LC10-A:** (A) denegar por la forma, como SEC-124, que es lo que recomienda el analista y exige cambiar el punto 19; (B) unir las líneas como el shell; (C) fijar sólo lo del punto 19.
      - **Medición de QA** (`docs/qa/REQ-023.md`, «medición de LC10»; `c4ad408`, hooks iguales a `befc17a`; Linux/WSL2, bash 5.3.9, jq 1.8.2; hook directo y shell aparte; sin host):
        - lo que LC10 ya fija sale `allow` hoy en los tres árboles, que es el fail-before;
        - el analizador empieza el cuerpo una línea antes que el shell;
        - nuevo **QA-023-23** (`instrumento`, preexistente en `9596e39` y `v1.33.2`): una orden de git prohibida o una escritura protegida en la línea siguiente pasan las cuatro puertas, y el shell las ejecuta.
      - **QA-023-23 no se ha pasado** a `Hallazgos abiertos:` ni al registro de seguridad: lo decide el propietario.
      - **La lectura (a)**, el pliegue de `guard-git` ante una barra escapada, queda **no medida y fuera de esta versión** por decisión del propietario (REQ-007, Historial).
      - **Actualización (2026-10-03, posterior a `598792c`):**
        - **P-LC10-A resuelta por el propietario: (A).** El punto 19 lleva la «Excepción nombrada — LC10»: denegación por la forma, a todo agente, en las cuatro puertas, con motivo `SEC-125` · `LC10`. El falso positivo queda cubierto, y (B) y (C) quedan rechazadas. LC10 se desglosa en LC10.1–LC10.9 y los controles LC10.c1 y LC10.c2, con columnas tomadas de la medición sobre `c4ad408`. El punto 18 no cambia.
        - **QA-023-23 registrado:** en `Hallazgos abiertos:` de REQ-007 (por QA) y en `docs/seguridad/registro-seguridad.md`, R-049 (sólo registro, sin firma). Clase `instrumento`, preexistente, abierto y sin aceptar. La forma de LC10 lo cierra cuando esté implementada y validada; las demás formas siguen abiertas.
        - **Revisión documental de QA: CON-HALLAZGOS.** QA-023-24 (`contrato`, baja): la razón que sostiene «LC10 no añade movimientos» es falsa, aunque la conclusión es cierta. QA-023-25 (`contrato`, baja): la regla del motivo de LC10 choca con REQ-001 CA-53 (presupuesto). Están sólo en `docs/qa/REQ-023.md`, no en la cabecera.
        - **El contrato de la fase 2 está completo para implementar HC1–HC9, LC1–LC9 y LC10**, salvo **el motivo cuando LC10 coincide con un comando que supera el presupuesto** (QA-023-25), que depende de la pasada correctiva del analista.
        - **Decidido por el propietario (2026-10-03, posterior a `3158bf9`; literal en `PENDING_APPROVAL.md`):**
          - QA-023-25: precede REQ-001 CA-53. Lo que supera el presupuesto se deniega sin analizar, con el motivo de CA-53; el motivo SEC-125/LC10, sólo para las denegaciones que produce el análisis.
          - QA-023-24: el punto 5 de CA-66 y las notas se corrigen.
          - Las dos correcciones las aplica el **propietario** junto con el código.
          - **La pasada correctiva de la fase 2 se reserva para el código**, y QA verifica texto y código juntos.
          - La precisión sobre `guard-codigo` y `guard-git` en LC10 se mantiene.
        - **IMPLEMENTACIÓN MANUAL EN CURSO (propietario): código de los puntos 18 y 19, filas HC/LC del banco, correcciones QA-023-24 y QA-023-25.** La lista de sedes y los comandos están más abajo, en «ESTADO: IMPLEMENTACIÓN MANUAL PENDIENTE». Después: QA (Opus), con la pasada de la fase 2 si hace falta; luego seguridad con QA favorable; luego el commit.
        - **2026-10-03, posterior a `093e81e`:** el propietario autorizó un despacho nuevo al `desarrollador`. **No se ejecutó:** sería volver a producir, reformulado, el despacho que ya detuvo un control del proveedor, y la instrucción de ese bloqueo lo prohíbe. **La implementación sigue siendo manual** (registro en `PENDING_APPROVAL.md`). No se despachó a nadie y no cambió el código.
        - **Delta construido por el propietario** (`9467f02`, `10ac6c4`, `36a0d27` y `5121638`, SIN VALIDAR): la sección 46 (HC1–HC9, LC1–LC10), los puntos 18 y 19 con LC10, y el texto de QA-023-24/25. `Archivos:` de REQ-007 se completó en `ee9c3ce`.
        - **IMPEDIMENTO (2026-10-03, sobre `ee9c3ce`): la validación de QA de la fase 2 la detuvo un control del proveedor** mientras QA leía el diff de `hooks/`.
          - **No hay veredicto.** QA no ejecutó gates, sección 46, regresiones, banco, autoprueba, fail-before, shell aparte, coste ni la revisión del texto de QA-023-24/25, y no modificó ningún archivo.
          - **Las cifras del propietario** (2038/0/12; 2050 casos) siguen sin repetir por QA y no acreditan nada.
          - **No se reintentó ni se reformuló.** Seguridad **no se despacha**, porque no hay QA favorable (§6), y el write-back del analista depende de los dos veredictos.
          - **SEC-124, SEC-125 y LC10 no se declaran reparados**, y QA-023-23/24/25 siguen como estaban. La pasada correctiva de la fase 2 sigue sin gastar.
          - **Decide el propietario cómo se valida.** Volver a despachar esta validación a QA sería repetir la acción detenida.
        - **Resuelto por el propietario (posterior a `92ec1fa`, literal en `PENDING_APPROVAL.md`):**
          - **Validación por vía manual:** la del propietario (`docs/qa/REQ-023.md`, «validación del delta construido por el propietario — vía manual»), con una segunda medición externa y el CI run 37163342218 (success). Todo en `ddd1241`.
          - **Sin firma del qa-tester ni del auditor-seguridad.**
        - **Write-back de estado (analista, posterior a `ddd1241`):**
          - **Puntos 18 y 19 y CA-66 fase 2:** «construido en `10ac6c4` y `36a0d27`; validado por el propietario por vía manual (`docs/qa/REQ-023.md`, CI run 37163342218); sin firma del qa-tester ni del auditor-seguridad por impedimento del proveedor». Lo mismo en ADR-016, las notas, la guía y el índice.
          - **`Hallazgos abiertos:` de REQ-007:**
            - SEC-124 (`contrato`) y SEC-125 (`instrumento`): «reparado en su alcance (validación manual del propietario)»;
            - QA-023-23: «cerrado en la forma de LC10; abierto en cualquier otra»;
            - QA-023-24 y QA-023-25: cerrados; nunca estuvieron en el campo.
          - **R-050:** sólo registro, sin firma.
          - **`QA:` y `Seguridad:` de REQ-007 siguen `pendiente`.** SEC-124 sigue en el campo como `contrato`, así que también impide cerrar REQ-007.
          - **Comprobado por la coordinadora:** `tools/arnes-lectura.sh .` no ve anomalías. Un cierre simulado en una copia con la puerta real deniega por `QA: pendiente` y, con los veredictos forzados, por el primer `contrato` de la lista: la puerta interpreta el campo.
    - **Cierre, tramo 2 (2026-10-03, posterior a `52a1d39`): las decisiones de publicación del propietario**, literales en `PENDING_APPROVAL.md` § Resueltas:
      - **CA-54 / QA-023-10:** aceptado con alcance; se repara en 1.36.0.
      - **SEC-115/118:** límites declarados; fail-closed en 1.36.0.
      - **SEC-120:** límite declarado; se repara en 1.36.0, antes del 2026-10-29.
      - **Hueco C:** límite declarado, sin fecha.
      - **P-119-A (F2, F5, F7) y SEC-123:** límites declarados, abiertos y no aceptados como riesgo.
      - **SKIP e INCONCLUSO:** no acreditan.
      - **«siete» → «ocho»**, corregido.
      - **Las firmas de la fase 2:** ausentes y declaradas.
      - **Escrito por el analista** en las notas `[1.35.0]` y en la guía. `requirements/README.md` no cambia.
      - **La cola queda vacía:** la entrada pendiente pasó a § Resueltas, sin cambiar su texto. Cerrar requisitos sigue sin estar autorizado.
      - **SEC-126 no se corrige:** está en `hooks/lib.sh` l. 704, ruta protegida. `guard-codigo` deniega la edición a la coordinadora y `AGENTS.md` §6 la manda al `desarrollador`, que no se despachó. No se intentó ningún rodeo. Queda para el propietario (manual) o para 1.36.0.
      - **Pendiente, declarado por el analista y sin autorizar:**
        - P-119-A sigue en «Preguntas abiertas» de REQ-007 y como «abierta» en su fila del índice, aunque el propietario ya la resolvió como límites declarados;
        - el motivo caso por caso de los SKIP no está en ninguna sede: está sólo en el log del CI;
        - una nota de historia de las notas menciona un «ocho» antiguo.
      - **`QA:` y `Seguridad:` de REQ-007 siguen `pendiente`.**
    - **Cierre, tramo 3 (2026-10-03, posterior a `8522e4f`; decisiones literales en `PENDING_APPROVAL.md`):**
      - **SEC-126:** corregido por el propietario en el comentario de `hooks/lib.sh`. La coordinadora verificó que el diff de `hooks/` es un solo archivo y sólo líneas de comentario, y las gates de §7 dan rc 0. Queda como «reparado» en las notas y en R-051 (sólo registro, sin firma). Que el texto nuevo cumpla la propiedad de R-048 §4 no lo comprobó ningún agente.
      - **P-119-A:** resuelta como límites declarados en REQ-007 (sin campos de cabecera) y en el índice. F2, F5 y F7 siguen abiertos y no aceptados. REQ-007 ya no tiene preguntas abiertas.
      - **Notas `[1.35.0]`:** son las notas finales, con «Qué cambia», «Límites declarados» (con alcance y consecuencia), «Lo no medido: el host y Windows/MSYS», «Firmas ausentes, y por qué», «Hacia 1.36.0» (CA-54, SEC-115/118, SEC-120, que vence el 2026-10-29) e «Historia». Los SKIP remiten al log del CI y a `docs/qa/REQ-023.md`. Ningún identificador de las notas anteriores desaparece (comprobación de la coordinadora).
      - **La guía** está alineada con las notas.
      - **`QA:` y `Seguridad:` de REQ-007 siguen `pendiente`.** No se ha cerrado ningún REQ.
    - **Prueba en el host, CLI dentro de WSL2 (2026-10-03, cabeza `5d810f0`, hooks idénticos a `a51dc5b`; la ejecutó la coordinadora con registro previo):**
      - **Entorno:** Claude Code **2.1.285**, `claude -p`, con la sonda de `sec119-r6` delante de `guard.sh` del worktree. No se cargó `arnes-juan` 1.33.2. Sesión de la coordinadora.
      - **(1) Heredoc normal a `docs/`:** allow; `docs/nota.md` escrito.
      - **(2) Escritura partida con `\` y salto hacia `docs/`:** el hook la recibió con la barra y el salto; allow; `docs/partida.md` escrito.
      - **(3) `echo x > src/algo`:** **deny**, con el motivo «el comando escribe en 'src/algo', que es código de la app; sólo el agente 'desarrollador'…»; el host lo bloqueó y `src/algo` no existe.
      - **Evidencia:** en el scratchpad de la sesión, `host-a51dc5b/` (PREREGISTRO, RESULTADO, logs de la sonda y `stream.jsonl`). **No está en la rama de evidencia.**
      - **No ejercido:** el **panel de la extensión** (lo hace el propietario), Windows/MSYS, `MultiEdit` y las formas HC/LC que deniegan.
      - **Notas `[1.35.0]` actualizadas** en «Lo no medido» › «El host», con la línea de esta prueba, por decisión del propietario. La guía no lo decía para la fase 2 y no cambia. La evidencia está copiada a la rama de evidencia, `cand-1.35.0/host-a51dc5b/ (nombre del directorio de la sesión; la cabeza probada es `5d810f0`)`.
    - **LO QUE EL PROPIETARIO HACE A MANO PARA PUBLICAR:**
      1. **`.arnes/config.json`, clave `arnes_version`:** `"1.33.0"` → `"1.35.0"` (l. 3). Es archivo protegido. `plugin.json` (`version`) y `marketplace.json` (`metadata.version`, `plugins[0].version`) ya están en `1.35.0`.
      2. **En el mismo commit**, el párrafo de `arnes_version` de las notas `[1.35.0]` (`CHANGELOG.md`, «Límites declarados», el que dice «sigue en `1.33.0` … Este commit no la toca»), que dejaría de ser cierto.
      3. **Push** de `cand/1.35.0` sin force y **una sola corrida de CI** sobre la cabeza final. Se conserva el resultado y no se relanza.
      4. **Actualizar el PR #59**, quitarle el borrador, **fusionar** a `main` y crear el **tag `v1.35.0`**.
      5. **Actualizar la instalación estable** del plugin y comprobarla. Después, si se quiere, la comprobación en VS Code (CLI dentro de WSL y, aparte, la extensión).
    - **ESTADO: IMPLEMENTACIÓN MANUAL PENDIENTE (la escribe el propietario).** La coordinadora no despacha al desarrollador. Lo que sigue sólo ahorra búsqueda: no es diseño ni código.
      - **Especificación:** `requirements/REQ-007.md`.
        - CA-47 **punto 18** (SEC-124) y **punto 19** (SEC-125).
        - CA-66, «versionado de la fase 2», con la tabla **HC1–HC9 / LC1–LC9**, sus cuatro columnas, los movimientos, la validación por capa y el coste.
        - La tabla de sedes del analista: «Sedes y pruebas del versionado del 2026-10-03, fase 2», l. ~2093.
        - Fuente de los casos: R-047 §3 y §4, y `cand-1.35.0/evidencia-seg-r8/` en la rama de evidencia.
      - **Sedes de código** (líneas en `244c4f1`, a confirmar al editar):

        | Sede | Responde a |
        |---|---|
        | `hooks/lib.sh`, `arnes_bash_sin_texto` (l. 1659; bucle de heredocs; devuelve `ARNES_RC_CR` en l. 1745; la constante, en l. 1359) | CA-47 p. 18; CA-66 HC1–HC9 |
        | `hooks/lib.sh`, `arnes_bash_escrituras` (l. 1766) | CA-47 p. 19; CA-66 LC1–LC9 |
        | `hooks/guard-codigo.sh`, traducción de los códigos de `arnes_bash_escrituras` (l. 61–70) | CA-47 p. 18, el motivo con `SEC-124` |
        | `hooks/guard-completado.sh`, la misma traducción (l. 332–343) | CA-47 p. 18, el motivo |
        | `hooks/guard-git.sh`, `arnes_guard_git` (l. 166; el pliegue de SEC-009 en l. 210–213) | CA-47 p. 18 (la forma la deniega `guard.sh` aunque `guard-git` permita); p. 19 / P9, sólo como referencia que hay que comprobar |
      - **Sedes del banco:**
        - `tests/escenarios/hooks/secciones/45-dependencia-del-proceso-y-cr-del-comando.sh`, o una sección nueva; si es nueva, el campo `Archivos:` de REQ-007 lo actualiza el analista;
        - `run.sh`, con `CASOS_ESPERADOS` (l. 1659, hoy 1787) y el `CASOS_ESPERADOS_SECCION` de la sección;
        - `tests/escenarios/hooks/README.md`.

        Todo ello responde a CA-66, fase 2.
      - **Comandos** (desde la raíz del worktree):
        - Sección 45 sola: `bash tests/escenarios/hooks/run.sh secciones/45-*.sh`
        - Regresión de SEC-047 / SEC-119 / SEC-122: `bash tests/escenarios/hooks/run.sh secciones/08-*.sh secciones/41-*.sh secciones/33-acento-y-clave-2-*.sh secciones/43-*.sh secciones/45-*.sh`
        - Regresión que añade el contrato (heredocs de REQ-001, REQ-005 CA-40/CA-41, escrituras por `Bash`, `guard-git`): `bash tests/escenarios/hooks/run.sh secciones/06-*.sh secciones/07-*.sh secciones/09-*.sh secciones/29-*.sh`
        - Fail-before: los mismos selectores con `ARNES_HOOKS_DIR=<copia de los hooks de 3f96e6b>`; columnas `9596e39` y `v1.33.2` por la misma vía.
        - Banco completo: `bash tests/escenarios/hooks/run.sh` · autoprueba: `bash tests/escenarios/hooks/autoprueba-corredor.sh`
        - Gates de §7: `for f in hooks/*.sh tools/*.sh; do bash -n "$f" || exit 1; done` · `jq -e . hooks/hooks.json >/dev/null` · `jq -e . .claude-plugin/plugin.json >/dev/null && jq -e . .claude-plugin/marketplace.json >/dev/null`
      - **Después del código:** QA (Opus, §5), con la pasada correctiva de la fase 2 si hace falta; luego seguridad con QA favorable; luego el commit local. Esas comisiones de revisión sí las puede despachar la coordinadora, porque no producen código.
- **Impedimento (2026-10-03, posterior a `fff53f4`; anterior a la novena autorización):** el propietario autorizó implementar SEC-124 (B), SEC-125 y la corrección de F3, con analista, desarrollador, QA y seguridad, una pasada correctiva como máximo y sin reiniciar contadores. Al iniciar la ejecución, un control de seguridad del proveedor detuvo la respuesta de la coordinadora. **No se ejecutó ningún paso, no se despachó a ningún agente y no cambió ningún archivo de código ni de contrato.** No se reintentó, no se delegó y no se cambió de modelo. SEC-123, SEC-124 y SEC-125 siguen `abierto`.
- **Siguiente paso real (2026-10-03, posterior a `3158bf9`):** la implementación manual del propietario, que está en curso: código de los puntos 18 y 19, filas HC/LC del banco y correcciones QA-023-24 y QA-023-25. Cuando la entregue, QA verifica texto y código juntos.
- **Siguiente paso anterior (historia):** que **una persona** revise las fuentes del traspaso y redacte, o decida no redactar, §3 y §7 del plan (`TRASPASO.md` §6 y §8). La coordinadora no las reintenta ni las delega. Después vendría la autorización de ejecución. Hasta entonces no se despacha a nadie y no se abre ninguna vuelta.
- **Conservado en un commit local del 2026-10-03, sin push:** este archivo, `PENDING_APPROVAL.md`, `CHANGELOG.md`, `propuesta-v1.35.0/plan-implementacion.md` y `propuesta-v1.35.0/TRASPASO.md`. Es historial local, **no** una copia remota: `origin` y el PR #59 siguen en `45368ce`. **Sin seguimiento:** los cinco archivos históricos de `propuesta-v1.35.0/` (`TRASPASO.md` §3).

## Historia — octava autorización terminada; SEC-124 impidió la determinación favorable (2026-10-02)

**ACTUALIZACIÓN 2026-10-02 (octava autorización), historia; la sustituye el bloque vigente de arriba:**
- **Rama:** `cand/1.35.0` local en `c0c8be2`, **sin push**. `origin` y el PR #59 siguen en `45368ce`.
- **Hecho:** SEC-122 (las dos caras), QA-023-14 y P-023-13-A reparados (`9220c71`), con pasada correctiva (`befc17a`); QA favorable; seguridad R-047 conforme con las reparaciones.
- **Impedimento:** SEC-124 (`contrato`), introducido por el delta. Decisión 11.
- **Pendiente del propietario:** decisión 11; 9b (CA-54); fichas 1 y 2; P-119-A (con SEC-123); SEC-125; SEC-120.
- **El presupuesto de la octava autorización está agotado.** No se abre nada sin decisión.

**ACTUALIZACIÓN 2026-10-02 (séptima autorización), historia:**
- **Estado de la rama:** `cand/1.35.0` = `origin` = PR #59 (borrador) en `45368ce`; CI `37032468437` en verde.
- **QA-023-13:** reparado (`3bc7d3c`), con QA favorable y seguridad R-046 conforme. El caso CR no se ejerció en el host.
- **Firmas:** REQ-023, REQ-031 y REQ-001 tienen QA y seguridad aprobados sobre el código final.
- **SEC-122:** nuevo, `contrato` en REQ-007 (R-046).
- **Pendiente del propietario:** la decisión 10 (SEC-122), la 9b (QA-023-10, con la medición de Windows/MSYS en `sec-ca54-win/`), P-023-13-A, las fichas 1 y 2 y P-119-A.
- **No se abre ninguna vuelta sin decisión.**
- **Evidencia:** rama local de evidencia, hasta `b91068e`.

## Historia — la vuelta de la sexta autorización cerró QA-023-09 y QA-023-11, pero QA fue NO favorable por QA-023-13; QA-023-10 abierto; esperando la decisión 9, las fichas 1 y 2 y P-119-A (2026-10-01)

*Cuando se escribió (2026-10-01), este bloque mandaba en la rama `cand/1.35.0`. Hoy es historia; las cabezas, el próximo paso y lo que estaba sin comitear que cita ya no son los vigentes.*

- **Dónde está cada cosa:**
  - `cand/1.35.0` = `origin/cand/1.35.0` = PR #59 (borrador), en `452098e`.
  - Evidencia en la rama local `evidencia/prueba-despacho-2026-09-14`:
    - `sec119-r6/` (`215f916` y `3eb279d`);
    - `cand-1.35.0/evidencia-dev-r6/` (`3b947a1`), con el parche de la optimización retirada;
    - `cand-1.35.0/evidencia-qa-r6/` (`0d3d0c9`);
    - CI intermedio (`db565a4`).
- **Sexta autorización (decisión 8):**
  - **QA-023-09, cerrado:** lectura campo a campo (`cd6afa6`); CA-47 puntos 12 y 13; host r6 conforme.
  - **QA-023-11, cerrado:** CA-45 con la v3b.
  - **QA-023-10, abierto:** la optimización no llegó a 5 s, se detuvo y salió del candidato.
  - **QA-023-13, nuevo y bloqueante:** un CR final del `cwd` se recorta y las puertas anclan en otro directorio, deny→allow frente a 1.33.2. Nace del anclaje de `104ffd1`.
  - **Seguridad:** no despachada, porque QA no fue favorable.
- **Próximo paso concreto:** la decisión del propietario sobre la **decisión 9**. Recomendado 9a (A), reparar fallando cerrado, y 9b (A), residual declarado con una medición en Windows/MSYS antes de publicar. **No se abre ninguna vuelta sin esa decisión.**
- **Sin comitear, a propósito:** este archivo (bloque derivado y este bloque) y `propuesta-v1.35.0/`.

## Historia — la vuelta de SEC-119/O-11 (quinta autorización) terminó con QA NO favorable (2026-10-01)

- **Quinta autorización (SEC-119 y O-11):**
  - **Hecho:** contrato (REQ-007 CA-45/CA-47, ADR-016), código (`104ffd1`), banco (sección 43, 1334 casos) y validación en el host (v3, `94c6191`).
  - **QA sobre `43b948a`: NO favorable.** QA-023-09 es una regresión de `104ffd1`: un `cwd` con salto de línea desplaza los campos de la entrada, y las dos puertas juzgan otra ruta. Se manifiesta en el host (v3b); un permiso desde el host no está observado ni descartado. QA-023-10 es el coste de CA-54. QA-023-11 era la validación en el host incompleta; sus casos ya se ejecutaron, y queda declarar R5 como límite.
  - **Seguridad:** no se pidió, porque QA no fue favorable.
- **Resuelto:** el propietario eligió la opción (A) de la decisión 8 en la sexta autorización (2026-10-01).

## Historia — candidato 1.35.0 (PR #59): SEC-117 reparado, validado en el host real y con QA y seguridad aprobados; SIN publicar; esperando las fichas 1, 2 y 4 y la decisión 7 (2026-09-30)

- **Autorizaciones:** `PENDING_APPROVAL.md` § Resueltas, cuatro del 2026-09-29/30, literales. La segunda llegó truncada.
- **Vuelta excepcional agrupada** (tercera y cuarta autorización): el contador de REQ-023 sigue agotado (3 de 3), no se reinició y no se creó otro REQ.
  - **Contrato:** REQ-023 CA-13 (SEC-117) con ADR-015; REQ-001 CA-10/11/12 y REQ-007 CA-46 (c) versionados; REQ-001 reabierto; QA-023-06 y REQ-031 CA-A13.
  - **Código:** `5dfabb3`, con el banco adaptado sin retirar casos y la sección 42.
  - **Validación en el host real:** en la rama local de evidencia, `sec117-real-v2/`. El caso que antes cerraba ahora deniega.
  - **QA:** aprobado en REQ-023, REQ-031 y REQ-001. **Seguridad:** R-045-A aprobado en los mismos tres, con SEC-117 `mitigado`.
- **Estados:** REQ-023, REQ-031 y REQ-001 en `en-revisión`, **sin cerrar**, porque cerrar está impedido por la cola y no autorizado. REQ-007 sigue `en-progreso`.
- **Espera al propietario:**
  - ficha 1 (SEC-115/SEC-118);
  - ficha 2 (C);
  - **ficha 4 (SEC-119, rutas no canónicas; seguridad recomienda reparar antes de publicar)**;
  - **decisión 7 (O-11, archivo ilegible; recomendada la opción B)**.

  Nada de esto está aceptado.
- **Condiciones de publicación todavía pendientes:** las notas deben declarar SEC-119, SEC-120 y la tercera vía de SEC-115, o sus reparaciones, según se decida; el CI de la cabeza final; y la fusión, el tag y la publicación, que son decisión del propietario.

## Historia (rama `feat/fidelidad-encargo`) — REQ-029 fidelidad al encargo: entrega implementada y firmada, SIN cerrar (2026-09-23)

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

## Historia (`main`) — REQ-025 entrega 1 (coordinación orientada a entregas), 2026-09-21

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
## Estado derivado — 2026-10-07 12:45

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `cand/1.36.0` @ `c5bf6d4` — CON CAMBIOS SIN COMITEAR
**Arnés:** plugin instalado `1.35.0` · el proyecto declara `1.33.0` — **migración pendiente** (`/arnes-upgrade`)
**Aprobaciones pendientes:** 0
**REQ:** 29 — completado 14 · en-revisión 5 · en-progreso 1 · bloqueado 1 · otros 8
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 14 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-001 | en-revision | aprobado | aprobado | critico | qa-006(instrumento),qa-011(instrumento),… |
| REQ-007 | en-progreso | pendiente | pendiente | critico | qa-114(contrato,dueñoanalista-requerimie… |
| REQ-008 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-011 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-013 | en-revision | con-hallazgos | con-hallazgos | critico | sec-014(contrato),sec-020(contrato),qa-2… |
| REQ-018 | borrador | pendiente | pendiente | critico | (ninguno) |
| REQ-019 | pendiente | pendiente | preventiva | critico | sec-033(contrato) |
| REQ-020 | pendiente | pendiente | preventiva | critico | sec-038(contrato),sec-039(contrato),sec-… |
| REQ-021 | bloqueado | con-hallazgos | preventiva | critico | dev-021-05(instrumento,dueñoanalista-req… |
| REQ-022 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-023 | en-revision | aprobado | aprobado | critico | sec-118(instrumento,r-045:unmotivodedene… |
| REQ-024 | borrador | pendiente | pendiente | critico | (ninguno) |
| REQ-025 | en-revision | aprobado | aprobado | critico | qa-025-08(instrumento),sec-103(instrumen… |
| REQ-028 | borrador | pendiente | pendiente | critico | (ninguno) |
| REQ-031 | en-revision | aprobado | aprobado | critico | sec-115(instrumento,r-044-c:unhookquemue… |

<!-- ARNES:DERIVADO fin -->
